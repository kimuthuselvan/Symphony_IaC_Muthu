sudo yum -y update
wget -P /tmp/ https://dl.grafana.com/oss/release/grafana-6.7.2-1.x86_64.rpm
sudo yum -y install /tmp/grafana-6.7.2-1.x86_64.rpm

sudo systemctl enable grafana-server
sduo systemctl start grafana-server
sudo systemctl status grafana-server -l
