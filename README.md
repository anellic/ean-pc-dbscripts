ean-pc-dbscripts
================

Partner Connect database scripts for Partners to create relational database based on V3 downloadable files.
-----------------------------------------------------------------------------------------------------------

NOTE*: The script has been update to work with SQLite 3.11.0 or MariaDB 10.1.22. SQLite is ONLY recommended to learn about the database, and/or portable devices (tablets & phones). We now consider MariaDB to be our default host database.
Latest version included NEW Coordinates list file of Train and Metro Stations.
If you are using MySQL, all MariaDB scripts should work; but these are sample scripts to speed up your deployment, Expedia nor EAN directly support any database products and/or tools.

HOW-TO USE:
1. Select either MariaDB / SQLite
2. Create the "eanprod" database structure using your selected database management tool.
1. MariaDB_create_eanprod.sql - This create all of "eanprod" database structure from scratch, indexes and stored procedures as well.
2. MySQL_extend_eanprod_xx_XX.sql - This will add tables to support extra languages, it will need to be edited to the proper LOCALE information (like es_es for Spanish/Spain). You may run it multiple times to generate structures for multiple languages.
3. EAN_MariaDB_refresh.sh - The script that updates the database, the top lines will need to be adjusted for database name, dbserver, user name, password, etc. Run this to populate and refresh the database.

 MySQL Version 5.6+ changed the security model, you need to FIRST use:
 mysql_config_editor set --login-path=local --host=localhost --user=localuser –password
 then uncomment the lines with the remarks that will use --login-path parameter instead of --user, --password and --host .

/Queries - Contain multiple queries that show how to relate the data in the database.

/SQLite - Script and database creation script.The refresh scripts uses some Python helper code, so you will need to supply Python 2.10+ for it to work. As Python goes it needs to be a 2.x release as 3.X are different. The final file could be quite big with allmost 7 GB in size so be careful and only specify what u need. 

/MariaDB - MariaDB versions of the scripts including my Server my.cnf configuration file, as some changes will be needed to support proper UTF-8 sorting.

/doc - Documentation that I am currently working on to better explain how to use the database files.
-> How-to EAN Database files - How to create the database files (not finished yet).
-> EAN Database Working with Geography - Documentation showing how to relate tables to solve geography, using the stored procedures to support even better (more accurate) searches. 
-> Using external data to add geography information. It includes the geonames table usage to solve questions like: nearby Train Stations.


** Use of these scripts are at your own risk. The scripts are provided “as is” without any warranty of any kind and Expedia disclaims any and all liability regarding any use of the scripts. **

Please contact us with any questions / concern / suggestions.

Partner:Connect Team
apihelp@expedia.com
