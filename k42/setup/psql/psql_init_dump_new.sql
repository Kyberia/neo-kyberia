--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.9
-- Dumped by pg_dump version 9.1.9
-- Started on 2013-08-25 22:27:39 CEST

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 170 (class 3079 OID 11644)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 1970 (class 0 OID 0)
-- Dependencies: 170
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 501 (class 1247 OID 17283)
-- Dependencies: 5
-- Name: acc_enum; Type: TYPE; Schema: public; Owner: kyberia
--

CREATE TYPE acc_enum AS ENUM (
    'master',
    'op',
    'access',
    'silence',
    'ban',
    'execute'
);


ALTER TYPE public.acc_enum OWNER TO kyberia;

--
-- TOC entry 511 (class 1247 OID 17324)
-- Dependencies: 5
-- Name: l_order; Type: TYPE; Schema: public; Owner: kyberia
--

CREATE TYPE l_order AS ENUM (
    'asc',
    'desc'
);


ALTER TYPE public.l_order OWNER TO kyberia;

--
-- TOC entry 498 (class 1247 OID 17266)
-- Dependencies: 5
-- Name: link_enum; Type: TYPE; Schema: public; Owner: kyberia
--

CREATE TYPE link_enum AS ENUM (
    'hard',
    'soft',
    'bookmark',
    'synapse'
);


ALTER TYPE public.link_enum OWNER TO kyberia;

--
-- TOC entry 491 (class 1247 OID 17246)
-- Dependencies: 5
-- Name: menum; Type: TYPE; Schema: public; Owner: kyberia
--

CREATE TYPE menum AS ENUM (
    'no',
    'to',
    'from',
    'both'
);


ALTER TYPE public.menum OWNER TO kyberia;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 169 (class 1259 OID 17445)
-- Dependencies: 1930 5
-- Name: levenshtein; Type: TABLE; Schema: public; Owner: kyberia; Tablespace: 
--

CREATE TABLE levenshtein (
    lev_user_id integer,
    lev_node_id integer,
    lev_timestamp timestamp without time zone DEFAULT now()
);


ALTER TABLE public.levenshtein OWNER TO kyberia;

--
-- TOC entry 168 (class 1259 OID 17438)
-- Dependencies: 5
-- Name: log; Type: TABLE; Schema: public; Owner: kyberia; Tablespace: 
--

CREATE TABLE log (
    log_time timestamp without time zone,
    log_type_id integer,
    log_content text
);


ALTER TABLE public.log OWNER TO kyberia;

--
-- TOC entry 161 (class 1259 OID 17255)
-- Dependencies: 1896 1897 1898 1899 491 491 5
-- Name: mail; Type: TABLE; Schema: public; Owner: kyberia; Tablespace: 
--

CREATE TABLE mail (
    mail_id integer NOT NULL,
    mail_from integer DEFAULT 0 NOT NULL,
    mail_to integer DEFAULT 0 NOT NULL,
    mail_timestamp timestamp without time zone,
    mail_read menum DEFAULT 'no'::menum,
    mail_deleted menum DEFAULT 'no'::menum,
    mail_text text
);


ALTER TABLE public.mail OWNER TO kyberia;

--
-- TOC entry 165 (class 1259 OID 17304)
-- Dependencies: 1908 1909 1910 1911 1912 1913 1914 1915 5
-- Name: nodes; Type: TABLE; Schema: public; Owner: kyberia; Tablespace: 
--

CREATE TABLE nodes (
    node_id integer NOT NULL,
    node_template_id integer,
    node_parent integer DEFAULT 0 NOT NULL,
    node_creator integer DEFAULT 0 NOT NULL,
    node_external_access boolean DEFAULT false,
    node_created timestamp without time zone,
    node_lastchild_created timestamp without time zone DEFAULT now(),
    node_lastdescendant_created timestamp without time zone,
    node_updated timestamp without time zone,
    node_children_count integer DEFAULT 0,
    node_k integer DEFAULT 0,
    node_views integer,
    node_descendant_count integer,
    node_name character varying(256) DEFAULT NULL::character varying,
    node_external_link character varying(256) DEFAULT NULL::character varying,
    node_content text
);


ALTER TABLE public.nodes OWNER TO kyberia;

--
-- TOC entry 164 (class 1259 OID 17302)
-- Dependencies: 165 5
-- Name: nodes_node_id_seq; Type: SEQUENCE; Schema: public; Owner: kyberia
--

