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
    public class GhostingWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(Ghosting);
			Utils.BeginObjectRegister(type, L, translator, 0, 4, 0, 0);
			
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Pause", _m_Pause);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Resume", _m_Resume);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "InitGhosting", _m_InitGhosting);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "MeshCreate", _m_MeshCreate);
			
			
			
			
			
			Utils.EndObjectRegister(type, L, translator, null, null,
			    null, null, null);

		    Utils.BeginClassRegister(type, L, __CreateInstance, 2, 0, 0);
			Utils.RegisterFunc(L, Utils.CLS_IDX, "CreateGhosting", _m_CreateGhosting_xlua_st_);
            
			
            
			
			
			
			Utils.EndClassRegister(type, L, translator);
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CreateInstance(RealStatePtr L)
        {
            
			try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
				if(LuaAPI.lua_gettop(L) == 1)
				{
					
					Ghosting gen_ret = new Ghosting();
					translator.Push(L, gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to Ghosting constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Pause(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Ghosting gen_to_be_invoked = (Ghosting)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    gen_to_be_invoked.Pause(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Resume(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Ghosting gen_to_be_invoked = (Ghosting)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    gen_to_be_invoked.Resume(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_InitGhosting(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Ghosting gen_to_be_invoked = (Ghosting)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    GhostingEffect _ghostingEffect = (GhostingEffect)translator.GetObject(L, 2, typeof(GhostingEffect));
                    UnityEngine.Renderer _affectRender = (UnityEngine.Renderer)translator.GetObject(L, 3, typeof(UnityEngine.Renderer));
                    UnityEngine.MeshFilter _affectMeshFilter = (UnityEngine.MeshFilter)translator.GetObject(L, 4, typeof(UnityEngine.MeshFilter));
                    UnityEngine.Color _ghostingColor;translator.Get(L, 5, out _ghostingColor);
                    float _ghostingLife = (float)LuaAPI.lua_tonumber(L, 6);
                    bool _ignoreTimeScale = LuaAPI.lua_toboolean(L, 7);
                    
                    gen_to_be_invoked.InitGhosting( _ghostingEffect, _affectRender, _affectMeshFilter, _ghostingColor, _ghostingLife, _ignoreTimeScale );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_MeshCreate(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Ghosting gen_to_be_invoked = (Ghosting)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Material _mat = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
                    
                    gen_to_be_invoked.MeshCreate( _mat );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_CreateGhosting_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 8&& translator.Assignable<UnityEngine.Material>(L, 1)&& translator.Assignable<GhostingEffect>(L, 2)&& translator.Assignable<UnityEngine.Renderer>(L, 3)&& translator.Assignable<UnityEngine.MeshFilter>(L, 4)&& translator.Assignable<UnityEngine.Color>(L, 5)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 6)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 7)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 8)) 
                {
                    UnityEngine.Material _mat = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    GhostingEffect _ghostingEffect = (GhostingEffect)translator.GetObject(L, 2, typeof(GhostingEffect));
                    UnityEngine.Renderer _affectRender = (UnityEngine.Renderer)translator.GetObject(L, 3, typeof(UnityEngine.Renderer));
                    UnityEngine.MeshFilter _affectMeshFilter = (UnityEngine.MeshFilter)translator.GetObject(L, 4, typeof(UnityEngine.MeshFilter));
                    UnityEngine.Color _ghostingColor;translator.Get(L, 5, out _ghostingColor);
                    float _ghostingLife = (float)LuaAPI.lua_tonumber(L, 6);
                    bool _ignoreTimeScale = LuaAPI.lua_toboolean(L, 7);
                    bool _ignorePause = LuaAPI.lua_toboolean(L, 8);
                    
                        Ghosting gen_ret = Ghosting.CreateGhosting( _mat, _ghostingEffect, _affectRender, _affectMeshFilter, _ghostingColor, _ghostingLife, _ignoreTimeScale, _ignorePause );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 7&& translator.Assignable<UnityEngine.Material>(L, 1)&& translator.Assignable<GhostingEffect>(L, 2)&& translator.Assignable<UnityEngine.Renderer>(L, 3)&& translator.Assignable<UnityEngine.MeshFilter>(L, 4)&& translator.Assignable<UnityEngine.Color>(L, 5)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 6)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 7)) 
                {
                    UnityEngine.Material _mat = (UnityEngine.Material)translator.GetObject(L, 1, typeof(UnityEngine.Material));
                    GhostingEffect _ghostingEffect = (GhostingEffect)translator.GetObject(L, 2, typeof(GhostingEffect));
                    UnityEngine.Renderer _affectRender = (UnityEngine.Renderer)translator.GetObject(L, 3, typeof(UnityEngine.Renderer));
                    UnityEngine.MeshFilter _affectMeshFilter = (UnityEngine.MeshFilter)translator.GetObject(L, 4, typeof(UnityEngine.MeshFilter));
                    UnityEngine.Color _ghostingColor;translator.Get(L, 5, out _ghostingColor);
                    float _ghostingLife = (float)LuaAPI.lua_tonumber(L, 6);
                    bool _ignoreTimeScale = LuaAPI.lua_toboolean(L, 7);
                    
                        Ghosting gen_ret = Ghosting.CreateGhosting( _mat, _ghostingEffect, _affectRender, _affectMeshFilter, _ghostingColor, _ghostingLife, _ignoreTimeScale );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to Ghosting.CreateGhosting!");
            
        }
        
        
        
        
        
        
		
		
		
		
    }
}
