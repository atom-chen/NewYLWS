-- 笼罩相机
local config = {

    path = 'Timeline/Copy/plot7/plot7-3wave3start.prefab',
    assetPath = 'Timeline/Copy/plot7/plot7-3wave3start.playable',
	plotLanguage = 'SectionLanguage7',
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
			bindingZhuZhanParam = {1001205, 5, 60, 300, 15},
            clip_list = {},
		},
		{  
		    name = 'Custom Anim Track',	
		    bindingType = 2,
			bindingWujiangCamp = 1,
			bindingWujiangID = 1205,
            clip_list = {},
		},
    },
	load_list = {
        {
            path = "Models/1205/1205_4.prefab",
            createInstance = false,
            name = "1205",
            instancePos = {0, 0, 0},
            instanceRotation = {0, 0, 0},
        },
    },
}

return config