CREATE SEQUENCE nodes_node_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.nodes_node_id_seq OWNER TO kyberia;

--
-- TOC entry 1971 (class 0 OID 0)
-- Dependencies: 164
-- Name: nodes_node_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kyberia
--

ALTER SEQUENCE nodes_node_id_seq OWNED BY nodes.node_id;


--
-- TOC entry 162 (class 1259 OID 17275)
-- Dependencies: 1900 5
-- Name: relations_links; Type: TABLE; Schema: public; Owner: kyberia; Tablespace: 
--

CREATE TABLE relations_links (
    link_dst integer NOT NULL,
    link_src integer NOT NULL,
    link_creator integer DEFAULT 0 NOT NULL,
    link_created timestamp without time zone
);


ALTER TABLE public.relations_links OWNER TO kyberia;

--
-- TOC entry 163 (class 1259 OID 17295)
-- Dependencies: 1901 1902 1903 1904 1905 1906 5 501
-- Name: relations_users; Type: TABLE; Schema: public; Owner: kyberia; Tablespace: 
--

CREATE TABLE relations_users (
    rel_node_id integer DEFAULT 0 NOT NULL,
    rel_user_id integer DEFAULT 0 NOT NULL,
    rel_node_permission acc_enum,
    rel_last_visit timestamp without time zone,
    rel_visits integer DEFAULT 0,
    rel_given_k boolean DEFAULT false NOT NULL,
    rel_synapse_weight double precision DEFAULT 1 NOT NULL,
    rel_bookmarked boolean DEFAULT false NOT NULL
);


ALTER TABLE public.relations_users OWNER TO kyberia;

--
-- TOC entry 166 (class 1259 OID 17319)
-- Dependencies: 1916 5
-- Name: tiamat; Type: TABLE; Schema: public; Owner: kyberia; Tablespace: 
--

