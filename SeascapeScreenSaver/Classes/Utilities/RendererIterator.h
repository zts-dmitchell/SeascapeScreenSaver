//
//  ESRendererIterator.h
//  SeascapeScreenSaver
//
//  Created by David Mitchell on 1/11/15.
//  Copyright (c) 2015 David Mitchell. All rights reserved.
//

#ifndef SeascapeScreenSaver_ESRendererIterator_h
#define SeascapeScreenSaver_ESRendererIterator_h

#import "CircularIterator.h"
#import "Renderer.h"
#import "AnimationController.h"

/*
 // Extends CircularIterator
 ESRendererIterator rendererIter = [[ESRendererIterator alloc] init];
 
 // Optional. Should make sure renderer isn't already present.
 [rendererIter addRenderer: newRenderer];
 
 [rendererIter setScreenSize:screenSize];
 
 [rendererIter setNext];
 
 [rendererIter render];
 */

@interface RendererIterator : CircularIterator

-(instancetype) initWithAnimationController:(id<AnimationController>) animationController;
-(void) setFrameSize:(NSSize) screenSize;
-(void) addRenderer:(NSString*) renderer;
-(void) setNext;
-(void) render;

@property(nonatomic, strong) id<Renderer> renderer;
@property (nonatomic, strong) id<AnimationController> animationController;
@property(nonatomic, assign) NSSize screenSize;
@property (nonatomic, assign) unsigned long iterationsPerRenderer;
@property (nonatomic, assign) unsigned long defaultIterationsPerRenderer;

@property (nonatomic, assign) unsigned long frameNumber;
@property (nonatomic, strong) NSDictionary* shaderToys;

@property (nonatomic, strong) NSDictionary* shaderToys2;

@end

#endif
