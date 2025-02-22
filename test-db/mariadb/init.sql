--
-- Copyright 2025 Jaroslav Chmurny
--
-- This file is part of RDBMS Diff.
--
-- RDBMS Diff is free software licensed under the Apache License,
-- Version 2.0 (the "License"); you may not use this file except in
-- compliance with the License. You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

/*********************************************************************************/
/* Schema                                                                        */
/*********************************************************************************/

CREATE DATABASE IF NOT EXISTS rdbms_diff;

USE rdbms_diff;

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

CREATE TABLE t_log_entries (
	id BIGINT NOT NULL,
	date_and_time TIMESTAMP NOT NULL,
	severity SMALLINT NOT NULL,
	service VARCHAR(30) NOT NULL,
	message TEXT NOT NULL,
    CONSTRAINT t_log_entries_pk PRIMARY KEY(id),
	CONSTRAINT severity_check CHECK (severity >= 0 and severity <= 5)
);

CREATE INDEX i_log_entry_timestamp ON t_log_entries(date_and_time);

CREATE TABLE t_datatype_mixture (
	id BIGINT NOT NULL,
	date_value DATE,
	time_value TIME,
	timestamp_value TIMESTAMP,
	float_value FLOAT,
	double_value FLOAT,
	boolean_value BOOLEAN,
	char_value CHAR(3),
    CONSTRAINT t_datatype_mixture_pk PRIMARY KEY(id)
);

CREATE SEQUENCE s_dummy_1 INCREMENT BY 1 NO MAXVALUE START WITH 1 NOCYCLE;

CREATE SEQUENCE s_dummy_2 INCREMENT BY 1 NO MAXVALUE START WITH 1 NOCYCLE;

CREATE SEQUENCE s_dummy_3 INCREMENT BY 1 NO MAXVALUE START WITH 1 NOCYCLE;

CREATE SEQUENCE s_dummy_4 INCREMENT BY 1 NO MAXVALUE START WITH 1 NOCYCLE;

CREATE SEQUENCE s_dummy_5 INCREMENT BY 1 NO MAXVALUE START WITH 1 NOCYCLE;

CREATE VIEW v_lines AS
SELECT l.label as line, m.identifier as means_of_transport, s1.name as terminal_stop_one, s2.name as terminal_stop_two FROM t_lines l
INNER JOIN t_means_of_transport m ON m.uuid = l.means_of_transport_uuid
INNER JOIN t_stations s1 ON s1.uuid = l.terminal_stop_one_uuid
INNER JOIN t_stations s2 ON s2.uuid = l.terminal_stop_two_uuid;

CREATE VIEW v_edges AS
SELECT l.label as line, s1.name as start_station, s2.name as end_station, e.distance_min as distance_min from t_edges e
INNER JOIN t_lines l ON l.uuid = e.line_uuid
INNER JOIN t_stations s1 ON s1.uuid = e.start_station_uuid
INNER JOIN t_stations s2 ON s2.uuid = e.end_station_uuid;

/* TODO: this will most likely not work
CREATE MATERIALIZED VIEW mv_lines AS
SELECT l.label as line, m.identifier as means_of_transport, s1.name as terminal_stop_one, s2.name as terminal_stop_two FROM t_lines l
INNER JOIN t_means_of_transport m ON m.uuid = l.means_of_transport_uuid
INNER JOIN t_stations s1 ON s1.uuid = l.terminal_stop_one_uuid
INNER JOIN t_stations s2 ON s2.uuid = l.terminal_stop_two_uuid;

CREATE MATERIALIZED VIEW mv_edges AS
SELECT l.label as line, s1.name as start_station, s2.name as end_station, e.distance_min as distance_min from t_edges e
INNER JOIN t_lines l ON l.uuid = e.line_uuid
INNER JOIN t_stations s1 ON s1.uuid = e.start_station_uuid
INNER JOIN t_stations s2 ON s2.uuid = e.end_station_uuid;
*/


