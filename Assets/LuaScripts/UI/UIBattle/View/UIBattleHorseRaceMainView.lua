local GameUtility = CS.GameUtility
local UIUtil = UIUtil
local Vector2 = Vector2
local table_insert = table.insert
local Language = Language
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTween = CS.DOTween.DOTween
local CommonDefine = CommonDefine
local UIManagerInst = UIManagerInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum
local math_ceil = math.ceil
local BattleHorseRankItemPath = "UI/Prefabs/Battle/BattleHorseRankItem.prefab"
local BattleHorseRankItem = require("UI.UIBattle.View.BattleHorseRankItem")
local UIBattleHorseRaceMainView = BaseClass("UIBattleHorseRaceMainView", UIBaseView)
local base = UIBaseView

function UIBattleHorseRaceMainView:__init()
	self.m_speed = 1
	self.m_rankItemArray = nil
end

function UIBattleHorseRaceMainView:OnCreate()
	base.OnCreate(self)

	self.back_btn, self.m_speedBtn ,self.m_rankShowRoot, self.m_rankFontPic, self.m_rankNumPic, self.m_completeBtn, self.m_rankEnd = UIUtil.GetChildRectTrans(self.transform, {
        "TopRightContainer/BackBtn",
		"BottomRightContainer/speedBtn",
		"TopLeftContainer/RankShowRoot",
		"TopMiddleContainer/rankEnd/rankFontPic",
		"TopMiddleContainer/rankEnd/rankNumPic",
		"BottoMidContainer/completeBtn",
		"TopMiddleContainer/rankEnd",
	})

	local completeBtnText = UIUtil.GetChildTexts(self.transform, {
        "BottoMidContainer/completeBtn/completeBtnText",
    })

    if CommonDefine.IS_HAIR_MODEL then
		local tmpPos = self.m_rankShowRoot.anchoredPosition
		self.m_rankShowRoot.anchoredPosition = Vector2.New(tmpPos.x - 1, tmpPos.y)
	end

	completeBtnText.text = Language.GetString(4169)
	
	self.m_speedImage = self:AddComponent(UIImage, "BottomRightContainer/speedBtn/SpeedTextImage", AtlasConfig.BattleDynamicLoad)
	self.m_rankNumImage = self:AddComponent(UIImage, "TopMiddleContainer/rankEnd/rankNumPic", AtlasConfig.BattleDynamicLoad)
	self.m_rankFontImage = self:AddComponent(UIImage, "TopMiddleContainer/rankEnd/rankFontPic", AtlasConfig.BattleDynamicLoad)

	self.m_loaderSeq = 0
	self.m_rankItemArray = {}

	self:HandleClick()
end

function UIBattleHorseRaceMainView:OnEnable(...)
    base.OnEnable(self, ...)
	local logic = CtlBattleInst:GetLogic()
	if logic then
		if logic:IsHideUIWhenUIStart() then
			self:Hide()
		end
	end
end

function UIBattleHorseRaceMainView:HandleClick()
	local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.back_btn.gameObject, onClick)
	UIUtil.AddClickEvent(self.m_speedBtn.gameObject, onClick)
	UIUtil.AddClickEvent(self.m_completeBtn.gameObject, onClick)
end

function UIBattleHorseRaceMainView:RemoveClick()
    UIUtil.RemoveClickEvent(self.back_btn.gameObject)
	UIUtil.RemoveClickEvent(self.m_speedBtn.gameObject)
	UIUtil.RemoveClickEvent(self.m_completeBtn.gameObject)
end

function UIBattleHorseRaceMainView:OnClick(go, x, y)
	local btnName = go.name

	if btnName == 'BackBtn' then
		self:Back()
	elseif btnName == 'speedBtn' then
		self.m_speed = self.m_speed + 0.5
		self.m_speed = self.m_speed > 1.5 and 1 or self.m_speed
		TimeScaleMgr:SetTimeScaleMultiple(self.m_speed)
		CtlBattleInst:GetLogic():WriteSpeedUpSetting(self.m_speed)

		if self.m_speed == 1 then
			self.m_speedImage:SetAtlasSprite("zhandou92.png", true)
		elseif self.m_speed == 1.5 then
			self.m_speedImage:SetAtlasSprite("zhandou93.png", true)
		end
	elseif btnName == 'completeBtn' then
		SceneManagerInst:SwitchScene(SceneConfig.HomeScene)
	end
