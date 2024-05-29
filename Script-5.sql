-- SETUP --

CREATE DATABASE ACTIVIDAD5

USE ACTIVIDAD5

CREATE TABLE Clientes (
    id_cliente INT IDENTITY(1, 2) PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    email VARCHAR(100) 
);

CREATE TABLE Ventas (
    id_venta INT IDENTITY(1, 1) PRIMARY KEY,
    id_producto INT,
    cantidad INT,
    fecha_venta DATETIME
);

CREATE TABLE LogBorrado (
    id_log INT IDENTITY(1, 1) PRIMARY KEY,
    id_venta INT,
    id_cliente INT,
    fecha_venta DATETIME,
    fecha_borrado DATETIME DEFAULT GETDATE()
);

CREATE TABLE Productos (
	id_producto INT IDENTITY(1, 1) PRIMARY KEY,
	nombre_producto VARCHAR(40),
	precio MONEY,
);

CREATE TABLE Empleados (
	id_empleado INT IDENTITY(1, 1) PRIMARY KEY,
	nombre VARCHAR(40),
	id_department INT,
	last_name VARCHAR(40),
	fecha_nacimiento DATETIME
);

DROP TABLE Empleados ;

INSERT INTO Clientes (id_cliente, nombre, apellido, email) VALUES
(1, 'Juan', 'Perez', 'JUAN.PEREZ@EXAMPLE.COM'),
(2, 'Ana', 'Gomez', 'ANA.GOMEZ@EXAMPLE.COM'),
(3, 'Luis', 'Martinez', 'LUIS.MARTINEZ@EXAMPLE.COM'),
(4, 'Maria', 'Lopez', 'MARIA.LOPEZ@EXAMPLE.COM'),
(5, 'Carlos', 'Hernandez', 'CARLOS.HERNANDEZ@EXAMPLE.COM');

------------------------------------------- Disparadores BEFORE --------------------------------------------------

-- Ejercicio 1: BEFORE INSERT - Convertir Correos Electrónicos a Minúsculas
-- Contexto: Crea una tabla Clientes con las columnas id_cliente, nombre, apellido, y email.
-- Prueba del Disparador:
-- Resultado Esperado: El email se inserta en minúsculas (juan.perez@mail.com).

CREATE TRIGGER trigger_email_minusculas
ON Clientes
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO Clientes (nombre, apellido, email)
    SELECT nombre, apellido, LOWER(email)
    FROM INSERTED;
END;

SELECT * FROM Clientes;

--Ejercicio 2: BEFORE UPDATE - Asegurar Precio No Negativo
--Contexto: Crea una tabla Productos con las columnas id_producto, nombre_producto, y precio.
--Resultado Esperado: El precio se actualiza a 0.00.

CREATE TRIGGER trigger_asegurar_precio_no_negativo
ON Productos
INSTEAD OF UPDATE
AS
BEGIN
    UPDATE Productos
    SET precio = 0
    FROM Productos p
    INNER JOIN inserted i ON p.id_producto = i.id_producto
   	WHERE p.precio < 0;
END;

SELECT * FROM Productos;

INSERT INTO Productos (nombre_producto, precio) VALUES ('juguito de najanra', -15);

UPDATE Productos SET precio = -20 WHERE id_producto = 3;


--Ejercicio 3: BEFORE DELETE - Registrar Ventas Eliminadas
--Contexto: Crea una tabla Ventas con las columnas id_venta, id_producto, cantidad, y fecha_venta. Crea
--una tabla LogBorrado para registrar los borrados.
--Prueba del Disparador:
--Resultado Esperado: El id_venta y la fecha_venta se registran en la tabla LogBorrado.

CREATE TRIGGER trigger_before_delete_registrar_ventas_eliminadas
ON Ventas
INSTEAD OF DELETE
AS
BEGIN
    -- Insertar los registros eliminados en LogBorrado
    INSERT INTO LogBorrado (id_venta, fecha_venta)
    SELECT id_venta, fecha_venta
    FROM deleted;
    
    -- Eliminar los registros de la tabla Ventas
    DELETE FROM Ventas
    WHERE id_venta IN (SELECT id_venta FROM deleted);
