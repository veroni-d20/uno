use starknet::{
    get_caller_address, ContractAddress
};
use core::array::ArrayTrait;
use core::dict::Felt252Dict;
use core::option::OptionTrait;
use core::traits::Into;

#[derive(Copy, Drop, Serde, starknet::Store)]
enum GameState {
Waiting,
InProgress,
Finished
}

#[starknet::contract]
mod UnoGameContract {

    
use starknet::storage::{Map, StoragePointerReadAccess, StoragePointerWriteAccess};

use super::{ContractAddress, GameState,get_caller_address};

#[storage]
struct Storage {
    // Game Management
    game_id_counter: felt252,
    game_id: felt252,
    current_game_state: GameState,
    players: Map::<(felt252, ContractAddress),bool>,
    player_order: Map::<u32, ContractAddress>,
    current_player_index: u8,
    max_players: u8,
    total_players: u8,
    // Game Mechanics
    play_direction: bool, // true: clockwise, false: counter-clockwise

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
fn GameEnded(winner: ContractAddress, score: u256) {}

// Game Initialization
#[external(v0)]
fn create_game(ref self: ContractState, max_players: u8) -> felt252 {
    // Validate player count
    assert(max_players >= 2 && max_players <= 4, 'Invalid player count');

    // Generate unique game ID
    let game_id = generate_game_id(ref self);
    
    // Set up game parameters
    self.game_id.write(game_id);
    self.max_players.write(max_players);
    self.current_game_state.write(GameState::Waiting);
    self.play_direction.write(true);
    let temp = get_caller_address();
    // Emit game creation event
    GameCreated(game_id, temp);
    self.total_players.write(0);
    // self.join_game(game_id);
    
    game_id
    
}
fn generate_game_id(ref self: ContractState) -> felt252 {
    // Increment and return the game ID counter
    let current_counter = self.game_id_counter.read();
    let new_counter = current_counter + 1;
    self.game_id_counter.write(new_counter);
    new_counter
}

// Player Join Mechanism
// Player Join Mechanism
// #[external(v0)]
// fn join_game(ref self: ContractState, game_id: felt252) {
//     // Validate game state
//     assert(self.current_game_state.read() == GameState::Waiting, 'Game already started');
//     assert(self.total_players < self.max_players.read().into(), 'Game is full');

//     let player = get_caller_address();
    
//     // Prevent duplicate joins
//     assert(!self.players.read((game_id, player)), 'Already joined');

//     // Add player
//     self.players.write((game_id, player), true);
//     self.player_order.write(self.total_players, player);
//     self.total_players.write(self.total_players+1);

//     // Emit player join event
//     PlayerJoined(game_id, player);

//     // Start game if max players reached
//     if self.total_players == self.max_players.read().into() {
//         start_game(ref self,game_id);
//     }
// }

// fn start_game(ref self: ContractState, game_id: felt252) {

//     // Set initial game state
//     self.current_game_state.write(GameState::InProgress);
    
//     // Select first player
//     self.current_player_index.write(total_players-1);

//     // Emit game start event
//     GameStarted(game_id);
// }

}