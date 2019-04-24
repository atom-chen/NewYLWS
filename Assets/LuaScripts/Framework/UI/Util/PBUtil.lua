local table_insert = table.insert
local CommonDefine = CommonDefine

PBUtil = {
    ConvertFrameDataArrayToProto = function(frameDataProtoArray, frameDataArray)
        for _,frameData in pairs(frameDataArray) do
            if frameData then
                local frameDataProto = frameDataProtoArray:add()
                frameDataProto.frame_id = frameData.frame_id
                frameDataProto.event_type = frameData.event_type
                PBUtil.ConvertSummonDataToProto(frameDataProto.summon_data, frameData.summonData)
                PBUtil.ConvertSkillDataToProto(frameDataProto.skill_data, frameData.skillData)
                PBUtil.ConvertPostionDataToProto(frameDataProto.pos_data, frameData.positionData)
                PBUtil.ConvertRotationDataToProto(frameDataProto.rotation_data, frameData.rotationData)
                PBUtil.ConvertWujiangAttrDataToProto(frameDataProto.attr_data, frameData.wujiangAttrData)
                PBUtil.ConvertHPDataToProto(frameDataProto.hp_data, frameData.hpData)
                PBUtil.ConvertJudgeDataToProto(frameDataProto.judge_data, frameData.judgeData)
                PBUtil.ConvertNuqiDataToProto(frameDataProto.nuqi_data, frameData.nuqiData)
                PBUtil.ConvertBornDataToProto(frameDataProto.born_data, frameData.bornData)
                PBUtil.ConvertStatusDataToProto(frameDataProto.status_data, frameData.statusData)
            end
        end
    end,

    ConvertSummonDataToProto = function(protoData, summonData)
        if summonData then
            protoData.camp = summonData.camp
            protoData.reason = summonData.reason
            protoData.summonID = summonData.summonID
            protoData.summonLevel = summonData.summonLevel
        end
    end,

    ConvertSkillDataToProto = function(protoData, skillData)
        if skillData then
            protoData.camp = skillData.camp
            protoData.skillID = skillData.skillID
            protoData.actorID = skillData.actorID
            protoData.targetID = skillData.targetID
            protoData.keyframe = skillData.keyframe
        end
    end,

    ConvertPostionDataToProto = function(protoData, posData)
        if posData then
            protoData.actorID = posData.actorID
            protoData.reason = posData.reason
            protoData.pos_x = posData.pos_x
            protoData.pos_y = posData.pos_y
            protoData.pos_z = posData.pos_z
            protoData.exParam = posData.exParam
        end
    end,

    ConvertRotationDataToProto = function(protoData, rotationData)
        if rotationData then
            protoData.actorID = rotationData.actorID
            protoData.rot_x = rotationData.rot_x
            protoData.rot_y = rotationData.rot_y
            protoData.rot_z = rotationData.rot_z
        end
    end,

    ConvertWujiangAttrDataToProto = function(protoData, attrData)
        if attrData then
            protoData.actorID = attrData.actorID
            protoData.attrType = attrData.attrType
            protoData.oldVal = attrData.oldVal
            protoData.newVal = attrData.newVal
        end
    end,

    ConvertHPDataToProto = function(protoData, hpData)
        if hpData then
            protoData.actorID = hpData.actorID
            protoData.hurtType = hpData.hurtType
            protoData.reason = hpData.reason
            protoData.deltaVal = hpData.deltaVal
            protoData.oldHP = hpData.oldHP
            protoData.newHP = hpData.newHP
            protoData.attackID = hpData.attackID
            protoData.skillID = hpData.skillID
            protoData.judge = hpData.judge
        end
    end,

    ConvertJudgeDataToProto = function(protoData, judgeData)
        if judgeData then
            protoData.actorID = judgeData.actorID
            protoData.judge = judgeData.judge
            protoData.targetID = judgeData.targetID
        end
    end,
    
    ConvertNuqiDataToProto = function(protoData, nuqiData)
        if nuqiData then
            protoData.actorID = nuqiData.actorID
            protoData.deltaVal = nuqiData.deltaVal
            protoData.reason = nuqiData.reason
            protoData.skillID = nuqiData.skillID
            protoData.oldHP = nuqiData.oldHP
            protoData.newHP = nuqiData.newHP
        end
    end,

    ConvertBornDataToProto = function(protoData, bornData)
        if bornData then
            protoData.actorID = bornData.actorID
            protoData.pos_x = bornData.pos_x
            protoData.pos_y = bornData.pos_y
            protoData.pos_z = bornData.pos_z
            protoData.forward_x = bornData.forward_x
            protoData.forward_y = bornData.forward_y
            protoData.forward_z = bornData.forward_z
            protoData.hp = bornData.hp
        end
    end,

    ConvertStatusDataToProto = function(protoData, statusData)
        if statusData then
            protoData.actorID = statusData.actorID
            protoData.statusType = statusData.statusType
            protoData.giverSkillID = statusData.giverSkillID
            protoData.giverActorID = statusData.giverActorID
        end
    end,

    ConvertCmdListToProto = function(cmdListProto, cmdList)
        for _,command in pairs(cmdList) do
            if command then
                local dataProto = cmdListProto:add()

                dataProto.cmd_type = command:GetCmdType()
                dataProto.frame_num = command:GetFrameNum()

                if dataProto.cmd_type == BattleEnum.FRAME_CMD_TYPE_SUMMON_PERFORM then
                    dataProto.cmd_summon_perform.camp = command:GetData()

                elseif dataProto.cmd_type == BattleEnum.FRAME_CMD_TYPE_SKILL_INPUT_END then
                    PBUtil.ConvertSkillInputEndDataToProto(dataProto.cmd_input_end, command:GetData())

                elseif dataProto.cmd_type == BattleEnum.FRAME_CMD_TYPE_CREATE_BENCH then
                    dataProto.cmd_create_bench.wujiang_id = command:GetData()

                elseif dataProto.cmd_type == BattleEnum.FRAME_CMD_TYPE_SELECT_SHENBING then
                    dataProto.cmd_select_shenbing.award_index, dataProto.cmd_select_shenbing.award_actor_id = command:GetData()
                
                elseif dataProto.cmd_type == BattleEnum.FRAME_CMD_TYPE_GUILDBOSS_SYNC_HP then
                    dataProto.cmd_guildboss_sync_hp.harm, dataProto.cmd_guildboss_sync_hp.left_hp, dataProto.cmd_guildboss_sync_hp.is_self = command:GetData()
                end
            end
        end
    end,

    ConvertSkillInputEndDataToProto = function(protoData, performPos,performerID,targetID)
        protoData.performer_id = performerID
        protoData.target_id = targetID
        protoData.perform_pos.x = performPos.x
        protoData.perform_pos.y = performPos.y
        protoData.perform_pos.z = performPos.z
    end,

    ConvertLineupDataToProto = function(buzhenID, proto, lineupData)
        proto.buzhen_id = buzhenID
        proto.wujiang_seq1 = lineupData.roleSeqList[1] or 0
        proto.wujiang_seq2 = lineupData.roleSeqList[2] or 0
        proto.wujiang_seq3 = lineupData.roleSeqList[3] or 0
        proto.wujiang_seq4 = lineupData.roleSeqList[4] or 0
        proto.wujiang_seq5 = lineupData.roleSeqList[5] or 0
        proto.summon = lineupData.summon or 0
        proto.backup_wujiang_seq1 = lineupData.backupSeqList[1] or 0
        proto.backup_wujiang_seq2 = lineupData.backupSeqList[2] or 0
        proto.backup_wujiang_seq3 = lineupData.backupSeqList[3] or 0
        if lineupData.employData then
            proto.hired_wujiang.hire_owner_id = lineupData.employData.ownerID
            proto.hired_wujiang.wujiang_brief.id = lineupData.employData.id
            proto.hired_wujiang.wujiang_brief.level = lineupData.employData.level
            proto.hired_wujiang.wujiang_brief.star = lineupData.employData.star
            proto.hired_wujiang.wujiang_brief.pos = lineupData.employData.pos
            proto.hired_wujiang.wujiang_brief.index = lineupData.employData.index
            proto.hired_wujiang.wujiang_brief.power = lineupData.employData.power
            proto.hired_wujiang.wujiang_brief.tupo_times = lineupData.employData.tupo
            proto.hired_wujiang.wujiang_brief.wuqiLevel = lineupData.employData.weaponLevel
        end
    end,

    ConvertWujiangBriefProtoToData = function(briefProto)
        local briefClass = require("DataCenter.WuJiangData.WuJiangBrief")
        local o = briefClass.New()
        
        o.id = briefProto.id
        o.level = briefProto.level
        o.star = briefProto.star
        o.pos = briefProto.pos
        o.index = briefProto.index
        o.power = briefProto.power
        o.tupo = briefProto.tupo_times
        o.weaponLevel = briefProto.wuqiLevel
        o.mountID = briefProto.mountID
        o.mountLevel = briefProto.mountLevel
        
        return o
    end,

    ConvertWujiangDataToBrief = function(wujiangData)
        local briefClass = require("DataCenter.WuJiangData.WuJiangBrief")
        local o = briefClass.New()
        
        o.id = wujiangData.id
        o.level = wujiangData.level
        o.star = wujiangData.star
        o.pos = 0
        o.index = wujiangData.index
        o.power = wujiangData.power
        o.tupo = wujiangData.tupo
        o.weaponLevel = wujiangData.weaponLevel
        
        return o
    end,

    ToParseList = function(protoList, parseFunc)
        if protoList and parseFunc then
            local dataList = {}
            for i, v in ipairs(protoList) do
                if v then
                   local data = parseFunc(v)
                   if data then
                        table_insert(dataList, data) 
                   end
                end
            end
            return dataList
        end
    end,
    
    ConvertUserBriefProtoToData = function(user_brief_info, data)
        if user_brief_info then
            if not data then
                local briefClass = require("DataCenter.UserData.UserBrief")
                data = briefClass.New()
            end
            data.uid = user_brief_info.uid
            data.use_icon = user_brief_info.use_icon          -- 主公头像
            data.level = user_brief_info.level     
            data.name = user_brief_info.name                  
            data.guild_name = user_brief_info.guild_name      -- 军团名称
            data.vip_level = user_brief_info.vip_level   
            data.guild_job = user_brief_info.guild_job
            data.guild_id = user_brief_info.guild_id
            data.dist_id = user_brief_info.dist_id
            data.guild_icon = user_brief_info.guild_icon      --家族旗帜
            data.guild_job_name = user_brief_info.guild_job_name
            data.str_dist_id = user_brief_info.str_dist_id
            data.dist_name = user_brief_info.dist_name
            return data
        end
    end,

    ConvertEmpolyWujiangProtoToData = function(proto)
        local briefClass = require("DataCenter.FriendData.FriendEmployData")
        local data = briefClass.New()
        data.leftEmployTimes = proto.left_rent_times
        data.friendBriefData = PBUtil.ConvertUserBriefProtoToData(proto.friend_brief)
        data.wujiangBriefData = PBUtil.ConvertWujiangBriefProtoToData(proto.rentout_wujiang_brief)
        data.wujiangBriefData.ownerID = data.friendBriefData.uid
        return data
    end,

    
    ConvertOneBuzhenProtoToData = function(one_buzhen)
        if one_buzhen then
            local LineupDataClass = require "DataCenter.Lineup.LineupData"
            local lineupData = LineupDataClass.New(one_buzhen.buzhen_id)
            lineupData.roleSeqList = {one_buzhen.wujiang_seq1, one_buzhen.wujiang_seq2, one_buzhen.wujiang_seq3, one_buzhen.wujiang_seq4, one_buzhen.wujiang_seq5}
            lineupData.summon = one_buzhen.summon
            lineupData.backupSeqList = {one_buzhen.backup_wujiang_seq1, one_buzhen.backup_wujiang_seq2, one_buzhen.backup_wujiang_seq3}
            if one_buzhen.hired_wujiang then
                lineupData.employData = PBUtil.ConvertWujiangBriefProtoToData(one_buzhen.hired_wujiang.wujiang_brief)
                lineupData.employData.ownerID = one_buzhen.hired_wujiang.hire_owner_id
            end
            return lineupData
        end
    end,

    ParseAwardList = function(award_list)
        local AwardDataClass = require "DataCenter.AwardData.AwardData"

        local l = {}
        for _, v in ipairs(award_list) do
            local oneAward = AwardDataClass.New(v.award_type)
            oneAward:ParseFromPbObj(v)
            table_insert(l, oneAward)
        end
        return l
    end,

    CreateAwardData = function(item_id, item_count)
        local AwardDataClass = require "DataCenter.AwardData.AwardData"
        local oneAward = AwardDataClass.New(CommonDefine.AWARD_TYPE_ITEM)
        oneAward:CreateItem(item_id, item_count)
        return oneAward
    end,
    
    ConvertShopGoodsProtoToData = function(proto)
        local briefClass = require("DataCenter.Shop.GoodsData")
        local data = briefClass.New()
        data.goodsID = proto.goods_id
        data.discount = proto.discount
        data.leftBuyTimes = proto.left_buy_times
        data.descIndex = proto.cond_desc_index
        data.noLimit = proto.without_limit
        return data
    end,

    ConvertVipShopGoodsProtoToData = function(proto)
        local dataClass = require("DataCenter.Vip.VipGoodsData")
        local data = dataClass.New()
        data.goodsID = proto.goods_id
        data.price = proto.price
        data.charged_yuanbao = proto.charged_yuanbao
        data.normal_charged_yuanbao = proto.normal_charged_yuanbao
        data.first_charged_yuanbao = proto.first_charged_yuanbao
        data.recommend = proto.recommend
        data.sicon = proto.sicon
        data.desc = proto.desc
        data.appStoreProductID = proto.appStoreProductID
        data.name = proto.name
        data.buy_times = proto.buy_times
        data.goods_type = proto.goods_type
        data.buy_times_limit = proto.buy_times_limit
        data.buy_times_type = proto.buy_times_type
        data.sortID = proto.sortID
        data.goods_info_list = PBUtil.ToParseList(proto.goods_info_list, PBUtil.ConvertOneItemToData)
        return data
    end,

    ConvertOneItemToData = function(one_item)
        local itemData = nil
        if one_item then
            local itemID = one_item.item_id
            local itemCount = one_item.count or 0
            local isLocked = one_item.locked == 1
            local ItemDataClass = require "DataCenter.ItemData.ItemData"
            itemData = ItemDataClass.New(itemID, itemCount, isLocked)
        end
        return itemData
    end,

    CreateAwardParamFromPbAward = function(pb_award_info)
        local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"

        if pb_award_info.award_type == CommonDefine.AWARD_TYPE_ITEM then
            local pb_item = pb_award_info.award_item
            local param = AwardIconParamClass.New(pb_item.item_id, pb_item.count)
            return param
        elseif pb_award_info.award_type == CommonDefine.AWARD_TYPE_HERO then
            local pb_wujiang = pb_award_info.award_wujiang
            local param = AwardIconParamClass.New(pb_wujiang.wujiang_id, 1)
            param.star = pb_wujiang.wujiang_star
            param.level = pb_wujiang.wujiang_level
            return param
        elseif pb_award_info.award_type == CommonDefine.AWARD_TYPE_SHENBING then
            local pb_shenbing = pb_award_info.award_shenbing
            local param = AwardIconParamClass.New(pb_shenbing.id, 1)
            param.level = pb_shenbing.stage
            return param
        elseif pb_award_info.award_type == CommonDefine.AWARD_TYPE_ZUOQI then
            local pb_zuoqi = pb_award_info.award_horse
            local param = AwardIconParamClass.New(pb_zuoqi.id, 1)
            param.level = pb_zuoqi.stage
            return param
        end
    end,

    CreateAwardParamFromAwardData = function(award_data)
        local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"

        if award_data:GetAwardType() == CommonDefine.AWARD_TYPE_ITEM then
            local pb_item = award_data:GetItemData()
            local param = AwardIconParamClass.New(pb_item:GetItemID(), pb_item:GetItemCount())
            return param
        elseif award_data:GetAwardType() == CommonDefine.AWARD_TYPE_HERO then
            local pb_wujiang = award_data:GetWujiangData()
            local param = AwardIconParamClass.New(pb_wujiang.id, 1)
            param.star = pb_wujiang.star
            param.level = pb_wujiang.level
            return param
        elseif award_data:GetAwardType() == CommonDefine.AWARD_TYPE_SHENBING then
            local pb_shenbing = award_data:GetShenbingData()
            local param = AwardIconParamClass.New(pb_shenbing:GetItemID(), 1)
            param.level = pb_shenbing:GetStage()
            return param
        elseif award_data:GetAwardType() == CommonDefine.AWARD_TYPE_ZUOQI then
            local pb_zuoqi = award_data:GetZuoqiData()
            local param = AwardIconParamClass.New(pb_zuoqi:GetItemID(), 1)
            param.level = pb_zuoqi:GetStage()
            return param
        end
    end,
}