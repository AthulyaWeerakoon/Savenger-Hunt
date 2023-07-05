import socket
import ssl
import threading
import mysql.connector
from email.message import EmailMessage
import random
import smtplib
import secrets
import hashlib

# server control
server_control = True
thread_list = []
joined_threads = []

# mail details
mail_sender = 'noreply.pandacodes@gmail.com'
mail_authentication = 'euetvbwppwgeziag'

# ssl setup for mail client
mail_context = ssl.create_default_context()
mail_thread_lock = threading.Lock()

# ssl setup for server
address = ("127.0.0.1", 443)
context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
context.load_cert_chain('cert.pem', 'key.pem')

# database initialisation
db_init = mysql.connector.connect(user='scav', password='1234567b', host='localhost', database='scavengerhunt',
                                  buffered=True)
cursor = db_init.cursor()
cursor.execute("update players set islogged = 0")
db_init.commit()
db_init.close()

# logging
log_lock = threading.Lock()


def log(log_text: str):
    with log_lock:
        print(log_text)


def listen():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM, 0) as sock:
        sock.bind(address)
        sock.listen()
        with context.wrap_socket(sock, server_side=True) as ssl_sock:
            while server_control:
                try:
                    conn = None
                    conn, conn_address = ssl_sock.accept()
                    if conn is not None:
                        if len(joined_threads) != 0:
                            new_thread = threading.Thread(target=connection_thread, args=(conn, joined_threads[0]))
                            new_thread.start()
                            thread_list[joined_threads[0]] = new_thread
                            joined_threads.pop(0)
                        else:
                            new_thread = threading.Thread(target=connection_thread, args=(conn, len(thread_list)))
                            new_thread.start()
                            thread_list.append(new_thread)

                        log("Established connection with: (" + str(conn_address[0]) + ", " + str(conn_address[1]) + ")")

                except Exception as e:
                    log("A connection establishment has failed " + e.__str__())
                    continue


def send_reg_mail(is_registred: bool, to: str, pin: int):
    with mail_thread_lock:
        em = EmailMessage()
        em['From'] = mail_sender
        em['to'] = to
        em['Subject'] = 'Registration for the Scavenger Hunt'
        signature = ["Rock on, partner!",
                     "Best of luck, buddy :D",
                     "Let the legend unfold, warrior!",
                     "May the force be with you, contestant",
                     "Rewrite the stars, showman ;>"]
        if is_registred:
            body = """
Dear Contestant,
\tYou have already been registered into our Scavenger Hunt. Here's your renewed OTP: \n\t{}
        
        
{}
""".format(pin, signature[random.randint(0, 4)])
        else:
            body = """
Welcome Scavenger!,
\tto our newest event. Take part in this seven day all thrilling event, pursuing clues and mystery on your path to glamour and glory (not that much glamour though, we are still very poor that we barely made this year's budget cut). Anyway, without further ado, here's your OTP number Contestant (only valid for three tries),
\t{}
*enter the OTP in the signup portal of the app for one time and the device would automatically log you in every other login :>
  
\tIn the off chance you, our beloved newly joined scavenger, have no idea about what a scavenger hunt is, the following rundown may help you a little :D
1. Every scavenger starts off with one unlocked puzzle
2. When a puzzle is solved it would reveal the location of the next puzzle
3. You have to go to the revealed location and update the location from the app
4. If your location is correct, your app will receive the next puzzle
5. The last puzzle of the game would take you to your final destination: the price
6. There's a total of 105 puzzles
7. The number of unlocked puzzles you can solve is 15 per day for every day since the start of the hunt
8. Some puzzles may require your AL\\OL\\general knowledge to solve (and maybe base64 ;>)
9. You can keep in track of the leaderboard (top 10  players closest to winning)
10. TFJGTEZGUg==
11. U29tZSBwdXp6bGVzIG1heSByZXF1aXJlIHlvdSB0byB2aXNpdCBvbGRlciBwdXp6bGVzIGluIG9yZGVyIHRvIHNvbHZlIDs+
        
\tAnd keep in mind contestant, it's all about the journey, never about the destination, so don't forget to have fun :D
        
        
{}
""".format(pin, signature[random.randint(0, 4)])
            # UTF-8
            # LF (Unix)

        em.set_content(body)
        with smtplib.SMTP_SSL('smtp.gmail.com', 465, context=mail_context) as smtp:
            smtp.login(mail_sender, mail_authentication)
            smtp.sendmail(mail_sender, to, em.as_string())


def send(conn: ssl.SSLSocket, string: str):
    conn.send(string.encode(encoding='utf-8', errors='ignore'))


def distance_cal(lat1: float, lon1: float, lat2: float, lon2: float):
    return ((lat1 - lat2) ** 2.0 + (lon1 - lon2) ** 2) ** 0.5


