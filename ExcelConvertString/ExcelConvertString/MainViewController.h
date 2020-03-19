//
//  MainViewController.h
//  ExcelConvertString
//
//  Created by admin on 2018/11/14.
//  Copyright © 2018 大西瓜. All rights reserved.
//
/*
 **操作步骤**
 **先全选excel表，搜索\n，将所有换行去掉或替换成$$$$$（最后根据需求去掉还是变成\n）**
 1.(必须)粘贴Excel的key列(推荐用英文作为key) -> getNormalKey
 2.(必须)粘贴Excel的value列 -> GetValue
 3.拖入.strings或粘贴路径 -> getStringsKey
 4.根据需求选择convert和repetition
 使用说明：
 1.获取normalKey最多为2列，一列注释，一列key
 2.getKey时设置起始行(默认为1)，从0开始
 3.注释列每行至少一个中文，没有自行添加
 4.key区分大小写
 5.getConvertKey默认都转换成%@,用#隔开，每次获取都会重置(例如：产品名#链接#www.xxx.com#Open)
 .xml解析说明:
 1.拖入xml路径->getXmlKey\n
 2.拖入key=xml.key的strings文件路径->getStringsKey\n
 3.XmlConvert
 */
#import <Cocoa/Cocoa.h>

@interface MainViewController : NSViewController

@end
