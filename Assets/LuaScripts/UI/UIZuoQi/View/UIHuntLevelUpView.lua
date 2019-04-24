
local table_insert = table.insert
local math_ceil = math.ceil
local Language = Language
local UIUtil = UIUtil
local ConfigUtil = ConfigUtil
local AtlasConfig = AtlasConfig
local GameObject = CS.UnityEngine.GameObject
local UISliderHelper = typeof(CS.UISliderHelper)
local GameUtility = CS.GameUtility
local string_format = string.format
local math_floor = math.floor
local MountMgr = Player:GetInstance():GetMountMgr()
local UserMgr = Player:GetInstance():GetUserMgr()

local UIGameObjectLoaderInstance = UIGameObjectLoader:GetInstance()
local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"

local UIHuntLevelUpView = BaseClass("UIHuntLevelUpView", UIBaseView)
local base = UIBaseView

function UIHuntLevelUpView:OnCreate()
    base.OnCreate(self)
    local titleText, attrAreaDesc, attrDesc, SpendText, levelUpBtnText
    titleText, self.m_gardenNameText, self.m_gardenNameText2, self.m_mountInfoText, self.m_skillText, self.m_curLevelText, 
    self.m_nextLevelText, attrAreaDesc, attrDesc, self.m_curArrtAreaText, self.m_nextAttrAddText,
    SpendText, self.m_fullLevelText, levelUpBtnText, self.m_spendTimeText, self.m_conditionText = UIUtil.GetChildTexts(self.transform, {
        "Container/bg/title/Text",
        "Container/bg/MountInfo/frame/GradenText",
        "Container/bg/GardenName",
        "Container/bg/MountInfo/Desc",
        "Container/bg/MountInfo/Skill",
        "Container/bg/CurLevel",
        "Container/bg/NextLevel/Text",
        "Container/bg/AttrAreaDesc",
        "Container/bg/AttrDesc",
        "Container/bg/AttrArea",
        "Container/bg/NextAttrAdd",
        "Container/bg/Spend/Text",
        "Container/bg/FullLevel",
        "Container/bg/Button/Text",
        "Container/bg/SpendTime",
        "Container/bg/ConditionText",
    })

    self.m_closeBtn, self.m_levelUpBtn, self.m_mountTr, self.m_nextLevelTr, self.m_spendTr, self.m_gridTr,
    self.m_ruleBtnTr = UIUtil.GetChildTransforms(self.transform, {
        "backBtn",
        "Container/bg/Button",
        "Container/bg/MountInfo/mountPos",
        "Container/bg/NextLevel",
        "Container/bg/Spend",
        "Container/bg/Spend/Grid",
        "Container/bg/title/ruleButton",
    })

    self.m_tongshuaiSlider = UIUtil.FindComponent(self.transform, UISliderHelper, "Container/bg/AttrSliders/Slider")
    self.m_wuliSlider = UIUtil.FindComponent(self.transform, UISliderHelper, "Container/bg/AttrSliders/Slider2")
    self.m_zhiliSlider = UIUtil.FindComponent(self.transform, UISliderHelper, "Container/bg/AttrSliders/Slider3")
    self.m_fangyuSlider = UIUtil.FindComponent(self.transform, UISliderHelper, "Container/bg/AttrSliders/Slider4")

    self.m_nextLevelGo = self.m_nextLevelTr.gameObject
    self.m_spendGo = self.m_spendTr.gameObject
    titleText.text = Language.GetString(3533)
    attrAreaDesc.text = Language.GetString(3565)
    attrDesc.text = Language.GetString(3566)
    SpendText.text = Language.GetString(3531)
    levelUpBtnText.text = Language.GetString(3523)
    self.m_mountModels = {}
    self.m_huntId = 0
    self.m_spendItemList = {}
    self.m_seq = 0
    self.m_levelUpGardenId = nil
    self.m_levelUpGardenFinishTime = nil
    
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_levelUpBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_ruleBtnTr.gameObject, onClick)
end

function UIHuntLevelUpView:OnClick(go)
    if go.name == "Button" then
        if self.m_levelUpGardenId then
            local gameSetting = UserMgr:GetSettingData()
            local serverTime = Player:GetInstance():GetServerTime()
            if gameSetting.hunt_levelup_reduce_cd_per_yuanbao == 0 then
                return
            end
            local yuanbaoCount2 = math_ceil((self.m_levelUpGardenFinishTime - serverTime) / gameSetting.hunt_levelup_reduce_cd_per_yuanbao)
            local huntCfg = ConfigUtil.GetHuntCfgByID(self.m_levelUpGardenId)
            if huntCfg then
                UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(3537), string_format(Language.GetString(3597), huntCfg.name, yuanbaoCount2),
                Language.GetString(10), Bind(self, self.ClearLevelUpCD), Language.GetString(5))
            end
        else
            MountMgr:ReqHuntLevelUp(self.m_huntId)
        end
    elseif go.name == "backBtn" then
        self:CloseSelf()
    elseif go.name == "ruleButton" then
        UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 126) 
    end
