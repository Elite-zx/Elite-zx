---
title: "汇编语言【王爽】实验流程"
date: 2023-02-04
categories: 
- CSAPP
- assembly language
tag: 
- Foundation
---
# 前言：
前前后后看完这本书，做完所有实验和检测点，用了接近一个月的时间，除了最后几天比较认真，其余时间是比较懒散的，这本书其实最多半个月就能解决掉。接下来会步入CSAPP第三章的学习，争取早日把有名的bomb lab完成了

---

# 实验1 查看CPU和内存，用机器指令和汇编指令编程
## debug环境搭建：[参考此文](https://blog.csdn.net/YuzuruHanyu/article/details/80287419?spm=1001.2014.3001.5506)
## assignment 1

1. 用A命令向内存中写入汇编指令，用U命令查看

![](attachment/be45e9be004d61829c5b03272132030c.png)

2. 用R命令分别修改CS、IP寄存器，即CS:IP的指向，用T命令逐条执行

![](attachment/26795f5d2a90e3b1abc6b1fdc9d39408.png)
## assignment 2

1. 写入并查看指令

![](attachment/3433e861e5085ced9ca3c7be18ad26e6.png)

2. 修改_CS:IP_指向

![](attachment/be45e9be004d61829c5b03272132030c.png)

3. 执行指令，计算$2^8$，结果为 $AX = 0100H$

![](attachment/26795f5d2a90e3b1abc6b1fdc9d39408.png)
## assignment 3

1. 用D命令查找，最终在$FFFF5H \to FFFFCH（FFFF:0005 \to FFFF:000C）$发现$dd/mm/yy$字样的生产日期

![](attachment/26795f5d2a90e3b1abc6b1fdc9d39408.png)

2. 尝试用E命令修改，该操作失效，因为这是ROM

![](attachment/5fd1fddb244160f8985c8162d69751f1.png)
## assignment 4
1.$A0000H \to BFFFFH$对8086 PC机是显存地址，往这个范围内的内存写入数据，会改变显示器上的内容，我们可以看见屏幕上出现了笑脸、爱心和钻石
![](attachment/3433e861e5085ced9ca3c7be18ad26e6.png)
![](attachment/f1c8bb9ffed9738a412d85eba74d5094.png)

---

# 实验2 用机器指令和汇编指令编程
## assignment 1

1. 用A指令向内存中写入汇编指令，用U指令查看

![](attachment/69e55d7cd42de97dab21bb828f85738e.png)

2. 修改CS:IP使其指向代码段

![](attachment/9f2dfda5f53b12dff0c5b678c0230fe1.png)、

3. t命令逐步执行指令后查看AX、BX、SP寄存器内容

![](attachment/07b1a26be34a52d64824abce91c15e76.png)
## assignment 2
在使用T命令进行单步追踪的时候，产生了中断，为了保护现场，CPU将PSW、CS和IP依此入栈，导致了内存相关位置内容的改变（保留疑问）

---

# 实验3 编程、编译、链接、跟踪
## assignment 1

1. 编译链接生成可执行文件

![](attachment/9a986e22ba33aa2f07fb537819658b5d.png)
## assignment 2

1. debug将程序载入内存，设置CS:IP：程序所在内存段的段地址为$DS=075C$，则PSP的地址为$075C:0$，程序的地址为$076C:0\;(075C+10:0)$,$CS:IP = 076C:0000$

![](attachment/9f2dfda5f53b12dff0c5b678c0230fe1.png)

2. 跟踪程序执行过程

![](attachment/4558f12f037760ce42478fc1c563f99a.png)
用P命令执行`INT 21`
![](attachment/55386b9183e912238f4ef08482495438.png)
## assignment 3

1. 查看PSP的内容

![](attachment/07b1a26be34a52d64824abce91c15e76.png)

---

# 实验4 [bx]和loop的使用
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

![](attachment/9a986e22ba33aa2f07fb537819658b5d.png)

3. 查看载入内存的程序，可以看见标签s已被替换为地址$076C:000E$

![](attachment/f1c8bb9ffed9738a412d85eba74d5094.png)

4. 执行程序，验证结果，正确

![](attachment/69e55d7cd42de97dab21bb828f85738e.png)
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

![](attachment/f1c8bb9ffed9738a412d85eba74d5094.png)
## assignment 3

1. 复制的是什么：复制程序的第一条指令`mov ax,cs`到 `loop s` 指令至内存地址$0020:0000$处
2. 如何知道程序的字节数：首先可以确定第一个空应该填入CS，这是程序的段地址，其次在`mov cx,_____` 上先随意填一个1，用debug跟踪程序，用U命令查看程序所占地址范围：$076C:0000 \to 076C:0015$，共$16H\,(23D)$个字节,因此第二个空应该填入$16H$

