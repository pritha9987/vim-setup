"#################################
"
"      VIM Nvbug plugin 1.2
"
"      Author: Pine Yan
"      Wiki: https://wiki.nvidia.com/engwiki/index.php/NVBug_Plugin_for_Vim
"      Source: /home/vim-nv/plugins/nvbug
"
"#################################

if exists("b:do_nvbug_init") 
	finish
endif
let b:do_nvbug_init = 1

setlocal noswapfile
setlocal noexpandtab
setlocal omnifunc=g:nvbug_complete_func
let s:nvbug_name_dict = []
let g:nvbug_name_dictfile = '/home/vim-nv/plugins/nvbug/scripts/nvbug-namelist'
let s:nvbug_fields = ['BugAction', 'Disposition', 'DuplicateBugs', 'PerforceCheckinNumber', 'CCFullName',
\    'Severity']
let s:nvbug_name_filter = 'ARBFullName\|CCFullName'
let s:bugAction_match = ['HW - Open - To fix', 'HW - Open - To close', 'HW - Closed', 'HW - Open - To verify']
let s:disposition_match = ['Bug - Fixed', 'Duplicate', 'Not a bug', 'Open issue', 'Not an NV bug', 'Bug - Will not fix']
let s:severity_match = ['1-System Crash', '2-Application Crash', '3-Functionality', '4-Corruption', 
\                        '5-Performance', '6-Enhancement', '7-Task Tracking']
let s:priority_match = ['0-Showstopper', '1-Urgent', '2-Fix Before Next Build', '3-Fix Before Milestone', '4-Fix Before Ship', '5-Normal', '6-Would be Nice', '7-Fix In Next Release']

function! g:nvbug_complete_func(findstart,base)
	if a:findstart
	" determine start of the word
		let line = line('.') - 1
		let fieldname = ''
		if line > 0
			let fieldname = getline(line)
		endif
		if fieldname =~ s:nvbug_name_filter
			let search = col('.') - 1
			let start = search
			let namestr = getline('.')
			while search >= 0 && namestr[search] != ','
				if namestr[search] =~ '[a-zA-z]'
					let start = search
				endif
				let search -= 1
			endwhile	
			return start
		else
			return 0
		endif
	else
	" find matching 
		if a:base =~ "^\[\["
			let matches = []
			for field in s:nvbug_fields
				let field = '[['.field.']]'
				if field =~ "^".a:base
					call add(matches, field)
			       	endif	
		       	endfor
			return matches
		else  
			if line('.') == 1
				return []
			endif
			let fieldname = getline(line('.') - 1)
			if fieldname =~ s:nvbug_name_filter
				if empty(s:nvbug_name_dict)
       					let s:nvbug_name_dict = readfile(g:nvbug_name_dictfile)
				endif
				return filter(copy(s:nvbug_name_dict), 'v:val =~ "^'.a:base.'"')
			endif
			if fieldname =~ "BugAction"
				return s:bugAction_match
			endif
			if fieldname =~ "Disposition"
				return s:disposition_match
			endif
			if fieldname =~ "Severity"
				return s:severity_match
			endif
			if fieldname =~ "Priority"
				return s:priority_match
			endif
			return []
		endif
	endif
endfun
