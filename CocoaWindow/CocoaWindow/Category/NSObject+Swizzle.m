//
//  NSObject+Swizzle.m
//  CocoaWindow
//
//  Created by Sunny Young on 2020/2/7.
//  Copyright © 2020 Sunnyyoung. All rights reserved.
//

#import "NSObject+Swizzle.h"

#define SetNSErrorFor(FUNC, ERROR_VAR, FORMAT,...)    \
    if (ERROR_VAR) {    \
        NSString *errStr = [NSString stringWithFormat:@"%s: " FORMAT,FUNC,##__VA_ARGS__]; \
        *ERROR_VAR = [NSError errorWithDomain:@"NSCocoaErrorDomain" \
                                         code:-1    \
                                     userInfo:[NSDictionary dictionaryWithObject:errStr forKey:NSLocalizedDescriptionKey]]; \
    }
#define SetNSError(ERROR_VAR, FORMAT,...) SetNSErrorFor(__func__, ERROR_VAR, FORMAT, ##__VA_ARGS__)

@implementation NSObject (CWSwizzle)

+ (BOOL)cw_instanceSwizzleOrigin:(SEL)origin withAlter:(SEL)alter error:(NSError**)error {
    Method originMethod = class_getInstanceMethod(self, origin);
    if (!originMethod) {
        SetNSError(error, @"original method %@ not found for class %@", NSStringFromSelector(origin), self.className);
        return NO;
    }
    
    Method alterMethod = class_getInstanceMethod(self, alter);
    if (!alterMethod) {
        SetNSError(error, @"alternate method %@ not found for class %@", NSStringFromSelector(alter), self.className);
        return NO;
    }
    
    class_addMethod(self,
                    origin,
                    class_getMethodImplementation(self, origin),
                    method_getTypeEncoding(originMethod));
    class_addMethod(self,
                    alter,
                    class_getMethodImplementation(self, alter),
                    method_getTypeEncoding(alterMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(self, origin), class_getInstanceMethod(self, alter));
    return YES;
}

+ (BOOL)cw_classSwizzleOrigin:(SEL)origin withAlter:(SEL)alter error:(NSError**)error {
    return [object_getClass(self) cw_instanceSwizzleOrigin:origin withAlter:alter error:error];
}


@end
