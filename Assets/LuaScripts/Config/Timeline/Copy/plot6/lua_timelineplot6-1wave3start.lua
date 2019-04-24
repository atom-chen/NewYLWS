-- 笼罩相机
local config = {

    path = 'Timeline/Copy/plot6/plot6-1wave3start.prefab',
    assetPath = 'Timeline/Copy/plot6/plot6-1wave3start.playable',
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
			bindingZhuZhanParam = {1001001, 5, 40, 350, 15},
            clip_list = {},
		},
    },
	load_list = {
        {
            path = "Models/1001/1001_4.prefab",
            createInstance = false,
            name = "1001",
            instancePos = {0, 0, 0},
            instanceRotation = {0, 0, 0},
        },
    },
}

return config
