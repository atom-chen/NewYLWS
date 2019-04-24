
local string_format = string.format
local math_ceil = math.ceil

local UIGuildLevelUpView = BaseClass("UIGuildLevelUpView", UIBaseView)
local base = UIBaseView

local ConfigUtil = ConfigUtil
local GuildMgr = Player:GetInstance().GuildMgr


function UIGuildLevelUpView:OnCreate()

    base.OnCreate(self)

    self:InitView()
end

function UIGuildLevelUpView:InitView()

    local titleText, donationText, guildResourceText, awardText, levelUpBtnText

    titleText, self.m_curLevelText, self.m_nextLevelText, donationText, self.m_donationSilderText, guildResourceText,
    self.m_resouce1CountText, self.m_resouce2CountText, self.m_resouce1CostCountText, self.m_resouce2CostCountText, 
    awardText, self.m_awardDectText, levelUpBtnText, self.m_tipsText = UIUtil.GetChildTexts(self.transform, {
        "Container/TitleBg/TitleText",
        "Container/CanLevelUpView/arrow/CurLevelText",
        "Container/CanLevelUpView/arrow/NextLevelText",
        "Container/CanLevelUpView/DonationText",
        "Container/CanLevelUpView/DonationSilder/DonationSilderText",
        "Container/CanLevelUpView/GuildResourceText",
        "Container/CanLevelUpView/Resouce1/Resouce1CountText",
        "Container/CanLevelUpView/Resouce2/Resouce2CountText",
        "Container/CanLevelUpView/Resouce1/Resouce1CostCountText",
        "Container/CanLevelUpView/Resouce2/Resouce2CostCountText",
        "Container/CanLevelUpView/AwardText",
        "Container/CanLevelUpView/AwardDectText",
        "Container/CanLevelUpView/LevelUpBtn/LevelUpBtnText",
        "Container/FullLevelTipsText"
    })

    titleText.text = Language.GetString(1359)
    donationText.text = Language.GetString(1360)
    guildResourceText.text = Language.GetString(1361)
    awardText.text = Language.GetString(1362)
    self.m_tipsText.text = Language.GetString(1358)
    levelUpBtnText.text = Language.GetString(1344)

    self.m_canLevelUpViewGo, self.m_closeBtn, self.m_levelUpBtn,
    self.m_ruleBtnTr = UIUtil.GetChildTransforms(self.transform, {
        "Container/CanLevelUpView",
        "CloseBtn",
        "Container/CanLevelUpView/LevelUpBtn",
        "Container/ruleBtn",
    })

    self.m_canLevelUpViewGo = self.m_canLevelUpViewGo.gameObject
    self.m_donationSilder = UIUtil.FindSlider(self.transform, "Container/CanLevelUpView/DonationSilder")

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_levelUpBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_ruleBtnTr.gameObject, onClick)
end


function UIGuildLevelUpView:OnDestory()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_levelUpBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_ruleBtnTr.gameObject)

    base.OnDestory(self)
end

function UIGuildLevelUpView:OnAddListener()
    base.OnAddListener(self)
    
    self:AddUIListener(UIMessageNames.MN_MYGUILD_BASEINFO_CHG, self.LevelUpSucc)
end

function UIGuildLevelUpView:OnRemoveListener()
    base.OnRemoveListener(self)

    self:RemoveUIListener(UIMessageNames.MN_MYGUILD_BASEINFO_CHG, self.LevelUpSucc)
end

function UIGuildLevelUpView:OnEnable(...)
   
    base.OnEnable(self, ...)

    self:UpdateData()
end

function UIGuildLevelUpView:LevelUpSucc()
    self:CloseSelf()
end


function UIGuildLevelUpView:UpdateData()

    local myGuildData = GuildMgr.MyGuildData
    if not myGuildData then
        return
    end
    
    local cfg = ConfigUtil.GetGuildExpCfgByID(myGuildData.level)
    if not cfg then
        return
    end
   
    local isFullLevel = cfg.need_huoyue < 0

    self.m_canLevelUpViewGo:SetActive(not isFullLevel)
    self.m_tipsText.gameObject:SetActive(isFullLevel)

    if not isFullLevel then
        self.m_curLevelText.text = string_format(Language.GetString(1345), myGuildData.level)
        self.m_nextLevelText.text = string_format(Language.GetString(1345), myGuildData.level + 1)

        local percent = myGuildData.huoyue / myGuildData.need_huoyue
        if percent > 1 then
            percent = 1
        end
        self.m_donationSilder.value = percent
        self.m_donationSilderText.text = string_format(Language.GetString(1356), myGuildData.huoyue, myGuildData.need_huoyue)

        self.m_resouce1CostCountText.text = cfg.need_yuanbao
        self.m_resouce2CostCountText.text = cfg.need_coin

        local isenough = myGuildData.guild_yuanbao >= cfg.need_yuanbao 
        self.m_resouce1CountText.text = string_format(Language.GetString(isenough and 1363 or 1357), myGuildData.guild_yuanbao)
        
        isenough = myGuildData.guild_coin >= cfg.need_coin 
        self.m_resouce2CountText.text = string_format(Language.GetString(isenough and 1363 or 1357), myGuildData.guild_coin)

        self.m_awardDectText.text = Language.GetString(cfg.awardStrID)
    end
end

function UIGuildLevelUpView:OnClick(go, x, y)
    if go.name == "CloseBtn" then
        self:CloseSelf() 
    elseif go.name == "LevelUpBtn" then
        local myGuildData = GuildMgr.MyGuildData
        if myGuildData then
            local cfg = ConfigUtil.GetGuildExpCfgByID(myGuildData.level)
            if not cfg then
                return
            end

            if myGuildData.huoyue < myGuildData.need_huoyue then
                UILogicUtil.FloatAlert(Language.GetString(1365))
                return
            end

            if myGuildData.guild_yuanbao < cfg.need_yuanbao or myGuildData.guild_coin < cfg.need_coin then
                UILogicUtil.FloatAlert(Language.GetString(1364))
                return
            end

            GuildMgr:ReqLevelUp()
        end
    elseif go.name == "ruleBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 113) 
    end 
end

return UIGuildLevelUpView