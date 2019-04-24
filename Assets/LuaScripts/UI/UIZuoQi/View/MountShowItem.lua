
local string_format = string.format
local math_ceil = math.ceil
local math_floor = math.floor
local GameUtility = CS.GameUtility
local UILogicUtil = UILogicUtil
local UIUtil = UIUtil
local Language = Language
local ConfigUtil = ConfigUtil
local CommonDefine = CommonDefine
local PreloadHelper = PreloadHelper
local MountMgr = Player:GetInstance():GetMountMgr()
local UserMgr = Player:GetInstance():GetUserMgr()

local MountShowItem = BaseClass("MountShowItem", UIBaseItem)
local base = UIBaseItem

function MountShowItem:OnCreate()
    base.OnCreate(self)

    self.m_gardenNameText, self.m_coolingTimeText, self.m_leftCount,
    self.m_cantShowText, self.m_yuanbaoText, self.m_btnText = UIUtil.GetChildTexts(self.transform, {
        "frame/GradenText",
        "maintain/coolingTime",
        "maintain/leftCount",
        "cantShowText",
        "maintain/yuanbao/Text",
        "maintain/Button/Text",
    })

    self.m_clickBtn, self.m_noMountGo, self.m_maintainGo, self.m_mountPos,
    self.m_yuanbaoTr = UIUtil.GetChildTransforms(self.transform, {
        "maintain/Button",
        "NoMountBg",
        "maintain",
        "mountPos",
        "maintain/yuanbao",
    })

    self.m_yuanbaoGo = self.m_yuanbaoTr.gameObject
    self.m_maintainGo = self.m_maintainGo.gameObject
    self.m_noMountGo = self.m_noMountGo.gameObject
    self.m_showData = false
    self.m_coolingTime = 0
  
    
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_clickBtn.gameObject, onClick)
end

function MountShowItem:OnDestroy()
    
    UIUtil.RemoveClickEvent(self.m_clickBtn.gameObject)
    base.OnDestroy(self)
end

function MountShowItem:OnClick(go)
    if go.name == "Button" then
        if self.m_showData.status ~= 1 and self.m_showData.status ~= 2 then
            if not self.m_showData.left_times or self.m_showData.left_times <= 0 then
                UILogicUtil.FloatAlert(Language.GetString(3554))
                return
            end
        
            if self.m_coolingTime > 0 then
                local allTime = UserMgr:GetSettingData().horse_show_cd
                local priceCfg = ConfigUtil.GetShowClearCDPriceCfgByID(self.m_showData.clear_cd_times + 1)
                local yuanbaoCount = math_ceil((self.m_coolingTime / allTime) * priceCfg.price)
                local data = {
                    titleMsg = Language.GetString(3553),
                    contentMsg = string_format(Language.GetString(3552), yuanbaoCount),
                    yuanbao = yuanbaoCount,
                    buyCallback = Bind(self, self.ClearHorseCD),
                }
                UIManagerInst:OpenWindow(UIWindowNames.UIBuyTipsDialog, data)
            else
                UIManagerInst:OpenWindow(UIWindowNames.UIMountChoice, self.m_showData.id)
            end
        end
    end
end

function MountShowItem:HorseShowClick()
    local letfTime = self.m_showData.cd_end_time - Player:GetInstance():GetServerTime()
    if letfTime > 0 then
        local allTime = UserMgr:GetSettingData().horse_show_cd
        local priceCfg = ConfigUtil.GetShowClearCDPriceCfgByID(self.m_showData.clear_cd_times + 1)
        local yuanbaoCount = math_ceil((letfTime / allTime) * priceCfg.price)
        local data = {
            titleMsg = Language.GetString(3553),
            contentMsg = string_format(Language.GetString(3552), yuanbaoCount),
            yuanbao = yuanbaoCount,
            buyCallback = Bind(self, self.ClearHorseCD),
        }
        UIManagerInst:OpenWindow(UIWindowNames.UIBuyTipsDialog, data)
    else
        UIManagerInst:OpenWindow(UIWindowNames.UIMountChoice, self.m_showData.id)
    end
end

