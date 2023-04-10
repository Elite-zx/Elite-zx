---
title: "汇编语言【王爽】实验流程"
date: 2023-03-06
categories: 
- CSAPP
tag: 
- Foundation
---
<meta name="referrer" content="no-referrer"/>
<a name="MTE7s"></a>
# 前言：
前前后后看完这本书，做完所有实验和检测点，用了接近一个月的时间，除了最后几天比较认真，其余时间是比较懒散的，这本书其实最多半个月就能解决掉。接下来会步入CSAPP第三章的学习，争取早日把有名的attack lab完成了
<!--more-->
---

<a name="PhqOH"></a>
# 实验1 查看CPU和内存，用机器指令和汇编指令编程
<a name="xymUo"></a>
## debug环境搭建：[参考此文](https://blog.csdn.net/YuzuruHanyu/article/details/80287419?spm=1001.2014.3001.5506)
<a name="UrdzB"></a>
## assignment 1

1. 用A命令向内存中写入汇编指令，用U命令查看

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673249473372-3a80b2ab-d9e2-483c-ac41-140d30fdd765.png#averageHue=%23161616&clientId=uc99250e8-54b1-4&from=paste&height=248&id=ub963f2d1&name=image.png&originHeight=245&originWidth=374&originalType=binary&ratio=1&rotation=0&showTitle=false&size=6659&status=done&style=none&taskId=u0fa9efb8-dccf-4ce1-b3ea-8d79929c540&title=&width=378)

2. 用R命令分别修改CS、IP寄存器，即CS:IP的指向，用T命令逐条执行

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673249669344-d36231e5-8310-46ba-a3c6-155e2601ff58.png#averageHue=%230e0e0e&clientId=uc99250e8-54b1-4&from=paste&height=309&id=udc060390&name=image.png&originHeight=309&originWidth=608&originalType=binary&ratio=1&rotation=0&showTitle=false&size=7838&status=done&style=none&taskId=udc51570f-ded8-4f72-a2f5-ee442502176&title=&width=608)
<a name="rTW1r"></a>
## assignment 2

1. 写入并查看指令

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673250172971-61fbb876-feda-4ca9-b81d-e558cc0e5a6a.png#averageHue=%23151515&clientId=uc99250e8-54b1-4&from=paste&height=174&id=u55f6e2fe&name=image.png&originHeight=174&originWidth=376&originalType=binary&ratio=1&rotation=0&showTitle=false&size=4324&status=done&style=none&taskId=u9c9ba619-9a5c-4e5c-9e9d-45d5a6ea724&title=&width=376)

2. 修改_CS:IP_指向

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673250237721-ec3e62f5-f6bc-4890-8f25-b62f6d89e60e.png#averageHue=%230c0c0c&clientId=uc99250e8-54b1-4&from=paste&height=228&id=u87c23aee&name=image.png&originHeight=228&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=false&size=7409&status=done&style=none&taskId=u0c70f1dc-bfd2-4472-a4d5-84a3fe97214&title=&width=642)

3. 执行指令，计算$2^8$，结果为 $AX = 0100H$

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673250558182-3582fd8d-9783-421c-9731-0d83ae5c81a8.png#averageHue=%23121212&clientId=uc99250e8-54b1-4&from=paste&height=72&id=u92a48cc6&name=image.png&originHeight=72&originWidth=583&originalType=binary&ratio=1&rotation=0&showTitle=false&size=2934&status=done&style=none&taskId=ud124b271-ce25-43f5-aabf-1f9dd478c19&title=&width=583)
<a name="QAZ3Z"></a>
## assignment 3

1. 用D命令查找，最终在$FFFF5H \to FFFFCH（FFFF:0005 \to FFFF:000C）$发现$dd/mm/yy$字样的生产日期

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673251622812-ca79ef23-5a2a-46b2-ba9f-326aa9d3bc54.png#averageHue=%23161616&clientId=uc99250e8-54b1-4&from=paste&height=68&id=ud8481a70&name=image.png&originHeight=68&originWidth=630&originalType=binary&ratio=1&rotation=0&showTitle=false&size=3411&status=done&style=none&taskId=u26b9075a-3732-4bca-831f-f7252d9a335&title=&width=630)

2. 尝试用E命令修改，该操作失效，因为这是ROM

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673251941938-25cdf39e-5c26-49a3-81da-f108dff28da7.png#averageHue=%230f0f0f&clientId=uc99250e8-54b1-4&from=paste&height=120&id=u23687460&name=image.png&originHeight=120&originWidth=632&originalType=binary&ratio=1&rotation=0&showTitle=false&size=4133&status=done&style=none&taskId=uca81322b-a794-4e03-b596-0d7a694a021&title=&width=632)
<a name="CHS7t"></a>
## assignment 4
1.$A0000H \to BFFFFH$对8086 PC机是显存地址，往这个范围内的内存写入数据，会改变显示器上的内容，我们可以看见屏幕上出现了笑脸、爱心和钻石<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673253290191-823908a7-61e0-4e4d-ac20-66184b8a4509.png#averageHue=%23141414&clientId=uc99250e8-54b1-4&from=paste&height=24&id=udb4b1014&name=image.png&originHeight=24&originWidth=316&originalType=binary&ratio=1&rotation=0&showTitle=false&size=646&status=done&style=none&taskId=uc1f68660-8c22-4e6b-81ab-8168f9d217e&title=&width=316)<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673253301915-ead25a09-d4a2-48f2-ba25-7bb4b7279d64.png#averageHue=%230000aa&clientId=uc99250e8-54b1-4&from=paste&height=46&id=u1f906edf&name=image.png&originHeight=46&originWidth=489&originalType=binary&ratio=1&rotation=0&showTitle=false&size=1808&status=done&style=none&taskId=u8980a613-e82f-4ceb-a518-1e33c095648&title=&width=489)

---

<a name="hcb7h"></a>
# 实验2 用机器指令和汇编指令编程
<a name="vDc8z"></a>
## assignment 1

1. 用A指令向内存中写入汇编指令，用U指令查看

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673596808599-b129a717-4d20-42a3-8823-64dc726440e3.png#averageHue=%23151515&clientId=u2caa9258-9642-4&from=paste&height=236&id=uc9b341b4&name=image.png&originHeight=236&originWidth=374&originalType=binary&ratio=1&rotation=0&showTitle=false&size=6210&status=done&style=none&taskId=uf45debe0-8185-465e-b3c1-03874bac6c7&title=&width=374)

2. 修改CS:IP使其指向代码段

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673596896692-f6335ebe-e9b7-44cf-9a38-d686dde7d140.png#averageHue=%230a0a0a&clientId=u2caa9258-9642-4&from=paste&height=162&id=u325eac60&name=image.png&originHeight=162&originWidth=577&originalType=binary&ratio=1&rotation=0&showTitle=false&size=4064&status=done&style=none&taskId=uaa5719c7-c665-4f9e-baa5-b5de2b24fc8&title=&width=577)、

3. t命令逐步执行指令后查看AX、BX、SP寄存器内容

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673597028389-791ccf84-0268-4f23-976f-53e6ecd97b36.png#averageHue=%23121212&clientId=u2caa9258-9642-4&from=paste&height=374&id=ueb563e3c&name=image.png&originHeight=374&originWidth=635&originalType=binary&ratio=1&rotation=0&showTitle=false&size=15302&status=done&style=none&taskId=u24406e7c-e085-4926-bf36-d7ff7eeb06a&title=&width=635)
<a name="NB9fg"></a>
## assignment 2
在使用T命令进行单步追踪的时候，产生了中断，为了保护现场，CPU将PSW、CS和IP依此入栈，导致了内存相关位置内容的改变（保留疑问）

---

<a name="jpe3I"></a>
# 实验3 编程、编译、链接、跟踪
<a name="QMUAH"></a>
## assignment 1

1. 编译链接生成可执行文件

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673681789903-cb9f13be-b044-4c3f-be1d-8fa401195306.png#averageHue=%230b0b0b&clientId=ufc3ba72b-b1bc-4&from=paste&height=328&id=ufc540080&name=image.png&originHeight=328&originWidth=524&originalType=binary&ratio=1&rotation=0&showTitle=false&size=8289&status=done&style=none&taskId=uaf6acc9d-3a30-400a-b361-0bea1d87366&title=&width=524)
<a name="bm7kI"></a>
## assignment 2

1. debug将程序载入内存，设置CS:IP：程序所在内存段的段地址为$DS=075C$，则PSP的地址为$075C:0$，程序的地址为$076C:0\;(075C+10:0)$,$CS:IP = 076C:0000$

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673682350829-98451696-0d75-4414-87c5-b527b5c96169.png#averageHue=%23111111&clientId=ufc3ba72b-b1bc-4&from=paste&height=90&id=u24027707&name=image.png&originHeight=90&originWidth=583&originalType=binary&ratio=1&rotation=0&showTitle=false&size=3436&status=done&style=none&taskId=u88d9a7fb-f08c-4035-82ab-48a67509d8f&title=&width=583)

