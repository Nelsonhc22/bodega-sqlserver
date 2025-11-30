*/

------------------------------------------------------------
-- PASO 0: VERIFICACIÓN PREVIA (EJECUTAR PRIMERO)
------------------------------------------------------------

/*
Antes de empezar, verificar el Taller 1 completo.
*/

USE master;
GO

-- Verificar que la BD TiendaGrupo existe
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'TiendaGrupo')
    PRINT '✓ Base de datos TiendaGrupo existe'
ELSE
BEGIN
    PRINT '❌ ERROR: No existe la BD TiendaGrupo'
    PRINT 'Debes completar el Taller 1 primero'
    PRINT 'Repositorio Taller 1: [inserta tu link]'
END
GO

-- Si todo está bien:

-- PASO 1: CAMBIAR A LA BASE DE DATOS TIENDAGRUPO

USE TiendaGrupo;
GO

PRINT 'TALLER 2: INICIANDO EJECUCIÓN'
PRINT ' '
GO

-- Verificar que las tablas del Taller 1 existen
PRINT 'Verificando tablas del Taller 1...'
GO

SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE' 
ORDER BY TABLE_NAME;
GO



-- PASO 2: CREAR TABLA BITACORA (AUDITORÍA)

PRINT 'PASO 2: CREAR TABLA BITACORA'
GO

-- Verificar si ya existe (para no duplicarla)
IF OBJECT_ID('dbo.BITACORA', 'U') IS NOT NULL
BEGIN
    PRINT 'Tabla BITACORA ya existe. Eliminando...'
    DROP TABLE dbo.BITACORA;
    PRINT 'Tabla antigua eliminada'
END
GO

-- Crear tabla BITACORA
CREATE TABLE dbo.BITACORA (
    IdAuditoria     INT IDENTITY(1,1) PRIMARY KEY,
    Accion          VARCHAR(50) NOT NULL,           -- INSERTAR, ACTUALIZAR, ELIMINAR
    FechaAccion     DATETIME NOT NULL DEFAULT GETDATE(),
    Usuario         VARCHAR(100) NOT NULL DEFAULT SYSTEM_USER,
    NombreProducto  NVARCHAR(150) NULL,
    Producto        NVARCHAR(150) NULL
);
GO

PRINT 'Tabla BITACORA creada exitosamente'
PRINT ' '
GO

-- PASO 3: CREAR PROCEDIMIENTO 1 - INSERTAR PRODUCTO

PRINT 'PASO 3: CREAR PROCEDIMIENTO sp_InsertarProducto'
GO

