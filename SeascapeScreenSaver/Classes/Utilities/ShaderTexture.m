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

@implementation ShaderTexture

#pragma mark Setup/Initialization

-(id) init {
    
    self = [super init];
    if(self != nil) {
        self.shaderTextureData = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(bool) addTexture:(NSString*) filename ofType:(NSString*) ext {
  
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
    
    NSLog(@"Setup textures");
    
    NSBitmapImageRep *bitmapimagerep = LoadImage(data.pathToTexture, 0);
    
    if(bitmapimagerep == nil) {
        NSLog(@"Failed to load image: %@", data.pathToTexture);
        return;
    }
    
    NSRect rect = NSMakeRect(0, 0, [bitmapimagerep pixelsWide], [bitmapimagerep pixelsHigh]);
    
    glActiveTexture(GL_TEXTURE_2D + data.textureNumber);
    
    // Load the texture
    GLuint texture;
    
    glGenTextures(1, &texture);
    data.textureHandle = texture;

    glBindTexture(GL_TEXTURE_2D, data.textureHandle);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glGenerateMipmap(GL_TEXTURE_2D);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, rect.size.width, rect.size.height, 0,
                 (([bitmapimagerep hasAlpha])?(GL_RGBA):(GL_RGB)), GL_UNSIGNED_BYTE,
                 [bitmapimagerep bitmapData]);
    
    char szUniformName[32];
    
    snprintf(szUniformName, 32, "iChannel%d", data.textureNumber);
    
    data.uniformHandle = glGetUniformLocation(program, szUniformName);
    
    glUniform1i(program, data.textureNumber);
    
    glBindTexture(GL_TEXTURE_2D, 0);

};

void (^renderTextures)(ShaderTextureData*,GLuint) =^ (ShaderTextureData* data, GLuint ignored) {
    
    glActiveTexture(GL_TEXTURE_2D + data.textureNumber);
    glBindTexture(GL_TEXTURE_2D, data.textureHandle);
};

void (^deleteTextures)(ShaderTextureData*, GLuint) =^ (ShaderTextureData* data, GLuint ignored) {
    
    if(data.textureHandle == 0) {
        NSLog(@"Texture not initialzied: %@", data.pathToTexture);
        return;
    }
    
    NSLog(@"Deleting texture: %@", data.pathToTexture);
    GLuint texture = data.textureHandle;
    glDeleteTextures(1, &texture);
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
    
    [self iterator:prepareATexture withProgram:program];
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
//    const unsigned long count = (unsigned long)self.shaderTextureData.count;

    ShaderTextureData* data;
    const unsigned long count = (unsigned long)self.shaderTextureData.count;

    for(int i=0; i<count; ++i) {
        
        // Textures
        glActiveTexture(GL_TEXTURE_2D + data.textureNumber);
        glBindTexture(GL_TEXTURE_2D, data.textureHandle);
    }
#endif
}

@end
