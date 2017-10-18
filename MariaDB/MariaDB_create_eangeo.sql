/*#####################################################**
** EAN GEO - custom tables that include all Spatial    **
** Information                                         **
** using Spatial Index and Functions                   **
** MariaDB version using the Aria Storage Engine       **
#######################################################*/

DROP DATABASE IF EXISTS eangeo;
-- specify utf8 / ut8_unicode_ci to manage all languages properly
-- updated from files contain those characters
CREATE DATABASE eangeo CHARACTER SET utf8 COLLATE utf8_unicode_ci;

-- users permisions, must run as root to give the SUPER permission
GRANT ALL ON eangeo.* TO 'eanuser'@'%' IDENTIFIED BY 'Passw@rd1';
GRANT ALL ON eangeo.* TO 'eanuser'@'localhost' IDENTIFIED BY 'Passw@rd1';
GRANT SUPER ON *.* to eanuser@'localhost' IDENTIFIED BY 'Passw@rd1';
FLUSH PRIVILEGES;

-- REQUIRED IN WINDOWS as we do not use STRICT_TRANS_TABLE for the upload process
SET @@global.sql_mode= '';
SET GLOBAL sql_mode='';

USE eangeo;

/*######################################################
##                                                    ##
## TABLES & STORED PROCEDURES CREATED TO ENHANCE THE  ##
## SYSTEM FUNCTIONALITY                               ##
##                                                    ##
######################################################*/
-- Spatial Version of the ActivePropertyList
-- copy the original structure will all the data
DROP TABLE IF EXISTS geo_activepropertylist;
CREATE TABLE geo_activepropertylist ENGINE=Aria SELECT * FROM eanprod.activepropertylist;
-- add the POINT field to the structure
ALTER TABLE geo_activepropertylist ADD geo_point POINT;
-- fill the POINT field (using existing latitude and longitude)
UPDATE geo_activepropertylist 
	SET geo_point=ST_GeomFromText(CONCAT('POINT(',Latitude,' ',Longitude,')'));
-- make geo_point field NOT NULL (as is a requirement for spatial indexes)
ALTER TABLE geo_activepropertylist MODIFY COLUMN geo_point POINT NOT NULL;
-- add the SPATIAL index
CREATE SPATIAL INDEX spa_hotels ON geo_activepropertylist(geo_point);
-- erase ANY non valid geometry
-- DELETE FROM geo_activepropertylist WHERE ST_IsValid(geo_point)=0;
	
-- Spatial Version of the ActivePropertyBusinessModel
-- copy the original structure will all the data
DROP TABLE IF EXISTS geo_activepropertymodel;
CREATE TABLE geo_activepropertymodel ENGINE=Aria SELECT * FROM eanprod.activepropertybusinessmodel;
-- add the POINT field to the structure
ALTER TABLE geo_activepropertymodel ADD geo_point POINT;
-- fill the POINT field (using existing latitude and longitude)
UPDATE geo_activepropertymodel
	SET geo_point=ST_GeomFromText(CONCAT('POINT(',Latitude,' ',Longitude,')'));
-- make geo_point field NOT NULL (as is a requirement for spatial indexes)
ALTER TABLE geo_activepropertymodel MODIFY COLUMN geo_point POINT NOT NULL;
-- add the SPATIAL index
CREATE SPATIAL INDEX spa_businessmodel ON geo_activepropertymodel(geo_point);
-- erase ANY non valid geometry
-- DELETE FROM geo_activepropertybusinessmodel WHERE ST_IsValid(geo_point)=0;

--- you should erase all point out like:

DELETE * FROM geo_activepropertymodel WHERE ABS(longitude) > 180 OR ABS(latitude) > 90;

-- Spatial Version of the PointsOfInterestCoordinatesList
-- copy the original structure will all the data
DROP TABLE IF EXISTS geo_pointsofinterestcoordinateslist;
CREATE TABLE geo_pointsofinterestcoordinateslist ENGINE=Aria SELECT * FROM eanprod.pointsofinterestcoordinateslist;
-- add the POINT field to the structure
ALTER TABLE geo_pointsofinterestcoordinateslist ADD geo_point POINT;
-- fill the POINT field (using existing latitude and longitude)
UPDATE geo_pointsofinterestcoordinateslist 
	SET geo_point=ST_GeomFromText(CONCAT('POINT(',Latitude,' ',Longitude,')'));
