

#import "ViewController.h"
#import "InterScrollerViewController.h"
#import <DIOSDK/DIOController.h>
#import <DIOSDK/DIOInterscrollerView.h>
#import <AppLovinSDK/AppLovinSDK.h>


@interface InterScrollerViewController () <MAAdViewAdDelegate>

@property (nonatomic, strong) MAAdView *adView;

@end

@implementation InterScrollerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(close:)];

    self.navigationController.navigationBar.translucent = NO;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell1"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell2"];
    
    [self createInlineAd];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)createInlineAd {
    self.adView = [[MAAdView alloc] initWithAdUnitIdentifier: self.adUnitID];
    self.adView.translatesAutoresizingMaskIntoConstraints = NO;
    self.adView.delegate = self;
    //add custom ad request data (optional)
    [ViewController addCustomAdRequestDataForInterstitial:nil forAdView:self.adView];
    // Load the ad
    [self.adView loadAd];
    self.adView.hidden = NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 139;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 25) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        [cell.contentView addSubview:self.adView];
        self.adView.translatesAutoresizingMaskIntoConstraints = NO;

        [cell.contentView.leadingAnchor constraintEqualToAnchor:self.adView.leadingAnchor].active = YES;
        [cell.contentView.trailingAnchor constraintEqualToAnchor:self.adView.trailingAnchor].active = YES;
        [cell.contentView.topAnchor constraintEqualToAnchor:self.adView.topAnchor].active = YES;
        [cell.contentView.bottomAnchor constraintEqualToAnchor:self.adView.bottomAnchor].active = YES;

        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = @"Simple Cell";
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 25 && [self.adUnitType isEqual:@"IF"]) {
        return 250;
    }
    return UITableViewAutomaticDimension;
}

- (void)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [[DIOController sharedInstance] finishAllAds];
}

#pragma mark MAAdViewAdDelegate implementation
- (void)didClickAd:(nonnull MAAd *)ad {
    NSLog(@"didClickAd");
}

- (void)didDisplayAd:(nonnull MAAd *)ad {
    NSLog(@"didDisplayAd");
    //must be set for ad unit at the AppLovin dashboard
    if ([ad.networkName isEqual:@"DisplayIO"]) {
//        [self.adView stopAutoRefresh];  //IMPORTANT: Intersroller ads should not use AutoRefresh
    }
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
    NSLog(@"ad.networkName: %@", ad.networkName);
    NSLog(@"ad.networkPlacement: %@", ad.networkPlacement);
    NSLog(@"didLoadAd");
    NSLog(@"adView:  %@", _adView);
    if ([ad.networkName isEqual:@"DisplayIO"]) {
//        [self.tableView reloadData];
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
