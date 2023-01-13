import { sleep } from "k6";
import { randomString } from 'https://jslib.k6.io/k6-utils/1.2.0/index.js';

import { crawler } from "./crawler.js";
import { bot } from "./bot.js";
import { exploit } from "./exploit.js";
import { synthetic } from "./synthetic.js";

export const options = {
    stages: [
      { target: 10, duration: `${__ENV.DURATION}` }
    ]
  };

const cookieValue = `%7B%22diA%22%3A%22${randomString(8)}`;

function getRandom(min, max) {
    return Math.random() * (max - min) + min;
  }

export default function main() {
  exploit(cookieValue);
  synthetic(cookieValue);
  crawler(cookieValue);
  bot(cookieValue);
  sleep(getRandom(2, 5));
}