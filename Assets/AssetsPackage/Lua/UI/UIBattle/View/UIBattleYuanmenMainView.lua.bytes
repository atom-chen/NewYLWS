
local GameUtility = CS.GameUtility
local UIUtil = UIUtil
local UIBattleMainView = require("UI.UIBattle.View.UIBattleMainView")
local UIBattleYuanmenMainView = BaseClass("UIBattleYuanmenMainView", UIBattleMainView)
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
local yuanmenMgr = Player:GetInstance():GetYuanmenMgr()

local CtlBattleInst = CtlBattleInst
local SCORE_SCALE = Vector3.New(3, 3, 3)
  

----------------------------------------------------------------------------------------------------------
function UIBattleYuanmenMainView:OnCreate()
	base.OnCreate(self)

	self.m_scoreNumList = {}
	self.m_score = -1
	self.m_scoreImgPath = ''

	self.m_inscriptionScoreRoot, self.m_scoreNumTran = UIUtil.GetChildTransforms(self.transform, {
		"TopRightContainer/InscriptionScore",
		"TopRightContainer/InscriptionScore/ScoreNum",
	})
	
	self.m_scoreImage = self:AddComponent(UIImage, "TopRightContainer/InscriptionScore/ScoreImage", AtlasConfig.BattleDynamicLoad)
	for i = 1, 5 do 
		local image = self:AddComponent(UIImage, "TopRightContainer/InscriptionScore/ScoreNum/itemGroup/num"..i, AtlasConfig.BattleDynamicLoad)
		image.gameObject:SetActive(false)
        table_insert(self.m_scoreNumList, image)
	end	
end

function UIBattleYuanmenMainView:OnDestroy()	
	self.m_scoreNumList = nil

	base.OnDestroy(self)
end

function UIBattleYuanmenMainView:Update()
	base.Update(self)

	self:UpdateNeedScore()
end

function UIBattleYuanmenMainView:UpdateNeedScore()
	if not self.m_isShowInscriptinCopyRoot then
		self.m_inscriptionScoreRoot.gameObject:SetActive(true)
		self.m_isShowInscriptinCopyRoot = true
	end
	
	local logic = CtlBattleInst:GetLogic()
	if logic then
		if logic:GetScore() ~= self.m_score then
			self.m_score = logic:GetScore()
			self:UpdateSorceNum()
		end
	end
end

function UIBattleYuanmenMainView:UpdateSorceNum()
	local score  = self.m_score 
	local num_list = {}
	local num
	
	repeat
		num = score % 10
		score = math_floor(score / 10)
		table_insert(num_list, num)
	until score == 0

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

	-- local scoreAwardCfgList	= ConfigUtil.GetInscriptionCopyScoreAwardCfgList()
	-- for i, v in ipairs(scoreAwardCfgList) do
	-- 	if v then
	-- 		if self.m_score <= v.max and self.m_score >= v.min then
	-- 			if self.m_scoreAwardID ~= i then
	-- 				self.m_scoreAwardID = i
	-- 				self:ScoreChgShow()
	-- 			end
	-- 			self.m_scoreImage:SetAtlasSprite("queshen"..math_floor(i)..".png")
	-- 		end
	-- 	end
	-- end

	local nowImg = yuanmenMgr:GetEvaluationSpritePath(self.m_score)

	if self.m_scoreImgPath ~= nowImg then
		self:ScoreChgShow()
		self.m_scoreImgPath = nowImg
		self.m_scoreImage:SetAtlasSprite(nowImg)
	end
end

function UIBattleYuanmenMainView:ScoreChgShow()
	self.m_scoreImage.transform.localScale = SCORE_SCALE
	local tweener = DOTweenShortcut.DOScale(self.m_scoreImage.transform, 1, 0.2)
	DOTweenSettings.SetEase(tweener, DoTweenEaseType.InBack)
end

return UIBattleYuanmenMainView