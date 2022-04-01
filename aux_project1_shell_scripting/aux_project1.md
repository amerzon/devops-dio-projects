# Shell script logic

- if user group "developers" does not exist then create it
- use a for loop to iterate through the names.csv file's names:
  - check if user already exist, if yes then log user already exists, and move on to the next name in the loop
    - if the user does not already exist then create user account with developer as member
      - ~/.ssh/authorized_keys

Command to create users:
sudo useradd $user -g users -G $GROUP_VAR 