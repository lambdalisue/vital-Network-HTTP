let s:save_cpo = &cpo
set cpo&vim

function! s:_vital_loaded(V) abort
  let s:Process = a:V.import('Process')
endfunction
function! s:_vital_depends() abort
  return ['Process']
endfunction

let s:errcode = {}
let s:errcode[1] = 'Unsupported protocol. This build of curl has no support for this protocol.'
let s:errcode[2] = 'Failed to initialize.'
let s:errcode[3] = 'URL malformed. The syntax was not correct.'
let s:errcode[4] = 'A feature or option that was needed to perform the desired request was not enabled or was explicitly disabled at buildtime. To make curl able to do this, you probably need another build of libcurl!'
let s:errcode[5] = 'Couldn''t resolve proxy. The given proxy host could not be resolved.'
let s:errcode[6] = 'Couldn''t resolve host. The given remote host was not resolved.'
let s:errcode[7] = 'Failed to connect to host.'
let s:errcode[8] = 'FTP weird server reply. The server sent data curl couldn''t parse.'
let s:errcode[9] = 'FTP access denied. The server denied login or denied access to the particular resource or directory you wanted to reach. Most often you tried to change to a directory that doesn''t exist on the server.'
let s:errcode[11] = 'FTP weird PASS reply. Curl couldn''t parse the reply sent to the PASS request.'
let s:errcode[13] = 'FTP weird PASV reply, Curl couldn''t parse the reply sent to the PASV request.'
let s:errcode[14] = 'FTP weird 227 format. Curl couldn''t parse the 227-line the server sent.'
let s:errcode[15] = 'FTP can''t get host. Couldn''t resolve the host IP we got in the 227-line.'
let s:errcode[17] = 'FTP couldn''t set binary. Couldn''t change transfer method to binary.'
let s:errcode[18] = 'Partial file. Only a part of the file was transferred.'
let s:errcode[19] = 'FTP couldn''t download/access the given file, the RETR (or similar) command failed.'
let s:errcode[21] = 'FTP quote error. A quote command returned error from the server.'
let s:errcode[22] = 'HTTP page not retrieved. The requested url was not found or returned another error with the HTTP error code being 400 or above. This return code only appears if -f, --fail is used.'
let s:errcode[23] = 'Write error. Curl couldn''t write data to a local filesystem or similar.'
let s:errcode[25] = 'FTP couldn''t STOR file. The server denied the STOR operation, used for FTP uploading.'
let s:errcode[26] = 'Read error. Various reading problems.'
let s:errcode[27] = 'Out of memory. A memory allocation request failed.'
let s:errcode[28] = 'Operation timeout. The specified time-out period was reached according to the conditions.'
let s:errcode[30] = 'FTP PORT failed. The PORT command failed. Not all FTP servers support the PORT command, try doing a transfer using PASV instead!'
let s:errcode[31] = 'FTP couldn''t use REST. The REST command failed. This command is used for resumed FTP transfers.'
let s:errcode[33] = 'HTTP range error. The range "command" didn''t work.'
let s:errcode[34] = 'HTTP post error. Internal post-request generation error.'
let s:errcode[35] = 'SSL connect error. The SSL handshaking failed.'
let s:errcode[36] = 'FTP bad download resume. Couldn''t continue an earlier aborted download.'
let s:errcode[37] = 'FILE couldn''t read file. Failed to open the file. Permissions?'
let s:errcode[38] = 'LDAP cannot bind. LDAP bind operation failed.'
let s:errcode[39] = 'LDAP search failed.'
let s:errcode[41] = 'Function not found. A required LDAP function was not found.'
let s:errcode[42] = 'Aborted by callback. An application told curl to abort the operation.'
let s:errcode[43] = 'Internal error. A function was called with a bad parameter.'
let s:errcode[45] = 'Interface error. A specified outgoing interface could not be used.'
let s:errcode[47] = 'Too many redirects. When following redirects, curl hit the maximum amount.'
let s:errcode[48] = 'Unknown option specified to libcurl. This indicates that you passed a weird option to curl that was passed on to libcurl and rejected. Read up in the manual!'
let s:errcode[49] = 'Malformed telnet option.'
let s:errcode[51] = 'The peer''s SSL certificate or SSH MD5 fingerprint was not OK.'
let s:errcode[52] = 'The server didn''t reply anything, which here is considered an error.'
let s:errcode[53] = 'SSL crypto engine not found.'
let s:errcode[54] = 'Cannot set SSL crypto engine as default.'
let s:errcode[55] = 'Failed sending network data.'
let s:errcode[56] = 'Failure in receiving network data.'
let s:errcode[58] = 'Problem with the local certificate.'
let s:errcode[59] = 'Couldn''t use specified SSL cipher.'
let s:errcode[60] = 'Peer certificate cannot be authenticated with known CA certificates.'
let s:errcode[61] = 'Unrecognized transfer encoding.'
let s:errcode[62] = 'Invalid LDAP URL.'
let s:errcode[63] = 'Maximum file size exceeded.'
let s:errcode[64] = 'Requested FTP SSL level failed.'
let s:errcode[65] = 'Sending the data requires a rewind that failed.'
let s:errcode[66] = 'Failed to initialise SSL Engine.'
let s:errcode[67] = 'The user name, password, or similar was not accepted and curl failed to log in.'
let s:errcode[68] = 'File not found on TFTP server.'
let s:errcode[69] = 'Permission problem on TFTP server.'
let s:errcode[70] = 'Out of disk space on TFTP server.'
let s:errcode[71] = 'Illegal TFTP operation.'
let s:errcode[72] = 'Unknown TFTP transfer ID.'
let s:errcode[73] = 'File already exists (TFTP).'
let s:errcode[74] = 'No such user (TFTP).'
let s:errcode[75] = 'Character conversion failed.'
let s:errcode[76] = 'Character conversion functions required.'
let s:errcode[77] = 'Problem with reading the SSL CA cert (path? access rights?).'
let s:errcode[78] = 'The resource referenced in the URL does not exist.'
let s:errcode[79] = 'An unspecified error occurred during the SSH session.'
let s:errcode[80] = 'Failed to shut down the SSL connection.'
let s:errcode[82] = 'Could not load CRL file, missing or wrong format (added in 7.19.0).'
let s:errcode[83] = 'Issuer check failed (added in 7.19.0).'
let s:errcode[84] = 'The FTP PRET command failed'
let s:errcode[85] = 'RTSP: mismatch of CSeq numbers'
let s:errcode[86] = 'RTSP: mismatch of Session Identifiers'
let s:errcode[87] = 'unable to parse FTP file list'
let s:errcode[88] = 'FTP chunk callback reported error'
let s:errcode[89] = 'No connection available, the session will be queued'
let s:errcode[90] = 'SSL public key does not matched pinned public key'

