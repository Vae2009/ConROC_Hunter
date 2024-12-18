ConROC.Hunter = {};

local ConROC_Hunter, ids = ...;
local currentSpecName;
local currentSpecID;

function ConROC:EnableDefenseModule()
	self.NextDef = ConROC.Hunter.Defense;
end

function ConROC:UNIT_SPELLCAST_SUCCEEDED(event, unitID, lineID, spellID)
	if unitID == 'player' then
		self.lastSpellId = spellID;
	end

	ConROC:JustCasted(spellID);
end

function ConROC:PopulateTalentIDs()
    local numTabs = GetNumTalentTabs()

    for tabIndex = 1, numTabs do
        local tabName = GetTalentTabInfo(tabIndex)
        tabName = string.gsub(tabName, "[^%w]", "") .. "_Talent" -- Remove spaces from tab name
        print("ids."..tabName.." = {")
        local numTalents = GetNumTalents(tabIndex)

        for talentIndex = 1, numTalents do
            local name, _, _, _, _ = GetTalentInfo(tabIndex, talentIndex)

            if name then
                local talentID = string.gsub(name, "[^%w]", "") -- Remove spaces from talent name
                    print(talentID .." = ", talentIndex ..",")
            end
        end
        print("}")
    end
end

local Racial, Spec, Ability, Rank, BM_Talent, MM_Talent, Surv_Talent, Pet, Runes, Buff, Debuff = ids.Racial, ids.Spec, ids.Ability, ids.Rank, ids.BeastMastery_Talent, ids.Marksmanship_Talent, ids.Survival_Talent, ids.Pet, ids.Runes, ids.Buff, ids.Debuff;
local _AutoShot_ACTIVE = false;

function ConROC:SpecUpdate()
	currentSpecName = ConROC:currentSpec()
    currentSpecID = ConROC:currentSpec("ID")

	if currentSpecName then
	   ConROC:Print(self.Colors.Info .. "Current spec:", self.Colors.Success ..  currentSpecName)
	else
	   ConROC:Print(self.Colors.Error .. "You do not currently have a spec.")
	end
end

ConROC:SpecUpdate()

function ConROC:EnableRotationModule()
	self.Description = 'Hunter';
	self.NextSpell = ConROC.Hunter.Damage;

	self:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED');
	self:RegisterEvent("PLAYER_TALENT_UPDATE");
	self.lastSpellId = 0;
end

function ConROC:PLAYER_TALENT_UPDATE()
	ConROC:SpecUpdate();
    ConROC:closeSpellmenu();
end

--Info
local _Player_Level = UnitLevel("player");
local _Player_Percent_Health = ConROC:PercentHealth('player');
local _Pet_Percent_Health = ConROC:PercentHealth('pet');
local _is_PvP = ConROC:IsPvP();
local _in_combat = UnitAffectingCombat('player');
local _party_size = GetNumGroupMembers();
local _is_PC = UnitPlayerControlled("target");
local _is_Enemy = ConROC:TarHostile();
local _Target_Health = UnitHealth('target');
local _Target_Percent_Health = ConROC:PercentHealth('target');

--Resources
local _Mana, _Mana_Max, _Mana_Percent = ConROC:PlayerPower('Mana');

--Conditions
local _Queue = 0;
local _is_moving = ConROC:PlayerSpeed();
local _enemies_in_melee, _target_in_melee = ConROC:Targets("Melee");
local _enemies_in_10yrds, _target_in_10yrds = ConROC:Targets("10");
local _enemies_in_20yrds, _target_in_20yrds = ConROC:Targets("20");
local _enemies_in_40yrds, _target_in_40yrds = ConROC:Targets("40");
local _can_Execute = _Target_Percent_Health < 20;

--Racials
local _Berserking, _Berserking_RDY = _, _;
local _Shadowmeld, _Shadowmeld_RDY = _, _;

