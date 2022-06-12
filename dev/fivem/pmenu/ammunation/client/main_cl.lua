ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(1000)
    end
end)

-- Config
ammuped = "s_m_y_ammucity_01"
local ammupedpos = {
	{x = 22.811, y = -1105.253, z = 29.797, h = 155.981},
	{x = 1691.94, y = 3761.29, z = 34.705, h = 226.07},
	{x = -331.622, y = 6085.233, z = 31.454, h = 224.0},
}
local blipammu = {
	{x = -324.22,  y = 6075.24,  z = 0.0},
	{x = 1699.99,  y = 3751.51,  z = 0.0},
	{x = 17.01,  y = -1116.21,  z = 0.0},
}
local menuammu = {
    {x = -330.24, y = 6083.94, z = 31.45},
	{x = 1693.73, y = 3760.01, z = 34.7},
	{x = 22.35, y = -1107.33, z = 29.79},
}

-- Message en bas
function DrawSub(msg, time)
	ClearPrints()
	BeginTextCommandPrint('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandPrint(time, 1)
end

-- Menu Armurerie (Sans PPA)
local shopammu = {
	Base = { Header = {"shopui_title_gunclub", "shopui_title_gunclub"}, Title = "Fleeca Bank" },
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
				TriggerServerEvent('!{#EZKww103}#:buyweapon', 425, "WEAPON_KNIFE", "couteau")
			end
			if btn == "Batte" then
				TriggerServerEvent('!{#EZKww103}#:buyweapon', 325, "WEAPON_BAT", "batte")
			end
			if btn == "Permis de port d'armes" then
                ESX.TriggerServerCallback('!{#EZKww103}#:buylicense', function(bought)
                    if bought then
                        PlaySoundFrontend(-1, 'WEAPON_PURCHASE', 'HUD_AMMO_SHOP_SOUNDSET', false)
                        CloseMenu()
                    end
                end)
			end
			if btn == "Munitions" then
				local pedweap = GetSelectedPedWeapon(GetPlayerPed(-1))
				local pedammo = GetAmmoInPedWeapon(GetPlayerPed(-1), pedweap)
				if pedweap == -1569615261 then
					ESX.ShowAdvancedNotification("Armurerie", "", "Tu n'as pas d'armes en main.", "CHAR_AMMUNATION", 0)
				elseif pedammo == 250 then
					ESX.ShowAdvancedNotification("Armurerie", "", "Tu ne peux plus stocker plus de munitions. ~g~(Maximum : 250)", "CHAR_AMMUNATION", 0)
				else
					TriggerServerEvent('!{#EZKww103}#:buyammo', 150, "munitions")
				end
			end
		end,
    },

	Menu = {
		["Actions disponibles"] = {
			b = {
                {name = "Couteau", price = 425, askX = true},
                {name = "Batte", price = 325, askX = true},
				{name = "Munitions", ammo = 1 , Description = "Prix : ~g~250$"},
				{name = "Permis de port d'armes", price = 40000},
			}
        },
    }
}

-- Menu Armurerie (Avec PPA)
local shopammu2 = {
	Base = { Header = {"shopui_title_gunclub", "shopui_title_gunclub"}, Title = "Fleeca Bank" },
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
				TriggerServerEvent('!{#EZKww103}#:buyweapon', 425, "WEAPON_KNIFE", "couteau")
			end
			if btn == "Batte" then
				TriggerServerEvent('!{#EZKww103}#:buyweapon', 325, "WEAPON_BAT", "batte")
			end
			if btn == "Pétoire" then
				TriggerServerEvent('!{#EZKww103}#:buyweapon', 65000, "WEAPON_SNSPISTOL", "pétoire")
			end
			if btn == "Munitions" then
				local pedweap = GetSelectedPedWeapon(GetPlayerPed(-1))
				local pedammo = GetAmmoInPedWeapon(GetPlayerPed(-1), pedweap)
				if pedweap == -1569615261 then
					ESX.ShowAdvancedNotification("Armurerie", "", "Tu n'as pas d'armes en main.", "CHAR_AMMUNATION", 0)
				elseif pedammo == 250 then
					ESX.ShowAdvancedNotification("Armurerie", "", "Tu ne peux plus stocker plus de munitions. ~g~(Maximum : 250)", "CHAR_AMMUNATION", 0)
				else
					TriggerServerEvent('!{#EZKww103}#:buyammo', 100, "munitions")
				end
			end
		end,
    },

	Menu = {
		["Actions disponibles"] = {
			b = {
                {name = "Couteau", ask = "~g~425$", askX = true},
                {name = "Batte", ask = "~g~325$", askX = true},
				{name = "—"},
				{name = "Pétoire", ask = "~g~65000$", askX = true},
				{name = "Munitions", ammo = 1 , Description = "Prix : ~g~250$" },
			}
        },
    }
}

RegisterNetEvent('!{#EZKww103}#:buyammo2')
AddEventHandler('!{#EZKww103}#:buyammo2', function(source)
	local pedweap = GetSelectedPedWeapon(GetPlayerPed(-1))
	AddAmmoToPed(GetPlayerPed(-1), pedweap, 50)
end)

-- Position Menu
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k in pairs(menuammu) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, menuammu[k].x, menuammu[k].y, menuammu[k].z)
			--[[
			if dist <= 10.0 then
				DrawMarker(25, menuammu[k].x, menuammu[k].y, menuammu[k].z-0.9, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.7, 0.7, 0.7, 224, 50, 50, 200, false, false, 2, false, false, false, false)
			end
			]]
            if dist <= 1.2 then
				DrawSub("Appuyez sur ~r~E ~s~pour intéragir.", 1)		
                if IsControlJustPressed(1,51) then
					ESX.TriggerServerCallback('esx_license:checkLicense', function(hasWeaponLicense)
						if hasWeaponLicense then
							CreateMenu(shopammu2)
						else
							CreateMenu(shopammu)
						end
					end, GetPlayerServerId(PlayerId()), 'weapon')
				end
			end
        end
    end
end)

-- Position bLIP
Citizen.CreateThread(function()
    for k in pairs(blipammu) do
		local blip = AddBlipForCoord(blipammu[k].x, blipammu[k].y, blipammu[k].z)
		SetBlipSprite(blip, 110)
		SetBlipScale(blip, 0.5)
		SetBlipAsShortRange(blip, true)
		SetBlipColour(blip, 1)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Armurerie")
		EndTextCommandSetBlipName(blip)	
    end
end)

-- Ped
Citizen.CreateThread(function()
    for k in pairs(ammupedpos) do
    	local hash = GetHashKey(ammuped)
    	while not HasModelLoaded(hash) do
    		RequestModel(hash)
    		Wait(20)
    		end
    	ped = CreatePed("PED_TYPE_CIVFEMALE", ammuped, ammupedpos[k].x, ammupedpos[k].y, ammupedpos[k].z-1.0, ammupedpos[k].h, false, true)
		SetBlockingOfNonTemporaryEvents(ped, true)
		SetEntityInvincible(ped, true)
    	FreezeEntityPosition(ped, true)
    end
end)

--
-- Developped by lwz#2051
--