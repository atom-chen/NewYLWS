local UIUserDetailView = BaseClass("UIUserDetailView", UIBaseView)
local base = UIBaseView
local UIUtil = UIUtil
local Vector3 = Vector3
local UIImage = UIImage
local TheGameIds = TheGameIds
local math_ceil = math.ceil
local ConfigUtil = ConfigUtil
local AtlasConfig = AtlasConfig
local Language = Language

local UIWuJiangCardItem = require "UI.UIWuJiang.View.UIWuJiangCardItem"
local CardItemPath = TheGameIds.CommonWujiangCardPrefab

local string_format = string.format
local string_trim = string.trim
local table_insert = table.insert

local UserItem = require "UI.UIUser.UserItem"

local UserItemScale = Vector3.New(1.2, 1.2, 1)
local WujiangCardScale = Vector3.New(0.9, 0.95, 1)
local WujiangCardPosList = {
    Vector3.New(68.4, -88.7, 0),
    Vector3.New(213, -88.7, 0),
    Vector3.New(357.8, -88.7, 0),
    Vector3.New(501, -88.7, 0),
    Vector3.New(645.3, -88.7, 0),
}

function UIUserDetailView:OnCreate()
    base.OnCreate(self)
    
    self.m_userIconSeq = 0
    self.m_userIconItem = nil
    self.m_userDetailParam = nil

    self.m_wujiang_card_list = {}
    self.m_wujiangCardSeq = 0

    self.m_lastSignature = ''

    self:InitView()
end
function UIUserDetailView:InitView()

    self.m_closeBtn, self.m_backBtn, self.m_headRoot, self.m_battleArrayContent, self.m_arenaRankTr
     = UIUtil.GetChildTransforms(self.transform, {
        "closeBtn", "contentPanel/TopContent/titleBg/backBtn",
        "contentPanel/TopContent/headIconRoot",
        "contentPanel/BottomContent/battleArrayContent",
        "contentPanel/TopContent/rightContent/arena/arenaRankText",
    })

    self.m_inputField = self:AddComponent(UIInput, "contentPanel/MidContent/InputField")


    local titleText, serverText, achieveText, arenaText, militaryText, placeholderText, battleArrayText

    titleText, self.m_playerNameText, self.m_guildNameText, self.m_guildJobText,
    serverText, self.m_serverIdText, achieveText, arenaText, militaryText,
    self.m_arenaRankText, self.m_militaryNumText, battleArrayText,
    self.m_powerText, self.m_achieveNumText, self.m_placeholderText
     = UIUtil.GetChildTexts(self.transform, {
        "contentPanel/TopContent/titleBg/titleText",
        "contentPanel/TopContent/VipV/PlayerNameText",
        "contentPanel/TopContent/guildBg/guildText",
        "contentPanel/TopContent/guildBg/guildJobText",
        "contentPanel/TopContent/serverText",
        "contentPanel/TopContent/serverText/serverIdText",
        "contentPanel/TopContent/rightContent/achieve/achieveText",
        "contentPanel/TopContent/rightContent/arena/arenaText",
        "contentPanel/TopContent/rightContent/military/militaryText",
        "contentPanel/TopContent/rightContent/arena/arenaRankText",
        "contentPanel/TopContent/rightContent/military/militaryNumText",
        "contentPanel/BottomContent/battleArrayText",
        "contentPanel/BottomContent/PowerBg/PowerText",
        "contentPanel/TopContent/rightContent/achieve/numText",
        "contentPanel/MidContent/InputField/PlaceholderText",
    })

    self.m_vipLevelImage = self:AddComponent(UIImage, "contentPanel/TopContent/VipV/VipLevelImage", AtlasConfig.DynamicLoad)
    self.m_vipLevelImage2 = self:AddComponent(UIImage, "contentPanel/TopContent/VipV/VipLevelImage2", AtlasConfig.DynamicLoad)
    self.m_guildIconImage = self:AddComponent(UIImage, "contentPanel/TopContent/guildBg/guildImage", AtlasConfig.DynamicLoad2)
    self.m_arenaImage = self:AddComponent(UIImage, "contentPanel/TopContent/rightContent/arena/arenaImage")
    self.m_militaryImage = self:AddComponent(UIImage, "contentPanel/TopContent/rightContent/military/militaryImage", AtlasConfig.DynamicLoad)
    self.m_postImage = UIUtil.AddComponent(UIImage, self, "contentPanel/TopContent/guildBg/bgImage", AtlasConfig.DynamicLoad)

    titleText.text = Language.GetString(1551)
    serverText.text = Language.GetString(1552)
    achieveText.text = Language.GetString(1553)
    arenaText.text = Language.GetString(1554)
    militaryText.text = Language.GetString(1555)
    self.m_placeholderText.text = Language.GetString(1556)
    battleArrayText.text = Language.GetString(1557)

