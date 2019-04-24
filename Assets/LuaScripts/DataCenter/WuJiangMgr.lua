
local WujiangDataClass = require("DataCenter.WuJiangData.WuJiangData")
local WujiangBriefClass = require("DataCenter.WuJiangData.WuJiangBrief")
local WuJiangDetailData = require("DataCenter.WuJiangData.WuJiangDetailData")
local UserBrief = require("DataCenter.UserData.UserBrief")
local WuJiangManager = BaseClass("WuJiangManager")
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort
local math_ceil = math.ceil
local CountryTypeDefine = CountryTypeDefine
local CommonDefine = CommonDefine 
local OneCommonRankData = require("DataCenter.CommonRankData.OneCommonRankData")
local copyNumList = table.copyNumList   
 
function WuJiangManager:__init()
    self.m_wujiangDict = {}

    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_NTF_EXP_CHG, Bind(self, self.NtfWujiangExpChg))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_NTF_WUJIANG_CHG, Bind(self, self.NtfWUjiangChg))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_NTF_REMOVE_WUJIANG, Bind(self, self.NtfRemoveWuJiang))
    
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_RSP_WUJIANG_LEVELUP, Bind(self, self.RspLevelUp))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_RSP_WUJIANG_STAR_LEVELUP, Bind(self, self.RspStarLevelUp))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_RSP_WUJIANG_SKILL_LEVELUP, Bind(self, self.RspSkillLevelUp))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_RSP_WUJIANG_POWER_RANK, Bind(self, self.RspPowerRank))  
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_RSP_EQUIP_SHENBING, Bind(self, self.RspEquipShenBing))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_RSP_UNEQUIP_SHENBING, Bind(self, self.RspUnEquipShenBing))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_RSP_SHENBING_IMPROVE_STAGE, Bind(self, self.RspShenBingImprove))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_RSP_SHENBING_REBUILD, Bind(self, self.RspShenBingRebuild))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_RSP_CONFIRM_SHENBING_REBUILD, Bind(self, self.RspConfirmShenBingRebuild))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_RSP_IMPROVE_INTIMACY, Bind(self, self.RspImproveIntimacy)) 
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_NTF_INTIMACY_CHG , Bind(self, self.NtfIntimacyChg))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_RSP_LOCK, Bind(self, self.RspLock))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_RSP_WUJIANG_SECOND_ATTR_INFO, Bind(self, self.RspWuJiangSecondAttrInfo))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_RSP_WUJIANG_MERGE, Bind(self, self.RspWujiangMerge))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_NTF_WUJIANG_POWER_CHG, Bind(self, self.NtfWujiangPowerChg))
     

    self.m_reqWuJiangData = {
        index = 0, 
        level = 0
    } 

    self.CurrWuJiangIndex = 0

    self.CurrCountrySortType = CountryTypeDefine[1]
    self.CurSortPriority = 1                            --1星级2等级3突破次数4稀有度 

    self:SetQingYuanGiftItemCfg()

    self.m_curWuJiangChgData = {
        index = 0,
        second_attr_chg = nil,
        skill_chg = false
    }
end

function WuJiangManager:Dispose()
    self.m_wujiangDict = {}
end

function WuJiangManager:OperateWuJiangList(rsp_wujiang_list)
    if not rsp_wujiang_list then
        return
    end

    self.m_wujiangDict = {}

    for i, v in ipairs(rsp_wujiang_list) do
        if v then 
            self.m_wujiangDict[v.wujiang_index] = self:ToWuJiangData(v)
        end
    end

    self:SetWuJiangRedPointStatus()
end

function WuJiangManager:GetWuJiangDict()
    return self.m_wujiangDict
end

function WuJiangManager:ToWuJiangData(one_wujiang, data)
    if one_wujiang then
        if not data then
            data = WujiangDataClass.New()
        end
        data.index = one_wujiang.wujiang_index
        data.id = math_ceil(one_wujiang.wujiang_id)
        data.star = one_wujiang.wujiang_star
        data.level = one_wujiang.wujiang_level
        data.exp = one_wujiang.wujiang_exp
        data.shenbing_idx = one_wujiang.shenbing_index
        data.horse_index = one_wujiang.horse_index

        local shenbingData = Player:GetInstance():GetShenBingMgr():GetShenBingDataByIndex(data.shenbing_idx)
        if shenbingData then
            data.weaponLevel = shenbingData:GetStage()
        else
            data.weaponLevel = 1
        end

        if one_wujiang.skill_list then
            data.skill_list = {}
            for i, v in ipairs(one_wujiang.skill_list) do
                if v then
                    local skillData = self:ToSkillData(v)
                    table_insert(data.skill_list, skillData)
                end
            end
        end

        data.tupo = self:GetTuPo(data)
        
        data.power = one_wujiang.wujiang_power
        data.inscriptions_detail_info = Player:GetInstance().InscriptionMgr:ToInscriptionsDetailData(one_wujiang.inscriptions_info)

        data.show_first_attr = self:ToFirstAttrData(one_wujiang.show_first_attr)
        data.extra_first_attr = self:ToFirstAttrData(one_wujiang.extra_first_attr)
        data.locked = one_wujiang.locked

        return data
    end
