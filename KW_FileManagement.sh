#!/bin/bash

first_color=41

window_idx=0
window_size=20

user_idx=0
proc_idx=-1

canCMD=0

getUsersArray() {
	allUser=(`grep /bin/bash /etc/passwd | cut -f1 -d: | sort`)

	i_cnt=0
	for sortUser in ${allUser[@]}
	do
		if [ ${#sortUser} -gt 7 ]; then
			printUser[$i_cnt]="${sortUser:0:6}""+"
		else
			printUser[$i_cnt]="${sortUser}"
		fi
		i_cnt=`expr $i_cnt + 1`
	done
}


getProcsArray_on_userid() {
	getwhatuser=$1

	allps=`ps -aux | grep -w $getwhatuser | sort -k 2 -g -r`
	
	IFS_backup="$IFS"

	IFS=$'\n'

	CMD=(`echo "$allps" | awk '{print $11$12$13}'`)
	PID=(`echo "$allps" | awk '{print $2}'`)
	STIME=(`echo "$allps" | awk '{print $9}'`)
	STAT=(`echo "$allps" | awk '{print $8}'`)
	FB=()
	for line in "${STAT[@]}"; do
		if [[ $line =~ "+" ]]; then
			FB+=('F')		
		else
			FB+=('B')		
		fi
	done

	IFS="$IFS_backup"
}

printColor() {
	if [ $2 = $1 ]; then
		echo -n [$3m
	fi
}

printLogo() {
	echo ""
	echo "______                       _    _"
	echo "| ___ \\                     | |  (_)"	
	echo "| |_/ / _ __   __ _    ___  | |_  _   ___   ___"
	echo "|  __/ |  __| / _  |  / __| |  _|| | / __| / _ \\"
	echo "| |    | |   | (_| | | (__  | |_ | || (__ |  __/"
	echo "\\_|    |_|    \\__,_|  \\___|  \\__||_| \\___| \\___|"

	echo

	echo "(_)         | |    (_)"
	echo " _   _ __   | |     _  _ __   _   _ __  __"
	echo "| | |  _ \\  | |    | ||  _ \\ | | | |\\ \\/ /"
	echo "| | | | | | | |____| || | | || |_| | >  <"
	echo "|_| |_| |_| \\_____/|_||_| |_| \\__,_|/_/\\_\\"
	
	echo ""
}

warning() {
	echo "" 
        echo '                               _   _  _____  '
        echo '                              | \ | ||  _  | '
        echo '                              |  \| || | | | '
        echo '                              | . ` || | | | '
        echo '                              | |\  |\ \_/ / '
        echo '                              \_| \_/ \___/  '
	echo ' ______  _____ ______ ___  ___ _____  _____  _____  _____  _____  _   _ '
	echo ' | ___ \|  ___|| ___ \|  \/  ||_   _|/  ___|/  ___||_   _||  _  || \ | | '
	echo ' | |_/ /| |__  | |_/ /| .  . |  | |  \ `--. \ `--.   | |  | | | ||  \| | '
	echo ' |  __/ |  __| |    / | |\/| |  | |   `--. \ `--. \  | |  | | | || . ` | '
	echo ' | |    | |___ | |\ \ | |  | | _| |_ /\__/ //\__/ / _| |_ \ \_/ /| |\  | '
	echo ' \_|    \____/ \_| \_|\_|  |_/ \___/ \____/ \____/  \___/  \___/ \_| \_/ '                                                                 
}

re_draw_screen(){
	clear
	printLogo
	getUsersArray
	getProcsArray_on_userid ${printUser[$user_idx]}

	userCnt=${#allUser[*]}
	if [ $userCnt -gt 20 ]; then
		userCnt=20
	fi

	numCmds=${#CMD[*]}

	echo "-NAME-----------------CMD--------------------PID-----STIME-----"
	for (( i=0; i<$window_size; i++)); do
		printf "|"

		
		printColor $i $user_idx $first_color

		printf "%20.20s" ${allUser[$i]}
		echo -n [0m
		printf "|"
		IFS_backup="$IFS"
		IFS=$'\n'

		virtual_idx=`expr $i + $window_idx`
		
		printColor $virtual_idx  $proc_idx 42
	
		printf "%-2s%-20.20s|%7.7s|%9.9s" ${FB[$virtual_idx]} ${CMD[$virtual_idx]} ${PID[$virtual_idx]} ${STIME[$virtual_idx]}
		
		echo -n [0m
		printf "|"
		IFS="$IFS_backup"
		printf "\n"
	done
	echo "---------------------------------------------------------------"
	echo "If you want to exit , Please Type 'q' or 'Q', Help : h or ?"
	printf ""

}

function proc_kill() {
	cur_username=`whoami`

	if [ "${allUser[$1]}" = "$cur_username" ]; then
		kill -9 ${PID[$2]}
	else
		clear
		warning
		sleep 3
	fi
}

function print_help() {
	clear
	echo ""
	echo "This is a Task Manager for Linux system!"
	echo "If you want to search some task please press right / left / up / down Direction Key!"
	echo "If you want to terminate the process press Enter Key or k Key!"
	echo "Warning : Do not terminate the other Users that you are not using it now!"
	sleep 2
}

function key_cusor_up() 
{
	if [ $canCMD -eq 0 ]; then
		if [ $user_idx -gt 0 ]; then
			user_idx=`expr $user_idx - 1`
		fi  
	else
		if [ $proc_idx -gt `expr $window_idx - 0` ]; then 
			if [ $proc_idx -gt 0 ]; then
				proc_idx=`expr $proc_idx - 1`
			fi
		else
			if [ $proc_idx -gt 0 ]; then
				proc_idx=`expr $proc_idx - 1`
				window_idx=`expr $window_idx - 1`
			fi		
		fi
	fi
}

function key_cusor_down() 
{
	if [ $canCMD -eq 0 ]; then
		if [ $user_idx -lt `expr $userCnt - 1` ]; then
			user_idx=`expr $user_idx + 1`
		fi 
	else
		
		if [ $proc_idx -lt `expr $window_size - 1`  ]; then 
			if [ $proc_idx -lt `expr $numCmds - 1` ]; then
				proc_idx=`expr $proc_idx + 1`
			fi 
		else
			if [ $proc_idx -lt `expr $numCmds - 1` ]; then
				proc_idx=`expr $proc_idx + 1`
				window_idx=`expr $window_idx + 1`
			fi			
		fi
	fi
}

function key_cusor_right() {
	if [ $canCMD -eq 0 ]; then
		proc_idx=0
		canCMD=1
		window_idx=0
	fi
}

function key_cusor_left() {
	if [ $canCMD -eq 1 ]; then
		canCMD=0
		proc_idx=-1
		window_idx=0
	fi
}

function key_ENTER() {
	if [ $canCMD = 1 ]; then
		proc_kill $user_idx $proc_idx
	fi
}

function key_HELP() {
	print_help
}


function main() {
	until [ "$key" = "Q" -o "$key" = "q" ]; do
		
		re_draw_screen
		
		IFS_backup="$IFS"
		IFS=''

		read -sN1 -t 3 key # 1 char (not delimiter), silent
		# catch multi-char special key sequences
		read -sN1 -t 0.0001 k1
		read -sN1 -t 0.0001 k2
		read -sN1 -t 0.0001 k3
		key+=${k1}${k2}${k3}

		case "$key" in

		$'\e[A'|$'\e0A')   # cursor up
		IFS="$IFS_backup"
		  key_cusor_up
		  ;;

		$'\e[B'|$'\e0B')  # cursor down
		IFS="$IFS_backup"
		  key_cusor_down
		  ;;

		$'\e[D'|$'\e0D')  # left
		IFS="$IFS_backup"
		  key_cusor_left
		  ;;

		$'\e[C'|$'\e0C')  # right
		IFS="$IFS_backup"
		  key_cusor_right
		  ;;


		$'\n')  # space: mark/unmark item
		IFS="$IFS_backup"
		  key_ENTER
		  ;;

                $'k')  # ENTER and k ALSO KILL THE PROCESS!!
                IFS="$IFS_backup"
                  key_ENTER
                  ;;

		$'?'|$'h')
		IFS="$IFS_backup"
         	  print_help
		  ;;

		'')
		IFS="$IFS_backup"
		  ;;

		*)
		IFS="$IFS_backup"
		  ;;

		esac                  

		continue
	done
	
}

main
