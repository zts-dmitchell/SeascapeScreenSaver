//
//  SymmetricOriginsRenderer.h
//  SymmetricOrigins
//
//  Created by David Mitchell on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ESRenderer.h"
#import "ShaderUtil.h"

typedef struct SymmetricOriginsVec2 {
    GLfloat x;
    GLfloat y;
}SymmetricOriginsVec2;

typedef struct SymmetricOriginsVec3 {
    GLfloat x;
    GLfloat y;
    GLfloat z;
}SymmetricOriginsVec3;

typedef struct SymmetricOriginsBuffers {
    GLuint VertexBuffer;
}SymmetricOriginsBuffers;

typedef struct SymmetricOriginsUniformHandles {
    GLint m_u_iGlobalTimeHandle;
    GLint m_u_iResolutionHandle;
    GLint iMouseHandle;
}SymmetricOriginsUniformHandles;

typedef struct SymmetricOriginsAttributeHandles {
    GLint m_a_posHandle;
}SymmetricOriginsAttributeHandles;

@interface SymmetricOriginsRenderer : NSObject <ESRenderer, Attributes>
{
@private
    GLuint program;
    SymmetricOriginsBuffers m_buffers;
    SymmetricOriginsUniformHandles m_uniforms;
    SymmetricOriginsAttributeHandles m_attributes;
    
    GLfloat m_u_iGlobalTime;
    SymmetricOriginsVec3  m_u_iResolution;
    SymmetricOriginsVec3 m_a_pos;
    SymmetricOriginsVec2  m_iMouse;

}

@end
