#!/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
blue_bg=`tput setab 4`
white=`tput setaf 7`
red_bg=`tput setab 1`
bold=`tput bold`

if  ! which gcloud > /dev/null; then
   echo -e "${red_bg} ${white} gcloud not found! Please install gcloud and then run the script \c ${reset}"
   echo ''
   exit
fi

if  ! which jq > /dev/null; then
   echo -e "${red_bg} ${white} jq not found! Please install jq and then run the script \c ${reset}"
   echo ''
   exit
fi

auth=false
token=$(gcloud auth print-access-token)

if [ "$token" != "" ]
then
        auth=true
        auth_act=$(gcloud config list account --format "value(core.account)")
        echo "Authenticated with the account $auth_act"
        echo ''
else
        gcloud auth login
        echo "Authenticated with the account $auth_act"
        echo ''
fi

echo "+------------------------------------------+"
echo "| GCP Lateral Movement Detector            |"
echo "| Author: Liat Vaknin                      |"
echo "| https://github.com/ElLicho007            |"
printf "| %-40s |\n" "`date`"
echo "| Starting....                             |"
echo "+------------------------------------------+"
echo ''
echo ''

echo "${blue_bg} ${white} All available projects: ${reset}"
gcloud projects list
echo ''

echo "${blue_bg} ${white} Select project to check or ALL: ${reset}"
read selected_proj
echo ''

if [ $selected_proj == "ALL" ] || [ $selected_proj == "All" ] || [ $selected_proj == "all" ]
then
        proj=( $(gcloud projects list | tail -n +2 | awk {'print $1'}) )
        for i in "${proj[@]}"
        do
                echo "${blue_bg} ${white} [*] Inspecting now project $i ${reset}"
                gcloud config set project $i

                svc_act=$(gcloud iam service-accounts list --filter "Compute Engine default service account" --format json | jq -r '.[].email')
                if [ "$svc_act" = "" ]; then
                        echo No service account in project $i
                        echo Moving on to the next project...
                        echo ''
                        continue
                fi
                echo The default service account for project $i is: $svc_act

                role_svc_act=$(gcloud projects get-iam-policy $i --flatten="bindings[].members" --format=json --filter="bindings.members:$svc_act" | jq -r '.[].bindings.role')
                if [ "$role_svc_act" = "" ]; then
                        echo No role found for the service account
                        echo ''
                        continue
                fi
                echo The role for the default service account is: $role_svc_act
                echo''

                echo "${blue_bg} ${white} All instances in project $i: ${reset}"
                gcloud compute instances list
                echo ''
        	insta=($(gcloud compute instances list | tail -n +2 | awk {'print $1'}))
                
                echo "${blue_bg} ${white} Select instance to check or ALL: ${reset}"
                read selected_instance
                echo ''

                if [ $selected_instance == "ALL" ] || [ $selected_instance == "All" ] || [ $selected_instance == "all" ]
                then
                        for j in "${insta[@]}"
                        do
                                echo "${blue_bg} ${white} [*] Inspecting now instance $j ${reset}"
                		zone=($(gcloud compute instances list --filter $j --format json | jq -r '.[].zone' | cut -d '/' -f 9))
                		insta_svc_act=($(gcloud compute instances describe $j --zone $zone --format json | jq -r '.serviceAccounts' | grep "email" | cut -d '"' -f 4))
                		#echo $insta_svc_act
                		if [ "$insta_svc_act" == "$svc_act" ]; then
                			echo Instance $j is using the default service account $svc_act
                			scope=($(gcloud compute instances describe $j --zone $zone --format json | jq -r '.serviceAccounts[].scopes[]'))                      
                                        if [[ $scope == *"https://www.googleapis.com/auth/cloud-platform" ]]; then
                                                echo "Instance $j has all cloud APIs access scope"
                                                echo "${red_bg} ${white} ${bold}[*] WARNING: The machine $j can access ALL vms in the project $i!!!${reset}"
                                                echo "${red_bg} ${white} ${bold}[*] WARNING: From the vm $j use the command gcloud compute ssh to access all vms in the project $i!!!${reset}"
                                        else
                                                echo "No sufficient cloud API access scope"
                                                echo "Moving on to the next instance..."
                                        fi				
                                fi
        	       done
                        echo ''
                else
                        echo "${blue_bg} ${white} [*] Inspecting now instance $selected_instance ${reset}"
                        zone=($(gcloud compute instances list --filter $selected_instance --format json | jq -r '.[].zone' | cut -d '/' -f 9))
                        insta_svc_act=($(gcloud compute instances describe $selected_instance --zone $zone --format json | jq -r '.serviceAccounts' | grep "email" | cut -d '"' -f 4))
                        if [ "$insta_svc_act" == "$svc_act" ]; then
                                echo Instance $selected_instance is using the default service account $svc_act
                                scope=($(gcloud compute instances describe $selected_instance --zone $zone --format json | jq -r '.serviceAccounts[].scopes[]'))                      
                                if [[ $scope == *"https://www.googleapis.com/auth/cloud-platform" ]]; then
                                        echo "Instance $j has all cloud APIs access scope"
                                        echo "${red_bg} ${white} ${bold}[*] WARNING: The machine $selected_instance can access ALL vms in the project $i!!!${reset}"
                                        echo "${red_bg} ${white} ${bold}[*] WARNING: From the vm $selected_instance use the command gcloud compute ssh to access all vms in the project $i!!!${reset}"
                                fi
                        fi                              
                fi
                                
                        echo ''
        done
