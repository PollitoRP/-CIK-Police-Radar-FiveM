-- ==========================================================
--               CIK POLICE RADAR - CLIENT SCRIPT
-- ==========================================================

local isRadarOpen = false
local isRemoteOpen = false
local hasJobPermission = true

local frontActive = true
local rearActive = true
local frontLocked = false
local rearLocked = false

local speedUnit = Config.SpeedUnit or 'KMH'
local fastLimit = Config.DefaultFastLimit or 120
local audioEnabled = (Config.Features and Config.Features.EnableSoundBeep ~= nil) and Config.Features.EnableSoundBeep or true

-- Datos guardados / bloqueados
local lockedFrontData = nil
local lockedRearData = nil
local highestFrontSpeed = 0
local highestRearSpeed = 0

-- Inicialización de Framework
CreateThread(function()
    if Config.Framework == 'esx' then
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Wait(100)
        end
        checkJobPermission()
    elseif Config.Framework == 'qbcore' then
        QBCore = exports['qb-core']:GetCoreObject()
        checkJobPermission()
    else
        hasJobPermission = true
    end
end)

-- Comprobación de trabajo (Job)
function checkJobPermission()
    if not Config.RequirePoliceJob then
        hasJobPermission = true
        return
    end

    if Config.Framework == 'esx' then
        local playerData = ESX.GetPlayerData()
        if playerData and playerData.job then
            for _, job in ipairs(Config.PoliceJobs) do
                if playerData.job.name == job then
                    hasJobPermission = true
                    return
                end
            end
        end
    elseif Config.Framework == 'qbcore' then
        local player = QBCore.Functions.GetPlayerData()
        if player and player.job then
            for _, job in ipairs(Config.PoliceJobs) do
                if player.job.name == job then
                    hasJobPermission = true
                    return
                end
            end
        end
    end

    hasJobPermission = false
end

-- Eventos de cambio de trabajo
RegisterNetEvent('esx:setJob', function(job)
    checkJobPermission()
    if not hasJobPermission and isRadarOpen then
        ToggleRadar(false)
    end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    checkJobPermission()
    if not hasJobPermission and isRadarOpen then
        ToggleRadar(false)
    end
end)

-- Notificaciones en pantalla
function Notify(text)
    if Config.NotificationType == 'chat' then
        TriggerEvent('chat:addMessage', {
            color = { 0, 150, 255 },
            multiline = true,
            args = { "[RADAR]", text }
        })
    else
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandThefeedPostTicker(false, true)
    end
end

-- Función para verificar si el vehículo actual es apto para radar
function IsVehicleAllowed(veh)
    if not DoesEntityExist(veh) then return false end

    -- Restricción por modelos explícitos
    if Config.AllowedVehicles and #Config.AllowedVehicles > 0 then
        local model = GetEntityModel(veh)
        for _, allowed in ipairs(Config.AllowedVehicles) do
            if model == GetHashKey(allowed) then
                return true
            end
        end
        return false
    end

    -- Restricción por vehículo de emergencia
    if Config.OnlyEmergencyVehicles then
        local class = GetVehicleClass(veh)
        return class == 18 -- Clase Emergency
    end

    return true
end

-- Función para verificar si el asiento actual del jugador está permitido
function IsSeatAllowed(ped, veh)
    local allowedMode = Config.AllowedSeats or 'all'
    if allowedMode == 'all' then
        return true
    end

    local isDriver = (GetPedInVehicleSeat(veh, -1) == ped)
    local isCopilot = (GetPedInVehicleSeat(veh, 0) == ped)

    if allowedMode == 'copilot' then
        return isCopilot
    elseif allowedMode == 'driver' then
        return isDriver
    elseif allowedMode == 'front' then
        return isDriver or isCopilot
    end

    return true
end

-- Abrir / Cerrar Radar
function ToggleRadar(forceState)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)

    if forceState == nil then
        forceState = not isRadarOpen
    end

    if forceState then
        if not IsPedInAnyVehicle(ped, false) then
            Notify(_U('not_in_veh'))
            return
        end

        if not IsVehicleAllowed(veh) then
            Notify(_U('not_police_veh'))
            return
        end

        if not IsSeatAllowed(ped, veh) then
            Notify(_U('seat_not_allowed'))
            return
        end

        if Config.RequirePoliceJob and not hasJobPermission then
            Notify(_U('no_permission'))
            return
        end

        isRadarOpen = true
        SendNUIMessage({
            action = 'openRadar',
            features = Config.Features,
            speedUnit = speedUnit,
            fastLimit = fastLimit,
            theme = Config.Theme or 'modern_hud'
        })
    else
        isRadarOpen = false
        if isRemoteOpen then
            ToggleRemote(false)
        end
        SendNUIMessage({ action = 'closeRadar' })
    end
