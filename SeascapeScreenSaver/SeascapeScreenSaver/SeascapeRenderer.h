//
//  SeascapeRenderer.h
//  Seascape
//
//  Created by David Mitchell on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ESRenderer.h"
#import "ShaderUtil.h"

typedef struct vec2 {
    GLfloat x;
    GLfloat y;
}vec2;

typedef struct vec3 {
    GLfloat x;
    GLfloat y;
    GLfloat z;
}vec3;

typedef struct SeascapeBuffers {
    GLuint VertexBuffer;
}SeascapeBuffers;

typedef struct SeascapeUniformHandles {
    GLint m_u_iGlobalTimeHandle;
    GLint m_u_iResolutionHandle;
    GLint m_u_iSeaHeightHandle;
    GLint m_u_iSeaChoppyHandle; // 0 to 4;
    GLint m_u_iSpeedHandle;
}SeascapeUniformHandles;

typedef struct SeascapeAttributeHandles {
    GLint m_a_posHandle;
}SeascapeAttributeHandles;

@interface SeascapeRenderer : NSObject <ESRenderer, Attributes>
{
@private
    GLuint program;
    SeascapeBuffers m_buffers;
    SeascapeUniformHandles m_uniforms;
    SeascapeAttributeHandles m_attributes;
    
    GLfloat m_u_iGlobalTime;
    vec3  m_u_iResolution;
    vec2 m_a_pos;
    GLfloat m_u_iSeaChoppy;
    GLfloat m_u_iSeaHeight;
    GLfloat m_u_iSpeed;
}

@end
