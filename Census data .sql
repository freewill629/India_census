SELECT * FROM test.dbo.data1;
SELECT * FROM test.dbo.data2;
SELECT COUNT(*) FROM test.dbo.data1;
SELECT COUNT(*) FROM test.dbo.data2;

-- DELETE NULL ROWS
DELETE FROM test.dbo.data1
WHERE District IS NULL
AND [State ] IS NULL
AND Growth IS NULL
AND Growth IS NULL
AND [Sex Ratio] IS NULL
AND Literacy IS NULL;

DELETE FROM test.dbo.data2
WHERE District IS NULL
AND State IS NULL
AND Area_km2 IS NULL
AND Population IS NULL;

-- CHECKING THE NUMBER OF ROWS AFTER DELETING NULL VALUES

SELECT COUNT(*) FROM test.dbo.data1;
SELECT COUNT(*) FROM test.dbo.data2;

--CLEAN INVALID VALUE FROM THE TABLE

 DELETE FROM test.dbo.data1
 WHERE District = 'District';

-- CHECKING THE NUMBER OF ROWS AFTER DELETING INVALID VALUES

SELECT COUNT(*) FROM test.dbo.data1;
SELECT COUNT(*) FROM test.dbo.data2;


--Population data for India
--Total Population

SELECT SUM(population) AS Total_Population 
FROM test.dbo.data2;

--Growth Rate Percentage

SELECT AVG(Growth)*100 AS Growth_Rate_India
FROM test.dbo.data1;

-- Average Sex Ratio

SELECT ROUND(AVG([Sex Ratio]),0) AS Avg_sex_ratio 
FROM test.dbo.data1;

-- Average Literacy

SELECT ROUND(AVG(Literacy),2) AS Avg_Literacy
FROM test.dbo.data1;

--Population data Statewise
--Total Population

SELECT State, SUM(population) AS Population_Statewise 
FROM test.dbo.data2
GROUP BY State
ORDER BY Population_Statewise;

--Growth Rate Percentage
SELECT [State], AVG(Growth)*100 AS Growth_Rate_Statewise
FROM test.dbo.data1
GROUP BY [State ]
ORDER BY Growth_Rate_Statewise ASC;

-- Average Sex Ratio

SELECT [State], ROUND(AVG([Sex Ratio]),0) AS Statewise_Sex_Ratio
FROM test.dbo.data1
GROUP BY [State ]
ORDER BY Statewise_Sex_Ratio ASC;

-- Average Literacy

SELECT [State], ROUND(AVG(Literacy),2) AS Statewise_Literacy
FROM test.dbo.data1
GROUP BY [State]
ORDER BY Statewise_Literacy ASC;

--States With Literacy Rate above 90%

SELECT [State], ROUND(AVG(Literacy),2) AS Statewise_Literacy
FROM test.dbo.data1
GROUP BY [State]
HAVING ROUND(AVG(Literacy),2) > 90
ORDER BY Statewise_Literacy DESC;

-- TOP 3 States With Highest Growth Rates

SELECT TOP 3 State, ROUND(AVG(Growth),2)*100 AS Avg_Growth
FROM test.dbo.data1
GROUP BY State
ORDER BY Avg_Growth DESC;

--Top 3 States With Lowest Growth Rates

SELECT TOP 3 State, ROUND(AVG(Growth),2) AS Avg_Growth
FROM test.dbo.data1
GROUP BY State
ORDER BY Avg_Growth ASC;

-- TOP 3 States With Highest Literacy

SELECT TOP 3 State, ROUND(AVG(Literacy),2) AS Avg_Literacy
FROM test.dbo.data1
GROUP BY State
ORDER BY Avg_Literacy DESC;

-- TOP 3 States With Lowest Literacy

SELECT TOP 3 State, ROUND(AVG(Literacy),2) AS Avg_Literacy
FROM test.dbo.data1
GROUP BY State
ORDER BY Avg_Literacy ASC;

-- TOP 3 States With Highest Sex Ratio

SELECT TOP 3 State, ROUND(AVG([Sex Ratio]),0) AS Avg_Sex_Ratio
FROM test.dbo.data1
GROUP BY State
ORDER BY Avg_Sex_Ratio DESC;

-- Top 3 States With Lowest Sex Ratio

SELECT TOP 3 State, ROUND(AVG([Sex Ratio]),0) AS Avg_Sex_Ratio
FROM test.dbo.data1
GROUP BY State
ORDER BY Avg_Sex_Ratio ASC;

--Top and Bottom 5 States in Literacy
DROP TABLE IF EXISTS #topstates
CREATE TABLE #topstates(State nvarchar(255), Literacy float)
INSERT INTO #topstates
SELECT TOP 5 state, ROUND(AVG(Literacy),2) AS Avg_Literacy
FROM test.dbo.data1
GROUP BY state
ORDER BY Avg_Literacy DESC;

SELECT * FROM #topstates;

