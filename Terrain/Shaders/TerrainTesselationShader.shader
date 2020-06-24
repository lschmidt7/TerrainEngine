Shader "Unlit/TerrainTesselationShader"
{
    Properties
    {
        _MousePos ("Mouse Pos",Vector) = (-200,-200,-200,0)
        _Color ("Color",Color) = (1,1,1,1)
        _LightPos ("Light Pos",Vector) = (0,0,0,0)
        _LightDir ("Light Dir",Vector) = (0,0,0,0)
        _LightAmbient ("Light Ambient",float) = 1
        _Map ("Map",2D) = "white" {}
        _Tilling ("_Tilling",int) = 1
        _BlendRate ("Blend Rate",float) = 0.01

        _Smooth ("Smooth",float) = 0.1
    }
    SubShader
    {
        Tags { "Queue"="Geometry" "RenderType"="Opaque" }
        LOD 100
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            #pragma target 5.0

            #include "UnityCG.cginc"
            #include "CGInc/structs.cginc"

            struct vertIN{
				uint vID : SV_VertexID;
				uint insID : SV_InstanceID;
			};

            struct v2g
            {
                float2 uv : TEXCOORD0;
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct g2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 vertexWorld : TEXCOORD1;
                float3 normal : NORMAL;
            };

            float4 _MousePos;
            float4 _Color;
            float4 _LightPos;
            float4 _LightDir;
            float _LightAmbient;
            int _Tilling;
            float _BlendRate;

            float sculpArea;

            bool editing;

            float _Smooth;

            sampler2D _Map;

            StructuredBuffer<Data> buffer;

            v2g vert (vertIN i)
            {
                v2g o;
				o.vertex = float4(buffer[i.vID].pos,0);
                o.uv = buffer[i.vID].uv;
                o.normal = normalize(mul(float4(buffer[i.vID].normal,0.0),unity_WorldToObject).xyz);
                return o;
            }

            float3 mediumPoint(float3 v1, float3 v2, float3 v3){
                return (v1+v2+v3)/3.0;
            }

            float2 mediumUV(float2 v1, float2 v2, float2 v3){
                return (v1+v2+v3)/3.0;
            }

            [maxvertexcount(9)]
            void geom( triangle v2g IN[3], inout TriangleStream<g2f> Stream )
            {
                g2f o;
                float3 v1 = IN[0].vertex.xyz;
                float3 v2 = IN[1].vertex.xyz;
                float3 v3 = IN[2].vertex.xyz;
                /*if(v1.y==v2.y && v1.y==v3.y){
                    o.vertex = UnityObjectToClipPos(v1);
                    o.vertexWorld = IN[0].vertex;
                    o.uv = IN[0].uv;
                    o.normal = IN[0].normal;
                    Stream.Append(o);
                    
                    o.vertex = UnityObjectToClipPos(v2);
                    o.vertexWorld = IN[1].vertex;
                    o.uv = IN[1].uv;
                    o.normal = IN[1].normal;
                    Stream.Append(o);

                    o.vertex = UnityObjectToClipPos(v3);
                    o.vertexWorld = IN[2].vertex;
                    o.uv = IN[2].uv;
                    o.normal = IN[2].normal;
                    Stream.Append(o);
                }else{*/
                    float3 v4 = mediumPoint(v1,v2,v3);
                    float2 uv4 = mediumUV(IN[0].uv,IN[1].uv,IN[2].uv);
                    float3 n4 = normalize(IN[0].normal+IN[1].normal+IN[2].normal);
                    v4+=n4*_Smooth;

                    // triangle 1
                    o.vertex = UnityObjectToClipPos(v1);
                    o.vertexWorld = IN[0].vertex;
                    o.uv = IN[0].uv;
                    o.normal = IN[0].normal;
                    Stream.Append(o);

                    o.vertex = UnityObjectToClipPos(v2);
                    o.vertexWorld = IN[1].vertex;
                    o.uv = IN[1].uv;
                    o.normal = IN[1].normal;
                    Stream.Append(o);

                    o.vertex = UnityObjectToClipPos(v4);
                    o.vertexWorld = float4(v4,1);
                    o.uv = uv4;
                    o.normal = n4;
                    Stream.Append(o);

                    Stream.RestartStrip();
                    // triangle 1

                    // triangle 2
                    o.vertex = UnityObjectToClipPos(v2);
                    o.vertexWorld = IN[1].vertex;
                    o.uv = IN[1].uv;
                    o.normal = IN[1].normal;
                    Stream.Append(o);

                    o.vertex = UnityObjectToClipPos(v3);
                    o.vertexWorld = IN[2].vertex;
                    o.uv = IN[2].uv;
                    o.normal = IN[2].normal;
                    Stream.Append(o);

                    o.vertex = UnityObjectToClipPos(v4);
                    o.vertexWorld = float4(v4,1);
                    o.uv = uv4;
                    o.normal = n4;
                    Stream.Append(o);

                    Stream.RestartStrip();
                    // triangle 2

                    // triangle 3
                    o.vertex = UnityObjectToClipPos(v3);
                    o.vertexWorld = IN[2].vertex;
                    o.uv = IN[2].uv;
                    o.normal = IN[2].normal;
                    Stream.Append(o);

                    o.vertex = UnityObjectToClipPos(v1);
                    o.vertexWorld = IN[0].vertex;
                    o.uv = IN[0].uv;
                    o.normal = IN[0].normal;
                    Stream.Append(o);

                    o.vertex = UnityObjectToClipPos(v4);
                    o.vertexWorld = float4(v4,1);
                    o.uv = uv4;
                    o.normal = n4;
                    Stream.Append(o);

                    //Stream.RestartStrip();
                    // triangle 3
                //}
            }

            fixed4 frag (g2f i) : SV_Target
            {
                
                // LIGHT
                float3 vertexToLight = normalize(_LightPos-i.vertexWorld);
                float ill = dot(vertexToLight,i.normal);
                // LIGHT

                fixed4 col =  tex2D(_Map, i.uv/_Tilling);
                col = col*ill+float4(0.2,0.2,0.2,0);
                
                // MOUSE
                if(editing==1){
                    float d = distance(i.uv,float2(_MousePos.x,_MousePos.z));
                    if(d>sculpArea-0.05 && d<sculpArea){
                        col = float4(0,0,0,1);
                    }
                }
                
                // MOUSE

                return col;
            }
            ENDCG
        }
    }
}