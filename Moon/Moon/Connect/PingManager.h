//
//  PingManager.h
//  SpeedTunnel
//
//  Created by ZY on 2022/4/18.
//

#import <Foundation/Foundation.h>
#import "SimplePing.h"

NS_ASSUME_NONNULL_BEGIN
enum PingManagerStatus {
    start,
    failToSendPacket,
    receivePacket,
    receiveUnpectedPacket,
    timeout,
    error,
    finished
};

#ifdef DEBUG

#define NSLog(...) NSLog(__VA_ARGS__)

#else

#define NSLog(...)

#endif

@interface PingManagerItem : NSObject
@property (nonatomic, strong) NSString *hostName;
@property (nonatomic, assign) double singleTime;
@property (nonatomic, assign) enum PingManagerStatus status;
@end

@interface PingManager : NSObject <SimplePingDelegate>
@property (nonatomic, strong) NSString * _Nullable hostName;
@property (nonatomic, strong) SimplePing  * _Nullable smpinger;
@property (nonatomic, strong) NSTimer * _Nullable sendTimer;
@property (nonatomic, strong) NSDate * _Nullable startDate;
@property (nonatomic, strong) dispatch_source_t _Nullable sendPacketTimer;
@property (nonatomic, assign) NSInteger queueCount;


@property (nonatomic, copy) void (^ _Nullable pingRedultCallback)(PingManagerItem *item);
@property (nonatomic, assign) NSInteger count;
+ (instancetype)shared;
+ (instancetype)startPingHost:(NSString * _Nullable )host count:(NSInteger)count pingRedultCallback:(void(^ _Nullable)(PingManagerItem *item))callback ;
@end

NS_ASSUME_NONNULL_END
