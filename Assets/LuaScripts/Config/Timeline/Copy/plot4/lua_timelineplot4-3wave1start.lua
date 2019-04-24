-- 笼罩相机
local config = {

    path = 'Timeline/Copy/plot4/plot4-3wave1start.prefab',
    assetPath = 'Timeline/Copy/plot4/plot4-3wave1start.playable',
	plotLanguage = 'SectionLanguage4',
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
			bindingType = 4,
            bindingPath = '1038',
            bindingWujiangCamp = false,
			bindingWujiangID = false,
            clip_list = {},
		},
	},
	load_list = {
        {
            path = "Models/1038/1038_showoff.prefab",
            createInstance = true,
            name = "1038",
            instancePos = {0, 0, 0},
            instanceRotation = {0, 0, 0},
        },
    },
}

return config
