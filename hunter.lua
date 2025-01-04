ConROC.Hunter = {};

local ConROC_Hunter, ids = ...;

function ConROC:EnableRotationModule()
	self.Description = 'Hunter';
	self.NextSpell = ConROC.Hunter.Damage;

	self:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED');
	self.lastSpellId = 0;

	if ConROCSpellmenuClass == nil then
		ConROC:SpellmenuClass();
	end
end

function ConROC:EnableDefenseModule()
	self.NextDef = ConROC.Hunter.Defense;
end

function ConROC:UNIT_SPELLCAST_SUCCEEDED(event, unitID, lineID, spellID)
	if unitID == 'player' then
		self.lastSpellId = spellID;
	end

	ConROC:JustCasted(spellID);
end

local Racial, Spec, Ability, Rank, BM_Talent, MM_Talent, Surv_Talent, Pet, Engrave, Runes, Buff, Debuff = ids.Racial, ids.Spec, ids.Ability, ids.Rank, ids.BeastMastery_Talent, ids.Marksmanship_Talent, ids.Survival_Talent, ids.Pet, ids.Engrave, ids.Runes, ids.Buff, ids.Debuff;
local _AutoShot_ACTIVE = false;

local _AutoAttack, _AutoAttack_RDY = ConROC:AbilityReady(6603, timeShift);
local _AutoShot, _AutoShot_RDY = ConROC:AbilityReady(75, timeShift);

--Info
local _Player_Spec, _Player_Spec_ID = ConROC:currentSpec();
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
	_AutoAttack, _AutoAttack_RDY = ConROC:AbilityReady(6603, timeShift);
	_AutoShot, _AutoShot_RDY = ConROC:AbilityReady(75, timeShift);

	_Player_Spec, _Player_Spec_ID = ConROC:currentSpec();
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
	wipe(ConROC.SuggestedSpells);
	ConROC:Stats();

