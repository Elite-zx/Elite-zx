---
title: 《数据结构与算法C++》学习历程 
date: 2022/10/25
categories:
- Data structure and Algorithm
tags: 
- Foundation
---

<meta name="referrer" content="no-referrer"/>
<a name="qIfKY"></a>

# 前言

以下记录了我2022年暑假开始学习数据结构的历程。从哈希表到图论，有着详细的思考过程。

<!--more-->

---

<a name="Aq9ue"></a>
# Chapter 1 Lists,Stacks and Queues
<a name="csZFb"></a>
### 1. 对自制vector容器添加错误检查能力
> 访问vector容器，可能会出现的错误的迭代器操作主要有两种
> 1. 错误的访存操作：迭代器未初始化，执行`*`操作
> 2. 迭代器超出容器边界：迭代器在末尾执行`++iter/iter++`操作
> 
另外，迭代器还会出现如`7`所述的失效的情况

<a name="kxJtb"></a>
#### 1.处理错误操作：在重载运算符`*`和`++`时检查current的值
```cpp
Object operator *()
{
	if (const_iterator::current == NULL)  // Check boundary
    {
        cout << "Error: iterator is NULL!" << endl;
		abort();
	}
	return *(const_iterator::current);
}

iterator& operator ++ ()
{
    if (const_iterator::current == objects[theSize-1]) // Error:Cannot access objects
	{
		cout << "Error: iterator is end!" << endl;
	    abort();
	}
	const_iterator::current++;
	return *this;
}
```
iterator类与const_iterator类作为vector模板类的嵌套类，访问外部类的私有成员`objects`与`theSize`是一件比较困难的事情 [StackOverFlow：Can inner classes access private variables?](https://stackoverflow.com/questions/486099/can-inner-classes-access-private-variables)
> 嵌套类与外部类之间没有访问特权

<a name="hHyA9"></a>
#### 2.处理失效的迭代器：给迭代器添加一个数据成员用于指向当前表，用一个函数用于判断迭代器是否指向正确的表。当发生扩容时，原有的theVector指向的空间被释放。（`theVector == NULL`感觉有点问题）
```cpp
class const_iterator
{
    ...
protected:
    Object* current;
    const vector<Object>* theVector;
    
    void assertIsValid()const
	{
		if(current == NULL || theVector == NULL)
            throw "IteratorOutOfbounds";
    }
    ...
}
```
<a name="fgUkk"></a>
### 2. 搜寻链表的注意点
在链表搜寻值为x的节点时，显然需要保存两个节点的信息：当前节点`current`和上一个节点`foreCurrent`,要注意对这两个值不同的初始化，搜寻的条件也不同。有以下两种模式：
```cpp
current = head->next
foreCurrent = head;
while (current && current->data != x)
{
    foreCurrent = current;
    current = current->next;
}
```
```cpp
Node* current = head; // Initially nullptr
Node* foreCurrent = nullptr;
while (current->next!= nullptr && current->data != x )
{
	foreCurrent = current;
	current = current->next;
}
```
注意：混淆这两种模式将出现访存错误，如以下情况
```cpp
Node* current = head->next;
Node* foreCurrent = head;
while (current->next!= nullptr && current->data != x )
{
	foreCurrent = current;
	current = current->next;
}
```
这样会出现的问题是：当链表中仅有一个头节点时，初始`current=head->next`值为`nullptr`，第3行的`current->next`将执行失败（实现iterator类后，尽可能的使用该类，该类不存在以上问题）
<a name="hF7j1"></a>
### 3.平衡符号
创建一个空栈后读取文件，当读取到开放字符`(,{,[,/*`时压入栈，当读取到封闭字符`),},],*/`时从栈顶弹出字符。
> 1. 读取到封闭字符时，栈为空，则封闭字符不匹配，报错
> 2. 弹出的字符与封闭字符不匹配，报错
> 3. 读取到文件尾后，栈不为空，则开放字符不匹配，报错

```cpp
void balSymbol()
{
	char current, prev;
	string left("{[(*");
	string right("}])");
	ifstream iFile("3_21Sample.txt");
	stack<char> check;
	if (!iFile.is_open())
		abort();
	iFile >> current;
	prev = '\0';
	while (!iFile.eof())
	{ 
		// push open symbol in stack
		if (left.find(current) != string::npos) 
		{
			if(current !='*')
				check.push(current);
			else if (current == '*' && prev == '/') // push in '/*'
			{
				check.push(prev);
			}
			// no push action for current =='*' prev !='/'
		}
		// If it is a closed symbol and stack is not empty, the corresponding symbol will pop up

		if (current == '/' && prev == '*') // special for '/','/' can be left or right
		{ // for '*/',no action for current =='/' and stack is empty (/*....),
			if(check.empty())
			{
				//last mismatch closed symbol is a speical situation, which can not belong to error:eof()
				cout << "closed symbol mismatch!" << endl;
				exit(1);
			}

			else if(check.top() == '/')
				check.pop();
		}
		else if (right.find(current) != string::npos)   // for (]}
		{
			if (check.empty()) // prevent top() error
			{
				//last mismatch closed symbol is a speical situation, which can not belong to error:eof()
				cout << "closed symbol mismatch!" << endl;
				exit(1);
			}
			else if (current == '}' && check.top() == '{')
				check.pop();
			else if (current == ']' && check.top() == '[')
				check.pop();
			else if (current == ')' && check.top() == '(')
				check.pop();
			else
				break; // error: top stack symbol mismatch → eof() is false
		}
		prev = current;
		iFile >> current; // read next character in buffer
	}
	// judge
	if (!iFile.eof() )
		cout << "closed symbol mismatch!" << endl;
	else if (!check.empty())
		cout << "open symbol mismatch!" << endl;
	else
		cout << "Successful!" << endl;
}
```
<a name="JdH6s"></a>
### 4. 中缀表达式转后缀表达式
1.为什么在向栈中压入运算符时，要先弹出优先级更高的运算符
> 运算符的出栈顺序代表了运算符的执行顺序。显然的，优先级更高的运算符最先打印并出栈，即在后缀表达式中代表最早参与运算

2.为什么直到碰到右括号`)`之前，不弹出左括号`(`，遇到右括号`)`后,弹出栈元素直到遇到`(`
> 该操作的意思是弹出括号内的所有运算符，显然的，括号内的各运算符优先级高于括号外的运算符

```cpp
void infixToPostFix()
{
	ifstream iFile("3_23Sample.txt");
	if (!iFile.is_open())
		abort();
	string operators = "()+-/*";
	stack<char>keepOptors;
	char current;
	iFile >> current;
	while (!iFile.eof())
	{
		if (operators.find(current) != string::npos)
		{
			if (keepOptors.empty()) // initial
				keepOptors.push(current);
			else if (current == '+')
			{
				while (operators.find(keepOptors.top(), 2)!= string::npos) //top item is +, -,* or /
				{
					cout << keepOptors.top()<<' ';
					keepOptors.pop();
					if (keepOptors.empty())
						break;
				}
				keepOptors.push(current);
			}
			else if(current =='-')
			{
				while (operators.find(keepOptors.top(), 3)) //top item is -,* or /
				{
					cout << keepOptors.top()<<' ';
					keepOptors.pop();
					if (keepOptors.empty())
						break;
				}
				keepOptors.push(current);
			}
			else if (current == '*' || current == '(')
				keepOptors.push(current);
			else if (current == ')')
			{
				while (keepOptors.top() != '(')
				{
					cout << keepOptors.top()<<' ';
					keepOptors.pop();
				}
				keepOptors.pop(); // pop up '('
			}
		}
		else
			cout << current << ' ';
		iFile >> current;
	}
	while (!keepOptors.empty())
	{
		cout << keepOptors.top() << ' ';
		keepOptors.pop();
	}
}
```
<a name="Kvu8h"></a>
### 5. 后缀表达式转中缀表达式
想法与计算后缀表达式差不多，注意两个地方
> 1.优先参与运算的运算符的运算结果是下一个运算符的操作数，想想怎么把表达式连接成一个整体
> 2.为每个计算式加上括号，确保在最终的中缀表达式中能清晰的表达计算顺序，如 8*5+3 与 (8*(5+3))

```cpp
void postfixToInfix()
{
	stack<string> expr;
	ifstream iFile("3_22Sample.txt");
	if (!iFile.is_open())
		abort();
	string first, second;
	char current;
	iFile >> current;
	while (!iFile.eof())
	{
		if (48 <= current && current <= 57)
			expr.push(string(1,current));
		else
		{
			first = expr.top();
			expr.pop();
			second = expr.top();
			expr.pop();
			if (current == '*')
				expr.push('('+first + '*'+second+')');
			else if (current == '/')
				expr.push('('+first +'/'+ second + ')');
			else if (current == '+')
				expr.push('(' + first + '+' + second + ')');
			else
				expr.push('(' + first + '-' + second + ')');
		}
		iFile >> current;
	}
	cout << expr.top() << endl;
}
```
<a name="OSFAk"></a>
### 6. 逆向打印链表的两个方法
<a name="UuJnf"></a>
#### 1.链表反转
改变单向链表的结构，反转其方向。需要用到三个结点的信息`prev、current、next`
```cpp
void Reverse_List()  // O(1)
	{
		Node* prev, *current, *cNext;
		prev = nullptr;
		current = head->next;
		cNext = current->next;

		while (cNext != nullptr)
		{
			current->next = prev; // reverse direction
			prev = current;
			current = cNext;
			cNext = current->next; 
		}
		current->next = prev;
		head->next = current; // head to tail

		while (current != nullptr)
		{
			cout << current->value << ' ';
			current = current->next;
		}
		cout << endl;
	}
```
> 注意同时声明多个指针时，不能写成`Node* prev, current, cNext`，这种声明下`current、cNext`是int型，只有一个`prev`是指针类型。应改为`Node* prev, *current, *cNext;`

<a name="aAKjU"></a>
#### 2.利用栈
逆向打印可以利用栈先进后出的性质实现
```cpp
void Reverse_Print_With_Stack() //  O(N)
{
    stack<T> storage;
    Node* p = head->next;
    while (p != nullptr)
    {
        storage.push(p->value);
        p = p->next;
    }
    while (!storage.empty())
    {
        cout << storage.top() << ' ';
        storage.pop();
    }
    cout << endl;
	}
```
<a name="QwIKh"></a>
### 7. 环形缓冲区的满vs空问题
用**数组**实现队列通常有两种方式

1. head 指向队列头，即第一个元素，tail 指向新元素即将插入的位置，即最后一个元素的下一个位置，enque后tail+1 (初始状态：head = tail = 0)   
2. head 指向队列头，tail指向最后一个元素，enque前tail+1 （初始状态：front = 0 , tail = -1）

两种情况下，均要保持队列最后一个元素不能使用，(n-1) 长度队列可以用长度为 n 的数组创建

1. <br />

empty：`head = tail  `<br />full：`head = (tail+1) % maxSize`  <br />如果完全填充数组，那么会导致full和empty情况下，均满足`head = tail `

2. <br />

empty : `head = (tail+1) % maxSize`  <br />full：`head = (tail+2) % maxSize` ？<br />如果完全填充数组，那么会导致full和empty情况下,均满足`head = (tail+1) % maxSize`![image.png](https://cdn.nlark.com/yuque/0/2022/png/29536731/1660033289402-7374663e-99df-4e23-8d39-2bcb71e5622a.png)
<a name="mDKbV"></a>
### 8. 判断链表是否有环的两个方法
> 1. 用`hashset`存储遍历过的节点，用新节点对比，有重复则存在环
> 2. 双指针遍历，速度不同，相遇则存在环

```cpp
template<typename T>
class Solution
{
public:
	void detectloop(Node<T>* head)
	{
		Node<T>* first, * second;
		first = second = head;
		/*A walks faster than B, so only A is judged.
		If A is the last node, you need to judge A->next*/
		while (first != nullptr && first->next != nullptr)
		{
			first = first->next->next; // two step
			second = second->next; // one step
			if (first == second)
			{
				cout << "exist loop" << endl;
				return;
			}
		}
		cout << "no loop" << endl;
		return;
	}
};
```
> 涉及的算法：[Floyd's Cycle Finding Algorithm](https://www.geeksforgeeks.org/floyds-cycle-finding-algorithm/)

[知乎：如何判断链表有环](https://zhuanlan.zhihu.com/p/31401474)<br />[LeetCode：Linked List Cycle](https://leetcode.com/problems/linked-list-cycle/discuss/1829489/C%2B%2B-oror-Easy-To-Understand-oror-2-Pointer-oror-Fast-and-Slow)
<a name="qdbBD"></a>
## other questions：

1. **stackoverflow示例中总是出现的foo ，bar 是什么意思**

foo：File or Object，文件或对象。它用于代替对象变量或文件名，用于代码演示<br />bar：与foo的作用一样，表示变量或文件，用于代码演示2.VS2019调出监视窗口的办法

2. **vs2019中调式调出监视窗口**

设置断点，运行程序<br />![屏幕截图 2022-07-20 175431.png](https://cdn.nlark.com/yuque/0/2022/png/29536731/1658310883417-a80aaf32-ea48-40bb-b554-2c6d8960689b.png)

3. **git上传项目到github**

[知乎：github基础教学](https://zhuanlan.zhihu.com/p/369486197)
<a name="IthCG"></a>
## remaining problem

1. **在vector中实现erase(iterator pos)**

涉及萃取

2. **实现能够指定容器的stack类**
3. **STL stack: emplace() vs push()**

涉及右值引用，移动构造(?)

4. **判断链表是否有环，为什么不直接判断最后一个节点指向是否为nullptr**

我认为可能的原因：当最后一个节点指向本身时，其next也不为nullptr，而此时单链表中不存在环，所以该方法不适用。

---

<a name="oX3jS"></a>
# Chapter 2 Trees
<a name="JBUuP"></a>
## record:
<a name="oEiO6"></a>
### 1. 二叉查找树类中为什么要额外添加功能与公有函数相同，但参数不同的同名私有函数
在类外调用公有函数，而公有函数内部需要递归处理左右子树，需要传入新的根节点，所以需要有额外的能传入根节点参数的函数，因为这类函数只被公有函数所使用，所以设置为私有（辅助函数）<br />[stackoverflow：When/why to make function private in class?](https://stackoverflow.com/questions/4505938/when-why-to-make-function-private-in-class)
<a name="DpaEu"></a>
### 2.搜索二叉树的insert成员函数结点指针t必须引用传递的原因
如果采用值传递，那么函数insert中的指针将是实参的副本，在函数insert中修改该副本，不能达到修改结点p的成员变量left or right的目的, remove函数同理<br />![](https://cdn.nlark.com/yuque/0/2022/jpeg/29536731/1661568230165-1e7336ea-23dc-443d-afa4-e35e7a5a4058.jpeg)
<a name="WEgNR"></a>
### 3. 平衡二叉树

对BST的find操作，其运行时间为$O(d)$,$d$为结点的深度。给定一系列值，不同的插入序列对应不同的树结构，有着不同的平均结点深度，进而有不同的查找效率。<br />![image.png](https://cdn.nlark.com/yuque/0/2022/png/29536731/1661156478689-efe3aeff-b060-4bc9-80ee-099b96f5aa02.png)<br />创建高度为h的AVL树所需的最少结点数为斐波那契数列第h+2项的值减1（高度和项数均从0计数）
<a name="FZLgt"></a>
## remaining problem
<a name="Le4pv"></a>
### 1. 给定一系列值，确定构造BST的方法个数
[stackoverflow：How many ways can you insert a series of values into a BST to form a specific tree?](https://stackoverflow.com/questions/17119116/how-many-ways-can-you-insert-a-series-of-values-into-a-bst-to-form-a-specific-tr)

---

<a name="Cieup"></a>
# Chapter 3 Hashing
<a name="RQFF9"></a>
## 1. 为什么哈希表只能惰性删除(lazy deletion)
答：在插入其它元素A时，A可能与待删除元素B发生过冲突(collision),即可能有`myhash(A) == myhash(B)`,也可能是A在向前探测的过程中与B发生过冲突。 如果删除元素B，那么在寻找A就会失败，因为此时B所在的位置是EMPTY，那么findPos(A)在B的位置上会返回currentPos,查找结束，但currentPos是EMPTY而不是A所在的值。
<a name="mwjke"></a>
## 2. 为什么要有哈希表？是怎么达到高效性的？
为了在**常数时间**内高效实现对数据的插入，删除，查找操作。 通过**哈希函数**（通常是 `hash(x) % tableSize`,`hash(x)`的作用是将x转化为数字，由key类提供，如果x本身就是数字，那么hash(x) = x），让待插入数据**直接定位**到哈希表中的一个位置（哈希表是什么？ 一个固定大小的存储项的数组， 哈希 = 散列）<br />![](https://cdn.nlark.com/yuque/0/2022/jpeg/29536731/1664794253808-1aee7326-a1c4-44c2-986e-5ca40efa4d87.jpeg)
<a name="Hcjq3"></a>
## 3. 冲突(collision)是什么？怎么解决冲突的？
不同的数据可能会被哈希函数映射到相同的位置，而一个位置只能属于一个数据，因此产生了冲突。为解决冲突，很简单是想法就是：**既然原本属于它的位置被占用了，那就将数据移到可以存放的空位置**<br />如何找到这个空位置呢？有两种方法

1. **分离链接法（separate chaining）:**

既然冲突是因为一个位置只能存放一个数据，那么引入链表以实现一个位置能够存放多个数据，冲突便解决了。哈希表中的一个位置对应一条链表，显然的，在某个位置发生的冲突越多，那么这条链表就越长。无论是执行查找还是删除操作，都要先找到链表（由哈希函数得到），再在链表里面找到数据。

2. **开放定址法（open addressing）：**

往前探测（probe），形式化为公式就是`hashi(x) = (hash(x) + f(i))`,**i表示向前探测的次数**，f(i)称为冲突解决策略（collision resolution strategy）,显然`f(0)=0`。根据f(i)形式的不同，分为线性(Linear)探测:`f(i)=i`、平方(quadratic)探测:`f(i) = i2`、双(double)散列:`f(i) = i*hash2(x)`<br />**线性探测会引起一次聚集（**primary cluster**），平方探测会引起二次聚集（**Secondary Clustering**），**关于这一点：[stackoverflow：What is primary and secondary clustering in hash?](https://stackoverflow.com/questions/27742285/what-is-primary-and-secondary-clustering-in-hash) 说的很清楚<br />为什么一次聚集对性能的影响会比二次聚集更大呢？首先要知道，聚集之所以会影响性能，是因为聚集导致hashPos之后的位置大部分被占用，进而导致探测次数增加。一次聚集是无间隔的聚集，那么只要在这堆聚集的项中发生了冲突，就基本上要一步一步的探测完所有聚集项才能找到空位置。而二次聚集是有间隔的，一次两步的探测会减少探测的发生。这个具体的描述比较困难，但是很好想。<br />双散列，消除了聚集问题，它应用了另一个哈希函数`hash2(x)`（**哈希结果不能为0，则f(i)将失去意义**），使得探测更趋于随机化，而不是集中在哈希位置附近。<br />注意点：

-  哈希表的**大小(tableSize)为素数(Prime)**能更好的减少冲突的发生 
- **tableSize为素数且λ<0.5**（有一半以上空项）时平方探测能保证插入成功。否则甚至不如线性探测，因为插入可能会失败（书上有证明）
- 当计算哈希值代价较高时，性能角度上，双散列较之平方探测不是一个更好的选择

**两个方法的对比：** 前者不如后者，因为分离链表法会因为插入而分配新内存，这将降低执行效率；其次，分离链表法等于是哈希表与链表的结合，等于要求实现了另一种数据结构(而不是哈希表)，提高了程序的复杂性
```cpp
int findPos(const hashedObj& x) const
	{
		int currentPos = myhash(x);
		int offset = 1;

		while (array[currentPos].info != Empty && array[currentPos].element != x)
		{
			currentPos += offset;
			offset = pow(offset,2);
			if (currentPos >= array.size())
				currentPos -= array.size();
		}
		return currentPos;
	}
```
<a name="vpuOb"></a>
## 4. 为什么要再散列(rehashing)？再散列要怎么做？
当哈希表过于满(too full，λ too big)，查找操作将会变得非常缓慢（如之前所说，探测次数会非常多），进而影响插入和删除操作。解决这个困境的办法就是扩大哈希表以降低λ。<br />做法是：创建一个表长为大于2倍当前长度的第一个素数的新表（如当前长度是7，扩大后为17），相应的也产生了新的哈希函数，接着把原表中的所有数据通过新的哈希函数映射到新表中。<br />怎么界定哈希表是否需要再散列，一个好的方法是：当λ到达某个界定值时

---

<a name="OulqF"></a>
# Chapter 4 Heap
<a name="KirP0"></a>
## 1. 为什么要有二叉堆(Binary Heap)? 是怎么达到高效的？
为了实现**优先级队列(priority queue)**，即根据不同对象间的优先级排列而形成的队列，如操作系统中进程的优先级队列。相比于用队列(Queue)实现的根据对象到来的时间属性而确定优先级队列(即First Come First Served), 我们希望有一种数据结构，它有着更加灵活的优先级批判标准，而不是只看任务的到达时间。不仅如此，为了高效性，我们希望这个数据结构能够快速的找出队列中优先级最大的那一个。<br />由此我们引出二叉堆，二叉堆是一个**底层为数组的完全二叉树(complete binary tree)，**有结构性质和堆序性质<br />![image.png](https://cdn.nlark.com/yuque/0/2022/png/29536731/1665135196819-0f05c687-059e-4b79-9c73-9c31e16de204.png)
```cpp
void insert(const Comparable& x)
	{
		if (heapSize == array.size() - 1)
			array.resize(array.size() * 2);

		int hole = ++heapSize;
		Comparable copy = x;
		array[0] = std::move(copy);
		for (; x < array[hole / 2]; hole /= 2)  // percolate up
		{
			array[hole] = std::move(array[hole / 2);
		}
		array[hole] = std::move(array[0]);
	} 

void deleteMin()
	{
		hole = 1;
		Comparable x = std::move(array[heapSize--]);
		for (; hole <= heapSize; hole*=2) // percolate down
		{
			child = 2 * hole;
			if (child != heapSize && array[child] < array[child + 1])
				++child;
			if (x > array[child])
				array[hole] = std::move(array[child]);
			else
				break;
		}
		array[hole] = std::move(x);
	}

void heapify()
	{
		for (int i = heapSize / 2; i > 0; --i)
			percolateDown(i);
	}
```

---

<a name="eHZpk"></a>
# Chapter 5 Sorting
<a name="SWGCy"></a>
## Insertion_Sort
<a name="Hw7N9"></a>
### 1. 怎么插入的？为什么结果能有序？
对序列(Comparable)，假定第一个数据(array[0])是有序的，把从第二项到末尾的数据逐个插入到开头的有序序列中。<br />怎么插入的？将待插入项`tmp`与有序序列中的项逐个比较，遇到`array[i]>tmp`(升序序列)，则将有序序列中的元素右移，为`tmp`提供插入位，接着插入`tmp`。等价于将位置为p的项放入前p+1项(从0开始索引)的正确位置(从小到大)。如果数组本身就比较有序，那么可以省去不少插入操作<br />为什么能有序？ straightforward，我觉得有些许减治法的感觉，先解决小问题，逐步解决大问题。
```cpp
template<typename Comparable>
void insertionSort(std::vector<Comparable>& array)
{
	int N = array.size();
	for (int p = 1; p < N; ++p)
	{
		Comparable tmp = std::move(array[p]);
		int j = p - 1;
		for (; j >= 0 && tmp < array[j]; --j)
		{
			array[j + 1] = std::move(array[j]); // j move right, p move left
		}
		array[j + 1] = std::move(tmp);
	}
};
```
<a name="AXqXN"></a>
## Shell_Sort
<a name="NvzxL"></a>
### 1. 为什么说希尔排序涉及了插入排序？
因为希尔排序先将序列分组，然后在组内进行插入排序
<a name="rqY4s"></a>
### 2. 希尔排序是如何分组的？
使用一组增量h1，h2，h3， . . . , ht(就是代表了不同的跨度，h1 =1)。第一阶段，对任意位置i，把array[i]，array[i+ht]，array[i+2ht]...分为一组执行插入排序；第二阶段，对任意位置i，把array[i]，array[i+ht-1]，array[i+2ht-1]...分为一组执行插入排序。显然的，在最后阶段，使用增量h1=1时就是对整个序列执行插入排序。<br />选择合适的增量能使插入排序的时间复杂度低于插入排序，如 Hibbard增量： 1, 3, 7, . . . , 2k − 1。<br />**执行一个增量为h****k****的排序(hk-Sort)，等价于对h****k****个子数组(subarray)执行插入排序(见下图)**。<br />![](https://cdn.nlark.com/yuque/0/2022/jpeg/29536731/1665481444552-78d1a034-c95c-462b-b080-475d22f10d1c.jpeg)
<a name="yUWsx"></a>
### 3. 希尔排序是如何改进插入排序的? 执行名副其实的插入排序前(h1)，分组的作用是什么？
分组的作用是对数组执行[预排序](https://zhuanlan.zhihu.com/p/87781731)，即在执行真正的插入排序前先使数组比较有序，以减少执行插入操作的次数。显然插入排序在1.元素个数少 2. 数组比较有序 的情况下执行效率高。分组营造了前一个条件以高效排序子数组，并为逐步减少分组的增量(跨度)以排序数组中的更多元素提供了第二个条件。所以显然的，希尔排序优于插入排序。
```cpp
template<typename Comparable>
void shell_Sort(std::vector<Comparable> array)
{
	int N = array.size();
	for (int gap = N/2; gap > 0; gap /= 2)
	{ 
		// insertion Sort
		for (int p = gap; p < N; ++p)   // point: ++p here
		{
			int j = p - gap;
			Comparable tmp = std::move(array[p]);
			for (; j >= 0 &&  array[j] > tmp; j-=gap)
				array[j + gap] = std::move(array[j]);
			array[j + gap] = std::move(tmp);
		}
	}
};
```
<a name="ZZpJ6"></a>
## Heap_Sort
<a name="mMQHg"></a>
### 1. 如何利用堆实现排序
要利用堆(heap)将一个乱序的数组变成有序的数组，显然的，要首先构造一个堆(build heap)，即利用heapify的方法将N个元素组成堆的结构(本质还是数组)；接着，对这个堆执行N-1次`deleteMax`(或`deleteMin`)操作，在每次执行删除操作时，将删除的元素填入刚刚空出来的最后一个元素的位置上；最后能得到一个递增序列(最大堆)或递减序列(最小堆)。<br />关键是要认识到，在本质上，对堆执行deleteMax操作，是将堆的最后一个元素(`array[HeapSize]`)填在根(`array[0]`)的位置(覆盖原有的根值),接着把这个结点通过下滤(percolate down)放在合适位置。较之堆删除，堆排序只改变了一个操作，那就是把这个覆盖的过程，变成一个交换(swap)的过程。

![image.png](https://cdn.nlark.com/yuque/0/2022/png/29536731/1665664167534-eee32f0c-0cba-487b-a1aa-b684f3f02866.png)
```cpp
template<typename Comparable>
void heapSort(vector<Comparable> & objects)
{
	// bulid heap
	for (int j = objects.size()/2-1; j >= 0; --j)
		percDown(objects, j, objects.size());
	//make a decreasing array
	for (int i = objects.size()-1; i>0; --i)
	{
		swap(objects[0], objects[i]);
		percDown(objects, 0, i);
	}
}

inline int  leftChild(int i)
{
	return 2 * i + 1;
}

template<typename Comparable>
void percDown(vector<Comparable> &objects , int i, int n)
{
	Comparable tmp = move(objects[i]);
	int child;// left child 
	for(;leftChild(i) < n; i = child)
	{
		child = leftChild(i);
		if (child != n-1 && objects[child] < objects[child + 1])
			++child;
		if (tmp < objects[child])
			objects[i] = move(objects[child]);
		else
			break;
	}
	objects[i] = move(tmp);
}
```
<a name="pNLGn"></a>
## Merge_Sort
<a name="cBdMT"></a>
### 1. 归并排序是如何排序的，为什么说体现了分而治之( divide-and-conquer)的思想？
归并排序，最重要的基本操作就是**将两个已排序的数组整合为一个**，也就是Merge(合并)操作。要获取两个已排序的数组，首先将待排序的数组一分为二，然后对这两个子数组递归的调用归并排序（递归返回条件：子数组只剩一个元素` left >= right`)。 <br />归并排序本质上是对**逐步完成对子数组的排序进而完成大数组的排序**。<br />**divide：将数组一分为二    conquer：Merge**
```cpp
template<typename Comparable>
void mergeSort(vector<Comparable>& objects, vector<Comparable>& tmpA, int left, int right)
{
	if (left >= right) // recursive call's end condition : only one element 
		return;  
	int center = (left + right) / 2;
	mergeSort(objects, tmpA, left, center); // merge first half 
	mergeSort(objects, tmpA, center + 1, right);  // merge second half
	merge(objects, tmpA, left, center + 1, right); // patch
}

template<typename Comparable>
void mergeSort(vector<Comparable>& objects)  // driver
{
	vector<Comparable> tmpA(objects.size());
	mergeSort(objects, tmpA, 0, objects.size() - 1);
}

template<typename Comparable> // merge two sorted array into one
void merge(vector<Comparable>& objects, vector<Comparable>& tmpA, int leftBegin, int rightBegin, int rightEnd)
{
	int leftEnd = rightBegin - 1;
	int tmpAIndex = leftBegin;
	int N = rightEnd - leftBegin + 1;

	while (leftBegin <= leftEnd && rightBegin <= rightEnd) // comparison between two halves
	{
		if (objects[leftBegin] <= objects[rightBegin])
			tmpA[tmpAIndex++] = move(objects[leftBegin++]);
		else
			tmpA[tmpAIndex++] = move(objects[rightBegin++]);
	}

	while (leftBegin <= leftEnd) // copy the remainder
	{
		tmpA[tmpAIndex++] = move(objects[leftBegin++]);
	}

	while (rightBegin <= rightEnd)
	{
		tmpA[tmpAIndex++] = move(objects[rightBegin++]);
	}

	// how to write back to objects
	for (int i = 0; i < N; ++i,--rightEnd )
	{
		objects[rightEnd] = move(tmpA[rightEnd]);
	}

}
```
![](https://cdn.nlark.com/yuque/0/2023/jpeg/29536731/1672988373854-be3e4874-5705-410b-8800-ad92faa15a40.jpeg)
<a name="dIPOD"></a>
## Quick_Sort 
<a name="SkElc"></a>
### 1. 快速排序是如何排序的
与归并排序类似，快速排序也有分割数组的操作，但不同于归并排序一分为二的做法**，快速排序会先在数组中选取一个枢纽元(pivot)，然后把剩下的元素根据大于/小于pivot分为两组(group)，**产生两个子数组，放在pivot前后，接着递归的对子数组调用快速排序。
<a name="Tfhnl"></a>
### 2. 为什么选择三数中值(Median-of-Three )作为pivot的效率最高
这里的三数中值，指的是数组最左边`array[0]`，最右边`array[size-1]`，和中间`array[(left+right)/2]`这三个值中大小排中间的那个。<br />**选取pivot的原则是取尽可能靠近数组的中值(第 ⌈N/2⌉大的值)，这样做的目的是让分组(partition)后产生了两个子数组如归并排序般尽可能均匀，进而减少递归的层次。**不随机选取三个数取中值的原因在于random函数的代价较高，会影响性能(不随机去一个pivot的原因也是如此)。直接选取第一个元素作为pivot是一个欠妥的做法，这样会导致算法在数组有预排序的情况下做无用功。<br />**为什么将三者的最小值放在**`**array[left]**`**？** 因为最小值必然小于pivot，避免了一次多余的交换，同时这个left还能作为partition过程中`j`的哨兵(sentinel)，避免j越界。<br />**为什么将三者的最大值放在**`**array[right]**`**？**同理，避免了交换，但此处没有起到做哨兵的作用，因为我们会在选取pivot时就将pivot放在`array[right-1]`的位置,而i与j遇到equal to pivot的值都会停止，所以pivot也作为了`i`的哨兵。
<a name="XXNbN"></a>
### 3. 如何分组？
我们的目标是把小于pivot的值放在数组左边，大于pivot的值放在数组右边。**采取的策略时**`**i**`**从数组左边开始遍历，遇到大于pivot的值就停止(该值不属于左边)；**`**j**`**从数组右边开始遍历，遇到小于pivot的值就停止。接着交换**`**i**`**和**`**j**`**所在位置的元素。当i和j交叉时，把**`**pivot**`**与**`**i**`**所在位置的值交换**(为什么是`i`而不是`j`？因为pivot预先被放在数组右边right-1的位置，如果被放在右边那pivot就是和`j`交换位置)<br />**如何处理等于pivot的元素？**先说结论，`**i**`**和**`**j**`**遇到这样的元素都要停下**。<br />接着在极端情况(所有元素都一样)情况下讨论其它做法的低效性<br />**为什么不一个停下而另一个继续前进？**如果`i`停下而`j`不停下，则`i``j`交叉的位置会偏向左侧，而pivot要与i最后在的位置交换值，这样显然会导致子数组的大小不平衡。<br />**为什么不两个都不停下？**首先`i`，`j`显然可能会出界，即使存在`i``j`出界的代码，这样做会导致i最后所处的位置在靠近最右边的位置(取决于具体实现)，而pivot要与`i`交换位置，进而导致产生的子数组很不平衡，降低了算法效率
<a name="mt8ir"></a>
### 4. 递归结束条件是什么？什么是cutoff？为什么要结合插入排序？
快速排序或许应该像归并排序那样，当子数组仅剩一个元素时递归返回。但是实际上并不这样设置递归返回条件，因为存在这样一个事实：**当数组元素个数很少(5~20)时，快速排序的效率还不如插入排序。因此在partition之后如果子数组的大小小于某一界限(cutoff)，就停止递归调用，转而对子数组调用插入排序,进而提升算法的整体效率**<br />这里提到了[快速排序与归并排序的区别](https://stackoverflow.com/questions/70402/why-is-quicksort-better-than-mergesort)，还有的区别点是快速排序不占用额外的内存，快速排序使用的是[尾递归](https://stackoverflow.com/questions/33923/what-is-tail-recursion)等
```cpp
template<typename Comparable>
const Comparable Median(vector<Comparable> & array,int left,int right)
{
	int center = (left + right) / 2;
	if (array[left] > array[right])
		swap(array[left], array[right]);
	if (array[center] > array[right])
		swap(array[center], array[right]); // keep left is min among three values
	if (array[left] > array[center])
		swap(array[left], array[center]); // keep right is max among three values
	swap(array[center], array[right - 1]); // put pivot into position right-1 
	return array[right - 1];
}

template<typename Comparable>
void quickSort(vector<Comparable>& array, int left, int right)
{
	int range = right - left + 1;
	if (range > 10) // cutoff = 10
	{
		Comparable pivot = Median(array, left, right);
		// partition
		int i = left; int j = right - 1;
		while (i < j)
		{
			while (array[++i] < pivot); // increase before check , details see stackoverflow 
			while (array[--j] > pivot);
			swap(array[i], array[j]);
		}
		swap(array[i], array[right - 1]);
		// recursion
		quickSort(array, left, i - 1);
		quickSort(array, i + 1, right);
	}

	else
		insertionSort(array, left, right);
};

//Driver
template<typename Comparable>
void quickSort(vector<Comparable>& array)
{
	quickSort(array, 0, array.size() - 1);
}
```
<a name="wPOyJ"></a>
# Chapter 6 Disjoint Sets
<a name="AHMCd"></a>
## 1. 什么是不相交集？什么是union/find操作？
对于一个集合S，由一个关系R可将S划分为多个[等价类](https://www.zhihu.com/question/276100093/answer/388155191)(equivalence class)，在一个等价类中的所有元素之间均存在关系R(即任意a，b ∈ S, a~b)。显然的，要判断任意给定的S中的元素a，b是否有关系，只需判断a,b是否属于同一个等价类，这也说明了**等价类概念的提出是为了给出一个快速判断a,b是否存在关系的方法(我的理解)**。显然的，等价类是S的一个子集(set)，一个元素也只属于一个等价类，**不同的等价类们就是本章要讨论的不相交集(disjoint sets）**<br />什么是union/find操作？先查找元素a和b所在的等价类(find操作)，然后判断是不是同一个等价类(find(a) == find(b) ？ ),that is，**判断a,b是否有关系。如果没有，就将a,b联系起来，也就是变得有关系**，即将a,b的等价类合并为一个新的等价类(注意关系的传递性(Transitive)，a,b如果有关系，那么两者原来所在集合的所有元素间也存在了关系)，合并的过程就是union操作。如果本身就有关系，就不用操作了。
<a name="x95GB"></a>
## 2. 如何表示不相交集？
初始状态，对于N个元素的集合S，假设N个元素间均不存在关系，因此有N个不相交集(每个集合仅有一个元素)。因为不存在comparison操作，所以我们并不在意元素的值是多少，因此我们**把N个元素以0~N-1编号**。<br />我们**用树来表示一个集合，并把树的根作为集合的名字**(某个元素编号)。初始状态时，每个集合名统一表示为-1。<br />**树形态的不相交集不具备完全二叉树(堆)那样的规整性，为什么可以用数组来实现？**因为对于每个元素我们只关心它所在的集合是哪个，即它所在的树的根是哪个，因此**对于每个元素，我们仅需知道它所在的树的根值**即可。不仅如此，数组的从0开始下标也与我们的编号符合，因此可以**用大小为N的数组存储0~N-1个元素的父节点（即对第i个数组项，array[i]存储了编号i的父结点），提供了一个由任意结点开始向上遍历即可获取根结点（that is ，任意结点所在集合名）的途径。**
<a name="XuWqo"></a>
## 3. Union/find 如何执行 ？ 
find操作要找到元素A所在树的根，即对A结点沿根节点方向向上遍历，直到数组值为 -1(`sets[i] < 0`)，说明此数组编号为根节点(`return x`)。这其实就是一个不断获取父节点的过程，可使用递归。
```cpp
int find(int x) const  
	{
		if (sets[x] < 0)
			return x;
		else
			return find(sets[x]); // recursive
	}

```
Union操作**要合并两个集合，只需要将一个集合的根结点，链接到另一个集合的根节点上**，因为在我们的方法中，根节点才是集合的唯一标识。具体来说，假设root1(同样的，是一个编号)是某个集合的根结点(即，集合名)，root2是另一个集合的根节点，执行Union，就是执行array[root1] = root2 (执行前：array[root1] == array[root2] == -1 ; 执行后：array[root1] == root2 , array[root2] == -1)<br />如果实参不是根，而是元素编号，则需额外执行两次find
```cpp
void unions(int root1, int root2)
	{
		sets[root2] = root1;
	}
```
显然的，因为数组是一个支持随机存取的数据结构，则获取set[x]的值是常数时间(that is O(1) )，find操作真正耗时的是向上探索的过程，也就是说**影响find操作的主要是结点所在的深度**。
<a name="xnSpG"></a>
## 4. 如何改进Union
上述合并是有问题的，把两颗相同高度的树合并，或通过把一颗高树(larger height)根节点链接到一颗矮树的根节点以实现两颗不同高度树的合并，均**会使新树的高度比原来最大的那颗还要多一，即增加了各结点的深度，这样会极大影响find的效率(根节点最大高度为N-1)**。因此我们需要改进合并的方法。<br />很自然的想法就是**把矮树的根节点链接到高树的根节点**(注意本章所用的树不是二叉树，而是一颗多路树)，这样新树的高度还会保持与原来高树的一致；如果两棵树高度相同，那么谁链接到谁都可以，结果都会使新树高度增1(所以根节点最大高度为log2N)<br />如何确定高树和矮树？显然的，**我们需要跟踪每棵树的高度，可以用现有的数组存储，原先根节点的数组值为-1，现在将其改写为其所代表集合的高度的负数**(为什么是负数？或许是为了方便find函数的判断语句更好编写:`if (sets[x] < 0 return x;`注意之前提到设置各集合初始值为-1，也与这里符合)<br />也可以根据数的大小(size)决定谁链接到谁，但显然由高度做决定更好
```cpp
void unionSets(int root1, int root2)
	{
		if (sets[root2] < sets[root1]) // set[root] keep track of height(negative)
			sets[root1] = root2; // root2 is deeper
		else
		{
			if (sets[root2] == sets[root1])
				--sets[root1];
			sets[root2] = root1;
		}
	}
```
<a name="unJoe"></a>
## 5. 如何改进find
在寻找编号为x的元素的根的过程中，我们使用**路径压缩(Path Compression)**的方法(自调整)，即**把从x到root之间所有结点的父节点均改为根节点。**<br />![image.png](https://cdn.nlark.com/yuque/0/2022/png/29536731/1666421236514-c4f89687-71a5-42a4-b5fe-19f8f379487a.png)<br />具体做法是**递归的将根节点的编号赋值给路径上的结点**
```cpp
	int find(int x) 
	{
		if (sets[x] < 0)
			return x;
		else
			return sets[x] = find(sets[x]);
	}
```
<a name="fO0SW"></a>
# Chapter 7 Graph Algorithms
<a name="TOgKc"></a>
## [Graph implement](https://stackoverflow.com/questions/5493474/graph-implementation-c)
![](https://cdn.nlark.com/yuque/0/2022/jpeg/29536731/1666956918039-3ebc54cf-6c4e-4feb-8f90-6473899dc634.jpeg)
```cpp
#pragma once
#include<vector>
#include<map>
using namespace std;

struct vertex
{
	typedef pair<int, vertex* > ve;
	int name; 
	int seq;// serial number
	int ind; // indegree
    int addition // additional Message 
	vector<ve> adj; // adjacent list:cost of edge, destination vertex

	vertex(int n) :name(n),seq(0),ind(0){}
};

class Graph
{
public:
	typedef map<int, vertex*> vmap;
	vmap graph;
	void addEdge(const int from, const int to,const int weight);
	void addVertex(int newSeq);
};

void Graph::addEdge(const int from, const int to, const int weight)
{
	vertex* f = graph.find(from)->second;
	vertex* t = graph.find(to)->second; 
	pair<int, vertex*> edge = make_pair(weight, t);
	f->adj.push_back(edge);
    ++(t->ind);
}

void Graph::addVertex(int newSeq)
{
	auto iter = graph.find(newSeq);
	if (iter != graph.end())
	{
		vertex * v;
		v = new vertex(newSeq);
		graph[newSeq] = v;
		return;
	}
}

int Graph::size()
{
	return graph.size();
}

void InitialGraph(Graph& myGraph)  // a instance
{
	myGraph.addVertex(0);
	myGraph.addVertex(1);
	myGraph.addVertex(2); 
	myGraph.addVertex(3);
	myGraph.addVertex(4);
	myGraph.addVertex(5);
	myGraph.addEdge(0, 1, 1);// as unweighted graph , weight = 1
	myGraph.addEdge(0, 2, 1);
	myGraph.addEdge(3, 2, 1);
	myGraph.addEdge(3, 0, 1);
	myGraph.addEdge(4, 3, 1); 
	myGraph.addEdge(4, 1, 1);
	myGraph.addEdge(1, 5, 1);

}
```
<a name="JeoiH"></a>
## Topological Sort
<a name="ueS0P"></a>
### 1. 什么是拓扑排序？意义是什么？
首先先理解拓扑的含义：the way the parts of sth are arranged and related. 形象的来说：比如说一个人要自学计算机科学知识(sth)，而该领域知识由很多板块的内容(parts)构成，这些内容又相互关联(在学懂A课程前必须有B课程的基础，related)，那么他就面临一个问题，怎么安排学习顺序(路径，arranged)？一个显然不合理的安排是在学习操作系统先于数据结构与算法，因为数据结构与算法是学习OS的前置课程。**一个不违反前置条件的学习路径就是一个拓扑排序，其意义就是得到一条合理的学习路径。**说的更广泛一点，拓扑排序就是得到一个合理的处理顺序。<br />如果我们把各板块内容之间铺垫关系画成一张图，各板块为顶点，有向边作为关联(如 Vertex数据结构与算法指向Vertex操作系统)，那么**拓扑排序在这个图中体现为一条沿着有向边方向的路径**(即路径中任意一段单位路径u到v,不存在边(v,u))<br />显然，**存在拓扑排序的图一定是有向无环图**( directed acyclic graph，DAG),[如果图是有环的，那么就找不到符合要求的路径，因为总会违反前置条件](https://www.quora.com/Why-must-a-graph-with-a-topological-sort-be-acyclic-and-why-must-an-acyclic-graph-have-a-topological-sort)
<a name="yLpq8"></a>
### 2. 如何实现拓扑排序算法？怎样使其更高效？
对于我们要选择的第一个顶点，显然的，它必须没有前置条件，即没有顶点指向它，入度(indegree为0)。我们选择这样一个点，然后**在图中抹去该点和它的边**(显然的，都是由它发出的边，与它相关的顶点入度也随之更新)，在剩下的图中重复这个步骤，直到图为空(如果找不到入度为0的顶点而图不为空，说明图不是DAG，存在环)。顶点被抹去的顺序，就是拓扑排序。<br />如何快速寻找到入度为0的点呢？如果通过遍历顶点集的方式，那么开销是很大的，特别是如果图很稀疏(边很少，sparse)，那么要去除的边也是很少的，因此每一步被影响到入度的顶点的数量也是很少的，即大部分的顶点入度是一直没变的，反复的遍历它们是pointless行为。<br />提升效率方法是**将入度为0的点单独拿出来，我们可以用栈或队列来存储。在每次去掉顶点和边之后，我们将更新后入度变为0的顶点加入到队列中**。显然的，队列的出队顺序就是我们要求的拓扑排序。
```cpp
#pragma once
#include<iostream>
#include"Graph.h"
#include<queue>
using namespace std;

void TopologicalSort(Graph& myGraph)
{ 
	queue<vertex*> zero;
	int counter = -1;
	int N = myGraph.size();

	for (auto& iter :myGraph.graph) // initalize vertexSet which indegree is zero
	{
		if (iter.second->ind == 0)
			zero.push(iter.second);
	}

	while (!zero.empty())
	{
		vertex* v = zero.front();
		zero.pop();
		v->seq = ++counter;
		cout << v->name << ' ';
		int adjN = v->adj.size();
		for (int i = 0; i < adjN; ++i)
		{
			if (--(v->adj[i].second->ind) == 0)
				zero.push(v->adj[i].second);
		}
	}

	if (counter != N-1)
		abort();
}
```
<a name="Ms2lL"></a>
## Shortest-Path Algorithms
<a name="TdCMl"></a>
### 1. 什么是单源最短路径问题？
单源最短路径问题(Single-Source Shortest-Path Problem): **给定一个有权图(weighted graph,可以有环)中的一个点**`**v**`**，求出**`**v**`**到其它所有顶点的最短路径**，that is ,在答案所呈现的结果图中，`v`到结果图中任意一个顶点`w`的路径，其长度是`v`与`w`之间存在的所有路径中，长度最短的那条。<br />也可以从另一个角度理解这个问题，即如果把边长视为开销，那么**该问题就是要以最小的开销，从源顶点开始，覆盖整张图的顶点**
<a name="q5MIP"></a>
### 2.为什么Breadth-First Search可以解决Unweighted Shortest-Paths?
为了理解SSSP问题，我们先考虑无权图，无权图可视为权重为1的有权图<br />我们先设置问题的初始状态：`v`到任意`w`的距离都是无穷大，任意`w`的状态都是unknown(`v`到该`w`的最短路径还未确定)。<br />我们首先能确定的是`v`能直接到达的点(`v`的邻接点)，因为v只有唯一途径能到达这些点，所以这个唯一途径就是最短路径。我们把这些点称为第一层，其最短路径均为1。接着，我们能确定的点显然是第一层的邻接点，**因为**`**v**`**能通过第一层的点去访问只有这些点**，我们把这些点称为第二层，其最短路径自然为2。按照这样的一个广度优先搜索的逻辑，我们便能确定所有点的最短路径。<br />因为是无权图，所以不存在对路径长度的多次更新（关于该点可见后续讨论中的例子：不存在将s->w1->w3更改为s->w2->w3的可能），对每个顶点的处理，只需简单的将其distance信息设置为前一个顶点的distance+1即可。
```cpp
void Graph::unweighted_Shortest_Path_with_queue(vertex& s)
{
	queue<vertex*> q;
	for (auto& iter : graph)
		iter.second->dist = INFINITY;
	s.dist = 0;
	q.push(&s);
	while (!q.empty())
	{
		vertex v = *q.front(); // priority '.' > '*'
		q.pop(); 
		for (auto& adjac : v.adj)
		{
			adjac.second->dist = v.dist + 1; 
			adjac.second->path = v.name;
			q.push(adjac.second);
		}
	}
}

void Graph::unweighted_Shortest_Path(vertex& s)
{
	int NUM_VERTICES = size();
	for (auto& iter : graph) 
	{
		iter.second->dist = INFINITY;
		iter.second->known = false;
	}
	s.dist = 0;

	for (int currDist = 0; currDist < NUM_VERTICES; ++currDist) // double for loops:inefficiency
		for (auto& iter : graph) 
			if (!iter.second->known && iter.second->dist == currDist)
			{
				iter.second->known = true;
				for (auto& adjac : (iter.second->adj))
				{
					adjac.second->dist = currDist + 1; // update distance
					adjac.second->path = iter.second->name;
				}
			}
}
```
<a name="YjF5L"></a>
### 3.为什么Dijkstra Algorithm每一步要选择最近的结点，为什么该算法可以解决Single-Source Weighted？
与上一问一样，要找到`v`到所有顶点的最短路径，我们总得先知道`v`能到达哪些点。所以我们在用Dijkstra解决SSSP的时候，我们似乎也应该按照这样的结点选择顺序：首先找的是`v`的邻接点，然后再邻接点..... 。但是我们需要注意，**我们实际选择结点的顺序(选择结点即把结点变为known，说明找到了到它的最短路径)，是不断的选取未确定结点中离**`**v**`**距离最近的那一个，而不是像无权图中那样邻接点接着邻接点的广度搜索。**<br />**为什么要选择最近的那一个？**<br />举个最简单的例子：在这个图中，我们首先探索了源顶点的邻接点w1,w2，更新其dist为ds+dcost，那么w1.dist=1，w2.dist =3。那么下一轮我们选择那个顶点进行探索(其邻接点)呢？显然是w1，因为在当前条件下，我们只知道源顶点离w1更近一些，那么到w3(后续未知结点)的最短路径自然更可能的在w1这边(我们还不知道后续顶点的dist信息)。**因此我们在每次选择一个顶点以探索他的邻接点(更新dist信息)，都要选择当前距离v最近的那个，因为经过这样一个点的路径才最有可能是(到后续顶点)最短路径/开销可能最少。**<br />为什么在无权图中不用这样做？<br />无权图的边长权重都为1，开销的是一样的。<br />![](https://cdn.nlark.com/yuque/0/2022/jpeg/29536731/1667390674960-21e67dd1-f11c-4336-a168-c237056626fe.jpeg)<br />我们要有一个认知：**源顶点**`**v**`**到某一目标顶点**`**w****t**`**之间的最短路径①上存在着几个中间顶点，那么v到任意一个中间结点**`**w****i**`**的最短路径②一定与①重合。**或者说v到目标顶点的最短路径，是目标顶点在该路径的上一个顶点的最短路径延长了一个边长所得到的。<br />**因此我们逐步找到各顶点的最短路径，并从之前找到的最短路径(以开销最少的方式)延展到其它顶点上，便可以找到到所有顶点的最短路径。**
```cpp
void Graph::Dijkstra_Algorithm(vertex& s)
{
	for (auto& iter : graph)
	{
		iter.second->dist = INFINITY;
		iter.second->known = false;
	}
	s.dist = 0;
	while (existUnknown()) //there is an unknown vertex
	{
 		vertex* v = smallestUnknown();   // smallest unknown distance vertex
		v->known = true;
		for (auto& iter : v->adj)
		{
			if (v->dist + iter.first < iter.second->dist) 
			{
				iter.second->dist = v->dist + iter.first; // update
				iter.second->path = v->name;
			}
		}
	}
}

bool Graph:: existUnknown()
{
	for (auto& iter : graph)  // iteration 
	{
		if (!iter.second->known)
			return true;
	}
	return false;
}

vertex* Graph::smallestUnknown()
{
	vertex* min = graph.begin()->second;
	for (auto& iter : graph)  // iteration 
	{
		if (!iter.second->known && iter.second->dist < min->dist)
			min = iter.second;
	}
	return min;
}
```
<a name="b4gnk"></a>
### 4.为什么Dijkstra Algorithm不适用于有负权值边的图
在Dijkstra算法中，我们**一旦将一个顶点**`**v**`**由unknown标记为known，就说明由**`**s**`**到**`**v**`**的最短路径已经找到，且不会再改变，即算法不会在后续过程中回头(look back)修改到**`**v**`**的最短路程这一信息**。如果我们用Dijkstra算法在图中确定了`v`的最短路径，然后发现`v`到某个邻接点`u`(状态为unknown)的边权值为负，那么此时`s`到`v`的实际最短路径就发生了变化：s->v->w->v，然而因为Dijkstra算法不会look back，所以算法继续保持之前的最短路径，因此会产生与事实不符的结果。
<a name="wzqMO"></a>
## Critical Path Problems
<a name="MCV9V"></a>
### 1. 如何理解关键路径？关键路径是什么？
一个项目由多个可独立完成工作(jobs)组成，各工作之间存在优先级限制关系(precedence constraint)，即某一项工作必须在完成另一项(或多项)工作后才能启动。①如何确定项目的最快(早)完成时间？②如何确定某些工作的可延迟时间 (that is,slack time 松弛时间) 以不至于增加整个项目的完成时间？<br />**关键路径这样一组工作序列：该工作序列可以用来确定项目的最快完成时间。对第二点，关键路径上的所有工作的可延迟时间均为0，关键路径上的任何一个工作被延迟，都会增加整个项目的完成时间，这也是为什么称之为"关键"。**<br />这样的项目可以体现在有向无环图中。为什么一定是无环？与拓扑排序一样的道理，如果有几个工作成环状相互制约，那就无法开启任何一项工作，因为总是违反其优先级限制关系。**关键路径在这样的图中体现为从开始到结束的最长路径(longest path)**<br />注意路径的长度由边的权值(工作完成所需时间)决定而不是边的数量
<a name="oj5FV"></a>
### 2. 为什么图的最长路径就是关键路径？
> 关键路径是通过识别最长的相关活动并测量从开始到结束完成它们所需的时间来确定的 -wikipedia

我们首先要理解一条路径上的各个工作节点之间存在着严格的先后关系，即优先级限制关系。这就说明**各工作只能串行的执行**，哪怕你有很多处理器(processors)也必须等待高优先级的工作执行完毕后再开启新的工作。互不关联(不在同一路径)的工作可以并行的执行，所以**在最长路径上的最后一个工作执行完毕时，其它路径也一定执行完毕，即整个项目执行完毕。因此最长路径决定了项目的完成时间，不延迟的执行最长路径(上的工作)所花的时间，就是项目的最快完成时间。**
<a name="Aa03a"></a>
## Network Flow Problems
<a name="RBuq3"></a>
### 1. 如何理解网络流问题？
网络流问题就是从一个端`s`往另一个端`t`发送流(Flow,如通水，运货，发送数据包等)，要经过数个中间节点，各节点间的边的传输容量是有限的(如水管的阈值，超过了这个值水管会破裂)，问从s发送到t的最大流(the maximum amount of ﬂow)是多少。显然的要找出这个最大流，**我们要解决的根本问题是如何正确安排运输方案(即路径选择)以最大化流**。<br />**如何计算图中流的数量(the amount of ﬂow)？** **只需看从端**`**s**`**发出了多少流即可**(端`t`肯定接受同样数量的流，除非“漏水”了)<br />**怎么验证我们得到的流的数量是最大的？**把图分割(cut)为两个部分，一部分包含s，另一部分包含t(其余结点随意，因此存在多种切割方式)，**经过切割线上的边的容量总和决定了最大流的界限，容量总和的最小值即为图所能承受的最大流的值(the minimum cut capacity is exactly equal to the maximum ﬂow)**<br />由此我们可以看出，**解决最大流问题的目的不是为了得到最大流的值，而是知道能达到最大流的运输方案**<br />[**网络流问题基础 Network Flow Problems**](https://www.youtube.com/watch?v=6DFWUgV5Osc&list=PLvOO0btloRnsbnIIbX6ywvD8OZUTT0_ID&index=8)
<a name="LytbY"></a>
### 2. 如何得到最大流？
首先考虑简单的算法(naive algorithm )，我们随机的选择路径( free to choose any path from s to t)，直到Gr中不存在s到t的路径，看能否得到最大流，事实证明，这样是不可靠的，得到的方案可能会使我们会得到一个小于最大流的值。**该方法存在的缺陷是，一旦在某一步选中了错误的路径(不属于最大流方案的路径)，算法无法纠正错误，因此找不到最大流。**<br />我们改进一下这个算法，**在每次进行一次路径选择(即在G****r****图中相应边执行了减法)之后，接着在相应边上加上一条方向相反的边，其权值就等于刚刚该边减去的值。称为Ford–Fulkerson algorithm**<br />**这样做的目的，是让算法有了撤销(undo)的能力，可以把不好的路径撤销掉，因此该算法总能找到正确的路径，进而找到最大流。**<br />[**Ford-Fulkerson Algorithm 寻找网络最大流  -Dr Wang **](https://www.youtube.com/watch?v=8sLON0DqLZo&list=PLvOO0btloRnsbnIIbX6ywvD8OZUTT0_ID&index=9)


