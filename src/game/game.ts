/* eslint-disable no-case-declarations */
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
import { generate_random_integer } from "../utils/utils";
import { Battle, ShotInfo, ShotState } from './battle';
import { Messages } from '../modules/modules_const';
import { Config } from './config';
import { Field } from './field';
import { Player } from './player';
import { Bot } from './bot';

export function Game() {
    const cell_size = 34;
    const gm = GoManager();
    const PLAYER_INDEX = 0;
    const BOT_INDEX = 1;
    const battle = Battle();
    const bot = Bot(battle, BOT_INDEX);

    let is_block_input = true;

    function init() {
        EventBus.on('MSG_ON_UP', on_click);

        battle.setup({
            width: Config.field_width,
            height: Config.field_height,
            start_turn_callback: on_turn_start,
            end_turn_callback: on_turn_end,
            win_callback: on_win
        });

        bot.setup();
        render_player(Config.start_pos_ufield_x, Config.start_pos_ufield_y, battle.get_player(PLAYER_INDEX));
        render_player(Config.start_pos_efield_x, Config.start_pos_efield_y, battle.get_player(BOT_INDEX));
        battle.start();
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

    function on_turn_start() {
        const idx = battle.get_current_turn_player_index();
        switch (idx) {
            case PLAYER_INDEX:
                // NOTE: если игрок, то нужно просто разблокировать инпут, остальная логика завист от него
                is_block_input = false;
                break;
            case BOT_INDEX:
                // NOTE: если бот, то вызывать его логику
                const bot_shot_info = bot.shot();
                timer.delay(1, false, () => shot_animate(bot_shot_info, Config.start_pos_ufield_x, Config.start_pos_ufield_y, on_shot_end));
                break;
        }
    }

    function on_turn_end() {
        is_block_input = true;
    }

    // NOTE: нужна для того чтобы можно было закончить ход именно после выстрела
    function on_shot_end() {
        battle.end_turn();
    }

    function on_win() {
        log("Победил игрок " + battle.get_current_turn_player_index());
    }


    function shot_animate(info: ShotInfo, st_pos_fld_x: number, st_pos_fld_y: number, on_end: () => void) {
        const x = info.shot_pos.x;
        const y = info.shot_pos.y;
        switch (info.state) {
            case ShotState.HIT:
                render_shot(x, y, "hit", st_pos_fld_x, st_pos_fld_y);
                break;
            case ShotState.MISS:
                render_shot(x, y, "miss", st_pos_fld_x, st_pos_fld_y);
                break;
            case ShotState.KILL:
                render_killed(x, y, info.data!, st_pos_fld_x, st_pos_fld_y);
                break;
            case ShotState.ERROR:
                return;
        }

        on_end();
    }

    // NOTE: когда ход пользователя, мы слушаем инпут и стреляем
    function on_click(pos: { x: number, y: number }) {
        const tmp = Camera.window_to_world(pos.x, pos.y);
        const cell_cord = in_cell(Config.start_pos_efield_x, Config.start_pos_efield_y, tmp);
        if (!cell_cord) {
            return;
        }
        const info = battle.shot(cell_cord.x, cell_cord.y);
        shot_animate(info, Config.start_pos_efield_x, Config.start_pos_efield_y, on_shot_end);
    }

    function in_cell(start_pos_x: number, start_pos_y: number, pos: vmath.vector3) {
        let x = Math.floor((pos.x - (start_pos_x - cell_size * 0.5)) / cell_size);
        let y = Math.floor((-pos.y + (start_pos_y + cell_size * 0.5)) / cell_size);
        if (x < 0 || x > 9 || y < 0 || y > 9)
            return undefined;
        return { x, y };
    }

    function on_message(message_id: hash, message: any) {
        if (is_block_input) return;
        gm.do_message(message_id, message);
    }

    function render_shot(x: number, y: number, state: string, field_start_pos_x: number, field_start_pos_y: number) {
        gm.make_go(state, vmath.vector3(x * cell_size + field_start_pos_x, y * (-cell_size) + field_start_pos_y, 1));
    }

    function render_killed(x: number, y: number, data: { x: number, y: number }[], field_start_pos_x: number, field_start_pos_y: number) {
        render_shot(x, y, "hit", field_start_pos_x, field_start_pos_y);
        for (let i = 0; i < data.length; i++) {
            const cord = data[i];
            render_shot(cord.x, cord.y, "miss", field_start_pos_x, field_start_pos_y);
        }
    }

    init();

    return { on_message };
}

export type Game = ReturnType<typeof Game>;



