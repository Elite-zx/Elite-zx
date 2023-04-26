---
title: "[CSAPP] datalab, bomblab, attacklab"
date: 2023/03/06
categories:
- CSAPP
tags: 
- Foundation
---
<meta name="referrer" content="no-referrer"/>

<a name="IR5gF"></a>
# lab1 dataLab

<!--more-->

<a name="RKm5i"></a>
## 前提
确保有一个linux系统，并已经执行过以下两条命令:<br />安装gcc：`sudo apt-get install build-essential`  <br />安装[gcc的交叉编译环境](https://askubuntu.com/questions/855945/what-exactly-does-gcc-multilib-mean-on-ubuntu#:~:text=gcc%2Dmultilib%20is%20useful%20for,you%20get%20the%20idea).)：`sudo apt-get install gcc-multilib`，因为实验的程序需要以32位方式编译<br />在[CMU的CSAPP网站](http://csapp.cs.cmu.edu/3e/labs.html)上下载实验所需资料，包括**README, Writeup，Self-Study Handout，**这三部分均包含对实验的要求说明（Handout的说明在其包含的bits.c文件中由注释给出），Self-Study Handout包括用于测试的文件
<a name="IOcHR"></a>
## 1.bitXor(x,y)
要用~和&实现异或^，即将结果中 1-0，0-1对应的位设置为1<br />x&y中为1的位(bit)对应 1-1； 取反后为：0-0、0-1、1-0；<br />(~x&~y)为1的位(bit)对应 0-0； 取反后为：1-1、0-1、1-0；<br />两个做交集即为结果。（位向量可以表示集合，&，|，~可视为 交，并，补操作）
```cpp
/*
bitXor - x^y using only ~ and & 
Example: bitXor(4, 5) = 1
Legal ops: ~ &
Max ops: 14
Rating: 1
*/
int bitXor(int x, int y) {
    return  ~(x&y) & ~(~x&~y) ; // if regardless '+' is illegal:(~x&y) + ((x)&(~y)) or ~((x&y) + ((~x)&(~y)))
}
```
<a name="mB5XE"></a>
## 2.tmin
最简单的一题：`000...001` --> `1000...000`
```cpp
/* 
tmin - return minimum two's complement integer 
Legal ops: ! ~ & ^ | + << >>
Max ops: 4
Rating: 1
*/
int tmin(void) {
  return 1<<31;
}
```
<a name="pr9MQ"></a>
## 3.isTmax(x)
这题最开始想到 Tmin的一个性质，即对二进制补码 Tmax关于加法的逆为其本身：Tmax+Tmax = 0；因此利用这个性质写出了`!((~x) + (~x))`，但[测试结果出乎意料](https://stackoverflow.com/questions/74541471/datalab-of-csappistmax-seems-unoperative?noredirect=1#comment131585049_74541471)，加法溢出导致了未知的行为。<br />根据 Tmax +1 = Tmin 的性质可以得出 ,  `100...000` + `011...111` = `111..1111` (-1)，可得出`!(~x^(x+1))`（^可替换为+）<br />处理特例-1： -1同样会产生结果1，根据 `-1+1==0`,`Tmax+1!=0`，进而`!(-1+1) !=0` ，`!(Tmax+1) ==0`.<br />所以`对Tmax, x+(x+1) = x` , `对-1,x+(x+1)!=x`<br />用`x+(x+1)` 替换原式中的第一项x，最终得出结果：`!(~((x+!(x+1))^(x+1)))`
```cpp
/*
isTmax - returns 1 if x is the maximum, two's complement number,
and 0 otherwise 
egal ops: ! ~ & ^ | +
Max ops: 10
Rating: 1
*/
int isTmax(int x) {
  return !(~((x+!(x+1)) ^ (x+1))) ; 
   // !((~x) + (~x));  it should be right, the operator "!" seem to not work
}
```
<a name="kHLgK"></a>
## 4.allOddBits(x)
这道题没想出来，在x上shift的方式想了一个多小时，总是不能满足所有测试用例，说明在x上shift是行不通的。<br />用好异或即可解决：构造`101...1010`，再用该数提取x中的奇数位，最后再与`101...1010`比较
```cpp
/* 
allOddBits - return 1 if all odd-numbered bits in word set to 1
where bits are numbered from 0 (least significant) to 31 (most significant)
Examples allOddBits(0xFFFFFFFD) = 0, allOddBits(0xAAAAAAAA) = 1
Legal ops: ! ~ & ^ | + << >>
Max ops: 12
Rating: 2
*/
int allOddBits(int x) {
  int allOdd = (0xAA << 24) + (0xAA << 16) + (0xAA << 8) + 0xAA; // 10101010..101
  return ! ((allOdd & x) ^ allOdd);   
}
```
<a name="sswhY"></a>
## 5.isAsciiDigit(x)
有点难，还是自己做出来了，主要使用了掩码提取x中的指定位，再运用前几题的经验---用异或执行比较操作。<br />x的最后四位，3bit 与 1,2bit不能同时为1，因而有`!((x&mask2)^mask2) + (!((x&mask3)^mask3)))`，难点在于怎么处理好式中三部分的逻辑关系
```cpp
/* 
 * isAsciiDigit - return 1 if 0x30 <= x <= 0x39 (ASCII codes for characters '0' to '9')
 *   Example: isAsciiDigit(0x35) = 1.
 *            isAsciiDigit(0x3a) = 0.
 *            isAsciiDigit(0x05) = 0.
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 15
 *   Rating: 3
 */
int isAsciiDigit(int x) {
  int mask1 = 0x3;   // 000...0011
  int mask2 = 0xA;   // 1010
  int mask3 = 0xC;   // 1100
  return  !( ((x>>4)^mask1) | (!((x&mask2)^mask2) + (!((x&mask3)^mask3)) ) );
}
```
<a name="DZZaa"></a>
## 6.conditional
比较简单，主要实现这样一个逻辑：x!=0，返回y；x=0，返回z；<br />涉及的操作是把x转化为0与1两个值，再把`000...0001`转化为`111...1111`
```cpp
/* 
 * conditional - same as x ? y : z 
 *   Example: conditional(2,4,5) = 4
 *   Legal ops: ! ~ & ^ | + << >> 
 *   Max ops: 16
 *   Rating: 3
 */
int conditional(int x, int y, int z) {
  int  judge = !(x ^ 0x0); // x=0 -> judge=1,whereas x!=0 -> judge=0
  judge = (judge << 31)>>31; // 000...000 or 111...111
  return ((~judge)&y) | (judge&z);
}
```
<a name="MZZvz"></a>
## 7.isLessOrEqual(x, y)
可通过减法`y-x>=0`判断`x<=y`，由于不存在-符，所以取x关于加法的逆-x，进而变为 x+y<br />那么这题就涉及加法溢出,需要对` x+uw  y `结果的三种情况的判断(negative overflow ， positive overflow)，变得复杂起来。<br />更好的想法是**分析式子**`**y-x**`**并加入一个conditional操作**：如果两者异号(正-负，负-正)，那么结果的正负的确定的；如果两者同号(同号相减不可能溢出)，则通过与Tmin相与提取符号位。
```cpp
/* 
 * isLessOrEqual - if x <= y  then return 1, else return 0 
 *   Example: isLessOrEqual(4,5) = 1.
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 24
 *   Rating: 3
 */
int isLessOrEqual(int x, int y) 
{
  int Tmin = 1<<31; // 100...0000
  int signY = Tmin & y;
  int signX = Tmin & x;
  int judge = (signY ^ signX)<<31; 
  x = (~x)+1;
  return (judge&signX) | (~(judge>>31) & !((y+x)&Tmin)) ; // 
}
```
<a name="WP1Li"></a>
## 8.logicalNeg(x)
这题要求自己实现一个 ！逻辑，即输入0返回1，输入N（N!=0）返回0。一开始的出发点是：x=0，返回1；x 位向量存在为1的位，返回0。但是仅靠逻辑运算符无法实现该想法。<br />于是换了一个想法：先得到x的符号位signX。signx为1，说明x为负数，可以直接得到结果；sign为0，说明x即可能为0也可能为正数，那么就要利用补码加法操作会发生的**positive overflow**现象，即 Tmax + x ，对任意x>0均会使结果变为负数，符号位由0 -->1。（positive overflow 不同于 negative overflow，并没有产生整数溢出，因此不会导致[undefined behavior](http://port70.net/~nsz/c/c11/n1570.html#3.4.3p3)）
```cpp
/* 
 * logicalNeg - implement the ! operator, using all of 
 *              the legal operators except !
 *   Examples: logicalNeg(3) = 0, logi'calNeg(0) = 1
 *   Legal ops: ~ & ^ | + << >>
 *   Max ops: 12
 *   Rating: 4 
 */
int logicalNeg(int x) {
  int Tmin = 1<<31;
  int Tmax = ~Tmin;
  int signX = ((x&Tmin)>>31) & 0x1;
  return (signX^0x1) & ((((x + Tmax)>>31)&0x1)^0x1);
}
```
<a name="Y5Acb"></a>
## 9.howManyBits(x)
这题一开始想的是去除符号位后，找位向量中最左边的1的位置序号，但是我忽略了补码的一个性质：**当数的符号位为1时，将数按符号位扩展之后其值不会变**，如1101与101表示的是同一个值(-3)，因此找到最左边的1并不能得到最短的位数。<br />要找到能表示负数的最短位数，而又不受符号位拓展的影响，便要找最左边的0，而不是1。为与对正数的操作相统一，做法是把负数按位取反(Such as: 1101 -> 0010)<br />按二分法逐步缩小范围，找到最左边的1
```cpp
/* howManyBits - return the minimum number of bits required to represent x in
 *             two's complement
 *  Examples: howManyBits(12) = 5
 *            howManyBits(298) = 10
 *            howManyBits(-5) = 4
 *            howManyBits(0)  = 1
 *            howManyBits(-1) = 1
 *            howManyBits(0x80000000) = 32
 *  Legal ops: ! ~ & ^ | + << >>
 *  Max ops: 90
 *  Rating: 4
 */
int howManyBits(int x) {
  int b16,b8,b4,b2,b1,b0;
  int signX = x>>31;
  x = ((~signX) & x) | (signX&(~x));// if x is negative, let sign bit:1-> 0
  
  b16 = (!!(x>>16))<<4; // ensure high 16 bits exist 1 or not
  x=x>>b16;
  b8 = (!!(x>>8))<<3; // ensure high 8 bits 
  x=x>>b8;
  b4 = (!!(x>>4))<<2; // ensure high 4 bits 
  x=x>>b4;  
  b2 = (!!(x>>2))<<1; // ensure high 2 bits 
  x=x>>b2; 
  b1 = !!(x>>1); // ensure 31 bits or not 
  x = x>>b1;
  b0 = x;
  
  return b0+b1+b2+b4+b8+b16+1; // 1: sign bit
}
```
<a name="glYde"></a>
## 10.floatScale2(uf)
先对题目做出一点解释：传入一个`unsigned`类型的参数，但是函数内将它解释为一个浮点数类型，即参数的值不是参数的十进制值，而是其二进制形式表示的浮点数值(M×2E)<br />**整体思路：用掩码分别提取sign,exponent,fraction三部分，再根据exp的值分类讨论**<br />注意点：对normalized，f*2的2是乘在了2E；而对denormalized，是乘在了frac表示的M上，这也是为什么`frac = frac <<1`，这也使得denormalized能转化到normalized (smoothly)
```cpp
//float
/* 
 * floatScale2 - Return bit-level equivalent of expression 2*f for
 *   floating point argument f.
 *   Both the argument and result are passed as unsigned int's, but
 *   they are to be interpreted as the bit-level representation of
 *   single-precision floating point values.
 *   When argument is NaN, return argument    // revision: NaN or infinity
 *   Legal ops: Any integer/unsigned operations incl. ||, &&. also if, while
 *   Max ops: 30
 *   Rating: 4
 */
unsigned floatScale2(unsigned uf) {
  int musk_exp,musk_frac,sign,exp,frac,result;
  musk_exp = 0xFF << 23;
  musk_frac = 0x7FFFFF;
  exp = (uf & musk_exp)>>23;
  frac = uf & musk_frac;
  sign = 0x1<<31 & uf;
  result = 5;
  if(exp == 0xFF  ) // NaN
     result = uf;
  else if(exp == 0x0) // denormalized
  {  
     if(frac == 0x0)
     {
        if(sign)  // -0.0
           result = uf;
        else     // +0.0
           result = 0 ;
     }
     
     else
     {
        frac = frac << 1;
        result = sign+ (exp<<23) + frac;
     }
  }
  
  else if(exp != 0x0 && exp != 0xFF) // normalized
  {
     exp += 1;
     result = sign+ (exp<<23) + frac;
  }
  return result;
}
```
<a name="tO8yh"></a>
## 11.floatFloat2Int(uf)
浮点数类型的这几题比前面的题要轻松很多，大概是因为可用符号和结构比较充足的原因吧。<br />对题目的解释：返回浮点数f的int型表示，如输入`12345.0 (0x4640E400)`, 正确输出为`12345 (0x3039)`<br />注意点：当f的值超过32bit的int类型位向量所能表示的最大值时(2^31-1)，即E>31时，属于out of range
```cpp
/* 
 * floatFloat2Int - Return bit-level equivalent of expression (int) f
 *   for floating point argument f.
 *   Argument is passed as unsigned int, but
 *   it is to be interpreted as the bit-level representation of a
 *   single-precision floating point value.
 *   Anything out of range (including NaN and infinity) should return
 *   0x80000000u.
 *   Legal ops: Any integer/unsigned operations incl. ||, &&. also if, while
 *   Max ops: 30
 *   Rating: 4
 */
 
int floatFloat2Int(unsigned uf) {
  int musk_exp,musk_frac,exp,frac,sign,E,Bias,result;
  musk_exp = 0xFF << 23;
  musk_frac = 0x7FFFFF;
  exp = (uf & musk_exp)>>23;
  frac = uf & musk_frac;
  sign = 0x1<<31 & uf;
  Bias = 127;
  result = 5;
  if(exp == 0xFF  ) // NaN or infinity
     result = 0x80000000u;
     
  else if(exp == 0x0)
     result = 0;
     
  else if(exp != 0x0 && exp != 0xFF) // normalized
  {
     E = exp -Bias;  // bit_num of fraction
     if(E < 0)
        result = 0;
     else if (E>31)
        result = 0x80000000u;
     else
     {
        frac = frac>>(23-E);
        result = (0x1 << E) + frac ; 
        if(sign == 0x1<<31)
           result = - result;
     }
  }
  
  return result;
}
```
<a name="UlJMS"></a>
## 12.floatPower2(x)
注意点：当2^x超过位向量所能表示的最大值（largest normalized）时，即exp 大于 254（1111 1110），属于too large
```cpp
/* 
 * floatPower2 - Return bit-level equivalent of the expression 2.0^x
 *   (2.0 raised to the power x) for any 32-bit integer x.
 *
 *   The unsigned value that is returned should have the identical bit
 *   representation as the single-precision floating-point number 2.0^x.
 *   If the result is too small to be represented as a denorm, return
 *   0. If too large, return +INF.
 * 
 *   Legal ops: Any integer/unsigned operations incl. ||, &&. Also if, while 
 *   Max ops: 30 
 *   Rating: 4
 */
unsigned floatPower2(int x) {
  int exp,frac,E,Bias,result;
  Bias = 127;
  result = 5;
  E = x;
  if(x<1 && x!=0)
     return 0;

  else if(x >= 0x1 || x == 0)
  {
     frac = 0x0;
     exp = E+Bias;
     if(exp > 254)  // 1111 1110
        {
           exp = 0xFF;
           result = exp <<23+frac;         
        }
     else
        result = (exp<<23) + frac; 
  }    
  
  return result ;
}
```
<a name="iHsuB"></a>
## consequence
`make`<br />`./driver.pl`
<a name="SLl25"></a>
### ![data_lab_success.png](https://cdn.nlark.com/yuque/0/2022/png/29536731/1669795434321-27bd7778-bde0-4d21-9ae0-425e1e785bd1.png#averageHue=%230d0c0c&clientId=u8b4f2be4-4c9f-4&from=ui&id=ue9c8e7dc&name=data_lab_success.png&originHeight=631&originWidth=1162&originalType=binary&ratio=1&rotation=0&showTitle=false&size=183673&status=done&style=none&taskId=u00d5bd76-a7dc-4107-8697-fafe865d7ec&title=)

---

<a name="FsQk5"></a>
# lab2 bombLab
<a name="mm3BW"></a>
## phase_1

1. 反汇编`main`函数：`read_line`函数之后寄存器`%rax`和`%rdi`存储了我们输入的字符串的首地址(后续的phase都是如此)

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677142575501-aadca48e-4054-40dc-977b-4719009de3e3.png#averageHue=%2362372c&clientId=u40dabece-2d53-4&from=paste&height=113&id=u7f5a75e8&name=image.png&originHeight=113&originWidth=1058&originalType=binary&ratio=1&rotation=0&showTitle=false&size=65961&status=done&style=none&taskId=u19a9cc96-f38d-462d-9d4b-fbdd1e6cd16&title=&width=1058)<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677163430669-16842232-e1ab-4ac7-a90d-8f9a18e1c5d2.png#averageHue=%232d2d2d&clientId=u40dabece-2d53-4&from=paste&height=128&id=u1267f1f6&name=image.png&originHeight=128&originWidth=1060&originalType=binary&ratio=1&rotation=0&showTitle=true&size=59576&status=done&style=none&taskId=ufdd9544b-0308-49f4-86fd-49a8013d976&title=%E9%AA%8C%E8%AF%81%25rdi%E6%8C%87%E5%90%91%E8%BE%93%E5%85%A5%E5%AD%97%E7%AC%A6%E4%B8%B2%281%29&width=1060 "验证%rdi指向输入字符串(1)")<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677163457263-f780263b-09ed-4875-bafc-0f00d7e8e894.png#averageHue=%23323232&clientId=u40dabece-2d53-4&from=paste&height=77&id=ubbe401e0&name=image.png&originHeight=77&originWidth=723&originalType=binary&ratio=1&rotation=0&showTitle=true&size=31472&status=done&style=none&taskId=u152fe82b-0961-427e-bd1e-8a6755f1504&title=%E9%AA%8C%E8%AF%81%25rdi%E6%8C%87%E5%90%91%E8%BE%93%E5%85%A5%E5%AD%97%E7%AC%A6%E4%B8%B2%282%29&width=723 "验证%rdi指向输入字符串(2)")

2. 反汇编`strings_not_equal`函数：该函数在输入字符串与目的字符串相同时，将寄存器`%rax`（通常用作函数返回值）赋值为0 (1 vice versa)

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677143001741-9ecdcda9-b9a6-4b31-a450-5d80ed226850.png#averageHue=%23302f2f&clientId=u40dabece-2d53-4&from=paste&height=147&id=u575b769d&name=image.png&originHeight=147&originWidth=1140&originalType=binary&ratio=1&rotation=0&showTitle=false&size=79269&status=done&style=none&taskId=u9916894f-f032-4f63-b09d-6ce04314c3f&title=&width=1140)<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677143020716-757eda92-ee3e-4fe0-9c1b-597af2e24eab.png#averageHue=%23323131&clientId=u40dabece-2d53-4&from=paste&height=214&id=uca455390&name=image.png&originHeight=214&originWidth=973&originalType=binary&ratio=1&rotation=0&showTitle=false&size=98661&status=done&style=none&taskId=u7c4aadd7-6706-4e4d-8a95-2e31a1df894&title=&width=973)

3. 反汇编`phase_1`函数：`strings_not_equal`函数返回值为0时，`test %eax, %eax`能使`je 0x400ef7<phase_1+23>`执行，phase_1 defused (explode vice versa)

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677143312955-e1e9a80c-1730-48ae-84f7-5dfded69d3a9.png#averageHue=%232e2d2d&clientId=u40dabece-2d53-4&from=paste&height=361&id=ue40fcfa2&name=image.png&originHeight=361&originWidth=1126&originalType=binary&ratio=1&rotation=0&showTitle=false&size=206173&status=done&style=none&taskId=u54ecca10-9722-4536-ba3f-f972c656feb&title=&width=1126)

4. 至此，只需找出目的字符串的位置即可，而目的字符串的地址明显在调用`strings_not_equal`函数之前赋值的`%esi：0x402400`寄存器中

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677143752561-a0f86e1a-fc9c-4ff2-b386-d8d929f293c5.png#averageHue=%23333333&clientId=u40dabece-2d53-4&from=paste&height=102&id=ua334cc19&name=image.png&originHeight=102&originWidth=1118&originalType=binary&ratio=1&rotation=0&showTitle=false&size=39885&status=done&style=none&taskId=u26286ab1-642e-4f50-9434-8d65b1add7d&title=&width=1118)<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677143789980-9946be38-59bb-4852-bd3c-72747f67fc16.png#averageHue=%23333333&clientId=u40dabece-2d53-4&from=paste&height=152&id=u0cd1b8f0&name=image.png&originHeight=152&originWidth=1065&originalType=binary&ratio=1&rotation=0&showTitle=false&size=69532&status=done&style=none&taskId=u1b6e1505-7e71-4000-8504-44c050e2921&title=&width=1065)
<a name="aPHyw"></a>
## phase_2

1. 反汇编`read_six_numbers`函数：可以推断出其实现了`sscanf(input, "%d %d %d %d %d %d",&a1,&a2,&a3,&a4,&a5,&a6)`的功能，其中`&a1~&a6`分别在1)`%rcx:0x4(%rsi)`2)`%r8:0x8(%rsi)`3)`%r9:0xc(%rsi)`4)`%rsp:0x10(%rsi)`5)`0x8(%rsp):0x14(%rsi), 0x18(%rsi) ` 前3个指针存储在寄存器中传递给`sscanf`函数，后三个指针存储在为`read_six_numbers`函数分配的栈空间中,可以推断出`%rsi`为一个含有六个元素的数组的首地址

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677148614935-cd29c501-e2a8-4185-9924-0829124ef293.png#averageHue=%232e2d2d&clientId=u40dabece-2d53-4&from=paste&height=506&id=ue62a1cc7&name=image.png&originHeight=506&originWidth=1045&originalType=binary&ratio=1&rotation=0&showTitle=false&size=292132&status=done&style=none&taskId=udf564ea8-5d5d-4db1-9fe7-6784845d360&title=&width=1045)<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677150202265-dda02d42-7661-48f0-9ec1-5b420d781e9d.png#averageHue=%23313131&clientId=u40dabece-2d53-4&from=paste&height=74&id=u5d32cc04&name=image.png&originHeight=74&originWidth=675&originalType=binary&ratio=1&rotation=0&showTitle=false&size=24474&status=done&style=none&taskId=u7f387e07-3b4e-4ad1-bae1-5f9cf213c77&title=&width=675)

