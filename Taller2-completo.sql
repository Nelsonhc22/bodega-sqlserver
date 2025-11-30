------------------------------------------------------------
-- TALLER 2: PROCEDIMIENTOS, TRIGGERS Y CONSULTAS
-- Base de Datos: TiendaGrupo
-- Fecha: Noviembre 2025
------------------------------------------------------------

USE TiendaGrupo;
GO

PRINT '=========================================='
PRINT 'TALLER 2: INICIANDO EJECUCIÓN'
PRINT '=========================================='
GO

------------------------------------------------------------
-- PASO 1: CREAR TABLA BITACORA
------------------------------------------------------------

CREATE TABLE dbo.BITACORA (
    IdAuditoria INT IDENTITY(1,1) PRIMARY KEY,
    Accion VARCHAR(50),
    FechaAccion DATETIME DEFAULT GETDATE(),
    Usuario VARCHAR(100) DEFAULT SYSTEM_USER,
    NombreProducto NVARCHAR(150)
);
GO

PRINT '✓ Tabla BITACORA creada'
GO

------------------------------------------------------------
-- PASO 2: CREAR PROCEDIMIENTO - INSERTAR PRODUCTO
------------------------------------------------------------

CREATE PROCEDURE dbo.sp_InsertarProducto
    @p_Nombre NVARCHAR(150),
    @p_IdCategoria INT,
    @p_Precio DECIMAL(10,2),
    @p_Stock INT
AS
BEGIN
    -- Validar que no exista producto duplicado
    IF EXISTS (SELECT 1 FROM dbo.Productos WHERE Nombre = @p_Nombre AND Activo = 1)
    BEGIN
        SELECT 'ESTE PRODUCTO YA HA SIDO INGRESADO' AS Mensaje;
        RETURN;
    END

    -- Validar que exista la categoría
    IF NOT EXISTS (SELECT 1 FROM dbo.Categorias WHERE IdCategoria = @p_IdCategoria AND Activo = 1)
    BEGIN
        SELECT 'LA CATEGORÍA NO EXISTE' AS Mensaje;
        RETURN;
    END

    -- Validar precio
    IF @p_Precio <= 0
    BEGIN
        SELECT 'EL PRECIO DEBE SER MAYOR A CERO' AS Mensaje;
        RETURN;
    END

    -- Insertar producto
    INSERT INTO dbo.Productos (Nombre, IdCategoria, Precio, Stock, Activo, FechaCreacion)
    VALUES (@p_Nombre, @p_IdCategoria, @p_Precio, @p_Stock, 1, SYSUTCDATETIME());

    SELECT 'PRODUCTO INSERTADO CORRECTAMENTE' AS Mensaje;
END;
GO

PRINT '✓ Procedimiento sp_InsertarProducto creado'
GO

------------------------------------------------------------
-- PASO 3: CREAR PROCEDIMIENTO - REALIZAR PEDIDO
------------------------------------------------------------

CREATE PROCEDURE dbo.sp_RealizarPedido
    @p_IdCliente INT,
    @p_IdProducto INT,
    @p_Cantidad INT
AS
BEGIN
    -- Validar que exista el producto
    IF NOT EXISTS (SELECT 1 FROM dbo.Productos WHERE IdProducto = @p_IdProducto AND Activo = 1)
    BEGIN
        SELECT 'ESTE PRODUCTO NO EXISTE' AS Mensaje;
        RETURN;
    END

    -- Validar que exista el cliente
    IF NOT EXISTS (SELECT 1 FROM dbo.Clientes WHERE IdCliente = @p_IdCliente AND Activo = 1)
    BEGIN
        SELECT 'ESTE CLIENTE NO EXISTE' AS Mensaje;
        RETURN;
    END

    -- Obtener stock disponible
    DECLARE @v_Stock INT;
    SELECT @v_Stock = Stock FROM dbo.Productos WHERE IdProducto = @p_IdProducto;

    -- Validar cantidad
    IF @p_Cantidad <= 0
    BEGIN
        SELECT 'LA CANTIDAD DEBE SER MAYOR A CERO' AS Mensaje;
        RETURN;
    END

    -- Validar stock
    IF @p_Cantidad > @v_Stock
    BEGIN
        SELECT 'EXISTENCIA DEL PRODUCTO INSUFICIENTE' AS Mensaje;
        RETURN;
    END

    -- Crear pedido
    INSERT INTO dbo.Pedidos (IdCliente, FechaPedido, Total)
    VALUES (@p_IdCliente, SYSUTCDATETIME(), 0);

    DECLARE @v_IdPedido INT = SCOPE_IDENTITY();
    DECLARE @v_Precio DECIMAL(10,2);
    
    SELECT @v_Precio = Precio FROM dbo.Productos WHERE IdProducto = @p_IdProducto;

    -- Insertar detalle del pedido
    INSERT INTO dbo.DetallePedidos (IdPedido, IdProducto, Cantidad, PrecioUnitario)
    VALUES (@v_IdPedido, @p_IdProducto, @p_Cantidad, @v_Precio);

    -- Actualizar total del pedido
    UPDATE dbo.Pedidos
    SET Total = (
        SELECT SUM(Cantidad * PrecioUnitario)
        FROM dbo.DetallePedidos
        WHERE IdPedido = @v_IdPedido
    )
    WHERE IdPedido = @v_IdPedido;

    -- Actualizar stock
    UPDATE dbo.Productos
    SET Stock = Stock - @p_Cantidad
    WHERE IdProducto = @p_IdProducto;

    SELECT 'PEDIDO REALIZADO EXITOSAMENTE' AS Mensaje;