END;

SELECT * FROM Ventas v ;
SELECT * FROM LogBorrado;

DELETE FROM Ventas WHERE id_venta = 1;

--Ejercicio 4: BEFORE INSERT - Validar Teléfono
--Contexto: Crea una tabla Usuarios con las columnas id_usuario, nombre, telefono.
--Prueba del Disparador:
--Resultado Esperado: El primer INSERT se completa con éxito, el segundo INSERT falla con el mensaje
--'El teléfono debe tener 10 dígitos'.

CREATE TRIGGER validar_telefono
ON Usuarios
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @TelefonoLength INT;
    DECLARE @Telefono VARCHAR(15);

    SELECT @Telefono = telefono FROM inserted;
    SELECT @TelefonoLength = LEN(@Telefono);

    IF @TelefonoLength < 6
    BEGIN
        RAISERROR('El tel�fono debe tener al menos 6 d�gitos', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;


CREATE TABLE Usuarios (
    id_usuario INT PRIMARY KEY,
    nombre VARCHAR(50),
    telefono VARCHAR(15)
);

BEGIN TRANSACTION;
INSERT INTO Usuarios (id_usuario, nombre, telefono) VALUES (1, 'Usuario1', '123456789');
INSERT INTO Usuarios (id_usuario, nombre, telefono) VALUES (2, 'Usuario2', '987654321');
INSERT INTO Usuarios (id_usuario, nombre, telefono) VALUES (3, 'Usuario3', '111222333');
INSERT INTO Usuarios (id_usuario, nombre, telefono) VALUES (4, 'Usuario4', '444555');
INSERT INTO Usuarios (id_usuario, nombre, telefono) VALUES (5, 'Usuario5', '777777');
INSERT INTO Usuarios (id_usuario, nombre, telefono) VALUES (6, 'Usuario6', '12345');
COMMIT TRANSACTION;


--Ejercicio 5: BEFORE UPDATE - Validar Fecha de Nacimiento
--Contexto: Crea una tabla Empleados con las columnas id_empleado, nombre, fecha_nacimiento.
--Prueba del Disparador:
--Resultado Esperado: La actualización falla con el mensaje 'La fecha de nacimiento no puede ser futura'.

SELECT * FROM Empleados ;

CREATE TRIGGER trigger_before_update_validar_fecha_nacimiento
ON Empleados
INSTEAD OF UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE fecha_nacimiento > GETDATE())
    BEGIN
        RAISERROR('La fecha de nacimiento no puede ser futura', 16, 1);
        RETURN;
    END

    UPDATE Empleados
    SET nombre = inserted.nombre,
        fecha_nacimiento = inserted.fecha_nacimiento
    FROM inserted
    WHERE Empleados.id_empleado = inserted.id_empleado;
END;



INSERT INTO Empleados (nombre, fecha_nacimiento)
VALUES 
('Juan Perez', '2040-01-01'),
( 'Maria Lopez', '2030-05-12'),
( 'Carlos Sanchez', '2025-09-23'),
( 'Ana Martinez', '2026-03-17'),
( 'Luis Gomez', '2024-11-30');


UPDATE Empleados SET fecha_nacimiento = '2025-09-23 00:00:00.000' WHERE id_empleado = 1;






























------------------------------------------------ Disparadores AFTER -------------------------------------------------

-- Ejercicio 1: AFTER INSERT - Registrar Nuevos Clientes
-- Contexto: Utiliza las tablas Clientes y LogBorrado creadas anteriormente. Crea un disparador que
-- registre los nuevos clientes en la tabla LogBorrado.
-- Prueba del Disparador:
-- Resultado Esperado: El id_cliente y la fecha actual se registran en la tabla LogBorrado.


CREATE TRIGGER log_new_clients	
ON Clientes
AFTER INSERT
AS
BEGIN
	INSERT INTO LogBorrado (id_cliente) SELECT INSERTED.id_cliente FROM INSERTED;