end

function WuJiangManager:ToWuJiangSecondAttrData(wujiangData, base_second_attr, extra_second_attr)
    if wujiangData then
        wujiangData.base_second_attr = self:ToSecondAttrData(base_second_attr)
        wujiangData.extra_second_attr = self:ToSecondAttrData(extra_second_attr)
    end
end

function WuJiangManager:GetOwnInscriptionIDList(wujiangIndex)
    local wujiangData = self.m_wujiangDict[wujiangIndex]
    if wujiangData then
        local inscriptions_detail_info  = wujiangData.inscriptions_detail_info
        if inscriptions_detail_info then
            return inscriptions_detail_info.inscription_id_list
        end
    end
end


function WuJiangManager:ToSkillData(one_wujiang_skill)
    if one_wujiang_skill then
        local data = {
            id = one_wujiang_skill.skill_id,
            skillLevel = one_wujiang_skill.skill_level,
        }
        return data 
    end
end

function WuJiangManager:ToSecondAttrData(second_attr)
    if second_attr then
        local data = {
            max_hp = second_attr.max_hp,	--血量上限
            phy_atk = second_attr.phy_atk,	--物攻
            phy_def = second_attr.phy_def,	--物防
            magic_atk = second_attr.magic_atk,--法攻
            magic_def = second_attr.magic_def,--法防
            phy_baoji = second_attr.phy_baoji,--物理爆击
            magic_baoji = second_attr.magic_baoji,--法术爆击
            shanbi = second_attr.shanbi,--闪避
            mingzhong = second_attr.mingzhong,--命中
            move_speed = second_attr.move_speed,--移动速度
            atk_speed = second_attr.atk_speed,--攻击速度
            hp_recover = second_attr.hp_recover,--生命回复
            nuqi_recover = second_attr.nuqi_recover,--怒气回复
            init_nuqi = second_attr.init_nuqi,--初始怒气
            baoji_hurt = second_attr.baoji_hurt,--暴击伤害
            phy_suckblood = second_attr.phy_suckblood,--物理吸血
            magic_suckblood = second_attr.magic_suckblood,--法术吸血
            reduce_cd = second_attr.reduce_cd--减免CD
        }
        return data 
    end
end

function WuJiangManager:ToFirstAttrData(first_attr)
    if first_attr then
        local data = {
            tongshuai = first_attr.tongshuai,	
            wuli = first_attr.wuli,	
            zhili = first_attr.zhili,	
            fangyu = first_attr.fangyu
        }
        return data 
    end
end

function WuJiangManager:GetWuJiangData(wujiangIndex, filter)
    if wujiangIndex == nil and filter then
        for k, v in pairs(self.m_wujiangDict) do
            if v then
                local wujiangCfg = ConfigUtil.GetWujiangCfgByID(v.id)
                if wujiangCfg then
                    if filter(v, wujiangCfg) then
                        return v
                    end
                end
            end
        end
    end

    return self.m_wujiangDict[wujiangIndex]
end

function WuJiangManager:WujiangDataToBrief(wujiangData)
    local o = WujiangBriefClass.New()
    o.id = wujiangData.id
    o.level = wujiangData.level
    o.star = wujiangData.star
    o.index = wujiangData.index
    o.power = wujiangData.power
    o.tupo = wujiangData.tupo
    o.weaponLevel = wujiangData.weaponLevel
    o.isLock = wujiangData.locked
    o.m_redPointStatus = false

    local mountData = Player:GetInstance():GetMountMgr():GetDataByIndex(wujiangData.horse_index)
    if mountData then
        o.mountID = mountData:GetItemID()
        o.mountLevel = mountData:GetStage()
    end      
    
    return o
end

function WuJiangManager:GetWuJiangBriefData(wujiangIndex)
    local wujiangData = self:GetWuJiangData(wujiangIndex)
    if wujiangData then
        return self:WujiangDataToBrief(wujiangData)
    end
end

function WuJiangManager:GetWuJiangList(filter)
    local wujiangList = {}

    for k, v in pairs(self.m_wujiangDict) do
        if v then
            local wujiangCfg = ConfigUtil.GetWujiangCfgByID(v.id)
            if wujiangCfg then
                if filter then
                    if filter(v, wujiangCfg) then
                        table_insert(wujiangList, v)
                    end
                else
                    table_insert(wujiangList, v)
                end
            end
        end
    end

    return wujiangList
end

function WuJiangManager:ConvertToWuJiangBriefList(wujiangDataList)
    local wujiangBriefList = {}
    local shenbingMgr = Player:GetInstance():GetShenBingMgr()
    local IdDic = shenbingMgr:GetShenBingWuJiangIdDic() 

    for k, v in pairs(wujiangDataList) do
        local wujiangBriefData = self:WujiangDataToBrief(v)
        if v.shenbing_idx <= 0 then
            if IdDic[wujiangBriefData.id] and IdDic[wujiangBriefData.id] > 0 then
                wujiangBriefData.m_redPointStatus = true 
            end
        end 
        table_insert(wujiangBriefList, wujiangBriefData)
    end

    return wujiangBriefList
