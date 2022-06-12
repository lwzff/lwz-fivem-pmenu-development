local sexeSelect = 0
local teteSelect = 0
local colorPeauSelect = 0
local cheveuxSelect = 0
local bebarSelect = -1
local poilsCouleurSelect = 0
local ImperfectionsPeau = 0
local face, acne, skin, eyecolor, skinproblem, freckle, wrinkle, hair, haircolor, eyebrow, beard, beardcolor
local camfin = false

PMenu = {}
PMenu.Data = {}

local playerPed = PlayerPedId()
local incamera = false
local board_scaleform
local handle
local board
local board_model = GetHashKey("prop_police_id_board")
local board_pos = vector3(0.0,0.0,0.0)
local overlay
local overlay_model = GetHashKey("prop_police_id_text")
local isinintroduction = false
local pressedenter = false
local introstep = 0
local timer = 0
local inputgroups = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31}
local enanimcinematique = false
local guiEnabled = false

local sound = false

Citizen.CreateThread(function()
	while true do
        if guiEnabled then
            ESX.UI.HUD.SetDisplay(0.0)
            TriggerEvent('es:setMoneyDisplay', 0.0)
            TriggerEvent('a_status:setDisplay', 0.0)
            DisplayRadar(false)
            TriggerEvent('ui:toggle', false)
			DisableControlAction(0, 1,   true) -- LookLeftRight
			DisableControlAction(0, 2,   true) -- LookUpDown
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 30,  true) -- MoveLeftRight
			DisableControlAction(0, 31,  true) -- MoveUpDown
			DisableControlAction(0, 21,  true) -- disable sprint
			DisableControlAction(0, 24,  true) -- disable attack
			DisableControlAction(0, 25,  true) -- disable aim
			DisableControlAction(0, 47,  true) -- disable weapon
			DisableControlAction(0, 58,  true) -- disable weapon
			DisableControlAction(0, 263, true) -- disable melee
			DisableControlAction(0, 264, true) -- disable melee
			DisableControlAction(0, 257, true) -- disable melee
			DisableControlAction(0, 140, true) -- disable melee
			DisableControlAction(0, 141, true) -- disable melee
			DisableControlAction(0, 143, true) -- disable melee
			DisableControlAction(0, 75,  true) -- disable exit vehicle
			DisableControlAction(27, 75, true) -- disable exit vehicle
		end
		Citizen.Wait(10)
	end
end)




local function LoadScaleform (scaleform)
	local handle = RequestScaleformMovie(scaleform)
	if handle ~= 0 then
		while not HasScaleformMovieLoaded(handle) do
			Citizen.Wait(0)
		end
	end
	return handle
end


local function CreateNamedRenderTargetForModel(name, model)
	local handle = 0
	if not IsNamedRendertargetRegistered(name) then
		RegisterNamedRendertarget(name, 0)
	end
	if not IsNamedRendertargetLinked(model) then
		LinkNamedRendertarget(model)
	end
	if IsNamedRendertargetRegistered(name) then
		handle = GetNamedRendertargetRenderId(name)
	end

	return handle
end

Citizen.CreateThread(function()
	board_scaleform = LoadScaleform("mugshot_board_01")
	handle = CreateNamedRenderTargetForModel("ID_Text", overlay_model)


	while handle do
		SetTextRenderId(handle)
		Set_2dLayer(4)
		Citizen.InvokeNative(0xC6372ECD45D73BCD, 1)
		DrawScaleformMovie(board_scaleform, 0.405, 0.37, 0.81, 0.74, 255, 255, 255, 255, 0)
		Citizen.InvokeNative(0xC6372ECD45D73BCD, 0)
		SetTextRenderId(GetDefaultScriptRendertargetRenderId())

		Citizen.InvokeNative(0xC6372ECD45D73BCD, 1)
		Citizen.InvokeNative(0xC6372ECD45D73BCD, 0)
		Wait(0)
	end
end)

local function CallScaleformMethod (scaleform, method, ...)
	local t
	local args = { ... }

	BeginScaleformMovieMethod(scaleform, method)

	for k, v in ipairs(args) do
		t = type(v)
		if t == 'string' then
			PushScaleformMovieMethodParameterString(v)
		elseif t == 'number' then
			if string.match(tostring(v), "%.") then
				PushScaleformMovieFunctionParameterFloat(v)
			else
				PushScaleformMovieFunctionParameterInt(v)
			end
		elseif t == 'boolean' then
			PushScaleformMovieMethodParameterBool(v)
		end
	end
	EndScaleformMovieMethod()
end


function KeyboardInput(inputText, maxLength) -- Thanks to Flatracer for the function.
    AddTextEntry('FMMC_KEY_TIP12', "")
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP12", "", inputText, "", "", "", maxLength)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end
    if UpdateOnscreenKeyboard() ~= 2 then
        result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
        return result
    else
        Citizen.Wait(500)
        return nil
    end
