CREATE DATABASE Minions

USE Minions

CREATE TABLE Minions(
	Id INT PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	Age INT
)
CREATE TABLE Towns(
	Id INT PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL
)
ALTER TABLE Minions
ADD TownId INT FOREIGN KEY REFERENCES Towns(Id)

INSERT INTO Towns(Id, [Name])
	VALUES
		(1, 'Sofia'),
		(2, 'Plovdiv'),
		(3, 'Varna')

SELECT * FROM Towns

INSERT INTO Minions(Id, [Name], Age, TownId)
	VALUES
		(1, 'Kevin', 22, 1),
		(2, 'Bob', 15, 3),
		(3, 'Steward', NULL, 2)

SELECT * FROM Minions

TRUNCATE TABLE Minions

SELECT * FROM Minions

DROP TABLE Minions
DROP TABLE Towns

CREATE TABLE Users(
	Id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	Username VARCHAR(30) UNIQUE NOT NULL,
	[Password] VARCHAR(26) NOT NULL,
	ProfilePicture VARBINARY(MAX)
	CHECK(DATALENGTH(ProfilePicture) <= 900 * 1024),
	LastLoginTime DATETIME2 NOT NULL,
	IsDeleted BIT NOT NULL
)

INSERT INTO Users(Username, [Password], LastLoginTime, IsDeleted)
	VALUES
		('Pesho0', '123456', '05.19.2020', 0),
		('Pesho1', '123456', '05.19.2020', 1),
		('Pesho2', '123456', '05.19.2020', 0),
		('Pesho3', '123456', '05.19.2020', 0),
		('Pesho4', '123456', '05.19.2020', 1)

SELECT * FROM Users

TRUNCATE TABLE Users
DROP TABLE Users

ALTER TABLE Users
DROP CONSTRAINT [PK__Users__3214EC07F92DE817]

ALTER TABLE Users
ADD CONSTRAINT PK_Users_CompositeIdUsername
PRIMARY KEY (Id, Username)

ALTER TABLE Users
ADD CONSTRAINT CK_Users_PasswordLength
CHECK(LEN([Password]) >= 5)

ALTER TABLE Users
ADD CONSTRAINT DF_Users_LastLoginTime
DEFAULT GETDATE() FOR LastLoginTime

ALTER TABLE Users
DROP CONSTRAINT PK_Users_CompositeIdUsername

ALTER TABLE Users
ADD CONSTRAINT PK_Users_Id
PRIMARY KEY(Id)

ALTER TABLE Users
ADD CONSTRAINT CK_Users_UsernameLength
CHECK(LEN(Username) >= 3)

CREATE TABLE People(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(200) NOT NULL,
	Picture VARBINARY(MAX)
	CHECK(DATALENGTH(Picture) <= 2000 * 1024),
	Height DECIMAL(5,2),
	[Weight] DECIMAL(5,2),
	Gender CHAR(1) NOT NULL
	CHECK((Gender) = 'm' OR (Gender) = 'f'),
	Birthdate DATE NOT NULL,
	Biography NVARCHAR(MAX)
)
--DROP TABLE People
INSERT INTO People([Name], Height, [Weight], Gender, Birthdate)
	VALUES
		('Pesho', 1.67, 67.45, 'm', '02.15.1987'),
		('Gosho', 1.70, 89.23, 'm', '06.05.1985'),
		('Penka', 1.65, 56.20, 'f', '12.10.1990'),
		('Stanka', 1.73, 53.45, 'f', '10.12.1991'),
		('Pesko', 1.89, 93.18, 'm', '03.08.1982')

SELECT * FROM People

CREATE DATABASE SoftUni

USE SoftUni

