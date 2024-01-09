local printTalentsMode = false

-- Slash command for printing talent tree with talent names and ID numbers
SLASH_CONROCPRINTTALENTS1 = "/ConROCPT"
SlashCmdList["CONROCPRINTTALENTS"] = function()
    printTalentsMode = not printTalentsMode
    ConROC:PopulateTalentIDs()
end

ConROC.Hunter = {};

local ConROC_Hunter, ids = ...;
local optionMaxIds = ...;
local currentSpecName

function ConROC:EnableDefenseModule()
	self.NextDef = ConROC.Hunter.Defense;
end

function ConROC:UNIT_SPELLCAST_SUCCEEDED(event, unitID, lineID, spellID)
	if unitID == 'player' then
		self.lastSpellId = spellID;
	end
end

function ConROC:PopulateTalentIDs()
    local numTabs = GetNumTalentTabs()
    
    for tabIndex = 1, numTabs do
        local tabName = GetTalentTabInfo(tabIndex) .. "_Talent"
        tabName = string.gsub(tabName, "%s", "") -- Remove spaces from tab name
        if printTalentsMode then
        	print(tabName..": ")
        else
        	ids[tabName] = {}
    	end
        
        local numTalents = GetNumTalents(tabIndex)

        for talentIndex = 1, numTalents do
            local name, _, _, _, _ = GetTalentInfo(tabIndex, talentIndex)

            if name then
                local talentID = string.gsub(name, "%s", "") -- Remove spaces from talent name
                if printTalentsMode then
                	print(talentID .." = ID no: ", talentIndex)
                else
                	ids[tabName][talentID] = talentIndex
                end
            end
        end
    end
    if printTalentsMode then printTalentsMode = false end
end
ConROC:PopulateTalentIDs()

local Racial, Spec, BM_Ability, BM_Talent, MM_Ability, MM_Talent, Surv_Ability, Surv_Talent, Pet, Player_Buff, Player_Debuff, Target_Debuff = ids.Racial, ids.Spec, ids.BM_Ability, ids.BeastMastery_Talent, ids.MM_Ability, ids.Marksmanship_Talent, ids.Surv_Ability, ids.Survival_Talent, ids.Pet, ids.Player_Buff, ids.Player_Debuff, ids.Target_Debuff;


function ConROC:SpecUpdate()
	currentSpecName = ConROC:currentSpec()

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
	
	ConROC:SpellmenuClass();
--	ConROCSpellmenuFrame:Hide();	
end
function ConROC:PLAYER_TALENT_UPDATE()
	ConROC:SpecUpdate();
    ConROC:closeSpellmenu();
end
--Ranks
--Beast Mastery

local _AspectoftheBeast = BM_Ability.AspectoftheBeast
local _AspectoftheCheetah = BM_Ability.AspectoftheCheetah
local _AspectoftheHawk = BM_Ability.AspectoftheHawkRank1;
local _AspectoftheMonkey = BM_Ability.AspectoftheMonkey;
local _AspectofthePack = BM_Ability.AspectofthePack;
local _AspectoftheWild = BM_Ability.AspectoftheWildRank1;
local _BestialWrath = BM_Ability.BestialWrath;
local _Intimidation = BM_Ability.Intimidation;
local _KillCommand = BM_Ability.KillCommand;
local _ScareBeast = BM_Ability.ScareBeastRank1;

--Marksmanship
local _AimedShot = MM_Ability.AimedShotRank1;	
local _ArcaneShot = MM_Ability.ArcaneShotRank1;
local _AutoShot = ids.MM_Ability.AutoShot;
local _ConcussiveShot = MM_Ability.ConcussiveShot;
local _HuntersMark = MM_Ability.HuntersMarkRank1;
local _MultiShot = MM_Ability.MultiShotRank1;
local _RapidFire = MM_Ability.RapidFire;
local _ScatterShot = MM_Ability.ScatterShot;
local _ScorpidSting = MM_Ability.ScorpidStingRank1;
local _SerpentSting = MM_Ability.SerpentStingRank1;
local _SilencingShot = MM_Ability.SilencingShotRank1;
local _TrueshotAura = MM_Ability.TrueshotAuraRank1;
local _ViperSting = MM_Ability.ViperStingRank1;
local _Volley = MM_Ability.VolleyRank1;

