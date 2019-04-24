--[[
-- added by wsh @ 2017-11-30
-- 1、加载全局模块，所有全局性的东西都在这里加载，好集中管理
-- 2、模块定义时一律用local再return，模块是否是全局模块由本脚本决定，在本脚本加载的一律为全局模块
-- 3、对必要模块执行初始化
-- 注意：
-- 1、全局的模块和被全局模块持有的引用无法GC，除非显式设置为nil
-- 2、除了单例类、通用的工具类、逻辑上的静态类以外，所有逻辑模块不要暴露到全局命名空间
-- 3、Unity侧导出所有接口到CS命名空间，访问cs侧函数一律使用CS.xxx，命名空间再cs代码中给了，这里不需要处理
-- 4、这里的全局模块是相对与游戏框架或者逻辑而言，lua语言层次的全局模块放Common.Main中导出
--]]

-- 加载全局模块
require "Framework.Common.BaseClass"
Config = Config or require "Global.Config"
if Config.IsClient or Config.IsSyncTest then
require "fixmath"
require "pathing"
require "cutil"
Json = require "rapidjson"
    -- msg
    MsgIDMap = require "Net.Config.MsgIDMap"
    MsgIDDefine = require "Net.Config.MsgIDDefine"
end
require "Common.Utils"


-- 创建全局模块
Singleton = require "Framework.Common.Singleton"
Updatable = require "Framework.Common.Updatable"
UpdatableSingleton = require "Framework.Common.UpdatableSingleton"
SortingLayerNames = require "Global.SortingLayerNames"
Language = require "Config.Define.Language"
PlotLanguage = require "Config.PlotLanguage.PlotLanguage"
ErrorCode = require "Config.Define.ErrorCode"
Layers = require "Config.Define.Layers"
Logger = require "Framework.Logger.Logger"
Profiler = require "Framework.Logger.Profiler"
require "Framework.Updater.Coroutine"
require "Global.DOTweenDef"
require("GameLogic.Battle.BattleRander")
require "GameLogic.Sequence.SequenceDef"
require "GameLogic.Sequence.SequenceCommands"
SequenceMgr = require "GameLogic.Sequence.SequenceMgr"
require "GameLogic.Timeline.TimelineDef"
TimelineMgr = require "GameLogic.Timeline.TimelineMgr"
require "Config.Define.CommonDefine"
require "Config.Define.ItemDefine"
require "Config.Define.CountryTypeDefine"
ACTOR_ATTR = require "Config.Define.ActorAttr"
require "GameLogic.Battle.BattleDef"
require "Framework.Resource.Effect.EffectDef"
TheGameIds = require "Resource.Config.TheGameIds"
require "Config.Define.SysIDs"

-- AssetBundle
require("Framework.AssetBundle.Config.ABConfig")
AssetBundleMgr = require("Framework.AssetBundle.AssetBundleMgr")
AssetBundleMgrInst = AssetBundleMgr:GetInstance()
ABTipsMgr = require("Framework.AssetBundle.ABTipsMgr")
AssetLoaderFactory = require("Framework.AssetBundle.ResourceLoader.AssetLoaderFactory")
ABLoaderFactory = require("Framework.AssetBundle.ResourceLoader.ABLoaderFactory")
ResourceAsyncLoaderFactory = require("Framework.AssetBundle.ResourceLoader.ResourceAsyncLoaderFactory")
require("GameLogic.Common.Setting")

-- game data
require "Config.ConfigUtil"
require "Framework.UI.Util.PBUtil"
DataManager = require "DataCenter.DataManager"
ClientData = require "DataCenter.ClientData.ClientData"
UserData = require "DataCenter.UserData.UserData"
Player = require "DataCenter.Player"

-- ui base
UIUtil = require "Framework.UI.Util.UIUtil"
TimeUtil = require "Framework.UI.Util.TimeUtil"
UIBaseComponent = require "Framework.UI.Base.UIBaseComponent"
UIBaseContainer = require "Framework.UI.Base.UIBaseContainer"
UIBaseView = require "Framework.UI.Base.UIBaseView"
UIBaseItem = require "Framework.UI.Base.UIBaseItem"

