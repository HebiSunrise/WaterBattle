export enum CellState {
    EMPTY,
    HIT,
    MISS,
    SHIP
}

export function Field(width: number, height: number) {

    const cells_state: CellState[][] = [];
    const ships_cells: number[][] = [];

    function init() {
        for (let y = 0; y < height; y++) {
            cells_state[y] = [];
            ships_cells[y] = [];
            for (let x = 0; x < width; x++) {
                cells_state[y][x] = CellState.EMPTY;
                ships_cells[y][x] = -1;
            }
        }
    }

    function set_cell_state(x: number, y: number, state: CellState) {
        cells_state[y][x] = state;
    }

    function set_ship_cell(x: number, y: number, state: CellState) {
        ships_cells[y][x] = state;
    }

    function get_cell_state(x: number, y: number) {
        return cells_state[y][x];
    }

    function get_ship_cell(x: number, y: number) {
        return ships_cells[y][x];
    }

    function in_boundaries(x: number, y: number) {
        return y >= 0 && y < cells_state.length && x >= 0 && x < cells_state[y].length;
    }

    init();

    return { set_cell_state, set_ship_cell, get_cell_state, get_ship_cell, in_boundaries };
}

export type Field = ReturnType<typeof Field>;