-- WARNING: Do not leave DDL queries active in your script while querying a database to prevent loss/corruption of data

-- Total number of rides within the review period: 5,667,986
SELECT COUNT (*)
FROM cyclistic..bikes;

-- Inspecting the top 10 rows of dataset
SELECT TOP (10) *
FROM cyclistic..bikes;

/*  Total Start Stations = 853, Total End Stations = 854. Total of 856 stations in all
	These three end stations were not recorded as start stations 
		1. Campbell Ave & Irving Park Rd
		2. La Villita Park (Albany/30th)
		3. Albany Ave & 16th St
	while these two start stations were not recorded as end stations 
		1. N Hampden Ct & W Diversey Ave
		2. 351 (this indicates an error in station name, start station id was entered as start station name)
	*/

SELECT end_station_name
FROM cyclistic..bikes
EXCEPT 
SELECT start_station_name FROM cyclistic..bikes;

SELECT start_station_name
FROM cyclistic..bikes
EXCEPT 
SELECT end_station_name FROM cyclistic..bikes;

-- 

SELECT * FROM cyclistic..bikes WHERE start_station_name = '351'; -- start_lat and start_lng recorded for these trips are 41.93 and -87.78 respectively
SELECT * FROM cyclistic..bikes WHERE start_lat = 41.93 AND start_lng = -87.78; -- the correct start station name should be 'Meade Ave & Diversey Ave'

-- Updating start station names, '351' with 'Meade Ave & Diversey Ave'

/* UPDATE cyclistic..bikes
SET start_station_name = 'Meade Ave & Diversey Ave' WHERE start_station_name = '351'; */

-- Now we have: Total Start Stations = 852, Total End Stations = 854. Total of 855 stations in all

SELECT * FROM cyclistic..bikes WHERE end_station_name = 'Meade Ave & Diversey Ave'; -- to confirm its existence in the End station column

-- Comparing the total values in each column
SELECT COUNT(ride_id), COUNT(rideable_type), COUNT(started_at), COUNT(ended_at), COUNT(start_station_name),
		COUNT(start_station_id), COUNT(end_station_name), COUNT(end_station_id), COUNT(start_lat), COUNT(start_lng),
		COUNT(end_lat), COUNT(end_lng), COUNT(member_casual)
FROM cyclistic..bikes;

-- Trips without identifiable end locations = 4,617 
SELECT COUNT (*) FROM
cyclistic..bikes
WHERE end_lat IS NULL AND end_lng IS NULL

-- Total null start station names =  712,978 and Total null start station Ids =  712,975
-- Total null end station names =  761,817 and Total null end station Ids =  761,817

SELECT COUNT(*) FROM cyclistic..bikes WHERE start_station_name IS NULL;
SELECT COUNT(*) FROM cyclistic..bikes WHERE start_station_id IS NULL;

SELECT COUNT(*) FROM cyclistic..bikes WHERE end_station_name IS NULL;
SELECT COUNT(*) FROM cyclistic..bikes WHERE end_station_id IS NULL;

-- Creating a view for distinct rows where station name is not missing. Start = 28,879. End = 87,055

USE cyclistic;
CREATE VIEW s_lat_lng AS
SELECT DISTINCT start_lat, start_lng, start_station_name, start_station_id
FROM cyclistic..bikes
WHERE start_station_name IS NOT NULL;

CREATE VIEW e_lat_lng AS
SELECT DISTINCT end_lat, end_lng, end_station_name, end_station_id
FROM cyclistic..bikes
WHERE end_station_name IS NOT NULL;

-- Inspecting duplicate recorded station names for same latitude and longitude. Start = 1408. End =  12,096

SELECT start_lat, start_lng, COUNT(*) AS no_of_station_names
FROM s_lat_lng
GROUP BY start_lat, start_lng
HAVING COUNT(start_lat) > 1 AND COUNT(start_lng) > 1
ORDER BY no_of_station_names DESC;

SELECT end_lat, end_lng, COUNT(*) AS no_of_station_names
FROM e_lat_lng
GROUP BY end_lat, end_lng
HAVING COUNT(end_lat) > 1 AND COUNT(end_lng) > 1
ORDER BY no_of_station_names DESC;

-- Inspecting correctly recorded station names per unique latitude and longitude. Start = 25,989. End = 59,646

SELECT start_lat, start_lng, COUNT(*) AS no_of_station_names
FROM s_lat_lng
GROUP BY start_lat, start_lng
HAVING COUNT(start_lat) = 1 AND COUNT(start_lng) = 1;

SELECT end_lat, end_lng, COUNT(*) AS no_of_station_names
FROM e_lat_lng
GROUP BY end_lat, end_lng
HAVING COUNT(end_lat) = 1 AND COUNT(end_lng) = 1;
 
-- Using same query, the results are saved into a view for easier joining with their respective station names

SELECT start_lat, start_lng, COUNT(*) AS no_of_station_names
INTO s_ones
FROM s_lat_lng
GROUP BY start_lat, start_lng
HAVING COUNT(start_lat) = 1 AND COUNT(start_lng) = 1;

SELECT end_lat, end_lng, COUNT(*) AS no_of_station_names
INTO e_ones
FROM e_lat_lng
GROUP BY end_lat, end_lng
HAVING COUNT(end_lat) = 1 AND COUNT(end_lng) = 1;

-- The 's_ones' and 'e_ones' table are joined separately here with the 's_lat_lng' table to populate the station names

