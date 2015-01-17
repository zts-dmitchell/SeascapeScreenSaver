//
//  ESRendererIterator.m
//  SeascapeScreenSaver
//
//  Created by David Mitchell on 1/11/15.
//  Copyright (c) 2015 David Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RendererIterator.h"
#import "Renderer.h"
#import "PropertiesLoader.h"
#import "ShaderToyRenderer.h"

// Renderers:
#import "SeascapeRenderer.h"
#import "WobblerRenderer.h"
#import "MountainsRenderer.h"
#import "SomewhereIn1993Renderer.h"
#import "SymmetricOriginsRenderer.h"
#import "MorningCityRenderer.h"


@implementation RendererIterator

-(instancetype) init {
    
    self = [super init];
    
    if(self != nil) {
        [self addDefaultRenderers];
    }
    
    return self;
}

-(instancetype) initWithArrayOfRenderers:(NSArray*) arrayOfRenderers {

    self = [super init];
    
    if(self != nil) {
        
        if(arrayOfRenderers == nil) {
            NSLog(@"'arrayOfRenderers' is nil! Using default list of renderers.");
            [self addDefaultRenderers];
        } else {
            [self addRenderersFromArray:arrayOfRenderers];
        }
    }
    
    return self;
}

-(instancetype) initWithAnimationController:(id<AnimationController>) animationController {
    
    self = [super init];
    
    if(self != nil) {
        
        if(! [self initializeRenderers]) {
            self = nil;
            return self;
        }
        
        self.animationController = animationController;
    }
    
    return self;
}

-(BOOL) initializeRenderers {
    
    // It knows what to load.
    NSDictionary* properties = [PropertiesLoader loadProperties];
    
    if(properties != nil) {
        
        // get iterationsPerRenderer:
        NSDictionary* runInfo = [properties objectForKey:@"run-info"];
        
        NSNumber* objNumber = [runInfo objectForKey:@"iterations-per-renderer"];
        
        self.iterationsPerRenderer = [objNumber intValue];
        
        NSLog(@"Iterations per renderer: %lu", self.iterationsPerRenderer);
        
        self.frameNumber = 0;

        self.shaderToys = [properties objectForKey:@"ShaderToys"];
        
        if(self.shaderToys == nil) {
            NSLog(@"Unable to find 'ShaderToys' object. Adding deprecated default renderers.");
            [self addDefaultRenderers];
            return true;
        }
        
        [self addRenderer:@"MorningCity"];
        
        //NSArray* renderers = [properties objectForKey:@"renderers"];
        //assert(renderers != nil);
        
    } else {
        NSLog(@"Unable to load properties.");
        return false;
    }
    
    return true;
}

-(void) setFrameSize:(NSSize) screenSize {
    
    self.screenSize = screenSize;
    
    [self.renderer setFrameSize:screenSize];
}

-(void) addRenderersFromArray:(NSArray*) arrayOfRenderers {

    for(NSString* renderer in arrayOfRenderers) {
        if(NSClassFromString(renderer) == nil) {
            NSLog(@"Renderer class not found: %@", renderer);
        } else {
            NSLog(@"Adding renderer: %@", renderer);
            [self addRenderer:renderer];
        }
    }
}

-(void) addDefaultRenderers {
    
    [self addRenderer:@"SeascapeRenderer"];
    [self addRenderer:@"WobblerRenderer"];
    [self addRenderer:@"MountainsRenderer"];
    [self addRenderer:@"SomewhereIn1993Renderer"];
    [self addRenderer:@"SymmetricOriginsRenderer"];
    [self addRenderer:@"MorningCityRenderer"];
    [self addRenderer:@"MusicPiratesRenderer"];
}

-(void) addRenderer:(NSString*) rendererClassName {
    
    [self addObject:rendererClassName];
}

-(void) setNext {

    [self.animationController stopAnimation];

    NSString* rendererClassName = [self next];
    
    NSLog(@"setNext: %@", rendererClassName);
    
    //Class c = NSClassFromString(rendererClassName);
    self.renderer = [[ShaderToyRenderer alloc] initWithShaderName:rendererClassName andShaderTextures:nil];
    
    
    [self.renderer setFrameSize:self.screenSize];

    [self.animationController startAnimation];
}

-(void) render {
    
    if(self.frameNumber++ % self.iterationsPerRenderer == 0) {
        
        [self setNext];
        
        NSLog(@"Switched to new renderer, '%@', after %lu frames.",
              [self getClassName], self.frameNumber - 1);
        
    }
    
    [self.renderer render];
}

-(NSString*) getClassName {
    return [self.renderer description];
}
@end