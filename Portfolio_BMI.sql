-- Exploring the Data

SELECT *
FROM PortfolioBMI.[dbo].[BMI MEN]

SELECT Entity,Code, Count(Year) 
FROM [PortfolioBMI].[dbo].[BMIFemale] 
Group by Entity,Code

SELECT *
FROM [PortfolioBMI].[dbo].[children_overweight]
ORDER BY Year

SELECT *
FROM [PortfolioBMI].[dbo].[Caloric intake]

SELECT *
FROM [PortfolioBMI].[dbo].[GDP]
ORDER BY Year

SELECT count(Year)
FROM [PortfolioBMI].[dbo].['global-food$']
Where Year>=1995 
GROUP BY Year
Having Count(Country)=25

SELECT *
FROM [PortfolioBMI].dbo.['death-rate-from-obesity$']
ORDER BY Year desc

-- The Global-food table need to be fixed some issues with missing values in the table to fit my timeframe. 
-- Before dropping data, I want a duplicate
SELECT * INTO Food 
FROM dbo.['global-food$']

--Omiting Countries that do not have the full scale of data avaliable (Such as the USSR, which doesn't exist anymore)
DELETE FROM Food 
WHERE Country IN (
SELECT Country FROM Food GROUP BY Country HAVING COUNT(Country)!=25);

--Exploring more:
SELECT *
FROM PortfolioBMI.[dbo].[Minimum_calories]

SELECT *
FROM PortfolioBMI.[dbo].[Percent_death_obesity]
ORDER BY Year

--Aggregating and joining data:
-- I wanted to join all relevant databases to answer the caloric consumption and deaths
SELECT 
a.Country,
a.Year,
a.Population,
a.[Food supply (kcal per capita per day)] AS Daily_Calories ,
a.[Food supply (Protein g per capita per day)]*4 AS Daily_Protein_G_Kcl,
a.[Food supply (Fat g per capita per day)]*9 AS Daily_Fat_Kcl,
a.[Food supply (kcal per capita per day)] - (a.[Food supply (Protein g per capita per day)]*4 + a.[Food supply (Fat g per capita per day)]*9) AS Daily_Carb_Kcl,
(a.[Food supply (Protein g per capita per day)]*4 / a.[Food supply (kcal per capita per day)])*100 AS Percent_Protein,
(a.[Food supply (Fat g per capita per day)]*9 / a.[Food supply (kcal per capita per day)])*100 AS Percent_Fat,
((a.[Food supply (kcal per capita per day)] - (a.[Food supply (Protein g per capita per day)]*4 + a.[Food supply (Fat g per capita per day)]*9)) / a.[Food supply (kcal per capita per day)])*100 AS Percent_Carb,
c.[Deaths - Cause: All causes - Risk: High body-mass index - Sex: B] AS Death_rate_Per_100K
INTO Food_Full
FROM dbo.Food a
INNER JOIN PortfolioBMI.dbo.['death-rate-from-obesity$'] c ON
a.[Country]=c.[Entity] AND a.[Year]=c.[Year]
WHERE c.Year>=1995

--Checking the results
SELECT *, [Daily_Calories]-[Minimum_intake_Kcl] AS Extra_Intake
FROM PortfolioBMI.[dbo].[Food_Full]

-- Joining BMI Related data
SELECT m.*,
f.[Entity] AS Ent,
f.[Code] AS CD,
f.[Year] AS YR,
f.[Mean BMI (female)],
pl.[Population]
INTO Joined_BMI
FROM PortfolioBMI.[dbo].[BMI MEN] m
INNER JOIN PortfolioBMI.[dbo].[BMIFemale] f
ON m.[Entity] = f.[Entity] and m.[Year]=f.[Year]
Join PortfolioBMI.[dbo].[Food_Full] pl
ON m.[Entity]=pl.[Country] and m.[Year]=pl.[Year]
WHERE m.[Mean BMI (male)] IS NOT NULL and f.[Year] >1978 and pl.[Year]>1978

--Checking the data
SELECT *
FROM PortfolioBMI.dbo.Joined_BMI


--Measuring the difference in GDP and Caloric intake within a 10 year period:
SELECT d.Country,d.Year, d.Total_change_in_Calories, t.Total_Change_in_GDP, b.DIF_DED
INTO Difference_tables
FROM (
	SELECT f.*,
	Daily_Calories- LAG (Daily_Calories, 10,0) OVER(PARTITION BY Country ORDER BY Year ASC) AS Total_change_in_Calories
	FROM Food_Full AS f
	WHERE f.Year>2008) AS d
Join (
	SELECT g.*, 
	g.[GDP per capita, PPP (constant 2017 international $)] - LAG (g.[GDP per capita, PPP (constant 2017 international $)],10,0) OVER (PARTITION BY g.Entity ORDER BY Year ASC) AS Total_Change_in_GDP
	FROM PortfolioBMI.dbo.GDP AS g
	WHERE G.Year<2020 AND Year >2008) as t
	ON d.Year=t.Year AND d.Country=t.Entity
JOIN(
	SELECT a.*, a.[Percent] - LAG (a.[Percent],10,0) OVER (PARTITION BY Entity ORDER BY Year ASC) AS DIF_DED
	FROM PortfolioBMI.dbo.Percent_death_obesity as a
	WHERE a.Year >2008) as b
	ON b.Entity=d.Country AND b.Year=d.Year
WHERE t.[GDP per capita, PPP (constant 2017 international $)]!=t.Total_Change_in_GDP AND d.Total_change_in_Calories!= d.Daily_Calories AND  b.[Percent] != b.DIF_DED

select * from Difference_tables

Drop table Difference_tables
-- Ranking for further exploration
SELECT *, RANK() OVER(PARTITION BY Year ORDER BY Death_rate_Per_100K DESC) AS Death_rate_Year_Ranking
FROM Food_Full AS f
WHERE Year = 2019

Select *
FROM(
SELECT a.*, a.[Percent] - LAG (a.[Percent],10,0) OVER (PARTITION BY Entity ORDER BY Year ASC) AS DIF_DED
FROM PortfolioBMI.dbo.Percent_death_obesity as a
WHERE a.Year >2008) as b
Where b.[Percent] != b.DIF_DED