function! s:_available(settings) abort
  return executable(s:_command(a:settings))
endfunction
function! s:_command(settings) abort
  return get(get(a:settings, 'command', {}), 'curl', 'curl')
endfunction
function! s:_quote() abort
  return &shellxquote == '"' ?  "'" : '"'
endfunction
function! s:_tempname() abort
  return tr(tempname(), '\', '/')
endfunction

function! s:open(settings) abort
  let quote = s:_quote()
  let command = self._command(a:settings)
  let a:settings._file.header = s:_tempname()
  let command .= ' --dump-header ' . quote . a:settings._file.header . quote
  let has_output_file = has_key(a:settings, 'outputFile')
  if has_output_file
    let output_file = a:settings.outputFile
  else
    let output_file = s:_tempname()
    let a:settings._file.content = output_file
  endif
  let command .= ' --output ' . quote . output_file . quote
  if has_key(a:settings, 'gzipDecompress') && a:settings.gzipDecompress
    let command .= ' --compressed '
  endif
  let command .= ' -L -s -k -X ' . a:settings.method
  let command .= ' --max-redirs ' . a:settings.maxRedirect
  let command .= s:_make_header_args(a:settings.headers, '-H ', quote)
  let timeout = get(a:settings, 'timeout', '')
  let command .= ' --retry ' . a:settings.retry
  if timeout =~# '^\d\+$'
    let command .= ' --max-time ' . timeout
  endif
  if has_key(a:settings, 'username')
    let auth = a:settings.username . ':' . get(a:settings, 'password', '')
    if has_key(a:settings, 'authMethod')
      if index(['basic', 'digest', 'ntlm', 'negotiate'], a:settings.authMethod) == -1
        throw 'vital: Web.HTTP: Invalid authorization method: ' . a:settings.authMethod
      endif
      let method = a:settings.authMethod
    else
      let method = 'anyauth'
    endif
    let command .= ' --' . method . ' --user ' . quote . auth . quote
  endif
  if has_key(a:settings, 'data')
    let a:settings._file.post = s:_make_postfile(a:settings.data)
    let command .= ' --data-binary @' . quote . a:settings._file.post . quote
  endif
  let command .= ' ' . quote . a:settings.url . quote

  call s:Process.system(command)
  let retcode = s:Process.get_last_status()

  let headerstr = s:_readfile(a:settings._file.header)
  let header_chunks = split(headerstr, "\r\n\r\n")
  let headers = map(header_chunks, 'split(v:val, "\r\n")')
  if retcode != 0 && empty(headers)
    if has_key(s:clients.curl.errcode, retcode)
      throw 'vital: Web.HTTP: ' . s:clients.curl.errcode[retcode]
    else
      throw 'vital: Web.HTTP: Unknown error code has occured in curl: code=' . retcode
    endif
  endif
  if !empty(headers)
    let responses = map(headers, '[v:val, ""]')
  else
    let responses = [[[], '']]
  endif
  if has_output_file
    let content = ''
  else
    let content = s:_readfile(output_file)
  endif
  let responses[-1][1] = content
  return responses
endfunction

function! s:is_open_supported(request) abort
  return 1
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
