--[[
-- added by wsh @ 2017-12-03
-- UI工具类
--]]
--local UIEventListener = CS.UIEventListener
local UIDragListener = CS.UIDragListener
local UIClickListener = CS.UIClickListener
local UIEventListener = CS.UIEventListener
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTween = CS.DOTween.DOTween
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTweenExtensions = CS.DOTween.DOTweenExtensions
local Type_Button = typeof(CS.UnityEngine.UI.Button)
local string_format = string.format
local Type_Image = typeof(typeof(CS.UnityEngine.UI.Image))
local Type_RectTransform = typeof(CS.UnityEngine.RectTransform)
local CalculateRelativeRectTransformBounds = CS.UnityEngine.RectTransformUtility.CalculateRelativeRectTransformBounds
local TweenAlpha = CS.TweenAlpha
local Type_Renderer = typeof(CS.UnityEngine.Renderer)

local GameUtility = CS.GameUtility
local GameObject = CS.UnityEngine.GameObject

local Mathf_Round = Mathf.Round
local Mathf_Log= Mathf.Log

local unpack = unpack or table.unpack
local table_insert = table.insert
local table_remove = table.remove

local UIUtil = {tryClickList = {}}

local function Clear()
	if #UIUtil.tryClickList == 0 then
		return
	end

	for i = #UIUtil.tryClickList, 1, -1 do
		local imaData = UIUtil.tryClickList[i]
		if not IsNull(imaData.img) then
			GameUtility.SetRaycastTarget(imaData.img, true)
		end
	end
	UIUtil.tryClickList = {}
end

local function GetChild(trans, index)
	return trans:GetChild(index)
end

-- 注意：根节点不能是隐藏状态，否则路径将找不到
local function FindComponent(trans, ctype, path)
	assert(trans ~= nil)
	assert(ctype ~= nil)
	
	local targetTrans = trans
	if path ~= nil and type(path) == "string" and #path > 0 then
		targetTrans = trans:Find(path)
	end
	if targetTrans == nil then
		return nil
	end
	local cmp = targetTrans:GetComponent(ctype)
	if cmp ~= nil then
		return cmp
	end
	return targetTrans:GetComponentInChildren(ctype)
end

local function FindTrans(trans, path)
	return trans:Find(path)
end

local function FindText(trans, path)
	return FindComponent(trans, typeof(CS.UnityEngine.UI.Text), path)
end

--[[ local function FindTextMeshProUGUI(trans, path)
	return FindComponent(trans, typeof(CS.TMPro.TextMeshProUGUI), path)
end ]]

local function FindImage(trans, path)
	return FindComponent(trans, typeof(CS.UnityEngine.UI.Image), path)
end

local function FindButton(trans, path)
	return FindComponent(trans, typeof(CS.UnityEngine.UI.Button), path)
end

local function FindInput(trans, path)
	return FindComponent(trans, typeof(CS.UnityEngine.UI.InputField), path)
end

local function FindSlider(trans, path)
	return FindComponent(trans, typeof(CS.UnityEngine.UI.Slider), path)
end

local function FindScrollRect(trans, path)
	return FindComponent(trans, typeof(CS.UnityEngine.UI.ScrollRect), path)
end

-- 获取直属画布
-- 暂时不用 注释
--[[ local function GetCanvas(ui_component)
	-- 初始化直属画布
	
	local canvas = nil
	if ui_component._class_type == UILayer then
		canvas = ui_component
	else
		local now_holder = ui_component.holder
		while now_holder ~= nil do	
			local var = ui_component:GetComponents(UICanvas)
			local k, v = next(var)
			if k then
				canvas = v
				break
			end
			now_holder = now_holder.holder
		end
	end
	assert(canvas ~= nil)
	return canvas
end ]]

function AddDragEvent(target, call_back)
	if target then
		UIDragListener.Get(target).onDrag = call_back
	end
end

function AddDragBeginEvent(target, call_back)
	if target then
		UIDragListener.Get(target).onDragBegin = call_back
	end
end

function AddDragEndEvent(target, call_back)
	if target then
		UIDragListener.Get(target).onDragEnd = call_back
	end
end

function AddClickEvent(target, call_back)
	if target then
		UIClickListener.Get(target).onClick = call_back
	end
end

