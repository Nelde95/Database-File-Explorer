DROP TABLE IF EXISTS Bruker_;
CREATE TABLE Bruker_ (
	brukernavn VARCHAR(20) NOT NULL,
	passord VARCHAR(50),
	uid SMALLINT NOT NULL,
	gid SMALLINT,
	navn VARCHAR(250),
	hjemmekatalog VARCHAR(100),
	kommandotolker VARCHAR(100),
	PRIMARY KEY(brukernavn),
	UNIQUE(uid)
);


.mode csv
.separator ':'
.import /etc/passwd Bruker_



DROP TABLE IF EXISTS Gruppe;
CREATE TABLE Gruppe (
	id SMALLINT NOT NULL,
	name VARCHAR(250) DEFAULT "Group name not found",
	PRIMARY KEY(id)
);


DROP TABLE IF EXISTS Bruker;
CREATE TABLE Bruker (
	brukernavn VARCHAR(20) NOT NULL,
	passord VARCHAR(50),
	uid SMALLINT NOT NULL,
	gid SMALLINT,
	navn VARCHAR(250),
	hjemmekatalog VARCHAR(100),
	kommandotolker VARCHAR(100),
	PRIMARY KEY(brukernavn),
	FOREIGN KEY(gid) REFERENCES Gruppe(id),
	UNIQUE(uid)
);

INSERT INTO Bruker (brukernavn, passord, uid, gid, navn, hjemmekatalog, kommandotolker)
	SELECT brukernavn, passord, uid, gid, navn, hjemmekatalog, kommandotolker FROM Bruker_;


DROP TABLE IF EXISTS csv_import;
CREATE TABLE csv_import (
	accessrights CHAR(3) NOT NULL,
	devicenum CHAR(4) NOT NULL,
	filetype VARCHAR(32) NOT NULL,
	gid SMALLINT,
	gname VARCHAR(250),
	hardlinks_qty UNSIGNED TINYINT NOT NULL,
	id UNSIGNED INT NOT NULL, -- inode number
	mountpoint VARCHAR(1000) NOT NULL,
	filename VARCHAR(250) UNIQUE NOT NULL,
	optiotransfer UNSIGNED BIGINT NOT NULL,
	filesize UNSIGNED BIGINT NOT NULL,
	uid SMALLINT,
	uname VARCHAR(20),
	PRIMARY KEY(id)
);

.mode csv
.separator ';'
.import ./files.csv csv_import


INSERT INTO Gruppe (id, name) SELECT DISTINCT gid, gname FROM csv_import;
INSERT INTO Gruppe (id) SELECT DISTINCT gid FROM Bruker_ as import
	WHERE NOT EXISTS(SELECT id FROM Gruppe AS controll WHERE controll.id = import.gid);



DROP TABLE IF EXISTS Fil;
CREATE TABLE Fil (
	id UNSIGNED INT NOT NULL,
	par UNSIGNED INT,
	filename VARCHAR(250),
	accessrights CHAR(3) NOT NULL,
	devicenum CHAR(4) NOT NULL,
	filetype VARCHAR(32) NOT NULL,
	gid SMALLINT,
	hardlinks_qty UNSIGNED TINYINT NOT NULL,
	mountpoint VARCHAR(1000) NOT NULL,
	optiotransfer UNSIGNED BIGINT NOT NULL,
	filesize UNSIGNED BIGINT NOT NULL,
	uid SMALLINT,
	PRIMARY KEY(id),
	FOREIGN KEY(par) REFERENCES Fil(id),
	FOREIGN KEY(uid) REFERENCES Bruker(uid)
);

INSERT INTO Fil (id, par, filename, accessrights, devicenum, filetype, gid, hardlinks_qty,
	mountpoint, optiotransfer, filesize, uid)
	SELECT a.id, b.id,
		SUBSTR(a.filename, LENGTH(b.filename)+2, LENGTH(a.filename)), a.accessrights, a.devicenum, a.filetype, a.gid, a.hardlinks_qty, a.mountpoint,
		a.optiotransfer, a.filesize, a.uid FROM csv_import AS a
		LEFT JOIN csv_import AS b
		ON b.filename = SUBSTR(rtrim(a.filename, replace(a.filename, '/', '')), 1,
			LENGTH(rtrim(a.filename, replace(a.filename, '/', '')))-1);
UPDATE Fil SET filename = "/" WHERE filename ISNULL;

DROP TABLE IF EXISTS csv_import;
DROP TABLE IF EXISTS Bruker_;