-- Eliminar si existe
IF OBJECT_ID('dbo.sp_InsertarProducto', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_InsertarProducto;
GO

-- Crear procedimiento
CREATE PROCEDURE dbo.sp_InsertarProducto
    @p_Nombre NVARCHAR(150),
    @p_IdCategoria INT,
    @p_Precio DECIMAL(10,2),
    @p_Stock INT
AS
BEGIN
    BEGIN TRY
        -- Validación 1: Verificar si el nombre del producto ya existe
        IF EXISTS (SELECT 1 FROM dbo.Productos WHERE Nombre = @p_Nombre AND Activo = 1)
        BEGIN
            SELECT 'ESTE PRODUCTO YA HA SIDO INGRESADO' AS Mensaje;
            RETURN;
        END

        -- Validación 2: Verificar si la categoría existe
        IF NOT EXISTS (SELECT 1 FROM dbo.Categorias WHERE IdCategoria = @p_IdCategoria AND Activo = 1)
        BEGIN
            SELECT 'LA CATEGORÍA ESPECIFICADA NO EXISTE' AS Mensaje;
            RETURN;
        END

        -- Validación 3: Precio debe ser positivo
        IF @p_Precio <= 0
        BEGIN
            SELECT 'EL PRECIO DEBE SER MAYOR A CERO' AS Mensaje;
            RETURN;
        END

        -- Validación 4: Stock no puede ser negativo
        IF @p_Stock < 0
        BEGIN
            SELECT 'EL STOCK NO PUEDE SER NEGATIVO' AS Mensaje;
            RETURN;
        END

        -- Insertar el producto
        INSERT INTO dbo.Productos (Nombre, IdCategoria, Precio, Stock, Activo, FechaCreacion)
        VALUES (@p_Nombre, @p_IdCategoria, @p_Precio, @p_Stock, 1, SYSUTCDATETIME());

        SELECT 'PRODUCTO INSERTADO CORRECTAMENTE' AS Mensaje;

    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS Mensaje;
    END CATCH
END;
GO

PRINT '✓ Procedimiento sp_InsertarProducto creado exitosamente'
PRINT ' '
GO

-- PASO 4: CREAR PROCEDIMIENTO 2 - REALIZAR PEDIDO

PRINT 'PASO 4: CREAR PROCEDIMIENTO sp_RealizarPedido'
GO

-- Eliminar si existe
IF OBJECT_ID('dbo.sp_RealizarPedido', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_RealizarPedido;
GO

-- Crear procedimiento
CREATE PROCEDURE dbo.sp_RealizarPedido
    @p_IdCliente INT,
    @p_IdProducto INT,
    @p_Cantidad INT
AS
BEGIN
    BEGIN TRY
        -- Validación 1: Verificar que el producto existe
        IF NOT EXISTS (SELECT 1 FROM dbo.Productos WHERE IdProducto = @p_IdProducto AND Activo = 1)
        BEGIN
            SELECT 'ESTE PRODUCTO NO EXISTE' AS Mensaje;
            RETURN;
        END

        -- Validación 2: Verificar que el cliente existe
        IF NOT EXISTS (SELECT 1 FROM dbo.Clientes WHERE IdCliente = @p_IdCliente AND Activo = 1)
        BEGIN
            SELECT 'ESTE CLIENTE NO EXISTE' AS Mensaje;
            RETURN;
        END

        -- Obtener cantidad en stock del producto
        DECLARE @v_Stock INT;
        SELECT @v_Stock = Stock FROM dbo.Productos WHERE IdProducto = @p_IdProducto;

        -- Validación 3: Verificar cantidad solicitada
        IF @p_Cantidad <= 0
        BEGIN
            SELECT 'LA CANTIDAD A PEDIR DEBE SER MAYOR A CERO' AS Mensaje;
            RETURN;
        END

        -- Validación 4: Verificar suficiencia de stock
        IF @p_Cantidad > @v_Stock
        BEGIN
            SELECT 'EXISTENCIA DEL PRODUCTO INSUFICIENTE. Stock disponible: ' + CAST(@v_Stock AS VARCHAR) AS Mensaje;
            RETURN;
        END

        -- Crear el pedido
        INSERT INTO dbo.Pedidos (IdCliente, FechaPedido, Total)
        VALUES (@p_IdCliente, SYSUTCDATETIME(), 0);

        DECLARE @v_IdPedido INT = SCOPE_IDENTITY();
        DECLARE @v_Precio DECIMAL(10,2);
        
        -- Obtener precio del producto
        SELECT @v_Precio = Precio FROM dbo.Productos WHERE IdProducto = @p_IdProducto;

        -- Insertar detalle del pedido
        INSERT INTO dbo.DetallePedidos (IdPedido, IdProducto, Cantidad, PrecioUnitario)
        VALUES (@v_IdPedido, @p_IdProducto, @p_Cantidad, @v_Precio);

        -- Actualizar el total del pedido
        UPDATE dbo.Pedidos
        SET Total = (
            SELECT SUM(Cantidad * PrecioUnitario)
            FROM dbo.DetallePedidos
            WHERE IdPedido = @v_IdPedido
        )
        WHERE IdPedido = @v_IdPedido;

        -- Actualizar stock del producto (restar cantidad vendida)
        UPDATE dbo.Productos
        SET Stock = Stock - @p_Cantidad
        WHERE IdProducto = @p_IdProducto;

        SELECT 'PEDIDO REALIZADO EXITOSAMENTE. ID Pedido: ' + CAST(@v_IdPedido AS VARCHAR) AS Mensaje;

    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS Mensaje;
    END CATCH
END;
GO

PRINT 'Procedimiento sp_RealizarPedido creado exitosamente'
PRINT ' '
GO

-- PASO 5: CREAR TRIGGERS (AUDITORÍA AUTOMÁTICA)

PRINT 'PASO 5: CREAR TRIGGERS DE AUDITORÍA'
GO

-- TRIGGER 1: INSERCIONES
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'tr_Auditoria_Productos_Insert')
    DROP TRIGGER dbo.tr_Auditoria_Productos_Insert;
GO

CREATE TRIGGER dbo.tr_Auditoria_Productos_Insert
ON dbo.Productos
AFTER INSERT
AS
BEGIN
    INSERT INTO dbo.BITACORA (Accion, FechaAccion, Usuario, NombreProducto)
    SELECT 'INSERTAR', GETDATE(), SYSTEM_USER, i.Nombre
    FROM inserted i;
END;
GO

PRINT 'Trigger para INSERCIONES creado'
GO

-- TRIGGER 2: ACTUALIZACIONES
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'tr_Auditoria_Productos_Update')
    DROP TRIGGER dbo.tr_Auditoria_Productos_Update;
