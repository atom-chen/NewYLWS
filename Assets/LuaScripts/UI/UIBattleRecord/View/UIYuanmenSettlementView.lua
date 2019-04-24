local base = require "UI.UIBattleRecord.View.BattleSettlementView"
local UIYuanmenSettlementView = BaseClass("UIYuanmenSettlementView", base)

local math_floor = math.floor
local table_insert = table.insert
local string_format = string.format
 

function UIYuanmenSettlementView:InitView()
    base.InitView(self)

    self.m_scoreDetailContentTr,
    self.m_attachItemScrollViewTr = UIUtil.GetChildTransforms(self.transform, {
        "ScoreDetailContent",   
        "bottomContainer/attachItemScrollView",     
    })

    self.m_titleTxt,
    self.m_timeDesTxt,
    self.m_timeTxt,
    self.m_timeCountTxt,
    self.m_diedDesTxt,
    self.m_diedTxt,
    self.m_diedCountTxt = UIUtil.GetChildTexts(self.transform, { 
        "ScoreDetailContent/BgContent/TitleTxt",
        "ScoreDetailContent/BgContent/TimeDesTxt",
        "ScoreDetailContent/BgContent/TimeDesTxt/TimeTxt",
        "ScoreDetailContent/BgContent/TimeDesTxt/CountTxt",
        "ScoreDetailContent/BgContent/DiedDesTxt",
        "ScoreDetailContent/BgContent/DiedDesTxt/DiedTxt", 
        "ScoreDetailContent/BgContent/DiedDesTxt/CountTxt", 
    })
    self.m_titleTxt.text = Language.GetString(3317)
    self.m_timeDesTxt.text = Language.GetString(3318)
    self.m_diedDesTxt.text = Language.GetString(3320)

    self:SetAttachContentPos()
end

function UIYuanmenSettlementView:SetAttachContentPos()
    self.m_yuanmenOriPosY = self.m_attachItemScrollViewTr.anchoredPosition.y

    self.m_attachItemScrollViewTr.anchoredPosition = Vector3.New(360, self.m_yuanmenOriPosY, 0)
end

function UIYuanmenSettlementView:OnEnable(...)
    base.OnEnable(self, ...)
    self.m_scoreDetailContentTr.gameObject:SetActive(true)
    
    local _, msgObj = ...
    if msgObj then
        coroutine.start(self.UpdateSorceNum, self, msgObj.battle_result.yuanmen_result)
    end
end

function UIYuanmenSettlementView:UpdateSorceNum(resultInfo)
    coroutine.waitforseconds(0.2)  

    local consumeTime =  os.date("%M:%S", resultInfo.consumed_time) or ""

    local dTimeScore = math.ceil(resultInfo.deduct_time_score)
    if dTimeScore ~= 0 then 
        dTimeScore = "-"..dTimeScore
    end
    self.m_timeTxt.text = string_format(Language.GetString(3319), consumeTime)
    self.m_timeCountTxt.text = string_format(Language.GetString(3326), dTimeScore)
    local diedCountStr = math.ceil(resultInfo.dead_wujiang)
    self.m_diedTxt.text = string_format(Language.GetString(3319), diedCountStr)
    local dWujiangScore = math.ceil(resultInfo.deduct_dead_wujiang)
    if dWujiangScore ~= 0 then
        dWujiangScore = '-'..dWujiangScore
    end
    self.m_diedCountTxt.text = string_format(Language.GetString(3326), dWujiangScore)

    local score = resultInfo.score
    
    local score2 = score
    if not score or score == 0 then
        return
    end 

    self.m_scoreImageTran.gameObject:SetActive(true)

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

	for i = index, 5 do 
		self.m_scoreNumList[index].gameObject:SetActive(false)
	end

	local nowImg = Player:GetInstance():GetYuanmenMgr():GetEvaluationSpritePath(score2)
    self.m_scoreImage:SetAtlasSprite(nowImg)
    
    self:ScoreChgShow()
end

local SCORE_SCALE = Vector3.New(0.02, 0.02, 0.02)
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings

function UIYuanmenSettlementView:ScoreChgShow()
	self.m_scoreImageTran.localScale = SCORE_SCALE
	local tweener = DOTweenShortcut.DOScale(self.m_scoreImage.transform, 1, 0.2)
	DOTweenSettings.SetEase(tweener, DoTweenEaseType.InBack)
end

function UIYuanmenSettlementView:OnDisable()
    self.m_scoreDetailContentTr.gameObject:SetActive(false)
    self.m_attachItemScrollViewTr.anchoredPosition = Vector3.New(0, self.m_yuanmenOriPosY, 0)

    base.OnDisable(self)
end

return UIYuanmenSettlementView