//
//  SoftwareListVC.m
//  iosapp
//
//  Created by ChanAetern on 12/9/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "SoftwareListVC.h"
#import "OSCSoftware.h"
#import "SoftwareCell.h"
#import "DetailsViewController.h"

static NSString * const kSoftwareCellID = @"SoftwareCell";

@implementation SoftwareListVC

- (instancetype)initWithSoftwaresType:(SoftwaresType)softwareType
{
    self = [super init];
    if (!self) {return nil;}
    
    NSString *searchTag;
    switch (softwareType) {
        case SoftwaresTypeRecommended:
            searchTag = @"recommend"; break;
        case SoftwaresTypeNewest:
            searchTag = @"time"; break;
        case SoftwaresTypeHottest:
            searchTag = @"view"; break;
        case SoftwaresTypeCN:
            searchTag = @"list_cn"; break;
    }
    
    self.generateURL = ^NSString * (NSUInteger page) {
        return [NSString stringWithFormat:@"%@%@?searchTag=%@&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_SOFTWARE_LIST, searchTag, (unsigned long)page, OSCAPI_SUFFIX];
    };
    
    [self setBlockAndClass];
    
    return self;
}

- (instancetype)initWIthSearchTag:(int)searchTag
{
    if (self = [super init]) {
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?searchTag=%d&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_SOFTWARETAG_LIST, searchTag, (unsigned long)page, OSCAPI_SUFFIX];
        };
        
        [self setBlockAndClass];
    }
    
    return self;
}

- (void)setBlockAndClass
{
    self.parseXML = ^NSArray * (ONOXMLDocument *xml) {
        return [[xml.rootElement firstChildWithTag:@"softwares"] childrenWithTag:@"software"];
    };
    
    self.objClass = [OSCSoftware class];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[SoftwareCell class] forCellReuseIdentifier:kSoftwareCellID];
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        SoftwareCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kSoftwareCellID forIndexPath:indexPath];
        OSCSoftware *software = self.objects[indexPath.row];
        
        cell.backgroundColor = [UIColor themeColor];
        cell.nameLabel.text = software.name;
        cell.descriptionLabel.text = software.softwareDescription;
        
        return cell;
    } else {
        return self.lastCell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        OSCSoftware *software = self.objects[indexPath.row];
        
        self.label.font = [UIFont systemFontOfSize:20];
        self.label.text = software.name;
        CGSize size = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 16, MAXFLOAT)];
        CGFloat height = size.height;
        
        self.label.font = [UIFont systemFontOfSize:13];
        self.label.text = software.softwareDescription;
        size = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 16, MAXFLOAT)];
        
        return height + size.height + 21;
    } else {
        return 60;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    
    if (row < self.objects.count) {
        OSCSoftware *software = self.objects[row];
        DetailsViewController *detailsViewController = [[DetailsViewController alloc] initWithSoftware:software];
        [self.navigationController pushViewController:detailsViewController animated:YES];
    } else {
        [self fetchMore];
    }
}


@end
