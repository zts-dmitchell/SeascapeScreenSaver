//
//  MusicPiratesRenderer.h
//  Wobbler
//
//  Created by David Mitchell on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ESRenderer.h"
#import "ShaderUtil.h"
#import "ShaderTexture.h"

typedef struct MusicPiratesBuffers {
    GLuint VertexBuffer;
}MusicPiratesBuffers;

typedef struct MusicPiratesUniformHandles {
    GLint iMouseHandle;
    GLint iGlobalTimeHandle;
    GLint iResolutionHandle;
    GLint iChannel0Handle;
    GLint iChannel1Handle;
}MusicPiratesUniformHandles;

typedef struct MusicPiratesAttributeHandles {
    GLint pos;
}MusicPiratesAttributeHandles;

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

@interface MusicPiratesRenderer : NSObject <ESRenderer, Attributes>
{
@private
    GLuint m_program;
    MusicPiratesBuffers m_buffers;
    MusicPiratesUniformHandles m_uniforms;
    MusicPiratesAttributeHandles m_attributes;
    MountainTextures m_textures;
    GLfloat m_iGlobalTime;
    MountainVec2  m_iMouse;
    MountainVec3  m_iResolution;
    bool m_bIsLoaded;
}

@property (nonatomic, strong) ShaderTexture* shaderTextures;
@end
