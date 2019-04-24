local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local FixDiv = FixMath.div

SummonEnum = {
    SUMMON_JIAOTU = 93500,
    SUMMON_SUANNI = 93501,
    SUMMON_TAOTIE = 93502,
    SUMMON_YAZI   = 93505,
    SUMMON_CHIWEN = 93506,

    SUMMON_ACTOR_ID_OFFSET = 6000,

    TALENT_SKILL_YINGKE = 1,
    TALENT_SKILL_ZENGSHANG = 2,
    TALENT_SKILL_ZHINU = 3,
    TALENT_SKILL_BAONU = 4,
    TALENT_SKILL_ZHENGFEN = 5,
    TALENT_SKILL_XUNJIE = 6,
    TALENT_SKILL_JINDUN = 7,
    TALENT_SKILL_QINJIN = 8,
    TALENT_SKILL_CHIHUAN = 9,
    TALENT_SKILL_FANTAN = 10,
    TALENT_SKILL_DAIZHI = 11,
    TALENT_SKILL_ZHONGLIAO = 12,
    TALENT_SKILL_SHOUGU = 13,
    TALENT_SKILL_SHOUJIAO = 14,
    TALENT_SKILL_SHOUYU = 15,
    TALENT_SKILL_SHOUXUE = 16,
}

SummonUtil = {
    GetExtraSkillArray = function(summonCfg)
        local extraSkillDataArray = {}
        extraSkillDataArray[0] = {
            skillId = summonCfg.extra_skill_id1,
            skillName = summonCfg.extra_skill_name1,
            openLevel = summonCfg.open_level1,
            skillX = summonCfg.extra_skill_x1,
            skillY = summonCfg.extra_skill_y1
        }
        extraSkillDataArray[0] = {
            skillId = summonCfg.extra_skill_id2,
            skillName = summonCfg.extra_skill_name2,
            openLevel = summonCfg.open_level2,
            skillX = summonCfg.extra_skill_x2,
            skillY = summonCfg.extra_skill_y2
        }
        extraSkillDataArray[0] = {
            skillId = summonCfg.extra_skill_id3,
            skillName = summonCfg.extra_skill_name3,
            openLevel = summonCfg.open_level3,
            skillX = summonCfg.extra_skill_x3,
            skillY = summonCfg.extra_skill_y3
        }
        extraSkillDataArray[0] = {
            skillId = summonCfg.extra_skill_id4,
            skillName = summonCfg.extra_skill_name4,
            openLevel = summonCfg.open_level4,
            skillX = summonCfg.extra_skill_x4,
            skillY = summonCfg.extra_skill_y4
        }
        return extraSkillDataArray
    end,

    X = function(summonCfg, level)
        local level = FixSub(level, 1)
        local delta = FixMul(summonCfg.ax, level)
        return FixAdd(summonCfg.x, delta)
    end,

    Y = function(summonCfg, level)
        local level = FixSub(level, 1)
        local delta = FixMul(summonCfg.ay, level)
        return FixAdd(summonCfg.y, delta)
    end,

    Z = function(summonCfg, level)
        local level = FixSub(level, 1)
        local delta = FixMul(summonCfg.az, level)
        return FixAdd(summonCfg.z, delta)
    end,
}