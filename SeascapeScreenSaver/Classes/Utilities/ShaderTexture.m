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
    }
    
    const unsigned int count = (unsigned int)self.shaderTextureData.count;
    
    data.textureNumber = count;
    
    [self.shaderTextureData addObject:data];
    
    return true;
}

#pragma mark Completion Blocks

typedef void (^CompletionBlockWithProgram)(ShaderTextureData*, GLuint);

void (^setupTextures)(ShaderTextureData*, GLuint) =^ (ShaderTextureData* data, GLuint program) {
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
    
    char szUniformName[20];
    
    sprintf(szUniformName, "iChannel%d", data.textureNumber);
    
    data.uniformHandle = glGetUniformLocation(program, szUniformName);
    
    glUniform1i(program, data.textureNumber);
};

void (^renderTextures)(ShaderTextureData*,GLuint) =^ (ShaderTextureData* data, GLuint ignored) {
    NSLog(@"Rendering textures");
    glActiveTexture(GL_TEXTURE_2D + data.textureNumber);
    glBindTexture(GL_TEXTURE_2D, data.textureHandle);
};

void (^deleteTextures)(ShaderTextureData*, GLuint) =^ (ShaderTextureData* data, GLuint ignored) {
    NSLog(@"Deleting textures");
    GLuint texture = data.textureHandle;
    glDeleteTextures(1, &texture);
    data.textureHandle = -1;
};

//-(void) iterator:(CompletionBlock) completionBlock {
//    
//    const unsigned long count = (unsigned long)self.shaderTextureData.count;
//
//    for(int i=0; i<count; ++i) {
//        
//        ShaderTextureData* data = [self.shaderTextureData objectAtIndex:i];
//        completionBlock(data);
//    }
//}

-(void) iterator:(CompletionBlockWithProgram) completionBlock withProgram:(GLuint) program {
    
    const unsigned long count = (unsigned long)self.shaderTextureData.count;
    
    for(int i=0; i<count; ++i) {
        
        ShaderTextureData* data = [self.shaderTextureData objectAtIndex:i];
        
        //if(
        completionBlock(data, program);
    }
}

-(void) setupTextures:(GLuint) program {
    self.program = program;
    
    [self iterator:setupTextures withProgram:program];
}


#pragma mark Cleanup

-(void) dealloc {

    [self iterator:deleteTextures withProgram:0];
}

#pragma mark Drawing/Rendering
-(void) render {
    
    [self iterator:renderTextures withProgram:0];
//    const unsigned long count = (unsigned long)self.shaderTextureData.count;
//
//    ShaderTextureData* data;
//
//    for(int i=0; i<count; ++i) {
//        
//        // Textures
//        glActiveTexture(data.textureId);
//        glBindTexture(GL_TEXTURE_2D, data.textureHandle);
//    }
}

@end
