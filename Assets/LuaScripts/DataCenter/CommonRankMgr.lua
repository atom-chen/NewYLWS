
local ConfigUtil = ConfigUtil
local CommonRankMgr = BaseClass("CommonRankMgr")
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort
local CommonDefine = CommonDefine
local BattleEnum = BattleEnum
local OneCommonRankData = require("DataCenter.CommonRankData.OneCommonRankData")
local WuJiangDetailData = require("DataCenter.WuJiangData.WuJiangDetailData")
local UserBrief = require("DataCenter.UserData.UserBrief")
local ShenBingDetailData = require("DataCenter.ShenBingData.ShenBingDetailData")
local MountData = require("DataCenter/MountData/MountData")
local copyNumList = table.copyNumList 

function CommonRankMgr:__init()
    self.m_rankCache = {}    --  ranktype -> { update_time=, my_rank=onerank, rank_list=onerank[] }

    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.COMMONRANK_RSP_RANK, Bind(self, self.RspRank))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.COMMONRANK_RSP_ONE_RANK_BUZHEN, Bind(self, self.RspRankBuzhen))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.COMMONRANK_RSP_WUJIANG_RANK_WUJIANG_DETAIL, Bind(self, self.RspWuJiangRankDetail)) 
end

function CommonRankMgr:ReqRank(ranktype, wujiangIndex)
    local msg_id = MsgIDDefine.COMMONRANK_REQ_RANK
    local msg = (MsgIDMap[msg_id])()
    msg.rank_type = ranktype
    msg.param1 = wujiangIndex or 0
   
    local rankCache = self.m_rankCache[ranktype]
    if rankCache then
        msg.update_time = rankCache.update_time or 1
    else
        msg.update_time = 1
    end
    
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function CommonRankMgr:RspRank(msg_obj)
    if not msg_obj or not msg_obj.result == 0 then
        return
    end

    local ranktype = msg_obj.rank_type
    local rankCache = self.m_rankCache[ranktype]
    if rankCache then
        local isWuJiangRank = (rank_type - rank_type % 100000) == 100000
        if rankCache.update_time ~= msg_obj.update_time or isWuJiangRank then
            rankCache.update_time = msg_obj.update_time
            rankCache.my_rank = OneCommonRankData.New()
            rankCache.my_rank:SetFromPB(msg_obj.my_rank)
            rankCache.rank_list = {}

            for _, pb_onerank in ipairs(msg_obj.rank_list) do
                local onerank = OneCommonRankData.New()
                onerank:SetFromPB(pb_onerank)
                table_insert(rankCache.rank_list, onerank)
            end
        end
    else
        local l = { 
            update_time = msg_obj.update_time,
            my_rank = OneCommonRankData.New(), 
            rank_list = {} 
        }
        l.my_rank:SetFromPB(msg_obj.my_rank) 
        for _, pb_onerank in ipairs(msg_obj.rank_list) do 
            local onerank = OneCommonRankData.New()
            onerank:SetFromPB(pb_onerank)
            table_insert(l.rank_list, onerank)
        end
        
        self.m_rankCache[ranktype] = l
    end

    UIManagerInst:Broadcast(UIMessageNames.MN_COMMONRANK_INFO, ranktype)
end

function CommonRankMgr:GetRankCache(ranktype)
    return self.m_rankCache[ranktype]
end

function CommonRankMgr:GetMyCommonRank(ranktype)
    local cache = self.m_rankCache[ranktype]
    if cache then
        if cache.my_rank.rank > 0 then
            local r = cache.rank_list[cache.my_rank.rank]
            return r
        else
            return cache.my_rank
        end
    end

    return nil
end

function CommonRankMgr:GetGroupHerosWarRank(ranktype)
    local cache = self.m_rankCache[ranktype]
    if cache then
        if cache.my_rank.rank > 0 then 
            local r = cache.rank_list[cache.my_rank.rank]
            if r then
                return r
            end
            return cache.my_rank
        end
        return cache.my_rank
    end

    return nil
