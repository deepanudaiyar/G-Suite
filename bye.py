import getpass
import pandas as pd
accountName = getpass.getuser()

# these options are here for better readability for results while outputting to terminal
pd.set_option('colheader_justify', 'right')
pd.set_option('max_columns', 8)
#This option displays results in multi-line , instead of 1-line
pd.set_option('expand_frame_repr', True)

#reads csv file to get email address
df = pd.read_csv(f'/Users/{accountName}/Documents/GAMfiles/newUser.csv')

# retrieves user data to display at the end of script
username = df.loc[0]['fullName']
startDate = df.loc[0]['startDate']
personalEmail = df.loc[0]['personalEmail']
email = df.loc[0]['email']

print('')
print('Onboarding complete, here are some key details for takeout!!')
print('')
print(f'{username} is now provisioned on G-Suite')
print('')
print(f'Email address:          {email}')
print('')
print(f'Start date:             {startDate}')
print('')
print(f'Email credentials to:   {personalEmail}')
print('')

