local UIUtil = UIUtil
local UIImage = UIImage
local math_ceil = math.ceil
local ConfigUtil = ConfigUtil
local UILogicUtil = UILogicUtil
local AtlasConfig = AtlasConfig
local GameUtility = CS.GameUtility
local Type_Image = typeof(CS.UnityEngine.UI.Image)

local UserItem = BaseClass("UserItem", UIBaseItem)
local base = UIBaseItem


function UserItem:OnCreate()
    base.OnCreate(self)

    self:InitView()

    self:HandleClick()
end

function UserItem:InitView()
    self.m_usedSpt, self.m_userFrameTrans, self.m_levelTr = UIUtil.GetChildRectTrans(self.transform, {
        "usedSpt",
        "UserFrame",
        "Level"
    })

    self.m_levelText = UIUtil.GetChildTexts(self.transform, {
        "Level/LevelText"
    })

    self.m_userIcon = UIUtil.AddComponent(UIImage, self, "UserHeadIcon", AtlasConfig.DynamicLoad)
    self.m_userFrame = UIUtil.AddComponent(UIImage, self, "UserFrame", AtlasConfig.DynamicLoad)
    self.m_userFrameImage = self.m_userFrameTrans:GetComponent(Type_Image)
    self.m_levelGo = self.m_levelTr.gameObject

    self.m_selfOnClickCallback = nil
    self.m_headIconCfg = nil
    self.m_headIconBoxCfg = nil
    self.m_fatherItem = nil
    self.m_headIconId = 0

    self.m_isUsed = false
end

function UserItem:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    
    UIUtil.AddClickEvent(self.m_userFrame.gameObject, onClick)
end

function UserItem:OnClick(go, x, y)
    if not go then
        return
    end
    if go == self.m_userFrame.gameObject then
        if self.m_selfOnClickCallback then
            if self.m_fatherItem then
                self.m_selfOnClickCallback(self.m_fatherItem)
            else
                self.m_selfOnClickCallback(self)
            end
        end
    end
end

function UserItem:GetHeadIconId()
    return self.m_headIconId
end

function UserItem:GetIsUsed()
    return self.m_isUsed
end

function UserItem:SetUseHeadIcon(isUsed)
    self.m_isUsed = isUsed
    self.m_usedSpt.gameObject:SetActive(self.m_isUsed)
end

function UserItem:OnDestroy()
    UIUtil.RemoveClickEvent(self:GetGameObject())

    if self.m_userIcon then
        self.m_userIcon:Delete()
        self.m_userIcon = nil
    end
    if self.m_userFrame then
        self.m_userFrame:Delete()
        self.m_userFrame = nil
    end
    self.m_usedSpt = nil
    self.m_userFrameImage = nil

    self.m_headIconId = 0
    self.m_selfOnClickCallback = nil
    self.m_headIconCfg = nil
    self.m_headIconBoxCfg = nil
    self.m_fatherItem = nil

    base.OnDestroy(self)
end

--headIconId:服务器发的头像iconID
--headIconBoxId:服务器发的头像框的id
--selfOnClickCallback:点击自身的回调事件
--isUsed:是否使用中
--isLocked:是否解锁了该头像
function UserItem:UpdateData(headIconId, headIconBoxId, level, selfOnClickCallback, isUsed, fatherItem, isLocked)
    local headIconCfg = ConfigUtil.GetHeadIconCfgByID(headIconId)
    if headIconCfg then
        self.m_headIconId = headIconId
        self.m_headIconCfg = headIconCfg
        local wujiangCfg = ConfigUtil.GetWujiangCfgByID(headIconCfg.icon)
        if wujiangCfg then
            self.m_userIcon:SetAtlasSprite(wujiangCfg.sIcon, false, AtlasConfig.RoleIcon)
        end 
    end

    -- local headIconBoxCfg = ConfigUtil.GetHeadIconBoxCfgByID(headIconBoxId)
    -- if headIconBoxCfg then
    --     self.m_headIconBoxCfg = headIconBoxCfg
    --     self.m_userFrame:SetAtlasSprite(headIconBoxCfg.sIcon, false, AtlasConfig[headIconBoxCfg.sAtlas])
    -- end

    self.m_selfOnClickCallback = selfOnClickCallback
    local canClick = selfOnClickCallback ~= nil
    GameUtility.SetRaycastTarget(self.m_userFrameImage, canClick)

    self.m_isUsed = isUsed or false
    self.m_usedSpt.gameObject:SetActive(self.m_isUsed)
    self.m_fatherItem = fatherItem
    local isLock = isLocked or false
    GameUtility.SetUIGray(self.m_userIcon.gameObject, isLock)
    GameUtility.SetUIGray(self.m_userFrame.gameObject, isLock)

    if level then
        self.m_levelText.text = math_ceil(level)
    end
    self.m_levelGo:SetActive(level ~= nil)
end


return UserItem