END;

SELECT * FROM LogBorrado;
SELECT * FROM Clientes;

--Ejercicio 2: AFTER UPDATE - Registrar Cambios de Precio
--Contexto: Utiliza las tablas Productos y HistorialPrecios creadas anteriormente. Crea un disparador que
--registre los cambios de precio después de actualizar un producto.
--Resultado Esperado: El cambio de precio se registra en la tabla HistorialPrecios.

CREATE TRIGGER trg_AfterProductUpdate
ON Productos
AFTER UPDATE
AS
BEGIN
    INSERT INTO HistorialPrecios (old_price, new_price, change_date)
    SELECT 
        DELETED.price AS old_price,
        INSERTED.price AS new_price,
        GETDATE() AS change_date
    FROM 
        INSERTED
    INNER JOIN 
        DELETED ON INSERTED.id = DELETED.id
    WHERE 
        DELETED.price <> INSERTED.price;
END;


CREATE TABLE HistorialPrecios (
	id INT IDENTITY(1, 1) PRIMARY KEY,
	old_price MONEY,
	new_price MONEY,
	change_date DATETIME DEFAULT GETDATE()
);

SELECT * FROM HistorialPrecios;
SELECT * FROM Productos;

UPDATE Productos SET price = 50 WHERE id = 1;
INSERT INTO Productos (name, price) VALUES ('Jabón', 99);

--Ejercicio 3: AFTER DELETE - Registrar Ventas Eliminadas
--Contexto: Utiliza las tablas Ventas y LogBorrado creadas anteriormente. Crea un disparador que registre
--los detalles de la venta eliminada en la tabla LogBorrado después de eliminar una venta.
--Prueba del Disparador:
--Resultado Esperado: El id_venta y la fecha_venta se registran en la tabla LogBorrado.

CREATE TRIGGER registrar_ventas_eliminadas
ON Ventas
AFTER DELETE
AS 
BEGIN
	INSERT INTO LogBorrado (id_venta, fecha_venta )
	SELECT 
		id_venta,
		fecha_venta
	FROM 
		DELETED;
END;

DELETE FROM Ventas WHERE id_venta = 453;

SELECT * FROM LogBorrado;
SELECT id_venta, fecha_venta FROM LogBorrado;
SELECT * FROM Ventas;
INSERT  INTO VENTAS(id_venta, id_producto, cantidad) VALUES (453, 1, 38);
SELECT * FROM Productos;

--Ejercicio 4: AFTER INSERT - Actualizar Stock
--Contexto: Crea una tabla Inventario con las columnas id_producto, stock. 
--Utiliza la tabla Ventas creada anteriormente. 
--Crea un disparador que actualice el stock después de insertar una venta.
--Prueba del Disparador:
--Resultado Esperado: El stock del producto 1 se reduce en 10 unidades.

CREATE TABLE Inventario (
	id_producto INT,
	stock INT, 
);

SELECT * FROM Ventas;
SELECT * FROM Products;
INSERT INTO Ventas(id_producto, cantidad) VALUES (1, 1);
INSERT INTO Inventario (id_producto, stock) VALUES (1, 50);
INSERT INTO Ventas (id_producto, cantidad, fecha_venta) VALUES (1, 1, GETDATE());

CREATE TRIGGER decrease_product_inventory
ON Ventas
AFTER INSERT
AS
BEGIN
	UPDATE Inventario
	SET Inventario.stock = Inventario.stock - 10
	FROM Inventario
	INNER JOIN INSERTED ON Inventario.id_producto = INSERTED.id_producto
END;

SELECT * FROM Inventario;

--Ejercicio 5: AFTER UPDATE - Registrar Cambios de Empleados
--Contexto: Utiliza la tabla Empleados creada anteriormente. Crea una tabla HistorialEmpleados para
--registrar cambios de departamentos. Crea un disparador que registre los cambios de departamento
--después de actualizar un empleado.
--Prueba del Disparador:
--Resultado Esperado: El cambio de departamento se registra en la tabla HistorialEmpleados.

