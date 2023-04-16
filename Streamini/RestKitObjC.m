//
//  RestKitObjC.m
//  Test
//
//  Created by Vasily Evreinov on 28/01/15.
//  Copyright (c) 2015 Direct Invent. All rights reserved.
//

#import "RestKitObjC.h"
#import <RestKit.h>

@implementation RestKitObjC

+ (void)setupLog {
    RKLogConfigureByName("RestKit", RKLogLevelWarning);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelWarning);
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/CoreData", RKLogLevelDebug);
}

@end
