USE Chinook;


-- EVENTOS
-- 1
CREATE TABLE InformeVentas
(
    ReportId INT AUTO_INCREMENT PRIMARY KEY,
    ReportDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    TotalVentas DECIMAL(10, 2),
    NumeroVentas INT
);

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

-- 2
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

-- 3

CREATE TABLE AlertaAlbum
(
    AlertaId INT AUTO_INCREMENT PRIMARY KEY,
    AlbumId INT,
    AlertaFecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    Mensaje NVARCHAR(255)
);

DELIMITER //
CREATE EVENT AlertaAlbumNoVendidoAnual
ON SCHEDULE EVERY 1 YEAR
STARTS '2024-12-31 00:00:00'
DO
BEGIN
    INSERT INTO AlertaAlbum (AlbumId, Mensaje)
    SELECT a.AlbumId, CONCAT('El álbum con ID ', a.AlbumId, ' no se ha vendido en el último año.')
    FROM Album a
    LEFT JOIN Track t ON a.AlbumId = t.AlbumId
    LEFT JOIN InvoiceLine il ON t.TrackId = il.TrackId
    WHERE il.InvoiceLineId IS NULL OR il.InvoiceId NOT IN (
        SELECT InvoiceId FROM Invoice WHERE InvoiceDate >= DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR)
    );
END//
DELIMITER ;

-- 4
DELIMITER //
CREATE EVENT LimpiarRegistrosAntiguosAuditoria
ON SCHEDULE EVERY 3 MONTH
STARTS '2024-12-01 00:00:00'
DO
BEGIN
    DELETE FROM ClienteAudit
    WHERE ChangedAt < DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR);
END//
DELIMITER ;

-- 5

CREATE TABLE TopGenerosMensual
(
    ReportId INT AUTO_INCREMENT PRIMARY KEY,
    ReportDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    GenreId INT,
    TotalVentas DECIMAL(10, 2)
);

DELIMITER //
CREATE EVENT ActualizarGenerosMasVendidosMensual
ON SCHEDULE EVERY 1 MONTH
STARTS '2024-11-01 00:00:00'
DO
BEGIN
    INSERT INTO TopGenerosMensual (GenreId, TotalVentas)
    SELECT g.GenreId, SUM(il.UnitPrice * il.Quantity)
    FROM Genre g
    JOIN Track t ON g.GenreId = t.GenreId
    JOIN InvoiceLine il ON t.TrackId = il.TrackId
    WHERE il.InvoiceId IN (
        SELECT InvoiceId FROM Invoice WHERE InvoiceDate >= DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH)
    )
    GROUP BY g.GenreId
    ORDER BY TotalVentas DESC;
END//
DELIMITER ;









