//
//  MountainsRenderer.mm
//  Wobbler
//
//  Created by David Mitchell on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "MountainsRenderer.h"
#include "ShaderUtil.h"
#import "ImageLoader.h"

#import <AppKit/AppKit.h>

#include "GLUtil.h"

// Attribute index.
enum {
    ATTRIB_VERTEX,
//    ATTRIB_TEXCOORD,
};

@interface MountainsRenderer(PrivateMethods)
- (BOOL) setupTextures;
@end

@implementation MountainsRenderer

- (id)init
{
    if ((self = [super init]))
    {
        program = [ShaderUtil loadShaders:@"Mountains"
                            withVertexExt:@"vsh"
                        andFragmentShader:@"Mountains"
                           andFragmentExt:@"fsh"
                           withAttributes:self];

        if( ! program )
        {
            self = nil;
            return nil;
        }
        
        m_buffers.VertexBuffer = -1;
        m_iGlobalTime = 0.0;
        m_iMouse.x = m_iMouse.y = 100;
        
        glUseProgram(program);
        
        //glEnable(GL_TEXTURE_2D);
        [self createVBO];
        
        [self setupTextures];
        
        glUseProgram(0);
    }
    
    return self;
}

- (void) dealloc
{
    glDeleteTextures(1, &m_textures.m_iChannel0);
    glDeleteTextures(1, &m_textures.m_iChannel1);
    
    [self destroyVBO];

    [ShaderUtil cleanup:program];
    
    NSLog(@"MountainsRenderer going away ...");
}

- (NSString*) name {
    return @"Mountains";
}

- (void)setFrameSize:(NSSize)newSize {
    
    m_iResolution.x = newSize.width;
    m_iResolution.y = newSize.height;
    
    NSLog(@"Setting frame size: %f w by %f h", newSize.width, newSize.height);
}

- (void)render
{
    glClearColor(.01, .01, .01, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    glUseProgram(program);
    
    //glEnableVertexAttribArray(ATTRIB_TEXCOORD);
    
    glBindBuffer(GL_ARRAY_BUFFER, m_buffers.VertexBuffer);
    glVertexAttribPointer(m_attributes.pos, 2, GL_FLOAT, GL_FALSE, 0, 0);
    glEnableVertexAttribArray(m_attributes.pos);
    
    //////////////////////////////////////////
    // Other uniform stuff
    // Set resolution, first!!
    glUniform3f(m_uniforms.iResolutionHandle, m_iResolution.x, m_iResolution.y, m_iResolution.z); printOpenGLError();
    
    m_iGlobalTime += 0.01;
    glUniform1f(m_uniforms.iGlobalTimeHandle, m_iGlobalTime); printOpenGLError();
    
    //glBindBuffer(GL_ARRAY_BUFFER, m_buffers.TexCoordBuffer);
    //glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, 0, 0);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, m_textures.m_iChannel0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, m_textures.m_iChannel1);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);  printOpenGLError();
    glDisableVertexAttribArray(m_attributes.pos);  printOpenGLError();

    glDisableVertexAttribArray(ATTRIB_VERTEX);

    glUseProgram(0);    
}

- (BOOL) setupTextures
{
    NSBundle *bundle;
    NSString * iChannel0Str, *iChannel1Str;
    NSBitmapImageRep *bitmapimagerep0, *bitmapimagerep1;
    NSRect rect;
    
    bundle = [NSBundle bundleForClass: [self class]];
    
    iChannel0Str = [bundle pathForResource: @"Day" ofType: @"jpg"];
    iChannel1Str = [bundle pathForResource: @"Day" ofType: @"jpg"];
    
    if( iChannel0Str == nil )
    {
        NSLog(@"Unable to load first image file." );
        return false;
    } else if( iChannel1Str == nil) {
        NSLog(@"Unable to load second image file." );
        return false;
    } else {
        bitmapimagerep0 = LoadImage(iChannel0Str, 0    );
        
        if( bitmapimagerep0 == nil ) {
            NSLog(@"Unable to load first image file: %@", iChannel0Str );
            return false;
        }
        
        bitmapimagerep1 = LoadImage(iChannel1Str, 0);
        
        if( bitmapimagerep1 == nil ) {
            NSLog(@"Unable to load second image file: %@", iChannel1Str );
            return false;
        }
    }
    
    rect = NSMakeRect(0, 0, [bitmapimagerep0 pixelsWide], [bitmapimagerep0 pixelsHigh]);
    
    /* Channel 0 Texture */
    glActiveTexture(GL_TEXTURE0);
    
    // Load the texture
    glGenTextures(1, &m_textures.m_iChannel0);
    glBindTexture(GL_TEXTURE_2D, m_textures.m_iChannel0);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, rect.size.width, rect.size.height, 0,
                 (([bitmapimagerep0 hasAlpha])?(GL_RGBA):(GL_RGB)), GL_UNSIGNED_BYTE,
                 [bitmapimagerep0 bitmapData]);

    rect = NSMakeRect(0, 0, [bitmapimagerep1 pixelsWide], [bitmapimagerep1 pixelsHigh]);
    
    /* Channel 1 Texture */
    glActiveTexture(GL_TEXTURE1);
    
    // Load the texture
    glGenTextures(1, &m_textures.m_iChannel1);
    glBindTexture(GL_TEXTURE_2D, m_textures.m_iChannel1);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, rect.size.width, rect.size.height, 0,
                 (([bitmapimagerep1 hasAlpha])?(GL_RGBA):(GL_RGB)), GL_UNSIGNED_BYTE,
                 [bitmapimagerep1 bitmapData]);

    return true;
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
        NSLog(@"Error: program variable not set. Make sure the context has been set.");
        return GL_INVALID_VALUE;
    }
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(program, ATTRIB_VERTEX, "pos");
    //glBindAttribLocation(program, ATTRIB_TEXCOORD, "vTexCoord");
    
    return 0;
}

- (GLuint) setPostLinkUniforms
{
    if( program < 1 )
    {
        NSLog(@"Error: program variable not set");
        return GL_INVALID_VALUE;
    }
        
    m_attributes.pos = glGetAttribLocation(program, "pos");
    
    if( m_attributes.pos == -1 )
        NSLog(@"Failed to get attribute location for 'pos'");

    //m_attributes.TextureCoord = glGetAttribLocation(program, "vTexCoord");
    
    //if( m_attributes.TextureCoord == -1 )
    //    NSLog(@"Failed to get attribue location for vTexCoord");
    
    m_uniforms.iGlobalTimeHandle = glGetUniformLocation(program, "iGlobalTime");
    m_uniforms.iResolutionHandle = glGetUniformLocation(program, "iResolution");
    
    m_uniforms.iChannel0Handle = glGetUniformLocation(program, "iChannel0");
    
    if( m_uniforms.iChannel0Handle == -1 )
        NSLog(@"Failed to get uniform location for 'iChannel0'");
    
    m_uniforms.iChannel1Handle = glGetUniformLocation(program, "iChannel1");
    
    if( m_uniforms.iChannel1Handle == -1 )
        NSLog(@"Failed to get uniform location for 'iChannel1'");
    

    return GL_NO_ERROR;
}

#pragma mark VBO Stuff

-(void) createVBO {
    
    NSLog(@"Creating VBO");
    
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
    
    NSLog(@"Destroying VBO");
    
    if(m_buffers.VertexBuffer != -1) {
        
        glDeleteBuffers(1, &m_buffers.VertexBuffer);
        m_buffers.VertexBuffer = -1;
    }
}

@end
