# 🚔 CIK Police Radar (`cik_police_radar`)

Un radar policial avanzado, moderno y ultra-optimizado para **FiveM (GTA V)** desarrollado completamente en **Lua 5.4**, HTML5, CSS3 y JavaScript (NUI).

Diseñado específicamente para permitir a los oficiales de policía escanear e identificar vehículos tanto **delante** como **detrás** de la patrulla en tiempo real.

---

## 🌟 Características Principales

- 📡 **Doble Antena Independiente**:
  - **Antena Delantera**: Detecta el vehículo que persigues o que va delante de ti.
  - **Antena Trasera**: Detecta el vehículo que te sigue o viene detrás.
- 🚗 **Detección Completa de Información del Vehículo**:
  - **Matrícula / Placa** exacta en tiempo real con diseño realista.
  - **Nombre y Modelo** del vehículo (ej: *Vapid Stanier, Sultan, Dominator*).
  - **Velocidad del Objetivo** (Target Speed) en **KM/H** o **MPH**.
  - **Velocidad Máxima** detectada (Fast Speed).
  - **Velocidad Propia** de la patrulla (Patrol Speed).
  - **Sentido de Marcha**: Indicador de si circula en tu **mismo sentido (▲)** o en **sentido contrario (▼)**.
- 🔒 **Sistema de Bloqueo / Fijación (Locking)**:
  - Permite congelar los datos de un vehículo sospechoso con una tecla rápida para guardar su matrícula y velocidad como evidencia.
  - Opción de **Auto-Lock**: Bloqueo automático cuando un infractor supera el límite de velocidad.
- 🔊 **Efectos de Sonido Sintéticos (Web Audio)**:
  - Beeps de escaneo, sonido de fijación de objetivo y alarma acústica de exceso de velocidad sin necesidad de archivos externos pesados.
- 📱 **Control Remoto Interactivo (Mando en Pantalla)**:
  - Abre un mando en pantalla pulsando `F6` o con `/radarrc` para cambiar ajustes con el ratón.
  - Permite encender/apagar antenas (`XMIT / HOLD`), fijar/desfijar vehículos, ajustar el límite de velocidad (`+ / -`), cambiar de KM/H a MPH o silenciar el audio.
- 🖱️ **Interfaz Arrastrable (Draggable UI)**:
  - Puedes arrastrar el radar a cualquier parte de tu pantalla con el ratón.
  - Guarda automáticamente la posición elegida en la memoria de tu FiveM (`localStorage`).
- ⚡ **Alto Rendimiento (0.00ms - 0.01ms)**:
  - Algoritmo de conos vectoriales optimizado (`GetGamePool`). Solo consume ciclos cuando estás dentro de un vehículo policial con el radar encendido.
- ⚙️ **Configuración Totalmente Modular**:
  - **Todas y cada una de las opciones del script se pueden activar o desactivar desde `config.lua`**.

---

## 📂 Estructura de Archivos

```
E:\cik_police_radar\
│
├── fxmanifest.lua        # Manifiesto del recurso para FiveM
├── config.lua            # Configuración de opciones, toggles y teclas
├── README.md             # Esta documentación
│
├── client\
│   └── main.lua          # Lógica del cliente, escáner vectorial y NUI callbacks
│
├── server\
│   └── main.lua          # Lógica del servidor y comprobaciones de permisos
│
├── locales\
│   ├── es.lua            # Traducciones en Español
│   └── en.lua            # Traducciones en Inglés
│
└── html\
    ├── index.html        # Estructura del radar y del mando a distancia
    ├── style.css         # Estilos visuales LED / OLED y animaciones
    └── script.js         # Lógica interactiva NUI, arrastre y audio sintético
```

---

## 🎮 Controles por Defecto

> *Nota: Cada jugador puede personalizar sus teclas dentro del juego en:*  
> **ESC -> Ajustes -> Asignación de teclas -> FiveM**.

| Acción | Comando | Tecla por Defecto |
|---|---|---|
| **Encender / Apagar Radar** | `/radar` | `F5` |
| **Abrir / Cerrar Mando Remoto** | `/radarrc` | `F6` |
| **Bloquear / Desbloquear Delantero** | `/radar_lockfront` | `NUMPAD 8` |
| **Bloquear / Desbloquear Trasero** | `/radar_lockrear` | `NUMPAD 2` |
| **Desbloquear Todos** | `/radar_unlock` | `NUMPAD 5` |

---

## ⚙️ Cómo Desactivar / Activar Opciones (`config.lua`)

En `config.lua` dispones de la tabla `Config.Features` donde puedes activar o quitar cualquier función:

```lua
Config.Features = {
    EnableFrontRadar           = true,  -- true/false: Activa o quita la antena delantera
    EnableRearRadar            = true,  -- true/false: Activa o quita la antena trasera
    ShowVehiclePlate           = true,  -- true/false: Muestra u oculta la matrícula
    ShowVehicleModel           = true,  -- true/false: Muestra u oculta el modelo del coche
    ShowPatrolSpeed            = true,  -- true/false: Muestra u oculta tu propia velocidad
    ShowTargetSpeed            = true,  -- true/false: Muestra u oculta la velocidad del objetivo
    ShowFastSpeed              = true,  -- true/false: Muestra u oculta la velocidad máxima (FAST)
    ShowDirectionArrow         = true,  -- true/false: Muestra flechas de sentido (Mismo / Contrario)
    EnableLockSystem           = true,  -- true/false: Permite congelar lecturas
    AutoLockOnOverSpeed        = false, -- true/false: Bloquea automáticamente si supera el límite
    EnableSoundBeep            = true,  -- true/false: Sonidos de radar
    EnableLockSound            = true,  -- true/false: Sonido al fijar vehículo
    EnableFastAlertSound       = true,  -- true/false: Alarma de exceso de velocidad
    EnableRemoteControl        = true,  -- true/false: Mando en pantalla con ratón
    EnableDraggableUI          = true,  -- true/false: Permite mover el radar con el ratón
    SavePosition               = true,  -- true/false: Recuerda la posición en pantalla
    HideRadarWhenOutOfVehicle  = true,  -- true/false: Se apaga al bajarte del coche
    AutoOpenOnVehicleEnter     = false  -- true/false: Se enciende solo al subirte a la patrulla
}
```

### Otras opciones configurables:
- `Config.AllowedSeats = 'all'` (`'all'` = todos los ocupantes, `'copilot'` = solo copiloto, `'driver'` = solo conductor, `'front'` = conductor y copiloto)
- `Config.SpeedUnit = 'KMH'` o `'MPH'`
- `Config.DefaultFastLimit = 120` (Límite en km/h o mph para activar alertas)
- `Config.Framework = 'standalone'` (`'standalone'`, `'esx'`, `'qbcore'`)
- `Config.RequirePoliceJob = false` (Pon `true` si solo la policía puede usarlo)
- `Config.OnlyEmergencyVehicles = true` (Solo vehículos con sirenas/policiales)
- `Config.MaxScanDistance = 55.0` (Metros de alcance de las antenas)

---

## 🚀 Instalación en tu Servidor

1. Copia o mueve la carpeta `cik_police_radar` a la carpeta `resources` de tu servidor FiveM (por ejemplo: `resources/[scripts]/cik_police_radar`).
2. Abre tu archivo `server.cfg`.
3. Añade la siguiente línea:
   ```cfg
   ensure cik_police_radar
   ```
4. Reinicia tu servidor o ejecuta en la consola:
   ```
   refresh
   ensure cik_police_radar
   ```
5. Súbete a cualquier vehículo policial dentro del servidor y pulsa **`F5`**.

