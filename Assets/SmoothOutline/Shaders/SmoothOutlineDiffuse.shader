Shader "Smooth Outline/Diffuse"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _Emission ("Emission", Color) = (0, 0, 0, 0)
        _Ambient ("Ambient", Color) = (0.5, 0.5, 0.5, 0)
        [Slider(0.1)] _Shininess ("Shininess", Range(0.1, 30.0)) = 8.0
        [Slider(0.01)] _SpecularIntensity ("Specular Intensity", Range(0.0, 1.0)) = 0
        _OutlineColor ("Outline Color", Color) = (0.0, 0.0, 0.0, 1)
        [Slider(0.1)] _OutlineWidth ("Outline Width", Range(0.0, 20.0)) = 3
        [Toggle] Distance_Width ("Distance Outline Width", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        UsePass "Smooth Outline/Unlit/Shadow Caster"
        UsePass "Smooth Outline/Unlit/Fill Dummy Color"

        GrabPass {}

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #pragma shader_feature DISTANCE_WIDTH_ON
            #define DIFFUSE_ON
            #define FORWARD_BASE

            #include "SmoothOutline.cginc"

            ENDCG
        }

        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One
            ZWrite Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd

            #pragma shader_feature DISTANCE_WIDTH_ON
            #define DIFFUSE_ON

            #include "SmoothOutline.cginc"

            ENDCG
        }
    }
    Fallback "Diffuse"
}