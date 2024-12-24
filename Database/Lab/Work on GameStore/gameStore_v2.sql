CREATE TABLE IF NOT EXISTS users
(
    user_id character varying(10) NOT NULL,
    username character varying(50) NOT NULL,
    password_hash character(50),
    email character varying(100),
    phone_number character varying(20),
    balance money NOT NULL,
    status boolean,
    create_time date,
    CONSTRAINT pk_user PRIMARY KEY (user_id)
);

CREATE TABLE IF NOT EXISTS games
(
    game_id character(10) NOT NULL,
    name character varying(50) NOT NULL,
    genre_id character(10) NOT NULL,
    release_date date NOT NULL,
    status character varying(10) NOT NULL,
    revenue money NOT NULL,
    developer_id character(10) NOT NULL,
    rating numeric(2, 1),
    price money,
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
    cost money NOT NULL,
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

ALTER TABLE IF EXISTS games
    ADD CONSTRAINT fk_genres FOREIGN KEY (genre_id)
    REFERENCES genres (genre_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


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

