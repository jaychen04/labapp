//
//  OSCFavorites.h
//  iosapp
//
//  Created by 李萍 on 16/8/29.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, FavoritesType)
{
    FavoritesTypeAll = 0,
    FavoritesTypeSoftware = 1,
    FavoritesTypeQuestion = 2,
    FavoritesTypeBlog,
    FavoritesTypeTranslate,
    FavoritesTypeActivity,
    FavoritesTypeNews,
};

@interface OSCFavorites : NSObject

@property (nonatomic, assign) long id;
@property (nonatomic, assign) FavoritesType type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *href;

@end
