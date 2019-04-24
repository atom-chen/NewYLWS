local IsNull = IsNull
local UIUtil = UIUtil
local FixNewVector3 = FixMath.NewFixVector3
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTween = CS.DOTween.DOTween
local string_format = string.format
local math_ceil = math.ceil
local BattleHorseRankItem = BaseClass("BattleHorseRankItem", UIBaseItem)
local base = UIBaseItem
local SPEED_PARAMETER = 8

function BattleHorseRankItem:OnCreate()
    base.OnCreate(self)

    local speed1,speed2,speed3,speed4,speed5,speed6
    self.m_speedContent, speed1, speed2, speed3, speed4, speed5, speed6 = UIUtil.GetChildRectTrans(self.transform, {
        "speedContent",
        "speedContent/speed1",
        "speedContent/speed2",
        "speedContent/speed3",
        "speedContent/speed4",
        "speedContent/speed5",
        "speedContent/speed6",
    })

    self.m_nameText = UIUtil.GetChildTexts(self.transform, {
        "nameText",
    })
    self.m_bgImage = UIUtil.AddComponent(UIImage, self, "bgImage", AtlasConfig.BattleDynamicLoad)
    self.m_speedList = { speed1, speed2, speed3, speed4, speed5, speed6 }
    self:ShowSpeedChange()
end

function BattleHorseRankItem:OnDestroy()
    --self:ClearNuqiEffect()
    base.OnDestroy(self)
end

function BattleHorseRankItem:SetData(rankInfo, viewBaseOrder)
    self.m_viewBaseOrder = viewBaseOrder
    
    if rankInfo then
        local sIcon = rankInfo.isSelf and "saima3.png" or "saima2.png"
        self.m_bgImage:SetAtlasSprite(sIcon, false)
        local name = rankInfo.isSelf and string_format(Language.GetString(4170),rankInfo.name) or rankInfo.name
        self.m_nameText.text = name
        local curSpeedCount = math_ceil(rankInfo.curSpeed / SPEED_PARAMETER)
        local count = #self.m_speedList - curSpeedCount
        for i = 1, #self.m_speedList do
            self.m_speedList[i].gameObject:SetActive(i > count)
        end
    end
end

function BattleHorseRankItem:ShowSpeedChange()
    local tweener = DOTween.ToFloatValue(function()
        return 0
    end, 
    function(value)
        self.m_speedList[#self.m_speedList].localScale = Vector3.New( 1 + 0.1 * value, 1, 1)
    end, 1, 0.1)
    DOTweenSettings.SetLoops(tweener, -1, 1)
end

return BattleHorseRankItem

