//
//  FileReader.h
//  OptumLabsMacOSMFA
//
//  Created by garbutante on 3/3/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileReader : NSObject {
    NSString * filePath;
        
    NSFileHandle * fileHandle;
    unsigned long long currentOffset;
    unsigned long long totalFileLength;
        
    NSString * lineDelimiter;
    NSUInteger chunkSize;
}
@property (nonatomic, copy) NSString * lineDelimiter;
@property (nonatomic) NSUInteger chunkSize;

- (id) initWithFilePath:(NSString *)aPath;

- (NSString *) readLine;
- (NSString *) readTrimmedLine;

#if NS_BLOCKS_AVAILABLE
- (void) enumerateLinesUsingBlock:(void(^)(NSString*, BOOL *))block;
#endif


@end

NS_ASSUME_NONNULL_END
