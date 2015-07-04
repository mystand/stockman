# Stockman

Стокман - это OpenSource сервер изображений плюс клиентские библиотеки

# API Серверной части

## Работа с единичными изображениями

### Загрузка / обновление изображения
```
POST /<PROJECT_PRIVATE_KEY>/<IMAGE_PRIVATE_KEY>
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
Cервер вернет: 
В случае успеха пустой json {} с кодом 200
В случае ошибки код json формата
{
  errors: [<ERROR_CODE>...]
}
с http кодом ошибки (пока всегда 500)

### Получение изображения
```
GET /<PROJECT_PUBLIC_KEY>/<IMAGE_PUBLIC_KEY>[/<PROCESSING_STRING>][.<EXTENSION>]
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
  size: <SIZE>,
  extension: <EXTENSION>,
  dementions: <DEMENTIONS>
}

### Удаление изображения
```
DELETE /<PROJECT_PRIVATE_KEY>/<IMAGE_PRIVATE_KEY>
```
* `PROJECT_PRIVATE_KEY` - Секретный ключ проекта
* `IMAGE_PRIVATE_KEY` - Секретный ключ изображения
 
Cервер вернет: 
В случае успеха ответ с кодом 200
В случае ошибки ответ с кодом ошибки (404 если не нашли галерею или 500 если внутренняя ошибка) и json-ом следующего вида:
```
{
  errors: [<ERROR_CODE>...]
}

## Работа с галереями

### Загрузка / обновление галери
```
POST /<PROJECT_PRIVATE_KEY>/galleries/<GALLERY_PRIVATE_KEY>
```
* `PROJECT_PRIVATE_KEY` - Секретный ключ проекта, получается коснольной утилитой stockman при создании проекта
* `GALLERY_PRIVATE_KEY` - Секретный ключ галлереи, получается серверной функцией private_key(GALLERY_UNIQ_KEY)

POST параметры

| Name     | Description | Type |
|:---------|:------------|:-----|
| files     | Загружаемые изображения | массив File |
| versions | Параметры версий (формат описан ниже) | Hash |

```
[
    {
        "id": <ITEM_ID>,
        "versions": {
            <ITEM_VERSION_NAME>: <ITEM_PROCESSING_STRING>
            ...
        }
    },
    ...
]
```

Cервер вернет: 
В случае успеха пустой json {} с кодом 200
В случае ошибки код json формата
```
{
  errors: [<ERROR_CODE>...]
}
```
с http кодом ошибки (пока всегда 500)

### Запрос галери
```
GET /<PROJECT_PUBLIC_KEY>/galleries/<GALLERY_PUBLIC_KEY>
```
* `PROJECT_PUBLIC_KEY` - Открытый ключ проекта
* `GALLERY_PUBLIC_KEY` - Открытый ключ галереи

Cервер вернет: 
В случае успеха ответ с кодом 200 и json-ом следующего вида:
```
{
  count: <IMAGES_COUNT>,
  images: [
    origin: <IMAGE_PUBLIC_KEY>,
    <VERSION_NAME>: <IMAGE_PUBLIC_KEY>
    ...
  ]
}
```
В случае ошибки ответ с кодом ошибки (404 если не нашли галерею или 500 если внутренняя ошибка) и json-ом следующего вида:
```
{
  errors: [<ERROR_CODE>...]
}
```

### Удаление галери
```
DELETE /<PROJECT_PRIVATE_KEY>/galleries/<GALLERY_PRIVATE_KEY>
```
* `PROJECT_PRIVATE_KEY` - Секретный ключ проекта, получается коснольной утилитой stockman при создании проекта
* `GALLERY_PRIVATE_KEY` - Секретный ключ галлереи, получается серверной функцией private_key(GALLERY_UNIQ_KEY)

Cервер вернет: 
В случае успеха ответ с кодом 200
В случае ошибки ответ с кодом ошибки (404 если не нашли галерею или 500 если внутренняя ошибка) и json-ом следующего вида:
```
{
  errors: [<ERROR_CODE>...]
}
```

# API Консоли

stockman project new : Выдает PROJECT_PRIVATE_KEY
stockman project list : > Выдает список PROJECT_PRIVATE_KEY
stockman project remove <PROJECT_PRIVATE_KEY> : Удаляет всю папку с проектом
