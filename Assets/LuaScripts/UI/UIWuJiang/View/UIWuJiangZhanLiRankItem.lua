local UIUtil = UIUtil

local UIWuJiangZhanLiRankItem = BaseClass("UIWuJiangZhanLiRankItem", UIBaseItem)
local base = UIBaseItem

local bgPath = "bg"
local rankIconPath = "rankIcon"
local rankLabelPath = "rankLabel"
local playerIconPath = "iconBg/Icon"
local playerLevePath = "iconBg/level"
local playerNamePath = "name"
local palyerZhanLiPath = "zhanlinumber"

function UIWuJiangZhanLiRankItem:__delete()
    self.m_go = false
    self.m_transform = false
    self.m_resPath = false
    self.m_rank = 0
    self.m_zhanli = 0
    self.m_playerIconSpt = false
    self.m_itemBgIconSpt = false
    self.m_itemRankIconSpt = false
    self.m_rankLabelTr =false
    self.m_rankIconTr = false
end

function UIWuJiangZhanLiRankItem:OnCreate()
    base.OnCreate(self)

    self.m_go = false
    self.m_resPath = false
    self.m_rank = 0
    self.m_zhanli = 0

    self.m_playerLevelLabel, self.m_playerNameLabel, self.m_playerZhanLiLabel = UIUtil.GetChildTexts(self.transform, {
        playerLevePath,playerNamePath,palyerZhanLiPath,
    })

    self.m_playerIconSpt = UIUtil.AddComponent(UIImage, self, playerIconPath, AtlasConfig.RoleIcon)
    self.m_itemBgIconSpt = UIUtil.AddComponent(UIImage, self, bgPath, AtlasConfig.DynamicLoad)
    self.m_itemRankIconSpt = UIUtil.AddComponent(UIImage, self, rankIconPath, AtlasConfig.DynamicLoad)

    self.m_rankLabelTr, self.m_rankIconTr = UIUtil.GetChildTransforms(self.transform, {
        rankLabelPath, rankIconPath
    })
end

function UIWuJiangZhanLiRankItem:UpdateData(go, resPath, rank, playerIcon, playerLeve, playerName, playerZhanli)
    if not go or not resPath or not rank or not playerIcon or not playerLeve or not playerName or not playerZhanli then
        return
    end

    self.m_go = go
    self.m_resPath = resPath
    self.m_rank = rank or 0
    self.m_zhanli = playerZhanli or 0

    self.m_playerLevelLabel.text = playerLeve
    self.m_playerNameLabel.text = playerName
    self.m_playerZhanLiLabel.text = string.format("%d", playerZhanli)

    self.m_playerIconSpt:SetAtlasSprite(playerIcon .. ".png", false, AtlasConfig.RoleIcon)

    self:UpdateRank()
end

function UIWuJiangZhanLiRankItem:GetRank()
    return self.m_rank
end

function UIWuJiangZhanLiRankItem:SetSiblingIndex(index)
    self.transform:SetSiblingIndex(index)
end

function UIWuJiangZhanLiRankItem:UpdateRank()
    if self.m_rank == 1 then
        self.m_itemBgIconSpt:SetAtlasSprite("ph02.png", false, AtlasConfig.DynamicLoad)
    else
        self.m_itemBgIconSpt:SetAtlasSprite("ph01.png", false, AtlasConfig.DynamicLoad)
        if self.m_rank == 2 then
                self.m_itemRankIconSpt:SetAtlasSprite("ph04.png", true, AtlasConfig.DynamicLoad)
        elseif self.m_rank == 3 then
                self.m_itemRankIconSpt:SetAtlasSprite("ph05.png", true, AtlasConfig.DynamicLoad)
        else
            self.m_rankLabelTr.gameObject:SetActive(true)

            local rankLabel = UIUtil.GetChildTexts(self.transform, {
                rankLabelPath,
            })
            rankLabel.text = string.format("%d", self.m_rank),
    
            self.m_rankIconTr.gameObject:SetActive(false)
        end
    end
end

return UIWuJiangZhanLiRankItem