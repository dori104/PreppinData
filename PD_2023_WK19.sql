-- Tableau conference session info
WITH SESSIONS AS (

    SELECT * FROM (
    
        SELECT
            SESSION_NUMBER

        -- Getting speaker initials from session description
            ,LEFT(SPLIT_PART(DESCRIPTION,' ',1),1) || LEFT(SPLIT_PART(DESCRIPTION,' ',2),1) AS SPEAKER

        -- Getting subject from session description
            ,CASE
                WHEN CONTAINS(LOWER(DESCRIPTION),'prep') THEN 'Prep'
                WHEN CONTAINS(LOWER(DESCRIPTION),'server') THEN 'Server'
                WHEN CONTAINS(LOWER(DESCRIPTION),'community') THEN 'Community'
                WHEN CONTAINS(LOWER(DESCRIPTION),'desktop') THEN 'Desktop'
            END AS SUBJECT

        -- Flag for whether a session includes deduplication
            ,CASE
                WHEN CONTAINS(DESCRIPTION,'deduplication') THEN TRUE
                ELSE FALSE
            END AS DEDUPLICATION_FLAG
            
        FROM TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK19
    )
    
    WHERE DEDUPLICATION_FLAG = TRUE
    ORDER BY SESSION_NUMBER
)
,


-- Info on the rooms that talks are taking place
ROOMS AS (

    SELECT
    -- String functions to extract room and session info
        FLOOR
        ,RIGHT(FLOOR,1) || LPAD(TO_VARCHAR(ROOM),2,'0') AS ROOM
        ,SPLIT_PART(DESCRIPTION,' - ',1) AS SESSION_NAME
        ,LEFT(SPLIT_PART(DESCRIPTION,' - ',2),2) AS SPEAKER
        ,SPLIT_PART(SPLIT_PART(DESCRIPTION,' - ',2),' ',3) AS SUBJECT
        
    FROM (
    
        SELECT * FROM PD_2023_WK19_ROOMS
        UNPIVOT (
            DESCRIPTION
            FOR FLOOR IN ("Floor 1", "Floor 2", "Floor 3")
        )
        
    ) A -- Floor columns to rows
)
,


-- Distances in metres between rooms
DISTANCES AS (

    SELECT
        ROOM AS ROOM_A
        ,ROOM_B
        ,DISTANCE
        ,CEIL((DISTANCE / 1.2) / 60,0) AS MINUTES_TO_NEXT_ROOM  -- Calculate minutes taken to walk from room a to room b , rounding up
    FROM PD_2023_WK19_DISTANCES
    
    UNPIVOT (
        DISTANCE
        FOR ROOM_B IN ("101","102","103","104","105","201","202","203","204","205","301","302")
    )   -- Room B columns to rows
    
    WHERE DISTANCE != 0 -- Remove distances between the same room
)


SELECT
    D.ROOM_A
    ,R.ROOM AS ROOM_B
    ,D.MINUTES_TO_NEXT_ROOM
    ,D.DISTANCE AS METRES
    ,R.SPEAKER
    ,R.SUBJECT
FROM ROOMS AS R

JOIN SESSIONS AS S
ON R.SPEAKER = S.SPEAKER
AND R.SUBJECT = S.SUBJECT

JOIN DISTANCES AS D
ON R.ROOM = D.ROOM_B

WHERE R.FLOOR = 'Floor 2'
AND D.ROOM_A = 302  -- Say we are in room 302 now, how long will it take to get to this talk?
;

