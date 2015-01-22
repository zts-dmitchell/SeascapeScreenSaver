//
//  ESRendererIterator.m
//  SeascapeScreenSaver
//
//  Created by David Mitchell on 1/11/15.
//  Copyright (c) 2015 David Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RendererIterator.h"
#import "PropertiesLoader.h"
#import "ShaderToyRenderer.h"

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
    
    // It knows what to load.
    NSDictionary* properties = [PropertiesLoader loadProperties];
    
    if(properties != nil) {
        
        // get iterationsPerRenderer:
        NSDictionary* runInfo = [properties objectForKey:@"run-info"];
        
        NSNumber* objNumber = [runInfo objectForKey:@"iterations-per-renderer"];
        
        self.iterationsPerRenderer = [objNumber intValue];
        self.defaultIterationsPerRenderer = self.iterationsPerRenderer;
        
        NSLog(@"Iterations per renderer: %lu", self.iterationsPerRenderer);
        
        self.frameNumber = 0;

        self.shaderToys = [properties objectForKey:@"ShaderToys"];
        
        if(self.shaderToys == nil) {
            NSLog(@"Unable to find 'ShaderToys' object. Adding deprecated default renderers.");
            [self addDefaultRenderers];
            return true;
        }
        
        NSArray* allKeys = [self.shaderToys allKeys];
        NSDictionary* renderKeys;
        
        for(int i=0; i<allKeys.count; ++i) {
            
            renderKeys = [allKeys objectAtIndex:i];
            
            NSString* renderer = [renderKeys description];
            
            // Get the "Config" dictionary, and check if this renderer is enabled.
            NSDictionary* rendererChildrenDict = [self.shaderToys objectForKey:renderer];
            
            if(rendererChildrenDict != nil) {
                
                NSDictionary* config = [rendererChildrenDict objectForKey:@"Config"];
                
                if(config != nil) {
                    NSNumber *enabled = [config objectForKey:@"enabled"];
                    
                    if(enabled != nil && [enabled boolValue] == NO) {
                        NSLog(@"Renderer, %@, is not enabled. Skipping", renderer);
                    } else {
                        NSLog(@"Renderer, %@, is enabled (%@)", renderer, enabled);
                        [self addRenderer:renderer];
                    }
                } else {
                    [self addRenderer:renderer];
                }
            } else {
                NSLog(@"No configuration settings for renderer: %@", renderer);
                [self addRenderer:renderer];
            }
        }
    } else {
        NSLog(@"Unable to load properties.");
        return false;
    }
    
    return true;
}

-(void) setFrameSize:(NSSize) screenSize {
    
    self.screenSize = screenSize;
    
    [self.renderer setFrameSize:screenSize];
    [self.renderer2 setFrameSize:screenSize];
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

    // If there's only one object, return.
    if([self count] == 1 && self.renderer != nil) {
        NSLog(@"Returning without setting new renderer.  There's only one.");
        return;
    } else {
        NSLog(@"ShaderToys count: %i.", [self count]);
    }
    
    [self.animationController stopAnimation];

    NSString* rendererClassName = [self next];
    
    NSLog(@"setNext: %@", rendererClassName);
    NSArray* textures;
    NSDictionary* rendererDic = [self.shaderToys objectForKey:rendererClassName];
    
    if(rendererDic != nil) {
        
        // Handle the config. This one's a dictionary
        NSDictionary* config = [rendererDic objectForKey:@"Config"];
        
        if(config != nil) {
           
            NSNumber* iterationsPerRenderer = [config objectForKey:@"iterations-per-renderer"];
            
            if(iterationsPerRenderer != nil) {
                self.iterationsPerRenderer = [iterationsPerRenderer intValue];
                
                if(self.iterationsPerRenderer < 100) {
                    NSLog(@"Minimum of 100 iterations.  Setting to default");
                    self.iterationsPerRenderer = self.defaultIterationsPerRenderer;
                }
                
                NSLog(@"Number of iterations per renderer (min 100): %lu", self.iterationsPerRenderer);

            } else {
                NSLog(@"Didn't find 'iterations-per-renderer' Going with default");
                self.iterationsPerRenderer = self.defaultIterationsPerRenderer;
            }
            
        } else {
            NSLog(@"Didn't find config for renderer: %@", rendererClassName);
        }
        
        // Handle the textures. This one's an NSArray
        textures = [rendererDic objectForKey:@"Textures"];
     
        if(textures != nil) {
            for(NSString* s in textures) {
                NSLog(@"Found texture file: %@", s);
            }
        }
        
        GLfloat vertices[] =
        { -1.0, 0.0,   1.0, 0.0,   -1.0,  1.0,
            1.0, 0.0,   1.0,  1.0,   -1.0,  1.0
        };
        
        GLfloat vertices2[] =
        { -1.0, -1.0,   1.0, -1.0,   -1.0,  0.0,
            1.0, -1.0,   1.0,  0.0,   -1.0,  0.0
        };
        
        //self.renderer = [[ShaderToyRenderer alloc] initWithShaderName:rendererClassName andShaderTextures:textures];
        self.renderer = [[ShaderToyRenderer alloc] initWithShaderNameAndVertices:rendererClassName
                                                                  shaderTextures:textures
                                                                     andVertices:vertices];
        self.renderer2 = [[ShaderToyRenderer alloc] initWithShaderNameAndVertices:@"Venice"
                                                                  shaderTextures:textures
                                                                     andVertices:vertices2];
    }
    
    [self.renderer setFrameSize:self.screenSize];
    [self.renderer2 setFrameSize:self.screenSize];

    [self.animationController startAnimation];
}

-(void) render {
    
    if(self.frameNumber++ % self.iterationsPerRenderer == 0) {
        
        [self setNext];
        
        NSLog(@"Switched to new renderer, '%@', after %lu frames.",
              self.currentClassname, self.frameNumber - 1);
    }
    
    [self.renderer2 render];
    [self.renderer render];
}

@end