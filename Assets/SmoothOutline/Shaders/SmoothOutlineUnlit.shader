Shader "Smooth Outline/Unlit"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineColor ("Outline Color", Color) = (0.0, 0.0, 0.0, 1)
        [Slider(0.1)] _OutlineWidth ("Outline Width", Range(0.0, 20.0)) = 3
        [Toggle] Distance_Width ("Distance Outline Width", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        UsePass "Smooth Outline/Fill Dummy Color"

        GrabPass {}

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #pragma shader_feature DISTANCE_WIDTH_ON

            #include "SmoothOutline.cginc"

            ENDCG
        }
    }
}