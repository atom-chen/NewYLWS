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
    public class DOTweenDOTweenExtensionsWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(DOTween.DOTweenExtensions);
			Utils.BeginObjectRegister(type, L, translator, 0, 0, 0, 0);
			
			
			
			
			
			
			Utils.EndObjectRegister(type, L, translator, null, null,
			    null, null, null);

		    Utils.BeginClassRegister(type, L, __CreateInstance, 36, 0, 0);
			Utils.RegisterFunc(L, Utils.CLS_IDX, "Complete", _m_Complete_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "CompletedLoops", _m_CompletedLoops_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "Delay", _m_Delay_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "Duration", _m_Duration_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "Elapsed", _m_Elapsed_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ElapsedDirectionalPercentage", _m_ElapsedDirectionalPercentage_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ElapsedPercentage", _m_ElapsedPercentage_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "Flip", _m_Flip_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ForceInit", _m_ForceInit_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "Goto", _m_Goto_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "GotoWaypoint", _m_GotoWaypoint_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "IsActive", _m_IsActive_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "IsBackwards", _m_IsBackwards_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "IsComplete", _m_IsComplete_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "IsInitialized", _m_IsInitialized_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "IsPlaying", _m_IsPlaying_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "Kill", _m_Kill_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "Loops", _m_Loops_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "PathGetDrawPoints", _m_PathGetDrawPoints_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "PathGetPoint", _m_PathGetPoint_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "PathLength", _m_PathLength_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "Pause", _m_Pause_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "Play", _m_Play_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "PlayBackwards", _m_PlayBackwards_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "PlayForward", _m_PlayForward_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "Restart", _m_Restart_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "Rewind", _m_Rewind_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SmoothRewind", _m_SmoothRewind_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "TogglePause", _m_TogglePause_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "WaitForCompletion", _m_WaitForCompletion_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "WaitForElapsedLoops", _m_WaitForElapsedLoops_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "WaitForKill", _m_WaitForKill_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "WaitForPosition", _m_WaitForPosition_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "WaitForRewind", _m_WaitForRewind_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "WaitForStart", _m_WaitForStart_xlua_st_);
            
			
            
			
			
			
			Utils.EndClassRegister(type, L, translator);
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CreateInstance(RealStatePtr L)
        {
            
			try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
				if(LuaAPI.lua_gettop(L) == 1)
				{
					
					DOTween.DOTweenExtensions gen_ret = new DOTween.DOTweenExtensions();
					translator.Push(L, gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenExtensions constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Complete_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 1&& translator.Assignable<DG.Tweening.Tween>(L, 1)) 
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                    DOTween.DOTweenExtensions.Complete( _t );
                    
                    
                    
                    return 0;
                }
                if(gen_param_count == 2&& translator.Assignable<DG.Tweening.Tween>(L, 1)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 2)) 
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    bool _withCallbacks = LuaAPI.lua_toboolean(L, 2);
                    
                    DOTween.DOTweenExtensions.Complete( _t, _withCallbacks );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenExtensions.Complete!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_CompletedLoops_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                        int gen_ret = DOTween.DOTweenExtensions.CompletedLoops( _t );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Delay_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                        float gen_ret = DOTween.DOTweenExtensions.Delay( _t );
                        LuaAPI.lua_pushnumber(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Duration_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 2&& translator.Assignable<DG.Tweening.Tween>(L, 1)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 2)) 
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    bool _includeLoops = LuaAPI.lua_toboolean(L, 2);
                    
                        float gen_ret = DOTween.DOTweenExtensions.Duration( _t, _includeLoops );
                        LuaAPI.lua_pushnumber(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 1&& translator.Assignable<DG.Tweening.Tween>(L, 1)) 
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                        float gen_ret = DOTween.DOTweenExtensions.Duration( _t );
                        LuaAPI.lua_pushnumber(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenExtensions.Duration!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Elapsed_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 2&& translator.Assignable<DG.Tweening.Tween>(L, 1)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 2)) 
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    bool _includeLoops = LuaAPI.lua_toboolean(L, 2);
                    
                        float gen_ret = DOTween.DOTweenExtensions.Elapsed( _t, _includeLoops );
                        LuaAPI.lua_pushnumber(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 1&& translator.Assignable<DG.Tweening.Tween>(L, 1)) 
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                        float gen_ret = DOTween.DOTweenExtensions.Elapsed( _t );
                        LuaAPI.lua_pushnumber(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenExtensions.Elapsed!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ElapsedDirectionalPercentage_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                        float gen_ret = DOTween.DOTweenExtensions.ElapsedDirectionalPercentage( _t );
                        LuaAPI.lua_pushnumber(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ElapsedPercentage_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 2&& translator.Assignable<DG.Tweening.Tween>(L, 1)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 2)) 
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    bool _includeLoops = LuaAPI.lua_toboolean(L, 2);
                    
                        float gen_ret = DOTween.DOTweenExtensions.ElapsedPercentage( _t, _includeLoops );
                        LuaAPI.lua_pushnumber(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 1&& translator.Assignable<DG.Tweening.Tween>(L, 1)) 
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                        float gen_ret = DOTween.DOTweenExtensions.ElapsedPercentage( _t );
                        LuaAPI.lua_pushnumber(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenExtensions.ElapsedPercentage!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Flip_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                    DOTween.DOTweenExtensions.Flip( _t );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ForceInit_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                    DOTween.DOTweenExtensions.ForceInit( _t );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Goto_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 3&& translator.Assignable<DG.Tweening.Tween>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 3)) 
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    float _to = (float)LuaAPI.lua_tonumber(L, 2);
                    bool _andPlay = LuaAPI.lua_toboolean(L, 3);
                    
                    DOTween.DOTweenExtensions.Goto( _t, _to, _andPlay );
                    
                    
                    
                    return 0;
                }
                if(gen_param_count == 2&& translator.Assignable<DG.Tweening.Tween>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    float _to = (float)LuaAPI.lua_tonumber(L, 2);
                    
                    DOTween.DOTweenExtensions.Goto( _t, _to );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenExtensions.Goto!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GotoWaypoint_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 3&& translator.Assignable<DG.Tweening.Tween>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 3)) 
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    int _waypointIndex = LuaAPI.xlua_tointeger(L, 2);
                    bool _andPlay = LuaAPI.lua_toboolean(L, 3);
                    
                    DOTween.DOTweenExtensions.GotoWaypoint( _t, _waypointIndex, _andPlay );
                    
                    
                    
                    return 0;
                }
                if(gen_param_count == 2&& translator.Assignable<DG.Tweening.Tween>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    int _waypointIndex = LuaAPI.xlua_tointeger(L, 2);
                    
                    DOTween.DOTweenExtensions.GotoWaypoint( _t, _waypointIndex );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenExtensions.GotoWaypoint!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_IsActive_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                        bool gen_ret = DOTween.DOTweenExtensions.IsActive( _t );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_IsBackwards_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                        bool gen_ret = DOTween.DOTweenExtensions.IsBackwards( _t );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_IsComplete_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                        bool gen_ret = DOTween.DOTweenExtensions.IsComplete( _t );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_IsInitialized_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                        bool gen_ret = DOTween.DOTweenExtensions.IsInitialized( _t );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_IsPlaying_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                        bool gen_ret = DOTween.DOTweenExtensions.IsPlaying( _t );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Kill_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 2&& translator.Assignable<DG.Tweening.Tween>(L, 1)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 2)) 
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    bool _complete = LuaAPI.lua_toboolean(L, 2);
                    
                    DOTween.DOTweenExtensions.Kill( _t, _complete );
                    
                    
                    
                    return 0;
                }
                if(gen_param_count == 1&& translator.Assignable<DG.Tweening.Tween>(L, 1)) 
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                    DOTween.DOTweenExtensions.Kill( _t );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenExtensions.Kill!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Loops_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                        int gen_ret = DOTween.DOTweenExtensions.Loops( _t );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_PathGetDrawPoints_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 2&& translator.Assignable<DG.Tweening.Tween>(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    int _subdivisionsXSegment = LuaAPI.xlua_tointeger(L, 2);
                    
                        UnityEngine.Vector3[] gen_ret = DOTween.DOTweenExtensions.PathGetDrawPoints( _t, _subdivisionsXSegment );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                if(gen_param_count == 1&& translator.Assignable<DG.Tweening.Tween>(L, 1)) 
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                        UnityEngine.Vector3[] gen_ret = DOTween.DOTweenExtensions.PathGetDrawPoints( _t );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenExtensions.PathGetDrawPoints!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_PathGetPoint_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    float _pathPercentage = (float)LuaAPI.lua_tonumber(L, 2);
                    
                        UnityEngine.Vector3 gen_ret = DOTween.DOTweenExtensions.PathGetPoint( _t, _pathPercentage );
                        translator.PushUnityEngineVector3(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_PathLength_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                        float gen_ret = DOTween.DOTweenExtensions.PathLength( _t );
                        LuaAPI.lua_pushnumber(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Pause_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                        DG.Tweening.Tween gen_ret = DOTween.DOTweenExtensions.Pause( _t );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Play_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                        DG.Tweening.Tween gen_ret = DOTween.DOTweenExtensions.Play( _t );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_PlayBackwards_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                    DOTween.DOTweenExtensions.PlayBackwards( _t );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_PlayForward_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                    DOTween.DOTweenExtensions.PlayForward( _t );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Restart_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 3&& translator.Assignable<DG.Tweening.Tween>(L, 1)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    bool _includeDelay = LuaAPI.lua_toboolean(L, 2);
                    float _changeDelayTo = (float)LuaAPI.lua_tonumber(L, 3);
                    
                    DOTween.DOTweenExtensions.Restart( _t, _includeDelay, _changeDelayTo );
                    
                    
                    
                    return 0;
                }
                if(gen_param_count == 2&& translator.Assignable<DG.Tweening.Tween>(L, 1)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 2)) 
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    bool _includeDelay = LuaAPI.lua_toboolean(L, 2);
                    
                    DOTween.DOTweenExtensions.Restart( _t, _includeDelay );
                    
                    
                    
                    return 0;
                }
                if(gen_param_count == 1&& translator.Assignable<DG.Tweening.Tween>(L, 1)) 
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                    DOTween.DOTweenExtensions.Restart( _t );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenExtensions.Restart!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Rewind_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 2&& translator.Assignable<DG.Tweening.Tween>(L, 1)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 2)) 
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    bool _includeDelay = LuaAPI.lua_toboolean(L, 2);
                    
                    DOTween.DOTweenExtensions.Rewind( _t, _includeDelay );
                    
                    
                    
                    return 0;
                }
                if(gen_param_count == 1&& translator.Assignable<DG.Tweening.Tween>(L, 1)) 
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                    DOTween.DOTweenExtensions.Rewind( _t );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to DOTween.DOTweenExtensions.Rewind!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SmoothRewind_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                    DOTween.DOTweenExtensions.SmoothRewind( _t );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_TogglePause_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                    DOTween.DOTweenExtensions.TogglePause( _t );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_WaitForCompletion_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                        UnityEngine.YieldInstruction gen_ret = DOTween.DOTweenExtensions.WaitForCompletion( _t );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_WaitForElapsedLoops_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    int _elapsedLoops = LuaAPI.xlua_tointeger(L, 2);
                    
                        UnityEngine.YieldInstruction gen_ret = DOTween.DOTweenExtensions.WaitForElapsedLoops( _t, _elapsedLoops );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_WaitForKill_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                        UnityEngine.YieldInstruction gen_ret = DOTween.DOTweenExtensions.WaitForKill( _t );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_WaitForPosition_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    float _position = (float)LuaAPI.lua_tonumber(L, 2);
                    
                        UnityEngine.YieldInstruction gen_ret = DOTween.DOTweenExtensions.WaitForPosition( _t, _position );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_WaitForRewind_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                        UnityEngine.YieldInstruction gen_ret = DOTween.DOTweenExtensions.WaitForRewind( _t );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_WaitForStart_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    DG.Tweening.Tween _t = (DG.Tweening.Tween)translator.GetObject(L, 1, typeof(DG.Tweening.Tween));
                    
                        UnityEngine.Coroutine gen_ret = DOTween.DOTweenExtensions.WaitForStart( _t );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        
        
        
        
        
		
		
		
		
    }
}
