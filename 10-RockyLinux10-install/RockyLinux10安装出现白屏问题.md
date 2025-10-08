# 解决 Rocky Linux 10.0 虚拟机安装白屏问题

## 快速解决方案

### 方法1：修改启动参数（最常用）

1. 在安装菜单选择 "Install Rocky Linux 10"
2. 按 `e` 键编辑启动命令
3. 在 `linuxefi` 或 `linux` 行末尾添加：
   ```
   nomodeset
   ```
4. 按 `Ctrl+X` 或 `F10` 继续启动

**如果仍然白屏**，尝试：
- 移除 `rhgb quiet` 参数
- 或添加 `text` 进入纯文本安装

### 方法2：直接选择文本安装模式
在启动菜单选择 "Install Rocky Linux 10 in text mode"

## 不同虚拟化平台的特定解决方案

### VMware
- 虚拟机设置 → 硬件 → 显示器
  - 勾选 "加速3D图形"
  - 或取消勾选以使用软件渲染
- 或编辑启动参数添加：
  ```
  nouveau.modeset=0
  ```

### VirtualBox
- 设置 → 显示 → 屏幕
  - 将显存调高至128MB
  - 图形控制器选择 VMSVGA 或 VBoxVGA
- 启动时添加参数：
  ```
  nomodeset
  ```

### KVM/QEMU
- 使用 virt-manager 编辑虚拟机
  - 视频选择 "Virtio" 或 "QXL"
  - 增加显存到64MB以上
- 启动时添加参数：
  ```
  nomodeset
  ```

### Hyper-V
- 虚拟机设置 → 硬件 → 视频
  - 选择 "Microsoft Basic Display Adapter"
- 启动时添加参数：
  ```
  nomodeset
  ```

## 安装后的永久修复

### 方法1：使用 grubby 命令
```bash
# 添加 nomodeset 参数到所有内核
sudo grubby --update-kernel=ALL --args="nomodeset"

# 重启系统
sudo reboot
```

### 方法2：安装正确的显卡驱动
对于NVIDIA显卡：
```bash
# 启用ELRepo源
sudo dnf install -y https://www.elrepo.org/elrepo-release-10.el10.elrepo.noarch.rpm

# 安装NVIDIA驱动
sudo dnf install -y kmod-nvidia
```

## 其他可能的解决方案

- **检查ISO文件**：确保下载完整并验证SHA256
- **调整BIOS/UEFI设置**：关闭Secure Boot或切换图形设置
- **更新虚拟化软件**：确保使用最新版本的VMware/VirtualBox等

如果问题仍然存在，能否告诉我你使用的虚拟化平台和虚拟机配置？这样我可以提供更精确的解决方案。
