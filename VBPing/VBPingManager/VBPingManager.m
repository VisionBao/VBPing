//
//  VBPingManager.m
//  VBPing
//
//  Created by VisionBao on 2019/3/28.
//  Copyright © 2019 VisionBao. All rights reserved.
//

#import "VBPingManager.h"
#import "SimplePing/SimplePing.h"
#include <netdb.h>

@interface VBPingManager ()<
    SimplePingDelegate
>
@property (nonatomic, strong) SimplePing *pinger;
@property (nonatomic, strong) NSTimer *sendTimer;
@end

@implementation VBPingManager

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *hostName = @"www.10010.com";
        self.pinger = [[SimplePing alloc] initWithHostName:hostName];
        self.pinger.addressStyle = SimplePingAddressStyleAny;
        self.pinger.delegate = self;
    }
    return self;
}

- (void)startPing {
    [self start];
}

- (void)start {
    [self.pinger start];
}

- (void)stop {
    [self.pinger stop];
    self.pinger = nil;
    
    if ([self.sendTimer isValid])
    {
        [self.sendTimer invalidate];
    }
    self.sendTimer = nil;
}

- (void)sendPing {
    [self.pinger sendPingWithData:nil];
}

#pragma mark - pinger delegate

- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
    NSLog(@"pinging %@", [self displayAddressForAddress:address]);
    
    [self sendPing];
    
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error {
    NSLog(@"failed: %@", [self shortErrorFromError:error]);
    
    [self stop];
    
    if (self.pingFailureCallback) {
        self.pingFailureCallback();
    }
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    NSLog(@"#%u sent", (unsigned int) sequenceNumber);
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error {
    NSLog(@"#%u send failed: %@", (unsigned int) sequenceNumber, [self shortErrorFromError:error]);
    
    [self stop];
    
    if (self.pingFailureCallback) {
        self.pingFailureCallback();
    }
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    NSLog(@"#%u received, size=%zu", (unsigned int) sequenceNumber, (size_t) packet.length);
    
    [self stop];
    
    if (self.pingSuccessCallback) {
        self.pingSuccessCallback();
    }
}

- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet {
    NSLog(@"unexpected packet, size=%zu", (size_t) packet.length);
    
    [self stop];
    
    if (self.pingSuccessCallback) {
        self.pingSuccessCallback();
    }
}

#pragma mark - Others mothods

/**
 * 将ping接收的数据转换成ip地址
 * @param address 接受的ping数据
 */
- (NSString *)displayAddressForAddress:(NSData *)address {
    int err;
    NSString *result;
    char hostStr[NI_MAXHOST];
    
    result = nil;
    
    if (address != nil) {
        err = getnameinfo([address bytes], (socklen_t)[address length], hostStr, sizeof(hostStr),
                          NULL, 0, NI_NUMERICHOST);
        if (err == 0) {
            result = [NSString stringWithCString:hostStr encoding:NSASCIIStringEncoding];
        }
    }
    
    if (result == nil) {
        result = @"?";
    }
    
    return result;
}

/*
 * 解析错误数据并翻译
 */
- (NSString *)shortErrorFromError:(NSError *)error {
    NSString *result;
    NSNumber *failureNum;
    int failure;
    const char *failureStr;
    
    result = nil;
    
    // Handle DNS errors as a special case.
    
    if ([[error domain] isEqual:(NSString *)kCFErrorDomainCFNetwork] &&
        ([error code] == kCFHostErrorUnknown)) {
        failureNum = [[error userInfo] objectForKey:(id)kCFGetAddrInfoFailureKey];
        if ([failureNum isKindOfClass:[NSNumber class]]) {
            failure = [failureNum intValue];
            if (failure != 0) {
                failureStr = gai_strerror(failure);
                if (failureStr != NULL) {
                    result = [NSString stringWithUTF8String:failureStr];
                }
            }
        }
    }
    
    if (result == nil) {
        result = [error localizedFailureReason];
    }
    if (result == nil) {
        result = [error localizedDescription];
    }
    if (result == nil) {
        result = [error description];
    }
    
    return result;
}
@end
