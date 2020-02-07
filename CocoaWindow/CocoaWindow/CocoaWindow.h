//
//  CocoaWindow.h
//  CocoaWindow
//
//  Created by Sunny Young on 2018/10/22.
//  Copyright © 2018 Sunnyyoung. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>
#import "CGSInternal.h"

@interface NSWindow (CocoaWindow)

@property (nonatomic, assign) BOOL cw_isDecorationViewHidden;
@property (nonatomic, assign) CGFloat cw_titlebarHeight;
@property (nonatomic, assign) CGFloat cw_closeButtonOffset;
@property (nonatomic, assign) CGFloat cw_blur;

@end
