local UILineupMainView = BaseClass("UILineupMainView", UIBaseView)
local base = UIBaseView
local table_insert = table.insert
local CSObject = CS.UnityEngine.Object
local Type_GridLayoutGroup = typeof(CS.UnityEngine.UI.GridLayoutGroup)
local ScreenPointToWorldPointInRectangle = CS.UnityEngine.RectTransformUtility.ScreenPointToWorldPointInRectangle
local Type_RectTransform = typeof(CS.UnityEngine.RectTransform)
local SplitString = CUtil.SplitString
local BattleEnum = BattleEnum
local Utils = Utils
local Quaternion = Quaternion
local CommonDefine = CommonDefine
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTween = CS.DOTween.DOTween
local WujiangRootPath = TheGameIds.CommonWujiangRootPath
local GameObject = CS.UnityEngine.GameObject
local GameUtility = CS.GameUtility
local Vector2 = Vector2
local Vector3 = Vector3
local isEditor = CS.GameUtility.IsEditor()
local table_keys = table.keys
local math_ceil = math.ceil
local string_format = string.format
local loaderInstance = UIGameObjectLoader:GetInstance()
local Language = Language

local LineupWuJiangCardItem = require "UI.UIWuJiang.View.LineupWuJiangCardItem"
local CardItemPath = TheGameIds.CommonWujiangCardPrefab
local DragonIconItem = require "UI.Lineup.DragonIconItem"
local DragonIconPath = TheGameIds.DragonIconItemPrefab
local DragonTalentItem = require "UI.Lineup.DragonTalentItem"
local TalentItemPath = TheGameIds.TalentItemPrefab

local PetPosOffset = Vector3.New(0.1, 0, 0)
 
function UILineupMainView:OnCreate()
    base.OnCreate(self)

    self:InitVariable()
    self:InitView()
    self:InitDragonIcon()
end

function UILineupMainView:OnEnable(...)
    base.OnEnable(self, ...)
    local initorder
    initorder, self.m_battleType, self.m_copyID = ...

    self.m_bottomContainer.sizeDelta = Vector2.New(1540, self.m_bottomContainer.sizeDelta.y)
    self.m_lineupRoleContent:SetActive(true)
    self.m_benchRoleContent:SetActive(false)

    self.m_power = self.m_lineupMgr:GetLineupTotalPower(self:GetBuZhenID())
    self:UpdateLineup()
    self:HandleClick()

    if self:IsCheckLineupIllegal() then
        self.m_lineupMgr:ReqBuzhenIllegal(self:GetBuZhenID())
    end
end

function UILineupMainView:OnAddListener()
	base.OnAddListener(self)
	-- UI消息注册
    self:AddUIListener(UIMessageNames.MN_LINEUP_ITEM_SELECT, self.OnClickWuJiangCardItem)
    self:AddUIListener(UIMessageNames.MN_WUJIANG_SELECT, self.OnSelectWuJiangCardItem)
    self:AddUIListener(UIMessageNames.MN_LINEUP_APPLY_NEW, self.UpdateLineup)
    self:AddUIListener(UIMessageNames.MN_LINEUP_CHECK_LINEUP_ILLEGAL, self.UpdateLineup)
    self:AddUIListener(UIMessageNames.MN_LINEUP_CLICK_DRAGON, self.OnClickDragonIcon)
    self:AddUIListener(UIMessageNames.MN_LINEUP_REFRESH, self.UpdateLineup)
end

function UILineupMainView:OnRemoveListener()
	base.OnRemoveListener(self)
	-- UI消息注销
    self:RemoveUIListener(UIMessageNames.MN_LINEUP_ITEM_SELECT, self.OnClickWuJiangCardItem)
    self:RemoveUIListener(UIMessageNames.MN_WUJIANG_SELECT, self.OnSelectWuJiangCardItem)
    self:RemoveUIListener(UIMessageNames.MN_LINEUP_APPLY_NEW, self.UpdateLineup)
    self:RemoveUIListener(UIMessageNames.MN_LINEUP_CHECK_LINEUP_ILLEGAL, self.UpdateLineup)
    self:RemoveUIListener(UIMessageNames.MN_LINEUP_CLICK_DRAGON, self.OnClickDragonIcon)
    self:RemoveUIListener(UIMessageNames.MN_LINEUP_REFRESH, self.UpdateLineup)
end

function UILineupMainView:OnDisable()
    self:RecyleModelAndIcon()
    self:RemoveEvent()
    self:DestroyRoleContainer()

    self.m_perviousParent = nil
    self.m_transformIndex = 0

    base.OnDisable(self)
end

-- 初始化非UI变量
function UILineupMainView:InitVariable()
    self.m_lineupMgr = Player:GetInstance():GetLineupMgr()
    self.m_wuJiangMgr = Player:GetInstance():GetWujiangMgr()
    self.m_friendMgr = Player:GetInstance():GetFriendMgr()
    self.m_wujiangIconList = {}
    self.m_iconSeq = 0 
    self.m_wujiangShowList = {}
    self.m_wujiangLoadingSeqList = {}
    self.m_perviousParent = nil
    self.m_dragOffset = nil
    self.m_transformIndex = 0
    self.m_battleType = BattleEnum.BattleType_COPY
    self.m_selectWujiangPos = nil
    self.m_tweenner = nil
    self.m_dragonIconItemList = {}
    self.m_talentIconList = {}
    self.m_sceneSeq = 0
    self.m_power = 0