function RemoveClickEvent(target)
	if not IsNull(target) then
		UIClickListener.Remove(target)
	end
end

function SetUIClickable(value)
	UIClickListener.canClick = value
end

function RemoveEvent(target)
	if not IsNull(target) then
		UIEventListener.Remove(target)
	end
end

function RemoveDragEvent(target)
	if not IsNull(target) then
		UIDragListener.Remove(target)
	end
end

--添加按下事件
function AddDownEvent(target, call_back)
	if target then
		UIEventListener.Get(target).onDown = call_back
	end
end

--添加松开事件
function AddUpEvent(target, call_back)
	if target then
		UIEventListener.Get(target).onUp = call_back
	end
end

function LoopMoveLocalX(rectTrans, originalPosX, targetPosX, duration, isLoop)
	if not rectTrans then
		return
	end

	if isLoop == nil then
		isLoop = true
	end
	--DOTweenShortcut.DOKill(rectTrans, true)
	local posX = originalPosX

    local function getterFunc()
        return posX
    end

    local function setterFunc(x)
        posX = x
    end

    local function tweenUpdate()
		rectTrans.anchoredPosition = Vector2.New(posX, rectTrans.anchoredPosition.y)
	end
	
	local tweener = DOTween.ToFloatValue(getterFunc, setterFunc, targetPosX, duration)
	if isLoop then
		DOTweenSettings.SetLoops(tweener, -1, 1)
	end
    DOTweenSettings.SetEase(tweener, DoTweenEaseType.InBack)
    DOTweenSettings.OnUpdate(tweener, tweenUpdate)
	
	return tweener
end

function LoopMoveLocalY(rectTrans, originalPosY, targetPosY, duration, isLoop)
	if not rectTrans then
		return
	end

	--DOTweenShortcut.DOKill(rectTrans, true)

	
	local posY = originalPosY

    local function getterFunc()
        return posY
    end

    local function setterFunc(y)
        posY = y
    end

    local function tweenUpdate()
		rectTrans.anchoredPosition = Vector2.New(rectTrans.anchoredPosition.x, posY)
	end
	
	local tweener = DOTween.ToFloatValue(getterFunc, setterFunc, targetPosY, duration)
	if isLoop then
		DOTweenSettings.SetLoops(tweener, -1, 1)
	end
    DOTweenSettings.SetEase(tweener, DoTweenEaseType.InBack)
    DOTweenSettings.OnUpdate(tweener, tweenUpdate)

	
	return tweener
end

function LoopTweenLocalScale(trans, originalScale, targetScale, duration)
	duration = duration or 0.5

	trans.localScale = originalScale
	local tweener = DOTweenShortcut.DOScale(trans, targetScale, duration)
	DOTweenSettings.SetLoops(tweener, -1, 1)

	return tweener
end

function OnceTweenScale(trans, initScale, targetScale, duration)
	duration = duration or 0.2
    if trans then
        trans.localScale = initScale
        DOTweenShortcut.DOKill(trans, true)
        local tweener = DOTweenShortcut.DOScale(trans, targetScale, duration)
        DOTweenSettings.SetLoops(tweener, 2, 1)
    end
end

function KillTween(tweener, complete)
	if complete == nil then
		complete = false
	end
	if tweener then
		DOTweenExtensions.Kill(tweener, complete)
	end
end

function GetChildTransforms(trans, names)
	if trans then
		local childs = {}
		local objs = GameUtility.GetChildTransforms(trans, names)
		for i = 0, objs.Length - 1 do
			table_insert(childs, objs[i])
		end
		
		return unpack(childs)
	end
end

function GetChildRectTrans(trans, names)
	if trans then
		local childs = {}
		local objs = GameUtility.GetChildRectTrans(trans, names)
		for i = 0, objs.Length - 1 do
			table_insert(childs, objs[i])
		end
		
		return unpack(childs)
	end
end

function GetChildTexts(trans, names)
	if trans then
		local childs = {}
		local objs = GameUtility.GetChildTexts(trans, names)
		for i = 0, objs.Length - 1 do
			table_insert(childs, objs[i])
		end
		
		return unpack(childs)
	end
end

