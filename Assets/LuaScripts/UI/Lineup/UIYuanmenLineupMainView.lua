
local table_insert = table.insert
local string_format = string.format
local CSObject = CS.UnityEngine.Object
local SplitString = CUtil.SplitString
local BattleEnum = BattleEnum
local Utils = Utils
local CommonDefine = CommonDefine
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTween = CS.DOTween.DOTween
local DOTweenSettings = CS.DOTween.DOTweenSettings
local GameObject = CS.UnityEngine.GameObject
local Vector3 = Vector3
local wujiangMgr = Player:GetInstance():GetWujiangMgr()
local Type_Image = typeof(CS.UnityEngine.UI.Image) 
local Color = Color
local Type_CanvasGroup = typeof(CS.UnityEngine.CanvasGroup)


local UILineupMainView = require "UI.Lineup.UILineupMainView"
local UIYuanmenLineupMainView = BaseClass("UIYuanmenLineupMainView", UILineupMainView)
local base = UILineupMainView
local yuanmenMgr = Player:GetInstance():GetYuanmenMgr()

local InitPosY = 40
local Speed = 2.5
local PauseAlpha = 0.5
local AlphaSpeed = 0.013

function UIYuanmenLineupMainView:OnEnable(...)
    base.OnEnable(self, ...)
     
    self.m_yuanmenRoot.gameObject:SetActive(true)

    local one_yuanmen = yuanmenMgr:GetOneYuanmenInfo(self.m_copyID)
    if not one_yuanmen then
        return
    end 
    
    self:SetDesText(one_yuanmen.left_buff_list, one_yuanmen.right_buff_list)
end 

function UIYuanmenLineupMainView:OnDisable()
    self.m_yuanmenRoot.gameObject:SetActive(false)

    base.OnDisable(self)
end

-- 初始化UI变量
function UIYuanmenLineupMainView:InitView()
    base.InitView(self)

    self.m_yuanmenRoot = UIUtil.GetChildRectTrans(self.transform, { 
        "BottomContainer/YuanmenRoot",
    })

    local leftDesText_1, leftDesText_2, leftDesText_3, leftDesText_4, leftDesText_5, rightDesText_1, rightDesText_2, rightDesText_3, rightDesText_4, rightDesText_5

    leftDesText_1,
    leftDesText_2,
    leftDesText_3,
    leftDesText_4,
    leftDesText_5,
    rightDesText_1,
    rightDesText_2,
    rightDesText_3,
    rightDesText_4,
    rightDesText_5,    
    desLeftText,
    desRightText = UIUtil.GetChildTexts(self.transform, {
         "BottomContainer/YuanmenRoot/leftContainer/additionDesContainer/des1",
         "BottomContainer/YuanmenRoot/leftContainer/additionDesContainer/des2",
         "BottomContainer/YuanmenRoot/leftContainer/additionDesContainer/des3",
         "BottomContainer/YuanmenRoot/leftContainer/additionDesContainer/des4",
         "BottomContainer/YuanmenRoot/leftContainer/additionDesContainer/des5",
         "BottomContainer/YuanmenRoot/rightContainer/additionDesContainer/des1",
         "BottomContainer/YuanmenRoot/rightContainer/additionDesContainer/des2",
         "BottomContainer/YuanmenRoot/rightContainer/additionDesContainer/des3",
         "BottomContainer/YuanmenRoot/rightContainer/additionDesContainer/des4",
         "BottomContainer/YuanmenRoot/rightContainer/additionDesContainer/des5", 
         
         "BottomContainer/YuanmenRoot/leftContainer/desTitleText",
         "BottomContainer/YuanmenRoot/rightContainer/desTitleText",
    })

    self.m_leftDesTextList = {leftDesText_1, leftDesText_2, leftDesText_3, leftDesText_4, leftDesText_5}
    self.m_rightDesTextList = {rightDesText_1, rightDesText_2, rightDesText_3, rightDesText_4, rightDesText_5}

    desLeftText.text = Language.GetString(3311)
    desRightText.text = Language.GetString(3312)
end  

function UIYuanmenLineupMainView:SetDesText(left_buff_list, right_buff_list)
    for i = 1, 5 do 
        self.m_leftDesTextList[i].text = ""
        self.m_rightDesTextList[i].text = ""
    end

    local leftCount = #left_buff_list
    local rightCount = #right_buff_list
    
    for i = 1, leftCount do 
        local leftBuffCfg = ConfigUtil.GetYuanmenBuffCfgByID(left_buff_list[i])
        self.m_leftDesTextList[i].text = leftBuffCfg.desc
    end
    for i = 1, rightCount do
        local rightBuffCfg = ConfigUtil.GetYuanmenBuffCfgByID(right_buff_list[i])
        self.m_rightDesTextList[i].text = rightBuffCfg.desc
    end 
end

function UIYuanmenLineupMainView:TweenOpen()
    DOTween.ToFloatValue(function()
        return 0
    end, 
    function(value)
        self.m_topContainer.anchoredPosition = Vector3.New(0, 130 - 130 * value, 0)
        local pos = Vector3.New(0, 0.9, 0.6 - 1 * value)
        self.m_roleCameraTrans.localPosition = pos
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

return UIYuanmenLineupMainView