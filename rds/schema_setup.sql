-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS hvdb;

-- Select the database
USE hvdb;

-- Create ride_data table
CREATE TABLE ride_data (
    ride_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50),
    vehicle_id VARCHAR(50),
    timestamp DATETIME,
    pickup_location_lat FLOAT,
    pickup_location_long FLOAT,
    dropoff_location_lat FLOAT,
    dropoff_location_long FLOAT,
    ride_status VARCHAR(50)
);

-- Create user_data table
CREATE TABLE user_data (
    user_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    registration_date DATETIME
);

-- Load data into ride_data
LOAD DATA LOCAL INFILE '../rds/ride_data.csv'
INTO TABLE ride_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ride_id, user_id, vehicle_id, @timestamp, pickup_location_lat, pickup_location_long, dropoff_location_lat, dropoff_location_long, ride_status)
SET timestamp = STR_TO_DATE(@timestamp, '%Y-%m-%dT%H:%i:%s');

-- Load data into user_data
LOAD DATA LOCAL INFILE '../rds/user_data.csv'
INTO TABLE user_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(user_id, name, email, @registration_date)
SET registration_date = STR_TO_DATE(@registration_date, '%Y-%m-%dT%H:%i:%s');