DROP TABLE IF EXISTS #bottomstates
CREATE TABLE #bottomstates(State nvarchar(255), Literacy float);
INSERT INTO #bottomstates
SELECT TOP 5 State,ROUND(AVG(Literacy),2) AS Avg_Literacy
FROM test.dbo.data1
GROUP BY State
ORDER BY Avg_Literacy ASC;

SELECT * FROM #bottomstates;

SELECT * FROM #bottomstates
UNION
SELECT * FROM #topstates
ORDER BY Literacy DESC;

--States Having Literacy rates More than National Average.

DROP TABLE IF EXISTS #templiteracytable
Create TABLE #templiteracytable(State nvarchar(255), Literacy float)
INSERT INTO #templiteracytable
SELECT [State], ROUND(AVG(Literacy),2)
FROM test.dbo.data1
GROUP BY [State];

SELECT * FROM #templiteracytable
WHERE Literacy > (SELECT AVG(Literacy) FROM #templiteracytable);

--Select States That Starts With Letter A OR B

SELECT DISTINCT [State] FROM test.dbo.data1 WHERE [State] LIKE 'A%' OR [State] LIKE 'B%';

--Getting the number of Males and females districtwise

SELECT c.District,c.[State], ROUND(c.Population/(c.Sex_Ratio+1),0) Males, ROUND((c.Population * c.Sex_Ratio)/(c.Sex_Ratio + 1),0) Females FROM
(SELECT a.District, a.[State],a.[Sex Ratio]/1000 Sex_Ratio,b.Population FROM test.dbo.data1 a INNER JOIN test.dbo.data2 b ON a.District = b.District) c 
ORDER BY FEMALES DESC;

--Getting the number of Males and females Statewise

SELECT d.[State], SUM(d.Males) Males_Statewise, SUM(d.Females) Females_Statewise FROM
(SELECT c.District,c.[State], ROUND(c.Population/(c.Sex_Ratio+1),0) Males, ROUND((c.Population * c.Sex_Ratio)/(c.Sex_Ratio + 1),0) Females FROM
(SELECT a.District, a.[State],a.[Sex Ratio]/1000 Sex_Ratio,b.Population FROM test.dbo.data1 a INNER JOIN test.dbo.data2 b ON a.District = b.District) c ) d
GROUP BY d.[State]
ORDER BY Females_Statewise DESC;

--Statewise Literacy Rate

SELECT [State], ROUND(ROUND(SUM(Literacy),2) / COUNT(District), 2) Statewise_Literacy FROM test.dbo.data1 GROUP BY [State] ORDER BY Statewise_Literacy DESC;

--Total Literarte and Illeterate Citizens Statewise

SELECT d.[State], SUM(d.Total_Literate_People), SUM(d.Total_Illeterate_People) FROM
(SELECT c.District, c.[State], ROUND((c.Literacy * c.Population)/100,0) Total_Literate_People, ROUND(((100-c.Literacy)*Population)/100,0) Total_Illeterate_People FROM
(SELECT a.District, a.[State], a.Literacy, b.Population FROM test.dbo.data1 a INNER JOIN test.dbo.data2 b ON a.District = b.District) c) d GROUP BY d.[State] ORDER BY d.[State] DESC;

--Previous Population & Current Population of India From Sensus

SELECT SUM(d.New_Population),SUM(d.Old_Population) FROM
(SELECT c.District, c.[State], ROUND((c.New_Population * 100)/((c.Growth*100) + 100),0) Old_Population , c.New_Population FROM
(SELECT a.District, a.[State], a.Growth, b.Population New_Population FROM test.dbo.data1 a INNER JOIN test.dbo.data2 b ON a.District = b.District) c) d


--Population V/S Area

SELECT (i.total_area/i.Sum_of_new_population) Area_per_person_new, (i.total_area/i.Sum_of_old_population) Area_per_person_old FROM
(SELECT g.*,h.total_area FROM
(SELECT '1' AS Pop_Key, e.* FROM
(SELECT SUM(d.New_Population) Sum_of_new_population ,SUM(d.Old_Population) Sum_of_old_population FROM
(SELECT c.District, c.[State], ROUND((c.New_Population * 100)/((c.Growth*100) + 100),0) Old_Population , c.New_Population FROM
(SELECT a.District, a.[State], a.Growth, b.Population New_Population FROM test.dbo.data1 a INNER JOIN test.dbo.data2 b ON a.District = b.District) c) d) e)g

INNER JOIN

(SELECT '1' AS Pop_Key, f.* FROM
(SELECT SUM(Area_km2) total_area FROM test.dbo.data2) f)h

ON g.Pop_Key = h.Pop_Key) i;

--Output top 3 districts from each states

SELECT a.District,a.[State],a.Literacy,a.rnk FROM
(SELECT District,[State], Literacy, RANK() OVER(PARTITION BY [State] ORDER BY Literacy DESC) rnk
FROM test.dbo.data1) a
WHERE rnk<4;
