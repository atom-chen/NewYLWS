-- 笼罩相机
local config = {

    path = 'Timeline/Copy/plot6/plot6-4wave3start.prefab',
    assetPath = 'Timeline/Copy/plot6/plot6-4wave3start.playable',
	plotLanguage = 'SectionLanguage6',
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
            bindingType = 2,
            bindingPath = false,
            bindingWujiangCamp = 2,
            bindingWujiangID = 1018,
            clipingType = 2,
            clip_list = {},
		},
		{	
		    name = 'EffectTrack',
			bindingType = 0,
            clipingType = 1,
            clip_list = {
                ["1018_showoff"] = {
                    parentType = 4,
                    prefabPath = 'Models/1018/Effect/1018_showoff.prefab',
                    wujiangID = 1018,
					camp = 2,
                },
            },
		},	
    },
}

return config
