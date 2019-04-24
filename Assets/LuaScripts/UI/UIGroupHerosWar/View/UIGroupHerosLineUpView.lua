local UIGroupHerosLineUpView = BaseClass("UIGroupHerosLineUpView", UIBaseView)
local base = UIBaseView
local table_insert = table.insert
local CSObject = CS.UnityEngine.Object
local Type_GridLayoutGroup = typeof(CS.UnityEngine.UI.GridLayoutGroup)
local ScreenPointToWorldPointInRectangle = CS.UnityEngine.RectTransformUtility.ScreenPointToWorldPointInRectangle
local Type_RectTransform = typeof(CS.UnityEngine.RectTransform)
local SplitString = CUtil.SplitString
local BattleEnum = BattleEnum
local Utils = Utils
local CommonDefine = CommonDefine
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTween = CS.DOTween.DOTween
local GameObject = CS.UnityEngine.GameObject
local Vector2 = Vector2
local Vector3 = Vector3
local isEditor = CS.GameUtility.IsEditor()
local table_keys = table.keys
local math_ceil = math.ceil
local math_floor = math.floor
local string_format = string.format
local loaderInstance = UIGameObjectLoader:GetInstance()
local Language = Language
local UILogicUtil = UILogicUtil

local UserItemPrefab = TheGameIds.UserItemPrefab
local UserItemClass = require("UI.UIUser.UserItem")
local WujiangRootPath = "UI/Prefabs/GroupHerosWar/WujiangRoot.prefab"
local LineupWuJiangCardItem = require "UI.UIWuJiang.View.LineupWuJiangCardItem"
local CardItemPath = TheGameIds.CommonWujiangCardPrefab
local DragonIconItem = require "UI.Lineup.DragonIconItem"
local DragonIconPath = TheGameIds.DragonIconItemPrefab
local DragonTalentItem = require "UI.Lineup.DragonTalentItem"
local TalentItemPath = TheGameIds.TalentItemPrefab
local GroupHerosMgr = Player:GetInstance():GetGroupHerosMgr()

local PetPosOffset = Vector3.New(0.1, 0, 0)
 
function UIGroupHerosLineUpView:OnCreate()
    base.OnCreate(self)

    self:InitVariable()
    self:InitView()
    self:InitDragonIcon()
end

function UIGroupHerosLineUpView:OnEnable(...)
    base.OnEnable(self, ...)
    local initorder, score, rivalInfo, prepareDeadline
    initorder, self.m_battleType, score, rivalInfo, prepareDeadline = ...

    if prepareDeadline then
        self.m_prepareDeadline = prepareDeadline - Player:GetInstance():GetServerTime()
    else
        self.m_prepareDeadline = 0
    end
    self:CreateRoleContainer()
    --第一次打时获取副本阵容
    self:WalkLineup(function(standPos, wujiangBriefData, isEmploy)
    end)

    self.m_power = self.m_lineupMgr:GetLineupTotalPower(Utils.GetBuZhenIDByBattleType(self.m_battleType))
    self:UpdateRivalInfo(rivalInfo)
    self:UpdateUserInfo(score)
    self:RspArrangeBuzhen()
    self:UpdateLineup()
    self:HandleClick()

    self.m_readyGo:SetActive(false)
    self.m_maskGo:SetActive(false)
    if self:IsCheckLineupIllegal() then
        self.m_lineupMgr:ReqBuzhenIllegal(Utils.GetBuZhenIDByBattleType(self.m_battleType))
    end
end

function UIGroupHerosLineUpView:OnAddListener()
	base.OnAddListener(self)
	-- UI消息注册
    self:AddUIListener(UIMessageNames.MN_LINEUP_ITEM_SELECT, self.OnClickWuJiangCardItem)
    self:AddUIListener(UIMessageNames.MN_WUJIANG_SELECT, self.OnSelectWuJiangCardItem)
    self:AddUIListener(UIMessageNames.MN_LINEUP_APPLY_NEW, self.UpdateLineup)
    self:AddUIListener(UIMessageNames.MN_LINEUP_CHECK_LINEUP_ILLEGAL, self.UpdateLineup)
    self:AddUIListener(UIMessageNames.MN_LINEUP_CLICK_DRAGON, self.OnClickDragonIcon)
    self:AddUIListener(UIMessageNames.MN_QUNXIONGZHULU_NTF_RIVAL_BUZHEN_CHG, self.UpdateRivalWujiang)
    self:AddUIListener(UIMessageNames.MN_QUNXIONGZHULU_RSP_READY, self.RspReady)
    self:AddUIListener(UIMessageNames.MN_QUNXIONGZHULU_RSP_ARRANGE_BUZHEN, self.RspArrangeBuzhen)
    self:AddUIListener(UIMessageNames.MN_QUNXIONGZHULU_RSP_QUIT_BATTLE, self.RspQuitBattle)
    self:AddUIListener(UIMessageNames.MN_QUNXIONGZHULU_NTF_PREPARE_DEADLINE, self.UpdateDeadline)
