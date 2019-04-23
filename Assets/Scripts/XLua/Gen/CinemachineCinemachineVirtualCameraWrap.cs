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
    public class CinemachineCinemachineVirtualCameraWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(Cinemachine.CinemachineVirtualCamera);
			Utils.BeginObjectRegister(type, L, translator, 0, 7, 7, 6);
			
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "UpdateCameraState", _m_UpdateCameraState);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "InvalidateComponentPipeline", _m_InvalidateComponentPipeline);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetComponentOwner", _m_GetComponentOwner);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetComponentPipeline", _m_GetComponentPipeline);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetCinemachineComponent", _m_GetCinemachineComponent);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "ModifyCameraDistance", _m_ModifyCameraDistance);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "OnPositionDragged", _m_OnPositionDragged);
			
			
			Utils.RegisterFunc(L, Utils.GETTER_IDX, "State", _g_get_State);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "LookAt", _g_get_LookAt);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "Follow", _g_get_Follow);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "UserIsDragging", _g_get_UserIsDragging);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "m_LookAt", _g_get_m_LookAt);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "m_Follow", _g_get_m_Follow);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "m_Lens", _g_get_m_Lens);
            
			Utils.RegisterFunc(L, Utils.SETTER_IDX, "LookAt", _s_set_LookAt);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "Follow", _s_set_Follow);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "UserIsDragging", _s_set_UserIsDragging);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "m_LookAt", _s_set_m_LookAt);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "m_Follow", _s_set_m_Follow);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "m_Lens", _s_set_m_Lens);
            
			
			Utils.EndObjectRegister(type, L, translator, null, null,
			    null, null, null);

		    Utils.BeginClassRegister(type, L, __CreateInstance, 2, 2, 2);
			
			
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "PipelineName", Cinemachine.CinemachineVirtualCamera.PipelineName);
            
			Utils.RegisterFunc(L, Utils.CLS_GETTER_IDX, "CreatePipelineOverride", _g_get_CreatePipelineOverride);
            Utils.RegisterFunc(L, Utils.CLS_GETTER_IDX, "DestroyPipelineOverride", _g_get_DestroyPipelineOverride);
            
			Utils.RegisterFunc(L, Utils.CLS_SETTER_IDX, "CreatePipelineOverride", _s_set_CreatePipelineOverride);
            Utils.RegisterFunc(L, Utils.CLS_SETTER_IDX, "DestroyPipelineOverride", _s_set_DestroyPipelineOverride);
            
			
			Utils.EndClassRegister(type, L, translator);
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CreateInstance(RealStatePtr L)
        {
            
			try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
				if(LuaAPI.lua_gettop(L) == 1)
				{
					
					Cinemachine.CinemachineVirtualCamera gen_ret = new Cinemachine.CinemachineVirtualCamera();
					translator.Push(L, gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to Cinemachine.CinemachineVirtualCamera constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_UpdateCameraState(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Cinemachine.CinemachineVirtualCamera gen_to_be_invoked = (Cinemachine.CinemachineVirtualCamera)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Vector3 _worldUp;translator.Get(L, 2, out _worldUp);
                    float _deltaTime = (float)LuaAPI.lua_tonumber(L, 3);
                    
                    gen_to_be_invoked.UpdateCameraState( _worldUp, _deltaTime );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_InvalidateComponentPipeline(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Cinemachine.CinemachineVirtualCamera gen_to_be_invoked = (Cinemachine.CinemachineVirtualCamera)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    gen_to_be_invoked.InvalidateComponentPipeline(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetComponentOwner(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Cinemachine.CinemachineVirtualCamera gen_to_be_invoked = (Cinemachine.CinemachineVirtualCamera)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                        UnityEngine.Transform gen_ret = gen_to_be_invoked.GetComponentOwner(  );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetComponentPipeline(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Cinemachine.CinemachineVirtualCamera gen_to_be_invoked = (Cinemachine.CinemachineVirtualCamera)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                        Cinemachine.CinemachineComponentBase[] gen_ret = gen_to_be_invoked.GetComponentPipeline(  );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetCinemachineComponent(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Cinemachine.CinemachineVirtualCamera gen_to_be_invoked = (Cinemachine.CinemachineVirtualCamera)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    Cinemachine.CinemachineCore.Stage _stage;translator.Get(L, 2, out _stage);
                    
                        Cinemachine.CinemachineComponentBase gen_ret = gen_to_be_invoked.GetCinemachineComponent( _stage );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ModifyCameraDistance(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Cinemachine.CinemachineVirtualCamera gen_to_be_invoked = (Cinemachine.CinemachineVirtualCamera)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    float _deltaDistance = (float)LuaAPI.lua_tonumber(L, 2);
                    
                    gen_to_be_invoked.ModifyCameraDistance( _deltaDistance );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_OnPositionDragged(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Cinemachine.CinemachineVirtualCamera gen_to_be_invoked = (Cinemachine.CinemachineVirtualCamera)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Vector3 _delta;translator.Get(L, 2, out _delta);
                    
                    gen_to_be_invoked.OnPositionDragged( _delta );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_State(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Cinemachine.CinemachineVirtualCamera gen_to_be_invoked = (Cinemachine.CinemachineVirtualCamera)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.State);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_LookAt(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Cinemachine.CinemachineVirtualCamera gen_to_be_invoked = (Cinemachine.CinemachineVirtualCamera)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.LookAt);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_Follow(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Cinemachine.CinemachineVirtualCamera gen_to_be_invoked = (Cinemachine.CinemachineVirtualCamera)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.Follow);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_UserIsDragging(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Cinemachine.CinemachineVirtualCamera gen_to_be_invoked = (Cinemachine.CinemachineVirtualCamera)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushboolean(L, gen_to_be_invoked.UserIsDragging);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_m_LookAt(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Cinemachine.CinemachineVirtualCamera gen_to_be_invoked = (Cinemachine.CinemachineVirtualCamera)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.m_LookAt);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_m_Follow(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Cinemachine.CinemachineVirtualCamera gen_to_be_invoked = (Cinemachine.CinemachineVirtualCamera)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.m_Follow);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_m_Lens(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Cinemachine.CinemachineVirtualCamera gen_to_be_invoked = (Cinemachine.CinemachineVirtualCamera)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.m_Lens);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_CreatePipelineOverride(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			    translator.Push(L, Cinemachine.CinemachineVirtualCamera.CreatePipelineOverride);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_DestroyPipelineOverride(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			    translator.Push(L, Cinemachine.CinemachineVirtualCamera.DestroyPipelineOverride);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_LookAt(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Cinemachine.CinemachineVirtualCamera gen_to_be_invoked = (Cinemachine.CinemachineVirtualCamera)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.LookAt = (UnityEngine.Transform)translator.GetObject(L, 2, typeof(UnityEngine.Transform));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_Follow(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Cinemachine.CinemachineVirtualCamera gen_to_be_invoked = (Cinemachine.CinemachineVirtualCamera)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.Follow = (UnityEngine.Transform)translator.GetObject(L, 2, typeof(UnityEngine.Transform));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_UserIsDragging(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Cinemachine.CinemachineVirtualCamera gen_to_be_invoked = (Cinemachine.CinemachineVirtualCamera)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.UserIsDragging = LuaAPI.lua_toboolean(L, 2);
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_m_LookAt(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Cinemachine.CinemachineVirtualCamera gen_to_be_invoked = (Cinemachine.CinemachineVirtualCamera)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.m_LookAt = (UnityEngine.Transform)translator.GetObject(L, 2, typeof(UnityEngine.Transform));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_m_Follow(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Cinemachine.CinemachineVirtualCamera gen_to_be_invoked = (Cinemachine.CinemachineVirtualCamera)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.m_Follow = (UnityEngine.Transform)translator.GetObject(L, 2, typeof(UnityEngine.Transform));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_m_Lens(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Cinemachine.CinemachineVirtualCamera gen_to_be_invoked = (Cinemachine.CinemachineVirtualCamera)translator.FastGetCSObj(L, 1);
                Cinemachine.LensSettings gen_value;translator.Get(L, 2, out gen_value);
				gen_to_be_invoked.m_Lens = gen_value;
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_CreatePipelineOverride(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			    Cinemachine.CinemachineVirtualCamera.CreatePipelineOverride = translator.GetDelegate<Cinemachine.CinemachineVirtualCamera.CreatePipelineDelegate>(L, 1);
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_DestroyPipelineOverride(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			    Cinemachine.CinemachineVirtualCamera.DestroyPipelineOverride = translator.GetDelegate<Cinemachine.CinemachineVirtualCamera.DestroyPipelineDelegate>(L, 1);
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
		
		
		
		
    }
}
