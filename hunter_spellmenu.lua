local debugOptions = {
	scrollChild = false,
	header = false,
	spells = false,
}
-- L for translations
local L = LibStub("AceLocale-3.0"):GetLocale("ConROC");

local ConROC_Hunter, ids = ...;
local ConROC_RolesTable = {};
local lastFrame = 0;

local showOptions = false;
local fixOptionsWidth = false;
local frameWidth = math.ceil(ConROCSpellmenuFrame:GetWidth()*2);
local spellFrameHeight = 0;
local scrollContentWidth = frameWidth - 30;
local scrollHeight = 0;

local plvl = UnitLevel('player');

local defaults = {
	["ConROC_SM_Role_Ranged"] = true,
	["ConROC_SM_Role_Melee"] = false,
	["ConROC_SM_Role_PvP"] = false,

	["ConROC_Ranged_Sting_Serpent"] = true,
	["ConROC_Ranged_Sting_Scorpid"] = false,
	["ConROC_Ranged_Sting_Viper"] = false,
	["ConROC_Ranged_Sting_None"] = false,
	["ConROC_Ranged_Ability_HuntersMark"] = true,
	["ConROC_Ranged_Ability_ChimeraShot"] = true,
	["ConROC_Ranged_Ability_MultiShot"] = true,
	["ConROC_Ranged_Ability_AimedShot"] = true,
	["ConROC_Ranged_Ability_RapidFire"] = true,
	["ConROC_Ranged_Ability_BestialWrath"] = true,
	["ConROC_Ranged_Fire_None"] = true,
	["ConROC_Ranged_Stun_ConcussiveShot"] = false,
	["ConROC_Ranged_Stun_WingClip"] = false,
	["ConROC_Ranged_Stun_Intimidation"] = false,
	["ConROC_Ranged_Stun_ScatterShot"] = false,
	["ConROC_Ranged_Option_AutoShot"] = true,
	["ConROC_Ranged_Option_AoE"] = false,

	["ConROC_Melee_Sting_Serpent"] = true,
	["ConROC_Melee_Sting_Scorpid"] = false,
	["ConROC_Melee_Sting_Viper"] = false,
	["ConROC_Melee_Sting_None"] = false,
	["ConROC_Melee_Ability_HuntersMark"] = true,
	["ConROC_Melee_Ability_ChimeraShot"] = true,
	["ConROC_Melee_Ability_MultiShot"] = true,
	["ConROC_Melee_Ability_AimedShot"] = true,
	["ConROC_Melee_Ability_RapidFire"] = true,
	["ConROC_Melee_Ability_BestialWrath"] = true,
	["ConROC_Melee_Fire_None"] = true,
	["ConROC_Melee_Stun_ConcussiveShot"] = false,
	["ConROC_Melee_Stun_WingClip"] = false,
	["ConROC_Melee_Stun_Intimidation"] = false,
	["ConROC_Melee_Stun_ScatterShot"] = false,
	["ConROC_Melee_Option_AutoShot"] = true,
	["ConROC_Melee_Option_AoE"] = false,
}


ConROCHunterSpells = ConROCHunterSpells or defaults;
local radioGroups = {}

function ConROC:setRole(radioBtn, roleData, radioButtons)
	for _, btn in ipairs(radioButtons) do
        btn:SetChecked(false)
    	ConROCHunterSpells[btn.role] = false
    end
    radioBtn:SetChecked(true)
    ConROCHunterSpells[roleData.role] = true
end

function ConROC:checkActiveRole()
	for _, roleSettings in ipairs(ConROC_RoleSettingsTable) do
        local frameName = roleSettings.frameName
        local role = _G[roleSettings.role]

        if role:GetChecked() then
        		local checkboxName = "ConROC_"..frameName.."_"
                -- The frame with matching name is checked, perform actions here
                return role, checkboxName, frameName
        end
    end
end

function ConROC:setRoleChecked(_spellData, _oItem)
	local activeRole, checkboxName, _ = ConROC:checkActiveRole()
	if ConROC:CheckBox(activeRole) then
		local spellCheck = checkboxName .. _spellData.spellCheckbox
		if _spellData.type == "textfield" then
			_oItem:SetNumber(ConROCHunterSpells[spellCheck]);
		else
			_oItem:SetChecked(ConROCHunterSpells[spellCheck]);
		end
	end
end

function ConROC:setRoleSpellClicked(_spellData, _oItem)
	local activeRole, checkboxName, _ = ConROC:checkActiveRole()
	if ConROC:CheckBox(activeRole) then
		local spellCheck = checkboxName .. _spellData.spellCheckbox
		if _spellData.type == "textfield" then
			ConROCHunterSpells[spellCheck] = _G["ConROC_SM_".._spellData.spellCheckbox]:GetNumber();
		else
			ConROCHunterSpells[spellCheck] = _oItem:GetChecked();
		end
	end
end

local function CheckScrollbarVisibility()
	if _G["ConROCSpellmenuFrame_OpenButton"]:IsShown() then
        return
    end
    local scrollChildHeight = math.ceil(ConROCScrollChild:GetHeight())
    local containerHeight = math.ceil(ConROCScrollFrame:GetHeight())
	ConROCSpellmenuFrame:SetWidth(frameWidth)

    if scrollChildHeight <= containerHeight then
    	ConROCScrollbar:Hide()
        ConROCScrollContainer:SetHeight(math.ceil(ConROCScrollChild:GetHeight())+16)
    	ConROCSpellmenuFrame:SetHeight(math.ceil(ConROCScrollContainer:GetHeight())+68)
		ConROCScrollFrame:SetPoint("TOPLEFT", 8, -8)
		ConROCScrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)
    	ConROCScrollChild:SetWidth(ConROCScrollFrame:GetWidth())
    else
    	ConROCScrollbar:Show()
    	ConROCSpellmenuFrame:SetHeight(300)
    	ConROCScrollContainer:SetHeight(237)
		ConROCScrollFrame:SetPoint("TOPLEFT", 8, -8)
		ConROCScrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)
    	ConROCScrollChild:SetWidth(ConROCScrollFrame:GetWidth())
    end
