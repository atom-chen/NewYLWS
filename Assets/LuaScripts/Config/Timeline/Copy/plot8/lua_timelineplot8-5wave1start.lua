-- 笼罩相机
local config = {

    path = 'Timeline/Copy/plot8/plot8-5wave1start.prefab',
    assetPath = 'Timeline/Copy/plot8/plot8-5wave1start.playable',
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
            bindingType = 4,
            bindingPath = '1111',
            bindingWujiangCamp = false,
			bindingWujiangID = false,
            clip_list = {},
		},
    },
	load_list = {
        {
            path = "Models/1111/1111_4.prefab",
            createInstance = true,
            name = "1111",
            instancePos = {0, 0, 0},
            instanceRotation = {0, 0, 0},
        },
	},
}


return config