end


function UIGroupHerosLineUpView:OnRemoveListener()
	base.OnRemoveListener(self)
	-- UI消息注销
    self:RemoveUIListener(UIMessageNames.MN_LINEUP_ITEM_SELECT, self.OnClickWuJiangCardItem)
    self:RemoveUIListener(UIMessageNames.MN_WUJIANG_SELECT, self.OnSelectWuJiangCardItem)
    self:RemoveUIListener(UIMessageNames.MN_LINEUP_APPLY_NEW, self.UpdateLineup)
    self:RemoveUIListener(UIMessageNames.MN_LINEUP_CHECK_LINEUP_ILLEGAL, self.UpdateLineup)
    self:RemoveUIListener(UIMessageNames.MN_LINEUP_CLICK_DRAGON, self.OnClickDragonIcon)
    self:RemoveUIListener(UIMessageNames.MN_QUNXIONGZHULU_NTF_RIVAL_BUZHEN_CHG, self.UpdateRivalWujiang)
    self:RemoveUIListener(UIMessageNames.MN_QUNXIONGZHULU_RSP_READY, self.RspReady)
    self:RemoveUIListener(UIMessageNames.MN_QUNXIONGZHULU_RSP_ARRANGE_BUZHEN, self.RspArrangeBuzhen)
    self:RemoveUIListener(UIMessageNames.MN_QUNXIONGZHULU_RSP_QUIT_BATTLE, self.RspQuitBattle)
    self:RemoveUIListener(UIMessageNames.MN_QUNXIONGZHULU_NTF_PREPARE_DEADLINE, self.UpdateDeadline)
end

function UIGroupHerosLineUpView:UpdateDeadline(time)
    self.m_prepareDeadline = time - Player:GetInstance():GetServerTime()
end

function UIGroupHerosLineUpView:RspQuitBattle()
    self:CloseSelf()
end

function UIGroupHerosLineUpView:RspArrangeBuzhen()
    self:UpdateLineupIcons()
    self:UpdateWujiang()
    self:UpdateDragonBtn()
    
    local nowPower = self.m_lineupMgr:GetLineupTotalPower(Utils.GetBuZhenIDByBattleType(self.m_battleType))
    UILogicUtil.PowerChange(nowPower - self.m_power, -170)
    self.m_power = self.m_lineupMgr:GetLineupTotalPower(Utils.GetBuZhenIDByBattleType(self.m_battleType))
    self.m_powerText.text = string.format("%d", self.m_lineupMgr:GetLineupTotalPower(Utils.GetBuZhenIDByBattleType(self.m_battleType)))
end

function UIGroupHerosLineUpView:RspReady()
    self.m_readyGo:SetActive(true)
    self.m_maskGo:SetActive(true)
end

function UIGroupHerosLineUpView:OnDisable()
    self:RecyleModelAndIcon()
    self:RemoveEvent()
    self:DestroyRoleContainer()

    self.m_prepareDeadline = 0
    self.m_perviousParent = nil
    self.m_transformIndex = 0

    base.OnDisable(self)
end

-- 初始化非UI变量
function UIGroupHerosLineUpView:InitVariable()
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
    self.m_rivalWujiangShowList = {}
    self.m_rivalWujiangLoadSeqList = {}
    self.m_userIconItem = nil
    self.m_userSeq = 0
    self.m_rivalIconItem = nil
    self.m_rivalSeq = 0
    self.m_prepareDeadline = 0
    self.m_rivalWujiangList = {}
    self.m_power = 0
end

