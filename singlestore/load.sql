-- Create CDC connector between MySQL RDS and SingleStore
CREATE LINK hybrid_vector AS MYSQL 
    CONFIG '{
        "database.hostname": "%HOSTNAME%", 
        "database.port": 3306, 
        "database.ssl.mode":"required" 
    }'
    CREDENTIALS '{
        "database.password": "%PASSWORD%", 
        "database.user": "%USER%"
    }';

-- Create tables from LINK connector
CREATE TABLES IF NOT EXISTS AS INFER PIPELINE AS LOAD DATA 
LINK hybrid_vector "*" FORMAT AVRO;

-- Start pipelines 
-- TODO: Specify pipelines
START ALL PIPELINES;