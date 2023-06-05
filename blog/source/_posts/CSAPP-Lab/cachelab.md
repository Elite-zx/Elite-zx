---
title: "[CSAPP] cachelab"
date: 2023/03/16
categories:
- CSAPP
tags: 
- Foundation
---

<meta name="referrer" content="no-referrer"/>
<a name="HHpvX"></a>

# lab4 cachelab
<!--more-->

## 1. 要做什么

1. 组索引位数 -s  （$S = 2^s$为高速缓存组的组数）
2. 高速缓存行数 -E 
3. 块偏移位数 -b （$B = 2^b$为高速缓存块的大小）

根据内存访问记录，输出每条访问的结果（hit/miss/evict)，输出操作通过调用`printSummary(hit_count, miss_count, eviction_count)`函数完成，输出结果应当与作者提供给我们的`reference cache simulator`相同，运行`make`+`./test-csim`获取评分
<a name="i3aH1"></a>
## 2. getopt函数的用法
由于三个参数通过命令行输入，因此我们需要通过C语言库中的`getopt`函数，结合switch语句从命令行中获取参数值 <br />C语言中的`main`函数是程序的入口函数，它包含两个参数：`argc`和`argv`。它们的作用如下：

1. argc参数

argc参数表示程序运行时命令行参数的个数（argument count），包括程序名本身。因此，argc的值至少为1，即第一个参数是程序名本身。如果程序没有接受任何命令行参数，则argc的值为1。

2. argv参数

argv参数是一个字符串指针数组（argument vector），每个元素指向一个命令行参数。其中，argv[0]指向程序名本身，argv[1]、argv[2]等等依次指向后续的命令行参数。<br />通过argc和argv参数，程序可以接收命令行传递的参数，从而实现更加灵活和可配置的功能。例如，可以通过命令行参数指定程序要处理的文件名、程序要使用的配置文件、程序要输出的日志级别等等。程序可以根据不同的命令行参数采取不同的行为，从而实现更加灵活和可配置的功能。<br />C语言中的`getopt`函数可以帮助程序解析命令行参数。`getopt`函数通常与`argc`和`argv`参数一起使用，可以从命令行中提取选项和参数，并根据需要执行相应的操作。以下是`getopt`函数的一般用法：
```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
    int opt;
    while ((opt = getopt(argc, argv, "abc:d")) != -1) {
        switch (opt) {
            case 'a':
                printf("Option -a\n");
                break;
            case 'b':
                printf("Option -b\n");
                break;
            case 'c':
                printf("Option -c with value '%s'\n", optarg);
                break;
            case 'd':
                printf("Option -d\n");
                break;
            case '?':
                printf("Unknown option: %c\n", optopt);
                break;
        }
    }
    return 0;
}

```
在上面的例子中，`getopt`函数的第一个参数是`argc`，第二个参数是`argv`，第三个参数是一个字符串，它包含可接受的选项和参数信息。在这个字符串中，每个字符表示一个选项，如果这个选项需要接受一个参数，则在后面加上一个冒号。例如，`"abc:d"`表示可接受的选项有`-a`、`-b`、`-c`和`-d`，其中`-c`选项需要接受一个参数。<br />`getopt`函数会循环遍历命令行中的所有选项，每次返回一个选项和其参数（如果有）。在循环中，使用`switch`语句根据选项进行相应的操作。如果`getopt`函数发现了一个未知的选项，它会返回`?`,并将这个选项保存在`optopt`变量中。<br />以下是一些示例命令行及其对应的输出：
```bash
$ ./a.out -a -b -c filename -d
Option -a
Option -b
Option -c with value 'filename'
Option -d
```
```bash
$ ./a.out -a -b -c
Option -a
Option -b
Unknown option: c
```
在使用`getopt`函数时，需要注意以下几点：

1. 在循环中，`optarg`变量保存当前选项的参数（如果有），可以通过这个变量获取参数的值。变量类型为字符串，可通过`atoi`函数转化为整型。
2. 如果一个选项需要接受一个参数，但是没有给出参数，或者参数不合法，`getopt`函数会返回`?`，并将这个选项保存在`optopt`变量
3. 如果一个选项在可接受的选项字符串中没有指定，`getopt`函数会返回`-1`，并结束循环