![](attachment/a1984fc0ae5d3f224966bb4c15b2e0ea.png)

---

# 实验5 编写、调试具有多个段的程序
## assignment 1

1. 将程序载入内存后查看，可知data段段地址为$076C$, stack段段地址为$076D$，code段段地址为$076E$

![](attachment/d589f866c98c4ea05c31a837ae10ba82.png)

2. Q1：`G 001D`执行程序至程序返回前，用U命令查看data段内容: $0123H,0456H,0789H,0ABCH,0DEFH,0FEDH,0CBAH,0987H$，与初状态(源程序)一致，该程序按顺序做了入栈和出栈操作，因此数据不变

![](attachment/f1c8bb9ffed9738a412d85eba74d5094.png)

3. Q2：R命令查看各个段寄存器的值  $\to \;CS:076E$、 $DS:076C$、$SS:076D$

![](attachment/4558f12f037760ce42478fc1c563f99a.png)

4. Q3：data段和stack段分别占16个字节，因此设code段段地址为$X$，那么stack段段地址为$X-1H$，data段段地址为$X-2H$（做了assignment2后可以发现这里说法并不准确）
## assignment 2

1. 步骤与assigment1 完全一致

![](attachment/2a60b33897c958a72dcac6c90c6195cf.png)
![](attachment/74a158dbaf8f30c5bda7baeaf9e299e7.png)
![](attachment/e32c2fe4dd55436bc2d3d5814bd82eec.png)
![](attachment/b61143a70bf02c04d76e0e636905efe6.png)

2. 得出结论：段无论大小，在源程序载入内存后，段所占内存大小一定为16的整数倍
## assignment 3

1. 步骤与assignment1完全一致

![](attachment/701e394e364ff05db810936e4b0030e4.png)，后面跟着data段(076F)和stack段(0770)")
![](attachment/f6b2fa2fee1fe043742b9fcb66c5a9cb.png)
2， 设code段段地址为$X$，那么data段段地址为$X+3H$，stack段段地址为$X+4H$
## assignment 4
如果去掉通知编译器程序的入口的`end start `语句，那么唯一可正确运行的是起始段为code段的程序3
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

![](attachment/7244d292d962167035026ae6d17647cd.png)

3. 执行程序，查看c段内容，正确

![](attachment/1902be5182e1e33b83c2ed1578768ca2.png)
![](attachment/7e5d09d22bc0f75cb757fda650a9b4eb.png)
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

![](attachment/7244d292d962167035026ae6d17647cd.png)

3. 执行程序，查看b段内容，正确

![](attachment/7244d292d962167035026ae6d17647cd.png)

---

# 实验6 实践课程中的程序
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

![](attachment/07b1a26be34a52d64824abce91c15e76.png)

3. 执行程序后，查看data段内容，正确

![](attachment/7244d292d962167035026ae6d17647cd.png)
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

![](attachment/7244d292d962167035026ae6d17647cd.png)

3. 执行程序，查看data段内容，正确

![](attachment/7244d292d962167035026ae6d17647cd.png)

---

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

![](attachment/9bc6319e4399ae16eed295b023956965.png)

3. 执行程序后，查看table段的内容，正确

![](attachment/a1984fc0ae5d3f224966bb4c15b2e0ea.png)
# 实验8 分析一个奇怪的程序

1. 程序从$start$入口处开始执行，一个`nop`指令占一个字节并表示No operation，此处用了两个`nop`指令的目的是在$s$处预留两个字节的空间，程序执行`mov cs:[di], ax`之后$s$处的两个字节被试图写入`jmp short s1`，接着程序向下执行`jmp short s`使得程序跳转回$s$处开始执行。
2. `jmp short s1`到底做了什么：修改IP使其前进十个字节。因为该指令本身的作用是使IP从$s2$跳转到$s1$，即从$s2$处的jmp指令的下一指令`nop`$(076C:0022)$跳转到$s1$处的`mov ax, 0`$(076C:0018)$，因为`jmp short 标号`是依据位移进行转移的指令，而此处位移大小为$0022H-0018H =-10D(F6H)$，所以$s$处的`jmp short s`指令的机器码为`EBF6`（刚好占两个字节，因此可以被正确写入$s$处）
3. 执行$s$处的跳转指令，使得$IP = IP+(-10)$,即向前移动十位，用debug跟踪程序，可以看到向前第十个指令为`mov ax, 4c00H`$(000AH-0010H=0000H)$，程序从此处开始向下执行，最终可以正确退出

