
-- 1. Global numbers of (total cases, deaths and death percentage)

SELECT
	SUM(new_cases) AS Total_cases,
	SUM(CAST(new_deaths AS INT)) AS Total_deaths,
	SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
	FROM PortfolioProject..CovidDeaths
	--WHERE location like '%Philippines%'
	WHERE continent is not NULL 
	--GROUP BY Date
	ORDER BY 1,2



-- 2. Continents vs TotalDeathCount

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT
	Location,
	SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM
	PortfolioProject..CovidDeaths
--WHERE location like '%Philippines%'
WHERE
	continent is NULL 
	and location not in ('World', 'European Union', 'International')
GROUP BY 
	location
ORDER BY 
	TotalDeathCount Desc


 
-- 3. Total Percent of Population Infected in Different Countries

SELECT
Location, 
Population, 
MAX(total_cases) as HighestInfectionCount,  
MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM
	PortfolioProject..CovidDeaths
--WHERE location like '%Philippines%'
GROUP BY
	Location,
	Population
ORDER BY
	PercentPopulationInfected Desc



-- 4.

Select
	Location, 
	Population,
	Date, 
	MAX(total_cases) AS HighestInfectionCount,  
	Max((total_cases/population))*100 AS PercentPopulationInfected
From 
	PortfolioProject..CovidDeaths
--Where location like '%Philippines%'
Group by 
	Location, 
	Population, 
	Date
order by PercentPopulationInfected desc



-- 5. Total Population vs Vaccination (Not included in Dashboard)
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