CREATE VIEW s_uni_names AS
SELECT o.start_lat, o.start_lng, s.start_station_name, s.start_station_id
FROM s_ones AS o
LEFT JOIN s_lat_lng AS s
ON o.start_lat = s.start_lat AND o.start_lng = s.start_lng;

CREATE VIEW e_uni_names AS
SELECT o.end_lat, o.end_lng, e.end_station_name, e.end_station_id
FROM e_ones AS o
LEFT JOIN e_lat_lng AS e
ON o.end_lat = e.end_lat AND o.end_lng = e.end_lng;

-- Inspecting for correctness in the joins
SELECT COUNT(*) FROM s_uni_names
SELECT TOP (10) * FROM s_uni_names
SELECT * FROM bikes WHERE start_lat = 41.8916 AND start_lng = -87.6484 AND start_station_name IS NOT NULL

SELECT COUNT(*) FROM e_uni_names
SELECT TOP (10) * FROM e_uni_names
SELECT * FROM bikes WHERE end_lat = 41.8094 AND end_lng = -87.5919 AND end_station_name IS NOT NULL

-- Populating the available Station name and Ids into the 'bikes' table using Semi Joins and saved into a new table: 'bikes_cleaned'

SELECT ride_id, rideable_type, started_at, ended_at, 
	CASE WHEN b.start_station_name IS NULL AND b.start_lat IN (SELECT start_lat FROM s_uni_names)
		AND b.start_lng IN (SELECT start_lng FROM s_uni_names) THEN s.start_station_name 
		ELSE b.start_station_name END AS start_station_name,
	CASE WHEN b.start_station_id IS NULL AND b.start_lat IN (SELECT start_lat FROM s_uni_names)
		AND b.start_lng IN (SELECT start_lng FROM s_uni_names) THEN s.start_station_id 
		ELSE b.start_station_id END AS start_station_id,
	CASE WHEN b.end_station_name IS NULL AND b.end_lat IN (SELECT end_lat FROM e_uni_names)
		AND b.end_lng IN (SELECT end_lng FROM e_uni_names) THEN e.end_station_name 
		ELSE b.end_station_name END AS end_station_name,
	CASE WHEN b.end_station_id IS NULL AND b.end_lat IN (SELECT end_lat FROM e_uni_names)
		AND b.end_lng IN (SELECT end_lng FROM e_uni_names) THEN e.end_station_id 
		ELSE b.end_station_id END AS end_station_id,
	b.start_lat, b.start_lng, b.end_lat, b.end_lng, member_casual
	INTO bikes_cleaned
FROM bikes AS b
LEFT JOIN s_uni_names AS s
ON b.start_lat = s.start_lat AND b.start_lng = s.start_lng
LEFT JOIN e_uni_names AS e
ON b.end_lat = e.end_lat AND b.end_lng = e.end_lng;

-- Re-inspecting, Total null start station names =  556,685 and Total null start station Ids =  556,685
-- Total null end station names =  610,731 and Total null end station Ids =  610,731

SELECT COUNT(*) FROM cyclistic..bikes_cleaned WHERE start_station_name IS NULL;
SELECT COUNT(*) FROM cyclistic..bikes_cleaned WHERE start_station_id IS NULL;

SELECT COUNT(*) FROM cyclistic..bikes_cleaned WHERE end_station_name IS NULL;
SELECT COUNT(*) FROM cyclistic..bikes_cleaned WHERE end_station_id IS NULL;

-- Creating a column to calculate the trip durations in approximate minutes and day of the week each trip was started
SELECT *, DATEDIFF (second, started_at, ended_at) AS trip_dur_secs, DATENAME(WEEKDAY,started_at)  AS ride_start_dow
INTO bikes_done
FROM cyclistic..bikes_cleaned;

-- Trip with duration of 0 secs = 508 while Trip with negative duration = 145
SELECT COUNT(*) 
FROM cyclistic..bikes_done
WHERE trip_dur_secs = 0;

SELECT COUNT(*) 
FROM cyclistic..bikes_done
WHERE trip_dur_secs < 0;

-- Mean duration of all trips = 21mins
SELECT (AVG(trip_dur_secs) / 60) AS 'mean length of rides (mins)'
FROM cyclistic..bikes_done;

-- Max ride duration = 55,944mins (= 932hrs 24mins = 38days, 20hrs 24mins) . Min ride duration = 0.016mins

SELECT MAX(trip_dur_secs) / 60.0 AS 'max length of rides (mins)'
FROM cyclistic..bikes_done;

SELECT MIN(trip_dur_secs) / 60.0 AS 'min length of rides (mins)'
FROM cyclistic..bikes_done
WHERE trip_dur_secs > 0;

-- Average ride duration. Members = 13.48mins , Casual = 31.92mins

SELECT member_casual, AVG(trip_dur_secs) / 60.0
FROM bikes_done
GROUP BY member_casual

-- Average ride duration. Monday = 20.58mins , Tuesday = 18.22mins, Wednesday = 18.13mins, Thursday = 18.50mins, Friday = 20.80mins, 
-- Saturday = 26.02mins, Sunday = 27.75mins

SELECT ride_start_dow, AVG(trip_dur_secs) / 60.0
FROM bikes_done
GROUP BY ride_start_dow;

-- Average ride duration, grouped by membership status and day of week ride started
SELECT member_casual, ride_start_dow, AVG(trip_dur_secs) / 60.0
FROM bikes_done
GROUP BY member_casual, ride_start_dow
ORDER BY member_casual, ride_start_dow;