2. 跟踪程序执行过程

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673682565168-917f19d2-8e0c-44ab-84e5-453c301bcda0.png#averageHue=%23111111&clientId=ufc3ba72b-b1bc-4&from=paste&height=378&id=u739eac5d&name=image.png&originHeight=378&originWidth=593&originalType=binary&ratio=1&rotation=0&showTitle=false&size=13977&status=done&style=none&taskId=u7a4cf037-0141-418c-a6bc-3a455f22fa1&title=&width=593)<br />用P命令执行`INT 21`<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673682678668-4d6f6ba6-a61b-408a-8aa9-f84fdd1abc8a.png#averageHue=%230d0d0d&clientId=ufc3ba72b-b1bc-4&from=paste&height=386&id=ue3d6f0ce&name=image.png&originHeight=386&originWidth=620&originalType=binary&ratio=1&rotation=0&showTitle=false&size=12637&status=done&style=none&taskId=ud602a7a4-6c24-495c-b269-66ce57ddba3&title=&width=620)
<a name="fqp3r"></a>
## assignment 3

1. 查看PSP的内容

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673682886059-386e1af8-2b73-480f-92b1-d2ea01cce40a.png#averageHue=%23161616&clientId=ufc3ba72b-b1bc-4&from=paste&height=175&id=ueb72f5b4&name=image.png&originHeight=175&originWidth=625&originalType=binary&ratio=1&rotation=0&showTitle=false&size=6346&status=done&style=none&taskId=ufec3ae9d-8d07-4ba6-ae47-78454c6ed61&title=&width=625)

---

<a name="eTiIA"></a>
# 实验4 [bx]和loop的使用
<a name="Ypsn2"></a>
## assignment 1

1. 编写源程序
```
assume cs:codesg

codesg segment

mov ax, 0020H
mov ds, ax
mov bx, 0
mov dx, 0
mov cx, 64

s: 
mov [bx],dx
inc bx
inc dx
loop s

mov ax, 4c00h 
int 21h

codesg ends
end
```

2. 编译，链接生成可执行文件

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673769654198-dcf5a11b-b298-4d67-ac52-e6412baa7953.png#averageHue=%230a0a0a&clientId=ua6d781cd-6a2a-4&from=paste&height=308&id=ucb1b0e3f&name=image.png&originHeight=308&originWidth=563&originalType=binary&ratio=1&rotation=0&showTitle=false&size=9162&status=done&style=none&taskId=ud2798294-b700-4d36-9278-b89b6f31b7e&title=&width=563)

3. 查看载入内存的程序，可以看见标签s已被替换为地址$076C:000E$

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673770040980-f6175097-5e41-41f0-a0d4-ed6dcc9e2d26.png#averageHue=%230f0f0f&clientId=ua6d781cd-6a2a-4&from=paste&height=257&id=ub7d89c02&name=image.png&originHeight=257&originWidth=601&originalType=binary&ratio=1&rotation=0&showTitle=false&size=9471&status=done&style=none&taskId=u76baa400-787b-4ed1-b282-488abb7c243&title=&width=601)

4. 执行程序，验证结果，正确

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673770269260-0b535c86-7318-4bea-9b9b-151df8786503.png#averageHue=%23151515&clientId=ua6d781cd-6a2a-4&from=paste&height=144&id=u9760e10a&name=image.png&originHeight=144&originWidth=480&originalType=binary&ratio=1&rotation=0&showTitle=false&size=4621&status=done&style=none&taskId=u407ff41a-3998-40b9-80e2-b904a9486e8&title=&width=480)
<a name="q95Oy"></a>
## assignment 2 

1. 编写源程序：将bx寄存器两用，即作偏移地址，又作操作数，可将程序缩短为9条指令
```
assume cs:codesg

codesg segment

mov ax, 0020H
mov ds, ax
mov bx, 0
mov cx, 64

s: 
mov [bx],bx
inc bx
loop s

mov ax, 4c00h 
int 21h

codesg ends
end
```

2. 其它步骤与assigment 1一致，验证结果，正确

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673771416582-e853218d-46c6-4bf8-98d6-cacae4200dbb.png#averageHue=%231a1a1a&clientId=u7cc11769-d150-4&from=paste&height=359&id=u85d074a9&name=image.png&originHeight=373&originWidth=490&originalType=binary&ratio=1&rotation=0&showTitle=false&size=9679&status=done&style=none&taskId=uca7996c4-5515-4485-9bd2-5bed6cf48b4&title=&width=472)
<a name="b3BKL"></a>
## assignment 3

1. 复制的是什么：复制程序的第一条指令`mov ax,cs`到 `loop s` 指令至内存地址$0020:0000$处
2. 如何知道程序的字节数：首先可以确定第一个空应该填入CS，这是程序的段地址，其次在`mov cx,_____` 上先随意填一个1，用debug跟踪程序，用U命令查看程序所占地址范围：$076C:0000 \to 076C:0015$，共$16H\,(23D)$个字节,因此第二个空应该填入$16H$

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673774640766-de55642e-4594-4add-9f75-ac17f9cf3628.png#averageHue=%230d0d0d&clientId=u7cc11769-d150-4&from=paste&height=282&id=u704b4ac0&name=image.png&originHeight=282&originWidth=616&originalType=binary&ratio=1&rotation=0&showTitle=false&size=9580&status=done&style=none&taskId=u46b6c23e-98fc-45b4-ad17-7f7d7bef327&title=&width=616)

---

<a name="l6DRo"></a>
# 实验5 编写、调试具有多个段的程序
<a name="y07m5"></a>
## assignment 1

1. 将程序载入内存后查看，可知data段段地址为$076C$, stack段段地址为$076D$，code段段地址为$076E$

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673877104816-d24fcee5-293b-4965-a116-55b74e84812c.png#averageHue=%23101010&clientId=u1b2351c9-0f42-4&from=paste&height=266&id=u68a1fe4a&name=image.png&originHeight=266&originWidth=619&originalType=binary&ratio=1&rotation=0&showTitle=false&size=10189&status=done&style=none&taskId=u25c1d019-e4f1-4cb3-9fef-a5363cacec8&title=&width=619)

2. Q1：`G 001D`执行程序至程序返回前，用U命令查看data段内容: $0123H,0456H,0789H,0ABCH,0DEFH,0FEDH,0CBAH,0987H$，与初状态(源程序)一致，该程序按顺序做了入栈和出栈操作，因此数据不变

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673877337524-5a528fcf-a7ec-47a7-ba04-6014616d76ff.png#averageHue=%231a1a1a&clientId=u1b2351c9-0f42-4&from=paste&height=51&id=u84a23991&name=image.png&originHeight=51&originWidth=480&originalType=binary&ratio=1&rotation=0&showTitle=false&size=1917&status=done&style=none&taskId=u5609cee2-98bd-479e-9a89-84510ea0a9d&title=&width=480)

3. Q2：R命令查看各个段寄存器的值  $\to \;CS:076E$、 $DS:076C$、$SS:076D$

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673877858110-72e7472f-1574-4c88-ae28-a064f40894e4.png#averageHue=%23131313&clientId=u1b2351c9-0f42-4&from=paste&height=73&id=u1f2d1ce2&name=image.png&originHeight=73&originWidth=592&originalType=binary&ratio=1&rotation=0&showTitle=false&size=3486&status=done&style=none&taskId=ub88918a8-2d91-4abe-b21e-299699ae7ce&title=&width=592)

4. Q3：data段和stack段分别占16个字节，因此设code段段地址为$X$，那么stack段段地址为$X-1H$，data段段地址为$X-2H$（做了assignment2后可以发现这里说法并不准确）
<a name="qSFne"></a>
## assignment 2

