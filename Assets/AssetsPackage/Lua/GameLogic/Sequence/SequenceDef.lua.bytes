
local table_insert = table.insert

SequenceEventType = {
    NONE = 0,                           -- 
    START = 1,                          --
    UPDATE = 2,                         -- 
    DELAY = 3,                          -- 延时
    DELAY_FRAME = 4,                    -- 等待下一帧

    BATTLE_LOGIC_INIT_BEGIN = 8,        -- 战斗逻辑初始化开始
    BATTLE_LOGIC_INIT_COMPLETE = 9,     -- 战斗逻辑初始化结束
    BATTLE_GO_START = 10,                -- 战斗过场开始
    BATTLE_GO_END = 11,                  -- 战斗过场结束
    BATTLE_WAVE_END = 12,                -- 战斗一波结束

    
    BATTLE_END = 13,                     -- 战斗结束
    BATTLE_WIN_ACTION = 14,              -- 战斗胜利动作
    SKILL_INPUT_ACTIVE = 15,             -- 激活大招输入
    SKILL_INPUT_DEACTIVE = 16,           -- 结束大招输入

    -- 和C#侧WaitEventClipInspector.EventType 对应
    SHOW_UI_START = 17,                  -- 开始显示某UI
    CLOSE_UI_END = 18,                   -- 某UI关闭
    CLICK_UI = 19,                       -- 点击UI物件    
    PLOT_TIMELINE_END = 20,              -- 剧情关闭
    SHOW_UI_END = 21,                    -- UI完全显示
    CHILD_UI_SHOW_END = 22,              -- 子UI显示完成
    SHENBING_OPERATION_FINISH = 23,      --神兵装备、强化
    TWEEN_END = 24,                      --界面中各种Tween位移  
    EQUIP_HORSE = 25,                    --装备坐骑
}

SkipState = {
    None = 0,
    Start = 1,
    Process = 2,
    End = 3,
}

WhatContext = {
    PLOT = 1,
    GUIDE = 2,
    SUMMON = 3,
}

PLOTPROGRESS = {
    INIT_BEGIN = 1,
    INIT_END = 2,
    BEGIN_CAMERA = 3,
    WAVE_CAMERA = 4,
    BATTLE_START = 5,
    WAVE_END = 6,
    GO_NEXT_PAGE = 7,
    FINISH = 8,
    WIN_COMPLETE = 9,
    WIN_COMPLETE_WITHOUT_CAMERA = 10,
}

----------------------------------------
SequenceEvent = BaseClass("SequenceEvent")
function SequenceEvent:__init(eventType, args, filter, callback)
    self.eventType = eventType
    self.args = args or false
    self.filter = filter or false
    self.callback = callback or false
end

----------------------------------------
SequenceWaiting = BaseClass("SequenceWaiting")
function SequenceWaiting:__init(event)
    self.eventList = false
    if event then
        self.eventList = {}
        table_insert(self.eventList, event)
    end
end

function SequenceWaiting:AddEvent(event)
    if not self.eventList then
        self.eventList = {}
    end    
    table_insert(self.eventList, event)
end

----------------------------------------
SequenceTriggerData = BaseClass("SequenceTriggerData")
function SequenceTriggerData:__init(eventType, args)
    self.eventType = eventType
    self.args = args or false
end

----------------------------------------
SequenceStep = BaseClass("SequenceStep")
function SequenceStep:__init(name, func)
    self.name = name
    self.func = func
end

----------------------------------------
SequenceBase = BaseClass("SequenceBase")
function SequenceBase:__init()
    self.steps = {}     -- SequenceStep[]
end
function SequenceBase:IsCrossScene()
    return false
end
function SequenceBase:GetPreLoadList()
    return nil
end


