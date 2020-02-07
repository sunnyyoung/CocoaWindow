//
//  NSObject+Swizzle.h
//  CocoaWindow
//
//  Created by Sunny Young on 2020/2/7.
//  Copyright © 2020 Sunnyyoung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (CWSwizzle)

+ (BOOL)cw_instanceSwizzleOrigin:(SEL)origin withAlter:(SEL)alter error:(NSError**)error;
+ (BOOL)cw_classSwizzleOrigin:(SEL)origin withAlter:(SEL)alter error:(NSError**)error;

@end

NS_ASSUME_NONNULL_END
