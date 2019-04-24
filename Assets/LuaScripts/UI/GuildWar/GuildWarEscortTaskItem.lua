local GameUtility = CS.GameUtility
local UserItemPrefab = TheGameIds.UserItemPrefab
local UserItemClass = require("UI.UIUser.UserItem")
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()
local guildWarMgr = Player:GetInstance():GetGuildWarMgr()
local GameUtility = CS.GameUtility
local math_floor = math.floor
local TimeUtil = TimeUtil

local GuildWarEscortTaskItem = BaseClass("GuildWarEscortTaskItem", UIBaseItem)
local base = UIBaseItem
 

function GuildWarEscortTaskItem:OnCreate()
    base.OnCreate(self)
    self.m_husongID = 0
    self.m_hufaItem = nil
    self.m_hufaItemSeq = 0 


    self:InitView() 
    self:HandleClick()
end 

function GuildWarEscortTaskItem:InitView()
    self.m_itemPosTr,
    self.m_acceptBtnTr,
    self.m_getAwardBtnTr,
    self.m_inviteBtnTr,
    self.m_otherTr,
    self.m_custodianPosTr = UIUtil.GetChildTransforms(self.transform, { 
        "Panel/ItemPos",
        "Panel/Bottom/AcceptBtn",
        "Panel/Bottom/GetAwardBtn",
        "Panel/Bottom/Other/InviteCustodianBtn",
        "Panel/Bottom/Other",
        "Panel/Bottom/Other/CustodianItemPos",
    })
 
    self.m_tilteTxt,
    self.m_difficultyTxt,
    self.m_conveyDes1Txt,
    self.m_conveyDes2Txt,
    self.m_achieveTitleTxt,
    self.m_achieveNum1Txt,
    self.m_achieveNum2Txt, 
    self.m_acceptBtnTxt, 
    self.m_getAwardBtnTxt,
    self.m_otherDes1Txt,
    self.m_escortTimeTxt,
    self.m_otherDes2Txt,
    self.m_inviteBtnTxt,
    self.m_custodianNameTxt = UIUtil.GetChildTexts(self.transform, {   
        "Panel/TitleContent/TitleTxt",
        "Panel/TitleContent/CircleImg/DifficultyTxt",
        "Panel/Des1",
        "Panel/Des2",
        "Panel/AchieveContent/Bg/AchieveTitleTxt",
        "Panel/AchieveContent/Award1/Bg/NumTxt",
        "Panel/AchieveContent/Award2/Bg/NumTxt",
        "Panel/Bottom/AcceptBtn/Text",
        "Panel/Bottom/GetAwardBtn/Text",
        "Panel/Bottom/Other/OtherDes1",
        "Panel/Bottom/Other/EscortTimeTxt",
        "Panel/Bottom/Other/OtherDes2",
        "Panel/Bottom/Other/InviteCustodianBtn/Text", 
        "Panel/Bottom/Other/CustodianItemPos/CustodianName",
    })   

    self.m_tilteTxt.text = Language.GetString(2370)
    self.m_achieveTitleTxt.text = Language.GetString(2378)
    self.m_acceptBtnTxt.text = Language.GetString(2379)
    self.m_getAwardBtnTxt.text = Language.GetString(2380)
    self.m_inviteBtnTxt.text = Language.GetString(2381)
    self.m_otherDes1Txt.text = Language.GetString(2382)
    self.m_otherDes2Txt.text = Language.GetString(2383)

    self.m_award1IconImg = UIUtil.AddComponent(UIImage, self,  "Panel/AchieveContent/Award1/IconImg", AtlasConfig.ItemIcon)
    self.m_award2IconImg = UIUtil.AddComponent(UIImage, self,  "Panel/AchieveContent/Award2/IconImg", AtlasConfig.ItemIcon)

    self.m_circleImg = UIUtil.AddComponent(UIImage, self,  "Panel/TitleContent/CircleImg", AtlasConfig.DynamicLoad)

    self.m_frameImg = UIUtil.AddComponent(UIImage, self,  "Panel/ItemPos/Frame", AtlasConfig.DynamicLoad)
