# -CIK-Police-Radar-FiveM
🚔 CIK Police Radar — FiveM  Un sistema de radar policial dual (antena delantera y trasera) para servidores de FiveM, diseñado con un panel digital interactivo (NUI), escáner de matrículas, detección de modelo de vehículo y control remoto.  Compatible tanto de forma Standalone (sin frameworks) como con ESX y QBCore.




📸 Vista General y Funciones
📡 Doble antena independiente:
Frontal: Escanea e identifica los vehículos que persigues o que circulan delante de la patrulla.
Trasera: Escanea los vehículos que se aproximan o circulan detrás.
📋 Lectura completa de datos del vehículo:
Matrícula exacta con marco estilizado.
Nombre del modelo (ejemplo: Stanier, Buffalo, Sultan).
Velocidad actual en tiempo real (KM/H o MPH).
Velocidad máxima registrada durante la persecución (FAST).
Indicador de sentido de marcha: mismo sentido (▲) o sentido contrario (▼).
🔒 Sistema de bloqueo (Lock):
Permite congelar los datos de un infractor con una sola tecla para conservar la matrícula y la velocidad como prueba.
Opción de bloqueo automático si el vehículo supera el límite configurado.
🎮 Control remoto interactivo:
Mando emergente en pantalla para manejar antenas, cambiar unidades de velocidad, activar/desactivar audio o ajustar límites con el ratón.
🖱️ Interfaz arrastrable y personalizable:
Haz clic y mueve el radar a la posición de la pantalla que prefieras. La posición se memoriza automáticamente.
🔊 Efectos de sonido:
Tonos de escaneo, alerta de exceso de velocidad y sonido de fijación generados en tiempo real sin requerir archivos de sonido externos.
💺 Control de asientos:
Permite restringir el uso del radar a toda la patrulla, únicamente al copiloto, al conductor o a los dos asientos delanteros.
⌨️ Controles por Defecto

Los oficiales pueden personalizar todas las teclas desde:
ESC → Ajustes → Asignación de teclas → FiveM

Acción	Comando	Tecla predeterminada
Encender / Apagar Radar	/radar	F5
Abrir Control Remoto (Ratón)	/radarrc	F6
Fijar / Desfijar Objetivo Delantero	/radar_lockfront	NUMPAD 8
Fijar / Desfijar Objetivo Trasero	/radar_lockrear	NUMPAD 2
Desbloquear Todas las Antenas	/radar_unlock	NUMPAD 5
⚙️ Configuración (config.lua)

📥 Instalación
Descarga el repositorio o haz un clon dentro de la carpeta resources de tu servidor:
bash
resources/[scripts]/cik_police_radar
Añade la siguiente línea a tu archivo server.cfg:
cfg
ensure cik_police_radar
Reinicia el servidor o ejecuta en consola:
bash
refresh
ensure cik_police_radar
Sube a un vehículo policial y pulsa F5.
📌 Resumen de lo que aporta para GitHub:
Explica de un vistazo el propósito y características del proyecto.
Incluye la tabla de teclas para los jugadores.
Muestra el bloque de configuración para que otros desarrolladores sepan cómo adaptarlo.
Contiene los pasos de instalación estándar para FiveM.
