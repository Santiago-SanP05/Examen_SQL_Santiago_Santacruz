# BASE DE DATOS DE VENTAS DE ALBUNES/CANCIONES

Esta base de datos tiene como fin estructurar bien para que las consultas a la hora de manipularlos sea el mas conveniente para todos,
facilitando procedos de filtrados, 

Para la creacion segun los requisistos eran:
## REQUISITOS


Realiza las tareas descritas a continuación. Asegúrate de documentar cada paso y explicar las decisiones tomadas en el desarrollo de cada consulta, procedimiento, función, trigger y evento.

Consultas SQL:


Realiza las siguientes consultas en SQL:


A. Obtén el álbum más vendido en cada país en el último año.
B. Lista los clientes que han gastado más de $40 en total en la tienda.
C.Encuentra los cinco géneros más vendidos.
D. Calcula el número de canciones compradas por cada cliente.
E. Lista los clientes que no han realizado compras en los últimos 6 meses.
F. Consulta el número total de ventas por cada artista.
G. Calcula el total de ventas de cada empleado en el último mes.
H. Encuentra los clientes más frecuentes de cada país.
I. Lista las ventas diarias de canciones en un mes específico.
J. Genera un informe de los cinco clientes más recientes.
K. Calcula el precio promedio de venta de canciones.
L. Lista las canciones más caras y más baratas vendidas.
N. Muestra los cinco clientes que compraron más canciones de Rock.
M. Encuentra la duración total de canciones en cada álbum.
O. Lista los empleados que generaron más ventas en el último año.
P. Calcula el descuento promedio aplicado a los clientes VIP.
R. Encuentra el cliente con más canciones compradas.
S. Lista los álbumes con más canciones vendidas en el último trimestre.
T. Muestra las ventas semanales de canciones en el último año.
U. Lista los géneros que no han sido vendidos en el último año.


Funciones SQL:


Desarrolla las siguientes funciones:



TotalDeVentasCliente(ClienteID): Calcula el total de ventas de un cliente en un año específico.
PrecioPromedioPorCompra(CompraID): Retorna el precio promedio de canciones en una compra.
DuracionTotalAlbum(AlbumID): Retorna la duración total de canciones en un álbum.
CalcularDescuentoCliente(ClienteID): Calcula el descuento a aplicar según el historial de compras.
EsVIP(ClienteID): Verifica si un cliente es "VIP" con base en su frecuencia de compra.


Triggers:


Implementa los siguientes triggers:



ActualizarStockEnVenta: Al realizar una venta, actualiza la cantidad de canciones en stock.
AuditarCambioCliente: Cada vez que se modifica un cliente, registra el cambio en una tabla de auditoría.
RegistrarCambioPrecio: Guarda el historial de cambios de precio en las canciones.
NotificarEliminacionVenta: Notifica cuando se elimina un registro de venta.
BloquearCompraConDeuda: Evita la compra de un cliente si tiene deuda pendiente.


Eventos SQL:


Crea los siguientes eventos:

InformeSemanalVentas: Genera un informe de ventas semanal automáticamente.
ActualizarEstadosCuentaMensual: Actualiza el estado de cuenta de los clientes mensualmente.
AlertaAlbumNoVendidoAnual: Envía una alerta cuando un álbum no se ha vendido en el último año.
LimpiarRegistrosAntiguosAuditoria: Borra los registros antiguos de auditoría cada trimestre.
ActualizarGenerosMasVendidosMensual: Actualiza la lista de géneros más vendidos cada mes.



## Consultas

-- 1 Obtén el álbum más vendido en cada país en el último año.
SELECT I.BillingCountry,
T.AlbumId,
A.Title,
SUM(IL.Quantity) As Total_ventas
FROM Invoice I
INNER JOIN InvoiceLine IL ON I.InvoiceId = IL.InvoiceId
INNER JOIN Track T ON IL.TrackId = T.TrackId
INNER JOIN Album A ON T.AlbumId = A.AlbumId
WHERE I.InvoiceDate < '2024-01-01 00:00:00'
GROUP BY I.BillingCountry,T.AlbumId,A.Title 
ORDER BY I.BillingCountry,Total_ventas DESC;


