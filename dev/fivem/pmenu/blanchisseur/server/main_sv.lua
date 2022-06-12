ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('@#{WKK.931JE}#:getOtherPlayerData', function(source, cb, target, notify)
	local xPlayer = ESX.GetPlayerFromId(target)

	if notify then
		xPlayer.showNotification(_U('being_searched'))
	end

	if xPlayer then
		local data = {
			name = xPlayer.getName(),
			job = xPlayer.job.label,
			grade = xPlayer.job.grade_label,
			inventory = xPlayer.getInventory(),
			accounts = xPlayer.getAccounts(),
			weapons = xPlayer.getLoadout()
		}

		if Config.EnableESXIdentity then
			data.dob = xPlayer.get('dateofbirth')
			data.height = xPlayer.get('height')

			if xPlayer.get('sex') == 'm' then data.sex = 'male' else data.sex = 'female' end
		end

		TriggerEvent('stk_status:getStatus', target, 'drunk', function(status)
			if status then
				data.drunk = ESX.Math.Round(status.percent)
			end

			if Config.EnableLicenses then
				TriggerEvent('stk_license:getLicenses', target, function(licenses)
					data.licenses = licenses
					cb(data)
				end)
			else
				cb(data)
			end
		end)
	end
end)

RegisterNetEvent('@#{WKK.931JE}#:spawned')
AddEventHandler('@#{WKK.931JE}#:spawned', function()
	local xPlayer = ESX.GetPlayerFromId(playerId)

	if xPlayer and xPlayer.job2.name == 'blanchisseur' then
		Citizen.Wait(5000)
		TriggerClientEvent('@#{WKK.931JE}#:updateBlip', -1)
	end
end)

RegisterNetEvent('@#{WKK.931JE}#:forceBlip')
AddEventHandler('@#{WKK.931JE}#:forceBlip', function()
	TriggerClientEvent('@#{WKK.931JE}#:updateBlip', -1)
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.Wait(5000)
		TriggerClientEvent('@#{WKK.931JE}#:updateBlip', -1)
	end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TriggerEvent('stk_phone:removeNumber', 'blanchisseur')
	end
end)

RegisterServerEvent('@#{WKK.931JE}#:washMoneyJob')
AddEventHandler('@#{WKK.931JE}#:washMoneyJob', function(amount)
	local xPlayer 		= ESX.GetPlayerFromId(source)
	local account 		= xPlayer.getAccount('black_money')
	
	if amount > 0 and account.money >= amount then
		
		
		local washedMoney = amount	

		xPlayer.removeAccountMoney('black_money', amount)
		xPlayer.addMoney(washedMoney)
		
		TriggerClientEvent("esx:showNotification", source, "tu as blanchi ~g~+" .. washedMoney .. "~g~$ ~s~d'argent sales")
		
	else
		TriggerClientEvent("esx:showNotification", source, "Montant invalide")
	end

end)