2. 反汇编`phase_2`函数：判断a1与0x1相等，不相等则explode；接着判断a2与2*a1是否相等，不相等则explode，接着都是一样的模式：判断当前数据是否与前一个数据的2倍相等，不相等则explode，直到判断完六个数据

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677150067118-dd3962a5-1458-4a3e-9399-4cf1699ca7a7.png#averageHue=%23423227&clientId=u40dabece-2d53-4&from=paste&height=656&id=u8a1ec132&name=image.png&originHeight=656&originWidth=885&originalType=binary&ratio=1&rotation=0&showTitle=false&size=478280&status=done&style=none&taskId=u1da79441-ac63-407b-ab6c-037fd3e1450&title=&width=885)

3. 自此，我们可以判断出这六个数字分别是$2^0,2^1,2^2,2^3,2^4,2^5$

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677149991615-e3f805b9-b4b0-4f49-bfbf-36dc2153557b.png#averageHue=%23313131&clientId=u40dabece-2d53-4&from=paste&height=112&id=ua5f4ba93&name=image.png&originHeight=112&originWidth=782&originalType=binary&ratio=1&rotation=0&showTitle=false&size=34849&status=done&style=none&taskId=u43537a4a-415e-4df2-b80d-0601d361576&title=&width=782)
<a name="XKRDk"></a>
## phase_3

