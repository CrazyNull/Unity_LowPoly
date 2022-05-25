Shader "LowPoly/Grass_Instanced_2" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _ColorLimit ("Color Limit",float) = 1.0
        _SwingOffset ("Swing Offset",Float) = 0.1
        _WindDir ("Wind Direction",Vector) = (0,0,0,0)
        _ColTexScale ("Color Texture Scale",Range(10,500)) = 100
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
            float _ColorLimit;

            float _ColTexScale;
            sampler2D _GrassColorTex;
            

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
                fixed4 color : TEXCOORD2;
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

                float3 moveDir = _SwingOffset * _WindDir * _SinTime.w;
                worldPos = worldPos + moveDir * smoothstep(0,1,v.vertex.y / 1.0);

                v2f o;
                o.vertex = mul(UNITY_MATRIX_VP, float4(worldPos, 1.0f));
                o.worldPos = worldPos;
                o.uv = v.uv;
                o.color = pow(_Color,v.vertex.y / _ColorLimit);

                //o.color = fixed4(1,1,1,1);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 coluv = float2(((i.worldPos.x + _ColTexScale * 0.5f) % _ColTexScale) / _ColTexScale,((i.worldPos.z + _ColTexScale * 0.5f) % _ColTexScale) / _ColTexScale);
                fixed4 col = tex2D(_GrassColorTex, coluv);
                col += col * col * col;
                fixed3 worldNormal = normalize(cross(ddy(i.worldPos),ddx(i.worldPos)));
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed4 diffuse = _LightColor0 * saturate(dot(worldNormal,worldLightDir)) * 0.5 + 0.5;
                //return diffuse * i.color * col;
                return col;
            }

            ENDCG
        }
    }
}