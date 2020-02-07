//
//  CocoaWindow.m
//  CocoaWindow
//
//  Created by Sunny Young on 2018/10/22.
//  Copyright © 2018 Sunnyyoung. All rights reserved.
//

#import "CocoaWindow.h"
#import "NSObject+Swizzle.h"

typedef CGError CGSSetWindowBackgroundBlurRadiusFunction(CGSConnectionID cid, CGSWindowID wid, NSUInteger blur);

static void *GetFunctionByName(NSString *library, char *func) {
    CFBundleRef bundle;
    CFURLRef bundleURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef) library, kCFURLPOSIXPathStyle, true);
    CFStringRef functionName = CFStringCreateWithCString(kCFAllocatorDefault, func, kCFStringEncodingASCII);
    bundle = CFBundleCreate(kCFAllocatorDefault, bundleURL);
    void *f = NULL;
    if (bundle) {
        f = CFBundleGetFunctionPointerForName(bundle, functionName);
        CFRelease(bundle);
    }
    CFRelease(functionName);
    CFRelease(bundleURL);
    return f;
}

CGSSetWindowBackgroundBlurRadiusFunction* GetCGSSetWindowBackgroundBlurRadiusFunction(void) {
    static BOOL tried = NO;
    static CGSSetWindowBackgroundBlurRadiusFunction *function = NULL;
    if (!tried) {
        function  = GetFunctionByName(@"/System/Library/Frameworks/ApplicationServices.framework", "CGSSetWindowBackgroundBlurRadius");
        tried = YES;
    }
    return function;
}

@interface NSFrameView : NSView
@end

@interface NSTitledFrame : NSFrameView
@end

@interface NSThemeFrame : NSTitledFrame
@end

@interface NSThemeFrame (CocoaWindow)

@property (nonatomic, assign) BOOL cw_isDecorationViewHidden;
@property (nonatomic, assign) CGFloat cw_titlebarHeight;
@property (nonatomic, assign) CGFloat cw_closeButtonOffset;

@end

@implementation NSThemeFrame (CocoaWindow)

+ (void)load {
    [self cw_instanceSwizzleOrigin:NSSelectorFromString(@"_titlebarHeight") withAlter:@selector(_cw_titlebarHeight) error:nil];
    [self cw_instanceSwizzleOrigin:NSSelectorFromString(@"_closeButtonOrigin") withAlter:@selector(_cw_closeButtonOrigin) error:nil];
    [self cw_instanceSwizzleOrigin:NSSelectorFromString(@"_minYTitlebarButtonsOffset") withAlter:@selector(_cw_minYTitlebarButtonsOffset) error:nil];
}

#pragma mark - Swizzling method

- (CGFloat)_cw_titlebarHeight {
    return self.cw_titlebarHeight > 0.0 ? self.cw_titlebarHeight : [self _cw_titlebarHeight];
}

- (CGPoint)_cw_closeButtonOrigin {
    CGPoint origin = [self _cw_closeButtonOrigin];
    if (self.cw_closeButtonOffset > 0.0) {
        origin.x = self.cw_closeButtonOffset;
    }
    return origin;
}

- (CGFloat)_cw_minYTitlebarButtonsOffset {
    // find the height of the window buttons. only do this once to not kill performance
    static CGFloat titlebarButtonHeight;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSButton *button = [NSWindow standardWindowButton:NSWindowCloseButton forStyleMask:self.window.styleMask];
        titlebarButtonHeight = button.frame.size.height;
    });
    
    return self.cw_titlebarHeight > 0.0 ? (-self.cw_titlebarHeight + titlebarButtonHeight) / 2.0 : [self _cw_minYTitlebarButtonsOffset];
}

#pragma mark - Private method

- (void)setDecorationViewHidden:(BOOL)hidden inView:(NSView *)view {
    if (view.subviews.count == 0) {
        return ;
    }
    for (NSView *subview in view.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"_NSTitlebarDecorationView")]) {
            subview.hidden = hidden;
            return ;
        } else {
            [self setDecorationViewHidden:hidden inView:subview];
        }
    }
}

- (BOOL)getDecorationViewHiddenInView:(NSView *)view {
    if (view.subviews.count == 0) {
        return YES;
    }
    for (NSView *subview in view.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"_NSTitlebarDecorationView")]) {
            return subview.isHidden;
        } else {
            return [self getDecorationViewHiddenInView:subview];
        }
    }
    return YES;
}

- (void)layoutTitleBarButtons {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL selector = NSSelectorFromString(@"_resetTitleBarButtons");
    if ([self respondsToSelector:selector]) {
        [self performSelector:NSSelectorFromString(@"_resetTitleBarButtons")];
    }
#pragma clang diagnostic pop
}

#pragma mark - Property method

- (BOOL)cw_isDecorationViewHidden {
    return [self getDecorationViewHiddenInView:self];
}

- (void)setCw_isDecorationViewHidden:(BOOL)isDecorationViewHidden {
    [self setDecorationViewHidden:isDecorationViewHidden inView:self];
}

- (CGFloat)cw_titlebarHeight {
    return [objc_getAssociatedObject(self, @selector(cw_titlebarHeight)) doubleValue];
}

- (void)setCw_titlebarHeight:(CGFloat)titlebarHeight {
    objc_setAssociatedObject(self, @selector(cw_titlebarHeight), @(titlebarHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self layoutTitleBarButtons];
}

- (CGFloat)cw_closeButtonOffset {
    return [objc_getAssociatedObject(self, @selector(cw_closeButtonOffset)) doubleValue];
}

- (void)setCw_closeButtonOffset:(CGFloat)closeButtonOffset {
    objc_setAssociatedObject(self, @selector(cw_closeButtonOffset), @(closeButtonOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self layoutTitleBarButtons];
}

@end

@implementation NSWindow (CocoaWindow)

#pragma mark - Property method

- (NSThemeFrame *)themeFrame {
    return (NSThemeFrame *)self.contentView.superview;
}

- (BOOL)cw_isDecorationViewHidden {
    return self.themeFrame.cw_isDecorationViewHidden;
}

- (void)setCw_isDecorationViewHidden:(BOOL)isDecorationViewHidden {
    self.themeFrame.cw_isDecorationViewHidden = isDecorationViewHidden;
}

- (CGFloat)cw_titlebarHeight {
    return self.themeFrame.cw_titlebarHeight;
}

- (void)setCw_titlebarHeight:(CGFloat)titlebarHeight {
    self.themeFrame.cw_titlebarHeight = titlebarHeight;
}

- (CGFloat)cw_closeButtonOffset {
    return self.themeFrame.cw_closeButtonOffset;
}

- (void)setCw_closeButtonOffset:(CGFloat)closeButtonOffset {
    self.themeFrame.cw_closeButtonOffset = closeButtonOffset;
}

- (CGFloat)cw_blur {
    return [objc_getAssociatedObject(self, @selector(cw_blur)) doubleValue];
}

- (void)setCw_blur:(CGFloat)blur {
    objc_setAssociatedObject(self, @selector(cw_blur), @(blur), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    GetCGSSetWindowBackgroundBlurRadiusFunction()(CGSMainConnectionID(), (CGSWindowID)self.windowNumber, blur);
}

@end
