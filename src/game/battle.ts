
import { CellState, Field } from "./field";
import { Player } from "./player";

export enum Direction {
    HORIZONTAL,
    VERTICAL
}

export enum ShotState {
    HIT,
    MISS,
    KILL,
    ERROR
}

export interface ShotInfo {
    state: ShotState;
    shot_pos: { x: number, y: number };
    data?: { x: number, y: number }[];
}

interface ShipBB {
    start: { x: number, y: number };
    end: { x: number, y: number };
}

export interface BattleConfig {
    width: number;
    height: number;
    start_turn_callback: VoidCallback;
    end_turn_callback: VoidCallback;
    win_callback: VoidCallback;
}

type VoidCallback = () => void;

export type ShawCallBack = (x: number, y: number, player: Player) => void;

export function Battle() {
    const players: Player[] = [];
    let current_turn_player_index = 0;
    let current_turn_player_shot_state: ShotState;
    let start_turn_cb: VoidCallback;
    let end_turn_cb: VoidCallback;
    let win_cb: VoidCallback;
    let turn_timer: hash;

    function setup(config: BattleConfig) {
        start_turn_cb = config.start_turn_callback;
        end_turn_cb = config.end_turn_callback;
        win_cb = config.win_callback;
        const player1 = Player();
        const player2 = Player();

        player1.setup(config.width, config.height);
        player2.setup(config.width, config.height);
        players.push(player1, player2);

        // TODO: вынести авторасстановку короблей 
        player1.auto_place_ships([
            { length: 4, count: 1 },
            { length: 3, count: 2 },
            { length: 2, count: 3 },
            { length: 1, count: 4 },
        ]);
        player2.auto_place_ships([
            { length: 4, count: 1 },
            { length: 3, count: 2 },
            { length: 2, count: 3 },
            { length: 1, count: 4 },
        ]);
    }

    function start() {
        // TODO: решить кто первый ходит
        start_turn();
    }

    function start_turn() {
        current_turn_player_shot_state = ShotState.ERROR;
        turn_timer = timer.delay(5, false, end_turn);
        start_turn_cb();
    }

    function end_turn() {
        timer.cancel(turn_timer);
        end_turn_cb();
        if (is_win()) {
            win_cb();
            return;
        }
        if (is_need_switch_turn())
            switch_turn();

        start_turn();
    }

    function is_need_switch_turn() {
        return current_turn_player_shot_state === ShotState.ERROR || current_turn_player_shot_state === ShotState.MISS;
    }

    function switch_turn() {
        current_turn_player_index = 1 - current_turn_player_index;
    }

    function get_current_turn_player_index() {
        return current_turn_player_index;
    }

    function get_current_player() {
        return players[current_turn_player_index];
    }

    function get_opponent(self_idx: number) {
        return players[1 - self_idx];
    }

    function get_players() {
        return players;
    }

    function get_player(index: number) {
        return players[index];
    }

    function shot(x: number, y: number): ShotInfo {
        const player = get_opponent(current_turn_player_index);
        const field = player.get_field();
        const cell_state = field.get_value(x, y);

        if (cell_state == CellState.HIT || cell_state == CellState.MISS) {
            current_turn_player_shot_state = ShotState.ERROR;
            return { state: ShotState.ERROR, shot_pos: { x, y } };
        }

        if (!player.has_ship_part(x, y)) {

            field.set_value(x, y, CellState.MISS);
            current_turn_player_shot_state = ShotState.MISS;
            return { state: ShotState.MISS, shot_pos: { x, y } };
        }

        field.set_value(x, y, CellState.HIT);
        current_turn_player_shot_state = ShotState.HIT;

        const ship = player.get_ship(x, y);
        player.ships_lifes[ship]--;

        if (player.ships_lifes[ship] == 0) {
            current_turn_player_shot_state = ShotState.KILL;
            return { state: ShotState.KILL, shot_pos: { x, y }, data: player.miss_around_ship(ship) };
        }

        return { state: ShotState.HIT, shot_pos: { x, y } };
    }

    function is_win() {
        const player = get_opponent(get_current_turn_player_index());
        if (player.ships_uids.every(ship => player.ships_lifes[ship] == 0)) {
            return true;
        }
        return false;
    }

    return {
        setup,
        start,
        shot,
        end_turn,
        get_current_turn_player_index,
        get_current_player,
        get_opponent,
        get_players,
        get_player
    };
}

export type Battle = ReturnType<typeof Battle>;