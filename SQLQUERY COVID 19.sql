

-- Covid Statistics from January 1st of 2020 to June 28 2021
-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

Select *
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	Continent is NOT NULL 
ORDER BY
	3,4


-- Select Data that we are going to be starting with

Select
	Location, 
	CAST(Date as Date) as Date, 
	Total_cases, 
	New_cases, 
	Total_deaths, 
	Population
FROM PortfolioProject..CovidDeaths
WHERE
	Continent is NOT NULL 
ORDER BY
	1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country

Select
	Location, 
	CAST(Date as Date) as Date, 
	Total_cases,
	Total_deaths, 
	(total_deaths/total_cases)*100 AS DeathPercentage
FROM
	PortfolioProject..CovidDeaths
WHERE 
	location like '%Philippines%'
	and Continent is NOT NULL 
ORDER BY
	1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select
	Location, 
	CAST(Date as Date) as Date,
	Population,
	Total_cases,  
	(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
	--WHERE location like '%Philippines%'
ORDER BY
	1,2


-- Countries with Highest Infection Rate compared to Population
Select 
  Location, 
  Population, 
  MAX(total_cases) AS HighestInfectionCount, 
  Max((total_cases / population))* 100 AS PercentPopulationInfected 
FROM 
  PortfolioProject..CovidDeaths 
  --WHERE location like '%Philippines%'
Group by 
  Location, 
  Population 
ORDER BY 
  PercentPopulationInfected desc



-- Countries with Highest Death Count per Population

Select 
  Location, 
  MAX(CAST(Total_deaths AS int)) AS TotalDeathCount 
FROM 
  PortfolioProject..CovidDeaths
  --WHERE location like '%Philippines%'
WHERE 
  Continent is NOT NULL 
Group by 
  Location 
ORDER BY 
  TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

Select 
  continent, 
  MAX(cast(Total_deaths AS int)) AS TotalDeathCount 
FROM 
  PortfolioProject..CovidDeaths 
  --WHERE location like '%Philippines%'
WHERE 
  Continent is NOT NULL 
Group by 
  Continent 
ORDER BY 
  TotalDeathCount desc



-- GLOBAL NUMBERS

Select 
	SUM(new_cases) AS Total_cases,
	SUM(cast(new_deaths AS int)) AS Total_deaths,
	SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM 
	PortfolioProject..CovidDeaths
	--WHERE location like '%states%'
WHERE
	Continent is NOT NULL 
	--Group By date
ORDER BY
	1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT
	dea.Continent,
	dea.Location,
	CAST(dea.Date as date) AS Date,
	dea.Population,
	--vac.new_vaccinations,
	ISNULL(vac.new_vaccinations, 'N/A') as New_Vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM
	PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent is not null
ORDER BY 
	2,3 



-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS (
  SELECT 
    dea.Continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY 
        dea.location, 
        dea.Date) AS RollingPeopleVaccinated 
  FROM 
    PortfolioProject..CovidDeaths dea 
    Join PortfolioProject..CovidVaccinations vac On dea.location = vac.location 
    and dea.date = vac.date 
  WHERE 
    dea.continent is NOT NULL 
    ) 
Select 
  *, (RollingPeopleVaccinated / Population)* 100 
FROM 
  PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query


DROP 
  Table if exists #PercentPopulationVaccinated
  Create Table #PercentPopulationVaccinated
  (
    Continent nvarchar(255), 
    Location nvarchar(255), 
    Date date, 
    Population numeric, 
    New_vaccinations numeric, 
    RollingPeopleVaccinated numeric, 
    ) insert into #PercentPopulationVaccinated
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations, 
  sum(
    cast(vac.new_vaccinations as int)
  ) over (
    partition by dea.location 
    order by 
      dea.location, 
      dea.date
  ) AS RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
FROM 
  PortfolioProject..CovidDeaths dea 
  join PortfolioProject..CovidVaccinations vac on dea.location = vac.location 
  and dea.date = vac.date 
WHERE 
  dea.continent is not null --order by 2,3

SELECT *,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations, 
  SUM(
    CONVERT(int, vac.new_vaccinations)
  ) OVER (
    Partition by dea.Location 
    ORDER BY 
      dea.location, 
      dea.Date
  ) AS RollingPeopleVaccinated --, (RollingPeopleVaccinated/population)*100
FROM 
  PortfolioProject..CovidDeaths dea 
  Join PortfolioProject..CovidVaccinations vac On dea.location = vac.location 
  and dea.date = vac.date 
WHERE 
  dea.continent is NOT NULL


