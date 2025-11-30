------------------------------------------------------------
-- TALLER 2: GUÍA DE PRUEBAS
-- Base de Datos: TiendaGrupo
------------------------------------------------------------

USE TiendaGrupo;
GO

PRINT '=========================================='
PRINT 'PRUEBAS DEL SISTEMA'
PRINT '=========================================='
GO

------------------------------------------------------------
-- PRUEBA 1: Insertar producto válido
------------------------------------------------------------

PRINT ' '
PRINT 'PRUEBA 1: Insertar producto válido'
EXEC dbo.sp_InsertarProducto 
    @p_Nombre = N'Test Producto',
    @p_IdCategoria = 1,
    @p_Precio = 25.00,
    @p_Stock = 30;
GO

------------------------------------------------------------
-- PRUEBA 2: Intentar insertar producto duplicado
------------------------------------------------------------

PRINT ' '
PRINT 'PRUEBA 2: Intentar insertar producto duplicado (debe fallar)'
EXEC dbo.sp_InsertarProducto 
    @p_Nombre = N'Gaseosa 350ml',
    @p_IdCategoria = 1,
    @p_Precio = 0.80,
    @p_Stock = 100;
GO

------------------------------------------------------------
-- PRUEBA 3: Realizar pedido válido
------------------------------------------------------------

PRINT ' '
PRINT 'PRUEBA 3: Realizar pedido válido'
EXEC dbo.sp_RealizarPedido 
    @p_IdCliente = 1,
    @p_IdProducto = 1,
    @p_Cantidad = 5;
GO

------------------------------------------------------------
-- PRUEBA 4: Intentar pedir más stock del disponible
------------------------------------------------------------

PRINT ' '
PRINT 'PRUEBA 4: Intentar pedir más stock (debe fallar)'
EXEC dbo.sp_RealizarPedido 
    @p_IdCliente = 2,
    @p_IdProducto = 2,
    @p_Cantidad = 999;
GO

------------------------------------------------------------
-- VERIFICACIONES
------------------------------------------------------------

PRINT ' '
PRINT '=========================================='
PRINT 'VERIFICACIONES'
PRINT '=========================================='
GO

PRINT ' '
PRINT 'Productos actuales:'
SELECT IdProducto, Nombre, Stock FROM dbo.Productos WHERE Activo = 1;
GO

PRINT ' '
PRINT 'Pedidos realizados:'
SELECT IdPedido, IdCliente, Total FROM dbo.Pedidos;
GO

PRINT ' '
PRINT 'Registros de auditoría:'
SELECT IdAuditoria, Accion, NombreProducto FROM dbo.BITACORA;
GO

PRINT ' '
PRINT '=========================================='
PRINT '✓ PRUEBAS COMPLETADAS'
PRINT '=========================================='
GO