end

function ConROC:RotationChoices()
    ConROC:UpdateSpellID();

	ConROC_RoleSettingsTable = {
		{
		frameName = "Ranged",
		activeTexture = ConROC.Textures.Ranged,
		disabledTexture = ConROC.Textures.Ranged_disabled,
		role = "ConROC_SM_Role_Ranged",
		},
		{
		frameName = "Melee",
		activeTexture = ConROC.Textures.Melee,
		disabledTexture = ConROC.Textures.Melee_disabled,
		role = "ConROC_SM_Role_Melee",
		},
		{
		frameName = "PvP",
		activeTexture = ConROC.Textures.PvP,
		disabledTexture = ConROC.Textures.PvP_disabled,
		role = "ConROC_SM_Role_PvP",
		},
	}
	ConROC_RotationSettingsTable = {
		{
	    frameName = "Stings",
	    spells = {
	      {spellID = ids.Ability.SerpentSting, spellCheckbox = "Sting_Serpent", reqLevel = 4, type = "spell"},
	      {spellID = ids.Ability.ScorpidSting, spellCheckbox = "Sting_Scorpid", reqLevel = 22, type ="spell"},
	      {spellID = ids.Ability.ViperSting, spellCheckbox = "Sting_Viper", reqLevel = 36, type = "spell"},
	      {spellID = "None", spellCheckbox = "Sting_None", reqLevel = 4, type="none"}
	    },
	    groupType = "radioButtons"
	 	},
		{
		frameName = "Aspects",
		spells = {
			{spellID = ids.Runes.AspectoftheFalcon, spellCheckbox = "Aspect_AspectoftheFalcon", reqLevel = 60, type = "spell"},
			{spellID = ids.Ability.AspectoftheHawk, spellCheckbox = "Aspect_AspectoftheHawk", reqLevel = 10, type = "spell"},
			{spellID = ids.Ability.AspectoftheMonkey, spellCheckbox = "Aspect_AspectoftheMonkey", reqLevel = 4, type ="spell"},
			{spellID = ids.Ability.AspectoftheViper, spellCheckbox = "Aspect_AspectoftheViper", reqLevel = 1, type = "spell"},
			{spellID = ids.Ability.AspectoftheWild, spellCheckbox = "Aspect_AspectoftheWild", reqLevel = 46, type = "spell"},
		},
		groupType = "radioButtons"
		},
	  	{
	    frameName = "Abilities",
	    spells = {
	    	{spellID = ids.Ability.HuntersMark, spellCheckbox = "Ability_HuntersMark", reqLevel = 6, type = "spell"},
	    	{spellID = ids.Runes.ChimeraShot, spellCheckbox = "Ability_ChimeraShot", reqLevel = 1, type = "spell"},
			{spellID = ids.Runes.HeartoftheLion, spellCheckbox = "Ability_HeartoftheLion", reqLevel = 1, type = "spell"},
			{spellID = ids.Runes.KillShot, spellCheckbox = "Ability_KillShot", reqLevel = 1, type = "spell"},
	    	{spellID = ids.Ability.AimedShot, spellCheckbox = "Ability_AimedShot", reqLevel = 20, type = "spell"},
	    	{spellID = ids.Ability.RapidFire, spellCheckbox = "Ability_RapidFire", reqLevel = 26, type = "spell"},
	    	{spellID = ids.Ability.BestialWrath, spellCheckbox = "Ability_BestialWrath", reqLevel = 40, type = "spell"},
	    	{spellID = ids.Ability.MultiShot, spellCheckbox = "Ability_MultiShot", reqLevel = 18, type = "spell"},
	    	{spellID = ids.Ability.RaptorStrike, spellCheckbox = "Ability_RaptorStrike", reqLevel = 1, type = "spell"},
	    	{spellID = ids.Ability.MongooseBite, spellCheckbox = "Ability_MongooseBite", reqLevel = 16, type = "spell"},
	    	{spellID = ids.Runes.FlankingStrike, spellCheckbox = "Ability_FlankingStrike", reqLevel = 1, type = "spell"},
	    	{spellID = ids.Runes.Carve, spellCheckbox = "Ability_Carve", reqLevel = 1, type = "spell"},
	    	{spellID = ids.Ability.Counterattack, spellCheckbox = "Ability_Counterattack", reqLevel = 30, type = "spell"},
	    	{spellID = ids.Runes.WyvernStrike, spellCheckbox = "Ability_WyvernStrike", reqLevel = 40, type = "spell"},
	    },
	    groupType = "checkBoxes"
	  	},
		  {
		  frameName = "Fire Traps",
		  spells = {
			  {spellID = ids.Ability.ImmolationTrap, spellCheckbox = "Fire_ImmolationTrap", reqLevel = 16, type = "spell"},
			  {spellID = ids.Ability.ExplosiveTrap, spellCheckbox = "Fire_ExplosiveTrap", reqLevel = 34, type ="spell"},
			  {spellID = "None", spellCheckbox = "Fire_None", reqLevel = 4, type="none"}
		  },
		  groupType = "radioButtons"
		  },
	  	{
	    frameName = "Stuns and Slows",
	    spells = {
	    	{spellID = ids.Ability.ConcussiveShot, spellCheckbox = "Stun_ConcussiveShot", reqLevel = 8, type = "spell"},
	    	{spellID = ids.Ability.WingClip, spellCheckbox = "Stun_WingClip", reqLevel = 12, type = "spell"},
	    	{spellID = ids.Ability.Intimidation, spellCheckbox = "Stun_Intimidation", reqLevel = 30, type = "spell"},
	    	{spellID = ids.Ability.ScatterShot, spellCheckbox = "Stun_ScatterShot", reqLevel = 20, type = "spell"},
	    },
	    groupType = "checkBoxes"
	  	},
	  	{
	    frameName = "Options",
	    spells = {
			{spellID = ids.Ability.WingClip, spellCheckbox = "Option_WingClip", reqLevel = 12, type="custom", icon = 2974, customName="Extra ATK Proc"},
		    {spellID = "AoE Toggle Button", spellCheckbox = "Option_AoE", reqLevel = 18, type = "aoetoggler"},
	    }
	  }
	}
