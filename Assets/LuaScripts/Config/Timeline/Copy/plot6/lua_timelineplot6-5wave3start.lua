-- 笼罩相机
local config = {

    path = 'Timeline/Copy/plot6/plot6-5wave3start.prefab',
    assetPath = 'Timeline/Copy/plot6/plot6-5wave3start.playable',
	plotLanguage = 'SectionLanguage6',
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
			bindingZhuZhanParam = {1001042, 5, 60, 600, 15},
            clip_list = {},
		},
		{  
		    name = 'Custom Anim Track',	
		    bindingType = 2,
			bindingWujiangCamp = 1,
			bindingWujiangID = 1042,
            clip_list = {},
		},
		{	
		    name = 'EffectTrack',
			bindingType = 0,
            clipingType = 1,
            clip_list = {
                ["1042_skl10423"] = {
                    parentType = 4,
                    prefabPath = 'Models/1042/Effect/1042_skl10423.prefab',
                    wujiangID = 1042,
					camp = 1,
                },
            },
		},	
    },
    load_list = {
        {
            path = "Models/1042/1042_4.prefab",
            createInstance = false,
            name = "1042",
            instancePos = {0, 0, 0},
            instanceRotation = {0, 0, 0},
        },
    },
}

return config
