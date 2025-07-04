//
//  ViewController.m
//  AppLovinMediation
//
//  Created by Ro Do on 04.04.2022.
//
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import "ViewController.h"
#import "InlineViewController.h"
#import <DIOSDK/DIOController.h>
#import "DisplayIOMediationAdapter.h"


@interface ViewController ()<MAAdViewAdDelegate, MAAdDelegate, MARewardedAdDelegate>
@property (weak, nonatomic) IBOutlet UIButton *bannerButton;
@property (weak, nonatomic) IBOutlet UIButton *mRectButton;
@property (weak, nonatomic) IBOutlet UIButton *inFeedButton;
@property (weak, nonatomic) IBOutlet UIButton *interstitialButton;
@property (weak, nonatomic) IBOutlet UIButton *interscrollerButton;
@property (weak, nonatomic) IBOutlet UIButton *inlineButton;
@property (weak, nonatomic) IBOutlet UIButton *rvButton;
@property (strong, nonatomic)  UIView *adContainer;
@property (nonatomic, strong) MAAdView *adView;
@property (nonatomic, strong) MAInterstitialAd *interstitialAd;
@property (nonatomic, strong) MARewardedAd *rvAd;

@end

@implementation ViewController

NSString *bannerID = @"e37f5572855feab1";
NSString *mRectID = @"be4c536771ef3142";
NSString *inFeedID = @"fce17514958843dd";
NSString *interstitialID = @"88a2c8359162b418";
NSString *interscrollerlID = @"33df6d2f311a2004";
NSString *inlineID = @"17611d32a7cad853";
NSString *rvID = @"140a474097abb735";




- (void)viewDidLoad {
    [super viewDidLoad];
    [super viewDidLoad];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            NSLog(@"ATT STATUS = %ld", (long)status);
        }];
    });
    self.adContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen.bounds), 300)];
    [self.view addSubview: self.adContainer];
}

- (IBAction)pressBannerButton:(id)sender {
    [self createInlineAd:bannerID];
}
- (IBAction)pressMediumRectButton:(id)sender {
    [self createInlineAd:mRectID];
}
- (IBAction)pressInFeedButton:(id)sender {
    [self goToFeed:inFeedID type:@"IF"];
}
- (IBAction)pressInterstitialButton:(id)sender {
    [self createInterstitialAd];
}

- (IBAction)interscrollerButtonWasPressed:(id)sender {
    [self goToFeed:interscrollerlID type:@"IS"];
}

- (IBAction)inlineButtonWasPressed:(id)sender {
    [self goToFeed:inlineID type:@"IL"];
}

- (IBAction)rvButtonWasPressed:(id)sender {
    [self createRVAd];
}

- (void)goToFeed:(NSString*)adUnitID type: (NSString*)adUnitType{
    InlineViewController *vc = [InlineViewController new];
    vc.adUnitID = adUnitID;
    vc.adUnitType = adUnitType;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)createInterstitialAd
{
    if (!self.interstitialAd) {
        self.interstitialAd = [[MAInterstitialAd alloc] initWithAdUnitIdentifier: interstitialID];
        self.interstitialAd.delegate = self;
    }

    // Load the first ad
    [ViewController addCustomAdRequestDataForInterstitial:self.interstitialAd forAdView:nil];
    [self.interstitialAd loadAd];
}

- (void)createRVAd
{
    if (!self.rvAd) {
        self.rvAd = [MARewardedAd sharedWithAdUnitIdentifier: rvID];
        self.rvAd.delegate = self;
    }

    // Load the first ad
    [self.rvAd loadAd];
}

- (void)createInlineAd:(NSString*)unitID
{
    if (self.adView) {
//        [self.adView stopAutoRefresh];
        [self.adView removeFromSuperview];
        self.adView.delegate = nil;
        self.adView = nil;
    }
    self.adView = [[MAAdView alloc] initWithAdUnitIdentifier: unitID];
    self.adView.delegate = self;
    [self.adView setMultipleTouchEnabled:YES];
    [self.adView setUserInteractionEnabled:YES];

    self.adView.backgroundColor = UIColor.cyanColor;
    [self.adContainer addSubview: self.adView];
    self.adView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.adView.topAnchor constraintEqualToAnchor:self.adContainer.topAnchor constant:50].active = YES;
    [self.adView.bottomAnchor constraintEqualToAnchor:self.adContainer.bottomAnchor].active = YES;
    [self.adView.trailingAnchor constraintEqualToAnchor:self.adContainer.trailingAnchor].active = YES;
    [self.adView.leadingAnchor constraintEqualToAnchor:self.adContainer.leadingAnchor].active = YES;


    // Load the ad
    [ViewController addCustomAdRequestDataForInterstitial:nil forAdView:self.adView];
    [self.adView loadAd];
    self.adView.hidden = NO;
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
    if ( self.rvAd != nil && [self.rvAd isReady] )
    {
        [self.rvAd showAd];
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

#pragma mark - MARewardedAdDelegate Protocol

- (void)didRewardUserForAd:(MAAd *)ad withReward:(MAReward *)reward
{
    NSLog(@"didRewardUserForAd: label: %@,  amount: %ld", reward.label, (long)reward.amount);
}

+ (void)addCustomAdRequestDataForInterstitial:(nullable MAInterstitialAd *) interstitialAd forAdView:(nullable MAAdView *) adView {
    DIOAdRequest* adRequest = [[DIOAdRequest alloc] init];
    if (interstitialAd != nil) {
        [interstitialAd setLocalExtraParameterForKey:DIO_AD_REQUEST value:adRequest];
    }
    if (adView != nil) {
        [adView setLocalExtraParameterForKey:DIO_AD_REQUEST value:adRequest];
    }
}

@end
