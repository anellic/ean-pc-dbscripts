#!/bin/bash
#########################################################################
## other than the default of the MariaDB Command Lines installation    ##
## you will need to install:                                           ##
## -> cURL                                                             ##
## -> unzip                                                            ##
## -> database client for MariaDB (MySQL client works)                 ##
## you can select by searching for them in the Cygwin packages during  ##
## the install.                                                        ##
##                                                                     ##
## This is modified version of EAN_MariaDB_refresh.sh.                 ##
## which instead of extract content of zip into uncompressed format    ##
## it used named pipe to uncompressed content of zip and load data     ##
## to  MariaDB/MySQL from that named pipe, all MD5 hash comparison done##
## against zip file instead of uncompressed text data.                 ##
## This is provided so we can avoid extracting and storing hugh        ##
## uncompressed text file to save disk storage                         ##
##                                                                     ##
## Usage                                                               ##
## ./EAN_MariaDB_refresh_zip.sh [db user name] [db pasw] [db name] \   ##
##  [working dir] [zip data dir]                                       ##
#########################################################################

### Environment ###
STARTTIME=$(date +%s)
## for Linux: CHKSUM_CMD=md5sum
## cksum should be available in all Unix versions
## leave empty for faster processing
##CHKSUM_CMD=shasum
CHKSUM_CMD=md5sum
## for Linux: MYSQL_DIR=/usr/bin/
MYSQL_DIR=/usr/bin/
# for simplicity I added the MYSQL bin path to the Windows
# path environment variable, for Windows set it to ""
#MYSQL_DIR=""
##MySQL user, password, host (Server)
#using a number will force it to use TCP/IP if no a pipe connection
MYSQL_HOST=localhost
MYSQL_USER=$1
MYSQL_PASS=$2
MYSQL_DB=$3
MYSQL_PORT=3306
MYSQL_PROTOCOL=TCP
# home directory of the user (in our case "/home/eanuser")
WORKING_DIR=$4

## Amount of days to keep in the log
## that track changes to ActivePropertyList
LOG_DAYS=365

### Import files ###
#####################################
# the list should match the tables ##
# created by create_ean.sql script ##
#####################################
LANG=en_US
FILES=(
ActivePropertyList
AirportCoordinatesList
AreaAttractionsList
AttributeList
ChainList
CityCoordinatesList
CountryList
DiningDescriptionList
HotelImageList
NeighborhoodCoordinatesList
ParentRegionList
PointsOfInterestCoordinatesList
PolicyDescriptionList
PropertyAttributeLink
PropertyDescriptionList
PropertyTypeList
RecreationDescriptionList
RegionCenterCoordinatesList
RegionEANHotelIDMapping
RoomTypeList
SpaDescriptionList
TrainMetroStationCoordinatesList
WhatToExpectList
#
# minorRev=25 added files
#
PropertyLocationList
PropertyAmenitiesList
PropertyRoomsList
PropertyBusinessAmenitiesList
PropertyNationalRatingsList
PropertyFeesList
PropertyMandatoryFeesList
PropertyRenovationsList
#
### Special File for Authorized Partners ONLY
ActivePropertyBusinessModel
## <BusinessModelMask> 	<Availability Offered>
## 1 	Expedia Collect only
## 2 	Hotel Collect only
## 3 	Both (ETP)
)

## home where the process will execute
#cd C:/data/EAN/DEV/database
## this will be CRONed so it needs the working directory absolute path
## change to your user home directory

## make directory and its subdirectory as needed
mkdir -p ${WORKING_DIR}
cd ${WORKING_DIR}

echo "Starting at working directory ..."
pwd

### Parameters that you may need:
### If you use LOW_PRIORITY, execution of the LOAD DATA statement is delayed until no other clients are reading from the table.
CMD_MYSQL="${MYSQL_DIR}mysql -u ${MYSQL_USER} -p${MYSQL_PASS} --local-infile=1 --default-character-set=utf8 --database=${MYSQL_DB}"

