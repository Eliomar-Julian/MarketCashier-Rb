# // script de manipulação de bancod de dados 'sqlite3'
# // manipula '../db/banco.db'

require 'sqlite3'

# // criação/conexão com o banco de dados
$db = SQLite3::Database.new '../db/banco.db'
$db.execute "CREATE TABLE IF NOT EXISTS produtos(cod TEXT, prod TEXT, prec FLOAT)"

# // insere os valores -----------------------------------------------------------
def db_insert a, b, c
    if a == "" or b == "" 
        return 'blank'
    end
    $db.execute "INSERT INTO produtos (cod, prod, prec) VALUES(?, ?, ?)", a, b, c
end

# // busca o codigo solicitado ----------------------------------------------------
def db_query cod
    lista = []
    if cod.nil? 
        return lista 
    end
    itens = $db.query "SELECT cod, prod, prec FROM produtos WHERE cod=?", cod
    itens.each { |results| lista.push results }
    return lista
end

# // faz uma busca dinamica a cada tecla precionada. Devolve uma lista com os itens proximos do que foi digitado
def db_search busca
    lista = [] 
    achado = $db.query "SELECT cod, prod, prec FROM produtos WHERE prod LIKE?", '%' + busca + '%'
    achado.map { |vals| lista.push vals }
    return lista
end

# // retorna a lista de tudo o que esta na tabela 'produtos' dentro do banco
def db_listing
    lista = [] 
    achado = $db.query "SELECT * FROM produtos" 
    achado.each do |vals| 
        lista.push vals
    end
    return lista
end

# // remove um produto do banco ------------------------------------------------
def db_remove prod
    $db.query "DELETE FROM produtos WHERE prod=?", prod
end

# // atualiza informaçoes de preço e codigo aos produtos selecionados
def db_update cod, pro, pre 
    $db.query "UPDATE produtos SET cod=? WHERE prod=?",cod, pro
    $db.query "UPDATE produtos SET prec=? WHERE prod=?",pre, pro

end