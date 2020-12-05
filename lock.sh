#!/bin/bash

# TermLock (Terminal Lock)
# r2020-12-05 fr2017-01-13
# by Valerio Capello - http://labs.geody.com/ - License: GPL v3.0

trap "" 1 2 3 20 # Traps Signals and Interrupts: blocks Ctrl+C , Ctrl+\ , Ctrl+Z , Ctrl+D

# pwunlock='$6$00000000$Ecw0YyyJ4sK4v4s7/V/HvstYmY48Hthq0T3M/Dr70frxMfGTUbP4llrgm2vTwJbQxGGbP2cDUlvl2QeO6tPwo0' # Hash for "test" (without quotes), generated with mkpasswd -m sha-512 --salt '00000000' 'test' # Set the hash of the unlock password. Use single quotes (''), not double quotes (""), to avoid '$' being interpreted as variables
# pwunlock=$1; # Pass the MD5 hash of the unlock password as a parameter from the command line
# pwunlock=`mkpasswd -m sha-512 --salt '00000000' 'test1'`; # Create a sha-512 hash from a clear text string (not recommended here within the script, as it leaves the password in cleartext)
pwunlock=`getent shadow|grep "$(whoami)"|cut -f 2- -d ':'|cut -f 1 -d ':'`; # Get the hash type, salt and hashed password for the current user
pwunlockhtyp=1; # hash type: 0: plain text (not recommended), 1: autodetect (recommended)
alarmfail=0; # Play a sound for failed attempts (might not work on all shells/terminals): 0: No, 1: Yes
tllogfailwarn=0; # Warn that failed attempts will be logged (if enabled): 0: No, 1: Yes
tllogfail=1; # Log failed attempts: 0: No, 1: Yes
tllogfailfn="/var/log/termlock/termlock_access_`date '+%Y'`.log"; # Log file name for Failed attempts (destination directory must exists and be writeable)
tlloglock=1; # Log locks: 0: No, 1: Yes
tlloglockfn="/var/log/termlock/termlock_access_`date '+%Y'`.log"; # Log file name for Locks (destination directory must exists and be writeable)
tllogunlock=1; # Log unlocks: 0: No, 1: Yes
tllogunlockfn="/var/log/termlock/termlock_access_`date '+%Y'`.log"; # Log file name for Unlocks (destination directory must exists and be writeable)
tllogedt=1; # Add date and time to log entries: 0: No, 1: Yes
tllogeip=1; # Add IP address to log entries: 0: No, 1: Yes

if [ "$pwunlockhtyp" -eq 1 ]; then
if [ "${pwunlock//[^$]}" = '$$$' ]; then
pwhtyp=`echo -n "$pwunlock"|cut -f 2- -d ':'|cut -f 1 -d ':'|cut -f 2- -d '$'|cut -f 1 -d '$'`; # Get the hash type
pwhslt=`echo -n "$pwunlock"|cut -f 2- -d ':'|cut -f 1 -d ':'|cut -f 2- -d '$'|cut -f 2- -d '$'|cut -f 1 -d '$'`; # Get the salt
case "$pwhtyp" in
1)
pwhtypa='md5';
;;
5)
pwhtypa='sha-256';
;;
6)
pwhtypa='sha-512';
;;
*)
$pwunlockhtyp=0;
pwhtypa='';
;;
esac
fi
else
# It might be DES, which is not supported. Assume cleartext.
$pwunlockhtyp=0;
pwhtypa='';
fi

# echo "Hash: $pwunlock";

if [ $tlloglock -eq 1 ]; then
if [ $tllogedt -eq 1 ]; then
ctdt="`date '+%F %T'` "
else
ctdt=""
fi
if [ $tllogeip -eq 1 ]; then
ctip="`echo $SSH_CLIENT | awk '{print $1}'` "
else
ctip=""
fi
echo "$ctdt$ctip*** LOCK ***" >> $tlloglockfn
fi

clear
while true
do
clear
echo "TERMINAL LOCKED"
# echo "Press Enter to unlock"; read key
while read -r -t 0; do read -r; done # Empties Keyboard Buffer
if [ $tllogfail -eq 1 -a $tllogfailwarn -eq 1 ]; then
echo "Failed attempts will be logged"
fi
echo -n "Enter Password: "
# read pwin # Show typed password
read -s pwin # Hide typed password
if [ "$pwunlockhtyp" -eq 1 ]; then
pwinh=`mkpasswd -m $pwhtypa --salt "$pwhslt" "$pwin";`;
else
# pwinh=`echo -n "$pwin" | md5sum | sed 's/  -//g';`; # md5sum
pwinh="$pwunlock";
fi
while true
do
if [ "$pwinh" = "$pwunlock" ]
then
# clear
break 2
else
if [ $tllogfail -eq 1 ]; then
if [ $tllogedt -eq 1 ]; then
ctdt="`date '+%F %T'` "
else
ctdt=""
fi
if [ $tllogeip -eq 1 ]; then
ctip="`echo $SSH_CLIENT | awk '{print $1}'` "
else
ctip=""
fi
echo "$ctdt$ctip$pwin" >> $tllogfailfn
fi
echo -e "\nWrong password"
if [ $alarmfail -eq 1 ]; then
for i in {1..5}; do printf '\7'; sleep 0.2; done
sleep 2
else
sleep 3 # Pauses to slow down brute force attacks
fi
# echo -e "\nPress Enter for a new attempt"; read key
break
fi
done
done
pwunlock=""; pwin=""; pwinh=""; pwhtyp=""; pwhtypa=""; pwhslt=""; # The scope of these variables is local but better safe than sorry
if [ $tllogunlock -eq 1 ]; then
if [ $tllogedt -eq 1 ]; then
ctdt="`date '+%F %T'` "
else
ctdt=""
fi
if [ $tllogeip -eq 1 ]; then
ctip="`echo $SSH_CLIENT | awk '{print $1}'` "
else
ctip=""
fi
echo "$ctdt$ctip*** UNLOCK ***" >> $tllogunlockfn
fi
echo -e "\nTerminal Unlocked\n"