-- 初始化UI变量
function UIGroupHerosLineUpView:InitView()
    local powerDesText, clearText, lineupManageBtnText, userScoreDescText, rivalScoreDescText, userServerDescText,
    rivalServerDescText
    self.m_powerText, powerDesText, clearText, lineupManageBtnText, self.m_skillNameText, self.m_skillDesText,
    self.m_talnetNameText, self.m_dragonNameText, userScoreDescText, rivalScoreDescText, self.m_userScoreText,
    self.m_rivalScoreText, userServerDescText, rivalServerDescText, self.m_userServerText, self.m_rivalServerText,
    self.m_userNameText, self.m_rivalNameText, self.m_beginLeftTimeText = UIUtil.GetChildTexts(self.transform, {
        "BottomContainer/center/powerBg/powerText",
        "BottomContainer/center/powerBg/powerDesText",
        "TopContainer/clearBtn/clearText",
        "TopContainer/lineupManageBtn/lineupManageBtnText",
        "DragonContainer/bgImg/skillNameText",
        "DragonContainer/bgImg/skillDesText",
        "DragonContainer/bgImg/talnetNameText",
        "DragonContainer/titleImg/dragonNameText",
        "TopContainer/UserInfo/Score",
        "TopContainer/RivalInfo/Score",
        "TopContainer/UserInfo/ScoreText",
        "TopContainer/RivalInfo/ScoreText",
        "TopContainer/UserInfo/Server",
        "TopContainer/RivalInfo/Server",
        "TopContainer/UserInfo/ServerText",
        "TopContainer/RivalInfo/ServerText",
        "TopContainer/UserInfo/UserName",
        "TopContainer/RivalInfo/UserName",
        "TopContainer/Battle/LeftTime",
    })
    powerDesText.text = Language.GetString(1102)
    clearText.text = Language.GetString(1101)
    lineupManageBtnText.text = Language.GetString(1100)
    self.m_skillNameText.text = Language.GetString(1123)
    self.m_talnetNameText.text = Language.GetString(1124)
    userScoreDescText.text = Language.GetString(3971)
    rivalScoreDescText.text = Language.GetString(3971)
    userServerDescText.text = Language.GetString(3972)
    rivalServerDescText.text = Language.GetString(3972)

    local iconBg1,iconBg2,iconBg3,iconBg4,iconBg5
    iconBg1, iconBg2, iconBg3, iconBg4, iconBg5, self.m_lineupRolesParent, self.m_backBtn, self.m_roleParent,
    self.m_lineupManagerBtn, self.m_clearBtn, self.m_fightBtn, self.m_bottomContainer, self.m_lineupRoleContent,
    self.m_topContainer, self.m_dragonContainer, self.m_dragonBtn, self.m_talentItemGrid, self.m_dragonIconGrid,
    self.m_dragonBg, self.m_dragonCloseBtn, self.m_readyTr, self.m_maskTr, self.m_userIconTr, self.m_rivalIconTr = UIUtil.GetChildRectTrans(self.transform, {
        "BottomContainer/center/LineupRoleContent/roleBg/itemBg_1",
        "BottomContainer/center/LineupRoleContent/roleBg/itemBg_2",
        "BottomContainer/center/LineupRoleContent/roleBg/itemBg_3",
        "BottomContainer/center/LineupRoleContent/roleBg/itemBg_4",
        "BottomContainer/center/LineupRoleContent/roleBg/itemBg_5",
        "BottomContainer/center/LineupRoleContent/lineupRoles",
        "TopContainer/Panel/backBtn",
        "BottomContainer/center/roleParent",
        "TopContainer/lineupManageBtn",
        "TopContainer/clearBtn",
        "BottomContainer/center/fightBtn",
        "BottomContainer",
        "BottomContainer/center/LineupRoleContent",
        "TopContainer",
        "DragonContainer",
        "BottomContainer/center/dragonBtn",
        "DragonContainer/bgImg/talentItemGrid",
        "BottomContainer/center/dragonIconGrid",
        "DragonContainer/dragonBg",
        "DragonContainer/dragonCloseBtn",
        "BottomContainer/center/Ready",
        "Mask",
        "TopContainer/UserInfo/IconPos",
        "TopContainer/RivalInfo/IconPos",
    })

    self.m_readyGo = self.m_readyTr.gameObject
    self.m_maskGo = self.m_maskTr.gameObject
    self.m_dragonBtn = self.m_dragonBtn.gameObject
    self.m_dragonContainer = self.m_dragonContainer.gameObject
    self.m_lineupRoleContent = self.m_lineupRoleContent.gameObject
    self.m_roleBgList = {iconBg1.gameObject,iconBg2.gameObject,iconBg3.gameObject,iconBg4.gameObject,iconBg5.gameObject}
    self.m_roleGrid = self.m_lineupRolesParent:GetComponent(Type_GridLayoutGroup)
    self.m_roleRT = UIUtil.FindComponent(self.m_lineupRolesParent, Type_RectTransform)

    self.m_dragonBtnImage = UIUtil.AddComponent(UIImage, self, "BottomContainer/center/dragonBtn", AtlasConfig.DynamicLoad)
    self.m_rivalDragonImg = UIUtil.AddComponent(UIImage, self, "TopContainer/RivalInfo/DragonImg", AtlasConfig.DynamicLoad)
    self.m_dragonContainer:SetActive(false)
    self.m_maskGo:SetActive(false)
end

function UIGroupHerosLineUpView:SetParent(trans, pos, parent)
    trans:SetParent(parent)
    trans.localPosition = pos
    trans.localScale = Vector3.one
end