end

function WuJiangManager:GetWujiangCount(filter)
    local wujiangList = self:GetWuJiangList(filter)
    return #wujiangList
end

-- 根据排序规则获取武将列表
function WuJiangManager:GetSortWuJiangList(priority, filter)

    priority = priority or 1

    if priority <= 0 or priority > 4 then
        Logger.LogError("GetSortWuJiangList priority error")
        return
    end

    local wujiangList = {}
   
    for k, v in pairs(self.m_wujiangDict) do
        if v then
            local wujiangCfg = ConfigUtil.GetWujiangCfgByID(v.id)
            if wujiangCfg then
                if filter then
                    if filter(v, wujiangCfg) then
                        v.sortNum = self:GetSortNum(v, priority)
                        table_insert(wujiangList, v)
                    end
                else
                    v.sortNum = self:GetSortNum(v, priority)
                    table_insert(wujiangList, v)
                end
            end
        end
    end

    table_sort(wujiangList, function(l, r)
        if l.sortNum ~= r.sortNum then
            return l.sortNum > r.sortNum
        end

        if l.id ~= r.id then
            return l.id < r.id
        end
        
		return l.index < l.index
    end)
    
    return wujiangList
end

function WuJiangManager:GetSortNum(wujiangData, priority)
    --排序规则，按优先级
    --优先级 星级＞等级＞突破次数＞稀有度＞id  
    --priority 1星级2等级3突破次数4稀有度
    --星级1位数 等级3位 突破次数 2位 稀有度1位

    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(wujiangData.id)
    if wujiangCfg then
        if priority == 1 then
            return wujiangData.star * 1000000 + wujiangData.level * 1000 + wujiangData.tupo * 10 + wujiangCfg.rare
        elseif priority == 2 then
            return wujiangData.level * 10000 + wujiangData.star * 1000 + wujiangData.tupo * 10 + wujiangCfg.rare
        elseif priority == 3 then
            return wujiangData.tupo * 100000 + wujiangData.star * 10000 + wujiangData.level * 10 + wujiangCfg.rare
        elseif priority == 4 then
            return wujiangCfg.rare * 1000000 + wujiangData.star * 100000 + wujiangData.level * 100 + wujiangData.tupo 
        end
    end 

    return 0
end

--去掉星级的排序
function WuJiangManager:GetSortNum2(wujiangData, priority)
    --排序规则，按优先级
    --优先级 星级＞等级＞突破次数＞稀有度＞id  
    --priority 1星级2等级3突破次数4稀有度
    --星级1位数 等级3位 突破次数 2位 稀有度1位

    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(wujiangData.id)
    if wujiangCfg then
        if priority == 2 then
            return wujiangData.level * 1000 + wujiangData.tupo * 10 + wujiangCfg.rare
        elseif priority == 3 then
            return wujiangData.tupo * 1000 + wujiangData.level * 10 + wujiangCfg.rare
        elseif priority == 4 then
            return wujiangCfg.rare * 100000  + wujiangData.level * 100 + wujiangData.tupo 
        end
    end 

    return 0
end

function WuJiangManager:GetTuPo(wujiangData)
    --不同稀有度，技能突破上限不同  分别为 6 6 4 2
    -- SSR 3个技能 * 6 - 技能数
    local tupo = 0
    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(wujiangData.id)
   
    if wujiangCfg then
        local skill_list = wujiangData.skill_list
        
        if skill_list then
            for i = 1, #skill_list do
                tupo = tupo + skill_list[i].skillLevel - 1
            end
        end   
    end
    
    return tupo
end

function WuJiangManager:NtfWujiangExpChg(msg_obj)
    local exp_chg_list = msg_obj.exp_chg_list
    for _, v in ipairs(exp_chg_list) do
        local oldWuJiangData = self.m_wujiangDict[v.wujiang_index]
        if oldWuJiangData then
            oldWuJiangData.exp = v.exp
            oldWuJiangData.level = v.level
            UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_EXP_CHG)
        end
    end 
end

function WuJiangManager:ToOneWujiangPower(one_wujiang_power, data)
    if one_wujiang_power then
        local data = data or {}
        data.wujiang_index = one_wujiang_power.wujiang_index
        data.power = one_wujiang_power.power
        return data
    end
end

function WuJiangManager:NtfWujiangPowerChg(msg_obj)
    if msg_obj then
        local wujiangList = PBUtil.ToParseList(msg_obj.wujiang_list, Bind(self, self.ToOneWujiangPower))
        if wujiangList then
            for _, oneWujiang in ipairs(wujiangList) do
                local oldWuJiangData = self.m_wujiangDict[oneWujiang.wujiang_index]
                if oneWujiang.power ~= oldWuJiangData.power then
                    self.m_wujiangDict[oneWujiang.wujiang_index].power = oneWujiang.power
                end
            end
        end
    end
end

