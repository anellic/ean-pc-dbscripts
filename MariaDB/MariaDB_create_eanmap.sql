/*#####################################################*
## MySQL_create_eanmap.sql                       v7.7 ##
## SCRIPT TO GENERATE EAN DATABASE IN MYSQL ENGINE    ##
## THIS DATABASE IS USED FOR INTERNAL PURPOSE ONLY    ##
## TO BE USED IN MAPPING ENGAGEMENT                   ##
## WILL CREATE USER: eanuser / expedia                ##
## table names are lowercase so it will work  in all  ## 
## platforms the same.                                ##
########################################################
-- 7.7 Eliminate the DestinationID and DestinationName from the destinations data
##
## YOU NEED TO CONNECT AS ROOT FOR THIS SCRIPT TO WORK PROPERLY
*/
DROP DATABASE IF EXISTS eanmap;
-- specify utf8 / ut8_unicode_ci to manage all languages properly
-- updated from files contain those characters
CREATE DATABASE eanmap CHARACTER SET utf8 COLLATE utf8_unicode_ci;

-- users permissions, you must run as root to get the user this permissions
--
-- GRANT ALL ON eanmap.* TO 'eanuser'@'%' IDENTIFIED BY 'Passw@rd1';
-- GRANT ALL ON eanmap.* TO 'eanuser'@'localhost' IDENTIFIED BY 'Passw@rd1';
-- GRANT SUPER ON *.* to eanuser@'localhost' IDENTIFIED BY 'Passw@rd1';
-- FLUSH PRIVILEGES;


-- REQUIRED IN WINDOWS as we do not use STRICT_TRANS_TABLE for the upload process
SET @@global.sql_mode= '';
SET GLOBAL sql_mode='';

USE eanmap;

