//
//  MorningCityRenderer.h
//  MorningCity
//
//  Created by David Mitchell on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Renderer.h"
#import "ShaderUtil.h"

typedef struct MorningCityVec2 {
    GLfloat x;
    GLfloat y;
}MorningCityVec2;

typedef struct MorningCityVec3 {
    GLfloat x;
    GLfloat y;
    GLfloat z;
}MorningCityVec3;

typedef struct MorningCityBuffers {
    GLuint VertexBuffer;
}MorningCityBuffers;

typedef struct MorningCityUniformHandles {
    GLint m_u_iGlobalTimeHandle;
    GLint m_u_iResolutionHandle;
    GLint iMouseHandle;
}MorningCityUniformHandles;

typedef struct MorningCityAttributeHandles {
    GLint m_a_posHandle;
}MorningCityAttributeHandles;

@interface MorningCityRenderer : NSObject <Renderer, Attributes>
{
@private
    GLuint program;
    MorningCityBuffers m_buffers;
    MorningCityUniformHandles m_uniforms;
    MorningCityAttributeHandles m_attributes;
    
    GLfloat m_u_iGlobalTime;
    MorningCityVec3  m_u_iResolution;
    MorningCityVec3 m_a_pos;
    MorningCityVec2  m_iMouse;

}

@end