--Abilities
	local _BestialWrath, _BestialWrath_RDY = ConROC:AbilityReady(Ability.BestialWrath, timeShift);
	local _, _CallPet_RDY = ConROC:AbilityReady(Ability.CallPet, timeShift);
	local _Intimidation, _Intimidation_RDY = ConROC:AbilityReady(Ability.Intimidation, timeShift);

	local _AimedShot, _AimedShot_RDY = ConROC:AbilityReady(Ability.AimedShot, timeShift);
	local _ArcaneShot, _ArcaneShot_RDY = ConROC:AbilityReady(Ability.ArcaneShot, timeShift);
	local _ConcussiveShot, _ConcussiveShot_RDY = ConROC:AbilityReady(Ability.ConcussiveShot, timeShift);
	local _HuntersMark, _HuntersMark_RDY = ConROC:AbilityReady(Ability.HuntersMark, timeShift);
		local _HuntersMark_BUFF = ConROC:TargetAura(_HuntersMark, timeShift);
	local _MultiShot, _MultiShot_RDY = ConROC:AbilityReady(Ability.MultiShot, timeShift);
	local _RapidFire, _RapidFire_RDY = ConROC:AbilityReady(Ability.RapidFire, timeShift);
		local _RapidFire_BUFF = ConROC:Aura(_RapidFire, timeShift);
	local _ScatterShot, _ScatterShot_RDY = ConROC:AbilityReady(Ability.ScatterShot, timeShift);
	local _ScorpidSting, _ScorpidSting_RDY = ConROC:AbilityReady(Ability.ScorpidSting, timeShift);
		local _ScorpidSting_DEBUFF, _, _ScorpidSting_DUR = ConROC:TargetAura(_ScorpidSting, timeShift);
	local _SerpentSting, _SerpentSting_RDY = ConROC:AbilityReady(Ability.SerpentSting, timeShift);
		local _SerpentSting_DEBUFF, _, _SerpentSting_DUR = ConROC:TargetAura(_SerpentSting, timeShift);
	local _TrueshotAura, _TrueshotAura_RDY = ConROC:AbilityReady(Ability.TrueshotAura, timeShift);
		local _TrueshotAura_BUFF = ConROC:Aura(_TrueshotAura, timeShift);
	local _ViperSting, _ViperSting_RDY = ConROC:AbilityReady(Ability.ViperSting, timeShift);
		local _ViperSting_DEBUFF, _, _ViperSting_DUR = ConROC:TargetAura(_ViperSting, timeShift);
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
		local _WyvernSting_DEBUFF = ConROC:TargetAura(_WyvernSting, timeShift);

	local _AspectoftheHawk, _AspectoftheHawk_RDY = ConROC:AbilityReady(Ability.AspectoftheHawk, timeShift);
		local _AspectoftheHawk_FORM = ConROC:Form(_AspectoftheHawk);
	local _AspectoftheFalcon, _AspectoftheFalcon_RDY = ConROC:AbilityReady(Runes.AspectoftheFalcon, timeShift);
		local _AspectoftheFalcon_FORM = ConROC:Form(_AspectoftheFalcon);
	local _AspectoftheCheetah, _AspectoftheCheetah_RDY = ConROC:AbilityReady(Ability.AspectoftheCheetah, timeShift);
		local _AspectoftheCheetah_FORM = ConROC:Form(_AspectoftheCheetah);
	local _AspectoftheMonkey, _AspectoftheMonkey_RDY = ConROC:AbilityReady(Ability.AspectoftheMonkey, timeShift);
		local _AspectoftheMonkey_FORM = ConROC:Form(_AspectoftheMonkey);
	local _AspectofthePack, _AspectofthePack_RDY = ConROC:AbilityReady(Ability.AspectofthePack, timeShift);
		local _AspectofthePack_FORM = ConROC:Form(_AspectofthePack);
	local _AspectoftheViper, _AspectoftheViper_RDY = ConROC:AbilityReady(Ability.AspectoftheViper, timeShift);
		local _AspectoftheViper_FORM = ConROC:Form(_AspectoftheViper);
	local _AspectoftheWild, _AspectoftheWild_RDY = ConROC:AbilityReady(Ability.AspectoftheWild, timeShift);
		local _AspectoftheWild_FORM = ConROC:Form(_AspectoftheWild);

--Runes
	local _Carve, _Carve_RDY = ConROC:AbilityReady(Runes.Carve, timeShift);
	local _ChimeraShot, _ChimeraShot_RDY = ConROC:AbilityReady(Runes.ChimeraShot, timeShift);
	local _ExplosiveShot, _ExplosiveShot_RDY = ConROC:AbilityReady(Runes.ExplosiveShot, timeShift);
		local _ExplosiveShot_DEBUFF = ConROC:TargetAura(_ExplosiveShot, timeShift);
	local _FlankingStrike, _FlankingStrike_RDY = ConROC:AbilityReady(Runes.FlankingStrike, timeShift);
		local _FlankingStrike_BUFF, _FlankingStrike_COUNT, _FlankingStrike_DUR = ConROC:Aura(_FlankingStrike, timeShift);
	local _HeartoftheLion, _HeartoftheLion_RDY = ConROC:AbilityReady(Runes.HeartoftheLion, timeShift);
		local _HeartoftheLion_FORM = ConROC:Form(_HeartoftheLion);
	local _KillCommand, _KillCommand_RDY = ConROC:AbilityReady(Runes.KillCommand, timeShift);
	local _KillShot, _KillShot_RDY = ConROC:AbilityReady(Runes.KillShot, timeShift);
	local _, _LoneWolf_PASSIVE = ConROC:AbilityReady(Runes.LoneWolf, timeShift);
		local _LockandLoad_BUFF = ConROC:Aura(Buff.LockandLoad, timeShift);
	local _WyvernStrike, _WyvernStrike_RDY = ConROC:AbilityReady(Runes.WyvernStrike, timeShift);