## create named pipe
echo "Create temporary named pipe ..."
mkfifo --mode=0644 tmpUncompressedPipe

### Download Data ###
echo "Downloading files using cURL..."
for FILE in ${FILES[@]}
do
    ## capture the current file checksum
	if [ -e ${FILE}.zip ] && [ -n "${CHKSUM_CMD}" ] ; then
		echo "File exist $FILE.zip and using chksum command $CHKSUM_CMD... saving checksum for comparison..."
    	CHKSUM_PREV=`$CHKSUM_CMD $FILE.zip | cut -f1 -d' '`
    else
    	CHKSUM_PREV=0
	fi
    ## download the files via HTTP (no need for https)
    if [[ "$FILE" =~ ^(TrainMetroStationCoordinatesList|RegionEANHotelIDMapping|RegionCenterCoordinatesList|ParentRegionList|NeighborhoodCoordinatesList|CityCoordinatesList|CountryList|AirportCoordinatesList)$ ]]; then
    	echo "Working on /new/$FILE.zip ..."
        curl -O http://www.ian.com/affiliatecenter/include/V2/new/$FILE.zip
    else
    	echo "Working on $FILE.zip ..."
        ##wget  -t 30 --no-verbose -r -N -nd http://www.ian.com/affiliatecenter/include/V2/$FILE.zip
        curl -O http://www.ian.com/affiliatecenter/include/V2/$FILE.zip
    fi

    ## some integrity tests to avoid processing 'bad' files
    if [ -n "${CHKSUM_CMD}" ] ; then
        CHKSUM_NOW=`$CHKSUM_CMD $FILE.zip | cut -f1 -d' '`
    else
        CHKSUM_NOW=1
    fi

    if [ "$CHKSUM_PREV" = "$CHKSUM_NOW" ]; then
        ## if equal, nothing has changed, skip
        continue
    fi

 	## unzip the files to standard output and write it to named pipe file,
 	## save the exit value to check for errors
	## BSD does not support same syntax, but there is no need in MAC OS as Linux (unzip -L `find -iname $FILE.zip`)
	unzip -p -L -o $FILE.zip > tmpUncompressedPipe
    ZIPOUT=$?

   	echo "calculating records ...."
    records=`wc -l < tmpUncompressedPipe | tr -d ' '`
    (( records-- ))
    echo "records found ($records)."

    ## check if we need to update or not based on file changed, file contains at least 1x record
    ## file is readeable, file NOT empty, file unzipped w/o errors
    if [ "$ZIPOUT" -eq 0 ] && [ "$records" -gt 0 ]; then
    	echo "Updating as integrity is ok & checksum change from ($CHKSUM_PREV) to ($CHKSUM_NOW) on file ($FILE.zip)..."
		## table name are lowercase
   		tablename=`echo $FILE | tr "[[:upper:]]" "[[:lower:]]"`
        ## checking if working with activepropertylist to make a backup of it before changes
        if [ $tablename = "activepropertybusinessmodel" ]; then
			echo "Running a backup of ActivePropertyBusinessModel..."
			### Run stored procedures as required for extra functionality       ###
			### you can use this section for your own stuff                     ###
			CMDSP_MYSQL="${MYSQL_DIR}mysql -u ${MYSQL_USER} -p${MYSQL_PASS} --default-character-set=utf8 --database=${MYSQL_DB}"
			$CMDSP_MYSQL --execute="CALL eanprod.sp_log_createcopy();"
			echo "ActivePropertyBusinessModel backup done."
        fi
		### Update MySQL Data ###
   		echo "Uploading ($FILE.zip) to ($MYSQL_DB.$tablename) with REPLACE option..."
		## let's try with the REPLACE OPTION
   		time $CMD_MYSQL --execute="set foreign_key_checks=0; set sql_log_bin=0; set unique_checks=0; SET sql_mode = ''; LOAD DATA LOCAL INFILE 'tmpUncompressedPipe' REPLACE INTO TABLE $tablename CHARACTER SET utf8 FIELDS TERMINATED BY '|' IGNORE 1 LINES;"
   		## we need to erase the records, NOT updated today
   		echo "erasing old records from ($tablename)..."
   		time $CMD_MYSQL --execute="DELETE FROM $tablename WHERE datediff(TimeStamp, now()) < 0;"
        ## optimize table to reduce storage consumption
        time $CMD_MYSQL --execute="OPTIMIZE TABLE $tablename;"
        ## checking if working with activepropertylist to fill the changed log table
        if [ $tablename = "activepropertybusinessmodel" ]; then
			echo "Creating log of changes for ActivePropertyBusinessModel..."
			### Run stored procedures as required for extra functionality       ###
			### you can use this section for your own stuff                     ###
			CMDSP_MYSQL="${MYSQL_DIR}mysql  -u ${MYSQL_USER} -p${MYSQL_PASS} --default-character-set=utf8 --database=eanprod"
			$CMDSP_MYSQL --execute="CALL eanprod.sp_log_addedrecords();"
			$CMDSP_MYSQL --execute="CALL eanprod.sp_log_erasedrecords();"
			$CMDSP_MYSQL --execute="CALL eanprod.sp_log_erase_common();"
			$CMDSP_MYSQL --execute="CALL eanprod.sp_log_erase_deleted();"
			$CMDSP_MYSQL --execute="CALL eanprod.sp_log_changedrecords();"
			### erase records before retention period
			$CMDSP_MYSQL --execute="DELETE FROM log_activeproperty_changes WHERE TimeStamp < DATE_SUB(NOW(), INTERVAL $LOG_DAYS DAY);"
			echo "Log for ActivePropertyBusinessModel done."
        fi
    fi
