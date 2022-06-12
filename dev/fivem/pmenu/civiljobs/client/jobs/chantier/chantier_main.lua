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
AuTravailleChantier = nil
local ArgentMin
local ArgentMax

RegisterNetEvent("RED_JOBS:ChantierAntiDump")
AddEventHandler("RED_JOBS:ChantierAntiDump", function(_config, _workzone, _WorkerChillPos, _WorkerWorkingPos)
    Heading = _config.Heading
    pedHash = _config.pedHash
    AuTravailleChantier = _config.AuTravailleChantier
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
    local ped = CreatePed(2, GetHashKey(pedHash), zone.Chantier, Heading, 0, 0)
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






function StartTravailleChantier()
    while not sync do Wait(100) end
    while AuTravailleChantier do
		TriggerEvent('showNotify', '~b~INFORMATION\n~w~Rends-toi près du chantier et travailles bien.')
        Wait(1)
        local random = math.random(1,#workzone)
        local count = 1
        for k,v in pairs(workzone) do
            count = count + 1
            if count == random and AuTravailleChantier then
                local EnAction = false
                local pPed = GetPlayerPed(-1)
                local pCoords = GetEntityCoords(pPed)
                local dstToMarker = GetDistanceBetweenCoords(v.pos, pCoords, true)
                local blip = AddBlipForCoord(v.pos)
                SetBlipSprite(blip, 402)
                SetBlipColour(blip, 5)
                SetBlipScale(blip, 0.65)
                while not EnAction and AuTravailleChantier do
                    Citizen.Wait(1)
                    pCoords = GetEntityCoords(pPed)
                    dstToMarker = GetDistanceBetweenCoords(v.pos, pCoords, true)
                    DrawMarker(25, v.pos.x, v.pos.y, v.pos.z+0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 93, 182, 229, 200, 0, 0, 2, 1, nil, nil, 0)
                    local distance = GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), zone.Chantier, true)
                    if distance <= 2.0 then
						DrawSub("Appuyez sur ~b~E ~s~pour parler à la personne.", 1)
                        if IsControlJustPressed(1, 51) and distance <= 3.0 then
							CreateMenu(menuchantier)
                            AuTravailleChantier = false
                        end
                    end
                    if dstToMarker <= 2.0 and AuTravailleChantier then
						DrawSub("Appuyez sur ~b~E ~s~pour travailler.", 1)
                        if IsControlJustPressed(1, 51) and dstToMarker <= 3.0 then
                            RemoveBlip(blip)
                            EnAction = true
                            SetEntityCoords(pPed, v.pos, 0.0, 0.0, 0.0, 0)
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

-- Menu
local menuchantier = {
	Base = { Header = {false, false}, Title = "Fleeca Bank" },
	Data = { currentMenu = "Actions disponibles", "Test" },
	Events = {
		onSelected = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)
			PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
			local slide = btn.slidenum
			local btn = btn.name
			local check = btn.unkCheckbox
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
			local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)

			if btn == "Commencer à travailler" then
				CloseMenu()
				AuTravailleChantier = true
				TriggerEvent('skinchanger:getSkin', function(skin)
					local clothesSkin = {
						['bags_1'] = 0, ['bags_2'] = 0,
						['tshirt_1'] = 59, ['tshirt_2'] = 0,
						['torso_1'] = 56, ['torso_2'] = 0,
						['arms'] = 30,
						['pants_1'] = 31, ['pants_2'] = 0,
						['shoes_1'] = 25, ['shoes_2'] = 0,
						['mask_1'] = 0, ['mask_2'] = 0,
						['bproof_1'] = 0, ['bproof_2'] = 0,
						['helmet_1'] = 0, ['helmet_2'] = 0,
					}
					TriggerEvent('skinchanger:loadClothes', skin, clothesSkin)
					tenueWeed = true
                end)
				StartTravailleChantier()
			end
			if btn == "Arrêter de travailler" then
				CloseMenu()
				TriggerEvent('showNotify', "~b~INFORMATION\n~w~Tu as arrêté de travailler.\n \n~o~CHANTIER\n~w~Merci pour ta journée.")
				AuTravailleChantier = false
                ESX.TriggerServerCallback('zzu_skin:getPlayerSkin', function(skin, jobSkin)
					local isMale = skin.sex == 0
					TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
						ESX.TriggerServerCallback('zzu_skin:getPlayerSkin', function(skin)
							TriggerEvent('skinchanger:loadSkin', skin)
							TriggerEvent('esx:restoreLoadout')
						end)
					end)
                end)
            end
	end,
    },

	Menu = {
		["Actions disponibles"] = {
			b = {
                {name = "Commencer à travailler", ask = "→", askX = true},
				{name = "Arrêter de travailler", ask = "→", askX = true},
			}
        },
    }
}

Citizen.CreateThread(function()
    TriggerServerEvent("RED_JOBS:ChantierAntiDump")
end)