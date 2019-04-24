--UI通用逻辑

local CommonDefine = CommonDefine
local Screen = CS.UnityEngine.Screen
local Application = CS.UnityEngine.Application
local RuntimePlatform = CS.UnityEngine.RuntimePlatform
local SystemInfo = CS.UnityEngine.SystemInfo
local GameObject = CS.UnityEngine.GameObject
local string_gsub = string.gsub
local string_find = string.find
local math_min = math.min
local ConfigUtil = ConfigUtil
local Language = Language
local string_format = string.format
local table_insert = table.insert
local math_floor = math.floor
local string_split = string.split
local string_len = string.len
local GameUtility = CS.GameUtility
local TimeUtil = TimeUtil
local ItemDefine = ItemDefine
local AtlasConfig = AtlasConfig
local math_ceil = math.ceil
local math_floor = math.floor
local math_round = Mathf.Round
local UIConfig = UIConfig
local UIWindowNames = UIWindowNames
local Utils = Utils
local NetworkReachability = CS.UnityEngine.NetworkReachability

local Type_CanvasScaler = typeof(CS.UnityEngine.UI.CanvasScaler)

local UILogicUtil = {}

function SetWuJiangRareImage(icon, rareType)
    if icon then
        if rareType == CommonDefine.WuJiangRareType_1 then
            icon:SetAtlasSprite("ty16.png", true)
        elseif rareType == CommonDefine.WuJiangRareType_2 then
            icon:SetAtlasSprite("ty15.png", true)
        elseif rareType == CommonDefine.WuJiangRareType_3 then
            icon:SetAtlasSprite("ty14.png", true)
        elseif rareType == CommonDefine.WuJiangRareType_4 then
            icon:SetAtlasSprite("ty13.png", true)
        end
    end
end

local FLASH_COLOR = Color.New(202/255, 117/255, 10/255, 1)
local NO_COLOR = Color.black

function SetWuJiangFrame(icon, rareType, setNativeSize)
    if icon then
        if rareType == CommonDefine.WuJiangRareType_1 then
            icon:SetAtlasSprite("ty24.png", setNativeSize)
            icon:SetColor(NO_COLOR)
        elseif rareType == CommonDefine.WuJiangRareType_2 then
            icon:SetAtlasSprite("ty20.png", setNativeSize)
            icon:SetColor(NO_COLOR)
        elseif rareType == CommonDefine.WuJiangRareType_3 then
            icon:SetAtlasSprite("ty22.png", setNativeSize)
            icon:SetColor(NO_COLOR)
        elseif rareType == CommonDefine.WuJiangRareType_4 then
            icon:SetAtlasSprite("ty18.png", setNativeSize)
            icon:SetColor(FLASH_COLOR)
        end
    end
end

function SetWuJiangJobImage(icon, jobType, setNativeSize)
    if icon then
        --1猛将2近卫3豪杰4神射5仙法
        if jobType == CommonDefine.PROF_1 then
            icon:SetAtlasSprite("ty27.png", setNativeSize)
        elseif jobType == CommonDefine.PROF_2 then
            icon:SetAtlasSprite("ty29.png", setNativeSize)
        elseif jobType == CommonDefine.PROF_3 then
            icon:SetAtlasSprite("ty04.png", setNativeSize)
        elseif jobType == CommonDefine.PROF_4 then
            icon:SetAtlasSprite("ty26.png", setNativeSize)
        elseif jobType == CommonDefine.PROF_5 then
            icon:SetAtlasSprite("ty28.png", setNativeSize)
        end
    end
end

function SetWuJiangCountryImage(icon, country, setNativeSize)
     -- 1魏2蜀3吴4群
    if icon then
        if country == CommonDefine.COUNTRY_1 then
            icon:SetAtlasSprite("peiyang31.png", setNativeSize)
        elseif country == CommonDefine.COUNTRY_2 then
            icon:SetAtlasSprite("peiyang29.png", setNativeSize)
        elseif country == CommonDefine.COUNTRY_3 then
            icon:SetAtlasSprite("peiyang30.png", setNativeSize)
        elseif country == CommonDefine.COUNTRY_4 then
            icon:SetAtlasSprite("peiyang32.png", setNativeSize)
        end
    end
end

function GetWuJiangJobName(jobType)
    if jobType == CommonDefine.PROF_1 then
        return Language.GetString(614)
    elseif jobType == CommonDefine.PROF_2 then
        return Language.GetString(615)
    elseif jobType == CommonDefine.PROF_3 then
        return Language.GetString(616)
    elseif jobType == CommonDefine.PROF_4 then
        return Language.GetString(617)
    elseif jobType == CommonDefine.PROF_5 then
        return Language.GetString(618)
    end
end

function GetWuJiangCountryName(country)
    if country == CommonDefine.COUNTRY_1 then
        return Language.GetString(610)
    elseif country == CommonDefine.COUNTRY_2 then
        return Language.GetString(611)
    elseif country == CommonDefine.COUNTRY_3 then
        return Language.GetString(612)
    elseif country == CommonDefine.COUNTRY_4 then
        return Language.GetString(613)
    end
end

--大于100000变为‘10万’
function ChangeCountToCountAndText(count)
    if count > CommonDefine.CountLimitToText then
        return string_format("%d%s", math_floor(count / (CommonDefine.CountLimitToText / 10)), '万')
    else
        return tostring(math_ceil(count)) 
    end
end

