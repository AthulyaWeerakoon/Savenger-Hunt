import socket
import ssl
import threading
import mysql.connector
from mysql.connector import errorcode
from email.message import EmailMessage
import random
import smtplib
import hashlib

# server control
server_control = True
thread_list = []

# database control
db = mysql.connector.connect(user='scav', password='1234567b', host='localhost', database='shinding')
cursor = db.cursor()

# mail details
mail_sender = 'noreply.pandacodes@gmail.com'
mail_authentication = 'euetvbwppwgeziag'

# ssl setup for mail client
mail_context = ssl.create_default_context()

# ssl setup for server
address = ("192.168.1.209", 443)
context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
context.load_cert_chain('cert.pem', 'key.pem')

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.bind(address)
sock.listen()


def listen():
    global server_control
    conn = None
    while server_control:
        ssl_sock = context.wrap_socket(sock, server_side=True)
        conn = None
        conn, conn_address = ssl_sock.accept()
        if conn is not None:
            thread_list.append(threading.Thread(target=connection_thread, args=(conn, len(thread_list))))
            thread_list[-1].start()


def send_reg_mail(is_registred: bool, to: str, pin: int):
    em = EmailMessage()
    em['From'] = mail_sender
    em['to'] = to
    em['Subject'] = 'Registration for the Scavenger Hunt'
    body = ""
    signature = ["Rock on, partner!",
                 "Best of luck, buddy :D",
                 "Let the legend unfold, warrior!",
                 "May the force be with you, contestant",
                 "Rewrite the stars, showman ;>"]
    if is_registred:
        body = """
Dear Contestant,
\tYou have already been registered into our Scavenger Hunt. In the chance you forgot what your Login PIN is, it would be: \n\t{}\n
        
        
{}
""".format(pin, signature[random.randint(0, 4)])
    else:
        body = """
Welcome Scavenger!,
\tto our newest event. Take part in this seven day all thrilling event, pursuing clues and mystery on your path to glamour and glory (not that much glamour though, we are still very poor that we barely made this year's budget cut). Anyway, without further ado, here's your PIN number Contestant,
\t{}
        
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
        
\tAnd keep in mind contestant, it's all about the journey, so don't forget to have fun :D
        
        
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


def connection_thread(conn: ssl.SSLSocket, thread_ind: int):
    while True:
        try:
            data = conn.recvfrom(1024)[0].decode()
            '''
            --- login and registration ---
            - receive -
            L followed by mail:pass - login details - implemented
            R followed by mail - register details - implemented
            
            - send -
            EE - invalid email - implemented
            EL - login failed - implemented
            ED - database query error - implemented
            ER - already registered - implemented
            
            SL:ID:QN - successful login: database id: question number - implemented
            SR - successful registration - implemented
            '''
            if data[0] == 'R':
                split_data = data[1:].split()
                for i in range(0, len(split_data)):
                    split_data[i] = split_data[i].lower()
                email = None
                for a in split_data:
                    if a[-14:len(a)] == "@eng.jfn.ac.lk":
                        email = a
                if email is None:
                    send(conn, 'EE')
                else:
                    cursor.execute("select email from players where email = {}".format(email))
                    if len(cursor) == 0:  # for when the player is not registered
                        while True:
                            pin_gen = random.randint(10000, 99999)
                            cursor.execute("select pin from players where pin = {}".format(pin_gen))
                            if len(cursor) == 0:
                                break

                        cursor.execute("insert into players (email, pin) values (\'{}\',\'{}\')".format(email, pin_gen))
                        send_reg_mail(False, email, pin_gen)
                        send(conn, 'SR')

                    else:  # for when the player is already registered
                        cursor.execute("select pin from players where email = {}".format(email))
                        send_reg_mail(True, email, int(cursor[0]))
                        send(conn, 'ER')

            elif data[0] == 'L':
                split_data = data[1:].split(':', 1)
                cursor.execute("Select id, pin, puzzleid from players where email = {} and pin = {}".format(
                    split_data[0].lower(), split_data[1]))
                if len(cursor) == 0:
                    send(conn, 'EL')
                elif len(cursor) == 1:
                    send(conn, "SL:{}:{}".format(cursor[0][0], cursor[0][2]))
                else:
                    send(conn, 'ED')

        except Exception as e:
            print("Exception occurred: \n", e, "\n broke and joined thread "
                  , thread_ind, " handling ", conn.getsockname())
            thread_list[thread_ind].join()
            break
