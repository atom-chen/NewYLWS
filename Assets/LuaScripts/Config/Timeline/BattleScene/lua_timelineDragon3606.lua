-- Demo关卡第一波
local config = {

    path = 'Timeline/BattleScene/Dragon/3606/Dragon3606.prefab',
    assetPath = 'Timeline/BattleScene/Dragon/3606/Dragon3606.playable',
    track_list = {
        {
            name = 'Animation Track',
            bindingType = 4,
            bindingPath = 'sphere',
            bindingWujiangCamp = false,
            bindingWujiangID = false,
            clip_list = {},
        },
		{
            name = 'Animation Track (1)',
            bindingType = 4,
            bindingPath = 'CM vcam11',
            bindingWujiangCamp = false,
            bindingWujiangID = false,
            clip_list = {},
        },
		{	
		    name = 'Animation Track (2)',
			bindingType = 4,
            bindingPath = '3606',
            bindingWujiangCamp = false,
			bindingWujiangID = false,
            clip_list = {},
		},
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
		    name = 'EffectTrack',
			bindingType = 0,
            clipingType = 1,
            clip_list = {
                ["3606_fenjing1"] = {
                    parentType = 1,
                    prefabPath = 'Models/3606/Effect/3606_fenjing1.prefab',
                    trackName = "3606",
                },
            },
        },
        {	
		    name = 'EffectTrack1',
			bindingType = 0,
            clipingType = 1,
            clip_list = {
                ["3606_fenjing2"] = {
                    parentType = 1,
                    prefabPath = 'Models/3606/Effect/3606_fenjing2.prefab',
                    trackName = "3606",
                },
            },
        },
    },
    load_list = {
        {
            path = "Models/3606/3606_showoff.prefab",
            createInstance = true,
            name = "3606",
            instancePos = {0, 0, 0},
            instanceRotation = {0, 0, 0},
        },
    },
}

return config