function ConROC:Stats()
	_Player_Level = UnitLevel("player");
	_Player_Percent_Health = ConROC:PercentHealth('player');
	_Pet_Percent_Health = ConROC:PercentHealth('pet');
	_is_PvP = ConROC:IsPvP();
	_in_combat = UnitAffectingCombat('player');
	_party_size = GetNumGroupMembers();
	_is_PC = UnitPlayerControlled("target");
	_is_Enemy = ConROC:TarHostile();
	_Target_Health = UnitHealth('target');
	_Target_Percent_Health = ConROC:PercentHealth('target');

	_Mana, _Mana_Max, _Mana_Percent = ConROC:PlayerPower('Mana');

	_Queue = 0;
	_is_moving = ConROC:PlayerSpeed();
	_enemies_in_melee, _target_in_melee = ConROC:Targets("Melee");
	_enemies_in_10yrds, _target_in_10yrds = ConROC:Targets("10");
	_enemies_in_20yrds, _target_in_20yrds = ConROC:Targets("20");
	_enemies_in_40yrds, _target_in_40yrds = ConROC:Targets("40");
	_can_Execute = _Target_Percent_Health < 20;

	_Berserking, _Berserking_RDY = ConROC:AbilityReady(Racial.Berserking, timeShift);
	_Shadowmeld, _Shadowmeld_RDY = ConROC:AbilityReady(Racial.Shadowmeld, timeShift);
end

function ConROC.Hunter.Damage(_, timeShift, currentSpell, gcd)
	ConROC:UpdateSpellID();
	ConROC:Stats();

--Abilities
	local _BestialWrath, _BestialWrath_RDY = ConROC:AbilityReady(Ability.BestialWrath, timeShift);
	local _Intimidation, _Intimidation_RDY = ConROC:AbilityReady(Ability.Intimidation, timeShift);

	local _AimedShot, _AimedShot_RDY = ConROC:AbilityReady(Ability.AimedShot, timeShift);
	local _ArcaneShot, _ArcaneShot_RDY = ConROC:AbilityReady(Ability.ArcaneShot, timeShift);
	local _AutoShot, _AutoShot_RDY = ConROC:AbilityReady(Ability.AutoShot, timeShift);
	local _ConcussiveShot, _ConcussiveShot_RDY = ConROC:AbilityReady(Ability.ConcussiveShot, timeShift);
	local _HuntersMark, _HuntersMark_RDY = ConROC:AbilityReady(Ability.HuntersMark, timeShift);
		local _, _, _, _HuntersMark_UP = ConROC:TargetAura(_HuntersMark);
	local _MultiShot, _MultiShot_RDY = ConROC:AbilityReady(Ability.MultiShot, timeShift);
	local _RapidFire, _RapidFire_RDY = ConROC:AbilityReady(Ability.RapidFire, timeShift);
		local _RapidFire_BUFF = ConROC:Aura(_RapidFire);
	local _ScatterShot, _ScatterShot_RDY = ConROC:AbilityReady(Ability.ScatterShot, timeShift);
	local _ScorpidSting, _ScorpidSting_RDY = ConROC:AbilityReady(Ability.ScorpidSting, timeShift);
	local _SerpentSting, _SerpentSting_RDY = ConROC:AbilityReady(Ability.SerpentSting, timeShift);
	local _TrueshotAura, _TrueshotAura_RDY = ConROC:AbilityReady(Ability.TrueshotAura, timeShift);
		local _TrueshotAura_BUFF = ConROC:Aura(_TrueshotAura);
	local _ViperSting, _ViperSting_RDY = ConROC:AbilityReady(Ability.ViperSting, timeShift);
	local _Volley, _Volley_RDY = ConROC:AbilityReady(Ability.Volley, timeShift);

	local _Counterattack, _Counterattack_RDY = ConROC:AbilityReady(Ability.Counterattack, timeShift);
	local _ExplosiveTrap, _ExplosiveTrap_RDY = ConROC:AbilityReady(Ability.ExplosiveTrap, timeShift);
	local _ImmolationTrap, _ImmolationTrap_RDY = ConROC:AbilityReady(Ability.ImmolationTrap, timeShift);
	local _FreezingTrap, _FreezingTrap_RDY = ConROC:AbilityReady(Ability.FreezingTrap, timeShift);
	local _FrostTrap, _FrostTrap_RDY = ConROC:AbilityReady(Ability.FrostTrap, timeShift);
	local _MongooseBite, _MongooseBite_RDY = ConROC:AbilityReady(Ability.MongooseBite, timeShift);
	local _RaptorStrike, _RaptorStrike_RDY	= ConROC:AbilityReady(Ability.RaptorStrike, timeShift);
	local _WingClip, _WingClip_RDY = ConROC:AbilityReady(Ability.WingClip, timeShift);
		local _WingClip_DEBUFF = ConROC:TargetAura(_WingClip, timeShift);
	local _WyvernSting, _WyvernSting_RDY = ConROC:AbilityReady(Ability.WyvernSting, timeShift);
		local _WyvernSting_DEBUFF = ConROC:TargetAura(_WyvernSting);

	local _AspectoftheHawk, _AspectoftheHawk_RDY = ConROC:AbilityReady(Ability.AspectoftheHawk, timeShift);
		local _AspectoftheHawk_FORM = ConROC:Form(_AspectoftheHawk);
	local _AspectoftheCheetah, _AspectoftheCheetah_RDY = ConROC:AbilityReady(Ability.AspectoftheCheetah, timeShift);
		local _AspectoftheCheetah_FORM = ConROC:Form(_AspectoftheCheetah);
	local _AspectofthePack, _AspectofthePack_RDY = ConROC:AbilityReady(Ability.AspectofthePack, timeShift);
		local _AspectofthePack_FORM = ConROC:Form(_AspectofthePack);

