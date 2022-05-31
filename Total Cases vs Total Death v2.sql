SELECT 
*
FROM
PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT 
--*
--FROM
--PortfolioProject..CovidDeaths
--ORDER BY 3,4

--Select the data that we will be using


--Looking at Total Cases vs Tota Deaths
--Shows the likelihood of dying if you contract covid in your country
SELECT
	location
	,date
	,total_cases
	,new_cases
	,total_deaths
	,population
	,(total_deaths/Total_cases)*100 As DeathPercentages
FROM
PortfolioProject..CovidDeaths
WHERE
	location like '%kingdom%'
	AND continent IS NOT NULL
ORDER BY 1,2


--Looking at the Total Cases vs Poplation
--Shows what percentage of population got covid
SELECT
	location
	,date
	,total_cases
	,population
	,(total_cases/population)*100 As PercentagePopulationInfected
FROM
PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE
	--location like '%kingdom%'
ORDER BY 1,2


--Looking at countires with Highest Infection Rate compared to Population
SELECT
	location
	,population
	,MAX(total_cases) AS HighestInfectionCount
	,MAX((total_cases/population))*100 As PercentagePopulationInfected
FROM
PortfolioProject..CovidDeaths
--WHERE
	--location like '%kingdom%'
WHERE continent IS NOT NULL
GROUP BY  
	location
	,population
ORDER BY PercentagePopulationInfected desc


-- Showing Countries with Highest Death Count Per Population

SELECT
	location
	,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM
PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE
	--location like '%kingdom%'
GROUP BY  
	location
ORDER BY TotalDeathCount desc

--Break thing's down by Continent

--SELECT
--*
--FROM	
--CovidDeaths
--WHERE 
--	location not like '%income%'

-- How I removed results showing 'Income' in 'Location'

SELECT
	location
	,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM
PortfolioProject..CovidDeaths
WHERE continent IS NULL
	AND location not like '%income%'
--WHERE
	--location like '%kingdom%'
GROUP BY  
	location
ORDER BY TotalDeathCount desc

--Showing Continents with the highest death count per population
--can do this with all previous queries by replacing 'location' with 'continent'

SELECT
	continent
	,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM
PortfolioProject..CovidDeaths
WHERE continent IS NULL
--WHERE
	--location like '%kingdom%'
GROUP BY  
	continent
ORDER BY TotalDeathCount desc

--Global numbers overall

SELECT
	--date
	SUM(new_cases) AS TotalCases
	,SUM(CAST(new_deaths AS INT)) AS TotalDeaths
	,(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS GlobalDeathPercentage
	--,total_deaths
	--,(total_deaths/Total_cases)*100 As DeathPercentages
FROM
PortfolioProject..CovidDeaths
WHERE
	--location like '%kingdom%'
	continent IS NOT NULL
--Group By date
ORDER BY 1,2

--Global numbers per day

SELECT
	date
	,SUM(new_cases) AS TotalCases
	,SUM(CAST(new_deaths AS INT)) AS TotalDeaths
	,(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS GlobalDeathPercentage
	--,total_deaths
	--,(total_deaths/Total_cases)*100 As DeathPercentages
FROM
PortfolioProject..CovidDeaths
WHERE
	--location like '%kingdom%'
	continent IS NOT NULL
Group By date
ORDER BY 1,2


-- Joining CovidDeaths tble with CovidVaccine tble
-- Looking at total Poplation vs Vaccinations
--Rolling count
SELECT 
	dea.continent
	,dea.location
	,dea.date
	,dea.population
	,vac.new_vaccinations
	,SUM(CAST(vac.new_vaccinations AS bigint)) 
		OVER 
		(PARTITION BY dea.location ORDER BY dea.location
		,dea.date) AS RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/population)*100 Cant use a column I have created for the next one
From
	PortfolioProject..CovidDeaths AS Dea
JOIN 
	PortfolioProject..CovidVaccinations AS Vac
ON 
	Dea.location = Vac.location
AND 
	Dea.date = Vac.date
WHERE
	dea.continent IS NOT NULL
ORDER BY 2,3


--USE CTE

WITH PopulationVsVaccination 
	(Continent
	,Location
	,Date
	,Population
	,new_vaccinations
	,RollingPeopleVaccinated)
AS
(
SELECT 
	dea.continent
	,dea.location
	,dea.date
	,dea.population
	,vac.new_vaccinations
	,SUM(CAST(vac.new_vaccinations AS bigint)) 
		OVER 
		(PARTITION BY dea.location ORDER BY dea.location
		,dea.date) AS RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/population)*100 Cant use a column I have created for the next one
From
	PortfolioProject..CovidDeaths AS Dea
JOIN 
	PortfolioProject..CovidVaccinations AS Vac
ON 
	Dea.location = Vac.location
AND 
	Dea.date = Vac.date
WHERE
	dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT
	*
	,(RollingPeopleVaccinated/Population)*100
FROM
PopulationVsVaccination

--TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255)
	,Location nvarchar(255)
	,Date datetime
	,Population numeric
	,New_vaccination numeric
	,RollingPeopleVaccinated numeric
)

INSERT INTO
#PercentPopulationVaccinated

SELECT 
	dea.continent
	,dea.location
	,dea.date
	,dea.population
	,vac.new_vaccinations
	,SUM(CAST(vac.new_vaccinations AS bigint)) 
		OVER 
		(PARTITION BY dea.location ORDER BY dea.location
		,dea.date) AS RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/population)*100 Cant use a column I have created for the next one
From
	PortfolioProject..CovidDeaths AS Dea
JOIN 
	PortfolioProject..CovidVaccinations AS Vac
ON 
	Dea.location = Vac.location
AND 
	Dea.date = Vac.date
WHERE
	dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT
	*
	,(RollingPeopleVaccinated/Population)*100
FROM
#PercentPopulationVaccinated

--TEMP TABLE WITH DROP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255)
	,Location nvarchar(255)
	,Date datetime
	,Population numeric
	,New_vaccination numeric
	,RollingPeopleVaccinated numeric
)

INSERT INTO
#PercentPopulationVaccinated

SELECT 
	dea.continent
	,dea.location
	,dea.date
	,dea.population
	,vac.new_vaccinations
	,SUM(CAST(vac.new_vaccinations AS bigint)) 
		OVER 
		(PARTITION BY dea.location ORDER BY dea.location
		,dea.date) AS RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/population)*100 Cant use a column I have created for the next one
From
	PortfolioProject..CovidDeaths AS Dea
JOIN 
	PortfolioProject..CovidVaccinations AS Vac
ON 
	Dea.location = Vac.location
AND 
	Dea.date = Vac.date
--WHERE
--	dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT
	*
	,(RollingPeopleVaccinated/Population)*100
FROM
#PercentPopulationVaccinated

--Creating view to store data for later visualisaztions

CREATE VIEW PercentPopulationVaccinated AS

SELECT 
	dea.continent
	,dea.location
	,dea.date
	,dea.population
	,vac.new_vaccinations
	,SUM(CAST(vac.new_vaccinations AS bigint)) 
		OVER 
		(PARTITION BY dea.location ORDER BY dea.location
		,dea.date) AS RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/population)*100 Cant use a column I have created for the next one
From
	PortfolioProject..CovidDeaths AS Dea
JOIN 
	PortfolioProject..CovidVaccinations AS Vac
ON 
	Dea.location = Vac.location
AND 
	Dea.date = Vac.date
WHERE
	dea.continent IS NOT NULL
--ORDER BY 2,3