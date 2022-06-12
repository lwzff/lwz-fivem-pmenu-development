local PlayerData, currentTask = {}, {}

ESX = nil

-- Message en bas
function DrawSub(msg, time)
	ClearPrints()
	BeginTextCommandPrint('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandPrint(time, 1)
end

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

-- F6 Facture
function facture()
	local amount = KeyboardInput('#{PEOddnq348}@facture', ('Montant'), '', 6)
	local player, distance = ESX.Game.GetClosestPlayer()
	local amount = tonumber(amount)
	
	if player ~= -1 and distance <= 3.0 then
		if amount ~= nil then
			if amount <= 10000 then
				if amount == 0 then
				else
					if type(amount) == 'number' then
						TriggerServerEvent('esx_billing:sendBill24', GetPlayerServerId(player), 'society_unicorn', "Unicorn", amount)
						Wait(100)
						ESX.ShowNotification('~b~INFORMATION\n~w~Facture envoyée.\n \n~o~MONTANT \n~w~'..amount..'$')
					end
				end
			else
				ESX.ShowNotification('~b~INFORMATION\n~w~Montant trop élevé.\n \n~o~MAXIMUM \n~w~10.000$')
			end
		end
	else
		ESX.ShowNotification('~b~INFORMATION\n~w~Aucun joueur proche.')
    end
end

-- Téléportation bar (entrée)
function bartelep1()
	local dist = GetEntityCoords(GetPlayerPed(-1), 133.04, -1293.78, 29.26, false)
	DoScreenFadeOut(1000)
	while not IsScreenFadedOut() do
		Wait(1)
	end
	SetEntityCoords(GetPlayerPed(-1), 132.49, -1287.5, 29.26, 0.0, 0.0, 0.0, 0.0)
	DoScreenFadeIn(1000)
end

-- Téléportation bar (sortie)
function bartelep2()
	local dist = GetEntityCoords(GetPlayerPed(-1), 132.49, -1287.5, 29.26, false)
	DoScreenFadeOut(1000)
	while not IsScreenFadedOut() do
		Wait(1)
	end
	SetEntityCoords(GetPlayerPed(-1), 133.04, -1293.78, 29.26, 0.0, 0.0, 0.0, 0.0)
	DoScreenFadeIn(1000)
end

-- Menu Bar
local menubar = {
	--Base = { Header = {"commonmenu", "interaction_bgd"}, HeaderColor = {0, 204, 0}, Title = "Fleeca Bank" },
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

			if btn == "Grand Cru" then
				TriggerServerEvent('#{PEOddnq348}@punicorn:buyboisson', "grand_cru", "Grand Cru")
			end
			if btn == "Ice Tea" then
                TriggerServerEvent('#{PEOddnq348}@punicorn:buyboisson', "icetea", "Ice Tea")
            end
			if btn == "Limonade" then
                TriggerServerEvent('#{PEOddnq348}@punicorn:buyboisson', "limonade", "Limonade")
            end
			if btn == "Martini" then
                TriggerServerEvent('#{PEOddnq348}@punicorn:buyboisson', "martini", "Martini")
            end
			if btn == "Mojito" then
				TriggerServerEvent('#{PEOddnq348}@punicorn:buyboisson', "mojito", "Mojito")
            end
			if btn == "Rhum" then
                TriggerServerEvent('#{PEOddnq348}@punicorn:buyboisson', "rhum", "Rhum")
            end
			if btn == "Vodka" then
                TriggerServerEvent('#{PEOddnq348}@punicorn:buyboisson', "vodka", "Vodka")
            end
	end,
    },

	Menu = {
		["Actions disponibles"] = {
			b = {
                {name = "Grand Cru", ask = "→", askX = true},
				{name = "Ice Tea", ask = "→", askX = true},
				{name = "Limonade", ask = "→", askX = true},
				{name = "Martini", ask = "→", askX = true},
				{name = "Mojito", ask = "→", askX = true},
				{name = "Rhum", ask = "→", askX = true},
				{name = "Vodka", ask = "→", askX = true},
			}
        },
    }
}

-- Menu F6
function LoadingPrompt(loadingText, spinnerType)
    if IsLoadingPromptBeingDisplayed() then
        RemoveLoadingPrompt()
    end
    if (loadingText == nil) then
        BeginTextCommandBusyString(nil)
    else
        BeginTextCommandBusyString("STRING");
        AddTextComponentSubstringPlayerName(loadingText);
    end
    EndTextCommandBusyString(spinnerType)