CREATE TABLE Departamento (
	id INT IDENTITY(1, 1) PRIMARY KEY,
	name VARCHAR(40)
);

CREATE TABLE HistorialEmpleados(
	id INT IDENTITY(1, 1) PRIMARY KEY,
	id_empleado INT,
	old_department_id INT,
	new_department_id INT
);

SELECT * FROM Empleados;
SELECT * FROM Departamento;
SELECT * FROM HistorialEmpleados;

CREATE TRIGGER register_department_change
ON Empleados
AFTER UPDATE
AS
BEGIN
	INSERT INTO HistorialEmpleados(id_empleado, old_department_id, new_department_id)
	SELECT DELETED.id, DELETED.id_department, INSERTED.id_department
	FROM DELETED
	INNER JOIN INSERTED ON INSERTED.id = DELETED.id;
END;

--DROP TRIGGER register_department_change;

INSERT INTO Departamento (name) VALUES ('Legal');
INSERT INTO Departamento (name) VALUES ('Administrativo');
SELECT * FROM Departamento ;

INSERT INTO Empleados (name, id_department, last_name) VALUES ('Juan', 1, 'Perez');
SELECT * FROM Empleados;

UPDATE Empleados
SET id_department = 777
WHERE id = 1;




------------------------------------------Disparadores ROW LEVEL-----------------------------------------



--Ejercicio 1: BEFORE INSERT ROW LEVEL - Convertir Correos Electrónicos a Minúsculas
--Contexto: Utiliza la tabla Clientes creada anteriormente. Crea un disparador que convierta los correos
--electrónicos a minúsculas antes de insertarlos en la tabla.
--Prueba del Disparador:
--Resultado Esperado: El email se inserta en minúsculas (luis.martinez@mail.com).




------------------------------------------ STATEMENT LEVEL  -----------------------------------------------


CREATE TABLE Acciones (
    id_accion INT,
    descripcion VARCHAR(255),
    fecha_accion DATETIME
);

CREATE TABLE Clientes (
    id_cliente INT,
    nombre VARCHAR(255),
    email VARCHAR(255)
);
GO
CREATE TABLE Acciones (
    id_accion INT,
    descripcion VARCHAR(255),
    fecha_accion DATETIME
);
GO

CREATE TABLE Productos (
    id_producto INT,
    nombre VARCHAR(255),
    precio DECIMAL(10, 2) 
);
GO

--Ejercicio 1: BEFORE INSERT STATEMENT LEVEL 
--Registrar AcciónContexto: Crea una tabla Acciones con las columnas id_accion, descripcion, y fecha_accion. 
--Crea un disparador que registre una acción antes de insertar registros en la tabla Clientes.
--Prueba del Disparador:
--Resultado Esperado: Se registra la acción de insertar nuevos clientes en la tabla Acciones.

CREATE TRIGGER before_insert_clientes
ON Clientes
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO Acciones (descripcion, fecha_accion)
    VALUES ('Se va a insertar un nuevo cliente', GETDATE());

    INSERT INTO Clientes (nombre, email)
    SELECT nombre, email
    FROM inserted;
END;
GO

INSERT INTO Clientes (nombre, email)
VALUES ('Juan Perez', 'juan.perez@example.com');

INSERT INTO Clientes (nombre, email)
VALUES ('Maria Lopez', 'maria.lopez@example.com');

INSERT INTO Clientes (nombre, email)
VALUES ('Carlos Gonzalez', 'carlos.gonzalez@example.com');

INSERT INTO Clientes (nombre, email)
VALUES ('Ana Martinez', 'ana.martinez@example.com');

INSERT INTO Clientes (nombre, email)
VALUES ('Luis Fernandez', 'luis.fernandez@example.com');
GO

SELECT * FROM Acciones;
GO

