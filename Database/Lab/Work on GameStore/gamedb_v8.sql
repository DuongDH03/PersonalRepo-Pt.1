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
    CONSTRAINT pk_monitor PRIMARY KEY (admin_id, user_id, m_time)
);

CREATE TABLE IF NOT EXISTS control
(
    admin_id character(10) NOT NULL,
    game_id character(10) NOT NULL,
    action boolean NOT NULL,
    c_time date NOT NULL,
    CONSTRAINT pk_control PRIMARY KEY (admin_id, game_id, c_time)
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
    FROM games join game_rate using (game_id)
    WHERE price = 0
    ORDER BY rating DESC;

-- VIEW Top Paid game
-- Ranked by the Revenue
CREATE VIEW top_paid_games AS
    SELECT name, revenue
    FROM game_revenue JOIN games USING (game_id)
    WHERE price > 0
    ORDER BY revenue DESC;

--CREATE TRIGGER update_balance
--AFTER INSERT ON purchase
--FOR EACH ROW
--EXECUTE PROCEDURE update_user_balance();

-- VIEW Popular Genres
CREATE VIEW popular_genre AS
    SELECT g.genre_name, AVG(r.scoring) AS avg_rating
    FROM genres g
    JOIN belongs_to b USING (genre_id)
    JOIN review r USING (game_id)
    GROUP BY g.genre_name
    ORDER BY avg_rating DESC;

-- Update the Balance of User
CREATE OR REPLACE FUNCTION update_balance()
RETURNS TRIGGER AS $$
DECLARE
    game_price NUMERIC(12,2);
    user_balance NUMERIC(12,2);
    f_username varchar(50);
    f_gamename varchar(50);
BEGIN
    SELECT INTO f_username username FROM users WHERE user_id = NEW.user_id;
    SELECT INTO f_gamename name FROM games WHERE game_id = NEW.game_id;
    SELECT INTO game_price price FROM games WHERE game_id = NEW.game_id;
    SELECT INTO user_balance balance FROM users WHERE user_id = NEW.user_id;
    IF NEW.user_id in (SELECT user_id FROM users WHERE status = 'f') THEN
	RAISE NOTICE '% is being restricted, thus cannot purchase %', f_username, f_gamename;
	RETURN NULL;
    END IF;
    IF NEW.game_id in (SELECT game_id FROM games WHERE status <> 'selling') THEN
	RAISE NOTICE '% is unavailable for purchase now.', f_gamename;
	RETURN NULL;
    END IF;
    IF user_balance >= game_price THEN
        UPDATE users SET balance = balance - game_price WHERE user_id = NEW.user_id;
	RETURN NEW;
    ELSE
        RAISE NOTICE '% cannot buy % due to insufficent funds.', f_username, f_gamename;
	RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER update_balance_trigger
BEFORE INSERT ON purchase
FOR EACH ROW
EXECUTE FUNCTION update_balance();




--Trigger to auto disqualify users who haven't bought game from reviewing/ update scoring of users
CREATE OR REPLACE FUNCTION review_invalid() RETURNS TRIGGER AS $$
DECLARE
        f_username varchar(50);
        f_gamename varchar(50);
BEGIN
        select into f_username username
        from users
        where user_id = NEW.user_id;
        select into f_gamename name
        from games
        where game_id = NEW.game_id;
        IF (NEW.user_id) in (select user_id from users where status = 'f') THEN
                RAISE NOTICE '% is being banned, thus unable to make reviews', f_username;
                RETURN NULL;
        END IF;
        IF (NEW.user_id, NEW.game_id) not in (select user_id, game_id from purchase) THEN
                RAISE NOTICE '% has not owned %, thus unable to leave review.', f_username, f_gamename;
                RETURN NULL;
        ELSE IF (NEW.user_id, NEW.game_id) in (select user_id, game_id from review) THEN
                UPDATE review SET scoring = NEW.scoring where (user_id = NEW.user_id and game_id = NEW.game_id);
                RAISE NOTICE '% has changed their opinion about %', f_username, f_gamename;
                RETURN NULL;
                ELSE RETURN NEW;
                END IF;
        END IF;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER not_available
BEFORE INSERT ON review
FOR EACH ROW
EXECUTE PROCEDURE review_invalid();
  
CREATE OR REPLACE FUNCTION update_status_user() RETURNS TRIGGER AS
$$
BEGIN
	IF (NEW.action = 'f') THEN
		IF NEW.user_id in (SELECT user_id FROM users WHERE status = 'f') THEN
			RAISE NOTICE 'User already restricted';
			RETURN NULL;
		END IF;
		UPDATE users SET status = 'f' WHERE user_id = NEW.user_id;
		RETURN NEW;
	END IF;
	IF (NEW.action = 't') THEN
		IF NEW.user_id in (SELECT user_id FROM users WHERE status = 't') THEN
			RAISE NOTICE 'User already freed';
			RETURN NULL;
		END IF;
		UPDATE users SET status = 't' WHERE user_id = NEW.user_id;
		RETURN NEW;
	END IF;	
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER upon_monitor
BEFORE INSERT ON monitor
FOR EACH ROW
EXECUTE PROCEDURE update_status_user();

CREATE OR REPLACE FUNCTION update_status_game() RETURNS TRIGGER AS
$$
BEGIN
	IF (NEW.action = 't') THEN
		IF NEW.game_id in (SELECT game_id FROM games WHERE status = 'selling') THEN
			RAISE NOTICE 'Games already available';
			RETURN NULL;
		END IF;
		UPDATE games SET status = 'selling' WHERE game_id = NEW.game_id;
		RETURN NEW;
	END IF;
	IF (NEW.action = 'f') THEN
		IF NEW.game_id in (SELECT game_id FROM games WHERE status = 'stopped') THEN
			RAISE NOTICE 'Games already unavailable';
			RETURN NULL;
		END IF;
		UPDATE games SET status = 'stopped' WHERE game_id = NEW.game_id;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER upon_control
BEFORE INSERT ON control
FOR EACH ROW
EXECUTE PROCEDURE update_status_game();