end

local unicornf6 = {
	--Base = { Header = {"commonmenu", "interaction_bgd"}, HeaderColor = {255, 255, 255}, Title = "Entreprise d'oranges" },
	Base = { Header = {false, false}, HeaderColor = {255, 255, 255}, Title = "Entreprise de patates" },
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
			if btn == "Facture" then
				facture()
			elseif btn == "Annonces" then
				OpenMenu("Actions disponibles  ")
			elseif btn == "Ouverture" then
				TriggerServerEvent('#{PEOddnq348}@punicorn:ouverture')
			elseif btn == "Fermeture" then
				TriggerServerEvent('#{PEOddnq348}@punicorn:fermeture')
			elseif btn == "~r~Fermer" then
				CloseMenu()
			elseif btn == "Animations" then
				OpenMenu("Actions disponibles ")
			elseif btn == "Prendre une commande" then
				TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_CLIPBOARD", 0, true)
				TriggerEvent('showNotify', '~b~INFORMATION\n~w~Tu fais l\'emote ~o~prendre commande ~s~appuie sur W pour arrêter.')
			elseif btn == "Attendre comme un guarde" then
				TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_GUARD_STAND", 0, true)
				TriggerEvent('showNotify', '~b~INFORMATION\n~w~Tu fais l\'emote ~o~attendre guarde ~s~appuie sur W pour arrêter.')
			end
		end,
	},
	Menu = {
		["Actions disponibles"] = {
			b = {
				{name = "Facture", ask = "", askX = true},
				{name = "Annonces", ask = "", askX = true},
				{name = "Animations", ask = "", askX = true},
				{name = "—"},
				{name = "~r~Fermer", ask = "~r~→", askX = true}
			}
		},
		["Actions disponibles "] = {
			b = {
				{name = "Prendre une commande", ask = "", askX = true},
				{name = "Attendre comme un guarde", ask = "", askX = true},
				{name = "—"},
				{name = "~r~Fermer", ask = "~r~→", askX = true}
			}
		},
		["Actions disponibles  "] = {
			b = {
				{name = "Ouverture", ask = "", askX = true},
				{name = "Fermeture", ask = "", askX = true},
				{name = "—"},
				{name = "~r~Fermer", ask = "~r~→", askX = true}
			}
		},
	}
}

-- Menu Patron
function retraitUnicorn()
    local amount = KeyboardInput('#{PEOddnq348}@RET', ('Montant (max. 50000$)'), '', 5)
    if amount ~= nil then
        amount = tonumber(amount)
		if amount >= 50000 then
			TriggerEvent('showNotify', '~b~INFORMATION\n~w~Montant trop élevé.\n \n~o~MAXIMUM \n~w~50.000$')
		else
			if type(amount) == 'number' then
				TriggerServerEvent('esx_society:withdrawMoney', 'unicorn', amount)
			end
		end
    end
end

function depotUnicorn()
    local amount = KeyboardInput('#{PEOddnq348}@RET', ('Montant (max. 50000$)'), '', 5)
    if amount ~= nil then
        amount = tonumber(amount)
		if amount >= 50000 then
			TriggerEvent('showNotify', '~b~INFORMATION\n~w~Montant trop élevé.\n \n~o~MAXIMUM \n~w~50.000$')
		else
			if type(amount) == 'number' then
				TriggerServerEvent('esx_society:depositMoney', 'unicorn', amount)
			end
		end
	end
end

local unicornboss = {
	--Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 0}, Title = "" },
	Base = { Header = {false, false}, Color = {color_black}, HeaderColor = {255, 255, 0}, Title = "" },
	Data = { currentMenu = "Actions disponibles", "Test" },
	Events = {
		onSelected = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)
			PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
			local slide = btn.slidenum
			local btn = btn.name
			local check = btn.unkCheckbox

			if btn == "Retirer argent" then
				retraitUnicorn()
			elseif btn == "Déposer argent" then
				depotUnicorn()
			elseif btn == "Aide" then
				OpenMenu('Aide')
			elseif btn == "Comment retirer de l'argent ?" then
				ESX.ShowAdvancedNotification("Boite de nuit", "→ Aide", "Pour retirer de l'argent, rends-toi dans le menu principal et clique sur le bouton prévu pour.", "CHAR_MP_FM_CONTACT", 0, 0, false, 1)
			elseif btn == "Comment déposer de l'argent ?" then
				ESX.ShowAdvancedNotification("Boite de nuit", "→ Aide", "Pour déposer de l'argent, rends-toi dans le menu principal et clique sur le bouton prévu pour.", "CHAR_MP_FM_CONTACT", 0, 0, false, 1)
		end
	end,
},
	Menu = {
		["Actions disponibles"] = {
			b = {
				{name = "Retirer argent", ask = "", askX = true},
				{name = "Déposer argent", ask = "", askX = true},
				{name = "Aide", ask = "", askX = true}
			}
		},
		["Aide"] = {
			b = {
				{name = "Comment retirer de l'argent ?", ask = "", askX = true},
				{name = "Comment déposer de l'argent ?", ask = "", askX = true}
			}
		},
	}
}

