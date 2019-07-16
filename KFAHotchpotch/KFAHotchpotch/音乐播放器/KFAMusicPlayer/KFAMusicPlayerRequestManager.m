//
//  KFAMusicPlayerRequestManager.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/16.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFAMusicPlayerRequestManager.h"
#import "KFAMusicPlayerTool.h"
#import "KFAMusicCacheManager.h"

NSString * const KFANetworkStatusKey    = @"networkStatus";

@interface KFAPlayerRequestModel : NSObject<NSCoding>
@property (nonatomic, copy) NSString *last_modified;
@property (nonatomic, copy) NSString *ETag;
@end
@implementation KFAPlayerRequestModel
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.last_modified forKey:@"last_modified"];
    [aCoder encodeObject:self.ETag forKey:@"ETag"];
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.last_modified  = [aDecoder decodeObjectForKey:@"last_modified"];
        self.ETag = [aDecoder decodeObjectForKey:@"ETag"];
    }
    return self;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
}
@end

@interface KFAMusicPlayerRequestManager ()<NSURLSessionDataDelegate>

@property (nonatomic, strong) NSMutableURLRequest   *request;
@property (nonatomic, strong) NSURLSession          *session;
@property (nonatomic, strong) NSURLSessionDataTask  *dataTask;
@property (nonatomic, strong) NSURL                 *requestUrl;
@property (nonatomic, strong) NSMutableArray        *archiverArray;
@property (nonatomic, assign) BOOL  isNewAudio;

@end

@implementation KFAMusicPlayerRequestManager

- (void)dealloc{
    [[KFAMusicPlayerTool shareInstance] removeObserver:self forKeyPath:KFANetworkStatusKey];
}
+ (instancetype)requestWithUrl:(NSURL *)url{
    return [[self alloc] initWithUrl:url];
}
- (instancetype)initWithUrl:(NSURL *)url{
    self = [super init];
    if (self) {
        [[KFAMusicPlayerTool shareInstance] addObserver:self forKeyPath:KFANetworkStatusKey options:NSKeyValueObservingOptionNew context:nil];
        [KFAMusicCacheManager creatTempFile];
        self.requestUrl = [KFAMusicPlayerTool originalUrlWithUrl:url];
    }
    return self;
}
- (void)requestStart{
    __block KFAPlayerRequestModel *model = [[KFAPlayerRequestModel alloc] init];
    if (self.isHaveCache) {//安全性判断。如果沙盒存在缓存文件，再去发起校验。沙盒没有，直接下载缓存
        if (self.isObserveFileModifiedTime) {
            NSMutableDictionary *dic = [KFAMusicArchiverManager hasArchivedFileDictionary];
            [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([key isEqualToString:self.requestUrl.absoluteString]) {
                    model = (KFAPlayerRequestModel *)obj;
                    *stop = YES;
                }
            }];
        }
    }
    
    self.isNewAudio = YES;
    //直接请求源端数据
    self.request = [NSMutableURLRequest requestWithURL:self.requestUrl
                                           cachePolicy:(NSURLRequestReloadIgnoringCacheData)
                                       timeoutInterval:10.0];
    if (model.ETag) {
        [self.request addValue:model.ETag forHTTPHeaderField:@"If-None-Match"];
    }
    if (model.last_modified) {
        [self.request addValue:model.last_modified forHTTPHeaderField:@"If-Modified-Since"];
    }
    [self requestDataTask];
}

- (void)resumeRequestStart{
    //直接请求源端数据
    self.request = [NSMutableURLRequest requestWithURL:self.requestUrl
                                           cachePolicy:(NSURLRequestReloadIgnoringCacheData)
                                       timeoutInterval:10.0];
    if (self.requestOffset > 0) {
        NSString *value = [NSString stringWithFormat:@"bytes=%ld-%ld", (long)self.requestOffset,(long)self.fileLength];
        [self.request addValue:value forHTTPHeaderField:@"Range"];
    }
    [self requestDataTask];
}

- (void)requestDataTask{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.dataTask = [self.session dataTaskWithRequest:self.request];
    [self.dataTask resume];
}

- (void)setCancel:(BOOL)cancel {
    _cancel = cancel;
    [self.dataTask cancel];
    [self.session invalidateAndCancel];
}

#pragma mark - NSURLSessionDataDelegate
//服务器响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    if (self.cancel) return;
    completionHandler(NSURLSessionResponseAllow);
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    self.isNewAudio = NO;
    
    NSInteger statusCode = httpResponse.statusCode;
    if (statusCode == 200) {
        NSString *contentLength = httpResponse.allHeaderFields[@"Content-Length"];
        self.fileLength = (long)[contentLength integerValue] > 0 ? (long)[contentLength integerValue] : (long)[response expectedContentLength];
        
        KFAPlayerRequestModel *model = [KFAPlayerRequestModel new];
        model.last_modified = httpResponse.allHeaderFields[@"Last-Modified"];
        model.ETag          = httpResponse.allHeaderFields[@"Etag"];
        
        [KFAMusicArchiverManager archiveValue:model forKey:self.requestUrl.absoluteString];
        
        //如果没归档成功 如果本地有缓存则还是播放网络文件
    }else if(statusCode == 206){//带有Range请求头的返回
        
    }else{
        self.cancel = YES;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestManagerDidReceiveResponseWithStatusCode:)]) {
        [self.delegate requestManagerDidReceiveResponseWithStatusCode:statusCode];
    }
    
}

//服务器返回数据 可能会调用多次
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (self.cancel) return;
    self.cacheLength += data.length;
    [KFAMusicCacheManager writeToTempFileWithData:data];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestManagerDidReceiveData)]) {
        [self.delegate requestManagerDidReceiveData];
    }
}

//请求完成会调用该方法，请求失败则error有值
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (self.cancel) {return;}//下载取消
    if (error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestManagerDidCompleteWithError:)]) {
            [self.delegate requestManagerDidCompleteWithError:error.code];
        }
    }else {
        self.isNewAudio = YES;
        //可以缓存则保存文件
        [KFAMusicCacheManager moveTempFileToCache:self.requestUrl block:^(BOOL isSuccess,NSError *error) {
            if (!isSuccess) {
                NSLog(@"-- DFPlayer： 保存失败：%@",[error localizedDescription]);
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestManagerIsCached:)]) {
                [self.delegate requestManagerIsCached:isSuccess];
            }
        }];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    KFAMusicPlayerTool *tool = [KFAMusicPlayerTool shareInstance];
    if (object == tool) {
        if ([keyPath isEqualToString:KFANetworkStatusKey]) {
            if ( !self.isNewAudio) {
                if (tool.networkStatus != KFAMusicPlayerNetWorkStatusUnknown &&
                    tool.networkStatus != KFAMusicPlayerNetWorkStatusNotReachable) {
                    self.requestOffset = self.cacheLength;
                    [self resumeRequestStart];
                }
            }
        }
    }
}

@end
