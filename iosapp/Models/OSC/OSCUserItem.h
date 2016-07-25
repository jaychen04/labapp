//
//  OSCUserItem.h
//  iosapp
//
//  Created by Holden on 16/7/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSCUserItem : NSObject
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSString *portrait;

//新接口未用到的属性，如需用更改属性名与后台返回名字相同
@property (nonatomic, assign) int followersCount;
@property (nonatomic, assign) int fansCount;
@property (nonatomic, assign) int score;
@property (nonatomic, assign) int favoriteCount;
@property (nonatomic, assign) int relationship;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *developPlatform;
@property (nonatomic, copy) NSString *expertise;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, strong) NSDate *joinTime;
@property (nonatomic, strong) NSDate *latestOnlineTime;
@property (nonatomic, readwrite, copy) NSString *pinyin; //拼音
@property (nonatomic, readwrite, copy) NSString *pinyinFirst; //拼音首字母

@end
