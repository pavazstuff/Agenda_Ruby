require 'sinatra'
require 'haml'
require 'sqlite3'

class Agenda
	def initialize()
		@db = SQLite3::Database.open('agenda.sqlite')
	end

	def login(user,pass)
		@db.execute("SELECT * FROM usuarios WHERE usuario= '#{user}' AND clave= '#{pass}'").count
	end

	def contacts(order,by)
		self.contacts_array_to_hash(@db.execute("SELECT * FROM contactos ORDER BY #{order} #{by}"))
	end

	def find_contacts(person)
		self.contacts_array_to_hash(@db.execute("SELECT * FROM contactos WHERE nombre LIKE '%#{person}%' or apellido LIKE '%#{person}%' ORDER BY nombre ASC"))
	end

	def add_contact(name, lastname, phone, address)
		@db.execute("INSERT INTO contactos(nombre, apellido, telefono, direccion) VALUES('#{name}','#{lastname}','#{phone}','#{address}')")
	end

	def find_one_a_contact(arr)
		self.contacts_array_to_hash(@db.execute("SELECT * FROM contactos WHERE id='#{arr}'"))[0]
	end

	def update_contact(arr, name, lastname, phone, address)
		@db.execute("UPDATE contactos SET nombre= '#{name}', apellido= '#{lastname}', telefono= '#{phone}', direccion= '#{address}' WHERE id= '#{arr}'")
	end

	def delete_contact(arr)
		@db.execute("DELETE FROM contactos WHERE id='#{arr}'")
	end

	def contacts_array_to_hash(arr)
		arr.map do |person|
			{
				:id => person[0],
				:nombre => person[1],
				:apellido => person[2],
				:telefono => person[3],
				:direccion => person[4]
			}
		end
	end
end

configure do
	enable :sessions
end

db = Agenda.new()

get '/' do
	if session.has_key?('user') 
		if params.has_key?('order')
			order = params[:order]
		else
			order = "nombre"
		end

		if params.has_key?('by')
			by = params[:by]
		else
			by = "ASC"
		end

		@order = order
		@by = by
		@contacts = db.contacts(order,by)
		@num = @contacts.count
		haml :contacts
	else
		haml :index
	end
end

post '/' do
	num = db.login(params[:user],params[:pass])
	if num > 0 then
		session[:user] = true
	end
	redirect "/"
end

get '/search' do
	if session.has_key?('user') 
		if params.has_key?('q')
			busqueda = params[:q]
		else
			busqueda = ""
		end
		@contacts = db.find_contacts(busqueda)
		if @contacts.count > 0
			@num = @contacts.count
		else
			@num = 0
		end
		haml :search
	else
		redirect "/"
	end
end

get '/new' do
	if session.has_key?('user')
		haml :form
	else
		redirect "/"
	end
end

post '/new' do
	if session.has_key?('user')
		if params.has_key?('nombre') and params.has_key?('apellido') and params.has_key?('telefono') and params.has_key?('direccion')
			db.add_contact(params[:nombre],params[:apellido],params[:telefono],params[:direccion])
		end
	end
		redirect "/"
end

get '/edit' do
	if session.has_key?('user')
		if params.has_key?('id')
			@contact = db.find_one_a_contact(params[:id])
			haml :form2
		else
			redirect "/new"
		end
	else
		redirect "/"
	end
end

post '/edit' do
	if session.has_key?('user')
		if params.has_key?('nombre') and params.has_key?('apellido') and params.has_key?('telefono') and params.has_key?('direccion') and params.has_key?('id')
			db.update_contact(params[:id],params[:nombre],params[:apellido],params[:telefono],params[:direccion])
		end
	end
		redirect "/"
end

get '/delete' do
	if session.has_key?('user')
		if params.has_key?('id')
			db.delete_contact(params[:id])
		end
	end
		redirect "/"
end

get '/logout' do
	session.clear
	redirect "/"
end