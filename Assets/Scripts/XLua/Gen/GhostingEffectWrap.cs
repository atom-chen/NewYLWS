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
    public class GhostingEffectWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(GhostingEffect);
			Utils.BeginObjectRegister(type, L, translator, 0, 4, 7, 7);
			
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Pause", _m_Pause);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Resume", _m_Resume);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Stop", _m_Stop);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "RemoveGhosting", _m_RemoveGhosting);
			
			
			Utils.RegisterFunc(L, Utils.GETTER_IDX, "m_ghostingLife", _g_get_m_ghostingLife);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "m_triggerInterval", _g_get_m_triggerInterval);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "m_ghostingEffectTime", _g_get_m_ghostingEffectTime);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "m_ignoreTimeScale", _g_get_m_ignoreTimeScale);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "m_maxGhosting", _g_get_m_maxGhosting);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "m_ghostingColor", _g_get_m_ghostingColor);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "m_mat", _g_get_m_mat);
            
			Utils.RegisterFunc(L, Utils.SETTER_IDX, "m_ghostingLife", _s_set_m_ghostingLife);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "m_triggerInterval", _s_set_m_triggerInterval);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "m_ghostingEffectTime", _s_set_m_ghostingEffectTime);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "m_ignoreTimeScale", _s_set_m_ignoreTimeScale);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "m_maxGhosting", _s_set_m_maxGhosting);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "m_ghostingColor", _s_set_m_ghostingColor);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "m_mat", _s_set_m_mat);
            
			
			Utils.EndObjectRegister(type, L, translator, null, null,
			    null, null, null);

		    Utils.BeginClassRegister(type, L, __CreateInstance, 2, 0, 0);
			Utils.RegisterFunc(L, Utils.CLS_IDX, "ApplyGhostingEffect", _m_ApplyGhostingEffect_xlua_st_);
            
			
            
			
			
			
			Utils.EndClassRegister(type, L, translator);
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CreateInstance(RealStatePtr L)
        {
            
			try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
				if(LuaAPI.lua_gettop(L) == 1)
				{
					
					GhostingEffect gen_ret = new GhostingEffect();
					translator.Push(L, gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to GhostingEffect constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Pause(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                GhostingEffect gen_to_be_invoked = (GhostingEffect)translator.FastGetCSObj(L, 1);
            
            
                
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
            
            
                GhostingEffect gen_to_be_invoked = (GhostingEffect)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    gen_to_be_invoked.Resume(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Stop(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                GhostingEffect gen_to_be_invoked = (GhostingEffect)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    gen_to_be_invoked.Stop(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_RemoveGhosting(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                GhostingEffect gen_to_be_invoked = (GhostingEffect)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    Ghosting _ghosting = (Ghosting)translator.GetObject(L, 2, typeof(Ghosting));
                    
                    gen_to_be_invoked.RemoveGhosting( _ghosting );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ApplyGhostingEffect_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 9&& translator.Assignable<System.Collections.Generic.List<UnityEngine.GameObject>>(L, 1)&& translator.Assignable<UnityEngine.Material>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& translator.Assignable<UnityEngine.Color>(L, 6)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 7)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 8)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 9)) 
                {
                    System.Collections.Generic.List<UnityEngine.GameObject> _gos = (System.Collections.Generic.List<UnityEngine.GameObject>)translator.GetObject(L, 1, typeof(System.Collections.Generic.List<UnityEngine.GameObject>));
                    UnityEngine.Material _mat = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
                    float _ghostingLife = (float)LuaAPI.lua_tonumber(L, 3);
                    float _triggerInterval = (float)LuaAPI.lua_tonumber(L, 4);
                    int _maxGhosting = LuaAPI.xlua_tointeger(L, 5);
                    UnityEngine.Color _ghostingColor;translator.Get(L, 6, out _ghostingColor);
                    float _ghostingEffectTime = (float)LuaAPI.lua_tonumber(L, 7);
                    bool _ignoreTimeScale = LuaAPI.lua_toboolean(L, 8);
                    bool _ignorePause = LuaAPI.lua_toboolean(L, 9);
                    
                    GhostingEffect.ApplyGhostingEffect( _gos, _mat, _ghostingLife, _triggerInterval, _maxGhosting, _ghostingColor, _ghostingEffectTime, _ignoreTimeScale, _ignorePause );
                    
                    
                    
                    return 0;
                }
                if(gen_param_count == 8&& translator.Assignable<System.Collections.Generic.List<UnityEngine.GameObject>>(L, 1)&& translator.Assignable<UnityEngine.Material>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& translator.Assignable<UnityEngine.Color>(L, 6)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 7)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 8)) 
                {
                    System.Collections.Generic.List<UnityEngine.GameObject> _gos = (System.Collections.Generic.List<UnityEngine.GameObject>)translator.GetObject(L, 1, typeof(System.Collections.Generic.List<UnityEngine.GameObject>));
                    UnityEngine.Material _mat = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
                    float _ghostingLife = (float)LuaAPI.lua_tonumber(L, 3);
                    float _triggerInterval = (float)LuaAPI.lua_tonumber(L, 4);
                    int _maxGhosting = LuaAPI.xlua_tointeger(L, 5);
                    UnityEngine.Color _ghostingColor;translator.Get(L, 6, out _ghostingColor);
                    float _ghostingEffectTime = (float)LuaAPI.lua_tonumber(L, 7);
                    bool _ignoreTimeScale = LuaAPI.lua_toboolean(L, 8);
                    
                    GhostingEffect.ApplyGhostingEffect( _gos, _mat, _ghostingLife, _triggerInterval, _maxGhosting, _ghostingColor, _ghostingEffectTime, _ignoreTimeScale );
                    
                    
                    
                    return 0;
                }
                if(gen_param_count == 7&& translator.Assignable<System.Collections.Generic.List<UnityEngine.GameObject>>(L, 1)&& translator.Assignable<UnityEngine.Material>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& translator.Assignable<UnityEngine.Color>(L, 6)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 7)) 
                {
                    System.Collections.Generic.List<UnityEngine.GameObject> _gos = (System.Collections.Generic.List<UnityEngine.GameObject>)translator.GetObject(L, 1, typeof(System.Collections.Generic.List<UnityEngine.GameObject>));
                    UnityEngine.Material _mat = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
                    float _ghostingLife = (float)LuaAPI.lua_tonumber(L, 3);
                    float _triggerInterval = (float)LuaAPI.lua_tonumber(L, 4);
                    int _maxGhosting = LuaAPI.xlua_tointeger(L, 5);
                    UnityEngine.Color _ghostingColor;translator.Get(L, 6, out _ghostingColor);
                    float _ghostingEffectTime = (float)LuaAPI.lua_tonumber(L, 7);
                    
                    GhostingEffect.ApplyGhostingEffect( _gos, _mat, _ghostingLife, _triggerInterval, _maxGhosting, _ghostingColor, _ghostingEffectTime );
                    
                    
                    
                    return 0;
                }
                if(gen_param_count == 6&& translator.Assignable<System.Collections.Generic.List<UnityEngine.GameObject>>(L, 1)&& translator.Assignable<UnityEngine.Material>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& translator.Assignable<UnityEngine.Color>(L, 6)) 
                {
                    System.Collections.Generic.List<UnityEngine.GameObject> _gos = (System.Collections.Generic.List<UnityEngine.GameObject>)translator.GetObject(L, 1, typeof(System.Collections.Generic.List<UnityEngine.GameObject>));
                    UnityEngine.Material _mat = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
                    float _ghostingLife = (float)LuaAPI.lua_tonumber(L, 3);
                    float _triggerInterval = (float)LuaAPI.lua_tonumber(L, 4);
                    int _maxGhosting = LuaAPI.xlua_tointeger(L, 5);
                    UnityEngine.Color _ghostingColor;translator.Get(L, 6, out _ghostingColor);
                    
                    GhostingEffect.ApplyGhostingEffect( _gos, _mat, _ghostingLife, _triggerInterval, _maxGhosting, _ghostingColor );
                    
                    
                    
                    return 0;
                }
                if(gen_param_count == 9&& translator.Assignable<UnityEngine.GameObject>(L, 1)&& translator.Assignable<UnityEngine.Material>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& translator.Assignable<UnityEngine.Color>(L, 6)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 7)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 8)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 9)) 
                {
                    UnityEngine.GameObject _go = (UnityEngine.GameObject)translator.GetObject(L, 1, typeof(UnityEngine.GameObject));
                    UnityEngine.Material _mat = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
                    float _ghostingLife = (float)LuaAPI.lua_tonumber(L, 3);
                    float _triggerInterval = (float)LuaAPI.lua_tonumber(L, 4);
                    int _maxGhosting = LuaAPI.xlua_tointeger(L, 5);
                    UnityEngine.Color _ghostingColor;translator.Get(L, 6, out _ghostingColor);
                    float _ghostingEffectTime = (float)LuaAPI.lua_tonumber(L, 7);
                    bool _ignoreTimeScale = LuaAPI.lua_toboolean(L, 8);
                    bool _ignorePause = LuaAPI.lua_toboolean(L, 9);
                    
                    GhostingEffect.ApplyGhostingEffect( _go, _mat, _ghostingLife, _triggerInterval, _maxGhosting, _ghostingColor, _ghostingEffectTime, _ignoreTimeScale, _ignorePause );
                    
                    
                    
                    return 0;
                }
                if(gen_param_count == 8&& translator.Assignable<UnityEngine.GameObject>(L, 1)&& translator.Assignable<UnityEngine.Material>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& translator.Assignable<UnityEngine.Color>(L, 6)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 7)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 8)) 
                {
                    UnityEngine.GameObject _go = (UnityEngine.GameObject)translator.GetObject(L, 1, typeof(UnityEngine.GameObject));
                    UnityEngine.Material _mat = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
                    float _ghostingLife = (float)LuaAPI.lua_tonumber(L, 3);
                    float _triggerInterval = (float)LuaAPI.lua_tonumber(L, 4);
                    int _maxGhosting = LuaAPI.xlua_tointeger(L, 5);
                    UnityEngine.Color _ghostingColor;translator.Get(L, 6, out _ghostingColor);
                    float _ghostingEffectTime = (float)LuaAPI.lua_tonumber(L, 7);
                    bool _ignoreTimeScale = LuaAPI.lua_toboolean(L, 8);
                    
                    GhostingEffect.ApplyGhostingEffect( _go, _mat, _ghostingLife, _triggerInterval, _maxGhosting, _ghostingColor, _ghostingEffectTime, _ignoreTimeScale );
                    
                    
                    
                    return 0;
                }
                if(gen_param_count == 7&& translator.Assignable<UnityEngine.GameObject>(L, 1)&& translator.Assignable<UnityEngine.Material>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& translator.Assignable<UnityEngine.Color>(L, 6)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 7)) 
                {
                    UnityEngine.GameObject _go = (UnityEngine.GameObject)translator.GetObject(L, 1, typeof(UnityEngine.GameObject));
                    UnityEngine.Material _mat = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
                    float _ghostingLife = (float)LuaAPI.lua_tonumber(L, 3);
                    float _triggerInterval = (float)LuaAPI.lua_tonumber(L, 4);
                    int _maxGhosting = LuaAPI.xlua_tointeger(L, 5);
                    UnityEngine.Color _ghostingColor;translator.Get(L, 6, out _ghostingColor);
                    float _ghostingEffectTime = (float)LuaAPI.lua_tonumber(L, 7);
                    
                    GhostingEffect.ApplyGhostingEffect( _go, _mat, _ghostingLife, _triggerInterval, _maxGhosting, _ghostingColor, _ghostingEffectTime );
                    
                    
                    
                    return 0;
                }
                if(gen_param_count == 6&& translator.Assignable<UnityEngine.GameObject>(L, 1)&& translator.Assignable<UnityEngine.Material>(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 5)&& translator.Assignable<UnityEngine.Color>(L, 6)) 
                {
                    UnityEngine.GameObject _go = (UnityEngine.GameObject)translator.GetObject(L, 1, typeof(UnityEngine.GameObject));
                    UnityEngine.Material _mat = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
                    float _ghostingLife = (float)LuaAPI.lua_tonumber(L, 3);
                    float _triggerInterval = (float)LuaAPI.lua_tonumber(L, 4);
                    int _maxGhosting = LuaAPI.xlua_tointeger(L, 5);
                    UnityEngine.Color _ghostingColor;translator.Get(L, 6, out _ghostingColor);
                    
                    GhostingEffect.ApplyGhostingEffect( _go, _mat, _ghostingLife, _triggerInterval, _maxGhosting, _ghostingColor );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to GhostingEffect.ApplyGhostingEffect!");
            
        }
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_m_ghostingLife(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                GhostingEffect gen_to_be_invoked = (GhostingEffect)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushnumber(L, gen_to_be_invoked.m_ghostingLife);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_m_triggerInterval(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                GhostingEffect gen_to_be_invoked = (GhostingEffect)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushnumber(L, gen_to_be_invoked.m_triggerInterval);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_m_ghostingEffectTime(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                GhostingEffect gen_to_be_invoked = (GhostingEffect)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushnumber(L, gen_to_be_invoked.m_ghostingEffectTime);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_m_ignoreTimeScale(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                GhostingEffect gen_to_be_invoked = (GhostingEffect)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushboolean(L, gen_to_be_invoked.m_ignoreTimeScale);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_m_maxGhosting(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                GhostingEffect gen_to_be_invoked = (GhostingEffect)translator.FastGetCSObj(L, 1);
                LuaAPI.xlua_pushinteger(L, gen_to_be_invoked.m_maxGhosting);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_m_ghostingColor(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                GhostingEffect gen_to_be_invoked = (GhostingEffect)translator.FastGetCSObj(L, 1);
                translator.PushUnityEngineColor(L, gen_to_be_invoked.m_ghostingColor);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_m_mat(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                GhostingEffect gen_to_be_invoked = (GhostingEffect)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.m_mat);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_m_ghostingLife(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                GhostingEffect gen_to_be_invoked = (GhostingEffect)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.m_ghostingLife = (float)LuaAPI.lua_tonumber(L, 2);
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_m_triggerInterval(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                GhostingEffect gen_to_be_invoked = (GhostingEffect)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.m_triggerInterval = (float)LuaAPI.lua_tonumber(L, 2);
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_m_ghostingEffectTime(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                GhostingEffect gen_to_be_invoked = (GhostingEffect)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.m_ghostingEffectTime = (float)LuaAPI.lua_tonumber(L, 2);
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_m_ignoreTimeScale(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                GhostingEffect gen_to_be_invoked = (GhostingEffect)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.m_ignoreTimeScale = LuaAPI.lua_toboolean(L, 2);
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_m_maxGhosting(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                GhostingEffect gen_to_be_invoked = (GhostingEffect)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.m_maxGhosting = LuaAPI.xlua_tointeger(L, 2);
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_m_ghostingColor(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                GhostingEffect gen_to_be_invoked = (GhostingEffect)translator.FastGetCSObj(L, 1);
                UnityEngine.Color gen_value;translator.Get(L, 2, out gen_value);
				gen_to_be_invoked.m_ghostingColor = gen_value;
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_m_mat(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                GhostingEffect gen_to_be_invoked = (GhostingEffect)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.m_mat = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
		
		
		
		
    }
}