CREATE TABLE tiamat (
    tiamat_node_id integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.tiamat OWNER TO kyberia;

--
-- TOC entry 167 (class 1259 OID 17329)
-- Dependencies: 1917 1918 1919 1920 1921 1922 1923 1924 1925 1926 1927 1928 1929 5 511
-- Name: users; Type: TABLE; Schema: public; Owner: kyberia; Tablespace: 
--

CREATE TABLE users (
    user_id integer DEFAULT 0 NOT NULL,
    user_login character varying(256) DEFAULT NULL::character varying,
    user_xmpp character varying(256) DEFAULT NULL::character varying,
    user_password character varying(256) DEFAULT NULL::character varying,
    user_register_hash character varying(256) DEFAULT NULL::character varying,
    user_email character varying(256) DEFAULT NULL::character varying,
    user_gpg_prv text,
    user_gpg_pub text,
    user_last_action timestamp without time zone DEFAULT now() NOT NULL,
    user_action character varying(256) DEFAULT NULL::character varying,
    user_action_id integer,
    user_listing_amount integer DEFAULT 64,
    user_listing_order l_order DEFAULT 'desc'::l_order,
    user_def_header_id integer,
    user_mail_notify boolean DEFAULT false,
    user_acc_lockout timestamp without time zone,
    user_mood character varying(256) DEFAULT NULL::character varying,
    user_invisible boolean DEFAULT false,
    user_guild_id integer,
    user_ssl_certificate text
);


ALTER TABLE public.users OWNER TO kyberia;

--
-- TOC entry 1972 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN users.user_mood; Type: COMMENT; Schema: public; Owner: kyberia
--

COMMENT ON COLUMN users.user_mood IS 'nechat?';


--
-- TOC entry 1907 (class 2604 OID 17307)
-- Dependencies: 165 164 165
-- Name: node_id; Type: DEFAULT; Schema: public; Owner: kyberia
--

ALTER TABLE ONLY nodes ALTER COLUMN node_id SET DEFAULT nextval('nodes_node_id_seq'::regclass);


--
-- TOC entry 1962 (class 0 OID 17445)
-- Dependencies: 169 1963
-- Data for Name: levenshtein; Type: TABLE DATA; Schema: public; Owner: kyberia
--

COPY levenshtein (lev_user_id, lev_node_id, lev_timestamp) FROM stdin;
\.


--
-- TOC entry 1961 (class 0 OID 17438)
-- Dependencies: 168 1963
-- Data for Name: log; Type: TABLE DATA; Schema: public; Owner: kyberia
--

COPY log (log_time, log_type_id, log_content) FROM stdin;
\.


--
-- TOC entry 1954 (class 0 OID 17255)
-- Dependencies: 161 1963
-- Data for Name: mail; Type: TABLE DATA; Schema: public; Owner: kyberia
--

COPY mail (mail_id, mail_from, mail_to, mail_timestamp, mail_read, mail_deleted, mail_text) FROM stdin;
\.


--
-- TOC entry 1958 (class 0 OID 17304)
-- Dependencies: 165 1963
-- Data for Name: nodes; Type: TABLE DATA; Schema: public; Owner: kyberia
--

COPY nodes (node_id, node_template_id, node_parent, node_creator, node_external_access, node_created, node_lastchild_created, node_lastdescendant_created, node_updated, node_children_count, node_k, node_views, node_descendant_count, node_name, node_external_link, node_content) FROM stdin;
1	4	0	332	t	2013-08-19 00:22:26.488066	2013-08-19 00:22:26.488066	2013-08-19 00:22:26.488066	2013-08-19 00:22:26.488066	0	0	18	0	Main	\N	Toto je Main, pYco
\.


--
-- TOC entry 1973 (class 0 OID 0)
-- Dependencies: 164
-- Name: nodes_node_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kyberia
--

SELECT pg_catalog.setval('nodes_node_id_seq', 1, false);


--
-- TOC entry 1955 (class 0 OID 17275)
-- Dependencies: 162 1963
-- Data for Name: relations_links; Type: TABLE DATA; Schema: public; Owner: kyberia
--

COPY relations_links (link_dst, link_src, link_creator, link_created) FROM stdin;
\.


--
-- TOC entry 1956 (class 0 OID 17295)
-- Dependencies: 163 1963
-- Data for Name: relations_users; Type: TABLE DATA; Schema: public; Owner: kyberia
--

COPY relations_users (rel_node_id, rel_user_id, rel_node_permission, rel_last_visit, rel_visits, rel_given_k, rel_synapse_weight, rel_bookmarked) FROM stdin;
\.


--
-- TOC entry 1959 (class 0 OID 17319)
-- Dependencies: 166 1963
-- Data for Name: tiamat; Type: TABLE DATA; Schema: public; Owner: kyberia
--

COPY tiamat (tiamat_node_id) FROM stdin;
\.


--
-- TOC entry 1960 (class 0 OID 17329)
-- Dependencies: 167 1963
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: kyberia
--

COPY users (user_id, user_login, user_xmpp, user_password, user_register_hash, user_email, user_gpg_prv, user_gpg_pub, user_last_action, user_action, user_action_id, user_listing_amount, user_listing_order, user_def_header_id, user_mail_notify, user_acc_lockout, user_mood, user_invisible, user_guild_id, user_ssl_certificate) FROM stdin;
\.


--
-- TOC entry 1951 (class 2606 OID 17430)
-- Dependencies: 167 167 1964
-- Name: cons_id; Type: CONSTRAINT; Schema: public; Owner: kyberia; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT cons_id PRIMARY KEY (user_id);


--
-- TOC entry 1941 (class 2606 OID 17381)
-- Dependencies: 163 163 163 1964
-- Name: cons_user_node; Type: CONSTRAINT; Schema: public; Owner: kyberia; Tablespace: 
--

ALTER TABLE ONLY relations_users
    ADD CONSTRAINT cons_user_node PRIMARY KEY (rel_node_id, rel_user_id);


--
-- TOC entry 1935 (class 2606 OID 17355)
-- Dependencies: 161 161 1964
-- Name: mail_id; Type: CONSTRAINT; Schema: public; Owner: kyberia; Tablespace: 
--

ALTER TABLE ONLY mail
    ADD CONSTRAINT mail_id PRIMARY KEY (mail_id);


--
-- TOC entry 1949 (class 2606 OID 17353)
-- Dependencies: 165 165 1964
-- Name: node_id; Type: CONSTRAINT; Schema: public; Owner: kyberia; Tablespace: 
--

ALTER TABLE ONLY nodes
    ADD CONSTRAINT node_id PRIMARY KEY (node_id);


--
-- TOC entry 1939 (class 2606 OID 17379)
-- Dependencies: 162 162 162 162 1964
-- Name: prim; Type: CONSTRAINT; Schema: public; Owner: kyberia; Tablespace: 
--

ALTER TABLE ONLY relations_links
    ADD CONSTRAINT prim PRIMARY KEY (link_dst, link_src, link_creator);


--
-- TOC entry 1953 (class 1259 OID 17444)
-- Dependencies: 168 1964
-- Name: index_log_id; Type: INDEX; Schema: public; Owner: kyberia; Tablespace: 
--

CREATE INDEX index_log_id ON log USING btree (log_type_id);


--
-- TOC entry 1931 (class 1259 OID 17372)
-- Dependencies: 161 161 1964
-- Name: index_mail_form_to; Type: INDEX; Schema: public; Owner: kyberia; Tablespace: 
--

CREATE INDEX index_mail_form_to ON mail USING btree (mail_from, mail_to);


--
-- TOC entry 1932 (class 1259 OID 17371)
-- Dependencies: 161 1964
-- Name: index_mail_mail_id; Type: INDEX; Schema: public; Owner: kyberia; Tablespace: 
--

CREATE INDEX index_mail_mail_id ON mail USING btree (mail_id);


--
-- TOC entry 1933 (class 1259 OID 17373)
-- Dependencies: 161 161 1964
-- Name: index_mail_to_read; Type: INDEX; Schema: public; Owner: kyberia; Tablespace: 
--

CREATE INDEX index_mail_to_read ON mail USING btree (mail_to, mail_read);


--
-- TOC entry 1936 (class 1259 OID 17369)
-- Dependencies: 162 162 1964
-- Name: index_neurons_dst_src; Type: INDEX; Schema: public; Owner: kyberia; Tablespace: 
--

CREATE INDEX index_neurons_dst_src ON relations_links USING btree (link_dst, link_src);


--
-- TOC entry 1937 (class 1259 OID 17370)
-- Dependencies: 162 1964
-- Name: index_neurons_src; Type: INDEX; Schema: public; Owner: kyberia; Tablespace: 
--

CREATE INDEX index_neurons_src ON relations_links USING btree (link_src);


--
-- TOC entry 1943 (class 1259 OID 17363)
-- Dependencies: 165 1964
-- Name: index_node_creator; Type: INDEX; Schema: public; Owner: kyberia; Tablespace: 
--

CREATE INDEX index_node_creator ON nodes USING btree (node_creator);


--
-- TOC entry 1944 (class 1259 OID 17463)
-- Dependencies: 165 1964
-- Name: index_node_external_link; Type: INDEX; Schema: public; Owner: kyberia; Tablespace: 
--

CREATE INDEX index_node_external_link ON nodes USING btree (node_external_link);


--
-- TOC entry 1945 (class 1259 OID 17360)
-- Dependencies: 165 1964
-- Name: index_node_id; Type: INDEX; Schema: public; Owner: kyberia; Tablespace: 
--

CREATE INDEX index_node_id ON nodes USING btree (node_id);


--
-- TOC entry 1942 (class 1259 OID 17365)
-- Dependencies: 163 163 1964
-- Name: index_node_id_user_id; Type: INDEX; Schema: public; Owner: kyberia; Tablespace: 
--

CREATE INDEX index_node_id_user_id ON relations_users USING btree (rel_node_id, rel_user_id);


--
-- TOC entry 1946 (class 1259 OID 17449)
-- Dependencies: 165 1964
-- Name: index_node_name; Type: INDEX; Schema: public; Owner: kyberia; Tablespace: 
--

CREATE INDEX index_node_name ON nodes USING btree (node_name);


--
-- TOC entry 1947 (class 1259 OID 17362)
-- Dependencies: 165 1964
-- Name: index_node_parrent; Type: INDEX; Schema: public; Owner: kyberia; Tablespace: 
--

CREATE INDEX index_node_parrent ON nodes USING btree (node_parent);


--
-- TOC entry 1952 (class 1259 OID 17383)
-- Dependencies: 167 1964
-- Name: index_users_login; Type: INDEX; Schema: public; Owner: kyberia; Tablespace: 
--

CREATE INDEX index_users_login ON users USING btree (user_login);


--
-- TOC entry 1969 (class 0 OID 0)
-- Dependencies: 5
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2013-08-25 22:27:39 CEST

--
-- PostgreSQL database dump complete
--

