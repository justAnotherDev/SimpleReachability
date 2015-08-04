//
//  SimpleReachability.m
//

#import "SimpleReachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>


SimpleReachabilityStatus reachabilityStatusForFlags(SCNetworkReachabilityFlags flags);
static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info);


@interface SimpleReachability()
@property (nonatomic) SCNetworkReachabilityRef reachabilityRef;
@property (nonatomic, strong) NSMutableDictionary *completionBlocks;
@end

@implementation SimpleReachability

+(id)addListener:(void (^)(SimpleReachabilityStatus))listener {
	if (!listener)
		return nil;
	
	NSString *uniqueIdentifier = [[NSUUID UUID] UUIDString];
	[[SimpleReachability sharedInstance].completionBlocks setObject:listener forKey:uniqueIdentifier];
	
	return uniqueIdentifier;
}

+(void)removeListener:(id)listenerObject {
	[[SimpleReachability sharedInstance].completionBlocks removeObjectForKey:listenerObject];
}

+(SimpleReachabilityStatus)currentStatus {
	SCNetworkReachabilityFlags flags;
	SCNetworkReachabilityGetFlags([SimpleReachability sharedInstance].reachabilityRef, &flags);
	
	return reachabilityStatusForFlags(flags);
}

+(instancetype)sharedInstance {
	static SimpleReachability *sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[SimpleReachability alloc] init];
	});
	
	return sharedInstance;
}

-(instancetype)init {
	self = [super init];
	if (!self)
		return nil;

	_completionBlocks = [NSMutableDictionary dictionary];
	
	// attempt to start listening to reachability changes
	if (![self _startNotifier]) {
		NSLog(@"SimpleReachability error: %s", SCErrorString(SCError()));
	}
	
	return self;
}

-(SCNetworkReachabilityRef)reachabilityRef {
	if (!_reachabilityRef) {
		struct sockaddr_in zeroAddress;
		bzero(&zeroAddress, sizeof(zeroAddress));
		zeroAddress.sin_len = sizeof(zeroAddress);
		zeroAddress.sin_family = AF_INET;
		
		_reachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zeroAddress);
	}
	return _reachabilityRef;
}

- (BOOL)_startNotifier {
	if (SCNetworkReachabilitySetCallback(self.reachabilityRef, ReachabilityCallback, NULL)) {
		if (SCNetworkReachabilityScheduleWithRunLoop(self.reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
			return YES;
		}
	}
	return NO;
}

@end



static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) {
	SimpleReachabilityStatus status = reachabilityStatusForFlags(flags);
	
	NSArray *completionBlocks = [[SimpleReachability sharedInstance].completionBlocks allValues];
	for (void(^completionBlock)(SimpleReachabilityStatus) in completionBlocks) {
		completionBlock(status);
	}
}

SimpleReachabilityStatus reachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
	// if cellular and not reachable then cellular data has been disabled
	if ((flags & kSCNetworkReachabilityFlagsIsWWAN) && (flags & kSCNetworkReachabilityFlagsReachable) == 0) {
		return SimpleReachabilityStatusCellularNoData;
	}
	
	// if on cellular
	if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
		return SimpleReachabilityStatusCellular;
	}
	
	// if not reachable
	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
		return SimpleReachabilityStatusDisconnected;
	}
	
	// must be on wifi
	return SimpleReachabilityStatusWifi;
}
