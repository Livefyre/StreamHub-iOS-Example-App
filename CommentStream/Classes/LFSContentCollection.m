//
//  LFSContentCollection.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/24/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//


#import "LFSContentCollection.h"

@implementation LFSContentCollection {
    NSMutableArray *_array;
}

- (id)init
{
	return [self initWithCapacity:0u];
}

- (id)copy
{
	return [self mutableCopy];
}

-(void)dealloc
{
    _array = nil;
}

+(instancetype)array
{
    return [[self alloc] init];
}

#pragma mark - NSMutableArray primitives

-(id)initWithCapacity:(NSUInteger)numItems
{
    self = [super init];
	if (self != nil)
	{
        _array = [[NSMutableArray alloc] initWithCapacity:numItems];
	}
	return self;
}

-(void)removeObjectAtIndex:(NSUInteger)index
{
    [_array removeObjectAtIndex:index];
}

-(void)removeLastObject
{
    [_array removeLastObject];
}

-(void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    if ([anObject isKindOfClass:[LFSContent class]]) {
        [_array insertObject:anObject atIndex:index];
    } else {
        LFSContent *content = [[LFSContent alloc] initWithObject:anObject];
        [_array insertObject:content atIndex:index];
    }
}

-(void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    if ([anObject isKindOfClass:[LFSContent class]]) {
        [_array replaceObjectAtIndex:index withObject:anObject];
    } else {
        LFSContent *content = [[LFSContent alloc] initWithObject:anObject];
        [_array replaceObjectAtIndex:index withObject:content];
    }
}

-(void)addObject:(id)anObject
{
    if ([anObject isKindOfClass:[LFSContent class]]) {
        [_array addObject:anObject];
    } else {
        LFSContent *content = [[LFSContent alloc] initWithObject:anObject];
        [_array addObject:content];
    }
}

#pragma mark - NSArray primitives

-(NSUInteger)count
{
    return [_array count];
}

-(id)objectAtIndex:(NSUInteger)index
{
    return [_array objectAtIndex:index];
}

// note: per Apple docs, NSArray does not have adesignated initializer
-(id)initWithObjects:(const id [])objects count:(NSUInteger)cnt
{
    self = [super init];
    if (self != nil) {
        // initialize stuff here
        
        // create an NSArray from a C array of object pointers
        // and a C array of key pointers
        Class classOfLFSContent = [LFSContent class];
        LFSContent *__strong *array =
        (LFSContent *__strong *)malloc(sizeof(LFSContent*) * cnt);
        for (NSUInteger i = 0; i < cnt; i++) {
            id object = objects[i];
            LFSContent *Content = ([object isKindOfClass:classOfLFSContent]
                                   ? (LFSContent*)object
                                   : [[LFSContent alloc] initWithObject:object]);
            array[i] = Content;
        }
        _array = [[NSMutableArray alloc]
                  initWithObjects:array
                  count:cnt];
        free(array);
    }
    
    return self;
}

-(NSEnumerator*)objectEnumerator {
    return [_array objectEnumerator];
}

-(NSEnumerator*)reverseObjectEnumerator {
    return [_array reverseObjectEnumerator];
}

@end
