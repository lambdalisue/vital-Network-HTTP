# -*- coding: utf-8 -*-
#
# NOTE
#   Vim use a global namespace for python/python3 so define a unique name
#   function and write a code inside of the function to prevent conflicts.
#
def __vim_vital_network_http_python():
    import copy, gzip, time, functools
    import collections
    from threading import Lock, Thread
    try:
        from gzip import decompress as gzip_decompress
    except ImportError:
        try:
            from io import ByteIO as StringIO
        except ImportError:
            from StringIO import StringIO
        from gzip import GzipFile
        def gzip_decompress(data):
            buf = StringIO(data)
            f = GzipFile(fileobj=buf)
            return f.read()[:]

    try:
        from urllib.request import (
            build_opener,
            Request,
            HTTPPasswordMgrWithDefaultRealm,
            HTTPRedirectHandler,
            HTTPBasicAuthHandler,
            HTTPDigestAuthHandler,
            HTTPError, URLError,
        )
    except ImportError:
        # Python 2
        import urllib2
        class Request(urllib2.Request):
            def __init__(self, url, data=None, headers={},
                        origin_req_host=None, unverifiable=False, method=None):
                # Note:
                # urllib2.Request is OLD type class
                urllib2.Request.__init__(
                    self, url, data, headers, origin_req_host, unverifiable,
                )
                self.method = method
            def get_method(self):
                if self.method:
                    return self.method
                else:
                    return 'POST' if self.has_data() else 'GET'
        class HTTPRedirectHandler(urllib2.HTTPRedirectHandler):
            def redirect_request(self, req, fp, code, msg, headers, newurl):
                m = req.get_method()
                if (code in (301, 302, 303, 307) and m in ("GET", "HEAD")
                    or code in (301, 302, 303) and m == "POST"):
                    # Strictly (according to RFC 2616), 301 or 302 in response
                    # to a POST MUST NOT cause a redirection without confirmation
                    # from the user (of urllib2, in this case).  In practice,
                    # essentially all clients do redirect in this case, so we
                    # do the same.
                    # be conciliant with URIs containing a space
                    newurl = newurl.replace(' ', '%20')
                    newheaders = dict((k,v) for k,v in req.headers.items()
                                    if k.lower() not in ("content-length", "content-type")
                                    )
                    return Request(newurl,
                                headers=newheaders,
                                origin_req_host=req.get_origin_req_host(),
                                unverifiable=True,
                                method=m)
                else:
                    raise HTTPError(req.get_full_url(), code, msg, headers, fp)
        from urllib2 import (
            build_opener,
            HTTPPasswordMgrWithDefaultRealm,
            HTTPBasicAuthHandler,
            HTTPDigestAuthHandler,
            HTTPError, URLError,
        )

    def format_exception():
        exc_type, exc_obj, tb = sys.exc_info()
        f = tb.tb_frame
        lineno = tb.tb_lineno
        filename = f.f_code.co_filename
        return "%s: %s at %s:%d" % (
            exc_obj.__class__.__name__,
            exc_obj, filename, lineno,
        )

    def request_vim_to_python(request):
        p = copy.deepcopy(request)
        p.update({
            'max_redirect': int(request['max_redirect']),
            'timeout': int(request['timeout']),
            'retry': int(request['retry']),
            'gzip_decompress': bool(int(request['gzip_decompress'])),
            'data': None if not request['data'] else request['data'],
        })
        if p['data']:
            p['data'] = p['data'].encode('utf-8')
        if p['timeout'] == 0:
            p['timeout'] = None
        return p

    def retry(tries=4, delay=2, backoff=2):
        def inner(f):
            @functools.wraps(f)
            def wrap(*args, **kwargs):
                ctries, cdelay = tries, delay
                while ctries > 1:
                    try:
                        return f(*args, **kwargs)
                    except URLError:
                        time.sleep(cdelay)
                        ctries -= 1
                        cdelay *= backoff
                return f(*args, **kwargs)
            return wrap
        return inner

    def open(request):
        request = request_vim_to_python(request)
        rhandler = HTTPRedirectHandler()
        rhandler.max_redirections = request['max_redirect']
        opener = build_opener(rhandler)
        if request['username']:
            passmgr = HTTPPasswordMgrWithDefaultRealm()
            passmgr.add_password(
                None, request['url'],
                request['username'],
                request['password'],
            )
            opener.add_handler(HTTPBasicAuthHandler(passmgr))
            opener.add_handler(HTTPDigestAuthHandler(passmgr))
        req = Request(
            url=request['url'],
            data=request['data'],
            headers=request['headers'],
            method=request['method'],
        )
        if request['gzip_decompress']:
            req.add_header('Accept-encoding', 'gzip')
        try:
            res = retry(tries=request['retry'])(opener.open)(
                req, timeout=request['timeout']
            )
        except HTTPError as e:
            res = e
        if not hasattr(res, 'version'):
            # urllib2 does not have 'version' field
            import httplib
            res.version = httplib.HTTPConnection._http_vsn
        response_status = "HTTP/%s %d %s\n" % (
            '1.1' if res.version == 11 else '1.0',
            res.code, res.msg,
        )
        response_headers = str(res.headers)
        response_body = res.read()
        if (request['gzip_decompress']
                and res.headers.get('Content-Encoding') == 'gzip'):
            response_body = gzip_decompress(response_body)
        if hasattr(res.headers, 'get_content_charset'):
            # Python 3
            response_encoding = res.headers.get_content_charset()
        else:
            # Python 2
            response_encoding = res.headers.getparam('charset')
        response_body = response_body.decode(response_encoding)
        return (
            request['url'],
            response_status + response_headers,
            response_body,
        )

    def _retrieve(lock, requests, responses, indicator='', callback=None):
        try:
            while True:
                request = requests.popleft()
                if callback:
                    callback(lock, indicator % {
                        'url': request['url'],
                        'count': len(responses) + 1,
                    })
                responses.append(open(request))
        except IndexError:
            pass
        except Exception as e:
            # clear queue to stop other threads
            requests.clear()
            responses.append(e)

    def retrieve(requests, settings, callback=None):
        lock = Lock()
        requests  = collections.deque(requests)
        responses = collections.deque()
        indicator = settings.get(
            'indicator',
            'Requesting %%(url)s %%(count)d/%(total)d ...',
        )
        indicator = indicator % {
            'total': len(requests),
        }
        nprocess = int(settings.get('nprocess', 20))
        kwargs = dict(
            target=_retrieve,
            args=(lock, requests, responses, indicator, callback),
        )
        workers = [Thread(**kwargs) for n in range(nprocess)]
        for worker in workers:
            worker.start()
        for worker in workers:
            worker.join()
        # check if sub-thread throw exceptions or not
        exceptions = list(
            filter(lambda x: isinstance(x, Exception), responses)
        )
        if len(exceptions):
            raise exceptions[0]
        return responses

    return {
        'open': open,
        'retrieve': retrieve,
    }


