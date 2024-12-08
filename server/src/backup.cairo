use starknet::ContractAddress;
use core::array::ArrayTrait;
use core::dict::Felt252Dict;
use core::option::OptionTrait;
use core::traits::Into;

#[derive(Copy, Drop, Serde)]
enum CardColor {
    Red,
    Blue,
    Green,
    Yellow,
    Wild
}

#[derive(Copy, Drop, Serde)]
enum CardType {
    Number: u8,
    Skip,
    Reverse,
    DrawTwo,
    WildCard,
    WildDrawFour
}

#[derive(Copy, Drop, Serde)]
struct Card {
    color: CardColor,
    card_type: CardType,
    value: u8
}

#[derive(Copy, Drop, Serde)]
enum GameState {
    Waiting,
    InProgress,
    Finished
}

#[starknet::contract]
mod UnoGameContract {
        
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    use super::{ContractAddress, Card, CardColor, CardType, GameState};

    #[storage]
    struct Storage {
        // Game Management
        game_id: felt252,
        current_game_state: GameState,
        players: Map::<ContractAddress, bool>,
        player_order: Array::<ContractAddress>,
        current_player_index: u8,
        max_players: u8,

        // Deck Management
        deck: Array::<Card>,
        discard_pile: Array::<Card>,
        player_hands: Map::<(felt252, ContractAddress), Array::<Card>>,

        // Game Mechanics
        play_direction: bool, // true: clockwise, false: counter-clockwise
        current_color: CardColor,
        game_seed: felt252,

        // Score Tracking
        player_scores: Map::<ContractAddress, u256>
    }

    // Events
    #[event]
    fn GameCreated(game_id: felt252, creator: ContractAddress) {}

    #[event]
    fn PlayerJoined(game_id: felt252, player: ContractAddress) {}

    #[event]
    fn GameStarted(game_id: felt252) {}

    #[event]
    fn CardPlayed(player: ContractAddress, card: Card) {}

    #[event]
    fn GameEnded(winner: ContractAddress, score: u256) {}

    // Game Initialization
    #[external(v0)]
    fn create_game(ref self: ContractState, max_players: u8, seed: felt252) -> felt252 {
        // Validate player count
        assert(max_players >= 2 && max_players <= 4, 'Invalid player count');

        // Generate unique game ID
        let game_id = generate_game_id(seed);
        
        // Set up game parameters
        self.game_id.write(game_id);
        self.max_players.write(max_players);
        self.game_seed.write(seed);
        self.current_game_state.write(GameState::Waiting);
        self.play_direction.write(true);

        // Emit game creation event
        GameCreated(game_id, get_caller_address());
        
        game_id
    }

    // Player Join Mechanism
    #[external(v0)]
    fn join_game(ref self: ContractState, game_id: felt252) {
        // Validate game state
        assert(self.current_game_state.read() == GameState::Waiting, 'Game already started');
        assert(self.player_order.read().len() < self.max_players.read().into(), 'Game is full');

        let player = get_caller_address();
        
        // Prevent duplicate joins
        assert(!self.players.read((game_id, player)), 'Already joined');

        // Add player
        self.players.write((game_id, player), true);
        self.player_order.read().append(player);

        // Emit player join event
        PlayerJoined(game_id, player);

        // Start game if max players reached
        if self.player_order.read().len() == self.max_players.read().into() {
            start_game(game_id);
        }
    }

    // Game Start Logic
    fn start_game(self: ContractState) {
        // Generate and shuffle deck
        generate_deck();
        shuffle_deck(self.game_seed.read());

        // Distribute initial cards
        distribute_initial_cards(game_id);

        // Set initial game state
        self.current_game_state.write(GameState::InProgress);
        
        // Select first player
        self.current_player_index.write(select_first_player());

        // Emit game start event
        GameStarted(game_id);
    }

    // Card Play Mechanism
    #[external(v0)]
    fn play_card(self: ContractState, card: Card) {
        // Validate game state and turn
        validate_game_in_progress();
        validate_player_turn();
        validate_card_play(card);

        let player = get_caller_address();
        
        // Remove card from player's hand
        remove_card_from_hand(player, card);
        
        // Add card to discard pile
        self.discard_pile.read().append(card);

        // Process card effect
        process_card_effect(card);

        // Check for win condition
        check_win_condition(player);

        // Move to next player
        advance_turn();

        // Emit card play event
        CardPlayed(player, card);
    }

