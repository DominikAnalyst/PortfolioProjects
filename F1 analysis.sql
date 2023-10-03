/*
F1 Data Exploration 

Skills used: Joins, CTE's, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types, SubQuery

Link for created dashboard in Tableau public:  https://public.tableau.com/app/profile/dominik.kudla/vizzes

*/

-- TOP 10 constructor as points scored are concerned 1950-2023

SELECT  c.name AS team,
		SUM(points) AS points
FROM constructor_results cr
INNER JOIN constructors c
ON cr.constructorid = c.constructorid 
GROUP BY c.name
ORDER BY SUM(points) DESC
LIMIT 10;

-- Creating view  
CREATE VIEW constructor_points AS
SELECT  c.name AS team,
		SUM(points) AS points
FROM constructor_results cr
INNER JOIN constructors c
ON cr.constructorid = c.constructorid 
GROUP BY c.name
ORDER BY SUM(points) DESC
LIMIT 10;

-- List of every driver and every team they were racing for 
SELECT  d.forename AS first_name,
		d.surname AS last_name,
		c.name AS team
FROM results AS r
INNER JOIN drivers AS d  
ON r.driverid = d.driverid 
INNER JOIN constructors AS c
ON c.constructorid = r.constructorid 
GROUP BY (c.name, d.driverid, d.forename, d.surname)
ORDER BY d.driverid

-- List of race winners from 1950 to 2023 
SELECT  forename,
		surname,
		CAST(position AS INTEGER) 
FROM results AS r  
INNER JOIN drivers AS d
ON r.driverid = d.driverid 
WHERE position != '\N' AND position = '1'
GROUP BY (forename, surname, position)

-- TOP 10 most winning drivers 

SELECT  forename,
		surname,
		COUNT(CAST(position AS INTEGER))
FROM results AS r  
INNER JOIN drivers AS d
ON r.driverid = d.driverid 
WHERE position != '\N' AND position = '1'
GROUP BY (forename, surname, position)
ORDER BY COUNT(position) DESC
LIMIT 10;

-- TOP 10 drivers with most scored points 

SELECT  forename,
		surname,
		SUM(points)
FROM results AS r  
INNER JOIN drivers AS d
ON r.driverid = d.driverid 
GROUP BY (forename, surname)
ORDER BY SUM(points) DESC 
LIMIT 10;

-- TOP 10 constructor GP wins
SELECT  c.name,
		SUM(position::INTEGER) AS wins
FROM results AS r 
INNER JOIN constructors AS c 
ON c.constructorid = r.constructorid 
WHERE position != '\N' AND position = '1'
GROUP BY c.name
ORDER BY SUM(position::INTEGER) DESC
LIMIT 10;

--Average number of pitstops at each track 


WITH cte_stops AS
(SELECT ps.raceid,
		name, 		
		CAST(AVG(stop) AS DECIMAL(10,2)) AS avg_stops
FROM pit_stops ps
INNER JOIN races r
ON ps.raceid = r.raceid 
GROUP BY ps.raceid, name
)
SELECT 	name,
		CAST(AVG(avg_stops) AS DECIMAL(10,2)) AS stops
FROM cte_stops
GROUP BY name
ORDER BY stops DESC;


-- TOP 3 drivers scoring for TOP 10 constructors


WITH cte_driver_pts AS (
SELECT  d.forename AS first_name,
		d.surname AS last_name,
		c.name AS team,
		SUM(points) AS points
FROM results AS r
INNER JOIN drivers AS d  
ON r.driverid = d.driverid 
INNER JOIN constructors AS c
ON c.constructorid = r.constructorid 
WHERE c.name IN (SELECT  c.name AS team
				 FROM constructor_results cr
				 INNER JOIN constructors c
				 ON cr.constructorid = c.constructorid 
				 GROUP BY c.name
				 ORDER BY SUM(points) DESC
				 LIMIT 10)
GROUP BY (c.name, d.driverid, d.forename, d.surname)
ORDER BY team, SUM(points) DESC
)
SELECT * 
FROM (
SELECT  first_name,
		last_name,
		team,
		points,
		ROW_NUMBER () OVER (PARTITION BY team ORDER BY team) AS row_number
FROM cte_driver_pts) as sub 
WHERE row_number BETWEEN 1 AND 3; 



