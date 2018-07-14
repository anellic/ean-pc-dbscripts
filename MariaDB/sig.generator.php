<?php

/**
 * shell script to generate signature automatically and execute EAN refresh data script
 *
 * You can run output string as bash script:
 *
 * (php sig.generator.php xxx_cid yyy_apikey zzz_secretkey) | /bin/bash
 *
 * @author Zamrony P. Juhara <zamronypj@yahoo.com>
 */

//EAN CID, API Key and Secret key
$cid = $argv[1];
$apiKey = $argv[2];
$secret = $argv[3];
$timestamp = gmdate('U');
$sig = md5($apiKey . $secret . $timestamp);
//get current working dir
$cwd = getcwd();
$script = "CID=$cid SIGNATURE=$sig APIKEY=$apiKey $cwd/EAN_File_API_MariaDB_refresh.sh";
echo $script;
