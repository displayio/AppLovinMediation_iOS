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
        [self log: @"DIO SDK Initialized"];
    } errorHandler:^(NSError *error) {
        completionHandler(MAAdapterInitializationStatusInitializedFailure, nil);
        [self log: @"DIO SDK Initialization Fail"];
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
    if (dioAd != nil && dioAd.impressed) {
        [dioAd finish];
        dioAd = nil;
    }
}


- (void)loadInterstitialAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MAInterstitialAdapterDelegate>)delegate {
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    
    DIOPlacement *placement = [[DIOController sharedInstance] placementWithId:placementId];
    DIOAdRequest *adRequest = [placement newAdRequest];
    
    [adRequest requestAdWithAdReceivedHandler:^(DIOAdProvider *adProvider) {
        [self log: @"AD RECEIVED"];
        
        [adProvider loadAdWithLoadedHandler:^(DIOAd *ad) {
            [self log: @"AD LOADED"];
            dioAd = ad;
            
            if ([placement isKindOfClass:[DIOInterstitialPlacement class]]) {
                [delegate didLoadInterstitialAd];
            } else {
                [delegate didFailToDisplayInterstitialAdWithError:MAAdapterError.internalError];
            }
            
        } failedHandler:^(NSError *error){
            [self log: @"AD FAILED TO LOAD: %@", error.localizedDescription];
            [delegate didFailToDisplayInterstitialAdWithError:MAAdapterError.internalError];
        }];
    } noAdHandler:^(NSError *error){
        [self log: @"NO AD: %@", error.localizedDescription];
        [delegate didFailToDisplayInterstitialAdWithError:MAAdapterError.noFill];
    }];
}

- (void)showInterstitialAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MAInterstitialAdapterDelegate>)delegate {
    if (dioAd != nil ||
        [dioAd isKindOfClass:[DIOInterstitialHtml class]] ||
        [dioAd isKindOfClass:[DIOInterstitialVast class]]) {
        
        UIViewController *presentingViewController;
        if ( ALSdk.versionCode >= 11020199 ) {
            presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        } else {
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
                case DIOAdEventOnClosed:
                case DIOAdEventOnAdCompleted:{
                    [delegate didHideInterstitialAd];
                    break;
                }
                
                case DIOAdEventOnSwipedOut:
                case DIOAdEventOnSnapped:
                case DIOAdEventOnMuted:
                case DIOAdEventOnUnmuted:
                    break;
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
    
    if([placement isKindOfClass: DIOInterscrollerPlacement.class]) {
        DIOInterscrollerContainer *container = [[DIOInterscrollerContainer alloc] init];
        [container loadWithAdRequest:adRequest completionHandler:^(DIOAd *ad){
            UIView *adView = [container view];
            [delegate didLoadAdForAdView: adView];
        } errorHandler:^(NSError *error) {
            [self log: @"NO AD: %@", error.localizedDescription];
            [delegate didFailToLoadAdViewAdWithError:MAAdapterError.noFill];
            
        }];
    } else if ([placement isKindOfClass: DIOInFeedPlacement.class]
               || [placement isKindOfClass: DIOMediumRectanglePlacement.class]
               || [placement isKindOfClass: DIOBannerPlacement.class]){
        [adRequest requestAdWithAdReceivedHandler:^(DIOAdProvider *adProvider) {
            [self log: @"AD RECEIVED"];
            
            [adProvider loadAdWithLoadedHandler:^(DIOAd *ad) {
                [self log: @"AD LOADED"];
                dioAd = ad;
                [self handleInlineAdEvents:ad andNotify:delegate];
                
                UIView *adView = [ad view];
                [delegate didLoadAdForAdView: adView];
                
            } failedHandler:^(NSError *error){
                [self log: @"AD FAILED TO LOAD: %@", error.localizedDescription];
                [delegate didFailToLoadAdViewAdWithError:MAAdapterError.internalError];
            }];
        } noAdHandler:^(NSError *error){
            [self log: @"NO AD: %@", error.localizedDescription];
            [delegate didFailToLoadAdViewAdWithError:MAAdapterError.noFill];
        }];
    } else {
        [delegate didFailToLoadAdViewAdWithError:MAAdapterError.internalError];
    }
}

- (void)handleInlineAdEvents:(DIOAd *)ad andNotify:(nonnull id<MAAdViewAdapterDelegate>)inlineDelegate{
    if(ad == nil || inlineDelegate == nil) {
        return;
    }
    
    [ad setEventHandler:^(DIOAdEvent event) {
        switch (event) {
            case DIOAdEventOnShown:
                [inlineDelegate didDisplayAdViewAd];
                break;
            case DIOAdEventOnFailedToShow:{
                [inlineDelegate didFailToDisplayAdViewAdWithError: MAAdapterError.adDisplayFailedError];
                break;
            }
            case DIOAdEventOnClicked:
                [inlineDelegate didClickAdViewAd];
                break;
            case DIOAdEventOnClosed:
                [inlineDelegate didHideAdViewAd];
                break;
            case DIOAdEventOnAdCompleted:
            case DIOAdEventOnSwipedOut:
            case DIOAdEventOnSnapped:
            case DIOAdEventOnMuted:
            case DIOAdEventOnUnmuted:
                break;
        }
    }];
}


@end
