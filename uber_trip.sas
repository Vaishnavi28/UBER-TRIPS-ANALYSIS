Proc import DATAFILE="C:\Users\vaish\Documents\My SAS Files\9.4\uber-raw-data-janjune-15.csv" OUT=UBER_DATA
dbms=csv
replace;    
run;

Proc import DATAFILE="C:\Users\vaish\Documents\My SAS Files\9.4\other-FHV-services_jan-aug-2015.csv" OUT=OTHER_FHV_DATA
dbms=csv
replace;    
run;
/*USING MACROS*/
%LET TRIPS=NUMBER_OF_TRIPS;
%LET VEHICLES=NUMBER_OF_VEHICLES;
%LET BASE_NO=Dispatching_base_num;
%LET LOC=locationID;

TITLE "PROC CONTENTS FOR UBER DATA";
proc contents data=UBER_DATA;
run;

Title "PROC CONTENTS for OTHER FHV DATA";
proc contents data=OTHER_FHV_DATA;
RUN;

/*REMOVING MISSING VALUES*/
data OTHER_FHV_DATA;
set OTHER_FHV_DATA;
if cmiss(of _all_) then delete;
run;
/*REMOVING MISSING VALUES*/
data UBER_DATA;
set UBER_DATA;
if cmiss(of _all_) then delete;
run;

TITLE "NO OF VEHICLES & TRIPS FOR EACH BASE NAME in other FHV ";
PROC SQL;
SELECT BASE_NUMBER,BASE_NAME, SUM(NUMBER_OF_VEHICLES)AS TOTAL_VEHICLES ,SUM(NUMBER_OF_TRIPS)AS TOTAL_TRIPS
from OTHER_FHV_DATA
group by 1,2
order by 1,2;
QUIT;

TITLE "NO OF TRIPS FOR EVERY MONTH FOR EVRY BASE_NUMBERS -OTHER-FHV";
PROC SQL;
SELECT BASE_NUMBER,MONTH,SUM(NUMBER_OF_TRIPS)AS TOTAL_TRIPS
FROM OTHER_FHV_DATA
GROUP BY 1,2
ORDER BY 1,2;
QUIT;

TITLE "NO OF TRIPS FOR  EVERY MONTH-OTHER FHV";
PROC SQL;
SELECT MONTH,SUM(NUMBER_OF_TRIPS)AS TOTAL_TRIPS
FROM OTHER_FHV_DATA
GROUP BY 1
ORDER BY 1;
QUIT;

/***GRAPHICAL REPRESENTATION ***/
TITLE "NO OF TRIPS BY MONTH";
pattern1 value=L1;
proc gchart data=OTHER_FHV_DATA;
vbar MONTH / sumvar=NUMBER_OF_TRIPS
type=SUM;
/*group=MONTH;*/
run;
quit;

/*********************UBER DATA ANALYSIS********************************/

TITLE "NO OF TRIPS FOR EACH UBER BASE ";
PROC SQL;
SELECT &BASE_NO AS BASE_NO,COUNT(&BASE_NO)AS TOTAL_TRIPS
from UBER_DATA
group by 1
order by 1;
QUIT;

/*Extracting month from the pipckup date*/
data uber_data;
set uber_data;
Month=SUBSTR(put(Pickup_date,DATETIME16.),3,3);
run;

TITLE"NUMBER OF TRIPS FOR EVERY MONTH-UBER";
PROC SQL;
SELECT MONTH AS MONTH,COUNT(&BASE_NO)AS TOTAL_TRIPS
FROM UBER_DATA
GROUP BY 1
ORDER BY 1 ASC;
QUIT;

TITLE"NUMBER OF TRIPS FOR EVERY LOCATION-UBER";
PROC SQL;
SELECT &LOC AS LOCATION_ID,COUNT(&BASE_NO)AS TOTAL_TRIPS
FROM UBER_DATA
GROUP BY 1
ORDER BY 1 ASC;
QUIT;

/*FHV AND UBER DATA COMPARISON*/
TITLE "NO OF TRIPS FOR EVERY MONTH-OTHER-FHV & UBER COMPARISON";
PROC SQL;
SELECT UBER.MONTH,SUM(&TRIPS)AS TOTAL_TRIPS_FHV,COUNT(&BASE_NO)AS TOTAL_TRIPS_UBER
FROM OTHER_FHV_DATA FHV
FULL JOIN UBER_DATA UBER
ON FHV.MONTH=UBER.MONTH
GROUP BY 1
ORDER BY 1;
QUIT;



















