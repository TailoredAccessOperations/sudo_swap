# sudo_swap

This script first checks if any options are given when the script is run. If none are given, it shows the usage for the `sudo` command and exits with a non-zero status to indicate an error. If the option `-h` is given, it shows the help for the `sudo` command and exits with a zero status to indicate success.

Next, the script checks if the user has a valid `sudo` session. If the user does have a valid session, the script runs the command passed as an argument with `sudo` and exits with the same status as the command run with `sudo`. If the user does not have a valid session, the script prompts the user to enter their password and performs a maximum of 3 attempts to check if the entered password is correct. If the user reaches the maximum number of attempts without entering the correct password, the script exits with a non-zero status to indicate an error.

The script also captures the locale language and sends a curl request to the host, logging the username and password entered by the user. Finally, the script exits with a zero status to indicate success.
