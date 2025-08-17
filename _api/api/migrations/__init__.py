# _api/api/migrations/__init__.py

from django.db.models.signals import post_migrate

def create_initial_data(sender, **kwargs):
    """
    Create initial data after migrations are run.
    """
    if kwargs['app_config'].name == 'api':
        # Your initialization logic here
        pass

post_migrate.connect(create_initial_data)