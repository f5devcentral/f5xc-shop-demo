# Using pyinstaller to generate binaries

I should provide a script here.
```shell
pip install -r requirements.txt && \
pyinstaller f5xc_resource_ready.py && \
pyinstall f5xc_cred_destroy.py
```

There might be a path problem with pyinstaller in this example.
Adopt the correct path accordingly.

The binary will be located in ``dist``.