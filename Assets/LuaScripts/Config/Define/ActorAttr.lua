local ACTOR_ATTR = {
    
    FIRST_TONGBING = 1,                     -- 统兵
    FIRST_WULI = 2,                         -- 武力
    FIRST_ZHILI = 3,                        -- 智力
    FIRST_FANGYU = 4,                       -- 防御

    -- 基础属性
    BASE_START = 6,
    BASE_MAXHP = 6,		                    -- 最大血量
    BASE_PHY_ATK = 7,                       -- 物攻
    BASE_PHY_DEF = 8,                       -- 物防
    BASE_MAGIC_ATK = 9,                     -- 魔攻
    BASE_MAGIC_DEF = 10,                    -- 魔防
    BASE_PHY_BAOJI = 11,                    -- 物理暴击
    BASE_MAGIC_BAOJI = 12,                  -- 魔法暴击
    BASE_SHANBI = 13,                       -- 闪避
    BASE_MINGZHONG = 14,                    -- 命中
    BASE_MOVESPEED = 15,                    -- 移动速度
    BASE_ATKSPEED = 16,                     -- 攻击速度
    BASE_HP_RECOVER = 17,                   -- 生命回复
    BASE_NUQI_RECOVER = 18,                 -- 怒气回复
    BASE_INIT_NUQI = 19,                    -- 初始怒气
    BASE_BAOJI_HURT = 20,                   -- 暴伤
    BASE_PHY_SUCKBLOOD = 21,                -- 物理吸血
    BASE_MAGIC_SUCKBLOOD = 22,              -- 魔法吸血
    BASE_REDUCE_CD = 23,                    -- 冷却缩减
    BASE_END = 24,

    -- 战斗属性
    FIGHT_START = 25,
    FIGHT_HP = 25,			                -- 血量
    FIGHT_MAXHP = 26,			            -- 最大血量
    FIGHT_PHY_ATK = 27,                     -- 物攻
    FIGHT_PHY_DEF = 28,                     -- 物防
    FIGHT_MAGIC_ATK = 29,                   -- 魔攻
    FIGHT_MAGIC_DEF = 30,                   -- 魔防
    FIGHT_PHY_BAOJI = 31,                   -- 物理暴击
    FIGHT_MAGIC_BAOJI = 32,                 -- 魔法暴击
    FIGHT_SHANBI = 33,                      -- 闪避
    FIGHT_MINGZHONG = 34,                   -- 命中
    FIGHT_MOVESPEED = 35,                   -- 移动速度
    FIGHT_ATKSPEED = 36,                    -- 攻击速度
    FIGHT_HP_RECOVER = 37,                  -- 生命回复
    FIGHT_NUQI_RECOVER = 38,                -- 怒气回复
    FIGHT_BAOJI_HURT = 39,                  -- 暴伤
    FIGHT_PHY_SUCKBLOOD = 40,               -- 物理吸血
    FIGHT_MAGIC_SUCKBLOOD = 41,             -- 魔法吸血
    FIGHT_REDUCE_CD = 42,                   -- 冷却缩减
    FIGHT_END = 43,

    PROB_MIN = 50,
    PHY_HURTOTHER_MULTIPLE = 51,             -- 物理伤人结果修改倍数
    MAGIC_HURTOTHER_MULTIPLE = 52,           -- 法术伤人结果修改倍数
    PHY_BEHURT_MULTIPLE = 53,                -- 物理受伤结果修改倍数
    MAGIC_BEHURT_MULTIPLE = 54,              -- 法术受伤结果修改倍数
    MINGZHONG_PROB_CHG = 55,                 -- 命中率修改
    SNAHBI_PROB_CHG = 56,                    -- 闪避率修改
    PHY_BAOJI_PROB_CHG = 57,                 -- 物理暴击率修改
    MAGIC_BAOJI_PROB_CHG = 58,              -- 法术暴击率修改
    PROB_MAX = 59,

    BOSS_HANDTYPE_LEFT = 1,                      -- 混沌左手
    BOSS_HANDTYPE_RIGHT = 2, 

    HURT_OTHER_END_DOWN = 1,
    HURT_OTHER_END_UP = 2,
    BE_HURT_END_DOWN = 3,
    BE_HURT_END_UP = 4,

    IsFightAttr = function(attr)
        if attr >= ACTOR_ATTR.FIGHT_START and attr < ACTOR_ATTR.FIGHT_END then
            return true
        else
            return false
        end
    end,

    IsBaseAttr = function(attr)
        if attr >= ACTOR_ATTR.BASE_START and attr < ACTOR_ATTR.BASE_END then
            return true
        else
            return false
        end
    end,

    IsProbAttr = function(attr)
        if attr >= ACTOR_ATTR.PROB_MIN and attr < ACTOR_ATTR.PROB_MAX then
            return true
        else
            return false
        end
    end,
}

return ACTOR_ATTR