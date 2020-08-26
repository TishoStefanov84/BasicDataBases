CREATE DATABASE TripService

USE TripService

------------------- 01.DDL ---------------------

CREATE TABLE Cities(
	Id INT  PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(20) NOT NULL,
	CountryCode CHAR(2) NOT NULL
)

CREATE TABLE Hotels(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL,
	CityId INT FOREIGN KEY REFERENCES Cities(Id),
	EmployeeCount INT NOT NULL,
	BaseRate DECIMAL(15, 2)
)

CREATE TABLE Rooms(
	Id INT PRIMARY KEY IDENTITY,
	Price DECIMAL(15, 2) NOT NULL,
	[Type] NVARCHAR(20) NOT NULL,
	Beds INT NOT NULL,
	HotelId INT FOREIGN KEY REFERENCES Hotels(Id)
)

CREATE TABLE Trips(
	Id INT PRIMARY KEY IDENTITY,
	RoomId INT FOREIGN KEY REFERENCES Rooms(Id),
	BookDate DATE NOT NULL, CHECK(BookDate < ArrivalDate),
	ArrivalDate DATE NOT NULL, CHECK(ArrivalDate < ReturnDate),
	ReturnDate DATE NOT NULL,
	CancelDate DATE
)

CREATE TABLE Accounts(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	MiddleName NVARCHAR(20),
	LastName NVARCHAR(50) NOT NULL,
	CityId INT FOREIGN KEY REFERENCES Cities(Id),
	BirthDate DATE NOT NULL,
	Email VARCHAR(100) NOT NULL UNIQUE
)

CREATE TABLE AccountsTrips(
	AccountId INT FOREIGN KEY REFERENCES Accounts(Id),
	TripId INT FOREIGN KEY REFERENCES Trips(Id),
	Luggage INT NOT NULL, CHECK(Luggage >= 0),
	PRIMARY KEY(AccountId, TripId)
)




------------------------ 02. Insert --------------------------------

INSERT INTO Accounts(FirstName, MiddleName, LastName, CityId, BirthDate, Email)
	VALUES
		('John', 'Smith', 'Smith', 34, '1975-07-21', 'j_smith@gmail.com'),
		('Gosho', NULL, 'Petrov', 11, '1978-05-16', 'g_petrov@gmail.com'),
		('Ivan', 'Petrovich', 'Pavlov', 59, '1849-09-26', 'i_pavlov@softuni.bg'),
		('Friedrich', 'Wilhelm', 'Nietzsche', 2, '1844-10-15', 'f_nietzsche@softuni.bg')

INSERT INTO Trips(RoomId, BookDate, ArrivalDate, ReturnDate, CancelDate)
	VALUES
		(101, '2015-04-12', '2015-04-14', '2015-04-20', '2015-02-02'),
		(102, '2015-07-07', '2015-07-15', '2015-07-22', '2015-04-29'),
		(103, '2013-07-17', '2013-07-23', '2013-07-24', NULL),
		(104, '2012-03-17', '2012-03-31', '2012-04-01', '2012-01-10'),
		(109, '2017-08-07', '2017-08-28', '2017-08-29', NULL)


------------------------------ 03. Update --------------------------------


UPDATE Rooms
SET Price += Price * 0.14
WHERE HotelId IN (5, 7, 9)

------------------------------- 04. Delete ------------------------------

DELETE FROM AccountsTrips
WHERE AccountId = 47

---------------------------- 05. EEE-Mails ----------------------------

SELECT a.FirstName,
	   a.LastName,
	   FORMAT(a.BirthDate, 'MM-dd-yyyy') AS [BirthDate],
	   c.[Name] AS [Hometown],
	   a.Email
	FROM Accounts AS a
JOIN Cities AS c ON a.CityId = c.Id
WHERE Email LIKE 'e%'
ORDER BY [Hometown]

------------------------- 06. City Statistics ------------------------

SELECT c.[Name] AS [City],
	   COUNT(h.Id) AS [Hotels]
	FROM Cities AS c
JOIN Hotels AS h ON h.CityId = c.Id
GROUP BY c.[Name]
ORDER BY [Hotels] DESC, [City]


------------------------- 07. Longest and Shortest Trips --------------


