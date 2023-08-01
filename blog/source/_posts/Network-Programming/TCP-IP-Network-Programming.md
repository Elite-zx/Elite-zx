---
title: "TCP-IP-Network-Programming[尹圣雨]"
date: 2023/07/08
categories:
- Network-Programming
tags: 
- Adanvced
---
# Preamble
花了2周的时间(中途抽时间出来突击了期末考试)学完了这本书，例子也都复现了1遍。这本书作为网络编程初学者的第1本书，会是一个很好的选择

# 1. 开始网络编程
## 1.1 Hello world！
网络编程中服务器端套接字创建过程可整理如下（类比打电话）：
1. 第⼀步：调⽤ socket 函数创建套接字（安装电话）
2. 第⼆步：调⽤ bind 函数分配IP地址和端口号（分配电话号码）
3. 第三步：调⽤ listen 函数转换为可接受请求状态（连接电话线，等待接听电话）
4. 第四步：调⽤ accept 函数受理套接字请求（拿起话筒接听电话）
通过socket函数获取一个socket(在OS看来是文件)的文件描述符
```c
#include <sys/socket.h>
int socket (int domain , int type , int protocol );
/*
成功时返回⽂件描述符，失败时返回-1
domain: 套接字中使⽤的协议族（Protocol Family ）
type: 套接字数据传输的类型信息，分为面向连接的SOCK_STREAM和面向消息的SOCK_DGRAM
protocol: 计算机间通信中使⽤的协议信息,通常传递0
*/
```
IPV4地址用内置结构体sockaddr_in表示：
```c
struct sockaddr_in
{
 sa_family_t sin_family ; // 地址族（Address Family ）
 uint16_t sin_port ; //16 位 TCP/UDP 端口号
 struct in_addr sin_addr ; //32 位 IP 地址， 可以使用INADDR_ANY自动获取本机的IP地址
 char sin_zero [8]; // 不使⽤
};

```
其中的in_addr结构体表示一个32位IP地址
```c
struct in_addr
{
 in_addr_t s_addr ; //32 位IPV4 地址， in_addr_t是uint32_t的别名
}

```
为套接字绑定分配网络地址：
为socket绑定网络地址，等同于以下含义：
$$请把传入IP ***, 端口***的数据传给我！$$
这通过bind函数实现
```c
#include <sys/socket.h>
int bind (int sockfd , struct sockaddr *myaddr , socklen_t addrlen );
// 成功时返回0，失败时返回-1
```
一个服务器端套接字初始化的一般过程：
```c
int main(int argc, char* agrv[]) {
  int serv_sock;
  struct sockaddr_in serv_addr;
  char* serv_port = "9190";

  /*Create a server-side socket (listening socket)*/
  serv_sock = socket(PF_INET, SOCK_STREAM, 0);

  /*Address information initialization*/
  memset(serv_addr, 0, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_port = htons(atoi(serv_port));
  serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);

  /*allocate Address information for server*/
  bind(serv_sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr));
}
```

### 1.1.1 hello_server.c
```c
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>
void error_handling(char *message);

int main(int argc, char *argv[]) {
  int serv_sock;
  int clnt_sock;

  struct sockaddr_in serv_addr;
  struct sockaddr_in clnt_addr;
  socklen_t clnt_addr_size;

  char message[] = "Hello World!";

  if (argc != 2) {
    printf("Usage : %s <port>\n", argv[0]);
    exit(1);
  }
  //调用 socket 函数创建套接字：指明协议族（PF: Protocol Family），数据传输类型，协议信息
  serv_sock = socket(PF_INET, SOCK_STREAM, 0);
  if (serv_sock == -1) error_handling("socket() error");

  memset(&serv_addr, 0, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  serv_addr.sin_port = htons(atoi(argv[1]));
  //调用 bind 函数分配ip地址和端口号
  if (bind(serv_sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) == -1)
    error_handling("bind() error");
  //调用 listen 函数将套接字转为可接受连接状态
  if (listen(serv_sock, 5) == -1) error_handling("listen() error");

  clnt_addr_size = sizeof(clnt_addr);
  //调用 accept
  //函数受理连接请求。如果在没有连接请求的情况下调用该函数，则不会返回，直到有连接请求为止
  clnt_sock = accept(serv_sock, (struct sockaddr *)&clnt_addr, &clnt_addr_size);
  if (clnt_sock == -1) error_handling("accept() error");
  //稍后要将介绍的 write 函数用于传输数据，若程序经过 accept
  //这一行执行到本行，则说明已经有了连接请求
  write(clnt_sock, message, sizeof(message));
  close(clnt_sock);
  close(serv_sock);
  return 0;
}

void error_handling(char *message) {
  fputs(message, stderr);
  fputc('\n', stderr);
  exit(1);
}
```

### 1.1.2 hello_client.c
```c
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>
void error_handling(char *message);

int main(int argc, char *argv[]) {
  int sock;
  struct sockaddr_in serv_addr;
  char message[30];
  int str_len;

  if (argc != 3) {
    printf("Usage : %s <IP> <port>\n", argv[0]);
    exit(1);
  }
  //创建套接字，此时套接字并不马上分为服务端和客户端。如果紧接着调用 bind,listen
  //函数，将成为服务器套接字 如果调用 connect 函数，将成为客户端套接字
  sock = socket(PF_INET, SOCK_STREAM, 0);
  if (sock == -1) error_handling("socket() error");

  memset(&serv_addr, 0, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = inet_addr(argv[1]);
  serv_addr.sin_port = htons(atoi(argv[2]));
  //调用 connect 函数向服务器发送连接请求
  if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) == -1)
    error_handling("connect() error!");

  str_len = read(sock, message, sizeof(message) - 1);
  if (str_len == -1) error_handling("read() error!");

  printf("Message from server : %s \n", message);
  close(sock);
  return 0;
}

void error_handling(char *message) {
  fputs(message, stderr); 
  fputc('\n', stderr);
  exit(1);
}
```

### 1.1.3 result
![](attachment/e79dc4d57fe2ecb05125cec584f01393.png)
![](attachment/c939d2e059e8dcc4635e7b8244e90bcb.png)
## 1.2 基于 Linux 的⽂件操作
对linux而言，everthing is a file, 其中也包含socket。文件描述符是操作系统分配给文件的一个整数，该整数只不过是为了方便称呼文件（而不用称呼冗长的文件名）而赋予的一个编号而已
### 1.2.1 low_open.c
```c
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
void error_handling(char *message);

int main() {
  int fd;
  char buf[] = "Let's go!\n";
  // O_CREAT | O_WRONLY | O_TRUNC
  // 是文件打开模式，将创建新文件，并且只能写。如存在 data.txt
  // 文件，则清空文件中的全部数据。
  //这里使用了`|`运算符将多个选项参数组合在一起。这是因为 open 系统调用的选项参数是一个位掩码，每个选项都有一个对应的位标志，可以使用位运算符组合多个选项。
  fd = open("data.txt", O_CREAT | O_WRONLY | O_TRUNC);
  if (fd == -1) error_handling("open() error!");
  printf("file descriptor: %d \n", fd);
  // 向对应 fd 中保存的文件描述符的文件传输 buf 中保存的数据。
  if (write(fd, buf, sizeof(buf)) == -1) error_handling("write() error!");
  close(fd);
  return 0;
}

void error_handling(char *message) {
  fputs(message, stderr);
  fputc('\n', stderr);
  exit(1);
}
```
### 1.2.2 low_close.c
```c
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#define BUF_SIZE 100
void error_handling(char *message);

int main() {
  int fd;
  char buf[BUF_SIZE];

  fd = open("data.txt", O_RDONLY);
  if (fd == -1) error_handling("open() error!");
  printf("file descriptor: %d \n", fd);

  if (read(fd, buf, sizeof(buf)) == -1) error_handling("read() error!");
  printf("file data: %s", buf);
  close(fd);
  return 0;
}
void error_handling(char *message) {
  fputs(message, stderr);
  fputc('\n', stderr);
  exit(1);
}
```
### 1.2.3 result
![](attachment/65120f99cd74c21fbc090c07ce880147.png)
![](attachment/1f5ae1ea3f189e83c16a0a10d9e4e9ed.png)
# 2. 套接字类型与协议设置
## 2.1 没有数据边界的SOCK_STREAM
SOCK_STREAM可作为socket的第2个参数表示套接字类型(type)，具体来说，就是套接字的数据传输方式。该类型是tcp套接字的数据传输方式，没有数据边界，具体来说就是，发送方和接受方的动作不必一致，发送方有多次发送的动作(write)，接受方可能只有一次接受的动作(read)。接受方有缓存，它收到数据后不必立马调用read读取，而是先存入缓存
### 2.1.1 tcp_client
```c
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>
void error_handling(char *message);

int main(int argc, char *argv[]) {
  int sock;
  struct sockaddr_in serv_addr;
  char message[30];
  int str_len = 0;
  int idx = 0, read_len = 0;

  if (argc != 3) {
    printf("Usage : %s <IP> <port>\n", argv[0]);
    exit(1);
  }
  //创建套接字，此时套接字并不马上分为服务端和客户端。如果紧接着调用 bind,listen
  //函数，将成为服务器套接字 如果调用 connect 函数，将成为客户端套接字
  sock = socket(PF_INET, SOCK_STREAM, 0);
  if (sock == -1) error_handling("socket() error");

  memset(&serv_addr, 0, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = inet_addr(argv[1]);
  serv_addr.sin_port = htons(atoi(argv[2]));
  //调用 connect 函数向服务器发送连接请求
  if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) == -1)
    error_handling("connect() error!");

  // 一次读取一个字节，读到文件末尾时，read返回0，此时跳出while
  while (read_len = read(sock, &message[idx++], 1)) {
    if (read_len == -1) error_handling("read() error!");

    str_len += read_len;
  }
  printf("Message from server : %s \n", message);
  printf("Function read call count: %d \n", str_len);
  close(sock);
  return 0;
}

void error_handling(char *message) {
  fputs(message, stderr);
  fputc('\n', stderr);
  exit(1);
}
```
### 2.1.2 result
![](attachment/d83ad1d3f59ef51512948c572642b689.png)
# 3. 地址族与数据序列
## 3.1 网络字节序
鉴于各计算机可能存在内存字节序不同的情况（大端，小端），为避免网络数据传输中受到各主机字节序不统一的影响，统一规定网络传输数据时使用大端序列（又叫网络字节序，高字节低地址），具体来说，高字节在低地址。因此在执行网络传输之前，要先对数据进行大端格式化，这个过程是自动的，在实际网络传输过程中，无需手动执行转换
使用以下函数可实现主机字节序和网络字节序的手动转换
```c
unsigned short htons (unsigned short );// port number to network (short type)
unsigned short ntohs (unsigned short ); // reverse
unsigned long htonl (unsigned long ); // host to network (long type)
unsigned long ntohl (unsigned long ); // reverse 
```
### 3.1.1 endian_conv.c
```c
#include <arpa/inet.h>
#include <stdio.h>
int main(int argc, char *argv[]) {
  unsigned short host_port = 0x1234;
  unsigned short net_port;
  unsigned long host_addr = 0x12345678;
  unsigned long net_addr;

  net_port = htons(host_port);  //转换为网络字节序
  net_addr = htonl(host_addr);

  // %#x中的#x表示以16进制输出数据并在开头加上0x,同理还有8进制的%#o
  printf("Host ordered port: %#x \n", host_port);
  printf("Network ordered port: %#x \n", net_port);
  printf("Host ordered address: %#lx \n", host_addr);
  printf("Network ordered address: %#lx \n", net_addr);

  return 0;
}
```
### 3.1.2 result
可见我的AMD系列电脑的内存遵循小端序，大端格式化后数据字节逆序
![](attachment/87ef81c928890f54ce20d2fffdb73ed8.png)
## 3.2 IP地址：字符串到32位数据
表示IPv4地址的结构体sockaddr_in的IP地址字段接受一个32位的整型数据，而我们熟知的ip地址表示方式是点分十进制的字符串形式，因此就出现了ip地址由字符串到32位整数型数据之间进行转换的需求，该需求可以使用以下函数完成
### 3.2.1. inet_addr函数
该函数**将字符串形式的ip地址转化为32位整数型数据**，并提供差错检测(一个字节不超过255)
```c
#include <arpa/inet.h>
in_addr_t inet_addr (const char *string );
// 成功时返回 32 位大端序整数型筒 失败 返回 INADOR-NONE
```
示例：
```c
#include <stdio.h>
#include <arpa/inet.h>
int main(int argc, char *argv[])
{
    char *addr1 = "1.2.3.4";
    char *addr2 = "1.2.3.256"; // 256 will incur error

    unsigned long conv_addr = inet_addr(addr1);
    if (conv_addr == INADDR_NONE)
        printf("Error occured! \n");
    else
        printf("Network ordered integer addr: %#lx \n", conv_addr);

    conv_addr = inet_addr(addr2);
    if (conv_addr == INADDR_NONE)
        printf("Error occured! \n");
    else
        printf("Network ordered integer addr: %#lx \n", conv_addr);
    return 0;
}
```
结果：
![](attachment/941c48be404b3f47f30caff8f5d00ad0.png)
### 3.2.2. inet_aton函数
inet_aton较之inet_addr函数，能够**自动把生成的ip地址填入参数sockaddr_in的IP地址字段**中。`aton`是"**ASCII to Network**"的缩写，表示将ASCII码表示的IP地址转换为网络字节序的二进制形式
```c
#include <arpa/inet.h>
int inet_aton (const char *string , struct in_addr *addr );
/*
成功时返回 1 ，失败时返回 0
string: 含有需要转换的IP 地址信息的字符串地址值
addr: 将保存转换结果的 in_addr 结构体变量的地址值
*/
```
示例
```c
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
void error_handling(char *message);

int main(int argc, char *argv[]) {
  char *addr = "127.232.124.79";
  struct sockaddr_in addr_inet;

  if (!inet_aton(addr, &addr_inet.sin_addr))
    error_handling("Conversion error");
  else
    printf("Network ordered integer addr: %#x \n", addr_inet.sin_addr.s_addr);// 验证地址是否正确填入IPv4结构体
  return 0;
}

void error_handling(char *message) {
  fputs(message, stderr);
  fputc('\n', stderr);
  exit(1);
}
```
结果
![](attachment/c6f0ae89aedb08c97f94c9320cd94f42.png)
### 3.2.3. inet_ntoa
该函数**将32位整数型IP地址转换为点分十进制的字符串格式**返回，返回的字符串存储在该函数内部申请的内存空间（静态变量，该函数具有不可重入性）中，因此再次调用该函数会覆盖该空间。所以该函数的返回值应该复制到其他内存空间以保存。`ntoa`是"**Network to ASCII**"的缩写，表示将网络字节序的二进制形式的IP地址转换为ASCII码表示的点分十进制形式
```c
#include <arpa/inet.h>
char *inet_ntoa (struct in_addr adr );
```
示例
```c
#include <arpa/inet.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
  struct sockaddr_in addr1, addr2;
  char *str_ptr;
  char str_arr[20];

  addr1.sin_addr.s_addr = htonl(0x1020304);
  addr2.sin_addr.s_addr = htonl(0x1010101);
  //把addr1中的结构体信息转换为字符串的IP地址形式
  str_ptr = inet_ntoa(addr1.sin_addr);
  strcpy(str_arr, str_ptr);  // store
  printf("Dotted-Decimal notation1: %s \n", str_ptr);

  inet_ntoa(addr2.sin_addr);
  printf("Dotted-Decimal notation2: %s \n", str_ptr);
  printf("Dotted-Decimal notation3: %s \n", str_arr);
  return 0;
}
```
结果
![](attachment/6030c9054b8a2ba171683990a4cc0bc3.png)
# 4. 基于TCP的服务器端/客户端（1）
![](attachment/e16e56e5ac6d8bbc47e01030ab13f767.png)
## 4.1 listen函数：进入等待连接请求状态
```c
#include <sys/socket.h>
int listen (int sockfd , int backlog );
// 成功时返回0，失败时返回-1
//sock: 希望进⼊等待连接请求状态的套接字⽂件描述符，传递的描述符套接字参数称为服务端套接字
//backlog: 连接请求等待队列的⻓度，若为5，则队列⻓度为5，表⽰最多使5个连接请求进⼊队列 

```
在chapter1，我们已经讲解了socket函数和bind函数，此时我们的服务端已经有了一个接受指定端口的套接字。现在我们用listen函数让这个socket进入监听状态，具体来说，就是变成welcoming socket（该书称之为服务器端套接字）以便可以**接收客户端的连接请求**，同时能在服务器多个请求到达时创建**连接请求等待队列**(等候室，由第2个参数指定大小)。形象的来说，listen函数就是给socket这个大门安了一个门岗，使得socket能够管理到达的连接请求，并响应。（当服务端的监听队列已满且无法处理新的连接请求时，客户端与服务端的连接会进入半连接状态，也称为 **SYN_RCVD**（SYN Received）状态，表示3次tcp握手已完成）
![](attachment/3667d4a5d00801b91a8355208f05b5f6.png)
## 4.2 accept函数：响应请求连接
```c
#include <sys/socket.h>
int accept (int sockfd , struct sockaddr *addr , socklen_t *addrlen );
/* 
成功时返回⽂件描述符，失败时返回-1
sock: 服务端套接字的⽂件描述符
addr: 保存发起连接请求的客⼾端地址信息的变量地址值
addrlen: 的第⼆个参数addr 结构体的⻓度，但是存放有⻓度的变量地址。
*/
```
服务器端按序处理连接请求，我们使用**accept函数受理等待队列中的客户端连接请求**。该函数会**自动创建另一个套接字与客户端自动建立连接**并处理后续的数据传输（TCP中套接字是一一对应的关系）。调用accept函数时如果队列为空，那么此时accept函数陷入阻塞状态(不会返回)，直到有连接请求
为什么需要额外创建一个套接字呢？welcoming socket还要继续保留着继续接收连接请求（总不能把门岗调走处理事务吧）
![](attachment/d19f49855408aee2b43545cefe58a4f0.png)
## 4.3. connect函数：客户端发起连接请求
```c
#include <sys/socket.h>
int connect (int sock , struct sockaddr *servaddr , socklen_t addrlen );
/*
成功时返回0，失败返回-1
sock: 客⼾端套接字⽂件描述符
servaddr: 保存⽬标服务器端地址信息的变量地址值
addrlen: 以字节为单位传递给第⼆个结构体参数 servaddr 的变量地址⻓度
*/
```
客户端调用connect函数提供目的服务器的地址(serv_addr)以向目的服务器（该服务器必须已进入监听状态）发起连接请求。客户端的IP地址和端口在调用connect函数时由操作系统自动分配（而无需bind显式的指定）。服务端接收了连接请求后（指的是请求加入了服务端的请求队列，而不是指accept响应），connect函数返回，因此connect返回后会等待服务端受理(accept)已加入等待队列的请求
## 4.4 迭代回声服务器端/客户端
在单线程进程模式下，服务器同一时间只能处理服务于一个客户端
### 4.4.1. echo_server
```c
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#define BUF_SIZE 1024
void error_handling(char *message);

int main(int argc, char *argv[]) {
  int serv_sock, clnt_sock;
  char message[BUF_SIZE];
  int str_len, i;

  struct sockaddr_in serv_adr, clnt_adr;
  socklen_t clnt_adr_sz;

  if (argc != 2) {
    printf("Usage : %s <port>\n", argv[0]);
    exit(1);
  }

  serv_sock = socket(PF_INET, SOCK_STREAM, 0);
  if (serv_sock == -1) error_handling("socket() error");

  memset(&serv_adr, 0, sizeof(serv_adr));
  serv_adr.sin_family = AF_INET;
  serv_adr.sin_addr.s_addr = htonl(INADDR_ANY);
  serv_adr.sin_port = htons(atoi(argv[1]));

  if (bind(serv_sock, (struct sockaddr *)&serv_adr, sizeof(serv_adr)) == -1)
    error_handling("bind() error");

  if (listen(serv_sock, 5) == -1) error_handling("listen() error");

  clnt_adr_sz = sizeof(clnt_adr);
  //调用 5 次 accept 函数，共为 5 个客户端提供服务
  for (i = 0; i < 5; i++) {
    clnt_sock = accept(serv_sock, (struct sockaddr *)&clnt_adr, &clnt_adr_sz);
    if (clnt_sock == -1)
      error_handling("accept() error");
    else
      printf("Connect client %d \n", i + 1);

    while ((str_len = read(clnt_sock, message, BUF_SIZE)) != 0)
      write(clnt_sock, message, str_len);

    close(clnt_sock);
  }
  close(serv_sock);
  return 0;
}

void error_handling(char *message) {
  fputs(message, stderr);
  fputc('\n', stderr);
  exit(1);
}
```
### 4.4.2. echo_client
```c
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#define BUF_SIZE 1024
void error_handling(char *message);

int main(int argc, char *argv[]) {
  int sock;
  char message[BUF_SIZE];
  int str_len;
  struct sockaddr_in serv_adr;

  if (argc != 3) {
    printf("Usage : %s <IP> <port>\n", argv[0]);
    exit(1);
  }

  sock = socket(PF_INET, SOCK_STREAM, 0);
  if (sock == -1) error_handling("socket() error");

  memset(&serv_adr, 0, sizeof(serv_adr));
  serv_adr.sin_family = AF_INET;
  serv_adr.sin_addr.s_addr = inet_addr(argv[1]);
  serv_adr.sin_port = htons(atoi(argv[2]));

  if (connect(sock, (struct sockaddr *)&serv_adr, sizeof(serv_adr)) == -1)
    error_handling("connect() error!");
  else
    puts("Connected...........");

  while (1) {
    fputs("Input message(Q to quit): ", stdout);
    fgets(message, BUF_SIZE, stdin);

    if (!strcmp(message, "q\n") || !strcmp(message, "Q\n")) break;

    write(sock, message, strlen(message));
    str_len = read(sock, message, BUF_SIZE - 1);
    message[str_len] = 0;
    printf("Message from server: %s", message);
  }
  close(sock);
  return 0;
}

void error_handling(char *message) {
  fputs(message, stderr);
  fputc('\n', stderr);
  exit(1);
}
```
### 4.4.3. result
![](attachment/2e45803db382ec15a42c658b5627d53b.png)
![](attachment/650282c78ba0d2aed3ce5a236dae4aa1.png)
![](attachment/6a8c4efa776864979d2b537927996d80.png)
同一时间双开两个客户端，可以看到其中一个客户端在connect调用成功之后，服务器并未受理该请求，只是把该请求放入了等待队列
![](attachment/881cf4172f6c06ba53db261842b08c84.png)
# 5. 基于TCP的服务器端/客户端（2）
## 5.1. 回声客户端的完美实现
4.4节中的回声客户端实现存在这样一个问题，TCP连接是没有数据边界的，因此不能保证客户端发出一个字符串后，从服务器端收到的数据一定是刚发出去的那个字符串，也可能是服务器端缓存了几个字符串后一并发回的多个字符串集合。为了解决这个问题，我们从客户端入手，因为这里的回声客户端是知道目标数据的大小的，因此我们收到服务器端的回复后，我们只读取目标字符串大小的数据
```c
- *str_len = read(sock, message, BUF_SIZE - 1);
+ int read_len = 0;
+ int read_cnt = 0;
+ while (read_len < str_len) {
+ read_cnt += read(sock, &message[read_len], BUF_SIZE - 1);
+  if (read_cnt == -1) error_handling("read() error!");
+  read_len += read_cnt;
+ }
```
## 5.2. 计算机服务器端/客户端
好的网络程序应该定好规则(协议)以表示数据的边界，或提前告知收发数据的大小，这些协议就是应用层协议，下面看一个实例，该实例提前告知了运算数的数量，确定了数据边界
该实例实现了这样一个功能：客户端传递操作数数量、操作数、运算符3个信息（存储在一个数组中传递）给服务器，服务器返回计算结果
### 5.2.1. op_client.c
```c
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>
const int BUF_SIZE = 256;  // size of type char
const int OPSZ = 4;
int main(int argc, char* argv[]) {
  /* allocate socket*/
  int clnt_sock = socket(PF_INET, SOCK_STREAM, 0);

  if (argc != 3) {
    printf("Usage: %s <IP> <port> \n", argv[0]);
    exit(1);
  }
  /* target server's ip address and port number*/
  struct sockaddr_in serv_addr;
  memset(&serv_addr, 0, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = inet_addr(argv[1]);
  serv_addr.sin_port = htons(atoi(argv[2]));

  /* connect */
  if (connect(clnt_sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) ==
      -1) {
    printf("connect error!\n");
    exit(1);
  }
  printf("Connected!\n");
  /* write and read */
  int opnd_cnt;
  char opmsg[BUF_SIZE];  // char type because of function read
  fputs("Operand count: ", stdout);
  scanf("%d", &opnd_cnt);
  opmsg[0] = (char)opnd_cnt;
  for (int i = 0; i < opnd_cnt; ++i) {
    printf("Operand %d: ", i + 1);
    scanf("%d", (int*)&opmsg[i * OPSZ + 1]);
  }
  fgetc(stdin);  // remove carriage return
  fputs("Operator: ", stdout);
  scanf("%c", &opmsg[opnd_cnt * OPSZ + 1]);
  write(clnt_sock, opmsg, opnd_cnt * OPSZ + 2);
  int result;
  read(clnt_sock, &result, OPSZ);
  printf("Operation result: %d \n", result);

  /*close socket */
  close(clnt_sock);
  return 0;
}
```
### 5.2.2. op_server.c
```c
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>
const int BUF_SIZE = 256;
const int OPSZ = 4;

void error_handling(const char* message);
int caculate(int opnum, int* operand, char operator);

int main(int argc, char* argv[]) {
  /* allocate socket*/
  int serv_sock = socket(PF_INET, SOCK_STREAM, 0);

  if (argc != 2) {
    printf("Usage: %s <port>\n", argv[0]);
    exit(1);
  }
  /*initialize ip address and port number*/
  struct sockaddr_in serv_addr;
  memset(&serv_addr, 0, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  serv_addr.sin_port = htons(atoi(argv[1]));

  /*bind ip address and port to socket*/
  if (bind(serv_sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) == -1)
    error_handling("bind() error! \n");

  /* start listening, size of waiting list is 5 */
  listen(serv_sock, 5);
  printf("Server start!\n");

  /*handle request: create another socket and connect to client */
  struct sockaddr_in clnt_addr;
  // function accept need a LValue
  socklen_t clnt_addr_size = sizeof(clnt_addr);
  int opnd_cnt = 0;
  char opinfo[BUF_SIZE];
  int result = 0;
  for (int i = 0; i < 5; ++i) {
    int clnt_sock =
        accept(serv_sock, (struct sockaddr*)&clnt_addr, &clnt_addr_size);
    printf("Handle connection!\n");
    // the file pointer will moved by one byte
    read(clnt_sock, &opnd_cnt, 1);

    /* handle one connection at a time */
    int read_len = 0, read_cnt = 0;
    while (read_len < opnd_cnt * OPSZ + 1) {
      // count by bytes;
      read_cnt = read(clnt_sock, &opinfo[read_len], BUF_SIZE - 1);
      if (read_cnt == -1) error_handling("read() error!\n");
      read_len += read_cnt;
    }
    result = caculate(opnd_cnt, (int*)opinfo, opinfo[read_len - 1]);
    write(clnt_sock, (char*)&result, sizeof(result));
    close(clnt_sock);
  }
  close(serv_sock);
  return 0;
}

void error_handling(const char* message) {
  fputs(message, stderr);
  exit(1);
}

int caculate(int opnum, int* operand, char operator) {
  int result = operand[0];
  switch (operator) {
    case '+':
      for (int i = 1; i < opnum; ++i) result += operand[i];
      break;
    case '-':
      for (int i = 1; i < opnum; ++i) result -= operand[i];
      break;
    case '*':
      for (int i = 1; i < opnum; ++i) result *= operand[i];
      break;
    default:
      error_handling("illegal operator!\n");
  }
  return result;
}
```
### 5.2.3 result
![](attachment/2593983bab4832389ec6beb712263b58.png)
![](attachment/3e952448f811e4fc7ec50098210cb02e.png)
# 6. 基于UDP的服务端/客户端
## 6.1 数据传输函数
### 6.1.1 sendto函数：发送数据
```c
#include <sys/socket.h>
ssize_t sendto (int sock , void *buff , size_t nbytes , int flags ,
 struct sockaddr *to , socklen_t addrlen );
/*
成功时返回传输的字节数，失败是返回 -1
sock: ⽤于传输数据的 UDP 套接字
buff: 保存待传输数据的缓冲地址值
nbytes: 待传输的数据⻓度，以字节为单位
flags: 可选项参数，若没有则传递 0
to: 存有⽬标地址的 sockaddr 结构体变量的地址值
addrlen: 传递给参数 to 的地址值结构体变量⻓度
*/

```
### 6.1.2 recvfrom：接受数据
`recvfrom`函数是一个阻塞函数，如果没有接收到数据，程序会停下等待
```c
#include <sys/socket.h>
ssize_t recvfrom (int sock , void *buff , size_t nbytes , int flags ,
 struct sockaddr *from , socklen_t *addrlen );
/*
成功时返回传输的字节数，失败是返回 -1
sock: ⽤于传输数据的 UDP 套接字
buff: 保存待传输数据的缓冲地址值
nbytes: 待传输的数据⻓度，以字节为单位
flags: 可选项参数，若没有则传递 0
from: 存有发送端地址信息的 sockaddr 结构体变量的地址值
addrlen: 保存参数 from 的结构体变量⻓度的变量地址值。
*/
```