-- table to save all destinations (cities,POIs,areas,neighborhoods,etc.)
DROP TABLE IF EXISTS destinations;
CREATE TABLE destinations
(
	ID BIGINT NOT NULL AUTO_INCREMENT,
	RegionID BIGINT NOT NULL,
	RegionName VARCHAR(255),
	-- Spanish names to use for search
	RegionName_es_es VARCHAR(255),
	RegionNameLong_es_es VARCHAR(510),
	-- Brazilian portuguese names to use for search
	RegionName_pt_br VARCHAR(255),
	RegionNameLong_pt_br VARCHAR(510),
	-- this field will be the recomended regionIDs to use for this match --
	BestRegionIDs TEXT,
	BestRegionName VARCHAR(255),
	InternalRegionName VARCHAR(255),	
	RegionNameLong VARCHAR(510),
	RegionType VARCHAR(50),
	SubClass VARCHAR(50),
	ParentRegionID INT,
	ParentRegionType VARCHAR(50),
	ParentRegionName VARCHAR(255),
	ParentRegionNameLong VARCHAR(510),
	City VARCHAR(150),
	AirportCodes TEXT,
	StateProvinceCode VARCHAR(3),
	StateProvince VARCHAR(50),
	CountryCode VARCHAR(2),
	Country VARCHAR(50),	
	Latitude numeric(9,6),
	Longitude numeric(9,6),
    Priority VARCHAR(2),
	GeoLocation VARCHAR(30),
	AllHotelCount INT,
	AllHotelIDs TEXT,
	-- search engine amount of pages --
	SearchEngineCount BIGINT,
	-- reverse-geo of the GPS point --
    OpenStreetMap varchar(510),
    GeoOSMAddress VARCHAR(255),	
    GeoGoogleAddress VARCHAR(255),
    TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (ID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;
-- index by regionid, but there will be duplicates due to City vs. City (and Vicinity) records
CREATE INDEX destinations_regionid ON destinations(RegionID);
-- index by ParentRegionID to use for applying record fixers faster
CREATE INDEX destinations_parentlong ON destinations(ParentRegionNameLong,RegionType);


-- table to save all reverse-geo calls results (both: hotels and destinations)
DROP TABLE IF EXISTS reversegeo;
CREATE TABLE reversegeo
(
	IDType VARCHAR(1),
    MainID INT,
	Name VARCHAR(255),
	GeoOSMLatitude numeric(14,10),
	GeoOSMLongitude numeric(14,10),
	GeoOSMAddress VARCHAR(255),
	GeoGoogleLatitude numeric(14,10),
	GeoGoogleLongitude numeric(14,10),
	GeoGoogleAddress VARCHAR(255),
    TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (IDType,MainID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

-- table to save all TripAdvisor to EAN mapping
DROP TABLE IF EXISTS tripadvisor;
CREATE TABLE tripadvisor
(
    TripAdvisorID INT NOT NULL,
	EANHotelID INT NOT NULL,
    TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (EANHotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;
-- truncate table tripadvisor;
-- LOAD DATA LOCAL INFILE '/Users/rgruszka/TAtoEAN.csv' INTO TABLE tripadvisor CHARACTER SET utf8
-- FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;


DROP TABLE IF EXISTS activepropertylistext;
CREATE TABLE activepropertylistext
(
	HotelID INT,
    HotelPhoneNumber VARCHAR(30),
    HotelFaxNumber VARCHAR(30),
  	TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (HotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;
-- LOAD DATA LOCAL INFILE '/Users/rgruszka/activepropertylistExt.txt' INTO TABLE activepropertylistext CHARACTER SET utf8
-- FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 1 LINES;


-- table to save Orbitz hotels data extract
DROP TABLE IF EXISTS orbitzhotels;
CREATE TABLE orbitzhotels
(
	HotelID INT,
    HotelName VARCHAR(100),
    Address1 VARCHAR(50),
	Address2 VARCHAR(50),
	City VARCHAR(50),
	StateProvince VARCHAR(50),
	StateProvinceCode VARCHAR(2),
 	Country VARCHAR(50),
	CountryCode VARCHAR(2),
    PostalCode VARCHAR(20),
    Phone VARCHAR(30),
    Fax VARCHAR(30),
    Email VARCHAR(100),
    Latitude numeric(9,6),
    Longitude numeric(9,6),
    Stars INT,
    Description TEXT,
    AirportDesc VARCHAR(300),
    FacilityAmenities TEXT,
    Currency VARCHAR(3),
    CheckInTime VARCHAR(10),
    CheckOutTime VARCHAR(10),
    AreaServed VARCHAR(300),
    userScore NUMERIC(3,1),
    NumberOfReviews INT,
    NumberOfRecommendations INT,
    chainCode VARCHAR(50),
    MarketID INT,
    Merchant VARCHAR(5),
    OrbitzMerchant  VARCHAR(5),
    LastModifiedDate VARCHAR(20),
    Url VARCHAR(300),
    LeadPriceStart VARCHAR(10),
    LeadPriceEnd VARCHAR(10),
    LeadPriceLowRate VARCHAR(10),
    LeadPriceCurrency VARCHAR(10),
  	TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (HotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

-- import the data generated by an Utility (was provided to me this way)
-- LOAD DATA LOCAL INFILE '/Users/rgruszka/Downloads/oww_hotel_list.csv' INTO TABLE orbitzhotels CHARACTER SET utf8
-- FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n' IGNORE 1 LINES;



-- DROP TABLE IF EXISTS tnowhotels;
-- CREATE TABLE tnowhotels
-- (
-- hotel_id
-- hotel_name
-- line1,line2,city,state,state_code,country,country_code,postal,phone,fax,email,latitud,longitude,stars,description,airportDesc,facility_amenities,currency,checkInTime,checkOutTime,areaServed,userScore,numberOfReviews,numberOfRecommendations,chainCode,marketId,merchant,orbitzMerchant,lastModifiedDate,url,leadprice_start,leadprice_end,leadprice_lowrate,leadprice_currency
-- );

-- table to save all GIATA General Information
-- the order of the fields correspond to the sorted fields of the giata_general.csv file
DROP TABLE IF EXISTS giatageneral;
CREATE TABLE giatageneral
(
	AddressCityName		VARCHAR(60),
	AddressCountry		VARCHAR(60),
	AddressLine1		VARCHAR(50),
	AddressLine2		VARCHAR(50),
	AddressStreet		VARCHAR(50),
	ChainId				VARCHAR(5),
	ChainName			VARCHAR(100),
	City				VARCHAR(60),
	CityId				INT,
	Country				VARCHAR(2),
	Email				VARCHAR(200),
	GeoCodeAccuracy		VARCHAR(20),
	GiataID				INT NOT NULL,
	LastUpdate			VARCHAR(30),
	#Latitude			NUMERIC(15,12),
	#Longitude			NUMERIC(15,12),
	Latitude			VARCHAR(20),
	Longitude			VARCHAR(20),
	Name				VARCHAR(200),
	PhoneFax			VARCHAR(30),
	PhoneVoice			VARCHAR(30),
	Url					VARCHAR(250),
    TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (GiataID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

-- IMPORT STATEMENT USED: --
-- truncate table giatageneral;
-- LOAD DATA LOCAL INFILE '/Users/rgruszka/giata_general.csv' INTO TABLE giatageneral CHARACTER SET utf8
-- FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;


-- table to save all GIATA Providers Mapping Information
DROP TABLE IF EXISTS giataproviders; 
CREATE TABLE giataproviders (
  GiataID int(11) NOT NULL,
  ProviderCode varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  ProviderID varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
-- index by GiataID for fast join to the giatageneral table
CREATE INDEX giata_byid ON giataproviders(GiataID);
-- index by GiataID for fast join to the giatageneral table
CREATE INDEX giata_byprov ON giataproviders(ProviderCode,ProviderID);
CREATE index giata_providerid ON giataproviders(ProviderID);

-- IMPORT STATEMENT USED: --
-- truncate table giataproviders;
-- LOAD DATA LOCAL INFILE '/Users/rgruszka/giata_providers.csv' INTO TABLE giataproviders CHARACTER SET utf8
-- FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;



/*************************************************************************
** FUNCTION to eliminate all foreign characters from numbers identifiers
** useful to display/store phone numbers, SSN and similars
**
*/
DROP FUNCTION IF EXISTS STRIP_NON_DIGIT;
DELIMITER $$
CREATE FUNCTION STRIP_NON_DIGIT(input VARCHAR(255))
   RETURNS VARCHAR(255)
BEGIN
   DECLARE output   VARCHAR(255) DEFAULT '';
   DECLARE iterator INT          DEFAULT 1;
   WHILE iterator < (LENGTH(input) + 1) DO
      IF SUBSTRING(input, iterator, 1) IN ( '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' ) THEN
         SET output = CONCAT(output, SUBSTRING(input, iterator, 1));
      END IF;
      SET iterator = iterator + 1;
   END WHILE;
   RETURN output;
END
$$
DELIMITER ;

      
/*###########################################################################
# FUNCTION to format number into specific displays like:
# select MASK_FORMAT(123456789,'###-##-####');    => 123-45-6789
# select MASK_FORMAT(123456789,'(###) ###-####'); => (012) 345-6789
# select MASK_FORMAT(123456789,'###-#!##@(###)'); => 123-4!56@(789)                   
*/

DROP FUNCTION IF EXISTS MASK_FORMAT;
DELIMITER $$
CREATE FUNCTION MASK_FORMAT(unformatted_value BIGINT, format_string CHAR(32))
   RETURNS CHAR(32) DETERMINISTIC
BEGIN
-- Declare variables
DECLARE input_len TINYINT;
DECLARE output_len TINYINT;
DECLARE temp_char CHAR;
-- Initialize variables
SET input_len = LENGTH(unformatted_value);
SET output_len = LENGTH(format_string);
-- Construct formated string
WHILE ( output_len > 0 ) DO
   SET temp_char = SUBSTR(format_string, output_len, 1);
   IF ( temp_char = '#' ) THEN
      IF ( input_len > 0 ) THEN
         SET format_string = INSERT(format_string, output_len, 1, SUBSTR(unformatted_value, input_len, 1));
         SET input_len = input_len - 1;
      ELSE
         SET format_string = INSERT(format_string, output_len, 1, '0');
      END IF;
   END IF;
   SET output_len = output_len - 1;
END WHILE;
RETURN format_string;
END
$$
DELIMITER ;


/*###################################################################################
##### fill the destinations table ###################################################
###################################################################################*/
use eanmap;
truncate destinations;

-- Priority 01 - Multi-City (Vicinity)
INSERT INTO 
eanmap.destinations(RegionID,RegionName,RegionName_es_es,RegionNameLong_es_es,RegionName_pt_br,RegionNameLong_pt_br,BestRegionIDs,
                    BestRegionName,InternalRegionName,RegionNameLong,RegionType,SubClass,
                    ParentRegionID,ParentRegionType,ParentRegionName,ParentRegionNameLong,City,StateProvince,Country,Latitude,Longitude,
                    Priority,GeoLocation,AllHotelCount,AllHotelIDs)
SELECT parentregionlist.RegionID,eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong) AS 'CleanName',
       eanprod.REGION_NAME_CLEAN(regionlist_es_es.RegionName) AS 'CleanName_es_es',regionlist_es_es.RegionNameLong,
       eanprod.REGION_NAME_CLEAN(regionlist_pt_br.RegionName) AS 'CleanName_pt_br',regionlist_pt_br.RegionNameLong,
       parentregionlist.RegionID AS 'BestID',parentregionlist.RegionNameLong AS 'BestName',
	   eanprod.REGION_NAME_CLEAN(parentregionlist.RegionName),parentregionlist.RegionNameLong,parentregionlist.RegionType,
       parentregionlist.SubClass,ParentRegionID,ParentRegionType,ParentRegionName,ParentRegionNameLong,
	   eanprod.EXTRACT_ADDRESS_PART(eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong),'City') AS 'City',
	   eanprod.EXTRACT_ADDRESS_PART(eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong),'StateProvince') AS 'StateProvince',
	   eanprod.EXTRACT_ADDRESS_PART(eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong),'Country') AS 'Country',
       regioncentercoordinateslist.CenterLatitude,regioncentercoordinateslist.CenterLongitude,
       '01' AS 'Priority',CONCAT(regioncentercoordinateslist.CenterLatitude,',',regioncentercoordinateslist.CenterLongitude) as 'Location',
       eanprod.HOTELS_IN_REGION_COUNT(parentregionlist.RegionID) AS 'HotelCount',eanprod.HOTELS_IN_REGION(parentregionlist.RegionID) AS 'HotelList'
FROM eanprod.parentregionlist
-- get the coordinates (if available)
LEFT JOIN eanprod.regioncentercoordinateslist
ON eanprod.parentregionlist.RegionID = eanprod.regioncentercoordinateslist.RegionID
-- Spanish Translation
LEFT JOIN eanprod.regionlist_es_es
ON eanprod.parentregionlist.RegionID = eanprod.regionlist_es_es.RegionID
-- Portuguese Translation
LEFT JOIN eanprod.regionlist_pt_br
ON eanprod.parentregionlist.RegionID = eanprod.regionlist_pt_br.RegionID
-- DestinationID as mapped in the API 
-- LEFT JOIN eanextras.destinationidregionid
-- ON eanprod.parentregionlist.RegionID = eanextras.destinationidregionid.RegionID
WHERE eanprod.parentregionlist.RegionType='Multi-City (Vicinity)' AND eanprod.parentregionlist.SubClass='';


-- Priority 02 - City (excluding childs of City (and Vicinity) records
INSERT INTO 
eanmap.destinations(RegionID,RegionName,RegionName_es_es,RegionNameLong_es_es,RegionName_pt_br,RegionNameLong_pt_br,BestRegionIDs,
                    BestRegionName,InternalRegionName,RegionNameLong,RegionType,SubClass,
                    ParentRegionID,ParentRegionType,ParentRegionName,ParentRegionNameLong,City,StateProvince,Country,Latitude,Longitude,
                    Priority,GeoLocation,AllHotelCount,AllHotelIDs)
-- DestinationID,DestinationName)
SELECT parentregionlist.RegionID,eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong) AS 'CleanName',
       eanprod.REGION_NAME_CLEAN(regionlist_es_es.RegionName) AS 'CleanName_es_es',regionlist_es_es.RegionNameLong,
       eanprod.REGION_NAME_CLEAN(regionlist_pt_br.RegionName) AS 'CleanName_pt_br',regionlist_pt_br.RegionNameLong,
       parentregionlist.RegionID AS 'BestID',parentregionlist.RegionNameLong AS 'BestName',
	   eanprod.REGION_NAME_CLEAN(parentregionlist.RegionName),parentregionlist.RegionNameLong,parentregionlist.RegionType,
       parentregionlist.SubClass,ParentRegionID,ParentRegionType,ParentRegionName,ParentRegionNameLong,
	   eanprod.EXTRACT_ADDRESS_PART(eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong),'City') AS 'City',       
	   eanprod.EXTRACT_ADDRESS_PART(eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong),'StateProvince') AS 'StateProvince',
	   eanprod.EXTRACT_ADDRESS_PART(eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong),'Country') AS 'Country',
       regioncentercoordinateslist.CenterLatitude,regioncentercoordinateslist.CenterLongitude,
       '02' AS 'Priority',CONCAT(regioncentercoordinateslist.CenterLatitude,',',regioncentercoordinateslist.CenterLongitude) as 'Location',
       eanprod.HOTELS_IN_REGION_COUNT(parentregionlist.RegionID) AS 'HotelCount',eanprod.HOTELS_IN_REGION(parentregionlist.RegionID) AS 'HotelList'
FROM eanprod.parentregionlist
-- get the coordinates (if available)
LEFT JOIN eanprod.regioncentercoordinateslist
ON eanprod.parentregionlist.RegionID = eanprod.regioncentercoordinateslist.RegionID
-- Spanish Translation
LEFT JOIN eanprod.regionlist_es_es
ON eanprod.parentregionlist.RegionID = eanprod.regionlist_es_es.RegionID
-- Portuguese Translation
LEFT JOIN eanprod.regionlist_pt_br
ON eanprod.parentregionlist.RegionID = eanprod.regionlist_pt_br.RegionID
-- now include all the City / SubType = *ANY
WHERE (eanprod.parentregionlist.RegionType='City' AND eanprod.parentregionlist.SubClass='')
-- if the name of the parent is equal, then it is a child of the same-name (vicinity) record
-- that are NOT a child of an (and vicinity) record
AND ParentRegionID NOT IN (
	SELECT RegionID FROM eanprod.parentregionlist AS D
		WHERE eanprod.parentregionlist.RegionType='Multi-City (Vicinity)'
			  AND eanprod.parentregionlist.SubClass=''
);

-- Priority 03 - City (STRICT) this is a special set that include ALL cities regardless o them having "City (and vicinity) counterparts
INSERT INTO 
eanmap.destinations(RegionID,RegionName,RegionName_es_es,RegionNameLong_es_es,RegionName_pt_br,RegionNameLong_pt_br,BestRegionIDs,
                    BestRegionName,InternalRegionName,RegionNameLong,RegionType,SubClass,
                    ParentRegionID,ParentRegionType,ParentRegionName,ParentRegionNameLong,City,StateProvince,Country,Latitude,Longitude,
                    Priority,GeoLocation,AllHotelCount,AllHotelIDs)
SELECT parentregionlist.RegionID,eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong) AS 'CleanName',
       eanprod.REGION_NAME_CLEAN(regionlist_es_es.RegionName) AS 'CleanName_es_es',regionlist_es_es.RegionNameLong,
       eanprod.REGION_NAME_CLEAN(regionlist_pt_br.RegionName) AS 'CleanName_pt_br',regionlist_pt_br.RegionNameLong,
       parentregionlist.RegionID AS 'BestID',parentregionlist.RegionNameLong AS 'BestName',
	   eanprod.REGION_NAME_CLEAN(parentregionlist.RegionName),parentregionlist.RegionNameLong,parentregionlist.RegionType,
       parentregionlist.SubClass,ParentRegionID,ParentRegionType,ParentRegionName,ParentRegionNameLong,
	   eanprod.EXTRACT_ADDRESS_PART(eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong),'City') AS 'City',       
	   eanprod.EXTRACT_ADDRESS_PART(eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong),'StateProvince') AS 'StateProvince',
	   eanprod.EXTRACT_ADDRESS_PART(eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong),'Country') AS 'Country',
       regioncentercoordinateslist.CenterLatitude,regioncentercoordinateslist.CenterLongitude,
       '03' AS 'Priority',CONCAT(regioncentercoordinateslist.CenterLatitude,',',regioncentercoordinateslist.CenterLongitude) as 'Location',
       eanprod.HOTELS_IN_REGION_COUNT(parentregionlist.RegionID) AS 'HotelCount',eanprod.HOTELS_IN_REGION(parentregionlist.RegionID) AS 'HotelList'
FROM eanprod.parentregionlist
-- get the coordinates (if available)
LEFT JOIN eanprod.regioncentercoordinateslist
ON eanprod.parentregionlist.RegionID = eanprod.regioncentercoordinateslist.RegionID
-- Spanish Translation
LEFT JOIN eanprod.regionlist_es_es
ON eanprod.parentregionlist.RegionID = eanprod.regionlist_es_es.RegionID
-- Portuguese Translation
LEFT JOIN eanprod.regionlist_pt_br
ON eanprod.parentregionlist.RegionID = eanprod.regionlist_pt_br.RegionID
-- now include all the City / SubType = *ANY
WHERE eanprod.parentregionlist.RegionType='City' AND eanprod.parentregionlist.SubClass='' 
;


-- Priority 04 - Neighborhood / Neighbor
INSERT INTO 
eanmap.destinations(RegionID,RegionName,RegionName_es_es,RegionNameLong_es_es,RegionName_pt_br,RegionNameLong_pt_br,BestRegionIDs,
                    BestRegionName,InternalRegionName,RegionNameLong,RegionType,SubClass,
                    ParentRegionID,ParentRegionType,ParentRegionName,ParentRegionNameLong,Country,Latitude,Longitude,
                    Priority,GeoLocation,AllHotelCount,AllHotelIDs)
SELECT parentregionlist.RegionID,eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong) AS 'CleanName',
       eanprod.REGION_NAME_CLEAN(regionlist_es_es.RegionName) AS 'CleanName_es_es',regionlist_es_es.RegionNameLong,
       eanprod.REGION_NAME_CLEAN(regionlist_pt_br.RegionName) AS 'CleanName_pt_br',regionlist_pt_br.RegionNameLong,
       parentregionlist.RegionID AS 'BestID',parentregionlist.RegionNameLong AS 'BestName',
	   eanprod.REGION_NAME_CLEAN(parentregionlist.RegionName),parentregionlist.RegionNameLong,parentregionlist.RegionType,
       parentregionlist.SubClass,ParentRegionID,ParentRegionType,ParentRegionName,ParentRegionNameLong,
	   eanprod.EXTRACT_ADDRESS_PART(eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong),'Country') AS 'Country',
       regioncentercoordinateslist.CenterLatitude,regioncentercoordinateslist.CenterLongitude,
       '04' AS 'Priority',CONCAT(regioncentercoordinateslist.CenterLatitude,',',regioncentercoordinateslist.CenterLongitude) as 'Location',
       eanprod.HOTELS_IN_REGION_COUNT(parentregionlist.RegionID) AS 'HotelCount',eanprod.HOTELS_IN_REGION(parentregionlist.RegionID) AS 'HotelList'