else 
        echo "${blue_bg} ${white} [*] Inspecting now project $selected_proj ${reset}"
        gcloud config set project $selected_proj

        svc_act=$(gcloud iam service-accounts list --filter "Compute Engine default service account" --format json | jq -r '.[].email')
        if [ "$svc_act" = "" ]; then
                echo No service account in project $selected_proj
                echo Moving on to the next project...
                echo ''
                
        else
                echo The default service account for project $selected_proj is: $svc_act
                role_svc_act=$(gcloud projects get-iam-policy $selected_proj --flatten="bindings[].members" --format=json --filter="bindings.members:$svc_act" | jq -r '.[].bindings.role')
                if [ "$role_svc_act" = "" ]; then
                        echo No role found for the service account
                        echo ''
                else
                        echo The role for the default service account is: $role_svc_act
                        echo ''
                        echo "${blue_bg} ${white} All instances in the project: ${reset}"
                        gcloud compute instances list
                        echo ''
                        insta=($(gcloud compute instances list | tail -n +2 | awk {'print $1'}))
        
                        echo "${blue_bg} ${white} Select instance to check or ALL: ${reset}"
                        read selected_instance
                        echo ''
        
                        if [ $selected_instance == "ALL" ] || [ $selected_instance == "All" ] || [ $selected_instance == "all" ]
                        then
                                for j in "${insta[@]}"
                                do
                                        echo "${blue_bg} ${white} [*] Inspecting now instance $j ${reset}"
                                        zone=($(gcloud compute instances list --filter $j --format json | jq -r '.[].zone' | cut -d '/' -f 9))
                                        insta_svc_act=($(gcloud compute instances describe $j --zone $zone --format json | jq -r '.serviceAccounts' | grep "email" | cut -d '"' -f 4))
                        
                                        if [ "$insta_svc_act" == "$svc_act" ]; then
                                                echo Instance $j is using the default service account $svc_act
                                                scope=($(gcloud compute instances describe $j --zone $zone --format json | jq -r '.serviceAccounts[].scopes[]'))                      
                                                if [[ $scope == *"https://www.googleapis.com/auth/cloud-platform" ]]; then
                                                        echo "Instance $j has all cloud APIs access scope"
                                                        echo "${red_bg} ${white} ${bold}[*] WARNING: The machine $j can access ALL vms in the project $selected_proj!!!${reset}"
                                                        echo "${red_bg} ${white} ${bold}[*] WARNING: From the vm $j use the command gcloud compute ssh to access all vms in the project $selected_proj!!!${reset}"
                                                fi                              
                                        fi
                                done
                echo ''
                else
                        echo "${blue_bg} ${white} [*] Inspecting now instance $selected_instance ${reset}"
                        zone=($(gcloud compute instances list --filter $selected_instance --format json | jq -r '.[].zone' | cut -d '/' -f 9))
                        insta_svc_act=($(gcloud compute instances describe $selected_instance --zone $zone --format json | jq -r '.serviceAccounts' | grep "email" | cut -d '"' -f 4))
                        if [ "$insta_svc_act" == "$svc_act" ]; then
                                echo Instance $selected_instance is using the default service account $svc_act
                                scope=($(gcloud compute instances describe $selected_instance --zone $zone --format json | jq -r '.serviceAccounts[].scopes[]'))                      
                                if [[ $scope == *"https://www.googleapis.com/auth/cloud-platform" ]]; then
                                        echo "Instance $j has all cloud APIs access scope"
                                        echo "${red_bg} ${white} ${bold}[*] WARNING: The machine $selected_instance can access ALL vms in the project $selected_proj!!!${reset}"
                                        echo "${red_bg} ${white} ${bold}[*] WARNING: From the vm $selected_instance use the command gcloud compute ssh to access all vms in the project $selected_proj!!!${reset}"
                                fi
                        fi                              
                fi
                                
                        echo ''
                echo ''
                        
                        fi
                fi
fi