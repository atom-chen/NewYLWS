-- 笼罩相机
local config = {

    path = 'Timeline/Copy/plot7/plot7-4wave3start.prefab',
    assetPath = 'Timeline/Copy/plot7/plot7-4wave3start.playable',
	plotLanguage = 'SectionLanguage7',
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
            bindingWujiangID = 1043,
            clipingType = 2,
            clip_list = {},
		},
		{	
		    name = 'EffectTrack',
			bindingType = 0,
            clipingType = 1,
            clip_list = {
                ["1043_showoff_4"] = {
                    parentType = 4,
                    prefabPath = 'Models/1043/Effect/1043_showoff_4.prefab',
                    wujiangID = 1043,
					camp = 2,
                },
            },
		},	
    },
}

return config
