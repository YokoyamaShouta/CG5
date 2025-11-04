Shader "Unlit/06_toonShader"
{
	Properties
   {
	   _Color("Color",Color) = (1,0,0,1)
	   _DiffuseThresold("Diffuse",Range(0,1))=0
	   _SpecularThresold("Sprecular",Range(0,1))=0
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
			   float3 normal : NORMAL;
		   };

		   struct v2f
		   {
			   float4 vertex : SV_POSITION;
			   float3 worldPosition : TEXCOORD1;
			   float3 normal : NORMAL;
		   };

		   fixed4 _Color;
		   float _DiffuseThresold;
		   float _SpecularThresold;

		   float step(float t,float x)
		   {
				if(t <= x)			   
				{
					return 1.0f;
				}
				else
				{
					return 0.0f;
				}
		   }

		   float4 vert(float4 v:POSITION):SV_POSITION
		   {
			   float4 o;
			   o = UnityObjectToClipPos(v);
			   return o;
		   }		   		  

		   v2f vert(appdata v)
		   {
			  v2f o;
			  o.vertex = UnityObjectToClipPos(v.vertex);
			  o.normal = UnityObjectToWorldNormal(v.normal);
			  o.worldPosition = mul(unity_ObjectToWorld,v.vertex);
			  return o;
		   }

		   fixed4 frag(v2f i) : SV_TARGET
		   {
			   //	ambient
			   //fixed4 ambient = _Color * 0.1;
			   fixed4 ambient = _Color * 0.3 * _LightColor0;

			   //	diffuse
			   float intensity = saturate(dot(normalize(i.normal),_WorldSpaceLightPos0));
			   intensity = step(_DiffuseThresold,intensity);
		   	   fixed4 color = fixed4(1,1,1,1);
		   	   fixed4 diffuse = _Color * intensity * _LightColor0;

			   //	specular
			   float3 eyeDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);
			   float3 lightDir = normalize(_WorldSpaceLightPos0);
			   i.normal = normalize(i.normal);
			   float3 reflecDir = -lightDir + 2 * i.normal * dot(i.normal,lightDir);
			   float reflection = pow(saturate(dot(reflecDir,eyeDir)),20);
			   // reflection = step(_SpecularThresold,reflecDir);
			   fixed4 specular = reflection * _LightColor0;

			   fixed4 phong	= ambient + diffuse + specular;
			   return phong;	
		   }
		   ENDCG
	   }
   }
}
