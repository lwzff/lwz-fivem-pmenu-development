ESX              = nil
local PlayerData, Player, tpdivers, antiDupli, isInJoueurMenu = {},  {godMode = false, nonVisible = false}, {"Parking central", "Centre de police", "Hopital", "Aéroport", "Plage"}, 0, false
local isInMetierMenu = {} 
local GetOnscreenKeyboardResult = GetOnscreenKeyboardResult
local showcoord = false
local myPlayerJob = {}
local myPlayerWeapon = {}
local myPlayerOrg = {}
local myPlayerInv = {}
local myPlayerBanque = {}
local myPlayerid = {}
local myPlayerAccount = {}
local myPlayerSale = {}
local WipeData = {} 
local myPlayerremo = {}
local InSpectatorMode	= false
local TargetSpectate	= nil
local LastPosition		= nil
local polarAngleDeg		= 0;
local azimuthAngleDeg	= 90;
local radius			= -3.5;
local cam 				= nil
local PlayerDate		= {}
local ShowInfos			= false
local group
local antispam = true   
local staffmoddd = false
local playerloadout, playerGroup, noclip, godmode, visible = nil, nil, false, false, false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
end)


Admin = {
    actuellementspec = false,
    godmod = false,
    noclip = false,
    supersaut = false,
    staminainfini = false,
    fastrun = false,
    showcoords = false,
    showcrosshair = false
    --nomtete = false
}

local activerposition = true
function activpos()
	activerposition = not activerposition
	local pPed = GetPlayerPed(-1)
	if not activerposition then
		showcoord = true
	elseif activerposition then
		showcoord = false
	end
end
function showplayername()
	showname = not showname
end


local afficherlesnoms = true
function activename()
	afficherlesnoms = not afficherlesnoms
	local pPed = GetPlayerPed(-1)
	if not afficherlesnoms then
		showname = true
	elseif afficherlesnoms then
		showname = false
	end
end


function polar3DToWorld3D(entityPosition, radius, polarAngleDeg, azimuthAngleDeg)
	-- convert degrees to radians
	local polarAngleRad   = polarAngleDeg   * math.pi / 180.0
	local azimuthAngleRad = azimuthAngleDeg * math.pi / 180.0

	local pos = {
		x = entityPosition.x + radius * (math.sin(azimuthAngleRad) * math.cos(polarAngleRad)),
		y = entityPosition.y - radius * (math.sin(azimuthAngleRad) * math.sin(polarAngleRad)),
		z = entityPosition.z - radius * math.cos(azimuthAngleRad)
	}

	return pos
end

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
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

local godmodec = true
function playergodmod()
	godmodec = not godmodec
	local pPed = GetPlayerPed(-1)
	if not godmodec then
		SetEntityInvincible(pPed, true)
		ESX.DrawMissionText("~g~Invincible", 1250)
	elseif godmodec then
		SetEntityInvincible(pPed, false)
		ESX.DrawMissionText("~r~Invincibilité désactivé.", 1250)
	end
end

RegisterNetEvent("{#192AJdn}@:RegisterWarn")
AddEventHandler("{#192AJdn}@:RegisterWarn", function(reason)
    SetAudioFlag("LoadMPData", 1)
    PlaySoundFrontend(-1, "CHARACTER_SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
    ShowFreemodeMessage("WARNED", "Tu à été warn pour: "..reason, 5)
end)
function ShowFreemodeMessage(title, msg, sec)
	local scaleform = _RequestScaleformMovie('MP_BIG_MESSAGE_FREEMODE')

	BeginScaleformMovieMethod(scaleform, 'SHOW_SHARD_WASTED_MP_MESSAGE')
	PushScaleformMovieMethodParameterString(title)
	PushScaleformMovieMethodParameterString(msg)
	EndScaleformMovieMethod()

	while sec > 0 do
		Citizen.Wait(1)
		sec = sec - 0.01

		DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
	end

	SetScaleformMovieAsNoLongerNeeded(scaleform)
end
RegisterNetEvent('c_admin:bringplayer')
AddEventHandler('c_admin:bringplayer', function(plyPedCoords)
	SetEntityCoords(plyPed, plyPedCoords)
end)

function tpplayertome()
	local plyId = KeyboardInput1("CLIPPY_BOX_ID", "", "", 8)

	if plyId ~= nil then
		plyId = tonumber(plyId)
		
		if type(plyId) == 'number' then
			local plyPedCoords = GetEntityCoords(plyPed)
			TriggerServerEvent('c_admin:bringplayer', plyId, plyPedCoords)
		end
	end
end
function retournercar()
    local pPed = GetPlayerPed(-1)
    posped = GetEntityCoords(pPed)
    carspawndep = GetClosestVehicle(posped['x'], posped['y'], posped['z'], 10.0,0,70)
	if carspawndep ~= nil then
		platecarspawndep = GetVehicleNumberPlateText(carspawndep)
	end
    local playerCoords = GetEntityCoords(GetPlayerPed(-1))
    playerCoords = playerCoords + vector3(0, 2, 0)
	SetEntityCoords(carspawndep, playerCoords)
end

function SetFuel(vehicle, fuel)
	if type(fuel) == 'number' and fuel >= 0 and fuel <= 100 then
		SetVehicleFuelLevel(vehicle, fuel + 0.0)
		DecorSetFloat(vehicle, Config.FuelDecor, GetVehicleFuelLevel(vehicle))
	end
end

function _RequestScaleformMovie(movie)
	local scaleform = RequestScaleformMovie(movie)

	while not HasScaleformMovieLoaded(scaleform) do
		Citizen.Wait(0)
	end

	return scaleform
end
function spectate(target)

	ESX.TriggerServerCallback('esx:getPlayerData', function(player)
		if not InSpectatorMode then
			LastPosition = GetEntityCoords(GetPlayerPed(-1))
		end

		local playerPed = GetPlayerPed(-1)

		SetEntityCollision(playerPed, false, false)
		SetEntityVisible(playerPed, false)

		PlayerData = player
		if ShowInfos then
			SendNUIMessage({
				type = 'infos',
				data = PlayerData
			})	
		end

		Citizen.CreateThread(function()

			if not DoesCamExist(cam) then
				cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
			end

			SetCamActive(cam, true)
			RenderScriptCams(true, false, 0, true, true)

			InSpectatorMode = true
			TargetSpectate  = target

		end)
	end, target)

end
function agivemoney()
	local amount = KeyboardInput("CLIPPY_BOX_AMOUNT", "", "", 8)
	if amount ~= nil then
		amount = tonumber(amount)
		if type(amount) == 'number' then
			TriggerServerEvent('soso_admin:givecash', amount)
		end
	end
end
function resetNormalCamera()
	InSpectatorMode = false
    TargetSpectate  = nil

	local playerPed = GetPlayerPed(-1)

	SetCamActive(cam,  false)
	RenderScriptCams(false, false, 0, true, true)

	SetEntityCollision(playerPed, true, true)
	SetEntityVisible(playerPed, true)
	SetEntityCoords(playerPed, LastPosition.x, LastPosition.y, LastPosition.z)
end

function Popup(txt)
	ClearPrints()
	SetNotificationBackgroundColor(140)
	SetNotificationTextEntry("STRING")
	AddTextComponentSubstringPlayerName(txt)
	DrawNotification(false, true)
end

function getCamDirection()
	local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(pPed)
	local pitch = GetGameplayCamRelativePitch()
	local coords = vector3(-math.sin(heading * math.pi / 180.0), math.cos(heading * math.pi / 180.0), math.sin(pitch * math.pi / 180.0))
	local len = math.sqrt((coords.x * coords.x) + (coords.y * coords.y) + (coords.z * coords.z))

	if len ~= 0 then
		coords = coords / len
	end

	return coords
end
local invisible = true
function playerinvisible()
	invisible = not invisible
	local pPed = GetPlayerPed(-1)
	if not invisible then
		SetEntityVisible(pPed, false, false)
		ESX.DrawMissionText("~g~Invisible", 1250)
	elseif invisible then
		SetEntityVisible(pPed, true, false)
		ESX.DrawMissionText("~r~Invisibilité désactivé.", 1250)
	end
end

local noclip = false
local noclip_speed = 0.5

function playernoclip()
	noclip = not noclip
	local ped = GetPlayerPed(-1)
	if noclip then -- activé
		SetEntityVisible(ped, false, false)
		ESX.DrawMissionText("~g~Noclip activé", 1250)
	else -- désactivé
		SetEntityVisible(ped, true, false)
		ESX.DrawMissionText("~r~Noclip désactivé", 1250)
	end
end
function isNoclip()
	return noclip
end

function getCamDirection()
	local heading = GetGameplayCamRelativeHeading()+GetEntityHeading(GetPlayerPed(-1))
	local pitch = GetGameplayCamRelativePitch()

	local x = -math.sin(heading*math.pi/180.0)
	local y = math.cos(heading*math.pi/180.0)
	local z = math.sin(pitch*math.pi/180.0)

	local len = math.sqrt(x*x+y*y+z*z)
	if len ~= 0 then
		x = x/len
		y = y/len
		z = z/len
	end

	return x,y,z
end

function getPosition()
	local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
	return x,y,z
end
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if noclip then
			local ped = GetPlayerPed(-1)
			local x,y,z = getPosition()
			local dx,dy,dz = getCamDirection()
			local speed = noclip_speed
			SetEntityVelocity(ped, 0.0001, 0.0001, 0.0001)
		if IsControlPressed(0,32) then -- MOVE UP
			x = x+speed*dx
			y = y+speed*dy
			z = z+speed*dz
		end
		if IsControlPressed(0,21) then -- Speed
			local speed = 5.5
			x = x+speed*dx
			y = y+speed*dy
			z = z+speed*dz
		end
		if IsControlPressed(0,269) then -- MOVE DOWN
			x = x-speed*dx
			y = y-speed*dy
			z = z-speed*dz
		end
		SetEntityCoordsNoOffset(ped,x,y,z,true,true,true)
		end
	end
end)
    
