--
-- PostgreSQL database dump
--

-- Dumped from database version 15.4 (Ubuntu 15.4-0ubuntu0.23.04.1)
-- Dumped by pg_dump version 15.4 (Ubuntu 15.4-0ubuntu0.23.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: alumnodb
--

CREATE TABLE public.customers (
    customerid integer NOT NULL,
    firstname character varying(50) NOT NULL,
    lastname character varying(50) NOT NULL,
    address1 character varying(50) NOT NULL,
    address2 character varying(50),
    city character varying(50) NOT NULL,
    state character varying(50),
    zip character varying(9),
    country character varying(50) NOT NULL,
    region character(6) NOT NULL,
    email character varying(50),
    phone character varying(50),
    creditcardtype character varying(10) NOT NULL,
    creditcard character varying(50) NOT NULL,
    creditcardexpiration character varying(50) NOT NULL,
    username character varying(50) NOT NULL,
    password character varying(50) NOT NULL,
    age smallint,
    income integer,
    gender character varying(1)
)
WITH (autovacuum_vacuum_threshold='100000000', autovacuum_analyze_threshold='100000000');


ALTER TABLE public.customers OWNER TO alumnodb;

--
-- Name: customers_customerid_seq; Type: SEQUENCE; Schema: public; Owner: alumnodb
--

CREATE SEQUENCE public.customers_customerid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.customers_customerid_seq OWNER TO alumnodb;

--
-- Name: customers_customerid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: alumnodb
--

ALTER SEQUENCE public.customers_customerid_seq OWNED BY public.customers.customerid;


--
-- Name: imdb_actormovies; Type: TABLE; Schema: public; Owner: alumnodb
--

CREATE TABLE public.imdb_actormovies (
    actorid integer NOT NULL,
    movieid integer NOT NULL,
    numparticipation integer NOT NULL,
    "character" text NOT NULL,
    ascharacter text NOT NULL,
    isvoice smallint DEFAULT (0)::smallint NOT NULL,
    isarchivefootage smallint DEFAULT (0)::smallint NOT NULL,
    isuncredited smallint DEFAULT (0)::smallint NOT NULL,
    creditsposition integer DEFAULT 0 NOT NULL
)
WITH (autovacuum_vacuum_threshold='100000000', autovacuum_analyze_threshold='100000000');


ALTER TABLE public.imdb_actormovies OWNER TO alumnodb;

--
-- Name: imdb_actors; Type: TABLE; Schema: public; Owner: alumnodb
--

CREATE TABLE public.imdb_actors (
    actorid integer NOT NULL,
    actorname character varying(128) NOT NULL,
    gender character varying(6) NOT NULL
)
WITH (autovacuum_vacuum_threshold='100000000', autovacuum_analyze_threshold='100000000');


ALTER TABLE public.imdb_actors OWNER TO alumnodb;

--
-- Name: imdb_actors_actorid_seq; Type: SEQUENCE; Schema: public; Owner: alumnodb
--

CREATE SEQUENCE public.imdb_actors_actorid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.imdb_actors_actorid_seq OWNER TO alumnodb;

--
-- Name: imdb_actors_actorid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: alumnodb
--

ALTER SEQUENCE public.imdb_actors_actorid_seq OWNED BY public.imdb_actors.actorid;


--
-- Name: imdb_directormovies; Type: TABLE; Schema: public; Owner: alumnodb
--

CREATE TABLE public.imdb_directormovies (
    directorid integer NOT NULL,
    movieid integer NOT NULL,
    numpartitipation integer NOT NULL,
    ascharacter text,
    participation text,
    isarchivefootage smallint DEFAULT (0)::smallint NOT NULL,
    isuncredited smallint DEFAULT (0)::smallint NOT NULL,
    iscodirector smallint DEFAULT (0)::smallint NOT NULL,
    ispilot smallint DEFAULT (0)::smallint NOT NULL,
    ischief smallint DEFAULT (0)::smallint NOT NULL,
    ishead smallint DEFAULT (0)::smallint NOT NULL
)
WITH (autovacuum_vacuum_threshold='100000000', autovacuum_analyze_threshold='100000000');


ALTER TABLE public.imdb_directormovies OWNER TO alumnodb;

--
-- Name: imdb_directormovies_directorid_seq; Type: SEQUENCE; Schema: public; Owner: alumnodb
--

CREATE SEQUENCE public.imdb_directormovies_directorid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.imdb_directormovies_directorid_seq OWNER TO alumnodb;

--
-- Name: imdb_directormovies_directorid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: alumnodb
--

ALTER SEQUENCE public.imdb_directormovies_directorid_seq OWNED BY public.imdb_directormovies.directorid;


--
-- Name: imdb_directormovies_movieid_seq; Type: SEQUENCE; Schema: public; Owner: alumnodb
--

CREATE SEQUENCE public.imdb_directormovies_movieid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.imdb_directormovies_movieid_seq OWNER TO alumnodb;

--
-- Name: imdb_directormovies_movieid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: alumnodb
--

ALTER SEQUENCE public.imdb_directormovies_movieid_seq OWNED BY public.imdb_directormovies.movieid;


--
-- Name: imdb_directors; Type: TABLE; Schema: public; Owner: alumnodb
--

CREATE TABLE public.imdb_directors (
    directorid integer NOT NULL,
    directorname character varying(128) NOT NULL
)
WITH (autovacuum_vacuum_threshold='100000000', autovacuum_analyze_threshold='100000000');


ALTER TABLE public.imdb_directors OWNER TO alumnodb;

--
-- Name: imdb_directors_directorid_seq; Type: SEQUENCE; Schema: public; Owner: alumnodb
--

CREATE SEQUENCE public.imdb_directors_directorid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.imdb_directors_directorid_seq OWNER TO alumnodb;

--
-- Name: imdb_directors_directorid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: alumnodb
--

ALTER SEQUENCE public.imdb_directors_directorid_seq OWNED BY public.imdb_directors.directorid;


--
-- Name: imdb_moviecountries; Type: TABLE; Schema: public; Owner: alumnodb
--

CREATE TABLE public.imdb_moviecountries (
    movieid integer NOT NULL,
    country character varying(32) NOT NULL
)
WITH (autovacuum_vacuum_threshold='100000000', autovacuum_analyze_threshold='100000000');


ALTER TABLE public.imdb_moviecountries OWNER TO alumnodb;

--
-- Name: imdb_moviecountries_movieid_seq; Type: SEQUENCE; Schema: public; Owner: alumnodb
--

CREATE SEQUENCE public.imdb_moviecountries_movieid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.imdb_moviecountries_movieid_seq OWNER TO alumnodb;

--
-- Name: imdb_moviecountries_movieid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: alumnodb
--

ALTER SEQUENCE public.imdb_moviecountries_movieid_seq OWNED BY public.imdb_moviecountries.movieid;


--
-- Name: imdb_moviegenres; Type: TABLE; Schema: public; Owner: alumnodb
--

CREATE TABLE public.imdb_moviegenres (
    movieid integer NOT NULL,
    genre character varying(32) NOT NULL
)
WITH (autovacuum_vacuum_threshold='100000000', autovacuum_analyze_threshold='100000000');


ALTER TABLE public.imdb_moviegenres OWNER TO alumnodb;

--
-- Name: imdb_moviegenres_movieid_seq; Type: SEQUENCE; Schema: public; Owner: alumnodb
--

CREATE SEQUENCE public.imdb_moviegenres_movieid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.imdb_moviegenres_movieid_seq OWNER TO alumnodb;

--
-- Name: imdb_moviegenres_movieid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: alumnodb
--

ALTER SEQUENCE public.imdb_moviegenres_movieid_seq OWNED BY public.imdb_moviegenres.movieid;


--
-- Name: imdb_movielanguages; Type: TABLE; Schema: public; Owner: alumnodb
--

CREATE TABLE public.imdb_movielanguages (
    movieid integer NOT NULL,
    language character varying(32) NOT NULL,
    extrainformation character varying(128) NOT NULL
)
WITH (autovacuum_vacuum_threshold='100000000', autovacuum_analyze_threshold='100000000');


ALTER TABLE public.imdb_movielanguages OWNER TO alumnodb;

--
-- Name: imdb_movies; Type: TABLE; Schema: public; Owner: alumnodb
--

CREATE TABLE public.imdb_movies (
    movieid integer NOT NULL,
    movietitle character varying(255) NOT NULL,
    movierelease character varying(192) NOT NULL,
    movietype integer NOT NULL,
    year text,
    issuspended smallint DEFAULT 0 NOT NULL,
    ratingmean real,
    ratingcount integer
)
WITH (autovacuum_vacuum_threshold='100000000', autovacuum_analyze_threshold='100000000');


ALTER TABLE public.imdb_movies OWNER TO alumnodb;

--
-- Name: imdb_movies_movieid_seq; Type: SEQUENCE; Schema: public; Owner: alumnodb
--

CREATE SEQUENCE public.imdb_movies_movieid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.imdb_movies_movieid_seq OWNER TO alumnodb;

--
-- Name: imdb_movies_movieid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: alumnodb
--

ALTER SEQUENCE public.imdb_movies_movieid_seq OWNED BY public.imdb_movies.movieid;


--
-- Name: inventory; Type: TABLE; Schema: public; Owner: alumnodb
--

CREATE TABLE public.inventory (
    prod_id integer NOT NULL,
    stock integer NOT NULL,
    sales integer NOT NULL
)
WITH (fillfactor='85', autovacuum_vacuum_threshold='100000000', autovacuum_analyze_threshold='100000000');


ALTER TABLE public.inventory OWNER TO alumnodb;

--
-- Name: COLUMN inventory.stock; Type: COMMENT; Schema: public; Owner: alumnodb
--

COMMENT ON COLUMN public.inventory.stock IS 'quantity in stock';


--
-- Name: COLUMN inventory.sales; Type: COMMENT; Schema: public; Owner: alumnodb
--

COMMENT ON COLUMN public.inventory.sales IS 'quantity sold';


--
-- Name: orderdetail; Type: TABLE; Schema: public; Owner: alumnodb
--

CREATE TABLE public.orderdetail (
    orderid integer NOT NULL,
    prod_id integer NOT NULL,
    price numeric,
    quantity integer NOT NULL
)
WITH (autovacuum_vacuum_threshold='100000000', autovacuum_analyze_threshold='100000000');


ALTER TABLE public.orderdetail OWNER TO alumnodb;

--
-- Name: COLUMN orderdetail.price; Type: COMMENT; Schema: public; Owner: alumnodb
--

COMMENT ON COLUMN public.orderdetail.price IS 'price without taxes when the order was paid';


--
-- Name: orders; Type: TABLE; Schema: public; Owner: alumnodb
--

CREATE TABLE public.orders (
    orderid integer NOT NULL,
    orderdate date NOT NULL,
    customerid integer,
    netamount numeric,
    tax numeric,
    totalamount numeric,
    status character varying(10)
)
WITH (autovacuum_vacuum_threshold='100000000', autovacuum_analyze_threshold='100000000');


ALTER TABLE public.orders OWNER TO alumnodb;

--
-- Name: COLUMN orders.netamount; Type: COMMENT; Schema: public; Owner: alumnodb
--

COMMENT ON COLUMN public.orders.netamount IS 'order total without taxes';


--
-- Name: COLUMN orders.totalamount; Type: COMMENT; Schema: public; Owner: alumnodb
--

COMMENT ON COLUMN public.orders.totalamount IS 'order total including taxes';


--
-- Name: orders_orderid_seq; Type: SEQUENCE; Schema: public; Owner: alumnodb
--

CREATE SEQUENCE public.orders_orderid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orders_orderid_seq OWNER TO alumnodb;

--
-- Name: orders_orderid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: alumnodb
--

ALTER SEQUENCE public.orders_orderid_seq OWNED BY public.orders.orderid;


--
-- Name: products; Type: TABLE; Schema: public; Owner: alumnodb
--

CREATE TABLE public.products (
    prod_id integer NOT NULL,
    movieid integer NOT NULL,
    price numeric NOT NULL,
    description character varying(30) NOT NULL
)
WITH (autovacuum_vacuum_threshold='100000000', autovacuum_analyze_threshold='100000000');


ALTER TABLE public.products OWNER TO alumnodb;

--
-- Name: COLUMN products.price; Type: COMMENT; Schema: public; Owner: alumnodb
--

COMMENT ON COLUMN public.products.price IS 'price without taxes';


--
-- Name: products_movieid_seq; Type: SEQUENCE; Schema: public; Owner: alumnodb
--

CREATE SEQUENCE public.products_movieid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.products_movieid_seq OWNER TO alumnodb;

--
-- Name: products_movieid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: alumnodb
--

ALTER SEQUENCE public.products_movieid_seq OWNED BY public.products.movieid;


--
-- Name: products_prod_id_seq; Type: SEQUENCE; Schema: public; Owner: alumnodb
--

CREATE SEQUENCE public.products_prod_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.products_prod_id_seq OWNER TO alumnodb;

--
-- Name: products_prod_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: alumnodb
--

ALTER SEQUENCE public.products_prod_id_seq OWNED BY public.products.prod_id;


--
-- Name: customers customerid; Type: DEFAULT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.customers ALTER COLUMN customerid SET DEFAULT nextval('public.customers_customerid_seq'::regclass);


--
-- Name: imdb_actors actorid; Type: DEFAULT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.imdb_actors ALTER COLUMN actorid SET DEFAULT nextval('public.imdb_actors_actorid_seq'::regclass);


--
-- Name: imdb_directormovies directorid; Type: DEFAULT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.imdb_directormovies ALTER COLUMN directorid SET DEFAULT nextval('public.imdb_directormovies_directorid_seq'::regclass);


--
-- Name: imdb_directormovies movieid; Type: DEFAULT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.imdb_directormovies ALTER COLUMN movieid SET DEFAULT nextval('public.imdb_directormovies_movieid_seq'::regclass);


--
-- Name: imdb_directors directorid; Type: DEFAULT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.imdb_directors ALTER COLUMN directorid SET DEFAULT nextval('public.imdb_directors_directorid_seq'::regclass);


--
-- Name: imdb_moviecountries movieid; Type: DEFAULT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.imdb_moviecountries ALTER COLUMN movieid SET DEFAULT nextval('public.imdb_moviecountries_movieid_seq'::regclass);


--
-- Name: imdb_moviegenres movieid; Type: DEFAULT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.imdb_moviegenres ALTER COLUMN movieid SET DEFAULT nextval('public.imdb_moviegenres_movieid_seq'::regclass);


--
-- Name: imdb_movies movieid; Type: DEFAULT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.imdb_movies ALTER COLUMN movieid SET DEFAULT nextval('public.imdb_movies_movieid_seq'::regclass);


--
-- Name: orders orderid; Type: DEFAULT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.orders ALTER COLUMN orderid SET DEFAULT nextval('public.orders_orderid_seq'::regclass);


--
-- Name: products prod_id; Type: DEFAULT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.products ALTER COLUMN prod_id SET DEFAULT nextval('public.products_prod_id_seq'::regclass);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customerid);


