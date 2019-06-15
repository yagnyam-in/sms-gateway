# SMS Gateway

Use your phone as SMS Gateway  


[![Download Android](https://img.shields.io/badge/download-android-blue.svg)](https://dl.sg.yagnyam.in/app)
[![Web Site](https://img.shields.io/badge/web-site-blue.svg)](https://www.sg.yagnyam.in)


## Instructions to Send SMS

App `MyFancyAPP` should be created on Mobile App with access token `1234567890` for this to work.
   
```bash
curl -X POST -H "Content-Type: application/json" -d@- https://sg.yagnyam.in/api <<-EOF
{
    "phone": "+911987887891",
    "message": "Hello from the other side",
    "appId": "MyFancyAPP",
    "accessToken": "1234567890"
}
EOF
```


