//
//  WobblerRenderer.h
//  Wobbler
//
//  Created by David Mitchell on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "ESRenderer.h"
#include "ShaderUtil.h"

typedef struct Buffers {
    GLuint VertexBuffer;
    GLuint NormalBuffer;
    GLuint TexCoordBuffer;
    GLuint IndexBuffer;
    int IndexCount;
}Buffers;

typedef struct UniformHandles {
    GLuint Modelview;
    GLuint Projection;
    GLuint NormalMatrix;
    GLuint LightPosition;
    GLint AmbientMaterial;
    GLint SpecularMaterial;
    GLint Shininess;
    GLint Sampler;
    GLint StartRad;
    GLuint Percentage;
    
}UniformHandles;

typedef struct AttributeHandles {
    GLint Position;
    GLint Normal;
    GLint DiffuseMaterial;
    GLint TextureCoord;
}AttributeHandles;

/* Parameter */
typedef struct _Parameter {
	float current [4];
	float min     [4];
	float max     [4];
	float delta   [4];
	
} Parameter;

/* Macros */
#define PARAMETER_CURRENT(p)    (p.current)
#define PARAMETER_ANIMATE(p)    ({ int i; for (i = 0; i < 4; i ++) { \
    p.current[i] += p.delta[i]; \
    if ((p.current[i] < p.min[i]) || (p.current[i] > p.max[i])) \
        p.delta[i] = -p.delta[i]; } } )

@interface WobblerRenderer : NSObject <ESRenderer, Attributes>
{
@private
    GLuint program;
    GLuint m_texture;
    Buffers m_buffers;
    UniformHandles m_uniforms;
    AttributeHandles m_attributes;
    
    Parameter StartRad;
    NSSize m_screenSize;
}

@end
