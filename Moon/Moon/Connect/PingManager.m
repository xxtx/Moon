//
//  PingManager.m
//  SpeedTunnel
//
//  Created by ZY on 2022/4/18.
//

#import "PingManager.h"

@implementation PingManagerItem
@end

@implementation PingManager
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static PingManager * __instance = nil;
    dispatch_once(&onceToken, ^{
        __instance = [[PingManager alloc] init];
    });
    return __instance;
}

- (instancetype)initWithHost:(NSString *)host count:(NSInteger)count pingRedultCallback:(void(^)(PingManagerItem *item))callback {
    if (self = [super init]) {
        self.hostName = host;
        self.count = count;
        self.pingRedultCallback = callback;
        self.smpinger = [[SimplePing alloc] initWithHostName:host];
        self.smpinger.delegate = self;
        self.smpinger.addressStyle = SimplePingAddressStyleAny;
        [self.smpinger start];
    }
    return self;
}

+ (instancetype)startPingHost:(NSString *)host count:(NSInteger)count pingRedultCallback:(void(^)(PingManagerItem *item))callback {
    return [[self alloc] initWithHost:host count:count pingRedultCallback:callback];
}

- (void)clean:(enum PingManagerStatus)status {
    PingManagerItem *item = [[PingManagerItem alloc] init];
    item.hostName = self.hostName;
    item.status = status;
    if (self.pingRedultCallback && PingManager.shared.queueCount) {
        self.pingRedultCallback(item);
    }
    [self.smpinger stop];
    self.smpinger = nil;
    [self.sendTimer invalidate];
    self.sendTimer = nil;
    [self removePacketTimer];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pingTimeout) object:nil];
    self.hostName = nil;
    self.startDate = nil;
    self.pingRedultCallback = nil;
}

- (void)sendPing {
    if (self.count < 1) {
        [self stopPing];
        return;
    }
    self.count -= 1;
    self.startDate = NSDate.date;
    [self.smpinger sendPingWithData:nil];
    [self performSelector:@selector(pingTimeout) withObject:nil afterDelay:2];
}

- (void)stopPing {
    NSLog(@"[tunnel] Ping %@ STOP", self.hostName);
    [self clean: finished];
}

- (void)pingTimeout {
    NSLog(@"[tunnel] Ping %@ TIMEOUT", self.hostName);
    [self clean:timeout];
}

- (void)pingFail {
    NSLog(@"[tunnel] Ping %@ FAIL", self.hostName);
    [self clean:error];
}

- (void)addSendPacketTimer {
    dispatch_queue_t queue = dispatch_get_main_queue();
    self.sendPacketTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.sendPacketTimer, dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC) , DISPATCH_TIME_FOREVER, 0);
    dispatch_source_set_event_handler(self.sendPacketTimer, ^{
        [self clean:timeout];
    });
    dispatch_resume(self.sendPacketTimer);
}

- (void)removePacketTimer {
    if (self.sendPacketTimer) {
        dispatch_source_cancel(self.sendPacketTimer);
    }
}

#pragma mark - SimpingDelegate
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
    NSLog(@"[tunnel] Start Ping %@", self.hostName);
    [self sendPing];
    self.sendTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(smpinger) userInfo:nil repeats:YES];
    PingManagerItem *item = PingManagerItem.new;
    item.hostName = self.hostName;
    item.status = start;
    if (self.pingRedultCallback) {
        self.pingRedultCallback(item);
    }
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error {
    NSLog(@"[tunnel] Ping %@ Error:%@", self.hostName, error.localizedDescription);
    [self pingFail];
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pingTimeout) object:nil];
    NSLog(@"[tunnel] Ping %@ %hu send packet success", self.hostName, sequenceNumber);
    [self addSendPacketTimer];
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pingTimeout) object:nil];
    NSLog(@"[tunnel] send packet failed: %@ Error:%@", self.hostName, error.localizedDescription);
    [self clean:failToSendPacket];
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pingTimeout) object:nil];
    [self removePacketTimer];
    NSTimeInterval time = fabs(self.startDate.timeIntervalSinceNow * 1000);
    NSLog(@"[tunnel] %@ %hu received, size = %ld, time = %.2f", self.hostName,sequenceNumber, (unsigned long)packet.length, time > 999.9 ? 9999 : time);
    PingManagerItem *item = PingManagerItem.new;
    item.hostName = self.hostName;
    item.status = receivePacket;
    item.singleTime = time;
    if (self.pingRedultCallback) {
        self.pingRedultCallback(item);
    }
}

- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pingTimeout) object:nil];
//    NSLog(@"[tunnel] receive UNEXPECTED packet");
}

@end
