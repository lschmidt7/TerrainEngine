Shader "Custom/WaterFlowShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		[NoScaleOffset] _FlowMap ("Flow (RG, A noise)", 2D) = "black" {}
		_NormalMap ("Normal Map",2D) = "black" {}

		_UJump("U jump",Range(-0.25,0.25)) = 0.25
		_VJump("V jump",Range(-0.25,0.25)) = 0.25

		_Speed("Speed",Range(0,2)) = 1
	}
	SubShader {
		Tags { "Queue"="Transparent"  "RenderType"="Transparent"}
		LOD 200

		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM

		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		#include "FlowUV.cginc"

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _FlowMap;
		sampler2D _NormalMap;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		float _UJump;
		float _VJump;

		float _Speed;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			float2 flowVector = tex2D(_FlowMap,IN.uv_MainTex).rg*2-1;
			float noise = tex2D(_FlowMap,IN.uv_MainTex).a;
			float time = _Time.y*_Speed+noise;

			float3 uvwA = flowuv(IN.uv_MainTex,flowVector,float2(_UJump,_VJump),time,false);
			float3 uvwB = flowuv(IN.uv_MainTex,flowVector,float2(_UJump,_VJump),time,true);

			float3 normalA = UnpackNormal(tex2D(_NormalMap, uvwA.xy)) * uvwA.z;
			float3 normalB = UnpackNormal(tex2D(_NormalMap, uvwB.xy)) * uvwB.z;
			o.Normal = normalize(normalA + normalB);

			fixed4 c1 = tex2D (_MainTex, uvwA.xy) * uvwA.z;
			fixed4 c2 = tex2D (_MainTex, uvwB.xy) * uvwB.z;

			fixed4 c = (c1+c2)* _Color;

			o.Albedo = c;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
