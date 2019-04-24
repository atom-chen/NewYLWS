local FightWarItem = BaseClass("FightWarItem", UIBaseItem)
local base = UIBaseItem
local BattleEnum = BattleEnum

local string_format = string.format
local math_ceil = math.ceil
local math_floor = math.floor

local ImageNameList = 
{
    'zhengzhan11.png',
    'zhengzhan5.png',
    'zhengzhan1.png',
    'zhengzhan9.png',
    'zhengzhan8.png',
    'zhengzhan2.png',
    'zhengzhan3.png',
    'zhengzhan13.png',
    'zhengzhan6.png',
    'zhengzhan12.png',
    'zhengzhan4.png',
    'zhengzhan14.png',
    'zhengzhan15.png',
}


function FightWarItem:OnCreate()
    base.OnCreate(self)

    self.m_iconImage = UIUtil.AddComponent(UIImage, self, "", ImageConfig.FightWar)
    self.m_itemIcon = UIUtil.AddComponent(UIImage, self, "ItemIcon", AtlasConfig.ItemIcon)

    self.m_infoText, self.m_itemNumText = UIUtil.GetChildTexts(self.transform, {
        "bg/InfoText",
        "ItemIcon/ItemNumText"
    })
    
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self:GetGameObject(), onClick)
end

function FightWarItem:OnClick(go)

    if go == self:GetGameObject() then

        if self.m_battleType == BattleEnum.BattleType_GRAVE then
            UILogicUtil.SysShowUI(SysIDs.GRAVE_COPY)
            
        elseif self.m_battleType == BattleEnum.BattleType_YUANMEN then
            UILogicUtil.SysShowUI(SysIDs.FIGHTWAR_YUANMEN)
            -- UIManagerInst:OpenWindow(UIWindowNames.UILineupMain, BattleEnum.BattleType_INSCRIPTION, 101) 
        elseif self.m_battleType == BattleEnum.BattleType_SHENSHOU then
            UILogicUtil.SysShowUI(SysIDs.FIGHTWAR_SHENSHOU)
        elseif self.m_battleType == BattleEnum.BattleType_CAMPSRUSH then
            UILogicUtil.SysShowUI(SysIDs.CAMPS_RUSH)

        elseif self.m_battleType == BattleEnum.BattleType_INSCRIPTION then
            UILogicUtil.SysShowUI(SysIDs.INSCRIPTION_COPY)
            
        elseif self.m_battleType == BattleEnum.BattleType_BOSS1 then
            UILogicUtil.SysShowUI(SysIDs.FIGHTWAR_WORLDBOSS)

        elseif self.m_battleType == BattleEnum.BattleType_HUARONG_ROAD then

        elseif self.m_battleType == BattleEnum.BattleType_ARENA then
            UILogicUtil.SysShowUI(SysIDs.ARENA)
           
        elseif self.m_battleType == BattleEnum.BattleType_SHENBING then
            -- UIManagerInst:OpenWindow(UIWindowNames.UILineupMain, BattleEnum.BattleType_SHENBING, 1) 	
            UILogicUtil.SysShowUI(SysIDs.SHENBING_COPY)

        elseif self.m_battleType == BattleEnum.BattleType_THOUSAND_MILES then
            
        elseif self.m_battleType == BattleEnum.BattleType_LIEZHUAN then
            UILogicUtil.SysShowUI(SysIDs.LIEZHUAN)
        elseif self.m_battleType == BattleEnum.BattleType_QUNXIONGZHULU then
            UILogicUtil.SysShowUI(SysIDs.QUNXIONGZHULU)

        elseif self.m_battleType == BattleEnum.BattleType_HORSERACE then
            UILogicUtil.SysShowUI(SysIDs.HORSERACE)

        elseif self.m_battleType == BattleEnum.BattleType_GUILD_BOSS then
            UILogicUtil.SysShowUI(SysIDs.GUILD_BOSS)

        elseif self.m_battleType == BattleEnum.BattleType_GUILD_WARCRAFT then
            UILogicUtil.SysShowUI(SysIDs.GUILD_WAR)
        end
    end
end

function FightWarItem:OnDestroy(cfg)
    self.m_mainIconCfg = nil
end