--Survival
local _Counterattack = Surv_Ability.CounterattackRank1;
local _ExplosiveTrap = Surv_Ability.ExplosiveTrapRank1;
local _FreezingTrap = Surv_Ability.FreezingTrapRank1;
local _FrostTrap = Surv_Ability.FrostTrap;
local _ImmolationTrap = Surv_Ability.ImmolationTrapRank1;
local _MongooseBite = Surv_Ability.MongooseBiteRank1;
local _RaptorStrike = Surv_Ability.RaptorStrikeRank1;
local _WingClip = Surv_Ability.WingClipRank1;
local _WyvernSting = Surv_Ability.WyvernStingRank1;

function ConROC:UpdateSpellID()
--Beast Mastery
if IsSpellKnown(BM_Ability.AspectoftheHawkRank6) then _AspectoftheHawk = BM_Ability.AspectoftheHawkRank6;
elseif IsSpellKnown(BM_Ability.AspectoftheHawkRank5) then _AspectoftheHawk = BM_Ability.AspectoftheHawkRank5;
elseif IsSpellKnown(BM_Ability.AspectoftheHawkRank4) then _AspectoftheHawk = BM_Ability.AspectoftheHawkRank4;
elseif IsSpellKnown(BM_Ability.AspectoftheHawkRank3) then _AspectoftheHawk = BM_Ability.AspectoftheHawkRank3;
elseif IsSpellKnown(BM_Ability.AspectoftheHawkRank2) then _AspectoftheHawk = BM_Ability.AspectoftheHawkRank2; end

if IsSpellKnown(BM_Ability.AspectoftheWildRank2) then _AspectoftheWild = BM_Ability.AspectoftheWildRank2; end

if IsSpellKnown(BM_Ability.ScareBeastRank3) then _ScareBeast = BM_Ability.ScareBeastRank3;
elseif IsSpellKnown(BM_Ability.ScareBeastRank2) then _ScareBeast = BM_Ability.ScareBeastRank2; end

--Marksmanship
if IsSpellKnown(MM_Ability.AimedShotRank6) then _AimedShot = MM_Ability.AimedShotRank6;
elseif IsSpellKnown(MM_Ability.AimedShotRank5) then _AimedShot = MM_Ability.AimedShotRank5;
elseif IsSpellKnown(MM_Ability.AimedShotRank4) then _AimedShot = MM_Ability.AimedShotRank4;
elseif IsSpellKnown(MM_Ability.AimedShotRank3) then _AimedShot = MM_Ability.AimedShotRank3;
elseif IsSpellKnown(MM_Ability.AimedShotRank2) then _AimedShot = MM_Ability.AimedShotRank2; end

if IsSpellKnown(MM_Ability.ArcaneShotRank8) then _ArcaneShot = MM_Ability.ArcaneShotRank8;
elseif IsSpellKnown(MM_Ability.ArcaneShotRank7) then _ArcaneShot = MM_Ability.ArcaneShotRank7;
elseif IsSpellKnown(MM_Ability.ArcaneShotRank6) then _ArcaneShot = MM_Ability.ArcaneShotRank6;
elseif IsSpellKnown(MM_Ability.ArcaneShotRank5) then _ArcaneShot = MM_Ability.ArcaneShotRank5;
elseif IsSpellKnown(MM_Ability.ArcaneShotRank4) then _ArcaneShot = MM_Ability.ArcaneShotRank4;
elseif IsSpellKnown(MM_Ability.ArcaneShotRank3) then _ArcaneShot = MM_Ability.ArcaneShotRank3;
elseif IsSpellKnown(MM_Ability.ArcaneShotRank2) then _ArcaneShot = MM_Ability.ArcaneShotRank2; end

if IsSpellKnown(MM_Ability.HuntersMarkRank4) then _HuntersMark = MM_Ability.HuntersMarkRank4;
elseif IsSpellKnown(MM_Ability.HuntersMarkRank3) then _HuntersMark = MM_Ability.HuntersMarkRank3;
elseif IsSpellKnown(MM_Ability.HuntersMarkRank2) then _HuntersMark = MM_Ability.HuntersMarkRank2; end

if IsSpellKnown(MM_Ability.MultiShotRank4) then _MultiShot = MM_Ability.MultiShotRank4;
elseif IsSpellKnown(MM_Ability.MultiShotRank3) then _MultiShot = MM_Ability.MultiShotRank3;
elseif IsSpellKnown(MM_Ability.MultiShotRank2) then _MultiShot = MM_Ability.MultiShotRank2; end