end 

function GuildWarEscortTaskItem:UpdateData(one_husong_mission, curr_husong_mission)
    if not one_husong_mission then
        return
    end

    self.m_husongID = one_husong_mission.husong_id
    self.m_leftHSTime = one_husong_mission.left_time

    self:UpdateTimeTxt()
   
    local status = one_husong_mission.status 
    local hasHuFa = one_husong_mission.hufa_uid > 0 and true or false
  
    self:SetTaskStatus(status, hasHuFa, self:CanAcceptMission(curr_husong_mission)) 
    if hasHuFa then
        local userBriefData = one_husong_mission.hufa_brief
        self:CreateItem(userBriefData)
    end 

    local taskCfg = ConfigUtil.GetGuildWarHuSongCfgByID(self.m_husongID)
    if taskCfg then  
        self.m_difficultyTxt.text = taskCfg.name
        self.m_conveyDes1Txt.text = string.format(Language.GetString(2376), taskCfg.num)
        self.m_conveyDes2Txt.text = string.format(Language.GetString(2377), taskCfg.need_time)  

        local awardList = taskCfg.award
        if awardList[1] then
            self.m_award1IconImg:SetAtlasSprite(awardList[1][1]..".png")
            self.m_achieveNum1Txt.text = awardList[1][2]
        end
        if awardList[2] then
            self.m_award2IconImg:SetAtlasSprite(awardList[2][1]..".png")
            self.m_achieveNum2Txt.text = awardList[2][2]
        end

        if taskCfg.hardLevel == 1 then
            self.m_circleImg:SetAtlasSprite("jtzb15.png")
            self.m_frameImg:SetAtlasSprite("beibao18.png")
        elseif taskCfg.hardLevel == 2 then
            self.m_circleImg:SetAtlasSprite("jtzb16.png")
            self.m_frameImg:SetAtlasSprite("beibao14.png")
        elseif taskCfg.hardLevel == 3 then
            self.m_circleImg:SetAtlasSprite("zhuxian11.png")
            self.m_frameImg:SetAtlasSprite("beibao16.png")
        end
    end   
end

function GuildWarEscortTaskItem:SetTaskStatus(status, hasHuFa, canAcceptMission)

   
    if status == 0 then
        --没有接受任务 
        GameUtility.SetUIGray(self.m_acceptBtnTr.gameObject, not canAcceptMission)

        self.m_acceptBtnTr.gameObject:SetActive(true)   
        self.m_getAwardBtnTr.gameObject:SetActive(false)  
        self.m_otherTr.gameObject:SetActive(false)        
    elseif status == 1 then
        --进行中
        self.m_acceptBtnTr.gameObject:SetActive(false)   
        self.m_getAwardBtnTr.gameObject:SetActive(false)  
        self.m_otherTr.gameObject:SetActive(true)
        if hasHuFa then
            self.m_inviteBtnTr.gameObject:SetActive(false)     
            self.m_custodianPosTr.gameObject:SetActive(true)   
        else
            self.m_inviteBtnTr.gameObject:SetActive(true)     
            self.m_custodianPosTr.gameObject:SetActive(false)   
        end 
    elseif status == 2 then
        --已完成但未领取
        self.m_acceptBtnTr.gameObject:SetActive(false)   
        self.m_getAwardBtnTr.gameObject:SetActive(true)  
        self.m_otherTr.gameObject:SetActive(false)
        UIUtil.AddClickEvent(self.m_getAwardBtnTr.gameObject, UILogicUtil.BindClick(self, self.OnClick))  
        GameUtility.SetUIGray(self.m_getAwardBtnTr.gameObject, false) 

    elseif status == 3 then
        --完成并且已领取
        self.m_acceptBtnTr.gameObject:SetActive(false)   
        self.m_getAwardBtnTr.gameObject:SetActive(true)  
        self.m_otherTr.gameObject:SetActive(false)
        UIUtil.RemoveClickEvent(self.m_getAwardBtnTr.gameObject)  
        GameUtility.SetUIGray(self.m_getAwardBtnTr.gameObject, true) 
    end 
