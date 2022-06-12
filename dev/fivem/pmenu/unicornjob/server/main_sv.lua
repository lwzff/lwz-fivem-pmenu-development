ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('#{PEOddnq348}@punicorn:buyboisson')
AddEventHandler('#{PEOddnq348}@punicorn:buyboisson', function(item, label)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	if xPlayer.getInventoryItem(item).count <= 9 then
		xPlayer.addInventoryItem(item, 1)
	else
		TriggerClientEvent('esx:showNotification', source, "~b~INFORMATION\n~w~Tu es trop lourd.\n \n~o~MAXIMUM \n~w~10 "..label)
	end
end)

RegisterServerEvent('#{PEOddnq348}@punicorn:ouverture')
AddEventHandler('#{PEOddnq348}@punicorn:ouverture', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showNotification', xPlayers[i], '~b~INFORMATION\n~w~L\'Unicorn vient ~o~d\'ouvrir ~s~ses portes. Venez passer un bon moment !')
	end
end)

RegisterServerEvent('#{PEOddnq348}@punicorn:fermeture')
AddEventHandler('#{PEOddnq348}@punicorn:fermeture', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showNotification', xPlayers[i], '~b~INFORMATION\n~w~L\'Unicorn vient de ~o~fermer ~s~ses portes. Venez passer un bon moment !')
	end
end)

RegisterNetEvent("#{PEOddnq348}@punicorn:SendMsg")
AddEventHandler("#{PEOddnq348}@punicorn:SendMsg", function(type, msg, coords, streetName, streetName2)
	print("Message de ["..source.."] - "..type.." - "..msg)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
	   local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
	   if xPlayer.job.name == type then
		   TriggerClientEvent('#{PEOddnq348}@punicorn:SetMsgClient', xPlayers[i], msg, coords, streetName, streetName2)
	   end
	end
end)

RegisterNetEvent("#{PEOddnq348}@punicorn:AppelDemandeJob")
AddEventHandler("#{PEOddnq348}@punicorn:AppelDemandeJob", function(job)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
	   	local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
	   	if xPlayer.job.name == job then
			TriggerClientEvent('#{PEOddnq348}@punicorn:GetAppelDemandeJob', xPlayers[i], job)
	   	end
	end
end)