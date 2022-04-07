-- Checking the increasing rate of total deaths to toal covid cases reported

SELECT location, date, total_cases, total_deaths, convert(DECIMAL(10,2),(total_deaths/total_cases) * 100) AS 'death(%)'
FROM portfolio_project..coviddeaths
ORDER BY 1,2;


-- Checking the total number of covid deaths per country

SELECT location, date, total_cases, total_deaths, convert(DECIMAL(10,2),(total_deaths/total_cases) * 100) AS 'death(%)', 
		MAX(total_deaths) OVER(PARTITION BY location) AS tot_death_per_country
FROM portfolio_project..coviddeaths
ORDER BY 1,2;

-- Top 10 countries with highest infection count

SELECT TOP (10) location, MAX(total_cases) AS infection_count
FROM portfolio_project..coviddeaths
WHERE location NOT IN ('World', 'High income', 'Europe', 'Asia', 'European Union','Upper middle income', 'North America',
						'Lower middle income','South America')
GROUP BY location
ORDER BY infection_count DESC;

-- Top 10 countries with highest infection to population rate

SELECT TOP (10) location, population, MAX(total_cases) AS total_cases, convert(DECIMAL(10,2),MAX(total_cases/population)) * 100 AS 'infection_rate(%)'
FROM portfolio_project..coviddeaths
WHERE location NOT IN ('World', 'High income', 'Europe', 'Asia', 'European Union','Upper middle income', 'North America',
						'Lower middle income','South America')
GROUP BY location, population
ORDER BY 'infection_rate(%)' DESC;

-- Checking total stats for my country (Nigeria)

SELECT TOP (1) *
FROM portfolio_project..coviddeaths WHERE location = 'Nigeria'
ORDER BY date DESC;


-- Checking top 10 countries with highest death to population rate

SELECT TOP (10) location, population, MAX(total_deaths) AS total_deaths, 
		convert(DECIMAL(10,4),MAX(total_deaths/population)) * 100 AS 'death_rate(%)'
FROM portfolio_project..coviddeaths
WHERE location IS NOT NULL
GROUP BY location, population
ORDER BY 'death_rate(%)' DESC;

-- Showing death counts for continents

SELECT continent, MAX(total_deaths) AS death_count
FROM portfolio_project..coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY death_count DESC;

-- Checking total population versus vaccinations

SELECT d.date, d.continent, d.location, d.population, v.total_vaccinations
FROM portfolio_project..coviddeaths AS d
JOIN portfolio_project..covidvaccinations AS v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3,1;


-- using a common table expression to obtain the rate of rolling totals to population


WITH popvac (date, continent, location, population, new_vaccinations, rolling_tot_vaccination)
AS
(SELECT d.date, d.continent, d.location, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_tot_vaccination
FROM portfolio_project..coviddeaths AS d
JOIN portfolio_project..covidvaccinations AS v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL)

SELECT *, (rolling_tot_vaccination/population) * 100 AS 'tot_vac to pop rate'
FROM popvac

-- creating a view 

DROP VIEW IF EXISTS popvac;
USE portfolio_project;
CREATE VIEW popvac (date, continent, location, population, new_vaccinations, rolling_tot_vaccination)
AS
SELECT d.date, d.continent, d.location, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_tot_vaccination
FROM portfolio_project..coviddeaths AS d
JOIN portfolio_project..covidvaccinations AS v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL

SELECT * FROM popvac;