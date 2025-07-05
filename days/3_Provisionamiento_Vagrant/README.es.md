# 🛠️ Provisionamiento DevOps con Vagrant

**[English Version](./README.md)**

<hr>

Este proyecto demuestra cómo automatizar la configuración de un entorno de desarrollo utilizando **Vagrant** y scripts en **Bash**. Se muestra cómo levantar una máquina virtual (VM), instalar servicios esenciales y servir un sitio web usando Nginx.

## 🚀 ¿Qué hace?

Al ejecutar `vagrant up`, el proyecto:

1. **Crea una máquina virtual** usando la box base de Ubuntu `focal64`.
2. **Instala y configura**:
   - **Nginx**: Instala y habilita el servidor web.
   - **Docker**: Instala Docker para manejo de contenedores.
   - **Node.js** y **npm**: Usados para construir los archivos frontend.
   - **kubectl**: Instala la CLI de Kubernetes.
3. **Clona un sitio con Bootstrap**:
   - Clona [`startbootstrap-freelancer`](https://github.com/StartBootstrap/startbootstrap-freelancer).
   - Compila el proyecto con `npm`.
   - Sirve el archivo `index.html` generado mediante Nginx en `http://localhost:8081`.

## 🧱 Estructura del Proyecto

```
.
├── Vagrantfile
├── README.md
├── scripts/
│   ├── install.sh              # Script principal de provisionamiento
│   ├── nginx_install.sh        # Instalación y configuración de Nginx
│   ├── docker_install.sh       # Instalación de Docker y kubectl
│   ├── node_install.sh         # Instalación de Node.js y npm
│   └── serve_bootstrap.sh      # Clonado y despliegue del sitio Bootstrap
```

## 🖥️ ¿Cómo usarlo?

### 1. Clona este repositorio:

```bash
git clone https://github.com/tuusuario/tu-repo.git
cd tu-repo
```

### 2. Levanta la VM

```bash
vagrant up
```

La máquina se iniciará, se configurará automáticamente con los scripts, y servirá un sitio web en:

📍 **http://localhost:8081**

> Puedes apagarla con `vagrant halt` y volver a provisionar con `vagrant provision`.

---

## 📓 Habilidades Prácticas

- Escritura de scripts **Bash** modulares
- Creación de entornos con **Vagrant**
- Uso de **systemctl**, **curl** y validación de comandos
- Automatización de instalaciones y gestión de servicios
- Uso de **npm** para construir proyectos frontend
- Despliegue de contenido estático con **Nginx**

---

## 🧠 Notas

- Este proyecto ha sido probado con **Ubuntu 20.04 (focal64)**.
- Todos los scripts están ubicados en la carpeta `/scripts`.
- La VM tiene una IP privada `192.168.33.10` y acceso port-forwarded vía `localhost:8081`.

---

## 🔧 Resolución de Problemas

### ❗ Nginx o Docker están inactivos

Asegúrate de que los servicios estén instalados y habilitados:

```bash
sudo systemctl status nginx
sudo systemctl status docker
```

Si están inactivos:

```bash
sudo systemctl enable --now nginx
sudo systemctl enable --now docker
```

### ❗ Error de `globalThis is not defined` al compilar con npm

Puede deberse a una versión antigua de Node.js. Verifica con:

```bash
node --version
```

Si es menor a `12`, actualiza Node.js:

```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

### ❗ El puerto 8081 no funciona

- Verifica que el puerto 8081 no esté bloqueado en tu máquina host.
- Asegúrate de que Nginx esté corriendo dentro de la VM.
- También puedes intentar acceder desde: `http://192.168.33.10`.

### ❗ Los cambios no se reflejan

Si modificaste los scripts pero no ves cambios:

```bash
vagrant reload --provision
```

---

## 🙌 Autor

**Luiggi Rodriguez**  
[GitHub](https://github.com/luiggiroal)
