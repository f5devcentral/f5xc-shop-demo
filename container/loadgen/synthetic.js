import http from 'k6/http';
import { sleep, check } from 'k6';
import {parseHTML} from "k6/html";
import { addRandAgent } from './helpers.js';

export function synthetic() {
    const base = `${__ENV.TARGET_URL}`
    let res = http.get(base, addRandAgent());
    const doc = parseHTML(res.body);
    //Get a product
    let products = doc.find("a").toArray()
    products = products.filter(item => item.attr("href") !== "/cart")
    var product = products[Math.floor(Math.random()*products.length)] || "/product/0PUK6V6EV0" //if we were blocked, use a dummy product
    //Add to Cart
    let data = {
      product_id: product.attr("href").split("/").pop(),
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