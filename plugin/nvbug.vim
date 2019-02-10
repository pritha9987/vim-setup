"#################################
"
"      VIM Nvbug plugin 2.1
"
"      Author: Pine Yan
"      Wiki: https://wiki.nvidia.com/engwiki/index.php/NVBug_Plugin_for_Vim
"      Source: /home/vim-nv/plugins/nvbug
"
"#################################

if v:version >= 800

nmap <silent>,vb  :echo "ERROR: vim 8.0 not supported yet"<cr>
nmap <silent>,vf  :echo "ERROR: vim 8.0 not supported yet"<cr>
nmap <silent>,cb  :echo "ERROR: vim 8.0 not supported yet"<cr>
nmap <silent>,sb  :echo "ERROR: vim 8.0 not supported yet"<cr>
nmap <silent>,so  :echo "ERROR: vim 8.0 not supported yet"<cr>
nmap <silent>,nb  :echo "ERROR: vim 8.0 not supported yet"<cr>
nmap <silent>,mb  :echo "ERROR: vim 8.0 not supported yet"<cr>
nmap <silent>,rf  :echo "ERROR: vim 8.0 not supported yet"<cr>
nmap <silent>,mfb :echo "ERROR: vim 8.0 not supported yet"<cr>
nmap <silent>,bh  :echo "ERROR: vim 8.0 not supported yet"<cr>


else "version > 8.0

if v:version < 701

nmap <silent>,vb :echo "ERROR: please use VIM 7.1 or later"<cr>
nmap <silent>,vf :echo "ERROR: please use VIM 7.1 or later"<cr>
nmap <silent>,cb :echo "ERROR: please use VIM 7.1 or later"<cr>
nmap <silent>,sb :echo "ERROR: please use VIM 7.1 or later"<cr>
nmap <silent>,so :echo "ERROR: please use VIM 7.1 or later"<cr>
nmap <silent>,nb :echo "ERROR: please use VIM 7.1 or later"<cr>
nmap <silent>,mb :echo "ERROR: please use VIM 7.1 or later"<cr>
nmap <silent>,rf :echo "ERROR: please use VIM 7.1 or later"<cr>
nmap <silent>,mfb :echo "ERROR: please use VIM 7.1 or later"<cr>
nmap <silent>,bh :echo "ERROR: please use VIM 7.1 or later"<cr>

else "version < 7.01

let g:nvbug_plugin_ver = 2.1

autocmd BufRead,BufNewFile *.nvbug
\ setf nvbug 

nmap <silent>,vb :call g:askForBugID('', 'viewbug')<cr>
nmap <silent>,vf :call g:askForBugID('fullview', 'viewbug')<cr>
nmap <silent>,cb :call g:askForBugID('', 'commentbug')<cr>
nmap <silent>,sb :call g:NVBug_saveBug('Norm')<cr>
nmap <silent>,so :call g:NVBug_saveBug('saveOnly')<cr>
nmap <silent>,nb :call g:NVBug_newBug()<cr>
nmap <silent>,mb :call g:NVbuglist('~/.vim/nvbug/mybugs.list')<cr> 
nmap <silent>,rf :call g:refreshBugs()<cr> 
nmap <silent>,mfb :call g:NVbuglist('~/.vim/nvbug/myfiledbugs.list')<cr> 
nmap <silent>,bh  :call g:NVbuglist('~/.vim/nvbug/bug_history')<cr> 

let g:NVBug_comment_template = "/home/vim-nv/plugins/nvbug/scripts/nvbug_comment_template"
let g:NVBug_newbug_template = "~/.vim/nvbug/nvbug_newbug_template"

let s:NVBug_newbug_default = "comperf"

function! g:NVbuglist(listfile)
    tabnew
    exec 'view '.a:listfile
    nnoremap <buffer> <silent><cr> :call g:getBugFromLine('fullview','viewbug')<cr>
    nnoremap <buffer> <silent>C :call g:getBugFromLine('','commentbug')<cr>
endfunction

function! g:getBugFromLine(option, action)
    "let bugid = split(getline('.'),"    *")[0]
    let bugid = split(getline('.')," ")[0]
    if bugid =~ '^[0-9]\{5,\}$'
	exec 'match Todo /^'.bugid.'.*/'
	if a:action == 'viewbug'
		tabnew
		call s:NVBug_viewBug(a:option, bugid)
	elseif a:action == 'commentbug'
		new
		call s:NVBug_commentBug(bugid)	
	endif
    else
    	echo "Can't find BugID in current line"	
    endif
