Shader "Unlit/07_RimLight"
{
Properties
    {
        _Color("Base Color", Color) = (1,0,0,1)
        _RimColor("Rim Color", Color) = (1,1,1,1)
        _RimPower("Rim Power", Range(0.1, 8)) = 3
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            fixed4 _Color;
            fixed4 _RimColor;
            float _RimPower;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // カメラ方向ベクトル
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

                // 法線と視線ベクトルの角度を利用してリム強度を計算
                float rim = 1.0 - saturate(dot(viewDir, normalize(i.worldNormal)));

                // powでリムの鋭さを調整
                rim = pow(rim, _RimPower);

                // ベース色 + リムライト色
                fixed4 col = _Color + _RimColor * rim;

                // 不透明
                col.a = 1;
                return col;
            }
            ENDCG
        }
    }
}