CREATE TABLE Towns(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Addresses(
	Id INT PRIMARY KEY IDENTITY,
	AddressText NVARCHAR(100) NOT NULL,
	TownId INT FOREIGN KEY REFERENCES Towns(Id) NOT NULL
)

CREATE TABLE Departments(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	MiddleName NVARCHAR(50),
	LastName NVARCHAR(50) NOT NULL,
	JobTitle NVARCHAR(50) NOT NULL,
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL,
	HireDate DATE NOT NULL,
	Salary DECIMAL(7,2) NOT NULL,
	AddressId INT FOREIGN KEY REFERENCES Addresses(Id)
)

INSERT INTO Towns([Name])
	VALUES
		('Sofia'),
		('Plvdiv'),
		('Varna'),
		('Burgas')

INSERT INTO Departments([Name])
	VALUES
		('Engineering'),
		('Sales'),
		('Marketing'),
		('Software Development'),
		('Quality Assurance')

INSERT INTO Employees(FirstName, MiddleName, LastName, JobTitle, DepartmentId, HireDate, Salary)
	VALUES
		('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '02/01/2013', 3500.00),
		('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '03/02/2004', 4000.00),
		('Maria', 'Petrova', 'Ivanov', 'Intern', 5, '08/28/2016', 525.25),
		('Georgi', 'Teziev', 'Ivanov', 'CEO', 2, '12/09/2007', 3000.00),
		('Peter', 'Pan', 'Pan', 'Intern', 3, '08/28/2013', 599.88)

SELECT [Name] FROM Towns
ORDER BY [Name] ASC
SELECT [Name] FROM Departments
ORDER BY [Name] ASC
SELECT FirstName, LastName, JobTitle, Salary FROM Employees
ORDER BY Salary DESC

UPDATE Employees
SET Salary += Salary * 0.1;

SELECT Salary FROM Employees

CREATE DATABASE Movies

USE	Movies

CREATE TABLE Directors(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	DirectorName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)
CREATE TABLE Genres(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	GenreName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	CategoryName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE Movies(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Title NVARCHAR(50) NOT NULL,
	DirectorId INT FOREIGN KEY REFERENCES Directors(Id) NOT NULL,
	CopyrightYear DATE NOT NULL,
	[Length] INT NOT NULL,
	GenreId INT FOREIGN KEY REFERENCES Genres(Id) NOT NULL,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	Rating INT NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO Directors(DirectorName)
	VALUES
		('Gosho'),
		('Pesho'),
		('Mosho'),
		('Tosho'),
		('Stamat')

INSERT INTO Genres(GenreName)
	VALUES
		('Goshka'),
		('Peshka'),
		('Moshka'),
		('Toshka'),
		('Stamatka')

INSERT INTO Categories(CategoryName)
	VALUES
		('Action'),
		('Horror'),
		('Crime'),
		('Comedy'),
		('BG')

INSERT INTO Movies(Title, DirectorId, CopyrightYear, [Length], GenreId, CategoryId, Rating)
	VALUES
		('Movie1', 1, '05.05.2020', 193, 1, 1, 10),
		('Movie2', 2, '05.05.2020', 167, 2, 2, 8),
		('Movie3', 3, '05.05.2020', 178, 3, 3, 5),
		('Movie4', 4, '05.05.2020', 165, 4, 4, 8),
		('Movie5', 5, '05.05.2020', 123, 5, 5, 3)

SELECT * FROM Movies

CREATE DATABASE Hotel

USE Hotel
DROP DATABASE Hotel
CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Title NVARCHAR(50),
	Notes NVARCHAR(MAX)
)
INSERT INTO Employees(FirstName, LastName)
	VALUES
		('Pesho', 'Petrov'),
		('Gosho', 'Goshov'),
		('Tosho', 'Toshev')
CREATE TABLE Customers(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	AccountNumber BIGINT,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	PhoneNumber INT NOT NULL,
	EmergencyName NVARCHAR(50),
	EmergencyNumber INT,
	Notes NVARCHAR(MAX)
)
INSERT INTO Customers(FirstName, LastName, PhoneNumber)
	VALUES
		('Misho', 'Mishev', 0987765465),
		('Penka', 'Pencheva', 0987765465),
		('Mishka', 'Mishkova', 0987765465)

CREATE TABLE RoomStatus(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	RoomStatus NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)
INSERT INTO RoomStatus(RoomStatus)
	VALUES
		('EMPTY'),
		('EMPTY'),
		('EMPTY')

CREATE TABLE RoomTypes(
	RoomType NVARCHAR(50) PRIMARY KEY NOT NULL,
	Notes NVARCHAR(MAX)
)
INSERT INTO RoomTypes(RoomType)
	VALUES
		('Apartment'),
		('President Apartment'),
		('Small Apartment')

CREATE TABLE BedTypes(
	BedType NVARCHAR(50) PRIMARY KEY NOT NULL,
	Notes NVARCHAR(MAX)
)
INSERT INTO BedTypes(BedType)
	VALUES
		('Single'),
		('Double'),
		('Water Bed')

CREATE TABLE Rooms(
	RoomNumber INT PRIMARY KEY IDENTITY NOT NULL,
	RoomType NVARCHAR(50) FOREIGN KEY REFERENCES RoomTypes(RoomType),
	BedType NVARCHAR(50) FOREIGN KEY REFERENCES BedTypes(BedType),
	Rate INT NOT NULL,
	RoomStatus NVARCHAR(50),
	Notes NVARCHAR(MAX)
)
INSERT INTO Rooms(Rate, RoomStatus)
	VALUES
		(10, 'empty'),
		(12, 'empty'),
		(8, 'empty')
CREATE TABLE Payments(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
	PaymentDate DATE NOT NULL,
	AccountNumber BIGINT,
	FirstDateOccupied DATE,
	LastDateOccupied DATE,
	TotalDays AS DATEDIFF(DAY, FirstDateOccupied, LastDateOccupied),
	AmountCharged DECIMAL(14,2),
	TaxRate DECIMAL(8,2),
	TaxAmount DECIMAL(8,2),
	PaymentTotal DECIMAL(15,2),
	Notes NVARCHAR(MAX)
)
--DROP TABLE Payments
INSERT INTO Payments(EmployeeId, PaymentDate, TaxRate)
	VALUES
		(1, '05.05.2020', 120),
		(2, '05.05.2020', 150),
		(3, '05.05.2020', 110)

CREATE TABLE Occupancies(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
	DateOccupied DATE NOT NULL,
	AccountNumber BIGINT,
	RoomNumber INT FOREIGN KEY REFERENCES Rooms(RoomNumber),
	RateApplied INT,
	PhoneCharge DECIMAL(6,2),
	Notes NVARCHAR(MAX)
)
INSERT INTO Occupancies(EmployeeId, DateOccupied, RoomNumber)
	VALUES
		(1, '10.03.2020', 2),
		(2, '10.11.2020', 1),
		(3, '10.24.2020', 3)
UPDATE Payments
SET TaxRate -= TaxRate * 0.03;
SELECT TaxRate FROM Payments

SELECT * FROM Occupancies
TRUNCATE TABLE Occupancies

CREATE DATABASE CarRental

USE CarRental

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	CategoryName VARCHAR(200) NOT NULL,
	DailyRate INT,
	WeeklyRate INT,
	MonthlyRate INT,
	WeekendRate INT
)
INSERT INTO Categories(CategoryName)
	VALUES
		('Family Car'),
		('Sport Car'),
		('Mini Van')

CREATE TABLE Cars(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	PlateNumber INT NOT NULL,
	Manufacturer VARCHAR(100) NOT NULL,
	Model VARCHAR(100),
	CarYear INT,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id),
	Doors INT,
	Picture VARBINARY(MAX)
	CHECK(DATALENGTH(Picture) <= 2000 * 1024),
	Condition VARCHAR(100),
	Available BIT NOT NULL
)
INSERT INTO Cars(PlateNumber, Manufacturer, CategoryId, Available)
	VALUES
		(1234, 'Ford', 1, 0),
		(9876, 'BMW', 2, 1),
		(6754, 'Trabant', 3, 1)

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Title VARCHAR(100),
	Notes VARCHAR(MAX)
)
INSERT INTO Employees(FirstName, LastName)
	VALUES
		('Pesho', 'Peshov'),
		('Gosho', 'Goshev'),		
		('Misho', 'Mishev')

CREATE TABLE Customers(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	DriverLicenceNumber BIGINT NOT NULL,
	FullName VARCHAR(200) NOT NULL,
	[Address] VARCHAR(200),
	City VARCHAR(200),
	ZIPCode INT,
	Notes VARCHAR(MAX)
)
INSERT INTO Customers(DriverLicenceNumber, FullName)
	VALUES
		(123456, 'Gosho Peshev'),
		(0987654, 'Misho Goshev'),
		(1230987, 'Pesho Mishev')

CREATE TABLE RentalOrders(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
	CustomerId INT FOREIGN KEY REFERENCES Customers(Id),
	CarId INT FOREIGN KEY REFERENCES Cars(Id),
	TankLevel INT,
	KilometrageStart INT,
	KilometrageEnd INT,
	TotalKilometrage INT,
	StartDate DATE,
	EndDate DATE,
	TotalDays AS DATEDIFF(DAY, StartDate, EndDate),
	RateApplied INT,
	TaxRate DECIMAL(7,2),
	OrderStatus VARCHAR(50),
	Notes VARCHAR(MAX)
)
INSERT INTO RentalOrders(EmployeeId, CustomerId, CarId)
	VALUES
		(1, 1, 1),
		(2, 2, 2),
		(3, 3, 3)