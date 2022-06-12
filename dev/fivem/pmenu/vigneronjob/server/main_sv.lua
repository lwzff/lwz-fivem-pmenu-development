
ESX = nil
local PlayersTransforming, PlayersSelling, PlayersHarvesting = {}, {}, {}
local vine, jus = 1, 1

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
TriggerEvent('esx_phone:registerNumber', 'vigneron', ('vigneron_client'), true, true)
TriggerEvent('esx_society:registerSociety', 'vigneron', 'Vigneron', 'society_vigneron', 'society_vigneron', 'society_vigneron', {type = 'private'})

RegisterServerEvent('esx_vigneronjob:getStockItem')
AddEventHandler('esx_vigneronjob:getStockItem', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_vigne', function(inventory)
		local item = inventory.getItem(itemName)

		if item.count >= count then
			inventory.removeItem(itemName, count)
			xPlayer.addInventoryItem(itemName, count)
		else
			xPlayer.showNotification(_U('quantity_invalid'))
		end

		xPlayer.showNotification(_U('have_withdrawn') .. count .. ' ' .. item.label)
	end)
end)

ESX.RegisterServerCallback('esx_vigneronjob:getStockItems', function(source, cb)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_vigne', function(inventory)
		cb(inventory.items)
	end)
end)

RegisterServerEvent('stk_vigneron:putStockItems')
AddEventHandler('stk_vigneron:putStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_vigne', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- does the player have enough of the item?
		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_deposited', count, inventoryItem.label))
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
		end
	end)
end)

ESX.RegisterServerCallback('esx_vigneronjob:getPlayerInventory', function(source, cb)
	local xPlayer    = ESX.GetPlayerFromId(source)
	local items      = xPlayer.inventory

	cb({
		items      = items
	})
end)

ESX.RegisterUsableItem('jus_raisin', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('jus_raisin', 1)

	TriggerClientEvent('esx_status:add', source, 'hunger', 40000)
	TriggerClientEvent('esx_status:add', source, 'thirst', 120000)
	TriggerClientEvent('esx_basicneeds:onDrink', source)
	xPlayer.showNotification(_U('used_jus'))
end)

ESX.RegisterUsableItem('grand_cru', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('grand_cru', 1)

	TriggerClientEvent('esx_status:add', source, 'drunk', 400000)
	TriggerClientEvent('esx_basicneeds:onDrink', source)
	xPlayer.showNotification(_U('used_grand_cru'))
end)

--------------------------------------------------------------

RegisterServerEvent('stk_vigneron:RecolteRaisin')
AddEventHandler('stk_vigneron:RecolteRaisin', function()
	local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  local itemQuantity = xPlayer.getInventoryItem('raisin').count
  TriggerClientEvent('esx:showNotification', source, "~g~Récolte en cours")
      if itemQuantity >= 100 then
        TriggerClientEvent('esx:showNotification', source, "Tu n'a plus de ~r~place sur toi !")
      else
					xPlayer.addInventoryItem('raisin', 5)
      end
end)

RegisterServerEvent('stk_vigneron:TraitementRaisin')
AddEventHandler('stk_vigneron:TraitementRaisin', function()
	local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  local itemQuantity = xPlayer.getInventoryItem('raisin').count
  local itemQuantity2 = xPlayer.getInventoryItem('jus_raisin').count
  TriggerClientEvent('esx:showNotification', source, "~g~Traitement en cours")
  if itemQuantity2 >= 100 then
    TriggerClientEvent('esx:showNotification', source, "Tu n'a plus de ~r~place sur toi !")

  elseif itemQuantity <= 0 then
    TriggerClientEvent('esx:showNotification', source, "Tu n'a plus de ~p~raisin sur toi !")
  else
	xPlayer.removeInventoryItem('raisin', 2)
  xPlayer.addInventoryItem('jus_raisin', 1)
  end
end)

RegisterServerEvent('stk_vigneron:TraitementJus')
AddEventHandler('stk_vigneron:TraitementJus', function()
	local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  local itemQuantity = xPlayer.getInventoryItem('jus_raisin').count
  local itemQuantity2 = xPlayer.getInventoryItem('vine').count
  TriggerClientEvent('esx:showNotification', source, "~g~Traitement en cours")
  if itemQuantity2 >= 100 then
    TriggerClientEvent('esx:showNotification', source, "Tu n'a plus de ~r~place sur toi !")

  elseif itemQuantity <= 0 then
    TriggerClientEvent('esx:showNotification', source, "Tu n'a plus de ~p~Jus sur toi !")
  else
	xPlayer.removeInventoryItem('jus_raisin', 4)
  xPlayer.addInventoryItem('vine', 2)
  end
end)


RegisterServerEvent('stk_vigneron:VenteDeBonSHitSaDarroneDeMere')
AddEventHandler('stk_vigneron:VenteDeBonSHitSaDarroneDeMere', function()
	local _source = source
	local societyAccount = nil
  local xPlayer = ESX.GetPlayerFromId(_source)
  local itemQuantity = xPlayer.getInventoryItem('vine').count

  TriggerClientEvent('esx:showNotification', source, "~g~Vente en Cours")
      if itemQuantity <= 0 then
		TriggerClientEvent('esx:showNotification', source, "Tu n'a plus de ~p~Vin sur toi !")
	else

		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_vigneron', function(account)
			societyAccount = account
		end)
		if societyAccount ~= nil then
			societyAccount.addMoney(30)
			TriggerClientEvent('esx:showNotification',source,"Ton entreprise a gagné ~g~30$ !")
		end


	xPlayer.removeInventoryItem('vine', 1)
	xPlayer.addMoney(30)
	TriggerClientEvent('esx:showNotification', source, "Tu a gagné ~g~30$ !")
      end
end)



TriggerEvent('esx_addonaccount:getSharedAccount', 'society_vigne', function(account)
	societyAccount = account
end)
if societyAccount ~= nil then
	societyAccount.addMoney(money)
	TriggerClientEvent('esx:showNotification', xPlayer.source, _U('comp_earned') .. money)
end