GO

CREATE TRIGGER dbo.tr_Auditoria_Productos_Update
ON dbo.Productos
AFTER UPDATE
AS
BEGIN
    INSERT INTO dbo.BITACORA (Accion, FechaAccion, Usuario, NombreProducto)
    SELECT 'ACTUALIZAR', GETDATE(), SYSTEM_USER, i.Nombre
    FROM inserted i;
END;
GO

PRINT 'Trigger para ACTUALIZACIONES creado'
GO

-- TRIGGER 3: ELIMINACIONES
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'tr_Auditoria_Productos_Delete')
    DROP TRIGGER dbo.tr_Auditoria_Productos_Delete;
GO

CREATE TRIGGER dbo.tr_Auditoria_Productos_Delete
ON dbo.Productos
AFTER DELETE
AS
BEGIN
    INSERT INTO dbo.BITACORA (Accion, FechaAccion, Usuario, NombreProducto)
    SELECT 'ELIMINAR', GETDATE(), SYSTEM_USER, d.Nombre
    FROM deleted d;
END;
GO

PRINT 'Trigger para ELIMINACIONES creado'
PRINT ' '
GO

-- PASO 6: CREAR CONSULTAS ANALÍTICAS (VISTAS/REPORTES)

PRINT 'PASO 6: CONSULTAS ANALÍTICAS'
GO

-- CONSULTA 1: Cantidad de productos por categoría
PRINT ' '
PRINT '1. PRODUCTOS POR CATEGORÍA'

SELECT 
    c.Nombre AS NombreCategoria,
    COUNT(p.IdProducto) AS CantidadProductos,
    ROUND(AVG(p.Precio), 2) AS PrecioPromedio,
    SUM(p.Stock) AS StockTotal
FROM dbo.Categorias c
LEFT JOIN dbo.Productos p ON c.IdCategoria = p.IdCategoria AND p.Activo = 1
WHERE c.Activo = 1
GROUP BY c.IdCategoria, c.Nombre
ORDER BY CantidadProductos DESC;
GO

-- CONSULTA 2: Detalles de ventas
PRINT ' '
PRINT '2. DETALLES DE VENTAS'

SELECT 
    cl.NombreCompleto AS Cliente,
    ped.FechaPedido,
    prod.Nombre AS Producto,
    dp.Cantidad,
    dp.PrecioUnitario,
    (dp.Cantidad * dp.PrecioUnitario) AS Subtotal
FROM dbo.Pedidos ped
INNER JOIN dbo.Clientes cl ON ped.IdCliente = cl.IdCliente
INNER JOIN dbo.DetallePedidos dp ON ped.IdPedido = dp.IdPedido
INNER JOIN dbo.Productos prod ON dp.IdProducto = prod.IdProducto
ORDER BY ped.FechaPedido DESC;
GO

-- CONSULTA 3: Vendedores con ventas mayores a 100,000
PRINT ' '
PRINT '3. VENDEDORES CON VENTAS > 100,000'

SELECT 
    cl.NombreCompleto AS Vendedor,
    cl.Ciudad,
    COUNT(ped.IdPedido) AS TotalPedidos,
    ROUND(SUM(ped.Total), 2) AS VentaTotal
FROM dbo.Pedidos ped
INNER JOIN dbo.Clientes cl ON ped.IdCliente = cl.IdCliente
GROUP BY cl.IdCliente, cl.NombreCompleto, cl.Ciudad
HAVING SUM(ped.Total) > 100000
ORDER BY VentaTotal DESC;
GO

-- CONSULTA 4: Productos con bajo stock
PRINT ' '
PRINT '4. PRODUCTOS CON BAJO STOCK'

SELECT 
    prod.IdProducto,
    prod.Nombre AS NombreProducto,
    cat.Nombre AS Categoria,
    prod.Stock,
    prod.Precio,
    CASE 
        WHEN prod.Stock = 0 THEN 'SIN STOCK'
        WHEN prod.Stock <= 20 THEN 'STOCK BAJO'
        WHEN prod.Stock <= 50 THEN 'STOCK MODERADO'
        ELSE 'STOCK SUFICIENTE'
    END AS EstadoStock
FROM dbo.Productos prod
INNER JOIN dbo.Categorias cat ON prod.IdCategoria = cat.IdCategoria
WHERE prod.Activo = 1
ORDER BY prod.Stock ASC;
GO