end

-- 初始化UI变量
function UILineupMainView:InitView()
    local powerDesText, clearText, lineupManageBtnText
    self.m_powerText, powerDesText, clearText, lineupManageBtnText, self.m_skillNameText, self.m_skillDesText,
    self.m_talnetNameText, self.m_dragonNameText = UIUtil.GetChildTexts(self.transform, {
        "BottomContainer/center/powerBg/powerText",
        "BottomContainer/center/powerBg/powerDesText",
        "TopContainer/clearBtn/clearText",
        "TopContainer/lineupManageBtn/lineupManageBtnText",
        "DragonContainer/bgImg/skillNameText",
        "DragonContainer/bgImg/skillDesText",
        "DragonContainer/bgImg/talnetNameText",
        "DragonContainer/titleImg/dragonNameText",
    })
    powerDesText.text = Language.GetString(1102)
    clearText.text = Language.GetString(1101)
    lineupManageBtnText.text = Language.GetString(1100)
    self.m_skillNameText.text = Language.GetString(1123)
    self.m_talnetNameText.text = Language.GetString(1124)

    local iconBg1,iconBg2,iconBg3,iconBg4,iconBg5,benchIconBg1,benchIconBg2
    iconBg1,iconBg2,iconBg3,iconBg4,iconBg5,benchIconBg1,benchIconBg2,self.m_benchIconBg3,self.m_benchIconBg4,self.m_benchIconBg5,
    self.m_lineupRolesParent, self.m_backBtn, self.m_roleParent, self.m_lineupManagerBtn,self.m_clearBtn,
    self.m_fightBtn, self.m_bottomContainer, self.m_lineupRoleContent, self.m_benchRoleContent, self.m_benchRoleParent,
    self.m_lineupBtn, self.m_benchBtn, self.m_topContainer, self.m_dragonContainer, self.m_dragonBtn, self.m_talentItemGrid,
    self.m_dragonIconGrid, self.m_dragonBg, self.m_dragonCloseBtn,
    self.m_textBgBtn = UIUtil.GetChildRectTrans(self.transform, {
        "BottomContainer/center/LineupRoleContent/roleBg/itemBg_1",
        "BottomContainer/center/LineupRoleContent/roleBg/itemBg_2",
        "BottomContainer/center/LineupRoleContent/roleBg/itemBg_3",
        "BottomContainer/center/LineupRoleContent/roleBg/itemBg_4",
        "BottomContainer/center/LineupRoleContent/roleBg/itemBg_5",
        "BottomContainer/center/BenchRoleContent/roleBg/itemBg_1",
        "BottomContainer/center/BenchRoleContent/roleBg/itemBg_2",
        "BottomContainer/center/BenchRoleContent/roleBg/itemBg_3",
        "BottomContainer/center/BenchRoleContent/roleBg/itemBg_4",
        "BottomContainer/center/BenchRoleContent/roleBg/itemBg_5",
        "BottomContainer/center/LineupRoleContent/lineupRoles",
        "Panel/backBtn",
        "BottomContainer/center/roleParent",
        "TopContainer/lineupManageBtn",
        "TopContainer/clearBtn",
        "BottomContainer/center/fightBtn",
        "BottomContainer",
        "BottomContainer/center/LineupRoleContent",
        "BottomContainer/center/BenchRoleContent",
        "BottomContainer/center/BenchRoleContent/benchRoles",
        "BottomContainer/center/BenchRoleContent/lineupBtn",
        "BottomContainer/center/BenchRoleContent/benchBtn",
        "TopContainer",
        "DragonContainer",
        "BottomContainer/center/dragonBtn",
        "DragonContainer/bgImg/talentItemGrid",
        "BottomContainer/center/dragonIconGrid",
        "DragonContainer/dragonBg",
        "DragonContainer/dragonCloseBtn",
        "TopContainer/TextBg/TextBg10",
    })

    self.m_dragonBtn = self.m_dragonBtn.gameObject
    self.m_dragonContainer = self.m_dragonContainer.gameObject
    self.m_lineupRoleContent = self.m_lineupRoleContent.gameObject
    self.m_benchRoleContent = self.m_benchRoleContent.gameObject
    self.m_benchIconBg3 = self.m_benchIconBg3.gameObject
    self.m_benchIconBg4 = self.m_benchIconBg4.gameObject
    self.m_benchIconBg5 = self.m_benchIconBg5.gameObject
    self.m_roleBgList = {iconBg1.gameObject,iconBg2.gameObject,iconBg3.gameObject,iconBg4.gameObject,iconBg5.gameObject,benchIconBg1.gameObject,
                            benchIconBg2.gameObject,self.m_benchIconBg3,self.m_benchIconBg4,self.m_benchIconBg5}
    self.m_roleGrid = self.m_lineupRolesParent:GetComponent(Type_GridLayoutGroup)
    self.m_benchRoleGrid = self.m_benchRoleParent:GetComponent(Type_GridLayoutGroup)
    self.m_roleRT = UIUtil.FindComponent(self.m_lineupRolesParent, Type_RectTransform)

    self.m_lineupBtnImage = UIUtil.AddComponent(UIImage, self, "BottomContainer/center/BenchRoleContent/lineupBtn", AtlasConfig.DynamicLoad)
    self.m_benchBtnImage = UIUtil.AddComponent(UIImage, self, "BottomContainer/center/BenchRoleContent/benchBtn", AtlasConfig.DynamicLoad)
    self.m_dragonBtnImage = UIUtil.AddComponent(UIImage, self, "BottomContainer/center/dragonBtn", AtlasConfig.DynamicLoad)
    self.m_dragonContainer:SetActive(false)