-- res
ResourcesManager = require "Framework.Resource.ResourcesManager"
ResourcesManagerInst = ResourcesManager:GetInstance()
GameObjectPool = require "Framework.Resource.GameObjectPool"
GameObjectPoolInst = GameObjectPool:GetInstance()
GameObjectPoolNoActive = require "Framework.Resource.GameObjectPoolNoActive"
GameObjectPoolNoActiveInst = GameObjectPoolNoActive:GetInstance()

require "Resource.ResourceHelper" 
UIGameObjectLoader = require "Framework.UI.UIGameObjectLoader"
ActorShowLoader = require "UI.UIWuJiang.ActorShowLoader"

-- ui component
UILayer = require "Framework.UI.Component.UILayer"
UICanvas = require "Framework.UI.Component.UICanvas"
UIText = require "Framework.UI.Component.UIText"
UIImage = require "Framework.UI.Component.UIImage"
UISlider = require "Framework.UI.Component.UISlider"
UIInput = require "Framework.UI.Component.UIInput"
UIButton = require "Framework.UI.Component.UIButton"
UIToggleButton = require "Framework.UI.Component.UIToggleButton"
UIWrapComponent = require "Framework.UI.Component.UIWrapComponent"
UITabGroup = require "Framework.UI.Component.UITabGroup"
UIButtonGroup = require "Framework.UI.Component.UIButtonGroup"
UIWrapGroup = require "Framework.UI.Component.UIWrapGroup"
UIEffect = require "Framework.UI.Component.UIEffect"
LoopScrowView = require "Framework.UI.Component.LoopScrowView"
CenterOnChildView = require "Framework.UI.Component.CenterOnChildView"

-- ui window
GamePromptMgr = require "Framework.UI.GamePromptMgr"
UILayers = require "Framework.UI.UILayers"
UIManager = require "Framework.UI.UIManager"

if Config.IsClient or Config.IsSyncTest then
UIManagerInst = UIManager:GetInstance()
end

UIMessageNames = require "Framework.UI.Message.UIMessageNames"
UIWindowNames = require "UI.Config.UIWindowNames"
UIConfig = require "UI.Config.UIConfig"
UISortOrderMgr = require "Framework.UI.UISortOrderMgr"
require "GameLogic.Guide.GuideDef"
GuideMgr = require "GameLogic.Guide.GuideMgr"

-- update & time
Timer = require "Framework.Updater.Timer"
TimerManager = require "Framework.Updater.TimerManager"
UpdateManager = require "Framework.Updater.UpdateManager"
LogicUpdater = require "GameLogic.Main.LogicUpdater"

-- scenes
BaseScene = require "Framework.Scene.Base.BaseScene"
SceneManager = require "Framework.Scene.SceneManager"
SceneManagerInst = SceneManager:GetInstance()
SceneConfig = require "Scenes.Config.SceneConfig"

-- atlas
AtlasConfig = require "Resource.Config.AtlasConfig"
AtlasManager = require "Framework.Resource.AtlasManager"

UILogicUtil = require "Framework.UI.Util.UILogicUtil"

-- image
ImageConfig = require "Resource.Config.ImageConfig"

-- effect
BaseEffect = require "Framework.Resource.Effect.Base.BaseEffect"

-- audio
AudioMgr = require("Framework.Resource.Audio.AudioMgrFactory").Get()

-- net
require "Net.NetDef"
HallConnector = require "Net.Connector.HallConnector"
NetMonitor = require "Net.Monitor.NetMonitor"

