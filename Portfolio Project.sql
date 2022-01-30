SELECT *
FROM [Portfolio Project]..['Covid Deaths$']
ORDER BY 3,4


--SELECT *
--FROM [Portfolio Project]..['Covid Vaccinations$']
--ORDER BY 3,4

--Data that we will be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..['Covid Deaths$']

--Looking at Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercent
FROM [Portfolio Project]..['Covid Deaths$']
WHERE location = 'india'

--Looking at Total Cases vs Population
SELECT location, date, total_cases, population,(total_cases/population)*100 AS DeathPercentage
FROM [Portfolio Project]..['Covid Deaths$']
WHERE location = 'India'


--What country has highest infection rates compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM [Portfolio Project]..['Covid Deaths$']
GROUP BY location, population
order by percent_population_infected DESC


--Countries with highest deat count per population
SELECT location, max(cast(total_deaths as int)) AS total_death_counts
FROM [Portfolio Project]..['Covid Deaths$']
WHERE continent is not null
GROUP BY location
order by total_death_counts DESC


--Continent with highest death count
SELECT continent, MAX(cast(total_deaths AS int)) AS total_deaths_counts
FROM [Portfolio Project]..['Covid Deaths$']
WHERE continent is not null
GROUP BY continent
order by total_deaths_counts DESC


--Global Numbers
SELECT date, SUM(new_cases) as tota_cases, SUM(cast(new_deaths AS int)) as tot_deaths, (SUM(cast(new_deaths AS int))/SUM(new_cases))*100 AS death_percentage
FROM [Portfolio Project]..['Covid Deaths$']
WHERE continent is not null 
GROUP BY date

--Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM [Portfolio Project]..['Covid Deaths$'] dea JOIN [Portfolio Project]..['Covid Vaccinations$'] vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE

WITH popvsvac(Continent, location, date, population,new_vaccinations, rolling_people_vaccinated)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM [Portfolio Project]..['Covid Deaths$'] dea JOIN [Portfolio Project]..['Covid Vaccinations$'] vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null and dea.location = 'india'
)
SELECT *, (rolling_people_vaccinated/population)*100 
FROM popvsvac


--TEMP Table

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM [Portfolio Project]..['Covid Deaths$'] dea JOIN [Portfolio Project]..['Covid Vaccinations$'] vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (rolling_people_vaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating view to store data for later visualization
Create view percentpopulationvaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM [Portfolio Project]..['Covid Deaths$'] dea JOIN [Portfolio Project]..['Covid Vaccinations$'] vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
