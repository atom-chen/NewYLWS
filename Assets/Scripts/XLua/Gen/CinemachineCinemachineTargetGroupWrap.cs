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
    public class CinemachineCinemachineTargetGroupWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(Cinemachine.CinemachineTargetGroup);
			Utils.BeginObjectRegister(type, L, translator, 0, 5, 6, 4);
			
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetViewSpaceBoundingBox", _m_GetViewSpaceBoundingBox);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "UpdateTransform", _m_UpdateTransform);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "AddTarget", _m_AddTarget);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "RemoveTarget", _m_RemoveTarget);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "RemoveAllTarget", _m_RemoveAllTarget);
			
			
			Utils.RegisterFunc(L, Utils.GETTER_IDX, "BoundingBox", _g_get_BoundingBox);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "IsEmpty", _g_get_IsEmpty);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "m_PositionMode", _g_get_m_PositionMode);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "m_RotationMode", _g_get_m_RotationMode);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "m_UpdateMethod", _g_get_m_UpdateMethod);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "m_Targets", _g_get_m_Targets);
            
			Utils.RegisterFunc(L, Utils.SETTER_IDX, "m_PositionMode", _s_set_m_PositionMode);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "m_RotationMode", _s_set_m_RotationMode);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "m_UpdateMethod", _s_set_m_UpdateMethod);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "m_Targets", _s_set_m_Targets);
            
			
			Utils.EndObjectRegister(type, L, translator, null, null,
			    null, null, null);

		    Utils.BeginClassRegister(type, L, __CreateInstance, 1, 0, 0);
			
			
            
			
			
			
			Utils.EndClassRegister(type, L, translator);
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CreateInstance(RealStatePtr L)
        {
            
			try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
				if(LuaAPI.lua_gettop(L) == 1)
				{
					
					Cinemachine.CinemachineTargetGroup gen_ret = new Cinemachine.CinemachineTargetGroup();
					translator.Push(L, gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to Cinemachine.CinemachineTargetGroup constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetViewSpaceBoundingBox(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Cinemachine.CinemachineTargetGroup gen_to_be_invoked = (Cinemachine.CinemachineTargetGroup)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Matrix4x4 _mView;translator.Get(L, 2, out _mView);
                    
                        UnityEngine.Bounds gen_ret = gen_to_be_invoked.GetViewSpaceBoundingBox( _mView );
                        translator.PushUnityEngineBounds(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_UpdateTransform(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Cinemachine.CinemachineTargetGroup gen_to_be_invoked = (Cinemachine.CinemachineTargetGroup)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    gen_to_be_invoked.UpdateTransform(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_AddTarget(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Cinemachine.CinemachineTargetGroup gen_to_be_invoked = (Cinemachine.CinemachineTargetGroup)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Transform _targetTrans = (UnityEngine.Transform)translator.GetObject(L, 2, typeof(UnityEngine.Transform));
                    float _weight = (float)LuaAPI.lua_tonumber(L, 3);
                    float _radius = (float)LuaAPI.lua_tonumber(L, 4);
                    
                    gen_to_be_invoked.AddTarget( _targetTrans, _weight, _radius );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_RemoveTarget(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Cinemachine.CinemachineTargetGroup gen_to_be_invoked = (Cinemachine.CinemachineTargetGroup)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Transform _targetTrans = (UnityEngine.Transform)translator.GetObject(L, 2, typeof(UnityEngine.Transform));
                    
                    gen_to_be_invoked.RemoveTarget( _targetTrans );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_RemoveAllTarget(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Cinemachine.CinemachineTargetGroup gen_to_be_invoked = (Cinemachine.CinemachineTargetGroup)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    gen_to_be_invoked.RemoveAllTarget(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_BoundingBox(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Cinemachine.CinemachineTargetGroup gen_to_be_invoked = (Cinemachine.CinemachineTargetGroup)translator.FastGetCSObj(L, 1);
                translator.PushUnityEngineBounds(L, gen_to_be_invoked.BoundingBox);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_IsEmpty(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Cinemachine.CinemachineTargetGroup gen_to_be_invoked = (Cinemachine.CinemachineTargetGroup)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushboolean(L, gen_to_be_invoked.IsEmpty);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_m_PositionMode(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Cinemachine.CinemachineTargetGroup gen_to_be_invoked = (Cinemachine.CinemachineTargetGroup)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.m_PositionMode);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_m_RotationMode(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Cinemachine.CinemachineTargetGroup gen_to_be_invoked = (Cinemachine.CinemachineTargetGroup)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.m_RotationMode);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_m_UpdateMethod(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Cinemachine.CinemachineTargetGroup gen_to_be_invoked = (Cinemachine.CinemachineTargetGroup)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.m_UpdateMethod);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_m_Targets(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Cinemachine.CinemachineTargetGroup gen_to_be_invoked = (Cinemachine.CinemachineTargetGroup)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.m_Targets);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_m_PositionMode(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Cinemachine.CinemachineTargetGroup gen_to_be_invoked = (Cinemachine.CinemachineTargetGroup)translator.FastGetCSObj(L, 1);
                Cinemachine.CinemachineTargetGroup.PositionMode gen_value;translator.Get(L, 2, out gen_value);
				gen_to_be_invoked.m_PositionMode = gen_value;
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_m_RotationMode(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Cinemachine.CinemachineTargetGroup gen_to_be_invoked = (Cinemachine.CinemachineTargetGroup)translator.FastGetCSObj(L, 1);
                Cinemachine.CinemachineTargetGroup.RotationMode gen_value;translator.Get(L, 2, out gen_value);
				gen_to_be_invoked.m_RotationMode = gen_value;
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_m_UpdateMethod(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Cinemachine.CinemachineTargetGroup gen_to_be_invoked = (Cinemachine.CinemachineTargetGroup)translator.FastGetCSObj(L, 1);
                Cinemachine.CinemachineTargetGroup.UpdateMethod gen_value;translator.Get(L, 2, out gen_value);
				gen_to_be_invoked.m_UpdateMethod = gen_value;
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_m_Targets(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Cinemachine.CinemachineTargetGroup gen_to_be_invoked = (Cinemachine.CinemachineTargetGroup)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.m_Targets = (Cinemachine.CinemachineTargetGroup.Target[])translator.GetObject(L, 2, typeof(Cinemachine.CinemachineTargetGroup.Target[]));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
		
		
		
		
    }
}