function WuJiangManager:NtfWUjiangChg(msg_obj)    
    if msg_obj then
        local wujiang_info = msg_obj.wujiang_info
        local reason = msg_obj.reason
        if wujiang_info then  
            local oldWuJiangData = self.m_wujiangDict[wujiang_info.wujiang_index]
            if oldWuJiangData then
                --战力变化
                if wujiang_info.wujiang_power ~= oldWuJiangData.power then
                    UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_POWER_CHG, wujiang_info.wujiang_power - oldWuJiangData.power, wujiang_info.wujiang_index)
                end

                if oldWuJiangData.exp ~= wujiang_info.wujiang_exp then
                    --先消耗道具，再更新经验
                    UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_EXP_CHG)
                end
            end 
             --更新前
            if reason > 0 then

                if self.m_curWuJiangChgData.index == wujiang_info.wujiang_index then
                    self.m_curWuJiangChgData.skill_chg = self:GetSkillChg(wujiang_info, oldWuJiangData) 
                end
            end 
            self.m_wujiangDict[wujiang_info.wujiang_index] = self:ToWuJiangData(wujiang_info, oldWuJiangData) 

            --更新后
            if reason > 0 then
                if reason == 2 then --命签
                    UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_INSCRIPTION_CHG)
                end  
            end 
        end 
         
        if reason == 6 or reason == 9 then
            self:SetWuJiangRedPointStatus()
        end 
    end
end

function WuJiangManager:SetWuJiangRedPointStatus()  
    local status = false
    local shenbingMgr = Player:GetInstance():GetShenBingMgr()
    local shenBingCount = shenbingMgr:GetTotalCount()
    if shenBingCount > 0 then
        status = true
    end  

    if status then 
        status = false
        local IdDic = shenbingMgr:GetShenBingWuJiangIdDic()

        for k, v in pairs(self.m_wujiangDict) do 
            if v.shenbing_idx <= 0 then  
                if IdDic[v.id] and IdDic[v.id] > 0 then
                    status = true
                    break
                end 
            end
        end
    end

    local userMgr = Player:GetInstance():GetUserMgr()
    if not status then 
        userMgr:DeleteRedPointID(SysIDs.ROLE_BAG) 
    else
        userMgr:AddRedPointId(SysIDs.ROLE_BAG)
    end
    UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_ICON_REFRESH_RED_POINT)
end 

function WuJiangManager:NtfRemoveWuJiang(msg_obj)
    if msg_obj then
        local wujiang_index_list = msg_obj.wujiang_index_list
        if wujiang_index_list then
            for i = 1, #wujiang_index_list do
                local index = wujiang_index_list[i]
                self.m_wujiangDict[index] = nil
            end
        end
    end

    self:SetWuJiangRedPointStatus()
end

function WuJiangManager:CheckWuJiangChg(wujiang_info, wujiangData)
    if wujiangData then
        --local extra_second_attr_chg = self:GetSecondAttrChg(wujiang_info.base_second_attr, wujiangData.base_second_attr)
        local skillChgList = self:GetSkillChg(wujiang_info, wujiangData)
        local wujiangChgData = {
            index = wujiangData.index,
            extra_second_attr_chg = extra_second_attr_chg,
            skill_chg = skillChgList
        }

        return wujiangChgData
    end
end

function WuJiangManager:GetSecondAttrChg(new_second_attr, old_second_attr)
    if new_second_attr and old_second_attr then
        local data = {
            max_hp =  new_second_attr.max_hp - old_second_attr.max_hp,
            phy_atk = new_second_attr.phy_atk - old_second_attr.phy_atk,
            phy_def = new_second_attr.phy_def - old_second_attr.phy_def,
            magic_atk = new_second_attr.magic_atk - old_second_attr.magic_atk,
            magic_def = new_second_attr.magic_def - old_second_attr.magic_def,
            phy_baoji = new_second_attr.phy_baoji - old_second_attr.phy_baoji,
            magic_baoji = new_second_attr.magic_baoji - old_second_attr.magic_baoji,
            shanbi = new_second_attr.shanbi - old_second_attr.shanbi,
            mingzhong = new_second_attr.mingzhong - old_second_attr.mingzhong,
            move_speed = new_second_attr.move_speed - old_second_attr.move_speed,
            atk_speed = new_second_attr.atk_speed - old_second_attr.atk_speed,
            hp_recover = new_second_attr.hp_recover - old_second_attr.hp_recover,
            nuqi_recover = new_second_attr.nuqi_recover - old_second_attr.nuqi_recover,
            init_nuqi = new_second_attr.init_nuqi - old_second_attr.init_nuqi,
            baoji_hurt = new_second_attr.baoji_hurt - old_second_attr.baoji_hurt,
            phy_suckblood = new_second_attr.phy_suckblood - old_second_attr.phy_suckblood,
            magic_suckblood = new_second_attr.magic_suckblood - old_second_attr.magic_suckblood,
            reduce_cd = new_second_attr.reduce_cd - old_second_attr.reduce_cd
        }

        return data
    end
end

