Shader "LowPoly/Water"
{
    Properties
    {
        _Color ("Color", Color) = (0,0,0,1)
        _SpecularColor ("Specular Color", Color) = (0,0,0,1)
        _Gloss ("Gloss",Range(0.5,20.0)) = 1.0

        _WaveHight1 ("Wave Hight 1",Float) = 1.0
        _WaveScale1 ("Wave Scale 1",Float) = 1.0
        _WaveSpeed1 ("Wave Speed 1",Float) = 1.0
        _WaveDir1("Wave Direction 1",Float) = 0

        _WaveHight2 ("Wave Hight 2",Float) = 1.0
        _WaveScale2 ("Wave Scale 2",Float) = 1.0
        _WaveSpeed2 ("Wave Speed 2",Float) = 1.0
        _WaveDir2("Wave Direction 2",Float) = 0

        _WaveHight3 ("Wave Hight 3",Float) = 1.0
        _WaveScale3 ("Wave Scale 3",Float) = 1.0
        _WaveSpeed3 ("Wave Speed 3",Float) = 1.0
        _WaveDir3("Wave Direction 3",Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc" 

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD2;
            };

            float4 _Color;
            float4 _SpecularColor;
            float _Gloss;

            float _WaveHight1;
            float _WaveScale1;
            float _WaveSpeed1;
            float _WaveDir1;

            float _WaveHight2;
            float _WaveScale2;
            float _WaveSpeed2;
            float _WaveDir2;

            float _WaveHight3;
            float _WaveScale3;
            float _WaveSpeed3;
            float _WaveDir3;

            v2f vert (appdata v)
            {
                v2f o;

                float4 pos = v.vertex;

                float2 uv = v.uv.xy - float2(0.5, 0.5);
                float2 uv1 = float2(uv.x *cos(_WaveDir1) - uv.y * sin(_WaveDir1),uv.x *sin(_WaveDir1) + uv.y*cos(_WaveDir1));
                float2 uv2 = float2(uv.x *cos(_WaveDir2) - uv.y * sin(_WaveDir2),uv.x *sin(_WaveDir2) + uv.y*cos(_WaveDir2));
                float2 uv3 = float2(uv.x *cos(_WaveDir3) - uv.y * sin(_WaveDir3),uv.x *sin(_WaveDir3) + uv.y*cos(_WaveDir3));

                pos.y += _WaveHight1 * 0.3333 *  sin(_WaveScale1 * uv1.x + _Time.x * _WaveSpeed1);
                pos.y += _WaveHight2 * 0.3333 *  sin(_WaveScale2 * uv2.x + _Time.x * _WaveSpeed2);
                pos.y += _WaveHight3 * 0.3333 *  sin(_WaveScale3 * uv3.x + _Time.x * _WaveSpeed3);


                o.vertex = UnityObjectToClipPos(pos);

                o.worldPos = mul(unity_ObjectToWorld,pos);

                UNITY_TRANSFER_FOG(o,pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(cross(ddy(i.worldPos),ddx(i.worldPos)));
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed4 diffuse = _LightColor0 * _Color * saturate(dot(worldNormal,worldLightDir)) * 0.5 + 0.5;

                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
                fixed3 halfDir = normalize(viewDir + worldLightDir);
                fixed3 specular = _SpecularColor.rgb * pow(max(0,dot(halfDir,worldNormal)),_Gloss);

                diffuse.rgb = diffuse + specular.rgb;

                UNITY_APPLY_FOG(i.fogCoord, diffuse);
                return diffuse;
            }
            ENDCG
        }
    }
}
