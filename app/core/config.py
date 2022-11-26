from pydantic import BaseSettings, Field


class DatabaseConfig(BaseSettings):
    host: str = Field("localhost", env="DATABASE_HOST")
    port: int = Field(3306, env="DATABASE_PORT")
    database: str = Field("chore-management", env="DATABASE_NAME")
    username: str = Field("root", env="DATABASE_USERNAME")
    password: str = Field("root", env="DATABASE_PASSWORD")
    create_database: bool = Field(False, env="CREATE_DATABASE")
    disable_migrations: bool = Field(False, env="DISABLE_MIGRATIONS")

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


class RedisConfig(BaseSettings):
    host: str = Field("localhost", env="REDIS_HOST")
    port: int = Field(6379, env="REDIS_PORT")

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


class Config(BaseSettings):
    redis: RedisConfig
    database: DatabaseConfig
    admin_api_key: str = Field(..., env="ADMIN_API_KEY")
    application_secret: str = Field(..., env="APPLICATION_SECRET")

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Config(redis=RedisConfig(), database=DatabaseConfig())