SELECT a.Id AS [AccountId],
	   CONCAT(a.FirstName, ' ', a.LastName) AS [FullName],
	   MAX( DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS [LongestTrip],
	   MIN( DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS [ShortestTrip]
	FROM Accounts AS a
JOIN AccountsTrips [at] ON a.Id = [at].AccountId 
JOIN Trips AS t ON [at].TripId = t.Id
WHERE a.MiddleName IS NULL AND t.CancelDate IS NULL
GROUP BY a.Id, a.FirstName, a.LastName
ORDER BY [LongestTrip] DESC, [ShortestTrip]


-------------------------- 08. Metropolis -------------------------------


SELECT TOP(10)
	   c.Id,
	   c.[Name] AS [City], 
	   c.CountryCode AS [Country],
	   COUNT(a.Id) AS [Accounts]
	   FROM Cities AS c
JOIN Accounts AS a ON c.Id = a.CityId
GROUP BY c.Id, c.[Name], c.CountryCode
ORDER BY [Accounts] DESC


---------------------- 09. Romantic Getaways ----------------------------


SELECT a.Id, a.Email, c.[Name] AS [City], COUNT(a.Email) AS [Trips] FROM Accounts AS a
JOIN AccountsTrips AS [at] ON a.Id = [at].AccountId
JOIN Trips AS t ON [at].TripId = t.Id
JOIN Rooms AS r ON t.RoomId = r.Id
JOIN Hotels AS h ON r.HotelId = h.Id
JOIN Cities AS c ON a.CityId = c.Id
WHERE a.CityId = h.CityId
GROUP BY a.Id, a.Email, c.[Name]
ORDER BY [Trips] DESC, a.Id


-------------------- 10. GDPR Violation ----------------------------------


SELECT t.Id,
	   CASE
		WHEN a.MiddleName IS NULL THEN CONCAT(a.FirstName, ' ', a.LastName)
	    ELSE CONCAT(a.FirstName, ' ', a.MiddleName, ' ', a.LastName) 
	   END AS [Full Name],
	   c1.[Name] AS [From],
	   c2.[Name] AS [To],
	   CASE	
		WHEN t.CancelDate IS NOT NULL THEN 'Canceled'
		ELSE CONCAT(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate), ' days')
	   END AS [Duration]	
	FROM Trips AS t
JOIN AccountsTrips AS [at] ON t.Id = [at].TripId
JOIN Accounts AS a ON [at].AccountId = a.Id
JOIN Cities AS c1 ON a.CityId = c1.Id
JOIN Rooms AS r ON t.RoomId = r.Id
JOIN Hotels AS h ON r.HotelId = h.Id
JOIN Cities AS c2 ON h.CityId = c2.Id
ORDER BY [Full Name], t.Id


----------------------------------- 11. Available Room -----------------------------------

SELECT TOP(1) r.Id FROM Trips AS t
JOIN Rooms AS r ON t.RoomId = r.Id
WHERE r.HotelId = 112 AND ('2011-12-17' NOT BETWEEN t.ArrivalDate AND t.ReturnDate) AND t.CancelDate IS NOT NULL AND Beds >= 2
ORDER BY Price DESC


GO

CREATE FUNCTION udf_GetAvailableRoom(@HotelId INT, @Date DATE, @People INT)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @result VARCHAR(MAX);
	DECLARE @message VARCHAR(MAX) = 'No rooms available'
	DECLARE @roomId INT = (SELECT TOP(1) r.Id FROM Trips AS t
						   JOIN Rooms AS r ON t.RoomId = r.Id
					       WHERE r.HotelId = @HotelId
						   AND (@Date NOT BETWEEN t.ArrivalDate AND t.ReturnDate)
						   AND Beds >= @People
						   ORDER BY r.Price DESC)
	IF(@roomId IS NULL)
	BEGIN
		SET @result = @message
	END
	ELSE	
	BEGIN
		DECLARE @roomType NVARCHAR(20) = (SELECT [Type] FROM Rooms
										  WHERE Id = @roomId)

		DECLARE @bedsCount INT = (SELECT Beds FROM Rooms
								  WHERE Id = @roomId)

		DECLARE @hotelBaseRate DECIMAL(15, 2) = (SELECT BaseRate FROM Hotels
												 WHERE Hotels.Id = @HotelId)

		DECLARE @roomPrice DECIMAL(15, 2) = (SELECT Price FROM Rooms
											 WHERE Id = @roomId)

		DECLARE @totalPrice DECIMAL(15, 2) = (@hotelBaseRate + @roomPrice) * @People

		SET @result = CONCAT('Room ', @roomId,': ' ,@roomType, ' ', '(', @bedsCount, ' beds) - $', CAST(@totalPrice AS varchar(50)))
	END

	RETURN @result
END

GO

SELECT dbo.udf_GetAvailableRoom(112, '2011-12-17', 2)
SELECT dbo.udf_GetAvailableRoom(94, '2015-07-26', 3)


--------------------------------- 12. Switch Room --------------------------------------------


SELECT * FROM Trips
SELECT * FROM Rooms
SELECT * FROM Hotels

GO

CREATE PROCEDURE usp_SwitchRoom(@TripId INT, @TargetRoomId INT)
AS
BEGIN
	DECLARE @hotelId INT = (SELECT HotelId FROM Trips AS t
							JOIN Rooms AS r ON t.RoomId = r.Id
							WHERE t.Id = @TripId)

	DECLARE @roomId INT = (SELECT r.Id FROM Hotels AS h
						   JOIN Rooms AS r ON h.Id = r.HotelId
						   WHERE r.HotelId = @hotelId AND r.Id = @TargetRoomId)

	IF(@roomId IS NULL)
	BEGIN
		RAISERROR ('Target room is in another hotel!', 16, 1)
	END

	DECLARE @bedCount INT = (SELECT Beds FROM Rooms
							 WHERE Id = @roomId)

	DECLARE @peopleCount INT = (SELECT * FROM Trips AS t
								JOIN AccountsTrips AS [at] ON t.Id = [at].AccountId
								WHERE Id = 10)
END

GO