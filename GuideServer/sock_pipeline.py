import ssl
import os
from tqdm import tqdm


def send_file(conn: ssl.SSLSocket, path: str, size: int = 1024):
    _size = os.path.getsize(path)
    _sent_size = 0
    conn.send(str(_size).encode())
    conn.recv(size)
    bar = tqdm(range(_size), f"Sending file: ", unit="B", unit_scale=True, unit_divisor=size)
    with open(path, "rb") as file:
        while True:
            data = file.read(size)

            if not data:
                break

            conn.send(data)

            bar.update(len(data))
            _sent_size += len(data)

            if _sent_size >= _size:
                break


def recv_file(conn: ssl.SSLSocket, path: str, size: int):
    _size = int(conn.recv(size).decode())
    _recv_size = 0
    bar = tqdm(range(_size), f"Receiving file: ", unit="B", unit_scale=True, unit_divisor=size)
    conn.send('he'.encode())
    with open(path, "wb") as file:
        while True:
            data = conn.recv(size)

            if not data:
                break

            file.write(data)

            bar.update(len(data))
            _recv_size += len(data)

            if _recv_size >= _size:
                break

