# 🍎 macOS Terminal Setup: Navix & K8s Edition

### 1️⃣ 필수 도구 설치 (Homebrew & CLI)
# Homebrew 설치
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# iTerm2, 폰트, lsd(아이콘 리스트) 설치
brew install --cask iterm2
brew tap homebrew/cask-fonts && brew install --cask font-go-mono-nerd-font
brew install lsd

# Kubernetes 핵심 도구 설치
brew install kubectl kubectx derailed/k9s/k9s

### 2️⃣ Starship 프롬프트 세팅
# Starship 설치 및 zsh 등록
brew install starship
echo 'eval "$(starship init zsh)"' >> ~/.zshrc

# starship.toml 설정 (K8s 컨텍스트 표시)
mkdir -p ~/.config
cat << 'EOF' > ~/.config/starship.toml
format = """
$directory\
$git_branch\
$git_status\
$kubernetes\
$character
"""

[kubernetes]
symbol = "⎈ "
format = 'on [($symbol$context( \($namespace\)))]($style) '
disabled = false
style = "dimmed cyan"

[directory]
style = "blue"
truncate_to_repo = true
EOF

### 3️⃣ Alias & 편의 설정 (zshrc 하단 추가)
cat << 'EOF' >> ~/.zshrc

# Navix & K8s Aliases
alias nv='ssh user@navix.navercorp.com'
alias k='kubectl'
alias kx='kubectx'
alias kn='kubens'
alias ls='lsd'
alias ll='lsd -l'

# kubectl 자동완성
source <(kubectl completion zsh)
EOF

### 4️⃣ iTerm2 비주얼 설정 (GUI에서 직접 클릭)
# 1. Cmd + , (설정) -> Profiles -> Text -> Font: 'GoMono Nerd Font' 선택
# 2. Profiles -> Window -> Transparency: 25 정도로 조절
# 3. Profiles -> Window -> Blur: 체크 (배경 흐릿하게)
# 4. Keys -> Hotkey -> 'Create a Dedicated Hotkey Window' (Quake 모드 설정)

### 5️⃣ 바탕화면 아이콘 가리기 (선택)
defaults write com.apple.finder CreateDesktop false && killall Finder
