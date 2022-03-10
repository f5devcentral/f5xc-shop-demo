import { SharedArray } from "k6/data";

var agentHeaders = new SharedArray("all the agents", function() {
    var f = JSON.parse(open("./user-agents.json"));
    return f;
});

var botAgentHeaders = new SharedArray("bot agents", function() {
    var f = JSON.parse(open("./crawler-user-agents.json"));
    return f;
});

export function addRandAgent() {
    var element = agentHeaders[Math.floor(Math.random() * agentHeaders.length)]
    var agentHeader = {
        headers: {'User-Agent': element.userAgent}
    }
    return agentHeader;
}

export function addRandBotAgent() {
    var element = botAgentHeaders[Math.floor(Math.random() * botAgentHeaders.length)]
    var instance = element.instances[Math.floor(Math.random() * element.instances.length)]
    var crawlerHeader = {
        headers: {'User-Agent': instance}
    }
    return crawlerHeader;
}