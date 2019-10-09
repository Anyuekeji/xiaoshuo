//
//  LEFileManager.h
//  LE
//
//  Created by 刘云鹏 on 15/10/14.
//  Copyright © 2015年 刘云鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

/**-----------------------------------------------------------------------------
 * @name LEFileManager
 * -----------------------------------------------------------------------------
 * 文件系统管理，缓存管理
 */
@interface LEFileManager : NSObject

#pragma mark - 通用操作
/**
 *  创建文件，必须根路径，如果文件已经存在将被删除
 */
+ (BOOL) createFileAtPath : (NSString *) rootPath data : (NSData *) data;
/**
 *  删除文件，必须根路径
 */
+ (BOOL) deleteFileAtPath : (NSString *) rootPath;
/**
 *  判断文件是否存在，必须根路径
 */
+ (BOOL) isFileExistsAtPath : (NSString *) rootPath;
/**
 *  判断目录是否存在，必须根路径
 */
+ (BOOL) isDirectoryExistsAtPath : (NSString *) rootPath;
/**
 *  创建带目录和文件，如果不传入文件名则只创建目录，如果传入文件名且文件已经存在将被删除
 */
+ (BOOL) createFileAtDirectoryPath : (NSString *) rootDirectoryPath fileName : (NSString *) fileName;
/**
 *  文件大小，可以是文件夹或者文件｜单位M
 */
+ (double) sizeAtPath : (NSString *) floderOrFilePath;

#pragma mark - Documents
+ (BOOL) createFileInDocumentsWithFileName : (NSString *) fileName data : (NSData *) data;
+ (NSString *) createFileInDocumentsWithFileName : (NSString *) fileName;
+ (NSString *) filePathInDocumentsWithFileName : (NSString *) fileName;
+ (BOOL) isFileExistsInDocuments : (NSString *) fileRootName;
+ (BOOL) deleteFileInDocumentsWithFileName : (NSString *) fileName;
+ (NSString *) documentsPath;

#pragma mark - Caches
+ (BOOL) createFileInCachesWithFileName : (NSString *) fileName data : (NSData *) data;
+ (NSString *) createFileInCachesWithFileName : (NSString *) fileName;
+ (NSString *) filePathInCachesWithFileName : (NSString *) fileName;
+ (BOOL) isFileExistsInCaches : (NSString *) fileRootName;
+ (BOOL) deleteFileInCachesWithFileName : (NSString *) fileRootName;
+ (NSString *) cachesPath;

#pragma mark - Tmp
+ (BOOL) createFileInTmpWithFileName : (NSString *) fileName data : (NSData *) data;
+ (NSString *) createFileInTmpWithFileName : (NSString *) fileName;
+ (NSString *) filePathInTmpWithFileName : (NSString *) fileName;
+ (BOOL) isFileExistsInTmp : (NSString *) fileRootName;
+ (BOOL) deleteFileInTmpWithFileName : (NSString *) fileRootName;
+ (NSString *) tmpPath;

@end
