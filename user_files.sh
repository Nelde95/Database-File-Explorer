sqlite3 files.db "SELECT f.filename FROM Fil AS f
JOIN Bruker AS b
ON b.uid = f.uid
WHERE b.brukernavn = \""$1"\";"