end

function ConROC:SpellmenuClass()
	ConROC:RotationChoices();

	local _, Class, classId = UnitClass("player")
	local Color = RAID_CLASS_COLORS[Class]
	local frame = CreateFrame("Frame", "ConROCSpellmenuClass", ConROCSpellmenuFrame)

	frame:SetFrameStrata('MEDIUM');
	frame:SetFrameLevel('5')
	frame:SetSize(frameWidth, 30)
	frame:SetAlpha(1)

	frame:SetPoint("TOP", "ConROCSpellmenuFrame_Title", "BOTTOM", 0, 0)
	frame:SetMovable(false)
	frame:EnableMouse(true)
	frame:SetClampedToScreen(true)

	ConROC_roles(frame)

	frame:Hide();
	lastFrame = frame;

	-- create the frame and set its properties
	ConROCScrollContainer = CreateFrame("Frame", "ConROC_ScrollContainer", ConROCSpellmenuClass, "BackdropTemplate")
	ConROCScrollContainer:SetSize(frameWidth - 6, 237)
	ConROCScrollContainer:SetPoint("TOP", ConROCSpellmenuClass, "CENTER", 0, -20)
	ConROCScrollContainer:SetBackdrop({
	  bgFile = "Interface\\Buttons\\WHITE8x8",
	  nil,
	  tile = true, tileSize = 16, edgeSize = 16,
	  insets = { left = 0, right = 0, top = 0, bottom = 0 }
	})
	if debugOptions.scrollChild then
		ConROCScrollContainer:SetBackdropColor(0,1,0,0.2)
	else
		ConROCScrollContainer:SetBackdropColor(0,0,0,0.0)
	end
	ConROCScrollContainer:Show()

	-- create the scroll frame and set its properties
	ConROCScrollFrame = CreateFrame("ScrollFrame", "ConROC_ScrollFrame", ConROCScrollContainer, "UIPanelScrollFrameTemplate BackdropTemplate")
	ConROCScrollFrame:SetPoint("TOPLEFT", 8, -8)
	ConROCScrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)
	ConROCScrollFrame:SetBackdrop({
	  bgFile = "Interface\\Buttons\\WHITE8x8",
	  nil,
	  tile = true, tileSize = 16, edgeSize = 16,
	  insets = { left = 0, right = 0, top = 0, bottom = 0 }
	})
	if debugOptions.scrollChild then
		ConROCScrollFrame:SetBackdropColor(0,0,1,0.2)
	else
		ConROCScrollFrame:SetBackdropColor(0,0,0,0.0)
	end
	ConROCScrollFrame:Show()
	scrollContentWidth = ConROCScrollFrame:GetWidth()
	-- create the child frame and set its properties
	ConROCScrollChild = CreateFrame("Frame", "ConROC_ScrollChild", ConROCScrollFrame, "BackdropTemplate")
	ConROCScrollChild:SetSize(ConROCScrollFrame:GetWidth(), ConROCScrollFrame:GetHeight())
	ConROCScrollFrame:SetScrollChild(ConROCScrollChild)
	ConROCScrollChild:SetBackdrop({
	  bgFile = "Interface\\Buttons\\WHITE8x8",
	  nil,
	  tile = true, tileSize = 16, edgeSize = 16,
	  insets = { left = 0, right = 0, top = 0, bottom = 0 }
	})
	if debugOptions.scrollChild then
		ConROCScrollChild:SetBackdropColor(1,0,0,0.2)
	else
		ConROCScrollChild:SetBackdropColor(0,0,0,0.0)
	end
	ConROCScrollChild:Show()

	-- create the scrollbar and set its properties
	ConROCScrollbar = _G[ConROCScrollFrame:GetName() .. "ScrollBar"]
	ConROCScrollbar:SetValueStep(10)
	ConROCScrollbar.scrollStep = 10
	ConROCScrollbar:SetPoint("TOPLEFT", ConROCScrollFrame, "TOPRIGHT", 4, -16)
	ConROCScrollbar:SetPoint("BOTTOMLEFT", ConROCScrollFrame, "BOTTOMRIGHT", 4, 16)
	ConROCScrollbar:SetWidth(16)

	lastFrame = ConROCScrollChild;
	ConROCScrollContainer:Show();
	ConROCScrollFrame:Show();
	ConROCScrollChild:Show();

	ConROC_OptionsWindow(ConROC_RotationSettingsTable, ConROC_RoleSettingsTable)
	showOptions = true;
	fixOptionsWidth = true;

	-- Register for events to check scrollbar visibility
	ConROCScrollChild:SetScript("OnSizeChanged", CheckScrollbarVisibility)
	ConROCScrollContainer:SetScript("OnShow", CheckScrollbarVisibility)
end

local function ConROC_NoOptionsFrame()
    if ConROCNoOptions then
        return
    end
    if not ConROCScrollChild then
        return
    end

    -- Create ConROCNoOptions frame inside ConROCScrollChild
    ConROCNoOptions = CreateFrame("Frame", "ConROC_NoOptions", ConROCScrollFrame)
    ConROCNoOptions:SetSize(ConROCScrollFrame:GetWidth(), 80)  -- Start with a minimum height, will be adjusted dynamically

    ConROCNoOptions:SetPoint("TOPLEFT", ConROCScrollFrame, "TOPLEFT", 0, 0)

    ConROCNoOptions.text = ConROCNoOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    ConROCNoOptions.text:SetPoint("TOPLEFT", ConROCNoOptions, "TOPLEFT", 0, 0)
    ConROCNoOptions.text:SetWidth(ConROCNoOptions:GetWidth())  -- Set the width to match the frame width
    ConROCNoOptions.text:SetText(L["NO_SPELLS_TO_LIST"])
    ConROCNoOptions.text:SetJustifyH("LEFT")
    ConROCNoOptions.text:SetSpacing(2)
    ConROCNoOptions.text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    ConROCNoOptions.text:SetTextColor(1, 1, 1)  -- White color

    ConROCNoOptions:SetHeight(ConROCNoOptions.text:GetHeight())
    ConROCNoOptions:Show()