1. 步骤与assigment1 完全一致

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673878358257-7f67627a-48a8-45cf-bc4a-1f51e9552faa.png#averageHue=%230f0f0f&clientId=u1b2351c9-0f42-4&from=paste&height=265&id=u246ed639&name=image.png&originHeight=265&originWidth=615&originalType=binary&ratio=1&rotation=0&showTitle=true&size=9903&status=done&style=none&taskId=ud7500b3a-6b24-43c1-8498-3e220eabeef&title=%E6%BA%90%E7%A8%8B%E5%BA%8F%E8%BD%BD%E5%85%A5%E5%86%85%E5%AD%98%E5%90%8E%E7%94%A8U%E5%91%BD%E4%BB%A4%E6%9F%A5%E7%9C%8B%EF%BC%8C%E5%8F%91%E7%8E%B0%E5%90%84%E4%B8%AA%E6%AE%B5%E7%9A%84%E5%9C%B0%E5%9D%80%E4%B8%8Eassignment1%E5%AE%8C%E5%85%A8%E4%B8%80%E8%87%B4&width=615 "源程序载入内存后用U命令查看，发现各个段的地址与assignment1完全一致")<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673878450151-f2a27665-630b-4784-9a07-7c364c930469.png#averageHue=%23111111&clientId=u1b2351c9-0f42-4&from=paste&height=84&id=u67d44730&name=image.png&originHeight=84&originWidth=582&originalType=binary&ratio=1&rotation=0&showTitle=true&size=3313&status=done&style=none&taskId=u45570d21-23d5-4112-8fa2-e8d2f41ad8a&title=%E6%89%A7%E8%A1%8C%E7%A8%8B%E5%BA%8F%E8%87%B3%E7%A8%8B%E5%BA%8F%E8%BF%94%E5%9B%9E%E5%89%8D&width=582 "执行程序至程序返回前")<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673878510541-e58f6906-dc84-4df0-a6a2-59cfdf0b4a07.png#averageHue=%231a1a1a&clientId=u1b2351c9-0f42-4&from=paste&height=54&id=u68b4b398&name=image.png&originHeight=54&originWidth=504&originalType=binary&ratio=1&rotation=0&showTitle=true&size=2010&status=done&style=none&taskId=u823673f9-a9eb-4ebf-a4ee-ae34390d952&title=%E6%9F%A5%E7%9C%8Bdata%E6%AE%B5%E6%95%B0%E6%8D%AE%EF%BC%8C%E4%B8%8E%E6%BA%90%E7%A8%8B%E5%BA%8F%E4%B8%80%E8%87%B4%EF%BC%8C%E6%9C%AA%E6%94%B9%E5%8F%98&width=504 "查看data段数据，与源程序一致，未改变")<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673878562565-32d00b48-a53b-4868-916e-9e7ddb4a279d.png#averageHue=%23131313&clientId=u1b2351c9-0f42-4&from=paste&height=72&id=udc9f18e6&name=image.png&originHeight=72&originWidth=598&originalType=binary&ratio=1&rotation=0&showTitle=true&size=3334&status=done&style=none&taskId=uf3897f64-0600-409f-903a-e0c60d2a195&title=%E6%9F%A5%E7%9C%8B%E5%AF%84%E5%AD%98%E5%99%A8%E5%86%85%E5%AE%B9%EF%BC%8C%E5%90%84%E6%AE%B5%E5%AF%84%E5%AD%98%E5%99%A8%E5%86%85%E5%AE%B9%E4%B8%8Eassignment1%E5%AE%8C%E5%85%A8%E4%B8%80%E8%87%B4&width=598 "查看寄存器内容，各段寄存器内容与assignment1完全一致")

2. 得出结论：段无论大小，在源程序载入内存后，段所占内存大小一定为16的整数倍
<a name="AiceH"></a>
## assignment 3

1. 步骤与assignment1完全一致

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673879121558-74eaedb2-acd9-4a9c-a318-e028bba49db2.png#averageHue=%23101010&clientId=u1b2351c9-0f42-4&from=paste&height=264&id=u5b46f0b2&name=image.png&originHeight=264&originWidth=583&originalType=binary&ratio=1&rotation=0&showTitle=true&size=9249&status=done&style=none&taskId=uab9b0f8d-e010-40c9-ba7f-3de6b6e1d63&title=%E8%B5%B7%E5%A7%8B%E6%AE%B5%E4%B8%BAcode%E6%AE%B5%20%28076C%29%EF%BC%8C%E5%90%8E%E9%9D%A2%E8%B7%9F%E7%9D%80data%E6%AE%B5%28076F%29%E5%92%8Cstack%E6%AE%B5%280770%29&width=583 "起始段为code段 (076C)，后面跟着data段(076F)和stack段(0770)")<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673879373761-d05b59a9-6591-4c25-8033-e83698bff61e.png#averageHue=%23171717&clientId=u1b2351c9-0f42-4&from=paste&height=294&id=u7e2149b7&name=image.png&originHeight=294&originWidth=625&originalType=binary&ratio=1&rotation=0&showTitle=true&size=10607&status=done&style=none&taskId=u25c23b4d-250b-45e7-aa47-be84b0e1458&title=%E6%89%A7%E8%A1%8C%E7%A8%8B%E5%BA%8F%E8%87%B3%E7%A8%8B%E5%BA%8F%E8%BF%94%E5%9B%9E%E5%89%8D%EF%BC%8C%E6%9F%A5%E7%9C%8Bdata%E6%AE%B5%E5%86%85%E5%AE%B9%E5%92%8C%E5%90%84%E4%B8%AA%E6%AE%B5%E5%AF%84%E5%AD%98%E5%99%A8%E7%9A%84%E5%80%BC&width=625 "执行程序至程序返回前，查看data段内容和各个段寄存器的值")<br />2， 设code段段地址为$X$，那么data段段地址为$X+3H$，stack段段地址为$X+4H$
<a name="NxsNH"></a>
## assignment 4
如果去掉通知编译器程序的入口的`end start `语句，那么唯一可正确运行的是起始段为code段的程序3
<a name="oVwXx"></a>
## assignment 5

1. 编写源程序，注意在将段地址写入$DS$时，要借助一个寄存器充当介质，因为立即数无法直接写入$DS$
```
assume cs:code

a segment 
db 1,2,3,4,5,6,7,8
a ends

b segment
db 1,2,3,4,5,6,7,8
b ends

c segment 
db 0,0,0,0,0,0,0,0
c ends

code segment
start:
mov bx, 0
mov cx, 8
s:
mov dx, a
mov ds,dx
mov ax, [bx]
mov dx, b
mov ds,dx
add ax, [bx]
mov dx, c
mov ds,dx
mov [bx], ax
inc bx
loop s

mov ax,4c00H
int 21H

code ends

end start

```

2. 用debug跟踪程序，可以看到a段段地址：$076C$、b段段地址：$076D$、c段段地址：$076E$

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673882442409-a3ef513e-eb43-4f18-abf5-ea6f262cc3f6.png#averageHue=%230e0e0e&clientId=u1b2351c9-0f42-4&from=paste&height=333&id=u80ddd30c&name=image.png&originHeight=333&originWidth=603&originalType=binary&ratio=1&rotation=0&showTitle=false&size=11543&status=done&style=none&taskId=u0f76c72f-ed96-431c-8d71-352a3ca1f86&title=&width=603)

3. 执行程序，查看c段内容，正确

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673882790995-352f2b4b-203d-458a-b5a2-878acfd29335.png#averageHue=%231e1e1e&clientId=u1b2351c9-0f42-4&from=paste&height=59&id=uc023038f&name=image.png&originHeight=59&originWidth=498&originalType=binary&ratio=1&rotation=0&showTitle=true&size=2633&status=done&style=none&taskId=ucae589f2-04bc-4644-899d-6fdbd17e620&title=%E6%89%A7%E8%A1%8C%E7%A8%8B%E5%BA%8F%E5%89%8D%EF%BC%8CC%E6%AE%B5%E5%86%85%E5%AE%B9&width=498 "执行程序前，C段内容")<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673882830219-1912f93e-456b-47b1-b06a-32816e308e07.png#averageHue=%23171717&clientId=u1b2351c9-0f42-4&from=paste&height=95&id=ud9a53aa1&name=image.png&originHeight=95&originWidth=479&originalType=binary&ratio=1&rotation=0&showTitle=true&size=3576&status=done&style=none&taskId=udb82a728-cd51-436e-9481-a8a6f072f71&title=%E6%89%A7%E8%A1%8C%E7%A8%8B%E5%BA%8F%E5%90%8E%EF%BC%8CC%E6%AE%B5%E5%86%85%E5%AE%B9&width=479 "执行程序后，C段内容")
<a name="azFBM"></a>
## assignment 6

1. 编写源程序，注意bx变化值应为2，因为push、pop操作是以字为单位的
```
assume cs:code
a segment
dw 1,2,3,4,5,6,7,8,9,0ah,0bh,0ch,0dh,0eh,0fh,0ffh
a ends

b segment 
dw 0,0,0,0,0,0,0,0
b ends

code segment 
start:
mov ax, a
mov ds, ax
mov ax, b 
mov ss, ax
mov sp, 0010H
mov bx, 0
mov cx, 8
s:
push [bx]
add bx, 2
loop s

mov ax, 4c00H
int 21H

code ends

end start
```

2. 用debug跟踪程序，可以看到a段段地址： $076C$ 、 b段段地址：$076E$、code段段地址：$076F$

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673885232599-a5e6bf92-ae97-421b-ad5b-904f427aef76.png#averageHue=%230f0f0f&clientId=u1b2351c9-0f42-4&from=paste&height=296&id=ub52c7fd8&name=image.png&originHeight=296&originWidth=590&originalType=binary&ratio=1&rotation=0&showTitle=false&size=10267&status=done&style=none&taskId=ub78885e9-2d92-486e-abce-ac5186f563b&title=&width=590)

3. 执行程序，查看b段内容，正确

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673885271367-eddf0cc8-98aa-4fe8-a38f-a014ed5f8179.png#averageHue=%231b1b1b&clientId=u1b2351c9-0f42-4&from=paste&height=228&id=ud387c905&name=image.png&originHeight=228&originWidth=525&originalType=binary&ratio=1&rotation=0&showTitle=false&size=10970&status=done&style=none&taskId=u9df34674-6438-4f64-8810-2056308e5b5&title=&width=525)

---

<a name="O7BgM"></a>
# 实验6 实践课程中的程序
<a name="dyxQS"></a>
## assignment 1