-- make geo_point field NOT NULL (as is a requirement for spatial indexes)
ALTER TABLE geo_pointsofinterestcoordinateslist MODIFY COLUMN geo_point POINT NOT NULL;
-- add the SPATIAL index
CREATE SPATIAL INDEX spa_pois ON geo_pointsofinterestcoordinateslist(geo_point);
-- erase ANY non valid geometry
-- DELETE FROM geo_pointsofinterestcoordinateslist WHERE ST_IsValid(geo_point)=0;

-- Spatial Version of the RegionCenterCoordinatesList
-- copy the original structure will all the data
DROP TABLE IF EXISTS geo_regioncentercoordinateslist;
CREATE TABLE geo_regioncentercoordinateslist ENGINE=Aria SELECT * FROM eanprod.regioncentercoordinateslist;
-- add the POINT field to the structure
ALTER TABLE geo_regioncentercoordinateslist ADD geo_point POINT;
-- fill the POINT field (using existing latitude and longitude)
UPDATE geo_regioncentercoordinateslist
	SET geo_point=ST_GeomFromText(CONCAT('POINT(',CenterLatitude,' ',CenterLongitude,')'));
-- make geo_point field NOT NULL (as is a requirement for spatial indexes)
ALTER TABLE geo_regioncentercoordinateslist MODIFY COLUMN geo_point POINT NOT NULL;
-- add the SPATIAL index
CREATE SPATIAL INDEX spa_regioncenter ON geo_regioncentercoordinateslist(geo_point);
-- erase ANY non valid geometry
-- DELETE FROM geo_regioncentercoordinateslist WHERE ST_IsValid(geo_point)=0;
-- create regular index by Latitude, Longitude to use for geosearches
CREATE INDEX geo_regioncentercoordinates ON geo_regioncentercoordinateslist(CenterLatitude, CenterLongitude);

-- Spatial Version of the AirportCoordinatesList
-- copy the original structure will all the data
DROP TABLE IF EXISTS geo_airportcoordinateslist;
CREATE TABLE geo_airportcoordinateslist ENGINE=Aria SELECT * FROM eanprod.airportcoordinateslist;
-- add the POINT field to the structure
ALTER TABLE geo_airportcoordinateslist ADD geo_point POINT;
-- fill the POINT field (using existing latitude and longitude)
UPDATE geo_airportcoordinateslist
	SET geo_point=ST_GeomFromText(CONCAT('POINT(',Latitude,' ',Longitude,')'));
-- make geo_point field NOT NULL (as is a requirement for spatial indexes)
ALTER TABLE geo_airportcoordinateslist MODIFY COLUMN geo_point POINT NOT NULL;
-- add the SPATIAL index
CREATE SPATIAL INDEX spa_airportcoordinateslist ON geo_airportcoordinateslist(geo_point);
-- erase ANY non valid geometry
-- DELETE FROM geo_airportcoordinateslist WHERE ST_IsValid(geo_point)=0;
-- create regular index by Latitude, Longitude to use for geosearches
CREATE INDEX geo_airportcoordinates ON geo_airportcoordinateslist(Latitude, Longitude);

-- Spatial Version of the OurAirports (airports) data
-- copy the original structure will all the data
DROP TABLE IF EXISTS geo_ourairports;
CREATE TABLE geo_ourairports ENGINE=Aria SELECT * FROM eanextras.airports
-- ONLY those with Active Service that are airports and have an IATA code 
	WHERE ScheduledService='yes' AND AirportType LIKE "%_airport" AND IATACode <> '';
-- add the POINT field to the structure
ALTER TABLE geo_ourairports ADD geo_point POINT;
-- fill the POINT field (using existing latitude and longitude)
UPDATE geo_ourairports 
	SET geo_point=ST_PointFromText(CONCAT('POINT(',Latitude,' ',Longitude,')'));
-- make geo_point field NOT NULL (as is a requirement for spatial indexes)
ALTER TABLE geo_ourairports MODIFY COLUMN geo_point POINT NOT NULL;
-- add the SPATIAL index
CREATE SPATIAL INDEX spa_ourairports ON geo_ourairports(geo_point);
-- erase ANY non valid geometry
-- DELETE FROM geo_ourairports WHERE ST_IsValid(geo_point)=0;

