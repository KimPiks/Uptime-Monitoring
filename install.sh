#!/bin/bash

if [ "$EUID" -ne 0 ]; then 
  echo "To install the script, you need to run it as root."
  exit 1
fi

# Move script to /usr/bin
echo "Installing Uptime Monitoring..."
cp src/uptime-monitoring.sh /usr/bin/uptime-monitoring
chmod +x /usr/bin/uptime-monitoring

# Move includes to /usr/lib/uptime-monitoring
echo "Installing includes..."
mkdir -p /usr/lib/uptime-monitoring
cp src/includes/* /usr/lib/uptime-monitoring

# Create logs directory
echo "Creating logs directory..."
mkdir -p /var/log/uptime-monitoring

# Create configs
echo "Creating configs..."
mkdir -p /etc/uptime-monitoring
cp src/configs/* /etc/uptime-monitoring

# Create systemd service
echo "Creating systemd service..."
cp src/uptime-monitoring.service /etc/systemd/system/uptime-monitoring.service

# Copy man file
echo "Copying man file..."
cp src/uptime-monitoring.man /usr/share/man/man1/uptime-monitoring.1

# Finish
echo "Installation complete."
echo "Read script help page by running 'uptime-monitoring --help', you will know how to use the script."
echo "To start the service, run 'systemctl start uptime-monitoring'"