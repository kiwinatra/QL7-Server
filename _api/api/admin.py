from django.contrib import admin
from .models import *  

for model in [obj for name, obj in locals().items() if isinstance(obj, type) and issubclass(obj, models.Model)]:
    try:
        admin.site.register(model)
    except admin.sites.AlreadyRegistered:
        pass