Shader "Unlit/TerrainShader"
{
    Properties
    {
        _MousePos ("Mouse Pos",Vector) = (-200,-200,-200,0)
        _Color ("Color",Color) = (1,1,1,1)
        _LightPos ("Light Pos",Vector) = (0,0,0,0)
        _LightDir ("Light Dir",Vector) = (0,0,0,0)
        _LightAmbient ("Light Ambient",float) = 10
        _Map ("Map",2D) = "white" {}
        _Tilling ("_Tilling",int) = 1
        _BlendRate ("Blend Rate",float) = 0.01
    }
    SubShader
    {
        Tags { "Queue"="Geometry" "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 5.0

            #include "UnityCG.cginc"
            #include "CGInc/structs.cginc"

            struct vertIN{
				uint vID : SV_VertexID;
				uint insID : SV_InstanceID;
			};

            struct v2f
            {
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD0;
                float4 vertex : POSITION;
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

            sampler2D _Map;

            StructuredBuffer<Data> buffer;

            v2f vert (vertIN i)
            {
                v2f o;
				float4 position = float4(buffer[i.vID].pos,0);
				o.vertex = UnityObjectToClipPos(position);
                o.worldPos = mul(unity_ObjectToWorld,position);
                o.uv = buffer[i.vID].uv;
                o.normal = normalize(mul(float4(buffer[i.vID].normal,0.0),unity_WorldToObject).xyz);
                return o;

            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                // LIGHT
                float3 vertexToLight = normalize(_LightPos-i.worldPos);
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