1. 反汇编`phase_3`：从`(%esi)`的字符串可以看出该函数先读取了两个输入的值，接着判断第一个值是否大于7(`cmpl 0x7,0x8(rsp)`)，并根据这个值执行间接跳转操作(`jmp *0x402470(,rax,8)`)

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677150892423-92750918-b2b5-4aa5-9b0e-e08eec5cffdd.png#averageHue=%23141313&clientId=u40dabece-2d53-4&from=paste&height=150&id=uf4734a85&name=image.png&originHeight=150&originWidth=1074&originalType=binary&ratio=1&rotation=0&showTitle=false&size=61373&status=done&style=none&taskId=u56bba885-3031-4576-9ddd-85ccf2060e9&title=&width=1074)

2. 查看0x402470附近存储的地址值(用于实现switch语句的跳转表)，只要地址值的地址可以由0x402470加上一个8的倍数得到，就是符合条件的，最后验证出来有7个地址值，进而有7个符合条件的`0x8(%rsp`：1 2 3 4 5 6 7

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677072562462-74d53e52-6a59-498d-9186-02f1b43b8be5.png#averageHue=%23131313&clientId=u39d47224-2023-4&from=paste&height=324&id=u10476384&name=image.png&originHeight=324&originWidth=1067&originalType=binary&ratio=1&rotation=0&showTitle=false&size=80101&status=done&style=none&taskId=u49754a92-19b8-499c-8daf-4c666824406&title=&width=1067)

