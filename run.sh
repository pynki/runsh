#!/bin/bash


################################################################################
# COMMON FUNCTIONS
################################################################################
function quit {
	log "$1 Quit now!" 3
	log 11
	log 101
	exit $2			
}

################################################################################
# SOURCING OF OTHER SCRIPTS
################################################################################
#TODO this needs to be done in a function
source tools/logger.conf.sh
source tools/logger.sh
source tools/tools.sh

################################################################################
# DIRECTORY AND SCRIPTNAME
################################################################################
#TODO: this needs to be a done in a tools-script function
#TODO needs to be renamed to $SCRIPTNAME_BASE_DIR
SCRIPT_LOG_PREFIX=[`basename "$0"`]
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

################################################################################
# RUN.SH
################################################################################
log 101
log 10
### see above sourcing TODO
log "Sourced configs/all/includes.sh to get logging and tools" 0
log "Sourced configs/all/enviroment.sh to get enviroment vars" 0

### needs to be debug
log "DIR is $DIR" 0

### check if given config is GOOD
if [ -z "$1" ]; then
	quit '$1 not given - cannot execute "nothing"'
else
	if [ ! -f "$1" ]; then
        quit "File $1 does not exist!" 1
	else
		if [ ! -x "$1" ]; then
            quit "File $1 is not executable, try 'chmod +x $1' to make it executable." 1
		else
		log "Sourceing $1" 1
		source $1
		fi
	fi
fi
### see if the given script is GOOD
#TODO this needs to accept more than one script!
if [ -z "$EXEC_SCRIPT" ]; then
	quit 'No $EXEC_SCRIPT defined!'
else
 	if [ ! -f "$EXEC_SCRIPT" ]; then
		quit "File $EXEC_SCRIPT does not exist!" 1
	else 
		if [ ! -x "$EXEC_SCRIPT" ]; then
			quit "File $EXEC_SCRIPT is not executable, try 'chmod +x $EXEC_SCRIPT' to make it executable." 1
		fi
	fi
fi

################################################################################
# REMOTE CHECKS
################################################################################
if [ ! -z "$REMOTE_TYPE" ]; then
	log "REMOTE_TYPE defined. REMOTE_TYPE is: $REMOTE_TYPE" 0
	if [[ "$REMOTE_TYPE" == *"n"* ]]; then
		log 'Test if $TARGET_IP, $TARGET_USER and $TARGET_PASSWD are defined' 0
		if [ ! -z "$TARGET_IP" ] &&  [ ! -z "$TARGET_USER" ] && [ ! -z "$TARGET_PASSWD" ]; then
			log "Test for vars: 		OK" 0
			log "TARGET_IP is:     		$TARGET_IP" 1
			log "TARGET_USER is:   		$TARGET_USER" 1
			log "TARGET_PASSWD is: 		$TARGET_PASSWD" 1
			log "Test if $TARGET_IP is reachable" 0
			checkOnline $TARGET_IP
			if [ ! $? -eq 0 ]; then
				quit "Cannot ping $TARGET_IP. Is remote connected?" 1
			else
				log "Test if we can execute commands on the remote system via SSH" 0
				netExe 0 "cat /etc/hostname" $TARGET_IP $TARGET_USER $TARGET_PASSWD
				 if [ ! $? -eq 0 ]; then
                	quit "Cannot execute command on remote. Is SSH enabled?" 1
				fi
			fi
		else
			quit "Test for vars $TARGET_IP, $TARGET_USER or $TARGET_PASSWD: 		FAIL!" 1
		fi
	fi
	if [[ "$REMOTE_TYPE" == *"u"* ]]; then
        log "Test if TARGET_USB is defined" 0
		if [ ! -z "$TARGET_USB" ]; then
			log "Test for vars: 		OK" 0
			log "TARGET_USB is: 		$TARGET_USB" 1
			lsusb | grep -qw "$TARGET_USB"
			if [ ! $? -eq 0 ]; then
				quit "Cannot find USB device $TARGET_USB." 1
			else
				log "Found USB device $TARGET_USB" 0
			fi				
		else
        	quit "Test for var $TARGET_USB: 		FAIL!" 1
		fi
	fi
else
	log '$REMOTE_TYPE not defined, skipping tests for remote systems' 0
fi
### shift everything one to the left to have the config out of the way
shift 1
### executing the actual script that needs to be executed
log "Executing $EXEC_SCRIPT" 1
$EXEC_SCRIPT $@
RETURN_VAL=$?
log "Return value of $EXEC_SCRIPT is $RETURN_VAL" 0
if [ $RETURN_VAL -eq 0 ]; then
	log "$EXEC_SCRIPT successfully executed" 1 	
else
	log "$EXEC_SCRIPT not successfully executed" 2
fi

quit "run.sh finished."  $RETURN_VAL