END;
GO

PRINT '✓ Procedimiento sp_RealizarPedido creado'
GO

------------------------------------------------------------
-- PASO 4: CREAR TRIGGERS DE AUDITORÍA
------------------------------------------------------------

CREATE TRIGGER dbo.tr_Auditoria_Insert
ON dbo.Productos
AFTER INSERT
AS
BEGIN
    INSERT INTO dbo.BITACORA (Accion, FechaAccion, Usuario, NombreProducto)
    SELECT 'INSERTAR', GETDATE(), SYSTEM_USER, i.Nombre
    FROM inserted i;
END;
GO

CREATE TRIGGER dbo.tr_Auditoria_Update
ON dbo.Productos
AFTER UPDATE
AS
BEGIN
    INSERT INTO dbo.BITACORA (Accion, FechaAccion, Usuario, NombreProducto)
    SELECT 'ACTUALIZAR', GETDATE(), SYSTEM_USER, i.Nombre
    FROM inserted i;
END;
GO

CREATE TRIGGER dbo.tr_Auditoria_Delete
ON dbo.Productos
AFTER DELETE
AS
BEGIN
    INSERT INTO dbo.BITACORA (Accion, FechaAccion, Usuario, NombreProducto)
    SELECT 'ELIMINAR', GETDATE(), SYSTEM_USER, d.Nombre
    FROM deleted d;
END;
GO

PRINT '✓ Triggers de auditoría creados'
GO

------------------------------------------------------------
-- PASO 5: CONSULTAS ANALÍTICAS
------------------------------------------------------------

PRINT ' '
PRINT 'PRODUCTOS POR CATEGORÍA:'
SELECT 
    c.Nombre AS Categoria,
    COUNT(p.IdProducto) AS TotalProductos,
    SUM(p.Stock) AS StockTotal
FROM dbo.Categorias c
LEFT JOIN dbo.Productos p ON c.IdCategoria = p.IdCategoria
WHERE c.Activo = 1
GROUP BY c.Nombre
ORDER BY TotalProductos DESC;
GO

PRINT ' '
PRINT 'DETALLES DE VENTAS:'
SELECT 
    cl.NombreCompleto AS Cliente,
    prod.Nombre AS Producto,
    dp.Cantidad,
    dp.PrecioUnitario
FROM dbo.Pedidos ped
INNER JOIN dbo.Clientes cl ON ped.IdCliente = cl.IdCliente
INNER JOIN dbo.DetallePedidos dp ON ped.IdPedido = dp.IdPedido
INNER JOIN dbo.Productos prod ON dp.IdProducto = prod.IdProducto
ORDER BY ped.FechaPedido DESC;
GO

PRINT ' '
PRINT 'HISTORIAL DE AUDITORÍA:'
SELECT 
    IdAuditoria,
    Accion,
    FechaAccion,
    Usuario,
    NombreProducto
FROM dbo.BITACORA
ORDER BY FechaAccion DESC;
GO

------------------------------------------------------------
-- CONFIRMACIÓN FINAL
------------------------------------------------------------

PRINT ' '
PRINT '=========================================='
PRINT '✓ TALLER 2 COMPLETADO EXITOSAMENTE'
PRINT '=========================================='
GO
