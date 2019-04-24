local UIUtil = UIUtil
local UILogicUtil = UILogicUtil
local GodBeastMgr = Player:GetInstance():GetGodBeastMgr()
local string_split = CUtil.SplitString
local string_format = string.format
local math_ceil = math.ceil
local effectPath = TheGameIds.Ui_shenshou_tianfu_jihuo

local UIGodBeastTipsDialogView = BaseClass("UIGodBeastTipsDialogView", UIBaseView)
base = UIBaseView

local ShowTypeArr = {
    NewTalent = 1,
    ForgetTalent = 2,
    Awaken = 3,
    NewAwaken = 4,
    Max = 5,
}

local RANK_TIME = 1

function UIGodBeastTipsDialogView:OnCreate()
    base.OnCreate(self)

    self:InitView()
end

function UIGodBeastTipsDialogView:InitView()

    local sureBtnText, cancelBtnText, titleText, forgetText, awakeText, newTitleText, explainText, forgetDesText
    sureBtnText, cancelBtnText, titleText, forgetText, awakeText, newTitleText, explainText, 
    self.m_detailsText, forgetDesText, self.m_forgetTalentText = UIUtil.GetChildTexts(self.transform, {
        "BgRoot/Top/BottomBtn/sureBtn/sureBtnText",
        "BgRoot/Top/BottomBtn/cancelBtn/cancelBtnText",
        "BgRoot/Top/titleContent/titleText",
        "BgRoot/Top/forgetTitleContent/forgetText",
        "BgRoot/Top/awakeText",
        "BgRoot/Top/newAwakeContent/newTitleText",
        "BgRoot/Top/newAwakeContent/explainText",
        "BgRoot/Top/detailsText",
        "BgRoot/Top/forgetTitleContent/forgetDesText",
        "BgRoot/Top/forgetTitleContent/forgetTalentText",
    })

    self.m_closeBtn, self.m_sureBtn, self.m_cancelBtn, self.m_titleContent, self.m_talentContent, self.m_forgetContent,
    self.m_newAwakeContent, self.m_awakeContent, self.m_detailsContent = UIUtil.GetChildTransforms(self.transform, {
        "closeBtn",
        "BgRoot/Top/BottomBtn/sureBtn",
        "BgRoot/Top/BottomBtn/cancelBtn",
        "BgRoot/Top/titleContent",
        "BgRoot/Top/talentContent",
        "BgRoot/Top/forgetTitleContent",
        "BgRoot/Top/newAwakeContent",
        "BgRoot/Top/awakeText",
        "BgRoot/Top/detailsText",
    })

    self.m_talentIcon = UIUtil.AddComponent(UIImage, self, "BgRoot/Top/talentContent/talentBg/talentIcon", ImageConfig.GodBeast)
    self.m_layerName = UILogicUtil.FindLayerName(self.transform)
    self.m_talentEffect = nil
    self.m_allTalentList = ConfigUtil.GetGodBeastTalentAllCfg()
    self.m_randTime = 0
    self.m_isShowEffect = false

    sureBtnText.text = Language.GetString(10)
    cancelBtnText.text = Language.GetString(50)
    titleText.text = Language.GetString(3620)
    forgetText.text = Language.GetString(3635)
    forgetDesText.text = Language.GetString(3621)
    awakeText.text = Language.GetString(3622)
    newTitleText.text = Language.GetString(3623)
    explainText.text = Language.GetString(3624)
    self.m_sureCallback = nil
end

function UIGodBeastTipsDialogView:OnEnable(...)
    base.OnEnable(self, ...)
    local initOrder, data = ...
    self:HandleClick()
    if data then
        self.m_showType = data.showType
        self.m_godBeastId = data.godBeastId
        self.m_talentInfo = data.talentInfo
        if self.m_showType then
            self:UpdateData()
        end
    end
end

function UIGodBeastTipsDialogView:UpdateData()
    self.m_titleContent.gameObject:SetActive(false)
    self.m_forgetContent.gameObject:SetActive(false)
    self.m_awakeContent.gameObject:SetActive(false)
    self.m_talentContent.gameObject:SetActive(false)
    self.m_detailsContent.gameObject:SetActive(false)
    self.m_cancelBtn.gameObject:SetActive(false)
    self.m_newAwakeContent.gameObject:SetActive(false)
    if self.m_showType == ShowTypeArr.NewTalent then
        self:UpdateTalentData()
        self.m_titleContent.gameObject:SetActive(true)
        self.m_talentContent.gameObject:SetActive(true)
        self.m_detailsContent.gameObject:SetActive(true)
        self:ShowTalentEffect()
        self.m_isShowEffect = true
        self.m_randTime = RANK_TIME
    elseif self.m_showType == ShowTypeArr.ForgetTalent then
        self:UpdateForgetData()
        self.m_forgetContent.gameObject:SetActive(true)
        self.m_cancelBtn.gameObject:SetActive(true)
    elseif self.m_showType == ShowTypeArr.Awaken then
        self.m_awakeContent.gameObject:SetActive(true)
        self.m_cancelBtn.gameObject:SetActive(true)
    elseif self.m_showType == ShowTypeArr.NewAwaken then
        self.m_newAwakeContent.gameObject:SetActive(true)
    end
