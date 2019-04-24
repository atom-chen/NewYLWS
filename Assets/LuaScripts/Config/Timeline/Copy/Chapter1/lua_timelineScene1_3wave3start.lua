-- Demo关卡第一波
local config = {

    path = 'Timeline/Copy/Chapter1/Scene1_3_40/Scene1_3wave3start.prefab',
    assetPath = 'Timeline/Copy/Chapter1/Scene1_3_40/Scene1_3wave3start.playable',
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
            bindingWujiangID = 2095,
            clip_list = {},
		}	
    },

}

return config
