//
//  LEFileManager.m
//  LE
//
//  Created by 刘云鹏 on 15/10/14.
//  Copyright © 2015年 刘云鹏. All rights reserved.
//

#import "LEFileManager.h"

@implementation LEFileManager

#pragma mark - 通用操作
+ (BOOL) createFileAtPath : (NSString *) rootPath data : (NSData *) data {
    if ( [LEFileManager deleteFileAtPath:rootPath] ) {
        if ( ![[NSFileManager defaultManager] createFileAtPath:rootPath contents:data attributes:nil] ) {
            DPrintf("\nLEFileManager : Create File Error Path = %s\n", rootPath.UTF8String);
            return NO;
        }
    }
    return YES;;
}

+ (BOOL) deleteFileAtPath : (NSString *) rootPath {
    if ( [LEFileManager isFileExistsAtPath:rootPath] ) {
        NSError * error = nil;
        if ( ![[NSFileManager defaultManager] removeItemAtPath:rootPath error:&error] ) {
            DPrintf("\nLEFileManager : Remove File Error : %s Path = %s\n", error.localizedDescription.UTF8String, rootPath.UTF8String);
            return NO;
        }
    }
    return YES;
}

+ (BOOL) isFileExistsAtPath : (NSString *) rootPath {
    return [[NSFileManager defaultManager] fileExistsAtPath:rootPath];
}

+ (BOOL) isDirectoryExistsAtPath : (NSString *) rootPath {
    BOOL isDirectory = NO;
    if ( [[NSFileManager defaultManager] fileExistsAtPath:rootPath isDirectory:&isDirectory] ) {
        return isDirectory;
    }
    return NO;
}

+ (BOOL) createFileAtDirectoryPath : (NSString *) rootDirectoryPath fileName : (NSString *) fileName {
    if ( rootDirectoryPath && rootDirectoryPath.length > 0 ) {
        NSError * error = nil;
        if ( ![LEFileManager isDirectoryExistsAtPath:rootDirectoryPath] ) {
            if ( ![[NSFileManager defaultManager] createDirectoryAtPath:rootDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error] ) {
                DPrintf("\n LEFileManager : createDirectory Error : %s path = %s \n",error.localizedDescription.UTF8String, rootDirectoryPath.UTF8String);
                return NO;
            }
        }
        if ( fileName && fileName.length > 0 ) {
            rootDirectoryPath = [rootDirectoryPath stringByAppendingPathComponent:fileName];
            if ( [LEFileManager deleteFileAtPath:rootDirectoryPath] && ![[NSFileManager defaultManager] createDirectoryAtPath:rootDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error] ) {
                DPrintf("\n LEFileManager : createFile Error : %s path = %s \n",error.localizedDescription.UTF8String, rootDirectoryPath.UTF8String);
                return NO;
            }
        }
    }
    return YES;
}

/**
 *  文件大小｜单位M
 */
+ (double) sizeAtPath : (NSString *) floderOrFilePath {
    if ( [LEFileManager isDirectoryExistsAtPath:floderOrFilePath] ) {
        NSEnumerator *childFilesEnumerator = [[[NSFileManager defaultManager] subpathsAtPath:floderOrFilePath] objectEnumerator];
        NSString * fileName;
        long long floderSize = 0;
        while ( (fileName = [childFilesEnumerator nextObject]) != nil ) {
            NSString* fileAbsolutePath = [floderOrFilePath stringByAppendingPathComponent:fileName];
            floderSize += [self fileSizeAtPath:fileAbsolutePath];
        }
        return (double)floderSize / 1024.0f / 1024.0f;
    }
    return [self fileSizeAtPath:floderOrFilePath];
}

