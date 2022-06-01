//
//  CheckSpeedUnit.h
//  skynet
//
//  Created by hero on 2021/7/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CheckSpeedUnit : NSObject

+ (instancetype)shared;

@property (nonatomic, copy, readonly) NSString *downloadSpeed;

@property (nonatomic, copy, readonly) NSString *uploadSpeed;

@property (nonatomic, copy) void (^networkSpeedCallback)(NSString *download, NSString *upload, uint32_t totalSpeed, NSString *totalSpeedString);

- (void)startMonitor;

- (void)stopMonitor;

@end

NS_ASSUME_NONNULL_END
