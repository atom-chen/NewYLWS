-- Timeline模板
-- 注意修改lua文件名，当前是lua_timelineTemplate.lua,需要将其中的Template替换成对应的timeline名字，这个名字要唯一，不能和其他timeline重复
-- 比如召唤兽3506，文件名是lua_timelineSummon3506.lua,其他表配置使用哪个timeline时，将Summon3506配置进去即可。
-- 所有参数如果不需要，就设置为false
local config = {
    -- timeline预设的路径
    path = '',
    -- timeline对应的资源文件路径
    assetPath = '',
    -- language配置文件名
    plotLanguage = '',
    -- timeline需要设置参数的轨道列表，有多个用“，”分割
    track_list = {
        {
            -- 轨道的名字，不要跟当前timeline的其他轨道重名
            name = "",
            -- 绑定对象类型，
            -- 0：不用绑定对象
            -- 1：预设 动态加载预设，参数：bindingPath字段需要填预设路径,bindingPos字段是对象位置,bindingRotation字段是对象旋转
            -- 2：武将 在当前战斗角色中找到该武将，参数：bindingWujiangCamp字段填阵营（1左边2右边），bindingWujiangID武将ID
            -- 3：相机 参数：暂时不用填，目前就一个相机
            -- 4: timeline对象child 参数：bindingPath相对路径，在当前timeline预设下寻找
            -- 5：武将 动态加载武将，参数：bindingZhuZhanParam字段填助战参数，格式：{怪物ID, 怪物技能等级, 怪物等级, 怪物品阶, 怪物武器等级}
            bindingType = 0,
            bindingPath = false,
            bindingPos = false,
            bindingRotation = false,
            bindingWujiangCamp = false,
            bindingWujiangID = false,
            bindingZhuZhanParam = false,
            -- clip类型
            -- 0：啥都不干
            -- 1：特效
            -- 2：相机
            clipingType = 0,
            -- 当前轨道内需要设置参数的clip，有多个用，分割
            clip_list = {
                -- clip名字，当前timeline内唯一
                ["name"] = {
                    -- 父对象类型
                    -- 1 动画轨迹绑定对象 参数：trackName 动画轨迹名字，prefabPath 特效预设路径
                    -- 2 相机 参数：会额外设置instancePos和instanceRotation， prefabPath 特效预设路径
                    -- 3 timeline对象 参数：relativePath相对路径，在当前timeline预设下寻找， prefabPath 特效预设路径
                    -- 4 战斗武将，参数：wujiangID, camp填阵营（1左边2右边）, 说明：只适合该武将在战斗中只有一个的情况
                    parentType = 3,
                    relativePath = "",
                    trackName = false,
                    wujiangID = 0,
                    camp = 0,
                    -- 当前clip要用到的预设路径
                    prefabPath = '',
                    instancePos = {0, 0, 0},
                    instanceRotation = {0, 0, 0},
                }
            },
        }
    },
    -- 加载列表，策划只填主要的，其他的程序填吧
    load_list = {
        {
            -- 路径
            path = "",
            -- 名字，方便track获取该对象
            name = "",
            -- 是否实例化（只加载assetbundle,不创建对象）
            createInstance = false,
            -- 对象位置
            instancePos = false,
            -- 对象旋转
            instanceRotation = false,
        }
    },
}

return config
