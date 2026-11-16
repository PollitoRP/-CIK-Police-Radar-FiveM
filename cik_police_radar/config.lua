Config = {}

-- ==========================================================
--                  CONFIGURACIÓN GENERAL
-- ==========================================================

-- Idioma del script: 'es' (Español) o 'en' (Inglés)
Config.Locale = 'es'

-- Unidad de medida de velocidad: 'KMH' o 'MPH'
Config.SpeedUnit = 'KMH'

-- Límite de velocidad rápida por defecto (Alerta de exceso de velocidad)
-- Si un vehículo detectado supera este límite, parpadeará en rojo y emitirá una alerta sonora.
Config.DefaultFastLimit = 120

-- ==========================================================
--             COMPATIBILIDAD Y FRAMEWORKS
-- ==========================================================

-- Framework a usar: 'standalone' (Sin dependencias), 'esx' o 'qbcore'
-- En 'standalone' funcionará en cualquier servidor de FiveM sin necesidad de ESX o QBCore.
Config.Framework = 'standalone'

-- ¿Requiere tener trabajo de policía para usar el radar?
-- Si es false, cualquier jugador (o según los vehículos permitidos) podrá abrir el radar.
Config.RequirePoliceJob = false

-- Trabajos policiales autorizados (Solo si RequirePoliceJob = true y usas ESX o QBCore)
Config.PoliceJobs = {
    'police',
    'sheriff',
    'state',
    'trooper',
    'guardia',
    'cnp',
    'guardiacivil'
}

-- ==========================================================
--              RESTRICCIONES DE VEHÍCULOS
-- ==========================================================

-- ¿Solo permitir abrir el radar en vehículos de emergencia (clase policial / ambulancia)?
-- true = Solo coches con sirena/policía (Clase 18 en GTA V)
-- false = Se puede usar en cualquier vehículo
Config.OnlyEmergencyVehicles = true

-- Lista de modelos de vehículos autorizados específicos (dejar vacío {} para admitir todos los coches de policía)
-- Ejemplo: Config.AllowedVehicles = { 'police', 'police2', 'police3', 'sheriff' }
Config.AllowedVehicles = {}

-- ==========================================================
--              PERMISOS POR ASIENTO EN EL COCHE
-- ==========================================================

-- ¿Quién puede usar el radar dentro del vehículo policial?
-- Opciones disponibles:
--   'all'      -> TODOS los ocupantes del vehículo pueden usarlo.
--   'copilot'  -> ÚNICAMENTE el COPILOTO (asiento delantero del acompañante).
--   'driver'   -> ÚNICAMENTE el CONDUCTOR.
--   'front'    -> Tanto el CONDUCTOR como el COPILOTO (asientos delanteros).
Config.AllowedSeats = 'all'

-- ==========================================================
--       INTERRUPTORES DE FUNCIONES (ACTIVAR / DESACTIVAR)
--    ¡Aquí puedes quitar o poner TODAS las opciones del script!
-- ==========================================================

Config.Features = {
    -- Antena delantera: Detección de coches que van delante de ti
    EnableFrontRadar = true,

    -- Antena trasera: Detección de coches que van detrás de ti
    EnableRearRadar = true,

    -- Mostrar la matrícula del coche detectado
    ShowVehiclePlate = true,

    -- Mostrar el nombre / modelo del vehículo detectado (ej: VAPID STANIER, SULTAN, etc.)
    ShowVehicleModel = true,

    -- Mostrar la velocidad propia de tu patrulla
    ShowPatrolSpeed = true,

    -- Mostrar la velocidad del objetivo detectado
    ShowTargetSpeed = true,

    -- Mostrar la velocidad máxima alcanzada (FAST)
    ShowFastSpeed = true,

    -- Mostrar flechas indicadoras de dirección (Mismo sentido ▲ / Sentido contrario ▼)
    ShowDirectionArrow = true,

    -- Sistema de bloqueo / congelado de radar (Permite congelar la lectura del coche con una tecla)
    EnableLockSystem = true,

    -- Bloqueo automático cuando un coche supere el límite rápido (Auto-Lock)
    AutoLockOnOverSpeed = false,

    -- Efectos de sonido: Beep continuo al detectar/escanear
    EnableSoundBeep = true,

    -- Efectos de sonido: Sonido al bloquear/fijar un vehículo
    EnableLockSound = true,

    -- Efectos de sonido: Alarma cuando un coche supera la velocidad rápida (Fast Alert)
    EnableFastAlertSound = true,

    -- Control Remoto interactivo (permite abrir un mando en pantalla para cambiar opciones con ratón)
    EnableRemoteControl = true,

    -- Permitir arrastrar el radar por la pantalla con el ratón y moverlo donde quieras
    EnableDraggableUI = true,

    -- Guardar la posición del radar en pantalla automáticamente (para que no vuelva al inicio al reconectar)
    SavePosition = true,

    -- Ocultar el radar automáticamente si el oficial se baja del vehículo
    HideRadarWhenOutOfVehicle = true,

    -- Abrir el radar automáticamente en cuanto te subes a un coche policial autorizado
    AutoOpenOnVehicleEnter = false
}

-- ==========================================================
--              PARÁMETROS DE ESCANEO DEL RADAR
-- ==========================================================

-- Distancia máxima en metros a la que el radar detecta vehículos (Recomendado entre 40.0 y 70.0)
Config.MaxScanDistance = 55.0

-- Ángulo del cono de visión del radar en grados (Recomendado entre 25.0 y 45.0)
Config.ScanConeAngle = 35.0

-- Intervalo de actualización del escáner en milisegundos (ms)
-- 100ms = 10 veces por segundo (muy fluido y casi 0 impacto de rendimiento)
Config.ScanInterval = 100

-- ==========================================================
--                 COMANDOS Y TECLAS POR DEFECTO
--  (Los jugadores pueden cambiarlas en Ajustes -> Asignación de teclas -> FiveM)
-- ==========================================================

Config.Commands = {
    ToggleRadar = 'radar',           -- Comando para abrir/cerrar el radar (/radar)
    ToggleRemote = 'radarrc',        -- Comando para abrir el control remoto (/radarrc)
    LockFront = 'radar_lockfront',   -- Comando para bloquear antena delantera
    LockRear = 'radar_lockrear',     -- Comando para bloquear antena trasera
    UnlockAll = 'radar_unlock'       -- Comando para desbloquear ambas antenas
}

Config.DefaultKeys = {
    ToggleRadar = 'F5',              -- Tecla para encender/apagar el radar
    ToggleRemote = 'F6',             -- Tecla para abrir el mando/control remoto interactivo
    LockFront = 'NUMPAD8',           -- Tecla para bloquear vehículo delantero
    LockRear = 'NUMPAD2',            -- Tecla para bloquear vehículo trasero
    UnlockAll = 'NUMPAD5'            -- Tecla para desbloquear todo
}

-- ==========================================================
--                     NOTIFICACIONES
-- ==========================================================

-- Tipo de notificación: 'chat', 'native' (GTA V Feed) o 'custom'
Config.NotificationType = 'native'

-- Función auxiliar para obtener textos de traducción
function _U(entry)
    local lang = Config.Locale or 'es'
    if Locales and Locales[lang] and Locales[lang][entry] then
        return Locales[lang][entry]
    elseif Locales and Locales['en'] and Locales['en'][entry] then
        return Locales['en'][entry]
    end
    return entry
end

