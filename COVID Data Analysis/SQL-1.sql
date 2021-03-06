SELECT * 
FROM covidDeaths
ORDER By 3,4

SELECT * 
FROM covidVaccinations 
ORDER By 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM covidDeaths
ORDER BY 1,2;

--Total Cases bs Total Deaths
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM covidDeaths
WHERE location LIKE 'India'
ORDER BY 1,2;

--Total Cases vs Population
SELECT location,date,total_cases,population, (total_cases/population)*100 AS CasePercentage
FROM covidDeaths
WHERE location LIKE 'India'
ORDER BY 1,2;

--Countries with Highest Infection Rate compared to Population
SELECT location,  population, max(total_cases) AS HighestInfectionCount, max((total_cases/population))*100 AS PopulationInfectedPercent   
FROM covidDeaths
--WHERE location LIKE 'India'
GROUP by location , population
ORDER BY PopulationInfectedPercent desc;

--Countries with Highest Death Count per Population
SELECT location, max(total_deaths) AS TotalDeathCount   
FROM covidDeaths
--WHERE location LIKE 'India'
where continent is NOT NULL  -- location contains continents 
GROUP by location 
ORDER BY TotalDeathCount desc;

--Countries with Highest Death Count per Population per Continent
SELECT continent, max(total_deaths) AS TotalDeathCount   
FROM covidDeaths
--WHERE location LIKE 'India'
where continent is not NULL  
GROUP by continent 
ORDER BY TotalDeathCount desc;


SELECT location, max(total_deaths) AS TotalDeathCount   
FROM covidDeaths
--WHERE location LIKE 'India'
where continent is NULL  
GROUP by location 
ORDER BY TotalDeathCount desc;


--Global Numbers

SELECT date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM covidDeaths
--WHERE location LIKE 'India'
where continent is not NULL
GROUP by date
ORDER BY 1,2;

--correct way to do as above

SELECT date, sum(new_cases), sum(new_deaths), (sum(new_deaths)/sum(new_cases))*100 AS DeathPercentage
FROM covidDeaths
--WHERE location LIKE 'India'
where continent is not NULL
GROUP by date
ORDER BY 1,2;

-- World Death Percentage
SELECT sum(new_cases), sum(new_deaths), (sum(new_deaths)/sum(new_cases))*100 AS DeathPercentage
FROM covidDeaths
--WHERE location LIKE 'India'
where continent is not NULL
--GROUP by date
ORDER BY 1,2;


--Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
        sum(vac.new_vaccinations) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
FROM covidDeaths dea
join covidVaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not NULL
order by 2,3

-- Using CTE

WITH PopVsVac(continent, location, date, population,new_vaccinations,   RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
        sum(vac.new_vaccinations) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
FROM covidDeaths dea
join covidVaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not NULL
--orfedddddddddd
)
SELECT * 
from PopVsVac

-- Using CTE

WITH PopVsVac(continent, location, date, population,new_vaccinations,   RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
        sum(vac.new_vaccinations) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
FROM covidDeaths dea
join covidVaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not NULL
--order by 1,2
)
SELECT * , (RollingPeopleVaccinated*100/population)
from PopVsVac


-- Temp Table

drop TABLE if EXISTS PercentPopulationVaccinated;
Create TEMP table PercentPopulationVaccinated
(
  continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  RollingPeopleVaccinated numeric
);

Insert into PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
        sum(vac.new_vaccinations) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
FROM covidDeaths dea
join covidVaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not NULL;
--order by 1,2

SELECT * , (RollingPeopleVaccinated*100/population)
from PercentPopulationVaccinated;


-- Creating view for data visualization later

Create view PercentPopulationVaccinated	as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
        sum(vac.new_vaccinations) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
FROM covidDeaths dea
join covidVaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not NULL;
--order by 2,3

SELECT *
from PercentPopulationVaccinated;