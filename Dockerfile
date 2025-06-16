FROM python:3.10-slim

ENV PYTHONUNBUFFERED=1

# Обновляем pip и устанавливаем нужные библиотеки
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    curl \
    && pip install --upgrade pip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Сначала копируем requirements.txt и устанавливаем зависимости
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Затем копируем остальной код
COPY . .

CMD ["sh", "-c", "python manage.py migrate && gunicorn broma_config.wsgi:application --bind 0.0.0.0:8000"]
