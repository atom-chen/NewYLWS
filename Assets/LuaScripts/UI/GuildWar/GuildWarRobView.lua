local custodianSingleItemClass = require "UI.GuildWar.GuildWarCustodianSingleItem" 
local custodianSingleItemPrefab = "UI/Prefabs/Guild/UIGuildWarCustodianSingleItem.prefab"
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance() 
local guildWarMgr = Player:GetInstance():GetGuildWarMgr()
local UILogicUtil = UILogicUtil
local Language = Language
local BattleEnum = BattleEnum

local GuildWarRobView = BaseClass("GuildWarRobView", UIBaseView)
local base = UIBaseView 

function GuildWarRobView:OnCreate()
    base.OnCreate(self)
    self.m_custodianItemSeq = 0
    self.m_custodianItem = nil
    self.m_escortItemSeq = 0
    self.m_escortItem = nil
    self.m_intervalTime = 0
    self.m_robCount = 0

    self:InitView()
    self:HandleClick()
end

function GuildWarRobView:InitView()
    self.m_blackBgTr,
    self.m_robBtnTr,
    self.m_escortContentTr,
    self.m_custodianContentTr,
    self.m_noneContentTr = UIUtil.GetChildTransforms(self.transform, { 
        "BlackBg",
        "Panel/RobBtn",
        "Panel/EscortItemContent/EscortContent",
        "Panel/EscortItemContent/CustodianContent",
        "Panel/EscortItemContent/NoneContent",
    }) 
    
    self.m_titleTxt,
    self.m_difficultyTxt,
    self.m_timeTxt,
    self.m_achieveTitleTxt,
    self.m_award1NumTxt,
    self.m_award2NumTxt,
    self.m_des1Txt,
    self.m_des2Txt,
    self.m_robBtnTxt,
    self.m_robCountTxt,
    self.m_noneTxt = UIUtil.GetChildTexts(self.transform, {  
        "Panel/TitleContent/TitleTxt",
        "Panel/TitleContent/CircleImg/DifficultyTxt",
        "Panel/EscortTimeTxt",
        "Panel/AchieveContent/Bg/AchieveTitleTxt",
        "Panel/AchieveContent/Award1/Bg/NumTxt",
        "Panel/AchieveContent/Award2/Bg/NumTxt",
        "Panel/Des1",
        "Panel/Des2",
        "Panel/RobBtn/Text",
        "Panel/RobCountTxt",
        "Panel/EscortItemContent/NoneContent/Text",
    })
    self.m_award1IconImg = UIUtil.AddComponent(UIImage, self,  "Panel/AchieveContent/Award1/IconImg", AtlasConfig.ItemIcon)
    self.m_award2IconImg = UIUtil.AddComponent(UIImage, self,  "Panel/AchieveContent/Award2/IconImg", AtlasConfig.ItemIcon) 
    self.m_forageIconImg = UIUtil.AddComponent(UIImage, self,  "Panel/ForageItemPos/Icon", AtlasConfig.DynamicLoad)

    self.m_titleTxt.text = Language.GetString(2370)
    self.m_achieveTitleTxt.text = Language.GetString(2378) 
    self.m_des1Txt.text = Language.GetString(2373)
    self.m_des2Txt.text = Language.GetString(2383)
    self.m_robBtnTxt.text = Language.GetString(2374)
end

function GuildWarRobView:OnEnable(...)
    base.OnEnable(self, ...)

    local _, oneMissionInfo = ...
    if not oneMissionInfo then
        return
    end 
    self:UpdateData(oneMissionInfo)
end

