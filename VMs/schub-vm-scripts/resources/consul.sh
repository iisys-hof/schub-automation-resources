export GOMAXPROCS=`nproc` && sudo nohup consul agent \
  "--config-dir=/etc/consul.d/" \
  "--data-dir=/var/lib/consul/data/" \
  "--ui-dir=/usr/share/consul/ui/dist" > consul.log 2>&1 &