function UIGroupHerosLineUpView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_lineupManagerBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_clearBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_fightBtn.gameObject, onClick)
    for _,roleBgTrans in pairs(self.m_roleBgList) do
        UIUtil.AddClickEvent(roleBgTrans, onClick)
    end
    UIUtil.AddClickEvent(self.m_dragonBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_dragonBg.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_dragonCloseBtn.gameObject, onClick)
end

function UIGroupHerosLineUpView:RemoveEvent()
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_lineupManagerBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_clearBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_fightBtn.gameObject)
    for _,roleBgTrans in pairs(self.m_roleBgList) do
        UIUtil.RemoveClickEvent(roleBgTrans)
    end
    UIUtil.RemoveClickEvent(self.m_dragonBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_dragonBg.gameObject)
    UIUtil.RemoveClickEvent(self.m_dragonCloseBtn.gameObject)
end

function UIGroupHerosLineUpView:OnClick(go, x, y)
    local name = go.name
    if name == "backBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(9), Language.GetString(4000), Language.GetString(10), Bind(GroupHerosMgr, GroupHerosMgr.ReqQuitBattle), Language.GetString(50))
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
        UIManagerInst:OpenWindow(UIWindowNames.UILineupManager, self.m_battleType, false)
    elseif name == "clearBtn" then
        self:ClearLineup()
    elseif name == "fightBtn" then
        -- self:ClickFightBtn()
        GroupHerosMgr:ReqReady()
    elseif name == "dragonBtn" then
        self:OpenDragonPanel()
    elseif name == "dragonBg" then
        self.m_dragonContainer:SetActive(false)
        self.m_dragonIconGrid.localScale = Vector3.New(1, 0, 1)
    elseif name == "dragonCloseBtn" then
        self.m_dragonContainer:SetActive(false)
        self.m_dragonIconGrid.localScale = Vector3.New(1, 0, 1)
    else
        
    end
end

function UIGroupHerosLineUpView:ClearLineup()
    self.m_lineupMgr:ClearLineup(Utils.GetBuZhenIDByBattleType(self.m_battleType))
    self:UpdateLineup()
end


function UIGroupHerosLineUpView:UpdateLineup()
    

    GroupHerosMgr:ReqArrangeBuzhen(Utils.GetBuZhenIDByBattleType(self.m_battleType))
end

function UIGroupHerosLineUpView:UpdateDragonBtn()
    local dragon = self.m_lineupMgr:GetLineupDragon(Utils.GetBuZhenIDByBattleType(self.m_battleType))
    if dragon > 0 then
        UILogicUtil.SetDragonIcon(self.m_dragonBtnImage, dragon)
    else
        local defaultDragon = self:GetDefaultGodBeast()
        if defaultDragon then
            self.m_dragonBtn:SetActive(true)
            UILogicUtil.SetDragonIcon(self.m_dragonBtnImage, defaultDragon)
            self.m_lineupMgr:SetLineupDragon(Utils.GetBuZhenIDByBattleType(self.m_battleType), defaultDragon)
        else
            self.m_dragonBtn:SetActive(false)
        end
    end
end

function UIGroupHerosLineUpView:GetDefaultGodBeast()
    local godBeasdMgr = Player:GetInstance():GetGodBeastMgr()
    local dragonList = ConfigUtil.GetGodBeastCfgList()
    for id,_ in pairs(dragonList) do
        if godBeasdMgr:GetGodBeastByID(id) then
            return id
        end
    end
end

function UIGroupHerosLineUpView:UpdateUserInfo(score)
    local userData = Player:GetInstance():GetUserMgr():GetUserData()
    if not userData then
        return
    end

    if not self.m_userIconItem and self.m_userSeq == 0 then
        self.m_userSeq = loaderInstance:PrepareOneSeq()
        loaderInstance:GetGameObject(self.m_userSeq, UserItemPrefab, function(obj)
            self.m_userSeq = 0
            if not obj then
                return
            end
            self.m_userIconItem = UserItemClass.New(obj, self.m_userIconTr, UserItemPrefab)
            self.m_userIconItem:UpdateData(userData.use_icon_data.icon, userData.use_icon_data.icon_box, userData.level)
        end)
    else
        self.m_userIconItem:UpdateData(userData.use_icon_data.icon, userData.use_icon_data.icon_box, userData.level)
    end
    self.m_userNameText.text = userData.name
    self.m_userScoreText.text = math_ceil(score) 
    self.m_userServerText.text = userData.dist_name
end