--Runes
	local _HeartoftheLion, _HeartoftheLion_RDY = ConROC:AbilityReady(Runes.HeartoftheLion, timeShift);
		local _HeartoftheLion_BUFF = ConROC:Form(_HeartoftheLion);
	local _Carve, _Carve_RDY = ConROC:AbilityReady(Runes.Carve, timeShift);
	local _ChimeraShot, _ChimeraShot_RDY = ConROC:AbilityReady(Runes.ChimeraShot, timeShift);
	local _ExplosiveShot, _ExplosiveShot_RDY = ConROC:AbilityReady(Runes.ExplosiveShot, timeShift);
		local _ExplosiveShot_DEBUFF = ConROC:TargetAura(_ExplosiveShot, timeShift);
	local _FlankingStrike, _FlankingStrike_RDY = ConROC:AbilityReady(Runes.FlankingStrike, timeShift);
		local _FlankingStrike_BUFF, _FlankingStrike_COUNT = ConROC:Aura(_FlankingStrike, timeShift);
	local _KillCommand, _KillCommand_RDY = ConROC:AbilityReady(Runes.KillCommand, timeShift);
	local _KillShot, _KillShot_RDY = ConROC:AbilityReady(Runes.KillShot, timeShift);

--Conditions
	local _Pet_summoned = ConROC:CallPet();
	local _Pet_assist = ConROC:PetAssist();
	local _in_shot_range = ConROC:IsSpellInRange(_AutoShot, 'target');
	--local cPetRDY = GetCallPetSpellInfo();
	local tarHasMana = UnitPower('target', Enum.PowerType.Mana);

    local stingDEBUFF = {
		scStingDEBUFF = ConROC:TargetAura(_ScorpidSting);
        sStingDEBUFF = ConROC:TargetAura(_SerpentSting);
		vStingDEBUFF = ConROC:TargetAura(_ViperSting);
    }

	local stingUp = false;
		for k, v in pairs(stingDEBUFF) do
			if v then
				stingUp = true;
				break
			end
		end

