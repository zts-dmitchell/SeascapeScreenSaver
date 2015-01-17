//
//  ShaderToyRenderer.m
//  SeascapeScreenSaver
//
//  Created by David Mitchell on 1/15/15.
//  Copyright (c) 2015 David Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShaderToyRenderer.h"
#import "ShaderTexture.h"
#import "ShaderUtil.h"
#import "ImageLoader.h"
#import "GLUtil.h"

#import <AppKit/AppKit.h>


// Attribute index.
enum {
    ATTRIB_VERTEX,
};

@interface ShaderToyRenderer(PrivateMethods)
- (BOOL) setupTextures;
@end

@implementation ShaderToyRenderer


-(instancetype) initWithShaderName:(NSString*) shader andShaderTextures:(NSArray*) arrayOfTextureFiles {
    
    if((self = [super init])) {
        
        m_program = [ShaderUtil loadShaders:shader
                             andFragmentExt:@"fsh"
                             withAttributes:self];
        
        if( ! m_program ) {
            
            self = nil;
            return nil;
        }
        
        self.shaderTextures = [[ShaderTexture alloc] initWithArrayOfTextureFiles:arrayOfTextureFiles];
        
        m_bIsLoaded = false;
        
        glUseProgram(m_program);
        
        [self createVBO];
        
        [self.shaderTextures prepareTextures:m_program];
        
        glUseProgram(0);
    }
    
    return self;
}

- (void) dealloc {
    
    [self destroyVBO];
    
    [ShaderUtil cleanup:m_program];
    
    NSLog(@"ShaderToyRenderer going away ...");
}

- (NSString*) name {
    return @"ShaderToy";
}

- (void)setFrameSize:(NSSize)newSize {
    
    m_bIsLoaded = false;
    
    m_iResolution.x = newSize.width;
    m_iResolution.y = newSize.height;
    
    NSLog(@"Setting frame size: %f w by %f h", newSize.width, newSize.height);
}

- (void)render {
    
    glClearColor(.01, .01, .01, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glUseProgram(m_program);
    
    glBindBuffer(GL_ARRAY_BUFFER, m_buffers.VertexBuffer);
    glVertexAttribPointer(m_attributes.pos, 2, GL_FLOAT, GL_FALSE, 0, 0);
    glEnableVertexAttribArray(m_attributes.pos);
    
    //////////////////////////////////////////
    // Other uniform stuff
    m_iGlobalTime += 0.08;
    glUniform1f(m_uniforms.iGlobalTimeHandle, m_iGlobalTime); printOpenGLError();
    
    [self.shaderTextures render];
    
    if( !m_bIsLoaded ) {
        
        m_bIsLoaded = true;
        
        glUniform3f(m_uniforms.iResolutionHandle, m_iResolution.x, m_iResolution.y, m_iResolution.z); printOpenGLError();
        glUniform2f(m_uniforms.iMouseHandle, m_iMouse.x, m_iMouse.y);
    }
    
    glDrawArrays(GL_TRIANGLES, 0, 6);  printOpenGLError();
    glDisableVertexAttribArray(m_attributes.pos);  printOpenGLError();
    
    glUseProgram(0);
}

/////////////////////////////////////////
// Protocol Implementations
- (void) setProgram: (GLuint) newProgram {
    
    m_bIsLoaded = false;
    
    m_program = newProgram;
}

- (GLuint) bindAttributes {
    
    if( m_program < 1 )
    {
        NSLog(@"Error: program variable not set. Make sure the context has been set.");
        return GL_INVALID_VALUE;
    }
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(m_program, ATTRIB_VERTEX, "pos");
    
    return 0;
}

- (GLuint) setPostLinkUniforms {
    
    if( m_program < 1 ) {
        NSLog(@"Error: program variable not set");
        return GL_INVALID_VALUE;
    }
    
    m_attributes.pos = glGetAttribLocation(m_program, "pos");
    
    if( m_attributes.pos == -1 )
        NSLog(@"Failed to get attribute location for 'pos'");
    
    m_uniforms.iGlobalTimeHandle = glGetUniformLocation(m_program, "iGlobalTime");
    m_uniforms.iResolutionHandle = glGetUniformLocation(m_program, "iResolution");
    m_uniforms.iMouseHandle      = glGetUniformLocation(m_program, "iMouse");
    
    return GL_NO_ERROR;
}

#pragma mark VBO Stuff

-(void) createVBO {
    
    NSLog(@"Creating VBO");
    
    if(m_buffers.VertexBuffer != -1) {
        [self destroyVBO];
    }
    
    const GLfloat vertices[] =
    { -1.0, -1.0,   1.0, -1.0,   -1.0,  1.0,
        1.0, -1.0,   1.0,  1.0,   -1.0,  1.0 };
    
    // Gen
    // Bind
    // Buffer
    glGenBuffers(1, &m_buffers.VertexBuffer); // size, 1, and pointer
    glBindBuffer(GL_ARRAY_BUFFER, m_buffers.VertexBuffer);  printOpenGLError();
    glBufferData(GL_ARRAY_BUFFER, 12 * sizeof(GLfloat),
                 vertices, GL_STATIC_DRAW);  printOpenGLError();
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

-(void) destroyVBO {
    
    m_bIsLoaded = false;
    
    NSLog(@"Destroying VBO");
    
    if(m_buffers.VertexBuffer != -1) {
        
        glDeleteBuffers(1, &m_buffers.VertexBuffer);
        m_buffers.VertexBuffer = -1;
    }
}

@end