--设置物品边框
function SetItemFrameNormalImage(icon, stage, mainType, setNativeSize)
    if icon then
        local isXinWu = mainType == CommonDefine.ItemMainType_XinWu
        --1阶[灰] 2阶[蓝] 3阶[紫] 4阶[金] 5阶[红]
        if stage == CommonDefine.ItemStageType_1 then
            icon:SetAtlasSprite(isXinWu and "ty87.png" or "ty24.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_2 then
            icon:SetAtlasSprite(isXinWu and "ty88.png" or "ty20.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_3 then
            icon:SetAtlasSprite(isXinWu and "ty86.png" or "ty22.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_4 then
            icon:SetAtlasSprite(isXinWu and "ty89.png" or "ty18.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_5 then
            icon:SetAtlasSprite(isXinWu and "ty89.png" or "ty63.png", setNativeSize)
        end
    end
end

--设置物品边框(高亮时)
function SetItemFrameHighLightImage(icon, stage, mainType, setNativeSize)
    if icon then
        local isXinWu = mainType == CommonDefine.ItemMainType_XinWu
        --1阶[灰] 2阶[蓝] 3阶[紫] 4阶[金] 5阶[红]
        if stage == CommonDefine.ItemStageType_1 then
            icon:SetAtlasSprite(isXinWu and "ty95.png" or "beibao18.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_2 then
            icon:SetAtlasSprite(isXinWu and "ty96.png" or "beibao14.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_3 then
            icon:SetAtlasSprite(isXinWu and "ty94.png" or "beibao16.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_4 then
            icon:SetAtlasSprite(isXinWu and "ty97.png" or "beibao12.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_5 then
            icon:SetAtlasSprite(isXinWu and "ty97.png" or "ty66.png", setNativeSize)
        end
    end
end

--设置物品底图
function SetItemBgNormalImage(icon, stage, setNativeSize)
    if icon then
        --1阶[灰] 2阶[蓝] 3阶[紫] 4阶[金] 5阶[红]
        if stage == CommonDefine.ItemStageType_1 then
            icon:SetAtlasSprite("ty23.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_2 then
            icon:SetAtlasSprite("ty19.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_3 then
            icon:SetAtlasSprite("ty21.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_4 then
            icon:SetAtlasSprite("ty17.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_5 then
            icon:SetAtlasSprite("ty64.png", setNativeSize)
        end
    end
end

--设置物品等级图片
function SetItemLevelImage(icon, stage, setNativeSize)
    if icon then
        --1阶[灰] 2阶[蓝] 3阶[紫] 4阶[金] 5阶[红]
        if stage == CommonDefine.ItemStageType_1 then
            icon:SetAtlasSprite("peiyang28.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_2 then
            icon:SetAtlasSprite("peiyang26.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_3 then
            icon:SetAtlasSprite("peiyang27.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_4 then
            icon:SetAtlasSprite("peiyang25.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_5 then
            icon:SetAtlasSprite("peiyang25.png", setNativeSize)
        end
    end
end

function SetMingQianBgImage(icon, stage, setNativeSize)
    if icon then
        --1阶[灰] 2阶[蓝] 3阶[紫] 4阶[金] 5阶[红]
        if stage == CommonDefine.ItemStageType_1 then
            icon:SetAtlasSprite("mj35.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_2 then
            icon:SetAtlasSprite("mj36.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_3 then
            icon:SetAtlasSprite("mj37.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_4 then
            icon:SetAtlasSprite("mj38.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_5 then
            icon:SetAtlasSprite("mj39.png", setNativeSize)
        end
    end
end

--设置物品底图(高亮时)
function SetItemBgHighLightImage(icon, stage, setNativeSize)
    if icon then
        --1阶[灰] 2阶[蓝] 3阶[紫] 4阶[金] 5阶[红]
        if stage == CommonDefine.ItemStageType_1 then
            icon:SetAtlasSprite("beibao17.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_2 then
            icon:SetAtlasSprite("beibao13.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_3 then
            icon:SetAtlasSprite("beibao15.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_4 then
            icon:SetAtlasSprite("beibao19.png", setNativeSize)
        elseif stage == CommonDefine.ItemStageType_5 then
            icon:SetAtlasSprite("ty67.png", setNativeSize)
        end
    end
end

--是否需要刘海
function CheckNeedHair()

    local needHair = false

    if Application.platform == RuntimePlatform.IPhonePlayer then
        local device = string_gsub(SystemInfo.deviceModel," ","")
       
        if string_find(device,"iPhone10,3") or 
            string_find(device,"iPhone10,6") or 
            string_find(device,"iPhone11,8") or 
            string_find(device,"iPhone11,2") or 
            string_find(device,"iPhone11,6") then
			needHair = true
		end
    end
    
     --兼容测试模式
    if needHair or CommonDefine.IS_HAIR_MODEL then
        CommonDefine.IS_HAIR_MODEL = true
       -- CommonDefine.IPHONE_X_OFFSET_LEFT = 55
       -- CommonDefine.IPHONE_X_OFFSET_RIGHT = 0
    end

    if CS.GameUtility.IsEditor() then
        if Screen.width == 2436 and Screen.height == 1125 then
            
			CommonDefine.IS_HAIR_MODEL = true
        end
    end
end

function CalcScreen()
    local resolutionWidth = Screen.width
    local resolutionHeight = Screen.height
    local screenConvertRatio = math_min(resolutionWidth / CommonDefine.MANUAL_WIDTH, resolutionHeight / CommonDefine.MANUAL_HEIGHT)
    CommonDefine.SCREEN_WIDTH = resolutionWidth / screenConvertRatio
    CommonDefine.SCREEN_HEIGHT = resolutionHeight / screenConvertRatio
end

function GetSkillDesc(skillID, level)
    local skillCfg = ConfigUtil.GetSkillCfgByID(skillID)
    if skillCfg then
        local str = skillCfg["desc"..level]
        if str then
            str = str:gsub("{(.-)}", skillCfg)
            return str
        end
    end
end

function GetTupoLimit(rareType)
    if rareType == CommonDefine.WuJiangRareType_1 then
        return 2
    elseif rareType == CommonDefine.WuJiangRareType_2 then
        return 9
    elseif rareType == CommonDefine.WuJiangRareType_3 then
        return 15
    elseif rareType == CommonDefine.WuJiangRareType_4 then
        return 15
    end

    return 0
end

function FloatAlert(alertStr, beginY)
    if alertStr == "" then
        return
    end

    beginY = beginY or 100

    local target = UIManagerInst:GetWindow(UIWindowNames.UIPromptMsg, true, true)
	if target then
        UIManagerInst:Broadcast(UIMessageNames.MN_ADD_PROMPT, alertStr, beginY)
    else
        UIManagerInst:OpenWindow(UIWindowNames.UIPromptMsg, alertStr, beginY)
	end
end

function PowerChange(changePower, beginY)
    if changePower == 0 then
        return
    end
    beginY = beginY or 250

    local target = UIManagerInst:GetWindow(UIWindowNames.UIPowerChange, true, true)
	if target then
        UIManagerInst:Broadcast(UIMessageNames.MN_POWER_CHANGE, changePower, beginY)
    else
        UIManagerInst:OpenWindow(UIWindowNames.UIPowerChange, changePower, beginY)
	end
end

function HandleResult(result)
    if result <= 0 then
        return
    end

    UIManagerInst:Broadcast(UIMessageNames.MN_ERROR_CODE, result)
    FloatAlert(ErrorCode.GetString(result))
end

function IsNormalItem(itemMainType)
    return (itemMainType == CommonDefine.ItemMainType_MingQian or 
            itemMainType == CommonDefine.ItemMainType_XinWu or
            itemMainType == CommonDefine.ItemMainType_LiBao or
            itemMainType == CommonDefine.ItemMainType_ShenBing or 
            itemMainType == CommonDefine.ItemMainType_OtherItem)
end

function CanItemLock(itemMainType)
    return (itemMainType == CommonDefine.ItemMainType_MingQian or 
            itemMainType == CommonDefine.ItemMainType_ShenBing or 
            itemMainType == CommonDefine.ItemMainType_Mount)
end

function SetLockImage(icon, isLock)
    if icon then
        if isLock then
            icon:SetAtlasSprite("ty81.png")
        else
            icon:SetAtlasSprite("ty80.png")
        end
    end
end

--根据竞技场名次，返回相应的奖励列表
function GetArenaAwardListByRank(rank, rank_dan)
    local tbl = ConfigUtil.GetArenaAwardDict()
    local arenaAwardInfo = nil
    for id, info in pairs(tbl) do
        if info and info.dan == rank_dan and rank <= info.rank_floor and rank >= info.rank_ceil then
            arenaAwardInfo = info
            break
        end
    end
    local award_list_count = 0
    local award_list = {}
    if arenaAwardInfo then
        for i = 1, 6 do
            local award_id = arenaAwardInfo["award_id"..i]
            local award_count = arenaAwardInfo["award_count"..i]
            if award_id > 0 and award_count > 0 then
                if not award_list[award_id] then
                    award_list_count = award_list_count + 1
                    award_list[award_id] = award_count
                else
                    Logger.LogError("award_id"..i.." repeat : "..award_id)
                end
            end
        end
    end
    return award_list, award_list_count
end

--设置前三名的文字图标
function SetNumSpt(icon, num, setNativeSize)
    if icon then
        if num == 1 then
            icon:SetAtlasSprite("ph03.png", setNativeSize)
        elseif num == 2 then
            icon:SetAtlasSprite("ph04.png", setNativeSize)
        elseif num == 3 then
            icon:SetAtlasSprite("ph05.png", setNativeSize)
        end
    end
end

--军团名(为空则返回:无军团)
--name_color 军团名的颜色，格式为:<color=#27a5ec>%s</color>, 默认颜色为蓝色
function GetCorrectGuildName(guild_name, name_color)
    local name = guild_name
    if not name or #name == 0 then
        name = Language.GetString(2214)
    else
        if name_color and #name_color > 0 then
            name = string_format(name_color, name)
        else
            name = string_format(Language.GetString(2215), name)
        end
    end
    return name
end

function GetInscriptionDesc(itemID)
    local inscriptionStageInfo = ConfigUtil.GetInscriptionStageCfgByID(itemID)
    if inscriptionStageInfo then
        for k, v in pairs(inscriptionStageInfo) do
            local attrtype = CommonDefine[k]
            if attrtype and v > 0 then
                return Language.GetString(attrtype + 10).."+"..GetWuJiangSecondAttrVal(k, v)
            end
        end
    end

    return ""
end

function GetInscriptionStage(itemID)
    local stage = math_floor(itemID / 100 % 10)
    return stage
end

function FindLayerName(transform)
    if transform then
        local canvasScaler = transform:GetComponentInParent(Type_CanvasScaler)
        if canvasScaler then
            local layerName = canvasScaler.gameObject.name
            return layerName
        end
    end
end

function GetStarCfgListByLayer(layer)
    local starCfgList = {}
    local tbl = ConfigUtil.GetStarCfgList()
    if tbl then
        for k, v in pairs(tbl) do
            if v and v.star_layer == layer then
                table_insert(starCfgList, v)
            end
        end
    end
    return starCfgList
end

function GetStarCfgMaxLayer()
    local maxLayer = 0
    local tbl = ConfigUtil.GetStarCfgList()
    if tbl then
        for k, v in pairs(tbl) do
            if v and v.star_layer > maxLayer then
                maxLayer = v.star_layer
            end
        end
    end
    return maxLayer
end

function GetMaxStarLayerAndIndex(star_makeid_list)
    local maxLayer = 1
    local maxIndex = 0
    local maxMakeID = 0
    if star_makeid_list then
        for makeid, _ in pairs(star_makeid_list) do
            if maxMakeID < makeid then
                maxMakeID = makeid
            end
        end
    end
    if maxMakeID > 0 then
        maxLayer = math_floor(maxMakeID / 100)
        maxIndex = math_floor(maxMakeID % 100)
    end
    return maxLayer, maxIndex
end

--获取群雄逐鹿奖励宝箱ID
function GetBoxInfoByScore(score)
    local saichangCfgList = ConfigUtil.GetGroupHerosSaichangCfgList()
    if saichangCfgList then
        for i, v in pairs(saichangCfgList) do
            if score >= v.score_min and score <= v.score_max then
                return v.box_id, v.box_name
            end
        end
    end
    
    return nil, nil
end

--获取下一阶群雄逐鹿奖励宝箱ID
function GetNextBoxInfoByScore(score)
    local saichangCfgList = ConfigUtil.GetGroupHerosSaichangCfgList()
    if saichangCfgList then
        for i, v in pairs(saichangCfgList) do
            if score >= v.score_min and score <= v.score_max then
                if saichangCfgList[i + 1] then
                    return saichangCfgList[i + 1].box_id, saichangCfgList[i + 1].box_name
                else
                    return nil, nil
                end
            end
        end
    end
    
    return nil, nil
end

--获取军衔图片和军衔名
function GetJunxianImgByScore(score)
    local junxianCfgList = ConfigUtil.GetGroupHerosJunxianCfgList()
    if junxianCfgList then
        for i, v in pairs(junxianCfgList) do
            if score >= v.score_min and score <= v.score_max then
                return v.image_name..".png", v.name
            end
        end
    end
    return nil, nil
end

--获取当前赛季逐鹿币上限
function GetGroupHerosCoinsLimitByScore(score)
    local junxianCfgList = ConfigUtil.GetGroupHerosJunxianCfgList()
    if junxianCfgList then
        for i, v in pairs(junxianCfgList) do
            if score >= v.score_min and score <= v.score_max then
                return v.zhuluitem_limit
            end
        end
    end
    return nil
end

--获取赛场信息
function GetSaichangInfoByScore(score)
    local saichangCfgList = ConfigUtil.GetGroupHerosSaichangCfgList()
    if saichangCfgList then
        for i, v in pairs(saichangCfgList) do
            if score >= v.score_min and score <= v.score_max then
                return v.image_name..".png", v.competition_name
            end
        end
    end
    return nil, nil
end

--获得星盘配置的宝箱奖励
function GetStarBoxAwardList(starItemCfg)
    if not starItemCfg then
        return
    end
    local awardList = {}
    local awardCount = 0
    if starItemCfg.item_id1 > 0 and starItemCfg.item_count1 > 0 then
        awardList[starItemCfg.item_id1] = starItemCfg.item_count1
        awardCount = awardCount + 1
    end
    if starItemCfg.item_id2 > 0 and starItemCfg.item_count2 > 0 then
        awardList[starItemCfg.item_id2] = starItemCfg.item_count2
        awardCount = awardCount + 1
    end
    return awardList, awardCount
end

function GetChineseNumByArabNum(num)
    local str = Language.GetString(60)
    local arr = string_split(str, ",")
    return arr[num]
end

function GetStarCfgItemPos(starItemCfg)
    local starItemPos = Vector3.zero
    if starItemCfg and starItemCfg.star_pos then
        local posStrArr = string_split(starItemCfg.star_pos, "|")
        if posStrArr and #posStrArr >= 2 then
            local posX = tonumber(posStrArr[1])
            local posY = tonumber(posStrArr[2])
            starItemPos = Vector3.New(posX, posY, 0)
        end
    end
    return starItemPos
end

function GetStarCfgBoxOffset(starItemCfg)
    local posOffset = Vector3.New(0, 135, 0)
    if starItemCfg and starItemCfg.box_offset and string_len(starItemCfg.box_offset) > 0 then
        local posStrArr = string_split(starItemCfg.box_offset, "|")
        if posStrArr and #posStrArr >= 2 then
            local posX = tonumber(posStrArr[1])
            local posY = tonumber(posStrArr[2])
            posOffset = Vector3.New(posX, posY, 0)
        end
    end
    return posOffset
end

function GetFiledNameByBattleAttrType(attrType)
    local filedName = nil
    if attrType == CommonDefine.max_hp then
        filedName = "max_hp"
    elseif attrType == CommonDefine.phy_atk then
        filedName = "phy_atk"
    elseif attrType == CommonDefine.phy_def then
        filedName = "phy_def"
    elseif attrType == CommonDefine.magic_atk then
        filedName = "magic_atk"
    elseif attrType == CommonDefine.magic_def then
        filedName = "magic_def"
    elseif attrType == CommonDefine.phy_baoji then
        filedName = "phy_baoji"
    elseif attrType == CommonDefine.magic_baoji then
        filedName = "magic_baoji"
    elseif attrType == CommonDefine.shanbi then
        filedName = "shanbi"
    elseif attrType == CommonDefine.mingzhong then
        filedName = "mingzhong"
    elseif attrType == CommonDefine.move_speed then
        filedName = "move_speed"
    elseif attrType == CommonDefine.atk_speed then
        filedName = "atk_speed"
    elseif attrType == CommonDefine.hp_recover then
        filedName = "hp_recover"
    elseif attrType == CommonDefine.nuqi_recover then
        filedName = "nuqi_recover"
    elseif attrType == CommonDefine.init_nuqi then
        filedName = "init_nuqi"
    elseif attrType == CommonDefine.baoji_hurt then
        filedName = "baoji_hurt"
    elseif attrType == CommonDefine.phy_suckblood then
        filedName = "phy_suckblood"
    elseif attrType == CommonDefine.magic_suckblood then
        filedName = "magic_suckblood"
    elseif attrType == CommonDefine.reduce_cd then
        filedName = "reduce_cd"
    end
    return filedName
end

function SetItemCountText(itemCountText, itemCount, limit, enoughStrID)
    enoughStrID = enoughStrID or 79
    if itemCount >= limit then
        itemCountText.text = string_format(Language.GetString(enoughStrID), itemCount, limit)
    else
        itemCountText.text = string_format(Language.GetString(80), itemCount, limit)
    end
end

function GetInscriptionEquipCount(tupo)
    local inscriptionEquipCount = 6
    if tupo == 15 then
        inscriptionEquipCount = 9
    elseif tupo >= 9 then
        inscriptionEquipCount = 8
    elseif tupo >=3 then
        inscriptionEquipCount = 7
    end
    return inscriptionEquipCount
end

function IsSysOpen(sysID, isShopTips)
    local sysOpenCfg = ConfigUtil.GetSysopenCfgByID(sysID)
    if sysOpenCfg then
        local Player = Player:GetInstance()
        if sysOpenCfg.openType == SysOpenType.Level then
            if Player:GetUserMgr():GetUserData().level >= sysOpenCfg.openValue then
                return true
            end
        elseif sysOpenCfg.openType == SysOpenType.GetDragon then
            local godBeasdMgr = Player:GetGodBeastMgr()
            local dragonList = table_keys(ConfigUtil.GetGodBeastCfgList())
            for i,id in ipairs(dragonList) do
                if id == sysOpenCfg.openValue then
                    local dragonData = godBeasdMgr:GetGodBeastByID(id)
                    if dragonData then
                        return true
                    end
                end
            end
        elseif sysOpenCfg.openType == SysOpenType.CopyBeClear then
            if Player:GetMainlineMgr():IsCopyClear(sysOpenCfg.openValue) then
                return true
            end
        elseif sysOpenCfg.openType == SysOpenType.GuildLevel then
            local guildLv = Player:GetUserMgr():GetUserData().guild_level or 0
            if guildLv >= sysOpenCfg.openValue then
                return true
            end
        elseif sysOpenCfg.openType == SysOpenType.StarPanelLevel then
            if Player:GetUserMgr():CheckStarIsActive(sysOpenCfg.openValue) then
                return true
            end 
        end
        if isShopTips then
            UILogicUtil.FloatAlert(sysOpenCfg.sDesc)
        end
    end
    
    return false
end

function SysShowUI(sysID, ...)
    if not UILogicUtil.IsSysOpen(sysID, true) then
        return
    end
 
    if sysID == SysIDs.ROLE_BAG then
        --执行引导时，不记录UI
        local isGuideZuoqi = GuideMgr:GetInstance():IsPlayingGuide(GuideEnum.GUIDE_ZUOQI)
        local isGuideShenBing3 = GuideMgr:GetInstance():IsPlayingGuide(GuideEnum.GUIDE_SHENBING3)
        if isGuideZuoqi or isGuideShenBing3 then
            UIConfig[UIWindowNames.UIWuJiangList].OpenMode = CommonDefine.UI_OPEN_MODE_NONE
        end

        UIManagerInst:OpenWindow(UIWindowNames.UIWuJiangList, true)
    elseif sysID == SysIDs.ITEM_BAG then
        UIManagerInst:OpenWindow(UIWindowNames.UIBag)

    elseif sysID == SysIDs.STAR_PANEL then
        UIManagerInst:OpenWindow(UIWindowNames.UIStarPanel)

    elseif sysID == SysIDs.CHAT then
        UIManagerInst:OpenWindow(UIWindowNames.UIChatMain)

    elseif sysID == SysIDs.FRIEND then
        UIManagerInst:OpenWindow(UIWindowNames.UIFriendMain)
        
    elseif sysID == SysIDs.GUILD then
        Player:GetInstance().GuildMgr:ReqOpenGuild()

    elseif sysID == SysIDs.CAMPS_RUSH then
        UIManagerInst:OpenWindow(UIWindowNames.UICampsRush)

    elseif sysID == SysIDs.ARENA then
        UIManagerInst:OpenWindow(UIWindowNames.UIArenaMain)

    elseif sysID == SysIDs.EMAIL then
        local msg_id = MsgIDDefine.MAIL_REQ_MAIL_LIST
	    local msg = (MsgIDMap[msg_id])()
        HallConnector:GetInstance():SendMessage(msg_id, msg)
        
    elseif sysID == SysIDs.SHENBING_COPY then
        UIManagerInst:OpenWindow(UIWindowNames.UIShenbingCopy)

    elseif sysID == SysIDs.INSCRIPTION_COPY then
        UIManagerInst:OpenWindow(UIWindowNames.UIInscriptionCopy)

    elseif sysID == SysIDs.GRAVE_COPY then
        UIManagerInst:OpenWindow(UIWindowNames.UIGraveCopy)

    elseif sysID == SysIDs.FULI then
        UIManagerInst:OpenWindow(UIWindowNames.UIFuli)

    elseif sysID == SysIDs.ZHUANPAN then
        if not Player:GetInstance():GetActMgr():IsTurnTableOpen() then
            UILogicUtil.FloatAlert(Language.GetString(3465))
            UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_ICON_REFRESH)
            return
        end
        GameObjectPoolInst:GetGameObjectAsync(TheGameIds.DuoBaoSceneObjPrefab, function(go)
            if go then 
                UIManagerInst:OpenWindow(UIWindowNames.UIActTurntable, go)
            end
        end)  

    elseif sysID == SysIDs.ACTIVITY then
        UIManagerInst:OpenWindow(UIWindowNames.UIActivity)

    elseif sysID == SysIDs.QUNXIONGZHULU then
        UIManagerInst:OpenWindow(UIWindowNames.UIGroupHerosWar)
       
    elseif sysID == SysIDs.SHEN_BING then
        UIManagerInst:OpenWindow(UIWindowNames.UIShenBing)

    elseif sysID == SysIDs.FIGHTWAR_NANZHENG then
        UIManagerInst:OpenWindow(UIWindowNames.UIFightWar, ...)

    elseif sysID == SysIDs.FIGHTWAR_WORLDBOSS then
        UIManagerInst:OpenWindow(UIWindowNames.UIWorldBoss)

    elseif sysID == SysIDs.COPY_NORMAL or sysID == SysIDs.COPY_ELITE then
        local mainlineMgr = Player:GetInstance():GetMainlineMgr()
        if sysID == SysIDs.COPY_ELITE and not mainlineMgr:IsEliteUnlock() then
            UILogicUtil.FloatAlert(Language.GetString(2633))
            return 
        end
		local normalSectionID = mainlineMgr:GetLatestSectionIndex(CommonDefine.SECTION_TYPE_NORMAL)
		local eliteSectionID = mainlineMgr:GetLatestSectionIndex(CommonDefine.SECTION_TYPE_ELITE)
		mainlineMgr:SetUIData(normalSectionID, eliteSectionID, sysID == SysIDs.COPY_NORMAL and CommonDefine.SECTION_TYPE_NORMAL or CommonDefine.SECTION_TYPE_ELITE)
        UIManagerInst:OpenWindow(UIWindowNames.UIMainline, ...)

    elseif sysID == SysIDs.FIGHTWAR_YUANMEN then
        GameObjectPoolInst:GetGameObjectAsync(TheGameIds.YuanmenSceneObjPrefab, function(go)
            if go then
                UIManagerInst:OpenWindow(UIWindowNames.UIYuanmen, go)
            end
        end)

    elseif sysID == SysIDs.DIANJIANGTAI then
        UIManagerInst:OpenWindow(UIWindowNames.UIDianJiangMain)
        
    elseif sysID == SysIDs.SHOP then
        UIManagerInst:OpenWindow(UIWindowNames.UIShop, CommonDefine.SHOP_SPECIAL)
        
    elseif sysID == SysIDs.HUNT then
        UIManagerInst:OpenWindow(UIWindowNames.UIHunt)

    elseif sysID == SysIDs.GOD_BEAST then
        UIManagerInst:OpenWindow(UIWindowNames.UIGodBeast)

    elseif sysID == SysIDs.FIGHTWAR_SHENSHOU then
        UIManagerInst:OpenWindow(UIWindowNames.UIDragonCopyMain) 

    elseif sysID == SysIDs.GUILD_WAR then
       -- UIManagerInst:OpenWindow(UIWindowNames.UIGuildWarMain)
        Player:GetInstance().GuildMgr:ReqGuildDetail(2)

    elseif sysID == SysIDs.LIEZHUAN then
        UIManagerInst:OpenWindow(UIWindowNames.UILieZhuan)

    elseif sysID == SysIDs.SHANG_CHENG then
        UIManagerInst:OpenWindow(UIWindowNames.UIVipShop)

    elseif sysID == SysIDs.INSCRIPTION then
        UIManagerInst:OpenWindow(UIWindowNames.UIWuJiangInscription, ...)

    elseif sysID == SysIDs.SHOU_CHONG then 
        UIManagerInst:OpenWindow(UIWindowNames.UIShouChong) 

    elseif sysID == SysIDs.SEVEN_DAYS then
        UIManagerInst:OpenWindow(UIWindowNames.UISevenDays)

    elseif sysID == SysIDs.YUE_KA then 
        UIManagerInst:OpenWindow(UIWindowNames.UIYueKa)    

    elseif sysID == SysIDs.JIXINGGAOZHAO then
        if not Player:GetInstance():GetActMgr():IsJiXingGaoZhaoOpen() then
            UILogicUtil.FloatAlert(Language.GetString(3465))
            UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_ICON_REFRESH)
            return
        end
        UIManagerInst:OpenWindow(UIWindowNames.UIActJiXingGaoZhao)  
        
    elseif sysID == SysIDs.DUOBAO then
        if not Player:GetInstance():GetActMgr():IsDuoBaoOpen() then
            UILogicUtil.FloatAlert(Language.GetString(3465))
            UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_ICON_REFRESH)
            return
        end 
        GameObjectPoolInst:GetGameObjectAsync(TheGameIds.DuoBaoSceneObjPrefab, function(go)
            if go then
                local duobaoData = Player:GetInstance():GetActMgr():GetDuoBaoData()
                UIManagerInst:OpenWindow(UIWindowNames.UIDuoBao, duobaoData, go)
            end
        end) 

    elseif sysID == SysIDs.HORSERACE then
        UIManagerInst:OpenWindow(UIWindowNames.UIHorseRaceMain)
    elseif sysID == SysIDs.DOWNLOAD then
        if Player:GetInstance():GetUserMgr():IsTakeDownloadAward() then
            local msg = string_format(Language.GetString(4208), UIUtil.KBSizeToString(AssetBundleMgrInst:GetAllNeedDownloadABSize()))
            UIManagerInst:OpenWindow(UIWindowNames.UINormalTipsDialog, Language.GetString(9),msg, Language.GetString(4200), function()
                if Application.internetReachability == NetworkReachability.ReachableViaLocalAreaNetwork then
                    UIManagerInst:OpenWindow(UIWindowNames.UIDownloadDialog)
                else
                    UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(9),Language.GetString(4202), Language.GetString(10), function()
                        UIManagerInst:OpenWindow(UIWindowNames.UIDownloadDialog)
                    end, Language.GetString(50))
                end
            end, Language.GetString(50))
        else
            UIManagerInst:OpenWindow(UIWindowNames.UIDownloadTipsDialog)
        end
    elseif sysID == SysIDs.LIEZHUAN_WEI then
        GameObjectPoolInst:GetGameObjectAsync(TheGameIds.LieZhuanSceneObjPath, function(go)
            if go then
                UIManagerInst:OpenWindow(UIWindowNames.UILieZhuanChoose, CommonDefine.COUNTRY_1, go)
            end
        end)
    elseif sysID == SysIDs.LIEZHUAN_SHU then
        GameObjectPoolInst:GetGameObjectAsync(TheGameIds.LieZhuanSceneObjPath, function(go)
            if go then
                UIManagerInst:OpenWindow(UIWindowNames.UILieZhuanChoose, CommonDefine.COUNTRY_2, go)
            end
        end)
    elseif sysID == SysIDs.LIEZHUAN_WU then
        GameObjectPoolInst:GetGameObjectAsync(TheGameIds.LieZhuanSceneObjPath, function(go)
            if go then
                UIManagerInst:OpenWindow(UIWindowNames.UILieZhuanChoose, CommonDefine.COUNTRY_3, go)
            end
        end)
    elseif sysID == SysIDs.LIEZHUAN_QUN then
        GameObjectPoolInst:GetGameObjectAsync(TheGameIds.LieZhuanSceneObjPath, function(go)
            if go then
                UIManagerInst:OpenWindow(UIWindowNames.UILieZhuanChoose, CommonDefine.COUNTRY_4, go)
            end
        end)
    elseif sysID == SysIDs.HORSE then
        -- UIManagerInst:OpenWindow(UIWindowNames.UIWuJiangDetail, 1, false)
        UIManagerInst:OpenWindow(UIWindowNames.UIWuJiangList)

    elseif sysID == SysIDs.GUILD_BOSS then
        GameObjectPoolInst:GetGameObjectAsync(TheGameIds.GuildBossBgPath, function(go)
            if go then
                UIManagerInst:OpenWindow(UIWindowNames.UIGuildBoss, go)
            end
        end)
        
    elseif sysID == SysIDs.BUY_STRENGTH then
        local UserMgr = Player:GetInstance():GetUserMgr()
        local userData = UserMgr:GetUserData()
        local max_buy_stamina_count = ConfigUtil.GetVipPrivilegeValue(userData.vip_level, 'stamina_count')

        local data = {
                titleMsg = Language.GetString(2704),
                contentMsg = string_format(Language.GetString(2702), userData.today_buy_stamina_count, max_buy_stamina_count),
                yuanbao = string_format("%d",userData.next_buy_stamina_cost),
                buyCallback = Bind(UserMgr, UserMgr.ReqBuyStamina),
                currencyID = ItemDefine.Stamina_ID,
                currencyCount = 120,
            }           

        UIManagerInst:OpenWindow(UIWindowNames.UIBuyTipsDialog, data)
    elseif sysID == SysIDs.FRIEND_ASSITS then
        local isAssitsOpen = self:CheckAssitsTastIsOpen()
        if not isAssitsOpen then
            UILogicUtil.FloatAlert(Language.GetString(3073))
            return
        end
        UIManagerInst:OpenWindow(UIWindowNames.UIFriendTaskInvite)
    end
end

function CheckInputValueLegal(input_value, errLanguageID)
    if not input_value or string_len(input_value) <= 0 then
        if errLanguageID and type(errLanguageID) == "number" then
            UILogicUtil.FloatAlert(Language.GetString(errLanguageID))
        end
        return false
    end
    if GameUtility.RegulateTest(input_value, "\n") then
        UILogicUtil.FloatAlert(Language.GetString(63))
        return false
    end
    return true
end

function GetNameByItemID(id)
    if Utils.IsWujiang(id) then
        local wujiangCfg = ConfigUtil.GetWujiangCfgByID(id)
        if wujiangCfg then
            return wujiangCfg.sName
        end
    else
        local itemCfg = ConfigUtil.GetItemCfgByID(id)
        if itemCfg then
            return itemCfg.sName
        end
    end
    return ""
end

function GetLoginStateOrPassTime(lastLoginTime)
    lastLoginTime = lastLoginTime or 0
    local timeStr = lastLoginTime == 0 and Language.GetString(3011) or string_format(Language.GetString(3012), TimeUtil.GetTimePassStr(lastLoginTime))    
    return timeStr
end

function GetShenBingStageByLevel(level)
    local stage = 0
    if level < 5 then
        stage = CommonDefine.ItemStageType_1
    elseif level >= 5 and level < 10 then
        stage = CommonDefine.ItemStageType_2
    elseif level >= 10 and level < 15 then
        stage = CommonDefine.ItemStageType_3
    elseif level == 15 then
        stage = CommonDefine.ItemStageType_4
    end
    return stage
end

function GetWuJiangSecondAttrVal(attrField, val)
    if attrField == "baoji_hurt" or attrField == "phy_suckblood" or attrField == "magic_suckblood" or attrField == "reduce_cd" then
        val = val * 100
        if val == math_floor(val) then
            return string_format("%d%%", val)
        else
            return string_format("%s%%", math_round(val))
        end

    elseif attrField == "atk_speed" then
        return string_format("%d%%", val)
    end
    return string_format("%d", val)
end

function GetShenBingNameByStage(shenbingStage, shenbingCfg)
    if shenbingStage >= 0 and shenbingStage < 5 then
        return string_format(Language.GetString(2931), shenbingCfg.name1)
    elseif shenbingStage >= 5 and shenbingStage < 10 then
        return string_format(Language.GetString(2932), shenbingCfg.name2)
    elseif shenbingStage >= 10 and shenbingStage < 15 then
        return string_format(Language.GetString(2933), shenbingCfg.name3)
    elseif shenbingStage == 15 then
        return string_format(Language.GetString(2934), shenbingCfg.name4)
    else
        return ""
    end
end

function SetDragonIcon(icon, dragonID)
    if dragonID == 1003601 then
        icon:SetAtlasSprite("bz14.png")
    elseif dragonID == 1003606 then
        icon:SetAtlasSprite("bz12.png")
    elseif dragonID == 1003602 then
        icon:SetAtlasSprite("bz15.png")
    elseif dragonID == 1003603 then
        icon:SetAtlasSprite("bz13.png")
    end
end

function SetGuildPostImage(img, guildJob)
    if guildJob == 1 then
        img:SetAtlasSprite("jt09.png", false, AtlasConfig.DynamicLoad)
    elseif guildJob == 2 then
        img:SetAtlasSprite("jt08.png", false, AtlasConfig.DynamicLoad)
    elseif guildJob == 3 then
        img:SetAtlasSprite("jt10.png", false, AtlasConfig.DynamicLoad)
    elseif guildJob == 4 then
        img:SetAtlasSprite("realempty.tga", false, AtlasConfig.DynamicLoad)
    end
end

function ChangeSecondToTime(seconds)
    local timeText = ""
    if seconds >= 0 then
        local hour = seconds / 3600
        hour = math_floor(hour)
        seconds = seconds - hour * 3600
        local minute = seconds / 60
        minute = math_floor(minute)
        seconds = seconds - minute * 60
        local second = math_floor(seconds)
        timeText = string_format("%02d:%02d:%02d", hour, minute, second)
    else
        timeText = string_format("%02d:%02d:%02d", 0, 0, 0)
    end
    return timeText
end

function GetZuoQiNameByStage(stage, zuoqiCfg)
    if stage == CommonDefine.ItemStageType_1 then
        return string_format(Language.GetString(2931), zuoqiCfg.name1)
    elseif stage == CommonDefine.ItemStageType_2 then
        return string_format(Language.GetString(2932), zuoqiCfg.name2)
    elseif stage == CommonDefine.ItemStageType_3 then
        return string_format(Language.GetString(2933), zuoqiCfg.name3)
    elseif stage == CommonDefine.ItemStageType_4 then
        return string_format(Language.GetString(2934), zuoqiCfg.name4)
    elseif stage == CommonDefine.ItemStageType_5 then
        return string_format(Language.GetString(2936), zuoqiCfg.name5)
    else
        return ""
    end
end

function SetVipImage(vip, img1, img2)
    local tenNum = math_floor(vip / 10)
    img1.gameObject:SetActive(tenNum > 0)
    if tenNum > 0 then
        img1:SetAtlasSprite("zjm"..math_ceil(tenNum)..".png", true)
        img2.transform.localPosition = Vector3.New(63.3, -2.7)
    else
        img2.transform.localPosition = Vector3.New(35.4, -2.7)
    end
    local num = vip % 10
    img2:SetAtlasSprite("zjm"..math_ceil(num)..".png", true)
end

function GetMingWenDesc(index, mingwenID, washTimes)
    index = index or 1
    if not mingwenID then
        return string_format(Language.GetString(2914), index * 5)
    end

    local mingwenCfg = ConfigUtil.GetShenbingInscriptionCfgByID(mingwenID)
    if mingwenCfg then
        local nameList = CommonDefine.mingwen_second_attr_name_list
        local attrStr = ''
        for _, name in ipairs(nameList) do
            local hasPercent = true
            local val = mingwenCfg[name]
            if val and val > 0 then
                if name == "init_nuqi" then
                    hasPercent = false
                end
                local attrType = CommonDefine[name]
                if attrType then
                    local tempStr = nil
                    if hasPercent then
                        tempStr = Language.GetString(2910)
                        if i == 2 then
                            tempStr = Language.GetString(2911)
                        elseif i == 3 then
                            tempStr = Language.GetString(2912)
                        end
                    else
                        tempStr = Language.GetString(2942)
                        if i == 2 then
                            tempStr = Language.GetString(2943)
                        elseif i == 3 then
                            tempStr = Language.GetString(2944)
                        end
                    end
                    attrStr = attrStr..string_format(tempStr, Language.GetString(attrType + 10), val)
                end
            end
        end

        attrStr = attrStr..string_format(Language.GetString(2913), washTimes)
        return attrStr
    end
end

function WujiangIDToXinwuID(wujiangID)
    return 30000+wujiangID
end

function BindClick(obj, func, audioID)
    assert(obj ~= nil and type(obj) == "table")
	assert(func ~= nil and type(func) == "function")

    return function(...)
        if audioID then
            if audioID > 0 then                 
                AudioMgr:PlayUIAudio(audioID)
            end
        else
            local BIG_ENDING = '_BTN'
            local go, x, y = ...
            local btnName = go.name
            if btnName:sub(-#BIG_ENDING) == BIG_ENDING then
                -- print('big click')
                AudioMgr:PlayUIAudio(102)
            else
                -- print('small click')
                AudioMgr:PlayUIAudio(101)
            end
        end

        return func(obj, ...)
    end
end

-- int1 引导ID
function ReportGuideDetail(int1, int2, int3, str1, str2, str3)
    Player:GetInstance():GetUserMgr():ReqReportGuideDetail(int1, int2, int3, str1, str2, str3)
end

function GetGuildWarCityIcon(guild_brief)
    if guild_brief then
        local userData = Player:GetInstance():GetUserMgr():GetUserData()
        return guild_brief.gid == userData.guild_id and 'jtzb28.png' or 'jtzb29.png'
    end

    print('GetGuildWarCityIcon error guild_brief nil')
end

function GetWeaponMaxLevel(wujiangID)
    local level = 1 
    local cfg = ConfigUtil.GetWujiangCfgByID(wujiangID)
    if cfg then
        if cfg.rare == CommonDefine.WuJiangRareType_4 then
            level = 15
        elseif cfg.rare == CommonDefine.WuJiangRareType_3 then
            level = 10  
        end
    end
    return level
end

function GetCurMaxSliderValueByStars(star)
    local value = 0 
    if not star then
        return value
    end

    if star == 1 then
        value = 100
    elseif star == 2 then
        value = 110
    elseif star == 3 then
        value = 140
    elseif star == 4 then
        value = 180
    elseif star == 5 then
        value = 240
    elseif star == 6 then
        value = 350
    end

    return value
end

function CheckAssitsTastIsOpen()
    local isOpen = UILogicUtil.IsSysOpen(107)
    return isOpen
end

UILogicUtil.CheckAssitsTastIsOpen = CheckAssitsTastIsOpen 
UILogicUtil.ChangeCountToCountAndText = ChangeCountToCountAndText
UILogicUtil.SetWuJiangRareImage = SetWuJiangRareImage
UILogicUtil.SetWuJiangJobImage = SetWuJiangJobImage
UILogicUtil.GetWuJiangCountryName = GetWuJiangCountryName
UILogicUtil.GetWuJiangJobName = GetWuJiangJobName
UILogicUtil.SetItemFrameNormalImage = SetItemFrameNormalImage
UILogicUtil.SetItemFrameHighLightImage = SetItemFrameHighLightImage
UILogicUtil.SetItemBgNormalImage = SetItemBgNormalImage
UILogicUtil.SetItemBgHighLightImage = SetItemBgHighLightImage
UILogicUtil.SetItemLevelImage = SetItemLevelImage
UILogicUtil.SetMingQianBgImage = SetMingQianBgImage
UILogicUtil.CheckNeedHair = CheckNeedHair
UILogicUtil.CalcScreen = CalcScreen
UILogicUtil.GetSkillDesc = GetSkillDesc
UILogicUtil.SetWuJiangFrame = SetWuJiangFrame
UILogicUtil.SetWuJiangCountryImage = SetWuJiangCountryImage
UILogicUtil.GetTupoLimit = GetTupoLimit
UILogicUtil.FloatAlert = FloatAlert
UILogicUtil.PowerChange = PowerChange
UILogicUtil.HandleResult = HandleResult
UILogicUtil.IsNormalItem = IsNormalItem
UILogicUtil.CanItemLock = CanItemLock
UILogicUtil.SetLockImage = SetLockImage
UILogicUtil.GetArenaAwardListByRank = GetArenaAwardListByRank
UILogicUtil.SetNumSpt = SetNumSpt
UILogicUtil.GetCorrectGuildName = GetCorrectGuildName
UILogicUtil.GetArenaAwardListByAwardType = GetArenaAwardListByAwardType
UILogicUtil.GetInscriptionDesc = GetInscriptionDesc
UILogicUtil.GetInscriptionStage = GetInscriptionStage
UILogicUtil.FindLayerName = FindLayerName
UILogicUtil.GetStarCfgListByLayer = GetStarCfgListByLayer
UILogicUtil.GetStarBoxAwardList = GetStarBoxAwardList
UILogicUtil.GetStarCfgMaxLayer = GetStarCfgMaxLayer
UILogicUtil.GetChineseNumByArabNum = GetChineseNumByArabNum
UILogicUtil.GetStarCfgItemPos = GetStarCfgItemPos
UILogicUtil.GetStarCfgBoxOffset = GetStarCfgBoxOffset
UILogicUtil.GetMaxStarLayerAndIndex = GetMaxStarLayerAndIndex
UILogicUtil.GetJunxianImgByScore = GetJunxianImgByScore
UILogicUtil.GetBoxInfoByScore = GetBoxInfoByScore
UILogicUtil.GetNextBoxInfoByScore = GetNextBoxInfoByScore
UILogicUtil.GetGroupHerosCoinsLimitByScore = GetGroupHerosCoinsLimitByScore
UILogicUtil.GetSaichangInfoByScore = GetSaichangInfoByScore
UILogicUtil.GetFiledNameByBattleAttrType = GetFiledNameByBattleAttrType
UILogicUtil.SetItemCountText = SetItemCountText
UILogicUtil.GetInscriptionEquipCount = GetInscriptionEquipCount
UILogicUtil.SysShowUI = SysShowUI
UILogicUtil.CheckInputValueLegal = CheckInputValueLegal
UILogicUtil.GetLoginStateOrPassTime = GetLoginStateOrPassTime
UILogicUtil.GetNameByItemID = GetNameByItemID
UILogicUtil.GetShenBingStageByLevel = GetShenBingStageByLevel
UILogicUtil.GetWuJiangSecondAttrVal = GetWuJiangSecondAttrVal
UILogicUtil.GetShenBingNameByStage = GetShenBingNameByStage
UILogicUtil.SetDragonIcon = SetDragonIcon
UILogicUtil.SetGuildPostImage = SetGuildPostImage
UILogicUtil.ChangeSecondToTime = ChangeSecondToTime
UILogicUtil.GetZuoQiNameByStage = GetZuoQiNameByStage
UILogicUtil.GetMingWenDesc = GetMingWenDesc
UILogicUtil.SetVipImage = SetVipImage
UILogicUtil.IsSysOpen = IsSysOpen
UILogicUtil.WujiangIDToXinwuID = WujiangIDToXinwuID
UILogicUtil.ReportGuideDetail = ReportGuideDetail
UILogicUtil.BindClick = BindClick
UILogicUtil.GetGuildWarCityIcon = GetGuildWarCityIcon
UILogicUtil.GetWeaponMaxLevel = GetWeaponMaxLevel
UILogicUtil.GetCurMaxSliderValueByStars = GetCurMaxSliderValueByStars

return UILogicUtil