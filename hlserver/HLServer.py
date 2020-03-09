#!/usr/bin/env python3

import http.server
import urllib.parse
import json
import random
import os

import HLAPI

PARTNER_KEY=open(os.environ.get('HLSERVER_PARTNER_KEY'), 'r').read()
ENTERPRISE_ID=os.environ.get('HLSERVER_ENTERPRISE_ID')
APIKEY=os.environ.get('HLSERVER_API_KEY')

class SessionIDS:
    ids={}

class Server(http.server.BaseHTTPRequestHandler):
    def do_HEAD(self):
        return

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('access-control-allow-credentials', 'true')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('access-control-allow-methods', 'POST, GET, OPTIONS, DELETE')
        self.send_header('access-control-allow-headers', 'Accept, Authorization, Content-Type, DNT, Referer, Sec-Fetch-Dest, User-Agent')
        self.send_header('content-length', '0')
        self.send_header('allow', 'GET, HEAD, POST, PUT, DELETE, PATCH, OPTIONS')
        self.end_headers()

    def do_GET(self):
        self.respond()

    def do_POST(self):
        self.respond()

    def respond(self):
        url_r = urllib.parse.urlparse(self.path)
        path = url_r.path
        qs = urllib.parse.parse_qs(url_r.query)
        
        if path in Router.routes.get(self.command, {}):
            (status, headers, content) = Router.routes[self.command][path](self, qs)
        else:
            (status, headers, content) = (404, {'content-type': 'text/plain'}, 'Not found')

        self.send_response(status)
        for k, v in headers.items():
            self.send_header(k, v)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(bytes(content, 'UTF-8'))

    def post_data(self):
        ct = self.headers.get('content-type').strip()

        # Read until we have reach size
        def do_read(f, size):
            def do_read_r(f, size, data):
                d = f.read(size)
                data += d
                return (data, size - len(d), len(d))

            data, remaining, read = do_read_r(self.rfile, size, b'')
            while remaining > 0 or read == 0:
                data, remaining, read = do_read_r(self.rfile, remaining, data)

            return data
        
        # read up to content-length
        remaining = int(self.headers['content-length'])
        data = do_read(self.rfile, remaining)

        # parse based on the content-type
        if ct.startswith('application/json'):
            return json.loads(data)
        else:
            return d

    """
    Authenticate a user. This just looks up
    a user in our enterprise based on an email
    address and returns an authentication token
    that can be used with the /session API
    """
    def GET_auth(self, params):
        if 'email' not in params:
            return (400, {'content-type': 'text/plain'}, 'Missing query parameter email')

        email = params['email'][0]

        api = HLAPI.HLAPI(APIKEY, PARTNER_KEY, ENTERPRISE_ID)
        user = api.auth_user(email)

        response = {
            'token': user.token
        }
        
        return (
            200, {'content-type': 'application/json'}, json.dumps(response)
        )

    """
    Create a new session and returns the necessary
    details for connecting to it. This also returns
    a 4-digit sid which can be given to the other
    user so they can look up the session themselves.

    Headers:
    Authorization: token from /auth router

    Body: (Dictionary)
    contact_email: The email of the person we want to create a session with
    
    Return: (Dictionary)
    sid: The session PIN
    user_token: A User token for connecting to Help Lightning GSS
    session_token: A Session token for connecting to Help Lightning GSS
    url: The URL of the Help Lightning GSS server
    """
    def POST_session(self, _):
        auth = self.headers.get('authorization').strip()
        if auth is None:
            return (400, {'content-type': 'text/plain'}, 'Missing Authorization header')
        
        data = self.post_data()
        if 'contact_email' not in data:
            return (400, {'content-type': 'text/plain'}, 'Missing post data. Missing contact_email parameter')

        contact_email = data['contact_email']

        api = HLAPI.HLAPI(APIKEY, PARTNER_KEY, ENTERPRISE_ID)
        user2 = api.auth_user(contact_email)

        user1 = HLAPI.HLAPI.User(0, '', '', auth)
        
        # create a session
        session = api.make_session(user1, user2)

        # generate a 4-digit pin
        pin = self.generate_pin()
        SessionIDS.ids[pin] = session

        content = {
            'sid': pin,
            'session_id': session.sid,
            'session_token': session.participant1.session_token,
            'user_token': session.participant1.user_token,
            'url': session.url,
            'ws_url': session.ws_url
        }
        
        return (
            200, {'content-type': 'application/json'}, json.dumps(content)
        )

    """
    Look up an existing session based on the 4-digit
    sid and return the necessary details for connecting to it.

    Headers:
    Authorization: token from /auth router

    Params: 
    sid: The 4-digit sid from a previsouly created session
    
    Return: (Dictionary)
    sid: The session PIN
    user_token: A User token for connecting to Help Lightning GSS
    session_token: A Session token for connecting to Help Lightning GSS
    url: The URL of the Help Lightning GSS server
    """
    def GET_session(self, params):
        auth = self.headers.get('authorization').strip()
        if auth is None:
            return (400, {'content-type': 'text/plain'}, 'Missing Authorization header')
        
        if 'sid' not in params:
            return (400, {'content-type': 'text/plain'}, 'Missing query parameters sid')
        
        pin = params['sid'][0]
        if pin not in SessionIDS.ids:
            return (400, {'content-type': 'text/plain'}, 'Invalid sid')

        session = SessionIDS.ids[pin]

        content = {
            'sid': pin,
            'session_id': session.sid,
            'session_token': session.participant2.session_token,
            'user_token': session.participant2.user_token,
            'url': session.url
        }
        
        return (
            200, {'content-type': 'application/json'}, json.dumps(content)
        )

    def generate_pin(self):
        while True:
            v = (random.randint(0, 9),
                 random.randint(0, 9),
                 random.randint(0, 9),
                 random.randint(0, 9))
            pin = f'{v[0]}{v[1]}{v[2]}{v[3]}'

            if pin not in SessionIDS.ids:
                return pin

class Router:
    """
    This is our Router to define
    which routes and how to handle them
    """
    routes = {
        'GET': {
            '/auth': Server.GET_auth,
            '/session': Server.GET_session
        },
        'POST': {
            '/session': Server.POST_session
        },
        'HEAD': {

        }
    }

if __name__ == '__main__':
    httpd = http.server.HTTPServer(('0.0.0.0', 8777), Server)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
