#!/usr/bin/ksh
WORKDIR=/lvmbackup # directory is regularly backed up, of course
LOG=$WORKDIR/log
SYSADM=root
if [ -f "$LOG" ]
then
    rm -f "$LOG"
fi
if [ ! -d "$WORKDIR" ]
then
   Echo "missing directory $WORKDIR" exit 1
fi
cd $WORKDIR
/usr/sbin/vgdisplay -v -F > vgdisplay.new
LVMVGS=`grep vg_name vgdisplay.new | cut -d: -f1 | cut -d= -f2`
LVMPVOLS=`grep pv_name vgdisplay.new | cut -d: -f1 | cut -d= -f2 | cut -d,
-f1`
LVMLVOLS=`grep lv_name vgdisplay.new | cut -d: -f1 | cut -d= -f2`
/usr/sbin/pvdisplay -v $LVMPVOLS > pvdisplay.new
/usr/sbin/lvdisplay -v $LVMLVOLS > lvdisplay.new
/usr/sbin/lvlnboot -v > lvlnboot.new 2> /dev/null
/usr/sbin/ioscan -fk > ioscan.new
cp /etc/fstab fstab.new
for CURRENT in *new.
do
ORIG=${CURRENT%.new}
if diff $CURRENT $ORIG > /dev/null then
# files are the same....do nothing
rm $CURRENT
else
# files differ...make the new file the current file, move old
# one to file.old.
echo `date` "The config for $ORIG has changed." >> $LOG
echo "Copy of the new $ORIG config has been printed" >> $LOG
lp $CURRENT
mv $ORIG ${ORIG}old.
mv $CURRENT $ORIG
fi
done
if [ -s "$LOG" ]
then
     mailx -s "LVM configs have changed" $SYSADM < $LOG
fi
exit 0
