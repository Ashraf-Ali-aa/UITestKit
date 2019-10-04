// SBTUITestTunnelClient.h
//
// Copyright (C) 2016 Subito.it S.r.l (www.subito.it)
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
#endif

#if ENABLE_UITUNNEL

#import "SBTUITestTunnelClientProtocol.h"

typedef enum: NSUInteger {
    SBTUITestTunnelErrorLaunchFailed = 101,
    SBTUITestTunnelErrorConnectionToApplicationFailed = 201,
    SBTUITestTunnelErrorOtherFailure = 301
} SBTUITestTunnelError;

@class SBTUITestTunnelClient;
@class XCUIApplication;

/**
 *  Create an instance of SBTUITestTunnelClientDelegate.
 *
 *  The methods adopted by the object you use to manage the application life-cycle usually an instance of XCUIApplication.
 */
@protocol SBTUITestTunnelClientDelegate <NSObject>

/**
 Informs the delegate that it should launch the XCUIApplication under-test before the tunnel is established.
 It's required that you avoid launching until the delegate is called.

 @param sender An instance of the object sending the message.
 */
- (void)testTunnelClientIsReadyToLaunch:(nonnull SBTUITestTunnelClient *)sender;
@optional

/**
 Informs the delegate than the tunnel did shutdown.

 @param sender An instance of the object sending the message.
 @param error If shutdown was due to an error will be non-nil, if shutdown was normal and expected then error will be nil.
 */
- (void)testTunnelClient:(nonnull SBTUITestTunnelClient *)sender didShutdownWithError:(NSError * _Nullable)error;
@end


/**
 *  An object that establises a tunnel between the test runner and application being tested for the purposes of stubbing network calls, interacting with user defaults and more.
 *
 *  See SBTUITestTunnelClientProtocol.h for full API documentation.
 *
 *  The following options can be set as `XCUIApplication.launchArguments` for additional behaviours:
 *  SBTUITunneledApplicationLaunchOptionResetFilesystem: delete app's filesystem sandbox
 *  SBTUITunneledApplicationLaunchOptionDisableUITextFieldAutocomplete disables UITextField's autocomplete functionality which can lead to unexpected results when typing text.
 */
@interface SBTUITestTunnelClient : NSObject

/**
 *  The object that acts as the delegate of the tunneled application.
 *
 *  The delegate must adopt the SBTUITunneledApplicationDelegate protocol. The delegate is not retained.
 */
@property (nonatomic, weak) id<SBTUITestTunnelClientDelegate> _Nullable delegate;

/**
 *  Create an instance of SBTUITestTunnelClient passing in an XCUIApplication to use.
 *
 *  @param application The instance of XCUIApplication.
 */
- (nonnull instancetype)initWithApplication:(nonnull XCUIApplication *)application;

- (void)launchTunnelWithStartupBlock:(void (^_Nullable)(void))startupBlock;
+ (void)setConnectionTimeout:(NSTimeInterval)timeout;
- (void)shutDownWithError:(nullable NSError *)error;

- (void)waitForAppReady;
- (NSString *_Nullable)stubRequestsMatching:(SBTRequestMatch *_Nonnull)match response:(SBTStubResponse *_Nonnull)response removeAfterIterations:(NSUInteger)iterations;

- (BOOL)stubRequestsRemoveAll;
//- (NSString *_Nonnull)base64SerializeObject:(id _Nonnull )obj;
- (NSString *_Nullable)base64SerializeObject:(id _Nullable )obj;

- (NSString *_Nullable)sendSynchronousRequestWithPath:(NSString *_Nonnull)path params:(NSDictionary<NSString *, NSString *> *_Nullable)params assertOnError:(BOOL)assertOnError;

- (NSString *_Nullable)sendSynchronousRequestWithPath:(NSString *_Nonnull)path params:(NSDictionary<NSString *, NSString *> *_Nullable)params;

- (void)waitForMonitoredRequestsMatching:(SBTRequestMatch *_Nonnull)match timeout:(NSTimeInterval)timeout completionBlock:(void (^_Nonnull)(BOOL timeout))completionBlock;

- (void)waitForMonitoredRequestsMatching:(SBTRequestMatch *_Nullable)match timeout:(NSTimeInterval)timeout iterations:(NSUInteger)iterations completionBlock:(void (^_Nonnull)(BOOL timeout))completionBlock;

- (BOOL)uploadItemAtPath:(NSString *_Nonnull)srcPath toPath:(NSString *_Nullable)destPath relativeTo:(NSSearchPathDirectory)baseFolder;
- (NSArray<NSData *> *_Nonnull)downloadItemsFromPath:(NSString *_Nullable)path relativeTo:(NSSearchPathDirectory)baseFolder;

- (NSArray<SBTMonitoredNetworkRequest *> *_Nullable)monitoredRequestsPeekAll;

- (BOOL)setUserInterfaceAnimationsEnabled:(BOOL)enabled;
- (BOOL)setUserInterfaceAnimationSpeed:(NSInteger)speed;
- (NSInteger)userInterfaceAnimationSpeed;
- (BOOL)userInterfaceAnimationsEnabled;
- (BOOL)scrollTableViewWithIdentifier:(nonnull NSString *)identifier toRow:(NSInteger)row animated:(BOOL)flag;
- (BOOL)scrollCollectionViewWithIdentifier:(nonnull NSString *)identifier toRow:(NSInteger)row animated:(BOOL)flag;
- (BOOL)scrollScrollViewWithIdentifier:(nonnull NSString *)identifier toElementWitIdentifier:(nonnull NSString *)targetIdentifier animated:(BOOL)flag;
- (BOOL)forcePressViewWithIdentifier:(nonnull NSString *)identifier;
- (BOOL)coreLocationStubEnabled:(BOOL)flag;
- (BOOL)coreLocationStubAuthorizationStatus:(CLAuthorizationStatus)status;
- (BOOL)coreLocationStubLocationServicesEnabled:(BOOL)flag;
- (BOOL)coreLocationNotifyLocationUpdate:(nonnull NSArray<CLLocation *>*)locations;
- (BOOL)coreLocationNotifyLocationError:(nonnull NSError *)error;
- (BOOL)notificationCenterStubEnabled:(BOOL)flag;
- (BOOL)notificationCenterStubAuthorizationStatus:(UNAuthorizationStatus)status;
@end

@interface SBTUITestTunnelClient() <NSNetServiceDelegate>
{
    BOOL _userInterfaceAnimationsEnabled;
    NSInteger _userInterfaceAnimationSpeed;
}

@property (nonatomic, weak) XCUIApplication * _Nullable application;
@property (nonatomic, assign) NSInteger connectionPort;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, assign) NSTimeInterval connectionTimeout;
@property (nonatomic, strong) NSMutableArray * _Nullable stubOnceIds;
@property (nonatomic, strong) NSString * _Nullable bonjourName;
@property (nonatomic, strong) NSNetService * _Nullable bonjourBrowser;
@property (nonatomic, strong) void (^ _Nullable startupBlock)(void);
@property (nonatomic, copy) NSArray<NSString *> * _Nullable initialLaunchArguments;
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> * _Nullable initialLaunchEnvironment;
@property (nonatomic, strong) NSString *_Nullable(^ _Nonnull connectionlessBlock)(NSString *_Nonnull, NSDictionary<NSString *, NSString *> *_Nonnull);

@property (nonatomic, assign) NSTimeInterval * _Nonnull SBTUITunneledApplicationDefaultTimeout;

@end
#endif
