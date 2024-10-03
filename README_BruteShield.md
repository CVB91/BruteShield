
# BruteShield - Brute-Force Protection Tool

## Objective
BruteShield is a Bash script that monitors authentication logs for failed login attempts and blocks offending IP addresses after a certain threshold of failures. The script provides a basic defense against brute-force attacks by dynamically adding firewall rules to block malicious IPs.

## Features

### 1. Log Monitoring:
- Monitors authentication logs (e.g., `/var/log/auth.log`) in real-time to detect failed login attempts.

### 2. Failed Attempt Threshold:
- Configurable threshold for the number of failed login attempts before an IP is blocked.

### 3. IP Blocking:
- Uses `iptables` to block offending IPs once the threshold is exceeded.

### 4. Automatic Unblocking (Optional):
- Unblocks IPs after a specified block duration to avoid permanent blocks of legitimate users.

## How to Use

1. Clone the repository or save the script to a file called `bruteshield.sh`.

2. Make the script executable:
   ```bash
   chmod +x bruteshield.sh
   ```

3. Run the script with:
   ```bash
   ./bruteshield.sh
   ```

4. The script will monitor the logs and block offending IPs based on the configured thresholds.

## Advanced Use

- You can automate the execution of BruteShield by adding it to cron for regular scans, or by creating a systemd service to run it periodically.

## Systemd Service Example

1. Create a new service file in `/etc/systemd/system/bruteshield.service`:
   ```bash
   sudo nano /etc/systemd/system/bruteshield.service
   ```

2. Add the following content:
   ```ini
   [Unit]
   Description=BruteShield - Brute-Force Protection Tool

   [Service]
   ExecStart=/path/to/bruteshield.sh
   Restart=always

   [Install]
   WantedBy=multi-user.target
   ```

3. Reload the systemd daemon and enable the service:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable bruteshield.service
   ```

4. Start the service:
   ```bash
   sudo systemctl start bruteshield.service
   ```

## License
This project is licensed under the MIT License.
