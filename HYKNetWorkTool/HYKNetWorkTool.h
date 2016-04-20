//
//  HYKNetWorkTool.h
//  
//
//  Created by 侯玉昆 on 16/2/17.
//  Copyright © 2016年 侯玉昆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import  <UIKit/UIKit.h>



/**************************************************************
 * 定义block类型
 如果服务器返回的是JSON数据,那么直接传递给外界解析之后的 OC 数据. 帮用户自动解析JSON数据.
 如果是其他数据类型,直接将二进制数据返回给用户.

 **************************************************************/
//! 成功回调
typedef void (^successBlock)(id obj,NSURLResponse *reponse);
//! 回调失败
typedef void (^fauseBlock)(NSError *error);

@interface HYKNetWorkTool : NSObject

/**
 *  单文件上传的方法
 
 *  @param urlString 网络接口
 *  @param fileKey   服务器接收文件参数的 key 值
 *  @param filePath  上传文件的路径
 *  @param fileName  上传文件在服务器中保存的名称(可选)
 *  @param success   成功回调
 *  @param fause     失败回调
 */
- (void)POSTFileWithUlrString:(NSString *)urlString fileKey:(NSString *)fileKey filePath:(NSString *)filePath fileName:(NSString *)fileName success:(successBlock)success fause:(fauseBlock)fause;
/**
 *  多文件上传方法
 *
 *  @param urlString     网络接口
 *  @param fileKey       服务器接收文件参数的 key 值
 *  @param fileDic       上传文件的名称key和路径value
 *  @param paramaters    上传文件附带的参数集合
 *  @param success       成功回调
 *  @param sharedNetWork 失败回调
 */
- (void)POSTFileWithUlrString:(NSString *)urlString fileKey:(NSString *)fileKey fileDict:(NSDictionary *)fileDic paramaters:(NSDictionary *)paramaters success:(successBlock)success fause:(fauseBlock)fause;

//! 获取本地文件头信息
- (NSURLResponse *)getFileResponseWithFilepath:(NSString *)filePath;

//! post请求
- (void)postRequest:(NSString *)urlStr KeyAndValue:(NSDictionary *)dict success:(successBlock)success fause:(fauseBlock)fause;

//! get请求
- (void)getRequest:(NSString *)urlStr KeyAndValue:(NSDictionary *)dict success:(successBlock)success fause:(fauseBlock)fause;

//! 单例
+ (instancetype)sharedNetWork;

//! 测试服务器返回数据
- (void)loadWebServerDataWithUrlStr:(NSString *)urlStr success:(successBlock)success fause:(fauseBlock)fause;

//! 加载一个网页
- (void)loadWebPageWithUrlStr:(NSString *)urlStr addView:(UIView *)view;

//! modal一个网页
- (void)modelWebWithUrlStr:(NSString *)urlStr currentController:(id)controller;

//! 屏幕截图
- (void)screenShot:(CALayer *)layer;

@end
