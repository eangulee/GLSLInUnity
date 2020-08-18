Shader "GLSL/GLSL RGB Cube"
{
    SubShader
    {
        Pass
        {
            GLSLPROGRAM
            #ifdef VERTEX // here begins the vertex shader
            //varying变量是vertex和fragment shader之间做数据传递用的
            varying vec4 color;
            // this is a varying variable in the vertex shader
            void main()
            {
                //cube是以1为边长的正方体，所以顶点的xyz取值范围为[-0.5,0.5]，
                //分别加上0.5,将取值范围转换到[0,1]，正好是颜色RGB每个通道的取值范围
                color = gl_Vertex + vec4(0.5, 0.5, 0.5, 0.0);
                gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
            }
            #endif // here ends the vertex shader

            #ifdef FRAGMENT // here begins the fragment shader
            varying vec4 color;
            // this is a varying variable in the fragment shader
            void main()
            {
                //使用cube对象空间的顶点坐标的xyz值作为rgb输出
                gl_FragColor = color;
            }
            #endif // here ends the fragment shader
            ENDGLSL
        }
    }
}