--Indicators
	ConROC:AbilityRaidBuffs(_AspectoftheHawk, _AspectoftheHawk_RDY and not _AspectoftheHawk_FORM and not _target_in_melee);
	ConROC:AbilityBurst(_BestialWrath, not ConROC:CheckBox(ConROC_SM_Ability_BestialWrath) and _BestialWrath_RDY and _in_combat and _Pet_summoned);
	ConROC:AbilityBurst(_RapidFire, not ConROC:CheckBox(ConROC_SM_Ability_RapidFire) and _RapidFire_RDY and _in_combat);
	ConROC:AbilityMovement(_AspectoftheCheetah, _AspectoftheCheetah_RDY and not _AspectoftheCheetah_FORM and not _in_combat);

	ConROC:AbilityRaidBuffs(_TrueshotAura, _TrueshotAura_RDY and not _TrueshotAura_BUFF);

--Warnings
--[[	if cPetRDY and not _Pet_summoned and _in_combat then
		ConROC:Warnings("Call your pet!!!", true);
	end]]

--Rotations
	if ConROC.Seasons.IsSoD then
		if _HeartoftheLion_RDY and not _HeartoftheLion_BUFF then
			return _HeartoftheLion
		end

		if _KillCommand_RDY and _Pet_summoned then
			return _KillCommand
		end

		if not _Pet_assist and _Pet_summoned and _in_combat then
			ConROC:Warnings("Pet is NOT attacking!!!", true);
		end

		if _KillShot_RDY and _Target_Percent_Health < 20 then
			return _KillShot
		end

		if _in_shot_range then
			if ConROC:CheckBox(ConROC_SM_Role_Melee) then
				if ConROC:CheckBox(ConROC_SM_Option_AutoShot) and _AutoShot_RDY and not _AutoShot_ACTIVE then
					return _AutoShot;
				end

				if ConROC_AoEButton:IsVisible() and _MultiShot_RDY then
					return _MultiShot
				end

				if ConROC:CheckBox(ConROC_SM_Sting_Serpent) and _SerpentSting_RDY and not stingUp and ConROC.lastSpellId ~= _SerpentSting and not ConROC:CreatureType("Mechanical") and not ConROC:CreatureType("Elemental") then
					return _SerpentSting;
				end
			end

			if ConROC:CheckBox(ConROC_SM_Ability_HuntersMark) and _HuntersMark_RDY and not _HuntersMark_UP and not _target_in_melee then
				return _HuntersMark;
			end

			if ConROC:CheckBox(ConROC_SM_Sting_Viper) and _ViperSting_RDY and not stingUp and tarHasMana > 0 and ConROC.lastSpellId ~= _ViperSting and not ConROC:CreatureType("Mechanical") and not ConROC:CreatureType("Elemental") then
				return _ViperSting;
			end

			if ConROC:CheckBox(ConROC_SM_Sting_Serpent) and _SerpentSting_RDY and not stingUp and ConROC.lastSpellId ~= _SerpentSting and not ConROC:CreatureType("Mechanical") and not ConROC:CreatureType("Elemental") then
				return _SerpentSting;
			end

			if ConROC:CheckBox(ConROC_SM_Sting_Scorpid) and _ScorpidSting_RDY and not stingUp and ConROC.lastSpellId ~= _ScorpidSting and not ConROC:CreatureType("Mechanical") and not ConROC:CreatureType("Elemental") then
				return _ScorpidSting;
			end

			if ConROC:CheckBox(ConROC_SM_Ability_AimedShot) and _AimedShot_RDY and currentSpell ~= _AimedShot then
				return _AimedShot;
			end

			if (ConROC_AoEButton:IsVisible() and ConROC:CheckBox(ConROC_SM_Ability_MultiShot)) and _MultiShot_RDY then
				return _MultiShot;
			end

			if _ArcaneShot_RDY and currentSpell ~= _AimedShot and ((_Mana_Percent >= 50) or _is_moving or ((_Target_Percent_Health <= 5 and ConROC:Raidmob()) or (_Target_Percent_Health <= 20 and not ConROC:Raidmob()))) then
				return _ArcaneShot;
			end

			if ConROC:CheckBox(ConROC_SM_Option_AutoShot) and _AutoShot_RDY and not _AutoShot_ACTIVE then
				return _AutoShot;
			end
		end

		if _target_in_melee then
			_AutoShot_ACTIVE = false;
			if _FlankingStrike_RDY then
				return _FlankingStrike;
			end

			if _RaptorStrike_RDY then
				return _RaptorStrike
			end

			if _Counterattack_RDY then
				return _Counterattack;
			end

			if _MongooseBite_RDY then
				return _MongooseBite;
			end

			if _Carve_RDY then
				return _Carve;
			end

			if ConROC:CheckBox(ConROC_SM_Stun_WingClip) and _WingClip_RDY and not _WingClip_DEBUFF then
				return _WingClip;
			end

			if _RaptorStrike_RDY then
				return _RaptorStrike;
			end
		end
	return nil
	end
	--not SoD
	if ConROC:CheckBox(ConROC_SM_Ability_HuntersMark) and _HuntersMark_RDY and not _HuntersMark_UP and not _target_in_melee then
		return _HuntersMark;
	end

	if ConROC:CheckBox(ConROC_SM_Stun_Intimidation) and _Intimidation_RDY and _Pet_summoned and ConROC:TarYou() then
		return _Intimidation;
	end

	if ConROC:CheckBox(ConROC_SM_Stun_ScatterShot) and _ScatterShot_RDY and ConROC:IsSpellInRange(_ScatterShot, 'target') and ConROC:TarYou() then
		return _ScatterShot;
	end

	if _in_shot_range then
		if ConROC:CheckBox(ConROC_SM_Stun_ConcussiveShot) and _ConcussiveShot_RDY and ConROC:TarYou() then
			return _ConcussiveShot;
		end

		if ConROC:CheckBox(ConROC_SM_Ability_AimedShot) and _AimedShot_RDY and currentSpell ~= _AimedShot then
			return _AimedShot;
		end

		if ConROC:CheckBox(ConROC_SM_Sting_Viper) and _ViperSting_RDY and not stingUp and tarHasMana > 0 and ConROC.lastSpellId ~= _ViperSting and not ConROC:CreatureType("Mechanical") and not ConROC:CreatureType("Elemental") then
			return _ViperSting;
		end

		if ConROC:CheckBox(ConROC_SM_Sting_Serpent) and _SerpentSting_RDY and not stingUp and ConROC.lastSpellId ~= _SerpentSting and not ConROC:CreatureType("Mechanical") and not ConROC:CreatureType("Elemental") then
			return _SerpentSting;
		end

		if ConROC:CheckBox(ConROC_SM_Sting_Scorpid) and _ScorpidSting_RDY and not stingUp and ConROC.lastSpellId ~= _ScorpidSting and not ConROC:CreatureType("Mechanical") and not ConROC:CreatureType("Elemental") then
			return _ScorpidSting;
		end

		if ConROC:CheckBox(ConROC_SM_Ability_BestialWrath) and _BestialWrath_RDY and _in_combat and _Pet_summoned then
			return _BestialWrath;
		end

		if ConROC:CheckBox(ConROC_SM_Ability_RapidFire) and _RapidFire_RDY and _in_combat then
			return _RapidFire;
		end

		if (ConROC_AoEButton:IsVisible() and ConROC:CheckBox(ConROC_SM_Ability_MultiShot)) and _MultiShot_RDY then
			return _MultiShot;
		end

		if ConROC_AoEButton:IsVisible() and _Volley_RDY then
			return _Volley;
		end

		if _ArcaneShot_RDY and currentSpell ~= _AimedShot and ((_Mana_Percent >= 50) or _is_moving or (_Target_Percent_Health <= 5 and ConROC:Raidmob()) or (_Target_Percent_Health <= 20 and not ConROC:Raidmob())) then
			return _ArcaneShot;
		end

		if ConROC:CheckBox(ConROC_SM_Option_AutoShot) and _AutoShot_RDY and not _AutoShot_ACTIVE then
			return _AutoShot;
		end
	end

	if _target_in_melee then
		_AutoShot_ACTIVE = false;
		if _Counterattack_RDY then
			return _Counterattack;
		end

		if _MongooseBite_RDY then
			return _MongooseBite;
		end

		if ConROC:CheckBox(ConROC_SM_Stun_WingClip) and _WingClip_RDY and not _WingClip_DEBUFF then
			return _WingClip;
		end

		if _RaptorStrike_RDY then
			return _RaptorStrike;
		end
	end