end

function UIBattleHorseRaceMainView:OnDestroy()
	self:RemoveClick()

	for _,item in pairs(self.m_rankItemArray) do
		item:Delete()
	end
	self.m_rankItemArray = {}

	self.m_loaderSeq = 0
    self.back_btn = nil
    self.m_speed = 1
    self.m_speedImage = nil
	self.m_speedBtn = nil

	base.OnDestroy(self)
end

function UIBattleHorseRaceMainView:OnAddListener()
	base.OnAddListener(self)
	-- UI消息注册
	self:AddUIListener(UIMessageNames.UIBATTLE_START, self.OnBattleStart)
	self:AddUIListener(UIMessageNames.UIBATTLE_STOP, self.OnBattleStop)
	self:AddUIListener(UIMessageNames.UIBATTLE_HIDE_MAINVIEW, self.Hide)
	self:AddUIListener(UIMessageNames.UIBATTLE_SHOW_MAINVIEW, self.Show)
	self:AddUIListener(UIMessageNames.MN_HORSERACE_COUNT_DOWN, self.ShowCountDown)
	self:AddUIListener(UIMessageNames.MN_HORSERACE_SHOW_CURRENT_RANK, self.ShowCurRankShow)
	self:AddUIListener(UIMessageNames.MN_HORSERACE_UPDATE_RANK, self.UpdateRankShow)
	self:AddUIListener(UIMessageNames.MN_HORSERACE_SHOW_SELF_RANK, self.ShowSelfRankNun)
	self:AddUIListener(UIMessageNames.MN_HORSERACE_COMPLETE_BATTLE, self.OnCompleteBattle)
end

function UIBattleHorseRaceMainView:OnRemoveListener()
	base.OnRemoveListener(self)
	-- UI消息注销
	self:RemoveUIListener(UIMessageNames.UIBATTLE_START, self.OnBattleStart)
	self:RemoveUIListener(UIMessageNames.UIBATTLE_STOP, self.OnBattleStop)
	self:RemoveUIListener(UIMessageNames.UIBATTLE_HIDE_MAINVIEW, self.Hide)
	self:RemoveUIListener(UIMessageNames.UIBATTLE_SHOW_MAINVIEW, self.Show)
	self:RemoveUIListener(UIMessageNames.MN_HORSERACE_COUNT_DOWN, self.ShowCountDown)
	self:RemoveUIListener(UIMessageNames.MN_HORSERACE_SHOW_CURRENT_RANK, self.ShowCurRankShow)
	self:RemoveUIListener(UIMessageNames.MN_HORSERACE_UPDATE_RANK, self.UpdateRankShow)
	self:RemoveUIListener(UIMessageNames.MN_HORSERACE_SHOW_SELF_RANK, self.ShowSelfRankNun)
	self:RemoveUIListener(UIMessageNames.MN_HORSERACE_COMPLETE_BATTLE, self.OnCompleteBattle)
end

function UIBattleHorseRaceMainView:OnDisable()
	UIGameObjectLoader:GetInstance():CancelLoad(self.m_loaderSeq)
	self.m_loaderSeq = 0
end

function UIBattleHorseRaceMainView:ShowCountDown(countDownTime)
	if countDownTime then
		if countDownTime ~= 0 then
			local iconNum = math_ceil(countDownTime + 5)
			self.m_rankNumImage:SetAtlasSprite("saima"..iconNum..".png", true)
		end
		
		self.m_rankNumPic.gameObject:SetActive(countDownTime ~= 0)
		self.m_rankNumPic.localScale = Vector3.New(1, 1, 1)

		local tweener = DOTween.ToFloatValue(function()
			return 0
		end, 
		function(value)
			self.m_rankNumImage:SetColor(Color.New(1, 1, 1, 0.5 + 0.5*value))
			self.m_rankNumPic.localScale = Vector3.one * value * 3
		end, 1, 0.8)
		DOTweenSettings.SetEase(tweener, DoTweenEaseType.OutQuint)

	end
