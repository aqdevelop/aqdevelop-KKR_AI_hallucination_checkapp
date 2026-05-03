from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    mock_mode: bool = True

    anthropic_api_key: str = ""
    brave_search_api_key: str = ""
    google_cse_api_key: str = ""
    google_cse_id: str = ""

    extractor_model: str = "claude-haiku-4-5-20251001"
    verifier_model: str = "claude-sonnet-4-6"
    corrector_model: str = "claude-sonnet-4-6"

    max_text_length: int = 5000
    search_results_per_query: int = 6
    cache_ttl_days: int = 30

    cors_origins: str = "*"


settings = Settings()
