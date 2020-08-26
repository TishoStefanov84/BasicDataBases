USE SoftUni

GO

CREATE PROCEDURE usp_GetEmployeesSalaryAbove35000
AS
BEGIN
	SELECT FirstName, LastName FROM Employees
	WHERE Salary > 35000
END

EXEC usp_GetEmployeesSalaryAbove35000

GO

CREATE PROCEDURE usp_GetEmployeesSalaryAboveNumber (@salary DECIMAL(18, 4))
AS
BEGIN
	SELECT FirstName, LastName FROM Employees
	WHERE Salary >= @salary
END

EXEC usp_GetEmployeesSalaryAboveNumber 48100

GO

CREATE PROCEDURE usp_GetTownsStartingWith(@string VARCHAR(MAX))
AS
BEGIN
		SELECT [Name] FROM Towns
		WHERE LEFT([Name], LEN(@string)) = @string
END

EXEC usp_GetTownsStartingWith 'so'

GO

CREATE PROCEDURE usp_GetEmployeesFromTown(@town VARCHAR(50))
AS
BEGIN
	SELECT FirstName, LastName FROM Employees AS e
	JOIN Addresses AS a ON e.AddressID = a.AddressID
	JOIN Towns AS t ON a.TownID = t.TownID
	WHERE t.[Name] = @town
END

EXEC usp_GetEmployeesFromTown 'Sofia'

GO

CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4))
RETURNS VARCHAR(7)
AS
BEGIN
	DECLARE @result VARCHAR(7)
	IF(@salary < 30000)
	BEGIN
	   SET @result = 'Low'
	END
	ELSE IF(@salary >= 30000 AND @salary <= 50000)
	BEGIN
		SET @result = 'Average'
	END
	ELSE 
	BEGIN
		SET @result = 'High'
	END

	RETURN @result
END

GO

SELECT Salary,  dbo.ufn_GetSalaryLevel(Salary) AS [SalaryLevel] FROM Employees

GO

CREATE PROCEDURE usp_EmployeesBySalaryLevel(@SalaryLevel VARCHAR(7))
AS
BEGIN
	SELECT FirstName, LastName FROM Employees
	WHERE dbo.ufn_GetSalaryLevel(Salary) = @SalaryLevel
END

EXEC usp_EmployeesBySalaryLevel 'High'

GO

CREATE FUNCTION ufn_IsWordComprised(@setOfLetters VARCHAR(MAX), @word VARCHAR(50))
RETURNS BIT
AS
BEGIN
	DECLARE @result BIT = 1;
	DECLARE @count INT = 1;

	WHILE(@count <= LEN(@word))
	BEGIN
		DECLARE @letter CHAR(1) = SUBSTRING(@word, @count, 1)
		IF(CHARINDEX(@letter, @setOfLetters) <= 0)
		BEGIN
			SET @result = 0;
			BREAK;
		END
		SET @count += 1;
	END
	RETURN @result
END

GO

SELECT [dbo].[ufn_IsWordComprised]('pppp', 'Guy')

GO

CREATE PROCEDURE usp_DeleteEmployeesFromDepartment (@departmentId INT)
AS
BEGIN

	DELETE FROM EmployeesProjects
	WHERE EmployeeID IN (
						SELECT EmployeeID FROM Employees
						WHERE DepartmentID = @departmentId
						)

	UPDATE Employees
	SET ManagerID = NULL
	WHERE ManagerID IN (
					    SELECT EmployeeID FROM Employees
						WHERE DepartmentID = @departmentId
						)

	ALTER TABLE Departments
	ALTER COLUMN ManagerID INT

	UPDATE Departments
	SET ManagerID = NULL
	WHERE ManagerID IN (
					    SELECT EmployeeID FROM Employees
						WHERE DepartmentID = @departmentId
						)

    DELETE FROM Employees
	WHERE DepartmentID = @departmentId

	DELETE FROM Departments
	WHERE DepartmentID = @departmentId

	SELECT COUNT(*) FROM Employees
	WHERE DepartmentID = @departmentId
END

GO

USE Bank

GO

CREATE PROCEDURE usp_GetHoldersFullName
AS
BEGIN
	SELECT CONCAT(FirstName, ' ', LastName) AS [Full Name] FROM AccountHolders
END

EXEC usp_GetHoldersFullName

GO

CREATE PROCEDURE usp_GetHoldersWithBalanceHigherThan(@minBalance DECIMAL(18, 4))
AS
BEGIN
	SELECT FirstName, LastName FROM AccountHolders AS ah
	JOIN Accounts AS a ON ah.Id = a.AccountHolderId
	GROUP BY FirstName, LastName
	HAVING SUM(Balance) > @minBalance
	ORDER BY FirstName, LastName
END

EXEC usp_GetHoldersWithBalanceHigherThan 20000

GO

CREATE FUNCTION ufn_CalculateFutureValue(@sum DECIMAL(18, 4), @yearlyInterestRate FLOAT, @yearsCount INT)
RETURNS DECIMAL(18, 4)
AS
BEGIN
	DECLARE @futureValue DECIMAL(18, 4)
	SET @futureValue = @sum * (POWER((1 + @yearlyInterestRate), @yearsCount))
	RETURN @futureValue
END

GO

SELECT dbo.ufn_CalculateFutureValue (1000, 0.1, 5)

GO

CREATE PROCEDURE usp_CalculateFutureValueForAccount(@accountId INT, @interestRate FLOAT)
AS
BEGIN
	SELECT ah.Id AS [Account Id],
		   ah.FirstName AS [First Name],
		   ah.LastName AS [Last Name],
		   a.Balance AS [Current Balance],
		   dbo.ufn_CalculateFutureValue(a.Balance, @interestRate, 5) AS [Balance in 5 years]
	FROM AccountHolders AS ah
	JOIN Accounts AS a ON ah.Id = a.AccountHolderId
	WHERE a.Id = @accountId
END

GO

EXEC usp_CalculateFutureValueForAccount 1, 0.1

GO

USE Diablo

GO

CREATE FUNCTION ufn_CashInUsersGames(@gameName NVARCHAR(50))
RETURNS TABLE
AS
RETURN
SELECT SUM(Cash) AS [SumCash] 
		FROM
		(
		SELECT g.[Name], 
			   ug.Cash,
			   ROW_NUMBER()
			   OVER(PARTITION BY g.[Name] ORDER BY ug.Cash DESC) AS [RowNum]
			   FROM Games AS g
		JOIN UsersGames AS ug ON g.Id = ug.GameId
		WHERE g.[Name] = @gameName
		) AS [RowNumQuery]
WHERE [RowNum] % 2 <> 0

SELECT * FROM dbo.ufn_CashInUsersGames ('Love in a mist')