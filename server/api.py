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


def response_wrapper(fun, request, *args, **kwargs):
    try:

        return fun(request, *args, **kwargs)

    except Exception as ex:

        error = ''.join(traceback.format_exception(etype=type(ex), value=ex, tb=ex.__traceback__))

        response = JsonResponse({"error": error})
        response.status_code = 500

        return response


def _app_state(request):
    if request.method == 'GET':
        user_data = UserData.objects.all().filter(user_id=request.user.id)
        response = JsonResponse({
            "userData": list(map(lambda x: {
                "url": x.file.url,
                "name": x.file_name_original,
                "created_at": x.created_at,
                "updated_at": x.updated_at,
                "id": x.id
            }, user_data)),
            "message": 'ok'
        })

        return response


def _file_upload(request):
    if request.method == 'POST':
        file = request.FILES['File']
        user_data = UserData(
            user_id=request.user.id,
            file=file,
            file_name_original=file.name
        )
        user_data.save()

        return JsonResponse({
            "user_data": {
                "url": user_data.file.url,
                "name": user_data.file_name_original,
                "created_at": user_data.created_at,
                "updated_at": user_data.updated_at,
                "id": user_data.id
            },
            "message": 'created'
        })


def _file_upload_file_id(request, file_id):
    print('file_id', file_id)

    if request.method == 'POST':
        file = request.FILES['File']

        user_data = UserData.objects.get(id=file_id)
        old_file_path = user_data.file.path
        user_data.file = file
        user_data.file_name_original = file.name
        os.remove(old_file_path)
        user_data.save()

        return JsonResponse({
            "user_data": {
                "url": user_data.file.url,
                "name": user_data.file_name_original,
                "created_at": user_data.created_at,
                "updated_at": user_data.updated_at,
                "id": user_data.id
            },
            "message": 'updated'
        })

    elif request.method == 'DELETE':
        user_data = UserData.objects.get(id=file_id)
        file_path = user_data.file.path
        user_data.delete()
        os.remove(file_path)

        return JsonResponse({
            "message": 'deleted'
        })


@csrf_exempt
def app_state(request):
    return response_wrapper(_app_state, request)


@csrf_exempt
def file_upload(request):
    return response_wrapper(_file_upload, request)


@csrf_exempt
def file_upload_file_id(request, file_id):
    return response_wrapper(_file_upload_file_id, request, file_id)
