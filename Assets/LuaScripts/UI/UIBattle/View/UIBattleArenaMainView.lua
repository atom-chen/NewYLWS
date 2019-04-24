--[[
-- added by wsh @ 2018-02-26
-- UIBattleArenaMain视图层
--]]

local UIUtil = UIUtil
local UIBattleArenaMainView = BaseClass("UIBattleArenaMainView", UIBaseView)
local base = UIBaseView
local Vector3 = Vector3
local ActorUtil = ActorUtil
local table_sort = table.sort
local table_insert = table.insert
local string_format = string.format
local math_floor= math.floor
local Language = Language
local DOTweenSettings = CS.DOTween.DOTweenSettings
local GameObject = CS.UnityEngine.GameObject
local DOTween = CS.DOTween.DOTween
local TypeText = typeof(CS.TMPro.TextMeshProUGUI)
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum
local UILogicUtil = UILogicUtil
local Color = Color
local ConfigUtil = ConfigUtil
local ImageConfig = ImageConfig
local UserItemClass = require("UI.UIUser.UserItem")
local UserItemPrefab = TheGameIds.UserItemPrefab
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()


local WujiangItemPrefabPath = "UI/Prefabs/Battle/BattleWujiangItem.prefab"
local BattleWujiangItem = require("UI.UIBattle.View.BattleWujiangItem")

local ChatMgr = Player:GetInstance():GetChatMgr()

function UIBattleArenaMainView:__init()
	self.m_leftWujiangItemArray = nil
	self.m_rightWujiangItemArray = nil

	self.m_leftWujiangContainerTrans = nil
	self.m_rightWujiangContainerTrans = nil

	self.m_topRightTrans = nil
	self.m_bottomRightWujiangContainerTrans = nil
	self.m_bottomLeftContainerTrans = nil
	self.m_topMiddleTrans = nil
	self.m_bottomWujiangContainerTrans = nil
	self.m_playerContainer = nil
	self.m_vsTrans = nil
	self.m_talentItemList = {}


    self.m_hideChatTime = 0
	self.m_speed = 1
	self.m_huoEffect = nil
	self.m_leftPlayerItem = nil
	self.m_rightPlayerItem = nil
end

