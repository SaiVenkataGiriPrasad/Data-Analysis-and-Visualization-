use portfolio_project;

SELECT * FROM deaths_covid_data dcd;

SELECT * FROM vaccinations_covid_data vcd;


-- 1. Total Cases vs Total Deaths in terms of Percentage.

SELECT iso_code, location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 3) as death_percent
FROM deaths_covid_data dcd
WHERE location like '%states%'
ORDER BY 2, 3;
-- The above query shows the likelihood of death percentage if a person is infected with covid.


-- 2. Total Cases vs Total Population in terms of Percentage.

SELECT iso_code, location, total_cases, population, ROUND((total_cases/population)*100, 3) as percent_people_infected
FROM deaths_covid_data dcd 
WHERE location like '%states%'
ORDER BY 2;


-- 3. Countries with Highest covid infection rate when compared with its population.

SELECT location  , population, MAX(total_cases) as max_no_of_cases, MAX(total_cases/population)*100 AS percent_people_infected
FROM deaths_covid_data dcd
WHERE population > 60000000
GROUP BY location, population
ORDER BY 4 DESC;


-- 4. Countries with the Highest death percent when compared with its population.

SELECT  location, population, MAX(total_deaths) AS max_no_of_deaths, MAX(ROUND((total_deaths/population)*100, 3)) AS death_percent_per_country
FROM deaths_covid_data dcd 
GROUP BY location, population
ORDER BY 4 DESC;


-- 5. Countries with Highest Death Count per Population.

SELECT location, MAX(total_deaths) AS max_no_of_deaths
FROM deaths_covid_data dcd 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY max_no_of_deaths DESC;

-- 6. Exploring the data by Continent wise and on Yearly basis

SELECT continent , YEAR(date) AS year, SUM(total_cases) AS total_cases_continent_wise, SUM(total_deaths) AS total_deaths_continent_wise
FROM deaths_covid_data dcd 
GROUP BY continent, year

-- 7. Exploring the data by Country wise and on yearly basis.

SELECT location, YEAR(date) AS year, SUM(total_cases) AS total_cases_country_wise, SUM(total_deaths) AS total_deaths_country_wise
FROM deaths_covid_data dcd 
WHERE population > 100000000
GROUP BY location, year;

-- 8. Combining the data from two tables(deaths_covid and vaccinations_covid) to compare the Total Poputions vs Vaccinations.

-- Here, I am adding the new vaccinations on the monthly basis for each country.

SELECT dcd.continent, dcd.location, dcd.date, dcd.population, vcd.new_vaccinations, 
SUM(vcd.new_vaccinations) OVER (PARTITION BY dcd.location ORDER BY dcd.location, dcd.date) as montly_vaccinations
FROM deaths_covid_data dcd 
JOIN vaccinations_covid_data vcd 
ON dcd.location  = vcd.location
AND dcd.date = vcd.date
WHERE vcd.new_vaccinations;


-- 10. Using CTE, to perform the operations on Montly Vaccinations(montly_vaccinations)

WITH VaccVsPop_Percent (continent, location, date, population, new_vaccinations, monthly_vaccinations) AS 
(
SELECT dcd.continent, dcd.location, dcd.date, dcd.population, vcd.new_vaccinations, 
SUM(vcd.new_vaccinations) OVER (PARTITION BY dcd.location ORDER BY dcd.location, dcd.date) as montly_vaccinations
FROM deaths_covid_data dcd 
JOIN vaccinations_covid_data vcd 
ON dcd.location  = vcd.location
AND dcd.date = vcd.date
WHERE vcd.new_vaccinations
)
SELECT *, ROUND((monthly_vaccinations/population) * 100, 2) AS percent_population_vaccinated FROM VaccVsPop_Percent;


-- CREATING THE VIEWS TO STORE THE DATA FOR THE VISUALIZATIONS

CREATE VIEW percent_population_vaccinated AS
SELECT dcd.continent, dcd.location, dcd.date, dcd.population, vcd.new_vaccinations, 
SUM(vcd.new_vaccinations) OVER (PARTITION BY dcd.location ORDER BY dcd.location, dcd.date) as montly_vaccinations
FROM deaths_covid_data dcd 
JOIN vaccinations_covid_data vcd 
ON dcd.location  = vcd.location
AND dcd.date = vcd.date
WHERE vcd.new_vaccinations;

SELECT * FROM percent_population_vaccinated;