FROM eanprod.parentregionlist
-- get the coordinates (if available)
LEFT JOIN eanprod.regioncentercoordinateslist
ON eanprod.parentregionlist.RegionID = eanprod.regioncentercoordinateslist.RegionID
-- Spanish Translation
LEFT JOIN eanprod.regionlist_es_es
ON eanprod.parentregionlist.RegionID = eanprod.regionlist_es_es.RegionID
-- Portuguese Translation
LEFT JOIN eanprod.regionlist_pt_br
ON eanprod.parentregionlist.RegionID = eanprod.regionlist_pt_br.RegionID
WHERE eanprod.parentregionlist.RegionType='Neighborhood' AND eanprod.parentregionlist.SubClass='neighbor'
;


-- Priority 05 - Neighborhood / downtown
 INSERT INTO 
 eanmap.destinations(RegionID,RegionName,RegionName_es_es,RegionNameLong_es_es,RegionName_pt_br,RegionNameLong_pt_br,BestRegionIDs,
                    BestRegionName,InternalRegionName,RegionNameLong,RegionType,SubClass,
                    ParentRegionID,ParentRegionType,ParentRegionName,ParentRegionNameLong,City,StateProvince,Country,Latitude,Longitude,
                    Priority,GeoLocation,AllHotelCount,AllHotelIDs)
SELECT parentregionlist.RegionID,eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong) AS 'CleanName',
       eanprod.REGION_NAME_CLEAN(regionlist_es_es.RegionName) AS 'CleanName_es_es',regionlist_es_es.RegionNameLong,
       eanprod.REGION_NAME_CLEAN(regionlist_pt_br.RegionName) AS 'CleanName_pt_br',regionlist_pt_br.RegionNameLong,
       parentregionlist.RegionID AS 'BestID',parentregionlist.RegionNameLong AS 'BestName',
	   eanprod.REGION_NAME_CLEAN(parentregionlist.RegionName),parentregionlist.RegionNameLong,parentregionlist.RegionType,
       parentregionlist.SubClass,ParentRegionID,ParentRegionType,ParentRegionName,ParentRegionNameLong,
	   eanprod.EXTRACT_ADDRESS_PART(eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong),'City') AS 'City',	   
	   eanprod.EXTRACT_ADDRESS_PART(eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong),'StateProvince') AS 'StateProvince',
	   eanprod.EXTRACT_ADDRESS_PART(eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong),'Country') AS 'Country',
       regioncentercoordinateslist.CenterLatitude,regioncentercoordinateslist.CenterLongitude,
       '05' AS 'Priority',CONCAT(regioncentercoordinateslist.CenterLatitude,',',regioncentercoordinateslist.CenterLongitude) as 'Location',
       eanprod.HOTELS_IN_REGION_COUNT(parentregionlist.RegionID) AS 'HotelCount',eanprod.HOTELS_IN_REGION(parentregionlist.RegionID) AS 'HotelList'
FROM eanprod.parentregionlist
-- get the coordinates (if available)
LEFT JOIN eanprod.regioncentercoordinateslist
ON eanprod.parentregionlist.RegionID = eanprod.regioncentercoordinateslist.RegionID
-- Spanish Translation
LEFT JOIN eanprod.regionlist_es_es
ON eanprod.parentregionlist.RegionID = eanprod.regionlist_es_es.RegionID
-- Portuguese Translation
LEFT JOIN eanprod.regionlist_pt_br
ON eanprod.parentregionlist.RegionID = eanprod.regionlist_pt_br.RegionID
WHERE eanprod.parentregionlist.RegionType='Neighborhood' AND eanprod.parentregionlist.SubClass='downtown';



-- Priority 06 - City / regional
INSERT INTO 
eanmap.destinations(RegionID,RegionName,RegionName_es_es,RegionNameLong_es_es,RegionName_pt_br,RegionNameLong_pt_br,BestRegionIDs,
                    BestRegionName,InternalRegionName,RegionNameLong,RegionType,SubClass,
                    ParentRegionID,ParentRegionType,ParentRegionName,ParentRegionNameLong,Country,Latitude,Longitude,
                    Priority,GeoLocation,AllHotelCount,AllHotelIDs)
