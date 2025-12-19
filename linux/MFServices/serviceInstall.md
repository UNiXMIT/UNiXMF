# systemd Service Install

## Install Services
```
chmod +x services/*
sudo ln -s /home/support/MFSupport/MFServices/* /etc/systemd/system/
sudo systemctl daemon-reload
```

## Start/Stop Service
```
sudo systemctl start serviceName
sudo systemctl stop serviceName
```