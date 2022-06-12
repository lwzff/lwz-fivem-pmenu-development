-- Message en bas
function DrawSub(msg, time)
	ClearPrints()
	BeginTextCommandPrint('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandPrint(time, 1)
end

local sync = false
local WorkerChillPos = {}
local workzone = {}
local WorkerWorkingPos = {}
local Heading
local pedHash
AuTravailleJardinier = nil
local ArgentMin
local ArgentMax

RegisterNetEvent("RED_JOBS:JardinierAntiDump")
AddEventHandler("RED_JOBS:JardinierAntiDump", function(_config, _workzone, _WorkerChillPos, _WorkerWorkingPos)
    Heading = _config.Heading
    pedHash = _config.pedHash
    AuTravailleJardinier = _config.AuTravailleJardinier
    ArgentMin = _config.ArgentMin
    ArgentMax = _config.ArgentMax


    workzone = _workzone
    WorkerChillPos = _WorkerChillPos
    WorkerWorkingPos = _WorkerWorkingPos
    sync = true
end)

Citizen.CreateThread(function()
    while not sync do Wait(100) end
    LoadModel(pedHash)
    local ped = CreatePed(2, GetHashKey(pedHash), zone.Jardinier, Heading, 0, 0)
    DecorSetInt(ped, "Yay", 5431)
    FreezeEntityPosition(ped, 1)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, true)
    SetEntityInvincible(ped, true)
    SetEntityAsMissionEntity(ped, 1, 1)
    SetBlockingOfNonTemporaryEvents(ped, 1)


    for _,v in pairs(WorkerChillPos) do
        local ped = CreatePed(2, GetHashKey(pedHash), v.pos, v.Heading, 0, 0)
        DecorSetInt(ped, "Yay", 5431)
        FreezeEntityPosition(ped, 1)
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_AA_COFFEE", 0, true)
        SetEntityInvincible(ped, true)
        SetEntityAsMissionEntity(ped, 1, 1)
        SetBlockingOfNonTemporaryEvents(ped, 1)
    end

    for _,v in pairs(WorkerWorkingPos) do
        local ped = CreatePed(2, GetHashKey(pedHash), v.pos, v.Heading, 0, 0)
        DecorSetInt(ped, "Yay", 5431)
        FreezeEntityPosition(ped, 1)
        TaskStartScenarioInPlace(ped, v.scenario, 0, true)
        SetEntityInvincible(ped, true)
        SetEntityAsMissionEntity(ped, 1, 1)
        SetBlockingOfNonTemporaryEvents(ped, 1)
    end
end)

function StartTravailleJardinier()
    while not sync do Wait(100) end
    while AuTravailleJardinier do
		TriggerEvent('showNotify', '~b~INFORMATION\n~w~Rends-toi sur le terrain de golf et travailles bien.')
        Wait(1)
        local random = math.random(1,#workzone)
        local count = 1
        for k,v in pairs(workzone) do
            count = count + 1
            if count == random and AuTravailleJardinier then
                local EnAction = false
                local pPed = GetPlayerPed(-1)
                local pCoords = GetEntityCoords(pPed)
                local dstToMarker = GetDistanceBetweenCoords(v.pos, pCoords, true)
                local blip = AddBlipForCoord(v.pos)
                SetBlipSprite(blip, 649)
                SetBlipColour(blip, 2)
                SetBlipScale(blip, 0.5)
                while not EnAction and AuTravailleJardinier do
                    Citizen.Wait(1)
                    pCoords = GetEntityCoords(pPed)
                    dstToMarker = GetDistanceBetweenCoords(v.pos, pCoords, true)
                    DrawMarker(2, v.pos.x, v.pos.y, v.pos.z+0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 93, 182, 229, 200, 0, 0, 2, 1, nil, nil, 0)
                    local distance = GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), zone.Jardinier, true)
                    if distance <= 2.0 then
                        DrawSub("Appuyez sur ~b~E ~s~pour parler à la personne.", 1)
                        if IsControlJustPressed(1, 51) and distance <= 2.0 then
                            CreateMenu(menujardinier)
                            AuTravailleJardinier = false
                        end
                    end
                    local allow = false
                    if dstToMarker <= 3.0 and AuTravailleJardinier then 
                        if GetEntityModel(GetVehiclePedIsIn(GetPlayerPed(-1), true)) ~= 1783355638 then
							DrawSub("Tu te fous de moi, ton véhicule de fonction est où ?", 1)
                            allow = false
                        else
                            DrawSub("Appuyez sur ~b~E ~s~pour travailler.", 1)
                            allow = true
                        end
                        if IsControlJustPressed(1, 51) and dstToMarker <= 3.0 and allow then
                            RemoveBlip(blip)
                            EnAction = true
                            local spawnRandom = vector3(v.pos.x+math.random(1,3), v.pos.y+math.random(1,3), v.pos.z-1.0)
                            SetEntityCoords(pPed, spawnRandom, 0.0, 0.0, 0.0, 0)
                            SetEntityHeading(pPed, v.Heading)
                            TaskStartScenarioInPlace(pPed, v.scenario, 0, true)
                            Wait(10000)
                            ClearPedTasksImmediately(GetPlayerPed(-1))
                            local money = math.random(ArgentMin, ArgentMax)
                            TriggerServerEvent("ori_jobs:pay", money)
							TriggerEvent('showNotify', '~b~INFORMATION\n~w~Super boulot, continues ainsi !\n\n~o~RÉCOMPENSE\n~w~'..money..'$')
                            break
                        end
                    end
                end
                if DoesBlipExist(blip) then
                    RemoveBlip(blip)
                end
            end
        end
    end
end

Citizen.CreateThread(function()
    TriggerServerEvent("RED_JOBS:JardinierAntiDump")
end)