function UIGroupHerosLineUpView:UpdateRivalInfo(rivalInfo)
    if not self.m_rivalIconItem and self.m_rivalSeq == 0 then
        self.m_rivalSeq = loaderInstance:PrepareOneSeq()
        loaderInstance:GetGameObject(self.m_rivalSeq, UserItemPrefab, function(obj)
            self.m_rivalSeq = 0
            if not obj then
                return
            end
            self.m_rivalIconItem = UserItemClass.New(obj, self.m_rivalIconTr, UserItemPrefab)
            self.m_rivalIconItem:UpdateData(rivalInfo.user_brief.use_icon.icon, rivalInfo.user_brief.use_icon.icon_box, rivalInfo.user_brief.level)
        end)
    else
        self.m_rivalIconItem:UpdateData(rivalInfo.user_brief.use_icon.icon, rivalInfo.user_brief.use_icon.icon_box, rivalInfo.user_brief.level)
    end

    self.m_rivalNameText.text = rivalInfo.user_brief.name
    self.m_rivalScoreText.text = math_ceil(rivalInfo.score)
    self.m_rivalServerText.text = rivalInfo.user_brief.dist_name
    self.m_rivalWujiangList = rivalInfo.def_wujiang_list
    self:UpdateRivalWujiang(rivalInfo.def_wujiang_list, rivalInfo.buzhen_info.summon)
end

function UIGroupHerosLineUpView:UpdateRivalWujiang(wujiangBriefList, dragon)
    UILogicUtil.SetDragonIcon(self.m_rivalDragonImg, dragon)
    for standPos = 1, CommonDefine.LINEUP_WUJIANG_COUNT do
        local wujiangBriefData = wujiangBriefList[standPos]
        if wujiangBriefData then
            if self.m_rivalWujiangLoadSeqList[standPos] and self.m_rivalWujiangLoadSeqList[standPos] > 0 then
                ActorShowLoader:GetInstance():CancelLoad(self.m_rivalWujiangLoadSeqList[standPos])
                self.m_rivalWujiangLoadSeqList[standPos] = 0
            end

            local actorShow = self.m_rivalWujiangShowList[standPos]
            local weaponLevel = wujiangBriefData.weaponLevel
            if not actorShow or actorShow:GetWuJiangID() ~= wujiangBriefData.id or 
            PreloadHelper.WuqiLevelToResLevel(actorShow:GetWuQiLevel()) ~= PreloadHelper.WuqiLevelToResLevel(weaponLevel) then
                self:LoadRivalWuJiangModel(standPos, wujiangBriefData.id, weaponLevel)
            end
        else
            if self.m_rivalWujiangShowList[standPos] then
                self.m_rivalWujiangShowList[standPos]:Delete()
                self.m_rivalWujiangShowList[standPos] = nil
            end
        end
    end
end

function UIGroupHerosLineUpView:LoadRivalWuJiangModel(standPos, wujiangID, weaponLevel)
    local loadingSeq = ActorShowLoader:GetInstance():PrepareOneSeq()
    self.m_rivalWujiangLoadSeqList[standPos] = loadingSeq

    ActorShowLoader:GetInstance():CreateShowOffWuJiang(loadingSeq, ActorShowLoader.MakeParam(wujiangID, weaponLevel), self.m_roleContainerTrans, function(actorShow)
        self.m_rivalWujiangLoadSeqList[standPos] = 0
        
        -- 把当前位置上的武将回收了
        if self.m_rivalWujiangShowList[standPos] then
            self.m_rivalWujiangShowList[standPos]:Delete()
            self.m_rivalWujiangShowList[standPos] = nil
        end
        self.m_rivalWujiangShowList[standPos] = actorShow
    
        if actorShow:GetPetID() > 0 then
            actorShow:SetPosition(self:GetRivalStandPos(standPos) - PetPosOffset)
        else
            actorShow:SetPosition(self:GetRivalStandPos(standPos))
        end
        actorShow:SetEulerAngles(self:GetRivalWujiangEuler(standPos))
        actorShow:SetLocalScale(Vector3.one)
        actorShow:PlayAnim(BattleEnum.ANIM_IDLE)
    end)
end

function UIGroupHerosLineUpView:UpdateWujiang()

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

function UIGroupHerosLineUpView:LoadWuJiangModel(standPos, wujiangID, weaponLevel)
    local loadingSeq = ActorShowLoader:GetInstance():PrepareOneSeq()
    self.m_wujiangLoadingSeqList[standPos] = loadingSeq

    ActorShowLoader:GetInstance():CreateShowOffWuJiang(loadingSeq, ActorShowLoader.MakeParam(wujiangID, weaponLevel), self.m_roleContainerTrans, function(actorShow)
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
        actorShow:SetLocalScale(Vector3.one)
        actorShow:PlayAnim(BattleEnum.ANIM_IDLE)
        if self.m_selectWujiangPos and self.m_selectWujiangPos == standPos then
            actorShow:PlayAnim(BattleEnum.ANIM_SHOWOFF)

            self.m_selectWujiangPos = nil
        end
    end)
