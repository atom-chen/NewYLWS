
local table_insert = table.insert
local table_sort = table.sort
local string_len = string.len
local string_trim = string.trim
local math_ceil = math.ceil

local ConfigUtil = ConfigUtil
local GameUtility = CS.GameUtility
local GameObject = CS.UnityEngine.GameObject
local GuildIconItem = require "UI.Guild.View.GuildIconItem"
local GuildMgr = Player:GetInstance().GuildMgr
local CommonDefine = CommonDefine

local UIGuildCreateView = BaseClass("UIGuildCreateView", UIBaseView)
local base = UIBaseView


function UIGuildCreateView:OnCreate()
    base.OnCreate(self)

    self.m_guildIconList = {}
    self.m_currSelectItem = false

    self:InitView()
    self:HandleClick()
end

function UIGuildCreateView:InitView()

    local tabTitle2Text, nameText, declarationText,
    declarationInputPlaceholder, guildNameInputPlaceholder, cancelBtnText

    self.m_tabTitleText, tabTitle2Text, self.m_titleText, 
    nameText, declarationText, declarationInputPlaceholder, guildNameInputPlaceholder, cancelBtnText, self.m_createBtnText,
    self.m_yuanbaoText = UIUtil.GetChildTexts(self.transform, {
        "Container/TabTitle/TabTitleText",
        "Container/TabTitle2/TabTitle2Text",
        "Container/TitleText",
        "Container/NameText",
        "Container/Declaration/DeclarationText",
        "Container/Declaration/DeclarationInput/Placeholder",
        "Container/NameText/GuildNameInput/Placeholder",
        "Container/Cancel_BTN/CancelBtnText",
        "Container/Create_BTN/CreateBtnText",
        "Container/YuanbaoText"
    })

    tabTitle2Text.text = Language.GetString(1321)
    nameText.text = Language.GetString(1315)
    declarationText.text = Language.GetString(1310)
    cancelBtnText.text = Language.GetString(50)
    declarationInputPlaceholder.text = Language.GetString(1322)
    guildNameInputPlaceholder.text = Language.GetString(1323)
    
    self.m_itemContent, self.m_cancelBtn, self.m_createBtn, self.m_closeBtn,
    self.m_yuanbaoTextTr = UIUtil.GetChildTransforms(self.transform, {
        "Container/ItemScrollView/Viewport/ItemContent",
        "Container/Cancel_BTN",
        "Container/Create_BTN",
        "CloseBtn",
        "Container/YuanbaoText"
    })

    self.m_guildNameInput = self:AddComponent(UIInput, "Container/NameText/GuildNameInput")
    self.m_declarationInput = self:AddComponent(UIInput, "Container/Declaration/DeclarationInput")

    self.m_smallGuildIconImage = self:AddComponent(UIImage, "Container/SmallIcon/GuildIconImage", AtlasConfig.DynamicLoad2)
    self.m_bigGuildIconImage = self:AddComponent(UIImage, "Container/BigIcon/GuildIconImage2", AtlasConfig.DynamicLoad2)
end

function UIGuildCreateView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_cancelBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_createBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)

    base.OnDestroy(self)
end

function UIGuildCreateView:OnAddListener()
    base.OnAddListener(self)

    self:AddUIListener(UIMessageNames.MN_GUILD_RSP_SETTING, self.SaveGuildInfo)
end

function UIGuildCreateView:OnRemoveListener()
    base.OnRemoveListener(self)

    self:RemoveUIListener(UIMessageNames.MN_GUILD_RSP_SETTING, self.SaveGuildInfo)
end

function UIGuildCreateView:SaveGuildInfo()
    self:CloseSelf()
end

