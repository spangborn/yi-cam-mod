#!/bin/sh

# Moscow TimeZone UTC+3
# If you need other TimeZone just change mytz value
# Moscow      UTC+3
# Kiev/Tallin UTC+2
# Berlin      UTC+1
# Los-Angeles UTC-8

mytz=UTC-7 # <- Edit here

digitalTZ=`echo $mytz | sed 's/UTC//'`

TZtoSet=$((8-digitalTZ))

if [ $TZtoSet -gt 0 ]; then
    TZValue="GMT+$TZtoSet"
    echo "TZValue=$TZValue"
else
    TZValue="GMT$TZtoSet"
    echo "TZValue=$TZValue"
fi

echo $TZValue > /etc/TZ

# Telnet

if [ ! -f "/etc/init.d/S88telnet" ]; then
    echo "#!/bin/sh" > /etc/init.d/S88telnet
    echo "telnetd &" >> /etc/init.d/S88telnet
    chmod 755 /etc/init.d/S88telnet
fi

# FTP

echo "#!/bin/sh" > /etc/init.d/S89ftp
echo "tcpsvd -vE 0.0.0.0 21 ftpd -w / &" >> /etc/init.d/S89ftp
chmod 755 /etc/init.d/S89ftp

# HTTP
dr=`dirname $0`
if ! cmp $dr/server /home/web/server; then
    mv /home/web/server /home/web/server.backup
    cp $dr/server /home/web/server
    ln -s /home/hd1/record /home/web/
fi

# RTSP

versionLetter=`sed -n 's/version=1.8.7.0\(.\)_.*/\1/p' /home/version`

case $versionLetter in
    A|B|M|N) file='M'
        ;;
    J|K|L) file='K'
        ;;
    E|F|H|I) file='I'
        ;;
    *) file='None'
        ;;
esac

if [ $file != 'None' ]; then
    filename="${dr}/rtspsvr${file}"
    echo Using $filename
    if test -f $filename; then
        if ! cmp $filename /home/rtspsvr; then
            test -f /home/rtspsvr && mv /home/rtspsvr /home/rtspsvr.backup
            cp $filename /home/rtspsvr
        fi
    fi
else
    echo 'Firmware not supported'
fi

# fix bootcycle

mv $dr/equip_test.sh $dr/equip_test-moved.sh
reboo