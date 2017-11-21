/**************************************************** 
** SQLite version 3 script to create empty eanprod **
** for use with EAN downloadable content           **
** $ sqlite3 eanprod.db < SQLite_create_eanprod.sql**
****************************************************/
BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS `whattoexpectlist` (
	`EANHotelID`	integer,
	`LanguageCode`	text,
	`WhatToExpect`	text
);
CREATE INDEX IF NOT EXISTS `whattoexpectlist_idx` ON `whattoexpectlist` (
	`EANHotelID`
);
CREATE TABLE IF NOT EXISTS `spadescriptionlist` (
	`EANHotelID`	integer,
	`LanguageCode`	text,
	`SpaDescription`	text
);
CREATE INDEX IF NOT EXISTS `spadescriptionlist_idx` ON `spadescriptionlist` (
	`EANHotelID`
);
CREATE TABLE IF NOT EXISTS `roomtypelist` (
	`EANHotelID`	integer,
	`RoomTypeID`	integer,
	`LanguageCode`	text,
	`RoomTypeImage`	text,
	`RoomTypeName`	text,
	`RoomTypeDescription`	text
);
CREATE INDEX IF NOT EXISTS `roomtypelist_idx` ON `roomtypelist` (
	`EANHotelID`,
	`RoomTypeID`
);
CREATE TABLE IF NOT EXISTS `trainmetrostationcoordinateslist` (
	RegionID 	integer,
	RegionName 	text,
	RegionType 	text,
  	Latitude	decimal ( 9 , 6 ) DEFAULT NULL,
	Longitude	decimal ( 9 , 6 ) DEFAULT NULL,
	PRIMARY KEY(`RegionID`)
);
CREATE TABLE IF NOT EXISTS `regioneanhotelidmapping` (
	`RegionID`	int ( 11 ) NOT NULL,
	`EANHotelID`	int ( 11 ) NOT NULL,
	PRIMARY KEY(`RegionID`,`EANHotelID`)
);
CREATE INDEX IF NOT EXISTS `regioneanhotelidmapping_idx` ON `regioneanhotelidmapping` (
	`EANHotelID`,
	`RegionID`
);
CREATE TABLE IF NOT EXISTS `regioncentercoordinateslist` (
	`RegionID`	int ( 11 ) NOT NULL,
	`RegionName`	varchar ( 255 ) DEFAULT NULL,
	`CenterLatitude`	decimal ( 9 , 6 ) DEFAULT NULL,
	`CenterLongitude`	decimal ( 9 , 6 ) DEFAULT NULL,
	PRIMARY KEY(`RegionID`)
);
CREATE TABLE IF NOT EXISTS `recreationdescriptionlist` (
	`EANHotelID`	integer,
	`LanguageCode`	text,
	`RecreationDescription`	text
);
CREATE INDEX IF NOT EXISTS `recreationdescriptionlist_idx` ON `recreationdescriptionlist` (
	`EANHotelID`
);
CREATE TABLE IF NOT EXISTS `propertytypelist` (
	`PropertyCategory`	int ( 11 ) NOT NULL,
	`LanguageCode`	varchar ( 5 ) DEFAULT NULL,
	`PropertyCategoryDesc`	varchar ( 256 ) DEFAULT NULL,
	PRIMARY KEY(`PropertyCategory`)
);
CREATE TABLE IF NOT EXISTS `propertyroomslist` (
	`EANHotelID`	integer,
	`LanguageCode`	text,
	`PropertyRoomsDescription`	text
);
CREATE INDEX IF NOT EXISTS `propertyroomslist_idx` ON `propertyroomslist` (
	`EANHotelID`
);
CREATE TABLE IF NOT EXISTS `propertyrenovationslist` (
	`EANHotelID`	integer,
	`LanguageCode`	text,
	`PropertyRenovationsDescription`	text
);
CREATE INDEX IF NOT EXISTS `propertyrenovationslist_idx` ON `propertyrenovationslist` (
	`EANHotelID`
);
CREATE TABLE IF NOT EXISTS `propertynationalratingslist` (
	`EANHotelID`	integer,
	`LanguageCode`	text,
	`PropertyNationalRatingsDescription`	text
);
CREATE INDEX IF NOT EXISTS `propertynationalratingslist_idx` ON `propertynationalratingslist` (
	`EANHotelID`
);
CREATE TABLE IF NOT EXISTS `propertymandatoryfeeslist` (
	`EANHotelID`	integer,
	`LanguageCode`	text,
	`PropertyMandatoryFeesDescription`	text
);
CREATE INDEX IF NOT EXISTS `propertymandatoryfeeslist_idx` ON `propertymandatoryfeeslist` (
	`EANHotelID`
);
CREATE TABLE IF NOT EXISTS `propertylocationlist` (
	`EANHotelID`	integer,
	`LanguageCode`	text,
	`PropertyLocationDescription`	text
);
CREATE INDEX IF NOT EXISTS `propertylocationlist_idx` ON `propertylocationlist` (
	`EANHotelID`
);
CREATE TABLE IF NOT EXISTS `propertyfeeslist` (
	`EANHotelID`	integer,
	`LanguageCode`	text,
	`PropertyFeesDescription`	text
);
CREATE INDEX IF NOT EXISTS `propertyfeeslist_idx` ON `propertyfeeslist` (
	`EANHotelID`
);
CREATE TABLE IF NOT EXISTS `propertydescriptionlist` (
	`EANHotelID`	integer,
	`LanguageCode`	text,
	`PropertyDescription`	text
);
CREATE INDEX IF NOT EXISTS `propertydescriptionlist_idx` ON `propertydescriptionlist` (
	`EANHotelID`
);
CREATE TABLE IF NOT EXISTS `propertybusinessamenitieslist` (
	`EANHotelID`	integer,
	`LanguageCode`	text,
	`PropertyBusinessAmenitiesDescription`	text
);
CREATE INDEX IF NOT EXISTS `propertybusinessamenitieslist_idx` ON `propertybusinessamenitieslist` (
	`EANHotelID`
);
CREATE TABLE IF NOT EXISTS `propertyattributelink` (
	`EANHotelID`	int ( 11 ) NOT NULL,
	`AttributeID`	int ( 11 ) NOT NULL,
	`LanguageCode`	varchar ( 5 ) DEFAULT NULL,
	`AppendTxt`	varchar ( 191 ) DEFAULT NULL,
	PRIMARY KEY(`EANHotelID`,`AttributeID`)
);
CREATE INDEX IF NOT EXISTS `propertyattributelink_idx` ON `propertyattributelink` (
	`AttributeID`,
	`EANHotelID`
);
CREATE TABLE IF NOT EXISTS `propertyamenitieslist` (
	`EANHotelID`	integer,
	`LanguageCode`	text,
	`PropertyAmenitiesDescription`	text
);
CREATE INDEX IF NOT EXISTS `propertyamenitieslist_idx` ON `propertyamenitieslist` (
	`EANHotelID`
);
CREATE TABLE IF NOT EXISTS `policydescriptionlist` (
	`EANHotelID`	integer,
	`LanguageCode`	text,
	`PolicyDescription`	text
);
CREATE INDEX IF NOT EXISTS `policydescriptionlist_idx` ON `policydescriptionlist` (
	`EANHotelID`
);
CREATE TABLE IF NOT EXISTS `pointsofinterestcoordinateslist` (
	`RegionID`	int ( 11 ) NOT NULL,
	`RegionName`	varchar ( 255 ) DEFAULT NULL,
	`RegionNameLong`	varchar ( 191 ) NOT NULL DEFAULT '',
	`Latitude`	decimal ( 9 , 6 ) DEFAULT NULL,
	`Longitude`	decimal ( 9 , 6 ) DEFAULT NULL,
	`SubClassification`	varchar ( 20 ) DEFAULT NULL,
	PRIMARY KEY(`RegionNameLong`)
);
CREATE INDEX IF NOT EXISTS `pointsofinterestcoordinateslist_idx_pointsofinterestcoordinateslist_regionid` ON `pointsofinterestcoordinateslist` (
	`RegionID`
);
CREATE INDEX IF NOT EXISTS `pointsofinterestcoordinateslist_idx_poi__geoloc` ON `pointsofinterestcoordinateslist` (
	`Latitude`,
	`Longitude`
);

