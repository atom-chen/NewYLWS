local table_insert = table.insert
local FixMod = FixMath.mod

BattleRander = {
    m_randList = {},
    m_curr = 0,
    Generate = function(count)
        local self = BattleRander
        local random = math.random
        for i = 1, count do
            -- table_insert(self.m_randList, random(1, 1000))   todo for test
            table_insert(self.m_randList, i)
        end
    end,

    AddRandList = function(randList)
        BattleRander.m_curr = 0
        BattleRander.m_randList = randList
    end,

    Rand = function()
        local self = BattleRander
        if #self.m_randList == 0 then
            return 100
        end
    
        self.m_curr = self.m_curr + 1
        if self.m_curr  > #self.m_randList then
            self.m_curr = 1
        end

        return self.m_randList[self.m_curr]
    end,

    Clear = function()
        BattleRander.m_randList = {}
        BattleRander.m_curr = 0
    end,
}