`getopt`函数的第三个参数是一个字符串，用于指定程序支持的命令行选项和参数。<br />虽然`getopt`函数可以遍历所有命令行参数，但是在不指定可接受选项字符串的情况下，`getopt`函数不知道哪些参数是选项，哪些是参数，也不知道选项是否需要参数。指定<br />可接受选项字符串可以告诉`getopt`函数哪些选项是合法的，以及它们是否需要参数，从而使`getopt`函数能够正确地解析命令行参数。接受选项字符串的格式为一个字符串，由选项和参数组成，每个选项用一个字符表示，如果选项需要参数，则在选项字符后面跟一个冒号。例如，字符串`"ab:c"`表示程序支持三个选项`-a`、`-b`和`-c`, 其中`-c`选项需要一个参数。
<a name="kBmQw"></a>
## 3. fscanf的用法
`fscanf`是C语言标准库中的一个函数，它可以从一个文件中读取格式化数据，并将读取的结果存储到指定的变量中，该函数返回成功填充参数列表的项目数。`fscanf`函数的基本格式如下：
```c
int fscanf(FILE *stream, const char *format, ...);
```
其中，第一个参数`stream`是指向要读取数据的文件的指针；第二个参数`format`是一个字符串，用于指定读取数据的格式；第三个及之后的参数是要读取数据的变量名。<br />例如，如果你有一个文件`data.txt`，里面包含了三个整数，每个整数之间用空格分隔，你可以使用下面的代码将这些整数读取到三个变量`a`、`b`、`c`中
```c
#include <stdio.h>

int main() {
    FILE *fp = fopen("data.txt", "r");
    int a, b, c;
    fscanf(fp, "%d %d %d", &a, &b, &c);
    printf("a = %d, b = %d, c = %d\n", a, b, c);
    fclose(fp);
    return 0;
}
```
在上面的例子中，`fscanf`函数的第一个参数是文件指针`fp`，第二个参数是格式化字符串`"%d %d %d"`，它表示要读取三个整数，每个整数之间用空格分隔。第三个、第四个和第五个参数分别是三个整数变量`a`、`b`、`c`的地址，`fscanf`函数将读取到的整数存储到这些变量中。最后，我们打印出这些变量的值，以检查是否正确读取了文件中的数据。
<a name="dKoHs"></a>
## 4. 编写程序
这个实验不是真的让你去实现一个cache，而是让你编写一个能对访问记录进行应答的程序，这也是为什么writeup里强调所有的内存访问操作所需的块都不会超过行的容量<br />![yuque_diagram.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1678952903754-2052873c-6eb8-47c2-84e6-48ae84c0df8f.png)

1. cache结构声明

cache本质上是一个2D array，因此我们在结构体中声明一个指向二维数组的指针
```cpp
typedef struct cache_line
{
	int valid_bit;
	int tag;
    int time_stamp;
}cache_line;

typedef struct cache
{
	int S;
	int E;
	int B;
	cache_line** Cache; 
}cache;
```

2. main

主要在于正确解析命令行参数，会用`getopt`就行
```cpp
int main(int argc, char* argv[])
{ 	
    int	hit_count = 0, miss_count = 0, eviction_count = 0;
    int s, E, b,opt;
    char* trace_name = (char*)malloc(sizeof(char)*30);
    cache* my_cache;
    while((opt = getopt(argc, argv, "s:E:b:t:"))!= -1){
		switch(opt){
		case 's':
		   s = atoi(optarg);
		   break;
		case 'E':
		   E = atoi(optarg);
		   break;
		case 'b':
		   b = atoi(optarg);
		   break;
		case 't':
		   strcpy(trace_name,optarg);
		   break;
		case '?':
		   printf("unknown option: %c\n",optopt);
		   break;
		   }
     }
     my_cache = construct_cache(s,E,b);
     access_cache(my_cache, s, b, trace_name, &hit_count, &miss_count, &eviction_count);
     free_cache(my_cache);
     printSummary(hit_count, miss_count, eviction_count);
     return 0;
 }
```

3. construct_cache

根据输入的命令行参数`s`,`E`,`b`构造cache，并初始化每一个高速缓存行
```cpp
 cache* construct_cache(int s, int E, int b)
 {
     cache* my_cache =(cache*) malloc(sizeof(cache));  // construct Cache
	 my_cache->S = 1 << s;
	 my_cache->B = 1 << b;
	 my_cache->E = E;
	 my_cache->Cache = (cache_line**)malloc(my_cache->S * sizeof(cache_line*) );
	 for(int i=0; i<my_cache->S;++i)
	 {
		my_cache->Cache[i] = (cache_line*)malloc(my_cache->E * sizeof(cache_line));
		for(int j=0; j<my_cache->E; ++j) // initialize
		{
			my_cache->Cache[i][j].valid_bit = 0;
			my_cache->Cache[i][j].tag = -1;
			my_cache->Cache[i][j].time_stamp = 0;
		}

	}
	return my_cache;
 }
```

4. update_LRU

