#!/bin/bash

echo -n "Enter the host address:"
read host
echo -n "Enter the user name:"
read username

#add ssh-key
scp ~/.ssh/authorized_keys $username@$host:/home/$username/.ssh/
scp ~/.ssh/id_rsa.pub $username@$host:/home/$username/.ssh/
scp ~/.ssh/id_rsa $username@$host:/home/$username/.ssh/

#enable ssh-key
ssh -t $username@$host "mkdir ~/.ssh"
ssh -t $username@$host "eval $(ssh-agent)"

#add user previlege
ssh -t $username@$host "sudo cat /etc/sudoers > ~/sudoers_tmp"
ssh -t $username@$host "echo '$username ALL=NOPASSWD: ALL' >> ~/sudoers_tmp"
ssh -t $username@$host "sudo cp ~/sudoers_tmp /etc/sudoers"