end

function ConROC_roles(frame)
    local radioButtons = {}
	local roleIconSize = 32;
	local sizeCheck = (math.ceil(frame:GetWidth()-20)/#ConROC_RoleSettingsTable)
    if(sizeCheck <= 34) then
    	roleIconSize = 28;
    elseif (sizeCheck <= 28) then
    	roleIconSize = 24
    end

    local roleSpaceValue = (math.ceil(frame:GetWidth())-20-roleIconSize) / (#ConROC_RoleSettingsTable-1)
    for i, roleData in ipairs(ConROC_RoleSettingsTable) do
        local radioBtn = CreateFrame("CheckButton", roleData.role, frame, "UIRadioButtonTemplate")
        radioBtn:SetSize(roleIconSize, roleIconSize)

        local radioNormalTexture = radioBtn:GetNormalTexture()
        radioNormalTexture:SetTexture(nil)
        radioNormalTexture:SetAlpha(0)

        local radioHighlightTexture = radioBtn:GetHighlightTexture()
        radioHighlightTexture:SetTexture(nil)
        radioHighlightTexture:SetAlpha(0)

        local radioCheckedTexture = radioBtn:GetCheckedTexture()
        radioCheckedTexture:SetTexture(nil)
        radioCheckedTexture:SetAlpha(0)

        radioBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", (10 + (i - 1) * roleSpaceValue), -2)
        radioBtn:SetChecked(ConROCHunterSpells[roleData.role])

        local checkedTexture = radioBtn:CreateTexture(nil, "ARTWORK")
        checkedTexture:SetTexture(roleData.activeTexture)
        checkedTexture:SetBlendMode("BLEND")
        checkedTexture:SetSize(roleIconSize, roleIconSize)
        checkedTexture:SetPoint("CENTER", radioBtn, "CENTER", 0, 0)
        radioBtn:SetCheckedTexture(checkedTexture)

        local uncheckedTexture = radioBtn:CreateTexture(nil, "ARTWORK")
        uncheckedTexture:SetTexture(roleData.disabledTexture)
        uncheckedTexture:SetBlendMode("BLEND")
        uncheckedTexture:SetSize(roleIconSize, roleIconSize)
        uncheckedTexture:SetPoint("CENTER", radioBtn, "CENTER", 0, 0)
        radioBtn:SetNormalTexture(uncheckedTexture)

        radioBtn:SetScript("OnClick", function(self)
            ConROC:setRole(self, roleData, radioButtons)
            ConROC:RoleProfile()
        end)

        local radioText = radioBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        radioText:SetText(roleData.frameName)
        radioText:SetPoint("BOTTOM", radioBtn, "TOP", 0, -5)
        radioBtn.role = roleData.role
        table.insert(radioButtons, radioBtn)
    end
end

function ConROC_OptionsWindow(_table, _roles)
    local _, Class, classId = UnitClass("player")
    local Color = RAID_CLASS_COLORS[Class]
    -- create the child frames and add text to them
    for i = 1, #_table do
        local radioButtonsTable = {}
        local frame = CreateFrame("Frame", "ConROC_CheckHeader"..i, ConROCScrollChild, "BackdropTemplate")
        frame:SetSize(scrollContentWidth, 20)
        if i == 1 then
            frame:SetPoint("TOPLEFT", lastFrame, "TOPLEFT", 0, 0)
        else
            frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -10)
        end
        if debugOptions.header then     
            frame:SetBackdrop({
              bgFile = "Interface\\Buttons\\WHITE8x8",
              nil,
              tile = true, tileSize = 16, edgeSize = 16,
              insets = { left = 0, right = 0, top = 0, bottom = 0 }
            })
            local r, g, b = math.random(), math.random(), math.random()
            frame:SetBackdropColor(r, g, b, 0.5)
        end
        scrollHeight = scrollHeight + math.ceil(frame:GetHeight());
        frame:Show()

        local text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        text:SetPoint("CENTER", frame, "CENTER")
        text:SetText(_table[i].frameName)
        frame.text = text -- store the text object in the frame for later use

        spellFrameHeight = 0;
        local _spellFrame = CreateFrame("Frame", "ConROC_CheckFrame"..i, frame, "BackdropTemplate");
        _spellFrame:SetSize(scrollContentWidth, 5)
        _spellFrame:SetPoint("TOPLEFT", "ConROC_CheckHeader"..i, "BOTTOMLEFT", 0, 0)
        if debugOptions.spells then
            _spellFrame:SetBackdrop({
              bgFile = "Interface\\Buttons\\WHITE8x8",
              nil,
              tile = true, tileSize = 16, edgeSize = 16,
              insets = { left = 0, right = 0, top = 0, bottom = 0 }
            })
            local r, g, b = math.random(), math.random(), math.random()
            _spellFrame:SetBackdropColor(r, g, b, 0.5)
        end
        lastFrame = _spellFrame;
        scrollHeight = scrollHeight + 5;

        local _spells = _table[i].spells
        for j = 1, #_spells do
            local _spellData = _spells[j]
            if _spellData.type == "spell" or _spellData.type == "poison" then
                if _table[i].groupType == "radioButtons" then
                    ConROC:OptionRadioButtonSpell(_spellData, i, j, _spellFrame, radioButtonsTable);
                else
                    ConROC:OptionCheckboxSpell(_spellData, i, j, _spellFrame);
                end
            elseif _spellData.type == "custom" then
                ConROC:CustomOption(_spellData, i, j, _spellFrame);
            elseif _spellData.type == "textfield" then
                ConROC:OptionTextfield(_spellData, i, j, _spellFrame);
            elseif _spellData.type == "aoetoggler" then
                ConROC:OptionAoE(_spellData, i, j, _spellFrame);
            elseif _spellData.type == "none" then
                if _table[i].groupType == "radioButtons" then
                    ConROC:OptionNone(_spellData, i, j, _spellFrame, _table[i].groupType, radioButtonsTable);
                else
                    ConROC:OptionNone(_spellData, i, j, _spellFrame);
                end
            end
            _spellFrame:SetHeight(spellFrameHeight);
            frame:Show();
        end
    end
    ConROCScrollChild:SetHeight(scrollHeight);
end

function ConROC:OptionCheckboxSpell(_spellData, i, j, _spellFrame)
	--spell start
	local spellName, _, spellTexture = GetSpellInfo(_spellData.spellID)
	local oItem = CreateFrame("CheckButton", "ConROC_SM_".._spellData.spellCheckbox, _spellFrame, "UICheckButtonTemplate");
	local oItemtext = oItem:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");		
	if j == 1 then
		oItem:SetPoint("TOPLEFT", lastFrame, "TOPLEFT", 0, 0);
	else
		oItem:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, 0);
	end
	lastFrame = oItem;
	oItem:SetSize(20,20)
	ConROC:setRoleChecked(_spellData, oItem)

	oItem:SetScript("OnClick",
		function(self)
			ConROC:setRoleSpellClicked(_spellData, self)
		end);
	-- static
	oItemtext:SetText(spellName);
	local c1t = oItem.texture;
	if not c1t then
		c1t = oItem:CreateTexture('CheckFrame'..j..'_check'..j..'_Texture', 'ARTWORK');
		c1t:SetTexture(spellTexture);
		c1t:SetBlendMode('BLEND');
		oItem.texture = c1t;
	end
	c1t:SetSize(20,20)
	c1t:SetPoint("LEFT", oItem, "RIGHT", 2, 0);
	oItemtext:SetPoint('LEFT', c1t, 'RIGHT', 4, 0);

	scrollHeight = scrollHeight + math.ceil(lastFrame:GetHeight());
	spellFrameHeight = spellFrameHeight + math.ceil(lastFrame:GetHeight());
	lastFrame:Show();
	--spell end
