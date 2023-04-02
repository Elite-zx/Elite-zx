---
title: HIT-OSLab0-1-2 
date: 2023/03/24
categories:
- OS
tags: 
- Foundation
---

<meta name="referrer" content="no-referrer"/>


<a name="LIwaN"></a>
# 实验0 实验环境搭建
<!--more-->

---

[reference1](https://hoverwinter.gitbooks.io/hit-oslab-manual/content/environment.html)<br />[reference2](https://blog.csdn.net/zy010101/article/details/108085192)<br />遇到的问题：在编译linux0.11时，出现`fatal error：asm/ioctl.h: No such file or directory`，`loctl.h`这个文件是在库`linux-lib-dev`中的，而且我已经安装了这个库，但还是有这个错误<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1679055607952-a7d970dc-d0af-4bf9-8a10-389fbf39cd71.png#averageHue=%23323130&clientId=u3a7860c6-b5b9-4&from=paste&height=253&id=ua58a300b&name=image.png&originHeight=380&originWidth=1554&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=169952&status=done&style=none&taskId=u654359bb-fcf7-4d06-85f5-9faa172d7aa&title=&width=1036)<br /> 解决方法：使用i386版本的linux-libc-dev
```bash
sudo apt-get install linux-libc-dev:i386
```
<a name="CgYpM"></a>
# 实验1 操作系统的引导

---

<a name="rsI0N"></a>
## 1. 改写bootsect.s

1. 我们只需要`bootsect.s`源码中打印字符串的部分，因为不涉及迁移`bootsect`从`0x07c00`到`0x90000`的操作，所以`bootsect.s`读入内存后还是在`0x07c00`的位置，因此要添加`mov es, #07c0`才能使`es:bp`指向正确的字符串起始位置。此外，`cx`参数的大小为字符串大小+6，这里的6是3个CR/LF (carriage return/line feed: 13 10) 

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1679306853262-7e6f4ca7-68d6-4641-83f8-e0edbf6e9a65.png#averageHue=%23f0f0f0&clientId=ub2e2e66c-6eae-4&from=paste&height=293&id=u332a1dd5&name=image.png&originHeight=293&originWidth=1264&originalType=binary&ratio=1&rotation=0&showTitle=false&size=104104&status=done&style=none&taskId=u27f27fa8-2816-477c-8a4b-416f08ee4ee&title=&width=1264)<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1679120889905-e4fdb498-a155-4fbc-9485-851c42da41cc.png#averageHue=%23292928&clientId=u2a122f00-1508-4&from=paste&height=164&id=hO11h&name=image.png&originHeight=246&originWidth=994&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=69573&status=done&style=none&taskId=u0269a0c9-fa2b-422e-b66d-5402077e146&title=&width=662.6666666666666)<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1679121050256-f419626e-7a21-4ac1-83f9-1b95d1360eb3.png#averageHue=%23292929&clientId=u2a122f00-1508-4&from=paste&height=163&id=TTKfL&name=image.png&originHeight=245&originWidth=1350&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=104566&status=done&style=none&taskId=u6208cb08-47ef-43f9-90cb-c0dd2f14ca8&title=&width=900)

2. 改写`bootsect.s`
```
entry _start
_start:
	mov	ah,#0x03		! read cursor pos
	xor	bh,bh
	int	0x10
	
	mov	cx,#34
	mov	bx,#0x0007		! page 0, attribute 7 (normal)
	mov	bp,#msg1
	mov	ax,#0x07c0
	mov	es,ax         ! set correct segment address
	mov	ax,#0x1301		! write string, move cursor
	int	0x10

inf_loop:
        jmp inf_loop     ! keep not exit

msg1:
	.byte 13,10
	.ascii "EliteX system is Loading ..."
	.byte 13,10,13,10

.org 510   ! jump over root_dev
boot_flag:
	.word 0xAA55         ! effective sign
```

3. 要仅汇编`bootsect.s`得到`Image`，运行以下命令（在实模式下，as86工具用于汇编产生目标代码，ld86工具用于连接产生可执行文件）
```bash
as86 -0 -a -o bootsect.o bootsect.s
ld86 -0 -s -o bootsect bootsect.o
dd bs=1 if=bootsect of=Image skip=32
```

4. 结果

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1679291194417-3bded04a-f0fa-42d5-881a-969e7b59420d.png#averageHue=%23171716&clientId=ua87acfff-24aa-4&from=paste&height=411&id=u13c84d5d&name=image.png&originHeight=552&originWidth=946&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=45537&status=done&style=none&taskId=uaf3fd5c0-d375-488d-a6e2-9636e569b0e&title=&width=704.65625)
<a name="VRykQ"></a>
## 2. 改写setup.s
<a name="JS2dj"></a>
### task1

1. 在`setup.s`中写入`bootsect.s`的内容，对字符串信息作修改，修改`es`为`0x07e0`，因为`setup`在内存紧跟`bootsect`(0x07c00 + 0x200)之后 (这里将`cs`的值通过`ax`赋给`es`，因为此时`cs`的值就是`0x07e0`）)
```
entry _start
_start:
mov	ah,#0x03		! read cursor pos
xor	bh,bh
int	0x10

mov	cx,#25
mov	bx,#0x0007		! page 0, attribute 7 (normal)
mov	bp,#msg1
mov	ax,cs
mov	es,ax
mov	ax,#0x1301		! write string, move cursor
int	0x10

inf_loop:
jmp inf_loop 

msg1:
.byte 13,10
.ascii "Now we are in SETUP"
.byte 13,10,13,10
```
![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1679295121521-d9f5ba9a-a2f3-406c-95b2-c032f4093a17.png#averageHue=%23f8f6f3&clientId=ua87acfff-24aa-4&from=paste&height=156&id=u53cd6060&name=image.png&originHeight=234&originWidth=1106&originalType=binary&ratio=1.5&rotation=0&showTitle=true&size=121487&status=done&style=none&taskId=ueb27f2e8-c7ae-4f15-9709-13b57b4a98b&title=int%200x13&width=737.3333333333334 "int 0x13")

2. 在`**bootsect.s**`中添加源码中载入`setup`的部分，并修改`SETUPSEG`为`0x07e0`，原因还是在于我们没有移动`**bootsect**`**，**去掉循环并修改`SETUPLEN`为`2`，因为对我们的改写后的`setup`，仅需读入两个扇区就够了（其实一个扇区的大小也够了）
```
SETUPLEN = 1
SETUPSEG = 0x07e0

entry _start
_start:
	mov	ah,#0x03		! read cursor pos
	xor	bh,bh
	int	0x10
	
	mov	cx,#34
	mov	bx,#0x0007		! page 0, attribute 7 (normal)
	mov	bp,#msg1
	mov	ax,#0x07c0
	mov	es,ax
	mov	ax,#0x1301		! write string, move cursor
	int	0x10

load_setup:
	mov	dx,#0x0000		! drive 0, head 0
	mov	cx,#0x0002		! sector 2, track 0
	mov	bx,#0x0200		! address = 512, in INITSEG
	mov	ax,#0x0200+SETUPLEN	! service 2, nr of sectors
	int	0x13			! read it
	jnc	ok_load_setup		! ok - continue
	mov	dx,#0x0000
	mov	ax,#0x0000		! reset the diskette
	int	0x13
	j	load_setup
	
ok_load_setup:
	jmpi	0,SETUPSEG 

msg1:
	.byte 13,10
	.ascii "EliteX system is Loading ..."
	.byte 13,10,13,10


.org 510   ! jump over root_dev
boot_flag:
	.word 0xAA55         ! effective sign
```

3. 修改`linux-0.11/tool/build.c`注释掉最后部分，以便我们借助MakeFile编译`bootsect.s`与`setup.s`，而不用两个分别手动编译

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1679294169436-70675d89-6d65-4daf-8497-da686fe3a38b.png#averageHue=%230b0b0b&clientId=ua87acfff-24aa-4&from=paste&height=339&id=u8afde1bf&name=image.png&originHeight=564&originWidth=1029&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=160589&status=done&style=none&taskId=u11ec5c70-12de-4770-8679-70f759df314&title=&width=619)

4. 结果

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1679294501705-49ff1622-5adc-437a-8cff-1be4d2841e43.png#averageHue=%23191919&clientId=ua87acfff-24aa-4&from=paste&height=490&id=ub64002a5&name=image.png&originHeight=536&originWidth=826&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=38308&status=done&style=none&taskId=ue6cf2b2d-8218-4f57-977c-2368cbcf023&title=&width=754.65625)
<a name="pW014"></a>
### task2

1. 我们需要`setup.s`源码中获取硬件信息的部分，需要解决的问题是将这些数据打印在屏幕上，利用了功能号为`0x0E`的`0x10`号中断，指导书写了一个`print_nl`来打印回车换行符，而我直接在打印的字符串中加入`13 10`实现回车换行
```
INITSEG  = 0x9000

entry _start
_start:
    mov ah,#0x03     ; read cursor pos
    xor bh,bh
    int 0x10

    mov cx,#25       ; Print "NOW we are in SETUP"
    mov bx,#0x0007
    mov bp,#msg2 
    mov ax,cs        ; cs: 0x07e0
    mov es,ax
    mov ax,#0x1301
    int 0x10

; Get Cursor Pos
    mov ax,#INITSEG
    mov ds,ax
    mov ah,#0x03
    xor bh,bh
    int 0x10
    mov [0],dx  	; store in 9000:0

; Get Memory Size
    mov ah,#0x88
    int 0x15
    mov [2],ax      ; store in 9000:2

; Get hd0 data
    mov ax,#0x0000
    mov ds,ax       ; modify ds
    lds si,[4*0x41]
    mov ax,#INITSEG
    mov es,ax       
    mov di,#0x0004  ; store in 9000:4
    mov cx,#0x10
    rep
    movsb

! Be Ready to Print
    mov ax,cs       ; 0x07e0
    mov es,ax
    mov ax,#INITSEG ; 9000
    mov ds,ax

; print Cursor Position
    mov cx,#18
    mov bx,#0x0007
    mov bp,#msg_cursor
    mov ax,#0x1301
    int 0x10

    mov dx,[0]  ; pass hex number through register dx to function print_hex
    call    print_hex

; print Memory Size
    mov ah,#0x03
    xor bh,bh
    int 0x10

    mov cx,#14
    mov bx,#0x0007
    mov bp,#msg_memory
    mov ax,#0x1301
    int 0x10

    mov dx,[2]  
    call    print_hex

; print KB
    mov ah,#0x03
    xor bh,bh
    int 0x10

    mov cx,#2
    mov bx,#0x0007
    mov bp,#msg_kb
    mov ax,#0x1301
    int 0x10

; print Cyles
    mov ah,#0x03
    xor bh,bh
    int 0x10
    mov cx,#7
    mov bx,#0x0007
    mov bp,#msg_cyles
    mov ax,#0x1301
    int 0x10
    mov dx,[4]
    call    print_hex

; print Heads
    mov ah,#0x03
    xor bh,bh
    int 0x10
    mov cx,#8
    mov bx,#0x0007
    mov bp,#msg_heads
    mov ax,#0x1301
    int 0x10
    mov dx,[6]
    call    print_hex

; print Secotrs
    mov ah,#0x03
    xor bh,bh
    int 0x10
    mov cx,#10
    mov bx,#0x0007
    mov bp,#msg_sectors
    mov ax,#0x1301
    int 0x10
    mov dx,[12]
    call    print_hex

inf_loop:
    jmp inf_loop

print_hex:
    mov    cx,#4
print_digit:
    rol    dx,#4   ; rotate left
    mov    ax,#0xe0f 
    and    al,dl   ; fetch low 4 bits
    add    al,#0x30    ; 0~9
    cmp    al,#0x3a    
    jl     outp
    add    al,#0x07    ; a~f , add more 0x07
outp:
    int    0x10
    loop   print_digit
    ret

msg2:
    .byte 13,10
    .ascii "NOW we are in SETUP"
    .byte 13,10,13,10
msg_cursor:
    .byte 13,10
    .ascii "Cursor position:"
msg_memory:
    .byte 13,10
    .ascii "Memory Size:"
msg_cyles:
    .byte 13,10
    .ascii "Cyls:"
msg_heads:
    .byte 13,10
    .ascii "Heads:"
msg_sectors:
    .byte 13,10
    .ascii "Sectors:"
msg_kb:
    .ascii "KB"
```

2. 结果

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1679390498885-fa17ae6d-b23d-42a3-b330-8ebfc78ec9e1.png#averageHue=%231d1d1c&clientId=u65b4c6eb-4a7f-4&from=paste&height=453&id=uded74e2b&name=image.png&originHeight=559&originWidth=896&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=43381&status=done&style=none&taskId=uf6a85f2d-73a3-4faa-9cc6-46206197425&title=&width=725.328125)
<a name="zTa0D"></a>
# 实验2 系统调用

---

<a name="JOp3O"></a>
## 1. 编写接口函数iam, whoami
跟`write`一样，在接口函数文件内调用宏函数`_syscall1`或`_syscall2`（依参数个数而定），程序内包括后续用于测试系统调用的`main`函数。<br />iam.c
```cpp
#define __LIBRARY__   // 定义了这个宏，unistd.h中的一个条件编译块才会编译
#include <unistd.h>
#include <errno.h>
_syscall1(int, iam, const char*, name);


int main(int argc, char* argv[])
{
    iam(argv[1]);
}
```
whoami.c
```cpp
#define __LIBRARY__
#include <unistd.h>
#include <errno.h>
#include <stdio.h>

_syscall2(int, whoami, char*, name, unsigned int, size);

int main()
{	
	char username[25] = {0};
	whoami(username, 23);
	printf("username: %s\n", username);
}
```
<a name="W3D3k"></a>
## 2. 修改unistd.h
可以跳过这步，因为之后的编译过程所用到的`unistd.h`头文件并不在这个源码树下，而是在标准头文件`/usr/include`下。<br />在`linux-0.11/include/unistd.h`添加宏`_NR_whoami`、`_NR_iam`以在`_syscall*`函数中传递正确的参数给`0x80`号中断处理程序<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1679572755150-a56cb4f4-d15c-4ae1-9805-281eeb789ef7.png#averageHue=%23292929&clientId=uf07d0e56-512f-4&from=paste&height=413&id=ufd549e7e&name=image.png&originHeight=558&originWidth=1370&originalType=binary&ratio=1.3499999046325684&rotation=0&showTitle=false&size=241240&status=done&style=none&taskId=u866e49d8-c96e-4501-a177-307f9157abc&title=&width=1014.814886503918)
<a name="u7wVb"></a>
## 3. 修改_sys_call_table函数表
在`linux-0.11/include/linux/sys.h`添加函数指针`sys_whoami`、`sys_iam`，函数在`sys_call_table`数组中的位置必须和在`<unistd.h>`文件中的`__NR_xxxxxx`的值对应上。在文件开头加上`extern`是让编译器在其它文件寻找这两个函数<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1679573228960-b5285a35-85b6-4209-8ae9-b138c0d50cb6.png#averageHue=%232a2a2a&clientId=u33e52eb9-8f95-4&from=paste&height=514&id=ud13dda37&name=image.png&originHeight=694&originWidth=1410&originalType=binary&ratio=1.3499999046325684&rotation=0&showTitle=false&size=416921&status=done&style=none&taskId=u00862be4-becc-4d75-a056-a82d7ed996f&title=&width=1044.4445182266602)
<a name="dhvNt"></a>
## 4. 实现函数sys_whoami, sys_iam
在`linux-0.11/kernel/iamwho.c`中编写最终的执行函数，执行这两个函数是系统调用的最后一步<br />在 Linux-0.11 内核中，`get_fs_byte` 和 `put_fs_byte` 函数用于在用户空间和内核空间之间传输数据。<br />`get_fs_byte` 函数从用户空间读取一个字节到内核空间。它接受一个指向用户空间内存地址的指针，并返回从该地址读取的字节。<br />`put_fs_byte` 函数则将一个字节从内核空间写入用户空间。它接受一个字节值和一个指向用户空间内存地址的指针。它将字节值写入指定的用户空间地址。<br />这两个函数在数据传输过程中起到了关键作用，使得内核可以与用户空间的应用程序进行安全地数据交换。
```c
#include<string.h>
#include<asm/segment.h>  // get_fs_byte, put_fs_byte
#include<errno.h>

char str_pos[24];
int sys_iam(const char* name)
{
    char c ;
    int i = 0;
    while((c = get_fs_byte(name+i)) != '\0')
    {
        str_pos[i] = c;
        ++i;
    }

    if(i > 23)
    {
        errno = EINVAL;
        return -1;
    }
    printk("elitezx lab2 string:  %s\n",str_pos );	
    return i;
}

int sys_whoami(char* name, unsigned int size)
{
    if(size<strlen(str_pos))
    {
        errno = EINVAL;
        return -1;
    }
    int ans = 0;
    char c;
    while((c = str_pos[ans] )!='\0')
    {
        put_fs_byte(c,name++);
        ++ans;
    }
    return ans;
}
```
<a name="aSQwE"></a>
## 5. 执行
关于这部分，指导书说的比较详细了，我这里再补充一些：挂载hdc目录到虚拟机操作系统上，实现hdc目录在linux-0.11与ubuntu22.04之间的文件共享，我们把用于系统调用的测试程序`iam.c`，`whoami.c`复制到hdc目录就可以在Bochs模拟器下的linux-0.11环境中编译执行这两个文件
```bash
sudo ./mount-hdc 
cp iam.c whoami.c hdc/usr/root
```
![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1679722650168-38ca1876-eae9-4f73-bcd7-9049e23c5f19.png#averageHue=%231d1d1d&clientId=uece2d1bc-2718-4&from=paste&height=376&id=u8f16972f&name=image.png&originHeight=507&originWidth=777&originalType=binary&ratio=1.3499999046325684&rotation=0&showTitle=false&size=32649&status=done&style=none&taskId=u93898fba-d497-4c31-b847-ed2fc5b1fcd&title=&width=575.555596214266)<br />注意在`iam.c`,`whoami.c`程序内的头文件`<unistd.h>`是标准头文件，是由GCC编译器一同安装的，它们通常随着GCC一起打包并分发，通常位于`/usr/include`目录下，而不是在之前修过的源码树下的`include/unistd.h`, 因此我们要转入`hdc/usr/include`下修改`<unistd.h>`，加入两个宏`__NR_iam`,`__NR_whoami`<br />编译
```bash
gcc -o iam iam.c
gcc -o whoami whoami.c
```
<a name="GQLfS"></a>
## 6. 结果
![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1679724796210-81f3aae1-2a44-4b80-aae6-3028a859b73f.png#averageHue=%23ab9f84&clientId=uece2d1bc-2718-4&from=paste&height=430&id=u8fb9b579&name=image.png&originHeight=580&originWidth=983&originalType=binary&ratio=1.3499999046325684&rotation=0&showTitle=false&size=66303&status=done&style=none&taskId=u266c3a1b-1d68-4099-b48b-b886c550c27&title=&width=728.1481995863879)
<a name="ALw3l"></a>

