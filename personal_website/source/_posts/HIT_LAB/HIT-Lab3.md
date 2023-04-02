---
title: HIT-OSLab3
date: 2023/04/2
categories:
- OS
tags: 
- Foundation
---

<meta name="referrer" content="no-referrer"/>

# 实验3 进程运行轨迹的跟踪与统计
---
<a name="Vy8dW"></a>
## 1. 前提
<!--more-->
1. 系统调用times

`times`系统调用接受一个`struct tms*`类型的参数，该结构体用于保存进程和其子进程的 CPU 时间信息，同时 times 系统调用会返回一个滴答数，即时钟周期数，该滴答数表示自OS启动以来经过的时钟周期数。<br />`struct tms`类型在`include/sys/times.h`中定义如下：<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1680080228119-8e4f099c-80bb-400b-a9c4-1707bb900cb4.png#averageHue=%23fcfbfa&clientId=uf8821459-f9ef-4&from=paste&height=294&id=u5c5af96f&name=image.png&originHeight=463&originWidth=915&originalType=binary&ratio=1.3499999046325684&rotation=0&showTitle=false&size=86220&status=done&style=none&taskId=u227088fb-be53-4659-8beb-57d4b3ebbc7&title=&width=581.77783203125)<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1680081641847-9ce0ae8e-ea7d-426d-982a-c4ab275e0050.png#averageHue=%23fdfcfc&clientId=uf8821459-f9ef-4&from=paste&height=81&id=u1e48b640&name=image.png&originHeight=109&originWidth=1188&originalType=binary&ratio=1.3499999046325684&rotation=0&showTitle=false&size=24401&status=done&style=none&taskId=u110b85ba-8c80-4079-ae38-3ccfc24a576&title=&width=880.0000621654414)<br />`tms_stime`和`tms_utime`分别记录了进程在内核态和用户态下消耗的CPU时间总和，它们的和就是进程从开始执行到调用times系统调用所经过的时间。`tms_stime`和`tms_utime`并不包括进程在睡眠状态或等待I/O操作中所消耗的时间，因此它们的和也不等于进程的实际运行时间。<br />注意这里时间的单位是CPU的滴答时间（tick），一个滴答数表示两个时钟中断的间隔。在Linux系统中，时钟中断通常由硬件定时器产生，定时器会以固定的频率向CPU发送中断信号。**每当时钟中断发生时，内核会将当前进程的时间片计数器减 1，内核会检查当前进程的时间片（counter）是否已经用完，如果用完了，就将当前进程放到就绪队列中，然后调用调度函数 schedule 选择一个新的进程运行。**这个频率通常是100Hz，即一秒发生100次，也就是说时间中断的间隔为10ms（1/100s），每隔10ms就发生一次时钟中断，linux内核中的`jiffies`变量就记录了时间中断的个数，即滴答数。那么可以看出这里的时间单位既然是滴答数，而滴答数10ms产生一个，那么实际时间应该是 $ticks/100$ (秒)，100是常量`HZ`的值<br />由此，如果想获取一个进程从开始到结束的CPU使用时间，即用户态下CPU时间和内核态下CPU时间之和，可用如下函数
```cpp
#include <stdio.h>
#include <sys/times.h>
#include <unistd.h>

int main() {
    struct tms t;
    clock_t clock_time;

    // 获取进程的CPU时间统计信息
    clock_time = times(&t);

    // 计算进程的总的CPU时间
    double cpu_time = (double)(t.tms_utime + t.tms_stime) / HZ;

    printf("Total CPU time: %.2f seconds\n", cpu_time);

    return 0;
}

```
用到的`clock_t`在`include/time.h`中定义如下    ![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1680082042776-a6814d15-253d-43cb-be0a-4d3e2fa9819e.png#averageHue=%23fdfcfb&clientId=uf8821459-f9ef-4&from=paste&height=67&id=uf3bbfd6f&name=image.png&originHeight=91&originWidth=1143&originalType=binary&ratio=1.3499999046325684&rotation=0&showTitle=false&size=24657&status=done&style=none&taskId=ub62b64bd-cb85-441a-bfbf-5d591e528b7&title=&width=846.6667264773564)

2. 系统调用wait

`wait` 函数是一个系统调用（位于`include/sys/wait.h`）。在Unix/Linux操作系统中，`wait`函数可以等待子进程结束，并获取子进程的退出状态。在使用`wait`函数时，如果子进程已经结束，`wait`函数会立即返回并返回子进程的退出状态；如果子进程还没有结束，`wait`函数会阻塞父进程，直到子进程结束并返回其退出状态。具体来说，`wait` 函数的作用如下：<br />1 如果当前进程没有子进程，`wait` 函数会立即返回 `-1`，并设置 `errno` 为 `ECHILD`，表示当前进程没有子进程需要等待。<br />2 如果当前进程有一个或多个子进程正在运行，调用 `wait` 函数会阻塞当前进程，直到其中一个子进程结束。当子进程结束时，`wait `函数会返回该子进程的进程 ID，并将该子进程的退出状态保存到一个整型变量`status`中。<br />3 如果当前进程有多个子进程正在运行，调用`wait`函数会等待其中任意一个子进程结束，并且无法指定要等待哪个子进程。如果需要等待特定的子进程，可以使用 `waitpid`函数代替`wait`函数。<br />需要注意的是，如果当前进程没有调用wait函数等待其子进程结束，那么当子进程结束时，其退出状态可能会一直保存在内核中，直到当前进程调用`wait`或`waitpid`函数获取该状态。如果当前进程没有获取子进程的退出状态，那么该子进程就会成为僵尸进程（Zombie Process），占用系统资源并且无法被正常清理。<br />因此，在编写多进程程序时，通常需要在父进程中调用`wait`或`waitpid`函数等待子进程结束，并获取其退出状态，以避免产生僵尸进程。<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1680090411853-3ca6d5fc-a85f-4018-b853-38d6b5eab55c.png#averageHue=%23f0f0f0&clientId=ud7b45409-87b8-4&from=paste&height=245&id=uc11188b1&name=image.png&originHeight=383&originWidth=1132&originalType=binary&ratio=1.5625&rotation=0&showTitle=false&size=153979&status=done&style=none&taskId=ue946029c-b4a7-4c74-903e-d7348704955&title=&width=724.48)<br />对linux0.11 wait函数必须接受一个`int`参数以保存子进程退出状态，如果你不想保存该信息，可传递`NULL`。而在现代linux中，该参数为可选参数。

3. linux0.11，进程的state值

在Linux 0.11中，进程状态可以被表示为以下几个值：

1. `TASK_RUNNING`：进程正在执行，也就是说CPU正在执行它的指令。但是，如果一个进程的状态为`TASK_RUNNING`，而它又没有占用CPU时间片运行，那么它就是处于就绪态。
2. `TASK_INTERRUPTIBLE`：进程正在等待某个事件的发生（例如，等待用户输入、等待网络数据等），它已经睡眠，并且可以响应一个信号以退出等待状态。
3. `TASK_UNINTERRUPTIBLE`：和`TASK_INTERRUPTIBLE`一样，进程也是正在等待某个事件的发生，但是进程在等待期间不会响应信号，直到事件发生后才会退出等待状态，比如I/O操作。
4. `TASK_STOPPED`：进程已经被停止，通常是收到了一个SIGSTOP信号。

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1680423221854-cc012464-a635-471f-8978-9e5a9bca7ae9.png#averageHue=%23fbf9f7&clientId=u36208795-4bd0-4&from=paste&height=151&id=u89a07fa0&name=image.png&originHeight=204&originWidth=1173&originalType=binary&ratio=1.3499999046325684&rotation=0&showTitle=true&size=108104&status=done&style=none&taskId=u3d9817ff-dff7-4f86-84ad-0f193cbddb3&title=include%2Flinux%2Fsched.h&width=868.888950269413 "include/linux/sched.h")
<a name="BqcgZ"></a>
## 2. process.c
```cpp
#include<unistd.h>
#include<stdio.h>
#include<time.h>
#include<sys/times.h>
#include<sys/types.h>
#include<sys/wait.h>
void cpuio_bound(int last, int cpu_time, int io_time);


void main(int argc, char* argv[])
{
	pid_t son_proc_pid[21];
	int i = 0 ;
	while(i<21)
	{
		if(! (son_proc_pid[i] = fork()))
		{
			cpuio_bound(20,i,20-i);
			return;
		}
		++i;
	}

	i = 0;
	while(i<21)
	{
		printf("child_process_pid: %d\n", son_proc_pid[i]);
		++i;
	
	wait(NULL);
}

void cpuio_bound(int last, int cpu_time, int io_time)
{
	struct tms start, pre;
	clock_t sum_cpu_time = 0 ;
	clock_t accumulate =0;

	while(1)
	{
		times(&start);
		while(sum_cpu_time < cpu_time)
		{
			times(&pre);
			sum_cpu_time = (pre.tms_utime - start.tms_utime + pre.tms_stime - pre.tms_stime)/100;
		}

		if(sum_cpu_time>=last) break;  

		sleep(io_time);   
		if((accumulate+= io_time + cpu_time)>=last)
			break;
	}	
}
```
![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1680091964283-677f3934-2877-4b47-bb90-8de524ca7631.png#averageHue=%23016b01&clientId=ueafc2590-6fa1-4&from=paste&height=560&id=u6a843c73&name=image.png&originHeight=875&originWidth=1271&originalType=binary&ratio=1.5625&rotation=0&showTitle=false&size=321878&status=done&style=none&taskId=u1fca88b5-6987-447d-a8dc-b9523e8f249&title=&width=813.44)
<a name="TtxLI"></a>
## 3. 生成log的前置工作

1. 修改`linux-0.11/init/main.c`，将文件描述符`3`与`process.log`关联。文件描述符是一个非负整数，它是操作系统内部用来标识一个特定文件的引用。

![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1680092845738-eb1c4f7b-85cd-4bda-8eaf-a3c9f2965bd9.png#averageHue=%23404040&clientId=uf8821459-f9ef-4&from=paste&height=356&id=u59def16c&name=image.png&originHeight=480&originWidth=1482&originalType=binary&ratio=1.3499999046325684&rotation=0&showTitle=false&size=257225&status=done&style=none&taskId=u48dfe7b1-b671-4b96-b4c4-ab3217f6fa5&title=&width=1097.777855327596)

2. 在内核中添加`fprintk`函数用于在程序中调用以写入log文件
```cpp
#include <linux/sched.h>
#include <sys/stat.h>

static char logbuf[1024];
int fprintk(int fd, const char *fmt, ...)
{
    va_list args;
    int count;
    struct file * file;
    struct m_inode * inode;

    va_start(args, fmt);
    count=vsprintf(logbuf, fmt, args);
    va_end(args);

    if (fd < 3)    /* 如果输出到stdout或stderr，直接调用sys_write即可 */
    {
        __asm__("push %%fs\n\t"
            "push %%ds\n\t"
            "pop %%fs\n\t"
            "pushl %0\n\t"
            "pushl $logbuf\n\t" /* 注意对于Windows环境来说，是_logbuf,下同 */
            "pushl %1\n\t"
            "call sys_write\n\t" /* 注意对于Windows环境来说，是_sys_write,下同 */
            "addl $8,%%esp\n\t"
            "popl %0\n\t"
            "pop %%fs"
            ::"r" (count),"r" (fd):"ax","cx","dx");
    }
    else    /* 假定>=3的描述符都与文件关联。事实上，还存在很多其它情况，这里并没有考虑。*/
    {
        if (!(file=task[0]->filp[fd]))    /* 从进程0的文件描述符表中得到文件句柄 */
            return 0;
        inode=file->f_inode;

        __asm__("push %%fs\n\t"
            "push %%ds\n\t"
            "pop %%fs\n\t"
            "pushl %0\n\t"
            "pushl $logbuf\n\t"
            "pushl %1\n\t"
            "pushl %2\n\t"
            "call file_write\n\t"
            "addl $12,%%esp\n\t"
            "popl %0\n\t"
            "pop %%fs"
            ::"r" (count),"r" (file),"r" (inode):"ax","cx","dx");
    }
    return count;
}
```

3. 修改fork.c

进程在创建后就立马被设置为就绪态`TASK_RUNNING`<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1680418919364-03d91541-3641-4d47-a424-34ea2bca802d.png#averageHue=%23340a19&clientId=uf67f330f-a4ae-4&from=paste&height=204&id=u37425a43&name=image.png&originHeight=276&originWidth=1287&originalType=binary&ratio=1.3499999046325684&rotation=0&showTitle=false&size=89012&status=done&style=none&taskId=u293f4087-df5d-429c-990e-d462e4a802f&title=&width=953.3334006792281)

4. 修改sched.c

在进程的状态切换点打印进程的状态信息
```c
/*
 *  linux/kernel/sched.c
 *
 *  (C) 1991  Linus Torvalds
 */

/*
 * 'sched.c' is the main kernel file. It contains scheduling primitives
 * (sleep_on, wakeup, schedule etc) as well as a number of simple system
 * call functions (type getpid(), which just extracts a field from
 * current-task
 */
#include <linux/sched.h>
#include <linux/kernel.h>
#include <linux/sys.h>
#include <linux/fdreg.h>
#include <asm/system.h>
#include <asm/io.h>
#include <asm/segment.h>

#include <signal.h>

#define _S(nr) (1<<((nr)-1))
#define _BLOCKABLE (~(_S(SIGKILL) | _S(SIGSTOP)))

void show_task(int nr,struct task_struct * p)
{
    int i,j = 4096-sizeof(struct task_struct);

    printk("%d: pid=%d, state=%d, ",nr,p->pid,p->state);
    i=0;
    while (i<j && !((char *)(p+1))[i])
        i++;
    printk("%d (of %d) chars free in kernel stack\n\r",i,j);
}

void show_stat(void)
{
    int i;

    for (i=0;i<NR_TASKS;i++)
        if (task[i])
            show_task(i,task[i]);
}

#define LATCH (1193180/HZ)

extern void mem_use(void);

extern int timer_interrupt(void);
extern int system_call(void);

union task_union {
    struct task_struct task;
    char stack[PAGE_SIZE];
};

static union task_union init_task = {INIT_TASK,};

long volatile jiffies=0;
long startup_time=0;
struct task_struct *current = &(init_task.task);
struct task_struct *last_task_used_math = NULL;

struct task_struct * task[NR_TASKS] = {&(init_task.task), };

long user_stack [ PAGE_SIZE>>2 ] ;

struct {
    long * a;
    short b;
} stack_start = { & user_stack [PAGE_SIZE>>2] , 0x10 };
/*
 *  'math_state_restore()' saves the current math information in the
 * old math state array, and gets the new ones from the current task
 */
void math_state_restore()
{
    if (last_task_used_math == current)
        return;
    __asm__("fwait");
    if (last_task_used_math) {
        __asm__("fnsave %0"::"m" (last_task_used_math->tss.i387));
    }
    last_task_used_math=current;
    if (current->used_math) {
        __asm__("frstor %0"::"m" (current->tss.i387));
    } else {
        __asm__("fninit"::);
        current->used_math=1;
    }
}

/*
 *  'schedule()' is the scheduler function. This is GOOD CODE! There
 * probably won't be any reason to change this, as it should work well
 * in all circumstances (ie gives IO-bound processes good response etc).
 * The one thing you might take a look at is the signal-handler code here.
 *
 *   NOTE!!  Task 0 is the 'idle' task, which gets called when no other
 * tasks can run. It can not be killed, and it cannot sleep. The 'state'
 * information in task[0] is never used.
 */
void schedule(void)
{
    int i,next,c;
    struct task_struct ** p;

    /* check alarm, wake up any interruptible tasks that have got a signal */

    for(p = &LAST_TASK ; p > &FIRST_TASK ; --p)
        if (*p) {
            if ((*p)->alarm && (*p)->alarm < jiffies) {
                (*p)->signal |= (1<<(SIGALRM-1));
                (*p)->alarm = 0;
            }
            if (((*p)->signal & ~(_BLOCKABLE & (*p)->blocked)) &&
                (*p)->state==TASK_INTERRUPTIBLE)
            {
                (*p)->state=TASK_RUNNING;
                /*可中断睡眠 => 就绪*/
                fprintk(3,"%d\tJ\t%d\n",(*p)->pid,jiffies);
            }
        }

    /* this is the scheduler proper: */

    while (1) {
        c = -1;
        next = 0;
        i = NR_TASKS;
        p = &task[NR_TASKS];
        while (--i) {
            if (!*--p)
                continue;
            if ((*p)->state == TASK_RUNNING && (*p)->counter > c)
                c = (*p)->counter, next = i;
        }
        if (c) break;
        for(p = &LAST_TASK ; p > &FIRST_TASK ; --p)
            if (*p)
                (*p)->counter = ((*p)->counter >> 1) +
                (*p)->priority;
    }
    /*编号为next的进程 运行*/
    if(current->pid != task[next] ->pid)
    {
        /*时间片到时程序 => 就绪*/
        if(current->state == TASK_RUNNING)
            fprintk(3,"%d\tJ\t%d\n",current->pid,jiffies);
        fprintk(3,"%d\tR\t%d\n",task[next]->pid,jiffies);
    }
    switch_to(next);
}

int sys_pause(void)
{
    current->state = TASK_INTERRUPTIBLE;
    /*
	*当前进程  运行 => 可中断睡眠
	*/
    if(current->pid != 0)
        fprintk(3,"%d\tW\t%d\n",current->pid,jiffies);
    schedule();
    return 0;
}

void sleep_on(struct task_struct **p)
{
    struct task_struct *tmp;

    if (!p)
        return;
    if (current == &(init_task.task))
        panic("task[0] trying to sleep");
    tmp = *p;
    *p = current;
    current->state = TASK_UNINTERRUPTIBLE;
    /*
	*当前进程进程 => 不可中断睡眠
	*/
    fprintk(3,"%d\tW\t%d\n",current->pid,jiffies);
    schedule();
    if (tmp)
    {
        tmp->state=0;
        /*
		*原等待队列 第一个进程 => 唤醒（就绪）
		*/
        fprintk(3,"%d\tJ\t%d\n",tmp->pid,jiffies);
    }
}

void interruptible_sleep_on(struct task_struct **p)
{
    struct task_struct *tmp;

    if (!p)
        return;
    if (current == &(init_task.task))
        panic("task[0] trying to sleep");
    tmp=*p;
    *p=current;
    repeat:	current->state = TASK_INTERRUPTIBLE;
    /*
	*这一部分属于 唤醒队列中间进程，通过goto实现唤醒 队列头进程 过程中Wait
	*/
    fprintk(3,"%d\tW\t%d\n",current->pid,jiffies);
    schedule();
    if (*p && *p != current) {
        (**p).state=0;
        /*
		*当前进程进程 => 可中断睡眠 同上
		*/
        fprintk(3,"%d\tJ\t%d\n",(*p)->pid,jiffies);
        goto repeat;
    }
    *p=NULL;
    if (tmp)
    {
        tmp->state=0;
        /*
		*原等待队列 第一个进程 => 唤醒（就绪）
		*/
        fprintk(3,"%d\tJ\t%d\n",tmp->pid,jiffies);
    }
}

void wake_up(struct task_struct **p)
{
    if (p && *p) {
        (**p).state=0;
        /*
		*唤醒 最后进入等待序列的 进程
		*/
        fprintk(3,"%d\tJ\t%d\n",(*p)->pid,jiffies);
        *p=NULL;
    }
}

/*
 * OK, here are some floppy things that shouldn't be in the kernel
 * proper. They are here because the floppy needs a timer, and this
 * was the easiest way of doing it.
 */
static struct task_struct * wait_motor[4] = {NULL,NULL,NULL,NULL};
static int  mon_timer[4]={0,0,0,0};
static int moff_timer[4]={0,0,0,0};
unsigned char current_DOR = 0x0C;

int ticks_to_floppy_on(unsigned int nr)
{
    extern unsigned char selected;
    unsigned char mask = 0x10 << nr;

    if (nr>3)
        panic("floppy_on: nr>3");
    moff_timer[nr]=10000;		/* 100 s = very big :-) */
    cli();				/* use floppy_off to turn it off */
    mask |= current_DOR;
    if (!selected) {
        mask &= 0xFC;
        mask |= nr;
    }
    if (mask != current_DOR) {
        outb(mask,FD_DOR);
        if ((mask ^ current_DOR) & 0xf0)
            mon_timer[nr] = HZ/2;
        else if (mon_timer[nr] < 2)
            mon_timer[nr] = 2;
        current_DOR = mask;
    }
    sti();
    return mon_timer[nr];
}

void floppy_on(unsigned int nr)
{
    cli();
    while (ticks_to_floppy_on(nr))
        sleep_on(nr+wait_motor);
    sti();
}

void floppy_off(unsigned int nr)
{
    moff_timer[nr]=3*HZ;
}

void do_floppy_timer(void)
{
    int i;
    unsigned char mask = 0x10;

    for (i=0 ; i<4 ; i++,mask <<= 1) {
        if (!(mask & current_DOR))
            continue;
        if (mon_timer[i]) {
            if (!--mon_timer[i])
                wake_up(i+wait_motor);
        } else if (!moff_timer[i]) {
            current_DOR &= ~mask;
            outb(current_DOR,FD_DOR);
        } else
            moff_timer[i]--;
    }
}

#define TIME_REQUESTS 64

static struct timer_list {
    long jiffies;
    void (*fn)();
    struct timer_list * next;
} timer_list[TIME_REQUESTS], * next_timer = NULL;

void add_timer(long jiffies, void (*fn)(void))
{
    struct timer_list * p;

    if (!fn)
        return;
    cli();
    if (jiffies <= 0)
        (fn)();
    else {
        for (p = timer_list ; p < timer_list + TIME_REQUESTS ; p++)
            if (!p->fn)
                break;
        if (p >= timer_list + TIME_REQUESTS)
            panic("No more time requests free");
        p->fn = fn;
        p->jiffies = jiffies;
        p->next = next_timer;
        next_timer = p;
        while (p->next && p->next->jiffies < p->jiffies) {
            p->jiffies -= p->next->jiffies;
            fn = p->fn;
            p->fn = p->next->fn;
            p->next->fn = fn;
            jiffies = p->jiffies;
            p->jiffies = p->next->jiffies;
            p->next->jiffies = jiffies;
            p = p->next;
        }
    }
    sti();
}

void do_timer(long cpl)
{
    extern int beepcount;
    extern void sysbeepstop(void);

    if (beepcount)
        if (!--beepcount)
            sysbeepstop();

    if (cpl)
        current->utime++;
    else
        current->stime++;

    if (next_timer) {
        next_timer->jiffies--;
        while (next_timer && next_timer->jiffies <= 0) {
            void (*fn)(void);

            fn = next_timer->fn;
            next_timer->fn = NULL;
            next_timer = next_timer->next;
            (fn)();
        }
    }
    if (current_DOR & 0xf0)
        do_floppy_timer();
    if ((--current->counter)>0) return;
    current->counter=0;
    if (!cpl) return;
    schedule();
}

int sys_alarm(long seconds)
{
    int old = current->alarm;

    if (old)
        old = (old - jiffies) / HZ;
    current->alarm = (seconds>0)?(jiffies+HZ*seconds):0;
    return (old);
}

int sys_getpid(void)
{
    return current->pid;
}

int sys_getppid(void)
{
    return current->father;
}

int sys_getuid(void)
{
    return current->uid;
}

int sys_geteuid(void)
{
    return current->euid;
}

int sys_getgid(void)
{
    return current->gid;
}

int sys_getegid(void)
{
    return current->egid;
}

int sys_nice(long increment)
{
    if (current->priority-increment>0)
        current->priority -= increment;
    return 0;
}

void sched_init(void)
{
    int i;
    struct desc_struct * p;

    if (sizeof(struct sigaction) != 16)
        panic("Struct sigaction MUST be 16 bytes");
    set_tss_desc(gdt+FIRST_TSS_ENTRY,&(init_task.task.tss));
    set_ldt_desc(gdt+FIRST_LDT_ENTRY,&(init_task.task.ldt));
    p = gdt+2+FIRST_TSS_ENTRY;
    for(i=1;i<NR_TASKS;i++) {
        task[i] = NULL;
        p->a=p->b=0;
        p++;
        p->a=p->b=0;
        p++;
    }
    /* Clear NT, so that we won't have troubles with that later on */
    __asm__("pushfl ; andl $0xffffbfff,(%esp) ; popfl");
    ltr(0);
    lldt(0);
    outb_p(0x36,0x43);		/* binary, mode 3, LSB/MSB, ch 0 */
    outb_p(LATCH & 0xff , 0x40);	/* LSB */
    outb(LATCH >> 8 , 0x40);	/* MSB */
    set_intr_gate(0x20,&timer_interrupt);
    outb(inb_p(0x21)&~0x01,0x21);
    set_system_gate(0x80,&system_call);
}
```
sys_pause在Linux0.11中，`sys_pause()`系统调用的主要作用是让进程暂停执行，直到接收到一个信号。当进程调用`sys_pause()`系统调用时，它会将自己的状态设置为`TASK_INTERRUPTIBLE`，并且将其添加到等待信号队列中。然后，进程会进入睡眠状态，直到收到一个信号或者被其他进程显式地唤醒。<br />这个系统调用通常用于实现等待信号的操作，比如等待一个定时器信号或者等待一个IO操作完成的信号。在这种情况下，进程可以使用`sys_pause()`系统调用进入睡眠状态，而不必浪费CPU资源等待信号的到来。当信号到来时，内核会唤醒进程，并且将信号传递给进程的信号处理程序进行处理。<br />需要注意的是，在Linux 2.6以后的版本中，`sys_pause()`系统调用已经被废弃，被`sys_rt_sigsuspend()`系统调用所取代。`sys_rt_sigsuspend()`系统调用可以实现类似的等待信号的操作，并且提供更多的控制选项。<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1680156794185-dce974ae-e57c-4560-b22c-5f6bf5caee22.png#averageHue=%23fbf8f6&clientId=u11640b7c-d1e3-4&from=paste&height=364&id=u46c71fba&name=image.png&originHeight=491&originWidth=1238&originalType=binary&ratio=1.3499999046325684&rotation=0&showTitle=false&size=243762&status=done&style=none&taskId=u9adb656e-5edb-4706-9773-14fee2abbf6&title=&width=917.037101818869)

5. 修改exit.c
```c
int do_exit(long code)
{

    int i;
    free_page_tables(get_base(current->ldt[1]),get_limit(0x0f));
    free_page_tables(get_base(current->ldt[2]),get_limit(0x17));
    for (i=0 ; i<NR_TASKS ; i++)
        if (task[i] && task[i]->father == current->pid) {
            task[i]->father = 1;
            if (task[i]->state == TASK_ZOMBIE)
                /* assumption task[1] is always init */
                (void) send_sig(SIGCHLD, task[1], 1);
        }
    for (i=0 ; i<NR_OPEN ; i++)
        if (current->filp[i])
            sys_close(i);
    iput(current->pwd);
    current->pwd=NULL;
    iput(current->root);
    current->root=NULL;
    iput(current->executable);
    current->executable=NULL;
    if (current->leader && current->tty >= 0)
        tty_table[current->tty].pgrp = 0;
    if (last_task_used_math == current)
        last_task_used_math = NULL;
    if (current->leader)
        kill_session();
    current->state = TASK_ZOMBIE;
    current->exit_code = code;
    fprintk(3,"%ld\tE\t%ld\n",current->pid,jiffies);
    tell_father(current->father);
    schedule();
    return (-1);	/* just to suppress warnings */
}
```
do_exit函数与sys_waitpid函数在 Linux 0.11 中，`do_exit()` 函数负责终止一个进程。当一个进程调用 `do_exit()` 时，它会执行多个清理操作，包括释放进程持有的任何资源，如打开的文件和内存，并向父进程通知进程的退出状态。如果进程有任何子进程，则 `do_exit()` 也通过递归调用 `do_exit()` 终止它们。<br />`sys_waitpid() `函数用于等待子进程终止并检索其退出状态。当进程调用 `sys_waitpid()` 时，它会阻塞，直到其中一个子进程终止。如果子进程已经终止，`sys_waitpid() `将立即返回该子进程的退出状态。否则，它将继续阻塞，直到子进程终止。<br />除了等待特定的子进程外，`sys_waitpid() `还可以用于等待任何子进程终止，方法是通过传递` -1` 的 `pid` 参数。当一个进程有多个子进程并且想要等待第一个终止时，这很有用。
<a name="PLMGK"></a>
## 4. 生成log
先共享文件
```bash
./mount-hdc
```
移动多进程程序`process.c`到linux-0.11目录下
```bash
cp process.c hdc/usr/root
```
![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1680102556459-4dae45b1-9b54-41b1-ac91-af3f975f8622.png#averageHue=%230cb804&clientId=uc1e146a1-ff2e-4&from=paste&height=202&id=u1b11e17d&name=image.png&originHeight=182&originWidth=801&originalType=binary&ratio=1&rotation=0&showTitle=false&size=18239&status=done&style=none&taskId=u50fc4245-9bac-45f5-96f1-e1e5dd0e51c&title=&width=890.000023576949)<br />编译运行, 最后执行一个`sync`命令，确保将文件系统中的所有缓存数据写入磁盘<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1680156855136-d0cd08e2-6520-4ccf-b809-43de45b15990.png#averageHue=%23222121&clientId=u11640b7c-d1e3-4&from=paste&height=376&id=uf77324e2&name=image.png&originHeight=507&originWidth=786&originalType=binary&ratio=1.3499999046325684&rotation=0&showTitle=false&size=29997&status=done&style=none&taskId=u51aea8a4-a9b1-412e-bbf5-7de3992819e&title=&width=582.2222633518829)
sync命令sync 命令是用于将文件系统中的所有缓存数据写入磁盘的命令。在 Linux 中，当一个进程修改了一个文件时，这个修改不会立即写入磁盘，而是会先被写入内存中的缓存，以提高文件系统的性能。然而，如果系统崩溃或出现其他问题，这些修改可能会丢失。因此，为了保证数据的完整性，我们需要将缓存数据定期地写入磁盘中。<br />sync 命令会将所有的缓存数据写入磁盘中，并将所有被修改的元数据（如 i-node、目录结构等）更新到磁盘中。这样可以保证所有的修改都被写入到磁盘中，从而避免了数据的丢失。通常在关机前执行 sync 命令，以确保所有数据都已被保存到磁盘中。<br />需要注意的是，执行 sync 命令并不能保证磁盘数据的完全一致性。在磁盘数据的写入过程中，如果发生了异常情况，可能会导致数据的损坏或丢失。因此，在执行 sync 命令后，建议再执行一次磁盘检查命令（如 fsck 命令）来确保文件系统的完整性。<br />将生成的`process.log`移动到虚拟机下
```bash
./mount-hdc
cp hdc/var/process.log process.log
```
查看process.log，进程0在log关联文件描述符之前就已经在运行，因此未出现在log文件中<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1680415902178-9c4c2da7-7edb-4723-b55a-e9fe72e794e9.png#averageHue=%232e2d3c&clientId=uf67f330f-a4ae-4&from=paste&height=494&id=u30477769&name=image.png&originHeight=667&originWidth=989&originalType=binary&ratio=1.3499999046325684&rotation=0&showTitle=false&size=72543&status=done&style=none&taskId=u9090ad80-0a07-40ab-b6df-2b16198c3e3&title=&width=732.5926443447992)![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1680157216292-d2746d2e-ef7a-47b7-ae49-89ac6630d367.png#averageHue=%232e3345&clientId=u11640b7c-d1e3-4&from=paste&height=340&id=u6d455e29&name=image.png&originHeight=459&originWidth=1069&originalType=binary&ratio=1.3499999046325684&rotation=0&showTitle=false&size=121217&status=done&style=none&taskId=u8f7744b6-ff01-47a1-a81c-74e61b5412a&title=&width=791.8519077902835)
<a name="h8nod"></a>
## 5. 分析log
用指导书给的py脚本程序`stat_log.py`分析log文件，在分析之前将py脚本文件的第一行`#!/usr/bin/python`改为`#!/usr/bin/python2`（已安装python2）以适配版本，否则在python3环境下`print`函数会出错<br />为该脚本文件分配可执行权限
```bash
chmod +x stat_log.py
```
执行脚本，分析进程9、10、11、12的运行情况（多个指标：平均周转时间，平均等待时间）
```bash
./stat_log.py process.log 9 10 11 12 -g | less
```
![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1680423652089-e86380f3-f4e9-4d79-ad11-0a1ebc9798ad.png#averageHue=%23231227&clientId=uccfc5aea-4473-4&from=paste&height=474&id=ud8daee23&name=image.png&originHeight=640&originWidth=1147&originalType=binary&ratio=1.3499999046325684&rotation=0&showTitle=false&size=107108&status=done&style=none&taskId=u28cc7fdb-6a4e-4903-b874-35caa352db5&title=&width=849.6296896496307)
<a name="NJnrE"></a>
## 6. 修改时间片，重新分析log
进程的时间片是进程的`counter`值，而counter在schedule函数中根据`priority`动态设置，因此进程的时间片受`counter`和`prioriy`两个变量的影响。进程的`priority`继承自父进程，进而所有进程的`priority`都来自于进程0 。<br />linux0.11中，`priority`和`counter`在`include/linux/sched.h`中定义<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1680424066512-421f988e-49a3-4b66-a9b3-4e984c083da7.png#averageHue=%23f9f8f7&clientId=uc4ca57e0-594c-4&from=paste&height=179&id=u3cf28712&name=image.png&originHeight=242&originWidth=1399&originalType=binary&ratio=1.3499999046325684&rotation=0&showTitle=false&size=102392&status=done&style=none&taskId=udc7dd1be-caaf-44ac-8d33-1569af77da3&title=&width=1036.2963695029061)<br />我们修改这个值，然后重新执行process程序，分析log。<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1680425118028-6426a982-4e91-4b81-8fc4-7c2f2dcf7319.png#averageHue=%23320a1a&clientId=uc4ca57e0-594c-4&from=paste&height=204&id=uc99c017b&name=image.png&originHeight=334&originWidth=1215&originalType=binary&ratio=1.3499999046325684&rotation=0&showTitle=false&size=77552&status=done&style=none&taskId=u885ffd8c-f755-4bc9-8037-be7eab07b04&title=&width=742.0000610351562)<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1680425135373-cbb971da-57f6-43f9-a92b-c665b29e7410.png#averageHue=%23310a1b&clientId=uc4ca57e0-594c-4&from=paste&height=196&id=u78f7b710&name=image.png&originHeight=287&originWidth=1092&originalType=binary&ratio=1.3499999046325684&rotation=0&showTitle=false&size=66299&status=done&style=none&taskId=u61617740-70c7-46bb-b3a7-329f0fd3129&title=&width=744.888916015625)<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/29536731/1680425366848-3d2e176f-aaed-410d-a132-af6ac4df180c.png#averageHue=%23343e56&clientId=uc4ca57e0-594c-4&from=paste&height=361&id=ubd18199b&name=image.png&originHeight=487&originWidth=1101&originalType=binary&ratio=1.3499999046325684&rotation=0&showTitle=false&size=83283&status=done&style=none&taskId=u1a1720f5-a694-44f6-97d8-f4d20b23ae7&title=&width=815.5556131684772)<br />可以看到这里的时间平均周转时间变多了，有以下两种可能：

1. 当进程的执行时间很长时，增加时间片大小可能会导致进程在等待时间片结束时的等待时间变长，因为进程需要等待更长的时间才能获得 CPU
2. 当进程的数量非常多时，增加时间片大小可能会导致进程在就绪队列中等待的时间变长，因为每个进程需要等待更长的时间才能获得 CPU。

因此，时间片大小的设置需要根据具体情况进行调整，不能简单地认为增加时间片大小一定会减少平均周转时间。需要根据系统中进程的数量、执行时间等因素来选择合适的时间片大小，从而达到更好的系统性能。
