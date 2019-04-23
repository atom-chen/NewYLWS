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
    public class GameUtilityWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(GameUtility);
			Utils.BeginObjectRegister(type, L, translator, 0, 0, 0, 0);
			
			
			
			
			
			
			Utils.EndObjectRegister(type, L, translator, null, null,
			    null, null, null);

		    Utils.BeginClassRegister(type, L, __CreateInstance, 87, 0, 0);
			Utils.RegisterFunc(L, Utils.CLS_IDX, "FormatToUnityPath", _m_FormatToUnityPath_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "FormatToSysFilePath", _m_FormatToSysFilePath_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "FullPathToAssetPath", _m_FullPathToAssetPath_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "GetFileExtension", _m_GetFileExtension_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "GetSpecifyFilesInFolder", _m_GetSpecifyFilesInFolder_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "GetAllFilesInFolder", _m_GetAllFilesInFolder_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "GetAllDirsInFolder", _m_GetAllDirsInFolder_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "CheckFileAndCreateDirWhenNeeded", _m_CheckFileAndCreateDirWhenNeeded_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "CheckDirAndCreateWhenNeeded", _m_CheckDirAndCreateWhenNeeded_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "LoadABFromMemory", _m_LoadABFromMemory_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "LoadABFromMemoryAsync", _m_LoadABFromMemoryAsync_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SafeWriteWWWBytes", _m_SafeWriteWWWBytes_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SafeWriteAllBytes", _m_SafeWriteAllBytes_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SafeWriteAllLines", _m_SafeWriteAllLines_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SafeWriteWWWText", _m_SafeWriteWWWText_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SafeWriteAllText", _m_SafeWriteAllText_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SafeReadAllBytes", _m_SafeReadAllBytes_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SafeReadAllLines", _m_SafeReadAllLines_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SafeReadAllText", _m_SafeReadAllText_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DeleteDirectory", _m_DeleteDirectory_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SafeClearDir", _m_SafeClearDir_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SafeDeleteDir", _m_SafeDeleteDir_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SafeDeleteFile", _m_SafeDeleteFile_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SafeRenameFile", _m_SafeRenameFile_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SafeCopyFile", _m_SafeCopyFile_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "IsEditor", _m_IsEditor_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SetLightMap", _m_SetLightMap_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SetSkyBox", _m_SetSkyBox_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "OpenFog", _m_OpenFog_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SetFog", _m_SetFog_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ScreenPos2TerrainPos", _m_ScreenPos2TerrainPos_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "TouchWujiangIndex", _m_TouchWujiangIndex_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "CreateMeshGo", _m_CreateMeshGo_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "CreateLine", _m_CreateLine_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "CreateRect", _m_CreateRect_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "CreateCircle", _m_CreateCircle_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "CreateHalfCircle", _m_CreateHalfCircle_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "CreateSector", _m_CreateSector_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "CreateRange", _m_CreateRange_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "CreateRingSector", _m_CreateRingSector_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SetLocalFromRotation", _m_SetLocalFromRotation_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ActiveTransform", _m_ActiveTransform_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "RotateAroundY", _m_RotateAroundY_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "RecursiveSetLayer", _m_RecursiveSetLayer_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "GetWorldCorners", _m_GetWorldCorners_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "GetChildTransforms", _m_GetChildTransforms_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "GetChildTexts", _m_GetChildTexts_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "GetChildImages", _m_GetChildImages_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "GetStringLength", _m_GetStringLength_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "GetChildRectTrans", _m_GetChildRectTrans_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "OpenMainCameraDepthTexture", _m_OpenMainCameraDepthTexture_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SetLayer", _m_SetLayer_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ForceCrossFade", _m_ForceCrossFade_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "GetClipLength", _m_GetClipLength_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "DestroyChild", _m_DestroyChild_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ObjectExploded", _m_ObjectExploded_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SetUISortingOrder", _m_SetUISortingOrder_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SetUIGray", _m_SetUIGray_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "KeepCenterAlign", _m_KeepCenterAlign_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "GetRectTransWorldCorners", _m_GetRectTransWorldCorners_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "RegulateTest", _m_RegulateTest_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "GetNameLength", _m_GetNameLength_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SetLineRendererPositionByIndex", _m_SetLineRendererPositionByIndex_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SetShadowHeight", _m_SetShadowHeight_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SetAnchoredPosition", _m_SetAnchoredPosition_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SetPosition", _m_SetPosition_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SetLocalPosition", _m_SetLocalPosition_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SetLocalScale", _m_SetLocalScale_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SetForward", _m_SetForward_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "RotateByEuler", _m_RotateByEuler_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "LookAt", _m_LookAt_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "TransformWorld2RectPos", _m_TransformWorld2RectPos_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "PosWorld2RectPos", _m_PosWorld2RectPos_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SetParticleSystemSpeed", _m_SetParticleSystemSpeed_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SetRaycastTarget", _m_SetRaycastTarget_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "IsRaycastTargetEnabled", _m_IsRaycastTargetEnabled_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "CreateSpriteFromTexture", _m_CreateSpriteFromTexture_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "PlayEffectGo", _m_PlayEffectGo_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ClipGameObjectWithBounds", _m_ClipGameObjectWithBounds_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "CheckGuiRaycastObjects", _m_CheckGuiRaycastObjects_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SetWeaponTrailLayer", _m_SetWeaponTrailLayer_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "UseWeaponTrail", _m_UseWeaponTrail_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SetSceneGOActive", _m_SetSceneGOActive_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "RegisterIOSNotification", _m_RegisterIOSNotification_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ClearNotification", _m_ClearNotification_xlua_st_);
            
			
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "AssetsFolderName", GameUtility.AssetsFolderName);
            
			
			
			
			Utils.EndClassRegister(type, L, translator);
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CreateInstance(RealStatePtr L)
        {
            
			try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
				if(LuaAPI.lua_gettop(L) == 1)
				{
					
					GameUtility gen_ret = new GameUtility();
					translator.Push(L, gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to GameUtility constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_FormatToUnityPath_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _path = LuaAPI.lua_tostring(L, 1);
                    
                        string gen_ret = GameUtility.FormatToUnityPath( _path );
                        LuaAPI.lua_pushstring(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_FormatToSysFilePath_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _path = LuaAPI.lua_tostring(L, 1);
                    
                        string gen_ret = GameUtility.FormatToSysFilePath( _path );
                        LuaAPI.lua_pushstring(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_FullPathToAssetPath_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _full_path = LuaAPI.lua_tostring(L, 1);
                    
                        string gen_ret = GameUtility.FullPathToAssetPath( _full_path );
                        LuaAPI.lua_pushstring(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetFileExtension_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _path = LuaAPI.lua_tostring(L, 1);
                    
                        string gen_ret = GameUtility.GetFileExtension( _path );
                        LuaAPI.lua_pushstring(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetSpecifyFilesInFolder_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 2&& (LuaAPI.lua_isnil(L, 1) || LuaAPI.lua_type(L, 1) == LuaTypes.LUA_TSTRING)&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)) 
                {
                    string _path = LuaAPI.lua_tostring(L, 1);
                    string _pattern = LuaAPI.lua_tostring(L, 2);
                    
                        string[] gen_ret = GameUtility.GetSpecifyFilesInFolder( _path, _pattern );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 3&& (LuaAPI.lua_isnil(L, 1) || LuaAPI.lua_type(L, 1) == LuaTypes.LUA_TSTRING)&& translator.Assignable<string[]>(L, 2)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 3)) 
                {
                    string _path = LuaAPI.lua_tostring(L, 1);
                    string[] _extensions = (string[])translator.GetObject(L, 2, typeof(string[]));
                    bool _exclude = LuaAPI.lua_toboolean(L, 3);
                    
                        string[] gen_ret = GameUtility.GetSpecifyFilesInFolder( _path, _extensions, _exclude );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 2&& (LuaAPI.lua_isnil(L, 1) || LuaAPI.lua_type(L, 1) == LuaTypes.LUA_TSTRING)&& translator.Assignable<string[]>(L, 2)) 
                {
                    string _path = LuaAPI.lua_tostring(L, 1);
                    string[] _extensions = (string[])translator.GetObject(L, 2, typeof(string[]));
                    
                        string[] gen_ret = GameUtility.GetSpecifyFilesInFolder( _path, _extensions );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 1&& (LuaAPI.lua_isnil(L, 1) || LuaAPI.lua_type(L, 1) == LuaTypes.LUA_TSTRING)) 
                {
                    string _path = LuaAPI.lua_tostring(L, 1);
                    
                        string[] gen_ret = GameUtility.GetSpecifyFilesInFolder( _path );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to GameUtility.GetSpecifyFilesInFolder!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetAllFilesInFolder_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    string _path = LuaAPI.lua_tostring(L, 1);
                    
                        string[] gen_ret = GameUtility.GetAllFilesInFolder( _path );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetAllDirsInFolder_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    string _path = LuaAPI.lua_tostring(L, 1);
                    
                        string[] gen_ret = GameUtility.GetAllDirsInFolder( _path );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_CheckFileAndCreateDirWhenNeeded_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _filePath = LuaAPI.lua_tostring(L, 1);
                    
                    GameUtility.CheckFileAndCreateDirWhenNeeded( _filePath );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_CheckDirAndCreateWhenNeeded_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _folderPath = LuaAPI.lua_tostring(L, 1);
                    
                    GameUtility.CheckDirAndCreateWhenNeeded( _folderPath );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_LoadABFromMemory_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.WWW _www = (UnityEngine.WWW)translator.GetObject(L, 1, typeof(UnityEngine.WWW));
                    
                        UnityEngine.AssetBundle gen_ret = GameUtility.LoadABFromMemory( _www );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_LoadABFromMemoryAsync_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.WWW _www = (UnityEngine.WWW)translator.GetObject(L, 1, typeof(UnityEngine.WWW));
                    
                        UnityEngine.AssetBundleCreateRequest gen_ret = GameUtility.LoadABFromMemoryAsync( _www );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SafeWriteWWWBytes_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    string _outFile = LuaAPI.lua_tostring(L, 1);
                    UnityEngine.WWW _www = (UnityEngine.WWW)translator.GetObject(L, 2, typeof(UnityEngine.WWW));
                    
                        bool gen_ret = GameUtility.SafeWriteWWWBytes( _outFile, _www );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SafeWriteAllBytes_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _outFile = LuaAPI.lua_tostring(L, 1);
                    byte[] _outBytes = LuaAPI.lua_tobytes(L, 2);
                    
                        bool gen_ret = GameUtility.SafeWriteAllBytes( _outFile, _outBytes );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SafeWriteAllLines_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    string _outFile = LuaAPI.lua_tostring(L, 1);
                    string[] _outLines = (string[])translator.GetObject(L, 2, typeof(string[]));
                    
                        bool gen_ret = GameUtility.SafeWriteAllLines( _outFile, _outLines );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SafeWriteWWWText_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    string _outFile = LuaAPI.lua_tostring(L, 1);
                    UnityEngine.WWW _www = (UnityEngine.WWW)translator.GetObject(L, 2, typeof(UnityEngine.WWW));
                    
                        bool gen_ret = GameUtility.SafeWriteWWWText( _outFile, _www );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SafeWriteAllText_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _outFile = LuaAPI.lua_tostring(L, 1);
                    string _text = LuaAPI.lua_tostring(L, 2);
                    
                        bool gen_ret = GameUtility.SafeWriteAllText( _outFile, _text );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SafeReadAllBytes_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _inFile = LuaAPI.lua_tostring(L, 1);
                    
                        byte[] gen_ret = GameUtility.SafeReadAllBytes( _inFile );
                        LuaAPI.lua_pushstring(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SafeReadAllLines_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    string _inFile = LuaAPI.lua_tostring(L, 1);
                    
                        string[] gen_ret = GameUtility.SafeReadAllLines( _inFile );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SafeReadAllText_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _inFile = LuaAPI.lua_tostring(L, 1);
                    
                        string gen_ret = GameUtility.SafeReadAllText( _inFile );
                        LuaAPI.lua_pushstring(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DeleteDirectory_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _dirPath = LuaAPI.lua_tostring(L, 1);
                    
                    GameUtility.DeleteDirectory( _dirPath );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SafeClearDir_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _folderPath = LuaAPI.lua_tostring(L, 1);
                    
                        bool gen_ret = GameUtility.SafeClearDir( _folderPath );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SafeDeleteDir_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _folderPath = LuaAPI.lua_tostring(L, 1);
                    
                        bool gen_ret = GameUtility.SafeDeleteDir( _folderPath );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SafeDeleteFile_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _filePath = LuaAPI.lua_tostring(L, 1);
                    
                        bool gen_ret = GameUtility.SafeDeleteFile( _filePath );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SafeRenameFile_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _sourceFileName = LuaAPI.lua_tostring(L, 1);
                    string _destFileName = LuaAPI.lua_tostring(L, 2);
                    
                        bool gen_ret = GameUtility.SafeRenameFile( _sourceFileName, _destFileName );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SafeCopyFile_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _fromFile = LuaAPI.lua_tostring(L, 1);
                    string _toFile = LuaAPI.lua_tostring(L, 2);
                    
                        bool gen_ret = GameUtility.SafeCopyFile( _fromFile, _toFile );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_IsEditor_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    
                        bool gen_ret = GameUtility.IsEditor(  );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetLightMap_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Texture2D _lm = (UnityEngine.Texture2D)translator.GetObject(L, 1, typeof(UnityEngine.Texture2D));
                    
                    GameUtility.SetLightMap( _lm );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetSkyBox_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Material _mat = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    
                    GameUtility.SetSkyBox( _mat );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_OpenFog_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    bool _isOpen = LuaAPI.lua_toboolean(L, 1);
                    
                    GameUtility.OpenFog( _isOpen );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetFog_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.FogMode _mode;translator.Get(L, 1, out _mode);
                    float _density = (float)LuaAPI.lua_tonumber(L, 2);
                    float _begin = (float)LuaAPI.lua_tonumber(L, 3);
                    float _end = (float)LuaAPI.lua_tonumber(L, 4);
                    UnityEngine.Color _color;translator.Get(L, 5, out _color);
                    
                    GameUtility.SetFog( _mode, _density, _begin, _end, _color );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ScreenPos2TerrainPos_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Vector2 _screenPos;translator.Get(L, 1, out _screenPos);
                    string _terrainLayer = LuaAPI.lua_tostring(L, 2);
                    
                        UnityEngine.Vector3 gen_ret = GameUtility.ScreenPos2TerrainPos( _screenPos, _terrainLayer );
                        translator.PushUnityEngineVector3(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_TouchWujiangIndex_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    int _layer = LuaAPI.xlua_tointeger(L, 1);
                    UnityEngine.Camera _fortressMainCamera = (UnityEngine.Camera)translator.GetObject(L, 2, typeof(UnityEngine.Camera));
                    UnityEngine.EventSystems.PointerEventData _eventData = (UnityEngine.EventSystems.PointerEventData)translator.GetObject(L, 3, typeof(UnityEngine.EventSystems.PointerEventData));
                    
                        int gen_ret = GameUtility.TouchWujiangIndex( _layer, _fortressMainCamera, _eventData );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_CreateMeshGo_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    string _name = LuaAPI.lua_tostring(L, 1);
                    UnityEngine.Vector3[] _vertices = (UnityEngine.Vector3[])translator.GetObject(L, 2, typeof(UnityEngine.Vector3[]));
                    UnityEngine.Vector2[] _uvs = (UnityEngine.Vector2[])translator.GetObject(L, 3, typeof(UnityEngine.Vector2[]));
                    UnityEngine.Material _material = (UnityEngine.Material)translator.GetObject(L, 4, typeof(UnityEngine.Material));
                    int _layer = LuaAPI.xlua_tointeger(L, 5);
                    
                        UnityEngine.GameObject gen_ret = GameUtility.CreateMeshGo( _name, _vertices, _uvs, _material, _layer );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_CreateLine_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _parent = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Material _mat = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
                    int _layer = LuaAPI.xlua_tointeger(L, 3);
                    
                        UnityEngine.Transform gen_ret = GameUtility.CreateLine( _parent, _mat, _layer );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_CreateRect_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _parent = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Material _mat = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
                    int _layer = LuaAPI.xlua_tointeger(L, 3);
                    
                        UnityEngine.Transform gen_ret = GameUtility.CreateRect( _parent, _mat, _layer );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_CreateCircle_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _parent = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Material _mat = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
                    int _layer = LuaAPI.xlua_tointeger(L, 3);
                    
                        UnityEngine.Transform gen_ret = GameUtility.CreateCircle( _parent, _mat, _layer );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_CreateHalfCircle_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _parent = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Material _mat = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
                    int _layer = LuaAPI.xlua_tointeger(L, 3);
                    
                        UnityEngine.Transform gen_ret = GameUtility.CreateHalfCircle( _parent, _mat, _layer );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_CreateSector_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _parent = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Material _mat = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
                    int _layer = LuaAPI.xlua_tointeger(L, 3);
                    
                        UnityEngine.Transform gen_ret = GameUtility.CreateSector( _parent, _mat, _layer );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_CreateRange_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _parent = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Material _mat = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
                    int _layer = LuaAPI.xlua_tointeger(L, 3);
                    
                        UnityEngine.Transform gen_ret = GameUtility.CreateRange( _parent, _mat, _layer );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_CreateRingSector_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _parent = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Material _mat = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
                    int _layer = LuaAPI.xlua_tointeger(L, 3);
                    
                        UnityEngine.Transform[] gen_ret = GameUtility.CreateRingSector( _parent, _mat, _layer );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetLocalFromRotation_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _tr = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector3 _fromDir;translator.Get(L, 2, out _fromDir);
                    UnityEngine.Vector3 _toDir;translator.Get(L, 3, out _toDir);
                    
                    GameUtility.SetLocalFromRotation( _tr, _fromDir, _toDir );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ActiveTransform_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _tr = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    bool _isActive = LuaAPI.lua_toboolean(L, 2);
                    
                    GameUtility.ActiveTransform( _tr, _isActive );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_RotateAroundY_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Vector3 _forward;translator.Get(L, 1, out _forward);
                    float _angle = (float)LuaAPI.lua_tonumber(L, 2);
                    
                        UnityEngine.Vector3 gen_ret = GameUtility.RotateAroundY( _forward, _angle );
                        translator.PushUnityEngineVector3(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_RecursiveSetLayer_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.GameObject _obj = (UnityEngine.GameObject)translator.GetObject(L, 1, typeof(UnityEngine.GameObject));
                    int _layer = LuaAPI.xlua_tointeger(L, 2);
                    
                    GameUtility.RecursiveSetLayer( _obj, _layer );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetWorldCorners_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.RectTransform _rectTransform = (UnityEngine.RectTransform)translator.GetObject(L, 1, typeof(UnityEngine.RectTransform));
                    
                        UnityEngine.Vector3[] gen_ret = GameUtility.GetWorldCorners( _rectTransform );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetChildTransforms_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _parent = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    string[] _names = (string[])translator.GetObject(L, 2, typeof(string[]));
                    
                        UnityEngine.Transform[] gen_ret = GameUtility.GetChildTransforms( _parent, _names );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetChildTexts_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _parent = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    string[] _names = (string[])translator.GetObject(L, 2, typeof(string[]));
                    
                        UnityEngine.UI.Text[] gen_ret = GameUtility.GetChildTexts( _parent, _names );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetChildImages_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _parent = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    string[] _names = (string[])translator.GetObject(L, 2, typeof(string[]));
                    
                        UnityEngine.UI.Image[] gen_ret = GameUtility.GetChildImages( _parent, _names );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetStringLength_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _str = LuaAPI.lua_tostring(L, 1);
                    
                        int gen_ret = GameUtility.GetStringLength( _str );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetChildRectTrans_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _parent = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    string[] _names = (string[])translator.GetObject(L, 2, typeof(string[]));
                    
                        UnityEngine.RectTransform[] gen_ret = GameUtility.GetChildRectTrans( _parent, _names );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_OpenMainCameraDepthTexture_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    bool _isOpen = LuaAPI.lua_toboolean(L, 1);
                    
                    GameUtility.OpenMainCameraDepthTexture( _isOpen );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetLayer_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.GameObject _go = (UnityEngine.GameObject)translator.GetObject(L, 1, typeof(UnityEngine.GameObject));
                    int _layer = LuaAPI.xlua_tointeger(L, 2);
                    
                    GameUtility.SetLayer( _go, _layer );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ForceCrossFade_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 5&& translator.Assignable<UnityEngine.Animator>(L, 1)&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)) 
                {
                    UnityEngine.Animator _animator = (UnityEngine.Animator)translator.GetObject(L, 1, typeof(UnityEngine.Animator));
                    string _name = LuaAPI.lua_tostring(L, 2);
                    float _transitionDuration = (float)LuaAPI.lua_tonumber(L, 3);
                    int _layer = LuaAPI.xlua_tointeger(L, 4);
                    float _normalizedTime = (float)LuaAPI.lua_tonumber(L, 5);
                    
                    GameUtility.ForceCrossFade( _animator, _name, _transitionDuration, _layer, _normalizedTime );
                    
                    
                    
                    return 0;
                }
                if(gen_param_count == 4&& translator.Assignable<UnityEngine.Animator>(L, 1)&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Animator _animator = (UnityEngine.Animator)translator.GetObject(L, 1, typeof(UnityEngine.Animator));
                    string _name = LuaAPI.lua_tostring(L, 2);
                    float _transitionDuration = (float)LuaAPI.lua_tonumber(L, 3);
                    int _layer = LuaAPI.xlua_tointeger(L, 4);
                    
                    GameUtility.ForceCrossFade( _animator, _name, _transitionDuration, _layer );
                    
                    
                    
                    return 0;
                }
                if(gen_param_count == 3&& translator.Assignable<UnityEngine.Animator>(L, 1)&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Animator _animator = (UnityEngine.Animator)translator.GetObject(L, 1, typeof(UnityEngine.Animator));
                    string _name = LuaAPI.lua_tostring(L, 2);
                    float _transitionDuration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                    GameUtility.ForceCrossFade( _animator, _name, _transitionDuration );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to GameUtility.ForceCrossFade!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetClipLength_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Animator _animator = (UnityEngine.Animator)translator.GetObject(L, 1, typeof(UnityEngine.Animator));
                    string _clip = LuaAPI.lua_tostring(L, 2);
                    
                        float gen_ret = GameUtility.GetClipLength( _animator, _clip );
                        LuaAPI.lua_pushnumber(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DestroyChild_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.GameObject _go = (UnityEngine.GameObject)translator.GetObject(L, 1, typeof(UnityEngine.GameObject));
                    
                    GameUtility.DestroyChild( _go );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ObjectExploded_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 7&& translator.Assignable<UnityEngine.GameObject>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 6)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 7)) 
                {
                    UnityEngine.GameObject _go = (UnityEngine.GameObject)translator.GetObject(L, 1, typeof(UnityEngine.GameObject));
                    UnityEngine.Vector3 _pos;translator.Get(L, 2, out _pos);
                    float _radius = (float)LuaAPI.lua_tonumber(L, 3);
                    float _power = (float)LuaAPI.lua_tonumber(L, 4);
                    float _upward = (float)LuaAPI.lua_tonumber(L, 5);
                    float _clearTime = (float)LuaAPI.lua_tonumber(L, 6);
                    bool _useGravity = LuaAPI.lua_toboolean(L, 7);
                    
                    GameUtility.ObjectExploded( _go, _pos, _radius, _power, _upward, _clearTime, _useGravity );
                    
                    
                    
                    return 0;
                }
                if(gen_param_count == 6&& translator.Assignable<UnityEngine.GameObject>(L, 1)&& translator.Assignable<UnityEngine.Vector3>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 6)) 
                {
                    UnityEngine.GameObject _go = (UnityEngine.GameObject)translator.GetObject(L, 1, typeof(UnityEngine.GameObject));
                    UnityEngine.Vector3 _pos;translator.Get(L, 2, out _pos);
                    float _radius = (float)LuaAPI.lua_tonumber(L, 3);
                    float _power = (float)LuaAPI.lua_tonumber(L, 4);
                    float _upward = (float)LuaAPI.lua_tonumber(L, 5);
                    float _clearTime = (float)LuaAPI.lua_tonumber(L, 6);
                    
                    GameUtility.ObjectExploded( _go, _pos, _radius, _power, _upward, _clearTime );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to GameUtility.ObjectExploded!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetUISortingOrder_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.GameObject _go = (UnityEngine.GameObject)translator.GetObject(L, 1, typeof(UnityEngine.GameObject));
                    bool _isUI = LuaAPI.lua_toboolean(L, 2);
                    int _order = LuaAPI.xlua_tointeger(L, 3);
                    
                    GameUtility.SetUISortingOrder( _go, _isUI, _order );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetUIGray_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.GameObject _go = (UnityEngine.GameObject)translator.GetObject(L, 1, typeof(UnityEngine.GameObject));
                    bool _isGray = LuaAPI.lua_toboolean(L, 2);
                    
                    GameUtility.SetUIGray( _go, _isGray );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_KeepCenterAlign_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _srcTrans = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Transform _centerTrans = (UnityEngine.Transform)translator.GetObject(L, 2, typeof(UnityEngine.Transform));
                    
                    GameUtility.KeepCenterAlign( _srcTrans, _centerTrans );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetRectTransWorldCorners_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.RectTransform _rectTrans = (UnityEngine.RectTransform)translator.GetObject(L, 1, typeof(UnityEngine.RectTransform));
                    
                        UnityEngine.Vector3[] gen_ret = GameUtility.GetRectTransWorldCorners( _rectTrans );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_RegulateTest_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 3&& (LuaAPI.lua_isnil(L, 1) || LuaAPI.lua_type(L, 1) == LuaTypes.LUA_TSTRING)&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 3)) 
                {
                    string _str = LuaAPI.lua_tostring(L, 1);
                    string _pattern = LuaAPI.lua_tostring(L, 2);
                    bool _ingoreCase = LuaAPI.lua_toboolean(L, 3);
                    
                        bool gen_ret = GameUtility.RegulateTest( _str, _pattern, _ingoreCase );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 2&& (LuaAPI.lua_isnil(L, 1) || LuaAPI.lua_type(L, 1) == LuaTypes.LUA_TSTRING)&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)) 
                {
                    string _str = LuaAPI.lua_tostring(L, 1);
                    string _pattern = LuaAPI.lua_tostring(L, 2);
                    
                        bool gen_ret = GameUtility.RegulateTest( _str, _pattern );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to GameUtility.RegulateTest!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetNameLength_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _temp = LuaAPI.lua_tostring(L, 1);
                    
                        int gen_ret = GameUtility.GetNameLength( _temp );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetLineRendererPositionByIndex_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.LineRenderer _lr = (UnityEngine.LineRenderer)translator.GetObject(L, 1, typeof(UnityEngine.LineRenderer));
                    float _x1 = (float)LuaAPI.lua_tonumber(L, 2);
                    float _y1 = (float)LuaAPI.lua_tonumber(L, 3);
                    float _z1 = (float)LuaAPI.lua_tonumber(L, 4);
                    float _x2 = (float)LuaAPI.lua_tonumber(L, 5);
                    float _y2 = (float)LuaAPI.lua_tonumber(L, 6);
                    float _z2 = (float)LuaAPI.lua_tonumber(L, 7);
                    
                    GameUtility.SetLineRendererPositionByIndex( _lr, _x1, _y1, _z1, _x2, _y2, _z2 );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetShadowHeight_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.GameObject _go = (UnityEngine.GameObject)translator.GetObject(L, 1, typeof(UnityEngine.GameObject));
                    float _y = (float)LuaAPI.lua_tonumber(L, 2);
                    float _offsetY = (float)LuaAPI.lua_tonumber(L, 3);
                    
                    GameUtility.SetShadowHeight( _go, _y, _offsetY );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetAnchoredPosition_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.RectTransform _rt = (UnityEngine.RectTransform)translator.GetObject(L, 1, typeof(UnityEngine.RectTransform));
                    float _x = (float)LuaAPI.lua_tonumber(L, 2);
                    float _y = (float)LuaAPI.lua_tonumber(L, 3);
                    float _z = (float)LuaAPI.lua_tonumber(L, 4);
                    
                    GameUtility.SetAnchoredPosition( _rt, _x, _y, _z );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetPosition_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _tr = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _x = (float)LuaAPI.lua_tonumber(L, 2);
                    float _y = (float)LuaAPI.lua_tonumber(L, 3);
                    float _z = (float)LuaAPI.lua_tonumber(L, 4);
                    
                    GameUtility.SetPosition( _tr, _x, _y, _z );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetLocalPosition_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _tr = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _x = (float)LuaAPI.lua_tonumber(L, 2);
                    float _y = (float)LuaAPI.lua_tonumber(L, 3);
                    float _z = (float)LuaAPI.lua_tonumber(L, 4);
                    
                    GameUtility.SetLocalPosition( _tr, _x, _y, _z );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetLocalScale_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _tr = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _x = (float)LuaAPI.lua_tonumber(L, 2);
                    float _y = (float)LuaAPI.lua_tonumber(L, 3);
                    float _z = (float)LuaAPI.lua_tonumber(L, 4);
                    
                    GameUtility.SetLocalScale( _tr, _x, _y, _z );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetForward_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _tr = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _x = (float)LuaAPI.lua_tonumber(L, 2);
                    float _y = (float)LuaAPI.lua_tonumber(L, 3);
                    float _z = (float)LuaAPI.lua_tonumber(L, 4);
                    
                    GameUtility.SetForward( _tr, _x, _y, _z );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_RotateByEuler_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _tr = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _x = (float)LuaAPI.lua_tonumber(L, 2);
                    float _y = (float)LuaAPI.lua_tonumber(L, 3);
                    float _z = (float)LuaAPI.lua_tonumber(L, 4);
                    
                    GameUtility.RotateByEuler( _tr, _x, _y, _z );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_LookAt_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _tr = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    float _x = (float)LuaAPI.lua_tonumber(L, 2);
                    float _y = (float)LuaAPI.lua_tonumber(L, 3);
                    float _z = (float)LuaAPI.lua_tonumber(L, 4);
                    
                    GameUtility.LookAt( _tr, _x, _y, _z );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_TransformWorld2RectPos_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Camera _mainCam = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    UnityEngine.Camera _uiCam = (UnityEngine.Camera)translator.GetObject(L, 2, typeof(UnityEngine.Camera));
                    UnityEngine.Transform _tr = (UnityEngine.Transform)translator.GetObject(L, 3, typeof(UnityEngine.Transform));
                    UnityEngine.RectTransform _rectTr = (UnityEngine.RectTransform)translator.GetObject(L, 4, typeof(UnityEngine.RectTransform));
                    float _offSetY = (float)LuaAPI.lua_tonumber(L, 5);
                    UnityEngine.Vector2 _recPos;
                    
                        bool gen_ret = GameUtility.TransformWorld2RectPos( _mainCam, _uiCam, _tr, _rectTr, _offSetY, out _recPos );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    translator.PushUnityEngineVector2(L, _recPos);
                        
                    
                    
                    
                    return 2;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_PosWorld2RectPos_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Camera _mainCam = (UnityEngine.Camera)translator.GetObject(L, 1, typeof(UnityEngine.Camera));
                    UnityEngine.Camera _uiCam = (UnityEngine.Camera)translator.GetObject(L, 2, typeof(UnityEngine.Camera));
                    float _wX = (float)LuaAPI.lua_tonumber(L, 3);
                    float _wY = (float)LuaAPI.lua_tonumber(L, 4);
                    float _wZ = (float)LuaAPI.lua_tonumber(L, 5);
                    UnityEngine.RectTransform _rectTr = (UnityEngine.RectTransform)translator.GetObject(L, 6, typeof(UnityEngine.RectTransform));
                    float _offSetY = (float)LuaAPI.lua_tonumber(L, 7);
                    UnityEngine.Vector2 _recPos;
                    
                        bool gen_ret = GameUtility.PosWorld2RectPos( _mainCam, _uiCam, _wX, _wY, _wZ, _rectTr, _offSetY, out _recPos );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    translator.PushUnityEngineVector2(L, _recPos);
                        
                    
                    
                    
                    return 2;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetParticleSystemSpeed_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.GameObject _go = (UnityEngine.GameObject)translator.GetObject(L, 1, typeof(UnityEngine.GameObject));
                    float _speed = (float)LuaAPI.lua_tonumber(L, 2);
                    
                    GameUtility.SetParticleSystemSpeed( _go, _speed );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetRaycastTarget_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.UI.Graphic _g = (UnityEngine.UI.Graphic)translator.GetObject(L, 1, typeof(UnityEngine.UI.Graphic));
                    bool _enabled = LuaAPI.lua_toboolean(L, 2);
                    
                    GameUtility.SetRaycastTarget( _g, _enabled );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_IsRaycastTargetEnabled_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.UI.Graphic _g = (UnityEngine.UI.Graphic)translator.GetObject(L, 1, typeof(UnityEngine.UI.Graphic));
                    
                        bool gen_ret = GameUtility.IsRaycastTargetEnabled( _g );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_CreateSpriteFromTexture_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Texture2D _t = (UnityEngine.Texture2D)translator.GetObject(L, 1, typeof(UnityEngine.Texture2D));
                    
                        UnityEngine.Sprite gen_ret = GameUtility.CreateSpriteFromTexture( _t );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_PlayEffectGo_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.GameObject _effectGO = (UnityEngine.GameObject)translator.GetObject(L, 1, typeof(UnityEngine.GameObject));
                    
                    GameUtility.PlayEffectGo( _effectGO );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ClipGameObjectWithBounds_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.Transform _trans = (UnityEngine.Transform)translator.GetObject(L, 1, typeof(UnityEngine.Transform));
                    UnityEngine.Vector4 _clipRegion;translator.Get(L, 2, out _clipRegion);
                    
                    GameUtility.ClipGameObjectWithBounds( _trans, _clipRegion );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_CheckGuiRaycastObjects_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.EventSystems.PointerEventData _eventData = (UnityEngine.EventSystems.PointerEventData)translator.GetObject(L, 1, typeof(UnityEngine.EventSystems.PointerEventData));
                    
                        bool gen_ret = GameUtility.CheckGuiRaycastObjects( _eventData );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetWeaponTrailLayer_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.GameObject _go = (UnityEngine.GameObject)translator.GetObject(L, 1, typeof(UnityEngine.GameObject));
                    int _layer = LuaAPI.xlua_tointeger(L, 2);
                    
                    GameUtility.SetWeaponTrailLayer( _go, _layer );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_UseWeaponTrail_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.GameObject _go = (UnityEngine.GameObject)translator.GetObject(L, 1, typeof(UnityEngine.GameObject));
                    bool _isUse = LuaAPI.lua_toboolean(L, 2);
                    
                    GameUtility.UseWeaponTrail( _go, _isUse );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetSceneGOActive_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _parentPath = LuaAPI.lua_tostring(L, 1);
                    string _path = LuaAPI.lua_tostring(L, 2);
                    bool _value = LuaAPI.lua_toboolean(L, 3);
                    
                    GameUtility.SetSceneGOActive( _parentPath, _path, _value );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_RegisterIOSNotification_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    double _addDays = LuaAPI.lua_tonumber(L, 1);
                    string _hour = LuaAPI.lua_tostring(L, 2);
                    string _min = LuaAPI.lua_tostring(L, 3);
                    string _title = LuaAPI.lua_tostring(L, 4);
                    string _msg = LuaAPI.lua_tostring(L, 5);
                    
                    GameUtility.RegisterIOSNotification( _addDays, _hour, _min, _title, _msg );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ClearNotification_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    
                    GameUtility.ClearNotification(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        
        
        
        
        
		
		
		
		
    }
}