end

function UIGroupHerosLineUpView:UpdateLineupIcons()
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
                        self.m_wujiangIconList[standPos]:SetData(wujiangBriefData,true)
                        local isLineupIllegal = true
                        if isEmploy then 
                            isLineupIllegal = self.m_lineupMgr:IsEmployIllegal(Utils.GetBuZhenIDByBattleType(self.m_battleType))
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
                self.m_wujiangIconList[standPos]:SetData(wujiangBriefData, true)
                local isLineupIllegal = true
                if isEmploy then 
                    isLineupIllegal = self.m_lineupMgr:IsEmployIllegal(Utils.GetBuZhenIDByBattleType(self.m_battleType))
                end
                self.m_wujiangIconList[standPos]:SetIconColor(isLineupIllegal and Color.white or Color.red) 
            end
        end)
    end
end 

function UIGroupHerosLineUpView:HideAllIcon()
    for _, wujiangItem in pairs(self.m_wujiangIconList) do
        wujiangItem:HideAll()
    end
end

-- function UIGroupHerosLineUpView:GetRivalStandPos(standPos)
--     if not self.m_rivalStandPosList then
--         self.m_rivalStandPosList = {
--             Vector3.New(-2.42, 0, 5.64), 
--             Vector3.New(-4, 0, 6.41), 
--             Vector3.New(-1.06, 0, 6.41),  
--             Vector3.New(-3.29, 0, 7.68),
--             Vector3.New(-1.86, 0, 7.68)
--         }
--     end
--     return self.m_rivalStandPosList[standPos]
-- end

-- function UIGroupHerosLineUpView:GetStandPos(standPos)
--     if not self.m_standPosList then
--         self.m_standPosList = {
--             Vector3.New(2.24, 0, 5.64), 
--             Vector3.New(1.13, 0, 6.41), 
--             Vector3.New(3.58, 0, 6.41),  
--             Vector3.New(1.78, 0, 7.68),
--             Vector3.New(3.22, 0, 7.68)
--         }
--     end
--     return self.m_standPosList[standPos]
-- end

function UIGroupHerosLineUpView:GetRivalStandPos(standPos)
    if not self.m_rivalStandPosList then
        self.m_rivalStandPosList = {
            Vector3.New(-0.81, 0, 6.4), 
            Vector3.New(-1.72, 0, 5.2), 
            Vector3.New(-1.8, 0, 7.75),  
            Vector3.New(-3.17, 0, 7.18),
            Vector3.New(-3.17, 0, 5.8)
        }
    end
    return self.m_rivalStandPosList[standPos]
end

function UIGroupHerosLineUpView:GetStandPos(standPos)
    if not self.m_standPosList then
        self.m_standPosList = {
            Vector3.New(0.81, 0, 6.4), 
            Vector3.New(1.92, 0, 7.87), 
            Vector3.New(1.64, 0, 5.2),  
            Vector3.New(3.37, 0, 7.18),
            Vector3.New(3.37, 0, 5.8)
        }
    end
    return self.m_standPosList[standPos]
end

function UIGroupHerosLineUpView:GetRivalWujiangEuler(standPos)
    if not self.m_rivalWujiangEulerList then
        self.m_rivalWujiangEulerList = {
            Vector3.New(0, 130, 0), 
            Vector3.New(0, 130, 0),  
            Vector3.New(0, 130, 0),  
            Vector3.New(0, 130, 0),  
            Vector3.New(0, 130, 0)
        }
    end
    return self.m_rivalWujiangEulerList[standPos]
end

function UIGroupHerosLineUpView:GetWujiangEuler(standPos)
    if not self.m_wujiangEulerList then
        self.m_wujiangEulerList = {
            Vector3.New(0, 230, 0), 
            Vector3.New(0, 230, 0),  
            Vector3.New(0, 230, 0),  
            Vector3.New(0, 230, 0),  
            Vector3.New(0, 230, 0)
        }
    end
    return self.m_wujiangEulerList[standPos]
end

function UIGroupHerosLineUpView:HandleDrag(dragGO)
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

function UIGroupHerosLineUpView:OnDragBegin(go, x, y, eventData)
    local dragTrans = go.transform
    self.m_transformIndex = dragTrans:GetSiblingIndex()
    if self.m_wujiangIconList[self.m_transformIndex + 1]:IsHide() then
        return
    end
    self.m_roleGrid.enabled = false

    local _, worldPos = ScreenPointToWorldPointInRectangle(self.m_roleRT, eventData.position, eventData.pressEventCamera)
    self.m_dragOffset = dragTrans.position - worldPos
    self.m_perviousParent = dragTrans.parent
    dragTrans:SetParent(self.m_roleParent)
    self.m_wujiangIconList[self.m_transformIndex + 1]:EnableRaycast(false)
    self:EnableItemRaycast(false)