function WuJiangManager:GetSkillChg(wujiang_info, wujiangData)
    local skillChgList = { }
    if wujiang_info.skill_list and wujiangData.skill_list then
        for i, v in ipairs(wujiang_info.skill_list) do
            local newSkillData = wujiang_info.skill_list[i]
            if newSkillData then

                for j = 1, #wujiangData.skill_list do
                    local oldSkillData = wujiangData.skill_list[j]
                    if oldSkillData.id == newSkillData.skill_id then
                        if oldSkillData.skillLevel ~= newSkillData.skill_level then

                            table_insert(skillChgList, {
                                skillID = oldSkillData.id,
                                oldLevel = oldSkillData.skillLevel,
                                newLevel = newSkillData.skill_level
                            })
                        end
                        break
                    end
                end
                
            end
        end
    end
    
    return skillChgList
end

--神兵

function WuJiangManager:ReqEquipShenBing(shenbing_index, wujiang_index)
    local msg_id = MsgIDDefine.WUJIANG_REQ_EQUIP_SHENBING
    local msg = (MsgIDMap[msg_id])()
    msg.shenbing_index = shenbing_index
    msg.wujiang_index = wujiang_index
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function WuJiangManager:RspEquipShenBing(msg_obj)
    if msg_obj.result == 0 then
        UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_RSP_EQUIP_SHENBING)
        AudioMgr:PlayAudio(109)
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHENBING_OPERATION_FINISH, 'Equip')
    end
end

function WuJiangManager:ReqUnEquipShenBing(shenbing_index, wujiang_index)
    local msg_id = MsgIDDefine.WUJIANG_REQ_UNEQUIP_SHENBING
    local msg = (MsgIDMap[msg_id])()
    msg.shenbing_index = shenbing_index
    msg.wujiang_index = wujiang_index
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function WuJiangManager:RspUnEquipShenBing(msg_obj)
    if msg_obj.result == 0 then
        UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_RSP_UNEQUIP_SHENBING)
    end
end

function WuJiangManager:ReqShenBingImprove(shenbing_index)
    local msg_id = MsgIDDefine.WUJIANG_REQ_SHENBING_IMPROVE_STAGE
    local msg = (MsgIDMap[msg_id])()
    msg.shenbing_index = shenbing_index
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function WuJiangManager:RspShenBingImprove(msg_obj)
    if msg_obj.result == 0 then
        UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_RSP_SHENBING_IMPROVE_STAGE)
        AudioMgr:PlayAudio(110)
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHENBING_OPERATION_FINISH, 'Improve')
    end
end

function WuJiangManager:ReqShenBingRebuild(shenbingList, shenbingIndex)
    local msg_id = MsgIDDefine.WUJIANG_REQ_SHENBING_REBUILD
    local msg = (MsgIDMap[msg_id])()
    for i, v in ipairs(shenbingList) do
        msg.shenbing_index_list:append(v)
    end
    msg.shenbing_index = shenbingIndex
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function WuJiangManager:RspShenBingRebuild(msg_obj)
    if msg_obj.result == 0 then
        UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_RSP_SHENBING_REBUILD)
        AudioMgr:PlayAudio(111)
    end
end

function WuJiangManager:ReqConfirmShenBingRebuild(confirm, shenbing_index)
    local msg_id = MsgIDDefine.WUJIANG_REQ_CONFIRM_SHENBING_REBUILD
    local msg = (MsgIDMap[msg_id])()
    msg.confirm = confirm
    msg.shenbing_index = shenbing_index
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function WuJiangManager:RspConfirmShenBingRebuild(msg_obj)
    if msg_obj.result == 0 then
        UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_RSP_CONFIRM_SHENBING_REBUILD, msg_obj)
    end
end

--升级
function WuJiangManager:ReqLevelUp(wujiangIndex, expItem)
    local msg_id = MsgIDDefine.WUJIANG_REQ_WUJIANG_LEVELUP
    local msg = (MsgIDMap[msg_id])()
  
    msg.wujiang_index = wujiangIndex

    local one_item = msg.cost_item_list:add()
    one_item.item_id = expItem.item_id
    one_item.count = expItem.count

    self.m_reqWuJiangData.index = wujiangIndex
    local wujiangData = self.m_wujiangDict[wujiangIndex]
    if wujiangData then
        self.m_reqWuJiangData.level = wujiangData.level
    end
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function WuJiangManager:RspLevelUp(msg_obj)
    local result = msg_obj.result
    if result == 0 then
        local wujiangData = self.m_wujiangDict[self.m_reqWuJiangData.index]
        if wujiangData then
            if self.m_reqWuJiangData.level > 0 and wujiangData.level ~= self.m_reqWuJiangData.level then
                self.m_reqWuJiangData.level = 0
                UILogicUtil.FloatAlert(string.format(Language.GetString(642), wujiangData.level))
                UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_DATA_CHG, 1)
            end
        end
	end
end

--升星

