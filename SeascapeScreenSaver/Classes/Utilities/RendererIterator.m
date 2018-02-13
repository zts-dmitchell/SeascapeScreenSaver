//
//  RendererIterator.m
//  SeascapeScreenSaver
//
//  Created by David Mitchell on 1/11/15.
//  Copyright (c) 2015 David Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RendererIterator.h"
#import "PropertiesLoader.h"
#import "ShaderToyRenderer.h"
#include "MonitorDisplayInfo.h"
#import "WobblerRenderer.h"
#import <IOKit/ps/IOPowerSources.h>

#pragma mark Constants
static const NSString * const kShaderToys = @"ShaderToys";
static const NSString * const kConfig = @"Config";
static const NSString * const kEnabled = @"enabled";
static const NSString * const kIterationsPerRenderer = @"iterations-per-renderer";
static const NSString * const kSingleScreenDisplayFactor = @"single-screen-display-factor";
static const NSString * const kMultiScreenDisplayFactor = @"multi-screen-display-factor";


@implementation RendererIterator

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
    
    CFDictionaryRef powerDict = IOPSCopyExternalPowerAdapterDetails();
    
    if(powerDict == nil) {
        NSLog(@"NOT PLUGGED IN!!!");
    } else {
        NSLog(@"PLUGGED IN!!!");
        CFRelease(powerDict);
    }
    
    // It knows what to load.
    NSDictionary* properties = [PropertiesLoader loadProperties];
    
    if(properties != nil) {
        
        // get iterationsPerRenderer:
        NSDictionary* runInfo = [properties objectForKey:@"run-info"];
        
        NSNumber* objNumber = [runInfo objectForKey:kIterationsPerRenderer];
        
        self.iterationsPerRenderer = [objNumber intValue];
        self.defaultIterationsPerRenderer = self.iterationsPerRenderer;
        
        NSLog(@"Iterations per renderer: %lu", self.iterationsPerRenderer);
        
        self.frameNumber = 0;

        self.shaderToys = [properties objectForKey:kShaderToys];
        
        if(self.shaderToys == nil) {
            NSLog(@"Unable to find 'ShaderToys' object. Adding deprecated default renderers.");
            [self addDefaultRenderers];
            return true;
        }
//#define ONE_RENDERER
#ifdef ONE_RENDERER
        [self addRenderer:@"SeascapeRenderer"];

        //[self addRenderer:@"FlyByNight"];
        //[self addRenderer:@"WobblerRenderer"];
#else
        NSArray* allKeys = [self.shaderToys allKeys];
        NSDictionary* renderKeys;
        
        for(int i=0; i<allKeys.count; ++i) {
            
            renderKeys = [allKeys objectAtIndex:i];
            
            NSString* renderer = [renderKeys description];
            
            [self addRenderer:renderer];
        }
#endif
    } else {
        NSLog(@"Unable to load properties.");
        return false;
    }
    
    return true;
}

