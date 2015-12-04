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

function dra_logger {
    npm install grunt
    npm install grunt-cli
    npm install grunt-idra

    echo "Service List: ${DRA_SERVICE_LIST}"
    echo -e ""

    #dra_commands "${DRA_EVENT_TYPE_1}" "${DRA_FILE_1}" "${DRA_SERVER}"
    #dra_commands "${DRA_EVENT_TYPE_2}" "${DRA_FILE_2}" "${DRA_SERVER}"
    #dra_commands "${DRA_EVENT_TYPE_3}" "${DRA_FILE_3}" "${DRA_SERVER}"
    #dra_commands "${DRA_EVENT_TYPE_1}" "${DRA_FILE_1}"
    #dra_commands "${DRA_EVENT_TYPE_2}" "${DRA_FILE_2}"
    #dra_commands "${DRA_EVENT_TYPE_3}" "${DRA_FILE_3}"
	dra_commands "${DRA_SERVICE_LIST}"


    
    #grunt --gruntfile=node_modules/grunt-idra/idra.js -eventType=istanbulCoverage -file=tests/coverage/reports/coverage-summary.json
    #grunt --gruntfile=node_modules/grunt-idra/idra.js -eventType=testComplete -deployAnalyticsServer=https://da-test.oneibmcloud.com    
}

function dra_commands {
    dra_grunt_command=""
	RESULT=1
    
    if [ -n "$1" ] && [ "$1" != " " ]; then
        echo -e "Service List: $1 is defined and not empty"
		dra_grunt_command='grunt --gruntfile=node_modules/grunt-idra/idra.js -statusCheck="'
		dra_grunt_command+=$1
		dra_grunt_command+='"'
		echo -e "\nFinal command to grunt-iDRA to check services:\n"
		echo -e $dra_grunt_command
		
		for var in 1 2 3 4 5
		do
		   echo -e "Attempt #$var"
		   while [ $RESULT -ne 0 ]
			do
			sleep 5
			eval $dra_grunt_command
			RESULT=$?
			echo -e "Result of attempt #$var: $RESULT"
			done
		done
		
		
		#delete_criteria='curl -H "projectKey: ${DRA_PROJECT_KEY}" -H "Content-Type: application/json" -X DELETE http://da.oneibmcloud.com/api/v1/criteria?name=EnvListCheck_curl1'
		#echo -e "Deleting criteria ...\n"
		#eval $delete_criteria
        
		#criteria_variable='{"name": "EnvListCheck_curl1","revision": 2,"project": "key","mode": "decision","rules": [{"name": "Check for list of services in region","conditions": [{"eval": "_isEnvironmentListPassing('
		#criteria_variable+=$1
		#criteria_variable+=')","op": "=","value": true}]}]}'
		#echo -e "\nCriteria Variable: $criteria_variable"
		
		#criteria_to_file='echo $criteria_variable > criteriafile.json'
		#eval $criteria_to_file
		#echo -e "\nCriteria created from service list:\n"
		#cat criteriafile.json
		
		#post_criteria='curl -H "projectKey: ${DRA_PROJECT_KEY}" -H "Content-Type: application/json" -X POST -d @criteriafile.json http://da.oneibmcloud.com/api/v1/criteria'
		#echo -e "\nPosting criteria to API...\n"
		#eval $post_criteria
        
    else
        echo -e "\nService List is not defined or is empty .. proceeding with deployment ..\n"
    fi
}

dra_logger

#custom_cmd
