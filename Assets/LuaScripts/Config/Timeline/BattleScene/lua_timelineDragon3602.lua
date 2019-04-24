-- 召唤兽3601
local config = {

    path = 'Timeline/BattleScene/Dragon/3602/Dragon3602.prefab',
    assetPath = 'Timeline/BattleScene/Dragon/3602/Dragon3602.playable',
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
            bindingPath = '3602',
            bindingWujiangCamp = false,
			bindingWujiangID = false,
            clip_list = {},
        },
        {	
		    name = 'EffectTrack',
			bindingType = 0,
            clipingType = 1,
            clip_list = {
                ["yumao_Camera1"] = {
                    parentType = 2,
                    prefabPath = 'Models/3602/Effect/3602_yumao_Camera.prefab',
                    instancePos = {-0.317, 0.152, 0.38},
                    instanceRotation = {0, 0, 0},
                },
                ["yumao_Camera2"] = {
                    parentType = 2,
                    prefabPath = 'Models/3602/Effect/3602_yumao_Camera.prefab',
                    instancePos = {0.389, 0.192, 0.735},
                    instanceRotation = {0, -180, 0},
                },
                ["yumao_Camera3"] = {
                    parentType = 2,
                    prefabPath = 'Models/3602/Effect/3602_yumao_Camera.prefab',
                    instancePos = {-0.435, -0.369, 0.907},
                    instanceRotation = {0.0, -1.467, 148.7},
                },
                ["3602_yumao_changjing"] = {
                    parentType = 2,
                    prefabPath = 'Models/3602/Effect/3602_yumao_changjing.prefab',
                    instancePos = {5.32, 15.3, 0},
                    instanceRotation = {0, 0, 0},
                },
                ["3602_fenjing01"] = {
                    parentType = 1,
                    prefabPath = 'Models/3602/Effect/3602_fenjing01.prefab',
                    trackName = "3602",
                },
            },
        },
    },
    load_list = {
        {
            path = "Models/3602/3602_showoff.prefab",
            createInstance = true,
            name = "3602",
            instancePos = {0, 0, 0},
            instanceRotation = {0, 0, 0},
        },
    },
}

return config