if IsSpellKnown(MM_Ability.ScorpidStingRank4) then _ScorpidSting = MM_Ability.ScorpidStingRank4;
elseif IsSpellKnown(MM_Ability.ScorpidStingRank3) then _ScorpidSting = MM_Ability.ScorpidStingRank3;
elseif IsSpellKnown(MM_Ability.ScorpidStingRank2) then _ScorpidSting = MM_Ability.ScorpidStingRank2; end

if IsSpellKnown(MM_Ability.SerpentStingRank8) then _SerpentSting = MM_Ability.SerpentStingRank8;
elseif IsSpellKnown(MM_Ability.SerpentStingRank7) then _SerpentSting = MM_Ability.SerpentStingRank7;
elseif IsSpellKnown(MM_Ability.SerpentStingRank6) then _SerpentSting = MM_Ability.SerpentStingRank6;
elseif IsSpellKnown(MM_Ability.SerpentStingRank5) then _SerpentSting = MM_Ability.SerpentStingRank5;
elseif IsSpellKnown(MM_Ability.SerpentStingRank4) then _SerpentSting = MM_Ability.SerpentStingRank4;
elseif IsSpellKnown(MM_Ability.SerpentStingRank3) then _SerpentSting = MM_Ability.SerpentStingRank3;
elseif IsSpellKnown(MM_Ability.SerpentStingRank2) then _SerpentSting = MM_Ability.SerpentStingRank2; end

if IsSpellKnown(MM_Ability.TrueshotAuraRank3) then _TrueshotAura = MM_Ability.TrueshotAuraRank3;
elseif IsSpellKnown(MM_Ability.TrueshotAuraRank2) then _TrueshotAura = MM_Ability.TrueshotAuraRank2; end
	
if IsSpellKnown(MM_Ability.ViperStingRank3) then _ViperSting = MM_Ability.ViperStingRank3;
elseif IsSpellKnown(MM_Ability.ViperStingRank2) then _ViperSting = MM_Ability.ViperStingRank2; end

if IsSpellKnown(MM_Ability.VolleyRank3) then _Volley = MM_Ability.VolleyRank3;
elseif IsSpellKnown(MM_Ability.VolleyRank2) then _Volley = MM_Ability.VolleyRank2; end

--Survival
if IsSpellKnown(Surv_Ability.CounterattackRank3) then _Counterattack = Surv_Ability.CounterattackRank3;
elseif IsSpellKnown(Surv_Ability.CounterattackRank2) then _Counterattack = Surv_Ability.CounterattackRank2; end

if IsSpellKnown(Surv_Ability.ExplosiveTrapRank3) then _ExplosiveTrap = Surv_Ability.ExplosiveTrapRank3;
elseif IsSpellKnown(Surv_Ability.ExplosiveTrapRank2) then _ExplosiveTrap = Surv_Ability.ExplosiveTrapRank2; end

if IsSpellKnown(Surv_Ability.ImmolationTrapRank5) then _ImmolationTrap = Surv_Ability.ImmolationTrapRank5;
elseif IsSpellKnown(Surv_Ability.ImmolationTrapRank4) then _ImmolationTrap = Surv_Ability.ImmolationTrapRank4;
elseif IsSpellKnown(Surv_Ability.ImmolationTrapRank3) then _ImmolationTrap = Surv_Ability.ImmolationTrapRank3;
elseif IsSpellKnown(Surv_Ability.ImmolationTrapRank2) then _ImmolationTrap = Surv_Ability.ImmolationTrapRank2; end

if IsSpellKnown(Surv_Ability.FreezingTrapRank3) then _FreezingTrap = Surv_Ability.FreezingTrapRank3;
elseif IsSpellKnown(Surv_Ability.FreezingTrapRank2) then _FreezingTrap = Surv_Ability.FreezingTrapRank2; end

if IsSpellKnown(Surv_Ability.MongooseBiteRank4) then _MongooseBite = Surv_Ability.MongooseBiteRank4;
elseif IsSpellKnown(Surv_Ability.MongooseBiteRank3) then _MongooseBite = Surv_Ability.MongooseBiteRank3;
elseif IsSpellKnown(Surv_Ability.MongooseBiteRank2) then _MongooseBite = Surv_Ability.MongooseBiteRank2; end

