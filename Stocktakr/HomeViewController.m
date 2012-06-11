//
//  HomeViewController.m
//  Stocktakr
//
//  Created by Sherman Lo on 14/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeViewController.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "ProductManager.h"
#import "SettingsViewController.h"
#import "PriceCheckViewController.h"
#import "StocktakeViewController.h"
#import "PurchaseOrderViewController.h"


@interface HomeViewController ()

- (void)settings:(UIBarButtonItem *)barButton;

@end

@implementation HomeViewController


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Stocktakr";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Settings"] style:UIBarButtonItemStyleBordered target:self action:@selector(settings:)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Public methods

- (IBAction)priceCheck:(UIButton *)button {
	PriceCheckViewController *viewController = [[PriceCheckViewController alloc] initWithNibName:nil bundle:nil];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)performStocktake:(UIButton *)button {
	StocktakeViewController *viewController = [[StocktakeViewController alloc] init];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)purchaseOrder:(UIButton *)button {
	PurchaseOrderViewController *viewController = [[PurchaseOrderViewController alloc] init];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)downloadProducts:(UIButton *)button {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *storeId = [userDefaults valueForKey:STORE_ID_KEY];
	NSString *password = [userDefaults valueForKey:PASSWORD_KEY];
	
	if (![storeId length] || ![password length]) {
		[[[UIAlertView alloc] initWithTitle:@"Enter credentials" message:@"Enter your credentials in the settings  to get started" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
		
		return;
	}
	
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	hud.mode = MBProgressHUDModeAnnularDeterminate;
	hud.progress = 0.01;
	hud.labelText = @"Downloading";
	[[ProductManager sharedManager] loadProductListWithStoreId:storeId password:password complete:^(BOOL success) {
		hud.progress = 1.0;
		[MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
	} progress:^(double progress) {
		hud.progress = (float)progress;
	}];
}


#pragma mark - Private methods

- (void)settings:(UIBarButtonItem *)barButton {
	SettingsViewController *viewController = [[SettingsViewController alloc] initWithNibName:nil bundle:nil];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self presentModalViewController:navController animated:YES];
}

@end
