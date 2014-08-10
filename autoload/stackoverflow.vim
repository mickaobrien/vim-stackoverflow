function! TextEnableCodeSnip(filetype,start,end,textSnipHl) abort
    " Taken from http://vim.wikia.com/wiki/Different_syntax_highlighting_within_regions_of_a_file
    let ft=toupper(a:filetype)
    let group='textGroup'.ft
    if exists('b:current_syntax')
      let s:current_syntax=b:current_syntax
      " Remove current syntax definition, as some syntax files (e.g. cpp.vim)
      " do nothing if b:current_syntax is defined.
      unlet b:current_syntax
    endif
    execute 'syntax include @'.group.' syntax/'.a:filetype.'.vim'
    try
      execute 'syntax include @'.group.' after/syntax/'.a:filetype.'.vim'
    catch
    endtry
    if exists('s:current_syntax')
      let b:current_syntax=s:current_syntax
    else
      unlet b:current_syntax
    endif
    execute 'syntax region textSnip'.ft.'
    \ matchgroup='.a:textSnipHl.'
    \ start="'.a:start.'" end="'.a:end.'"
    \ contains=@'.group
endfunction

function! stackoverflow#StackOverflow(query)

    let query=a:query

    if exists('b:current_syntax')
        let ftype=b:current_syntax
    endif

    let winnum = bufwinnr('^__StackOverflow__')
    if (winnum >= 0)
        "execute winnum . 'wincmd w'
        execute winnum . 'wincmd c'
        "let ftype = split(bufname('%'), '__')[-1]
    endif
    "else
    let ftype = b:current_syntax
    let bufname = '__StackOverflow__' . ftype
    execute 'belowright 10split ' . bufname
    setlocal buftype=nofile
    setlocal nonumber
    "Map o to toggle fold open/close
    nnoremap <buffer> o zak<cr>
    "endif
    normal! ggdG

    silent echom 'Searching for ' . query

python << EOF
import vim, urllib, urllib2, json, StringIO, gzip, re

query = vim.eval("a:query")

QUESTION_URL = "http://api.stackexchange.com/2.2/search/excerpts?order=desc&sort=relevance&q=%s&accepted=true&site=stackoverflow"
ANSWER_URL = "http://api.stackexchange.com/2.2/questions/%s/?order=desc&sort=votes&site=stackoverflow&filter=!)Rw3MeNsaTmNs*UdDXqKh*Ci"
TIMEOUT = 20

def search(query):
    questions = get_questions(query)
    question_ids = [q['question_id'] for q in questions['items']]
    all_question_data = get_answers(question_ids)

    for a in all_question_data['items']:
        a['answers'] = sorted(a['answers'], key=lambda x: x['score'], reverse=True)
    return all_question_data

def get_questions(query):
    url = QUESTION_URL % urllib.quote(query)
    questions = get_content(url)
    return questions

def get_answers(question_ids):
    qids = ';'.join(map(str, question_ids))
    url = ANSWER_URL % qids
    answers = get_content(url)
    return answers

def html2list(html):
    clean = clean_html(html)
    split_text = clean.split('\n')
    return split_text

def format_answers(answers):
    answerer = lambda x: x['owner']['display_name']
    score = lambda x: x['score']
    bodies = [80*'='+'\n'
              + 'Answered by: ' + answerer(a) + '\n'
              + 'Score: ' + str(score(a)) + '\n\n'
              + a['body'] for a in answers]
    split_text = [html2list(b) for b in bodies]
    text_list = []
    map(text_list.extend, split_text)
    return text_list

def get_content(url):
    try:
        response = urllib2.urlopen(url, None, TIMEOUT)

        if response.info().get('Content-Encoding') == 'gzip':
            buf = StringIO.StringIO( response.read())
            gzip_f = gzip.GzipFile(fileobj=buf)
            content = gzip_f.read()
        else:
            content = response.read()

        json_response = json.loads(content)

        return json_response

    except Exception, e:
        print e

def clean_html(html):
    codes = {
        r'</?p>': '',
        r'</?b>': '',
        r'</?em>': '',
        '<br>': '',
        r'<h\d>(.*?)</h\d>': r'\1',
        r'</?strong>': '',
        r'</?code>': '',
        r'</?blockquote>': '',
        r'<pre.*?>': '<CODE>\n',
        '</pre>': '</CODE>',
        r'[\n]*</?ul>[\n]*': '',
        r'<li>(.*?)</li>': r'* \1',
        r'<a href="(.*?)".*?>(.*?)</a>': r'[\2](\1)',
        '&quot;' : '"',
        '&#39;': "'",
        '&hellip;': '...',
        '&amp;': '&',
        '&gt;': '>',
        '&lt;': '<'
    }

    for code in codes:
        html = re.sub(code, codes[code], html)

    #TODO move encoding somewhere else!
    return html.encode('latin1', errors='ignore')

vim.current.buffer[0] = "RESULTS FOR %s" % query
questions = search(query)['items']

for i, q in enumerate(questions):
    # KEYS
    #[u'body', u'is_answered', u'question_score', u'tags', u'title', u'excerpt', u'last_activity_date', u'answer_count', u'creation_date', u'item_type', u'score', u'has_accepted_answer', u'is_accepted', u'question_id']
    #vim.current.buffer.append(q)  

    title = clean_html(q['title'].encode('latin1', errors='ignore'))
    answer_count = q['answer_count']
    #excerpt = clean_html(q['excerpt'].encode('latin1').replace('\n', ' '))

    vim.current.buffer.append("Q%d. %s (%d answers)" % (i+1, title, answer_count))
    vim.current.buffer.append(html2list(q['body']))
    answers = format_answers(q['answers'])
    #print answers
    vim.current.buffer.append(answers)


EOF
    "if exists(ftype)
    call TextEnableCodeSnip(ftype, '<CODE>', '</CODE>', 'SpecialComment')
    "endif

    call SetFolds()
endfunction

function! MarkdownFolds()
" Lines that start with Q1. start a fold
  let thisline = getline(v:lnum)
  if match(thisline, '^Q\d\{1,2\}\.') >= 0
    return ">1"
  else
    return "="
  endif
endfunction

function! MarkdownFoldText()
  let foldsize = (v:foldend-v:foldstart)
  return getline(v:foldstart)
endfunction

function! SetFolds()
    setlocal foldmethod=expr
    setlocal foldexpr=MarkdownFolds()
    setlocal foldtext=MarkdownFoldText()
    setlocal foldcolumn=1
endfunction
