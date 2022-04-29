from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.conf import settings
from django.core import serializers
from server.models import UserData
from django.core.files import File
import traceback
import os
import pprint
import json

pp = pprint.pprint


@csrf_exempt
def app_state(request):
    try:

        if request.method == 'GET':
            user_data = UserData.objects.all().filter(user_id=request.user.id)
            # print(user_data[0].file.name, user_data[0].file.url)
            # print(serializers.serialize("json", user_data[0].file))
            # user_data = serializers.serialize("json", user_data)
            # print('map(lambda x:x,user_data)',list(map(lambda x:{"x":x.file.url},user_data)))
            # print('json.parse(user_data)', user_data)
            response = JsonResponse({
                "userData":list(map(lambda x: {
                    "url": x.file.url,
                    "name": x.file_name_original,
                    "created_at": x.created_at,
                    "id": x.id
                }, user_data)),
                "message": 'ok'
            })

            return response

    except Exception as ex:

        error = ''.join(traceback.format_exception(etype=type(ex), value=ex, tb=ex.__traceback__))

        response = JsonResponse({"error": error})
        response.status_code = 500

        return response


@csrf_exempt
def file_upload(request):
    try:

        if request.method == 'POST':
            file = request.FILES['File']
            user_data = UserData(
                user_id=request.user.id,
                file=file,
                file_name_original=file.name
            )
            user_data.save()

        response = JsonResponse({
            "user_data":{
                    "url": user_data.file.url,
                    "name": user_data.file_name_original,
                    "created_at": user_data.created_at,
                    "id": user_data.id
                },
            "message": 'ok'
        })

        return response

    except Exception as ex:

        error = ''.join(traceback.format_exception(etype=type(ex), value=ex, tb=ex.__traceback__))

        response = JsonResponse({"error": error})
        response.status_code = 500

        return response
