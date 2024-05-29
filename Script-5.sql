-- SETUP --

CREATE DATABASE ACTIVIDAD5
GO

USE ACTIVIDAD5
GO

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


GO

INSERT INTO Clientes (id_cliente, nombre, apellido, email) VALUES
(1, 'Juan', 'Perez', 'JUAN.PEREZ@EXAMPLE.COM'),
(2, 'Ana', 'Gomez', 'ANA.GOMEZ@EXAMPLE.COM'),
(3, 'Luis', 'Martinez', 'LUIS.MARTINEZ@EXAMPLE.COM'),
(4, 'Maria', 'Lopez', 'MARIA.LOPEZ@EXAMPLE.COM'),
(5, 'Carlos', 'Hernandez', 'CARLOS.HERNANDEZ@EXAMPLE.COM');
GO

INSERT INTO Clientes (nombre, apellido, email) VALUES
('PEPE', 'PEPEREZ', 'PEPEPEPEREZ@GMAIL.COM');

-- Disparadores BEFORE

-- Ejercicio 1: BEFORE INSERT - Convertir Correos Electrónicos a Minúsculas
-- Contexto: Crea una tabla Clientes con las columnas id_cliente, nombre, apellido, y email.
-- Prueba del Disparador:
-- Resultado Esperado: El email se inserta en minúsculas (juan.perez@mail.com).

CREATE TRIGGER trg_BeforeInsertClientes
ON Clientes
AFTER INSERT
AS
BEGIN
    UPDATE Clientes
    SET email = LOWER(i.email)
    FROM Clientes c
    INNER JOIN inserted i ON c.id_cliente = i.id_cliente;
END;

SELECT * FROM Clientes;

-- Disparadores AFTER 

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

CREATE TABLE Productos (
	id INT IDENTITY(1, 1) PRIMARY KEY,
	name VARCHAR(40),
	price MONEY,
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































































































