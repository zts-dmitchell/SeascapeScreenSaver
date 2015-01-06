//
//  Shader.vsh
//  Earth Wobbler
//
//  Created by David Mitchell on 2/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#ifdef GL_ES
precision highp float;
#endif


uniform mat4 Projection;
uniform mat4 Modelview;
uniform mat3 Normal;

attribute vec3 vNormal;
attribute vec4 vTexCoord;
attribute vec4 vPosition;

varying vec2 v_texCoord;

varying float LightIntensity;
//uniform vec3 LightPosition;

const float specularContribution = 0.1;
const float diffuseContribution  = 1.0 - specularContribution;

// Experimental
varying vec3 vVaryingNormal;
varying vec3 vVaryingLightDir;
//varying vec3 vVaryingViewVec;

void main(void)
{
    vec3 LightPosition  = vec3( 0.01, 0.0, 0.001);
    vec3 ecPosition     = vec3 (Projection * Modelview * vPosition);
    
    /*
    vec3 transNormal    = normalize(Normal * vNormal);
    vec3 lightVec       = normalize(LightPosition - ecPosition);
    vec3 reflectVec     = reflect(-lightVec, transNormal.xyz);
    vec3 viewVec        = normalize(-ecPosition);

    float spec          = clamp(dot(reflectVec, viewVec), 0.0, 1.0);
    spec                = pow(spec, 16.0);

    LightIntensity      = diffuseContribution *
                            max(dot(lightVec, transNormal.xyz), 0.0)
                            + specularContribution * spec;
    */
    vVaryingNormal      = Normal * vNormal;
    vVaryingLightDir    = normalize(LightPosition);
    //vVaryingViewVec     = ecPosition - 
    
    v_texCoord          = vTexCoord.st;
    gl_Position         = Projection * Modelview * vPosition;
}
