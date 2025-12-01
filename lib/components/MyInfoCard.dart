import 'package:flutter/material.dart';

class MyInfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MyInfoCard({
    Key? key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.info, // Ícone padrão se não passar nenhum
    this.iconColor = Colors.blue,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), 
      ),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          // Ícone da Esquerda
          leading: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1), // Fundo clarinho
            child: Icon(icon, color: iconColor),
          ),
          
          // Título (ex: Nome da Rua)
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          
          // Subtítulo (ex: Horário e Capacidade)
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], height: 1.3),
            ),
          ),
          isThreeLine: true, // Permite que o subtítulo tenha mais linhas
          
          // Botões de Ação (Direita)
          trailing: Row(
            mainAxisSize: MainAxisSize.min, // Ocupa o mínimo de espaço possível
            children: [
              // Só mostra o botão se a função for passada
              if (onEdit != null)
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.orange),
                  onPressed: onEdit,
                  tooltip: 'Editar',
                ),
              if (onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Excluir',
                ),
            ],
          ),
        ),
      ),
    );
  }
}