if __name__ == '__main__':
    # Assume that the module is executed for open_async/retrieve_async
    import sys, ast
    import tempfile
    requests = []
    for arg in sys.argv[1:]:
        request = {
            'method': 'GET',
            'data': '',
            'headers': {},
            'output_file': '',
            'timeout': 0,
            'username': '',
            'password': '',
            'max_redirect': 20,
            'retry': 1,
            'gzip_decompress': 0,
        }
        request.update(ast.literal_eval(arg))
        requests.append(request)
    fn = __vim_vital_network_http_python()
    def stderr_callback(lock, indicator):
        import sys
        with lock:
            sys.stderr.write('\r')
            sys.stderr.write(indicator)

    if len(requests) == 1:
        responses = [fn['open'](requests[0])]
    else:
        responses = fn['retrieve'](requests, {})

    for response in responses:
        print(response[0])
        print(response[1])
        print('')
        print(response[2])
else:
    # Assume that the module is loaded from Vim
    import vim
    fn = __vim_vital_network_http_python()
    def vim_callback(lock, indicator):
        with lock:
            vim.command('redraw')
            print(indicator)
    # Execute a main code
    try:
        namespace = vim.bindeval('namespace')
        fname = vim.eval('fname')
        kwargs = vim.eval('kwargs')
        if kwargs.pop('verbose', 1):
            kwargs['callback'] = vim_callback
        if fname == 'open':
            namespace['response'] = open(**kwargs)
        else:
            namespace['responses'] = retrieve(**kwargs)
    except:
        namespace['exception'] = format_exception()
