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
import { Battle } from './battle';

interface CellData {
    x: number;
    y: number;
    _hash: hash;
}

export function Game() {
    const cell_size = 20;
    const gm = GoManager();
    const battle = Battle();

    function init() {
        const battle = Battle();
        battle.setup(10, 10);
        battle.auto_place_ships([
            { length: 4, count: 1 },
            { length: 3, count: 2 },
            { length: 2, count: 3 },
            { length: 1, count: 4 },
        ]);

        const field = battle.get_field();
        for (let y = 0; y < field.height; y++) {
            let output = '';
            for (let x = 0; x < field.width; x++) {
                output = output + " " + field.get_value(x, y);
            }
            log(y + 1 + " " + output);
        }

        wait_event();
    }

    function wait_event() {
        while (true) {
            const [message_id, message] = flow.until_any_message();
            gm.do_message(message_id, message);
        }
    }

    init();

    return {};
}