end

-- Abrir / Cerrar Control Remoto
function ToggleRemote(forceState)
    if not isRadarOpen then return end

    if forceState == nil then
        forceState = not isRemoteOpen
    end

    isRemoteOpen = forceState
    SetNuiFocus(isRemoteOpen, isRemoteOpen)

    if isRemoteOpen then
        SendNUIMessage({ action = 'openRemote' })
    else
        SendNUIMessage({ action = 'closeRemote' })
    end
end

-- ==========================================================
--       ALGORITMO PRECISO DE ESCANEO DE VEHÍCULOS
-- ==========================================================

function ScanVehicles(playerVeh)
    local pCoords = GetEntityCoords(playerVeh)
    local pForward = GetEntityForwardVector(playerVeh)
    local coneCos = math.cos(math.rad(Config.ScanConeAngle or 35.0))
    local maxDist = Config.MaxScanDistance or 55.0

    local frontTarget = nil
    local frontMinDist = maxDist + 1.0

    local rearTarget = nil
    local rearMinDist = maxDist + 1.0

    local vehicles = GetGamePool('CVehicle')

    for _, veh in ipairs(vehicles) do
        if veh ~= playerVeh and DoesEntityExist(veh) and not IsEntityDead(veh) then
            local vCoords = GetEntityCoords(veh)
            local toTarget = vCoords - pCoords
            local dist = #(toTarget)

            if dist <= maxDist and dist > 1.5 then
                local dirNorm = toTarget / dist
                local dot = (pForward.x * dirNorm.x) + (pForward.y * dirNorm.y) + (pForward.z * dirNorm.z)

                -- Delantero (dot positivo dentro del cono)
                if frontActive and dot >= coneCos and dist < frontMinDist then
                    if HasEntityClearLosToEntity(playerVeh, veh, 17) then
                        frontTarget = veh
                        frontMinDist = dist
                    end
                -- Trasero (dot negativo dentro del cono trasero)
                elseif rearActive and dot <= -coneCos and dist < rearMinDist then
                    if HasEntityClearLosToEntity(playerVeh, veh, 17) then
                        rearTarget = veh
                        rearMinDist = dist
                    end
                end
            end
        end
    end

    return frontTarget, rearTarget
end

-- Extraer datos del vehículo detectado
function GetVehicleRadarData(targetVeh, playerVeh)
    if not targetVeh or not DoesEntityExist(targetVeh) then return nil end

    local speedMultiplier = (speedUnit == 'KMH') and 3.6 or 2.236936
    local currentSpeed = math.floor(GetEntitySpeed(targetVeh) * speedMultiplier)

    -- Matrícula limpia
    local rawPlate = GetVehicleNumberPlateText(targetVeh) or ""
    local plate = string.gsub(rawPlate, '^%s*(.-)%s*$', '%1')

    -- Modelo
    local modelHash = GetEntityModel(targetVeh)
    local modelName = GetDisplayNameFromVehicleModel(modelHash)
    local label = GetLabelText(modelName)
    if label == "NULL" or label == "" or not label then
        label = modelName
    end

    -- Sentido (Mismo o Contrario)
    local pHeading = GetEntityHeading(playerVeh)
    local tHeading = GetEntityHeading(targetVeh)
    local diff = math.abs(pHeading - tHeading)
    if diff > 180.0 then diff = 360.0 - diff end

    local dir = (diff < 65.0) and 'SAME' or 'OPP'

    return {
        speed = currentSpeed,
        plate = plate,
        model = label,
        direction = dir
    }
end

-- ==========================================================
--                  BUCLE PRINCIPAL DEL RADAR
-- ==========================================================

