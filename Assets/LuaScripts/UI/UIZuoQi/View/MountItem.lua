
local string_format = string.format
local math_ceil = math.ceil
local math_floor = math.floor
local table_insert = table.insert
local GameUtility = CS.GameUtility
local random = math.random
local UILogicUtil = UILogicUtil
local UIUtil = UIUtil
local Language = Language
local PreloadHelper = PreloadHelper
local CommonDefine = CommonDefine
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local HorseShowClass = require "UI.UIWuJiang.HorseShow" 
local MountMgr = Player:GetInstance():GetMountMgr()

local MountItem = BaseClass("MountItem", UIBaseItem)
local base = UIBaseItem

function MountItem:OnCreate()
    base.OnCreate(self)
    local choiceBtnText
    self.m_stageAreaText, self.m_attrText, choiceBtnText = UIUtil.GetChildTexts(self.transform, {
        "other/stageArea/Text",
        "other/AttributeText",
        "other/ChoiceButton/Text",
    })

    choiceBtnText.text = Language.GetString(3546)
    self.m_choiceBtn, self.m_otherTr = UIUtil.GetChildTransforms(self.transform, {
        "other/ChoiceButton",
        "other"
    })
    self.m_callback = nil
    self.m_mountData = false
    self.m_horseShow = nil
    self.m_mountPos = nil
    self.m_mountPos2 = nil
    self.m_mountModels = {}

    
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_choiceBtn.gameObject, onClick)
end

function MountItem:OnClick(go)
    if go.name == "ChoiceButton" then
        if self.m_callback then
            self.m_callback(self.m_mountData.index)
            self.m_callback = nil
        end
    end
end

function MountItem:OnDestroy()
    local pool = GameObjectPoolInst
    for _, v in ipairs(self.m_mountModels) do        
        pool:RecycleGameObject(v.path, v.go)
    end
    self.m_mountModels = {}

    UIUtil.RemoveClickEvent(self.m_choiceBtn.gameObject)
    base.OnDestroy(self)
end

function MountItem:HideChoiceBtn()
    self.m_choiceBtn.gameObject:SetActive(false)
end

function MountItem:UpdateAttr()
    local baseAttr = self.m_mountData.base_first_attr
    if baseAttr then
        local attrNameList = CommonDefine.first_attr_name_list
        local attrStr = ""
        for i, v in pairs(attrNameList) do
            local val = math_ceil(baseAttr[v])
            if val then
                local attrType = CommonDefine[v]
                if attrType then
                    attrStr = attrStr..string_format(Language.GetString(3549), Language.GetString(attrType + 10), tostring(val))
                    if i == 2 then
                        attrStr = attrStr.."\n"
                    elseif i == 1 or i == 3 then
                        attrStr = attrStr.."    "
                    end
                end
            end
        end
        self.m_attrText.text =  attrStr
    end
end

function MountItem:SetData(mountData, randomseed, angle, pos1, pos2, callback)
    if not mountData then
        return
    end

    self.m_callback = callback
    self.m_mountData = mountData
    self.m_mountPos = pos1
    self.m_mountPos2 = pos2
    self.m_stageAreaText.text = string_format(Language.GetString(3550), mountData.stage, mountData.max_stage)
    self:ShowMountModel(mountData.id, mountData.stage, angle)
    local baseAttr = mountData.base_first_attr
    if baseAttr then
        local attrNameList = CommonDefine.first_attr_name_list
        local attrStr = ""
        math.randomseed(randomseed)
        local randomCount = random(0, 2)
        local randomList= {}
        if randomCount > 0 then
            for i = 1, randomCount do
                randomList[i] = random(1, 4)
                if i == 2 then
                    while randomList[i] == randomList[i - 1] do
                        randomList[i] = random(1, 4)
                    end
                end
            end
        end

        for i, v in pairs(attrNameList) do
            local val = math_ceil(baseAttr[v])
            for _, j in pairs(randomList) do
                if j == i then
                    val = self:ChangeNumber(val)
                end
            end
            if val then
                local attrType = CommonDefine[v]
                if attrType then
                    val = tostring(val)
                    if #val < 2 then
                        attrStr = attrStr..string_format(Language.GetString(3578), Language.GetString(attrType + 10), tostring(val))
                    else
                        attrStr = attrStr..string_format(Language.GetString(3549), Language.GetString(attrType + 10), tostring(val))
                    end
                    if i == 2 then
                        attrStr = attrStr.."\n"
                    elseif i == 1 or i == 3 then
                        attrStr = attrStr.."    "
                    end
                end
            end
        end
        self.m_attrText.text =  attrStr
    end
end

function MountItem:ChangeNumber(number)
    local str = tostring(number)
    local count = random(1, 2)
    if #str == 1 then
        return "?"
    else
        if count == 1 then
            return math_floor(number / 10).."?"
        else
            return "??"
        end
    end
end

function MountItem:ShowMountModel(mountId, mountLevel, angle)
    if not mountId then
        Logger.LogError("no mountId!")
        return
    end
    local pool = GameObjectPoolInst
    local resPath = PreloadHelper.GetShowoffHorsePath(mountId, mountLevel)

    pool:GetGameObjectAsync(resPath, function(inst)
        if IsNull(inst) then
            pool:RecycleGameObject(resPath, inst)
            return
        end
        self.m_horseShow = HorseShowClass.New(inst, mountID, mountLevel, true)
        self.m_horseShow:PlayAnim(BattleEnum.ANIM_MOVE)
        
        inst.transform:SetParent(self.m_mountPos)
        inst.transform.localScale = Vector3.New(0.8, 0.8, 0.8)
        inst.transform.localPosition = Vector3.New(0, 0, 0)
        inst.transform.localEulerAngles = Vector3.New(4, angle, 0)
        
        GameUtility.RecursiveSetLayer(inst, Layers.IGNORE_RAYCAST)
        GameUtility.SetShadowHeight(inst, inst.transform.position.y, 0)
        coroutine.start(function()
            coroutine.waitforseconds(0.2)
            self.m_moveTweenner = DOTweenShortcut.DOMove(inst.transform, self.m_mountPos2.position, 0.8)
            DOTweenSettings.SetUpdate(self.m_moveTweenner, true)
            coroutine.waitforseconds(0.8)
            self.m_horseShow:PlayAnim(BattleEnum.ANIM_IDLE)
            DOTweenShortcut.DOLocalMoveY(self.m_otherTr, 0, 0.4)
            coroutine.waitforseconds(0.5)

            TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, 'UIMountChoice')
        end)

        table_insert(self.m_mountModels, {path = resPath, go = inst})
    end)
end

return MountItem