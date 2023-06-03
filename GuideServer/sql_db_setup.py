import mysql.connector


user = mysql.connector.connect(user='scav', password='1234567b', host='localhost', database='scavengerhunt')
cursor = user.cursor()

cursor.execute("create table create table players (id int not null auto_increment, email varchar(22) not null, "
               "pinhash varchar(128) not null, puzzleid int not null, primary key (id));")
cursor.execute("create table puzzles ( puzzleid int not null auto_increment, puzzle varchar(1000) not null, "
               "img varchar(255), imgtype varchar(1), lang float(10) not null, lat float(10)  not null, err float(10) "
               "not null, primary key(puzzleid));")
cursor.execute("create table leaderboard ( placeid int not null auto_increment, id int not null, primary key(placeid) "
               ");")
cursor.execute("alter table players add foreign key (puzzleid) references puzzles(puzzleid);")
cursor.execute("alter table leaderboard add foreign key (id) references players(id);")
