LIBPATH=/opt/open-xchange/lib
PROPERTIESDIR=/opt/open-xchange/etc
OSGIPATH=/opt/open-xchange/osgi

# Defines the Java options for the groupware Java virtual machine.
JAVA_XTRAOPTS="-Dsun.net.inetaddr.ttl=3600 -Dnetworkaddress.cache.ttl=3600 -Dnetworkaddress.cache.negative.ttl=10 -Dlogback.threadlocal.put.duplicate=false -server -Djava.awt.headless=true -XX:MaxPermSize=256m -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:CMSInitiatingOccupancyFraction=75 -XX:+UseCMSInitiatingOccupancyOnly -XX:NewRatio=3 -XX:+UseTLAB -XX:+DisableExplicitGC -Dosgi.compatibility.bootdelegation=false -XX:-OmitStackTraceInFastThrow -XmsINSERT_JAVA_MEM_MIN_HERE -XmxINSERT_JAVA_MEM_MAX_HERE -Djava.security.egd=file:/dev/./urandom"

# Defines the Java options for all command line tools. CLTs need much less memory compared to the groupware process.
JAVA_OXCMD_OPTS="-Djava.net.preferIPv4Stack=true -Xmx50m"

# Maximum number of open Files for the groupware
NRFILES="8192"

# Specify the umask of file permissions to be created by ox, e.g. in the
# filestore.
# BEWARE: setting a nonsense value like 666 will make open-xchange stop working!
#         useful values are 006 or 066
UMASK=066