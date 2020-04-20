default:
	rm "files.csv"
	export D=1
	./file_info.sh "/" > "files.csv"
	cat createtables.sql | sqlite3 files.db
