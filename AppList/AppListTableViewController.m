//
//  AppListTableViewController.m
//  AppList
//
//  Created by Emck on 1/23/19.
//  Copyright © 2019 AppTem. All rights reserved.
//

#import "AppListTableViewController.h"

@interface AppListTableViewController ()

@end

@implementation AppListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"应用列表";
    
    [self getAppList];

    // cell箭头名称
    // self.icon_arrow = @"CellArrow";

    //    //设置相关参数
    //    //cell背景颜色
    //    self.backgroundColor_Normal = [UIColor whiteColor];
    //    //cell选中背景颜色
    //    self.backgroundColor_Selected = CFCellBackgroundColor_Highlighted;
    //    //cell右边Label字体
    //    self.rightLabelFont = [UIFont systemFontOfSize:15];
    //    //cell右边Label文字颜色
    //    self.rightLabelFontColor = CFRightLabelTextColor;
}

- (void)getAppList
{
//        Class LSApplicationWorkspace_class = NSClassFromString(@"LSApplicationWorkspace");
//        NSObject* workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
//        NSLog(@"apps: %@", [workspace performSelector:@selector(installedPlugins)]);
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"

    id workspace = [NSClassFromString(@"LSApplicationWorkspace") performSelector:@selector(defaultWorkspace)];
    NSArray *plugins = [workspace performSelector:@selector(installedPlugins)];
    NSMutableSet *list = [[NSMutableSet alloc] init];
    for (id plugin in plugins) {
        id bundle = [plugin performSelector:@selector(containingBundle)];
        if (bundle) [list addObject:bundle];
    }

    NSMutableArray *Items = [[NSMutableArray alloc] init];
    NSString *Name,*Identifier;
    NSArray *Names;
    for (id plugin in list) {
        Name = [plugin performSelector:NSSelectorFromString(@"itemName")];
        if (Name == NULL) continue;
        Names = [Name componentsSeparatedByString:@"-"];
        Name = Names[0];
        Names = [Name componentsSeparatedByString:@":"];
        Name = Names[0];
        Names = [Name componentsSeparatedByString:@"·"];
        Name = Names[0];
        Identifier = [plugin performSelector:NSSelectorFromString(@"applicationIdentifier")];

        CFSettingLabelItem *item = [CFSettingLabelItem itemWithIcon:NULL title:Name];
        item.text_right = Identifier;
        [Items addObject:item];
    }
    #pragma clang diagnostic pop


    CFSettingGroup *group = [[CFSettingGroup alloc] init];
    group.items =  Items;

    UIView *view = [[UIImageView alloc]init];
    view.frame = CGRectMake(0, 0, self.view.frame.size.width, 4);
    view.backgroundColor = CFCellBackgroundColor_Highlighted;
    group.headerHeight = 4;
    group.headerView = view;

    [self.dataList addObject:group];
    
    
//    // 生成JSON文件并分享到AirDrop
//    NSString *AppList = @"{\n";
//    for (id plugin in list) {
//        NSString *name = [plugin performSelector:NSSelectorFromString(@"itemName")];
//        if (name == NULL) continue;
//
//        NSString *app = [NSString stringWithFormat:@"  \"%@\": \"%@\",\n", [plugin performSelector:NSSelectorFromString(@"applicationIdentifier")], name];
//        AppList = [AppList stringByAppendingString:app];
//    }
//    AppList = [AppList substringToIndex:AppList.length - 2];
//    AppList = [AppList stringByAppendingString:@"\n}"];
//
//    #pragma clang diagnostic pop
//
//    NSString * aa = [self createFileWithName:@"apps.json" contents:AppList];
//
//    NSURL *fileURL= [NSURL fileURLWithPath:aa];
//    NSArray *urls= @[fileURL];
//    UIActivityViewController *activituVC=[[UIActivityViewController alloc]initWithActivityItems:urls applicationActivities:nil];
//    NSArray *cludeActivitys=@[UIActivityTypeCopyToPasteboard];
//    activituVC.excludedActivityTypes=cludeActivitys;
//    [self presentViewController:activituVC animated:YES completion:nil];
//
//    // http://itunes.apple.com/lookup?bundleId=com.bundle.id
}

- (NSString *)createFileWithName:(NSString *)fileName contents:(NSString *)contents
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    if ([manager createFileAtPath:filePath contents:contents attributes:nil]) {
        //NSLog(@"Created the File Successfully.");
        return filePath;
    } else {
        //NSLog(@"Failed to Create the File");
        return NULL;
    }
    #pragma clang diagnostic pop
}


//------------------------------------------------------------------------------
// writng content to specific file name
//------------------------------------------------------------------------------
- (NSString *)writeString:(NSString *)content toFile:(NSString *)fileName
{
    // Fetch directory path of document for local application.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // the absolute path of file named fileName by joining the document path with fileName, separated by path separator.
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    // Check if the file named fileName exists.
    if ([manager fileExistsAtPath:filePath]) {
        NSError *error = nil;
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wint-conversion"
        NSString *tmp =[[NSString alloc] initWithContentsOfFile:fileName usedEncoding:NSStringEncodingConversionAllowLossy error:nil];
        #pragma clang diagnostic pop
        
        if (tmp) {
            content = [tmp stringByAppendingString:content];
        }
        // Write NSString content to the file.
        [content writeToFile:filePath atomically:YES encoding:NSStringEncodingConversionAllowLossy error:&error];
        // If error happens, log it.
        if (error) {
            NSLog(@"There is an Error: %@", error);
            return NULL;
        }
        else return filePath;
    } else {
        // If the file doesn't exists, log it.
        NSLog(@"File %@ doesn't exists", fileName);
        return NULL;
    }
}

@end
