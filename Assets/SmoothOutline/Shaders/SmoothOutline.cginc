#ifndef SMOOTH_OUTLINE
#define SMOOTH_OUTLINE

#define SAMPLE_NUM 6
#define SAMPLE_INV 0.16666666
#define PI2 6.2831852
#define EPSILON 0.001
#define DUMMY_COLOR fixed3(1.0, 0.0, 1.0)

#include "UnityCG.cginc"

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
};

struct v2f
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float4 grabPos : TEXCOORD1;
#ifdef DISTANCE_WIDTH_ON
    float4 worldPos : TEXCOORD2;
#endif
};

sampler2D _GrabTexture;
fixed4 _Color;
sampler2D _MainTex;
half4 _MainTex_ST;
fixed4 _OutlineColor;
half _OutlineWidth;

v2f vert(appdata v)
{
    v2f o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.grabPos = ComputeGrabScreenPos(o.pos);

#ifdef DISTANCE_WIDTH_ON
    o.worldPos = mul(unity_ObjectToWorld, v.vertex);
#endif

    return o;
}

fixed4 frag(v2f i) : SV_Target
{
#ifndef DISTANCE_WIDTH_ON
    half outlineWidth = _OutlineWidth;
#else
    half outlineWidth = min(_OutlineWidth / distance(_WorldSpaceCameraPos.xyz, i.worldPos.xyz), _OutlineWidth);
#endif
    half2 delta = (1 / _ScreenParams.xy) * outlineWidth;

    int edge = 0;
    [unroll]
    for (int j = 0; j < SAMPLE_NUM && edge == 0; j++)
    {
        fixed4 tex = tex2D(_GrabTexture, i.grabPos.xy / i.grabPos.w + half2(sin(SAMPLE_INV * j * PI2) * delta.x, cos(SAMPLE_INV * j * PI2) * delta.y));
        edge += distance(tex.rgb, DUMMY_COLOR) < EPSILON ? 0 : 1;
    }

    fixed4 col = lerp(tex2D(_MainTex, i.uv) * _Color, _OutlineColor, edge);
    return col;
}

#endif