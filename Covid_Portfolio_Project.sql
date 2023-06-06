SELECT *
FROM covid_deaths
WHERE continent IS NOT NULL 
ORDER BY 3,4

--SELECT *
--FROM covid_vaccination 
--ORDER BY 3,4

SELECT
location,
date,
total_cases,
new_cases,
total_deaths,
population
FROM covid_deaths
WHERE continent IS NOT NULL 
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--In this case Poland specific
SELECT
location,
date,
total_cases,
total_deaths,
(total_deaths::decimal/total_cases)*100 AS death_percentage
FROM covid_deaths
--WHERE location = 'Poland'
--AND WHERE continent IS NOT NULL 
ORDER BY 1,2

--Looking at Total Cases VS Population 
SELECT
location,
date,
population,
total_cases,
(total_cases::decimal/population)*100 AS percentage_of_infected_population
FROM covid_deaths
--WHERE location = 'Poland'
--AND WHERE continent IS NOT NULL 
ORDER BY 1,2

-- Countries with highest infection rate compared to population 

SELECT 
location,
population,
MAX(total_cases) AS highest_infection_count,
MAX((total_cases::decimal/population))*100 AS percent_population_infected
FROM covid_deaths
--WHERE location = 'Poland'
--AND WHERE continent IS NOT NULL 
GROUP BY location, population 
ORDER BY percent_population_infected DESC 

-- Countries with highest deathcount per population 

SELECT
location,
MAX(total_deaths) AS total_deaths_count
FROM covid_deaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY total_deaths_count DESC 

--Just Looking :) 

SELECT
location,
MAX(total_deaths) AS total_deaths_count
FROM covid_deaths
WHERE continent IS NULL 
GROUP BY location
ORDER BY total_deaths_count DESC 

--Showing continents with the highest death count per population 

SELECT
continent ,
MAX(total_deaths) AS total_deaths_count
FROM covid_deaths
WHERE continent IS NOT NULL 
GROUP BY continent 
ORDER BY total_deaths_count DESC 


--Global Numbers Per Day 

SELECT 
date,
SUM(new_cases) AS total_cases,
SUM(new_deaths) AS total_deaths,
(SUM(new_deaths::decimal) / SUM(new_cases))*100 AS death_percentage 
FROM covid_deaths
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1,2 

--Global Numbers
SELECT 
SUM(new_cases) AS total_cases,
SUM(new_deaths) AS total_deaths,
(SUM(new_deaths::decimal) / SUM(new_cases))*100 AS death_percentage 
FROM covid_deaths
WHERE continent IS NOT NULL 
ORDER BY 1,2 

-- Total Population VS Vaccinations (CTE)
WITH PopvsVac 
(continent,
 location,
 date,
 population,
 new_vaccinations,
 rolling_people_vaccinated)
AS 
( 
SELECT 
cdea.continent,
cdea.location,
cdea.date,
cdea.population,
cvac.new_vaccinations,
SUM(cvac.new_vaccinations) OVER (PARTITION BY cdea.location ORDER BY cdea.location, cdea.date) AS rolling_people_vacinated
--(rolling_people_vaccinated/cdea.population)*100
FROM covid_deaths AS cdea
JOIN covid_vaccination AS cvac
	ON cdea.location = cvac.location 
	and cdea.date = cvac.date 
WHERE cdea.continent IS NOT NULL 
--ORDER BY 2,3	
)
SELECT *, 
(rolling_people_vaccinated/population::decimal)*100 
FROM PopvsVac


--USE CTE

WITH PopvsVac (Continent,Location,date,population,rolling_people_vacinated)
AS 

--TEMP TABLE FAIL ATTEMPT 

DROP TABLE IF EXISTS percent_population_vaccinated
CREATE TEMP TABLE percent_population_vaccinated(
 continent character,
 location character,
 date  date,
 population numeric,
 new_vaccinations numeric,
 rolling_people_vaccinated numeric
 ) 
SELECT 
cdea.continent,
cdea.location,
cdea.date,
cdea.population,
cvac.new_vaccinations,
SUM(cvac.new_vaccinations) OVER (PARTITION BY cdea.location ORDER BY cdea.location, cdea.date) AS rolling_people_vaccinated
--(rolling_people_vaccinated/cdea.population)*100
INTO TEMP TABLE percent_population_vaccinated
FROM covid_deaths AS cdea
JOIN covid_vaccination AS cvac
	ON cdea.location = cvac.location 
	and cdea.date = cvac.date 
WHERE cdea.continent IS NOT NULL 
--ORDER BY 2,3

SELECT *, 
(rolling_people_vaccinated/population::decimal)*100 
FROM percent_population_vaccinated


-- VIEW to store data for later visualisations

CREATE VIEW percent_population_vaccinated AS 
SELECT 
cdea.continent,
cdea.location,
cdea.date,
cdea.population,
cvac.new_vaccinations,
SUM(cvac.new_vaccinations) OVER (PARTITION BY cdea.location ORDER BY cdea.location, cdea.date) AS rolling_people_vacinated
--(rolling_people_vaccinated/cdea.population)*100
FROM covid_deaths AS cdea
JOIN covid_vaccination AS cvac
	ON cdea.location = cvac.location 
	and cdea.date = cvac.date 
WHERE cdea.continent IS NOT NULL 
--ORDER BY 2,3	
