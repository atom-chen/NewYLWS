-- 笼罩相机
local config = {

    path = 'Timeline/Copy/plot8/plot8-1wave3start.prefab',
    assetPath = 'Timeline/Copy/plot8/plot8-1wave3start.playable',
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
		    name = 'Custom Anim Track',
            bindingType = 2,
            bindingWujiangCamp = 2,
            bindingWujiangID = 1029,
            clip_list = {},
		},
		{	
		    name = 'EffectTrack',
			bindingType = 0,
            clipingType = 1,
            clip_list = {
                ["1029_showoff_4"] = {
                    parentType = 4,
                    prefabPath = 'Models/1029/Effect/1029_showoff_4.prefab',
                    wujiangID = 1029,
					camp = 2,
                },
            },
		},	
    },
}

return config