function FightWarItem:UpdateData(index, one_act_copy)
    self.m_battleType = one_act_copy.battle_type
    self.m_left_times = one_act_copy.left_times  --演武 辕门挑战 对应道具数量
    self.m_status = one_act_copy.status          --上古巨兽： 0可挑战 1已挑战 2不可挑战（open_time 给出可挑战时间）
    self.m_open_time = one_act_copy.open_time
    self.m_param1 = one_act_copy.param1
    self.m_param2 = one_act_copy.param2

    if index <= #ImageNameList then
        if index == 9 then
            local imagePath = "zhengzhan6.png"
            if self.m_param1 == 2034 then
                imagePath = "zhengzhan6.png"
            elseif self.m_param1 == 2031 then
                imagePath = "zhengzhan6_1.png"
            end 
            self.m_iconImage:SetAtlasSprite(imagePath, true)
        else
            self.m_iconImage:SetAtlasSprite(ImageNameList[index], true)
        end 
    end
    
    self:SetWarStatus()
end

function FightWarItem:SetWarStatus()
    self.m_infoText.text = ""
    self.m_itemIcon.gameObject:SetActive(false)

    local itemCount = 3

    local sysID = self:GetSysID()
    if not UILogicUtil.IsSysOpen(sysID) then
        local sysOpenCfg = ConfigUtil.GetSysopenCfgByID(sysID)
        if sysOpenCfg then
            self.m_infoText.text = sysOpenCfg.sDesc
        end
        return
    end

    if self.m_battleType == BattleEnum.BattleType_GRAVE or 
        self.m_battleType == BattleEnum.BattleType_INSCRIPTION or 
        self.m_battleType == BattleEnum.BattleType_SHENSHOU or
        self.m_battleType == BattleEnum.BattleType_CAMPSRUSH or 
        self.m_battleType == BattleEnum.BattleType_HUARONG_ROAD or 
        self.m_battleType == BattleEnum.BattleType_SHENBING or 
        self.m_battleType == BattleEnum.BattleType_THOUSAND_MILES or 
        self.m_battleType == BattleEnum.BattleType_GUILD_BOSS then
            
        local strID = self.m_left_times > 0 and 1702 or 1701
        self.m_infoText.text = string_format(Language.GetString(strID), self.m_left_times)
    
    elseif self.m_battleType == BattleEnum.BattleType_BOSS1 or self.m_battleType == BattleEnum.BattleType_BOSS2 then
        local serverTime = TimeUtil.GetTime(Player:GetInstance():GetServerTime())
        --print("serverTime , ", table.dump(serverTime))
        if self.m_status == 0 then
            self.m_infoText.text = string_format(Language.GetString(1715), self.m_left_times)
        elseif self.m_status == 1 then
            self.m_infoText.text = Language.GetString(1704)
        elseif self.m_status == 2 then
            if self.m_open_time > 0 then
                local openTime = TimeUtil.GetTime(self.m_open_time)
                local serverTime = TimeUtil.GetTime(Player:GetInstance():GetServerTime())
                if openTime.day ~= serverTime.day then
                    self.m_infoText.text = string_format(Language.GetString(1706), openTime.hour)
                else
                    self.m_infoText.text = string_format(Language.GetString(1705), openTime.hour)
                end
            end
        end

    elseif self.m_battleType == BattleEnum.BattleType_ARENA then
        self.m_itemIcon.gameObject:SetActive(true)
        self.m_itemIcon:SetAtlasSprite("20051.png", false)
        local limitNum = Player:GetInstance():GetUserMgr():GetSettingData().arena_lingpai_limit
        if limitNum then
            if limitNum > self.m_left_times then
                self.m_itemNumText.text = string_format(Language.GetString(77), self.m_left_times, limitNum)
            else
                self.m_itemNumText.text = string_format(Language.GetString(83), self.m_left_times, limitNum)
            end
        end
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_arena_dan_award")
        self.m_infoText.text = string_format(Language.GetString(1708), tbl[self.m_param1].dan_name, self.m_param2)
        coroutine.start(self.FitPos, self)

    elseif self.m_battleType == BattleEnum.BattleType_YUANMEN then
        self.m_itemIcon:SetAtlasSprite("20053.png", false)
        self.m_itemIcon.gameObject:SetActive(true)   
        self.m_itemNumText.text = math_ceil(self.m_left_times)
        self.m_infoText.text = string_format(Language.GetString(1707), self.m_param1)        
        coroutine.start(self.FitPos, self)

    elseif self.m_battleType == BattleEnum.BattleType_LIEZHUAN then
        self.m_infoText.text = Language.GetString(1703)

    elseif self.m_battleType == BattleEnum.BattleType_QUNXIONGZHULU then
        if self.m_open_time > 0 then
            local openTime = TimeUtil.GetTime(self.m_open_time)
            local serverTime = TimeUtil.GetTime(Player:GetInstance():GetServerTime())
            if openTime.day ~= serverTime.day then
                self.m_infoText.text = string_format(Language.GetString(1706), openTime.hour)
            else
                self.m_infoText.text = string_format(Language.GetString(1705), openTime.hour)
            end
        else
            self.m_infoText.text = Language.GetString(1703)
        end

    elseif self.m_battleType == BattleEnum.BattleType_HORSERACE then
        self.m_infoText.text = Language.GetString(1703)

    elseif self.m_battleType == BattleEnum.BattleType_GUILD_WARCRAFT then
        local showNum = 0
        if self.m_param1 == 1 then
            showNum = 1711
        elseif self.m_param1 == 2 then
            if self.m_param2 == 0 then
                showNum = 1712
            elseif self.m_param2 == 1 then
                showNum = 1713
                UIManagerInst:Broadcast(UIMessageNames.MN_FIGHTWAR_UPDATE_LEFT_TIME, true, self)
            end
        elseif self.m_param1 == 3 then
            showNum = 1714
        end

        self.m_infoText.text = Language.GetString(showNum) 
    end    
