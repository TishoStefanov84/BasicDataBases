CREATE DATABASE [Airport]

USE [Airport]

------- 01.DDL--------------

CREATE TABLE Planes(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL,
	Seats INT NOT NULL,
	[Range] INT NOT NULL
)

CREATE TABLE Flights(
	Id INT PRIMARY KEY IDENTITY,
	DepartureTime DATETIME2,
	ArrivalTime DATETIME2,
	Origin VARCHAR(50) NOT NULL,
	Destination VARCHAR(50) NOT NULL,
	PlaneId INT FOREIGN KEY REFERENCES Planes(Id)
)

CREATE TABLE Passengers(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(30) NOT NULL,
	LastName VARCHAR(30) NOT NULL,
	Age INT NOT NULL,
	[Address] VARCHAR(30) NOT NULL,
	PassportId CHAR(11) NOT NULL
)

CREATE TABLE LuggageTypes(
	Id INT PRIMARY KEY IDENTITY,
	[Type] VARCHAR(30) NOT NULL
)

CREATE TABLE Luggages(
	Id INT PRIMARY KEY IDENTITY,
	LuggageTypeId INT FOREIGN KEY REFERENCES LuggageTypes(Id),
	PassengerId INT FOREIGN KEY REFERENCES Passengers(Id)
)

CREATE TABLE Tickets(
	Id INT PRIMARY KEY IDENTITY,
	PassengerId INT FOREIGN KEY REFERENCES Passengers(Id),
	FlightId INT FOREIGN KEY REFERENCES Flights(Id),
	LuggageId INT FOREIGN KEY REFERENCES Luggages(Id),
	Price DECIMAL(15, 2) NOT NULL
)

------------- 02. Insert -------------------------

INSERT INTO Planes([Name], Seats, [Range])
	VALUES
		('Airbus 336', 112, 5132),
		('Airbus 330', 432, 5325),
		('Boeing 369', 231, 2355),
		('Stelt 297', 254, 2143),
		('Boeing 338', 165, 5111),
		('Airbus 558', 387, 1342),
		('Boeing 128', 345, 5541)

INSERT INTO LuggageTypes([Type])
	VALUES
		('Crossbody Bag'),
		('School Backpack'),
		('Shoulder Bag')

----------- 03.Update ------------------

UPDATE Tickets
SET Price += Price * 0.13
WHERE Price = ( 
				  SELECT Price FROM Tickets AS t
				  JOIN Flights AS f ON f.Id = t.FlightId
				  WHERE Destination = 'Carlsbad'
				 )

------------ 04. Delete -----------------


DELETE FROM Tickets
WHERE FlightId = (
				  SELECT Id FROM Flights
				  WHERE Destination = 'Ayn Halagim'
				 )

DELETE FROM Flights
WHERE Id = (
			SELECT Id FROM Flights
            WHERE Destination = 'Ayn Halagim'
		   )

-------------- 05. The "Tr" Planes --------------

SELECT * FROM Planes
WHERE [Name] LIKE '%tr%'
ORDER BY Id, [Name], Seats, [Range]

------------- 06. Flight Profits -----------------

SELECT f.Id AS [FlightId],
		SUM(t.Price) AS [Price]
	FROM Flights AS f
JOIN Tickets AS t ON f.Id = t.FlightId
GROUP BY f.Id
ORDER BY SUM(t.Price) DESC, [FlightId]


------------- 07. Passenger Trips ------------------

SELECT CONCAT(p.FirstName, ' ', p.LastName) AS [Full Name],
	   f.Origin,
	   f.Destination
	FROM Passengers AS p
JOIN Tickets AS t ON p.Id = t.PassengerId
JOIN Flights AS f ON t.FlightId = f.Id
ORDER BY [Full Name], f.Origin, f.Destination


----------- 08. Non Adventures People --------------

SELECT p.FirstName, p.LastName, p.Age FROM Passengers AS p
LEFT JOIN Tickets AS t ON p.Id = t.PassengerId
WHERE t.Id IS NULL
ORDER BY p.Age DESC, p.FirstName, p.LastName


------------- 09. Full Info --------------------

SELECT CONCAT(p.FirstName, ' ', p.LastName) AS [Full Name], 
	   pl.[Name] AS [Plane Name],
	   CONCAT(f.Origin, ' - ', f.Destination) AS [Trip],
	   lt.[Type] AS [Luggage Type]
	FROM Passengers AS p
JOIN Tickets AS t ON p.Id = t.PassengerId
JOIN Flights AS f ON t.FlightId = f.Id
JOIN Planes AS pl ON f.PlaneId = pl.Id
JOIN Luggages AS l ON t.LuggageId = l.Id
JOIN LuggageTypes AS lt ON l.LuggageTypeId = lt.Id
ORDER BY [Full Name], [Plane Name], f.Origin, f.Destination, [Luggage Type]

-------------------- 10. PSP -------------------------

SELECT p.[Name], 
	   p.Seats, 
	   COUNT(t.PassengerId) AS [Passengers Count] 
	FROM Planes AS p
LEFT JOIN Flights AS f ON p.Id = f.PlaneId
LEFT JOIN Tickets AS t ON f.Id = t.FlightId
GROUP BY p.[Name], p.Seats
ORDER BY [Passengers Count] DESC, p.[Name], p.Seats

------------------ 11. Vacation ---------------------
GO

CREATE FUNCTION udf_CalculateTickets(@origin VARCHAR(50), @destination VARCHAR(50), @peopleCount INT)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @totalPrice DECIMAL(24, 2)

	IF(@peopleCount <= 0)
	BEGIN
		RETURN 'Invalid people count!'
	END

	DECLARE @currentFlightId INT = (SELECT TOP(1) Id 
										FROM Flights 
										WHERE Origin = @origin AND Destination = @destination)

	IF(@currentFlightId IS NULL)
	BEGIN
		RETURN 'Invalid flight!'
	END

	DECLARE @price DECIMAL (15, 2) = (SELECT Price 
											FROM Tickets
											WHERE FlightId = @currentFlightId)
		
	SET @totalPrice = @price * @peopleCount

	DECLARE @result VARCHAR(50) = CAST(@totalPrice AS varchar(50))
	RETURN CONCAT('Total price ', @result)

END

GO

SELECT dbo.udf_CalculateTickets('Kolyshley','Rancabolang', 33)
SELECT dbo.udf_CalculateTickets('Kolyshley','Rancabolang', -1)
SELECT dbo.udf_CalculateTickets('Invalid','Rancabolang', 33)

----------------- 12. Wrong Data -----------------------------

GO

CREATE PROCEDURE usp_CancelFlights
AS
UPDATE Flights
SET DepartureTime = NULL, ArrivalTime = NULL
WHERE ArrivalTime > DepartureTime

GO