SELECT parentregionlist.RegionID,eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong) AS 'CleanName',
       eanprod.REGION_NAME_CLEAN(regionlist_es_es.RegionName) AS 'CleanName_es_es',regionlist_es_es.RegionNameLong,
       eanprod.REGION_NAME_CLEAN(regionlist_pt_br.RegionName) AS 'CleanName_pt_br',regionlist_pt_br.RegionNameLong,
       parentregionlist.RegionID AS 'BestID',parentregionlist.RegionNameLong AS 'BestName',
	   eanprod.REGION_NAME_CLEAN(parentregionlist.RegionName),parentregionlist.RegionNameLong,parentregionlist.RegionType,
       parentregionlist.SubClass,ParentRegionID,ParentRegionType,ParentRegionName,ParentRegionNameLong,
	   eanprod.EXTRACT_ADDRESS_PART(eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong),'Country') AS 'Country',
       regioncentercoordinateslist.CenterLatitude,regioncentercoordinateslist.CenterLongitude,
       '06' AS 'Priority',CONCAT(regioncentercoordinateslist.CenterLatitude,',',regioncentercoordinateslist.CenterLongitude) as 'Location',
       eanprod.HOTELS_IN_REGION_COUNT(parentregionlist.RegionID) AS 'HotelCount',eanprod.HOTELS_IN_REGION(parentregionlist.RegionID) AS 'HotelList'
FROM eanprod.parentregionlist
-- get the coordinates (if available)
LEFT JOIN eanprod.regioncentercoordinateslist
ON eanprod.parentregionlist.RegionID = eanprod.regioncentercoordinateslist.RegionID
-- Spanish Translation
LEFT JOIN eanprod.regionlist_es_es
ON eanprod.parentregionlist.RegionID = eanprod.regionlist_es_es.RegionID
-- Portuguese Translation
LEFT JOIN eanprod.regionlist_pt_br
ON eanprod.parentregionlist.RegionID = eanprod.regionlist_pt_br.RegionID
WHERE eanprod.parentregionlist.RegionType='City' AND eanprod.parentregionlist.SubClass='regional';


-- Priority 07 - Neighborhood / regional
INSERT INTO 
eanmap.destinations(RegionID,RegionName,RegionName_es_es,RegionNameLong_es_es,RegionName_pt_br,RegionNameLong_pt_br,BestRegionIDs,
                    BestRegionName,InternalRegionName,RegionNameLong,RegionType,SubClass,
                    ParentRegionID,ParentRegionType,ParentRegionName,ParentRegionNameLong,Country,Latitude,Longitude,
                    Priority,GeoLocation,AllHotelCount,AllHotelIDs)
SELECT parentregionlist.RegionID,eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong) AS 'CleanName',
       eanprod.REGION_NAME_CLEAN(regionlist_es_es.RegionName) AS 'CleanName_es_es',regionlist_es_es.RegionNameLong,
       eanprod.REGION_NAME_CLEAN(regionlist_pt_br.RegionName) AS 'CleanName_pt_br',regionlist_pt_br.RegionNameLong,
       parentregionlist.RegionID AS 'BestID',parentregionlist.RegionNameLong AS 'BestName',
	   eanprod.REGION_NAME_CLEAN(parentregionlist.RegionName),parentregionlist.RegionNameLong,parentregionlist.RegionType,
       parentregionlist.SubClass,ParentRegionID,ParentRegionType,ParentRegionName,ParentRegionNameLong,
	   eanprod.EXTRACT_ADDRESS_PART(eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong),'Country') AS 'Country',
       regioncentercoordinateslist.CenterLatitude,regioncentercoordinateslist.CenterLongitude,
       '07' AS 'Priority',CONCAT(regioncentercoordinateslist.CenterLatitude,',',regioncentercoordinateslist.CenterLongitude) as 'Location',
       eanprod.HOTELS_IN_REGION_COUNT(parentregionlist.RegionID) AS 'HotelCount',eanprod.HOTELS_IN_REGION(parentregionlist.RegionID) AS 'HotelList'
FROM eanprod.parentregionlist
-- get the coordinates (if available)
LEFT JOIN eanprod.regioncentercoordinateslist
ON eanprod.parentregionlist.RegionID = eanprod.regioncentercoordinateslist.RegionID
-- Spanish Translation
LEFT JOIN eanprod.regionlist_es_es
ON eanprod.parentregionlist.RegionID = eanprod.regionlist_es_es.RegionID
-- Portuguese Translation
LEFT JOIN eanprod.regionlist_pt_br
ON eanprod.parentregionlist.RegionID = eanprod.regionlist_pt_br.RegionID
WHERE eanprod.parentregionlist.RegionType='Neighborhood' AND eanprod.parentregionlist.SubClass='regional';

-- Priority 08 - Neighborhood / airport
-- we use the Airport Coordinates List that include a MainCityID mapping
-- TODO: fix the MainCityID later for those with '0' value 
-- do not clean the region name as it is 'AirportName (IATACODE)'
-- use the AirportCoordinatesList to get Lat,Long
INSERT INTO 
eanmap.destinations(RegionID,RegionName,RegionName_es_es,RegionNameLong_es_es,RegionName_pt_br,RegionNameLong_pt_br,BestRegionIDs,
                    BestRegionName,InternalRegionName,RegionNameLong,RegionType,SubClass,
                    ParentRegionID,ParentRegionType,ParentRegionName,ParentRegionNameLong,AirportCodes,StateProvince,Country,Latitude,Longitude,
                    Priority,GeoLocation,AllHotelCount,AllHotelIDs)
SELECT eanprod.airportcoordinateslist.AirportID,eanprod.airportcoordinateslist.AirportName AS 'CleanName',
       regionlist_es_es.RegionName AS 'CleanName_es_es',regionlist_es_es.RegionNameLong,
       regionlist_pt_br.RegionName AS 'CleanName_pt_br',regionlist_pt_br.RegionNameLong,
       eanprod.airportcoordinateslist.MainCityID AS 'BestID',eanprod.parentregionlist.RegionNameLong AS 'BestName',
       parentregionlist.RegionName,parentregionlist.RegionNameLong,'Neighborhood' AS 'RegionType','airport' AS 'SubClass',
	   ParentRegionID,ParentRegionType,ParentRegionName,parentregionlist.ParentRegionNameLong,
       eanprod.airportcoordinateslist.AirportCode AS 'AirportCodes',
	   eanprod.EXTRACT_ADDRESS_PART(eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong),'StateProvince'),
	   eanprod.EXTRACT_ADDRESS_PART(eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong),'Country'),
       eanprod.airportcoordinateslist.Latitude,eanprod.airportcoordinateslist.Longitude,
       '08' AS 'Priority',CONCAT(eanprod.airportcoordinateslist.Latitude,',',eanprod.airportcoordinateslist.Longitude) as 'Location',
       eanprod.HOTELS_IN_REGION_COUNT(eanprod.airportcoordinateslist.MainCityID) AS 'HotelCount',eanprod.HOTELS_IN_REGION(eanprod.airportcoordinateslist.MainCityID) AS 'HotelList'
FROM eanprod.airportcoordinateslist
-- get the parentregion of the MainCityID
LEFT JOIN eanprod.parentregionlist
ON  eanprod.airportcoordinateslist.MainCityID = eanprod.parentregionlist.RegionID
-- Spanish Translation are in the RegionList_es_es
LEFT JOIN eanprod.regionlist_es_es
ON eanprod.airportcoordinateslist.AirportID = eanprod.regionlist_es_es.RegionID
-- Portuguese Translation are in the RegionList_pt_br
LEFT JOIN eanprod.regionlist_pt_br
ON eanprod.airportcoordinateslist.AirportID = eanprod.regionlist_pt_br.RegionID
WHERE eanprod.airportcoordinateslist.MainCityID <> 0;


-- Priority 09 - Point of Interest Shadow
INSERT INTO 
eanmap.destinations(RegionID,RegionName,RegionName_es_es,RegionNameLong_es_es,RegionName_pt_br,RegionNameLong_pt_br,BestRegionIDs,
                    BestRegionName,InternalRegionName,RegionNameLong,RegionType,SubClass,
                    ParentRegionID,ParentRegionType,ParentRegionName,ParentRegionNameLong,Country,Latitude,Longitude,
                    Priority,GeoLocation,AllHotelCount,AllHotelIDs)