3. 根据后续的赋值-跳转指令，可以得到对应的7个`0xc(%rsp)`：311 707 256 389 206 682 327，所以最终答案有7个: (1, 311)，(2, 707)，(3, 256)，(4, 389)，(5, 206)，(6, 682)，(7, 327)

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677151557789-3726bd23-9a03-48c7-bb2b-1a31a71ae4c0.png#averageHue=%23121212&clientId=u40dabece-2d53-4&from=paste&height=286&id=ud77abcea&name=image.png&originHeight=327&originWidth=347&originalType=binary&ratio=1&rotation=0&showTitle=false&size=72813&status=done&style=none&taskId=uaa3da35e-6e2a-42ba-af96-025e357b784&title=&width=304)![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677151578594-a2486d66-586a-473a-ba87-8ed30e462b01.png#averageHue=%231e1e1e&clientId=u40dabece-2d53-4&from=paste&height=294&id=ud120ef9a&name=image.png&originHeight=391&originWidth=354&originalType=binary&ratio=1&rotation=0&showTitle=false&size=101567&status=done&style=none&taskId=ub5d0284e-6af4-4113-b8cd-89ebdce0f6d&title=&width=266)<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677073427546-61c8a627-e902-4132-922f-d9c30d888865.png#averageHue=%23303030&clientId=u39d47224-2023-4&from=paste&height=50&id=u47146b93&name=image.png&originHeight=75&originWidth=297&originalType=binary&ratio=1&rotation=0&showTitle=false&size=8224&status=done&style=none&taskId=u32d95d06-a5d5-44ea-9c62-17652eea139&title=&width=197)![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677073446185-f50d15ab-e6e5-4d7f-b87a-7c41585c225e.png#averageHue=%232f2f2f&clientId=u39d47224-2023-4&from=paste&height=47&id=ue4a4e105&name=image.png&originHeight=70&originWidth=287&originalType=binary&ratio=1&rotation=0&showTitle=false&size=8707&status=done&style=none&taskId=u21abdc4b-34e0-4b23-8ae8-6a213e06389&title=&width=192)![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677073458555-0aefc97d-f40a-4b0b-8e5e-1c592d1478fb.png#averageHue=%23313131&clientId=u39d47224-2023-4&from=paste&height=51&id=u12915178&name=image.png&originHeight=74&originWidth=307&originalType=binary&ratio=1&rotation=0&showTitle=false&size=8649&status=done&style=none&taskId=u884bf4d9-3d42-48e3-9d32-a6cc91f0115&title=&width=212)![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677073483221-c6634274-ca68-4d70-b35d-bcf9c12bc64d.png#averageHue=%23292929&clientId=u39d47224-2023-4&from=paste&height=48&id=u8a9d1cb9&name=image.png&originHeight=71&originWidth=296&originalType=binary&ratio=1&rotation=0&showTitle=false&size=10382&status=done&style=none&taskId=u3d742e48-f459-45a3-abcb-5a2e46a9698&title=&width=201)![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677073498912-78462783-24d1-48c5-bd9c-dc0efd391d71.png#averageHue=%232a2a29&clientId=u39d47224-2023-4&from=paste&height=47&id=uc7e8ea56&name=image.png&originHeight=75&originWidth=290&originalType=binary&ratio=1&rotation=0&showTitle=false&size=11606&status=done&style=none&taskId=u579ff7da-06cc-49aa-bbb5-7d665920365&title=&width=183)![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677073505761-bdd3ef17-0fcd-491a-8c9d-c021bd67b4a8.png#averageHue=%23272727&clientId=u39d47224-2023-4&from=paste&height=53&id=u656875e3&name=image.png&originHeight=78&originWidth=307&originalType=binary&ratio=1&rotation=0&showTitle=false&size=11833&status=done&style=none&taskId=u1ec87705-b895-47c3-98cb-1da89ebe401&title=&width=208)![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677073525247-e99ecac4-12c7-4929-ac87-722029dcb4fd.png#averageHue=%23303030&clientId=u39d47224-2023-4&from=paste&height=49&id=uaaf9dd91&name=image.png&originHeight=74&originWidth=316&originalType=binary&ratio=1&rotation=0&showTitle=false&size=8976&status=done&style=none&taskId=u262b648d-9811-41df-9106-07a991aca4a&title=&width=208)
<a name="Qae7S"></a>
## phase_4

1. 反汇编`phase_4`函数：开头部分具有与`phase_3`函数相似的部分，均需输入两个值（留意这里，其实只需保证填充了两个值就可以），且规定了第1个值不大于14(`cmpl $0xe, 0x8(%rsp)`)，之后函数调用`func4`函数，传入三个参数`%edx`, `%esi`, `0x8(%rsp)`。虽然目前不清楚func4做了什么，但可以确定返回值必须为0(`test %eax, %eax`)。后续的`cmpl $0x0, 0xc(%rsp)`足以确定第2个值为0

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677206362623-39fe4977-5cab-4016-9003-2541d41dbe6a.png#averageHue=%232a2823&clientId=u15f83395-fa33-4&from=paste&height=416&id=ubcbcc5b1&name=image.png&originHeight=587&originWidth=1125&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=601648&status=done&style=none&taskId=ucd50703b-cd59-4e1b-b4f1-5fefbaddeb2&title=&width=797)

2. 反汇编`func4`函数：出现了`func4`调用自身的情况，所以`func4`是一个递归函数。第1部分将`%rax`赋值为`%edx`-`%esi`,再加上它的最高位(`%rax >> 31`)，接着执行算数右移。这里加上最高位的原因在于，当后续`%rax`在递归中值减少为-1时，最高位是符号位1，两者相加能保证`%rax`始终大于等于0，结合后续汇编内容，可以推断出第一个值`0x8(%rsp)`应当是一个无符号数，范围为0~14; 第2部分，可以看出这是一个二分查找的过程，如果`%ecx > %edi`，那么就使`%ecx`变为`%esi`到`%edx`的中间值(`lea -0x1(%rcx), %edx`)；第3部分，结合eax返回必须为0的条件，可以推断出所有递归的函数调用均不应使第3部分的跳转指令执行，否则会使返回`phase_4`的`%rax`值为1

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677204842268-34841e29-56e5-4d63-9e9f-b1576cec24a4.png#averageHue=%232b2a2a&clientId=u15f83395-fa33-4&from=paste&height=562&id=u81eba999&name=image.png&originHeight=843&originWidth=1305&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=520895&status=done&style=none&taskId=u37b9260f-a9c9-4dd9-abb9-dd995610f26&title=&width=870)

3. 自此，可以推断出第1个值随递归调用次数增多而减少，进而有多个不同的值，并在减少为0时停止变化。分析后可得出有以下4个值7 3 1 0，结合第2个值为0的条件，得出符合条件的字符串有(7, 0), (3, 0), (1, 0), (0, 0)

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677206164369-fa35758d-403b-483b-ad52-af80ef73df84.png#averageHue=%232c2c2c&clientId=u15f83395-fa33-4&from=paste&height=49&id=u3b0eedfa&name=image.png&originHeight=74&originWidth=649&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=17085&status=done&style=none&taskId=ub467ca8a-a273-4b74-b425-f72d9e99ae4&title=&width=432.6666666666667)![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677206214348-cbc56dfd-faed-4afb-8859-c6bb00e4be62.png#averageHue=%232c2c2c&clientId=u15f83395-fa33-4&from=paste&height=49&id=ub80967c2&name=image.png&originHeight=74&originWidth=686&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=17880&status=done&style=none&taskId=u78e1925a-de3d-4ff7-a76b-00e4657dd48&title=&width=457.3333333333333)<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677206249049-10571826-c506-4fdf-bcae-4ca9487bd383.png#averageHue=%232d2d2d&clientId=u15f83395-fa33-4&from=paste&height=46&id=u3c92002a&name=image.png&originHeight=75&originWidth=713&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=17666&status=done&style=none&taskId=u81f0177a-9477-484d-bc60-f8009a91d73&title=&width=435.3333435058594)![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677206271742-0b02d5c9-234f-465e-9fb7-6a9cb6c3b2f3.png#averageHue=%232c2c2c&clientId=u15f83395-fa33-4&from=paste&height=49&id=u0a7235e4&name=image.png&originHeight=73&originWidth=674&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=17218&status=done&style=none&taskId=u48f4584a-4771-47be-b5b5-5281e909d12&title=&width=449.3333333333333)
<a name="Kxq7k"></a>
## phase_5