end

function UIUserDetailView:OnAddListener()
    base.OnAddListener(self)
    --UI消息注册
    self:AddUIListener(UIMessageNames.MN_USER_DETAIL, self.UpdateInfo)
end 

function UIUserDetailView:OnRemoveListener()
    base.OnRemoveListener(self)
    --消息注销
    self:RemoveUIListener(UIMessageNames.MN_USER_DETAIL, self.UpdateInfo)
end

function UIUserDetailView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
end

function UIUserDetailView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
end

function UIUserDetailView:OnClick(go)
    if go.name == "closeBtn" or go.name == "backBtn" then 
        if Player:GetInstance():GetUserMgr():CheckIsSelf(self.m_userDetailParam.userBrief.uid) then
            local nowInput = self.m_inputField:GetText()
            if nowInput ~= '' and self.m_lastSignature ~= nowInput then
                Player:GetInstance():GetUserMgr():ReqSetSignature(nowInput)
            end
        end

        self:CloseSelf()
    end
end

function UIUserDetailView:OnEnable(...)
    base.OnEnable(self, ...)
    local _, uid = ...
    self:HandleClick()
    
    local UserManager = Player:GetInstance():GetUserMgr()
    uid = uid or UserManager:GetUserData().uid
    UserManager:ReqUserDetail(uid)
end

function UIUserDetailView:OnDisable()
    base.OnDisable(self)
    self:RemoveClick()

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_userIconSeq)
    self.m_userIconSeq = 0
    if self.m_userIconItem then
        self.m_userIconItem:SetLocalScale(Vector3.one)
        self.m_userIconItem:Delete()
        self.m_userIconItem = nil
    end

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_wujiangCardSeq)
    self.m_wujiangCardSeq = 0

    for _, item in pairs(self.m_wujiang_card_list) do
        item:SetLocalScale(Vector3.one)
        item:Delete()
    end
    self.m_wujiang_card_list = {}

    self.m_lastSignature = ''
    self.m_userDetailParam = nil
end

function UIUserDetailView:OnDestroy()
    base.OnDestroy(self)
end

function UIUserDetailView:UpdateVip(vip)
   
    UILogicUtil.SetVipImage(vip, self.m_vipLevelImage, self.m_vipLevelImage2)
end

function UIUserDetailView:UpdateInfo(userDetailParam)
    self.m_userDetailParam = userDetailParam

    self:UpdateBrief()
    self:UpdateSignature()
    self:UpdateHonor()
    self:UpdateDefList()
end

function UIUserDetailView:UpdateBrief()
    local userBrief = self.m_userDetailParam.userBrief

    if self.m_userIconItem == nil then
        if self.m_userIconSeq == 0 then
            self.m_userIconSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq() 
            UIGameObjectLoader:GetInstance():GetGameObject(self.m_userIconSeq, TheGameIds.UserItemPrefab, function(obj)
                self.m_userIconSeq = 0
                
                if not IsNull(obj) then
                
                    self.m_userIconItem = UserItem.New(obj, self.m_headRoot, TheGameIds.UserItemPrefab)
                    self.m_userIconItem:SetLocalScale(UserItemScale)
                    self.m_userIconItem:UpdateData(userBrief.use_icon.icon, userBrief.use_icon.icon_box, userBrief.level)    
                end
            end)
        end
    else
        self.m_userIconItem:UpdateData(userBrief.use_icon.icon, userBrief.use_icon.icon_box, userBrief.level)
    end 

    self:UpdateVip(userBrief.vip_level)

    self.m_playerNameText.text = userBrief.name
    self.m_guildNameText.text = UILogicUtil.GetCorrectGuildName(userBrief.guild_name)
    self.m_guildJobText.text = userBrief.guild_job_name

    self.m_postImage.gameObject:SetActive(userBrief.guild_job > 0)
    UILogicUtil.SetGuildPostImage(self.m_postImage, userBrief.guild_job)

    local guildIconCfg = ConfigUtil.GetGuildIconCfgByID(userBrief.guild_icon)
    if guildIconCfg then
        self.m_guildIconImage:SetAtlasSprite(guildIconCfg.icon..".png")
    end

    self.m_serverIdText.text = userBrief.str_dist_id
