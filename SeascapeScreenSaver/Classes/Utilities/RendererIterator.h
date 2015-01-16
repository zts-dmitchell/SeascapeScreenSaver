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

-(instancetype) init;
-(instancetype) initWithArrayOfRenderers:(NSArray*) arrayOfRenderers;
-(void) setFrameSize:(NSSize) screenSize;
-(void) addRenderer:(NSString*) renderer;
-(void) setNext;
-(void) render;
-(NSString*) getClassName;
@property(nonatomic, assign) NSSize screenSize;
@property(nonatomic, strong) id<Renderer> renderer;
@end

#endif