end

function ConROC:OptionRadioButtonSpell(_spellData, i, j, _spellFrame, _radioButtonsTable)
	--spell start
	local spellName, _, spellTexture;
	if type(_spellData.spellID) == "number" then
		spellName, _, spellTexture = GetSpellInfo(_spellData.spellID)
	else
		spellName, spellTexture = _spellData.spellID, nil;
	end
	local myFrame = "ConROC_SM_".._spellData.spellCheckbox
	local oItem = CreateFrame("CheckButton", myFrame, _spellFrame, "UIRadioButtonTemplate");
	local oItemtext = oItem:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
	if j == 1 then
		oItem:SetPoint("TOPLEFT", lastFrame, "TOPLEFT", 0, 0);
	else
		oItem:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, 0);
	end
	lastFrame = oItem;
	oItem:SetSize(20,20)

	ConROC:setRoleChecked(_spellData, oItem)
	oItem.spellCheckbox = _spellData.spellCheckbox
	_radioButtonsTable[j] = oItem;

	oItem:SetScript("OnClick",
		function(self)
			local role, checkboxName, frameName = ConROC:checkActiveRole()
			for _, radioButton in ipairs(_radioButtonsTable) do
				if radioButton ~= self then
					radioButton:SetChecked(false)
					ConROCHunterSpells[checkboxName .. radioButton.spellCheckbox] = radioButton:GetChecked()
				else
					-- Perform any additional logic based on the selected button
					self:SetChecked(true)
					ConROCHunterSpells[checkboxName .. radioButton.spellCheckbox] = self:GetChecked()
				end
			end
		end);
	oItemtext:SetText(spellName);
	local c1t = oItem.texture;
	if not c1t then
		c1t = oItem:CreateTexture('CheckFrame'..j..'_check'..j..'_Texture', 'ARTWORK');
		c1t:SetTexture(spellTexture);
		c1t:SetBlendMode('BLEND');
		oItem.texture = c1t;
	end
	c1t:SetSize(20,20)
	c1t:SetPoint("LEFT", oItem, "RIGHT", 2, 0);
	if type(_spellData.spellID) == "number" then
		oItemtext:SetPoint('LEFT', c1t, 'RIGHT', 4, 0);
	else				
		oItemtext:SetPoint('LEFT', oItem, 'RIGHT', 26, 0);
	end
	_G[myFrame] = oItem
	scrollHeight = scrollHeight + math.ceil(lastFrame:GetHeight());
	spellFrameHeight = spellFrameHeight + math.ceil(lastFrame:GetHeight());
	lastFrame:Show();
	--spell end
end

