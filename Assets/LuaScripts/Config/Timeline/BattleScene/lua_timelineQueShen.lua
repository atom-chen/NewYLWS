-- 笼罩相机
local config = {

    path = 'Timeline/BattleScene/QueShen/QueShen.prefab',
    assetPath = 'Timeline/BattleScene/QueShen/QueShen.playable',
    track_list = {
        {
            name = 'CameraTrack',
            bindingType = 3,
            bindingPath = false,
            bindingWujiangCamp = false,
            bindingWujiangID = false,
            clipingType = 2,
            clip_list = {},
        },
        {	
		    name = 'EffectTrack',
			bindingType = 0,
            clipingType = 1,
            clip_list = {
                ["4050_show"] = {
                    parentType = 4,
                    prefabPath = 'Models/4050/Effect/4050_show.prefab',
                    wujiangID = 4050,
                    camp = 2,
                },
            },
        },
    },
}

return config
