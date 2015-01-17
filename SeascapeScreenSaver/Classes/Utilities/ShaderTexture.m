//
//  ShaderTexture.m
//  SeascapeScreenSaver
//
//  Created by David Mitchell on 1/12/15.
//  Copyright (c) 2015 David Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "ShaderTexture.h"
#import "ImageLoader.h"
#include "GLUtil.h"

@implementation ShaderTexture

#pragma mark Setup/Initialization

-(instancetype) initWithArrayOfTextureFiles:(NSArray *)arrayOfTextureFiles {
    
    self = [super init];
    if(self != nil) {
        
        self.shaderTextureData = [[NSMutableArray alloc] init];
        
        if(arrayOfTextureFiles != nil)
            [self addTextures:arrayOfTextureFiles];
    }
    
    return self;
}

-(bool) addTextures:(NSArray*) arrayOfTextures {

    for(NSString* file in arrayOfTextures) {
        
        NSString* stringByDeletingPathExtension = [file stringByDeletingPathExtension];
        NSString* pathExtension = [file pathExtension];
        
        [self addTexture:stringByDeletingPathExtension ofType:pathExtension];
    }
    
    return true;
}

-(bool) addTexture:(NSString*) filename ofType:(NSString*) ext {
  
    glEnable(GL_TEXTURE_2D); printOpenGLError();

    ShaderTextureData* data = [[ShaderTextureData alloc] init];

    // This also tests whether the texture will be displayed
    data.pathToTexture = [[NSBundle bundleForClass:[self class]] pathForResource:filename ofType:ext];
    
    if(data.pathToTexture == nil) {
        NSLog(@"Unable to find texture: %@.%@", filename, ext);
        return false;
    } else {
        NSLog(@"Successfully loaded path-to-texture: %@", data.pathToTexture);
    }
    
    const unsigned int count = (unsigned int)self.shaderTextureData.count;
    
    NSLog(@"Setting texture-number: %d", count);
    data.textureNumber = count;
    
    [self.shaderTextureData addObject:data];
    
    return true;
}

#pragma mark Completion Blocks

typedef void (^CompletionBlockWithProgram)(ShaderTextureData*, GLuint);

void (^prepareATexture)(ShaderTextureData*, GLuint) =^ (ShaderTextureData* data, GLuint program) {
    
    NSLog(@"Preparing a texture: %@", data.pathToTexture);
    
    NSBitmapImageRep *bitmapimagerep = LoadImage(data.pathToTexture, 0);
    
    if(bitmapimagerep == nil) {
        NSLog(@"Failed to load image: %@", data.pathToTexture);
        return;
    }
    
    NSRect rect = NSMakeRect(0, 0, [bitmapimagerep pixelsWide], [bitmapimagerep pixelsHigh]);
    
    NSLog(@"Prepping texture: %d. w: %ld, h: %ld",
          data.textureNumber,
          (long)[bitmapimagerep pixelsWide], (long)[bitmapimagerep pixelsHigh]);
    
    glActiveTexture(GL_TEXTURE0 + data.textureNumber); printOpenGLError();
    
    // Load the texture
    GLuint texture;
    
    glGenTextures(1, &texture); printOpenGLError();
    data.textureHandle = texture;

    glBindTexture(GL_TEXTURE_2D, data.textureHandle); printOpenGLError();
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);  printOpenGLError();
    
    // Doc same both must be the same.
    const GLint formatAndInternalFormat = [bitmapimagerep hasAlpha] ? GL_RGBA : GL_RGB;
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT); printOpenGLError();
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT); printOpenGLError();
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); printOpenGLError();
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);//_MIPMAP_LINEAR); printOpenGLError();
    //glGenerateMipmap(GL_TEXTURE_2D); printOpenGLError();
    glTexImage2D(GL_TEXTURE_2D, 0, formatAndInternalFormat,
                 rect.size.width, rect.size.height, 0,
                 formatAndInternalFormat, GL_UNSIGNED_BYTE,
                 [bitmapimagerep bitmapData]); printOpenGLError();
    
    
    char szUniformName[32];
    
    snprintf(szUniformName, 32, "iChannel%d", data.textureNumber);
    NSLog(@"Alpha? %d.  Uniform name: '%s', with number: %d",
          [bitmapimagerep hasAlpha], szUniformName, data.textureNumber);
    
    GLint uniformHandle = glGetUniformLocation(program, szUniformName); printOpenGLError();
    
    glUniform1i(uniformHandle, data.textureNumber); printOpenGLError();
    
    glBindTexture(GL_TEXTURE_2D, 0); printOpenGLError();
};

void (^renderTextures)(ShaderTextureData*,GLuint) =^ (ShaderTextureData* data, GLuint ignored) {
    
    glActiveTexture(GL_TEXTURE0 + data.textureNumber); printOpenGLError();
    glBindTexture(GL_TEXTURE_2D, data.textureHandle);  printOpenGLError();
};

void (^deleteTextures)(ShaderTextureData*, GLuint) =^ (ShaderTextureData* data, GLuint ignored) {
    
    if(data.textureHandle == 0) {
        NSLog(@"Texture not initialzied: %@", data.pathToTexture);
        return;
    }
    
    NSLog(@"Deleting texture: %@", data.pathToTexture);
    GLuint texture = data.textureHandle;
    glDeleteTextures(1, &texture); printOpenGLError();
    data.textureHandle = 0;
    
    NSLog(@"Done deleting texture.");
};

-(void) iterator:(CompletionBlockWithProgram) completionBlock withProgram:(GLuint) program {
    
    const unsigned long count = (unsigned long)self.shaderTextureData.count;
    
    for(int i=0; i<count; ++i) {
        
        ShaderTextureData* data = [self.shaderTextureData objectAtIndex:i];
    
        completionBlock(data, program);
    }
}

-(void) prepareTextures:(GLuint) program {
    
#ifdef RENDER_WITH_ITERATOR
    [self iterator:prepareATexture withProgram:program];
#else
    ShaderTextureData* data;
    const unsigned long count = (unsigned long)self.shaderTextureData.count;
    
    for(int i=0; i<count; ++i) {

        data = [self.shaderTextureData objectAtIndex:i];

        prepareATexture(data, program);
    }
#endif
}

#pragma mark Cleanup

-(void) dealloc {

    [self iterator:deleteTextures withProgram:0];
}

#pragma mark Drawing/Rendering

-(void) render {
    
#ifdef RENDER_WITH_ITERATOR
    [self iterator:renderTextures withProgram:0];
#else
    ShaderTextureData* data;
    const unsigned long count = (unsigned long)self.shaderTextureData.count;

    for(int i=0; i<count; ++i) {
        
        // Textures
        data = [self.shaderTextureData objectAtIndex:i];

        glActiveTexture(GL_TEXTURE0 + data.textureNumber); printOpenGLError();
        glBindTexture(GL_TEXTURE_2D, data.textureHandle);  printOpenGLError();
    }
#endif
}

@end
