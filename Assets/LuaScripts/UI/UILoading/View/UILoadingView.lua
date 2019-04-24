local table_insert = table.insert
local Random = Mathf.Random
local string_format = string.format
local math_floor = math.floor
local Type_Sprite = typeof(CS.UnityEngine.Sprite)
local GameUtility = CS.GameUtility
local BattleEnum = BattleEnum
local UILoadingView = BaseClass("UILoadingView", UIBaseView)
local base = UIBaseView

function UILoadingView:OnCreate()
	base.OnCreate(self)
	self.m_value = 0
	self.m_loadingTipsList = require("Config.Define.LoadingTips")
	self.m_downloadMsg = Language.GetString(4204)

	self.m_loadingTipsText, self.m_downloadTips = UIUtil.GetChildTexts(self.transform, {
		"ContentRoot/LoadingDesc",
		"ContentRoot/downloadTips",
    })
	self.loading_slider = self:AddComponent(UISlider, "ContentRoot/SliderBar")
	self.loading_slider:SetValue(0.0)
	self.m_loadingBgImg = UIUtil.AddComponent(UIImage, self, "BgRoot/BG", AtlasConfig.DynamicLoad)
	self.m_loadingBgImg = self.m_loadingBgImg:GetImage()
	self.m_defaultSprite = self.m_loadingBgImg.sprite
end

function UILoadingView:SetValue(value)
	self.m_value = value
	self.loading_slider:SetValue(self.m_value)
end

function UILoadingView:GetValue()
	return self.m_value
end

function UILoadingView:OnEnable(...)
	base.OnEnable(self, ...)

	local _, battleType = ...
	self:ShowLoadingTips(battleType)
end

function UILoadingView:OnDestroy()
	self.loading_slider = nil
	self.m_value = 0
	base.OnDestroy(self)
end

function UILoadingView:PreloadLoadingBg(battleType, callback)
	local path, name = self:GetImagePathAndName(battleType)

	AtlasManager:GetInstance():LoadImageAsync(path, name, function(sprite)
		if IsNull(sprite) then
			self.m_loadingBgImg.sprite = self.m_defaultSprite
		else
			if Type_Sprite == sprite:GetType() then
				self.m_loadingBgImg.sprite = sprite
			else
				self.m_loadingBgImg.sprite = GameUtility.CreateSpriteFromTexture(sprite)
			end
		end

		callback()
	end)
end

function UILoadingView:GetImagePathAndName(battleType)
	if battleType == BattleEnum.BattleType_COPY then
		local copyCfg = ConfigUtil.GetCopyCfgByID(CtlBattleInst:GetLogic():GetBattleParam().copyID)
		local sectionCfg = ConfigUtil.GetCopySectionCfgByID(copyCfg.section)
		return ImageConfig.Loading, sectionCfg.loading_bg
	elseif battleType == BattleEnum.BattleType_SHENSHOU then
		local copyID = CtlBattleInst:GetLogic():GetBattleParam().copyID 
		local cfg = ConfigUtil.GetGragonCopyCfgByID(copyID)
		if cfg then 
			local monsID = cfg.monsterid
			local loadingTipsCfg = self.m_loadingTipsList[monsID]
			if loadingTipsCfg then
				return loadingTipsCfg.imgPath, loadingTipsCfg.img[1] 
			else
				return self.m_loadingTipsList[1000].imgPath, self.m_loadingTipsList[1000].img[1]
			end 
		else
			return self.m_loadingTipsList[1000].imgPath, self.m_loadingTipsList[1000].img[1]
		end  
	else
		local loadingTipsCfg = self.m_loadingTipsList[battleType]
		if loadingTipsCfg then
			return loadingTipsCfg.imgPath, loadingTipsCfg.img[1]
		else
			return self.m_loadingTipsList[1000].imgPath, self.m_loadingTipsList[1000].img[1]
		end
	end
end

function UILoadingView:ShowLoadingTips(battleType) 
	local tipsList = nil
	if battleType == BattleEnum.BattleType_SHENSHOU then
		local copyID = CtlBattleInst:GetLogic():GetBattleParam().copyID  
		local cfg = ConfigUtil.GetGragonCopyCfgByID(copyID)
		if cfg then 
			local monsID = cfg.monsterid
			local loadingTipsCfg = self.m_loadingTipsList[monsID]
			if loadingTipsCfg then
				tipsList = loadingTipsCfg.desc
			else
				tipsList = self.m_loadingTipsList[1000].desc
			end
		else 
			tipsList = self.m_loadingTipsList[1000].desc
		end
	else 
		local loadingTipsCfg = self.m_loadingTipsList[battleType]
		if loadingTipsCfg then
			tipsList = loadingTipsCfg.desc
		else
			tipsList = self.m_loadingTipsList[1000].desc
		end 
	end

	if tipsList and #tipsList > 1 then
			local randNum = Random(1, #tipsList)
			self.m_loadingTipsText.text = tipsList[randNum]
	end
end

function UILoadingView:Update()
	local curABName, progress = AssetBundleMgrInst:GetDownloadingABInfo()
	if curABName then
		self.m_downloadTips.text = string_format(self.m_downloadMsg, curABName, math_floor(progress * 100))
	else
		self.m_downloadTips.text = ''
	end
end

return UILoadingView