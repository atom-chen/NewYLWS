-- 笼罩相机
local config = {

    path = 'Timeline/Copy/plot9/plot9-3wave3start.prefab',
    assetPath = 'Timeline/Copy/plot9/plot9-3wave3start.playable',
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
		    name = 'Custom Anim Track',
            bindingType = 2,
            bindingWujiangCamp = 2,
            bindingWujiangID = 1076,
            clipingType = 2,
            clip_list = {},
		},
		{	
		    name = 'EffectTrack',
			bindingType = 0,
            clipingType = 1,
            clip_list = {
                ["1076_showoff"] = {
                    parentType = 4,
                    prefabPath = 'Models/1076/Effect/1076_showoff.prefab',
                    wujiangID = 1076,
					camp = 2,
                },
            },
		},	
    },
}

return config
