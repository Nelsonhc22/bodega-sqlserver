
CREATE PROCEDURE RealizarPedido
    @idpedido CHAR(7),
    @idprod CHAR(7),
    @cantidad INT
AS
BEGIN
    -- Verificar si el producto existe
    IF NOT EXISTS (SELECT * FROM PRODUCTO WHERE idprod = @idprod)
    BEGIN
        PRINT 'ESTE PRODUCTO NO EXISTE';
        RETURN;
    END;

    -- Verificar existencias del producto
    DECLARE @existencia INT;
    SELECT @existencia = existencias FROM PRODUCTO WHERE idprod = @idprod;

    IF @existencia < @cantidad
    BEGIN
        PRINT 'EXISTENCIA DEL PRODUCTO INSUFICIENTE';
        RETURN;
    END;

    -- Insertar el pedido si hay suficiente existencia
    INSERT INTO PEDIDO (idpedido, idprod, cantidad)
    VALUES (@idpedido, @idprod, @cantidad);

    -- Actualizar la existencia del producto
    UPDATE PRODUCTO
    SET existencias = existencias - @cantidad
    WHERE idprod = @idprod;

    PRINT 'PEDIDO REGISTRADO EXITOSAMENTE';
END;
GO

-- Producto inexistente
EXEC RealizarPedido 'PED001', 'P9999', 5;

-- Producto existente pero sin suficiente stock
EXEC RealizarPedido 'PED002', 'P0001', 100;

-- Producto correcto (stock suficiente)
EXEC RealizarPedido 'PED003', 'P0001', 2;