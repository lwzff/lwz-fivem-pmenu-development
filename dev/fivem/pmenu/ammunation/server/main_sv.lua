ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('!{#EZKww103}#:buyweapon')
AddEventHandler('!{#EZKww103}#:buyweapon', function(price, weapon, label)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer.getMoney() >= price then
		xPlayer.removeMoney(price)
    	xPlayer.addWeapon(weapon, 255)
		TriggerClientEvent('esx:showAdvancedNotification', source, "Armurerie", "", "Tu as acheté un(e) ~g~" ..label.. " ~s~pour ~g~" ..price.. "$", "CHAR_AMMUNATION", 0) 
    else
		TriggerClientEvent('esx:showAdvancedNotification', source, "Armurerie", "", "Tu n'as pas assez d'argent. ~g~(" ..price.. "$)", "CHAR_AMMUNATION", 0) 
    end
end)

RegisterServerEvent('!{#EZKww103}#:buyammo')
AddEventHandler('!{#EZKww103}#:buyammo', function(price, label)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer.getMoney() >= price then
		xPlayer.removeMoney(price)
		TriggerClientEvent('!{#EZKww103}#:buyammo2', _source)
		TriggerClientEvent('esx:showAdvancedNotification', source, "Armurerie", "", "Tu as acheté ~g~x50 " ..label.. " ~s~pour ~g~" ..price.. "$", "CHAR_AMMUNATION", 0)
    else
		TriggerClientEvent('esx:showAdvancedNotification', source, "Armurerie", "", "Tu n'as pas assez d'argent. ~g~(" ..price.. "$)", "CHAR_AMMUNATION", 0) 
    end
end)

ESX.RegisterServerCallback('!{#EZKww103}#:buylicense', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.getMoney() >= 35000 then
		xPlayer.removeMoney(35000)
		TriggerClientEvent('esx:showAdvancedNotification', source, "Armurerie", "", "Tu as acheté un ~g~permis de port d'armes ~s~pour ~g~35000$", "CHAR_AMMUNATION", 0) 
		xPlayer.addInventoryItem('permisarmes', 1)
		TriggerEvent('esx_license:addLicense', source, 'weapon', function()
			cb(true)
		end)
	else
		TriggerClientEvent('esx:showAdvancedNotification', source, "Armurerie", "", "Tu n'as pas assez d'argent. ~g~(35000$)", "CHAR_AMMUNATION", 0) 
		cb(false)
	end			
end)
RegisterServerEvent('!{#EZKww103}#:logsbuyppa')
AddEventHandler('!{#EZKww103}#:logsbuyppa', function(source)
	local logsbuyppa = "https://discordapp.com/api/webhooks/729378220448808990/naOuDcI8WnEyNA1cib5ZLLMJH8W4qTWY2mlp6BZDWT_e_mZPYiC2ITEFBLrOrtLaoJFH"
	local buyppatext = "lwz#2051 - Staffmod"
	local buyppalogo = "https://i.imgur.com/0SdnyOK.jpg" 
	local xPlayer = ESX.GetPlayerFromId(source)
    local name = GetPlayerName(source)
    local admin = {
            {
                ["color"] = "15158332",
                ["title"] = "**Ammu-Nation | Achat PPA**",
                ["description"] = "Joueur : **"..name.."**\n\nA acheté un **PPA** à l'Ammu-Nation pour 40.000$",
                ["footer"] = {
                    ["text"] = buyppatext,
                    ["icon_url"] = buyppalogo,
                },
            }
        }
    
        PerformHttpRequest(logsbuyppa, function(err, text, headers) end, 'POST', json.encode({username = "Ammu-Nation | Achat PPA", embeds = admin}), { ['Content-Type'] = 'application/json' })
end)