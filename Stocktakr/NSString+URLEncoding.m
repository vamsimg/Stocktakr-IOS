//
//  NSString+URLEncoding.m
//  Stocktakr
//
//  Created by Sherman Lo on 18/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+URLEncoding.h"

@implementation NSString (URLEncoding)

-(NSString *)urlEncode {
	//TODO: RIGHT??
	return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
																		(__bridge CFStringRef)self,
																		NULL,
																		(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
																		kCFStringEncodingUTF8);
}

@end
