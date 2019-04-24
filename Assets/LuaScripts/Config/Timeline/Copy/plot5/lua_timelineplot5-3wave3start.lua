-- 笼罩相机
local config = {

    path = 'Timeline/Copy/plot5/plot5-3wave3start.prefab',
    assetPath = 'Timeline/Copy/plot5/plot5-3wave3start.playable',
	plotLanguage = 'SectionLanguage5',
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
            bindingType = 4,
            bindingPath = 'sphere',
            bindingWujiangCamp = false,
            bindingWujiangID = false,
            clip_list = {},
        },
		{
            name = 'Animation Track (2)',
            bindingType = 4,
            bindingPath = 'CM vcam12',
            bindingWujiangCamp = false,
            bindingWujiangID = false,
            clip_list = {},
        },
		{
		    name = 'Animation Track',
            bindingType = 2,
            bindingPath = false,
            bindingWujiangCamp = 2,
            bindingWujiangID = 1017,
            clipingType = 2,
            clip_list = {},
		},
		{	
		    name = 'EffectTrack',
			bindingType = 0,
            clipingType = 1,
            clip_list = {
                ["1017_showoff"] = {
                    parentType = 4,
                    prefabPath = 'Models/1017/Effect/1017_showoff.prefab',
                    wujiangID = 1017,
					camp = 2,
                },
            },
		},	
    },
}

return config