-- Position Menus & TP
local tpbar1 = {
    {x = 133.04, y = -1293.78, z = 29.26},
}
local tpbar2 = {
    {x = 132.49, y = -1287.5, z = 29.26},
}
local barmenu = {
	{x = 129.73, y = -1283.73, z = 29.27},
}
local bossmenu = {
	{x = 94.21, y = -1292.67, z = 29.26},
}
local blipunicorn = {
    {x = 129.43, y = -1299.63, z = 0.0},
}
local Enattente = false
local zone = {
    {
        zone = vector3(127.81, -1300.29, 29.43),
        job = "unicorn",
		label = "unicorn",
    },
}
Citizen.CreateThread(function()
	for k in pairs(blipunicorn) do
		local blip = AddBlipForCoord(blipunicorn[k].x, blipunicorn[k].y, blipunicorn[k].z)
		SetBlipSprite(blip, 121)
		SetBlipScale(blip, 0.5)
		SetBlipAsShortRange(blip, true)
		SetBlipColour(blip, 8)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Unicorn")
		EndTextCommandSetBlipName(blip)	
    end
    while true do
        Citizen.Wait(0)
		if IsControlJustPressed(1,167) and PlayerData.job ~= nil and PlayerData.job.name == 'unicorn' then
			CreateMenu(unicornf6)
		end
        for k in pairs(tpbar1) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, tpbar1[k].x, tpbar1[k].y, tpbar1[k].z)
			if dist <= 10.0 and PlayerData.job ~= nil and PlayerData.job.name == 'unicorn'  then
				DrawMarker(2, tpbar1[k].x, tpbar1[k].y, tpbar1[k].z+0.2, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.2, 0.2, 0.2, 204, 204, 204, 200, true, false, 2, true, false, false, false)
			end
			if dist <= 1.0 and PlayerData.job ~= nil and PlayerData.job.name == 'unicorn' then
				DrawSub("Appuyez sur ~p~E ~s~pour se rendre au bar.", 1)		
				if IsControlJustPressed(1,51) then
					bartelep1()
				end
			end
        end
		for k in pairs(tpbar2) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, tpbar2[k].x, tpbar2[k].y, tpbar2[k].z)
			if dist <= 10.0 and PlayerData.job ~= nil and PlayerData.job.name == 'unicorn'  then
				DrawMarker(2, tpbar2[k].x, tpbar2[k].y, tpbar2[k].z+0.2, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.2, 0.2, 0.2, 204, 204, 204, 200, true, false, 2, true, false, false, false)
			end
			if dist <= 1.0 and PlayerData.job ~= nil and PlayerData.job.name == 'unicorn' then
				DrawSub("Appuyez sur ~p~E ~s~pour sortir du bar.", 1)		
				if IsControlJustPressed(1,51) then
					bartelep2()
				end
			end
        end
		for k in pairs(barmenu) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, barmenu[k].x, barmenu[k].y, barmenu[k].z)
			if dist <= 15.0 and PlayerData.job ~= nil and PlayerData.job.name == 'unicorn' then
				DrawMarker(2, barmenu[k].x, barmenu[k].y, barmenu[k].z+0.2, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.2, 0.2, 0.2, 204, 204, 204, 200, true, false, 2, true, false, false, false)
			end
            if dist <= 1.0 and PlayerData.job ~= nil and PlayerData.job.name == 'unicorn' then
                DrawSub("Appuyez sur ~p~E ~s~pour faire une boisson.", 1)		
                if IsControlJustPressed(1,51) then
					CreateMenu(menubar)
				end
			end
        end
		for k in pairs(bossmenu) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, bossmenu[k].x, bossmenu[k].y, bossmenu[k].z)
			if dist <= 15.0 and PlayerData.job ~= nil and PlayerData.job.name == 'unicorn' and PlayerData.job.grade_name == 'boss' then
				DrawMarker(2, bossmenu[k].x, bossmenu[k].y, bossmenu[k].z+0.2, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.2, 0.2, 0.2, 204, 204, 204, 200, true, false, 2, true, false, false, false)
			end
            if dist <= 1.0 and PlayerData.job ~= nil and PlayerData.job.name == 'unicorn' and PlayerData.job.grade_name == 'boss' then
                DrawSub("Appuyez sur ~p~E ~s~pour gérer l'entreprise.", 1)		
                if IsControlJustPressed(1,51) then
					TriggerEvent('esx_society:openBossMenu', 'unicorn', function(data, menu)
						menu.close()
					end, { wash = false }) -- disable washing money
				end
			end
		end
		for k,v in pairs(zone) do
            bool, wait, dst = NearZoneOpti(v.zone, 10.0)
            if bool then 
                DrawMarker(20, v.zone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 132, 102, 226, 200, 1, 0, 2, 1, nil, nil, 0)
                if dst <= 1.0 then
					DrawSub("Appuyez sur ~p~E ~s~pour appeler un employé.", 1)
                    if IsControlJustReleased(1, 38) then
                        if not Enattente then
                            Popup("~b~INFORMATION \n~s~Votre appel à été envoyé.")
                            TriggerServerEvent("#{PEOddnq348}@punicorn:AppelDemandeJob", v.job)
                            WaitingDebug()
                        else
                            Popup("~b~INFORMATION \n~s~Tu dois attendre avant de faire un nouvel appel.")
                        end
                    end
                    break
                end
            end
        end
    end