end

function UILineupMainView:SetParent(trans, pos, parent)
    trans:SetParent(parent)
    trans.localPosition = pos
    trans.localScale = Vector3.one
end

function UILineupMainView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_lineupManagerBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_clearBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_fightBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_lineupBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_benchBtn.gameObject, onClick)
    for _,roleBgTrans in pairs(self.m_roleBgList) do
        UIUtil.AddClickEvent(roleBgTrans, onClick)
    end
    UIUtil.AddClickEvent(self.m_dragonBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_dragonBg.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_dragonCloseBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_textBgBtn.gameObject, onClick)
end

function UILineupMainView:RemoveEvent()
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_lineupManagerBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_clearBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_fightBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_lineupBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_benchBtn.gameObject)
    for _,roleBgTrans in pairs(self.m_roleBgList) do
        UIUtil.RemoveClickEvent(roleBgTrans)
    end
    UIUtil.RemoveClickEvent(self.m_dragonBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_dragonBg.gameObject)
    UIUtil.RemoveClickEvent(self.m_dragonCloseBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_textBgBtn.gameObject)
end

function UILineupMainView:OnClick(go, x, y)
    local name = go.name
    if name == "backBtn" then
        self:CloseSelf()
    elseif string.contains(name, "itemBg_1") then
        self:OpenWujiangSeleteUI(1)
    elseif string.contains(name, "itemBg_2") then
        self:OpenWujiangSeleteUI(2)
    elseif string.contains(name, "itemBg_3") then
        self:OpenWujiangSeleteUI(3)
    elseif string.contains(name, "itemBg_4") then
        self:OpenWujiangSeleteUI(4)
    elseif string.contains(name, "itemBg_5") then
        self:OpenWujiangSeleteUI(5)
    elseif name == "lineupManageBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UILineupManager, self.m_battleType)
    elseif name == "clearBtn" then
        self:ClearLineup()
    elseif name == "fightBtn" then
        self:ClickFightBtn()

        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI, "fightBtn")
    elseif name == "dragonBtn" then
        self:OpenDragonPanel()
    elseif name == "dragonBg" then
        self.m_dragonContainer:SetActive(false)
        self.m_dragonIconGrid.localScale = Vector3.New(1, 0, 1)
    elseif name == "dragonCloseBtn" then
        self.m_dragonContainer:SetActive(false)
        self.m_dragonIconGrid.localScale = Vector3.New(1, 0, 1)
    elseif name == "TextBg10" then
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI, "TextBg10")
    end
end

function UILineupMainView:ClearLineup()
    self.m_lineupMgr:ClearLineup(self:GetBuZhenID())
    self:UpdateLineup()
end

function UILineupMainView:CheckEmployBeforFight()
    local isIllegal, reason = self.m_lineupMgr:IsLineupIllegal(self:GetBuZhenID())
    if isIllegal then
        self:CheckLineupBeforeFight()
    else
        local content = Language.GetString(1115)
        if reason == 34 then
            content = Language.GetString(1115)
        elseif reason == 35 then
            content = Language.GetString(1114)
        elseif reason == 281 then
            content = Language.GetString(1116)
        end
        UIManagerInst:OpenWindow(UIWindowNames.UINormalTipsDialog, Language.GetString(1107),content, Language.GetString(1109))
    end
end

function UILineupMainView:CheckLineupBeforeFight()
    local lineupRoleCount, haveEmployWujiang = self:GetLineupRoleCount()
    if lineupRoleCount == 0 then
        UIManagerInst:OpenWindow(UIWindowNames.UINormalTipsDialog, Language.GetString(1107),Language.GetString(1108), 
                                           Language.GetString(1109))
        return
    end

    if lineupRoleCount == 1 and haveEmployWujiang then
        UIManagerInst:OpenWindow(UIWindowNames.UINormalTipsDialog, Language.GetString(1107),Language.GetString(1120), 
                                           Language.GetString(1109))
        return
    end

    local allRoleCount = Player:GetInstance():GetWujiangMgr():GetWujiangCount()
    if lineupRoleCount < CommonDefine.LINEUP_WUJIANG_COUNT and lineupRoleCount < allRoleCount then
        UIManagerInst:OpenWindow(UIWindowNames.UINormalTipsDialog, Language.GetString(1107),Language.GetString(1106), 
        Language.GetString(10), Bind(self, self.StartFight), Language.GetString(5))
        return
    end

    self:StartFight()
end

function UILineupMainView:StartFight()
    local downloadList = {}
    local bRet = SceneManagerInst:CheckDownload(SceneConfig.BattleScene, downloadList, self.m_battleType, false, self.m_copyID)
    if bRet and not GuideMgr:GetInstance():IsPlayingGuide() then
        ABTipsMgr:GetInstance():ShowABLoadTips(downloadList, Bind(self, self.SendFightReq))
    else
        self:SendFightReq()
    end
