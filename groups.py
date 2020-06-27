import csv
import getpass
import pandas as pd

# these options are here for better readability for results while outputting to terminal
pd.set_option('colheader_justify', 'right')
pd.set_option('max_columns', 8)
#This option displays results in one line , instead of multi-line
pd.set_option('expand_frame_repr', False)

accountName = getpass.getuser()

#creates a new file
filename = f"/Users/{accountName}/Documents/GAMfiles/groupsToAdd.csv"

with open(filename, 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(["groupName", "memberName"])

#reads csv file to get email address
df = pd.read_csv(f'/Users/{accountName}/Documents/GAMfiles/newUser.csv')
userEmail = df.iloc[0]['email']

#Prompts for groups list
print('')
print("Enter one group name at a time and press Enter.\n Once you have listed all the groups, simply type DONE to proceed to next step.")
print('')
groupList = []
i=0
while 1:
    i+=1
    group=input('Group name %d: '%i)
    if group.casefold()=='done':
        break
    groupList.append(group)

# Appending the data to the csv file
with open(filename, 'a') as file:
    writer = csv.writer(file)
    for group in groupList:
        writer.writerow([group,userEmail])

# Previewing data of groupsToAdd
#reads csv
df = pd.read_csv(f'/Users/{accountName}/Documents/GAMfiles/groupsToAdd.csv')
print('')
print('Previewing data of groupsToAdd.csv')
print('')
print(df)