
-- Eliminar la base de datos si ya existe
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'Bodega')
BEGIN
    USE master
    ALTER DATABASE Bodega SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE Bodega
    PRINT 'Base de datos Bodega eliminada'
END
GO

-- Crear la base de datos Bodega
CREATE DATABASE Bodega
GO

PRINT 'Base de datos Bodega creada exitosamente'
GO

-- Usar la base de datos Bodega
USE Bodega
GO

-- Crear tabla PRODUCTO
CREATE TABLE PRODUCTO
(
    idprod CHAR(7) PRIMARY KEY,
    descripcion VARCHAR(25),
    existencias INT, --cantidad de producto existentes
    precio DECIMAL(10,2) NOT NULL, --precio costo
    preciov DECIMAL(10,2) NOT NULL, --precio venta
    ganancia AS preciov - precio, --campo calculado para calcular la ganancia
    CHECK(preciov > precio) --precio venta tiene que ser mayor al precio de compra
)
GO

PRINT 'Tabla PRODUCTO creada exitosamente'
GO

-- Crear tabla PEDIDO
CREATE TABLE PEDIDO
(
    idpedido CHAR(7),
    idprod CHAR(7),
    cantidad INT, --cantidad de unidades vendidas del producto en el pedido
    FOREIGN KEY(idprod) REFERENCES PRODUCTO(idprod)
)
GO

PRINT 'Tabla PEDIDO creada exitosamente'
GO

-- Mostrar las tablas creadas
SELECT 
    TABLE_NAME AS 'Tablas Creadas en Bodega'
FROM 
    INFORMATION_SCHEMA.TABLES
WHERE 
    TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME

GO

INSERT INTO PRODUCTO (idprod, descripcion, existencias, precio, preciov)
VALUES
('P0001', 'Manzanas', 50, 1.50, 2.00),
('P0002', 'Peras', 30, 1.00, 1.80);


