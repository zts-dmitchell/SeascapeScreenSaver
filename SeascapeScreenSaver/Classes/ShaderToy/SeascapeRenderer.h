//
//  SeascapeRenderer.h
//  Seascape
//
//  Created by David Mitchell on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Renderer.h"
#import "ShaderUtil.h"

typedef struct SeascapeVec2 {
    GLfloat x;
    GLfloat y;
}SeascapeVec2;

typedef struct SeascapeVec3 {
    GLfloat x;
    GLfloat y;
    GLfloat z;
}SeascapeVec3;

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

@interface SeascapeRenderer : NSObject <Renderer, Attributes>
{
@private
    GLuint program;
    SeascapeBuffers m_buffers;
    SeascapeUniformHandles m_uniforms;
    SeascapeAttributeHandles m_attributes;
    
    GLfloat m_u_iGlobalTime;
    SeascapeVec3  m_u_iResolution;
    SeascapeVec3 m_a_pos;
    GLfloat m_u_iSeaChoppy;
    GLfloat m_u_iSeaHeight;
    GLfloat m_u_iSpeed;
}

@end
