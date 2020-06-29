//
//  MissingValueModel.h
//  ExcelConvertString
//
//  Created by 薛伟伟 on 2020/3/15.
//  Copyright © 2020 大西瓜. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MissingValueModel : NSObject

@property (copy, nonatomic) NSString *keyString;
@property (copy, nonatomic) NSString *valueString;
@property (copy, nonatomic) NSString *translateString;
@property (assign, nonatomic) NSRange range;
@property (assign, nonatomic) NSUInteger insertLocation;

@end

NS_ASSUME_NONNULL_END
