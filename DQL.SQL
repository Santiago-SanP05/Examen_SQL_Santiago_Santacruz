USE Chinook;


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

-- 2 Lista los clientes que han gastado más de $40 en total en la tienda.
SELECT c.CustomerId,
	c.FirstName,
	c.LastName,
	SUM(i.Total) AS TotalSpent 
FROM Customer c 
JOIN Invoice i ON c.CustomerId = i.CustomerId 
GROUP BY c.CustomerId, c.FirstName, c.LastName 
HAVING SUM(i.Total) > 40;

-- 3 Encuentra los cinco géneros más vendidos.
SELECT g.Name, 
SUM(il.Quantity) AS TotalSold 
FROM Genre g 
JOIN Track t ON g.GenreId = t.GenreId 
JOIN InvoiceLine il ON t.TrackId = il.TrackId 
GROUP BY g.Name 
ORDER BY TotalSold DESC LIMIT 5;

-- 4 Calcula el número de canciones compradas por cada cliente.
SELECT C.CustomerId, C.FirstName, C.LastName, SUM(il.Quantity) AS TotalSongs 
FROM Customer C
INNER JOIN Invoice i ON C.CustomerId = i.CustomerId 
INNER JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId 
GROUP BY C.CustomerId, C.FirstName, C.LastName;

-- 5 Lista los clientes que no han realizado compras en los últimos 6 meses.
SELECT c.CustomerId, c.FirstName, c.LastName 
FROM Customer c 
LEFT JOIN Invoice i ON c.CustomerId = i.CustomerId AND i.InvoiceDate >= DATE_ADD(CURDATE(), interval -6 YEAR) 
WHERE i.InvoiceId IS NULL;

-- 6 Consulta el número total de ventas por cada artista.
SELECT AR.Name, SUM(il.Quantity) AS Total_Ventas
FROM Artist AR
JOIN Album a ON AR.ArtistId = a.ArtistId 
JOIN Track t ON a.AlbumId = t.AlbumId 
JOIN InvoiceLine il ON t.TrackId = il.TrackId 
GROUP BY AR.Name;

-- 7 Calcula el total de ventas de cada empleado en el último mes.
SELECT e.EmployeeId, e.FirstName, e.LastName, SUM(i.Total) AS TotalSales 
FROM Employee e 
JOIN Customer c ON e.EmployeeId = c.SupportRepId 
JOIN Invoice i ON c.CustomerId = i.CustomerId
WHERE i.InvoiceDate >= DATE_ADD(CURDATE(),INTERVAL -1 MONTH) 
GROUP BY e.EmployeeId, e.FirstName, e.LastName;

-- 8 Encuentra los clientes más frecuentes de cada país.
SELECT i.BillingCountry, c.CustomerId, c.FirstName, COUNT(i.InvoiceId) AS TotalPurchases 
FROM Customer c 
JOIN Invoice i ON c.CustomerId = i.CustomerId 
GROUP BY i.BillingCountry, c.CustomerId, c.FirstName
ORDER BY i.BillingCountry, TotalPurchases DESC;

-- 9 Lista las ventas diarias de canciones en un mes específico.
SELECT DATE(i.InvoiceDate) AS Venta_Fechsa, SUM(il.Quantity) AS Total_De_Canciones 
FROM Invoice i 
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId 
WHERE MONTH(i.InvoiceDate) = 10 AND YEAR(i.InvoiceDate) = 2023 
GROUP BY DATE(i.InvoiceDate);

-- 10 Genera un informe de los cinco clientes más recientes.

SELECT C.FirstName, C.LastName, I.InvoiceDate 
FROM Customer C
INNER JOIN Invoice I ON C.CustomerId = I.CustomerId
ORDER BY I.InvoiceDate DESC
LIMIT 5;

-- 11 Calcula el precio promedio de venta de canciones.

SELECT AVG(il.UnitPrice) AS AveragePrice 
FROM InvoiceLine il;

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

-- 16 Calcula el descuento promedio aplicado a los clientes VIP.
-- Descuento que se le aplica a los VIP (Promedio entre el precio unitario y el de venta, para aplicarcelo a las personas que el total de venta mayor a 10)
SELECT AVG(il.UnitPrice * il.Quantity) AS Descuento_aplicado_A_VIP
FROM InvoiceLine il 
JOIN Invoice i ON il.InvoiceId = i.InvoiceId 
JOIN Customer c ON i.CustomerId = c.CustomerId ;
-- Seleccion de VIP
SELECT COUNT(c.CustomerId), c.FirstName, c.LastName, SUM(i.Total)
FROM Customer c 
LEFT JOIN Invoice i ON c.CustomerId = i.CustomerId WHERE i.Total > 10
GROUP BY c.CustomerId,c.FirstName,c.LastName;

-- 17 Encuentra el cliente con más canciones compradas.

SELECT c.CustomerId, c.FirstName, c.LastName, SUM(il.Quantity) AS Canciones 
FROM Customer c 
JOIN Invoice i ON c.CustomerId = i.CustomerId 
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId 
GROUP BY c.CustomerId, c.FirstName, c.LastName 
ORDER BY Canciones DESC LIMIT 1;

-- 18 Lista los álbumes con más canciones vendidas en el último trimestre.
SELECT a.Title, SUM(il.Quantity) AS TotalSongsSold 
FROM Album a 
JOIN Track t ON a.AlbumId = t.AlbumId 
JOIN InvoiceLine il ON t.TrackId = il.TrackId 
JOIN Invoice i ON il.InvoiceId = i.InvoiceId 
WHERE i.InvoiceDate >= DATE_ADD(CURDATE(),INTERVAL -3 WEEK) 
GROUP BY a.Title 
ORDER BY TotalSongsSold DESC;

-- 19 Muestra las ventas semanales de canciones en el último año.
SELECT DATEPART(WEEK, i.InvoiceDate) AS Week, YEAR(i.InvoiceDate) AS Year, SUM(il.Quantity) AS TotalSongsSold 
FROM Invoice i 
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId 
GROUP BY DATEPART(WEEK, i.InvoiceDate), 
YEAR(i.InvoiceDate) 
ORDER BY Year, Week;

SELECT Week(i.InvoiceDate) as MES, YEAR(i.InvoiceDate) as Año, SUM(il.Quantity) AS Musica_Total
FROM Invoice i
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
WHERE YEAR(i.InvoiceDate) = '2024'
GROUP BY Week(i.InvoiceDate),YEAR(i.InvoiceDate)
ORDER BY Year;

SELECT WEEK(i.InvoiceDate),SUM(il.Quantity) AS Musica_Total
FROM Invoice i
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
GROUP BY Week(i.InvoiceDate);

-- 20 Lista los géneros que no han sido vendidos en el último año.
SELECT g.Name FROM Genre g 
LEFT JOIN Track t ON g.GenreId = t.GenreId 
LEFT JOIN InvoiceLine il ON t.TrackId = il.TrackId 
LEFT JOIN Invoice i ON il.InvoiceId = i.InvoiceId 
WHERE i.InvoiceId IS NULL AND YEAR(i.InvoiceDate) = YEAR(CURDATE());