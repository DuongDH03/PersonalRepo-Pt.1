CREATE TABLE IF NOT EXISTS users
(
    user_id character varying(10) NOT NULL,
    username character varying(50) NOT NULL,
    password_hash character(50) NOT NULL,
    email character varying(100),
    phone_number character varying(20),
    balance numeric(12,2) NOT NULL,
    status boolean NOT NULL,
    create_time date NOT NULL,
    CONSTRAINT pk_user PRIMARY KEY (user_id)
);

CREATE TABLE IF NOT EXISTS games
(
    game_id character(10) NOT NULL,
    name character varying(50) NOT NULL,
    release_date date NOT NULL,
    status character varying(10) NOT NULL,
    developer_id character(10) NOT NULL,
    price numeric(12,2),
    ver character varying(10) NOT NULL,
    CONSTRAINT pk_game PRIMARY KEY (game_id)
);

CREATE TABLE IF NOT EXISTS genres
(
    genre_id character(10) NOT NULL,
    genre_name character varying(50) NOT NULL,
    CONSTRAINT pk_genres PRIMARY KEY (genre_id)
);

CREATE TABLE IF NOT EXISTS game_dev
(
    developer_id character(10) NOT NULL,
    name character varying(50) NOT NULL,
    email character varying(50),
    address character varying(50),
    website character varying(50),
    starting_date date,
    CONSTRAINT pk_dev PRIMARY KEY (developer_id)
);

CREATE TABLE IF NOT EXISTS administrators
(
    admin_id character(10) NOT NULL,
    admin_name character varying(50) NOT NULL,
    CONSTRAINT pk_admin PRIMARY KEY (admin_id)
);

CREATE TABLE IF NOT EXISTS purchase
(
    user_id character(10) NOT NULL,
    game_id character(10) NOT NULL,
    "time" date NOT NULL,
    CONSTRAINT pk_purchase PRIMARY KEY (user_id, game_id)
);

CREATE TABLE IF NOT EXISTS monitor
(
    admin_id character(10) NOT NULL,
    user_id character(10) NOT NULL,
    action boolean NOT NULL,
    m_time date NOT NULL,
    CONSTRAINT pk_monitor PRIMARY KEY (admin_id, user_id)
);

CREATE TABLE IF NOT EXISTS control
(
    admin_id character(10) NOT NULL,
    game_id character(10) NOT NULL,
    action boolean NOT NULL,
    c_time date NOT NULL,
    CONSTRAINT pk_control PRIMARY KEY (admin_id, game_id)
);

CREATE TABLE IF NOT EXISTS wishlist
(
    user_id character(10) NOT NULL,
    game_id character(10) NOT NULL,
    CONSTRAINT pk_wish PRIMARY KEY (user_id, game_id)
);

CREATE TABLE IF NOT EXISTS review
(
    user_id character(10) NOT NULL,
    game_id character(10) NOT NULL,
    scoring numeric(2, 1) NOT NULL,
    CONSTRAINT pk_review PRIMARY KEY (user_id, game_id)
);