if IsSpellKnown(Surv_Ability.RaptorStrikeRank8) then _RaptorStrike = Surv_Ability.RaptorStrikeRank8;
elseif IsSpellKnown(Surv_Ability.RaptorStrikeRank7) then _RaptorStrike = Surv_Ability.RaptorStrikeRank7;
elseif IsSpellKnown(Surv_Ability.RaptorStrikeRank6) then _RaptorStrike = Surv_Ability.RaptorStrikeRank6;
elseif IsSpellKnown(Surv_Ability.RaptorStrikeRank5) then _RaptorStrike = Surv_Ability.RaptorStrikeRank5;
elseif IsSpellKnown(Surv_Ability.RaptorStrikeRank4) then _RaptorStrike = Surv_Ability.RaptorStrikeRank4;
elseif IsSpellKnown(Surv_Ability.RaptorStrikeRank3) then _RaptorStrike = Surv_Ability.RaptorStrikeRank3;
elseif IsSpellKnown(Surv_Ability.RaptorStrikeRank2) then _RaptorStrike = Surv_Ability.RaptorStrikeRank2; end

if IsSpellKnown(Surv_Ability.WingClipRank3) then _WingClip = Surv_Ability.WingClipRank3;
elseif IsSpellKnown(Surv_Ability.WingClipRank2) then _WingClip = Surv_Ability.WingClipRank2; end

if IsSpellKnown(Surv_Ability.WyvernStingRank3) then _WyvernSting = Surv_Ability.WyvernStingRank3;
elseif IsSpellKnown(Surv_Ability.WyvernStingRank2) then _WyvernSting = Surv_Ability.WyvernStingRank2; end

ids.optionMaxIds = {
--Beast Mastery
AspectoftheBeast = _AspectoftheBeast,
AspectoftheCheetah = _AspectoftheCheetah,
AspectoftheHawk = _AspectoftheHawk,
AspectoftheMonkey = _AspectoftheMonkey,
AspectofthePack = _AspectofthePack,
AspectoftheWild = _AspectoftheWild,
BestialWrath = _BestialWrath,
Intimidation = _Intimidation,
ScareBeast = _ScareBeast,
--Marksmanship
AimedShot = _AimedShot,
ArcaneShot = _ArcaneShot,
ConcussiveShot = _ConcussiveShot,
HuntersMark = _HuntersMark,
MultiShot = _MultiShot,
RapidFire = _RapidFire,
ScatterShot = _ScatterShot,
ScorpidSting = _ScorpidSting,
SerpentSting = _SerpentSting,
TrueshotAura = _TrueshotAura,
ViperSting = _ViperSting,
Volley = _Volley, 
--Survival
Counterattack = _Counterattack,
ExplosiveTrap = _ExplosiveTrap, 
FreezingTrap = _FreezingTrap,
FrostTrap = _FrostTrap,
ImmolationTrap = _ImmolationTrap,
MongooseBite = _MongooseBite,
RaptorStrike = _RaptorStrike,
WingClip = _WingClip,
WyvernSting = _WyvernSting,
}
end
ConROC:UpdateSpellID()
function ConROC.Hunter.Damage(_, timeShift, currentSpell, gcd)
ConROC:UpdateSpellID()
--Character
	local plvl 												= UnitLevel('player');
	
--Racials
		
--Resources
	local mana												= UnitPower('player', Enum.PowerType.Mana);
	local manaMax 											= UnitPowerMax('player', Enum.PowerType.Mana);
	local manaPercent 										= math.max(0, mana) / math.max(1, manaMax) * 100;

