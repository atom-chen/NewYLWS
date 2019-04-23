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
    public class TMProTMP_SubMeshUIWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(TMPro.TMP_SubMeshUI);
			Utils.BeginObjectRegister(type, L, translator, 0, 13, 12, 9);
			
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetModifiedMaterial", _m_GetModifiedMaterial);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetPaddingForMaterial", _m_GetPaddingForMaterial);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "UpdateMeshPadding", _m_UpdateMeshPadding);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetAllDirty", _m_SetAllDirty);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetVerticesDirty", _m_SetVerticesDirty);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetLayoutDirty", _m_SetLayoutDirty);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetMaterialDirty", _m_SetMaterialDirty);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetPivotDirty", _m_SetPivotDirty);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Cull", _m_Cull);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Rebuild", _m_Rebuild);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "RefreshMaterial", _m_RefreshMaterial);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "RecalculateClipping", _m_RecalculateClipping);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "RecalculateMasking", _m_RecalculateMasking);
			
			
			Utils.RegisterFunc(L, Utils.GETTER_IDX, "fontAsset", _g_get_fontAsset);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "spriteAsset", _g_get_spriteAsset);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "mainTexture", _g_get_mainTexture);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "material", _g_get_material);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "sharedMaterial", _g_get_sharedMaterial);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "fallbackMaterial", _g_get_fallbackMaterial);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "fallbackSourceMaterial", _g_get_fallbackSourceMaterial);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "materialForRendering", _g_get_materialForRendering);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "isDefaultMaterial", _g_get_isDefaultMaterial);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "padding", _g_get_padding);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "canvasRenderer", _g_get_canvasRenderer);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "mesh", _g_get_mesh);
            
			Utils.RegisterFunc(L, Utils.SETTER_IDX, "fontAsset", _s_set_fontAsset);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "spriteAsset", _s_set_spriteAsset);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "material", _s_set_material);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "sharedMaterial", _s_set_sharedMaterial);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "fallbackMaterial", _s_set_fallbackMaterial);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "fallbackSourceMaterial", _s_set_fallbackSourceMaterial);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "isDefaultMaterial", _s_set_isDefaultMaterial);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "padding", _s_set_padding);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "mesh", _s_set_mesh);
            
			
			Utils.EndObjectRegister(type, L, translator, null, null,
			    null, null, null);

		    Utils.BeginClassRegister(type, L, __CreateInstance, 2, 0, 0);
			Utils.RegisterFunc(L, Utils.CLS_IDX, "AddSubTextObject", _m_AddSubTextObject_xlua_st_);
            
			
            
			
			
			
			Utils.EndClassRegister(type, L, translator);
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CreateInstance(RealStatePtr L)
        {
            
			try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
				if(LuaAPI.lua_gettop(L) == 1)
				{
					
					TMPro.TMP_SubMeshUI gen_ret = new TMPro.TMP_SubMeshUI();
					translator.Push(L, gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to TMPro.TMP_SubMeshUI constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_AddSubTextObject_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    TMPro.TextMeshProUGUI _textComponent = (TMPro.TextMeshProUGUI)translator.GetObject(L, 1, typeof(TMPro.TextMeshProUGUI));
                    TMPro.MaterialReference _materialReference;translator.Get(L, 2, out _materialReference);
                    
                        TMPro.TMP_SubMeshUI gen_ret = TMPro.TMP_SubMeshUI.AddSubTextObject( _textComponent, _materialReference );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetModifiedMaterial(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Material _baseMaterial = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
                    
                        UnityEngine.Material gen_ret = gen_to_be_invoked.GetModifiedMaterial( _baseMaterial );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetPaddingForMaterial(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 1) 
                {
                    
                        float gen_ret = gen_to_be_invoked.GetPaddingForMaterial(  );
                        LuaAPI.lua_pushnumber(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 2&& translator.Assignable<UnityEngine.Material>(L, 2)) 
                {
                    UnityEngine.Material _mat = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
                    
                        float gen_ret = gen_to_be_invoked.GetPaddingForMaterial( _mat );
                        LuaAPI.lua_pushnumber(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to TMPro.TMP_SubMeshUI.GetPaddingForMaterial!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_UpdateMeshPadding(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    bool _isExtraPadding = LuaAPI.lua_toboolean(L, 2);
                    bool _isUsingBold = LuaAPI.lua_toboolean(L, 3);
                    
                    gen_to_be_invoked.UpdateMeshPadding( _isExtraPadding, _isUsingBold );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetAllDirty(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    gen_to_be_invoked.SetAllDirty(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetVerticesDirty(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    gen_to_be_invoked.SetVerticesDirty(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetLayoutDirty(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    gen_to_be_invoked.SetLayoutDirty(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetMaterialDirty(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    gen_to_be_invoked.SetMaterialDirty(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetPivotDirty(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    gen_to_be_invoked.SetPivotDirty(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Cull(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Rect _clipRect;translator.Get(L, 2, out _clipRect);
                    bool _validRect = LuaAPI.lua_toboolean(L, 3);
                    
                    gen_to_be_invoked.Cull( _clipRect, _validRect );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Rebuild(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.UI.CanvasUpdate _update;translator.Get(L, 2, out _update);
                    
                    gen_to_be_invoked.Rebuild( _update );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_RefreshMaterial(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    gen_to_be_invoked.RefreshMaterial(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_RecalculateClipping(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    gen_to_be_invoked.RecalculateClipping(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_RecalculateMasking(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    gen_to_be_invoked.RecalculateMasking(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_fontAsset(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.fontAsset);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_spriteAsset(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.spriteAsset);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_mainTexture(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.mainTexture);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_material(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.material);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_sharedMaterial(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.sharedMaterial);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_fallbackMaterial(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.fallbackMaterial);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_fallbackSourceMaterial(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.fallbackSourceMaterial);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_materialForRendering(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.materialForRendering);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_isDefaultMaterial(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushboolean(L, gen_to_be_invoked.isDefaultMaterial);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_padding(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushnumber(L, gen_to_be_invoked.padding);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_canvasRenderer(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.canvasRenderer);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_mesh(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.mesh);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_fontAsset(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.fontAsset = (TMPro.TMP_FontAsset)translator.GetObject(L, 2, typeof(TMPro.TMP_FontAsset));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_spriteAsset(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.spriteAsset = (TMPro.TMP_SpriteAsset)translator.GetObject(L, 2, typeof(TMPro.TMP_SpriteAsset));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_material(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.material = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_sharedMaterial(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.sharedMaterial = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_fallbackMaterial(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.fallbackMaterial = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_fallbackSourceMaterial(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.fallbackSourceMaterial = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_isDefaultMaterial(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.isDefaultMaterial = LuaAPI.lua_toboolean(L, 2);
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_padding(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.padding = (float)LuaAPI.lua_tonumber(L, 2);
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_mesh(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_SubMeshUI gen_to_be_invoked = (TMPro.TMP_SubMeshUI)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.mesh = (UnityEngine.Mesh)translator.GetObject(L, 2, typeof(UnityEngine.Mesh));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
		
		
		
		
    }
}
