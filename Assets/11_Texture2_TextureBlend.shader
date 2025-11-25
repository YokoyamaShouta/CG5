Shader "Unlit/11_Texture2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SubTex ("SubTex",2D) = "white" {}
        _MaskTex ("MaskTex",2D) = "black" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
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
                float4 vertex : SV_POSITION;
            };                      

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _MaskTex;
            sampler2D _SubTex;
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 main = tex2D(_MainTex,i.uv * _MainTex_ST.xx);
                fixed4 sub = tex2D(_SubTex,i.uv * _MainTex_ST.xx);
                fixed4 mask = tex2D(_MaskTex,i.uv);
                return lerp(sub,main,mask.r);
            }
            ENDCG
        }
    }
}
