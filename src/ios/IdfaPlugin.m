#import "IdfaPlugin.h"
#import <AdSupport/ASIdentifierManager.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@implementation IdfaPlugin

- (void)getInfo:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSString *idfaString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        BOOL enabled = [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
        NSDictionary* resultData;

        if (@available(iOS 14, *)) {
            NSNumber* trackingPermission = @(ATTrackingManager.trackingAuthorizationStatus);
            // workaround, as long as Apple deferred the roll-out of manadatory tracking permission popup
            // we'll assume that if the idfa string is not nullish, then it's allowed by user
            if (!enabled && idfaString != nil && ![@"00000000-0000-0000-0000-000000000000" isEqualToString:idfaString]) {
                enabled = YES;
            }

            resultData = @{
                @"idfa": idfaString,
                @"trackingLimited": [NSNumber numberWithBool:!enabled],
                @"trackingPermission": trackingPermission
            };
        } else {
            resultData = @{
                @"idfa": idfaString,
                @"trackingLimited": [NSNumber numberWithBool:!enabled]
            };
        }

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultData];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)requestPermission:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;

    if (@available(iOS 14, *)) {
        ATTrackingManagerAuthorizationStatus authStatus = ATTrackingManager.trackingAuthorizationStatus;

        switch (authStatus) {
            case ATTrackingManagerAuthorizationStatusAuthorized:
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
                break;
            case ATTrackingManagerAuthorizationStatusDenied:
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:2];
                break;
            case ATTrackingManagerAuthorizationStatusNotDetermined:
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
                break;
            case ATTrackingManagerAuthorizationStatusRestricted:
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:3];
                break;
        }
    } else {
        // Fallback on earlier versions
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Not available on this iOS version"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
