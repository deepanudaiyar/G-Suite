#!/bin/bash

accountName=$(whoami)
newUserCsv=/Users/$accountName/Documents/GAMfiles/newUser.csv
groupCsv=/Users/$accountName/Documents/GAMfiles/groupsToAdd.csv
#Make sure to change the path of your signature file below
sigFile=/Users/$accountName/Documents/G-Suite/signature.html
pandaMagic=/Users/$accountName/Documents/G-Suite/newhire.py
addingGroups=/Users/$accountName/Documents/G-Suite/groups.py
takeOut=/Users/$accountName/Documents/G-Suite/bye.py
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

#Setting up log location
    NOW=$( date '+%F_%H:%M:%S' )
    logLoc="/Users/$accountName/Documents/GAMfiles/logs/$NOW.log"
    (
        #Sets path of GAM
            GAM=/Users/$accountName/bin/gamadv-xtd3/gam

        # these two variables are used for error handling purposes
            invalidUsernameString="Does not exist"
            validUsernameString="User"

        #Verifies admin email address & downloads the new hire tracker sheet from google drive
            echo "To download the latest New Hire Tracker file, Enter your admin email address."
            while [ "$verifyAdmin" != *"$invalidUsernameString"* ]; 
            do
                read -p "Admin Email address: " adminName
                echo
                echo "Validating email address..."
                verifyAdmin=`$GAM whatis $adminName noinfo 2>&1`
                if [[ "$verifyAdmin" != *"$validUsernameString"* ]]
                then
                    echo "Invalid Email address, try again."
                fi
                
                if [[ "$verifyAdmin" == *"$validUsernameString"* ]]
                then
                    echo
                    echo "Downloading File.."
                    echo
                    # Please make sure to change the id below to match your excel or google sheet file 
                    $GAM user $adminName get drivefile id 1FqRV9VDsRJAfYrzl-u3xBHEHjtw9UA_Kh-_aFB5PKig format microsoft targetfolder /Users/$accountName/Documents/GAMfiles targetname newHireTracker.xlsx overwrite true 
                    break
                fi
            done

        # Running python script to collect new hire info from excel sheet and saving the details into a csv file and previewing data
            echo 
            echo "Using pandas magic to retrieve new hire info"
            echo
            python3 $pandaMagic
            echo
            echo "If you are not satisfied with the results, please re-edit the $newUserCsv file with your data and save it."
            echo
        # Making sure that the end user have verified new hire info in the newUser.csv file
            echo "Please make sure that you have a *LICENSE* available and verify the *newUser.csv* before proceeding further."
            echo
            echo "Once verified, enter Y to Proceed :"
            while :
            do
                read opt
                case $opt in
                    y|Y)
                        echo
                        echo "Creating user"
                        #Generate random password 
                        pwd=`openssl rand -base64 12`

                        #create user
                        $GAM csv $newUserCsv gam create user \~email firstname \~first lastname \~last password $pwd changepasswordatnextlogin True  

                        #fill in profile details
                        echo
                        echo "Updating profile details.."
                        $GAM csv $newUserCsv gam update user \~email relation manager \~managerEmail organization title \~jobTitle department \~dept

                        #Moving to a specific OU
                        echo 
                        read -p "Would you like to move this user to any specific OU other than default ? (Y/N) " ans;
                        case $ans in 
                            y|Y)
                                    while :
                                    do 
                                        echo
                                        echo "Alright, Choose one of the following OU:"
                                        echo "1. Org1"
                                        echo "2. Org2"
                                        echo "3. Org3"
                                        echo "4. Org4"
                                        read opt
                                        case $opt in
                                            1)  echo "Moving user to Org1"
                                                $GAM csv $newUserCsv gam update org Org1 move user \~email
                                                break
                                                ;;
                                            2)  echo "Moving user to Org2"
                                                $GAM csv $newUserCsv gam update org Org2 move user \~email
                                                break
                                                ;;
                                            3)  echo "Moving user to Org3"
                                                $GAM csv $newUserCsv gam update org Org3 move user \~email
                                                break
                                                ;;
                                            4)  echo "Moving user to Org4"
                                                $GAM csv $newUserCsv gam update org Org3 move user \~email
                                                break
                                                ;;
                                            *)  echo
                                                echo "Please enter a valid option."
                                                echo
                                                ;;
                                        esac
                                    done
                                ;;
                            n|N)
                                echo
                                echo "Alrighty then..."
                                ;;
                        esac
                        
                        #Running Python script to collect info for adding groups to user
                        echo
                        while :
                        do
                            read -p "Would you like to add groups to this user ? (Y/N) " ans;
                            case $ans in
                                y|Y)
                                    echo
                                    echo "Starting python magic ..."
                                    echo 
                                    python3 $addingGroups
                                    echo
                                    echo "If you are not satisfied with the results, please re-edit the $groupCsv file with your data and save it."
                                    echo
                                    echo "Please verify the groupsToAdd.csv before proceeding further. Once verified, press Y to Proceed: "
                                    while :
                                    do
                                        read opt
                                        case $opt in
                                            y|Y)
                                                echo
                                                $GAM csv $groupCsv gam update groups \~groupName add member \~memberName
                                                echo
                                                break
                                                ;;
                                            *)
                                                echo
                                                echo "Please enter a valid option."
                                                echo
                                                ;;
                                        esac
                                    done
                                    break
                                    ;;
                                n|N)
                                    echo
                                    echo "Alrighty then..."
                                    break
                                    ;;
                                *)
                                    echo
                                    echo "Enter a valid option"
                                    echo
                                    ;;
                            esac
                        done
                        break
                        ;;
                    *)  echo
                        echo "Please enter a valid option."
                        echo
                        ;;
                esac
            done

        #Setting signature
                
            echo "Setting up Signature..."
            echo
            $GAM csv $newUserCsv gam user \~email signature file $sigFile replace fullName field:name.fullName replace title field:organization.title replace phonenumber field:phone.value.type.work
            echo
            echo "Here's the current signature of the user"
            echo
            $GAM csv $newUserCsv gam user \~email show signature format
            echo

        #Uploading logs to I.T team G-drive folder for audit purpose and reference.
            echo "Initiating upload of log.."
            echo
            echo "User is provisioned in G by $adminName at $NOW"
            #Make sure to change the folder id of your g-drive below
            $GAM user $adminName add drivefile localfile $logLoc teamdriveparentid 1n8580FUK8-x1N_8UUxj5DvTnmNexlQem 
            echo
            echo "Locally, you can find the log at: "
            echo $logLoc
            echo
        #Running bye.py to give few key details that could help in next steps
            python3 $takeOut
            echo "Password:               $pwd"
            echo
            echo "(^ _ ^)/~~ & Nandri!"
            echo
        
        
    ) 2>&1 |tee -a $logLoc
