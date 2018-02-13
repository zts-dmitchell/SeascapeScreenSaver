//
//  MonitorDisplayInfo.h
//  SeascapeScreenSaver
//
//  Created by David Mitchell on 1/21/15.
//  Copyright (c) 2015 David Mitchell. All rights reserved.
//

#ifndef __SeascapeScreenSaver__MonitorDisplayInfo__
#define __SeascapeScreenSaver__MonitorDisplayInfo__
#include <ApplicationServices/ApplicationServices.h>

CGError CGDisplayRegisterReconfigurationCallback (
                                                  CGDisplayReconfigurationCallBack proc,
                                                  void *userInfo
                                                  );

int MDI_GetDisplayCount(void);

#endif /* defined(__SeascapeScreenSaver__MonitorDisplayInfo__) */
