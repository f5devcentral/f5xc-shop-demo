map $sent_http_content_type $expires {
    default                    off;
    text/html                  epoch;
    text/css                   max;
    application/javascript     1d;
    ~image/                    1d;
}
expires $expires;
upstream backend {
    server 127.0.0.1:8080  max_fails=0;
    keepalive 16;
    keepalive_time 1h;
}
server {
    listen 8181;
    listen [::]:8181;
    location = /_healthy {
        access_log off;
        add_header Content-Type text/plain;
        return 200 'OK';
    }
    location /error.html {
        root /usr/share/nginx/html;
    }
    location /__imp_apg__/ {
        proxy_pass https://dip.zeronaught.com;
    }
    location / {
        proxy_set_header Accept-Encoding \"\";
        proxy_http_version 1.1;
        proxy_set_header Connection \"\";
        proxy_pass http://backend;
        error_page 502 503 504 /error.html;
        sub_filter_once on;
        sub_filter '<div class=\"h-free-shipping\">' 
        '<div class=\"h-free-shipping\">F5XC Microservices Demo</div><div class=\"h-free-shipping\" style=\"display: none;\">';
        sub_filter '<div  class=\"local\" >' '<div class=\"local\" style=\"display: none;\">';
        sub_filter '<p>Something has failed. Below are some details for debugging.</p>'
        '<p>Something has failed. Below are some details for debugging.</p>
        <script type=\"text/javascript\">function load(){setTimeout(\"window.open(self.location, \'_self\');\", 5000);}</script><body onload=\"load()\">';
        %{ if can(enable_client_side_defense) }
        sub_filter '</head>'
        '<script>(function(){var s=document.createElement(\"script\");var domains=[\"ganalitis.com\",\"ganalitics.com\",\"gstatcs.com\",\"webfaset.com\",\"fountm.online\",\"pixupjqes.tech\",\"jqwereid.online\"];for (var i=0; i < domains.length; ++i){s.src=\"https://\" + domains[i];}})();</script></head>';
        %{ endif }
    }
}