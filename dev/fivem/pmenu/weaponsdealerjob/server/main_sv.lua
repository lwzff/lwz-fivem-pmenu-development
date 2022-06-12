ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('@{EnwE.484}:pventearmes:buyweapon')
AddEventHandler('@{EnwE.484}:pventearmes:buyweapon', function(price, ammo, weapon, label)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer.getMoney() >= price then
		xPlayer.removeMoney(price)
    	xPlayer.addWeapon(weapon, ammo)
		TriggerClientEvent('esx:showAdvancedNotification', source, "Emilio", "", "Tu as acheté un(e) ~g~" ..label.. " ~s~pour ~g~" ..price.. "$", "CHAR_LESTER_DEATHWISH", 0) 
    else
		TriggerClientEvent('esx:showAdvancedNotification', source, "Emilio", "", "Tu n'as pas assez d'argent. ~g~(" ..price.. "$)", "CHAR_LESTER_DEATHWISH", 0) 
    end
end)

RegisterServerEvent('@{EnwE.484}:pventearmes:buyitem')
AddEventHandler('@{EnwE.484}:pventearmes:buyitem', function(price, quantity, item, label)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer.getMoney() >= price then
		xPlayer.removeMoney(price)
    	xPlayer.addInventoryItem(item, quantity)
		TriggerClientEvent('esx:showAdvancedNotification', source, "Emilio", "", "Tu as acheté un(e) ~g~" ..label.. " ~s~pour ~g~" ..price.. "$", "CHAR_LESTER_DEATHWISH", 0) 
    else
		TriggerClientEvent('esx:showAdvancedNotification', source, "Emilio", "", "Tu n'as pas assez d'argent. ~g~(" ..price.. "$)", "CHAR_LESTER_DEATHWISH", 0) 
    end
end)

RegisterServerEvent('@{EnwE.484}:pventearmes:getStockItem')
AddEventHandler('@{EnwE.484}:pventearmes:getStockItem', function(itemName, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_venarm', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- is there enough in the society?
		if count > 0 and inventoryItem.count >= count then

			-- can the player carry the said amount of x item?
			if sourceItem.limit ~= -1 and (sourceItem.count + count) > sourceItem.limit then
				TriggerClientEvent('esx:showNotification', _source, "~r~Quantité invalide.")
			else
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent('esx:showNotification', _source, "Tu as retiré ~r~"..count.." "..inventoryItem.name.."~s~.")
			end
		else
			TriggerClientEvent('esx:showNotification', _source, "~r~Quantité invalide.")
		end
	end)
end)

RegisterServerEvent('@{EnwE.484}:pventearmes:putStockItems')
AddEventHandler('@{EnwE.484}:pventearmes:putStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_venarm', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- does the player have enough of the item?
		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('esx:showNotification', xPlayer.source, "Tu as déposé ~g~x"..count.." "..inventoryItem.label.."~s~.")
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, "~r~Quantité invalide !")
		end
	end)
end)

ESX.RegisterServerCallback('@{EnwE.484}:pventearmes:getStockItems', function(source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_venarm', function(inventory)
		cb(inventory.items)
	end)
end)

ESX.RegisterServerCallback('@{EnwE.484}:pventearmes:getPlayerInventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory

	cb( { items = items } )
end)

RegisterServerEvent('@{EnwE.484}:pventearmes:ouverture')
AddEventHandler('@{EnwE.484}:pventearmes:ouverture', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showNotification', xPlayers[i], '~b~INFORMATION\n~w~La boite Dallas Industries vient ~o~d\'ouvrir ~s~ses portes. Viens maintenant !')
	end
end)

RegisterServerEvent('@{EnwE.484}:pventearmes:fermeture')
AddEventHandler('@{EnwE.484}:pventearmes:fermeture', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showNotification', xPlayers[i], '~b~INFORMATION\n~w~La boite Dallas Industries vient de ~o~fermer ~s~ses portes. Repasse plus tard !')
	end
end)
