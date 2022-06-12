local HasAlreadyEnteredMarker, OnJob, IsNearCustomer, CustomerIsEnteringVehicle, CustomerEnteredVehicle, IsDead, CurrentActionData = false, false, false, false, false, false, {}
local CurrentCustomer, CurrentCustomerBlip, DestinationBlip, targetCoords, LastZone, CurrentAction, CurrentActionMsg

local PlayerData = {}
local blips = true
local blipActive = false

ESX = nil


Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

function ShowLoadingPromt(msg, time, type)
	Citizen.CreateThread(function()
		Citizen.Wait(0)

		BeginTextCommandBusyspinnerOn('STRING')
		AddTextComponentSubstringPlayerName(msg)
		EndTextCommandBusyspinnerOn(type)
		Citizen.Wait(time)

		BusyspinnerOff()
	end)
end
function StartTaxiJob()
	ShowLoadingPromt(('Prise de service'), 5000, 3)
	ClearCurrentMission()

	OnJob = true
end

function ClearCurrentMission()
	if DoesBlipExist(CurrentCustomerBlip) then
		RemoveBlip(CurrentCustomerBlip)
	end

	if DoesBlipExist(DestinationBlip) then
		RemoveBlip(DestinationBlip)
	end

	CurrentCustomer           = nil
	CurrentCustomerBlip       = nil
	DestinationBlip           = nil
	IsNearCustomer            = false
	CustomerIsEnteringVehicle = false
	CustomerEnteredVehicle    = false
	targetCoords              = nil
end
function StopTaxiJob()
	local playerPed = PlayerPedId()

	if IsPedInAnyVehicle(playerPed, false) and CurrentCustomer ~= nil then
		local vehicle = GetVehiclePedIsIn(playerPed,  false)
		TaskLeaveVehicle(CurrentCustomer,  vehicle,  0)

		if CustomerEnteredVehicle then
			TaskGoStraightToCoord(CurrentCustomer,  targetCoords.x,  targetCoords.y,  targetCoords.z,  1.0,  -1,  0.0,  0.0)
		end
	end

	ClearCurrentMission()
	OnJob = false
	DrawSub('Fin de service', 5000)
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


-- Fonction TP
function TeleportFadeEffect(entity, coords)
	Citizen.CreateThread(function()
		DoScreenFadeOut(800)
		while not IsScreenFadedOut() do
			Citizen.Wait(0)
		end
		ESX.Game.Teleport(entity, coords, function()
			DoScreenFadeIn(800)
		end)
	end)
end

-- Fonction affichage mission text
function DrawSub(msg, time)
	ClearPrints()
	BeginTextCommandPrint('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandPrint(time, 1)
end

-- Fonction notification
function notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, true)
end

-- Fonction facture
function facturetaxi()
    local titre = KeyboardInput('stk_facture', ('Nom de la facture'), '', 35)
    local amount = KeyboardInput('stk_facture', ('Montant'), '', 6)
    local player, distance = ESX.Game.GetClosestPlayer()
    local amount = tonumber(amount)
    
    if player ~= -1 and distance <= 3.0 then
        if amount ~= nil then
            if amount <= 10000 then
                if amount == 0 then
                else
                    if type(amount) == 'number' then
                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_taxi', titre, amount)
                        Wait(100)
                        TriggerEvent('showNotify', '~b~INFORMATION\n~w~Facture envoyée.\n \n~o~MONTANT \n~w~'..amount..'$')
                    end
                end
            else
                TriggerEvent('showNotify', '~b~INFORMATION\n~w~Montant trop élevé.\n \n~o~MAXIMUM \n~w~10.000$')
            end
        end
    else
        TriggerEvent('showNotify', '~b~INFORMATION\n~w~Aucun joueur proche.')
    end
end

-- Fonction spawn de voitures
function spawnCar(car)
    local car = GetHashKey(car)
    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(50)
    end
    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), false))
    local vehicle = CreateVehicle(car, 911.108, -177.867, 74.283, 240.3, true, false)
    
    SetEntityAsNoLongerNeeded(vehicle)
	SetModelAsNoLongerNeeded(vehicleName)
	SetVehicleWindowTint(vehicle, 3)
	SetVehicleNumberPlateText(vehicle, "taxi")
