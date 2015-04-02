//
//  OSCBlog.m
//  iosapp
//
//  Created by chenhaoxiang on 10/30/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCBlog.h"
#import <UIKit/UIKit.h>
#import "Utils.h"

static NSString * const kID = @"id";
static NSString * const kAuthor = @"authorname";
static NSString * const kAuthorID = @"authorid";
static NSString * const kTitle = @"title";
static NSString * const kBody = @"body";
static NSString * const kCommentCount = @"commentCount";
static NSString * const kPubDate = @"pubDate";
static NSString * const kDocumentType = @"documentType";

@implementation OSCBlog

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _blogID = [[[xml firstChildWithTag:kID] numberValue] longLongValue];
        _author = [[xml firstChildWithTag:kAuthor] stringValue];
        _authorID = [[[xml firstChildWithTag:kAuthorID] numberValue] longLongValue];
        _title = [[xml firstChildWithTag:kTitle] stringValue];
        _body = [[xml firstChildWithTag:kBody] stringValue];
        _commentCount = [[[xml firstChildWithTag:kCommentCount] numberValue] intValue];
        _pubDate = [[xml firstChildWithTag:kPubDate] stringValue];
        _documentType = [[[xml firstChildWithTag:kDocumentType] numberValue] intValue];
    }
    
    return self;
}

- (NSAttributedString *)attributedTittle
{
    NSTextAttachment *textAttachment = [NSTextAttachment new];
    if (_documentType == 0) {
        textAttachment.image = [UIImage imageNamed:@"widget_repost"];
    } else {
        textAttachment.image = [UIImage imageNamed:@"widget-original"];
    }
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
    NSMutableAttributedString *attributedTittle = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
    [attributedTittle appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [attributedTittle appendAttributedString:[[NSAttributedString alloc] initWithString:_title]];
    
    return attributedTittle;
}

-(NSAttributedString *)attributedTimes
{
    NSMutableAttributedString *attributedTime;
    
    NSTextAttachment *textAttachment = [NSTextAttachment new];
    textAttachment.image = [UIImage imageNamed:@"time"];
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
    attributedTime = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
    [attributedTime appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [attributedTime appendAttributedString:[[NSAttributedString alloc] initWithString:[Utils intervalSinceNow:_pubDate]]];
    
    return attributedTime;
}

-(NSAttributedString *)attributedCommentCount
{
    NSMutableAttributedString *attributedCommentCount;
    
    NSTextAttachment *textAttachment = [NSTextAttachment new];
    textAttachment.image = [UIImage imageNamed:@"comment"];
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
    attributedCommentCount = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
    [attributedCommentCount appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [attributedCommentCount appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", _commentCount]]];
    
    return attributedCommentCount;
}

- (BOOL)isEqual:(id)object
{
    if ([self class] == [object class]) {
        return _blogID == ((OSCBlog *)object).blogID;
    }
    
    return NO;
}


@end
