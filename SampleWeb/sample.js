// Location of the sample HLServer
const HOST_URL = 'http://localhost:8777'

// Backend data center for the SDK: 'dev' | 'eu1' | 'produs' (default 'produs').
// Legacy 'US'/'EU' values are still accepted.
const DATA_CENTER = 'produs'

function refresh(state) {
    console.log('refresh', state);
    if (state.error) {
        document.querySelector('#errorMsg').visible = true;
    } else {
        document.querySelector('#errorMsg').visible = false;
    }

    let login = document.querySelector('#login');
    let authenticated = document.querySelector('#authenticated');
    let incall = document.querySelector('#incall');

    if (state.state == STATE_LOGIN) {
        show(login);
        hide(authenticated);
        hide(incall);
    } else if (state.state == STATE_AUTHENTICATED) {
        hide(login);
        show(authenticated);
        hide(incall);
    } else if (state.state == STATE_IN_CALL) {
        hide(login);
        hide(authenticated);

        // update the pin code
        let sessionPincode = document.querySelector('#session-pincode');
        sessionPincode.innerHTML = state.session.pin;

        // start the HL SDK
        let hlDiv = document.querySelector('#hl-call');
        state.callClient = HL.CallClientFactory.CallClient;

        // Runtime assets (Zoom /lib WASM/workers and the PDF worker) load from
        //  `${assetBaseUrl}/zoom/videosdk/<version>/lib`. Point this at wherever
        //  the packaged SDK assets are hosted. Here they live in ./sdk alongside
        //  the bundle, so the base is `<origin>/sdk`.
        state.callClient.assetBaseUrl = `${window.location.origin}/sdk`;

        let name = randomName();
        // The 8th argument selects the backend data center (see DATA_CENTER above).
        const call = new HL.Call(state.session.session_id,
                                 state.session.session_token,
                                 state.session.user_token,
                                 state.session.url,
                                 '', name, '', DATA_CENTER);
        // Delegates for call events. The SDK emits onCallEnded and
        //  onScreenCaptureCreated. Knowledge sharing is now handled by the SDK's
        //  built-in content library, so no knowledge delegate is required.
        const delegate = {
            onCallEnded: (reason) => {
                console.log('onCallEnded', reason);
                // set the state back to authenticated
                state.state = STATE_AUTHENTICATED;
                state.session = null;
                state.callClient = null;

                refresh(state);
            },
            onScreenCaptureCreated: (image) => {
                // `image` is a complete data URL (e.g. "data:image/png;base64,...").
                //  The capture is also uploaded to the Help Lightning server automatically.
                console.log('onScreenCaptureCreated');
            }
        };

        state.callClient.setDelegate(delegate);
        state.callClient.startCall(call, hlDiv).then((callID) => {
            console.log('Call started...', callID);
        }).catch(err => {
            if (err instanceof HL.CallException) {
                console.error('Error creating Help Lightning call', err.message);
            } else {
                console.error('Unknown error', err);
            }

            resetState(state);
            refresh(state);
        });
        
        show(incall);
    } else {
        console.warn('Unknown state', state);
        resetState(state);
        refresh(state);
    }
}

function show(div) {
    div.style.display = 'block';
}

function hide(div) {
    div.style.display = 'none';
}

function resetState(state) {
    state.state = STATE_LOGIN;
    state.error = null;
    state.token = null;
    state.session = null;
    state.callClient = null;
}

function randomName() {
    let n = Math.floor(Math.random() * 100000);
    return `User_${n}`;
}

function onLogin(target, state) {
    let email = document.querySelector('#username').value;
    let params = new URLSearchParams({'email': email});
    
    return fetch(`${HOST_URL}/auth?${params.toString()}`)
        .then(response => {
            if (response.ok) {
                return response.json();
            } else {
                throw new Error('Invalid email address');
            }
        })
        .then(response => {
            let newState = {
                ...state,
                state: STATE_AUTHENTICATED, // move to authenticated state
                token: response.token
            };
            
            return newState;
        });
}

function createSession(target, state) {
    let email = document.querySelector('#contact').value;

    return fetch(`${HOST_URL}/session`, {
        method: 'POST',
        headers: {
            'Content-type': 'application/json',
            'Authorization': state.token
        },
        body: JSON.stringify({'contact_email': email})
    }).then(response => {
        if (response.ok) {
            return response.json()
        } else {
            throw new Error('Unable to create session');
        }
    }).then(response => {
        let newState = {
            ...state,
            state: STATE_IN_CALL,
            session: {
                pin: response.sid,
                session_id: response.session_id,
                user_token: response.user_token,
                session_token: response.session_token,
                url: response.ws_url
            }
        };
        
        return newState;
    });
}

function joinSession(target, state) {
    let pin = document.querySelector('#pincode').value;
    let params = new URLSearchParams({'sid': pin});
    
    return fetch(`${HOST_URL}/session?${params.toString()}`, {
        method: 'GET',
        headers: {
            'Authorization': state.token
        }
    }).then(response => {
        if (response.ok) {
            return response.json();
        } else {
            throw new Error('Invalid PIN');
        }
    }).then(response => {
        let newState = {
            ...state,
            state: STATE_IN_CALL,
            session: {
                pin: response.sid,
                session_id: response.session_id,
                user_token: response.user_token,
                session_token: response.session_token,
                url: response.ws_url
            }
        };
        
        return newState;
    });
}
