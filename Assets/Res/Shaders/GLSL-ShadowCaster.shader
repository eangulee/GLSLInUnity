// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

///////////////////////////////////////////
// author     : eangulee
// create time: 2020/12/4
// modify time: 
// description: Generate a depth texture from the projector
///////////////////////////////////////////

Shader "GLSL/ShadowMapping/Caster" 
{
	SubShader {
		Tags { 			
		    "RenderType" = "Opaque"
		}
		Pass {
			Fog { Mode Off }
			Cull front//设置Cull front可解决面向光源的acne问题
			GLSLPROGRAM
			//gl_Vertex 顶点
            //gl_Position 裁剪空间坐标输出到片元着色器
            //gl_FragColor 输出颜色
		    #include "UnityCG.glslinc"
		    #include "lib/Custom.glslinc"
		    
			uniform float _gShadowBias;

		    struct v2f {
				vec4 pos;//其实没用到，为了展示如何使用glsl结构体
				vec2 depth;
			};

			#ifdef VERTEX
			out v2f v;
			void main()
	        {            
	            gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
	            gl_Position.z += _gShadowBias;
	          	v.depth = gl_Position.zw;
	        }
	        #endif
	        #ifdef FRAGMENT
	        in v2f v;
			void main()
			{
				float depth = v.depth.x / v.depth.y;

			#if defined (SHADER_TARGET_GLSL) 
				depth = depth* 0.5 + 0.5; //(-1, 1)-->(0, 1)
			#elif defined (UNITY_REVERSED_Z) //如果是使用的reverzed-z，需要处理一下
				depth = 1.0 - depth;       //(1, 0)-->(0, 1)
			#endif

				gl_FragColor = EncodeFloatRGBA(depth);
			}
			#endif
			ENDGLSL  
		}
	}
}
