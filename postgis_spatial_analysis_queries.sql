/* Created by Madusha Maha Gamage */
/* Q1. well-known text for the street ‘Atlantic Commons’ in the street table */
SELECT ST_AsEWKT(geom)
FROM nyc_streets
WHERE name = 'Atlantic Commons';
/* Q2: neighborhood does POINT(586782 4504202) */
SELECT name
FROM nyc_neighborhoods
WHERE ST_Contains(geom, ST_GeomFromText('POINT(586782 4504202)',26918));
/* Q3: Distance between ‘Columbus Cir’ and ‘Fulton Ave */
SELECT ST_DISTANCE (
(SELECT geom FROM nyc_streets WHERE name = 'Columbus Cir'),
(SELECT geom FROM nyc_streets WHERE name = 'Fulton Ave')
)
/* Q4: The ten neighborhoods with the highest number of homicide incidents.*/
SELECT a.name, count(b.ID) AS N_HOMICIDES
FROM nyc_neighborhoods AS a
JOIN nyc_homicides AS b
ON ST_INTERSECTS(a.geom, b.geom)
GROUP BY a.name
ORDER BY N_HOMICIDES DESC
LIMIT 10
/* Q 5: Number of homicide incidents within 1,000 m of POINT(586782 4504202) */
SELECT COUNT(*) AS N_HOMICIDES
FROM nyc_homicides AS a
WHERE ST_DWithin (geom, ST_GeomFromText('POINT(586782 4504202)',26918),1000)
/* Q6: longest road/street and list its name and length */
WITH street_lengths AS (
SELECT name, (ST_LENGTH(geom)) AS total_length
FROM nyc_streets
WHERE name IS NOT NULL
)
SELECT name, total_length
FROM street_lengths
WHERE total_length=(SELECT MAX(total_length) FROM street_lengths);
/* Q7:list the neighborhoods that this longest road/street passes through */
SELECT a.name
FROM nyc_neighborhoods AS a
JOIN nyc_streets AS b
ON ST_INTERSECTS(a.geom, b.geom)
WHERE b.name='Leif Ericson Dr'
/* Q8:Length of those roads*/
SELECT a.name, ST_LENGTH(ST_INTERSECTION(a.geom, b.geom)) AS length_meters
FROM nyc_neighborhoods AS a
JOIN nyc_streets AS b
ON ST_INTERSECTS(a.geom, b.geom)
WHERE b.name='Leif Ericson Dr'
