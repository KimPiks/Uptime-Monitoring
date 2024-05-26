# Uptime-Monitoring

The uptime-monitoring tool is designed to monitor and report the status of websites. It records whether a website responds, the HTTP status it returns, and the response time. Monitoring occurs at specific intervals set in a configuration file. This tool can handle monitoring an indefinite number of websites, which are specified in the configuration file. It includes the ability to send email notifications via SMTP in case of response issues from any website and can regularly report the status of all monitored websites. Additionally, the script provides commands to track the status of services via the system terminal.

## Installation

1. Clone this repository
```
git clone https://github.com/KimPiks/Uptime-Monitoring.git
```
2. Go into script directory
```
cd Uptime-Monitoring
```
3. Install script
```
sudo ./install.sh
```
4. Start service
```
systemctl start uptime-monitoring
```

## Configuration

### * Importan note
- Changing the configuration may require the use of sudo because the configuration files are located in the /etc location.
If you want to change the locations of the configuration files, check the [[Changing configuration files location](#Changing-configuration-files-location)] sections

- Changing the configuration may require restarting the service: `systemctl restart uptime-monitoring`

<br>

1. Setting the e-mail address for sending notifications
```
sudo uptime-monitoring --set-email
```

2. Setting the proxy list
```
sudo uptime-monitoring --add-proxy [FILE_LOCATION]
```

* Each line of the proxy file should contain a separate proxy address. The script selects a random address for connections.

3. Adding service to monitoring
```
sudo uptime-monitoring --add-service
```

4. Removing service from monitoring
```
sudo uptime-monitoring --remove-service
```

## Commands

* `uptime-monitoring [options...]`

Options:<br>

* `--help`: Display help
* `--version` Display version
* `--service` Show status of services
* `--url [URL] --service` Show status of a specific service
* `--logs [URL]` Show last 100 logs of a specific service
* `--background` Start service in background
* `--add-service` Add a new service
* `--remove-service [URL]` Remove service
* `--set-email` Set email for notifications
* `--add-proxy [FILE]` Add proxy for service


## Changing configuration files location
1. Copy the configuration files from `/etc/uptime-monitoring` to the expected location

2. Edit the following line in the `/usr/bin/uptime-monitoring script`

```
CONFIGS_DIR="/etc/uptime-monitoring"
```

3. Restart service 
```
systemctl restart uptime-monitoring
```

## License
Check [LICENSE](https://github.com/KimPiks/Uptime-Monitoring/blob/main/LICENSE) file