--Conditions
	local _Pet_summoned = ConROC:CallPet();
	local _Pet_assist = ConROC:PetAssist();
	local tarHasMana = UnitPower('target', Enum.PowerType.Mana);
	local _Sting_UP = _ScorpidSting_DEBUFF or _SerpentSting_DEBUFF or _ViperSting_DEBUFF;

	if _target_in_melee then
		_AutoShot_ACTIVE = false;
	end

--Indicators
	ConROC:AbilityRaidBuffs(_AspectoftheFalcon, ConROC:CheckBox(ConROC_SM_Aspect_AspectoftheFalcon) and _AspectoftheFalcon_RDY and not _AspectoftheFalcon_FORM);
	ConROC:AbilityRaidBuffs(_AspectoftheHawk, ConROC:CheckBox(ConROC_SM_Aspect_AspectoftheHawk) and _AspectoftheHawk_RDY and not _AspectoftheHawk_FORM);
	ConROC:AbilityRaidBuffs(_AspectoftheMonkey, ConROC:CheckBox(ConROC_SM_Aspect_AspectoftheMonkey) and _AspectoftheMonkey_RDY and not _AspectoftheMonkey_FORM);
	ConROC:AbilityRaidBuffs(_AspectoftheViper, ConROC:CheckBox(ConROC_SM_Aspect_AspectoftheViper) and _AspectoftheViper_RDY and not _AspectoftheViper_FORM);
	ConROC:AbilityRaidBuffs(_AspectoftheWild, ConROC:CheckBox(ConROC_SM_Aspect_AspectoftheWild) and _AspectoftheWild_RDY and not _AspectoftheWild_FORM);
	ConROC:AbilityBurst(_BestialWrath, not ConROC:CheckBox(ConROC_SM_Ability_BestialWrath) and _BestialWrath_RDY and _in_combat and _Pet_summoned);
	ConROC:AbilityBurst(_RapidFire, not ConROC:CheckBox(ConROC_SM_Ability_RapidFire) and _RapidFire_RDY and _in_combat);
	ConROC:AbilityMovement(_AspectoftheCheetah, _AspectoftheCheetah_RDY and not _AspectoftheCheetah_FORM and not _in_combat);

	ConROC:AbilityRaidBuffs(_TrueshotAura, _TrueshotAura_RDY and not _TrueshotAura_BUFF);

--Warnings
	--ConROC:Warnings("Call your pet!", _CallPet_RDY and not _Pet_summoned and _in_combat and not _LoneWolf_PASSIVE);
	ConROC:Warnings("Pet is NOT attacking!!!", not _Pet_assist and _Pet_summoned and _in_combat);

