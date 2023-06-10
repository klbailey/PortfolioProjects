SELECT *
FROM PortfolioProject_Covid.dbo.CovidDeaths
WHERE continent IS NOT null
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject_Covid.dbo.CovidDeaths
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject_Covid.dbo.CovidDeaths
WHERE location LIKE 'states%' 
AND continent IS NOT null
ORDER BY 1,2

--Look at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject_Covid.dbo.CovidDeaths
--WHERE location LIKE '%states%'
ORDER BY 1,2

--Looking at Countries with Highest infection rates compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject_Covid.dbo.CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc


SELECT Location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject_Covid.dbo.CovidDeaths
WHERE continent IS NOT null
GROUP BY Location
ORDER BY TotalDeathCount desc

--Looking at Countries with the HIghest Death Count per Population

SELECT Location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject_Covid.dbo.CovidDeaths
WHERE continent IS NOT null
GROUP BY Location
ORDER BY TotalDeathCount desc

--Break things down by Continent

SELECT Continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject_Covid.dbo.CovidDeaths
WHERE continent IS NOT null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Showing continents with the highest death count per population

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject_Covid.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent IS null
GROUP BY location
ORDER BY TotalDeathCount desc

--Global Numbers need to cast float as integer

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject_Covid.dbo.CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT null
--GROUP BY date
ORDER BY 1,2

SELECT *
FROM PortfolioProject_Covid.dbo.CovidVaccinations

--JOIN the two tables 
SELECT *
FROM PortfolioProject_Covid.dbo.CovidDeaths dea
JOIN PortfolioProject_Covid.dbo.CovidVaccinations vac 
	ON dea.location = vac.location	
	AND dea.date = vac.date

	--USE CTE
With PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
--Look at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject_Covid.dbo.CovidDeaths dea
JOIN PortfolioProject_Covid.dbo.CovidVaccinations vac 
	ON dea.location = vac.location	
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 2,3
)
SELECT*, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac

--Temp Table

DROP Table if EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject_Covid.dbo.CovidDeaths dea
JOIN PortfolioProject_Covid.dbo.CovidVaccinations vac 
	ON dea.location = vac.location	
	AND dea.date = vac.date
--WHERE dea.continent IS NOT null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Create View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject_Covid.dbo.CovidDeaths dea
JOIN PortfolioProject_Covid.dbo.CovidVaccinations vac 
	ON dea.location = vac.location	
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated



