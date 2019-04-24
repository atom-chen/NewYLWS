
local GameUtility = CS.GameUtility
local UIUtil = UIUtil
local UIBattleMainView = require("UI.UIBattle.View.UIBattleMainView")
local UIBattleInscriptionMainView = BaseClass("UIBattleInscriptionMainView", UIBattleMainView)
local base = UIBattleMainView
local unity_key_code = CS.UnityEngine.KeyCode
local Vector3 = Vector3
local ActorUtil = ActorUtil
local Quaternion = CS.UnityEngine.Quaternion
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local TypeText = typeof(CS.TMPro.TextMeshProUGUI)
local table_sort = table.sort
local table_insert = table.insert
local table_remove = table.remove
local string_format = string.format
local math_floor = math.floor
local Language = Language
local MeshRenderer = CS.UnityEngine.MeshRenderer
local Type_MeshRenderer = typeof(MeshRenderer)
local Type_RectTransform = typeof(CS.UnityEngine.RectTransform)
local Shader = CS.UnityEngine.Shader
local CommonDefine = CommonDefine
local ScreenPointToLocalPointInRectangle = CS.UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTweenExtensions = CS.DOTween.DOTweenExtensions
local BagItemPrefabPath = TheGameIds.CommonBattleBagItemPrefab
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local UISliderHelper = typeof(CS.UISliderHelper)

local blood_slider_path = "topMiddleContainer/bossBlood/bloodSlider"
local boss_img_path = "topMiddleContainer/bossBlood/bloodSlider/bloodSpt"

local BOX_SCALE = Vector3.New(0.5, 0.5, 0.5)
local SCORE_SCALE = Vector3.New(3, 3, 3)
  
local ItemType = {
	21110,--命签[条]
	21101,--命签[筒]
	21119,--命签[万]
	21128,--命签[东]
	21130,--命签[南]
	21229,--命签[西]
	21231,--命签[北]
	21132,--命签[中]
	21133, --命签[发]
	21134, --命签[白]
}

----------------------------------------------------------------------------------------------------------
local FlyingItem = BaseClass("FlyingItem", UIBaseItem)
function FlyingItem:OnCreate()
	--self.m_itemIconSpt = UIUtil.AddComponent(UIImage, self, "ItemIconSpt", AtlasConfig.ItemIcon)
	self.m_mingqianBgSpt = UIUtil.AddComponent(UIImage, self, "mingqianBgSpt", AtlasConfig.ItemIcon)
	self.m_mingqianIcon = UIUtil.AddComponent(UIImage, self, "mingqianBgSpt/mingqianIconSpt", AtlasConfig.ItemIcon)
end

function FlyingItem:SetIcon(icon, atlasCfg)
	if not icon then
		return
	end
	
	self.m_mingqianIcon:SetAtlasSprite(icon, true, AtlasConfig.ItemIcon)
	self.m_mingqianBgSpt:SetAtlasSprite("mj36.png", true, AtlasConfig.ItemIcon)
end

----------------------------------------------------------------------------------------------------------
function UIBattleInscriptionMainView:OnCreate()
	base.OnCreate(self)

	self.m_scoreNumList = {}
	self.m_score = 0
	self.m_isShowInscriptinCopyRoot = false

	self.m_inscriptinCopyRoot, self.m_inscriptionScoreRoot, self.m_scoreNumTran = UIUtil.GetChildTransforms(self.transform, {
		"BottomRightContainer/InscriptionBg",
		"TopRightContainer/InscriptionScore",
		"TopRightContainer/InscriptionScore/ScoreNum",
	})
	
	self.m_lastHP = 0
	self.m_bloodSlider = UIUtil.FindComponent(self.transform, UISliderHelper, blood_slider_path)
	self.m_bloodImg = UIUtil.AddComponent(UIImage, self, boss_img_path)
	self.m_bloodImg:SetFillAmount(1)
	self.m_bloodSlider:UpdateSliderImmediately(1)
	self.m_bossBloodTr = UIUtil.FindTrans(self.transform, "topMiddleContainer/bossBlood")
	self.m_bossID = CtlBattleInst:GetLogic():GetBossID()

	self.m_inscriptionCopyText2 = UIUtil.FindComponent(self.transform, TypeText, "BottomRightContainer/InscriptionBg/inscriptionCopyText2")
	self.m_scoreImage = self:AddComponent(UIImage, "TopRightContainer/InscriptionScore/ScoreImage", AtlasConfig.BattleDynamicLoad)
	for i = 1, 5 do 
		local image = self:AddComponent(UIImage, "TopRightContainer/InscriptionScore/ScoreNum/itemGroup/num"..i, AtlasConfig.BattleDynamicLoad)
		image.gameObject:SetActive(false)
        table_insert(self.m_scoreNumList, image)
	end
	
	self.m_boxRoot.gameObject:SetActive(false)
	self.m_inscriptinCopyRoot.gameObject:SetActive(false)

	--self:UpdateNeedScore()
	--self:UpdateSorceNum()
end

function UIBattleInscriptionMainView:OnDestroy()	
	self.m_bloodSlider:Dispose()
    self.m_bloodSlider = nil
	self.m_inscriptionCopyText2 = nil
	self.m_scoreNumList = nil

	base.OnDestroy(self)
end

function UIBattleInscriptionMainView:Update()
	base.Update(self)
	self:UpdateBloodPercent()

	local logic = CtlBattleInst:GetLogic()
	if logic then
		local bossLeftMS = logic:GetBossLeftMS()
		if bossLeftMS > 0 then
			local leftS = math_floor(bossLeftMS / 1000)
			if leftS ~= self.m_bossLeftS then
				self.m_bossBloodTr.gameObject:SetActive(true)

				local bossID, bossIndex	= logic:GetBossData()
				local monsterCfg = ConfigUtil.GetMonsterCfgByID(bossID)
				
				if monsterCfg then
					local wujiangCfg = ConfigUtil.GetWujiangCfgByID(monsterCfg.role_id)
					
					if wujiangCfg then
						if bossIndex == 1 then
							self.m_inscriptionCopyText2.text = string_format(Language.GetString(1901), wujiangCfg.sName, leftS)
						elseif bossIndex == 2 then
							self.m_inscriptionCopyText2.text = string_format(Language.GetString(1903), wujiangCfg.sName, leftS)
						elseif bossIndex == 3 then
							self.m_inscriptionCopyText2.text = string_format(Language.GetString(1904), wujiangCfg.sName, leftS)
						end
						self.m_bossLeftS = leftS
					end
				end
			end
		else
			self.m_bossBloodTr.gameObject:SetActive(false)
			self.m_lastHP = 0
			self.m_bloodImg:SetFillAmount(0)
        	self.m_bloodSlider:UpdateSliderImmediately(0)
			self:UpdateNeedScore()
		end
	end
end

function UIBattleInscriptionMainView:UpdateBloodPercent()
	local btLogic = CtlBattleInst:GetLogic()
    if not btLogic then
        return
    end

	self.m_bossID = btLogic:GetBossID()

    local actor = ActorManagerInst:GetActor(self.m_bossID)
    if not actor then
        self.m_bloodImg:SetFillAmount(0)
        self.m_bloodSlider:UpdateSliderImmediately(0)
        return 
    end

    local actorData = actor:GetData()
    if not actorData then
        return
    end

    local curHP = actorData:GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    local maxHP = actorData:GetAttrValue(ACTOR_ATTR.FIGHT_MAXHP)
    local newPercent = curHP / maxHP

    self.m_bloodImg:SetFillAmount(newPercent)

    local hpChg = curHP - self.m_lastHP
    if hpChg >= 0 or newPercent > self.m_bloodSlider:GetSliderValue() then
        self.m_bloodSlider:UpdateSliderImmediately(newPercent)
    else
        local time = (-hpChg) / maxHP * 8
        time = time > 1.5 and 1.5 or time
        newPercent = newPercent < 0.02 and 0.02 or newPercent
        self.m_bloodSlider:TweenUpdateSlider(newPercent, time)
    end
    self.m_lastHP = curHP
end

function UIBattleInscriptionMainView:UpdateNeedScore()

	if self.m_score > 0 then
		if not self.m_isShowInscriptinCopyRoot then
			self.m_inscriptinCopyRoot.gameObject:SetActive(true)
			self.m_isShowInscriptinCopyRoot = true
		end
		
		local logic = CtlBattleInst:GetLogic()
		if logic then
			local bossLeftMS = logic:GetBossLeftMS()
			if bossLeftMS <= 0 then
				local nextNeed = logic:NextBossNeedScore()
				local diff = nextNeed - self.m_score
				if diff < 0 then
					diff = 0
				end
				self.m_inscriptionCopyText2.text = string_format(Language.GetString(1900), diff)
			end
		end
	end
end

function UIBattleInscriptionMainView:MoveBoxIcon(bagItem, isLast)
	local boxGO = bagItem:GetGameObject()

	local targetPos = self.m_scoreNumTran.position
	local selfPos = bagItem.transform.position

    local pathArray = {
		Vector3.New(selfPos.x, selfPos.y, selfPos.z), Vector3.New(targetPos.x, targetPos.y, targetPos.z)
	}
		
    local tweener = DOTweenShortcut.DOPath(bagItem.transform, pathArray, 1)
	DOTweenSettings.SetEase(tweener, DoTweenEaseType.OutSine)    
	
	DOTweenSettings.OnComplete(tweener, function()
		bagItem:Delete()

		if isLast then
			self:UpdateNeedScore()
			self:UpdateSorceNum()
			self:CheckDropGuide()
		end
	end)
end

function UIBattleInscriptionMainView:PickBox(dropList, score)
	local mainCamera = BattleCameraMgr:GetMainCamera()
	local uiCamera = UIManagerInst.UICamera

	-- 这批最后一个飘到位了 就设置界面上的积分

	if self.m_score == 0 and score ~= 0 then
		self.m_inscriptionScoreRoot.gameObject:SetActive(true)
	end

	self.m_score = score

	local loaderSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
	UIGameObjectLoader:GetInstance():GetGameObjects(loaderSeq, BagItemPrefabPath, #dropList, function(objs)		
		if objs then
			for i = 1, #objs do
				local oneDrop = dropList[i]
				local worldPos, dropType = oneDrop[2], oneDrop[3]
				--worldPos.y = worldPos.y + 0.2

				local ok, outV2 = GameUtility.PosWorld2RectPos(mainCamera, uiCamera, worldPos.x, worldPos.y, worldPos.z, self.rectTransform, 0)
    
				local v_new = Vector3.New(outV2.x, outV2.y, 0)
	
				local flying = FlyingItem.New(objs[i], self.transform, BagItemPrefabPath)
				flying:SetLocalScale(BOX_SCALE)
				flying:SetLocalPosition(v_new)

				local itemID = ItemType[dropType]
				if itemID then
					local itemCfg = ConfigUtil.GetItemCfgByID(itemID)
					if itemCfg then
						flying:SetIcon(itemCfg.sIcon)
					else
						-- print("err itemID ", itemID)		
					end
				end
	
				self:MoveBoxIcon(flying, (i == #objs))
			end
		end
	end)
end


function UIBattleInscriptionMainView:UpdateSorceNum()
	local score  = self.m_score 
	local num_list = {}
	local num
	
	if score > 0 then
		repeat
			num = score % 10
			score = math_floor(score / 10)
			table_insert(num_list, num)
		until score == 0
	end

	local curr_number_count = #num_list
	local index = 1
	local str = ""
    for i = curr_number_count, 1, -1 do
		str = string_format("number5%s.png", math_floor(num_list[i]))
		self.m_scoreNumList[index].gameObject:SetActive(true)
        self.m_scoreNumList[index]:SetAtlasSprite(str)
        index = index + 1
	end
	
	--print("self.m_score", self.m_score , table.dump(num_list))

	for i = index, 5 do 
		self.m_scoreNumList[index].gameObject:SetActive(false)
	end

	local scoreAwardCfgList	= ConfigUtil.GetInscriptionCopyScoreAwardCfgList()
	for i, v in ipairs(scoreAwardCfgList) do
		if v then
			if self.m_score <= v.max and self.m_score >= v.min then
				if self.m_scoreAwardID ~= i then
					self.m_scoreAwardID = i
					self:ScoreChgShow()
				end
				self.m_scoreImage:SetAtlasSprite(v.image)
			end
		end
	end
end

function UIBattleInscriptionMainView:ScoreChgShow()
	self.m_scoreImage.transform.localScale = SCORE_SCALE
	local tweener = DOTweenShortcut.DOScale(self.m_scoreImage.transform, 1, 0.2)
	DOTweenSettings.SetEase(tweener, DoTweenEaseType.InBack)
end

function UIBattleInscriptionMainView:CheckDropGuide()
    if Player:GetInstance():GetUserMgr():IsGuided(GuideEnum.GUIDE_INSCRIPTION_DROP) then
        return
    end
    if GuideMgr:GetInstance():IsPlayingGuide(GuideEnum.GUIDE_INSCRIPTION_DROP) then
        return
    end
    CtlBattleInst:FramePause()
    CtlBattleInst:Pause(BattleEnum.PAUSEREASON_EVERY, 0)
    BattleCameraMgr:Pause()
    GuideMgr:GetInstance():Play(GuideEnum.GUIDE_INSCRIPTION_DROP, function()
        CtlBattleInst:FrameResume()
        CtlBattleInst:Resume(BattleEnum.PAUSEREASON_EVERY)
        BattleCameraMgr:Resume()
    end)
end

return UIBattleInscriptionMainView