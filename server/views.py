from django.contrib.auth.decorators import login_required
from django.shortcuts import render

@login_required(login_url='/accounts/login/')
def app(request):

    # Create json or whatever object
    # post data to firebase using maybe Request library for example
    return render(request, 'app.html', {})