end

function CreateBoard(ped)
    local plyData = ESX.GetPlayerData()
    RequestModel(board_model)
    while not HasModelLoaded(board_model) do Wait(0) end
    RequestModel(overlay_model)
    while not HasModelLoaded(overlay_model) do Wait(0) end
    board = CreateObject(board_model, GetEntityCoords(ped), false, true, false)
    overlay = CreateObject(overlay_model, GetEntityCoords(ped), false, true, false)
    AttachEntityToEntity(overlay, board, -1, 4103, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    ClearPedWetness(ped)
    ClearPedBloodDamage(ped)
    ClearPlayerWantedLevel(PlayerId())
    SetCurrentPedWeapon(ped, GetHashKey("weapon_unarmed"), 1)
    AttachEntityToEntity(board, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2, 1)
    CallScaleformMethod(board_scaleform, 'SET_BOARD', plyData.job.label, GetPlayerName(PlayerId()), 'LOS SANTOS POLICE DEPT', '' , 0, 1, 116)
end

local FirstSpawn     = true
local LastSkin       = nil
local PlayerLoaded   = false

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerLoaded = true
end)

AddEventHandler('playerSpawned', function()
	Citizen.CreateThread(function()
		while not PlayerLoaded do
			Citizen.Wait(10)
		end
		if FirstSpawn then
			ESX.TriggerServerCallback('a_skin:getPlayerSkin', function(skin, jobSkin)
				if skin == nil then
					TriggerEvent('c_charact:create')
				else
                    TriggerEvent('skinchanger:loadSkin', skin)
                    TriggerEvent('topserveur:openme')
                    spawncinematiqueplayer()
				end
			end)
			FirstSpawn = false
		end
	end)
end)




function SpawnCharacter()
    cam2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 411.30, -998.62, -99.01, 0.00, 0.00, 89.75, 50.00, false, 0)
    PointCamAtCoord(cam2, 411.30, -998.62, -99.01)
    SetCamActiveWithInterp(cam2, cam, 5000, true, true)
end


local testss = {
	Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "Personnage VIP S" },
	Data = { currentMenu = "Nouveau personnage", "Test" },
	Events = {
			onSlide = function(menuData, currentButton, currentSlt, PMenu)
				local currentMenu, ped = menuData.currentMenu, GetPlayerPed(-1)
			if currentMenu == "Nouveau personnage" then
                if currentSlt ~= 1 then return end
                currentButton = currentButton.slidenum - 1
                sex = currentButton
                TriggerEvent('skinchanger:change', 'sex', sex)
            end
          
            if currentMenu == "type de haut" then
                if currentSlt ~= 1 then return end
                local arms = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'arms', arms)
            end
            if currentMenu == "couleur des hauts" then
                if currentSlt ~= 1 then return end
                local arms2 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'arms_2', arms2)
            end
            if currentMenu == "chaine" then
                if currentSlt ~= 1 then return end
                local tshirt1 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'tshirt_1', tshirt1)
            end
            if currentMenu == "couleur chaine" then
                if currentSlt ~= 1 then return end
                local tshirt2 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'tshirt_2', tshirt2)
            end
            if currentMenu == "bas" then
                
                if currentSlt ~= 1 then return end
                local pants1 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'pants_1', pants1)
            end
            if currentMenu == "couleur du bas" then 
               
                if currentSlt ~= 1 then return end
                local pants2 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'pants_2', pants2)
            end

            if currentMenu == "casque" then 
               
                if currentSlt ~= 1 then return end
                local helmet1 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'helmet_1', helmet1)
            end
            if currentMenu == "couleur du casque" then 
               
                if currentSlt ~= 1 then return end
                local helmet2 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'helmet_2', helmet2)
            end

            if currentMenu == "sac" then 
               
                if currentSlt ~= 1 then return end
                local bags1 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'bags_1', bags1)
            end
            if currentMenu == "couleur des sacs" then 
               
                if currentSlt ~= 1 then return end
                local bags2 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'bags_2', bags2)
            end


            if currentMenu == "masque" then 
               
                if currentSlt ~= 1 then return end
                local mask1 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'mask_1', mask1)
            end
            if currentMenu == "couleur du masque" then 
               
                if currentSlt ~= 1 then return end
                local mask2 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'mask_2', mask2)
            end

		end,
			onSelected = function(self, _, btn)

				if btn.name == "~g~Continuer & Sauvegarder" then
					TriggerEvent('skinchanger:getSkin', function(skin)
					TriggerServerEvent('a_skin:save', skin)
					CloseMenu()
				end)
                ESX.ShowNotification("~g~Attention.\n~s~Vous venez d'enregistrer votre personnage.")
            elseif btn == "Customiser le Ped" then
                OpenMenu("Customiser le Ped") 
		end
	end,
},


