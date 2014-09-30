#!/bin/bash
author::yanjiajia
USAGE="usage:./`basename $0` start | stop | status | start_agent | stop_agent | start_webgui | stop_webgui"
IP=`ifconfig | awk -F'addr:|Bcast' '/Bcast/{print $2}' 2&> /dev/null`
wlisten_PID=`ps aux |grep "wlisten" |grep -v "grep" |awk '{ print $2 }'`
tuxwsvr_PID=`ps aux |grep "tuxwsvr" |grep -v "grep" |awk '{ print $2 }'`
tux_snmpd_STATUS=`ps aux |grep "tux_snmpd" |grep -v "grep" |awk '{ print $2 }'`
CMD=`ps aux |grep BBL|wc -l`
#start tuxedo
function start_tuxedo()
{ 
echo -e "===========starting tuxedo===========\n"
if  [ $CMD -eq 1 ];then
        echo "do you want to start tuxedo server,you can input Y/y/n/N?"
        read shuru
        case $shuru in
        Y|y)

        tmboot -y
        if [ $? -eq 0 ];then
                echo "starting tuxedo succeed"
        else
                echo "started failed"
        fi
        ;;
        N|n)
        echo "exit start tuxedo";exit 1
        ;;
        esac

else
        echo -e "tuxedo is running\n"
fi
}

#stop tuxedo 
function stop_tuxedo()
{
if [ "$tux_snmpd_STATUS" ];then
        echo "you must stop tux_snmpd"
else
        echo -e "===========stopping tuxedo===========\n"
        if [ $CMD -ne 1 ];then
                tmshutdown -y;sleep 5;tmipcrm -y 2&> /dev/null
        else
                echo -e "tuxedo is not running\n"
        fi
fi

}
#start tux_snmpd
function start_tux_snmpd()
{
echo  "do you wang to start tux_snmpd ? you can type Y/N"
read input
case $input in
y|Y|YES|yes)
read -p "please input tuxedo user password:" -s password
sudo tux_snmpd -l tux_snmp -s -c << EOF
$password
EOF
if [ $? -eq 0 ];then
        echo -e "start tux_snmpd succeed\n"
else
        echo -e "start failed";exit 1
fi
;;
N|n|no|NO)
exit 0
;;
*)
echo "please input YES/NO" ;;
esac
} 

#stop tux_snmpd
function stop_tux_snmpd()
{
echo  -e "===========stopping tuxedo snmp agent===========\n" 
stop_agent all;echo -e " tux_snmpd is not running\n" 

}

#start webgui
function start_web()
{
read -p "please input tuxedo user password:" -s password
sudo wlisten -i $TUXDIR/udataobj/webgui/webgui.ini << EOF
$password
EOF
sudo tuxwsvr -l //${IP:-"192.168.0.175"}:3050 -i $TUXDIR/udataobj/tuxwsvr.ini << EOF
$password
EOF
}

#stop webgui
function stop_web()
{
if [ "$wlisten_PID" ];then
        sudo kill -9 $wlisten_PID
else
        echo "wlisten is not exist" 
fi
if [ "$tuxwsvr_PID" ];then
        sudo kill -9 $tuxwsvr_PID
else


        echo "tuxwsvr is not exist"
fi
}

case $1 in
status)
echo "sorry,didn't realize"
;;
start)
start_tuxedo
;;
stop)
stop_tuxedo
;;
start_agent)
start_tux_snmpd
;;
stop_agent)
stop_tux_snmpd
;;
start_webgui)
start_web
;;
stop_webgui)
stop_web
;;
*)
echo $USAGE;;
esac 
