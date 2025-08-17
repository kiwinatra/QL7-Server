from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)
from . import views

router = DefaultRouter()
router.register(r'users', views.UserViewSet, basename='user')
router.register(r'products', views.ProductViewSet, basename='product')
router.register(r'orders', views.OrderViewSet, basename='order')

urlpatterns = [

    path('', views.api_root),

    path('auth/', include([
        path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
        path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
        path('register/', views.RegisterView.as_view(), name='register'),
    ])),

    path('me/', views.CurrentUserView.as_view(), name='current-user'),

    path('products/search/', views.ProductSearchView.as_view(), name='product-search'),

    path('orders/<int:pk>/cancel/', views.OrderCancelView.as_view(), name='order-cancel'),
    path('orders/<int:pk>/complete/', views.OrderCompleteView.as_view(), name='order-complete'),

    path('', include(router.urls)),

    path('admin/', include([
        path('stats/', views.AdminStatsView.as_view(), name='admin-stats'),
        path('users/<int:pk>/activate/', views.UserActivateView.as_view(), name='user-activate'),
    ])),
]