end)

function Popup(msg)
    AddTextEntry('AppelNotif', msg)
    SetNotificationTextEntry("AppelNotif")
    SetNotificationBackgroundColor(140)
    DrawNotification(false, true)
end

function WaitingDebug()
    Enattente = true
    Citizen.CreateThread(function()
        Wait(30*1000)
        Enattente = false
    end)
end

RegisterNetEvent("#{PEOddnq348}@punicorn:GetAppelDemandeJob")
AddEventHandler("#{PEOddnq348}@punicorn:GetAppelDemandeJob", function(job)
	local source = _source
	local TempsAffichage = 30
	
    SetAudioFlag("LoadMPData", true)
    PlaySoundFrontend(-1, "Menu_Accept", "Phone_SoundSet_Default", 1)
    PlaySoundFrontend(-1, "ATM_WINDOW", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
    if job == "unicorn" then
        --Popup("~b~APPEL CITOYEN\n~w~Un citoyen a besoin d'un membre de l'unicorn à la boite de nuit.")

		PlaySoundFrontend(-1, "Menu_Accept", "Phone_SoundSet_Default", 1)
		PlaySoundFrontend(-1, "ATM_WINDOW", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
		if streetName2 ~= "" then
			Popup("~b~APPEL CITOYEN\n~s~Besoin de vous à l'unicorn\n \n~o~POSITION \n~s~Affichée sur le GPS (30sec)")
		else
			Popup("~b~APPEL CITOYEN\n~s~Besoin de vous à l'unicorn\n \n~o~POSITION \n~s~Affichée sur le GPS (30sec)")
		end

		local blip = AddBlipForCoord(127.81, -1300.29, 29.23)
		SetBlipSprite(blip, 459)
		SetBlipScale(blip, 0.5)
		SetBlipColour(blip, 8)

		local radius = AddBlipForRadius(127.81, -1300.29, 29.23, 25.0)
		SetBlipAlpha(radius, 150)
		SetBlipColour(radius, 44)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Appel Unicorn')
		EndTextCommandSetBlipName(blip)
    
		Citizen.Wait(30000)
		RemoveBlip(radius)
		RemoveBlip(blip)
    end
end)

function NearZoneOpti(coords, near)
    local pPed = GetPlayerPed(-1)
    local pCoords = GetEntityCoords(pPed)
    local dst = GetDistanceBetweenCoords(coords, pCoords, true)
    if dst <= near then
        return true, 1, dst
    else
        return false, 500
    end
end

--
-- Developped by lwz#2051
--