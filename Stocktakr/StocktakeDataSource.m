//
//  StocktakeDataSource.m
//  Stocktakr
//
//  Created by Sherman Lo on 9/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StocktakeDataSource.h"
#import "ProductManager.h"
#import "Constants.h"


@implementation StocktakeDataSource

- (NSNumber *)quantityForBarcode:(NSString *)barcode {
	return [[ProductManager sharedManager] stocktakeQuantityForBarcode:barcode];
}

- (NSNumber *)incrementQuantityForBarcode:(NSString *)barcode {
	return [[ProductManager sharedManager] incrementStocktakeQuantityForBarcode:barcode];
}

- (BOOL)setQuantity:(NSNumber *)quantity forBarcode:(NSString *)barcode {
	return [[ProductManager sharedManager] setStocktakeQuantity:quantity forBarcode:barcode];
}

- (NSArray *)records {
	return [[ProductManager sharedManager] stocktakeRecords];
}

- (NSUInteger)numberOfRecords {
	return [[ProductManager sharedManager] numberOfStocktakeRecords];
}

- (void)deleteForProduct:(NSString *)productCode {
	[[ProductManager sharedManager] deleteStocktakeRecordForProduct:productCode];
}

- (void)uploadWithStoreId:(NSString *)storeId password:(NSString *)password name:(NSString *)name complete:(void (^)(BOOL success))complete {
	[[ProductManager sharedManager] uploadStocktakeRecordsWithStoreId:storeId password:password name:name complete:complete];
}

- (BOOL)shouldAutoIncrementQuantity {
	return ![[NSUserDefaults standardUserDefaults] boolForKey:SET_QUANTITY_KEY];
}

@end