SELECT parentregionlist.RegionID,eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong) AS 'CleanName',
       eanprod.REGION_NAME_CLEAN(regionlist_es_es.RegionName) AS 'CleanName_es_es',regionlist_es_es.RegionNameLong,
       eanprod.REGION_NAME_CLEAN(regionlist_pt_br.RegionName) AS 'CleanName_pt_br',regionlist_pt_br.RegionNameLong,
       parentregionlist.RegionID AS 'BestID',parentregionlist.RegionNameLong AS 'BestName',
       parentregionlist.RegionName,parentregionlist.RegionNameLong,'Point of Interest' as 'RegionType',parentregionlist.SubClass,
	   ParentRegionID,ParentRegionType,ParentRegionName,ParentRegionNameLong,
	   eanprod.EXTRACT_ADDRESS_PART(eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong),'Country') AS 'Country',
       pointsofinterestcoordinateslist.Latitude,pointsofinterestcoordinateslist.Longitude,
       '09' AS 'Priority',CONCAT(pointsofinterestcoordinateslist.Latitude,',',pointsofinterestcoordinateslist.Longitude) as 'Location',
       eanprod.HOTELS_IN_REGION_COUNT(parentregionlist.RegionID) AS 'HotelCount',eanprod.HOTELS_IN_REGION(parentregionlist.RegionID) AS 'HotelList'
FROM eanprod.parentregionlist
-- get the coordinates (if available)
LEFT JOIN eanprod.pointsofinterestcoordinateslist
ON eanprod.parentregionlist.RegionID = eanprod.pointsofinterestcoordinateslist.RegionID
-- Spanish Translation
LEFT JOIN eanprod.regionlist_es_es
ON eanprod.parentregionlist.RegionID = eanprod.regionlist_es_es.RegionID
-- Portuguese Translation
LEFT JOIN eanprod.regionlist_pt_br
ON eanprod.parentregionlist.RegionID = eanprod.regionlist_pt_br.RegionID
-- the point of interest shadow are the ones with the real records
WHERE eanprod.parentregionlist.RegionType='Point of Interest Shadow';

-- Priority 10 - City / neighbor
INSERT INTO 
eanmap.destinations(RegionID,RegionName,RegionName_es_es,RegionNameLong_es_es,RegionName_pt_br,RegionNameLong_pt_br,BestRegionIDs,
                    BestRegionName,InternalRegionName,RegionNameLong,RegionType,SubClass,
                    ParentRegionID,ParentRegionType,ParentRegionName,ParentRegionNameLong,Country,Latitude,Longitude,
                    Priority,GeoLocation,AllHotelCount,AllHotelIDs)
SELECT parentregionlist.RegionID,eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong) AS 'CleanName',
       eanprod.REGION_NAME_CLEAN(regionlist_es_es.RegionName) AS 'CleanName_es_es',regionlist_es_es.RegionNameLong,
       eanprod.REGION_NAME_CLEAN(regionlist_pt_br.RegionName) AS 'CleanName_pt_br',regionlist_pt_br.RegionNameLong,
       parentregionlist.RegionID AS 'BestID',parentregionlist.RegionNameLong AS 'BestName',
	   eanprod.REGION_NAME_CLEAN(parentregionlist.RegionName),parentregionlist.RegionNameLong,parentregionlist.RegionType,parentregionlist.SubClass,
	   ParentRegionID,ParentRegionType,ParentRegionName,ParentRegionNameLong,
	   eanprod.EXTRACT_ADDRESS_PART(eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong),'Country') AS 'Country',
	   regioncentercoordinateslist.CenterLatitude,regioncentercoordinateslist.CenterLongitude,
       '10' AS 'Priority',CONCAT(regioncentercoordinateslist.CenterLatitude,',',regioncentercoordinateslist.CenterLongitude) as 'Location',
       eanprod.HOTELS_IN_REGION_COUNT(parentregionlist.RegionID) AS 'HotelCount',eanprod.HOTELS_IN_REGION(parentregionlist.RegionID) AS 'HotelList'
FROM eanprod.parentregionlist
-- get the coordinates (if available)
LEFT JOIN eanprod.regioncentercoordinateslist
ON eanprod.parentregionlist.RegionID = eanprod.regioncentercoordinateslist.RegionID
-- Spanish Translation
LEFT JOIN eanprod.regionlist_es_es
ON eanprod.parentregionlist.RegionID = eanprod.regionlist_es_es.RegionID
-- Portuguese Translation
LEFT JOIN eanprod.regionlist_pt_br
ON eanprod.parentregionlist.RegionID = eanprod.regionlist_pt_br.RegionID
WHERE eanprod.parentregionlist.RegionType='City' AND eanprod.parentregionlist.SubClass='neighbor';



-- Priority 11 - Multi-Region (within a country) / region
INSERT INTO 
eanmap.destinations(RegionID,RegionName,RegionName_es_es,RegionNameLong_es_es,RegionName_pt_br,RegionNameLong_pt_br,BestRegionIDs,
                    BestRegionName,InternalRegionName,RegionNameLong,RegionType,SubClass,
                    ParentRegionID,ParentRegionType,ParentRegionName,ParentRegionNameLong,Country,Latitude,Longitude,
                    Priority,GeoLocation,AllHotelCount,AllHotelIDs)
SELECT parentregionlist.RegionID,eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong) AS 'CleanName',
       eanprod.REGION_NAME_CLEAN(regionlist_es_es.RegionName) AS 'CleanName_es_es',regionlist_es_es.RegionNameLong,
       eanprod.REGION_NAME_CLEAN(regionlist_pt_br.RegionName) AS 'CleanName_pt_br',regionlist_pt_br.RegionNameLong,
       parentregionlist.RegionID AS 'BestID',parentregionlist.RegionNameLong AS 'BestName',
	   eanprod.REGION_NAME_CLEAN(parentregionlist.RegionName),parentregionlist.RegionNameLong,parentregionlist.RegionType,parentregionlist.SubClass,
	   ParentRegionID,ParentRegionType,ParentRegionName,ParentRegionNameLong,
	   eanprod.EXTRACT_ADDRESS_PART(eanprod.REGION_NAME_CLEAN(parentregionlist.RegionNameLong),'Country') AS 'Country',
       regioncentercoordinateslist.CenterLatitude,regioncentercoordinateslist.CenterLongitude,
       '11' AS 'Priority',CONCAT(regioncentercoordinateslist.CenterLatitude,',',regioncentercoordinateslist.CenterLongitude) as 'Location',
       eanprod.HOTELS_IN_REGION_COUNT(parentregionlist.RegionID) AS 'HotelCount',eanprod.HOTELS_IN_REGION(parentregionlist.RegionID) AS 'HotelList'
FROM eanprod.parentregionlist
-- get the coordinates (if available)
LEFT JOIN eanprod.regioncentercoordinateslist
ON eanprod.parentregionlist.RegionID = eanprod.regioncentercoordinateslist.RegionID
-- Spanish Translation
LEFT JOIN eanprod.regionlist_es_es
ON eanprod.parentregionlist.RegionID = eanprod.regionlist_es_es.RegionID
-- Portuguese Translation
LEFT JOIN eanprod.regionlist_pt_br
ON eanprod.parentregionlist.RegionID = eanprod.regionlist_pt_br.RegionID
-- just the Cites, Areas, Neighboorhoods
WHERE eanprod.parentregionlist.RegionType='Multi-Region (within a country)' AND eanprod.parentregionlist.SubClass='region';


-- fix errors in the Country data
UPDATE destinations
SET Country=eanprod.REGION_NAME_CLEAN(RegionNameLong)
WHERE Country='';


UPDATE destinations
SET Country='United States of America'
WHERE Country IN ('US','USA','United States');

UPDATE destinations
SET Country='United States of America', StateProvince='Alaska'
WHERE Country IN ('Far North Alaska','Interior Alaska');

UPDATE destinations
SET Country='United States of America', StateProvince='Florida', City='Orlando'
WHERE Country='Downtown Disney® area/Lake Buena Vista';

UPDATE destinations
SET Country='France'
WHERE Country='FR';

UPDATE destinations
SET Country='Canada'
WHERE Country='Can';

UPDATE destinations
SET Country='United Kingdom'
WHERE Country='UK';

UPDATE destinations
SET Country='Ecuador'
WHERE Country ='Equador';

UPDATE destinations
SET Country='Mexico'
WHERE Country ='Baja California Norte';

UPDATE destinations
SET Country='South Korea'
WHERE Country ='South Kore';

UPDATE destinations
SET Country='Austria'
WHERE Country ='Austria Wine Region';

UPDATE destinations
SET Country='Saudi Arabia'
WHERE Country IN ('Southern Saudi Arabia','Central Saudi Arabia');

UPDATE destinations
SET Country='Romania'
WHERE Country IN ('Western Romania','Eastern Romania','Romanian Black Sea Coast');

UPDATE destinations
SET Country='Ukraine'
WHERE Country IN ('Eastern Ukraine','Western Ukraine','Kiev - Central Ukraine');

UPDATE destinations
SET Country='Norway'
WHERE Country IN ('Eastern Norway','Fjord Norway','Oslo - Southern Norway','Northern Norway');

UPDATE destinations
SET Country='New Zealand'
WHERE Country ='West Coast New Zealand';

UPDATE destinations
SET Country='Montenegro'
WHERE Country ='Montenegro Coast';

UPDATE destinations
SET Country='Russia'
WHERE Country IN ('Central Russia','Russian Far East','Southern Russia - Black Sea Coast','Northwest Russia');

UPDATE destinations
SET Country='Iceland'
WHERE Country IN ('South Iceland','West Iceland','Northern Iceland','East Iceland');

