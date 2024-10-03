
#!/bin/bash

# Variables
LOG_FILE="/var/log/auth.log"  # Path to the log file you want to monitor
BLOCK_THRESHOLD=5             # Number of failed attempts before blocking
TIME_WINDOW=60                # Time window in seconds to observe failed attempts
BLOCK_DURATION=3600           # Duration to block the IP in seconds (optional)
BLOCKED_IPS="/tmp/blocked_ips.txt"  # File to keep track of blocked IPs

# Function to block an IP address
block_ip() {
    local ip=$1
    echo "[INFO] Blocking IP $ip"
    
    # Add the IP to the firewall block list (using iptables as an example)
    iptables -A INPUT -s "$ip" -j DROP

    # Record the blocked IP with timestamp
    echo "$ip $(date +%s)" >> $BLOCKED_IPS

    # Optional: Send an alert
    echo "Blocked IP: $ip due to failed login attempts" | mail -s "BruteShield Alert" admin@yourdomain.com
}

# Function to check and unblock IPs after BLOCK_DURATION
unblock_ips() {
    local current_time=$(date +%s)
    local new_blocked_ips="/tmp/blocked_ips_new.txt"
    touch $new_blocked_ips

    while read -r line; do
        local ip=$(echo "$line" | awk '{print $1}')
        local block_time=$(echo "$line" | awk '{print $2}')
        local time_diff=$((current_time - block_time))

        # Unblock IPs if they have been blocked for longer than BLOCK_DURATION
        if [ $time_diff -ge $BLOCK_DURATION ]; then
            echo "[INFO] Unblocking IP $ip"
            iptables -D INPUT -s "$ip" -j DROP
        else
            echo "$line" >> $new_blocked_ips
        fi
    done < $BLOCKED_IPS

    mv $new_blocked_ips $BLOCKED_IPS
}

# Monitor log file for failed login attempts and block offending IPs
tail -F $LOG_FILE | while read -r line; do
    # Extract relevant details (example for SSH login failure)
    if echo "$line" | grep "Failed password" > /dev/null; then
        ip=$(echo "$line" | awk '{print $NF}')

        # Track failed attempts from each IP using an associative array
        declare -A failed_attempts

        if [[ -z ${failed_attempts["$ip"]} ]]; then
            failed_attempts["$ip"]=1
        else
            failed_attempts["$ip"]=$((failed_attempts["$ip"] + 1))
        fi

        # If the threshold is exceeded, block the IP
        if [[ ${failed_attempts["$ip"]} -ge $BLOCK_THRESHOLD ]]; then
            block_ip "$ip"
            unset failed_attempts["$ip"]
        fi
    fi
done
