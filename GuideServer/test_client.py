import socket
import ssl
from sock_pipeline import recv_file

address = ("127.0.0.1", 443)
context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
# context.load_verify_locations('cert.pem')

with socket.socket(socket.AF_INET, socket.SOCK_STREAM, 0) as sock:
    sock.connect(address)
    with context.wrap_socket(sock) as ssock:
        print(ssock.version())
        while True:
            string = input('Enter data to send: ')
            if string[0] == 'N':
                split_string = string[1:].split(':')
                if split_string != 'P' and split_string != 'T':
                    

            ssock.send(string.encode(encoding='utf-8', errors='ignore'))
            print(ssock.recv(1024).decode())

