<?php
$addOnList = require 'wp-addons.php';

$addOnType = $argv[1];
$addOnAction = isset($argv[2]) ? $argv[2] : '';

$requestedList = [];
/*
For each defined action on each theme and plugin, return the command parameters to
activate it if the addon was simply named, or interpret the toggle and version instructions.
'addon' || ['addon', 'activate'] : Activate and install latest
['addon', null, '1.0'] : Install version 1.0 of addon, but do not activate
['addon', false] : Install latest version of addon, but do not activate
*/

$requestedList = $addOnAction ? $addOnList[$addOnType][$addOnAction] : $addOnList[$addOnType];
if(!empty($requestedList)){
    
    foreach($requestedList as $key => $item){
        if(is_array($item)){
            if(!empty($item[0])){
                $requestedList[$key] = $item[0];
            }
            
            if(!empty($item[1]) && $addOnAction !== 'delete' && $addOnAction !== 'uninstall'){
                $requestedList[$key] .= " --activate";
            }
            
            if(!empty($item[2])){
                $requestedList[$key] .= " --version=${item[2]}";
            }
        } else if($addOnAction === 'install'){
            $requestedList[$key] .= " --activate";
        }
    }
}

echo implode("\n", $requestedList);