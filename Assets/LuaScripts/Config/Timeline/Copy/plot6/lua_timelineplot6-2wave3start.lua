-- 笼罩相机
local config = {

    path = 'Timeline/Copy/plot6/plot6-2wave3start.prefab',
    assetPath = 'Timeline/Copy/plot6/plot6-2wave3start.playable',
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
			bindingZhuZhanParam = {1001042, 5, 30, 200, 15},
            clip_list = {},
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
