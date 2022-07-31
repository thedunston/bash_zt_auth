#!?bin/basho

# Checks to see if a node is set to expire.

# Authentication Token
AUTH_TOKEN="$(cat /var/lib/zerotier-one/authtoken.secret)"

# Hours to deauthorize.
theHours=24

# Network ID.
theNet="39ee4368238ae577"

# Network address and port.
ztAddress="http://127.0.0.1:9993/controller/network"

# Get the nodes.
for eachNode in $(curl -s -H "X-ZT1-Auth: ${AUTH_TOKEN}" -X GET ${ztAddress}/${theNet}/member | egrep -o '[a-z0-9]{10}'); do

	# Get the last authorization time.
	last_auth=$(curl -s -H "X-ZT1-Auth: ${AUTH_TOKEN}" -X GET ${ztAddress}/${theNet}/member/${eachNode} |jq -r '.lastAuthorizedTime')
	
	# Unix Epoch of last auth time. Remove the last three digits to use date command.
	epoch1=$(echo ${last_auth} | sed 's/...$//')
	
	# Current time.
	current_time=$(date +"%s")
	
	# 24 hours from now.
	epoch2=$(date -d @${epoch1} --date="${theHours} hours" +"%s")
	
	# Check if current date is greater than the last authorization time.
	if [[ ${current_time} > ${epoch2} ]]; then
	
		# Deauthorize the node.
		curl -s -H "X-ZT1-Auth: ${AUTH_TOKEN}" -X POST -d '{"authorized": false}'  "${ztAddress}/${theNet}/member/${eachNode}"
	
	fi

done