from django.apps import AppConfig

class ApiConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'api'
    verbose_name = 'API Module'

    def ready(self):

        import api.signals  

        from .services import initialize_api
        initialize_api()