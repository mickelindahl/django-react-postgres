from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.conf import settings
from server.models import UserData
from django.core.files import File
import traceback
import os
import pprint

pp = pprint.pprint


@csrf_exempt
def file_upload(request):

    try:

        if request.method == 'POST':

            file = request.FILES['File']
            # file_path = settings.MEDIA_ROOT + '/downloads/' + file.name

            user_data = UserData(user_id=request.user.id, file=file)
            user_data.save()

            # with open(file_path, 'wb+') as destination:
            #     for chunk in file.chunks():
            #         destination.write(chunk)

        response = JsonResponse({
            "message": 'ok'
        })

        return response

    except Exception as ex:

        error = ''.join(traceback.format_exception(etype=type(ex), value=ex, tb=ex.__traceback__))

        response = JsonResponse({"error": error})
        response.status_code = 500

        return response
