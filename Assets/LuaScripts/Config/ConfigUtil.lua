ConfigUtil = {
    GetConfigTbl = function(path)
        return require(path)
    end,

    GetSkillCfgByID = function(skill_id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_skill")
        if tbl then
            return tbl[skill_id]
        end
        return nil
    end,

    GetWujiangCfgByID = function(wujiang_id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_role")
        if tbl then
            return tbl[wujiang_id]
        end
        return nil
    end,

    GetGroupHerosJunxianCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_qunxiongzhulu_military_rank")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetGroupHerosDengjieCfgList = function()
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_qunxiongzhulu_military")
        if tbl then
            return tbl
        end
        return nil
    end,

    GetGroupHerosSaichangCfgList = function()
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_qunxiongzhulu_duan")
        if tbl then
            return tbl
        end
        return nil
    end,

    GetGroupHerosJunxianCfgList = function()
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_qunxiongzhulu_military_rank")
        if tbl then
            return tbl
        end
        return nil
    end,

    GetVipPrivilegeCfgByLvl = function(vip_level)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_vip_privilege")
        if tbl then
            return tbl[vip_level]
        end
        return nil
    end,

    GetVipPrivilegeValue = function(vip_level, privilege_str)
        local cfg = ConfigUtil.GetVipPrivilegeCfgByLvl(vip_level)
        if cfg then
            return cfg[privilege_str] or 0
        end
        return 0
    end,

    GetIntimacyCfgByID = function(wujiang_id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_intimacy")
        if tbl then
            return tbl[wujiang_id]
        end
        return nil
    end, 

    GetIntimacyLevelCfgByComcatID = function(comcat_id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_intimacy_level")
        if tbl then
            return tbl[comcat_id]
        end
        return nil
    end,

    GetIntimacyItemFuncCfg = function()
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_item_func")
        if tbl then
            return tbl
        end
        return nil
    end,

    GetShenbingCfgByID = function(shengbing_id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_shenbing")
        if tbl then
            return tbl[shengbing_id]
        end
        return nil
    end,

    GetHuntCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_hunt")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetHuntLevelUpCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_hunt_ground_level")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetShowClearCDPriceCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_hunt_show_clear_cd_price")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetShenbingInscriptionCfgByID = function(inscriptionID)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_shenbing_inscription")
        if tbl then
            return tbl[inscriptionID]
        end
        return nil
    end,

    GetShenbingInscriptionCfgList = function()
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_shenbing_inscription")
        if tbl then
            return tbl
        end
        return nil
    end,

    ShenbingInscriptionCfgQualityList = {},

    GetShenbingInscriptionCfgListByQuality = function(quality)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_shenbing_inscription")
        local qualityList = ConfigUtil.ShenbingInscriptionCfgQualityList
        if not qualityList[quality] then
            local list = {}
            local table_insert = table.insert
            for k, v in pairs(tbl) do
                if v.quality == quality then
                    table_insert(list, v)
                end
            end 
            qualityList[quality] = list
        end

        return qualityList[quality]
    end,

    GetShenbingImproverCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_shenbing_improve_stage")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetWujiangTalentCfgByStar = function(star)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_wujiang_talent_factor")
        if tbl then
            return tbl[star]
        end
        return nil
    end,

    GetActorEffectCfgByID = function(effect_id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_actor_effect")
        if tbl then
            return tbl[effect_id]
        end
        return nil
    end,

    GetActionCfgByID = function(wujiang_id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_action")
        if tbl then
            return tbl[wujiang_id]
        end
        return nil
    end,

    GetAnimationCfgByName = function(anim_name)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_animation")
        if tbl then
            return tbl[anim_name]
        end
        return nil
    end,

    GetMapCfgByID = function(map_id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_map")
        if tbl then
            return tbl[map_id]
        end
        return nil
    end,

    GetMapStandCfgByID = function(stand_id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_map_stand")
        if tbl then
            return tbl[stand_id]
        end
        return nil
    end,

    GetStandMatrixByMapName = function(map_name, wave)
        local tbl = ConfigUtil.GetConfigTbl("Config.MapMatrix.lua_cell_matrix"..map_name)
        if tbl then
            return tbl['matrix'..wave]
        end
        return nil
    end,

    GetMonsterCfgByID = function(monster_id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_monster")
        if tbl then
            return tbl[monster_id]
        end
        return nil
    end,

    GetBattleRoundCfgByID = function(round_id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_battle_round")
        if tbl then
            return tbl[round_id]
        end
        return nil
    end,

    GetYuanmenBuZhenCfgByID = function(yuanmen_id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_yuanmen_buzhen") 
        if tbl then
            return tbl[yuanmen_id]
        end
        return nil
    end,

    GetYuanmenBuffCfgByID = function(buff_id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_yuanmen_buff") 
        if tbl then
            return tbl[buff_id]
        end
        return nil
    end,

    GetYuanmenBoxAwardCfgByID = function(yuanmen_id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_box") 
        if tbl then
            return tbl[yuanmen_id]
        end
        return nil
    end,

    GetMonsterMaxCfgByLevel = function(level)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_monster_max_value")
        if tbl then
            return tbl[level]
        end
        return nil
    end,

    GetCopyCfgByID = function(copy_id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_copy")
        if tbl then
            return tbl[copy_id]
        end
        return nil
    end,

    GetCellMatrixByMapName =  function(map_name)
        return ConfigUtil.GetConfigTbl("Config.MapMatrix.lua_cell_matrix"..map_name)
    end,

    GetTimelineCfgByID = function(timelineName, timelinePath)
        if not timelinePath or not timelineName then
            Logger.Log("---------timelineName error")
        end
        return ConfigUtil.GetConfigTbl("Config.Timeline.".. timelinePath .. ".lua_timeline" .. timelineName)
    end,

    GetAudioCfgByID = function(audioID)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_audio")
        if tbl then
            return tbl[audioID]
        end
        return nil
    end,

    GetFuliCfgByID = function(audioID)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_fuli")
        if tbl then
            return tbl[audioID]
        end
        return nil
    end,

    GetObjectCfgByID = function(object_id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_objects")
        if tbl then
            return tbl[object_id]
        end
        return nil
    end,

    GetWuJiangLevelCfgByID = function(lv)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_wujiang_level")
        if tbl then
            return tbl[lv]
        end
        return nil
    end,

    GetWuJiangStarCfgByID = function(star)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_wujiang_star")
        if tbl then
            return tbl[star]
        end
        return nil
    end,

    GetWuJiangBreakCfgByID = function(tupo)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_wujiang_break")
        if tbl then
            return tbl[tupo]
        end
        return nil
    end,

    GetItemFuncCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_item_func")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

	GetItemCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_item")
        if tbl then
            return tbl[id]
        end
        return nil
    end,
    
    GetInscriptionStageCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_inscription_stage")
        if tbl then
            return tbl[id]
        end
        return nil
	end,
    
    GetCampsRushCopyCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_camps_rush_copy")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetCampsRushCopyCfg = function()
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_camps_rush_copy")
        if tbl then
            return tbl
        end
        return nil
    end,

    GetCampsRushCopyDropCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_camps_drop")
        if tbl then
            return tbl[id]
        end
        return nil
    end,
    GetArenaDanAwardCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_arena_dan_award")
        if tbl then
            return tbl[id]
        end
        return nil
    end,
    GetArenaBuyCost = function(buy_times)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_arena_buy_times_cost")
        if tbl then
            return tbl[buy_times]
        end
        return nil
    end,
    GetArenaAwardDict = function()
        return ConfigUtil.GetConfigTbl("Config.Data.lua_arena_award")
    end,

    GetArenaAwardCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_arena_award")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetInscriptionCopyCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_inscription_copy")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetShenbingCopyCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_shenbingcopy")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetShenbingCopyCfgList = function()
        return ConfigUtil.GetConfigTbl("Config.Data.lua_shenbingcopy")
    end,

    GetShenbingCopyMonsterCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_shenbingcopy_monsters")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetZuoQiCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_horse")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetZuoQiImproveCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_horse_stage")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetShenbingCfgList = function()
        return ConfigUtil.GetConfigTbl("Config.Data.lua_shenbing")
    end,

    GetShenbingCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_shenbing")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetWorldBossCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_world_boss")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetCopySectionCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_copy_section")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetCopyCfgList = function()
        return ConfigUtil.GetConfigTbl("Config.Data.lua_copy")
    end,

    GetSectionCfgList = function()
        return ConfigUtil.GetConfigTbl("Config.Data.lua_copy_section")
    end,

    GetSectionBoxAwardCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_copy_star_reward")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetCopyDropCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_copy_drop")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetStarCfgList = function()
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_star")
        return tbl
    end,

    GetStarCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_star")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetGuildIconCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_guild_icon")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetCopyResetCostCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_copy_reset_cost")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetVipPrivilegeByID = function(id)
    local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_vip_privilege")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetUserExpCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_user_exp")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetSysopenCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_sysopen")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetSysopenCfg = function()
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_sysopen")
        if tbl then
            return tbl
        end
        return nil
    end,

    GetGuildDonateCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_guild_donate")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetGuildTaskCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_guild_task")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetGuildExpCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_guild_exp")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetGuildSkillCfg = function()
        return ConfigUtil.GetConfigTbl("Config.Data.lua_guild_skill")
    end,

    GetGuildSkillCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_guild_skill")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetGuildWorShipCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_guild_worship")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetHeadIconCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_head_icon")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetHeadIconCfgList = function()
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_head_icon")
        return tbl
    end,

    GetHeadIconBoxCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_head_icon_box")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetGuildBossCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_guild_boss")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetMainIconCfgByID = function()
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_main_icon")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetMainIconCfgDict = function()
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_main_icon")
        return tbl
    end,
    
    GetFriendRelationCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_friend_relation")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetFriendRelationCfgList = function()
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_friend_relation")
        return tbl
    end,
    
    GetFriendGiftCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_friend_gift")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetFriendGiftCfgList = function()
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_friend_gift")
        return tbl
    end,

    GetGraveCopyCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_grave_copy")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetGraveCopyCfgList = function()
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_grave_copy")
        return tbl
    end,

    GetChatFaceCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_chat_face")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetChatFaceCfgList = function()
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_chat_face")
        return tbl
    end,

    GetFriendTaskCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_friend_task")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetTaskCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_task")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetTaskBoxCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_task_box_award")
        if tbl then
            return tbl[id]
        end
        return nil
    end,
    

    GetInscriptionCopyScoreAwardCfgList = function()
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_inscription_copy_score_award")
        return tbl
    end,

    GetGragonCopyCfgList = function()
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_dragon_copy")
        if tbl then
            return tbl
        end
        return nil
    end,

    GetGragonCopyCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_dragon_copy")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetInscriptionCopyCfgList = function()
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_inscription_copy")
        return tbl
    end,

    GetXiejiaResCfgByRare = function(rare)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_lottery_xiejia")
        if tbl then
            return tbl[rare]
        end
        return nil
    end,

    GetShopCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_shop")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetMysteryShopCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_shop_secret")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetGodBeastCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_dragon")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetGodBeastCfgList = function(id)
        return ConfigUtil.GetConfigTbl("Config.Data.lua_dragon")
    end,

    GetShenshouCopyCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_dragon_copy")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetGodBeastLevelCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_dragon_improve")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetGodBeastTalentCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_dragon_talent")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetGuildWarCraftCityCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_guild_warcraft_city")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetNoticeCfgList = function()
        return ConfigUtil.GetConfigTbl("Config.Data.lua_notice")
    end,

    GetGuildWarRankAwardCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_guild_warcraft_rank_award") 
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetGuildWarCraftCityCfgList = function()
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_guild_warcraft_city")
        return tbl
    end,

    GetGuildWarCraftDefTitleCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_guild_warcraft_def_title")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetGuildWarCraftDefTitleCfgList = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_guild_warcraft_def_title")
        return tbl
    end,

    GetGuildWarCraftShopCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_guild_warcraft_shop")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetGuildWarCraftShopCfgList = function()
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_guild_warcraft_shop")
        return tbl
    end,
    
    GetGuildWarHuSongCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_guild_husong")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetGodBeastTalentAllCfg = function()
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_dragon_talent")
        if tbl then
            return tbl
        end
        return nil
    end,

    GetLieZhuanCopyCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_liezhuan")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetLieZhuanAllCopyCfg = function()
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_liezhuan")
        if tbl then
            return tbl
        end
        return nil
    end,

    GetGuideCfgList = function(wujiang_id)
        return ConfigUtil.GetConfigTbl("Config.Data.lua_guide")
    end,

    GetGuideCfgByID = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_guide")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetInscriptionAndHorseSkillCfgByID = function(skill_id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_otherskill")
        if tbl then
            return tbl[skill_id]
        end
        return nil
    end,

    GetHorseRaceMapCfgById = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_horse_race_map")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetHorseRaceAllMapCfg = function()
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_horse_race_map")
        if tbl then
            return tbl
        end
        return nil
    end,

    GetTipsDescCfg = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_tips_desc")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetHorseRacePriceCfgById = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_horse_race_price")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetWuJiangBreakSecondAttrCfgById = function(id)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_wujiang_break_second_attr")
        if tbl then
            return tbl[id]
        end
        return nil
    end,

    GetHorseRaceCameraCfgByRankNum = function(rankNum)
        local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_horse_race_camera")
        if tbl then
            return tbl[rankNum]
        end
        return nil
    end,
}