function ConROC:OptionTextfield(_spellData, i, j, _spellFrame)
	local oItem = CreateFrame("Frame", "ConROC_SM_".._spellData.spellCheckbox.."Frame", _spellFrame,"BackdropTemplate");
	oItem:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", tile = true, tileSize = 16, insets = {left = 0, right = 0, top = 0, bottom = 0},});
	oItem:SetBackdropColor(0, 0, 0);
	if j == 1 then
		oItem:SetPoint("TOPLEFT", lastFrame, "TOPLEFT", 0, 0);
	else
		oItem:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, 0);
	end
	lastFrame = oItem;
	oItem:SetSize(20, 20);

	local box1 = CreateFrame("EditBox", "ConROC_SM_".._spellData.spellCheckbox, oItem);
	box1:SetPoint("TOP", 0, 0);
	box1:SetPoint("BOTTOM", 0, 0);
	box1:SetMultiLine(false);
	box1:SetFontObject(GameFontNormalSmall);
	box1:SetNumeric(true);
	box1:SetAutoFocus(false);
	box1:SetMaxLetters("2");
	box1:SetWidth(20);
	box1:SetTextInsets(3, 0, 0, 0);

	ConROC:setRoleChecked(_spellData, box1)
	box1:SetScript("OnEditFocusLost",
		function()
			ConROC:setRoleSpellClicked(_spellData, box1)
			box1:ClearFocus()
		end);
	box1:SetScript("OnEnterPressed",
		function()
			ConROC:setRoleSpellClicked(_spellData, box1)
			box1:ClearFocus()
		end);
	box1:SetScript("OnEscapePressed",
		function()
			ConROC:setRoleSpellClicked(_spellData, box1)
			box1:ClearFocus()
		end);

	local e1t = oItem:CreateTexture('CheckFrame2_oItem_Texture', 'ARTWORK');
	e1t:SetTexture(GetItemIcon(_spellData.icon));
	e1t:SetBlendMode('BLEND');
	e1t:SetSize(20,20);
	e1t:SetPoint("LEFT", oItem, "LEFT", 20, 0);

	local oItemtext = oItem:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
	if(_spellData.customName) then
		oItemtext:SetText(_spellData.customName);
	else
		oItemtext:SetText(_spellData.spellID);
	end
	oItemtext:SetPoint('LEFT', e1t, 'RIGHT', 5, 0);

	spellFrameHeight = spellFrameHeight + math.ceil(lastFrame:GetHeight());
	scrollHeight = scrollHeight + lastFrame:GetHeight();
	lastFrame:Show();
end

function ConROC:CustomOption(_spellData, i, j, _spellFrame)
	local spellName, _, spellTexture = GetSpellInfo(_spellData.spellID)
	local oItem = CreateFrame("CheckButton", "ConROC_SM_".._spellData.spellCheckbox, _spellFrame, "UICheckButtonTemplate");
	local oItemtext = oItem:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
	if j == 1 then
		oItem:SetPoint("TOPLEFT", lastFrame, "TOPLEFT", 0, 0);
	else
		oItem:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, 0);
	end
	lastFrame = oItem;
	oItem:SetSize(20,20)
	ConROC:setRoleChecked(_spellData, oItem)

	oItem:SetScript("OnClick", 
		function(self)
			ConROC:setRoleSpellClicked(_spellData, self)
		end);
	-- static
	oItemtext:SetText(_spellData.customName);
	local c1t = oItem.texture;
	if not c1t then
		c1t = oItem:CreateTexture('CheckFrame'..j..'_check'..j..'_Texture', 'ARTWORK');
		c1t:SetTexture(spellTexture);
		c1t:SetBlendMode('BLEND');
		oItem.texture = c1t;
	end
	c1t:SetSize(20,20)
	c1t:SetPoint("LEFT", oItem, "RIGHT", 2, 0);
	oItemtext:SetPoint('LEFT', c1t, 'RIGHT', 4, 0);

	scrollHeight = scrollHeight + math.ceil(lastFrame:GetHeight());
	spellFrameHeight = spellFrameHeight + math.ceil(lastFrame:GetHeight());
	lastFrame:Show();
end

function ConROC:OptionAoE(_spellData, i, j, _spellFrame)
	local myFrame = "ConROC_SM_".._spellData.spellCheckbox
	local oItem = CreateFrame("CheckButton", myFrame, _spellFrame, "UICheckButtonTemplate");
	local oItemtext = oItem:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");		
	if j == 1 then
		oItem:SetPoint("TOPLEFT", lastFrame, "TOPLEFT", 0, 0);
	else
		oItem:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, 0);
	end
	lastFrame = oItem;
	oItem:SetSize(20,20)
	ConROC:setRoleChecked(_spellData, oItem)
	if ConROC:CheckBox(ConROC_SM_Option_AoE) then
		ConROCButtonFrame:Show();
		if ConROC.db.profile.unlockWindow then
			ConROCToggleMover:Show();					
		else
			ConROCToggleMover:Hide();					
		end
	else
		ConROCButtonFrame:Hide();
		ConROCToggleMover:Hide();
	end

	oItem:SetScript("OnClick",
		function(self)
			ConROC:setRoleSpellClicked(_spellData, self)
			if ConROC:CheckBox(ConROC_SM_Option_AoE) then
				ConROCButtonFrame:Show();
				if ConROC.db.profile.unlockWindow then
					ConROCToggleMover:Show();					
				else
					ConROCToggleMover:Hide();					
				end					
			else
				ConROCButtonFrame:Hide();
				ConROCToggleMover:Hide();
			end
		end);
	oItemtext:SetText(_spellData.spellID);
	oItemtext:SetPoint('LEFT', oItem, 'RIGHT', 26, 0);
	_G[myFrame] = oItem;
	scrollHeight = scrollHeight + math.ceil(lastFrame:GetHeight());
	spellFrameHeight = spellFrameHeight + math.ceil(lastFrame:GetHeight());
	lastFrame:Show();
end

