float sigmoid(float v){
    return 1.0/(1.0+exp(v));
}

float stair(float v){
    if(v<0.1){
        return 1.0;
    }
    if(v<0.6){
        return 0.6;
    }
    return 0.3;

}

float distanceUV(float4 p1, float2 p2){
    return sqrt(pow(p2.x-p1.x,2)+pow(p2.y-p1.z,2));
}