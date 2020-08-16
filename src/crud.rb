require 'sqlite3'

$db = SQLite3::Database.new '../db/banco.db'
$db.execute "CREATE TABLE IF NOT EXISTS produtos(cod TEXT, prod TEXT, prec FLOAT)"

def db_insert a, b, c
    if a.nil? or b.nil? or c.nil? 
        return Exception
    end
    $db.execute "INSERT INTO produtos (cod, prod, prec) VALUES(?, ?, ?)", a, b, c
end

def db_query cod
    lista = []
    if cod.nil? 
        return lista 
    end
    itens = $db.query "SELECT cod, prod, prec FROM produtos WHERE cod=?", cod
    itens.each do |results| 
        lista.push results
    end
    return lista
end

def db_search busca
    lista = [] 
    achado = $db.query "SELECT cod, prod, prec FROM produtos WHERE prod LIKE?", '%' + busca + '%'
    achado.each do |vals| 
        lista.push vals
    end
    return lista
end

def db_security nome
    lista = [] 
    achado = $db.query "SELECT nome, senha FROM usuarios WHERE nome=?", nome 
    achado.each do |vals| 
        lista.push vals
    end
    return lista
end