function UIBattleArenaMainView:OnCreate()
	base.OnCreate(self)
	self.m_leftWujiangItemArray = {}
	self.m_rightWujiangItemArray = {}
	
	self.m_leftDragonNameText, self.m_rightDragonNameText, self.m_leftPlayerName, self.m_rightPlayerName,
	self.m_leftDragonLevelText, self.m_rightDragonLevelText = UIUtil.GetChildTexts(self.transform, {
		"leftDragonRoot/NameBg/leftDragonNameText",
		"rightDragonRoot/NameBg/rightDragonNameText",
		"PlayerContainer/leftPlayer/playerName",
		"PlayerContainer/rightPlayer/playerName",
		"leftDragonRoot/NameBg/leftDragonLevelText",
		"rightDragonRoot/NameBg/rightDragonLevelText",
	})
	self.m_timeText = UIUtil.FindComponent(self.transform, TypeText, "DynamicCanvas/TopMiddleContainer/waveBg/Time/timeText")
	self.m_chatText = UIUtil.FindComponent(self.transform, TypeText, "BottomLeftContainer/ChatText/ContentText")

	self.m_topRightTrans, self.m_bottomRightWujiangContainerTrans, self.m_topMiddleTrans, 
	self.m_bottomWujiangContainerTrans, self.m_vsTrans, self.m_leftWujiangContainerTrans, 
	self.m_rightWujiangContainerTrans, self.m_leftDragonRoot, self.m_rightDragonRoot, self.m_bottomLeftContainerTrans,
	self.back_btn, self.m_switchCameraBtn, self.m_friendBtn, self.m_chatBtn, self.m_chatBg, self.m_speedBtn, self.m_chatTxtRoot,
	self.m_playerContainer, self.m_talentItemTr, self.m_leftTalentRootTr, self.m_rightTalentRootTr
	 = UIUtil.GetChildRectTrans(self.transform, {
        "TopRightContainer",
		"BottomRightContainer",
		"DynamicCanvas/TopMiddleContainer",
		"BottomWujiangContainer",
		"WujiangMiddleContainer/Center",
		"BottomWujiangContainer/LeftPlayerWujiangContainer/leftWujiangContainer",
		"BottomWujiangContainer/RightPlayerWujiangContainer/rightWujiangContainer",
		"leftDragonRoot",
		"rightDragonRoot",
		"BottomLeftContainer",
		"TopRightContainer/BackBtn",
		"BottomRightContainer/SwitchCamera",
		"BottomLeftContainer/friendBtn",
		"BottomLeftContainer/chatBtn",
		"BottomLeftContainer/ChatText/chatbg",
		"BottomRightContainer/speedBtn",
		"BottomLeftContainer/ChatText",
		"PlayerContainer",
		"talentItemPrefab",
		"leftDragonRoot/leftTalentRoot",
		"rightDragonRoot/rightTalentRoot",
	})

	self.m_talentItemPrefab = self.m_talentItemTr.gameObject
	
	local tmpPos = self.m_leftWujiangContainerTrans.anchoredPosition
	self.m_leftWujiangContainerTrans.anchoredPosition = Vector2.New(tmpPos.x + CommonDefine.IPHONE_X_OFFSET_LEFT, tmpPos.y) -- todo IPHONE_X_OFFSET_LEFT
	local tmpPos = self.m_rightWujiangContainerTrans.anchoredPosition
	self.m_rightWujiangContainerTrans.anchoredPosition = Vector2.New(tmpPos.x + CommonDefine.IPHONE_X_OFFSET_LEFT, tmpPos.y)

	self.m_speedImage = self:AddComponent(UIImage, "BottomRightContainer/speedBtn/SpeedTextImage", AtlasConfig.BattleDynamicLoad)
	self.m_leftDragonImg = self:AddComponent(UIImage, "leftDragonRoot/leftDragonImg", ImageConfig.BattleArena)
	self.m_rightDragonImg = self:AddComponent(UIImage, "rightDragonRoot/rightDragonImg", ImageConfig.BattleArena)

	self.m_autoBattleImage = self:AddComponent(UIImage, "BottomRightContainer/AutoBattle/AutoBattleImage", AtlasConfig.BattleDynamicLoad)
	self.m_autoBattleImageParent = self:AddComponent(UIImage, "BottomRightContainer/AutoBattle")

	self.m_leftItemCreatePos, self.m_rightItemCreatePos = UIUtil.GetChildTransforms(self.transform, {
		'PlayerContainer/leftPlayer',
		'PlayerContainer/rightPlayer',
	 })

	self:CheckActorCreated()

	self:UpdateAutoFight()
	self:InitSpeedUpSetting()

	self:HandleClick()
end

function UIBattleArenaMainView:OnEnable(...)
	base.OnEnable(self, ...)

	self:UpdateUserInfo()

	self:UpdateDragonInfo()
end

function UIBattleArenaMainView:UpdateUserInfo()
	local battleParam = CtlBattleInst:GetLogic():GetBattleParam()
	if battleParam then
		local leftCampInfo = battleParam.leftCamp
		self.m_leftPlayerName.text = leftCampInfo.name
		local seq = UIGameObjectLoaderInst:PrepareOneSeq()
		UIGameObjectLoaderInst:GetGameObject(seq, UserItemPrefab, function(obj)
			seq = 0
			if IsNull(obj) then
				return
			end
			local userItem = UserItemClass.New(obj, self.m_leftItemCreatePos, UserItemPrefab)
			userItem:SetLocalScale(Vector3.New(0.77, 0.77, 0.77))
			userItem:UpdateData(leftCampInfo.user_icon.icon, leftCampInfo.user_icon.box, leftCampInfo.level)
			self.m_leftPlayerItem = userItem
		end)

		local rightPlayerInfo = battleParam.rightCampList[1]
		self.m_rightPlayerName.text = rightPlayerInfo.name
		local seq1 = UIGameObjectLoaderInst:PrepareOneSeq()
		UIGameObjectLoaderInst:GetGameObject(seq, UserItemPrefab, function(obj)
			seq1 = 0
			if IsNull(obj) then
				return
			end
			local userItem = UserItemClass.New(obj, self.m_rightItemCreatePos, UserItemPrefab)
			userItem:SetLocalScale(Vector3.New(0.77, 0.77, 0.77))
			local playerInfo = battleParam.rightCampList[1]
			userItem:UpdateData(rightPlayerInfo.user_icon.icon, rightPlayerInfo.user_icon.icon_box, rightPlayerInfo.level)
			self.m_rightPlayerItem = userItem
		end)

	end
	
	self.m_bottomWujiangContainerTrans.gameObject:SetActive(false) 
	self.m_playerContainer.gameObject:SetActive(false) 
