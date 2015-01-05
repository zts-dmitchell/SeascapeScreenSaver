//
//  SeascapeRenderer.mm
//  Earth Wobbler
//
//  Created by David Mitchell on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SeascapeRenderer.h"
#import "ShaderUtil.h"
#import "GLUtil.h"

// Attribute index.
enum {
    ATTRIB_POSITION
};

@interface SeascapeRenderer(PrivateMethods)
@end

@implementation SeascapeRenderer

- (id)init
{
    if ((self = [super init]))
    {
        program = [ShaderUtil loadShaders:@"SeascapeVertexShader"
                            withVertexExt:@"vsh"
                        andFragmentShader:@"SeascapeFragmentShader"
                           andFragmentExt:@"fsh"
                           withAttributes:self];
        
        if( ! program )
        {
            self = nil;
            return nil;
        }
        
        m_u_iResolution.x = 320;
        m_u_iResolution.y = 568;
        m_buffers.VertexBuffer = -1;
        m_u_iSeaChoppy = 4.0;
        m_u_iSeaHeight = 0.6;
        m_u_iSpeed = 10.0;
        
        
        glUseProgram(program);
        
        [self createVBO];
        
        glUseProgram(0);
    }
    
    return self;
}

- (void) dealloc
{
    [self destroyVBO];
    [ShaderUtil cleanup:program];
    
    NSLog(@"SeascapeRenderer going away ...");
}

- (void)setFrameSize:(NSSize)newSize {
    
    m_u_iResolution.x = newSize.width;
    m_u_iResolution.y = newSize.height;
    m_u_iResolution.z =   1.0;
}

- (void)render
{
    glClearColor(0.09765625f, 0.09765625f, 0.2375f, 1.0f);
    //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glClear(GL_COLOR_BUFFER_BIT);

    glUseProgram(program);
    
    glBindBuffer(GL_ARRAY_BUFFER, m_buffers.VertexBuffer);
    glVertexAttribPointer(m_attributes.m_a_posHandle, 2, GL_FLOAT, GL_FALSE, 0, 0);
    glEnableVertexAttribArray(m_attributes.m_a_posHandle);
    
    //////////////////////////////////////////
    // Other uniform stuff
    // Set resolution, first!!
    glUniform3f(m_uniforms.m_u_iResolutionHandle, m_u_iResolution.x, m_u_iResolution.y, m_u_iResolution.z); printOpenGLError();
    
    m_u_iGlobalTime += 0.01;
    glUniform1f(m_uniforms.m_u_iGlobalTimeHandle, m_u_iGlobalTime); printOpenGLError();
    
    glUniform1f(m_uniforms.m_u_iSeaChoppyHandle, m_u_iSeaChoppy);
    glUniform1f(m_uniforms.m_u_iSeaHeightHandle, m_u_iSeaHeight);
    glUniform1f(m_uniforms.m_u_iSpeedHandle, m_u_iSpeed);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);  printOpenGLError();
    glDisableVertexAttribArray(m_attributes.m_a_posHandle);  printOpenGLError();
    
    glUseProgram(0);
    
}

/////////////////////////////////////////
// Protocol Implementations
- (void) setProgram: (GLuint) newProgram
{
    program = newProgram;
}
    
- (GLuint) bindAttributes
{
    if( program < 1 )
    {
        NSLog(@"Error: program variable not set");
        return GL_INVALID_VALUE;
    }
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(program, ATTRIB_POSITION, "pos");
    
    return 0;
}

- (GLuint) setPostLinkUniforms
{
    if( program < 1 )
    {
        NSLog(@"Error: program variable not set");
        return GL_INVALID_VALUE;
    }
        
    m_attributes.m_a_posHandle = glGetAttribLocation(program, "pos");
    
    if( m_attributes.m_a_posHandle == -1 )
        NSLog(@"Failed to get attribute location for 'pos'");

    m_uniforms.m_u_iGlobalTimeHandle = glGetUniformLocation(program, "iGlobalTime");
    
    if( m_uniforms.m_u_iGlobalTimeHandle == -1 )
        NSLog(@"Failed to get uniform location for 'iGlobalTime'" );
    
    m_uniforms.m_u_iResolutionHandle = glGetUniformLocation(program, "iResolution");
    
    if( m_uniforms.m_u_iResolutionHandle == -1 )
        NSLog(@"Failed to get uniform location for 'iResolution'");
    
    m_uniforms.m_u_iSeaChoppyHandle = glGetUniformLocation(program, "iSeaChoppy");
    m_uniforms.m_u_iSeaHeightHandle = glGetUniformLocation(program, "iSeaHeight");
    m_uniforms.m_u_iSpeedHandle = glGetUniformLocation(program, "iSpeed");
    
    return GL_NO_ERROR;
}

#pragma mark VBO Stuff
-(void) createVBO {


    if(m_buffers.VertexBuffer != -1) {
        [self destroyVBO];
    }
    
    GLfloat vertices[] = { -1.0, -1.0,   1.0, -1.0,   -1.0,  1.0,
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
 
    if(m_buffers.VertexBuffer != -1) {
        
        glDeleteBuffers(1, &m_buffers.VertexBuffer);
        m_buffers.VertexBuffer = -1;
    }
}

@end
