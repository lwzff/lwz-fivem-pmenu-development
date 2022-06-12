local PlayerData,CurrentActionData, handcuffTimer, dragStatus, blipsCops, currentTask = {}, {}, {}, {}, {}
local HasAlreadyEnteredMarker, isDead, isHandcuffed, hasAlreadyJoined, playerInService = false, false, false, false, false
local LastStation, LastPart, LastPartNum, LastEntity, CurrentAction
dragStatus.isDragged, isInShopMenu = false, false
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().org == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
end)
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

-- Config
local entreetp = {
	{x = -58.329, y = -2244.574, z = 8.955}
}
local sortietp = {
	{x = 1138.17, y = -3199.0, z = -39.665}
}


-- Function box
function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
    AddTextEntry(entryTitle, textEntry)
    DisplayOnscreenKeyboard(1, entryTitle, '', inputText, '', '', '', maxLength)
    blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
        blockinput = false
        return result
    else
        Citizen.Wait(500)
        blockinput = false
        return nil
    end
end

-- Function blanchir argent
function blanchir()
    local amount = KeyboardInput('shdz_quantite', ('Quantité'), '', 20)
    if amount ~= nil then
        amount = tonumber(amount)
		if amount == 0 then
			ESX.ShowNotification(" ~r~Frero tu vas rien blanchir la ")
		else
			if type(amount) == 'number' then
				TriggerServerEvent('@#{WKK.931JE}#:washMoneyJob',amount)
			end
		end
    end
end

------------------------MENUF6------------------
local menublanchisseur= {
	Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {0, 0, 0}, Title = "Blanchisseur" },
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
			
		if btn == "Blanchir" then
			blanchir()
			CloseMenu()
		end
	end
},

	Menu = {
		["Actions disponibles"] = {
			b = {
				{name = "Blanchir", ask = "🤑", askX = true},
			}
        }
    }
}

------------------------Fin------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if IsControlJustReleased(1, 56) and PlayerData.org and PlayerData.org.name == 'blanchisseur' then
			CreateMenu(menublanchisseur)
		end
		for k in pairs(entreetp) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, entreetp[k].x, entreetp[k].y, entreetp[k].z)
			if dist <= 0.2 then
				DrawSub("Appuyez sur ~b~E ~s~pour intéragir.", 1)
                if IsControlJustPressed(1,51) then
					DoScreenFadeOut(500)
                    while not IsScreenFadedOut() do
                        Wait(1)
                    end
                	SetEntityCoords(GetPlayerPed(-1), 1138.17, -3198.62, -40.61, 0.0, 0.0, 0.0, 0)
                	DoScreenFadeIn(500) 
				end
            end
		end
		for k in pairs(sortietp) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, sortietp[k].x, sortietp[k].y, sortietp[k].z)
			if dist <= 0.2 then
				DrawSub("Appuyez sur ~b~E ~s~pour intéragir.", 1)
                if IsControlJustPressed(1,51) then
					DoScreenFadeOut(500)
                    while not IsScreenFadedOut() do
                        Wait(1)
                    end
                	SetEntityCoords(GetPlayerPed(-1), -58.329, -2244.574, 8.955, 0.0, 0.0, 0.0, 0)
                	DoScreenFadeIn(500) 
				end
            end
		end
	end
end)

RegisterNetEvent('esx:setOrg')
AddEventHandler('esx:setOrg', function(org)
	PlayerData.org = org
end)

AddEventHandler('playerSpawned', function(spawn)
	isDead = false

	if not hasAlreadyJoined then
		TriggerServerEvent('@#{WKK.931JE}#:spawned')
	end
	hasAlreadyJoined = true
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
	end
end)

RegisterNetEvent("@#{WKK.931JE}#:notify")
AddEventHandler("@#{WKK.931JE}#:notify", function(icon, type, sender, title, text)
    Citizen.CreateThread(function()
		Wait(1)
		SetNotificationTextEntry("STRING");
		AddTextComponentString(text);
		SetNotificationMessage(icon, icon, true, type, sender, title, text);
		DrawNotification(false, true);
    end)
end)