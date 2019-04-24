-- 笼罩相机
local config = {

    path = 'Timeline/Copy/plot2/plot2-22wave3start.prefab',
    assetPath = 'Timeline/Copy/plot2/plot2-22wave3start.playable',
	plotLanguage = 'SectionLanguage2',
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
			bindingZhuZhanParam = {1002200, 5, 6, 100, 0},
            clip_list = {},
		},
		{  
		    name = 'Custom Anim Track',	
		    bindingType = 2,
			bindingWujiangCamp = 1,
			bindingWujiangID = 2200,
            clip_list = {},
		},
    },
    load_list = {
        {
            path = "Models/2200/2200_1.prefab",
            createInstance = false,
            name = "2200",
            instancePos = {0, 0, 0},
            instanceRotation = {0, 0, 0},
        },
    },
}

return config