end

function UIGroupHerosLineUpView:OnDragEnd(go, x, y, eventData)
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
        local length = 0
        for k, v in pairs(self.m_wujiangIconList) do
            if not v:IsHide() then
                length = length + 1
            end
        end
        if length > 1 then
            self:ModifyLineupSeq(self.m_transformIndex + 1, 0)
            self:UpdateLineup()
        else
            UILogicUtil.FloatAlert(Language.GetString(4001))
        end
    elseif string.contains(dropGO.name, "itemBg_") then
        -- 交换武将阵容数据
        local dropGOIndex = dropGO.transform:GetSiblingIndex()
        self:SwapLineupSeq(self.m_transformIndex + 1, dropGOIndex + 1)
        -- 重新刷新icon,武将因为要做动画，单独刷新
        self:UpdateLineupIcons()
        self:SwapWujiang(self.m_transformIndex + 1, dropGOIndex + 1)
    else
        -- 拖到外面了，这个武将从阵容中去掉
        local length = 0
        for k, v in pairs(self.m_wujiangIconList) do
            if not v:IsHide() then
                length = length + 1
            end
        end
        if length > 1 then
            self:ModifyLineupSeq(self.m_transformIndex + 1, 0)
            self:UpdateLineup()
        else
            UILogicUtil.FloatAlert(Language.GetString(4001))
        end
    end

    self.m_roleGrid.enabled = true
end

function UIGroupHerosLineUpView:SwapWujiang(index1, index2)
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

function UIGroupHerosLineUpView:OnDrag(go, x, y, eventData)
    if self.m_wujiangIconList[self.m_transformIndex + 1]:IsHide() then
        return
    end

    local _, nowPos = ScreenPointToWorldPointInRectangle(self.m_roleRT, eventData.position, eventData.pressEventCamera)
    go.transform.position = nowPos + self.m_dragOffset
end

function UIGroupHerosLineUpView:EnableItemRaycast(enabled)
    for _, item in pairs(self.m_wujiangIconList) do
        if item then
            item:EnableRaycast(enabled)
        end
    end
end

function UIGroupHerosLineUpView:OnClickWuJiangCardItem(standPos)
    self:OpenWujiangSeleteUI(standPos)
end

function UIGroupHerosLineUpView:OnSelectWuJiangCardItem(selectWujiangSeq, data1, standPos)

    self:ModifyLineupSeq(standPos, selectWujiangSeq)
    self.m_selectWujiangPos = standPos

    self:UpdateLineup()
    self:TweenItemPos(standPos)
end

function UIGroupHerosLineUpView:TweenItemPos(standPos)
    self.m_roleGrid.enabled = false
    UIUtil.KillTween(self.m_tweenner)
    local trans = self.m_wujiangIconList[standPos].transform
    local localPos = trans.localPosition
    trans.localPosition = Vector3.New(localPos.x, localPos.y + 30, 0)
    self.m_tweenner = DOTweenShortcut.DOLocalMoveY(trans, localPos.y, 0.5)
    DOTweenSettings.SetEase(self.m_tweenner, DoTweenEaseType.OutBounce)
    DOTweenSettings.OnComplete(self.m_tweenner, function()
        self.m_roleGrid.enabled = true
    end)
end

function UIGroupHerosLineUpView:OpenWujiangSeleteUI(standPos)
    UIManagerInst:OpenWindow(UIWindowNames.UIGroupHerosLineupSelect, self.m_battleType, standPos)
end

function UIGroupHerosLineUpView:RecyleModelAndIcon()
    loaderInstance:CancelLoad(self.m_iconSeq)
    self.m_iconSeq = 0
    loaderInstance:CancelLoad(self.m_userSeq)
    self.m_userSeq = 0
    loaderInstance:CancelLoad(self.m_rivalSeq)
    self.m_rivalSeq = 0

    for _,seq in pairs(self.m_wujiangLoadingSeqList) do
        if seq > 0 then
            ActorShowLoader:GetInstance():CancelLoad(seq)
        end
    end
    self.m_wujiangLoadingSeqList = {}

    for _,seq in pairs(self.m_rivalWujiangLoadSeqList) do
        if seq > 0 then
            ActorShowLoader:GetInstance():CancelLoad(seq)
        end
    end
    self.m_rivalWujiangLoadSeqList = {}

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
    for _,wujiangShow in pairs(self.m_rivalWujiangShowList) do
        if wujiangShow then
            wujiangShow:Delete()
        end
    end
    if self.m_userIconItem then
        self.m_userIconItem:Delete()
        self.m_userIconItem = nil
    end
    if self.m_rivalIconItem then
        self.m_rivalIconItem:Delete()
        self.m_rivalIconItem = nil
    end

    self.m_petSeq = 0
    self.m_wujiangShowList = {}
    self.m_rivalWujiangShowList = {}
    self.m_rivalWujiangList = {}
