import pandas as pd
import getpass
accountName = getpass.getuser()

#reads excel and uses only specific cols for gathering data
df = pd.read_excel(f'/Users/{accountName}/Documents/GAMfiles/newHireTracker.xlsx', usecols=['Name','Title','Manager Email','Dept','START Actual','Personal e-mail (For IT)'])[['Name','Title','Manager Email','Dept','START Actual','Personal e-mail (For IT)']]
pd.set_option('colheader_justify', 'right')
pd.set_option('max_columns', 8)

#This option below can be turned on, if one needs the results in one line instead of multi-lines
#pd.set_option('expand_frame_repr', True)

#adds a column of suffix which is used later with email column.
df['domain_name'] = "@domainname.com"

# Splits Name column into two using whitespace as a spliter and limits the output to only 2 columns > 0(first),1(last)
df[['First','Last']] = df['Name'].str.split(expand=True,n=1)

#combines first and last column to create email address
df['Email'] = df['First'].str.cat(df['Last'], sep=".")

#converts email to lowercase
df['Email'] = df['Email'].str.lower()

#adds suffix to email address
df['Email'] = df['Email'] + df['domain_name']

#drops a columns to have a tidy data
df = df.drop(columns=['domain_name'])

#Prompts for input
newUser = input("Enter Full Name of the user: ")
print('')
print("Searching New Hire Tracker sheet for " + str(newUser))
        
#searches for input in the excel sheet
results = df['Name'].str.match(newUser, na=False, case=False)

#assigning the results to a variable to use it for while loop conditions
userExists = df[results]

# this loop verifies the input to see if it's empty & searches against excel sheet to find a valid username
while (userExists.empty is True or len(newUser) == 0):
    print('')
    print("Invalid Full Name, try again!!")
    print('')
    newUser = input("Full Name : ")
    results = df['Name'].str.match(newUser, na=False, case=False)
    userExists = df[results]
else:
    print('')
    print('A user has been found!')
    print('')

#Exports data to a csv file, which will be used by GAM for user creation
df[results].to_csv(f"/Users/{accountName}/Documents/GAMfiles/newUser.csv",index=False,header=['fullName','jobTitle','managerEmail','dept','startDate','personalEmail','first','last','email'])
print('User details are exported.')

#reads csv
newdf = pd.read_csv(f'/Users/{accountName}/Documents/GAMfiles/newUser.csv',usecols=['fullName','jobTitle','managerEmail','dept','first','last','email'])
print('')
print('Previewing data of newUser.csv')
print('')
print(newdf)




