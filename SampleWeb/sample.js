const helplightningApiKey = '9BoKBM2MQ27nPdHW0XckRw';
const galdrWrapper = () => {
  const url = 'http://localhost:8777/';
  const instance = axios.create({
    baseURL: url,
    timeout: 60000
  })
  return instance
}
const galdrClient = galdrWrapper()

const callClient = HL.CallClientFactory.CallClient;

const user = {
  email: 'small_admin@helplightning.com',
  password: '123456'
};

const hlcall = document.getElementById('hlcall');
const callContactButton = document.getElementById('callContact');

function init () {
  hlcall.innerText = 'Init...';
  
  login(user);
  callContactButton.value = 'Call Contact';
  callContactButton.onclick = callContact;
}

function login () {
  galdrClient.get('auth', { params: {
    email: user.email
  }}).then(res => {
    user.token = res.data.token;
  }).catch(error => {
    console.log(error);
    alert('Login failed.');
  });
}

function callContact () {
  if (user.token) {
    console.log('Call contact...');

    const contact = {
      email: 'small_u1@helplightning.com'
    };
    createSession(user.token, contact).then(session => {
      const call = new HL.Call(session.session_id, session.session_token, user.token, session.ws_url, helplightningApiKey, 'Small Admin', '');

      const delegate = {
        onCallEnded: (reason) => {
          hlcall.innerText = reason;
          callContactButton.innerHTML = 'Call Contact';
          callContactButton.onclick = callContact;
        },
        onScreenCaptureCreated: (image) => {
          console.log('Screen captured.');
          const photoUrl = `data:image/jpeg;base64,${btoa(image)}`;
          const videoSrc = document.getElementById('screen_capture');
          videoSrc.src = photoUrl;
        }
      };

      callClient.delegate = delegate;
      callClient.startCall(call).then(() => {
        callContactButton.innerHTML = 'End Call';
        callContactButton.onclick = endCall;
      }).catch(error => {
        if (error instanceof HL.CallException) {
          console.log('HL error: ' + error.message);
        } else {
          console.log('Unknown error.');
        }
      });
    });
  } else {
    alert('Please login.');
  }
}

function createSession (userToken, contact) {
  return new Promise((resolve, reject) => {
    galdrClient.post('session', { contact_email: contact.email }, { headers: {'Authorization': userToken} }).then(res => {
      resolve(res.data);
    }).catch(error => {
      console.log(error);
      reject(error);
    });
  });
}

function endCall () {
  callClient.stopCurrentCall().then(() => {
    callContactButton.innerHTML = 'Call Contact';
    callContactButton.onclick = callContact;
  });
}

init();
