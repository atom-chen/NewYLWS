local UIUtil = UIUtil
local UIGuildBossRankItem = BaseClass("UIGuildBossRankItem", UIBaseItem)
local base = UIBaseItem
local UILogicUtil = UILogicUtil
local ConfigUtil = ConfigUtil
local string_format = string.format
local UserItemClass = require("UI.UIUser.UserItem")
local GuildItemClass = require("UI.UIGuildBoss.GuildItem")
local UserItemPrefab = TheGameIds.UserItemPrefab
local GuildItemPrefab = TheGameIds.GuildItemPrefab
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()

local UISliderHelper = typeof(CS.UISliderHelper)
local Type_RectTransform = typeof(CS.UnityEngine.RectTransform)

function UIGuildBossRankItem:Delete()
    self.m_go = false
    self.m_transform = false
    self.m_nameText = nil
    self.m_hurtText = nil
    self.m_noRankText = nil
    self.rankLabelText = nil
    self.m_rankIconTr = nil
    self.m_rankImage = nil

    if self.m_itemPrefab then
        self.m_itemPrefab:Delete()
    end
    self.m_itemPrefab = nil

end

function UIGuildBossRankItem:OnCreate()
	base.OnCreate(self)

    self:InitView()
end

function UIGuildBossRankItem:InitView()
    self.m_nameText, self.m_hurtText, self.m_noRankText, self.rankLabelText = UIUtil.GetChildTexts(self.transform, {
        "name", "hurt", "noRankText", "rankLabel"
    })

    self.m_rankIconTr, self.m_itemCreatePos = UIUtil.GetChildTransforms(self.transform, {
       'rankIcon', 'ItemCreatePos'
    })

    self.m_rankImage = UIUtil.AddComponent(UIImage, self, "rankIcon", AtlasConfig.DynamicLoad)
end


function UIGuildBossRankItem:UpdateData(hurt, level, name, rank, icon, box, isGuildRank, isSelf)
    if self.m_itemPrefab then
        self.m_itemPrefab:Delete()
        self.m_itemPrefab = nil
    end

    if not isGuildRank then
        local seq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObject(seq, UserItemPrefab, function(obj)
            seq = 0
            if IsNull(obj) then
                return
            end
            local userItem = UserItemClass.New(obj, self.m_itemCreatePos, UserItemPrefab)
            self.m_itemPrefab = userItem
            userItem:SetLocalScale(Vector3.New(0.65, 0.65, 0.65))
            userItem:UpdateData(icon, box, level)
        end)
    else
        local seq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObject(seq, GuildItemPrefab, function(obj)
            seq = 0
            if IsNull(obj) then
                return
            end
            local userItem = GuildItemClass.New(obj, self.m_itemCreatePos, GuildItemPrefab)
            self.m_itemPrefab = userItem
            userItem:SetLocalScale(Vector3.New(0.7, 0.7, 0.7))
            userItem:UpdateData(icon)
        end)
    end

    -- 伤害数值为6位数或以上时要按xxxx万的方式显示，超过10亿时按照xxxx亿的方式显示
    if hurt ~= 0 then
        if hurt < 100000 then
            self.m_hurtText.text = string_format(Language.GetString(2434), hurt)
        elseif hurt < 1000000000 then
            local tmp = hurt / 10000
            self.m_hurtText.text = string_format(Language.GetString(2435), tmp)
        else
            local tmp = hurt / 100000000
            self.m_hurtText.text = string_format(Language.GetString(2436), tmp)
        end
    else
        self.m_hurtText.text = string_format(Language.GetString(2434), hurt)
    end

    if isSelf then
        self.m_nameText.text = string_format(Language.GetString(2447), name)
    else
        self.m_nameText.text = name
    end


    self:UpdateRank(rank)
end

function UIGuildBossRankItem:UpdateRank(rank)
    self.rankLabelText.text = ''
    self.m_noRankText.text = ''
    self.m_rankIconTr.gameObject:SetActive(true)
    if rank == 0 then
        self.m_rankIconTr.gameObject:SetActive(false)
        self.m_noRankText.text = Language.GetString(2433)
    elseif rank == 1 then
        self.m_rankImage:SetAtlasSprite("ph03.png", false, AtlasConfig.DynamicLoad)
    elseif rank == 2 then
        self.m_rankImage:SetAtlasSprite("ph04.png", false, AtlasConfig.DynamicLoad)
    elseif rank == 3 then
        self.m_rankImage:SetAtlasSprite("ph05.png", false, AtlasConfig.DynamicLoad)
    else
        self.rankLabelText.text = string_format("%d", rank)
        self.m_rankIconTr.gameObject:SetActive(false)
    end
end

function UIGuildBossRankItem:SetSiblingIndex(index)
    self.transform:SetSiblingIndex(index)
end

return UIGuildBossRankItem

