sqlite3 files.db "SELECT COALESCE(NULLIF(
	   COALESCE(rtrim(f4.filename, \"/\") || \"/\", \"\")
	|| COALESCE(rtrim(f3.filename,\"/\") || \"/\", \"\")
	|| COALESCE(rtrim(f2.filename,\"/\") || \"/\", \"\")
	|| COALESCE(rtrim(f1.filename,\"/\"), \"\"), \"\"), \"/\")
FROM Fil AS f1
LEFT JOIN Fil AS f2
ON f1.parid = f2.id AND f1.pardevicenum = f2.devicenum
LEFT JOIN Fil AS f3
ON f2.parid = f3.id AND f2.pardevicenum = f3.devicenum
LEFT JOIN Fil AS f4
ON f3.parid = f4.id AND f3.pardevicenum = f4.devicenum
WHERE f1.id = \""$1"\";"
