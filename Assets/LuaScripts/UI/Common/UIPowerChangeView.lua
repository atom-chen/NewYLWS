
local Time = Time
local UIUtil = UIUtil
local GameObjectPoolInstance = GameObjectPoolInst
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DoTween = CS.DOTween.DOTween
local Type_CanvasGroup = typeof(CS.UnityEngine.CanvasGroup)
local Type_Animator = typeof(CS.UnityEngine.Animator)

local mathf_lerp = Mathf.Lerp
local math_ceil = math.ceil
local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove
local string_len =  string.len
local EffectPath = "UI/Effect/Prefabs/UI_zhanli_up"

local UIPowerChangeView = BaseClass("UIPowerChangeView", UIBaseView)
local base = UIBaseView

local MsgPrefabPath = "UI/Prefabs/Message/PowerMsg.prefab"

function UIPowerChangeView:OnCreate()
    base.OnCreate(self)
   
    self.m_msgList = {}
    self.m_showMsgGoList = {}
    self.m_checkInterval = 1
    self.m_seq = 0
    self.m_isAdd = true
    self.m_layerName = UILogicUtil.FindLayerName(self.transform)
end

function UIPowerChangeView:OnEnable(...)
    base.OnEnable(self, ...)

    local _, power, beginY = ...
    self.m_isAdd = true
    self:AddPowers(power, beginY)
end

function UIPowerChangeView:OnDestroy()
    self:ClearMessage()
	base.OnDestroy(self)
end

function UIPowerChangeView:Update()

    if #self.m_showMsgGoList >= 1 then
        return
    end

    if #self.m_msgList > 0 and Time.frameCount % self.m_checkInterval == 0 then
        self:BeginTween()
    end
end

function UIPowerChangeView:OnAddListener()
	base.OnAddListener(self)
	
    self:AddUIListener(UIMessageNames.MN_POWER_CHANGE, self.AddPowers)
   
end

function UIPowerChangeView:OnRemoveListener()
	base.OnRemoveListener(self)
	
    self:RemoveUIListener(UIMessageNames.MN_POWER_CHANGE, self.AddPowers)
end

function UIPowerChangeView:OnDisable()
    UISortOrderMgr:GetInstance():PushSortingOrder(self, self.m_layerName)
    self:ClearEffect()
    base.OnDisable(self)
end

function UIPowerChangeView:AddPowers(power, beginY)
    if power == 0 or not power then
        return
    end
    
    local msg = {
        power = power,
        beginY = beginY,
    }
    table_insert(self.m_msgList, msg)

    self.m_checkInterval = #self.m_msgList == 1 and 1 or 5
end

function UIPowerChangeView:ClearMessage()
    self.m_msgList = {}

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_seq)
    self.m_seq = 0
    for i, v in ipairs(self.m_showMsgGoList) do
        GameObjectPoolInstance:RecycleGameObject(MsgPrefabPath, v)
    end
end

function UIPowerChangeView:ClearEffect()
    if self.m_effect then
        self.m_effect:Delete()
        self.m_effect = nil
    end
end

function UIPowerChangeView:BeginTween()
    self.m_seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
    UIGameObjectLoader:GetInstance():GetGameObject(self.m_seq, MsgPrefabPath, function(go)
        self.m_seq = 0
        
        if not IsNull(go) then

            table_insert(self.m_showMsgGoList, go)

            local trans = go.transform
            local msg = self.m_msgList[1]
            table_remove(self.m_msgList, 1)
            
            if msg.power > 0 then
                local sortOrder = UISortOrderMgr:GetInstance():PopSortingOrder(self, self.m_layerName)
                UIUtil.AddComponent(UIEffect, self, go.transform, sortOrder, EffectPath, function(effect)
                    effect:SetLocalPosition(Vector3.zero)
                    effect:SetLocalScale(Vector3.one)
                    self.m_effect = effect
                end)
            else
                self:ClearEffect()
            end
            
            trans:SetParent(self.transform)
            trans.localPosition = Vector3.New(0, msg.beginY, 0)
            trans.localScale = Vector3.one
            
            local animator = go:GetComponent(Type_Animator)
            local powerText = UIUtil.FindText(trans, "PowerText")
            powerText.text = ""
            local oneWait = 0
            local twoWait = 0

            if msg.power > 0 then
                oneWait = 0.41
                twoWait = 0.55
                self.m_isAdd = true
                animator:Play("Add")
            elseif msg.power < 0 then
                oneWait = 0.33
                twoWait = 0.4
                msg.power = msg.power * -1
                self.m_isAdd = false
                animator:Play("Reduce")
            end

            coroutine.start(function()
                coroutine.waitforseconds(oneWait)
                local start, dur = 0, 0.6
                local power = 0
                local deltaTime = Time.deltaTime

                while start < dur do
                    start = start + deltaTime
                    if not IsNull(powerText) then
                        if self.m_isAdd then
                            powerText.text = string_format("+%d", power)
                        else
                            powerText.text = string_format("-%d", power)
                        end
                    end
                    power = mathf_lerp(0, msg.power, start/dur)
                    power = math_ceil(power)
                    coroutine.waitforframes(1)
                end
                if not IsNull(powerText) then
                    if self.m_isAdd then
                        powerText.text = string_format("+%d", msg.power)
                    else
                        powerText.text = string_format("-%d", msg.power)
                    end
                end
                coroutine.waitforseconds(twoWait)
                self:MoveComplete()
            end)
            
        end
    end)
end

function UIPowerChangeView:MoveComplete()
    if #self.m_showMsgGoList > 0 then
        local go = table_remove(self.m_showMsgGoList, 1)
        if not IsNull(go) then
            self:ClearEffect()
            GameObjectPoolInstance:RecycleGameObject(MsgPrefabPath, go)
        end
        if #self.m_msgList == 0 then
            self:CloseSelf()
        end
    end
end

return UIPowerChangeView