end

function UIHuntLevelUpView:ClearLevelUpCD()
    MountMgr:ReqClearLevelUpCD(self.m_levelUpGardenId)
    self:CloseSelf()
end

function UIHuntLevelUpView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_levelUpBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_ruleBtnTr.gameObject)
    base.OnDestroy(self)
end

function UIHuntLevelUpView:OnAddListener()
    base.OnAddListener(self)

    self:AddUIListener(UIMessageNames.MN_HUNT_RSP_LEVELUP, self.LevelUpSuc)
end

function UIHuntLevelUpView:OnRemoveListener()
    base.OnRemoveListener(self)

    self:RemoveUIListener(UIMessageNames.MN_HUNT_RSP_LEVELUP, self.LevelUpSuc)
end

function UIHuntLevelUpView:LevelUpSuc()
    self:CloseSelf()
end

function UIHuntLevelUpView:OnEnable(...)
    base.OnEnable(self, ...)
    local _, id, level, levelUpGardenId, levelUpGardenFinishTime = ...
    
    if not id then
        return
    end
    
    self.m_huntId = id
    self.m_levelUpGardenId = levelUpGardenId
    self.m_levelUpGardenFinishTime = levelUpGardenFinishTime
    local huntCfg = ConfigUtil.GetHuntCfgByID(id)
    local levelUpCfg = ConfigUtil.GetHuntLevelUpCfgByID(id * 100 + level)
    if huntCfg and levelUpCfg then
        self:UpdateMount(huntCfg)
        
        self.m_gardenNameText2.text = huntCfg.name
        self.m_curLevelText.text = string_format(Language.GetString(3579), level)
        self.m_nextLevelText.text = string_format(Language.GetString(3579), level + 1)
        if level >= huntCfg.Maxlevel then
            self.m_nextLevelGo:SetActive(false)
            self.m_spendGo:SetActive(false)
            self.m_levelUpBtn.gameObject:SetActive(false)
            self.m_fullLevelText.text = Language.GetString(3568)
            self.m_nextAttrAddText.text = ""
            self.m_spendTimeText.text = ""
        else
            self.m_nextLevelGo:SetActive(true)
            self.m_spendGo:SetActive(true)
            self.m_levelUpBtn.gameObject:SetActive(true)
            self.m_fullLevelText.text = ""
            self.m_spendTimeText.text = string_format(Language.GetString(3536), self:GetLeftTimeText(levelUpCfg.levelup_need_time))
        end
        local curTongshuai = huntCfg.max_tongshuai
        local limitTongshuai = huntCfg.max_tongshuai
        local curWuli = huntCfg.max_wuli
        local limitWuli = huntCfg.max_wuli
        local curZhili = huntCfg.max_zhili
        local limitZhili = huntCfg.max_zhili
        local curFangyu = huntCfg.max_fangyu
        local limitFangyu = huntCfg.max_fangyu
        for i = 1, level do
            local upCfg = ConfigUtil.GetHuntLevelUpCfgByID(id * 100 + i)
            if upCfg then
                curTongshuai = curTongshuai + upCfg.max_tongshuai
                curWuli = curWuli + upCfg.max_wuli
                curZhili = curZhili + upCfg.max_zhili
                curFangyu = curFangyu + upCfg.max_fangyu
            end
        end
        for i = 1, huntCfg.Maxlevel do
            local upCfg = ConfigUtil.GetHuntLevelUpCfgByID(id * 100 + i)
            if upCfg then
                limitTongshuai = limitTongshuai + upCfg.max_tongshuai
                limitWuli = limitWuli + upCfg.max_wuli
                limitZhili = limitZhili + upCfg.max_zhili
                limitFangyu = limitFangyu + upCfg.max_fangyu
            end
        end
        local maxValue = self:GetMaxValue(limitTongshuai, limitWuli, limitZhili, limitFangyu)
        self.m_tongshuaiSlider:UpdateSliderImmediately(curTongshuai/maxValue)
        self.m_wuliSlider:UpdateSliderImmediately(curWuli/maxValue)
        self.m_zhiliSlider:UpdateSliderImmediately(curZhili/maxValue)
        self.m_fangyuSlider:UpdateSliderImmediately(curFangyu/maxValue)
        self.m_curArrtAreaText.text = string_format(Language.GetString(3569), 1, curTongshuai,
        1, curWuli, 1, curZhili, 1, curFangyu)
        local nextLevelUpCfg = ConfigUtil.GetHuntLevelUpCfgByID(id * 100 + level + 1)
        if nextLevelUpCfg then
            self.m_nextAttrAddText.text = string_format(Language.GetString(3570), nextLevelUpCfg.max_tongshuai, nextLevelUpCfg.max_wuli, nextLevelUpCfg.max_zhili,
        nextLevelUpCfg.max_fangyu)
        end

        local awardList = {}
        for i = 1, 3 do
            if levelUpCfg["levelup_item_id"..i] > 0 then
                table_insert(awardList, {id = levelUpCfg["levelup_item_id"..i], count = levelUpCfg["levelup_item_count"..i]})
            end
        end

        if #self.m_spendItemList == 0 and self.m_seq == 0 then
            self.m_seq = UIGameObjectLoaderInstance:PrepareOneSeq()
            UIGameObjectLoaderInstance:GetGameObjects(self.m_seq, CommonAwardItemPrefab, #awardList, function(objs)
                self.m_seq = 0
                
                if objs then
                    for i = 1, #objs do
                        local awardItem = CommonAwardItem.New(objs[i], self.m_gridTr, CommonAwardItemPrefab)
                        awardItem:SetLocalScale(Vector3.one * 0.75)
                        table_insert(self.m_spendItemList, awardItem)
                        
                        local awardIconParam = AwardIconParamClass.New(awardList[i].id, awardList[i].count)
                        awardItem:UpdateData(awardIconParam)
                    end
                end
            end)
        else
            for i, v in ipairs(self.m_spendItemList) do
                local awardIconParam = AwardIconParamClass.New(awardList[i].id, awardList[i].count)
                v:UpdateData(awardIconParam)
            end
        end

        local otherHuntLevel = MountMgr:GetHuntLevelByID(levelUpCfg.ground_id)
        local otherHuntCfg = ConfigUtil.GetHuntCfgByID(levelUpCfg.ground_id)
        if otherHuntCfg and otherHuntLevel < levelUpCfg.level then
            self.m_conditionText.text = string_format(Language.GetString(3571), otherHuntCfg.name, levelUpCfg.level)
        else
            self.m_conditionText.text = ""
        end
    end

