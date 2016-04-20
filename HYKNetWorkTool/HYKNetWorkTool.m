//
//  HYKNetWorkTool.m
//  
//
//  Created by 侯玉昆 on 16/2/17.
//  Copyright © 2016年 侯玉昆. All rights reserved.
//

#import "HYKNetWorkTool.h"
#import "HYKModalViewController.h"

#define BOUNDARY @"boundary"
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height


@interface HYKNetWorkTool ()

{
    

}

@end


@implementation HYKNetWorkTool

/**************************************************************
 *  多文件上传
 **************************************************************/
- (void)POSTFileWithUlrString:(NSString *)urlString fileKey:(NSString *)fileKey fileDict:(NSDictionary *)fileDic paramaters:(NSDictionary *)paramaters success:(successBlock)success fause:(fauseBlock)fause{
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.HTTPMethod = @"POST";
    
    request.HTTPBody = [self getHttpBodyWithFileKey:fileKey fileDic:fileDic paramaters:paramaters];
    
    NSString *type  =[NSString stringWithFormat:@"multipart/form-data; boundary=%@",BOUNDARY];
                      
     [request setValue:type forHTTPHeaderField:@"Content-Type"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data && !error) {
            
            id responseObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            
            if (responseObj) {
                responseObj = data;
            }
            
            if (success) {
                success(responseObj,response);
            }
        }else {
        
            if (fause) {
                fause(error);
            }
        }
    }] resume ];
}
/**
 *  请求多文件上传和多参数
 *  @param filekey    服务器接受文件的参数key
 *  @param fileDic    上传服务器的文件的名称key和路径value
 *  @param paramaters 上传服务器的参数集合
 */
- (NSData *)getHttpBodyWithFileKey:(NSString *)filekey fileDic:(NSDictionary *)fileDic paramaters:(NSDictionary *)paramaters
{
    NSMutableData *data = [NSMutableData data];
    
    //!遍历字典
    
    [fileDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        NSString *fileName = key;
        
        NSString *filePath = obj;
        
        NSMutableString *headerStrM = [NSMutableString stringWithFormat:@"\r\n--%@\r\n",BOUNDARY];
        
        [headerStrM appendFormat:@"Content-Disposition: form-data; name=%@; filename=%@\r\n",filekey,fileName];
        
        [headerStrM appendFormat:@"Content-Type: application/octet-stream\r\n\r\n"];
        
        [data appendData:[headerStrM dataUsingEncoding:NSUTF8StringEncoding]];
        
        // 2. 文件内容
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        
        [data appendData:fileData];
        
    }];
    
    [paramaters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        // 服务器接收文本参数的 key 值
        NSString *paramaterKey = key;
        // 文本内容
        NSString *paramaterValue = obj;
        
        // 拼接普通文本参数请求体格式
        // 普通文本参数的上边界
        NSMutableString *headerS = [NSMutableString stringWithFormat:@"\r\n--%@\r\n",BOUNDARY];
        
        [headerS appendFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n",paramaterKey];
        
        [data appendData:[headerS dataUsingEncoding:NSUTF8StringEncoding]];
        
        // 普通文本参数
        [data appendData:[paramaterValue dataUsingEncoding:NSUTF8StringEncoding]];
        
    }];
    
    NSMutableString *footStr = [NSMutableString stringWithFormat:@"\r\n--%@--",BOUNDARY];
    
    [data appendData:[footStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    return data;
}

/**************************************************************
 *  单个文件POST上传
 **************************************************************/
- (void)POSTFileWithUlrString:(NSString *)urlString fileKey:(NSString *)fileKey filePath:(NSString *)filePath fileName:(NSString *)fileName success:(successBlock)success fause:(fauseBlock)fause{

    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.HTTPMethod = @"POST";
    
    // 告诉服务器,本次网络请求有文件上传信息.
    NSString *type = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",BOUNDARY];
    
    [request setValue:type forHTTPHeaderField:@"Content-Type"];

    
    request.HTTPBody = [self getHttpBodyWithFileKey: fileKey filePath:filePath fileName:fileName] ;
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data && !error) {
            
            id responseObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            
            if (!responseObj) { //如果不能解析JSON 数据,
                
                responseObj = data;
            }
            
            // 执行回调.
            if (success) {
                success(responseObj ,response);
            }
        }else //失败:
        {
            // 执行回调.
            if (fause) {
                fause(error);
            }
        }
        
    }] resume];
}

/**
 *  获得单文件上传请求体格式的方法.
 *
 *  @param filekey  服务器接收文件参数的 key 值
 *  @param filePath 上传文件内容(文件路径)
 *  @param fileName 上传文件在服务器中保存的名称(可选)
 */
