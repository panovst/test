#!/bin/sh

RETVAL=0
appPath=$(dirname $0)/..
pidPath=${appPath}/var/server.pid
pidValue=""
if [ -f $pidPath ]
    then
        pidValue=`cat $pidPath`
fi


# server properties
CUSTOM="-Dadmin.enabled=false -Djabber.test.mode=false -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9999 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname=10.13.1.6"
CONFIG="-Dfelix.config.properties=file:$appPath/osgi/config.properties"
# JGROUPS="-Djava.net.preferIPv4Stack=true -Dcluster.config=$appPath/conf/cluster.xml -Djgroups.bind_addr=localhost"
JGROUPS="-Djava.net.preferIPv4Stack=true -Dcluster.config=$appPath/conf/cluster.xml"
JVM="-Xmx2G"
OPTIONS="$JVM $CONFIG $JGROUPS $CUSTOM"
EXECUTABLE="java $OPTIONS -jar osgi/org.apache.felix.main-2.0.2.jar"

# end of server properties


start() {
    if [ "$pidValue" ]
        then
            processStr=`ps uw -p "$pidValue" | grep felix`
            if [ "$processStr" ]
                then
                    echo "Server already started"
                    return
            fi
    fi
    # move to app home dir
    cd $appPath
    # start application
    logPath=${appPath}/logs/stdout.log
    if [ -e $logPath ]
        then
            mv $logPath "${logPath}."`stat -f %Sm -t %FT%T%z ${logPath}`
    fi
    nohup $EXECUTABLE >> $logPath &
    echo $! >$pidPath
}

stop() {
    if [ "$pidValue" ]
        then
            kill $pidValue
    fi
}

restart() {
    if [ "$pidValue" ]
        then
            stop
            sleep 5            # give it a few moments to shutdown
            kill -9 $pidValue  # force shutdown
            start
    fi
}

case "$1" in
       start)
               start
               ;;
       stop)
               stop
               ;;
       restart)
               restart
               ;;
       *)
               echo "Usage $0 {start|stop|restart}"
               RETVAL=1
esac

exit $RETVAL
