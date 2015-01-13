//
//  PropertiesLoader.h
//  SeascapeScreenSaver
//
//  Created by David Mitchell on 1/12/15.
//  Copyright (c) 2015 David Mitchell. All rights reserved.
//

#ifndef SeascapeScreenSaver_PropertiesLoader_h
#define SeascapeScreenSaver_PropertiesLoader_h

@interface PropertiesLoader : NSObject

+(NSDictionary*) loadProperties:(NSString*) propertiesFile ofType:(NSString*) ext;

@end
#endif