end

function UIBattleArenaMainView:HandleClick()
	local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.back_btn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_switchCameraBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_friendBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_chatBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_chatBg.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_speedBtn.gameObject, onClick)
end

function UIBattleArenaMainView:RemoveClick()
    UIUtil.RemoveClickEvent(self.back_btn.gameObject)
    UIUtil.RemoveClickEvent(self.m_switchCameraBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_friendBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_chatBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_chatBg.gameObject)
    UIUtil.RemoveClickEvent(self.m_speedBtn.gameObject)
end

function UIBattleArenaMainView:OnClick(go, x, y)
	local btnName = go.name

	if btnName == 'BackBtn' then
		self:Back()
	elseif btnName == 'SwitchCamera' then
		if CtlBattleInst:IsInFight() then
			CtlBattleInst:GetLogic():SwitchCamera()
		end
	elseif btnName == 'friendBtn' then
		UILogicUtil.SysShowUI(SysIDs.FRIEND)
	elseif btnName == 'chatBtn' or btnName == 'chatbg' then
		UILogicUtil.SysShowUI(SysIDs.CHAT)
	elseif btnName == 'speedBtn' then
		self.m_speed = self.m_speed + 0.5
		self.m_speed = self.m_speed > 2 and 1 or self.m_speed
		TimeScaleMgr:SetTimeScaleMultiple(self.m_speed)
		CtlBattleInst:GetLogic():WriteSpeedUpSetting(self.m_speed)

		if self.m_speed == 1 then
			self.m_speedImage:SetAtlasSprite("zhandou92.png", true)
		elseif self.m_speed == 1.5 then
			self.m_speedImage:SetAtlasSprite("zhandou93.png", true)
		elseif self.m_speed == 2 then
			self.m_speedImage:SetAtlasSprite("zhandou94.png", true)
		end	
	end
end

function UIBattleArenaMainView:UpdateDragonInfo()
	local logic = CtlBattleInst:GetLogic()
	if logic then
		local battleParam = logic:GetBattleParam()
		    
		local leftDragonData = battleParam.leftCamp.oneDragon
		if leftDragonData then
			local dragonCfg = ConfigUtil.GetGodBeastCfgByID(leftDragonData.dragonID)
			if dragonCfg then
				self.m_leftDragonNameText.text = dragonCfg.sName
				self.m_leftDragonLevelText.text = string_format(Language.GetString(1126), leftDragonData.dragonLevel)
				self.m_leftDragonImg:SetAtlasSprite(dragonCfg.role_id .. ".png")
			end
			self:CreateTalent(leftDragonData.talentList, self.m_leftTalentRootTr)
		end
	
		local rightCampList = battleParam.rightCampList
		for _, rightCamp in ipairs(rightCampList) do
			local rightDragonData = rightCamp.oneDragon
			if rightDragonData then
				local dragonCfg = ConfigUtil.GetGodBeastCfgByID(rightDragonData.dragonID)
				if dragonCfg then
					self.m_rightDragonNameText.text = dragonCfg.sName
					self.m_rightDragonLevelText.text = string_format(Language.GetString(1126), rightDragonData.dragonLevel)
					self.m_rightDragonImg:SetAtlasSprite(dragonCfg.role_id .. ".png")
				end
				self:CreateTalent(rightDragonData.talentList, self.m_rightTalentRootTr)
			end
		end
	end
end

