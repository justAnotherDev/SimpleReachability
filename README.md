# SimpleReachability
Reachability class for iOS

## Why?
Everyone uses Reachability.h, but it's not great. This class helps to simplify it while adding new functionality.

## New Functionality?
If cellular data is disabled for your app via Settings.app Reachability.h will still return as reachable and connected to cellular! This class adds a new enum ```SimpleReachabilityStatusCellularNoData``` to help detect this state.

## Usage
```objc
// query current reachability
SimpleReachabilityStatus status = [SimpleReachability currentStatus];

// listen to reachability changes
@property (nonatomic, strong) id reachabilityObserver;
self.reachabilityObserver = [SimpleReachability addListener:^(SimpleReachabilityStatus currentStatus) {
		// do something w/ updated status here
}];

// stop listening to reachability changes
[SimpleReachability removeListener:self.reachabilityObserver];
```

## Available Statuses

| Status        					| Description           				|
| ------------- 					|:-------------:|
| <b>SimpleReachabilityStatusDisconnected</b>		| Device is not reachable.				|
| <b>SimpleReachabilityStatusCellular</b>		| Device is connected to WWAN and is reachable.		|
| <b>SimpleReachabilityStatusCellularNoData</b>		| Device is connected to WWAN but is NOT reachable. Likely that the user has disabled cellular data. |
| <b>SimpleReachabilityStatusWifi</b>			| Device is connected to Wifi network.			|
