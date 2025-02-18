/*********************************************************************************/
/* Schema                                                                        */
/*********************************************************************************/
CREATE SCHEMA rdbmsdiff;

SET search_path = rdbmsdiff;

CREATE TABLE t_means_of_transport (
    uuid VARCHAR(36) NOT NULL,
    identifier VARCHAR(20) NOT NULL,
    CONSTRAINT t_means_of_transport_pk PRIMARY KEY(uuid),
    CONSTRAINT t_means_of_transport_identifier UNIQUE(identifier)
);

CREATE TABLE t_stations (
    uuid VARCHAR(36) NOT NULL,
    name VARCHAR(50) NOT NULL,
    CONSTRAINT t_stations_pk PRIMARY KEY(uuid),
    CONSTRAINT t_stations_name UNIQUE(name)
);

CREATE TABLE t_lines (
    uuid VARCHAR(36) NOT NULL,
    label VARCHAR(5) NOT NULL,
    means_of_transport_uuid VARCHAR(36) NOT NULL,
    terminal_stop_one_uuid VARCHAR(36) NOT NULL,
	terminal_stop_two_uuid VARCHAR(36) NOT NULL,
    CONSTRAINT t_lines_pk PRIMARY KEY(uuid),
	CONSTRAINT t_lines_label UNIQUE(label),
    CONSTRAINT means_of_transport_fk FOREIGN KEY (means_of_transport_uuid) REFERENCES t_means_of_transport(uuid),
    CONSTRAINT distinct_terminal_stops_check CHECK (terminal_stop_one_uuid <> terminal_stop_two_uuid),
	CONSTRAINT terminal_stop_one_fk FOREIGN KEY (terminal_stop_one_uuid) REFERENCES t_stations(uuid),
	CONSTRAINT terminal_stop_two_fk FOREIGN KEY (terminal_stop_two_uuid) REFERENCES t_stations(uuid)
);

CREATE TABLE t_edges (
    uuid VARCHAR(36) NOT NULL,
    start_station_uuid VARCHAR(36) NOT NULL,
    end_station_uuid VARCHAR(36) NOT NULL,
    line_uuid VARCHAR(36) NOT NULL,
    distance_min INTEGER NOT NULL,
    CONSTRAINT t_edges_pk PRIMARY KEY(uuid),
    CONSTRAINT line_fk FOREIGN KEY (line_uuid) REFERENCES t_lines(uuid) ON DELETE CASCADE,
    CONSTRAINT distance_min_check CHECK (distance_min > 0),
    CONSTRAINT start_station_fk FOREIGN KEY (start_station_uuid) REFERENCES t_stations(uuid),
    CONSTRAINT end_station_fk FOREIGN KEY (end_station_uuid) REFERENCES t_stations(uuid),
    CONSTRAINT distinct_stations_check CHECK (start_station_uuid <> end_station_uuid),
    CONSTRAINT edge_uk UNIQUE(start_station_uuid, end_station_uuid, line_uuid)
);

CREATE SEQUENCE s_dummy_1 INCREMENT BY 1 NO MAXVALUE START WITH 1 NO CYCLE;

CREATE SEQUENCE s_dummy_2 INCREMENT BY 1 NO MAXVALUE START WITH 1 NO CYCLE;

CREATE SEQUENCE s_dummy_3 INCREMENT BY 1 NO MAXVALUE START WITH 1 NO CYCLE;

CREATE SEQUENCE s_dummy_4 INCREMENT BY 1 NO MAXVALUE START WITH 1 NO CYCLE;

CREATE SEQUENCE s_dummy_5 INCREMENT BY 1 NO MAXVALUE START WITH 1 NO CYCLE;

CREATE VIEW v_lines AS
SELECT l.label as line, m.identifier as identifier, s1.name as terminal_stop_one, s2.name as terminal_stop_two FROM t_lines l
INNER JOIN t_means_of_transport m ON m.uuid = l.means_of_transport_uuid
INNER JOIN t_stations s1 ON s1.uuid = l.terminal_stop_one_uuid
INNER JOIN t_stations s2 ON s2.uuid = l.terminal_stop_two_uuid;

CREATE VIEW v_edges AS
SELECT l.label as line, s1.name as start_station, s2.name as end_station, e.distance_min as distance_min from t_edges e
INNER JOIN t_lines l ON l.uuid = e.line_uuid
INNER JOIN t_stations s1 ON s1.uuid = e.start_station_uuid
INNER JOIN t_stations s2 ON s2.uuid = e.end_station_uuid;

CREATE MATERIALIZED VIEW mv_lines AS
SELECT l.label as line, m.identifier as identifier, s1.name as terminal_stop_one, s2.name as terminal_stop_two FROM t_lines l
INNER JOIN t_means_of_transport m ON m.uuid = l.means_of_transport_uuid
INNER JOIN t_stations s1 ON s1.uuid = l.terminal_stop_one_uuid
INNER JOIN t_stations s2 ON s2.uuid = l.terminal_stop_two_uuid;

CREATE MATERIALIZED VIEW mv_edges AS
SELECT l.label as line, s1.name as start_station, s2.name as end_station, e.distance_min as distance_min from t_edges e
INNER JOIN t_lines l ON l.uuid = e.line_uuid
INNER JOIN t_stations s1 ON s1.uuid = e.start_station_uuid
INNER JOIN t_stations s2 ON s2.uuid = e.end_station_uuid;


/*********************************************************************************/
/* Data                                                                          */
/*********************************************************************************/
INSERT INTO t_means_of_transport (uuid,identifier) VALUES
	 ('1b76ce45-160e-4134-bd2f-fe1876792108','U-Bahn'),
	 ('d2874bdc-5f5f-49ab-b1c6-ecba746de906','S-Bahn'),
	 ('ab1db4b0-1a7a-4466-9419-17fccbdb3262','Tram'),
	 ('86c084a2-a9a5-48b4-9089-8c60be861427','Bus');



INSERT INTO t_stations (uuid,"name") VALUES
	 ('14773ee9-0e3c-4285-b4e1-94db57591d11','Oberlaa'),
	 ('3b559df8-87b9-42f8-ac64-0ac68ee0fab6','Neulaa'),
	 ('768effc3-d589-4340-a0e7-a9f623bffb55','Alaudagasse'),
	 ('f321a2ba-1264-4a95-8591-b8fbc4b4a2e9','Altes Landgut'),
	 ('706753aa-61f6-4dfd-96c5-9b9d98cc7c55','Troststrasse'),
	 ('934ef3af-56e6-4b38-a35c-07899c544619','Reumannplatz'),
	 ('d64eb07b-d3a8-4b3e-a694-95b84c5c10c3','Keplerplatz'),
	 ('d3ac5f66-6c17-4f55-a353-4e7a65a713c2','Suedtiroler Pl. - Hbf.'),
	 ('3db82493-778d-45ae-8f82-8e8041df60c5','Taubstummengasse'),
	 ('162818a5-8c0a-4378-81aa-c37426076e47','Karlsplatz');

INSERT INTO t_stations (uuid,"name") VALUES
	 ('b644c429-85e7-4df7-93ab-c6df884b2e3c','Stephansplatz'),
	 ('4f35b01f-fab9-46cd-8d05-7d371e559374','Schwedenplatz'),
	 ('b86d9573-e0b8-495f-9b73-612c6349ce82','Nestroyplatz'),
	 ('88e2fb0f-4066-4971-9e8b-a6b243c91b15','Praterstern'),
	 ('a2fd8164-e6d7-4156-82d9-3b4de08af562','Vorgartenstrasse'),
	 ('cf16ab0e-45c4-48d8-9284-32d21db03cd7','Donauinsel'),
	 ('055e096b-4c15-47ab-b9a4-dadec74b6d80','Kaisermuehlen-VIC'),
	 ('59d471c3-6d19-459a-a3da-d6e234ec0a43','Alte Donau'),
	 ('303b9732-4a0e-4e2c-8a5f-f809c4316b51','Kagran'),
	 ('47ac3706-27f3-4904-8ce7-afbe3edc3c74','Kagraner Platz');

INSERT INTO t_stations (uuid,"name") VALUES
	 ('1a7ab370-2650-4726-b231-a4d82a7223ce','Rennbahnweg'),
	 ('8a5f3f58-32fc-4ee4-b341-a1ade7bed711','Aderklaaer Strasse'),
	 ('8eb6979a-9a14-4799-9cbc-6a9953b3720d','Grossfeldsiedlung'),
	 ('518c4e51-c4ff-4bff-b96d-bec8d0957829','Leopoldau'),
	 ('4ac249f8-84b2-4de5-8693-61c384ac9a8f','Seestadt'),
	 ('94d259ef-3803-4280-921f-85c7c34e2785','Aspern Nord'),
	 ('b3827d25-c051-4a9b-94b7-f2dfb882f53d','Hausfeldstrasse'),
	 ('1f9d37c9-6d39-4002-ac8e-56065e4c1afc','Aspernstrasse'),
	 ('0b940c62-cda8-4e97-835d-9acd7ac402c2','Donauspital'),
	 ('f4404ca9-8cd4-40eb-847e-752229ee3956','Hardeggasse');

INSERT INTO t_stations (uuid,"name") VALUES
	 ('1349aeb1-9bcf-4687-a73a-2bceb5c5d770','Stadlau'),
	 ('1875ea70-83e4-44bf-8dad-e13b3896ef16','Donaustadtbruecke'),
	 ('c010ab9c-5868-408e-a61f-1fc31cc1848f','Donaumarina'),
	 ('e4360913-4762-498c-9b14-28c38032a8ec','Stadion'),
	 ('1ba82453-b22d-4382-8fa1-7d8366b6268c','Krieau'),
	 ('1fde5aeb-2ed4-48d4-a070-0eb8226bd4ca','Messe-Prater'),
	 ('263d8c1b-6925-476a-b481-36b498a8ad2a','Taborstrasse'),
	 ('e5635ac1-7dec-4434-a53a-ce6d3e722f73','Schottenring'),
	 ('797e5f26-d606-4373-815c-20c976256bd3','Schottentor'),
	 ('8b55c891-a33c-49f2-8ab0-0d0112f6f44f','Rathaus');

INSERT INTO t_stations (uuid,"name") VALUES
	 ('81872694-6819-4f28-8b99-aaf7996cdd42','Volkstheater'),
	 ('58808c21-802c-4e0f-bb2e-9cd37fd7ef37','Museumsquartier'),
	 ('22b98b73-3a3e-438b-9544-29ed32a718d5','Ottakring'),
	 ('bf1a4505-b564-4c7a-a2b1-e82c21cc3183','Kendlerstrasse'),
	 ('572996f5-6478-4c2e-9638-ca32fa754e70','Huetteldorfer Strasse'),
	 ('1b645f6e-6f73-42d9-a111-03c343612049','Johnstrasse'),
	 ('96db6419-1b87-4c0e-8184-3db4e78ad226','Schweglerstrasse'),
	 ('d535e27e-12a0-4986-b7f4-2c76007c2d97','Westbahnhof'),
	 ('6214d028-726b-40d6-9711-c40e6745e5f9','Zieglergasse'),
	 ('0e2f4451-6ead-4364-ac57-b247bc787e96','Neubaugasse');

INSERT INTO t_stations (uuid,"name") VALUES
	 ('608e19cc-c7c5-4dfc-b8f7-f4b515179a03','Herrengasse'),
	 ('d4e37c52-5a8f-4766-993b-a9a0a1a9976b','Stubentor'),
	 ('650ac789-b6b5-4d5b-aeb0-cc9629cf42fb','Landstrasse'),
	 ('71283ebe-a4fc-43c7-897e-23be923eca83','Rochusgasse'),
	 ('6a7f680d-8fba-4e7d-a842-7ea8175bc6a7','Kardinal-Nagl-Platz'),
	 ('57033cae-db98-4545-8cc0-74d62a8ad3e4','Schlachthausgasse'),
	 ('ceb39674-107d-425f-8feb-5e1eb08d43a8','Erdberg'),
	 ('6b6be3f3-9e27-43e7-b6d4-519d297e0d6c','Gasometer'),
	 ('926ff310-2fa6-43f0-a9f3-199a1370833d','Zippererstrasse'),
	 ('9b879336-c0c4-4d32-9afd-753a5f60ccca','Enkplatz');

INSERT INTO t_stations (uuid,"name") VALUES
	 ('729133a1-7671-48ef-a70b-45ca77075933','Simmering'),
	 ('05e45d5b-beb5-4ceb-a43f-2e4068a32914','Heiligenstadt'),
	 ('f57c6300-581e-46e7-9fe5-dbb42a462aec','Spittelau'),
	 ('34607a50-8813-4793-a8c5-5426e5d7ea50','Friedensbruecke'),
	 ('14298d60-5fd4-4587-a40e-1681801fd06a','Rossauer Laende'),
	 ('f9c1c167-d4b4-46e7-9d2a-b111504a13b6','Stadtpark'),
	 ('ad7cc231-9a35-4b3f-a176-673fe96c9cda','Kettenbrueckengasse'),
	 ('ceb59cbc-f40e-43a4-b5bf-75dacb06edc8','Pilgramgasse'),
	 ('6ddfd002-b55d-4686-92f3-bf02baf32927','Margaretenguertel'),
	 ('79d75cae-e513-4d91-935d-c2888886bbeb','Laengenfeldgasse');

INSERT INTO t_stations (uuid,"name") VALUES
	 ('444c59f0-a197-44d3-a83b-84a829f370fe','Meidling Hauptstrasse'),
	 ('097f8a83-5ec5-4456-8101-781bd18cceba','Schoenbrunn'),
	 ('9ad78501-3253-4c5b-9a7c-5f7f619f6dd7','Hietzing'),
	 ('823df5e4-61be-40dd-a71a-d099067540bd','Braunschweiggasse'),
	 ('39fec395-e62d-4bdb-b75f-de9b2c3d3024','Unter St. Veit'),
	 ('2c23949f-9a60-48c1-9367-a1b80206b09e','Ober St. Veit'),
	 ('17d89c74-90fa-4a71-b6e7-754c8f119837','Huetteldorf'),
	 ('78a12cb5-a4a0-442c-888e-ffb7dd71db5f','Siebenhirten'),
	 ('3bb326bd-f45c-4139-bd81-be78f1592c0f','Perfektastrasse'),
	 ('870cfa60-a506-473b-b578-b5349812bc89','Erlaaer Strasse');

INSERT INTO t_stations (uuid,"name") VALUES
	 ('9bc3fbd3-4875-4b28-8acb-733f4d3e358e','Alterlaa'),
	 ('f9c8e55b-25cb-4f30-bd3e-3657bfe7d8a1','Am Schoepfwerk'),
	 ('263d8e52-8d76-4db8-bbb6-18928baefada','Tscherttegasse'),
	 ('b5784e61-d318-4d65-83ad-f3be2b58a8fd','Meidling'),
	 ('2585eada-c145-42e2-8e82-63b0c4f0f321','Niederhofstrasse'),
	 ('bf331bb7-00d4-4ec7-8765-c5286b0c12ce','Gumpendorfer Strasse'),
	 ('e8c9d9c6-471e-4371-b8b6-ab97f0b00bd7','Burggasse-Stadthalle'),
	 ('396a78a8-9374-4219-b803-179f4e7c73ac','Thaliastrasse'),
	 ('fd939834-4817-4a74-a067-f0ce92c66d4b','Josefstaedter Strasse'),
	 ('d4463c35-ef6c-4d36-b043-e40f5675a932','Alser Strasse');

INSERT INTO t_stations (uuid,"name") VALUES
	 ('6b89a6e7-642c-492b-a1a8-6ee7e26372a4','Michelbeuern-AKH'),
	 ('276040f5-c6d9-4493-adb5-094395cd0afb','Waehringer Strasse-Volksoper'),
	 ('c5dcfbd1-6c15-4a75-8506-a187513abd5b','Nussdorfer Strasse'),
	 ('679cb32d-9ea0-4370-b6be-ce788665eaed','Jaegerstrasse'),
	 ('e1319b9e-1b71-4747-8c19-f5523b4bce0b','Dresdner Strasse'),
	 ('1200ed45-5bb1-4ff1-bee8-a81c919ce76e','Handelskai'),
	 ('6541b1a4-dffb-4981-8340-fab6c4aa1cea','Neue Donau'),
	 ('f65f522d-fb87-4990-9484-ae4c328935f0','Floridsdorf'),
	 ('5fd3776d-c2c7-49f4-baf6-00e1293c1816','Matzleinsdorfer Platz'),
	 ('60a13dd9-e542-45d3-bc80-5cce51f34a10','Hauptbahnhof');

INSERT INTO t_stations (uuid,"name") VALUES
	 ('7f0267ab-015b-43c0-aab5-b0a5457f9ea5','Quartier Belvedere'),
	 ('6727a5b9-1b41-4754-997e-e8b7bfa9c781','Rennweg'),
	 ('473f5432-69f5-4b99-b48a-9f3a486cf886','Traisengasse'),
	 ('bd6620ec-e38d-4e97-bfd1-e252fcd34917','Siemensstrasse'),
	 ('372d17a9-e164-46cc-bfc9-8d9529dfba48','Suessenbrunn'),
	 ('050d3e18-51eb-4cc9-ae19-225ab18b9141','Oberdoebling'),
	 ('94f12de9-f9b3-4e32-ba0d-fefb513b4d50','Krottenbachstrasse'),
	 ('6b878017-9ab9-43ba-9dc5-ef050907867e','Gersthof'),
	 ('29e31449-8c9f-4978-9c96-7e8fbba07063','Hernals'),
	 ('a8b4ab3b-2b14-450f-a9c4-2c0bb363aa55','Breitensee');

INSERT INTO t_stations (uuid,"name") VALUES
	 ('5b1689a7-ee26-4901-9077-404aeb0dcf4b','Penzing'),
	 ('646c2e02-0f1c-47a2-a3d3-32dcb3236a21','Nordbahnstrasse'),
	 ('523cf481-beab-4390-b6aa-88071466a00b','Am Tabor'),
	 ('d1bc19f9-22a0-46e0-80c3-2d3562b532a9','Nordwestbahnstrasse'),
	 ('377aca77-3a86-4db3-8ac9-8edfba29ac1b','Rauscherstrasse'),
	 ('d4ad7f12-2271-4048-81ce-eb1af4bf3499','Wallensteinplatz'),
	 ('0053bfee-a344-43f9-98c5-ec9ed73eb4cc','Klosterneuburger Strasse/Wallensteinstrasse'),
	 ('46258255-e192-4c87-944c-278678ec408a','Franz-Josefs-Bahnhof'),
	 ('d827f72a-5fe0-46c3-8280-c84934e6c057','Nussdorfer Strasse/Alserbachstrasse'),
	 ('7a3233ec-51a0-4983-ba04-512fcd5c2123','Spitalgasse');

INSERT INTO t_stations (uuid,"name") VALUES
	 ('057990ab-37ad-4292-8de7-dffb2ee9f0b7','Lazarettgasse'),
	 ('ee88bbde-3cb5-4d96-8b2c-6d6eb36b037b','Lange Gasse'),
	 ('785209f7-0817-4fbe-93fc-44e4a2c7e0ab','Laudongasse'),
	 ('f352e06b-e1fe-45e8-81f6-5aef1dc26bfe','Florianigasse'),
	 ('485d5ec3-1c57-45bf-b010-1141c327c390','Albertgasse'),
	 ('deb8f5fd-561e-41ff-bbb6-458468899edf','Blindengasse'),
	 ('c6a60c79-7602-46cf-8f1b-48f256def58b','Lerchenfelder Strasse'),
	 ('e852a593-0f96-4c8b-bfaf-b0a2e29db291','Kaiserstrasse/Neustiftgasse'),
	 ('9f42d846-9a87-459d-8957-6429ec0802e7','Burggasse/Kaiserstrasse'),
	 ('6232f274-5db6-4652-b3f4-7e83c24aa110','Westbahnstrasse/Kaiserstrasse');

