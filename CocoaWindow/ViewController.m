//
//  ViewController.m
//  CocoaWindow
//
//  Created by Sunny Young on 2018/10/27.
//  Copyright © 2018 Sunnyyoung. All rights reserved.
//

#import "ViewController.h"
#import "CocoaWindow.h"

@interface ViewController()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)toggleShowTitleButton:(NSButton *)sender {
    self.view.window.titleVisibility = sender.state == NSControlStateValueOn ? NSWindowTitleVisible : NSWindowTitleHidden;
}

- (IBAction)toggleTitleTransparentButton:(NSButton *)sender {
    self.view.window.titlebarAppearsTransparent = sender.state == NSControlStateValueOn;
}

- (IBAction)toggleHideDecorationViewButton:(NSButton *)sender {
    self.view.window.cw_isDecorationViewHidden = sender.state == NSControlStateValueOn;
}

- (IBAction)dragBlurSlider:(NSSlider *)sender {
    self.view.window.cw_blur = sender.doubleValue;
}

- (IBAction)dragTitlebarHeightSlider:(NSSlider *)sender {
    self.view.window.cw_titlebarHeight = sender.doubleValue;
}

- (IBAction)dragCloseButtonOffsetSlider:(NSSlider *)sender {
    self.view.window.cw_closeButtonOffset = sender.doubleValue;
}

- (IBAction)tapBackgroundColorButton:(NSColorWell *)sender {
    self.view.window.backgroundColor = [sender.color colorWithAlphaComponent:0.8];
}

@end