end

function UIUserDetailView:UpdateSignature()
    self.m_lastSignature = self.m_userDetailParam.personalSignature

    self.m_inputField:SetText(self.m_userDetailParam.personalSignature)

    if Player:GetInstance():GetUserMgr():CheckIsSelf(self.m_userDetailParam.userBrief.uid) then
        self.m_inputField:SetInteractable(true)

        -- if self.m_userDetailParam.personalSignature == '' then
        --     self.m_inputField.text = Language.GetString(1556)
        --     self.m_lastSignature = Language.GetString(1556)
        -- else
        --     self.m_inputField.text = self.m_userDetailParam.personalSignature
        -- end
    else
        self.m_inputField:SetInteractable(false)

        if self.m_userDetailParam.personalSignature == '' then
            self.m_inputField:SetText(Language.GetString(1558))
        else
            self.m_inputField:SetText(self.m_userDetailParam.personalSignature)
        end
    end
end

function UIUserDetailView:UpdateHonor()
    self.m_achieveNumText.text = math_ceil(self.m_userDetailParam.achievement)

    local rankPos = self.m_arenaRankTr.localPosition
    if self.m_userDetailParam.arenaRank > 0 then
        self.m_arenaRankText.text = string_format(Language.GetString(1560), self.m_userDetailParam.arenaRank)
        self.m_arenaRankTr.localPosition = Vector3.New(97, rankPos.y, 0)
    else
        self.m_arenaRankText.text = Language.GetString(2108)
        self.m_arenaRankTr.localPosition = Vector3.New(-10, rankPos.y, 0)
    end

    local danAwardCfg = ConfigUtil.GetArenaDanAwardCfgByID(self.m_userDetailParam.arenaDan)
    if danAwardCfg then
        self.m_arenaImage:SetAtlasSprite(danAwardCfg.sIcon, false, AtlasConfig[danAwardCfg.sAtlas])
    end
    
    local guildWarCraftDefTitleCfg = ConfigUtil.GetGuildWarCraftDefTitleCfgByID(self.m_userDetailParam.warcraftUserTitle)
    if guildWarCraftDefTitleCfg then
        self.m_militaryImage:SetAtlasSprite(guildWarCraftDefTitleCfg.icon..".png")
    end
    if self.m_userDetailParam.jungong > 0 then
        self.m_militaryNumText.text = math_ceil(self.m_userDetailParam.jungong)
    else
        self.m_militaryNumText.text = Language.GetString(1559)
    end
end

function UIUserDetailView:UpdateDefList()
    self.m_powerText.text = math_ceil(self.m_userDetailParam.defPower)

    if #self.m_wujiang_card_list == 0 and self.m_wujiangCardSeq == 0 then
        self.m_wujiangCardSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObjects(self.m_wujiangCardSeq, CardItemPath, #self.m_userDetailParam.defWujiangBriefList, function(objs)
            self.m_wujiangCardSeq = 0
            if objs then
                for i = 1, #objs do
                    local cardItem = UIWuJiangCardItem.New(objs[i], self.m_battleArrayContent, CardItemPath)
                    cardItem:SetData(self.m_userDetailParam.defWujiangBriefList[i])
                    cardItem:SetAnchoredPosition(WujiangCardPosList[i])
                    cardItem:SetLocalScale(WujiangCardScale)
                    table_insert(self.m_wujiang_card_list, cardItem)
                end
            end
        end)
    else
        for i, wujiangItem in ipairs(self.m_wujiang_card_list) do
            wujiangItem:SetData(self.m_userDetailParam.defWujiangBriefList[i])
        end
    end
end

return UIUserDetailView








