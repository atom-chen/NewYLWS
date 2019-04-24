-- 笼罩相机
local config = {

    path = 'Timeline/BattleScene/Luoyang/Luoyangdemo4.prefab',
    assetPath = 'Timeline/BattleScene/Luoyang/Luoyangdemo4.playable',
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
		    name = 'Custom Anim Track',
			bindingType = 2,
            bindingWujiangCamp = 2,
            bindingWujiangID = 1041, 			
		},
	},	
}

return config
