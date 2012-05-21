//
//  ScanViewController.m
//  Stocktakr
//
//  Created by Sherman Lo on 16/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ScanViewController.h"
#import "ProductManager.h"
#import "Constants.h"


@interface ScanViewController ()

@end

@implementation ScanViewController

@synthesize barcodeField = barcodeField_;
@synthesize quantityField = quantityField_;
@synthesize descriptionLabel = descriptionLabel_;
@synthesize barcodeLabel = barcodeLabel_;
@synthesize priceLabel = priceLabel_;


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Scan Item";
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.barcodeField becomeFirstResponder];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:SET_QUANTITY_KEY]) {
		self.quantityField.userInteractionEnabled = YES;
	} else {
		self.quantityField.userInteractionEnabled = NO;
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (textField == self.quantityField) {
		NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
		NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"^[0-9]+(\\.[0-9]*)?$" options:0 error:nil];
		NSRange match = [regEx rangeOfFirstMatchInString:newString options:0 range:NSMakeRange(0, [newString length])];
		if (match.location != 0) {
			return NO;
		}
	}
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.barcodeField) {
		NSString *barcode = textField.text;
		
		NSDictionary *product = [[ProductManager sharedManager] productForBarcode:barcode];
		if (!product) {
			[[[UIAlertView alloc] initWithTitle:@"Invalid barcode" message:@"Unable to find a product matching barcode" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
		}
		
		textField.text = @"";
		
		self.descriptionLabel.text = [product valueForKey:@"description"];
		self.barcodeLabel.text = [product valueForKey:@"barcode"];
		self.priceLabel.text = [product valueForKey:@"price"];
		
		if ([[NSUserDefaults standardUserDefaults] boolForKey:SET_QUANTITY_KEY]) {
			[self.quantityField becomeFirstResponder];
		} else {
			self.quantityField.text = [[[ProductManager sharedManager] incrementQuantityForBarcode:barcode] stringValue];
		}
	} else {
		NSNumber *quantity = [NSNumber numberWithDouble:[textField.text doubleValue]];
		
		[[ProductManager sharedManager] setQuantity:quantity forBarcode:self.barcodeLabel.text];
		
		[textField resignFirstResponder];
	}
	
	return YES;
}

@end
