-- ==========================================================
--               CIK POLICE RADAR - SERVER SCRIPT
-- ==========================================================

print("^4[CIK_POLICE_RADAR]^7 Recurso iniciado correctamente.")
print("^4[CIK_POLICE_RADAR]^7 Modo: " .. tostring(Config.Framework) .. " | Idioma: " .. tostring(Config.Locale))

-- Verificación de permiso policial en el servidor (Opcional según framework)
RegisterNetEvent('cik_police_radar:server:checkPermission', function()
    local src = source
    local hasPerm = true

    if Config.RequirePoliceJob then
        hasPerm = false
        if Config.Framework == 'esx' then
            local ESX = exports['es_extended']:getSharedObject()
            local xPlayer = ESX.GetPlayerFromId(src)
            if xPlayer and xPlayer.job then
                for _, job in ipairs(Config.PoliceJobs) do
                    if xPlayer.job.name == job then
                        hasPerm = true
                        break
                    end
                end
            end
        elseif Config.Framework == 'qbcore' then
            local QBCore = exports['qb-core']:GetCoreObject()
            local Player = QBCore.Functions.GetPlayer(src)
            if Player and Player.PlayerData.job then
                for _, job in ipairs(Config.PoliceJobs) do
                    if Player.PlayerData.job.name == job then
                        hasPerm = true
                        break
                    end
                end
            end
        end
    end

    TriggerClientEvent('cik_police_radar:client:receivePermission', src, hasPerm)
end)