end

function CommonRankMgr:ReqRankBuzhen(ranktype, rank)
    if self.m_queringBuzhen then
        return
    end 
    self.m_queringBuzhen = true

    local msg_id = MsgIDDefine.COMMONRANK_REQ_ONE_RANK_BUZHEN
    local msg = (MsgIDMap[msg_id])()
    msg.rank_type = ranktype
    msg.rank = rank    
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function CommonRankMgr:RspRankBuzhen(msg_obj)
    self.m_queringBuzhen = false 
    if not msg_obj or not msg_obj.result == 0 then
        return
    end 
    local wujiang_list = {} 
    for _, v in ipairs(msg_obj.wujiang_list) do
        if v.id > 0 then
            local wujiangBrief = PBUtil.ConvertWujiangBriefProtoToData(v)
            table_insert(wujiang_list, wujiangBrief)
        end
    end
    UIManagerInst:Broadcast(UIMessageNames.MN_COMMONRANK_REQ_BUZHEN, wujiang_list) 
end

function CommonRankMgr:SetQueringBuZhen(quering)
    self.m_queringBuzhen = quering
end

function CommonRankMgr:ReqWuJiangRankDetail(rank, ranktype) 
    local msg_id = MsgIDDefine.COMMONRANK_REQ_WUJIANG_RANK_WUJIANG_DETAIL
    local msg = (MsgIDMap[msg_id])() 
    msg.rank = rank    
    msg.rank_type = ranktype
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function CommonRankMgr:RspWuJiangRankDetail(msg_obj) 
    if not msg_obj then
        return
    end 
    
    if msg_obj.result == 0 then
        local panelData = self:ConvertToWuJiangDetailData(msg_obj.wujiang_detail)
        if panelData then
            UIManagerInst:OpenWindow(UIWindowNames.UIWuJiangAttr, panelData)
        end 
    end
end

function CommonRankMgr:ConvertToWuJiangDetailData(wujiang_detail)
    local tempWJDetailData = nil
    local tempUserBrief = nil
    local tempShenBingDetailData = nil
    if wujiang_detail then
        tempWJDetailData = WuJiangDetailData.New()    
        tempUserBrief = UserBrief.New() 

        local wujiangInfo = wujiang_detail.wujiang_info
        local userbriefInfo = wujiang_detail.user_brief_info
        local shenbingInfo = wujiang_detail.shenbing_info 
        local mountInfo = wujiang_detail.horse_info

        tempWJDetailData.id = wujiangInfo.wujiang_id or 0
        tempWJDetailData.level = wujiangInfo.wujiang_level or 0
        tempWJDetailData.star = wujiangInfo.wujiang_star or 0
        tempWJDetailData.index = wujiangInfo.wujiang_index or 0
        tempWJDetailData.power = wujiangInfo.wujiang_power or 0 
        if wujiangInfo.skill_list then
            tempWJDetailData.skill_list = {}
            for i, v in ipairs(wujiangInfo.skill_list) do
                if v then
                    local skillData = self:ToSkillData(v)
                    table_insert(tempWJDetailData.skill_list, skillData)
                end
            end
        end 
        tempWJDetailData.tupo =  self:GetTuPo(tempWJDetailData) or 0 

        local sbData = wujiangInfo.shenbing_index  
        tempShenBingDetailData = self:ParseToShenBingDetailData(shenbingInfo)
        if tempShenBingDetailData then
            tempWJDetailData.weaponLevel = tempShenBingDetailData.stage
        else
            tempWJDetailData.weaponLevel = 1
        end

        tempWJDetailData.base_second_attr = self:ConvertToSecondAttrData(wujiang_detail.base_second_attr)
        tempWJDetailData.extra_second_attr = self:ConvertToSecondAttrData(wujiang_detail.extra_second_attr)

        local inscriptions_detail_info  = wujiangInfo.inscriptions_info
        tempWJDetailData.inscription_list = {}
        if inscriptions_detail_info then 
            local id_list = inscriptions_detail_info.inscription_id_list
            for i = 1, #id_list do 
                tempWJDetailData.inscription_list[i] = id_list[i]
            end 
        end   
        PBUtil.ConvertUserBriefProtoToData(userbriefInfo, tempUserBrief)

        local tempMountData = self:ToMountData(mountInfo)

        local finalWuJiangDetail = {
            wujiangDetailData = tempWJDetailData,
            sbDetailData = tempShenBingDetailData,
            userBriefData = tempUserBrief,
            mountData = tempMountData,
        }
        return finalWuJiangDetail
    end
