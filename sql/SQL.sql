SET sql_mode = '';
SET FOREIGN_KEY_CHECKS = 0;
CREATE DATABASE air_transport_risk;
USE air_transport_risk;

SHOW VARIABLES LIKE 'secure_file_priv';
SET GLOBAL local_infile = 1;

USE air_transport_risk;

DROP TABLE IF EXISTS dim_airport;

CREATE TABLE dim_airport (
    airport_id INT PRIMARY KEY,
    airport_name VARCHAR(255),
    city VARCHAR(255),
    country_name VARCHAR(255),
    iata VARCHAR(10),
    icao VARCHAR(10),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6)
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_airport.csv'
INTO TABLE dim_airport
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(airport_id, airport_name, city, country_name, iata, icao, latitude, longitude);

SELECT COUNT(*) FROM dim_airport;

SELECT * FROM dim_airport LIMIT 10;

SHOW WARNINGS LIMIT 10;

CREATE TABLE fact_routes (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    airline_id INT,
    source_airport_id INT,
    destination_airport_id INT,
    equipment_code VARCHAR(10)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_routes.csv'
INTO TABLE fact_routes
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(airline_id, source_airport_id, destination_airport_id, equipment_code);

TRUNCATE TABLE fact_routes;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_routes.csv'
INTO TABLE fact_routes
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
  @airline_id,
  @source_airport_id,
  @destination_airport_id,
  @equipment_code
)
SET
  airline_id = NULLIF(@airline_id, ''),
  source_airport_id = NULLIF(@source_airport_id, ''),
  destination_airport_id = NULLIF(@destination_airport_id, ''),
  equipment_code = NULLIF(@equipment_code, '');


DROP TABLE IF EXISTS fact_routes;

CREATE TABLE fact_routes (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    airline_id INT,
    source_airport_id INT,
    destination_airport_id INT,
    equipment_code VARCHAR(50)
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_routes.csv'
INTO TABLE fact_routes
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
  @airline_id,
  @source_airport_id,
  @destination_airport_id,
  @equipment_code
)
SET
  airline_id = NULLIF(@airline_id, ''),
  source_airport_id = NULLIF(@source_airport_id, ''),
  destination_airport_id = NULLIF(@destination_airport_id, ''),
  equipment_code = NULLIF(@equipment_code, '');
  
  SELECT COUNT(*) FROM fact_routes;
SELECT equipment_code, LENGTH(equipment_code)
FROM fact_routes
ORDER BY LENGTH(equipment_code) DESC
LIMIT 5;

SELECT COUNT(*) FROM dim_aircraft;

SELECT equipment_code, COUNT(*)
FROM dim_aircraft
GROUP BY equipment_code
HAVING COUNT(*) > 1;

SELECT * FROM dim_aircraft LIMIT 10;

SELECT COUNT(*) FROM dim_airline;

SELECT airline_id, COUNT(*)
FROM dim_airline
GROUP BY airline_id
HAVING COUNT(*) > 1;

SELECT active_flag, COUNT(*)
FROM dim_airline
GROUP BY active_flag;

SELECT airline_id, airline_name, iata, icao, active_flag
FROM dim_airline
LIMIT 10;


SELECT 
    *
FROM
    dim_aircraft
WHERE
    equipment_code = 'E135';

DELETE FROM dim_aircraft
WHERE equipment_code = 'E135'
  AND model_name = 'Embraer RJ140';


DROP TABLE IF EXISTS dim_aircraft;
DROP TABLE IF EXISTS dim_airline;
DROP TABLE IF EXISTS dim_country;

CREATE TABLE dim_country (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(255),
    iso_code_2 VARCHAR(5),
    iso_code_3 VARCHAR(5)
);
CREATE TABLE dim_airline (
    airline_id INT PRIMARY KEY,
    airline_name VARCHAR(255),
    iata VARCHAR(10),
    icao VARCHAR(10),
    active_flag CHAR(1)
);

