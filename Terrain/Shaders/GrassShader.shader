Shader "Unlit/GrassShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Height ("Grass Height",float) = 1
        _Width ("Grass Width",float) = 1
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
            #include "CGInc/structs.cginc"

            struct v2g{
                float4 pos : POSITION;
                float3 dir : NORMAL;
            };

            struct g2f{
                float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Height;
            float _Width;

            StructuredBuffer<Grass> buffer; // grass points

            v2g vert (uint id : SV_VertexID)
            {
                v2g o;
                o.pos = float4(buffer[id].pos,1);
                o.dir = buffer[id].dir;
                return o;
            }

            [maxvertexcount(4)]
            void geom( point v2g IN[1], inout TriangleStream<g2f> OutputStream )
            {
                float3 up = float3(0,_Height,0);

                float3 p1 = IN[0].pos;
                float3 p2 = p1+IN[0].dir*_Width;
                float3 p3 = p1+up;
                float3 p4 = p2+up;

                g2f v1;
                v1.pos = UnityObjectToClipPos(p1);
                v1.uv = float2(0,0);
                OutputStream.Append(v1);
                
                g2f v2;
                v2.pos = UnityObjectToClipPos(p2);
                v2.uv = float2(1,0);
                OutputStream.Append(v2);

                g2f v3;
                v3.pos = UnityObjectToClipPos(p3);
                v3.uv = float2(0,1);
                OutputStream.Append(v3);

                g2f v4;
                v4.pos = UnityObjectToClipPos(p4);
                v4.uv = float2(1,1);
                OutputStream.Append(v4);

            }

            fixed4 frag (g2f i) : SV_Target
            {
                // sample the texture
                float4 col = tex2D(_MainTex, i.uv);
                clip(col.a-0.7);
                return col;
            }
            ENDCG
        }
    }
}
