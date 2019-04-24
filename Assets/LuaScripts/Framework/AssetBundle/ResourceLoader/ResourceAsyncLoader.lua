-- /// <summary>
-- /// added by wsh @ 2017.12.22
-- /// 功能：资源异步请求，本地、远程通杀
-- /// 注意：
-- /// 1、Unity5.3官方建议用UnityWebRequest取代WWW：https://unity3d.com/cn/learn/tutorials/topics/best-practices/assetbundle-fundamentals?playlist=30089
-- /// 2、这里还是采用WWW，因为UnityWebRequest的Bug无数：
-- ///     1）Unity5.3.5：http://blog.csdn.net/st75033562/article/details/52411197
-- ///     2）Unity5.5：https://bitbucket.org/Unity-Technologies/assetbundledemo/pull-requests/25/feature-unitywebrequest/diff#comment-None
-- ///     3）还有各个版本发行说明中关于UnityWebRequest的修复，如Unity5.4.1（5.4全系列版本基本都有修复这个API的Bug）：https://unity3d.com/cn/unity/whats-new/unity-5.4.1
-- ///     4）此外对于LZMA压缩，采用UnityWebRequest好处在于节省内存，性能上并不比WWW优越：https://docs.unity3d.com/530/Documentation/Manual/AssetBundleCompression.html
-- /// 3、LoadFromFile(Async)在Unity5.4以上支持streamingAsset目录加载资源，5.3.7和5.4.3以后支持LAMZ压缩，但是没法加载非Assetbundle资源
-- /// 4、另外，虽然LoadFromFile(Async)是加载ab最快的API，但是会延缓Asset加载的时间（读磁盘），如果ab尽量预加载，不考虑内存敏感问题，这个API意义就不大
-- /// </summary>

-- <summary>
-- added by graylei @ 2018.12.5
-- 注意：
-- 1、www.assetbundle这种取ab的方式会造成严重的卡顿，同时会导致场景切换加载速度超长，原因猜测是因为单个包体有5M左右，取ab时会先将lzma压缩解压再压缩成lz4导致的，所以弃用了。
-- 2、www.bytes取出来的是未解压的原始包大小的字节数组，不存在解压缩，所以没有性能问题。
-- 3、LoadFromMemoryAsync加载lzma压缩的ab包时没有额外的内存占用，但是从ab包中加载asset时也会有性能问题，造成卡顿
-- 4、基于上面的分析，准备使用www.bytes和LoadFromMemoryAsync配合使用。同时只加载需要的asset, 对于一些需要将asset全部加载出来的ab包整理出来特殊处理，不存在只有部分asset需要加载的ab包
-- </summary>

local ResourceLoaderBase = require("Framework.AssetBundle.ResourceLoader.ResourceLoaderBase")
local AssetBundleHelper = CS.AssetBundles.AssetBundleHelper
local AssetBundleUtility = CS.AssetBundles.AssetBundleUtility
local GameUtility = CS.GameUtility
local AssetBundle = CS.UnityEngine.AssetBundle
local WWW = CS.UnityEngine.WWW
local ResourceAsyncLoader = BaseClass("ResourceAsyncLoader", ResourceLoaderBase)

function ResourceAsyncLoader:__init(sequence)
    self.m_seq = sequence
    self.m_abName = nil
    self.m_url = nil
    self.m_www = nil
    self.m_isOver = nil
    self.m_notCache = false
    self.m_needDownload = false
    self.m_isLoadFinish = false
end

function ResourceAsyncLoader:Init(url, abName, notCache)
    self.m_abName = abName
    self.m_url = url
    self.m_notCache = (notCache == nil) and false or notCache
    self.m_www = nil
    self.m_isOver = false
    self.m_needDownload = false
    self.m_isLoadFinish = false
end

function ResourceAsyncLoader:InitWithABName(url, abName, needDownload)
    self.m_abName = abName
    self.m_url = url
    self.m_notCache = false
    self.m_www = nil
    self.m_isOver = false
    self.m_needDownload = needDownload
    self.m_isLoadFinish = false
end

function ResourceAsyncLoader:IsCache()
    return not self.m_notCache
end

function ResourceAsyncLoader:GetSequence()
    return self.m_seq
end

function ResourceAsyncLoader:GetABName()
    return self.m_abName
end

function ResourceAsyncLoader:GetURL()
    return self.m_url
end

function ResourceAsyncLoader:GetAssetbundle()
    local error = self:GetError()
    if error then
        return false
    end
    return self.m_www.assetBundle
end

function ResourceAsyncLoader:GetText()
    return self.m_www.text
end

function ResourceAsyncLoader:GetWWW()
    return self.m_www
end

function ResourceAsyncLoader:NeedDownload()
    return self.m_needDownload
end

function ResourceAsyncLoader:GetError()
    if not self.m_www then
        return nil
    end

    if self.m_www.error and self.m_www.error ~= '' then
        return self.m_www.error
    else
        return nil
    end
end

function ResourceAsyncLoader:IsDone()
    return self.m_isOver
end

function ResourceAsyncLoader:Start()
    if string.contains(self.m_url, ".assetbundle") and not string.contains(self.m_url, ABConfig.LuaABFileName) then
        self.m_www = WWW.LoadFromCacheOrDownload(self.m_url, 1)
    else
        self.m_www = WWW(self.m_url)
    end

    if self.m_www then
        coroutine.waituntil(function()
            return self.m_www.isDone
        end)

        local error = self:GetError()
        if error then
            Logger.LogError(error .. " for " .. self.m_url)
        end
        
    else
        Logger.LogError("New www failed!!!")
    end
    
    self.m_isLoadFinish = true
end

function ResourceAsyncLoader:Progress()
    if self:IsDone() then
        return 1
    end

    if not self.m_www then
        return 0
    end

    return self.m_www.progress
end

function ResourceAsyncLoader:Update()
    if self:IsDone() then
        return
    end

    self.m_isOver = self.m_isLoadFinish
    if not self.m_isOver then
        return
    end

    local error = self:GetError()
    if error then
        Logger.LogError(error .. " for " .. self.m_url)
    else
        if self.m_needDownload then
            -- Logger.Log("Remove donot update record : " .. self.m_abName)
            AssetBundleHelper.RemoveABFromDontUpdatableFile(self.m_abName)
        end
    end
end

function ResourceAsyncLoader:Dispose()
    if self.m_www then
        self.m_www:Dispose()
        self.m_www = nil
    end
    self.m_isOver = false
    self.m_isLoadFinish = false
    ResourceAsyncLoaderFactory:GetInstance():RecycleLoader(self)
end

return ResourceAsyncLoader