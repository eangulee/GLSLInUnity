Shader "GLSL/GLSL shading in world space" {
	Properties {
		_Point ("a point in world space", Vector) = (0., 0., 0., 1.0)
		_DistanceNear ("threshold distance", Float) = 5.0
		_ColorNear ("color near to point", Color) = (0.0, 1.0, 0.0, 1.0)
		_ColorFar ("color far from point", Color) = (1.0, 0.0, 0.0, 1.0)
	}
	SubShader {
		Pass {
			GLSLPROGRAM
			// uniforms corresponding to properties
			uniform vec4 _Point;
			uniform float _DistanceNear;
			uniform vec4 _ColorNear;
			uniform vec4 _ColorFar;
			#include "UnityCG.glslinc"
			out vec4 position_in_world_space;
			#ifdef VERTEX
			void main()
			{
				position_in_world_space = unity_ObjectToWorld * gl_Vertex;
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
			}
			#endif
			#ifdef FRAGMENT
			void main()
			{
				float dist= distance(position_in_world_space, _Point);
				if (dist < _DistanceNear)
				{
					gl_FragColor = _ColorNear;
				}
				else
				{
					gl_FragColor = _ColorFar;
				}
			}
			#endif
			ENDGLSL
		}
	}
}
