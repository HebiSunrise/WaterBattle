import { copy } from "../utils/utils";

export enum CellState {
    EMPTY,
    HIT,
    MISS,
    SHIP
}

export function Field(width: number, height: number) {
    const values: CellState[][] = [];

    function init() {
        for (let y = 0; y < height; y++) {
            values[y] = [];
            for (let x = 0; x < width; x++) {
                values[y][x] = CellState.EMPTY;
            }
        }
    }

    function set_value(x: number, y: number, value: CellState) {
        values[y][x] = value;
    }

    function get_value(x: number, y: number): CellState {
        return values[y][x];
    }

    function in_boundaries(x: number, y: number) {
        return y >= 0 && y < values.length && x >= 0 && x < values[y].length;
    }

    function get_index(x: number, y: number): number {
        return y * width + x;
    }

    function load_state(state: CellState[][]) {
        for (let y = 0; y < state.length; y++) {
            for (let x = 0; x < state[y].length; x++) {
                set_value(x, y, state[y][x]);
            }
        }
    }

    function save_state(): CellState[][] {
        return copy(values);
    }

    function debug() {
        for (let y = 0; y < height; y++) {
            let output = '';
            for (let x = 0; x < width; x++) {
                output = output + " " + get_value(x, y);
            }
            log(y + 1 + " " + output);
        }
    }

    init();

    return {
        set_value,
        get_value,
        in_boundaries,
        get_index,
        debug,
        load_state,
        save_state,
        width: width,
        height: height
    };
}

export type Field = ReturnType<typeof Field>;