function MountShowItem:ClearHorseCD()
    MountMgr:ReqClearShowCD(self.m_showData.id)
    UIManagerInst:OpenWindow(UIWindowNames.UIMountChoice, self.m_showData.id)
end

function MountShowItem:SetData(showData, clipBounds)
    if not showData then
        return
    end
    
    self.m_showData = showData
    self.m_coolingTime = showData.cd_end_time - Player:GetInstance():GetServerTime()
    self.m_btnText.text = Language.GetString(3547)
    self.m_yuanbaoGo:SetActive(false)
    if self.m_coolingTime > 0 then
        self.m_yuanbaoGo:SetActive(true)
        self.m_btnText.text = Language.GetString(3553)
        local allTime = UserMgr:GetSettingData().horse_show_cd
        local priceCfg = ConfigUtil.GetShowClearCDPriceCfgByID(self.m_showData.clear_cd_times + 1)
        self.m_yuanbaoText.text = math_ceil((self.m_coolingTime / allTime) * priceCfg.price)
    end

    local huntCfg = ConfigUtil.GetHuntCfgByID(showData.id)
    if huntCfg then
        if showData.level <= 0 then
            self.m_gardenNameText.text = string_format(Language.GetString(3590), huntCfg.name)
        else
            self.m_gardenNameText.text = string_format(Language.GetString(3543), huntCfg.name, showData.level)
        end
        self.m_leftCount.text = string_format(Language.GetString(3544), showData.left_times, showData.total_times)
        if showData.status == CommonDefine.Hunt_Lock then
            self.m_maintainGo:SetActive(false)
            self.m_noMountGo:SetActive(true)
            self.m_cantShowText.text = string_format(Language.GetString(3545), "解锁")
        elseif showData.status == CommonDefine.Hunt_NeedMaintain then
            self.m_maintainGo:SetActive(false)
            self.m_noMountGo:SetActive(true)
            self.m_cantShowText.text = string_format(Language.GetString(3545), "维护")
        else
            self.m_maintainGo:SetActive(true)
            self.m_noMountGo:SetActive(false)
            self.m_cantShowText.text = ""
            self:ShowMountModel(huntCfg.horse_id, clipBounds)
        end
    end
end

function MountShowItem:ShowMountModel(mountId, clipBounds)
    if not mountId then
        Logger.LogError("no mountId!")
        return
    end
    local pool = GameObjectPoolInst
    local resPath = PreloadHelper.GetShowoffHorsePath(mountId, 5)

    pool:GetGameObjectAsync(resPath, function(inst)
        if IsNull(inst) then
            pool:RecycleGameObject(resPath, inst)
            return
        end

        local trans = inst.transform

        trans:SetParent(self.m_mountPos)
        trans.localScale = Vector3.New(140, 140, 140)
        local position =  Vector3.New(-9.6, -118, 0)
        if mountId == 23004 then
            position = Vector3.New(-26, -118, 0)
        elseif mountId == 23005 then
            position = Vector3.New(-9.6, -130, 0)
        end
        trans.localPosition = position
        trans.localEulerAngles = Vector3.New(7, 151, 0)
        
        GameUtility.RecursiveSetLayer(inst, Layers.UI)

        local clipRegion = Vector4.New(clipBounds[0].x, clipBounds[0].y, clipBounds[2].x, clipBounds[2].y)
       
        UIUtil.ClipGameObjectWithBounds(trans, clipRegion)
    end)
end

function MountShowItem:ChangeTime(time)
    local timeText = ""
    if time >= 0 then
        local hour = time / 3600
        hour = math_floor(hour)
        time = time - hour * 3600
        local minute = time / 60
        minute = math_floor(minute)
        time = time - minute * 60
        local second = math_floor(time)
        timeText = string.format("%02d:%02d:%02d", hour, minute, second)
    else
        timeText = ""
    end
    return timeText
end

function MountShowItem:Update()
    if self.m_coolingTime > 0 then
        self.m_coolingTime = self.m_coolingTime - Time.deltaTime
        self.m_coolingTimeText.text = self:ChangeTime(self.m_coolingTime)
    else
        self.m_coolingTimeText.text = ""
    end
end

return MountShowItem