1. 反汇编`phase_5`函数：要求输入字符串包含六个字符（注意！包含空格），根据后续汇编逻辑，可反编译得到以下程序 (%fs:0x28在这里的作用：作为金丝雀值，提供堆栈保护检查)
```c
int index
int i = 0 // %rax
do{
index = *(input+i);
index = index& 0xf; // take lower four bits
dest[0] = source[index]; // dest: (%rsp+0x10+%rax) source: 0x4024b0
if(string_not_equal(dest, target) == 0) // target: 0x40245e --- "flyers"
      //defuse
else
   explode_bomb();
}while(i>6)
```
![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677227102569-50a0daeb-22b8-4911-84ee-83283088ca0d.png#averageHue=%23211710&clientId=ub432d06a-c081-4&from=paste&height=629&id=u029c0758&name=image.png&originHeight=944&originWidth=901&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=467386&status=done&style=none&taskId=uaa2e377e-a27a-4e06-9129-f19ece505a9&title=&width=600.6666666666666)

2. 分别查看`source: 0x4024b0`和`target: 0x40245e`处的字符串，我们要做的就是使输入字符串形成的索引值能够从`0x4024b0`处的字符集中提取出 "flyers"

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677227207876-48a2e806-f23e-49ec-982e-698183c7bc19.png#averageHue=%23151515&clientId=ub432d06a-c081-4&from=paste&height=52&id=u3302b9b7&name=image.png&originHeight=78&originWidth=1766&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=39766&status=done&style=none&taskId=u6f4121a7-1717-4bf8-9d35-1f34adc43a8&title=&width=1177.3333333333333)<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677227244326-73d2e1d2-8fa8-4452-bb1c-64b132ecd786.png#averageHue=%23131313&clientId=ub432d06a-c081-4&from=paste&height=49&id=u7ad1cd69&name=image.png&originHeight=73&originWidth=906&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=18317&status=done&style=none&taskId=u0a7a9ee0-efaa-4b08-8a9e-6e726ed5958&title=&width=604)

3. 我们的输入字符串每个字符在内存中占一个byte，`movzbl (%rbx, %rax, 1), %ecx`说明了一次循环提取一个字符，并只取该字符的低四位(`and $0xf, %edx`)作为索引值
4. 首先先确定索引值，然后推出字符串：对比source和target两个字符串，可以确定索引值为：7 15 14 5 6 7，这6个索引值在ASCII表中对应的字符是无法输入的（eg：7 BEL），因此我们要利用只取低四位作索引值这一特点，索引值对应的四位二进制为：1001，1111，1110，0101，0110，0111 ， 因此所有(prefer a~z)低四位为以上二进制组合的均可以defuse，如ionefg，yONuvw

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677228092474-185f8fde-3015-4a64-ae85-2a4931bb2ca9.png#averageHue=%23191919&clientId=ub432d06a-c081-4&from=paste&height=72&id=u2762ccc0&name=image.png&originHeight=108&originWidth=741&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=24485&status=done&style=none&taskId=u4d7584c2-7474-4bc2-8df3-b7710936568&title=&width=494)![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677228432835-1ddc8d9b-d067-4d80-82c1-d63b067d6c25.png#averageHue=%23191919&clientId=ub432d06a-c081-4&from=paste&height=71&id=uaf8564a8&name=image.png&originHeight=107&originWidth=705&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=24585&status=done&style=none&taskId=ud201852c-7855-4553-8543-43f2a63028c&title=&width=470)
<a name="BuuHr"></a>
## phase_6

1. thinking process
```c
phase_6(input)
{
int a1 = 0;  // %r12d
int* input_copy = input; // mov %rsp, %r13
int val; // %eax

while(1)
{
    val = *(input_copy); // 0x0(%r13)
    val = val-1;
    if(val>5)  explode()  // 元素值不得大于6
        
    ++a1; // add $0x1, %r12d
    if(a1 == 6) break; // jmp 95
    int a2 = a1; // mov %r12d, %ebx
    do{   // 65
        val = *(input+a2);
        if(val == *input_copy)
            explode();
        ++a2;
        }while(a2<= 5 ) // 87
    ++input_copy; // add $0x4, %r13
} // 93
/*两个信息：(已验证)
1. 输入字符串中所有元素不大于6
2. 输入字符串中所有元素互不相等 */ 0~6

int* sentry = input+6; // mov 0x18(%rsp), %rsi   95
int* input_copy_2 = input; // %rax
int a3 = 7; // %edx, %ecx
do{
    *(input_copy_2) = a3 - *(input_copy_2);
    ++input_copy_2;
}while(input_copy_2 != sentry)
/* 更新输入字符串所有值为：7-初始值(已证实), 
结合之前的信息，说明此时的输入字符串均不小于1，且只可能存在一个等于1 */
 
int a4 = 0; // 123 %esi  -- index
int a5; // %edx
int a6; // %eax  -- index
offset_166:
if(input[a4] <= 1) // 166  %ecx
{
    a5 = 0x6032d0; // 143
    offset_148:
    *(input+0x20+2*a4) = a5; // 148 [8]:20, [10]:28, [12]:30, [14]:38, [16]:40,[18]:48
                             //   0x6032d0, 0x6032e0  0x6032f0 0x603200 0x603310 0x603320   
    a4 += 4; // add $0x4, %rsi 
    if(a4 ==  24 )
        goto offset_183; // 161 
    else 
        goto offset_166;
}
else  // 均要走这个else， 可能有一个不走这个else -->肯定有一个不走
{
    a6 = 1;  // 171  
    &a5 = 0x6032d0; // 176  这个地址+0x8能多次跳转
    do{ // 130
        a5 = *(&a5 + 0x8) ; // mov 0x8(%rdx),%rdx  链表?
        ++a6; 
    }while(a6 != *(input+a4) ) // 139  (must have 1-6), 2-5, 3-4 , 4-3, 5-2, 6-1, (7-0)
    goto offset_148;         // recorrect: 3-4, 4-3,5-2,6-1,1-6,2-5
} // 181

offset_183：    function: link node in order
int a7 = input[8]; //%rbx 0x20(%rsp)   *(input+ 8) ~ *(input+16) all represent a address
int* input_copy_3 = input+10 // %rax  0x28(%rsp)
int* input_copy_4 = input+20 // %rsi  0x50(%rsp)
a3 = a7; // a3:%rcx
while(1){ // 201
    a5 = *input_copy_3; //a5:%rdx [10][12]...[18][20] 6
    *(a3+0x8) = a5; // 0x8(%rcx)
    input_copy_3 += 2; // 0x8 
    if(input_copy_3 == input_copy_4) break; // 215 
    a3 = a5; // mov %rdx, %rcx
}    //   make  *(a[i-2] + 0x8) = a[i] (i = i+2: 10 12 .. 18)
// 结束时 %rdx = * (input + 18)

*(*(input+18) + 2 ) = 0; // 222   set last node's pointer to nullptr
int a8 = 5; // %ebp
int a9 // %rax 
do
{
 &a9 = *(a7+2); // %rax   initial a7 = input[8]
  a9 = *a9; // mov (%rax), %eax
if(*(*(input+8)) < a9) // cmp %eax, (%rbx) 
    explode();   // 验证是否降序
a7 = *(*(input+8)+2); // mov 0x8(%rbx), %rbx 更新%rbx  
--a8;
}while(a8>0)

}
// over
    
/*inital:
0x14c(0): 332;
0x0a8(1): 168;
0x39c(2): 924;
0x2b3(3): 691
0x1dd(4): 477
0x1bb(5): 443

2->3->4->5->0->1 */


```

2. 我完成phase_6的时间比前五个加起来还多，从第一次反汇编phase_6到彻底搞清楚phase_6各个步骤做了什么并推出答案花的时间可能接近有6，7个小时了，确定了这是一个链表问题，将链表排序并验证。这个phase里很关键的信息就是`0x6032d0`这个地址值，通过查看该地址后24个字的内容，可以看见这里储存了一个含有6个结点的链表，然后根据这个信息分析并反编译汇编代码， 即可发现我们的最终目的是使`0x6032d0`这里的链表降序排列。输入自己推算出的答案，看见终端显示出拆弹成功真的超开心

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677403752602-71565a7a-ae83-4e0e-a0d7-cdd2e3df1fd5.png#averageHue=%23232222&clientId=u54232b82-dfec-4&from=paste&height=165&id=u5a9db9de&name=image.png&originHeight=248&originWidth=1501&originalType=binary&ratio=1.5&rotation=0&showTitle=true&size=164901&status=done&style=none&taskId=u365af322-15ad-46fb-9cfc-245887947ea&title=list%20after%20sort&width=1000.6666666666666 "list after sort")<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677402131273-de3ea8a9-669e-4bf2-8194-cccb235cd58b.png#averageHue=%23282828&clientId=u54232b82-dfec-4&from=paste&height=217&id=ucd4dd2ed&name=image.png&originHeight=325&originWidth=1104&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=146781&status=done&style=none&taskId=u67c0a4b5-d060-40b2-9b3c-921a69962c7&title=&width=736)
<a name="QjpMp"></a>
## secret_phase
![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677404056138-294107ed-6f1c-4477-83c9-44b00041ef4b.png#averageHue=%232a2929&clientId=u54232b82-dfec-4&from=paste&height=152&id=u674c8aa7&name=image.png&originHeight=228&originWidth=1213&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=42994&status=done&style=none&taskId=u89aa5f1c-7b78-46bb-b51c-a2062f218dc&title=&width=808.6666666666666)

1. 发现彩蛋

以上语句说明邪恶博士还给我们留了一手， 拆弹还没彻底完成，这个easter egg在bomb.c中是发现不了的，只能在bomb文件中寻找。CMU给出的writeup给了我们明确的提示，可以用`objdump -t bomb`查看函数的符号表，包括全局变量的名称和所有函数的名称，进而我们可以在符号表中发现secret_phase。<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677404753141-3d41a656-d41d-476c-aae5-e51421f24d6e.png#averageHue=%230b0b0a&clientId=u54232b82-dfec-4&from=paste&height=338&id=u59b20a1e&name=image.png&originHeight=507&originWidth=1706&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=217929&status=done&style=none&taskId=ub07a14e6-ebf4-4769-b55c-e586658a966&title=&width=1137.3333333333333)

2. 怎么触发

1)谁调用了secret_phase：`secret_phase`既然作为一个函数，那么就需要被调用，邪恶博士不会做了炸弹而不接引线，因此我们要在`main`函数中寻找可能调用`secret_base`的语句，既然phase_1到phase_6我们都分析过源码，所以调用语句肯定只能存在`phase_defused`函数中，反汇编`phase_defused`函数，果然发现了调用`secret_phase`的指令<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677404954528-c0e39bd3-077e-49cd-a460-d820f2047ce8.png#averageHue=%232b2a2a&clientId=u54232b82-dfec-4&from=paste&height=488&id=u9e4e339a&name=image.png&originHeight=732&originWidth=1266&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=459111&status=done&style=none&taskId=u6d1b7d59-0bf7-4df3-9948-00a20fc914f&title=&width=844)<br />2）在phase_defused中如何触发：从`main`函数可以看出，bomb文件在每次未触发炸弹而执行完一个phase的时候都会调用一次`phase_defused`。分析phase_defused，该函数当输入字符串表示分隔的数字值时，如果数字个数小于6个，直接返回，对应phase1~phase5；如果数字等于6个，继续执行，对应phase6<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677414713624-83322f4b-2b99-42ce-9152-3c094464743d.png#averageHue=%232a2a29&clientId=u54232b82-dfec-4&from=paste&height=167&id=u4e91d4e7&name=image.png&originHeight=251&originWidth=1753&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=206560&status=done&style=none&taskId=u8107d152-8bbe-44eb-beb6-bd477c6e492&title=&width=1168.6666666666667)<br />接着从地址`0x603870`处读取两个数字，一个字符串<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677414792269-cc61be84-af1a-449f-b88a-efdf5b602450.png#averageHue=%23262626&clientId=u54232b82-dfec-4&from=paste&height=52&id=u54634d3d&name=image.png&originHeight=78&originWidth=676&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=25535&status=done&style=none&taskId=uf1933c57-b4a3-46a2-a583-11eeb6c7623&title=&width=450.6666666666667)<br />经过验证，地址`0x603870`为phase_4阶段输入字符串的开始地址<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677414872028-db9b7aa7-d78c-450a-877d-8d643d89022d.png#averageHue=%23272626&clientId=u54232b82-dfec-4&from=paste&height=52&id=u20d9ba63&name=image.png&originHeight=78&originWidth=763&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=32367&status=done&style=none&taskId=uf4f5ab27-77d8-4b6a-9614-34ea9d69b04&title=&width=508.6666666666667)![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677414887631-8de449af-6eff-4f20-9632-860f0d751f77.png#averageHue=%232b2b2b&clientId=u54232b82-dfec-4&from=paste&height=51&id=u78a64d3f&name=image.png&originHeight=76&originWidth=856&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=31655&status=done&style=none&taskId=u1f45d585-4254-407d-a785-6859f161d5b&title=&width=570.6666666666666)<br />根据后续逻辑，只要在phase_4阶段时输入`"7 0 DrEvil"`即可触发`secret_bomb`<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677415081966-c8dd9474-52be-4ca5-b73b-da79cea387f2.png#averageHue=%232b2a2a&clientId=u54232b82-dfec-4&from=paste&height=289&id=uff04a21c&name=image.png&originHeight=434&originWidth=1193&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=295794&status=done&style=none&taskId=uc3d47c14-4fd2-4066-8097-d303800fa51&title=&width=795.3333333333334)<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677415023030-75fb6b08-160a-41a7-ac0c-2cd054c806ee.png#averageHue=%23272727&clientId=u54232b82-dfec-4&from=paste&height=53&id=u647b3556&name=image.png&originHeight=79&originWidth=501&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=19252&status=done&style=none&taskId=ubfabe50b-c88f-4d79-8759-413c728c17a&title=&width=334)<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677415142283-f37e926f-a289-4c18-9170-346e631d561e.png#averageHue=%232a2a2a&clientId=u54232b82-dfec-4&from=paste&height=361&id=uc5b1fa4e&name=image.png&originHeight=542&originWidth=1158&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=228864&status=done&style=none&taskId=u4bbc5a61-2cb2-48b7-95b7-d8b064cb1ad&title=&width=772)

3. 终章：拆解secret_phase

1）反编译secret_base
```c
secret_phase()
{
    int input_2;// (%rdi)
    &input_2 = read_line(); //  %rdi
    
    int a1 = 0xa; // %edx
    int a2 = 0x0; // %esi
    long int input_num_1 = strtol(input_2); // %rax
    long int input_num_2 = input_num_1 // %rbx
    input_num_1 -= 1; 
    if(input_num_1 > 0x3e8 /*1000*/) explode();
    // 输入的数字字符串 值小于 1001
    a2 = input_num_2;// mov %ebx, %esi  
    &input_2 = 0x6030f0;
    int ret = fun7(&input_2,a2,input_num_1); // ret_value: %rax
    
    if(ret == 0x2)
        defused();
    else
        explode(); 
}

int fun7(&input_2, a2, input_num_1)
{
    if(&input_2 == 0x0) return -1; // avoid endless recursion
    int a3 = *(&input_2);  // 9 %edx   initial a3 = 24
    if(a3 <= a2) goto offset_28; // 13  a2是输入值 

    // a3 > a2
    input_2 = *(&input_2 + 0x8); // +2  turn left
    input_num_1 = fun7(&input_2, a2, input_num_1); // 19

    input_num_1 *= 2; // input_num_q is 1 here
    return input_num_1;

    offset_28:
    input_num_1 = 0;
    if(a3 == a2) return input_num_1;	

    // a3 < a2
    input_2 = *(&input_2 + 0x10); // +4   turn right
    input_num_1 = fun7(&input_2, a2, input_num_1); // 0
    input_num_1 = 2*input_num_1 + 1;  // 1
    return input_num_1;
}

```
2）有了phase_6的经验，我在查看了特殊地址`0x6030f0`的内容后很快就反应出这又是链表相关的问题，扩大查看的地址范围后，我发现地址`0x6030f0`为起点进行索引，后面120个字大小的地址空间，表示一个高度为3，结点大小为8 words的二叉搜索树；再结合`secret_phase`的逻辑，在子函数`fun7`返回值为2时defuse，经过分析，`fun7`这个递归函数，在最后三次递归时为turn left(`&input_2 + 0x8`）->turn right(`&input_2 + 0x10`) -> return 0时才能保证最终返回值为2，画出二叉树后，可以很清楚的看到，满足这样三步走的有且仅有子结点22 （子结点22再左走一步到叶子结点20，只是重复了一遍return 0，也满足要求，因此20也是最终答案，）<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677484445488-99b96bb8-8026-406a-8606-b6ed814389d7.png#averageHue=%232b2b2b&clientId=u289fcf2a-d904-4&from=paste&height=565&id=u5030ad8b&name=image.png&originHeight=848&originWidth=1530&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=595091&status=done&style=none&taskId=uf7e602a3-1dfa-4402-88da-6b6d06e26db&title=&width=1020)<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677484586007-34081aec-ae5a-409a-9270-7503f23d697b.png#averageHue=%23fefefe&clientId=u289fcf2a-d904-4&from=paste&height=268&id=u3886e51a&name=image.png&originHeight=321&originWidth=613&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=45328&status=done&style=none&taskId=uc94db6c6-0837-40f5-8324-986eeadfa19&title=&width=511.66668701171875)<br />3) 至此，整个bomblab就结束了，花费了我十多个小时完成了这个lab还是很值得的，伴随这一个又一个defuse，成就感是满满的，哈哈哈<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677484822762-1f6d54b5-8a8f-405e-ab5b-b3de5c095440.png#averageHue=%232d2d2d&clientId=u289fcf2a-d904-4&from=paste&height=309&id=ua22fc755&name=image.png&originHeight=463&originWidth=1657&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=276450&status=done&style=none&taskId=ua2ea40a4-48b8-410d-a36d-c5de36dd026&title=&width=1104.6666666666667)

---

<a name="SLpu6"></a>
# lab3 attacklab
<a name="UbCO7"></a>
## 前提

1. 注意！该实验在ubuntu22.04上是没法做的，任何形式的攻击都会引发segment fault，建议用ubuntu22.04的同学跟博主一样另外再安装一个ubuntu20.04

 博主就是在这踩了坑，一直以为操作有问题，后来带着实验的执行环境google了一下才发现这个问题

2. exploit string用工具`hex/2raw`构造并传递给字符串，该工具要求输入的每个字节用2-digit 十六进制数表示，两个字节之间用空格分开，输出对应的二进制序列。

writeup的附录A介绍了多种`hex/2raw`接受输入字符串并传递给ctarget的多种方式，我习惯用：<br />`./hex2raw < exploit_string.txt | ./ctarget -q`<br />这条命令将`exploit_string.txt`作为`hex2raw`的输入，并建立管道将`hex2raw`的输出传输到`./ctarget`中，-q命令选项表示不向评分服务器发送信息，如果你是CMU的可以不用这个选项（哈哈哈）。该工具应该只接受文件流的输入，如果在终端直接执行`./hex2raw`那么将无法中止输入
<a name="Kk3w5"></a>
## phase_1

1. 反汇编`ctarget`：可用`objdump -d ctarget`获取ctarget的汇编版本，为了方便，我们直接将输出定向到一个asm文件中

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677585087533-3d1cfcba-4dd9-41f4-8cc8-bb4c35b8674f.png#averageHue=%231b1b1b&clientId=u2c7b2c0d-00ea-4&from=paste&height=40&id=u07c104d6&name=image.png&originHeight=60&originWidth=1223&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=26128&status=done&style=none&taskId=u6e9b8aa5-d406-4587-b032-e270697a03a&title=&width=815.3333333333334)<br />这样我们每次查看ctarget的汇编版本时，就不用重新反汇编一次了

2. `vim dis_ctarget.asm`查看`getbuf`函数的汇编代码，可以看见它的栈帧长度为0x28（40）个字节，因此要覆盖在这之上的调用者`test`函数的ret地址，只需在缓冲区写入0x30（48）个字节即可；查看`touch1`函数，它的地址在`0x004017c0`处，因此要在exploit_string的最后8个字节上填入c0 17 40 00（little-endian）

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677585873581-353e1114-4253-4b23-aceb-6ba85c12e660.png#averageHue=%231c1c1c&clientId=u2c7b2c0d-00ea-4&from=paste&height=318&id=ub151bf36&name=image.png&originHeight=477&originWidth=1375&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=178834&status=done&style=none&taskId=u661b7e64-355d-4240-a2ac-0d48718019c&title=&width=916.6666666666666)

3. `vim phase_1.txt`输入

 $\begin{matrix}
  &00  &00  &00  &00  &00  &00  &00 &00 \\
  &00 &00  & 00 &00  &00  &00  &00 &00 \\
  &00  &00  &00  &00 &00  &00  &00  &00\\
  &00  &00  &00  &00  &00  &00  &00  &00\\
  &00  &00  &00  &00  &00  &00  &00  &00\\
  &c0 &17  &40  &00  &00  &00  &00
\end{matrix}$<br />最后留了一个字节以供gets放入' \n ' (不放也没事，执行touch1能直接退出程序)。最后一行result显示PASS就说明攻击生效了
![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677586525442-cc13fc97-7de2-4bc6-90c7-bdb9356cc9b4.png#averageHue=%231c1c1c&clientId=u2c7b2c0d-00ea-4&from=paste&height=196&id=u93bb9ade&name=image.png&originHeight=294&originWidth=1896&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=129168&status=done&style=none&taskId=u503e0466-2b33-4b30-9a9e-f21980d78e7&title=&width=1264)
<a name="xCSRi"></a>
## phase_2

1. 编写汇编代码，转化为字节码：`vim asb.s`，输入以下汇编代码（push可直接压入地址，不必先放入寄存器）

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677637642575-745a9de7-6e49-4ef0-9f44-46dbe3cfb8a0.png#averageHue=%23232323&clientId=u7f8a8b62-e84b-4&from=paste&height=62&id=uc88e8483&name=image.png&originHeight=93&originWidth=380&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=15349&status=done&style=none&taskId=u1fe3d97e-2ee2-4e3f-b2f0-921ac53df4e&title=&width=253.33333333333334)<br />line1将`cookie`值赋给`%rdi`传参给`touch2`；ine2将2`touch2`的地址压入栈中，目的在于在`ret`指令执行后，从栈中弹出并赋值给`%rip`的返回地址是`touch2`的地址<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677637347348-81a97333-5ab5-4766-b689-e0a40d50a9b1.png#averageHue=%23131313&clientId=u7f8a8b62-e84b-4&from=paste&height=221&id=u494680d1&name=image.png&originHeight=331&originWidth=1165&originalType=binary&ratio=1.5&rotation=0&showTitle=true&size=130023&status=done&style=none&taskId=u8d81b4ca-fd2a-4ce9-ba46-d1e09ded02c&title=%E8%8E%B7%E5%8F%96touch2%E7%9A%84%E5%9C%B0%E5%9D%80&width=776.6666666666666 "获取touch2的地址")<br />writeup的附录B提示我们将gcc与objdump结合使用产生指令序列的字节码<br />`gcc -c asb.s`<br />`objdump -d asb.o > asb.d`<br />这样我们就得到了指令序列的字节码，可用于构造exploit_string<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677638192080-ecafc66a-645a-4bf0-a9d2-af3a00412381.png#averageHue=%23191918&clientId=u7f8a8b62-e84b-4&from=paste&height=203&id=u9041b219&name=image.png&originHeight=304&originWidth=962&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=84296&status=done&style=none&taskId=ue5e430b5-0a7a-42c3-8791-f51017acec7&title=&width=641.3333333333334)

2. 构造`phase_2.txt`，因为`asb.o`中的代码本身就已经逆序，所以直接输入即可；用于覆盖`test`栈帧中返回地址的值可由`%rsp`的值推算出（取决于你将字节码放在缓冲区的位置），这里为了方便， 我将字节码放在了缓冲区的开头，则用于覆盖的地址就是`%rsp`的值

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677591555601-28a75db3-4efc-445a-bd75-67d6722d57ee.png#averageHue=%231d1d1d&clientId=u2c7b2c0d-00ea-4&from=paste&height=359&id=pvcAu&name=image.png&originHeight=539&originWidth=1175&originalType=binary&ratio=1.5&rotation=0&showTitle=true&size=188389&status=done&style=none&taskId=u8ffbde5e-78e3-433e-a1a6-dfa4742b694&title=%E8%8E%B7%E5%8F%96%E6%A0%88%E9%A1%B6%E5%80%BC&width=783.3333333333334 "获取栈顶值")<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677638376139-5fb21190-4237-424f-a168-1c204bce6ef7.png#averageHue=%231b1b1b&clientId=u7f8a8b62-e84b-4&from=paste&height=406&id=ud656f730&name=image.png&originHeight=609&originWidth=806&originalType=binary&ratio=1.5&rotation=0&showTitle=true&size=117050&status=done&style=none&taskId=u39e09168-0d44-4223-a419-2cad498a46f&title=phase_2_exploit_string&width=537.3333333333334 "phase_2_exploit_string")

3. 攻击生效

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677638454464-852c44b4-14f9-43fe-8e9f-a927c267b260.png#averageHue=%230b0b0b&clientId=u7f8a8b62-e84b-4&from=paste&height=233&id=ua99fc494&name=image.png&originHeight=349&originWidth=1225&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=146341&status=done&style=none&taskId=uba333293-f36a-4b4a-bd6b-7ab4d63bd03&title=&width=816.6666666666666)
<a name="TVVPU"></a>
## phase_3

1. 与`phase_2`很像，但这次要传递的参数是字符串形式的`cookie`。因为`getbuf`的栈帧在函数结束后就被操作系统收回，且会被后续函数调用占用，因此我们将字符串`cookie`放在`test`函数的栈帧中，地址`0x5561dca8`；获取`touch3`函数的地址，编写攻击代码

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677673769317-083e3c3d-3eb7-4716-8b34-154511f96d34.png#averageHue=%231c1c1c&clientId=ub6cccc71-6474-4&from=paste&height=236&id=ufe6c6401&name=image.png&originHeight=354&originWidth=1183&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=123850&status=done&style=none&taskId=ue426e205-3b8c-42f1-a2ca-516774edd68&title=&width=788.6666666666666)<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677678328785-d2f2582c-e25c-484b-83d8-4a0a2595ab07.png#averageHue=%23060606&clientId=ub6cccc71-6474-4&from=paste&height=61&id=u15b6d558&name=image.png&originHeight=91&originWidth=347&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=11449&status=done&style=none&taskId=u1ce98f2a-043c-4c00-b0a0-20b0f14e918&title=&width=231.33333333333334)

2. `ascii -ax`查看十六进制形式的ascii-table，得出`"59b997fa"`的ascii形式为`35 39 62 39 39 37 66 61`

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677678551264-8b3b6a28-3390-45cb-bbc6-b20f241eb472.png#averageHue=%231d1d1d&clientId=ub6cccc71-6474-4&from=paste&height=247&id=u95244bf5&name=image.png&originHeight=370&originWidth=1204&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=116378&status=done&style=none&taskId=u6e6beaa6-64b0-4c0c-ba41-3a88510ea43&title=&width=802.6666666666666)

3. 覆盖返回地址和test栈帧，写入攻击代码的地址和字符串`cookie`

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677678755332-3ea51646-6c2b-4212-8f6a-d6fe5551fa9a.png#averageHue=%23202020&clientId=ub6cccc71-6474-4&from=paste&height=210&id=u5caf20c9&name=image.png&originHeight=315&originWidth=871&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=61586&status=done&style=none&taskId=uc183fab2-b53c-4109-9912-d5f30dc3d02&title=&width=580.6666666666666)

4. 攻击生效

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677678782689-4f003174-6f36-4200-87cd-d46e586d9907.png#averageHue=%231d1d1d&clientId=ub6cccc71-6474-4&from=paste&height=235&id=u145918cd&name=image.png&originHeight=353&originWidth=1184&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=131718&status=done&style=none&taskId=u08615a2d-ec29-45b1-bc0c-7f9a93e2212&title=&width=789.3333333333334)
<a name="UnHwd"></a>
## phase_4
确定攻击方案：`rtarget`由于具备栈随机化，以及栈内代码不可执行这两个属性，所以如果要在栈中插入攻击代码将面临两个问题：1）用于指向攻击代码的地址无法确定：因为我们要把攻击代码放入栈中，但栈的位置不确定，进而我们也无法创建指向攻击代码的指针  2）攻击代码无法执行，因为栈被标注为不可执行。writeup给了我们明确的提示，既然我们无法插入自己的攻击代码，那么就用`ctarget`自身的代码实现攻击，具体做法是通过地址跳转，截取`ctarget`的部分代码用作攻击代码；`gadget`指的是几条指令后跟着一条ret指令的程序片段，如果把函数栈设置为一连串`gadget`的地址，那么一旦执行其中一个`gadget`，`ret`指令就会不断的从栈中弹出新的`gadget`的地址赋给`%rip`,由此引发多个`gadget`的连续执行（注意函数调用栈地址的随机化跟程序代码的地址无关）

1. `cookie`的值不可能从`rgadget`中找到，需要我们自己放到栈中，如同`phase_3`一样，放的位置不能是`getbuf`的缓冲区，因此我们将其放到`test`的栈帧中；接着要实现`mov $0x59b997fa,%rdi`，需执行`popq %rdi`，根据writeup的参照表，先在`start_farm`和`end_farm`之间寻找`5f`，结果没有，但是找到了`58 90`,地址为`0x004019ab`，这代表`popq %rax  nop`，因此我们需要用`%rax`作介质传递`cookie`给`%rdi`，而在farm中我们也确实找到了`movq %rax, %rdi：48 89 c7`，地址为`0x004019c5`，一共用到了两个`gadget`

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677748308138-674aa437-9522-414c-afcf-828967ad2c1b.png#averageHue=%231f1f1f&clientId=u0689b11d-a2d1-4&from=paste&height=82&id=ueb5eeaef&name=image.png&originHeight=123&originWidth=1061&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=44128&status=done&style=none&taskId=u3043295b-c67b-407d-81b2-642907b3b41&title=&width=707.3333333333334)<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677748250489-e3dcf01c-ae26-4997-a969-4efde7d2c835.png#averageHue=%231c1b1b&clientId=u0689b11d-a2d1-4&from=paste&height=163&id=ube7f5b3e&name=image.png&originHeight=244&originWidth=1060&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=73997&status=done&style=none&taskId=ub3c3a582-4fc1-4e85-ac8e-de93a3fa7d2&title=&width=706.6666666666666)

2. 按照下图逻辑编写phase_4，可实现攻击。自此attacklab就结束了，第一次感觉自己当了一名hacker，感觉很棒

![yuque_diagram.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677750944719-6ccf095c-ffce-4020-8cb6-f5b0f0fde9f8.png#averageHue=%2310222d&clientId=u0689b11d-a2d1-4&from=ui&height=546&id=u0eb7edee&name=yuque_diagram.png&originHeight=1110&originWidth=380&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=38484&status=done&style=none&taskId=uf668df10-5035-4532-8f4f-6e2ef500940&title=&width=187)![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677751046005-10305a9e-443a-4de9-9d53-344ef204db84.png#averageHue=%23202020&clientId=u0689b11d-a2d1-4&from=paste&height=186&id=u3879cf7f&name=image.png&originHeight=279&originWidth=762&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=62095&status=done&style=none&taskId=uef71dd0c-5925-4f87-8c3b-ca049535c44&title=&width=508)<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1677750954828-918501d5-682b-4638-ac25-f66bced64fb7.png#averageHue=%231c1c1c&clientId=u0689b11d-a2d1-4&from=paste&height=235&id=u61b7152b&name=image.png&originHeight=353&originWidth=1387&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=128770&status=done&style=none&taskId=u3e63c29c-34df-412e-b6ae-c66bfaa71c6&title=&width=924.6666666666666)


