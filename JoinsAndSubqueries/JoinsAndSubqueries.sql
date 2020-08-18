USE SoftUni

SELECT TOP(5) e.EmployeeID, e.JobTitle, e.AddressID, a.AddressText 
	FROM Employees AS e
JOIN Addresses AS a ON e.AddressID = a.AddressID
ORDER BY e.AddressID

SELECT TOP(50) e.FirstName, e.LastName, t.[Name], a.AddressText FROM Employees AS e
JOIN Addresses AS a ON e.AddressID = a.AddressID
JOIN Towns AS t ON a.TownID = t.TownID
ORDER BY e.FirstName, e.LastName

SELECT e.EmployeeID, e.FirstName, e.LastName, d.[Name] AS [DepartmentName] 
	FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
WHERE d.[Name] = 'Sales'
ORDER BY e.EmployeeID

SELECT TOP(5) e.EmployeeID, e.FirstName, e.Salary, d.[Name] AS [DepartmentName] 
	FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
WHERE e.Salary > 15000
ORDER BY d.DepartmentID

SELECT TOP(3) e.EmployeeID, e.FirstName 
	FROM Employees AS e
LEFT JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
LEFT JOIN Projects AS p ON ep.ProjectID = p.ProjectID
WHERE ep.ProjectID IS NULL
ORDER BY e.EmployeeID

SELECT e.FirstName, e.LastName, e.HireDate, d.[Name] AS [DeptName] 
	FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
WHERE e.HireDate > '01.01.1999' AND d.[Name] IN('Sales', 'Finance')
ORDER BY e.HireDate

SELECT TOP(5) e.EmployeeID, e.FirstName, p.[Name] AS [ProjectName] 
	FROM Employees AS e
JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p ON ep.ProjectID = p.ProjectID
WHERE p.StartDate > '08.13.2002' AND p.EndDate IS NULL
ORDER BY e.EmployeeID

SELECT e.EmployeeID, e.FirstName, 
	CASE
		WHEN DATEPART(YEAR, p.StartDate) < 2005 THEN p.[Name]
		ELSE NULL
	END AS [ProjectName]
	FROM Employees AS e
JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p ON ep.ProjectID = p.ProjectID
WHERE e.EmployeeID = 24

SELECT e1.EmployeeID, e1.FirstName, e1.ManagerID, e2.FirstName AS [ManagerName]
	FROM Employees AS e1
JOIN Employees AS e2 ON e1.ManagerID = e2.EmployeeID
WHERE e1.ManagerID IN(3,7)
ORDER BY e1.EmployeeID

SELECT TOP(50) e1.EmployeeID, 
	CONCAT(e1.FirstName, ' ', e1.LastName) AS [EmployeeName],
	CONCAT(e2.FirstName, ' ', e2.LastName) AS [ManagerName],
	d.[Name] AS [DepartmentName]
	FROM Employees AS e1
JOIN Employees AS e2 ON e1.ManagerID = e2.EmployeeID
JOIN Departments AS d ON e1.DepartmentID = d.DepartmentID
ORDER BY e1.EmployeeID

SELECT MIN([AverageSalary])  
	FROM
	(SELECT DepartmentID,
		AVG(Salary) AS [AverageSalary]
		FROM Employees
GROUP BY DepartmentID) AS [MinAverageSalary]

USE [Geography]

SELECT c.CountryCode, m.MountainRange, p.PeakName, p.Elevation 
	FROM Countries AS c
JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
JOIN Mountains AS m ON mc.MountainId = m.Id
JOIN Peaks AS p ON m.Id = p.MountainId
WHERE c.CountryCode = 'BG' AND p.Elevation > 2835
ORDER BY p.Elevation DESC

SELECT CountryCode, COUNT(MountainId) AS [MountainRanges]
	FROM MountainsCountries
WHERE CountryCode IN ('US', 'RU', 'BG')
GROUP BY CountryCode


SELECT TOP(5) c.CountryName, r.RiverName FROM Countries AS c
LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
LEFT JOIN Rivers AS r ON cr.RiverId = r.Id
WHERE c.ContinentCode = 'AF'
ORDER BY c.CountryName

SELECT ContinentCode,
	   CurrencyCode,
	   [CurrencyCount] AS [CurrencyUsage]
			FROM
				(SELECT *,
						DENSE_RANK() 
						OVER(PARTITION BY ContinentCode ORDER BY [CurrencyCount] DESC) AS [RANK]
						FROM
							(SELECT ContinentCode, 
            					    CurrencyCode, 
            					    COUNT(*) AS [CurrencyCount]
							FROM Countries
							GROUP BY ContinentCode, CurrencyCode) AS [CurrencyCountQuery]
				WHERE CurrencyCount > 1) AS [CurrencyRankQuery]
WHERE [RANK] = 1

SELECT COUNT(*) AS [Count] 
	FROM
		(SELECT c.CountryCode, COUNT(mc.MountainId) AS [MountainCount] FROM Countries AS c
		LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
		GROUP BY c.CountryCode) AS [MountainCountQuery]
WHERE [MountainCount] = 0


SELECT TOP(5) c.CountryName, 
	   MAX(p.Elevation) AS [HighestPeakElevation], 
	   MAX(r.[Length]) AS [LongestRiverLength] 
	   FROM Countries AS c
LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
LEFT JOIN Rivers AS r ON cr.RiverId = r.Id
LEFT JOIN MountainsCountries mc ON c.CountryCode = mc.CountryCode
LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
LEFT JOIN Peaks AS p ON m.Id = p.MountainId
GROUP BY c.CountryName
ORDER BY [HighestPeakElevation] DESC, [LongestRiverLength] DESC, c.CountryName


SELECT TOP(5) [Country],
		CASE
			WHEN PeakName IS NULL THEN '(no highest peak)'
			ELSE PeakName
		END AS [Highest Peak Name],
		CASE
			WHEN Elevation IS NULL THEN 0
			ELSE Elevation
		END AS [Highest Peak Elevation],
		CASE 
			WHEN MountainRange IS NULL THEN '(no mountain)'
			ELSE MountainRange
		END AS [Mountain]
FROM
(SELECT *,
		DENSE_RANK()
		OVER(PARTITION BY [Country] ORDER BY Elevation) AS [PeakRank]
				FROM
				(SELECT c.CountryName AS [Country],
					   p.PeakName,
					   p.Elevation,
					   m.MountainRange
					FROM Countries AS c
				LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
				LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
				LEFT JOIN Peaks AS p ON m.Id = p.MountainId) AS [FullInfoQuery]) AS [PeakQuery]
WHERE [PeakRank] = 1
ORDER BY [Country], [Highest Peak Name]