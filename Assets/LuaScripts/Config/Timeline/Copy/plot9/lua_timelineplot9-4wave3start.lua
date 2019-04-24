-- 笼罩相机
local config = {

    path = 'Timeline/Copy/plot9/plot9-4wave3start.prefab',
    assetPath = 'Timeline/Copy/plot9/plot9-4wave3start.playable',
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
		    name = 'Animation Track (1)',
            bindingType = 5,
			bindingZhuZhanParam = {1001002, 3, 70, 800, 15},
            clipingType = 2,
            clip_list = {},
		},
		{
		    name = 'Custom Anim Track',
            bindingType = 2,
            bindingWujiangCamp = 2,
            bindingWujiangID = 1014,
            clipingType = 2,
            clip_list = {},
		},
		{
		    name = 'Custom Anim Track (1)',
            bindingType = 2,
            bindingWujiangCamp = 2,
            bindingWujiangID = 1061,
            clipingType = 2,
            clip_list = {},
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
