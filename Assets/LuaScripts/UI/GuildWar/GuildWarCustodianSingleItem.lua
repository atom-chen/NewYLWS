
local guildWarMgr = Player:GetInstance():GetGuildWarMgr()
local UserItemPrefab = TheGameIds.UserItemPrefab
local UserItemClass = require("UI.UIUser.UserItem")
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()

local GuildWarCustodianSingleItem = BaseClass("GuildWarCustodianSingleItem", UIBaseItem)
local base = UIBaseItem
 

function GuildWarCustodianSingleItem:OnCreate()
    base.OnCreate(self) 
    self.m_highLightActive = false
    self.m_hufaIconItem = nil
    self.m_hufaIconItemSeq = 0

    self:InitView()
    self:HandleClick()
end 

function GuildWarCustodianSingleItem:InitView()
    self.m_highLightImgTr,
    self.m_userItemPosTr = UIUtil.GetChildTransforms(self.transform, {  
        "HighLightImg",
        "UserItemPos",
    })

    self.m_userNameTxt,
    self.m_guildNameTxt = UIUtil.GetChildTexts(self.transform, {   
        "Other/UserName",
        "Other/GuildName",
    })  

    self.m_titleImg = UIUtil.AddComponent(UIImage, self, "Other/TitleImg", AtlasConfig.DynamicLoad)
    self.m_guildImg = UIUtil.AddComponent(UIImage, self, "Other/GuildImg", AtlasConfig.DynamicLoad2)

    self.m_highLightImgTr.gameObject:SetActive(false)
end

function GuildWarCustodianSingleItem:UpdateData(userBriefData)
    if not userBriefData then
        return
    end

    self.m_uid = userBriefData.uid 
    self.m_userNameTxt.text = userBriefData.name
    self.m_guildNameTxt.text = userBriefData.guild_name 
    local guildWartitleCfg = ConfigUtil.GetGuildWarCraftDefTitleCfgByID(userBriefData.user_title)
    if guildWartitleCfg then
        self.m_titleImg:SetAtlasSprite(guildWartitleCfg.icon..".png")
    end

    local guildIconCfg = ConfigUtil.GetGuildIconCfgByID(userBriefData.guild_icon)
    if guildIconCfg then
        self.m_guildImg:SetAtlasSprite(guildIconCfg.icon..".png")
    end

    self:CreateHuFaIconItem(userBriefData)
end

function GuildWarCustodianSingleItem:CreateHuFaIconItem(userBriefData)
    if self.m_hufaIconItem then
        if userBriefData.use_icon then
            self.m_hufaIconItem:UpdateData(userBriefData.use_icon.icon, userBriefData.use_icon.icon_box, userBriefData.level)
        end
    else
        self.m_hufaIconItemSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObject(self.m_hufaIconItemSeq, UserItemPrefab, function(obj)
            self.m_hufaIconItemSeq = 0
            if IsNull(obj) then
                return
            end
            local userItem = UserItemClass.New(obj, self.m_userItemPosTr, UserItemPrefab)
            userItem:SetLocalScale(Vector3.New(0.8, 0.8, 0.8))
            if userBriefData.use_icon then
                userItem:UpdateData(userBriefData.use_icon.icon, userBriefData.use_icon.icon_box, userBriefData.level)
            end
            self.m_hufaIconItem = userItem
        end)
    end
end 

function GuildWarCustodianSingleItem:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.transform.gameObject, onClick)
end

function GuildWarCustodianSingleItem:RemoveClick()
    UIUtil.RemoveClickEvent(self.transform.gameObject)
end

function GuildWarCustodianSingleItem:OnClick(go, x, y)
    if self.m_highLightActive then
        self.m_highLightActive = false
        guildWarMgr:DeleteFromHuFaIDList(self.m_uid)
    else
        self.m_highLightActive = true
        guildWarMgr:AddToHuFaIDList(self.m_uid)
    end
    self.m_highLightImgTr.gameObject:SetActive(self.m_highLightActive) 
end

function GuildWarCustodianSingleItem:OnDestroy()
    UIGameObjectLoaderInst:CancelLoad(self.m_hufaIconItemSeq)
    self.m_hufaIconItemSeq = 0
    if self.m_hufaIconItem then
        self.m_hufaIconItem:Delete()
        self.m_hufaIconItem = nil
    end
    base.OnDestroy(self)
end

function GuildWarCustodianSingleItem:ResetPosZ()
    if self.rectTransform then
        local x = self.rectTransform.anchoredPosition.x
        local y = self.rectTransform.anchoredPosition.y
        self.rectTransform.anchoredPosition = Vector3.New(x, y, 0)
    end
end

return GuildWarCustodianSingleItem