UPDATE destinations
SET Country='Thailand'
WHERE Country IN ('North Thailand','East Coast Thailand','South Thailand','Northeast Thailand','Central Thailand');

UPDATE destinations
SET Country='Poland'
WHERE Country IN ('Krakow - Lesser Poland','Warsaw - Eastern Poland','Greater Poland');

UPDATE destinations
SET Country='Vietnam'
WHERE Country IN ('Northern Vietnam','Southern Vietnam','Central Vietnam');

UPDATE destinations
SET Country='Switzerland'
WHERE Country IN ('Northern Switzerland','Southern Switzerland','Central Switzerland','Western Switzerland');

UPDATE destinations
SET Country='Sweden'
WHERE Country IN ('Southern Sweden','Northern Sweden','Central Sweden','Ladugardsgardet');

UPDATE destinations
SET Country='Sri Lanka'
WHERE Country IN ('Central Sri Lanka','South Sri Lanka Coast');

UPDATE destinations
SET Country='Chile'
WHERE Country IN ('Central Chile','Southern Chile','Northern Chile');

UPDATE destinations
SET Country='Finland'
WHERE Country='Central Finland';

UPDATE destinations
SET Country='Slovakia'
WHERE Country IN ('Eastern Slovakia','Bratislava - Western Slovakia');

UPDATE destinations
SET Country='Morocco'
WHERE Country='Ouarzazate - South Eastern Morocco';



-- fill all country codes
update destinations
INNER JOIN eanprod.countrylist
ON destinations.Country = countrylist.CountryName
SET destinations.CountryCode = countrylist.CountryCode;

-- erase the test-region
DELETE FROM destinations
WHERE Country='Region Test';


-- use the temporary Kosovo (XK) ISO indicator
UPDATE destinations
SET CountryCode='XK'
WHERE Country='Kosovo';

UPDATE destinations
SET CountryCode='CW'
WHERE Country='Curacao';

UPDATE destinations
SET CountryCode='BQ'
WHERE Country IN ('Sint Eustatius and Saba','Bonaire');

/*###################################################################################
###  Set BRAZIL State Codes using the ParentRegionName 
###  to identify the State Name
### the second part of the query change the Childs of the just changed parent records
###
### Beware, that from MySQL 5.7.6 on, the optimizer may optimize the sub-query away and 
### still give you the error, unless you SET optimizer_switch = 'derived_merge=off';
###################################################################################*/
use eanmap;
-- AC -> Acre (03 records)
UPDATE destinations
SET StateProvince='Acre', StateProvinceCode='AC'
WHERE ParentRegionName='Acre (state)' AND CountryCode='BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Acre', StateProvinceCode='AC'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='AC') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Acre', StateProvinceCode='AC'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='AC') AS P)
AND CountryCode='BR';

-- AL -> Alagoas (23 records)
UPDATE destinations
SET StateProvince='Alagoas', StateProvinceCode='AL'
WHERE ParentRegionName='Alagoas (state)' AND CountryCode='BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Alagoas', StateProvinceCode='AL'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='AL') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Alagoas', StateProvinceCode='AL'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='AL') AS P)
AND CountryCode='BR';

-- AP -> Amapá (05 records)
UPDATE destinations
SET StateProvince='Amapa', StateProvinceCode='AP'
WHERE ParentRegionName='Amapa (state)' AND CountryCode='BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Amapa', StateProvinceCode='AP'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='AP') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Amapa', StateProvinceCode='AP'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='AP') AS P)
AND CountryCode='BR';

-- AM -> Amazonas (11 records)
UPDATE destinations
SET StateProvince='Amazonas', StateProvinceCode='AM'
WHERE ParentRegionName='Amazonas (state)' AND CountryCode='BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Amazonas', StateProvinceCode='AM'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='AM') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Amazonas', StateProvinceCode='AM'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='AM') AS P)
AND CountryCode='BR';

-- BA -> Bahia (50 records)
UPDATE destinations
SET StateProvince='Bahia', StateProvinceCode='BA'
WHERE ParentRegionName='Bahia (state)' AND CountryCode='BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Bahia', StateProvinceCode='BA'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='BA') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Bahia', StateProvinceCode='BA'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='BA') AS P)
AND CountryCode='BR';

-- CE -> Ceara (22 records)
UPDATE destinations
SET StateProvince='Ceara', StateProvinceCode='CE'
WHERE ParentRegionName='Ceara (state)' AND CountryCode='BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Ceara', StateProvinceCode='CE'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='CE') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Ceara', StateProvinceCode='CE'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='CE') AS P)
AND CountryCode='BR';

-- DF -> Distrito Federal (12 records)
UPDATE destinations
SET StateProvince='Federal District', StateProvinceCode='DF'
WHERE ParentRegionName='Federal District (state)' AND CountryCode='BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Federal District', StateProvinceCode='DF'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='DF') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Federal District', StateProvinceCode='DF'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='DF') AS P)
AND CountryCode='BR';

-- ES -> Espirito Santo (08 records)
UPDATE destinations
SET StateProvince='Espirito Santo', StateProvinceCode='ES'
WHERE ParentRegionName='Espirito Santo (state)' AND CountryCode='BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Espirito Santo', StateProvinceCode='ES'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='ES') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Espirito Santo', StateProvinceCode='ES'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='ES') AS P)
AND CountryCode='BR';

-- GO -> Goias (23 records)
UPDATE destinations
SET StateProvince='Goias', StateProvinceCode='GO'
WHERE ParentRegionName='Goias (state)' AND CountryCode='BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Goias', StateProvinceCode='GO'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='GO') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Goias', StateProvinceCode='GO'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='GO') AS P)
AND CountryCode='BR';

-- MA -> Maranhão (90 records)
UPDATE destinations
SET StateProvince='Maranhao', StateProvinceCode='MA'
WHERE ParentRegionName='Maranhao (state)' AND CountryCode='BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Maranhao', StateProvinceCode='MA'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='MA') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Maranhao', StateProvinceCode='MA'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='MA') AS P)
AND CountryCode='BR';

-- MT -> Mato Grosso (18 records)
UPDATE destinations
SET StateProvince='Mato Grosso', StateProvinceCode='MT'
WHERE ParentRegionName='Mato Grosso (state)' AND CountryCode='BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Mato Grosso', StateProvinceCode='MT'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='MT') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Mato Grosso', StateProvinceCode='MT'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='MT') AS P)
AND CountryCode='BR';

-- MS -> Mato Grosso do Sul (59 records)
UPDATE destinations
SET StateProvince='Mato Grosso do Sul', StateProvinceCode='MS'
WHERE ParentRegionName='Mato Grosso do Sul (state)' AND CountryCode='BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Mato Grosso do Sul', StateProvinceCode='MS'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='MS') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Mato Grosso do Sul', StateProvinceCode='MS'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='MS') AS P)
AND CountryCode='BR';

-- MG -> Minas Gerais (139 records)
UPDATE destinations
SET StateProvince='Minas Gerais', StateProvinceCode='MG'
WHERE ParentRegionName='Minas Gerais (state)' AND CountryCode='BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Minas Gerais', StateProvinceCode='MG'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='MG') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Minas Gerais', StateProvinceCode='MG'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='MG') AS P)
AND CountryCode='BR';

-- PA -> Para (22 records)
UPDATE destinations
SET StateProvince='Para', StateProvinceCode='PA'
WHERE ParentRegionName='Para (state)' AND CountryCode='BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Para', StateProvinceCode='PA'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='PA') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Para', StateProvinceCode='PA'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='PA') AS P)
AND CountryCode='BR';

-- PB -> Paraiba (09 records)
UPDATE destinations
SET StateProvince='Paraiba', StateProvinceCode='PB'
WHERE ParentRegionName='Paraiba (state)' AND CountryCode='BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Paraiba', StateProvinceCode='PB'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='PB') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Paraiba', StateProvinceCode='PB'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='PB') AS P)
AND CountryCode='BR';

-- PR -> Parana (38 records)
UPDATE destinations
SET StateProvince='Parana', StateProvinceCode='PR'
WHERE ParentRegionName='Parana (state)' AND CountryCode='BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Parana', StateProvinceCode='PR'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='PR') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Parana', StateProvinceCode='PR'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='PR') AS P)
AND CountryCode='BR';

-- PE -> Pernambuco (20 records)
UPDATE destinations
SET StateProvince='Pernambuco', StateProvinceCode='PE'
WHERE ParentRegionName='Pernambuco (state)' AND CountryCode='BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Pernambuco', StateProvinceCode='PE'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='PE') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Pernambuco', StateProvinceCode='PE'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='PE') AS P)
AND CountryCode='BR';

-- PI -> Piaui (11 records)
UPDATE destinations
SET StateProvince='Piaui', StateProvinceCode='PI'
WHERE ParentRegionName='Piaui (state)' AND CountryCode = 'BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Piaui', StateProvinceCode='PI'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='PI') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Piaui', StateProvinceCode='PI'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='PI') AS P)
AND CountryCode='BR';