end  

function CommonRankMgr:ToMountData(one_horse)
    if one_horse then
        local data = MountData.New()
        data.m_index = one_horse.index
        data.m_id = one_horse.id
        data.m_stage = one_horse.stage
        data.m_max_stage = one_horse.max_stage
        data.m_base_first_attr = self:ToFirstAttrData(one_horse.base_first_attr)
        data.m_equiped_wujiang_index = one_horse.equiped_wujiang_index
        data.m_isLocked = one_horse.locked
        data.m_extra_first_attr = self:ToFirstAttrData(one_horse.extra_first_attr)
        return data
    end
end

function CommonRankMgr:ToFirstAttrData(first_attr)
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

function CommonRankMgr:ParseToShenBingDetailData(one_shenbing)
    local data = ShenBingDetailData.New()
    data.id = one_shenbing.id
    data.stage = one_shenbing.stage
    data.attr_list = self:ConvertToSecondAttrData(one_shenbing.attr_list)
    data.mingwen_list = self:ConvertToMingWenData(one_shenbing.mingwen_list)
    data.break_times = one_shenbing.break_times
    return data
end

function CommonRankMgr:ConvertToSecondAttrData(second_attr)
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

function CommonRankMgr:ConvertToMingWenData(mingwen_list)
    local dataList = {}
    for _, one_mingwen in ipairs(mingwen_list) do
        local data = {
            mingwen_id = one_mingwen.mingwen_id,
            wash_times = one_mingwen.wash_times,
        }
        table_insert(dataList, data)
    end
    return dataList
end

function CommonRankMgr:GetTuPo(wujiangData) 
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

function CommonRankMgr:ToSkillData(one_wujiang_skill)
    if one_wujiang_skill then
        local data = {
            id = one_wujiang_skill.skill_id,
            skillLevel = one_wujiang_skill.skill_level,
        }
        return data 
    end
end

function CommonRankMgr:GetBuzhenIDByRanktype(ranktype)
    local battleType = 0
    if ranktype == CommonDefine.COMMONRANK_WORLDBOSS_YESTODAY or ranktype == CommonDefine.COMMONRANK_WORLDBOSS_TODAY then
        battleType = Player:GetInstance():GetBossMgr():GetTodayBattleType()
    elseif ranktype == CommonDefine.COMMONRANK_ARENA then
        battleType = BattleEnum.BattleType_ARENA
    elseif ranktype == CommonDefine.COMMONRANK_CAMPS then
        battleType = BattleEnum.BattleType_CAMPSRUSH
    elseif ranktype == CommonDefine.COMMONRANK_INSCRIPTIONCOPY then
        battleType = BattleEnum.BattleType_INSCRIPTION
    elseif ranktype == CommonDefine.COMMONRANK_GRAVECOPY then
        battleType = BattleEnum.BattleType_GRAVE
    elseif ranktype == CommonDefine.COMMONRANK_YUANMEN then
        battleType = BattleEnum.BattleType_YUANMEN
    end

    local buzhenID = Utils.GetBuZhenIDByBattleType(battleType)
    return buzhenID
end

return CommonRankMgr