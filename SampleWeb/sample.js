// Location of the sample HLServer
const HOST_URL = 'http://localhost:8777'

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

        let name = randomName();
        const call = new HL.Call(state.session.session_id,
                                 state.session.session_token,
                                 state.session.user_token,
                                 state.session.url,
                                 '', name, '');
        // set up some delegates to handle messages
        const delegate = {
            onCallEnded: (reason) =>{
                console.log('onCallEnded', reason);
                // set the state back to authenticated
                state.state = STATE_AUTHENTICATED;
                state.session = null;
                state.callClient = null;

                refresh(state);
            },
            onScreenCaptureCreated: (image) => {
                // TODO: prompt to save this somewhere?
                // or ignore it, it'll be uploaded to the server
                //  automatically
            },
            // onSelectShareKnowledge is optional. If you don't implement it, the feature will be disabled.
            onSelectShareKnowledge: (fileTypes) => {
                // You can prompt to select a file or any other source of files matching the fileTypes.
                // Return a promise that resolves to a file object in shape of { type: 'IMAGE' or 'DOCUMENT', url: 'url_of_file' }
                return showKnowledge();
            },
            // onSelectKnowledgeOverlay is optional. If you don't implement it, the feature will be disabled.
            onSelectKnowledgeOverlay: (fileTypes) => {
                // You can prompt to select a file or any other source of files matching the fileTypes.
                // Return a promise that resolves to a file object in shape of { type: 'IMAGE', url: 'url_of_file' }
                return showKnowledge();
            }
        };

        state.callClient.delegate = delegate;
        // the third parameter is optional and can be left blank
        //  in which case, it will default to the US data center.
        // Current available data centers are:
        //  - US
        //  - EU
        state.callClient.startCall(call, hlDiv, 'US').then((callID) => {
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

function showKnowledge() {
    // Pretend we are fetching knowledge from
    //  a Knowledge Management System somewhere.
    //
    // We need to return a Promise that resolves
    //  with a `{type: 'IMAGE', url: 'https://..'}`
    return fetch('knowledge/knowledge.json')
        .then((res) => res.json())
        .then((knowledge) => {
            let k = document.querySelector('#knowledgeOverlay');
            let body = k.querySelector('.modal-card-body');

            // set the html
            const elems = knowledge.items.map((i) => {
                div = document.createElement('div');
                lbl = document.createElement('label');
                div.append(lbl);

                // a radio button
                inp = document.createElement('input');
                inp.setAttribute('type', 'radio');
                inp.setAttribute('name', 'knowledgeItem');
                inp.setAttribute('value', i.image);
                lbl.append(inp);

                // the image
                img = document.createElement('img');
                img.setAttribute('src', i.thumbnail)
                lbl.append(img);

                return div;
            });
            body.replaceChildren(...elems);
            

            // get the select knowledge button
            let ok_btn = k.querySelector('#selectKnowledge');

            // return a promise
            return new Promise((success, error) => {
                // connect the callback of the ok_btn
                ok_btn.addEventListener('click', () => {
                    // get the selected item
                    const selected_img = document.querySelector("input[type='radio'][name=knowledgeItem]:checked").value;

                    // close the modal
                    closeModal(k);

                    // Call success on the promise with the URL
                    // to the image to load
                    success({type: 'IMAGE', url: selected_img});
                }, {once: true}); // once will remove this event hanlder after being used

                // now show the modal
                openModal(k);
            });
        });
}

function show(div) {
    div.style.display = 'block';
}

function hide(div) {
    div.style.display = 'none';
}

function openModal($el) {
    $el.classList.add('is-active');
}

function closeModal($el) {
    $el.classList.remove('is-active');
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
