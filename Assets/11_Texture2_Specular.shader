Shader "Unlit/11_Texture2_Speculer"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("BaseColor", color) = (0,0,0,0)
    }
    SubShader
    {        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag                        

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;                
                float4 vertex : SV_POSITION;
                float3 wPos : TEXCOORD1;
                float3 normal : NORMAL;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 aColor = _Color * 0.3;
                fixed4 dColor = _Color;
                fixed4 sColor = fixed4(1,1,1,1);
                float3 eyeDir = normalize(_WorldSpaceCameraPos.xyz - i.wPos);
                float3 halfVec = normalize(_WorldSpaceLightPos0 + eyeDir);
                float intensity = saturate(dot(normalize(i.normal),halfVec));
                float phong = pow(intensity, 20);
                fixed4 maskColor = tex2D(_MainTex, i.uv * _MainTex_ST.xy);
                return aColor + dColor * intensity + maskColor.r * phong * sColor;
            }
            ENDCG
        }
    }
}
