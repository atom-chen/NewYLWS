-- 序章
local config = {

    path = 'Timeline/HomeScene/Pavilion/PavilionEnd.prefab',
    assetPath = 'Timeline/HomeScene/Pavilion/PavilionEnd.playable',
	plotLanguage = 'SectionLanguage1',
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
            bindingPath = '4050',
            bindingWujiangCamp = false,
			bindingWujiangID = false,
            clip_list = {},
        },
        {	
		    name = 'EffectTrack',
			bindingType = 0,
            clipingType = 1,
            clip_list = {
                ["4050_show_open"] = {
                    parentType = 1,
                    prefabPath = 'Models/4050/Effect/4050_show_open.prefab',
                    trackName = "4050",
                },
            },
        },
    },
    load_list = {
        {
            path = "Models/4050/4050_1.prefab",
            createInstance = true,
            name = "4050",
            instancePos = {0, 0, 0},
            instanceRotation = {0, 0, 0},
        },
    },
}

return config