function GuildWarRobView:UpdateData(oneMissionInfo) 
    self.m_leftHSTime = oneMissionInfo.left_time
    local taskCfg = ConfigUtil.GetGuildWarHuSongCfgByID(oneMissionInfo.husong_id)
    if taskCfg then
        self.m_difficultyTxt.text = taskCfg.name
         -- self.m_forageIconImg:SetAtlasSprite(taskCfg.)    --粮草icon
        local awardList = taskCfg.award
        if awardList[1] then
            self.m_award1IconImg:SetAtlasSprite(awardList[1][1]..".png")
            self.m_award1NumTxt.text = awardList[1][2]
        end
        if awardList[2] then
            self.m_award2IconImg:SetAtlasSprite(awardList[2][1]..".png")
            self.m_award2NumTxt.text = awardList[2][2]
        end 
    end
    local hufaID = oneMissionInfo.hufa_id
    local hufaBrief = oneMissionInfo.hufa_brief 
    if hufaBrief.uid > 0 then
        self.m_noneContentTr.gameObject:SetActive(false)
        self.m_custodianContentTr.gameObject:SetActive(true)
        self:CreateCustodianItem(hufaBrief) 
    else
        self.m_noneTxt.text = Language.GetString(2397)
        self.m_noneContentTr.gameObject:SetActive(true)
        self.m_custodianContentTr.gameObject:SetActive(false)
    end
        
    local owenrBrief = oneMissionInfo.owner_brief
    self:CreateEscortItem(owenrBrief)

    local robCount = guildWarMgr:GetHuSongCount()
    local color = ""
    if robCount > 0 then
        color = "1DF900"
    else
        color = "FF0000"
    end
    self.m_robCountTxt.text = string.format(Language.GetString(2389), color, robCount)
    self.m_robCount = robCount
end

function GuildWarRobView:CreateEscortItem(myUserBrief)  
    if not myUserBrief then
        return
    end
    if self.m_escortItem then
        self.m_escortItem:UpdateData(myUserBrief)
    else
        self.m_escortItemSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObject(self.m_escortItemSeq, custodianSingleItemPrefab, function(obj)
            self.m_escortItemSeq = 0
            if IsNull(obj) then
                return
            end
            
            local singleItem = custodianSingleItemClass.New(obj, self.m_escortContentTr, custodianSingleItemPrefab) 
            singleItem:UpdateData(myUserBrief) 
            singleItem:RemoveClick()  
            self.m_escortItem = singleItem
        end)  
    end
end

function GuildWarRobView:CreateCustodianItem(hufaBrief)
    if self.m_custodianItem then
        self.m_custodianItem:UpdateData(hufaBrief)
    else
        self.m_custodianItemSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObject(self.m_custodianItemSeq, custodianSingleItemPrefab, function(obj)
            self.m_custodianItemSeq = 0
            if IsNull(obj) then
                return
            end 
            local singleItem = custodianSingleItemClass.New(obj, self.m_custodianContentTr, custodianSingleItemPrefab) 
            singleItem:UpdateData(hufaBrief)  
            singleItem:RemoveClick()
            self.m_custodianItem = singleItem 
        end)  
    end
end

function GuildWarRobView:Update()
    self.m_intervalTime = self.m_intervalTime - Time.deltaTime
    if self.m_intervalTime <= 0 then
        self:UpdateTimeTxt()
        self.m_intervalTime = 1
    end
end

function GuildWarRobView:UpdateTimeTxt() 
    if not self.m_leftHSTime or self.m_leftHSTime <= 0 then
        return
    end 

    local leftS = self.m_leftHSTime - 1  
    local hour = math.floor(leftS / 60 / 60)
    local min = math.floor((leftS - hour * 60 * 60) / 60)
    local sec = math.floor(leftS % 60)
    self.m_timeTxt.text = string.format(Language.GetString(2384), hour, min, sec)
    self.m_leftHSTime = leftS 
end  

function GuildWarRobView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_robBtnTr.gameObject, onClick)   
    UIUtil.AddClickEvent(self.m_blackBgTr.gameObject, onClick)  
end

function GuildWarRobView:OnClick(go, x, y)
    if go.name == "RobBtn" then
        if not guildWarMgr:CheckHuSongCount() then
            UILogicUtil.FloatAlert(Language.GetString(2393))
            return
        end
        UIManagerInst:OpenWindow(UIWindowNames.UILineupMain, BattleEnum.BattleType_ROB_GUILD_HUSONG)
    elseif go.name == "BlackBg" then
        self:CloseSelf()
    end
end

function GuildWarRobView:OnDisable()
    UIGameObjectLoaderInst:CancelLoad(self.m_custodianItemSeq)
    UIGameObjectLoaderInst:CancelLoad(self.m_escortItemSeq)
    self.m_custodianItemSeq = 0
    self.m_escortItemSeq = 0

    if self.m_custodianItem then
        self.m_custodianItem:Delete()
    end
    if self.m_escortItem then
        self.m_escortItem:Delete()
    end
    
    self.m_custodianItem = nil
    self.m_escortItem = nil

    base.OnDisable(self)
end 

function GuildWarRobView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_robBtnTr.gameObject)   
    UIUtil.RemoveClickEvent(self.m_blackBgTr.gameObject)  

    base.OnDestroy(self)
end

return GuildWarRobView
