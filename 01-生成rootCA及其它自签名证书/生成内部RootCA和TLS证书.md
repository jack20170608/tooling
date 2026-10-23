# 使用 OpenSSL 生成内部 Root CA 和 TLS 证书

本文以 Rocky Linux 10 和 OpenSSL 为例，介绍如何创建一个仅供内部使用的根 CA，并用它签发服务器证书。也会说明独立自签名证书的用法及限制。

## 一、先区分两种证书

- **内部 CA 签发的证书**：Root CA 自签名，服务器证书由 Root CA 签发。客户端只需信任 Root CA，即可验证由它签发的证书。内部服务通常推荐这种方式。
- **独立自签名证书**：服务器自己签发自己的证书。客户端默认不信任它，必须逐台将该服务器证书加入信任库；证书更新后也要同步更新客户端。

“自签名”并不意味着应该让每台服务器都自己签证书。对多个内部服务，建立一个受控的 Root CA，再由它签发各服务证书，管理和信任配置会更简单。

## 二、准备环境和目录

确认系统已安装 OpenSSL：

```bash
openssl version
```

如未安装：

```bash
sudo dnf install -y openssl
```

创建 CA 工作目录。以下示例将 Root CA 的私钥、证书和 CSR 放在 `~/internal-pki`：

```bash
umask 077
mkdir -p /appvol/ilovemyhome/internal-pki/{private,certs,csr}
chmod 700 /appvol/ilovemyhome/internal-pki/private
cd /appvol/ilovemyhome/internal-pki/
```

生产环境中应将 Root CA 私钥保存在受控、离线或严格限制访问的设备上，不要放在 Web 服务器上。这里使用当前用户目录只是为了演示。

## 三、生成 Root CA

### 1. 生成加密的 Root CA 私钥

```bash
openssl genpkey \
  -algorithm RSA \
  -aes-256-cbc \
  -pkeyopt rsa_keygen_bits:4096 \
  -out private/rootCA.key.pem

chmod 600 private/rootCA.key.pem
```

命令会提示输入私钥口令。请使用强口令，并通过安全方式保存；丢失口令后无法再用该私钥签发证书。`rootCA.key.pem` 是最重要的敏感文件，绝不能发送给客户端或复制到服务端。

### 2. 创建自签名 Root CA 证书

```bash
openssl req -x509 -new \
  -key private/rootCA.key.pem \
  -sha256 \
  -days 3650 \
  -out certs/rootCA.cert.pem \
  -subj "/C=CN/O=Home Lab/OU=Internal PKI/CN=Home Lab Root CA" \
  -addext "basicConstraints=critical,CA:TRUE,pathlen:0" \
  -addext "keyUsage=critical,keyCertSign,cRLSign" \
  -addext "subjectKeyIdentifier=hash"

chmod 644 certs/rootCA.cert.pem
```

Root CA 证书本身是自签名的。`pathlen:0` 表示它不用于签发下级 CA，只签发终端证书。证书有效期示例设为 10 年；有效期应结合内部管理和更新策略确定。

查看证书内容和有效期：

```bash
openssl x509 -in certs/rootCA.cert.pem -noout -subject -issuer -dates
openssl x509 -in certs/rootCA.cert.pem -noout -text
```

## 四、生成并签发服务器证书

下面以 `www.ilovemyhome.top` 为例。请替换成服务实际使用的 DNS 名称或 IP 地址。

### 1. 生成服务器私钥和 CSR

```bash
openssl genpkey \
  -algorithm RSA \
  -pkeyopt rsa_keygen_bits:3072 \
  -out private/www.ilovemyhome.top.key.pem

chmod 600 private/www.ilovemyhome.top.key.pem

openssl req -new \
  -key private/www.ilovemyhome.top.key.pem \
  -out csr/www.ilovemyhome.top.csr.pem \
  -subj "/C=CN/O=Home Lab/OU=Services/CN=www.ilovemyhome.top"
```

服务端私钥通常需要由服务进程读取，因此示例没有加密该私钥。应限制文件权限，并仅允许运行服务的账户读取。不要把该私钥和证书请求文件当作 Root CA 私钥保存或分发。

### 2. 配置证书扩展，特别是 SAN

现代 TLS 客户端会检查 **Subject Alternative Name (SAN)**，不能只依赖证书的 CN。创建扩展文件：

```bash
cat > www.ilovemyhome.top.ext <<'EOF'
[server_cert]
basicConstraints = critical,CA:FALSE
keyUsage = critical,digitalSignature,keyEncipherment
extendedKeyUsage = serverAuth
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
subjectAltName = @alt_names

[alt_names]
DNS.1 = www.ilovemyhome.top
DNS.2 = sso.ilovemyhome.top
DNS.5 = dns10.ilovemyhome.top
DNS.6 = db20.ilovemyhome.top
DNS.3 = sso.t
DNS.3 = dns10.t
DNS.4 = db20.t
# 如服务也通过 IP 访问，取消注释并替换为实际地址：
IP.1 = 172.16.10.20
IP.2 = 172.16.10.21
IP.3 = 172.16.10.188
IP.4 = 172.16.10.189
IP.5 = 172.16.10.30
IP.6 = 172.16.10.31
IP.7 = 172.16.10.32
EOF
```

