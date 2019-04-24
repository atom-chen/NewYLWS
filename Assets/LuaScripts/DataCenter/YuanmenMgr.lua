local table_insert = table.insert
local math_floor = math.floor
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixMod = FixMath.mod
local FixSin = FixMath.sin
local FixCos = FixMath.cos
local FixFloor = FixMath.floor

local YuanmenMgr = BaseClass("YuanmenMgr") 

function YuanmenMgr:__init() 
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.YUANMEN_RSP_YUANMEN_PANNEL, Bind(self, self.RspPanel)) 
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.YUANMEN_RSP_REFRESH_YUANMEN, Bind(self, self.RspRefresh))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.YUANMEN_RSP_TAKE_PASS_SIX_AWARD, Bind(self, self.RspBoxAward))
 
     
    self.m_yuanmenList = {}
end

function YuanmenMgr:ReqPanel()
    local msg_id = MsgIDDefine.YUANMEN_REQ_YUANMEN_PANNEL
    local msg = (MsgIDMap[msg_id])()

    HallConnector:GetInstance():SendMessage(msg_id,msg)
end

function YuanmenMgr:RspPanel(msg_obj) 
    if not msg_obj then 
        return 
    end 
    local data = self:ConvertYuanmenPanelData(msg_obj)

    UIManagerInst:Broadcast(UIMessageNames.MN_YUANMEN_RSP_PANEL, data)
end 

function YuanmenMgr:ReqRefresh()
    local msg_id = MsgIDDefine.YUANMEN_REQ_REFRESH_YUANMEN
    local msg = (MsgIDMap[msg_id])()

    HallConnector:GetInstance():SendMessage(msg_id,msg)
end

function YuanmenMgr:RspRefresh(msg_obj)
    if not msg_obj then
        return 
    end 

    local data = self:ConvertYuanmenPanelData(msg_obj)
    
    UIManagerInst:Broadcast(UIMessageNames.MN_YUANMEN_RSQ_REFRESH, data)
end

function YuanmenMgr:ReqBoxAward()
    local msg_id = MsgIDDefine.YUANMEN_REQ_TAKE_PASS_SIX_AWARD
    local msg = (MsgIDMap[msg_id])() 
    
    HallConnector:GetInstance():SendMessage(msg_id,msg)
end

function YuanmenMgr:RspBoxAward(msg_obj)
    if not msg_obj then
        return 
    end 
    local result = msg_obj.result 
    UIManagerInst:Broadcast(UIMessageNames.MN_YUANMEN_RSP_BOX_AWARD, result)
end


function YuanmenMgr:GetOneYuanmenInfo(yuanmen_id)
    return self.m_yuanmenList[yuanmen_id]
end

function YuanmenMgr:ConvertYuanmenPanelData(msg_obj)
    if not msg_obj then
        return
    end
    local temp_panel_info = self:ConvertYuanmenPanelInfo(msg_obj.pannel_info)
    local temp_cfg_info = self:ConvertYuanmenCfgInfo(msg_obj.cfg_info)
    local temp_yuanmen_id_list = {}
    for i = 1, #msg_obj.yuanmen_copy_list do
        local tempOneYuanmen = self:ConvertYuanmenCopyInfo(msg_obj.yuanmen_copy_list[i])
        if tempOneYuanmen then
            self.m_yuanmenList[tempOneYuanmen.yuanmen_id] = tempOneYuanmen
            table_insert(temp_yuanmen_id_list, tempOneYuanmen.yuanmen_id)
        end 
    end

    local temp_msg_obj = {
        pannel_info = temp_panel_info,
        cfg_info = temp_cfg_info,
        yuanmen_id_list = temp_yuanmen_id_list, 
    } 
    return temp_msg_obj
end 

function YuanmenMgr:ConvertYuanmenPanelInfo(panel_info)
    if not panel_info then
        return
    end
    local temp_info = {
        time_to_next_refresh = panel_info.time_to_next_refresh or 0,
        success_battle_count = panel_info.success_battle_count or 0,
        best_score = panel_info.best_score or 0,
        world_rank = panel_info.world_rank or 0,
        take_pass_six_award = panel_info.take_pass_six_award or false,
    }
    return temp_info
end

function YuanmenMgr:ConvertYuanmenCfgInfo(cfg_info)
    if not cfg_info then
        return
    end
    local temp_info = { 
        cfg_manual_refresh_cost_yuanbao = cfg_info.cfg_manual_refresh_cost_yuanbao or 0,
        cfg_addition_award_need_pass_battle = cfg_info.cfg_addition_award_need_pass_battle or 0,
        cfg_one_battle_cost_coin = cfg_info.cfg_one_battle_cost_coin or 0, 
    }
    return temp_info
end