--[[ function GetChildImages(trans, names)
	if trans then
		local childs = {}
		local objs = GameUtility.GetChildImages(trans, names)
		for i = 0, objs.Length - 1 do
			table_insert(childs, objs[i])
		end
		
		return unpack(childs)
	end
end ]]

--新增lua侧脚本
function AddComponent(component_target, holder, var_arg, ...)
	assert(component_target.__ctype == ClassType.class)

	local component = component_target.New(holder, var_arg)
	component:OnCreate(...)
	return component
end

--新增Unity脚本
function AddCSComponent(gameObject, csType)
	assert(gameObject ~= nil)
	assert(csType ~= nil)

	local cmp = gameObject:GetComponent(csType)
	if cmp ~= nil then
		return cmp
	end

	return gameObject:AddComponent(csType)
end

function DisableSpringContent(springContent)
	if springContent then
		springContent.enabled = false
	end
end

--旋转形成抖动的效果
function TweenRotateToShake(targetTrans, lastTweener, rotateStart, rotateEnd)
	UIUtil.KillTween(lastTweener)
	if not targetTrans then
		return
	end
	
	targetTrans.localRotation = rotateStart
    local sequence = DOTween.NewSequence()
    local tweenner = DOTweenShortcut.DOLocalRotate(targetTrans, rotateEnd, 0.1)
    DOTweenSettings.SetRelative(tweenner)
    DOTweenSettings.SetLoops(tweenner, 5, 1)
    DOTweenSettings.Append(sequence, tweenner)
    DOTweenSettings.SetLoops(sequence, -1, 1)
    DOTweenSettings.AppendInterval(sequence, 0.5)
	return sequence
end

function TryClick(trans, diableClickTime)
	if not Player:GetInstance():IsGameInit() then -- 游戏没有初始化，获取不到GetServerTime， 会导致按钮再也不能被点击
		return
	end
	local image = UIUtil.FindImage(trans)
	if image and GameUtility.IsRaycastTargetEnabled(image) then
		local isFind = false
		for _, data in ipairs(UIUtil.tryClickList) do
			if data.img == image then
				isFind = true
				break
			end
		end
		if not isFind then
			GameUtility.SetRaycastTarget(image, false)
			
			local imaData = {
				time = Player:GetInstance():GetServerTime() + (diableClickTime or 1),
				img = image
			}
			table_insert(UIUtil.tryClickList, imaData)
		end
	end
end

function CheckTryClickTime()
	if #UIUtil.tryClickList == 0 then
		return
	end

	local curTime = Player:GetInstance():GetServerTime()
	for i = #UIUtil.tryClickList, 1, -1 do
		local imaData = UIUtil.tryClickList[i]
		if curTime > imaData.time then
			table_remove(UIUtil.tryClickList, i)
			if not IsNull(imaData.img) then
				GameUtility.SetRaycastTarget(imaData.img, true)
			end
		end
	end
end

function TryBtnEnable(gameObject, isEnable)
	if not IsNull(gameObject) then
		local button = gameObject:GetComponent(Type_Button)
		if button then
			button.interactable = isEnable
		end

		local image = gameObject:GetComponent(Type_Image)
		if image then
			GameUtility.SetRaycastTarget(image, isEnable)
		end

		GameUtility.SetUIGray(gameObject, not isEnable)   
	end
end

function KeepCenterAlign(trans, centerTrans)
	GameUtility.KeepCenterAlign(trans, centerTrans)
end


function DoGraphicTweenAlpha(graphic, duration, startAlpha, endAlpha, loops, loopType, call_back)
  	return TweenAlpha.Begin(graphic, call_back, duration, startAlpha, endAlpha, loops, loopType)
end

function SpringDampen(velocity, strength, deltaTime)
	if deltaTime > 1 then 
		deltaTime = 1
	end

	local dampeningFactor = 1 - strength * 0.001
	local ms = Mathf_Round(deltaTime * 1000)
	local totalDampening = dampeningFactor ^ ms
	local vTotal = velocity * ((totalDampening - 1) / Mathf_Log(dampeningFactor))
	local tmp = velocity * totalDampening
	velocity:Set(tmp.x, tmp.y)
	return vTotal * 0.06
end

