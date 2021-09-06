Shader "LowPoly/Water"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _SpecularColor ("Specular Color", Color) = (0,0,0,1)
        _Gloss ("Gloss",Range(0.5,10.0)) = 1.0

        _WaveHight ("Wave Hight",Float) = 1.0
        _WaveDir("Wave Direction",Vector) = (1,0,0,0)

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            float4 _SpecularColor;
            float _Gloss;

            float _WaveHight;

            v2f vert (appdata v)
            {
                v2f o;

                float4 pos = v.vertex;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                pos.y += _WaveHight * sin(_Time.y * o.uv.x);

                o.vertex = UnityObjectToClipPos(pos);

                o.worldPos = mul(unity_ObjectToWorld,pos);

                UNITY_TRANSFER_FOG(o,pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                fixed3 worldNormal = normalize(cross(ddy(i.worldPos),ddx(i.worldPos)));
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rbg * col.rbg * saturate(dot(worldNormal,worldLightDir)) * 0.5 + 0.5;

                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
                fixed3 halfDir = normalize(viewDir + worldLightDir);
                fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0,dot(halfDir,worldNormal)),_Gloss);

                col.rgb = diffuse + specular.rgb;

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
