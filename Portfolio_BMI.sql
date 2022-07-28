-- Exploring the Data
SELECT Entity, MAX([Mean BMI (male)])
FROM PortfolioBMI.[dbo].[BMI MEN]
WHERE [Mean BMI (male)]>30 AND Year BETWEEN 2012 AND 2015
GROUP BY Entity,[Mean BMI (male)] 
ORDER BY [Mean BMI (male)] desc


SELECT * 
FROM [PortfolioBMI].[dbo].[BMIFemale] 

SELECT *
FROM [PortfolioBMI].[dbo].[children_overweight]
WHERE [Indicator:Overweight prevalence among children under 5 years of ]>24

SELECT *
FROM [PortfolioBMI].[dbo].[Caloric intake]

SELECT *
FROM [PortfolioBMI].[dbo].[GDP]

SELECT *
FROM [PortfolioBMI].[dbo].['global-food$']

SELECT *
FROM [PortfolioBMI].[dbo].['death-rate-from-obesity$']
WHERE Entity = 'Libya'
ORDER BY Year desc



SELECT *
FROM PortfolioBMI.[dbo].[Minimum_calories]

SELECT *
FROM PortfolioBMI.[dbo].[Percent_death_obesity]


--Aggregating and joining data:

SELECT 
a.[Country],
a.[Year],
a.[Population],
a.[Food supply (kcal per capita per day)] AS Daily_Calories ,
a.[Food supply (Protein g per capita per day)]*4 AS Daily_Protein_G_Kcl,
a.[Food supply (Fat g per capita per day)]*9 AS Daily_Fat_Kcl,
a.[Food supply (kcal per capita per day)] - (a.[Food supply (Protein g per capita per day)]*4 + a.[Food supply (Fat g per capita per day)]*9) AS Daily_Carb_Kcl,
b.[Minimum caloric requirement (kcal/person/day)] AS Minimum_intake_Kcl,
(a.[Food supply (Protein g per capita per day)]*4 / a.[Food supply (kcal per capita per day)])*100 AS Percent_Protein,
(a.[Food supply (Fat g per capita per day)]*9 / a.[Food supply (kcal per capita per day)])*100 AS Percent_Fat,
((a.[Food supply (kcal per capita per day)] - (a.[Food supply (Protein g per capita per day)]*4 + a.[Food supply (Fat g per capita per day)]*9)) / a.[Food supply (kcal per capita per day)])*100 AS Percent_Carb,
c.[Deaths - Cause: All causes - Risk: High body-mass index - Sex: B] AS Death_rate_Per_100K,
G.[GDP per capita, PPP (constant 2017 international $)] AS GDP_PC
INTO Food_Full
FROM PortfolioBMI.[dbo].['global-food$'] a
INNER JOIN PortfolioBMI.[dbo].[Minimum_calories] b ON 
a.[Country]=b.[Entity] AND a.[Year]=b.[Year]
INNER JOIN PortfolioBMI.[dbo].['death-rate-from-obesity$'] c ON
a.[Country]=c.[Entity] AND a.[Year]=c.[Year]
INNER JOIN PortfolioBMI.DBO.GDP G ON
a.[Country]=G.[Entity] AND a.[Year]=G.[Year]

select * 
from PortfolioBMI.dbo.Food_Full

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

--Checking for Null values after a join issue.
SELECT *
FROM PortfolioBMI.dbo.Joined_BMI
WHERE  [Population] Is NULL