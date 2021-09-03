# select target

target=$(printf "menara\nasing" | fzf --prompt="target: ")
if [ -z "$target" ]; then
  echo "error: no target selected"
  exit
fi

# select media

media=$(find /run/media/progrestian -maxdepth 1 ! -name progrestian | fzf --prompt="media: ")
if [ -z "$media" ]; then
  echo "error: no media selected"
  exit
fi

# delete old installer in media

rm -rf "$media"/beton

# create folder in media

mkdir "$media"/beton

# copy installer script

cp run.sh "$media"/beton

# copy fonts

cp -a ~/.local/share/fonts "$media"/beton

# set install vars

echo "export BETON_TARGET=$target" >> "$media"/beton/vars.sh

# copy dnf packages list

dnf repoquery --qf '%{name}' --userinstalled | tr '\n' ' ' > package-list/dnf/installed.txt
cp package-list/dnf/installed.txt "$media"/beton/dnf.txt

# copy flatpak packages list

flatpak list --app --columns=application | tail -c +1 | tr '\n' ' ' > package-list/flatpak/installed.txt
cp package-list/flatpak/installed.txt "$media"/beton/flatpak.txt

# download latest wifi driver

if [ "asing" = "$target" ]; then
  wifidriverfilename=$(curl -s https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/ | grep -oE "iwlwifi-QuZ-a0-hr-b0-[0-9]+" | tail -1)
  wget -q -O "$media"/beton/"$wifidriverfilename".ucode https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/"$wifidriverfilename".ucode
fi