--Abilities
	local bWrathRDY											= ConROC:AbilityReady(_BestialWrath, timeShift);	
	local intimRDY											= ConROC:AbilityReady(_Intimidation, timeShift);		
	
	local aimShotRDY	 									= ConROC:AbilityReady(_AimedShot, timeShift);
	local arcShotRDY	 									= ConROC:AbilityReady(_ArcaneShot, timeShift);	
	local autoShot	 										= ConROC:AbilityReady(_AutoShot, timeShift);
	local concusShotRDY										= ConROC:AbilityReady(_ConcussiveShot, timeShift);
	local hMarkRDY		 									= ConROC:AbilityReady(_HuntersMark, timeShift);	
		local hmDEBUFF											= ConROC:DebuffName(_HuntersMark);	
	local multiRDY	 										= ConROC:AbilityReady(_MultiShot, timeShift);
	local rFireRDY											= ConROC:AbilityReady(_RapidFire, timeShift);	
		local rfBUFF											= ConROC:Buff(_RapidFire);	
	local scatterRDY										= ConROC:AbilityReady(_ScatterShot, timeShift);			
	local scStingRDY										= ConROC:AbilityReady(_ScorpidSting, timeShift);
	local sStingRDY											= ConROC:AbilityReady(_SerpentSting, timeShift);
	local tsAuraRDY											= ConROC:AbilityReady(_TrueshotAura, timeShift);
		local tsABUFF											= ConROC:Buff(_TrueshotAura);		
	local vStingRDY											= ConROC:AbilityReady(_ViperSting, timeShift);
	local volleyRDY											= ConROC:AbilityReady(_Volley, timeShift);		
		
	local cAttackRDY										= ConROC:AbilityReady(_Counterattack, timeShift);			
	local exTrapRDY											= ConROC:AbilityReady(_ExplosiveTrap, timeShift);
	local imTrapRDY											= ConROC:AbilityReady(_ImmolationTrap, timeShift);
	local fTrapRDY											= ConROC:AbilityReady(_FreezingTrap, timeShift);
	local frTrapRDY											= ConROC:AbilityReady(_FrostTrap, timeShift);
	local mBiteRDY											= ConROC:AbilityReady(_MongooseBite, timeShift);		
	local rStrikeRDY										= ConROC:AbilityReady(_RaptorStrike, timeShift);
	local wClipRDY											= ConROC:AbilityReady(_WingClip, timeShift);	
		local wClipDEBUFF										= ConROC:TargetDebuff(_WingClip, timeShift);		
	local wStingRDY											= ConROC:AbilityReady(_WyvernSting, timeShift);
		local wStingDEBUFF										= ConROC:TargetDebuff(_WyvernSting);	
		
	local aotHawk											= ConROC:AbilityReady(_AspectoftheHawk, timeShift);
		local aothForm											= ConROC:Form(_AspectoftheHawk);
	local aotCheetah										= ConROC:AbilityReady(_AspectoftheCheetah, timeShift);
		local aotcForm											= ConROC:Form(_AspectoftheCheetah);
	local aotPack											= ConROC:AbilityReady(_AspectofthePack, timeShift);
		local aotpForm											= ConROC:Form(_AspectofthePack);
		
--Conditions	
	local targetPh 											= ConROC:PercentHealth('target');
	local summoned 											= ConROC:CallPet();
	local isClose 											= CheckInteractDistance('target', 3);
	local moving 											= ConROC:PlayerSpeed();	
	local incombat 											= UnitAffectingCombat('player');
	local inShotRange										= ConROC:IsSpellInRange(_AutoShot, 'target');
	local cPetRDY											= GetCallPetSpellInfo();
	local inMelee											= isClose
	local tarHasMana 										= UnitPower('target', Enum.PowerType.Mana);
	
	if IsSpellKnown(_WingClip) then
		inMelee												= ConROC:IsSpellInRange(_WingClip, 'target');
	end

    local stingDEBUFF = {
		scStingDEBUFF										= ConROC:TargetDebuff(_ScorpidSting);
        sStingDEBUFF										= ConROC:TargetDebuff(_SerpentSting);
		vStingDEBUFF										= ConROC:TargetDebuff(_ViperSting);	
    }	

	local stingUp = false;
		for k, v in pairs(stingDEBUFF) do
			if v then
				stingUp = true;
				break
			end
		end
		
--Indicators
	ConROC:AbilityRaidBuffs(_AspectoftheHawk, aotHawk and not aothForm and not inMelee);	
	ConROC:AbilityBurst(BM_Ability.BestialWrath, not ConROC:CheckBox(ConROC_SM_Ability_BestialWrath) and bWrathRDY and incombat and summoned);
	ConROC:AbilityBurst(MM_Ability.RapidFire, not ConROC:CheckBox(ConROC_SM_Ability_RapidFire) and rFireRDY and incombat);
	ConROC:AbilityMovement(BM_Ability.AspectoftheCheetah, aotCheetah and not aotcForm and not incombat);

	ConROC:AbilityRaidBuffs(_TrueshotAura, tsAuraRDY and not tsABUFF);
	
