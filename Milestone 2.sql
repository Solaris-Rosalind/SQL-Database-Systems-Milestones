use role snail_role;
use schema msis3333_student.snail_schema;

select * from master_registrations;

-- Create Table for normalized data of 5k registrations, Half marathon registrations, & Full marathon registrations
create or replace table master_registrations(
    RunnerID INT NOT NULL PRIMARY KEY,
    First_Name VARCHAR(55),
    Last_Name VARCHAR(55),
    Birth_Date DATE,
    Gender VARCHAR(10),
    Country_Code VARCHAR(3),
    Distance VARCHAR(15),
    Corral VARCHAR(5),
    ShirtSize VARCHAR(5)
);

select * from MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_5K;

-- Normalize Registrations_5k
-- Remove duplciates
DELETE FROM MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_5K
WHERE (RunnerId) IN (
    SELECT RunnerId
    FROM (
        SELECT 
            RunnerId,
            ROW_NUMBER() OVER (PARTITION BY RunnerId ORDER BY RunnerId) AS rn
        FROM MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_5K
    )
    WHERE rn > 1
);

-- Add distance column
ALTER TABLE MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_5K
ADD Distance VARCHAR(4) DEFAULT '5k';

-- Update gender column
UPDATE MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_5K
SET SEX = CASE
    WHEN SEX = 'F' THEN 'Female'
    WHEN SEX = 'M' THEN 'Male'
    WHEN SEX = 'NB' THEN 'Non-binary'
END;

-- Add corral column
ALTER TABLE MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_5K
ADD Corral VARCHAR(2) DEFAULT 'B';

-- If expected finish time less than 18 minutes then runner is in corral A else they are in B
UPDATE MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_5K
SET Corral = CASE
    WHEN Projected_Finish_Minutes < 18 THEN 'A'
    WHEN Projected_Finish_Minutes < 20 AND SEX = 'Female' THEN 'A'
    ELSE 'B'
END;

select * from MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_HALF;

-- Normalize Registrations_Half
-- Remove duplciates
DELETE FROM MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_HALF
WHERE (RunnerId) IN (
    SELECT RunnerId
    FROM (
        SELECT 
            RunnerId,
            ROW_NUMBER() OVER (PARTITION BY RunnerId ORDER BY RunnerId) AS rn
        FROM MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_HALF
    )
    WHERE rn > 1
);
-- Add distance column
ALTER TABLE MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_HALF
ADD Distance VARCHAR(4) DEFAULT 'Half';

-- Add corral column
ALTER TABLE MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_HALF
ADD Corral VARCHAR(2) DEFAULT 'B';

-- If expected finish time less than 90 minutes then runner is in corral A else they are in B
UPDATE MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_HALF
SET Corral = CASE
    WHEN Est_Finish_in_Min < 90 THEN 'A'
    WHEN Est_Finish_in_Min < 100 AND Gender = 'Female' THEN 'A'
    ELSE 'B'
END;

-- normalize t-shirt sizing
UPDATE MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_HALF
SET Size = CASE
    WHEN Size = 'Small' THEN 'S'
    WHEN Size = 'Medium' THEN 'M'
    WHEN Size = 'Large' THEN 'L'
    ELSE Size
END;

select * from MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_FULL;

-- Normalize Registrations_Full
-- Remove duplciates
DELETE FROM MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_FULL
WHERE (RunnerId) IN (
    SELECT RunnerId
    FROM (
        SELECT 
            RunnerId,
            ROW_NUMBER() OVER (PARTITION BY RunnerId ORDER BY RunnerId) AS rn
        FROM MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_FULL
    )
    WHERE rn > 1
);
-- Add distance column
ALTER TABLE MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_FULL
ADD Distance VARCHAR(4) DEFAULT 'Full';

-- Update gender column
UPDATE MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_FULL
SET Gender = CASE
    WHEN Gender = 'F' THEN 'Female'
    WHEN Gender = 'M' THEN 'Male'
    WHEN Gender = 'Nonbinary' THEN 'Non-binary'
END;

-- Add corral column
ALTER TABLE MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_FULL
ADD Corral VARCHAR(2) DEFAULT 'B';

-- If expected finish time less than 185 minutes then runner is in corral A else they are in B
UPDATE MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_FULL
SET Corral = CASE
    WHEN Finish_Minutes < 185 THEN 'A'
    WHEN Finish_Minutes < 200 AND Gender = 'Female' THEN 'A'
    ELSE 'B'
END;

-- Inserting into master registrations the normalized data from the registrations full, registrations half, and registrations 5k Tables
-- Inserting data from registrations 5k
insert into master_registrations 
    (RunnerID,
    First_Name,
    Last_Name,
    Birth_Date,
    Gender,
    Country_Code,
    Distance,
    Corral,
    ShirtSize)
select
    RunnerID,
    FNAME,
    LNAME,
    DOB,
    SEX,
    NATION,
    Distance,
    Corral,
    Shirt
from MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_5k;

-- Inserting into master registrations the normalized data from the registrations full, registrations half, and registrations Half Tables
-- Inserting data from registrations Half
insert into master_registrations 
    (RunnerID,
    First_Name,
    Last_Name,
    Birth_Date,
    Gender,
    Country_Code,
    Distance,
    Corral,
    ShirtSize)
select
    RunnerID,
    FIRST_NAME,
    LAST_NAME,
    BIRTHDATE,
    GENDER,
    COUNTRY,
    Distance,
    Corral,
    SIZE
from MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_HALF;

-- Inserting into master registrations the normalized data from the registrations full, registrations half, and registrations Full Tables
-- Inserting data from registrations Full
insert into master_registrations 
    (RunnerID,
    First_Name,
    Last_Name,
    Birth_Date,
    Gender,
    Country_Code,
    Distance,
    Corral,
    ShirtSize)
select
    RunnerID,
    GivenName,
    SurName,
    Birth_Date,
    Gender,
    Origin_Country,
    Distance,
    Corral,
    ShirtSize
from MSIS3333_STUDENT.SNAIL_SCHEMA.REGISTRATIONS_FULL;

-- Create the Runners Profile table (3NF)
CREATE TABLE Runners (
    RunnerID INT PRIMARY KEY,
    First_Name VARCHAR(50),
    Last_Name VARCHAR(50),
    Birth_Date DATE,
    Gender VARCHAR(20),
    ShirtSize VARCHAR(10)
);

-- Create the Race Results table (3NF)
CREATE TABLE RaceResults (
    RunnerID INT,
    Distance VARCHAR(20),
    Country_Code CHAR(3),
    Corral CHAR(1),
    -- Composite Primary Key: A runner can only have one entry per distance
    PRIMARY KEY (RunnerID, Distance),
    -- Foreign Key: Ensures the runner exists in the profile table
    FOREIGN KEY (RunnerID) REFERENCES Runners(RunnerID)
);

-- Move unique runner profiles to the Runners table
INSERT INTO Runners (RunnerID, First_Name, Last_Name, Birth_Date, Gender, ShirtSize)
SELECT DISTINCT RunnerID, First_Name, Last_Name, Birth_Date, Gender, ShirtSize
FROM MSIS3333_STUDENT.SNAIL_SCHEMA.MASTER_REGISTRATIONS;

-- Move the race-specific data to the RaceResults table
INSERT INTO RaceResults (RunnerID, Distance, Country_Code, Corral)
SELECT RunnerID, Distance, Country_Code, Corral
FROM MSIS3333_STUDENT.SNAIL_SCHEMA.MASTER_REGISTRATIONS;

select * from Runners;
select * from RaceResults;
