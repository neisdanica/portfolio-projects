-- Alter Table to change column's data type

ALTER TABLE ProjectPortfolio..CovidDeaths$ ALTER COLUMN total_cases										float 
ALTER TABLE ProjectPortfolio..CovidDeaths$ ALTER COLUMN total_deaths									float 
ALTER TABLE ProjectPortfolio..CovidDeaths$ ALTER COLUMN total_cases_per_million							float
ALTER TABLE ProjectPortfolio..CovidDeaths$ ALTER COLUMN total_deaths_per_million						float 
ALTER TABLE ProjectPortfolio..CovidDeaths$ ALTER COLUMN reproduction_rate								float 
ALTER TABLE ProjectPortfolio..CovidDeaths$ ALTER COLUMN icu_patients									float 
ALTER TABLE ProjectPortfolio..CovidDeaths$ ALTER COLUMN icu_patients_per_million						float
ALTER TABLE ProjectPortfolio..CovidDeaths$ ALTER COLUMN hosp_patients									float 
ALTER TABLE ProjectPortfolio..CovidDeaths$ ALTER COLUMN hosp_patients_per_million						float
ALTER TABLE ProjectPortfolio..CovidDeaths$ ALTER COLUMN weekly_icu_admissions							float 
ALTER TABLE ProjectPortfolio..CovidDeaths$ ALTER COLUMN weekly_icu_admissions_per_million				float
ALTER TABLE ProjectPortfolio..CovidDeaths$ ALTER COLUMN weekly_hosp_admissions							float
ALTER TABLE ProjectPortfolio..CovidDeaths$ ALTER COLUMN weekly_hosp_admissions_per_million				float

ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN total_tests									float 
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN new_tests										float 
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN total_tests_per_thousand						float
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN new_tests_per_thousand						float 
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN new_tests_smoothed							float 
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN new_tests_smoothed_per_thousand				float 
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN positive_rate									float
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN tests_per_case								float 
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN total_vaccinations							float
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN people_vaccinated								float 
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN people_fully_vaccinated						float 
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN total_boosters								float
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN new_vaccinations								float
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN new_vaccinations_smoothed						float
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN total_vaccinations_per_hundred				float 
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN people_vaccinated_per_hundred					float 
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN people_fully_vaccinated_per_hundred			float
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN total_boosters_per_hundred					float 
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN new_vaccinations_smoothed_per_million			float 
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN new_people_vaccinated_smoothed				float 
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN new_people_vaccinated_smoothed_per_hundred	float
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN extreme_poverty								float 
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN female_smokers								float
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN male_smokers									float 
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN excess_mortality_cumulative_absolute			float 
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN excess_mortality_cumulative					float
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN excess_mortality								float
ALTER TABLE ProjectPortfolio..CovidVaccinations$ ALTER COLUMN excess_mortality_cumulative_per_million		float

SELECT *
FROM ProjectPortfolio..CovidDeaths$
ORDER BY 3,4;

SELECT *
FROM ProjectPortfolio..CovidVaccinations$
ORDER BY 3,4;

---- SELECTING DATA FOR THE ANALYSIS

SELECT	location, date, total_cases, new_cases, total_deaths, population

FROM	ProjectPortfolio..CovidDeaths$

ORDER BY 1,2;

---- TOTAL CASES vs. TOTAL DEATHS in the Philippines
SELECT	location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 AS death_percentage
FROM	ProjectPortfolio..CovidDeaths$
WHERE location like '%Philippines%'
ORDER BY 1,2;

-- TOTAL CASES vs POPULATION
-- SHOWS PERCENTAGE OF POPULATION WHO GOT COVID in the Philippines
SELECT	location, date, population, total_cases,(total_cases/population)*100 AS percent_population_infected
FROM	ProjectPortfolio..CovidDeaths$
WHERE location like '%Philippines'
ORDER BY 1,2;

-- Highest Infection Rate per Capita by Country
SELECT	location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM	ProjectPortfolio..CovidDeaths$
--WHERE location like '%States'
GROUP BY location, population
ORDER BY percent_population_infected DESC;

-- Highest Death Count by Country
SELECT	location, MAX(total_deaths) AS TotalDeathCount
FROM	ProjectPortfolio..CovidDeaths$
WHERE	continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Total Death Count by Continent
SELECT	continent, SUM(new_deaths) AS TotalDeathCount
FROM	ProjectPortfolio..CovidDeaths$
WHERE	continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Daily Comparison of Cumulative Cases and Deaths Across All Countries.
SELECT	date, SUM(total_cases) AS total_cases, SUM(total_deaths) AS total_deaths, (SUM(total_deaths)/NULLIF(SUM(total_cases),0))*100 AS death_percentage
FROM	ProjectPortfolio..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Total Number of Cases vs Total Number of Deaths per Day Across All Countries 
SELECT	date, SUM(new_cases) AS total_cases_per_day, SUM(new_deaths) AS total_deaths_per_day, (SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 AS death_percentage
FROM	ProjectPortfolio..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- JOINING CovidDeaths Table with CovidVaccinations Table
-- Shows the number of new_vaccinations and the rolling count of total_vaccinations per day by Country
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_total_vaccinations
FROM ProjectPortfolio..CovidDeaths$ dea
JOIN ProjectPortfolio..CovidVaccinations$ vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;
	
-- Showing rolling count of New_Vaccinations vs Population per Day 

-- First option to do that use CTE
WITH PopVacPercentage (continent, location, date, population, new_vaccinations, rolling_total_vaccinations)
AS
( SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_total_vaccinations
  FROM ProjectPortfolio..CovidDeaths$ dea
  JOIN ProjectPortfolio..CovidVaccinations$ vac
  	ON dea.location = vac.location 
  	AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
)

SELECT *, (rolling_total_vaccinations/population)*100 AS vaccination_percentage
FROM PopVacPercentage

-- 2nd option is to use temp table

DROP TABLE if exists PopVacPercentage
CREATE TABLE PopVacPercentage
(
 continent						nvarchar(255),
 location						nvarchar(255),
 date							datetime,
 population						numeric,
 new_vaccinations				numeric,
 rolling_total_vaccinations		numeric
)

INSERT INTO PopVacPercentage
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_total_vaccinations
FROM ProjectPortfolio..CovidDeaths$ dea
JOIN ProjectPortfolio..CovidVaccinations$ vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (rolling_total_vaccinations/population)*100 AS vaccination_percentage
FROM PopVacPercentage

-- CREATING VIEW to store data to be used for later visualization in Tableau --
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_total_vaccinations
FROM ProjectPortfolio..CovidDeaths$ dea
JOIN ProjectPortfolio..CovidVaccinations$ vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated