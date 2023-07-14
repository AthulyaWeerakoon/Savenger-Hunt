import ssl


def send_file(conn: ssl.SSLSocket, path: str, size: int = 1024):
    with open(path, "rb") as file:
        while True:
            data = file.read(size)

            if not data:
                if not data:
                    break

                conn.send(data)


def recv_file(conn: ssl.SSLSocket, path: str, size: int):
    with open(path, "wb") as file:
        while True:
            data = conn.recv(size)

            if not data:
                break

            file.write(data)

