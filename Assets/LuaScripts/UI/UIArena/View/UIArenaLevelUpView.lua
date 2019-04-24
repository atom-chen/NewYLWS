local UIUtil = UIUtil
local UIImage = UIImage
local UIEffect = UIEffect
local TheGameIds = TheGameIds
local AtlasConfig = AtlasConfig
local GameUtility = CS.GameUtility
local Vector3 = Vector3
local ArenaLevelUpEffect1 = TheGameIds.ArenaLevelUpEffect1
local ArenaLevelUpEffect2 = TheGameIds.ArenaLevelUpEffect2
local ArenaLevelUpEffect3 = TheGameIds.ArenaLevelUpEffect3
local ArenaLevelUpEffect4 = TheGameIds.ArenaLevelUpEffect4

local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTween = CS.DOTween.DOTween

local UIArenaLevelUpView = BaseClass("UIArenaLevelUpView", UIBaseView)
local base = UIBaseView
local MOVE_TARGET = Vector3.New(-564,201.6,0)

function UIArenaLevelUpView:OnCreate()
    base.OnCreate(self)

    self:InitView()

    self:HandleClick()
end

function UIArenaLevelUpView:InitView()
    self.m_blackBgTrans, self.m_rankRoot = UIUtil.GetChildRectTrans(self.transform, {"blackBg", "rankRoot"})

    self.m_blackBgImg = self:AddComponent(UIImage, "blackBg")

    self.m_rankNameText = UIUtil.GetChildTexts(self.transform, {"rankRoot/rankNameBg/rankNameText"})

    self.m_rankIcon = UIUtil.AddComponent(UIImage, self, "rankRoot/rankIcon", AtlasConfig.DynamicLoad2)

    self.m_effectItem = nil
    self.m_isShowEndTween = false
end

function UIArenaLevelUpView:HandleClick()
    UIUtil.AddClickEvent(self.m_blackBgTrans.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
end

function UIArenaLevelUpView:OnClick(go, x, y)
    if not go then
        return
    end
    local goName = go.name
    if goName == "blackBg" then
        if not self.m_isShowEndTween then
            self:TweenEnd()
        end
    end
end

function UIArenaLevelUpView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_blackBgTrans.gameObject)

    self.m_isShowEndTween = false
    self.m_blackBgTrans = nil

    self.m_rankNameText = nil

    if self.m_rankIcon then
        self.m_rankIcon:Delete()
        self.m_rankIcon = nil
    end
    if self.m_effectItem then
        self.m_effectItem:Delete()
        self.m_effectItem = nil
    end

    base.OnDestroy(self)
end

function UIArenaLevelUpView:OnEnable(initOrder, currRankDan)
    base.OnEnable(self)

    UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_TOP_STATE, false)

    self.m_isShowEndTween = false

    local rankDanCfg = ConfigUtil.GetArenaDanAwardCfgByID(currRankDan)
    if rankDanCfg then
        self.m_rankIcon:SetAtlasSprite(rankDanCfg.sIcon, true, AtlasConfig[rankDanCfg.sAtlas])
        self.m_rankNameText.text = rankDanCfg.dan_name
    end

    --创建特效
    local effectPath = nil
    if currRankDan == 1 then
        effectPath = ArenaLevelUpEffect1
    elseif currRankDan == 2 then
        effectPath = ArenaLevelUpEffect2
    elseif currRankDan == 3 then
        effectPath = ArenaLevelUpEffect3
    elseif currRankDan == 4 then
        effectPath = ArenaLevelUpEffect4
    end
    if effectPath then
        local sortOrder = self:PopSortingOrder()
        UIUtil.AddComponent(UIEffect, self, "", sortOrder, effectPath, function(effect)
            self.m_effectItem = effect
            self.m_effectItem.m_effect.transform.localScale = Vector3.New(10, 10, 10)
            GameUtility.SetLayer(self.m_effectItem:GetGameObject(), Layers.UI)
        end)
    end


end

function UIArenaLevelUpView:TweenEnd()
    self.m_isShowEndTween = true

    DOTween.ToFloatValue(function()
        return 0
    end, 
    function(value)
        self.m_blackBgImg:SetColor(Color.New(1, 1, 1, 1 - value))
    end, 1, 1)

    if self.m_effectItem then
        local tweener = DOTweenShortcut.DOScale(self.m_effectItem.m_effect.transform, 8, 1)
        DOTweenSettings.OnComplete(tweener, function()
            self.m_effectItem:GetGameObject():SetActive(false)
            self.m_rankRoot.gameObject:SetActive(true)
            local sequence = DOTween.NewSequence()

            local tweener1 = DOTweenShortcut.DOLocalMove(self.m_rankRoot, MOVE_TARGET, 0.4)
            DOTweenSettings.SetEase(tweener1, DoTweenEaseType.OutCirc)
    
            local tweener2 = DOTweenShortcut.DOScale(self.m_rankRoot, 1.1, 0.2)
            DOTweenSettings.SetEase(tweener2, DoTweenEaseType.OutCirc)
    
            local tweener3 = DOTweenShortcut.DOScale(self.m_rankRoot, 1, 0.1)
            DOTweenSettings.SetEase(tweener3, DoTweenEaseType.InCirc)
    
            local tweener4 = DOTweenShortcut.DOScale(self.m_rankRoot, 1, 0.3)
            DOTweenSettings.OnComplete(tweener4, function()
                self:Reset()
                UIManagerInst:Broadcast(UIMessageNames.MN_ARENA_UPDATE_CURRENT_RANKDAN)                
                self:CloseSelf()
            end)

            DOTweenSettings.Append(sequence, tweener1)
            DOTweenSettings.Append(sequence, tweener2)
            DOTweenSettings.Append(sequence, tweener3)
            DOTweenSettings.Append(sequence, tweener4)
        end)
    end
end

function UIArenaLevelUpView:Reset()
    UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_TOP_STATE, true)
    self.m_rankRoot.gameObject:SetActive(false)
    self.m_rankRoot.transform.localPosition = Vector3.zero
    self.m_blackBgImg:SetColor(Color.New(1, 1, 1, 1))
end

return UIArenaLevelUpView