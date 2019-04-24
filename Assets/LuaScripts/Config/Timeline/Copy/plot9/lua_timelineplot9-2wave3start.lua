-- 笼罩相机
local config = {

    path = 'Timeline/Copy/plot9/plot9-2wave3start.prefab',
    assetPath = 'Timeline/Copy/plot9/plot9-2wave3start.playable',
	plotLanguage = 'SectionLanguage9',
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
            bindingType = 5,
			bindingZhuZhanParam = {1001002, 3, 60, 700, 15},
            clipingType = 2,
            clip_list = {},
		},
		{
		    name = 'Custom Anim Track',
            bindingType = 2,
            bindingWujiangCamp = 2,
            bindingWujiangID = 1075,
            clipingType = 2,
            clip_list = {},
		},
		{	
		    name = 'EffectTrack',
			bindingType = 0,
            clipingType = 1,
            clip_list = {
                ["1075_showoff"] = {
                    parentType = 4,
                    prefabPath = 'Models/1075/Effect/1075_showoff.prefab',
                    wujiangID = 1075,
					camp = 2,
                },
				["1002_showoff_4"] = {
                    parentType = 4,
                    prefabPath = 'Models/1002/Effect/1002_showoff_4.prefab',
                    wujiangID = 1002,
					camp = 1,
                },
            },
		},	
    },
	load_list = {
        {
            path = "Models/1002/1002_4.prefab",
            createInstance = false,
            name = "1002",
            instancePos = {0, 0, 0},
            instanceRotation = {0, 0, 0},
	    },
    },
}

return config
