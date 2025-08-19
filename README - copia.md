# Adobe Patcher Utility

Una potente y amigable utilidad de PowerShell para gestionar la conectividad y los parches a nivel de sistema de las aplicaciones de Adobe. Esta herramienta proporciona una interfaz de consola clara para aplicar modificaciones comunes de forma segura y reversible.

<!-- Badges -->
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/Pablitus666/Info-RAM?style=flat-square)](https://github.com/Pablitus666/Info-RAM/releases)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg?style=flat-square)](LICENSE) <!-- Assuming a LICENSE file will be added or it's just a statement -->

![Social Preview](images/socialpreview.png)

## Descargo de Responsabilidad (Disclaimer)

Esta herramienta está destinada únicamente a fines educativos y administrativos. Modifica archivos de sistema como el archivo `hosts`, reglas del firewall y carpetas del sistema. Úsala bajo tu propio riesgo. El autor no se hace responsable de ningún daño en tu sistema. Asegúrate siempre de tener una copia de seguridad de tus datos importantes.

## ✨ Características

- **Gestión de Procesos:** Detiene rápidamente todos los procesos y servicios de Adobe en ejecución.
- **Bloqueo por Archivo Hosts:** Añade o elimina automáticamente los dominios de los servidores de Adobe en tu archivo `hosts` para bloquear las conexiones de red.
- **Control del Firewall:** Crea o elimina reglas en el Firewall de Windows para impedir que ejecutables específicos de Adobe accedan a internet.
- **Parches del Sistema:**
    - **Desactivador de Adobe Genuine Service (AGS):** Desactiva de forma segura el servicio AGS renombrando y bloqueando su directorio.
    - **Ocultador de la Carpeta de Creative Cloud:** Oculta la carpeta "Creative Cloud Files" del panel de navegación del Explorador de Archivos.
- **Acciones Reversibles:** Todos los parches y modificaciones se pueden deshacer fácilmente desde el menú.
- **Interfaz de Usuario Amigable:** Una interfaz de usuario basada en texto (TUI) limpia e intuitiva para una fácil operación.
- **Elevación Automática de Privilegios:** El script solicita automáticamente los permisos de administrador necesarios para funcionar.

## 📷 Capturas de pantalla

<p align="center">
  <img src="images/screenshot.png?v=2" alt="Vista previa de la aplicación" width="600"/>
</p>

Pantalla principal de Parche mostrando su menú. 

## 🖥️ ¿Cómo se usa?

1.  Descarga o clona este repositorio.
2.  Navega a la carpeta del proyecto `Proyecto Parche`.
3.  Simplemente haz doble clic en el archivo `Parche.bat`. El script solicitará automáticamente los permisos de administrador.
4.  Usa las teclas numéricas para navegar por el menú y aplicar o eliminar los parches según necesites.

## 👨‍💻 Créditos

- **Creador y Mantenedor:** Pablitus

Este proyecto es un esfuerzo comunitario. ¡Gracias a todos los que lo prueban, lo apoyan y reportan errores!
