------------------------------------------------------------
-- GUÍA DE PRUEBA: TALLER 2
-- Base de Datos: TiendaGrupo
-- Instrucciones para ejecutar y validar los procedimientos
------------------------------------------------------------

-- PASO 1: Asegurar que estamos en la base de datos correcta
USE TiendaGrupo;
GO

------------------------------------------------------------
-- SECCIÓN 1: PRUEBAS DE PROCEDIMIENTOS
------------------------------------------------------------

PRINT 'PRUEBAS DE PROCEDIMIENTOS ALMACENADOS'
GO

-- TEST 1: Insertar un nuevo producto 
PRINT '1. Insertando producto válido...'
EXEC dbo.sp_InsertarProducto 
    @p_Nombre = N'Tablet Samsung 10"',
    @p_IdCategoria = 4,  -- Tecnología
    @p_Precio = 120.00,
    @p_Stock = 25;
GO

-- TEST 2: Intentar insertar producto duplicado (DEBE FALLAR)
PRINT '2. Intentando insertar producto duplicado...'
EXEC dbo.sp_InsertarProducto 
    @p_Nombre = N'Gaseosa 350ml',  -- Ya existe en la BD
    @p_IdCategoria = 1,
    @p_Precio = 0.80,
    @p_Stock = 50;
GO

-- TEST 3: Insertar producto con categoría inválida (DEBE FALLAR)
PRINT '3. Intentando insertar con categoría inexistente...'
EXEC dbo.sp_InsertarProducto 
    @p_Nombre = N'Producto Test',
    @p_IdCategoria = 999,  -- No existe
    @p_Precio = 10.00,
    @p_Stock = 10;
GO

-- TEST 4: Insertar producto con precio inválido (DEBE FALLAR)
PRINT '4. Intentando insertar con precio negativo...'
EXEC dbo.sp_InsertarProducto 
    @p_Nombre = N'Otro Producto',
    @p_IdCategoria = 1,
    @p_Precio = -5.00,  -- Inválido
    @p_Stock = 10;
GO

-- TEST 5: Realizar un pedido válido
PRINT '5. Realizando pedido válido...'
EXEC dbo.sp_RealizarPedido 
    @p_IdCliente = 1,      -- Juan Pérez
    @p_IdProducto = 1,     -- Gaseosa 350ml
    @p_Cantidad = 5;
GO

-- TEST 6: Intentar pedir más de lo disponible (DEBE FALLAR)
PRINT '6. Intentando pedir más stock del disponible...'
EXEC dbo.sp_RealizarPedido 
    @p_IdCliente = 2,      -- Ana Gómez
    @p_IdProducto = 2,     -- Café molido 500g
    @p_Cantidad = 1000;    -- Stock insuficiente
GO

-- TEST 7: Intentar pedir producto inexistente (DEBE FALLAR)
PRINT '7. Intentando pedir producto inexistente...'
EXEC dbo.sp_RealizarPedido 
    @p_IdCliente = 1,
    @p_IdProducto = 999,   -- No existe
    @p_Cantidad = 10;
GO

-- TEST 8: Realizar otro pedido válido (cliente 3, producto 5)
PRINT '8. Realizando segundo pedido válido...'
EXEC dbo.sp_RealizarPedido 
    @p_IdCliente = 3,      -- Carlos Ruiz
    @p_IdProducto = 5,     -- Leche entera 1L
    @p_Cantidad = 10;
GO

------------------------------------------------------------
-- SECCIÓN 2: VERIFICACIÓN DE DATOS
------------------------------------------------------------

PRINT ' '
PRINT '=========================================='
PRINT 'VERIFICACIÓN DE DATOS DESPUÉS DE PRUEBAS'
PRINT '=========================================='
GO

-- Verificar productos actuales
PRINT '1. Estado actual de productos:'
SELECT IdProducto, Nombre, Stock, Precio, Activo
FROM dbo.Productos
ORDER BY IdProducto;
GO

-- Verificar pedidos realizados
PRINT '2. Pedidos realizados:'
SELECT p.IdPedido, c.NombreCompleto, p.FechaPedido, p.Total
FROM dbo.Pedidos p
INNER JOIN dbo.Clientes c ON p.IdCliente = c.IdCliente
ORDER BY p.IdPedido DESC;
GO