end

function UILineupMainView:SendFightReq()
    if self.m_battleType == BattleEnum.BattleType_COPY then
        self.m_lineupMgr:ReqEnterCopy(self.m_copyID)
    elseif self.m_battleType == BattleEnum.BattleType_BOSS1 or self.m_battleType == BattleEnum.BattleType_BOSS2 then
        self.m_lineupMgr:ReqEnterBoss(self.m_battleType)
    elseif self.m_battleType == BattleEnum.BattleType_ARENA then
        Player:GetInstance():GetArenaMgr():ReqEnterArena()
    elseif self.m_battleType == BattleEnum.BattleType_INSCRIPTION then
        self.m_lineupMgr:ReqEnterInscriptionCopy(self.m_copyID)
    elseif self.m_battleType == BattleEnum.BattleType_SHENSHOU then
        self.m_lineupMgr:ReqEnterShenShouCopy(self.m_copyID)
    elseif self.m_battleType == BattleEnum.BattleType_GUILD_BOSS then
        self.m_lineupMgr:ReqEnterGuildBoss(self.m_copyID)
    elseif self.m_battleType == BattleEnum.BattleType_SHENBING then
        self.m_lineupMgr:ReqEnterShenbingCopy(self.m_copyID)
    elseif self.m_battleType == BattleEnum.BattleType_YUANMEN then
        self.m_lineupMgr:ReqEnterYuanmenCopy(self.m_copyID)
    elseif self.m_battleType == BattleEnum.BattleType_GRAVE then
        self.m_lineupMgr:ReqEnterGraveCopy(self.m_copyID)
    elseif self.m_battleType == BattleEnum.BattleType_FRIEND_CHALLENGE then
        self.m_friendMgr:ReqEnterQieCuo()
    elseif self.m_battleType == BattleEnum.BattleType_GUILD_WARCRAFT then
        self.m_lineupMgr:ReqEnterGuildWarCopy(Player:GetInstance():GetGuildWarMgr():GetWarBriefData().attackCityID)
    elseif self.m_battleType == BattleEnum.BattleType_ROB_GUILD_HUSONG then
        local rob_uid, rob_stage = Player:GetInstance():GetGuildWarMgr():GetRobInfo()
        self.m_lineupMgr:ReqEnterGuildWarRobCopy(rob_uid, rob_stage)
    elseif self.m_battleType == BattleEnum.BattleType_LIEZHUAN then
        self.m_lineupMgr:ReqEnterLieZhuanSingleCopy(self.m_copyID)
    end
end

function UILineupMainView:GetLineupRoleCount()
    local count = 0
    local haveEmployWujiang = false
    self.m_lineupMgr:Walk(self:GetBuZhenID(), function(wujiangBriefData, isMain, isEmploy)
        count = count + 1
        if isEmploy then
            haveEmployWujiang = true
        end
    end)
    return count, haveEmployWujiang
end

function UILineupMainView:UpdateLineup()
    self:UpdateLineupIcons()
    self:UpdateWujiang()
    self:UpdateDragonBtn()

    local nowPower = self.m_lineupMgr:GetLineupTotalPower(self:GetBuZhenID())
    UILogicUtil.PowerChange(nowPower - self.m_power, -170)
    self.m_power = self.m_lineupMgr:GetLineupTotalPower(self:GetBuZhenID())
    self.m_powerText.text = string.format("%d", self.m_lineupMgr:GetLineupTotalPower(self:GetBuZhenID()))
end

function UILineupMainView:UpdateDragonBtn()
    local dragon = self.m_lineupMgr:GetLineupDragon(self:GetBuZhenID())
    if dragon > 0 then
        UILogicUtil.SetDragonIcon(self.m_dragonBtnImage, dragon)
    else
        local defaultDragon = self:GetDefaultGodBeast()
        if defaultDragon then
            self.m_dragonBtn:SetActive(true)
            UILogicUtil.SetDragonIcon(self.m_dragonBtnImage, defaultDragon)
            self.m_lineupMgr:SetLineupDragon(self:GetBuZhenID(), defaultDragon)
        else
            self.m_dragonBtn:SetActive(false)
        end
    end
end

function UILineupMainView:GetBuZhenID()
    local buZhenId = Utils.GetBuZhenIDByBattleType(self.m_battleType)
    if self.m_battleType == BattleEnum.BattleType_LIEZHUAN then
        buZhenId = Player:GetInstance():GetLieZhuanMgr():GetSelectCountry()*10000 + buZhenId
    end
    return buZhenId
end

function UILineupMainView:GetDefaultGodBeast()
    local godBeasdMgr = Player:GetInstance():GetGodBeastMgr()
    local dragonList = ConfigUtil.GetGodBeastCfgList()
    for id,_ in pairs(dragonList) do
        if godBeasdMgr:GetGodBeastByID(id) then
            return id
        end
    end
end

