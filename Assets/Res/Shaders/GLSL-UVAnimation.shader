Shader "GLSL/UV Animation" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Image Sequence", 2D) = "white" {}
    	_HorizontalAmount ("Horizontal Amount", Float) = 8
    	_VerticalAmount ("Vertical Amount", Float) = 8
    	_Speed ("Speed", Range(1, 100)) = 30
	}
	SubShader {
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		
		Pass {
			Tags { "LightMode"="ForwardBase" }
			
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			
			GLSLPROGRAM // here begins the part in Unity's GLSL
			#include "UnityCG.glslinc"
			uniform vec4 _MainTex_ST;

			struct v2f {
                vec2 texcoord;
            };

			#ifdef VERTEX // here begins the vertex shader
            out v2f v;
			void main()
            {            
                gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
                v.texcoord = TRANSFORM_TEX_ST(gl_MultiTexCoord0, _MainTex_ST);//处理tiling和offset
            }
			#endif // here ends the definition of the vertex shader
			#ifdef FRAGMENT // here begins the fragment shader
			uniform sampler2D _MainTex;
            in v2f v;
            uniform vec4 _Color;
			uniform float _HorizontalAmount;
			uniform float _VerticalAmount;
			uniform float _Speed;
            void main()
            {
                float time = floor(_Time.y * _Speed);  
				float row = floor(time / _HorizontalAmount);    // /运算获取当前行
				float column = time - row * _HorizontalAmount;  // %运算获取当前列
				
				//首先把原纹理坐标i.uv按行数和列数进行等分，然后使用当前的行列进行偏移
				vec2 uv = v.texcoord + vec2(column, -row);
				uv.x /= _HorizontalAmount;
				uv.y /= _VerticalAmount;
				
				//纹理采样
				vec4 c = texture2D(_MainTex, uv);
				c.rgb *= _Color.rgb;
				
				gl_FragColor = c;
            }
			#endif // here ends the definition of the fragment shader
			ENDGLSL // here ends the part in GLSL
		}
	}
}