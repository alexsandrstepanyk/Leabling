// ========================================
// ІМПОРТИ - підключення необхідних бібліотек
// ========================================
import 'dart:convert'; // Для конвертації JSON (перетворення даних у текст і назад)
import 'dart:async'; // Для роботи з асинхронними операціями та таймаутами
import 'package:http/http.dart' as http; // Для HTTP-запитів до Ollama API
import 'package:flutter/material.dart'; // Основна бібліотека Flutter для UI
import 'package:shared_preferences/shared_preferences.dart'; // Для збереження даних локально (історія чату)

// ========================================
// ТОЧКА ВХОДУ В ДОДАТОК
// ========================================
void main() => runApp(Flutter_aplication_live()); // Запускає додаток, створюючи головний віджет

// ========================================
// ГОЛОВНИЙ ВІДЖЕТ ДОДАТКУ (без стану)
// ========================================
class Flutter_aplication_live extends StatelessWidget {
  const Flutter_aplication_live({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blueGrey), // Основна колірна схема додатку
      home: LoginScreen(), // Перший екран, який бачить користувач (екран входу)
    );
  }
}

// ========================================
// ЕКРАН 1: ЛОГІН / РЕЄСТРАЦІЯ
// ========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Контролери для захоплення тексту з полів вводу
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // ВАЖЛИВО: Звільняємо ресурси при закритті екрану
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30), // Відступи від країв екрану
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Центруємо вміст по вертикалі
            children: [
              // Логотип / Назва додатку
              Text("Leblings", style: TextStyle(fontSize: 30)),
              SizedBox(height: 20), // Відступ
              
              // Поле для Email
              TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email")),
              
              // Поле для паролю (з прихованням тексту)
              TextField(controller: _passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
              
              SizedBox(height: 20), // Відступ
              
              // Кнопка реєстрації
              ElevatedButton(
                child: Text("Register"),
                onPressed: () {
                  // Перевірка: чи заповнені обидва поля
                  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Будь ласка, введіть Email та пароль")));
                    return;
                  }
                  // Переходимо на екран анкети (SurveyScreen)
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SurveyScreen()));
                }
              )
            ],
          ),
        ),
      ),
    );
  }
}
// ========================================
// ЕКРАН 2: АНКЕТА (створення профілю померлої людини)
// ========================================
class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  _SurveyScreenState createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  // Контролери для захоплення інформації про померлу людину
  final TextEditingController _nameController = TextEditingController(); // Ім'я
  final TextEditingController _yearsController = TextEditingController(); // Роки життя
  final TextEditingController _bioController = TextEditingController(); // Біографія, спогади
  final TextEditingController _styleController = TextEditingController(); // Стиль спілкування

  @override
  void dispose() {
    // ВАЖЛИВО: Звільняємо ресурси при закритті екрану
    _nameController.dispose();
    _yearsController.dispose();
    _bioController.dispose();
    _styleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Erstellung eines Profils"), // "Створення профілю"
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView( // Дозволяє прокручувати екран, якщо клавіатура закриває поля
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Text(
              "Bring der KI die Persönlichkeit deiner nahestehenden Person bei.", // "Навчіть ШІ особистості вашої близької людини"
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            
            // === ПОЛЕ 1: Ім'я ===
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Wie hieß er/sie?", // "Як його/її звали?"
                hintText: "Zum Beispiel: Opa Wasyl", // "Наприклад: Дідо Василь"
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),

            // === ПОЛЕ 2: Роки життя ===
            TextField(
              controller: _yearsController,
              decoration: InputDecoration(
                labelText: "Роки життя",
                hintText: "Наприклад: 1945 - 2020",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),

            // === ПОЛЕ 3: Біографія, спогади, хобі ===
            TextField(
              controller: _bioController,
              maxLines: 4, // Багаторядкове поле
              decoration: InputDecoration(
                labelText: "Головні факти, хобі, спогади",
                hintText: "Що він любив? Чим займався? Що ви хочете, щоб ШІ знав?",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),

            // === ПОЛЕ 4: Стиль спілкування ===
            TextField(
              controller: _styleController,
              decoration: InputDecoration(
                labelText: "Яким був його стиль мови?",
                hintText: "Наприклад: суворий, але добрий; часто жартував",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),

            // === КНОПКА: Створити цифровий образ ===
            SizedBox(
              width: double.infinity, // Кнопка на всю ширину екрану
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                child: Text("Створити цифровий образ", style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: () {
                  // Перевірка: чи всі поля заповнені
                  if (_nameController.text.isEmpty || _yearsController.text.isEmpty || _bioController.text.isEmpty || _styleController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Будь ласка, заповніть всі поля анкети")));
                    return;
                  }
                  // Переходимо на екран чату, передаючи ім'я та опис
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
// ========================================
// ЕКРАН 3: ЧАТ З ШІ (головний функціонал)
// ========================================
class ChatScreen extends StatefulWidget {
  final String name;        // Ім'я померлої людини (передається з анкети)
  final String description; // Опис/біографія (передається з анкети)

  const ChatScreen({super.key, required this.name, required this.description});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Контролер для поля вводу повідомлень
  final TextEditingController _messageController = TextEditingController();
  
  // Список усіх повідомлень у чаті
  // Кожне повідомлення - це Map з полями: "text" (текст) та "isUser" (true/false - від користувача чи від AI)
  final List<Map<String, dynamic>> _messages = [];

  // Прапорець для запобігання багаторазовому надсиланню
  bool _isSending = false;

  @override
  void dispose() {
    // ВАЖЛИВО: Звільняємо ресурси при закритті екрану
    _messageController.dispose();
    super.dispose();
  }

  // ========================================
  // ІНІЦІАЛІЗАЦІЯ: виконується при відкритті чату
  // ========================================
  @override
  void initState() {
    super.initState();
    _loadMessages(); // Завантажуємо збережену історію чату
  }

  // ========================================
  // ЗАВАНТАЖЕННЯ історії з локального сховища
  // ========================================
  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance(); // Отримуємо доступ до локального сховища
      final String? messagesJson = prefs.getString('chat_history_${widget.name}'); // Шукаємо історію для цього імені
      
      if (messagesJson != null) {
        final List<dynamic> decoded = jsonDecode(messagesJson); // Перетворюємо JSON-текст у список
        setState(() {
          _messages.addAll(decoded.cast<Map<String, dynamic>>()); // Додаємо повідомлення до списку
        });
      }
    } catch (e) {
      print('❌ Помилка при завантаженні історії: $e');
      // Якщо дані пошкоджені - просто починаємо з порожньої історії
    }
  }

  // ========================================
  // ЗБЕРЕЖЕННЯ історії в локальне сховище
  // ========================================
  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String messagesJson = jsonEncode(_messages); // Перетворюємо список повідомлень у JSON-текст
      await prefs.setString('chat_history_${widget.name}', messagesJson); // Зберігаємо під унікальним ключем (ім'я людини)
    } catch (e) {
      print('❌ Помилка при збереженні історії: $e');
      // Продовжуємо роботу навіть якщо не вдалося зберегти
    }
  }

  // ========================================
  // ОТРИМАННЯ ВІДПОВІДІ від Ollama AI
  // ========================================
  Future<String> getAIResponse(String userMessage) async {
    var url = Uri.parse("http://localhost:11434/api/chat"); // Адреса локального Ollama сервера

    // === Формуємо історію розмови для AI ===
    List<Map<String, String>> conversationHistory = [
      {
        "role": "system", // Системний промпт - інструкції для AI
        "content": "Ти — цифровий образ людини на ім'я ${widget.name}. Твої спогади: ${widget.description}. Відповідай як ця людина. Будь дружелюбна та теплою. ВАЖЛИВО: Завжди відповідай українською мовою, навіть якщо питання задане іншою мовою."
      }
    ];

    // === Додаємо історію попередніх повідомлень (останні 20 для економії пам'яті) ===
    int historyLimit = _messages.length > 20 ? 20 : _messages.length;
    for (int i = historyLimit - 1; i >= 0; i--) {
      conversationHistory.add({
        "role": _messages[i]["isUser"] ? "user" : "assistant", // user = людина, assistant = AI
        "content": _messages[i]["text"]
      });
    }

    // === Додаємо поточне повідомлення користувача ===
    conversationHistory.add({"role": "user", "content": userMessage});

    try {
      // === Відправляємо HTTP POST запит до Ollama ===
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json; charset=utf-8", // Вказуємо, що відправляємо JSON в UTF-8
        },
        body: jsonEncode({
          "model": "mistral", // Назва AI моделі (mistral підтримує українську)
          "messages": conversationHistory, // Вся історія розмови
          "stream": false // Не використовуємо потоковий режим (чекаємо повної відповіді)
        }),
      ).timeout(Duration(seconds: 60)); // Максимум 60 секунд на відповідь

      // === Обробка успішної відповіді ===
      if (response.statusCode == 200) {
        var data = jsonDecode(utf8.decode(response.bodyBytes)); // Декодуємо JSON-відповідь
        print("✅ Відповідь від Ollama: $data"); // Виводимо для дебагу
        
        // Перевіряємо, чи є текст відповіді
        if (data['message'] != null && data['message']['content'] != null) {
          return data['message']['content']; // Повертаємо текст від AI
        } else {
          return "❌ Немає відповіді від Ollama";
        }
      } else {
        // === Обробка помилки HTTP ===
        var errorBody = utf8.decode(response.bodyBytes);
        print("❌ Помилка від Ollama: $errorBody");
        return "❌ Помилка від Ollama:\nHTTP ${response.statusCode}";
      }
    } on TimeoutException {
      // === Обробка таймауту (занадто довга відповідь) ===
      return "❌ Таймаут: Ollama занадто довго відповідає (>60 сек)\nПереконайтеся, що сервер запущений: ollama serve";
    } catch (e) {
      // === Обробка інших помилок (наприклад, сервер не запущений) ===
      print("❌ Помилка підключення: $e");
      return "❌ Не вдалося з'єднатися з Ollama на localhost:11434\nЗапустіть: ollama serve";
    }
  }

  // ========================================
  // ВІДПРАВКА ПОВІДОМЛЕННЯ (обробка кліку на кнопку "Надіслати")
  // ========================================
  void _sendMessage() async {
    // ЗАХИСТ: Якщо поле порожнє або вже надсилається повідомлення - нічого не робимо
    if (_messageController.text.isEmpty || _isSending) return;
    
    String userText = _messageController.text; // Зберігаємо текст повідомлення

    // Встановлюємо прапорець, що йде надсилання
    setState(() {
      _isSending = true;
    });

    // === Додаємо повідомлення користувача до чату ===
    setState(() {
      _messages.insert(0, {"text": userText, "isUser": true}); // Додаємо на початок списку
    });
    await _saveMessages(); // Зберігаємо історію

    _messageController.clear(); // Очищаємо поле вводу

    // === Отримуємо відповідь від AI ===
    String aiResponse = await getAIResponse(userText);

    // === Додаємо відповідь AI до чату ===
    setState(() {
      _messages.insert(0, {"text": aiResponse, "isUser": false}); // isUser: false = повідомлення від AI
      _isSending = false; // Знімаємо блокування
    });
    await _saveMessages(); // Зберігаємо оновлену історію
  }
  // ========================================
  // ПОБУДОВА ІНТЕРФЕЙСУ чату
  // ========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // === Верхня панель (AppBar) ===
      appBar: AppBar(
        title: Text("Розмова з: ${widget.name}"), // Показуємо ім'я померлої людини
        backgroundColor: Colors.blueGrey,
      ),
      
      body: Column(
        children: [
          // === ОБЛАСТЬ З ПОВІДОМЛЕННЯМИ ===
          Expanded(
            child: ListView.builder(
              reverse: true, // Повідомлення йдуть знизу вгору (як у Telegram)
              padding: EdgeInsets.all(15),
              itemCount: _messages.length, // Кількість повідомлень
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg["text"], msg["isUser"]); // Створюємо "хмарку" для кожного повідомлення
              },
            ),
          ),
          
          // === ПОЛЕ ВВОДУ ТЕКСТУ (знизу екрану) ===
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: Colors.white,
            child: Row(
              children: [
                // Поле для вводу тексту
                Expanded(
                  child: TextField(
                    controller: _messageController, // Контролер для захоплення тексту
                    decoration: InputDecoration(
                      hintText: "Напишіть щось...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)), // Заокруглені краї
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                // Кнопка "Надіслати"
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueGrey),
                  onPressed: _sendMessage, // Викликає метод _sendMessage при кліку
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // ВІДЖЕТ "ХМАРКА ПОВІДОМЛЕННЯ"
  // Створює візуальне оформлення для кожного повідомлення
  // ========================================
  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      // Вирівнювання: якщо від користувача - праворуч, якщо від AI - ліворуч
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5), // Відступи між повідомленнями
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10), // Внутрішні відступи
        decoration: BoxDecoration(
          // Колір: користувач - світло-сірий, AI - темно-сірий
          color: isUser ? Colors.blueGrey[100] : Colors.grey[300],
          // Заокруглені кути (хвостик вказує на відправника)
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: isUser ? Radius.circular(15) : Radius.circular(0), // Хвостик ліворуч для AI
            bottomRight: isUser ? Radius.circular(0) : Radius.circular(15), // Хвостик праворуч для користувача
          ),
        ),
        child: Text(
          text, // Текст повідомлення
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}