Shader "Smooth Outline/Unlit"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _Emission ("Emission", Color) = (0, 0, 0, 0)
        _OutlineColor ("Outline Color", Color) = (0.0, 0.0, 0.0, 1)
        [Slider(0.1)] _OutlineWidth ("Outline Width", Range(0.0, 20.0)) = 3
        [Toggle] Distance_Width ("Distance Outline Width", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Name "Shadow Caster"
            Tags { "LightMode" = "ShadowCaster" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }

        Pass
        {
            Name "Fill Dummy Color"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define DUMMY_COLOR fixed4(1.0, 0.0, 1.0, 0.0)

            struct appdata
            {
                half4 vertex : POSITION;
            };

            struct v2f
            {
                half4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return DUMMY_COLOR;
            }
            ENDCG
        }

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
    Fallback "Unlit/Texture"
}