let s:save_cpo = &cpo
set cpo&vim

let s:registry = {}
let s:priority = []

function! s:_vital_loaded(V) abort
  let s:Prelude = a:V.import('Prelude')
  let s:String = a:V.import('Data.String')
endfunction
function! s:_vital_depends() abort
  return ['Prelude', 'Data.String']
endfunction
function! s:_vital_created(module) abort
  call s:register('python', 'Network.HTTP.Python')
  call s:register('curl', 'Network.HTTP.CURL')
  call s:register('wget', 'Network.HTTP.WGET')
endfunction

function! s:_throw(msg) abort
  throw printf('vital: Network.HTTP: %s', a:msg)
endfunction
function! s:_get_default_request() abort
  return {
        \ 'method': 'GET',
        \ 'params': {},
        \ 'data': '',
        \ 'headers': {},
        \ 'content_type': '',
        \ 'output_file': '',
        \ 'timeout': 0,
        \ 'username': '',
        \ 'password': '',
        \ 'max_redirection': 20,
        \ 'retry': 1,
        \ 'auth_method': '',
        \ 'gzip_decompress': 0,
        \}
endfunction
function! s:__urlencode_char(c) abort
  return printf('%%%02X', char2nr(a:c))
endfunction

function! s:register(name, ...) abort
  let alias = get(a:000, 0, a:name)
  let s:registry[alias] = s:V.import(a:name)
  call add(s:priority, alias)
endfunction

function! s:decodeURI(str) abort
  let ret = a:str
  let ret = substitute(ret, '+', ' ', 'g')
  let ret = substitute(ret, '%\(\x\x\)', '\=printf("%c", str2nr(submatch(1), 16))', 'g')
  return ret
endfunction
function! s:escape(str) abort
  let result = ''
  for i in range(len(a:str))
    if a:str[i] =~# '^[a-zA-Z0-9_.~-]$'
      let result .= a:str[i]
    else
      let result .= s:__urlencode_char(a:str[i])
    endif
  endfor
  return result
endfunction
function! s:encodeURI(items) abort
  let ret = ''
  if s:Prelude.is_dict(a:items)
    for key in sort(keys(a:items))
      if strlen(ret)
        let ret .= '&'
      endif
      let ret .= key . '=' . s:encodeURI(a:items[key])
    endfor
  elseif s:Prelude.is_list(a:items)
    for item in sort(a:items)
      if strlen(ret)
        let ret .= '&'
      endif
      let ret .= item
    endfor
  else
    let ret = s:escape(a:items)
  endif
  return ret
endfunction
function! s:encodeURIComponent(items) abort
  let ret = ''
  if s:Prelude.is_dict(a:items)
    for key in sort(keys(a:items))
      if strlen(ret) | let ret .= '&' | endif
      let ret .= key . '=' . s:encodeURIComponent(a:items[key])
    endfor
  elseif s:Prelude.is_list(a:items)
    for item in sort(a:items)
      if strlen(ret) | let ret .= '&' | endif
      let ret .= item
    endfor
  else
    let items = iconv(a:items, &enc, 'utf-8')
    let len = strlen(items)
    let i = 0
    while i < len
      let ch = items[i]
      if ch =~# '[0-9A-Za-z-._~!''()*]'
        let ret .= ch
      elseif ch == ' '
        let ret .= '+'
      else
        let ret .= '%' . substitute('0' . s:String.nr2hex(char2nr(ch)), '^.*\(..\)$', '\1', '')
      endif
      let i = i + 1
    endwhile
  endif
  return ret
endfunction