menuStaff = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, HeaderColor = {255, 255, 255}, Title = "Administration" , Blocked = true },
    Data = { currentMenu = "Administration", "SotekCore" },
    Events = {

        onSelected = function(self, _, btn, PMenu, menuData, currentMenu, currentButton, currentBtn, currentSlt, result, slide)
            PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
            local slide = btn.slidenum
            local button = btn
            local btn = btn.name   
			local check = btn.unkCheckbox
            local currentMenu = self.Data.currentMenu
            local result = GetOnscreenKeyboardResult()
            if btn == "Activer le mode staff" then 
                staffmoddd = not staffmoddd
                if staffmoddd then 
                ESX.ShowNotification("Mode staff ~g~activé")

                table.insert(menuStaff.Menu["Administration"].b, { name = "Liste des joueurs", ask = ">", askX = true })
                table.insert(menuStaff.Menu["Administration"].b, { name = "Personnage", ask = ">", askX = true })
                table.insert(menuStaff.Menu["Administration"].b, { name = "Véhicule", ask = ">", askX = true })
                table.insert(menuStaff.Menu["Administration"].b, { name = "Divers", ask = ">", askX = true }) 
                OpenMenu("Administration")
                else
                    CloseMenu(true)
                    ESX.ShowNotification("Mode staff ~r~désactivé")

                end    
            end

            if btn == "Véhicule" then
                OpenMenu("Véhicule")
            elseif btn == "Faire apparaître un véhicule" then
                local result = KeyboardInput("Sotek",'Voiture', "", 50)
                if result ~= nil then
                    ExecuteCommand("car " .. result)
                    ESX.ShowNotification("~g~Véhicule spawn\n~r~Si aucun véhicule n'est aPPA ru, vérifie que tu as bien écris son nom de spawn")
                else
                    ESX.ShowNotification("~r~Aucun nom saisi")
                end
            elseif btn == "Retourner le véhicule" then 
                retournercar()
            elseif btn == "Modifier la plaque du véhicule" then
                local result = KeyboardInput("Sotek",'Plaque', "", 50)
                local playerPed = GetPlayerPed(-1)
                local plateResult = result
                local plyVehicle = GetVehiclePedIsIn(playerPed)
                if IsPedInAnyVehicle(playerPed, false) then
                    if result ~= nil then
                        SetVehicleNumberPlateText(plyVehicle, result)
                    else
                        ESX.ShowNotification("~r~Aucune plaque saisi")
                    end
                else
                    ESX.ShowNotification("~r~Vous devez être dans un véhicule")
                end
            elseif btn == "Réparer le véhicule" then
                local playerPed = GetPlayerPed(-1)
                local plyVehicle = GetVehiclePedIsIn(playerPed)
                if IsPedInAnyVehicle(playerPed, false) then
                    SetVehicleFixed(plyVehicle)
                    SetVehicleDeformationFixed(plyVehicle)
                    SetVehicleUndriveable(plyVehicle, false)
                    SetVehicleDirtLevel(plyVehicle, 0)
                    SetVehicleEngineOn(plyVehicle, true, true)
                else
                    ESX.ShowNotification("~r~Vous devez être dans un véhicule")
                end
            elseif btn == "~r~Supprimer le véhicule" then
                local playerPed = GetPlayerPed(-1)
                if IsPedInAnyVehicle(playerPed, false) then
                    ExecuteCommand("dv")
                else
                    ESX.ShowNotification("~r~Vous devez être dans un véhicule")
                end
            end

            if btn == "Divers" then 
                OpenMenu("Divers")
            elseif btn == "Se téléporter au marqueur" then
                TeleportToWaypoint()
            elseif btn == "Afficher/cacher le nom des joueurs" then
                afficherlesnoms = not afficherlesnoms
                if afficherlesnoms then
                    showname = false
                else 
                    showname = true
                end
            elseif btn == "Afficher/cacher blips des joueurs" then
               
            elseif btn == "Afficher/cacher les coordonnées" then
                activpos()
            end

  
            if btn == "Personnage" then 
                OpenMenu("Personnage")
            elseif btn == "Mode invincible" then
                playergodmod()
            elseif btn == "Mode invisible" then
                playerinvisible()
            elseif btn == "Noclip" then 
                playernoclip()
            end

            if btn == "Liste des joueurs" then
                menuStaff.Menu["Liste des joueurs"].b = {}
                    for _, playerId in ipairs(GetActivePlayers()) do
                        local plyName = GetPlayerName(playerId)
                        local plyId = GetPlayerServerId(playerId)
                        table.insert(menuStaff.Menu["Liste des joueurs"].b, { name = GetPlayerName(playerId), ask = "ID : ~b~" .. GetPlayerServerId(playerId) .. "~s~ →", askX = true, playerId = plyId})
                    end
                OpenMenu("Liste des joueurs")
                isInJoueurMenu = true
            end
            if isInJoueurMenu then
                for k, v in pairs(menuStaff.Menu["Liste des joueurs"].b) do
                    if v.name == btn then
                        menuPlayerId = v.playerId
                        menuPlayer = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                        menuPlayerName = v.name
                        if antispam then
                            table.insert(menuStaff.Menu["Gestion du joueur"].b,{ name = "Réanimer", ask = "", askX = true })
                            table.insert(menuStaff.Menu["Gestion du joueur"].b,{ name = "Envoyer un message privé au joueur", ask = "→", askX = true })
                            table.insert(menuStaff.Menu["Gestion du joueur"].b,{ name = "Sac à dos du joueur", ask = "→", askX = true })
                            table.insert(menuStaff.Menu["Gestion du joueur"].b,{ name = "Se téléporter au joueur", ask = "→", askX = true })
                            table.insert(menuStaff.Menu["Gestion du joueur"].b,{ name = "Se téléporter dans la voiture du joueur", ask = "→", askX = true })
                            table.insert(menuStaff.Menu["Gestion du joueur"].b,{ name = "Téléporter le joueur à moi", ask = "→", askX = true })
                            table.insert(menuStaff.Menu["Gestion du joueur"].b, { name = "Spectate le joueur", checkbox = false , Description = "~g~N'oublie pas de jouer avec ta molette pour zoomer et dezoomer"})
                            table.insert(menuStaff.Menu["Gestion du joueur"].b,{ name = "Modifier le métier du joueur", ask = "→", askX = true })

                        if playerGroup ~= nil and (playerGroup == 'superadmin' or playerGroup == 'owner') then
                           
                            table.insert(menuStaff.Menu["Gestion du joueur"].b, { name = "Donner un item", ask = "→", askX = true })
                            table.insert(menuStaff.Menu["Gestion du joueur"].b,{ name = "Donner une arme ", ask = "→", askX = true})
                        end
                        table.insert(menuStaff.Menu["Gestion du joueur"].b,{ name = "Freeze le joueur", checkbox = false })
                        table.insert(menuStaff.Menu["Gestion du joueur"].b, { name = "Warn le joueur", ask = "→", askX = true })
                        table.insert(menuStaff.Menu["Gestion du joueur"].b, { name = "Kick le joueur", ask = "→", askX = true })
                        if playerGroup ~= nil and (playerGroup == 'superadmin' or playerGroup == 'owner') then
                           
                            table.insert(menuStaff.Menu["Gestion du joueur"].b, { name = "~r~Wipe le joueur" , ask = "" , askX = true , Description = "~r~Attention aucun retour en arrière est possible"})
                        end
                        antispam = false
                    end
                        OpenMenu("Gestion du joueur")
                    end
                end

                if btn == "~r~Wipe le joueur" then
                    ESX.TriggerServerCallback("{@Wzn394}#:id", function(myPlayerid)
                        WipeData.ID = myPlayerid
                        if  WipeData.ID then 
                        TriggerServerEvent('{#04WNWejd}@:PlayerWipe',  WipeData, menuPlayerId, GetPlayerName(GetPlayerFromServerId(menuPlayerId)))	
                        ESX.ShowNotification('~b~INFORMATION\n\n~w~Tu as wipe '..menuPlayerName)
                        end
                      end,menuPlayerId)
                end
                if btn == "Réanimer" then 
                    TriggerServerEvent('esx_ambulancejob:revive2',menuPlayerId )
                    ESX.ShowNotification("Tu as réanimer ~b~"..menuPlayerName)

                end
                if btn == "Se téléporter au joueur" then
                    local plyPedCoords = GetEntityCoords(plyPed)
                    SetEntityCoords(PlayerPedId(), GetEntityCoords(menuPlayer))
                    ESX.ShowNotification("Tu t'es téléporter à ~b~"..menuPlayerName)

                elseif btn == "Se téléporter dans la voiture du joueur" then
                    if IsPedSittingInAnyVehicle(menuPlayer) then
                        TaskWarpPedIntoVehicle(GetPlayerPed(-1), GetVehiclePedIsIn(menuPlayer), -2)
                        ESX.ShowNotification("Tu t'es téléporter dans la voiture de ~b~"..menuPlayerName)

                    else
                        ESX.ShowNotification("~b~" .. menuPlayerName .. "~s~ n'est pas dans un véhicule")
                    end
                elseif btn == "Téléporter le joueur à moi" then

                    if menuPlayerId ~= nil then
                      
              
                            local plyPedCoords = GetEntityCoords(plyPed)
                            TriggerServerEvent('c_admin:bringplayer', menuPlayerId, plyPedCoords)
                            ESX.ShowNotification(  "~s~ tu as apporté ~b~".. menuPlayerName .."~s~ sur toi")

                    end

                elseif btn == "Freeze le joueur" then

                    Player.Frozen = not Player.Frozen
                    if Player.Frozen then
                        ExecuteCommand("freeze "..menuPlayerId)
                        --FreezeEntityPosition(menuPlayer, true)
                        --SetPlayerInvincible(menuPlayer, true)
                        --SetEntityCollision(menuPlayer, false)
                        --TaskLeaveVehicle(menuPlayer, GetVehiclePedIsIn(menuPlayer), 0)
                        ESX.ShowNotification("Vous avez freeze ~b~" .. menuPlayerName)
                    else
                        ExecuteCommand("freeze "..menuPlayerId)
                        --FreezeEntityPosition(menuPlayer, false)
                        --SetPlayerInvincible(menuPlayer, false)
                        --SetEntityCollision(menuPlayer, true)
                        ESX.ShowNotification("Vous avez unfreeze ~b~" .. menuPlayerName)
                    end
                elseif btn == "Modifier le métier du joueur" then

                    isInMetierMenu = true
                    OpenMenu("Liste des métiers")
                end
                if btn == "LSPD" then 
                    menuStaff.Menu["LSPD"].b = {}
                    table.insert(menuStaff.Menu["LSPD"].b, { name = "Cadet [0]", ask = "", askX = true})
                    table.insert(menuStaff.Menu["LSPD"].b, { name = "Officier 1 [1]", ask = "", askX = true })
                    table.insert(menuStaff.Menu["LSPD"].b, { name = "Officier 2 [2]", ask = "", askX = true })
                    table.insert(menuStaff.Menu["LSPD"].b, { name = "Officier 3 [3]", ask = "", askX = true })
                    table.insert(menuStaff.Menu["LSPD"].b, { name = "Sergent 1 [4]", ask = "", askX = true })
                    table.insert(menuStaff.Menu["LSPD"].b, { name = "Sergent 2 [5]", ask = "", askX = true })
                    table.insert(menuStaff.Menu["LSPD"].b, { name = "Sergent 3 [6]", ask = "", askX = true })
                    table.insert(menuStaff.Menu["LSPD"].b, { name = "Lieutenant 1 [7]", ask = "", askX = true })
                    table.insert(menuStaff.Menu["LSPD"].b, { name = "Lieutenant 2 [8]", ask = "", askX = true })
                    table.insert(menuStaff.Menu["LSPD"].b, { name = "Lieutenant 3 [9]", ask = "", askX = true })
                    table.insert(menuStaff.Menu["LSPD"].b, { name = "Capitaine [10]", ask = "", askX = true })
                    table.insert(menuStaff.Menu["LSPD"].b, { name = "Commandant [11]", ask = "", askX = true })
                    OpenMenu("LSPD")
                end
                if btn == "Cadet [0]" then 
                    lspd = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'police', '0')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Cadet de la police' )
                elseif btn == "Officier 1 [1]" then
                    lspd = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'police', '1')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Officier 1 de la police' )
                elseif btn == "Officier 2 [2]" then
                    lspd = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'police', '2')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Officier 2 de la police' )
                elseif btn == "Officier 3 [3]" then
                    lspd = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'police', '3')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Officier 3 de la police' )
                elseif btn == "Sergent 1 [4]" then
                    lspd = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'police', '4')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Sergent 1 de la police' )
                elseif btn == "Sergent 2 [5]" then
                    lspd = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'police', '5')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Sergent 2 de la police' )
                elseif btn == "Sergent 3 [6]" then
                    lspd = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'police', '6')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Sergent 3 de la police' )
                elseif btn == "Lieutenant 1 [7]" then
                    lspd = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'police', '7')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Lieutenant 1 de la police' )
                elseif btn == "Lieutenant 2 [8]" then
                    lspd = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'police', '8')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Lieutenant 2 de la police' )
                elseif btn == "Lieutenant 3 [9]" then
                    lspd = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'police', '9')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Lieutenant 3 de la police' )
                elseif btn == "Capitaine [10]" then
                    lspd = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'police', '10')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Capitaine de la police' )
                elseif btn == "Commandant [11]" then
                    lspd = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'police', '11')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Commandant de la police' )
                end
                if btn == "EMS" then 
                    menuStaff.Menu["EMS"].b = {}
                    table.insert(menuStaff.Menu["EMS"].b, { name = "Ambulancier [0]", ask = "", askX = true})
                    table.insert(menuStaff.Menu["EMS"].b, { name = "Médecin [1]", ask = "", askX = true})
                    table.insert(menuStaff.Menu["EMS"].b, { name = "Chef-médecin [2]", ask = "", askX = true})
                    table.insert(menuStaff.Menu["EMS"].b, { name = "Directeur [3]", ask = "", askX = true})

                    OpenMenu("EMS")
                elseif btn == "Ambulancier [0]" then
                    ems = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'ambulance', '0')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Ambulancier des EMS' )
                elseif btn == "Médecin [1]" then
                    ems = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'ambulance', '1')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Médecin des EMS' )
                elseif btn == "Chef-médecin [2]" then
                    ems = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'ambulance', '2')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Chef-médecin des EMS' )
                elseif btn == "Directeur [3]" then
                    ems = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'ambulance', '3')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Directeur des EMS' )
                end

                if btn == "Concessionnaire Auto" then
                    menuStaff.Menu["Concessionnaire Auto"].b = {}
                    table.insert(menuStaff.Menu["Concessionnaire Auto"].b, { name = "Stagiaire [0]", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Concessionnaire Auto"].b, { name = "Employé [1]", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Concessionnaire Auto"].b, { name = "Responsable [2]", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Concessionnaire Auto"].b, { name = "Patron [3]   ", ask = "", askX = true})
                    OpenMenu('Concessionnaire Auto')
                elseif btn == "Stagiaire [0]" then
                    Auto = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'cardealer', '0')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Stagiaire du Concessionnaire Auto' )
                elseif btn == "Employé [1]" then
                    Auto = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'cardealer', '1')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Employé du Concessionnaire Auto' )
                elseif btn == "Responsable [2]" then
                    Auto = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'cardealer', '2')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Responsable du Concessionnaire Auto' )
                elseif btn == "Patron [3]   " then
                    Auto = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'cardealer', '3')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Patron du Concessionnaire Auto' )
                end

                if btn == "Concessionnaire Moto" then
                    menuStaff.Menu["Concessionnaire Moto"].b = {}
                    table.insert(menuStaff.Menu["Concessionnaire Moto"].b, { name = "Recrue [0]", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Concessionnaire Moto"].b, { name = "Novice [1]", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Concessionnaire Moto"].b, { name = "Experimenté [2]", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Concessionnaire Moto"].b, { name = "Patron [3]  ", ask = "", askX = true})
                    OpenMenu('Concessionnaire Moto')
                elseif btn == "Recrue [0]" then
                    Moto = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'motorcycle', '0')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Recrue du Concessionnaire Moto' )
                elseif btn == "Novice [1]" then
                    Moto = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'motorcycle', '1')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Novice du Concessionnaire Moto' )
                elseif btn == "Experimenté [2]" then
                    Moto = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'motorcycle', '2')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Experimenté du Concessionnaire Moto' )
                elseif btn == "Patron [3]  " then
                    Moto = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'motorcycle', '3')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. '~s~ Patron du Concessionnaire Moto' )
                end

                if btn == "Agent immobilier" then
                    menuStaff.Menu["Agent immobilier"].b = {}
                    table.insert(menuStaff.Menu["Agent immobilier"].b, { name = "Location [0]", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Agent immobilier"].b, { name = "Vendeur [1]", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Agent immobilier"].b, { name = "Gestion [2]", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Agent immobilier"].b, { name = "Patron& [3] ", ask = "", askX = true})
                    OpenMenu('Agent immobilier')
                elseif btn == "Location [0]" then
                    Agent = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'realestateagent', '0')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. "~s~ Location de l'Agence immobilière" )
                elseif btn == "Vendeur [1]" then
                    Agent = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("Sotek-{#192AJdn}@:SetJob", menuPlayerId, 'realestateagent', '1')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. "~s~ Vendeur de l'Agence immobilière" )
                elseif btn == "Gestion [2]" then
                    Agent = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'realestateagent', '2')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. "~s~ Gestion de l'Agence immobilière" )
                elseif btn == "Patron [3] " then 
                    Agent = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'realestateagent', '3')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. "~s~ Patron de l'Agence immobilière" )
                end

                if btn == "Orpailleur" then
                    menuStaff.Menu["Orpailleur"].b = {}
                    table.insert(menuStaff.Menu["Orpailleur"].b, { name = "Intermédaire [0]", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Orpailleur"].b, { name = "Orpailleur [1]", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Orpailleur"].b, { name = "Chef de chai [2]", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Orpailleur"].b, { name = "Patron [3]     ", ask = "", askX = true})
                    OpenMenu('Orpailleur')
                elseif btn == "Intermédaire [0]" then
                    Agent = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'orpailleur', '0')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. "~s~ Intermédaire des Orpailleurs" )
                elseif btn == "Orpailleur [1]" then
                    Agent = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'orpailleur', '1')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. "~s~ Orpailleur des Orpailleurs" )
                elseif btn == "Chef de chai [2]" then
                    Agent = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'orpailleur', '2')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. "~s~ Gestion des Orpailleurs" )
                elseif btn == "Patron [3]     " then 
                    Agent = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'orpailleur', '3')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. "~s~ Patron des Orpailleurs" )
                end

                if btn == "Tabac" then
                    menuStaff.Menu["Tabac"].b = {}
                    table.insert(menuStaff.Menu["Tabac"].b, { name = "Stagiaire [0]  ", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Tabac"].b, { name = "Intermédiaire [1]", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Tabac"].b, { name = "Responsable [2] ", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Tabac"].b, { name = "Co Patron [3] ", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Tabac"].b, { name = "Patron [4]", ask = "", askX = true})
                    OpenMenu('Tabac')
                elseif btn == "Stagiaire [0]  " then
                    Agent = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'tabac', '0')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. "~s~ Stagiaire du Tabac" )
                elseif btn == "Intermédiaire [1]" then
                    Agent = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'tabac', '1')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. "~s~ Intermédiaire du Tabac" )
                elseif btn == "Responsable [2] " then
                    Agent = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'tabac', '2')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. "~s~ Responsable du Tabac" )
                elseif btn == "Co Patron [3] " then 
                    Agent = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'tabac', '3')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. "~s~ Co Patron du Tabac" )
                
                elseif btn == "Patron [4]" then 
                    Agent = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'tabac', '4')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. "~s~ Patron du Tabac" )
                end

                if btn == "Vigneron" then
                    menuStaff.Menu["Vigneron"].b = {}
                    table.insert(menuStaff.Menu["Vigneron"].b, { name = "Stagiaire [0]    ", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Vigneron"].b, { name = "Employé [1]   ", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Vigneron"].b, { name = "Responsable [2]  ", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Vigneron"].b, { name = "Patron [3]        ", ask = "", askX = true})
                    OpenMenu('Vigneron')
                elseif btn == "Stagiaire [0]    " then
                    Agent = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'vigneron', '0')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. "~s~ Stagiaire des Vignerons" )
                elseif btn == "Employé [1]   " then
                    Agent = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'vigneron', '1')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. "~s~ Employé des Vignerons" )
                elseif btn == "Responsable [2]  " then
                    Agent = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'vigneron', '2')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. "~s~ Gestion des Vignerons" )
                elseif btn == "Patron [3]        " then 
                    Agent = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, 'vigneron', '3')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. "~s~ Patron des Vignerons" )
                end

                if btn == "Vendeur d'armes" then
                    menuStaff.Menu["Vendeur d'armes"].b = {}
                    table.insert(menuStaff.Menu["Vendeur d'armes"].b, { name = "Légère [0]", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Vendeur d'armes"].b, { name = "Lourde [1]", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Vendeur d'armes"].b, { name = "Patron [2]", ask = "", askX = true})
                    OpenMenu("Vendeur d'armes")
                elseif btn == "Légère [0]" then
                    Agent = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, "ventearmes", '0')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. "~s~ Légère des Vendeur d'armes" )
                elseif btn == "Lourde [1]" then
                    Agent = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, "ventearmes", '1')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. "~s~ Lourde des Vendeur d'armes" )
                elseif btn == "Patron [2]" then
                    Agent = GetPlayerPed(GetPlayerFromServerId(menuPlayerId))
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, "ventearmes", '2')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. "~s~ Patron des Vendeur d'armes" )
                end

                if btn == "Chômeur" then
                    TriggerServerEvent("{#192AJdn}@:SetJob", menuPlayerId, "unemployed", '0')
                    ESX.ShowNotification('~r~Information\n~s~Tu as mis ~b~' .. menuPlayerName .. "~s~ Chômeur" )
                end
                if btn == "Envoyer un message privé au joueur" then 
                    AddTextEntry("Entrer la raison", "Entrer le message que vous voulez transmettre")
                    DisplayOnscreenKeyboard(1, "Entrer la raison", '', "", '', '', '', 128)
                    TriggerServerEvent("{#04WNWejd}@:SendMsgToPlayer", menuPlayerId, msg)
                    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
						Citizen.Wait(0)
                    end
                    if UpdateOnscreenKeyboard() ~= 2 then
						msg = GetOnscreenKeyboardResult()
                        Citizen.Wait(1)
                    end
                    TriggerServerEvent("{#04WNWejd}@:SendMsgToPlayer", menuPlayerId, msg)
                end
                if btn == "Warn le joueur" then 
                    menuStaff.Menu["Warn le joueur"].b = {}
                    table.insert(menuStaff.Menu["Warn le joueur"].b, { name = "Freekill", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Warn le joueur"].b, { name = "Provocation inutile (Force Rp)", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Warn le joueur"].b, { name = "HRP vocal", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Warn le joueur"].b, { name = "Conduite HRP", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Warn le joueur"].b, { name = "NoFear", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Warn le joueur"].b, { name = "NoPain", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Warn le joueur"].b, { name = "Parle coma", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Warn le joueur"].b, { name = "Troll", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Warn le joueur"].b, { name = "Powergaming", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Warn le joueur"].b, { name = "Insultes", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Warn le joueur"].b, { name = "Non respect du staff", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Warn le joueur"].b, { name = "Metagaming", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Warn le joueur"].b, { name = "ForceRP", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Warn le joueur"].b, { name = "Freeshoot", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Warn le joueur"].b, { name = "Freepunch", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Warn le joueur"].b, { name = "Non respect du masse RP", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Warn le joueur"].b, { name = "Vol de véhicule en zone safe", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Warn le joueur"].b, { name = "Vol de véhicule de fonction", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Warn le joueur"].b, { name = "Autre ( entrer une raison )", ask = "", askX = true})



                    OpenMenu("Warn le joueur")
                elseif btn == "Freekill" then 
                    TriggerServerEvent("{#192AJdn}@:RegisterWarn", menuPlayerId, "Freekill")
                    ESX.ShowNotification("Tu as Warn pour Freekill ~b~"..menuPlayerName)
                elseif btn == "Provocation inutile (Force Rp)" then 
                    TriggerServerEvent("{#192AJdn}@:RegisterWarn", menuPlayerId, "Provocation inutile (Force Rp)")
                    ESX.ShowNotification("Tu as Warn pour Freekill ~b~"..menuPlayerName)

                elseif btn == "HRP vocal" then 
                    TriggerServerEvent("{#192AJdn}@:RegisterWarn", menuPlayerId, "HRP vocal")
                    ESX.ShowNotification("Tu as Warn pour Freekill ~b~"..menuPlayerName)

                    elseif btn == "Conduite HRP" then 
                    TriggerServerEvent("{#192AJdn}@:RegisterWarn", menuPlayerId, "Conduite HRP")
                    ESX.ShowNotification("Tu as Warn pour Freekill ~b~"..menuPlayerName)

                elseif btn == "NoFear" then 
                    TriggerServerEvent("{#192AJdn}@:RegisterWarn", menuPlayerId, "NoFear")
                    ESX.ShowNotification("Tu as Warn "..menuPlayerName.." pour NoFear ~b~")

                elseif btn == "NoPain" then 
                    TriggerServerEvent("{#192AJdn}@:RegisterWarn", menuPlayerId, "NoPain")
                    ESX.ShowNotification("Tu as Warn "..menuPlayerName.." pour NoPain ~b~")

                elseif btn == "Parle coma" then 
                    TriggerServerEvent("{#192AJdn}@:RegisterWarn", menuPlayerId, "Parle coma")
                    ESX.ShowNotification("Tu as Warn "..menuPlayerName.." pour Parle coma ~b~")

                elseif btn == "Troll" then 
                    TriggerServerEvent("{#192AJdn}@:RegisterWarn", menuPlayerId, "Troll")
                    ESX.ShowNotification("Tu as Warn "..menuPlayerName.." pour Troll ~b~")

                elseif btn == "Powergaming" then 
                    TriggerServerEvent("{#192AJdn}@:RegisterWarn", menuPlayerId, "Powergaming")
                    ESX.ShowNotification("Tu as Warn "..menuPlayerName.." pour Powergaming ~b~")

                elseif btn == "Insultes" then 
                    TriggerServerEvent("{#192AJdn}@:RegisterWarn", menuPlayerId, "Insultes")
                    ESX.ShowNotification("Tu as Warn "..menuPlayerName.." pour Insultes ~b~")

                elseif btn == "Non respect du staff" then 
                    TriggerServerEvent("{#192AJdn}@:RegisterWarn", menuPlayerId, "Non respect du staff")
                    ESX.ShowNotification("Tu as Warn "..menuPlayerName.." pour Non respect du staff ~b~")

                elseif btn == "Metagaming" then 
                    TriggerServerEvent("{#192AJdn}@:RegisterWarn", menuPlayerId, "Metagaming")
                    ESX.ShowNotification("Tu as Warn "..menuPlayerName.." pour Metagaming ~b~")

                elseif btn == "ForceRP" then 
                    TriggerServerEvent("{#192AJdn}@:RegisterWarn", menuPlayerId, "ForceRP")
                    ESX.ShowNotification("Tu as Warn "..menuPlayerName.." pour ForceRP ~b~")

                elseif btn == "Freeshoot" then 
                    TriggerServerEvent("{#192AJdn}@:RegisterWarn", menuPlayerId, "Freeshoot")
                    ESX.ShowNotification("Tu as Warn "..menuPlayerName.." pour Freeshoot ~b~")

                elseif btn == "Freepunch" then 
                    TriggerServerEvent("{#192AJdn}@:RegisterWarn", menuPlayerId, "Freepunch")
                    ESX.ShowNotification("Tu as Warn "..menuPlayerName.." pour Freepunch ~b~")

                elseif btn == "Non respect du masse RP" then 
                    TriggerServerEvent("{#192AJdn}@:RegisterWarn", menuPlayerId, "Non respect du masse RP")
                    ESX.ShowNotification("Tu as  Warn "..menuPlayerName.." pour Non respect du masse RP ~b~")

                elseif btn == "Vol de véhicule en zone safe" then 
                    TriggerServerEvent("{#192AJdn}@:RegisterWarn", menuPlayerId, "Vol de véhicule en zone safe")
                    ESX.ShowNotification("Tu as Warn "..menuPlayerName.." pour Vol de véhicule en zone safe ~b~")

                elseif btn == "Vol de véhicule de fonction" then 
                    TriggerServerEvent("{#192AJdn}@:RegisterWarn", menuPlayerId, "Vol de véhicule de fonction")
                    ESX.ShowNotification("Tu as Warn "..menuPlayerName.." pour Vol de véhicule de fonction ~b~")

                elseif btn == "Autre ( entrer une raison )" then 
                    local raison =  KeyboardInput("Sotek",'Raison', "", 50)
                        TriggerServerEvent("{#192AJdn}@:RegisterWarn", menuPlayerId, raison)
                        ESX.ShowNotification("Tu as Warn pour "..raison.."~b~ "..menuPlayerName)

                end

                if btn == "Kick le joueur" then 
                    menuStaff.Menu["Kick le joueur"].b = {}
                    table.insert(menuStaff.Menu["Kick le joueur"].b, { name = "Troll ", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Kick le joueur"].b, { name = "NoFear ", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Kick le joueur"].b, { name = "NoPain ", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Kick le joueur"].b, { name = "Insulte ", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Kick le joueur"].b, { name = "HRP ", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Kick le joueur"].b, { name = "AFK ", ask = "", askX = true})
                    table.insert(menuStaff.Menu["Kick le joueur"].b, { name = "Autre (Entrer la raison) ", ask = "", askX = true})

                    OpenMenu("Kick le joueur")
                elseif btn == "Troll " then
                    TriggerServerEvent("{#192AJdn}@:Kick", menuPlayerId, "Tu as été kick pour : Troll")
                elseif btn == "NoFear " then
                    TriggerServerEvent("{#192AJdn}@:Kick", menuPlayerId, "Tu as été kick pour : NoFear")
                elseif btn == "NoPain " then
                    TriggerServerEvent("{#192AJdn}@:Kick", menuPlayerId, "Tu as été kick pour : NoPain")
                elseif btn == "Insulte " then
                    TriggerServerEvent("{#192AJdn}@:Kick", menuPlayerId, "Tu as été kick pour : Insulte")
                elseif btn == "HRP " then
                    TriggerServerEvent("{#192AJdn}@:Kick", menuPlayerId, "Tu as été kick pour : HRP")
                elseif btn == "AFK " then
                    TriggerServerEvent("{#192AJdn}@:Kick", menuPlayerId, "Tu as été kick pour : AFK")
                elseif btn == "Autre (Entrer la raison) " then
                    local raisonkick =  KeyboardInput("Sotek",'Raison', "", 50)
                    TriggerServerEvent("{#192AJdn}@:Kick", menuPlayerId, "Tu as été kick pour : " ..raisonkick)
                end
                if btn == "Sac à dos du joueur" then 
             

                    menuStaff.Menu["Sac à dos du joueur"].b = {}
                    table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Inventaire" , ask = ">" , askX = true })
                    if playerGroup ~= nil and (playerGroup == 'superadmin' or playerGroup == 'owner') then
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Effacer tout l'inventaire du joueur" , ask = "" , askX = true })
                    end

                    table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Armes" , ask = ">" , askX = true })
                    if playerGroup ~= nil and (playerGroup == 'superadmin' or playerGroup == 'owner') then
                    table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Enlever toute les armes du joueur" , ask = "" , askX = true })
                    end

                    local playerId = menuPlayerId
                    ESX.TriggerServerCallback("{@Wzn394}#:getJobs", function(myPlayerJob)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Métier : ~b~" .. myPlayerJob.label .. "~s~ - ~b~" .. myPlayerJob.grade } )
                    end, menuPlayerId)

                    ESX.TriggerServerCallback("{@Wzn394}#:getOrgs", function( myPlayerOrg)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Organisation : ~b~" .. myPlayerOrg.label .. "~s~ - ~b~" .. myPlayerOrg.gradeorg_label .. " ~s~(~b~" .. myPlayerOrg.gradeorg .. "~s~)"})
                    end, menuPlayerId)

                    ESX.TriggerServerCallback("{@Wzn394}#:money", function( myPlayerMoney)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Liquide : ~g~" .. myPlayerMoney .. "$" , slidemax = {"Give ", "Retirer"}})

                    end, menuPlayerId)
                    ESX.TriggerServerCallback("{@Wzn394}#:banque", function( myPlayerBanque)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Banque : ~g~" .. myPlayerBanque[1].money .. "$", slidemax = {"Give", "Retirer "}})

                    end, menuPlayerId)

                    ESX.TriggerServerCallback("{@Wzn394}#:sale", function( myPlayerSale)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Argent Sale : ~g~" .. myPlayerSale[2].money .. "$", slidemax = {"Give  ", "Retirer  "}})

                    end, menuPlayerId)

                    Wait(181)
                    OpenMenu('Sac à dos du joueur')
                end
                if button.slidename == "Give " then
                    menuStaff.Menu["Sac à dos du joueur"].b = {}

                    amount = KeyboardInput("Sotek",'Give Liquide', "", 8)
                    TriggerServerEvent('soso_admin:momo',menuPlayerId, amount)
                    ESX.ShowNotification("Tu as donné ~g~"..amount.."$~s~à ~b~"..menuPlayerName)

                    CloseMenu()
                    
                    table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Inventaire" , ask = ">" , askX = true })
                    if playerGroup ~= nil and (playerGroup == 'superadmin' or playerGroup == 'owner') then
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Effacer tout l'inventaire du joueur" , ask = "" , askX = true })
                    end

                    table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Armes" , ask = ">" , askX = true })
                    if playerGroup ~= nil and (playerGroup == 'superadmin' or playerGroup == 'owner') then
                    table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Enlever toute les armes du joueur" , ask = "" , askX = true })
                    end

                    local playerId = menuPlayerId
                    ESX.TriggerServerCallback("{@Wzn394}#:getJobs", function(myPlayerJob)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Métier : ~b~" .. myPlayerJob.label .. "~s~ - ~b~" .. myPlayerJob.grade } )
                    end, menuPlayerId)

                    ESX.TriggerServerCallback("{@Wzn394}#:getOrgs", function( myPlayerOrg)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Organisation : ~b~" .. myPlayerOrg.label .. "~s~ - ~b~" .. myPlayerOrg.gradeorg_label .. " ~s~(~b~" .. myPlayerOrg.gradeorg .. "~s~)"})
                    end, menuPlayerId)
                    ESX.TriggerServerCallback("{@Wzn394}#:money", function( myPlayerMoney)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Liquide : ~g~" .. myPlayerMoney .. "$" , slidemax = {"Give ", "Retirer"}})
                    end, menuPlayerId)
                    ESX.TriggerServerCallback("{@Wzn394}#:banque", function( myPlayerBanque)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Banque : ~g~" .. myPlayerBanque[1].money .. "$", slidemax = {"Give", "Retirer "}})
                    end, menuPlayerId)
                    ESX.TriggerServerCallback("{@Wzn394}#:sale", function( myPlayerSale)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Argent Sale : ~g~" .. myPlayerSale[2].money .. "$", slidemax = {"Give  ", "Retirer  "}})
                    end, menuPlayerId)

                    Wait(181)
                    OpenMenu('Sac à dos du joueur')
                end
                if button.slidename == "Retirer" then
                    amount = KeyboardInput("Sotek",'Retirer Liquide', "", 8)
                    TriggerServerEvent('soso_admin:removemoeney',menuPlayerId, amount)
                    ESX.ShowNotification("Tu as retiré ~g~"..amount.."$~s~à ~b~"..menuPlayerName)

                    CloseMenu()
                    menuStaff.Menu["Sac à dos du joueur"].b = {}
                    table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Inventaire" , ask = ">" , askX = true })
                    if playerGroup ~= nil and (playerGroup == 'superadmin' or playerGroup == 'owner') then
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Effacer tout l'inventaire du joueur" , ask = "" , askX = true })
                    end

                    table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Armes" , ask = ">" , askX = true })
                    if playerGroup ~= nil and (playerGroup == 'superadmin' or playerGroup == 'owner') then
                    table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Enlever toute les armes du joueur" , ask = "" , askX = true })
                    end

                    local playerId = menuPlayerId
                    ESX.TriggerServerCallback("{@Wzn394}#:getJobs", function(myPlayerJob)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Métier : ~b~" .. myPlayerJob.label .. "~s~ - ~b~" .. myPlayerJob.grade } )
                    end, menuPlayerId)

                    ESX.TriggerServerCallback("{@Wzn394}#:getOrgs", function( myPlayerOrg)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Organisation : ~b~" .. myPlayerOrg.label .. "~s~ - ~b~" .. myPlayerOrg.gradeorg_label .. " ~s~(~b~" .. myPlayerOrg.gradeorg .. "~s~)"})
                    end, menuPlayerId)
                    ESX.TriggerServerCallback("{@Wzn394}#:money", function( myPlayerMoney)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Liquide : ~g~" .. myPlayerMoney .. "$" , slidemax = {"Give ", "Retirer"}})
                    end, menuPlayerId)
                    ESX.TriggerServerCallback("{@Wzn394}#:banque", function( myPlayerBanque)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Banque : ~g~" .. myPlayerBanque[1].money .. "$", slidemax = {"Give", "Retirer "}})
                    end, menuPlayerId)
                    ESX.TriggerServerCallback("{@Wzn394}#:sale", function( myPlayerSale)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Argent Sale : ~g~" .. myPlayerSale[2].money .. "$", slidemax = {"Give  ", "Retirer  "}})
                    end, menuPlayerId)

                    Wait(181)
                    OpenMenu('Sac à dos du joueur')
                end
                

                if button.slidename == "Give" then
                    local amount = KeyboardInput("SosoBox", "Banque", "", 8)
                    if amount ~= nil then
                        amount = tonumber(amount)
                        if type(amount) == 'number' then
                            TriggerServerEvent('soso_admin:momobanque',menuPlayerId, amount)
                            ESX.ShowNotification("Tu as donné ~g~"..amount.."$~s~ en banque à ~b~"..menuPlayerName)

                        end
                    end

                    CloseMenu()
                    menuStaff.Menu["Sac à dos du joueur"].b = {}
                    table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Inventaire" , ask = ">" , askX = true })
                    if playerGroup ~= nil and (playerGroup == 'superadmin' or playerGroup == 'owner') then
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Effacer tout l'inventaire du joueur" , ask = "" , askX = true })
                    end

                    table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Armes" , ask = ">" , askX = true })
                    if playerGroup ~= nil and (playerGroup == 'superadmin' or playerGroup == 'owner') then
                    table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Enlever toute les armes du joueur" , ask = "" , askX = true })
                    end

                    local playerId = menuPlayerId
                    ESX.TriggerServerCallback("{@Wzn394}#:getJobs", function(myPlayerJob)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Métier : ~b~" .. myPlayerJob.label .. "~s~ - ~b~" .. myPlayerJob.grade } )
                    end, menuPlayerId)

                    ESX.TriggerServerCallback("{@Wzn394}#:getOrgs", function( myPlayerOrg)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Organisation : ~b~" .. myPlayerOrg.label .. "~s~ - ~b~" .. myPlayerOrg.gradeorg_label .. " ~s~(~b~" .. myPlayerOrg.gradeorg .. "~s~)"})
                    end, menuPlayerId)
                    ESX.TriggerServerCallback("{@Wzn394}#:money", function( myPlayerMoney)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Liquide : ~g~" .. myPlayerMoney .. "$" , slidemax = {"Give ", "Retirer"}})
                    end, menuPlayerId)
                    ESX.TriggerServerCallback("{@Wzn394}#:banque", function( myPlayerBanque)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Banque : ~g~" .. myPlayerBanque[1].money .. "$", slidemax = {"Give", "Retirer "}})
                    end, menuPlayerId)
                    ESX.TriggerServerCallback("{@Wzn394}#:sale", function( myPlayerSale)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Argent Sale : ~g~" .. myPlayerSale[2].money .. "$", slidemax = {"Give  ", "Retirer  "}})
                    end, menuPlayerId)

                    Wait(181)
                    OpenMenu('Sac à dos du joueur')
                end
                if button.slidename == "Retirer " then
                    local amount = KeyboardInput("SosoBox", "Banque", "", 8)
                    if amount ~= nil then
                        amount = tonumber(amount)
                        if type(amount) == 'number' then
                            TriggerServerEvent('soso_admin:removebanque',menuPlayerId, amount)
                            ESX.ShowNotification("Tu as retiré ~g~"..amount.."$~s~ en banque à ~b~"..menuPlayerName)

                        end
                    end

                    CloseMenu()
                    menuStaff.Menu["Sac à dos du joueur"].b = {}
                    table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Inventaire" , ask = ">" , askX = true })
                    if playerGroup ~= nil and (playerGroup == 'superadmin' or playerGroup == 'owner') then
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Effacer tout l'inventaire du joueur" , ask = "" , askX = true })
                    end

                    table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Armes" , ask = ">" , askX = true })
                    if playerGroup ~= nil and (playerGroup == 'superadmin' or playerGroup == 'owner') then
                    table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Enlever toute les armes du joueur" , ask = "" , askX = true })
                    end

                    local playerId = menuPlayerId
                    ESX.TriggerServerCallback("{@Wzn394}#:getJobs", function(myPlayerJob)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Métier : ~b~" .. myPlayerJob.label .. "~s~ - ~b~" .. myPlayerJob.grade } )
                    end, menuPlayerId)

                    ESX.TriggerServerCallback("{@Wzn394}#:getOrgs", function( myPlayerOrg)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Organisation : ~b~" .. myPlayerOrg.label .. "~s~ - ~b~" .. myPlayerOrg.gradeorg_label .. " ~s~(~b~" .. myPlayerOrg.gradeorg .. "~s~)"})
                    end, menuPlayerId)
                    ESX.TriggerServerCallback("{@Wzn394}#:money", function( myPlayerMoney)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Liquide : ~g~" .. myPlayerMoney .. "$" , slidemax = {"Give ", "Retirer"}})
                    end, menuPlayerId)
                    ESX.TriggerServerCallback("{@Wzn394}#:banque", function( myPlayerBanque)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Banque : ~g~" .. myPlayerBanque[1].money .. "$", slidemax = {"Give", "Retirer "}})
                    end, menuPlayerId)
                    ESX.TriggerServerCallback("{@Wzn394}#:sale", function( myPlayerSale)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Argent Sale : ~g~" .. myPlayerSale[2].money .. "$", slidemax = {"Give  ", "Retirer  "}})
                    end, menuPlayerId)

                    Wait(181)
                    OpenMenu('Sac à dos du joueur')
                end

                if button.slidename == "Give  " then
                    local amount = KeyboardInput("SosoBox", "Argent Sale", "", 8)
                    if amount ~= nil then
                        amount = tonumber(amount)
                        if type(amount) == 'number' then
                            TriggerServerEvent('soso_admin:momosale',menuPlayerId, amount)
                            ESX.ShowNotification("Tu as donné ~g~"..amount.."$~s~ d'argent ~r~sale ~s~ à ~b~"..menuPlayerName)
                            

                        end
                    end

                    CloseMenu()
                    menuStaff.Menu["Sac à dos du joueur"].b = {}
                    table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Inventaire" , ask = ">" , askX = true })
                    if playerGroup ~= nil and (playerGroup == 'superadmin' or playerGroup == 'owner') then
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Effacer tout l'inventaire du joueur" , ask = "" , askX = true })
                    end

                    table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Armes" , ask = ">" , askX = true })
                    if playerGroup ~= nil and (playerGroup == 'superadmin' or playerGroup == 'owner') then
                    table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Enlever toute les armes du joueur" , ask = "" , askX = true })
                    end

                    local playerId = menuPlayerId
                    ESX.TriggerServerCallback("{@Wzn394}#:getJobs", function(myPlayerJob)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Métier : ~b~" .. myPlayerJob.label .. "~s~ - ~b~" .. myPlayerJob.grade } )
                    end, menuPlayerId)

                    ESX.TriggerServerCallback("{@Wzn394}#:getOrgs", function( myPlayerOrg)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Organisation : ~b~" .. myPlayerOrg.label .. "~s~ - ~b~" .. myPlayerOrg.gradeorg_label .. " ~s~(~b~" .. myPlayerOrg.gradeorg .. "~s~)"})
                    end, menuPlayerId)
                    ESX.TriggerServerCallback("{@Wzn394}#:money", function( myPlayerMoney)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Liquide : ~g~" .. myPlayerMoney .. "$" , slidemax = {"Give ", "Retirer"}})
                    end, menuPlayerId)
                    ESX.TriggerServerCallback("{@Wzn394}#:banque", function( myPlayerBanque)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Banque : ~g~" .. myPlayerBanque[1].money .. "$", slidemax = {"Give", "Retirer "}})
                    end, menuPlayerId)
                    ESX.TriggerServerCallback("{@Wzn394}#:sale", function( myPlayerSale)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Argent Sale : ~g~" .. myPlayerSale[2].money .. "$", slidemax = {"Give  ", "Retirer  "}})
                    end, menuPlayerId)

                    Wait(180)
                    OpenMenu('Sac à dos du joueur')
                end

                if button.slidename == "Retirer  " then
                    local amount = KeyboardInput("SosoBox", "Argent Sale", "", 8)
                    if amount ~= nil then
                        amount = tonumber(amount)
                        if type(amount) == 'number' then
                            TriggerServerEvent('soso_admin:removesale',menuPlayerId, amount)
                            ESX.ShowNotification("Tu as retirer ~g~"..amount.."$~s~ d'argent ~r~sale ~s~ à ~b~"..menuPlayerName)

                        end
                    end


                    CloseMenu()
                    menuStaff.Menu["Sac à dos du joueur"].b = {}
                    table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Inventaire" , ask = ">" , askX = true })
                    if playerGroup ~= nil and (playerGroup == 'superadmin' or playerGroup == 'owner') then
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Effacer tout l'inventaire du joueur" , ask = "" , askX = true })
                    end

                    table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Armes" , ask = ">" , askX = true })
                    if playerGroup ~= nil and (playerGroup == 'superadmin' or playerGroup == 'owner') then
                    table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Enlever toute les armes du joueur" , ask = "" , askX = true })
                    end

                    local playerId = menuPlayerId
                    ESX.TriggerServerCallback("{@Wzn394}#:getJobs", function(myPlayerJob)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Métier : ~b~" .. myPlayerJob.label .. "~s~ - ~b~" .. myPlayerJob.grade } )
                    end, menuPlayerId)

                    ESX.TriggerServerCallback("{@Wzn394}#:getOrgs", function( myPlayerOrg)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Organisation : ~b~" .. myPlayerOrg.label .. "~s~ - ~b~" .. myPlayerOrg.gradeorg_label .. " ~s~(~b~" .. myPlayerOrg.gradeorg .. "~s~)"})
                    end, menuPlayerId)
                    ESX.TriggerServerCallback("{@Wzn394}#:money", function( myPlayerMoney)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Liquide : ~g~" .. myPlayerMoney .. "$" , slidemax = {"Give ", "Retirer"}})
                    end, menuPlayerId)
                    ESX.TriggerServerCallback("{@Wzn394}#:banque", function( myPlayerBanque)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Banque : ~g~" .. myPlayerBanque[1].money .. "$", slidemax = {"Give", "Retirer "}})
                    end, menuPlayerId)
                    ESX.TriggerServerCallback("{@Wzn394}#:sale", function( myPlayerSale)
                        table.insert(menuStaff.Menu["Sac à dos du joueur"].b, { name = "Argent Sale : ~g~" .. myPlayerSale[2].money .. "$", slidemax = {"Give  ", "Retirer  "}})
                    end, menuPlayerId)

                    Wait(180)
                    OpenMenu('Sac à dos du joueur')
                end
                if btn == "Effacer tout l'inventaire du joueur" then 
                    ExecuteCommand("clearinventory " .. menuPlayerId)
                    ESX.ShowNotification("Tu as effacé tout l'inventaire de ~b~"..menuPlayerName)


                end
                if btn == "Enlever toute les armes du joueur" then 
                    ExecuteCommand("clearloadout " .. menuPlayerId)
                    ESX.ShowNotification("Tu as enlevé toute les armes de ~b~"..menuPlayerName)


                end
                if btn == "Inventaire" then
                    menuStaff.Menu["Inventaire"].b = {}  

                    ESX.TriggerServerCallback("{@Wzn394}#:inventaire", function( myPlayerInv)
                        for i=1, #myPlayerInv, 1 do
                            local count = myPlayerInv[i].count
                        if count >= 1 then 
                        table.insert(menuStaff.Menu["Inventaire"].b, { name = "" .. myPlayerInv[i].label .." (" ..count..")", Description = "~r~ Pour retirer un item de l'inventaire il suffit simplement d'appuyer sur entrer !"  })
                        end
 
                    end
                    end, menuPlayerId)
                    Wait(180)
                OpenMenu("Inventaire")
                end
                if currentMenu == "Inventaire" then 

                    quantity = KeyboardInput("Sotek",'Item', "", 50)
                    ESX.TriggerServerCallback("{@Wzn394}#:inventaire", function( myPlayerInv)
                        for i=1, #myPlayerInv, 1 do
                            local count = myPlayerInv[i].count

                            if  "" .. myPlayerInv[i].label .." (" ..count..")" == btn and count > 0 then      
                                if quantity ~= nil then
                                    local post = true
                                    quantity = tonumber(quantity)
                            
                                    if type(quantity) == 'number' then
                                        quantity = ESX.Math.Round(quantity)
                            
                                        if quantity <= 0 then
                                            post = false
                                        end
                                    end                     
                                 TriggerServerEvent('soso_admin:ez',menuPlayerId, myPlayerInv[i].name , quantity)
                                 ESX.ShowNotification("Tu as retiré  "..quantity.." ~y~ "..myPlayerInv[i].label .. "~s~ à ~b~" ..menuPlayerName)
                                                     
                               else
                                  ESX.ShowNotification('Montant invalide')
                              end

                            end
                        end
                    end, menuPlayerId)
                    
                    CloseMenu()
                    menuStaff.Menu["Inventaire"].b = {}
                    Wait(140)
                    ESX.TriggerServerCallback("{@Wzn394}#:inventaire", function( myPlayerInv)
                        for i=1, #myPlayerInv, 1 do
                            local count = myPlayerInv[i].count
                        if count >= 1 then 
                        table.insert(menuStaff.Menu["Inventaire"].b, { name = "" .. myPlayerInv[i].label .." (" ..count..")" ,Description = "~r~ Pour retirer un item de l'inventaire il suffit simplement d'appuyer sur entrer !" })
                        end
 
                    end
                    end, menuPlayerId)
                    Wait(141)
                    OpenMenu("Inventaire")

                end
                if btn == "Armes" then
            
                menuStaff.Menu["Armes"].b = {}  

                ESX.TriggerServerCallback("{@Wzn394}#:weapon", function( myPlayerWeapon)
                    for k,v in ipairs(myPlayerWeapon) do
                    table.insert(menuStaff.Menu["Armes"].b, { name = "" .. v.label , Description = "~r~Pour retirer l'arme il suffit d'appuyer sur entrer !"})
                    end
                end, menuPlayerId)
                Wait(180)
                OpenMenu("Armes")
                end
                if currentMenu== "Armes" then 
                    ESX.TriggerServerCallback("{@Wzn394}#:weapon", function( myPlayerWeapon)

                    for k, v in ipairs(myPlayerWeapon) do
                        if v.label == btn  then 
                            
                            TriggerServerEvent('soso_admin:removeweapon', menuPlayerId, v.name)
                            ESX.ShowNotification("Tu as retirer une ~r~"..v.label.. "~s~ à ~b~"..menuPlayerName)
                        end
                    end
                end, menuPlayerId)
                CloseMenu()    
                menuStaff.Menu["Armes"].b = {}  
                Wait(140)
                ESX.TriggerServerCallback("{@Wzn394}#:weapon", function( myPlayerWeapon)
                    for k,v in ipairs(myPlayerWeapon) do
                    table.insert(menuStaff.Menu["Armes"].b, { name = "" .. v.label , Description = "~r~Pour retirer l'arme il suffit d'appuyer sur entrer !"})
                    end
                end, menuPlayerId)
                Wait(141)
                OpenMenu("Armes")
                
                end
                if btn == "Donner un item" then 
                    menuStaff.Menu["Donner un item"].b ={}
                    table.insert(menuStaff.Menu["Donner un item"].b, { name = "Mécano" , ask = ">" , askX = true})
                    table.insert(menuStaff.Menu["Donner un item"].b, { name = "EMS " , ask = ">" , askX = true})
                    table.insert(menuStaff.Menu["Donner un item"].b, { name = "LTD & 24/7" , ask = ">" , askX = true})
                    table.insert(menuStaff.Menu["Donner un item"].b, { name = "Vigneron " , ask = ">" , askX = true})
                    table.insert(menuStaff.Menu["Donner un item"].b, { name = "Orpailleur " , ask = ">" , askX = true})
                    table.insert(menuStaff.Menu["Donner un item"].b, { name = "Unicorn " , ask = ">" , askX = true})
                    table.insert(menuStaff.Menu["Donner un item"].b, { name = "Vip" , ask = ">" , askX = true})
                    table.insert(menuStaff.Menu["Donner un item"].b, { name = "Drogue" , ask = ">" , askX = true})


                    OpenMenu("Donner un item")
                end
                if btn == "Mécano" then 
                    menuStaff.Menu["Mécano"].b ={}
                    table.insert(menuStaff.Menu["Mécano"].b, { name = "Kit de crochetage " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Mécano"].b, { name = "Kit de carosserie " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Mécano"].b, { name = "Outils de carosserie " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Mécano"].b, { name = "Kit de réparation " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Mécano"].b, { name = "Outils de réparation " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Mécano"].b, { name = "Bouteille de gaz " , ask = "" , askX = true})

                  OpenMenu("Mécano")
            
                elseif btn == "Kit de crochetage " then     
                  local quantity = KeyboardInput("Sotek",'Item Mécano', "", 50)
                  TriggerServerEvent('sotek-staffmod:giveitems', menuPlayerId, "blowpipe", quantity)
                  ESX.ShowNotification("Tu as donné ".. quantity .." ~r~ Kit de crochetage ~s~ à ~b~"..menuPlayerName)

                elseif btn == "Kit de carosserie " then     
                    local quantity = KeyboardInput("Sotek",'Item Mécano', "", 50)
                    TriggerServerEvent('sotek-staffmod:giveitems', menuPlayerId, "carokit", quantity)
                    ESX.ShowNotification("Tu as donné ".. quantity .." ~r~ Kit de carosserie ~s~ à ~b~"..menuPlayerName)

                elseif btn == "Outils de carosserie " then     
                    local quantity = KeyboardInput("Sotek",'Item Mécano', "", 50)
                    TriggerServerEvent('sotek-staffmod:giveitems', menuPlayerId, "carotool", quantity)
                    ESX.ShowNotification("Tu as donné ".. quantity .." ~r~ Outils de carosserie ~s~ à ~b~"..menuPlayerName)

                elseif btn == "Kit de réparation " then     
                    local quantity = KeyboardInput("Sotek",'Item Mécano', "", 50)
                    TriggerServerEvent('sotek-staffmod:giveitems', menuPlayerId, "fixkit", quantity)
                    ESX.ShowNotification("Tu as donné ".. quantity .." ~r~ Kit de réparation ~s~ à ~b~"..menuPlayerName)

                elseif btn == "Outils de réparation " then     
                    local quantity = KeyboardInput("Sotek",'Item Mécano', "", 50)
                    TriggerServerEvent('sotek-staffmod:giveitems', menuPlayerId, "fixtool", quantity)
                    ESX.ShowNotification("Tu as donné ".. quantity .." ~r~ Outils de réparation ~s~ à ~b~"..menuPlayerName)

                elseif btn == "Bouteille de gaz " then     
                    local quantity = KeyboardInput("Sotek",'Item Mécano', "", 50)
                    TriggerServerEvent('sotek-staffmod:giveitems', menuPlayerId, "gazbottle", quantity)
                    ESX.ShowNotification("Tu as donné ".. quantity .." ~r~ Bouteille de gaz ~s~ à ~b~"..menuPlayerName)

                end

                if btn == "EMS " then 
                    menuStaff.Menu["EMS "].b = {}
                    table.insert(menuStaff.Menu["EMS "].b, { name = "Bandage " , ask = "" , askX = true})

                    table.insert(menuStaff.Menu["EMS "].b, { name = "Kit de soin " , ask = "" , askX = true})

                    OpenMenu( "EMS ")
                elseif btn == "Bandage " then     
                   local quantity = KeyboardInput("Sotek",'Item EMS', "", 50)
                    TriggerServerEvent('sotek-staffmod:giveitems', menuPlayerId, "bandage", quantity)
                elseif btn == "Kit de soin " then     
                      local quantity = KeyboardInput("Sotek",'Item Mécano', "", 50)
                      TriggerServerEvent('sotek-staffmod:giveitems', menuPlayerId, "medikit", quantity)
                end

                if btn == "LTD & 24/7" then 
                    menuStaff.Menu["LTD & 24/7"].b={}
                    table.insert(menuStaff.Menu["LTD & 24/7"].b, { name = "Eau " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["LTD & 24/7"].b, { name = "Pain " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["LTD & 24/7"].b, { name = "Sandwich " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["LTD & 24/7"].b, { name = "Energy " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["LTD & 24/7"].b, { name = "Téléphone " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["LTD & 24/7"].b, { name = "Sim " , ask = "" , askX = true})

                    OpenMenu("LTD & 24/7")
                elseif btn == "Eau " then 
                    local quantity = KeyboardInput("Sotek",'Item LTD & 24/7', "", 8)
                    TriggerServerEvent('sotek-staffmod:giveitems', menuPlayerId, "water", quantity)
                elseif btn == "Pain " then 
                    local quantity = KeyboardInput("Sotek",'Item LTD & 24/7', "", 8)
                    TriggerServerEvent('sotek-staffmod:giveitems', menuPlayerId, "bread", quantity)
                elseif btn == "Sandwich " then 
                    local quantity = KeyboardInput("Sotek",'Item LTD & 24/7', "", 8)
                    TriggerServerEvent('sotek-staffmod:giveitems', menuPlayerId, "sandwich", quantity)
                elseif btn == "Energy " then 
                    local quantity = KeyboardInput("Sotek",'Item LTD & 24/7', "", 8)
                    TriggerServerEvent('sotek-staffmod:giveitems', menuPlayerId, "energy", quantity)
                elseif btn == "Téléphone " then 
                    local quantity = KeyboardInput("Sotek",'Item LTD & 24/7', "", 8)
                    TriggerServerEvent('sotek-staffmod:giveitems', menuPlayerId, "phone", quantity)
                elseif btn == "Sim " then
                    local quantity = KeyboardInput("Sotek",'Item LTD & 24/7', "", 8)
                    TriggerServerEvent('sotek-staffmod:giveitems', menuPlayerId, "sim", quantity)
                end

                if btn == "Vigneron " then 
                    menuStaff.Menu["Vigneron "].b={}
                    table.insert(menuStaff.Menu["Vigneron "].b, { name = "Raison " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Vigneron "].b, { name = "Jus de raison " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Vigneron "].b, { name = "Vin " , ask = "" , askX = true})


                    OpenMenu("Vigneron ")
                elseif btn == "Raison " then 
                    local quantity = KeyboardInput("Sotek","Item Vigneron" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'raisin',quantity)
                elseif btn == "Jus de raison " then 
                    local quantity = KeyboardInput("Sotek","Item Vigneron" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'jus_raisin',quantity)
                elseif btn == "Vin " then 
                    local quantity = KeyboardInput("Sotek","Item Vigneron" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'vine',quantity)
                end

                if btn == "Orpailleur " then 
                    menuStaff.Menu["Orpailleur "].b={}
                    table.insert(menuStaff.Menu["Orpailleur "].b, { name = "Or " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Orpailleur "].b, { name = "Or fondu " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Orpailleur "].b, { name = "Lingot " , ask = "" , askX = true})


                    OpenMenu("Orpailleur ")
                elseif btn == "Or " then 
                    local quantity = KeyboardInput("Sotek","Item Orpailleur" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'or',quantity)
                elseif btn == "Or fondu " then 
                    local quantity = KeyboardInput("Sotek","Item Orpailleur" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'or_fondu',quantity)
                elseif btn == "Lingot " then 
                    local quantity = KeyboardInput("Sotek","Item Orpailleur" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'lingot',quantity)
                end

                if btn == "Unicorn " then 
                    menuStaff.Menu["Unicorn "].b = {}
                    table.insert(menuStaff.Menu["Unicorn "].b, { name = "Grand Cru " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Unicorn "].b, { name = "Ice-Tea " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Unicorn "].b, { name = "Limonade " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Unicorn "].b, { name = "Martini " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Unicorn "].b, { name = "Mojito " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Unicorn "].b, { name = "Rhum " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Unicorn "].b, { name = "Vodka " , ask = "" , askX = true})

                    OpenMenu("Unicorn ")
                elseif btn == "Grand Cru " then
                    local quantity = KeyboardInput("Sotek","Item Unicorn" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'grand_cru',quantity)
                elseif btn == "Ice-Tea " then 
                    local quantity = KeyboardInput("Sotek","Item Unicorn" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'icetea',quantity)
                elseif btn == "Limonade " then
                    local quantity = KeyboardInput("Sotek","Item Unicorn" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'limonade',quantity)
                elseif btn == "Martini " then 
                    local quantity = KeyboardInput("Sotek","Item Unicorn" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'martini',quantity)
                elseif btn == "Mojito " then 
                    local quantity = KeyboardInput("Sotek","Item Unicorn" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'mojito',quantity)
                elseif btn == "Rhum " then 
                    local quantity = KeyboardInput("Sotek","Item Unicorn" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'rhum',quantity)
                elseif btn == "Vodka " then
                    local quantity = KeyboardInput("Sotek","Item Unicorn" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'vodka',quantity)
                end

                if btn == "Vip" then
                    menuStaff.Menu["Vip"].b = {}
                    table.insert(menuStaff.Menu["Vip"].b, { name = "Giga Tacos " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Vip"].b, { name = "Big King XXL " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Vip"].b, { name = "Steackhouse " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Vip"].b, { name = "McFlurry " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Vip"].b, { name = "Fanta " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Vip"].b, { name = "Pinacolada " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Vip"].b, { name = "Ricard " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Vip"].b, { name = "Whisky " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Vip"].b, { name = "Silencieux " , ask = "" , askX = true})

                    OpenMenu("Vip")
                elseif btn == "Giga Tacos " then 
                    local quantity = KeyboardInput("Sotek","Item Vip" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'gigatacos',quantity)
                elseif btn == "Big King XXL " then
                    local quantity = KeyboardInput("Sotek","Item Vip" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'bigkingxxl',quantity)
                elseif btn == "Steackhouse " then
                    local quantity = KeyboardInput("Sotek","Item Vip" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'steackhouse',quantity)
                elseif btn == "McFlurry " then
                    local quantity = KeyboardInput("Sotek","Item Vip" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'mcflurry',quantity)
                elseif btn == "Fanta " then 
                    local quantity = KeyboardInput("Sotek","Item Vip" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'fanta',quantity)
                elseif btn == "Pinacolada " then 
                    local quantity = KeyboardInput("Sotek","Item Vip" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'pinacolada',quantity)
                elseif btn == "Ricard " then
                    local quantity = KeyboardInput("Sotek","Item Vip" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'ricard',quantity) 
                elseif btn == "Whisky " then
                    local quantity = KeyboardInput("Sotek","Item Vip" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'whisky',quantity)
                elseif btn == "Silencieux " then 
                    local quantity = KeyboardInput("Sotek","Item Vip" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'silencieux',quantity)
                end

                if btn == "Drogue" then 
                    menuStaff.Menu["Drogue"].b = {}
                    table.insert(menuStaff.Menu["Drogue"].b, { name = "Weed " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Drogue"].b, { name = "Pochon de weed " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Drogue"].b, { name = "Opium " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Drogue"].b, { name = "Pochon de opium " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Drogue"].b, { name = "Meth " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Drogue"].b, { name = "Pochon de meth " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Drogue"].b, { name = "coke " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Drogue"].b, { name = "Pochon de Coke " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Drogue"].b, { name = "Gilet LSPD " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Drogue"].b, { name = "Gilet " , ask = "" , askX = true})

                    OpenMenu("Drogue")
                elseif btn == "Weed "then  
                    local quantity = KeyboardInput("Sotek","Item Drogue" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'weed',quantity)
                elseif btn == "Pochon de weed " then 
                    local quantity = KeyboardInput("Sotek","Item Drogue" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'weed_pooch',quantity)
                elseif btn =="Opium " then 
                    local quantity = KeyboardInput("Sotek","Item Drogue" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'opium',quantity)
                elseif btn == "Pochon de opium " then 
                    local quantity = KeyboardInput("Sotek","Item Drogue" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'opium_pooch',quantity)
                elseif btn == "Meth " then 
                    local quantity = KeyboardInput("Sotek","Item Drogue" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'meth',quantity)
                elseif btn == "Pochon de meth " then 
                    local quantity = KeyboardInput("Sotek","Item Drogue" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'meth_pooch',quantity)
                elseif btn == "coke " then 
                    local quantity = KeyboardInput("Sotek","Item Drogue" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'coke',quantity)
                elseif btn == "Pochon de Coke " then 
                    local quantity = KeyboardInput("Sotek","Item Drogue" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'coke_pooch',quantity)
                elseif btn == "Gilet LSPD " then 
                    local quantity = KeyboardInput("Sotek","Item Drogue" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'giletlspd',quantity)
                elseif btn == "Gilet " then 
                    local quantity = KeyboardInput("Sotek","Item Drogue" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'gilet',quantity)
                end
                if btn == "Spectate le joueur" then 
                    if not InSpectatorMode then
                        LastPosition = GetEntityCoords(GetPlayerPed(-1))
                    end
                    InSpectatorMode = not InSpectatorMode
                    if InSpectatorMode then  
                    spectate(menuPlayerId)
                    SetNuiFocus(false)
                    else
                    	InSpectatorMode = false
                          TargetSpectate  = nil

                    	local playerPed = GetPlayerPed(-1)

                    	SetCamActive(cam,  false)
                    	RenderScriptCams(false, false, 0, true, true)

	                    SetEntityCollision(playerPed, true, true)
	                    SetEntityVisible(playerPed, true)
	                    SetEntityCoords(playerPed, LastPosition.x, LastPosition.y, LastPosition.z)
                    end
                end
 
                if btn == "Donner une arme " then 
                    menuStaff.Menu["Donner une arme "].b = {}
                    table.insert(menuStaff.Menu["Donner une arme "].b, { name = "Ammu-Nation" , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Donner une arme "].b, { name = "Vendeur d'arme " , ask = "" , askX = true})

                    OpenMenu("Donner une arme ")
                end
                if btn == "Ammu-Nation" then 
                    menuStaff.Menu["Ammu-Nation"].b = {}
                    table.insert(menuStaff.Menu["Ammu-Nation"].b, { name = "Couteau " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Ammu-Nation"].b, { name = "Batte " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Ammu-Nation"].b, { name = "PPA " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Ammu-Nation"].b, { name = "Pétoire " , ask = "" , askX = true})

                    OpenMenu("Ammu-Nation")
                end 
                if btn == "Couteau " then 
                    TriggerServerEvent("sotek-staffmod:giveweapon", menuPlayerId, "WEAPON_KNIFE")

                elseif btn == "Batte " then
                    TriggerServerEvent("sotek-staffmod:giveweapon", menuPlayerId, "WEAPON_BAT")
                elseif btn == "PPA " then 
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'permisarmes',1)
                elseif btn == "Pétoire " then 
                    TriggerServerEvent("sotek-staffmod:giveweapon", menuPlayerId, "WEAPON_SNSPISTOL")

                end
                if btn == "Vendeur d'arme " then 
                    menuStaff.Menu["Vendeur d'arme "].b = {}
                    table.insert(menuStaff.Menu["Vendeur d'arme "].b, { name = "Pétoire " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Vendeur d'arme "].b, { name = "Pistolet .9mm " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Vendeur d'arme "].b, { name = "Pistolet Lourd " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Vendeur d'arme "].b, { name = "Calibre .50 " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Vendeur d'arme "].b, { name = "Pistolet Vintage " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Vendeur d'arme "].b, { name = "Micro Uzi " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Vendeur d'arme "].b, { name = "Skorpion " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Vendeur d'arme "].b, { name = "Fusil à pompe court " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Vendeur d'arme "].b, { name = "AK-47 compacte " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Vendeur d'arme "].b, { name = "AK-47 " , ask = "" , askX = true})
                    table.insert(menuStaff.Menu["Vendeur d'arme "].b, { name = "Gilet par balles " , ask = "" , askX = true})


                    OpenMenu("Vendeur d'arme ")
                elseif btn == "Pétoire " then 
                    TriggerServerEvent("sotek-staffmod:giveweapon", menuPlayerId, "WEAPON_SNSPISTOL")
                elseif btn == "Pistolet .9mm " then 
                    TriggerServerEvent("sotek-staffmod:giveweapon", menuPlayerId, "WEAPON_PISTOL")
                elseif btn == "Pistolet Lourd " then 
                    TriggerServerEvent("sotek-staffmod:giveweapon", menuPlayerId, "weapon_heavypistol")
                elseif btn == "Calibre .50 " then 
                    TriggerServerEvent("sotek-staffmod:giveweapon", menuPlayerId, "WEAPON_PISTOL50")
                elseif btn == "Pistolet Vintage " then 
                    TriggerServerEvent("sotek-staffmod:giveweapon", menuPlayerId, "WEAPON_HEAVYPISTOL")
                elseif btn == "Micro Uzi " then 
                    TriggerServerEvent("sotek-staffmod:giveweapon", menuPlayerId, "WEAPON_MICROSMG")
                elseif btn == "Skorpion " then 
                    TriggerServerEvent("sotek-staffmod:giveweapon", menuPlayerId, "WEAPON_MINISMG")
               elseif btn == "Fusil à pompe court " then 
                    TriggerServerEvent("sotek-staffmod:giveweapon", menuPlayerId, "weapon_sawnoffshotgun")
                elseif btn == "AK-47 compacte " then 
                    TriggerServerEvent("sotek-staffmod:giveweapon", menuPlayerId, "WEAPON_COMPACTRIFLE")
                elseif btn == "AK-47 " then 
                    TriggerServerEvent("sotek-staffmod:giveweapon", menuPlayerId, "WEAPON_ASSAULTRIFLE")
                elseif btn == "Gilet par balles " then 
                    local quantity = KeyboardInput("Sotek","Gilet" , "",8)
                    TriggerServerEvent("sotek-staffmod:giveitems", menuPlayerId,'gilet',quantity)
                end
            end
        end,
    },
    Menu = {

        ["Administration"] = {
			b = {  
				--{name = "Activer le mode staff",checkbox = false},

			}
        },
        ["Activer le mode staff"] = {
			b = {  
				--{name = "Liste des joueurs", ask = '→', askX = true},
                {name = "Personnage", ask = '→', askX = true},
                {name = "Véhicule", ask = '→', askX = true},
                {name = "Divers", ask = '→', askX = true},
			}
        },
        ["Liste des joueurs"] = {
            b = {
            }
        },
        ["Gestion du joueur"] = {
            b = {
                
            --    { name = "Réanimer", ask = "", askX = true },
            --    { name = "Sac à dos du joueur", ask = "→", askX = true },

              ---  
              ---  { name = "Se téléporter au joueur", ask = "→", askX = true },
              ----  { name = "Se téléporter dans la voiture du joueur", ask = "→", askX = true },
             --   { name = "Téléporter le joueur à moi", ask = "→", askX = true },
              --  { name = "Spectate le joueur", checkbox = false , Description = "~g~N'oublie pas de jouer avec ta molette pour zoomer et dezoomer"},
              --  { name = "Modifier le métier du joueur", ask = "→", askX = true },
            --    { name = "Donner un item", ask = "→", askX = true , Description = "~r~Seul les Superadmins peuvent acceder a ce menu!!" },
               -- { name = "Donner une arme ", ask = "→", askX = true , Description = "~r~Seul les Superadmins peuvent acceder a ce menu!!"},
              -- { name = "Freeze le joueur", checkbox = false },
              --  { name = "Warn le joueur", ask = "→", askX = true },
               -- { name = "Kick le joueur", ask = "→", askX = true },
               -- { name = "Envoyer un message privé au joueur", ask = "→", askX = true },
            --    {name = "~r~Wipe le joueur", ask = '', askX = true,Description = "~r~Attention aucun retour en arrière est possible"}

            }
        },
        ["Liste des métiers"] = {
            b = {
                { name = "LSPD", ask = "→", askX = true },
                { name = "EMS", ask = "→", askX = true },
                { name = "Concessionnaire Auto", ask = "→", askX = true },
                { name = "Concessionnaire Moto", ask = "→", askX = true },
                { name = "Agent immobilier", ask = "→", askX = true },
                { name = "Orpailleur", ask = "→", askX = true },
                { name = "Tabac", ask = "→", askX = true },
                { name = "Vigneron", ask = "→", askX = true },
                { name = "Vendeur d'arme", ask = "→", askX = true },
                { name = "Chômeur", ask = "", askX = true },


            }
        },
        ["Personnage"] = {
            b = {

                { name = "Noclip", checkbox = false },

                { name = "Mode invincible", checkbox = false },
                { name = "Mode invisible", checkbox = false },
            }
        },
        ["Véhicule"] = {
            b = {
                { name = "Réparer le véhicule", ask = '→', askX = true },
                { name = "Faire apparaître un véhicule", ask = '→', askX = true },
                { name = "Retourner le véhicule", ask = '→', askX = true },
                { name = "Modifier la plaque du véhicule", ask = '→' , askX = true},         
                { name = "~r~Supprimer le véhicule", ask = '→', askX = true }
            }
        },
        ["Divers"] = {
            b = {
                { name = "Se téléporter au marqueur", ask = '→', askX = true },
                { name = "Afficher/cacher le nom des joueurs", checkbox = false },
                { name = "Afficher/cacher blips des joueurs", checkbox = false },
                { name = "Afficher/cacher les coordonnées", checkbox = false }
            }
        },

        ["Inventaire"] = {
            b = {
           

            }
        },
        
        
        ["Donner un item"] = {
            b = {

            }
        },
                
        ["Donner une arme "] = {
            b = {

            }
        },

                        
        ["Ammu-Nation"] = {
            b = {

            }
        },

                        
        ["Vendeur d'arme "] = {
            b = {

            }
        },


        ["Mécano"] = {
            b = {

            }
        },

        ["Vip"] = {
            b = {

            }
        },


        ["EMS "] = {
            b = {

            }
        },
        
        ["LTD & 24/7"] = {
            b = {

            }
        },

        ["Vigneron "] = {
            b = {

            }
        },

        ["Unicorn "] = {
            b = {

            }
        },

        ["Orpailleur "] = {
            b = {

            }
        },

        ["Drogue"] = {
            b = {
           

            }
        },
        ["Armes"] = {
            b = {
           

            }
        },
        ["Sac à dos du joueur"] = {
            b = {
           

            }
        },
        
        ["Warn le joueur"] = {
            b = {
           

            }
        },
        
        ["Kick le joueur"] = {
            b = {
           

            }
        },
       

        ["LSPD"] = {
            b = {
           

            }
        },
        
        ["EMS"] = {
            b = {
           

            }
        },
        
        ["Concessionnaire Auto"] = {
            b = {
           

            }
        },

        ["Concessionnaire Moto"] = {
            b = {
           

            }
        },

        ["Agent immobilier"] = {
            b = {
           

            }
        },

        ["Orpailleur"] = {
            b = {
           

            }
        },
        ["Tabac"] = {
            b = {
           

            }
        },
       
        ["Vigneron"] = {
            b = {
           

            }
        },

        ["Vendeur d'armes"] = {
            b = {
           

            }
        },
	}
}
Citizen.CreateThread(function()
	while true do
		if ESX ~= nil then
			ESX.TriggerServerCallback('SotekAdmin:Admin_getUsergroup', function(group) playerGroup = group end)

			Citizen.Wait(30 * 1000)
		else
			Citizen.Wait(100)
		end
	end
end)

RegisterCommand("staff", function()
    
    menuStaff.Menu["Administration"].b = {}
    table.insert(menuStaff.Menu["Administration"].b, { name = "Activer le mode staff", checkbox = false})
    if playerGroup ~= nil and (playerGroup == 'mod' or playerGroup == 'admin' or playerGroup == 'superadmin' or playerGroup == 'owner') then

        CreateMenu(menuStaff)        
  

    end
end)
RegisterNetEvent('staffmodsoso')
AddEventHandler('staffmodsoso', function()
    menuStaff.Menu["Administration"].b = {}
        table.insert(menuStaff.Menu["Administration"].b, { name = "Activer le mode staff", checkbox = false})
        CreateMenu(menuStaff)        
    ESX.ShowNotification("Mode staff ~g~activé")
  
end)
RegisterCommand("plylist", function()
    for _, playerId in ipairs(GetActivePlayers()) do
        local plyName = GetPlayerName(playerId)
        -- table.insert(menuStaff.Menu["Liste des joueurs"].b, { name = tostring(plyName), ask = tostring(playerId)})
        ESX.ShowNotification(plyName .. " - " .. playerId)
    end
end)

-- FONCTIONS
Citizen.CreateThread(function()
	while true do
		plyPed = PlayerPedId()
	
		if showcoord then
			local playerPos = GetEntityCoords(plyPed)
			local playerHeading = GetEntityHeading(plyPed)
			ESX.DrawMissionText("~b~X~s~ : " .. playerPos.x .. " ~b~Y~s~ : " .. playerPos.y .. " ~b~Z~s~ : " .. playerPos.z .. " 		~b~Angle~s~: " .. playerHeading)
		end
		if showname then
			for id = 0, 256 do
				if NetworkIsPlayerActive(id) and GetPlayerPed(id) ~= plyPed then
					local headId = Citizen.InvokeNative(0xBFEFE3321A3F5015, GetPlayerPed(id), ('('.. GetPlayerServerId(id) .. ') ' .. GetPlayerName(id)), false, false, "", false)
				end
			end
		end

		
		Citizen.Wait(0)
	end
end)

function TeleportToWaypoint()
	if DoesBlipExist(GetFirstBlipInfoId(8)) then
		local blipIterator = GetBlipInfoIdIterator(8)
		local blip = GetFirstBlipInfoId(8, blipIterator)
		WaypointCoords = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector()) --Thanks To Briglair [forum.FiveM.net]
		wp = true
	else
        ESX.ShowNotification("~r~Aucun waypoint")
	end

	local zHeigt = 0.0
	height = 1000.0
	while wp do
		Citizen.Wait(0)
		if wp then
			if IsPedInAnyVehicle(GetPlayerPed(-1), 0) and (GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), 0), -1) == GetPlayerPed(-1)) then
				entity = GetVehiclePedIsIn(GetPlayerPed(-1), 0)
			else
				entity = GetPlayerPed(-1)
			end

            
			SetEntityCoords(entity, WaypointCoords.x, WaypointCoords.y, height)
			FreezeEntityPosition(entity, true)
			local Pos = GetEntityCoords(entity, true)

			if zHeigt == 0.0 then
				height = height - 25.0
				SetEntityCoords(entity, Pos.x, Pos.y, height)
				bool, zHeigt = GetGroundZFor_3dCoord(Pos.x, Pos.y, Pos.z, 0)
			else
				SetEntityCoords(entity, Pos.x, Pos.y, zHeigt)
				FreezeEntityPosition(entity, false)
				wp = false
				height = 1000.0
				zHeigt = 0.0
				break
			end
		end
	end
end


Citizen.CreateThread(function()

    while true do

      Wait(0)

      if InSpectatorMode then

          local targetPlayerId = GetPlayerFromServerId(TargetSpectate)
          local playerPed	  = GetPlayerPed(-1)
          local targetPed	  = GetPlayerPed(targetPlayerId)
          local coords	 = GetEntityCoords(targetPed)

          for i=0, 32, 1 do
              if i ~= PlayerId() then
                  local otherPlayerPed = GetPlayerPed(i)
                  SetEntityNoCollisionEntity(playerPed,  otherPlayerPed,  true)
                  SetEntityVisible(playerPed, false)
              end
          end

          if IsControlPressed(2, 241) then
              radius = radius + 2.0;
          end

          if IsControlPressed(2, 242) then
              radius = radius - 2.0;
          end

          if radius > -1 then
              radius = -1
          end

          local xMagnitude = GetDisabledControlNormal(0, 1);
          local yMagnitude = GetDisabledControlNormal(0, 2);

          polarAngleDeg = polarAngleDeg + xMagnitude * 10;

          if polarAngleDeg >= 360 then
              polarAngleDeg = 0
          end

          azimuthAngleDeg = azimuthAngleDeg + yMagnitude * 10;

          if azimuthAngleDeg >= 360 then
              azimuthAngleDeg = 0;
          end

          local nextCamLocation = polar3DToWorld3D(coords, radius, polarAngleDeg, azimuthAngleDeg)

          SetCamCoord(cam,  nextCamLocation.x,  nextCamLocation.y,  nextCamLocation.z)
          PointCamAtEntity(cam,  targetPed)
          SetEntityCoords(playerPed,  coords.x, coords.y, coords.z + 10)

          if IsControlPressed(2, 47) then
          OpenAdminActionMenu(targetPlayerId)
          end
          
-- taken from Easy Admin (thx to Bluethefurry)  --
          local text = {}
          -- cheat checks
          local targetGod = GetPlayerInvincible(targetPlayerId)
          if targetGod then
              table.insert(text,"Godmode: ~r~Activé~w~")
          else
              table.insert(text,"Godmode: ~g~Pas activé~w~")
          end

          -- health info
          table.insert(text,"Vie"..": "..GetEntityHealth(targetPed).."/"..GetEntityMaxHealth(targetPed))
          table.insert(text,"Armure"..": "..GetPedArmour(targetPed))

          for i,theText in pairs(text) do
              SetTextFont(0)
              SetTextProportional(1)
              SetTextScale(0.0, 0.30)
              SetTextDropshadow(0, 0, 0, 0, 255)
              SetTextEdge(1, 0, 0, 0, 255)
              SetTextDropShadow()
              SetTextOutline()
              SetTextEntry("STRING")
              AddTextComponentString(theText)
              EndTextCommandDisplayText(0.3, 0.7+(i/30))
          end
-- end of taken from easyadmin -- 
      end

    end
end)
