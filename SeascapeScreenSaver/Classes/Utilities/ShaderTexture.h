//
//  ShaderTexture.h
//  SeascapeScreenSaver
//
//  Created by David Mitchell on 1/12/15.
//  Copyright (c) 2015 David Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "Attributes.h"
#import "ShaderTextureData.h"

@interface ShaderTexture : NSObject //<Attributes>

-(id) init;
-(bool) addTexture:(NSString*) filename ofType:(NSString*) ext;
-(void) prepareTextures:(GLuint) program;
-(void) render;

@property (nonatomic, strong) NSMutableArray* shaderTextureData;
@end
