#!/bin/bash

#defines how often the online checker pings the target
TOOLS_CHECK_ONLINE_COUNT=3

# Checks if a host is online
# It just tried to ping it serveral times and see if the host answers
#call: checkOnline @TARGET_IP
checkOnline() {
	if [ "$#" -ne 2 ]; then
		log "Check if host [$1] is online" 0
		ping -q -c$TOOLS_CHECK_ONLINE_COUNT $1 > /dev/null
		if [ $? -eq 0 ]; then
	    	    log "Host [$1] is online" 1
		else
    		 	log "Host [$1] is offline" 2
    		 	return 1
		fi
	else 
		log "checkOnline() - params wrong [$*]" 2
		return 1
	fi
	return 0
}

# Copies a file to a network target
# call: netCopy $FILE $TARGET_FILE $TARGET_IP $TARGET_USER $TARGET_PASSWD
netCopy() {
	if [ "$#" -ne 6 ]; then	
		log "netCopy() - Copy $1 to $4@$3:$2" 1
		sshpass -p $5 | scp -q $1 $4@$3:$2
	else
		log "netCopy() - params wrong [$*]" 2
		return 1
	fi
	return 0
}

# Executes command on remote system
# call: netExe $SUDO $COMMAND $TARGET_IP $TARGET_USER $TARGET_PASSWD
netExe() {
	if [ "$#" -ne 6 ]; then
		if [ $1 -eq 1 ]; then
				log "netExe() - [ executing echo $5 | sudo -S -p '' $2 ] on $4@$3 with sudo flag" 1
				SSH_RET=`sshpass -p $5 ssh -q $4@$3 "echo $5 | sudo -S -p '' $2"`
		elif [ $1 -eq 0 ]; then
				log "netExe() - [ $2 ] on $4@$3" 1
				SSH_RET=`sshpass -p $5 ssh -q $4@$3 "$2"`
		else
				log "netExe() - params wrong [$*]" 2
				return 1
		fi
	else 
		log "netExe() - params wrong [$*]" 2
		return 1
	fi
	log "Return of netExe is: $SSH_RET" 1
	return 0
}

export -f netExe
export -f netCopy
export -f checkOnline