- (NSData *)getHttpBodyWithFileKey:(NSString *)filekey filePath:(NSString *)filePath fileName:(NSString *)fileName {
    //! 请求体数据
    NSMutableData *data = [NSMutableData data];
    //! 同步获得本地数据信息
    NSURLResponse *response = [self getFileResponseWithFilepath:filePath];
    //! 如果用户没有指定文件名称
    if (!fileName) {
        fileName = response.suggestedFilename;
    }
    //! 文件的上边界
    NSMutableString *headerStrM = [NSMutableString stringWithFormat:@"\r\n--%@\r\n",BOUNDARY];
    
    [headerStrM appendFormat:@"Content-Disposition: form-data; name=%@; filename=%@\r\n",filekey,fileName ];
    
    [headerStrM appendFormat:@"Content-Type: %@\r\n\r\n",response.MIMEType];
    
    [data appendData:[headerStrM dataUsingEncoding:NSUTF8StringEncoding]];
    //! 文件内容
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    
    [data appendData:fileData];
    //! 文件下边界
    NSMutableString *footStr = [NSMutableString stringWithFormat:@"\r\n--%@--",BOUNDARY];
    
    [data appendData:[footStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    return data;
    
    
}
/**************************************************************
 *  当获得用户的一个本地上传路径时,有的用户一般不会给文件命名,说一上传到服务器的文件为空,所以需要人工的给本第文件解析,解析就要用url,需要给本地路径转换为url加上file://然后在本地不需要上传服务器,类似于在本地的虚拟服务器,解析出文件名称类型等信息后返回,这样就可以获取文件信息上传而不用用户进行复杂操作,但由于信息包含在response中(nsurlsecction在子线程)他处于子线程,不能保证在主线程之前调用完毕,而文件信息需要在上传之前确定,所以需要,用nsurlcollection解决回到主线程
 **************************************************************/
- (NSURLResponse *)getFileResponseWithFilepath:(NSString *)filePath{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",filePath]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLResponse *response = nil;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    
    return response;
    
}

/**************************************************************
 *  封装GET和POST请求
 **************************************************************/
- (void)postRequest:(NSString *)urlStr KeyAndValue:(NSDictionary *)dict success:(successBlock)success fause:(fauseBlock)fause{
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.HTTPMethod = @"POST";
    
    NSString *body;
    
    for (NSString *key in dict) {
        body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",key,[dict objectForKeyedSubscript:key]] ];
    }
    
    [body substringFromIndex:body.length - 1];
    
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data && !error) {
            
            id responseObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            
            if (!responseObj) { //如果不能解析JSON 数据,
                
                responseObj = data;
            }
            
            // 执行回调.
            if (success) {
                success(responseObj ,response);
            }
            
            
        }else //失败:
        {
            // 执行回调.
            if (fause) {
                fause(error);
            }
        }
        
    }] resume];
    
}


- (void)getRequest:(NSString *)urlStr KeyAndValue:(NSDictionary *)dict success:(successBlock)success fause:(fauseBlock)fause{
    
    urlStr = [urlStr stringByAppendingString:@"?"];
    
    for (NSString *key in dict) {
        
        urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",key,[dict objectForKey:key]]];
    }
    
    [urlStr substringFromIndex:urlStr.length - 1];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data && !error) {
            
            id responseObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            
            if (!responseObj) { //如果不能解析JSON 数据,
                
                responseObj = data;
            }
            
            // 执行回调.
            if (success) {
                success(responseObj ,response);
            }
            
            
        }else //失败:
        {
            // 执行回调.
            if (fause) {
                fause(error);
            }
        }

        
    }] resume] ;
}
/**************************************************************
 *  测试服务器返回值的方法
 **************************************************************/
- (void)loadWebServerDataWithUrlStr:(NSString *)urlStr success:(successBlock)success fause:(fauseBlock)fause{

//! 百分号转义
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
//! 创建请求延时15秒
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];

//! 发送网络请求
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // data :服务器返回的数据.
        // response :服务器的响应头.
        // error :连接错误
        // 网络请求完成之后执行当前block中的内容;
        // 提供一个时机:(网络请求完成!)
        
        // 成功:
        if (data && !error) {
            
            id responseObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            
            if (!responseObj) { //如果不能解析JSON 数据,
                
                responseObj = data;
            }
            
            // 执行回调.
            if (success) {
                success(responseObj ,response);
            }
            
            
        }else //失败:
        {
            // 执行回调.
            if (fause) {
                fause(error);
            }
        }
        
    }] resume];

}

/**
 *  单例对象
 *
 *  @return _instance
 */
+ (instancetype)sharedNetWork {

    static id _instrance;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _instrance = [[self alloc]init];
    });

    return _instrance;
}

//! 加载一个网页
- (void)loadWebPageWithUrlStr:(NSString *)urlStr addView:(UIView *)view{
    
    
    
    
    UIWebView *web = [[UIWebView alloc]initWithFrame:CGRectMake(0, 40, WIDTH, HEIGHT)];
    
    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    
    [view addSubview: web];
    
}

//! model一个网页
- (void)modelWebWithUrlStr:(NSString *)urlStr currentController:(id)controller{
    
    HYKModalViewController *vc = [HYKModalViewController controllerWithUrlStr:urlStr];
    
    [controller presentViewController:vc animated:YES completion:nil];
    
}

//! 屏幕截图
- (void)screenShot:(CALayer *)layer{

    // 1.开启图片的图形上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(100, 100), NO, 0.0);
    
    // 2.获取当前的图形上下文
    CGContextRef ref = UIGraphicsGetCurrentContext();
    
    // 3.把layer的内容渲染上去
    [layer renderInContext:ref];
    
    // 4.从图形上下文中获取图片
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    // 5.关闭图形上下文
    UIGraphicsEndImageContext();
    
    // 6.保存
    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
    
}



@end