function YuanmenMgr:CalcMaxHP(monsterID, monster_level, monsterValuePercent, right_buff_list)  
    local monsterCfg = ConfigUtil.GetMonsterCfgByID(monsterID)
    if not monsterCfg then
        return 0
    end
    
    local maxCfg = ConfigUtil.GetMonsterMaxCfgByLevel(monster_level)
    if not maxCfg then 
        return 0
    end

    local valuePercent = FixDiv(monsterValuePercent, 1000)
    local factor = FixDiv(monsterCfg.factor_maxhp, 1000)

    local v = maxCfg.max_hp
    v = FixMul(v, factor)
    v = FixMul(v, valuePercent)

    local buffPercent = 0

    for _, buffID in ipairs(right_buff_list) do
        local buffCfg = ConfigUtil.GetYuanmenBuffCfgByID(buffID)
        if buffCfg.max_hp > 0 then
            buffPercent = FixAdd(buffPercent, buffCfg.max_hp)
        end
    end

    max_hp = FixFloor(FixMul(v, FixAdd(1, buffPercent)))
    
    return max_hp
end

function YuanmenMgr:ConvertYuanmenCopyInfo(one_yuanmen)
    if not one_yuanmen then
        return
    end

    local temp_wujiang_info_list = {}
    
    local wujiang_info_list = one_yuanmen.right_wujiang_info_list

    local left_buff_list = {}
    for _, v in ipairs(one_yuanmen.left_buff_list) do
        table_insert(left_buff_list, v)
    end
    
    local right_buff_list = {}
    for _, v in ipairs(one_yuanmen.right_buff_list) do
        table_insert(right_buff_list, v)
    end
     
    local buzhenCfg = ConfigUtil.GetYuanmenBuZhenCfgByID(one_yuanmen.yuanmen_id) 
    if buzhenCfg == nil then
        return nil
    end
    local battleRoundCfg = ConfigUtil.GetBattleRoundCfgByID(buzhenCfg.battleRound[1][1]) 
    if battleRoundCfg then 
        for i, monster in ipairs(battleRoundCfg.monsterlist) do
            local monsterID = monster[1] 
            local temp_wujiang_result = {
                monster_id = monsterID,
                nuqi = 0,
                max_hp = 0,
                hp = 0,
                max_nuqi = BattleEnum.ActorConfig_MAX_NUQI,
                monster_level = one_yuanmen.monster_level,
            } 

            temp_wujiang_result.max_hp = self:CalcMaxHP(monsterID, one_yuanmen.monster_level, battleRoundCfg.monsterValuePercent, right_buff_list)
            temp_wujiang_result.hp = temp_wujiang_result.max_hp 

            for _, v in ipairs(wujiang_info_list) do
                if v.monster_id == monsterID then
                    temp_wujiang_result.hp = v.hp
                    temp_wujiang_result.nuqi = v.nuqi
                    break
                end
            end

            table_insert(temp_wujiang_info_list, temp_wujiang_result)
        end
    end

    local temp_one_yuanmen = {
        yuanmen_id = one_yuanmen.yuanmen_id,
        star_level = one_yuanmen.star_level,
        monster_level = one_yuanmen.monster_level,
        left_buff_list = left_buff_list,
        right_buff_list = right_buff_list,
        right_wujiang_info_list = temp_wujiang_info_list,
        passed = one_yuanmen.passed,
        score = one_yuanmen.score,
    }    

    return temp_one_yuanmen
end 

function YuanmenMgr:ConvertBoxAwardInfo(msg)
    if not msg then
        return
    end
    -- local temp_award_info_list = {}

    -- for i = 1, #msg then
    --     if msg[i] then
    --         local award_info = msg[i]
    --         local one_item = award_info.award_item
    --         local temp_one_item = {
    --             item_id = one_item.item_id or 0,
    --             count = one_item.count or 0,
    --             locked = one_item.locked or 0,
    --         }
    --         local award_wujiang = award_info.award_wujiang
    --         local temp_award_wujiang = {
    --             skill_id = award_wujiang.skill_id or 0,
    --             skill_level = award_wujiang.skill_level,
    --         }


    --         local temp_award_info = {
    --             award_type = award_info.award_type,
    --             award_item = temp_one_item,
                
    --         }
           


    --         table_insert(temp_award_info_list, temp_award_info)
    --     end
    -- end


end

function YuanmenMgr:GetEvaluationSpritePath(score)
    if not score then return "" end 
    if score >= 4500 then
         return "queshen5.png"
    elseif score >= 4000 then
        return "queshen4.png"
    elseif score >= 3000 then
        return "queshen3.png"
    elseif score >= 2000 then
        return "queshen2.png"
    else
        return "queshen1.png"
    end 
end 
 
function YuanmenMgr:GetWujiangCfgByMonsterID(monster_id)
    local monsterCfg = ConfigUtil.GetMonsterCfgByID(monster_id)
    if monsterCfg then
        local wujiangCfg = ConfigUtil.GetWujiangCfgByID(monsterCfg.role_id) 
        return wujiangCfg
    end
    return nil    
end



return YuanmenMgr