1. 这里只实践了问题7.8的解决方案（用栈作数据缓冲区），如下
```
assume cs:codesg, ds:datasg, ss:stacksg

datasg segment 
db 'ibm             '
db 'dec             '
db 'dos             '
db 'vax             '
datasg ends

stacksg segment
dw 0,0,0,0,0,0,0,0
stacksg ends

codesg segment
start:
mov ax, stacksg
mov ss, ax
mov sp, 10H
mov ax, datasg
mov ds, ax
mov bx, 0
mov cx, 4
s0:
push cx
mov si, 0
mov cx, 3
s:
mov al, [bx+si]
and al, 11011111B
mov [bx+si], al
inc si
loop s 

pop cx
add bx, 10H
loop s0

mov ax, 4c00H
int 21H

codesg ends

end start
```

2. 跟踪程序，查看data段内容

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673954476992-988989f0-7ba5-4132-8b53-011e5cfe1ce7.png#averageHue=%23111111&clientId=ue12bca8e-25be-4&from=paste&height=332&id=u6d512701&name=image.png&originHeight=332&originWidth=619&originalType=binary&ratio=1&rotation=0&showTitle=false&size=11651&status=done&style=none&taskId=uac27a62a-e7e2-4573-8364-30a015779f0&title=&width=619)

3. 执行程序后，查看data段内容，正确

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673954644257-b63d5af0-f266-4057-b1e1-c513e09c9298.png#averageHue=%23151515&clientId=ue12bca8e-25be-4&from=paste&height=114&id=u73878512&name=image.png&originHeight=114&originWidth=574&originalType=binary&ratio=1&rotation=0&showTitle=false&size=4009&status=done&style=none&taskId=u92fc65de-f6f5-42c1-84b2-350c1e4d948&title=&width=574)
<a name="pHbEJ"></a>
## assignment 2

1. 编写源程序，双层循环中，进入第二层循环之后立马将cx压入栈中暂存，可避免双层循环在使用cx寄存器上的冲突
```
assume cs:codesg, ds:datasg, ss:stacksg

stacksg segment
dw 0,0,0,0,0,0,0,0
stacksg ends

datasg segment 
db '1. display      '
db '2. brows        '
db '3. replace      '
db '4. modify       '
datasg ends

codesg segment
start:
mov ax, stacksg
mov ss, ax
mov sp, 10H 
mov ax, datasg
mov ds, ax
mov bx, 0
mov cx, 4
s0:
push cx
mov cx, 4
mov si, 0
s: 
mov al, [bx+3+si]
and al, 11011111B
mov [bx+3+si], al
inc si
loop s

pop cx
add bx, 10H
loop s0

mov ax, 4c00H
int 21H

codesg ends

end start



```

2. 跟踪程序，查看data段内容

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673955793129-198d15a6-56f1-4375-a4c1-fa6d84e6aa7c.png#averageHue=%23111111&clientId=ue12bca8e-25be-4&from=paste&height=311&id=u5ce4b731&name=image.png&originHeight=311&originWidth=623&originalType=binary&ratio=1&rotation=0&showTitle=false&size=12680&status=done&style=none&taskId=u132e706b-1ed7-4582-becb-0f6cd930428&title=&width=623)

3. 执行程序，查看data段内容，正确

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1673955864652-707fd6d7-d65d-4be6-b3f9-bbcbbc27484b.png#averageHue=%23151515&clientId=ue12bca8e-25be-4&from=paste&height=110&id=ubb174b39&name=image.png&originHeight=110&originWidth=618&originalType=binary&ratio=1&rotation=0&showTitle=false&size=5260&status=done&style=none&taskId=u786ee51b-5382-4915-8eb1-9feeb54fdba&title=&width=618)

---

<a name="MJU1z"></a>
# 实验7 寻址方式在结构化数据访问中的应用

1. 编写源程序，用`word ptr / byte ptr`指定内存单元大小主要应用在`div`指令或用于向内存写入立即数
```
assume cs:codesg

stack segment
dw 0,0,0,0,0,0,0,0
stack ends

data segment
db '1975','1976', '1977', '1978', '1979', '1980', '1981', '1982','1983'
db '1984', '1985', '1986', '1987', '1988', '1989', '1990', '1991', '1992'
db '1993', '1994', '1995'

dd 16,22,382,1356,2390, 8000, 16000,24486,50065, 97479,140417,197514
dd 345980,590827,803530,1183000,1843000,2759000, 3753000, 4649000,5937000

dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793, 4037,5635, 8226
dw 11542,14430,15257,17800
data ends

table segment
db 21 dup ('year summ ne ?? ')
table ends

codesg segment
start:
mov ax, stack ;0776C
mov ss, ax
mov sp, 10H
mov ax, data ; 076D
mov es, ax
mov ax, table ; 077b
mov ds, ax
mov bx,0
mov si,0
mov cx,21

year:
push cx
mov cx, 4
mov di, 0
char:
mov al, es:[si]
mov [bx+di], al
inc di
inc si
loop char
pop cx
add bx, 10H
loop year

mov cx, 21
mov bx, 0
income:
push cx
mov cx, 2
mov di, 0
dwInt:
mov ax, es:[si]
mov [bx].5[di], ax
add si, 2
add di, 2
loop dwInt
pop cx
add bx, 10H
loop income

mov cx, 21
mov bx, 0
staff:
mov ax, es:[si]
mov [10+bx], ax
add si, 2;
add bx, 10H
loop staff

mov cx, 21
mov bx, 0
average:
mov dx, [bx+7]
mov ax, [bx+5]
div word ptr [bx+0AH]
mov [bx+0Dh], ax
add bx, 10H
loop average

mov ax, 4C00H
int 21H
codesg ends
end start 
```

2. 查看原始table段的内容

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1674054412418-905eb553-63b9-4352-8fd3-87d9c57ec955.png#averageHue=%231d1d1d&clientId=u59b02d03-003e-4&from=paste&height=312&id=ue1c1140e&name=image.png&originHeight=312&originWidth=640&originalType=binary&ratio=1&rotation=0&showTitle=false&size=19887&status=done&style=none&taskId=ue6fc1e9d-9b84-43c0-852e-a69d953b492&title=&width=640)

3. 执行程序后，查看table段的内容，正确

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1674054465034-493bafb1-d935-4da9-b3d0-07b0bdd54911.png#averageHue=%231b1b1b&clientId=u59b02d03-003e-4&from=paste&height=378&id=u98d88789&name=image.png&originHeight=378&originWidth=630&originalType=binary&ratio=1&rotation=0&showTitle=false&size=21611&status=done&style=none&taskId=u95e0d8ba-0b80-4cd2-9a0a-a3aaec2f835&title=&width=630)
<a name="wI3bu"></a>
# 实验8 分析一个奇怪的程序

1. 程序从$start$入口处开始执行，一个`nop`指令占一个字节并表示No operation，此处用了两个`nop`指令的目的是在$s$处预留两个字节的空间，程序执行`mov cs:[di], ax`之后$s$处的两个字节被试图写入`jmp short s1`，接着程序向下执行`jmp short s`使得程序跳转回$s$处开始执行。
2. `jmp short s1`到底做了什么：修改IP使其前进十个字节。因为该指令本身的作用是使IP从$s2$跳转到$s1$，即从$s2$处的jmp指令的下一指令`nop`$(076C:0022)$跳转到$s1$处的`mov ax, 0`$(076C:0018)$，因为`jmp short 标号`是依据位移进行转移的指令，而此处位移大小为$0022H-0018H =-10D(F6H)$，所以$s$处的`jmp short s`指令的机器码为`EBF6`（刚好占两个字节，因此可以被正确写入$s$处）
3. 执行$s$处的跳转指令，使得$IP = IP+(-10)$,即向前移动十位，用debug跟踪程序，可以看到向前第十个指令为`mov ax, 4c00H`$(000AH-0010H=0000H)$，程序从此处开始向下执行，最终可以正确退出

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1674306714709-54439679-a96b-496d-97b1-de0f2c3abf77.png#averageHue=%230d0d0d&clientId=u6f9c44da-f55a-4&from=paste&height=383&id=u78c30e80&name=image.png&originHeight=383&originWidth=595&originalType=binary&ratio=1&rotation=0&showTitle=false&size=10505&status=done&style=none&taskId=uae9cedf9-248f-4122-b32a-b23020dad5f&title=&width=595)<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1674308784974-d476fbd5-6642-45a7-8e5a-a3db1e5ed646.png#averageHue=%230a0a0a&clientId=u6f9c44da-f55a-4&from=paste&height=150&id=ua98d7cca&name=image.png&originHeight=150&originWidth=640&originalType=binary&ratio=1&rotation=0&showTitle=false&size=3506&status=done&style=none&taskId=ufcfb45ef-5abd-4191-9c60-6ca3d7ac8c6&title=&width=640)
<a name="lZyJr"></a>
# 实验9 根据材料编程

