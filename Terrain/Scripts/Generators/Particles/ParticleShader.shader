Shader "Unlit/ParticleShader"
{
    Properties
    {
        _CircleSize ("Circle Size",Range(0,0.5)) = 1
        _Color ("Color",Color) = (1,1,1,1)
        _Bright ("Bright",Range(0,2)) = 1
        _NumOfPoints("Num Points",int)=1
        _FlowVelocity ("Flow Velocity",float) = 1

        _FlowMap ("Flow Map",2D) = "white" {}
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha

        ZWrite Off
		Ztest Always
		AlphaTest Greater 0

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define STEPS 10
            #define STEP_SIZE 0.01
            #define FAR 10000

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 wPos : TEXCOORD1;
            };

            float _CircleSize;
            float4 _Position;
            float4 _Color;
            float _Bright;
            int _NumOfPoints;
            float _FlowVelocity;

            sampler2D _FlowMap;

            StructuredBuffer<float3> points;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.wPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.uv = v.uv;
                return o;
            }

            float sdf(float3 p, float3 centro,float size){
                return distance(p,centro)-size;
            }

            float raymarching(float3 rs, float3 rd, inout float3 p, inout float3 center){
                float d,t=0.0,dd=100000;
                for(int i=0;i<STEPS;i++){
                    p = rs + rd * t;
                    for(int j=0;j<_NumOfPoints;j++){
                        
                        float3 shift = float3(0,1,0) * (_Time.y * _FlowVelocity);
                        float3 newPoint = points[j] + shift;

                        float3 desl1 = normalize(tex2Dlod(_FlowMap,float4(newPoint.x,newPoint.z,0,0)).xyz);
                        float3 desl2 = normalize(tex2Dlod(_FlowMap,float4(newPoint.y,newPoint.z,0,0)).xyz);
                        float3 desl = cross(desl1,desl2)*0.3;
                        newPoint+=desl.xyz;                        

                        float3 v = float3((int)newPoint.x/0.5,(int)newPoint.y/0.5,(int)newPoint.z/0.5);
                        if(v.y>1)
                            newPoint.y-=(v.y*0.5);
                        d = sdf(p,newPoint,_CircleSize);
                        if(d<dd){
                            center = newPoint;
                            dd=d;
                        }
                    }
                    if(dd<0.01 || dd>FAR)
                        break;
                    t+=dd;
                }
                return dd;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                float4 col = _Color;
                col.a=0;
                
                float3 ray_start = i.wPos;
                float3 ray_direction = normalize(float3(i.wPos-_WorldSpaceCameraPos));
                
                float d,ill;
                float3 p;
                float3 cent;
                d = raymarching(ray_start,ray_direction,p,cent);

                if(d<0.01){
                    ill = dot(normalize(_WorldSpaceCameraPos-p),normalize(cent-p))*(1-cent.y)*_Bright;
                    col.a=1;
                    col*=ill;
                }

                return col;
            }
            ENDCG
        }
    }
}