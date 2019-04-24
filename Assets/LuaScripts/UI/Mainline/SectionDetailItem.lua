local Language = Language
local CommonDefine = CommonDefine
local UIUtil = UIUtil
local SplitString = CUtil.SplitString
local string_format = string.format
local ConfigUtil = ConfigUtil

local RotateStart = Quaternion.Euler(0, 0, -8)
local RotateEnd = Vector3.New(0, 0, 8)

local SectionDetailItem = BaseClass("SectionDetailItem", UIBaseItem)
local base = UIBaseItem

function SectionDetailItem:OnCreate()
    self.m_sectionID = nil
    self.m_indexStrList = SplitString(Language.GetString(2600), ',')

    self.m_passImageGO, self.m_clickBtn, self.m_lockRootGO, self.m_unlockRootGO, self.m_starTrans = UIUtil.GetChildTransforms(self.transform, {
        "unlockRoot/passImage",
        "unlockRoot/clickBtn",
        "lockRoot",
        "unlockRoot",
        "unlockRoot/star",
    })

    self.m_indexText, self.m_nameText, self.m_starCountText, self.m_boxCountText, self.m_unlockDesText, 
    self.m_unlockLevelText = UIUtil.GetChildTexts(self.transform, {
        "indexText",
        "unlockRoot/nameText",
        "unlockRoot/star/starCountText",
        "unlockRoot/boxCountText",
        "lockRoot/unlockDesText",
        "lockRoot/unlockLevelText",
    })

    self.m_boxImage = UIUtil.AddComponent(UIImage, self, "unlockRoot/boxImage", AtlasConfig.DynamicLoad)
    self.m_unlockDesText.text = Language.GetString(2606)
    self.m_passImageGO = self.m_passImageGO.gameObject
    self.m_unlockRootGO = self.m_unlockRootGO.gameObject
    self.m_lockRootGO = self.m_lockRootGO.gameObject

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_clickBtn.gameObject, onClick)
end

function SectionDetailItem:SetData(sectionID, sectionType)
    self.m_sectionID = sectionID

    local sectionCfg = ConfigUtil.GetCopySectionCfgByID(sectionID)
    if not sectionCfg then
        return
    end

    local mainlineMgr = Player:GetInstance():GetMainlineMgr()
    local sectionIndexStr = self.m_indexStrList[sectionCfg.section_index]
    self.m_indexText.text = string_format(Language.GetString(2602), sectionIndexStr)

    if Player:GetInstance():GetUserMgr():GetUserData().level >= sectionCfg.level then
        self.m_unlockRootGO:SetActive(true)
        self.m_lockRootGO:SetActive(false)
        self.m_nameText.text = sectionCfg.section_name
        self.m_passImageGO:SetActive(mainlineMgr:IsSectionClear(sectionID, sectionType))

        local boxCfgID = mainlineMgr:GetBoxIndexbySectionId(sectionID, 3, sectionType)
        local boxCfg = ConfigUtil.GetSectionBoxAwardCfgByID(boxCfgID)
        if boxCfg then
            local boxData = mainlineMgr:GetSectionBoxData(sectionID, sectionType)
            self.m_boxCountText.text = string_format(Language.GetString(2607), boxData and boxData.enableBoxCount or 0, 3)
            self.m_starCountText.text = string_format(Language.GetString(2607), boxData and boxData.curstars or 0, boxCfg.require_star)
            local isAllOpen = true
            local canGetBox = false
            if boxData then
                for _, state in ipairs(boxData.boxStateList) do
                    if state ~= 2 then
                        isAllOpen = false
                    end
                    if state == 1 then
                        canGetBox = true
                    end
                end
            else
                isAllOpen = false
            end
            self.m_boxImage:SetAtlasSprite(isAllOpen and "zhuxian17.png" or "zhuxian18.png")
            if canGetBox then
                UIUtil.KillTween(self.m_tweenner)
                local targetTrans = self.m_boxImage.transform
                local lastTweener = self.m_tweenner
                local sequence = UIUtil.TweenRotateToShake(targetTrans, lastTweener, RotateStart, RotateEnd)
                self.m_tweenner = sequence
            else
                UIUtil.KillTween(self.m_tweenner)
            end
        end
    else
        self.m_unlockRootGO:SetActive(false)
        self.m_lockRootGO:SetActive(true)
        self.m_unlockLevelText.text = string_format(Language.GetString(2605), sectionCfg.level)
    end

    self:FixStarPosition()
end

function SectionDetailItem:OnClick(go, x, y)
    UIManagerInst:Broadcast(UIMessageNames.MN_MAINLINE_CLICK_SECTION_ITEM,  self.m_sectionID)
end

function SectionDetailItem:OnDestroy()
    UIUtil.KillTween(self.m_tweenner)
    UIUtil.RemoveClickEvent(self.m_clickBtn.gameObject)
    base.OnDestroy(self)
end

function SectionDetailItem:FixStarPosition()
    self.m_starTrans.localPosition = Vector3.New(-(48 + self.m_starCountText.preferredWidth) / 2, -16, 0)
end

return SectionDetailItem