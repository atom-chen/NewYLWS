local ActorBubbleItem = BaseClass("ActorBubbleItem", UIBaseItem)
local base = UIBaseItem
local Time = Time
local Vector3 = Vector3
local GameUtility = CS.GameUtility
local Vector3ScaleR = Vector3.New(1, 1, 1)
local Vector3Pos1 = Vector3.New(125, -25, 0)
local Vector3Pos2= Vector3.New(280, -69, 0)
local Vector3ScaleL = Vector3.New(-1, 1, 1)
local VectorPos4 = Vector3.New(110, -25, 0)
local VectorPos5 = Vector3.New(265, -69, 0)
local MSG_CHANGE_INTERVAL = 2

function ActorBubbleItem:OnCreate()
	base.OnCreate(self)
	self.m_messageList = nil
	self.m_messageIndex = 0
	self.m_time = 0
	self.m_actorID = 0
	self.m_mainCam = nil
	self.m_parent = nil
	self.m_isOver = false

	self.m_bgTrans, self.m_nameRectTrans, self.m_msgRectTrans = UIUtil.GetChildRectTrans(self.transform, {
		"bg",
		"nameLbl",
        "msgLbl",
    })

    self.m_nameText, self.m_msgText = UIUtil.GetChildTexts(self.transform, {
		"nameLbl",
        "msgLbl",
	})
	
	self.m_bgTrans = self.m_bgTrans.transform
end

function ActorBubbleItem:OnDestroy()
	self.m_messageList = nil
	self.m_messageIndex = 0
	self.m_time = 0
	self.m_actorID = 0
	self.m_mainCam = nil
	self.m_parent = nil
	self.m_isOver = false

    base.OnDestroy(self)
end

function ActorBubbleItem:SetData(actorID, characterName, messageList, parent)
	local isRight = true
	self.m_messageList = messageList
	self.m_messageIndex = 1
	self.m_time = 0
	self.m_actorID = actorID
	self.m_mainCam = BattleCameraMgr:GetMainCamera()
	self.m_parent = parent

	self.m_nameText.text = PlotLanguage.GetString("GuideLanguage", tonumber(characterName))
	if isRight then
		self.m_bgTrans.localScale = Vector3ScaleR
		self.m_nameRectTrans.anchoredPosition = Vector3Pos1
		self.m_msgRectTrans.anchoredPosition = Vector3Pos2
	else
		self.m_bgTrans.localScale = Vector3ScaleL
		self.m_nameRectTrans.anchoredPosition = VectorPos4
		self.m_msgRectTrans.anchoredPosition = VectorPos5
	end

	self:SetMsgText()
end

function ActorBubbleItem:Update()
	self:UpdateMsgText()
	self:UpdateMsgPosition()
end

function ActorBubbleItem:UpdateMsgPosition()
	local actor = ActorManagerInst:GetActor(self.m_actorID)
    if not actor then
       return 
    end

    local bloodBar = actor:GetBloodBarTransform()
        
	local ok, outV2 = GameUtility.TransformWorld2RectPos(self.m_mainCam, UIManagerInst.UICamera, bloodBar, self.m_parent, 0)
	GameUtility.SetLocalPosition(self.transform, outV2.x, outV2.y, 0)
end

function ActorBubbleItem:UpdateMsgText()
	self.m_time = self.m_time + Time.deltaTime
	if self.m_time > MSG_CHANGE_INTERVAL then
		self.m_time = 0
		self.m_messageIndex = self.m_messageIndex + 1
		self:SetMsgText()
	end
end

function ActorBubbleItem:SetMsgText()
	if self.m_messageIndex > #self.m_messageList then
		self.m_isOver = true
		return
	end
	self.m_msgText.text = PlotLanguage.GetString("GuideLanguage", self.m_messageList[self.m_messageIndex])
	-- 69是text顶部到bg顶部偏移， 14是text底部到bg底部的偏移
	local bgHeight = 14 + 69 + self.m_msgText.preferredHeight
	if bgHeight < 139 then
		bgHeight = 139
	end
	self.transform.sizeDelta = Vector2.New(525, bgHeight)
end

function ActorBubbleItem:IsOver()
	return self.m_isOver
end

return ActorBubbleItem