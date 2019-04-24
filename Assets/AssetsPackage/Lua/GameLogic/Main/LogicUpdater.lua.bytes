--[[
-- added by wsh @ 2017-01-09
-- 游戏逻辑Updater，游戏逻辑模块可能需要严格的驱动顺序
--]]
local Time = Time
local LogicUpdater = BaseClass("LogicUpdater", UpdatableSingleton)
local traceback = debug.traceback

function LogicUpdater:Update()
	local hallConnector = HallConnector:GetInstance()
	local status,err = pcall(hallConnector.Update, hallConnector, Time.deltaTime)
	if not status then
		Logger.LogError("hallConnector update err : "..err.."\n"..traceback())
	end

	if not Config.IsSyncTest then
		if SceneManagerInst:IsBattleScene() then
			DragonTimelineMgr:Update()
			BattleCameraMgr:Update(Time.deltaTime)
			WaveGoMgr:Update(Time.deltaTime)
			WavePlotMgr:Update(Time.deltaTime)
			DieShowMgr:Update(Time.deltaTime)
			CtlBattleInst:Update(Time.deltaTime)
		end
		NetMonitor:GetInstance():Update(Time.deltaTime)
		TimeScaleMgr:Update(Time.deltaTime)
		AssetBundleMgrInst:Update()

		if SceneManagerInst:IsHomeScene() then
			GamePromptMgr:GetInstance():Update(Time.deltaTime)
		end
		GuideMgr:GetInstance():Update(Time.deltaTime)
	end
end

function LogicUpdater:LateUpdate()
	SequenceMgr:GetInstance():LateUpdate()
	EffectMgr:LateUpdate(Time.deltaTime)
	AudioMgr:Update(Time.deltaTime)
	FrameDebuggerInst:Update(Time.deltaTime)

	if SceneManagerInst:IsBattleScene() then
		CtlBattleInst:LateUpdate(Time.deltaTime)
		ComponentMgr:LateUpdate(Time.deltaTime)
	end
end

function LogicUpdater:FixedUpdate()
end

function LogicUpdater:Dispose()
end



return LogicUpdater
