#include "UnityStandardCoreForwardSimple.cginc"
#include "VertExmotion.cginc"
#include "UnityStandardCore.cginc"

VertexOutputBaseSimple vertForwardBaseSimpleVM(VertexInput v)
{
	// v.vertex = VertExmotion(v.vertex, v.color);
	return vertForwardBaseSimple( v);
}

VertexOutputForwardAddSimple vertForwardAddSimpleVM(VertexInput v)
{
	// v.vertex = VertExmotion(v.vertex, v.color);
	return vertForwardAddSimple( v);
}
