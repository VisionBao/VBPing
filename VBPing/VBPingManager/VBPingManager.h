//
//  VBPingManager.h
//  VBPing
//
//  Created by VisionBao on 2019/3/28.
//  Copyright © 2019 VisionBao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^PingSuccessCallback)(void);
typedef void(^PingFailureCallback)(void);
@interface VBPingManager : NSObject

@property (nonatomic, copy) PingSuccessCallback pingSuccessCallback;
@property (nonatomic, copy) PingFailureCallback pingFailureCallback;
- (void)startPing;
@end

NS_ASSUME_NONNULL_END
