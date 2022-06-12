local PlayerData = {}

ESX = nil
playermanagement = true

-- Debug setjob
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

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

-- Fonction coffre
function OpenGetStocksMenu()
	ESX.TriggerServerCallback('@{EnwE.484}:pventearmes:getStockItems', function(items)
		local elements = {}
		
		for i=1, #items, 1 do
			local item = items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type = 'item_standard',
					value = item.name
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			css      = 'police',
			title    = 'Inventaire (retrait)',
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				css      = 'police',
				title = "Quantité"
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if count == nil then
					ESX.ShowNotification("~r~Quantité invalide.")
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('@{EnwE.484}:pventearmes:getStockItem', itemName, count)

					Citizen.Wait(300)
					OpenGetStocksMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end
function OpenPutStocksMenu()
	ESX.TriggerServerCallback('@{EnwE.484}:pventearmes:getPlayerInventory', function(inventory)
		local elements = {}

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type = 'item_standard',
					value = item.name
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			css      = 'police',
			title    = "Inventaire (dépôt)",
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
				css      = 'police',
				title = "Quantité"
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if count == nil then
					ESX.ShowNotification("~r~Quantité invalide.")
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('@{EnwE.484}:pventearmes:putStockItems', itemName, count)

					Citizen.Wait(300)
					OpenPutStocksMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

-- Message en bas
function DrawSub(msg, time)
	ClearPrints()
	BeginTextCommandPrint('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandPrint(time, 1)
end

-- Menu Vente lourde
local mventearmesl = {
	Base = { Header = {"commonmenu", "interaction_bgd"}, Title = "Emilio" },
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
	
			if btn == "Gilet par balles" then
				TriggerServerEvent('@{EnwE.484}:pventearmes:buyitem', 25000, 1, "gilet", "gilet par balles")
            elseif btn == "Micro Uzi" then
                TriggerServerEvent('@{EnwE.484}:pventearmes:buyweapon', 125000, 425, "WEAPON_MICROSMG", "Micro UZI")
			elseif btn == "Skorpion" then
				TriggerServerEvent('@{EnwE.484}:pventearmes:buyweapon', 175000, 425, "WEAPON_MINISMG", "Skorpion")
			elseif btn == "AK-47" then
				TriggerServerEvent('@{EnwE.484}:pventearmes:buyweapon', 750000, 425, "WEAPON_ASSAULTRIFLE", "AK-47")
			elseif btn == "AK-47 compacte" then
				TriggerServerEvent('@{EnwE.484}:pventearmes:buyweapon', 400000, 425, "WEAPON_COMPACTRIFLE", "AK-47 compacte")
			elseif btn == "Pétoire" then
					TriggerServerEvent('@{EnwE.484}:pventearmes:buyweapon', 22500, 425, "WEAPON_SNSPISTOL", "Pétoire")
			elseif btn == "Pistolet .9mm" then
				TriggerServerEvent('@{EnwE.484}:pventearmes:buyweapon', 50000, 425, "WEAPON_PISTOL", "Pistolet 9mm")
			elseif btn == "Pistolet Lourd" then
				TriggerServerEvent('@{EnwE.484}:pventearmes:buyweapon', 75000, 425, "weapon_heavypistol", "Pistolet 9mm")
			elseif btn == "Pistolet Lourd" then
				TriggerServerEvent('@{EnwE.484}:pventearmes:buyweapon', 195000, 425, "weapon_heavypistol", "Pistolet 9mm")	
			elseif btn == "Calibre .50" then
				TriggerServerEvent('@{EnwE.484}:pventearmes:buyweapon', 115000, 425, "WEAPON_PISTOL50", "Calibre 50")
			elseif btn == "Fusil à pompe court" then
				TriggerServerEvent('@{EnwE.484}:pventearmes:buyweapon', 250000, 425, "weapon_sawnoffshotgun", "Calibre 50")	
            end
			
	end,
    },

	Menu = {
		["Actions disponibles"] = {
			b = {
				{name = "Pétoire", ask = "~g~22.500$", askX = true},
				{name = "Pistolet .9mm", ask = "~g~50.000$", askX = true},
				{name = "Pistolet Lourd", ask = "~g~75.000$", askX = true},
				{name = "Calibre .50", ask = "~g~115.000$", askX = true},
				{name = "Pistolet Vintage", ask = "~g~195.000$", askX = true},
				{name = "Micro Uzi", ask = "~g~125.000$", askX = true},
				{name = "Skorpion", ask = "~g~175.000$", askX = true},
				{name = "Fusil à pompe court", ask = "~g~250.000$", askX = true},
				{name = "AK-47 compacte", ask = "~g~400.000$", askX = true},
				{name = "AK-47", ask = "~g~750.000$", askX = true},
				{name = "Gilet par balles", ask = "~g~25.000$", askX = true},
			}
        },
    }
}
-- Menu Vente Légère
local mventearmes2 = {
	Base = { Header = {"commonmenu", "interaction_bgd"}, Title = "Enriqué" },
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

			if btn == "Couteau" then
				TriggerServerEvent('@{EnwE.484}:pventearmes:buyweapon', 250, 1, "WEAPON_KNIFE", "Couteau")
			elseif btn == "Batte" then
				TriggerServerEvent('@{EnwE.484}:pventearmes:buyweapon', 500, 1, "WEAPON_BAT", "Batte")
			elseif btn == "Bouteille en verre" then
				TriggerServerEvent('@{EnwE.484}:pventearmes:buyweapon', 750, 1, "WEAPON_BOTTLE", "Bouteille en verre")
			elseif btn == "Cran d'arrêt" then
				TriggerServerEvent('@{EnwE.484}:pventearmes:buyweapon', 1000, 1, "WEAPON_SWITCHBLADE", "Cran d'arrêt")
			elseif btn == "Queue de billard" then
				TriggerServerEvent('@{EnwE.484}:pventearmes:buyweapon', 1200, 1, "WEAPON_POOLCUE", "Queue de billard")
			elseif btn == "Hache de guerre" then
				TriggerServerEvent('@{EnwE.484}:pventearmes:buyweapon', 1600, 1, "WEAPON_BATTLEAXE", "Hache de guerre")
			elseif btn == "Club de golf" then
				TriggerServerEvent('@{EnwE.484}:pventearmes:buyweapon', 1900, 1, "WEAPON_GOLFCLUB", "Club de golf")
			elseif btn == "Marteau" then
				TriggerServerEvent('@{EnwE.484}:pventearmes:buyweapon', 2500, 1, "WEAPON_HAMMER", "Marteau")
			elseif btn == "Hachette" then
				TriggerServerEvent('@{EnwE.484}:pventearmes:buyweapon', 20000, 1, "WEAPON_HATCHET", "Hachette")
			elseif btn == "Poing américain" then
				TriggerServerEvent('@{EnwE.484}:pventearmes:buyweapon', 4500, 1, "WEAPON_KNUCKLE", "Poing américain")	
            end
			
	end,
    },

	Menu = {
		["Actions disponibles"] = {
			b = {
				{name = "Couteau", ask = "~g~250$", askX = true},
				{name = "Batte", ask = "~g~500$", askX = true},
				{name = "Bouteille en verre", ask = "~g~750$", askX = true},
				{name = "Cran d'arrêt", ask = "~g~1.000$", askX = true},
				{name = "Queue de billard", ask = "~g~1.200$", askX = true},
				{name = "Hache de guerre", ask = "~g~1.600$", askX = true},
				{name = "Club de golf", ask = "~g~1.900$", askX = true},
				{name = "Marteau", ask = "~g~2.500$", askX = true},
				{name = "Poing américain", ask = "~g~4.500$", askX = true},
				{name = "Hachette", ask = "~g~20.000$", askX = true},
			}
        },
    }
}

-- Menu Stock bar
function OpenArmoryMenu()
local elements = {}
	table.insert(elements, {label = "Retirer",  value = 'get_stock'})
	table.insert(elements, {label = "Déposer", value = 'put_stock'})
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory', {
		title    = 'Stockage du bar',
		align    = 'top-left',
		elements = elements
	}, function(data, menu)

		if data.current.value == 'put_stock' then
			OpenPutStocksMenu()
		elseif data.current.value == 'get_stock' then
			OpenGetStocksMenu()
		end

	end, function(data, menu)
		menu.close()
	end)
