/*
Covid-19 Data Exploration 

Skills used: Joins, CTE's, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM covid_deaths
WHERE continent IS NOT NULL 
ORDER BY 3,4

--Select data that we are going to be starting with 

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

--Total Cases vs Total Deaths
--Shows likelihood of dying if you got covid in Poland 

SELECT
location,
date,
total_cases,
total_deaths,
(total_deaths::decimal/total_cases)*100 AS death_percentage
FROM covid_deaths
WHERE location = 'Poland'
AND continent IS NOT NULL 
ORDER BY 1,2

--Total Cases VS Population 
--Shows percentage of population with covid 

SELECT
location,
date,
population,
total_cases,
(total_cases::decimal/population)*100 AS percentage_of_infected_population
FROM covid_deaths
ORDER BY 1,2

-- Countries with highest infection rate compared to population 

SELECT 
location,
population,
MAX(total_cases) AS highest_infection_count,
MAX((total_cases::decimal/population))*100 AS percent_population_infected
FROM covid_deaths
GROUP BY location, population 
ORDER BY percent_population_infected DESC 

-- Countries with highest death count per population 

SELECT
location,
MAX(total_deaths) AS total_deaths_count
FROM covid_deaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY total_deaths_count DESC 

--BEAKING THINGS DOWN WITH CONTINENT
--Showing continents with the highest death count per population 

SELECT
continent ,
MAX(total_deaths) AS total_deaths_count
FROM covid_deaths
WHERE continent IS NOT NULL 
GROUP BY continent 
ORDER BY total_deaths_count DESC 


--Global Numbers per day 

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
FROM covid_deaths AS cdea
JOIN covid_vaccination AS cvac
	ON cdea.location = cvac.location 
	and cdea.date = cvac.date 
WHERE cdea.continent IS NOT NULL 
)
SELECT *, 
(rolling_people_vaccinated/population::decimal)*100 
FROM PopvsVac


-- VIEW to store data for later visualisations

CREATE VIEW percent_population_vaccinated AS 
SELECT 
cdea.continent,
cdea.location,
cdea.date,
cdea.population,
cvac.new_vaccinations,
SUM(cvac.new_vaccinations) OVER (PARTITION BY cdea.location ORDER BY cdea.location, cdea.date) AS rolling_people_vacinated
FROM covid_deaths AS cdea
JOIN covid_vaccination AS cvac
	ON cdea.location = cvac.location 
	and cdea.date = cvac.date 
WHERE cdea.continent IS NOT NULL 
--ORDER BY 2,3	
