/* eslint-disable @typescript-eslint/no-empty-function */
/* eslint-disable prefer-const */
/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/no-unsafe-argument */
/* eslint-disable @typescript-eslint/no-unsafe-assignment */
/* eslint-disable @typescript-eslint/no-unsafe-member-access */
import * as druid from 'druid.druid';
import { PlayerIndex } from './game';

interface props {
    druid: DruidClass;
}

export function init(this: props): void {
    this.druid = druid.new(this);
    this.druid.new_button('reset', function () {
        EventBus.send('ON_RESET', {});
    });
    EventBus.on('ON_SWIYCH_TURN', (index: number) => {
        const turm_marker = gui.get_node('turm_marker');
        switch (index) {
            case PlayerIndex.PLAYER:
                gui.set_rotation(turm_marker, vmath.vector3(0, 0, 180));
                break;
            case PlayerIndex.BOT:
                gui.set_rotation(turm_marker, vmath.vector3(0, 0, 0));
                break;
        }
    });
}

export function on_input(this: props, action_id: string | hash, action: unknown): void {
    this.druid.on_input(action_id, action);
}

export function update(this: props, dt: number): void {
    this.druid.update(dt);
}

export function on_message(this: props, message_id: string | hash, message: any, sender: string | hash | url): void {
    this.druid.on_message(message_id, message, sender);
}

export function final(this: props): void {
    this.druid.final();
    EventBus.off_all_current_script();
}