-- battle
require "GameLogic.Battle.FrameDebugger.BattleRecordDef"
require "GameLogic.Battle.Skill.SkillDef"
require "GameLogic.Battle.Status.StatusDef"
require "GameLogic.Battle.Medium.MediumDef"
require "GameLogic.Battle.BattleLogic.Dragon.DragonDef"
require "GameLogic.Battle.BattleParam"
require "GameLogic.Battle.Skill.Formular"
CtlBattle = require "GameLogic.Battle.CtlBattle"
CtlBattleInst = CtlBattle:GetInstance()

BattleRecorder = require "GameLogic.Battle.FrameDebugger.BattleRecorder"
FrameDebugger = require "GameLogic.Battle.FrameDebugger.FrameDebugger"
FrameDebuggerInst = FrameDebugger:GetInstance()

StatusFactory = require "GameLogic.Battle.Status.StatusFactory"
StatusFactoryInst = StatusFactory:GetInstance()
MediumManager = require "GameLogic.Battle.Medium.MediumManager"
MediumManagerInst = MediumManager:GetInstance()

SkillPool = require "GameLogic.Battle.Skill.SkillPool"
SkillPoolInst = SkillPool:GetInstance()

ActorManager = require "GameLogic.Battle.ActorManager"
ActorManagerInst = ActorManager:GetInstance()

Actor = require "GameLogic.Battle.Actors.Actor"
require("GameLogic.Battle.Actors.ActorUtil")
ActorComponent = require "GameLogic.Battle.Component.ActorComponent"
MediumComponent = require "GameLogic.Battle.Component.MediumComponent"
ComponentMgr = require("GameLogic.Battle.Component.CompMgrFactory").Get()
FightData = require "GameLogic.Battle.FightData"
SkillItem = require "GameLogic.Battle.Skill.SkillItem"
EffectMgr = require("Framework.Resource.Effect.EffectMgrFactory").Get()
BattleCameraMgr = require("GameLogic.Battle.Camera.BattleCameraFactory").Get()
DragonTimelineMgr = require("GameLogic.Battle.DragonTimeline.DragonTimelineFactory").Get()
FrameCmdFactory = require "GameLogic.Battle.BattleCommand.FrameCmdFactory"
WaveGoMgr = require('GameLogic.Battle.WaveGo.WaveGoMgrFactory').Get()
WavePlotMgr = require('GameLogic.Battle.WavePlot.WavePlotMgrFactory').Get()
TimeScaleMgr = require('GameLogic.Battle.TimeScale.TimeScaleMgrFactory').Get()
DieShowMgr = require('GameLogic.Battle.DieShow.DieShowMgrFactory').Get()

-- 命签
SkillInscriptionItem = require "GameLogic.Battle.Skill.inscription.SkillInscriptionItem"
SkillHorseItem = require "GameLogic.Battle.Skill.horseSkill.SkillHorseItem"

-- SDK
require "GameLogic.SDK.PlatformDef"
PlatformMgr = require "GameLogic.SDK.PlatformMgr"

-- 单例类初始化
if Config.IsClient then
GamePromptMgr:GetInstance()
ActorShowLoader:GetInstance()
UIGameObjectLoader:GetInstance()
UISortOrderMgr:GetInstance()
end
DataManager:GetInstance()
Player:GetInstance()
ResourcesManager:GetInstance()
UpdateManager:GetInstance()
AtlasManager:GetInstance()
LogicUpdater:GetInstance()
HallConnector:GetInstance()
-- CtlBattle:GetInstance()
-- ActorManager:GetInstance()
-- SkillPool:GetInstance()
-- StatusFactory:GetInstance()
SequenceMgr:GetInstance()
-- MediumManager:GetInstance()
-- todo 检查 GameLoading相关的能不能用lua 好像不需要放在plugin里了


-- mri = require("Global.MemoryReferenceInfo")

-- mri.m_cMethods.DumpMemorySnapshotComparedFile("./", "Compared", -1, 
-- "./LuaMemRefInfo-All-[20190221-100014]-[1-Before].txt", 
-- "./LuaMemRefInfo-All-[20190221-100147]-[2-After].txt")