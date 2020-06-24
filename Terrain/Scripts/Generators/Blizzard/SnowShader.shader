Shader "Unlit/SnowShader"
{
	Properties
	{
		_SnowTex ("Texture", 2D) = "white" {}
		_SnowSize("Size",Range(0,0.1)) = 0.1
		_SnowVelocity("Velocity",Range(0,2)) = 1
		_Desvio("Desvio",Range(1,50)) = 1
	}
	SubShader
	{
		Cull Off
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			#include "UnityCG.cginc"

			StructuredBuffer<float3> buffer;

			struct vertIN{
				uint vID : SV_VertexID;
				uint insID : SV_InstanceID;
			};

			struct v2g
			{
				float4 vertex : POSITION;
			};

			struct g2f{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _SnowTex;
			float4 _SnowTex_ST;

			float _SnowSize;
			float _SnowVelocity;
			float _Desvio;
			float _StartHeight;

			float2 vf(float3 p){
				return float2(-p.z,p.x);
			}

			v2g vert (vertIN i)
			{
				v2g o;
				float3 v0 = buffer[i.vID];
				float2 desv1 = -normalize(vf(v0+float3(cos(_Time.x),0,sin(_Time.x))))*_Desvio;
				float3 desv = float3(desv1.x,0,desv1.y);
				desv.y = _Time.x * _SnowVelocity * _StartHeight;
				v0 -= desv;
				if(v0.y<0){
					int d = (int)(abs(v0.y)/_StartHeight);
					if(d<1)
						v0.y += _StartHeight;
					else
						v0.y += (d+1)*_StartHeight;
					
				}
				o.vertex = float4(v0,1);
				return o;
			}

			[maxvertexcount(8)]
			void geom(point v2g IN[1], inout TriangleStream<g2f> stream){

				float3 v0 = IN[0].vertex.xyz;

				float3 norm = float3(0,0.5,0);

				float3 v1 = v0 + norm * _SnowSize;

				float3 v2 = v0+(float3(0.5,0,0)*_SnowSize);

				float3 v3 = v1+(float3(0.5,0,0)*_SnowSize);


				float3 v5 = v0+(float3(0.25,0,0)*_SnowSize)-(float3(0,0,0.25)*_SnowSize);

				float3 v6 = v5+ norm * _SnowSize;

				float3 v7 = v5+(float3(0,0,0.5)*_SnowSize);

				float3 v8 = v7 + norm * _SnowSize;

				g2f o;
				o.vertex = UnityObjectToClipPos(v0);
				o.uv = float2(0,0);
				stream.Append(o);

				o.vertex = UnityObjectToClipPos(v1);
				o.uv = float2(1,0);
				stream.Append(o);

				o.vertex = UnityObjectToClipPos(v2);
				o.uv = float2(0,1);
				stream.Append(o);

				o.vertex = UnityObjectToClipPos(v3);
				o.uv = float2(1,1);
				stream.Append(o);

				stream.RestartStrip();


				o.vertex = UnityObjectToClipPos(v5);
				o.uv = float2(0,0);
				stream.Append(o);

				o.vertex = UnityObjectToClipPos(v6);
				o.uv = float2(1,0);
				stream.Append(o);

				o.vertex = UnityObjectToClipPos(v7);
				o.uv = float2(0,1);
				stream.Append(o);

				o.vertex = UnityObjectToClipPos(v8);
				o.uv = float2(1,1);
				stream.Append(o);

				stream.RestartStrip();
			}
			
			fixed4 frag (g2f i) : SV_Target
			{
				fixed4 col = tex2D(_SnowTex, i.uv);
				clip(col.a-0.7);
				return col;
			}
			ENDCG
		}
	}
}
