ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local availableJobs = {}
local WipeData = {}
ESX.RegisterServerCallback('SotekAdmin:Admin_getUsergroup', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer ~= nil then
		local playerGroup = xPlayer.getGroup()

        if playerGroup ~= nil then 
            cb(playerGroup)
        else
            cb(nil)
        end
	else
		cb(nil)
	end
end)
function getMaximumGrade(jobname)
	local queryDone, queryResult = false, nil
	MySQL.Async.fetchAll('SELECT * FROM job_grades WHERE job_name = @jobname ORDER BY `grade` DESC ;', {
		['@jobname'] = jobname
	}, function(result)
        queryDone, queryResult = true, result
	end)
	while not queryDone do
		Citizen.Wait(10)
	end
	if queryResult[1] then
		return queryResult[1].grade
	end
	return nil
end
ESX.RegisterServerCallback('specstaff:getPlayerData', function(source, cb, id)
    local xPlayer = ESX.GetPlayerFromId(id)
    if xPlayer ~= nil then
        cb(xPlayer)
    end
end)
RegisterServerEvent('{#04WNWejd}@:PlayerWipe') 
AddEventHandler('{#04WNWejd}@:PlayerWipe', function(data, id, pname) 
	MySQL.Async.execute(" DELETE FROM addon_account_data WHERE owner = @wipeID; DELETE FROM addon_inventory_items WHERE owner = @wipeID; DELETE FROM billing WHERE identifier = @wipeID; DELETE FROM billing WHERE sender = @wipeID; DELETE FROM datastore_data WHERE owner = @wipeID; DELETE FROM open_car WHERE identifier = @wipeID; DELETE FROM owned_properties WHERE owner = @wipeID; DELETE FROM owned_vehicles WHERE owner = @wipeID; DELETE FROM owned_boats WHERE owner = @wipeID; DELETE FROM rented_vehicles WHERE owner = @wipeID; DELETE FROM open_car WHERE identifier = @wipeID; DELETE FROM user_accounts WHERE identifier = @wipeID; DELETE FROM phone_calls WHERE owner = @wipeTEL; DELETE FROM phone_messages WHERE transmitter = @wipeTEL; DELETE FROM phone_messages WHERE receiver = @wipeTEL; DELETE FROM phone_users_contacts WHERE identifier = @wipeID; DELETE FROM phone_users_contacts WHERE number = @wipeTEL; DELETE FROM playerstattoos WHERE identifier = @wipeID; DELETE FROM user_inventory WHERE identifier = @wipeID; DELETE FROM user_licenses WHERE owner = @wipeID; DELETE FROM characters WHERE identifier = @wipeID; DELETE FROM users WHERE identifier = @wipeID; ", { ['@wipeID'] = data.ID }, function(rowsChanged) 
		table.insert(WipeData, data) 
    end) 
	DropPlayer(id, "Ton personnage a été réinitialisé (wipe).")
	print(id)
	print(json.encode(id))

end)
-- Setjob
RegisterNetEvent("{#192AJdn}@:SetJob")
AddEventHandler("{#192AJdn}@:SetJob", function(id, job, grade)
	local xPlayer = ESX.GetPlayerFromId(id)
	xPlayer.setJob(job, grade)

end)


RegisterNetEvent("{#192AJdn}@:GetJob")
AddEventHandler("{#192AJdn}@:GetJob", function(id, job, grade)
	local xPlayer = ESX.GetPlayerFromId(id)
	xPlayer.getJob()

end)
RegisterNetEvent("{#192AJdn}@:Kick")
AddEventHandler("{#192AJdn}@:Kick", function(id, raison)
	DropPlayer(id, raison)
end)
function SessionBanPlayer(id, steam, source, type)
	table.insert(SessionBanned, steam)
	WarnsLog(id, source, type, true)
	DropPlayer(id, SessionBanMsg)
end



RegisterNetEvent("{#04WNWejd}@:SendMsgToPlayer")
AddEventHandler("{#04WNWejd}@:SendMsgToPlayer", function(id, msg)
    TriggerClientEvent('esx:showNotification', id, "~b~MESSAGE STAFF\n~w~"..msg)
end) 
local warns = {}
RegisterNetEvent("{#192AJdn}@:RegisterWarn")
AddEventHandler("{#192AJdn}@:RegisterWarn", function(id, type)
	local steam = GetPlayerIdentifier(id, 0)
	local warnsGet = 0
	local found = false
	for k,v in pairs(warns) do
		if v.id == steam then
			found = true
			warnsGet = v.warns
			table.remove(warns, k)
			break
		end
	end
	if not found then
		table.insert(warns, {
			id = steam,
			warns = 1
		})
	else
		table.insert(warns, {
			id = steam,
			warns = warnsGet + 1
		})
	end
	print(warnsGet+1)
	if warnsGet+1 >= 3 then
		--SessionBanPlayer(id, steam, source, type)
		DropPlayer(id, "Vous avez dépassé la limite de warn. Vous avez été kick du serveur. Merci de lire le règlement.")
	else
		--WarnsLog(id, source, type, false)
		TriggerClientEvent("{#192AJdn}@:RegisterWarn", id, type)
	end
end)


ESX.RegisterServerCallback("{@Wzn394}#:getJobs", function(source, cb, target)
    local xTarget = ESX.GetPlayerFromId(target)
    local myPlayerJob = xTarget.getJob()

    cb(myPlayerJob)
   
end)

