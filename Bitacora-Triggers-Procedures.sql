-- =============================================
-- PARTE: PROCEDIMIENTOS, TRIGGERS Y BITÁCORA
-- Base de Datos: Bodega
-- Motor: SQL Server
-- =============================================

-- Crear tabla BITACORA
CREATE TABLE BITACORA (
    id INT IDENTITY(1,1) PRIMARY KEY,
    accion VARCHAR(50),
    fecha DATETIME,
    usuario VARCHAR(100)
);
GO

-- =============================================
-- TRIGGERS PARA BITÁCORA
-- =============================================

-- Trigger para bitácora en INSERCIONES
CREATE TRIGGER tr_bitacora_productos
ON PRODUCTO
AFTER INSERT
AS
BEGIN
    INSERT INTO BITACORA (accion, fecha, usuario)
    SELECT 'INSERCIÓN', GETDATE(), SYSTEM_USER
    FROM inserted;
END;
GO

-- Trigger para bitácora en ACTUALIZACIONES
CREATE TRIGGER tr_bitacora_productos_update
ON PRODUCTO
AFTER UPDATE
AS
BEGIN
    INSERT INTO BITACORA (accion, fecha, usuario)
    SELECT 'ACTUALIZACIÓN', GETDATE(), SYSTEM_USER
    FROM inserted;
END;
GO

-- Trigger para bitácora en ELIMINACIONES
CREATE TRIGGER tr_bitacora_productos_delete
ON PRODUCTO
AFTER DELETE
AS
BEGIN
    INSERT INTO BITACORA (accion, fecha, usuario)
    SELECT 'ELIMINACIÓN', GETDATE(), SYSTEM_USER
    FROM deleted;
END;
GO

-- =============================================
-- PROCEDIMIENTOS ALMACENADOS
-- =============================================

-- Procedimiento para insertar productos
CREATE PROCEDURE sp_insertar_producto
    @p_idprod CHAR(7),
    @p_descripcion VARCHAR(25),
    @p_existencias INT,
    @p_precio DECIMAL(10,2),
    @p_preciov DECIMAL(10,2)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM PRODUCTO WHERE idprod = @p_idprod OR descripcion = @p_descripcion)
    BEGIN
        SELECT 'ESTE PRODUCTO YA HA SIDO INGRESADO' AS mensaje;
    END
    ELSE
    BEGIN
        INSERT INTO PRODUCTO (idprod, descripcion, existencias, precio, preciov)
        VALUES (@p_idprod, @p_descripcion, @p_existencias, @p_precio, @p_preciov);
        
        SELECT 'PRODUCTO INSERTADO CORRECTAMENTE' AS mensaje;
    END
END;
GO

-- Procedimiento para realizar pedidos
CREATE PROCEDURE sp_realizar_pedido
    @p_idpedido CHAR(7),
    @p_idprod CHAR(7),
    @p_cantidad INT,
    @p_usuario VARCHAR(100)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM PRODUCTO WHERE idprod = @p_idprod)
    BEGIN
        SELECT 'ESTE PRODUCTO NO EXISTE' AS mensaje;
    END
    ELSE
    BEGIN
        DECLARE @v_existencias INT;
        SELECT @v_existencias = existencias FROM PRODUCTO WHERE idprod = @p_idprod;
        
        IF @p_cantidad > @v_existencias
        BEGIN
            SELECT 'EXISTENCIA DEL PRODUCTO INSUFICIENTE' AS mensaje;
        END
        ELSE
        BEGIN
            INSERT INTO PEDIDO (idpedido, idprod, cantidad)
            VALUES (@p_idpedido, @p_idprod, @p_cantidad);
            
            UPDATE PRODUCTO 
            SET existencias = existencias - @p_cantidad 
            WHERE idprod = @p_idprod;
            
            SELECT 'PEDIDO REALIZADO EXITOSAMENTE' AS mensaje;
        END
    END
END;
GO

-- =============================================
-- MENSAJE DE CONFIRMACIÓN
-- =============================================
PRINT '=============================================';
PRINT 'PARTE COMPLETADA EXITOSAMENTE';
PRINT '- Tabla BITACORA creada';
PRINT '- 3 Triggers de bitácora creados';
PRINT '- 2 Procedimientos almacenados creados';
PRINT '=============================================';
GO

--Datos de prueba

-- Continuando desde P0003
EXEC sp_insertar_producto 'P0003', 'Uvas', 25, 2.00, 4.50;
EXEC sp_insertar_producto 'P0004', 'Zanahorias', 40, 0.80, 1.80;
EXEC sp_insertar_producto 'P0005', 'Tomates', 35, 1.20, 2.50;
EXEC sp_insertar_producto 'P0006', 'Cebollas', 45, 0.90, 1.90;
---
-- Pedidos con formato similar
EXEC sp_realizar_pedido 'PD0001', 'P0001', 10, 'cliente_restaurante';
EXEC sp_realizar_pedido 'PD0002', 'P0003', 8, 'cliente_mercado';
EXEC sp_realizar_pedido 'PD0003', 'P0004', 15, 'cliente_hotel';

--Pruebas erroneas aproposito
-- Probar validaciones
PRINT '4. Probando validaciones...';
EXEC sp_insertar_producto 'P0001', 'Manzanas Verdes', 10, 1.20, 2.00; -- Debe fallar
EXEC sp_realizar_pedido 'PD0008', 'P0012', 20, 'cliente_exportador'; -- Debe fallar



