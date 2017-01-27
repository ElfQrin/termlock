# TermLock (Terminal Lock)
# r2017-01-27 fr2017-01-13
# by Valerio Capello - http://labs.geody.com/ - License: GPL v3.0

trap "" 1 2 3 20 # Traps Signals and Interrupts: blocks Ctrl+C , Ctrl+\ , Ctrl+Z , Ctrl+D

# 098f6bcd4621d373cade4e832627b4f6 # Hash for "test" (without quotes)
# pwunlock=$1; # Pass the MD5 hash of the unlock password as a parameter from the command line
pwunlock="098f6bcd4621d373cade4e832627b4f6"; # Set the MD5 hash of the unlock password (type echo -n "PASSWORD" | md5sum | sed "s/  -//g"; in the command line to get the hash of the password. You may want to delete the last command from the history after getting the hash.
# pwunlock=echo -n "PASSWORD" | md5sum | sed "s/  -//g"; # Create MD5 hash from a clear text string (not recommended)
alarmfail=0; # Play a sound for failed attempts (might not work on all shells/terminals): 0: No, 1: Yes
tllogfailwarn=0; # Warn that failed attempts will be logged (if enabled)
tllogfail=1; # Log failed attempts: 0: No, 1: Yes
tllogfailfn="/var/log/termlock/termlock_access_`date '+%Y'`.log"; # Log file name for Failed attempts (destination directory must exists and be writeable)
tlloglock=1; # Log locks: 0: No, 1: Yes
tlloglockfn="/var/log/termlock/termlock_access_`date '+%Y'`.log"; # Log file name for Locks (destination directory must exists and be writeable)
tllogunlock=1; # Log unlocks: 0: No, 1: Yes
tllogunlockfn="/var/log/termlock/termlock_access_`date '+%Y'`.log"; # Log file name for Unlocks (destination directory must exists and be writeable)
tllogedt=1; # Add date and time to log entries: 0: No, 1: Yes
tllogeip=0; # Add IP address to log entries: 0: No, 1: Yes

if [ $tlloglock -eq 1 ]; then
if [ $tllogedt -eq 1 ]; then
ctdt="`date '+[%F %T]'` "
else
ctdt=""
fi
if [ $tllogeip -eq 1 ]; then
ctip="[`echo $SSH_CLIENT | awk '{print $1}'`] "
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
pwinh=`echo -n "$pwin" | md5sum | sed "s/  -//g";`
while true
do
# if [ "$pwin" = "$pwunlock" ] # Use only if passwords are not hashed (not recommended)
if [ "$pwinh" = "$pwunlock" ]
then
# clear
break 2
else
if [ $tllogfail -eq 1 ]; then
if [ $tllogedt -eq 1 ]; then
ctdt="`date '+[%F %T]'` "
else
ctdt=""
fi
if [ $tllogeip -eq 1 ]; then
ctip="[`echo $SSH_CLIENT | awk '{print $1}'`] "
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
pwunlock=""; pwin=""; pwinh="" # The scope of these variables is local but better safe than sorry
if [ $tllogunlock -eq 1 ]; then
if [ $tllogedt -eq 1 ]; then
ctdt="`date '+[%F %T]'` "
else
ctdt=""
fi
if [ $tllogeip -eq 1 ]; then
ctip="[`echo $SSH_CLIENT | awk '{print $1}'`] "
else
ctip=""
fi
echo "$ctdt$ctip*** UNLOCK ***" >> $tllogunlockfn
fi
echo -e "\nTerminal Unlocked\n"