1. 编写源程序：最开始我试图用`mov address，data`的形式直接向显存中写入数据，并且比较蠢的一个字符一个字符的输入，但这种形式的mov指令对显存区域似乎并不奏效，实操之后发现显存内容未被修改为给定值，并且其内容还在动态的变化(?)。之后利用栈存储数据`welcome to masm!`，利用寄存器$ax$作介质，用mov指令实现内存之间的内容交换，避免了重复手动输入数据
```
assume cs:codesg

data segment
db 'welcome to masm!'
data ends

codesg segment
start: 
mov ax, data
mov ds, ax
mov ax, 0B800H
mov es, ax

mov bx, 0
mov si, 1824
mov cx, 10H
s0:
mov ah, 82H
mov al, [bx]
mov es:[si], ax
inc bx
add si, 2
loop s0

mov bx, 0 
mov si, 1984
mov cx, 10H
s1:
mov ah, 0A4H
mov al, [bx]
mov es:[si], ax
inc bx
add si, 2
loop s1

mov bx, 0 
mov si, 2144
mov cx, 10H
s2:
mov ah, 11110001B
mov al, [bx]
mov es:[si], ax
inc bx
add si, 2
loop s2

mov ax, 4c00H
int 21H
codesg ends

end start
```

2. 最终效果

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1674447541217-19494cef-6da4-4fd3-b28c-6ad18c755471.png#averageHue=%23080808&clientId=u2be92af7-bf87-4&from=paste&height=400&id=u7d46ece7&name=image.png&originHeight=400&originWidth=640&originalType=binary&ratio=1&rotation=0&showTitle=false&size=8808&status=done&style=none&taskId=u5b2b0b44-a96d-458a-878e-8f9b74b9697&title=&width=640)

<a name="zPzcC"></a>
# 实验10 编写子程序
<a name="Z9mXL"></a>
## assignment 1

1. 编写源程序，在子程序的开始将所有子程序将用的寄存器保存在栈中（不论子程序是否修改寄存器或返回后主程序是否使用寄存器，都应当这样做），以便从子程序返回前再恢复（**注意入栈顺序与出栈顺序相反**）
```
assume cs:code
data segment
db "welcome to masm!", 0
data ends

stack segment
dw 16 dup (0)
stack ends

code segment
start:
mov dh, 8
mov dl, 3
mov cl, 2
mov ax, data
mov ds, ax
mov ax, stack
mov sp, 20H
mov si, 0
call show_str

mov ax, 4C00H
int 21H

show_str:
push ax ; 保存子程序中所有将用到的寄存器的初始值，以便在返回前恢复
push bx
push cx
push dx
push es
push si

mov ax, 0B800H; 80×25彩色模式显示缓冲区
mov es, ax

mov al, 160 ; 设置指定打印位置
inc dh ; 行数从0开始
mul dh ; 8位乘法，结果存储在ax中
mov bx, ax
mov al, 2
mul dl
add bx, ax
mov ah, cl

print:
mov cl, [si] ; 设置cx
mov ch, 0
jcxz ok ;判断字符串是否结束

mov al, cl ; 设置字符属性和值
mov es:[bx],ax
inc si
add bx, 2
jmp print

ok:
pop si
pop es
pop dx
pop cx
pop bx
pop ax
ret 

code ends
end start
```

2. 运行结果

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1674959885930-a6c4181a-e6a1-44cb-9ec8-cc5013b1314e.png#averageHue=%23141414&clientId=ue48ee0fc-f4a6-4&from=paste&height=427&id=u8c981b1c&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=false&size=12224&status=done&style=none&taskId=u3854a69e-62d2-4b34-89c5-98dd0c0fb70&title=&width=642)
<a name="gCr3l"></a>
## assignment 2

1. 编写源程序，利用除法溢出公式 

                   $X/n = int(H/2)*65536 +[rem(H/n)*65536+L]/n$<br />该公式的基本思想是将可能发生除法溢出的32位除法$X/n$，分解为两个十六位(实际运算时是32位，被除数高16位置0)的除法<br />$(H/n)*65536 + (L/n)$<br />**商（32位）：**<br />高十六位为$int(H/2)*65536$,低十六为$int([rem(H/n)*65536+L]/n)$<br />**余数（16位）：**<br />$rem([rem(H/n)*65536+L]/n)$<br />（注：对这个公式的理解有限）
```
assume cs:code

stack segment
dw 16 dup (0)
stack ends

code segment
start:
mov ax, stack
mov ss, ax
mov sp, 20H
mov ax, 4240H
mov dx, 000FH
mov cx, 0AH
call divdw

mov ax, 4C00H
int 21H

divdw:
push bx

mov bx, ax ; 暂存L
mov ax, dx ; H/N
mov dx, 0
div cx ; int(H/N)在ax中，rem(H/N)在dx中

push ax ; 暂存int(H/N)，除数

mov ax, bx; dx and ax constitute rem(H/N)*65535+L
div cx ; ax store the result
mov cx, dx

pop dx ; int(H/N)

pop bx
ret



code ends
end start
```

2. 运行结果正确

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675050216892-a6c856a5-19e3-42a9-9dae-62052e8d077c.png#averageHue=%23191919&clientId=u68f84982-1dce-4&from=paste&height=427&id=u69ef2d14&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=false&size=16724&status=done&style=none&taskId=u6de69850-12af-46ff-80ef-d1f8f4817f4&title=&width=642)
<a name="wHNVn"></a>
## assignment 3

1. 编写源程序：由于是从数字尾部开始构造字符串，所以用栈来暂存数据再合适不过
```
assume cs:code

data segment
db 10 dup(0)
data ends

stack segment
dw 16 dup(0)
stack ends

code segment
start:
mov ax, 12666
mov bx, data
mov ds, bx
mov si, 0
mov bx, stack
mov ss, bx
mov sp, 20H
call dtoc

mov dh, 8
mov dl, 3
mov cl, 2
call show_str

mov ax, 4C00H
int 21H

dtoc:
push ax
push bx
push cx
push dx
push si
push di

mov dx, 0 ; 被除数高16位 置0
mov bx, 10
mov di, 0 ; 字符计数

divide:
mov cx, ax 
jcxz over
inc di
div bx ; 32位除法，商在ax，余数在dx
add dx, 30H
push dx
mov dx, 0
jmp divide

over:
mov cx, di
move: 
pop bx
mov [si], bl
inc si
loop move

pop di
pop si
pop dx
pop cx
pop bx
pop ax
ret

show_str:
push ax ; 保存子程序中所有将用到的寄存器的初始值，以便在返回前恢复
push bx
push cx
push dx
push es
push si

mov ax, 0B800H; 80×25彩色模式显示缓冲区
mov es, ax

mov al, 160 ; 设置指定打印位置
inc dh ; 行数从0开始
mul dh ; 8位乘法，结果存储在ax中
mov bx, ax
mov dh, 0
mov al, 2
mul dl
add bx, ax
mov ah, cl

print:
mov cl, [si] ; 设置cx
mov ch, 0
jcxz ok ;判断字符串是否结束

mov al, cl ; 设置字符属性和值
mov es:[bx],ax
inc si
add bx, 2
jmp print

ok:
pop si
pop es
pop dx
pop cx
pop bx
pop ax
ret 

code ends
end start
```

2. 运行结果

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675070403817-35e5aa0f-3d0c-42ab-803a-9d7dbf5bcb8a.png#averageHue=%231f1f1e&clientId=u9270fba6-a6a8-4&from=paste&height=427&id=uc1ace679&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=true&size=16905&status=done&style=none&taskId=uf4805ca7-fbac-43eb-a257-f1c820ade31&title=%E6%AD%A3%E7%A1%AE%E5%86%99%E5%85%A5%E6%95%B0%E6%8D%AE%E6%AE%B5&width=642 "正确写入数据段")<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675070685747-6e72ffff-b062-418d-9d09-67596698a4ca.png#averageHue=%23141313&clientId=u9270fba6-a6a8-4&from=paste&height=427&id=ub539738e&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=true&size=12534&status=done&style=none&taskId=u448c5569-17ad-4eec-8879-9d56a9e0d67&title=%E6%AD%A3%E7%A1%AE%E6%89%93%E5%8D%B0&width=642 "正确打印")
<a name="ww3wC"></a>
# 实验11 编写子程序

1. 编写源程序：主要用到了`cmp`指令和条件转移指令组合形成的if逻辑
```
assume cs:codesg
datasg segment
db "Beginner's All-purpose Symbolic Instruction Code.",0
datasg ends

codesg segment
begin:
mov ax, datasg
mov ds, ax
mov si, 0
call letterc

mov ax, 4C00H
int 21H

letterc:
push ax
push cx

Capital:
mov al, [si]
mov cl, al
mov ch, 0
jcxz OK
cmp al, 97
jb NO
cmp al, 122
ja NO
and al, 11011111B
mov [si], al	

NO:
inc si
jmp short Capital

OK:
pop cx
pop ax
ret

codesg ends
end begin
```

2. 运行结果

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675142887049-1e6b7958-8779-4745-81f5-c6a536a232ca.png#averageHue=%231d1d1d&clientId=u14a9d0ea-1971-4&from=paste&height=427&id=u9451414e&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=true&size=18343&status=done&style=none&taskId=u733f3e2b-82d2-436e-a8de-95b8faa1f07&title=%E5%88%9D%E5%A7%8B%E7%8A%B6%E6%80%81&width=642 "初始状态")<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675142878774-286c5ae3-e961-424a-96db-dae987c9a153.png#averageHue=%23212121&clientId=u14a9d0ea-1971-4&from=paste&height=427&id=ub5c49ec4&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=true&size=19861&status=done&style=none&taskId=u7a2a2568-c507-4078-a32b-b75eef2ec62&title=%E5%85%A8%E9%83%A8%E5%A4%A7%E5%86%99&width=642 "全部大写")
<a name="bk4z5"></a>
# 实验12 编写0号中断的处理程序