CREATE TABLE IF NOT EXISTS `parentregionlist` (
	`RegionID`	integer NOT NULL,
	`RegionType`	varchar ( 50 ) DEFAULT NULL,
	`RelativeSignificance`	varchar ( 3 ) DEFAULT NULL,
	`SubClass`	varchar ( 50 ) DEFAULT NULL,
	`RegionName`	varchar ( 255 ) DEFAULT NULL,
	`RegionNameLong`	varchar ( 510 ) DEFAULT NULL,
	`ParentRegionID`	int ( 11 ) DEFAULT NULL,
	`ParentRegionType`	varchar ( 50 ) DEFAULT NULL,
	`ParentRegionName`	varchar ( 255 ) DEFAULT NULL,
	`ParentRegionNameLong`	varchar ( 510 ) DEFAULT NULL,
	PRIMARY KEY(`RegionID`)
);
CREATE INDEX IF NOT EXISTS `parentregionlist_idx_regionnamelong` ON `parentregionlist` (
	`RegionNameLong`
);
CREATE INDEX IF NOT EXISTS `parentregionlist_idx` ON `parentregionlist` (
	`ParentRegionID`
);
CREATE TABLE IF NOT EXISTS `neighborhoodcoordinateslist` (
	`RegionID`	integer,
	`RegionName`	text,
	`Coordinates`	text
);
CREATE INDEX IF NOT EXISTS `neighborhoodcoordinateslist_idx` ON `neighborhoodcoordinateslist` (
	`RegionID`
);
CREATE TABLE IF NOT EXISTS `hotelimagelist` (
	`EANHotelID`	integer NOT NULL,
	`Caption`	varchar ( 70 ) DEFAULT NULL,
	`URL`	varchar ( 150 ) NOT NULL,
	`Width`	integer DEFAULT NULL,
	`Height`	integer DEFAULT NULL,
	`ByteSize`	integer DEFAULT NULL,
	`ThumbnailURL`	varchar ( 300 ) DEFAULT NULL,
	`DefaultImage`	tinyint ( 1 ) DEFAULT NULL,
	PRIMARY KEY(`URL`)
);
CREATE INDEX IF NOT EXISTS `hotelimagelist_idx` ON `hotelimagelist` (
	`EANHotelID`
);
CREATE TABLE IF NOT EXISTS `diningdescriptionlist` (
	`EANHotelID`	integer,
	`LanguageCode`	text,
	`PropertyDiningDescription`	text
);
CREATE INDEX IF NOT EXISTS `diningdescriptionlist_idx` ON `diningdescriptionlist` (
	`EANHotelID`
);
CREATE TABLE IF NOT EXISTS `countrylist` (
	`CountryID`	integer NOT NULL,
	`LanguageCode`	varchar ( 5 ) DEFAULT NULL,
	`CountryName`	varchar ( 250 ) DEFAULT NULL,
	`CountryCode`	varchar ( 2 ) NOT NULL,
	`Transliteration`	varchar ( 256 ) DEFAULT NULL,
	`ContinentID`	integer DEFAULT NULL,
	PRIMARY KEY(`CountryID`)
);
CREATE INDEX IF NOT EXISTS `countrylist_idx_countrylist_countryname` ON `countrylist` (
	`CountryName`
);
CREATE INDEX IF NOT EXISTS `countrylist_idx_countrylist_countrycode` ON `countrylist` (
	`CountryCode`
);
CREATE TABLE IF NOT EXISTS `citycoordinateslist` (
	`RegionID`	integer,
	`RegionName`	text,
	`Coordinates`	text
);
CREATE INDEX IF NOT EXISTS `citycoordinateslist_idx` ON `citycoordinateslist` (
	`RegionID`
);

