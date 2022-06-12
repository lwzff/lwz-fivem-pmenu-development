ESX = nil
local PlayersTransforming  = {}
local PlayersTransformingOrFondu = {}
local PlayersSelling       = {}
local PlayersHarvesting = {}
local lingot = 1

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


TriggerEvent('esx_phone:registerNumber', 'orpailleur', ('orpailleur_client'), true, true)
TriggerEvent('esx_society:registerSociety', 'orpailleur', 'Orpailleur', 'society_orpailleur', 'society_orpailleur', 'society_orpailleur', {type = 'private'})

local function Harvest(source, zone)
	if PlayersHarvesting[source] == true then

		local xPlayer  = ESX.GetPlayerFromId(source)
		if xPlayer ~= nil and zone == "orFarm" then
		--if zone == "RaisinFarm" then
			local itemQuantity = xPlayer.getInventoryItem('or').count
			if itemQuantity >= 100 then
				TriggerClientEvent('esx:showNotification', source, _U('not_enough_place'))
				return
			else
				SetTimeout(1800, function()
					xPlayer.addInventoryItem('or', 1)
					Harvest(source, zone)
				end)
			end
		end
	end
end


RegisterServerEvent('esx_orpailleurjob:getStockItem')
AddEventHandler('esx_orpailleurjob:getStockItem', function(itemName, count)

	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_orpailleur', function(inventory)

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

ESX.RegisterServerCallback('esx_orpailleurjob:getStockItems', function(source, cb)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_orpailleur', function(inventory)
		cb(inventory.items)
	end)

end)

RegisterServerEvent('esx_orpailleurjob:putStockItems')
AddEventHandler('esx_orpailleurjob:putStockItems', function(itemName, count)
  local xPlayer = ESX.GetPlayerFromId(source)
  local sourceItem = xPlayer.getInventoryItem(itemName)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_orpailleur', function(inventory)

    local inventoryItem = inventory.getItem(itemName)

    if sourceItem.count >= count and count > 0 then
      xPlayer.removeInventoryItem(itemName, count)
      inventory.addItem(itemName, count)
    else
      TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
    end

    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('added') .. count .. ' ' .. item.label)

  end)

end)

ESX.RegisterServerCallback('esx_orpailleurjob:getPlayerInventory', function(source, cb)
	local xPlayer    = ESX.GetPlayerFromId(source)
	local items      = xPlayer.inventory
	cb({
		items      = items
	})
end)

-----------------------------------------

RegisterServerEvent('{EDmdlmE12}#orpailleur:RecolteOr')
AddEventHandler('{EDmdlmE12}#orpailleur:RecolteOr', function()
	local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  local itemQuantity = xPlayer.getInventoryItem('or').count
  TriggerClientEvent('esx:showNotification', _source, "~g~Récolte d'or en cours...")
	  if itemQuantity >= 100 then
		
        TriggerClientEvent('esx:showNotification', source, "Tu n'a plus de ~r~place sur toi !")
      else
					xPlayer.addInventoryItem('or', 2)
      end
end)


RegisterServerEvent('{EDmdlmE12}#orpailleur:FonteOr')
AddEventHandler('{EDmdlmE12}#orpailleur:FonteOr', function()
	local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  local itemQuantity = xPlayer.getInventoryItem('or').count
  local itemQuantity2 = xPlayer.getInventoryItem('or_fondu').count
  TriggerClientEvent('esx:showNotification', _source, '~g~Fonte en cours...')
  if itemQuantity2 >= 100 then
    TriggerClientEvent('esx:showNotification', source, "Tu n'a plus de ~r~place sur toi !")

  elseif itemQuantity <= 0 then
    TriggerClientEvent('esx:showNotification', source, "Tu n'a plus de ~y~pépite d'or sur toi !")
  else
	xPlayer.removeInventoryItem('or', 2)
  xPlayer.addInventoryItem('or_fondu', 1)
  end
end)


RegisterServerEvent('{EDmdlmE12}#orpailleur:Moulage')
AddEventHandler('{EDmdlmE12}#orpailleur:Moulage', function()
	local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  local itemQuantity = xPlayer.getInventoryItem('or_fondu').count
  local itemQuantity2 = xPlayer.getInventoryItem('lingot').count
  TriggerClientEvent('esx:showNotification', _source, '~g~Moulage en cours...')
  if itemQuantity2 >= 100 then
    TriggerClientEvent('esx:showNotification', source, "Tu n'a plus de ~r~place sur toi !")

  elseif itemQuantity <= 0 then
    TriggerClientEvent('esx:showNotification', source, "Tu n'a plus d'~y~or fondu sur toi !")
  else
	xPlayer.removeInventoryItem('or_fondu', 4)
  xPlayer.addInventoryItem('lingot', 2)
  end
end)

RegisterServerEvent('{EDmdlmE12}#orpailleur:VentePourLaRichesse')
AddEventHandler('{EDmdlmE12}#orpailleur:VentePourLaRichesse', function()
	local _source = source
	local societyAccount = nil
  local xPlayer = ESX.GetPlayerFromId(_source)
  local itemQuantity = xPlayer.getInventoryItem('lingot').count
  TriggerClientEvent('esx:showNotification', _source, '~g~Vente en cours...')
      if itemQuantity <= 0 then
        TriggerClientEvent('esx:showNotification', source, "Tu n'a plus de ~y~lingot sur toi !")
      else

        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_orpailleur', function(account)
          societyAccount = account
        end)
        if societyAccount ~= nil then
          societyAccount.addMoney(60)
          TriggerClientEvent('esx:showNotification',source,"Ton entreprise a gagné ~g~30$ !")
        end

	xPlayer.removeInventoryItem('lingot', 1)
	xPlayer.addMoney(30)
	TriggerClientEvent('esx:showNotification', source, "Tu a gagné ~g~60$ !")
      end
end)