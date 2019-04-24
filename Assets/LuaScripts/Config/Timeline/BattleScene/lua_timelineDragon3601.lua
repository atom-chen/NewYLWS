-- Demo关卡第一波
local config = {

    path = 'Timeline/BattleScene/Dragon/3601/Dragon3601.prefab',
    assetPath = 'Timeline/BattleScene/Dragon/3601/Dragon3601.playable',
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
            bindingPath = '3601',
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
                ["3601_fenjing"] = {
                    parentType = 1,
                    prefabPath = 'Models/3601/Effect/3601_fenjing.prefab',
                    trackName = "3601",
                },
            },
        },
    },
    load_list = {
        {
            path = "Models/3601/3601_showoff.prefab",
            createInstance = true,
            name = "3601",
            instancePos = {0, 0, 0},
            instanceRotation = {0, 0, 0},
        },
    },

}

return config
