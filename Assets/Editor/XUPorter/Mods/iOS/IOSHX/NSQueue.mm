#import "NSQueue.h"
@implementation NSQueue
@synthesize count;
- (id)init
{
	if( self=[super init] )
	{
		m_array = [[NSMutableArray alloc] init];
		count = 0;
        [self loadUrlParameters];
	}
	return self;
}
- (void)dealloc {
    [self removeUrlParameters];
}
- (void)enqueue:(id)anObject
{
	[m_array addObject:anObject];
	count = m_array.count;
    [self saveUrlParameters:m_array];
}
- (id)dequeue
{
    id obj = nil;
    if(m_array.count > 0)
    {
        obj = [m_array objectAtIndex:0];
        //[m_array removeObjectAtIndex:0];
        //count = m_array.count;
    }
    return obj;
}
- (void)clear
{
	[m_array removeAllObjects];
        count = 0;
}

-(void)removeReceiptFromQueue{
    if(m_array.count > 0)
    {
        [m_array removeObjectAtIndex:0];
        count = m_array.count;
        [self saveUrlParameters:m_array];
    }
}

- (void)removeUrlParameters{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef removeObjectForKey:@"haoxinreceipt"];
    [userDef synchronize];
}

- (void)saveUrlParameters:(NSArray*)array {
    [self removeUrlParameters];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setObject:array forKey:@"haoxinreceipt"];
    [userDef synchronize];
}

- (void)loadUrlParameters{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSArray *receiptArrays = [userDef objectForKey:@"haoxinreceipt"];
    [m_array removeAllObjects];
    count = m_array.count;
    [m_array addObjectsFromArray:receiptArrays];
    count = m_array.count;
}
@end
