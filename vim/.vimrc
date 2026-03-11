" --- 일반 설정 --- "
set number              " 줄 번호 표시
set relativenumber      " 상대 줄 번호 표시
set cursorline          " 현재 줄 강조
set mouse=a             " 마우스 사용 허용
set clipboard=unnamed   " 시스템 클립보드와 연동

" --- 편집 설정 --- "
set ts=4                " tabstop: 탭 너비 4
set sw=4                " shiftwidth: 들여쓰기 너비 4
set expandtab           " 탭을 공백으로 변환
set autoindent          " 자동 들여쓰기
set cindent             " C 언어 스타일 들여쓰기

" --- 검색 설정 --- "
set hlsearch            " 검색 결과 강조
set ignorecase          " 검색 시 대소문자 무시
set smartcase           " 대문자 입력 시 대소문자 구분
set incsearch           " 점진적 검색

" --- 기타 --- "
syntax on               " 구문 강조 사용
filetype indent on      " 파일 종류에 따른 들여쓰기 적용
set laststatus=2        " 상태 표시줄 항상 표시
set encoding=utf-8      " 인코딩 설정

" --- 편의성 설정 ---- "
nnoremap X :bd<CR>    " X로 현재 버퍼 닫기
nnoremap H gT         " H로 이전 탭 이동
nnoremap L gt         " L로 다음 탭 이동

set whichwrap-=h    "h, l 누르면 다음 줄로 이동"
set whichwrap-=l

inoremap jk <Esc>   "jk, kj 누르면 모드 변환"
inoremap kj <Esc>

" ========================== "
" --- 1. 기본 편집 및 들여쓰기 설정 ---
set number              " 줄 번호 표시
set autoindent          " 자동 들여쓰기
set smartindent         " 문법에 맞게 스마트한 들여쓰기
set tabstop=4           " Tab 크기를 4칸으로
set shiftwidth=4        " 자동 들여쓰기 시 4칸 이동
set expandtab           " Tab을 공백으로 변환
set cursorline          " 현재 커서 줄 강조
set hlsearch            " 검색 결과 하이라이트

" --- 2. 줄 끝/처음에서 좌우(h, l) 이동 시 줄 바꿈 허용 ---
set whichwrap+=<,>,h,l,[,]

" --- 3. 단축키 매핑 (Insert 모드 탈출) ---
inoremap jk <Esc>
inoremap kj <Esc>

" --- 4. 괄호 자동 완성 및 엔터 처리 ---
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap " ""<left>
inoremap ' ''<left>

" 괄호 열고 엔터 시 줄 바꿈 및 들여쓰기
inoremap {<CR> {<CR>}<Esc>O
inoremap [<CR> [<CR>]<Esc>O
inoremap (<CR> (<CR>)<Esc>O

" --- 5. 이미 닫는 괄호가 있으면 입력 대신 '커서 이동' ---
" 입력하려는 문자가 바로 다음 문자와 같으면 한 칸 옆으로 이동합니다.
inoremap <expr> ) strpart(getline('.'), col('.')-1, 1) == ")" ? "\<Right>" : ")"
inoremap <expr> ] strpart(getline('.'), col('.')-1, 1) == "]" ? "\<Right>" : "]"
inoremap <expr> } strpart(getline('.'), col('.')-1, 1) == "}" ? "\<Right>" : "}"
inoremap <expr> " strpart(getline('.'), col('.')-1, 1) == "\"" ? "\<Right>" : "\""
inoremap <expr> ' strpart(getline('.'), col('.')-1, 1) == "'" ? "\<Right>" : "'"
