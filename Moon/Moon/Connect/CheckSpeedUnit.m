//
//  CheckSpeedUnit.m
//  skynet
//
//  Created by hero on 2021/7/20.
//

#import "CheckSpeedUnit.h"
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <net/if_dl.h>

@interface CheckSpeedUnit ()

@property (nonatomic, assign) uint32_t iBytes;
@property (nonatomic, assign) uint32_t oBytes;
@property (nonatomic, assign) uint32_t aBytes;

@property (nonatomic, assign) uint32_t wifiIBytes;
@property (nonatomic, assign) uint32_t wifiOBytes;
@property (nonatomic, assign) uint32_t wifiABytes;

@property (nonatomic, assign) uint32_t wwanIBytes;
@property (nonatomic, assign) uint32_t wwanOBytes;
@property (nonatomic, assign) uint32_t wwanABytes;

@property (nonatomic, strong) NSTimer *timer;

@end

static CheckSpeedUnit *_instance = nil;
@implementation CheckSpeedUnit

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _iBytes = _oBytes = _aBytes = _wifiIBytes = _wifiOBytes = _wifiABytes = _wwanABytes = _wwanIBytes = _wwanOBytes = 0;
    }
    return self;
}

- (void)startMonitor {
    if (self.timer) {
        return;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkSpeed) userInfo:nil repeats:YES];
    [self.timer fire];
}

- (void)stopMonitor {
    [self.timer invalidate];
    self.timer = nil;
    _iBytes = _oBytes = _aBytes = _wifiIBytes = _wifiOBytes = _wifiABytes = _wwanABytes = _wwanIBytes = _wwanOBytes = 0;
}

- (NSString*)stringWithbytes:(int)bytes {
    if (bytes < 1024) {
        return [NSString stringWithFormat:@"%dB", bytes];
    } else if (bytes >= 1024 && bytes < 1024 * 1024) {
        return [NSString stringWithFormat:@"%.1fKB", (double)bytes / 1024];
    } else if (bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024) {
        return [NSString stringWithFormat:@"%.1fMB", (double)bytes / (1024 * 1024)];
    } else {
        return [NSString stringWithFormat:@"%.1fGB", (double)bytes / (1024 * 1024 * 1024)];
    }
}

- (void)checkSpeed {
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1) {
        return;
    }
    uint32_t iBytes = 0;
    uint32_t oBytes = 0;
    uint32_t allFlow = 0;
    uint32_t wifiIBytes = 0;
    uint32_t wifiOBytes = 0;
    uint32_t wifiFlow = 0;
    uint32_t wwanIBytes = 0;
    uint32_t wwanOBytes = 0;
    uint32_t wwanFlow = 0;

    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next) {
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;

        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        
        if (ifa->ifa_data == 0)
            continue;

        // network
        if (strncmp(ifa->ifa_name, "lo", 2)) {
            struct if_data* if_data = (struct if_data*)ifa->ifa_data;
            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
            allFlow = iBytes + oBytes;
        }

        //wifi
        if (!strcmp(ifa->ifa_name, "en0")) {
            struct if_data* if_data = (struct if_data*)ifa->ifa_data;
            wifiIBytes += if_data->ifi_ibytes;
            wifiOBytes += if_data->ifi_obytes;
            wifiFlow = wifiIBytes + wifiOBytes;
        }

        //3G or gprs
        if (!strcmp(ifa->ifa_name, "pdp_ip0")) {
            struct if_data* if_data = (struct if_data*)ifa->ifa_data;
            wwanIBytes += if_data->ifi_ibytes;
            wwanOBytes += if_data->ifi_obytes;
            wwanFlow = wwanIBytes + wwanOBytes;
        }
    }

    freeifaddrs(ifa_list);

    uint32_t dSpeed = 0;
    uint32_t uSpeed = 0;
    
    if (_iBytes != 0) {
        dSpeed = iBytes - _iBytes;
        _downloadSpeed = [[self stringWithbytes:iBytes - _iBytes] stringByAppendingString:@"/s"];
    } else {
        _downloadSpeed = @"0b/s";
    }
    _iBytes = iBytes;
    if (_oBytes != 0) {
        uSpeed = oBytes - _oBytes;
        _uploadSpeed = [[self stringWithbytes:oBytes - _oBytes] stringByAppendingString:@"/s"];
    } else {
        _uploadSpeed = @"0b/s";
    }
    _oBytes = oBytes;
    
    if (self.networkSpeedCallback) {
        self.networkSpeedCallback(_downloadSpeed, _uploadSpeed, dSpeed + uSpeed, [[self stringWithbytes:(dSpeed + uSpeed)] stringByAppendingFormat:@"/s"]);
    }
}


@end