endfunction

function! g:askForBugID(option, action)
	let guessid = ''
	let curword = expand("<cword>")
	if curword =~ '^[0-9]\{5,\}$'
		let guessid = curword
	else
		let guess_line = search('Bug ID: *[0-9]\+','bn')
		if guess_line != 0
			let [bugstr, guessid] = split(getline(guess_line),"   *")
		endif
	endif
        let latest_ver = str2float(substitute(system("cat /home/vim-nv/plugins/nvbug/scripts/.latest_version"), "\n", "", ""))
	if latest_ver > g:nvbug_plugin_ver
		let bugid = input("Enter BugID (FYI: plugin ".printf("%1.2f", latest_ver)." now available!):",guessid)
	else
		let bugid = input("Enter BugID (press <enter> now if you want abort):",guessid)
	endif
	if bugid != 'q' && bugid != '' 
		if a:action == 'viewbug'
			tabnew
			call s:NVBug_viewBug(a:option, bugid)
		elseif a:action == 'commentbug'
			new
			call s:NVBug_commentBug(bugid)	
		endif
	else
		echo "Abort!"
	endif
endfunction	

function! s:NVBug_viewBug(option, bugID)
    exec "silent e "."bug".a:bugID
	setf nvbug
    setlocal buftype=nofile
    let readcmd = '0read !/home/vim-nv/plugins/nvbug/scripts/viewbug '
    if a:option =~ 'fullview'
        let readcmd = readcmd . '-f '
    endif
    if a:option =~ 'nohistory'
        let readcmd = readcmd . '-nohistory '
    endif
    let readcmd = readcmd . a:bugID
	execute readcmd
	1
endfunction

function! s:NVBug_commentBug(bugID)
	setf nvbug
	let fillCommentCmd = "0read !/home/vim-nv/plugins/nvbug/scripts/fillCommentTemplate ".a:bugID." < ".g:NVBug_comment_template
	execute fillCommentCmd
	call search('AuthorFullName','w')
	call append(".",system("/home/vim-nv/plugins/nvbug/scripts/getName"))
	let curpos=searchpos('$CURSOR','w')
	%s/$CURSOR//
	call cursor(curpos)
	startinsert
endfunction

function! g:NVBug_saveBug(saveMode)
    	let filename = tempname()
	exec "saveas ".filename
	if a:saveMode == "saveOnly"
	    execute "silent read !/home/vim-nv/plugins/nvbug/scripts/errormail /home/vim-nv/plugins/nvbug/scripts/updateBug -saveOnly ".filename." &"	
	else
	    execute "silent read !/home/vim-nv/plugins/nvbug/scripts/errormail /home/vim-nv/plugins/nvbug/scripts/updateBug ".filename." &"	
	endif
	echo "Bug Update has been submitted."
endfunction

function! g:NVBug_newBug()
	let templates = substitute(glob(g:NVBug_newbug_template."_*"), "[^\n]*nvbug_newbug_template_", "  ", "g")
	echo "Available templates:"
	echo templates
	let template = input("Choose the template to use (empty to abort): ",s:NVBug_newbug_default)
    if template != ''
        let s:NVBug_newbug_default = template
        call g:NVBug_newBug_with_template(g:NVBug_newbug_template.'_'.template)
    else
        echo "Abort!"
    endif
endfunction

function! g:NVBug_newBug_with_template(template_file)
        tabnew
        exec "silent e ".tempname()."/new_bug"
        setf nvbug
        let readcmd = '0read '.a:template_file
        execute readcmd
        let b:current_syntax = "nvbug"
	call search('RequesterFullName','w')
	call append(".",system("/home/vim-nv/plugins/nvbug/scripts/getName"))
        let curpos=searchpos('$CURSOR','w')
        %s/$CURSOR//
        call cursor(curpos)
        startinsert
endfunction

function! g:refreshBugs()
    let current_pos = getpos('.')
    call cursor(1, 1)
    let bugids = []
    let buglines = []
    echo "Processing bugs in current buffer, please wait for a couple seconds..."
    while nextnonblank('.') != 0
    	call cursor(nextnonblank('.'), 1)
        let bugid = split(getline('.'),"    *")[0]
        if bugid =~ '^[0-9]\{5,\}$'
	    let bugids = bugids + [bugid]
	    let buglines = buglines + [line('.')]
        endif
    	:delete
    endwhile
    execute '0read !../nvbug/fetchBugs.pl -id '.join(bugids, ',')
endfunction

endif "version < 7.01
endif "version > 8.0
