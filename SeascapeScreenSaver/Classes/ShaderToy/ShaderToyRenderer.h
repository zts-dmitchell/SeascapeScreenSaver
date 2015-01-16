//
//  ShaderToyRenderer.h
//  SeascapeScreenSaver
//
//  Created by David Mitchell on 1/15/15.
//  Copyright (c) 2015 David Mitchell. All rights reserved.
//

#ifndef SeascapeScreenSaver_ShaderToyRenderer_h
#define SeascapeScreenSaver_ShaderToyRenderer_h
#import <OpenGL/gl.h>
#import "ESRenderer.h"
#import "Attributes.h"
#import "ShaderTexture.h"

typedef struct ShaderToyBuffers {
    GLuint VertexBuffer;
}ShaderToyBuffers;

typedef struct ShaderToyUniformHandles {
    GLint iMouseHandle;
    GLint iGlobalTimeHandle;
    GLint iResolutionHandle;
}ShaderToyUniformHandles;

typedef struct ShaderToyAttributeHandles {
    GLint pos;
}ShaderToyAttributeHandles;

typedef struct ShaderToyVec2 {
    GLfloat x;
    GLfloat y;
}ShaderToyVec2;

typedef struct ShaderToyVec3 {
    GLfloat x;
    GLfloat y;
    GLfloat z;
}ShaderToyVec3;

@interface ShaderToyRenderer : NSObject <ESRenderer, Attributes>
{
@private
    GLuint m_program;
    ShaderToyBuffers m_buffers;
    ShaderToyUniformHandles m_uniforms;
    ShaderToyAttributeHandles m_attributes;
    GLfloat m_iGlobalTime;
    ShaderToyVec2  m_iMouse;
    ShaderToyVec3  m_iResolution;
    
    bool m_bIsLoaded;
}

@property (nonatomic, strong) ShaderTexture* shaderTextures;

@end


#endif
