import { CellState, Field } from "./field";

export enum Direction {
    HORIZONTAL,
    VERTICAL,
}

interface ShipBB {
    start: { x: number, y: number };
    end: { x: number, y: number };
}

function Battle() {
    let uid_counter = 0;
    let field: Field;

    const ships_uids: number[] = [];
    const ships_bb: { [ship_uid: number]: ShipBB } = {};
    const ships_lifes: { [ship_uid: number]: number } = {};
    const index_to_ship_uid: { [index: number]: number } = {};

    function setup(fieldWidth: number, fieldHiegth: number) {
        field = Field(fieldWidth, fieldHiegth);
    }

    function auto_place_ships(ships: { length: number, count: number }[]) {
        // TODO: автоматически расставляем корабли
        create_ship(0, 0, 3, Direction.HORIZONTAL);
    }

    function create_ship(x: number, y: number, length: number, direction: Direction): number {
        const ship_uid = generate_uid();
        ships_uids.push(ship_uid);

        ships_lifes[ship_uid] = length;

        const start = { x, y };
        let end = { x, y };

        switch (direction) {
            case Direction.HORIZONTAL:
                for (let i = 0; i < length; i++) {
                    index_to_ship_uid[field.get_index(x + i, y)] = ship_uid;
                    field.set_value(x + i, y, CellState.SHIP);
                }
                end = { x: x + length - 1, y };
                break;
            case Direction.VERTICAL:
                for (let i = 0; i < length; i++) {
                    index_to_ship_uid[field.get_index(x + i, y)] = ship_uid;
                    field.set_value(x + i, y, CellState.SHIP);
                }
                end = { x, y: y + length - 1 };
                break;
        }

        ships_bb[ship_uid] = { start, end };

        return ship_uid;
    }

    function try_damage(x: number, y: number): boolean {
        if (!has_ship_part(x, y)) {
            field.set_value(x, y, CellState.MISS);
            return false;
        }

        field.set_value(x, y, CellState.HIT);

        const ship = get_ship(x, y);
        ships_lifes[ship]--;

        if (ships_lifes[ship] == 0) {
            miss_around_ship(ship);
        }

        return true;
    }

    function miss_around_ship(ship: number) {
        const { start, end } = ships_bb[ship];
        for (let y = start.y - 1; y <= end.y + 1; y++) {
            for (let x = start.x - 1; x <= end.x + 1; x++) {
                if (field.in_boundaries(x, y)) {
                    if (field.get_value(x, y) != CellState.SHIP)
                        field.set_value(x, y, CellState.MISS);
                }
            }
        }
    }

    function is_win(): boolean {
        return ships_uids.every(ship => ships_lifes[ship] == 0);
    }

    function get_ship(x: number, y: number): number {
        return index_to_ship_uid[field.get_index(x, y)];
    }

    function has_ship_part(x: number, y: number): boolean {
        return index_to_ship_uid[field.get_index(x, y)] != undefined;
    }

    function generate_uid(): number {
        return uid_counter++;
    }

    return { setup, auto_place_ships, try_damage };
}

const battle = Battle();
battle.setup(10, 10);
battle.auto_place_ships([
    { length: 4, count: 1 },
    { length: 3, count: 2 },
    { length: 2, count: 3 },
    { length: 1, count: 4 },
]);