CREATE TABLE IF NOT EXISTS `chainlist` (
	`ChainCodeID`	int ( 11 ) NOT NULL,
	`ChainName`	varchar ( 30 ) DEFAULT NULL,
	PRIMARY KEY(`ChainCodeID`)
);
CREATE TABLE IF NOT EXISTS `attributelist` (
	`AttributeID`	integer NOT NULL,
	`LanguageCode`	varchar ( 5 ) DEFAULT NULL,
	`AttributeDesc`	varchar ( 255 ) DEFAULT NULL,
	`Type`	varchar ( 15 ) DEFAULT NULL,
	`SubType`	varchar ( 15 ) DEFAULT NULL,
	PRIMARY KEY(`AttributeID`)
);
CREATE TABLE IF NOT EXISTS `areaattractionslist` (
	`EANHotelID`	integer,
	`LanguageCode`	text,
	`AreaAttractions`	text
);
CREATE INDEX IF NOT EXISTS `areaattractionslist_idx` ON `areaattractionslist` (
	`EANHotelID`
);
CREATE TABLE IF NOT EXISTS `airportcoordinateslist` (
	`AirportID`	integer NOT NULL,
	`AirportCode`	varchar ( 3 ) NOT NULL,
	`AirportName`	varchar ( 70 ) DEFAULT NULL,
	`Latitude`	decimal ( 9 , 6 ) DEFAULT NULL,
	`Longitude`	decimal ( 9 , 6 ) DEFAULT NULL,
	`MainCityID`	integer DEFAULT NULL,
	`CountryCode`	varchar ( 2 ) DEFAULT NULL,
	PRIMARY KEY(`AirportCode`)
);
CREATE INDEX IF NOT EXISTS `airportcoordinateslist_idx_airportcoordinatelist_maincityid` ON `airportcoordinateslist` (
	`MainCityID`
);
CREATE INDEX IF NOT EXISTS `airportcoordinateslist_idx_airportcoordinatelist_airportname` ON `airportcoordinateslist` (
	`AirportName`
);
CREATE INDEX IF NOT EXISTS `airportcoordinateslist_airportcoordinate_geoloc` ON `airportcoordinateslist` (
	`Latitude`,
	`Longitude`
);
CREATE TABLE IF NOT EXISTS `activepropertylist` (
	`EANHotelID`	integer NOT NULL,
	`SequenceNumber`	integer DEFAULT NULL,
	`Name`	varchar ( 70 ) DEFAULT NULL,
	`Address1`	varchar ( 50 ) DEFAULT NULL,
	`Address2`	varchar ( 50 ) DEFAULT NULL,
	`City`	varchar ( 50 ) DEFAULT NULL,
	`StateProvince`	varchar ( 2 ) DEFAULT NULL,
	`PostalCode`	varchar ( 15 ) DEFAULT NULL,
	`Country`	varchar ( 2 ) DEFAULT NULL,
	`Latitude`	decimal ( 8 , 5 ) DEFAULT NULL,
	`Longitude`	decimal ( 8 , 5 ) DEFAULT NULL,
	`AirportCode`	varchar ( 3 ) DEFAULT NULL,
	`PropertyCategory`	integer DEFAULT NULL,
	`PropertyCurrency`	varchar ( 3 ) DEFAULT NULL,
	`StarRating`	decimal ( 2 , 1 ) DEFAULT NULL,
	`Confidence`	integer DEFAULT NULL,
	`SupplierType`	varchar ( 3 ) DEFAULT NULL,
	`Location`	varchar ( 80 ) DEFAULT NULL,
	`ChainCodeID`	integer DEFAULT NULL,
	`RegionID`	integer DEFAULT NULL,
	`HighRate`	decimal ( 19 , 4 ) DEFAULT NULL,
	`LowRate`	decimal ( 19 , 4 ) DEFAULT NULL,
	`CheckInTime`	varchar ( 10 ) DEFAULT NULL,
	`CheckOutTime`	varchar ( 10 ) DEFAULT NULL,
	PRIMARY KEY(`EANHotelID`)
);
CREATE INDEX IF NOT EXISTS `activepropertylist_activeproperties_regionid` ON `activepropertylist` (
	`RegionID`
);
CREATE INDEX IF NOT EXISTS `activepropertylist_activeproperties_geoloc` ON `activepropertylist` (
	`Latitude`,
	`Longitude`
);

