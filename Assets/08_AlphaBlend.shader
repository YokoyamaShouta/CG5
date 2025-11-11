Shader "Unlit/"	//	シェーダ
{
	Properties
	{
		_Color("Color",Color) = (1,0,0,1)
	}

	SubShader	
	{
		Tags
		{
			"Queue" = "Transparent"
		}

		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma	vertex vert
			#pragma	fragment frag
			#include "UnityCG.cginc"	//	unity機能インクルード

			fixed4 _Color;

			float4 vert(float4 v:POSITION):SV_POSITION
			{
				float4 o;
				o = UnityObjectToClipPos(v);
				return o;
			}

			fixed4 frag(float4 i:SV_POSITION):SV_TARGET
			{
				fixed4 o = fixed4(1,0,0,0.3);
				return o;
			}
			
			ENDCG
		}
	}
}