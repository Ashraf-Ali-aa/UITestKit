// CLLocationManager+Swizzles.m
//
// Copyright (C) 2019 Subito.it S.r.l (www.subito.it)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#if DEBUG
    #ifndef ENABLE_UITUNNEL
        #define ENABLE_UITUNNEL 1
    #endif

    #ifndef ENABLE_UITUNNEL_SWIZZLING
        #define ENABLE_UITUNNEL_SWIZZLING 1
    #endif
#endif

#if ENABLE_UITUNNEL && ENABLE_UITUNNEL_SWIZZLING

#import "CLLocationManager+Swizzles.h"
#import <UITestKitCommon/SBTSwizzleHelpers.h>
#import <CoreLocation/CLLocationManagerDelegate.h>

static NSMapTable *_instanceHashTable;
static NSString *_autorizationStatus;
static NSString *_serviceStatus;

@implementation CLLocationManager (Swizzles)

- (void)swz_startMonitoring
{
    [_instanceHashTable setObject:[_instanceHashTable objectForKey:self] forKey:self];
}

- (void)swz_startUpdatingLocation
{
    [_instanceHashTable setObject:[_instanceHashTable objectForKey:self] forKey:self];
}

- (void)swz_startUpdatingHeading
{
    [_instanceHashTable setObject:[_instanceHashTable objectForKey:self] forKey:self];
}

- (void)swz_requestLocation
{
    [_instanceHashTable setObject:[_instanceHashTable objectForKey:self] forKey:self];
}

- (void)swz_requestAlwaysAuthorization
{
    [_instanceHashTable setObject:[_instanceHashTable objectForKey:self] forKey:self];
}

- (void)swz_requestWhenInUseAuthorization
{
    [_instanceHashTable setObject:[_instanceHashTable objectForKey:self] forKey:self];
}

- (void)swz_stopMonitoring
{
    [_instanceHashTable removeObjectForKey:self];
}

- (void)swz_stopUpdatingLocation
{
    [_instanceHashTable removeObjectForKey:self];
}

- (void)swz_stopUpdatingHeading
{
    [_instanceHashTable removeObjectForKey:self];
}

+ (CLAuthorizationStatus)swz_authorizationStatus
{
    NSString *defaultStatus = [@(kCLAuthorizationStatusAuthorizedAlways) stringValue];
    NSInteger status = (_autorizationStatus.length > 0 ? _autorizationStatus : defaultStatus).intValue;
    return (CLAuthorizationStatus)status;
}

+ (BOOL)swz_locationServicesEnabled
{
    NSString *defaultStatus = @"YES";
    BOOL status = [(_serviceStatus ?: defaultStatus) isEqualToString:@"YES"];
    return (CLAuthorizationStatus)status;
}

- (void)swz_setDelegate:(id<CLLocationManagerDelegate>)delegate
{
    [_instanceHashTable setObject:delegate forKey:self];
}

- (id<CLLocationManagerDelegate>)stubbedDelegate
{
    return [_instanceHashTable objectForKey:self];
}

+ (void)loadSwizzlesWithInstanceHashTable:(NSMapTable<CLLocationManager *, id<CLLocationManagerDelegate>>*)hashTable authorizationStatus:(NSString *)autorizationStatus
{
    _instanceHashTable = hashTable;
    _autorizationStatus = autorizationStatus;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SBTTestTunnelInstanceSwizzle(self.class, @selector(startMonitoring), @selector(swz_startMonitoring));
        SBTTestTunnelInstanceSwizzle(self.class, @selector(startUpdatingLocation), @selector(swz_startUpdatingLocation));
        SBTTestTunnelInstanceSwizzle(self.class, @selector(startUpdatingHeading), @selector(swz_startUpdatingHeading));
        SBTTestTunnelInstanceSwizzle(self.class, @selector(stopMonitoring), @selector(swz_stopMonitoring));
        SBTTestTunnelInstanceSwizzle(self.class, @selector(stopUpdatingLocation), @selector(swz_stopUpdatingLocation));
        SBTTestTunnelInstanceSwizzle(self.class, @selector(stopUpdatingHeading), @selector(swz_stopUpdatingHeading));
        SBTTestTunnelInstanceSwizzle(self.class, @selector(requestLocation), @selector(swz_requestLocation));
        SBTTestTunnelInstanceSwizzle(self.class, @selector(requestAlwaysAuthorization), @selector(swz_requestAlwaysAuthorization));
        SBTTestTunnelInstanceSwizzle(self.class, @selector(requestWhenInUseAuthorization), @selector(swz_requestWhenInUseAuthorization));
        SBTTestTunnelInstanceSwizzle(self.class, @selector(setDelegate:), @selector(swz_setDelegate:));

        SBTTestTunnelClassSwizzle(self, @selector(authorizationStatus), @selector(swz_authorizationStatus));
        SBTTestTunnelClassSwizzle(self, @selector(locationServicesEnabled), @selector(swz_locationServicesEnabled));
    });
}

+ (void)removeSwizzles
{
    [_instanceHashTable removeAllObjects];
    
    // Repeat swizzle to restore default implementation
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SBTTestTunnelInstanceSwizzle(self.class, @selector(startMonitoring), @selector(swz_startMonitoring));
        SBTTestTunnelInstanceSwizzle(self.class, @selector(startUpdatingLocation), @selector(swz_startUpdatingLocation));
        SBTTestTunnelInstanceSwizzle(self.class, @selector(startUpdatingHeading), @selector(swz_startUpdatingHeading));
        SBTTestTunnelInstanceSwizzle(self.class, @selector(stopMonitoring), @selector(swz_stopMonitoring));
        SBTTestTunnelInstanceSwizzle(self.class, @selector(stopUpdatingLocation), @selector(swz_stopUpdatingLocation));
        SBTTestTunnelInstanceSwizzle(self.class, @selector(stopUpdatingHeading), @selector(swz_stopUpdatingHeading));
        SBTTestTunnelInstanceSwizzle(self.class, @selector(requestLocation), @selector(swz_requestLocation));
        SBTTestTunnelInstanceSwizzle(self.class, @selector(requestAlwaysAuthorization), @selector(swz_requestAlwaysAuthorization));
        SBTTestTunnelInstanceSwizzle(self.class, @selector(requestWhenInUseAuthorization), @selector(swz_requestWhenInUseAuthorization));
        SBTTestTunnelInstanceSwizzle(self.class, @selector(setDelegate:), @selector(swz_setDelegate:));

        SBTTestTunnelClassSwizzle(self, @selector(authorizationStatus), @selector(swz_authorizationStatus));
        SBTTestTunnelClassSwizzle(self, @selector(locationServicesEnabled), @selector(swz_locationServicesEnabled));
    });
}

@end

#endif