" request({settings})
" request({url}[, {settings}])
" request({method}, {url}[, {settings}])
function! s:_request(settings) abort
  let settings = extend({
        \ 'method': 'GET',
        \ 'params': {},
        \ 'data': '',
        \ 'headers': {},
        \ 'content_type': '',
        \ 'output_file': '',
        \ 'timeout': 0,
        \ 'username': '',
        \ 'password': '',
        \ 'max_redirection': 20,
        \ 'retry': 1,
        \ 'auth_method': '',
        \ 'gzip_decompress': 0,
        \}, a:settings
        \)
  if !has_key(settings, 'url')
    call s:_throw('"url" parameter is required')
  endif
  
  if !empty(settings, 'content_type')
    let settings.headers['Content-Type'] = settings.content_type
  endif
  if !empty(settings, 'params')
    let param = s:encodeURI(settings.params)
    if strlen(param)
      let settings.url = printf('%s?%s', settings.url, param)
    endif
  endif
  if !empty(settings, 'data')
    if s:Prelude.is_dict(settings.data)
      let data = [s:encodeURI(settings.data)]
    elseif s:Prelude.is_list(settings.data)
      let data = settings.data
    else
      let data = split(settings.data, "\n")
    endif
    unlet! settings.data
    let settings.data = data
    let settings.headers['Content-Length'] = len(join(settings.data, "\n"))
  endif
  if settings.gzip_decompress
    let settings.headers['Accept-encoding'] = 'gzip'
  endif
  return settings
endfunction
function! s:request(...) abort
  if a:0 == 0
    call s:_throw('request() require at least one argument')
  elseif a:0 == 1
    if s:Prelude.is_string(a:1)
      " settings({url})
      let settings = {}
      let settings.url = a:1
    else
      " settings({settings})
      let settings = a:1
    endif
  elseif a:0 == 2
    if s:Prelude.is_string(a:2)
      " settings({method}, {url})
      let settings = {}
      let settings.url = a:2
      let settings.method = a:1
    else
      " settings({url}, {settings})
      let settings = a:2
      let settings.url = a:1
    endif
  elseif a:0 == 3
    " settings({method}, {url}, {settings})
    let settings = a:3
    let settings.url = a:2
    let settings.method = a:1
  else
    call s:_throw('The maximum number of arguments of request() is 3')
  endif
  return s:_request(settings)
endfunction

" open({request}[, {settings}])
function! s:open(request, ...) abort
  let request = extend(
        \ s:_get_default_request(),
        \ a:request,
        \)
  let settings = extend({
        \ 'clients': copy(s:priority),
        \}, get(a:000, 0, {})
        \)
  for client in settings.clients
    if !client.is_open_supported(request)
      continue
    endif
    return client.open(request, settings)
  endfor
  call s:_throw('Not supported')
endfunction

" open_async({request}[, {settings}])
function! s:open_async(request, ...) abort
  let request = extend(
        \ s:_get_default_request(),
        \ a:request,
        \)
  let settings = extend({
        \ 'clients': copy(s:priority),
        \}, get(a:000, 0, {})
        \)
  for client in settings.clients
    if !client.is_open_async_supported(request)
      continue
    endif
    return client.open_async(request, settings)
  endfor
  call s:_throw('Not supported')
endfunction

" retrieve({requests}[, {settings}])
function! s:retrieve(requests, ...) abort
  let requests = map(
        \ copy(a:requests),
        \ 'extend(s:_get_default_request(), v:val)',
        \)
  let settings = extend({
        \ 'clients': copy(s:priority),
        \}, get(a:000, 0, {})
        \)
  for client in settings.clients
    if !client.is_retrieve_supported(requests)
      continue
    endif
    return client.retrieve(requests, settings)
  endfor
  call s:_throw('Not supported')
endfunction

" retrieve({requests}[, {settings}])
function! s:retrieve_async(requests, ...) abort
  let requests = map(
        \ copy(a:requests),
        \ 'extend(s:_get_default_request(), v:val)',
        \)
  let settings = extend({
        \ 'clients': copy(s:priority),
        \}, get(a:000, 0, {})
        \)
  for client in settings.clients
    if !client.is_retrieve_async_supported(requests)
      continue
    endif
    return client.retrieve_async(requests, settings)
  endfor
  call s:_throw('Not supported')
endfunction

let &cpo = s:save_cpo
unlet! s:save_cpo
" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker:
