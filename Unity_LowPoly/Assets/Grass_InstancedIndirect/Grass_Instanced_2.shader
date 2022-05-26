Shader "LowPoly/Grass_Instanced_2" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _SwingOffset ("Swing Offset",Float) = 0.1
        _WindDir ("Wind Direction",Vector) = (0,0,0,0)

        [NoScaleOffset]
        _GrassColorTex ("Grass Color Texture",2D) = "white" {}
        _ColTexScale ("Color Texture Scale",Range(0.01,200)) = 25

        _NoiseTex ("Animation Noise Texture",2D) = "white" {}
        _AniSpeed ("Animation Speed",Range(0,5)) = 1
    }
    SubShader {

        Cull Off

        Pass {

            Tags {"LightMode"="ForwardBase" "RenderType"="Opaque"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            #pragma target 4.5

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            float _SwingOffset;
            float3 _WindDir;

            sampler2D _GrassColorTex;
            float _ColTexScale;

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float _AniSpeed;

        #if SHADER_TARGET >= 45
            StructuredBuffer<float4> positionBuffer;
        #endif

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 coluv : TEXCOORD2;

            };

            v2f vert (appdata v, uint instanceID : SV_InstanceID)
            {
            #if SHADER_TARGET >= 45
                float4 data = positionBuffer[instanceID];
            #else
                float4 data = 0;
            #endif

                float3 localPos = v.vertex.xyz;
                float a = data.w;
                float b = atan(localPos.x / localPos.z);
                float r = sqrt(localPos.x * localPos.x  + localPos.z * localPos.z);
                localPos.x = r * cos(a + b);
                localPos.z = r * sin(a + b);
                float3 worldPos = data.xyz + localPos;

                v2f o;

                o.coluv = float2(((worldPos.x + _ColTexScale * 0.5f) % _ColTexScale) / _ColTexScale,((worldPos.z + _ColTexScale * 0.5f) % _ColTexScale) / _ColTexScale);\
                _NoiseTex_ST.zw += _Time.x * _AniSpeed;

                float2 nosieuv = TRANSFORM_TEX(o.coluv, _NoiseTex);
                fixed4 noise = tex2Dlod(_NoiseTex,float4(nosieuv,0,0));
                fixed n = 0.299 * noise.r + 0.587 * noise.g + 0.144 * noise.b;
                worldPos.y *= n;

                o.vertex = mul(UNITY_MATRIX_VP, float4(worldPos, 1.0f));

                float3 moveDir = _SwingOffset * _WindDir * _SinTime.w * _AniSpeed;
                worldPos = worldPos + moveDir * max(0,localPos. y / 1.0) * n;

                o.worldPos = worldPos;
                o.uv = v.uv;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_GrassColorTex, i.coluv);
                col += col * col * col * col;
                fixed3 worldNormal = normalize(cross(ddy(i.worldPos),ddx(i.worldPos)));
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed4 diffuse = _LightColor0 * saturate(dot(worldNormal,worldLightDir)) * 0.5 + 0.75;
                return diffuse * col;
            }

            ENDCG
        }
    }
}