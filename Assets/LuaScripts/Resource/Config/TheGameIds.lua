--[[
-- added by wsh @ 2018-01-08
-- 特效
--]]

local TheGameIds = 
{
	AttrMsgPrefab = "UI/Prefabs/Battle/FloatAttrMsg.prefab",
	BuffMaskPrefab = "UI/Prefabs/Battle/BattleBuffMask.prefab",
	BattleBuffMaskBloodRed = "UI/Prefabs/Battle/BattleBuffMaskBloodRed.prefab",
	BattleBuffMaskRed = "UI/Prefabs/Battle/BattleBuffMaskRed.prefab",
	BattleBuffMaskPurple = "UI/Prefabs/Battle/BattleBuffMaskPurple.prefab",
	BattleBuffMaskGreen = "UI/Prefabs/Battle/BattleBuffMaskGreen.prefab",
	BattleBuffMaskYellow = "UI/Prefabs/Battle/BattleBuffMaskYellow.prefab",
	BattleBuffMaskBlue = "UI/Prefabs/Battle/BattleBuffMaskBlue.prefab",
	BattleBuffMaskGrey = "UI/Prefabs/Battle/BattleBuffMaskGrey.prefab",
	BattleBuffMaskGold = "UI/Prefabs/Battle/BattleBuffMaskGold.prefab",
	BattleBuffMaskBlack = "UI/Prefabs/Battle/BattleBuffMaskBlack.prefab",
	WorldArtFont = "UI/Prefabs/Battle/WorldArtFont.prefab",
	WaveMsgPrefab = "UI/Prefabs/Battle/FloatWaveMsg.prefab",
	FontPrefabPath = "UI/Prefabs/Battle/FontPrefab.prefab",
	
	BattleWin = "UI/Effect/Prefabs/win",
	BattleLose = "UI/Effect/Prefabs/lose",
	BattleFinish = "UI/Effect/Prefabs/jieshu",

	CommonWujiangCardPrefab = "UI/Prefabs/Common/WujiangCardItem.prefab",
	CommonBagItemPrefab = "UI/Prefabs/Common/BagItemPrefab.prefab",
	CommonAwardItemPrefab = "UI/Prefabs/Common/AwardItemPrefab.prefab",
	CommonItemDetailContainerPrefab = "UI/Prefabs/Common/ItemDetailContainer.prefab",
	CommonBattleBagItemPrefab = "UI/Prefabs/Common/BattleBagItemPrefab.prefab",
	SimpleAwardItemPrefab = "UI/Prefabs/Common/SimpleAwardItem.prefab",
	FirstAttrItemPrefab = "UI/Prefabs/Common/FirstAttrItem.prefab",
	Role3DCameraPrefab = "UI/Prefabs/Common/Role3DCamera.prefab",
	CommonWujiangRootPath = "UI/Prefabs/Common/WujiangRoot.prefab",
	YuanmenSceneObjPrefab = "UI/Prefabs/Common/YuanmenSceneObj.prefab",
	DuoBaoSceneObjPrefab = "UI/Prefabs/Common/DuoBaoSceneObj.prefab",
	WujiangRootPath = "UI/Prefabs/ZhuGong/WujiangLevelUpRoot.prefab",
	LieZhuanSceneObjPath = "UI/Prefabs/LieZhuan/LieZhuanSceneObj.prefab",
    GuildBossBgPath = "UI/Prefabs/GuildBoss/EmBattle.prefab",

	--主公头像
	UserItemPrefab = "UI/Prefabs/Common/UserItemPrefab.prefab",
	GuildItemPrefab = "UI/Prefabs/GuildBoss/GuildItemPrefab.prefab",
	
	-- 战损
	BattleRecordLeftItemPrefab = "UI/Prefabs/Battle/BattleLeftRecordItem.prefab",
	BattleRecordRightItemPrefab = "UI/Prefabs/Battle/BattleRightRecordItem.prefab",

	--军团
	GuildIconItemPrefab = "UI/Prefabs/Guild/GuildIconItemPrefab.prefab",
	GuildRankItemPrefab = "UI/Prefabs/GuildBoss/UIGuildBossRankItem.prefab",

	--竞技场特效
	ArenaDuanWeiJinJie = "UI/Effect/Prefabs/Ui_arena_duanweijinjie",
	ArenaDuanWeiJinJieBg = "UI/Effect/Prefabs/Ui_arena_duanweijinjie_BG",
	ArenaRankEffectPath = "UI/Effect/Prefabs/ui_arena_rank_effect",
	ArenaLevelUpEffect1 = "UI/Effect/Prefabs/Ui_arena_levelup_zuanshi2wangzhe",
	ArenaLevelUpEffect2 = "UI/Effect/Prefabs/Ui_arena_levelup_huangjin2zuanshi",
	ArenaLevelUpEffect3 = "UI/Effect/Prefabs/Ui_arena_levelup_baiyin2huangjin",
	ArenaLevelUpEffect4 = "UI/Effect/Prefabs/Ui_arena_levelup_qingtong2baiyin",

	--特效路径
	ui_shengxing_icon_fx_path =  "UI/Effect/Prefabs/ui_shengxing_icon_fx",
	ui_shengxing_star_fx_path =  "UI/Effect/Prefabs/ui_shengxing_star_fx",
	ui_shengjitiao01_fx_path =  "UI/Effect/Prefabs/ui_shengjitiao01_fx",
	Ui_bigmapmisson_chapter_fx = "UI/Effect/Prefabs/Ui_bigmapmisson_chapter_fx",
	UI_guankakaifang = "UI/Effect/Prefabs/UI_guankakaifang",
	dianjiang_bao = "UI/Effect/Prefabs/dianjiang_bao%d.prefab",
	ui_zhiyin = "UI/Effect/Prefabs/ui_zhiyin",

	--好友
	FriendItemPrefab = "UI/Prefabs/Friend/FriendItemPrefab.prefab",
	FriendChatItemPrefab = "UI/Prefabs/Friend/FriendChatItemPrefab.prefab",
	FriendOperateItemPrefab = "UI/Prefabs/Friend/FriendOperateItemPrefab.prefab",
	FriendBattleHelpRecordItem = "UI/Prefabs/Friend/FriendBattleHelpRecordItem.prefab",
	FriendTaskInviteItemPrefab = "UI/Prefabs/Friend/FriendTaskInviteItemPrefab.prefab",
	FriendTaskItemPrefab = "UI/Prefabs/Friend/FriendTaskItemPrefab.prefab",

	--聊天
	ChatItemPrefab = "UI/Prefabs/Chat/ChatItemPrefab.prefab",
	ChatTimeItemPrefab = "UI/Prefabs/Chat/ChatTimeItemPrefab.prefab",
	ChatSysItemPrefab = "UI/Prefabs/Chat/ChatSysItemPrefab.prefab",
	MainChatItemPrefab = "UI/Prefabs/Main/MainChatItemPrefab.prefab",

	TongQianPrefab =  "Effect/Prefab/Battle/tongqian.prefab",
	BaoxiangPrefab = "Effect/Prefab/Battle/baoxiang.prefab",
	Baoxiang2Prefab = "Effect/Prefab/Battle/baoxiang2.prefab",
	
	ChatFaceItemPrefab = "UI/Prefabs/Chat/chatFaceItemPrefab.prefab",

	--主界面任务item
	MainTaskItemPrefab = "UI/Prefabs/Main/UIMainTaskItemPrefab.prefab",

	--群雄逐鹿
	GroupHerosWarRecordItemPrefab = "UI/Prefabs/GroupHerosWar/RecordItem.prefab",

	--神兽天赋特效
	Ui_shenshou_tianfu_jihuo = "UI/Effect/Prefabs/Ui_shenshou_tianfu_jihuo",

	--赛马特效
	saima_smoke = "Effect/Common/saima_smoke.prefab",
	saima_zhongdianxian = "Effect/Common/saima_zhongdianxian.prefab",
	saima_zhongdianxian_bao = "Effect/Common/saima_zhongdianxian_bao.prefab",

	--copyItem特效
	UI_bigmapmisson_select_blue_path = "UI/Effect/Prefabs/Ui_bigmapmisson_select_blue",
	UI_bigmapmisson_select_purple_path = "UI/Effect/Prefabs/Ui_bigmapmisson_select_purple",

	FloatMsgPrefab = "UI/Prefabs/Battle/FloatMsg.prefab",
	FloatSkillMsgLeftPrefab = "UI/Prefabs/Battle/FloatSkillMsgLeft.prefab",
	FloatSkillMsgRightPrefab = "UI/Prefabs/Battle/FloatSkillMsgRight.prefab",

	-- 布阵
	EmployWujiangItemPrefab = "UI/Prefabs/Lineup/EmployWujiangItem.prefab",
	DragonIconItemPrefab = "UI/Prefabs/Lineup/DragonIconItem.prefab",
	TalentItemPrefab = "UI/Prefabs/Lineup/talentItemPrefab.prefab",

	-- 任务
	
	TaskItemPrefabPath = "UI/Prefabs/Task/UITaskItem.prefab",
	 
	-- 商店
	ShopShelfItemPath = "UI/Prefabs/Common/ShopShelfItem.prefab",
	RebateShopShelfItemPath = "UI/Prefabs/Common/RebateShopShelfItem.prefab",
	ShopTabItemPath = "UI/Prefabs/Shop/ShopTabItem.prefab",
	VipShopGoodsItemPath = "UI/Prefabs/Vip/VipShopGoodsItem.prefab",
	VipGoodsDetailItemPath = "UI/Prefabs/Vip/VipGoodsDetailItem.prefab",

	-- 登录
	ServerGroupItemPrefab = "UI/Prefabs/Login/ServerGroupItem.prefab",
	ServerItemPrefab = "UI/Prefabs/Login/ServerItem.prefab",
	ServerRoleItemPrefab = "UI/Prefabs/Login/ServerRoleItem.prefab",

	shenbing_qianghua_fx_path =  "UI/Effect/Prefabs/shenbing_qianghua_fx.prefab",
	shenbing_chongzhu_fx_path =  "UI/Effect/Prefabs/shenbing_chongzhu_fx.prefab",
}

return TheGameIds