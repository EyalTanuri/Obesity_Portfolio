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

--Dropping
DELETE FROM Food 
WHERE Country IN (
SELECT Country FROM Food GROUP BY Country HAVING COUNT(Country)!=25);

SELECT *
FROM PortfolioBMI.[dbo].[Minimum_calories]

SELECT *
FROM PortfolioBMI.[dbo].[Percent_death_obesity]
ORDER BY Year

--Aggregating and joining data:

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

--Cheking
SELECT *, [Daily_Calories]-[Minimum_intake_Kcl] AS Extra_Intake
FROM PortfolioBMI.[dbo].[Food_Full]

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
WHERE  [Population] Is NULL

CREATE VIEW Food_GDP_BMI AS
SELECT a.*, b.[Mean BMI (female)],b.[Mean BMI (male)]
FROM PortfolioBMI.[dbo].[Food_Full] a
JOIN PortfolioBMI.[dbo].[Joined_BMI] b ON
a.[Country]=b.[Entity] AND a.[Year]=b.[Year]

SELECT *
FROM PortfolioBMI.[dbo].[Percent_death_obesity]

--I want to make info boxs to indicate change:
CREATE TABLE Change_Blocks (
Year NUMERIC,
Country VARCHAR(255),
Calories NUMERIC,
GDP NUMERIC,
)

INSERT INTO dbo.Change_blocks(Year, Country, Calories)
select Year, Country, Daily_Calories  from Food_Full where Year=1995 or Year=2019

UPDATE dbo.Change_Blocks 
SET GDP = b.[GDP per capita, PPP (constant 2017 international $)]
From dbo.Change_Blocks a
JOIN PortfolioBMI.DBO.GDP b ON
a.Year= b.Year and a.country=b.Entity

select Year, Country, GDP from Change_blocks where GDP is null

