# Script de Configuración de Apache y CGI para DevOps

**[English Version](./README.md)**

<hr>

Este repositorio contiene un script Bash (`apache_hello_world.sh`) diseñado para automatizar la configuración inicial de un servidor web Apache en un sistema Ubuntu, incluyendo la habilitación de CGI (Common Gateway Interface) y el despliegue de una página web dinámica "Hola Mundo" que muestra el tiempo de actividad del servidor utilizando un script CGI.

Este script es ideal para el aprovisionamiento rápido de un entorno de desarrollo o pruebas.

## 🚀 Características

- **Actualización y Mejora del Sistema:** Asegura que los paquetes del sistema estén actualizados.
- **Instalación de Apache:** Instala el servidor web Apache2.
- **Habilitación de CGI:** Activa el módulo CGI de Apache (`mod_cgi`) y configura el directorio `cgi-bin`.
- **Despliegue de Script CGI:** Crea un script Bash simple (`uptime.sh`) en `/usr/lib/cgi-bin` que muestra el tiempo de actividad del servidor.
- **Configuración del Firewall:** Abre el puerto 80 (HTTP) en UFW (Uncomplicated Firewall) para permitir el tráfico web.
- **Página Web Personalizada:** Despliega un nuevo `index.html` en `/var/www/html` que incluye JavaScript para obtener y mostrar el tiempo de actividad desde el script CGI.
- **Gestión de Permisos:** Establece correctamente la propiedad y los permisos para los archivos web desplegados (`index.html`) y el script CGI (`uptime.sh`).
- **Pasos de Verificación:** Incluye comandos para verificar el estado de Apache, las reglas de UFW y un comando `curl` para verificar el sitio web desplegado.

## 📋 Requisitos Previos

- Un sistema Linux basado en Ubuntu (probado en Ubuntu 20.04 LTS Focal Fossa).
- Privilegios `sudo` en el sistema.
- Conectividad básica a Internet para la descarga de paquetes.

**Nota:** Este script está destinado principalmente a ejecutarse dentro de una máquina virtual Vagrant o un entorno de desarrollo aislado similar.

## 💡 Cómo Funciona

El script realiza las siguientes acciones secuencialmente:

1.  Actualiza las listas de paquetes y actualiza los paquetes instalados.
2.  Instala el paquete `apache2`.
3.  Habilita el módulo `mod_cgi` de Apache y reinicia Apache.
4.  Crea el directorio `/usr/lib/cgi-bin` si no existe.
5.  Escribe un script Bash simple (`uptime.sh`) en el directorio `cgi-bin` y lo hace ejecutable (`chmod 777`).
6.  Habilita la configuración `serve-cgi-bin` de Apache y recarga Apache para aplicar los cambios.
7.  Agrega una regla de firewall UFW para permitir el tráfico entrante en el puerto TCP 80.
8.  Verifica el estado del servicio Apache2.
9.  Elimina la página `index.html` predeterminada de Apache.
10. Crea un nuevo `index.html` con contenido personalizado, incluyendo una sección de JavaScript para obtener el tiempo de actividad del servidor desde el script CGI.
11. Establece la propiedad de `index.html` a `www-data:www-data` (el usuario/grupo predeterminado de Apache).
12. Establece los permisos de archivo para `index.html` a `644` (lectura/escritura para el propietario, solo lectura para el grupo y otros).
13. Obtiene y muestra la dirección IP pública del sistema.
14. Realiza una solicitud `curl` al sitio web desplegado para verificar su accesibilidad.

## 🚀 Cómo Ejecutar el Script

1.  **Hacer el script ejecutable:**
    Debe dar permisos de ejecución al script.

    ```bash
    chmod +x apache_hello_world.sh
    ```

2.  **Ejecutar el script:**
    Ejecute el script con `sudo` porque realiza cambios a nivel del sistema (instalación de paquetes, reglas de firewall, propiedad de archivos, etc.).

    ```bash
    sudo ./apache_hello_world.sh
    ```

    El script imprimirá mensajes indicando su progreso. Es posible que se le solicite su contraseña de `sudo`.

## ✨ Después de Ejecutar el Script

Una vez que el script se complete con éxito:

1.  **Acceder al Servidor Web:**
    Debería poder acceder al servidor web Apache desde su navegador.

    - Si está ejecutando esto en una máquina virtual Vagrant con reenvío de puertos predeterminado (por ejemplo, del puerto 8080 del host al 80 del invitado), abra su navegador en su **máquina anfitriona** y vaya a:
      `http://localhost:8080`
    - Si su máquina virtual tiene una dirección IP privada (por ejemplo, `192.168.33.10`), abra su navegador en su **máquina anfitriona** y vaya a:
      `http://<IP_PRIVADA_VM>` (ej. `http://192.168.33.10`)
    - Si está ejecutando el navegador directamente en la VM, vaya a:
      `http://localhost`

2.  **Verificar Contenido:**
    Debería ver una página web con el título "¡DevOps en Acción!", un logotipo de Git, el encabezado "¡Hola Mundo DevOps!", una hora del servidor actualizada dinámicamente y el tiempo de actividad del servidor obtenido del script CGI.

3.  **Verificar el Script CGI Directamente (Opcional):**
    También puede acceder directamente al script CGI para ver su salida sin formato:
    `http://localhost/cgi-bin/uptime.sh` (ajuste `localhost` a la IP/puerto accesible de su VM si es necesario)

## 🐛 Solución de Problemas

- **"Permiso denegado" durante la ejecución del script:** Asegúrese de ejecutar el script con `sudo`: `sudo ./apache_hello_world.sh`.
- **El sitio web no carga (error del navegador):**
  - Verifique el estado de Apache: `sudo systemctl status apache2`.
  - Verifique las reglas de UFW: `sudo ufw status`. Asegúrese de que `80/tcp ALLOW Anywhere` esté en la lista.
  - Verifique los permisos y la propiedad de los archivos:
    `ls -l /var/www/html/index.html` (debe ser `www-data:www-data` y `rw-r--r--`)
    `ls -l /usr/lib/cgi-bin/uptime.sh` (debe ser ejecutable, por ejemplo, `rwxrwxrwx`)
- **El tiempo de actividad no se muestra o "Error cargando uptime.":**
  - Asegúrese de que `mod_cgi` esté habilitado: `sudo a2enmod cgi` seguido de `sudo systemctl restart apache2`.
  - Asegúrese de que `serve-cgi-bin` esté habilitado: `sudo a2enconf serve-cgi-bin` seguido de `sudo systemctl reload apache2`.
  - Verifique los permisos de `uptime.sh`: `sudo chmod 777 /usr/lib/cgi-bin/uptime.sh`.
  - Intente acceder al script CGI directamente en su navegador: `http://<IP_VM>/cgi-bin/uptime.sh`. Si eso funciona, podría haber un problema con la obtención de JavaScript en el lado de `index.html`.
- **Mensaje de Ubuntu Pro durante la actualización/mejora:** "The following security updates require Ubuntu Pro..." Esto es normal para Ubuntu 20.04 LTS. No impedirá que el script se ejecute ni que Apache se instale.