function UIBattleArenaMainView:CreateTalent(talentList, root)
	for i = 1, #talentList do
		local talentItem = self.m_talentItemList[i]
		local trans = nil
		if not talentItem then
			local go = GameObject.Instantiate(self.m_talentItemPrefab)
			if not IsNull(go) then
				trans = go.transform
				trans:SetParent(root)
                trans.localScale = Vector3.one
                trans.localPosition = Vector3.zero
			end
		end
		local levelText = UIUtil.GetChildTexts(trans, {"LevelBg/Text"})
		local iconImg = UIUtil.AddComponent(UIImage, trans, "talentIcon")
		local talentCfg = ConfigUtil.GetGodBeastTalentCfgByID(talentList[i].talentID)
		if not IsNull(levelText) and not IsNull(iconImg) and talentCfg then
			levelText.text = math_floor(talentList[i].talentLevel) 
			iconImg:SetAtlasSprite(talentCfg.sIcon, false, ImageConfig.GodBeast)
		end
	end
end

function UIBattleArenaMainView:Update()
	self:UpdateTimeText()
	self:CheckHideChat()
	-- self:EditorTest()
end

function UIBattleArenaMainView:EditorTest()
    if CS.UnityEngine.Input.GetKeyDown(CS.UnityEngine.KeyCode.F1) then
        CtlBattleInst:FramePause()
    end
    if CS.UnityEngine.Input.GetKeyDown(CS.UnityEngine.KeyCode.F2) then
        CtlBattleInst:FrameResume()
	end
end

function UIBattleArenaMainView:OnDestroy()
	self:RemoveClick()
	for _, v in ipairs(self.m_talentItemList) do
		v:Delete()
	end
	self.m_talentItemList = {}

	if self.m_leftWujiangItemArray then
		for _,item in pairs(self.m_leftWujiangItemArray) do
			item:Delete()
		end

		self.m_leftWujiangItemArray = nil
	end

	if self.m_rightWujiangItemArray then
		for _,item in pairs(self.m_rightWujiangItemArray) do
			item:Delete()
		end

		self.m_rightWujiangItemArray = nil
	end

	self.m_leftWujiangContainerTrans = nil
	self.m_rightWujiangContainerTrans = nil

	self.m_topRightTrans = nil
	self.m_bottomRightWujiangContainerTrans = nil
	self.m_bottomLeftContainerTrans = nil
	self.m_topMiddleTrans = nil
	self.m_bottomWujiangContainerTrans = nil
	self.m_playerContainer = nil
	self.m_vsTrans = nil

	self.back_btn = false
	self.m_summonBtn = false
	self.skillBtn = false
	self.joyBtn = false
	self.m_speed = 1
	self.m_huoEffect = nil

	if self.m_leftPlayerItem then
		self.m_leftPlayerItem:Delete()
		self.m_leftPlayerItem = nil
	end

	if self.m_rightPlayerItem then
		self.m_rightPlayerItem:Delete()
		self.m_rightPlayerItem = nil
	end
	
	base.OnDestroy(self)
end


function UIBattleArenaMainView:OnAddListener()
	base.OnAddListener(self)
	-- UI消息注册
	self:AddUIListener(UIMessageNames.UIBATTLE_STOP, self.OnBattleStop)
	self:AddUIListener(UIMessageNames.UIBATTLE_SET_BATTLEARENAUI_ACTIVE, self.SetBattleArenaUIActive)
	self:AddUIListener(UIMessageNames.UIBATTLE_SET_BATTLEARENAMIDDLEUI_ACTIVE, self.SetBattleArenaMiddleUIActive)
	self:AddUIListener(UIMessageNames.UIBATTLE_ACTOR_CREATE, self.OnActorCreate)
    self:AddUIListener(UIMessageNames.UIBATTLE_ACTOR_DIE, self.OnActorDie)
	self:AddUIListener(UIMessageNames.UIBATTLE_HP_CHANGE, self.OnHPChange)
	self:AddUIListener(UIMessageNames.UIBATTLEFLOAT_SHOW_NUQI, self.OnNuqiChange)
	self:AddUIListener(UIMessageNames.UIBATTLE_DRAGON_SKILL_PERFORM, self.OnDragonSkillPerform)
    self:AddUIListener(UIMessageNames.MN_CHAT_MAIN_CHAT_LIST, self.UpdateChatMsgList)
	-- self:AddUIListener(UIMessageNames.UIBATTLE_WAVE_END, self.OnWaveEnd)
end

