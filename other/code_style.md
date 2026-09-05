# C++ Code Style & Чистота Кода
Этот гайд устанавливает базовые правила написания чистого, читаемого и поддерживаемого кода в соответствии с Google C++ Style Guide и общепринятыми лучшими практиками C++.

## 1. Именование (Naming Conventions)

### Переменные и члены класса:

1. Используйте snake_case.

2. Имена должны быть короткими, но описательными.

Пример: std::string table_name;, int items_count;

### Члены класса (private/protected):

Используйте snake_case с закрывающим подчёркиванием.

Это помогает сразу отличить член класса от локальной переменной.

Пример:

```cpp
class MyClass {
 private:
  int data_member_;
  std::string name_;
 public:
  void set_name(const std::string& name) { name_ = name; }
};
```
### Константы класса (Class Constants)
constexpr переменные: kPascalCase

const члены класса: kPascalCase

Статические константы: kPascalCase

Пример:
```cpp
static constexpr double kE = 2.718281828459045;
static constexpr double kSqrt2 = 1.414213562373095;
```

### Структуры
Название структуры: PascalCase

Поля структуры: snake_case (без закрывающего подчёркивания)

Пример:
```cpp
struct UserInfo {
    std::string name;
    int age;
    std::string email_address;
};

```
### Функции и методы:

Используйте PascalCase (также известный как CapitalizedCamelCase).

Пример: CalculateTotalPrice(), OpenFile(), GetUserName()

### Классы, структуры, типы:

Используйте PascalCase.

Пример: class MyClass;, struct UserProfile;, typedef std::vector<Book> BookCollection;

### Константы и макросы (enum values):

Используйте UPPER_CASE с подчёркиваниями.

Пример: 
```cpp
const int MAX_BUFFER_SIZE = 1024;
enum class Color { RED, GREEN_BLUE };
```

### Пространства имён (namespaces):

Используйте snake_case в нижнем регистре.

Пример: 
```cpp 
namespace my_project {}, namespace audio_engine {}
```


## 2. Форматирование
### Отступы: 
Используйте 2 пробела для каждого уровня отступа. Не используйте табы.

### Пробелы вокруг операторов:

Ставьте пробелы вокруг бинарных операторов (=, +, -, ==, && и т.д.).

Пример: 
```cpp 
int x = 5 + 3;
if (a && b) { ... }
```

Не ставьте пробел после унарных операторов (!x, *ptr).

Не ставьте пробел перед запятой или точкой с запятой, но ставьте после.

### Фигурные скобки {}:

Открывающая скобка находится на той же строке, что и оператор.

Закрывающая скобка находится на новой строке.

Пример:

```cpp 
void MyFunction() {
  if (condition) {
    // ...
  } else {
    // ...
  }
}
```

### Длина строки:
Старайтесь не превышать 80 символов в строке. Максимум — 120.

## 3. Общие принципы и лучшие практики

### const — ваш лучший друг:

Помечайте как const всё, что не должно изменяться: параметры функций, методы, переменные.

Пример:
```cpp
void PrintMessage(const std::string& message);
int GetValue() const;
void ProcessData(const std::vector<int>& data);
```

### using вместо typedef:

Для создания псевдонимов типов предпочтительнее использовать using.

Пример: 
```cpp 
using StringList = std::vector<std::string>; (более читаемо, чем typedef).
```

### nullptr вместо NULL или 0:

Всегда используйте nullptr для указателей.

### auto используйте с умом:

Используйте auto, чтобы избежать многословия, когда тип очевиден из контекста.
```cpp
// Хорошо - тип очевиден
auto it = vec.begin();
auto& element = vec[0];  // ссылка
const auto& name = GetName();  // константная ссылка

// Плохо - тип неясен
auto result = ProcessData();  // какой тип?
auto x = 10;  // лучше int x = 10;

// Лучше так
std::unique_ptr<MyClass> ptr = CreateObject();
int x = 10;
```

Не забывайте про выведение ссылок в auto(либо используйте decltype, либо auto&)


### Всегда инициализируйте переменные при объявлении.

Предпочитайте uniform initialization (фигурные скобки {}), где это уместно.

Пример:
```cpp
int count{};
std::vector<int> data = {1, 2, 3};
int x{5};
```

Uniform initialization предотвращает narrowing
```cpp
int x{5.5};  // ошибка компиляции
int x(5.5);  // warning, но компилируется
```