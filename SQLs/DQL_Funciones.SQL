USE Chinook;

-- 1
/*TotalDeVentasCliente(ClienteID): Calcula el total de ventas de un cliente en un año específico.*/

DELIMITER //
CREATE FUNCTION Ventas_Cliente_Año(ID_Cliente INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	SELECT 
    C.FirstName,
    C.LastName,
    SUM(IL.InvoiceLineId) as Total
    FROM Customer C
    JOIN Invoice I ON C.CustomerId = I.CustomerId
    JOIN InvoiceLine IL ON I.InvoiceId = IL.InvoiceId
    group by Total
	
END//
