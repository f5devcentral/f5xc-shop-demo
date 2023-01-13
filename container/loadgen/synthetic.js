import http from 'k6/http';
import { sleep, check } from 'k6';
import {parseHTML} from "k6/html";
import { addRandAgent } from './helpers.js';

export function synthetic(cookieValue) {
    const base = `${__ENV.TARGET_URL}`
    const jar = http.cookieJar();
    jar.set(base, '_imp_apg_r_', cookieValue);
    let res = http.get(base, addRandAgent()); //Get a session cookie
    //const doc = parseHTML(res.body);
    //console.log(doc)
    //Get a product
    //let products = doc.find("a").toArray()
    //products = products.filter(item => item.attr("href") !== "/cart")
    //var product = products[Math.floor(Math.random()*products.length)] || "/product/0PUK6V6EV0" //if we were blocked, use a dummy product
    //Add to Cart
    let products = [
      "/product/OLJCESPC7Z",
      "/product/66VCHSJNUP",
      "/product/1YMWWN1N4O",
      "/product/L9ECAV7KIM",
      "/product/2ZYFJ3GM2N",
      "/product/0PUK6V6EV0",
      "/product/LS4PSXUNUM",
      "/product/9SIQT8TOJO",
      "/product/6E92ZMYYFZ"
    ]
    let data = {
      product_id: products[Math.floor(Math.random()*products.length)],
      quantity: 1
    };
    res = http.post(base.concat("/cart"), data, addRandAgent());
    check(res, {
      'status is 200': (r) => r.status === 200
    });
    sleep(.2);
    //Checkout
    data = {
      email: "someone@f5.com",
      street_address: "801 5th Avenue",
      zip_code: "98104",
      city: "Seattle",
      state: "WA",
      country: "United States",
      credit_card_number: "4432-8015-6152-0454",
      credit_card_expiration_month: 1,
      credit_card_expiration_year: 2024,
      credit_card_cvv: 789
    };
    res = http.post(base.concat("/cart/checkout"), data, addRandAgent());
    check(res, {
      'status is 200': (r) => r.status === 200
    });
    sleep(.2)
  }