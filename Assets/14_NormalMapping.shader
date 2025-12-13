Shader "Unlit/14_NormalMapping"
{
    Properties
    {
        _MainTex ("Albedo", 2D) = "white" {}
        _NormalTex ("Normal Map", 2D) = "bump" {}
        _LightColor ("Light Color", Color) = (1,1,1,1)
        _LightDir ("Light Direction", Vector) = (0.5, 1, 0.3, 0)
        _SpecularPower ("Specular Power", Float) = 32
        _SpecularIntensity ("Specular Intensity", Float) = 1
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
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                float3 T : TEXCOORD2;
                float3 B : TEXCOORD3;
                float3 N : TEXCOORD4;
            };

            sampler2D _MainTex;
            sampler2D _NormalTex;
            fixed4 _LightColor;
            float4 _LightDir;
            float _SpecularPower;
            float _SpecularIntensity;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                float3 t = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz));
                float3 n = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                float3 b = cross(n, t) * v.tangent.w;

                o.T = t;
                o.B = b;
                o.N = n;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // ノーマルマップの値を[-1, 1]に変換
                float3 normalTS = tex2D(_NormalTex, i.uv).xyz * 2 - 1;

                // TBN行列を用いて接線空間からワールド空間へ変換
                float3x3 TBN = float3x3(i.T, i.B, i.N);
                float3 normalWS = normalize(mul(TBN, normalTS));

                // ライト方向を正規化
                float3 lightDir = normalize(_LightDir.xyz);

                // ディフューズ成分
                float diff = saturate(dot(normalWS, lightDir));
                fixed4 diffuse = diff * _LightColor;

                // 視線方向
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

                // スペキュラ成分（Phong反射モデル）
                float3 reflectDir = reflect(-lightDir, normalWS);
                float spec = pow(saturate(dot(viewDir, reflectDir)), _SpecularPower) * _SpecularIntensity;
                fixed4 specular = spec * _LightColor;

                // アルベドテクスチャ取得
                fixed4 albedo = tex2D(_MainTex, i.uv);

                // ライティング合成
                fixed4 color = albedo * diffuse + specular;
                color.a = albedo.a; // アルファは元テクスチャのまま

                return color;
            }

            ENDCG
        }
    }
}