end

-- Debug setjob
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
	Wait(100)
	if PlayerData.job ~= nil and PlayerData.job.name == 'taxi' then
		blips = true
		blipActive = false
		TriggerEvent("stk_jobs:createblips")
	else
		blips = false
		blipActive = false
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	blips = false
	blipActive = false
	PlayerData.job = job
	Wait(100)
	if PlayerData.job ~= nil and PlayerData.job.name == 'taxi' then
		blips = true
		blipActive = false
		TriggerEvent("stk_jobs:createblips")
	else
		blips = false
		blipActive = false
	end
end)

-------------------------------------------------------------------------------------------

-- Menu vestiaire
local vestiaireT= {
	Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "Vestiaire" },
	Data = { currentMenu = "Actions disponibles", "Test" },
	Events = {
		onSelected = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)
			PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
			local slide = btn.slidenum
			local btn = btn.name
			local check = btn.unkCheckbox
			if btn == "Tenue civile" then
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
					TriggerEvent('skinchanger:loadSkin', skin)
				end)
				SetPedArmour(playerPed, 0)			
			elseif btn == "Tenue de travail" then
				TriggerEvent('stk_jobs:onDuty')
				onDuty = true
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
					if skin.sex == 0 then
						TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_male)
					elseif skin.sex == 1 then
						TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_female)
				   end
				end)
			end
	end,
},

	Menu = {
		["Actions disponibles"] = {
			b = {
				{name = "Tenue civile", ask = "Prendre", askX = true},
				{name = "----------------------------------------", ask = "", askX = true},
				{name = "Tenue de travail", ask = "Prendre", askX = true},				
			}
		}
	}
}

local GarageTaxi= {
	Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "Garage" },
	Data = { currentMenu = "Actions disponibles", "Test" },
	Events = {
		onSelected = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)
			PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
			local slide = btn.slidenum
			local btn = btn.name
			local check = btn.unkCheckbox
			if btn == "Sortir Véhicule" then
				ESX.ShowNotification('Vous avez ~r~sorti~s~ un véhicule.')		
				spawnCar("taxi")
			elseif btn == "~r~Ranger Véhicule" then 
				local closeveh = GetClosestVehicle(911.108, -177.867, 74.283, 240.3, 0)
				DeleteEntity(closeveh)
				ESX.ShowNotification('Vous avez ~g~rangé~s~ un véhicule.')
			end
	end,
},

	Menu = {
		["Actions disponibles"] = {
			b = {
				{name = "Sortir Véhicule", ask = "", askX = true},
				{name = "~r~Ranger Véhicule", ask = "", askX = true},				
			}
		}
	}
}


----f6

local f6= {
	Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "Taxi" },
	Data = { currentMenu = "Actions disponibles", "Test" },
	Events = {
		onSelected = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)
			PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
			local slide = btn.slidenum
			local btn = btn.name
			local check = btn.unkCheckbox
			if btn == "Facturation" then
				facturetaxi()
			elseif btn == "Annonce Taxi Disponible" then
				TriggerServerEvent("AnnounceTaxiOuvert")
			elseif btn == "Annonce Taxi Indisponible" then
				TriggerServerEvent("AnnounceTaxiFerme")
			elseif btn == "Prise de Service avec Pnj" then 
				if OnJob then
					StopTaxiJob()
				else
					if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'taxi' then
						local playerPed = PlayerPedId()
						local vehicle   = GetVehiclePedIsIn(playerPed, false)
	
						if IsPedInAnyVehicle(playerPed, false) and GetPedInVehicleSeat(vehicle, -1) == playerPed then
							if tonumber(ESX.PlayerData.job.grade) >= 3 then
								StartTaxiJob()
							else
								if IsInAuthorizedVehicle() then
									StartTaxiJob()
								else
									ESX.ShowNotification('vous devez être dans un taxi pour commencer la mission')
								end
							end
						else
							if tonumber(ESX.PlayerData.job.grade) >= 3 then
								ESX.ShowNotification("vous devez être dans un véhicule pour commencer la mission")
							else
								ESX.ShowNotification('vous devez être dans un taxi pour commencer la mission')
							end
						end
					end
				end
			elseif btn == "Fin de Service avec Pnj" then 
				StopTaxiJob()
			end
		
	end,
},

	Menu = {
		["Actions disponibles"] = {
			b = {
				{name = "Facturation", ask = ">", askX = true},
				{name = "Annonce Taxi Disponible", ask = "", askX = true},
				{name = "Annonce Taxi Indisponible", ask = "", askX = true},
				{name = "Prise de Service avec Pnj", ask = "", askX = true},
				{name = "Fin de Service avec Pnj", ask = "", askX = true},
							
			}
		}
	}
}