1. 编写源程序

总体来说就3个任务：

- 编写中断处理程序 
- 复制中断处理程序至内存空闲区域($0000:0200H\to0000:02FFH$)  
- 修改中断向量表（中断处理程序地址入口表）

注意在用`jcxz`条件转移指令时，要`jmp short`回程序开头
```
assume cs:code

code segment
start:
mov ax, cs
mov ds, ax
mov si, offset do0 ; 076C:0028
mov ax, 0
mov es, ax
mov di, 0200H

mov cx, offset do0end- offset do0; 0034H
cld
rep movsb ; 复制程序到0:200

mov word ptr es:[0], 0200H
mov word ptr es:[0+2], 0 ; 修改中断向量表

mov ax, 4C00H
int 21H

do0:
jmp short do0start
db "divide error",0 

do0start:
mov ax, 0B800H
mov es, ax
mov di, 160*12+34*2

mov ax, cs
mov ds, ax
mov si, 202H

print:
mov cL, [si]
mov ch, 0
jcxz ok
mov ah, 04h ;red
mov al, cl
mov es:[di], ax
inc si
add di, 2 
jmp short print

ok:
mov ax, 4C00H
int 21H

do0end: ;005C
nop

code ends
end start
```

2. 运行结果(在debug中运行检测程序lab12T无法触发中断，直接执行却可以)

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675159533550-89caf027-f6da-4345-aa8c-e03159df600e.png#averageHue=%23141414&clientId=u2ec176e2-9874-4&from=paste&height=427&id=u6679d84b&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=false&size=12440&status=done&style=none&taskId=u7d87f433-7092-4f23-a3d6-b1339bf6fe9&title=&width=642)
<a name="YSdgF"></a>
# 实验13 编写、应用中断例程
<a name="HHw6N"></a>
## assignment 1

1. 编写源程序：与lab10-1的show_str基本一致，只需将`call-ret`更改为 `int 7cH - iret`
```
assume cs:code

code segment
start:
mov ax, cs
mov ds, ax
mov si, offset print
mov ax, 0
mov es, ax
mov di, 0200H

mov cx, offset printed - offset print
cld
rep  movsb

mov word ptr es:[7cH*4], 0200H
mov word ptr es:[7cH*4+2], 0 

mov ax, 4C00H
int 21H

print:
push bx
push cx
push es
push si
push ax
push dx

mov ax, 0B800H
mov es, ax

mov al, 160
inc dh
mul dh ; 160*(10+1) in ax
mov bx, ax
mov al, 2
mul dl ; 10*2 in ax
add bx, ax
mov ah, cl

stPrint:
mov ch, 0
mov cl, [si]
jcxz ok

mov al, cl
mov es:[bx], ax
add bx, 2
inc si
jmp short stPrint

ok:
pop dx
pop ax
pop si
pop es
pop cx
pop bx
iret

printed:
nop

code ends
end start
```

2. 运行结果

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675224733068-a783d5cd-5d35-46b5-8032-3c8938e8347a.png#averageHue=%23131313&clientId=u8a54de4a-c425-4&from=paste&height=427&id=u9672685d&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=false&size=12092&status=done&style=none&taskId=u4599fb35-92fc-4ea1-b9cb-e60668d8629&title=&width=642)
<a name="LKaNX"></a>
## assignment 2

1. 编写源程序

用中断例程实现loop指令，主要需要解决三个问题

- 怎么取得标号$S$的段地址和偏移地址？

有一对段地址$CS$和偏移地址$IP$在中断过程时被压入栈，标号的段地址就是该CS，标号	       的偏移地址可由该IP加上转移地址(`offset s - offset se`)得到

- 得到$S$的段地址和偏移地址后，如何设置$CS:IP$

用`iret`指令：`pop IP , pop CS ,  popf`
```
assume cs:code

code segment
start:
mov ax, cs
mov ds, ax
mov si, offset lp
mov ax, 0
mov es, ax
mov di, 0200H

mov cx, offset lped - offset lp
cld
rep  movsb

mov word ptr es:[7cH*4], 0200H
mov word ptr es:[7cH*4+2], 0 

mov ax, 4C00H
int 21H

lp:
dec cx
jcxz lpret
push bp
mov bp, sp
add [bp+2], bx
lpret:
pop bp
iret

lped:
nop

code ends
end start
```

2. 运行结果

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675237825483-f1ed3d6d-00cc-453b-91b3-757823355468.png#averageHue=%23171515&clientId=ub529a018-e1a0-4&from=paste&height=427&id=u272d8fd4&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=false&size=12787&status=done&style=none&taskId=u38f1e876-6c89-499b-b704-a23609bf566&title=&width=642)
<a name="TCCAl"></a>
## assignment 3
```
assume cs:code
code segment
s1: db 'Good,better,best,','$'
s2: db 'Never let it rest,','$' 
s3: db 'Till good is better,','$'
s4: db 'And better,best.', '$'
s: dw offset s1, offset s2, offset s3, offset s4 
row: db 2,4,6,8

start:
mov ax, cs 
mov ds, ax
mov bx, offset s
mov si, offset row
mov cx, 4
ok:
mov bh, 0 
mov dh, [si]
mov dl, 0
mov ah, 2 ; BIOS中断例程--设置光标
int 10h 

mov dx, [bx]                                           
mov ah, 9 ; DOS中断例程--打印字符串
int 21h
inc si
add bx, 2
loop ok

mov ax, 4C00H; DOS中断例程--程序返回，返回值在al
int 21H
code ends
end start
```
<a name="zGspx"></a>
# 实验14 访问 CMOS RAM

1. 编写源程序
```
assume cs:code

stack segment
dw 16 dup (0)
stack ends

code segment
start:
mov ax, stack
mov ss, ax
mov sp, 20H
mov ax, 0B800H
mov ds, ax

mov al, 9
mov bx, 160*12+36*2
call GetAscill
mov byte ptr [bx+4], '/'

mov al, 8
add bx, 6
call GetAscill
mov byte ptr [bx+4], '/'

mov al, 7
add bx, 6
call GetAscill
mov byte ptr [bx+4], ' '

mov al, 4
add bx, 6
call GetAscill
mov byte ptr [bx+4], ':'

mov al, 2
add bx, 6
call GetAscill
mov byte ptr [bx+4], ':'

mov al, 0
add bx, 6
call GetAscill

mov ax, 4C00H
int 21H

GetAscill:
push ax
push bx
push cx
push dx

out 70H, al
in al, 71H

mov ah, al
mov cl, 4
shr ah, cl
and al, 00001111B

add ah, 30H
add al, 30H

mov dx, 0B800H
mov es, dx
mov es:[bx], ah 
mov byte ptr es:[bx+1], 02H ; green
mov es:[bx+2], al
mov byte ptr es:[bx+3], 02H

pop dx
pop cx
pop bx
pop ax
ret

code ends
end start
```

2. 运行结果

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675253920788-8fc4fee5-abeb-4e49-93bf-97e3873b6599.png#averageHue=%23141413&clientId=uf0bf1a62-8c66-4&from=paste&height=388&id=u067d841f&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=false&size=11685&status=done&style=none&taskId=u21f4afac-9bb2-4466-b21a-1a578f58efb&title=&width=583.6363509863864)
<a name="yTwL0"></a>
# 实验15 安装新的int 9 中断例程
<a name="TIrMX"></a>
## 前置练习1
在屏幕中间依次显示$a\to z$,按Esc键后改变与颜色

1. 编写源程序：由于重新编写的int 9 例程与用于显示的程序在同时运行，所以不需要有安装程序。在编写int 9中断例程时，错把`call dword ptr ds:[0]`写成了`call word ptr ds:[0]`，导致整个系统没有正确的int 9中断例程，因此出现了错误。
```
assume cs:code

stack segment
db 64 dup(0)
stack ends

data segment
dw 0,0
data ends

code segment
start:
mov ax, stack
mov ss, ax
mov sp, 40H
mov ax, data
mov ds, ax

mov ax, 0
mov es, ax

push es:[9*4]
pop ds:[0]
push es:[9*4+2]
pop ds:[2] ; 保存原int 9中断例程的入口地址

cli
mov word ptr es:[9*4], offset int9
mov es:[9*4+2], cs;设置新的入口地址
sti


mov ax, 0B800H
mov es,ax
mov dh, 'a'
s:
mov es:[160*12+40*2], dh
call delay
inc dh
cmp dh, 'z'
jna s ; 依次打印a~z


mov ax, 0 
mov es, ax

cli
push ds:[0]
pop es:[9*4]
push ds:[2]
pop es:[9*4+2] ;恢复原int 9中断例程的入口地址
sti


mov ax, 4C00h
int 21H

delay:
push ax
push dx
mov ax, 0
mov dx, 10H
se:
sub ax, 1 ; 不能用dec
sbb dx, 0
cmp ax, 0
jne se
cmp dx, 0
jne se

pop dx
pop ax
ret ; 延时

int9:
push ax
push es
in al, 60H

pushf
call dword ptr ds:[0]

cmp al, 01H
jne int9ret
mov ax, 0B800H
mov es, ax
inc byte ptr es:[160*12+40*2+1] ; 修改字符属性

int9ret:
pop es
pop ax
iret

code ends
end start

```

