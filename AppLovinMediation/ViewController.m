//
//  ViewController.m
//  AppLovinMediation
//
//  Created by Ro Do on 04.04.2022.
//

#import "ViewController.h"
#import "InterScrollerViewController.h"
#import <AppLovinSDK/AppLovinSDK.h>


@interface ViewController ()<MAAdViewAdDelegate, MAAdDelegate>
@property (weak, nonatomic) IBOutlet UIView *adContainer;
@property (weak, nonatomic) IBOutlet UIButton *bannerButton;
@property (weak, nonatomic) IBOutlet UIButton *mRectButton;
@property (weak, nonatomic) IBOutlet UIButton *inFeedButton;
@property (weak, nonatomic) IBOutlet UIButton *interstitialButton;
@property (weak, nonatomic) IBOutlet UIButton *interscrollerButton;

@property (nonatomic, strong) MAAdView *adView;
@property (nonatomic, strong) MAInterstitialAd *interstitialAd;

@end

@implementation ViewController

NSString *bannerID = @"6d11a7a95464e9d7";
NSString *mRectID = @"6160e3098704539f";
NSString *inFeedID = @"001bab17cbacdb55";
NSString *interstitialID = @"09971374de5dc75a";



- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)pressBannerButton:(id)sender {
    [self createInlineAd:bannerID];
}
- (IBAction)pressMediumRectButton:(id)sender {
    [self createInlineAd:mRectID];

}
- (IBAction)pressInFeedButton:(id)sender {
    [self createInlineAd:inFeedID];

}
- (IBAction)pressInterstitialButton:(id)sender {
    [self createInterstitialAd];
}

- (IBAction)interscrollerButtonWasPressed:(id)sender {
    InterScrollerViewController *vc = [InterScrollerViewController new];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)createInterstitialAd
{
    self.interstitialAd = [[MAInterstitialAd alloc] initWithAdUnitIdentifier: interstitialID];
    self.interstitialAd.delegate = self;

    // Load the first ad
    [self.interstitialAd loadAd];
}

- (void)createInlineAd:(NSString*)unitID
{
    [self.adContainer.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];

    self.adView = [[MAAdView alloc] initWithAdUnitIdentifier: unitID];
    self.adView.delegate = self;

    CGFloat height = 250;
    CGFloat width = CGRectGetWidth(UIScreen.mainScreen.bounds);
    self.adView.frame = CGRectMake(0, 0, width, height);
    self.adView.backgroundColor = UIColor.cyanColor;
    [self.adContainer addSubview: self.adView];

    // Load the ad
    [self.adView loadAd];
    self.adView.hidden = NO;
//    [self.adView startAutoRefresh];
}


- (void)didClickAd:(nonnull MAAd *)ad { 
    NSLog(@"didClickAd");
}

- (void)didDisplayAd:(nonnull MAAd *)ad { 
    NSLog(@"didDisplayAd");
}

- (void)didFailToDisplayAd:(nonnull MAAd *)ad withError:(nonnull MAError *)error { 
    NSLog(@"didFailToDisplayAd");
}

- (void)didFailToLoadAdForAdUnitIdentifier:(nonnull NSString *)adUnitIdentifier withError:(nonnull MAError *)error { 
    NSLog(@"didFailToLoadAdForAdUnitIdentifier");
    NSLog(@"Error: %@", error.message);

}

- (void)didHideAd:(nonnull MAAd *)ad { 
    NSLog(@"didHideAd");
}

- (void)didLoadAd:(nonnull MAAd *)ad { 
    NSLog(@"didLoadAd");
    if ( self.interstitialAd != nil && [self.interstitialAd isReady] )
    {
        [self.interstitialAd showAd];
    }
}

- (void)didCollapseAd:(nonnull MAAd *)ad { 
    NSLog(@"didCollapseAd");
}

- (void)didExpandAd:(nonnull MAAd *)ad { 
    NSLog(@"didExpandAd");
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder { 
    NSLog(@"encodeWithCoder");
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection { 
    NSLog(@"traitCollectionDidChange");
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container { 
    NSLog(@"preferredContentSizeDidChangeForChildContentContainer");
}

- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize { 
    NSLog(@"sizeForChildContentContainer");
    return parentSize;
}

- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container { 
    NSLog(@"systemLayoutFittingSizeDidChangeForChildContentContainer");
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator { 
    NSLog(@"viewWillTransitionToSize");
}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator { 
    NSLog(@"willTransitionToTraitCollection");
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator { 
    NSLog(@"didUpdateFocusInContext");
}

- (void)setNeedsFocusUpdate { 
    NSLog(@"setNeedsFocusUpdate");
}

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context { 
    NSLog(@"shouldUpdateFocusInContext");
    return NO;
}

- (void)updateFocusIfNeeded { 
    NSLog(@"updateFocusIfNeeded");
}

@end
