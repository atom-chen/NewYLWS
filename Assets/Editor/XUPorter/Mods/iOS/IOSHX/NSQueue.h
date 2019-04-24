#import <Foundation/Foundation.h>
@interface NSQueue : NSObject {
	NSMutableArray* m_array;
}
- (void)enqueue:(id)anObject;
- (id)dequeue;
- (void)clear;
- (void)removeReceiptFromQueue;
@property (nonatomic, readonly) int count;
@end