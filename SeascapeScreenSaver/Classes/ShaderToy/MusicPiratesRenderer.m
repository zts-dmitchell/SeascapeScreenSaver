//
//  MusicPiratesRenderer.m
//
//  Created by David Mitchell on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MusicPiratesRenderer.h"
#import "ShaderUtil.h"
#import "ImageLoader.h"
#import "GLUtil.h"

#import <AppKit/AppKit.h>

// Attribute index.
enum {
    ATTRIB_VERTEX,
};

@interface MusicPiratesRenderer(PrivateMethods)
- (BOOL) setupTextures;
@end

@implementation MusicPiratesRenderer

- (id)init {
    
    if ((self = [super init])) {
        
        m_program = [ShaderUtil loadShaders:@"MusicPirates"
                             andFragmentExt:@"fsh"
                             withAttributes:self];

        if( ! m_program ) {
            
            self = nil;
            return nil;
        }
        
        self.shaderTextures = [[ShaderTexture alloc] init];
        
        m_buffers.VertexBuffer = -1;
        m_iGlobalTime = 0.0;
        m_iMouse.x = m_iMouse.y = 3;
        m_bIsLoaded = false;
        
        glUseProgram(m_program);
        
        [self createVBO];
        
        [self setupTextures];
        
        glUseProgram(0);
    }
    
    return self;
}

- (void) dealloc {
    
//    glDeleteTextures(1, &m_textures.m_iChannel0);
//    glDeleteTextures(1, &m_textures.m_iChannel1);
    
    m_textures.m_iChannel0 = m_textures.m_iChannel1 = -1;
    
    [self destroyVBO];

    [ShaderUtil cleanup:m_program];
    
    NSLog(@"MusicPiratesRenderer going away ...");
}

- (NSString*) name {
    return @"MusicPirates";
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
    m_iGlobalTime += 0.1;
    glUniform1f(m_uniforms.iGlobalTimeHandle, m_iGlobalTime); printOpenGLError();
    
    [self.shaderTextures render];
    
    if( !m_bIsLoaded ) {
       
        m_bIsLoaded = true;
        
        glUniform3f(m_uniforms.iResolutionHandle, m_iResolution.x, m_iResolution.y, m_iResolution.z); printOpenGLError();
        glUniform2f(m_uniforms.iMouseHandle, m_iMouse.x, m_iMouse.y);
    
//        // Textures
//        glActiveTexture(GL_TEXTURE0);
//        glBindTexture(GL_TEXTURE_2D, m_textures.m_iChannel0);
//
//        glActiveTexture(GL_TEXTURE1);
//        glBindTexture(GL_TEXTURE_2D, m_textures.m_iChannel1);
    }
    
    glDrawArrays(GL_TRIANGLES, 0, 6);  printOpenGLError();
    glDisableVertexAttribArray(m_attributes.pos);  printOpenGLError();

    glBindTexture(GL_TEXTURE_2D, 0);

    glUseProgram(0);
}

