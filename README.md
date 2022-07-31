# ZT AUTH

ZeroTier, by default, requires approval for each peer that wants to connect to a ZT network.  Once the peer is connected then it requires manual methods to remove it.

I wanted the ability to use ZT like a VPN for remote users and not have to manually deauthorize them after a given period of time.

ZT Auth is one solution for my needs.

## Backend Authentication

ZT Auth uses SSH for authentication.  

### Why SSH?

SSH is a very stable and robust application and protocol.  It has support for two-factor authentication, key-based authentication, etc.  It uses the native Linux authentication mechanisms, namely PAM, and account management is handled by the OS.  Additionally, obtaining access to a server running SSH only is relatively inexpensive.  Datapacket.net and DigitalOcean have VMs for less than $5/month.  However, port forwarding to a container provides a method of public access to an SSH server when running inside of a container.

It is recommended to use SSH Key-based authentication along with a second factor. By using key-based authentication, the user's public key can be prepended with the 'forced command' option to only allow one command to be run when a user authenticates and then the session is dropped. For this project, key-based authentication is required.

## Setup

Install inotify-tools:

`sudo apt install inotify-tools`

From that package, *inotifywait* will be used to monitor a directory for new files or updates to existing files.

Copy the file *zt-deauth.sh* to the /etc/cron.hourly directory and make it executable:

`cp zt-deauth.sh /etc/cron.hourly`

`chmod +x /etc/cron.hourly/zt-deauth.sh`

Every hour, each node's last login will be checked to see if the number of hours have passed when it will be expired.

Then copy the zt_auth.sh script anywhere you like.

`cp zt_auth.sh /usr/local/bin`

`chmod +x /usr/local/bin/zt_auth.sh`

Edit the user's public key and add at the beginning:

`command="echo 1 > /activate/abcdef7890",no-pty,no-port-forwarding,no-X11-forwarding ssh-rsa....`

the command redirects the number "1," which is arbitrary, into the file */activate/abcdef7890*.  Change *abcdef7890* to peer ID of the node that is on your ZT LAN.

You can use any directory you want, but be sure to change permissions so the user can write to it.  For example,, the directory /activate will be used:

`mkdir /activate`
`chmod 777 /activate`
`chmod +t /activate`

Then run:

`/usr/local/bin/zt_auth.sh /active &`

that will run the process in the background and wait for a file to be created matching the 10 character format for a ZT node.  Any other file found not in that format will be deleted.

The file to be created or updated will be one of the SSH users.  When they login, the command:

`echo 1 > /activate/abcdef7890`

will be executed and the session will immediately terminate.