function ConROC:OptionNone(_spellData, i, j, _spellFrame, _checkType, _radioButtonsTable)
    _checkType = _checkType or nil
    _radioButtonsTable = _radioButtonsTable or nil
    local myFrame = "ConROC_SM_".._spellData.spellCheckbox
    local oItem;

    if _checkType == "radioButtons" then
        oItem = CreateFrame("CheckButton", myFrame, _spellFrame, "UIRadioButtonTemplate");
    else
        oItem = CreateFrame("CheckButton", myFrame, _spellFrame, "UICheckButtonTemplate");
    end
    local oItemtext = oItem:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");     
    if j == 1 then
        oItem:SetPoint("TOPLEFT", lastFrame, "TOPLEFT", 0, 0);
    else
        oItem:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, 0);
    end
    lastFrame = oItem;
    oItem:SetSize(20,20)
    ConROC:setRoleChecked(_spellData, oItem)
    if _checkType == "radioButtons" then
        oItem.spellCheckbox = _spellData.spellCheckbox
        _radioButtonsTable[j] = oItem;
        oItem:SetScript("OnClick", 
        function(self)
            local role, checkboxName, frameName = ConROC:checkActiveRole()
            for _, radioButton in ipairs(_radioButtonsTable) do
                if radioButton ~= self then
                    radioButton:SetChecked(false)
                    ConROCHunterSpells[checkboxName .. radioButton.spellCheckbox] = radioButton:GetChecked()
                else
                    -- Perform any additional logic based on the selected button
                    self:SetChecked(true)
                    ConROCHunterSpells[checkboxName .. radioButton.spellCheckbox] = self:GetChecked()
                end
            end
        end);
    else
        oItem:SetScript("OnClick", 
        function(self)          
            ConROC:setRoleSpellClicked(_spellData, self)
        end);
    end

    oItemtext:SetText(_spellData.spellID);
    oItemtext:SetPoint('LEFT', oItem, 'RIGHT', 26, 0);
    _G[myFrame] = oItem;
    scrollHeight = scrollHeight + math.ceil(lastFrame:GetHeight());
    spellFrameHeight = spellFrameHeight + math.ceil(lastFrame:GetHeight());
    lastFrame:Show();
end

