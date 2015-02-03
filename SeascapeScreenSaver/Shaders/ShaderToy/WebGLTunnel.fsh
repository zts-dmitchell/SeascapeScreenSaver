// http://stackoverflow.com/questions/5451376/how-to-implement-this-tunnel-like-animation-in-webgl
// Converted to ShaderToy by Michael Pohoreski in 2015
// https://www.shadertoy.com/view/XlXGD4
// Minor cleanup
// Remove unused vars: CENTER, x, y, PI

const int   MAX_RINGS     = 30;
const float RING_DISTANCE = 0.05;
const float WAVE_COUNT    = 60.0;
const float WAVE_DEPTH    = 0.04;

//uniform float uTime;
//varying vec2 vPosition;

void main(void) 
{
    vec2 vPosition = 2.*gl_FragCoord.xy/iResolution.xy-1.;
    float rot = mod(iGlobalTime*0.6, 6.28318530717959 ); // 2.*PI
    
    bool black = false;
    float prevRingDist = RING_DISTANCE;
    for (int i = 0; i < MAX_RINGS; i++) {
        vec2  center = vec2(0.0, 0.7 - RING_DISTANCE * float(i)*1.2);
        float radius = 0.5 + RING_DISTANCE / (pow(float(i+5), 1.1)*0.006);
        float dist   = distance(center, vPosition);
              dist   = pow(dist, 0.3);
        float ringDist = abs(dist-radius);

        if (ringDist < RING_DISTANCE*prevRingDist*7.0)
        {
            vec2  d           = vPosition - center;
            float angle       = atan( d.y, d.x );
            float thickness   = 1.1 * ringDist / prevRingDist;
            float depthFactor = WAVE_DEPTH * sin((angle+rot*radius) * WAVE_COUNT);
            if (dist > radius)
                black = (thickness < RING_DISTANCE * 5.0 - depthFactor * 2.0);
            else
                black = (thickness < RING_DISTANCE * 5.0 + depthFactor);
            break; // causes all white on GTX Titan !? // removes inner thin path
        }
        if (dist > radius)
            break;
        prevRingDist = ringDist;
    }
    
    gl_FragColor.rgb = black ? vec3(0) : vec3(1);
}
