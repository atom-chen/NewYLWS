
local Language = Language
local UILogicUtil = UILogicUtil
local GuildMgr = Player:GetInstance().GuildMgr
local string_format = string.format
local UIUtil = UIUtil
local ImageConfig = ImageConfig

local UIGuildSkillActiveView = BaseClass("UIGuildSkillActiveView", UIBaseView)
local base = UIBaseView

function UIGuildSkillActiveView:OnCreate()
    base.OnCreate(self)
    local descText, cancelBtnText, activeBtnText
    self.m_skillNameText, self.m_guildLevelText, self.m_totalDonationText, self.m_skillDescText,
    descText, exitBtnText, activeBtnText, self.m_coinsCountText, self.m_coinsHaveCountText,
    self.m_goldCountText, self.m_goldHaveCountText = UIUtil.GetChildTexts(self.transform, {
        "bgRoot/contentRoot/skill/skillName",
        "bgRoot/contentRoot/skill/guildLevelText",
        "bgRoot/contentRoot/skill/totalDonationText",
        "bgRoot/contentRoot/skill/skillDescText",
        "bgRoot/contentRoot/descText",
        "bgRoot/contentRoot/exit_BTN/Text",
        "bgRoot/contentRoot/active_BTN/Text",
        "bgRoot/contentRoot/coins/countText",
        "bgRoot/contentRoot/coins/haveText",
        "bgRoot/contentRoot/gold/countText",
        "bgRoot/contentRoot/gold/haveText"
    })

    descText.text = Language.GetString(1430)
    exitBtnText.text = Language.GetString(50)
    activeBtnText.text = Language.GetString(1426)

    self.m_bgBtn, self.m_backBtn, self.m_cancelBtn, self.m_activeBtn = UIUtil.GetChildTransforms(self.transform, {
        "bg",
        "bgRoot/backBtn",
        "bgRoot/contentRoot/exit_BTN",
        "bgRoot/contentRoot/active_BTN"
    })

    self.m_skillImg = self:AddComponent(UIImage, "bgRoot/contentRoot/skill/skillBg/skillImg", ImageConfig.SkillIcon)
    self.m_activeCallback = nil

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_bgBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_cancelBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_activeBtn.gameObject, onClick)
end

function UIGuildSkillActiveView:OnClick(go)
    if go.name == "bg" or go.name == "backBtn" or go.name == "exit_BTN" then
        self:CloseSelf()
    elseif go.name == "active_BTN" then
        if self.m_activeCallback then
            self.m_activeCallback()
            self:CloseSelf()
        end
    end
end


function UIGuildSkillActiveView:OnEnable(...)
    base.OnEnable(self, ...)
    local _, data, callback = ...

    if data then
        self.m_skillNameText.text = data.name
        self.m_guildLevelText.text = string_format(Language.GetString(1424), data.unlock_guild_level)
        self.m_totalDonationText.text = string_format(Language.GetString(1425), data.need_huoyue)
        self.m_skillDescText.text = data.desc
        self.m_skillImg:SetAtlasSprite(data.img_name)
        local guildData = GuildMgr.MyGuildData
        if guildData then
            local coinsCountText = UILogicUtil.ChangeCountToCountAndText(data.cost_guild_coin)
            local coinsHaveCountText = UILogicUtil.ChangeCountToCountAndText(guildData.guild_coin)
            local goldsCountText = UILogicUtil.ChangeCountToCountAndText(data.cost_guild_yuanbao)
            local goldsHaveCountText = UILogicUtil.ChangeCountToCountAndText(guildData.guild_yuanbao)
            self.m_coinsCountText.text = coinsCountText
            local tempStr = Language.GetString(1432)
            if data.cost_guild_coin > guildData.guild_coin then
                tempStr = Language.GetString(1431)
            end
            self.m_coinsHaveCountText.text = string_format(tempStr, coinsHaveCountText)
            self.m_goldCountText.text = goldsCountText
            local tempStrGold = Language.GetString(1432)
            if data.cost_guild_yuanbao > guildData.guild_yuanbao then
                tempStrGold = Language.GetString(1431)
            end
            self.m_goldHaveCountText.text = string_format(tempStrGold, goldsHaveCountText)
        end
    end

    self.m_activeCallback = callback or nil
end

function UIGuildSkillActiveView:OnDisable()
    self.m_activeCallback = nil
end

function UIGuildSkillActiveView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_bgBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_cancelBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_activeBtn.gameObject)
    base.OnDestroy(self)
end

return UIGuildSkillActiveView
