# Help Lightning Web SDK Sample

This is a very simple web example illustrating how to use the Help
Lightning javascript SDK.

This requires the sample Integration server in the `../hlserver/`
directory to be configured and running.

## Pre-requisites

To run this sample, you will first need to make sure you have an
account on Help Lightning and have permissions to generate a partner
key and an api key for your site.

This sample requires an "integration server", which is a secure
backend that holds the partner key and api key. This server will make
requests to the Help Lightning API on behalf of the client.

An integration server is included in the `../hlserver/`
directory. Please read the corresponding README.md to configure and
run that server.

You will also need a web server to host the files in this
directory. For testing, you can use the one built into python3:

```sh
python -m http.server
```

This will run a simple server on port 8000, and you can connect to it
by opening your web browser to http://localhost:8000

## Running

To run the demo, you will need two accounts that you can access in
your Help Lightning site.

:warning:
> You can open up the demo in two different tabs, however, 
>  this will cause conflicts since both will write to the
>  same localStorage.
> Please use different profiles or an incognito window for
>  one of the tabs!

In one browser, log in as one of the users. You'll notice you are not
prompted for a password. See the `Warning about Authentication`
section below.

In a second browser, log in as a different user in your site.

Next, in the first browser, enter the email address of the second user
and click `Create New Session`. You will now be in the connecting
screen and a `PIN` will be visible at the top.

In the second browser, enter the `PIN` and click `Join Session`.

You will now be in a Help Lightning video session.

You will notice that there is no direct signaling (userA calls userB,
userB rings, userB accepts). It is possible to use Help Lightning's
signaling, but it requires that you set up a server that accepts
web-hooks to receive the signaling events, and then push them down to
your clients.

This example uses "out of band signaling". In this case, our sample
server generated a 4-digit PIN code, and this was sent from one user
to another, via SMS, email, calendar invite, verbally, telepathically,
etc.

## Integration Server

Authentication in Help Lightning can be handled in many ways. In this
example, we are using a Help Lightning partner key, which allows you
to act on behalf of your site or any of your users.

This allows you to manage authentication in your app in the normal
way, then have your backend/integration server act on behalf of your
users with regards to Help Lightning.

A Partner Key should _NEVER_ be exposed or embedded in the front-end clients!

## Important Parts of the SDK

The Help Lightning javascript SDK is very simple. It _only_ includes
the 'In Call' portion of Help Lightning. You can of course make
requests to the Help Lightning RESTful API, but that is out of the
scope of this SDK.

Here are the steps to show a Help Lightning call inside of your web
application:

* Acquire a user token, sessionId, session token, and a session URL. (Please see
   the hlserver example on how this is done)
* Create a `<div>` that Help Lightning can embed into.
* Include the following in your head section:
```javascript
    <!-- Load help lightning JS SDK -->
    <script src="https://helplightning.net/sdk/helplightning.min.js"></script>
    <script src="https://helplightning.net/sdk/opentok-enterprise/opentok.min.js"></script>
    <script src="https://helplightning.net/sdk/pdf_viewer/build/pdf.min.js"></script>
```
* Create a new client from the factory:
```javascript
let callClient = HL.CallClientFactory.CallClient;
```
* Create a new call. You need to pass in the:
   1. SessionId
   1. session token
   1. user token
   1. Server URL
   1. An optional API Key (or an empty string)
   1. A display name for the user
   1. An optional URL to an avatar (or an empty string)
```javascript
        const call = new HL.Call(state.session.session_id,
                                 state.session.session_token,
                                 state.session.user_token,
                                 state.session.url,
                                 '', name, '');
```
* Define your callback delegates. These functions will be called
   based on events from Help Lightning. There are two events you can
   capture: 1) `onCallEnded` 2) `onScreenCaptureCreated`. Make sure
   you assign your delegate to the call client.
```javascript
        const delegate = {
            onCallEnded: (reason) =>{
                console.log('onCallEnded', reason);
            },
            onScreenCaptureCreated: (image) => {
                // TODO: prompt to save this somewhere?
                // or ignore it, it'll be uploaded to the server
                //  automatically
            }
        };
        callClient.delegate = delegate;
```
* Start a call. This is an asynchronous method and will return the
   `callId` as the parameter to the callback function. This `callId`
   can be used later to retrieve detailed stats, screen captures, or
   recordings from the Help Lightning RESTful API.
```javascript
        state.callClient.startCall(call, hlDiv).then((callID) => {
            console.log('Call started...', callID);
        }).catch(err => {
            if (err instanceof HL.CallException) {
                console.error('Error creating Help Lightning call', err.message);
            } else {
                console.error('Unknown error', err);
            }
        });
```
* If you need to stop the call from outside of Help Lightning, you
   can use the `stopCurrentCall()` method on the callClient.
```javascript
callClient.stopCurrentCall();
```

## Pinning SDK versions

This example points to the latest version of the Help Lightning SDK
and components. You can pin your version by specifying the version in
the URL:
```javascript
    <script src="https://helplightning.net/sdk/4.34.3/helplightning.min.js"></script>
    <script src="https://helplightning.net/sdk/4.34.3/opentok-enterprise/opentok.min.js"></script>
    <script src="https://helplightning.net/sdk/4.34.3/pdf_viewer/build/pdf.min.js"></script>
```

## Warning about Authentication

:warning: This example does not include any authentication! You can
log into any user in your site and act on their behalf!

It is expected, that in a real application, you will already have your
own authentication method between your web application and your
server. Once authenticated, your backend will then map your internal
authenticated user to a corresponding Help Lightning user, and act on
their behalf, using the partner key.

<!--  LocalWords:  SDK javascript Pre api backend README md python3
 -->
<!--  LocalWords:  http localStorage userA userB SMS 'In Call' JS src
 -->
<!--  LocalWords:  RESTful sessionId hlserver async callClient const
 -->
<!--  LocalWords:  SessionId HL '' onCallEnded onScreenCaptureCreated
 -->
<!--  LocalWords:  'onCallEnded' TODO callId hlDiv callID 'Call call'
 -->
<!--  LocalWords:  instanceof CallException 'Error 'Unknown error'
 -->
<!--  LocalWords:  stopCurrentCall
 -->
