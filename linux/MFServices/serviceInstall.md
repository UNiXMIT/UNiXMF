# systemd Service Install

## Install Services
```
chmod +x /home/support/MFSupport/MFServices/*.sh
sudo ln -s /home/support/MFSupport/MFServices/*.service /etc/systemd/system/
sudo systemctl daemon-reload
```

## Start/Stop Service
```
sudo systemctl start serviceName
sudo systemctl stop serviceName
sudo systemctl restart serviceName
```