local UIGuildWarRankItem = BaseClass("UIGuildWarRankItem", UIBaseItem)
local base = UIBaseItem      

function UIGuildWarRankItem:OnDestroy()
    if self.m_cityIconImage then
        self.m_cityIconImage:Delete()
        self.m_cityIconImage = nil
    end

    if self.m_guildIconImg then
        self.m_guildIconImg:Delete()
        self.m_guildIconImg = nil
    end

    if self.m_rankNumImg then
        self.m_rankNumImg:Delete()
        self.m_rankNumImg = nil
    end
    
    base.OnDestroy(self)
end

function UIGuildWarRankItem:OnCreate()
    base.OnCreate(self)
    self.m_guildItem = nil
    self.m_itemLoaderSeq = 0
    
    self:InitView()
end

function UIGuildWarRankItem:InitView()
    self.m_rankNumImgTr = UIUtil.GetChildTransforms(self.transform, { 
        "RankNumImg",
    })

    self.m_rankNumTxt,
    self.m_guildNameTxt,
    self.m_serverNameTxt,
    self.m_cityNumTxt,
    self.m_integrationTxt = UIUtil.GetChildTexts(self.transform, {
        "RankNumTxt",
        "GuildNameTxt",
        "ServerNameTxt",
        "CityNum",
        "IntegrationTxt",
    }) 
 
    self.m_rankNumImg = UIUtil.AddComponent(UIImage, self,  "RankNumImg", AtlasConfig.DynamicLoad)
    self.m_guildIconImg = UIUtil.AddComponent(UIImage, self,  "GuildItemPos/GuildIcon", AtlasConfig.DynamicLoad2) 
    self.m_cityIconImage = UIUtil.AddComponent(UIImage, self, "CityImg", AtlasConfig.DynamicLoad2)
end


function UIGuildWarRankItem:UpdateData(rankInfo)
    if not rankInfo then
        return
    end
    local cityNum = math.ceil(rankInfo.occ_city_num)
    local rankNum = math.ceil(rankInfo.rank)
    local guildBrief = rankInfo.guild_brief
    self:SetRankNum(rankNum)
    self.m_cityNumTxt.text = cityNum

    local guildIconCfg = ConfigUtil.GetGuildIconCfgByID(guildBrief.icon)
    if guildIconCfg then
        self.m_guildIconImg:SetAtlasSprite(guildIconCfg.icon..".png")
    end
    self.m_guildNameTxt.text = guildBrief.name
    self.m_serverNameTxt.text = guildBrief.dist_name          
    self.m_integrationTxt.text = math.ceil(guildBrief.warcraftscore)
    
    local cityIcon = UILogicUtil.GetGuildWarCityIcon(guildBrief)
    if cityIcon then
        self.m_cityIconImage:SetAtlasSprite(cityIcon, true)
    end
end

function UIGuildWarRankItem:SetRankNum(rankNum)
    if rankNum <= 3 then
        self.m_rankNumImgTr.gameObject:SetActive(true)
        self.m_rankNumTxt.text = ""
        UILogicUtil.SetNumSpt(self.m_rankNumImg, rankNum, true)
    else
        self.m_rankNumImgTr.gameObject:SetActive(false)
        self.m_rankNumTxt.text = rankNum
    end 
end


return UIGuildWarRankItem