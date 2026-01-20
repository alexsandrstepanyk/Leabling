import 'dart:convert'; // Для обробки тексту від ШІ
import 'dart:async'; // Для TimeoutException
import 'package:http/http.dart' as http; // Для зв'язку з інтернетом
import 'package:flutter/material.dart';

void main() => runApp(Flutter_aplication_live());

class Flutter_aplication_live extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Leblings", style: TextStyle(fontSize: 30)),
              SizedBox(height: 20),
              TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email")),
              TextField(controller: _passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text("Register"),
                onPressed: () {
                  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Будь ласка, введіть Email та пароль")));
                    return;
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SurveyScreen()));
                   // Тут ми потім вставимо перехід
                }
              )
            ],
          ),
        ),
      ),
    );
  }
}
// --- ЕКРАН 2: АНКЕТА (ДЕНЬ 4) ---
class SurveyScreen extends StatefulWidget {
  @override
  _SurveyScreenState createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  // Контролери, які "захоплюють" текст, що ви пишете в полях
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _styleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Erstellung eines Profils"),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView( // Дозволяє гортати екран, якщо клавіатура закриває поля
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bring der KI die Persönlichkeit deiner nahestehenden Person bei.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            
            // Поле 1: Ім'я
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Wie hieß er/sie?",
                hintText: "Zum Beispiel: Opa Wasyl",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),

            // Поле 2: Роки життя
            TextField(
              controller: _yearsController,
              decoration: InputDecoration(
                labelText: "Роки життя",
                hintText: "Наприклад: 1945 - 2020",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),

            // Поле 3: Факти та спогади
            TextField(
              controller: _bioController,
              maxLines: 4, // Робимо поле великим
              decoration: InputDecoration(
                labelText: "Головні факти, хобі, спогади",
                hintText: "Що він любив? Чим займався? Що ви хочете, щоб ШІ знав?",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),

            // Поле 4: Манера спілкування
            TextField(
              controller: _styleController,
              decoration: InputDecoration(
                labelText: "Яким був його стиль мови?",
                hintText: "Наприклад: суворий, але добрий; часто жартував",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),

            // Кнопка збереження
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                child: Text("Створити цифровий образ", style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: () {
                  if (_nameController.text.isEmpty || _yearsController.text.isEmpty || _bioController.text.isEmpty || _styleController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Будь ласка, заповніть всі поля анкети")));
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        name: _nameController.text,
                        description: _bioController.text,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// --- ЕКРАН 3: ЧАТ (ДЕНЬ 5) ---
class ChatScreen extends StatefulWidget {
  final String name;        // Ім'я, яке ми ввели в анкеті
  final String description; // Опис людини з анкети

  ChatScreen({required this.name, required this.description});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  
  // Список повідомлень. Кожне повідомлення має текст і позначку, хто його надіслав.
  final List<Map<String, dynamic>> _messages = [];

  // --- OLLAMA (ЛОКАЛЬНО) ---
  Future<String> getAIResponse(String userMessage) async {
    var url = Uri.parse("http://localhost:11434/api/chat");

    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json; charset=utf-8",
        },
        body: jsonEncode({
          "model": "llama2",
          "messages": [
            {
              "role": "system", 
              "content": "Ти — цифровий образ людини на ім'я ${widget.name}. Твої спогади: ${widget.description}. Відповідай як ця людина. Будь дружелюбна та теплою."
            },
            {"role": "user", "content": userMessage}
          ],
          "stream": false
        }),
      ).timeout(Duration(seconds: 60));

      if (response.statusCode == 200) {
        var data = jsonDecode(utf8.decode(response.bodyBytes));
        print("✅ Відповідь від Ollama: $data");
        
        if (data['message'] != null && data['message']['content'] != null) {
          return data['message']['content'];
        } else {
          return "❌ Немає відповіді від Ollama";
        }
      } else {
        var errorBody = utf8.decode(response.bodyBytes);
        print("❌ Помилка від Ollama: $errorBody");
        return "❌ Помилка від Ollama:\nHTTP ${response.statusCode}";
      }
    } on TimeoutException {
      return "❌ Таймаут: Ollama занадто довго відповідає (>60 сек)\nПереконайтеся, що сервер запущений: ollama serve";
    } catch (e) {
      print("❌ Помилка підключення: $e");
      return "❌ Не вдалося з'єднатися з Ollama на localhost:11434\nЗапустіть: ollama serve";
    }
  }

  // Далі йде ваш старий метод _sendMessage
  void _sendMessage() async {
    if (_messageController.text.isEmpty) return;
    
    String userText = _messageController.text;

    setState(() {
      // Додаємо ваше повідомлення
      _messages.insert(0, {"text": userText, "isUser": true});
    });

    _messageController.clear();

    // Отримуємо реальну відповідь від ШІ
    String aiResponse = await getAIResponse(userText);

    setState(() {
      // Додаємо відповідь від ШІ
      _messages.insert(0, {"text": aiResponse, "isUser": false});
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Розмова з: ${widget.name}"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          // Область з повідомленнями
          Expanded(
            child: ListView.builder(
              reverse: true, // Повідомлення йдуть знизу вгору
              padding: EdgeInsets.all(15),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg["text"], msg["isUser"]);
              },
            ),
          ),
          
          // Поле вводу тексту
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Напишіть щось...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueGrey),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Віджет "Хмарка повідомлення"
  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueGrey[100] : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: isUser ? Radius.circular(15) : Radius.circular(0),
            bottomRight: isUser ? Radius.circular(0) : Radius.circular(15),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}