--Warnings
	if cPetRDY and not summoned and incombat then
		ConROC:Warnings("Call your pet!!!", true);
	end

--Rotations
	if ConROC:CheckBox(ConROC_SM_Ability_HuntersMark) and hMarkRDY and not hmDEBUFF and not inMelee then
		return _HuntersMark;
	end	

	if ConROC:CheckBox(ConROC_SM_Stun_Intimidation) and intimRDY and summoned and ConROC:TarYou() then
		return BM_Ability.Intimidation;
	end

	if ConROC:CheckBox(ConROC_SM_Stun_ScatterShot) and scatterRDY and ConROC:IsSpellInRange(MM_Ability.ScatterShot, 'target') and ConROC:TarYou() then
		return MM_Ability.ScatterShot;
	end
		
	if inShotRange then
		if ConROC:CheckBox(ConROC_SM_Stun_ConcussiveShot) and concusShotRDY and ConROC:TarYou() then
			return MM_Ability.ConcussiveShot;
		end
		
		if ConROC:CheckBox(ConROC_SM_Ability_AimedShot) and aimShotRDY and currentSpell ~= _AimedShot then
			return _AimedShot;
		end

		if ConROC:CheckBox(ConROC_SM_Sting_Viper) and vStingRDY and not stingUp and tarHasMana > 0 and ConROC.lastSpellId ~= _ViperSting and not ConROC:CreatureType("Mechanical") and not ConROC:CreatureType("Elemental") then
			return _ViperSting;
		end
		
		if ConROC:CheckBox(ConROC_SM_Sting_Serpent) and sStingRDY and not stingUp and ConROC.lastSpellId ~= _SerpentSting and not ConROC:CreatureType("Mechanical") and not ConROC:CreatureType("Elemental") then
			return _SerpentSting;
		end
		
		if ConROC:CheckBox(ConROC_SM_Sting_Scorpid) and scStingRDY and not stingUp and ConROC.lastSpellId ~= _ScorpidSting and not ConROC:CreatureType("Mechanical") and not ConROC:CreatureType("Elemental") then
			return _ScorpidSting;
		end
		
		if ConROC:CheckBox(ConROC_SM_Ability_BestialWrath) and bWrathRDY and incombat and summoned then
			return BM_Ability.BestialWrath;
		end
		
		if ConROC:CheckBox(ConROC_SM_Ability_RapidFire) and rFireRDY and incombat then
			return MM_Ability.RapidFire;
		end
		
		if (ConROC_AoEButton:IsVisible() and ConROC:CheckBox(ConROC_SM_Ability_MultiShot)) and multiRDY then
			return _MultiShot;
		end
		
		if ConROC_AoEButton:IsVisible() and volleyRDY then
			return _Volley;
		end
		
		if arcShotRDY and currentSpell ~= _AimedShot and ((manaPercent >= 50) or moving or ((targetPh <= 5 and ConROC:Raidmob()) or (targetPh <= 20 and not ConROC:Raidmob()))) then
			return _ArcaneShot;
		end
		
		if autoShot then
			return ids.MM_Ability.AutoShot;
		end
	end

	if inMelee then
		if cAttackRDY then
			return _Counterattack;
		end
	
		if mBiteRDY then
			return _MongooseBite;
		end
		
		if ConROC:CheckBox(ConROC_SM_Stun_WingClip) and wClipRDY and not wClipDEBUFF then
			return _WingClip;
		end
		
		if rStrikeRDY then
			return _RaptorStrike;
		end
	end
	
	return nil;
end

function ConROC.Hunter.Defense(_, timeShift, currentSpell, gcd)
--Character
	local plvl 												= UnitLevel('player');
	
--Racials
		
--Resources
	local focus 											= UnitPower('player', Enum.PowerType.Focus);
	local focusMax 											= UnitPowerMax('player', Enum.PowerType.Focus);

