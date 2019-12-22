--
-- @Project: Onset Minigames
-- @Author: Samuelds
-- @License: GNU General Public License v3.0
-- @Source: https://github.com/Onset-minigames
--

Players = {}

--
-- Spawn jail or administration
--
function StartPlayersLocation()

	local jail = 1
	for _, playerId in pairs(GetAllPlayers()) do
		
		if Players[playerId] and Players[playerId].role then

			SetPlayerHealth(playerId, 100)
			if Players[playerId].role == "prisoner" then

				ChangeClothing(playerId, "prisoner")
				local jailLocation = Configs.jails[jail]
				SetPlayerLocation(playerId, jailLocation.x, jailLocation.y, jailLocation.z + 100)
				jail = jail + 1

			elseif Players[playerId].role == "guardian" then

				ChangeClothing(playerId, "guardian")
				SetPlayerLocation(playerId, Configs.guardians.spawn.x, Configs.guardians.spawn.y, Configs.guardians.spawn.z + 100)

			end

			-- Set role into
			CallRemoteEvent(playerId, "SetRole", Players[playerId].role)
			SetPlayerRespawnTime(playerId, 60 * 60 * 1000) -- 1 heure

		end
	end

end

--
--
--
function SetSpawnPlayer(playerId)

	local spawnLocation = Configs.spawns[Random(1, #Configs.spawns)]
	SetPlayerSpawnLocation(playerId, spawnLocation.x, spawnLocation.y, spawnLocation.z + 200, 90.0)

end

--
--
--
function SpawnPlayer(playerId)

	local spawnLocation = Configs.spawns[Random(1, #Configs.spawns)]
	SetPlayerLocation(playerId, spawnLocation.x, spawnLocation.y, spawnLocation.z + 200)

end


--
-- Get steamId
--
AddEvent("OnPlayerSteamAuth", function(playerId)

	Players[playerId].steamId = GetPlayerSteamId(playerId)

end)

--
-- Player join
--
AddEvent("OnPlayerJoin", function(playerId)

	-- Init player
	Players[playerId] = {}
	SetSpawnPlayer(playerId)
	AddPlayerChatAll('<span color="#eeeeeeaa">' .. GetPlayerName(playerId) .. ' (' .. playerId .. ') joined the server</>')

end)

--
--
--
AddEvent("OnPlayerQuit", function(playerId)

	-- Remove player on team
	if Players[playerId] then
		if Players[playerId].role then
			local role = Players[playerId].role
			table.remove(Roles[role])
			Players[playerId].role = nil
		end
		Players[playerId] = nil	
	end

	AddPlayerChatAll('<span color="#eeeeeeaa">' .. GetPlayerName(playerId) .. ' (' .. playerId .. ') leave the server</>')

end)

--
--
--
AddEvent('OnPlayerDeath', function(playerId, instigator)

	-- Remove player on team
	if Players[playerId] and Players[playerId].role then
		local role = Players[playerId].role
		table.remove(Roles[role])
		Players[playerId].role = nil
		SetPlayerSpectate(playerId, true)
	end

end)

--
-- REMOVE-ME
--
AddCommand('kill', function(playerId)

	SetPlayerHealth(playerId, 0)

end)

--
--
--
AddEvent("OnPlayerWeaponShot", function(playerId, weapon, hittype, otherPlayerId, xB, yB, zB, xA, yA, zA, normalx, normaly, normalz)

	if otherPlayerId ~= 0 and weapon == 21 and hittype == HIT_PLAYER then
		if Players[otherPlayerId].ragdoll == false or Players[otherPlayerId].ragdoll == nil then
			Players[otherPlayerId].ragdoll = true
			local x, y, z = GetPlayerLocation(otherPlayerId) -- Tempo fix
			EquipPlayerWeaponSlot(otherPlayerId, 0) -- Tempo fix
			SetPlayerRagdoll(otherPlayerId, true)
			Delay(10000, function()
				SetPlayerRagdoll(otherPlayerId, false)
				SetPlayerLocation(otherPlayerId, x, y, z, 0.0) -- Tempo fix
				Players[otherPlayerId].ragdoll = false
			end)
		end
	elseif gameStatus == 0 and hittype == HIT_PLAYER then
		return false
	end

end)

--
--
--
AddEvent("OnPlayerDamage", function(playerId, damageType, amount)

	if damageType == 4 and amount > 60 then
		print(playerId, damagetype, amount)
		SetPlayerHealth(playerId, 0)
	end

end)