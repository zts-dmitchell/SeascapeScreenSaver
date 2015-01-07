//
//  MountainsRenderer.mm
//  Wobbler
//
//  Created by David Mitchell on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "Mountains.h"
#include "ShaderUtil.h"
#import "ImageLoader.h"

#import <AppKit/AppKit.h>

// Attribute index.
enum {
    ATTRIB_NORMAL,
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
    NUM_ATTRIBUTES
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
        glUseProgram(program);
        
        glEnable(GL_TEXTURE_2D);
        
        [self setupTextures];
        
        glUseProgram(0);

    }
    
    return self;
}

- (void) dealloc
{
    glDeleteTextures(1, &m_texture);
    
    // TODO: Cleanup vertex buffers;
    [ShaderUtil cleanup:program];
    
    NSLog(@"MountainsRenderer going away ...");
}

- (NSString*) name {
    return @"Mountains";
}

- (void)setFrameSize:(NSSize)newSize {
    
    m_screenSize = newSize;
    
    NSLog(@"Setting frame size: %f w by %f h", newSize.width, newSize.height);
}

- (void)render
{
    glClearColor(.01, .01, .01, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    glUseProgram(program);
    
    glEnableVertexAttribArray(ATTRIB_NORMAL);
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glEnableVertexAttribArray(ATTRIB_TEXCOORD);
    
    glBindBuffer(GL_ARRAY_BUFFER, m_buffers.NormalBuffer);
    glVertexAttribPointer(ATTRIB_NORMAL, 3, GL_FLOAT, GL_FALSE, 0, 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, m_buffers.VertexBuffer);
    glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, 0, 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, m_buffers.TexCoordBuffer);
    glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, 0, 0);
    
    
    glUseProgram(0);    
}

- (BOOL) setupTextures
{
    NSBundle *bundle;
    NSString * string;
    NSBitmapImageRep *bitmapimagerep;
    NSRect rect;
    
    bundle = [NSBundle bundleForClass: [self class]];
    
    string = [bundle pathForResource: @"Day" ofType: @"jpg"];
    //string = [bundle pathForResource: @"tex2" ofType: @"jpg"];
    //string = [bundle pathForResource: @"stars-wallpapers-5-600x512" ofType: @"jpg"];
    
    if( string == nil )
    {
        NSLog(@"Unable to load image file." );
        return false;
    }
    else 
    {
        bitmapimagerep = LoadImage(string, 0    );
        
        if( bitmapimagerep == nil )
        {
            NSLog(@"Unable to load image file: %@", string );
            return false;
        }            
    }
    
    rect = NSMakeRect(0, 0, [bitmapimagerep pixelsWide], [bitmapimagerep pixelsHigh]);
    
    /* day texture */
    glActiveTexture(GL_TEXTURE0);
    
    // Load the texture
    glGenTextures(1, &m_texture);
    glBindTexture(GL_TEXTURE_2D, m_texture);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, rect.size.width, rect.size.height, 0,
                 (([bitmapimagerep hasAlpha])?(GL_RGBA):(GL_RGB)), GL_UNSIGNED_BYTE,
                 [bitmapimagerep bitmapData]);
    
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
        NSLog(@"Error: program variable not set");
        return GL_INVALID_VALUE;
    }
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(program, ATTRIB_NORMAL, "vNormal");
    glBindAttribLocation(program, ATTRIB_VERTEX, "vPosition");
    glBindAttribLocation(program, ATTRIB_TEXCOORD, "vTexCoord");
    
    return 0;
}

- (GLuint) setPostLinkUniforms
{
    if( program < 1 )
    {
        NSLog(@"Error: program variable not set");
        return GL_INVALID_VALUE;
    }
        
    m_attributes.Position = glGetAttribLocation(program, "vPosition");
    
    if( m_attributes.Position == -1 )
        NSLog(@"Failed to get attribute location for 'vPosition'");

    m_attributes.TextureCoord = glGetAttribLocation(program, "vTexCoord");
    
    if( m_attributes.TextureCoord == -1 )
        NSLog(@"Failed to get attribue location for vTexCoord");
    
    m_uniforms.Sampler = glGetUniformLocation(program, "Sampler");
    
    if( m_uniforms.Sampler == -1 )
        NSLog(@"Failed to get uniform location for 'Sampler'");


    return GL_NO_ERROR;
}

@end