## 6.2. 回声服务端/客户端
### 6.2.1 uecho_client.c
首次执行sendto时自动为客户端socket分配ip和端口号
```c
#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

const int BUF_SIZE = 100;
void error_handling(const char* message);

int main(int argc, char* argv[]) {
  int sock = socket(PF_INET, SOCK_DGRAM, 0);
  struct sockaddr_in target_serv_addr;

  if (argc != 3) {
    printf("Usage: %s <IP> <port> \n", argv[0]);
    exit(1);
  }
  memset(&target_serv_addr, 0, sizeof(target_serv_addr));
  target_serv_addr.sin_family = AF_INET;
  target_serv_addr.sin_addr.s_addr = inet_addr(argv[1]);
  target_serv_addr.sin_port = htons(atoi(argv[2]));

  char message[BUF_SIZE];
  while (1) {
    fputs("Input message(Q to quit): ", stdout);
    fgets(message, BUF_SIZE, stdin);

    if (!strcmp(message, "q\n") || !strcmp(message, "Q\n")) break;

    /*automatically allocate ip and port to client socket when executing
     * function sendto */
    if (sendto(sock, &message, strlen(message), 0,
               (struct sockaddr*)&target_serv_addr,
               sizeof(target_serv_addr)) == -1)
      error_handling("sendto() error!\n");

    socklen_t serv_adr_sz = sizeof(target_serv_addr);
    int recv_len = recvfrom(sock, &message, strlen(message), 0,
                            (struct sockaddr*)&target_serv_addr, &serv_adr_sz);
    if (recv_len == -1) error_handling("recvfrom() error!\n");
    message[recv_len] = '\0';
    printf("Message from server: %s", message);
  }
  close(sock);
  return 0;
}

void error_handling(const char* message) {
  fputs(message, stderr);
  exit(1);
}
```
### 6.2.2 uecho_server.c
没有了listen，accept步骤，用recvfrom和sendto代替了write和read，因为此时每次传输数据都要指明目的IP和端口号。使用UDP协议的socket就像一个邮箱，数据伴随着目的地址传入socket，因此在UDP中服务端和客户端的socket不是一一对应的，服务器的一个UDP套接字就可以服务多个客户端
```c
#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

const int BUF_SIZE = 100;
void error_handling(const char* message);

int main(int argc, char* argv[]) {
  int serv_sock = socket(PF_INET, SOCK_DGRAM, 0);

  if (argc != 2) {
    printf("Usage: %s <port> \n", argv[0]);
    exit(1);
  }

  struct sockaddr_in serv_addr;
  memset(&serv_addr, 0, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  serv_addr.sin_port = htons(atoi(argv[1]));

  if (bind(serv_sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) == -1)
    error_handling("bind() error!\n");

  struct sockaddr_in clnt_addr;
  socklen_t clnt_addr_sz = sizeof(clnt_addr);
  char message[BUF_SIZE];
  while (1) {
    int recv_len = recvfrom(serv_sock, &message, BUF_SIZE, 0,
                            (struct sockaddr*)&clnt_addr, &clnt_addr_sz);
    if (recv_len == -1) error_handling("recvfrom() error!\n");
    sendto(serv_sock, &message, recv_len, 0, (struct sockaddr*)&clnt_addr,
           clnt_addr_sz);
  }
  close(serv_sock);
  return 0;
}

void error_handling(const char* message) {
  fputs(message, stderr);
  exit(1);
}
```
### 6.2.3 result
![](attachment/af0aec2f4b4381f159e4f4e72cbdd405.png)
## 6.3. 已连接的UDP套接字
UDP也是可以建立连接的，具体来说，指定默认的目标地址就不用每次发送数据的时候都指定目标地址了，对需要长时间与同一台主机通信的情况能提高性能，相应的，因为不需要指定目标地址了，此时就可以用write和read取代sendto和recvfrom

