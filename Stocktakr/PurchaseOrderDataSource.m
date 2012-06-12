//
//  PurchaseOrderDataSource.m
//  Stocktakr
//
//  Created by Sherman Lo on 9/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PurchaseOrderDataSource.h"
#import "ProductManager.h"


@implementation PurchaseOrderDataSource

- (NSNumber *)quantityForBarcode:(NSString *)barcode {
	return [[ProductManager sharedManager] purchaseOrderQuantityForBarcode:barcode];
}

- (NSNumber *)incrementQuantityForBarcode:(NSString *)barcode {
	return [[ProductManager sharedManager] incrementPurchaseOrderQuantityForBarcode:barcode];
}

- (BOOL)setQuantity:(NSNumber *)quantity forBarcode:(NSString *)barcode {
	return [[ProductManager sharedManager] setPurchaseOrderQuantity:quantity forBarcode:barcode];
}

- (NSArray *)records {
	return [[ProductManager sharedManager] purchaseOrderRecords];
}

- (void)deleteForProduct:(NSString *)productCode {
	[[ProductManager sharedManager] deletePurchaseOrderRecordForProduct:productCode];
}

- (void)uploadWithStoreId:(NSString *)storeId password:(NSString *)password name:(NSString *)name complete:(void (^)(BOOL success))complete {
	[[ProductManager sharedManager] uploadPurchaseOrdersWithStoreId:storeId password:password name:name complete:complete];
}

- (BOOL)shouldAutoIncrementQuantity {
	return NO;
}

@end
