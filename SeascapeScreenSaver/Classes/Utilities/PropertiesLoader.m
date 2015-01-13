//
//  PropertiesLoader.m
//  SeascapeScreenSaver
//
//  Created by David Mitchell on 1/12/15.
//  Copyright (c) 2015 David Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PropertiesLoader.h"


@implementation PropertiesLoader

+(NSDictionary*) loadProperties:(NSString*) propertiesFile ofType:(NSString*) ext {
    
    NSString* path = [[NSBundle
                       bundleForClass:[self class]]
                      pathForResource:propertiesFile ofType:ext];

    if(path == nil) {
        NSLog(@"Unable to find load properties file: %@.%@", propertiesFile, ext);
        return nil;
    }
    
    NSDictionary* dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    if(dict == nil) {
        NSLog(@"Failed to load contents of properties file: %@.%@", propertiesFile, ext);
    }
    
    return dict;
}

+(void) saveProperties:(NSDictionary*) dictionary inFile:(NSString*) propertiesFile ofType:(NSString*) ext {
    
}
@end