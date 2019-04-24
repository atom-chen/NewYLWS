
local base = require "UI.UIBattleRecord.View.BattleSettlementView"
local UIGuildWarRobSettlementView = BaseClass("UIGuildWarRobSettlementView", base)

local string_format = string.format

function UIGuildWarRobSettlementView:OnCreate()
    base.OnCreate(self)
    
    self.m_jungongText = UIUtil.GetChildTexts(self.transform, {
        "Canvas/jungongText",
    })
end

function UIGuildWarRobSettlementView:OnEnable(...)
    base.OnEnable(self, ...)

    local order, msgObj = ...
    if not msgObj then
        -- print(' battle settlement view no msgObj ')
        return 
    end
    self.m_msgObj = msgObj

    self.starListTrans.gameObject:SetActive(false)
    self.m_bottomContentTr.gameObject:SetActive(false)
    self.m_finish = true
    self:CoroutineDrop()

    local finish_result = msgObj.battle_result.result --1:左边赢， 2：右边赢

    if finish_result == 1 then
        self:HandleWinOrLoseEffect(0)
        self.m_jungongText.text = string_format(Language.GetString(2353), msgObj.add_jungong)
    else
        self:HandleWinOrLoseEffect(1)
    end
end

return UIGuildWarRobSettlementView