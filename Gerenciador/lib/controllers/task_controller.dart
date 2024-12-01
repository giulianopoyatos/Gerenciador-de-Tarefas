import 'package:get/get.dart';
import 'package:task_management/db/db_helper.dart';
import 'package:task_management/models/task.dart';

class TaskController extends GetxController {
  //Isso irá armazenar os dados e atualizar a interface do usuário.

  @override
  void onReady() {
    getTasks();
    super.onReady();
  }

  final RxList<Task> taskList = List<Task>.empty().obs;

  // Adiciona dados à tabela.
  // Os colchetes duplos significam que são parâmetros nomeados opcionais.
  Future<void> addTask({required Task task}) async {
     await DBHelper.insert(task);
  }

  // Obtem todos os dados da tabela.
  void getTasks() async {
    List<Map<String, dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((data) => new Task.fromJson(data)).toList());
  }

  // Exclui dados da tabela.
  void deleteTask(Task task) async {
    await DBHelper.delete(task);
    getTasks();
  }

  // Atualiza dados na tabela.
  void markTaskCompleted(int? id) async {
    await DBHelper.update(id);
    getTasks();
  }
}
