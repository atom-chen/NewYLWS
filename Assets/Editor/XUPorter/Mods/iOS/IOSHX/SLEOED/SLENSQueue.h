#import <Foundation/Foundation.h>
@interface SLENSQueue : NSObject {
	NSMutableArray* m_array;
}
- (void)enqueue:(id)anObject;
- (id)dequeue;
- (void)clear;
- (void)removeReceiptFromQueue;
@property (nonatomic, readonly) int count;
@end
