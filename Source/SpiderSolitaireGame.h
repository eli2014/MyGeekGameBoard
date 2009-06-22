

#import "Game.h"
@class Deck;


/** The classic card solitaire game Klondike.
 See: http://en.wikipedia.org/wiki/Klondike_(solitaire) */
@interface SpiderSolitaireGame : Game {
    Deck *_deck;
    Deck *_aces[4];
	
	NSMutableArray *stacks;
}

@end