function UILineupMainView:UpdateWujiang()
    self:CreateRoleContainer()

    -- 刷新武将.
    self:WalkLineup(function(standPos, wujiangBriefData, isEmploy)
        if wujiangBriefData then
            if self.m_wujiangLoadingSeqList[standPos] and self.m_wujiangLoadingSeqList[standPos] > 0 then
                -- 已经在加载了, 取消重新加载
                ActorShowLoader:GetInstance():CancelLoad(self.m_wujiangLoadingSeqList[standPos])
                self.m_wujiangLoadingSeqList[standPos] = 0
            end

            local actorShow = self.m_wujiangShowList[standPos]
            local weaponLevel = wujiangBriefData.weaponLevel
            if not actorShow or actorShow:GetWuJiangID() ~= wujiangBriefData.id or 
                PreloadHelper.WuqiLevelToResLevel(actorShow:GetWuQiLevel()) ~= PreloadHelper.WuqiLevelToResLevel(weaponLevel) then
                -- 武将未加载，或者已经存在但是不是同一个了重新加载
                self:LoadWuJiangModel(standPos, wujiangBriefData.id, weaponLevel)                
            else
                -- 这个位置上的武将没有变化，不再加载
            end
        else
            self:ModifyLineupSeq(standPos, 0)
            --这个位置上的武将被下了，回收模型
            if self.m_wujiangShowList[standPos] then
                self.m_wujiangShowList[standPos]:Delete()
                self.m_wujiangShowList[standPos] = nil
            end
        end
    end)
end

function UILineupMainView:LoadWuJiangModel(standPos, wujiangID, weaponLevel)
    local loadingSeq = ActorShowLoader:GetInstance():PrepareOneSeq()
    self.m_wujiangLoadingSeqList[standPos] = loadingSeq
    
    local showParam = ActorShowLoader.MakeParam(wujiangID, weaponLevel)
    showParam.stageSound = true

    ActorShowLoader:GetInstance():CreateShowOffWuJiang(loadingSeq, showParam, self.m_roleContainerTrans, function(actorShow)
        self.m_wujiangLoadingSeqList[standPos] = 0
        
        -- 把当前位置上的武将回收了
        if self.m_wujiangShowList[standPos] then
            self.m_wujiangShowList[standPos]:Delete()
            self.m_wujiangShowList[standPos] = nil
        end
        self.m_wujiangShowList[standPos] = actorShow
    
        if actorShow:GetPetID() > 0 then
            actorShow:SetPosition(self:GetStandPos(standPos) - PetPosOffset)
        else
            actorShow:SetPosition(self:GetStandPos(standPos))
        end
        actorShow:SetEulerAngles(self:GetWujiangEuler(standPos))

        if self.m_selectWujiangPos and self.m_selectWujiangPos == standPos then
            actorShow:PlayAnim(BattleEnum.ANIM_SHOWOFF)
            actorShow:PlayStageAudio()

            self.m_selectWujiangPos = nil
        else
            actorShow:PlayAnim(BattleEnum.ANIM_IDLE)
        end
    end)
end

function UILineupMainView:UpdateLineupIcons()
      -- 刷新icon
      if #self.m_wujiangIconList == 0 and self.m_iconSeq == 0 then
        self.m_iconSeq = loaderInstance:PrepareOneSeq()
        loaderInstance:GetGameObjects(self.m_iconSeq, CardItemPath, CommonDefine.LINEUP_WUJIANG_COUNT, function(objs)
            self.m_iconSeq = 0
            if objs then
                for i = 1, #objs do
                    objs[i].name = "lineupItem_" .. i
                    self:HandleDrag(objs[i])

                    local wujiangItem = LineupWuJiangCardItem.New(objs[i], self:GetIconParent(), CardItemPath)
                    table_insert(self.m_wujiangIconList, wujiangItem)
                end

                self:HideAllIcon()
                self:WalkLineup(function(standPos, wujiangBriefData, isEmploy)
                    if wujiangBriefData then
                        self.m_wujiangIconList[standPos]:SetData(wujiangBriefData)
                        local isLineupIllegal = true
                        if isEmploy then 
                            isLineupIllegal = self.m_lineupMgr:IsEmployIllegal(self:GetBuZhenID())
                        end
                        self.m_wujiangIconList[standPos]:SetIconColor(isLineupIllegal and Color.white or Color.red) 
                    end
                end)
            end
        end)
    else
        self:HideAllIcon()
        self:WalkLineup(function(standPos, wujiangBriefData, isEmploy)
            if wujiangBriefData then
                self.m_wujiangIconList[standPos]:SetData(wujiangBriefData)
                local isLineupIllegal = true
                if isEmploy then 
                    isLineupIllegal = self.m_lineupMgr:IsEmployIllegal(self:GetBuZhenID())
                end
                self.m_wujiangIconList[standPos]:SetIconColor(isLineupIllegal and Color.white or Color.red) 
            end
        end)
    end
end 

function UILineupMainView:HideAllIcon()
    for _, wujiangItem in pairs(self.m_wujiangIconList) do
        wujiangItem:HideAll()
    end
end

function UILineupMainView:GetStandPos(standPos)
    if not self.m_standPosList then
        self.m_standPosList = {
            Vector3.New(0, 0, 5.64), 
            Vector3.New(-2.35, 0, 6.41), 
            Vector3.New(2.35, 0, 6.41),  
            Vector3.New(-1.19, 0, 7.68),
            Vector3.New(1.19, 0, 7.68)
        }
    end
    return self.m_standPosList[standPos]
end

