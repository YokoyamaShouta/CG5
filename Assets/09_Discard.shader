Shader "Unlit/09_Discard"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _Cutoff("Cutoff", Range(0,1)) = 0.5
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="TransparentCutout" }

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _Cutoff;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv  : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                
                clip(col.r - 0.01);

                return col;
            }
            ENDCG
        }
    }
}
