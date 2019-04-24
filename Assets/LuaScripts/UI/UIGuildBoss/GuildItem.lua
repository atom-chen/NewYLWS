local UIUtil = UIUtil
local UIImage = UIImage
local math_ceil = math.ceil
local ConfigUtil = ConfigUtil
local UILogicUtil = UILogicUtil
local AtlasConfig = AtlasConfig
local GameUtility = CS.GameUtility
local Type_Image = typeof(CS.UnityEngine.UI.Image)

local GuildItem = BaseClass("GuildItem", UIBaseItem)
local base = UIBaseItem


function GuildItem:OnCreate()
    base.OnCreate(self)

    self:InitView()

    -- self:HandleClick() -- 点击，暂不需要
end

function GuildItem:InitView()
    -- self.m_bgIcon = UIUtil.AddComponent(UIImage, self, "Icon", AtlasConfig.DynamicLoad) -- 背景
    self.m_guildFlagIcon = UIUtil.AddComponent(UIImage, self, "Icon/GuildIconImage", AtlasConfig.DynamicLoad)

    self.m_selfOnClickCallback = nil
    self.m_headIconCfg = nil
    self.m_fatherItem = nil
    self.m_headIconId = 0
end

function GuildItem:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    
    UIUtil.AddClickEvent(self.m_guildFlagIcon.gameObject, onClick)
end

function GuildItem:OnClick(go, x, y)
    if not go then
        return
    end
    if go == self.m_guildFlagIcon.gameObject then
        if self.m_selfOnClickCallback then
            if self.m_fatherItem then
                self.m_selfOnClickCallback(self.m_fatherItem)
            else
                self.m_selfOnClickCallback(self)
            end
        end
    end
end

function GuildItem:GetHeadIconId()
    return self.m_headIconId
end


function GuildItem:OnDestroy()
    UIUtil.RemoveClickEvent(self:GetGameObject())

    if self.m_guildFlagIcon then
        self.m_guildFlagIcon:Delete()
        self.m_guildFlagIcon = nil
    end

    self.m_headIconId = 0
    self.m_selfOnClickCallback = nil
    -- self.m_headIconCfg = nil
    self.m_fatherItem = nil

    base.OnDestroy(self)
end

--headIconId:服务器发的头像iconID
--headIconBoxId:服务器发的头像框的id
--selfOnClickCallback:点击自身的回调事件
--isUsed:是否使用中
function GuildItem:UpdateData(iconId, selfOnClickCallback, fatherItem)
    self.m_headIconId = iconId
    local guildCfg = ConfigUtil.GetGuildIconCfgByID(iconId)
    if guildCfg then
        local guildImage = guildCfg.icon .. '.png'
        self.m_guildFlagIcon:SetAtlasSprite(guildImage, false,  AtlasConfig.DynamicLoad2)
    end
    GameUtility.SetRaycastTarget(self.m_guildFlagIcon, canClick)

    self.m_selfOnClickCallback = selfOnClickCallback
    local canClick = selfOnClickCallback ~= nil
    self.m_fatherItem = fatherItem
end


return GuildItem