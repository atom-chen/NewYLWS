local actMgr = Player:GetInstance():GetActMgr()
local userMgr = Player:GetInstance():GetUserMgr()
local shopMgr = Player:GetInstance():GetShopMgr() 
local taskMgr = Player:GetInstance():GetTaskMgr()
local dianJiangMgr = Player:GetInstance():GetDianjiangMgr()

local CommonDefine = CommonDefine

local MainIconItem = BaseClass("MainIconItem", UIBaseItem)
local base = UIBaseItem

function MainIconItem:OnCreate()
    base.OnCreate(self)

    self.m_iconImage = UIUtil.AddComponent(UIImage, self, "Icon", AtlasConfig.DynamicLoad)
    self.m_iconNameText = UIUtil.FindText(self.transform, "Icon/IconNameText")

    self.m_redPoint = UIUtil.GetChildTransforms(self.transform, {
        "redPoint"
    })
   
    self.m_redPoint = self.m_redPoint.gameObject
    self.m_redPoint:SetActive(false)


    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent(self:GetGameObject(), onClick)
end

function MainIconItem:OnClick(go)
    if go == self:GetGameObject() then
        if self.m_mainIconCfg then
            UILogicUtil.SysShowUI(self.m_mainIconCfg.sysId)
        end
    end
end

function MainIconItem:OnDestroy(cfg)
    UIUtil.RemoveClickEvent(self:GetGameObject())
    self.m_mainIconCfg = nil
    base.OnDestroy(self)
end

function MainIconItem:UpdateData(cfg)
    if cfg then
        self.m_mainIconCfg = cfg
        self.m_iconNameText.text = cfg.sName
        self.m_iconImage:SetAtlasSprite(cfg.sIcon..".png")
 
        self:Refresh()
        self:RefreshRedPoint()
    end
end

function MainIconItem:RefreshRedPoint()
    local redPointStatus = false 
    
    if self.m_mainIconCfg.sysId == SysIDs.DOWNLOAD then
        redPointStatus = Player:GetInstance():GetUserMgr():IsShowDownloadRedPoint()
    else
        redPointStatus = self:IsIdExist()  
    end
    
    self.m_redPoint:SetActive(redPointStatus)
end

function MainIconItem:IsIdExist() 
    local idList = userMgr:GetRedPointList()
    local id = self.m_mainIconCfg.sysId

    local isExist = false
    if idList[id] then
        isExist = true
    end

    return isExist
end

function MainIconItem:Refresh() 
    local userData = userMgr:GetUserData() 
    local isOpen = UILogicUtil.IsSysOpen(self.m_mainIconCfg.sysId)

    if self.m_mainIconCfg.sysId == SysIDs.SHOU_CHONG then   -- 首充
        if userData.first_recharge_award_status == 2 or not isOpen then
            self.transform.gameObject:SetActive(false)
        else
            self.transform.gameObject:SetActive(true)
        end
    elseif self.m_mainIconCfg.sysId == SysIDs.SEVEN_DAYS then  --七天
        local leftDays = taskMgr:GetSevenDaysLeftDays() 
        if leftDays <= 0 or not isOpen then
            self.transform.gameObject:SetActive(false)
        else 
            self.transform.gameObject:SetActive(true)
        end
    elseif self.m_mainIconCfg.sysId == SysIDs.ZHUANPAN then   --转盘
        local turntableOpen = actMgr:IsTurnTableOpen()
        if not turntableOpen or not isOpen then
            self.transform.gameObject:SetActive(false) 
        else
            self.transform.gameObject:SetActive(true)
        end 
    elseif self.m_mainIconCfg.sysId == SysIDs.DUOBAO then    --夺宝
        local duobaoOpen = actMgr:IsDuoBaoOpen() 
        if not duobaoOpen or not isOpen then 
            self.transform.gameObject:SetActive(false) 
        else
            self.transform.gameObject:SetActive(true)
        end
    elseif self.m_mainIconCfg.sysId == SysIDs.JIXINGGAOZHAO then    --吉星高照
        local jixinggaozhaoOpen = actMgr:IsJiXingGaoZhaoOpen() 
        if not jixinggaozhaoOpen or not isOpen then 
            self.transform.gameObject:SetActive(false) 
        else
            self.transform.gameObject:SetActive(true)
        end  
    elseif self.m_mainIconCfg.sysId == SysIDs.ACTIVITY then   --活动
        local actvitityOpen = actMgr:IsActOpen()
        if not actvitityOpen or not isOpen then
            self.transform.gameObject:SetActive(false) 
        else
            self.transform.gameObject:SetActive(true)
        end 
    elseif self.m_mainIconCfg.sysId == SysIDs.YUE_KA then   -- 月卡

    elseif self.m_mainIconCfg.sysId == SysIDs.FULI then   -- 福利

    elseif self.m_mainIconCfg.sysId == SysIDs.DOWNLOAD then
        self.transform.gameObject:SetActive(isOpen and userMgr:IsNeedDownloadAB())
    end

end 

return MainIconItem
