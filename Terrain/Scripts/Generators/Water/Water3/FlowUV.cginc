

float3 flowuv(float2 uv, float2 flowVector,float2 jump,float time, bool flowB){
	float offs = flowB ? 0.5 : 0;
	float progress = frac(time+offs);
	float3 uvw;
	uvw.xy = uv - flowVector * progress + offs;
	uvw.xy += (time-progress) * jump;
	uvw.z = 1 - abs( 1 - 2 * progress );
	return uvw;
}