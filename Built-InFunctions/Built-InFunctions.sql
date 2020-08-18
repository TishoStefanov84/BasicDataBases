USE [SoftUni]

SELECT FirstName, LastName FROM Employees
WHERE FirstName LIKE 'SA%'

SELECT FirstName, LastName FROM Employees
WHERE LastName LIKE '%EI%'

SELECT FirstName FROM Employees
WHERE DepartmentID IN (3, 10) AND
	DATEPART(YEAR, HireDate) BETWEEN 1995 AND 2005

SELECT FirstName, LastName FROM Employees
WHERE JobTitle NOT LIKE '%engineer%'

SELECT [Name] FROM Towns
WHERE LEN([Name]) IN (5,6)
ORDER BY [Name]

SELECT * FROM Towns
WHERE [Name] LIKE '[MKBE]%'
ORDER BY [Name]

SELECT * FROM Towns
WHERE [Name] LIKE '[^RBD]%'
ORDER BY [Name]

CREATE VIEW v_EmployeesHiredAfter2000
AS
(SELECT FirstName, LastName FROM Employees
WHERE  DATEPART(YEAR, HireDate) > 2000)

SELECT * FROM v_EmployeesHiredAfter2000

SELECT FirstName, LastName FROM Employees
WHERE LEN(LastName) = 5


SELECT EmployeeID, FirstName, LastName, Salary,
	DENSE_RANK() 
	OVER(PARTITION BY Salary
	ORDER BY EmployeeID)
	AS [Rank] 
	FROM Employees
	WHERE Salary BETWEEN 10000 AND 50000
	ORDER BY Salary DESC 

SELECT * FROM
(SELECT EmployeeID, FirstName, LastName, Salary,
	DENSE_RANK() 
	OVER(PARTITION BY Salary
	ORDER BY EmployeeID)
	AS [Rank] 
	FROM Employees
	WHERE Salary BETWEEN 10000 AND 50000)
	AS [Rank Table]
WHERE [Rank] = 2
ORDER BY Salary DESC

USE [Geography]

SELECT 
	CountryName AS [Country Name], 
	IsoCode AS [ISO Code] FROM Countries
WHERE CountryName LIKE '%a%a%a%'
ORDER BY IsoCode

SELECT p.PeakName, r.RiverName,
	LOWER
	(CONCAT(p.PeakName, 
	SUBSTRING(r.RiverName, 2, LEN(r.RiverName) - 1))) 
	AS [Mix]
FROM Peaks 
	AS p, Rivers 
	AS r
WHERE RIGHT(p.PeakName, 1) = LEFT(r.RiverName, 1)
ORDER BY [Mix]

USE [Diablo]

SELECT TOP (50) [Name], 
	FORMAT([Start], 'yyyy-MM-dd') AS [Start]
FROM Games
WHERE DATEPART(YEAR, [Start]) IN(2011, 2012)
ORDER BY [Start], [Name]


SELECT Username, 
	SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email) - CHARINDEX('@', Email)) AS [Email Provider]
FROM Users
ORDER BY [Email Provider], Username


SELECT Username, IpAddress AS [IP Address] FROM Users
WHERE IpAddress LIKE '___.1_%._%.___' 
ORDER BY Username

SELECT [Name],
	CASE
	WHEN DATEPART(HOUR, [Start]) BETWEEN 0 AND 11 THEN 'Morning'
	WHEN DATEPART(HOUR, [Start]) BETWEEN 12 AND 17 THEN 'Afternoon'
	ELSE 'Evening'
	END AS [Part of the Day],
	CASE
	WHEN Duration <= 3 THEN 'Extra Short'
	WHEN Duration BETWEEN 4 AND 6 THEN 'Short'
	WHEN Duration > 6 THEN 'Long'
	ELSE 'Extra Long'
	END AS [Duration]
FROM Games
ORDER BY [Name], [Duration], [Part of the Day]

USE OnlineStore

CREATE TABLE OrdersTable(
	Id INT PRIMARY KEY IDENTITY,
	ProductName VARCHAR(50) NOT NULL,
	OrderDate DATETIME2 NOT NULL
)

INSERT INTO OrdersTable(ProductName, OrderDate)
	VALUES
		('Butter', '2016-09-19 00:00:00.000'),
		('Milk', '2016-09-30 00:00:00.000'),
		('Cheese', '2016-09-04 00:00:00.000'),
		('Bread', '2015-12-20 00:00:00.000'),
		('Tomatoes', '2015-12-30 00:00:00.000')

SELECT ProductName, OrderDate,
	DATEADD(DAY, 3, OrderDate) AS [Pay Due],
	DATEADD(MONTH , 1, OrderDate) AS [Deliver Due]
FROM OrdersTable

