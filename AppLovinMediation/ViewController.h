//
//  ViewController.h
//  AppLovinMediation
//
//  Created by Ro Do on 04.04.2022.
//

#import <UIKit/UIKit.h>
#import <AppLovinSDK/AppLovinSDK.h>

@interface ViewController : UIViewController

+ (void)addCustomAdRequestDataForInterstitial:(nullable MAInterstitialAd *) interstitialAd forAdView:(nullable MAAdView *) adView;

@end