function UIBattleArenaMainView:OnRemoveListener()
	base.OnRemoveListener(self)
	-- UI消息注销
	self:RemoveUIListener(UIMessageNames.UIBATTLE_STOP, self.OnBattleStop)
	self:RemoveUIListener(UIMessageNames.UIBATTLE_SET_BATTLEARENAUI_ACTIVE, self.SetBattleArenaUIActive)
	self:RemoveUIListener(UIMessageNames.UIBATTLE_SET_BATTLEARENAMIDDLEUI_ACTIVE, self.SetBattleArenaMiddleUIActive)
	self:RemoveUIListener(UIMessageNames.UIBATTLE_ACTOR_CREATE, self.OnActorCreate)
    self:RemoveUIListener(UIMessageNames.UIBATTLE_ACTOR_DIE, self.OnActorDie)
	self:RemoveUIListener(UIMessageNames.UIBATTLE_HP_CHANGE, self.OnHPChange)
	self:RemoveUIListener(UIMessageNames.UIBATTLEFLOAT_SHOW_NUQI, self.OnNuqiChange)
	self:RemoveUIListener(UIMessageNames.UIBATTLE_DRAGON_SKILL_PERFORM, self.OnDragonSkillPerform)
    self:RemoveUIListener(UIMessageNames.MN_CHAT_MAIN_CHAT_LIST, self.UpdateChatMsgList)
	-- self:RemoveUIListener(UIMessageNames.UIBATTLE_WAVE_END, self.OnWaveEnd)
end

function UIBattleArenaMainView:OnBattleStop(wave)

end

function UIBattleArenaMainView:OnDragonSkillPerform(camp)
	if camp == BattleEnum.ActorCamp_LEFT then
		self.m_leftDragonRoot.gameObject:SetActive(true)
	else
		self.m_rightDragonRoot.gameObject:SetActive(true)
	end

	local tweener = DOTween.ToFloatValue(function()
        return 0
    end, 
	function(value)
		if camp == BattleEnum.ActorCamp_LEFT then
			self.m_leftDragonRoot.anchoredPosition = Vector3.New(-750 + 750 * value, -250, 0)
		else
			self.m_rightDragonRoot.anchoredPosition = Vector3.New(750 - 750 * value, -250, 0)
		end
	end, 1, 0.3)
	DOTweenSettings.OnComplete(tweener, function()
        local tweener1 = DOTween.ToFloatValue(function()
			return 0
		end, 
		function(value)
			if camp == BattleEnum.ActorCamp_LEFT then
				self.m_leftDragonRoot.anchoredPosition = Vector3.New(-750 * value, -250, 0)
			else
				self.m_rightDragonRoot.anchoredPosition = Vector3.New(750 * value, -250, 0)
			end
		end, 1, 0.15)
		DOTweenSettings.SetDelay(tweener1, 0.5)
    end)
end

function UIBattleArenaMainView:SetBattleArenaUIActive(active)
	
	self:ClearHuoEffect()

	if active then
		self.m_bottomLeftContainerTrans.anchoredPosition = Vector3.New(0, 190, 0)
		self.m_bottomRightWujiangContainerTrans.anchoredPosition = Vector3.New(0, 190, 0)
		self.m_topRightTrans.anchoredPosition = Vector3.zero
		self.m_topMiddleTrans.anchoredPosition = Vector3.zero

		self.m_bottomWujiangContainerTrans.gameObject:SetActive(true) 
		self.m_playerContainer.gameObject:SetActive(true) 
	else

		self.m_bottomLeftContainerTrans.anchoredPosition = Vector3.New(0, -1000, 0)
		self.m_bottomRightWujiangContainerTrans.anchoredPosition = Vector3.New(0, -1000, 0)
		self.m_topRightTrans.anchoredPosition = Vector3.New(0, 1000, 0)
		self.m_topMiddleTrans.anchoredPosition = Vector3.New(0, 1000, 0)

	end
end

function UIBattleArenaMainView:SetBattleArenaMiddleUIActive(active)

	if active then
		self.m_vsTrans.anchoredPosition = Vector3.zero

		if not self.m_huoEffect then
			local window = UIManagerInst:GetWindow(UIWindowNames.UIBattleArenaMain)
			local sortOrder = window.View.base_order + 5
			self.m_huoEffect = self:AddComponent(UIEffect, "", sortOrder, "UI/Effect/Prefabs/huoxing01")
		end
	else
		self.m_vsTrans.anchoredPosition = Vector3.New(0, -2000, 0)
	end

end

