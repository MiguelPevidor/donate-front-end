import 'dart:convert';


import 'Objeto.dart';

Comparator<Instituicao> InstituicaoPorNome= (u1, u2) => u1.nome!.compareTo(u2.nome!);


abstract class TipoInstituicao{
  static final String padrao = "Padrão";
  static final String administrador = "Administrador";
}


class Instituicao extends Objeto{
  String? nome;
  String? tipo;
  String? login;
  String? senha;
  String? endereco;
  String? urlFoto;


  Instituicao({this.nome, this.tipo, this.login, this.senha, this.endereco, this.urlFoto});


  @override
  String toString() {
    return 'Instituicao{id: $id, nome: $nome, tipo: $tipo, login: $login, senha: $senha, endereco: $endereco, urlFoto: $urlFoto}';
  }

  Instituicao.fromMap(Map<String, dynamic> map) : super.fromMap(map){
    nome = map["nome"];
    tipo = map["tipo"];
    login = map["login"];
    senha = map["senha"];
    endereco = map["endereco"];
    urlFoto = map["urlFoto"];
  }

  Map<String, dynamic> toMap(){
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['nome'] = this.nome;
    data['tipo'] = this.tipo;
    data['login'] = this.login;
    data['senha'] = this.senha;
    data['endereco'] = this.endereco;
    data['urlFoto'] = this.urlFoto;
    return data;
  }


}