SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2

--You Should convert the VARCHAR to FLOAT to Run

--TOTAL CASES vs TOTAL DEATHS  
--How the chances of you dying if you get the covid-19
SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths))/(CONVERT(float, total_cases))*100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%PHI%' AND continent IS NOT NULL
ORDER BY 1, 2

--TOTAL CASES vs POPULATION 
--Percentage of Population got covid-19
SELECT location, date, population,total_cases, (CONVERT(float, total_cases))/(CONVERT(float, population))*100 AS PercentPopulation
FROM CovidDeaths
WHERE location LIKE '%PHI%'
ORDER BY 1, 2

--Countries with Highest Rate of Infection compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfection, MAX((CONVERT(float, total_cases))/(CONVERT(float, population)))*100 AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Lets Break Things Down by Continent
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Show Continents wiht Highest death count per population
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100  AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--CTE
WITH PopVsVac (contient, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
--TOTAL POPULATION VS VACCINATIONS
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVacinated$.new_vaccinations,
SUM(CAST(CovidVacinated$.new_vaccinations AS float)) OVER (Partition By CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) AS RollingPeopleVaccinated --,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths INNER JOIN CovidVacinated$
ON CovidDeaths.location = CovidVacinated$.location AND CovidDeaths.date = CovidVacinated$.date
WHERE CovidDeaths.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVacinated$.new_vaccinations,
SUM(CAST(CovidVacinated$.new_vaccinations AS float)) OVER (Partition By CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) AS RollingPeopleVaccinated --,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths INNER JOIN CovidVacinated$
ON CovidDeaths.location = CovidVacinated$.location AND CovidDeaths.date = CovidVacinated$.date
--WHERE CovidDeaths.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
CREATE View PercentPopulationVaccinated AS
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVacinated$.new_vaccinations,
SUM(CAST(CovidVacinated$.new_vaccinations AS float)) OVER (Partition By CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) AS RollingPeopleVaccinated --,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths INNER JOIN CovidVacinated$
ON CovidDeaths.location = CovidVacinated$.location AND CovidDeaths.date = CovidVacinated$.date
WHERE CovidDeaths.continent IS NOT NULL
--ORDER BY 2,3
 