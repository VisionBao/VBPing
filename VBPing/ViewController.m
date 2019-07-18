//
//  ViewController.m
//  VBPing
//
//  Created by VisionBao on 2019/3/28.
//  Copyright © 2019 VisionBao. All rights reserved.
//

#import "ViewController.h"
#import "VBPingManager/VBPingManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    VBPingManager *pingMgr = [[VBPingManager alloc] init];
//    [pingMgr startPing];
    pingMgr.pingFailureCallback = ^{
        NSLog(@"f");
    };
    pingMgr.pingSuccessCallback = ^{
        NSLog(@"t");
    };
    [pingMgr startPing];
}


@end
