--[[
Dota Archers game mode
]]

print( "Dota Archers game mode loaded." )

if DotaArchers == nil then
	DotaArchers = class({})
end

-- Precache resources
function Precache( context )
	--PrecacheResource( "particle", "particles/generic_gameplay/winter_effects_hero.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf", context )	
	PrecacheResource( "particle", "particles/units/heroes/hero_tinker/tinker_rockets_arrow.vpcf", context )	
	
end

--------------------------------------------------------------------------------
-- ACTIVATE
--------------------------------------------------------------------------------
function Activate()
    GameRules.DotaArchers = DotaArchers()
    GameRules.DotaArchers:InitGameMode()
end

--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------
function DotaArchers:InitGameMode()
	local GameMode = GameRules:GetGameModeEntity()
	self._nRadiantKills = 0
	self._nDireKills = 0
	
	-- Enable the standard Dota PvP game rules
	GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled( false )
	GameRules:SetHeroSelectionTime( 30.0 )
	GameRules:SetPreGameTime( 0.0 )
	GameRules:SetPostGameTime( 60.0 )
	GameRules:SetTreeRegrowTime( 60.0 )
	GameRules:SetHeroMinimapIconSize( 500 )
	GameRules:SetCreepMinimapIconScale( 0.7 )
	GameRules:SetRuneMinimapIconScale( 1.5 )
	GameRules:SetUseUniversalShopMode( true )
	
	-- Register Think
	GameMode:SetContextThink( "DotaArchers:GameThink", function() return self:GameThink() end, 0.25 )
	--GameMode:SetContextThink( "DotaArchers:GameThinkFive", function() return self:GameThinkFive() end, 5.0 )
	--GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )			THIS IS A WIN ENDS THE GAME
	
	-- Hook into game events allowing reload of functions at run time
	ListenToGameEvent( "last_hit", Dynamic_Wrap( DotaArchers, "OnLastHit" ), self )
	ListenToGameEvent( "game_message", Dynamic_Wrap( DotaArchers, "game_message" ), self )
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( DotaArchers, "OnGameRulesStateChange" ), self )
	-- Custom console commands
	Convars:RegisterCommand( "archer_radkill", function(...) return self:_TestRadiantGainKill( ... ) end, "+1 Radiant Kill", FCVAR_CHEAT )
	
	-- Register Game Events
end

--------------------------------------------------------------------------------
function DotaArchers:GameThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self:_CheckForVictory()		--Checking if frag limit is reached
	
	end
	return 0.25
end

----------------------
function DotaArchers:GameThinkFive()
	print(string.format("Radiant kills: %d", self._nRadiantKills))
	print(string.format("Dire kills: %d", self._nDireKills))
	
	return 5.0
end

-- CHECKS IF THE VICTORY CONDITION IS TRUE
function DotaArchers:_CheckForVictory()
	--print("Checking for victor")

	if self._nRadiantKills >= 20 then
		GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
	else
		if self._nDireKills >= 20 then
			GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )	
		end

	end
end
	
--function DotaArchers:_LevelPlayers()
--	print("LevelingUpHeroes")
--	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
--	if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
--			if PlayerResource:HasSelectedHero( nPlayerID ) then
--				local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
--				if not hero:IsAlive() then
--					hero:RespawnUnit()
--				end
--				hero:SetLevel( 2 )
--			end
--		end
--	end
--end
	
	
-------------------- EVENT FUNCTIONS	
-- Event, On a player kill
function DotaArchers:OnLastHit(event)
	print ("A LAST HIT HAS HAPPENED")
	local killer = event.PlayerID
	local deadEnt = event.EntKilled
	local wasHeroKill = event.HeroKill
	
	if wasHeroKill >= 1 then
		if PlayerResource:GetTeam( killer )	== DOTA_TEAM_GOODGUYS then
			print ("Radiant score a last hit")
			self._nRadiantKills = self._nRadiantKills + 1
		elseif PlayerResource:GetTeam( killer )	== DOTA_TEAM_BADGUYS then
			print ("Dire score a last hit")
			self._nDireKills = self._nDireKills + 1
		end
	end

end

--When the game state changes
function DotaArchers:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		-- Welcome popup
		ShowGenericPopup( "#archer_instructions_title", "#archer_instructions_body", "", "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN )
	end
	if nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print("StateChanged")
		--self:_LevelPlayers()
	end
end
	
-- DEBUG COMMAND TO GIVE PLUS ONE KILL TO RADIANT
function DotaArchers:_TestRadiantGainKill()
	print("Giving Radiant + 1 Kill")
	--self._nRadiantKills = self._nRadiantKills + 1
	self:_LevelPlayers()
end

