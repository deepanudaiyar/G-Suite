#!/bin/bash

#Setting log location and how it captures error
accountName=$(whoami)
GAMfiles=/Users/$accountName/Documents/GAMfiles
logDir=/Users/$accountName/Documents/GAMfiles/logs

#Setting up directory structure
    if [ ! -d "$GAMfiles" ]
    then
        echo "Setting up GAMfiles directory.."
        mkdir $GAMfiles
        echo
    else
        echo 
    fi

    if [ ! -d "$logDir" ]
    then
        echo "Setting up Logs directory"
        mkdir $logDir
        echo
    else
        echo
    fi

NOW=$( date '+%F_%H:%M:%S' )
logloc="/Users/$accountName/Documents/GAMfiles/logs/$NOW.log"
(
    #Sets path of GAM, please make sure to change this path to reflect your GAM path. Use 'gam version' to find your path.
    GAM=/Users/$accountName/bin/gamadv-xtd3/gam

    # these two variables are used for error handling purposes
    invalidUsernameString="Does not exist"
    validUsernameString="User"

    echo
    echo "Enter full email address of a user that you are terminating."

    while [ "$verifyUsername" != *"$invalidUsernameString"* ]; 
    do
        #prompting for input and saving it into a variable.
        read -p "Email address: " username
        echo
        echo "Validating email address..."
        echo
        #Verifies username by using the command below and saves the output into a variable , which is then compared to a string to handle error
        verifyUsername=`$GAM whatis $username noinfo 2>&1`

        if [[ "$verifyUsername" != *"$validUsernameString"* ]]
        then
            echo "Invalid email address, try again."
        fi
        
        if [[ "$verifyUsername" == *"$validUsernameString"* ]]
        then
                #Wiping user's calendar
                read -p "Would you like to Wipe user's calendar ? (Y/N) " ans;

                case $ans in 
                    y|Y)
                        echo
                        echo Clearing up calendar events of $username 
                        $GAM calendar $username wipe 
                        echo 
                        ;;
                    n|N)
                        echo
                        echo "Alrighty then, it's been skipped."
                        echo 
                        ;;
                esac

                #Transferring calendar data and releasing resources
                read -p "Would you rather transfer calendar data to users manager? (Y/N) " ans;
                case $ans in 
                    y|Y)
                        while [ "$verifyManager" != *"$invalidUsernameString"* ]; 
                        do
                            echo
                            read -p "Enter Full email address of the manager: " manager
                            echo
                            echo "Validating email address..."
                            verifyManager=`$GAM whatis $manager noinfo 2>&1`

                            if [[ "$verifyManager" != *"$validUsernameString"* ]]
                            then
                                echo "Invalid email address, try again."
                            fi

                            if [[ "$verifyManager" == *"$validUsernameString"* ]]
                            then
                                echo 
                                echo "Initiating transfer of calendar data from $username to $manager"
                                $GAM create datatransfer $username calendar $manager release_resources 
                                break
                            fi    
                        done
                        ;;
                    n|N)
                        echo
                        echo "Alrighty then, it's been skipped."
                        echo 
                        ;;
                esac

                #setting the terminated user to suspended state
                echo 
                echo Suspending user $username
                $GAM update user $username suspended on 
                echo $username is suspended

                #removing the user from all of their groups
                echo
                echo removing $username from all the groups they belong to
                $GAM user $username delete groups 

                #Moving user to the terminated OU 
                echo
                echo Moving $username to Terminated Users OU 
                $GAM update org terminated\ users move user $username 
                
                # deprovisioning all of their SSO tokens
                echo 
                echo "Deprovisioning $username SSO Tokens" 
                $GAM user $username deprovision
                echo 

                #removing gmail account related data from user's mobile devices. 
                echo "Gathering mobile devices for $username"
                IFS=$'\n'
                mobile_devices=($($GAM print mobile query $username | grep -v resourceId | awk -F"," '{print $1}'))
                unset IFS
                    for mobileid in ${mobile_devices[@]}
                        do
                            $GAM update mobile $mobileid action account_wipe && echo "Removing $mobileid from $username" 
                    done
                
                #Transferring docs to the manager
                read -p "Would you like to transfer G-drive data to users manager? (Y/N) " ans;

                case $ans in 
                    y|Y)
                        while [ "$verifyManager" != *"$invalidUsernameString"* ]; 
                        do
                            echo
                            read -p "Enter Full email address of the manager: " manager
                            echo
                            echo "Validating email address..."
                            verifyManager=`$GAM whatis $manager noinfo 2>&1`

                            if [[ "$verifyManager" != *"$validUsernameString"* ]]
                            then
                                echo "Invalid email address, try again."
                            fi

                            if [[ "$verifyManager" == *"$validUsernameString"* ]]
                            then
                                echo 
                                echo "Initiating Drive transfer from $username to $manager"
                                $GAM create transfer $username drive $manager private 
                                break
                            fi    
                        done
                        ;;
                    n|N)
                        echo
                        echo "Alrighty then, it's been skipped." 
                        ;;
                esac

                # Collecting admin email address for logs and uploading to IT Team drive
                echo
                echo "To upload the log to I.T team drive, Enter your admin email address ?"
                while [ "$verifyAdmin" != *"$invalidUsernameString"* ]; 
                do
                    read -p "Admin Email address: " adminname
                    echo
                    echo "Validating email address..."
                    verifyAdmin=`$GAM whatis $adminname noinfo 2>&1`
                    if [[ "$verifyAdmin" != *"$validUsernameString"* ]]
                    then
                        echo "Invalid Email address, try again."
                    fi
                    
                    if [[ "$verifyAdmin" == *"$validUsernameString"* ]]
                    then
                        echo
                        echo "Initiating Upload of log"
                        echo
                        echo "$username is deprovisioned from G-Suite on $NOW by $adminname"
                        echo
                        #Make sure to change the drive folder id to match your preferred folder
                        $GAM user $adminname add drivefile localfile $logloc teamdriveparentid 1n8580FUK8-x1N_UUxj5DvTnmNexlQWm 
                        echo
                        echo "Locally, you can find the log at: "
                        echo $logloc
                        echo 
                        break
                    fi
                done
            break
        fi
    done

) 2>&1 |tee -a $logloc


