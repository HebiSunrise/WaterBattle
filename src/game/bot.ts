import { generate_random_integer } from "../utils/utils";
import { Config } from './config';

export function Bot() {

    function step() {
        const x = generate_random_integer(Config.field_width);
        const y = generate_random_integer(Config.field_height);



        log(x, y);
        return { x, y };
    }

    return { step };
}
