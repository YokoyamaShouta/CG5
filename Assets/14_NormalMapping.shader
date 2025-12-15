Shader "Unlit/14_NormalMapping"
{
    Properties
    {
        _MainTex ("Albedo", 2D) = "white" {}
        _NormalTex ("Normal Map", 2D) = "bump" {}
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
               float4 vertex  : POSITION;
               float2 uv      : TEXCOORD0;
               float3 normal : NORMAL;
               float4 tangent : TANGENT;
            };

        struct v2f
        {
            float4 vertex  : SV_POSITION; // クリップ空間座標
            float2 uv      : TEXCOORD0;   // UV座標
            
            // TBNベクトルをワールド空間で格納
            float3 T : TEXCOORD1; // ワールド空間の接線 (Tangent)
            float3 B : TEXCOORD2; // ワールド空間の従法線 (Binormal)
            float3 N : TEXCOORD3; // ワールド空間の法線 (Normal)
            
            float3 worldPos : TEXCOORD4; // ワールド空間の頂点位置
        };

         sampler2D _MainTex;
         sampler2D _NormalTex;

        v2f vert (appdata v)
        {
            v2f o;
            // クリップ空間の頂点位置
            o.vertex = UnityObjectToClipPos(v.vertex);
            // ワールド空間の頂点位置
            o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
            // UV座標
            o.uv = v.uv;
        
            // TBNベクトルをワールド空間に変換
            // UnityCG.cginc のマクロを使えば簡単ですが、手動で計算
            float3 N = UnityObjectToWorldNormal(v.normal);
            float3 T = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz));
            // 従法線を計算 (v.tangent.w がフリップの有無を示す)
            float3 B = cross(N, T) * v.tangent.w;
        
            o.N = normalize(N);
            o.T = normalize(T);
            o.B = normalize(B);
            
            return o;
        }

        uniform float4 _LightColor0; // メインのディレクショナルライトの色
        
        fixed4 frag (v2f i) : SV_Target
        {
            // 1. 法線の準備 (接空間 -> ワールド空間)
            float3 nMap = UnpackNormal(tex2D(_NormalTex, i.uv)); // UnpackNormal を使うのが一般的
            
            // TBN行列（ワールド空間のTBNベクトル）を使って変換
            // TBN行列 M = [i.T, i.B, i.N]
            float3x3 TBN = float3x3(i.T, i.B, i.N);
            float3 wNormal = normalize(mul(TBN, nMap));
        
            // 2. ライトベクトルの準備
            // _WorldSpaceLightPos0.w が 0 の場合（ディレクショナルライト）
            float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
            
            // 3. ライティング計算（ディフューズ光）
            // Lambertian反射モデル
            float NdotL = max(0.0, dot(wNormal, lightDir));
            float3 diffuse = NdotL * _LightColor0.rgb;
        
            // 4. アルベド（メインテクスチャ）のサンプリング
            fixed4 albedo = tex2D(_MainTex, i.uv);
            
            // 5. 最終色の計算
            fixed3 finalColor = albedo.rgb * diffuse;
        
            return fixed4(finalColor, albedo.a);
        }
            ENDCG
        }
    }
}