CreateThread(function()
    while true do
        local sleep = 500

        if isRadarOpen then
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)

            if not veh or veh == 0 or not DoesEntityExist(veh) then
                if Config.Features.HideRadarWhenOutOfVehicle then
                    ToggleRadar(false)
                end
            elseif not IsSeatAllowed(ped, veh) then
                ToggleRadar(false)
            else
                sleep = Config.ScanInterval or 100
                local speedMultiplier = (speedUnit == 'KMH') and 3.6 or 2.236936
                local patrolSpeed = math.floor(GetEntitySpeed(veh) * speedMultiplier)

                -- Escaneo de objetivos
                local frontVeh, rearVeh = ScanVehicles(veh)

                -- Antena Delantera
                local frontPayload = {
                    active = frontActive,
                    locked = frontLocked,
                    hasTarget = false
                }

                if frontLocked and lockedFrontData then
                    frontPayload.hasTarget = true
                    frontPayload.targetSpeed = lockedFrontData.speed
                    frontPayload.fastSpeed = highestFrontSpeed
                    frontPayload.plate = lockedFrontData.plate
                    frontPayload.model = lockedFrontData.model
                    frontPayload.direction = lockedFrontData.direction
                    frontPayload.isOverSpeed = (lockedFrontData.speed >= fastLimit)
                elseif frontActive and frontVeh then
                    local data = GetVehicleRadarData(frontVeh, veh)
                    if data then
                        frontPayload.hasTarget = true
                        frontPayload.targetSpeed = data.speed
                        if data.speed > highestFrontSpeed then highestFrontSpeed = data.speed end
                        frontPayload.fastSpeed = highestFrontSpeed
                        frontPayload.plate = data.plate
                        frontPayload.model = data.model
                        frontPayload.direction = data.direction
                        frontPayload.isOverSpeed = (data.speed >= fastLimit)

                        -- Auto bloqueo si supera el límite rápido
                        if Config.Features.AutoLockOnOverSpeed and not frontLocked and data.speed >= fastLimit then
                            frontLocked = true
                            lockedFrontData = data
                            if Config.Features.EnableLockSound and audioEnabled then
                                SendNUIMessage({ action = 'playSound', sound = 'lock' })
                            end
                        end

                        -- Alerta sonora
                        if frontPayload.isOverSpeed and Config.Features.EnableFastAlertSound and audioEnabled then
                            SendNUIMessage({ action = 'playSound', sound = 'fast_alert' })
                        end
                    end
                end

                -- Antena Trasera
                local rearPayload = {
                    active = rearActive,
                    locked = rearLocked,
                    hasTarget = false
                }

                if rearLocked and lockedRearData then
                    rearPayload.hasTarget = true
                    rearPayload.targetSpeed = lockedRearData.speed
                    rearPayload.fastSpeed = highestRearSpeed
                    rearPayload.plate = lockedRearData.plate
                    rearPayload.model = lockedRearData.model
                    rearPayload.direction = lockedRearData.direction
                    rearPayload.isOverSpeed = (lockedRearData.speed >= fastLimit)
                elseif rearActive and rearVeh then
                    local data = GetVehicleRadarData(rearVeh, veh)
                    if data then
                        rearPayload.hasTarget = true
                        rearPayload.targetSpeed = data.speed
                        if data.speed > highestRearSpeed then highestRearSpeed = data.speed end
                        rearPayload.fastSpeed = highestRearSpeed
                        rearPayload.plate = data.plate
                        rearPayload.model = data.model
                        rearPayload.direction = data.direction
                        rearPayload.isOverSpeed = (data.speed >= fastLimit)

                        if Config.Features.AutoLockOnOverSpeed and not rearLocked and data.speed >= fastLimit then
                            rearLocked = true
                            lockedRearData = data
                            if Config.Features.EnableLockSound and audioEnabled then
                                SendNUIMessage({ action = 'playSound', sound = 'lock' })
                            end
                        end

                        if rearPayload.isOverSpeed and Config.Features.EnableFastAlertSound and audioEnabled then
                            SendNUIMessage({ action = 'playSound', sound = 'fast_alert' })
                        end
                    end
                end

                -- Enviar actualización al NUI
                SendNUIMessage({
                    action = 'updateRadarData',
                    patrolSpeed = patrolSpeed,
                    front = frontPayload,
                    rear = rearPayload
                })
            end
        end

        Wait(sleep)
    end
end)

-- Auto abrir al subir al coche si está activado
if Config.Features.AutoOpenOnVehicleEnter then
    CreateThread(function()
        local wasInVehicle = false
        while true do
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)
            local inVeh = (veh and veh ~= 0)

            if inVeh and not wasInVehicle then
                if IsVehicleAllowed(veh) and IsSeatAllowed(ped, veh) and (not Config.RequirePoliceJob or hasJobPermission) then
                    ToggleRadar(true)
                end
            end
            wasInVehicle = inVeh
            Wait(1000)
        end
    end)
end

-- ==========================================================
--                  COMANDOS Y ASIGNACIÓN DE TECLAS
-- ==========================================================

RegisterCommand(Config.Commands.ToggleRadar, function()
    ToggleRadar()
end, false)
RegisterKeyMapping(Config.Commands.ToggleRadar, 'Encender / Apagar Radar Policial', 'keyboard', Config.DefaultKeys.ToggleRadar)

