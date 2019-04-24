-- 笼罩相机
local config = {

    path = 'Timeline/Copy/plot3/plot3-4wave3start.prefab',
    assetPath = 'Timeline/Copy/plot3/plot3-4wave3start.playable',
	plotLanguage = 'SectionLanguage3',
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
		    name = 'Custom Anim Track',
            bindingType = 2,
            bindingPath = false,
            bindingWujiangCamp = 2,
            bindingWujiangID = 1041,
            clipingType = 2,
            clip_list = {},
        },
		{	
		    name = 'EffectTrack',
			bindingType = 0,
            clipingType = 1,
            clip_list = {
                ["1041_showoff"] = {
                    parentType = 4,
                    prefabPath = 'Models/1041/Effect/1041_showoff.prefab',
                    wujiangID = 1041,
					camp = 2,
                },
            },
		},	
	},	
}

return config
