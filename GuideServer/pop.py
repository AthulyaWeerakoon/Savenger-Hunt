import sys
import ssl  # https://docs.python.org/3/library/ssl.html
import socket  # https://docs.python.org/3/library/socket.html


intf = '127.0.0.1'
port = 6789


def client(intf, port, err=1):
    """Simple TLS client"""
    context = ssl.create_default_context()
    context.check_hostname = False
    # context.verify_mode = ssl.CERT_NONE
    # context.post_handshake_auth = False

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.settimeout(2)
        sock.connect((intf, port))
        if err == 1:
            # import requests;
            # requests.get(f'https://{intf}:{port}/', verify=False)
            # OR
            # import urllib3;
            # urllib3.connection_from_url(f'https://{intf}:{port}/').request('GET', '/')
            context.wrap_socket(sock)  # FileNotFoundError: [Errno 2] No such file or directory
        else:
            # import urllib.request, ssl;
            # ctx = ssl.create_default_context();
            # ctx.check_hostname = False;
            # urllib.request.urlopen(f'https://{intf}:{port}/', context=ctx)
            context.wrap_socket(sock, server_hostname=intf)  # OSError: [Errno 0] Error

    # https://bugs.python.org/issue35324
    """
    Traceback (most recent call last):
    File "poc.py", line .., in <module>
        context.wrap_socket(sock)
    File "C:\Apps\Python375\lib\ssl.py", line 423, in wrap_socket
        session=session
    File "C:\Apps\Python375\lib\ssl.py", line 870, in _create
        self.do_handshake()
    File "C:\Apps\Python375\lib\ssl.py", line 1139, in do_handshake
        self._sslobj.do_handshake()
    FileNotFoundError: [Errno 2] No such file or directory
    """


def server(intf, port):
    """Buggy server that close socket during handshake"""
    def sni_callback(
        sock: ssl.SSLSocket,
        req_hostname: str,
        cb_context: ssl.SSLContext
    ):
        sock.close()
        return None

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((intf, port))
    s.listen(8)
    default_timeout = s.gettimeout()
    print("Serving on {}:{}".format(intf, port))

    try:
        while True:
            # https://stackoverflow.com/questions/34871191/cant-close-socket-on-keyboardinterrupt
            s.settimeout(0.5)
            try:
                conn, (host, port) = s.accept()
            except socket.timeout:
                continue
            s.settimeout(default_timeout)
            print('connected')

            context = ssl.create_default_context(purpose=ssl.Purpose.CLIENT_AUTH)
            # https://stackoverflow.com/questions/41996833/using-ssl-context-set-servername-callback-in-python
            context.set_servername_callback(sni_callback)
            #context.load_cert_chain(certfile="cert.pem", keyfile="cert.key")
            try:
                ssl_sock = context.wrap_socket(conn, server_side=True)
            except OSError:
                pass

            conn.close()
            # try:
            #     handle_client(ssl_sock, (host, port))
            # finally:
            #     conn.close()

    except KeyboardInterrupt:
        s.close()


if __name__ == '__main__':
    if len(sys.argv) < 2 or sys.argv[1] not in {'server', 'client', 'client2'}:
        print('Usage: poc.py {server,client}')
        raise SystemExit()
    if sys.argv[1] == 'client':
        client(intf, port)
    if sys.argv[1] == 'client2':
        client(intf, port, err=2)
    if sys.argv[1] == 'server':
        server(intf, port)