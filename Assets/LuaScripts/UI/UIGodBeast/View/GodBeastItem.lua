local string_format = string.format
local math_ceil = math.ceil
local string_split = CUtil.SplitString
local GodBeastMgr = Player:GetInstance():GetGodBeastMgr()
local GODBEAST_INDEX = {1, 3, 2, 4}
local GodBeastItem = BaseClass("GodBeasttem", UIBaseItem)
local base = UIBaseItem

function GodBeastItem:OnCreate()
    base.OnCreate(self)

    self.m_iconImage = UIUtil.AddComponent(UIImage, self, "", ImageConfig.GodBeast)

    self.m_lockedText = UIUtil.GetChildTexts(self.transform, {
        "locked/bg/lockedText"
    })

    self.m_locked = UIUtil.GetChildTransforms(self.transform, { "locked" })

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self:GetGameObject(), onClick)
end

function GodBeastItem:OnClick(go)
    if go == self:GetGameObject() then
        local godBeastData = {}
        if self.m_godBeastId then
            local godBeastData = GodBeastMgr:GetGodBeastByID(self.m_godBeastId)
            if godBeastData then
                UIManagerInst:OpenWindow(UIWindowNames.UIGodBeastMain, godBeastData)
            end
        end     
    end
end

function GodBeastItem:UpdateData(index, id)
    self.m_godBeastId = id
    local iconIndex = GODBEAST_INDEX[index]
    self.m_iconImage:SetAtlasSprite("godBeast"..iconIndex..".png", true)

    self.m_sysId = self:GetSysIdByGodBeastId(id)
    if self.m_sysId then
        self:SetLockStatus(UILogicUtil.IsSysOpen(self.m_sysId, false), self.m_sysId)
    end
end

function GodBeastItem:GetSysIdByGodBeastId(id)
    if id == 1003601 then
        return SysIDs.DRAGON_QINGLONG
    elseif id == 1003603 then
        return SysIDs.DRAGON_BAIHU
    elseif id == 1003602 then
        return SysIDs.DRAGON_ZHUQUE
    elseif id == 1003606 then
        return SysIDs.DRAGON_XUANWU
    end
end

function GodBeastItem:SetLockStatus(isOpen, sysID)
    self.m_locked.gameObject:SetActive(not isOpen)
    if not isOpen then
        local sysOpenCfg = ConfigUtil.GetSysopenCfgByID(sysID)
        if sysOpenCfg then
            self.m_lockedText.text = sysOpenCfg.sDesc
        end
    end
end

function GodBeastItem:OnDestroy()
    UIUtil.RemoveClickEvent(self:GetGameObject())
    if self.m_iconImage then
        self.m_iconImage:Delete()
        self.m_iconImage = nil
    end
    
    base.OnDestroy(self)
end

return GodBeastItem