![](attachment/07b1a26be34a52d64824abce91c15e76.png)
![](attachment/7244d292d962167035026ae6d17647cd.png)
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

![](attachment/a1984fc0ae5d3f224966bb4c15b2e0ea.png)

# 实验10 编写子程序
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

![](attachment/48b3a4564299e00c537ad89e4a1aa6e0.png)
## assignment 2

1. 编写源程序，利用除法溢出公式 

                   $X/n = int(H/2)*65536 +[rem(H/n)*65536+L]/n$
该公式的基本思想是将可能发生除法溢出的32位除法$X/n$，分解为两个十六位(实际运算时是32位，被除数高16位置0)的除法
$(H/n)*65536 + (L/n)$
**商（32位）：**
高十六位为$int(H/2)*65536$,低十六为$int([rem(H/n)*65536+L]/n)$
**余数（16位）：**
$rem([rem(H/n)*65536+L]/n)$
（注：对这个公式的理解有限）
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

![](attachment/3e62cb394c3e34f04693136b17ab094f.png)
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

![](attachment/4a2d01950618f1bd82fc3ef321645928.png)
![](attachment/641df2d303642523f5b106137fff3bf6.png)
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

![](attachment/ae00e48f345b630c03e516d571016343.png)
![](attachment/fcb4683184a6c0d79d2699bc79186aa3.png)
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

![](attachment/3e62cb394c3e34f04693136b17ab094f.png)
# 实验13 编写、应用中断例程
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

![](attachment/07b1a26be34a52d64824abce91c15e76.png)
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

![](attachment/3e62cb394c3e34f04693136b17ab094f.png)
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

![](attachment/a1984fc0ae5d3f224966bb4c15b2e0ea.png)
# 实验15 安装新的int 9 中断例程
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

![](attachment/cc6fd8aa713248d3063b863655b4b1eb.png)
![](attachment/175b1d630705c9664b4ee1403d07af35.png)
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

![](attachment/877445709c8ed9e5d56a7314e57f8ea3.png)
![](attachment/030425252bf3048fb11aa73425e64b26.png)
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

![](attachment/ef86dd4e7df68488abe8bf379be285f3.png)
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

![](attachment/4c1ca28437ff3c577a43f65b910fda7a.png)
![](attachment/e142cd676fd54b10899408183ed6cb5a.png)
![](attachment/11cdf681ec8c986a3cde650b18515366.png)
# 实验17 编写包含多个功能子程序的中断例程
第17章实验用BIOS提供的功能号分别为2, 3的中断例程int 13H实现对软盘扇区的读写，由于该实验大多是对mul，div的用法和中断例程安装程序的复习，且无法看见实验效果，所以就没做了
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

![](attachment/3ac9ffcac28dbfa0df02e9ddeb39586e.png)
![](attachment/d94e14d3995f026c2ff6eae5847929ca.png)
![](attachment/1902559d0ee1576594f6400ef5ea21dc.png)
# Other
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

如果在程序中省略`assume ds:data`，则会出现_不能用段寄存器寻址_的错误
![](attachment/48b3a4564299e00c537ad89e4a1aa6e0.png)

2. `assume cs:codesg`

将$CS$与代码段关联，在程序加载时将代码段(codesg)的段地址放入$CS$中. 如果去掉该语句，则程序编译不通过，因为$CS$的值不确定
![](attachment/48b3a4564299e00c537ad89e4a1aa6e0.png)
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

在上一个程序中，我们用`mov al, a[si]` `add b, ax`访问了data段的内容，在编译器看来，这两条语句是这样的: `mov al, es:0[si]``add es:[8], ax`
![](attachment/48b3a4564299e00c537ad89e4a1aa6e0.png)
我们现在用更熟悉的`mov al, [si+a]` `add b[0], ax`形式，从编译器角度来看，这两种形式没有区别
这说明了在指令中**a等价于**`**byte ptr [0]**`**，b等价于**`**word ptr [8]**`（仅含偏移地址信息，默认段地址在es中，因为`assume es:data`）
![](attachment/48b3a4564299e00c537ad89e4a1aa6e0.png)

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
`c dw a, b`将数据标号当作数据定义，c指代地址为`seg data:000A`的字单元，**该字单元的内容是a的偏移地址**$0000$，下面是验证
![](attachment/48b3a4564299e00c537ad89e4a1aa6e0.png)
![](attachment/00b606854598c5ba4b5d5647c190adcf.png)

