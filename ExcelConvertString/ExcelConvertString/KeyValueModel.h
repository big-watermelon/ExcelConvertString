//
//  KeyValueModel.h
//  ExcelConvertString
//
//  Created by 薛伟伟 on 2020/3/15.
//  Copyright © 2020 大西瓜. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//TODO:封装
@interface KeyValueModel : NSObject

@property (strong, nonatomic) NSMutableArray *stringsKeyArray;
@property (strong, nonatomic) NSMutableArray *stringKeyRepetitionArray;
@property (strong, nonatomic) NSMutableArray *stringValueArray;
@property (strong, nonatomic) NSMutableDictionary *stringKeyannotationDic;
@end

NS_ASSUME_NONNULL_END
