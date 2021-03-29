Shader "GLSL/SinWave"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _MaskColor ("Mask Color", Color) = (0.5,0.5,0.5,0.5)
    }
    SubShader
    {
        Tags { "RenderType"="Transprent" "Queue"="Transparent"}
        
        Cull Off
        Lighting Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            GLSLPROGRAM
            #include "UnityCG.glslinc"
            
            #ifdef VERTEX
            out vec4 textureCoordinates;//uv输入到fs阶段
            void main()
            {
                gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
                textureCoordinates = gl_MultiTexCoord0;//uv
            }
            #endif
            #ifdef FRAGMENT
            // uniforms corresponding to properties
            uniform sampler2D _MainTex;
            uniform vec4 _Color;// shader property specified by users
            uniform vec4 _MaskColor;// shader property specified by users
            uniform float _Offset;            
            in vec4 textureCoordinates;//接收fs阶段传入的uv
            void main()
            {
                // sample the texture
                vec4 textureColor = texture2D(_MainTex, vec2(textureCoordinates));

                // 振幅（控制波浪顶端和底端的高度）
                float amplitude = 0.05;
                
                // 角速度（控制波浪的周期）
                float angularVelocity = 10.0;
                
                // 频率（控制波浪移动的速度）
                float frequency = 10.0;
                
                // 偏距（设为 0.5 使得波浪垂直居中于屏幕）
                float offset = _Offset;
                
                // 初相位（正值表现为向左移动，负值则表现为向右移动）
                float initialPhase = frequency * _Time.y;
                
                // 代入正弦曲线公式计算 y 值
                // y = Asin(ωx ± φt) + k
                float y = amplitude * sin((angularVelocity * textureCoordinates.x) + initialPhase) + offset;

                 // 大于y的叠加mask color
                if (textureCoordinates.y > y) {
                    textureColor *= _MaskColor;
                }

                gl_FragColor = textureColor;
            }
            #endif
            ENDGLSL            
        }
    }
}
