/* eslint-disable no-case-declarations */
import { copy, generate_random_integer } from "../utils/utils";
import { Battle, ShotInfo, ShotState } from "./battle";
import { CellState, Field } from "./field";

export interface BotState {
    last_hit: { x: number, y: number };
    first_hit: { x: number, y: number };
    available_indexes: number[];
    neighbors: { x: number, y: number }[];
    was_hit: boolean;
    was_no_hit: boolean;
}

export function Bot(battle: Battle, player_idx: number) {
    let last_hit = { x: -1, y: -1 };
    let first_hit = { x: -1, y: -1 };
    let available_indexes: number[] = [];
    let neighbors: { x: number, y: number }[] = [];
    let was_hit = false;
    let was_no_hit = true;

    function setup() {
        const opponent = battle.get_opponent(player_idx);
        const field = opponent.get_field();
        for (let y = 0; y < field.height; y++) {
            for (let x = 0; x < field.width; x++) {
                available_indexes.push(field.get_index(x, y));
            }
        }
    }

    function shot() {
        const opponent = battle.get_opponent(player_idx);
        const field = opponent.get_field();

        let pos = { x: 0, y: 0 };

        if (was_no_hit)
            pos = generate_pos(field);

        const is_same_first_last_hit = first_hit.x == last_hit.x && first_hit.y == last_hit.y;
        if (was_hit && is_same_first_last_hit) {
            if (neighbors.length == 0)
                detect_neighbors(field);

            if (neighbors.length > 0)
                pos = get_random_neighbor();
        }

        const is_vertical_search = first_hit.x == last_hit.x && first_hit.y != last_hit.y;
        if (is_vertical_search)
            pos = vertical_search(field);

        const is_horizontal_search = first_hit.x != last_hit.x && first_hit.y == last_hit.y;
        if (is_horizontal_search)
            pos = horizontal_search(field);

        const result = battle.shot(pos.x, pos.y);

        switch (result.state) {
            case ShotState.KILL: on_kill(result, field); break;
            case ShotState.HIT: on_hit(result, field); break;
            case ShotState.MISS: on_miss(result, field); break;
        }

        if (first_hit.x != -1) was_hit = true;

        delete_neigh();

        return result;
    }

    function on_kill(info: ShotInfo, field: Field) {
        if (info.data) {
            for (const pos of info.data) {
                const idx = available_indexes.indexOf(field.get_index(pos.x, pos.y));
                if (idx != -1) {
                    available_indexes.splice(idx, 1);
                }
            }
        }
        delete_idx(field, info.shot_pos);
        last_hit.x = info.shot_pos.x;
        last_hit.y = info.shot_pos.y;
        delete_neigh();
        was_no_hit = true;
        was_hit = false;
        first_hit.x = -1;
        first_hit.y = -1;
        last_hit.x = -1;
        last_hit.y = -1;
    }

    function on_hit(info: ShotInfo, field: Field) {
        if (was_no_hit) {
            first_hit.x = info.shot_pos.x;
            first_hit.y = info.shot_pos.y;
            was_no_hit = false;
        }
        last_hit.x = info.shot_pos.x;
        last_hit.y = info.shot_pos.y;
        was_hit = true;
        delete_idx(field, info.shot_pos);
    }

    function on_miss(info: ShotInfo, field: Field) {
        delete_idx(field, info.shot_pos);
        was_hit = false;
    }

    function generate_pos(filed: Field) {
        const index = generate_random_integer(available_indexes.length - 1);
        const x = available_indexes[index] % filed.width;
        const y = math.floor(available_indexes[index] / filed.height);

        return { x, y };
    }

    function delete_idx(field: Field, pos: { x: number, y: number }) {
        const idx = available_indexes.indexOf(field.get_index(pos.x, pos.y));
        available_indexes.splice(idx, 1);
    }

    function delete_neigh() {
        if ((first_hit.x != last_hit.x || first_hit.y != last_hit.y)) {
            if (neighbors.length > 0) {
                neighbors.splice(0, neighbors.length);
            }
        }
    }

    function detect_neighbors(field: Field) {
        if (field.in_boundaries(first_hit.x + 1, first_hit.y) && field.get_value(first_hit.x + 1, first_hit.y) != CellState.MISS) neighbors.push({ x: first_hit.x + 1, y: first_hit.y });
        if (field.in_boundaries(first_hit.x - 1, first_hit.y) && field.get_value(first_hit.x - 1, first_hit.y) != CellState.MISS) neighbors.push({ x: first_hit.x - 1, y: first_hit.y });
        if (field.in_boundaries(first_hit.x, first_hit.y + 1) && field.get_value(first_hit.x, first_hit.y + 1) != CellState.MISS) neighbors.push({ x: first_hit.x, y: first_hit.y + 1 });
        if (field.in_boundaries(first_hit.x, first_hit.y - 1) && field.get_value(first_hit.x, first_hit.y - 1) != CellState.MISS) neighbors.push({ x: first_hit.x, y: first_hit.y - 1 });
    }

    function get_random_neighbor() {
        const next = generate_random_integer(neighbors.length - 1);
        const x = neighbors[next].x;
        const y = neighbors[next].y;
        neighbors.splice(next, 1);
        return { x, y };
    }

    function vertical_search(field: Field) {
        const pos = { x: 0, y: 0 };
        const is_down_search = first_hit.y > last_hit.y;
        if (is_down_search) {
            pos.y = down_search(field);
        }
        const is_up_search = first_hit.y < last_hit.y;
        if (is_up_search) {
            pos.y = up_search(field);
        }
        pos.x = last_hit.x;
        return pos;
    }

    function down_search(field: Field) {
        const check_pos = field.in_boundaries(last_hit.x, last_hit.y - 1);
        if (check_pos && field.get_value(last_hit.x, last_hit.y - 1) != CellState.MISS) {
            return last_hit.y - 1;
        }
        return first_hit.y + 1;
    }

    function up_search(field: Field) {
        const check_pos = field.in_boundaries(last_hit.x, last_hit.y + 1);
        if (check_pos && field.get_value(last_hit.x, last_hit.y + 1) != CellState.MISS) {
            return last_hit.y + 1;
        }
        return first_hit.y - 1;
    }

    function horizontal_search(field: Field) {
        const pos = { x: 0, y: 0 };
        const is_right_search = first_hit.x < last_hit.x;
        if (is_right_search) {
            pos.x = right_search(field);
        }
        const is_left_search = first_hit.x > last_hit.x;
        if (is_left_search) {
            pos.x = left_search(field);
        }
        pos.y = last_hit.y;
        return pos;
    }

    function left_search(field: Field) {
        const check_pos = field.in_boundaries(last_hit.x - 1, last_hit.y);
        if (check_pos && field.get_value(last_hit.x - 1, last_hit.y) != CellState.MISS) {
            return last_hit.x - 1;
        }
        return first_hit.x + 1;
    }

    function right_search(field: Field) {
        const check_pos = field.in_boundaries(last_hit.x + 1, last_hit.y);
        if (check_pos && field.get_value(last_hit.x + 1, last_hit.y) != CellState.MISS) {
            return last_hit.x + 1;
        }
        return first_hit.x - 1;
    }

    function load_state(state: BotState) {
        last_hit = state.last_hit;
        first_hit = state.first_hit;
        available_indexes = state.available_indexes;
        neighbors = state.neighbors;
        was_hit = state.was_hit;
        was_no_hit = state.was_no_hit;
    }

    function save_state(): BotState {
        const result: BotState = {
            last_hit: last_hit,
            first_hit: first_hit,
            available_indexes: copy(available_indexes),
            neighbors: copy(neighbors),
            was_hit: was_hit,
            was_no_hit: was_no_hit,
        };

        return result;
    }

    return {
        setup,
        shot,
        load_state,
        save_state
    };
}
