Shader "GLSL/ScreenSpaceShadowMapping/Receiver" {

	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base", 2D) = "white" {}
	}

	SubShader {
		Tags { "RenderType"="Opaque" "LIGHTMODE"="ForwardBase" }

		Pass {
			GLSLPROGRAM
			//gl_Vertex 顶点
            //gl_Position 裁剪空间坐标输出到片元着色器
            //gl_FragColor 输出颜色
		    #include "UnityCG.glslinc"
			#pragma fragmentoption ARB_precision_hint_fastest 

			struct v2f {
				vec4 uv;
				vec4 screenPos;	
			};

			uniform vec4 _Color;
			uniform sampler2D _MainTex;
			// vec4 _MainTex_ST;
			uniform sampler2D _ScreenSpceShadowTexture;

			#ifdef VERTEX
			out v2f v;
			void main()
	        {            
	            gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
	            v.uv = gl_MultiTexCoord0;
				v.screenPos = gl_Position;
	        }
	        #endif

			#ifdef FRAGMENT
	        in v2f v;
			void main()
			{
				vec2 screenPos = v.screenPos.xy / v.screenPos.w;
				vec2 sceneUVs = screenPos * 0.5 + 0.5;
//#if UNITY_UV_STARTS_AT_TOP
//				sceneUVs.y = _ProjectionParams.x < 0.0 ? (1.0 - sceneUVs.y) : sceneUVs.y;
//#endif
				float shadow = texture(_ScreenSpceShadowTexture, sceneUVs).r;
				vec4 col = texture(_MainTex, v.uv.xy) * _Color * shadow;
				gl_FragColor = col;
			}
			#endif
			ENDGLSL
		}
	}

	FallBack "Mobile/Diffuse"
}