function UIGuildCreateView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
   
    UIUtil.AddClickEvent(self.m_cancelBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_createBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
end

function UIGuildCreateView:OnEnable(...)
    base.OnEnable(self, ...)
   
    local order,data = ...

    self.m_titleText.text = data[1]             --标题
    self.m_tabTitleText.text = data[1]          --下方标题
    self.m_createBtnText.text = data[2]         --完成按钮名
    self.m_guildNameInput:SetText(data[3])      --原军团名(作为修改信息时)
    self.m_declarationInput:SetText(data[4])    --原军团宣言(作为修改信息时)
    
    if self.m_createBtnText.text == Language.GetString(1417) then
        self.m_yuanbaoTextTr.gameObject:SetActive(false)
    elseif self.m_createBtnText.text == Language.GetString(1320) then
        self.m_yuanbaoTextTr.gameObject:SetActive(true)
    end

    local guild_icon_list = ConfigUtil.GetConfigTbl("Config.Data.lua_guild_icon")
    if not guild_icon_list then
        return
    end

    local cfgIDlist = {}
    for k, v in pairs(guild_icon_list) do 
        table_insert(cfgIDlist, k)
    end

    table_sort(cfgIDlist, function(a, b)
		return a < b
    end)

    local function itemOnClick(item)
        if not item then
            return
        end

        if not self.m_currSelectItem then
            self.m_currSelectItem = item
            self.m_currSelectItem:SetOnSelectState(true)
        else
            if self.m_currSelectItem ~= item then 
                self.m_currSelectItem:SetOnSelectState(false)
                self.m_currSelectItem = item
                self.m_currSelectItem:SetOnSelectState(true)
            end
        end

        self:UpdateIcon(self.m_currSelectItem:GetIconID())
    end

    self.m_seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
    UIGameObjectLoader:GetInstance():GetGameObjects(self.m_seq, TheGameIds.GuildIconItemPrefab, #cfgIDlist, function(objs)
        if objs then
            for i, v in ipairs(cfgIDlist) do
                local go = objs[i]
                if go then
                    local guildIconItem = GuildIconItem.New(go, self.m_itemContent)
                    table_insert(self.m_guildIconList, guildIconItem)
                    guildIconItem:UpdateData(v, i == 1, itemOnClick)

                    if i == 1 then
                        self.m_currSelectItem = guildIconItem
                    end
                end
            end
            self:UpdateIcon(cfgIDlist[1])
        end
    end)
    local settingData = Player:GetInstance():GetUserMgr():GetSettingData()
    self.m_yuanbaoText.text = math_ceil(settingData.create_guild_need_yuanbao)
end

function UIGuildCreateView:UpdateIcon(iconID)
    local guildIconCfg = ConfigUtil.GetGuildIconCfgByID(iconID)
    if guildIconCfg then
        if self.m_smallGuildIconImage then
            self.m_smallGuildIconImage:SetAtlasSprite(guildIconCfg.icon..".png")
        end
        if self.m_bigGuildIconImage then
            self.m_bigGuildIconImage:SetAtlasSprite(guildIconCfg.icon..".png")
        end
    end
end

function UIGuildCreateView:OnDisable(...)

    if self.m_guildIconList then
        for i, v in ipairs(self.m_guildIconList) do
            v:Delete()
        end
        self.m_guildIconList = {}
    end

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_seq)
    self.m_seq = 0

    base.OnDisable(self)
end


function UIGuildCreateView:OnClick(go, x, y)
    if go.name == "Cancel_BTN" then
        self:CloseSelf()

    elseif go.name == "CloseBtn" then
        self:CloseSelf()

    elseif go.name == "Create_BTN" then
        local nameText = string_trim(self.m_guildNameInput:GetText())
        if nameText == "" then
            UILogicUtil.FloatAlert(Language.GetString(1324))
            return
        end

        local nameLength = GameUtility.GetNameLength(nameText)
        if nameLength <= 2 then
            UILogicUtil.FloatAlert(Language.GetString(1325))
            return
        end

        local declarationText = string_trim(self.m_declarationInput:GetText())
        
        if self.m_currSelectItem then
            if self.m_createBtnText.text == Language.GetString(1320) then
                GuildMgr:ReqCreateGuild(nameText, self.m_currSelectItem:GetIconID(), declarationText)
            elseif self.m_createBtnText.text == Language.GetString(1417) then
                GuildMgr:ReqSetting(1, nameText, declarationText,  self.m_currSelectItem:GetIconID())
            end
        end

    end
end

return UIGuildCreateView