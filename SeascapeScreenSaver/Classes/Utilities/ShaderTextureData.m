//
//  ShaderTextureData.m
//  SeascapeScreenSaver
//
//  Created by David Mitchell on 1/13/15.
//  Copyright (c) 2015 David Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShaderTextureData.h"

@implementation ShaderTextureData

-(instancetype) init {
    self = [super init];
    if(self != nil) {
        self.textureNumber = 0;
        self.textureHandle = 0;
        self.pathToTexture = nil;
    }
    return self;
}

@end