- (BOOL) setupTextures {
    
    [self.shaderTextures addTexture:@"tex03" ofType:@"jpg"];
    [self.shaderTextures addTexture:@"Day" ofType:@"jpg"];
    
    [self.shaderTextures prepareTextures:m_program];
    
//    NSBundle *bundle;
//    NSString * iChannel0Str, *iChannel1Str;
//    NSBitmapImageRep *bitmapimagerep0, *bitmapimagerep1;
//    NSRect rect;
//    
//    bundle = [NSBundle bundleForClass: [self class]];
//    
//    iChannel0Str = [bundle pathForResource: @"tex03" ofType: @"jpg"];
//    iChannel1Str = [bundle pathForResource: @"Day"   ofType: @"jpg"];
//    
//    if( iChannel0Str == nil ) {
//        NSLog(@"Unable to load first image file." );
//        return false;
//    } else if( iChannel1Str == nil) {
//        NSLog(@"Unable to load second image file." );
//        return false;
//    } else {
//        bitmapimagerep0 = LoadImage(iChannel0Str, 0);
//        
//        if( bitmapimagerep0 == nil ) {
//            NSLog(@"Unable to load first image file: %@", iChannel0Str );
//            return false;
//        }
//        
//        bitmapimagerep1 = LoadImage(iChannel1Str, 0);
//        
//        if( bitmapimagerep1 == nil ) {
//            NSLog(@"Unable to load second image file: %@", iChannel1Str );
//            return false;
//        }
//    }
//    
//    /* Channel 0 Texture */
//    rect = NSMakeRect(0, 0, [bitmapimagerep0 pixelsWide], [bitmapimagerep0 pixelsHigh]);
//    
//    glActiveTexture(GL_TEXTURE0);
//    
//    // Load the texture
//    glGenTextures(1, &m_textures.m_iChannel0);
//    glBindTexture(GL_TEXTURE_2D, m_textures.m_iChannel0);
//    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
//    
//    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
//    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
//    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//    glGenerateMipmap(GL_TEXTURE_2D);
//    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, rect.size.width, rect.size.height, 0,
//                 (([bitmapimagerep0 hasAlpha])?(GL_RGBA):(GL_RGB)), GL_UNSIGNED_BYTE,
//                 [bitmapimagerep0 bitmapData]);
//    
//    m_uniforms.iChannel0Handle = glGetUniformLocation(m_program, "iChannel0");
//    glUniform1i(m_program, 0);
//    
//    /* Channel 1 Texture */
//    rect = NSMakeRect(0, 0, [bitmapimagerep1 pixelsWide], [bitmapimagerep1 pixelsHigh]);
//    
//    glActiveTexture(GL_TEXTURE1);
//    
//    // Load the texture
//    glGenTextures(1, &m_textures.m_iChannel1);
//    glBindTexture(GL_TEXTURE_2D, m_textures.m_iChannel1);
//    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
//    
//    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
//    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
//    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//    glGenerateMipmap(GL_TEXTURE_2D);
//    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, rect.size.width, rect.size.height, 0,
//                 (([bitmapimagerep1 hasAlpha])?(GL_RGBA):(GL_RGB)),
//                 GL_UNSIGNED_BYTE,
//                 [bitmapimagerep1 bitmapData]);
//    
//    m_uniforms.iChannel1Handle = glGetUniformLocation(m_program, "iChannel1");
//    glUniform1i(m_program, 1);
//    
//
//    /*
//     function createGLTexture( ctx, image, format, texture )
//     {
//     if( ctx==null ) return;
//     
//     ctx.bindTexture(   ctx.TEXTURE_2D, texture);
//     ctx.pixelStorei(   ctx.UNPACK_FLIP_Y_WEBGL, false );
//     
//     ctx.texImage2D(    ctx.TEXTURE_2D, 0, format, ctx.RGBA, ctx.UNSIGNED_BYTE, image);
//     
//     ctx.texParameteri( ctx.TEXTURE_2D, ctx.TEXTURE_MAG_FILTER, ctx.LINEAR);
//     ctx.texParameteri( ctx.TEXTURE_2D, ctx.TEXTURE_MIN_FILTER, ctx.LINEAR_MIPMAP_LINEAR);
//     ctx.texParameteri( ctx.TEXTURE_2D, ctx.TEXTURE_WRAP_S, ctx.REPEAT);
//     ctx.texParameteri( ctx.TEXTURE_2D, ctx.TEXTURE_WRAP_T, ctx.REPEAT);
//     ctx.generateMipmap(ctx.TEXTURE_2D);
//     ctx.bindTexture(ctx.TEXTURE_2D, null);
//     }
//     
//     */
    return true;
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
    
    if( m_program < 1 )
    {
        NSLog(@"Error: program variable not set");
        return GL_INVALID_VALUE;
    }
        
    m_attributes.pos = glGetAttribLocation(m_program, "pos");
    
    if( m_attributes.pos == -1 )
        NSLog(@"Failed to get attribute location for 'pos'");

    m_uniforms.iGlobalTimeHandle = glGetUniformLocation(m_program, "iGlobalTime");
    m_uniforms.iResolutionHandle = glGetUniformLocation(m_program, "iResolution");
    m_uniforms.iMouseHandle      = glGetUniformLocation(m_program, "iMouse");
    
//    m_uniforms.iChannel0Handle   = glGetUniformLocation(m_program, "iChannel0");
//    
//    if( m_uniforms.iChannel0Handle == -1 )
//        NSLog(@"Failed to get uniform location for 'iChannel0'");
//    
//    m_uniforms.iChannel1Handle = glGetUniformLocation(m_program, "iChannel1");
//    
//    if( m_uniforms.iChannel1Handle == -1 )
//        NSLog(@"Failed to get uniform location for 'iChannel1'");
    
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
