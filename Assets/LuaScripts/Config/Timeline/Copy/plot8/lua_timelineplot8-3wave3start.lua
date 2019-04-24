-- 笼罩相机
local config = {

    path = 'Timeline/Copy/plot8/plot8-3wave3start.prefab',
    assetPath = 'Timeline/Copy/plot8/plot8-3wave3start.playable',
	plotLanguage = 'SectionLanguage8',
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
			bindingZhuZhanParam = {1001029, 5, 60, 400, 15},
            clip_list = {},
		},
    },
	load_list = {
        {
            path = "Models/1029/1029_4.prefab",
            createInstance = false,
            name = "1029",
            instancePos = {0, 0, 0},
            instanceRotation = {0, 0, 0},
	    },
    },
}

return config
