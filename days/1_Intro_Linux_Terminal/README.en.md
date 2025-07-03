# DevOps Apache & CGI Setup Script

This repository contains a Bash script (`apache_hello_world.sh`) designed to automate the initial setup of an Apache web server on an Ubuntu system, including enabling CGI (Common Gateway Interface) and deploying a dynamic "Hello World" web page that displays server uptime using a CGI script.

This script is ideal for quickly provisioning a development or testing environment.

## 🚀 Features

- **System Update & Upgrade:** Ensures the system packages are up-to-date.
- **Apache Installation:** Installs the Apache2 web server.
- **CGI Enablement:** Activates the Apache CGI module (`mod_cgi`) and configures the `cgi-bin` directory.
- **CGI Script Deployment:** Creates a simple `uptime.sh` Bash script in `/usr/lib/cgi-bin` that outputs the server's uptime.
- **Firewall Configuration:** Opens port 80 (HTTP) in UFW (Uncomplicated Firewall) to allow web traffic.
- **Custom Web Page:** Deploys a new `index.html` to `/var/www/html` that includes JavaScript to fetch and display the uptime from the CGI script.
- **Permissions Management:** Correctly sets ownership and permissions for the deployed web files (`index.html`) and CGI script (`uptime.sh`).
- **Verification Steps:** Includes commands to check Apache status, UFW rules, and a `curl` command to verify the deployed website.

## 📋 Prerequisites

- An Ubuntu-based Linux system (tested on Ubuntu 20.04 LTS Focal Fossa).
- `sudo` privileges on the system.
- Basic internet connectivity for package downloads.

**Note:** This script is primarily intended to be run within a Vagrant VM or a similar isolated development environment.

## 💡 How it Works

The script performs the following actions sequentially:

1.  Updates package lists and upgrades installed packages.
2.  Installs the `apache2` package.
3.  Enables Apache's `mod_cgi` module and restarts Apache.
4.  Creates the `/usr/lib/cgi-bin` directory if it doesn't exist.
5.  Writes a simple Bash script (`uptime.sh`) into the `cgi-bin` directory and makes it executable (`chmod 777`).
6.  Enables the `serve-cgi-bin` Apache configuration and reloads Apache to apply changes.
7.  Adds a UFW firewall rule to allow incoming traffic on TCP port 80.
8.  Checks the status of the Apache2 service.
9.  Removes the default Apache `index.html` page.
10. Creates a new `index.html` with custom content, including a JavaScript section to fetch server uptime from the CGI script.
11. Sets the ownership of `index.html` to `www-data:www-data` (the default Apache user/group).
12. Sets file permissions for `index.html` to `644` (read/write for owner, read-only for group and others).
13. Obtains and displays the system's public IP address.
14. Performs a `curl` request to the deployed website to verify its accessibility.

## 🚀 How to Run the Script

1.  **Make the script executable:**
    You need to give the script execution permissions.

    ```bash
    chmod +x apache_hello_world.sh
    ```

2.  **Run the script:**
    Execute the script with `sudo` because it performs system-level changes (package installation, firewall rules, file ownership, etc.).

    ```bash
    sudo ./apache_hello_world.sh
    ```

    The script will print messages indicating its progress. You may be prompted for your `sudo` password.

## ✨ After Running the Script

Once the script completes successfully:

1.  **Access the Web Server:**
    You should be able to access the Apache web server from your browser.

    - If you're running this in a Vagrant VM with default port forwarding (e.g., host's 8080 to guest's 80), open your browser on your **host machine** and go to:
      `http://localhost:8080`
    - If your VM has a private IP address (e.g., `192.168.33.10`), open your browser on your **host machine** and go to:
      `http://<VM_PRIVATE_IP>` (e.g., `http://192.168.33.10`)
    - If you are running the browser directly on the VM, go to:
      `http://localhost`

2.  **Verify Content:**
    You should see a web page with the title "¡DevOps en Acción!", a Git logo, the "¡Hola Mundo DevOps!" heading, a dynamically updated server time, and the server's uptime fetched from the CGI script.

3.  **Check CGI Script Directly (Optional):**
    You can also directly access the CGI script to see its raw output:
    `http://localhost/cgi-bin/uptime.sh` (adjust `localhost` to your VM's accessible IP/port if needed)

## 🐛 Troubleshooting

- **"Permission denied" during script execution:** Ensure you ran the script with `sudo`: `sudo ./apache_hello_world.sh`.
- **Website not loading (browser error):**
  - Check Apache status: `sudo systemctl status apache2`.
  - Verify UFW rules: `sudo ufw status`. Ensure `80/tcp ALLOW Anywhere` is listed.
  - Check file permissions and ownership:
    `ls -l /var/www/html/index.html` (should be `www-data:www-data` and `rw-r--r--`)
    `ls -l /usr/lib/cgi-bin/uptime.sh` (should be executable, e.g., `rwxrwxrwx`)
- **Uptime not showing or "Error cargando uptime.":**
  - Ensure `mod_cgi` is enabled: `sudo a2enmod cgi` followed by `sudo systemctl restart apache2`.
  - Ensure `serve-cgi-bin` is enabled: `sudo a2enconf serve-cgi-bin` followed by `sudo systemctl reload apache2`.
  - Check permissions of `uptime.sh`: `sudo chmod 777 /usr/lib/cgi-bin/uptime.sh`.
  - Try accessing the CGI script directly in your browser: `http://<VM_IP>/cgi-bin/uptime.sh`. If that works, there might be an issue with the JavaScript fetch on the `index.html` side.
- **Ubuntu Pro message during update/upgrade:** "The following security updates require Ubuntu Pro..." This is normal for Ubuntu 20.04 LTS. It won't prevent the script from running or Apache from installing.
