-- Notification radar
function ShowAboveRadarMessage(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(0, 1)
end

RegisterNetEvent('showNotify')
AddEventHandler('showNotify', function(notify)
    ShowAboveRadarMessage(notify)
end)

local vehicle = nil
local ZoneDeSpawn = vector3(-1336.572, 118.7055, 56.51094)


-- Menu
local menujardinier = {
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
				AuTravailleJardinier = true
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
                    end)
					local spawnRandom = vector3(ZoneDeSpawn.x+math.random(1,15), ZoneDeSpawn.y+math.random(1,15), ZoneDeSpawn.z)
                    ESX.Game.SpawnVehicle(1783355638, spawnRandom, 274.95318603516, function(veh)
                        vehicle = NetworkGetNetworkIdFromEntity(veh)
						vehcoords = GetEntityCoords(vehicle)
                        local blip = AddBlipForEntity(veh)
                        SetBlipSprite(blip, 561)
						SetBlipScale(blip, 0.8)
                        SetBlipFlashes(blip, true)
                    end)
                    StartTravailleJardinier()
			end
			if btn == "Arrêter de travailler" then
				CloseMenu()
				TriggerEvent('showNotify', "~b~INFORMATION\n~w~Tu as arrêté de travailler.\n \n~o~JARDINIER\n~w~Merci pour ta journée.")
				AuTravailleJardinier = false
                ESX.Game.DeleteVehicle(NetworkGetEntityFromNetworkId(vehicle))
                ESX.TriggerServerCallback('a_skin:getPlayerSkin', function(skin, jobSkin)
					local isMale = skin.sex == 0
					TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
						ESX.TriggerServerCallback('a_skin:getPlayerSkin', function(skin)
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
	while true do
		Citizen.Wait(0)
		local distance = GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), zone.Jardinier, true)
		if distance <= 2.0 then
			DrawSub("Appuyez sur ~b~E ~w~pour parler à la personne.", 1)
			if IsControlJustPressed(1, 51) and distance <= 2.0 then
				CreateMenu(menujardinier)
			end
		end
    end
end)