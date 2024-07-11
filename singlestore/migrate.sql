CREATE DATABASE IF NOT EXISTS migration;
USE migration;

-- Create CDC connector between MySQL RDS and SingleStore
CREATE LINK mysql_link AS MYSQL 
CONFIG '{
"database.hostname": <hostname>, 
"database.port": 3306, 
      "database.ssl.mode":"required" 
}' 
CREDENTIALS '{
"database.password": "TestPassword123$", 
"database.user": "testuser"
}';

-- Create tables from LINK connector
CREATE TABLES IF NOT EXISTS AS INFER PIPELINE AS LOAD DATA 
LINK mysql_link "*" FORMAT AVRO;

-- Start pipelines 
-- TODO: Specify pipelines
START ALL PIPELINES;

SELECT COUNT(*) FROM ride_data;
SELECT COUNT(*) FROM user_data;