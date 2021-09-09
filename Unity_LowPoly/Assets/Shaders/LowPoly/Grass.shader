Shader "LowPoly/Grass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"
            #include "Lighting.cginc" 

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 worldPos : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float3 _GrassOffsetCenter;
            float _GrassOffsetRadius;

            v2f vert (appdata v)
            {
                UNITY_SETUP_INSTANCE_ID(v);
                v2f o;
                float4 pos = v.vertex;
                float4 worldPos = mul(unity_ObjectToWorld,pos);

                float4 modelWorldPos = mul(unity_ObjectToWorld,float4(0,0,0,1));
                float dis = distance(_GrassOffsetCenter,modelWorldPos);
                if(dis < _GrassOffsetRadius)
                {
                    float3 dir = _GrassOffsetCenter - modelWorldPos;
                    dir = normalize(dir) * (_GrassOffsetRadius - dis);
                    worldPos.xyz = worldPos.xyz - dir * saturate(worldPos.y / 0.1);
                    pos = mul(unity_WorldToObject,worldPos);
                }

                o.vertex = UnityObjectToClipPos(pos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = worldPos;

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed3 worldNormal = normalize(cross(ddy(i.worldPos),ddx(i.worldPos)));
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed4 diffuse = _LightColor0 * col * saturate(dot(worldNormal,worldLightDir)) * 0.5 + 0.5;
                diffuse = diffuse * _Color;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, diffuse);
                return diffuse;
            }
            ENDCG
        }
    }

    Fallback "Mobile/Diffuse"
}