--Rotations
	repeat
		while(true) do
			if ConROC.Seasons.IsSoD then
				if ConROC:CheckBox(ConROC_SM_Ability_HeartoftheLion) and _HeartoftheLion_RDY and not _HeartoftheLion_FORM then
					tinsert(ConROC.SuggestedSpells, _HeartoftheLion);
					_HeartoftheLion_FORM = true;
					_Queue = _Queue + 1;
					break;
				end

				if _target_in_melee then
					_AutoShot_ACTIVE = false;
					if ConROC:CheckBox(ConROC_SM_Ability_FlankingStrike) and _FlankingStrike_RDY and _FlankingStrike_DUR <= 3 then
						tinsert(ConROC.SuggestedSpells, _FlankingStrike);
						_FlankingStrike_RDY = false;
						_FlankingStrike_DUR = 10;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Ability_RaptorStrike) and _RaptorStrike_RDY then
						tinsert(ConROC.SuggestedSpells, _RaptorStrike);
						_RaptorStrike_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Ability_WyvernStrike) and _WyvernStrike_RDY then
						tinsert(ConROC.SuggestedSpells, _WyvernStrike);
						_WyvernStrike_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Ability_Counterattack) and _Counterattack_RDY then
						tinsert(ConROC.SuggestedSpells, _Counterattack);
						_Counterattack_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Ability_MongooseBite) and _MongooseBite_RDY then
						tinsert(ConROC.SuggestedSpells, _MongooseBite);
						_MongooseBite_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Ability_KillShot) and _KillShot_RDY then
						tinsert(ConROC.SuggestedSpells, _KillShot);
						_KillShot_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Ability_FlankingStrike) and _FlankingStrike_RDY then
						tinsert(ConROC.SuggestedSpells, _FlankingStrike);
						_FlankingStrike_RDY = false;
						_FlankingStrike_DUR = 10;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Ability_Carve) and _Carve_RDY then
						tinsert(ConROC.SuggestedSpells, _Carve);
						_Carve_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Fire_ImmolationTrap) and ConROC:RuneEquipped(Engrave.LockandLoad, "head") and _ImmolationTrap_RDY and not _LockandLoad_BUFF then
						tinsert(ConROC.SuggestedSpells, _ImmolationTrap);
						_ImmolationTrap_RDY = false;
						_LockandLoad_BUFF = true;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Fire_ExplosiveTrap) and ConROC:RuneEquipped(Engrave.LockandLoad, "head") and _ExplosiveTrap_RDY and not _LockandLoad_BUFF then
						tinsert(ConROC.SuggestedSpells, _ExplosiveTrap);
						_ExplosiveTrap_RDY = false;
						_LockandLoad_BUFF = true;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Stun_Intimidation) and _Intimidation_RDY and _Pet_summoned and ConROC:TarYou() then
						tinsert(ConROC.SuggestedSpells, _Intimidation);
						_Intimidation_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Stun_ScatterShot) and _ScatterShot_RDY and ConROC:IsSpellInRange(_ScatterShot, 'target') and ConROC:TarYou() then
						tinsert(ConROC.SuggestedSpells, _ScatterShot);
						_ScatterShot_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Stun_WingClip) and _WingClip_RDY and not _WingClip_DEBUFF then
						tinsert(ConROC.SuggestedSpells, _WingClip);
						_WingClip_DEBUFF = true;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Option_WingClip) and _WingClip_RDY and ConROC:HasWindfury() then
						tinsert(ConROC.SuggestedSpells, _WingClip);
						_WingClip_DEBUFF = true;
						_Queue = _Queue + 1;
						break;
					end

					tinsert(ConROC.SuggestedSpells, _AutoAttack); --Waiting Spell Icon
					_Queue = _Queue + 3;
					break;
				else
					if ConROC:CheckBox(ConROC_SM_Role_Melee) then
						if ConROC:CheckBox(ConROC_SM_Option_AutoShot) and _AutoShot_RDY and not _AutoShot_ACTIVE then
							tinsert(ConROC.SuggestedSpells, _AutoShot);
							_AutoShot_ACTIVE = true;
							_Queue = _Queue + 1;
							break;
						end

						if (ConROC_AoEButton:IsVisible() and ConROC:CheckBox(ConROC_SM_Ability_MultiShot)) and _MultiShot_RDY then
							tinsert(ConROC.SuggestedSpells, _MultiShot);
							_MultiShot_RDY = false;
							_Queue = _Queue + 1;
							break;
						end

						if ConROC:CheckBox(ConROC_SM_Sting_Serpent) and _SerpentSting_RDY and not _Sting_UP and ConROC.lastSpellId ~= _SerpentSting and not ConROC:CreatureType("Mechanical") and not ConROC:CreatureType("Elemental") then
							tinsert(ConROC.SuggestedSpells, _SerpentSting);
							_Sting_UP = true;
							_Queue = _Queue + 1;
							break;
						end

						tinsert(ConROC.SuggestedSpells, _AutoShot); --Waiting Spell Icon
						_Queue = _Queue + 3;
						break;
					else
						if not _in_combat then
							if ConROC:CheckBox(ConROC_SM_Ability_HuntersMark) and _HuntersMark_RDY and not _HuntersMark_BUFF and not _target_in_melee then
								tinsert(ConROC.SuggestedSpells, _HuntersMark);
								_HuntersMark_BUFF = true;
								_Queue = _Queue + 1;
								break;
							end

							if ConROC:CheckBox(ConROC_SM_Ability_AimedShot) and _AimedShot_RDY and currentSpell ~= _AimedShot then
								tinsert(ConROC.SuggestedSpells, _AimedShot);
								_AimedShot_RDY = false;
								_LockandLoad_BUFF = false;
								_Queue = _Queue + 1;
								break;
							end
						end

						if ConROC:CheckBox(ConROC_SM_Sting_Viper) and _ViperSting_RDY and not _Sting_UP and tarHasMana > 0 and ConROC.lastSpellId ~= _ViperSting and not ConROC:CreatureType("Mechanical") and not ConROC:CreatureType("Elemental") then
							tinsert(ConROC.SuggestedSpells, _ViperSting);
							_Sting_UP = true;
							_Queue = _Queue + 1;
							break;
						end

						if ConROC:CheckBox(ConROC_SM_Sting_Serpent) and _SerpentSting_RDY and not _Sting_UP and ConROC.lastSpellId ~= _SerpentSting and not ConROC:CreatureType("Mechanical") and not ConROC:CreatureType("Elemental") then
							tinsert(ConROC.SuggestedSpells, _SerpentSting);
							_Sting_UP = true;
							_Queue = _Queue + 1;
							break;
						end

						if ConROC:CheckBox(ConROC_SM_Sting_Scorpid) and _ScorpidSting_RDY and not _Sting_UP and ConROC.lastSpellId ~= _ScorpidSting and not ConROC:CreatureType("Mechanical") and not ConROC:CreatureType("Elemental") then
							tinsert(ConROC.SuggestedSpells, _ScorpidSting);
							_Sting_UP = true;
							_Queue = _Queue + 1;
							break;
						end

						if ConROC:CheckBox(ConROC_SM_Ability_BestialWrath) and _BestialWrath_RDY and _in_combat and _Pet_summoned then
							tinsert(ConROC.SuggestedSpells, _BestialWrath);
							_BestialWrath_RDY = false;
							_Queue = _Queue + 1;
							break;
						end

						if ConROC:CheckBox(ConROC_SM_Ability_RapidFire) and _RapidFire_RDY and _in_combat then
							tinsert(ConROC.SuggestedSpells, _RapidFire);
							_RapidFire_RDY = false;
							_Queue = _Queue + 1;
							break;
						end


						if ConROC:CheckBox(ConROC_SM_Ability_ChimeraShot) and _ChimeraShot_RDY and (_RapidFire_BUFF or ((_SerpentSting_DEBUFF and _SerpentSting_DUR <= 6) or (_ScorpidSting_DEBUFF and _ScorpidSting_DUR <= 6) or (_ViperSting_DEBUFF and _ViperSting_DUR <= 6))) then
							tinsert(ConROC.SuggestedSpells, _ChimeraShot);
							_ChimeraShot_RDY = false;
							_LockandLoad_BUFF = false;
							_SerpentSting_DUR = 15;
							_ScorpidSting_DUR = 15;
							_ViperSting_DUR = 15;
							_Queue = _Queue + 1;
							break;
						end

						if ConROC:CheckBox(ConROC_SM_Ability_KillShot) and _KillShot_RDY and _RapidFire_BUFF then
							tinsert(ConROC.SuggestedSpells, _KillShot);
							_KillShot_RDY = false;
							_Queue = _Queue + 1;
							break;
						end

						if ConROC:CheckBox(ConROC_SM_Fire_ImmolationTrap) and ConROC:RuneEquipped(Engrave.LockandLoad, "head") and _ImmolationTrap_RDY and not _LockandLoad_BUFF then
							tinsert(ConROC.SuggestedSpells, _ImmolationTrap);
							_ImmolationTrap_RDY = false;
							_LockandLoad_BUFF = true;
							_Queue = _Queue + 1;
							break;
						end

						if ConROC:CheckBox(ConROC_SM_Fire_ExplosiveTrap) and ConROC:RuneEquipped(Engrave.LockandLoad, "head") and _ExplosiveTrap_RDY and not _LockandLoad_BUFF then
							tinsert(ConROC.SuggestedSpells, _ExplosiveTrap);
							_ExplosiveTrap_RDY = false;
							_LockandLoad_BUFF = true;
							_Queue = _Queue + 1;
							break;
						end

						if ConROC:RuneEquipped(Engrave.LockandLoad, "head") and _FreezingTrap_RDY and not _LockandLoad_BUFF then
							tinsert(ConROC.SuggestedSpells, _FreezingTrap);
							_FreezingTrap_RDY = false;
							_LockandLoad_BUFF = true;
							_Queue = _Queue + 1;
							break;
						end

						if ConROC:CheckBox(ConROC_SM_Ability_ChimeraShot) and _ChimeraShot_RDY and _LockandLoad_BUFF then
							tinsert(ConROC.SuggestedSpells, _ChimeraShot);
							_LockandLoad_BUFF = false;
							_SerpentSting_DUR = 15;
							_ScorpidSting_DUR = 15;
							_ViperSting_DUR = 15;
							_Queue = _Queue + 1;
							break;
						end

						if ConROC:CheckBox(ConROC_SM_Ability_ChimeraShot) and _ChimeraShot_RDY then
							tinsert(ConROC.SuggestedSpells, _ChimeraShot);
							_ChimeraShot_RDY = false;
							_SerpentSting_DUR = 15;
							_ScorpidSting_DUR = 15;
							_ViperSting_DUR = 15;
							_Queue = _Queue + 1;
							break;
						end

						if ConROC:CheckBox(ConROC_SM_Ability_AimedShot) and _AimedShot_RDY and _LockandLoad_BUFF then
							tinsert(ConROC.SuggestedSpells, _AimedShot);
							_LockandLoad_BUFF = false;
							_SerpentSting_DUR = 15;
							_ScorpidSting_DUR = 15;
							_ViperSting_DUR = 15;
							_Queue = _Queue + 1;
							break;
						end

						if ConROC:CheckBox(ConROC_SM_Ability_KillShot) and _KillShot_RDY then
							tinsert(ConROC.SuggestedSpells, _KillShot);
							_KillShot_RDY = false;
							_Queue = _Queue + 1;
							break;
						end

						if ConROC:CheckBox(ConROC_SM_Fire_ImmolationTrap) and _ImmolationTrap_RDY then
							tinsert(ConROC.SuggestedSpells, _ImmolationTrap);
							_ImmolationTrap_RDY = false;
							_Queue = _Queue + 1;
							break;
						end

						if ConROC:CheckBox(ConROC_SM_Fire_ExplosiveTrap) and _ExplosiveTrap_RDY then
							tinsert(ConROC.SuggestedSpells, _ExplosiveTrap);
							_ExplosiveTrap_RDY = false;
							_Queue = _Queue + 1;
							break;
						end

						if ConROC:CheckBox(ConROC_SM_Ability_AimedShot) and _AimedShot_RDY and currentSpell ~= _AimedShot then
							tinsert(ConROC.SuggestedSpells, _AimedShot);
							_AimedShot_RDY = false;
							_Queue = _Queue + 1;
							break;
						end

						if (ConROC_AoEButton:IsVisible() and ConROC:CheckBox(ConROC_SM_Ability_MultiShot)) and _MultiShot_RDY then
							tinsert(ConROC.SuggestedSpells, _MultiShot);
							_MultiShot_RDY = false;
							_Queue = _Queue + 1;
							break;
						end

						if (ConROC_AoEButton:IsVisible() and ConROC:CheckBox(ConROC_SM_Ability_Volley)) and _Volley_RDY then
							tinsert(ConROC.SuggestedSpells, _Volley);
							_Volley_RDY = false;
							_Queue = _Queue + 1;
							break;
						end

						if _ArcaneShot_RDY and currentSpell ~= _AimedShot and ((_Mana_Percent >= 50) or _is_moving or ((_Target_Percent_Health <= 5 and ConROC:Raidmob()) or (_Target_Percent_Health <= 20 and not ConROC:Raidmob()))) then
							tinsert(ConROC.SuggestedSpells, _ArcaneShot);
							_ArcaneShot_RDY = false;
							_Queue = _Queue + 1;
							break;
						end

						tinsert(ConROC.SuggestedSpells, _AutoShot); --Waiting Spell Icon
						_Queue = _Queue + 3;
						break;
					end
				end
			else--not SoD
				if _target_in_melee then
					_AutoShot_ACTIVE = false;
					if ConROC:CheckBox(ConROC_SM_Ability_Counterattack) and _Counterattack_RDY then
						tinsert(ConROC.SuggestedSpells, _Counterattack);
						_Counterattack_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Ability_MongooseBite) and _MongooseBite_RDY then
						tinsert(ConROC.SuggestedSpells, _MongooseBite);
						_MongooseBite_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Stun_Intimidation) and _Intimidation_RDY and _Pet_summoned and ConROC:TarYou() then
						tinsert(ConROC.SuggestedSpells, _Intimidation);
						_Intimidation_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Stun_ScatterShot) and _ScatterShot_RDY and ConROC:IsSpellInRange(_ScatterShot, 'target') and ConROC:TarYou() then
						tinsert(ConROC.SuggestedSpells, _ScatterShot);
						_ScatterShot_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Stun_WingClip) and _WingClip_RDY and not _WingClip_DEBUFF then
						tinsert(ConROC.SuggestedSpells, _WingClip);
						_WingClip_DEBUFF = true;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Ability_RaptorStrike) and _RaptorStrike_RDY then
						tinsert(ConROC.SuggestedSpells, _RaptorStrike);
						_RaptorStrike_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					tinsert(ConROC.SuggestedSpells, _AutoAttack); --Waiting Spell Icon
					_Queue = _Queue + 3;
					break;
				else
					if ConROC:CheckBox(ConROC_SM_Ability_HuntersMark) and _HuntersMark_RDY and not _HuntersMark_BUFF then
						tinsert(ConROC.SuggestedSpells, _HuntersMark);
						_HuntersMark_BUFF = true;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Stun_ConcussiveShot) and _ConcussiveShot_RDY and ConROC:TarYou() then
						tinsert(ConROC.SuggestedSpells, _ConcussiveShot);
						_ConcussiveShot_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Ability_AimedShot) and _AimedShot_RDY and currentSpell ~= _AimedShot then
						tinsert(ConROC.SuggestedSpells, _AimedShot);
						_AimedShot_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Sting_Viper) and _ViperSting_RDY and not _Sting_UP and tarHasMana > 0 and ConROC.lastSpellId ~= _ViperSting and not ConROC:CreatureType("Mechanical") and not ConROC:CreatureType("Elemental") then
						tinsert(ConROC.SuggestedSpells, _ViperSting);
						_Sting_UP = true;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Sting_Serpent) and _SerpentSting_RDY and not _Sting_UP and ConROC.lastSpellId ~= _SerpentSting and not ConROC:CreatureType("Mechanical") and not ConROC:CreatureType("Elemental") then
						tinsert(ConROC.SuggestedSpells, _SerpentSting);
						_Sting_UP = true;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Sting_Scorpid) and _ScorpidSting_RDY and not _Sting_UP and ConROC.lastSpellId ~= _ScorpidSting and not ConROC:CreatureType("Mechanical") and not ConROC:CreatureType("Elemental") then
						tinsert(ConROC.SuggestedSpells, _ScorpidSting);
						_Sting_UP = true;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Ability_BestialWrath) and _BestialWrath_RDY and _in_combat and _Pet_summoned then
						tinsert(ConROC.SuggestedSpells, _BestialWrath);
						_BestialWrath_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					if ConROC:CheckBox(ConROC_SM_Ability_RapidFire) and _RapidFire_RDY and _in_combat then
						tinsert(ConROC.SuggestedSpells, _RapidFire);
						_RapidFire_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					if (ConROC_AoEButton:IsVisible() and ConROC:CheckBox(ConROC_SM_Ability_MultiShot)) and _MultiShot_RDY then
						tinsert(ConROC.SuggestedSpells, _MultiShot);
						_MultiShot_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					if (ConROC_AoEButton:IsVisible() and ConROC:CheckBox(ConROC_SM_Ability_Volley)) and _Volley_RDY then
						tinsert(ConROC.SuggestedSpells, _Volley);
						_Volley_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					if _ArcaneShot_RDY and currentSpell ~= _AimedShot and ((_Mana_Percent >= 50) or _is_moving or (_Target_Percent_Health <= 5 and ConROC:Raidmob()) or (_Target_Percent_Health <= 20 and not ConROC:Raidmob())) then
						tinsert(ConROC.SuggestedSpells, _ArcaneShot);
						_ArcaneShot_RDY = false;
						_Queue = _Queue + 1;
						break;
					end

					tinsert(ConROC.SuggestedSpells, _AutoShot); --Waiting Spell Icon
					_Queue = _Queue + 3;
					break;
				end
			end

			tinsert(ConROC.SuggestedSpells, 26008); --Waiting Spell Icon
			_Queue = _Queue + 3;
			break;
		end
	until _Queue >= 3;
