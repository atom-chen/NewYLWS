-- 笼罩相机
local config = {

    path = 'Timeline/Copy/plot8/plot8-4wave3start.prefab',
    assetPath = 'Timeline/Copy/plot8/plot8-4wave3start.playable',
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
            bindingWujiangID = 1035,
            clip_list = {},
		},
				{
		    name = 'Custom Anim Track (1)',
            bindingType = 2,
            bindingWujiangCamp = 2,
            bindingWujiangID = 1034,
            clip_list = {},
		},
		{	
		    name = 'EffectTrack',
			bindingType = 0,
            clipingType = 1,
            clip_list = {
                ["1035_showoff"] = {
                    parentType = 4,
                    prefabPath = 'Models/1035/Effect/1035_showoff.prefab',
                    wujiangID = 1035,
					camp = 2,
                },
				["1034_showoff"] = {
                    parentType = 4,
                    prefabPath = 'Models/1034/Effect/1034_showoff.prefab',
                    wujiangID = 1034,
					camp = 2,
                },
            },
		},	
    },
}

return config
