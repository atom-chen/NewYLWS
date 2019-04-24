-- 笼罩相机
local config = {

    path = 'Timeline/Copy/plot7/plot7-1wave3start.prefab',
    assetPath = 'Timeline/Copy/plot7/plot7-1wave3start.playable',
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
			bindingZhuZhanParam = {1001004, 3, 60, 500, 15},
            clip_list = {},
		},
    },
	load_list = {
        {
            path = "Models/1004/1004_4.prefab",
            createInstance = false,
            name = "1004",
            instancePos = {0, 0, 0},
            instanceRotation = {0, 0, 0},
	    },
    },
}

return config