function WuJiangManager:ReqStarLevelUp(wujiangIndex, wujiangIndexList)
    local msg_id = MsgIDDefine.WUJIANG_REQ_WUJIANG_STAR_LEVELUP
    local msg = (MsgIDMap[msg_id])()
    msg.wujiang_index = wujiangIndex

    for i, v in ipairs(wujiangIndexList) do
        if v then
            msg.cost_wujiang_list:append(v)
        end
    end

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function WuJiangManager:RspStarLevelUp(msg_obj)
    local result = msg_obj.result
    
	if result == 0 then
        UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_DATA_CHG, 2)
        UILogicUtil.FloatAlert(Language.GetString(643))
	end
end

--突破 
function WuJiangManager:ReqSkillLevelUp(wujiangIndex, wujiangIndexList) 
    local msg_id = MsgIDDefine.WUJIANG_REQ_WUJIANG_SKILL_LEVELUP
    local msg = (MsgIDMap[msg_id])()
    msg.wujiang_index = wujiangIndex
    for i, v in ipairs(wujiangIndexList) do
        if v then
            msg.cost_wujiang_list:append(v)
        end
    end 

    self.m_curWuJiangChgData.index = wujiangIndex

    --print("ReqSkillLevelUp wujiangIndex ", wujiangIndex)

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function WuJiangManager:RspSkillLevelUp(msg_obj)
    local result = msg_obj.result
    if result == 0 then
        
        self.m_curWuJiangChgData.second_attr_chg = self:GetSecondAttrChg(msg_obj.curr_second_attr, msg_obj.src_second_attr)

        --print("self.m_curWuJiangChgData ", table.dump(self.m_curWuJiangChgData))

        UIManagerInst:OpenWindow(UIWindowNames.UIWuJiangTupoSucc, self.m_curWuJiangChgData)

        UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_DATA_CHG, 3)
	end
end

--战力排行
function WuJiangManager:ReqPowerRank(wujiang_id)
    -- local msg_id = MsgIDDefine.WUJIANG_REQ_WUJIANG_POWER_RANK
    -- local msg = (MsgIDMap[msg_id])()
    -- msg.wujiang_id = wujiang_id
    -- HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function WuJiangManager:RspPowerRank(msg_obj)
    -- Logger.Log('RspPowerRank msg_obj: ' .. tostring(msg_obj))

    -- local result = msg_obj.result
	-- if result == 0 then
    --     if not msg_obj.ranking_list then
    --        return
    --     end
    --     local rankingList = {}

    --     for i, v in ipairs(msg_obj.ranking_list) do
    --         if v then
    --             table_insert(fewa, self:ToRankData(v))
    --         end
    --     end
    -- end 
end 

function WuJiangManager:ReqWuJiangSecondAttrInfo(wujiangIndex)
    local msg_id = MsgIDDefine.WUJIANG_REQ_WUJIANG_SECOND_ATTR_INFO
    local msg = (MsgIDMap[msg_id])()
    msg.wujiang_index = wujiangIndex
    self.m_reqWuJiangData.index = wujiangIndex
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function WuJiangManager:RspWuJiangSecondAttrInfo(msg_obj) 
    local result = msg_obj.result
	if result == 0 then
        local wujiangData = self.m_wujiangDict[self.m_reqWuJiangData.index]
        if wujiangData then
            self:ToWuJiangSecondAttrData(wujiangData, msg_obj.base_second_attr, msg_obj.extra_second_attr)
        
            local panelData = self:GetWuJiangAttrPanelData(wujiangData.index) 
            if panelData then
                UIManagerInst:OpenWindow(UIWindowNames.UIWuJiangAttr, panelData)
            end
        end
	end
end

--Prase 数据
function WuJiangManager:ToRankData(one_ranking, data)
    if one_ranking then
        data = data or {}
        data.rank = one_ranking.rank
        data.power = one_ranking.power
        data.userBriefData = PBUtil.ConvertUserBriefProtoToData(one_ranking.user_brief_info)
        return data
    end
end

function WuJiangManager:GetWuJiangAttrPanelData(index)
    local wujiangData = self.m_wujiangDict[index]
    if wujiangData then 
        local userBrief = UserBrief.New()
        userBrief.uid =  Player:GetInstance():GetUserMgr():GetUserData().uid

        local panelData = {
            wujiangDetailData = self:WuJiangDataToWuJiangDetailData(wujiangData),
            userBriefData = userBrief
        }

        local shenbingMgr = Player:GetInstance():GetShenBingMgr()
        local shenbingData = shenbingMgr:GetShenBingDataByIndex(wujiangData.shenbing_idx)
        if shenbingData then
            panelData.sbDetailData = shenbingMgr:ShenbingDataToShenbingDetailData(shenbingData) 
        end
        local mountData = Player:GetInstance():GetMountMgr():GetDataByIndex(wujiangData.horse_index)
        if mountData then
            panelData.mountData = mountData
        end

        return panelData
    end
end

