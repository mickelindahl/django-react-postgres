"""server URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from . import views
from . import api

urlpatterns = [

                  path('api/file-upload', api.file_upload, name='api pdf'),
                  path('', views.app, name='main'),
                  # path(r'^login/$', auth_views.LoginView, name='login'),
                  # path(r'^logout/$', auth_views.auth_logout, name='logout'),
                  # Add Django site authentication urls (for login, logout, password management)
                  path('accounts/', include('django.contrib.auth.urls')),
                  # Note: Using the above method adds the following URLs with names in square brackets, which can be used to reverse
                  # the URL mappings. You don't have to implement anything else — the above URL mapping automatically maps the below
                  # mentioned URLs.
                  #
                  # accounts/ login/ [name='login']
                  # accounts/ logout/ [name='logout']
                  # a   ccounts/ password_change/ [name='password_change']
                  # accounts/ password_change/done/ [name='password_change_done']
                  # accounts/ password_reset/ [name='password_reset']
                  # accounts/ password_reset/done/ [name='password_reset_done']
                  # accounts/ reset/<uidb64>/<token>/ [name='password_reset_confirm']
                  # accounts/ reset/done/ [name='password_reset_complete']
                  #
                  # The URLs (and implicitly, views) that we just added expect to find their associated templates in a
                  # directory /registration/ somewhere in the templates search path.

                  path('admin/', admin.site.urls),
                  # re_path('', views.app, name='main'),

              ] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
