//
//  KeyValueStateModel.h
//  ExcelConvertString
//
//  Created by admin on 2019/5/29.
//  Copyright © 2019 大西瓜. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KeyValueStateModel : NSObject
@property (nonatomic, copy) NSString *repetitionString;
@property (nonatomic, assign) BOOL valueIsNull;
@property (nonatomic, assign) BOOL formatSpecifiersIsUnequal;
@end