CREATE TABLE dim_aircraft (
    equipment_code VARCHAR(10) PRIMARY KEY,
    model_name VARCHAR(255)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_country.csv'
INTO TABLE dim_country
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(country_name, iso_code_2, iso_code_3);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_airline.csv'
INTO TABLE dim_airline
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
  @airline_id,
  @airline_name,
  @iata,
  @icao,
  @active_flag
)
SET
  airline_id = NULLIF(@airline_id, ''),
  airline_name = NULLIF(@airline_name, ''),
  iata = NULLIF(@iata, ''),
  icao = NULLIF(@icao, ''),
  active_flag = NULLIF(@active_flag, '');

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_aircraft.csv'
INTO TABLE dim_aircraft
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(equipment_code, model_name);

TRUNCATE TABLE dim_aircraft;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_aircraft.csv'
INTO TABLE dim_aircraft
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(model_name, equipment_code);

DROP TABLE IF EXISTS dim_aircraft_staging;

CREATE TABLE dim_aircraft_staging (
    model_name VARCHAR(255),
    equipment_code VARCHAR(10)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_aircraft.csv'
INTO TABLE dim_aircraft_staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(model_name, equipment_code);

SELECT COUNT(*) FROM dim_aircraft_staging;

INSERT INTO dim_aircraft (equipment_code, model_name)
SELECT
    equipment_code,
    MIN(model_name) AS model_name
FROM dim_aircraft_staging
GROUP BY equipment_code;

SELECT COUNT(*) FROM dim_aircraft;

SELECT equipment_code, COUNT(*)
FROM dim_aircraft
GROUP BY equipment_code
HAVING COUNT(*) > 1;

SELECT * FROM dim_aircraft LIMIT 10;

DROP TABLE dim_aircraft_staging;

ALTER TABLE dim_airport ADD COLUMN country_id INT;

UPDATE dim_airport a
JOIN dim_country c
  ON a.country_name = c.country_name
SET a.country_id = c.country_id;

SELECT * FROM dim_airline
SELECT * FROM dim_aircraft
SELECT * FROM dim_airport
SELECT * FROM dim_country
SELECT * FROM fact_routes

SELECT
    COUNT(*) AS total_routes,
    SUM(destination_airport_id IS NULL) AS null_destination,
    SUM(source_airport_id IS NULL) AS null_source,
    SUM(airline_id IS NULL) AS null_airline,
    SUM(equipment_code IS NULL) AS null_equipment
FROM fact_routes;

CREATE TABLE fact_routes_clean AS
SELECT *
FROM fact_routes
WHERE source_airport_id IS NOT NULL
  AND destination_airport_id IS NOT NULL
  AND airline_id IS NOT NULL;

SELECT
    COUNT(*) AS clean_routes,
    SUM(source_airport_id IS NULL) AS null_source,
    SUM(destination_airport_id IS NULL) AS null_destination,
    SUM(airline_id IS NULL) AS null_airline
FROM fact_routes_clean;

SELECT COUNT(*) AS orphan_source_airports
FROM fact_routes_clean f
LEFT JOIN dim_airport a
  ON f.source_airport_id = a.airport_id
WHERE a.airport_id IS NULL;

SELECT COUNT(*) AS orphan_destination_airports
FROM fact_routes_clean f
LEFT JOIN dim_airport a
  ON f.destination_airport_id = a.airport_id
WHERE a.airport_id IS NULL;

SELECT COUNT(*) AS orphan_airlines
FROM fact_routes_clean f
LEFT JOIN dim_airline d
  ON f.airline_id = d.airline_id
WHERE d.airline_id IS NULL;

SELECT COUNT(*) AS orphan_aircraft
FROM fact_routes_clean f
LEFT JOIN dim_aircraft p
  ON f.equipment_code = p.equipment_code
WHERE p.equipment_code IS NULL;

CREATE TABLE fact_routes_final AS
SELECT f.*
FROM fact_routes_clean f
JOIN dim_airport s ON f.source_airport_id = s.airport_id
JOIN dim_airport d ON f.destination_airport_id = d.airport_id;

SELECT COUNT(*) FROM fact_routes_final;

CREATE TABLE airport_outbound AS
SELECT
    source_airport_id AS airport_id,
    COUNT(*) AS outbound_routes
FROM fact_routes_final
GROUP BY source_airport_id;

CREATE TABLE airport_inbound AS
SELECT
    destination_airport_id AS airport_id,
    COUNT(*) AS inbound_routes
FROM fact_routes_final
GROUP BY destination_airport_id;


CREATE TABLE airport_connectivity AS
SELECT
    a.airport_id,
    a.airport_name,
    a.city,
    a.country_id,
    COALESCE(i.inbound_routes, 0)  AS inbound_routes,
    COALESCE(o.outbound_routes, 0) AS outbound_routes,
    COALESCE(i.inbound_routes, 0) + COALESCE(o.outbound_routes, 0)
        AS total_routes
FROM dim_airport a
LEFT JOIN airport_inbound i  ON a.airport_id = i.airport_id
LEFT JOIN airport_outbound o ON a.airport_id = o.airport_id;

SELECT
    COUNT(*) AS airports,
    MIN(total_routes) AS min_routes,
    MAX(total_routes) AS max_routes
FROM airport_connectivity;

SELECT *
FROM airport_connectivity
ORDER BY total_routes DESC
LIMIT 10;

CREATE TABLE airport_ranked AS
SELECT
    airport_id,
    airport_name,
    city,
    country_id,
    inbound_routes,
    outbound_routes,
    total_routes,
    RANK() OVER (ORDER BY total_routes DESC) AS connectivity_rank
FROM airport_connectivity;

SELECT
    SUM(total_routes) AS total_network_routes
FROM airport_connectivity;

SELECT
    connectivity_rank,
    airport_name,
    total_routes,
    ROUND(
        100.0 * total_routes /
        (SELECT SUM(total_routes) FROM airport_connectivity),
        2
    ) AS pct_of_global_routes
FROM airport_ranked
WHERE connectivity_rank <= 10
ORDER BY connectivity_rank;

CREATE TABLE network_totals AS
SELECT SUM(total_routes) AS total_network_routes
FROM airport_connectivity;

CREATE TABLE airport_spof_global AS
SELECT
    a.airport_id,
    a.airport_name,
    a.city,
    a.country_id,
    a.total_routes,
    ROUND(
        1.0 * a.total_routes / n.total_network_routes,
        4
    ) AS global_route_share
FROM airport_connectivity a
CROSS JOIN network_totals n;

SELECT
    airport_name,
    total_routes,
    global_route_share
FROM airport_spof_global
ORDER BY global_route_share DESC
LIMIT 10;

CREATE TABLE airport_country_connectivity AS
SELECT
    a.airport_id,
    a.airport_name,
    a.country_id,
    c.country_name,
    a.total_routes
FROM airport_connectivity a
JOIN dim_country c
  ON a.country_id = c.country_id;

CREATE TABLE country_total_connectivity AS
SELECT
    country_id,
    country_name,
    SUM(total_routes) AS country_total_routes
FROM airport_country_connectivity
GROUP BY country_id, country_name;

CREATE TABLE country_airport_ranked AS
SELECT
    a.country_id,
    a.country_name,
    a.airport_id,
    a.airport_name,
    a.total_routes,
    RANK() OVER (
        PARTITION BY a.country_id
        ORDER BY a.total_routes DESC
    ) AS airport_rank_in_country
FROM airport_country_connectivity a;

CREATE TABLE country_spof_metrics AS
SELECT
    r.country_id,
    r.country_name,
    MAX(CASE WHEN r.airport_rank_in_country = 1 THEN r.airport_name END)
        AS top_airport,
    MAX(CASE WHEN r.airport_rank_in_country = 1 THEN r.total_routes END)
        AS top_airport_routes,
    t.country_total_routes,
    ROUND(
        1.0 * MAX(CASE WHEN r.airport_rank_in_country = 1 THEN r.total_routes END)
        / t.country_total_routes,
        4
    ) AS top1_dependency_ratio
FROM country_airport_ranked r
JOIN country_total_connectivity t
  ON r.country_id = t.country_id
GROUP BY r.country_id, r.country_name, t.country_total_routes;

SELECT *
FROM country_spof_metrics
ORDER BY top1_dependency_ratio DESC
LIMIT 15;

SELECT
    COUNT(*) AS total_airports,
    SUM(country_id IS NULL) AS null_country_id
FROM dim_airport;

SELECT DISTINCT country_name
FROM dim_airport
LIMIT 20;

UPDATE dim_airport a
JOIN dim_country c
  ON a.country_name = c.country_name
SET a.country_id = c.country_id;

SET SQL_SAFE_UPDATES = 0;

UPDATE dim_airport a
JOIN dim_country c
  ON a.country_name = c.country_name
SET a.country_id = c.country_id;

SET SQL_SAFE_UPDATES = 1;

SELECT
    COUNT(*) AS total_airports,
    SUM(country_id IS NULL) AS null_country_id
FROM dim_airport;


DROP TABLE IF EXISTS airport_country_connectivity;

CREATE TABLE airport_country_connectivity AS
SELECT
    a.airport_id,
    a.airport_name,
    a.country_id,
    c.country_name,
    a.total_routes
FROM airport_connectivity a
JOIN dim_country c
  ON a.country_id = c.country_id
WHERE a.country_id IS NOT NULL;

DROP TABLE IF EXISTS country_total_connectivity;

CREATE TABLE country_total_connectivity AS
SELECT
    country_id,
    country_name,
    SUM(total_routes) AS country_total_routes
FROM airport_country_connectivity
GROUP BY country_id, country_name;

DROP TABLE IF EXISTS country_airport_ranked;

CREATE TABLE country_airport_ranked AS
SELECT
    a.country_id,
    a.country_name,
    a.airport_id,
    a.airport_name,
    a.total_routes,
    RANK() OVER (
        PARTITION BY a.country_id
        ORDER BY a.total_routes DESC
    ) AS airport_rank_in_country
FROM airport_country_connectivity a;

DROP TABLE IF EXISTS country_spof_metrics;

CREATE TABLE country_spof_metrics AS
SELECT
    r.country_id,
    r.country_name,
    MAX(CASE WHEN r.airport_rank_in_country = 1 THEN r.airport_name END)
        AS top_airport,
    MAX(CASE WHEN r.airport_rank_in_country = 1 THEN r.total_routes END)
        AS top_airport_routes,
    t.country_total_routes,
    ROUND(
        1.0 * MAX(CASE WHEN r.airport_rank_in_country = 1 THEN r.total_routes END)
        / t.country_total_routes,
        4
    ) AS top1_dependency_ratio
FROM country_airport_ranked r
JOIN country_total_connectivity t
  ON r.country_id = t.country_id
GROUP BY r.country_id, r.country_name, t.country_total_routes;

SELECT *
FROM country_spof_metrics
ORDER BY top1_dependency_ratio DESC
LIMIT 15;

DROP TABLE IF EXISTS airport_connectivity;

CREATE TABLE airport_connectivity AS
SELECT
    a.airport_id,
    a.airport_name,
    a.city,
    a.country_id,
    COALESCE(i.inbound_routes, 0)  AS inbound_routes,
    COALESCE(o.outbound_routes, 0) AS outbound_routes,
    COALESCE(i.inbound_routes, 0) + COALESCE(o.outbound_routes, 0)
        AS total_routes
FROM dim_airport a
LEFT JOIN airport_inbound i  ON a.airport_id = i.airport_id
LEFT JOIN airport_outbound o ON a.airport_id = o.airport_id;

SELECT
    COUNT(*) AS airports,
    SUM(country_id IS NULL) AS null_country_id
FROM airport_connectivity;

DROP TABLE IF EXISTS country_spof_metrics;

CREATE TABLE country_spof_metrics AS
SELECT
    r.country_id,
    r.country_name,
    MAX(CASE WHEN r.airport_rank_in_country = 1 THEN r.airport_name END)
        AS top_airport,
    MAX(CASE WHEN r.airport_rank_in_country = 1 THEN r.total_routes END)
        AS top_airport_routes,
    t.country_total_routes,
    ROUND(
        1.0 * MAX(CASE WHEN r.airport_rank_in_country = 1 THEN r.total_routes END)
        / t.country_total_routes,
        4
    ) AS top1_dependency_ratio
FROM country_airport_ranked r
JOIN country_total_connectivity t
  ON r.country_id = t.country_id
WHERE t.country_total_routes > 0
GROUP BY r.country_id, r.country_name, t.country_total_routes;

SELECT *
FROM country_spof_metrics
ORDER BY top1_dependency_ratio DESC
LIMIT 15;

DROP TABLE IF EXISTS country_risk_classification;

CREATE TABLE country_risk_classification AS
SELECT
    country_id,
    country_name,
    top_airport,
    top_airport_routes,
    country_total_routes,
    top1_dependency_ratio,
    CASE
        WHEN top1_dependency_ratio >= 0.70 THEN 'High Risk'
        WHEN top1_dependency_ratio >= 0.40 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_level
FROM country_spof_metrics;

SELECT risk_level, COUNT(*) AS country_count
FROM country_risk_classification
GROUP BY risk_level;

DROP TABLE IF EXISTS airline_airport_routes;

CREATE TABLE airline_airport_routes AS
SELECT
    airline_id,
    source_airport_id AS airport_id,
    COUNT(*) AS route_count
FROM fact_routes_final
GROUP BY airline_id, source_airport_id

UNION ALL

SELECT
    airline_id,
    destination_airport_id AS airport_id,
    COUNT(*) AS route_count
FROM fact_routes_final
GROUP BY airline_id, destination_airport_id;

DROP TABLE IF EXISTS airline_total_routes;

CREATE TABLE airline_total_routes AS
SELECT
    airline_id,
    SUM(route_count) AS airline_total_routes
FROM airline_airport_routes
GROUP BY airline_id;

DROP TABLE IF EXISTS airline_airport_ranked;

CREATE TABLE airline_airport_ranked AS
SELECT
    r.airline_id,
    d.airline_name,
    r.airport_id,
    a.airport_name,
    r.route_count,
    RANK() OVER (
        PARTITION BY r.airline_id
        ORDER BY r.route_count DESC
    ) AS airport_rank_for_airline
FROM airline_airport_routes r
JOIN dim_airline d
  ON r.airline_id = d.airline_id
JOIN dim_airport a
  ON r.airport_id = a.airport_id;

DROP TABLE IF EXISTS airline_dependency_metrics;

CREATE TABLE airline_dependency_metrics AS
SELECT
    r.airline_id,
    r.airline_name,
    MAX(CASE WHEN r.airport_rank_for_airline = 1 THEN r.airport_name END)
        AS primary_hub,
    MAX(CASE WHEN r.airport_rank_for_airline = 1 THEN r.route_count END)
        AS primary_hub_routes,
    t.airline_total_routes,
    ROUND(
        1.0 * MAX(CASE WHEN r.airport_rank_for_airline = 1 THEN r.route_count END)
        / t.airline_total_routes,
        4
    ) AS top1_hub_dependency_ratio
FROM airline_airport_ranked r
JOIN airline_total_routes t
  ON r.airline_id = t.airline_id
WHERE t.airline_total_routes > 0
GROUP BY r.airline_id, r.airline_name, t.airline_total_routes;

SELECT *
FROM airline_dependency_metrics
ORDER BY top1_hub_dependency_ratio DESC
LIMIT 15;

DROP TABLE IF EXISTS airline_risk_classification;

CREATE TABLE airline_risk_classification AS
SELECT
    airline_id,
    airline_name,
    primary_hub,
    primary_hub_routes,
    airline_total_routes,
    top1_hub_dependency_ratio,
    CASE
        WHEN top1_hub_dependency_ratio >= 0.50 THEN 'High Risk'
        WHEN top1_hub_dependency_ratio >= 0.30 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_level
FROM airline_dependency_metrics;

SELECT risk_level, COUNT(*) AS airline_count
FROM airline_risk_classification
GROUP BY risk_level;


DROP TABLE IF EXISTS airline_aircraft_family;

CREATE TABLE airline_aircraft_family AS
SELECT
    airline_id,
    CASE
        WHEN equipment_code LIKE '%A32%' THEN 'Airbus A320 Family'
        WHEN equipment_code LIKE '%A33%' THEN 'Airbus A330 Family'
        WHEN equipment_code LIKE '%A34%' THEN 'Airbus A340 Family'
        WHEN equipment_code LIKE '%A35%' THEN 'Airbus A350 Family'
        WHEN equipment_code LIKE '%B73%' THEN 'Boeing 737 Family'
        WHEN equipment_code LIKE '%B74%' THEN 'Boeing 747 Family'
        WHEN equipment_code LIKE '%B75%' THEN 'Boeing 757 Family'
        WHEN equipment_code LIKE '%B76%' THEN 'Boeing 767 Family'
        WHEN equipment_code LIKE '%B77%' THEN 'Boeing 777 Family'
        WHEN equipment_code LIKE '%B78%' THEN 'Boeing 787 Family'
        WHEN equipment_code LIKE '%CR%'  THEN 'CRJ Family'
        WHEN equipment_code LIKE '%DH%'  THEN 'De Havilland Dash'
        WHEN equipment_code LIKE '%E%'   THEN 'Embraer E-Jet'
        ELSE 'Other / Mixed'
    END AS aircraft_family,
    COUNT(*) AS route_count
FROM fact_routes_final
GROUP BY airline_id, aircraft_family;

DROP TABLE IF EXISTS airline_total_routes_fleet;

CREATE TABLE airline_total_routes_fleet AS
SELECT
    airline_id,
    SUM(route_count) AS airline_total_routes
FROM airline_aircraft_family
GROUP BY airline_id;

DROP TABLE IF EXISTS airline_fleet_dependency;

DROP TABLE IF EXISTS airline_fleet_dependency;

CREATE TABLE airline_fleet_dependency AS
SELECT
    f.airline_id,
    d.airline_name,
    MAX(CASE WHEN f.route_count = m.max_routes THEN f.aircraft_family END)
        AS primary_aircraft_family,
    m.max_routes AS primary_family_routes,
    t.airline_total_routes,
    ROUND(
        1.0 * m.max_routes / t.airline_total_routes,
        4
    ) AS top1_fleet_dependency_ratio
FROM airline_aircraft_family f
JOIN (
    SELECT
        airline_id,
        MAX(route_count) AS max_routes
    FROM airline_aircraft_family
    GROUP BY airline_id
) m
  ON f.airline_id = m.airline_id
 AND f.route_count = m.max_routes
JOIN airline_total_routes_fleet t
  ON f.airline_id = t.airline_id
JOIN dim_airline d
  ON f.airline_id = d.airline_id
WHERE t.airline_total_routes > 0
GROUP BY
    f.airline_id,
    d.airline_name,
    m.max_routes,
    t.airline_total_routes;

SELECT *
FROM airline_fleet_dependency
ORDER BY top1_fleet_dependency_ratio DESC
LIMIT 15;

DROP TABLE IF EXISTS airline_fleet_risk;

CREATE TABLE airline_fleet_risk AS
SELECT
    airline_id,
    airline_name,
    primary_aircraft_family,
    primary_family_routes,
    airline_total_routes,
    top1_fleet_dependency_ratio,
    CASE
        WHEN top1_fleet_dependency_ratio >= 0.80 THEN 'High Risk'
        WHEN top1_fleet_dependency_ratio >= 0.50 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_level
FROM airline_fleet_dependency;

SELECT risk_level, COUNT(*) AS airline_count
FROM airline_fleet_risk
GROUP BY risk_level;