ESX.RegisterServerCallback("{@Wzn394}#:getOrgs", function(source, cb, target)
    local xTarget = ESX.GetPlayerFromId(target)
    local myPlayerOrg = xTarget.getOrg()

    cb(myPlayerOrg)

end)

ESX.RegisterServerCallback("{@Wzn394}#:money", function(source, cb, target )
    local xTarget = ESX.GetPlayerFromId(target)
    local myPlayerAccount = xTarget.getMoney()

    cb(myPlayerAccount)

end)

ESX.RegisterServerCallback("{@Wzn394}#:banque", function(source, cb, target)
    local xTarget = ESX.GetPlayerFromId(target)
    local myPlayerAccount = xTarget.getAccounts()

    cb(myPlayerAccount)

end)

ESX.RegisterServerCallback("{@Wzn394}#:sale", function(source, cb, target)
    local xTarget = ESX.GetPlayerFromId(target)
    local myPlayerSale = xTarget.getAccounts()

    cb(myPlayerSale)

end)

ESX.RegisterServerCallback("{@Wzn394}#:inventaire", function(source, cb, target, minimal )
    local xTarget = ESX.GetPlayerFromId(target)
    local myPlayerInv = xTarget.getInventory(minimal)

    cb(myPlayerInv)

end)

ESX.RegisterServerCallback("{@Wzn394}#:weapon", function(source, cb, target, weaponName )
    local xTarget = ESX.GetPlayerFromId(target)
    local myPlayerWeapon = xTarget.getLoadout()

    cb(myPlayerWeapon)

end)

-- Items
RegisterServerEvent('{#192AJdn}@:giveitems')
AddEventHandler('{#192AJdn}@:giveitems', function(id, items, quantit)
	local xPlayer = ESX.GetPlayerFromId(id)
    xPlayer.addInventoryItem(items, quantit)
end)



RegisterServerEvent('{#192AJdn}@:giveweapon')
AddEventHandler('{#192AJdn}@:giveweapon', function(id, weapon)
	local xPlayer = ESX.GetPlayerFromId(id)
    xPlayer.addWeapon(weapon, 350)
end)
RegisterNetEvent("{#04WNWejd}@:GetPlayerInfo")
AddEventHandler("{#04WNWejd}@:GetPlayerInfo", function(id, pname)
    TriggerClientEvent('esx:showNotification', source, "~b~("..id..") - "..pname.."\n\n~w~Steam HEX : "..GetPlayerIdentifier(id))
    --DropPlayer(id, "Ton personnage a été réinitialisé (wipe).")
end) 
ESX.RegisterServerCallback("{@Wzn394}#:id", function(source, cb, target)
    local xTarget = ESX.GetPlayerFromId(target)
    local myPlayerid = xTarget.getIdentifier()

    cb(myPlayerid)


end)    


--remove inventory item

RegisterServerEvent('{#192AJdn}@:removeitem')
AddEventHandler('{#192AJdn}@:removeitem', function(id, item,count)
	local xPlayer = ESX.GetPlayerFromId(id)
	xPlayer.removeInventoryItem(item, count)
end)

ESX.RegisterServerCallback("{@Wzn394}#:inv", function(source, cb, target , item, count)
    local xTarget = ESX.GetPlayerFromId(target)
	local myPlayerremo = xTarget.removeInventoryItem(myPlayerInv, count)

    cb(myPlayerremo)


end)   


RegisterServerEvent('soso_admin:momo')
AddEventHandler('soso_admin:momo', function(id, money)
	local xPlayer = ESX.GetPlayerFromId(id)
    xPlayer.addMoney(money)
end)

RegisterServerEvent('soso_admin:momobanque')
AddEventHandler('soso_admin:momobanque', function(id, money)
	local xPlayer = ESX.GetPlayerFromId(id)
    xPlayer.addAccountMoney('bank' , money)
end)

RegisterServerEvent('soso_admin:momosale')
AddEventHandler('soso_admin:momosale', function(id, money)
	local xPlayer = ESX.GetPlayerFromId(id)
    xPlayer.addAccountMoney('black_money', money)
end)


RegisterServerEvent('soso_admin:removemoeney')
AddEventHandler('soso_admin:removemoeney', function(id, money)
	local xPlayer = ESX.GetPlayerFromId(id)
	xPlayer.removeMoney(money)
end)


RegisterServerEvent('soso_admin:removebanque')
AddEventHandler('soso_admin:removebanque', function(id, money)
	local xPlayer = ESX.GetPlayerFromId(id)
	xPlayer.removeAccountMoney('bank', money)
end)


RegisterServerEvent('soso_admin:removesale')
AddEventHandler('soso_admin:removesale', function(id, money)
	local xPlayer = ESX.GetPlayerFromId(id)
	xPlayer.removeAccountMoney('black_money', money)
end)

RegisterServerEvent('soso_admin:removeweapon')
AddEventHandler('soso_admin:removeweapon', function(id, weapon)
	local xPlayer = ESX.GetPlayerFromId(id)
	xPlayer.removeWeapon(weapon)
end)

ESX.RegisterServerCallback('Sotek:getPlayerLoadout', function(source, cb)
	TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer ~= nil then
		local playerLoadout = xPlayer.getLoadout()
		
		cb(playerLoadout)
	else
		cb(nil)
	end
end)
RegisterServerEvent('soso_admin:ez')
AddEventHandler('soso_admin:ez', function(id, item,count)
	local xPlayer = ESX.GetPlayerFromId(id)
	xPlayer.removeInventoryItem(item, count)
end)