CREATE TABLE IF NOT EXISTS belongs_to(
	game_id char(10) NOT NULL,
	genre_id char(10) NOT NULL,
	CONSTRAINT fk_belong_games FOREIGN KEY (game_id) REFERENCES games (game_id),
	CONSTRAINT fk_belong_genres FOREIGN KEY (genre_id) REFERENCES genres (genre_id),
	CONSTRAINT pk_belongs PRIMARY KEY (game_id, genre_id)
);
ALTER TABLE IF EXISTS games
    ADD CONSTRAINT fk_dev FOREIGN KEY (developer_id)
    REFERENCES game_dev (developer_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS purchase
    ADD CONSTRAINT fk_prch_usr FOREIGN KEY (user_id)
    REFERENCES users (user_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS purchase
    ADD CONSTRAINT fk_prch_game FOREIGN KEY (game_id)
    REFERENCES games (game_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS monitor
    ADD CONSTRAINT fk_monitor_admin FOREIGN KEY (admin_id)
    REFERENCES administrators (admin_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS monitor
    ADD CONSTRAINT fk_monitor_usr FOREIGN KEY (user_id)
    REFERENCES users (user_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS control
    ADD CONSTRAINT fk_control_admin FOREIGN KEY (admin_id)
    REFERENCES administrators (admin_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS control
    ADD CONSTRAINT fk_control_game FOREIGN KEY (game_id)
    REFERENCES games (game_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS wishlist
    ADD CONSTRAINT wish_usr FOREIGN KEY (user_id)
    REFERENCES users (user_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS wishlist
    ADD CONSTRAINT wish_game FOREIGN KEY (game_id)
    REFERENCES games (game_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS review
    ADD CONSTRAINT fk_rate_usr FOREIGN KEY (user_id)
    REFERENCES users (user_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS review
    ADD CONSTRAINT fk_rate_game FOREIGN KEY (game_id)
    REFERENCES games (game_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

-- Create VIEW on Game's Rating 
CREATE VIEW game_rate AS
SELECT game_id, AVG(scoring) AS rating
FROM review
GROUP BY game_id;

CREATE VIEW game_revenue AS
SELECT p.game_id, SUM(g.price) AS revenue
FROM purchase p
JOIN games g ON p.game_id = g.game_id
GROUP BY p.game_id;

-- View Top Free Games
-- Ranked by Rating
CREATE VIEW top_free_games AS
    SELECT name, rating
    FROM games JOIN game_rate USING (game_id)
    WHERE price = 0
    ORDER BY rating DESC;

-- VIEW Top Paid game
-- Ranked by the Revenue
CREATE VIEW top_paid_games AS
    SELECT name, revenue
    FROM game_revenue JOIN games USING (game_id)
    WHERE price > 0
    ORDER BY revenue DESC;

-- Update the Balance of User
CREATE OR REPLACE FUNCTION update_balance()
RETURNS TRIGGER AS $$
DECLARE
    game_price NUMERIC;
    user_balance NUMERIC;
BEGIN
    SELECT price INTO game_price FROM games WHERE game_id = NEW.game_id;
    SELECT balance INTO user_balance FROM users WHERE user_id = NEW.user_id;
    IF user_balance >= game_price THEN
        UPDATE users SET balance = balance - game_price WHERE user_id = NEW.user_id;
    ELSE
        RAISE EXCEPTION 'Cannot buy';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_balance_trigger
BEFORE INSERT ON purchase
FOR EACH ROW
EXECUTE FUNCTION update_balance_after_purchase();

-- VIEW Popular Genres
CREATE VIEW popular_genre AS
    SELECT g.genre_name, AVG(r.scoring) AS avg_rating
    FROM genres g
    JOIN belongs_to b USING (genre_id)
    JOIN review r USING (game_id)
    GROUP BY g.genre_name
    ORDER BY avg_rating DESC;



INSERT INTO genres (genre_id, genre_name) VALUES
	('GE0001', 'Action'),
	('GE0002', 'Casual'),
	('GE0003', 'RPG'),
	('GE0004', 'Visual Novel'),
	('GE0005', 'Violence'),
	('GE0006', 'Gore'),
	('GE0007', 'Rogue-like'),
	('GE0008', 'Sport'),
	('GE0009', 'Multiplayer'),
	('GE0010', 'FPS');

INSERT INTO game_dev (developer_id, name, email, address, website, starting_date)
VALUES
	('GD0001', 'Team Cherry', 'teamcherry@gmail.au', 'Australia', 'hollowknightsilksong.com', '2014-04-02'),
	('GD0002', 'Nintendo', 'nintendo@nintendo.com', 'Japan', 'nintendo.com', '1889-09-23'),
	('GD0003', 'CD Projekt Red', 'cdprojektred@cdprojekt.com', 'Poland', 'cdprojektred.com', '1994-03-16'),
	('GD0004', 'Rockstar Games', 'info@rockstargames.com', 'United States', 'rockstargames.com', '1998-12-01'),
	('GD0005', 'Square Enix', 'info@square-enix.com', 'Japan', 'square-enix.com', '1975-09-22'),
	('GD0006', 'Santa Monica Studio', 'info@santamonicastudio.com', 'United States', 'sms.playstation.com', '1999-02-01'),
	('GD0007', 'CD Projekt Red', 'cdprojektred@cdprojekt.com', 'Poland', 'cdprojektred.com', '1994-03-16'),
	('GD0008', 'Ubisoft', 'info@ubisoft.com', 'France', 'ubisoft.com', '1986-03-12'),
	('GD0009', 'Dut Studios', 'vnstio@ct.vn', 'Vietnam', 'dutquy.studios.vn', '2020-09-23'),
	('GD0010', 'Mojang Studios', 'info@mojang.com', 'Sweden', 'mojang.com', '2009-05-17'),
	('GD0011', '0verflow', 'overflow_vn@gmail.com', 'Japan', 'overflow.ln', '1997-12-01'),
	('GD0012', '11 bit studios', '11bitstudio@gmail.com', 'Poland', NULL, NULL),
	('GD0013', '1C Company', 'ccompany@gmail.com', 'Russia', NULL, NULL),
	('GD0014', 'Snowbird Game Studios', 'snowbird@gmail.com', 'Russia', 'www.snowbirdgames.com', '2012-01-01'), 
	('GD0015', 'Brownie Brown', 'brownie@nintendo.co.jp', 'Japan', 'www.browniebrown.co.jp', '2000-06-30'), 
	('GD0016', 'Hasbro Interactive', 'hasbro@hasbro.com', 'USA', 'www.hasbro.com', '1995-12-01'), 
	('GD0017', 'Adventure Soft', 'adventure@adventuresoft.com', 'England', 'www.adventuresoft.com', '1984-01-01'), 
	('GD0018', 'Ambrella', 'ambrella@ambrella.co.jp', 'Japan', 'www.ambrella.co.jp', '1998-04-01'), 	
	('GD0019', 'Arkedo Studio', 'arkedo@arkedo.com', 'France', 'www.arkedo.com', '2006-10-01'), 
	--('GD0020', 'Aspyr Media', 'aspyr@aspyr.com', 'Texas', 'USA', 'www.aspyr.com', '1996-09-01'), 
	('GD0021','Bethesda Game Studios','bethesda@bethsoft.com','USA','www.bethsoft.com','2001-06-28'), 
	('GD0022','Big Ant Studios','bigant@bigant.com','Australia','www.bigantstudios.com','2001-06-28'),
	('GD0023', 'BioWare', 'bioware@bioware.com', 'Canada', 'www.bioware.com', '1995-02-01'), 
	('GD0024', 'Blizzard Entertainment', 'blizzard@blizzard.com', 'USA', 'www.blizzard.com', '1991-02-08'), 
	('GD0025', 'Capcom', 'capcom@capcom.com', 'Japan', 'www.capcom.com', '1979-06-11'), 
	('GD0026', '42 Entertainment', '42entertain@gmail.com', 'USA', '42entertain.com', '2002-02-01'), 
	('GD0027', 'Crystal Dynamics', 'crystaldynamics@crystald.com', 'USA', 'www.crystald.com', '1992-07-01'), 
	('GD0028', 'Eidos Interactive', 'eidos@eidos.com', 'England', 'www.eidos.com', '1990-01-01'), 	
	('GD0029','Electronic Arts','ea@ea.com','USA','www.ea.com','1982-05-28'), 
	('GD0030','Epic Games','epicgames@epicgames.com','USA','www.epicgames.com','1991-01-01'), 
	('GD0031','FromSoftware','fromsoftware@fromsoftware.jp','Japan','www.fromsoftware.jp','1986-11-01'),
	('GD0032','Game Freak','gamefreak@gamefreak.co.jp','Japan','www.gamefreak.co.jp','1989-04-26'), 
	('GD0033','Gearbox Software','gearbox@gearboxsoftware.com','USA','www.gearboxsoftware.com','1999-02-16'), 
	('GD0034','id Software','idsoftware@idsoftware.com','USA','www.idsoftware.com','1991-02-01'), 
	('GD0035','Insomniac Games','IGO@insomniacgames.com','USA','www.insomniacgames.com','1994-02-28'), 
	('GD0036','Konami Digital Entertainment Co., Ltd.','konami@konami.co.jp ','Japan ','www.konami.co.jp ','1969-03-21'), 
	('GD0037','LucasArts Entertainment Company LLC.','lucasarts@lucasarts.com ','USA','www.lucasarts.com','1982-05-01'), 
	('GD0038','Microsoft Studios Global Publishing','microsoft@microsoftstudios.com','USA','www.microsoftstudios.com ','2002-09-30'), 
	('GD0039','Namco Bandai Games Inc.','namcobandai@namcobandai.co.jp ','Japan ','www.namcobandaigames.co.jp ','1955-06-01'), 
	('GD0040','Naughty Dog Inc.','naughtydog@naughtydog.com ','USA ','www.naughtydog.com ','1984-09-09'),
	('GD0041','NetherRealm Studios LLC.','netherrealmstudios@netherrealmstudios.com ','USA ','www.netherrealmstudios.com','2010-08-31'), 
	('GD0042','Nintendo Co., Ltd.','nintendo@nintendo.co.jp ','Japan ','www.nintendo.co.jp ','1889-09-23'), 
	('GD0043','Obsidian Entertainment Inc.','obsidianentertainment@obsidian.net ','USA','www.obsidian.net ','2003-06-12'), 
	('GD0044','PlatinumGames Inc.','platinumgames@platinumgames.co.jp ','Japan','www.platinumgames.co.jp','2006-08-01'), 
	('GD0045','Polyphony Digital Inc.','polyphonydigital@polyphonydigital.co.jp','Japan','polyphony.co.jp','2001-11-30'), 
	('GD0046','Rare Ltd.','rare@rare.co.uk','UK','rare.games','2001-11-28'),
	('GD0048','Aquaria', 'aquria@aqua.co.jp', 'Japan', 'aquriagames.co', '2007-06-15'),
	('GD0049','Human Entertainment', 'he@gmail.com', 'Japan', 'he_unhe.co.jp', '1997-01-01'),
	('GD0050','Idol Minds', 'idolmind@id.com', 'USA', 'idolminds.co.us', '1997-02-12'),
  	('GD0047', 'Rockstar North', 'info@rockstargames.com', 'United Kingdom', 'rockstargames.com', '1984-12-14');

INSERT INTO Games (game_id, name, release_date, status, developer_id, price, ver)
VALUES
        ('G0101', 'Hollow Knight: Silksong', '2024-02-14', 'selling', 'GD0001', 19.99, '1.0.0.0'),
        ('G0102', 'The Legend of Zelda: Tears of the Kingdom', '2023-06-15', 'selling', 'GD0002',  59.99, '1.6.0'),
        ('G0103', 'Cyberpunk 2077', '2020-12-10', 'selling', 'GD0003', 49.99, '1.31'),
        ('G0104', 'Red Dead Redemption 2', '2018-10-26', 'selling', 'GD0004', 59.99, '1.27'),
        ('G0105', 'Final Fantasy VII Remake', '2020-04-10', 'selling', 'GD0005', 59.99, '1.02'),
        ('G0106', 'God of War', '2018-04-20', 'selling', 'GD0006', 39.99, '1.30'),
        ('G0107', 'The Witcher 3: Wild Hunt', '2015-05-19', 'selling', 'GD0007', 39.99, '1.32'),
        ('G0108', 'Assassins Creed Valhalla', '2020-11-10', 'selling', 'GD0008', 59.99, '3.0.1'),
        ('G0109', 'Super Mario Odyssey', '2017-10-27', 'selling', 'GD0002',  59.99, '1.3.0'),
        ('G0110', 'Minecraft', '2011-11-18', 'selling', 'GD0010', 26.95, '1.17'),
        ('G0001', 'Unchained Blades', '2012-01-19', 'selling', 'GD0018', 19.99, '1.0'),
        ('G0002', 'Hell Yeah! Wrath of the Dead Rabbit', '2012-09-25', 'selling', 'GD0029', 14.99, '1.1'),
        ('G0003', 'Street Fighter IV', '2008-07-18', 'selling', 'GD0033', 39.99, '1.2'),
        ('G0004', 'Crash Boom Bang!', '2006-10-20', 'selling', 'GD0033', 29.99, '1.0'),
        ('G0005', 'Dragon Ball Z: Budokai Tenkaichi 3', '2007-10-04', 'selling', 'GD0033', 49.99, '1.0'),
        ('G0006', 'Dragon Ball Xenoverse 2', '2016-10-25', 'selling', 'GD0033',  59.99, '1.3'),
        ('G0007', 'Sword Art Online: Fatal Bullet', '2018-02-23', 'selling',  'GD0033',  49.99, '1.2'),
        ('G0008', 'Gradius V', '2004-07-22', 'selling', 'GD0036',  19.99, '1.0'),
        ('G0010', 'Metal Gear Solid 4: Guns of the Patriots', '2008-06-12', 'selling',  'GD0036',  59.99, '1.0'),
        ('G0011', 'Castlevania: Lords of Shadow', '2010-10-05', 'selling',  'GD0036',  49.99, '1.0'),
        ('G0012', 'Pro Evolution Soccer 2021', '2020-09-15', 'selling',  'GD0036',  29.99, '1.0'),
        ('G0013', 'Silent Hill: Homecoming', '2008-09-30', 'selling',  'GD0036',  39.99, '1.0'),
        ('G0014', 'TwinBee RPG', '1998-04-02', 'selling',  'GD0036',  19.99, '1.0'),
        ('G0015', 'Dance Dance Revolution A20 Plus', '2020-07-01', 'selling',  'GD0036', 49.99, '1.0'),
        ('G0016', 'Power Pros Touch', '2009-01-21', 'selling', 'GD0034',  9.99, '1.0'),
        ('G0017','Professional Baseball Spirits A','2019-07-18','selling',  'GD0041',  6.99, '1.9'),
        ('G0092', 'The Legend of Zelda: Breath of the Wild', '2017-03-03', 'selling',  'GD0045', 59.99, '1.0'),
        ('G0093', 'Super Mario Odyssey', '2017-10-27', 'selling', 'GD0045',  59.99, '1.0'),
        ('G0094', 'Mario Kart 8 Deluxe', '2017-04-28', 'selling',  'GD0040', 59.99, '1.0'),
        ('G0095', 'Splatoon 2', '2017-07-21', 'selling',  'GD0045',  59.99, '1.0'),
        ('G0096', 'Super Smash Bros. Ultimate', '2018-12-07', 'selling',  'GD0045',  59.99, '1.0'),
        ('G0097', 'Animal Crossing: New Horizons', '2020-03-20', 'selling',  'GD0045',  59.99, '1.0'),
        ('G0098','The Legend of Zelda: Skyward Sword HD','2021-07-16','selling','GD0002',59.99,'1.0'),
        ('G0099','Mario Golf: Super Rush','2021-06-25','selling',  'GD0045',  9.99, '2.0.13'),
        ('G0024', 'Pro Evolution Soccer 2020', '2019-09-10', 'selling',  'GD0036',  29.99, '1.0'),
        ('G0025', 'Zone of the Enders: The 2nd Runner - M∀RS', '2018-09-06', 'selling',  'GD0016',  29.99, '1.0'),
        ('G0026', 'Castlevania: Lords of Shadow – Mirror of Fate HD', '2013-10-29', 'selling',  'GD0036',  14.99, '1.0'),
        ('G0027', 'Pro Evolution Soccer 2018', '2017-09-12', 'selling', 'GD0036',  29.99, '1.0'),
        ('G0028','Professional Baseball Spirits B','2020-07-09','stopped',  'GD0041',  10.99, '1.0'),
        ('G0029', 'Pro Evolution Soccer 2017', '2016-09-13', 'selling',  'GD0036',  29.99, '1.0'),
        ('G0030', 'Metal Gear Solid V: The Phantom Pain', '2015-09-01', 'selling',  'GD0036',  59.99, 1.0),
        ('G0031', 'Pro Evolution Soccer 2016', '2015-09-15', 'selling',  'GD0036',  29.99, '1.0'),
        ('G0032', 'Castlevania: Lords of Shadow 2', '2014-02-25', 'selling',  'GD0036',  39.99, '1.0'),
        ('G0033', 'The Death', '2020-03-19', 'selling', 'GD0009', 3.99, '1.0'),
	('G0009', 'Arcaea', '2017-04-04', 'selling', 'GD0001',  9.99, '4.0.5'),
	('G0019', 'Snake', '1998-01-07', 'selling', 'GD0001',  1.99, '1.0'),
	('G0018', 'Classic Tetris', '1998-02-14', 'selling',  'GD0002', 4.99, '3.0.1'),
	('G0023', 'Freedom Dive', '2001-12-14', 'selling', 'GD0016', 5.99, '1.0.2'),
	('G0020', 'Muse Dash', '2016-02-16', 'selling', 'GD0032',  4.99, '3.2.9'),
	('G0021', 'Rhythm Doctor', '1999-08-14', 'selling',  'GD0002',  5.99, '3.1'),
	('G0022', 'World of Tanks', '2015-08-14', 'selling', 'GD0024',  0.00, '4.15');	
	
INSERT INTO Users (user_id, username, password_hash, email, phone_number, balance, status, create_time)
VALUES
  ('US0001', 'user1', 'password1', 'user1@example.com', '123456789', 100.00, true, '2022-01-01'),
  ('US0002', 'user2', 'password2', 'user2@example.com', '987654321', 10.00, true, '2022-02-02'),
  ('US0003', 'user3', 'password3', 'user3@example.com', '555555555', 200.00, true, '2022-03-03'),
  ('US0004', 'user4', 'password4', 'user4@example.com', '999999999', 75.00, true, '2022-04-04'),
  ('US0005', 'user5', 'password5', 'user5@example.com', '111111111', 150.00, true, '2022-05-05'),
  ('US0006', 'user6', 'password6', 'user6@example.com', '222222222', 300.00, true, '2022-06-06'),
  ('US0007', 'user7', 'password7', 'user7@example.com', '333333333', 250.00, true, '2022-07-07'),
  ('US0008', 'user8', 'password8', 'user8@example.com', '444444444', 180.00, true, '2022-08-08'),
  ('US0009', 'user9', 'password9', 'user9@example.com', '555555555', 120.00, true, '2022-09-09'),
  ('US0010', 'user10', 'password10', 'user10@example.com', '666666666', 220.00, true, '2022-10-10'),
  ('US0011', 'johndoe', 'password11', 'johndoe@example.com', '777777777', 80.00, true, '2022-11-11'),
  ('US0012', 'aliceinwonderland', 'password12', 'alice@example.com', '888888888', 190.00, false, '2022-12-12'),
  ('US0013', 'maverick', 'password13', 'maverick@example.com', '999999999', 250.00, true, '2023-01-01'),
  ('US0014', 'sarahsmith', 'password14', 'sarahsmith@example.com', '11112222333', 150.00, true, '2023-02-02'),
  ('US0015', 'captainjack', 'password15', 'captainjack@example.com', '44445555666', 300.00, true, '2023-03-03'),
  ('US0016', 'emilyrose', 'password16', 'emilyrose@example.com', '77778888999', 280.00, true, '2023-04-04'),
  ('US0017', 'coolgamer', 'password17', 'coolgamer@example.com', '11113333444', 210.00, true, '2023-05-05'),
  ('US0018', 'rockstar23', 'password18', 'rockstar23@example.com', '44445555777', 320.00, true, '2023-06-06'),
  ('US0019', 'superman1985', 'password19', 'superman@example.com', '77778888111', 380.00, true, '2023-07-07'),
  ('US0020', 'rubyred', 'password20', 'rubyred@example.com', '99992222333', 270.00, true, '2023-08-08');


INSERT INTO Wishlist (user_id, game_id)
VALUES
  ('US0001', 'G0003'),
  ('US0001', 'G0005'),
  ('US0001', 'G0007'),
  ('US0002', 'G0004'),
  ('US0002', 'G0006'),
  ('US0002', 'G0008'),
  ('US0003', 'G0009'),
  ('US0003', 'G0010'),
  ('US0003', 'G0012'),
  ('US0004', 'G0014'),
  ('US0004', 'G0015'),
  ('US0004', 'G0017'),
  ('US0005', 'G0018'),
  ('US0005', 'G0019'),
  ('US0005', 'G0021'),
  ('US0006', 'G0022'),
  ('US0006', 'G0023'),
  ('US0006', 'G0025'),
  ('US0007', 'G0027'),
  ('US0007', 'G0028'),
  ('US0007', 'G0030'),
  ('US0008', 'G0011'),
  ('US0008', 'G0013'),
  ('US0008', 'G0015'),
  ('US0009', 'G0016'),
  ('US0009', 'G0018'),
  ('US0009', 'G0020'),
  ('US0010', 'G0021'),
  ('US0010', 'G0023'),
  ('US0010', 'G0025'),
  ('US0011', 'G0026'),
  ('US0011', 'G0028'),
  ('US0011', 'G0030'),
  ('US0012', 'G0004'),
  ('US0012', 'G0006'),
  ('US0012', 'G0008'),
  ('US0013', 'G0009'),
  ('US0013', 'G0011'),
  ('US0013', 'G0013'),
  ('US0014', 'G0014'),
  ('US0014', 'G0016'),
  ('US0014', 'G0018'),
  ('US0015', 'G0019'),
  ('US0015', 'G0021'),
  ('US0015', 'G0023'),
  ('US0016', 'G0024'),
  ('US0016', 'G0026'),
  ('US0016', 'G0028'),
  ('US0017', 'G0029'),
  ('US0017', 'G0030');

INSERT INTO Purchase (user_id, game_id, time)
VALUES
  ('US0001', 'G0002', '2021-11-01'),
  ('US0012', 'G0025', '2022-05-15'),
  ('US0005', 'G0008', '2021-12-07'),
  ('US0018', 'G0030', '2022-08-19'),
  ('US0009', 'G0013', '2022-01-25'),
  ('US0016', 'G0019', '2022-03-30'),
  ('US0010', 'G0023', '2022-06-10'),
  ('US0007', 'G0017', '2022-02-12'),
  ('US0020', 'G0010', '2022-09-03'),
  ('US0003', 'G0029', '2022-04-22'),
  ('US0015', 'G0005', '2022-01-10'),
  ('US0004', 'G0016', '2022-02-28'),
  ('US0011', 'G0011', '2022-05-05'),
  ('US0013', 'G0026', '2022-07-17'),
  ('US0016', 'G0020', '2022-08-25'),
  ('US0006', 'G0003', '2021-12-20'),
  ('US0017', 'G0014', '2022-03-10'),
  ('US0002', 'G0024', '2022-04-03'),
  ('US0014', 'G0007', '2022-07-05'),
  ('US0008', 'G0028', '2022-09-12'),
  ('US0010', 'G0022', '2022-11-28'),
  ('US0005', 'G0004', '2022-01-15'),
  ('US0001', 'G0018', '2022-02-18'),
  ('US0016', 'G0027', '2022-05-22'),
  ('US0003', 'G0021', '2022-08-08'),
  ('US0019', 'G0012', '2022-09-30'),
  ('US0006', 'G0009', '2022-02-05'),
  ('US0007', 'G0025', '2022-04-12'),
  ('US0004', 'G0006', '2022-06-15'),
  ('US0012', 'G0023', '2022-09-18'),
  ('US0009', 'G0017', '2022-11-08'),
  ('US0013', 'G0020', '2023-01-03'),
  ('US0008', 'G0003', '2022-03-20'),
  ('US0015', 'G0014', '2022-06-25'),
  ('US0011', 'G0019', '2022-09-07'),
  ('US0017', 'G0028', '2022-11-12'),
  ('US0002', 'G0011', '2023-01-15'),
  ('US0018', 'G0026', '2022-03-25'),
  ('US0014', 'G0021', '2022-05-30'),
  ('US0001', 'G0005', '2022-09-02'),
  ('US0016', 'G0016', '2022-11-15'),
  ('US0003', 'G0027', '2023-01-20'),
  ('US0019', 'G0022', '2022-03-05'),
  ('US0006', 'G0012', '2022-05-10'),
  ('US0010', 'G0009', '2022-07-15'),
  ('US0005', 'G0025', '2022-09-20'),
  ('US0012', 'G0006', '2022-11-25'),
  ('US0007', 'G0011', '2023-01-30'),
  ('US0013', 'G0016', '2023-03-05');



