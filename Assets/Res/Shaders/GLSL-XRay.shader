Shader "GLSL/XRay"
{
    Properties
    {
        _MainTex("Base 2D", 2D) = "white" {}
        _XRayColor("XRay Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass // 正常绘制
        {
            Tags{ "RenderType"="Opaque" }
            ZTest LEqual//default
            ZWrite On//default
            GLSLPROGRAM
            //gl_Vertex 顶点
            //gl_MultiTexCoord0 uv
            //gl_Normal 顶点法线
            //gl_Position 裁剪空间坐标输出到片元着色器
            //gl_FragColor 输出颜色
            #include "UnityCG.glslinc"

            uniform vec4 _MainTex_ST;
            struct v2f {
                vec2 textureCoord;
            };

            #ifdef VERTEX
            out v2f v;
            void main()
            {            
                gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
                v.textureCoord = TRANSFORM_TEX_ST(gl_MultiTexCoord0, _MainTex_ST);//处理tiling和offset
            }
            #endif
            #ifdef FRAGMENT
            uniform sampler2D _MainTex;
            in v2f v;
            void main()
            {
                gl_FragColor = texture2D(_MainTex, v.textureCoord);
            }
            #endif
            ENDGLSL  
        }
        Pass // xRay 绘制
        {
            Tags{ "RenderType"="Transparent" "Queue"="Transparent"}
            Blend SrcAlpha One
            ZTest Greater//深度测试，大于当前的通过测试
            ZWrite Off//关闭深度写入
            Cull Back//default
            GLSLPROGRAM
            #include "UnityCG.glslinc"
            #ifdef VERTEX
            uniform vec4 _XRayColor;
            out vec4 xRayColor;            
            void main()
            {            
                gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
                vec3 viewDir = ObjSpaceViewDir(gl_Vertex);//模型空间下的视方向
                vec3 normal = normalize(gl_Normal);
                viewDir = normalize(viewDir);
                float rim = 1.0 - dot(normal, viewDir);//边缘颜色更深，正面颜色更浅
                xRayColor = _XRayColor * rim;
            }
            #endif
            #ifdef FRAGMENT
            in vec4 xRayColor;
            void main()
            {
                gl_FragColor = xRayColor;
            }
            #endif
            ENDGLSL
        }        
    }
}