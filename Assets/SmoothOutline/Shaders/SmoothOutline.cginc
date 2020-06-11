#ifndef SMOOTH_OUTLINE
#define SMOOTH_OUTLINE

#define SAMPLE_NUM 6
#define SAMPLE_INV 0.16666666
#define PI2 6.2831852
#define EPSILON 0.001
#define DUMMY_COLOR fixed3(1.0, 0.0, 1.0)

#include "UnityCG.cginc"
#include "AutoLight.cginc"

struct appdata
{
    half4 vertex : POSITION;
    half3 normal : NORMAL;
    half2 uv : TEXCOORD0;
};

struct v2f
{
    half4 pos : SV_POSITION;
    half2 uv : TEXCOORD0;
    half4 grabPos : TEXCOORD1;
    half4 worldPos : TEXCOORD2;
    half3 worldNormal : TEXCOORD3;
    SHADOW_COORDS(4)
    half3 ambient : TEXCOORD5;
};

sampler2D _GrabTexture;
fixed4 _Color;
fixed4 _Emission;
fixed4 _Ambient;
half _Shininess;
half _SpecularIntensity;
sampler2D _MainTex;
half4 _MainTex_ST;
fixed4 _OutlineColor;
half _OutlineWidth;
half4 _LightColor0;

v2f vert(appdata v)
{
    v2f o = (v2f)0;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.grabPos = ComputeGrabScreenPos(o.pos);

#ifdef DISTANCE_WIDTH_ON
    o.worldPos = mul(unity_ObjectToWorld, v.vertex);
#endif

#ifdef DIFFUSE_ON
    o.worldNormal = UnityObjectToWorldNormal(v.normal);

#if UNITY_SHOULD_SAMPLE_SH
    #if defined(VERTEXLIGHT_ON)
        o.ambient = Shade4PointLights(
            unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
            unity_LightColor[0].rgb, unity_LightColor[1].rgb,
            unity_LightColor[2].rgb, unity_LightColor[3].rgb,
            unity_4LightAtten0, o.worldPos, o.worldNormal
        );
    #endif
    o.ambient += max(0, ShadeSH9(float4(o.worldNormal, 1)));
#else
    o.ambient = 0;
#endif

#endif

    TRANSFER_SHADOW(o);

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

    fixed4 col = tex2D(_MainTex, i.uv) * _Color;

#ifdef DIFFUSE_ON
    half3 L;
    half3 N = normalize(i.worldNormal);
    if (_WorldSpaceLightPos0.w > 0) {
        L = _WorldSpaceLightPos0.xyz - i.worldPos.xyz;
    } else {
        L = _WorldSpaceLightPos0.xyz;
    }
    L = normalize(L);

    half3 NL = max(0, dot(N, L));
#ifdef FORWARD_BASE
    UNITY_LIGHT_ATTENUATION(atten, i, 0)
    NL = NL * (1.0 - _Ambient.rgb) + _Ambient.rgb;
    atten = atten * (1.0 - _Ambient.rgb) + _Ambient.rgb;

    half3 V = normalize(_WorldSpaceCameraPos -i.worldPos.xyz);
    half3 specular = pow(max(0.0, dot(reflect(-L, N), V)), _Shininess) * _SpecularIntensity * _LightColor0.rgb;
#else
    UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos.xyz)
    half3 specular = 0;
#endif

    half nl = min(NL, atten);

    col.rgb *= nl * _LightColor0.rgb;
    col.rgb += i.ambient + specular;
#endif

    col.rgb += _Emission.rgb;
    col = lerp(col, _OutlineColor, edge);

    return col;
}

#endif