-- Spatial Version of the CityCoordinatesList
-- copy the original structure will all the data
DROP TABLE IF EXISTS geo_citycoordinateslist;
CREATE TABLE geo_citycoordinateslist ENGINE=Aria SELECT * FROM eanprod.citycoordinateslist;
-- add the POINT field to the structure
ALTER TABLE geo_citycoordinateslist ADD geo_polygon POLYGON;
-- fill the POINT field (using existing latitude and longitude)
UPDATE geo_citycoordinateslist
	SET geo_polygon = ST_PolygonFromText(eangeo.CONVERT_TO_POLYGON(Coordinates));
-- make geo_point field NOT NULL (as is a requirement for spatial indexes)
ALTER TABLE geo_citycoordinateslist MODIFY COLUMN geo_polygon POLYGON NOT NULL;
-- add the SPATIAL index
CREATE SPATIAL INDEX spa_citycoordinateslist ON geo_citycoordinateslist(geo_polygon);
-- erase ANY non valid geometry
-- DELETE FROM geo_citycoordinateslist WHERE ST_IsValid(geo_polygon)=0;


-- Spatial Version of the NeighborhoodCoordinatesList
-- copy the original structure will all the data
DROP TABLE IF EXISTS geo_neighborhoodcoordinateslist;
CREATE TABLE geo_neighborhoodcoordinateslist ENGINE=Aria SELECT * FROM eanprod.neighborhoodcoordinateslist; 
-- add the POINT field to the structure
ALTER TABLE geo_neighborhoodcoordinateslist ADD geo_polygon POLYGON;
-- fill the POINT field (using existing latitude and longitude)
UPDATE geo_neighborhoodcoordinateslist
	SET geo_polygon = ST_PolygonFromText(eangeo.CONVERT_TO_POLYGON(Coordinates));
-- make geo_point field NOT NULL (as is a requirement for spatial indexes)
ALTER TABLE geo_neighborhoodcoordinateslist MODIFY COLUMN geo_polygon POLYGON NOT NULL;
-- add the SPATIAL index
CREATE SPATIAL INDEX spa_neighborcoordinateslist ON geo_neighborhoodcoordinateslist(geo_polygon);
-- erase ANY non valid geometry
-- DELETE FROM geo_neighborhoodcoordinateslist WHERE ST_IsValid(geo_polygon)=0;

use eangeo;
-- To search by kilometers use: 3959 instead of miles: 6371.
DROP FUNCTION IF EXISTS SLC;
CREATE FUNCTION SLC (pt1 point, pt2 point) RETURNS double
RETURN 3959 * acos(cos(radians(ST_X(pt1))) * cos(radians(ST_X(pt2))) * cos(radians(ST_Y(pt2)) 
       - radians(ST_Y(pt1))) + sin(radians(ST_X(pt1))) * sin(radians(ST_X(pt2))));

use eangeo;
DELIMITER $$
-- To search by kilometers instead of miles, replace 3959 with 6371.
DROP FUNCTION IF EXISTS PARENT_ALL_REGIONS;
CREATE FUNCTION PARENT_ALL_REGIONS(search_id int) 
RETURNS VARCHAR(4096)
DETERMINISTIC
BEGIN
   set session group_concat_max_len = 4096;
-- get all first level decendents
-- those are direct City + Neighborhood records
   select GROUP_CONCAT(RegionID) INTO @firstdecend
   FROM eanprod.parentregionlist
   WHERE ParentRegionID = search_id;
-- now we add the previous to all new ones
-- to make a complete list
-- Select @seconddecend;
   SELECT GROUP_CONCAT(RegionID) INTO @seconddecend 
   FROM eanprod.parentregionlist
   WHERE ParentRegionID=search_id OR ParentRegionID IN (@firstdecend);
-- Select @thirddecend;
-- SELECT GROUP_CONCAT(RegionID) INTO @thirddecend FROM parentregionlist
   SELECT GROUP_CONCAT(RegionID) INTO @thirddecend
   FROM eanprod.parentregionlist
   WHERE ParentRegionID=search_id OR ParentRegionID IN (@firstdecend) OR ParentRegionID IN (@seconddecend);
RETURN @thirddecend
END $$
delimiter ;
           
