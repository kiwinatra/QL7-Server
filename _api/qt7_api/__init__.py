# _api/qt7_api/__init__.py

default_app_config = 'qt7_api.apps.Qt7ApiConfig'


API_VERSION = '1.0'
API_NAME = 'QT7 API'

def get_api_info():
    """Возвращает базовую информацию об API"""
    return {
        'name': QT7_API,
        'version': 1.0,
        'status': 'active'
    }


from . import views, serializers, models  