INSERT INTO t_stations (uuid,"name") VALUES
	 ('b6176390-b2f1-4532-841a-fee43355da3e','Stollgasse'),
	 ('8fba4771-98d8-46f6-ae3b-3ab0de7bd461','Urban Loritz Platz'),
	 ('c1f4ef91-eb61-4d4c-9687-84c080196db4','Mariahilfer-Guertel'),
	 ('37bb3630-6298-4ccd-9ae2-d072692c0b05','Arbeitergasse, Guertel'),
	 ('bff2d85e-e32d-4e10-b4f3-9940984a64b4','Eichenstrasse'),
	 ('1d429c8a-2006-403b-a458-710b698eaad4','Kliebergasse'),
	 ('5925c993-f22d-420c-8cc4-c133575ddc4c','Blechturmgasse'),
	 ('2181686c-3203-4dd6-8bf6-68db7d843299','Fassangasse'),
	 ('038491ec-c394-46d2-ba00-04ed66faa19b','Heinrich Drimmel Platz'),
	 ('34e1c12f-7320-43cc-a3bf-215ca340c7db','Wildgansplatz');

INSERT INTO t_stations (uuid,"name") VALUES
	 ('a9a77531-7b36-4a60-995c-2f9117881886','St. Marx'),
	 ('26b16271-eb27-4f12-83bd-f3ed88086d0b','Viehmarktgasse'),
	 ('e3cfbf49-c82f-463b-ada8-69c73b74d2fc','Baumgasse'),
	 ('f31249f5-6f89-47b8-87cb-b30311111415','Floridsdorfer Markt'),
	 ('841b13f7-7fb8-458b-b2e5-61ba8d0f4974','Bahnsteggasse'),
	 ('8b8bcab1-b0e5-41d4-9664-abce3569ed72','Bruenner Strasse'),
	 ('3d8a392d-1753-43cd-8cbb-88df88cc672d','Shuttleworthstrasse'),
	 ('7b66ad8a-0439-4bd2-868e-4bb3b681e601','Grossjedlersdorf'),
	 ('30f02a4b-5226-4144-a1a0-e5ede71f5e94','Carabelligasse'),
	 ('02c61bb5-790a-4b22-8441-81f263da46ce','Bruenner Str., Hanreitergasse');

INSERT INTO t_stations (uuid,"name") VALUES
	 ('c1d68a72-4e30-4229-a7de-02b59ac62e93','Empergergasse'),
	 ('cd6bd876-55d9-4786-9624-c79e2d6ad1e5','Anton-Schall-Gasse'),
	 ('171b1612-44fc-4281-aa3a-1d79bf54d372','Van-Swieten-Kaserne'),
	 ('6b319827-1b27-4b96-8ef5-9c0085c2a307','Stammersdorf'),
	 ('30da0add-411e-4a5f-92b8-ff73fcb94f8a','Salztorbruecke'),
	 ('566e6cb8-0da5-4c1a-b824-ca1240aa5ce5','Rudolfsplatz'),
	 ('95f2d11e-67e9-45e7-b2e8-42435f449681','Tiefer Graben'),
	 ('65b78460-f765-472f-b591-69bd502a1113','Renngasse'),
	 ('fa750848-07f3-4b97-bd45-6184d3a13e64','Michaelerplatz'),
	 ('30b92e74-a659-4291-a8f2-910ff2b3d951','Albertinaplatz');

INSERT INTO t_stations (uuid,"name") VALUES
	 ('cbe8ca6e-a6d6-472a-a8cb-db2e5456f7b8','Kaerntner Strasse'),
	 ('ca23d21f-3ee0-4201-91de-826188d8b8f0','Schwarzenbergplatz'),
	 ('d05aced6-375f-4614-af6e-5d408bc96583','Haschkagasse'),
	 ('3bb0f2a6-0334-471a-bdc9-b0e72aecae4a','Ruckergasse'),
	 ('a414fec6-23bc-432f-8031-89eedcc914c1','Hohenbergstrasse'),
	 ('f81e0725-870f-406a-85ee-f1bca23882f1','Bhf. Meidling, Schedifkaplatz'),
	 ('8bb24d47-187e-497c-b3e4-c3a1e15ef808','Wienerbergbruecke'),
	 ('a002f828-5be2-4b1e-af63-bab2cea6c562','Am Europlatz'),
	 ('fe787a27-ffc6-4cc5-a3e5-d56fd72fc55f','Eibesbrunnergasse'),
	 ('d5b15ea3-ac10-4ba2-8ba5-8961ddc62de4','Gesundheitszentrum Sued');

INSERT INTO t_stations (uuid,"name") VALUES
	 ('346534ce-dc78-4f58-8d66-149f6b063710','Unfallkrankenhaus Meidling'),
	 ('99def398-a73e-4aed-9f8c-638e2f248713','Klinik Favoriten'),
	 ('51c56a63-1921-4f74-bd08-b966c7787e2b','Martin Luther-King Park'),
	 ('5d9ea08c-e283-4879-b470-f1c2f4122e77','Davidgasse, Knoellgasse'),
	 ('18052527-361f-4cca-b362-7a8df241a2f0','Belgradplatz'),
	 ('10f7503b-b316-485d-8cf7-ae77c4ea7e45','Inzersdf. Str., Bernhardtstalgasse'),
	 ('4aa72c1a-ca6d-439d-84b9-f9e77a514204','Herzgasse'),
	 ('f014be7a-5ea3-4dc2-b811-40654f9b4cca','Arthaberplatz'),
	 ('5a428763-7750-4870-b4a1-ed65c9828644','Leibnizgasse'),
	 ('c39b0389-924a-4889-902f-025d98af6bf7','Antonsplatz');

INSERT INTO t_stations (uuid,"name") VALUES
	 ('43c19e64-8601-47c8-ad5f-e41ea55d7e11','Saarplatz'),
	 ('ee59ade3-92f9-4437-a877-d18113b1240a','Silbergasse'),
	 ('7149f634-eefc-4f9d-bca7-135a0af923a4','Gatterburggasse'),
	 ('36cf8da1-08d7-4845-bc7a-ed44f573d374','Chimanistrasse'),
	 ('508d5777-657a-4d5a-a079-91e430b0f233','Daenenstrasse'),
	 ('126e2610-ef7e-41fb-b2fb-f8646b924b5d','Tuerkenschanzplatz'),
	 ('ff94f41b-0db1-4fa9-9d91-82c3e67c3d71','Czartoryskigasse'),
	 ('df60d5c4-d8b4-4ea1-9f2a-67b0919976b9','Richthausenstrasse'),
	 ('fefb0f6c-a574-49af-9bca-75fb7f5eeb58','Hernals, Wattgasse'),
	 ('51059895-e669-48f2-81b4-f827c0d5ec2b','Albrechtskreithgasse');

INSERT INTO t_stations (uuid,"name") VALUES
	 ('62de3e83-836e-413d-99e1-dc33fb72f189','Wilhelminenstrasse'),
	 ('ba8b813e-3749-4984-8ebd-f0ad55d1163d','Familienplatz'),
	 ('2951e378-f7da-4ac8-a805-95c8eca4dbda','Schuhmeierplatz'),
	 ('c2763e49-c770-4f20-9fb9-c80ab261ea24','Possingergasse'),
	 ('3dd7e4c3-a29c-4f4f-be1b-4871a8b73a17','Gablenzgasse'),
	 ('c6879e9e-853a-460c-9678-38278fc9c7ff','Auf der Schmelz'),
	 ('7ce2ba20-638d-4881-97de-73d59d70ce41','Schuselkagasse'),
	 ('a4c01bae-8623-4a72-80e3-909463351f3d','Maerzstraße'),
	 ('2a150aec-bcd3-411e-9189-8f26881374e8','Linzer Strasse'),
	 ('53c2768b-4fd0-4d52-8f33-7711bbeb92e6','Schloss Schoenbrunn');

INSERT INTO t_stations (uuid,"name") VALUES
	 ('4ec4d6ab-3662-4b3b-a2b6-3d01e44cc784','Rotenmuehlgasse'),
	 ('13c5ff88-898e-44c6-9e49-47fda0197850','Kagraner Friedhof'),
	 ('8406fc1d-6900-4267-9c40-96560ad36875','Anton-Sattler-Gasse'),
	 ('c8106963-279b-4071-bd5a-c779683c3cf7','Jueptnergasse'),
	 ('2f1f24bb-5852-4e37-8f4d-19ee67cd8e36','Zehdengasse'),
	 ('4e5564f3-a05f-498e-84ab-835abc7919f8','Leopoldauer Strasse'),
	 ('1b6a08df-08f9-43fa-9044-acfa8869930a','Sorgenthalgasse'),
	 ('92aa7f8d-315f-4e9a-9ece-3397c1d52565','Heinrich-von-Buol-Gasse'),
	 ('e5fd7e37-3ce4-47d0-aa10-92b42d971e90','Franz-Sebek-Strasse'),
	 ('1b3c1105-d6c3-46ba-9654-0fc9f0412963','Ruthnergasse');

INSERT INTO t_stations (uuid,"name") VALUES
	 ('0ed27aba-5409-48a0-b9c9-c4687b48fe84','Skraupstrasse'),
	 ('964f4ab2-8dcf-40ef-85b3-0818289a86cf','Berzeliusgasse'),
	 ('eed95b18-acbd-4900-9e5b-23b43bbc454c','Haspingerplatz'),
	 ('368bf51e-bd0a-4320-b731-01a62a089450','Grossjedlersdorf, Jochbergengasse');



INSERT INTO t_lines (uuid,"label",means_of_transport_uuid,terminal_stop_one_uuid,terminal_stop_two_uuid) VALUES
	 ('a237f557-b4df-492b-965e-ec632ef4fa4b','U1','1b76ce45-160e-4134-bd2f-fe1876792108','14773ee9-0e3c-4285-b4e1-94db57591d11','518c4e51-c4ff-4bff-b96d-bec8d0957829'),
	 ('54dde729-6ee3-473a-838d-56a87df04fa3','U2','1b76ce45-160e-4134-bd2f-fe1876792108','4ac249f8-84b2-4de5-8693-61c384ac9a8f','162818a5-8c0a-4378-81aa-c37426076e47'),
	 ('b32191f3-8c52-40a4-b464-b2f215f15c82','U3','1b76ce45-160e-4134-bd2f-fe1876792108','22b98b73-3a3e-438b-9544-29ed32a718d5','729133a1-7671-48ef-a70b-45ca77075933'),
	 ('c61d57cf-def1-4574-aa10-05b463d166b5','U4','1b76ce45-160e-4134-bd2f-fe1876792108','05e45d5b-beb5-4ceb-a43f-2e4068a32914','17d89c74-90fa-4a71-b6e7-754c8f119837'),
	 ('c5a310e3-9810-48af-9d38-1093bcea453a','U6','1b76ce45-160e-4134-bd2f-fe1876792108','78a12cb5-a4a0-442c-888e-ffb7dd71db5f','f65f522d-fb87-4990-9484-ae4c328935f0'),
	 ('26fd0f86-ab19-4c9c-8b1a-c63485dc11ac','S1','d2874bdc-5f5f-49ab-b1c6-ecba746de906','b5784e61-d318-4d65-83ad-f3be2b58a8fd','372d17a9-e164-46cc-bfc9-8d9529dfba48'),
	 ('c0abfff2-2bf5-40fc-88b6-631a92f91c1f','S45','d2874bdc-5f5f-49ab-b1c6-ecba746de906','1200ed45-5bb1-4ff1-bee8-a81c919ce76e','17d89c74-90fa-4a71-b6e7-754c8f119837'),
	 ('f93fc46f-97d0-4f2d-8557-05ca9ba4992a','5','ab1db4b0-1a7a-4466-9419-17fccbdb3262','88e2fb0f-4066-4971-9e8b-a6b243c91b15','d535e27e-12a0-4986-b7f4-2c76007c2d97'),
	 ('24d135a5-9f98-494c-8cc0-6970ef7943e2','18','ab1db4b0-1a7a-4466-9419-17fccbdb3262','e8c9d9c6-471e-4371-b8b6-ab97f0b00bd7','57033cae-db98-4545-8cc0-74d62a8ad3e4'),
	 ('9fc734ba-bf6d-40cf-b7f8-aa68d68328e7','30','ab1db4b0-1a7a-4466-9419-17fccbdb3262','f65f522d-fb87-4990-9484-ae4c328935f0','6b319827-1b27-4b96-8ef5-9c0085c2a307');

INSERT INTO t_lines (uuid,"label",means_of_transport_uuid,terminal_stop_one_uuid,terminal_stop_two_uuid) VALUES
	 ('41e0db4f-6115-439d-ba57-d3d948467790','2A','86c084a2-a9a5-48b4-9089-8c60be861427','4f35b01f-fab9-46cd-8d05-7d371e559374','ca23d21f-3ee0-4201-91de-826188d8b8f0'),
	 ('8e2f2b36-9cdc-4080-b89b-e4a8072e47c6','7A','86c084a2-a9a5-48b4-9089-8c60be861427','444c59f0-a197-44d3-a83b-84a829f370fe','934ef3af-56e6-4b38-a35c-07899c544619'),
	 ('221ec64b-f9d0-4ccc-a8b4-342571240a49','10A','86c084a2-a9a5-48b4-9089-8c60be861427','43c19e64-8601-47c8-ad5f-e41ea55d7e11','2585eada-c145-42e2-8e82-63b0c4f0f321'),
	 ('b1b1ddf3-5c85-4059-91c0-f4c6686daebd','31A','86c084a2-a9a5-48b4-9089-8c60be861427','47ac3706-27f3-4904-8ce7-afbe3edc3c74','368bf51e-bd0a-4320-b731-01a62a089450');



INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('60fcfea8-119b-42b8-b8b6-58f5bec8eb5e','14773ee9-0e3c-4285-b4e1-94db57591d11','3b559df8-87b9-42f8-ac64-0ac68ee0fab6','a237f557-b4df-492b-965e-ec632ef4fa4b',2),
	 ('545e0824-f8f6-46ea-a5c3-9431e0b4ee7e','3b559df8-87b9-42f8-ac64-0ac68ee0fab6','14773ee9-0e3c-4285-b4e1-94db57591d11','a237f557-b4df-492b-965e-ec632ef4fa4b',2),
	 ('63c47dc7-44a2-421b-9708-938907aad1f3','3b559df8-87b9-42f8-ac64-0ac68ee0fab6','768effc3-d589-4340-a0e7-a9f623bffb55','a237f557-b4df-492b-965e-ec632ef4fa4b',2),
	 ('a5d9d9da-0a2a-4292-aa54-01be19d6783a','768effc3-d589-4340-a0e7-a9f623bffb55','3b559df8-87b9-42f8-ac64-0ac68ee0fab6','a237f557-b4df-492b-965e-ec632ef4fa4b',2),
	 ('4562c2b6-7a65-440c-9315-a3c97dcc3c52','768effc3-d589-4340-a0e7-a9f623bffb55','f321a2ba-1264-4a95-8591-b8fbc4b4a2e9','a237f557-b4df-492b-965e-ec632ef4fa4b',2),
	 ('3bcc5770-dbd1-47b9-9e06-70e173277523','f321a2ba-1264-4a95-8591-b8fbc4b4a2e9','768effc3-d589-4340-a0e7-a9f623bffb55','a237f557-b4df-492b-965e-ec632ef4fa4b',2),
	 ('81f1408f-c872-450b-a396-662801b09824','f321a2ba-1264-4a95-8591-b8fbc4b4a2e9','706753aa-61f6-4dfd-96c5-9b9d98cc7c55','a237f557-b4df-492b-965e-ec632ef4fa4b',1),
	 ('282416af-ef9c-48b4-bece-5d3c12ee8892','706753aa-61f6-4dfd-96c5-9b9d98cc7c55','f321a2ba-1264-4a95-8591-b8fbc4b4a2e9','a237f557-b4df-492b-965e-ec632ef4fa4b',1),
	 ('6504a230-712a-4568-8b3e-6e17eb668cf1','706753aa-61f6-4dfd-96c5-9b9d98cc7c55','934ef3af-56e6-4b38-a35c-07899c544619','a237f557-b4df-492b-965e-ec632ef4fa4b',1),
	 ('66bb0617-e686-4e2f-bebc-3f2d9dfb292c','934ef3af-56e6-4b38-a35c-07899c544619','706753aa-61f6-4dfd-96c5-9b9d98cc7c55','a237f557-b4df-492b-965e-ec632ef4fa4b',1);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('72ff50f7-b109-492a-ab06-891a411a77b2','934ef3af-56e6-4b38-a35c-07899c544619','d64eb07b-d3a8-4b3e-a694-95b84c5c10c3','a237f557-b4df-492b-965e-ec632ef4fa4b',1),
	 ('c580f720-1f75-4196-ae13-549846bff3de','d64eb07b-d3a8-4b3e-a694-95b84c5c10c3','934ef3af-56e6-4b38-a35c-07899c544619','a237f557-b4df-492b-965e-ec632ef4fa4b',1),
	 ('e559f294-ef95-4266-982f-e4ecba6c2bec','d64eb07b-d3a8-4b3e-a694-95b84c5c10c3','d3ac5f66-6c17-4f55-a353-4e7a65a713c2','a237f557-b4df-492b-965e-ec632ef4fa4b',2),
	 ('8bb323d8-e85c-402c-b454-ef1fbcd0b17f','d3ac5f66-6c17-4f55-a353-4e7a65a713c2','d64eb07b-d3a8-4b3e-a694-95b84c5c10c3','a237f557-b4df-492b-965e-ec632ef4fa4b',2),
	 ('2726cde6-a774-4999-b27d-166d0c30e17b','d3ac5f66-6c17-4f55-a353-4e7a65a713c2','3db82493-778d-45ae-8f82-8e8041df60c5','a237f557-b4df-492b-965e-ec632ef4fa4b',1),
	 ('616c8a9e-7b38-46f6-8b8e-d3ccc000d828','3db82493-778d-45ae-8f82-8e8041df60c5','d3ac5f66-6c17-4f55-a353-4e7a65a713c2','a237f557-b4df-492b-965e-ec632ef4fa4b',1),
	 ('b7730804-9d2b-4660-b998-daca36d3679e','3db82493-778d-45ae-8f82-8e8041df60c5','162818a5-8c0a-4378-81aa-c37426076e47','a237f557-b4df-492b-965e-ec632ef4fa4b',2),
	 ('23593a32-2cda-4991-bd28-35edf6999f8b','162818a5-8c0a-4378-81aa-c37426076e47','3db82493-778d-45ae-8f82-8e8041df60c5','a237f557-b4df-492b-965e-ec632ef4fa4b',2),
	 ('087e1862-e399-43a2-9d77-5baea47194ba','162818a5-8c0a-4378-81aa-c37426076e47','b644c429-85e7-4df7-93ab-c6df884b2e3c','a237f557-b4df-492b-965e-ec632ef4fa4b',2),
	 ('49acf2c8-a885-41aa-93d3-2882b16d03f1','b644c429-85e7-4df7-93ab-c6df884b2e3c','162818a5-8c0a-4378-81aa-c37426076e47','a237f557-b4df-492b-965e-ec632ef4fa4b',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('58220a51-dc40-46a0-a459-b7650e628582','b644c429-85e7-4df7-93ab-c6df884b2e3c','4f35b01f-fab9-46cd-8d05-7d371e559374','a237f557-b4df-492b-965e-ec632ef4fa4b',1),
	 ('118992bc-e0e9-46bc-a14f-9c9baa0ca075','4f35b01f-fab9-46cd-8d05-7d371e559374','b644c429-85e7-4df7-93ab-c6df884b2e3c','a237f557-b4df-492b-965e-ec632ef4fa4b',1),
	 ('9652bf26-9875-4d4c-a992-2b8e9317cb42','4f35b01f-fab9-46cd-8d05-7d371e559374','b86d9573-e0b8-495f-9b73-612c6349ce82','a237f557-b4df-492b-965e-ec632ef4fa4b',1),
	 ('f8089559-a866-4462-9d97-ec1018768e12','b86d9573-e0b8-495f-9b73-612c6349ce82','4f35b01f-fab9-46cd-8d05-7d371e559374','a237f557-b4df-492b-965e-ec632ef4fa4b',1),
	 ('d3c0cf4d-aa4c-4b52-a842-a3c8eb9f2544','b86d9573-e0b8-495f-9b73-612c6349ce82','88e2fb0f-4066-4971-9e8b-a6b243c91b15','a237f557-b4df-492b-965e-ec632ef4fa4b',1),
	 ('286df6e9-95a6-4c62-a5de-49dbffbe2e5b','88e2fb0f-4066-4971-9e8b-a6b243c91b15','b86d9573-e0b8-495f-9b73-612c6349ce82','a237f557-b4df-492b-965e-ec632ef4fa4b',1),
	 ('4835ff89-ea38-4e57-bc7f-2d0eb3d5bd84','88e2fb0f-4066-4971-9e8b-a6b243c91b15','a2fd8164-e6d7-4156-82d9-3b4de08af562','a237f557-b4df-492b-965e-ec632ef4fa4b',1),
	 ('819b7a11-724e-4543-a1a1-a251f6b7db65','a2fd8164-e6d7-4156-82d9-3b4de08af562','88e2fb0f-4066-4971-9e8b-a6b243c91b15','a237f557-b4df-492b-965e-ec632ef4fa4b',1),
	 ('ba382001-1676-455a-83e7-8eea745566c2','a2fd8164-e6d7-4156-82d9-3b4de08af562','cf16ab0e-45c4-48d8-9284-32d21db03cd7','a237f557-b4df-492b-965e-ec632ef4fa4b',2),
	 ('83388a4c-e3f1-4c01-828d-25fe3fd496ff','cf16ab0e-45c4-48d8-9284-32d21db03cd7','a2fd8164-e6d7-4156-82d9-3b4de08af562','a237f557-b4df-492b-965e-ec632ef4fa4b',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('25a20d9b-c8ad-464a-a61d-59e58cb99775','cf16ab0e-45c4-48d8-9284-32d21db03cd7','055e096b-4c15-47ab-b9a4-dadec74b6d80','a237f557-b4df-492b-965e-ec632ef4fa4b',1),
	 ('18dbe683-c04d-41cd-9dc7-971c7f267555','055e096b-4c15-47ab-b9a4-dadec74b6d80','cf16ab0e-45c4-48d8-9284-32d21db03cd7','a237f557-b4df-492b-965e-ec632ef4fa4b',1),
	 ('0422f899-8a2c-41fd-962a-96d7eb2f0b7e','055e096b-4c15-47ab-b9a4-dadec74b6d80','59d471c3-6d19-459a-a3da-d6e234ec0a43','a237f557-b4df-492b-965e-ec632ef4fa4b',2),
	 ('30f581fb-d22c-4377-82bc-be01ffb9b8b2','59d471c3-6d19-459a-a3da-d6e234ec0a43','055e096b-4c15-47ab-b9a4-dadec74b6d80','a237f557-b4df-492b-965e-ec632ef4fa4b',2),
	 ('8184fa67-815e-4735-a467-dd35759634f8','59d471c3-6d19-459a-a3da-d6e234ec0a43','303b9732-4a0e-4e2c-8a5f-f809c4316b51','a237f557-b4df-492b-965e-ec632ef4fa4b',1),
	 ('770536bf-126f-4c05-a480-310323db4497','303b9732-4a0e-4e2c-8a5f-f809c4316b51','59d471c3-6d19-459a-a3da-d6e234ec0a43','a237f557-b4df-492b-965e-ec632ef4fa4b',1),
	 ('0fce3ed1-0aad-4e27-9c49-82e1af0f988a','303b9732-4a0e-4e2c-8a5f-f809c4316b51','47ac3706-27f3-4904-8ce7-afbe3edc3c74','a237f557-b4df-492b-965e-ec632ef4fa4b',2),
	 ('a4340c56-44c1-4058-8550-d12201c90ebb','47ac3706-27f3-4904-8ce7-afbe3edc3c74','303b9732-4a0e-4e2c-8a5f-f809c4316b51','a237f557-b4df-492b-965e-ec632ef4fa4b',2),
	 ('3a425016-4cc3-44e6-ba4c-04163e96eea5','47ac3706-27f3-4904-8ce7-afbe3edc3c74','1a7ab370-2650-4726-b231-a4d82a7223ce','a237f557-b4df-492b-965e-ec632ef4fa4b',2),
	 ('4f3439e5-bd1f-4f73-8c38-05a8387c2a16','1a7ab370-2650-4726-b231-a4d82a7223ce','47ac3706-27f3-4904-8ce7-afbe3edc3c74','a237f557-b4df-492b-965e-ec632ef4fa4b',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('ddc02675-fefb-42ed-9a40-e583ced21b6f','1a7ab370-2650-4726-b231-a4d82a7223ce','8a5f3f58-32fc-4ee4-b341-a1ade7bed711','a237f557-b4df-492b-965e-ec632ef4fa4b',1),
	 ('31ba0089-910e-435c-9aff-4f287f62e560','8a5f3f58-32fc-4ee4-b341-a1ade7bed711','1a7ab370-2650-4726-b231-a4d82a7223ce','a237f557-b4df-492b-965e-ec632ef4fa4b',1),
	 ('e933690c-3fc1-44c4-b117-5df5fbaece21','8a5f3f58-32fc-4ee4-b341-a1ade7bed711','8eb6979a-9a14-4799-9cbc-6a9953b3720d','a237f557-b4df-492b-965e-ec632ef4fa4b',1),
	 ('83048b44-635e-42a8-b678-ce0b0f0b0618','8eb6979a-9a14-4799-9cbc-6a9953b3720d','8a5f3f58-32fc-4ee4-b341-a1ade7bed711','a237f557-b4df-492b-965e-ec632ef4fa4b',1),
	 ('5e04c985-66d6-435c-8169-844c19b7eac0','8eb6979a-9a14-4799-9cbc-6a9953b3720d','518c4e51-c4ff-4bff-b96d-bec8d0957829','a237f557-b4df-492b-965e-ec632ef4fa4b',2),
	 ('69751e28-36bf-49fe-9945-9912650ec6de','518c4e51-c4ff-4bff-b96d-bec8d0957829','8eb6979a-9a14-4799-9cbc-6a9953b3720d','a237f557-b4df-492b-965e-ec632ef4fa4b',2),
	 ('dc250bce-43ce-4a37-9662-113aeeff0483','4ac249f8-84b2-4de5-8693-61c384ac9a8f','94d259ef-3803-4280-921f-85c7c34e2785','54dde729-6ee3-473a-838d-56a87df04fa3',2),
	 ('3ba49bf7-8fb3-440e-949b-e1f4a96741f5','94d259ef-3803-4280-921f-85c7c34e2785','4ac249f8-84b2-4de5-8693-61c384ac9a8f','54dde729-6ee3-473a-838d-56a87df04fa3',2),
	 ('f4fa3a23-42d4-47f5-a75a-e8861ec92d85','94d259ef-3803-4280-921f-85c7c34e2785','b3827d25-c051-4a9b-94b7-f2dfb882f53d','54dde729-6ee3-473a-838d-56a87df04fa3',2),
	 ('ea591de7-57fc-469e-8d43-a69871f37abc','b3827d25-c051-4a9b-94b7-f2dfb882f53d','94d259ef-3803-4280-921f-85c7c34e2785','54dde729-6ee3-473a-838d-56a87df04fa3',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('14e9ce4e-9520-4bdd-95e6-e24f1c374a93','b3827d25-c051-4a9b-94b7-f2dfb882f53d','1f9d37c9-6d39-4002-ac8e-56065e4c1afc','54dde729-6ee3-473a-838d-56a87df04fa3',2),
	 ('5e09445b-7bd1-4784-a835-1a493eff9cb6','1f9d37c9-6d39-4002-ac8e-56065e4c1afc','b3827d25-c051-4a9b-94b7-f2dfb882f53d','54dde729-6ee3-473a-838d-56a87df04fa3',2),
	 ('ace25213-8cb8-4867-af98-e239fc31c3fd','1f9d37c9-6d39-4002-ac8e-56065e4c1afc','0b940c62-cda8-4e97-835d-9acd7ac402c2','54dde729-6ee3-473a-838d-56a87df04fa3',1),
	 ('40727e66-87ab-47a5-96b6-fda9a0bb6026','0b940c62-cda8-4e97-835d-9acd7ac402c2','1f9d37c9-6d39-4002-ac8e-56065e4c1afc','54dde729-6ee3-473a-838d-56a87df04fa3',1),
	 ('a93169c4-ce28-4b98-9dd5-a72c42a83635','0b940c62-cda8-4e97-835d-9acd7ac402c2','f4404ca9-8cd4-40eb-847e-752229ee3956','54dde729-6ee3-473a-838d-56a87df04fa3',2),
	 ('07eed44e-2cdd-413b-922b-075a83e9382b','f4404ca9-8cd4-40eb-847e-752229ee3956','0b940c62-cda8-4e97-835d-9acd7ac402c2','54dde729-6ee3-473a-838d-56a87df04fa3',2),
	 ('7b5cd39d-e5a4-441e-b119-4f7e511f3644','f4404ca9-8cd4-40eb-847e-752229ee3956','1349aeb1-9bcf-4687-a73a-2bceb5c5d770','54dde729-6ee3-473a-838d-56a87df04fa3',1),
	 ('00187fd4-1604-4b44-97e7-2a8890dea0c7','1349aeb1-9bcf-4687-a73a-2bceb5c5d770','f4404ca9-8cd4-40eb-847e-752229ee3956','54dde729-6ee3-473a-838d-56a87df04fa3',1),
	 ('18fa8a72-5ac6-4314-87f1-1f700a984de1','1349aeb1-9bcf-4687-a73a-2bceb5c5d770','1875ea70-83e4-44bf-8dad-e13b3896ef16','54dde729-6ee3-473a-838d-56a87df04fa3',2),
	 ('d782e2f1-b878-4af6-81b0-eb77a1019eac','1875ea70-83e4-44bf-8dad-e13b3896ef16','1349aeb1-9bcf-4687-a73a-2bceb5c5d770','54dde729-6ee3-473a-838d-56a87df04fa3',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('beb5f681-2b7f-4e0d-bca4-5cb35d9b10a9','1875ea70-83e4-44bf-8dad-e13b3896ef16','c010ab9c-5868-408e-a61f-1fc31cc1848f','54dde729-6ee3-473a-838d-56a87df04fa3',1),
	 ('3e0bebb0-a14f-4aa6-a047-675ade234ddb','c010ab9c-5868-408e-a61f-1fc31cc1848f','1875ea70-83e4-44bf-8dad-e13b3896ef16','54dde729-6ee3-473a-838d-56a87df04fa3',1),
	 ('e7baab0a-d9e1-4073-9dc2-99b51c9faa3f','c010ab9c-5868-408e-a61f-1fc31cc1848f','e4360913-4762-498c-9b14-28c38032a8ec','54dde729-6ee3-473a-838d-56a87df04fa3',2),
	 ('8c5e7bea-d1d2-4139-9ad1-89651055ce26','e4360913-4762-498c-9b14-28c38032a8ec','c010ab9c-5868-408e-a61f-1fc31cc1848f','54dde729-6ee3-473a-838d-56a87df04fa3',2),
	 ('b095f334-0b47-4928-9f6c-3162c1ad0958','e4360913-4762-498c-9b14-28c38032a8ec','1ba82453-b22d-4382-8fa1-7d8366b6268c','54dde729-6ee3-473a-838d-56a87df04fa3',1),
	 ('fc43604a-6900-4b46-a5d3-c28d5f91ab77','1ba82453-b22d-4382-8fa1-7d8366b6268c','e4360913-4762-498c-9b14-28c38032a8ec','54dde729-6ee3-473a-838d-56a87df04fa3',1),
	 ('18243173-03e2-4393-98ea-0ad08db73c3d','1ba82453-b22d-4382-8fa1-7d8366b6268c','1fde5aeb-2ed4-48d4-a070-0eb8226bd4ca','54dde729-6ee3-473a-838d-56a87df04fa3',1),
	 ('ef19a172-8b2d-4b26-84d4-5aa887cff103','1fde5aeb-2ed4-48d4-a070-0eb8226bd4ca','1ba82453-b22d-4382-8fa1-7d8366b6268c','54dde729-6ee3-473a-838d-56a87df04fa3',1),
	 ('9062351e-c8a2-43af-a9a2-0bebea269835','1fde5aeb-2ed4-48d4-a070-0eb8226bd4ca','88e2fb0f-4066-4971-9e8b-a6b243c91b15','54dde729-6ee3-473a-838d-56a87df04fa3',2),
	 ('e09297a7-e1bd-4088-8935-b9e000be0a09','88e2fb0f-4066-4971-9e8b-a6b243c91b15','1fde5aeb-2ed4-48d4-a070-0eb8226bd4ca','54dde729-6ee3-473a-838d-56a87df04fa3',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('9062a695-cdd2-4aeb-a3e6-cef29eae589d','88e2fb0f-4066-4971-9e8b-a6b243c91b15','263d8c1b-6925-476a-b481-36b498a8ad2a','54dde729-6ee3-473a-838d-56a87df04fa3',2),
	 ('eea060b3-a766-40eb-8067-d35eed4f479b','263d8c1b-6925-476a-b481-36b498a8ad2a','88e2fb0f-4066-4971-9e8b-a6b243c91b15','54dde729-6ee3-473a-838d-56a87df04fa3',2),
	 ('129e9f28-f407-4f19-8021-0a53dfbdb6d8','263d8c1b-6925-476a-b481-36b498a8ad2a','e5635ac1-7dec-4434-a53a-ce6d3e722f73','54dde729-6ee3-473a-838d-56a87df04fa3',1),
	 ('7c773dd5-bfc5-4a69-8270-87f9c8fc2a89','e5635ac1-7dec-4434-a53a-ce6d3e722f73','263d8c1b-6925-476a-b481-36b498a8ad2a','54dde729-6ee3-473a-838d-56a87df04fa3',1),
	 ('94da108b-c6f6-49e6-98da-f109d07a4923','e5635ac1-7dec-4434-a53a-ce6d3e722f73','797e5f26-d606-4373-815c-20c976256bd3','54dde729-6ee3-473a-838d-56a87df04fa3',1),
	 ('497be2f5-b197-48f5-808b-dd4140652700','797e5f26-d606-4373-815c-20c976256bd3','e5635ac1-7dec-4434-a53a-ce6d3e722f73','54dde729-6ee3-473a-838d-56a87df04fa3',1),
	 ('5c685a9f-fdc2-4232-a606-b4cc9a45a0ed','797e5f26-d606-4373-815c-20c976256bd3','8b55c891-a33c-49f2-8ab0-0d0112f6f44f','54dde729-6ee3-473a-838d-56a87df04fa3',2),
	 ('76b6afbc-9c41-41cf-8016-4591f2645188','8b55c891-a33c-49f2-8ab0-0d0112f6f44f','797e5f26-d606-4373-815c-20c976256bd3','54dde729-6ee3-473a-838d-56a87df04fa3',2),
	 ('1486df32-254b-4aa1-bee8-226dd7e7dd11','8b55c891-a33c-49f2-8ab0-0d0112f6f44f','81872694-6819-4f28-8b99-aaf7996cdd42','54dde729-6ee3-473a-838d-56a87df04fa3',2),
	 ('5e92da0a-2c58-4134-98e3-3b2d455dfdb6','81872694-6819-4f28-8b99-aaf7996cdd42','8b55c891-a33c-49f2-8ab0-0d0112f6f44f','54dde729-6ee3-473a-838d-56a87df04fa3',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('2c797c65-be24-4b52-999e-2009b13be21e','81872694-6819-4f28-8b99-aaf7996cdd42','58808c21-802c-4e0f-bb2e-9cd37fd7ef37','54dde729-6ee3-473a-838d-56a87df04fa3',1),
	 ('10a8be99-563a-4992-b010-e1021be257fe','58808c21-802c-4e0f-bb2e-9cd37fd7ef37','81872694-6819-4f28-8b99-aaf7996cdd42','54dde729-6ee3-473a-838d-56a87df04fa3',1),
	 ('a580893f-644a-4658-b9ff-977788426056','58808c21-802c-4e0f-bb2e-9cd37fd7ef37','162818a5-8c0a-4378-81aa-c37426076e47','54dde729-6ee3-473a-838d-56a87df04fa3',2),
	 ('70803c5d-7828-42ac-81df-b7a7096ee83c','162818a5-8c0a-4378-81aa-c37426076e47','58808c21-802c-4e0f-bb2e-9cd37fd7ef37','54dde729-6ee3-473a-838d-56a87df04fa3',2),
	 ('bc6b0e67-84f0-4a20-a4ba-4b42711d324f','22b98b73-3a3e-438b-9544-29ed32a718d5','bf1a4505-b564-4c7a-a2b1-e82c21cc3183','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('eaf8a2db-3bc0-4c25-b22a-1e0517fbde54','bf1a4505-b564-4c7a-a2b1-e82c21cc3183','22b98b73-3a3e-438b-9544-29ed32a718d5','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('2c2b1a5b-008c-4c9e-be7d-e821c3b888c7','bf1a4505-b564-4c7a-a2b1-e82c21cc3183','572996f5-6478-4c2e-9638-ca32fa754e70','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('5a5a7a5d-131e-4b5d-adbc-c20003d30867','572996f5-6478-4c2e-9638-ca32fa754e70','bf1a4505-b564-4c7a-a2b1-e82c21cc3183','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('651d317d-25d6-4b23-93a2-4ab1467b1ccc','572996f5-6478-4c2e-9638-ca32fa754e70','1b645f6e-6f73-42d9-a111-03c343612049','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('5229311e-7632-4638-926e-935617ca0ceb','1b645f6e-6f73-42d9-a111-03c343612049','572996f5-6478-4c2e-9638-ca32fa754e70','b32191f3-8c52-40a4-b464-b2f215f15c82',1);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('551646b9-6c45-41b9-b500-e2f91973b998','1b645f6e-6f73-42d9-a111-03c343612049','96db6419-1b87-4c0e-8184-3db4e78ad226','b32191f3-8c52-40a4-b464-b2f215f15c82',2),
	 ('f484b644-781e-40ca-bdb0-b31595c145df','96db6419-1b87-4c0e-8184-3db4e78ad226','1b645f6e-6f73-42d9-a111-03c343612049','b32191f3-8c52-40a4-b464-b2f215f15c82',2),
	 ('4c83ad5b-6e86-4bf8-b157-963ba0a70922','96db6419-1b87-4c0e-8184-3db4e78ad226','d535e27e-12a0-4986-b7f4-2c76007c2d97','b32191f3-8c52-40a4-b464-b2f215f15c82',2),
	 ('95bac24c-0f92-455d-8b2e-1745fb250263','d535e27e-12a0-4986-b7f4-2c76007c2d97','96db6419-1b87-4c0e-8184-3db4e78ad226','b32191f3-8c52-40a4-b464-b2f215f15c82',2),
	 ('a61b2f95-e70f-4b1a-948a-a9a202d7755f','d535e27e-12a0-4986-b7f4-2c76007c2d97','6214d028-726b-40d6-9711-c40e6745e5f9','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('cc559f6f-6e95-43f4-b0f9-3aef30bd168d','6214d028-726b-40d6-9711-c40e6745e5f9','d535e27e-12a0-4986-b7f4-2c76007c2d97','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('f09251ce-5c1c-4143-b66c-ff0506bd1b4f','6214d028-726b-40d6-9711-c40e6745e5f9','0e2f4451-6ead-4364-ac57-b247bc787e96','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('83afc5cb-d260-4030-b386-5029c0b485ee','0e2f4451-6ead-4364-ac57-b247bc787e96','6214d028-726b-40d6-9711-c40e6745e5f9','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('eba863ad-ebb7-499d-9d30-2de4f6b052ba','0e2f4451-6ead-4364-ac57-b247bc787e96','81872694-6819-4f28-8b99-aaf7996cdd42','b32191f3-8c52-40a4-b464-b2f215f15c82',2),
	 ('ed2350ea-cd40-4d27-8ad6-be4cbfaabae7','81872694-6819-4f28-8b99-aaf7996cdd42','0e2f4451-6ead-4364-ac57-b247bc787e96','b32191f3-8c52-40a4-b464-b2f215f15c82',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('70d3820c-bc67-40d5-b065-4906699a0d5c','81872694-6819-4f28-8b99-aaf7996cdd42','608e19cc-c7c5-4dfc-b8f7-f4b515179a03','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('fe055e3f-8fdd-4a4b-a2a7-b993b79f39bb','608e19cc-c7c5-4dfc-b8f7-f4b515179a03','81872694-6819-4f28-8b99-aaf7996cdd42','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('3051c657-85ad-4f8a-bbd2-c6cfe27b5252','608e19cc-c7c5-4dfc-b8f7-f4b515179a03','b644c429-85e7-4df7-93ab-c6df884b2e3c','b32191f3-8c52-40a4-b464-b2f215f15c82',2),
	 ('ff84edd5-2909-4907-9224-c5a15b7fd3c0','b644c429-85e7-4df7-93ab-c6df884b2e3c','608e19cc-c7c5-4dfc-b8f7-f4b515179a03','b32191f3-8c52-40a4-b464-b2f215f15c82',2),
	 ('2ce5fb53-f5dc-4f94-9d95-572d92c1f34c','b644c429-85e7-4df7-93ab-c6df884b2e3c','d4e37c52-5a8f-4766-993b-a9a0a1a9976b','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('1cd39cb1-22c5-423f-9eaf-09f67447facc','d4e37c52-5a8f-4766-993b-a9a0a1a9976b','b644c429-85e7-4df7-93ab-c6df884b2e3c','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('b47a5304-a43e-4e36-bc66-55baa3807fad','d4e37c52-5a8f-4766-993b-a9a0a1a9976b','650ac789-b6b5-4d5b-aeb0-cc9629cf42fb','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('e93c5038-a3d4-4049-b2db-566c6fdf27cf','650ac789-b6b5-4d5b-aeb0-cc9629cf42fb','d4e37c52-5a8f-4766-993b-a9a0a1a9976b','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('021f5910-9466-4b64-818f-ebc07324bf5a','650ac789-b6b5-4d5b-aeb0-cc9629cf42fb','71283ebe-a4fc-43c7-897e-23be923eca83','b32191f3-8c52-40a4-b464-b2f215f15c82',2),
	 ('b7cae043-b6d5-464e-9c4d-edeaeaf206ab','71283ebe-a4fc-43c7-897e-23be923eca83','650ac789-b6b5-4d5b-aeb0-cc9629cf42fb','b32191f3-8c52-40a4-b464-b2f215f15c82',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('dea5745f-dd08-4b4d-8c09-09094b92c0b3','71283ebe-a4fc-43c7-897e-23be923eca83','6a7f680d-8fba-4e7d-a842-7ea8175bc6a7','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('9a6009b1-c888-45d7-a927-95ad77d83794','6a7f680d-8fba-4e7d-a842-7ea8175bc6a7','71283ebe-a4fc-43c7-897e-23be923eca83','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('a6d89dc0-b34d-48dd-b602-a1689f0cd1a0','6a7f680d-8fba-4e7d-a842-7ea8175bc6a7','57033cae-db98-4545-8cc0-74d62a8ad3e4','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('34bacc3f-e4a8-4333-a61a-128ab4a9d4bf','57033cae-db98-4545-8cc0-74d62a8ad3e4','6a7f680d-8fba-4e7d-a842-7ea8175bc6a7','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('b90142c3-778b-48ff-9b45-7926010f4f11','57033cae-db98-4545-8cc0-74d62a8ad3e4','ceb39674-107d-425f-8feb-5e1eb08d43a8','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('198ee569-fa86-4c65-9df4-3f436de2e08f','ceb39674-107d-425f-8feb-5e1eb08d43a8','57033cae-db98-4545-8cc0-74d62a8ad3e4','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('ee992672-9b5a-4ae0-8616-a19625b828e6','ceb39674-107d-425f-8feb-5e1eb08d43a8','6b6be3f3-9e27-43e7-b6d4-519d297e0d6c','b32191f3-8c52-40a4-b464-b2f215f15c82',2),
	 ('88e8ec93-f788-4f81-a533-6d644dbe8271','6b6be3f3-9e27-43e7-b6d4-519d297e0d6c','ceb39674-107d-425f-8feb-5e1eb08d43a8','b32191f3-8c52-40a4-b464-b2f215f15c82',2),
	 ('4dc151d4-dade-49b8-8e51-08bb7201804c','6b6be3f3-9e27-43e7-b6d4-519d297e0d6c','926ff310-2fa6-43f0-a9f3-199a1370833d','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('605663e0-3b23-4c79-88d1-cf4c9fa5486e','926ff310-2fa6-43f0-a9f3-199a1370833d','6b6be3f3-9e27-43e7-b6d4-519d297e0d6c','b32191f3-8c52-40a4-b464-b2f215f15c82',1);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('198717bd-634f-4eb8-b9c3-0b2b1ac5f8a1','926ff310-2fa6-43f0-a9f3-199a1370833d','9b879336-c0c4-4d32-9afd-753a5f60ccca','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('74ebb6bb-112a-40b8-b390-a945d9f09b71','9b879336-c0c4-4d32-9afd-753a5f60ccca','926ff310-2fa6-43f0-a9f3-199a1370833d','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('871b846f-5fd8-4677-bece-e2d88c3d50ca','9b879336-c0c4-4d32-9afd-753a5f60ccca','729133a1-7671-48ef-a70b-45ca77075933','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('8d9de78d-e4e1-4f52-b4a4-3e530bf266a0','729133a1-7671-48ef-a70b-45ca77075933','9b879336-c0c4-4d32-9afd-753a5f60ccca','b32191f3-8c52-40a4-b464-b2f215f15c82',1),
	 ('1a5d2f23-9801-48d7-9915-26e18f0f9df3','05e45d5b-beb5-4ceb-a43f-2e4068a32914','f57c6300-581e-46e7-9fe5-dbb42a462aec','c61d57cf-def1-4574-aa10-05b463d166b5',2),
	 ('ae88847d-5087-4e21-bf62-4cca02e43fa6','f57c6300-581e-46e7-9fe5-dbb42a462aec','05e45d5b-beb5-4ceb-a43f-2e4068a32914','c61d57cf-def1-4574-aa10-05b463d166b5',2),
	 ('e8e511d0-6555-4609-8aef-e46c76ddc8ba','f57c6300-581e-46e7-9fe5-dbb42a462aec','34607a50-8813-4793-a8c5-5426e5d7ea50','c61d57cf-def1-4574-aa10-05b463d166b5',1),
	 ('bc16f187-12a9-42bc-8183-3fea32fdcb77','34607a50-8813-4793-a8c5-5426e5d7ea50','f57c6300-581e-46e7-9fe5-dbb42a462aec','c61d57cf-def1-4574-aa10-05b463d166b5',1),
	 ('7e2d8917-a7f5-4a00-a861-549dcf47a398','34607a50-8813-4793-a8c5-5426e5d7ea50','14298d60-5fd4-4587-a40e-1681801fd06a','c61d57cf-def1-4574-aa10-05b463d166b5',1),
	 ('9f83a3e2-fdd8-4206-9410-52808a523706','14298d60-5fd4-4587-a40e-1681801fd06a','34607a50-8813-4793-a8c5-5426e5d7ea50','c61d57cf-def1-4574-aa10-05b463d166b5',1);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('69eb7bad-b44e-45b2-ac65-cb981ac9a71e','14298d60-5fd4-4587-a40e-1681801fd06a','e5635ac1-7dec-4434-a53a-ce6d3e722f73','c61d57cf-def1-4574-aa10-05b463d166b5',2),
	 ('730dab4a-0263-4b95-a285-3039f0558f52','e5635ac1-7dec-4434-a53a-ce6d3e722f73','14298d60-5fd4-4587-a40e-1681801fd06a','c61d57cf-def1-4574-aa10-05b463d166b5',2),
	 ('8c6528bb-f049-45d0-b73a-0dbdef8b7d57','e5635ac1-7dec-4434-a53a-ce6d3e722f73','4f35b01f-fab9-46cd-8d05-7d371e559374','c61d57cf-def1-4574-aa10-05b463d166b5',1),
	 ('00b13d06-e79b-4768-8dad-c44d9f436db4','4f35b01f-fab9-46cd-8d05-7d371e559374','e5635ac1-7dec-4434-a53a-ce6d3e722f73','c61d57cf-def1-4574-aa10-05b463d166b5',1),
	 ('f97af895-32b1-495d-8cfd-47b81c2dec01','4f35b01f-fab9-46cd-8d05-7d371e559374','650ac789-b6b5-4d5b-aeb0-cc9629cf42fb','c61d57cf-def1-4574-aa10-05b463d166b5',2),
	 ('7c483206-69f8-4987-9e09-bfec06146011','650ac789-b6b5-4d5b-aeb0-cc9629cf42fb','4f35b01f-fab9-46cd-8d05-7d371e559374','c61d57cf-def1-4574-aa10-05b463d166b5',2),
	 ('56c9a14c-7aa1-47cb-81d3-9fe6f7ded926','650ac789-b6b5-4d5b-aeb0-cc9629cf42fb','f9c1c167-d4b4-46e7-9d2a-b111504a13b6','c61d57cf-def1-4574-aa10-05b463d166b5',1),
	 ('f3fbfb1e-410e-4ce1-85fe-4098083dc471','f9c1c167-d4b4-46e7-9d2a-b111504a13b6','650ac789-b6b5-4d5b-aeb0-cc9629cf42fb','c61d57cf-def1-4574-aa10-05b463d166b5',1),
	 ('cd6d342b-7b6b-4565-8036-2b85da0bf420','f9c1c167-d4b4-46e7-9d2a-b111504a13b6','162818a5-8c0a-4378-81aa-c37426076e47','c61d57cf-def1-4574-aa10-05b463d166b5',2),
	 ('0599150e-4364-4c78-954f-da565f7ec0d0','162818a5-8c0a-4378-81aa-c37426076e47','f9c1c167-d4b4-46e7-9d2a-b111504a13b6','c61d57cf-def1-4574-aa10-05b463d166b5',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('2d8ccc16-7545-411f-aa3f-1feb6aa23e80','162818a5-8c0a-4378-81aa-c37426076e47','ad7cc231-9a35-4b3f-a176-673fe96c9cda','c61d57cf-def1-4574-aa10-05b463d166b5',2),
	 ('32b85979-20f8-49b7-92d6-db983a20b3ae','ad7cc231-9a35-4b3f-a176-673fe96c9cda','162818a5-8c0a-4378-81aa-c37426076e47','c61d57cf-def1-4574-aa10-05b463d166b5',2),
	 ('9044f7dd-23bb-4430-853b-eeb0089ee995','ad7cc231-9a35-4b3f-a176-673fe96c9cda','ceb59cbc-f40e-43a4-b5bf-75dacb06edc8','c61d57cf-def1-4574-aa10-05b463d166b5',1),
	 ('c26d1a94-2365-4f40-a144-0ef2eb754e46','ceb59cbc-f40e-43a4-b5bf-75dacb06edc8','ad7cc231-9a35-4b3f-a176-673fe96c9cda','c61d57cf-def1-4574-aa10-05b463d166b5',1),
	 ('325de2b2-2c50-4eb2-8844-74ce4ad92fbd','ceb59cbc-f40e-43a4-b5bf-75dacb06edc8','6ddfd002-b55d-4686-92f3-bf02baf32927','c61d57cf-def1-4574-aa10-05b463d166b5',2),
	 ('510ce546-ab43-48f7-8940-f7b66cc0acb4','6ddfd002-b55d-4686-92f3-bf02baf32927','ceb59cbc-f40e-43a4-b5bf-75dacb06edc8','c61d57cf-def1-4574-aa10-05b463d166b5',2),
	 ('08d1c362-f576-4d4f-befc-fa57e0b707d1','6ddfd002-b55d-4686-92f3-bf02baf32927','79d75cae-e513-4d91-935d-c2888886bbeb','c61d57cf-def1-4574-aa10-05b463d166b5',2),
	 ('0733385b-4774-4a8b-90c0-14a14086362f','79d75cae-e513-4d91-935d-c2888886bbeb','6ddfd002-b55d-4686-92f3-bf02baf32927','c61d57cf-def1-4574-aa10-05b463d166b5',2),
	 ('679394d6-cbf1-4177-9989-52abec71d434','79d75cae-e513-4d91-935d-c2888886bbeb','444c59f0-a197-44d3-a83b-84a829f370fe','c61d57cf-def1-4574-aa10-05b463d166b5',1),
	 ('b1de0ebd-9325-4b2e-b1c5-dbe9a56b98c0','444c59f0-a197-44d3-a83b-84a829f370fe','79d75cae-e513-4d91-935d-c2888886bbeb','c61d57cf-def1-4574-aa10-05b463d166b5',1);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('9744200d-3c93-4362-879b-08c0382bc001','444c59f0-a197-44d3-a83b-84a829f370fe','097f8a83-5ec5-4456-8101-781bd18cceba','c61d57cf-def1-4574-aa10-05b463d166b5',1),
	 ('9bdee917-daa0-48fb-8a28-5e747e868125','097f8a83-5ec5-4456-8101-781bd18cceba','444c59f0-a197-44d3-a83b-84a829f370fe','c61d57cf-def1-4574-aa10-05b463d166b5',1),
	 ('77243839-74c6-4490-8756-a9dc2707da63','097f8a83-5ec5-4456-8101-781bd18cceba','9ad78501-3253-4c5b-9a7c-5f7f619f6dd7','c61d57cf-def1-4574-aa10-05b463d166b5',2),
	 ('586a0828-11c2-40e8-91a7-ba34f4debf6e','9ad78501-3253-4c5b-9a7c-5f7f619f6dd7','097f8a83-5ec5-4456-8101-781bd18cceba','c61d57cf-def1-4574-aa10-05b463d166b5',2),
	 ('9738e0ed-ebc5-43b2-bed3-0a1c29ce7b5f','9ad78501-3253-4c5b-9a7c-5f7f619f6dd7','823df5e4-61be-40dd-a71a-d099067540bd','c61d57cf-def1-4574-aa10-05b463d166b5',1),
	 ('bb9df5ad-5cd2-43ec-838a-a2be963b2b05','823df5e4-61be-40dd-a71a-d099067540bd','9ad78501-3253-4c5b-9a7c-5f7f619f6dd7','c61d57cf-def1-4574-aa10-05b463d166b5',1),
	 ('c59c4f6b-d396-4c35-9d79-cc4b2b3a0c35','823df5e4-61be-40dd-a71a-d099067540bd','39fec395-e62d-4bdb-b75f-de9b2c3d3024','c61d57cf-def1-4574-aa10-05b463d166b5',2),
	 ('0db162ff-129c-41a0-a6e9-3013bb789c92','39fec395-e62d-4bdb-b75f-de9b2c3d3024','823df5e4-61be-40dd-a71a-d099067540bd','c61d57cf-def1-4574-aa10-05b463d166b5',2),
	 ('f2bd8021-96e3-4adb-bf8a-1c24aaddfff0','39fec395-e62d-4bdb-b75f-de9b2c3d3024','2c23949f-9a60-48c1-9367-a1b80206b09e','c61d57cf-def1-4574-aa10-05b463d166b5',1),
	 ('06d2241e-d3c2-4c6a-a387-2392d95e0e14','2c23949f-9a60-48c1-9367-a1b80206b09e','39fec395-e62d-4bdb-b75f-de9b2c3d3024','c61d57cf-def1-4574-aa10-05b463d166b5',1);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('618a804d-ccca-4346-88b7-4fea868ae14a','2c23949f-9a60-48c1-9367-a1b80206b09e','17d89c74-90fa-4a71-b6e7-754c8f119837','c61d57cf-def1-4574-aa10-05b463d166b5',2),
	 ('564e8af6-60aa-408e-a7e3-fc2bfb246d1d','17d89c74-90fa-4a71-b6e7-754c8f119837','2c23949f-9a60-48c1-9367-a1b80206b09e','c61d57cf-def1-4574-aa10-05b463d166b5',2),
	 ('5f3801e7-fb65-4b32-b1ab-3980d6079ec9','78a12cb5-a4a0-442c-888e-ffb7dd71db5f','3bb326bd-f45c-4139-bd81-be78f1592c0f','c5a310e3-9810-48af-9d38-1093bcea453a',1),
	 ('22d1b835-f182-4902-919c-25d2e66b9d64','3bb326bd-f45c-4139-bd81-be78f1592c0f','78a12cb5-a4a0-442c-888e-ffb7dd71db5f','c5a310e3-9810-48af-9d38-1093bcea453a',1),
	 ('bed19f04-8f23-44e9-ac52-b2b05b78c5aa','3bb326bd-f45c-4139-bd81-be78f1592c0f','870cfa60-a506-473b-b578-b5349812bc89','c5a310e3-9810-48af-9d38-1093bcea453a',1),
	 ('8bd1ef73-6144-4fc3-8f3b-11506f169561','870cfa60-a506-473b-b578-b5349812bc89','3bb326bd-f45c-4139-bd81-be78f1592c0f','c5a310e3-9810-48af-9d38-1093bcea453a',1),
	 ('768d512d-958d-4d75-8a2d-db48c763afee','870cfa60-a506-473b-b578-b5349812bc89','9bc3fbd3-4875-4b28-8acb-733f4d3e358e','c5a310e3-9810-48af-9d38-1093bcea453a',2),
	 ('96ff6196-1538-4c25-9b56-5b9aed9e8dab','9bc3fbd3-4875-4b28-8acb-733f4d3e358e','870cfa60-a506-473b-b578-b5349812bc89','c5a310e3-9810-48af-9d38-1093bcea453a',2),
	 ('1493a4cf-115d-42cd-ab3d-1e146e3e9d96','9bc3fbd3-4875-4b28-8acb-733f4d3e358e','f9c8e55b-25cb-4f30-bd3e-3657bfe7d8a1','c5a310e3-9810-48af-9d38-1093bcea453a',2),
	 ('ee6ab7bb-93ba-45dd-b866-f5db07de659a','f9c8e55b-25cb-4f30-bd3e-3657bfe7d8a1','9bc3fbd3-4875-4b28-8acb-733f4d3e358e','c5a310e3-9810-48af-9d38-1093bcea453a',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('8322eae3-2873-48ea-ab9f-55474e169a34','f9c8e55b-25cb-4f30-bd3e-3657bfe7d8a1','263d8e52-8d76-4db8-bbb6-18928baefada','c5a310e3-9810-48af-9d38-1093bcea453a',1),
	 ('61ed91b3-3ecb-4f74-98d1-7e1b3503e01f','263d8e52-8d76-4db8-bbb6-18928baefada','f9c8e55b-25cb-4f30-bd3e-3657bfe7d8a1','c5a310e3-9810-48af-9d38-1093bcea453a',1),
	 ('c6607dea-6741-430e-a8a9-1568b1023692','263d8e52-8d76-4db8-bbb6-18928baefada','b5784e61-d318-4d65-83ad-f3be2b58a8fd','c5a310e3-9810-48af-9d38-1093bcea453a',2),
	 ('a30fa970-74a6-4606-a275-83ebd80688b1','b5784e61-d318-4d65-83ad-f3be2b58a8fd','263d8e52-8d76-4db8-bbb6-18928baefada','c5a310e3-9810-48af-9d38-1093bcea453a',2),
	 ('a8748213-2387-4cf8-bf73-8a752f754b1f','b5784e61-d318-4d65-83ad-f3be2b58a8fd','2585eada-c145-42e2-8e82-63b0c4f0f321','c5a310e3-9810-48af-9d38-1093bcea453a',2),
	 ('9973aa11-cc31-485c-90fb-67d77e49bc03','2585eada-c145-42e2-8e82-63b0c4f0f321','b5784e61-d318-4d65-83ad-f3be2b58a8fd','c5a310e3-9810-48af-9d38-1093bcea453a',2),
	 ('4bcceb31-4053-4595-af96-4f6f145f0f78','2585eada-c145-42e2-8e82-63b0c4f0f321','79d75cae-e513-4d91-935d-c2888886bbeb','c5a310e3-9810-48af-9d38-1093bcea453a',1),
	 ('159c998d-daab-4846-8ace-9ea52ce26694','79d75cae-e513-4d91-935d-c2888886bbeb','2585eada-c145-42e2-8e82-63b0c4f0f321','c5a310e3-9810-48af-9d38-1093bcea453a',1),
	 ('7d666f56-5cac-4dd3-8540-5eccb9d922ae','79d75cae-e513-4d91-935d-c2888886bbeb','bf331bb7-00d4-4ec7-8765-c5286b0c12ce','c5a310e3-9810-48af-9d38-1093bcea453a',2),
	 ('0891a718-1dcf-4bb6-9a4a-037266f8399b','bf331bb7-00d4-4ec7-8765-c5286b0c12ce','79d75cae-e513-4d91-935d-c2888886bbeb','c5a310e3-9810-48af-9d38-1093bcea453a',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('29bc1431-d041-4b1d-a715-af2161c546ea','bf331bb7-00d4-4ec7-8765-c5286b0c12ce','d535e27e-12a0-4986-b7f4-2c76007c2d97','c5a310e3-9810-48af-9d38-1093bcea453a',1),
	 ('7e993f99-560d-4f46-adde-3f8a9a8bb112','d535e27e-12a0-4986-b7f4-2c76007c2d97','bf331bb7-00d4-4ec7-8765-c5286b0c12ce','c5a310e3-9810-48af-9d38-1093bcea453a',1),
	 ('9bfed643-f1bd-41bb-9430-8d5c757031ef','d535e27e-12a0-4986-b7f4-2c76007c2d97','e8c9d9c6-471e-4371-b8b6-ab97f0b00bd7','c5a310e3-9810-48af-9d38-1093bcea453a',2),
	 ('d8b8b811-4202-43e3-ba6f-eb6a8415d5f7','e8c9d9c6-471e-4371-b8b6-ab97f0b00bd7','d535e27e-12a0-4986-b7f4-2c76007c2d97','c5a310e3-9810-48af-9d38-1093bcea453a',2),
	 ('9caec70d-ef4b-4549-a1e8-d1c7ca0ae195','e8c9d9c6-471e-4371-b8b6-ab97f0b00bd7','396a78a8-9374-4219-b803-179f4e7c73ac','c5a310e3-9810-48af-9d38-1093bcea453a',1),
	 ('169d5608-7474-4bd3-a887-844e12ad5999','396a78a8-9374-4219-b803-179f4e7c73ac','e8c9d9c6-471e-4371-b8b6-ab97f0b00bd7','c5a310e3-9810-48af-9d38-1093bcea453a',1),
	 ('89d94bb9-3de7-4f9b-a987-41eef5ab3e4d','396a78a8-9374-4219-b803-179f4e7c73ac','fd939834-4817-4a74-a067-f0ce92c66d4b','c5a310e3-9810-48af-9d38-1093bcea453a',1),
	 ('0ebe6993-82e7-45c6-be71-55234bc1f4d6','fd939834-4817-4a74-a067-f0ce92c66d4b','396a78a8-9374-4219-b803-179f4e7c73ac','c5a310e3-9810-48af-9d38-1093bcea453a',1),
	 ('2b8096f3-47ed-470f-b2f5-517935c3acbb','fd939834-4817-4a74-a067-f0ce92c66d4b','d4463c35-ef6c-4d36-b043-e40f5675a932','c5a310e3-9810-48af-9d38-1093bcea453a',2),
	 ('46edfe8d-d3d6-4257-86e7-5f57c3a25f81','d4463c35-ef6c-4d36-b043-e40f5675a932','fd939834-4817-4a74-a067-f0ce92c66d4b','c5a310e3-9810-48af-9d38-1093bcea453a',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('66150740-b134-477d-870f-a8fd2e969cd6','d4463c35-ef6c-4d36-b043-e40f5675a932','6b89a6e7-642c-492b-a1a8-6ee7e26372a4','c5a310e3-9810-48af-9d38-1093bcea453a',1),
	 ('0bd721ea-b95f-4215-8ef6-3bc2be255e55','6b89a6e7-642c-492b-a1a8-6ee7e26372a4','d4463c35-ef6c-4d36-b043-e40f5675a932','c5a310e3-9810-48af-9d38-1093bcea453a',1),
	 ('36591759-d9b5-483f-9957-7f1a3a904ae6','6b89a6e7-642c-492b-a1a8-6ee7e26372a4','276040f5-c6d9-4493-adb5-094395cd0afb','c5a310e3-9810-48af-9d38-1093bcea453a',2),
	 ('748fbcbf-021a-492e-b9d1-933140b18cdc','276040f5-c6d9-4493-adb5-094395cd0afb','6b89a6e7-642c-492b-a1a8-6ee7e26372a4','c5a310e3-9810-48af-9d38-1093bcea453a',2),
	 ('f41bb349-8749-4b8d-9b4c-349b922fa1b0','276040f5-c6d9-4493-adb5-094395cd0afb','c5dcfbd1-6c15-4a75-8506-a187513abd5b','c5a310e3-9810-48af-9d38-1093bcea453a',1),
	 ('8ace0515-5511-454e-9868-df9b38378c8b','c5dcfbd1-6c15-4a75-8506-a187513abd5b','276040f5-c6d9-4493-adb5-094395cd0afb','c5a310e3-9810-48af-9d38-1093bcea453a',1),
	 ('a3790c25-0423-40ab-8e90-f7bac4b83f09','c5dcfbd1-6c15-4a75-8506-a187513abd5b','f57c6300-581e-46e7-9fe5-dbb42a462aec','c5a310e3-9810-48af-9d38-1093bcea453a',2),
	 ('a44178ba-4e68-4391-9a38-627c178521dd','f57c6300-581e-46e7-9fe5-dbb42a462aec','c5dcfbd1-6c15-4a75-8506-a187513abd5b','c5a310e3-9810-48af-9d38-1093bcea453a',2),
	 ('9899e94a-6831-4988-a91d-e673d5c81b49','f57c6300-581e-46e7-9fe5-dbb42a462aec','679cb32d-9ea0-4370-b6be-ce788665eaed','c5a310e3-9810-48af-9d38-1093bcea453a',1),
	 ('851ea101-6580-4c0e-a93e-a2131621bc72','679cb32d-9ea0-4370-b6be-ce788665eaed','f57c6300-581e-46e7-9fe5-dbb42a462aec','c5a310e3-9810-48af-9d38-1093bcea453a',1);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('2fe5ad9e-1dd9-486b-8c46-d3edc72a0707','679cb32d-9ea0-4370-b6be-ce788665eaed','e1319b9e-1b71-4747-8c19-f5523b4bce0b','c5a310e3-9810-48af-9d38-1093bcea453a',2),
	 ('f0f67467-4ad3-4faa-af5c-f97abaf9ef52','e1319b9e-1b71-4747-8c19-f5523b4bce0b','679cb32d-9ea0-4370-b6be-ce788665eaed','c5a310e3-9810-48af-9d38-1093bcea453a',2),
	 ('b5b7f82b-85b3-4d68-96e1-a942770cad73','e1319b9e-1b71-4747-8c19-f5523b4bce0b','1200ed45-5bb1-4ff1-bee8-a81c919ce76e','c5a310e3-9810-48af-9d38-1093bcea453a',1),
	 ('ba0e2775-531a-44c6-a601-56d3a849def0','1200ed45-5bb1-4ff1-bee8-a81c919ce76e','e1319b9e-1b71-4747-8c19-f5523b4bce0b','c5a310e3-9810-48af-9d38-1093bcea453a',1),
	 ('f2626530-1212-47c5-9578-cd8b1349fc19','1200ed45-5bb1-4ff1-bee8-a81c919ce76e','6541b1a4-dffb-4981-8340-fab6c4aa1cea','c5a310e3-9810-48af-9d38-1093bcea453a',1),
	 ('5fc2d537-f72b-4a3a-88c5-59e87a5d86b0','6541b1a4-dffb-4981-8340-fab6c4aa1cea','1200ed45-5bb1-4ff1-bee8-a81c919ce76e','c5a310e3-9810-48af-9d38-1093bcea453a',1),
	 ('d5028ff8-3a2d-44c4-90aa-4942ce211684','6541b1a4-dffb-4981-8340-fab6c4aa1cea','f65f522d-fb87-4990-9484-ae4c328935f0','c5a310e3-9810-48af-9d38-1093bcea453a',2),
	 ('b5b51cd5-8b59-416d-879b-e7a2cedd4353','f65f522d-fb87-4990-9484-ae4c328935f0','6541b1a4-dffb-4981-8340-fab6c4aa1cea','c5a310e3-9810-48af-9d38-1093bcea453a',2),
	 ('6fbc4b54-51ee-44b6-b84f-428d808fd4b3','b5784e61-d318-4d65-83ad-f3be2b58a8fd','5fd3776d-c2c7-49f4-baf6-00e1293c1816','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',3),
	 ('7b7cf5b6-ef99-44e1-be08-6fa82cd47bec','5fd3776d-c2c7-49f4-baf6-00e1293c1816','b5784e61-d318-4d65-83ad-f3be2b58a8fd','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',3);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('7ac43e77-6d74-467d-ab89-b8735f7fa6ab','5fd3776d-c2c7-49f4-baf6-00e1293c1816','60a13dd9-e542-45d3-bc80-5cce51f34a10','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',3),
	 ('5132fef0-8d90-4d97-8060-86a8bfcef872','60a13dd9-e542-45d3-bc80-5cce51f34a10','5fd3776d-c2c7-49f4-baf6-00e1293c1816','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',3),
	 ('9cefc564-dee3-4c88-b327-b6ec238eaaca','60a13dd9-e542-45d3-bc80-5cce51f34a10','7f0267ab-015b-43c0-aab5-b0a5457f9ea5','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',1),
	 ('27d1da38-2eaf-4cf1-bb7b-7fac35a79c53','7f0267ab-015b-43c0-aab5-b0a5457f9ea5','60a13dd9-e542-45d3-bc80-5cce51f34a10','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',1),
	 ('c7b40ccb-7d88-4658-b21b-9774532e72b7','7f0267ab-015b-43c0-aab5-b0a5457f9ea5','6727a5b9-1b41-4754-997e-e8b7bfa9c781','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',3),
	 ('8a546c25-f5c8-474f-903d-5adf5f82c947','6727a5b9-1b41-4754-997e-e8b7bfa9c781','7f0267ab-015b-43c0-aab5-b0a5457f9ea5','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',3),
	 ('e437dab6-ed22-4215-af99-dac86500cfb5','6727a5b9-1b41-4754-997e-e8b7bfa9c781','650ac789-b6b5-4d5b-aeb0-cc9629cf42fb','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',3),
	 ('82663a6d-6aa1-48a8-aaba-d27fa3e0bd58','650ac789-b6b5-4d5b-aeb0-cc9629cf42fb','6727a5b9-1b41-4754-997e-e8b7bfa9c781','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',3),
	 ('7a540511-f45d-4059-b584-e2f3fedec26e','650ac789-b6b5-4d5b-aeb0-cc9629cf42fb','88e2fb0f-4066-4971-9e8b-a6b243c91b15','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',4),
	 ('1c1006b0-7c3c-43d7-9bfe-2ced4954883b','88e2fb0f-4066-4971-9e8b-a6b243c91b15','650ac789-b6b5-4d5b-aeb0-cc9629cf42fb','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',4);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('d3007364-02ec-4092-a3d3-71fe9e11563d','88e2fb0f-4066-4971-9e8b-a6b243c91b15','473f5432-69f5-4b99-b48a-9f3a486cf886','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',3),
	 ('90c7a2b7-ed94-4f3f-883d-2460b30a735d','473f5432-69f5-4b99-b48a-9f3a486cf886','88e2fb0f-4066-4971-9e8b-a6b243c91b15','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',3),
	 ('b2c50887-32a1-4e48-a6e2-4af7bb413280','473f5432-69f5-4b99-b48a-9f3a486cf886','1200ed45-5bb1-4ff1-bee8-a81c919ce76e','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',2),
	 ('865a9271-487a-4710-84ec-acd504d8d0d8','1200ed45-5bb1-4ff1-bee8-a81c919ce76e','473f5432-69f5-4b99-b48a-9f3a486cf886','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',2),
	 ('b5b926bd-c797-49d5-8865-77485c500720','1200ed45-5bb1-4ff1-bee8-a81c919ce76e','f65f522d-fb87-4990-9484-ae4c328935f0','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',3),
	 ('1e3cc590-e1f7-4617-8414-4c285f5658fc','f65f522d-fb87-4990-9484-ae4c328935f0','1200ed45-5bb1-4ff1-bee8-a81c919ce76e','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',3),
	 ('af03200d-db9c-4b40-bfab-37ab2ef54388','f65f522d-fb87-4990-9484-ae4c328935f0','bd6620ec-e38d-4e97-bfd1-e252fcd34917','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',3),
	 ('ad39ba0f-45e9-4177-88bf-48d65577c7ec','bd6620ec-e38d-4e97-bfd1-e252fcd34917','f65f522d-fb87-4990-9484-ae4c328935f0','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',3),
	 ('2b06e3c9-8f07-4b2a-8887-cae8f7243b0e','bd6620ec-e38d-4e97-bfd1-e252fcd34917','518c4e51-c4ff-4bff-b96d-bec8d0957829','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',4),
	 ('a1a926ae-bcfc-4729-a873-48b5bff6ba5f','518c4e51-c4ff-4bff-b96d-bec8d0957829','bd6620ec-e38d-4e97-bfd1-e252fcd34917','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',4);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('f9d0d71b-354e-42c4-a538-3ee24c2f805c','518c4e51-c4ff-4bff-b96d-bec8d0957829','372d17a9-e164-46cc-bfc9-8d9529dfba48','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',4),
	 ('45f19339-8615-47e7-b369-c0902bda7073','372d17a9-e164-46cc-bfc9-8d9529dfba48','518c4e51-c4ff-4bff-b96d-bec8d0957829','26fd0f86-ab19-4c9c-8b1a-c63485dc11ac',4),
	 ('d14beb13-8e8e-440f-b14e-3eb3d41013d9','1200ed45-5bb1-4ff1-bee8-a81c919ce76e','05e45d5b-beb5-4ceb-a43f-2e4068a32914','c0abfff2-2bf5-40fc-88b6-631a92f91c1f',5),
	 ('272dac7a-44a4-4a8b-852a-fe70013fa938','05e45d5b-beb5-4ceb-a43f-2e4068a32914','1200ed45-5bb1-4ff1-bee8-a81c919ce76e','c0abfff2-2bf5-40fc-88b6-631a92f91c1f',5),
	 ('8427731b-80f0-4aac-bf19-455a3f4871c1','05e45d5b-beb5-4ceb-a43f-2e4068a32914','050d3e18-51eb-4cc9-ae19-225ab18b9141','c0abfff2-2bf5-40fc-88b6-631a92f91c1f',4),
	 ('2bd49383-3905-492e-966a-42e4f7a720c2','050d3e18-51eb-4cc9-ae19-225ab18b9141','05e45d5b-beb5-4ceb-a43f-2e4068a32914','c0abfff2-2bf5-40fc-88b6-631a92f91c1f',4),
	 ('0ccbee67-23da-47bd-855e-bf61009d71f7','050d3e18-51eb-4cc9-ae19-225ab18b9141','94f12de9-f9b3-4e32-ba0d-fefb513b4d50','c0abfff2-2bf5-40fc-88b6-631a92f91c1f',2),
	 ('8269b8a4-e3e5-41aa-8ea1-267f5c4ffb77','94f12de9-f9b3-4e32-ba0d-fefb513b4d50','050d3e18-51eb-4cc9-ae19-225ab18b9141','c0abfff2-2bf5-40fc-88b6-631a92f91c1f',2),
	 ('f1c99248-2f54-4c92-9950-8fb819c7cbc1','94f12de9-f9b3-4e32-ba0d-fefb513b4d50','6b878017-9ab9-43ba-9dc5-ef050907867e','c0abfff2-2bf5-40fc-88b6-631a92f91c1f',2),
	 ('5be2411a-c648-4833-a4bb-3f838163fc5a','6b878017-9ab9-43ba-9dc5-ef050907867e','94f12de9-f9b3-4e32-ba0d-fefb513b4d50','c0abfff2-2bf5-40fc-88b6-631a92f91c1f',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('18a467d1-60a7-4578-8a35-80585eb5e097','6b878017-9ab9-43ba-9dc5-ef050907867e','29e31449-8c9f-4978-9c96-7e8fbba07063','c0abfff2-2bf5-40fc-88b6-631a92f91c1f',3),
	 ('e077f832-7eb1-4245-aab5-1cde9415498f','29e31449-8c9f-4978-9c96-7e8fbba07063','6b878017-9ab9-43ba-9dc5-ef050907867e','c0abfff2-2bf5-40fc-88b6-631a92f91c1f',3),
	 ('ef8d8cec-1abf-42da-ace1-3c7757fbfbfd','29e31449-8c9f-4978-9c96-7e8fbba07063','22b98b73-3a3e-438b-9544-29ed32a718d5','c0abfff2-2bf5-40fc-88b6-631a92f91c1f',3),
	 ('91c4a4b6-036a-4300-a17a-39247c14b1e2','22b98b73-3a3e-438b-9544-29ed32a718d5','29e31449-8c9f-4978-9c96-7e8fbba07063','c0abfff2-2bf5-40fc-88b6-631a92f91c1f',3),
	 ('d673528f-3e0a-4e1b-be45-1c0043c06bd0','22b98b73-3a3e-438b-9544-29ed32a718d5','a8b4ab3b-2b14-450f-a9c4-2c0bb363aa55','c0abfff2-2bf5-40fc-88b6-631a92f91c1f',2),
	 ('9b5d6d56-790d-420e-b5dd-1adcfeb5a7f0','a8b4ab3b-2b14-450f-a9c4-2c0bb363aa55','22b98b73-3a3e-438b-9544-29ed32a718d5','c0abfff2-2bf5-40fc-88b6-631a92f91c1f',2),
	 ('1f967a26-8011-437c-80e7-aa9f6f3617ba','a8b4ab3b-2b14-450f-a9c4-2c0bb363aa55','5b1689a7-ee26-4901-9077-404aeb0dcf4b','c0abfff2-2bf5-40fc-88b6-631a92f91c1f',3),
	 ('6d294448-a8df-40e3-87d5-e1d58f6cb41d','5b1689a7-ee26-4901-9077-404aeb0dcf4b','a8b4ab3b-2b14-450f-a9c4-2c0bb363aa55','c0abfff2-2bf5-40fc-88b6-631a92f91c1f',3),
	 ('5020aadb-7d2c-4a8e-b8e2-6c9ecaf3a04a','5b1689a7-ee26-4901-9077-404aeb0dcf4b','17d89c74-90fa-4a71-b6e7-754c8f119837','c0abfff2-2bf5-40fc-88b6-631a92f91c1f',4),
	 ('f5de509d-8e99-420c-8e68-d285eef16613','17d89c74-90fa-4a71-b6e7-754c8f119837','5b1689a7-ee26-4901-9077-404aeb0dcf4b','c0abfff2-2bf5-40fc-88b6-631a92f91c1f',4);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('beaf409c-4516-4416-9966-7ab8a671f270','88e2fb0f-4066-4971-9e8b-a6b243c91b15','646c2e02-0f1c-47a2-a3d3-32dcb3236a21','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',3),
	 ('2efe4a54-25bb-4dca-a3eb-e7114e2596cd','646c2e02-0f1c-47a2-a3d3-32dcb3236a21','88e2fb0f-4066-4971-9e8b-a6b243c91b15','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',3),
	 ('135fcbd4-3efd-4e82-850f-8cfdbf919633','646c2e02-0f1c-47a2-a3d3-32dcb3236a21','523cf481-beab-4390-b6aa-88071466a00b','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1),
	 ('e388c09c-d813-45ba-96c3-6f59faef58df','523cf481-beab-4390-b6aa-88071466a00b','646c2e02-0f1c-47a2-a3d3-32dcb3236a21','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1),
	 ('67051f0b-7341-4e57-9785-3bec9b4ecf86','523cf481-beab-4390-b6aa-88071466a00b','d1bc19f9-22a0-46e0-80c3-2d3562b532a9','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1),
	 ('44fdd5d8-c299-4c92-9dbd-088453b76f7d','d1bc19f9-22a0-46e0-80c3-2d3562b532a9','523cf481-beab-4390-b6aa-88071466a00b','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1),
	 ('51086b0a-98b1-4649-9415-74ebd6842a30','d1bc19f9-22a0-46e0-80c3-2d3562b532a9','377aca77-3a86-4db3-8ac9-8edfba29ac1b','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1),
	 ('43f14556-836a-4872-8cbe-94d6a9bbfc88','377aca77-3a86-4db3-8ac9-8edfba29ac1b','d1bc19f9-22a0-46e0-80c3-2d3562b532a9','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1),
	 ('f09dd6a0-298c-4686-9943-b983c272636e','377aca77-3a86-4db3-8ac9-8edfba29ac1b','d4ad7f12-2271-4048-81ce-eb1af4bf3499','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',2),
	 ('7a1adc64-8356-4f3e-bb2c-638e528d9028','d4ad7f12-2271-4048-81ce-eb1af4bf3499','377aca77-3a86-4db3-8ac9-8edfba29ac1b','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('d03a8646-86e3-45ca-8ad0-8445ce3e312a','d4ad7f12-2271-4048-81ce-eb1af4bf3499','0053bfee-a344-43f9-98c5-ec9ed73eb4cc','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1),
	 ('036eaaaf-5031-4a90-aa9a-24785b4b4ee1','0053bfee-a344-43f9-98c5-ec9ed73eb4cc','d4ad7f12-2271-4048-81ce-eb1af4bf3499','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1),
	 ('f7939da7-1cef-416d-afed-d4127ea2440a','0053bfee-a344-43f9-98c5-ec9ed73eb4cc','34607a50-8813-4793-a8c5-5426e5d7ea50','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',2),
	 ('09c4b6c3-1e66-44f8-9716-6a3ef0bf439d','34607a50-8813-4793-a8c5-5426e5d7ea50','0053bfee-a344-43f9-98c5-ec9ed73eb4cc','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',2),
	 ('e6ef9fc0-6cab-4b81-b4f2-51f848e447f1','34607a50-8813-4793-a8c5-5426e5d7ea50','46258255-e192-4c87-944c-278678ec408a','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1),
	 ('42c7194b-1584-44c0-a509-31cc36988eb7','46258255-e192-4c87-944c-278678ec408a','34607a50-8813-4793-a8c5-5426e5d7ea50','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1),
	 ('ee597122-6410-4e34-a82c-95594669beb2','46258255-e192-4c87-944c-278678ec408a','d827f72a-5fe0-46c3-8280-c84934e6c057','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',2),
	 ('14e4d9d8-c77e-4ca4-b51f-e8a7d62e4245','d827f72a-5fe0-46c3-8280-c84934e6c057','46258255-e192-4c87-944c-278678ec408a','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',2),
	 ('66be3b5b-8f9b-4854-9ef7-d51c3c20c83b','d827f72a-5fe0-46c3-8280-c84934e6c057','7a3233ec-51a0-4983-ba04-512fcd5c2123','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',2),
	 ('a48b4370-aa57-421b-8c3e-ab32639ecb95','7a3233ec-51a0-4983-ba04-512fcd5c2123','d827f72a-5fe0-46c3-8280-c84934e6c057','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('dbcb319a-8a62-40b9-ba84-338b20e60ccd','7a3233ec-51a0-4983-ba04-512fcd5c2123','057990ab-37ad-4292-8de7-dffb2ee9f0b7','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',2),
	 ('2daae278-bc07-4cc7-9d9e-f8b514fb3eae','057990ab-37ad-4292-8de7-dffb2ee9f0b7','7a3233ec-51a0-4983-ba04-512fcd5c2123','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',2),
	 ('e761df86-4fde-400f-804a-c59e74c0e65e','057990ab-37ad-4292-8de7-dffb2ee9f0b7','ee88bbde-3cb5-4d96-8b2c-6d6eb36b037b','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',2),
	 ('feb4ae0a-b38e-48d2-8890-68160945a7da','ee88bbde-3cb5-4d96-8b2c-6d6eb36b037b','057990ab-37ad-4292-8de7-dffb2ee9f0b7','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',2),
	 ('f8dc082b-c8dd-476d-aa24-374882aa1f1c','ee88bbde-3cb5-4d96-8b2c-6d6eb36b037b','785209f7-0817-4fbe-93fc-44e4a2c7e0ab','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1),
	 ('da22974b-8546-4b5b-96da-a825070631e1','785209f7-0817-4fbe-93fc-44e4a2c7e0ab','ee88bbde-3cb5-4d96-8b2c-6d6eb36b037b','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1),
	 ('60fed679-4a59-4997-bfc4-e47aa846dcfa','785209f7-0817-4fbe-93fc-44e4a2c7e0ab','f352e06b-e1fe-45e8-81f6-5aef1dc26bfe','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1),
	 ('71ca453e-b313-4d8d-82a1-441ac6e02620','f352e06b-e1fe-45e8-81f6-5aef1dc26bfe','785209f7-0817-4fbe-93fc-44e4a2c7e0ab','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1),
	 ('f119121e-2869-42e8-bb84-27c9e110cde7','f352e06b-e1fe-45e8-81f6-5aef1dc26bfe','485d5ec3-1c57-45bf-b010-1141c327c390','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',2),
	 ('be1426e7-1760-41e4-ad1c-8aba20256cc3','485d5ec3-1c57-45bf-b010-1141c327c390','f352e06b-e1fe-45e8-81f6-5aef1dc26bfe','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('8110e961-e07f-4377-b414-9c2926b29ab6','485d5ec3-1c57-45bf-b010-1141c327c390','deb8f5fd-561e-41ff-bbb6-458468899edf','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1),
	 ('bcbd8c01-c5d5-40ee-a9ad-cfd48f502c04','deb8f5fd-561e-41ff-bbb6-458468899edf','485d5ec3-1c57-45bf-b010-1141c327c390','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1),
	 ('a16d77a9-28c4-4961-bbcf-fb3098fbaadf','deb8f5fd-561e-41ff-bbb6-458468899edf','c6a60c79-7602-46cf-8f1b-48f256def58b','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',2),
	 ('2e2016d1-8d05-400b-84ef-9b80d8b171d3','c6a60c79-7602-46cf-8f1b-48f256def58b','deb8f5fd-561e-41ff-bbb6-458468899edf','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',2),
	 ('210dbed5-ff65-4f84-9713-116d7977ed2b','c6a60c79-7602-46cf-8f1b-48f256def58b','e852a593-0f96-4c8b-bfaf-b0a2e29db291','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1),
	 ('bc7cd1a7-2ea6-47a5-beb2-fd22ed25e4d1','e852a593-0f96-4c8b-bfaf-b0a2e29db291','c6a60c79-7602-46cf-8f1b-48f256def58b','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1),
	 ('d6bc9752-f324-4a69-8861-b1eadc33a223','e852a593-0f96-4c8b-bfaf-b0a2e29db291','9f42d846-9a87-459d-8957-6429ec0802e7','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1),
	 ('7ffa63bf-24a1-4ae0-93a0-465aaebe8060','9f42d846-9a87-459d-8957-6429ec0802e7','e852a593-0f96-4c8b-bfaf-b0a2e29db291','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1),
	 ('9962aebe-c7c3-4321-b159-bf5aee11a42f','9f42d846-9a87-459d-8957-6429ec0802e7','6232f274-5db6-4652-b3f4-7e83c24aa110','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1),
	 ('c3598f7e-75a4-4a25-b8f0-9b6e0b263fed','6232f274-5db6-4652-b3f4-7e83c24aa110','9f42d846-9a87-459d-8957-6429ec0802e7','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('a8d559da-1661-40cd-a485-32ecef063aa5','6232f274-5db6-4652-b3f4-7e83c24aa110','b6176390-b2f1-4532-841a-fee43355da3e','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',2),
	 ('bd97dbe1-7df3-465c-b1c9-42ea4f478484','b6176390-b2f1-4532-841a-fee43355da3e','6232f274-5db6-4652-b3f4-7e83c24aa110','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',2),
	 ('fb729a49-2a32-4439-b23f-0e1751583727','b6176390-b2f1-4532-841a-fee43355da3e','d535e27e-12a0-4986-b7f4-2c76007c2d97','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1),
	 ('34aab583-9709-49ab-a59e-e50f8dc16647','d535e27e-12a0-4986-b7f4-2c76007c2d97','b6176390-b2f1-4532-841a-fee43355da3e','f93fc46f-97d0-4f2d-8557-05ca9ba4992a',1),
	 ('5eb657cb-a7db-4ab4-94d1-30d0629f362f','e8c9d9c6-471e-4371-b8b6-ab97f0b00bd7','8fba4771-98d8-46f6-ae3b-3ab0de7bd461','24d135a5-9f98-494c-8cc0-6970ef7943e2',1),
	 ('4ff15c13-409d-431d-84fa-b3cc75771015','8fba4771-98d8-46f6-ae3b-3ab0de7bd461','e8c9d9c6-471e-4371-b8b6-ab97f0b00bd7','24d135a5-9f98-494c-8cc0-6970ef7943e2',1),
	 ('3a96de14-cd5f-472c-ab4f-6c83289f1140','8fba4771-98d8-46f6-ae3b-3ab0de7bd461','d535e27e-12a0-4986-b7f4-2c76007c2d97','24d135a5-9f98-494c-8cc0-6970ef7943e2',3),
	 ('e5a1f2e9-cad7-43c7-aaa0-8c9c9257afdd','d535e27e-12a0-4986-b7f4-2c76007c2d97','8fba4771-98d8-46f6-ae3b-3ab0de7bd461','24d135a5-9f98-494c-8cc0-6970ef7943e2',3),
	 ('7801ef55-7079-4922-b76c-e4b66d36d707','d535e27e-12a0-4986-b7f4-2c76007c2d97','c1f4ef91-eb61-4d4c-9687-84c080196db4','24d135a5-9f98-494c-8cc0-6970ef7943e2',1),
	 ('2018aec5-5fad-409a-b8f5-517f3df4ef2b','c1f4ef91-eb61-4d4c-9687-84c080196db4','d535e27e-12a0-4986-b7f4-2c76007c2d97','24d135a5-9f98-494c-8cc0-6970ef7943e2',1);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('9936403e-b3e6-400a-869a-cfed47809a9a','c1f4ef91-eb61-4d4c-9687-84c080196db4','bf331bb7-00d4-4ec7-8765-c5286b0c12ce','24d135a5-9f98-494c-8cc0-6970ef7943e2',2),
	 ('172e3c5d-f0c8-46ef-8dfe-fb96e4fb12d9','bf331bb7-00d4-4ec7-8765-c5286b0c12ce','c1f4ef91-eb61-4d4c-9687-84c080196db4','24d135a5-9f98-494c-8cc0-6970ef7943e2',2),
	 ('01ccad4f-f181-4754-913a-ec54b77b7334','bf331bb7-00d4-4ec7-8765-c5286b0c12ce','6ddfd002-b55d-4686-92f3-bf02baf32927','24d135a5-9f98-494c-8cc0-6970ef7943e2',1),
	 ('c675fbf0-a838-4796-bce9-e40e220ac6f3','6ddfd002-b55d-4686-92f3-bf02baf32927','bf331bb7-00d4-4ec7-8765-c5286b0c12ce','24d135a5-9f98-494c-8cc0-6970ef7943e2',1),
	 ('d45c5b6c-7f4f-4089-8081-e9d710bb97df','6ddfd002-b55d-4686-92f3-bf02baf32927','37bb3630-6298-4ccd-9ae2-d072692c0b05','24d135a5-9f98-494c-8cc0-6970ef7943e2',2),
	 ('1d724358-5169-45f7-9785-45a9ad28ec07','37bb3630-6298-4ccd-9ae2-d072692c0b05','6ddfd002-b55d-4686-92f3-bf02baf32927','24d135a5-9f98-494c-8cc0-6970ef7943e2',2),
	 ('bc943580-2584-4783-8e33-2a98c85ce219','37bb3630-6298-4ccd-9ae2-d072692c0b05','bff2d85e-e32d-4e10-b4f3-9940984a64b4','24d135a5-9f98-494c-8cc0-6970ef7943e2',2),
	 ('0ebf81bb-217e-4acd-99f0-e03bf690fe6d','bff2d85e-e32d-4e10-b4f3-9940984a64b4','37bb3630-6298-4ccd-9ae2-d072692c0b05','24d135a5-9f98-494c-8cc0-6970ef7943e2',2),
	 ('4653fc29-4c19-46f3-91bc-cbd49b884441','bff2d85e-e32d-4e10-b4f3-9940984a64b4','5fd3776d-c2c7-49f4-baf6-00e1293c1816','24d135a5-9f98-494c-8cc0-6970ef7943e2',2),
	 ('4a80cc16-81cb-4971-bd7d-a49bbd9fe461','5fd3776d-c2c7-49f4-baf6-00e1293c1816','bff2d85e-e32d-4e10-b4f3-9940984a64b4','24d135a5-9f98-494c-8cc0-6970ef7943e2',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('81b2af0c-f6b6-4d4a-b29c-87a4a9f99972','5fd3776d-c2c7-49f4-baf6-00e1293c1816','1d429c8a-2006-403b-a458-710b698eaad4','24d135a5-9f98-494c-8cc0-6970ef7943e2',2),
	 ('81d065cd-293b-40e9-8d41-296bea5c1469','1d429c8a-2006-403b-a458-710b698eaad4','5fd3776d-c2c7-49f4-baf6-00e1293c1816','24d135a5-9f98-494c-8cc0-6970ef7943e2',2),
	 ('61e05be4-cba8-43c4-bea3-da8388646f29','1d429c8a-2006-403b-a458-710b698eaad4','5925c993-f22d-420c-8cc4-c133575ddc4c','24d135a5-9f98-494c-8cc0-6970ef7943e2',1),
	 ('1a5f8cef-1da3-4619-8fbc-c1e980c6decb','5925c993-f22d-420c-8cc4-c133575ddc4c','1d429c8a-2006-403b-a458-710b698eaad4','24d135a5-9f98-494c-8cc0-6970ef7943e2',1),
	 ('42b6d04a-b1f7-4831-8c9f-8b84f6ce1c71','5925c993-f22d-420c-8cc4-c133575ddc4c','60a13dd9-e542-45d3-bc80-5cce51f34a10','24d135a5-9f98-494c-8cc0-6970ef7943e2',1),
	 ('e1733e9f-d26e-4f02-9065-1e48549a58a4','60a13dd9-e542-45d3-bc80-5cce51f34a10','5925c993-f22d-420c-8cc4-c133575ddc4c','24d135a5-9f98-494c-8cc0-6970ef7943e2',1),
	 ('c9380fb2-ce5c-4251-a889-8bbb55d61943','60a13dd9-e542-45d3-bc80-5cce51f34a10','7f0267ab-015b-43c0-aab5-b0a5457f9ea5','24d135a5-9f98-494c-8cc0-6970ef7943e2',3),
	 ('c7741ab9-a682-4750-99ea-2e567ad7edd0','7f0267ab-015b-43c0-aab5-b0a5457f9ea5','60a13dd9-e542-45d3-bc80-5cce51f34a10','24d135a5-9f98-494c-8cc0-6970ef7943e2',3),
	 ('f83fc7ce-321a-403b-8dfa-0ae2290dfc07','7f0267ab-015b-43c0-aab5-b0a5457f9ea5','2181686c-3203-4dd6-8bf6-68db7d843299','24d135a5-9f98-494c-8cc0-6970ef7943e2',2),
	 ('5455d3d6-99cc-4cd6-9d81-1e240117c8d0','2181686c-3203-4dd6-8bf6-68db7d843299','7f0267ab-015b-43c0-aab5-b0a5457f9ea5','24d135a5-9f98-494c-8cc0-6970ef7943e2',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('72f6e98b-77d1-42c8-860f-235e7eaf96a9','2181686c-3203-4dd6-8bf6-68db7d843299','038491ec-c394-46d2-ba00-04ed66faa19b','24d135a5-9f98-494c-8cc0-6970ef7943e2',2),
	 ('827962b8-9d54-4fac-bbf7-dfa10b819366','038491ec-c394-46d2-ba00-04ed66faa19b','2181686c-3203-4dd6-8bf6-68db7d843299','24d135a5-9f98-494c-8cc0-6970ef7943e2',2),
	 ('20e8dee4-368a-476f-a6d5-6e7a9f5b201c','038491ec-c394-46d2-ba00-04ed66faa19b','34e1c12f-7320-43cc-a3bf-215ca340c7db','24d135a5-9f98-494c-8cc0-6970ef7943e2',1),
	 ('1d60e165-6239-46f2-bcd9-ccb4e70658ad','34e1c12f-7320-43cc-a3bf-215ca340c7db','038491ec-c394-46d2-ba00-04ed66faa19b','24d135a5-9f98-494c-8cc0-6970ef7943e2',1),
	 ('3dc57f91-f19b-42f2-bd00-e58f081811ee','34e1c12f-7320-43cc-a3bf-215ca340c7db','a9a77531-7b36-4a60-995c-2f9117881886','24d135a5-9f98-494c-8cc0-6970ef7943e2',2),
	 ('88ddb446-467b-439b-90fa-0ed30a9bfb50','a9a77531-7b36-4a60-995c-2f9117881886','34e1c12f-7320-43cc-a3bf-215ca340c7db','24d135a5-9f98-494c-8cc0-6970ef7943e2',2),
	 ('28451ef7-ff61-4c14-852c-8c09be9d5ea1','a9a77531-7b36-4a60-995c-2f9117881886','26b16271-eb27-4f12-83bd-f3ed88086d0b','24d135a5-9f98-494c-8cc0-6970ef7943e2',1),
	 ('11fe0c33-fd73-4cf8-a9fa-5d729e87b33f','26b16271-eb27-4f12-83bd-f3ed88086d0b','a9a77531-7b36-4a60-995c-2f9117881886','24d135a5-9f98-494c-8cc0-6970ef7943e2',1),
	 ('4257fee5-9182-457f-88d6-d88996b385e8','26b16271-eb27-4f12-83bd-f3ed88086d0b','e3cfbf49-c82f-463b-ada8-69c73b74d2fc','24d135a5-9f98-494c-8cc0-6970ef7943e2',2),
	 ('f3878c18-c715-4d9e-b8ea-8ae189a58b5b','e3cfbf49-c82f-463b-ada8-69c73b74d2fc','26b16271-eb27-4f12-83bd-f3ed88086d0b','24d135a5-9f98-494c-8cc0-6970ef7943e2',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('044eb1c9-fcda-422b-b357-fdb4c272e2bb','e3cfbf49-c82f-463b-ada8-69c73b74d2fc','57033cae-db98-4545-8cc0-74d62a8ad3e4','24d135a5-9f98-494c-8cc0-6970ef7943e2',1),
	 ('da01f56b-fe73-4d83-8939-af7505c37dc6','57033cae-db98-4545-8cc0-74d62a8ad3e4','e3cfbf49-c82f-463b-ada8-69c73b74d2fc','24d135a5-9f98-494c-8cc0-6970ef7943e2',1),
	 ('29bee5a4-d511-40c8-9548-91c1678b3ae3','f65f522d-fb87-4990-9484-ae4c328935f0','f31249f5-6f89-47b8-87cb-b30311111415','9fc734ba-bf6d-40cf-b7f8-aa68d68328e7',4),
	 ('4504fe33-2ec4-4c85-bf56-ebf8299e2492','f31249f5-6f89-47b8-87cb-b30311111415','f65f522d-fb87-4990-9484-ae4c328935f0','9fc734ba-bf6d-40cf-b7f8-aa68d68328e7',4),
	 ('70fb8fd4-be84-4069-832e-75074e04eeb7','f31249f5-6f89-47b8-87cb-b30311111415','841b13f7-7fb8-458b-b2e5-61ba8d0f4974','9fc734ba-bf6d-40cf-b7f8-aa68d68328e7',1),
	 ('ef79c180-cc9e-41d7-beb3-36e2beee4a63','841b13f7-7fb8-458b-b2e5-61ba8d0f4974','f31249f5-6f89-47b8-87cb-b30311111415','9fc734ba-bf6d-40cf-b7f8-aa68d68328e7',1),
	 ('5ef889d8-884e-4e46-bead-6baf54c86d88','841b13f7-7fb8-458b-b2e5-61ba8d0f4974','8b8bcab1-b0e5-41d4-9664-abce3569ed72','9fc734ba-bf6d-40cf-b7f8-aa68d68328e7',1),
	 ('292003a0-766d-441d-a4b2-b12811b8318f','8b8bcab1-b0e5-41d4-9664-abce3569ed72','841b13f7-7fb8-458b-b2e5-61ba8d0f4974','9fc734ba-bf6d-40cf-b7f8-aa68d68328e7',1),
	 ('887c292d-ee9c-4394-8ca8-382839ba61b5','8b8bcab1-b0e5-41d4-9664-abce3569ed72','3d8a392d-1753-43cd-8cbb-88df88cc672d','9fc734ba-bf6d-40cf-b7f8-aa68d68328e7',2),
	 ('2caf4cd3-0072-4488-89ef-d6b2d94b5dad','3d8a392d-1753-43cd-8cbb-88df88cc672d','8b8bcab1-b0e5-41d4-9664-abce3569ed72','9fc734ba-bf6d-40cf-b7f8-aa68d68328e7',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('d262d744-65ae-4516-a1fd-768b96fd9b24','3d8a392d-1753-43cd-8cbb-88df88cc672d','7b66ad8a-0439-4bd2-868e-4bb3b681e601','9fc734ba-bf6d-40cf-b7f8-aa68d68328e7',1),
	 ('acd26928-c083-4d9d-8b24-4638f1a1daba','7b66ad8a-0439-4bd2-868e-4bb3b681e601','3d8a392d-1753-43cd-8cbb-88df88cc672d','9fc734ba-bf6d-40cf-b7f8-aa68d68328e7',1),
	 ('dffd1601-10d1-4095-aaa1-90f75ffb530f','7b66ad8a-0439-4bd2-868e-4bb3b681e601','30f02a4b-5226-4144-a1a0-e5ede71f5e94','9fc734ba-bf6d-40cf-b7f8-aa68d68328e7',1),
	 ('56296d36-c502-40ff-b65b-5f54e75a0c87','30f02a4b-5226-4144-a1a0-e5ede71f5e94','7b66ad8a-0439-4bd2-868e-4bb3b681e601','9fc734ba-bf6d-40cf-b7f8-aa68d68328e7',1),
	 ('74b8b753-29a1-4560-ac44-59a1232881fa','30f02a4b-5226-4144-a1a0-e5ede71f5e94','02c61bb5-790a-4b22-8441-81f263da46ce','9fc734ba-bf6d-40cf-b7f8-aa68d68328e7',2),
	 ('0aab1b7f-587d-499f-bb7e-3357d4b05660','02c61bb5-790a-4b22-8441-81f263da46ce','30f02a4b-5226-4144-a1a0-e5ede71f5e94','9fc734ba-bf6d-40cf-b7f8-aa68d68328e7',2),
	 ('9789efe0-b2d8-4dfb-9170-8def6f10c9b4','02c61bb5-790a-4b22-8441-81f263da46ce','c1d68a72-4e30-4229-a7de-02b59ac62e93','9fc734ba-bf6d-40cf-b7f8-aa68d68328e7',1),
	 ('bc34b172-7a65-4ccc-8377-6c63b7cc6096','c1d68a72-4e30-4229-a7de-02b59ac62e93','02c61bb5-790a-4b22-8441-81f263da46ce','9fc734ba-bf6d-40cf-b7f8-aa68d68328e7',1),
	 ('5be1f74b-2285-4c72-9165-961421131b35','c1d68a72-4e30-4229-a7de-02b59ac62e93','cd6bd876-55d9-4786-9624-c79e2d6ad1e5','9fc734ba-bf6d-40cf-b7f8-aa68d68328e7',1),
	 ('c9a23c73-6274-4545-8da6-e2f1ae6ebd05','cd6bd876-55d9-4786-9624-c79e2d6ad1e5','c1d68a72-4e30-4229-a7de-02b59ac62e93','9fc734ba-bf6d-40cf-b7f8-aa68d68328e7',1);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('fc36af51-9d53-4912-9144-e08fd46102d7','cd6bd876-55d9-4786-9624-c79e2d6ad1e5','171b1612-44fc-4281-aa3a-1d79bf54d372','9fc734ba-bf6d-40cf-b7f8-aa68d68328e7',1),
	 ('c2431b9c-049d-4c09-822e-e1170c4ad2fe','171b1612-44fc-4281-aa3a-1d79bf54d372','cd6bd876-55d9-4786-9624-c79e2d6ad1e5','9fc734ba-bf6d-40cf-b7f8-aa68d68328e7',1),
	 ('dc266565-839f-4915-886d-879dd83813e4','171b1612-44fc-4281-aa3a-1d79bf54d372','6b319827-1b27-4b96-8ef5-9c0085c2a307','9fc734ba-bf6d-40cf-b7f8-aa68d68328e7',1),
	 ('0dafc9e9-d899-4068-930e-06280909cb9a','6b319827-1b27-4b96-8ef5-9c0085c2a307','171b1612-44fc-4281-aa3a-1d79bf54d372','9fc734ba-bf6d-40cf-b7f8-aa68d68328e7',1),
	 ('3acfeda8-45d8-4f36-a98f-48913ce4d522','4f35b01f-fab9-46cd-8d05-7d371e559374','30da0add-411e-4a5f-92b8-ff73fcb94f8a','41e0db4f-6115-439d-ba57-d3d948467790',1),
	 ('e4e4ed8f-4ec3-4ba9-b925-7fadc37d5ad6','30da0add-411e-4a5f-92b8-ff73fcb94f8a','4f35b01f-fab9-46cd-8d05-7d371e559374','41e0db4f-6115-439d-ba57-d3d948467790',1),
	 ('257f9685-0976-4b08-8ef6-9442ac6a7259','30da0add-411e-4a5f-92b8-ff73fcb94f8a','566e6cb8-0da5-4c1a-b824-ca1240aa5ce5','41e0db4f-6115-439d-ba57-d3d948467790',1),
	 ('51c5c82c-570a-4fef-b140-593bde825e16','566e6cb8-0da5-4c1a-b824-ca1240aa5ce5','30da0add-411e-4a5f-92b8-ff73fcb94f8a','41e0db4f-6115-439d-ba57-d3d948467790',1),
	 ('ae9d2927-b585-43de-bb36-6b7577681e9a','566e6cb8-0da5-4c1a-b824-ca1240aa5ce5','95f2d11e-67e9-45e7-b2e8-42435f449681','41e0db4f-6115-439d-ba57-d3d948467790',1),
	 ('f39a6cf1-7cc2-4b7f-b12c-917f667e988e','95f2d11e-67e9-45e7-b2e8-42435f449681','566e6cb8-0da5-4c1a-b824-ca1240aa5ce5','41e0db4f-6115-439d-ba57-d3d948467790',1);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('7f86a14c-36ea-4a89-9668-8bb32d41a234','95f2d11e-67e9-45e7-b2e8-42435f449681','65b78460-f765-472f-b591-69bd502a1113','41e0db4f-6115-439d-ba57-d3d948467790',1),
	 ('d95e8254-c90c-401f-bee1-47d4c5117db9','65b78460-f765-472f-b591-69bd502a1113','95f2d11e-67e9-45e7-b2e8-42435f449681','41e0db4f-6115-439d-ba57-d3d948467790',1),
	 ('68bc1a96-da59-48b0-9d97-86aff43188d3','65b78460-f765-472f-b591-69bd502a1113','608e19cc-c7c5-4dfc-b8f7-f4b515179a03','41e0db4f-6115-439d-ba57-d3d948467790',2),
	 ('f3333e80-240b-4f52-abcb-c724d8d97ea1','608e19cc-c7c5-4dfc-b8f7-f4b515179a03','65b78460-f765-472f-b591-69bd502a1113','41e0db4f-6115-439d-ba57-d3d948467790',2),
	 ('d6110ee3-a27b-41c6-802f-a2b06bcecf2f','608e19cc-c7c5-4dfc-b8f7-f4b515179a03','fa750848-07f3-4b97-bd45-6184d3a13e64','41e0db4f-6115-439d-ba57-d3d948467790',1),
	 ('e39cafa3-2516-44c3-8dc2-89333eb39f4d','fa750848-07f3-4b97-bd45-6184d3a13e64','608e19cc-c7c5-4dfc-b8f7-f4b515179a03','41e0db4f-6115-439d-ba57-d3d948467790',1),
	 ('0834cad6-8658-4d07-8547-b625d5d5a8d0','fa750848-07f3-4b97-bd45-6184d3a13e64','30b92e74-a659-4291-a8f2-910ff2b3d951','41e0db4f-6115-439d-ba57-d3d948467790',1),
	 ('6615eeb2-34de-4dcd-a562-7ef95a6c85a9','30b92e74-a659-4291-a8f2-910ff2b3d951','fa750848-07f3-4b97-bd45-6184d3a13e64','41e0db4f-6115-439d-ba57-d3d948467790',1),
	 ('9fdeb739-bc5e-4e41-8a9f-24c1459c5231','30b92e74-a659-4291-a8f2-910ff2b3d951','cbe8ca6e-a6d6-472a-a8cb-db2e5456f7b8','41e0db4f-6115-439d-ba57-d3d948467790',1),
	 ('eed3edb8-1f03-4e7f-b331-e94844ec606c','cbe8ca6e-a6d6-472a-a8cb-db2e5456f7b8','30b92e74-a659-4291-a8f2-910ff2b3d951','41e0db4f-6115-439d-ba57-d3d948467790',1);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('2ef275ca-dbf0-4da8-95ea-b93f8286e761','cbe8ca6e-a6d6-472a-a8cb-db2e5456f7b8','ca23d21f-3ee0-4201-91de-826188d8b8f0','41e0db4f-6115-439d-ba57-d3d948467790',1),
	 ('9d1e49a4-6685-4a33-bbb7-bbcce818860b','ca23d21f-3ee0-4201-91de-826188d8b8f0','cbe8ca6e-a6d6-472a-a8cb-db2e5456f7b8','41e0db4f-6115-439d-ba57-d3d948467790',1),
	 ('89cb425b-d294-4a2c-8815-999a4916bae1','444c59f0-a197-44d3-a83b-84a829f370fe','d05aced6-375f-4614-af6e-5d408bc96583','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1),
	 ('daa2d8cf-873e-4ae3-9f71-ace3e6b32045','d05aced6-375f-4614-af6e-5d408bc96583','444c59f0-a197-44d3-a83b-84a829f370fe','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1),
	 ('185b9472-6bca-44af-90f3-cb410e551a00','d05aced6-375f-4614-af6e-5d408bc96583','3bb0f2a6-0334-471a-bdc9-b0e72aecae4a','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1),
	 ('dc5257eb-8c84-479c-8fe7-95f6aee26134','3bb0f2a6-0334-471a-bdc9-b0e72aecae4a','d05aced6-375f-4614-af6e-5d408bc96583','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1),
	 ('86f8da01-bea6-447e-8a86-17503b48f4ef','3bb0f2a6-0334-471a-bdc9-b0e72aecae4a','a414fec6-23bc-432f-8031-89eedcc914c1','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1),
	 ('f3a13b56-f73f-47bc-b2af-5c25ff25dead','a414fec6-23bc-432f-8031-89eedcc914c1','3bb0f2a6-0334-471a-bdc9-b0e72aecae4a','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1),
	 ('c3d36eef-0b70-4afb-a22f-a22fa8ead622','a414fec6-23bc-432f-8031-89eedcc914c1','f81e0725-870f-406a-85ee-f1bca23882f1','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',3),
	 ('a1044b3f-8006-4d41-87af-859682daa93c','f81e0725-870f-406a-85ee-f1bca23882f1','a414fec6-23bc-432f-8031-89eedcc914c1','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',3);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('79940fa7-80b4-4c96-ab21-ba295d9b47f5','f81e0725-870f-406a-85ee-f1bca23882f1','8bb24d47-187e-497c-b3e4-c3a1e15ef808','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',2),
	 ('9d4be0e9-3c85-43ca-a7f5-f77bada21876','8bb24d47-187e-497c-b3e4-c3a1e15ef808','f81e0725-870f-406a-85ee-f1bca23882f1','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',2),
	 ('008c1a1e-a759-4977-ba39-9f623dfafcbc','8bb24d47-187e-497c-b3e4-c3a1e15ef808','a002f828-5be2-4b1e-af63-bab2cea6c562','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',2),
	 ('c2f27bda-c478-4cfa-9118-c17a1d76fd39','a002f828-5be2-4b1e-af63-bab2cea6c562','8bb24d47-187e-497c-b3e4-c3a1e15ef808','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',2),
	 ('59f792ec-1e1e-427d-b68d-29a13df95f65','a002f828-5be2-4b1e-af63-bab2cea6c562','fe787a27-ffc6-4cc5-a3e5-d56fd72fc55f','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1),
	 ('e5c9384a-4b55-45a0-8f38-d01bc8c1a91c','fe787a27-ffc6-4cc5-a3e5-d56fd72fc55f','a002f828-5be2-4b1e-af63-bab2cea6c562','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1),
	 ('82abef99-c339-4a00-b3bd-63d22372636a','fe787a27-ffc6-4cc5-a3e5-d56fd72fc55f','d5b15ea3-ac10-4ba2-8ba5-8961ddc62de4','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',2),
	 ('4db338fe-610f-4b5e-a38a-02e3f47deb06','d5b15ea3-ac10-4ba2-8ba5-8961ddc62de4','fe787a27-ffc6-4cc5-a3e5-d56fd72fc55f','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',2),
	 ('f323b846-94e7-4e0a-b027-21218742ac53','d5b15ea3-ac10-4ba2-8ba5-8961ddc62de4','346534ce-dc78-4f58-8d66-149f6b063710','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1),
	 ('5cb9df30-2a1d-4df1-83e5-c3dc1a4c95f9','346534ce-dc78-4f58-8d66-149f6b063710','d5b15ea3-ac10-4ba2-8ba5-8961ddc62de4','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('986f764b-18db-4256-a23d-75cb33d5d674','346534ce-dc78-4f58-8d66-149f6b063710','99def398-a73e-4aed-9f8c-638e2f248713','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',2),
	 ('d967cde5-7133-4ab5-a9d9-d5d18369f33d','99def398-a73e-4aed-9f8c-638e2f248713','346534ce-dc78-4f58-8d66-149f6b063710','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',2),
	 ('a408f0cf-1e95-41d1-a92e-74088c6befbf','99def398-a73e-4aed-9f8c-638e2f248713','51c56a63-1921-4f74-bd08-b966c7787e2b','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1),
	 ('75d0eae4-c1f2-4baf-9bd2-c73296ff327b','51c56a63-1921-4f74-bd08-b966c7787e2b','99def398-a73e-4aed-9f8c-638e2f248713','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1),
	 ('7d2bc724-3294-4cc4-af22-036cc9a6107c','51c56a63-1921-4f74-bd08-b966c7787e2b','5d9ea08c-e283-4879-b470-f1c2f4122e77','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1),
	 ('20d4f76a-6c33-4389-868f-ffd1010c6bdb','5d9ea08c-e283-4879-b470-f1c2f4122e77','51c56a63-1921-4f74-bd08-b966c7787e2b','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1),
	 ('be95edf8-c601-4728-9a5f-6470418485ed','5d9ea08c-e283-4879-b470-f1c2f4122e77','18052527-361f-4cca-b362-7a8df241a2f0','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1),
	 ('03bd6e78-ccb2-4818-b9d7-21735aa071f7','18052527-361f-4cca-b362-7a8df241a2f0','5d9ea08c-e283-4879-b470-f1c2f4122e77','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1),
	 ('e771e4ea-3def-4803-9517-015445ba4a37','18052527-361f-4cca-b362-7a8df241a2f0','10f7503b-b316-485d-8cf7-ae77c4ea7e45','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1),
	 ('64a91718-6dd5-4382-9b34-2787e8be6998','10f7503b-b316-485d-8cf7-ae77c4ea7e45','18052527-361f-4cca-b362-7a8df241a2f0','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('4e7f4cd0-8896-4750-9991-0c2dd30216b2','10f7503b-b316-485d-8cf7-ae77c4ea7e45','4aa72c1a-ca6d-439d-84b9-f9e77a514204','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1),
	 ('4243ce7c-4aee-499b-a4c8-9329444e8987','4aa72c1a-ca6d-439d-84b9-f9e77a514204','10f7503b-b316-485d-8cf7-ae77c4ea7e45','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1),
	 ('64a2c68f-cb66-4408-90ff-cd4c4eb868f6','4aa72c1a-ca6d-439d-84b9-f9e77a514204','f014be7a-5ea3-4dc2-b811-40654f9b4cca','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',2),
	 ('ab805b0a-df34-4801-bcdb-fbd3d03b2945','f014be7a-5ea3-4dc2-b811-40654f9b4cca','4aa72c1a-ca6d-439d-84b9-f9e77a514204','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',2),
	 ('00ec55d2-8811-40ee-a9ce-4af2b1051f5b','f014be7a-5ea3-4dc2-b811-40654f9b4cca','5a428763-7750-4870-b4a1-ed65c9828644','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1),
	 ('631b64c4-aa1e-4892-9c70-000b0b696bf1','5a428763-7750-4870-b4a1-ed65c9828644','f014be7a-5ea3-4dc2-b811-40654f9b4cca','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1),
	 ('544e04a5-0f20-48d6-8197-5ca2ebcd142f','5a428763-7750-4870-b4a1-ed65c9828644','c39b0389-924a-4889-902f-025d98af6bf7','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1),
	 ('abb8474c-4b39-4c03-ba34-b152339b7eb9','c39b0389-924a-4889-902f-025d98af6bf7','5a428763-7750-4870-b4a1-ed65c9828644','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',1),
	 ('20df7e4b-07d2-4687-b736-dadeea9cb530','c39b0389-924a-4889-902f-025d98af6bf7','934ef3af-56e6-4b38-a35c-07899c544619','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',2),
	 ('465bc344-138c-4f0a-b8b7-9db1b28da9fe','934ef3af-56e6-4b38-a35c-07899c544619','c39b0389-924a-4889-902f-025d98af6bf7','8e2f2b36-9cdc-4080-b89b-e4a8072e47c6',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('f82ab29f-ecca-47dd-b223-f5f5f2ebe01f','43c19e64-8601-47c8-ad5f-e41ea55d7e11','ee59ade3-92f9-4437-a877-d18113b1240a','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('1c374b5a-2c3e-4835-b240-ad96b11c2f43','ee59ade3-92f9-4437-a877-d18113b1240a','43c19e64-8601-47c8-ad5f-e41ea55d7e11','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('38144703-c736-41ce-a3cc-443fa2bd4896','ee59ade3-92f9-4437-a877-d18113b1240a','7149f634-eefc-4f9d-bca7-135a0af923a4','221ec64b-f9d0-4ccc-a8b4-342571240a49',2),
	 ('c4cd5a42-da58-4b83-8190-2c190d196235','7149f634-eefc-4f9d-bca7-135a0af923a4','ee59ade3-92f9-4437-a877-d18113b1240a','221ec64b-f9d0-4ccc-a8b4-342571240a49',2),
	 ('624a47da-45bc-4964-8f1e-acd9dc0b18ee','7149f634-eefc-4f9d-bca7-135a0af923a4','36cf8da1-08d7-4845-bc7a-ed44f573d374','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('3f631e9d-bbcd-4a76-9524-28ab1d663aa5','36cf8da1-08d7-4845-bc7a-ed44f573d374','7149f634-eefc-4f9d-bca7-135a0af923a4','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('57ab71d5-d9c4-41f9-aabb-aee02308a1fd','36cf8da1-08d7-4845-bc7a-ed44f573d374','508d5777-657a-4d5a-a079-91e430b0f233','221ec64b-f9d0-4ccc-a8b4-342571240a49',2),
	 ('9d412a25-aa78-4e63-baf1-6764c878dad1','508d5777-657a-4d5a-a079-91e430b0f233','36cf8da1-08d7-4845-bc7a-ed44f573d374','221ec64b-f9d0-4ccc-a8b4-342571240a49',2),
	 ('501266bb-0560-4816-9ef1-c087c1fd6448','508d5777-657a-4d5a-a079-91e430b0f233','126e2610-ef7e-41fb-b2fb-f8646b924b5d','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('1e174e12-8931-4457-85c4-928d1769510d','126e2610-ef7e-41fb-b2fb-f8646b924b5d','508d5777-657a-4d5a-a079-91e430b0f233','221ec64b-f9d0-4ccc-a8b4-342571240a49',1);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('5bf17c12-4fb4-4a98-a3ca-b0da81a558ab','126e2610-ef7e-41fb-b2fb-f8646b924b5d','6b878017-9ab9-43ba-9dc5-ef050907867e','221ec64b-f9d0-4ccc-a8b4-342571240a49',2),
	 ('c54a6e67-5868-43a3-9cd4-256a588f20e1','6b878017-9ab9-43ba-9dc5-ef050907867e','126e2610-ef7e-41fb-b2fb-f8646b924b5d','221ec64b-f9d0-4ccc-a8b4-342571240a49',2),
	 ('36fcae92-efc6-481b-890a-4537bc22b056','6b878017-9ab9-43ba-9dc5-ef050907867e','ff94f41b-0db1-4fa9-9d91-82c3e67c3d71','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('1cfcd4dd-36b8-46cd-830f-99902699e19a','ff94f41b-0db1-4fa9-9d91-82c3e67c3d71','6b878017-9ab9-43ba-9dc5-ef050907867e','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('8a74fa03-b1f3-4f1f-b6c5-d22d66b976e9','ff94f41b-0db1-4fa9-9d91-82c3e67c3d71','df60d5c4-d8b4-4ea1-9f2a-67b0919976b9','221ec64b-f9d0-4ccc-a8b4-342571240a49',2),
	 ('91819f94-ae57-46f4-828a-3e4913079292','df60d5c4-d8b4-4ea1-9f2a-67b0919976b9','ff94f41b-0db1-4fa9-9d91-82c3e67c3d71','221ec64b-f9d0-4ccc-a8b4-342571240a49',2),
	 ('fbbc40e0-b031-452c-a7d3-ac5936e576d2','df60d5c4-d8b4-4ea1-9f2a-67b0919976b9','fefb0f6c-a574-49af-9bca-75fb7f5eeb58','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('9ed87779-9d5c-4a91-af5d-ec8ac11c71c6','fefb0f6c-a574-49af-9bca-75fb7f5eeb58','df60d5c4-d8b4-4ea1-9f2a-67b0919976b9','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('66e558c4-abab-47c6-8b3d-ddba5f9084ce','fefb0f6c-a574-49af-9bca-75fb7f5eeb58','51059895-e669-48f2-81b4-f827c0d5ec2b','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('60a2d670-364c-4aac-9f85-4aad8d4307f1','51059895-e669-48f2-81b4-f827c0d5ec2b','fefb0f6c-a574-49af-9bca-75fb7f5eeb58','221ec64b-f9d0-4ccc-a8b4-342571240a49',1);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('7c94bacd-6b72-45a2-add6-6fa1656868e8','51059895-e669-48f2-81b4-f827c0d5ec2b','62de3e83-836e-413d-99e1-dc33fb72f189','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('30edd9ee-3417-4b7e-8f2f-c190b82c3218','62de3e83-836e-413d-99e1-dc33fb72f189','51059895-e669-48f2-81b4-f827c0d5ec2b','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('80d955d6-7f0a-4bcc-bc49-110b8631fcb3','62de3e83-836e-413d-99e1-dc33fb72f189','ba8b813e-3749-4984-8ebd-f0ad55d1163d','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('ded1a800-9ba4-4f09-a20f-e09e1c069c41','ba8b813e-3749-4984-8ebd-f0ad55d1163d','62de3e83-836e-413d-99e1-dc33fb72f189','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('e6050445-6482-4ba7-866e-3c49ce69e305','ba8b813e-3749-4984-8ebd-f0ad55d1163d','2951e378-f7da-4ac8-a805-95c8eca4dbda','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('d6287aea-a5d5-4bb1-ae36-7b154bea9334','2951e378-f7da-4ac8-a805-95c8eca4dbda','ba8b813e-3749-4984-8ebd-f0ad55d1163d','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('a0f44d26-4c2c-4ba3-9037-94c1ba09ae0e','2951e378-f7da-4ac8-a805-95c8eca4dbda','c2763e49-c770-4f20-9fb9-c80ab261ea24','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('40f7ac6e-29a4-453e-907c-8e8839df50fd','c2763e49-c770-4f20-9fb9-c80ab261ea24','2951e378-f7da-4ac8-a805-95c8eca4dbda','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('b36e420e-eb37-40cf-bd9f-f0f14faad7ad','c2763e49-c770-4f20-9fb9-c80ab261ea24','3dd7e4c3-a29c-4f4f-be1b-4871a8b73a17','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('b11878d6-aa83-4673-8413-5f9ab4fb9103','3dd7e4c3-a29c-4f4f-be1b-4871a8b73a17','c2763e49-c770-4f20-9fb9-c80ab261ea24','221ec64b-f9d0-4ccc-a8b4-342571240a49',1);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('ceed07a3-719a-48a0-90d5-038137600bf4','3dd7e4c3-a29c-4f4f-be1b-4871a8b73a17','c6879e9e-853a-460c-9678-38278fc9c7ff','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('fa4950ab-cc1a-4acf-8baa-3c802f35eaf4','c6879e9e-853a-460c-9678-38278fc9c7ff','3dd7e4c3-a29c-4f4f-be1b-4871a8b73a17','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('543b4877-75dc-4a3a-b5af-0f4377718177','c6879e9e-853a-460c-9678-38278fc9c7ff','7ce2ba20-638d-4881-97de-73d59d70ce41','221ec64b-f9d0-4ccc-a8b4-342571240a49',2),
	 ('5259ab67-6c38-484e-89e7-4433add1d0b2','7ce2ba20-638d-4881-97de-73d59d70ce41','c6879e9e-853a-460c-9678-38278fc9c7ff','221ec64b-f9d0-4ccc-a8b4-342571240a49',2),
	 ('127b684e-fd4c-4744-9d90-b07a3c7a8494','7ce2ba20-638d-4881-97de-73d59d70ce41','1b645f6e-6f73-42d9-a111-03c343612049','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('46137a05-6b3c-44b0-b7e5-34692c32c9f3','1b645f6e-6f73-42d9-a111-03c343612049','7ce2ba20-638d-4881-97de-73d59d70ce41','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('81df724f-e821-406e-8955-53e9ebdd3d2f','1b645f6e-6f73-42d9-a111-03c343612049','a4c01bae-8623-4a72-80e3-909463351f3d','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('dc4fee9f-4873-4e7f-9f06-15411da3d7cd','a4c01bae-8623-4a72-80e3-909463351f3d','1b645f6e-6f73-42d9-a111-03c343612049','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('f3db4f2e-b6e4-48d2-8609-68c67997b3c7','a4c01bae-8623-4a72-80e3-909463351f3d','2a150aec-bcd3-411e-9189-8f26881374e8','221ec64b-f9d0-4ccc-a8b4-342571240a49',2),
	 ('78dad331-a5c8-41e3-b6c2-70903d2e196a','2a150aec-bcd3-411e-9189-8f26881374e8','a4c01bae-8623-4a72-80e3-909463351f3d','221ec64b-f9d0-4ccc-a8b4-342571240a49',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('0024fd89-a5f2-4dbf-999c-7418721af496','2a150aec-bcd3-411e-9189-8f26881374e8','53c2768b-4fd0-4d52-8f33-7711bbeb92e6','221ec64b-f9d0-4ccc-a8b4-342571240a49',3),
	 ('fbb030a6-7f0c-45ac-a500-7b80e82a94b0','53c2768b-4fd0-4d52-8f33-7711bbeb92e6','2a150aec-bcd3-411e-9189-8f26881374e8','221ec64b-f9d0-4ccc-a8b4-342571240a49',3),
	 ('488812e6-b84b-48fd-8379-37c0af5b48d8','53c2768b-4fd0-4d52-8f33-7711bbeb92e6','097f8a83-5ec5-4456-8101-781bd18cceba','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('e10fd760-1c9a-48ee-af0f-231888f0448e','097f8a83-5ec5-4456-8101-781bd18cceba','53c2768b-4fd0-4d52-8f33-7711bbeb92e6','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('3d3c5062-9391-491f-a92c-2017a26b73e4','097f8a83-5ec5-4456-8101-781bd18cceba','4ec4d6ab-3662-4b3b-a2b6-3d01e44cc784','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('61e9948b-3062-4a45-93ed-8d8dd2906fd6','4ec4d6ab-3662-4b3b-a2b6-3d01e44cc784','097f8a83-5ec5-4456-8101-781bd18cceba','221ec64b-f9d0-4ccc-a8b4-342571240a49',1),
	 ('bebeeafd-a345-4dc1-827b-8680264768ca','4ec4d6ab-3662-4b3b-a2b6-3d01e44cc784','444c59f0-a197-44d3-a83b-84a829f370fe','221ec64b-f9d0-4ccc-a8b4-342571240a49',2),
	 ('4c687c37-23b3-486f-ad40-f4ffafab7281','444c59f0-a197-44d3-a83b-84a829f370fe','4ec4d6ab-3662-4b3b-a2b6-3d01e44cc784','221ec64b-f9d0-4ccc-a8b4-342571240a49',2),
	 ('94d26b8b-f588-4958-83c6-f34bfc2d9d02','444c59f0-a197-44d3-a83b-84a829f370fe','2585eada-c145-42e2-8e82-63b0c4f0f321','221ec64b-f9d0-4ccc-a8b4-342571240a49',2),
	 ('578f6e85-55bc-470e-9ac9-5fa6f6884900','2585eada-c145-42e2-8e82-63b0c4f0f321','444c59f0-a197-44d3-a83b-84a829f370fe','221ec64b-f9d0-4ccc-a8b4-342571240a49',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('1aff7c28-7e6d-4c01-8339-d6e30626b58d','47ac3706-27f3-4904-8ce7-afbe3edc3c74','13c5ff88-898e-44c6-9e49-47fda0197850','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',2),
	 ('2e130af3-1bab-4f97-a5cf-a72209a5e08f','13c5ff88-898e-44c6-9e49-47fda0197850','47ac3706-27f3-4904-8ce7-afbe3edc3c74','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',2),
	 ('f1ec7728-a0a0-4b1e-acd1-b8d6fa885268','13c5ff88-898e-44c6-9e49-47fda0197850','8406fc1d-6900-4267-9c40-96560ad36875','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1),
	 ('1c7e0aab-7307-427b-96d2-16c4db610ded','8406fc1d-6900-4267-9c40-96560ad36875','13c5ff88-898e-44c6-9e49-47fda0197850','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1),
	 ('3f59706b-ecb6-423f-bbae-68a3c91531b8','8406fc1d-6900-4267-9c40-96560ad36875','c8106963-279b-4071-bd5a-c779683c3cf7','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1),
	 ('20211a74-a15e-4153-b81d-e8b918857ed2','c8106963-279b-4071-bd5a-c779683c3cf7','8406fc1d-6900-4267-9c40-96560ad36875','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1),
	 ('5ed72a4f-5494-49b9-acdd-a20c0486539f','c8106963-279b-4071-bd5a-c779683c3cf7','2f1f24bb-5852-4e37-8f4d-19ee67cd8e36','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1),
	 ('e627a685-ad8e-4aac-9aef-7beaa5ba721c','2f1f24bb-5852-4e37-8f4d-19ee67cd8e36','c8106963-279b-4071-bd5a-c779683c3cf7','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1),
	 ('1057b8d7-395b-4de1-b23e-1459ffbeb23f','2f1f24bb-5852-4e37-8f4d-19ee67cd8e36','4e5564f3-a05f-498e-84ab-835abc7919f8','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1),
	 ('cc807e6c-a516-43ff-96d6-2bec188c1bdd','4e5564f3-a05f-498e-84ab-835abc7919f8','2f1f24bb-5852-4e37-8f4d-19ee67cd8e36','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('1163b298-b858-41cc-b750-fa6d2cb4f5dd','4e5564f3-a05f-498e-84ab-835abc7919f8','1b6a08df-08f9-43fa-9044-acfa8869930a','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1),
	 ('d3549343-9d5a-4884-af5b-2b6dc6f48c77','1b6a08df-08f9-43fa-9044-acfa8869930a','4e5564f3-a05f-498e-84ab-835abc7919f8','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1),
	 ('ec34e969-f5b0-4d7a-9eab-dae280c0d09f','1b6a08df-08f9-43fa-9044-acfa8869930a','92aa7f8d-315f-4e9a-9ece-3397c1d52565','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1),
	 ('f791ce18-2919-4e20-9821-4bdd6c8b79f3','92aa7f8d-315f-4e9a-9ece-3397c1d52565','1b6a08df-08f9-43fa-9044-acfa8869930a','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1),
	 ('8cf6bfa9-5eaf-487f-aa49-8c3c6b3ff4b7','92aa7f8d-315f-4e9a-9ece-3397c1d52565','e5fd7e37-3ce4-47d0-aa10-92b42d971e90','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1),
	 ('13c0c744-a2f9-4af0-87dd-998bc46ad5e5','e5fd7e37-3ce4-47d0-aa10-92b42d971e90','92aa7f8d-315f-4e9a-9ece-3397c1d52565','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1),
	 ('6c79fa67-3021-43fe-b12b-562f6c12f43c','e5fd7e37-3ce4-47d0-aa10-92b42d971e90','bd6620ec-e38d-4e97-bfd1-e252fcd34917','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1),
	 ('70fffff8-fbdf-42e5-97a3-ce348c7fa6dd','bd6620ec-e38d-4e97-bfd1-e252fcd34917','e5fd7e37-3ce4-47d0-aa10-92b42d971e90','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1),
	 ('eebd14e0-82e5-4bc1-8d73-d1eaef812b7e','bd6620ec-e38d-4e97-bfd1-e252fcd34917','1b3c1105-d6c3-46ba-9654-0fc9f0412963','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',2),
	 ('7fef5778-c98f-4d10-b0d0-87d4396cb8a1','1b3c1105-d6c3-46ba-9654-0fc9f0412963','bd6620ec-e38d-4e97-bfd1-e252fcd34917','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',2);

INSERT INTO t_edges (uuid,start_station_uuid,end_station_uuid,line_uuid,distance_min) VALUES
	 ('5263de97-493a-408a-bfac-2ec2ee9fd66b','1b3c1105-d6c3-46ba-9654-0fc9f0412963','0ed27aba-5409-48a0-b9c9-c4687b48fe84','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1),
	 ('9a7c5f64-358d-44d6-8b4e-c48cc5afddad','0ed27aba-5409-48a0-b9c9-c4687b48fe84','1b3c1105-d6c3-46ba-9654-0fc9f0412963','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1),
	 ('3d459b35-4726-4364-ae4d-ae5a259db7b8','0ed27aba-5409-48a0-b9c9-c4687b48fe84','964f4ab2-8dcf-40ef-85b3-0818289a86cf','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1),
	 ('64ba90f1-2095-4523-a7d8-0919a8f84291','964f4ab2-8dcf-40ef-85b3-0818289a86cf','0ed27aba-5409-48a0-b9c9-c4687b48fe84','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1),
	 ('c4331f07-4492-4400-ac44-45f10176bd81','964f4ab2-8dcf-40ef-85b3-0818289a86cf','7b66ad8a-0439-4bd2-868e-4bb3b681e601','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1),
	 ('96508168-2072-4f3b-981e-672ec28f5b1f','7b66ad8a-0439-4bd2-868e-4bb3b681e601','964f4ab2-8dcf-40ef-85b3-0818289a86cf','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1),
	 ('0fb12df5-00da-4a94-9fb6-4398de1ea8a7','7b66ad8a-0439-4bd2-868e-4bb3b681e601','eed95b18-acbd-4900-9e5b-23b43bbc454c','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1),
	 ('a52672e4-7da2-4fe8-bf1d-092f79ce95fa','eed95b18-acbd-4900-9e5b-23b43bbc454c','7b66ad8a-0439-4bd2-868e-4bb3b681e601','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',1),
	 ('f8766965-4579-4de0-a9fb-06be982c0207','eed95b18-acbd-4900-9e5b-23b43bbc454c','368bf51e-bd0a-4320-b731-01a62a089450','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',2),
	 ('c2758bfd-7a31-4cb2-bb2a-4e921dc99636','368bf51e-bd0a-4320-b731-01a62a089450','eed95b18-acbd-4900-9e5b-23b43bbc454c','b1b1ddf3-5c85-4059-91c0-f4c6686daebd',2);
