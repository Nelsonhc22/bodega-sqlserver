------------------------------------------------------------
-- SCRIPT ADICIONAL: VISTAS Y FUNCIONES
-- Base de Datos: TiendaGrupo
-- Autores: Kevin Soriano + Jimmy Melendez
------------------------------------------------------------

USE TiendaGrupo;
GO

------------------------------------------------------------
-- VISTA 1: Categorías y Productos (Kevin)
------------------------------------------------------------

IF OBJECT_ID('dbo.vw_CategoriasProductos', 'V') IS NOT NULL
    DROP VIEW dbo.vw_CategoriasProductos;
GO

CREATE VIEW dbo.vw_CategoriasProductos
AS
SELECT
    c.IdCategoria,
    c.Nombre AS NombreCategoria,
    p.IdProducto,
    p.Nombre AS NombreProducto,
    p.Precio,
    p.Stock
FROM dbo.Categorias c
INNER JOIN dbo.Productos p
    ON c.IdCategoria = p.IdCategoria;
GO

------------------------------------------------------------
-- VISTA 2: Resumen de Inventario
------------------------------------------------------------

IF OBJECT_ID('dbo.vw_ResumenInventario', 'V') IS NOT NULL
    DROP VIEW dbo.vw_ResumenInventario;
GO

CREATE VIEW dbo.vw_ResumenInventario
AS
SELECT
    c.Nombre AS Categoria,
    COUNT(p.IdProducto) AS TotalProductos,
    SUM(p.Stock) AS StockTotal,
    ROUND(AVG(p.Precio), 2) AS PrecioPromedio
FROM dbo.Categorias c
LEFT JOIN dbo.Productos p ON c.IdCategoria = p.IdCategoria
WHERE c.Activo = 1 AND p.Activo = 1
GROUP BY c.Nombre;
GO

------------------------------------------------------------
-- VISTA 3: Ventas por Cliente
------------------------------------------------------------

IF OBJECT_ID('dbo.vw_VentasPorCliente', 'V') IS NOT NULL
    DROP VIEW dbo.vw_VentasPorCliente;
GO

CREATE VIEW dbo.vw_VentasPorCliente
AS
SELECT
    cl.NombreCompleto,
    COUNT(ped.IdPedido) AS TotalPedidos,
    ROUND(SUM(ped.Total), 2) AS VentaTotal
FROM dbo.Clientes cl
LEFT JOIN dbo.Pedidos ped ON cl.IdCliente = ped.IdCliente
WHERE cl.Activo = 1
GROUP BY cl.IdCliente, cl.NombreCompleto;
GO

PRINT '✓ Vistas creadas exitosamente'
GO
