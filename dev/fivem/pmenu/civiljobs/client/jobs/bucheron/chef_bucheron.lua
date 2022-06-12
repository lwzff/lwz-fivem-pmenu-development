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

-- Menu
local menubucheron = {
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
				AuTravaillebucheron = true
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
                StartTravaillebucheron()
			end
			if btn == "Arrêter de travailler" then
				CloseMenu()
				TriggerEvent('showNotify', "~b~INFORMATION\n~w~Tu as arrêté de travailler.\n \n~o~BÛCHERON\n~w~Merci pour ta journée.")
				AuTravaillebucheron = false
				endwork()
				--TriggerEvent("LS_LSPD:RemoveVeh", NetworkGetEntityFromNetworkId(vehicle))
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
	while true do
		Citizen.Wait(0)
		local distance = GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), zone.bucheron, true)
		if distance <= 3.0 then
			DrawSub("Appuyez sur ~b~E ~w~pour parler à la personne.", 1)
			if IsControlJustPressed(1, 51) and distance <= 3.0 then
				CreateMenu(menubucheron)
			end
		end
    end
end)