    // Draw Card Mechanism
    #[external(v0)]
    fn draw_card(self: @ContractState, game_id: felt252) {
        validate_game_in_progress(self);
        validate_player_turn(self);

        let player = get_caller_address();
        let drawn_card = draw_card_from_deck();
        
        // Add drawn card to player's hand
        self.player_hands.read((game_id, player)).append(drawn_card);

        // Advance turn if card cannot be played
        advance_turn();
    }

    // Win Condition Check
    fn check_win_condition(self: ContractState) {
        // Check if player has no cards left
        if self.player_hands.read((self.game_id.read(), player)).is_empty() {
            end_game(player);
        }
    }

    // Game Termination
    fn end_game(self: ContractState, winner: ContractAddress) {
        // Calculate final score
        let score = calculate_final_score();
        
        // Update game state
        self.current_game_state.write(GameState::Finished);
        
        // Record winner's score
        self.player_scores.write(winner, score);

        // Emit game end event
        GameEnded(winner, score);
    }

    // Utility Functions
    fn generate_game_id(seed: felt252) -> felt252 {
        // Generate unique game ID using seed and block info
        hash(seed ^ get_block_info().block_number)
    }

    fn generate_deck() {
        // Implement full UNO deck generation logic
        let mut deck = ArrayTrait::new();
        // Add all UNO cards with proper distribution
        self.deck.write(deck);
    }

    fn shuffle_deck(self: ContractState, seed: felt252) {
        // Implement Fisher-Yates shuffle with cryptographic seed
        let mut deck = self.deck.read();
        // Shuffling logic using seed
        self.deck.write(deck);
    }

    fn distribute_initial_cards(self: ContractState, game_id: felt252) {
        let players = self.player_order.read();
        
        // Distribute 7 cards to each player
        players.iter().for_each(|player| {
            let mut player_hand = ArrayTrait::new();
            
            // Draw 7 cards for each player
            for _ in 0..7 {
                player_hand.append(draw_card_from_deck());
            }
            
            self.player_hands.write((game_id, *player), player_hand);
        });
    }

    // Complex Validation Functions
    fn validate_card_play(self: ContractState, card: Card) -> bool {
        let top_card = self.discard_pile.read().last().unwrap();
        
        // Matching color or number or action
        card.color == top_card.color || 
        card.card_type == top_card.card_type ||
        card.color == CardColor::Wild
    }

    fn process_card_effect(card: Card) {
        match card.card_type {
            CardType::Skip => skip_next_player(),
            CardType::Reverse => change_play_direction(),
            CardType::DrawTwo => draw_two_cards(),
            CardType::WildDrawFour => draw_four_cards(),
            _ => {}
        }
    }

    // Additional Game Mechanics
    fn validate_game_in_progress(self: ContractState) {
        assert(self.current_game_state.read() == GameState::InProgress, 'Game not in progress');
    }

    fn validate_player_turn(self: ContractState) {
        let current_player = self.player_order.read()[self.current_player_index.read()];
        assert(get_caller_address() == current_player, 'Not your turn');
    }

    fn advance_turn(self: ContractState) {
        let player_count = self.player_order.read().len();
        let current_index = self.current_player_index.read();
        
        // Determine next player based on direction
        let next_index = if self.play_direction.read() {
            (current_index + 1) % player_count
        } else {
            (current_index - 1 + player_count) % player_count
        };
        
        self.current_player_index.write(next_index);
    }

    // Scoring and Endgame
    fn calculate_final_score(self: @ContractState) -> u256 {
        let players = self.player_order.read();
        let mut total_score: u256 = 0;
        
        players.iter().for_each(|player| {
            let hand = self.player_hands.read((self.game_id.read(), *player));
            
            // Calculate score based on remaining cards
            let hand_score = hand.iter().fold(0, |acc, card| {
                acc + match card.card_type {
                    CardType::Number(val) => val.into(),
                    CardType::Skip | CardType::Reverse | CardType::DrawTwo => 20,
                    CardType::WildCard | CardType::WildDrawFour => 50,
                }
            });
            
            total_score += hand_score;
        });
        
        total_score
    }

    // Deck and Card Management
    fn draw_card_from_deck(self: @ContractState) -> Card {
        // Implement safe card drawing with deck replenishment
        if self.deck.read().is_empty() {
            regenerate_deck_from_discard();
        }
        
        let card = self.deck.read().pop_front().unwrap();
        card
    }

    fn regenerate_deck_from_discard(self: ContractState) {
        // Move discard pile back to deck, keeping top card
        let top_card = self.discard_pile.read().pop_back().unwrap();
        self.deck.write(self.discard_pile.read());
        self.discard_pile.write(ArrayTrait::new());
        self.discard_pile.read().append(top_card);
        
        // Reshuffle deck
        shuffle_deck(self.game_seed.read());
    }
}