Shader "GLSL/BlinnPhone"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SpecularTex("_SpecularTex", 2D) = "white" {}//控制哪一部分会有高光：脸蛋，布料上千万别有高光，金属，陶瓷，皮具，甲克可以有高光。
        _SpecularGloss("_SpecularGloss", range(0.001, 100)) = 30//光斑大小，和本值成反比
        [Toggle] _IsBlinn("_IsBlinn", int) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}

        Pass
        {
            GLSLPROGRAM
            //gl_Vertex 顶点
            //gl_MultiTexCoord0 uv
            //gl_Normal 顶点法线
            //gl_Position 裁剪空间坐标输出到片元着色器
            //gl_FragColor 输出颜色
            #include "UnityCG.glslinc"
            //获取灯光颜色需要申明，unity会自动赋值
            uniform vec4 _LightColor0;// color of light source (from "Lighting.cginc")

            uniform vec4 _MainTex_ST;
            #ifdef VERTEX
            out vec2 textureCoord;//uv输入到fs阶段
            out vec3 worldNormal;//世界空间下的法线
            out vec3 vertexWorldPos;//世界空间下的顶点坐标
            void main()
            {
                worldNormal = gl_NormalMatrix * vec3(gl_Normal);
                vertexWorldPos = vec3(unity_ObjectToWorld * gl_Vertex);
                gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
                textureCoord = TRANSFORM_TEX_ST(gl_MultiTexCoord0, _MainTex_ST);//处理tiling和offset
            }
            #endif
            #ifdef FRAGMENT
            // uniforms corresponding to properties
            uniform sampler2D _MainTex;
            uniform sampler2D _SpecularTex;
            uniform float _SpecularGloss;
            uniform int _IsBlinn;
            in vec2 textureCoord;//接收fs阶段传入的uv
            in vec3 worldNormal;
            in vec3 vertexWorldPos;
            void main()
            {
                // sample the texture
                vec4 color = texture2D(_MainTex, textureCoord);

                vec3 normal = normalize(worldNormal);
                vec3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                vec3 viewDir = normalize(vertexWorldPos.xyz -_WorldSpaceCameraPos.xyz);

                vec3 useDir = vec3(0, 0, 0);
                if (_IsBlinn > 0)//实际代码中不要这么写
                {
                    //Blinn-Phong光照模型
                    vec3 halfDir = normalize(worldLight + viewDir);//半角向量
                    useDir = halfDir;
                }
                else
                {
                    //Phong光照模型
                    vec3 reflectDir = normalize(reflect(-worldLight, normal));//reflect函数求反射角方向
                    useDir = reflectDir;
                }
                //漫反射
                vec3 diffuse = color.rgb * _LightColor0.rgb * max(0.0, dot(normal, worldLight));

                //高光
                vec3 specular = _LightColor0.rgb * pow(saturate(dot(normal, useDir)), _SpecularGloss) * texture2D(_SpecularTex, textureCoord).r;

                gl_FragColor = vec4(diffuse + specular,color.a);
            }
            #endif
            ENDGLSL  
        }
    }
}
