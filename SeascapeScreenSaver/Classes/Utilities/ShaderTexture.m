//
//  ShaderTexture.m
//  SeascapeScreenSaver
//
//  Created by David Mitchell on 1/12/15.
//  Copyright (c) 2015 David Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShaderTexture.h"

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

    data.pathToTexture = [[NSBundle bundleForClass:[self class]] pathForResource:filename ofType:ext];
    
    if(data.pathToTexture == nil) {
        NSLog(@"Unable to find texture: %@.%@", filename, ext);
        return false;
    }
    
    const unsigned int count = (unsigned int)self.shaderTextureData.count;
    
    data.textureId = GL_TEXTURE_2D + count;
    
    [self.shaderTextureData addObject:data];
    
    return true;
}

#pragma mark Completion Blocks

typedef void (^CompletionBlock)(ShaderTextureData*);

void (^renderTextures)(ShaderTextureData*) =^ (ShaderTextureData* data) {
    NSLog(@"Rendering textures");
    glActiveTexture(data.textureId);
    glBindTexture(GL_TEXTURE_2D, data.textureHandle);
};

void (^deleteTextures)(ShaderTextureData*) =^ (ShaderTextureData* data) {
    NSLog(@"Freeing textures");
    GLuint texture = data.textureHandle;
    glDeleteTextures(1, &texture);
    data.textureHandle = -1;
};

-(void) iterator:(CompletionBlock) completionBlock {
    
    const unsigned long count = (unsigned long)self.shaderTextureData.count;

    for(int i=0; i<count; ++i) {
        
        ShaderTextureData* data = [self.shaderTextureData objectAtIndex:i];
        completionBlock(data);
    }
}

#pragma mark Cleanup

-(void) dealloc {

    [self iterator:deleteTextures];
}

#pragma mark Drawing/Rendering
-(void) render {
    
    [self iterator:renderTextures];
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


#pragma mark Attribute Protocol Methods
- (void) setProgram: (GLuint) program {
    return;
}

- (GLuint) bindAttributes {
    return 0;
}

- (GLuint) setPostLinkUniforms {
    return 0;
}


@end
