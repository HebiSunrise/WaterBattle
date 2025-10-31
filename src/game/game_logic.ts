/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/no-unsafe-argument */
/* eslint-disable no-constant-condition */
/* eslint-disable @typescript-eslint/no-unsafe-assignment */
/* eslint-disable @typescript-eslint/no-unsafe-call */
/* eslint-disable no-empty */
/* eslint-disable @typescript-eslint/no-non-null-assertion */
/* eslint-disable prefer-const */
/* eslint-disable @typescript-eslint/no-unsafe-member-access */
/* eslint-disable @typescript-eslint/explicit-module-boundary-types */
/* eslint-disable @typescript-eslint/no-empty-function */

import * as flow from 'ludobits.m.flow';
import { GoManager } from '../modules/GoManager';
import { Battle, ShotState } from './battle';
import { Messages } from '../modules/modules_const';

interface CellData {
    x: number;
    y: number;
    _hash: hash;
}

export function Game() {
    const cell_size = 34;
    const gm = GoManager();
    const battle = Battle();
    const start_pos_ufield_x = 50;
    const start_pos_ufield_y = -50;
    const start_pos_bfield_x = 440;
    const start_pos_bfield_y = -50;

    function init() {
        battle.setup(10, 10);
        EventBus.on('MSG_ON_UP', on_click);

        battle.auto_place_ships([
            { length: 4, count: 1 },
            { length: 3, count: 2 },
            { length: 2, count: 3 },
            { length: 1, count: 4 },
        ]);

        debug_field();

        render_field(start_pos_ufield_x, start_pos_ufield_y);
        render_field(start_pos_bfield_x, start_pos_bfield_y);
    }

    function render_field(start_pos_x: number, start_pos_y: number) {
        const field = battle.get_field();
        for (let y = 0; y < field.height; y++) {
            for (let x = 0; x < field.width; x++) {
                gm.make_go("cell", vmath.vector3(x * 34 + start_pos_x, y * (-34) + start_pos_y, 0));
            }
        }
    }

    function debug_field() {
        const field = battle.get_field();
        for (let y = 0; y < field.height; y++) {
            let output = '';
            for (let x = 0; x < field.width; x++) {
                output = output + " " + field.get_value(x, y);
            }
            log(y + 1 + " " + output);
        }
    }

    function in_cell(start_pos_x: number, start_pos_y: number, pos: vmath.vector3) {
        let x = Math.floor((pos.x - (start_pos_x - cell_size * 0.5)) / cell_size);
        let y = Math.floor((-pos.y + (start_pos_y + cell_size * 0.5)) / cell_size);
        if (x < 0 || x > 9 || y < 0 || y > 9)
            return undefined;
        return { x, y };
    }

    function on_message(message_id: hash, message: any) {
        gm.do_message(message_id, message);
    }

    function on_click(pos: { x: number, y: number }) {
        const tmp = Camera.window_to_world(pos.x, pos.y);
        log(tmp.x, " ", tmp.y);
        // const cell_cord = in_cell(start_pos_ufield_x, start_pos_ufield_y, tmp);
        const cell_cord = in_cell(start_pos_bfield_x, start_pos_bfield_y, tmp);
        log(cell_cord);
        if (!cell_cord) {
            return;
        }
        const shot_state = battle.shot(cell_cord.x, cell_cord.y);
        switch (shot_state.state) {
            case ShotState.HIT:
                render_shot(cell_cord.x, cell_cord.y, "hit");
                break;
            case ShotState.MISS:
                render_shot(cell_cord.x, cell_cord.y, "miss");
                break;
            case ShotState.KILL:
                render_killed(cell_cord.x, cell_cord.y, shot_state.data!);
                break;
        }
        debug_field();
    }

    function render_shot(x: number, y: number, state: string) {
        gm.make_go(state, vmath.vector3(x * cell_size + start_pos_bfield_x, y * (-cell_size) + start_pos_bfield_y, 1));
    }

    function render_killed(x: number, y: number, data: { x: number, y: number }[]) {
        render_shot(x, y, "hit");
        for (let i = 0; i < data.length; i++) {
            const cord = data[i];
            render_shot(cord.x, cord.y, "miss");
        }
        if (battle.is_win()) {
            log("win");
        }
    }

    init();

    return { on_message };
}

export type Game = ReturnType<typeof Game>;



