
local table_insert = table.insert
local string_format = string.format
local CSObject = CS.UnityEngine.Object
local SplitString = CUtil.SplitString
local BattleEnum = BattleEnum
local Utils = Utils
local CommonDefine = CommonDefine
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local GameObject = CS.UnityEngine.GameObject
local Vector3 = Vector3

local UILineupMainView = require "UI.Lineup.UILineupMainView"
local UIShenbingCopyLineupMainView = BaseClass("UIShenbingCopyLineupMainView", UILineupMainView)
local base = UILineupMainView

function UIShenbingCopyLineupMainView:OnEnable(...)
    base.OnEnable(self, ...)
    
    self:ChgSpecialText()
end

function UIShenbingCopyLineupMainView:OnDisable()
    self.m_textBg.gameObject:SetActive(false)

    base.OnDisable(self)
end

-- 初始化UI变量
function UIShenbingCopyLineupMainView:InitView()
    base.InitView(self)

    self.m_textBg = UIUtil.GetChildRectTrans(self.transform, {
        "TopContainer/TextBg",
    })

    self.m_speicalText = UIUtil.GetChildTexts(self.transform, {
        "TopContainer/TextBg/SpecialText",
    })
end

function UIShenbingCopyLineupMainView:ChgSpecialText()
    local nameList = {}

    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_SHENBING)
    local briefList = Player:GetInstance():GetLineupMgr():GetLineupBriefList(buzhenID)
    for _, v in ipairs(briefList) do
        local wujiangCfg = ConfigUtil.GetWujiangCfgByID(v.id)
        if wujiangCfg and wujiangCfg.rare > CommonDefine.WuJiangRareType_2 then
            table_insert(nameList, wujiangCfg.sName)
        end
    end

    if #nameList > 0 then
        local nameStr = ''
        for i = 1, #nameList do
            nameStr = nameStr .. nameList[i]

            if i < #nameList then
                nameStr = nameStr .. '、'
            end
        end
        self.m_speicalText.text = string_format(Language.GetString(2816), nameStr)

        self.m_textBg.gameObject:SetActive(true)
    else
        self.m_textBg.gameObject:SetActive(false)
    end
end


function UIShenbingCopyLineupMainView:UpdateLineup()
    base.UpdateLineup(self)
    self:ChgSpecialText()
end

return UIShenbingCopyLineupMainView