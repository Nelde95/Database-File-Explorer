sqlite3 files.db "SELECT COALESCE(NULLIF(
	   COALESCE(rtrim(f4.filename, \"/\") || \"/\", \"\")
	|| COALESCE(rtrim(f3.filename,\"/\") || \"/\", \"\")
	|| COALESCE(rtrim(f2.filename,\"/\") || \"/\", \"\")
	|| COALESCE(rtrim(f1.filename,\"/\"), \"\"), \"\"), \"/\")
FROM Fil AS f1
LEFT JOIN Fil AS f2
ON f1.par = f2.id
LEFT JOIN Fil AS f3
ON f2.par = f3.id
LEFT JOIN Fil AS f4
ON f3.par = f4.id
WHERE f1.id = \""$1"\";"
