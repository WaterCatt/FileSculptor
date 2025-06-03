# FileSculptor

**FileSculptor** — это гибкая Ruby-библиотека и CLI-инструмент для переименования и организации файлов. Она позволяет обрабатывать как отдельные директории, так и вложенные структуры, используя шаблоны, регулярные выражения и пользовательский код.

---

## 🔧 Возможности

- Переименование файлов по пользовательской логике (Ruby-блок).
- Обработка вложенных директорий (`recursive: true/false`).
- Перемещение файлов в зависимости от имени, расширения, даты и других параметров.
- Обработка коллизий имён (если файл уже существует).
- Журнал ошибок и логгирование действий.
- Создание директорий при необходимости.
- Использование как из Ruby-скриптов, так и из консоли (CLI).

---

## 🖥 Использование: CLI

### Установка CLI после установки библиотеки:

```
gem install file_sculptor

```

### Основные команды:

```
file_sculptor rename ./downloads --recursive
```

```
file_sculptor organize ./photos --rule=date
```

```
file_sculptor organize ./misc --rule=extension --dry-run
```

### Поддерживаемые правила организации:
* extension — группировка по расширению (например .png → Images/)

* first_letter — группировка по первой букве имени файла (cat.png → C/)

* date — по дате создания (photo.jpg → 1.05/)

### Пользовательский шаблон — через Ruby-файл с блоком кода.

```
file_sculptor organize ./docs --script organize_rule.rb
```

### Содержимое organize_rule.rb:

```ruby
Proc.new do |path|
  ext = File.extname(path).delete('.')
  first = File.basename(path)[0].upcase
  "Sorted/#{ext}/#{first}"
end
```

## ⚙️ Конфигурация

### Вы можете передавать опции при инициализации:

```ruby
FileSculptor.new("path/to/dir", recursive: true, dry_run: false, logger: true)
```

## 💻 Использование: API (Ruby) (примерное)

### Переименование файлов 

```ruby
require 'file_sculptor'

sculptor = FileSculptor.new("downloads", recursive: true)

sculptor.rename_files do |path|
  dirname = File.dirname(path)
  ext = File.extname(path)
  base = File.basename(path, ext)
  "#{dirname}/#{base.downcase.gsub(/\s+/, '_')}#{ext}"
end
```
### Организация файлов по типу

```ruby
sculptor.organize_files do |path|
  ext = File.extname(path).delete('.').capitalize
  "Organized/#{ext}"
end
```

### Пример: организация по дате создания

```ruby
sculptor.organize_files do |path|
  date = File.ctime(path).strftime("%-d.%m")
  "Images/#{date}"
end
```



## 🛡 Безопасность и логирование

* Все действия логируются.

* Проверка на существование целевого имени файла.

* Создание целевых директорий, если они отсутствуют.

* Возможность "сухого запуска" (dry_run: true) для предварительного анализа.
