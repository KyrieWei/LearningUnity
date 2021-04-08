Shader "Unlit/ToonShading"
{
    Properties
    {
        _Color          ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex        ("Main Tex", 2D) = "white" {}
        _Ramp           ("Ramp Texture", 2D) = "white" {}
        _Outline        ("Outline", Range(0, 1)) = 0.1
        _OutlineColor   ("Outline Color", Color) + (0, 0, 0, 1)
        _Specular       ("Specular", Color) = (1, 1, 1, 1)
        _SpecularScale  ("Specular Scale", Range(0, 0.1)) = 0.01
    }

    SubShader
    {

        Pass
        {
            NAME "OUTLINE"

            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
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
