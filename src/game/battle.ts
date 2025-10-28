import { CellState, Field } from "./field";

export enum Direction {
    HORIZONTAL,
    VERTICAL,
}

interface ShipInfo {
    start: { x: number, y: number };
    end: { x: number, y: number };
}

function Battle() {
    let uid_counter = 0;

    let field: Field;

    const ships: number[] = [];
    const ships_lifes: { [ship: number]: number } = {};
    const ships_info: { [ship: number]: ShipInfo } = {};

    function setup(fieldWidth: number, fieldHiegth: number) {
        field = Field(fieldWidth, fieldHiegth);
    }

    function auto_chto_to_tam() {
        // TODO: автоматически расставляем корабли
        create_ship(0, 0, 3, Direction.HORIZONTAL);
    }

    function create_ship(x: number, y: number, length: number, direction: Direction): number {
        const ship = generate_uid();
        ships.push(ship);

        ships_lifes[ship] = length;


        const start = { x, y };
        let end = { x, y };

        switch (direction) {
            case Direction.HORIZONTAL:
                for (let i = 0; i < length; i++) {
                    field.set_ship_cell(x + i, y, CellState.SHIP);
                    field.set_cell_state(x + i, y, CellState.SHIP);
                }
                end = { x: x + length - 1, y };
                break;
            case Direction.VERTICAL:
                for (let i = 0; i < length; i++) {
                    field.set_ship_cell(x + i, y, CellState.SHIP);
                    field.set_cell_state(x + i, y, CellState.SHIP);
                }
                end = { x, y: y + length - 1 };
                break;
        }

        ships_info[ship] = { start, end };

        return ship;
    }

    function try_damage(x: number, y: number): boolean {
        if (field.get_ship_cell(x, y) == -1) {
            field.set_cell_state(x, y, CellState.MISS);
            return false;
        }

        field.set_cell_state(x, y, CellState.HIT);

        const ship = field.get_ship_cell(x, y);
        ships_lifes[ship]--;

        if (ships_lifes[ship] == 0) {
            miss_around_ship(ship);
        }

        return true;
    }

    function miss_around_ship(ship: number) {
        const { start, end } = ships_info[ship];
        for (let y = start.y - 1; y <= end.y + 1; y++) {
            for (let x = start.x - 1; x <= end.x + 1; x++) {
                if (field.in_boundaries(x, y)) {
                    if (field.get_cell_state(x, y) != CellState.SHIP)
                        field.set_cell_state(x, y, CellState.MISS);
                }
            }
        }
    }

    function is_win(): boolean {
        return ships.every(ship => ships_lifes[ship] == 0);
    }

    function generate_uid(): number {
        return uid_counter++;
    }

    return { setup, auto_chto_to_tam, try_damage };
}

const battle = Battle();
battle.setup(10, 10);