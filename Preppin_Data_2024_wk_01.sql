SELECT * FROM TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2024_WK01;
DESCRIBE TABLE TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2024_WK01;

-- Before converting price to numeric, find precision as maximum length of number + 2 dp digits
SELECT
  FLIGHT_DETAILS
  ,MAX(
      LENGTH(TO_NUMERIC(SPLIT_PART(FLIGHT_DETAILS,'//',5)))
      ) OVER () + 2 AS PRICE_PRECISION
FROM TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2024_WK01
;


-- Table for bookings with a flow card
CREATE OR REPLACE TABLE DP_PD_2024_WK1_FLOWCARD AS

SELECT * FROM (

    SELECT
        -- Splitting out flight details into separate columns
        TO_DATE(LEFT(FLIGHT_DETAILS,10),'YYYY-MM-DD') AS "Flight Date"
        ,SPLIT_PART(FLIGHT_DETAILS,'//',2) AS "Flight Number"
        ,SPLIT_PART(SPLIT_PART(FLIGHT_DETAILS,'//',3),'-',1) AS "Flight From"
        ,SPLIT_PART(SPLIT_PART(FLIGHT_DETAILS,'//',3),'-',2) AS "Flight To"
        ,SPLIT_PART(FLIGHT_DETAILS,'//',4) AS "Class"
        ,TO_DECIMAL(SPLIT_PART(FLIGHT_DETAILS,'//',5),6,2) AS "Price"   -- Precision = 6, # of dp = 2
    
        -- Converting flow card field from 1/0 to yes/no
        ,CASE
            WHEN FLOW_CARD = 1 THEN 'YES'
            WHEN FLOW_CARD = 0 THEN 'NO'
        END AS "Flow Card?"

        ,BAGS_CHECKED AS "Bags Checked"
        ,MEAL_TYPE AS "Meal Type"
            
    FROM TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2024_WK01
)
WHERE "Flow Card?" = 'YES'
;


-- Table for bookings with no flow card
CREATE OR REPLACE TABLE DP_PD_2024_WK1_NO_FLOWCARD AS

SELECT * FROM (

    SELECT
        -- Splitting out flight details into separate columns
        TO_DATE(LEFT(FLIGHT_DETAILS,10),'YYYY-MM-DD') AS "Flight Date"
        ,SPLIT_PART(FLIGHT_DETAILS,'//',2) AS "Flight Number"
        ,SPLIT_PART(SPLIT_PART(FLIGHT_DETAILS,'//',3),'-',1) AS "Flight From"
        ,SPLIT_PART(SPLIT_PART(FLIGHT_DETAILS,'//',3),'-',2) AS "Flight To"
        ,SPLIT_PART(FLIGHT_DETAILS,'//',4) AS "Class"
        ,TO_DECIMAL(SPLIT_PART(FLIGHT_DETAILS,'//',5),6,2) AS "Price"   -- Precision = 6, # of dp = 2
    
        -- Converting flow card field from 1/0 to yes/no
        ,CASE
            WHEN FLOW_CARD = 1 THEN 'YES'
            WHEN FLOW_CARD = 0 THEN 'NO'
        END AS "Flow Card?"

        ,BAGS_CHECKED AS "Bags Checked"
        ,MEAL_TYPE AS "Meal Type"
            
    FROM TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2024_WK01
)
WHERE "Flow Card?" = 'NO'
;

SELECT * FROM DP_PD_2024_WK1_NO_FLOWCARD;
SELECT * FROM DP_PD_2024_WK1_FLOWCARD;
