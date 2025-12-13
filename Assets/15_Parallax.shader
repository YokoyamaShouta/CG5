Shader "Unlit/15_Parallax"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;                
                float4 vertex : SV_POSITION;
                float3 viewDirTS : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
               v2f o;

               o.vertex = UnityObjectToClipPos(v.vertex);

               o.uv = v.uv;
               //   vertex uv ‚ÌŒvŽZŽ‘—¿
               float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
               float3 viewDirWS = _WorldSpaceCameraPos.xyz - worldPos;

               float3 t = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz));
               float3 n = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
               float3 b = cross(n,t) * v.tangent.w * unity_WorldTransformParams.w;

               float3x3 matTBN = float3x3(t,b,n);
               o.viewDirTS = mul(matTBN,viewDirWS);

               return o;
            }      
            
            fixed4 frag(v2f i) : SV_Target
            {
                float3 viewDirTS = normalize(-i.viewDirTS);
                float2 offset = viewDirTS.xy * 0.5;
                float2 uv = i.uv + offset;
                return tex2D(_MainTex,uv);
            }
            ENDCG
        }
    }
}