CREATE TABLE IF NOT EXISTS `activepropertybusinessmodel` (
	`EANHotelID`	integer NOT NULL,
	`SequenceNumber`	integer DEFAULT NULL,
	`Name`	varchar ( 70 ) DEFAULT NULL,
	`Address1`	varchar ( 50 ) DEFAULT NULL,
	`Address2`	varchar ( 50 ) DEFAULT NULL,
	`City`	varchar ( 50 ) DEFAULT NULL,
	`StateProvince`	varchar ( 2 ) DEFAULT NULL,
	`PostalCode`	varchar ( 15 ) DEFAULT NULL,
	`Country`	varchar ( 2 ) DEFAULT NULL,
	`Latitude`	decimal ( 8 , 5 ) DEFAULT NULL,
	`Longitude`	decimal ( 8 , 5 ) DEFAULT NULL,
	`AirportCode`	varchar ( 3 ) DEFAULT NULL,
	`PropertyCategory`	int ( 11 ) DEFAULT NULL,
	`PropertyCurrency`	varchar ( 3 ) DEFAULT NULL,
	`StarRating`	decimal ( 2 , 1 ) DEFAULT NULL,
	`Confidence`	integer DEFAULT NULL,
	`SupplierType`	varchar ( 3 ) DEFAULT NULL,
	`Location`	varchar ( 80 ) DEFAULT NULL,
	`ChainCodeID`	integer DEFAULT NULL,
	`RegionID`	integer DEFAULT NULL,
	`HighRate`	decimal ( 19 , 4 ) DEFAULT NULL,
	`LowRate`	decimal ( 19 , 4 ) DEFAULT NULL,
	`CheckInTime`	varchar ( 10 ) DEFAULT NULL,
	`CheckOutTime`	varchar ( 10 ) DEFAULT NULL,
	`BusinessModelMask`	integer ( 1 ) DEFAULT NULL,
	PRIMARY KEY(`EANHotelID`)
);
CREATE INDEX IF NOT EXISTS `activepropertybusinessmodel_regionid` ON `activepropertybusinessmodel` (
	`RegionID`
);
CREATE INDEX IF NOT EXISTS `activepropertybusinessmodel_geoloc` ON `activepropertybusinessmodel` (
	`Latitude`,
	`Longitude`
);
COMMIT;
-- EOF: SQLite_create_eanprod.sql
