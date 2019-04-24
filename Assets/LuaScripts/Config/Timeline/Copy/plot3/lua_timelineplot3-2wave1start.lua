-- 笼罩相机
local config = {

    path = 'Timeline/Copy/plot3/plot3-2wave1start.prefab',
    assetPath = 'Timeline/Copy/plot3/plot3-2wave1start.playable',
	plotLanguage = 'SectionLanguage3',
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
            name = 'Animation Track (1)',
			bindingType = 4,
            bindingPath = '1042',
            bindingWujiangCamp = false,
			bindingWujiangID = false,
            clip_list = {},
		},
		{	
		    name = 'EffectTrack',
			bindingType = 0,
            clipingType = 1,
            clip_list = {
                ["1042_showoff_3"] = {
                    parentType = 1,
                    prefabPath = 'Models/1042/Effect/1042_showoff_3.prefab',
                    trackName = "1042",
                },
            },
        },
	},
	load_list = {
        {
            path = "Models/1042/1042_3.prefab",
            createInstance = true,
            name = "1042",
            instancePos = {0, 0, 0},
            instanceRotation = {0, 0, 0},
        },
    },
}

return config