RegisterCommand(Config.Commands.ToggleRemote, function()
    if isRadarOpen and Config.Features.EnableRemoteControl then
        ToggleRemote()
    end
end, false)
RegisterKeyMapping(Config.Commands.ToggleRemote, 'Abrir Control Remoto del Radar', 'keyboard', Config.DefaultKeys.ToggleRemote)

RegisterCommand(Config.Commands.LockFront, function()
    if not isRadarOpen or not Config.Features.EnableLockSystem then return end
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if not veh or veh == 0 then return end

    if frontLocked then
        frontLocked = false
        lockedFrontData = nil
        highestFrontSpeed = 0
    else
        local frontVeh, _ = ScanVehicles(veh)
        if frontVeh then
            local data = GetVehicleRadarData(frontVeh, veh)
            if data then
                frontLocked = true
                lockedFrontData = data
                highestFrontSpeed = data.speed
                if Config.Features.EnableLockSound and audioEnabled then
                    SendNUIMessage({ action = 'playSound', sound = 'lock' })
                end
                Notify(_U('front_locked_notify'))
            end
        end
    end
end, false)
RegisterKeyMapping(Config.Commands.LockFront, 'Fijar / Bloquear Radar Delantero', 'keyboard', Config.DefaultKeys.LockFront)

RegisterCommand(Config.Commands.LockRear, function()
    if not isRadarOpen or not Config.Features.EnableLockSystem then return end
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if not veh or veh == 0 then return end

    if rearLocked then
        rearLocked = false
        lockedRearData = nil
        highestRearSpeed = 0
    else
        local _, rearVeh = ScanVehicles(veh)
        if rearVeh then
            local data = GetVehicleRadarData(rearVeh, veh)
            if data then
                rearLocked = true
                lockedRearData = data
                highestRearSpeed = data.speed
                if Config.Features.EnableLockSound and audioEnabled then
                    SendNUIMessage({ action = 'playSound', sound = 'lock' })
                end
                Notify(_U('rear_locked_notify'))
            end
        end
    end
end, false)
RegisterKeyMapping(Config.Commands.LockRear, 'Fijar / Bloquear Radar Trasero', 'keyboard', Config.DefaultKeys.LockRear)

RegisterCommand(Config.Commands.UnlockAll, function()
    if not isRadarOpen then return end
    frontLocked = false
    rearLocked = false
    lockedFrontData = nil
    lockedRearData = nil
    highestFrontSpeed = 0
    highestRearSpeed = 0
    Notify(_U('unlocked_notify'))
end, false)
RegisterKeyMapping(Config.Commands.UnlockAll, 'Desbloquear Radares Policiales', 'keyboard', Config.DefaultKeys.UnlockAll)

-- ==========================================================
--                    NUI CALLBACKS
-- ==========================================================

RegisterNUICallback('closeRemote', function(data, cb)
    ToggleRemote(false)
    cb('ok')
end)

RegisterNUICallback('openRemoteFromUI', function(data, cb)
    if Config.Features.EnableRemoteControl then
        ToggleRemote(true)
    end
    cb('ok')
end)

RegisterNUICallback('toggleFrontAntenna', function(data, cb)
    frontActive = not frontActive
    if not frontActive then
        frontLocked = false
        lockedFrontData = nil
    end
    cb('ok')
end)

RegisterNUICallback('toggleRearAntenna', function(data, cb)
    rearActive = not rearActive
    if not rearActive then
        rearLocked = false
        lockedRearData = nil
    end
    cb('ok')
end)

RegisterNUICallback('lockFront', function(data, cb)
    ExecuteCommand(Config.Commands.LockFront)
    cb('ok')
end)

RegisterNUICallback('lockRear', function(data, cb)
    ExecuteCommand(Config.Commands.LockRear)
    cb('ok')
end)

RegisterNUICallback('unlockAll', function(data, cb)
    ExecuteCommand(Config.Commands.UnlockAll)
    cb('ok')
end)

RegisterNUICallback('changeSpeedUnit', function(data, cb)
    speedUnit = data.unit or 'KMH'
    cb('ok')
end)

RegisterNUICallback('toggleAudio', function(data, cb)
    audioEnabled = data.enabled
    cb('ok')
end)

RegisterNUICallback('setFastLimit', function(data, cb)
    if data.limit then
        fastLimit = tonumber(data.limit)
    end
    cb('ok')
end)

RegisterNUICallback('changeTheme', function(data, cb)
    if data.theme then
        Config.Theme = data.theme
    end
    cb('ok')
end)