-- RJ -> Rio De Janeiro (30 records)
UPDATE destinations
SET StateProvince='Rio De Janeiro', StateProvinceCode='RJ'
WHERE ParentRegionName='Rio de Janeiro (state)' AND CountryCode='BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Rio De Janeiro', StateProvinceCode='RJ'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='RJ') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Rio De Janeiro', StateProvinceCode='RJ'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='RJ') AS P)
AND CountryCode='BR';

-- RN -> Rio Grande do Norte (18 records)
UPDATE destinations
SET StateProvince='Rio Grande do Norte', StateProvinceCode='RN'
WHERE ParentRegionName='Rio Grande do Norte (state)' AND CountryCode = 'BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Rio Grande do Norte', StateProvinceCode='RN'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='RN') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Rio Grande do Norte', StateProvinceCode='RN'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='RN') AS P)
AND CountryCode='BR';

-- RS -> Rio Grande do Sul (174 records)
UPDATE destinations
SET StateProvince='Rio Grande do Sul', StateProvinceCode='RS'
WHERE ParentRegionName='Rio Grande do Sul (state)' AND CountryCode = 'BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Rio Grande do Sul', StateProvinceCode='RS'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='RS') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Rio Grande do Sul', StateProvinceCode='RS'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='RS') AS P)
AND CountryCode='BR';

-- RO -> Rondônia (06 records)
UPDATE destinations
SET StateProvince='Rondonia', StateProvinceCode='RO'
WHERE ParentRegionName='Rondonia (state)' AND CountryCode = 'BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Rondonia', StateProvinceCode='RO'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='RO') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Rondonia', StateProvinceCode='RO'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='RO') AS P)
AND CountryCode='BR';

-- RR -> Roraima (03 records)
UPDATE destinations
SET StateProvince='Roraima', StateProvinceCode='RR'
WHERE ParentRegionName='Roraima (state)' AND CountryCode = 'BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Roraima', StateProvinceCode='RR'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='RR') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Roraima', StateProvinceCode='RR'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='RR') AS P)
AND CountryCode='BR';

-- SC -> Santa Catarina (42 records)
UPDATE destinations
SET StateProvince='Santa Catarina', StateProvinceCode='SC'
WHERE ParentRegionName='Santa Catarina (state)' AND CountryCode='BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Santa Catarina', StateProvinceCode='SC'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='SC') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Santa Catarina', StateProvinceCode='SC'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='SC') AS P)
AND CountryCode='BR';

-- SP -> São Paulo (95 records)
UPDATE destinations
SET StateProvince='Sao Paulo', StateProvinceCode='SP'
WHERE ParentRegionName='Sao Paulo (state)' AND CountryCode='BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Sao Paulo', StateProvinceCode='SP'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='SP') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Sao Paulo', StateProvinceCode='SP'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='SP') AS P)
AND CountryCode='BR';

-- SE -> Sergipe (12 records)
UPDATE destinations
SET StateProvince='Sergipe', StateProvinceCode='SE'
WHERE ParentRegionName='Sergipe (state)' AND CountryCode='BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Sergipe', StateProvinceCode='SE'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='SE') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Sergipe', StateProvinceCode='SE'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='SE') AS P)
AND CountryCode='BR';

-- TO -> Tocantins (05 records)
UPDATE destinations
SET StateProvince='Tocantins', StateProvinceCode='TO'
WHERE ParentRegionName='Tocantins (state)' AND CountryCode='BR';
-- now change the child records
UPDATE destinations
SET StateProvince='Tocantins', StateProvinceCode='TO'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='TO') AS P)
AND CountryCode='BR';
UPDATE destinations
SET StateProvince='Tocantins', StateProvinceCode='TO'
WHERE ParentRegionID IN 
(SELECT * FROM ( SELECT RegionID FROM destinations AS P WHERE CountryCode='BR' and StateProvinceCode='TO') AS P)
AND CountryCode='BR';


/*###################################################################################
########### adjust the BEST REGION (ID & NAME) to cover the case of smaller islands
########### where instead of the city we will like to use the WHOLE Island
########### normaly the parent RegionID will be the best choice
#####################################################################################
########### as of now this is hard coded in this query
###################################################################################*/
use eanmap;

/*########################
### Fix Hawaii Islands ###
########################*/
-- Fix Hawaii (The Big Island) --
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionName LIKE '%Hawaii (The Big Island)%' AND ParentRegionType='Multi-City (Vicinity)';

UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionName LIKE '%Maui Island%' AND ParentRegionType='Multi-City (Vicinity)';

UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionName LIKE '%Kauai Island%' AND ParentRegionType='Multi-City (Vicinity)';

UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionName LIKE '%Oahu Island%' AND ParentRegionType='Multi-City (Vicinity)';

UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionName LIKE '%Lanai Island%' AND ParentRegionType='Multi-City (Vicinity)';

UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionName LIKE '%Molokai Island%' AND ParentRegionType='Multi-City (Vicinity)';


/*###########################
### Fix Caribeean Islands ###
###########################*/
-- Fix Barbados (55 rec) to use BEST as the whole Island --
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%Barbados (all)%';

-- Fix St.Lucia (28 rec) to use BEST as the whole Island --
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%St. Lucia (all)%';

-- Fix Grand Cayman (19 rec) to use BEST as the whole Island --
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%Grand Cayman, Cayman Islands%';

-- Fix Aruba (17 rec) to use BEST as the whole Island --
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%Aruba (all), Aruba%';

-- Fix Antigua and Barbuda (29 rec) to use BEST as the whole Island --
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%Antigua and Barbuda (all), Antigua and Barbuda%';

-- Fix Bermuda (21 rec) to use BEST as the whole Island --
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%Bermuda (all), Bermuda%';

-- Fix Turks and Caicos (23 rec) to use BEST as the whole Island --
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%Turks and Caicos (all), Turks and Caicos%';

-- Fix Curacao (22 rec) to use BEST as the whole Island --
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%Curacao (all), Curacao%';

-- Fix Bonaire (2 rec) to use BEST as the whole Island --
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%Bonaire (all), Bonaire, Sint Eustatius and Saba%';

-- Fix Haiti (15 rec) to use BEST the Port-au-Prince (and vicinity) --
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%Port-au-Prince (and vicinity), Haiti%';

-- Fix St Thomas and St John (23 rec) to use BEST as the whole Island --
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%St. Thomas and St. John%';

-- Fix Guadeloupe (French Islands) (23 rec) to use BEST as all the Island --
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%Guadeloupe (islands), Guadeloupe%';

-- Fix St. Barthelemy (5 rec) to use BEST as all the Island --
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%St. Barthelemy (all), St. Barthelemy%';

-- Fix Martinique (French Islands) (24 rec) to use BEST as all the Island --
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%Martinique (all)%';

-- Fix St. Martin (French) (18 rec) to use ALL the Island French+Dutch --
UPDATE destinations
SET BestRegionIDs='602299,602298', BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%St. Martin (French), St. Martin%' OR 
		RegionNameLong LIKE '%St. Martin (French), St. Martin%';

-- Fix Sint Maarten (Dutch) (17 rec) to use ALL the Island French+Dutch --
UPDATE destinations
SET BestRegionIDs='602299,602298', BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%Sint Maarten (Dutch)%' OR 
		RegionNameLong LIKE '%Sint Maarten (Dutch)%';

-- Fix Grenada (18 rec) to use BEST as the whole Island --
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%Grenada (all), Grenada%';
 
-- Fix British Virgin Islands (30 rec) to use BEST as all the Island --
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%British Virgin Islands (all)%';

-- Fix St. Croix (4 rec) to use BEST as all the Island --
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%St. Croix Island%';

-- Fix Nevis (9 rec) to use BEST as the whole Island --
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%Nevis, St. Kitts and Nevis%';

-- Fix St. Kitts (3 rec) to use BEST as the whole Island --
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%St. Kitts, St. Kitts and Nevis%';

-- Fix Tobago (21 rec) to use BEST as the whole Island --
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%Tobago, Trinidad and Tobago%';

-- Fix Trinidad (41 rec) to use BEST as the whole Island --
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%Trinidad, Trinidad and Tobago%';

-- Fix Anguilla (14 rec) to use BEST as the whole Island --
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%Anguilla (all), Anguilla%';

-- Fix St. Vincent and the Granadines (17 rec) to use BEST as the whole Island ###
-- somehow it need to use the LIKE instead
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%St. Vincent and the Grenadines (all)%';


-- Fix San Juan, Puerto Rico by creating a San Juan (and vicinity) Manual Region ###
-- this record will have a list of RegionIDs inside ###
-- San Juan, Condado, Miramar, Old San Juan, Ocean Park, Isla Verde
-- 3179,506189,6004932,6004934,6082360,6139938 -> Total (137 hotels)
-- ORIGINAL QUERY:
-- use eanmap;
-- select *,eanprod.HOTELS_IN_REGION_COUNT(RegionID) from destinations
-- where
--  	RegionType NOT IN ('Point of Interest','Point of Interest Shadow') AND
--     (RegionName LIKE 'San Juan%' OR RegionName LIKE 'San Juan Antiguo%' OR RegionName LIKE 'Condado%' 
--      OR RegionName LIKE 'Ocean Park%' OR RegionName LIKE 'Miramar%' OR RegionName LIKE 'Isla Verde%')
--     AND RegionNameLong LIKE '%Puerto Rico%'  
--
INSERT INTO 
eanmap.destinations(RegionID,RegionName,RegionName_es_es,RegionNameLong_es_es,RegionName_pt_br,RegionNameLong_pt_br,BestRegionIDs,BestRegionName,
                    InternalRegionName,RegionNameLong,RegionType,SubClass,
                    ParentRegionID,ParentRegionType,ParentRegionName,ParentRegionNameLong,City,StateProvince,Country,CountryCode,Latitude,Longitude,
                    Priority,GeoLocation,AllHotelCount,AllHotelIDs)
