//
//  SomewhereIn1993Renderer.h
//  SomewhereIn1993
//
//  Created by David Mitchell on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Renderer.h"
#import "ShaderUtil.h"

typedef struct SomewhereIn1993Vec2 {
    GLfloat x;
    GLfloat y;
}SomewhereIn1993Vec2;

typedef struct SomewhereIn1993Vec3 {
    GLfloat x;
    GLfloat y;
    GLfloat z;
}SomewhereIn1993Vec3;

typedef struct SomewhereIn1993Buffers {
    GLuint VertexBuffer;
}SomewhereIn1993Buffers;

typedef struct SomewhereIn1993UniformHandles {
    GLint m_u_iGlobalTimeHandle;
    GLint m_u_iResolutionHandle;
    GLint iMouseHandle;
}SomewhereIn1993UniformHandles;

typedef struct SomewhereIn1993AttributeHandles {
    GLint m_a_posHandle;
}SomewhereIn1993AttributeHandles;

@interface SomewhereIn1993Renderer : NSObject <Renderer, Attributes>
{
@private
    GLuint program;
    SomewhereIn1993Buffers m_buffers;
    SomewhereIn1993UniformHandles m_uniforms;
    SomewhereIn1993AttributeHandles m_attributes;
    
    GLfloat m_u_iGlobalTime;
    SomewhereIn1993Vec3  m_u_iResolution;
    SomewhereIn1993Vec3 m_a_pos;
    SomewhereIn1993Vec2  m_iMouse;

}

@end
