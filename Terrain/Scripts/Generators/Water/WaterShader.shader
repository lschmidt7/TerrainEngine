Shader "Custom/WaterShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Cube ("Cubemap", CUBE) = "" {}

		_Velocity("Velocity",Range(1,10)) = 1

		_NormalMap ("Normal Map", 2D) = "white" {}
		_Transparence("Transparence",Range(0.0,1.0))=0.0

		_Resolution("Resolution",Range(0.0,50.0))=1
		_Frequency("Frequency",Range(0.0,50.0))=1
		_Speed("Speed",Range(0.0,500.0))=1
		_Amplitude("Amplitude",Range(0.0,50.0))=1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
        LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _NormalMap;
		samplerCUBE _Cube;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		float _Velocity;
		float _Transparence;

		float _Resolution;
		float _Frequency;
		float _Speed;
		float _Amplitude;

		void surf (Input IN, inout SurfaceOutputStandard o) {

			float2 uv = IN.uv_MainTex;
			uv.x -= 1+cos(_Time.x);
			uv.y -= 1+sin(_Time.x);
			float2 scaledUv = ( uv - 0.5 ) * _Resolution;

			float2 ripple = float2(
		        sin(  (length( scaledUv ) * _Frequency ) + ( _Time.x * _Speed ) ),
		        cos( ( length( scaledUv ) * _Frequency ) + ( _Time.x * _Speed ) )
		    // Scale amplitude to make input more convenient for users
		    ) * ( _Amplitude / 1000.0 );


			fixed4 c = tex2D (_MainTex, IN.uv_MainTex+ripple) * _Color;
			o.Normal = UnpackNormal(tex2D(_NormalMap,scaledUv));
			o.Albedo = c.rgb*10;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a*_Transparence;

		}
		ENDCG
	}
	FallBack "Diffuse"
}
