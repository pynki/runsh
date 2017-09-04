#!/bin/bash
# Simple logger script.
# Needs to be sourced by other scripts to export the log() function.
# Known log-level:
# * MISC
# 0 DEBUG
# 1 INFO
# 2 WARN
# 3 ERROR
# 10 EXEC
# 11 EXIT
# 99 ???? given when level not an int
# 101 DRAW A LINE

int='^[0-9]+$'
buildMsg() {
	case "$1" in
		101 ) MSG="------------------------------------------------------------";;
	esac
	SKIP_PREFIX=1
}

log() {
	SKIP_PREFIX=0
	if [ -z "$2" ]; then
		MSG=""		
		if [[ $1 =~ $int ]]; then
			LEVEL=$1
		else 
			LEVEL=99
		fi	
	else
		MSG=$1
		LEVEL=$2
	fi
	if [ "$LEVEL" -gt 100 ]; then
		buildMsg $LEVEL
	fi
	case "$LEVEL" in
		0 )  PREFIX="[DEBUG]";;
		1 )  PREFIX="[INFO] ";;
		2 )  PREFIX="[WARN] ";;
		3 )  PREFIX="[ERROR]";;
		10 ) PREFIX="[EXEC] ";;
		11 ) PREFIX="[EXIT] ";;
		* )  PREFIX="[MISC] ";;
	esac
	if [ "$LOG_DATE" = 1 ]; then
		LOG_PREFIX_CONSOLE=[`date $LOG_DATE_FORMAT_OPTIONS`]
	fi	
	if [ "$LEVEL" -gt "$LOG_LEVEL" -o "$LEVEL" -eq "$LOG_LEVEL" ]; then 		
		if [ $LOG_CONSOLE = 1 ]; then
			if [ "$SKIP_PREFIX" = 1 ]; then
				echo $MSG
			else				
				echo "$PREFIX$LOG_PREFIX_CONSOLE$SCRIPT_LOG_PREFIX $MSG"
			fi
		fi
		if [ $LOG_FILE = 1 ]; then
			if [ ! -e $LOG_FILE_PATH ]; then
				mkdir $LOG_FILE_PATH	
				touch $LOG_FILE_NAME		
			fi
			if [ "$SKIP_PREFIX" = 1 ]; then
				echo $MSG >> $LOG_FILE_NAME
			else		
				echo "$PREFIX$LOG_PREFIX_FILE$SCRIPT_LOG_PREFIX $MSG" >> $LOG_FILE_NAME
			fi
		fi
	fi	
}
export -f log
export -f buildMsg