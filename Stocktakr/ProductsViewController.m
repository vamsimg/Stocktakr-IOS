//
//  RecordsViewController.m
//  Stocktakr
//
//  Created by Sherman Lo on 16/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProductsViewController.h"
#import "QuantityViewController.h"
#import "RecordCell.h"
#import	"ProductDataSource.h"


@interface ProductsViewController ()

@property (nonatomic, strong) NSArray *records;

@end

@implementation ProductsViewController

@synthesize dataSource = _dataSource;
@synthesize records = records_;


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Records";
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.records = [self.dataSource records];
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
		NSDictionary *record = [self.records objectAtIndex:indexPath.row];
		
		[self.dataSource deleteForProduct:[record valueForKey:@"code"]];
		self.records = [self.dataSource records];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *product = [self.records objectAtIndex:indexPath.row];
	
	QuantityViewController *viewController = [[QuantityViewController alloc] initWithNibName:nil bundle:nil];
	viewController.product = product;
	viewController.initialQuantity = [product valueForKey:@"quantity"];
	viewController.dataSource = self.dataSource;
	[self.navigationController pushViewController:viewController animated:YES];
}

@end
