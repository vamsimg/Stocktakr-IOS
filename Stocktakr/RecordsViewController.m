//
//  RecordsViewController.m
//  Stocktakr
//
//  Created by Sherman Lo on 16/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecordsViewController.h"
#import "QuantityViewController.h"
#import "ProductManager.h"
#import "RecordCell.h"


@interface RecordsViewController ()

@property (nonatomic, strong) NSArray *records;

@end

@implementation RecordsViewController

@synthesize records = records_;


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Records";
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.records = [[ProductManager sharedManager] records];
	[self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.records count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    RecordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		cell = [[RecordCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}
	
	NSDictionary *record = [self.records objectAtIndex:indexPath.row];
	
	cell.textLabel.text = [record objectForKey:@"description"];
	cell.detailTextLabel.text = [record objectForKey:@"barcode"];
	
	cell.quantityLabel.text = [[record valueForKey:@"quantity"] stringValue];
	[cell.quantityLabel sizeToFit];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		ProductManager *productManager = [ProductManager sharedManager];
		NSDictionary *record = [self.records objectAtIndex:indexPath.row];
		
		[productManager deleteRecordForProduct:[record valueForKey:@"code"]];
		self.records = [productManager records];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *product = [self.records objectAtIndex:indexPath.row];
	
	QuantityViewController *viewController = [[QuantityViewController alloc] initWithNibName:nil bundle:nil];
	viewController.product = product;
	viewController.initialQuantity = [product valueForKey:@"quantity"];
	[self.navigationController pushViewController:viewController animated:YES];
}

@end