我是通过对每个高速缓冲行维护一个time_stamp实现的LRU，因此更新Cache中各行的LRU操作很重要。对访问的行，time_stamp置0，有效位和tag位也要做更新，其余行的time_stamp加1
```cpp
void update_LRU(cache* my_cache, int ad_set, int ad_tag, int line_index)
{
	for (int i = 0; i < my_cache->E; ++i)
		if(my_cache->Cache[ad_set][i].valid_bit) ++(my_cache->Cache[ad_set][i].time_stamp);

	my_cache->Cache[ad_set][line_index].time_stamp = 0;
	my_cache->Cache[ad_set][line_index].valid_bit = 1;
	my_cache->Cache[ad_set][line_index].tag = ad_tag;
}
```

5. get_line_index

每次访问cache，要得知hit，miss，eviction等信息，通过该函数实现：查找cache中所有行，如果找到有效位为1且tag位符合的行，则命中，否则miss
```cpp
int get_line_index(cache* my_cache, int ad_set, int ad_tag)
{
	for (int i = 0; i < my_cache->E; ++i)
	{
		if(my_cache->Cache[ad_set][i].valid_bit && my_cache->Cache[ad_set][i].tag == ad_tag)
			return i;  // hit
	}
	return -1; // miss
}
```

6. is_not_full

。进一步对miss，遍历cache所有行，如果找不到有效位为0的行，则说明cache is full，那么就额外涉及有eviction操作
```cpp
int is_not_full(cache* my_cache, int ad_set)
{
	for (int i = 0; i < my_cache->E; ++i)
		if(!my_cache->Cache[ad_set][i].valid_bit) return i;

	return -1;
}
```

7. find_LRU

对eviction操作，执行我们的LRU替换策略，先找到时间戳最大的行，再进行覆盖操作
```cpp
int find_LRU(cache* my_cache, int ad_set)
{
	int max_stamp = 0;
	int evict_line = 0;
	int temp = 0;
	for (int i = 0; i < my_cache->E; ++i)
	{
		temp = my_cache->Cache[ad_set][i].time_stamp;
		if(temp > max_stamp)
			{
				max_stamp = temp;
				evict_line = i;
			}
	}
	return evict_line;
}
```

8. access_cache

我们需要用`fscanf`对数据访问操作进行解析，注意此处的`" %c %x,%d"`,`%c`前有一个whitespace，目的在于忽略对指令访问操作。由于不同数据访问指令执行的cache操作次数不同，因此我将对cache进行操作的部分分割成一个独立的函数`real_access_cache`。M等于L+S，因此需要两次更新。
```cpp
void access_cache(cache* my_cache, int s, int b, char* trace_name, int* hit_count_ptr, int* miss_count_ptr, int* eviction_count_ptr)
 {
 	 FILE* pFile;   // receive access
     pFile = fopen(trace_name,"r");
     if(!pFile) exit(-1);
     char identifier;
     unsigned address;
     int size;
     while(fscanf(pFile," %c %x,%d",&identifier,&address,&size)>0)
     {     
		int mask =(unsigned)(-1)>>(64-s);
		int ad_set = (address >> b) & mask;
		int ad_tag = address >> (s+b);
		switch(identifier)
		{
		case 'M':
			real_access_cache(my_cache, ad_set, ad_tag, hit_count_ptr, miss_count_ptr, eviction_count_ptr);
			real_access_cache(my_cache, ad_set, ad_tag, hit_count_ptr, miss_count_ptr, eviction_count_ptr);
			break;
		case 'L':
			real_access_cache(my_cache, ad_set, ad_tag, hit_count_ptr, miss_count_ptr, eviction_count_ptr);
			break;
		case 'S':
			real_access_cache(my_cache, ad_set, ad_tag, hit_count_ptr, miss_count_ptr, eviction_count_ptr);
			break;
		}
	}
	fclose(pFile);
 }

 void real_access_cache(cache* my_cache, int ad_set, int ad_tag, int* hit_count_ptr, int* miss_count_ptr, int* eviction_count_ptr)
 {
    int line_index,free_line, evict_line;
	line_index = get_line_index(my_cache, ad_set, ad_tag);
	if(line_index != -1)
	{
		++(*hit_count_ptr);
		update_LRU(my_cache, ad_set, ad_tag, line_index);
	}

	else 
	{
		free_line = is_not_full(my_cache, ad_set);
		if(free_line != -1)
		{
			++(*miss_count_ptr);
			update_LRU(my_cache, ad_set, ad_tag, free_line);
		}

		else
		{
			++(*miss_count_ptr);
			++(*eviction_count_ptr);
			evict_line = find_LRU(my_cache,ad_set);
			update_LRU(my_cache, ad_set, ad_tag, evict_line);
		}
		
	}	
}
```
<a name="XOedv"></a>
## 5. 结果
![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1678885115012-43a6dad1-7672-42f8-b302-42c04af83585.png)

