#!/bin/bash

# call convertDateToEpoch $RETURN_VAL $DATE
# converts date to since epoch
# tested date formats:
# "2017-07-01 08:00:00"
# "01 Jul 2017 08:00:00"
convertDateToEpoch() {
	echo "DATE in is: $2"
    declare -n reVal=$1
	local date=$(($(date --date="$2" +'%s * 1000 + %-N / 1000000')))
	reVal=$date
}

#call: checkOnline @TARGET_IP
# Checks if a host is online
# It just tried to ping it serveral times and see if the host answers
checkOnline() {
	local TOOLS_CHECK_ONLINE_COUNT=3 #TODO: rethink and rename...
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

# call: netCopy $FILE $TARGET_FILE $TARGET_IP $TARGET_USER $TARGET_PASSWD
# Copies a file to a network target
netCopy() {
	if [ "$#" -ne 6 ]; then	
		log "netCopy() - Copy $1 to $4@$3:$2" 1
		`sshpass -p $5 scp -q $1 $4@$3:$2`
	else
		log "netCopy() - params wrong [$*]" 2
		return 1
	fi
	return 0
}


# call: netExe $SUDO $COMMAND $TARGET_IP $TARGET_USER $TARGET_PASSWD
# Executes command on remote system
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
	log "Output of netExe is: $SSH_RET" 1
	return 0
}

# call: checkHostExistsInSSHConfig $SSH_HOSTNAME
# Checks if a host is configured in a ssh config file
# needs $SSH_CONFIG configutred and pointing to an ssh config file
checkHostExistsInSSHConfig() {
	if [ -z "$SSH_CONFIG" ]; then
		log "No SSH_CONFIG param present." 2
		return 1
	else
		if [ ! -f "$SSH_CONFIG" ]; then
			log "Missing $SSH_CONFIG" 2
			return 1
		else
		# assumes that at this point we have a valid ssh config file (TODO: check if its really valid!)
			GREP_RET=`cat $SSH_CONFIG | grep -x "Host $1"`
			if [ ! $? -eq 0 ]; then
				log "Cannot find host $1 in ssh config file: $SSH_CONFIG" 1
				return 1
			else
				log "Found host $1 in $SSH_CONFIG" 0
			fi
		fi
	fi
	return 0
}

# call: checkIfInstalled REMOTE PACKAGE_NAME INSTALL_IF_NOT_INSTALLED(any input)
# Checks if a packet is installed
# needs dpkg
#TODO nicer output....
checkIfInstalled() {
	local DPKG_L_NOT_FOUND="no"
	if [ $1 -eq 1 ]; then
		echo "exe remote"
		#TODO this must somehow get the user-host config....
		NETEXE_RET=`netExe 0 "dpkg-query -W $2 2>&1" 10.254.0.22 root 1234`
		grep -q "$DPKG_L_NOT_FOUND" <<< $NETEXE_RET
	else
		echo "exe local"
		dpkg-query -W $2 2>&1 | grep "$DPKG_L_NOT_FOUND"
		fi	
	if [ $? -eq 0 ]; then
		log "Packet $2 is not installed" 1
		if [ $3 -eq 0 ]; then
			return 1
		else
			log "Try to install $2 with [installWithApt $3 $2]" 1
			installWithApt 1 $2
		fi	
	else
		log "Packet $2 is installed." 0
	fi
	return 0
}

# call: 
# Installs packages
# needs apt-get
installWithApt() {
	echo "updateing apt lists because 1"
	echo "installing $2"
	return 0
}

export -f convertDateToEpoch
export -f netExe
export -f netCopy
export -f checkOnline
export -f checkHostExistsInSSHConfig
export -f checkIfInstalled
export -f installWithApt