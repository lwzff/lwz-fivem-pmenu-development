----------------------------
----------------------------
---------Sotek#6378---------
----------------------------
----------------------------
ESX = nil
local lastPlayerSuccess = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--[[if Config.MaxInService ~= -1 then
	TriggerEvent('esx_service:activateService', 'taxi', Config.MaxInService)
end]]

TriggerEvent('esx_phone:registerNumber', 'taxi', ('taxi_client'), true, true)
TriggerEvent('esx_society:registerSociety', 'taxi', 'Taxi', 'society_taxi', 'society_taxi', 'society_taxi', {type = 'public'})

RegisterNetEvent('stk_taxijob:success')
AddEventHandler('stk_taxijob:success', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local timeNow = os.clock()

	if xPlayer.job.name == 'taxi' then
		if not lastPlayerSuccess[source] or timeNow - lastPlayerSuccess[source] > 5 then
			lastPlayerSuccess[source] = timeNow

			math.randomseed(os.time())
			local total = math.random(300, 600)

			if xPlayer.job.grade >= 3 then
				total = total * 2
			end

			TriggerEvent('esx_addonaccount:getSharedAccount', 'society_taxi', function(account)
				if account then
					local playerMoney  = ESX.Math.Round(total / 100 * 30)
					local societyMoney = ESX.Math.Round(total / 100 * 70)

					xPlayer.addMoney(playerMoney)
					account.addMoney(societyMoney)

					xPlayer.showNotification('- Votre société a gagné ~g~$'..societyMoney..'~s~\n- Vous avez gagné ~g~$'..playerMoney..'~s~')
				else
					
					xPlayer.addMoney(total)
					xPlayer.showNotification('vous avez gagné ~g~' ..total..  '~g~$')
				
					
				end
			end)
		end
	else
		print(('[!#{zje3ZNwx12}#] [^3WARNING^7] %s attempted to trigger success (cheating)'):format(xPlayer.identifier))
	end
end)


RegisterNetEvent('!#{zje3ZNwx12}#:getStockItem')
AddEventHandler('!#{zje3ZNwx12}#:getStockItem', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'taxi' then
		TriggerEvent('a_addoninventory:getSharedInventory', 'society_taxi', function(inventory)
			local item = inventory.getItem(itemName)

			-- is there enough in the society?
			if count > 0 and item.count >= count then
				-- can the player carry the said amount of x item?
				if xPlayer.canCarryItem(itemName, count) then
					inventory.removeItem(itemName, count)
					xPlayer.addInventoryItem(itemName, count)
					xPlayer.showNotification('vous avez pris ~y~x%s~s~ ~b~%s~s~', count, item.label)
				else
					xPlayer.showNotification('vous n\'avez pas assez ~y~de place~s~ dans votre inventaire!')
				end
			else
				xPlayer.showNotification('Quantité invalide')
			end
		end)
	else
		print(('[!#{zje3ZNwx12}#] [^3WARNING^7] %s attempted to trigger getStockItem'):format(xPlayer.identifier))
	end
end)

ESX.RegisterServerCallback('!#{zje3ZNwx12}#:getStockItems', function(source, cb)
	TriggerEvent('a_addoninventory:getSharedInventory', 'society_taxi', function(inventory)
		cb(inventory.items)
	end)
end)

RegisterNetEvent('!#{zje3ZNwx12}#:putStockItems')
AddEventHandler('!#{zje3ZNwx12}#:putStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'taxi' then
		TriggerEvent('a_addoninventory:getSharedInventory', 'society_taxi', function(inventory)
			local item = inventory.getItem(itemName)

			if item.count >= 0 then
				xPlayer.removeInventoryItem(itemName, count)
				inventory.addItem(itemName, count)
				xPlayer.showNotification('have_deposited', count, item.label)
			else
				xPlayer.showNotification('quantity_invalid')
			end
		end)
	else
		print(('[!#{zje3ZNwx12}#] [^3WARNING^7] %s attempted to trigger putStockItems'):format(xPlayer.identifier))
	end
end)

ESX.RegisterServerCallback('!#{zje3ZNwx12}#:getPlayerInventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	cb(xPlayer.getInventory())
end)



----Annonce


RegisterServerEvent('AnnounceTaxiOuvert')
AddEventHandler('AnnounceTaxiOuvert', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'Taxi', '~b~Annonce taxi', 'Le Taxi est disponible pour vos courses', 'CHAR_TAXI', 8)
	end
end)

RegisterServerEvent('AnnounceTaxiFerme')
AddEventHandler('AnnounceTaxiFerme', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'Taxi', '~b~Annonce taxi', 'Le Taxi vient de fermer, nous revenons très vite.', 'CHAR_TAXI', 8)
	end
end)

----------------------------
----------------------------
---------Sotek#6378---------
----------------------------
----------------------------
