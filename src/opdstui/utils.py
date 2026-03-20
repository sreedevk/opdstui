def dig(obj, *attrs):
    for attr in attrs:
        if obj is None:
            return None
        obj = getattr(obj, attr, None)
    return obj