-- Creating a country polygon finder
-- http://victorwyee.com/webapp/creating-country-polygon-locator-php-mysql-google-maps/


-- GEONAMES Project data

DROP TABLE IF EXISTS geonames;
CREATE TABLE geonames
(
GeoNameID INT NOT NULL,
Name VARCHAR(200),
AsciiName VARCHAR(200),
AlternateNames TEXT,
Latitude numeric(9,6),
Longitude numeric(9,6),
FeatureClass char(1),
FeatureCode varchar(10),
CountryCode  char(2),
AlternativeCountryCode varchar(60),
AdminCode1 varchar(20),
AdminCode2 varchar(80), 
AdminCode3 varchar(20),
AdminCode4 varchar(20),
Population BIGINT,
Elevation INT,
Dem INT,
Timezone varchar(40),
ModificationDate date,
TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (GeoNameID)
) ENGINE=Aria CHARACTER SET utf8 COLLATE utf8_unicode_ci;
## index by Latitude, Longitude to use for geosearches
## we add the FeatureCode to the index to spped up filtered searches
CREATE INDEX geonames_geoloc ON geonames(Latitude, Longitude,FeatureCode);
## index to speed the usual search by name,country filtered by FeatureClass and code
CREATE INDEX geonames_fastasciiname ON geonames(AsciiName, CountryCode, FeatureClass, FeatureCode);


/*************************************************************************
** FUNCTION to generate the WKT (weel known text) for a polygon
** based on the way EAN saver its polygons
*/
DROP FUNCTION IF EXISTS CONVERT_TO_POLYGON;
DELIMITER $$
CREATE FUNCTION CONVERT_TO_POLYGON(input TEXT)
   RETURNS TEXT
BEGIN
   RETURN CONCAT('POLYGON((',REPLACE(REPLACE(input, ';', ' '),':', ','),',',SUBSTRING_INDEX(REPLACE(input, ';', ' '),':', 1),'))');
END
$$
DELIMITER ;


##################################################################
## search what is close to a GPSPoint using Geonames table content
## EXAMPLE IS: 286020 – Carin Hotel (London) GPSPoint ( 51.51274,-0.18305)
## call sp_geonames_from_point(51.51274,-0.18305,1);
##################################################################
DROP PROCEDURE IF EXISTS sp_geonames_from_point;
DELIMITER $$
CREATE PROCEDURE sp_geonames_from_point(IN lat double,lon double, maxdist int)
BEGIN
SELECT GeoNameID,AsciiName,Name,CountryCode,FeatureClass,FeatureCode,AdminCode1,AdminCode2,AdminCode3,AdminCode4,Latitude,Longitude,
# this calculate the distance from the given longitude, latitude
    round( sqrt( 
        (POW(a.Latitude - lat, 2)* 68.1 * 68.1) + 
        (POW(a.Longitude - lon, 2) * 53.1 * 53.1) 
     )) AS distance
FROM geonames AS a 
WHERE 1=1
HAVING distance < maxdist
ORDER BY distance ASC;
# to use LIMIT you need to use a prepared statement to avoid errors
END 
$$
DELIMITER ;

##################################################################
##this version will allow you to restrict the results:
##only return Specific FeatureCode
## http://www.geonames.org/export/codes.html
##################################################################
DROP PROCEDURE IF EXISTS sp_geonames_from_point_featcode;
DELIMITER $$
CREATE PROCEDURE sp_geonames_from_point_featcode(IN lat double,lon double, maxdist int, featcode varchar(60))
BEGIN
SET @s = CONCAT('SELECT GeoNameID,AsciiName,Name,CountryCode,FeatureClass,FeatureCode,AdminCode1,AdminCode2,AdminCode3,AdminCode4,Latitude,Longitude,',
		' sqrt((POW(a.Latitude-',lat,',2)*68.1*68.1)+', 
		'(POW(a.Longitude-',lon,',2)*53.1*53.1)) AS distance',
		' FROM geonames as a WHERE FeatureCode=\'',featcode,
		'\' HAVING distance < ',maxdist,
		' ORDER BY distance ASC;');
Select @s;
PREPARE stmt1 FROM @s; 
EXECUTE stmt1; 
DEALLOCATE PREPARE stmt1;
END 
$$
DELIMITER ;