end

function UIGodBeastTipsDialogView:UpdateTalentData()
    if self.m_talentInfo then
        local talentCfg = ConfigUtil.GetGodBeastTalentCfgByID(self.m_talentInfo.talent_id)
        if talentCfg then
            local str = talentCfg.exdesc
            local x1 = talentCfg.x + talentCfg.ax * self.m_talentInfo.talent_level
            local x2 = math_ceil(x1)
            x1 = x1 == x2 and x2 or x1
            local y1 = talentCfg.y + talentCfg.ay * self.m_talentInfo.talent_level
            local y2 = math_ceil(y1)
            y1 = y1 == y2 and y2 or y1
            str = str:gsub("{(.-)}", {x=x1, y=y1})
            local talentName = string_format(string_split(Language.GetString(3630), ",")[self.m_talentInfo.talent_level],talentCfg.name)
            self.m_detailsText.text = string_format(Language.GetString(3634), talentName, str)
            self.m_talentIcon:SetAtlasSprite(talentCfg.sIcon, false)
        end
    end
end

function UIGodBeastTipsDialogView:UpdateForgetData()
    if self.m_talentInfo then
        local talentCfg = ConfigUtil.GetGodBeastTalentCfgByID(self.m_talentInfo.talent_id)
        self.m_forgetTalentText.text = string_format(string_split(Language.GetString(3630), ",")[self.m_talentInfo.talent_level],talentCfg.name)
    end
end

function UIGodBeastTipsDialogView:OnDisable()
    self:RemoveClick()
    self:ClearTalentEffect()
    self.m_randTime = 0
    self.m_isShowEffect = false
    base.OnDisable(self)
end

function UIGodBeastTipsDialogView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_sureBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_cancelBtn.gameObject, onClick)
end

function UIGodBeastTipsDialogView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_sureBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_cancelBtn.gameObject)
end

function UIGodBeastTipsDialogView:OnClick(go, x, y)
    if self.m_showType == ShowTypeArr.NewAwaken then
        self:CheckShenShouAwakeGuide()
    end

    if go.name == "sureBtn" then
        if self.m_showType == ShowTypeArr.ForgetTalent then
            UIManagerInst:Broadcast(UIMessageNames.MN_GODBEAST_SURE_FORGET_TALENT)
            self:CloseSelf()
        elseif self.m_showType == ShowTypeArr.Awaken then
            if self.m_godBeastId then
                GodBeastMgr:ReqAwakening(self.m_godBeastId)
            end
        else
            self:CloseSelf()
        end
    elseif go.name == "closeBtn" or go.name == "cancelBtn" then
        self:CloseSelf()
    end
end

function UIGodBeastTipsDialogView:OnDestroy()
    self:ClearTalentEffect()

    if self.m_talentIcon then
        self.m_talentIcon:Delete()
        self.m_talentIcon = nil
    end

    base.OnDestroy(self)
end

function UIGodBeastTipsDialogView:CheckShenShouAwakeGuide()
    if Player:GetInstance():GetUserMgr():IsGuided(GuideEnum.GUIDE_SHENSHOU_AWAKE) then
        return
    end
    if GuideMgr:GetInstance():IsPlayingGuide(GuideEnum.GUIDE_SHENSHOU_AWAKE) then
        return
    end
    GuideMgr:GetInstance():Play(GuideEnum.GUIDE_SHENSHOU_AWAKE)
end

function UIGodBeastTipsDialogView:ShowTalentEffect()
    if not self.m_talentEffect then
        local sortOrder = UISortOrderMgr:GetInstance():PopSortingOrder(self, self.m_layerName)
        UIUtil.AddComponent(UIEffect, self, "", sortOrder, effectPath, function(effect)
            self.m_talentEffect = effect
            self.m_talentEffect:SetLocalPosition(Vector3.New(0, 70, 0))
            self.m_talentEffect:SetLocalScale(Vector3.New(1, 1, 1))
        end)
    end
end

function UIGodBeastTipsDialogView:ClearTalentEffect()
    if self.m_talentEffect then
        self.m_talentEffect:Delete()
        self.m_talentEffect = nil
    end 
end

function UIGodBeastTipsDialogView:Update()
    if self.m_isShowEffect then
        self.m_randTime = self.m_randTime - Time.deltaTime
        local talentCfg = nil
        if self.m_randTime > 0 then
            local index = math.random(1, #self.m_allTalentList)
            talentCfg = ConfigUtil.GetGodBeastTalentCfgByID(self.m_allTalentList[index].id)
        else 
            talentCfg = ConfigUtil.GetGodBeastTalentCfgByID(self.m_talentInfo.talent_id)
            self.m_randTime = 0
            self.m_isShowEffect = false
        end
        self.m_talentIcon:SetAtlasSprite(talentCfg.sIcon, false)
        end
end

return UIGodBeastTipsDialogView