FROM python:3.9.5-slim

# Отключаем буферизацию вывода Python (удобнее для логов)
ENV PYTHONUNBUFFERED=1

# Устанавливаем зависимости для сборки и работы с PostgreSQL
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Указываем рабочую директорию
WORKDIR /app

# Копируем файл зависимостей и устанавливаем пакеты
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Копируем весь исходный код в контейнер
COPY . .

# Команда по умолчанию: миграции + запуск gunicorn
CMD ["sh", "-c", "python manage.py migrate && gunicorn broma_config.wsgi:application --bind 0.0.0.0:8000"]