-(void) setFrameSize:(NSSize) screenSize {
    
    self.screenSize = screenSize;
    
    [self.renderer setFrameSize:screenSize];
    //[self.renderer2 setFrameSize:screenSize];
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

    // If there's only one object, return.
    if([self count] == 1 && self.renderer != nil) {
        NSLog(@"Returning without setting new renderer.  There's only one.");
        return;
    } else {
        NSLog(@"ShaderToys count: %i.", [self count]);
    }
    
    [self.animationController stopAnimation];

    bool lookingForRenderer = true;
    float scalingFactor = 1.0;
    
    while(lookingForRenderer) {
        
        NSString* renderer = [self next];
        NSArray* textures;
    
        NSDictionary* rendererDic = [self.shaderToys objectForKey:renderer];
    
        if(rendererDic != nil) {
            
            // Handle the config. This one's a dictionary
            NSDictionary* config = [rendererDic objectForKey:kConfig];
            
            if(config != nil) {
               
                // Check if enabled
                NSNumber *enabled = [config objectForKey:kEnabled];
                
                if(enabled != nil && [enabled boolValue] == NO) {
                    NSLog(@"Renderer, %@, is not enabled. Skipping", renderer);
                    continue;
                } else {
                    NSLog(@"Renderer, %@, is enabled (%@)", renderer, enabled);
                }
                
                scalingFactor = [self getScalingFactor:config];
                
                NSNumber* iterationsPerRenderer = [config objectForKey:kIterationsPerRenderer];
                
                if(iterationsPerRenderer != nil) {
                    self.iterationsPerRenderer = [iterationsPerRenderer intValue];
                    
                    if(self.iterationsPerRenderer < 100) {
                        NSLog(@"Minimum of 100 iterations.  Setting to default");
                        self.iterationsPerRenderer = self.defaultIterationsPerRenderer;
                    }
                    
                } else {
                    NSLog(@"Didn't find 'iterations-per-renderer' Going with default");
                    self.iterationsPerRenderer = self.defaultIterationsPerRenderer;
                }
                
            } else {
                NSLog(@"Didn't find config for renderer: %@", renderer);
                self.iterationsPerRenderer = self.defaultIterationsPerRenderer;
            }

            NSLog(@"Number of iterations for renderer '%@': %lu", renderer, self.iterationsPerRenderer);
            

            // Handle the textures. This one's an NSArray
            textures = [rendererDic objectForKey:@"Textures"];
         
            if(textures != nil) {
                for(NSString* s in textures) {
                    NSLog(@"Found texture file: %@", s);
                }
            }
            
    //        const GLfloat vertices[] =
    //        { -1.0, 0.0,   1.0, 0.0,   -1.0,  1.0,
    //            1.0, 0.0,   1.0,  1.0,   -1.0,  1.0
    //        };
    //        
    //        const GLfloat vertices2[] =
    //        { -1.0, -1.0,   1.0, -1.0,   -1.0,  0.0,
    //            1.0, -1.0,   1.0,  0.0,   -1.0,  0.0
    //        };
            
            //self.renderer = [[ShaderToyRenderer alloc] initWithShaderName:rendererClassName andShaderTextures:textures];
//    #ifdef ONE_RENDERER
//            self.renderer = [[ShaderToyRenderer alloc] initWithShaderName:renderer
//                                                        andShaderTextures:textures
//                                                        withScalingFactor:1.0];
//    #else
//            self.renderer = [[ShaderToyRenderer alloc] initWithShaderName:renderer
//                                                        andShaderTextures:textures
//                                                        withScalingFactor:scalingFactor];
            if([ renderer compare:@"WobblerRenderer"] == NSOrderedSame )
                self.renderer = [[WobblerRenderer alloc] init];
            else
                self.renderer = [[ShaderToyRenderer alloc] initWithShaderName:renderer
                                                            andShaderTextures:textures
                                                            withScalingFactor:scalingFactor];
            
//    #endif
            //self.renderer = [[ShaderToyRenderer alloc] initWithShaderNameAndVertices:rendererClassName
            //                                                          shaderTextures:textures
            //                                                             andVertices:vertices];
            //self.renderer2 = [[ShaderToyRenderer alloc] initWithShaderNameAndVertices:@"Venice"
            //                                                          shaderTextures:textures
            //                                                             andVertices:vertices2];
            lookingForRenderer = false;
        }
    }
    
    [self.renderer setFrameSize:self.screenSize];
    //[self.renderer2 setFrameSize:self.screenSize];

    [self.animationController startAnimation];
}

#define CLAMP(edge0, edge1, value)  \
    (value < edge0 ? edge0 : value > edge1 ? edge1 : value);

-(float) getScalingFactor:(NSDictionary*) config {

    const int monitorCount = MDI_GetDisplayCount();
    float scalingFactor = 1.0;

    if(monitorCount == 1) {
        
        NSNumber *singleScalingFactor = [config objectForKey:kSingleScreenDisplayFactor];
        
        if(singleScalingFactor != nil ) {
            scalingFactor =  [singleScalingFactor floatValue];
            NSLog(@"SingleScreenDisplayFactor overridden: %f", scalingFactor);
        } else {
            NSLog(@"SingleScreenDisplayFactor: %f", scalingFactor);
        }
        
    } else {

        NSNumber *multiScalingFactor = [config objectForKey:kMultiScreenDisplayFactor];
        
        if(multiScalingFactor != nil ) {
            scalingFactor =  [multiScalingFactor floatValue];
            NSLog(@"MultiScreenDisplayFactor overridden: %f", scalingFactor);
        } else {
            NSLog(@"MultiScreenDisplayFactor: %f", scalingFactor);
        }
    }
    
    return CLAMP(0.1, 1.0, scalingFactor);
}

-(void) render {
    
    if(self.frameNumber++ % self.iterationsPerRenderer == 0) {
        
        [self setNext];
        
        NSLog(@"Switched to new renderer, '%@', after %lu frames.",
              self.currentClassname, self.frameNumber - 1);
    }
    
    //[self.renderer2 render];
    [self.renderer render];
}

@end
