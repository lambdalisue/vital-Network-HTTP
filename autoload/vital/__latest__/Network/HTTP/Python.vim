let s:save_cpo = &cpo
set cpo&vim

function! s:_vital_loaded(V) abort
  let s:P = a:V.import('System.Filepath')
  let s:Y = a:V.import('Vim.Python')
endfunction
function! s:_vital_depends() abort
  return ['System.Filepath', 'Vim.Python']
endfunction

function! s:is_open_supported(request) abort
  return 0
endfunction
function! s:open(request, settings) abort
  let settings = extend({
        \ 'python': 0,
        \}, a:settings)
  let fname = 'open'
  let kwargs = {
        \ 'request': copy(request),
        \}
  let namespace = {}
  execute s:Y.exec_file(
        \ s:P.join(s:root, 'Python.py'),
        \ settings.python == 1 ? 0 : settings.python
        \)
  if has_key(namespace, 'exception')
    call s:_throw(namespace.exception)
  endif
  return namespace.response
endfunction

function! s:is_open_async_supported(request) abort
  return 0
endfunction
function! s:open_async(request, settings) abort
  call s:_throw('Not implemented yet')
endfunction

function! s:is_retrieve_supported(requests) abort
  return 0
endfunction
function! s:retrieve(requests, settings) abort
  let settings = extend({
        \ 'python': 0,
        \}, a:settings)
  let fname = 'retrieve'
  let kwargs = {
        \ 'requests': copy(requests),
        \}
  let namespace = {}
  execute s:Y.exec_file(
        \ s:P.join(s:root, 'Python.py'),
        \ settings.python == 1 ? 0 : settings.python
        \)
  if has_key(namespace, 'exception')
    call s:_throw(namespace.exception)
  endif
  return namespace.responses
endfunction

function! s:is_retrieve_async_supported(requests) abort
  return 0
endfunction
function! s:retrieve_async(requests, settings) abort
  call s:_throw('Not implemented yet')
endfunction

let &cpo = s:save_cpo
unlet! s:save_cpo
" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker:
