USE Chinook ; 

-- TRIGGERS

-- 1
/*ActualizarStockEnVenta: Al realizar una venta, actualiza la cantidad de canciones en stock.*/

DELIMITER //
CREATE TRIGGER ActualizarStockEnVenta
AFTER INSERT ON InvoiceLine
FOR EACH ROW
BEGIN
    DECLARE TrackId INT, Quantity INT;

    -- Asumimos que la tabla Track tiene una columna llamada 'Stock'
    SELECT TrackId = i.TrackId, @Quantity = i.Quantity
    FROM INSERTED i;

    UPDATE Track
    SET Stock = Stock - Quantity
    WHERE TrackId = TrackId;
END//
DELIMITER ;

-- 2
/*AuditarCambioCliente: Cada vez que se modifica un cliente, registra el cambio en una tabla de auditoría.*/
CREATE TABLE IF NOT EXISTS Auditoria
(
    AuditId INT auto_increment PRIMARY KEY,
    CustomerId INT,
    OldFirstName NVARCHAR(40),
    OldLastName NVARCHAR(20),
    NewFirstName NVARCHAR(40),
    NewLastName NVARCHAR(20),
    ChangedAt DATETIME DEFAULT NOW()
);


DELIMITER //
CREATE TRIGGER AuditarCambioCliente
AFTER UPDATE ON Customer
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (CustomerId, OldFirstName, OldLastName, NewFirstName, NewLastName)
    SELECT d.CustomerId, d.FirstName, d.LastName, i.FirstName, i.LastName
    FROM DELETED d
    INNER JOIN INSERTED i ON d.CustomerId = i.CustomerId
    WHERE d.FirstName <> i.FirstName OR d.LastName <> i.LastName;
END//
DELIMITER ;

-- 3
/*RegistrarCambioPrecio: Guarda el historial de cambios de precio en las canciones.*/

CREATE TABLE IF NOT EXISTS Precio_Historial
(
    HistoryId INT auto_increment PRIMARY KEY,
    TrackId INT,
    OldPrice DECIMAL(10, 2),
    NewPrice DECIMAL(10, 2),
    ChangedAt DATETIME DEFAULT NOW()
);

DELIMITER //
CREATE TRIGGER RegistrarCambioPrecio
AFTER UPDATE ON Track
FOR EACH ROW
BEGIN
    INSERT INTO Precio_Historial (TrackId, OldPrice, NewPrice)
    SELECT d.TrackId, d.UnitPrice, i.UnitPrice
    FROM DELETED d
    INNER JOIN INSERTED i ON d.TrackId = i.TrackId
    WHERE d.UnitPrice <> i.UnitPrice;
END//
DELIMITER ;

-- 4
/*NotificarEliminacionVenta: Notifica cuando se elimina un registro de venta.*/
CREATE TABLE VentaEliminadaLog
(
    LogId INT auto_increment PRIMARY KEY,
    InvoiceId INT,
    DeletedAt DATETIME DEFAULT NOW()
);
DELIMITER //
CREATE TRIGGER Noti_Eliminar
AFTER UPDATE ON Invoice
FOR EACH ROW
BEGIN
	INSERT INTO VentaEliminadaLog(InvoiceId)
    VALUES(OLD.InvoiceId);
END //
DELIMITER ;

-- 5 
/*BloquearCompraConDeuda: Evita la compra de un cliente si tiene deuda pendiente.*/

-- No chè :(

