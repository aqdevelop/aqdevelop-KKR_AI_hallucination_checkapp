from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    mock_mode: bool = True

    anthropic_api_key: str = ""
    gemini_api_key: str = ""
    brave_search_api_key: str = ""
    google_cse_api_key: str = ""
    google_cse_id: str = ""
    naver_client_id: str = ""
    naver_client_secret: str = ""

    # Models are routed by name prefix in services/llm.py:
    #   claude-*  → Anthropic, gemini-* → Google Gemini
    extractor_model: str = "gemini-2.5-flash"
    verifier_model: str = "gemini-2.5-flash"
    corrector_model: str = "gemini-2.5-flash"

    max_text_length: int = 5000
    search_results_per_query: int = 6
    cache_ttl_days: int = 30

    cors_origins: str = "*"


settings = Settings()