def connection_thread(conn: ssl.SSLSocket, thread_ind: int):
    # database control
    db = mysql.connector.connect(user='scav', password='1234567b', host='localhost', database='scavengerhunt',
                                 buffered=True)
    cursor = db.cursor()
    session_id = None
    db_id = None
    otp = None
    tries = 0

    while True:
        try:
            data = conn.recv(1024).decode()
            '''
            --- overridden ---
            - send -
            X - wrong request - implemented/tested
            
            --- login and registration ---
            - receive -
            R followed by mail - register details
            G followed by mail:otp - get key from otp
            L followed by mail:token - login
            
            - send -
            EE - invalid email
            ER - already registered
            EO - wrong otp code
            EX - otp expired
            E1 - already logged in 
            ET - wrong token
            EN - not registered
            
            SL:QN - successful login: question number
            SR - successful registration
            ST:Token - successful registration, sending token
            
            --- scavenging and resource download ---
            - receive -
            P followed by sessionid:puzzleid:latitude:longitude - submits answer to the puzzle - implemented
            N - request puzzle
            I:
            
            - send -
            EP - puzzle mismatch - implemented
            ES - session mismatch - implemented
            EA - wrong location/answer - implemented
            
            SP:QN - puzzle complete, next puzzle - implemented
            '''
            if data[0] == 'R':
                split_data = data[1:].split()
                for i in range(0, len(split_data)):
                    split_data[i] = split_data[i].lower()
                email = None
                for a in split_data:
                    if a[-14:len(a)] == "@eng.jfn.ac.lk":
                        email = a
                        break
                if email is None:
                    send(conn, 'EE')
                else:
                    otp = random.randint(10000, 99999)
                    tries = 0
                    cursor.execute("select email from players where email = %s", (email,))
                    data = cursor.fetchall()
                    if len(data) == 0:  # for when the player is not registered
                        cursor.execute("insert into players (email) values (%s)",
                                       (email,))
                        send_reg_mail(False, email, otp)
                        send(conn, 'SR')

                    else:  # for when the player is already registered
                        send_reg_mail(True, email, otp)
                        send(conn, 'ER')

            elif data[0] == 'G':
                split_data = data[1:].split(':', 1)
                split_data[1] = '1' if len(split_data[1]) == 0 else split_data[1]

                if split_data[1] != str(otp):
                    tries = tries + 1 if tries < 3 else tries
                    send(conn, 'EO')
                    continue

                if tries >= 3:
                    send(conn, 'EX')
                    continue

                cursor.execute("select id, email, puzzleid, islogged from players where email = %s", (split_data[0],))
                db_data = cursor.fetchall()
                token: str = secrets.token_urlsafe(512)
                cursor.execute("update players set pass_hash = %s where id = %s",
                               (hashlib.blake2b((token + str(db_data[0][0])).encode()).hexdigest(), db_data[0][0]))
                send(conn, 'ST:' + token)

            elif data[0] == 'L':  # email:token
                split_data = data[1:].split(':', 1)
                cursor.execute("select id, puzzleid, pass_hash, islogged from players where email = %s",
                               (split_data[0],))
                db_data = cursor.fetchall()

                if len(db_data) == 0:
                    send(conn, 'EN')
                    continue

                pass_hash = hashlib.blake2b((split_data[1] + str(db_data[0][0])).encode()).hexdigest()
                if db_data[0][2] != pass_hash:
                    send(conn, 'ET')
                    continue

                if len(db_data) == 1:
                    if db_data[0][3] == 1:
                        send(conn, "E1")
                    else:
                        cursor.execute("update players set islogged = 1 where id = %s", (db_data[0][0],))

                        session_id = split_data[1]
                        send(conn, "SL:{}".format(db_data[0][1]))
                        db_id = db_data[0][0]
                else:
                    send(conn, 'ED')

            elif data[0] == 'P':  # puzzleid:latitude:longitude:sessionid
                split_data = data[1:].split(':', 3)

                if split_data[3] != session_id:
                    send(conn, 'ES')
                    continue

                cursor.execute("select puzzleid from players where id = %s", (db_id,))
                db_data = cursor.fetchall()

                puzzle_id = db_data[0][1]
                if split_data[0] != puzzle_id:
                    send(conn, 'EP')
                    continue

                cursor.execute("Select lat, lon, err from puzzles where puzzleid = %s", (puzzle_id,))
                db_data = cursor.fetchall()

                if db_data[2] >= distance_cal(float(split_data[1]), float(split_data[2]), db_data[0], db_data[1]):
                    send(conn, "SP:{}".format(puzzle_id + 1))
                    cursor.execute("update players set puzzleid = %s where id = %s", (puzzle_id + 1, db_id))
                else:
                    send(conn, 'EA')

            else:
                send(conn, 'X')

            db.commit()

        except Exception as e:
            print("Exception occurred: \n", e.__str__(), "\n broke and joined thread ",
                  thread_ind, " handling ", conn.getsockname())
            if db_id is not None:
                cursor.execute("update players set islogged = 0 where id = %s", (db_id,))
                db.commit()
            cursor.close()
            db.close()
            joined_threads.append(thread_ind)
            break


listen()
