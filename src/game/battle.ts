import { generate_random_integer } from "../utils/utils";
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
    data?: { x: number, y: number }[];
}

interface ShipBB {
    start: { x: number, y: number };
    end: { x: number, y: number };
}

export function Battle() {
    const user = Player();
    const bot = Player();
    user.setup(10, 10);
    bot.setup(10, 10);
    bot.auto_place_ships([
        { length: 4, count: 1 },
        { length: 3, count: 2 },
        { length: 2, count: 3 },
        { length: 1, count: 4 },
    ]);

    return { user: user, bot: bot };
}

export type Battle = ReturnType<typeof Battle>;