local posvestiaretaxi = {
	{x = 894.88, y = -180.23, z = 74.5}
}

local posgaraget = {
	{x = 902.05, y = -168.06, z = 74.08, h = 238.7}
}

local bossmenutaxi = {
	{x = 895.96, y = -178.72, z = 74.7}
}
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if IsControlJustPressed(1,167) and PlayerData.job and PlayerData.job.name == 'taxi' then
			CreateMenu(f6)
		end
		for k in pairs(posvestiaretaxi) do
			local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
			local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, posvestiaretaxi[k].x, posvestiaretaxi[k].y, posvestiaretaxi[k].z)
			if dist <= 50.0 and PlayerData.job and PlayerData.job.name == 'taxi' then
				DrawMarker(25, posvestiaretaxi[k].x, posvestiaretaxi[k].y, posvestiaretaxi[k].z-0.8, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.7, 0.7, 0.7, 82, 198, 255, 200, false, false, 2, false, false, false, false)
			end
			if dist <= 1.5 and PlayerData.job and PlayerData.job.name == 'taxi' then
				DrawSub("Appuyez sur ~b~E ~s~pour pour intéragir.", 1)	
				if IsControlJustPressed(1,51) and PlayerData.job and PlayerData.job.name == 'taxi' then
					CreateMenu(vestiaireT)
				end
			end
		end
		for k in pairs(posgaraget) do
			local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
			local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, posgaraget[k].x, posgaraget[k].y, posgaraget[k].z)
			if dist <= 1.5 and PlayerData.job and PlayerData.job.name == 'taxi' then
				DrawSub("Appuyez sur ~b~E ~s~pour pour intéragir.", 1)	
				if IsControlJustPressed(1,51) and PlayerData.job and PlayerData.job.name == 'taxi' then
					CreateMenu(GarageTaxi)
				end
			end
		end
		for k in pairs(bossmenutaxi) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, bossmenutaxi[k].x, bossmenutaxi[k].y, bossmenutaxi[k].z)
			if dist <= 15.0 and PlayerData.job and PlayerData.job.name == 'taxi' and PlayerData.job.grade_name == 'boss' then
				DrawMarker(25, bossmenutaxi[k].x, bossmenutaxi[k].y, bossmenutaxi[k].z-1.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.7, 0.7, 0.7, 255, 255, 255, 200, false, false, 2, true, false, false, false)
			end
            if dist <= 1.0 and PlayerData.job and PlayerData.job.name == 'taxi' and PlayerData.job.grade_name == 'boss' then
                DrawSub("Appuyez sur ~w~E ~s~pour gérer l'entreprise.", 1)		
                if IsControlJustPressed(1,51) then
					TriggerEvent('esx_society:openBossMenu', 'taxi', function(data, menu)
						menu.close()
					end, { wash = false }) -- disable washing money
				end
			end
        end



	end
end)

local bliptaxi = {
    {x = 894.88, y = -180.23, z = 74.5}
}
Citizen.CreateThread(function()
    for k in pairs(bliptaxi) do
		local blip = AddBlipForCoord(bliptaxi[k].x, bliptaxi[k].y, bliptaxi[k].z)
		SetBlipSprite(blip, 56)
		SetBlipScale(blip, 0.5)
		SetBlipAsShortRange(blip, true)
		SetBlipColour(blip, 46)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Taxi")
		EndTextCommandSetBlipName(blip)	
    end
end)


