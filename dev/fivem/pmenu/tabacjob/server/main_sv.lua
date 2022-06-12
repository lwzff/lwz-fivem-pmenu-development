
ESX = nil
local PlayersTransforming  = {}
local PlayersSelling       = {}
local PlayersHarvesting = {}
local malbora = 1
local winston = 1
local spliff = 1
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


TriggerEvent('esx_phone:registerNumber', 'tabac', ('tabac_client'), true, true)
TriggerEvent('esx_society:registerSociety', 'tabac', 'Tabac', 'society_tabac', 'society_tabac', 'society_tabac', {type = 'private'})


RegisterServerEvent('esx_tabac:getStockItem')
AddEventHandler('esx_tabac:getStockItem', function(itemName, count)

	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_tabac', function(inventory)

		local item = inventory.getItem(itemName)

		if item.count >= count then
			inventory.removeItem(itemName, count)
			xPlayer.addInventoryItem(itemName, count)
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
		end

		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_withdrawn') .. count .. ' ' .. item.label)

	end)

end)

ESX.RegisterServerCallback('esx_tabac:getStockItems', function(source, cb)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_tabac', function(inventory)
		cb(inventory.items)
	end)

end)

RegisterServerEvent('esx_tabac:putStockItems')
AddEventHandler('esx_tabac:putStockItems', function(itemName, count)

	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_tabac', function(inventory)

		local item = inventory.getItem(itemName)

		if item.count >= 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
		end

		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('added') .. count .. ' ' .. item.label)

	end)
end)

ESX.RegisterServerCallback('esx_tabac:getPlayerInventory', function(source, cb)

	local xPlayer    = ESX.GetPlayerFromId(source)
	local items      = xPlayer.inventory

	cb({
		items      = items
	})

end)

-------

RegisterServerEvent('!@{#KDKwnw10}#:RecolteTabac')
AddEventHandler('!@{#KDKwnw10}#:RecolteTabac', function()
	local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  local itemQuantity = xPlayer.getInventoryItem('tabac').count
  TriggerClientEvent('esx:showNotification', _source, "~g~Récolte en cours...")
	  if itemQuantity >= 100 then
		
        TriggerClientEvent('esx:showNotification', source, "Tu n'a plus de ~r~place sur toi !")
      else
					xPlayer.addInventoryItem('tabac', 2)
      end
end)


RegisterServerEvent('!@{#KDKwnw10}#:TraitementMarlboro')
AddEventHandler('!@{#KDKwnw10}#:TraitementMarlboro', function()
	local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  local itemQuantity = xPlayer.getInventoryItem('tabac').count
  local itemQuantity2 = xPlayer.getInventoryItem('malbora').count
  TriggerClientEvent('esx:showNotification', _source, '~g~Traitement en cours...')
  if itemQuantity2 >= 100 then
    TriggerClientEvent('esx:showNotification', source, "Tu n'a plus de ~r~place sur toi !")

  elseif itemQuantity <= 0 then
    TriggerClientEvent('esx:showNotification', source, "Tu n'a plus de ~y~ tabac sur toi !")
  else
	xPlayer.removeInventoryItem('tabac', 2)
  xPlayer.addInventoryItem('malbora', 1)
  end
end)

RegisterServerEvent('!@{#KDKwnw10}#:TraitementWinston')
AddEventHandler('!@{#KDKwnw10}#:TraitementWinston', function()
	local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  local itemQuantity = xPlayer.getInventoryItem('tabac').count
  local itemQuantity2 = xPlayer.getInventoryItem('winston').count
  TriggerClientEvent('esx:showNotification', _source, '~g~Traitement en cours...')
  if itemQuantity2 >= 100 then
    TriggerClientEvent('esx:showNotification', source, "Tu n'a plus de ~r~place sur toi !")

  elseif itemQuantity <= 0 then
    TriggerClientEvent('esx:showNotification', source, "Tu n'a plus de ~y~ tabac ~s~sur toi !")
  else
	xPlayer.removeInventoryItem('tabac', 2)
  xPlayer.addInventoryItem('winston', 1)
  end
end)


RegisterServerEvent('!@{#KDKwnw10}#:VenteMarlboro')
AddEventHandler('!@{#KDKwnw10}#:VenteMarlboro', function()
	local _source = source
	local societyAccount = nil
  local xPlayer = ESX.GetPlayerFromId(_source)
  local itemQuantity = xPlayer.getInventoryItem('malbora').count
  TriggerClientEvent('esx:showNotification', _source, '~g~Vente en cours...')
      if itemQuantity <= 0 then
        TriggerClientEvent('esx:showNotification', source, "Tu n'a plus de ~y~Marlboro sur toi !")
	  else
		
		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_tabac', function(account)
			societyAccount = account
		end)
		if societyAccount ~= nil then
			societyAccount.addMoney(90)
			TriggerClientEvent('esx:showNotification',source,"Ton entreprise a gagné ~g~90$ !")
		end
	xPlayer.removeInventoryItem('malbora', 1)
	xPlayer.addMoney(30)
	TriggerClientEvent('esx:showNotification', source, "Tu a gagné ~g~30$ !")
	TriggerClientEvent('esx:drawMissionText', source, "Test", 1)
      end
end)



RegisterServerEvent('!@{#KDKwnw10}#:VenteWinston')
AddEventHandler('!@{#KDKwnw10}#:VenteWinston', function()
	local _source = source
	local societyAccount = nil
  local xPlayer = ESX.GetPlayerFromId(_source)
  local itemQuantity = xPlayer.getInventoryItem('winston').count
  TriggerClientEvent('esx:showNotification', _source, '~g~Vente en cours...')
      if itemQuantity <= 0 then
        TriggerClientEvent('esx:showNotification', source, "Tu n'a plus de ~y~Winston sur toi !")
	  else
		
		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_tabac', function(account)
			societyAccount = account
		end)
		if societyAccount ~= nil then
			societyAccount.addMoney(60)
			TriggerClientEvent('esx:showNotification',source,"Ton entreprise a gagné ~g~60$ !")
		end
		
	xPlayer.removeInventoryItem('winston', 1)
	xPlayer.addMoney(30)
	TriggerClientEvent('esx:showNotification', source, "Tu a gagné ~g~30$ !")
	TriggerClientEvent('esx:drawMissionText', source, "Test", 1)
      end
end)

ESX.RegisterUsableItem('winston', function(source)

	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('winston', 1)

	TriggerClientEvent('esx_status:add', source, 'hunger', 40000)
	TriggerClientEvent('esx_status:add', source, 'thirst', 120000)
	TriggerClientEvent('esx_basicneeds:onDrink', source)
	TriggerClientEvent('esx:showNotification', source, _U('used_win'))

end)

ESX.RegisterUsableItem('spliff', function(source)

	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('spliff', 1)

	TriggerClientEvent('esx_status:add', source, 'drunk', 400000)
	TriggerClientEvent('esx_basicneeds:onDrink', source)
	TriggerClientEvent('esx:showNotification', source, _U('used_spliff'))

end)
