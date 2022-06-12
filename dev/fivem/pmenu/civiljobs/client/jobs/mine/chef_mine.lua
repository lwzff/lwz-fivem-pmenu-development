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

-- Menu
local menumine = {
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
				TriggerEvent('showNotify', "~b~INFORMATION\n~w~Allez, bonne chance et sois fort.")
				AuTravaillemine = true
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
				if not ESX.Game.IsSpawnPointClear(vector3(2843.071, 2784.613, 59.94376), 6.0) then
					local veh = ESX.Game.GetClosestVehicle(vector3(2843.071, 2784.613, 59.94376))
					TriggerEvent("LS_LSPD:RemoveVeh", veh)
				end
				ESX.Game.SpawnVehicle(GetHashKey("sadler"), vector3(2843.071, 2784.613, 59.94376), 59.144374847412, function(veh)
					SetVehicleOnGroundProperly(veh)
					vehicle = NetworkGetNetworkIdFromEntity(veh)
				end)
				StartTravaillemine()
			end
			if btn == "Arrêter de travailler" then
				CloseMenu()
				TriggerEvent('showNotify', "~b~INFORMATION\n~w~Tu as arrêté de travailler.\n \n~o~MINE\n~w~Merci pour ta journée.")
				AuTravaillemine = false
                endwork()
                TriggerEvent("LS_LSPD:RemoveVeh", NetworkGetEntityFromNetworkId(vehicle))
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
		local distance = GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), zone.mine, true)
		if distance <= 3.0 then
			DrawSub("Appuyez sur ~b~E ~w~pour parler à la personne.", 1)
			if IsControlJustPressed(1, 51) and distance <= 3.0 then
				CreateMenu(menumine)
			end
		end
    end
end)