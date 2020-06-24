Shader "Custom/TerrainSurfaceShader"
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
        
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
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

        half _Glossiness;
        half _Metallic;

        struct Input
        {
            float2 uv_MainTex;
            float4 col;
        };

        struct appdata{
            uint vID : SV_VertexID;
            uint insID : SV_InstanceID;

            float3 worldPos : TEXCOORD1;

            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 texcoord : TEXCOORD0;
        };



        void vert(inout appdata i, out Input o){
            UNITY_INITIALIZE_OUTPUT(Input, o);
            #ifdef SHADER_API_D3D11
                i.vertex = float4(buffer[i.vID].pos,1);
                i.worldPos = mul(unity_ObjectToWorld,buffer[i.vID].pos);
                i.texcoord = float4(buffer[i.vID].uv,0,0);
                i.normal = normalize(mul(float4(buffer[i.vID].normal,0.0),unity_WorldToObject).xyz);
                o.col = tex2Dlod(_Map, float4(buffer[i.vID].uv/_Tilling,0,0));
            #endif
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            o.Albedo = IN.col;//tex2D(_Map, IN.uv_MainTex/_Tilling);
        }
        ENDCG
    }
}