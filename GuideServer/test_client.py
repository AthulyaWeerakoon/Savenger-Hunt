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
            ssock.send(string.encode(encoding='utf-8', errors='ignore'))

            response = ssock.recv(1024).decode()
            print(response)

            if response == 'RI':
                ssock.send('SI'.encode())
                recv_file(ssock, "image.png", 1024)