function UIBattleArenaMainView:ClearHuoEffect()
    if self.m_huoEffect then
        self:RemoveComponent(self.m_huoEffect:GetName(), UIEffect)
        self.m_huoEffect = nil
    end 
end

function UIBattleArenaMainView:CheckActorCreated()
	ActorManagerInst:Walk(
		function(tmpTarget)
			local actorID = tmpTarget:GetActorID()			
			self:OnActorCreate(actorID)
        end
    )
end

function UIBattleArenaMainView:OnActorCreate(actorID)
	local wujiangItem1 = self:GetWujiangItem(actorID)
	if wujiangItem1 then
		return
	end

    local actor = ActorManagerInst:GetActor(actorID)
    if not actor then
       return 
	end

	if actor:IsCalled() or ActorUtil.IsAnimal(actor) then
		return
	end

	if actor:GetCamp() == BattleEnum.ActorCamp_LEFT then
		self:AddWujiangItemPrefabPath(self.m_leftWujiangContainerTrans, self.m_leftWujiangItemArray, actorID, true)
	else
		self:AddWujiangItemPrefabPath(self.m_rightWujiangContainerTrans, self.m_rightWujiangItemArray, actorID, false)
	end
end

function UIBattleArenaMainView:AddWujiangItemPrefabPath(wujiangContainerTrans, wujiangItemArray, actorID, isLeft)
	GameObjectPoolInst:GetGameObjectAsync(WujiangItemPrefabPath, function(inst)
		local wujiangItem = BattleWujiangItem.New(inst, wujiangContainerTrans, WujiangItemPrefabPath)
		wujiangItem:SetLocalScale(Vector3.New(0.96, 0.96, 0.96))
		wujiangItem:SetData(actorID, self.base_order)
		table_insert(wujiangItemArray, wujiangItem)

		self:SortWujiangItem(wujiangItemArray, isLeft)
	end)
end

function UIBattleArenaMainView:OnActorDie(actorID)
	local wujiangItem = self:GetWujiangItem(actorID)
	if wujiangItem then
		wujiangItem:OnActorDie()
	end
end

function UIBattleArenaMainView:OnHPChange(actorID, hpChgVal)
	local wujiangItem = self:GetWujiangItem(actorID)
	if wujiangItem then
		wujiangItem:UpdateBloodBar(hpChgVal)
	end
end

function UIBattleArenaMainView:OnNuqiChange(actor, chgVal, reason)
	if not actor then
		return
	end

	local wujiangItem = self:GetWujiangItem(actor:GetActorID())
	if wujiangItem then
		wujiangItem:UpdateNuqiBar(chgVal)
	end
end

function UIBattleArenaMainView:GetWujiangItem(actorID)
	local getItem = false
	for i,item in pairs(self.m_leftWujiangItemArray) do
		if item and item:GetActorID() == actorID then
			getItem = true
			return item,i
		end
	end

	if not getItem then
		for i,item in pairs(self.m_rightWujiangItemArray) do
			if item and item:GetActorID() == actorID then
				getItem = true
				return item,i
			end
		end
	end
end

function UIBattleArenaMainView:SortWujiangItem(wujiangItemArray, isLeft)
	table_sort(wujiangItemArray, function(itemA, itemB)
		if itemA:GetActorID() == itemB:GetActorID() then
			return false
		end

		if isLeft then
			return itemA:GetActorID() > itemB:GetActorID()
		else
			return itemA:GetActorID() < itemB:GetActorID()
		end
	end) 

	for i,item in pairs(wujiangItemArray) do
		if item then
			item:SetSiblingIndex(i)
		end
	end
end