--
-- Name: imdb_actormovies imdb_actormovies_pkey; Type: CONSTRAINT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.imdb_actormovies
    ADD CONSTRAINT imdb_actormovies_pkey PRIMARY KEY (actorid, movieid, numparticipation);


--
-- Name: imdb_actors imdb_actors_pkey; Type: CONSTRAINT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.imdb_actors
    ADD CONSTRAINT imdb_actors_pkey PRIMARY KEY (actorid);


--
-- Name: imdb_directormovies imdb_directormovies_pkey; Type: CONSTRAINT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.imdb_directormovies
    ADD CONSTRAINT imdb_directormovies_pkey PRIMARY KEY (directorid, movieid, numpartitipation);


--
-- Name: imdb_directors imdb_directors_pkey; Type: CONSTRAINT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.imdb_directors
    ADD CONSTRAINT imdb_directors_pkey PRIMARY KEY (directorid);


--
-- Name: imdb_moviecountries imdb_moviecountries_pkey; Type: CONSTRAINT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.imdb_moviecountries
    ADD CONSTRAINT imdb_moviecountries_pkey PRIMARY KEY (movieid, country);


--
-- Name: imdb_moviegenres imdb_moviegenres_pkey; Type: CONSTRAINT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.imdb_moviegenres
    ADD CONSTRAINT imdb_moviegenres_pkey PRIMARY KEY (movieid, genre);