function UILineupMainView:GetWujiangEuler(standPos)
    if not self.m_wujiangEulerList then
        self.m_wujiangEulerList = {
            Vector3.New(0, 180, 0), 
            Vector3.New(0, 180, 0),  
            Vector3.New(0, 180, 0),  
            Vector3.New(0, 180, 0),  
            Vector3.New(0, 180, 0)
        }
    end
    return self.m_wujiangEulerList[standPos]
end

function UILineupMainView:HandleDrag(dragGO)
    local function DragBegin(go, x, y, eventData)
        self:OnDragBegin(go, x, y, eventData)
    end

    local function DragEnd(go, x, y, eventData)
        self:OnDragEnd(go, x, y, eventData)
    end

    local function Drag(go, x, y, eventData)
        self:OnDrag(go, x, y, eventData)
    end
   
    UIUtil.AddDragBeginEvent(dragGO, DragBegin)
    UIUtil.AddDragEndEvent(dragGO, DragEnd)
    UIUtil.AddDragEvent(dragGO, Drag)
end

function UILineupMainView:OnDragBegin(go, x, y, eventData)
    local dragTrans = go.transform
    self.m_transformIndex = dragTrans:GetSiblingIndex()
    if self.m_wujiangIconList[self.m_transformIndex + 1]:IsHide() then
        return
    end
    self.m_roleGrid.enabled = false
    self.m_benchRoleGrid.enabled = false

    local _, worldPos = ScreenPointToWorldPointInRectangle(self.m_roleRT, eventData.position, eventData.pressEventCamera)
    self.m_dragOffset = dragTrans.position - worldPos
    self.m_perviousParent = dragTrans.parent
    dragTrans:SetParent(self.m_roleParent)
    self.m_wujiangIconList[self.m_transformIndex + 1]:EnableRaycast(false)
    self:EnableItemRaycast(false)
end

function UILineupMainView:OnDragEnd(go, x, y, eventData)
    if self.m_wujiangIconList[self.m_transformIndex + 1]:IsHide() then
        return
    end

    self:EnableItemRaycast(true)
    -- 拖出来的头像放回原来的位置
    local dragTrans = go.transform
    dragTrans:SetParent(self.m_perviousParent)
    dragTrans:SetSiblingIndex(self.m_transformIndex)

    local dropGO = eventData.pointerCurrentRaycast.gameObject
    if IsNull(dropGO) then
        -- 拖到外面了，这个武将从阵容中去掉
        self:ModifyLineupSeq(self.m_transformIndex + 1, 0)
        self:UpdateLineup()
    elseif string.contains(dropGO.name, "itemBg_") then
        -- 交换武将阵容数据
        local dropGOIndex = dropGO.transform:GetSiblingIndex()
        self:SwapLineupSeq(self.m_transformIndex + 1, dropGOIndex + 1)
        -- 重新刷新icon,武将因为要做动画，单独刷新
        self:UpdateLineupIcons()
        self:SwapWujiang(self.m_transformIndex + 1, dropGOIndex + 1)
    else
        -- 拖到外面了，这个武将从阵容中去掉
        self:ModifyLineupSeq(self.m_transformIndex + 1, 0)
        self:UpdateLineup()
    end

    self.m_roleGrid.enabled = true
    self.m_benchRoleGrid.enabled = true
end

function UILineupMainView:SwapWujiang(index1, index2)
    -- 武将逻辑位置交换下
    local wujiang = self.m_wujiangShowList[index1]
    self.m_wujiangShowList[index1] = self.m_wujiangShowList[index2]
    self.m_wujiangShowList[index2] = wujiang
    -- 武将位置交换下
    if self.m_wujiangShowList[index1] then
        local trans = self.m_wujiangShowList[index1]:GetWujiangTransform()
        local tweener = DOTweenShortcut.DOLocalMove(trans, self:GetStandPos(index1), 0.2)
        self.m_wujiangShowList[index1]:SetEulerAngles(self:GetWujiangEuler(index1))
        DOTweenSettings.OnUpdate(tweener, function()
            self.m_wujiangShowList[index1]:SetPosition(trans.localPosition)
        end)
    end
    if self.m_wujiangShowList[index2] then
        local trans = self.m_wujiangShowList[index2]:GetWujiangTransform()
        local tweener = DOTweenShortcut.DOLocalMove(trans, self:GetStandPos(index2), 0.2)
        self.m_wujiangShowList[index2]:SetEulerAngles(self:GetWujiangEuler(index2))
        DOTweenSettings.OnUpdate(tweener, function()
            self.m_wujiangShowList[index2]:SetPosition(trans.localPosition)
        end)
    end
end

function UILineupMainView:OnDrag(go, x, y, eventData)
    if self.m_wujiangIconList[self.m_transformIndex + 1]:IsHide() then
        return
    end

    local _, nowPos = ScreenPointToWorldPointInRectangle(self.m_roleRT, eventData.position, eventData.pressEventCamera)
    go.transform.position = nowPos + self.m_dragOffset
end

function UILineupMainView:EnableItemRaycast(enabled)
    for _, item in pairs(self.m_wujiangIconList) do
        if item then
            item:EnableRaycast(enabled)
        end
    end
end

function UILineupMainView:OnClickWuJiangCardItem(standPos)
   -- TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI, tostring(standPos))
    self:OpenWujiangSeleteUI(standPos)
end

function UILineupMainView:OnSelectWuJiangCardItem(selectWujiangSeq, data1, standPos)

    self:ModifyLineupSeq(standPos, selectWujiangSeq)
    self.m_selectWujiangPos = standPos

    self:UpdateLineup()
    self:TweenItemPos(standPos)
