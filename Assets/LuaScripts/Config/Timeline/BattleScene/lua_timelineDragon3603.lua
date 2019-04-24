-- 召唤兽3601
local config = {

    path = 'Timeline/BattleScene/Dragon/3603/Dragon3603.prefab',
    assetPath = 'Timeline/BattleScene/Dragon/3603/Dragon3603.playable',
    track_list = {
        {
		    name = 'Cinemachine Track',
            bindingType = 3,
            bindingPath = false,
            bindingWujiangCamp = false,
            bindingWujiangID = false,
            clipingType = 2,
            clip_list = {},
		},
		{	
		    name = 'Animation Track',
			bindingType = 4,
            bindingPath = '3603',
            bindingWujiangCamp = false,
			bindingWujiangID = false,
            clip_list = {},
        },
        {	
		    name = 'EffectTrack',
			bindingType = 0,
            clipingType = 1,
            clip_list = {
                ["3603_fenjing"] = {
                    parentType = 1,
                    prefabPath = 'Models/3603/Effect/3603_fenjing.prefab',
                    trackName = "3603",
                },
            },
        },
    },
    load_list = {
        {
            path = "Models/3603/3603_showoff.prefab",
            createInstance = true,
            name = "3603",
            instancePos = {0, 0, 0},
            instanceRotation = {0, 0, 0},
        },
    },
}

return config