function ConROC:SpellMenuUpdate(newSpell)
	ConROC:RotationChoices();

    lastFrame = ConROCScrollChild;
    local anyHLVisible = false;
    scrollHeight = 0;
    local _table = ConROC_RotationSettingsTable;
    local firstHeadline = 1;
    for i = 1, #_table do
            local anyChildVisible = false;
            local frame = _G["ConROC_CheckHeader"..i]
            if i == firstHeadline then
                frame:SetPoint("TOPLEFT", lastFrame, "TOPLEFT", 0, 0)
            else
                frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -10)
                --scrollHeight = scrollHeight + 10;
            end
            --scrollHeight = scrollHeight + math.ceil(frame:GetHeight());
            frame:Show()

            local spellFrameHeight = 0;
            local _spellFrame = _G["ConROC_CheckFrame"..i];
            _spellFrame:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 0);
            local lFrame = _spellFrame;
            local _spells = _table[i].spells
            local firstItem = 1;
            for j = 1, #_spells do
                local _spellData = _spells[j]
                if _spellData.type == "spell" then
                    local spellName, _, spellTexture = GetSpellInfo(_spellData.spellID)
                    local oItem = _G["ConROC_SM_".._spellData.spellCheckbox]
                    if j == firstItem then
                        oItem:SetPoint("TOPLEFT", lFrame, "TOPLEFT", 0, 0);
                    else
                        oItem:SetPoint("TOPLEFT", lFrame, "BOTTOMLEFT", 0, 0);
                    end
                    if type(_spellData.spellID) == "number" then
                        if plvl >= _spellData.reqLevel and (IsSpellKnown(_spellData.spellID) or IsSpellKnownOrOverridesKnown(_spellData.spellID)) then
                            lFrame = oItem;
                            lFrame:Show();
                            if oItem:IsShown() then
                                anyChildVisible = true;
                                scrollHeight = scrollHeight + math.ceil(lFrame:GetHeight());
                                spellFrameHeight = spellFrameHeight + math.ceil(oItem:GetHeight());
                            end
                        else
                            if j == firstItem then
                                if j == #_spells then
                                    --print("all section spells hidden")
                                else
                                    firstItem = j + 1;
                                end
                            end
                            oItem:Hide()
                            --print("Hide spell", spellName)
                        end
                    end
                --spell end
                elseif _spellData.type == "poison" then
                    local spellName = _spellData.spellID.name;
                    local oItem = _G["ConROC_SM_".._spellData.spellCheckbox]
                    if j == firstItem then
                        oItem:SetPoint("TOPLEFT", lFrame, "TOPLEFT", 0, 0);
                    else
                        oItem:SetPoint("TOPLEFT", lFrame, "BOTTOMLEFT", 0, 0);
                    end
                    if type(_spellData.spellID.id) == "number" then
                        if plvl >= _spellData.reqLevel then --and IsSpellKnown(_spellData.spellID) then
                            lFrame = oItem;
                            scrollHeight = scrollHeight + math.ceil(lFrame:GetHeight());
                            spellFrameHeight = spellFrameHeight + math.ceil(oItem:GetHeight());
                            lFrame:Show();
                            allHidden = false;
                        else
                            if j == firstItem then
                                if j == #_spells then
                                    --print("all section spells hidden")
                                else
                                    firstItem = j + 1;
                                end
                            end
                            --print("Hiding", spellName)
                            oItem:Hide()
                        end
                    else
                        scrollHeight = scrollHeight + math.ceil(lFrame:GetHeight());
                        spellFrameHeight = spellFrameHeight + math.ceil(oItem:GetHeight());
                    end
                elseif _spellData.type == "aoetoggler" then
                    local spellName, _, spellTexture = GetSpellInfo(_spellData.spellID)
                    local oItem = _G["ConROC_SM_".._spellData.spellCheckbox]
                    if j == firstItem then
                        oItem:SetPoint("TOPLEFT", lFrame, "TOPLEFT", 0, 0);
                    else
                        oItem:SetPoint("TOPLEFT", lFrame, "BOTTOMLEFT", 0, 0);
                    end
                    if plvl >= _spellData.reqLevel then
                        lFrame = oItem;
                        lFrame:Show();
                            if oItem:IsShown() then
                                anyChildVisible = true;
                                scrollHeight = scrollHeight + math.ceil(lFrame:GetHeight());
                                spellFrameHeight = spellFrameHeight + math.ceil(oItem:GetHeight());
                            end
                    else
                        if j == firstItem then
                            if j == #_spells then
                                --print("all section spells hidden")
                            else
                                firstItem = j + 1;
                            end
                        end
                        oItem:Hide()
                    end
                elseif _spellData.type == "textfield" then
                    local oItem = _G["ConROC_SM_".._spellData.spellCheckbox.."Frame"]
                    if j == firstItem then
                        oItem:SetPoint("TOPLEFT", lFrame, "TOPLEFT", 0, 0);
                    else
                        oItem:SetPoint("TOPLEFT", lFrame, "BOTTOMLEFT", 0, 0);
                    end
                    if plvl >= _spellData.reqLevel and (IsSpellKnown(_spellData.spellID) or IsSpellKnownOrOverridesKnown(_spellData.spellID)) then
                        lFrame = oItem;
                        lFrame:Show();
                            if oItem:IsShown() then
                                anyChildVisible = true;
                                scrollHeight = scrollHeight + math.ceil(lFrame:GetHeight());
                                spellFrameHeight = spellFrameHeight + math.ceil(oItem:GetHeight());
                            end
                    else
                        if j == firstItem then
                            if j == #_spells then
                                --print("all section spells hidden")
                            else
                                firstItem = j + 1;
                            end
                        end
                        oItem:Hide()
                    end
                elseif _spellData.type == "custom" then
					--local spellName, _, spellTexture = GetSpellInfo(_spellData.spellID)
					local oItem = _G["ConROC_SM_".._spellData.spellCheckbox]
					if j == firstItem then
						oItem:SetPoint("TOPLEFT", lFrame, "TOPLEFT", 0, 0);
					else
						oItem:SetPoint("TOPLEFT", lFrame, "BOTTOMLEFT", 0, 0);
					end
					if plvl >= _spellData.reqLevel then
						lFrame = oItem;
						scrollHeight = scrollHeight + math.ceil(lFrame:GetHeight());
						spellFrameHeight = spellFrameHeight + math.ceil(oItem:GetHeight());
						lFrame:Show();
                        anyChildVisible = true;
					else
						if j == firstItem then
							if j == #_spells then
								--print("all section spells hidden")
							else
								firstItem = j + 1;
							end
						end
						--print("Hiding", spellName)
						oItem:Hide()
					end
                elseif _spellData.type == "none" then
                    local spellName, _, spellTexture = GetSpellInfo(_spellData.spellID)
                    local oItem = _G["ConROC_SM_".._spellData.spellCheckbox]
                    if j == firstItem then
                        oItem:SetPoint("TOPLEFT", lFrame, "TOPLEFT", 0, 0);
                    else
                        oItem:SetPoint("TOPLEFT", lFrame, "BOTTOMLEFT", 0, 0);
                    end
                    if plvl >= _spellData.reqLevel and anyChildVisible then
                        lFrame = oItem;
                        oItem:Show();
                    else
                        oItem:Hide();
                    end                    
                    if oItem:IsShown() then
                        --anyChildVisible = true;
                        scrollHeight = scrollHeight + math.ceil(lFrame:GetHeight());
                        spellFrameHeight = spellFrameHeight + math.ceil(oItem:GetHeight());
                    end
                end
                if anyChildVisible then
                    lastFrame = _spellFrame;
                    _spellFrame:SetHeight(spellFrameHeight);
                end
            end

            if anyChildVisible then
                    --print("-- FRAME to show", frame:GetName())
                    if i > firstHeadline then scrollHeight = scrollHeight + 10; end
                    scrollHeight = scrollHeight + math.ceil(frame:GetHeight());
                    frame:Show();
                    anyHLVisible = true;
                else
                    --print("-- FRAME to hide", frame:GetName())
                    frame:Hide();
                    if i == firstHeadline then
                        firstHeadline = i +1;
                    end
                end
        end
        if not anyHLVisible then
            ConROC_NoOptionsFrame();
            ConROC_NoOptions:Show();
            scrollHeight = ConROCNoOptions:GetHeight()
        else
            if ConROCNoOptions then
                ConROC_NoOptions:Hide();
            end
        end

        ConROCScrollChild:SetHeight(scrollHeight);

    -- Update for scrolling window -- Start
    if fixOptionsWidth then
        ConROCSpellmenuFrame:SetWidth(frameWidth);
        CheckScrollbarVisibility()
        ConROCScrollContainer:Show();
        ConROCScrollChild:Show();
    end
end

function ConROC:RoleProfile()
	local activeRole, _, frameName = ConROC:checkActiveRole()

	if ConROC:CheckBox(activeRole) then
	    for _, rotationSettings in ipairs(ConROC_RotationSettingsTable) do
	        for _, spellData in ipairs(rotationSettings.spells) do
	            local spellCheckbox = spellData.spellCheckbox
	            local checkboxName = "ConROC_SM_" .. spellCheckbox
	            local spellName = "ConROC_" .. frameName .. "_" .. spellCheckbox
	            if ConROCHunterSpells[spellName] ~= nil then --and 
	            	if type(ConROCHunterSpells[spellName]) == "boolean" then
	                	_G["ConROC_SM_" .. spellCheckbox]:SetChecked(ConROCHunterSpells[spellName])
	                elseif type(ConROCHunterSpells[spellName]) == "number" then
	                	_G["ConROC_SM_" .. spellCheckbox]:SetNumber(ConROCHunterSpells[spellName])
                	end
            	end
	        end
	    end

	    if ConROC:CheckBox(ConROC_SM_Option_AoE) then
	        ConROCButtonFrame:Show()
	        if ConROC.db.profile.unlockWindow then
	            ConROCToggleMover:Show()
	        else
	            ConROCToggleMover:Hide()
	        end
	    else
	        ConROCButtonFrame:Hide()
	        ConROCToggleMover:Hide()
	    end
	end
end