2. 运行结果

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675319548168-77f7b5a6-54bb-4526-b234-adb0e561004e.png#averageHue=%237ab44c&clientId=u17647ab4-03d9-4&from=paste&height=388&id=u49a1ed0a&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=true&size=13571&status=done&style=none&taskId=u61859af5-760b-45d0-8b8d-c62aa3a3245&title=%E6%8C%89Esc%E6%94%B9%E5%8F%98%E9%A2%9C%E8%89%B21&width=583.6363509863864 "按Esc改变颜色1")<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675319563355-013b242f-ab37-4a8f-a956-6222d6e1847c.png#averageHue=%238dd756&clientId=u17647ab4-03d9-4&from=paste&height=388&id=u9a049927&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=true&size=13830&status=done&style=none&taskId=u52c59e7d-a185-4177-8537-a05965e054e&title=%E6%8C%89Esc%E6%94%B9%E5%8F%98%E9%A2%9C%E8%89%B22&width=583.6363509863864 "按Esc改变颜色2")
<a name="vlBjq"></a>
## 前置练习2
在DOS下，按F1键后改变当前屏幕的显示颜色，其他的键照常处理

1. 编写源程序：原int 9的中断例程入口地址不能放在安装程序中，否则在进入新int 9中断例程后将丢失原int 9中断例程入口地址，导致无法调用原int 9中断例程。将原int 9中断例程入口地址放在$0:0200 \to 0:0203$,可在新int 9中断例程中通过`cs:[200H]`访问
```
assume cs:code, ss:stack

stack segment
db 32 dup(0)
stack ends

code segment
start:
mov ax, stack
mov ss, ax
mov sp, 20H

mov ax, 0
mov es, ax
mov di, 0204H
mov ax, cs
mov ds, ax
mov si, offset int9

mov cx, offset int9ed - offset int9
cld
rep movsb; 安装

push es:[9*4]
pop es:[200H]
push es:[9*4+2]
pop es:[202H] ; 保存原int 9入口地址

cli
mov word ptr es:[9*4], 204H
mov word ptr es:[9*4+2], 0 ; 修改中断向量表
sti

mov ax, 4C00H
int 21H

int9:
push ax
push cx
push es
push di

in al, 60H

pushf
call dword ptr cs:[200H] ; 调用原int 9

cmp al, 3BH
jne int9ret

mov ax, 0B800H
mov es, ax
mov di, 1
mov cx, 2000
s:
inc byte ptr es:[di]
add di, 2
loop s

int9ret:
pop di
pop es
pop cx
pop ax
iret


int9ed:
nop

code ends
end start
```

2. 运行结果

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675322759364-2785ad21-17c7-4499-b1a3-fe6726975b02.png#averageHue=%230d0d0d&clientId=ud2f6d655-0b50-4&from=paste&height=388&id=u4340ef70&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=true&size=12813&status=done&style=none&taskId=uc1c9e4ff-ae09-465d-a787-aba159b8b98&title=%E6%8C%89%E4%B8%8BF1%201&width=583.6363509863864 "按下F1 1")<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675322817620-9b94c323-5bcb-4465-ba63-7a2721ba4d46.png#averageHue=%23aeaeae&clientId=ud2f6d655-0b50-4&from=paste&height=388&id=u019e66f9&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=true&size=8862&status=done&style=none&taskId=ue0c4ae51-d75f-4e13-8d7c-a26ee51e20f&title=%E6%8C%89%E4%B8%8BF1%202&width=583.6363509863864 "按下F1 2")
<a name="XyIu0"></a>
## assignment 1

1. 编写源程序

与前两个练习相差不大，判断字符条件不同而已：判断是否是字符A的断码`cmp aL, 1EH+80H`
```
assume cs:code, ss:stack

stack segment
db 32 dup(0)
stack ends

code segment
start:
mov ax, stack
mov ss, ax
mov sp, 20H

mov ax, 0
mov es, ax
mov di, 0204H
mov ax, cs
mov ds, ax
mov si, offset int9

mov cx, offset int9ed - offset int9
cld
rep movsb; 安装

push es:[9*4]
pop es:[200H]
push es:[9*4+2]
pop es:[202H] ; 保存原int 9入口地址

cli
mov word ptr es:[9*4], 204H
mov word ptr es:[9*4+2], 0 ; 修改中断向量表
sti

mov ax, 4C00H
int 21H

int9:
push ax
push cx
push es
push di

in aL,60h

pushf
call dword ptr cs:[200H]

cmp aL, 1EH+80H
jne int9ret

mov cx, 2000
mov ax, 0B800H
mov es, ax
mov di, 0
s:
mov byte ptr es:[di], 'A'
mov byte ptr es:[di+1], 02H
add di, 2
loop s

int9ret:
pop di
pop es
pop cx
pop ax
iret

int9ed:
nop

code ends
end start

```

2. 运行结果

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675329053483-60588212-d9b5-4cef-acf7-06c70f65db5f.png#averageHue=%23141313&clientId=ud2f6d655-0b50-4&from=paste&height=388&id=u7a90e8bd&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=true&size=7755&status=done&style=none&taskId=u3c74959a-2b05-4756-8089-500ac2f8893&title=%E6%8C%89%E4%B8%8BA%E5%90%8E%E6%9D%BE%E5%BC%80&width=583.6363509863864 "按下A后松开")
<a name="YodIM"></a>
# 实验16 编写包含多个功能子程序的中断例程

1. 编写源程序

注意中断例程安装后，直接定址表table的偏移地址发生了变化，没有了前面安装程序带来的一截偏移，同时偏移地址增加200H
```
assume cs:code
code segment
start:
mov ax, cs
mov ds, ax
mov si, offset int7ch
mov ax, 0
mov es, ax
mov di, 0200H

mov cx, offset int7ched - offset int7ch
cld
rep  movsb

mov word ptr es:[7cH*4], 0200H
mov word ptr es:[7cH*4+2], 0 

mov ax, 4C00H
int 21H

int7ch:
jmp short int7chStart
table dw offset Sub1-offset int7ch+200H, offset Sub2-offset int7ch+200H, offset Sub3-offset int7ch+200H, offset Sub4-offset int7ch+200H

int7chStart:
push ax
push bx
cmp ah, 3
ja int7chRet
mov bl, ah
mov bh, 0
add bx, bx
call word ptr cs:(table-int7ch+200H)[bx]

int7chRet:
pop bx
pop ax
iret

Sub1:
push ax
push bx
push cx
push ds
mov ax, 0B800H
mov ds, ax
mov cx, 2000
mov bx, 0
s1:
mov byte ptr [bx], ' '
add bx, 2
loop s1
pop ds
pop cx
pop bx
pop ax
ret

Sub2:
push ax
push bx
push cx
push ds
mov bx, 0B800H
mov ds, bx
mov cx, 2000
mov bx, 1
s2:
and byte ptr [bx], 11111000B ; 只设置最后3位
or byte ptr [bx], al
add bx, 2
loop s2
pop ds
pop cx
pop bx
pop ax
ret

Sub3:
push ax
push bx
push cx
push ds
mov bx, 0B800H
mov ds, bx
mov cl, 4
shl al, cl
mov cx, 2000
mov bx, 1
s3:
and byte ptr [bx], 10001111B
or [bx], al
add bx, 2
loop s3
pop ds
pop cx
pop bx
pop ax
ret

Sub4:
push ax
push bx
push cx
push ds
push es
push si
push di
mov bx, 08B00H
mov es, bx
mov ds, bx
mov si, 160
mov di, 0
cld
mov cx, 24

s4:
push cx
mov cx, 160
rep movsb
pop cx
loop s4

mov cx, 80
mov si, 0
s41:
mov byte ptr [160*24+si], ' '
add si ,2
loop s41
pop di
pop si
pop es
pop ds
pop cx
pop bx
pop ax
ret

int7ched:
nop

code ends
end start
```
```
assume cs:code

code segment
start:
mov ah,1 ; 0 2 3
mov al,2
int 7CH

mov ax, 4C00H
int 21H
code ends
end start
```

