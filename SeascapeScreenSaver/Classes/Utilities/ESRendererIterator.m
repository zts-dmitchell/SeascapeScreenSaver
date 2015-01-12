//
//  ESRendererIterator.m
//  SeascapeScreenSaver
//
//  Created by David Mitchell on 1/11/15.
//  Copyright (c) 2015 David Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESRendererIterator.h"
#import "ESRenderer.h"

// Renderers:
#import "SeascapeRenderer.h"
#import "WobblerRenderer.h"
#import "MountainsRenderer.h"
#import "SomewhereIn1993Renderer.h"
#import "SymmetricOriginsRenderer.h"
#import "MorningCityRenderer.h"


@implementation ESRendererIterator

-(id) init {
    
    self = [super init];
    
    if(self != nil) {
        [self addDefaultRenderers];
    }
    
    return self;
}

-(void) setFrameSize:(NSSize) screenSize {
    
    self.screenSize = screenSize;
    
    [self.renderer setScreenSize:screenSize];
}

-(void) addDefaultRenderers {
    
    [self addRenderer:@"SeascapeRenderer"];
    [self addRenderer:@"WobblerRenderer"];
    [self addRenderer:@"MountainsRenderer"];
    [self addRenderer:@"SomewhereIn1993Renderer"];
    [self addRenderer:@"SymmetricOriginsRenderer"];
    [self addRenderer:@"MorningCityRenderer"];
}

-(void) addRenderer:(NSString*) rendererClassName {
    
    [self addObject:rendererClassName];
}

-(void) setNext {

    NSString* rendererClassName = [self next];
    NSLog(@"setNext: %@", rendererClassName);
    
    Class c = NSClassFromString(rendererClassName);
    
    self.renderer = [[c alloc] init];
    [self.renderer setFrameSize:self.screenSize];
}

-(void) render {
    NSLog(@"About to render");
    [self.renderer render];
}

@end