function CreateScrollViewItemList(itemList, createCount, prefab, parent, itemClass)
	assert(prefab ~= nil)
	assert(itemList ~= nil)
	
	if #itemList == 0 then
		for i = 1, createCount do
			local go = GameObject.Instantiate(prefab)
			local createItem = itemClass.New(go, parent)
			table_insert(itemList, createItem)
		end
	end
end

function ClipGameObjectWithBounds(trans, clipRegion)
	--[[ if trans then
		local renderList = trans:GetComponentsInChildren(Type_Renderer)
		if renderList then
			for i = 0, renderList.Length - 1 do
				local matList = renderList[i].materials
				if matList then
					for i = 0, matList.Length - 1 do
						local mat = matList[i]
						if mat and mat:HasProperty("_ClipRegions") then
							mat:SetVector("_ClipRegions", clipRegion)
						end
					end
				end
			end
		end
	end ]]

	GameUtility.ClipGameObjectWithBounds(trans, clipRegion)
end

function OnceTweenTextScale(text, initScale, targetScale, duration)
	if text then
		duration = duration or 0.2
		local alignment = text.alignment
		local trans = text.transform
		--local pos = trans.localPosition
		text.alignment = CommonDefine.MiddleCenter
		--trans.localPosition = pos
		trans.localScale = initScale
        DOTweenShortcut.DOKill(trans, true)
        local tweener = DOTweenShortcut.DOScale(trans, targetScale, duration)
		DOTweenSettings.SetLoops(tweener, 2, 1)
		DOTweenSettings.OnComplete(tweener, function()
			text.alignment = alignment
		end)
    end
end

function KBSizeToString(kbSize)
    local sizeStr = nil
    if kbSize >= 1024 then
        sizeStr = string_format("%.2f", kbSize / 1024) .. "M"
    else
        sizeStr = kbSize .. "K"
    end

    return sizeStr
end

UIUtil.Clear = Clear
UIUtil.GetChild = GetChild
UIUtil.FindComponent = FindComponent
UIUtil.FindTrans = FindTrans
UIUtil.FindText = FindText
--UIUtil.FindTextMeshProUGUI = FindTextMeshProUGUI
UIUtil.FindImage = FindImage
UIUtil.FindButton = FindButton
UIUtil.FindInput = FindInput
UIUtil.FindSlider = FindSlider
UIUtil.FindScrollRect = FindScrollRect
UIUtil.AddDragEvent = AddDragEvent
UIUtil.AddDragBeginEvent = AddDragBeginEvent
UIUtil.AddDragEndEvent = AddDragEndEvent
UIUtil.AddClickEvent = AddClickEvent
UIUtil.RemoveClickEvent = RemoveClickEvent
UIUtil.RemoveEvent = RemoveEvent
UIUtil.RemoveDragEvent = RemoveDragEvent
UIUtil.AddDownEvent =  AddDownEvent
UIUtil.AddUpEvent = AddUpEvent
UIUtil.LoopMoveLocalX = LoopMoveLocalX
UIUtil.LoopMoveLocalY = LoopMoveLocalY
UIUtil.LoopTweenLocalScale = LoopTweenLocalScale
UIUtil.KillTween = KillTween
UIUtil.GetChildTransforms = GetChildTransforms
UIUtil.GetChildRectTrans = GetChildRectTrans
UIUtil.GetChildTexts = GetChildTexts
--UIUtil.GetChildImages = GetChildImages
UIUtil.AddComponent = AddComponent
UIUtil.AddCSComponent = AddCSComponent
UIUtil.DisableSpringContent = DisableSpringContent
UIUtil.TweenRotateToShake = TweenRotateToShake
UIUtil.TryClick = TryClick
UIUtil.CheckTryClickTime = CheckTryClickTime
UIUtil.TryBtnEnable = TryBtnEnable
UIUtil.KeepCenterAlign = KeepCenterAlign
UIUtil.DoGraphicTweenAlpha = DoGraphicTweenAlpha
UIUtil.SpringDampen = SpringDampen
UIUtil.CreateScrollViewItemList = CreateScrollViewItemList
UIUtil.OnceTweenScale = OnceTweenScale
UIUtil.ClipGameObjectWithBounds = ClipGameObjectWithBounds
UIUtil.OnceTweenTextScale = OnceTweenTextScale
UIUtil.KBSizeToString = KBSizeToString
UIUtil.SetUIClickable = SetUIClickable

return UIUtil