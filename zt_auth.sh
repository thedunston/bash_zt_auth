#!/bin/bash

# Script based off of Nicolás Jorge Dato article. https://www.baeldung.com/linux/monitor-changes-directory-tree

# Create a directory to monitor.  That directory path will need to be added to the SSH key forced command.
# Example: command="command="echo 1 > /activate/abcdef7890",no-pty,no-port-forwarding,no-X11-forwarding ssh-rsa.... 
# My directory is /activate.  First change permissions so any user can write to the directory.
# chmod 777 /activate
# chmod +t /activate
# Then run the command: bash auth_zt.sh /activate &
# Generate the ssh keys and add the forced command for each user and their respective node.

# Authentication Token
AUTH_TOKEN="$(cat /var/lib/zerotier-one/authtoken.secret)"

# ZeroTier controller IP. Default, 127.0.0.1
ztAddress="http://127.0.0.1:9993/controller/network"

# ZeroTier network ID
ztNet="39ee4368238ae577"

node_update() {

    theDate=$(date)
    echo "[${theDate}]: The node ${1}${2} was modified" >> monitor_log
    curl -s -H "X-ZT1-Auth: ${AUTH_TOKEN} " -X POST -d '{"authorized": true}' "${ztAddress}/${ztNet}/member/${2}"

}

node_auth() {

    theDate=$(date)
    echo "[${theDate}]: The node ${2} was authorized." >> monitor_log

    # Authorize the node
    curl -s -H "X-ZT1-Auth: ${AUTH_TOKEN}" -X POST -d '{"authorized": true}' "${ztAddress}/${ztNet}/member/${2}"

}

inotifywait -q -m -r -e create,modify $1 | while read DIRECTORY EVENT FILE; do
    case $EVENT in
        CREATE*)

	    # Check for new files that match the regex for ZT node IDs
	    if [[ "${FILE}" =~ ^[a-f0-9]{10}$ ]]; then

	           node_auth "$DIRECTORY" "$FILE"

	    else

		# Delete any file that doesn't match the pattern
		rm -f "${DIRECTORY}${FILE}"

	    fi

	    ;;

          MODIFY*)

	        node_update "$DIRECTORY" "$FILE"

	  ;;

    esac

done
