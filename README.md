# NEX Backend

FastAPI backend for the NEX Project.

## Setup

1.  **Create a virtual environment:**
    ```bash
    python -m venv venv
    .\venv\Scripts\activate
    ```

2.  **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

3.  **Configure Environment:**
    Create a `.env` file in the `nex_backend` directory (same level as `app` folder):
    ```env
    POSTGRES_USER=postgres
    POSTGRES_PASSWORD=your_password
    POSTGRES_SERVER=localhost
    POSTGRES_DB=nex_db
    SECRET_KEY=your_secret_key
    ```
    *Note: Ensure you have PostgreSQL installed and the database `nex_db` created.*

4.  **Run the Server:**
    ```bash
    uvicorn app.main:app --reload
    ```

## API Documentation

Once the server is running, visit:
- **Swagger UI:** `http://127.0.0.1:8000/docs`
- **Reocm:** `http://127.0.0.1:8000/redoc`

## Project Structure

- `app/main.py`: Entry point.
- `app/core/`: Configuration and database connection.
- `app/models/`: SQLAlchemy ORM models.
- `app/schemas/`: Pydantic schemas.
- `app/api/`: API endpoints.
