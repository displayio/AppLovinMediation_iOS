//
//  DisplayIOMediationAdapter.m
//  AppLovinMediation
//
//  Created by Ro Do on 04.04.2022.
//

#import "DisplayIOMediationAdapter.h"
#import <DIOSDK/DIOController.h>
#import <DIOSDK/DIOPlacement.h>
#import <DIOSDK/DIOBannerPlacement.h>
#import <DIOSDK/DIOMediumRectanglePlacement.h>
#import <DIOSDK/DIOInfeedPlacement.h>
#import <DIOSDK/DIOInterstitialPlacement.h>
#import <DIOSDK/DIOInterstitialHtml.h>
#import <DIOSDK/DIOInterstitialVast.h>
#import <DIOSDK/DIOInterscrollerPlacement.h>


@implementation DisplayIOMediationAdapter

DIOAd *dioAd;
- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    
    NSString* appID =  parameters.serverParameters[@"app_id"];
    [self log: @"Initializing DIO SDK adapter... "];
    completionHandler(MAAdapterInitializationStatusInitializing, nil);
    
    [[DIOController sharedInstance] initializeWithProperties:nil appId:appID completionHandler:^{
        completionHandler(MAAdapterInitializationStatusInitializedSuccess, nil);
        NSLog(@"=============== DIO SDK Initialized ===============");
    } errorHandler:^(NSError *error) {
        completionHandler(MAAdapterInitializationStatusInitializedFailure, nil);
        NSLog(@"=============== DIO SDK Initialization Fail ===============");
    }];
}

- (NSString *)SDKVersion
{
    return [DIOController sharedInstance].getSDKVersion;
}

- (NSString *)adapterVersion
{
    return [DIOController sharedInstance].getSDKVersion;
}

- (void)destroy
{
    NSLog(@"Destroy called for adapter %@", self);
    
    @try  {
        if (dioAd != nil && dioAd.impressed) {
            [dioAd finish];
            dioAd = nil;
        }
        
    } @catch(NSException *e) {
        NSLog(@"Failed to finish ad:  %@", e.description);
    }
}


- (void)loadInterstitialAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MAInterstitialAdapterDelegate>)delegate {
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    
    DIOPlacement *placement = [[DIOController sharedInstance] placementWithId:placementId];
    DIOAdRequest *adRequest = [placement newAdRequest];
    
    [adRequest requestAdWithAdReceivedHandler:^(DIOAdProvider *adProvider) {
        NSLog(@"AD RECEIVED");
        
        [adProvider loadAdWithLoadedHandler:^(DIOAd *ad) {
            NSLog(@"AD LOADED");
            dioAd = ad;
            
            if ([placement isKindOfClass:[DIOInterstitialPlacement class]]) {
                [delegate didLoadInterstitialAd];
            } else {
                [delegate didFailToDisplayInterstitialAdWithError:MAAdapterError.internalError];
            }
            
        } failedHandler:^(NSError *error){
            NSLog(@"AD FAILED TO LOAD: %@", error.localizedDescription);
            [delegate didFailToDisplayInterstitialAdWithError:MAAdapterError.internalError];
        }];
    } noAdHandler:^(NSError *error){
        NSLog(@"NO AD: %@", error.localizedDescription);
        [delegate didFailToDisplayInterstitialAdWithError:MAAdapterError.noFill];
    }];
}

- (void)showInterstitialAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MAInterstitialAdapterDelegate>)delegate {
    if (dioAd != nil ||
        [dioAd isKindOfClass:[DIOInterstitialHtml class]] ||
        [dioAd isKindOfClass:[DIOInterstitialVast class]]) {
        
        UIViewController *presentingViewController;
            if ( ALSdk.versionCode >= 11020199 )
            {
                presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
            }
            else
            {
                presentingViewController = [ALUtils topViewControllerFromKeyWindow];
            }
        
        [dioAd showAdFromViewController:presentingViewController eventHandler:^(DIOAdEvent event){
            switch (event) {
                case DIOAdEventOnShown:{
                    [delegate didDisplayInterstitialAd];
                    break;
                }
                case DIOAdEventOnFailedToShow:{
                    [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adDisplayFailedError];
                    break;
                }
                case DIOAdEventOnClicked:{
                    [delegate didClickInterstitialAd];
                    break;
                }
                case DIOAdEventOnClosed:{
                    [delegate didHideInterstitialAd];
                    break;
                }
                case DIOAdEventOnAdCompleted:{
                    NSLog(@"AD COMPLETED");
                    break;
                }
            }
        }];
        
    } else {
        [delegate didFailToDisplayInterstitialAdWithError:MAAdapterError.internalError];
    }
    
    
}

- (void)loadAdViewAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters adFormat:(nonnull MAAdFormat *)adFormat andNotify:(nonnull id<MAAdViewAdapterDelegate>)delegate {
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    
    DIOPlacement *placement = [[DIOController sharedInstance] placementWithId:placementId];
    DIOAdRequest *adRequest = [placement newAdRequest];
    
    [adRequest requestAdWithAdReceivedHandler:^(DIOAdProvider *adProvider) {
        NSLog(@"AD RECEIVED");
        
        [adProvider loadAdWithLoadedHandler:^(DIOAd *ad) {
            NSLog(@"AD LOADED");
            dioAd = ad;
            [ad setEventHandler:^(DIOAdEvent event) {
                switch (event) {
                    case DIOAdEventOnShown:
                        [delegate didDisplayAdViewAd];
                        break;
                    case DIOAdEventOnFailedToShow:{
                        [delegate didFailToDisplayAdViewAdWithError: MAAdapterError.adDisplayFailedError];
                        break;
                    }
                    case DIOAdEventOnClicked:
                        [delegate didClickAdViewAd];
                        break;
                    case DIOAdEventOnClosed:
                        [delegate didHideAdViewAd];
                        break;
                    case DIOAdEventOnAdCompleted:
                        NSLog(@"AD COMPLETED");
                        break;
                }
            }];
            if ([placement isKindOfClass:[DIOBannerPlacement class]] ||
                [placement isKindOfClass:[DIOMediumRectanglePlacement class]] ||
                [placement isKindOfClass:[DIOInFeedPlacement class]]) {
                
                UIView *adView = [ad view];
                [delegate didLoadAdForAdView: adView];
                
            } else if ([placement isKindOfClass:[DIOInterscrollerPlacement class]]) {
                
            } else {
                [delegate didFailToLoadAdViewAdWithError:MAAdapterError.internalError];
            }
            
        } failedHandler:^(NSError *error){
            NSLog(@"AD FAILED TO LOAD: %@", error.localizedDescription);
            [delegate didFailToLoadAdViewAdWithError:MAAdapterError.internalError];
        }];
    } noAdHandler:^(NSError *error){
        NSLog(@"NO AD: %@", error.localizedDescription);
        [delegate didFailToLoadAdViewAdWithError:MAAdapterError.noFill];
    }];
}


@end
