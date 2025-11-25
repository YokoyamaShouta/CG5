Shader "Unlit/10_Dissolve"
{
    Properties
    {
         _MainTex("MainTex", 2D) = "white" {}
        _MaskTex("MaskTex", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _Dissolve("Dissolve", Range(0,1)) = 0.5
    }

    SubShader
    {       
        Pass
        {
            Tags{"LightMode" = "UniversalForward"}
            //  •\–Ê‚Ì•`‰æ
            Cull front
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
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            float _Dissolve;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
               fixed4 mask = tex2D(_MaskTex,i.uv);
               clip(mask.r - _Dissolve);
               return fixed4(0,1,1,1);
            }
            ENDCG
        }

        Pass
        {
            Cull back
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
                float4 vertex : SV_POSITION;
                float2 uv  : TEXCOORD0;
            };

            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            float _Dissolve;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 mask = tex2D(_MaskTex,i.uv);
                clip(mask.r - _Dissolve);
                return mask;
            }
            ENDCG
        }        
    }
}
