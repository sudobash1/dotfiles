if ! command -v git >/dev/null; then
  echo "No git command in \$PATH. Skipping git initialization."
  exit
fi

git config --global user.name "Stephen Robinson"

# Determine email to use
echo "1) sblazerobinson@gmail.com"
echo "2) stephen.robinson@eqware.net"
echo "or enter custom email"
read -p "What email do you want to use for git? " email
case "$email" in
  1) email="sblazerobinson@gmail.com" ;;
  2) email="stephen.robinson@eqware.net" ;;
esac
if echo -n "$email" | grep -Eq "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$"; then
  [ "$email" ] && git config --global user.email "$email"
else
  echo "Invalid email"
fi

# Set up editor and diff tool
if command -v vim >/dev/null; then
  git config --global core.editor vim
else
  git config --global core.editor vi
fi
command -v vimdiff >/dev/null && git config --global diff.tool vimdiff

# Prevent accidentaly pushing branches
git config --global push.default nothing

git config --global color.ui auto