--Ranks
	--Beast Mastery
	local _AspectoftheWild = BM_Ability.AspectoftheWildRank1;
	local _MendPet = BM_Ability.MendPetRank1;

	if IsSpellKnown(BM_Ability.AspectoftheWildRank2) then _AspectoftheWild = BM_Ability.AspectoftheWildRank2; end

	if IsSpellKnown(BM_Ability.MendPetRank7) then _MendPet = BM_Ability.MendPetRank7;
	elseif IsSpellKnown(BM_Ability.MendPetRank6) then _MendPet = BM_Ability.MendPetRank6;
	elseif IsSpellKnown(BM_Ability.MendPetRank5) then _MendPet = BM_Ability.MendPetRank5;
	elseif IsSpellKnown(BM_Ability.MendPetRank4) then _MendPet = BM_Ability.MendPetRank4;
	elseif IsSpellKnown(BM_Ability.MendPetRank3) then _MendPet = BM_Ability.MendPetRank3;
	elseif IsSpellKnown(BM_Ability.MendPetRank2) then _MendPet = BM_Ability.MendPetRank2; end
	
	--Marksmanship
	local _DistractingShot = MM_Ability.DistractingShotRank1;

	if IsSpellKnown(MM_Ability.DistractingShotRank6) then _DistractingShot = MM_Ability.DistractingShotRank6;
	elseif IsSpellKnown(MM_Ability.DistractingShotRank5) then _DistractingShot = MM_Ability.DistractingShotRank5;
	elseif IsSpellKnown(MM_Ability.DistractingShotRank4) then _DistractingShot = MM_Ability.DistractingShotRank4;
	elseif IsSpellKnown(MM_Ability.DistractingShotRank3) then _DistractingShot = MM_Ability.DistractingShotRank3;
	elseif IsSpellKnown(MM_Ability.DistractingShotRank2) then _DistractingShot = MM_Ability.DistractingShotRank2; end

	--Survival
	local _Disengage = Surv_Ability.DisengageRank1;

	if IsSpellKnown(Surv_Ability.DisengageRank3) then _Disengage = Surv_Ability.DisengageRank3;
	elseif IsSpellKnown(Surv_Ability.DisengageRank2) then _Disengage = Surv_Ability.DisengageRank2; end	
	
--Abilities
	local feedRDY											= ConROC:AbilityReady(BM_Ability.FeedPet, timeShift);
		local happiness 									= GetPetHappiness();
	local mendPetRDY 										= ConROC:AbilityReady(_MendPet, timeShift);
	
	local disShotRDY										= ConROC:AbilityReady(_DistractingShot, timeShift);	

	local deterRDY											= ConROC:AbilityReady(Surv_Ability.Deterrence, timeShift);
	local disenRDY											= ConROC:AbilityReady(_Disengage, timeShift);
	local fDeathRDY											= ConROC:AbilityReady(Surv_Ability.FeignDeath, timeShift);

	local aotMonkey											= ConROC:AbilityReady(BM_Ability.AspectoftheMonkey, timeShift);
		local aotmForm											= ConROC:Form(BM_Ability.AspectoftheMonkey);
	local aotWild											= ConROC:AbilityReady(_AspectoftheWild, timeShift);
		local aotwForm											= ConROC:Form(_AspectoftheWild);
		
--Conditions	
	local playerPh 											= ConROC:PercentHealth('player');
	local summoned 											= ConROC:CallPet();	
	local petPh												= ConROC:PercentHealth('pet');
	local incombat 											= UnitAffectingCombat('player');
	local isClose 											= CheckInteractDistance('target', 3);	
	local inMelee											= isClose
	
	if IsSpellKnown(_WingClip) then
		inMelee											= ConROC:IsSpellInRange(_WingClip, 'target');
	end
	
	if happiness == nil then
		happiness = 0;
	end
	
--Indicators
	ConROC:AbilityRaidBuffs(BM_Ability.FeedPet, feedRDY and summoned and not incombat and happiness < 3);
	
--Rotations	
	if disenRDY and inMelee and ConROC:TarYou() then
		return _Disengage;
	end
	
	if aotMonkey and not aotmForm and inMelee and ConROC:TarYou() then
		return BM_Ability.AspectoftheMonkey;
	end
	
	if deterRDY and playerPh <= 30 and ConROC:TarYou() then
		return Surv_Ability.Deterrence;
	end
	
	if fDeathRDY and playerPh <= 30 and ConROC:TarYou() then
		return Surv_Ability.FeignDeath;
	end	
	
	if mendPetRDY and summoned and petPh <= 40 then
		return _MendPet;
	end
	
	return nil;
end