function UIBattleArenaMainView:Back()
	local ctlInstance = CtlBattleInst
	if ctlInstance:GetLogic():IsFinished() then
		return
	end
	
	local isAlreadPause = ctlInstance:IsFramePause()
	if ctlInstance:IsInFight() and (isAlreadPause or ctlInstance:IsPause()) then
		return
	end

	BattleCameraMgr:Pause()
	ctlInstance:Pause(BattleEnum.PAUSEREASON_WANT_EXIT, 111)
	if not isAlreadPause then
		CtlBattleInst:FramePause()
	end

	local battleLogic = CtlBattleInst:GetLogic()
	if battleLogic:GetBattleType() == BattleEnum.BattleType_FRIEND_CHALLENGE then
		self:ShowBackTips()
		return
	end

	UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(9),Language.GetString(6), 
	Language.GetString(1561), function()
		if battleLogic then
			Player:GetInstance():GetMainlineMgr():GetUIData().isAutoFight = false
			local battleResultData = battleLogic:GetBattleParam().resultInfo
			if battleResultData then
				battleLogic:ReqSettle(battleResultData.result == 1, true)
			end
		end
	end, Language.GetString(7), function()
		BattleCameraMgr:Resume()
		CtlBattleInst:Resume(BattleEnum.PAUSEREASON_WANT_EXIT)
		if not isAlreadPause then
			CtlBattleInst:FrameResume()
		end
	end)
end

function UIBattleArenaMainView:ShowBackTips()
	UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(9), Language.GetString(6), 
	Language.GetString(8), function()
		local battleLogic = CtlBattleInst:GetLogic()
		if battleLogic then
			Player:GetInstance():GetMainlineMgr():GetUIData().isAutoFight = false
			battleLogic:OnCityReturn()
		end
	end, Language.GetString(7), function()
		BattleCameraMgr:Resume()
		CtlBattleInst:Resume(BattleEnum.PAUSEREASON_WANT_EXIT)
		if not isAlreadPause then
			CtlBattleInst:FrameResume()
		end
	end)
end


function UIBattleArenaMainView:UpdateTimeText()

	local logic = CtlBattleInst:GetLogic()
	if logic then
		local leftS = logic:GetLeftS()
		if leftS ~= self.lastLeftS then
			local min = math_floor(leftS / 60)
			local sec = math_floor(leftS % 60)
			self.m_timeText.text = string_format("%02d:%02d", min, sec)
			self.lastLeftS = leftS
		end
	end
end

function UIBattleArenaMainView:UpdateAutoFight(isClick)
	self.m_autoBattleImage:SetAtlasSprite("zhandou99.png", true)
	self.m_autoBattleImage:SetColor(Color.black)
	self.m_autoBattleImageParent:SetColor(Color.black)
end


function UIBattleArenaMainView:InitSpeedUpSetting()
    local logic = CtlBattleInst:GetLogic()
	if logic then
		self.m_speed = logic:ReadSpeedUpSetting()
        TimeScaleMgr:SetTimeScaleMultiple(self.m_speed)
		if self.m_speed == 1 then
			self.m_speedImage:SetAtlasSprite("zhandou92.png", true)
		elseif self.m_speed == 1.5 then
			self.m_speedImage:SetAtlasSprite("zhandou93.png", true)
		elseif self.m_speed == 2 then
			self.m_speedImage:SetAtlasSprite("zhandou94.png", true)
		end
	end
end

function UIBattleArenaMainView:UpdateChatMsgList()
    local chatDataList = ChatMgr:GetMainChatList()
	if chatDataList and #chatDataList > 0 then
		local lastOne = chatDataList[#chatDataList]

		local chatData = lastOne.chatData
		local chatType = lastOne.chatType
		
		if chatData then            
			self.m_chatTxtRoot.gameObject:SetActive(true)
			self.m_hideChatTime = Player:GetInstance():GetServerTime() + 30
        
            local speaker_brief = chatData.speaker_brief
    
            if chatType == CommonDefine.CHAT_TYPE_SYS then
                self.m_chatText.text = string_format(Language.GetString(3115), chatData.words)  
            elseif chatType == CommonDefine.CHAT_TYPE_WORLD then
                if speaker_brief then
                    self.m_chatText.text = string_format(Language.GetString(3114), speaker_brief.name, chatData.words)  
                end
            elseif chatType == CommonDefine.CHAT_TYPE_GUILD then
                if speaker_brief then
                    self.m_chatText.text = string_format(Language.GetString(3116), speaker_brief.name, chatData.words)  
                end
            else
                self.m_chatText.text = ''
            end
        end
	end
end

function UIBattleArenaMainView:CheckHideChat()	
    if self.m_hideChatTime > 0 and Player:GetInstance():GetServerTime() >= self.m_hideChatTime then
        self.m_chatTxtRoot.gameObject:SetActive(false)
        self.m_hideChatTime = 0
	end
end

return UIBattleArenaMainView