end

function UIGroupHerosLineUpView:GetIconParent()
    return self.m_lineupRolesParent
end

function UIGroupHerosLineUpView:GetRecoverParam()
    return self.m_battleType, self.m_copyID
end

function UIGroupHerosLineUpView:CreateRoleContainer()
    if IsNull(self.m_roleContainerGo) then
        self.m_roleContainerGo = GameObject("RoleContainer")
        self.m_roleContainerTrans = self.m_roleContainerGo.transform

        self.m_sceneSeq = loaderInstance:PrepareOneSeq()
        loaderInstance:GetGameObject(self.m_sceneSeq, WujiangRootPath, function(go)
            self.m_sceneSeq = 0
            if not IsNull(go) then
                self.m_roleBgGo = go
                self.m_roleContainerTrans:SetParent(self.m_roleBgGo.transform)
                self.m_roleContainerTrans.position = Vector3.New(0, -8.3, 86)
                self.m_roleContainerTrans.eulerAngles = Vector3.New(0, 0, 0)
                self.m_roleCameraTrans = self.m_roleBgGo.transform:Find("RoleCamera")
                self.m_roleCameraTrans.localPosition = Vector3.New(0, -5.24, 86.5)
                self.m_roleCameraTrans.eulerAngles = Vector3.New(20, 0, 0)
            end
            self:TweenOpen()
        end)
    end
end

function UIGroupHerosLineUpView:DestroyRoleContainer()
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

function UIGroupHerosLineUpView:WalkLineup(filter)
    self.m_lineupMgr:WalkMain(Utils.GetBuZhenIDByBattleType(self.m_battleType), filter)
end

function UIGroupHerosLineUpView:ModifyLineupSeq(standPos, newSeq)
    self.m_lineupMgr:ModifyLineupSeq(Utils.GetBuZhenIDByBattleType(self.m_battleType), false, standPos, newSeq)
end

function UIGroupHerosLineUpView:SwapLineupSeq(standPos1, standPos2)
    self.m_lineupMgr:SwapLineupSeq(Utils.GetBuZhenIDByBattleType(self.m_battleType), false, standPos1, standPos2)
end

function UIGroupHerosLineUpView:Update()
    if self.m_prepareDeadline > 0 then
        local deltaTime = Time.deltaTime
        self.m_prepareDeadline = self.m_prepareDeadline - deltaTime
        self.m_beginLeftTimeText.text = math_ceil(self.m_prepareDeadline)
    end
end

function UIGroupHerosLineUpView:IsCheckLineupIllegal()
    return true
end

function UIGroupHerosLineUpView:TweenOpen()
    DOTween.ToFloatValue(function()
        return 0
    end, 
    function(value)
        self.m_topContainer.anchoredPosition = Vector3.New(0, 130 - 130 * value, 0)
        local pos = Vector3.New(0, -5.24, 86 + 0.5 * value)
        self.m_roleCameraTrans.localPosition = pos
    end, 1, 0.3)

    local tweener = DOTween.ToFloatValue(function()
        return 0
    end, 
    function(value)
        self.m_bottomContainer.anchoredPosition = Vector3.New(0, -123 + 260 * value, 0)
    end, 1, 0.4)
    DOTweenSettings.SetEase(tweener, DoTweenEaseType.InOutBack)

end

function UIGroupHerosLineUpView:InitDragonIcon()
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

function UIGroupHerosLineUpView:OpenDragonPanel()
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

function UIGroupHerosLineUpView:UpdateDragonPanel()
    local curDragonID = self.m_lineupMgr:GetLineupDragon(Utils.GetBuZhenIDByBattleType(self.m_battleType))
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

function UIGroupHerosLineUpView:OnClickDragonIcon(dragonID)
    self.m_lineupMgr:SetLineupDragon(Utils.GetBuZhenIDByBattleType(self.m_battleType), dragonID)
    GroupHerosMgr:ReqArrangeBuzhen(Utils.GetBuZhenIDByBattleType(self.m_battleType))
    self:UpdateDragonPanel()
    self:UpdateDragonBtn()
end

function UIGroupHerosLineUpView:UpdateDragonSkillDec() 
    local dragonID = self.m_lineupMgr:GetLineupDragon(Utils.GetBuZhenIDByBattleType(self.m_battleType))
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


return UIGroupHerosLineUpView