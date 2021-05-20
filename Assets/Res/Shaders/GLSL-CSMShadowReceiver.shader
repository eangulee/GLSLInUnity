// Upgrade NOTE: replaced '_World2Shadow' with 'unity_WorldToShadow[0]'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

///////////////////////////////////////////
// author     : chen yong
// create time: 2017/7/5
// modify time: 
// description: 
///////////////////////////////////////////

Shader "GLSL/CSMShadowMapping/Receiver" {

	SubShader {
		Tags { "RenderType"="Opaque"  }

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
			#pragma fragmentoption ARB_precision_hint_fastest 

		    uniform mat4 _gWorldToShadow;
			uniform sampler2D _gShadowMapTexture;
			uniform vec4 _gShadowMapTexture_TexelSize;
			/*{TextureName}_TexelSize - a float4 property contains texture size information :
			x contains 1.0 / width
			y contains 1.0 / height
			z contains width
			w contains height*/

			uniform vec4 _gLightSplitsNear;
			uniform vec4 _gLightSplitsFar;
			uniform mat4 _gWorld2Shadow[4];
			
			uniform sampler2D _gShadowMapTexture0;
			uniform sampler2D _gShadowMapTexture1;
			uniform sampler2D _gShadowMapTexture2;
			uniform sampler2D _gShadowMapTexture3;
			uniform float _gShadowStrength;

			struct v2f
			{
				vec2 uv;
				vec4 shadowCoord;
				float eyeZ;
				vec4 worldPos;
			};
			

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

			vec4 getCascadeWeights(float z)
			{
				vec4 zNear = vec4(z >= _gLightSplitsNear.x?1.0:0.0,z >= _gLightSplitsNear.y?1.0:0.0,z >= _gLightSplitsNear.z?1.0:0.0,z >= _gLightSplitsNear.w?1.0:0.0);
				vec4 zFar = vec4(z < _gLightSplitsFar.x?1.0:0.0,z < _gLightSplitsFar.y?1.0:0.0,z < _gLightSplitsFar.z?1.0:0.0,z < _gLightSplitsFar.w?1.0:0.0);
				vec4 weights = zNear * zFar;
				return weights;
			}

			vec4 getShadowCoord(vec4 wpos, vec4 cascadeWeights)
			{
				vec3 sc0 = (_gWorld2Shadow[0] * wpos).xyz;
				vec3 sc1 = (_gWorld2Shadow[1] * wpos).xyz;
				vec3 sc2 = (_gWorld2Shadow[2] * wpos).xyz;
				vec3 sc3 = (_gWorld2Shadow[3] * wpos).xyz;
				return vec4(sc0 * cascadeWeights[0] + sc1 * cascadeWeights[1] + sc2 * cascadeWeights[2] + sc3 * cascadeWeights[3], 1);
			}

			vec4 SampleShadowTexture(vec4 wPos, vec4 cascadeWeights)
			{
				vec4 shadowCoord0 = (_gWorld2Shadow[0] * wPos);
				vec4 shadowCoord1 = (_gWorld2Shadow[1] * wPos);
				vec4 shadowCoord2 = (_gWorld2Shadow[2] * wPos);
				vec4 shadowCoord3 = (_gWorld2Shadow[3] * wPos);

				shadowCoord0.xy /= shadowCoord0.w;
				shadowCoord1.xy /= shadowCoord1.w;
				shadowCoord2.xy /= shadowCoord2.w;
				shadowCoord3.xy /= shadowCoord3.w;

				shadowCoord0.xy = shadowCoord0.xy*0.5 + 0.5;
				shadowCoord1.xy = shadowCoord1.xy*0.5 + 0.5;
				shadowCoord2.xy = shadowCoord2.xy*0.5 + 0.5;
				shadowCoord3.xy = shadowCoord3.xy*0.5 + 0.5;

				vec4 sampleDepth0 = texture(_gShadowMapTexture0, shadowCoord0.xy);
				vec4 sampleDepth1 = texture(_gShadowMapTexture1, shadowCoord1.xy);
				vec4 sampleDepth2 = texture(_gShadowMapTexture2, shadowCoord2.xy);
				vec4 sampleDepth3 = texture(_gShadowMapTexture3, shadowCoord3.xy);

				float depth0 = shadowCoord0.z / shadowCoord0.w;
				float depth1 = shadowCoord1.z / shadowCoord1.w;
				float depth2 = shadowCoord2.z / shadowCoord2.w;
				float depth3 = shadowCoord3.z / shadowCoord3.w;

				#if defined (UNITY_REVERSED_Z)
					depth0 = 1 - depth0;       //(1, 0)-->(0, 1)
					depth1 = 1 - depth1;
					depth2 = 1 - depth2;
					depth3 = 1 - depth3;
				#else
					depth0 = depth0*0.5 + 0.5; //(-1, 1)-->(0, 1)
					depth1 = depth1*0.5 + 0.5;
					depth2 = depth2*0.5 + 0.5;
					depth3 = depth3*0.5 + 0.5;
				#endif

				float shadow0 = sampleDepth0.r < depth0 ? _gShadowStrength : 1.0;
				float shadow1 = sampleDepth1.r < depth1 ? _gShadowStrength : 1.0;
				float shadow2 = sampleDepth2.r < depth2 ? _gShadowStrength : 1.0;
				float shadow3 = sampleDepth3.r < depth3 ? _gShadowStrength : 1.0;

				//return col0;
				float shadow = shadow0 * cascadeWeights[0] + shadow1 * cascadeWeights[1] + shadow2 * cascadeWeights[2] + shadow3 * cascadeWeights[3];
				//return shadow * cascadeWeights;
				return vec4(shadow, shadow, shadow, shadow);
			}

		    #ifdef VERTEX
			out v2f o;
			void main()
	        {            
	            gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
	            o.uv = gl_MultiTexCoord0.xy;
	            o.worldPos = unity_ObjectToWorld * gl_Vertex;
				o.shadowCoord = _gWorldToShadow * o.worldPos;
				o.eyeZ = gl_Position.w;
	        }
	        #endif
	        #ifdef FRAGMENT
	        in v2f o;
			void main()
			{
				vec4 weights = getCascadeWeights(o.eyeZ);
				// sample depth texture
				vec4 col = SampleShadowTexture(o.worldPos, weights);//310以后texture2D过期了，使用texture函数
				gl_FragColor = col;
			}
			#endif
			ENDGLSL
		}
	}
}