end

function UILineupMainView:TweenItemPos(standPos)
    self.m_roleGrid.enabled = false
    self.m_benchRoleGrid.enabled = false
    UIUtil.KillTween(self.m_tweenner)
    local trans = self.m_wujiangIconList[standPos].transform
    local localPos = trans.localPosition
    trans.localPosition = Vector3.New(localPos.x, localPos.y + 30, 0)
    self.m_tweenner = DOTweenShortcut.DOLocalMoveY(trans, localPos.y, 0.5)
    DOTweenSettings.SetEase(self.m_tweenner, DoTweenEaseType.OutBounce)
    DOTweenSettings.OnComplete(self.m_tweenner, function()
        self.m_roleGrid.enabled = true
        self.m_benchRoleGrid.enabled = true
    end)
end

function UILineupMainView:OpenWujiangSeleteUI(standPos)
    if self.m_battleType == BattleEnum.BattleType_LIEZHUAN then
        UIManagerInst:OpenWindow(UIWindowNames.UILieZhuanLineupSelect, self.m_battleType, standPos)
        return
    end
    UIManagerInst:OpenWindow(UIWindowNames.UILineupSelect, self.m_battleType, standPos)
end

function UILineupMainView:RecyleModelAndIcon()
    loaderInstance:CancelLoad(self.m_iconSeq)
    self.m_iconSeq = 0

    for _,seq in pairs(self.m_wujiangLoadingSeqList) do
        if seq > 0 then
            ActorShowLoader:GetInstance():CancelLoad(seq)
        end
    end
    self.m_wujiangLoadingSeqList = {}

    for _,wujiangIcon in pairs(self.m_wujiangIconList) do
        UIUtil.RemoveDragEvent(wujiangIcon:GetGameObject())
        wujiangIcon:Delete()
    end
    self.m_wujiangIconList = {}

    for _,wujiangShow in pairs(self.m_wujiangShowList) do
        if wujiangShow then
            wujiangShow:Delete()
        end
    end

    self.m_petSeq = 0
    self.m_wujiangShowList = {}
end

function UILineupMainView:GetIconParent()
    return self.m_lineupRolesParent
end

function UILineupMainView:GetRecoverParam()
    return self.m_battleType, self.m_copyID
end

function UILineupMainView:CreateRoleContainer()
    if IsNull(self.m_roleContainerGo) then
        self.m_roleContainerGo = GameObject("RoleContainer")
        self.m_roleContainerTrans = self.m_roleContainerGo.transform

        self.m_sceneSeq = loaderInstance:PrepareOneSeq()
        loaderInstance:GetGameObject(self.m_sceneSeq, WujiangRootPath, function(go)
            self.m_sceneSeq = 0
            if not IsNull(go) then
                self.m_roleBgGo = go
                self.m_roleContainerTrans:SetParent(self.m_roleBgGo.transform)
                self.m_roleCameraTrans = self.m_roleBgGo.transform:Find("RoleCamera")
                self.m_roleCameraTrans.localRotation = Quaternion.Euler(3, 0, 0)
            end
            self:TweenOpen()
        end)
    end
end

function UILineupMainView:DestroyRoleContainer()
    if not IsNull(self.m_roleContainerGo) then
        GameObject.DestroyImmediate(self.m_roleContainerGo)
    end

    self.m_roleContainerGo = nil
    self.m_roleContainerTrans = nil
    self.m_roleCameraTrans = nil

    loaderInstance:CancelLoad(self.m_sceneSeq)
    self.m_sceneSeq = 0

    if not IsNull(self.m_roleBgGo) then
        loaderInstance:RecycleGameObject(WujiangRootPath, self.m_roleBgGo)
        self.m_roleBgGo = nil
    end
end

function UILineupMainView:WalkLineup(filter)
    self.m_lineupMgr:WalkMain(self:GetBuZhenID(), filter)
end

function UILineupMainView:ModifyLineupSeq(standPos, newSeq)
    self.m_lineupMgr:ModifyLineupSeq(self:GetBuZhenID(), false, standPos, newSeq)
end

function UILineupMainView:SwapLineupSeq(standPos1, standPos2)
    self.m_lineupMgr:SwapLineupSeq(self:GetBuZhenID(), false, standPos1, standPos2)
end

function UILineupMainView:Update()
    if isEditor then
        if CS.UnityEngine.Input.GetKeyDown(CS.UnityEngine.KeyCode.P) then
            self.m_lineupMgr:EnablePlotMode()
        end
       

        if CS.UnityEngine.Input.GetKeyDown(CS.UnityEngine.KeyCode.F4) then
            GuideMgr:GetInstance():Clear()
        end
    end
end

function UILineupMainView:IsCheckLineupIllegal()
    return true
end

