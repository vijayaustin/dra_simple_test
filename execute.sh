#!/bin/bash

#********************************************************************************
# Copyright 2014 IBM
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#********************************************************************************

#############
# Colors    #
#############
export green='\e[0;32m'
export red='\e[0;31m'
export label_color='\e[0;33m'
export no_color='\e[0m' # No Color

##################################################
# Simple function to only run command if DEBUG=1 # 
### ###############################################
debugme() {
  [[ $DEBUG = 1 ]] && "$@" || :
}

set +e
set +x 

#if [ -z "${SAUCE_USERNAME}" ]; then
#    echo -e "${red}No SAUCE_USERNAME defined, please enter your username in the stage configuration.${no_color}"
#    exit 1     
#fi 
#
#if [ -z "${SAUCE_ACCESS_KEY}" ]; then 
#    echo -e "${red}No SAUCE_ACCESS_KEY defined, please either select for the service to be added, or define SAUCE_ACCESS_KEY in the stage configuration${no_color}"
#    exit 1     
#fi 

#debugme echo "SAUCE_ACCESS_KEY: ${SAUCE_ACCESS_KEY}"
#debugme echo "USER_ID: ${SAUCE_USERNAME}"

cmd_choice=$CMD_CHOICE

function execute { 
    eval $cmd_choice
    RESULT=$?
#    ${EXT_DIR}/sauce.py
#    PY_RES=$?
    
#    if [ "${DOWNLOAD_ASSETS}" == true ]; then
#        echo "zipping files"
#        zip -q selenium_logs.zip selenium-server-*
#        zip -q videos.zip video-*
#        mv selenium_logs.zip ${ARCHIVE_DIR}
#        mv videos.zip ${ARCHIVE_DIR}
#    fi
    
    if [ "${DRA}" == true ]; then
        #insert DRA commands here
        npm install grunt
        npm install grunt-cli
        npm install grunt-idra
        grunt --gruntfile=node_modules/grunt-idra/idra.js -eventType=SaucelabFvtTest -file=job_data_collection.json -deployAnalyticsServer="$DA_SERVER"
    fi
    
#    mv job_data_collection.json ${ARCHIVE_DIR}
    
#    if [ $RESULT -ne 0 ] || [ $PY_RES -ne 0 ]; then
#        exit 1
#    fi
    if [ $RESULT -ne 0 ]; then
        exit 1
    fi
}

if [[ $cmd_choice == "npm test" ]] || [[ $cmd_choice == "grunt test" ]] || [[ $cmd_choice == "grunt" ]]; then
    npm install
    execute
fi
if [[ $cmd_choice == "ant test" ]] || [[ $cmd_choice == "mvn test" ]]; then
    execute
fi
if [[ $cmd_choice == "custom" ]]; then
    custom_cmd
fi
if [[ $cmd_choice == " " ]] || [[ -z "$cmd_choice" ]]; then
    ${EXT_DIR}/auto-detect.py
    AUTO_RESULT=$?
    if [ $AUTO_RESULT -ne 0 ]; then
        echo "Running grunt test..."
        cmd_choice="grunt test"
        npm install
        execute
    else
        echo "Running npm test..."
        cmd_choice="npm test"
        npm install
        execute
    fi
fi

function dra_logger {
#    npm install grunt
#    npm install grunt-cli
#    npm install grunt-idra
    
    echo "event: ${DRA_EVENT_TYPE_1}"
    echo -e "└── file: ${DRA_FILE_1}"
    echo -e "└── server: ${DRA_SERVER_1}"
    echo "event 2: ${DRA_EVENT_TYPE_2}"
    echo -e "└──file: ${DRA_FILE_2}"
    echo -e "└──server: ${DRA_SERVER_2}"
    echo "event 3: ${DRA_EVENT_TYPE_3}"
    echo -e "└──file: ${DRA_FILE_3}"
    echo -e "└──server: ${DRA_SERVER_3}"
    echo -e ""

    dra_commands "${DRA_EVENT_TYPE_1}" "${DRA_FILE_1}" "${DRA_SERVER_1}"
    dra_commands "${DRA_EVENT_TYPE_2}" "${DRA_FILE_2}" "${DRA_SERVER_2}"
    dra_commands "${DRA_EVENT_TYPE_3}" "${DRA_FILE_3}" "${DRA_SERVER_3}"


    
#grunt --gruntfile=node_modules/grunt-idra/idra.js -eventType=istanbulCoverage -file=tests/coverage/reports/coverage-summary.json
#grunt --gruntfile=node_modules/grunt-idra/idra.js -eventType=testComplete -deployAnalyticsServer=https://da-test.oneibmcloud.com    
}

function dra_commands {
    dra_grunt_command=""
    
    if [ -n "$1" ] && [ "$1" != " " ]; then
        echo "Event: '$1' is defined and not empty"
        
        dra_grunt_command="grunt --gruntfile=node_modules/grunt-idra/idra.js -eventType=$1"
        
        echo -e "\tdra_grunt_command: $dra_grunt_command"
        
        if [ -n "$2" ] && [ "$2" != " " ]; then
            echo -e "\tFile: '$2' is defined and not empty"
            
            dra_grunt_command="$dra_grunt_command -file=$2"
        
            echo -e "\t\tdra_grunt_command: $dra_grunt_command"
            
        else
            echo -e "\tFile: '$2' is not defined or is empty"
        fi
        if [ -n "$3" ] && [ "$3" != " " ]; then
            echo -e "\tServer: '$3' is defined and not empty"
            
            dra_grunt_command="$dra_grunt_command -file=$3"
        
            echo -e "\t\tdra_grunt_command: $dra_grunt_command"
            
        else
            echo -e "\tServer: '$3' is not defined or is empty"
        fi
        
        echo -e "\tFINAL dra_grunt_command: $dra_grunt_command"
    else
        echo "Event: '$1' is not defined or is empty"
    fi
    
    echo ""
}

dra_logger








