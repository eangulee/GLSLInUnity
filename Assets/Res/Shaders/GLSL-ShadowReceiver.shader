// Upgrade NOTE: replaced '_World2Shadow' with 'unity_WorldToShadow[0]'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

///////////////////////////////////////////
// author     : eangulee
// create time: 2020/12/4
// modify time: 
// description: 
///////////////////////////////////////////

Shader "GLSL/ShadowMapping/Receiver" {
	SubShader{
		Tags { "RenderType" = "Opaque" }
		LOD 300

		Pass {
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardBase" }

			GLSLPROGRAM
			//gl_Vertex 顶点
            //gl_Position 裁剪空间坐标输出到片元着色器
            //gl_FragColor 输出颜色
		    #include "UnityCG.glslinc"
		    #include "lib/Custom.glslinc"

		    uniform mat4 _gWorldToShadow;
			uniform sampler2D _gShadowMapTexture;
			/*{TextureName}_TexelSize - a float4 property contains texture size information :
			x contains 1.0 / width
			y contains 1.0 / height
			z contains width
			w contains height*/
			uniform vec4 _gShadowMapTexture_TexelSize;
			uniform float _gShadowStrength;

			//3x3的PCF Soft Shadow
			float PCFSample(float depth, vec2 uv)
			{
				float shadow = 0.0;
				for (int x = -1; x <= 1; ++x)
				{
					for (int y = -1; y <= 1; ++y)
					{
						vec4 col = texture(_gShadowMapTexture, uv + vec2(x, y) * _gShadowMapTexture_TexelSize.xy);
						float sampleDepth = DecodeFloatRGBA(col);
						shadow += sampleDepth < depth ? _gShadowStrength : 1.0;//接受物体片元的深度与深度图的值比较，大于则表示被挡住灯光，显示为阴影，否则显示自己的颜色（这里显示白色）
					}
				}
				return shadow /= 9.0;
			}

		    #ifdef VERTEX
			out vec4 shadowCoord;
			void main()
	        {            
	            gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
	            vec4 worldPos = unity_ObjectToWorld * gl_Vertex;
				shadowCoord = _gWorldToShadow * worldPos;
	        }
	        #endif
	        #ifdef FRAGMENT
	        in vec4 shadowCoord;
			void main()
			{
				// shadow
				vec2 uv = shadowCoord.xy / shadowCoord.w;
				uv = uv * 0.5 + 0.5; //(-1, 1)-->(0, 1)

				float depth = shadowCoord.z / shadowCoord.w;			
			#if defined (UNITY_REVERSED_Z)
				depth = 1 - depth;       //(1, 0)-->(0, 1)
			#else
				depth = depth * 0.5 + 0.5; //(-1, 1)-->(0, 1)
			#endif
				// PCFSample
				float shadow = PCFSample(depth, uv);
				
				// sample depth texture
				// vec4 col = texture(_gShadowMapTexture, uv);//310以后texture2D过期了，使用texture函数
				// float sampleDepth = DecodeFloatRGBA(col);
				// float shadow = sampleDepth < depth ? _gShadowStrength : 1.0;//接受物体片元的深度与深度图的值比较，大于则表示被挡住灯光，显示为阴影，否则显示自己的颜色（这里显示白色）
				
				gl_FragColor = vec4(shadow, shadow, shadow, shadow);
			}
			#endif
			ENDGLSL
		}
	}
}
