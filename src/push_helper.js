var req = new XMLHttpRequest();
req.open("post", "https://push.ubports.com/notify", true); //refer to https://docs.ubports.com/en/latest/appdev/guides/pushnotifications.html
req.setRequestHeader("Content-type", "application/json");
req.onreadystatechange = function() {
        if ( req.readyState === XMLHttpRequest.DONE ) {
                        console.log("✍ Answer:", req.responseText);
        }
}
var approxExpire = new Date ();
approxExpire.setUTCMinutes(approxExpire.getUTCMinutes()+10);
req.send(JSON.stringify({
        "appid" : "appname.yourname_hookname",
        "expire_on": approxExpire.toISOString(),
        "token": "aAnqwiFn§DF%2",
        "data": {
                "notification": {
                        "card": {
                                "icon": "notification",
                                "summary": "Push Notification",
                                "body": "Hello world",
                                "popup": true,
                                "persist": true
                        },
                "vibrate": true,
                "sound": true
                }
        }
}));