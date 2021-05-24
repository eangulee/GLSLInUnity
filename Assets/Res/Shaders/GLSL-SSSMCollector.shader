// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "GLSL/ScreenSpaceShadowMapping/Collector"
{
	Subshader 
	{
		ZTest off 
		Fog { Mode Off }
		Cull back
		Lighting Off
		ZWrite Off
		
		Pass 
		{
			GLSLPROGRAM
			//gl_Vertex 顶点
            //gl_MultiTexCoord0 uv
            //gl_Normal 顶点法线
            //gl_Position 裁剪空间坐标输出到片元着色器
            //gl_FragColor 输出颜色
		    #include "UnityCG.glslinc"
			#pragma fragmentoption ARB_precision_hint_fastest
			
			uniform sampler2D _CameraDepthTex;
			uniform sampler2D _LightDepthTex;

			uniform mat4 _inverseVP;
			uniform mat4 _WorldToShadow;
			
			struct v2f
			{
				vec4 pos;//其实没用到，为了展示如何使用glsl结构体
				vec2 uv;
			};

			#ifdef VERTEX
			out v2f v;
			void main()
	        {            
	            gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
				v.pos = gl_Position;
				v.uv = gl_MultiTexCoord0.xy;
	        }
	        #endif

			#ifdef FRAGMENT
	        in v2f v;
			void main()
			{
				vec4 cameraDepth = texture(_CameraDepthTex, v.uv);
				float depth_ = cameraDepth.r;
#if defined (SHADER_TARGET_GLSL) || defined(SHADER_API_GLES) || defined(SHADER_API_GLES3)
				depth_ = depth_ * 2.0 - 1.0;	 // (0, 1)-->(-1, 1)
#elif defined (UNITY_REVERSED_Z)
				depth_ = 1.0 - depth_;       // (0, 1)-->(1, 0)
#endif

				// reconstruct world position by depth;
				vec4 clipPos;
				clipPos.xy = v.uv * 2.0 - 1.0;
				clipPos.z = depth_;
				clipPos.w = 1.0;

				vec4 posWorld = _inverseVP * clipPos;//裁剪空间转换到世界空间
				posWorld /= posWorld.w;

				vec4 shadowCoord = _WorldToShadow * posWorld;

				vec2 uv = shadowCoord.xy;
				uv = uv*0.5 + 0.5; //(-1, 1)-->(0, 1)

				float depth = shadowCoord.z / shadowCoord.w;
#if defined(SHADER_API_GLES) || defined(SHADER_API_GLES3)
				depth = depth*0.5 + 0.5; //(-1, 1)-->(0, 1)
#elif defined (UNITY_REVERSED_Z)
				depth = 1.0 - depth;       //(1, 0)-->(0, 1)
#endif
				vec4 col = texture(_LightDepthTex, uv);
				float sampleDepth = col.r;

				float shadow = (sampleDepth < depth - 0.05) ? 0.1 : 1.0;
				gl_FragColor = vec4(shadow, shadow, shadow, shadow);
			}
			#endif
			ENDGLSL
		}
	}
	Fallback off
}