done

echo "Updates done."

## echo "Running Stored Procedures..."
### Run stored procedures as required for extra functionality       ###
### you can use this section for your own stuff                     ###

## CMD_MYSQL="${MYSQL_DIR}mysql --default-character-set=utf8 --database=eanextras"
## $CMD_MYSQL --execute="CALL eanextras.sp_fill_fasttextsearch();"
## added as a fixer alternative to Identify Chain Hotels by name
## $CMD_MYSQL --execute="CALL eanextras.sp_fill_chainlistlink();"
## echo "Stored Procedures done."


######
## process special files
######

### Update MySQL Data ###
### Parameters that you may need:
### If you use LOW_PRIORITY, execution of the LOAD DATA statement is delayed until no other clients are reading from the table.
CMD_MYSQL="${MYSQL_DIR}mysql -u ${MYSQL_USER} -p${MYSQL_PASS} --local-infile=1 --default-character-set=utf8 --database=${MYSQL_DB}"
echo "Uploading Data to MariaDB..."
echo "Verify database against files..."
### Verify entries in tables against files ###
CMD_MYSQL="${MYSQL_DIR}mysqlshow -u ${MYSQL_USER} -p${MYSQL_PASS} --count ${MYSQL_DB}"
$CMD_MYSQL

### find the amount of records per datafile
### should match to the amount of database records
echo "+---------------------------------+----------+------------+"
echo "|             File                |       Records         |"
echo "+---------------------------------+----------+------------+"
for FILE in ${FILES[@]}
do
## Linux: records=`head --lines=-1 $FILE.txt | wc -l`
   records=`wc -l < $FILE.txt | tr -d ' '`
   (( records-- ))
   { printf "|" && printf "%33s" $FILE && printf "|" && printf "%23d" $records && printf "|\n"; }
done
echo "+---------------------------------+----------+------------+"
echo "Verify done."

## remove temporary name pipe file
echo "Remove temporary named pipe ..."
rm tmpUncompressedPipe

echo "script (import_db.sh) done."
## display endtime for the script
ENDTIME=$(date +%s)
secs=$(( $ENDTIME - $STARTTIME ))
h=$(( secs / 3600 ))
m=$(( ( secs / 60 ) % 60 ))
s=$(( secs % 60 ))
printf "total script time: %02d:%02d:%02d\n" $h $m $s
