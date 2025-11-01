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
import { Config } from './config';
import { Field } from './field';
import { Player } from './player';

interface CellData {
    x: number;
    y: number;
    _hash: hash;
}

export function Game() {
    const cell_size = 34;
    const gm = GoManager();
    const battle = Battle();

    function init() {
        EventBus.on('MSG_ON_UP', on_click);
        render_player(Config.start_pos_ufield_x, Config.start_pos_ufield_y, battle.user);
        render_player(Config.start_pos_bfield_x, Config.start_pos_bfield_y, battle.bot);
    }

    function render_player(st_x: number, st_y: number, player: Player) {
        render_field(st_x, st_y, player.get_field());
    }

    function render_field(start_pos_x: number, start_pos_y: number, field: Field) {
        for (let y = 0; y < field.height; y++) {
            for (let x = 0; x < field.width; x++) {
                gm.make_go("cell", vmath.vector3(x * 34 + start_pos_x, y * (-34) + start_pos_y, 0));
            }
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
        const cell_cord = in_cell(Config.start_pos_bfield_x, Config.start_pos_bfield_y, tmp);
        log(cell_cord);
        if (!cell_cord) {
            return;
        }
        const shot_state = battle.bot.shot(cell_cord.x, cell_cord.y);
        switch (shot_state.state) {
            case ShotState.HIT:
                render_shot(cell_cord.x, cell_cord.y, "hit", Config.start_pos_bfield_x, Config.start_pos_bfield_y);
                break;
            case ShotState.MISS:
                render_shot(cell_cord.x, cell_cord.y, "miss", Config.start_pos_bfield_x, Config.start_pos_bfield_y);
                break;
            case ShotState.KILL:
                render_killed(cell_cord.x, cell_cord.y, shot_state.data!, Config.start_pos_bfield_x, Config.start_pos_bfield_y);
                break;
        }
        battle.bot.get_field().debug();
    }

    function render_shot(x: number, y: number, state: string, st_x: number, st_y: number) {
        gm.make_go(state, vmath.vector3(x * cell_size + st_x/*Config.start_pos_bfield_x,*/, y * (-cell_size) + st_y, 1));
    }

    function render_killed(x: number, y: number, data: { x: number, y: number }[], field_start_pos_x: number, field_start_pos_y: number) {
        render_shot(x, y, "hit", field_start_pos_x, field_start_pos_y);
        for (let i = 0; i < data.length; i++) {
            const cord = data[i];
            render_shot(cord.x, cord.y, "miss", field_start_pos_x, field_start_pos_y);
        }
        if (battle.bot.is_win()) {
            log("win");
        }
    }

    init();

    return { on_message };
}

export type Game = ReturnType<typeof Game>;



