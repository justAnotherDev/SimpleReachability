//
//  SimpleReachability.h
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SimpleReachabilityStatus) {
    SimpleReachabilityStatusWifi,
    SimpleReachabilityStatusCellular,
    SimpleReachabilityStatusCellularNoData,
    SimpleReachabilityStatusDisconnected
};

@interface SimpleReachability : NSObject

/*!
 @brief Retrieve the current reachability status.
 */
+(SimpleReachabilityStatus)currentStatus;

/*!
 @brief Receive updates when the reachability status changes.
 @param listener The block to execute when reachability changes.
 @return The observer object. Use this object to stop receiving updates.
 */
+(id)addListener:(void(^)(SimpleReachabilityStatus currentStatus))listener;

/*!
 @brief Stop receiving updates.
 @param observerObject The observer object that was returned from @c addListener:
 */
+(void)removeListener:(id)observerObject;

@end
