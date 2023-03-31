--SELECT * FROM CovidVaccination
--ORDER BY 3,4

--SELECT * FROM CovidDeaths
--ORDER BY 3,4
ALTER TABLE PortfolioProject0..CovidDeaths 
ALTER COLUMN total_cases float
ALTER TABLE PortfolioProject0..CovidDeaths 
ALTER COLUMN total_deaths float

--Selecting the data that going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject0..CovidDeaths


--Total Cases Vs Total Deaths
-- Show likelihood of dying if you contract covid in India
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject0..CovidDeaths
WHERE location = 'India'

--Total Cases Vs Population
--Shows what percentge of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PopulationPercentage
FROM PortfolioProject0..CovidDeaths
WHERE location = 'India'

--Countries with highest infection rate

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PopulationPercentage
FROM PortfolioProject0..CovidDeaths
GROUP BY location, population
ORDER BY PopulationPercentage DESC

--Countries with highest death count per population

SELECT location, population, MAX(total_deaths) AS TotalDeathCounts
FROM PortfolioProject0..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCounts DESC

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_death, SUM(new_deaths)/SUM(new_cases)*100 
AS DeathPercentage
FROM PortfolioProject0..CovidDeaths
WHERE continent is not null
GROUP BY date

-- Total Population vs Vaccinations
-- Using Temp Table to calculate the percentage of population that recieved Covid vaccine


DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
FROM PortfolioProject0..CovidDeaths dea
Join PortfolioProject0..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (PeopleVaccinated/Population)*100 AS PercentageVaccinated
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations


CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as PeopleVaccinated
From PortfolioProject0..CovidDeaths dea
Join PortfolioProject0..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

SELECT * FROM PercentPopulationVaccinated