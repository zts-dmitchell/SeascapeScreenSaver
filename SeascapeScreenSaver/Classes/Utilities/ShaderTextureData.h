//
//  ShaderTextureData.h
//  SeascapeScreenSaver
//
//  Created by David Mitchell on 1/13/15.
//  Copyright (c) 2015 David Mitchell. All rights reserved.
//

#ifndef SeascapeScreenSaver_ShaderTextureData_h
#define SeascapeScreenSaver_ShaderTextureData_h
#import <Foundation/Foundation.h>
#import <OpenGL/gl.h>

@interface ShaderTextureData : NSObject

-(id) init;

@property (nonatomic, assign) GLuint textureNumber;
@property (nonatomic, assign) GLuint textureHandle;
@property (nonatomic, strong) NSString* pathToTexture;

@end

#endif