end

function FightWarItem:FitPos()
    coroutine.waitforframes(1)
    --UIUtil.KeepCenterAlign(self.m_itemIcon.transform, self.transform)
end

function FightWarItem:OnDestroy()
    if self.m_iconImage then
        self.m_iconImage:Delete()
        self.m_iconImage = nil
    end
    UIUtil.RemoveClickEvent(self:GetGameObject())
    base.OnDestroy(self)
end

function FightWarItem:GetSysID()
    if self.m_battleType == BattleEnum.BattleType_GRAVE then
        return SysIDs.GRAVE_COPY
        
    elseif self.m_battleType == BattleEnum.BattleType_YUANMEN then
        return SysIDs.FIGHTWAR_YUANMEN
      
    elseif self.m_battleType == BattleEnum.BattleType_SHENSHOU then
        return SysIDs.FIGHTWAR_SHENSHOU

    elseif self.m_battleType == BattleEnum.BattleType_CAMPSRUSH then
        return SysIDs.CAMPS_RUSH

    elseif self.m_battleType == BattleEnum.BattleType_INSCRIPTION then
        return SysIDs.INSCRIPTION_COPY
        
    elseif self.m_battleType == BattleEnum.BattleType_BOSS1 then
        return SysIDs.FIGHTWAR_WORLDBOSS

    elseif self.m_battleType == BattleEnum.BattleType_HUARONG_ROAD then

    elseif self.m_battleType == BattleEnum.BattleType_ARENA then
        return SysIDs.ARENA
       
    elseif self.m_battleType == BattleEnum.BattleType_SHENBING then
        return SysIDs.SHENBING_COPY

    elseif self.m_battleType == BattleEnum.BattleType_THOUSAND_MILES then
        
    elseif self.m_battleType == BattleEnum.BattleType_LIEZHUAN then
        return SysIDs.LIEZHUAN

    elseif self.m_battleType == BattleEnum.BattleType_QUNXIONGZHULU then
        return SysIDs.QUNXIONGZHULU

    elseif self.m_battleType == BattleEnum.BattleType_HORSERACE then
        return SysIDs.HORSERACE

    elseif self.m_battleType == BattleEnum.BattleType_GUILD_BOSS then
        return SysIDs.GUILD_BOSS

    elseif self.m_battleType == BattleEnum.BattleType_GUILD_WARCRAFT then
        return SysIDs.GUILD_WAR
    end

    return 0
end

function FightWarItem:UpdateLeftTimes(deltaTime)
    self.m_left_times = self.m_left_times - deltaTime
    if self.m_left_times <= 0 then
        self.m_left_times = 0
        self.m_infoText.text = Language.GetString(1714)
        UIManagerInst:Broadcast(UIMessageNames.MN_FIGHTWAR_UPDATE_LEFT_TIME, false)
        return
    end
    local showTime = math_ceil(self.m_left_times - deltaTime)

    local minute = math_floor(showTime / 60)
    local second = math_floor(showTime - minute * 60)
    local strTime = minute == 0 and string_format(Language.GetString(3584), second) or string_format(Language.GetString(3585), minute, second)

    self.m_infoText.text = string_format(Language.GetString(1713), strTime)
end

return FightWarItem