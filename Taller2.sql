CREATE TABLE Clientes (
    IdCliente INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(100),
    Pais NVARCHAR(50),
    Telefono NVARCHAR(20)
);

INSERT INTO Clientes (Nombre, Pais, Telefono)
VALUES 
('Carlos López', 'El Salvador', '7012-3456'),
('María Pérez', 'Guatemala', '5021-2222'),
('José Martínez', 'El Salvador', '7890-1111'),
('Ana Gómez', 'Honduras', '8888-9999'),
('Luisa Torres', 'Nicaragua', '8132-0563');

SELECT * FROM Clientes;

SELECT *
FROM Clientes
WHERE Pais = 'El Salvador';

SELECT *
INTO Clientes_ElSalvador
FROM Clientes
WHERE Pais = 'El Salvador';

SELECT * FROM Clientes_ElSalvador;

SELECT *
INTO Clientes_ElSalvador_Copia
FROM Clientes_ElSalvador;

SELECT * FROM Clientes_ElSalvador_Copia;

SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE='BASE TABLE';
