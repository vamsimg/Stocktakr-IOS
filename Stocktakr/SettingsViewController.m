//
//  SettingsViewController.m
//  Stocktakr
//
//  Created by Sherman Lo on 14/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "MBProgressHUD.h"
#import "ProductManager.h"
#import "Constants.h"


@interface SettingsViewController ()

- (void)close:(UIBarButtonItem *)barButton;
- (void)testConnectionWithStoreId:(NSString *)storeId password:(NSString *)password;

@end

@implementation SettingsViewController

@synthesize storeIdField = storeIdField_;
@synthesize passwordField = passwordField_;
@synthesize nameField = nameField_;
@synthesize setQuantitySwitch = setQuantitySwitch_;


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Settings";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(close:)];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	self.storeIdField.text = [userDefaults stringForKey:STORE_ID_KEY];
	self.passwordField.text = [userDefaults stringForKey:PASSWORD_KEY];
	self.nameField.text = [userDefaults stringForKey:NAME_KEY];
	self.setQuantitySwitch.on = [userDefaults boolForKey:SET_QUANTITY_KEY];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Public methods

- (IBAction)testConnection:(UIButton *)button {
	[self testConnectionWithStoreId:self.storeIdField.text password:self.passwordField.text];
}

- (IBAction)setQuantityChanged:(UISwitch *)toggleSwitch {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:toggleSwitch.on forKey:SET_QUANTITY_KEY];
	[userDefaults synchronize];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.storeIdField) {
		[self.passwordField becomeFirstResponder];
	} else if (textField == self.passwordField) {
		[self testConnectionWithStoreId:self.storeIdField.text password:self.passwordField.text];
	} else if (textField == self.nameField) {
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setValue:self.nameField.text forKey:NAME_KEY];
		[userDefaults synchronize];
		[textField resignFirstResponder];
	}
	
	return YES;
}


#pragma mark - Private methods

- (void)testConnectionWithStoreId:(NSString *)storeId password:(NSString *)password {
	if (![storeId length]) {
		[[[UIAlertView alloc] initWithTitle:@"Missing Store Id" message:@"Store Id must be entered" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
		return;
	}
	
	if (![password length]) {
		[[[UIAlertView alloc] initWithTitle:@"Missing Password" message:@"Password must be entered" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
		return;
	}
	
	[self.storeIdField resignFirstResponder];
	[self.passwordField resignFirstResponder];
	
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	hud.labelText = @"Validating";
	
	[[ProductManager sharedManager] validateCredentialsWithStoreId:storeId password:password complete:^(BOOL success){
		if (success) {
			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
			[userDefaults setValue:storeId forKey:STORE_ID_KEY];
			[userDefaults setValue:password forKey:PASSWORD_KEY];
			[userDefaults synchronize];
			hud.labelText = @"Successful";
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
				[MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
			});
		} else {
			[MBProgressHUD hideHUDForView:self.navigationController.view animated:NO];
			[[[UIAlertView alloc] initWithTitle:@"Incorrect Password" message:@"Your password is incorrect" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
		}
	}];
}

- (void)close:(UIBarButtonItem *)barButton {
	if ([self.nameField.text length]) {
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setValue:self.nameField.text forKey:NAME_KEY];
		[userDefaults synchronize];
	}	
	[self dismissModalViewControllerAnimated:YES];
}

@end
