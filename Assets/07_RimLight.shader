Shader "Unlit/07_RimLight"
{
    Properties
    {
        _Color("Color", Color) = (1,0,0,1)
        _RimPower("RimPower", FLOAT) = 0.5
    }
    SubShader
    {        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag           

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;                
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 worldPos : TECOORD1;
            };

            fixed4 _Color;
            float _RimPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 baseColor = _Color;
                fixed4 ambient = baseColor * 0.3;
                
                float3 eyeDir = normalize  (_WorldSpaceCameraPos.xyz - i.worldPos);
                float3 lightDir = -eyeDir;

                i.normal = normalize(i.normal);
                
                float3 reflectDir = -lightDir + 4 * i.normal *dot(i.normal,lightDir);
                fixed4 specular = pow(saturate(dot(reflectDir,eyeDir)),_RimPower) *_LightColor0;
                return (ambient + specular);
            }
            ENDCG
        }
    }
}
