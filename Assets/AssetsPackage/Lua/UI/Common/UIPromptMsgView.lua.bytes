
local Time = Time
local GameObjectPoolInstance = GameObjectPoolInst
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DoTween = CS.DOTween.DOTween
local Type_CanvasGroup = typeof(CS.UnityEngine.CanvasGroup)

local table_insert = table.insert
local table_remove = table.remove
local string_len =  string.len

local UIPromptMsgView = BaseClass("UIPromptMsgView", UIBaseView)
local base = UIBaseView

local MsgPrefabPath = "UI/Prefabs/Message/PromptMsg.prefab"
local InitScale = Vector3.one * 0.1

function UIPromptMsgView:OnCreate()
    base.OnCreate(self)
   
    self.m_msgList = {}
    self.m_showMsgGoList = {}
    self.m_checkInterval = 1
    self.m_nowShowMsgStr = "" 
    self.m_seq = 0
end

function UIPromptMsgView:OnEnable(...)
    base.OnEnable(self, ...)

    local _, msg, beginY = ...
    self:AddPrompts(msg, beginY)
end

function UIPromptMsgView:OnDestroy()
    self:ClearMessage()
	base.OnDestroy(self)
end

function UIPromptMsgView:Update()

    if #self.m_msgList > 0 and Time.frameCount % self.m_checkInterval == 0 then
        self:BeginTween()
    end
end

function UIPromptMsgView:OnAddListener()
	base.OnAddListener(self)
	
    self:AddUIListener(UIMessageNames.MN_ADD_PROMPT, self.AddPrompts)
    self:AddUIListener(UIMessageNames.MN_CLEAR_MESSAGE, self.ClearMessage)
   
end

function UIPromptMsgView:OnRemoveListener()
	base.OnRemoveListener(self)
	
    self:RemoveUIListener(UIMessageNames.MN_ADD_PROMPT, self.AddPrompts)
    self:RemoveUIListener(UIMessageNames.MN_CLEAR_MESSAGE, self.ClearMessage)
end

function UIPromptMsgView:AddPrompts(str, fBeginY)
    if str == "" or not str then
        return
    end

    --时间间隔太短，重复的文字返回
    if str == self.m_nowShowMsgStr then
        return
    end

    local msg = {
        msg = str,
        beginY = fBeginY
    }
    table_insert(self.m_msgList, msg)

    self.m_checkInterval = #self.m_msgList == 1 and 1 or 40
end

function UIPromptMsgView:ClearMessage()
    self.m_msgList = {}

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_seq)
    self.m_seq = 0
end

function UIPromptMsgView:BeginTween()
    self.m_seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
    UIGameObjectLoader:GetInstance():GetGameObject(self.m_seq, MsgPrefabPath, function(go)
        self.m_seq = 0
        
        if not IsNull(go) then
            
            if #self.m_msgList == 0 then
                GameObjectPoolInstance:RecycleGameObject(MsgPrefabPath, go)
                return
            end

            self:MoveDown()  --其他msg顶下去

            table_insert(self.m_showMsgGoList, go)
            
            local trans = go.transform
            --暂定
            --DOTweenShortcut.DOKill(trans)
            local canvasGroup = go:GetComponent(Type_CanvasGroup)
            canvasGroup.alpha = 1

            local msg = self.m_msgList[1]
            table_remove(self.m_msgList, 1)
           
            trans:SetParent(self.transform)
            trans.localPosition = Vector3.New(0, msg.beginY, 0)
            trans.localScale = InitScale
            
            self.m_nowShowMsgStr = msg.msg
             
            local msgText = UIUtil.FindText(trans, "msgText")
            msgText.text = msg.msg

            local delayTime = string_len(self.m_nowShowMsgStr) > 5 and 1.2 or 0.5
            --两次缩放
            local tweener = DOTweenShortcut.DOScale(trans, 1.5, 0.2)
            DOTweenSettings.SetEase(tweener, DoTweenEaseType.OutQuad)

            tweener = DOTweenShortcut.DOScale(trans, 1, 0.2)
            DOTweenSettings.SetEase(tweener, DoTweenEaseType.OutQuad)
            DOTweenSettings.SetDelay(tweener, 0.2)

            --渐变、移动
            tweener = DOTweenShortcut.DOLocalMoveY(trans, -200, 1)
            DOTweenSettings.SetDelay(tweener, delayTime)

            local function setterFunc(alpha)
                canvasGroup.alpha = alpha
            end

            tweener = DoTween.To(setterFunc, 1, 0, 1)
            DOTweenSettings.SetDelay(tweener, delayTime)
            DOTweenSettings.OnComplete(tweener, Bind(self,self.MoveComplete))
        end
    end)
end

function UIPromptMsgView:MoveComplete()
    if #self.m_showMsgGoList > 0 then
        local go = table_remove(self.m_showMsgGoList, 1)
        self.m_nowShowMsgStr = ""
        GameObjectPoolInstance:RecycleGameObject(MsgPrefabPath, go)
        if #self.m_showMsgGoList == 0 then
            self:CloseSelf()
        end
    end
end

function UIPromptMsgView:MoveDown()
    for i, v in ipairs(self.m_showMsgGoList) do 
        if not IsNull(v) then
            local transform = v.transform
            transform.localPosition = Vector3.New(0, transform.localPosition.y - 50, 0)
        end
    end
end

return UIPromptMsgView