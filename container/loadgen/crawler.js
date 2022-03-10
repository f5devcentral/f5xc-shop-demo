import http from 'k6/http';
import { sleep, check } from 'k6';
import {parseHTML} from "k6/html";
import { addRandAgent } from './helpers.js';

export function crawler() {
    const base = `${__ENV.TARGET_URL}`
    let res = http.get(base, addRandAgent());
    check(res, {
        'status is 200': (r) => r.status === 200
    });
    const doc = parseHTML(res.body);
    doc.find("a").toArray().forEach(function (item) {
        if (item.attr("href").startsWith('http')) {
            var url = item.attr("href")
        } else {
            var url = base + item.attr("href")
        }
        res = http.get(url, addRandAgent());
        if ( typeof res !== 'undefined') {
            check(res, {
                'status is 200': (r) => r.status === 200
            });
        }
     });
     sleep(.2);
}