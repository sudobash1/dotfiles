#PROMPT='%(!.%{$fg_bold[red]%}.%{$fg_bold[green]%}%n@)%m%{$reset_color%}:%{$fg_bold[blue]%}%(!.%1~.%~)%{$fg_bold[yellow]%}$(git_prompt_info)%(?:%{$reset_color%}%%:%{$fg_bold[red]%}%%%{$reset_color%}) '
#PROMPT='%(!.%{$fg_bold[red]%}.%{$fg_bold[green]%}%n@)%m%{$reset_color%}:%{$fg_bold[blue]%}%~%{$fg_bold[yellow]%}$(git_prompt_info)%(?:%{$reset_color%}%%:%{$fg_bold[red]%}%%%{$reset_color%}) '
setopt prompt_subst
PROMPT='%(!.%{$fg_bold[red]%}.%{$fg_bold[green]%}%n@)%m%{$reset_color%} %{$fg_bold[blue]%}${${PWD/#%$HOME%/~\/}/#$HOME/~}%{$fg_bold[yellow]%}$(git_prompt_info)%(?:%{$reset_color%}%%:%{$fg_bold[red]%}%%%{$reset_color%}) '

ZSH_THEME_GIT_PROMPT_PREFIX=" ("
ZSH_THEME_GIT_PROMPT_SUFFIX=")"
