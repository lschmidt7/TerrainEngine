Shader "Unlit/Cloud"
{
    Properties
    {
        _HeigthMapHigh ("Heigth Map High", 2D) = "white" {}

        _HeigthMapLow ("Heigth Map Low", 2D) = "white" {}

        _Transparency ("Transparency",Range(0,1)) = 0.5

        _Height ("Heigth",Range(0,4)) = 1

        _Step ("Step",Range(0,0.2)) = 0.01

        _Position ("Position",Vector) = (0,0,0,0)
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 wPos : TEXCOORD1;
            };

            sampler2D _HeigthMapLow;
            sampler2D _HeigthMapHigh;
            float4 _HeigthMapHigh_ST;

            float _Transparency;

            float _Height;

            float _Step;

            float4 _Position;

            float2 wposToUV(float3 wPos){
                float size=5;
                float2 uv = float2((wPos.x+size)/(2*size) ,(wPos.z+size)/(2*size)); // i.wPos.xz in uv coords
                return uv;
            }

            float4 map(float2 uv, sampler2D map){
                return tex2D(map,uv);
            }

            float4 raycastHit(float3 p, float3 viewDir){
                for(int i=0;i<100;i++){
                    
                    float2 uv = wposToUV(p);
                    float4 hh = map(uv,_HeigthMapHigh);
                    float4 hl = map(uv,_HeigthMapLow);
                    float pos_offset = _Position.y-0.34;
                    if(p.y<=pos_offset+hh.r*_Height && p.y>=pos_offset-hl.r*_Height){
                        float4 col = (hh+hl)/2;
                        return col;
                    }
                    p += _Step * viewDir;
                }
                return float4(-1,-1,-1,-1);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.wPos = mul(unity_ObjectToWorld,v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _HeigthMapHigh);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = fixed4(1,1,1,1);
                float3 viewDir = normalize(i.wPos - _WorldSpaceCameraPos);
                float4 c = raycastHit(i.wPos,viewDir);
                if(c.r>=0){
                    col = c;
                    col.a = c.r;
                }
                
                return col;
            }
            ENDCG
        }
    }
}
