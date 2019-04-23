#if USE_UNI_LUA
using LuaAPI = UniLua.Lua;
using RealStatePtr = UniLua.ILuaState;
using LuaCSFunction = UniLua.CSharpFunctionDelegate;
#else
using LuaAPI = XLua.LuaDLL.Lua;
using RealStatePtr = System.IntPtr;
using LuaCSFunction = XLua.LuaDLL.lua_CSFunction;
#endif

using XLua;
using System.Collections.Generic;


namespace XLua.CSObjectWrap
{
    using Utils = XLua.Utils;
    public class AssetBundlesAssetBundleHelperWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(AssetBundles.AssetBundleHelper);
			Utils.BeginObjectRegister(type, L, translator, 0, 0, 0, 0);
			
			
			
			
			
			
			Utils.EndObjectRegister(type, L, translator, null, null,
			    null, null, null);

		    Utils.BeginClassRegister(type, L, __CreateInstance, 10, 0, 0);
			Utils.RegisterFunc(L, Utils.CLS_IDX, "LoadManifestFromAssetbundle", _m_LoadManifestFromAssetbundle_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ShaderCollectionWarmUp", _m_ShaderCollectionWarmUp_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "LoadTextFromAssetbundle", _m_LoadTextFromAssetbundle_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "GetRenderersInChildren", _m_GetRenderersInChildren_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "CompareAndSaveABUpdateFile", _m_CompareAndSaveABUpdateFile_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "RemoveABFromDontUpdatableFile", _m_RemoveABFromDontUpdatableFile_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "IsVersionCached", _m_IsVersionCached_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ClearAllCachedVersions", _m_ClearAllCachedVersions_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ClearCache", _m_ClearCache_xlua_st_);
            
			
            
			
			
			
			Utils.EndClassRegister(type, L, translator);
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CreateInstance(RealStatePtr L)
        {
            
			try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
				if(LuaAPI.lua_gettop(L) == 1)
				{
					
					AssetBundles.AssetBundleHelper gen_ret = new AssetBundles.AssetBundleHelper();
					translator.Push(L, gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to AssetBundles.AssetBundleHelper constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_LoadManifestFromAssetbundle_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.AssetBundle _assetbundle = (UnityEngine.AssetBundle)translator.GetObject(L, 1, typeof(UnityEngine.AssetBundle));
                    string _assetName = LuaAPI.lua_tostring(L, 2);
                    
                        UnityEngine.AssetBundleManifest gen_ret = AssetBundles.AssetBundleHelper.LoadManifestFromAssetbundle( _assetbundle, _assetName );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ShaderCollectionWarmUp_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Object _collection = (UnityEngine.Object)translator.GetObject(L, 1, typeof(UnityEngine.Object));
                    
                    AssetBundles.AssetBundleHelper.ShaderCollectionWarmUp( _collection );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_LoadTextFromAssetbundle_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.AssetBundle _assetbundle = (UnityEngine.AssetBundle)translator.GetObject(L, 1, typeof(UnityEngine.AssetBundle));
                    string _assetName = LuaAPI.lua_tostring(L, 2);
                    
                        UnityEngine.TextAsset gen_ret = AssetBundles.AssetBundleHelper.LoadTextFromAssetbundle( _assetbundle, _assetName );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetRenderersInChildren_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Object _obj = (UnityEngine.Object)translator.GetObject(L, 1, typeof(UnityEngine.Object));
                    
                        UnityEngine.Renderer[] gen_ret = AssetBundles.AssetBundleHelper.GetRenderersInChildren( _obj );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_CompareAndSaveABUpdateFile_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.WWW _serverFile = (UnityEngine.WWW)translator.GetObject(L, 1, typeof(UnityEngine.WWW));
                    UnityEngine.WWW _streamFile = (UnityEngine.WWW)translator.GetObject(L, 2, typeof(UnityEngine.WWW));
                    
                    AssetBundles.AssetBundleHelper.CompareAndSaveABUpdateFile( _serverFile, _streamFile );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_RemoveABFromDontUpdatableFile_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _abName = LuaAPI.lua_tostring(L, 1);
                    
                    AssetBundles.AssetBundleHelper.RemoveABFromDontUpdatableFile( _abName );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_IsVersionCached_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _abPath = LuaAPI.lua_tostring(L, 1);
                    uint _version = LuaAPI.xlua_touint(L, 2);
                    
                        bool gen_ret = AssetBundles.AssetBundleHelper.IsVersionCached( _abPath, _version );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ClearAllCachedVersions_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _abName = LuaAPI.lua_tostring(L, 1);
                    
                        bool gen_ret = AssetBundles.AssetBundleHelper.ClearAllCachedVersions( _abName );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ClearCache_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    
                        bool gen_ret = AssetBundles.AssetBundleHelper.ClearCache(  );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        
        
        
        
        
		
		
		
		
    }
}
