from django.db import models
from datetime import datetime


def user_directory_path(instance, filename):
    # file will be uploaded to MEDIA_ROOT/user_<id>/<filename>

    now = datetime.now()  # current date and time
    date_time = now.strftime("%Y%m%d_%H%M%S")
    tmp = filename.split('.')
    tmp[0] = tmp[0] + '_' + date_time
    filename = '.'.join(tmp)

    return 'user_{0}/{1}'.format(instance.user_id, filename)


class UserData(models.Model):
    file = models.FileField(upload_to=user_directory_path)
    user_id = models.IntegerField()

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
