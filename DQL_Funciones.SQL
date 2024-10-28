USE Chinook;

-- 1
/*TotalDeVentasCliente(ClienteID): Calcula el total de ventas de un cliente en un año específico.*/

DELIMITER //
CREATE FUNCTION TotalDeVentasCliente(ClienteID INT, Ano DATE)
RETURNS DECIMAL(10, 2)
BEGIN 
	DECLARE TotalVentas DECIMAL(10, 2);
    
	SELECT SUM(i.Total) into TotalVentas
	FROM Invoice i 
	WHERE i.CustomerId = ClienteID AND YEAR(i.InvoiceDate) = Ano; 
	RETURN TotalVentas; 
END //
DELIMITER ;

CALL TotalDeVentasCliente(5,CURDATE()) -- :(

-- 2
/*PrecioPromedioPorCompra(CompraID): Retorna el precio promedio de canciones en una compra.*/
DELIMITER //
CREATE FUNCTION PrecioPromedioPorCompra(CompraID INT) 
RETURNS DECIMAL(10, 2) 
BEGIN 
DECLARE PrecioPromedio DECIMAL(10, 2); 
SELECT PrecioPromedio = AVG(il.UnitPrice) 
FROM InvoiceLine il 
WHERE il.InvoiceId = @CompraID; 
RETURN ISNULL(PrecioPromedio, 0); 
END //
DELIMITER ;
