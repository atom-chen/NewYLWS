local table_insert = table.insert 
local table_remove = table.remove
-- local NewCloseUpEffect = CS.NewCloseUpEffect

local DazhaoStateComponent = BaseClass("DazhaoStateComponent")

function DazhaoStateComponent:__init(dazhaoState)
    self.dazhaoState = dazhaoState
    -- self.m_changeBgColorList = {}
end

function DazhaoStateComponent:__delete()
    
end

function DazhaoStateComponent:Update(deltaMS)
    -- self:CheckChangeBgColor()
end

-- function DazhaoStateComponent:ChangeBGColor()
--     local skillCfg = self.dazhaoState:GetSkillCfg()
--     if not skillCfg then
--         return
--     end

--     self.m_changeBgColorList = {}

--     local list = skillCfg.bgColorParams
--     if list and #list > 0 then
--         for i = 1, #list do
--             local bgColorList = list[i]
--             local _delay = bgColorList[1]
--             local _during = bgColorList[2]
--             local _color = Color.New(bgColorList[3], bgColorList[4], bgColorList[5], bgColorList[6])
--             table_insert(self.m_changeBgColorList, {delay = _delay, during = _during, color = _color})
--         end
--     end

--     self:CheckChangeBgColor()
-- end

-- function DazhaoStateComponent:CheckChangeBgColor()
--     local timeSinceStart = self.dazhaoState:GetTimeSinceStart()
--     if timeSinceStart and self.m_changeBgColorList and #self.m_changeBgColorList > 0 then
--         for i = 1, #self.m_changeBgColorList do
--             if timeSinceStart >= self.m_changeBgColorList[i].delay then
--                 NewCloseUpEffect.AdjustBGColor(nil, self.m_changeBgColorList[i].color, self.m_changeBgColorList[i].during)
--                 table_remove(self.m_changeBgColorList, i)
--                 break
--             end
--         end
--     end
-- end

return DazhaoStateComponent