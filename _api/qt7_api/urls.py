from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    ProductViewSet,
    UserViewSet,
    OrderViewSet,
    ApiStatsView,
    SearchView,
    ApiDocumentationView
)

app_name = 'qt7_api'


router = DefaultRouter(trailing_slash=False)

# Регистрация ViewSets
router.register(r'log', ProductViewSet)
router.register(r'db', UserViewSet)
router.register(r'payments', OrderViewSet)

# Кастомные endpoints
custom_patterns = [
    path('log/', ApiStatsView.as_view(), name='stats'),
    path('pay/', SearchView.as_view(), name='search'),
    path('reg/', ApiDocumentationView.as_view(), name='docs'),
]

# Основные URL patterns
urlpatterns = [
    path('', include(router.urls)),
    path('', include(custom_patterns)),
    
    # Аутентификация
    path('auth/', include('rest_auth.urls')),
    path('auth/registration/', include('rest_auth.registration.urls')),
]