2. 运行结果

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675411618416-c6c100a2-f4d1-4bc9-b3e6-22f83fcdcaee.png#averageHue=%230d0d0d&clientId=uaa2840e8-10be-4&from=paste&height=427&id=u97049213&name=image.png&originHeight=427&originWidth=620&originalType=binary&ratio=1&rotation=0&showTitle=true&size=5698&status=done&style=none&taskId=udfd4d7d0-2546-4521-8884-82d74fe5421&title=%E5%8A%9F%E8%83%BD1%EF%BC%9A%E6%B8%85%E5%B1%8F&width=620 "功能1：清屏")<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675411466691-92faf4b3-fbd7-4859-b68b-e403f87d23e1.png#averageHue=%230e0e0d&clientId=uaa2840e8-10be-4&from=paste&height=427&id=u0af61a75&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=true&size=11776&status=done&style=none&taskId=ud7c332b2-9214-4185-917e-392d79cda17&title=%E5%8A%9F%E8%83%BD2%EF%BC%9A%E8%AE%BE%E7%BD%AE%E5%89%8D%E6%99%AF%E8%89%B2&width=642 "功能2：设置前景色")<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675411696534-79bed444-6b2a-4a77-ad72-027fb2081a4b.png#averageHue=%2300a900&clientId=uaa2840e8-10be-4&from=paste&height=427&id=ue6689a35&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=true&size=11354&status=done&style=none&taskId=u07994587-f0a4-4e4c-b31e-52a54f59cd3&title=%E5%8A%9F%E8%83%BD3%EF%BC%9A%E8%AE%BE%E7%BD%AE%E8%83%8C%E6%99%AF%E8%89%B2&width=642 "功能3：设置背景色")
<a name="IRx7s"></a>
# 实验17 编写包含多个功能子程序的中断例程
第17章实验用BIOS提供的功能号分别为2, 3的中断例程int 13H实现对软盘扇区的读写，由于该实验大多是对mul，div的用法和中断例程安装程序的复习，且无法看见实验效果，所以就没做了
<a name="upigZ"></a>
## 练习17-1
接受用户的键盘输入，输入"r"，"g",“b”分别将屏幕上的字符设置为红色，绿色，蓝色

1. 编写源程序

用功能号为0的int 16H中断例程读取键盘输入即可
```
assume cs:code

code segment
start:

show:
push ax
push es
push di

mov ah, 0
int 16H

mov bl, 1
cmp al,'b'
je showst
shl bl, 1
cmp al, 'g'
je showst
shl bl, 1
cmp al, 'r'
je showst
jmp short FRet

showst:
mov ax, 0B800H
mov es, ax
mov di, 1
mov cx, 2000
s:
and byte ptr es:[di], 11111000B
or es:[di], bl
add di, 2
loop s

FRet:
mov ax, 4C00H
int 21H

code ends
end start
```

2. 运行结果

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675431818731-db0edf92-bc54-4bfc-a35f-613c796dddda.png#averageHue=%230f0d0d&clientId=uaa2840e8-10be-4&from=paste&height=427&id=u2f889938&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=true&size=8416&status=done&style=none&taskId=u3c7affc7-f57c-470f-9cab-1a94bcb3c74&title=r-red&width=642 "r-red")<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675431840911-15621108-ffb6-42ce-94ab-603c36fe9540.png#averageHue=%230d0d0d&clientId=uaa2840e8-10be-4&from=paste&height=427&id=u1bb9ce94&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=true&size=8174&status=done&style=none&taskId=u26c95d33-ee9d-414a-9861-7aa91427bc6&title=g-green&width=642 "g-green")<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675431855013-727c9bbb-b9bf-43a5-9ca6-ea80957dfa92.png#averageHue=%230d0d0d&clientId=uaa2840e8-10be-4&from=paste&height=427&id=ucb1b0f24&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=true&size=8133&status=done&style=none&taskId=ub45cc602-bef7-4fba-9ec7-3d4b52f4485&title=b-blue&width=642 "b-blue")
<a name="Wyllk"></a>
# Other
<a name="QMCD1"></a>
## 1. 理解assume伪指令的作用
```
assume cs:code, ds:data
data segment
a db 1,2,3,4,5,6,7,8
b dw 0
data ends

code segment
start:
mov ax, data
mov ds, ax

mov si, 0
mov cx, 8

s:
mov ah, 0
mov al, a[si]
add b, ax
inc si
loop s

mov ax, 4C00H
int 21H

code ends
end start
```

1. `assume ds:data ss:stack`
- assume是伪指令，不会被编译为机器指令，因此实际程序运行后，段寄存器$DS、SS$中不会存放data和stack的地址，要更改段寄存器的内容需要在程序中用指令实现:`mov ax, data ``mov ds, ax`
- assume是伪指令，用于指示编译器将$DS、SS$分别与data段和stack段关联。①关联是什么意思呢？就是**在编译时默认data段中的数据标号a、b的段地址在**$DS$**中**，因此如果要正确访问到a、b的内容，必须用指令将data填入$DS$中。②数据标号自身就有段地址和偏移地址为什么还需要一个默认的段寄存器呢？这说明在程序段中的数据标号，仅含有偏移地址信息，它的段地址信息需要从默认段寄存器中取得。③此外，定义段的段标号data也不指代完整的地址，而仅仅代表段地址，因此`mov ax, data`在编译器看来是`mov ax, data段段地址`，如果data是指代一个32bits的完整地址，那么它将不能赋值给16bits的ax

如果在程序中省略`assume ds:data`，则会出现_不能用段寄存器寻址_的错误<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675343108877-68cf68d3-97ef-4ecb-8b4f-6da330149c94.png#averageHue=%23161616&clientId=u3f46bb08-d532-4&from=paste&height=388&id=uffd0ec43&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=false&size=13264&status=done&style=none&taskId=ud9fb02f3-e117-4559-bfe1-1659d6727ee&title=&width=583.6363509863864)

2. `assume cs:codesg`

将$CS$与代码段关联，在程序加载时将代码段(codesg)的段地址放入$CS$中. 如果去掉该语句，则程序编译不通过，因为$CS$的值不确定<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675341791119-4c9029f0-b9e3-4e2f-b1b9-aa5d02685f8f.png#averageHue=%230d0d0d&clientId=u3f46bb08-d532-4&from=paste&height=276&id=u952199f2&name=image.png&originHeight=304&originWidth=640&originalType=binary&ratio=1&rotation=0&showTitle=false&size=9905&status=done&style=none&taskId=ud6cc6c48-9ce9-4df5-a654-02e53729a4d&title=&width=581.8181692076126)
<a name="wwfwW"></a>
## 2. 理解数据标号

1. 数据标号与地址标号的不同

地址标号仅指代了一个地址，而数据标号不仅指代一个地址，还指代了这个地址的数据单元长度(byte, word, double word)，进而我们可以说数据标号就代表一个内存单元（由地址和单元长度就足以确定一个单元）
```
assume cs:code, es:data
data segment
a db 1,2,3,4,5,6,7,8
b dw 0
data ends

code segment
start:
mov ax, data
mov es, ax

mov si, 0
mov cx, 8

s:
mov ah, 0
mov al, a[si]
add b, ax
inc si
loop s

mov ax, 4C00H
int 21H

code ends
end start
```
这里的a和b分别指代了

- **地址为**`**seg data:0**`**, 长度为byte的字节单元**
- **地址为**`**seg data:8**`**, 长度为word的字单元**
2. 如何用数据标号以简洁形式访问内存中的数据

在上一个程序中，我们用`mov al, a[si]` `add b, ax`访问了data段的内容，在编译器看来，这两条语句是这样的: `mov al, es:0[si]``add es:[8], ax`<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675409971871-70ff728a-fa74-48ac-a742-be8ec319d677.png#averageHue=%23191919&clientId=uaa2840e8-10be-4&from=paste&height=427&id=u6e4d3ff6&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=false&size=14859&status=done&style=none&taskId=ua1726f99-29ec-46f7-ac48-ad448e15a63&title=&width=642)<br />我们现在用更熟悉的`mov al, [si+a]` `add b[0], ax`形式，从编译器角度来看，这两种形式没有区别<br />这说明了在指令中**a等价于**`**byte ptr [0]**`**，b等价于**`**word ptr [8]**`（仅含偏移地址信息，默认段地址在es中，因为`assume es:data`）<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675410379440-d032239f-bb7d-480f-a45d-f96f7d064cd3.png#averageHue=%231a1919&clientId=uaa2840e8-10be-4&from=paste&height=427&id=ubbac8493&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=false&size=15290&status=done&style=none&taskId=uce443a00-0b21-4ac2-89ac-bb7e70f3432&title=&width=642)

3. 将标号当作数据定义
```
assume cs:code, ds:data
data segment
a db 1,2,3,4,5,6,7,8
b dw 0
c dw a, b
data ends

code segment
start:
mov ax, data
mov ds, ax

mov dx, 2
mov dx, c
mov ax, c[1]

mov ax, 4C00H
int 21H

code ends
end start
```
`c dw a, b`将数据标号当作数据定义，c指代地址为`seg data:000A`的字单元，**该字单元的内容是a的偏移地址**$0000$，下面是验证<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675409382345-20e1a2f2-8973-4150-992a-2a8acb141fa9.png#averageHue=%23191919&clientId=uaa2840e8-10be-4&from=paste&height=427&id=ud990b41d&name=image.png&originHeight=427&originWidth=642&originalType=binary&ratio=1&rotation=0&showTitle=false&size=15496&status=done&style=none&taskId=u9d64f540-f9d7-4f4d-a179-67094b0601b&title=&width=642)<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1675409496753-347acc0d-300d-4502-b228-e202ee4504a4.png#averageHue=%23101010&clientId=uaa2840e8-10be-4&from=paste&height=400&id=u97a8ca97&name=image.png&originHeight=400&originWidth=640&originalType=binary&ratio=1&rotation=0&showTitle=false&size=12100&status=done&style=none&taskId=u65363c06-9a66-4677-9782-717ab71b1b6&title=&width=640)

