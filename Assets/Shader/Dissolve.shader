// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Dissolve"
{
    Properties
    {
        _BurnAmount             ("Burn Amount", Range(0.0, 1.0)) = 0.0
        _LineWidth              ("Burn Line Width", Range(0.0, 0.2)) = 0.1
        _MainTex                ("Base (RGB)", 2D) = "white" {}
        _BumpMap                ("Normal Map", 2D) = "bump" {}
        _BurnFirstColor         ("Burn First Color", Color) = (1, 0, 0, 1)
        _BurnSecondColor        ("Burn Second Color", Color) = (1, 0, 0, 1)
        _BurnMap                ("Burn Map", 2D) = "white" {}
    }

    SubShader
    {

        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed _BurnAmount;
            fixed _LineWidth;
            sampler2D _MainTex;
            sampler2D _BumpMap;
            fixed4 _BurnFirstColor;
            fixed4 _BurnSecondColor;
            sampler2D _BurnMap;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uvMainTex : TEXCOORD0;
                float2 uvBumpMap : TEXCOORD1;
                float2 uvBurnMap : TEXCOORD2;
                float3 lightDir : TEXCOORD3;
                float3 worldPos : TEXCOORD4;
                SHADOW_COORDS(5);
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.uvMainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uvBumpMap = TRANSFORM_TEX(v.texcoord, _BumpMap);
                o.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);

                TANGENT_SPACE_ROTATION;
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
