//
//  SubmitViewController.m
//  Stocktakr
//
//  Created by Sherman Lo on 17/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SubmitViewController.h"
#import "MBProgressHUD.h"
#import "ProductManager.h"
#import "Constants.h"


@interface SubmitViewController ()

@end

@implementation SubmitViewController

@synthesize nameField = nameField_;
@synthesize stocktakeRecordsLabel = stocktakeRecordsLabel_;


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Submit Records";
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.nameField becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Public methods

- (IBAction)submit:(UIButton *)button {
	[self.nameField resignFirstResponder];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *storeId = [userDefaults valueForKey:STORE_ID_KEY];
	NSString *password = [userDefaults valueForKey:PASSWORD_KEY];
	
	NSString *person = self.nameField.text;
	
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	hud.labelText = @"Submitting";
	[[ProductManager sharedManager] uploadStocktakeRecordsWithStoreId:storeId password:password person:person complete:^(BOOL success) {
		if (success) {
			hud.labelText = @"Successful";
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
				[MBProgressHUD hideHUDForView:self.navigationController.view animated:NO];
				[self.navigationController popViewControllerAnimated:YES];
			});
		} else {
			[MBProgressHUD hideHUDForView:self.navigationController.view animated:NO];

			[[[UIAlertView alloc] initWithTitle:@"Error Submitting" message:@"An error occurred while submitting records" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
		}
	}];
}

@end
