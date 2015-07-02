# Stockman

Стокман - это OpenSource сервер изображений плюс клиентские библиотеки

# API Серверной части

## Работа с единичными изображениями

### Загрузка / обновление изображения
```
POST http://v1.stockman.com/<PROJECT_PRIVATE_KEY>/<IMAGE_PRIVATE_KEY>
```
* `PROJECT_PRIVATE_KEY` - Секретный ключ проекта, получается коснольной утилитой stockman при создании проекта
* `IMAGE_PRIVATE_KEY` - Секретный ключ изображения, получается серверной функцией private_key(IMAGE_UNIQ_KEY)

POST параметры

| Name     | Description | Type |
|:---------|:------------|:-----|
| file     | Загружаемое изображение | File |
| versions | Параметры версий (формат описан ниже) | Hash |

Описание формата версий:
```
{
  <VERSION_NAME>: <PROCESSING_STRING>
}
```

### Получение изображения
```
GET http://v1.stockman.com/<PROJECT_PUBLIC_KEY>/<IMAGE_PUBLIC_KEY>/<PROCESSING_STRING>[.<EXTENSION>]
```
* `PROJECT_PUBLIC_KEY` - Открытй ключ проекта
* `IMAGE_PUBLIC_KEY` - Открытый ключ изображения, если используется не оригинал картинки, а одна из версий, то публичный ключ получается из строки `<IMAGE_PRIVATE_KEY>_<VERSION_NAME>` 
* `EXTENSION` - Разрешение файла, может быть несколько вариантов:
  * Не задано - будет найден первый попавшийся файл с таким `IMAGE_PUBLIC_KEY` и сделан на него redirect
  * Задано, и равно json - будет выдана информация об изображении в формате json
  * Задано, такой файл сеществует - будет отдан соответствующий файл
  * Задано, такой файл не сеществует - будет отдана ошибка 404

Описание JSON ответа:
{
  file_name: 
}

### Удаление изображения
```
DELETE http://v1.stockman.com/<PROJECT_PRIVATE_KEY>/<IMAGE_PRIVATE_KEY>
```
* `PROJECT_PRIVATE_KEY` - Секретный ключ проекта
* `IMAGE_PRIVATE_KEY` - Секретный ключ изображения
* 

# API Консоли

stockman project new : Выдает PROJECT_PRIVATE_KEY
stockman project list : > Выдает список PROJECT_PRIVATE_KEY
stockman project remove <PROJECT_PRIVATE_KEY> : Удаляет всю папку с проектом