return nil;
end

function ConROC.Hunter.Defense(_, timeShift, currentSpell, gcd)
	ConROC:UpdateSpellID();
	ConROC:Stats();

--Abilities
	local _FeedPet, _FeedPet_RDY = ConROC:AbilityReady(Ability.FeedPet, timeShift);
	local _MendPet, _MendPet_RDY = ConROC:AbilityReady(Ability.MendPet, timeShift);

	local _DistractingShot, _DistractingShot_RDY = ConROC:AbilityReady(Ability.DistractingShot, timeShift);

	local _Deterrence, _Deterrence_RDY = ConROC:AbilityReady(Ability.Deterrence, timeShift);
	local _Disengage, _Disengage_RDY = ConROC:AbilityReady(Ability.Disengage, timeShift);
	local _FeignDeath, _FeignDeath_RDY = ConROC:AbilityReady(Ability.FeignDeath, timeShift);

	local _AspectoftheMonkey, _AspectoftheMonkey_RDY = ConROC:AbilityReady(Ability.AspectoftheMonkey, timeShift);
		local _AspectoftheMonkey_FORM = ConROC:Form(_AspectoftheMonkey);
	local _AspectoftheWild, _AspectoftheWild_RDY = ConROC:AbilityReady(Ability.AspectoftheWild, timeShift);
		local _AspectoftheWild_FORM = ConROC:Form(_AspectoftheWild);

