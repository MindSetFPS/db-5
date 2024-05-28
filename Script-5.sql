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
    id_venta INT PRIMARY KEY,
    id_producto INT,
    cantidad INT,
    fecha_venta DATETIME
);

CREATE TABLE LogBorrado (
    id_log INT IDENTITY(1, 1) PRIMARY KEY,
    id_venta INT,
    id_cliente INT,
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
























































































































