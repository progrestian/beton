# load install vars

source vars.sh

# copy wifi driver

if [ "asing" = "$BETON_TARGET" ]; then
  if [ 0 -eq "$(find /lib/firmware -maxdepth 1 ! -name firmware | grep -o "iwlwifi-QuZ-a0-hr-b0" | wc -l)" ]; then
    wifidriverfilename=$(find . | grep -oE "iwlwifi-QuZ-a0-hr-b0-[0-9]+.ucode")
    sudo cp "$wifidriverfilename" /lib/firmware
    sudo reboot
  fi
fi

# keychron k2 fix

echo "options hid_apple fnmode=2 swap_opt_cmd=1" | sudo tee /etc/modprobe.d/hid_apple.conf > /dev/null
sudo dracut --force

# install dnf packages

sudo dnf install -y --setopt=install_weak_deps=False $(cat dnf.txt)

# install flatpak packages

sudo flatpak remote-add flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y $(cat flatpak.txt)

# change shell to zsh

usermod -s /bin/zsh

# copy fonts

cp -a fonts ~/.local/share

# install bitwarden npm

sudo npm install -g @bitwarden/cli

# manage keys

export BW_SESSION=$(bw login --raw)
export GNUPGHOME=~/.local/share/gnupg
mkdir ~/.ssh
mkdir -p $GNUPGHOME
chown -R progrestian ~/.ssh
chown -R progrestian $GNUPGHOME
chmod 700 ~/.ssh
chmod 700 $GNUPGHOME
bw get item "ssh-$BETON_TARGET-priv" | jq -r '.notes' > ~/.ssh/id_rsa
bw get item "ssh-$BETON_TARGET-pub" | jq -r '.notes' > ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa.pub
bw get item gpg-priv | jq -r '.notes' > ~/gpg-priv
bw get item gpg-pub | jq -r '.notes' > ~/gpg-pub
gpg --batch --pinentry-mode loopback --passphrase $(bw get password gpg-key --raw) --import ~/gpg-priv
gpg --batch --pinentry-mode loopback --passphrase $(bw get password gpg-key --raw) --import ~/gpg-pub
chown -R progrestian ~/.ssh
chown -R progrestian $GNUPGHOME
rm ~/gpg-priv
rm ~/gpg-pub
bw logout

# install chezmoi

cd ~
sh -c "$(curl -fsLS git.io/chezmoi)"
chezmoi init https://github.com/progrestian/titik.git
chezmoi apply
cd ~/.local/share/chezmoi
git remote set-url origin git@github.com:progrestian/titik.git

# remove bash files

rm ~/.bash_history
rm ~/.bash_logout
rm ~/.bash_profile
rm ~/.bashrc

# done

echo "====================================================="
echo "INSTALLATION DONE!"
echo "====================================================="