--Peds
Citizen.CreateThread(function()
    for k in pairs(posgaraget) do
		local hash = GetHashKey("a_m_y_business_01")
		while not HasModelLoaded(hash) do
			RequestModel(hash)
			Wait(20)
		end
		ped = CreatePed("PED_TYPE_CIVFEMALE", hash, posgaraget[k].x, posgaraget[k].y, posgaraget[k].z-0.99, posgaraget[k].h, false, true)
		SetBlockingOfNonTemporaryEvents(ped, true)
		FreezeEntityPosition(ped, true)
		SetEntityInvincible(ped, true)
	end
	
end)

function GetRandomWalkingNPC()
	local search = {}
	local peds   = ESX.Game.GetPeds()

	for i=1, #peds, 1 do
		if IsPedHuman(peds[i]) and IsPedWalking(peds[i]) and not IsPedAPlayer(peds[i]) then
			table.insert(search, peds[i])
		end
	end

	if #search > 0 then
		return search[GetRandomIntInRange(1, #search)]
	end

	for i=1, 250, 1 do
		local ped = GetRandomPedAtCoord(0.0, 0.0, 0.0, math.huge + 0.0, math.huge + 0.0, math.huge + 0.0, 26)

		if DoesEntityExist(ped) and IsPedHuman(ped) and IsPedWalking(ped) and not IsPedAPlayer(ped) then
			table.insert(search, ped)
		end
	end

	if #search > 0 then
		return search[GetRandomIntInRange(1, #search)]
	end
end

local test = {
	vector3(293.5, -590.2, 42.7),
	vector3(253.4, -375.9, 44.1),
	vector3(120.8, -300.4, 45.1),
	vector3(-38.4, -381.6, 38.3),
	vector3(-107.4, -614.4, 35.7),
	vector3(-252.3, -856.5, 30.6),
	vector3(-236.1, -988.4, 28.8),
	vector3(-277.0, -1061.2, 25.7),
	vector3(-576.5, -999.0, 21.8),
	vector3(-602.8, -952.6, 21.6),
	vector3(-790.7, -961.9, 14.9),
	vector3(-912.6, -864.8, 15.0),
	vector3(-1069.8, -792.5, 18.8),
	vector3(-1306.9, -854.1, 15.1),
	vector3(-1468.5, -681.4, 26.2),
	vector3(-1380.9, -452.7, 34.1),
	vector3(-1326.3, -394.8, 36.1),
	vector3(-1383.7, -270.0, 42.5),
	vector3(-1679.6, -457.3, 39.4),
	vector3(-1812.5, -416.9, 43.7),
	vector3(-2043.6, -268.3, 23.0),
	vector3(-2186.4, -421.6, 12.7),
	vector3(-1862.1, -586.5, 11.2),
	vector3(-1859.5, -617.6, 10.9),
	vector3(-1635.0, -988.3, 12.6),
	vector3(-1284.0, -1154.2, 5.3),
	vector3(-1126.5, -1338.1, 4.6),
	vector3(-867.9, -1159.7, 5.0),
	vector3(-847.5, -1141.4, 6.3),
	vector3(-722.6, -1144.6, 10.2),
	vector3(-575.5, -318.4, 34.5),
	vector3(-592.3, -224.9, 36.1),
	vector3(-559.6, -162.9, 37.8),
	vector3(-535.0, -65.7, 40.6),
	vector3(-758.2, -36.7, 37.3),
	vector3(-1375.9, 21.0, 53.2),
	vector3(-1320.3, -128.0, 48.1),
	vector3(-1285.7, 294.3, 64.5),
	vector3(-1245.7, 386.5, 75.1),
	vector3(-760.4, 285.0, 85.1),
	vector3(-626.8, 254.1, 81.1),
	vector3(-563.6, 268.0, 82.5),
	vector3(-486.8, 272.0, 82.8),
	vector3(88.3, 250.9, 108.2),
	vector3(234.1, 344.7, 105.0),
	vector3(435.0, 96.7, 99.2),
	vector3(482.6, -142.5, 58.2),
	vector3(762.7, -786.5, 25.9),
	vector3(809.1, -1290.8, 25.8),
	vector3(490.8, -1751.4, 28.1),
	vector3(432.4, -1856.1, 27.0),
	vector3(164.3, -1734.5, 28.9),
	vector3(-57.7, -1501.4, 31.1),
	vector3(52.2, -1566.7, 29.0),
	vector3(310.2, -1376.8, 31.4),
	vector3(182.0, -1332.8, 28.9),
	vector3(-74.6, -1100.6, 25.7),
	vector3(-887.0, -2187.5, 8.1),
	vector3(-749.6, -2296.6, 12.5),
	vector3(-1064.8, -2560.7, 19.7),
	vector3(-1033.4, -2730.2, 19.7),
	vector3(-1018.7, -2732.0, 13.3),
	vector3(797.4, -174.4, 72.7),
	vector3(508.2, -117.9, 60.8),
	vector3(159.5, -27.6, 67.4),
	vector3(-36.4, -106.9, 57.0),
	vector3(-355.8, -270.4, 33.0),
	vector3(-831.2, -76.9, 37.3),
	vector3(-1038.7, -214.6, 37.0),
	vector3(1918.4, 3691.4, 32.3),
	vector3(1820.2, 3697.1, 33.5),
	vector3(1619.3, 3827.2, 34.5),
	vector3(1418.6, 3602.2, 34.5),
	vector3(1944.9, 3856.3, 31.7),
	vector3(2285.3, 3839.4, 34.0),
	vector3(2760.9, 3387.8, 55.7),
	vector3(1952.8, 2627.7, 45.4),
	vector3(1051.4, 474.8, 93.7),
	vector3(866.4, 17.6, 78.7),
	vector3(319.0, 167.4, 103.3),
	vector3(88.8, 254.1, 108.2),
	vector3(-44.9, 70.4, 72.4),
	vector3(-115.5, 84.3, 70.8),
	vector3(-384.8, 226.9, 83.5),
	vector3(-578.7, 139.1, 61.3),
	vector3(-651.3, -584.9, 34.1),
	vector3(-571.8, -1195.6, 17.9),
	vector3(-1513.3, -670.0, 28.4),
	vector3(-1297.5, -654.9, 26.1),
	vector3(-1645.5, 144.6, 61.7),
	vector3(-1160.6, 744.4, 154.6),
	vector3(-798.1, 831.7, 204.4)


}
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)
		local playerPed = PlayerPedId()

		if OnJob then
			if CurrentCustomer == nil then
				DrawSub(('conduisez à la recherche de ~y~passagers'), 5000)

				if IsPedInAnyVehicle(playerPed, false) and GetEntitySpeed(playerPed) > 0 then
					local waitUntil = GetGameTimer() + GetRandomIntInRange(30000, 45000)

					while OnJob and waitUntil > GetGameTimer() do
						Citizen.Wait(0)
					end

					if OnJob and IsPedInAnyVehicle(playerPed, false) and GetEntitySpeed(playerPed) > 0 then
						CurrentCustomer = GetRandomWalkingNPC()

						if CurrentCustomer ~= nil then
							CurrentCustomerBlip = AddBlipForEntity(CurrentCustomer)

							SetBlipAsFriendly(CurrentCustomerBlip, true)
							SetBlipColour(CurrentCustomerBlip, 2)
							SetBlipCategory(CurrentCustomerBlip, 3)
							SetBlipRoute(CurrentCustomerBlip, true)

							SetEntityAsMissionEntity(CurrentCustomer, true, false)
							ClearPedTasksImmediately(CurrentCustomer)
							SetBlockingOfNonTemporaryEvents(CurrentCustomer, true)

							local standTime = GetRandomIntInRange(60000, 180000)
							TaskStandStill(CurrentCustomer, standTime)

							ESX.ShowNotification('vous avez ~g~trouvé~s~ un client, conduisez jusqu\'à ce dernier')
						end
					end
				end
			else
				if IsPedFatallyInjured(CurrentCustomer) then
					ESX.ShowNotification('votre client est ~r~inconscient~s~. Cherchez-en un autre.')

					if DoesBlipExist(CurrentCustomerBlip) then
						RemoveBlip(CurrentCustomerBlip)
					end

					if DoesBlipExist(DestinationBlip) then
						RemoveBlip(DestinationBlip)
					end

					SetEntityAsMissionEntity(CurrentCustomer, false, true)

					CurrentCustomer, CurrentCustomerBlip, DestinationBlip, IsNearCustomer, CustomerIsEnteringVehicle, CustomerEnteredVehicle, targetCoords = nil, nil, nil, false, false, false, nil
				end

				if IsPedInAnyVehicle(playerPed, false) then
					local vehicle          = GetVehiclePedIsIn(playerPed, false)
					local playerCoords     = GetEntityCoords(playerPed)
					local customerCoords   = GetEntityCoords(CurrentCustomer)
					local customerDistance = #(playerCoords - customerCoords)

					if IsPedSittingInVehicle(CurrentCustomer, vehicle) then
						if CustomerEnteredVehicle then
							local targetDistance = #(playerCoords - targetCoords)

							if targetDistance <= 10.0 then
								TaskLeaveVehicle(CurrentCustomer, vehicle, 0)

								ESX.ShowNotification("Vous êtes arrivée a destination")

								TaskGoStraightToCoord(CurrentCustomer, targetCoords.x, targetCoords.y, targetCoords.z, 1.0, -1, 0.0, 0.0)
								SetEntityAsMissionEntity(CurrentCustomer, false, true)
								TriggerServerEvent('stk_taxijob:success')
								RemoveBlip(DestinationBlip)

								local scope = function(customer)
									ESX.SetTimeout(60000, function()
										DeletePed(customer)
									end)
								end

								scope(CurrentCustomer)

								CurrentCustomer, CurrentCustomerBlip, DestinationBlip, IsNearCustomer, CustomerIsEnteringVehicle, CustomerEnteredVehicle, targetCoords = nil, nil, nil, false, false, false, nil
							end

							if targetCoords then
								DrawMarker(36, targetCoords.x, targetCoords.y, targetCoords.z + 1.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 234, 223, 72, 155, false, false, 2, true, nil, nil, false)
							end
						else
							RemoveBlip(CurrentCustomerBlip)
							CurrentCustomerBlip = nil
							targetCoords = test[GetRandomIntInRange(1, #test)]
							local distance = #(playerCoords - targetCoords)
							while distance < 3000 do
								Citizen.Wait(5)

								targetCoords = test[GetRandomIntInRange(1, #test)]
								distance = #(playerCoords - targetCoords)
							end


							local street = table.pack(GetStreetNameAtCoord(targetCoords.x, targetCoords.y, targetCoords.z))
							local msg    = nil

							if street[2] ~= 0 and street[2] ~= nil then
								msg = string.format( GetStreetNameFromHashKey(street[1]), GetStreetNameFromHashKey(street[2]))
							else
								msg = string.format( GetStreetNameFromHashKey(street[1]))
							end

							ESX.ShowNotification(msg)

							DestinationBlip = AddBlipForCoord(targetCoords.x, targetCoords.y, targetCoords.z)

							BeginTextCommandSetBlipName('STRING')
							AddTextComponentSubstringPlayerName('Destination')
							EndTextCommandSetBlipName(blip)
							SetBlipRoute(DestinationBlip, true)

							CustomerEnteredVehicle = true
						end
					else
						DrawMarker(36, customerCoords.x, customerCoords.y, customerCoords.z + 1.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 234, 223, 72, 155, false, false, 2, true, nil, nil, false)

						if not CustomerEnteredVehicle then
							if customerDistance <= 40.0 then

								if not IsNearCustomer then
									ESX.ShowNotification('vous êtes à proximité du client, approchez-vous de lui')
									IsNearCustomer = true
								end

							end

							if customerDistance <= 20.0 then
								if not CustomerIsEnteringVehicle then
									ClearPedTasksImmediately(CurrentCustomer)

									local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

									for i=maxSeats - 1, 0, -1 do
										if IsVehicleSeatFree(vehicle, i) then
											freeSeat = i
											break
										end
									end

									if freeSeat then
										TaskEnterVehicle(CurrentCustomer, vehicle, -1, freeSeat, 2.0, 0)
										CustomerIsEnteringVehicle = true
									end
								end
							end
						end
					end
				else
					DrawSub('veuillez remonter dans votre véhicule pour continuer la mission', 5000)
				end
			end
		else
			Citizen.Wait(500)
		end
	end
end)