end

function GuildWarEscortTaskItem:CanAcceptMission(curr_husong_mission)
    if curr_husong_mission then
        if  curr_husong_mission.husong_id > 0 and curr_husong_mission.husong_id ~= self.m_husongID then
            return false
        end
    end

    return true
end

function GuildWarEscortTaskItem:CreateItem(userBriefData) 
    local nameLen = string.len(userBriefData.name)
    local name = userBriefData.name
    if nameLen > 12 then
        name = string.sub(name, 1, 12).."..."
    end
    self.m_custodianNameTxt.text = name 

    if self.m_hufaItem then
        if userBriefData.use_icon then
            self.m_hufaItem:UpdateData(userBriefData.use_icon.icon, userBriefData.use_icon.icon_box, userBriefData.level)
        end
    else
        self.m_hufaItemSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObject(self.m_hufaItemSeq, UserItemPrefab, function(obj)
            self.m_hufaItemSeq = 0
            if not obj then
                return
            end
            local userItem = UserItemClass.New(obj, self.m_custodianPosTr, UserItemPrefab)
            userItem:SetLocalScale(Vector3.New(0.6, 0.6, 0.6))
            if userBriefData.use_icon then
                userItem:UpdateData(userBriefData.use_icon.icon, userBriefData.use_icon.icon_box, userBriefData.level)
            end
            self.m_hufaItem = userItem
        end)
    end
end

function GuildWarEscortTaskItem:Update()
    self:UpdateTimeTxt()
end

function GuildWarEscortTaskItem:UpdateTimeTxt() 
    if not self.m_leftHSTime or self.m_leftHSTime <= 0 then 
        return
    end
    local leftS = self.m_leftHSTime - 1
    self.m_escortTimeTxt.text = TimeUtil.ToHourMinSecStr(leftS, 2384)
    self.m_leftHSTime = leftS
end  

function GuildWarEscortTaskItem:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_acceptBtnTr.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_getAwardBtnTr.gameObject, onClick) 
    UIUtil.AddClickEvent(self.m_inviteBtnTr.gameObject, onClick) 
end

function GuildWarEscortTaskItem:OnClick(go, x, y)
    if go.name == "AcceptBtn" then 
        guildWarMgr:ReqAcceptHuSongMission(self.m_husongID)
    elseif go.name == "GetAwardBtn" then
        guildWarMgr:ReqTakeHuSongAward(self.m_husongID)
    elseif go.name == "InviteCustodianBtn" then 
        guildWarMgr:ReqInviteHuFaMembers()
    end
end

function GuildWarEscortTaskItem:OnAddListener()
	base.OnAddListener(self) 
end

function GuildWarEscortTaskItem:OnRemoveListener()
	base.OnRemoveListener(self)  
end 

function GuildWarEscortTaskItem:SetAwardBtnUnActiveStatus()
    UIUtil.RemoveClickEvent(self.m_getAwardBtnTr.gameObject)  
    GameUtility.SetUIGray(self.m_iconBtnTr.gameObject, true) 
end

function GuildWarEscortTaskItem:GetHuSongID()
    return self.m_husongID
end

function GuildWarEscortTaskItem:OnDestroy() 
    UIGameObjectLoaderInst:CancelLoad(self.m_hufaItemSeq)
    self.m_hufaItemSeq = 0
    if self.m_hufaItem then
        self.m_hufaItem:Delete()
        self.m_hufaItem = nil
    end


    if self.m_circleImg then
        self.m_circleImg:Delete()
        self.m_circleImg = nil
    end

    UIUtil.RemoveClickEvent(self.m_acceptBtnTr.gameObject)
    UIUtil.RemoveClickEvent(self.m_getAwardBtnTr.gameObject) 
    UIUtil.RemoveClickEvent(self.m_inviteBtnTr.gameObject) 

    base.OnDestroy(self)
end

return GuildWarEscortTaskItem