values(9999991,'San Juan, Puerto Rico','San Juan, Puerto Rico','San Juan, Puerto Rico','San Juan, Porto Rico','San Juan, Porto Rico','3179,506189,6004932,6004934,6082360,6139938','San Juan (and vicinity), Puerto Rico',
       'San Juan (and vicinity)','San Juan (and vicinity), Puerto Rico','Multi-City (Vicinity)','',
       '180021','Multi-City (Vicinity)', 'Puerto Rico Island', 'Puerto Rico Island, Puerto Rico','San Juan', NULL, 'Puerto Rico',
       'PR','18.466228', '-66.116364','01','18.466228,-66.116364',
       eanprod.HOTELS_IN_REGION_LIST_COUNT('3179,506189,6004932,6004934,6082360,6139938'),
       eanprod.HOTELS_IN_REGION_LIST('3179,506189,6004932,6004934,6082360,6139938'));


-- Fix Tenerife on Canary Islands, Spain (65) records ##########
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE 'Tenerife, Spain';

-- Fix Fuenteventura on Canary Islands, Spain (27) records ##########
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE 'Fuerteventura, Spain';

-- Fix Gran Canaria on Canary Islands, Spain (41) records ##########
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong like 'Gran Canaria, Spain';

-- Fix Lanzarote on Canary Islands, Spain (35) records ##########
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE 'Lanzarote, Spain';

-- Fix El Hierro on Canary Islands, Spain (9) records ##########
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE 'El Hierro, Spain';

-- Fix La Gomera on Canary Islands, Spain (10) records ##########
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE 'La Gomera. Spain';

-- Fix La Palma on Canary Islands, Spain (13) records ##########
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE 'La Palma. Spain';


-- Fix Palma de Mallorca on Balearic Islands, Spain (133) records ##########
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE 'Mallorca Island, Spain';


-- Fix Palma de Mallorca on Balearic Islands, Spain (37) records ##########
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE 'Ibiza Island, Spain';

-- Fix Formentera on Balearic Islands, Spain (8) records ##########
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE 'Formentera Island, Spain';



-- Fix Corfu-Island, Greece (67 rec) to use BEST as the whole Island ###
UPDATE destinations
SET BestRegionIDs=ParentRegionID, BestRegionName=ParentRegionNameLong,
    AllHotelCount=eanprod.HOTELS_IN_REGION_COUNT(ParentRegionID),
    AllHotelIDs=eanprod.HOTELS_IN_REGION(ParentRegionID)
WHERE ParentRegionNameLong LIKE '%Corfu Island, Greece%';




-- fill the State name
DROP TABLE IF EXISTS countrystate_fix;
CREATE TABLE countrystate_fix
(
	CountryCode VARCHAR(2),
	StateProvince VARCHAR(2),
	StateProvinceName VARCHAR(100),
	StateProvinceCode VARCHAR(3),
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

-- index by ParentRegionID to use for applying record fixers faster
CREATE UNIQUE INDEX idx_coountryandstate_code ON countrystate_fix(CountryCode,StateProvince);


INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("AU","AC","Australia Capital Territory","ACT");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("AU","NT","Northern Territory","NT");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("AU","NW","New South Wales","NSW");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("AU","QL","Queensland","QLD");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("AU","SA","South Australia","SA");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("AU","TS","Tasmania","TAS");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("AU","VC","Victoria","VIC");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("AU","WA","Western Australia","WA");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("AU","WT","Western Australia","WA");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("CA","AB","Alberta","AB");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("CA","BC","British Columbia","BC");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("CA","MB","Manitoba","MB");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("CA","NB","New Brunswick","NB");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("CA","NL","Newfoundland and Labrador","NL");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("CA","NS","Nova Scotia","NS");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("CA","NT","Northwest Territories","NT");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("CA","NU","Nunavut","NU");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("CA","ON","Ontario","ON");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("CA","PE","Prince Edward Island","PE");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("CA","PQ","Quebec","QC");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("CA","QC","Quebec","QC");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("CA","SK","Saskatchewan","SK");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("CA","YT","Yukon","YT");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","AK","Alaska","SK");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","AL","Alabama","AL");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","AR","Arkansas","AR");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","AZ","Arizona","AZ");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","CA","California","CA");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","CO","Colorado","CO");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","CT","Connecticut","CT");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","DC","District of Columbia","DC");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","DE","Delaware","DE");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","FL","Florida","FL");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","GA","Georgia","GA");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","GE","Georgia","GA");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","HI","Hawaii","HI");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","IA","Iowa","IA");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","ID","Idaho","ID");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","IL","Illinois","IL");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","IN","Indiana","IN");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","KS","Kansas","KS");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","KY","Kentucky","KY");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","LA","Louisiana","LA");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","MA","Massachusetts","MA");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","MD","Maryland","MD");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","ME","Maine","ME");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","MI","Michigan","MI");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","MN","Minnesota","MN");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","MO","Missouri","MO");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","MS","Mississippi","MS");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","MT","Montana","MT");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","NC","North Carolina","NC");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","ND","North Dakota","ND");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","NE","Nebraska","NE");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","NH","New Hampshire","NH");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","NJ","New Jersey","NJ");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","NM","New Mexico","NM");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","NV","Nevada","NV");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","NY","New York","NY");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","OH","Ohio","OH");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","OK","Oklahoma","OK");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","OR","Oregon","OR");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","PA","Pennsylvania","PA");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","RI","Rhode Island","RI");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","SC","South Carolina","SC");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","SD","South Dakota","SD");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","TN","Tennessee","TN");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","TX","Texas","TX");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","UT","Utah","UT");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","VA","Virginia","VA");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","VT","Vermont","VT");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","WA","Washington","WA");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","WI","Wisconsin","WI");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","WV","West Virginia","WV");
INSERT INTO countrystate_fix (CountryCode,StateProvince,StateProvinceName,StateProvinceCode) VALUES ("US","WY","Wyoming","WY");
--

-- update all state codes for the countries we have in the countrystate_fix table
UPDATE destinations D
INNER JOIN eanprod.countrylist L ON
    D.CountryCode = L.CountryCode
INNER JOIN countrystate_fix C ON
    D.RegionName LIKE CONCAT("%",C.StateProvinceName,", ",L.CountryName,"%")
--    D.CountryCode = C.CountryCode AND D.StateProvince = C.StateProvinceName
SET D.StateProvinceCode=C.StateProvinceCode,
D.StateProvince=C.StateProvinceName;


#####################################################################################
########### fill the hotels table ###################################################
#####################################################################################
use eanmap;

-- view to try to speed up the creation of the hotels fill query
-- DROP TABLE IF EXISTS GiataToEAN;
-- CREATE TABLE GiataToEAN
-- AS (SELECT ProviderID AS 'EANHotelID',GiataID
-- FROM giataproviders WHERE ProviderCode = 'expedia_ean');
-- create an unique index for EANHotelIDs
-- ALTER IGNORE TABLE GiataToEAN
-- ADD UNIQUE INDEX idx_GiataToEan (EANHotelID);


-- use eanmap;
-- table to save all hotels (properties)
-- this takes a while to generate so be patient ! (05:05)
-- DROP TABLE IF EXISTS hotels;
-- CREATE TABLE hotels
-- (
--	EANHotelID INT NOT NULL,
--	HotelName VARCHAR(70),
--	Address1 VARCHAR(50),
--	Address2 VARCHAR(50),
--	City VARCHAR(50),
--	StateProvinceCode VARCHAR(3),
--	StateProvince VARCHAR(50),
--	CountryCode VARCHAR(2),
--	Country VARCHAR(50),	
--	PostalCode VARCHAR(15),
--	FreeFormTxt VARCHAR(500),
--	Latitude numeric(9,6),
--	Longitude numeric(9,6),
--	GeoLocation VARCHAR(20),
--	Phone VARCHAR(20),
--	Fax VARCHAR(20), 
--	AirportCode VARCHAR(3),
--	AirportName VARCHAR(70),
--	PropertyCategory VARCHAR(256),
--	StarRating numeric(2,1),
--	ChainBrand VARCHAR(50),
--	BusinessModel VARCHAR(20),
--	MainRegionID INT,
--	MainRegionName VARCHAR(255),
--	AllRegionIDs TEXT,
--	AllRegionIDsCount INT,    
--	GeoOSMAddress VARCHAR(255),	
--	GeoGoogleAddress VARCHAR(255),
--	ExpediaID INT,
--  TripAdvisorID INT,
--  GiataID INT,
--  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--	PRIMARY KEY (EANHotelID)
-- ) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

-- EOF --