end

function UIBattleHorseRaceMainView:ShowCurRankShow(is_show)
	if self.m_rankShowRoot then
		self.m_rankShowRoot.gameObject:SetActive(is_show)
	end
end

function UIBattleHorseRaceMainView:UpdateRankShow(rank_list)
	if not rank_list then
		return
	end
	
	if #self.m_rankItemArray == 0 and self.m_loaderSeq == 0 then
		self.m_loaderSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObjects(self.m_loaderSeq, BattleHorseRankItemPath, #rank_list, function(objs)
            self.m_loaderSeq = 0
            if objs then
				for i = 1, #objs do
					local rankItem = BattleHorseRankItem.New(objs[i], self.m_rankShowRoot, BattleHorseRankItemPath)
					rankItem:SetData(rank_list[i], self.base_order)
					table_insert(self.m_rankItemArray, rankItem)
				end
            end
		end)
	else
		for i = 1 , #self.m_rankItemArray do
			self.m_rankItemArray[i]:SetData(rank_list[i], self.base_order)
		end
	end
end

function UIBattleHorseRaceMainView:ShowSelfRankNun(rank)
	if rank then
		local iconNum = math_ceil(rank + 5)
		self.m_rankNumPic.localScale = Vector3.New(1, 1, 1)
		self.m_rankEnd.localScale = Vector3.New(0.2, 0.2, 0.2)

		self.m_rankNumImage:SetAtlasSprite("saima"..iconNum..".png", true)
		self.m_rankNumPic.gameObject:SetActive(true)
		self.m_rankFontPic.gameObject:SetActive(true)

		local tweener = DOTween.ToFloatValue(function()
			return 0
		end, 
		function(value)
			self.m_rankNumImage:SetColor(Color.New(1, 1, 1, 0.5 + 0.5*value))
			self.m_rankEnd.localScale = Vector3.one * value
			self.m_rankFontImage:SetColor(Color.New(1, 1, 1, 0.5 + 0.5*value))
		end, 1, 2)
		DOTweenSettings.SetEase(tweener, DoTweenEaseType.OutQuint)

	end
end

function UIBattleHorseRaceMainView:Update()
end

function UIBattleHorseRaceMainView:OnCompleteBattle()
	self.m_completeBtn.gameObject:SetActive(true)
end

function UIBattleHorseRaceMainView:OnBattleStart(wave)
end

function UIBattleHorseRaceMainView:OnBattleStop(wave)
end

function UIBattleHorseRaceMainView:Back()
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
	local battleResultData = nil
	if battleLogic then
		battleResultData = battleLogic:GetBattleParam().battleResultData
	end
	if battleResultData then
		UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(9), self:GetBackLanguage(), 
		nil,nil, Language.GetString(4160), function()
			BattleCameraMgr:Resume()
			CtlBattleInst:Resume(BattleEnum.PAUSEREASON_WANT_EXIT)
			if not isAlreadPause then
				CtlBattleInst:FrameResume()
			end
		end)
	else
		UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(9), Language.GetString(6), 
		Language.GetString(4173), function()
			if battleLogic then
				Player:GetInstance():GetMainlineMgr():GetUIData().isAutoFight = false
				battleLogic:OnCityReturn()
			end
		end, Language.GetString(4160), function()
			BattleCameraMgr:Resume()
			CtlBattleInst:Resume(BattleEnum.PAUSEREASON_WANT_EXIT)
			if not isAlreadPause then
				CtlBattleInst:FrameResume()
			end
		end)
	end
end

function UIBattleHorseRaceMainView:GetBackLanguage()
	return Language.GetString(4159)
end

function UIBattleHorseRaceMainView:Hide()
	self.rectTransform.localPosition = Vector3.New(0, 3000, 0)
end

function UIBattleHorseRaceMainView:Show()
	self.rectTransform.localPosition = Vector3.zero
end

return UIBattleHorseRaceMainView