function WuJiangManager:WuJiangDataToWuJiangDetailData(wujiangData, data)
    if wujiangData then
        if not data then
            data = WuJiangDetailData.New()
        end
        data.id = wujiangData.id
        data.level = wujiangData.level
        data.star = wujiangData.star
        data.power = wujiangData.power
        data.tupo = wujiangData.tupo
        data.wuqiLevel = wujiangData.wuqiLevel
        --保持引用
        data.skill_list = wujiangData.skill_list
        data.base_second_attr = wujiangData.base_second_attr
        data.extra_second_attr = wujiangData.extra_second_attr

        local inscriptions_detail_info  = wujiangData.inscriptions_detail_info
        if inscriptions_detail_info then
            data.inscription_list = copyNumList(inscriptions_detail_info.inscription_id_list)
        end
        
        return data
    end
end

--情缘/亲密度   
function WuJiangManager:SetFinalIntimacyList(list)
    self.m_finalIntimacyList = list
end

function WuJiangManager:SortMapIntimacyList(intimacy_list)
    local tempIntimacyList = {}  
    while #intimacy_list > 0 do 
        local dstIDList = {}
        local oneCurDstInfo = {}
        local curSrcId = math.floor(intimacy_list[1].src_wujiang_id)
        local curDstId = math.floor(intimacy_list[1].dst_wujiang_id)
        local curIntimacy = math.floor(intimacy_list[1].intimacy)
        local curIntimacyLevel = math.floor(intimacy_list[1].intimacy_level)
        table.remove(intimacy_list, 1)

        oneCurDstInfo = {
            dst_wujiang_id = curDstId,
            intimacy = curIntimacy,
            intimacy_level = curIntimacyLevel,
        }   
        table_insert(dstIDList, oneCurDstInfo)

        local param = 1
        while param <= #intimacy_list do
            local oneNextDstInfo = {}
            local nextSrcId = math.floor(intimacy_list[param].src_wujiang_id)
            local nextDstId = math.floor(intimacy_list[param].dst_wujiang_id)
            local nextIntimacy = math.floor(intimacy_list[param].intimacy)
            local nextIntimacyLevel = math.floor(intimacy_list[param].intimacy_level)
            oneNextDstInfo = {
                dst_wujiang_id = nextDstId,
                intimacy = nextIntimacy,
                intimacy_level = nextIntimacyLevel,
            }
            if curSrcId == nextSrcId then   
                table.remove(intimacy_list, param)
                table_insert(dstIDList, oneNextDstInfo)
            else
                param = param + 1
            end  
        end
        tempIntimacyList[curSrcId] = dstIDList
    end  
    return tempIntimacyList
end

function WuJiangManager:GetOneFinalIntimacyListBySrcID(src_id)
    return self.m_finalIntimacyList[src_id]
end 

function WuJiangManager:ModifyFinalIntimacyList(intimacy_info)
    local src_id = intimacy_info.src_wujiang_id
    local tempIntimacyInfo = {
        dst_wujiang_id = intimacy_info.dst_wujiang_id,
        intimacy = intimacy_info.intimacy,
        intimacy_level = intimacy_info.intimacy_level,
    }

    if self.m_finalIntimacyList[src_id] then
        local hasDstId = false
        for i = 1, #self.m_finalIntimacyList[src_id] do
            if self.m_finalIntimacyList[src_id][i].dst_wujiang_id == intimacy_info.dst_wujiang_id then
                self.m_finalIntimacyList[src_id][i].intimacy = intimacy_info.intimacy
                self.m_finalIntimacyList[src_id][i].intimacy_level = intimacy_info.intimacy_level  
                hasDstId = true
            end
        end
        if not hasDstId then
            table_insert(self.m_finalIntimacyList[src_id], tempIntimacyInfo)
        end
    else
        if not self.m_finalIntimacyList[src_id] then
            self.m_finalIntimacyList[src_id] = {}
        end
        table_insert(self.m_finalIntimacyList[src_id], tempIntimacyInfo)
    end 
end

function WuJiangManager:ReqImproveIntimacy(src_wujiang_id, dst_wujiang_id, item_id)
    local msg_id = MsgIDDefine.WUJIANG_REQ_IMPROVE_INTIMACY
    local msg = (MsgIDMap[msg_id])()

    msg.src_wujiang_id = src_wujiang_id
    msg.dst_wujiang_id = dst_wujiang_id
    msg.item_id = item_id
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function WuJiangManager:RspImproveIntimacy(msg_obj)
    local result = msg_obj.result
    if result == 0 then

    end
end

function WuJiangManager:NtfIntimacyChg(msg_obj)
    if not msg_obj then
        return
    end
    local reason = msg_obj.reason
    local intimacy_info = self:ConvertOneIntimacy(msg_obj.intimacy_info)
    self:ModifyFinalIntimacyList(intimacy_info)
    UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_NTF_INTIMACY_CHG)
end

function WuJiangManager:ConvertIntimacyList(intimacy_list)
    if not intimacy_list then
        return
    end
    local temp_intimacy_list = {}
    for i = 1, #intimacy_list do
        local temp_one_intimacy = self:ConvertOneIntimacy(intimacy_list[i])
        table_insert(temp_intimacy_list, temp_one_intimacy)
    end

    return temp_intimacy_list
end