-- CONSULTA 5: Historial de auditoría (BITACORA)
PRINT ' '
PRINT '5. HISTORIAL DE AUDITORÍA'
PRINT '=========================================='

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
-- PASO 7: PRUEBAS DEL SISTEMA
------------------------------------------------------------

PRINT ' '
PRINT '=========================================='
PRINT 'PASO 7: PRUEBAS DEL SISTEMA'
PRINT '=========================================='
PRINT ' '
GO

-- TEST 1: Insertar un nuevo producto (éxito)
PRINT 'TEST 1: Insertar producto válido'
EXEC dbo.sp_InsertarProducto 
    @p_Nombre = N'Prueba Producto Taller2',
    @p_IdCategoria = 1,
    @p_Precio = 15.50,
    @p_Stock = 25;
GO

-- TEST 2: Intentar insertar producto duplicado (debe fallar)
PRINT ' '
PRINT '✓ TEST 2: Intentar insertar producto duplicado (debe fallar)'
EXEC dbo.sp_InsertarProducto 
    @p_Nombre = N'Gaseosa 350ml',  -- Ya existe
    @p_IdCategoria = 1,
    @p_Precio = 0.80,
    @p_Stock = 100;
GO

-- TEST 3: Realizar un pedido válido
PRINT ' '
PRINT '✓ TEST 3: Realizar pedido válido'
EXEC dbo.sp_RealizarPedido 
    @p_IdCliente = 1,
    @p_IdProducto = 1,
    @p_Cantidad = 5;
GO

-- TEST 4: Intentar pedir más stock del disponible (debe fallar)
PRINT ' '
PRINT '✓ TEST 4: Intentar stock insuficiente (debe fallar)'
EXEC dbo.sp_RealizarPedido 
    @p_IdCliente = 2,
    @p_IdProducto = 2,
    @p_Cantidad = 999999;  -- Hay que tener cuidado acá
GO

------------------------------------------------------------
-- PASO 8: VERIFICACIÓN FINAL
------------------------------------------------------------

PRINT ' '
PRINT 'PASO 8: VERIFICACIÓN FINAL'
PRINT ' '
GO

PRINT 'Verificando que TODO fue creado correctamente...'
PRINT ' '
GO

-- Verificar tabla BITACORA
PRINT '1. Tabla BITACORA:'
IF OBJECT_ID('dbo.BITACORA', 'U') IS NOT NULL
    PRINT '   ✓ EXISTE'
ELSE
    PRINT '   ❌ NO EXISTE'
GO

-- Verificar procedimientos
PRINT '2. Procedimientos:'
IF OBJECT_ID('dbo.sp_InsertarProducto', 'P') IS NOT NULL
    PRINT '   ✓ sp_InsertarProducto EXISTE'
ELSE
    PRINT '   ❌ sp_InsertarProducto NO EXISTE'

IF OBJECT_ID('dbo.sp_RealizarPedido', 'P') IS NOT NULL
    PRINT '   ✓ sp_RealizarPedido EXISTE'
ELSE
    PRINT '   ❌ sp_RealizarPedido NO EXISTE'
GO

-- Verificar triggers
PRINT '3. Triggers:'
SELECT COUNT(*) AS TotalTriggers 
FROM sys.triggers 
WHERE parent_id IN (SELECT object_id FROM sys.tables WHERE name = 'Productos');
GO

-- Contar registros en BITACORA
PRINT '4. Registros de auditoría creados:'
SELECT COUNT(*) AS TotalAuditorias FROM dbo.BITACORA;
GO

-- Ver estado actual de productos
PRINT '5. Estado actual de productos:'
SELECT COUNT(*) AS TotalProductos, 
       ROUND(AVG(Precio), 2) AS PrecioPromedio,
       SUM(Stock) AS StockTotal
FROM dbo.Productos 
WHERE Activo = 1;
GO

------------------------------------------------------------
-- CONFIRMACIÓN FINAL
------------------------------------------------------------

PRINT ' '
PRINT '=========================================='
PRINT ' TALLER 2 COMPLETADO EXITOSAMENTE'
PRINT '=========================================='
PRINT ' '
PRINT 'Se creó:'
PRINT '✓ 1 Tabla BITACORA'
PRINT '✓ 2 Procedimientos almacenados'
PRINT '✓ 3 Triggers de auditoría'
PRINT '✓ 5 Consultas analíticas'
PRINT ' '
PRINT 'Próximo paso: Ejecutar Taller2_Guia_Pruebas.sql'
PRINT '=========================================='
GO