end

-- Position
local ventearmes11 = {
    {x = 723.97, y = -791.137, z = 16.47, h = 269.5}
}
local ventearmes22 = {
    {x = 727.60, y = -791.11, z = 16.47, h = 87.67}
}
local stockbar = {
	{x = 741.47, y = -810.8, z = 24.27}
}
local bossmenu = {
	{x = 740.32, y = -814.37, z = 24.27}
}
local blipboite = {
    {x = 759.36, y = -815.93, z = 0.0},
}
ventearmesped = "s_m_m_chemsec_01"
Citizen.CreateThread(function()
	while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(1000)
	end
	
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()

	for k in pairs(blipboite) do
		local blip = AddBlipForCoord(blipboite[k].x, blipboite[k].y, blipboite[k].z)
		SetBlipSprite(blip, 93)
		SetBlipScale(blip, 0.5)
		SetBlipAsShortRange(blip, true)
		SetBlipColour(blip, 5)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Dallas Industries")
		EndTextCommandSetBlipName(blip)	
	end

	for k in pairs(ventearmes11) do
		local hash = GetHashKey(ventearmesped)
		while not HasModelLoaded(hash) do
			RequestModel(hash)
			Wait(20)
		end
		ped = CreatePed("PED_TYPE_CIVFEMALE", hash, ventearmes11[k].x, ventearmes11[k].y, ventearmes11[k].z-0.99, ventearmes11[k].h, false, true)
		SetBlockingOfNonTemporaryEvents(ped, true)
		FreezeEntityPosition(ped, true)
		SetEntityInvincible(ped, true)
	end
	for k in pairs(ventearmes22) do
		local hash = GetHashKey(ventearmesped)
		while not HasModelLoaded(hash) do
			RequestModel(hash)
			Wait(20)
		end
		ped = CreatePed("PED_TYPE_CIVFEMALE", hash, ventearmes22[k].x, ventearmes22[k].y, ventearmes22[k].z-0.99, ventearmes22[k].h, false, true)
		SetBlockingOfNonTemporaryEvents(ped, true)
		FreezeEntityPosition(ped, true)
		SetEntityInvincible(ped, true)
	end

    while true do
        Citizen.Wait(0)
        for k in pairs(ventearmes11) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, ventearmes11[k].x, ventearmes11[k].y, ventearmes11[k].z)
			if dist <= 1.0 and PlayerData.job ~= nil and PlayerData.job.name == 'ventearmes' and PlayerData.job.grade_name == 'recruit' then
				DrawSub("Appuyez sur ~b~E ~s~intéragir.", 1)	
				if IsControlJustPressed(1,51) then
					CreateMenu(mventearmes2)
				end
			end
			if dist <= 1.0 and PlayerData.job ~= nil and PlayerData.job.name == 'ventearmes' and PlayerData.job.grade_name == 'employe' then
				DrawSub("Appuyez sur ~b~E ~s~intéragir.", 1)	
				if IsControlJustPressed(1,51) then
					CreateMenu(mventearmes2)
				end
			end
			if dist <= 1.0 and PlayerData.job ~= nil and PlayerData.job.name == 'ventearmes' and PlayerData.job.grade_name == 'boss' then
				DrawSub("Appuyez sur ~b~E ~s~intéragir.", 1)	
				if IsControlJustPressed(1,51) then
					CreateMenu(mventearmes2)
				end
			end
		end
		for k in pairs(ventearmes22) do
			local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
			local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, ventearmes22[k].x, ventearmes22[k].y, ventearmes22[k].z)
			if dist <= 1.0 and PlayerData.job and PlayerData.job.name == 'ventearmes' and PlayerData.job.grade_name == 'employe' then
				DrawSub("Appuyez sur ~b~E ~s~intéragir.", 1)	
				if IsControlJustPressed(1,51) then
					CreateMenu(mventearmesl)
				end
			end
			if dist <= 1.0 and PlayerData.job and PlayerData.job.name == 'ventearmes' and PlayerData.job.grade_name == 'boss' then
				DrawSub("Appuyez sur ~b~E ~s~intéragir.", 1)	
				if IsControlJustPressed(1,51) then
					CreateMenu(mventearmesl)
				end
			end
		end
		for k in pairs(stockbar) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, stockbar[k].x, stockbar[k].y, stockbar[k].z)
			if dist <= 15.0 and PlayerData.job and PlayerData.job.name == 'ventearmes' then
				DrawMarker(25, stockbar[k].x, stockbar[k].y, stockbar[k].z-0.9, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.7, 0.7, 0.7, 255, 255, 255, 200, false, false, 2, true, false, false, false)
			end
            if dist <= 1.0 and PlayerData.job and PlayerData.job.name == 'ventearmes' then
                DrawSub("Appuyez sur ~w~E ~s~pour intéragir.", 1)		
                if IsControlJustPressed(1,51) then
					OpenArmoryMenu()
				end
			end
        end
		for k in pairs(bossmenu) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, bossmenu[k].x, bossmenu[k].y, bossmenu[k].z)
			if dist <= 15.0 and PlayerData.job and PlayerData.job.name == 'ventearmes' and PlayerData.job.grade_name == 'boss' then
				DrawMarker(25, bossmenu[k].x, bossmenu[k].y, bossmenu[k].z-0.9, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.7, 0.7, 0.7, 255, 255, 255, 200, false, false, 2, true, false, false, false)
			end
            if dist <= 1.0 and PlayerData.job and PlayerData.job.name == 'ventearmes' and PlayerData.job.grade_name == 'boss' then
                DrawSub("Appuyez sur ~w~E ~s~pour gérer l'entreprise.", 1)		
                if IsControlJustPressed(1,51) then
					TriggerEvent('esx_society:openBossMenu', 'ventearmes', function(data, menu)
						menu.close()
					end, { wash = false })
				end
			end
		end
	end
end)

--
-- Developped by lwz#2051
--