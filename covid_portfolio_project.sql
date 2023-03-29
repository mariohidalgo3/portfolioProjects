/* copying csv file to tables and consulting*/

-- COPY vaccinations(iso_code,continent,location,date,new_tests,total_tests,total_tests_per_thousand,new_tests_per_thousand,new_tests_smoothed,new_tests_smoothed_per_thousand,positive_rate,tests_per_case,tests_units,total_vaccinations,people_vaccinated,people_fully_vaccinated,new_vaccinations,new_vaccinations_smoothed,total_vaccinations_per_hundred,people_vaccinated_per_hundred,people_fully_vaccinated_per_hundred,new_vaccinations_smoothed_per_million,stringency_index,population_density,median_age,aged_65_older,aged_70_older,gdp_per_capita,extreme_poverty,cardiovasc_death_rate,diabetes_prevalence,female_smokers,male_smokers,handwashing_facilities,hospital_beds_per_thousand,life_expectancy,human_development_index)
-- FROM 'C:\Users\mario\Desktop\vaccinations.csv'
-- DELIMITER ','
-- CSV HEADER;

-- ALTER TABLE vaccinations
-- ALTER COLUMN tests_units TYPE VARCHAR(20);

SELECT *
FROM vaccinations;


/* looking at total cases vs total deaths. Building a deaths/cases ratio */

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deaths_percentage
FROM deaths
WHERE continent IS NOT NULL
ORDER BY deaths_percentage DESC;

/* looking at total cases vs population. Building cases/population ratio */

SELECT location, date, total_cases, population, (total_cases/population)*100 as casesPopulation_percentage
FROM deaths
WHERE continent IS NOT NULL
ORDER BY casesPopulation_percentage DESC;

/* looking at countries with highest infection count compared to population */

SELECT location, population, MAX(total_cases) as highestInfectionCount, MAX((total_cases/population)*100) as casesPopulation_percentage
FROM deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY casesPopulation_percentage DESC;

/* looking at countries with highest death count per polutation */

SELECT location, MAX(total_deaths) as highestDeathsCount
FROM deaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY highestDeathsCount DESC;

/* looking at continents with highest death count per polutation */

SELECT continent, MAX(total_deaths) as highestDeathsCount
FROM deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highestDeathsCount DESC;

/* global numbers */

SELECT /*date,*/ SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as deathsCases_ratio -- population, (total_cases/population)*100 as casesPopulation_percentage
FROM deaths
WHERE continent IS NOT NULL and new_cases is NOT NULL
-- GROUP BY date
ORDER BY deathsCases_ratio DESC;

/*consulting vaccinations table*/

SELECT *
FROM vaccinations as vac

/*joining vaccinations with deaths*/

SELECT *
FROM vaccinations as vac
JOIN deaths as dea
	ON dea.location = vac.location 
	and dea.date = vac.date;
	
/* looking at total population vs vaccinations*/

-- you can't use a column you just created to use it for a another calculated column. So, create a CTE and then make the consult
WITH popVsVac as
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as accum_vaccinations
	FROM vaccinations as vac
	JOIN deaths as dea
		ON dea.location = vac.location 
		and dea.date = vac.date
	WHERE dea.continent IS NOT NULL and vac.new_vaccinations IS NOT NULL
)
 --using CTE
 
SELECT *, (accum_vaccinations/population)*100 as percent_vaccinated
FROM popVsVac;

/* Creating view to store data for tableau */

CREATE VIEW percentPopulationVaccinated as

WITH pvv as
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as accum_vaccinations
	FROM vaccinations as vac
	JOIN deaths as dea
		ON dea.location = vac.location 
		and dea.date = vac.date
	WHERE dea.continent IS NOT NULL and vac.new_vaccinations IS NOT NULL
)
 
SELECT *, (accum_vaccinations/population)*100 as percent_vaccinated
FROM pvv;
	

	



