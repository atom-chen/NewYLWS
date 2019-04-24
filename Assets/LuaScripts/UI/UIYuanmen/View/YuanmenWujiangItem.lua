local math_floor = math.floor
local Vector3 = Vector3

local YuanmenWujiangItem = BaseClass("YuanmenWujiangItem", UIBaseItem)
local base = UIBaseItem

function YuanmenWujiangItem:OnCreate()
    base.OnCreate(self)
    self:InitView()
end

function YuanmenWujiangItem:InitView()
    self.m_highLightImgTrans,
    self.m_headIconContainerTrans = UIUtil.GetChildRectTrans(self.transform, {
         "headIconContainer/highLightImg", 
         "headIconContainer",
    })

    self.m_levelText, 
    self.m_nameText = UIUtil.GetChildTexts(self.transform, {
         "headIconContainer/levelBg/levelText",
         "nameBg/nameText",
    })

    self.m_frameImg = UIUtil.AddComponent(UIImage, self, "headIconContainer/iconImg/frameBg", AtlasConfig.DynamicLoad)
    self.m_iconImg = UIUtil.AddComponent(UIImage, self, "headIconContainer/iconImg", AtlasConfig.RoleIcon)
    self.m_countryImg = UIUtil.AddComponent(UIImage, self, "headIconContainer/countryImg", AtlasConfig.DynamicLoad)
    self.m_jobImg = UIUtil.AddComponent(UIImage, self, "nameBg/jobImg", AtlasConfig.DynamicLoad)

    self.m_bloodSlider = UIUtil.FindSlider(self.transform, "bloodSlider") 
    self.m_nuqiSlider = UIUtil.FindSlider(self.transform, "nuqiSlider") 
    self.m_bloodImg = UIUtil.AddComponent(UIImage, self, "bloodSlider/bloodImg", AtlasConfig.DynamicLoad)
    self.m_nuqiImg = UIUtil.AddComponent(UIImage, self, "nuqiSlider/nuqiImg", AtlasConfig.DynamicLoad)
end

function YuanmenWujiangItem:UpdateData(wujiang_info,index)  
    local monsterCfg = ConfigUtil.GetMonsterCfgByID(wujiang_info.monster_id)
    if not monsterCfg then 
         return
    end
    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(monsterCfg.role_id)
    if not wujiangCfg then 
        return
    end 

    if index == 1 then 
        self.m_headIconContainerTrans.localScale = Vector3.New(1.1, 1.1, 1.1) 
        self.m_headIconContainerTrans.localPosition = Vector3.New(0, 28, 0)
        self.m_highLightImgTrans.gameObject:SetActive(true) 
    end 

    self.m_levelText.text = math_floor(wujiang_info.monster_level)
    self.m_nameText.text = wujiangCfg.sName  

    UILogicUtil.SetWuJiangFrame(self.m_frameImg, wujiangCfg.rare)
    self.m_iconImg:SetAtlasSprite(wujiangCfg.sIcon)
    UILogicUtil.SetWuJiangCountryImage(self.m_countryImg, wujiangCfg.country)
    UILogicUtil.SetWuJiangJobImage(self.m_jobImg, wujiangCfg.nTypeJob)

    local bloodPercent =  wujiang_info.hp / wujiang_info.max_hp
    if bloodPercent >= 1 then
        bloodPercent = 1
    end 
    if bloodPercent < 0.3 then 
        self.m_bloodImg:SetAtlasSprite("st01.png")    -- 血量低于30%时，显示红色血条
    else
        self.m_bloodImg:SetAtlasSprite("st02.png")
    end 
    self.m_bloodSlider.value = bloodPercent  

    local nuqiPersent = wujiang_info.nuqi / wujiang_info.max_nuqi
    if nuqiPersent >= 1 then
        nuqiPersent = 1
        self.m_nuqiImg:SetAtlasSprite("st04.png") 
    else
        self.m_nuqiImg:SetAtlasSprite("st03.png") 
    end 
    
    self.m_nuqiSlider.value = nuqiPersent 
 
end 

function YuanmenWujiangItem:OnDestroy()
    if self.m_frameImg then
        self.m_frameImg:Delete()
        self.m_frameImg = nil
    end

    if self.m_iconImg then
        self.m_iconImg:Delete()
        self.m_iconImg = nil
    end

    if self.m_countryImg then
        self.m_countryImg:Delete()
        self.m_countryImg = nil
    end

    if self.m_jobImg then
        self.m_jobImg:Delete()
        self.m_jobImg = nil
    end  

    if self.m_bloodImg then
        self.m_bloodImg:Delete()
        self.m_bloodImg = nil
    end

    if self.m_nuqiImg then
        self.m_nuqiImg:Delete()
        self.m_nuqiImg = nil
    end
    self.m_headIconContainerTrans.localScale = Vector3.one
    self.m_headIconContainerTrans.localPosition = Vector3.New(0, 24, 0)
    self.m_highLightImgTrans.gameObject:SetActive(false) 
    
    base.OnDestroy(self)
end

return YuanmenWujiangItem




