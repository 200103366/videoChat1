FROM python:3.9.5-slim

ENV PYTHONUNBUFFERED=1

# Установка зависимостей системы
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Установка зависимостей Python
WORKDIR /app
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Копирование кода проекта
COPY . .

# Команда запуска
CMD ["sh", "-c", "python manage.py migrate && gunicorn broma_config.wsgi:application --bind 0.0.0.0:8000"]
FROM python:3.9.5-slim

# Environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# Install system dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Copy project filesMore actions
WORKDIR $PYSETUP_PATH
COPY pyproject.toml poetry.lock ./
RUN poetry config virtualenvs.create false \
 && poetry install --no-root

# Copy the rest of the app
COPY . /app
WORKDIR /app

# Run database migrations and start gunicorn
CMD ["sh", "-c", "python manage.py migrate && gunicorn broma_config.wsgi:application --bind 0.0.0.0:8000"]