+ (long long) fileSizeAtPath : (NSString *) filePath {
    if ( [[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
        return [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

#pragma mark - Documents
+ (BOOL) createFileInDocumentsWithFileName : (NSString *) fileName data : (NSData *) data {
    NSString * path = [[LEFileManager documentsPath] stringByAppendingPathComponent:fileName];
    if ( [LEFileManager deleteFileAtPath:path] ) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
        return YES;
    }
    return NO;
}

+ (NSString *) createFileInDocumentsWithFileName : (NSString *) fileName {
    NSString * path = [[LEFileManager documentsPath] stringByAppendingPathComponent:fileName];
    if ( [LEFileManager deleteFileAtPath:path] && [LEFileManager createFileAtPath:path data:nil] ) {
        return path;
    }
    return nil;
}

+ (NSString *) filePathInDocumentsWithFileName : (NSString *) fileName {
    return [[LEFileManager documentsPath] stringByAppendingPathComponent:fileName];
}

+ (BOOL) isFileExistsInDocuments : (NSString *) fileRootName {
    NSString * filePath = [[LEFileManager documentsPath] stringByAppendingPathComponent:fileRootName];
    return [LEFileManager isFileExistsAtPath:filePath];
}

+ (BOOL) deleteFileInDocumentsWithFileName : (NSString *) fileName {
    NSString * filePath = [[LEFileManager documentsPath] stringByAppendingPathComponent:fileName];
    return [LEFileManager deleteFileAtPath:filePath];
}

+ (NSString *) documentsPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}

#pragma mark - Caches
+ (BOOL) createFileInCachesWithFileName : (NSString *) fileName data : (NSData *) data {
    NSString * path = [[LEFileManager cachesPath] stringByAppendingPathComponent:fileName];
    if ( [LEFileManager deleteFileAtPath:path] ) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
        return YES;
    }
    return NO;
}

+ (NSString *) createFileInCachesWithFileName : (NSString *) fileName {
    NSString * path = [[LEFileManager cachesPath] stringByAppendingPathComponent:fileName];
    if ( [LEFileManager deleteFileAtPath:path] && [LEFileManager createFileAtPath:path data:nil] ) {
        return path;
    }
    return nil;
}

+ (NSString *) filePathInCachesWithFileName : (NSString *) fileName {
    return [[LEFileManager cachesPath] stringByAppendingPathComponent:fileName];
}

+ (BOOL) isFileExistsInCaches : (NSString *) fileRootName {
    NSString * filePath = [[LEFileManager cachesPath] stringByAppendingPathComponent:fileRootName];
    return [LEFileManager isFileExistsAtPath:filePath];
}

+ (BOOL) deleteFileInCachesWithFileName : (NSString *) fileRootName {
    NSString * filePath = [[LEFileManager cachesPath] stringByAppendingPathComponent:fileRootName];
    return [LEFileManager deleteFileAtPath:filePath];
}

+ (NSString *) cachesPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
}

#pragma mark - Tmp
+ (NSString *) tmpPath {
    return NSTemporaryDirectory();
}

+ (BOOL) createFileInTmpWithFileName : (NSString *) fileName data : (NSData *) data {
    NSString * path = [[LEFileManager tmpPath] stringByAppendingPathComponent:fileName];
    if ( [LEFileManager deleteFileAtPath:path] ) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
        return YES;
    }
    return NO;
}

+ (NSString *) createFileInTmpWithFileName : (NSString *) fileName {
    NSString * path = [[LEFileManager tmpPath] stringByAppendingPathComponent:fileName];
    if ( [LEFileManager deleteFileAtPath:path] && [LEFileManager createFileAtPath:path data:nil] ) {
        return path;
    }
    return nil;
}

+ (NSString *) filePathInTmpWithFileName : (NSString *) fileName {
    return [[LEFileManager tmpPath] stringByAppendingPathComponent:fileName];
}

+ (BOOL) isFileExistsInTmp : (NSString *) fileRootName {
    NSString * filePath = [[LEFileManager tmpPath] stringByAppendingPathComponent:fileRootName];
    return [LEFileManager isFileExistsAtPath:filePath];
}

+ (BOOL) deleteFileInTmpWithFileName : (NSString *) fileRootName {
    NSString * filePath = [[LEFileManager tmpPath] stringByAppendingPathComponent:fileRootName];
    return [LEFileManager deleteFileAtPath:filePath];
}

@end
