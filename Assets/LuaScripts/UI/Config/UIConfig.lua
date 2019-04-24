--[[
-- added by wsh @ 2017-11-30
-- UI模块配置表，添加新UI模块时需要在此处加入
--]]

local CommonDefine = CommonDefine

local UIWindowNames = UIWindowNames

local UIConfig = {
	[UIWindowNames.UILogin] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UILogin.View.UILoginView",
		PrefabPath = "UI/Prefabs/Login/UILogin.prefab",
		NeedOpenAudio = false
	},
	[UIWindowNames.UIPlatLogin] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UILogin.View.UIPlatLoginView",
		PrefabPath = "UI/Prefabs/Login/UIPlatLogin.prefab",
		NeedOpenAudio = false
	},
	[UIWindowNames.UIServerList] =	{
		Layer = UILayers.NormalLayer,
		View = "UI.UILogin.View.UIServerListView",
		PrefabPath = "UI/Prefabs/Login/UIServerList.prefab",
	},
	[UIWindowNames.UIUpdateNotice] =	{
		Layer = UILayers.NormalLayer,
		View = "UI.UILogin.View.UIUpdateNoticeView",
		PrefabPath = "UI/Prefabs/Login/UIUpdateNotice.prefab",
	},
	
	[UIWindowNames.UILoading] = {
		Layer = UILayers.TopLayer,
		View = "UI.UILoading.View.UILoadingView",
		PrefabPath = "UI/Prefabs/Loading/UILoading.prefab",
	},
	[UIWindowNames.UIDownloadTips] = {
		Layer = UILayers.TopLayer,
		View = "UI.UILoading.View.UIDownloadTipsView",
		PrefabPath = "UI/Prefabs/Loading/UIDownloadTips.prefab",
	},
	[UIWindowNames.UINoticeTip] = {
		Layer = UILayers.TipLayer,
		View = "UI.UINoticeTip.View.UINoticeTipView",
		PrefabPath = "UI/Prefabs/NoticeTip/UINoticeTip.prefab",
	},
	[UIWindowNames.UIBattleMain] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIBattle.View.UIBattleMainView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleMain.prefab",
		NeedOpenAudio = false,
	},
	[UIWindowNames.UIPlotBattleMain] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIBattle.View.UIPlotBattleMainView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleMain.prefab",
		NeedOpenAudio = false
	},
	[UIWindowNames.UIBattleInscriptionMain] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIBattle.View.UIBattleInscriptionMainView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleMain.prefab",
		NeedOpenAudio = false
	},
	[UIWindowNames.UIActTurntable] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIActivity.View.UIActTurntableView",
		PrefabPath = "UI/Prefabs/Activity/UIActTurntable.prefab",
		IsShowTop = true,
	},
	[UIWindowNames.UIActJiXingGaoZhao] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIActivity.View.UIActJiXingGaoZhaoView",
		PrefabPath = "UI/Prefabs/Activity/UIActJiXingGaoZhao.prefab",
		TweenTargetPath = "Panel",
	},
	[UIWindowNames.UIGroupHerosWar] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIGroupHerosWar.View.UIGroupHerosWarView",
		PrefabPath = "UI/Prefabs/GroupHerosWar/UIGroupHerosWar.prefab",
		IsShowTop = true,
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},
	[UIWindowNames.UIGroupHerosLineUp] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIGroupHerosWar.View.UIGroupHerosLineUpView",
		PrefabPath = "UI/Prefabs/GroupHerosWar/UIGroupHerosLineup.prefab",
	},
	[UIWindowNames.UIGroupHerosSaiChangBrief] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIGroupHerosWar.View.UIGroupHerosSaiChangBriefView",
		PrefabPath = "UI/Prefabs/GroupHerosWar/UIGroupHerosSaichangBrief.prefab",
		IsShowTop = true,
	},
	[UIWindowNames.UIGroupHerosLineupSelect] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIGroupHerosWar.View.UIGroupHerosLineupSelectView",
		PrefabPath = "UI/Prefabs/GroupHerosWar/UIGroupHerosWuJiangSelect.prefab",
		TweenTargetPath = "WuJiangBag",
	},
	[UIWindowNames.UIGroupHerosWuJiangList] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIGroupHerosWar.View.UIGroupHerosWuJiangListView",
		PrefabPath = "UI/Prefabs/GroupHerosWar/UIGroupHerosWujiangList.prefab",
		TweenTargetPath = "wujiangView",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},
	[UIWindowNames.UIGroupHerosJoinRecord] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIGroupHerosWar.View.UIGroupHerosJoinRecordView",
		PrefabPath = "UI/Prefabs/GroupHerosWar/UIGroupHerosJoinRecord.prefab",
		TweenTargetPath = "Container",
	},
	[UIWindowNames.UIGroupHerosWarRecord] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIGroupHerosWar.View.UIGroupHerosWarRecordView",
		PrefabPath = "UI/Prefabs/GroupHerosWar/UIGroupHerosWarRecord.prefab",
		TweenTargetPath = "Container",
	},
	[UIWindowNames.UIGroupHerosJunxian] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIGroupHerosWar.View.UIGroupHerosJunxianView",
		PrefabPath = "UI/Prefabs/GroupHerosWar/UIGroupHerosJunxian.prefab",
		TweenTargetPath = "Container",
	},
	[UIWindowNames.UIGroupHerosWarRank] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UICommonRank.UIGroupHerosWarRankView",
		PrefabPath = "UI/Prefabs/CommonRanks/UICommonRank.prefab",
	},
	[UIWindowNames.UIBattleYuanmenMain] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIBattle.View.UIBattleYuanmenMainView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleMain.prefab",
		NeedOpenAudio = false
	},
	[UIWindowNames.UIBattleShenbingMain] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIBattle.View.UIBattleShenbingMainView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleMain.prefab",
		NeedOpenAudio = false
	},
	[UIWindowNames.UIBattleFloat] = {
		Layer = UILayers.SceneLayer,
		View = "UI.UIBattleFloat.View.UIBattleFloatView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleFloat.prefab",
	},
	[UIWindowNames.UIPlotDialog] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIPlot.View.UIPlotDialogView",
		PrefabPath = "UI/Prefabs/Plot/UIPlotDialog.prefab",
	},
	[UIWindowNames.UIPlotTextDialog] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIPlot.View.UIPlotTextDialogView",
		PrefabPath = "UI/Prefabs/Plot/UIPlotTextDialog.prefab",
	},
	[UIWindowNames.UIPlotTopBottomHeidi] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIPlot.View.UIPlotTopBottomHeidiView",
		PrefabPath = "UI/Prefabs/Plot/UIPlotTopBottomHeidi.prefab",
	},
	[UIWindowNames.UIPlotBubbleDialog] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIPlot.View.UIPlotBubbleDialogView",
		PrefabPath = "UI/Prefabs/Plot/UIPlotBubbleDialog.prefab",
	},
	[UIWindowNames.UIFingerGuideDialog] = {
		Layer = UILayers.InfoLayer,
		View = "UI.UIPlot.View.UIFingerGuideDialogView",
		PrefabPath = "UI/Prefabs/Plot/UIFingerGuideDialog.prefab",
	},
	[UIWindowNames.UIInscriptionFingerGuideDialog] = {
		Layer = UILayers.InfoLayer,
		View = "UI.UIPlot.View.UIInscriptionFingerGuideDialogView",
		PrefabPath = "UI/Prefabs/Plot/UIInscriptionFingerGuideDialog.prefab",
	},
	[UIWindowNames.UICreateRole] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIPlot.View.UICreateRoleView",
		PrefabPath = "UI/Prefabs/Plot/UICreateRole.prefab",
		TweenTargetPath = "BgRoot",
	},
	[UIWindowNames.UIPlotWujiangDialog] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIPlot.View.UIPlotWujiangDialogView",
		PrefabPath = "UI/Prefabs/Common/UIPlotWujiangDialog.prefab",
	},
	[UIWindowNames.UIGuideWujiangDialog] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIPlot.View.UIGuideWujiangDialogView",
		PrefabPath = "UI/Prefabs/Common/UIPlotWujiangDialog.prefab",
	},
	[UIWindowNames.UIShenbingCopyWujiangDialog] = {
		Layer = UILayers.InfoLayer,
		View = "UI.UIShenbingCopy.UIShenbingCopyWujiangDialogView",
		PrefabPath = "UI/Prefabs/Common/UIPlotWujiangDialog.prefab",
	},
	[UIWindowNames.UIBattleBloodBar] = {
		Layer = UILayers.SceneLayer,
		View = "UI.UIBattleBloodBar.View.UIBattleBloodBarView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleBloodBar.prefab",
	},
	[UIWindowNames.UIWuJiangDetail] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIWuJiang.View.UIWuJiangDetailView",
		PrefabPath = "UI/Prefabs/WuJiang/UIWuJiangDetail.prefab",
		IsShowTop = true,
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},

	[UIWindowNames.UIWuJiangAttr] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIWuJiang.View.UIWuJiangAttrView",
		PrefabPath = "UI/Prefabs/WuJiang/UIWuJiangAttr.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIFuli] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIFuli.View.UIFuliView",
		PrefabPath = "UI/Prefabs/Fuli/UIFuli.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIActivity] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIActivity.View.UIActivityView",
		PrefabPath = "UI/Prefabs/Activity/UIActivity.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIGMView] = {
		Layer = UILayers.TipLayer,
		View = "UI.GM.UIGMView",
		PrefabPath = "UI/Prefabs/GM/UIGM.prefab",
	},
	[UIWindowNames.UICommonRank] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UICommonRank.UICommonRankView",
		PrefabPath = "UI/Prefabs/CommonRanks/UICommonRank.prefab",
	},
	[UIWindowNames.UIWorldbossRank] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UICommonRank.UIWorldbossRankView",
		PrefabPath = "UI/Prefabs/CommonRanks/UICommonRank.prefab",
	},
	[UIWindowNames.UIBattleLoseView] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIBattle.View.UIBattleLoseView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleLose.prefab",
	},

	[UIWindowNames.UIBattleWinView] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIBattle.View.UIBattleWinView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleWin.prefab",
	},
 
	[UIWindowNames.UIYuanmen] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIYuanmen.View.UIYuanmenView",
		PrefabPath = "UI/Prefabs/Yuanmen/UIYuanmen.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		IsShowTop = true,
	},
	[UIWindowNames.UIYuanmenDetail] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIYuanmen.View.YuanmenDetailView",
		PrefabPath = "UI/Prefabs/Yuanmen/YuanmenDetailView.prefab", 
		TweenTargetPath = "bg",
	},

	[UIWindowNames.UIWuJiangSkillDetail] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIWuJiang.View.UIWuJiangSkillDetailView",
		PrefabPath = "UI/Prefabs/WuJiang/UIWuJiangSkillDetail.prefab",
	},

	[UIWindowNames.UIQingYuanGiftView] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIWuJiang.View.UIQingYuanGiftView",
		PrefabPath = "UI/Prefabs/WuJiang/QingYuan/QingYuanGiftView.prefab",
	},

	[UIWindowNames.UIMainMenu] = {
		Layer = UILayers.MenuLayer,
		View = "UI.Main.UIMainMenuView",
		PrefabPath = "UI/Prefabs/Main/UIMainMenu.prefab",
	},

	[UIWindowNames.UIBattleArenaMain] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIBattle.View.UIBattleArenaMainView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleArenaMain.prefab",
		NeedOpenAudio = false, 
	},

	[UIWindowNames.UIWuJiangDevelop] =  {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIWuJiang.View.UIWuJiangDevelopView",
		PrefabPath = "UI/Prefabs/WuJiang/UIWuJiangDevelop.prefab",
		IsShowTop = true,
	},

	[UIWindowNames.UIBattleContinueGuide] = {
		Layer = UILayers.SceneLayer,
		View = "UI.UIContinueGuide.View.UIBattleContinueGuideView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleContinueGuide.prefab",
	},

	[UIWindowNames.UILineupMain] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.Lineup.UILineupMainView",
		PrefabPath = "UI/Prefabs/Lineup/LineupMain.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		IsClearWhenSceneChg = true,
	},
	
	[UIWindowNames.UIShenbingCopyLineupMainView] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.Lineup.UIShenbingCopyLineupMainView",
		PrefabPath = "UI/Prefabs/Lineup/LineupMain.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		IsClearWhenSceneChg = true,
	},

	[UIWindowNames.UIYuanmenLineupMain] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.Lineup.UIYuanmenLineupMainView",
		PrefabPath = "UI/Prefabs/Lineup/LineupMain.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		IsClearWhenSceneChg = true,
	},
	
	[UIWindowNames.UILineupEdit] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.Lineup.UILineupEditView",
		PrefabPath = "UI/Prefabs/Lineup/LineupMain.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		IsClearWhenSceneChg = true,
	},
	
	[UIWindowNames.UILineupArenaEdit] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.Lineup.UILineupArenaEditView",
		PrefabPath = "UI/Prefabs/Lineup/LineupMain.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		IsClearWhenSceneChg = true,
	},

	[UIWindowNames.UILineupSelect] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Lineup.UILineupSelectView",
		PrefabPath = "UI/Prefabs/Lineup/UIWuJiangSelect.prefab",
	},
	
	[UIWindowNames.UIWuJiangSelect] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Lineup.UIWuJiangSelectView",
		PrefabPath = "UI/Prefabs/Lineup/UIWuJiangSelect.prefab",
	},

	[UIWindowNames.UIPromptMsg] = {
		Layer = UILayers.InfoLayer,
		View = "UI.Common.UIPromptMsgView",
		PrefabPath = "UI/Prefabs/Message/UIPromptMsg.prefab",
	},

	[UIWindowNames.UIPowerChange] = {
		Layer = UILayers.TipLayer,
		View = "UI.Common.UIPowerChangeView",
		PrefabPath = "UI/Prefabs/Message/UIPowerChange.prefab",
	},

	[UIWindowNames.UIWuJiangTupoSucc] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIWuJiang.View.UIWuJiangTupoSuccView",
		PrefabPath = "UI/Prefabs/WuJiang/UIWuJiangTupoSucc.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UILineupManager] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Lineup.UILineupManagerView",
		PrefabPath = "UI/Prefabs/Lineup/UILineupManager.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},
	
	[UIWindowNames.UILineupEditRoleSelect] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Lineup.UILineupEditRoleSelectView",
		PrefabPath = "UI/Prefabs/Lineup/UIWuJiangSelect.prefab",
	},

	[UIWindowNames.UIArenaEditRoleSelect] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Lineup.UIArenaEditRoleSelectView",
		PrefabPath = "UI/Prefabs/Lineup/UIWuJiangSelect.prefab",
	},
	-- 
	[UIWindowNames.UINormalTipsDialog] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Common.UITipsDialogView",
		PrefabPath = "UI/Prefabs/Common/UITipsDialog.prefab",
		TweenTargetPath = "BgRoot",
	},
	[UIWindowNames.UITipsDialog] = {
		Layer = UILayers.InfoLayer,
		View = "UI.Common.UITipsDialogView",
		PrefabPath = "UI/Prefabs/Common/UITipsDialog.prefab",
		TweenTargetPath = "BgRoot",
	},
	[UIWindowNames.UITips] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Common.UITipsView",
		PrefabPath = "UI/Prefabs/Common/UITips.prefab",
	},

	[UIWindowNames.UITipsCompound] = {
		Layer = UILayers.InfoLayer,
		View = "UI.Common.UITipsCompoundView",
		PrefabPath = "UI/Prefabs/Common/UITipsCompound.prefab",
		TweenTargetPath = "BgRoot",
	},

	[UIWindowNames.UIServerNotice] = {
		Layer = UILayers.TopLayer,
		View = "UI.Common.UIServerNoticeView",
		PrefabPath = "UI/Prefabs/Common/UIServerNoticeView.prefab", 
	},
	
	[UIWindowNames.UIQuestionsMarkTips] = {
		Layer = UILayers.TipLayer,
		View = "UI.Common.UIQuestionsMarkTipsView",
		PrefabPath = "UI/Prefabs/Common/UIQuestionsMarkTips.prefab",
		TweenTargetPath = "Panel",
	},
	[UIWindowNames.UIAwardTips] = {
		Layer = UILayers.InfoLayer,
		View = "UI.Common.UIAwardTipsView",
		PrefabPath = "UI/Prefabs/Common/UIAwardTips.prefab",
	},
	-- 这个界面必须保持最顶层，在切换场景的时候会弹这个界面，其他弹窗可以用UITipsDialog和UINormalTipsDialog
	[UIWindowNames.UITopTipsDialog] = {
		Layer = UILayers.TopLayer,
		View = "UI.Common.UITipsDialogView",
		PrefabPath = "UI/Prefabs/Common/UITipsDialog.prefab",
		TweenTargetPath = "BgRoot",
	},

	--
	[UIWindowNames.UIGetAwardPanel] = {
		Layer = UILayers.InfoLayer,
		View = "UI.Common.UIGetAwardPanelView",
		PrefabPath = "UI/Prefabs/Common/UIGetAwardPanel.prefab",
		TweenTargetPath = "bg",
	},

	[UIWindowNames.UIBag] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIBag.View.UIBagView",
		PrefabPath = "UI/Prefabs/Bag/UIBag.prefab",
	},

	[UIWindowNames.UIBagUse] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIBag.View.UIBagUseView",
		PrefabPath = "UI/Prefabs/Bag/UIBagUse.prefab",
	},
	
	[UIWindowNames.UIWuJiangRank] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIWuJiang.View.UIWuJiangRankView",
		PrefabPath = "UI/Prefabs/CommonRanks/UIWuJiangRank.prefab",
		TweenTargetPath = "Panel",
	},
	
	[UIWindowNames.UIWuJiangXiaoZhuan] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIWuJiang.View.UIWuJiangXiaoZhuanView",
		PrefabPath = "UI/Prefabs/WuJiang/UIWuJiangXiaoZhuan.prefab",
		TweenTargetPath = "winPanel",
	},

	[UIWindowNames.UIWuJiangInscription] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIWuJiang.View.UIWuJiangInscriptionMainView",
		PrefabPath = "UI/Prefabs/WuJiang/UIWuJiangInscription.prefab",
		IsShowTop = true,
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},
	
	[UIWindowNames.UIInscriptionCaseList] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIWuJiang.View.UIInscriptionCaseList",
		PrefabPath = "UI/Prefabs/WuJiang/UIWuJiangInscriptionCaseList.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIAddInscriptionCase] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIWuJiang.View.UIAddInscriptionCaseView",
		PrefabPath = "UI/Prefabs/WuJiang/UIAddInscriptionCase.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIInscriptionAutoMergeView] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIWuJiang.View.UIInscriptionAutoMergeView",
		PrefabPath = "UI/Prefabs/WuJiang/UIWuJiangInscriptionAutoMerge.prefab",
	},

	[UIWindowNames.UIWuJiangSkillTipsView] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIWuJiang.View.UIWuJiangSkillTipsView",
		PrefabPath = "UI/Prefabs/WuJiang/UIWuJiangSkillTips.prefab",
		TweenTargetPath = "Container/SkillTips",
	},

	[UIWindowNames.UIIconTips] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Common.UIIconTipsView",
		PrefabPath = "UI/Prefabs/Common/UIIconTips.prefab",
		TweenTargetPath = "Container/SkillTips",
	},

	[UIWindowNames.UIPreviewShow] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Common.UIPreviewShowView",
		PrefabPath = "UI/Prefabs/Common/UIPreviewShow.prefab",
	},

	[UIWindowNames.UIWuJiangInscriptionMergeSucc] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIWuJiang.View.InscriptionMergeSuccView",
		PrefabPath = "UI/Prefabs/WuJiang/UIWuJiangInscriptionMergeSucc.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIBattleBossMain] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIBattle.View.UIBattleBossMainView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleMain.prefab",
		NeedOpenAudio = false,
	},

	[UIWindowNames.UICampsRush] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.CampsRush.UICampsRushView",
		PrefabPath = "UI/Prefabs/CampsRush/UICampsRush.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		IsShowTop = true,
	},

	[UIWindowNames.UICampsRushLineup] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.CampsRush.UICampsRushLineupView",
		PrefabPath = "UI/Prefabs/Lineup/LineupMain.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		IsClearWhenSceneChg = true,
	},
	
	[UIWindowNames.UICampsRushSelect] = {
		Layer = UILayers.NormalLayer,
		View = "UI.CampsRush.UICampsRushSelectView",
		PrefabPath = "UI/Prefabs/Lineup/UIWuJiangSelect.prefab",
	},
	
	[UIWindowNames.UICampsRushSweepAward] = {
		Layer = UILayers.NormalLayer,
		View = "UI.CampsRush.UICampsRushSweepAwardView",
		PrefabPath = "UI/Prefabs/CampsRush/UICampsRushSweepAward.prefab",
	},

	[UIWindowNames.UICampsRushAward] = {
		Layer = UILayers.NormalLayer,
		View = "UI.CampsRush.UICampsRushAwardView",
		PrefabPath = "UI/Prefabs/CampsRush/UICampsRushAward.prefab",
	},
	
	[UIWindowNames.UIWorldBoss] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIWorldBoss.View.UIWorldBossView",
		PrefabPath = "UI/Prefabs/WorldBoss/UIWorldBoss.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},

	[UIWindowNames.UIWorldBossTip] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIWorldBoss.View.UIWorldBossTipView",
		PrefabPath = "UI/Prefabs/WorldBoss/UIWorldBossTip.prefab",
	},

	[UIWindowNames.UIDragonCopyMain] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIDragonCopy.View.UIDragonCopyMainView",
		PrefabPath = "UI/Prefabs/DragonCopy/UIDragonCopyMain.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		IsShowTop = true,
	},

	[UIWindowNames.UIDragonCopyDetail] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIDragonCopy.View.UIDragonCopyDetailView",
		PrefabPath = "UI/Prefabs/DragonCopy/UIDragonCopyDetail.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		TweenTargetPath = "Panel",
	},

	[UIWindowNames.UIArenaMain] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIArena.View.UIArenaMainView",
		PrefabPath = "UI/Prefabs/Arena/UIArenaMain.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		IsShowTop = true,
	},

	[UIWindowNames.UIArenaGradingAward] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIArena.View.UIArenaGradingAwardView",
		PrefabPath = "UI/Prefabs/Arena/UIArenaGradingAward.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		IsShowTop = true,
		TweenTargetPath = "containerBg",
	},

	[UIWindowNames.UIArenaBattleRecord] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIArena.View.UIArenaBattleRecordView",
		PrefabPath = "UI/Prefabs/Arena/UIArenaBattleRecord.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		IsShowTop = true,
		TweenTargetPath = "containerBg",
	},

	[UIWindowNames.UIArenaLevelUp] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIArena.View.UIArenaLevelUpView",
		PrefabPath = "UI/Prefabs/Arena/UIArenaLevelUp.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_IGNORE,
		IsShowTop = false,
	},
	
	[UIWindowNames.UIZhuGong] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIZhuGong.View.UIZhuGongView",
		PrefabPath = "UI/Prefabs/ZhuGong/UIZhuGong.prefab",
		TweenTargetPath = "zhugongPanel",
	},

	[UIWindowNames.UINotificationSetting] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIZhuGong.View.UINotificationSettingView",
		PrefabPath = "UI/Prefabs/ZhuGong/UINotificationSetting.prefab",
		TweenTargetPath = "bgRoot",
	},
	
	[UIWindowNames.UIChangeName] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIZhuGong.View.UIChangeNameView",
		PrefabPath = "UI/Prefabs/ZhuGong/UIChangeName.prefab",
		TweenTargetPath = "BgRoot",
	},

	[UIWindowNames.UIZhuGongLevelUp] = {
		Layer = UILayers.TopLayer,
		View = "UI.UIZhuGong.View.UIZhuGongLevelUpView",
		PrefabPath = "UI/Prefabs/ZhuGong/UIZhuGongLevelUp.prefab"
	},

	[UIWindowNames.UIWuJiangList] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIWuJiang.View.UIWuJiangListView",
		PrefabPath = "UI/Prefabs/WuJiang/UIWujiangList.prefab",
		TweenTargetPath = "wujiangView",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},

	[UIWindowNames.UICheckLineup] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Lineup.UICheckLineupView",
		PrefabPath = "UI/Prefabs/Lineup/UICheckLineup.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		IsShowTop = true,
	},

	[UIWindowNames.UIMainline] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.Mainline.UIMainlineView",
		PrefabPath = "UI/Prefabs/Mainline/UIMainline.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		IsShowTop = true,
	},

	[UIWindowNames.UICopyDetail] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Mainline.UICopyDetailView",
		PrefabPath = "UI/Prefabs/Mainline/UICopyDetail.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		TweenTargetPath = "bg",
	},

	[UIWindowNames.UIMonsterHomeDetail] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Mainline.UIMonsterHomeDetailView",
		PrefabPath = "UI/Prefabs/Mainline/UIMonsterCopyDetail.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		TweenTargetPath = "bg",
	},

	[UIWindowNames.UIStarPanel] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIStarPanel.UIStarPanelView",
		PrefabPath = "UI/Prefabs/StarPanel/UIStarPanel.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		IsShowTop = false,
	},

	[UIWindowNames.UIEmail] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIEmail.View.UIEmailView",
		PrefabPath = "UI/Prefabs/Email/UIEmail.prefab",
		TweenTargetPath = "winPanel",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND, 
	},

	[UIWindowNames.BattleSettlement] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIBattleRecord.View.BattleSettlementView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleSettlement.prefab",
	},

	[UIWindowNames.UIBuyTipsDialog] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Common.UIBuyTipsDialogView",
		PrefabPath = "UI/Prefabs/Common/UIBuyTipsDialog.prefab",
		TweenTargetPath = "BgRoot",
	},

	[UIWindowNames.BattleRecord] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIBattleRecord.View.UIBattleRecordView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleRecord.prefab",
	},

	[UIWindowNames.BattleRecordFromSever] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIBattleRecord.View.UIBattleRecordFromSeverView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleRecord.prefab",
	},
	
	[UIWindowNames.UIItemDetail] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIBattleRecord.View.UIItemDetailView",
		PrefabPath = "UI/Prefabs/Common/UIItemDetail.prefab",
	},

	[UIWindowNames.UIAwardDetail] = {
		Layer = UILayers.InfoLayer,
		View = "UI.Common.UIAwardDetailView",
		PrefabPath = "UI/Prefabs/Common/UIItemDetail.prefab",
	},

	[UIWindowNames.UIGuildResourceDetail] = {
		Layer = UILayers.InfoLayer,
		View = "UI.Guild.View.UIGuildResourceDetailView",
		PrefabPath = "UI/Prefabs/Common/UIItemDetail.prefab",
	},

	[UIWindowNames.UILineupWujiangBrief] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Common.UILineupWujiangBriefView",
		PrefabPath = "UI/Prefabs/Common/UILineupWujiangBrief.prefab",
	},

	[UIWindowNames.UIGuildJoin] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Guild.View.UIGuildJoinView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildJoin.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIGuildRank] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.Guild.View.UIGuildRankView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildRank.prefab",
		TweenTargetPath = "Container",
		IsShowTop = true,
	},

	[UIWindowNames.UIGuildSkillActive] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Guild.View.UIGuildSkillActiveView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildSkillActive.prefab",
		TweenTargetPath = "bgRoot",
	},

	[UIWindowNames.UIGuildSkill] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.Guild.View.UIGuildSkillView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildSkill.prefab",
		TweenTargetPath = "bgRoot",
		IsShowTop = true,
	},

	[UIWindowNames.UIGuildCreate] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Guild.View.UIGuildCreateView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildCreate.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIMyGuild] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.Guild.View.UIGuildMainView",
		PrefabPath = "UI/Prefabs/Guild/UIMyGuild.prefab",
		IsShowTop = true,
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},

	[UIWindowNames.UIGuildDonation] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Guild.View.UIGuildDonationView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildDonation.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIGuildTask] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Guild.View.UIGuildTaskView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildTask.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIGuildLevelUp] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Guild.View.UIGuildLevelUpView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildLevelUp.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIGuildWorship] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Guild.View.UIGuildWorshipView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildWorship.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIGuildApplyList] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Guild.View.UIGuildApplyListView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildApplyList.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIGuildManage] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Guild.View.UIGuildManageView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildManage.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIGuildGetAward] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Guild.View.UIGuildGetAwardView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildGetAward.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIGuildLog] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Guild.View.UIGuildLogView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildLog.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIGuildMenu] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Guild.View.GuildMenuView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildMenu.prefab",
	},

	[UIWindowNames.UIGuildPost] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Guild.View.UIGuildPostView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildPost.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIBossSettlement] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIBattleRecord.View.UIBossSettlementView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleSettlement.prefab",
	},

	[UIWindowNames.UIZuoQi] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIZuoQi.View.UIZuoQiView",
		PrefabPath = "UI/Prefabs/ZuoQi/UIZuoQi.prefab",
		IsShowTop = true,
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},

	[UIWindowNames.UIZuoQiImprove] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIZuoQi.View.UIZuoQiImproveView",
		PrefabPath = "UI/Prefabs/ZuoQi/UIZuoQiImprove.prefab",
		IsShowTop = true,
	},

	[UIWindowNames.UIHunt] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIZuoQi.View.UIHuntView",
		PrefabPath = "UI/Prefabs/ZuoQi/UIHunt.prefab",
		IsShowTop = true,
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},

	[UIWindowNames.UIHuntTips] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIZuoQi.View.UIHuntTipsView",
		PrefabPath = "UI/Prefabs/ZuoQi/UIHuntTips.prefab",
	},

	[UIWindowNames.UIHuntMaintain] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIZuoQi.View.UIHuntMaintainView",
		PrefabPath = "UI/Prefabs/ZuoQi/UIHuntMaintain.prefab",
		TweenTargetPath = "BgRoot",
	},

	[UIWindowNames.UIHuntLevelUp] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIZuoQi.View.UIHuntLevelUpView",
		PrefabPath = "UI/Prefabs/ZuoQi/UIHuntLevelUp.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIMyMount] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIZuoQi.View.UIMyMountView",
		PrefabPath = "UI/Prefabs/ZuoQi/UIMyMount.prefab",
		TweenTargetPath = "Container",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},

	[UIWindowNames.UIMountItemTips] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIZuoQi.View.UIMountItemTipsView",
		PrefabPath = "UI/Prefabs/ZuoQi/UIMountItemTips.prefab",
	},

	[UIWindowNames.UIMountShow] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIZuoQi.View.UIMountShowView",
		PrefabPath = "UI/Prefabs/ZuoQi/UIMountShow.prefab",
		TweenTargetPath = "Container",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},

	[UIWindowNames.UIMountAttribute] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIZuoQi.View.UIMountAttributeView",
		PrefabPath = "UI/Prefabs/ZuoQi/UIMountAttribute.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIMountAttrImprove] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIZuoQi.View.UIMountAttrImproveView",
		PrefabPath = "UI/Prefabs/ZuoQi/UIMountAttrImprove.prefab",
		TweenTargetPath = "BgRoot",
	},

	[UIWindowNames.UIMountChoice] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIZuoQi.View.UIMountChoiceView",
		PrefabPath = "UI/Prefabs/ZuoQi/UIMountChoice.prefab",
	},

	[UIWindowNames.UIMountChoiceSucc] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIZuoQi.View.UIMountChoiceSuccView",
		PrefabPath = "UI/Prefabs/ZuoQi/UIMountChoiceSucc.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIShenbingCopy] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIShenbingCopy.UIShenbingCopyView",
		PrefabPath = "UI/Prefabs/ShenbingCopy/UIShenbingCopyView.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		TweenTargetPath = "bg",
	},

	[UIWindowNames.UIShenBing] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIShenBing.View.UIShenBingView",
		PrefabPath = "UI/Prefabs/Shenbing/UIShenBing.prefab",
		IsShowTop = true,
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},

	[UIWindowNames.UIShenBingImprove] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIShenBing.View.UIShenBingImproveView",
		PrefabPath = "UI/Prefabs/Shenbing/UIShenBingImprove.prefab",
		IsShowTop = true,
	},

	[UIWindowNames.UIShenBingRebuild] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIShenBing.View.UIShenBingRebuildView",
		PrefabPath = "UI/Prefabs/Shenbing/UIShenBingRebuild.prefab",
		IsShowTop = true,
	},

	[UIWindowNames.UIShenBingStageUp] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIShenBing.View.UIShenBingStageUpView",
		PrefabPath = "UI/Prefabs/Shenbing/UIShenBingStageUp.prefab",
		TweenTargetPath = "bgRoot",
	},

	[UIWindowNames.UIMingwenSurvey] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIShenBing.View.UIMingwenSurveyView",
		PrefabPath = "UI/Prefabs/Shenbing/UIMingwenSurvey.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIShenBingRebuildSuccess] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIShenBing.View.UIShenBingRebuildSuccessView",
		PrefabPath = "UI/Prefabs/Shenbing/UIShenBingRebuildSuccess.prefab",
		TweenTargetPath = "BgRoot",
	},

	[UIWindowNames.UIShenbingSelect] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIShenbingCopy.UIShenbingSelect",
		PrefabPath = "UI/Prefabs/ShenbingCopy/UIShenbingSelect.prefab",
	},

	[UIWindowNames.UIShenbingDetailSelect] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIShenbingCopy.UIShenbingDetailSelect",
		PrefabPath = "UI/Prefabs/ShenbingCopy/UIShenbingDetailSelect.prefab",
		TweenTargetPath = "bg",
	},

	[UIWindowNames.UIShenBingMingWenRandShow] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIShenBing.View.UIShenBingMingWenRandShowView",
		PrefabPath = "UI/Prefabs/Shenbing/UIShenBingMingWenRandShow.prefab",
	},

	[UIWindowNames.UIArenaSettlement] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIBattleRecord.View.UIArenaSettlementView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleSettlement.prefab",
	},

	[UIWindowNames.UIGroupHerosSettlement] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIBattleRecord.View.UIGroupHerosSettlementView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleSettlement.prefab",
	},

	[UIWindowNames.UIShenbingCopySettlement] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIBattleRecord.View.UIShenbingCopySettlementView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleSettlement.prefab",
	},

	[UIWindowNames.UIArenaRecord] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIBattleRecord.View.UIArenaRecordView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleRecord.prefab",
	},

	[UIWindowNames.UIGuildBoss] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIGuildBoss.View.UIGuildBossView",
		PrefabPath = "UI/Prefabs/GuildBoss/UIGuildBoss.prefab",
		IsShowTop = true,
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		
	},

	[UIWindowNames.UIMain] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.Main.UIMainView",
		PrefabPath = "UI/Prefabs/Main/UIMain.prefab",
		IsShowTop = true,
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		NeedOpenAudio = false,
	},
	
	[UIWindowNames.UIFriendRequest] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIFriend.View.UIFriendRequestView",
		PrefabPath = "UI/Prefabs/Friend/UIFriendRequest.prefab",
		TweenTargetPath = "winPanel",
	},
	
	[UIWindowNames.UIFriendMain] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIFriend.View.UIFriendMainView",
		PrefabPath = "UI/Prefabs/Friend/UIFriendMain.prefab",
		TweenTargetPath = "winPanel",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},

	[UIWindowNames.UIFriendDetail] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIFriend.View.UIFriendDetailView",
		PrefabPath = "UI/Prefabs/Friend/UIFriendDetail.prefab",
		TweenTargetPath = "winPanel",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},
	
	[UIWindowNames.UIFriendTask] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIFriend.View.UIFriendTaskView",
		PrefabPath = "UI/Prefabs/Friend/UIFriendTask.prefab",
		TweenTargetPath = "Panel",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},

	[UIWindowNames.UIFriendGift] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIFriend.View.UIFriendGiftView",
		PrefabPath = "UI/Prefabs/Friend/UIFriendGift.prefab",
		TweenTargetPath = "winPanel",
	},

	[UIWindowNames.UIFriendTaskInvite] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIFriend.View.UIFriendTaskInviteView",
		PrefabPath = "UI/Prefabs/Friend/UIFriendTaskInvite.prefab",
		TweenTargetPath = "winPanel",
	},

	[UIWindowNames.UIChatMain] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIChat.View.UIChatMainView",
		PrefabPath = "UI/Prefabs/Chat/UIChatMain.prefab",
		TweenTargetPath = "winPanel",
	},

	[UIWindowNames.UIFightWar] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.FightWar.UIFightWarView",
		PrefabPath = "UI/Prefabs/FightWar/UIFightWar.prefab",
		IsShowTop = true,
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},

	[UIWindowNames.UIFriendRentOutSelect] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Lineup.UIFriendRentOutSelectView",
		PrefabPath = "UI/Prefabs/Lineup/UIWuJiangSelect.prefab",
	},

	[UIWindowNames.UIGuildBossSettlement] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIBattleRecord.View.UIGuildBossSettlementView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleSettlement.prefab",
	},

	[UIWindowNames.UIGuildBossBackSettlement] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIBattleRecord.View.UIGuildBossBackSettlementView",
		PrefabPath = "UI/Prefabs/GuildBoss/UIGuildBossBackSettle.prefab",
		IsShowTop = true,
	},

	[UIWindowNames.UIBaoxiang] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Common.UIBaoxiangView",
		PrefabPath = "UI/Prefabs/Common/UIBaoxiang.prefab"
	},

	[UIWindowNames.UIGraveCopy] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIGraveCopy.View.UIGraveCopyView",
		PrefabPath = "UI/Prefabs/GraveCopy/UIGraveCopy.prefab",
		TweenTargetPath = "bg",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},

	[UIWindowNames.UIGraveCopySettlement] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIBattleRecord.View.UIGraveCopySettlementView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleSettlement.prefab",
	},
	
	[UIWindowNames.UIDianJiangMain] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.DianJiang.UIDianJiangMainView",
		PrefabPath = "UI/Prefabs/DianJiang/UIDianJiangMain.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		IsShowTop = true,
	},

	[UIWindowNames.UIDianjiangAwardOne] = {
		Layer = UILayers.NormalLayer,
		View = "UI.DianJiang.UIDianJiangAwardOneView",
		PrefabPath = "UI/Prefabs/DianJiang/UIDianJiangAwardOne.prefab",
		TweenTargetPath = 'Container'
	},

	[UIWindowNames.UIDianjiangAwardTen] = {
		Layer = UILayers.NormalLayer,
		View = "UI.DianJiang.UIDianJiangAwardTenView",
		PrefabPath = "UI/Prefabs/DianJiang/UIDianJiangAwardTen.prefab",
		TweenTargetPath = 'Container'
	},

	[UIWindowNames.UIXiejiaView] = {
		Layer = UILayers.NormalLayer,
		View = "UI.DianJiang.UIXiejiaView",
		PrefabPath = "UI/Prefabs/DianJiang/UIXiejiaMain.prefab",
	},

	[UIWindowNames.UIDianJiang] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.DianJiang.UIDianJiangView",
		PrefabPath = "UI/Prefabs/DianJiang/UIDianJiang.prefab",
	},

	[UIWindowNames.UIDrum] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.DianJiang.UIDrumView",
		PrefabPath = "UI/Prefabs/DianJiang/UIDrum.prefab",
	},

	[UIWindowNames.UITaskMain] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UITask.View.UITaskView",
		PrefabPath = "UI/Prefabs/Task/UITaskMain.prefab",
		IsShowTop = true,
        OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},

	[UIWindowNames.UIInscriptionCopy] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIInscriptionCopy.UIInscriptionCopyView",
		PrefabPath = "UI/Prefabs/InscriptionCopy/UIInscriptionCopy.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		TweenTargetPath = 'bg',
	},

	[UIWindowNames.UIShenBingItemTips] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Common.UIShenBingItemTipsView",
		PrefabPath = "UI/Prefabs/Common/UIShenBingItemTips.prefab",
	},

	[UIWindowNames.UIShop] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Shop.UIShopView",
		PrefabPath = "UI/Prefabs/Shop/UIShop.prefab",
		IsShowTop = true,
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		TweenTargetPath = "bg",
	},

	[UIWindowNames.UIRebateShop] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Shop.UIRebateShopView",
		PrefabPath = "UI/Prefabs/Shop/UIRebateShop.prefab",
		IsShowTop = true,
		TweenTargetPath = "bg",
	},

	[UIWindowNames.UIBuyGoods] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Shop.UIBuyGoodsView",
		PrefabPath = "UI/Prefabs/Shop/UIBuyGoods.prefab",
		TweenTargetPath = "winPanel",
	},

	[UIWindowNames.UIGodBeast] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIGodBeast.View.UIGodBeastView",
		PrefabPath = "UI/Prefabs/GodBeast/UIGodBeast.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		IsShowTop = true,
	},

	[UIWindowNames.UIInscriptionSettlement] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIBattleRecord.View.UIInscriptionSettlementView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleSettlement.prefab",
	},
	
	[UIWindowNames.UIYuanmenSettlement] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIBattleRecord.View.UIYuanmenSettlementView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleSettlement.prefab",
	},

	[UIWindowNames.UIGuildWarMain] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.GuildWar.GuildWarMainView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildWarMain.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},

	[UIWindowNames.UIGuildWarEscortTask] = {
		Layer = UILayers.NormalLayer,
		View = "UI.GuildWar.GuildWarEscortTaskView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildWarEscortTask.prefab",
	},

	[UIWindowNames.UIGuildWarInviteCustodian] = {
		Layer = UILayers.NormalLayer,
		View = "UI.GuildWar.GuildWarInviteCustodianView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildWarInviteCustodianView.prefab",
	}, 

	[UIWindowNames.UIGuildWarRob] = {
		Layer = UILayers.NormalLayer,
		View = "UI.GuildWar.GuildWarRobView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildWarRobView.prefab",
	}, 

	[UIWindowNames.UIGuildWarEscortFail] = {
		Layer = UILayers.NormalLayer,
		View = "UI.GuildWar.GuildWarEscortFailView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildWarEscortFailView.prefab",
	}, 

	[UIWindowNames.UIGuildWarAchievement] = {
		Layer = UILayers.NormalLayer,
		View = "UI.GuildWar.GuildWarAchievementView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildWarAchievement.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIGuildWarUserTitle] = {
		Layer = UILayers.NormalLayer,
		View = "UI.GuildWar.GuildWarUserTitleView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildWarUserTitle.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIGuildWarCityDetail] = {
		Layer = UILayers.NormalLayer,
		View = "UI.GuildWar.GuildWarCityDetailView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildWarCityDetail.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIGuildWarRank] = {
		Layer = UILayers.NormalLayer,
		View = "UI.GuildWar.GuildWarRankView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildWarRank.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIGuildWarOffenceCityResult] = {
		Layer = UILayers.NormalLayer,
		View = "UI.GuildWar.GuildWarOffenceCityResultView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildWarOffenceCityResult.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIGuildWarGuildDetail] = {
		Layer = UILayers.NormalLayer,
		View = "UI.GuildWar.GuildWarGuildDetailView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildWarGuildDetail.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIGuildWarMemberList] = {
		Layer = UILayers.NormalLayer,
		View = "UI.GuildWar.GuildWarMemberListView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildWarMemberList.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIGuildWarDefLineup] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.GuildWar.GuildWarDefLineupView",
		PrefabPath = "UI/Prefabs/Lineup/LineupMain.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},

	[UIWindowNames.UIBattleGuildWarMain] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIBattle.View.UIBattleGuildWarMainView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleMain.prefab",
		NeedOpenAudio = false
	},

	[UIWindowNames.UIGuildWarCityLineupSelect] = {
		Layer = UILayers.NormalLayer,
		View = "UI.GuildWar.GuildWarCityLineupSelectView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildWarCityLineupSelect.prefab",
	},

	[UIWindowNames.UIBattleGuildWarRobMain] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIBattle.View.UIBattleGuildWarRobMainView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleMain.prefab",
	},

	[UIWindowNames.UIGuildWarBuffShop] = {
		Layer = UILayers.NormalLayer,
		View = "UI.GuildWar.GuildWarBufferShopView",
		PrefabPath = "UI/Prefabs/Shop/UIGuildWarBuffShop.prefab",
		TweenTargetPath = "bg",
	},

	[UIWindowNames.UIGuildWarSettlement] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIBattleRecord.View.UIGuildWarSettlementView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleSettlement.prefab",
	},

	[UIWindowNames.UIGuildWarRobSettlement] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIBattleRecord.View.UIGuildWarRobSettlementView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleSettlement.prefab",
	},

	[UIWindowNames.UIGuildWarLineupSelect] = {
		Layer = UILayers.NormalLayer,
		View = "UI.GuildWar.GuildWarLineupSelectView",
		PrefabPath = "UI/Prefabs/Guild/UIGuildWarLineupSelect.prefab",
	},

	[UIWindowNames.UIGodBeastMain] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIGodBeast.View.UIGodBeastMainView",
		PrefabPath = "UI/Prefabs/GodBeast/UIGodBeastMain.prefab",
		IsShowTop = true,
	},

	[UIWindowNames.UIGodBeastTipsDialog] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIGodBeast.View.UIGodBeastTipsDialogView",
		PrefabPath = "UI/Prefabs/GodBeast/UIGodBeastTipsDialog.prefab",
		TweenTargetPath = "BgRoot",
	},

	[UIWindowNames.UIGodBeastAllTalent] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIGodBeast.View.UIGodBeastAllTalentView",
		PrefabPath = "UI/Prefabs/GodBeast/UIGodBeastAllTalent.prefab",
		TweenTargetPath = "BgRoot",
	},

	[UIWindowNames.UIGodBeastSkillDetail] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIGodBeast.View.UIGodBeastSkillDetailView",
		PrefabPath = "UI/Prefabs/GodBeast/UIGodBeastSkillDetail.prefab",
		TweenTargetPath = "BgRoot",
	},

	[UIWindowNames.UIUserDetail] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIUser.View.UIUserDetailView",
		PrefabPath = "UI/Prefabs/User/UIUserDetail.prefab",
		TweenTargetPath = "contentPanel",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},

	[UIWindowNames.UILieZhuan] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UILieZhuan.View.UILieZhuanView",
		PrefabPath = "UI/Prefabs/LieZhuan/UILieZhuan.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		IsShowTop = true,
	},

	[UIWindowNames.UILieZhuanChoose] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UILieZhuan.View.UILieZhuanChooseView",
		PrefabPath = "UI/Prefabs/LieZhuan/UILieZhuanChoose.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},

	[UIWindowNames.UILieZhuanTeam] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UILieZhuan.View.UILieZhuanTeamView",
		PrefabPath = "UI/Prefabs/LieZhuan/UILieZhuanTeam.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UILieZhuanFightTroop] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UILieZhuan.View.UILieZhuanFightTroopView",
		PrefabPath = "UI/Prefabs/LieZhuan/UILieZhuanFightTroop.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIVip] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIVip.View.UIVipView",
		PrefabPath = "UI/Prefabs/Vip/UIVipMain.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
	},

	[UIWindowNames.UIShouChong] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIShouChong.View.ShouChongView",
		PrefabPath = "UI/Prefabs/ShouChong/UIShouChong.prefab",
		IsShowTop = true, 
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND, 
	},

	[UIWindowNames.UISevenDays] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UISevenDays.View.SevenDaysView",
		PrefabPath = "UI/Prefabs/SevenDays/UISevenDays.prefab",
		IsShowTop = true, 
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND, 
	},

	[UIWindowNames.UIYueKa] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIYueKa.View.YueKaView",
		PrefabPath = "UI/Prefabs/YueKa/UIYueKa.prefab",
		IsShowTop = true, 
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND, 
	},

	[UIWindowNames.UIDuoBao] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIDuoBao.View.DuoBaoView",
		PrefabPath = "UI/Prefabs/DuoBao/UIDuoBao.prefab",
		IsShowTop = true, 
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND, 
	},

	[UIWindowNames.UIDuoBaoRecord] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIDuoBao.View.DuoBaoRecordView",
		PrefabPath = "UI/Prefabs/DuoBao/DuoBaoRecord.prefab",
		TweenTargetPath = "Panel",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND, 
	},

	[UIWindowNames.UIVipShop] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIVip.View.UIVipShopView",
		PrefabPath = "UI/Prefabs/Vip/UIVipShop.prefab",
		IsShowTop = true,
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		TweenTargetPath = "bg",
	},

	[UIWindowNames.UIVipBuyDialog] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIVip.View.UIVipBuyDialogView",
		PrefabPath = "UI/Prefabs/Vip/UIVipBuyDialog.prefab",
		TweenTargetPath = "BgRoot",
	},

	[UIWindowNames.UIMutiLinpup] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Common.UIMutiLinpupView",
		PrefabPath = "UI/Prefabs/Common/UIMutiLinpup.prefab",
	},

	[UIWindowNames.UILieZhuanInvitation] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UILieZhuan.View.UILieZhuanInvitationView",
		PrefabPath = "UI/Prefabs/LieZhuan/UILieZhuanInvitation.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UILieZhuanCreateTeam] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UILieZhuan.View.UILieZhuanCreateTeamView",
		PrefabPath = "UI/Prefabs/LieZhuan/UILieZhuanCreateTeam.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UILieZhuanLineup] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UILieZhuan.View.UILieZhuanLineupView",
		PrefabPath = "UI/Prefabs/LieZhuan/UILieZhuanLineup.prefab",
		IsClearWhenSceneChg = true,
	},

	[UIWindowNames.UILieZhuanTeamLineupSelect] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UILieZhuan.View.UILieZhuanTeamLineupSelectView",
		PrefabPath = "UI/Prefabs/Lineup/UIWuJiangSelect.prefab",
	},
	
	[UIWindowNames.UIBattleLieZhuanMain] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIBattle.View.UIBattleLieZhuanMainView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleMain.prefab",
		NeedOpenAudio = false
	},

	[UIWindowNames.UIInviteTips] = {
		Layer = UILayers.InfoLayer,
		View = "UI.Common.UIInviteTipsView",
		PrefabPath = "UI/Prefabs/Common/UIInviteTips.prefab",
	},

	[UIWindowNames.UILieZhuanSettlement] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIBattleRecord.View.UILieZhuanSettlementView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleSettlement.prefab",
	},

	[UIWindowNames.UILieZhuanLineupSelect] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UILieZhuan.View.UILieZhuanLineupSelectView",
		PrefabPath = "UI/Prefabs/Lineup/UIWuJiangSelect.prefab",
	},

	[UIWindowNames.UIHorseRaceMain] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIHorseRace.View.UIHorseRaceMainView",
		PrefabPath = "UI/Prefabs/HorseRace/UIHorseRaceMain.prefab",
		TweenTargetPath = "Container",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND, 
	},

	[UIWindowNames.UIHorseRaceSelect] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIHorseRace.View.UIHorseRaceSelectView",
		PrefabPath = "UI/Prefabs/HorseRace/UIHorseRaceSelect.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UIDownloadTipsDialog] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Download.UIDownloadTipsDialogView",
		PrefabPath = "UI/Prefabs/Download/UIDownloadTipsDialog.prefab",
	},
	[UIWindowNames.UIDownloadDialog] = {
		Layer = UILayers.NormalLayer,
		View = "UI.Download.UIDownloadDialogView",
		PrefabPath = "UI/Prefabs/Download/UIDownloadDialog.prefab",
	},

	[UIWindowNames.UIBattleHorseRaceMain] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.UIBattle.View.UIBattleHorseRaceMainView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleHorseRaceMain.prefab",
		NeedOpenAudio = false,
	},

	[UIWindowNames.UIBattleHorseRaceSettlement] = {
		Layer = UILayers.NormalLayer,
		View = "UI.UIBattle.View.UIBattleHorseRaceSettlementView",
		PrefabPath = "UI/Prefabs/Battle/UIBattleHorseRaceSettlement.prefab",
		TweenTargetPath = "Container",
	},

	[UIWindowNames.UILieZhuanSoloLineupMain] = {
		Layer = UILayers.BackgroudLayer,
		View = "UI.Lineup.UILieZhuanSoloLineupMainView",
		PrefabPath = "UI/Prefabs/Lineup/LineupMain.prefab",
		OpenMode = CommonDefine.UI_OPEN_MODE_APPEND,
		IsClearWhenSceneChg = true,
	},
}

-- todo 按需require

return UIConfig