--
-- Name: imdb_movielanguages imdb_movielanguages_pkey; Type: CONSTRAINT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.imdb_movielanguages
    ADD CONSTRAINT imdb_movielanguages_pkey PRIMARY KEY (movieid, language, extrainformation);


--
-- Name: imdb_movies imdb_movies_pkey; Type: CONSTRAINT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.imdb_movies
    ADD CONSTRAINT imdb_movies_pkey PRIMARY KEY (movieid);


--
-- Name: inventory inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_pkey PRIMARY KEY (prod_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (orderid);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (prod_id);


--
-- Name: imdb_directormovies imdb_directormovies_directorid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.imdb_directormovies
    ADD CONSTRAINT imdb_directormovies_directorid_fkey FOREIGN KEY (directorid) REFERENCES public.imdb_directors(directorid);


--
-- Name: imdb_directormovies imdb_directormovies_movieid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.imdb_directormovies
    ADD CONSTRAINT imdb_directormovies_movieid_fkey FOREIGN KEY (movieid) REFERENCES public.imdb_movies(movieid);


--
-- Name: imdb_moviecountries imdb_moviecountries_movieid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.imdb_moviecountries
    ADD CONSTRAINT imdb_moviecountries_movieid_fkey FOREIGN KEY (movieid) REFERENCES public.imdb_movies(movieid);


--
-- Name: imdb_moviegenres imdb_moviegenres_movieid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.imdb_moviegenres
    ADD CONSTRAINT imdb_moviegenres_movieid_fkey FOREIGN KEY (movieid) REFERENCES public.imdb_movies(movieid);


--
-- Name: imdb_movielanguages imdb_movielanguages_movieid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.imdb_movielanguages
    ADD CONSTRAINT imdb_movielanguages_movieid_fkey FOREIGN KEY (movieid) REFERENCES public.imdb_movies(movieid);


--
-- Name: orderdetail orderdetail_orderid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.orderdetail
    ADD CONSTRAINT orderdetail_orderid_fkey FOREIGN KEY (orderid) REFERENCES public.orders(orderid);


--
-- Name: orders orders_customerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_customerid_fkey FOREIGN KEY (customerid) REFERENCES public.customers(customerid);


--
-- Name: products products_movieid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alumnodb
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_movieid_fkey FOREIGN KEY (movieid) REFERENCES public.imdb_movies(movieid);


--
-- PostgreSQL database dump complete
--

