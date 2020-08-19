require 'sqlite3'

$db = SQLite3::Database.new '../db/banco.db'
$db.execute "CREATE TABLE IF NOT EXISTS produtos(cod TEXT, prod TEXT, prec FLOAT)"

def db_insert a, b, c
    if a == "" or b == "" 
        return 'blank'
    end
    $db.execute "INSERT INTO produtos (cod, prod, prec) VALUES(?, ?, ?)", a, b, c
end

def db_query cod
    lista = []
    if cod.nil? 
        return lista 
    end
    itens = $db.query "SELECT cod, prod, prec FROM produtos WHERE cod=?", cod
    itens.each { |results| lista.push results }
    return lista
end

def db_search busca
    lista = [] 
    achado = $db.query "SELECT cod, prod, prec FROM produtos WHERE prod LIKE?", '%' + busca + '%'
    achado.map { |vals| lista.push vals }
    return lista
end

def db_listing
    lista = [] 
    achado = $db.query "SELECT * FROM produtos" 
    achado.each do |vals| 
        lista.push vals
    end
    return lista
end

def db_remove prod
    $db.query "DELETE FROM produtos WHERE prod=?", prod
end

def db_update cod, pro, pre 
    $db.query "UPDATE produtos SET cod=? WHERE prod=?",cod, pro
    $db.query "UPDATE produtos SET prec=? WHERE prod=?",pre, pro

end