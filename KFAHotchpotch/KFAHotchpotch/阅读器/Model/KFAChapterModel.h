//
//  KFAChapterModel.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KFAImageData : NSObject

@property (nonatomic,copy) NSString *url; //图片链接
@property (nonatomic,assign) CGRect imageRect;  //图片位置
@property (nonatomic,assign) NSInteger position;

@end

@interface KFAChapterModel : NSObject<NSCoding, NSCopying>

@property (nonatomic,copy) NSString *content;
@property (nonatomic,copy) NSString *title;
@property (nonatomic) NSUInteger pageCount;

@property (nonatomic,copy) NSString *chapterpath;
@property (nonatomic,copy) NSString *html;

@property (nonatomic,copy) NSArray *epubContent;
@property (nonatomic,copy) NSArray *epubString;
@property (nonatomic,copy) NSArray *epubframeRef;
@property (nonatomic,copy) NSString *epubImagePath;
@property (nonatomic,copy) NSArray <KFAImageData *> *imageArray;
@property (nonatomic,assign) KFAReaderType type;

+ (KFAChapterModel *)chapterWithEpub:(NSString *)chapterpath title:(NSString *)title imagePath:(NSString *)path;

- (NSString *)stringOfPage:(NSUInteger)index;
- (void)updateFont;

@end

@interface KFAChapterModel (KFAParseData)

- (void)parserEpubToDictionary;
- (void)paginateEpubWithBounds:(CGRect)bounds;
- (void)paginateWithBounds:(CGRect)bounds;

@end

NS_ASSUME_NONNULL_END
