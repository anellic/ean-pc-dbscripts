#!/bin/bash
##########################################################################
## EAN_SQLite_refresh.sh  - Shell script to upload EAN data into sqlite ##
## it requires the csv2sqlite.py companion script and a                 ##
## python2 interpreter (installed and configured as default).           ##
## Data will be place in the /sqlite_data/ directory, inside the        ##
## eanprod.db SQLite 3 database  										##
##                                                                      ##
##########################################################################
# Modified for MAC
### Environment ###
STARTTIME=$(date +%s)
## for Linux: CHKSUM_CMD=mdsum
## for MAC CHKSUM_CMD=shasum
## for Cygwin under Windows use CHKSUM_CMD=md5deep
## cksum should be available in all Unix versions
## leave empty for faster processing
CHKSUM_CMD=md5deep
## for Linux: MYSQL_DIR=/usr/bin/
MYSQL_DIR=/usr/local/mysql/bin/
# for simplicity I added the MYSQL bin path to the Windows 
# path environment variable, for Windows set it to ""
#MYSQL_DIR=""
##MySQL user, password, host (Server)
#using a number will force it to use TCP/IP if no a pipe connection
#MYSQL_HOST=localhost
#MYSQL_USER=eanuser
#MYSQL_PASS=Passw@rd1
# after MySQL 5.6+ we depend on the mysql_config_editor to
# save the connections credentials (host, user, password)
# then we can use: --login-path={name of your connection}
MYSQL_LOGINPATH=local
MYSQL_DB=eanprod
MYSQL_PORT=3306
MYSQL_PROTOCOL=TCP
# home directory of the user (in our case "/home/eanuser")
HOME_DIR=/Users/jon
## directory under HOME_DIR
FILES_DIR=eanfiles
## Amount of days to keep in the log
## that track changes to ActivePropertyList
LOG_DAYS=100
### Import files ###
#####################################
# the list should match the tables ##
# created by create_ean.sql script ##
#####################################
LANG=es_ES
FILES=(
ChainList
AttributeList
CountryList
AirportCoordinatesList
AreaAttractionsList
CityCoordinatesList
DiningDescriptionList
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
ActivePropertyList
HotelImageList
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
cd ${HOME_DIR}

echo "Starting at working directory..."
pwd
## create subdirectory if required
if [ ! -d ${FILES_DIR} ]; then
   echo "creating download files directory..."
   mkdir ${FILES_DIR}
fi

## all clear, move into the working directory
cd ${FILES_DIR}

### Download Data ###
echo "Downloading files using cURL..."
for FILE in ${FILES[@]}
do
    ## capture the current file checksum
	if [ -e ${FILE}.txt ] && [ -n "${CHKSUM_CMD}" ] ; then
		echo "File exist $FILE.txt and using chksum command $CHKSUM_CMD... saving checksum for comparison..."
    	CHKSUM_PREV=`$CHKSUM_CMD $FILE.txt | cut -f1 -d' '`
    else
    	CHKSUM_PREV=0
	fi
    ## download the files via HTTP (no need for https), using time-stamping, -nd no host directories
    if [[ "$FILE" =~ ^(TrainMetroStationCoordinatesList|RegionEANHotelIDMapping|RegionCenterCoordinatesList|ParentRegionList|NeighborhoodCoordinatesList|CityCoordinatesList|CountryList|AirportCoordinatesList)$ ]]; then 
    	echo "Working on /new/$FILE.txt ..."
        curl -O http://www.ian.com/affiliatecenter/include/V2/new/$FILE.zip
    else    
    	echo "Working on $FILE.txt ..."
        ##wget  -t 30 --no-verbose -r -N -nd http://www.ian.com/affiliatecenter/include/V2/$FILE.zip
        curl -O http://www.ian.com/affiliatecenter/include/V2/$FILE.zip
    fi
	## unzip the files, save the exit value to check for errors
	## BSD does not support same syntax, but there is no need in MAC OS as Linux (unzip -L `find -iname $FILE.zip`)
    unzip -L -o $FILE.zip
	ZIPOUT=$?
    ## rename files to CamelCase format
    mv `echo $FILE | tr \[A-Z\] \[a-z\]`.txt $FILE.txt
    ## special fix for DiningDescriptionLIst naming error
    if [ $FILE = "DiningDescriptionList" ] && [ -f "DiningDescriptionLIst.txt" ]; then
       mv -f DiningDescriptionLIst.txt diningdescriptionlist.txt
    fi
   	## some integrity tests to avoid processing 'bad' files
   	if [ -n "${CHKSUM_CMD}" ] ; then
   	   CHKSUM_NOW=`$CHKSUM_CMD $FILE.txt | cut -f1 -d' '`
   	else
   	   CHKSUM_NOW=1
   	fi
   	echo "calculating records ...."
    records=`wc -l < $FILE.txt | tr -d ' '`
    (( records-- ))
    echo "records found ($records)."
    ## check if we need to update or not based on file changed, file contains at least 1x record
    ## file is readeable, file NOT empty, file unzipped w/o errors
    if [ "$ZIPOUT" -eq 0 ] && [ "$CHKSUM_PREV" != "$CHKSUM_NOW" ] && [ "$records" -gt 0 ] && [ -s ${FILE}.txt ] && [ -r ${FILE}.txt ]; then
    	echo "Updating as integrity is ok & checksum change ($CHKSUM_PREV) to ($CHKSUM_NOW) on file ($FILE.txt)..."
		## table name are lowercase
   		tablename=`echo $FILE | tr "[[:upper:]]" "[[:lower:]]"`
		### Erase SQLite Data ###
   		echo "Erasing previous data from ($MYSQL_DB.$tablename)..."
		sqlite3 ../sqlite_data/$MYSQL_DB.db "DELETE FROM $tablename;"
		### Update SQLite Data ###
   		echo "Uploading ($FILE.txt) to ($MYSQL_DB.$tablename)..."
		## use python upload version
        time python ../csv2sqlite.py $FILE.txt ../sqlite_data/$MYSQL_DB.db $tablename \|
    fi
done
echo "Updates done."

### VACUUM the data (compact unused space)
echo "VACUUM sqlite database ($MYSQL_DB.db)..."
sqlite3 ../sqlite_data/$MYSQL_DB.db "VACUUM;"
###

### Database size summary
###
python ../DatabaseSizeSummary.py ../sqlite_data/$MYSQL_DB.db
###

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


echo "script (EAN_SQLite_refresh_MAC.sh) done."
## display endtime for the script
ENDTIME=$(date +%s)
secs=$(( $ENDTIME - $STARTTIME ))
h=$(( secs / 3600 ))
m=$(( ( secs / 60 ) % 60 ))
s=$(( secs % 60 ))
printf "total script time: %02d:%02d:%02d\n" $h $m $s
