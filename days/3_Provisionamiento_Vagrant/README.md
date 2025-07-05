# 🛠️ DevOps Provisioning with Vagrant

**[Versión en Español](./README.es.md)**

<hr>

This project demonstrates automated provisioning of a development environment using **Vagrant** and **Bash scripting**. It showcases how to use Vagrant to spin up a virtual machine (VM), install essential services, and serve a website using Nginx.

## 🚀 What It Does

When you run `vagrant up`, the project:

1. **Creates a Virtual Machine** using the Ubuntu `focal64` base box.
2. **Installs and Configures**:
   - **Nginx**: Installs and enables the web server.
   - **Docker**: Installs Docker for container management.
   - **Node.js** and **npm**: Used to build front-end assets.
   - **kubectl**: Installs the Kubernetes CLI.
3. **Clones a Bootstrap Site**:
   - Clones [`startbootstrap-freelancer`](https://github.com/StartBootstrap/startbootstrap-freelancer).
   - Builds the project with `npm`.
   - Serves the built `index.html` via Nginx on `http://localhost:8081`.

## 🧱 Project Structure

```
.
├── Vagrantfile
├── README.md
├── scripts/
│   ├── install.sh              # Main provisioner that invokes all setup scripts
│   ├── nginx_install.sh        # Nginx setup and configuration
│   ├── docker_install.sh       # Docker + kubectl setup
│   ├── node_install.sh         # Node.js and npm installation
│   └── serve_bootstrap.sh      # Clones and serves Bootstrap project
```

## 🖥️ How to Use

### 1. Clone this repo:

```bash
git clone https://github.com/yourusername/your-repo.git
cd your-repo
```

### 2. Start the VM

```bash
vagrant up
```

The machine will boot, provision itself using the shell scripts, and serve a website at:

📍 **http://localhost:8081**

> You can shut it down with `vagrant halt` and re-provision with `vagrant provision`.

---

## 📓 Skills Practiced

- Writing modular **Bash scripts**
- Creating **Vagrant** environments
- Using **systemctl**, **curl**, and **command validation**
- Automating software installation and service management
- Using **npm** to build front-end projects
- Serving static content with **Nginx**

---

## 🧠 Notes

- The project is tested with **Ubuntu 20.04 (focal64)**.
- All scripts are located under the `/scripts` folder.
- The VM has a private IP `192.168.33.10` and port-forwarded access via `localhost:8081`.

---

## 🛠️ Troubleshooting

### ❗ Nginx or Docker are inactive

Make sure the services are installed and enabled:

```bash
sudo systemctl status nginx
sudo systemctl status docker
```

If inactive:

```bash
sudo systemctl enable --now nginx
sudo systemctl enable --now docker
```

### ❗ npm build fails with `globalThis is not defined`

You might be using an outdated Node.js version. Run:

```bash
node --version
```

If it's < `12`, upgrade Node.js and retry:

```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

### ❗ Port 8081 not working

- Make sure your host machine isn’t blocking port 8081.
- Ensure Nginx is running inside the VM.
- Try accessing `http://192.168.33.10` if using the private network.

### ❗ Changes not reflected

If you update the scripts but don’t see changes:

```bash
vagrant reload --provision
```

---

## 🙌 Author

**Luiggi Rodriguez**  
[GitHub](https://github.com/luiggiroal)
