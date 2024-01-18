--Select the data that we are going to be using 
--Order by location and date
SELECT 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM 
	covid_deaths
WHERE 
	continent IS NOT NULL 
ORDER BY 
	location,
	date;

--Looking at Total Case vs Total Deaths
-- Shows likelihood of dying you contract covid in your country
SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths::FLOAT / total_cases) * 100 AS DeathPercentage 
FROM 
    covid_deaths
--WHERE location LIKE 'Poland'
WHERE 
	continent IS NOT NULL 
ORDER BY 
    location, 
    date;

--Looking at Total Cases VS Population 
-- Shows what % of population got Covid
SELECT 
    location,
    date,
    total_cases,
    population,
    (total_cases::FLOAT / population) * 100 AS DeathPercentage 
FROM 
    covid_deaths
--WHERE location = 'Poland'
WHERE 
	continent IS NOT NULL 
ORDER BY 
    location, 
    date;

-- Looking at Countries with Highest Infection Rate compared to Population 
SELECT 
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases::FLOAT / population)) * 100 AS PercentPopulationInfected
FROM 
    covid_deaths
--WHERE location = 'Poland'
WHERE 
    total_cases IS NOT NULL
AND 
	continent IS NOT NULL 
GROUP BY
	location,
	population
ORDER BY 
    PercentPopulationInfected DESC;

-- Showing Countries with Highest Death Countr per Population

SELECT 
    location,
    MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM 
    covid_deaths
--WHERE location = 'Poland'
WHERE 
    total_deaths IS NOT NULL
AND 
	continent IS NOT NULL 
GROUP BY
    location
ORDER BY 
    TotalDeathCount DESC;


-- LET'S BREAK THINGS DOWN BY CONTINENT



--Showing continents with the highest death countr per population

SELECT 
    continent,
    MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM 
    covid_deaths
--WHERE location = 'Poland'
WHERE 
    total_deaths IS NOT NULL
AND 
	continent IS NOT NULL 
GROUP BY
    continent
ORDER BY 
    TotalDeathCount DESC;
	


-- GLOBAL NUMBERS 

SELECT 
    SUM(new_cases) AS total_cases,
	SUM(cast(new_deaths as int)) AS total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercantage
    --total_deaths,
    --(total_deaths::FLOAT / total_cases) * 100 AS DeathPercentage 
FROM 
    covid_deaths
--WHERE location = 'Poland'
WHERE 
	continent IS NOT NULL;
--GROUP BY date
--ORDER BY date;

--Looking at Total Population vs Vaccinations

SELECT 
    dea.continent, 
    dea.location, 
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS running_total_vaccinations
FROM 
    covid_deaths dea
JOIN 
    covid_vaccinations vac 
ON 
    dea.location = vac.location AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
ORDER BY
    dea.location,
    dea.date;

--USE CTE

WITH PopvsVac AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS running_total_vaccinations
    FROM 
        covid_deaths dea
    JOIN 
        covid_vaccinations vac 
    ON 
        dea.location = vac.location AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT 
    continent,
    location,
    date,
    population,
    new_vaccinations,
    running_total_vaccinations,
    (running_total_vaccinations::FLOAT / population) * 100 AS vaccination_percentage
FROM 
    PopvsVac;

--Creating View to store data for later visualizations

CREATE VIEW vaccination_percentage AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS running_total_vaccinations
FROM 
    covid_deaths dea
JOIN 
    covid_vaccinations vac 
ON 
    dea.location = vac.location AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;
--ORDER BY
    --dea.location,
    --dea.date;

--Ready view

SELECT * 
FROM 
	public.vaccination_percentage;
