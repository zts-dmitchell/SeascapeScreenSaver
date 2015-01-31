// Created by Reinder Nijhoff 2015
//
// Based on https://www.shadertoy.com/view/4ls3D4 by Dave_Hoskins

#define n b = .5*(b + texture2D(iChannel0, (c.xy + vec2(37, 17) * floor(c.z)) / 256.).x); c *= .4;

void main() {
    vec3 p = vec3(gl_FragCoord.xy / iResolution.xy - .5, .2), 
  d = p, a = p, b = p-p, c;

    for(int i = 0; i<99; i++) {
        c = p; c.z += iGlobalTime * 5.;
        n
        n
        n
        a += (1. - a) * b.x * abs(p.y) / 4e2;
        p += d;
    }
    gl_FragColor = vec4(1. - a*a,1);
}

