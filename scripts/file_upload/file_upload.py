#!/usr/bin/env python3.7

# Based off of code found at
# https://www.tutorialspoint.com/flask/flask_file_uploading.htm

import os
from flask import Flask, request, redirect, url_for, make_response
from werkzeug.utils import secure_filename

NAME = "uploader"
DESTINATION = os.path.realpath(os.path.curdir)

UPLOAD_FORM = f"""\
<p>
    <a href='/html5'>html5 uploader</a>
</p>
<form action="do_upload" method="POST" enctype="multipart/form-data">
    <h1>Upload a file</h1>
    <h2>Destination: {DESTINATION}</h2>
    <input type="file" name="file"/>
    <br />
    <input type="submit"/ value="Upload"/>
</form>
"""
HEADER = f"""\
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
"""

app = Flask(NAME)

@app.route('/')
def upload():
    return f"""\
<html>
    <head>
        {HEADER}
        <title>{NAME.capitalize()}</title>
    </head>
    <body>
        {UPLOAD_FORM}
    </body>
</html>
"""

@app.route('/html5')
def html5_upload():
    return f"""\
<html>
    <head>
        {HEADER}
        <title>{NAME.capitalize()}</title>
    </head>
    <body>
        <script src="{url_for('static', filename='dropzone/dropzone.min.js')}">
        </script>
        <link rel="stylesheet"
            href="{url_for('static', filename='dropzone/dropzone.min.css')}"/>
        <h1>Upload files</h1>
        <h2>Destination: {DESTINATION}</h2>
        <form id="myUploader" action="/do_html5_upload" class="dropzone"
        enctype="multipart/form-data">
        </form>
        <script>
        Dropzone.options.myUploader = {{
            chunking:true,
            retryChunks:true,
            chunkSize:{32*1020*1024}, // Bytes
            maxFilesize:{32*1024} // MB
        }}
        /*
            Dropzone.prototype.accept = function(file, done) {{
                return this.options.accept.call(this, file, done);
            }}
            */
        </script>
    </body>
</html>
"""

@app.route('/do_html5_upload', methods=('GET', 'POST'))
def do_html5_upload():
    if request.method == 'GET':
        return redirect('/html5')
    f = request.files.get('file', '')
    if not f:
        return make_response(("failed", 400))
    path = os.path.join(DESTINATION, secure_filename(f.filename))
    with open(path, 'ab') as dest:
        dest.seek(int(request.form['dzchunkbyteoffset']))
        dest.write(f.stream.read())
    return make_response(('Success', 200))

# @app.route('/do_html5_upload', methods=('GET', 'POST'))
# def do_html5_upload():
#     if request.method == 'GET':
#         return redirect('/html5')
#     for key, f in request.files.items():
#         if key.startswith('file'):
#             dest = os.path.join(DESTINATION, secure_filename(f.filename))
#             f.save(dest)
#     return "Success"


@app.route('/do_upload', methods=('GET', 'POST'))
def do_upload():
    if request.method == 'GET':
        return redirect('/')
    f = request.files['file']
    if not f:
        return redirect('/')
    dest = os.path.join(DESTINATION, secure_filename(f.filename))
    f.save(dest)
    return f"""\
<html>
    <head>
        {HEADER}
        <title>Success!</title>
    </head>
    <body>
        <h1>Success!</h1>
        <p>{f.filename} saved as {dest}</p>
        {UPLOAD_FORM}
    </body>
</html>
"""


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=1337)