function WuJiangManager:ConvertOneIntimacy(one_intimacy)
    if not one_intimacy then
        return nil
    end

    local temp_one_intimacy = {
        src_wujiang_id = one_intimacy.src_wujiang_id or 0,
        dst_wujiang_id = one_intimacy.dst_wujiang_id or 0,
        intimacy = one_intimacy.intimacy or 0,
        intimacy_level = one_intimacy.intimacy_level or 0,
    }
    return temp_one_intimacy
end

function WuJiangManager:GetLocalIntimacyCfg(src_wujiang_id)
    local localIntimacyCfg = {}
    local intimacyCfg = ConfigUtil.GetIntimacyCfgByID(src_wujiang_id)
    if not intimacyCfg then
        return
    end
    for i = 1, 4 do
        if intimacyCfg["wujiang_id"..i] > 0 then
            local oneWujiangInfo = {
                wujiang_id = intimacyCfg["wujiang_id"..i],
                wujiang_star = intimacyCfg["wujiang_star"..i],
            }
            table_insert(localIntimacyCfg, oneWujiangInfo)
        end
    end 
    return localIntimacyCfg
end

function WuJiangManager:IsWuJiangActive(src_id, dst_id)
    if not src_id or not dst_id then
        return
    end
    local oneFinalIntimacyList = self:GetOneFinalIntimacyListBySrcID(src_id)
    if not oneFinalIntimacyList then
        return false, nil
    end
    for i = 1, #oneFinalIntimacyList do
        if dst_id == oneFinalIntimacyList[i].dst_wujiang_id then
            return true, oneFinalIntimacyList[i]
        end
    end
    
    return false, nil
end  

function WuJiangManager:GetAttr(intimacy_level_cfg) 
    local attrList = CommonDefine.qingyuan_second_attr_name_list
    for index, attrName in ipairs(attrList) do
        local val = intimacy_level_cfg[attrName]
        if val > 0 then 
            return Language.GetString(index + 2540), val
        end
    end  
    return "", 0
end 

function WuJiangManager:SetQingYuanGiftItemCfg()
    local itemFuncCfg = ConfigUtil.GetIntimacyItemFuncCfg()
    self.m_qyItemFuncCfg = {}
    for i = 1, 5 do
        self.m_qyItemFuncCfg[i] = {}
    end
    for k, v in pairs(itemFuncCfg) do
        if v.func_type1 == 2 and v.param1 > 0 then 
            local oneItemInfo = {
                item_id = v.id, 
                add_value = v.func_value1,
            }
            if v.param1 == 1 then
                table_insert(self.m_qyItemFuncCfg[1], oneItemInfo)
            elseif v.param1 == 2 then
                table_insert(self.m_qyItemFuncCfg[2], oneItemInfo)
            elseif v.param1 == 3 then
                table_insert(self.m_qyItemFuncCfg[3], oneItemInfo)
            elseif v.param1 == 4 then
                table_insert(self.m_qyItemFuncCfg[4], oneItemInfo)
            elseif v.param1 == 5 then
                table_insert(self.m_qyItemFuncCfg[5], oneItemInfo)
            end 
        end
    end
end

function WuJiangManager:GetQYGiftItemCfgByJobType(job_type)
    if self.m_qyItemFuncCfg and self.m_qyItemFuncCfg[job_type] then
        return self.m_qyItemFuncCfg[job_type]
    end
end 

function WuJiangManager:SetGiftViewPanelPosX(posX)
    self.m_posX = posX
end

function WuJiangManager:GetGiftViewPanelPosX()
    return self.m_posX
end 

function WuJiangManager:ReqLock(wujiangIndex)
    local wujiangData = self:GetWuJiangData(wujiangIndex)
    if not wujiangData then
        return
    end

    local msg_id = MsgIDDefine.WUJIANG_REQ_LOCK
    local msg = (MsgIDMap[msg_id])()
    msg.wujiang_index = wujiangIndex
    msg.lock = wujiangData.locked == 1 and 0 or 1
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function WuJiangManager:RspLock(msg_obj)
    if msg_obj.result == 0 then
        local wujiangData = self:GetWuJiangData(msg_obj.wujiang_index)
        if wujiangData then
            wujiangData.locked = msg_obj.lock
            local strNum = wujiangData.locked == 1 and 708 or 709
            UILogicUtil.FloatAlert(Language.GetString(strNum))
            UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_LOCK_CHG, msg_obj.wujiang_index, msg_obj.lock)
        end
    end
end

function WuJiangManager:ReqMerge(xinwuID)
    local msg_id = MsgIDDefine.WUJIANG_REQ_WUJIANG_MERGE
    local msg = (MsgIDMap[msg_id])()
    msg.xinwu_id = xinwuID
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function WuJiangManager:RspWujiangMerge(msg_obj) 
    local result = msg_obj.result
	if result == 0 then
    
        local awardList = PBUtil.ParseAwardList(msg_obj.award_list)
            
        local uiData = {
            openType = 1,
            awardDataList = awardList
        }
        UIManagerInst:OpenWindow(UIWindowNames.UIGetAwardPanel, uiData)
    end
end

return WuJiangManager