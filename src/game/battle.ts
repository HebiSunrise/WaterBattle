import { generate_random_integer } from "../utils/utils";
import { CellState, Field } from "./field";

export enum Direction {
    HORIZONTAL,
    VERTICAL
}

interface ShipBB {
    start: { x: number, y: number };
    end: { x: number, y: number };
}

export function Battle() {
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
        const dir_count = 2;
        for (let i = 0; i < ships.length; i++) {
            for (let j = 0; j < ships[i].count; j++) {
                let is_search = true;
                while (is_search) {

                    const start = {
                        x: generate_random_integer(field.width),
                        y: generate_random_integer(field.height)
                    };

                    const end = Object.assign({}, start);
                    const direction = generate_random_integer(dir_count);

                    switch (direction) {
                        case Direction.HORIZONTAL:
                            end.x = end.x + ships[i].length;
                            break;

                        case Direction.VERTICAL:
                            end.y = end.y + ships[i].length;
                            break;
                    }

                    if (!is_can_place_ship(start, end)) {
                        is_search = true;
                    }
                    else {
                        is_search = false;
                        create_ship(start.x, start.y, ships[i].length, direction);
                        log(`start: x:${start.x}, y:${start.y} end: x:${end.x}, y:${end.y}, dir:${direction}, leng:${ships[i].length}`);
                    }
                }
            }
        }
    }

    function is_can_place_ship(start: { x: number, y: number }, end: { x: number, y: number }) {
        if (!field.in_boundaries(start.x, start.y) || !field.in_boundaries(end.x, end.y)) return false;

        for (let y = start.y - 1; y <= end.y + 1; y++) {
            for (let x = start.x - 1; x <= end.x + 1; x++) {
                if (field.in_boundaries(x, y)) {
                    if (field.get_value(x, y) == CellState.SHIP)
                        return false;
                }
            }
        }
        return true;
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
                    index_to_ship_uid[field.get_index(x, y + i)] = ship_uid;
                    field.set_value(x, y + i, CellState.SHIP);
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

    function get_field(): Field {
        return field;
    }

    return { setup, auto_place_ships, try_damage, get_field };
}

export type Battle = ReturnType<typeof Battle>;

