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
	PRIMARY KEY(id, devicenum)
);

.mode csv
.separator ';'
.import ./files.csv csv_import


INSERT INTO Gruppe (id, name) SELECT DISTINCT gid, gname FROM csv_import;
INSERT INTO Gruppe (id) SELECT DISTINCT gid FROM Bruker_ AS import
	WHERE NOT EXISTS(SELECT id FROM Gruppe AS controll WHERE controll.id = import.gid);



DROP TABlE IF EXISTS Device;
CREATE TABLE Device (
	devicenum CHAR(4) NOT NULL,
	optiotransfer UNSIGNED BIGINT NOT NULL,
	PRIMARY KEY(devicenum)
);
INSERT INTO Device (devicenum, optiotransfer) SELECT devicenum, optiotransfer FROM csv_import GROUP BY devicenum;

DROP TABLE IF EXISTS Fil;
CREATE TABLE Fil (
	id UNSIGNED INT NOT NULL,
	devicenum CHAR(4) NOT NULL,
	parid UNSIGNED INT,
	pardevicenum CHAR(4),
	filename VARCHAR(250),
	accessrights CHAR(3) NOT NULL,
	filetype VARCHAR(32) NOT NULL,
	gid SMALLINT,
	hardlinks_qty UNSIGNED TINYINT NOT NULL,
	filesize UNSIGNED BIGINT NOT NULL,
	uid SMALLINT,
	PRIMARY KEY(id, devicenum),
	FOREIGN KEY(devicenum) REFERENCES Device(devicenum),
	FOREIGN KEY(parid, pardevicenum) REFERENCES Fil(id, devicenum),
	FOREIGN KEY(gid) REFERENCES Gruppe(id),
	FOREIGN KEY(uid) REFERENCES Bruker(uid)
);

INSERT INTO Fil (id, devicenum, parid, pardevicenum,
	filename, accessrights, filetype, gid, hardlinks_qty, filesize, uid)
	SELECT a.id, a.devicenum, b.id, b.devicenum,
		COALESCE(SUBSTR(a.filename, LENGTH(rtrim(b.filename, '/'))+2, LENGTH(a.filename)), "/"),
	   	a.accessrights, a.filetype, a.gid, a.hardlinks_qty, a.filesize, a.uid
		FROM csv_import AS a
		LEFT JOIN csv_import AS b
		ON (b.filename = SUBSTR(rtrim(a.filename, replace(a.filename, '/', '')), 1,
			LENGTH(rtrim(a.filename, replace(a.filename, '/', '')))-1))
		OR (b.filename = "/" AND (LENGTH(a.filename) - LENGTH(replace(a.filename, '/', ''))) = 1
			AND a.filename != "/");
UPDATE Fil SET filename = "/" WHERE filename ISNULL;


DROP TABLE IF EXISTS Mount;
CREATE TABLE Mount (
	devicenum CHAR(4) NOT NULL,
	mountpointid UNSIGNED INT NOT NULL,
	mountpointdevice CHAR(4) NOT NULL,
	PRIMARY KEY(devicenum, mountpointid, mountpointdevice)
	FOREIGN KEY(devicenum) REFERENCES Device(devicenum),
	FOREIGN KEY(mountpointid, mountpointdevice) REFERENCES Fil(id, devicenum)
);
INSERT INTO Mount (devicenum, mountpointid, mountpointdevice)
	SELECT DISTINCT a.devicenum, b.id, b.devicenum
		FROM csv_import AS a
		JOIN csv_import AS b
		ON(a.mountpoint = b.filename);

--DROP TABLE IF EXISTS csv_import;
DROP TABLE IF EXISTS Bruker_;

DROP VIEW IF EXISTS sum_view;
CREATE VIEW sum_view
AS
SELECT
	b.brukernavn AS "brukernavn",
	b.navn AS "fulltnavn",
	SUM(f.filesize) AS "sum av filstorelser"
FROM Fil AS f
JOIN Bruker AS b
ON f.uid = b.uid
GROUP BY f.uid;
