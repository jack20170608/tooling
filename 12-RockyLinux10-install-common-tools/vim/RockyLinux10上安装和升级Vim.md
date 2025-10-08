在 Rocky Linux 10 上安装和升级 Vim 非常简单，您可以使用以下方法：

## 安装 Vim

```bash
# 使用 dnf 安装 Vim
sudo dnf install vim -y

# 如果需要安装增强版 Vim（包含更多特性）
sudo dnf install vim-enhanced -y
```

## 升级 Vim

```bash
# 更新系统软件包索引
sudo dnf check-update

# 升级 Vim 到最新版本
sudo dnf update vim -y

# 或者或者升级也可以升级所有已安装的软件包（包括 Vim）
sudo dnf update -y
```

## 验证安装

```bash
# 检查 Vim 版本
vim --version

# 查看 Vim 的安装信息
rpm -qi vim-enhanced
```

## 配置 Vim

如果您想个性化配置 Vim，可以创建或编辑 `~/.vimrc` 文件：

```bash
# 创建或编辑 Vim 配置文件
vim ~/.vimrc

# 示例配置（可以添加到 .vimrc 文件中）
set number          " 显示行号
set tabstop=4       " Tab 键宽度
set shiftwidth=4    " 自动缩进宽度
set expandtab       " 使用空格代替 Tab
set autoindent      " 自动缩进
set hlsearch        " 搜索高亮
set incsearch       " 增量搜索
set encoding=utf-8  " 使用 UTF-8 编码
```

## 安装额外的 Vim 插件

```bash
# 安装 Vim 插件管理器（例如 vim-plug）
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

安装完成后，您就可以开始使用 Vim 了。如果您需要更高级的 Vim 功能，可以考虑安装一些流行的 Vim 插件。