>在 UDP 协议中，使用 `connect` 函数并不会像 TCP 那样建立一个真正的连接，因为 UDP 是一种无连接的协议，不需要进行三次握手过程。
>在 UDP 中，使用 `connect` 函数主要有以下两个目的：
>1. 将一个特定的对等地址（即目标 IP 地址和端口号）与套接字绑定，这样在后续的数据发送操作中，就不需要在每次发送数据时都指定目标地址。这样可以简化编程，提高效率。
>2. 允许套接字接收来自这个特定对等地址的数据，同时忽略来自其他地址的所有数据。
>因此，我们可以将 UDP 中的 `connect` 操作看作是**将套接字与一个固定的对等地址“关联”或者说“绑定”**，而并非真正的建立连接。 这种所谓的 "连接" 只是在本地的套接字中存储了目标地址信息，并没有进行任何的网络交互或者状态同步，因此它并不提供 TCP 连接中的诸如流量控制、拥塞控制、数据重新传输等特性。
### 6.3.1 uecho_con_client.c
```c
#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

const int BUF_SIZE = 100;
void error_handling(const char* message);

int main(int argc, char* argv[]) {
  int sock = socket(PF_INET, SOCK_DGRAM, 0);
  struct sockaddr_in target_serv_addr;

  if (argc != 3) {
    printf("Usage: %s <IP> <port> \n", argv[0]);
    exit(1);
  }
  memset(&target_serv_addr, 0, sizeof(target_serv_addr));
  target_serv_addr.sin_family = AF_INET;
  target_serv_addr.sin_addr.s_addr = inet_addr(argv[1]);
  target_serv_addr.sin_port = htons(atoi(argv[2]));

  if (connect(sock, (struct sockaddr*)&target_serv_addr,
              sizeof(target_serv_addr)) == -1)
    error_handling("connect() error!\n");
  char message[BUF_SIZE];
  while (1) {
    fputs("Input message(Q to quit): ", stdout);
    fgets(message, BUF_SIZE, stdin);

    if (!strcmp(message, "q\n") || !strcmp(message, "Q\n")) break;
    write(sock, &message, strlen(message));

    int recv_len = read(sock, message, strlen(message));
    message[recv_len] = '\0';
    printf("Message from server: %s", message);
  }
  close(sock);
  return 0;
}

void error_handling(const char* message) {
  fputs(message, stderr);
  exit(1);
}
```
### 6.3.2 result
![](attachment/b54958037e3a5b7491ad8451b4698a17.png)
# 7. 基于TCP的半关闭
TCP建立连接后，连接双方会有两个流：输入流/输出流
![](attachment/7c818c010486f41b8818e2151e6b70ab.png)
为了使客户端/服务端中的其中一端发送完所有数据后仍然能接受另一个端的数据，可以半关闭TCP连接，即只关闭输入流或输出流，这可以通过`shutdown`函数做到
```c
#include <sys/socket.h>
int shutdown(int sock, int howto);
/*
成功时返回 0 ，失败时返回 -1
sock: 需要断开套接字⽂件描述符
howto: 传递断开⽅式信息，如下

SHUT_RD : 断开输⼊流
SHUT_WR : 断开输出流
SHUT_RDWR : 同时断开 I/O 流
*/
```
下面的file_server/file_client完成了如下图的数据传输过程
![](attachment/4ae3ea8faf1b1f928cf62609dd5f8d11.png)
## 7.1 file_server.c
```c
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

const int BUF_SIZE = 256;
void error_handling(char *message);

int main(int argc, char *argv[]) {
  int serv_sock = socket(PF_INET, SOCK_STREAM, 0);

  if (argc != 2) {
    printf("Usage: %s <port>\n", argv[0]);
    exit(1);
  }
  /*initialize ip address and port number*/
  struct sockaddr_in serv_addr;
  memset(&serv_addr, 0, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  serv_addr.sin_port = htons(atoi(argv[1]));

  /*bind ip address and port to socket*/
  if (bind(serv_sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) == -1)
    error_handling("bind() error! \n");

  /* start listening, size of waiting list is 5 */
  listen(serv_sock, 5);
  printf("Server start!\n");
  /*handle request: create another socket and connect to client */
  struct sockaddr_in clnt_addr;
  // function accept need a LValue
  socklen_t clnt_addr_size = sizeof(clnt_addr);
  char buf[BUF_SIZE];
  FILE *fp = fopen("file_server.c", "rb");
  if (fp == NULL) error_handling("fopen() error!\n");
  int clnd_sock;
  if ((clnd_sock = accept(serv_sock, (struct sockaddr *)&clnt_addr,
                          &clnt_addr_size)) == -1)
    error_handling("accept() error!\n");
  int read_cnt;
  while (1) {
    read_cnt = fread((void *)buf, 1, BUF_SIZE, fp);
    /*file has been read over*/
    if (read_cnt < BUF_SIZE) {
      write(clnd_sock, buf, read_cnt);
      break;
    }
    /*file has not been read over */
    write(clnd_sock, buf, BUF_SIZE);
  }

  /* half close, keep input(read) stream*/
  shutdown(clnd_sock, SHUT_WR);
  read(clnd_sock, buf, BUF_SIZE);
  printf("Message from client: %s \n", buf);

  /*close both stream*/
  close(clnd_sock);
  close(serv_sock);
  fclose(fp);
  return 0;
}

void error_handling(char *message) {
  fputs(message, stderr);
  exit(1);
}
```
## 7.2 file_clent.c
```c
#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

const int BUF_SIZE = 100;
void error_handling(const char* message);

int main(int argc, char* argv[]) {
  int sock = socket(PF_INET, SOCK_STREAM, 0);
  struct sockaddr_in target_serv_addr;

  if (argc != 3) {
    printf("Usage: %s <IP> <port> \n", argv[0]);
    exit(1);
  }
  memset(&target_serv_addr, 0, sizeof(target_serv_addr));
  target_serv_addr.sin_family = AF_INET;
  target_serv_addr.sin_addr.s_addr = inet_addr(argv[1]);
  target_serv_addr.sin_port = htons(atoi(argv[2]));

  if (connect(sock, (struct sockaddr*)&target_serv_addr,
              sizeof(target_serv_addr)) == -1)
    error_handling("connect() error!\n");
  char buf[BUF_SIZE];
  FILE* fp = fopen("file_client.txt", "wb");
  if (fp == NULL) error_handling("fopen() error!\n");
  int read_cnt;
  while ((read_cnt = read(sock, buf, BUF_SIZE)) != 0) {
    fwrite(buf, 1, read_cnt, fp);
  }
  puts("Received file data");
  write(sock, "Thank u", 8);
  fclose(fp);
  close(sock);
  return 0;
}

void error_handling(const char* message) {
  fputs(message, stderr);
  exit(1);
}
```
## 7.3 result
![](attachment/d2e0564ddd54046fd15a0be981b2e52b.png)
![](attachment/ce94467b7b28cbb47047110d011b70e8.png)
写入成功
![](attachment/372ea5e5cccd8196d37616a067fa98f6.png)
# 8. 域名与网络地址
## 8.1 gethostbyname函数
为了在程序中实现**域名到IP地址**的转换，我们可以使用`gethostbyname`函数
```c
#include <netdb.h>
struct hostent *gethostbyname(const char *hostname);
/*
成功时返回 hostent 结构体地址，失败时返回 NULL 指针
*/
```
其中返回值hostent的结构如下
![](attachment/0aad34bc55a44a1c76b6df9bec84fcd9.png)
![](attachment/ef195a6d49d749ac2c519f72faf4855c.png)
其中h_addr_list指向字符串指针数组，字符串指针指向的是的in_addr结构体（In_addr_t等价于uint32_t）
![](attachment/a31c9994a8114c843ed577624fc2cf9a.png)
>在C中，`char*`是一种非常通用的指针类型，常常用于指向某一块内存区域，这块内存区域可以是任意数据类型。因此，`char*`可以被用来指向 `in_addr` 结构体。
>
>`h_addr_list` 是 `hostent` 结构体的一个成员，其类型是 `char**`，也就是一个指向字符指针的指针。在网络编程中，`h_addr_list` 通常用于存储网络地址（在 IPv4 中是一个四字节的地址，而在 IPv6 中是一个十六字节的地址）。
>
>当你要将 `h_addr_list` 与 `in_addr` 结构体一起使用时，你实际上是在通过 `char*` 指针解引用并访问内存中的 `in_addr` 结构体实例。虽然这个内存块实际上包含了一个 `in_addr` 结构体，但是在类型系统中它仍然是一个 `char*`。
>
>这样做的原因是因为 `char*` 是一种灵活的方式，可以处理各种不同大小和格式的网络地址。但在使用时需要小心，因为类型系统不会阻止你错误地解释这些字节。你需要确保你正确地理解了你正在处理的网络地址的实际格式。
![](attachment/514c251ef3b21c05c87fa8f2ff464762.png)
![](attachment/78fbc6ebab1d6d6a3550665996e2b414.png)
## 8.2 gethostbyname.c
```c
#include <arpa/inet.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
void error_handling(const char* message);

int main(int argc, char* argv[]) {
  if (argc != 2) {
    printf("Usage:%s <domain name> \n", argv[0]);
    exit(1);
  }
  struct hostent* host = gethostbyname(argv[1]);
  printf("official name: %s \n", host->h_name);
  printf("alias list: \n");
  for (int i = 0; host->h_aliases[i]; ++i)
    printf("%d: %s \n", i + 1, host->h_aliases[i]);
  printf("host address type: %s \n",
         (host->h_addrtype == AF_INET) ? "AF_INET" : "AF_INET6");
  printf("address_length: %d \n", host->h_length);
  /* Note type conversion */
  for (int i = 0; host->h_addr_list[i]; ++i)
    printf("IP address list: %d---%s \n", i + 1,
           inet_ntoa(*((struct in_addr*)host->h_addr_list[i])));
  return 0;
}

void error_handling(const char* message) {
  fputs(message, stderr);
  exit(1);
}
```
result
![](attachment/568d85cab2ef72a5728042172e904ce7.png)
## 8.3 gethostbyaddr函数
实现**IP地址到域名**的转换,这里的addr接收in_addr地址类型的参数但使用`char*`类型的声明也是为了兼容IPV6以传递更多信息
```c
#include <netdb.h>
struct hostent *gethostbyaddr(const char *addr, socklen_t len, int family);
/*
成功时返回 hostent 结构体变量地址值，失败时返回 NULL 指针
addr: 含有IP地址信息的 in_addr 结构体指针。为了同时传递 IPV4 地址之外的全部信息，该变量的类型声明为char 指针
len: 向第⼀个参数传递的地址信息的字节数，IPV4时为 4 ，IPV6 时为16.
family: 传递地址族信息，ipv4 是 AF_INET ，IPV6是 AF_INET6
*/
```
## 8.4 gethostbyaddr.c
```c
#include <arpa/inet.h>
#include <netdb.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
void error_handling(const char* message);

int main(int argc, char* argv[]) {
  if (argc != 2) {
    printf("Usage:%s <IP address> \n", argv[0]);
    exit(1);
  }
  struct in_addr addr;
  addr.s_addr = inet_addr(argv[1]);
  struct hostent* host_info = gethostbyaddr((char*)&addr, 4, AF_INET);
  if (host_info == NULL) error_handling("gethostbyaddr() error!\n");
  printf("official name: %s \n", host_info->h_name);
  printf("alias list: \n");
  for (int i = 0; host_info->h_aliases[i]; ++i)
    printf("%d: %s \n", i + 1, host_info->h_aliases[i]);
  printf("host_info address type: %s \n",
         (host_info->h_addrtype == AF_INET) ? "AF_INET" : "AF_INET6");
  printf("address_length: %d \n", host_info->h_length);
  /* Note type conversion */
  for (int i = 0; host_info->h_addr_list[i]; ++i)
    printf("IP address list: %d---%s \n", i + 1,
           inet_ntoa(*((struct in_addr*)host_info->h_addr_list[i])));
  return 0;
}

void error_handling(const char* message) {
  fputs(message, stderr);
  exit(1);
}
```
result
![](attachment/cfe30a4cb38058933f4e764477b5248e.png)
# 9. 套接字的多种可选项
## 9.1 getsockopt函数获取套接字特性
```c
#include <sys/socket.h>
int getsockopt(int sock, int level, int optname, void *optval, socklen_t *optlen);
/*
成功时返回 0 ，失败时返回 -1
sock: ⽤于查看选项套接字⽂件描述符
level: 要查看的可选项协议层
optname: 要查看的可选项名
optval: 保存查看结果的缓冲地址值
optlen: 向第四个参数传递的缓冲⼤小。调⽤函数后，该变量中保存通过第四个参数返回的可选项信息的字节数。
*/
```
## 9.2 getsockopt实例：查看套接字类型
```c
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <unistd.h>

void error_handling(const char* message);

int main(int argc, char* argv[]) {
  int tcp_sock = socket(PF_INET, SOCK_STREAM, 0);
  int udp_sock = socket(PF_INET, SOCK_DGRAM, 0);
  printf("SO_TYPE---SOCK_STREAM: %d\n", SOCK_STREAM);
  printf("SO_TYPE---SOCK_DGRAM: %d\n", SOCK_DGRAM);

  int optval;
  socklen_t optlen = sizeof(optval);
  if (getsockopt(tcp_sock, SOL_SOCKET, SO_TYPE, &optval, &optlen) == -1)
    error_handling("getsockopt() error!");
  printf("getsockopt of tcp_sock in SO_TYPE: %d\n", optval);
  if (getsockopt(udp_sock, SOL_SOCKET, SO_TYPE, &optval, &optlen) == -1)
    error_handling("getsockopt() error!");
  printf("getsockopt of udp_sock in SO_TYPE: %d\n", optval);
  close(tcp_sock);
  close(udp_sock);
  return 0;
}

void error_handling(const char* message) {
  fputs(message, stderr);
  exit(1);
}
```
result
![](attachment/b661a5f7900573b11e64e616e4eef5da.png)
## 9.3 setsockopt函数设置套接字特性
```c
#include <sys/socket.h>
int setsockopt(int sock, int level, int optname, const void *optval, socklen_t optlen);
/*
成功时返回 0 ，失败时返回 -1
sock: ⽤于更改选项套接字⽂件描述符
level: 要更改的可选项协议层
optname: 要更改的可选项名
optval: 保存更改结果的缓冲地址值
optlen: 向第四个参数传递的缓冲⼤小。调⽤函数候，该变量中保存通过第四个参数返回的可选项信息的字节数。
*/
```
## 9.4 setsockopt实例：修改TCP套接字I/O缓冲
```c
#include <asm-generic/socket.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <unistd.h>

void error_handling(const char* message);
void getBufSize(int sock);

int main(int argc, char* argv[]) {
  int tcp_sock = socket(PF_INET, SOCK_STREAM, 0);
  int rcv_buf = 2048, snd_buf = 2048;

  getBufSize(tcp_sock);

  if (setsockopt(tcp_sock, SOL_SOCKET, SO_RCVBUF, &rcv_buf, sizeof(rcv_buf)) ==
      -1)
    error_handling("setsockopt() error!\n");

  if (setsockopt(tcp_sock, SOL_SOCKET, SO_SNDBUF, &snd_buf, sizeof(snd_buf)) ==
      -1)
    error_handling("setsockopt() error!\n");

  getBufSize(tcp_sock);
}

void getBufSize(int sock) {
  int rsv_buf, snd_buf;
  socklen_t len = sizeof(rsv_buf);

  if (getsockopt(sock, SOL_SOCKET, SO_RCVBUF, &rsv_buf, &len) == -1)
    error_handling("getsockopt() error!\n");
  printf("getsockopt of tcp_sock in SO_RCVBUF: %d\n", rsv_buf);

  len = sizeof(snd_buf);
  if (getsockopt(sock, SOL_SOCKET, SO_SNDBUF, &snd_buf, &len) == -1)
    error_handling("getsockopt() error!\n");
  printf("getsockopt of tcp_sock in SO_SNDBUF: %d\n", snd_buf);
}

void error_handling(const char* message) {
  fputs(message, stderr);
  exit(1);
}
```
result
setsockopt函数不会完全按照我们的指示设置套接字，只是向系统传递我们的要求，而结果大致反映我们的设置
![](attachment/d236b6c03d3c6fcf3c8b0ca19ca9b014.png)
## 9.5. SO_REUSEADDR---修改Time-wait状态
在终止服务器程序之后，TCP连接会在四次挥手之后进入time-wait状态（当一个TCP连接被关闭时，它实际上并不会立即完全消失，而是会进入一个称为 `TIME_WAIT` 的状态，目的是保证最后的 ACK 报文能够到达），这将导致服务器帮顶的端口号在一段时间内无法再次使用(通常是几分钟)。在高并发的情况下，`TIME_WAIT` 状态的连接可能会占用大量的端口，如果端口资源耗尽，那么新的连接就无法建立。
如果我们需要服务器停止运行后，对应的端口号可以立马被重新分配给新的套接字（**允许端口被立即重用**），这可以通过修改套接字的SO_REUSEADDR属性（修改为true）做到。
默认情况下SO_REUSEADDR为false，对应开启Time-Wait状态，此时Ctrl-C终止服务端程序将导致端口号不可用，重新尝试绑定会引发bind() error
```c
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#define BUF_SIZE 1024
void error_handling(char *message);

int main(int argc, char *argv[]) {
  int serv_sock, clnt_sock;
  char message[BUF_SIZE];
  int str_len, i;

  struct sockaddr_in serv_adr, clnt_adr;
  socklen_t clnt_adr_sz;

  if (argc != 2) {
    printf("Usage : %s <port>\n", argv[0]);
    exit(1);
  }

  serv_sock = socket(PF_INET, SOCK_STREAM, 0);
  if (serv_sock == -1) error_handling("socket() error");

  memset(&serv_adr, 0, sizeof(serv_adr));
  serv_adr.sin_family = AF_INET;
  serv_adr.sin_addr.s_addr = htonl(INADDR_ANY);
  serv_adr.sin_port = htons(atoi(argv[1]));

  /*int optVal =1;*/
  /*socklen_t optLen = sizeof(optVal);*/
  /*setsockopt(serv_sock, SOL_SOCKET, SO_REUSEADDR, &optVal, optLen);*/

  if (bind(serv_sock, (struct sockaddr *)&serv_adr, sizeof(serv_adr)) == -1)
    error_handling("bind() error");

  if (listen(serv_sock, 5) == -1) error_handling("listen() error");

  clnt_adr_sz = sizeof(clnt_adr);
  //调用 5 次 accept 函数，共为 5 个客户端提供服务
  for (i = 0; i < 5; i++) {
    clnt_sock = accept(serv_sock, (struct sockaddr *)&clnt_adr, &clnt_adr_sz);
    if (clnt_sock == -1)
      error_handling("accept() error");
    else
      printf("Connect client %d \n", i + 1);

    while ((str_len = read(clnt_sock, message, BUF_SIZE)) != 0)
      write(clnt_sock, message, str_len);

    close(clnt_sock);
  }
  close(serv_sock);
  return 0;
}

void error_handling(char *message) {
  fputs(message, stderr);
  fputc('\n', stderr);
  exit(1);
}
```
![](attachment/e5efeb758a2733bdc14ac3d5b4b9a819.png)
去掉注释，修改套接字的SO_REUSEADDR属性为true，此时终止服务器之后，相应端口能立即重新分配给新的套接字
![](attachment/fa93f1a6070f36a14e418eb6e4761aa7.png)
# 10. 多进程服务器
## 10.1 简单使用fork
![](attachment/386db4a1da1987c8e5cc6276315c48b0.png)
fork函数允许从父进程中创建子进程，并返回用户空间的同一位置（fork语句所在的位置），父进程的fork返回值为子进程的PID(非0)，子进程的fork返回值为0，更多信息可以看HIT笔记的相关部分
```cpp
#include <stdio.h>
#include <sys/wait.h>
#include <unistd.h>

int gVal = 10;
int main(int argc, char* argv[]) {
  int lVal = 20;
  pid_t pid;

  pid = fork();
  if (pid == 0) {
    printf("I am Son with gVal %d lVal %d !\n", gVal, lVal);
    gVal += 2;
    lVal += 2;
  } else {
    wait(NULL);
    printf("I am father with gVal %d lVal %d !\n", gVal, lVal);
    gVal -= 2;
    lVal -= 2;
  }
  return 0;
}
```
在父进程中使用[wait(NULL)](https://stackoverflow.com/a/42426884/19705477)，这将导致父进程阻塞直到子进程退出(后续会讲述wait函数)
![](attachment/659a0758a9ba7315c304b9a680b30e1d.png)
## 10.2 zombie process
zombie进程是完成工作后不释放PID的进程，这将导致PID的浪费（系统资源的浪费）。
>僵尸进程（Zombie Process）是一种已经完成执行但是还在进程表中保留着退出状态信息的进程。这些进程并不消耗任何系统资源，除了进程表中的一个位置。在子进程结束并将控制权返回给父进程之前，它必须保留一些信息，以便父进程可以查看。这些进程被称为僵尸进程。僵尸进程不消耗计算机的CPU或内存资源，但它们仍然消耗一个重要的系统资源，即进程ID（PID）。每个UNIX或类UNIX系统都有一个固定数量的进程ID可以使用。如果系统在尝试创建一个新的进程，但所有PID都已被使用（包括那些被僵尸进程使用的），则系统将无法创建新的进程。"系统资源的浪费"应该更准确地指的是"进程ID的浪费"

下面让我们来看是如何产生zombie进程的。
当一个子进程结束时（通过exit语句或return 语句），向exit函数传递的参数值和main函数的return语句返回的值都会传递给操作系统 。 而**操作系统不会销毁子进程，直到把这些值传递给产生该子进程的父进程** 。然而，操作系统不会主动把这些值传递给父进程 ，只有父进程主动发起请求(函数调用)时，操作系统才会传递该值 。也就是说，如果子进程比父进程先结束运行，而父进程又没有发起获取子进程返回值的请求(如wait函数)，那么子进程就会成为zombie进程，因为它已经执行结束但没有被释放，直到父进程执行完毕退出，子进程才会和父进程一起被销毁。
下面我们来看一个实例zombie.c
```c
#include <stdio.h>
#include <unistd.h>

int main(int argc, char* argv[]) {
  pid_t pid = fork();
  if (pid == 0) {
    printf("Hi, I am a child process\n");
  } else {
    printf("Child process pid: %d\n", pid);
    sleep(30);
  }
  if (pid == 0)
    printf("End child process!\n");
  else
    printf("End parent process!\n");
  return 0;
}
```
result
fork返回后CPU先执行的父进程，但父进程会执行sleep函数而陷入阻塞状态，接着CPU转去执行子进程，子进程执行完毕但父进程还没有，并且父进程没有主动对操作系统发起获取子进程返回值的请求（wait函数），因此子进程陷入zombie状态，通过`ps au`打印进程信息我们可以看见这一点。
![](attachment/058751d79c7fdeaac6ab1eb0f54d2b5a.png)
最后，父进程执行结束，子进程和父进程一起被销毁（没有pid为22792的父进程和pid为22793的子进程了）
![](attachment/0afb0b18fe4ed5af0a968440e678e031.png)
## 10.3 wait函数销毁zombie进程
父进程可以通过调用系统调用函数wait向操作系统请求获取子进程的返回值。如果调用此函数时已有子进程终止 ，那么子进程终止时传递的返回值( exit函数的参数值、main函数的retum返回值)将保存到该函数的参数（statloc指针）所指的内存空间
![](attachment/1b553c9395547b2cb6ebe8328b74db49.png)
可以通过下面2个宏函数获取子进程结束状态(是否正常结束)和子进程的返回值
```c
WIFEXITED(status) // 子进程正常终止时返回true,其中status的传递给wait的参数的解引用
WEXITSTATUS(status) // 返回子进程的返回值
```
下面看一个实例wait.c
```c
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <unistd.h>

int main(int argc, char* argv[]) {
  pid_t pid = fork();

  if (pid == 0)  // first child process
  {
    return 3;
  } else {
    printf("First child process pid: %d\n", pid);

    pid = fork();
    if (pid == 0) {
      exit(7);
    } else {
      printf("Second child process pid: %d\n", pid);

      int status;
      wait(&status);
      if (WIFEXITED(status))
        printf("First child process end and return value %d!\n",
               WEXITSTATUS(status));  // print 3

      wait(&status);
      if (WIFEXITED(status))
        printf("Second child process end and return value %d!\n",
               WEXITSTATUS(status));  // print 7
    }
  }
  return 0;
}
```
result
父进程先后创建两个子进程，第一次调用wait时1号子进程被销毁，第二次调用wait时2号子进程被销毁
![](attachment/9928caa0c31c41fcfe973fcaecbc1bf5.png)
## 10.4 waitpid不阻塞父进程的销毁zombie进程
调用wait函数时，父进程会阻塞直到子进程终止才继续运行，这将导致父进程等待子进程结束的这段时间内什么也不能做而效率低下。waitpid函数（传递WHOHANG参数）会在没有子进程终结时直接返回0而不阻塞父进程。
![](attachment/95cc69b5f823689cbdbea546ae159250.png)
实例
```c
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <unistd.h>

int main(int argc, char* argv[]) {
  pid_t pid = fork();

  if (pid == 0) {
    return 3;
  } else {
    int status;
    if (!waitpid(pid, &status, WNOHANG)) {
      fputs("no stuck if no child end!\n", stdout);
    }
    if (WIFEXITED(status))
      printf("First child process end and return value %d!\n",
             WEXITSTATUS(status));  // print 3
  }
  return 0;
}
```
result
![](attachment/914367e17954f6fecfcdc56add39a482.png)
## 10.5 sigaction函数信号处理
即使是使用了waitpid函数，父进程也不能及时的获取子进程的返回值（需要不断的调用wait/waitpid函数），根本原因在于**父进程不知道子进程什么时候结束**，而OS又不会在子进程结束时主动将返回值交给父进程进而销毁子进程，这需要父进程通过wait/waitpid函数主动向OS申请。因此如果有这样一个机制，在子进程结束时，**OS通知父进程(传递信号)**，然后父进程立马向OS申请获取子进程返回值，这样子进程就能立即被销毁而不会成为僵尸进程。
sigaciton函数是一个信号注册函数。信号注册，具体来说就进程告诉OS系统，在发生某个事件时通知我(进程)，并调用相应的处理函数(handler)，这类似于中断处理的思想
![](attachment/a3f1c84c7253cb8fe126f321d416546c.png)
sigaciton函数的定义如下
![](attachment/6171c3eb97c3a24fdb6b463229ea363b.png)
其中的信号信息有3种（由int类型的宏常量表示），代表了3种事件
![](attachment/797e9d754f69e8125c46968b6807e458.png)
其中alarm函数如下
![](attachment/95eefa88cca3a9aac2f16d8003a3768e.png)
实例：超时事件注册
```c
#include <signal.h>
#include <stdio.h>
#include <unistd.h>

void timeout(int sig) {
  if (sig == SIGALRM) puts("Time out !");
  alarm(2);  // after 2s, event will toggle
}
int main(int argc, char* argv[]) {
  struct sigaction act;
  act.sa_handler = timeout;
  act.sa_flags = 0;
  sigemptyset(&act.sa_mask); // set 0
  sigaction(SIGALRM, &act, 0);
  alarm(2);
  for (int i = 0; i < 3; ++i) {
    puts("wait...");
    // waiting for time out, in fact, running time will be 6 seconds instead of
    // 3*300=900 seconds
    sleep(300);
  }
}
```
result
程序每运行2秒就会触发超时事件，OS此时会唤醒进程并执行相应的处理函数（timeout）
程序运行6秒（而不是900s）后退出，即使进程因为sleep函数进入阻塞状态，发生信号时将唤醒由于调用sleep函数而进入阻塞状态的进程，而且进程一旦被唤醒，就不会再回到睡眠状态，即使还未到 sleep 函数中规定的时间也是如此
![](attachment/1006e24eee0b926f2e5613d776731d81.png)
## 10.6 利用信号处理技术消灭僵尸进程
将子进程终止注册为事件，并在父进程的处理函数中发起对子进程返回值的申请，这样子进程占有的系统资源就能够被操作系统回收
```c
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <unistd.h>

void childproc_handler(int sig) {
  int status;
  pid_t pid = waitpid(-1, &status, WNOHANG);
  if (WIFEXITED(status)) {
    printf("Remove child process pid %d and return value %d!\n", pid,
           WEXITSTATUS(status));  // print 3
  }
}

int main(int argc, char* argv[]) {
  struct sigaction act;
  act.sa_handler = childproc_handler;
  act.sa_flags = 0;
  sigemptyset(&act.sa_mask);  // set 0
  sigaction(SIGCHLD, &act, 0);

  pid_t pid = fork();
  if (!pid) {
    puts("Hi! I am child process one");
    sleep(2);
    return 1;
  } else {
    printf("First child process with pid %d\n", pid);
    pid = fork();
    if (!pid) {
      puts("Hi! I am child process two");
      sleep(2);
      exit(2);
    } else {
      printf("Second child process with pid %d\n", pid);
      puts("waiting...(child process end)");
      for (int i = 0; i < 3; i++) sleep(5);  // actually 2 seconds
    }
  }
  puts("parent process exit!\n");
  return 0;
}
```
result
这里出现了一个小插曲，当第2个子进程也以return方式退出时，remove语句只打印了一次，换言之两个子进程结束的时间太接近，使得在两次信号发送到达父进程的时间间隔内，父进程只执行了一次信号处理函数，因此第2个进程成为了zombie进程。解决方法时换成exit语句（或许是比return执行的更久）或通过修改sleep语句（让第2个子进程休眠更久一点）使得两个子进程结束的间隔更大一点。

子进程一旦结束，就触发父进程相应的处理函数，该函数通过waitpid函数向操作系统获取子进程的返回值，操作系统在提交返回值后销毁子进程，整个过程中不会出现zombie进程
![](attachment/35af049bab8b2ad7f5a1a24586f75f83.png)
## 10.7 多进程并发回声服务器
![](attachment/59fa49ea79b9ed837aacff89d40d592c.png)
之前我们的回声服务器同一时间内只能受理一个客户端请求，现在我们学习了多进程之后，就可以编写并发服务器了，能够做到同一时间处理多个客户端请求。具体来说，在父进程中用accept受理请求之后，分叉(fork)出一个子进程管理这个连接（之前提到过，accept创建新套接字并与相应客户端建立请求）。于是子进程负责和客户端进行数据传输，而父进程继续负责监听和受理。

注意子进程会复制父进程的一切资源，对套接字而言，子进程只会复制套接字的文件描述符（因为父进程本身不拥有套接字，从严格意义上说，套接字属于操作系统，而进程只是拥有代表相应套接字的文件描述符），所以fork之后，会有父、子进程两个的文件描述符指向同一个套接字(套接字本体没有被复制)
![](attachment/b0f7d2e88fea4f1696c08822d5bede8d.png)
就像是C++的智能指针shared_ptr一样，套接字只有在指向自己的文件描述符都销毁的情况下，才会销毁本体。因此子进程中要关闭服务器端套接字（serv_sock）以避免父进程退出时无法关闭服务端套接字，同理，父进程要关闭客户端连接套接字clnt_sock以避免子进程无法关闭连接套接字（深入理解必然涉及OS底层）
![](attachment/b3ab58ba33f309e03cd8ce733d519325.png)
```c
#include <arpa/inet.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <unistd.h>

const int BUF_SIZE = 36;
void error_handling(const char* message);
void childproc_handler(int sig);

int main(int argc, char* argv[]) {
  /* allocate socket*/
  int serv_sock = socket(PF_INET, SOCK_STREAM, 0);

  int optVal = 1;
  socklen_t optLen = sizeof(optVal);
  setsockopt(serv_sock, SOL_SOCKET, SO_REUSEADDR, &optVal, optLen);

  if (argc != 2) {
    printf("Usage: %s <port>\n", argv[0]);
    exit(1);
  }
  /*initialize ip address and port number*/
  struct sockaddr_in serv_addr;
  memset(&serv_addr, 0, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  serv_addr.sin_port = htons(atoi(argv[1]));

  /*bind ip address and port to socket*/
  if (bind(serv_sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) == -1)
    error_handling("bind() error! \n");

  /* start listening, size of waiting list is 5 */
  listen(serv_sock, 5);
  printf("Server start!\n");

  /* avoid zombie process*/
  struct sigaction act;
  act.sa_handler = childproc_handler;
  act.sa_flags = 0;
  sigemptyset(&act.sa_mask);  // set 0
  sigaction(SIGCHLD, &act, 0);

  /*handle request: create another socket and connect to client */
  struct sockaddr_in clnt_addr;
  // function accept need a LValue
  socklen_t clnt_addr_size = sizeof(clnt_addr);
  char buf[BUF_SIZE];
  while (1) {
    int clnt_sock =
        accept(serv_sock, (struct sockaddr*)&clnt_addr, &clnt_addr_size);
    if (clnt_sock == -1)
      continue;
    else
      puts("new client connected!");
    pid_t pid = fork();
    if (pid == -1) {
      close(clnt_sock);
      continue;
    }
    if (!pid) {
      close(serv_sock);
      int str_len = 0;
      while ((str_len = read(clnt_sock, buf, BUF_SIZE)) != 0) {
        write(clnt_sock, buf, BUF_SIZE);
      }
      close(clnt_sock);
      puts("client disconnected!");
      return 0;
    } else {
      close(clnt_sock);
    }
  }
  close(serv_sock);
  return 0;
}

void childproc_handler(int sig) {
  int status;
  pid_t pid = waitpid(-1, &status, WNOHANG);
  if (WIFEXITED(status)) {
    printf("Remove child process pid %d\n",
           WEXITSTATUS(status));  
  }
}
void error_handling(const char* message) {
  fputs(message, stderr);
  exit(1);
}
```
result
![](attachment/9aa9c5f63a91d40d8e3dd928e28aad33.png)
![](attachment/5680fe32c80ce85531680b9bec7c543b.png)
![](attachment/d70625c7d173e1a17eecbf42c3e16755.png)
## 10.8 I/O程序分割
使用父子进程分割输入输出操作，这样就不必等待数据接受后再执行写操作
![](attachment/994a6f3b0747bac403942595c57ce9c0.png)
注意write例程使用了shutdown函数，这是因为子进程的close(sock)操作不能关闭套接字，因为此时有两个文件描述符指向同一个套接字。这里在子进程中使用`shutdown(sock, SHUT_WR)`关闭套接字的写流（输出流），目的在于传递EOF给server端，告知server端数据流已经达到末尾。具体机制如下：

**shutdown()函数的调用会影响到所有持有该套接字的文件描述符**，无论它们在哪个进程中。`shutdown()`函数用于关闭一个套接字的一部分（读、写或读写都可以）。当你调用 `shutdown(sock, SHUT_WR)`，你是在告诉操作系统：无论还有多少进程持有这个套接字的文件描述符，你都不再需要对这个套接字进行写操作。这将导致任何后续的写操作都失败，并向试图从套接字读取数据的任何进程发送一个 EOF。同样的，如果你调用 `shutdown(sock, SHUT_RD)`，你就告诉操作系统，你不再需要从这个套接字读取数据了，任何后续的读操作都将立即返回 EOF，无论是否有数据可读。同时，这个套接字依然可以进行写操作，除非你也关闭了写端。
注意，这是与 `close()` 函数的行为完全不同的。调用 `close()` 函数只会影响到调用它的进程中的文件描述符，而对其他持有该套接字的进程没有任何影响。
```c
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

const int BUF_SIZE = 256;
void error_handling(char *message);
void write_routine(int sock, char *message);
void read_routine(int sock, char *message);

int main(int argc, char *argv[]) {
  int sock;
  char message[BUF_SIZE];
  struct sockaddr_in serv_adr;

  if (argc != 3) {
    printf("Usage : %s <IP> <port>\n", argv[0]);
    exit(1);
  }

  sock = socket(PF_INET, SOCK_STREAM, 0);
  if (sock == -1) error_handling("socket() error");

  memset(&serv_adr, 0, sizeof(serv_adr));
  serv_adr.sin_family = AF_INET;
  serv_adr.sin_addr.s_addr = inet_addr(argv[1]);
  serv_adr.sin_port = htons(atoi(argv[2]));

  if (connect(sock, (struct sockaddr *)&serv_adr, sizeof(serv_adr)) == -1)
    error_handling("connect() error!");
  else
    puts("Connected...........");

  pid_t pid = fork();
  if (!pid) {
    write_routine(sock, message);  // child process is responsible for write
  } else {
    read_routine(sock, message);  // parent process is responsible for read
  }

  close(sock);  // close twice
  return 0;
}

void write_routine(int sock, char *message) {
  while (1) {
    fgets(message, BUF_SIZE, stdin);
    if (!strcmp(message, "q\n") || !strcmp(message, "Q\n")) {
      shutdown(sock, SHUT_WR);  // pass EOF
      return;
    }
    write(sock, message, strlen(message));
  }
}

void read_routine(int sock, char *message) {
  while (1) {
    int str_len = read(sock, message, BUF_SIZE - 1);
    if (str_len == 0) return;  // message is empty which means no input
    message[str_len] = '\0';   // string end character
    printf("Message from server: %s", message);
  }
}

void error_handling(char *message) {
  fputs(message, stderr);
  fputc('\n', stderr);
  exit(1);
}
```
result
与回声客户端表现一样，但实现方式优化了很多
![](attachment/9e7bea7f57cf10d262c89729168daad7.png)

# 11. 进程间通信
## 11.1 管道通信的简单实现
使用pipe函数可以创建管道，并获取管道出口描述符和管道出口描述符。
![](attachment/7005d1b67b0c5e0874dc4abef07df2f9.png)
管道和套接字一样属于操作系统的资源，进程只持有它入口和出口的描述符，因此fork函数不会复制管道，而只是复制描述符给子进程。通过父子进程都持有对同一管道的描述符，那么管道就是父子进程间的共享内存空间，因此父子进程通过读写该内存就可以传递信息
![](attachment/53cd6542b53f77daaeaa50de4e2283a9.png)
实例
![](attachment/b3eff5f0398a5a1d9c66cc682db96abd.png)
```c
#include <stdio.h>
#include <unistd.h>

const int BUFSIZE = 36;

int main(int argc, char* argv[]) {
  char str0[] = "Hello! child process!";
  char message[BUFSIZE];
  int pipe_handle[2];
  pipe(pipe_handle);

  pid_t pid = fork();
  if (!pid) {
    write(pipe_handle[1], str0, sizeof(str0));
  } else {
    read(pipe_handle[0], message, BUFSIZE);
    printf("parent get message from child : %s", message);
  }
  return 0;
}
```
result
![](attachment/fdb2660ea8978480391fbd3e1ad34984.png)
## 11.2 管道实现进程间双向通信
进程间的双向通信必须建立2个管道，如果在同一个管道上进行双向通信，那么进程刚写入管道的内容就可能被自己读走，导致另一个进程读一个空的管道，这将导致错误。因此应该如下图所示的使用2个管道的模型进行进程间的双向通信
![](attachment/4a0ade80db15b228a67ac2d2e0ef0cfc.png)
实例
```c
#include <stdio.h>
#include <unistd.h>

const int BUFSIZE = 36;

int main(int argc, char* argv[]) {
  char str1[] = "Hello parent! I am child!";
  char str2[] = "Hello child! I am parent!";
  char buf[BUFSIZE];
  int pipe_handle1[2], pipe_handle2[2];
  pipe(pipe_handle1);
  pipe(pipe_handle2);

  pid_t pid = fork();
  if (!pid) {
    write(pipe_handle1[1], str1, sizeof(str1));
    int str_len = read(pipe_handle2[0], buf, BUFSIZE - 1);
    buf[str_len] = '\0';
    printf("Child: message from parent --- %s\n", buf);
  } else {
    write(pipe_handle2[1], str2, sizeof(str2));
    int str_len = read(pipe_handle1[0], buf, BUFSIZE - 1);
    buf[str_len] = '\0';
    printf("Parent: message from child --- %s\n", buf);
  }
  return 0;
}
```
result
![](attachment/3e44bf1ee1ef971ce5ca1d064a68de79.png)
## 11.3 保留消息的回声服务器
存在两个子进程：一个用于从套接字接收客户端数据并写入管道，另一个则用于从管道中读取数据并写入文件。注意这里写入文件操作，我在这踩了坑：客户端传递了几个消息后我就Ctrl-C终止进程查看对应文件内容，结果始终为空，原因如下：
>处理文件操作时，一定要确保在程序结束前正确关闭了文件。即使fwrite调用成功，数据可能仍然存在于C库的缓冲区中，而并未直接写入到磁盘文件。这是因为C库通常会缓存文件I/O操作以提高性能。如果在程序结束前文件没有被正确关闭，fclose函数在关闭文件之前会尝试将这些缓冲的数据写入到文件。如果程序在这之前就结束了，那么这些数据就会丢失。

>在Unix和类Unix系统（比如Linux）中，当你在终端中按下Ctrl+C，会向前台进程组发送一个SIGINT（终端中断）信号。默认情况下，该信号会结束接收到它的进程。
>对于一个父进程和它的子进程，如果它们在同一个前台进程组中，那么它们都会接收到这个SIGINT信号。如果子进程没有更改它的行为（比如安装一个信号处理器或者忽略该信号），它们会像父进程一样被结束。

也就是说，我Ctrl-C强制终结进程，导致父进程和子进程均被终结，导致子进程还没有来得及执行fclose函数关闭文件，最终导致文件始终为空。
echo_storeServ.c
```c
#include <arpa/inet.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <unistd.h>

const int BUFSIZE = 256;
void error_handling(const char* message);
void childproc_handler(int sig);

int main(int argc, char* argv[]) {
  /* allocate socket*/
  int serv_sock = socket(PF_INET, SOCK_STREAM, 0);

  /*remove time_wait state*/
  int optVal = 1;
  socklen_t optLen = sizeof(optVal);
  setsockopt(serv_sock, SOL_SOCKET, SO_REUSEADDR, &optVal, optLen);

  if (argc != 2) {
    printf("Usage: %s <port>\n", argv[0]);
    exit(1);
  }
  /*initialize ip address and port number*/
  struct sockaddr_in serv_addr;
  memset(&serv_addr, 0, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  serv_addr.sin_port = htons(atoi(argv[1]));

  /*bind ip address and port to socket*/
  if (bind(serv_sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) == -1)
    error_handling("bind() error! \n");

  /* start listening, size of waiting list is 5 */
  listen(serv_sock, 5);
  printf("Server start!\n");

  /* avoid zombie process*/
  struct sigaction act;
  act.sa_handler = childproc_handler;
  act.sa_flags = 0;
  sigemptyset(&act.sa_mask);  // set 0
  sigaction(SIGCHLD, &act, 0);

  /*handle request: create another socket and connect to client */
  struct sockaddr_in clnt_addr;
  // function accept need a LValue
  socklen_t clnt_addr_size = sizeof(clnt_addr);
  char buf[BUFSIZE];
  int pipe_handle[2];

  pipe(pipe_handle);

  pid_t pid = fork();

  /*child process which write content from client to txt file*/
  if (!pid) {
    FILE* pf = fopen("echomsg.txt", "wt");
    if (pf == NULL) error_handling("fopen() error!\n");
    close(serv_sock);
    for (int i = 0; i < 3; ++i) {
      int len = read(pipe_handle[0], buf, BUFSIZE);
      printf("i can write! len : %d\n", len);
      int num_written = fwrite((void*)buf, 1, len, pf);
      if (num_written < len && ferror(pf)) {
        perror("fwrite failed");
      }
    }
    fclose(pf);
    return 0;
  }

  while (1) {
    int clnt_sock =
        accept(serv_sock, (struct sockaddr*)&clnt_addr, &clnt_addr_size);
    if (clnt_sock == -1)
      continue;
    else
      puts("new client connected!");
    pid_t pid = fork();
    if (pid == -1) {
      close(clnt_sock);
      continue;
    }
    if (!pid) {
      close(serv_sock);
      int str_len = 0;
      while ((str_len = read(clnt_sock, buf, BUFSIZE)) != 0) {
        write(clnt_sock, buf, str_len);
        write(pipe_handle[1], buf, str_len);
      }
      close(clnt_sock);
      puts("client disconnected!");
      return 0;
    } else {
      close(clnt_sock);
    }
  }
  close(serv_sock);
  return 0;
}

void childproc_handler(int sig) {
  int status;
  pid_t pid = waitpid(-1, &status, WNOHANG);
  if (WIFEXITED(status)) {
    printf("Remove child process pid %d\n", WEXITSTATUS(status));
  }
}
void error_handling(const char* message) {
  fputs(message, stderr);
  exit(1);
}
```
result
负责从管道读取数据写入文件的子进程在写入3次后就退出，因为有sigaction信号处理机制，因此该子进程也会立刻销毁
![](attachment/29eab1af0b63b0ea2a76c0680cdc4136.png)
![](attachment/7464b01a2cdaa1279b81cb9b124ab62b.png)
# 12. I/O复用
之前的多进程并发服务器，只要有客户端连接请求就会创建新进程，这将不断消耗系统资源。我们希望建立这样一个服务端，它能在不创建进程的同时向多个客户端提供服务。这也就意味着，服务端进程**监听多个套接字**(与客户端连接的套接字)，如下图
![](attachment/f39ffd31fe0ea58f3e8bf260da486c25.png)
要让单个进程的服务端监听多个套接字，就需要用到select函数监视多个文件描述符（例如套接字）以查看是否有数据可读、可写或有错误的可用（该函数指出哪些文件描述符已经准备好进行读或写操作）。select()通过接受三个文件描述符集合（一个用于读操作，一个用于写操作，一个用于错误检测），并一个超时参数，然后在某个条件被满足（例如某个描述符准备好读取或写入数据，或者达到了超时时间）时返回。**select()函数会更改传递给它的文件描述符集(fd_set)，以指示哪些描述符已经准备好进行相应的I/O操作。**

这允许程序在同一时间点上同时处理多个套接字的I/O，而不是顺序地处理每个套接字的I/O，这样就提高了程序的效率。在多个套接字之间使用`select()`进行切换，使得程序能够在等待一个套接字的数据时去处理另一个套接字的数据，从而实现了I/O的复用。这是非常重要的，因为I/O操作通常是阻塞的，如果一个套接字上没有数据可以读或写，那么操作将阻塞，直到数据可用为止。使用`select()`可以避免这种阻塞，提高了程序处理多个套接字的能力。
![](attachment/9772f02912c93bd6a5977ea2a54524d5.png)
![](attachment/6c1108b3848c8b6bc3ab77932ca94f40.png)
表示超时时间的timeout结构如下，其中的微秒(tv_usec)是为了提供更高的时间精度。如果`tv_sec`为10，`tv_usec`为500000，那么它们共同表示的时间是 10.5 秒。
![](attachment/3022f73585fb7bbaafd68ab003e3c4f9.png)
其中表示文件描述符集合的fd_set型变量及相关函数如下，fd_set变量的每一个位都表示一个文件描述符（如图所示，第0位表示文件描述符0，即标准输入），位被置1则表示相应的文件被注册（即加入了被监听的文件描述符集合，fd_set型变量代表了一个监听集合）
![](attachment/bb54afd8e831de4aadede3a260319afb.png)
![](attachment/c4013103ad84275541e3ec613b822a6b.png)
## 12.1 select函数的简单使用
```c
#include <stdio.h>
#include <stdlib.h>
#include <sys/select.h>
#include <sys/time.h>
#include <unistd.h>

void error_handling(char *message);
const int BUFSIZE = 256;

int main(int argc, char *argv[]) {
  fd_set _read, tmp;
  FD_ZERO(&_read);
  FD_SET(0, &_read);  // 0 is file descriptor of standard input

  int max_file_Decriptor = 1;
  struct timeval timeout;
  char buf[BUFSIZE];
  while (1) {
    tmp = _read;
    /*timeout value = 5+ 0.5 = 5.5*/
    timeout.tv_sec = 5;
    timeout.tv_usec = 500000;
    int ret = select(max_file_Decriptor, &tmp, 0, 0, &timeout);
    if (ret == -1) {
      error_handling("select() error");
    } else if (!ret) {
      puts("time out!");
    } else {
      if (FD_ISSET(0, &tmp)) {
        int str_len = read(0, buf, BUFSIZE - 1);
        buf[str_len] = '\0';
        printf("message from stdin: %s", buf);
      }
    }
  }
  return 0;
}

void error_handling(char *message) {
  fputs(message, stderr);
  fputc('\n', stderr);
  exit(1);
}

```
result
select监听标准输入（文件描述符的值为0），并在5.5秒后超时。这里在循环中反复更新tmps和超时值以保证为初始值，是因为**调用 select函数后，除发生变化的文件描述符对应位外，剩下的所有位将初始化为 0。此外，调用 select 函数后，结构体 timeval 的成员 tv_sec 和tv_usec 的值将被替换为超时前剩余时间**
![](attachment/dc0e1a409aa8af1ffdb4d139a565348c.png)
## 12.2 基于select的多路I/O复用回声服务器
接下来，我们用select轮询机制监听多个套接字，仅用一个进程处理多个客户端连接
echo_selectServ.c 
```c
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

const int BUFSIZE = 256;
void error_handling(const char* message);
void childproc_handler(int sig);

int main(int argc, char* argv[]) {
  /* allocate socket*/
  int serv_sock = socket(PF_INET, SOCK_STREAM, 0);

  /*remove time_wait state*/
  int optVal = 1;
  socklen_t optLen = sizeof(optVal);
  setsockopt(serv_sock, SOL_SOCKET, SO_REUSEADDR, &optVal, optLen);

  if (argc != 2) {
    printf("Usage: %s <port>\n", argv[0]);
    exit(1);
  }
  /*initialize ip address and port number*/
  struct sockaddr_in serv_addr;
  memset(&serv_addr, 0, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  serv_addr.sin_port = htons(atoi(argv[1]));

  /*bind ip address and port to socket*/
  if (bind(serv_sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) == -1)
    error_handling("bind() error! \n");

  /* start listening, size of waiting list is 5 */
  listen(serv_sock, 5);
  printf("Server start!\n");

  /* avoid zombie process*/
  struct sigaction act;
  act.sa_handler = childproc_handler;
  act.sa_flags = 0;
  sigemptyset(&act.sa_mask);  // set 0
  sigaction(SIGCHLD, &act, 0);

  char buf[BUFSIZE];
  /*I/O Multiplexing*/
  fd_set _read, cp_read;
  FD_ZERO(&_read);
  FD_SET(serv_sock, &_read);
  int fd_max = serv_sock;
  struct timeval timeout;

  /* single server process, no fork */
  while (1) {
    cp_read = _read;
    timeout.tv_sec = 5;
    timeout.tv_usec = 500000;  // 5.5s
    int ret = select(fd_max + 1, &cp_read, 0, 0, &timeout);
    if (ret == -1) error_handling("select() error!");
    if (!ret)  // timeout
      continue;
    else {
      /* polling */
      for (int i = 0; i < fd_max + 1; ++i) {
        if (FD_ISSET(i, &cp_read)) {
          if (i == serv_sock)  //  Welcoming socket
          {
            /*handle request: create another socket and connect to client */
            struct sockaddr_in clnt_addr;
            socklen_t clnt_addr_size = sizeof(clnt_addr);
            int clnt_sock = accept(serv_sock, (struct sockaddr*)&clnt_addr,
                                   &clnt_addr_size);
            if (clnt_sock == -1) continue;
            FD_SET(clnt_sock, &_read);  // add new file descripter to listen
            fd_max = fd_max < clnt_sock ? clnt_sock : fd_max;
            printf("new client %d connected!\n", clnt_sock);
          } else {
            int str_len = read(i, buf, BUFSIZE);
            if (str_len == 0)  // EOF
            {
              FD_CLR(i, &_read);
              close(i);
              printf("close client %d!\n", i);
            } else {
              write(i, buf, str_len);
            }
          }
        }
      }
    }
  }
  close(serv_sock);
  return 0;
}

void childproc_handler(int sig) {
  int status;
  pid_t pid = waitpid(-1, &status, WNOHANG);
  if (WIFEXITED(status)) {
    printf("Remove child process pid %d\n", WEXITSTATUS(status));
  }
}
void error_handling(const char* message) {
  fputs(message, stderr);
  exit(1);
}
```
result
每次从select函数返回文件描述符状态，就通过`for (int i = 0; i < fd_max + 1; ++i) `**轮询（polling）** 所有文件描述符。客户端的连接请求同样通过传输数据完成，因此如果服务端套接字（welcoming socket）被监听到存在待读取数据，那么就执行受理连接（accept）的分支，并在该分支中把 新创建的与客户端连接的套接字文件描述符 加入监听集合（fd_set）中
客户端1
![](attachment/6999b38db2767845f962114ae262b809.png)
客户端2
![](attachment/4abfe7c56c5bfe63667df3ca40c39b54.png)
服务器端，可见借助I/O复用，单个进程也能在同一时间处理多个客户端的访问（这里提到的同一时间，不是指并发，而是服务端通过轮询，快速的处理各个连接的数据传输，在客户端看来就好像服务端只为自己服务一样）
![](attachment/c4cdc01f6586b7d728e1a4f4eb429295.png)
为什么叫I/O复用
>I/O多路复用是指在一个进程内同时处理多个网络连接的IO。这里的“多个网络连接”的IO，可以是同一时刻发生的，也可以是几乎同一时刻发生的。这种情况下，一个进程能处理多个IO请求，不需要为每个请求都生成一个线程或者进程，这样就大大提高了系统的性能。
>
> 在没有使用 I/O 多路复用技术时，如果服务器要同时处理多个客户端的连接请求，通常的做法是为每一个客户端创建一个新的进程或者线程。这种做法的问题在于，进程或线程的创建和销毁都需要系统资源，而且数量过多时，进程或线程的切换开销也会很大。
>
>而使用 select 这样的 I/O 多路复用技术，服务器只需要在一个进程内部使用非阻塞 I/O，通过 select 轮询所有的文件描述符，查看哪些连接上有数据到来，就可以读取数据，哪些连接可以发送数据，就可以写入数据。这样，一个进程就可以处理多个连接的 I/O 事件，大大提高了服务器的效率。

# 13. 多种I/O函数
之前的程序一直使用系统调用函数write/read实现I/O，接下来介绍网络编程相关的特有I/O函数，这些函数在基本I/O操作的基础上添加了额外的功能
## 13.1. send & recv 函数
![](attachment/f883ce6e3c8bb8fd973fb49ce32a880a.png)
![](attachment/85d221134aabf89b65840eff3c09f9c0.png)
这2个函数的前3个参数与write/read没有什么区别，重点在第3个选项参数， 该选项参数是一个位掩码，每个选项都有一个对应的位标志，可以使用位运算符或`|`组合多个选项，可选项如下
![](attachment/74845e29ed48db34cd6086d6bc20da9b.png)
### 13.1.1 MSG_OOB --- 紧急消息
该可选项发送紧急消息，但不是说发送的紧急消息会先于之前发送的消息到达接受对象，而是督促数据接收对象尽快处理数据。如果把紧急消息理解为需要急诊的病人，那么实际上MSG OOB模式的紧急数据传输无法快速把病人送到医院（TCP 保持传输顺序的传输特性），但可以在医院进行急救。具体来说，**紧急消息一达到接受对象，接受端就对他进行处理**。具体来说，收到MSG-OOB 紧急消息时，操作系统将产生 SIGURG 信号，并调用指定进程的(由fcntl函数指定)注册的信号处理函数 
实例
oob_recv.c
```c
#include <fcntl.h>
#include <netinet/in.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

const int BUFSIZE = 256;
int serv_sock, clnt_sock;
void error_handling(char *message);
void urg_handling(int sig);

int main(int argc, char *argv[]) {
  struct sockaddr_in serv_adr, clnt_adr;
  socklen_t clnt_adr_sz;

  if (argc != 2) {
    printf("Usage : %s <port>\n", argv[0]);
    exit(1);
  }

  serv_sock = socket(PF_INET, SOCK_STREAM, 0);
  if (serv_sock == -1) error_handling("socket() error");

  memset(&serv_adr, 0, sizeof(serv_adr));
  serv_adr.sin_family = AF_INET;
  serv_adr.sin_addr.s_addr = htonl(INADDR_ANY);
  serv_adr.sin_port = htons(atoi(argv[1]));

  if (bind(serv_sock, (struct sockaddr *)&serv_adr, sizeof(serv_adr)) == -1)
    error_handling("bind() error");

  if (listen(serv_sock, 5) == -1) error_handling("listen() error");

  clnt_adr_sz = sizeof(clnt_adr);
  clnt_sock = accept(serv_sock, (struct sockaddr *)&clnt_adr, &clnt_adr_sz);
  if (clnt_sock == -1) error_handling("accept() error");

  /*designate which process's urg_handling function to be invoke*/
  fcntl(clnt_sock, F_SETOWN, getpid());
  struct sigaction act;
  act.sa_handler = urg_handling;
  act.sa_flags = 0;
  sigemptyset(&act.sa_mask);  // set 0
  sigaction(SIGURG, &act, 0);

  int str_len;
  char buf[BUFSIZE];
  while ((str_len = recv(clnt_sock, buf, BUFSIZE - 1, 0)) != 0) {
    buf[str_len] = '\0';
    printf("normal message: %s\n", buf);
  }
  close(clnt_sock);
  close(serv_sock);
  return 0;
}

void error_handling(char *message) {
  fputs(message, stderr);
  fputc('\n', stderr);
  exit(1);
}

/*handle SIGURG signal*/
void urg_handling(int sig) {
  char buf[BUFSIZE];
  int str_len = recv(clnt_sock, buf, BUFSIZE - 1, MSG_OOB);
  buf[str_len] = '\0';
  printf("urgency message: %s\n", buf);
}
```
oob_send.c
```c
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#define BUF_SIZE 1024
void error_handling(char *message);

int main(int argc, char *argv[]) {
  int sock;
  struct sockaddr_in serv_adr;
  if (argc != 3) {
    printf("Usage : %s <IP> <port>\n", argv[0]);
    exit(1);
  }

  sock = socket(PF_INET, SOCK_STREAM, 0);
  if (sock == -1) error_handling("socket() error");

  memset(&serv_adr, 0, sizeof(serv_adr));
  serv_adr.sin_family = AF_INET;
  serv_adr.sin_addr.s_addr = inet_addr(argv[1]);
  serv_adr.sin_port = htons(atoi(argv[2]));

  if (connect(sock, (struct sockaddr *)&serv_adr, sizeof(serv_adr)) == -1)
    error_handling("connect() error!");
  else
    puts("Connected...........");

  write(sock, "123", 3);
  /*only send one byte in urgency*/
  send(sock, "4", 1, MSG_OOB);
  write(sock, "567", 1);
  send(sock, "890", 3, MSG_OOB);

  close(sock);
  return 0;
}

void error_handling(char *message) {
  fputs(message, stderr);
  fputc('\n', stderr);
  exit(1);
}
```
result
这里虽然紧急消息先被打印，不能说明4先于123到达接受端，可能只是处理紧急消息的函数的打印语句先执行了
![](attachment/23effd4530389430ff07087b41d209d6.png)
### 13.1.2 MSG_PEEK & MSG_DONTWAIT --- 非阻塞I/O
设置`MSG_PEEK`选项并调用recv函数时，即使读取了输入缓冲的数据也不会删除，`MSG_DONTWAIT`以非阻塞方式读取数据（即使不存在数据也不发生I/O阻塞）

## 13.2. readv & writev 函数 ---整合缓冲区
![](attachment/163a29bec32e1a69bd1a07ba45084f7f.png)
![](attachment/b99864babc74de9e1be82b015bfa0270.png)
![](attachment/22182d599deb49d5235ee40d9d4cc4d9.png)
其中iovcnt结构如下，是一个**缓冲区数组**
![](attachment/26cd47ed31b59785e60dfaef3950c490.png)
![](attachment/a493a702b6dfcf7b44aa07f76e2588cc.png)
这2个函数对数据进行**整合**发送和接收，具体来说，writev函数可以将分散保存在多个缓冲区的数据一起发送（取代多次调用write函数），readv函数可以将接受的数据分发到多个缓冲区（取代多次调用read函数），仅从函数调用开销这点上，这两个函数就已经优于之前使用的write/read函数了，不仅如此，使用writev函数取代write函数，传输的数据还可能被整合一个数据包（如果放得下的话），而无需多个数据包分别传输。
![](attachment/c9fc963f330a843d9b90d26fb9ea25a1.png)
实例 writev的简单使用
```c
#include <stdio.h>
#include <sys/uio.h>

int main(int argc, char* argv[]) {
  struct iovec buf_vec[2];
  char buf1[] = "abcdef";
  char buf2[] = "123456";
  buf_vec[0].iov_base = buf1;
  buf_vec[0].iov_len = sizeof(buf1);
  buf_vec[1].iov_base = buf2;
  buf_vec[1].iov_len = sizeof(buf2);

  int str_len = writev(1, buf_vec, 2);
  puts("");  // print output buffer(file) content
  printf("message len: %d", str_len);
  return 0;
}
```
result
把2个缓冲区buf1,buf2的数据写入标准输出
![](attachment/d31a6a126fb8b6bd1195b60356a56d09.png)
实例 readv的简单使用
```c
#include <stdio.h>
#include <string.h>
#include <sys/uio.h>

const int BUFSIZE = 48;

int main(int argc, char* argv[]) {
  struct iovec buf_vec[2];
  char buf1[BUFSIZE];
  char buf2[BUFSIZE];
  memset(buf1, 0, sizeof(buf1));
  memset(buf2, 0, sizeof(buf2));

  buf_vec[0].iov_base = buf1;
  buf_vec[0].iov_len = 2;
  buf_vec[1].iov_base = buf2;
  buf_vec[1].iov_len = BUFSIZE;

  int read_len = readv(0, buf_vec, 2);
  printf("buf1: %s\n", buf1);
  printf("buf2: %s\n", buf2);
  printf("read len: %d\n", read_len);
  return 0;
}

```
result
把标准输入的数据写入2个缓冲区buf1,buf2
![](attachment/3a28239fd3032bb07e104fb7d5c62fd3.png)
# 14. 多播和广播
## 14.1. 多播
多播就是一个发送端（sender）发送一次数据（使用UDP传输协议），但是接受到这个数据的有多个接收端（receiver），这通过路由器复制数据包做到。（下图中的“加入AAA组”是一个多播组）
![](attachment/109349f8b81a28d2ee5e8cf40dec1bd2.png)
这些接收端属于同一个多播组(Group)。多播组以一个包含D类IP地址的结构体表示，如果一个主机想要加入一个指定的多播组，这可以通过设置主机的套接字属性完成，即使用setsockopt函数，协议层为`IPPROTO_IP`，选项名为`IP_ADD_MEMBERSHIP`

多播组地址以结构体`struct ip_mreq`表示，第1个成员为加入的多播组的IP地址，第二个成员为加入该组的主机的IP地址（即调用setsockopt函数的主机，可通过INADDR_ANY自动获取IP地址）
![](attachment/ad4573a3613e48fd11a17a4cb9c4c94d.png)
实例
new_sender.c
修改套接字的TTL属性，设置目标多播组地址(一个D类地址)
```c
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

const int BUFSIZE = 256;
void error_handling(const char* message);

int main(int argc, char* argv[]) {
  /*like udp client*/
  int sock = socket(PF_INET, SOCK_DGRAM, 0);
  struct sockaddr_in multicast_addr;

  if (argc != 3) {
    printf("Usage: %s <GroupIP> <Port>\n", argv[0]);
    exit(1);
  }
  memset(&multicast_addr, 0, sizeof(multicast_addr));
  multicast_addr.sin_family = AF_INET;
  multicast_addr.sin_addr.s_addr = inet_addr(argv[1]);
  multicast_addr.sin_port = htons(atoi(argv[2]));

  int TTL_val = 64;
  /* set TTL: Time To Live. Decrement 1 for each router passed*/
  setsockopt(sock, IPPROTO_IP, IP_MULTICAST_TTL, &TTL_val, sizeof(TTL_val));
  FILE* fp = fopen("news.txt", "r");
  if (fp == NULL) error_handling("fopen() error!\n");

  char buf[BUFSIZE];
  if (!feof(fp)) {
    fgets(buf, BUFSIZE, fp);
    sendto(sock, buf, strlen(buf), 0, (struct sockaddr*)&multicast_addr,
           sizeof(multicast_addr));
    sleep(1);
  }
  fclose(fp);
  close(sock);
  return 0;
}

void error_handling(const char* message) {
  fputs(message, stderr);
  exit(1);
}
```
news_receiver.c
加入多播组，端口号与发送端保持一致
```c
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

const int BUFSIZE = 256;
void error_handling(const char* message);

int main(int argc, char* argv[]) {
  int receiver_sock = socket(PF_INET, SOCK_DGRAM, 0);

  if (argc != 3) {
    printf("Usage: %s <GroupIP> <Port> \n", argv[0]);
    exit(1);
  }
  /*join multicast group(type D address)*/
  struct ip_mreq GroupIP;
  GroupIP.imr_interface.s_addr = htonl(INADDR_ANY);
  GroupIP.imr_multiaddr.s_addr = inet_addr(argv[1]);
  setsockopt(receiver_sock, IPPROTO_IP, IP_ADD_MEMBERSHIP, &GroupIP,
             sizeof(GroupIP));

  struct sockaddr_in receiver_addr;
  memset(&receiver_addr, 0, sizeof(receiver_addr));
  receiver_addr.sin_family = AF_INET;
  receiver_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  receiver_addr.sin_port = htons(atoi(argv[2]));

  if (bind(receiver_sock, (struct sockaddr*)&receiver_addr,
           sizeof(receiver_addr)) == -1)
    error_handling("bind() error!\n");

  char buf[BUFSIZE];

  /* parameters NULL and 0 here*/
  int str_len = recvfrom(receiver_sock, buf, BUFSIZE - 1, 0, NULL, 0);
  buf[str_len] = '\0';
  fputs(buf, stdout);

  close(receiver_sock);
  return 0;
}

void error_handling(const char* message) {
  fputs(message, stderr);
  exit(1);
}
```
result
发送端通过端口8080向多播组（地址为`224.1.1.2`，端口号为`8080`）发送数据包，接收端加入该多播组并获取发送到该多播组的数据包
![](attachment/862f9d1e9c9b20554a28e1e688cd8d8f.png)
![](attachment/7ded042bf4640980e87983873057d4b3.png)
![](attachment/e7669d01bffa18877deece6dec9bd039.png)
## 14.2 广播
相比多播可以向不同网络的多个主机发送数据包（只要这些主机在同一个多播组），广播向同一网络（包含本地局域网）内的所有主机发送数据包，如果是特定局域网（称之为直接广播），则目标地址（即广播地址）为该局域网IP地址的网络部分，其余地址取1，例如希望向局域网`192.12.34`中的所有主机发送数据包，那么发送端设置的目标地址应该为`192.12.34`。如果是本地网络（LAN，这样的广播称为本地广播），那么目标地址为本地广播地址`255.255.255.255`

套接字默认是会阻止广播的，通过修改套接字属性`SO_BROADCAST`为真（协议层SOL_SOCKET），可使套接字支持广播
实例
brd_news_sender.c
```c
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

const int BUFSIZE = 256;
void error_handling(const char* message);

int main(int argc, char* argv[]) {
  /*like udp client*/
  int sock = socket(PF_INET, SOCK_DGRAM, 0);
  struct sockaddr_in broadcast_addr;

  if (argc != 3) {
    printf("Usage: %s <BroadcastIP> <Port>\n", argv[0]);
    exit(1);
  }
  /*send data to LAN or specific Area network*/
  memset(&broadcast_addr, 0, sizeof(broadcast_addr));
  broadcast_addr.sin_family = AF_INET;
  broadcast_addr.sin_addr.s_addr = inet_addr(argv[1]);
  broadcast_addr.sin_port = htons(atoi(argv[2]));

  /*socket disable broadcast as default, enable broadcast by set socket option
   * SO_BROADCAST to 1(true)*/
  int enable_brd = 1;
  setsockopt(sock, SOL_SOCKET, SO_BROADCAST, &enable_brd, sizeof(enable_brd));

  FILE* fp = fopen("news.txt", "r");
  if (fp == NULL) error_handling("fopen() error!\n");

  char buf[BUFSIZE];
  if (!feof(fp)) {
    fgets(buf, BUFSIZE, fp);
    sendto(sock, buf, strlen(buf), 0, (struct sockaddr*)&broadcast_addr,
           sizeof(broadcast_addr));
    sleep(1);
  }
  fclose(fp);
  close(sock);
  return 0;
}

void error_handling(const char* message) {
  fputs(message, stderr);
  exit(1);
}
```
brd_news_receiver.c
没有像多播那样加入多播组的操作，因为广播中的接收端所在的组就是自己所在的本地网络 
```c
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

const int BUFSIZE = 256;
void error_handling(const char* message);

int main(int argc, char* argv[]) {
  int receiver_sock = socket(PF_INET, SOCK_DGRAM, 0);

  if (argc != 2) {
    printf("Usage: %s <Port> \n", argv[0]);
    exit(1);
  }

  /*receive data from LAN */
  struct sockaddr_in receiver_addr;
  memset(&receiver_addr, 0, sizeof(receiver_addr));
  receiver_addr.sin_family = AF_INET;
  receiver_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  receiver_addr.sin_port = htons(atoi(argv[1]));

  if (bind(receiver_sock, (struct sockaddr*)&receiver_addr,
           sizeof(receiver_addr)) == -1)
    error_handling("bind() error!\n");

  char buf[BUFSIZE];

  /* parameters NULL and 0 here*/
  int str_len = recvfrom(receiver_sock, buf, BUFSIZE - 1, 0, NULL, 0);
  buf[str_len] = '\0';
  fputs(buf, stdout);

  close(receiver_sock);
  return 0;
}

void error_handling(const char* message) {
  fputs(message, stderr);
  exit(1);
}

```
result
本地广播
![](attachment/41c4f0892de1169794c50963df484479.png)
![](attachment/2e6f780d5fd5a5232239d01996ab3ff5.png)
# 15. 套接字与标准I/O
C语言标准库的标准I/O函数（[fopen](https://en.cppreference.com/w/cpp/io/c/fopen), [fgets](https://en.cppreference.com/w/c/io/fgets), [fputs](https://en.cppreference.com/w/c/io/fputs), [feof](https://en.cppreference.com/w/c/io/feof)）在**性能上优于操作系统提供的系统调用函数**，因为标准I/O函数有**缓冲区**，而系统I/O函数是直接对文件描述符进行读写操作，没有使用缓冲区。使用标准I/O函数进行网络编程时有如下结构，进程的数据先传递到标准I/O函数的缓冲区，然后数据再移动到套接字的输出缓冲
![](attachment/97f32df81fc3d7546128fa27e61dd200.png)
缓冲区是如何提高文件读写性能的？
- 从文件读取数据时，标准I/O库会一次性读取一块数据到输入缓冲区，然后逐个字符地提供给调用者。这样可以减少对底层文件系统的频繁读取，提高效率。
- 当使用标准I/O函数（如`fprintf`、`fputs`）向文件写入数据时，标准I/O库会将数据存储在输出缓冲区中，并在缓冲区满或遇到换行符时才将缓冲区的内容写入到文件中。这样可以减少对底层文件系统的频繁写入，提高效率。（在进行网络通信的情况下，使用标准头文件还可以减少数据包的大小，因为把数据整合到了一个数据包，避免产生了更多的数据包首部）。标准I/O库提供了`fflush`函数用于手动刷新输出缓冲区，可以确保缓冲区的内容立即写入文件。如果没有显式调用`fflush`，标准I/O库也会在适当的时机自动刷新缓冲区
## 15.1 标准I/O函数与系统I/O函数的性能对比
使用这2类函数复制同一份文件的内容，比较用时
sys_IO.c
```c
#include <fcntl.h>
#include <stdio.h>
#include <time.h>
#include <unistd.h>

const int BUFSIZE = 36;

int main(int agrc, char* argv[]) {
  clock_t start_time = clock();
  int fd1 = open("IO_test.txt", O_RDONLY);
  int fd2 = open("cpy1.txt", O_WRONLY | O_TRUNC | O_CREAT);

  int len = 0;
  char buf[BUFSIZE];
  while ((len = read(fd1, buf, BUFSIZE)) > 0) {
    write(fd2, buf, len);
  }

  close(fd1);
  close(fd2);
  clock_t end_time = clock();
  printf("total running time: %f", (double)end_time - start_time);
  return 0;
}
```
std_IO.c
```c
#include <stdio.h>
#include <time.h>

const int BUFSIZE = 36;

int main(int agrc, char* argv[]) {
  clock_t start_time = clock();
  FILE* fp1 = fopen("IO_test.txt", "r");
  FILE* fp2 = fopen("cpy2.txt", "w");

  int len = 0;
  char buf[BUFSIZE];
  while (fgets(buf, BUFSIZE, fp1) != NULL) {
    fputs(buf, fp2);
  }

  fclose(fp1);
  fclose(fp2);
  clock_t end_time = clock();
  printf("total running time: %f", (double)end_time - start_time);
  return 0;
}

```
result
标准I/O函数用时比系统I/O函数少（数据量越大，差异越明显）
![](attachment/a1f87ae9acdc7dc6020914197545e75e.png)
## 15.2. 获取FILE结构体指针
标准I/O函数需要FILE结构体指针以进行文件操作，而创建套接字（socket等系统调用函数）返回的是文件描述符（int 型），因此现在有了这样一个需求：将整型的文件描述符转换为FILE指针。这可以通过fdopen函数做到
![](attachment/a4dad62ccbb06c73cbe6aaf1d9624ba2.png)
实例
```c
#include <fcntl.h>
#include <stdio.h>

int main(int argc, char* argv[]) {
  int fd = open("switch.txt", O_WRONLY | O_CREAT);
  if (fd == -1) {
    fputs("open() error!", stderr);
    return -1;
  }
  FILE* fp = fdopen(fd, "w");
  fputs("switch fd to fp!", fp);
  fclose(fp);  // fd become pointless
  return 0;
}
```
result
实操后发现如果文件描述符是只读形式打开（O_RDONLY），那么使用fdopen转换成FILE指针时，FILE指针不能有写模式。因为FILE指针和文件描述符fd对应相同的文件流，因此只需关闭（fclose(fp) 或 close(fd)）其中一个即可（FILE结构体内部包含一个文件描述符）
>如果多个文件指针对应同一个文件描述符，也就是通过`fdopen`函数将同一个文件描述符转换为多个`FILE`指针，那么只要其中一个文件流调用了`fclose`函数关闭，其他文件流对应的文件描述符会变为无效（悬空描述符）

![](attachment/9eaa644fe65460a3ff069a3afd30e3c6.png)

同样也有把FILE指针转换为文件描述符的函数fileno
![](attachment/ea48e54e6fa29aef0453b3e35f324c99.png)
实例
```c
#include <fcntl.h>
#include <stdio.h>

int main(int argc, char* argv[]) {
  int fd = open("switch.txt", O_WRONLY | O_CREAT);
  if (fd == -1) {
    fputs("open() error!", stderr);
    return -1;
  }
  printf("first file descriptor: %d\n", fd);
  FILE* fp = fdopen(fd, "w");
  fputs("switch fp to fd!", fp);

  printf("second file descriptor: %d\n", fileno(fp));
  fclose(fp);  // fd become pointless
  return 0;
}
```
result
可见经过转换之后得到的文件描述符与初始文件描述符一致
![](attachment/9b7d26eb82fdfeb0823bf9873376f106.png)
## 15.3 使用标准I/O函数的回声服务端/客户端
echo_stdserv.c
```c
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>
const int BUF_SIZE = 256;

void error_handling(const char* message);

int main(int argc, char* argv[]) {
  /* allocate socket*/
  int serv_sock = socket(PF_INET, SOCK_STREAM, 0);

  if (argc != 2) {
    printf("Usage: %s <port>\n", argv[0]);
    exit(1);
  }
  /*initialize ip address and port number*/
  struct sockaddr_in serv_addr;
  memset(&serv_addr, 0, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  serv_addr.sin_port = htons(atoi(argv[1]));

  /*bind ip address and port to socket*/
  if (bind(serv_sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) == -1)
    error_handling("bind() error! \n");

  /* start listening, size of waiting list is 5 */
  listen(serv_sock, 5);
  printf("Server start!\n");

  /*handle request: create another socket and connect to client */
  struct sockaddr_in clnt_addr;
  // function accept need a LValue
  socklen_t clnt_adr_sz = sizeof(clnt_addr);
  char message[BUF_SIZE];

  for (int i = 0; i < 5; ++i) {
    int clnt_sock =
        accept(serv_sock, (struct sockaddr*)&clnt_addr, &clnt_adr_sz);
    if (clnt_sock == -1)
      error_handling("accept() error");
    else
      printf("Connect client %d \n", i + 1);

    FILE* write_fp = fdopen(clnt_sock, "w");
    FILE* read_fp = fdopen(clnt_sock, "r");
    /* standard I/O function*/
    while (!feof(read_fp)) {
      fgets(message, BUF_SIZE, read_fp);
      fputs(message, write_fp);
      fflush(write_fp);
    }
    fclose(write_fp);
    fclose(read_fp);
  }
  close(serv_sock);
  return 0;
}

void error_handling(const char* message) {
  fputs(message, stderr);
  exit(1);
}
```
echo_stdclnt.c
```c
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>
const int BUF_SIZE = 256;  // size of type char
int main(int argc, char* argv[]) {
  /* allocate socket*/
  int clnt_sock = socket(PF_INET, SOCK_STREAM, 0);

  if (argc != 3) {
    printf("Usage: %s <IP> <port> \n", argv[0]);
    exit(1);
  }
  /* target server's ip address and port number*/
  struct sockaddr_in serv_addr;
  memset(&serv_addr, 0, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = inet_addr(argv[1]);
  serv_addr.sin_port = htons(atoi(argv[2]));

  /* connect */
  if (connect(clnt_sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) ==
      -1) {
    printf("connect error!\n");
    exit(1);
  }
  printf("Connected!\n");

  /*use standard function*/
  FILE* write_fp = fdopen(clnt_sock, "w");
  FILE* read_fp = fdopen(clnt_sock, "r");
  char message[BUF_SIZE];
  while (1) {
    puts("Input message(Q to quit)");
    fgets(message, BUF_SIZE, stdin);
    if (!strcmp(message, "q\n") || !strcmp(message, "Q\n")) break;
    fputs(message, write_fp);
    fflush(write_fp);

    fgets(message, BUF_SIZE, read_fp);
    printf("message from server: %s", message);
  }
  fclose(write_fp);
  fclose(read_fp);
  return 0;
}
```
result
![](attachment/96872557390e8e962277030fedc4a0b6.png)
# 16. 分离I/O流
上一节我们使用fdopen函数针对同一个文件描述符（也即同一个套接字）分别创建了读模式和写模式的FILE指针
![](attachment/28c1ba09fe7a1f11a6237c8efda060a6.png)
这样和第10章创建额外的写进程和读进程一样，都实现了I/O流的分离（分离的方式不同，第10章是不同进程分别进行读和写，而第15章是通过不同的文件指针FILE进行读和写）
**接下来我们讨论通过建立2个FILE指针实现I/O分流的模式下怎么实现TCP的半关闭**（第7章），这里具体来说，是关闭输出流（写），保留输入流（读）

首先直接对写模式的FILE指针执行fclose操作是不可行的，这会导致套接字的关闭，如下图
![](attachment/6883be82a206f3ba8fbe6dd0e61316cb.png)
原因在于，2个FILE指针包含同一个文件描述符，当其中一个FILE指针关闭时，对于的文件描述符也会关闭，而因为**这里的套接字只有一个文件描述符**引用它，因此文件描述符关闭后套接字（属于OS）也会被销毁

那么我们考虑复制文件描述符，如下图
![](attachment/eb036696bec1ae639ecf0f055bb72d3c.png)
这种模型下，对其中一个FILE指针调用fclose就不会导致套接字被销毁，因为销毁所有文件描述符后才能销毁套接字。
![](attachment/726b274c0ba4d956454240e26500a109.png)
虽然此时套接字不会被销毁了，但关闭写模式的FILE指针并不能使套接字进入半关闭状态，文件描述符和套接字还是完好的，进程仍然可以利用该套接字进行写操作。我们还是要**通过shutdown函数实现半关闭**（而不是对写模式的FILE指针调用fclose），即使现在多个文件描述符指向套接字(实际上就是图中所示的2个)，但是**对shutdown函数而言，无论复制出多少个文件描述符，它都能使对应套接字进入半关闭状态，并发送EOF**

上述提到的文件描述符的复制，这可以通过以下2个函数做到，第2个函数的第2个参数大小应该大于0且小于进程能生成的最大文件符值
![](attachment/6f2520a761a5f25eab554e4dcf2f16ec.png)
## 16.1 复制文件描述符的简单实例
```c
#include <stdio.h>
#include <unistd.h>

int main(int argc, char* argv[]) {
  int fd = 1;  // standard output
  int cpy_fd1, cpy_fd2;
  char str1[] = "Hello!\n";
  char str2[] = "I am copying file descriptor!\n";

  cpy_fd1 = dup(fd);
  cpy_fd2 = dup2(fd, 6);

  write(cpy_fd1, str1, sizeof(str1));
  write(cpy_fd2, str2, sizeof(str2));
  close(cpy_fd1);
  close(cpy_fd2);
  write(fd, str1, sizeof(str1));
  close(fd);
  write(fd, str2, sizeof(str2)); // no output
  return 0;
}

```
result
![](attachment/9e46757343c689f0f849b94feb36d6ad.png)
## 16.2 使用标准I/O函数(分流)的回声服务端/客户端（半关闭版）
sep_serv.c
```c

#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>
const int BUF_SIZE = 256;

void error_handling(const char* message);

int main(int argc, char* argv[]) {
  /* allocate socket*/
  int serv_sock = socket(PF_INET, SOCK_STREAM, 0);

  if (argc != 2) {
    printf("Usage: %s <port>\n", argv[0]);
    exit(1);
  }
  /*initialize ip address and port number*/
  struct sockaddr_in serv_addr;
  memset(&serv_addr, 0, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  serv_addr.sin_port = htons(atoi(argv[1]));

  /*bind ip address and port to socket*/
  if (bind(serv_sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) == -1)
    error_handling("bind() error! \n");

  /* start listening, size of waiting list is 5 */
  listen(serv_sock, 5);
  printf("Server start!\n");

  /*handle request: create another socket and connect to client */
  struct sockaddr_in clnt_addr;
  // function accept need a LValue
  socklen_t clnt_adr_sz = sizeof(clnt_addr);
  char message[BUF_SIZE];

  for (int i = 0; i < 5; ++i) {
    int clnt_sock =
        accept(serv_sock, (struct sockaddr*)&clnt_addr, &clnt_adr_sz);
    if (clnt_sock == -1)
      error_handling("accept() error");
    else
      printf("Connect client %d \n", i + 1);

    FILE* write_fp = fdopen(clnt_sock, "w");
    FILE* read_fp = fdopen(dup(clnt_sock), "r");
    /* standard I/O function*/
    fputs("From server:\nHi~ client?\n", write_fp);
    fputs("I love all of the world!\n", write_fp);
    fputs("Don't forget to be awesome!\n", write_fp);
    fputs("I will half-close my TCP, bye!\n", write_fp);
    fflush(write_fp);

    shutdown(fileno(write_fp), SHUT_WR);
    fclose(write_fp);
    fgets(message, BUF_SIZE, read_fp);
    fputs(message, stdout);
    fclose(read_fp);
  }
  close(serv_sock);
  return 0;
}

void error_handling(const char* message) {
  fputs(message, stderr);
  exit(1);
}

```
sep_clnt.c
```c
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>
const int BUF_SIZE = 256;  // size of type char
int main(int argc, char* argv[]) {
  /* allocate socket*/
  int clnt_sock = socket(PF_INET, SOCK_STREAM, 0);

  if (argc != 3) {
    printf("Usage: %s <IP> <port> \n", argv[0]);
    exit(1);
  }
  /* target server's ip address and port number*/
  struct sockaddr_in serv_addr;
  memset(&serv_addr, 0, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = inet_addr(argv[1]);
  serv_addr.sin_port = htons(atoi(argv[2]));

  /* connect */
  if (connect(clnt_sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) ==
      -1) {
    printf("connect error!\n");
    exit(1);
  }
  printf("Connected!\n");

  /*use standard function*/
  FILE* write_fp = fdopen(clnt_sock, "w");
  FILE* read_fp = fdopen(clnt_sock, "r");
  char message[BUF_SIZE];
  while (1) {
    if (fgets(message, BUF_SIZE, read_fp) == NULL) break;
    fputs(message, stdout);
    fflush(stdout);
  }
  fputs("From client: Thank u! server.\n", write_fp);
  fflush(write_fp);
  fclose(write_fp);
  fclose(read_fp);
  return 0;
}
```
result
服务端半关闭后保留输入流，接受来自客户端的信息
![](attachment/e0ddbec755fe4c813cf665611bfe78ab.png)
![](attachment/d7787ba004de77d6f964b0260cc1356f.png)

# 17. 优于select的epoll
## 17.1 epoll机制
在第12章我们用select函数实现了多路I/O复用，该机制通过传递一个文件描述符的监视集合fd_set给select，select借助操作系统（套接字是操作系统管理的，监听套接字必然涉及操作系统）监视文件描述符的变化（事件捕获），并返回发生了事件的文件描述符集合。如果fd_set被修改，将导致**每次调用select获取套接字状态时都要传递一次fd_set**，而select函数又要将fd_set（监视对象信息）传递给底层的操作系统，因此是一件很降低性能的事情（需要进入OS内核）。不仅如此，select函数返回的fd_set包含所有文件描述符，只对发生了事件（如有数据写入）的文件描述符进行的标记（保持为1），因此每次返回后都需要通过**for循环轮询**的找出发生了变化的文件描述符。这2点性能消耗，导致select函数无法构建出高并发的服务器

基于解决这两点目的，我们希望有这样一个I/O事件通知机制，我**只需要传递一次监视对象信息**，该机制在监视对象出现变化时**只返回发生了变化的文件描述符集合**（而不是全部文件描述符）。linux下的epoll就能实现这样的机制，epoll机制有一下几个步骤
1. **创建存储监视对象的内存空间** 
在操作系统中（内核空间）申请（创建）用于保存监视对象的内存空间，这可以通过**epoll_create**函数（参数size没有意义）做到。这块内存空间被称为**epoll例程**，被视为一个文件，epoll_create创建该文件后会返回相应的文件描述符用于后续向该块内存注册监视对象
![](attachment/0745931c08cc5015da0e35ccf0984ebc.png)
2. **注册监视对象** 
在OS内核中有了存储监视对象（指套接字，包括服务端套接字serv_sock和与客户端连接的套接字clnt_sock）的文件描述符的内存空间之后，可以使用**epoll_ctl**函数向该内存中注册（加入）新的监视对象，这里的ctl指的是control，我理解为控制监视对象集合。该函数如下
![](attachment/671af7cac42a41e8e98db40b2ed86578.png)
![](attachment/823c1d0841a9d09d7a72407350a1b326.png)
其中第2个参数的取值为以下宏
![](attachment/57e9038151c031f2adb8568f4ff32d9a.png)
第4个参数的结构体定义如下，epoll机制下最后返回发生了变化（事件）的文件描述符集合也是存储在该结构体中
![](attachment/2e462d16f4ce6466be1ec73bf098f62f.png)
其中的数据成员fd表示待注册的文件描述符，数据成员events代表了要监听的事件，取值为以下宏（可以通过位或叠加）
![](attachment/c6ab561fb0c84df0c107b3cc5b30f429.png)
来看一个使用epoll_ctl函数注册的实例：
![](attachment/63ad6506247c65fe743163bc67decaae.png)
这段代码将文件描述符sockfd注册到epoll例程epfd 中 ，并在需要读取数据的情况下产生相应事件
3. **获取发生事件的文件描述符集合**
**epoll_wait**函数返回发生了变化的文件描述符集合（如果设置了timeout且在一段时间内没有套接字发生事件，则该函数触发超时，返回0）。这里的第2个参数是一个预先分配了内存的 `struct epoll_event` 结构体数组的指针，数组大小由第3个参数决定。为了正确地使用 `epoll_wait` 函数，需要先动态分配足够大的内存空间，然后将指向该内存空间的指针传递给 `epoll_wait` 函数。在函数返回后，可以根据实际发生的事件数量（返回值）来处理相应的文件描述符和事件类型。
epoll_wait在发生以下2个情况时返回
- 有就绪事件发生，分为条件触发和边缘触发。
- 指定的超时时间到达
![](attachment/c4d3d7614b8a16a1aae8b97eaebb8a6d.png)
## 17.2 基于epoll的多路I/O复用回声服务器
echo_epollserv.c
```c
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/epoll.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <unistd.h>

const int BUFSIZE = 256;
const int EPOLL_SIZE = 24;
void error_handling(const char* message);
void childproc_handler(int sig);

int main(int argc, char* argv[]) {
  /* allocate socket*/
  int serv_sock = socket(PF_INET, SOCK_STREAM, 0);

  /*remove time_wait state*/
  int optVal = 1;
  socklen_t optLen = sizeof(optVal);
  setsockopt(serv_sock, SOL_SOCKET, SO_REUSEADDR, &optVal, optLen);

  if (argc != 2) {
    printf("Usage: %s <port>\n", argv[0]);
    exit(1);
  }
  /*initialize ip address and port number*/
  struct sockaddr_in serv_addr;
  memset(&serv_addr, 0, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  serv_addr.sin_port = htons(atoi(argv[1]));

  /*bind ip address and port to socket*/
  if (bind(serv_sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) == -1)
    error_handling("bind() error! \n");

  /* start listening, size of waiting list is 5 */
  listen(serv_sock, 5);
  printf("Server start!\n");

  /* avoid zombie process*/
  struct sigaction act;
  act.sa_handler = childproc_handler;
  act.sa_flags = 0;
  sigemptyset(&act.sa_mask);  // set 0
  sigaction(SIGCHLD, &act, 0);

  char buf[BUFSIZE];

  /*epoll*/
  /*apply space for file descriptor*/
  int epoll_fd = epoll_create(EPOLL_SIZE);

  /*register file descriptor*/
  struct epoll_event register_event;
  register_event.events = EPOLLIN;
  register_event.data.fd = serv_sock;
  epoll_ctl(epoll_fd, EPOLL_CTL_ADD, serv_sock, &register_event);

  /*define event to receive result*/
  struct epoll_event* result_event;
  result_event = malloc(sizeof(struct epoll_event) * EPOLL_SIZE);
  /* start listening multiple sockets! */
  while (1) {
    int event_cnt = epoll_wait(epoll_fd, result_event, EPOLL_SIZE, -1);
    if (event_cnt == -1) error_handling("epoll_wait() error!");

    for (int i = 0; i < event_cnt; ++i) {
      if (result_event[i].data.fd == serv_sock) {
        struct sockaddr_in clnt_addr;
        socklen_t clnt_addr_size = sizeof(clnt_addr);
        int clnt_sock =
            accept(serv_sock, (struct sockaddr*)&clnt_addr, &clnt_addr_size);
        if (clnt_sock == -1) continue;

        register_event.events = EPOLLIN;
        register_event.data.fd = clnt_sock;
        epoll_ctl(epoll_fd, EPOLL_CTL_ADD, clnt_sock, &register_event);
        printf("new client %d connected!\n", clnt_sock);
      } else {
        int str_len = read(result_event[i].data.fd, buf, BUFSIZE);
        if (str_len == 0)  // EOF
        {
          epoll_ctl(epoll_fd, EPOLL_CTL_DEL, result_event[i].data.fd, NULL);
          close(result_event[i].data.fd);
          printf("close client %d!\n", result_event[i].data.fd);
        } else {
          write(result_event[i].data.fd, buf, str_len);
        }
      }
    }
  }
  close(serv_sock);
  close(epoll_fd);
  free(result_event);
  return 0;
};

void childproc_handler(int sig) {
  int status;
  pid_t pid = waitpid(-1, &status, WNOHANG);
  if (WIFEXITED(status)) {
    printf("Remove child process pid %d\n", WEXITSTATUS(status));
  }
}
void error_handling(const char* message) {
  fputs(message, stderr);
  exit(1);
}
```
result
更高性能的服务端
服务端
![](attachment/7c0426de98a4eec6d98a1893b03f765e.png)
客户端1
![](attachment/bdc64fa9524902c44b939b2003761b24.png)
客户端2
![](attachment/53c20744ee235177ad2cfd12b32581f5.png)
客户端3
![](attachment/9a51669450b6f94c29603ed9fb8154ed.png)
## 17.3 条件触发与边缘触发
触发触发，到底触发了什么？我的理解是触发了epoll_wait返回，以告诉服务端发生了相应事件
>在 epoll 中，"触发"指的是某个事件发生后，`epoll_wait` 函数返回并告知程序哪些文件描述符发生了事件。
### 17.3.1 条件触发
epoll默认以条件触发（Level-Triggered）方式工作，在条件触发模式下，只要有文件描述符处于就绪状态，`epoll_wait` 将不断返回该文件描述符的事件（当监听的文件描述符集合中有事件就绪时，`epoll_wait` 将立即返回），直到该事件被处理（比如读取完输入缓冲区中的数据，或写入完输出缓冲区）并不再就绪。比如服务端的一个客户端连接套接字从客户端收到了数据，在数据被读取完之前，epoll_wait将不断被该事件触发返回
实例：
下面通过打印语句看看epoll_wait的返回次数(触发次数，没有设置超时)
echo_epollserv.c
```c
-  const int BUFSIZE = 256;
+  const int BUFSIZE = 5; // keep some data in socket after read
+  puts("return epoll_wait!");
```
result
可以看出，虽然客户端只传递过来了一则消息，但因为套接字的输入缓冲中一直有数据，在条件触发模式下，这将一直触发epoll_wait通知该事件给服务端进程
![](attachment/9433ef50bca559f83736e6aa3bc18b2b.png)
![](attachment/10670ae32be0a74bee48a716ef28f926.png)
### 17.3.2 边缘触发
在边缘触发（Edge-Triggered）模式下，`epoll_wait` 只会在文件描述符状态发生变化时才返回，即当文件描述符从未就绪状态切换到就绪状态时，`epoll_wait` 返回该事件。如果文件描述符一直处于就绪状态，`epoll_wait` 不会重复返回该事件，直到文件描述符的状态发生变化。以接受数据后准备好读这一事件为例，边缘触发模式下，epoll_wait仅在套接字的输入缓冲收到数据时被触发，返回（通知）该事件给服务端进程。

要使文件描述符以边缘触发的方式触发epoll_wait返回，那么在注册文件描述符时（epoll_ctl函数），在监视对象的事件类型这个参数中添加EPOLLET，如下
```c
/* Edge Trigger*/
register_event.events = EPOLLIN | EPOLLET;
register_event.data.fd = clnt_sock;
epoll_ctl(epoll_fd, EPOLL_CTL_ADD, clnt_sock, &register_event);
```
实例
仅修改事件类型，而对其他代码不做修改，看看会发生什么
echo_epollserv_ET.c，
```c
- register_event.events = EPOLLIN ;
+ register_event.events = EPOLLIN | EPOLLET;
```
result
边缘触发模式下，epoll_wait仅在输入缓冲接受数据时被触发，而在输入缓冲有数据（即文件描述符保持处于发生了事件的就绪状态）不被触发（如果设置了超时那么会返回0，否则程序一直阻塞等待事件），这意味这**如果数据输入时没有被服务端进程全部读取完毕，那么剩余的输入缓冲的数据将一直保留，直到发生下一次输入事件（从而epoll_wait可以再次告诉服务端进程读取）**。

从结果我们可以看出，服务端的epoll_wait只返回了一次，在第2次执行epoll_wait时进入阻塞，而客户端也因为接受服务端返回数据的read函数没有读取到count个字符而陷入阻塞。
![](attachment/b91103e4c2b56e52941d20d8b57a9f38.png)
![](attachment/a8a6889c476226905e937cee14904ec3.png)

下面我们针对边缘模式修改回声服务器的读写操作，保证服务端在发生接收数据事件时能读取完输入缓冲中的全部数据，并修改I/O方式为**非阻塞I/O**

fcntl函数可以让我们修改套接字（文件）进行非阻塞I/O，fcntl的意思是file control，该函数常用来操纵文件描述符，函数声明和使用方式（示例中的第3个参数0可以被省略）如下
![](attachment/7197e8463192b89d19f16175a87106b3.png)
修改套接字为非阻塞文件（以非阻塞 I/O方式进行操作的文件）之后，使用read/write对其进行读写时，如果文件没有准备好数据（例如读取）或无法立即接受数据（例如写入），I/O 操作不会阻塞（即不会等待），而是立即返回，并**将 errno 设置为 EAGAIN**。这是一个表示暂时不可用的错误码。EAGAIN 表示 "Try Again"，意味着当前操作无法立即完成，但稍后可以重试。这样，程序可以继续执行其他任务，而不必一直等待 I/O 操作的完成。

实例
实现边缘触发的回声服务器
```c
#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/epoll.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <unistd.h>

const int BUFSIZE = 5;
const int EPOLL_SIZE = 24;
void error_handling(const char* message);
void childproc_handler(int sig);

int main(int argc, char* argv[]) {
  /* allocate socket*/
  int serv_sock = socket(PF_INET, SOCK_STREAM, 0);

  /*remove time_wait state*/
  int optVal = 1;
  socklen_t optLen = sizeof(optVal);
  setsockopt(serv_sock, SOL_SOCKET, SO_REUSEADDR, &optVal, optLen);

  if (argc != 2) {
    printf("Usage: %s <port>\n", argv[0]);
    exit(1);
  }
  /*initialize ip address and port number*/
  struct sockaddr_in serv_addr;
  memset(&serv_addr, 0, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  serv_addr.sin_port = htons(atoi(argv[1]));

  /*bind ip address and port to socket*/
  if (bind(serv_sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) == -1)
    error_handling("bind() error! \n");

  /* start listening, size of waiting list is 5 */
  listen(serv_sock, 5);
  printf("Server start!\n");

  /* avoid zombie process*/
  struct sigaction act;
  act.sa_handler = childproc_handler;
  act.sa_flags = 0;
  sigemptyset(&act.sa_mask);  // set 0
  sigaction(SIGCHLD, &act, 0);

  char buf[BUFSIZE];

  /*epoll*/
  /*apply space for file descriptor*/
  int epoll_fd = epoll_create(EPOLL_SIZE);

  /*register file descriptor*/
  struct epoll_event register_event;
  register_event.events = EPOLLIN;
  register_event.data.fd = serv_sock;
  epoll_ctl(epoll_fd, EPOLL_CTL_ADD, serv_sock, &register_event);

  /*define event to receive result*/
  struct epoll_event* result_event;
  result_event = malloc(sizeof(struct epoll_event) * EPOLL_SIZE);
  /* start listening multiple sockets! */
  while (1) {
    int event_cnt = epoll_wait(epoll_fd, result_event, EPOLL_SIZE, -1);
    if (event_cnt == -1) error_handling("epoll_wait() error!");

    puts("return epoll_wait!");
    for (int i = 0; i < event_cnt; ++i) {
      if (result_event[i].data.fd == serv_sock) {
        struct sockaddr_in clnt_addr;
        socklen_t clnt_addr_size = sizeof(clnt_addr);
        int clnt_sock =
            accept(serv_sock, (struct sockaddr*)&clnt_addr, &clnt_addr_size);
        if (clnt_sock == -1) continue;

        /*non block I/O*/
        int flag = fcntl(clnt_sock, F_GETFL);
        fcntl(clnt_sock, flag | O_NONBLOCK);

        /* Edge Trigger*/
        register_event.events = EPOLLIN | EPOLLET;
        register_event.data.fd = clnt_sock;
        epoll_ctl(epoll_fd, EPOLL_CTL_ADD, clnt_sock, &register_event);
        printf("new client %d connected!\n", clnt_sock);
      } else {
        while (1) {
          int str_len = read(result_event[i].data.fd, buf, BUFSIZE);
          if (str_len == 0)  // EOF
          {
            epoll_ctl(epoll_fd, EPOLL_CTL_DEL, result_event[i].data.fd, NULL);
            close(result_event[i].data.fd);
            printf("close client %d!\n", result_event[i].data.fd);
          } else if (str_len < 0 && errno == EAGAIN) {
            break;
          } else {
            write(result_event[i].data.fd, buf, str_len);
          }
        }
      }
    }
  }
  close(serv_sock);
  close(epoll_fd);
  free(result_event);
  return 0;
};

void childproc_handler(int sig) {
  int status;
  pid_t pid = waitpid(-1, &status, WNOHANG);
  if (WIFEXITED(status)) {
    printf("Remove child process pid %d\n", WEXITSTATUS(status));
  }
}
void error_handling(const char* message) {
  fputs(message, stderr);
  exit(1);
}

```
result
同样的回声服务，但是已经是进阶版了，借助边缘触发模式下的epoll机制，现在的回声服务器已经可以做到高并发了！
![](attachment/2ccc5b60c725957d2c1880f16dfb6595.png)
![](attachment/a8dfc303dc5fc4cf52b0c3be1053f60e.png)

因为条件触发会更频繁的触发epoll_wait，因此边缘触发更有可能带来高性能，但边缘触发要保证更精确的处理机制（如回声服务器中的读取完所有数据），以确保不错过事件。

# 18. 多线程服务器的实现
## 18.1 创建线程
使用pthread_create函数在进程中创建线程
![](attachment/c0e7c57c19734875c8944902eaff4552.png)
实例
![](attachment/cce4f553ae7e502afb27df0fb899a6c6.png)
thread1.c
```c
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void* thread_main(void* arg);
void error_handling(const char* message);

int main(int argc, char* argv[]) {
  pthread_t thread_id;
  int thread_param = 6;

  /* create pthread*/
  if (pthread_create(&thread_id, NULL, thread_main, (void*)&thread_param) !=
      0) {
    error_handling("pthread_create() error!");
  }

  sleep(8);
  puts("end of process");
  return 0;
}

void* thread_main(void* arg) {
  int cnt = *((int*)arg);
  for (int i = 0; i < cnt; ++i) {
    puts("thread is running");
    sleep(1);
  }
  return NULL;
}

void error_handling(const char* message) {
  fputs(message, stderr);
  exit(1);
}
```
result
![](attachment/5e8fbf9ade9e104851bb777f6dda2fde.png)

我们应该保证当前进程结束之前，其分出去的线程也应该结束，否则进程结束时会结束一切未结束运行的线程，如下图
![](attachment/bb95b0d9a2aa498a6025e9b4d9e3ff58.png)
使用pthread_join函数可以实现这一点，调用该函数的进程在指定ID（该函数的参数）的线程结束之前，进入等待状态。注意该函数的第二个参数，应该传入一个指针的地址，在函数内部，status作为一个二级指针指向传入的一级指针thr_ret，并通过status修改thr_ret的值，使其指向线程的返回值
![](attachment/f01e4195b049ba1ef3112af3f536e789.png)
此外，线程不会自动销毁，如果进程是一个服务器端，该进程分出了线程处理与客户端连接的套接字，那么在连接结束之后这些线程应该被销毁，使用pthread_detach函数可以引导线程销毁，且不会像pthread_join函数（也会引导线程销毁）阻塞调用它的进程
![](attachment/c3ab74154eecfadae8dd5a1e0da260cd.png)

实例
thread2.c
```c
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void* thread_main(void* arg);
void error_handling(const char* message);

int main(int argc, char* argv[]) {
  pthread_t thread_id;
  int thread_param = 6;
  void* thr_ret;

  /* create pthread*/
  if (pthread_create(&thread_id, NULL, thread_main, (void*)&thread_param) != 0)
    error_handling("pthread_create() error!");

  if (pthread_join(thread_id, &thr_ret) != 0)
    error_handling("pthread_join() error!\n");

  printf("Thread return message: %s", (char*)thr_ret);
  free(thr_ret);
  puts("end of process");
  return 0;
}

void* thread_main(void* arg) {
  int cnt = *((int*)arg);
  char* ret_msg = (char*)malloc(sizeof(char) * 27);
  strcpy(ret_msg, "Hello! I am thread~\n");
  for (int i = 0; i < cnt; ++i) {
    puts("thread is running");
    sleep(1);
  }
  return (void*)ret_msg;
}

void error_handling(const char* message) {
  fputs(message, stderr);
  exit(1);
}
```
result
进程在线程退出之前陷入等待状态
![](attachment/225a97b9cb9542ffbba1933ed858d1ec.png)
![](attachment/2fdceacbdaa445eeeac006cf1d773622.png)
## 18.2 多线程下的同步问题
可以用多个线程来完成一个任务的不同部分，比如计算1到10的加和，我可以创建一个thread1执行1到5的加和，创建一个thread2执行6到10的加和。这样的编程模型称为 工作线程模型。该模型的关键在于解决临界区问题，即多个线程同时访问一个资源。假设有一个全局变量num，初始值为0，thread1对num执行+1操作，而thread2也对num执行+1操作，那么就会出现临界区问题而导致num的值不可控。具体来说， 即使线程会分时使用CPU，不会发生严格意义上的同时访问num变量，但是存在这样的情况：thread1对num执行+1操作后，在将运算结果写入内存的num之前，num就被刚切换到的thread2读取了，那么thread2读取的就是thread1执行修改前的旧值
![](attachment/ae0095e8768a0611eccb3a7fedc7365c.png)
![](attachment/a6d6ce74d6ed68d0261ec67ede3f2166.png)
### 18.2.1 互斥量
线程同步机制用来解决临界区问题，我们可以在thread1访问num时给num上锁（禁止其它线程访问），在离开num时开锁（允许其它线程访问）。这个锁，具体来说就是一个互斥量mutex（可以理解为最大数量为1的信号量）。
pthread_mutex_init函数可以初始化一个互斥锁，pthread_mutex_distory函数销毁互斥锁
![](attachment/528705a66305d17553e8b3c14460c7d8.png)
![](attachment/88c8935e0ec4b03c448a9413554d0aef.png)
下面这两个函数负责上锁和开锁操作
![](attachment/fbf6c0865a7a67dc30f6bfbb38d6f857.png)
![](attachment/74a33b4116b3084c2e1de584462a48da.png)
实例
mutex.c
```c
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void* thread_des(void* msg);
void* thread_inc(void* msg);
const int num_thread = 100;
const int max_inc_des = 100;

long long num = 0;
pthread_mutex_t mutex;

int main(int argc, char* argv[]) {
  pthread_t thread_id[num_thread];
  /* initialize a mutex*/
  pthread_mutex_init(&mutex, NULL);

  for (int i = 0; i < num_thread; ++i) {
    if (i % 2)
      pthread_create(&thread_id[i], NULL, thread_inc, NULL);
    else
      pthread_create(&thread_id[i], NULL, thread_des, NULL);
  }
  for (int i = 0; i < num_thread; ++i) pthread_join(thread_id[i], NULL);

  puts("Caculate sum by using worker thread model!");
  printf("result: %lld\n", num);
  pthread_mutex_destroy(&mutex);
  return 0;
}

void* thread_inc(void* msg) {
  /*keep critical section*/
  /*thread synchronization*/
  pthread_mutex_lock(&mutex);
  for (int i = 0; i < max_inc_des; ++i) num += i;
  pthread_mutex_unlock(&mutex);
  return NULL;
}

void* thread_des(void* msg) {
  for (int i = 0; i < max_inc_des; ++i) {
    pthread_mutex_lock(&mutex);
    num -= i;
    pthread_mutex_unlock(&mutex);
  }
  return NULL;
}
```
result
用两个线程对初始值为0的num执行相同次数的加1减1操作，在互斥量的同步机制协调下，得到正确结果0
![](attachment/58c93d7bb8e5bc3234fe382d3022cc0a.png)
### 18.2.2 信号量
创建/销毁信号量
![](attachment/04cc5370858e890d726e3d8180552292.png)
![](attachment/99ca7a929dd0276e2b65edbed79beb1a.png)
修改信号量的值
![](attachment/0df18684be0f948d01f8448e61b5876e.png)
实例
semaphore.c
```c
#include <pthread.h>
#include <semaphore.h>
#include <stdio.h>

void* _read(void* arg);
void* accumulate(void* arg);
int num = 0;
int sum = 0;
static sem_t sem_empty;
static sem_t sem_full;
int main(int argc, char* argv[]) {
  sem_init(&sem_empty, 0, 1);
  sem_init(&sem_full, 0, 0);

  pthread_t th_id1, th_id2;

  pthread_create(&th_id1, NULL, _read, NULL);
  pthread_create(&th_id2, NULL, accumulate, NULL);

  pthread_join(th_id1, NULL);
  pthread_join(th_id2, NULL);

  puts("worker thread model under semaphore mechanism!");
  printf("result: %d\n", sum);

  sem_destroy(&sem_empty);
  sem_destroy(&sem_full);
  return 0;
}

void* _read(void* arg) {
  for (int i = 0; i < 6; ++i) {
    fputs("Input num: ", stdout);
    sem_wait(&sem_empty);
    scanf("%d", &num);
    sem_post(&sem_full);
  }
  return NULL;
}

void* accumulate(void* arg) {
  for (int i = 0; i < 6; ++i) {
    sem_wait(&sem_full);
    sum += num;
    sem_post(&sem_empty);
  }
  return NULL;
}
```
result
这里的信号量最大值为1,因此与互斥量等价
![](attachment/613a4d54e2bd2abff076e7e0458c625e.png)
## 18.3 多线程并发聊天服务器
chat_server.c
`clnt_cnt`和套接字数组`clnt_socks_arr`是临界资源
```c
#include <arpa/inet.h>
#include <bits/pthreadtypes.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#define MAX_CLNT 100
const int BUFSIZE = 256;

int clnt_cnt = 0;
int clnt_socks_arr[MAX_CLNT];
pthread_mutex_t mutex;
void error_handling(const char* message);
void send_msg_to_clnt(char* msg, int len);
void* handle_clnt(void* arg);

int main(int argc, char* argv[]) {
  /* allocate socket*/
  int serv_sock = socket(PF_INET, SOCK_STREAM, 0);

  /*remove time_wait state*/
  int optVal = 1;
  socklen_t optLen = sizeof(optVal);
  setsockopt(serv_sock, SOL_SOCKET, SO_REUSEADDR, &optVal, optLen);

  if (argc != 2) {
    printf("Usage: %s <port>\n", argv[0]);
    exit(1);
  }
  /*initialize ip address and port number*/
  struct sockaddr_in serv_addr;
  memset(&serv_addr, 0, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  serv_addr.sin_port = htons(atoi(argv[1]));

  /*bind ip address and port to socket*/
  if (bind(serv_sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) == -1)
    error_handling("bind() error! \n");

  /* start listening, size of waiting list is 5 */
  listen(serv_sock, 5);
  puts("Server start!");

  /*thread*/
  pthread_t t_id;
  /*mutex*/
  pthread_mutex_init(&mutex, NULL);

  struct sockaddr_in clnt_addr;
  socklen_t clnt_addr_size = sizeof(clnt_addr);
  while (1) {
    int clnt_sock =
        accept(serv_sock, (struct sockaddr*)&clnt_addr, &clnt_addr_size);
    pthread_mutex_lock(&mutex);
    clnt_socks_arr[clnt_cnt++] = clnt_sock;
    pthread_mutex_unlock(&mutex);

    pthread_create(&t_id, NULL, handle_clnt, (void*)&clnt_sock);
    pthread_detach(t_id);
    printf("Connected client IP: %s \n", inet_ntoa(clnt_addr.sin_addr));
  }
  close(serv_sock);
  return 0;
}

void* handle_clnt(void* arg) {
  int clnt_sock = *((int*)arg);
  char msg[BUFSIZE];
  int str_len;

  while ((str_len = read(clnt_sock, msg, BUFSIZE)) != 0)
    send_msg_to_clnt(msg, str_len);

  // remove current connection from server
  pthread_mutex_lock(&mutex);
  for (int i; i < clnt_cnt; ++i) {
    if (clnt_socks_arr[i] == clnt_sock) {
      while (i++ < clnt_cnt - 1)  // tilt array ,remove current client
        clnt_socks_arr[i] = clnt_socks_arr[i + 1];
      break;
    }
  }
  --clnt_cnt;
  pthread_mutex_unlock(&mutex);
  close(clnt_sock);
  return NULL;
}

/*send msg to all client*/
void send_msg_to_clnt(char* msg, int len) {
  pthread_mutex_lock(&mutex);
  for (int i = 0; i < clnt_cnt; ++i) write(clnt_socks_arr[i], msg, len);
  pthread_mutex_unlock(&mutex);
}

void error_handling(const char* message) {
  fputs(message, stderr);
  exit(1);
}
```
chat_clnt.c
```c
#include <arpa/inet.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#define BUF_SIZE 256
#define NAME_SIZE 256
void error_handling(char *message);
void write_routine(int sock, char *message);
void read_routine(int sock, char *message);
void *send_msg(void *msg);
void *recv_msg(void *msg);
char msg[BUF_SIZE];
char name[NAME_SIZE] = "[DEFAULT]";

int main(int argc, char *argv[]) {
  int sock;
  struct sockaddr_in serv_adr;

  if (argc != 4) {
    printf("Usage : %s <IP> <port> <name>\n", argv[0]);
    exit(1);
  }

  sprintf(name, "[%s]", argv[3]);
  sock = socket(PF_INET, SOCK_STREAM, 0);
  if (sock == -1) error_handling("socket() error");

  memset(&serv_adr, 0, sizeof(serv_adr));
  serv_adr.sin_family = AF_INET;
  serv_adr.sin_addr.s_addr = inet_addr(argv[1]);
  serv_adr.sin_port = htons(atoi(argv[2]));

  if (connect(sock, (struct sockaddr *)&serv_adr, sizeof(serv_adr)) == -1)
    error_handling("connect() error!");
  else
    puts("Connected...........");

  pthread_t snd_thread_id;
  pthread_t rsv_thread_id;

  pthread_create(&snd_thread_id, NULL, send_msg, &sock);
  pthread_create(&rsv_thread_id, NULL, recv_msg, &sock);
  void *thread_ret;
  pthread_join(snd_thread_id, &thread_ret);
  pthread_join(rsv_thread_id, &thread_ret);
  return 0;
}

void *send_msg(void *arg) {
  int sock = *((int *)arg);
  char msg_with_name[BUF_SIZE + NAME_SIZE + 1];
  while (1) {
    fgets(msg, BUF_SIZE, stdin);
    if (!strcmp(msg, "q\n") || !strcmp(msg, "q\n")) {
      close(sock);
      exit(1);
    }
    sprintf(msg_with_name, "%s: %s", name, msg);
    write(sock, msg_with_name, strlen(msg_with_name));
  }
  return NULL;
}

void *recv_msg(void *arg) {
  int sock = *((int *)arg);
  char msg_with_name[BUF_SIZE + NAME_SIZE + 1];
  while (1) {  // keep reading
    int str_len = read(sock, msg_with_name, NAME_SIZE + BUF_SIZE - 1);
    if (str_len == -1) error_handling("read() error!");
    msg_with_name[str_len] = '\0';
    fputs(msg_with_name, stdout);
  }
  return NULL;
}

void error_handling(char *message) {
  fputs(message, stderr);
  fputc('\n', stderr);
  exit(1);
}
```
result
服务端
![](attachment/509eb60af8a5c7093baf73d47bf5d13a.png)
客户端1
![](attachment/d543a47e1e28e125e8f5b48257862c6d.png)
客户端2
![](attachment/973738379cdbe3dbb10731e1dc1a4944.png)
客户端3
![](attachment/75b33d9fa43748fb352135223df754bd.png)

# 19. 终章---多线程Web服务器
```c
#include <arpa/inet.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#define BUFSIZE 256
#define LITTLE_BUF 100

void error_handling(char* msg);
void* request_handler(void* arg);
void send_data(FILE* fp, char* cont_type, char* file_name);
void send_error(FILE* fp);
char* Get_Content_Type(char* path_to_file);

int main(int argc, char* argv[]) {
  int serv_sock = socket(PF_INET, SOCK_STREAM, 0);
  /*remove time_wait state*/
  int optVal = 1;
  socklen_t optLen = sizeof(optVal);
  setsockopt(serv_sock, SOL_SOCKET, SO_REUSEADDR, &optVal, optLen);

  if (argc != 2) {
    printf("Usage: %s <port>\n", argv[0]);
    exit(1);
  }
  /*initialize ip address and port number*/
  struct sockaddr_in serv_addr;
  memset(&serv_addr, 0, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  serv_addr.sin_port = htons(atoi(argv[1]));

  /*bind ip address and port to socket*/
  if (bind(serv_sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) == -1)
    error_handling("bind() error! \n");

  /* start listening, size of waiting list is 5 */
  listen(serv_sock, 20);
  puts("WebServer start!");

  struct sockaddr_in clnt_addr;
  socklen_t clnt_addr_size = sizeof(clnt_addr);
  pthread_t t_id;
  int cnt = 0;
  while (1) {
    int clnt_sock =
        accept(serv_sock, (struct sockaddr*)&clnt_addr, &clnt_addr_size);
    printf("Connection request from client %d\n", cnt++);
    /*create a thread handle a connection*/
    pthread_create(&t_id, NULL, request_handler, &clnt_sock);
    pthread_detach(t_id);
  }
  close(serv_sock);
  return 0;
}

void* request_handler(void* arg) {
  int clnt_sock = *((int*)arg);

  /*I/O division*/
  FILE* write_fp = fdopen(clnt_sock, "w");
  FILE* read_fp = fdopen(dup(clnt_sock), "r");

  /*parse request line*/
  char req_line[LITTLE_BUF];
  char method[20];
  char file_name[20];
  char cont_type[20];

  /*get request line from request message*/
  fgets(req_line, LITTLE_BUF, read_fp);

  /*check if it is HTTP protocol*/
  if (strstr(req_line, "HTTP/") == NULL) {
    send_error(write_fp);
    fclose(write_fp);
    fclose(read_fp);
    return NULL;
  }
  /* function strtok is used to extract different part which is divided by '\'
   * in request line*/
  strcpy(method, strtok(req_line, " /"));
  strcpy(file_name, strtok(NULL, " /"));
  strcpy(cont_type, Get_Content_Type(file_name));
  /*check if it is GET method*/
  if (strcmp(method, "GET") != 0) {
    send_error(write_fp);
    fclose(write_fp);
    fclose(read_fp);
    return NULL;
  }
  fclose(read_fp);
  send_data(write_fp, cont_type, file_name);
  return NULL;
}

/*determine the value of Content-Type in HTTP message header*/
char* Get_Content_Type(char* path_to_file) {
  char extension[LITTLE_BUF];

  /* aviod path_to_file modified by function strtok*/
  char file_name[LITTLE_BUF];
  strcpy(file_name, path_to_file);

  /*get file extension which represent content type*/
  strtok(file_name, ".");
  strcpy(extension, strtok(NULL, "."));
  if (!strcmp(extension, "html") || !strcmp(extension, "htm")) {
    return "text/html";
  } else
    return "text/plain";
}

void send_error(FILE* fp) {
  /*status line and header*/
  char protocol[] = "HTTP/1.1 400 Bad Request\r\n";
  char date[] = "Date: Fri, 7 July 2023 2:12:09 GMT\r\n";
  char server[] = "Server: Linux Web server\r\n";
  char cntLen[] = "Content-Length: 1024\r\n";
  char cntType[] = "Content-Type: text/html\r\n\r\n";

  /*entity body*/
  char content[] =
      "<html><head><title>NETWORK</title></head>"
      "<body><font size=+5><br>Error occured! Please check filename or request "
      "method!"
      "</font></body></html>";

  fputs(protocol, fp);
  fputs(date, fp);
  fputs(server, fp);
  fputs(cntLen, fp);
  fputs(cntType, fp);
  fputs(content, fp);
  fflush(fp);
}

void send_data(FILE* fp, char* cont_type, char* file_name) {
  /*define request line and header*/
  char protocol[] = "HTTP/1.1 200 OK\r\n";
  char server[] = "Server: Linux Web server\r\n";
  char cntLen[] = "Content-Length: 1048\r\n";
  char cntType[LITTLE_BUF];
  sprintf(cntType, "Content-Type: %s\r\n\r\n", cont_type);

  /*open target file*/
  FILE* target_file = fopen(file_name, "r");
  if (target_file == NULL) {
    send_error(fp);
    return;
  }
  /*send request line and header*/
  fputs(protocol, fp);
  fputs(server, fp);
  fputs(cntLen, fp);
  fputs(cntType, fp);
  /*send entity body*/
  char buf[BUFSIZE];
  while (fgets(buf, BUFSIZE, target_file) != NULL) {
    fputs(buf, fp);
    fflush(fp);
  }
  fflush(fp);
  fclose(target_file);
  fclose(fp);
}

void error_handling(char* msg) {
  fputs(msg, stderr);
  exit(1);
}
```
result
最简单的web服务器模型，唯一的难点在于处理客户端发来的http格式的请求，用函数[strstr](https://en.cppreference.com/w/c/string/byte/strstr)验证消息是HTTP请求，用函数[strtok](https://en.cppreference.com/w/cpp/string/byte/strtok)（分割字符串）从HTTP请求消息中提取请求方法，目标文件等
访问`http://localhost:8080/index.html`
![](attachment/395435efb284241fb9b42c6fd8cf0415.png)
访问`http://localhost:8080/error.html`
![](attachment/81a4a706601a796624df931b264aaf0e.png)