function UILineupMainView:TweenOpen()

    local backBtnPos = self.m_backBtn.anchoredPosition
    
    DOTween.ToFloatValue(function()
        return 0
    end, 
    function(value)
        self.m_topContainer.anchoredPosition = Vector3.New(0, 130 - 130 * value, 0)
        self.m_backBtn.anchoredPosition = Vector3.New(backBtnPos.x, backBtnPos.y + 130 - 130 * value, 0)
        -- local pos = Vector3.New(0, 0.9, 0.6 + 0.4 * value)
        -- self.m_roleCameraTrans.localPosition = pos

        GameUtility.SetLocalPosition(self.m_roleCameraTrans, 0, 0.9, 0.6 + 0.4 * value)
    end, 1, 0.3)

    local tweener = DOTween.ToFloatValue(function()
        return 0
    end, 
    function(value)
        self.m_bottomContainer.anchoredPosition = Vector3.New(0, -133 + 260 * value, 0)
    end, 1, 0.4)
    DOTweenSettings.SetEase(tweener, DoTweenEaseType.InOutBack)

    DOTweenSettings.OnComplete(tweener, function()
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)
    end)
end

function UILineupMainView:InitDragonIcon()
    local seq = loaderInstance:PrepareOneSeq()
    loaderInstance:GetGameObjects(seq, DragonIconPath, CommonDefine.LINEUP_DRAGON_COUNT, function(objs)
        if objs then
            for i = 1, #objs do
                local dragonIconItem = DragonIconItem.New(objs[i], self.m_dragonIconGrid, DragonIconPath)
                table_insert(self.m_dragonIconItemList, dragonIconItem)
            end
            self.m_dragonIconGrid.localScale = Vector3.New(1, 0, 1)
        end
    end)

    local seq1 = loaderInstance:PrepareOneSeq()
    loaderInstance:GetGameObjects(seq1, TalentItemPath, CommonDefine.DRAGON_TELENT_COUNT, function(objs)
        if objs then
            for i = 1, #objs do
                local dragonTalentItem = DragonTalentItem.New(objs[i], self.m_talentItemGrid, TalentItemPath)
                table_insert(self.m_talentIconList, dragonTalentItem)
            end
        end
    end)
end

function UILineupMainView:OpenDragonPanel()
    self:UpdateDragonPanel()

    self.m_dragonContainer:SetActive(true)
    self.m_dragonIconGrid.localScale = Vector3.New(1, 0, 1)
    local tweener = DOTween.ToFloatValue(function()
        return 0
    end, 
    function(value)
        self.m_dragonIconGrid.localScale = Vector3.New(1, value, 1)
    end, 1, 0.3)

    DOTweenSettings.OnComplete(tweener, function()
    end)
end

function UILineupMainView:UpdateDragonPanel()
    local curDragonID = self.m_lineupMgr:GetLineupDragon(self:GetBuZhenID())
    local godBeasdMgr = Player:GetInstance():GetGodBeastMgr()
    local dragonList = table_keys(ConfigUtil.GetGodBeastCfgList())
    for i,id in ipairs(dragonList) do
        local dragonData = godBeasdMgr:GetGodBeastByID(id)
        self.m_dragonIconItemList[i]:SetData(id, dragonData == nil)
        self.m_dragonIconItemList[i]:OnSelect(id == curDragonID)
    end
    local curDragonData = godBeasdMgr:GetGodBeastByID(curDragonID)
    if curDragonData then
        for i = 1, CommonDefine.DRAGON_TELENT_COUNT do
            local talentData = nil
            if curDragonData.dragon_talent_list then
                talentData = curDragonData.dragon_talent_list[i]
            end
            self.m_talentIconList[i]:SetData(talentData)
        end
    end

    self:UpdateDragonSkillDec()
    local dragonCfg = ConfigUtil.GetGodBeastCfgByID(curDragonID)
    if dragonCfg then
        self.m_dragonNameText.text = string_format(Language.GetString(1125), dragonCfg.sName, curDragonData.level)
    end
end

function UILineupMainView:OnClickDragonIcon(dragonID)
    self.m_lineupMgr:SetLineupDragon(self:GetBuZhenID(), dragonID)
    self:UpdateDragonPanel()
    self:UpdateDragonBtn()
end

function UILineupMainView:UpdateDragonSkillDec() 
    local dragonID = self.m_lineupMgr:GetLineupDragon(self:GetBuZhenID())
    local dragonCfg = ConfigUtil.GetGodBeastCfgByID(dragonID)
    local dragonData = Player:GetInstance():GetGodBeastMgr():GetGodBeastByID(dragonID)
    local str = dragonCfg.sSkillDesc
    local x = dragonCfg.x + dragonCfg.ax * dragonData.level
    local x1 = math_ceil(x)
    x = x == x1 and x1 or x

    local skillCount = 0
    for k,v in pairs(dragonCfg.unlocklevel) do
        if dragonData.level >= v then
            skillCount = skillCount + 1
        end
    end

    local y = dragonCfg.y + dragonCfg.ay * skillCount
    local y1 = math_ceil(y)
    y = y == y1 and y1 or y

    str = str:gsub("{x}", "<color=#1feb0b>" .. x .. "</color>")
    str = str:gsub("{y}", y)
    self.m_skillDesText.text = "<color=#ffeea4>" .. dragonCfg.sSkillName .. "</color>".."："..str
end

function UILineupMainView:ClickFightBtn()
    UIUtil.TryClick(self.m_fightBtn)
    if self.m_battleType == BattleEnum.BattleType_ARENA and GuideMgr:GetInstance():IsPlayingGuide(GuideEnum.GUIDE_ARENA1) then
        self:SendFightReq()
    else
        self:CheckEmployBeforFight()
    end
end

return UILineupMainView