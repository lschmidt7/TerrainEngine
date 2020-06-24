Shader "Unlit/WaterShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color",Color) = (0,0,0,0)
		_Velocity1 ("Velocity 1",Range(0,1)) = 1.0
		_Density ("Density",Range(0,10)) = 1.0
		_Transparency("Transparency",Range(0,1)) = 1.0
		_Noise0("Noise 0",Range(0,5)) = 1.0
		_Noise1("Noise 1",Range(0,5)) = 1.0

	}
	SubShader
	{
		Tags {"Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100


        Blend SrcAlpha OneMinusSrcAlpha
        Cull back

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float4 _Color;
			float _RedChannel;
			float _GreenChannel;

			float _Velocity1;

			float _Density;

			float _Transparency;

			float _Noise0;
			float _Noise1;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float time = _Time.w*_Velocity1;

				float2 n0uv = float2(i.uv.x*1.4, i.uv.y - time*0.69);
			    float2 n1uv = float2(i.uv.x*0.5, i.uv.y*2.0 - time*0.12);
			    float n0 = (tex2D(_MainTex, n0uv).w-0.5);
			    float n1 = (tex2D(_MainTex, n1uv).w-0.5);
			    float noiseA = clamp(n0 + n1 , -1.0, 1.0)*_Noise0;

			    // Generate noisy y value
			    float2 n0uvB = float2(i.uv.x*0.7, i.uv.y - time*0.27);
			    float2 n1uvB = float2(i.uv.x*0.45, i.uv.y*2.0 - time*0.61);
			    float n0B = (tex2D(_MainTex, n0uvB).w-0.5);
			    float n1B = (tex2D(_MainTex, n1uvB).w-0.5);
			    float noiseB = clamp(n0B + n1B , -1.0, 1.0)*_Noise1;

			    float2 finalNoise = float2(noiseA, noiseB);
			    float perturb = (_Density - i.uv.y) * 0.35;
			    finalNoise = (finalNoise * perturb) + i.uv;

			    float4 col = tex2D(_MainTex, finalNoise);
			    col = float4(col.x*0.2, col.y*0.9, (col.y/col.x)*1.0, 1.0)*_Color;
			    finalNoise = clamp(finalNoise, 0.05, 1.0);
			    col.w = tex2D(_MainTex, finalNoise).g*_Transparency*2.0;
			    col.w = col.w*tex2D(_MainTex, i.uv).g;
        
        		clip(col.r-0.1);
        		clip(col.g-0.1);
        		clip(col.b-0.1);

				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
