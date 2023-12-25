SELECT*
FROM [Portfolio Project]..[Covid Deaths]
WHERE continent is not null
order by 3,4

--SELECT*
--FROM [Portfolio Project]..[Covid Vacinations]
--ORDER BY 3,4

--Total Cases vs Total Deaths
-- Shows the likleyhood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM [Portfolio Project]..[Covid Deaths]
WHERE location like '%states%'
AND continent is not null
ORDER BY 1,2



-- Looking at Total Cases vs Population
-- What percentage of population got COVID
SELECT Location, date, total_cases, population, (total_cases/population)*100 as infection_percentage
FROM [Portfolio Project]..[Covid Deaths]
WHERE location like '%states%'
ORDER BY 1,2



--Looking at countries with highest infection rate compared to popluation

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM [Portfolio Project]..[Covid Deaths]
--WHERE location like '$states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc


--Showing Countries With Highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..[Covid Deaths]
--WHERE location like '$states%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc



--LET's Break Things Down by Continent 

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..[Covid Deaths]
--WHERE location like '$states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc



--Showing Continents with Highest Death count

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..[Covid Deaths]
--WHERE location like '$states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc



--Global Number

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project]..[Covid Deaths]
--WHERE location like '%states%'
WHERE continent is not null
--Group By date
ORDER BY 1,2


--Total Pop vs Vac

SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..[Covid Deaths] dea
JOIN [Portfolio Project]..[Covid Vacinations] vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..[Covid Deaths] dea
JOIN [Portfolio Project]..[Covid Vacinations] vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT*, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..[Covid Deaths] dea
JOIN [Portfolio Project]..[Covid Vacinations] vac
	ON dea.location = vac.location 
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT*, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to Store Data for Later Visulizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..[Covid Deaths] dea
JOIN [Portfolio Project]..[Covid Vacinations] vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT*
FROM PercentPopulationVaccinated