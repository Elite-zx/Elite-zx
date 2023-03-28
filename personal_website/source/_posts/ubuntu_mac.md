---
title: ubuntu界面Mac化 
date: 2023/3/27
categories:
- gadget 
tags: 
- tutorial
---

<meta name="referrer" content="no-referrer"/>
最终效果：<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1679904915178-2b8d446d-4d5f-42d7-9850-d5a4c0dc0bcf.png#averageHue=%232dc92b&clientId=u8ce3d915-14ae-4&from=paste&height=565&id=ueeea8242&name=image.png&originHeight=848&originWidth=1914&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=159245&status=done&style=none&taskId=u5fb92b60-b558-40fb-9a44-b1f4da5e687&title=&width=1276)
<a name="s7Ott"></a>
<!--more-->
# 1. 安装GNOME Tweaks
这个软件可以让你配置Ubuntu的交互界面，你可以在Ubuntu自带的由GNOME Software 下载<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1679900946204-c742a5d9-a91a-4b67-8a85-b82a66b80d98.png#averageHue=%235e5e5e&clientId=ud601214a-d7ed-4&from=paste&height=390&id=u117233a8&name=image.png&originHeight=743&originWidth=1084&originalType=binary&ratio=1.5625&rotation=0&showTitle=false&size=75219&status=done&style=none&taskId=uaaab7274-262a-40dc-b6b7-e1858e9749d&title=&width=568.760009765625)

<a name="i6Rr5"></a>
# 2.下载安装模拟Mac风格的交互界面主题[WhiteSur-gtk-theme](https://github.com/vinceliuice/WhiteSur-gtk-theme)
```bash
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git
cd WhiteSur-gtk-theme
./install.sh
```
<a name="dH9pb"></a>
# 3. 下载Mac图标集
```bash
git clone https://github.com/vinceliuice/WhiteSur-icon-theme
cd  WhiteSur-icon-theme
./install.sh
```
<a name="cwXmK"></a>
# 4. 解除Gnome Tweak Tool 中的扩展禁用状态
![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1679901490751-dac0bd23-34aa-40db-a176-024e2f42459f.png#averageHue=%234d4c4c&clientId=ud601214a-d7ed-4&from=paste&height=400&id=u37ab7a7f&name=image.png&originHeight=625&originWidth=1044&originalType=binary&ratio=1.5625&rotation=0&showTitle=false&size=100597&status=done&style=none&taskId=u1f3960dc-937b-4e46-b496-68fe90b71d4&title=&width=668.16)<br />安装`chrome-gnome-shell`
```bash
sudo apt install chrome-gnome-shell
```
接着跳转到[User Themes](https://extensions.gnome.org/extension/19/user-themes/)<br />安装该插件并开启<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1679901620872-e69d3a78-b565-4b13-9736-46750d55fe6b.png#averageHue=%23fcfcfb&clientId=ud601214a-d7ed-4&from=paste&height=272&id=uaa079ca5&name=image.png&originHeight=425&originWidth=1447&originalType=binary&ratio=1.5625&rotation=0&showTitle=false&size=60616&status=done&style=none&taskId=uf904ddd5-8741-44fd-b6ad-7a7442b5c3c&title=&width=926.08)<br />解决<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1679901649198-a2f7d303-960f-4b35-b96e-0bc7c8ae464b.png#averageHue=%23353534&clientId=ud601214a-d7ed-4&from=paste&height=390&id=u3191091d&name=image.png&originHeight=609&originWidth=1044&originalType=binary&ratio=1.5625&rotation=0&showTitle=false&size=76490&status=done&style=none&taskId=u79e6d1ca-ed2a-420f-9c0b-caec1b63807&title=&width=668.16)

<a name="p4iNI"></a>
# 5. 安装Mac风格的Dock
安装并开启[Dash to Dock](https://extensions.gnome.org/extension/307/dash-to-dock/)，并可自行设置Dock样式<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1679903078052-658ae42a-c311-4990-93f7-dc8700c3ddb5.png#averageHue=%23696969&clientId=u33b15efd-72b8-4&from=paste&height=437&id=ub859c8a3&name=image.png&originHeight=683&originWidth=1385&originalType=binary&ratio=1.5625&rotation=0&showTitle=false&size=168939&status=done&style=none&taskId=u7cf1d85f-9a5e-4770-8407-ce5971d3b0b&title=&width=886.4)

<a name="EAoF9"></a>
# 6. 将交通灯移动到窗口右侧
在GNOME Tweaks -> Window Titlebars -> Left<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1679904374525-112bf886-c3ed-4b08-8636-460188802e21.png#averageHue=%23393938&clientId=u053a5944-acf3-4&from=paste&height=429&id=u3ec2f613&name=image.png&originHeight=643&originWidth=1066&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=79002&status=done&style=none&taskId=u3d4a3f13-0d2f-4d62-9dff-3a863f75003&title=&width=710.6666666666666)

