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
    public class TMProTMP_TextInfoWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(TMPro.TMP_TextInfo);
			Utils.BeginObjectRegister(type, L, translator, 0, 7, 15, 15);
			
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Clear", _m_Clear);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "ClearMeshInfo", _m_ClearMeshInfo);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "ClearAllMeshInfo", _m_ClearAllMeshInfo);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "ResetVertexLayout", _m_ResetVertexLayout);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "ClearUnusedVertices", _m_ClearUnusedVertices);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "ClearLineInfo", _m_ClearLineInfo);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "CopyMeshInfoVertexData", _m_CopyMeshInfoVertexData);
			
			
			Utils.RegisterFunc(L, Utils.GETTER_IDX, "textComponent", _g_get_textComponent);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "characterCount", _g_get_characterCount);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "spriteCount", _g_get_spriteCount);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "spaceCount", _g_get_spaceCount);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "wordCount", _g_get_wordCount);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "linkCount", _g_get_linkCount);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "lineCount", _g_get_lineCount);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "pageCount", _g_get_pageCount);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "materialCount", _g_get_materialCount);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "characterInfo", _g_get_characterInfo);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "wordInfo", _g_get_wordInfo);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "linkInfo", _g_get_linkInfo);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "lineInfo", _g_get_lineInfo);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "pageInfo", _g_get_pageInfo);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "meshInfo", _g_get_meshInfo);
            
			Utils.RegisterFunc(L, Utils.SETTER_IDX, "textComponent", _s_set_textComponent);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "characterCount", _s_set_characterCount);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "spriteCount", _s_set_spriteCount);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "spaceCount", _s_set_spaceCount);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "wordCount", _s_set_wordCount);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "linkCount", _s_set_linkCount);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "lineCount", _s_set_lineCount);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "pageCount", _s_set_pageCount);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "materialCount", _s_set_materialCount);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "characterInfo", _s_set_characterInfo);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "wordInfo", _s_set_wordInfo);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "linkInfo", _s_set_linkInfo);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "lineInfo", _s_set_lineInfo);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "pageInfo", _s_set_pageInfo);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "meshInfo", _s_set_meshInfo);
            
			
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
					
					TMPro.TMP_TextInfo gen_ret = new TMPro.TMP_TextInfo();
					translator.Push(L, gen_ret);
                    
					return 1;
				}
				if(LuaAPI.lua_gettop(L) == 2 && translator.Assignable<TMPro.TMP_Text>(L, 2))
				{
					TMPro.TMP_Text _textComponent = (TMPro.TMP_Text)translator.GetObject(L, 2, typeof(TMPro.TMP_Text));
					
					TMPro.TMP_TextInfo gen_ret = new TMPro.TMP_TextInfo(_textComponent);
					translator.Push(L, gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to TMPro.TMP_TextInfo constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Clear(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    gen_to_be_invoked.Clear(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ClearMeshInfo(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    bool _updateMesh = LuaAPI.lua_toboolean(L, 2);
                    
                    gen_to_be_invoked.ClearMeshInfo( _updateMesh );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ClearAllMeshInfo(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    gen_to_be_invoked.ClearAllMeshInfo(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ResetVertexLayout(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    bool _isVolumetric = LuaAPI.lua_toboolean(L, 2);
                    
                    gen_to_be_invoked.ResetVertexLayout( _isVolumetric );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ClearUnusedVertices(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    TMPro.MaterialReference[] _materials = (TMPro.MaterialReference[])translator.GetObject(L, 2, typeof(TMPro.MaterialReference[]));
                    
                    gen_to_be_invoked.ClearUnusedVertices( _materials );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ClearLineInfo(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    gen_to_be_invoked.ClearLineInfo(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_CopyMeshInfoVertexData(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                        TMPro.TMP_MeshInfo[] gen_ret = gen_to_be_invoked.CopyMeshInfoVertexData(  );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_textComponent(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.textComponent);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_characterCount(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                LuaAPI.xlua_pushinteger(L, gen_to_be_invoked.characterCount);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_spriteCount(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                LuaAPI.xlua_pushinteger(L, gen_to_be_invoked.spriteCount);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_spaceCount(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                LuaAPI.xlua_pushinteger(L, gen_to_be_invoked.spaceCount);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_wordCount(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                LuaAPI.xlua_pushinteger(L, gen_to_be_invoked.wordCount);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_linkCount(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                LuaAPI.xlua_pushinteger(L, gen_to_be_invoked.linkCount);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_lineCount(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                LuaAPI.xlua_pushinteger(L, gen_to_be_invoked.lineCount);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_pageCount(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                LuaAPI.xlua_pushinteger(L, gen_to_be_invoked.pageCount);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_materialCount(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                LuaAPI.xlua_pushinteger(L, gen_to_be_invoked.materialCount);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_characterInfo(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.characterInfo);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_wordInfo(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.wordInfo);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_linkInfo(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.linkInfo);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_lineInfo(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.lineInfo);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_pageInfo(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.pageInfo);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_meshInfo(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.meshInfo);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_textComponent(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.textComponent = (TMPro.TMP_Text)translator.GetObject(L, 2, typeof(TMPro.TMP_Text));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_characterCount(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.characterCount = LuaAPI.xlua_tointeger(L, 2);
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_spriteCount(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.spriteCount = LuaAPI.xlua_tointeger(L, 2);
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_spaceCount(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.spaceCount = LuaAPI.xlua_tointeger(L, 2);
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_wordCount(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.wordCount = LuaAPI.xlua_tointeger(L, 2);
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_linkCount(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.linkCount = LuaAPI.xlua_tointeger(L, 2);
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_lineCount(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.lineCount = LuaAPI.xlua_tointeger(L, 2);
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_pageCount(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.pageCount = LuaAPI.xlua_tointeger(L, 2);
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_materialCount(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.materialCount = LuaAPI.xlua_tointeger(L, 2);
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_characterInfo(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.characterInfo = (TMPro.TMP_CharacterInfo[])translator.GetObject(L, 2, typeof(TMPro.TMP_CharacterInfo[]));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_wordInfo(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.wordInfo = (TMPro.TMP_WordInfo[])translator.GetObject(L, 2, typeof(TMPro.TMP_WordInfo[]));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_linkInfo(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.linkInfo = (TMPro.TMP_LinkInfo[])translator.GetObject(L, 2, typeof(TMPro.TMP_LinkInfo[]));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_lineInfo(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.lineInfo = (TMPro.TMP_LineInfo[])translator.GetObject(L, 2, typeof(TMPro.TMP_LineInfo[]));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_pageInfo(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.pageInfo = (TMPro.TMP_PageInfo[])translator.GetObject(L, 2, typeof(TMPro.TMP_PageInfo[]));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_meshInfo(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                TMPro.TMP_TextInfo gen_to_be_invoked = (TMPro.TMP_TextInfo)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.meshInfo = (TMPro.TMP_MeshInfo[])translator.GetObject(L, 2, typeof(TMPro.TMP_MeshInfo[]));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
		
		
		
		
    }
}
