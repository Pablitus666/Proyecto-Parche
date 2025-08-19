## adobe-patcher v1.0 — Utilidad de Parcheo para Adobe

**adobe-patcher** es una potente y amigable utilidad de PowerShell diseñada para gestionar la conectividad y los parches a nivel de sistema de las aplicaciones de Adobe. Creada para ser intuitiva y segura, esta herramienta proporciona una interfaz de consola clara para aplicar y revertir modificaciones comunes de forma segura.

### ✨ Características Destacadas

*   **Gestión de Procesos:** Detiene rápidamente todos los procesos y servicios de Adobe en ejecución.
*   **Bloqueo por Archivo Hosts:** Añade o elimina automáticamente los dominios de los servidores de Adobe en tu archivo `hosts` para bloquear las conexiones de red.
*   **Control del Firewall:** Crea o elimina reglas en el Firewall de Windows para impedir que ejecutables específicos de Adobe accedan a internet.
*   **Parches del Sistema:**
    *   **Desactivador de Adobe Genuine Service (AGS):** Desactiva de forma segura el servicio AGS renombrando y bloqueando su directorio.
    *   **Ocultador de la Carpeta de Creative Cloud:** Oculta la carpeta "Creative Cloud Files" del panel de navegación del Explorador de Archivos.
*   **Acciones Reversibles:** Todos los parches y modificaciones se pueden deshacer fácilmente desde el menú.
*   **Interfaz de Usuario Amigable:** Una interfaz de usuario basada en texto (TUI) limpia e intuitiva para una fácil operación.
*   **Elevación Automática de Privilegios:** El script solicita automáticamente los permisos de administrador necesarios para funcionar.

### 🚀 Instrucciones de Uso

1.  Descargue el archivo `Proyecto.Parche.zip` que se encuentra más abajo en la sección de **Assets**.
2.  Descomprima el archivo `Proyecto.Parche.zip` en una carpeta de su elección.
3.  Ejecute el archivo `Parche.bat` que se encuentra dentro de la carpeta descomprimida.

### 🛡️ Descargo de Responsabilidad

Esta herramienta está destinada únicamente a fines educativos y administrativos. Modifica archivos de sistema como el archivo `hosts`, reglas del firewall y carpetas del sistema. Úsala bajo tu propio riesgo. El autor no se hace responsable de ningún daño en tu sistema. Asegúrate siempre de tener una copia de seguridad de tus datos importantes.