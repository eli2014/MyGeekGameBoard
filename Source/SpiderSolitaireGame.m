#import "SpiderSolitaireGame.h"
#import "Deck.h"
#import "PlayingCard.h"
#import "Stack.h"


#define kStackHeight 500


/**  WARNING: THIS CODE REQUIRES GARBAGE COLLECTION!
 **  This sample application uses Objective-C 2.0 garbage collection.
 **  Therefore, the source code in this file does NOT perform manual object memory management.
 **  If you reuse any of this code in a process that isn't garbage collected, you will need to
 **  add all necessary retain/release/autorelease calls, and implement -dealloc methods,
 **  otherwise unpleasant leakage will occur!
 **/


@implementation SpiderSolitaireGame


- (id) initWithBoard: (CALayer*)board
{
    self = [super initWithBoard: board];
    if (self != nil) {
        [self setNumberOfPlayers: 1];
        
        _deck = [[Deck alloc] initWithCardsOfClass: [PlayingCard class] numberOfDecks: 2];
		
		NSUInteger i, count = [_deck.cards count];
		for (i = 0; i < count; i++) {
			PlayingCard * obj = [_deck.cards objectAtIndex:i];
			NSLog(@"added card: %@", obj);
		}
		
		[_deck shuffle];	
        _deck.position = CGPointMake(kCardWidth/2+16,kCardHeight/2+16);
        [board addSublayer: _deck];
        
        _sink = [[Deck alloc] init];
        _sink.position = CGPointMake(3*kCardWidth/2+32,kCardHeight/2+16);
        [board addSublayer: _sink];
        
//        for( CardSuit suit=kSuitClubs; suit<=kSuitSpades; suit++ ) {
//            Deck *aces = [[Deck alloc] init];
//            aces.position = CGPointMake(kCardWidth/2+16+(kCardWidth+16)*(suit%2),
//                                        120+kCardHeight+(kCardHeight+16)*(suit/2));
//            [board addSublayer: aces];
//            _aces[suit] = aces;
//        }
        
		NSMutableArray *stacks = [[NSMutableArray alloc] init];
		
        for( int s=0; s<10; s++ ) {
            Stack *stack = [[Stack alloc] initWithStartPos: CGPointMake(kCardWidth/2,
                                                                        kStackHeight-kCardHeight/2.0)
                                                   spacing: CGSizeMake(0,-22)];
            stack.frame = CGRectMake(s*(kCardWidth+16),16, kCardWidth,kStackHeight);
            stack.backgroundColor = nil;
            stack.dragAsStacks = YES;
            [board addSublayer: stack];
            
            // According to the rules, one card should be added to each stack in turn, instead
            // of populating entire stacks one at a time. However, if one trusts the Deck's
            // -shuffle method (which uses the random() function, seeded with a high-entropy
            // cryptographically-strong value), it shouldn't make any difference :-)

			[stacks addObject:stack];
			
            //for( int c=0; c<=s; c++ )
//                [stack addBit: [_deck removeTopCard]];
//            ((Card*)stack.bits.lastObject).faceUp = YES;
        }
		for (int c=0; c<54; c++) {
			Stack *stack = [stacks objectAtIndex: c % [stacks count]];
			[stack addBit: [_deck removeTopCard]];
		}
		
		for (Stack *stack in stacks) {
			((Card*)stack.bits.lastObject).faceUp = YES;
		}
        
		
        [self nextPlayer];
    }
    return self;
}


- (BOOL) clickedBit: (Bit*)bit
{
    if( [bit isKindOfClass: [Card class]] ) {
        Card *card = (Card*)bit;
        if( card.holder == _deck ) {
            // Click on deck deals 3 cards to the sink:
            for( int i=0; i<3; i++ ) {
                Card *card = [_deck removeTopCard];
                if( card ) {
                    [_sink addCard: card];
                    card.faceUp = YES;
                }
            }
            [self endTurn];
            return YES;
        } else if( card.holder == _sink ) {
            // Clicking the sink when the deck is empty re-deals:
            if( _deck.empty ) {
                [_deck addCards: [_sink removeAllCards]];
                [_deck flip];
                [self endTurn];
                return YES;
            }
        } else {
            // Click on a card elsewhere turns it face-up:
            if( ! card.faceUp ) {
                card.faceUp = YES;
                return YES;
            }
        }
    }
    return NO;
}


- (BOOL) canBit: (Bit*)bit moveFrom: (id<BitHolder>)src
{
    if( [bit isKindOfClass: [DraggedStack class]] ) {
        Card *bottomSrc = [[(DraggedStack*)bit bits] objectAtIndex: 0];
        if( ! bottomSrc.faceUp )
            return NO;
    }
    return YES;
}


- (BOOL) canBit: (Bit*)bit moveFrom: (id<BitHolder>)src to: (id<BitHolder>)dst
{
    if( src==_deck || dst==_deck || dst==_sink )
        return NO;
    
    // Find the bottom card being moved, and the top card it's moving onto:
    PlayingCard *bottomSrc;
    if( [bit isKindOfClass: [DraggedStack class]] )
        bottomSrc = [[(DraggedStack*)bit bits] objectAtIndex: 0];
    else
        bottomSrc = (PlayingCard*)bit;
    
    PlayingCard *topDst;
    if( [dst isKindOfClass: [Deck class]] ) {
        // Dragging to an ace pile:
        if( ! [bit isKindOfClass: [Card class]] )
            return NO;
        topDst = (PlayingCard*) ((Deck*)dst).topCard;
        if( topDst == nil )
            return bottomSrc.rank == kRankAce;
        else
            return bottomSrc.suit == topDst.suit && bottomSrc.rank == topDst.rank+1;
        
    } else {
        // Dragging to a card stack:
        topDst = (PlayingCard*) ((Stack*)dst).topBit;
        if( topDst == nil )
            return bottomSrc.rank == kRankKing;
        else
            return bottomSrc.color != topDst.color && bottomSrc.rank == topDst.rank-1;
    }
}


- (Player*) checkForWinner
{
    for( CardSuit suit=kSuitClubs; suit<=kSuitSpades; suit++ )
        if( _aces[suit].cards.count < 13 )
            return nil;
    return _currentPlayer;
}



@end
