/* Assignmnet 7
# Madusha Sammani
# November 7, 2024 */
/*This file is about using PostGIS to perform neighborhood-level spatial analysis in NYC: 
area/perimeter measurements, spatial joins for counting points (subway stations, homicides), population aggregation, and density calculations. */
CREATE EXTENSION postgis;
/* Question 1 */
SELECT 
boroname, 
ST_Area(geom) AS "Area_Sq_Meters",
ST_AsKML(geom) AS "KML"
FROM nyc_neighborhoods
WHERE name = 'East Village';
/* Question 2 */
SELECT 
boroname, 
name,
ST_Perimeter(geom) AS "Perimeter_Meters"
FROM nyc_neighborhoods
WHERE name = 'Midtown' AND boroname = 'Manhattan';
/* Question 3 */
SELECT 
neighborhoods.name AS neighborhood,
count(subways.gid)AS station_count
FROM nyc_neighborhoods AS neighborhoods
JOIN nyc_subway_stations AS subways
ON ST_Contains(neighborhoods.geom, subways.geom)
GROUP BY neighborhoods.name
ORDER BY station_count DESC
LIMIT 1
/* Answer is Financial District */
/* Question 4 */
SELECT 
neighborhoods.boroname AS boroname,
count(homicides.gid)AS homicides_count
FROM nyc_neighborhoods AS neighborhoods
JOIN nyc_homicides AS homicides
ON ST_Contains(neighborhoods.geom, homicides.geom)
WHERE neighborhoods.boroname = 'Staten Island'
GROUP BY neighborhoods.boroname;
/* Answer is 101 */
/* Question 5 */
SELECT 
neighborhoods.name AS name,
SUM(census_blocks.popn_total)AS total_population
FROM nyc_neighborhoods AS neighborhoods
JOIN nyc_census_blocks AS census_blocks
ON ST_Contains(neighborhoods.geom, census_blocks.geom)
GROUP BY neighborhoods.name
ORDER BY total_population DESC
LIMIT 5;
/* Question 6 */
WITH density_data AS (
SELECT n.name AS name, SUM(c.popn_total) / (ST_Area(n.geom) / 1000000.0) AS density
FROM nyc_neighborhoods AS n
JOIN nyc_census_blocks AS c ON ST_Contains(n.geom, c.geom)
GROUP BY n.name, n.geom)
(
SELECT name,density AS largest
FROM density_data
WHERE density = (SELECT MAX(density) FROM density_data)
)
UNION
(
SELECT name, density AS smallest
FROM density_data
WHERE density = (SELECT MIN(density) FROM density_data)