--Conditions	
	local _Pet_summoned = ConROC:CallPet();
	local _, _target_in_melee = ConROC:IsMeleeRange();
	local _Pet_Happiness = GetPetHappiness();

	if _Pet_Happiness == nil then
		_Pet_Happiness = 0;
	end

--Indicators
	ConROC:AbilityRaidBuffs(_FeedPet, _FeedPet_RDY and _Pet_summoned and not _in_combat and _Pet_Happiness < 3);

--Rotations	
	if _Disengage_RDY and _target_in_melee and ConROC:TarYou() then
		return _Disengage;
	end

	if _AspectoftheMonkey_RDY and not _AspectoftheMonkey_FORM and _target_in_melee and ConROC:TarYou() then
		return _AspectoftheMonkey;
	end

	if _Deterrence_RDY and _Player_Percent_Health <= 30 and ConROC:TarYou() then
		return _Deterrence;
	end

	if _FeignDeath_RDY and _Player_Percent_Health <= 30 and ConROC:TarYou() then
		return _FeignDeath;
	end

	if _MendPet_RDY and _Pet_summoned and _Pet_Percent_Health <= 40 then
		return _MendPet;
	end
return nil;
end

function ConROC:JustCasted(spellID)
    if spellID == (ids.Ability.AutoShot or ids.Ability.SerpentSting) then
        _AutoShot_ACTIVE = true;
	else
        _AutoShot_ACTIVE = false;
    end
end