//
//  MountainsRenderer.h
//  Wobbler
//
//  Created by David Mitchell on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "Renderer.h"
#include "ShaderUtil.h"

typedef struct MountainsBuffers {
    GLuint VertexBuffer;
}MountainsBuffers;

typedef struct MountainsUniformHandles {
    GLint iMouseHandle;
    GLint iGlobalTimeHandle;
    GLint iResolutionHandle;
    GLint iChannel0Handle;
    GLint iChannel1Handle;
}MountainsUniformHandles;

typedef struct MountainsAttributeHandles {
    GLint pos;
}MountainsAttributeHandles;

typedef struct MountainTexture {
    GLuint m_iChannel0;
    GLuint m_iChannel1;
}MountainTextures;

typedef struct MountainVec2 {
    GLfloat x;
    GLfloat y;
}MountainVec2;

typedef struct MountainVec3 {
    GLfloat x;
    GLfloat y;
    GLfloat z;
}MountainVec3;

@interface MountainsRenderer : NSObject <Renderer, Attributes>
{
@private
    GLuint m_program;
    MountainsBuffers m_buffers;
    MountainsUniformHandles m_uniforms;
    MountainsAttributeHandles m_attributes;
    MountainTextures m_textures;
    GLfloat m_iGlobalTime;
    MountainVec2  m_iMouse;
    MountainVec3  m_iResolution;
    bool m_bIsLoaded;
}

@end
