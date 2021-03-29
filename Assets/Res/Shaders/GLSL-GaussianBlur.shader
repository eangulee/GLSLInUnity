Shader "GLSL/GaussianBlur"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Blur("Blur",Range(0,1)) = 0.01// 模糊程度
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
            out vec4 texcoord;//uv输入到fs阶段
            void main()
            {
                gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
                texcoord = gl_MultiTexCoord0;//uv
            }
            #endif
            #ifdef FRAGMENT
            // uniforms corresponding to properties
            uniform sampler2D _MainTex;
            uniform float _Blur;
            in vec4 texcoord;//接收fs阶段传入的uv
            void main()
            {
                //高斯模糊
                // 1 / 16
                float offset = _Blur * 0.0625f;
                // 左上
                vec4 textureColor = texture2D(_MainTex, vec2(texcoord.x - offset, texcoord.y - offset)) * 0.0947416f;
                // 上
                textureColor += texture2D(_MainTex, vec2(texcoord.x, texcoord.y - offset)) * 0.118318f;
                // 右上
                textureColor += texture2D(_MainTex, vec2(texcoord.x + offset, texcoord.y + offset)) * 0.0947416f;
                // 左
                textureColor += texture2D(_MainTex, vec2(texcoord.x - offset, texcoord.y)) * 0.118318f;
                // 中
                textureColor += texture2D(_MainTex, vec2(texcoord.x, texcoord.y)) * 0.147761f;
                // 右
                textureColor += texture2D(_MainTex, vec2(texcoord.x + offset, texcoord.y)) * 0.118318f;
                // 左下
                textureColor += texture2D (_MainTex, vec2(texcoord.x - offset, texcoord.y + offset)) * 0.0947416f;
                // 下
                textureColor += texture2D(_MainTex, vec2(texcoord.x, texcoord.y + offset)) * 0.118318f;
                // 右下
                textureColor += texture2D(_MainTex, vec2(texcoord.x + offset, texcoord.y - offset)) * 0.0947416f;

                gl_FragColor = textureColor;
            }
            #endif
            ENDGLSL            
        }
    }
}