SAN 中应列出客户端实际使用的每个 DNS 名称或 IP 地址。不要照抄示例域名或 IP。

### 3. 使用 Root CA 签发服务器证书

```bash
openssl x509 -req \
  -in csr/www.ilovemyhome.top.csr.pem \
  -CA certs/rootCA.cert.pem \
  -CAkey private/rootCA.key.pem \
  -CAcreateserial \
  -out certs/www.ilovemyhome.top.cert.pem \
  -days 1095 \
  -sha256 \
  -extfile www.ilovemyhome.top.ext \
  -extensions server_cert
```

签发时会要求输入 Root CA 私钥口令。示例服务器证书有效期为 397 天；签发证书的有效期不能超过 Root CA 的有效期，且应符合客户端和内部管理策略。

### 4. 验证签发结果

验证证书链、用途和主机名：

```bash
openssl verify \
  -CAfile certs/rootCA.cert.pem \
  -purpose sslserver \
  -verify_hostname www.ilovemyhome.top \
  certs/www.ilovemyhome.top.cert.pem
```

成功时会显示：

```text
certs/www.ilovemyhome.top.cert.pem: OK
```

检查证书的 SAN、签发者和有效期：

```bash
openssl x509 \
  -in certs/www.ilovemyhome.top.cert.pem \
  -noout -subject -issuer -dates -ext subjectAltName
```

## 五、让客户端信任 Root CA

分发给客户端的只有 `rootCA.cert.pem`，它是公开证书；**绝不分发** `rootCA.key.pem`。在 CA 管理端查看 SHA-256 指纹，并通过独立可信渠道交给客户端管理员核对：

```bash
openssl x509 -in certs/rootCA.cert.pem -noout -fingerprint -sha256
```

通过可信渠道将 `rootCA.cert.pem` 复制到 Rocky Linux 客户端（以下假设文件位于 `/tmp/rootCA.cert.pem`），核对指纹一致后安装：

```bash
openssl x509 -in /tmp/rootCA.cert.pem -noout -fingerprint -sha256

sudo install -m 0644 /tmp/rootCA.cert.pem \
  /etc/pki/ca-trust/source/anchors/internal-root-ca.crt
sudo update-ca-trust extract
```

不同操作系统和应用可能使用不同的证书信任库；有些应用还需要单独配置 CA 文件。安装后，可用以下命令验证服务器证书：

```bash
openssl verify \
  -CAfile /etc/pki/ca-trust/source/anchors/internal-root-ca.crt \
  -purpose sslserver \
  -verify_hostname www.ilovemyhome.top \
  certs/www.ilovemyhome.top.cert.pem
```

实际服务端配置通常需要服务器证书和对应私钥。按服务要求配置证书路径；如服务要求完整链文件，可将服务器证书与必要的中间 CA 证书按服务文档指定的顺序组合。不要把 Root CA 私钥放到服务端。

## 六、确实需要独立自签名服务器证书时

只有少量临时测试服务、且愿意逐台配置客户端信任时，才考虑独立自签名证书。例如：

```bash
openssl req -x509 -new \
  -newkey rsa:3072 \
  -nodes \
  -keyout git-test.key.pem \
  -out git-test.cert.pem \
  -days 365 \
  -sha256 \
  -subj "/CN=git-test.internal.example.com" \
  -addext "basicConstraints=critical,CA:FALSE" \
  -addext "keyUsage=critical,digitalSignature,keyEncipherment" \
  -addext "extendedKeyUsage=serverAuth" \
  -addext "subjectAltName=DNS:git-test.internal.example.com"

chmod 600 git-test.key.pem
```

`-nodes` 表示私钥不加密，适合需要在服务启动时自动读取私钥的场景，但必须通过文件权限等方式保护。客户端需要单独信任 `git-test.cert.pem`；如果服务增多或证书频繁更新，应改用前面的内部 CA 方案。

## 七、证书与私钥管理注意事项

- Root CA 私钥离线或严格隔离保存，限制访问并制作受保护的备份；不要提交到 Git、同步到普通网盘或放在业务服务器上。
- Root CA 证书可以分发，但在信任它之前，需通过独立可信渠道核对指纹。
- 私钥文件权限应尽可能严格；证书私钥泄露时，应停止使用并按既定流程更换。
- 证书到期前应重新签发并更新服务配置。OpenSSL 的上述简化命令不会自动提供完整的证书吊销、审计和自动续签管理；若有这些需求，应使用具备相应能力的 PKI 系统。
- 正式部署前，应在目标操作系统、浏览器、运行时和服务软件上验证证书链、SAN、用途和信任库行为。
