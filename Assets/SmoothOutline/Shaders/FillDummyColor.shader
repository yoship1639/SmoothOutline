Shader "Smooth Outline"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        //【1st pass】Fill with dummy color
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
    }
}