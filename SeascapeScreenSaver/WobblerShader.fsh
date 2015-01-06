//
//  WobblerShader.fsh
//  Wobbler
//
//  Created by David Mitchell on 2/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#ifdef GL_ES
    precision mediump float;
#endif

// Constants
const float C_PI    = 3.1415;
const float C_2PI   = 2.0 * C_PI;
const float C_2PI_I = 1.0 / (2.0 * C_PI);
const float C_PI_2  = C_PI / 2.0;

uniform sampler2D Sampler;
uniform float StartRad;
uniform vec2 Percentage;

varying vec2 v_texCoord;
varying float LightIntensity;

// Experimental
varying vec3 vVaryingNormal;
varying vec3 vVaryingLightDir;

void main()
{
    vec2 Freq = vec2(8.0, 8.0);
    vec2 Amplitude = vec2(0.05, 0.05);
    

    vec2  perturb;
    float rad;
    vec4  color;

    // Compute a perturbation factor for the x-direction
    rad = (v_texCoord.s + v_texCoord.t - 1.0 + StartRad) * Freq.x;

    // Wrap to -2.0*PI, 2*PI
    rad = rad * C_2PI_I;
    rad = fract(rad);
    rad = rad * C_2PI;

    // Center in -PI, PI
    if (rad >  C_PI) rad = rad - C_2PI;
    if (rad < -C_PI) rad = rad + C_2PI;

    // Center in -PI/2, PI/2
    if (rad >  C_PI_2) rad =  C_PI - rad;
    if (rad < -C_PI_2) rad = -C_PI - rad;

    perturb.x  = (rad - (rad * rad * rad / 6.0)) * Amplitude.x;

    // Now compute a perturbation factor for the y-direction
    rad = (v_texCoord.s - v_texCoord.t + StartRad) * Freq.y;

    // Wrap to -2*PI, 2*PI
    rad = rad * C_2PI_I;
    rad = fract(rad);
    rad = rad * C_2PI;

    // Center in -PI, PI
    if (rad >  C_PI) rad = rad - C_2PI;
    if (rad < -C_PI) rad = rad + C_2PI;

    // Center in -PI/2, PI/2
    if (rad >  C_PI_2) rad =  C_PI - rad;
    if (rad < -C_PI_2) rad = -C_PI - rad;

    perturb.y = (rad - (rad * rad * rad / 6.0)) * Amplitude.y;

    // Experimental
    vec4 AmbientMaterial = vec4(0.25, 0.25, 0.45, 1.0);
    vec4 DiffuseMaterial = vec4(0.2, 0.21, 0.21, 1.0);
    vec4 SpecularMaterial = vec4(0.210, 0.210, 0.210, 1.0);
    
    vec3 normalizedNormal = normalize(vVaryingNormal);
    
    float diff = max(0.0, dot(normalizedNormal,
                              normalize(vVaryingLightDir)));    

    gl_FragColor = diff * DiffuseMaterial;
    
    gl_FragColor += AmbientMaterial;
    
    perturb.x *= Percentage.x;
    perturb.y *= Percentage.y;

    color = texture2D(Sampler, perturb + v_texCoord.st);

    gl_FragColor *= texture2D(Sampler, perturb + v_texCoord.st);
    
    // Specular Light
    vec3 vReflection = normalize(reflect(-normalize(vVaryingLightDir),
                         normalizedNormal));
                
    float spec = max(0.0, dot(normalizedNormal, vReflection));
    
    if( diff != 0.0 )
    {
        float fSpec = pow(spec, 1.20);
        gl_FragColor.rgb += vec3(fSpec, fSpec, fSpec);
    }
    
}