--Ejercicio 2: AFTER UPDATE STATEMENT LEVEL 
--Registrar AcciónContexto: Utiliza las tablas Productos y Acciones creadas anteriormente.
--Crea un disparador que registre una acción después de actualizar precios en la tabla Productos.
--Prueba del Disparador:
--Resultado Esperado: Se registra la acción de actualizar precios en la tabla Acciones.

CREATE TRIGGER after_update_precios
ON Productos
AFTER UPDATE
AS
BEGIN
    IF UPDATE(precio)
    BEGIN
        INSERT INTO Acciones (descripcion, fecha_accion)
        VALUES ('Se ha actualizado el precio de un producto', GETDATE());
    END
END;
GO

INSERT INTO Productos (nombre, precio)
VALUES ('Producto A', 10.00),
       ('Producto B', 20.00),
       ('Producto C', 30.00);
GO

UPDATE Productos
SET precio = precio * 1.1;  
GO

SELECT * FROM Acciones;
GO


--Ejercicio 3: AFTER DELETE STATEMENT LEVEL - Registrar Acción
--Contexto: Utiliza las tablas Ventas y Acciones creadas anteriormente. Crea un disparador que registre
--una acción después de eliminar registros en la tabla Ventas.
--Prueba del Disparador:
--Resultado Esperado: Se registra la acción de eliminar registros de ventas en la tabla Acciones.




CREATE TRIGGER registrar_accion
ON VENTAS 
AFTER DELETE
AS
BEGIN
	INSERT INTO Acciones ( descripcion, fecha_accion ) VALUES ('Nueva venta', GETDATE());
END;

INSERT INTO Ventas (id_producto, cantidad, fecha_venta) VALUES (1, 10, GETDATE());

DELETE FROM Ventas WHERE id_venta = 2;

SELECT * FROM Ventas v ;
SELECT * FROM Acciones;




--Ejercicio 4: BEFORE INSERT ROW LEVEL - Validar Teléfono
--Contexto: Utiliza la tabla Usuarios creada anteriormente. Crea un disparador que valide el número de
--teléfono antes de insertarlo en la tabla.
--Prueba del Disparador:
--Resultado Esperado: El primer INSERT se completa con éxito, el segundo INSERT falla con el mensaje
--'El teléfono debe tener 10 dígitos'.

DROP TRIGGER validar_telefono;

CREATE TRIGGER row_level_validar_telefono
ON Usuarios
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @TelefonoLength INT;
    DECLARE @Telefono VARCHAR(15);

    SELECT @Telefono = telefono FROM inserted;
    SELECT @TelefonoLength = LEN(@Telefono);

    IF @TelefonoLength < 10
    BEGIN
        RAISERROR('El tel�fono debe tener al menos 10 d�gitos', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

SELECT * FROM Usuarios;

INSERT INTO Usuarios (nombre, telefono) VALUES ('USUARIO2', 838)

--Ejercicio 5: BEFORE UPDATE ROW LEVEL - Validar Fecha de Nacimiento
--Contexto: Utiliza la tabla Empleados creada anteriormente. Crea un disparador que valide la fecha de
--nacimiento antes de actualizarla en la tabla.
--Prueba del Disparador:
--Resultado Esperado: La actualización falla con el mensaje 'La fecha de nacimiento no puede ser futura'.

SELECT * FROM Empleados;

DROP TRIGGER trigger_before_update_validar_fecha_nacimiento;

CREATE TRIGGER trigger_row_level_before_update_validar_fecha_nacimiento
ON Empleados
INSTEAD OF UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE fecha_nacimiento > GETDATE())
    BEGIN
        RAISERROR('La fecha de nacimiento no puede ser futura', 16, 1);
        RETURN;
    END

    UPDATE Empleados
    SET nombre = inserted.nombre,
        fecha_nacimiento = inserted.fecha_nacimiento
    FROM inserted
    WHERE Empleados.id_empleado = inserted.id_empleado;
END;

UPDATE Empleados SET fecha_nacimiento = '2026-03-17 00:00:00.000' WHERE id_empleado = 1;



































































