//
//  MonitorDisplayInfo.c
//  SeascapeScreenSaver
//
//  Created by David Mitchell on 1/21/15.
//  Copyright (c) 2015 David Mitchell. All rights reserved.
//

#include "MonitorDisplayInfo.h"


//void triggerDetectDisplays()
//{
//    // loop over all IOFramebuffer services
//    CFMutableDictionaryRef matchingDict = IOServiceMatching("IOFramebuffer");
//    
//    mach_port_t masterPort;
//    IOMasterPort(MACH_PORT_NULL, &masterPort);
//    io_iterator_t serviceIterator;
//    IOServiceGetMatchingServices(masterPort, matchingDict, &serviceIterator);
//    
//    io_service_t obj = IOIteratorNext(serviceIterator);
//    while (obj)
//    {
//        kern_return_t kr = IOServiceRequestProbe(obj, 0);
//        obj = IOIteratorNext(serviceIterator);
//    }
//}

const int MAX_DISPLAYS = 16;

/* From http://stackoverflow.com/questions/2079956/programatically-trigger-detect-displays */
int MDI_GetDisplayCount()
{
    CGDisplayErr      dErr;
    CGDisplayCount    displayCount; //, i;
    CGDirectDisplayID mainDisplay;
    CGDisplayCount    maxDisplays = MAX_DISPLAYS;
    CGDirectDisplayID onlineDisplays[MAX_DISPLAYS];
    mainDisplay = CGMainDisplayID();
    
    dErr = CGGetOnlineDisplayList(maxDisplays, onlineDisplays, &displayCount);
    if (dErr != kCGErrorSuccess) {
        fprintf(stderr, "CGGetOnlineDisplayList: error %d.\n", dErr);
    }
    
//    printf("Display ID       Resolution\n");
//    for (i = 0; i < displayCount; i++) {
//        CGDirectDisplayID dID = onlineDisplays[i];
//        printf("%-16p %lux%lu %32s", dID,
//               CGDisplayPixelsWide(dID), CGDisplayPixelsHigh(dID),
//               (dID == mainDisplay) ? "[main display]\n" : "\n");
//    }
    
    return displayCount > 0 ? (displayCount <= MAX_DISPLAYS ? displayCount : 1) : 1;
}
