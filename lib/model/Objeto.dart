
abstract class Objeto{
  late String id;

  Objeto();

  Objeto.fromMap(Map<String, dynamic> map){
    id = map["id"];
  }

}