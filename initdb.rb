require 'sqlite3'

if File.exists? "agenda.sqlite"
	File.delete("agenda.sqlite")
end

db = SQLite3::Database.open('agenda.sqlite')

db.execute <<SQL
	CREATE TABLE usuarios(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		usuario VARCHAR(100),
		clave VARCHAR(100),
		unique(usuario)
		);
SQL

db.execute <<SQL
	INSERT INTO usuarios(usuario, clave) VALUES
	('admin', 'admin');
SQL

db.execute <<SQL
	CREATE TABLE contactos(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		nombre VARCHAR(100),
		apellido VARCHAR(100),
		telefono VARCHAR(25),
		direccion VARCHAR(200),
		unique(telefono)
		);
SQL

db.execute <<SQL
	INSERT INTO contactos(nombre, apellido, telefono, direccion) VALUES
	('Paris','Vazquez','6143360880','Villa de Polux 5650 Villas del Sol III'),
	('Blanca','Venzor','6141770560','Villa de Polux 5650 Villas del Sol III'),
	('Gerardo','Vazquez','6141334427','Villa de Polux 5650 Villas del Sol III'),
	('Orson','Vazquez','6142314767','Uruguay ####');
SQL