return nil;
end

function ConROC.Hunter.Defense(_, timeShift, currentSpell, gcd)
	ConROC:UpdateSpellID();
	wipe(ConROC.SuggestedDefSpells);
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
	local _Pet_Happiness = GetPetHappiness();

	if _Pet_Happiness == nil then
		_Pet_Happiness = 0;
	end

--Indicators
	ConROC:AbilityRaidBuffs(_FeedPet, _FeedPet_RDY and _Pet_summoned and not _in_combat and _Pet_Happiness < 3);

--Rotations	
	if _Disengage_RDY and _target_in_melee and ConROC:TarYou() then
		tinsert(ConROC.SuggestedDefSpells, _Disengage);
	end

	if _AspectoftheMonkey_RDY and not _AspectoftheMonkey_FORM and _target_in_melee and ConROC:TarYou() then
		tinsert(ConROC.SuggestedDefSpells, _AspectoftheMonkey);
	end

	if _Deterrence_RDY and _Player_Percent_Health <= 30 and ConROC:TarYou() then
		tinsert(ConROC.SuggestedDefSpells, _Deterrence);
	end

	if _FeignDeath_RDY and _Player_Percent_Health <= 30 and ConROC:TarYou() then
		tinsert(ConROC.SuggestedDefSpells, _FeignDeath);
	end

	if _MendPet_RDY and _Pet_summoned and _Pet_Percent_Health <= 40 then
		tinsert(ConROC.SuggestedDefSpells, _MendPet);
	end
return nil;
end

function ConROC:JustCasted(spellID)
    if spellID == (_AutoShot or Ability.SerpentSting) then
        _AutoShot_ACTIVE = true;
    end
end

function ConROC:HasWindfury()
	local _Windfury_Present = false;
	local _Windfury_IDs = {2636,3785,3786,3787,7141};
	local _has_Imbue, _, _, _Imbuement = GetWeaponEnchantInfo();
	if _has_Imbue then
		for _, v in pairs(_Windfury_IDs) do
			if _Imbuement == v then
				_Windfury_Present = true;
			end
		end
	end

	return _Windfury_Present;
end