end

function UIHuntLevelUpView:UpdateMount(cfg)
    self.m_gardenNameText.text = cfg.name
    local mountCfg = ConfigUtil.GetZuoQiCfgByID(cfg.horse_id)
    if mountCfg then
        self.m_mountInfoText.text = mountCfg.des
        local skillCfg = ConfigUtil.GetInscriptionAndHorseSkillCfgByID(mountCfg.skill_id)
        if skillCfg then
            local desc = skillCfg["exdesc"..5]
            if desc and desc ~= "" then
                local exdesc = desc:gsub("{(.-)}", function(m)
                    local v = skillCfg[m]
                    if v then
                        return v
                    end
                end)
                self.m_skillText.text = string_format(Language.GetString(3567), exdesc)
            end
        end
    end

    local pool = GameObjectPoolInst
    local resPath = PreloadHelper.GetShowoffHorsePath(cfg.horse_id, 5)

    pool:GetGameObjectAsync(resPath, function(inst)
        if IsNull(inst) then
            pool:RecycleGameObject(resPath, inst)
            return
        end

        local trans = inst.transform

        trans:SetParent(self.m_mountTr)
        trans.localScale = Vector3.New(140, 140, 140)
        trans.localPosition = Vector3.New(-9.6, -118, 0)
        trans.localEulerAngles = Vector3.New(7, 151, 0)
        
        GameUtility.RecursiveSetLayer(inst, Layers.UI)
        table_insert(self.m_mountModels, {path = resPath, go = inst})
    end)
end

function UIHuntLevelUpView:GetLeftTimeText(time)
    local hour = math_floor(time / 3600)
    if hour < 24 then
        if hour <= 0 then
            return string_format(Language.GetString(3580), math_floor(time / 60))
        else
            return string_format(Language.GetString(3581), hour)
        end
    else
        if hour % 24 == 0 then
            return string_format(Language.GetString(3582), math_floor(hour / 24))
        else
            return string_format(Language.GetString(3583), math_floor(hour / 24), (hour % 24))
        end
    end
end

function UIHuntLevelUpView:GetMaxValue(a, b, c, d)
    local list = {a, b, c, d}
    local max = 0
    for i, v in ipairs(list) do
        if v > max then
            max = v
        end
    end
    return max
end

function UIHuntLevelUpView:OnDisable()
    UIGameObjectLoaderInstance:CancelLoad(self.m_seq)
    self.m_seq = 0
    
    for _, v in ipairs(self.m_spendItemList) do
        v:Delete()
    end
    self.m_spendItemList = {}

    local pool = GameObjectPoolInst
    for _, v in ipairs(self.m_mountModels) do        
        pool:RecycleGameObject(v.path, v.go)
    end
    self.m_mountModels = {}
    base.OnDisable(self)
end

function UIHuntLevelUpView:OnTweenOpenComplete()
    TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)
end

return UIHuntLevelUpView