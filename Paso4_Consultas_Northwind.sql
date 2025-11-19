
--  Paso4_Consultas_Northwind.sql  

USE Northwind
GO

-- CONSULTA 1: Productos por categoría
-- Contar cuántos productos hay en cada categoría

SELECT 
    CategoryName AS 'CategoryName',
    COUNT(ProductID) AS 'Numero de productos'
FROM 
    Categories c
    INNER JOIN Products p ON c.CategoryID = p.CategoryID
GROUP BY 
    CategoryName
ORDER BY 
    CategoryName
GO


-- CONSULTA 2: Detalle de ventas
-- Objetivo: Mostrar el vendedor, fecha del pedido, producto y cantidad

SELECT 
    e.FirstName + ' ' + e.LastName AS 'Nombre Completo',
    o.OrderDate AS 'OrderDate',
    p.ProductName AS 'ProductName',
    od.Quantity AS 'Quantity'
FROM 
    Orders o
    INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
    INNER JOIN Products p ON od.ProductID = p.ProductID
    INNER JOIN Employees e ON o.EmployeeID = e.EmployeeID
ORDER BY 
    e.LastName, e.FirstName, o.OrderDate
GO


-- CONSULTA 3: Top vendedores con ventas mayores a $100,000
-- Listar vendedores cuyas ventas totales superan los $100,000

SELECT 
    e.FirstName + ' ' + e.LastName AS 'Nombre Completo',
    ROUND(SUM(od.Quantity * od.UnitPrice), 2) AS 'Venta total'
FROM 
    Employees e
    INNER JOIN Orders o ON e.EmployeeID = o.EmployeeID
    INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY 
    e.FirstName, e.LastName
HAVING 
    SUM(od.Quantity * od.UnitPrice) > 100000
ORDER BY 
    [Venta total] DESC
GO

PRINT 'Consultas ejecutadas correctamente'