-- Verificar detalles de pedidos
PRINT '3. Detalles de los pedidos:'
SELECT 
    dp.IdDetalle, 
    prod.Nombre, 
    dp.Cantidad, 
    dp.PrecioUnitario,
    (dp.Cantidad * dp.PrecioUnitario) AS Subtotal
FROM dbo.DetallePedidos dp
INNER JOIN dbo.Productos prod ON dp.IdProducto = prod.IdProducto
ORDER BY dp.IdDetalle DESC;
GO

-- Verificar la bitácora de auditoría
PRINT '4. Historial de auditoría (BITÁCORA):'
SELECT 
    IdAuditoria,
    Accion,
    FechaAccion,
    Usuario,
    NombreProducto
FROM dbo.BITACORA
ORDER BY IdAuditoria DESC;
GO

------------------------------------------------------------
-- SECCIÓN 3: CONSULTAS ANALÍTICAS
------------------------------------------------------------

PRINT ' '
PRINT '=========================================='
PRINT 'CONSULTAS ANALÍTICAS'
PRINT '=========================================='
GO

-- Consulta 1: Productos por categoría
PRINT '1. Cantidad de productos por categoría:'
SELECT 
    c.Nombre AS NombreCategoria,
    COUNT(p.IdProducto) AS CantidadProductos,
    ROUND(AVG(p.Precio), 2) AS PrecioPromedio
FROM dbo.Categorias c
LEFT JOIN dbo.Productos p ON c.IdCategoria = p.IdCategoria AND p.Activo = 1
WHERE c.Activo = 1
GROUP BY c.IdCategoria, c.Nombre
ORDER BY CantidadProductos DESC;
GO

-- Consulta 2: Detalles de ventas
PRINT '2. Detalles de todas las ventas realizadas:'
SELECT 
    cl.NombreCompleto AS Cliente,
    prod.Nombre AS Producto,
    dp.Cantidad,
    dp.PrecioUnitario,
    (dp.Cantidad * dp.PrecioUnitario) AS Total
FROM dbo.Pedidos ped
INNER JOIN dbo.Clientes cl ON ped.IdCliente = cl.IdCliente
INNER JOIN dbo.DetallePedidos dp ON ped.IdPedido = dp.IdPedido
INNER JOIN dbo.Productos prod ON dp.IdProducto = prod.IdProducto
ORDER BY ped.FechaPedido DESC;
GO

-- Consulta 3: Stock bajo
PRINT '3. Productos con stock bajo:'
SELECT 
    prod.Nombre,
    cat.Nombre AS Categoria,
    prod.Stock,
    prod.Precio
FROM dbo.Productos prod
INNER JOIN dbo.Categorias cat ON prod.IdCategoria = cat.IdCategoria
WHERE prod.Stock <= 50 AND prod.Activo = 1
ORDER BY prod.Stock ASC;
GO

------------------------------------------------------------
-- pruebas
------------------------------------------------------------

/*
PARA AGREGAR MÁS PRODUCTOS DE PRUEBA:

EXEC dbo.sp_InsertarProducto @p_Nombre = N'iPhone 13', @p_IdCategoria = 4, @p_Precio = 899.99, @p_Stock = 15;
EXEC dbo.sp_InsertarProducto @p_Nombre = N'Monitor 27"', @p_IdCategoria = 4, @p_Precio = 250.00, @p_Stock = 12;
EXEC dbo.sp_InsertarProducto @p_Nombre = N'Mouse Inalámbrico', @p_IdCategoria = 4, @p_Precio = 25.00, @p_Stock = 50;

PARA REALIZAR MÁS PEDIDOS DE PRUEBA:

EXEC dbo.sp_RealizarPedido @p_IdCliente = 2, @p_IdProducto = 3, @p_Cantidad = 10;
EXEC dbo.sp_RealizarPedido @p_IdCliente = 1, @p_IdProducto = 7, @p_Cantidad = 2;

*/

PRINT ' '
PRINT '=========================================='
PRINT 'GUÍA DE PRUEBA COMPLETADA'
PRINT '=========================================='
GO
