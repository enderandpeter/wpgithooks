<?php
$addOnList = require '.setup/wp-addons.php';

$addOnType = $argv[1];
$addOnAction = isset($argv[2]) ? $argv[2] : '';

$requestedList = [];
/*
For each defined action on each theme and plugin, return the command parameters to
install the files. The DB will have the settings for which ones are activated
'addon' : Install latest version of addon
['addon', '1.0'] : Install version 1.0 of addon
*/

$requestedList = $addOnAction ? $addOnList[$addOnType][$addOnAction] : $addOnList[$addOnType];
if(!empty($requestedList)){
    
    foreach($requestedList as $key => $item){
        if(is_array($item)){            
            if(!empty($item[1])){
                $requestedList[$key] = "${item[0]} --version=${item[1]}";
            }
        }
    }
}

echo implode("\n", $requestedList);