Menu = {
	["Nouveau personnage"] = {
		useFilter = true,
		b = {
            {name = "Skin", slidemax = 564, Description = "~r~Attention ! ~s~Les skin 'ped' son très beau."},
            {name = "Customiser le Ped",ask = ">", askX = true},
			{name = "~g~Continuer & Sauvegarder", Description = "~r~Attention ! ~s~Si vous acceptez cette étape, vous ne pourrez plus revenir en arrière."},
		}
    },
    

    ["customiser le ped"] = {   
        useFilter = true,        
        b = {
            { name = "Type de haut", ask = "→", askX = true, Description = "Choisissez votre type de haut."},
            { name = "Couleur des hauts", ask = "→", askX = true, Description = "Choisissez votre couleur de haut."},
            {name = "Bas", ask = "→", askX = true, Description = "Choisissez votre bas."},
            {name = "Couleur du bas", ask = "→", askX = true, Description = "Choisissez votre couleur de bas."},
            {name = "Chaine", ask = "→", askX = true, Description = "~r~Attention ! tout les peds ne possèdes pas forcement de chaine ."},
            {name = "Couleur chaine", ask = "→", askX = true, Description = "Choisissez votre couleur de chaine."},
            {name = "Casque", ask = "→", askX = true, Description = "~r~Attention ! tout les peds ne possèdes pas forcement de casque/chapeau ."},
            {name = "Couleur du casque", ask = "→", askX = true, Description = "Choisissez votre couleur de casque."},
            {name = "Masque", ask = "→", askX = true, Description = "~r~Attention ! tout les peds ne possèdes pas forcement de masque ."},
            {name = "Couleur du masque", ask = "→", askX = true, Description = "~r~Attention ! tout les peds ne possèdes pas forcement de masque ."},
            {name = "Sac", ask = "→", askX = true, Description = "~r~Attention ! tout les peds ne possèdes pas forcement de sac ."},
            {name = "Couleur des sacs", ask = "→", askX = true, Description = "~r~Attention ! tout les peds ne possèdes pas forcement de sac ."},
        }
    },

    ["couleur chaine"] = {            
        b = {
            { name = "Couleur chaine", slidemax = 3, Description = "Choisissez votre couleur de t-shirt."},
        }
    },
    ["chaine"] = {            
        b = {
            { name = "chaine", slidemax = 2, Description = "Choisissez votre t-shirt."},
        }
    },

    ["bas"] = {            
        b = {
            { name = "Bas", slidemax = 2, Description = "Choisissez votre bas."},
        }
    },
    ["couleur du bas"] = {            
        b = {
            { name = "Couleur du bas", slidemax = 20, Description = "Choisissez votre couleur de bas."},
        }
    },

    ["casque"] = {            
        b = {
            { name = "Casque", slidemax = 3, Description = "Choisissez votre casque."},
        }
    },
    ["couleur du casque"] = {            
        b = {
            { name = "Couleur du casque", slidemax = 3, Description = "Choisissez votre couleur de casque."},
        }
    },

    
    ["masque"] = {            
        b = {
            { name = "Masque", slidemax = 3, Description = "Choisissez votre masque."},
        }
    },
    ["couleur du masque"] = {            
        b = {
            { name = "Couleur du masque", slidemax = 3, Description = "Choisissez votre couleur de masque."},
        }
    },
  
  
    ["sac"] = {            
        b = {
            { name = "Sac", slidemax = 163, Description = "Choisissez votre type de sac."},
        }
    },
    ["couleur des sacs"] = {            
        b = {
            { name = "Couleur des sacs", slidemax = 10, Description = "Choisissez votre couleur de sac."},
        }
    },
  
    ["Bras"] = {            
        b = {
            { name = "Type de haut", ask = "→", askX = true, Description = "Choisissez votre type de haut."},
            { name = "Couleur des hauts", ask = "→", askX = true, Description = "Choisissez votre couleur de haut."},
        }
    },
    ["type de haut"] = {            
        b = {
            { name = "Type de haut", slidemax = 163, Description = "Choisissez votre type de haut."},
        }
    },
    ["couleur des hauts"] = {            
        b = {
            { name = "Couleur des hauts", slidemax = 10, Description = "Choisissez votre couleur de haut."},
        }
    },
}
}

RegisterCommand("peds", function()
	ESX.TriggerServerCallback('stk_vipS:getVIPSStatus', function(isVIPS)	
		if isVIPS then			
	        CreateMenu(testss)
	    else
			ESX.ShowNotification("Vous devez être vip.")
		end
	end, GetPlayerServerId(PlayerId()), '1')
end) 
