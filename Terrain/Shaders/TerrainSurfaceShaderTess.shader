Shader "Custom/TerrainSurfaceShaderTess"
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
        
        _DispTex ("Displacement Map", 2D) = "gray" {}
        _TexVal ("Tessellation value", Range(1,40)) = 1
        _DispVal ("Displacement factor", Range (0, 1)) = 0
    }
    SubShader
    {


        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 5.0

        #include "UnityCG.cginc"
        #include "CGInc/structs.cginc"


        #ifdef SHADER_API_D3D11
            StructuredBuffer<Data> buffer;
        #endif

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

        // tess
        sampler2D _DispTex;
        float _DispVal;
        float _TexVal;

        float4 tess() {
            return _TexVal;
        }
        // tess

        struct Input
        {
            float2 uv_MainTex;
            float4 col;
        };

        struct appdata{
            uint vID : SV_VertexID;
            uint insID : SV_InstanceID;

            //float4 worldPos : TEXCOORD1;

            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 texcoord1 : TEXCOORD0;
            float4 texcoord2 : TEXCOORD1;
        };

        void vert(inout appdata i, out Input o){
            UNITY_INITIALIZE_OUTPUT(Input, o);
            #ifdef SHADER_API_D3D11
                float val = tex2Dlod(_Map, float4(buffer[i.vID].uv/_Tilling, 0, 0)).r * _DispVal;
                i.normal = normalize(mul(float4(buffer[i.vID].normal,0.0),unity_WorldToObject).xyz);
                i.vertex = float4(buffer[i.vID].pos,1) + float4(i.normal,0) * val;
                //i.worldPos = mul(unity_ObjectToWorld,buffer[i.vID].pos);
                i.texcoord1 = float4(buffer[i.vID].uv,0,0);
                o.col = tex2Dlod(_Map, float4(buffer[i.vID].uv/_Tilling,0,0));
            #endif
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = IN.col;
        }
        ENDCG
    }
}