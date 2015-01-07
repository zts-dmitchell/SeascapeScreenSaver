//
//  MountainsRenderer.h
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
}Buffers;

typedef struct UniformHandles {
    GLint Sampler;
}UniformHandles;

typedef struct AttributeHandles {
    GLint Position;
    GLint TextureCoord;
}AttributeHandles;


@interface MountainsRenderer : NSObject <ESRenderer, Attributes>
{
@private
    GLuint program;
    GLuint m_texture;
    Buffers m_buffers;
    UniformHandles m_uniforms;
    AttributeHandles m_attributes;
    
    NSSize m_screenSize;
    float percentageX;
    float percentageY;
}

@end