-- 6 Consulta el número total de ventas por cada artista.
SELECT AR.Name, SUM(il.Quantity) AS Total_Ventas
FROM Artist AR
JOIN Album a ON AR.ArtistId = a.ArtistId 
JOIN Track t ON a.AlbumId = t.AlbumId 
JOIN InvoiceLine il ON t.TrackId = il.TrackId 
GROUP BY AR.Name;Ç

-- 7 Calcula el total de ventas de cada empleado en el último mes.
SELECT e.EmployeeId, e.FirstName, e.LastName, SUM(i.Total) AS TotalSales 
FROM Employee e 
JOIN Customer c ON e.EmployeeId = c.SupportRepId 
JOIN Invoice i ON c.CustomerId = i.CustomerId
WHERE i.InvoiceDate >= DATE_ADD(CURDATE(),INTERVAL -1 MONTH) 
GROUP BY e.EmployeeId, e.FirstName, e.LastName;

-- 12 Lista las canciones más caras y más baratas vendidas.

SELECT t.Name, MAX(il.UnitPrice) AS Mas_Cara 
FROM Track t 
JOIN InvoiceLine il ON t.TrackId = il.TrackId 
GROUP BY t.Name ORDER BY Mas_Cara DESC LIMIT 1;

-- 12.1 La mas barata
SELECT t.Name, MIN(il.UnitPrice) AS Mas_Barata 
FROM Track t 
JOIN InvoiceLine il ON t.TrackId = il.TrackId 
GROUP BY t.Name ORDER BY Mas_Barata ASC LIMIT 1;

-- 13 Muestra los cinco clientes que compraron más canciones de Rock.
SELECT c.CustomerId, c.FirstName, c.LastName, SUM(il.Quantity) AS Canciones_de_Rock 
FROM Customer c 
JOIN Invoice i ON c.CustomerId = i.CustomerId 
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId 
JOIN Track t ON il.TrackId = t.TrackId 
JOIN Genre g ON t.GenreId = g.GenreId 
WHERE g.Name = 'Rock' 
GROUP BY c.CustomerId, c.FirstName, c.LastName 
ORDER BY Canciones_de_Rock DESC LIMIT 5;

-- 15 Lista los empleados que generaron más ventas en el último año.
SELECT e.EmployeeId, e.FirstName, e.LastName, SUM(i.Total) AS TotalSales 
FROM Employee e 
JOIN Customer c ON e.EmployeeId = c.SupportRepId 
JOIN Invoice i ON c.CustomerId = i.CustomerId 
WHERE i.InvoiceDate >= DATE(YEAR, -1, GETDATE()) 
GROUP BY e.EmployeeId, e.FirstName, e.LastName 
ORDER BY TotalSales DESC;

## Eventos

DELIMITER //
CREATE EVENT InformeSemanalVentas
ON SCHEDULE EVERY 1 WEEK
STARTS '2024-10-28 00:00:00'
DO
BEGIN
    INSERT INTO InformeVentas (TotalVentas, NumeroVentas)
    SELECT SUM(Total), COUNT(*)
    FROM Invoice
    WHERE InvoiceDate >= DATE_SUB(CURRENT_DATE, INTERVAL 1 WEEK);
END//
DELIMITER ;


DELIMITER //
CREATE EVENT ActualizarEstadosCuentaMensual
ON SCHEDULE EVERY 1 MONTH
STARTS '2024-11-01 00:00:00'
DO
BEGIN
    UPDATE Customer
    SET AccountStatus = CASE 
        WHEN OutstandingBalance > 0 THEN 'Pending'
        ELSE 'Clear'
    END;
END;
DELIMITER ;


## Hecho Por
Santiago Santacruz Pinzon
@Santiago-SanP05
Tel: 3508115170
