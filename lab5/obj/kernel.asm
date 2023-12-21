
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c020b137          	lui	sp,0xc020b

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	000a1517          	auipc	a0,0xa1
ffffffffc020003a:	0c250513          	addi	a0,a0,194 # ffffffffc02a10f8 <edata>
ffffffffc020003e:	000ac617          	auipc	a2,0xac
ffffffffc0200042:	64260613          	addi	a2,a2,1602 # ffffffffc02ac680 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	77e060ef          	jal	ra,ffffffffc02067cc <memset>
    cons_init();                // init the console
ffffffffc0200052:	536000ef          	jal	ra,ffffffffc0200588 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00006597          	auipc	a1,0x6
ffffffffc020005a:	7a258593          	addi	a1,a1,1954 # ffffffffc02067f8 <etext+0x2>
ffffffffc020005e:	00006517          	auipc	a0,0x6
ffffffffc0200062:	7ba50513          	addi	a0,a0,1978 # ffffffffc0206818 <etext+0x22>
ffffffffc0200066:	128000ef          	jal	ra,ffffffffc020018e <cprintf>

    print_kerninfo();
ffffffffc020006a:	1ac000ef          	jal	ra,ffffffffc0200216 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	5fe020ef          	jal	ra,ffffffffc020266c <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5ee000ef          	jal	ra,ffffffffc0200660 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5ec000ef          	jal	ra,ffffffffc0200662 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	4aa040ef          	jal	ra,ffffffffc0204524 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	6df050ef          	jal	ra,ffffffffc0205f5c <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	57a000ef          	jal	ra,ffffffffc02005fc <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	3c8030ef          	jal	ra,ffffffffc020344e <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	4a8000ef          	jal	ra,ffffffffc0200532 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	5c6000ef          	jal	ra,ffffffffc0200654 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc0200092:	016060ef          	jal	ra,ffffffffc02060a8 <cpu_idle>

ffffffffc0200096 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200096:	715d                	addi	sp,sp,-80
ffffffffc0200098:	e486                	sd	ra,72(sp)
ffffffffc020009a:	e0a2                	sd	s0,64(sp)
ffffffffc020009c:	fc26                	sd	s1,56(sp)
ffffffffc020009e:	f84a                	sd	s2,48(sp)
ffffffffc02000a0:	f44e                	sd	s3,40(sp)
ffffffffc02000a2:	f052                	sd	s4,32(sp)
ffffffffc02000a4:	ec56                	sd	s5,24(sp)
ffffffffc02000a6:	e85a                	sd	s6,16(sp)
ffffffffc02000a8:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02000aa:	c901                	beqz	a0,ffffffffc02000ba <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02000ac:	85aa                	mv	a1,a0
ffffffffc02000ae:	00006517          	auipc	a0,0x6
ffffffffc02000b2:	77250513          	addi	a0,a0,1906 # ffffffffc0206820 <etext+0x2a>
ffffffffc02000b6:	0d8000ef          	jal	ra,ffffffffc020018e <cprintf>
readline(const char *prompt) {
ffffffffc02000ba:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000bc:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000be:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000c0:	4aa9                	li	s5,10
ffffffffc02000c2:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000c4:	000a1b97          	auipc	s7,0xa1
ffffffffc02000c8:	034b8b93          	addi	s7,s7,52 # ffffffffc02a10f8 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000cc:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000d0:	136000ef          	jal	ra,ffffffffc0200206 <getchar>
ffffffffc02000d4:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000d6:	00054b63          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000da:	00a95b63          	ble	a0,s2,ffffffffc02000f0 <readline+0x5a>
ffffffffc02000de:	029a5463          	ble	s1,s4,ffffffffc0200106 <readline+0x70>
        c = getchar();
ffffffffc02000e2:	124000ef          	jal	ra,ffffffffc0200206 <getchar>
ffffffffc02000e6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000e8:	fe0559e3          	bgez	a0,ffffffffc02000da <readline+0x44>
            return NULL;
ffffffffc02000ec:	4501                	li	a0,0
ffffffffc02000ee:	a099                	j	ffffffffc0200134 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02000f0:	03341463          	bne	s0,s3,ffffffffc0200118 <readline+0x82>
ffffffffc02000f4:	e8b9                	bnez	s1,ffffffffc020014a <readline+0xb4>
        c = getchar();
ffffffffc02000f6:	110000ef          	jal	ra,ffffffffc0200206 <getchar>
ffffffffc02000fa:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000fc:	fe0548e3          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200100:	fea958e3          	ble	a0,s2,ffffffffc02000f0 <readline+0x5a>
ffffffffc0200104:	4481                	li	s1,0
            cputchar(c);
ffffffffc0200106:	8522                	mv	a0,s0
ffffffffc0200108:	0ba000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            buf[i ++] = c;
ffffffffc020010c:	009b87b3          	add	a5,s7,s1
ffffffffc0200110:	00878023          	sb	s0,0(a5)
ffffffffc0200114:	2485                	addiw	s1,s1,1
ffffffffc0200116:	bf6d                	j	ffffffffc02000d0 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0200118:	01540463          	beq	s0,s5,ffffffffc0200120 <readline+0x8a>
ffffffffc020011c:	fb641ae3          	bne	s0,s6,ffffffffc02000d0 <readline+0x3a>
            cputchar(c);
ffffffffc0200120:	8522                	mv	a0,s0
ffffffffc0200122:	0a0000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            buf[i] = '\0';
ffffffffc0200126:	000a1517          	auipc	a0,0xa1
ffffffffc020012a:	fd250513          	addi	a0,a0,-46 # ffffffffc02a10f8 <edata>
ffffffffc020012e:	94aa                	add	s1,s1,a0
ffffffffc0200130:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200134:	60a6                	ld	ra,72(sp)
ffffffffc0200136:	6406                	ld	s0,64(sp)
ffffffffc0200138:	74e2                	ld	s1,56(sp)
ffffffffc020013a:	7942                	ld	s2,48(sp)
ffffffffc020013c:	79a2                	ld	s3,40(sp)
ffffffffc020013e:	7a02                	ld	s4,32(sp)
ffffffffc0200140:	6ae2                	ld	s5,24(sp)
ffffffffc0200142:	6b42                	ld	s6,16(sp)
ffffffffc0200144:	6ba2                	ld	s7,8(sp)
ffffffffc0200146:	6161                	addi	sp,sp,80
ffffffffc0200148:	8082                	ret
            cputchar(c);
ffffffffc020014a:	4521                	li	a0,8
ffffffffc020014c:	076000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            i --;
ffffffffc0200150:	34fd                	addiw	s1,s1,-1
ffffffffc0200152:	bfbd                	j	ffffffffc02000d0 <readline+0x3a>

ffffffffc0200154 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200154:	1141                	addi	sp,sp,-16
ffffffffc0200156:	e022                	sd	s0,0(sp)
ffffffffc0200158:	e406                	sd	ra,8(sp)
ffffffffc020015a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020015c:	42e000ef          	jal	ra,ffffffffc020058a <cons_putc>
    (*cnt) ++;
ffffffffc0200160:	401c                	lw	a5,0(s0)
}
ffffffffc0200162:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200164:	2785                	addiw	a5,a5,1
ffffffffc0200166:	c01c                	sw	a5,0(s0)
}
ffffffffc0200168:	6402                	ld	s0,0(sp)
ffffffffc020016a:	0141                	addi	sp,sp,16
ffffffffc020016c:	8082                	ret

ffffffffc020016e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020016e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200170:	86ae                	mv	a3,a1
ffffffffc0200172:	862a                	mv	a2,a0
ffffffffc0200174:	006c                	addi	a1,sp,12
ffffffffc0200176:	00000517          	auipc	a0,0x0
ffffffffc020017a:	fde50513          	addi	a0,a0,-34 # ffffffffc0200154 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc020017e:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200180:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200182:	220060ef          	jal	ra,ffffffffc02063a2 <vprintfmt>
    return cnt;
}
ffffffffc0200186:	60e2                	ld	ra,24(sp)
ffffffffc0200188:	4532                	lw	a0,12(sp)
ffffffffc020018a:	6105                	addi	sp,sp,32
ffffffffc020018c:	8082                	ret

ffffffffc020018e <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc020018e:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200190:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200194:	f42e                	sd	a1,40(sp)
ffffffffc0200196:	f832                	sd	a2,48(sp)
ffffffffc0200198:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020019a:	862a                	mv	a2,a0
ffffffffc020019c:	004c                	addi	a1,sp,4
ffffffffc020019e:	00000517          	auipc	a0,0x0
ffffffffc02001a2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200154 <cputch>
ffffffffc02001a6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02001a8:	ec06                	sd	ra,24(sp)
ffffffffc02001aa:	e0ba                	sd	a4,64(sp)
ffffffffc02001ac:	e4be                	sd	a5,72(sp)
ffffffffc02001ae:	e8c2                	sd	a6,80(sp)
ffffffffc02001b0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001b2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001b4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001b6:	1ec060ef          	jal	ra,ffffffffc02063a2 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ba:	60e2                	ld	ra,24(sp)
ffffffffc02001bc:	4512                	lw	a0,4(sp)
ffffffffc02001be:	6125                	addi	sp,sp,96
ffffffffc02001c0:	8082                	ret

ffffffffc02001c2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001c2:	3c80006f          	j	ffffffffc020058a <cons_putc>

ffffffffc02001c6 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02001c6:	1101                	addi	sp,sp,-32
ffffffffc02001c8:	e822                	sd	s0,16(sp)
ffffffffc02001ca:	ec06                	sd	ra,24(sp)
ffffffffc02001cc:	e426                	sd	s1,8(sp)
ffffffffc02001ce:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02001d0:	00054503          	lbu	a0,0(a0)
ffffffffc02001d4:	c51d                	beqz	a0,ffffffffc0200202 <cputs+0x3c>
ffffffffc02001d6:	0405                	addi	s0,s0,1
ffffffffc02001d8:	4485                	li	s1,1
ffffffffc02001da:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02001dc:	3ae000ef          	jal	ra,ffffffffc020058a <cons_putc>
    (*cnt) ++;
ffffffffc02001e0:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc02001e4:	0405                	addi	s0,s0,1
ffffffffc02001e6:	fff44503          	lbu	a0,-1(s0)
ffffffffc02001ea:	f96d                	bnez	a0,ffffffffc02001dc <cputs+0x16>
ffffffffc02001ec:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001f0:	4529                	li	a0,10
ffffffffc02001f2:	398000ef          	jal	ra,ffffffffc020058a <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001f6:	8522                	mv	a0,s0
ffffffffc02001f8:	60e2                	ld	ra,24(sp)
ffffffffc02001fa:	6442                	ld	s0,16(sp)
ffffffffc02001fc:	64a2                	ld	s1,8(sp)
ffffffffc02001fe:	6105                	addi	sp,sp,32
ffffffffc0200200:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200202:	4405                	li	s0,1
ffffffffc0200204:	b7f5                	j	ffffffffc02001f0 <cputs+0x2a>

ffffffffc0200206 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200206:	1141                	addi	sp,sp,-16
ffffffffc0200208:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020020a:	3b6000ef          	jal	ra,ffffffffc02005c0 <cons_getc>
ffffffffc020020e:	dd75                	beqz	a0,ffffffffc020020a <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200210:	60a2                	ld	ra,8(sp)
ffffffffc0200212:	0141                	addi	sp,sp,16
ffffffffc0200214:	8082                	ret

ffffffffc0200216 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200216:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200218:	00006517          	auipc	a0,0x6
ffffffffc020021c:	64050513          	addi	a0,a0,1600 # ffffffffc0206858 <etext+0x62>
void print_kerninfo(void) {
ffffffffc0200220:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200222:	f6dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200226:	00000597          	auipc	a1,0x0
ffffffffc020022a:	e1058593          	addi	a1,a1,-496 # ffffffffc0200036 <kern_init>
ffffffffc020022e:	00006517          	auipc	a0,0x6
ffffffffc0200232:	64a50513          	addi	a0,a0,1610 # ffffffffc0206878 <etext+0x82>
ffffffffc0200236:	f59ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020023a:	00006597          	auipc	a1,0x6
ffffffffc020023e:	5bc58593          	addi	a1,a1,1468 # ffffffffc02067f6 <etext>
ffffffffc0200242:	00006517          	auipc	a0,0x6
ffffffffc0200246:	65650513          	addi	a0,a0,1622 # ffffffffc0206898 <etext+0xa2>
ffffffffc020024a:	f45ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020024e:	000a1597          	auipc	a1,0xa1
ffffffffc0200252:	eaa58593          	addi	a1,a1,-342 # ffffffffc02a10f8 <edata>
ffffffffc0200256:	00006517          	auipc	a0,0x6
ffffffffc020025a:	66250513          	addi	a0,a0,1634 # ffffffffc02068b8 <etext+0xc2>
ffffffffc020025e:	f31ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200262:	000ac597          	auipc	a1,0xac
ffffffffc0200266:	41e58593          	addi	a1,a1,1054 # ffffffffc02ac680 <end>
ffffffffc020026a:	00006517          	auipc	a0,0x6
ffffffffc020026e:	66e50513          	addi	a0,a0,1646 # ffffffffc02068d8 <etext+0xe2>
ffffffffc0200272:	f1dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200276:	000ad597          	auipc	a1,0xad
ffffffffc020027a:	80958593          	addi	a1,a1,-2039 # ffffffffc02aca7f <end+0x3ff>
ffffffffc020027e:	00000797          	auipc	a5,0x0
ffffffffc0200282:	db878793          	addi	a5,a5,-584 # ffffffffc0200036 <kern_init>
ffffffffc0200286:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020028a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020028e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200290:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200294:	95be                	add	a1,a1,a5
ffffffffc0200296:	85a9                	srai	a1,a1,0xa
ffffffffc0200298:	00006517          	auipc	a0,0x6
ffffffffc020029c:	66050513          	addi	a0,a0,1632 # ffffffffc02068f8 <etext+0x102>
}
ffffffffc02002a0:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002a2:	eedff06f          	j	ffffffffc020018e <cprintf>

ffffffffc02002a6 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002a6:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002a8:	00006617          	auipc	a2,0x6
ffffffffc02002ac:	58060613          	addi	a2,a2,1408 # ffffffffc0206828 <etext+0x32>
ffffffffc02002b0:	04d00593          	li	a1,77
ffffffffc02002b4:	00006517          	auipc	a0,0x6
ffffffffc02002b8:	58c50513          	addi	a0,a0,1420 # ffffffffc0206840 <etext+0x4a>
void print_stackframe(void) {
ffffffffc02002bc:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002be:	1c6000ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02002c2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002c2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002c4:	00006617          	auipc	a2,0x6
ffffffffc02002c8:	74460613          	addi	a2,a2,1860 # ffffffffc0206a08 <commands+0xe0>
ffffffffc02002cc:	00006597          	auipc	a1,0x6
ffffffffc02002d0:	75c58593          	addi	a1,a1,1884 # ffffffffc0206a28 <commands+0x100>
ffffffffc02002d4:	00006517          	auipc	a0,0x6
ffffffffc02002d8:	75c50513          	addi	a0,a0,1884 # ffffffffc0206a30 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002dc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002de:	eb1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002e2:	00006617          	auipc	a2,0x6
ffffffffc02002e6:	75e60613          	addi	a2,a2,1886 # ffffffffc0206a40 <commands+0x118>
ffffffffc02002ea:	00006597          	auipc	a1,0x6
ffffffffc02002ee:	77e58593          	addi	a1,a1,1918 # ffffffffc0206a68 <commands+0x140>
ffffffffc02002f2:	00006517          	auipc	a0,0x6
ffffffffc02002f6:	73e50513          	addi	a0,a0,1854 # ffffffffc0206a30 <commands+0x108>
ffffffffc02002fa:	e95ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002fe:	00006617          	auipc	a2,0x6
ffffffffc0200302:	77a60613          	addi	a2,a2,1914 # ffffffffc0206a78 <commands+0x150>
ffffffffc0200306:	00006597          	auipc	a1,0x6
ffffffffc020030a:	79258593          	addi	a1,a1,1938 # ffffffffc0206a98 <commands+0x170>
ffffffffc020030e:	00006517          	auipc	a0,0x6
ffffffffc0200312:	72250513          	addi	a0,a0,1826 # ffffffffc0206a30 <commands+0x108>
ffffffffc0200316:	e79ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    }
    return 0;
}
ffffffffc020031a:	60a2                	ld	ra,8(sp)
ffffffffc020031c:	4501                	li	a0,0
ffffffffc020031e:	0141                	addi	sp,sp,16
ffffffffc0200320:	8082                	ret

ffffffffc0200322 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200322:	1141                	addi	sp,sp,-16
ffffffffc0200324:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200326:	ef1ff0ef          	jal	ra,ffffffffc0200216 <print_kerninfo>
    return 0;
}
ffffffffc020032a:	60a2                	ld	ra,8(sp)
ffffffffc020032c:	4501                	li	a0,0
ffffffffc020032e:	0141                	addi	sp,sp,16
ffffffffc0200330:	8082                	ret

ffffffffc0200332 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200332:	1141                	addi	sp,sp,-16
ffffffffc0200334:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200336:	f71ff0ef          	jal	ra,ffffffffc02002a6 <print_stackframe>
    return 0;
}
ffffffffc020033a:	60a2                	ld	ra,8(sp)
ffffffffc020033c:	4501                	li	a0,0
ffffffffc020033e:	0141                	addi	sp,sp,16
ffffffffc0200340:	8082                	ret

ffffffffc0200342 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200342:	7115                	addi	sp,sp,-224
ffffffffc0200344:	e962                	sd	s8,144(sp)
ffffffffc0200346:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200348:	00006517          	auipc	a0,0x6
ffffffffc020034c:	62850513          	addi	a0,a0,1576 # ffffffffc0206970 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200350:	ed86                	sd	ra,216(sp)
ffffffffc0200352:	e9a2                	sd	s0,208(sp)
ffffffffc0200354:	e5a6                	sd	s1,200(sp)
ffffffffc0200356:	e1ca                	sd	s2,192(sp)
ffffffffc0200358:	fd4e                	sd	s3,184(sp)
ffffffffc020035a:	f952                	sd	s4,176(sp)
ffffffffc020035c:	f556                	sd	s5,168(sp)
ffffffffc020035e:	f15a                	sd	s6,160(sp)
ffffffffc0200360:	ed5e                	sd	s7,152(sp)
ffffffffc0200362:	e566                	sd	s9,136(sp)
ffffffffc0200364:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200366:	e29ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020036a:	00006517          	auipc	a0,0x6
ffffffffc020036e:	62e50513          	addi	a0,a0,1582 # ffffffffc0206998 <commands+0x70>
ffffffffc0200372:	e1dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    if (tf != NULL) {
ffffffffc0200376:	000c0563          	beqz	s8,ffffffffc0200380 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020037a:	8562                	mv	a0,s8
ffffffffc020037c:	4ce000ef          	jal	ra,ffffffffc020084a <print_trapframe>
ffffffffc0200380:	00006c97          	auipc	s9,0x6
ffffffffc0200384:	5a8c8c93          	addi	s9,s9,1448 # ffffffffc0206928 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200388:	00006997          	auipc	s3,0x6
ffffffffc020038c:	63898993          	addi	s3,s3,1592 # ffffffffc02069c0 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200390:	00006917          	auipc	s2,0x6
ffffffffc0200394:	63890913          	addi	s2,s2,1592 # ffffffffc02069c8 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200398:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020039a:	00006b17          	auipc	s6,0x6
ffffffffc020039e:	636b0b13          	addi	s6,s6,1590 # ffffffffc02069d0 <commands+0xa8>
    if (argc == 0) {
ffffffffc02003a2:	00006a97          	auipc	s5,0x6
ffffffffc02003a6:	686a8a93          	addi	s5,s5,1670 # ffffffffc0206a28 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003aa:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003ac:	854e                	mv	a0,s3
ffffffffc02003ae:	ce9ff0ef          	jal	ra,ffffffffc0200096 <readline>
ffffffffc02003b2:	842a                	mv	s0,a0
ffffffffc02003b4:	dd65                	beqz	a0,ffffffffc02003ac <kmonitor+0x6a>
ffffffffc02003b6:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003ba:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003bc:	c999                	beqz	a1,ffffffffc02003d2 <kmonitor+0x90>
ffffffffc02003be:	854a                	mv	a0,s2
ffffffffc02003c0:	3ee060ef          	jal	ra,ffffffffc02067ae <strchr>
ffffffffc02003c4:	c925                	beqz	a0,ffffffffc0200434 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02003c6:	00144583          	lbu	a1,1(s0)
ffffffffc02003ca:	00040023          	sb	zero,0(s0)
ffffffffc02003ce:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003d0:	f5fd                	bnez	a1,ffffffffc02003be <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02003d2:	dce9                	beqz	s1,ffffffffc02003ac <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003d4:	6582                	ld	a1,0(sp)
ffffffffc02003d6:	00006d17          	auipc	s10,0x6
ffffffffc02003da:	552d0d13          	addi	s10,s10,1362 # ffffffffc0206928 <commands>
    if (argc == 0) {
ffffffffc02003de:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003e0:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003e2:	0d61                	addi	s10,s10,24
ffffffffc02003e4:	3a0060ef          	jal	ra,ffffffffc0206784 <strcmp>
ffffffffc02003e8:	c919                	beqz	a0,ffffffffc02003fe <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ea:	2405                	addiw	s0,s0,1
ffffffffc02003ec:	09740463          	beq	s0,s7,ffffffffc0200474 <kmonitor+0x132>
ffffffffc02003f0:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003f4:	6582                	ld	a1,0(sp)
ffffffffc02003f6:	0d61                	addi	s10,s10,24
ffffffffc02003f8:	38c060ef          	jal	ra,ffffffffc0206784 <strcmp>
ffffffffc02003fc:	f57d                	bnez	a0,ffffffffc02003ea <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003fe:	00141793          	slli	a5,s0,0x1
ffffffffc0200402:	97a2                	add	a5,a5,s0
ffffffffc0200404:	078e                	slli	a5,a5,0x3
ffffffffc0200406:	97e6                	add	a5,a5,s9
ffffffffc0200408:	6b9c                	ld	a5,16(a5)
ffffffffc020040a:	8662                	mv	a2,s8
ffffffffc020040c:	002c                	addi	a1,sp,8
ffffffffc020040e:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200412:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200414:	f8055ce3          	bgez	a0,ffffffffc02003ac <kmonitor+0x6a>
}
ffffffffc0200418:	60ee                	ld	ra,216(sp)
ffffffffc020041a:	644e                	ld	s0,208(sp)
ffffffffc020041c:	64ae                	ld	s1,200(sp)
ffffffffc020041e:	690e                	ld	s2,192(sp)
ffffffffc0200420:	79ea                	ld	s3,184(sp)
ffffffffc0200422:	7a4a                	ld	s4,176(sp)
ffffffffc0200424:	7aaa                	ld	s5,168(sp)
ffffffffc0200426:	7b0a                	ld	s6,160(sp)
ffffffffc0200428:	6bea                	ld	s7,152(sp)
ffffffffc020042a:	6c4a                	ld	s8,144(sp)
ffffffffc020042c:	6caa                	ld	s9,136(sp)
ffffffffc020042e:	6d0a                	ld	s10,128(sp)
ffffffffc0200430:	612d                	addi	sp,sp,224
ffffffffc0200432:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200434:	00044783          	lbu	a5,0(s0)
ffffffffc0200438:	dfc9                	beqz	a5,ffffffffc02003d2 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020043a:	03448863          	beq	s1,s4,ffffffffc020046a <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020043e:	00349793          	slli	a5,s1,0x3
ffffffffc0200442:	0118                	addi	a4,sp,128
ffffffffc0200444:	97ba                	add	a5,a5,a4
ffffffffc0200446:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020044a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020044e:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200450:	e591                	bnez	a1,ffffffffc020045c <kmonitor+0x11a>
ffffffffc0200452:	b749                	j	ffffffffc02003d4 <kmonitor+0x92>
            buf ++;
ffffffffc0200454:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200456:	00044583          	lbu	a1,0(s0)
ffffffffc020045a:	ddad                	beqz	a1,ffffffffc02003d4 <kmonitor+0x92>
ffffffffc020045c:	854a                	mv	a0,s2
ffffffffc020045e:	350060ef          	jal	ra,ffffffffc02067ae <strchr>
ffffffffc0200462:	d96d                	beqz	a0,ffffffffc0200454 <kmonitor+0x112>
ffffffffc0200464:	00044583          	lbu	a1,0(s0)
ffffffffc0200468:	bf91                	j	ffffffffc02003bc <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020046a:	45c1                	li	a1,16
ffffffffc020046c:	855a                	mv	a0,s6
ffffffffc020046e:	d21ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0200472:	b7f1                	j	ffffffffc020043e <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200474:	6582                	ld	a1,0(sp)
ffffffffc0200476:	00006517          	auipc	a0,0x6
ffffffffc020047a:	57a50513          	addi	a0,a0,1402 # ffffffffc02069f0 <commands+0xc8>
ffffffffc020047e:	d11ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
ffffffffc0200482:	b72d                	j	ffffffffc02003ac <kmonitor+0x6a>

ffffffffc0200484 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200484:	000ac317          	auipc	t1,0xac
ffffffffc0200488:	07430313          	addi	t1,t1,116 # ffffffffc02ac4f8 <is_panic>
ffffffffc020048c:	00033303          	ld	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200490:	715d                	addi	sp,sp,-80
ffffffffc0200492:	ec06                	sd	ra,24(sp)
ffffffffc0200494:	e822                	sd	s0,16(sp)
ffffffffc0200496:	f436                	sd	a3,40(sp)
ffffffffc0200498:	f83a                	sd	a4,48(sp)
ffffffffc020049a:	fc3e                	sd	a5,56(sp)
ffffffffc020049c:	e0c2                	sd	a6,64(sp)
ffffffffc020049e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02004a0:	02031c63          	bnez	t1,ffffffffc02004d8 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02004a4:	4785                	li	a5,1
ffffffffc02004a6:	8432                	mv	s0,a2
ffffffffc02004a8:	000ac717          	auipc	a4,0xac
ffffffffc02004ac:	04f73823          	sd	a5,80(a4) # ffffffffc02ac4f8 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b0:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02004b2:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b4:	85aa                	mv	a1,a0
ffffffffc02004b6:	00006517          	auipc	a0,0x6
ffffffffc02004ba:	5f250513          	addi	a0,a0,1522 # ffffffffc0206aa8 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02004be:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004c0:	ccfff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004c4:	65a2                	ld	a1,8(sp)
ffffffffc02004c6:	8522                	mv	a0,s0
ffffffffc02004c8:	ca7ff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc02004cc:	00007517          	auipc	a0,0x7
ffffffffc02004d0:	5fc50513          	addi	a0,a0,1532 # ffffffffc0207ac8 <default_pmm_manager+0x580>
ffffffffc02004d4:	cbbff0ef          	jal	ra,ffffffffc020018e <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004d8:	4501                	li	a0,0
ffffffffc02004da:	4581                	li	a1,0
ffffffffc02004dc:	4601                	li	a2,0
ffffffffc02004de:	48a1                	li	a7,8
ffffffffc02004e0:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004e4:	176000ef          	jal	ra,ffffffffc020065a <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004e8:	4501                	li	a0,0
ffffffffc02004ea:	e59ff0ef          	jal	ra,ffffffffc0200342 <kmonitor>
ffffffffc02004ee:	bfed                	j	ffffffffc02004e8 <__panic+0x64>

ffffffffc02004f0 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004f0:	715d                	addi	sp,sp,-80
ffffffffc02004f2:	e822                	sd	s0,16(sp)
ffffffffc02004f4:	fc3e                	sd	a5,56(sp)
ffffffffc02004f6:	8432                	mv	s0,a2
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004f8:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004fa:	862e                	mv	a2,a1
ffffffffc02004fc:	85aa                	mv	a1,a0
ffffffffc02004fe:	00006517          	auipc	a0,0x6
ffffffffc0200502:	5ca50513          	addi	a0,a0,1482 # ffffffffc0206ac8 <commands+0x1a0>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200506:	ec06                	sd	ra,24(sp)
ffffffffc0200508:	f436                	sd	a3,40(sp)
ffffffffc020050a:	f83a                	sd	a4,48(sp)
ffffffffc020050c:	e0c2                	sd	a6,64(sp)
ffffffffc020050e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200510:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200512:	c7dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200516:	65a2                	ld	a1,8(sp)
ffffffffc0200518:	8522                	mv	a0,s0
ffffffffc020051a:	c55ff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc020051e:	00007517          	auipc	a0,0x7
ffffffffc0200522:	5aa50513          	addi	a0,a0,1450 # ffffffffc0207ac8 <default_pmm_manager+0x580>
ffffffffc0200526:	c69ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    va_end(ap);
}
ffffffffc020052a:	60e2                	ld	ra,24(sp)
ffffffffc020052c:	6442                	ld	s0,16(sp)
ffffffffc020052e:	6161                	addi	sp,sp,80
ffffffffc0200530:	8082                	ret

ffffffffc0200532 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200532:	67e1                	lui	a5,0x18
ffffffffc0200534:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xdc18>
ffffffffc0200538:	000ac717          	auipc	a4,0xac
ffffffffc020053c:	fcf73423          	sd	a5,-56(a4) # ffffffffc02ac500 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200540:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200544:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200546:	953e                	add	a0,a0,a5
ffffffffc0200548:	4601                	li	a2,0
ffffffffc020054a:	4881                	li	a7,0
ffffffffc020054c:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200550:	02000793          	li	a5,32
ffffffffc0200554:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200558:	00006517          	auipc	a0,0x6
ffffffffc020055c:	59050513          	addi	a0,a0,1424 # ffffffffc0206ae8 <commands+0x1c0>
    ticks = 0;
ffffffffc0200560:	000ac797          	auipc	a5,0xac
ffffffffc0200564:	fe07b823          	sd	zero,-16(a5) # ffffffffc02ac550 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200568:	c27ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc020056c <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020056c:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200570:	000ac797          	auipc	a5,0xac
ffffffffc0200574:	f9078793          	addi	a5,a5,-112 # ffffffffc02ac500 <timebase>
ffffffffc0200578:	639c                	ld	a5,0(a5)
ffffffffc020057a:	4581                	li	a1,0
ffffffffc020057c:	4601                	li	a2,0
ffffffffc020057e:	953e                	add	a0,a0,a5
ffffffffc0200580:	4881                	li	a7,0
ffffffffc0200582:	00000073          	ecall
ffffffffc0200586:	8082                	ret

ffffffffc0200588 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200588:	8082                	ret

ffffffffc020058a <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020058a:	100027f3          	csrr	a5,sstatus
ffffffffc020058e:	8b89                	andi	a5,a5,2
ffffffffc0200590:	0ff57513          	andi	a0,a0,255
ffffffffc0200594:	e799                	bnez	a5,ffffffffc02005a2 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200596:	4581                	li	a1,0
ffffffffc0200598:	4601                	li	a2,0
ffffffffc020059a:	4885                	li	a7,1
ffffffffc020059c:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005a0:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005a2:	1101                	addi	sp,sp,-32
ffffffffc02005a4:	ec06                	sd	ra,24(sp)
ffffffffc02005a6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005a8:	0b2000ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc02005ac:	6522                	ld	a0,8(sp)
ffffffffc02005ae:	4581                	li	a1,0
ffffffffc02005b0:	4601                	li	a2,0
ffffffffc02005b2:	4885                	li	a7,1
ffffffffc02005b4:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005b8:	60e2                	ld	ra,24(sp)
ffffffffc02005ba:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005bc:	0980006f          	j	ffffffffc0200654 <intr_enable>

ffffffffc02005c0 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005c0:	100027f3          	csrr	a5,sstatus
ffffffffc02005c4:	8b89                	andi	a5,a5,2
ffffffffc02005c6:	eb89                	bnez	a5,ffffffffc02005d8 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005c8:	4501                	li	a0,0
ffffffffc02005ca:	4581                	li	a1,0
ffffffffc02005cc:	4601                	li	a2,0
ffffffffc02005ce:	4889                	li	a7,2
ffffffffc02005d0:	00000073          	ecall
ffffffffc02005d4:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005d6:	8082                	ret
int cons_getc(void) {
ffffffffc02005d8:	1101                	addi	sp,sp,-32
ffffffffc02005da:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005dc:	07e000ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc02005e0:	4501                	li	a0,0
ffffffffc02005e2:	4581                	li	a1,0
ffffffffc02005e4:	4601                	li	a2,0
ffffffffc02005e6:	4889                	li	a7,2
ffffffffc02005e8:	00000073          	ecall
ffffffffc02005ec:	2501                	sext.w	a0,a0
ffffffffc02005ee:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005f0:	064000ef          	jal	ra,ffffffffc0200654 <intr_enable>
}
ffffffffc02005f4:	60e2                	ld	ra,24(sp)
ffffffffc02005f6:	6522                	ld	a0,8(sp)
ffffffffc02005f8:	6105                	addi	sp,sp,32
ffffffffc02005fa:	8082                	ret

ffffffffc02005fc <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02005fc:	8082                	ret

ffffffffc02005fe <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02005fe:	00253513          	sltiu	a0,a0,2
ffffffffc0200602:	8082                	ret

ffffffffc0200604 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc0200604:	03800513          	li	a0,56
ffffffffc0200608:	8082                	ret

ffffffffc020060a <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020060a:	000a1797          	auipc	a5,0xa1
ffffffffc020060e:	eee78793          	addi	a5,a5,-274 # ffffffffc02a14f8 <ide>
ffffffffc0200612:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200616:	1141                	addi	sp,sp,-16
ffffffffc0200618:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020061a:	95be                	add	a1,a1,a5
ffffffffc020061c:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200620:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200622:	1bc060ef          	jal	ra,ffffffffc02067de <memcpy>
    return 0;
}
ffffffffc0200626:	60a2                	ld	ra,8(sp)
ffffffffc0200628:	4501                	li	a0,0
ffffffffc020062a:	0141                	addi	sp,sp,16
ffffffffc020062c:	8082                	ret

ffffffffc020062e <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc020062e:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200630:	0095979b          	slliw	a5,a1,0x9
ffffffffc0200634:	000a1517          	auipc	a0,0xa1
ffffffffc0200638:	ec450513          	addi	a0,a0,-316 # ffffffffc02a14f8 <ide>
                   size_t nsecs) {
ffffffffc020063c:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020063e:	00969613          	slli	a2,a3,0x9
ffffffffc0200642:	85ba                	mv	a1,a4
ffffffffc0200644:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc0200646:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200648:	196060ef          	jal	ra,ffffffffc02067de <memcpy>
    return 0;
}
ffffffffc020064c:	60a2                	ld	ra,8(sp)
ffffffffc020064e:	4501                	li	a0,0
ffffffffc0200650:	0141                	addi	sp,sp,16
ffffffffc0200652:	8082                	ret

ffffffffc0200654 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200654:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200658:	8082                	ret

ffffffffc020065a <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020065a:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020065e:	8082                	ret

ffffffffc0200660 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200660:	8082                	ret

ffffffffc0200662 <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200662:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200666:	00000797          	auipc	a5,0x0
ffffffffc020066a:	6b278793          	addi	a5,a5,1714 # ffffffffc0200d18 <__alltraps>
ffffffffc020066e:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200672:	000407b7          	lui	a5,0x40
ffffffffc0200676:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020067a:	8082                	ret

ffffffffc020067c <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc020067e:	1141                	addi	sp,sp,-16
ffffffffc0200680:	e022                	sd	s0,0(sp)
ffffffffc0200682:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200684:	00006517          	auipc	a0,0x6
ffffffffc0200688:	7c450513          	addi	a0,a0,1988 # ffffffffc0206e48 <commands+0x520>
void print_regs(struct pushregs* gpr) {
ffffffffc020068c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020068e:	b01ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200692:	640c                	ld	a1,8(s0)
ffffffffc0200694:	00006517          	auipc	a0,0x6
ffffffffc0200698:	7cc50513          	addi	a0,a0,1996 # ffffffffc0206e60 <commands+0x538>
ffffffffc020069c:	af3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02006a0:	680c                	ld	a1,16(s0)
ffffffffc02006a2:	00006517          	auipc	a0,0x6
ffffffffc02006a6:	7d650513          	addi	a0,a0,2006 # ffffffffc0206e78 <commands+0x550>
ffffffffc02006aa:	ae5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02006ae:	6c0c                	ld	a1,24(s0)
ffffffffc02006b0:	00006517          	auipc	a0,0x6
ffffffffc02006b4:	7e050513          	addi	a0,a0,2016 # ffffffffc0206e90 <commands+0x568>
ffffffffc02006b8:	ad7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006bc:	700c                	ld	a1,32(s0)
ffffffffc02006be:	00006517          	auipc	a0,0x6
ffffffffc02006c2:	7ea50513          	addi	a0,a0,2026 # ffffffffc0206ea8 <commands+0x580>
ffffffffc02006c6:	ac9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006ca:	740c                	ld	a1,40(s0)
ffffffffc02006cc:	00006517          	auipc	a0,0x6
ffffffffc02006d0:	7f450513          	addi	a0,a0,2036 # ffffffffc0206ec0 <commands+0x598>
ffffffffc02006d4:	abbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006d8:	780c                	ld	a1,48(s0)
ffffffffc02006da:	00006517          	auipc	a0,0x6
ffffffffc02006de:	7fe50513          	addi	a0,a0,2046 # ffffffffc0206ed8 <commands+0x5b0>
ffffffffc02006e2:	aadff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006e6:	7c0c                	ld	a1,56(s0)
ffffffffc02006e8:	00007517          	auipc	a0,0x7
ffffffffc02006ec:	80850513          	addi	a0,a0,-2040 # ffffffffc0206ef0 <commands+0x5c8>
ffffffffc02006f0:	a9fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006f4:	602c                	ld	a1,64(s0)
ffffffffc02006f6:	00007517          	auipc	a0,0x7
ffffffffc02006fa:	81250513          	addi	a0,a0,-2030 # ffffffffc0206f08 <commands+0x5e0>
ffffffffc02006fe:	a91ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200702:	642c                	ld	a1,72(s0)
ffffffffc0200704:	00007517          	auipc	a0,0x7
ffffffffc0200708:	81c50513          	addi	a0,a0,-2020 # ffffffffc0206f20 <commands+0x5f8>
ffffffffc020070c:	a83ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200710:	682c                	ld	a1,80(s0)
ffffffffc0200712:	00007517          	auipc	a0,0x7
ffffffffc0200716:	82650513          	addi	a0,a0,-2010 # ffffffffc0206f38 <commands+0x610>
ffffffffc020071a:	a75ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020071e:	6c2c                	ld	a1,88(s0)
ffffffffc0200720:	00007517          	auipc	a0,0x7
ffffffffc0200724:	83050513          	addi	a0,a0,-2000 # ffffffffc0206f50 <commands+0x628>
ffffffffc0200728:	a67ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020072c:	702c                	ld	a1,96(s0)
ffffffffc020072e:	00007517          	auipc	a0,0x7
ffffffffc0200732:	83a50513          	addi	a0,a0,-1990 # ffffffffc0206f68 <commands+0x640>
ffffffffc0200736:	a59ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020073a:	742c                	ld	a1,104(s0)
ffffffffc020073c:	00007517          	auipc	a0,0x7
ffffffffc0200740:	84450513          	addi	a0,a0,-1980 # ffffffffc0206f80 <commands+0x658>
ffffffffc0200744:	a4bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200748:	782c                	ld	a1,112(s0)
ffffffffc020074a:	00007517          	auipc	a0,0x7
ffffffffc020074e:	84e50513          	addi	a0,a0,-1970 # ffffffffc0206f98 <commands+0x670>
ffffffffc0200752:	a3dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200756:	7c2c                	ld	a1,120(s0)
ffffffffc0200758:	00007517          	auipc	a0,0x7
ffffffffc020075c:	85850513          	addi	a0,a0,-1960 # ffffffffc0206fb0 <commands+0x688>
ffffffffc0200760:	a2fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200764:	604c                	ld	a1,128(s0)
ffffffffc0200766:	00007517          	auipc	a0,0x7
ffffffffc020076a:	86250513          	addi	a0,a0,-1950 # ffffffffc0206fc8 <commands+0x6a0>
ffffffffc020076e:	a21ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200772:	644c                	ld	a1,136(s0)
ffffffffc0200774:	00007517          	auipc	a0,0x7
ffffffffc0200778:	86c50513          	addi	a0,a0,-1940 # ffffffffc0206fe0 <commands+0x6b8>
ffffffffc020077c:	a13ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200780:	684c                	ld	a1,144(s0)
ffffffffc0200782:	00007517          	auipc	a0,0x7
ffffffffc0200786:	87650513          	addi	a0,a0,-1930 # ffffffffc0206ff8 <commands+0x6d0>
ffffffffc020078a:	a05ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020078e:	6c4c                	ld	a1,152(s0)
ffffffffc0200790:	00007517          	auipc	a0,0x7
ffffffffc0200794:	88050513          	addi	a0,a0,-1920 # ffffffffc0207010 <commands+0x6e8>
ffffffffc0200798:	9f7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020079c:	704c                	ld	a1,160(s0)
ffffffffc020079e:	00007517          	auipc	a0,0x7
ffffffffc02007a2:	88a50513          	addi	a0,a0,-1910 # ffffffffc0207028 <commands+0x700>
ffffffffc02007a6:	9e9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02007aa:	744c                	ld	a1,168(s0)
ffffffffc02007ac:	00007517          	auipc	a0,0x7
ffffffffc02007b0:	89450513          	addi	a0,a0,-1900 # ffffffffc0207040 <commands+0x718>
ffffffffc02007b4:	9dbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007b8:	784c                	ld	a1,176(s0)
ffffffffc02007ba:	00007517          	auipc	a0,0x7
ffffffffc02007be:	89e50513          	addi	a0,a0,-1890 # ffffffffc0207058 <commands+0x730>
ffffffffc02007c2:	9cdff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007c6:	7c4c                	ld	a1,184(s0)
ffffffffc02007c8:	00007517          	auipc	a0,0x7
ffffffffc02007cc:	8a850513          	addi	a0,a0,-1880 # ffffffffc0207070 <commands+0x748>
ffffffffc02007d0:	9bfff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007d4:	606c                	ld	a1,192(s0)
ffffffffc02007d6:	00007517          	auipc	a0,0x7
ffffffffc02007da:	8b250513          	addi	a0,a0,-1870 # ffffffffc0207088 <commands+0x760>
ffffffffc02007de:	9b1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007e2:	646c                	ld	a1,200(s0)
ffffffffc02007e4:	00007517          	auipc	a0,0x7
ffffffffc02007e8:	8bc50513          	addi	a0,a0,-1860 # ffffffffc02070a0 <commands+0x778>
ffffffffc02007ec:	9a3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007f0:	686c                	ld	a1,208(s0)
ffffffffc02007f2:	00007517          	auipc	a0,0x7
ffffffffc02007f6:	8c650513          	addi	a0,a0,-1850 # ffffffffc02070b8 <commands+0x790>
ffffffffc02007fa:	995ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200800:	00007517          	auipc	a0,0x7
ffffffffc0200804:	8d050513          	addi	a0,a0,-1840 # ffffffffc02070d0 <commands+0x7a8>
ffffffffc0200808:	987ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020080c:	706c                	ld	a1,224(s0)
ffffffffc020080e:	00007517          	auipc	a0,0x7
ffffffffc0200812:	8da50513          	addi	a0,a0,-1830 # ffffffffc02070e8 <commands+0x7c0>
ffffffffc0200816:	979ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020081a:	746c                	ld	a1,232(s0)
ffffffffc020081c:	00007517          	auipc	a0,0x7
ffffffffc0200820:	8e450513          	addi	a0,a0,-1820 # ffffffffc0207100 <commands+0x7d8>
ffffffffc0200824:	96bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200828:	786c                	ld	a1,240(s0)
ffffffffc020082a:	00007517          	auipc	a0,0x7
ffffffffc020082e:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0207118 <commands+0x7f0>
ffffffffc0200832:	95dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200836:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200838:	6402                	ld	s0,0(sp)
ffffffffc020083a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020083c:	00007517          	auipc	a0,0x7
ffffffffc0200840:	8f450513          	addi	a0,a0,-1804 # ffffffffc0207130 <commands+0x808>
}
ffffffffc0200844:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200846:	949ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc020084a <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc020084a:	1141                	addi	sp,sp,-16
ffffffffc020084c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020084e:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200850:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200852:	00007517          	auipc	a0,0x7
ffffffffc0200856:	8f650513          	addi	a0,a0,-1802 # ffffffffc0207148 <commands+0x820>
print_trapframe(struct trapframe *tf) {
ffffffffc020085a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020085c:	933ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200860:	8522                	mv	a0,s0
ffffffffc0200862:	e1bff0ef          	jal	ra,ffffffffc020067c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200866:	10043583          	ld	a1,256(s0)
ffffffffc020086a:	00007517          	auipc	a0,0x7
ffffffffc020086e:	8f650513          	addi	a0,a0,-1802 # ffffffffc0207160 <commands+0x838>
ffffffffc0200872:	91dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200876:	10843583          	ld	a1,264(s0)
ffffffffc020087a:	00007517          	auipc	a0,0x7
ffffffffc020087e:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0207178 <commands+0x850>
ffffffffc0200882:	90dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200886:	11043583          	ld	a1,272(s0)
ffffffffc020088a:	00007517          	auipc	a0,0x7
ffffffffc020088e:	90650513          	addi	a0,a0,-1786 # ffffffffc0207190 <commands+0x868>
ffffffffc0200892:	8fdff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200896:	11843583          	ld	a1,280(s0)
}
ffffffffc020089a:	6402                	ld	s0,0(sp)
ffffffffc020089c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020089e:	00007517          	auipc	a0,0x7
ffffffffc02008a2:	90250513          	addi	a0,a0,-1790 # ffffffffc02071a0 <commands+0x878>
}
ffffffffc02008a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02008a8:	8e7ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc02008ac <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc02008ac:	1101                	addi	sp,sp,-32
ffffffffc02008ae:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008b0:	000ac497          	auipc	s1,0xac
ffffffffc02008b4:	db848493          	addi	s1,s1,-584 # ffffffffc02ac668 <check_mm_struct>
ffffffffc02008b8:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008ba:	e822                	sd	s0,16(sp)
ffffffffc02008bc:	ec06                	sd	ra,24(sp)
ffffffffc02008be:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008c0:	cbbd                	beqz	a5,ffffffffc0200936 <pgfault_handler+0x8a>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008c2:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008c6:	11053583          	ld	a1,272(a0)
ffffffffc02008ca:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ce:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008d2:	cba1                	beqz	a5,ffffffffc0200922 <pgfault_handler+0x76>
ffffffffc02008d4:	11843703          	ld	a4,280(s0)
ffffffffc02008d8:	47bd                	li	a5,15
ffffffffc02008da:	05700693          	li	a3,87
ffffffffc02008de:	00f70463          	beq	a4,a5,ffffffffc02008e6 <pgfault_handler+0x3a>
ffffffffc02008e2:	05200693          	li	a3,82
ffffffffc02008e6:	00006517          	auipc	a0,0x6
ffffffffc02008ea:	4e250513          	addi	a0,a0,1250 # ffffffffc0206dc8 <commands+0x4a0>
ffffffffc02008ee:	8a1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008f2:	6088                	ld	a0,0(s1)
ffffffffc02008f4:	c129                	beqz	a0,ffffffffc0200936 <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008f6:	000ac797          	auipc	a5,0xac
ffffffffc02008fa:	c3a78793          	addi	a5,a5,-966 # ffffffffc02ac530 <current>
ffffffffc02008fe:	6398                	ld	a4,0(a5)
ffffffffc0200900:	000ac797          	auipc	a5,0xac
ffffffffc0200904:	c3878793          	addi	a5,a5,-968 # ffffffffc02ac538 <idleproc>
ffffffffc0200908:	639c                	ld	a5,0(a5)
ffffffffc020090a:	04f71763          	bne	a4,a5,ffffffffc0200958 <pgfault_handler+0xac>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020090e:	11043603          	ld	a2,272(s0)
ffffffffc0200912:	11843583          	ld	a1,280(s0)
}
ffffffffc0200916:	6442                	ld	s0,16(sp)
ffffffffc0200918:	60e2                	ld	ra,24(sp)
ffffffffc020091a:	64a2                	ld	s1,8(sp)
ffffffffc020091c:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020091e:	14c0406f          	j	ffffffffc0204a6a <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200922:	11843703          	ld	a4,280(s0)
ffffffffc0200926:	47bd                	li	a5,15
ffffffffc0200928:	05500613          	li	a2,85
ffffffffc020092c:	05700693          	li	a3,87
ffffffffc0200930:	faf719e3          	bne	a4,a5,ffffffffc02008e2 <pgfault_handler+0x36>
ffffffffc0200934:	bf4d                	j	ffffffffc02008e6 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc0200936:	000ac797          	auipc	a5,0xac
ffffffffc020093a:	bfa78793          	addi	a5,a5,-1030 # ffffffffc02ac530 <current>
ffffffffc020093e:	639c                	ld	a5,0(a5)
ffffffffc0200940:	cf85                	beqz	a5,ffffffffc0200978 <pgfault_handler+0xcc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200942:	11043603          	ld	a2,272(s0)
ffffffffc0200946:	11843583          	ld	a1,280(s0)
}
ffffffffc020094a:	6442                	ld	s0,16(sp)
ffffffffc020094c:	60e2                	ld	ra,24(sp)
ffffffffc020094e:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200950:	7788                	ld	a0,40(a5)
}
ffffffffc0200952:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200954:	1160406f          	j	ffffffffc0204a6a <do_pgfault>
        assert(current == idleproc);
ffffffffc0200958:	00006697          	auipc	a3,0x6
ffffffffc020095c:	49068693          	addi	a3,a3,1168 # ffffffffc0206de8 <commands+0x4c0>
ffffffffc0200960:	00006617          	auipc	a2,0x6
ffffffffc0200964:	4a060613          	addi	a2,a2,1184 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0200968:	06b00593          	li	a1,107
ffffffffc020096c:	00006517          	auipc	a0,0x6
ffffffffc0200970:	4ac50513          	addi	a0,a0,1196 # ffffffffc0206e18 <commands+0x4f0>
ffffffffc0200974:	b11ff0ef          	jal	ra,ffffffffc0200484 <__panic>
            print_trapframe(tf);
ffffffffc0200978:	8522                	mv	a0,s0
ffffffffc020097a:	ed1ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020097e:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200982:	11043583          	ld	a1,272(s0)
ffffffffc0200986:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020098a:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020098e:	e399                	bnez	a5,ffffffffc0200994 <pgfault_handler+0xe8>
ffffffffc0200990:	05500613          	li	a2,85
ffffffffc0200994:	11843703          	ld	a4,280(s0)
ffffffffc0200998:	47bd                	li	a5,15
ffffffffc020099a:	02f70663          	beq	a4,a5,ffffffffc02009c6 <pgfault_handler+0x11a>
ffffffffc020099e:	05200693          	li	a3,82
ffffffffc02009a2:	00006517          	auipc	a0,0x6
ffffffffc02009a6:	42650513          	addi	a0,a0,1062 # ffffffffc0206dc8 <commands+0x4a0>
ffffffffc02009aa:	fe4ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            panic("unhandled page fault.\n");
ffffffffc02009ae:	00006617          	auipc	a2,0x6
ffffffffc02009b2:	48260613          	addi	a2,a2,1154 # ffffffffc0206e30 <commands+0x508>
ffffffffc02009b6:	07200593          	li	a1,114
ffffffffc02009ba:	00006517          	auipc	a0,0x6
ffffffffc02009be:	45e50513          	addi	a0,a0,1118 # ffffffffc0206e18 <commands+0x4f0>
ffffffffc02009c2:	ac3ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009c6:	05700693          	li	a3,87
ffffffffc02009ca:	bfe1                	j	ffffffffc02009a2 <pgfault_handler+0xf6>

ffffffffc02009cc <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009cc:	11853783          	ld	a5,280(a0)
ffffffffc02009d0:	577d                	li	a4,-1
ffffffffc02009d2:	8305                	srli	a4,a4,0x1
ffffffffc02009d4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02009d6:	472d                	li	a4,11
ffffffffc02009d8:	08f76763          	bltu	a4,a5,ffffffffc0200a66 <interrupt_handler+0x9a>
ffffffffc02009dc:	00006717          	auipc	a4,0x6
ffffffffc02009e0:	12870713          	addi	a4,a4,296 # ffffffffc0206b04 <commands+0x1dc>
ffffffffc02009e4:	078a                	slli	a5,a5,0x2
ffffffffc02009e6:	97ba                	add	a5,a5,a4
ffffffffc02009e8:	439c                	lw	a5,0(a5)
ffffffffc02009ea:	97ba                	add	a5,a5,a4
ffffffffc02009ec:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009ee:	00006517          	auipc	a0,0x6
ffffffffc02009f2:	39a50513          	addi	a0,a0,922 # ffffffffc0206d88 <commands+0x460>
ffffffffc02009f6:	f98ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009fa:	00006517          	auipc	a0,0x6
ffffffffc02009fe:	36e50513          	addi	a0,a0,878 # ffffffffc0206d68 <commands+0x440>
ffffffffc0200a02:	f8cff06f          	j	ffffffffc020018e <cprintf>
            cprintf("User software interrupt\n");
ffffffffc0200a06:	00006517          	auipc	a0,0x6
ffffffffc0200a0a:	32250513          	addi	a0,a0,802 # ffffffffc0206d28 <commands+0x400>
ffffffffc0200a0e:	f80ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a12:	00006517          	auipc	a0,0x6
ffffffffc0200a16:	33650513          	addi	a0,a0,822 # ffffffffc0206d48 <commands+0x420>
ffffffffc0200a1a:	f74ff06f          	j	ffffffffc020018e <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a1e:	00006517          	auipc	a0,0x6
ffffffffc0200a22:	38a50513          	addi	a0,a0,906 # ffffffffc0206da8 <commands+0x480>
ffffffffc0200a26:	f68ff06f          	j	ffffffffc020018e <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a2a:	1141                	addi	sp,sp,-16
ffffffffc0200a2c:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a2e:	b3fff0ef          	jal	ra,ffffffffc020056c <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a32:	000ac797          	auipc	a5,0xac
ffffffffc0200a36:	b1e78793          	addi	a5,a5,-1250 # ffffffffc02ac550 <ticks>
ffffffffc0200a3a:	639c                	ld	a5,0(a5)
ffffffffc0200a3c:	06400713          	li	a4,100
ffffffffc0200a40:	0785                	addi	a5,a5,1
ffffffffc0200a42:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a46:	000ac697          	auipc	a3,0xac
ffffffffc0200a4a:	b0f6b523          	sd	a5,-1270(a3) # ffffffffc02ac550 <ticks>
ffffffffc0200a4e:	eb09                	bnez	a4,ffffffffc0200a60 <interrupt_handler+0x94>
ffffffffc0200a50:	000ac797          	auipc	a5,0xac
ffffffffc0200a54:	ae078793          	addi	a5,a5,-1312 # ffffffffc02ac530 <current>
ffffffffc0200a58:	639c                	ld	a5,0(a5)
ffffffffc0200a5a:	c399                	beqz	a5,ffffffffc0200a60 <interrupt_handler+0x94>
                current->need_resched = 1;
ffffffffc0200a5c:	4705                	li	a4,1
ffffffffc0200a5e:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a60:	60a2                	ld	ra,8(sp)
ffffffffc0200a62:	0141                	addi	sp,sp,16
ffffffffc0200a64:	8082                	ret
            print_trapframe(tf);
ffffffffc0200a66:	de5ff06f          	j	ffffffffc020084a <print_trapframe>

ffffffffc0200a6a <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a6a:	11853783          	ld	a5,280(a0)
ffffffffc0200a6e:	473d                	li	a4,15
ffffffffc0200a70:	1ef76b63          	bltu	a4,a5,ffffffffc0200c66 <exception_handler+0x1fc>
ffffffffc0200a74:	00006717          	auipc	a4,0x6
ffffffffc0200a78:	0c070713          	addi	a4,a4,192 # ffffffffc0206b34 <commands+0x20c>
ffffffffc0200a7c:	078a                	slli	a5,a5,0x2
ffffffffc0200a7e:	97ba                	add	a5,a5,a4
ffffffffc0200a80:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a82:	1101                	addi	sp,sp,-32
ffffffffc0200a84:	e822                	sd	s0,16(sp)
ffffffffc0200a86:	ec06                	sd	ra,24(sp)
ffffffffc0200a88:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a8a:	97ba                	add	a5,a5,a4
ffffffffc0200a8c:	842a                	mv	s0,a0
ffffffffc0200a8e:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a90:	00006517          	auipc	a0,0x6
ffffffffc0200a94:	1f050513          	addi	a0,a0,496 # ffffffffc0206c80 <commands+0x358>
ffffffffc0200a98:	ef6ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            tf->epc += 4;
ffffffffc0200a9c:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200aa0:	60e2                	ld	ra,24(sp)
ffffffffc0200aa2:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200aa4:	0791                	addi	a5,a5,4
ffffffffc0200aa6:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200aaa:	6442                	ld	s0,16(sp)
ffffffffc0200aac:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200aae:	7f00506f          	j	ffffffffc020629e <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200ab2:	00006517          	auipc	a0,0x6
ffffffffc0200ab6:	1ee50513          	addi	a0,a0,494 # ffffffffc0206ca0 <commands+0x378>
}
ffffffffc0200aba:	6442                	ld	s0,16(sp)
ffffffffc0200abc:	60e2                	ld	ra,24(sp)
ffffffffc0200abe:	64a2                	ld	s1,8(sp)
ffffffffc0200ac0:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200ac2:	eccff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200ac6:	00006517          	auipc	a0,0x6
ffffffffc0200aca:	1fa50513          	addi	a0,a0,506 # ffffffffc0206cc0 <commands+0x398>
ffffffffc0200ace:	b7f5                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ad0:	00006517          	auipc	a0,0x6
ffffffffc0200ad4:	21050513          	addi	a0,a0,528 # ffffffffc0206ce0 <commands+0x3b8>
ffffffffc0200ad8:	eb6ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200adc:	8522                	mv	a0,s0
ffffffffc0200ade:	dcfff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200ae2:	84aa                	mv	s1,a0
ffffffffc0200ae4:	18051363          	bnez	a0,ffffffffc0200c6a <exception_handler+0x200>
}
ffffffffc0200ae8:	60e2                	ld	ra,24(sp)
ffffffffc0200aea:	6442                	ld	s0,16(sp)
ffffffffc0200aec:	64a2                	ld	s1,8(sp)
ffffffffc0200aee:	6105                	addi	sp,sp,32
ffffffffc0200af0:	8082                	ret
            cprintf("Load page fault\n");
ffffffffc0200af2:	00006517          	auipc	a0,0x6
ffffffffc0200af6:	20650513          	addi	a0,a0,518 # ffffffffc0206cf8 <commands+0x3d0>
ffffffffc0200afa:	e94ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200afe:	8522                	mv	a0,s0
ffffffffc0200b00:	dadff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200b04:	84aa                	mv	s1,a0
ffffffffc0200b06:	d16d                	beqz	a0,ffffffffc0200ae8 <exception_handler+0x7e>
                print_trapframe(tf);
ffffffffc0200b08:	8522                	mv	a0,s0
ffffffffc0200b0a:	d41ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b0e:	86a6                	mv	a3,s1
ffffffffc0200b10:	00006617          	auipc	a2,0x6
ffffffffc0200b14:	12060613          	addi	a2,a2,288 # ffffffffc0206c30 <commands+0x308>
ffffffffc0200b18:	0f600593          	li	a1,246
ffffffffc0200b1c:	00006517          	auipc	a0,0x6
ffffffffc0200b20:	2fc50513          	addi	a0,a0,764 # ffffffffc0206e18 <commands+0x4f0>
ffffffffc0200b24:	961ff0ef          	jal	ra,ffffffffc0200484 <__panic>
            cprintf("Store/AMO page fault\n");
ffffffffc0200b28:	00006517          	auipc	a0,0x6
ffffffffc0200b2c:	1e850513          	addi	a0,a0,488 # ffffffffc0206d10 <commands+0x3e8>
ffffffffc0200b30:	e5eff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b34:	8522                	mv	a0,s0
ffffffffc0200b36:	d77ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200b3a:	84aa                	mv	s1,a0
ffffffffc0200b3c:	d555                	beqz	a0,ffffffffc0200ae8 <exception_handler+0x7e>
                print_trapframe(tf);
ffffffffc0200b3e:	8522                	mv	a0,s0
ffffffffc0200b40:	d0bff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b44:	86a6                	mv	a3,s1
ffffffffc0200b46:	00006617          	auipc	a2,0x6
ffffffffc0200b4a:	0ea60613          	addi	a2,a2,234 # ffffffffc0206c30 <commands+0x308>
ffffffffc0200b4e:	0fd00593          	li	a1,253
ffffffffc0200b52:	00006517          	auipc	a0,0x6
ffffffffc0200b56:	2c650513          	addi	a0,a0,710 # ffffffffc0206e18 <commands+0x4f0>
ffffffffc0200b5a:	92bff0ef          	jal	ra,ffffffffc0200484 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b5e:	00006517          	auipc	a0,0x6
ffffffffc0200b62:	01a50513          	addi	a0,a0,26 # ffffffffc0206b78 <commands+0x250>
ffffffffc0200b66:	bf91                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b68:	00006517          	auipc	a0,0x6
ffffffffc0200b6c:	03050513          	addi	a0,a0,48 # ffffffffc0206b98 <commands+0x270>
ffffffffc0200b70:	b7a9                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b72:	00006517          	auipc	a0,0x6
ffffffffc0200b76:	04650513          	addi	a0,a0,70 # ffffffffc0206bb8 <commands+0x290>
ffffffffc0200b7a:	b781                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b7c:	00006517          	auipc	a0,0x6
ffffffffc0200b80:	05450513          	addi	a0,a0,84 # ffffffffc0206bd0 <commands+0x2a8>
ffffffffc0200b84:	e0aff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b88:	6458                	ld	a4,136(s0)
ffffffffc0200b8a:	47a9                	li	a5,10
ffffffffc0200b8c:	f4f71ee3          	bne	a4,a5,ffffffffc0200ae8 <exception_handler+0x7e>
                tf->epc += 4;
ffffffffc0200b90:	10843783          	ld	a5,264(s0)
                cprintf("activate syscall\n");
ffffffffc0200b94:	00006517          	auipc	a0,0x6
ffffffffc0200b98:	04c50513          	addi	a0,a0,76 # ffffffffc0206be0 <commands+0x2b8>
                tf->epc += 4;
ffffffffc0200b9c:	0791                	addi	a5,a5,4
ffffffffc0200b9e:	10f43423          	sd	a5,264(s0)
                cprintf("activate syscall\n");
ffffffffc0200ba2:	decff0ef          	jal	ra,ffffffffc020018e <cprintf>
                syscall();
ffffffffc0200ba6:	6f8050ef          	jal	ra,ffffffffc020629e <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200baa:	000ac797          	auipc	a5,0xac
ffffffffc0200bae:	98678793          	addi	a5,a5,-1658 # ffffffffc02ac530 <current>
ffffffffc0200bb2:	639c                	ld	a5,0(a5)
ffffffffc0200bb4:	8522                	mv	a0,s0
}
ffffffffc0200bb6:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200bb8:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200bba:	60e2                	ld	ra,24(sp)
ffffffffc0200bbc:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200bbe:	6589                	lui	a1,0x2
ffffffffc0200bc0:	95be                	add	a1,a1,a5
}
ffffffffc0200bc2:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200bc4:	2220006f          	j	ffffffffc0200de6 <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200bc8:	00006517          	auipc	a0,0x6
ffffffffc0200bcc:	03050513          	addi	a0,a0,48 # ffffffffc0206bf8 <commands+0x2d0>
ffffffffc0200bd0:	b5ed                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200bd2:	00006517          	auipc	a0,0x6
ffffffffc0200bd6:	04650513          	addi	a0,a0,70 # ffffffffc0206c18 <commands+0x2f0>
ffffffffc0200bda:	db4ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bde:	8522                	mv	a0,s0
ffffffffc0200be0:	ccdff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200be4:	84aa                	mv	s1,a0
ffffffffc0200be6:	f00501e3          	beqz	a0,ffffffffc0200ae8 <exception_handler+0x7e>
                print_trapframe(tf);
ffffffffc0200bea:	8522                	mv	a0,s0
ffffffffc0200bec:	c5fff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bf0:	86a6                	mv	a3,s1
ffffffffc0200bf2:	00006617          	auipc	a2,0x6
ffffffffc0200bf6:	03e60613          	addi	a2,a2,62 # ffffffffc0206c30 <commands+0x308>
ffffffffc0200bfa:	0ce00593          	li	a1,206
ffffffffc0200bfe:	00006517          	auipc	a0,0x6
ffffffffc0200c02:	21a50513          	addi	a0,a0,538 # ffffffffc0206e18 <commands+0x4f0>
ffffffffc0200c06:	87fff0ef          	jal	ra,ffffffffc0200484 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200c0a:	00006517          	auipc	a0,0x6
ffffffffc0200c0e:	05e50513          	addi	a0,a0,94 # ffffffffc0206c68 <commands+0x340>
ffffffffc0200c12:	d7cff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200c16:	8522                	mv	a0,s0
ffffffffc0200c18:	c95ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200c1c:	84aa                	mv	s1,a0
ffffffffc0200c1e:	ec0505e3          	beqz	a0,ffffffffc0200ae8 <exception_handler+0x7e>
                print_trapframe(tf);
ffffffffc0200c22:	8522                	mv	a0,s0
ffffffffc0200c24:	c27ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c28:	86a6                	mv	a3,s1
ffffffffc0200c2a:	00006617          	auipc	a2,0x6
ffffffffc0200c2e:	00660613          	addi	a2,a2,6 # ffffffffc0206c30 <commands+0x308>
ffffffffc0200c32:	0d800593          	li	a1,216
ffffffffc0200c36:	00006517          	auipc	a0,0x6
ffffffffc0200c3a:	1e250513          	addi	a0,a0,482 # ffffffffc0206e18 <commands+0x4f0>
ffffffffc0200c3e:	847ff0ef          	jal	ra,ffffffffc0200484 <__panic>
}
ffffffffc0200c42:	6442                	ld	s0,16(sp)
ffffffffc0200c44:	60e2                	ld	ra,24(sp)
ffffffffc0200c46:	64a2                	ld	s1,8(sp)
ffffffffc0200c48:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200c4a:	c01ff06f          	j	ffffffffc020084a <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200c4e:	00006617          	auipc	a2,0x6
ffffffffc0200c52:	00260613          	addi	a2,a2,2 # ffffffffc0206c50 <commands+0x328>
ffffffffc0200c56:	0d200593          	li	a1,210
ffffffffc0200c5a:	00006517          	auipc	a0,0x6
ffffffffc0200c5e:	1be50513          	addi	a0,a0,446 # ffffffffc0206e18 <commands+0x4f0>
ffffffffc0200c62:	823ff0ef          	jal	ra,ffffffffc0200484 <__panic>
            print_trapframe(tf);
ffffffffc0200c66:	be5ff06f          	j	ffffffffc020084a <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c6a:	8522                	mv	a0,s0
ffffffffc0200c6c:	bdfff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c70:	86a6                	mv	a3,s1
ffffffffc0200c72:	00006617          	auipc	a2,0x6
ffffffffc0200c76:	fbe60613          	addi	a2,a2,-66 # ffffffffc0206c30 <commands+0x308>
ffffffffc0200c7a:	0ef00593          	li	a1,239
ffffffffc0200c7e:	00006517          	auipc	a0,0x6
ffffffffc0200c82:	19a50513          	addi	a0,a0,410 # ffffffffc0206e18 <commands+0x4f0>
ffffffffc0200c86:	ffeff0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0200c8a <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c8a:	1101                	addi	sp,sp,-32
ffffffffc0200c8c:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c8e:	000ac417          	auipc	s0,0xac
ffffffffc0200c92:	8a240413          	addi	s0,s0,-1886 # ffffffffc02ac530 <current>
ffffffffc0200c96:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c98:	ec06                	sd	ra,24(sp)
ffffffffc0200c9a:	e426                	sd	s1,8(sp)
ffffffffc0200c9c:	e04a                	sd	s2,0(sp)
ffffffffc0200c9e:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200ca2:	cf1d                	beqz	a4,ffffffffc0200ce0 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200ca4:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200ca8:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200cac:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200cae:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200cb2:	0206c463          	bltz	a3,ffffffffc0200cda <trap+0x50>
        exception_handler(tf);
ffffffffc0200cb6:	db5ff0ef          	jal	ra,ffffffffc0200a6a <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200cba:	601c                	ld	a5,0(s0)
ffffffffc0200cbc:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200cc0:	e499                	bnez	s1,ffffffffc0200cce <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200cc2:	0b07a703          	lw	a4,176(a5)
ffffffffc0200cc6:	8b05                	andi	a4,a4,1
ffffffffc0200cc8:	e339                	bnez	a4,ffffffffc0200d0e <trap+0x84>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200cca:	6f9c                	ld	a5,24(a5)
ffffffffc0200ccc:	eb95                	bnez	a5,ffffffffc0200d00 <trap+0x76>
                schedule();
            }
        }
    }
}
ffffffffc0200cce:	60e2                	ld	ra,24(sp)
ffffffffc0200cd0:	6442                	ld	s0,16(sp)
ffffffffc0200cd2:	64a2                	ld	s1,8(sp)
ffffffffc0200cd4:	6902                	ld	s2,0(sp)
ffffffffc0200cd6:	6105                	addi	sp,sp,32
ffffffffc0200cd8:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200cda:	cf3ff0ef          	jal	ra,ffffffffc02009cc <interrupt_handler>
ffffffffc0200cde:	bff1                	j	ffffffffc0200cba <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200ce0:	0006c963          	bltz	a3,ffffffffc0200cf2 <trap+0x68>
}
ffffffffc0200ce4:	6442                	ld	s0,16(sp)
ffffffffc0200ce6:	60e2                	ld	ra,24(sp)
ffffffffc0200ce8:	64a2                	ld	s1,8(sp)
ffffffffc0200cea:	6902                	ld	s2,0(sp)
ffffffffc0200cec:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200cee:	d7dff06f          	j	ffffffffc0200a6a <exception_handler>
}
ffffffffc0200cf2:	6442                	ld	s0,16(sp)
ffffffffc0200cf4:	60e2                	ld	ra,24(sp)
ffffffffc0200cf6:	64a2                	ld	s1,8(sp)
ffffffffc0200cf8:	6902                	ld	s2,0(sp)
ffffffffc0200cfa:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200cfc:	cd1ff06f          	j	ffffffffc02009cc <interrupt_handler>
}
ffffffffc0200d00:	6442                	ld	s0,16(sp)
ffffffffc0200d02:	60e2                	ld	ra,24(sp)
ffffffffc0200d04:	64a2                	ld	s1,8(sp)
ffffffffc0200d06:	6902                	ld	s2,0(sp)
ffffffffc0200d08:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200d0a:	49e0506f          	j	ffffffffc02061a8 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200d0e:	555d                	li	a0,-9
ffffffffc0200d10:	097040ef          	jal	ra,ffffffffc02055a6 <do_exit>
ffffffffc0200d14:	601c                	ld	a5,0(s0)
ffffffffc0200d16:	bf55                	j	ffffffffc0200cca <trap+0x40>

ffffffffc0200d18 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200d18:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200d1c:	00011463          	bnez	sp,ffffffffc0200d24 <__alltraps+0xc>
ffffffffc0200d20:	14002173          	csrr	sp,sscratch
ffffffffc0200d24:	712d                	addi	sp,sp,-288
ffffffffc0200d26:	e002                	sd	zero,0(sp)
ffffffffc0200d28:	e406                	sd	ra,8(sp)
ffffffffc0200d2a:	ec0e                	sd	gp,24(sp)
ffffffffc0200d2c:	f012                	sd	tp,32(sp)
ffffffffc0200d2e:	f416                	sd	t0,40(sp)
ffffffffc0200d30:	f81a                	sd	t1,48(sp)
ffffffffc0200d32:	fc1e                	sd	t2,56(sp)
ffffffffc0200d34:	e0a2                	sd	s0,64(sp)
ffffffffc0200d36:	e4a6                	sd	s1,72(sp)
ffffffffc0200d38:	e8aa                	sd	a0,80(sp)
ffffffffc0200d3a:	ecae                	sd	a1,88(sp)
ffffffffc0200d3c:	f0b2                	sd	a2,96(sp)
ffffffffc0200d3e:	f4b6                	sd	a3,104(sp)
ffffffffc0200d40:	f8ba                	sd	a4,112(sp)
ffffffffc0200d42:	fcbe                	sd	a5,120(sp)
ffffffffc0200d44:	e142                	sd	a6,128(sp)
ffffffffc0200d46:	e546                	sd	a7,136(sp)
ffffffffc0200d48:	e94a                	sd	s2,144(sp)
ffffffffc0200d4a:	ed4e                	sd	s3,152(sp)
ffffffffc0200d4c:	f152                	sd	s4,160(sp)
ffffffffc0200d4e:	f556                	sd	s5,168(sp)
ffffffffc0200d50:	f95a                	sd	s6,176(sp)
ffffffffc0200d52:	fd5e                	sd	s7,184(sp)
ffffffffc0200d54:	e1e2                	sd	s8,192(sp)
ffffffffc0200d56:	e5e6                	sd	s9,200(sp)
ffffffffc0200d58:	e9ea                	sd	s10,208(sp)
ffffffffc0200d5a:	edee                	sd	s11,216(sp)
ffffffffc0200d5c:	f1f2                	sd	t3,224(sp)
ffffffffc0200d5e:	f5f6                	sd	t4,232(sp)
ffffffffc0200d60:	f9fa                	sd	t5,240(sp)
ffffffffc0200d62:	fdfe                	sd	t6,248(sp)
ffffffffc0200d64:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d68:	100024f3          	csrr	s1,sstatus
ffffffffc0200d6c:	14102973          	csrr	s2,sepc
ffffffffc0200d70:	143029f3          	csrr	s3,stval
ffffffffc0200d74:	14202a73          	csrr	s4,scause
ffffffffc0200d78:	e822                	sd	s0,16(sp)
ffffffffc0200d7a:	e226                	sd	s1,256(sp)
ffffffffc0200d7c:	e64a                	sd	s2,264(sp)
ffffffffc0200d7e:	ea4e                	sd	s3,272(sp)
ffffffffc0200d80:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d82:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d84:	f07ff0ef          	jal	ra,ffffffffc0200c8a <trap>

ffffffffc0200d88 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d88:	6492                	ld	s1,256(sp)
ffffffffc0200d8a:	6932                	ld	s2,264(sp)
ffffffffc0200d8c:	1004f413          	andi	s0,s1,256
ffffffffc0200d90:	e401                	bnez	s0,ffffffffc0200d98 <__trapret+0x10>
ffffffffc0200d92:	1200                	addi	s0,sp,288
ffffffffc0200d94:	14041073          	csrw	sscratch,s0
ffffffffc0200d98:	10049073          	csrw	sstatus,s1
ffffffffc0200d9c:	14191073          	csrw	sepc,s2
ffffffffc0200da0:	60a2                	ld	ra,8(sp)
ffffffffc0200da2:	61e2                	ld	gp,24(sp)
ffffffffc0200da4:	7202                	ld	tp,32(sp)
ffffffffc0200da6:	72a2                	ld	t0,40(sp)
ffffffffc0200da8:	7342                	ld	t1,48(sp)
ffffffffc0200daa:	73e2                	ld	t2,56(sp)
ffffffffc0200dac:	6406                	ld	s0,64(sp)
ffffffffc0200dae:	64a6                	ld	s1,72(sp)
ffffffffc0200db0:	6546                	ld	a0,80(sp)
ffffffffc0200db2:	65e6                	ld	a1,88(sp)
ffffffffc0200db4:	7606                	ld	a2,96(sp)
ffffffffc0200db6:	76a6                	ld	a3,104(sp)
ffffffffc0200db8:	7746                	ld	a4,112(sp)
ffffffffc0200dba:	77e6                	ld	a5,120(sp)
ffffffffc0200dbc:	680a                	ld	a6,128(sp)
ffffffffc0200dbe:	68aa                	ld	a7,136(sp)
ffffffffc0200dc0:	694a                	ld	s2,144(sp)
ffffffffc0200dc2:	69ea                	ld	s3,152(sp)
ffffffffc0200dc4:	7a0a                	ld	s4,160(sp)
ffffffffc0200dc6:	7aaa                	ld	s5,168(sp)
ffffffffc0200dc8:	7b4a                	ld	s6,176(sp)
ffffffffc0200dca:	7bea                	ld	s7,184(sp)
ffffffffc0200dcc:	6c0e                	ld	s8,192(sp)
ffffffffc0200dce:	6cae                	ld	s9,200(sp)
ffffffffc0200dd0:	6d4e                	ld	s10,208(sp)
ffffffffc0200dd2:	6dee                	ld	s11,216(sp)
ffffffffc0200dd4:	7e0e                	ld	t3,224(sp)
ffffffffc0200dd6:	7eae                	ld	t4,232(sp)
ffffffffc0200dd8:	7f4e                	ld	t5,240(sp)
ffffffffc0200dda:	7fee                	ld	t6,248(sp)
ffffffffc0200ddc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200dde:	10200073          	sret

ffffffffc0200de2 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200de2:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200de4:	b755                	j	ffffffffc0200d88 <__trapret>

ffffffffc0200de6 <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200de6:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7698>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200dea:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200dee:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200df2:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200df6:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200dfa:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200dfe:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200e02:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200e06:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200e0a:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200e0c:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200e0e:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200e10:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200e12:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200e14:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200e16:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200e18:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200e1a:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200e1c:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200e1e:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200e20:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200e22:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200e24:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200e26:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200e28:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200e2a:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200e2c:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200e2e:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200e30:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200e32:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200e34:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200e36:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200e38:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200e3a:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200e3c:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200e3e:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200e40:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200e42:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200e44:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200e46:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200e48:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200e4a:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200e4c:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200e4e:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200e50:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200e52:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200e54:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200e56:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200e58:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200e5a:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e5c:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e5e:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e60:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e62:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e64:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e66:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e68:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e6a:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e6c:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e6e:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e70:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e72:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e74:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e76:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e78:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e7a:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e7c:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e7e:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e80:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e82:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e84:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e86:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e88:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e8a:	812e                	mv	sp,a1
ffffffffc0200e8c:	bdf5                	j	ffffffffc0200d88 <__trapret>

ffffffffc0200e8e <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e8e:	000ab797          	auipc	a5,0xab
ffffffffc0200e92:	6ca78793          	addi	a5,a5,1738 # ffffffffc02ac558 <free_area>
ffffffffc0200e96:	e79c                	sd	a5,8(a5)
ffffffffc0200e98:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e9a:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e9e:	8082                	ret

ffffffffc0200ea0 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200ea0:	000ab517          	auipc	a0,0xab
ffffffffc0200ea4:	6c856503          	lwu	a0,1736(a0) # ffffffffc02ac568 <free_area+0x10>
ffffffffc0200ea8:	8082                	ret

ffffffffc0200eaa <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200eaa:	715d                	addi	sp,sp,-80
ffffffffc0200eac:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200eae:	000ab917          	auipc	s2,0xab
ffffffffc0200eb2:	6aa90913          	addi	s2,s2,1706 # ffffffffc02ac558 <free_area>
ffffffffc0200eb6:	00893783          	ld	a5,8(s2)
ffffffffc0200eba:	e486                	sd	ra,72(sp)
ffffffffc0200ebc:	e0a2                	sd	s0,64(sp)
ffffffffc0200ebe:	fc26                	sd	s1,56(sp)
ffffffffc0200ec0:	f44e                	sd	s3,40(sp)
ffffffffc0200ec2:	f052                	sd	s4,32(sp)
ffffffffc0200ec4:	ec56                	sd	s5,24(sp)
ffffffffc0200ec6:	e85a                	sd	s6,16(sp)
ffffffffc0200ec8:	e45e                	sd	s7,8(sp)
ffffffffc0200eca:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ecc:	31278463          	beq	a5,s2,ffffffffc02011d4 <default_check+0x32a>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200ed0:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200ed4:	8305                	srli	a4,a4,0x1
ffffffffc0200ed6:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200ed8:	30070263          	beqz	a4,ffffffffc02011dc <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0200edc:	4401                	li	s0,0
ffffffffc0200ede:	4481                	li	s1,0
ffffffffc0200ee0:	a031                	j	ffffffffc0200eec <default_check+0x42>
ffffffffc0200ee2:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200ee6:	8b09                	andi	a4,a4,2
ffffffffc0200ee8:	2e070a63          	beqz	a4,ffffffffc02011dc <default_check+0x332>
        count ++, total += p->property;
ffffffffc0200eec:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ef0:	679c                	ld	a5,8(a5)
ffffffffc0200ef2:	2485                	addiw	s1,s1,1
ffffffffc0200ef4:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ef6:	ff2796e3          	bne	a5,s2,ffffffffc0200ee2 <default_check+0x38>
ffffffffc0200efa:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200efc:	05c010ef          	jal	ra,ffffffffc0201f58 <nr_free_pages>
ffffffffc0200f00:	73351e63          	bne	a0,s3,ffffffffc020163c <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f04:	4505                	li	a0,1
ffffffffc0200f06:	785000ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc0200f0a:	8a2a                	mv	s4,a0
ffffffffc0200f0c:	46050863          	beqz	a0,ffffffffc020137c <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f10:	4505                	li	a0,1
ffffffffc0200f12:	779000ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc0200f16:	89aa                	mv	s3,a0
ffffffffc0200f18:	74050263          	beqz	a0,ffffffffc020165c <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f1c:	4505                	li	a0,1
ffffffffc0200f1e:	76d000ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc0200f22:	8aaa                	mv	s5,a0
ffffffffc0200f24:	4c050c63          	beqz	a0,ffffffffc02013fc <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200f28:	2d3a0a63          	beq	s4,s3,ffffffffc02011fc <default_check+0x352>
ffffffffc0200f2c:	2caa0863          	beq	s4,a0,ffffffffc02011fc <default_check+0x352>
ffffffffc0200f30:	2ca98663          	beq	s3,a0,ffffffffc02011fc <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200f34:	000a2783          	lw	a5,0(s4)
ffffffffc0200f38:	2e079263          	bnez	a5,ffffffffc020121c <default_check+0x372>
ffffffffc0200f3c:	0009a783          	lw	a5,0(s3)
ffffffffc0200f40:	2c079e63          	bnez	a5,ffffffffc020121c <default_check+0x372>
ffffffffc0200f44:	411c                	lw	a5,0(a0)
ffffffffc0200f46:	2c079b63          	bnez	a5,ffffffffc020121c <default_check+0x372>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200f4a:	000ab797          	auipc	a5,0xab
ffffffffc0200f4e:	63e78793          	addi	a5,a5,1598 # ffffffffc02ac588 <pages>
ffffffffc0200f52:	639c                	ld	a5,0(a5)
ffffffffc0200f54:	00008717          	auipc	a4,0x8
ffffffffc0200f58:	02470713          	addi	a4,a4,36 # ffffffffc0208f78 <nbase>
ffffffffc0200f5c:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f5e:	000ab717          	auipc	a4,0xab
ffffffffc0200f62:	5ba70713          	addi	a4,a4,1466 # ffffffffc02ac518 <npage>
ffffffffc0200f66:	6314                	ld	a3,0(a4)
ffffffffc0200f68:	40fa0733          	sub	a4,s4,a5
ffffffffc0200f6c:	8719                	srai	a4,a4,0x6
ffffffffc0200f6e:	9732                	add	a4,a4,a2
ffffffffc0200f70:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f72:	0732                	slli	a4,a4,0xc
ffffffffc0200f74:	2cd77463          	bleu	a3,a4,ffffffffc020123c <default_check+0x392>
    return page - pages + nbase;
ffffffffc0200f78:	40f98733          	sub	a4,s3,a5
ffffffffc0200f7c:	8719                	srai	a4,a4,0x6
ffffffffc0200f7e:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f80:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200f82:	4ed77d63          	bleu	a3,a4,ffffffffc020147c <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0200f86:	40f507b3          	sub	a5,a0,a5
ffffffffc0200f8a:	8799                	srai	a5,a5,0x6
ffffffffc0200f8c:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f8e:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f90:	34d7f663          	bleu	a3,a5,ffffffffc02012dc <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0200f94:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200f96:	00093c03          	ld	s8,0(s2)
ffffffffc0200f9a:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200f9e:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200fa2:	000ab797          	auipc	a5,0xab
ffffffffc0200fa6:	5b27bf23          	sd	s2,1470(a5) # ffffffffc02ac560 <free_area+0x8>
ffffffffc0200faa:	000ab797          	auipc	a5,0xab
ffffffffc0200fae:	5b27b723          	sd	s2,1454(a5) # ffffffffc02ac558 <free_area>
    nr_free = 0;
ffffffffc0200fb2:	000ab797          	auipc	a5,0xab
ffffffffc0200fb6:	5a07ab23          	sw	zero,1462(a5) # ffffffffc02ac568 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200fba:	6d1000ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc0200fbe:	2e051f63          	bnez	a0,ffffffffc02012bc <default_check+0x412>
    free_page(p0);
ffffffffc0200fc2:	4585                	li	a1,1
ffffffffc0200fc4:	8552                	mv	a0,s4
ffffffffc0200fc6:	74d000ef          	jal	ra,ffffffffc0201f12 <free_pages>
    free_page(p1);
ffffffffc0200fca:	4585                	li	a1,1
ffffffffc0200fcc:	854e                	mv	a0,s3
ffffffffc0200fce:	745000ef          	jal	ra,ffffffffc0201f12 <free_pages>
    free_page(p2);
ffffffffc0200fd2:	4585                	li	a1,1
ffffffffc0200fd4:	8556                	mv	a0,s5
ffffffffc0200fd6:	73d000ef          	jal	ra,ffffffffc0201f12 <free_pages>
    assert(nr_free == 3);
ffffffffc0200fda:	01092703          	lw	a4,16(s2)
ffffffffc0200fde:	478d                	li	a5,3
ffffffffc0200fe0:	2af71e63          	bne	a4,a5,ffffffffc020129c <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200fe4:	4505                	li	a0,1
ffffffffc0200fe6:	6a5000ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc0200fea:	89aa                	mv	s3,a0
ffffffffc0200fec:	28050863          	beqz	a0,ffffffffc020127c <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ff0:	4505                	li	a0,1
ffffffffc0200ff2:	699000ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc0200ff6:	8aaa                	mv	s5,a0
ffffffffc0200ff8:	3e050263          	beqz	a0,ffffffffc02013dc <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ffc:	4505                	li	a0,1
ffffffffc0200ffe:	68d000ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc0201002:	8a2a                	mv	s4,a0
ffffffffc0201004:	3a050c63          	beqz	a0,ffffffffc02013bc <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0201008:	4505                	li	a0,1
ffffffffc020100a:	681000ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc020100e:	38051763          	bnez	a0,ffffffffc020139c <default_check+0x4f2>
    free_page(p0);
ffffffffc0201012:	4585                	li	a1,1
ffffffffc0201014:	854e                	mv	a0,s3
ffffffffc0201016:	6fd000ef          	jal	ra,ffffffffc0201f12 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc020101a:	00893783          	ld	a5,8(s2)
ffffffffc020101e:	23278f63          	beq	a5,s2,ffffffffc020125c <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0201022:	4505                	li	a0,1
ffffffffc0201024:	667000ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc0201028:	32a99a63          	bne	s3,a0,ffffffffc020135c <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc020102c:	4505                	li	a0,1
ffffffffc020102e:	65d000ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc0201032:	30051563          	bnez	a0,ffffffffc020133c <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0201036:	01092783          	lw	a5,16(s2)
ffffffffc020103a:	2e079163          	bnez	a5,ffffffffc020131c <default_check+0x472>
    free_page(p);
ffffffffc020103e:	854e                	mv	a0,s3
ffffffffc0201040:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201042:	000ab797          	auipc	a5,0xab
ffffffffc0201046:	5187bb23          	sd	s8,1302(a5) # ffffffffc02ac558 <free_area>
ffffffffc020104a:	000ab797          	auipc	a5,0xab
ffffffffc020104e:	5177bb23          	sd	s7,1302(a5) # ffffffffc02ac560 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0201052:	000ab797          	auipc	a5,0xab
ffffffffc0201056:	5167ab23          	sw	s6,1302(a5) # ffffffffc02ac568 <free_area+0x10>
    free_page(p);
ffffffffc020105a:	6b9000ef          	jal	ra,ffffffffc0201f12 <free_pages>
    free_page(p1);
ffffffffc020105e:	4585                	li	a1,1
ffffffffc0201060:	8556                	mv	a0,s5
ffffffffc0201062:	6b1000ef          	jal	ra,ffffffffc0201f12 <free_pages>
    free_page(p2);
ffffffffc0201066:	4585                	li	a1,1
ffffffffc0201068:	8552                	mv	a0,s4
ffffffffc020106a:	6a9000ef          	jal	ra,ffffffffc0201f12 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc020106e:	4515                	li	a0,5
ffffffffc0201070:	61b000ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc0201074:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201076:	28050363          	beqz	a0,ffffffffc02012fc <default_check+0x452>
ffffffffc020107a:	651c                	ld	a5,8(a0)
ffffffffc020107c:	8385                	srli	a5,a5,0x1
ffffffffc020107e:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0201080:	54079e63          	bnez	a5,ffffffffc02015dc <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201084:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201086:	00093b03          	ld	s6,0(s2)
ffffffffc020108a:	00893a83          	ld	s5,8(s2)
ffffffffc020108e:	000ab797          	auipc	a5,0xab
ffffffffc0201092:	4d27b523          	sd	s2,1226(a5) # ffffffffc02ac558 <free_area>
ffffffffc0201096:	000ab797          	auipc	a5,0xab
ffffffffc020109a:	4d27b523          	sd	s2,1226(a5) # ffffffffc02ac560 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc020109e:	5ed000ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc02010a2:	50051d63          	bnez	a0,ffffffffc02015bc <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02010a6:	08098a13          	addi	s4,s3,128
ffffffffc02010aa:	8552                	mv	a0,s4
ffffffffc02010ac:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02010ae:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc02010b2:	000ab797          	auipc	a5,0xab
ffffffffc02010b6:	4a07ab23          	sw	zero,1206(a5) # ffffffffc02ac568 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02010ba:	659000ef          	jal	ra,ffffffffc0201f12 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02010be:	4511                	li	a0,4
ffffffffc02010c0:	5cb000ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc02010c4:	4c051c63          	bnez	a0,ffffffffc020159c <default_check+0x6f2>
ffffffffc02010c8:	0889b783          	ld	a5,136(s3)
ffffffffc02010cc:	8385                	srli	a5,a5,0x1
ffffffffc02010ce:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02010d0:	4a078663          	beqz	a5,ffffffffc020157c <default_check+0x6d2>
ffffffffc02010d4:	0909a703          	lw	a4,144(s3)
ffffffffc02010d8:	478d                	li	a5,3
ffffffffc02010da:	4af71163          	bne	a4,a5,ffffffffc020157c <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02010de:	450d                	li	a0,3
ffffffffc02010e0:	5ab000ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc02010e4:	8c2a                	mv	s8,a0
ffffffffc02010e6:	46050b63          	beqz	a0,ffffffffc020155c <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc02010ea:	4505                	li	a0,1
ffffffffc02010ec:	59f000ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc02010f0:	44051663          	bnez	a0,ffffffffc020153c <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc02010f4:	438a1463          	bne	s4,s8,ffffffffc020151c <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02010f8:	4585                	li	a1,1
ffffffffc02010fa:	854e                	mv	a0,s3
ffffffffc02010fc:	617000ef          	jal	ra,ffffffffc0201f12 <free_pages>
    free_pages(p1, 3);
ffffffffc0201100:	458d                	li	a1,3
ffffffffc0201102:	8552                	mv	a0,s4
ffffffffc0201104:	60f000ef          	jal	ra,ffffffffc0201f12 <free_pages>
ffffffffc0201108:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc020110c:	04098c13          	addi	s8,s3,64
ffffffffc0201110:	8385                	srli	a5,a5,0x1
ffffffffc0201112:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201114:	3e078463          	beqz	a5,ffffffffc02014fc <default_check+0x652>
ffffffffc0201118:	0109a703          	lw	a4,16(s3)
ffffffffc020111c:	4785                	li	a5,1
ffffffffc020111e:	3cf71f63          	bne	a4,a5,ffffffffc02014fc <default_check+0x652>
ffffffffc0201122:	008a3783          	ld	a5,8(s4)
ffffffffc0201126:	8385                	srli	a5,a5,0x1
ffffffffc0201128:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020112a:	3a078963          	beqz	a5,ffffffffc02014dc <default_check+0x632>
ffffffffc020112e:	010a2703          	lw	a4,16(s4)
ffffffffc0201132:	478d                	li	a5,3
ffffffffc0201134:	3af71463          	bne	a4,a5,ffffffffc02014dc <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201138:	4505                	li	a0,1
ffffffffc020113a:	551000ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc020113e:	36a99f63          	bne	s3,a0,ffffffffc02014bc <default_check+0x612>
    free_page(p0);
ffffffffc0201142:	4585                	li	a1,1
ffffffffc0201144:	5cf000ef          	jal	ra,ffffffffc0201f12 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201148:	4509                	li	a0,2
ffffffffc020114a:	541000ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc020114e:	34aa1763          	bne	s4,a0,ffffffffc020149c <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc0201152:	4589                	li	a1,2
ffffffffc0201154:	5bf000ef          	jal	ra,ffffffffc0201f12 <free_pages>
    free_page(p2);
ffffffffc0201158:	4585                	li	a1,1
ffffffffc020115a:	8562                	mv	a0,s8
ffffffffc020115c:	5b7000ef          	jal	ra,ffffffffc0201f12 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201160:	4515                	li	a0,5
ffffffffc0201162:	529000ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc0201166:	89aa                	mv	s3,a0
ffffffffc0201168:	48050a63          	beqz	a0,ffffffffc02015fc <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc020116c:	4505                	li	a0,1
ffffffffc020116e:	51d000ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc0201172:	2e051563          	bnez	a0,ffffffffc020145c <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc0201176:	01092783          	lw	a5,16(s2)
ffffffffc020117a:	2c079163          	bnez	a5,ffffffffc020143c <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc020117e:	4595                	li	a1,5
ffffffffc0201180:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0201182:	000ab797          	auipc	a5,0xab
ffffffffc0201186:	3f77a323          	sw	s7,998(a5) # ffffffffc02ac568 <free_area+0x10>
    free_list = free_list_store;
ffffffffc020118a:	000ab797          	auipc	a5,0xab
ffffffffc020118e:	3d67b723          	sd	s6,974(a5) # ffffffffc02ac558 <free_area>
ffffffffc0201192:	000ab797          	auipc	a5,0xab
ffffffffc0201196:	3d57b723          	sd	s5,974(a5) # ffffffffc02ac560 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc020119a:	579000ef          	jal	ra,ffffffffc0201f12 <free_pages>
    return listelm->next;
ffffffffc020119e:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02011a2:	01278963          	beq	a5,s2,ffffffffc02011b4 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02011a6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02011aa:	679c                	ld	a5,8(a5)
ffffffffc02011ac:	34fd                	addiw	s1,s1,-1
ffffffffc02011ae:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02011b0:	ff279be3          	bne	a5,s2,ffffffffc02011a6 <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc02011b4:	26049463          	bnez	s1,ffffffffc020141c <default_check+0x572>
    assert(total == 0);
ffffffffc02011b8:	46041263          	bnez	s0,ffffffffc020161c <default_check+0x772>
}
ffffffffc02011bc:	60a6                	ld	ra,72(sp)
ffffffffc02011be:	6406                	ld	s0,64(sp)
ffffffffc02011c0:	74e2                	ld	s1,56(sp)
ffffffffc02011c2:	7942                	ld	s2,48(sp)
ffffffffc02011c4:	79a2                	ld	s3,40(sp)
ffffffffc02011c6:	7a02                	ld	s4,32(sp)
ffffffffc02011c8:	6ae2                	ld	s5,24(sp)
ffffffffc02011ca:	6b42                	ld	s6,16(sp)
ffffffffc02011cc:	6ba2                	ld	s7,8(sp)
ffffffffc02011ce:	6c02                	ld	s8,0(sp)
ffffffffc02011d0:	6161                	addi	sp,sp,80
ffffffffc02011d2:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02011d4:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02011d6:	4401                	li	s0,0
ffffffffc02011d8:	4481                	li	s1,0
ffffffffc02011da:	b30d                	j	ffffffffc0200efc <default_check+0x52>
        assert(PageProperty(p));
ffffffffc02011dc:	00006697          	auipc	a3,0x6
ffffffffc02011e0:	fdc68693          	addi	a3,a3,-36 # ffffffffc02071b8 <commands+0x890>
ffffffffc02011e4:	00006617          	auipc	a2,0x6
ffffffffc02011e8:	c1c60613          	addi	a2,a2,-996 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02011ec:	0f000593          	li	a1,240
ffffffffc02011f0:	00006517          	auipc	a0,0x6
ffffffffc02011f4:	fd850513          	addi	a0,a0,-40 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc02011f8:	a8cff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02011fc:	00006697          	auipc	a3,0x6
ffffffffc0201200:	06468693          	addi	a3,a3,100 # ffffffffc0207260 <commands+0x938>
ffffffffc0201204:	00006617          	auipc	a2,0x6
ffffffffc0201208:	bfc60613          	addi	a2,a2,-1028 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020120c:	0bd00593          	li	a1,189
ffffffffc0201210:	00006517          	auipc	a0,0x6
ffffffffc0201214:	fb850513          	addi	a0,a0,-72 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201218:	a6cff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020121c:	00006697          	auipc	a3,0x6
ffffffffc0201220:	06c68693          	addi	a3,a3,108 # ffffffffc0207288 <commands+0x960>
ffffffffc0201224:	00006617          	auipc	a2,0x6
ffffffffc0201228:	bdc60613          	addi	a2,a2,-1060 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020122c:	0be00593          	li	a1,190
ffffffffc0201230:	00006517          	auipc	a0,0x6
ffffffffc0201234:	f9850513          	addi	a0,a0,-104 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201238:	a4cff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020123c:	00006697          	auipc	a3,0x6
ffffffffc0201240:	08c68693          	addi	a3,a3,140 # ffffffffc02072c8 <commands+0x9a0>
ffffffffc0201244:	00006617          	auipc	a2,0x6
ffffffffc0201248:	bbc60613          	addi	a2,a2,-1092 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020124c:	0c000593          	li	a1,192
ffffffffc0201250:	00006517          	auipc	a0,0x6
ffffffffc0201254:	f7850513          	addi	a0,a0,-136 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201258:	a2cff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(!list_empty(&free_list));
ffffffffc020125c:	00006697          	auipc	a3,0x6
ffffffffc0201260:	0f468693          	addi	a3,a3,244 # ffffffffc0207350 <commands+0xa28>
ffffffffc0201264:	00006617          	auipc	a2,0x6
ffffffffc0201268:	b9c60613          	addi	a2,a2,-1124 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020126c:	0d900593          	li	a1,217
ffffffffc0201270:	00006517          	auipc	a0,0x6
ffffffffc0201274:	f5850513          	addi	a0,a0,-168 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201278:	a0cff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020127c:	00006697          	auipc	a3,0x6
ffffffffc0201280:	f8468693          	addi	a3,a3,-124 # ffffffffc0207200 <commands+0x8d8>
ffffffffc0201284:	00006617          	auipc	a2,0x6
ffffffffc0201288:	b7c60613          	addi	a2,a2,-1156 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020128c:	0d200593          	li	a1,210
ffffffffc0201290:	00006517          	auipc	a0,0x6
ffffffffc0201294:	f3850513          	addi	a0,a0,-200 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201298:	9ecff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free == 3);
ffffffffc020129c:	00006697          	auipc	a3,0x6
ffffffffc02012a0:	0a468693          	addi	a3,a3,164 # ffffffffc0207340 <commands+0xa18>
ffffffffc02012a4:	00006617          	auipc	a2,0x6
ffffffffc02012a8:	b5c60613          	addi	a2,a2,-1188 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02012ac:	0d000593          	li	a1,208
ffffffffc02012b0:	00006517          	auipc	a0,0x6
ffffffffc02012b4:	f1850513          	addi	a0,a0,-232 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc02012b8:	9ccff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012bc:	00006697          	auipc	a3,0x6
ffffffffc02012c0:	06c68693          	addi	a3,a3,108 # ffffffffc0207328 <commands+0xa00>
ffffffffc02012c4:	00006617          	auipc	a2,0x6
ffffffffc02012c8:	b3c60613          	addi	a2,a2,-1220 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02012cc:	0cb00593          	li	a1,203
ffffffffc02012d0:	00006517          	auipc	a0,0x6
ffffffffc02012d4:	ef850513          	addi	a0,a0,-264 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc02012d8:	9acff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02012dc:	00006697          	auipc	a3,0x6
ffffffffc02012e0:	02c68693          	addi	a3,a3,44 # ffffffffc0207308 <commands+0x9e0>
ffffffffc02012e4:	00006617          	auipc	a2,0x6
ffffffffc02012e8:	b1c60613          	addi	a2,a2,-1252 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02012ec:	0c200593          	li	a1,194
ffffffffc02012f0:	00006517          	auipc	a0,0x6
ffffffffc02012f4:	ed850513          	addi	a0,a0,-296 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc02012f8:	98cff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(p0 != NULL);
ffffffffc02012fc:	00006697          	auipc	a3,0x6
ffffffffc0201300:	09c68693          	addi	a3,a3,156 # ffffffffc0207398 <commands+0xa70>
ffffffffc0201304:	00006617          	auipc	a2,0x6
ffffffffc0201308:	afc60613          	addi	a2,a2,-1284 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020130c:	0f800593          	li	a1,248
ffffffffc0201310:	00006517          	auipc	a0,0x6
ffffffffc0201314:	eb850513          	addi	a0,a0,-328 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201318:	96cff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free == 0);
ffffffffc020131c:	00006697          	auipc	a3,0x6
ffffffffc0201320:	06c68693          	addi	a3,a3,108 # ffffffffc0207388 <commands+0xa60>
ffffffffc0201324:	00006617          	auipc	a2,0x6
ffffffffc0201328:	adc60613          	addi	a2,a2,-1316 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020132c:	0df00593          	li	a1,223
ffffffffc0201330:	00006517          	auipc	a0,0x6
ffffffffc0201334:	e9850513          	addi	a0,a0,-360 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201338:	94cff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020133c:	00006697          	auipc	a3,0x6
ffffffffc0201340:	fec68693          	addi	a3,a3,-20 # ffffffffc0207328 <commands+0xa00>
ffffffffc0201344:	00006617          	auipc	a2,0x6
ffffffffc0201348:	abc60613          	addi	a2,a2,-1348 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020134c:	0dd00593          	li	a1,221
ffffffffc0201350:	00006517          	auipc	a0,0x6
ffffffffc0201354:	e7850513          	addi	a0,a0,-392 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201358:	92cff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020135c:	00006697          	auipc	a3,0x6
ffffffffc0201360:	00c68693          	addi	a3,a3,12 # ffffffffc0207368 <commands+0xa40>
ffffffffc0201364:	00006617          	auipc	a2,0x6
ffffffffc0201368:	a9c60613          	addi	a2,a2,-1380 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020136c:	0dc00593          	li	a1,220
ffffffffc0201370:	00006517          	auipc	a0,0x6
ffffffffc0201374:	e5850513          	addi	a0,a0,-424 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201378:	90cff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020137c:	00006697          	auipc	a3,0x6
ffffffffc0201380:	e8468693          	addi	a3,a3,-380 # ffffffffc0207200 <commands+0x8d8>
ffffffffc0201384:	00006617          	auipc	a2,0x6
ffffffffc0201388:	a7c60613          	addi	a2,a2,-1412 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020138c:	0b900593          	li	a1,185
ffffffffc0201390:	00006517          	auipc	a0,0x6
ffffffffc0201394:	e3850513          	addi	a0,a0,-456 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201398:	8ecff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020139c:	00006697          	auipc	a3,0x6
ffffffffc02013a0:	f8c68693          	addi	a3,a3,-116 # ffffffffc0207328 <commands+0xa00>
ffffffffc02013a4:	00006617          	auipc	a2,0x6
ffffffffc02013a8:	a5c60613          	addi	a2,a2,-1444 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02013ac:	0d600593          	li	a1,214
ffffffffc02013b0:	00006517          	auipc	a0,0x6
ffffffffc02013b4:	e1850513          	addi	a0,a0,-488 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc02013b8:	8ccff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02013bc:	00006697          	auipc	a3,0x6
ffffffffc02013c0:	e8468693          	addi	a3,a3,-380 # ffffffffc0207240 <commands+0x918>
ffffffffc02013c4:	00006617          	auipc	a2,0x6
ffffffffc02013c8:	a3c60613          	addi	a2,a2,-1476 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02013cc:	0d400593          	li	a1,212
ffffffffc02013d0:	00006517          	auipc	a0,0x6
ffffffffc02013d4:	df850513          	addi	a0,a0,-520 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc02013d8:	8acff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02013dc:	00006697          	auipc	a3,0x6
ffffffffc02013e0:	e4468693          	addi	a3,a3,-444 # ffffffffc0207220 <commands+0x8f8>
ffffffffc02013e4:	00006617          	auipc	a2,0x6
ffffffffc02013e8:	a1c60613          	addi	a2,a2,-1508 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02013ec:	0d300593          	li	a1,211
ffffffffc02013f0:	00006517          	auipc	a0,0x6
ffffffffc02013f4:	dd850513          	addi	a0,a0,-552 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc02013f8:	88cff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02013fc:	00006697          	auipc	a3,0x6
ffffffffc0201400:	e4468693          	addi	a3,a3,-444 # ffffffffc0207240 <commands+0x918>
ffffffffc0201404:	00006617          	auipc	a2,0x6
ffffffffc0201408:	9fc60613          	addi	a2,a2,-1540 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020140c:	0bb00593          	li	a1,187
ffffffffc0201410:	00006517          	auipc	a0,0x6
ffffffffc0201414:	db850513          	addi	a0,a0,-584 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201418:	86cff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(count == 0);
ffffffffc020141c:	00006697          	auipc	a3,0x6
ffffffffc0201420:	0cc68693          	addi	a3,a3,204 # ffffffffc02074e8 <commands+0xbc0>
ffffffffc0201424:	00006617          	auipc	a2,0x6
ffffffffc0201428:	9dc60613          	addi	a2,a2,-1572 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020142c:	12500593          	li	a1,293
ffffffffc0201430:	00006517          	auipc	a0,0x6
ffffffffc0201434:	d9850513          	addi	a0,a0,-616 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201438:	84cff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free == 0);
ffffffffc020143c:	00006697          	auipc	a3,0x6
ffffffffc0201440:	f4c68693          	addi	a3,a3,-180 # ffffffffc0207388 <commands+0xa60>
ffffffffc0201444:	00006617          	auipc	a2,0x6
ffffffffc0201448:	9bc60613          	addi	a2,a2,-1604 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020144c:	11a00593          	li	a1,282
ffffffffc0201450:	00006517          	auipc	a0,0x6
ffffffffc0201454:	d7850513          	addi	a0,a0,-648 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201458:	82cff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020145c:	00006697          	auipc	a3,0x6
ffffffffc0201460:	ecc68693          	addi	a3,a3,-308 # ffffffffc0207328 <commands+0xa00>
ffffffffc0201464:	00006617          	auipc	a2,0x6
ffffffffc0201468:	99c60613          	addi	a2,a2,-1636 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020146c:	11800593          	li	a1,280
ffffffffc0201470:	00006517          	auipc	a0,0x6
ffffffffc0201474:	d5850513          	addi	a0,a0,-680 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201478:	80cff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020147c:	00006697          	auipc	a3,0x6
ffffffffc0201480:	e6c68693          	addi	a3,a3,-404 # ffffffffc02072e8 <commands+0x9c0>
ffffffffc0201484:	00006617          	auipc	a2,0x6
ffffffffc0201488:	97c60613          	addi	a2,a2,-1668 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020148c:	0c100593          	li	a1,193
ffffffffc0201490:	00006517          	auipc	a0,0x6
ffffffffc0201494:	d3850513          	addi	a0,a0,-712 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201498:	fedfe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020149c:	00006697          	auipc	a3,0x6
ffffffffc02014a0:	00c68693          	addi	a3,a3,12 # ffffffffc02074a8 <commands+0xb80>
ffffffffc02014a4:	00006617          	auipc	a2,0x6
ffffffffc02014a8:	95c60613          	addi	a2,a2,-1700 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02014ac:	11200593          	li	a1,274
ffffffffc02014b0:	00006517          	auipc	a0,0x6
ffffffffc02014b4:	d1850513          	addi	a0,a0,-744 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc02014b8:	fcdfe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02014bc:	00006697          	auipc	a3,0x6
ffffffffc02014c0:	fcc68693          	addi	a3,a3,-52 # ffffffffc0207488 <commands+0xb60>
ffffffffc02014c4:	00006617          	auipc	a2,0x6
ffffffffc02014c8:	93c60613          	addi	a2,a2,-1732 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02014cc:	11000593          	li	a1,272
ffffffffc02014d0:	00006517          	auipc	a0,0x6
ffffffffc02014d4:	cf850513          	addi	a0,a0,-776 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc02014d8:	fadfe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02014dc:	00006697          	auipc	a3,0x6
ffffffffc02014e0:	f8468693          	addi	a3,a3,-124 # ffffffffc0207460 <commands+0xb38>
ffffffffc02014e4:	00006617          	auipc	a2,0x6
ffffffffc02014e8:	91c60613          	addi	a2,a2,-1764 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02014ec:	10e00593          	li	a1,270
ffffffffc02014f0:	00006517          	auipc	a0,0x6
ffffffffc02014f4:	cd850513          	addi	a0,a0,-808 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc02014f8:	f8dfe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02014fc:	00006697          	auipc	a3,0x6
ffffffffc0201500:	f3c68693          	addi	a3,a3,-196 # ffffffffc0207438 <commands+0xb10>
ffffffffc0201504:	00006617          	auipc	a2,0x6
ffffffffc0201508:	8fc60613          	addi	a2,a2,-1796 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020150c:	10d00593          	li	a1,269
ffffffffc0201510:	00006517          	auipc	a0,0x6
ffffffffc0201514:	cb850513          	addi	a0,a0,-840 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201518:	f6dfe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(p0 + 2 == p1);
ffffffffc020151c:	00006697          	auipc	a3,0x6
ffffffffc0201520:	f0c68693          	addi	a3,a3,-244 # ffffffffc0207428 <commands+0xb00>
ffffffffc0201524:	00006617          	auipc	a2,0x6
ffffffffc0201528:	8dc60613          	addi	a2,a2,-1828 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020152c:	10800593          	li	a1,264
ffffffffc0201530:	00006517          	auipc	a0,0x6
ffffffffc0201534:	c9850513          	addi	a0,a0,-872 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201538:	f4dfe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020153c:	00006697          	auipc	a3,0x6
ffffffffc0201540:	dec68693          	addi	a3,a3,-532 # ffffffffc0207328 <commands+0xa00>
ffffffffc0201544:	00006617          	auipc	a2,0x6
ffffffffc0201548:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020154c:	10700593          	li	a1,263
ffffffffc0201550:	00006517          	auipc	a0,0x6
ffffffffc0201554:	c7850513          	addi	a0,a0,-904 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201558:	f2dfe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020155c:	00006697          	auipc	a3,0x6
ffffffffc0201560:	eac68693          	addi	a3,a3,-340 # ffffffffc0207408 <commands+0xae0>
ffffffffc0201564:	00006617          	auipc	a2,0x6
ffffffffc0201568:	89c60613          	addi	a2,a2,-1892 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020156c:	10600593          	li	a1,262
ffffffffc0201570:	00006517          	auipc	a0,0x6
ffffffffc0201574:	c5850513          	addi	a0,a0,-936 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201578:	f0dfe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020157c:	00006697          	auipc	a3,0x6
ffffffffc0201580:	e5c68693          	addi	a3,a3,-420 # ffffffffc02073d8 <commands+0xab0>
ffffffffc0201584:	00006617          	auipc	a2,0x6
ffffffffc0201588:	87c60613          	addi	a2,a2,-1924 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020158c:	10500593          	li	a1,261
ffffffffc0201590:	00006517          	auipc	a0,0x6
ffffffffc0201594:	c3850513          	addi	a0,a0,-968 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201598:	eedfe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc020159c:	00006697          	auipc	a3,0x6
ffffffffc02015a0:	e2468693          	addi	a3,a3,-476 # ffffffffc02073c0 <commands+0xa98>
ffffffffc02015a4:	00006617          	auipc	a2,0x6
ffffffffc02015a8:	85c60613          	addi	a2,a2,-1956 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02015ac:	10400593          	li	a1,260
ffffffffc02015b0:	00006517          	auipc	a0,0x6
ffffffffc02015b4:	c1850513          	addi	a0,a0,-1000 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc02015b8:	ecdfe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02015bc:	00006697          	auipc	a3,0x6
ffffffffc02015c0:	d6c68693          	addi	a3,a3,-660 # ffffffffc0207328 <commands+0xa00>
ffffffffc02015c4:	00006617          	auipc	a2,0x6
ffffffffc02015c8:	83c60613          	addi	a2,a2,-1988 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02015cc:	0fe00593          	li	a1,254
ffffffffc02015d0:	00006517          	auipc	a0,0x6
ffffffffc02015d4:	bf850513          	addi	a0,a0,-1032 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc02015d8:	eadfe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(!PageProperty(p0));
ffffffffc02015dc:	00006697          	auipc	a3,0x6
ffffffffc02015e0:	dcc68693          	addi	a3,a3,-564 # ffffffffc02073a8 <commands+0xa80>
ffffffffc02015e4:	00006617          	auipc	a2,0x6
ffffffffc02015e8:	81c60613          	addi	a2,a2,-2020 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02015ec:	0f900593          	li	a1,249
ffffffffc02015f0:	00006517          	auipc	a0,0x6
ffffffffc02015f4:	bd850513          	addi	a0,a0,-1064 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc02015f8:	e8dfe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02015fc:	00006697          	auipc	a3,0x6
ffffffffc0201600:	ecc68693          	addi	a3,a3,-308 # ffffffffc02074c8 <commands+0xba0>
ffffffffc0201604:	00005617          	auipc	a2,0x5
ffffffffc0201608:	7fc60613          	addi	a2,a2,2044 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020160c:	11700593          	li	a1,279
ffffffffc0201610:	00006517          	auipc	a0,0x6
ffffffffc0201614:	bb850513          	addi	a0,a0,-1096 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201618:	e6dfe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(total == 0);
ffffffffc020161c:	00006697          	auipc	a3,0x6
ffffffffc0201620:	edc68693          	addi	a3,a3,-292 # ffffffffc02074f8 <commands+0xbd0>
ffffffffc0201624:	00005617          	auipc	a2,0x5
ffffffffc0201628:	7dc60613          	addi	a2,a2,2012 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020162c:	12600593          	li	a1,294
ffffffffc0201630:	00006517          	auipc	a0,0x6
ffffffffc0201634:	b9850513          	addi	a0,a0,-1128 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201638:	e4dfe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(total == nr_free_pages());
ffffffffc020163c:	00006697          	auipc	a3,0x6
ffffffffc0201640:	ba468693          	addi	a3,a3,-1116 # ffffffffc02071e0 <commands+0x8b8>
ffffffffc0201644:	00005617          	auipc	a2,0x5
ffffffffc0201648:	7bc60613          	addi	a2,a2,1980 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020164c:	0f300593          	li	a1,243
ffffffffc0201650:	00006517          	auipc	a0,0x6
ffffffffc0201654:	b7850513          	addi	a0,a0,-1160 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201658:	e2dfe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020165c:	00006697          	auipc	a3,0x6
ffffffffc0201660:	bc468693          	addi	a3,a3,-1084 # ffffffffc0207220 <commands+0x8f8>
ffffffffc0201664:	00005617          	auipc	a2,0x5
ffffffffc0201668:	79c60613          	addi	a2,a2,1948 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020166c:	0ba00593          	li	a1,186
ffffffffc0201670:	00006517          	auipc	a0,0x6
ffffffffc0201674:	b5850513          	addi	a0,a0,-1192 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201678:	e0dfe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020167c <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc020167c:	1141                	addi	sp,sp,-16
ffffffffc020167e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201680:	16058e63          	beqz	a1,ffffffffc02017fc <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc0201684:	00659693          	slli	a3,a1,0x6
ffffffffc0201688:	96aa                	add	a3,a3,a0
ffffffffc020168a:	02d50d63          	beq	a0,a3,ffffffffc02016c4 <default_free_pages+0x48>
ffffffffc020168e:	651c                	ld	a5,8(a0)
ffffffffc0201690:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201692:	14079563          	bnez	a5,ffffffffc02017dc <default_free_pages+0x160>
ffffffffc0201696:	651c                	ld	a5,8(a0)
ffffffffc0201698:	8385                	srli	a5,a5,0x1
ffffffffc020169a:	8b85                	andi	a5,a5,1
ffffffffc020169c:	14079063          	bnez	a5,ffffffffc02017dc <default_free_pages+0x160>
ffffffffc02016a0:	87aa                	mv	a5,a0
ffffffffc02016a2:	a809                	j	ffffffffc02016b4 <default_free_pages+0x38>
ffffffffc02016a4:	6798                	ld	a4,8(a5)
ffffffffc02016a6:	8b05                	andi	a4,a4,1
ffffffffc02016a8:	12071a63          	bnez	a4,ffffffffc02017dc <default_free_pages+0x160>
ffffffffc02016ac:	6798                	ld	a4,8(a5)
ffffffffc02016ae:	8b09                	andi	a4,a4,2
ffffffffc02016b0:	12071663          	bnez	a4,ffffffffc02017dc <default_free_pages+0x160>
        p->flags = 0;
ffffffffc02016b4:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc02016b8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02016bc:	04078793          	addi	a5,a5,64
ffffffffc02016c0:	fed792e3          	bne	a5,a3,ffffffffc02016a4 <default_free_pages+0x28>
    base->property = n;
ffffffffc02016c4:	2581                	sext.w	a1,a1
ffffffffc02016c6:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02016c8:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02016cc:	4789                	li	a5,2
ffffffffc02016ce:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02016d2:	000ab697          	auipc	a3,0xab
ffffffffc02016d6:	e8668693          	addi	a3,a3,-378 # ffffffffc02ac558 <free_area>
ffffffffc02016da:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02016dc:	669c                	ld	a5,8(a3)
ffffffffc02016de:	9db9                	addw	a1,a1,a4
ffffffffc02016e0:	000ab717          	auipc	a4,0xab
ffffffffc02016e4:	e8b72423          	sw	a1,-376(a4) # ffffffffc02ac568 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02016e8:	0cd78163          	beq	a5,a3,ffffffffc02017aa <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc02016ec:	fe878713          	addi	a4,a5,-24
ffffffffc02016f0:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02016f2:	4801                	li	a6,0
ffffffffc02016f4:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02016f8:	00e56a63          	bltu	a0,a4,ffffffffc020170c <default_free_pages+0x90>
    return listelm->next;
ffffffffc02016fc:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02016fe:	04d70f63          	beq	a4,a3,ffffffffc020175c <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201702:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201704:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201708:	fee57ae3          	bleu	a4,a0,ffffffffc02016fc <default_free_pages+0x80>
ffffffffc020170c:	00080663          	beqz	a6,ffffffffc0201718 <default_free_pages+0x9c>
ffffffffc0201710:	000ab817          	auipc	a6,0xab
ffffffffc0201714:	e4b83423          	sd	a1,-440(a6) # ffffffffc02ac558 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201718:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc020171a:	e390                	sd	a2,0(a5)
ffffffffc020171c:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc020171e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201720:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc0201722:	06d58a63          	beq	a1,a3,ffffffffc0201796 <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc0201726:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc020172a:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc020172e:	02061793          	slli	a5,a2,0x20
ffffffffc0201732:	83e9                	srli	a5,a5,0x1a
ffffffffc0201734:	97ba                	add	a5,a5,a4
ffffffffc0201736:	04f51b63          	bne	a0,a5,ffffffffc020178c <default_free_pages+0x110>
            p->property += base->property;
ffffffffc020173a:	491c                	lw	a5,16(a0)
ffffffffc020173c:	9e3d                	addw	a2,a2,a5
ffffffffc020173e:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201742:	57f5                	li	a5,-3
ffffffffc0201744:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201748:	01853803          	ld	a6,24(a0)
ffffffffc020174c:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc020174e:	853a                	mv	a0,a4
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201750:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc0201754:	659c                	ld	a5,8(a1)
ffffffffc0201756:	01063023          	sd	a6,0(a2)
ffffffffc020175a:	a815                	j	ffffffffc020178e <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc020175c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020175e:	f114                	sd	a3,32(a0)
ffffffffc0201760:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201762:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201764:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201766:	00d70563          	beq	a4,a3,ffffffffc0201770 <default_free_pages+0xf4>
ffffffffc020176a:	4805                	li	a6,1
ffffffffc020176c:	87ba                	mv	a5,a4
ffffffffc020176e:	bf59                	j	ffffffffc0201704 <default_free_pages+0x88>
ffffffffc0201770:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0201772:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0201774:	00d78d63          	beq	a5,a3,ffffffffc020178e <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0201778:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc020177c:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0201780:	02061793          	slli	a5,a2,0x20
ffffffffc0201784:	83e9                	srli	a5,a5,0x1a
ffffffffc0201786:	97ba                	add	a5,a5,a4
ffffffffc0201788:	faf509e3          	beq	a0,a5,ffffffffc020173a <default_free_pages+0xbe>
ffffffffc020178c:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc020178e:	fe878713          	addi	a4,a5,-24
ffffffffc0201792:	00d78963          	beq	a5,a3,ffffffffc02017a4 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc0201796:	4910                	lw	a2,16(a0)
ffffffffc0201798:	02061693          	slli	a3,a2,0x20
ffffffffc020179c:	82e9                	srli	a3,a3,0x1a
ffffffffc020179e:	96aa                	add	a3,a3,a0
ffffffffc02017a0:	00d70e63          	beq	a4,a3,ffffffffc02017bc <default_free_pages+0x140>
}
ffffffffc02017a4:	60a2                	ld	ra,8(sp)
ffffffffc02017a6:	0141                	addi	sp,sp,16
ffffffffc02017a8:	8082                	ret
ffffffffc02017aa:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02017ac:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02017b0:	e398                	sd	a4,0(a5)
ffffffffc02017b2:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02017b4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02017b6:	ed1c                	sd	a5,24(a0)
}
ffffffffc02017b8:	0141                	addi	sp,sp,16
ffffffffc02017ba:	8082                	ret
            base->property += p->property;
ffffffffc02017bc:	ff87a703          	lw	a4,-8(a5)
ffffffffc02017c0:	ff078693          	addi	a3,a5,-16
ffffffffc02017c4:	9e39                	addw	a2,a2,a4
ffffffffc02017c6:	c910                	sw	a2,16(a0)
ffffffffc02017c8:	5775                	li	a4,-3
ffffffffc02017ca:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02017ce:	6398                	ld	a4,0(a5)
ffffffffc02017d0:	679c                	ld	a5,8(a5)
}
ffffffffc02017d2:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02017d4:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02017d6:	e398                	sd	a4,0(a5)
ffffffffc02017d8:	0141                	addi	sp,sp,16
ffffffffc02017da:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02017dc:	00006697          	auipc	a3,0x6
ffffffffc02017e0:	d2c68693          	addi	a3,a3,-724 # ffffffffc0207508 <commands+0xbe0>
ffffffffc02017e4:	00005617          	auipc	a2,0x5
ffffffffc02017e8:	61c60613          	addi	a2,a2,1564 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02017ec:	08300593          	li	a1,131
ffffffffc02017f0:	00006517          	auipc	a0,0x6
ffffffffc02017f4:	9d850513          	addi	a0,a0,-1576 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc02017f8:	c8dfe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(n > 0);
ffffffffc02017fc:	00006697          	auipc	a3,0x6
ffffffffc0201800:	d3468693          	addi	a3,a3,-716 # ffffffffc0207530 <commands+0xc08>
ffffffffc0201804:	00005617          	auipc	a2,0x5
ffffffffc0201808:	5fc60613          	addi	a2,a2,1532 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020180c:	08000593          	li	a1,128
ffffffffc0201810:	00006517          	auipc	a0,0x6
ffffffffc0201814:	9b850513          	addi	a0,a0,-1608 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc0201818:	c6dfe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020181c <default_alloc_pages>:
    assert(n > 0);
ffffffffc020181c:	c959                	beqz	a0,ffffffffc02018b2 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc020181e:	000ab597          	auipc	a1,0xab
ffffffffc0201822:	d3a58593          	addi	a1,a1,-710 # ffffffffc02ac558 <free_area>
ffffffffc0201826:	0105a803          	lw	a6,16(a1)
ffffffffc020182a:	862a                	mv	a2,a0
ffffffffc020182c:	02081793          	slli	a5,a6,0x20
ffffffffc0201830:	9381                	srli	a5,a5,0x20
ffffffffc0201832:	00a7ee63          	bltu	a5,a0,ffffffffc020184e <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201836:	87ae                	mv	a5,a1
ffffffffc0201838:	a801                	j	ffffffffc0201848 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc020183a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020183e:	02071693          	slli	a3,a4,0x20
ffffffffc0201842:	9281                	srli	a3,a3,0x20
ffffffffc0201844:	00c6f763          	bleu	a2,a3,ffffffffc0201852 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201848:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020184a:	feb798e3          	bne	a5,a1,ffffffffc020183a <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020184e:	4501                	li	a0,0
}
ffffffffc0201850:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0201852:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc0201856:	dd6d                	beqz	a0,ffffffffc0201850 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201858:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020185c:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0201860:	00060e1b          	sext.w	t3,a2
ffffffffc0201864:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201868:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc020186c:	02d67863          	bleu	a3,a2,ffffffffc020189c <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc0201870:	061a                	slli	a2,a2,0x6
ffffffffc0201872:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc0201874:	41c7073b          	subw	a4,a4,t3
ffffffffc0201878:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020187a:	00860693          	addi	a3,a2,8
ffffffffc020187e:	4709                	li	a4,2
ffffffffc0201880:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201884:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201888:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc020188c:	0105a803          	lw	a6,16(a1)
ffffffffc0201890:	e314                	sd	a3,0(a4)
ffffffffc0201892:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc0201896:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0201898:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc020189c:	41c8083b          	subw	a6,a6,t3
ffffffffc02018a0:	000ab717          	auipc	a4,0xab
ffffffffc02018a4:	cd072423          	sw	a6,-824(a4) # ffffffffc02ac568 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02018a8:	5775                	li	a4,-3
ffffffffc02018aa:	17c1                	addi	a5,a5,-16
ffffffffc02018ac:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc02018b0:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02018b2:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02018b4:	00006697          	auipc	a3,0x6
ffffffffc02018b8:	c7c68693          	addi	a3,a3,-900 # ffffffffc0207530 <commands+0xc08>
ffffffffc02018bc:	00005617          	auipc	a2,0x5
ffffffffc02018c0:	54460613          	addi	a2,a2,1348 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02018c4:	06200593          	li	a1,98
ffffffffc02018c8:	00006517          	auipc	a0,0x6
ffffffffc02018cc:	90050513          	addi	a0,a0,-1792 # ffffffffc02071c8 <commands+0x8a0>
default_alloc_pages(size_t n) {
ffffffffc02018d0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02018d2:	bb3fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02018d6 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02018d6:	1141                	addi	sp,sp,-16
ffffffffc02018d8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02018da:	c1ed                	beqz	a1,ffffffffc02019bc <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc02018dc:	00659693          	slli	a3,a1,0x6
ffffffffc02018e0:	96aa                	add	a3,a3,a0
ffffffffc02018e2:	02d50463          	beq	a0,a3,ffffffffc020190a <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02018e6:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02018e8:	87aa                	mv	a5,a0
ffffffffc02018ea:	8b05                	andi	a4,a4,1
ffffffffc02018ec:	e709                	bnez	a4,ffffffffc02018f6 <default_init_memmap+0x20>
ffffffffc02018ee:	a07d                	j	ffffffffc020199c <default_init_memmap+0xc6>
ffffffffc02018f0:	6798                	ld	a4,8(a5)
ffffffffc02018f2:	8b05                	andi	a4,a4,1
ffffffffc02018f4:	c745                	beqz	a4,ffffffffc020199c <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc02018f6:	0007a823          	sw	zero,16(a5)
ffffffffc02018fa:	0007b423          	sd	zero,8(a5)
ffffffffc02018fe:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201902:	04078793          	addi	a5,a5,64
ffffffffc0201906:	fed795e3          	bne	a5,a3,ffffffffc02018f0 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc020190a:	2581                	sext.w	a1,a1
ffffffffc020190c:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020190e:	4789                	li	a5,2
ffffffffc0201910:	00850713          	addi	a4,a0,8
ffffffffc0201914:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201918:	000ab697          	auipc	a3,0xab
ffffffffc020191c:	c4068693          	addi	a3,a3,-960 # ffffffffc02ac558 <free_area>
ffffffffc0201920:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201922:	669c                	ld	a5,8(a3)
ffffffffc0201924:	9db9                	addw	a1,a1,a4
ffffffffc0201926:	000ab717          	auipc	a4,0xab
ffffffffc020192a:	c4b72123          	sw	a1,-958(a4) # ffffffffc02ac568 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020192e:	04d78a63          	beq	a5,a3,ffffffffc0201982 <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc0201932:	fe878713          	addi	a4,a5,-24
ffffffffc0201936:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201938:	4801                	li	a6,0
ffffffffc020193a:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc020193e:	00e56a63          	bltu	a0,a4,ffffffffc0201952 <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc0201942:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201944:	02d70563          	beq	a4,a3,ffffffffc020196e <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201948:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020194a:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020194e:	fee57ae3          	bleu	a4,a0,ffffffffc0201942 <default_init_memmap+0x6c>
ffffffffc0201952:	00080663          	beqz	a6,ffffffffc020195e <default_init_memmap+0x88>
ffffffffc0201956:	000ab717          	auipc	a4,0xab
ffffffffc020195a:	c0b73123          	sd	a1,-1022(a4) # ffffffffc02ac558 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020195e:	6398                	ld	a4,0(a5)
}
ffffffffc0201960:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201962:	e390                	sd	a2,0(a5)
ffffffffc0201964:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201966:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201968:	ed18                	sd	a4,24(a0)
ffffffffc020196a:	0141                	addi	sp,sp,16
ffffffffc020196c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020196e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201970:	f114                	sd	a3,32(a0)
ffffffffc0201972:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201974:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201976:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201978:	00d70e63          	beq	a4,a3,ffffffffc0201994 <default_init_memmap+0xbe>
ffffffffc020197c:	4805                	li	a6,1
ffffffffc020197e:	87ba                	mv	a5,a4
ffffffffc0201980:	b7e9                	j	ffffffffc020194a <default_init_memmap+0x74>
}
ffffffffc0201982:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201984:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201988:	e398                	sd	a4,0(a5)
ffffffffc020198a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020198c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020198e:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201990:	0141                	addi	sp,sp,16
ffffffffc0201992:	8082                	ret
ffffffffc0201994:	60a2                	ld	ra,8(sp)
ffffffffc0201996:	e290                	sd	a2,0(a3)
ffffffffc0201998:	0141                	addi	sp,sp,16
ffffffffc020199a:	8082                	ret
        assert(PageReserved(p));
ffffffffc020199c:	00006697          	auipc	a3,0x6
ffffffffc02019a0:	b9c68693          	addi	a3,a3,-1124 # ffffffffc0207538 <commands+0xc10>
ffffffffc02019a4:	00005617          	auipc	a2,0x5
ffffffffc02019a8:	45c60613          	addi	a2,a2,1116 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02019ac:	04900593          	li	a1,73
ffffffffc02019b0:	00006517          	auipc	a0,0x6
ffffffffc02019b4:	81850513          	addi	a0,a0,-2024 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc02019b8:	acdfe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(n > 0);
ffffffffc02019bc:	00006697          	auipc	a3,0x6
ffffffffc02019c0:	b7468693          	addi	a3,a3,-1164 # ffffffffc0207530 <commands+0xc08>
ffffffffc02019c4:	00005617          	auipc	a2,0x5
ffffffffc02019c8:	43c60613          	addi	a2,a2,1084 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02019cc:	04600593          	li	a1,70
ffffffffc02019d0:	00005517          	auipc	a0,0x5
ffffffffc02019d4:	7f850513          	addi	a0,a0,2040 # ffffffffc02071c8 <commands+0x8a0>
ffffffffc02019d8:	aadfe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02019dc <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02019dc:	c125                	beqz	a0,ffffffffc0201a3c <slob_free+0x60>
		return;

	if (size)
ffffffffc02019de:	e1a5                	bnez	a1,ffffffffc0201a3e <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019e0:	100027f3          	csrr	a5,sstatus
ffffffffc02019e4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02019e6:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019e8:	e3bd                	bnez	a5,ffffffffc0201a4e <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019ea:	0009f797          	auipc	a5,0x9f
ffffffffc02019ee:	6fe78793          	addi	a5,a5,1790 # ffffffffc02a10e8 <slobfree>
ffffffffc02019f2:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019f4:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019f6:	00a7fa63          	bleu	a0,a5,ffffffffc0201a0a <slob_free+0x2e>
ffffffffc02019fa:	00e56c63          	bltu	a0,a4,ffffffffc0201a12 <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019fe:	00e7fa63          	bleu	a4,a5,ffffffffc0201a12 <slob_free+0x36>
    return 0;
ffffffffc0201a02:	87ba                	mv	a5,a4
ffffffffc0201a04:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a06:	fea7eae3          	bltu	a5,a0,ffffffffc02019fa <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a0a:	fee7ece3          	bltu	a5,a4,ffffffffc0201a02 <slob_free+0x26>
ffffffffc0201a0e:	fee57ae3          	bleu	a4,a0,ffffffffc0201a02 <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc0201a12:	4110                	lw	a2,0(a0)
ffffffffc0201a14:	00461693          	slli	a3,a2,0x4
ffffffffc0201a18:	96aa                	add	a3,a3,a0
ffffffffc0201a1a:	08d70b63          	beq	a4,a3,ffffffffc0201ab0 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0201a1e:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc0201a20:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a22:	00469713          	slli	a4,a3,0x4
ffffffffc0201a26:	973e                	add	a4,a4,a5
ffffffffc0201a28:	08e50f63          	beq	a0,a4,ffffffffc0201ac6 <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201a2c:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc0201a2e:	0009f717          	auipc	a4,0x9f
ffffffffc0201a32:	6af73d23          	sd	a5,1722(a4) # ffffffffc02a10e8 <slobfree>
    if (flag) {
ffffffffc0201a36:	c199                	beqz	a1,ffffffffc0201a3c <slob_free+0x60>
        intr_enable();
ffffffffc0201a38:	c1dfe06f          	j	ffffffffc0200654 <intr_enable>
ffffffffc0201a3c:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc0201a3e:	05bd                	addi	a1,a1,15
ffffffffc0201a40:	8191                	srli	a1,a1,0x4
ffffffffc0201a42:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a44:	100027f3          	csrr	a5,sstatus
ffffffffc0201a48:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201a4a:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a4c:	dfd9                	beqz	a5,ffffffffc02019ea <slob_free+0xe>
{
ffffffffc0201a4e:	1101                	addi	sp,sp,-32
ffffffffc0201a50:	e42a                	sd	a0,8(sp)
ffffffffc0201a52:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201a54:	c07fe0ef          	jal	ra,ffffffffc020065a <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a58:	0009f797          	auipc	a5,0x9f
ffffffffc0201a5c:	69078793          	addi	a5,a5,1680 # ffffffffc02a10e8 <slobfree>
ffffffffc0201a60:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0201a62:	6522                	ld	a0,8(sp)
ffffffffc0201a64:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a66:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a68:	00a7fa63          	bleu	a0,a5,ffffffffc0201a7c <slob_free+0xa0>
ffffffffc0201a6c:	00e56c63          	bltu	a0,a4,ffffffffc0201a84 <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a70:	00e7fa63          	bleu	a4,a5,ffffffffc0201a84 <slob_free+0xa8>
    return 0;
ffffffffc0201a74:	87ba                	mv	a5,a4
ffffffffc0201a76:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a78:	fea7eae3          	bltu	a5,a0,ffffffffc0201a6c <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a7c:	fee7ece3          	bltu	a5,a4,ffffffffc0201a74 <slob_free+0x98>
ffffffffc0201a80:	fee57ae3          	bleu	a4,a0,ffffffffc0201a74 <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0201a84:	4110                	lw	a2,0(a0)
ffffffffc0201a86:	00461693          	slli	a3,a2,0x4
ffffffffc0201a8a:	96aa                	add	a3,a3,a0
ffffffffc0201a8c:	04d70763          	beq	a4,a3,ffffffffc0201ada <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0201a90:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a92:	4394                	lw	a3,0(a5)
ffffffffc0201a94:	00469713          	slli	a4,a3,0x4
ffffffffc0201a98:	973e                	add	a4,a4,a5
ffffffffc0201a9a:	04e50663          	beq	a0,a4,ffffffffc0201ae6 <slob_free+0x10a>
		cur->next = b;
ffffffffc0201a9e:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0201aa0:	0009f717          	auipc	a4,0x9f
ffffffffc0201aa4:	64f73423          	sd	a5,1608(a4) # ffffffffc02a10e8 <slobfree>
    if (flag) {
ffffffffc0201aa8:	e58d                	bnez	a1,ffffffffc0201ad2 <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201aaa:	60e2                	ld	ra,24(sp)
ffffffffc0201aac:	6105                	addi	sp,sp,32
ffffffffc0201aae:	8082                	ret
		b->units += cur->next->units;
ffffffffc0201ab0:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201ab2:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201ab4:	9e35                	addw	a2,a2,a3
ffffffffc0201ab6:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0201ab8:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201aba:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201abc:	00469713          	slli	a4,a3,0x4
ffffffffc0201ac0:	973e                	add	a4,a4,a5
ffffffffc0201ac2:	f6e515e3          	bne	a0,a4,ffffffffc0201a2c <slob_free+0x50>
		cur->units += b->units;
ffffffffc0201ac6:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201ac8:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201aca:	9eb9                	addw	a3,a3,a4
ffffffffc0201acc:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201ace:	e790                	sd	a2,8(a5)
ffffffffc0201ad0:	bfb9                	j	ffffffffc0201a2e <slob_free+0x52>
}
ffffffffc0201ad2:	60e2                	ld	ra,24(sp)
ffffffffc0201ad4:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201ad6:	b7ffe06f          	j	ffffffffc0200654 <intr_enable>
		b->units += cur->next->units;
ffffffffc0201ada:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201adc:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201ade:	9e35                	addw	a2,a2,a3
ffffffffc0201ae0:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0201ae2:	e518                	sd	a4,8(a0)
ffffffffc0201ae4:	b77d                	j	ffffffffc0201a92 <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0201ae6:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201ae8:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201aea:	9eb9                	addw	a3,a3,a4
ffffffffc0201aec:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201aee:	e790                	sd	a2,8(a5)
ffffffffc0201af0:	bf45                	j	ffffffffc0201aa0 <slob_free+0xc4>

ffffffffc0201af2 <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201af2:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201af4:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201af6:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201afa:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201afc:	38e000ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
  if(!page)
ffffffffc0201b00:	c139                	beqz	a0,ffffffffc0201b46 <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc0201b02:	000ab797          	auipc	a5,0xab
ffffffffc0201b06:	a8678793          	addi	a5,a5,-1402 # ffffffffc02ac588 <pages>
ffffffffc0201b0a:	6394                	ld	a3,0(a5)
ffffffffc0201b0c:	00007797          	auipc	a5,0x7
ffffffffc0201b10:	46c78793          	addi	a5,a5,1132 # ffffffffc0208f78 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201b14:	000ab717          	auipc	a4,0xab
ffffffffc0201b18:	a0470713          	addi	a4,a4,-1532 # ffffffffc02ac518 <npage>
    return page - pages + nbase;
ffffffffc0201b1c:	40d506b3          	sub	a3,a0,a3
ffffffffc0201b20:	6388                	ld	a0,0(a5)
ffffffffc0201b22:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201b24:	57fd                	li	a5,-1
ffffffffc0201b26:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0201b28:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0201b2a:	83b1                	srli	a5,a5,0xc
ffffffffc0201b2c:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201b2e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201b30:	00e7ff63          	bleu	a4,a5,ffffffffc0201b4e <__slob_get_free_pages.isra.0+0x5c>
ffffffffc0201b34:	000ab797          	auipc	a5,0xab
ffffffffc0201b38:	a4478793          	addi	a5,a5,-1468 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0201b3c:	6388                	ld	a0,0(a5)
}
ffffffffc0201b3e:	60a2                	ld	ra,8(sp)
ffffffffc0201b40:	9536                	add	a0,a0,a3
ffffffffc0201b42:	0141                	addi	sp,sp,16
ffffffffc0201b44:	8082                	ret
ffffffffc0201b46:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc0201b48:	4501                	li	a0,0
}
ffffffffc0201b4a:	0141                	addi	sp,sp,16
ffffffffc0201b4c:	8082                	ret
ffffffffc0201b4e:	00006617          	auipc	a2,0x6
ffffffffc0201b52:	a4a60613          	addi	a2,a2,-1462 # ffffffffc0207598 <default_pmm_manager+0x50>
ffffffffc0201b56:	06900593          	li	a1,105
ffffffffc0201b5a:	00006517          	auipc	a0,0x6
ffffffffc0201b5e:	a6650513          	addi	a0,a0,-1434 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0201b62:	923fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201b66 <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201b66:	7179                	addi	sp,sp,-48
ffffffffc0201b68:	f406                	sd	ra,40(sp)
ffffffffc0201b6a:	f022                	sd	s0,32(sp)
ffffffffc0201b6c:	ec26                	sd	s1,24(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201b6e:	01050713          	addi	a4,a0,16
ffffffffc0201b72:	6785                	lui	a5,0x1
ffffffffc0201b74:	0cf77b63          	bleu	a5,a4,ffffffffc0201c4a <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201b78:	00f50413          	addi	s0,a0,15
ffffffffc0201b7c:	8011                	srli	s0,s0,0x4
ffffffffc0201b7e:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b80:	10002673          	csrr	a2,sstatus
ffffffffc0201b84:	8a09                	andi	a2,a2,2
ffffffffc0201b86:	ea5d                	bnez	a2,ffffffffc0201c3c <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc0201b88:	0009f497          	auipc	s1,0x9f
ffffffffc0201b8c:	56048493          	addi	s1,s1,1376 # ffffffffc02a10e8 <slobfree>
ffffffffc0201b90:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b92:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b94:	4398                	lw	a4,0(a5)
ffffffffc0201b96:	0a875763          	ble	s0,a4,ffffffffc0201c44 <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc0201b9a:	00f68a63          	beq	a3,a5,ffffffffc0201bae <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b9e:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201ba0:	4118                	lw	a4,0(a0)
ffffffffc0201ba2:	02875763          	ble	s0,a4,ffffffffc0201bd0 <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc0201ba6:	6094                	ld	a3,0(s1)
ffffffffc0201ba8:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc0201baa:	fef69ae3          	bne	a3,a5,ffffffffc0201b9e <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc0201bae:	ea39                	bnez	a2,ffffffffc0201c04 <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201bb0:	4501                	li	a0,0
ffffffffc0201bb2:	f41ff0ef          	jal	ra,ffffffffc0201af2 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201bb6:	cd29                	beqz	a0,ffffffffc0201c10 <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201bb8:	6585                	lui	a1,0x1
ffffffffc0201bba:	e23ff0ef          	jal	ra,ffffffffc02019dc <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201bbe:	10002673          	csrr	a2,sstatus
ffffffffc0201bc2:	8a09                	andi	a2,a2,2
ffffffffc0201bc4:	ea1d                	bnez	a2,ffffffffc0201bfa <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc0201bc6:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201bc8:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201bca:	4118                	lw	a4,0(a0)
ffffffffc0201bcc:	fc874de3          	blt	a4,s0,ffffffffc0201ba6 <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc0201bd0:	04e40663          	beq	s0,a4,ffffffffc0201c1c <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc0201bd4:	00441693          	slli	a3,s0,0x4
ffffffffc0201bd8:	96aa                	add	a3,a3,a0
ffffffffc0201bda:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201bdc:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc0201bde:	9f01                	subw	a4,a4,s0
ffffffffc0201be0:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201be2:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201be4:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc0201be6:	0009f717          	auipc	a4,0x9f
ffffffffc0201bea:	50f73123          	sd	a5,1282(a4) # ffffffffc02a10e8 <slobfree>
    if (flag) {
ffffffffc0201bee:	ee15                	bnez	a2,ffffffffc0201c2a <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc0201bf0:	70a2                	ld	ra,40(sp)
ffffffffc0201bf2:	7402                	ld	s0,32(sp)
ffffffffc0201bf4:	64e2                	ld	s1,24(sp)
ffffffffc0201bf6:	6145                	addi	sp,sp,48
ffffffffc0201bf8:	8082                	ret
        intr_disable();
ffffffffc0201bfa:	a61fe0ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc0201bfe:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0201c00:	609c                	ld	a5,0(s1)
ffffffffc0201c02:	b7d9                	j	ffffffffc0201bc8 <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc0201c04:	a51fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201c08:	4501                	li	a0,0
ffffffffc0201c0a:	ee9ff0ef          	jal	ra,ffffffffc0201af2 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201c0e:	f54d                	bnez	a0,ffffffffc0201bb8 <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc0201c10:	70a2                	ld	ra,40(sp)
ffffffffc0201c12:	7402                	ld	s0,32(sp)
ffffffffc0201c14:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc0201c16:	4501                	li	a0,0
}
ffffffffc0201c18:	6145                	addi	sp,sp,48
ffffffffc0201c1a:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201c1c:	6518                	ld	a4,8(a0)
ffffffffc0201c1e:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc0201c20:	0009f717          	auipc	a4,0x9f
ffffffffc0201c24:	4cf73423          	sd	a5,1224(a4) # ffffffffc02a10e8 <slobfree>
    if (flag) {
ffffffffc0201c28:	d661                	beqz	a2,ffffffffc0201bf0 <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc0201c2a:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201c2c:	a29fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
}
ffffffffc0201c30:	70a2                	ld	ra,40(sp)
ffffffffc0201c32:	7402                	ld	s0,32(sp)
ffffffffc0201c34:	6522                	ld	a0,8(sp)
ffffffffc0201c36:	64e2                	ld	s1,24(sp)
ffffffffc0201c38:	6145                	addi	sp,sp,48
ffffffffc0201c3a:	8082                	ret
        intr_disable();
ffffffffc0201c3c:	a1ffe0ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc0201c40:	4605                	li	a2,1
ffffffffc0201c42:	b799                	j	ffffffffc0201b88 <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201c44:	853e                	mv	a0,a5
ffffffffc0201c46:	87b6                	mv	a5,a3
ffffffffc0201c48:	b761                	j	ffffffffc0201bd0 <slob_alloc.isra.1.constprop.3+0x6a>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201c4a:	00006697          	auipc	a3,0x6
ffffffffc0201c4e:	9ee68693          	addi	a3,a3,-1554 # ffffffffc0207638 <default_pmm_manager+0xf0>
ffffffffc0201c52:	00005617          	auipc	a2,0x5
ffffffffc0201c56:	1ae60613          	addi	a2,a2,430 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0201c5a:	06400593          	li	a1,100
ffffffffc0201c5e:	00006517          	auipc	a0,0x6
ffffffffc0201c62:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0207658 <default_pmm_manager+0x110>
ffffffffc0201c66:	81ffe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201c6a <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201c6a:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201c6c:	00006517          	auipc	a0,0x6
ffffffffc0201c70:	a0450513          	addi	a0,a0,-1532 # ffffffffc0207670 <default_pmm_manager+0x128>
kmalloc_init(void) {
ffffffffc0201c74:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201c76:	d18fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201c7a:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c7c:	00006517          	auipc	a0,0x6
ffffffffc0201c80:	99c50513          	addi	a0,a0,-1636 # ffffffffc0207618 <default_pmm_manager+0xd0>
}
ffffffffc0201c84:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c86:	d08fe06f          	j	ffffffffc020018e <cprintf>

ffffffffc0201c8a <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201c8a:	4501                	li	a0,0
ffffffffc0201c8c:	8082                	ret

ffffffffc0201c8e <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201c8e:	1101                	addi	sp,sp,-32
ffffffffc0201c90:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c92:	6905                	lui	s2,0x1
{
ffffffffc0201c94:	e822                	sd	s0,16(sp)
ffffffffc0201c96:	ec06                	sd	ra,24(sp)
ffffffffc0201c98:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c9a:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8589>
{
ffffffffc0201c9e:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201ca0:	04a7fc63          	bleu	a0,a5,ffffffffc0201cf8 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201ca4:	4561                	li	a0,24
ffffffffc0201ca6:	ec1ff0ef          	jal	ra,ffffffffc0201b66 <slob_alloc.isra.1.constprop.3>
ffffffffc0201caa:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201cac:	cd21                	beqz	a0,ffffffffc0201d04 <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0201cae:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201cb2:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201cb4:	00f95763          	ble	a5,s2,ffffffffc0201cc2 <kmalloc+0x34>
ffffffffc0201cb8:	6705                	lui	a4,0x1
ffffffffc0201cba:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201cbc:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201cbe:	fef74ee3          	blt	a4,a5,ffffffffc0201cba <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201cc2:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201cc4:	e2fff0ef          	jal	ra,ffffffffc0201af2 <__slob_get_free_pages.isra.0>
ffffffffc0201cc8:	e488                	sd	a0,8(s1)
ffffffffc0201cca:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201ccc:	c935                	beqz	a0,ffffffffc0201d40 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201cce:	100027f3          	csrr	a5,sstatus
ffffffffc0201cd2:	8b89                	andi	a5,a5,2
ffffffffc0201cd4:	e3a1                	bnez	a5,ffffffffc0201d14 <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0201cd6:	000ab797          	auipc	a5,0xab
ffffffffc0201cda:	83278793          	addi	a5,a5,-1998 # ffffffffc02ac508 <bigblocks>
ffffffffc0201cde:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201ce0:	000ab717          	auipc	a4,0xab
ffffffffc0201ce4:	82973423          	sd	s1,-2008(a4) # ffffffffc02ac508 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201ce8:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201cea:	8522                	mv	a0,s0
ffffffffc0201cec:	60e2                	ld	ra,24(sp)
ffffffffc0201cee:	6442                	ld	s0,16(sp)
ffffffffc0201cf0:	64a2                	ld	s1,8(sp)
ffffffffc0201cf2:	6902                	ld	s2,0(sp)
ffffffffc0201cf4:	6105                	addi	sp,sp,32
ffffffffc0201cf6:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201cf8:	0541                	addi	a0,a0,16
ffffffffc0201cfa:	e6dff0ef          	jal	ra,ffffffffc0201b66 <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201cfe:	01050413          	addi	s0,a0,16
ffffffffc0201d02:	f565                	bnez	a0,ffffffffc0201cea <kmalloc+0x5c>
ffffffffc0201d04:	4401                	li	s0,0
}
ffffffffc0201d06:	8522                	mv	a0,s0
ffffffffc0201d08:	60e2                	ld	ra,24(sp)
ffffffffc0201d0a:	6442                	ld	s0,16(sp)
ffffffffc0201d0c:	64a2                	ld	s1,8(sp)
ffffffffc0201d0e:	6902                	ld	s2,0(sp)
ffffffffc0201d10:	6105                	addi	sp,sp,32
ffffffffc0201d12:	8082                	ret
        intr_disable();
ffffffffc0201d14:	947fe0ef          	jal	ra,ffffffffc020065a <intr_disable>
		bb->next = bigblocks;
ffffffffc0201d18:	000aa797          	auipc	a5,0xaa
ffffffffc0201d1c:	7f078793          	addi	a5,a5,2032 # ffffffffc02ac508 <bigblocks>
ffffffffc0201d20:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201d22:	000aa717          	auipc	a4,0xaa
ffffffffc0201d26:	7e973323          	sd	s1,2022(a4) # ffffffffc02ac508 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201d2a:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201d2c:	929fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0201d30:	6480                	ld	s0,8(s1)
}
ffffffffc0201d32:	60e2                	ld	ra,24(sp)
ffffffffc0201d34:	64a2                	ld	s1,8(sp)
ffffffffc0201d36:	8522                	mv	a0,s0
ffffffffc0201d38:	6442                	ld	s0,16(sp)
ffffffffc0201d3a:	6902                	ld	s2,0(sp)
ffffffffc0201d3c:	6105                	addi	sp,sp,32
ffffffffc0201d3e:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d40:	45e1                	li	a1,24
ffffffffc0201d42:	8526                	mv	a0,s1
ffffffffc0201d44:	c99ff0ef          	jal	ra,ffffffffc02019dc <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201d48:	b74d                	j	ffffffffc0201cea <kmalloc+0x5c>

ffffffffc0201d4a <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201d4a:	c175                	beqz	a0,ffffffffc0201e2e <kfree+0xe4>
{
ffffffffc0201d4c:	1101                	addi	sp,sp,-32
ffffffffc0201d4e:	e426                	sd	s1,8(sp)
ffffffffc0201d50:	ec06                	sd	ra,24(sp)
ffffffffc0201d52:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201d54:	03451793          	slli	a5,a0,0x34
ffffffffc0201d58:	84aa                	mv	s1,a0
ffffffffc0201d5a:	eb8d                	bnez	a5,ffffffffc0201d8c <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d5c:	100027f3          	csrr	a5,sstatus
ffffffffc0201d60:	8b89                	andi	a5,a5,2
ffffffffc0201d62:	efc9                	bnez	a5,ffffffffc0201dfc <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d64:	000aa797          	auipc	a5,0xaa
ffffffffc0201d68:	7a478793          	addi	a5,a5,1956 # ffffffffc02ac508 <bigblocks>
ffffffffc0201d6c:	6394                	ld	a3,0(a5)
ffffffffc0201d6e:	ce99                	beqz	a3,ffffffffc0201d8c <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201d70:	669c                	ld	a5,8(a3)
ffffffffc0201d72:	6a80                	ld	s0,16(a3)
ffffffffc0201d74:	0af50e63          	beq	a0,a5,ffffffffc0201e30 <kfree+0xe6>
    return 0;
ffffffffc0201d78:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d7a:	c801                	beqz	s0,ffffffffc0201d8a <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0201d7c:	6418                	ld	a4,8(s0)
ffffffffc0201d7e:	681c                	ld	a5,16(s0)
ffffffffc0201d80:	00970f63          	beq	a4,s1,ffffffffc0201d9e <kfree+0x54>
ffffffffc0201d84:	86a2                	mv	a3,s0
ffffffffc0201d86:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d88:	f875                	bnez	s0,ffffffffc0201d7c <kfree+0x32>
    if (flag) {
ffffffffc0201d8a:	e659                	bnez	a2,ffffffffc0201e18 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201d8c:	6442                	ld	s0,16(sp)
ffffffffc0201d8e:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d90:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201d94:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d96:	4581                	li	a1,0
}
ffffffffc0201d98:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d9a:	c43ff06f          	j	ffffffffc02019dc <slob_free>
				*last = bb->next;
ffffffffc0201d9e:	ea9c                	sd	a5,16(a3)
ffffffffc0201da0:	e641                	bnez	a2,ffffffffc0201e28 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0201da2:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201da6:	4018                	lw	a4,0(s0)
ffffffffc0201da8:	08f4ea63          	bltu	s1,a5,ffffffffc0201e3c <kfree+0xf2>
ffffffffc0201dac:	000aa797          	auipc	a5,0xaa
ffffffffc0201db0:	7cc78793          	addi	a5,a5,1996 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0201db4:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201db6:	000aa797          	auipc	a5,0xaa
ffffffffc0201dba:	76278793          	addi	a5,a5,1890 # ffffffffc02ac518 <npage>
ffffffffc0201dbe:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201dc0:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201dc2:	80b1                	srli	s1,s1,0xc
ffffffffc0201dc4:	08f4f963          	bleu	a5,s1,ffffffffc0201e56 <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0201dc8:	00007797          	auipc	a5,0x7
ffffffffc0201dcc:	1b078793          	addi	a5,a5,432 # ffffffffc0208f78 <nbase>
ffffffffc0201dd0:	639c                	ld	a5,0(a5)
ffffffffc0201dd2:	000aa697          	auipc	a3,0xaa
ffffffffc0201dd6:	7b668693          	addi	a3,a3,1974 # ffffffffc02ac588 <pages>
ffffffffc0201dda:	6288                	ld	a0,0(a3)
ffffffffc0201ddc:	8c9d                	sub	s1,s1,a5
ffffffffc0201dde:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201de0:	4585                	li	a1,1
ffffffffc0201de2:	9526                	add	a0,a0,s1
ffffffffc0201de4:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201de8:	12a000ef          	jal	ra,ffffffffc0201f12 <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201dec:	8522                	mv	a0,s0
}
ffffffffc0201dee:	6442                	ld	s0,16(sp)
ffffffffc0201df0:	60e2                	ld	ra,24(sp)
ffffffffc0201df2:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201df4:	45e1                	li	a1,24
}
ffffffffc0201df6:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201df8:	be5ff06f          	j	ffffffffc02019dc <slob_free>
        intr_disable();
ffffffffc0201dfc:	85ffe0ef          	jal	ra,ffffffffc020065a <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201e00:	000aa797          	auipc	a5,0xaa
ffffffffc0201e04:	70878793          	addi	a5,a5,1800 # ffffffffc02ac508 <bigblocks>
ffffffffc0201e08:	6394                	ld	a3,0(a5)
ffffffffc0201e0a:	c699                	beqz	a3,ffffffffc0201e18 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0201e0c:	669c                	ld	a5,8(a3)
ffffffffc0201e0e:	6a80                	ld	s0,16(a3)
ffffffffc0201e10:	00f48763          	beq	s1,a5,ffffffffc0201e1e <kfree+0xd4>
        return 1;
ffffffffc0201e14:	4605                	li	a2,1
ffffffffc0201e16:	b795                	j	ffffffffc0201d7a <kfree+0x30>
        intr_enable();
ffffffffc0201e18:	83dfe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0201e1c:	bf85                	j	ffffffffc0201d8c <kfree+0x42>
				*last = bb->next;
ffffffffc0201e1e:	000aa797          	auipc	a5,0xaa
ffffffffc0201e22:	6e87b523          	sd	s0,1770(a5) # ffffffffc02ac508 <bigblocks>
ffffffffc0201e26:	8436                	mv	s0,a3
ffffffffc0201e28:	82dfe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0201e2c:	bf9d                	j	ffffffffc0201da2 <kfree+0x58>
ffffffffc0201e2e:	8082                	ret
ffffffffc0201e30:	000aa797          	auipc	a5,0xaa
ffffffffc0201e34:	6c87bc23          	sd	s0,1752(a5) # ffffffffc02ac508 <bigblocks>
ffffffffc0201e38:	8436                	mv	s0,a3
ffffffffc0201e3a:	b7a5                	j	ffffffffc0201da2 <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0201e3c:	86a6                	mv	a3,s1
ffffffffc0201e3e:	00005617          	auipc	a2,0x5
ffffffffc0201e42:	79260613          	addi	a2,a2,1938 # ffffffffc02075d0 <default_pmm_manager+0x88>
ffffffffc0201e46:	06e00593          	li	a1,110
ffffffffc0201e4a:	00005517          	auipc	a0,0x5
ffffffffc0201e4e:	77650513          	addi	a0,a0,1910 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0201e52:	e32fe0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201e56:	00005617          	auipc	a2,0x5
ffffffffc0201e5a:	7a260613          	addi	a2,a2,1954 # ffffffffc02075f8 <default_pmm_manager+0xb0>
ffffffffc0201e5e:	06200593          	li	a1,98
ffffffffc0201e62:	00005517          	auipc	a0,0x5
ffffffffc0201e66:	75e50513          	addi	a0,a0,1886 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0201e6a:	e1afe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201e6e <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0201e6e:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201e70:	00005617          	auipc	a2,0x5
ffffffffc0201e74:	78860613          	addi	a2,a2,1928 # ffffffffc02075f8 <default_pmm_manager+0xb0>
ffffffffc0201e78:	06200593          	li	a1,98
ffffffffc0201e7c:	00005517          	auipc	a0,0x5
ffffffffc0201e80:	74450513          	addi	a0,a0,1860 # ffffffffc02075c0 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201e84:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201e86:	dfefe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201e8a <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201e8a:	715d                	addi	sp,sp,-80
ffffffffc0201e8c:	e0a2                	sd	s0,64(sp)
ffffffffc0201e8e:	fc26                	sd	s1,56(sp)
ffffffffc0201e90:	f84a                	sd	s2,48(sp)
ffffffffc0201e92:	f44e                	sd	s3,40(sp)
ffffffffc0201e94:	f052                	sd	s4,32(sp)
ffffffffc0201e96:	ec56                	sd	s5,24(sp)
ffffffffc0201e98:	e486                	sd	ra,72(sp)
ffffffffc0201e9a:	842a                	mv	s0,a0
ffffffffc0201e9c:	000aa497          	auipc	s1,0xaa
ffffffffc0201ea0:	6d448493          	addi	s1,s1,1748 # ffffffffc02ac570 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201ea4:	4985                	li	s3,1
ffffffffc0201ea6:	000aaa17          	auipc	s4,0xaa
ffffffffc0201eaa:	682a0a13          	addi	s4,s4,1666 # ffffffffc02ac528 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201eae:	0005091b          	sext.w	s2,a0
ffffffffc0201eb2:	000aaa97          	auipc	s5,0xaa
ffffffffc0201eb6:	7b6a8a93          	addi	s5,s5,1974 # ffffffffc02ac668 <check_mm_struct>
ffffffffc0201eba:	a00d                	j	ffffffffc0201edc <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201ebc:	609c                	ld	a5,0(s1)
ffffffffc0201ebe:	6f9c                	ld	a5,24(a5)
ffffffffc0201ec0:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201ec2:	4601                	li	a2,0
ffffffffc0201ec4:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201ec6:	ed0d                	bnez	a0,ffffffffc0201f00 <alloc_pages+0x76>
ffffffffc0201ec8:	0289ec63          	bltu	s3,s0,ffffffffc0201f00 <alloc_pages+0x76>
ffffffffc0201ecc:	000a2783          	lw	a5,0(s4)
ffffffffc0201ed0:	2781                	sext.w	a5,a5
ffffffffc0201ed2:	c79d                	beqz	a5,ffffffffc0201f00 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201ed4:	000ab503          	ld	a0,0(s5)
ffffffffc0201ed8:	517010ef          	jal	ra,ffffffffc0203bee <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201edc:	100027f3          	csrr	a5,sstatus
ffffffffc0201ee0:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201ee2:	8522                	mv	a0,s0
ffffffffc0201ee4:	dfe1                	beqz	a5,ffffffffc0201ebc <alloc_pages+0x32>
        intr_disable();
ffffffffc0201ee6:	f74fe0ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc0201eea:	609c                	ld	a5,0(s1)
ffffffffc0201eec:	8522                	mv	a0,s0
ffffffffc0201eee:	6f9c                	ld	a5,24(a5)
ffffffffc0201ef0:	9782                	jalr	a5
ffffffffc0201ef2:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201ef4:	f60fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0201ef8:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0201efa:	4601                	li	a2,0
ffffffffc0201efc:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201efe:	d569                	beqz	a0,ffffffffc0201ec8 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201f00:	60a6                	ld	ra,72(sp)
ffffffffc0201f02:	6406                	ld	s0,64(sp)
ffffffffc0201f04:	74e2                	ld	s1,56(sp)
ffffffffc0201f06:	7942                	ld	s2,48(sp)
ffffffffc0201f08:	79a2                	ld	s3,40(sp)
ffffffffc0201f0a:	7a02                	ld	s4,32(sp)
ffffffffc0201f0c:	6ae2                	ld	s5,24(sp)
ffffffffc0201f0e:	6161                	addi	sp,sp,80
ffffffffc0201f10:	8082                	ret

ffffffffc0201f12 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f12:	100027f3          	csrr	a5,sstatus
ffffffffc0201f16:	8b89                	andi	a5,a5,2
ffffffffc0201f18:	eb89                	bnez	a5,ffffffffc0201f2a <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201f1a:	000aa797          	auipc	a5,0xaa
ffffffffc0201f1e:	65678793          	addi	a5,a5,1622 # ffffffffc02ac570 <pmm_manager>
ffffffffc0201f22:	639c                	ld	a5,0(a5)
ffffffffc0201f24:	0207b303          	ld	t1,32(a5)
ffffffffc0201f28:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201f2a:	1101                	addi	sp,sp,-32
ffffffffc0201f2c:	ec06                	sd	ra,24(sp)
ffffffffc0201f2e:	e822                	sd	s0,16(sp)
ffffffffc0201f30:	e426                	sd	s1,8(sp)
ffffffffc0201f32:	842a                	mv	s0,a0
ffffffffc0201f34:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201f36:	f24fe0ef          	jal	ra,ffffffffc020065a <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201f3a:	000aa797          	auipc	a5,0xaa
ffffffffc0201f3e:	63678793          	addi	a5,a5,1590 # ffffffffc02ac570 <pmm_manager>
ffffffffc0201f42:	639c                	ld	a5,0(a5)
ffffffffc0201f44:	85a6                	mv	a1,s1
ffffffffc0201f46:	8522                	mv	a0,s0
ffffffffc0201f48:	739c                	ld	a5,32(a5)
ffffffffc0201f4a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201f4c:	6442                	ld	s0,16(sp)
ffffffffc0201f4e:	60e2                	ld	ra,24(sp)
ffffffffc0201f50:	64a2                	ld	s1,8(sp)
ffffffffc0201f52:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201f54:	f00fe06f          	j	ffffffffc0200654 <intr_enable>

ffffffffc0201f58 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f58:	100027f3          	csrr	a5,sstatus
ffffffffc0201f5c:	8b89                	andi	a5,a5,2
ffffffffc0201f5e:	eb89                	bnez	a5,ffffffffc0201f70 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f60:	000aa797          	auipc	a5,0xaa
ffffffffc0201f64:	61078793          	addi	a5,a5,1552 # ffffffffc02ac570 <pmm_manager>
ffffffffc0201f68:	639c                	ld	a5,0(a5)
ffffffffc0201f6a:	0287b303          	ld	t1,40(a5)
ffffffffc0201f6e:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201f70:	1141                	addi	sp,sp,-16
ffffffffc0201f72:	e406                	sd	ra,8(sp)
ffffffffc0201f74:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201f76:	ee4fe0ef          	jal	ra,ffffffffc020065a <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f7a:	000aa797          	auipc	a5,0xaa
ffffffffc0201f7e:	5f678793          	addi	a5,a5,1526 # ffffffffc02ac570 <pmm_manager>
ffffffffc0201f82:	639c                	ld	a5,0(a5)
ffffffffc0201f84:	779c                	ld	a5,40(a5)
ffffffffc0201f86:	9782                	jalr	a5
ffffffffc0201f88:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201f8a:	ecafe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201f8e:	8522                	mv	a0,s0
ffffffffc0201f90:	60a2                	ld	ra,8(sp)
ffffffffc0201f92:	6402                	ld	s0,0(sp)
ffffffffc0201f94:	0141                	addi	sp,sp,16
ffffffffc0201f96:	8082                	ret

ffffffffc0201f98 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f98:	7139                	addi	sp,sp,-64
ffffffffc0201f9a:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201f9c:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201fa0:	1ff4f493          	andi	s1,s1,511
ffffffffc0201fa4:	048e                	slli	s1,s1,0x3
ffffffffc0201fa6:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201fa8:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201faa:	f04a                	sd	s2,32(sp)
ffffffffc0201fac:	ec4e                	sd	s3,24(sp)
ffffffffc0201fae:	e852                	sd	s4,16(sp)
ffffffffc0201fb0:	fc06                	sd	ra,56(sp)
ffffffffc0201fb2:	f822                	sd	s0,48(sp)
ffffffffc0201fb4:	e456                	sd	s5,8(sp)
ffffffffc0201fb6:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201fb8:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201fbc:	892e                	mv	s2,a1
ffffffffc0201fbe:	8a32                	mv	s4,a2
ffffffffc0201fc0:	000aa997          	auipc	s3,0xaa
ffffffffc0201fc4:	55898993          	addi	s3,s3,1368 # ffffffffc02ac518 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201fc8:	e7bd                	bnez	a5,ffffffffc0202036 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201fca:	12060c63          	beqz	a2,ffffffffc0202102 <get_pte+0x16a>
ffffffffc0201fce:	4505                	li	a0,1
ffffffffc0201fd0:	ebbff0ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc0201fd4:	842a                	mv	s0,a0
ffffffffc0201fd6:	12050663          	beqz	a0,ffffffffc0202102 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201fda:	000aab17          	auipc	s6,0xaa
ffffffffc0201fde:	5aeb0b13          	addi	s6,s6,1454 # ffffffffc02ac588 <pages>
ffffffffc0201fe2:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0201fe6:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201fe8:	000aa997          	auipc	s3,0xaa
ffffffffc0201fec:	53098993          	addi	s3,s3,1328 # ffffffffc02ac518 <npage>
    return page - pages + nbase;
ffffffffc0201ff0:	40a40533          	sub	a0,s0,a0
ffffffffc0201ff4:	00080ab7          	lui	s5,0x80
ffffffffc0201ff8:	8519                	srai	a0,a0,0x6
ffffffffc0201ffa:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0201ffe:	c01c                	sw	a5,0(s0)
ffffffffc0202000:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0202002:	9556                	add	a0,a0,s5
ffffffffc0202004:	83b1                	srli	a5,a5,0xc
ffffffffc0202006:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202008:	0532                	slli	a0,a0,0xc
ffffffffc020200a:	14e7f363          	bleu	a4,a5,ffffffffc0202150 <get_pte+0x1b8>
ffffffffc020200e:	000aa797          	auipc	a5,0xaa
ffffffffc0202012:	56a78793          	addi	a5,a5,1386 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0202016:	639c                	ld	a5,0(a5)
ffffffffc0202018:	6605                	lui	a2,0x1
ffffffffc020201a:	4581                	li	a1,0
ffffffffc020201c:	953e                	add	a0,a0,a5
ffffffffc020201e:	7ae040ef          	jal	ra,ffffffffc02067cc <memset>
    return page - pages + nbase;
ffffffffc0202022:	000b3683          	ld	a3,0(s6)
ffffffffc0202026:	40d406b3          	sub	a3,s0,a3
ffffffffc020202a:	8699                	srai	a3,a3,0x6
ffffffffc020202c:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020202e:	06aa                	slli	a3,a3,0xa
ffffffffc0202030:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202034:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202036:	77fd                	lui	a5,0xfffff
ffffffffc0202038:	068a                	slli	a3,a3,0x2
ffffffffc020203a:	0009b703          	ld	a4,0(s3)
ffffffffc020203e:	8efd                	and	a3,a3,a5
ffffffffc0202040:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202044:	0ce7f163          	bleu	a4,a5,ffffffffc0202106 <get_pte+0x16e>
ffffffffc0202048:	000aaa97          	auipc	s5,0xaa
ffffffffc020204c:	530a8a93          	addi	s5,s5,1328 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0202050:	000ab403          	ld	s0,0(s5)
ffffffffc0202054:	01595793          	srli	a5,s2,0x15
ffffffffc0202058:	1ff7f793          	andi	a5,a5,511
ffffffffc020205c:	96a2                	add	a3,a3,s0
ffffffffc020205e:	00379413          	slli	s0,a5,0x3
ffffffffc0202062:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0202064:	6014                	ld	a3,0(s0)
ffffffffc0202066:	0016f793          	andi	a5,a3,1
ffffffffc020206a:	e3ad                	bnez	a5,ffffffffc02020cc <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc020206c:	080a0b63          	beqz	s4,ffffffffc0202102 <get_pte+0x16a>
ffffffffc0202070:	4505                	li	a0,1
ffffffffc0202072:	e19ff0ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc0202076:	84aa                	mv	s1,a0
ffffffffc0202078:	c549                	beqz	a0,ffffffffc0202102 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc020207a:	000aab17          	auipc	s6,0xaa
ffffffffc020207e:	50eb0b13          	addi	s6,s6,1294 # ffffffffc02ac588 <pages>
ffffffffc0202082:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0202086:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc0202088:	00080a37          	lui	s4,0x80
ffffffffc020208c:	40a48533          	sub	a0,s1,a0
ffffffffc0202090:	8519                	srai	a0,a0,0x6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202092:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0202096:	c09c                	sw	a5,0(s1)
ffffffffc0202098:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc020209a:	9552                	add	a0,a0,s4
ffffffffc020209c:	83b1                	srli	a5,a5,0xc
ffffffffc020209e:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02020a0:	0532                	slli	a0,a0,0xc
ffffffffc02020a2:	08e7fa63          	bleu	a4,a5,ffffffffc0202136 <get_pte+0x19e>
ffffffffc02020a6:	000ab783          	ld	a5,0(s5)
ffffffffc02020aa:	6605                	lui	a2,0x1
ffffffffc02020ac:	4581                	li	a1,0
ffffffffc02020ae:	953e                	add	a0,a0,a5
ffffffffc02020b0:	71c040ef          	jal	ra,ffffffffc02067cc <memset>
    return page - pages + nbase;
ffffffffc02020b4:	000b3683          	ld	a3,0(s6)
ffffffffc02020b8:	40d486b3          	sub	a3,s1,a3
ffffffffc02020bc:	8699                	srai	a3,a3,0x6
ffffffffc02020be:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02020c0:	06aa                	slli	a3,a3,0xa
ffffffffc02020c2:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02020c6:	e014                	sd	a3,0(s0)
ffffffffc02020c8:	0009b703          	ld	a4,0(s3)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02020cc:	068a                	slli	a3,a3,0x2
ffffffffc02020ce:	757d                	lui	a0,0xfffff
ffffffffc02020d0:	8ee9                	and	a3,a3,a0
ffffffffc02020d2:	00c6d793          	srli	a5,a3,0xc
ffffffffc02020d6:	04e7f463          	bleu	a4,a5,ffffffffc020211e <get_pte+0x186>
ffffffffc02020da:	000ab503          	ld	a0,0(s5)
ffffffffc02020de:	00c95793          	srli	a5,s2,0xc
ffffffffc02020e2:	1ff7f793          	andi	a5,a5,511
ffffffffc02020e6:	96aa                	add	a3,a3,a0
ffffffffc02020e8:	00379513          	slli	a0,a5,0x3
ffffffffc02020ec:	9536                	add	a0,a0,a3
}
ffffffffc02020ee:	70e2                	ld	ra,56(sp)
ffffffffc02020f0:	7442                	ld	s0,48(sp)
ffffffffc02020f2:	74a2                	ld	s1,40(sp)
ffffffffc02020f4:	7902                	ld	s2,32(sp)
ffffffffc02020f6:	69e2                	ld	s3,24(sp)
ffffffffc02020f8:	6a42                	ld	s4,16(sp)
ffffffffc02020fa:	6aa2                	ld	s5,8(sp)
ffffffffc02020fc:	6b02                	ld	s6,0(sp)
ffffffffc02020fe:	6121                	addi	sp,sp,64
ffffffffc0202100:	8082                	ret
            return NULL;
ffffffffc0202102:	4501                	li	a0,0
ffffffffc0202104:	b7ed                	j	ffffffffc02020ee <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202106:	00005617          	auipc	a2,0x5
ffffffffc020210a:	49260613          	addi	a2,a2,1170 # ffffffffc0207598 <default_pmm_manager+0x50>
ffffffffc020210e:	0e300593          	li	a1,227
ffffffffc0202112:	00005517          	auipc	a0,0x5
ffffffffc0202116:	5f650513          	addi	a0,a0,1526 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc020211a:	b6afe0ef          	jal	ra,ffffffffc0200484 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020211e:	00005617          	auipc	a2,0x5
ffffffffc0202122:	47a60613          	addi	a2,a2,1146 # ffffffffc0207598 <default_pmm_manager+0x50>
ffffffffc0202126:	0ee00593          	li	a1,238
ffffffffc020212a:	00005517          	auipc	a0,0x5
ffffffffc020212e:	5de50513          	addi	a0,a0,1502 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202132:	b52fe0ef          	jal	ra,ffffffffc0200484 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202136:	86aa                	mv	a3,a0
ffffffffc0202138:	00005617          	auipc	a2,0x5
ffffffffc020213c:	46060613          	addi	a2,a2,1120 # ffffffffc0207598 <default_pmm_manager+0x50>
ffffffffc0202140:	0eb00593          	li	a1,235
ffffffffc0202144:	00005517          	auipc	a0,0x5
ffffffffc0202148:	5c450513          	addi	a0,a0,1476 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc020214c:	b38fe0ef          	jal	ra,ffffffffc0200484 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202150:	86aa                	mv	a3,a0
ffffffffc0202152:	00005617          	auipc	a2,0x5
ffffffffc0202156:	44660613          	addi	a2,a2,1094 # ffffffffc0207598 <default_pmm_manager+0x50>
ffffffffc020215a:	0df00593          	li	a1,223
ffffffffc020215e:	00005517          	auipc	a0,0x5
ffffffffc0202162:	5aa50513          	addi	a0,a0,1450 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202166:	b1efe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020216a <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020216a:	1141                	addi	sp,sp,-16
ffffffffc020216c:	e022                	sd	s0,0(sp)
ffffffffc020216e:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202170:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202172:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202174:	e25ff0ef          	jal	ra,ffffffffc0201f98 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0202178:	c011                	beqz	s0,ffffffffc020217c <get_page+0x12>
        *ptep_store = ptep;
ffffffffc020217a:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020217c:	c129                	beqz	a0,ffffffffc02021be <get_page+0x54>
ffffffffc020217e:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202180:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202182:	0017f713          	andi	a4,a5,1
ffffffffc0202186:	e709                	bnez	a4,ffffffffc0202190 <get_page+0x26>
}
ffffffffc0202188:	60a2                	ld	ra,8(sp)
ffffffffc020218a:	6402                	ld	s0,0(sp)
ffffffffc020218c:	0141                	addi	sp,sp,16
ffffffffc020218e:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202190:	000aa717          	auipc	a4,0xaa
ffffffffc0202194:	38870713          	addi	a4,a4,904 # ffffffffc02ac518 <npage>
ffffffffc0202198:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc020219a:	078a                	slli	a5,a5,0x2
ffffffffc020219c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020219e:	02e7f563          	bleu	a4,a5,ffffffffc02021c8 <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc02021a2:	000aa717          	auipc	a4,0xaa
ffffffffc02021a6:	3e670713          	addi	a4,a4,998 # ffffffffc02ac588 <pages>
ffffffffc02021aa:	6308                	ld	a0,0(a4)
ffffffffc02021ac:	60a2                	ld	ra,8(sp)
ffffffffc02021ae:	6402                	ld	s0,0(sp)
ffffffffc02021b0:	fff80737          	lui	a4,0xfff80
ffffffffc02021b4:	97ba                	add	a5,a5,a4
ffffffffc02021b6:	079a                	slli	a5,a5,0x6
ffffffffc02021b8:	953e                	add	a0,a0,a5
ffffffffc02021ba:	0141                	addi	sp,sp,16
ffffffffc02021bc:	8082                	ret
ffffffffc02021be:	60a2                	ld	ra,8(sp)
ffffffffc02021c0:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc02021c2:	4501                	li	a0,0
}
ffffffffc02021c4:	0141                	addi	sp,sp,16
ffffffffc02021c6:	8082                	ret
ffffffffc02021c8:	ca7ff0ef          	jal	ra,ffffffffc0201e6e <pa2page.part.4>

ffffffffc02021cc <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02021cc:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02021ce:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02021d2:	ec86                	sd	ra,88(sp)
ffffffffc02021d4:	e8a2                	sd	s0,80(sp)
ffffffffc02021d6:	e4a6                	sd	s1,72(sp)
ffffffffc02021d8:	e0ca                	sd	s2,64(sp)
ffffffffc02021da:	fc4e                	sd	s3,56(sp)
ffffffffc02021dc:	f852                	sd	s4,48(sp)
ffffffffc02021de:	f456                	sd	s5,40(sp)
ffffffffc02021e0:	f05a                	sd	s6,32(sp)
ffffffffc02021e2:	ec5e                	sd	s7,24(sp)
ffffffffc02021e4:	e862                	sd	s8,16(sp)
ffffffffc02021e6:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02021e8:	03479713          	slli	a4,a5,0x34
ffffffffc02021ec:	eb71                	bnez	a4,ffffffffc02022c0 <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc02021ee:	002007b7          	lui	a5,0x200
ffffffffc02021f2:	842e                	mv	s0,a1
ffffffffc02021f4:	0af5e663          	bltu	a1,a5,ffffffffc02022a0 <unmap_range+0xd4>
ffffffffc02021f8:	8932                	mv	s2,a2
ffffffffc02021fa:	0ac5f363          	bleu	a2,a1,ffffffffc02022a0 <unmap_range+0xd4>
ffffffffc02021fe:	4785                	li	a5,1
ffffffffc0202200:	07fe                	slli	a5,a5,0x1f
ffffffffc0202202:	08c7ef63          	bltu	a5,a2,ffffffffc02022a0 <unmap_range+0xd4>
ffffffffc0202206:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0202208:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc020220a:	000aac97          	auipc	s9,0xaa
ffffffffc020220e:	30ec8c93          	addi	s9,s9,782 # ffffffffc02ac518 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202212:	000aac17          	auipc	s8,0xaa
ffffffffc0202216:	376c0c13          	addi	s8,s8,886 # ffffffffc02ac588 <pages>
ffffffffc020221a:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020221e:	00200b37          	lui	s6,0x200
ffffffffc0202222:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0202226:	4601                	li	a2,0
ffffffffc0202228:	85a2                	mv	a1,s0
ffffffffc020222a:	854e                	mv	a0,s3
ffffffffc020222c:	d6dff0ef          	jal	ra,ffffffffc0201f98 <get_pte>
ffffffffc0202230:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc0202232:	cd21                	beqz	a0,ffffffffc020228a <unmap_range+0xbe>
        if (*ptep != 0) {
ffffffffc0202234:	611c                	ld	a5,0(a0)
ffffffffc0202236:	e38d                	bnez	a5,ffffffffc0202258 <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc0202238:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc020223a:	ff2466e3          	bltu	s0,s2,ffffffffc0202226 <unmap_range+0x5a>
}
ffffffffc020223e:	60e6                	ld	ra,88(sp)
ffffffffc0202240:	6446                	ld	s0,80(sp)
ffffffffc0202242:	64a6                	ld	s1,72(sp)
ffffffffc0202244:	6906                	ld	s2,64(sp)
ffffffffc0202246:	79e2                	ld	s3,56(sp)
ffffffffc0202248:	7a42                	ld	s4,48(sp)
ffffffffc020224a:	7aa2                	ld	s5,40(sp)
ffffffffc020224c:	7b02                	ld	s6,32(sp)
ffffffffc020224e:	6be2                	ld	s7,24(sp)
ffffffffc0202250:	6c42                	ld	s8,16(sp)
ffffffffc0202252:	6ca2                	ld	s9,8(sp)
ffffffffc0202254:	6125                	addi	sp,sp,96
ffffffffc0202256:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202258:	0017f713          	andi	a4,a5,1
ffffffffc020225c:	df71                	beqz	a4,ffffffffc0202238 <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc020225e:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202262:	078a                	slli	a5,a5,0x2
ffffffffc0202264:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202266:	06e7fd63          	bleu	a4,a5,ffffffffc02022e0 <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc020226a:	000c3503          	ld	a0,0(s8)
ffffffffc020226e:	97de                	add	a5,a5,s7
ffffffffc0202270:	079a                	slli	a5,a5,0x6
ffffffffc0202272:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202274:	411c                	lw	a5,0(a0)
ffffffffc0202276:	fff7871b          	addiw	a4,a5,-1
ffffffffc020227a:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020227c:	cf11                	beqz	a4,ffffffffc0202298 <unmap_range+0xcc>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc020227e:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202282:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0202286:	9452                	add	s0,s0,s4
ffffffffc0202288:	bf4d                	j	ffffffffc020223a <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020228a:	945a                	add	s0,s0,s6
ffffffffc020228c:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0202290:	d45d                	beqz	s0,ffffffffc020223e <unmap_range+0x72>
ffffffffc0202292:	f9246ae3          	bltu	s0,s2,ffffffffc0202226 <unmap_range+0x5a>
ffffffffc0202296:	b765                	j	ffffffffc020223e <unmap_range+0x72>
            free_page(page);
ffffffffc0202298:	4585                	li	a1,1
ffffffffc020229a:	c79ff0ef          	jal	ra,ffffffffc0201f12 <free_pages>
ffffffffc020229e:	b7c5                	j	ffffffffc020227e <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc02022a0:	00006697          	auipc	a3,0x6
ffffffffc02022a4:	a1068693          	addi	a3,a3,-1520 # ffffffffc0207cb0 <default_pmm_manager+0x768>
ffffffffc02022a8:	00005617          	auipc	a2,0x5
ffffffffc02022ac:	b5860613          	addi	a2,a2,-1192 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02022b0:	11000593          	li	a1,272
ffffffffc02022b4:	00005517          	auipc	a0,0x5
ffffffffc02022b8:	45450513          	addi	a0,a0,1108 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc02022bc:	9c8fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022c0:	00006697          	auipc	a3,0x6
ffffffffc02022c4:	9c068693          	addi	a3,a3,-1600 # ffffffffc0207c80 <default_pmm_manager+0x738>
ffffffffc02022c8:	00005617          	auipc	a2,0x5
ffffffffc02022cc:	b3860613          	addi	a2,a2,-1224 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02022d0:	10f00593          	li	a1,271
ffffffffc02022d4:	00005517          	auipc	a0,0x5
ffffffffc02022d8:	43450513          	addi	a0,a0,1076 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc02022dc:	9a8fe0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc02022e0:	b8fff0ef          	jal	ra,ffffffffc0201e6e <pa2page.part.4>

ffffffffc02022e4 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02022e4:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022e6:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02022ea:	fc86                	sd	ra,120(sp)
ffffffffc02022ec:	f8a2                	sd	s0,112(sp)
ffffffffc02022ee:	f4a6                	sd	s1,104(sp)
ffffffffc02022f0:	f0ca                	sd	s2,96(sp)
ffffffffc02022f2:	ecce                	sd	s3,88(sp)
ffffffffc02022f4:	e8d2                	sd	s4,80(sp)
ffffffffc02022f6:	e4d6                	sd	s5,72(sp)
ffffffffc02022f8:	e0da                	sd	s6,64(sp)
ffffffffc02022fa:	fc5e                	sd	s7,56(sp)
ffffffffc02022fc:	f862                	sd	s8,48(sp)
ffffffffc02022fe:	f466                	sd	s9,40(sp)
ffffffffc0202300:	f06a                	sd	s10,32(sp)
ffffffffc0202302:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202304:	03479713          	slli	a4,a5,0x34
ffffffffc0202308:	1c071163          	bnez	a4,ffffffffc02024ca <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc020230c:	002007b7          	lui	a5,0x200
ffffffffc0202310:	20f5e563          	bltu	a1,a5,ffffffffc020251a <exit_range+0x236>
ffffffffc0202314:	8b32                	mv	s6,a2
ffffffffc0202316:	20c5f263          	bleu	a2,a1,ffffffffc020251a <exit_range+0x236>
ffffffffc020231a:	4785                	li	a5,1
ffffffffc020231c:	07fe                	slli	a5,a5,0x1f
ffffffffc020231e:	1ec7ee63          	bltu	a5,a2,ffffffffc020251a <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0202322:	c00009b7          	lui	s3,0xc0000
ffffffffc0202326:	400007b7          	lui	a5,0x40000
ffffffffc020232a:	0135f9b3          	and	s3,a1,s3
ffffffffc020232e:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0202330:	c0000337          	lui	t1,0xc0000
ffffffffc0202334:	00698933          	add	s2,s3,t1
ffffffffc0202338:	01e95913          	srli	s2,s2,0x1e
ffffffffc020233c:	1ff97913          	andi	s2,s2,511
ffffffffc0202340:	8e2a                	mv	t3,a0
ffffffffc0202342:	090e                	slli	s2,s2,0x3
ffffffffc0202344:	9972                	add	s2,s2,t3
ffffffffc0202346:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc020234a:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc020234e:	5dfd                	li	s11,-1
        if (pde1&PTE_V){
ffffffffc0202350:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202354:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc0202356:	000aad17          	auipc	s10,0xaa
ffffffffc020235a:	1c2d0d13          	addi	s10,s10,450 # ffffffffc02ac518 <npage>
    return KADDR(page2pa(page));
ffffffffc020235e:	00cddd93          	srli	s11,s11,0xc
ffffffffc0202362:	000aa717          	auipc	a4,0xaa
ffffffffc0202366:	21670713          	addi	a4,a4,534 # ffffffffc02ac578 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc020236a:	000aae97          	auipc	t4,0xaa
ffffffffc020236e:	21ee8e93          	addi	t4,t4,542 # ffffffffc02ac588 <pages>
        if (pde1&PTE_V){
ffffffffc0202372:	e79d                	bnez	a5,ffffffffc02023a0 <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc0202374:	12098963          	beqz	s3,ffffffffc02024a6 <exit_range+0x1c2>
ffffffffc0202378:	400007b7          	lui	a5,0x40000
ffffffffc020237c:	84ce                	mv	s1,s3
ffffffffc020237e:	97ce                	add	a5,a5,s3
ffffffffc0202380:	1369f363          	bleu	s6,s3,ffffffffc02024a6 <exit_range+0x1c2>
ffffffffc0202384:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0202386:	00698933          	add	s2,s3,t1
ffffffffc020238a:	01e95913          	srli	s2,s2,0x1e
ffffffffc020238e:	1ff97913          	andi	s2,s2,511
ffffffffc0202392:	090e                	slli	s2,s2,0x3
ffffffffc0202394:	9972                	add	s2,s2,t3
ffffffffc0202396:	00093b83          	ld	s7,0(s2)
        if (pde1&PTE_V){
ffffffffc020239a:	001bf793          	andi	a5,s7,1
ffffffffc020239e:	dbf9                	beqz	a5,ffffffffc0202374 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc02023a0:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02023a4:	0b8a                	slli	s7,s7,0x2
ffffffffc02023a6:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023aa:	14fbfc63          	bleu	a5,s7,ffffffffc0202502 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc02023ae:	fff80ab7          	lui	s5,0xfff80
ffffffffc02023b2:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc02023b4:	000806b7          	lui	a3,0x80
ffffffffc02023b8:	96d6                	add	a3,a3,s5
ffffffffc02023ba:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc02023be:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc02023c2:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc02023c4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02023c6:	12f67263          	bleu	a5,a2,ffffffffc02024ea <exit_range+0x206>
ffffffffc02023ca:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc02023ce:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc02023d0:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc02023d4:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc02023d6:	00080837          	lui	a6,0x80
ffffffffc02023da:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc02023dc:	00200c37          	lui	s8,0x200
ffffffffc02023e0:	a801                	j	ffffffffc02023f0 <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc02023e2:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc02023e4:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02023e6:	c0d9                	beqz	s1,ffffffffc020246c <exit_range+0x188>
ffffffffc02023e8:	0934f263          	bleu	s3,s1,ffffffffc020246c <exit_range+0x188>
ffffffffc02023ec:	0d64fc63          	bleu	s6,s1,ffffffffc02024c4 <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02023f0:	0154d413          	srli	s0,s1,0x15
ffffffffc02023f4:	1ff47413          	andi	s0,s0,511
ffffffffc02023f8:	040e                	slli	s0,s0,0x3
ffffffffc02023fa:	9452                	add	s0,s0,s4
ffffffffc02023fc:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc02023fe:	0017f693          	andi	a3,a5,1
ffffffffc0202402:	d2e5                	beqz	a3,ffffffffc02023e2 <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc0202404:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202408:	00279513          	slli	a0,a5,0x2
ffffffffc020240c:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc020240e:	0eb57a63          	bleu	a1,a0,ffffffffc0202502 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202412:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc0202414:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc0202418:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc020241c:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc020241e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202420:	0cb7f563          	bleu	a1,a5,ffffffffc02024ea <exit_range+0x206>
ffffffffc0202424:	631c                	ld	a5,0(a4)
ffffffffc0202426:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0202428:	015685b3          	add	a1,a3,s5
                        if (pt[i]&PTE_V){
ffffffffc020242c:	629c                	ld	a5,0(a3)
ffffffffc020242e:	8b85                	andi	a5,a5,1
ffffffffc0202430:	fbd5                	bnez	a5,ffffffffc02023e4 <exit_range+0x100>
ffffffffc0202432:	06a1                	addi	a3,a3,8
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0202434:	fed59ce3          	bne	a1,a3,ffffffffc020242c <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc0202438:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc020243c:	4585                	li	a1,1
ffffffffc020243e:	e072                	sd	t3,0(sp)
ffffffffc0202440:	953e                	add	a0,a0,a5
ffffffffc0202442:	ad1ff0ef          	jal	ra,ffffffffc0201f12 <free_pages>
                d0start += PTSIZE;
ffffffffc0202446:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202448:	00043023          	sd	zero,0(s0)
ffffffffc020244c:	000aae97          	auipc	t4,0xaa
ffffffffc0202450:	13ce8e93          	addi	t4,t4,316 # ffffffffc02ac588 <pages>
ffffffffc0202454:	6e02                	ld	t3,0(sp)
ffffffffc0202456:	c0000337          	lui	t1,0xc0000
ffffffffc020245a:	fff808b7          	lui	a7,0xfff80
ffffffffc020245e:	00080837          	lui	a6,0x80
ffffffffc0202462:	000aa717          	auipc	a4,0xaa
ffffffffc0202466:	11670713          	addi	a4,a4,278 # ffffffffc02ac578 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc020246a:	fcbd                	bnez	s1,ffffffffc02023e8 <exit_range+0x104>
            if (free_pd0) {
ffffffffc020246c:	f00c84e3          	beqz	s9,ffffffffc0202374 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0202470:	000d3783          	ld	a5,0(s10)
ffffffffc0202474:	e072                	sd	t3,0(sp)
ffffffffc0202476:	08fbf663          	bleu	a5,s7,ffffffffc0202502 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc020247a:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc020247e:	67a2                	ld	a5,8(sp)
ffffffffc0202480:	4585                	li	a1,1
ffffffffc0202482:	953e                	add	a0,a0,a5
ffffffffc0202484:	a8fff0ef          	jal	ra,ffffffffc0201f12 <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202488:	00093023          	sd	zero,0(s2)
ffffffffc020248c:	000aa717          	auipc	a4,0xaa
ffffffffc0202490:	0ec70713          	addi	a4,a4,236 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0202494:	c0000337          	lui	t1,0xc0000
ffffffffc0202498:	6e02                	ld	t3,0(sp)
ffffffffc020249a:	000aae97          	auipc	t4,0xaa
ffffffffc020249e:	0eee8e93          	addi	t4,t4,238 # ffffffffc02ac588 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc02024a2:	ec099be3          	bnez	s3,ffffffffc0202378 <exit_range+0x94>
}
ffffffffc02024a6:	70e6                	ld	ra,120(sp)
ffffffffc02024a8:	7446                	ld	s0,112(sp)
ffffffffc02024aa:	74a6                	ld	s1,104(sp)
ffffffffc02024ac:	7906                	ld	s2,96(sp)
ffffffffc02024ae:	69e6                	ld	s3,88(sp)
ffffffffc02024b0:	6a46                	ld	s4,80(sp)
ffffffffc02024b2:	6aa6                	ld	s5,72(sp)
ffffffffc02024b4:	6b06                	ld	s6,64(sp)
ffffffffc02024b6:	7be2                	ld	s7,56(sp)
ffffffffc02024b8:	7c42                	ld	s8,48(sp)
ffffffffc02024ba:	7ca2                	ld	s9,40(sp)
ffffffffc02024bc:	7d02                	ld	s10,32(sp)
ffffffffc02024be:	6de2                	ld	s11,24(sp)
ffffffffc02024c0:	6109                	addi	sp,sp,128
ffffffffc02024c2:	8082                	ret
            if (free_pd0) {
ffffffffc02024c4:	ea0c8ae3          	beqz	s9,ffffffffc0202378 <exit_range+0x94>
ffffffffc02024c8:	b765                	j	ffffffffc0202470 <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02024ca:	00005697          	auipc	a3,0x5
ffffffffc02024ce:	7b668693          	addi	a3,a3,1974 # ffffffffc0207c80 <default_pmm_manager+0x738>
ffffffffc02024d2:	00005617          	auipc	a2,0x5
ffffffffc02024d6:	92e60613          	addi	a2,a2,-1746 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02024da:	12000593          	li	a1,288
ffffffffc02024de:	00005517          	auipc	a0,0x5
ffffffffc02024e2:	22a50513          	addi	a0,a0,554 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc02024e6:	f9ffd0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc02024ea:	00005617          	auipc	a2,0x5
ffffffffc02024ee:	0ae60613          	addi	a2,a2,174 # ffffffffc0207598 <default_pmm_manager+0x50>
ffffffffc02024f2:	06900593          	li	a1,105
ffffffffc02024f6:	00005517          	auipc	a0,0x5
ffffffffc02024fa:	0ca50513          	addi	a0,a0,202 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc02024fe:	f87fd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202502:	00005617          	auipc	a2,0x5
ffffffffc0202506:	0f660613          	addi	a2,a2,246 # ffffffffc02075f8 <default_pmm_manager+0xb0>
ffffffffc020250a:	06200593          	li	a1,98
ffffffffc020250e:	00005517          	auipc	a0,0x5
ffffffffc0202512:	0b250513          	addi	a0,a0,178 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0202516:	f6ffd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020251a:	00005697          	auipc	a3,0x5
ffffffffc020251e:	79668693          	addi	a3,a3,1942 # ffffffffc0207cb0 <default_pmm_manager+0x768>
ffffffffc0202522:	00005617          	auipc	a2,0x5
ffffffffc0202526:	8de60613          	addi	a2,a2,-1826 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020252a:	12100593          	li	a1,289
ffffffffc020252e:	00005517          	auipc	a0,0x5
ffffffffc0202532:	1da50513          	addi	a0,a0,474 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202536:	f4ffd0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020253a <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc020253a:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020253c:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc020253e:	e426                	sd	s1,8(sp)
ffffffffc0202540:	ec06                	sd	ra,24(sp)
ffffffffc0202542:	e822                	sd	s0,16(sp)
ffffffffc0202544:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202546:	a53ff0ef          	jal	ra,ffffffffc0201f98 <get_pte>
    if (ptep != NULL) {
ffffffffc020254a:	c511                	beqz	a0,ffffffffc0202556 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc020254c:	611c                	ld	a5,0(a0)
ffffffffc020254e:	842a                	mv	s0,a0
ffffffffc0202550:	0017f713          	andi	a4,a5,1
ffffffffc0202554:	e711                	bnez	a4,ffffffffc0202560 <page_remove+0x26>
}
ffffffffc0202556:	60e2                	ld	ra,24(sp)
ffffffffc0202558:	6442                	ld	s0,16(sp)
ffffffffc020255a:	64a2                	ld	s1,8(sp)
ffffffffc020255c:	6105                	addi	sp,sp,32
ffffffffc020255e:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202560:	000aa717          	auipc	a4,0xaa
ffffffffc0202564:	fb870713          	addi	a4,a4,-72 # ffffffffc02ac518 <npage>
ffffffffc0202568:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc020256a:	078a                	slli	a5,a5,0x2
ffffffffc020256c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020256e:	02e7fe63          	bleu	a4,a5,ffffffffc02025aa <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0202572:	000aa717          	auipc	a4,0xaa
ffffffffc0202576:	01670713          	addi	a4,a4,22 # ffffffffc02ac588 <pages>
ffffffffc020257a:	6308                	ld	a0,0(a4)
ffffffffc020257c:	fff80737          	lui	a4,0xfff80
ffffffffc0202580:	97ba                	add	a5,a5,a4
ffffffffc0202582:	079a                	slli	a5,a5,0x6
ffffffffc0202584:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202586:	411c                	lw	a5,0(a0)
ffffffffc0202588:	fff7871b          	addiw	a4,a5,-1
ffffffffc020258c:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020258e:	cb11                	beqz	a4,ffffffffc02025a2 <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202590:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202594:	12048073          	sfence.vma	s1
}
ffffffffc0202598:	60e2                	ld	ra,24(sp)
ffffffffc020259a:	6442                	ld	s0,16(sp)
ffffffffc020259c:	64a2                	ld	s1,8(sp)
ffffffffc020259e:	6105                	addi	sp,sp,32
ffffffffc02025a0:	8082                	ret
            free_page(page);
ffffffffc02025a2:	4585                	li	a1,1
ffffffffc02025a4:	96fff0ef          	jal	ra,ffffffffc0201f12 <free_pages>
ffffffffc02025a8:	b7e5                	j	ffffffffc0202590 <page_remove+0x56>
ffffffffc02025aa:	8c5ff0ef          	jal	ra,ffffffffc0201e6e <pa2page.part.4>

ffffffffc02025ae <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02025ae:	7179                	addi	sp,sp,-48
ffffffffc02025b0:	e44e                	sd	s3,8(sp)
ffffffffc02025b2:	89b2                	mv	s3,a2
ffffffffc02025b4:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02025b6:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02025b8:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02025ba:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02025bc:	ec26                	sd	s1,24(sp)
ffffffffc02025be:	f406                	sd	ra,40(sp)
ffffffffc02025c0:	e84a                	sd	s2,16(sp)
ffffffffc02025c2:	e052                	sd	s4,0(sp)
ffffffffc02025c4:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02025c6:	9d3ff0ef          	jal	ra,ffffffffc0201f98 <get_pte>
    if (ptep == NULL) {
ffffffffc02025ca:	cd49                	beqz	a0,ffffffffc0202664 <page_insert+0xb6>
    page->ref += 1;
ffffffffc02025cc:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc02025ce:	611c                	ld	a5,0(a0)
ffffffffc02025d0:	892a                	mv	s2,a0
ffffffffc02025d2:	0016871b          	addiw	a4,a3,1
ffffffffc02025d6:	c018                	sw	a4,0(s0)
ffffffffc02025d8:	0017f713          	andi	a4,a5,1
ffffffffc02025dc:	ef05                	bnez	a4,ffffffffc0202614 <page_insert+0x66>
ffffffffc02025de:	000aa797          	auipc	a5,0xaa
ffffffffc02025e2:	faa78793          	addi	a5,a5,-86 # ffffffffc02ac588 <pages>
ffffffffc02025e6:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc02025e8:	8c19                	sub	s0,s0,a4
ffffffffc02025ea:	000806b7          	lui	a3,0x80
ffffffffc02025ee:	8419                	srai	s0,s0,0x6
ffffffffc02025f0:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02025f2:	042a                	slli	s0,s0,0xa
ffffffffc02025f4:	8c45                	or	s0,s0,s1
ffffffffc02025f6:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02025fa:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025fe:	12098073          	sfence.vma	s3
    return 0;
ffffffffc0202602:	4501                	li	a0,0
}
ffffffffc0202604:	70a2                	ld	ra,40(sp)
ffffffffc0202606:	7402                	ld	s0,32(sp)
ffffffffc0202608:	64e2                	ld	s1,24(sp)
ffffffffc020260a:	6942                	ld	s2,16(sp)
ffffffffc020260c:	69a2                	ld	s3,8(sp)
ffffffffc020260e:	6a02                	ld	s4,0(sp)
ffffffffc0202610:	6145                	addi	sp,sp,48
ffffffffc0202612:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202614:	000aa717          	auipc	a4,0xaa
ffffffffc0202618:	f0470713          	addi	a4,a4,-252 # ffffffffc02ac518 <npage>
ffffffffc020261c:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc020261e:	078a                	slli	a5,a5,0x2
ffffffffc0202620:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202622:	04e7f363          	bleu	a4,a5,ffffffffc0202668 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc0202626:	000aaa17          	auipc	s4,0xaa
ffffffffc020262a:	f62a0a13          	addi	s4,s4,-158 # ffffffffc02ac588 <pages>
ffffffffc020262e:	000a3703          	ld	a4,0(s4)
ffffffffc0202632:	fff80537          	lui	a0,0xfff80
ffffffffc0202636:	953e                	add	a0,a0,a5
ffffffffc0202638:	051a                	slli	a0,a0,0x6
ffffffffc020263a:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc020263c:	00a40a63          	beq	s0,a0,ffffffffc0202650 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc0202640:	411c                	lw	a5,0(a0)
ffffffffc0202642:	fff7869b          	addiw	a3,a5,-1
ffffffffc0202646:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0202648:	c691                	beqz	a3,ffffffffc0202654 <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020264a:	12098073          	sfence.vma	s3
ffffffffc020264e:	bf69                	j	ffffffffc02025e8 <page_insert+0x3a>
ffffffffc0202650:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202652:	bf59                	j	ffffffffc02025e8 <page_insert+0x3a>
            free_page(page);
ffffffffc0202654:	4585                	li	a1,1
ffffffffc0202656:	8bdff0ef          	jal	ra,ffffffffc0201f12 <free_pages>
ffffffffc020265a:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020265e:	12098073          	sfence.vma	s3
ffffffffc0202662:	b759                	j	ffffffffc02025e8 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0202664:	5571                	li	a0,-4
ffffffffc0202666:	bf79                	j	ffffffffc0202604 <page_insert+0x56>
ffffffffc0202668:	807ff0ef          	jal	ra,ffffffffc0201e6e <pa2page.part.4>

ffffffffc020266c <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc020266c:	00005797          	auipc	a5,0x5
ffffffffc0202670:	edc78793          	addi	a5,a5,-292 # ffffffffc0207548 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202674:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202676:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202678:	00005517          	auipc	a0,0x5
ffffffffc020267c:	0b850513          	addi	a0,a0,184 # ffffffffc0207730 <default_pmm_manager+0x1e8>
void pmm_init(void) {
ffffffffc0202680:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202682:	000aa717          	auipc	a4,0xaa
ffffffffc0202686:	eef73723          	sd	a5,-274(a4) # ffffffffc02ac570 <pmm_manager>
void pmm_init(void) {
ffffffffc020268a:	e0a2                	sd	s0,64(sp)
ffffffffc020268c:	fc26                	sd	s1,56(sp)
ffffffffc020268e:	f84a                	sd	s2,48(sp)
ffffffffc0202690:	f44e                	sd	s3,40(sp)
ffffffffc0202692:	f052                	sd	s4,32(sp)
ffffffffc0202694:	ec56                	sd	s5,24(sp)
ffffffffc0202696:	e85a                	sd	s6,16(sp)
ffffffffc0202698:	e45e                	sd	s7,8(sp)
ffffffffc020269a:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020269c:	000aa417          	auipc	s0,0xaa
ffffffffc02026a0:	ed440413          	addi	s0,s0,-300 # ffffffffc02ac570 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02026a4:	aebfd0ef          	jal	ra,ffffffffc020018e <cprintf>
    pmm_manager->init();
ffffffffc02026a8:	601c                	ld	a5,0(s0)
ffffffffc02026aa:	000aa497          	auipc	s1,0xaa
ffffffffc02026ae:	e6e48493          	addi	s1,s1,-402 # ffffffffc02ac518 <npage>
ffffffffc02026b2:	000aa917          	auipc	s2,0xaa
ffffffffc02026b6:	ed690913          	addi	s2,s2,-298 # ffffffffc02ac588 <pages>
ffffffffc02026ba:	679c                	ld	a5,8(a5)
ffffffffc02026bc:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02026be:	57f5                	li	a5,-3
ffffffffc02026c0:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02026c2:	00005517          	auipc	a0,0x5
ffffffffc02026c6:	08650513          	addi	a0,a0,134 # ffffffffc0207748 <default_pmm_manager+0x200>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02026ca:	000aa717          	auipc	a4,0xaa
ffffffffc02026ce:	eaf73723          	sd	a5,-338(a4) # ffffffffc02ac578 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02026d2:	abdfd0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02026d6:	46c5                	li	a3,17
ffffffffc02026d8:	06ee                	slli	a3,a3,0x1b
ffffffffc02026da:	40100613          	li	a2,1025
ffffffffc02026de:	16fd                	addi	a3,a3,-1
ffffffffc02026e0:	0656                	slli	a2,a2,0x15
ffffffffc02026e2:	07e005b7          	lui	a1,0x7e00
ffffffffc02026e6:	00005517          	auipc	a0,0x5
ffffffffc02026ea:	07a50513          	addi	a0,a0,122 # ffffffffc0207760 <default_pmm_manager+0x218>
ffffffffc02026ee:	aa1fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026f2:	777d                	lui	a4,0xfffff
ffffffffc02026f4:	000ab797          	auipc	a5,0xab
ffffffffc02026f8:	f8b78793          	addi	a5,a5,-117 # ffffffffc02ad67f <end+0xfff>
ffffffffc02026fc:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02026fe:	00088737          	lui	a4,0x88
ffffffffc0202702:	000aa697          	auipc	a3,0xaa
ffffffffc0202706:	e0e6bb23          	sd	a4,-490(a3) # ffffffffc02ac518 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020270a:	000aa717          	auipc	a4,0xaa
ffffffffc020270e:	e6f73f23          	sd	a5,-386(a4) # ffffffffc02ac588 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202712:	4701                	li	a4,0
ffffffffc0202714:	4685                	li	a3,1
ffffffffc0202716:	fff80837          	lui	a6,0xfff80
ffffffffc020271a:	a019                	j	ffffffffc0202720 <pmm_init+0xb4>
ffffffffc020271c:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0202720:	00671613          	slli	a2,a4,0x6
ffffffffc0202724:	97b2                	add	a5,a5,a2
ffffffffc0202726:	07a1                	addi	a5,a5,8
ffffffffc0202728:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020272c:	6090                	ld	a2,0(s1)
ffffffffc020272e:	0705                	addi	a4,a4,1
ffffffffc0202730:	010607b3          	add	a5,a2,a6
ffffffffc0202734:	fef764e3          	bltu	a4,a5,ffffffffc020271c <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202738:	00093503          	ld	a0,0(s2)
ffffffffc020273c:	fe0007b7          	lui	a5,0xfe000
ffffffffc0202740:	00661693          	slli	a3,a2,0x6
ffffffffc0202744:	97aa                	add	a5,a5,a0
ffffffffc0202746:	96be                	add	a3,a3,a5
ffffffffc0202748:	c02007b7          	lui	a5,0xc0200
ffffffffc020274c:	7af6ed63          	bltu	a3,a5,ffffffffc0202f06 <pmm_init+0x89a>
ffffffffc0202750:	000aa997          	auipc	s3,0xaa
ffffffffc0202754:	e2898993          	addi	s3,s3,-472 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0202758:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc020275c:	47c5                	li	a5,17
ffffffffc020275e:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202760:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0202762:	02f6f763          	bleu	a5,a3,ffffffffc0202790 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202766:	6585                	lui	a1,0x1
ffffffffc0202768:	15fd                	addi	a1,a1,-1
ffffffffc020276a:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc020276c:	00c6d713          	srli	a4,a3,0xc
ffffffffc0202770:	48c77a63          	bleu	a2,a4,ffffffffc0202c04 <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc0202774:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202776:	75fd                	lui	a1,0xfffff
ffffffffc0202778:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc020277a:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc020277c:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020277e:	40d786b3          	sub	a3,a5,a3
ffffffffc0202782:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0202784:	00c6d593          	srli	a1,a3,0xc
ffffffffc0202788:	953a                	add	a0,a0,a4
ffffffffc020278a:	9602                	jalr	a2
ffffffffc020278c:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202790:	00005517          	auipc	a0,0x5
ffffffffc0202794:	ff850513          	addi	a0,a0,-8 # ffffffffc0207788 <default_pmm_manager+0x240>
ffffffffc0202798:	9f7fd0ef          	jal	ra,ffffffffc020018e <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020279c:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020279e:	000aa417          	auipc	s0,0xaa
ffffffffc02027a2:	d7240413          	addi	s0,s0,-654 # ffffffffc02ac510 <boot_pgdir>
    pmm_manager->check();
ffffffffc02027a6:	7b9c                	ld	a5,48(a5)
ffffffffc02027a8:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02027aa:	00005517          	auipc	a0,0x5
ffffffffc02027ae:	ff650513          	addi	a0,a0,-10 # ffffffffc02077a0 <default_pmm_manager+0x258>
ffffffffc02027b2:	9ddfd0ef          	jal	ra,ffffffffc020018e <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02027b6:	00009697          	auipc	a3,0x9
ffffffffc02027ba:	84a68693          	addi	a3,a3,-1974 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc02027be:	000aa797          	auipc	a5,0xaa
ffffffffc02027c2:	d4d7b923          	sd	a3,-686(a5) # ffffffffc02ac510 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02027c6:	c02007b7          	lui	a5,0xc0200
ffffffffc02027ca:	10f6eae3          	bltu	a3,a5,ffffffffc02030de <pmm_init+0xa72>
ffffffffc02027ce:	0009b783          	ld	a5,0(s3)
ffffffffc02027d2:	8e9d                	sub	a3,a3,a5
ffffffffc02027d4:	000aa797          	auipc	a5,0xaa
ffffffffc02027d8:	dad7b623          	sd	a3,-596(a5) # ffffffffc02ac580 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc02027dc:	f7cff0ef          	jal	ra,ffffffffc0201f58 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02027e0:	6098                	ld	a4,0(s1)
ffffffffc02027e2:	c80007b7          	lui	a5,0xc8000
ffffffffc02027e6:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc02027e8:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02027ea:	0ce7eae3          	bltu	a5,a4,ffffffffc02030be <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02027ee:	6008                	ld	a0,0(s0)
ffffffffc02027f0:	44050463          	beqz	a0,ffffffffc0202c38 <pmm_init+0x5cc>
ffffffffc02027f4:	6785                	lui	a5,0x1
ffffffffc02027f6:	17fd                	addi	a5,a5,-1
ffffffffc02027f8:	8fe9                	and	a5,a5,a0
ffffffffc02027fa:	2781                	sext.w	a5,a5
ffffffffc02027fc:	42079e63          	bnez	a5,ffffffffc0202c38 <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202800:	4601                	li	a2,0
ffffffffc0202802:	4581                	li	a1,0
ffffffffc0202804:	967ff0ef          	jal	ra,ffffffffc020216a <get_page>
ffffffffc0202808:	78051b63          	bnez	a0,ffffffffc0202f9e <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc020280c:	4505                	li	a0,1
ffffffffc020280e:	e7cff0ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc0202812:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202814:	6008                	ld	a0,0(s0)
ffffffffc0202816:	4681                	li	a3,0
ffffffffc0202818:	4601                	li	a2,0
ffffffffc020281a:	85d6                	mv	a1,s5
ffffffffc020281c:	d93ff0ef          	jal	ra,ffffffffc02025ae <page_insert>
ffffffffc0202820:	7a051f63          	bnez	a0,ffffffffc0202fde <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202824:	6008                	ld	a0,0(s0)
ffffffffc0202826:	4601                	li	a2,0
ffffffffc0202828:	4581                	li	a1,0
ffffffffc020282a:	f6eff0ef          	jal	ra,ffffffffc0201f98 <get_pte>
ffffffffc020282e:	78050863          	beqz	a0,ffffffffc0202fbe <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc0202832:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202834:	0017f713          	andi	a4,a5,1
ffffffffc0202838:	3e070463          	beqz	a4,ffffffffc0202c20 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc020283c:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020283e:	078a                	slli	a5,a5,0x2
ffffffffc0202840:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202842:	3ce7f163          	bleu	a4,a5,ffffffffc0202c04 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202846:	00093683          	ld	a3,0(s2)
ffffffffc020284a:	fff80637          	lui	a2,0xfff80
ffffffffc020284e:	97b2                	add	a5,a5,a2
ffffffffc0202850:	079a                	slli	a5,a5,0x6
ffffffffc0202852:	97b6                	add	a5,a5,a3
ffffffffc0202854:	72fa9563          	bne	s5,a5,ffffffffc0202f7e <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc0202858:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
ffffffffc020285c:	4785                	li	a5,1
ffffffffc020285e:	70fb9063          	bne	s7,a5,ffffffffc0202f5e <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202862:	6008                	ld	a0,0(s0)
ffffffffc0202864:	76fd                	lui	a3,0xfffff
ffffffffc0202866:	611c                	ld	a5,0(a0)
ffffffffc0202868:	078a                	slli	a5,a5,0x2
ffffffffc020286a:	8ff5                	and	a5,a5,a3
ffffffffc020286c:	00c7d613          	srli	a2,a5,0xc
ffffffffc0202870:	66e67e63          	bleu	a4,a2,ffffffffc0202eec <pmm_init+0x880>
ffffffffc0202874:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202878:	97e2                	add	a5,a5,s8
ffffffffc020287a:	0007bb03          	ld	s6,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
ffffffffc020287e:	0b0a                	slli	s6,s6,0x2
ffffffffc0202880:	00db7b33          	and	s6,s6,a3
ffffffffc0202884:	00cb5793          	srli	a5,s6,0xc
ffffffffc0202888:	56e7f863          	bleu	a4,a5,ffffffffc0202df8 <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020288c:	4601                	li	a2,0
ffffffffc020288e:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202890:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202892:	f06ff0ef          	jal	ra,ffffffffc0201f98 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202896:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202898:	55651063          	bne	a0,s6,ffffffffc0202dd8 <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc020289c:	4505                	li	a0,1
ffffffffc020289e:	decff0ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc02028a2:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02028a4:	6008                	ld	a0,0(s0)
ffffffffc02028a6:	46d1                	li	a3,20
ffffffffc02028a8:	6605                	lui	a2,0x1
ffffffffc02028aa:	85da                	mv	a1,s6
ffffffffc02028ac:	d03ff0ef          	jal	ra,ffffffffc02025ae <page_insert>
ffffffffc02028b0:	50051463          	bnez	a0,ffffffffc0202db8 <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02028b4:	6008                	ld	a0,0(s0)
ffffffffc02028b6:	4601                	li	a2,0
ffffffffc02028b8:	6585                	lui	a1,0x1
ffffffffc02028ba:	edeff0ef          	jal	ra,ffffffffc0201f98 <get_pte>
ffffffffc02028be:	4c050d63          	beqz	a0,ffffffffc0202d98 <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc02028c2:	611c                	ld	a5,0(a0)
ffffffffc02028c4:	0107f713          	andi	a4,a5,16
ffffffffc02028c8:	4a070863          	beqz	a4,ffffffffc0202d78 <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc02028cc:	8b91                	andi	a5,a5,4
ffffffffc02028ce:	48078563          	beqz	a5,ffffffffc0202d58 <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02028d2:	6008                	ld	a0,0(s0)
ffffffffc02028d4:	611c                	ld	a5,0(a0)
ffffffffc02028d6:	8bc1                	andi	a5,a5,16
ffffffffc02028d8:	46078063          	beqz	a5,ffffffffc0202d38 <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc02028dc:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_exit_out_size+0x1f5578>
ffffffffc02028e0:	43779c63          	bne	a5,s7,ffffffffc0202d18 <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02028e4:	4681                	li	a3,0
ffffffffc02028e6:	6605                	lui	a2,0x1
ffffffffc02028e8:	85d6                	mv	a1,s5
ffffffffc02028ea:	cc5ff0ef          	jal	ra,ffffffffc02025ae <page_insert>
ffffffffc02028ee:	40051563          	bnez	a0,ffffffffc0202cf8 <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc02028f2:	000aa703          	lw	a4,0(s5)
ffffffffc02028f6:	4789                	li	a5,2
ffffffffc02028f8:	3ef71063          	bne	a4,a5,ffffffffc0202cd8 <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc02028fc:	000b2783          	lw	a5,0(s6)
ffffffffc0202900:	3a079c63          	bnez	a5,ffffffffc0202cb8 <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202904:	6008                	ld	a0,0(s0)
ffffffffc0202906:	4601                	li	a2,0
ffffffffc0202908:	6585                	lui	a1,0x1
ffffffffc020290a:	e8eff0ef          	jal	ra,ffffffffc0201f98 <get_pte>
ffffffffc020290e:	38050563          	beqz	a0,ffffffffc0202c98 <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc0202912:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202914:	00177793          	andi	a5,a4,1
ffffffffc0202918:	30078463          	beqz	a5,ffffffffc0202c20 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc020291c:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020291e:	00271793          	slli	a5,a4,0x2
ffffffffc0202922:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202924:	2ed7f063          	bleu	a3,a5,ffffffffc0202c04 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202928:	00093683          	ld	a3,0(s2)
ffffffffc020292c:	fff80637          	lui	a2,0xfff80
ffffffffc0202930:	97b2                	add	a5,a5,a2
ffffffffc0202932:	079a                	slli	a5,a5,0x6
ffffffffc0202934:	97b6                	add	a5,a5,a3
ffffffffc0202936:	32fa9163          	bne	s5,a5,ffffffffc0202c58 <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc020293a:	8b41                	andi	a4,a4,16
ffffffffc020293c:	70071163          	bnez	a4,ffffffffc020303e <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc0202940:	6008                	ld	a0,0(s0)
ffffffffc0202942:	4581                	li	a1,0
ffffffffc0202944:	bf7ff0ef          	jal	ra,ffffffffc020253a <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202948:	000aa703          	lw	a4,0(s5)
ffffffffc020294c:	4785                	li	a5,1
ffffffffc020294e:	6cf71863          	bne	a4,a5,ffffffffc020301e <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc0202952:	000b2783          	lw	a5,0(s6)
ffffffffc0202956:	6a079463          	bnez	a5,ffffffffc0202ffe <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc020295a:	6008                	ld	a0,0(s0)
ffffffffc020295c:	6585                	lui	a1,0x1
ffffffffc020295e:	bddff0ef          	jal	ra,ffffffffc020253a <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202962:	000aa783          	lw	a5,0(s5)
ffffffffc0202966:	50079363          	bnez	a5,ffffffffc0202e6c <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc020296a:	000b2783          	lw	a5,0(s6)
ffffffffc020296e:	4c079f63          	bnez	a5,ffffffffc0202e4c <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202972:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202976:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202978:	000ab783          	ld	a5,0(s5)
ffffffffc020297c:	078a                	slli	a5,a5,0x2
ffffffffc020297e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202980:	28c7f263          	bleu	a2,a5,ffffffffc0202c04 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202984:	fff80737          	lui	a4,0xfff80
ffffffffc0202988:	00093503          	ld	a0,0(s2)
ffffffffc020298c:	97ba                	add	a5,a5,a4
ffffffffc020298e:	079a                	slli	a5,a5,0x6
ffffffffc0202990:	00f50733          	add	a4,a0,a5
ffffffffc0202994:	4314                	lw	a3,0(a4)
ffffffffc0202996:	4705                	li	a4,1
ffffffffc0202998:	48e69a63          	bne	a3,a4,ffffffffc0202e2c <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc020299c:	8799                	srai	a5,a5,0x6
ffffffffc020299e:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc02029a2:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc02029a4:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc02029a6:	8331                	srli	a4,a4,0xc
ffffffffc02029a8:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc02029aa:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02029ac:	46c77363          	bleu	a2,a4,ffffffffc0202e12 <pmm_init+0x7a6>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02029b0:	0009b683          	ld	a3,0(s3)
ffffffffc02029b4:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc02029b6:	639c                	ld	a5,0(a5)
ffffffffc02029b8:	078a                	slli	a5,a5,0x2
ffffffffc02029ba:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02029bc:	24c7f463          	bleu	a2,a5,ffffffffc0202c04 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02029c0:	416787b3          	sub	a5,a5,s6
ffffffffc02029c4:	079a                	slli	a5,a5,0x6
ffffffffc02029c6:	953e                	add	a0,a0,a5
ffffffffc02029c8:	4585                	li	a1,1
ffffffffc02029ca:	d48ff0ef          	jal	ra,ffffffffc0201f12 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02029ce:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc02029d2:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02029d4:	078a                	slli	a5,a5,0x2
ffffffffc02029d6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02029d8:	22e7f663          	bleu	a4,a5,ffffffffc0202c04 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02029dc:	00093503          	ld	a0,0(s2)
ffffffffc02029e0:	416787b3          	sub	a5,a5,s6
ffffffffc02029e4:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02029e6:	953e                	add	a0,a0,a5
ffffffffc02029e8:	4585                	li	a1,1
ffffffffc02029ea:	d28ff0ef          	jal	ra,ffffffffc0201f12 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02029ee:	601c                	ld	a5,0(s0)
ffffffffc02029f0:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02029f4:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02029f8:	d60ff0ef          	jal	ra,ffffffffc0201f58 <nr_free_pages>
ffffffffc02029fc:	68aa1163          	bne	s4,a0,ffffffffc020307e <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202a00:	00005517          	auipc	a0,0x5
ffffffffc0202a04:	0b050513          	addi	a0,a0,176 # ffffffffc0207ab0 <default_pmm_manager+0x568>
ffffffffc0202a08:	f86fd0ef          	jal	ra,ffffffffc020018e <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0202a0c:	d4cff0ef          	jal	ra,ffffffffc0201f58 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202a10:	6098                	ld	a4,0(s1)
ffffffffc0202a12:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0202a16:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202a18:	00c71693          	slli	a3,a4,0xc
ffffffffc0202a1c:	18d7f563          	bleu	a3,a5,ffffffffc0202ba6 <pmm_init+0x53a>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202a20:	83b1                	srli	a5,a5,0xc
ffffffffc0202a22:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202a24:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202a28:	1ae7f163          	bleu	a4,a5,ffffffffc0202bca <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202a2c:	7bfd                	lui	s7,0xfffff
ffffffffc0202a2e:	6b05                	lui	s6,0x1
ffffffffc0202a30:	a029                	j	ffffffffc0202a3a <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202a32:	00cad713          	srli	a4,s5,0xc
ffffffffc0202a36:	18f77a63          	bleu	a5,a4,ffffffffc0202bca <pmm_init+0x55e>
ffffffffc0202a3a:	0009b583          	ld	a1,0(s3)
ffffffffc0202a3e:	4601                	li	a2,0
ffffffffc0202a40:	95d6                	add	a1,a1,s5
ffffffffc0202a42:	d56ff0ef          	jal	ra,ffffffffc0201f98 <get_pte>
ffffffffc0202a46:	16050263          	beqz	a0,ffffffffc0202baa <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202a4a:	611c                	ld	a5,0(a0)
ffffffffc0202a4c:	078a                	slli	a5,a5,0x2
ffffffffc0202a4e:	0177f7b3          	and	a5,a5,s7
ffffffffc0202a52:	19579963          	bne	a5,s5,ffffffffc0202be4 <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202a56:	609c                	ld	a5,0(s1)
ffffffffc0202a58:	9ada                	add	s5,s5,s6
ffffffffc0202a5a:	6008                	ld	a0,0(s0)
ffffffffc0202a5c:	00c79713          	slli	a4,a5,0xc
ffffffffc0202a60:	fceae9e3          	bltu	s5,a4,ffffffffc0202a32 <pmm_init+0x3c6>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0202a64:	611c                	ld	a5,0(a0)
ffffffffc0202a66:	62079c63          	bnez	a5,ffffffffc020309e <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc0202a6a:	4505                	li	a0,1
ffffffffc0202a6c:	c1eff0ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc0202a70:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202a72:	6008                	ld	a0,0(s0)
ffffffffc0202a74:	4699                	li	a3,6
ffffffffc0202a76:	10000613          	li	a2,256
ffffffffc0202a7a:	85d6                	mv	a1,s5
ffffffffc0202a7c:	b33ff0ef          	jal	ra,ffffffffc02025ae <page_insert>
ffffffffc0202a80:	1e051c63          	bnez	a0,ffffffffc0202c78 <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc0202a84:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0202a88:	4785                	li	a5,1
ffffffffc0202a8a:	44f71163          	bne	a4,a5,ffffffffc0202ecc <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202a8e:	6008                	ld	a0,0(s0)
ffffffffc0202a90:	6b05                	lui	s6,0x1
ffffffffc0202a92:	4699                	li	a3,6
ffffffffc0202a94:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x8478>
ffffffffc0202a98:	85d6                	mv	a1,s5
ffffffffc0202a9a:	b15ff0ef          	jal	ra,ffffffffc02025ae <page_insert>
ffffffffc0202a9e:	40051763          	bnez	a0,ffffffffc0202eac <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc0202aa2:	000aa703          	lw	a4,0(s5)
ffffffffc0202aa6:	4789                	li	a5,2
ffffffffc0202aa8:	3ef71263          	bne	a4,a5,ffffffffc0202e8c <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202aac:	00005597          	auipc	a1,0x5
ffffffffc0202ab0:	13c58593          	addi	a1,a1,316 # ffffffffc0207be8 <default_pmm_manager+0x6a0>
ffffffffc0202ab4:	10000513          	li	a0,256
ffffffffc0202ab8:	4bb030ef          	jal	ra,ffffffffc0206772 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202abc:	100b0593          	addi	a1,s6,256
ffffffffc0202ac0:	10000513          	li	a0,256
ffffffffc0202ac4:	4c1030ef          	jal	ra,ffffffffc0206784 <strcmp>
ffffffffc0202ac8:	44051b63          	bnez	a0,ffffffffc0202f1e <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc0202acc:	00093683          	ld	a3,0(s2)
ffffffffc0202ad0:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202ad4:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0202ad6:	40da86b3          	sub	a3,s5,a3
ffffffffc0202ada:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202adc:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202ade:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202ae0:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0202ae4:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ae8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202aea:	10f77f63          	bleu	a5,a4,ffffffffc0202c08 <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202aee:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202af2:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202af6:	96be                	add	a3,a3,a5
ffffffffc0202af8:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fd52a80>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202afc:	433030ef          	jal	ra,ffffffffc020672e <strlen>
ffffffffc0202b00:	54051f63          	bnez	a0,ffffffffc020305e <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202b04:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202b08:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b0a:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd52980>
ffffffffc0202b0e:	068a                	slli	a3,a3,0x2
ffffffffc0202b10:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b12:	0ef6f963          	bleu	a5,a3,ffffffffc0202c04 <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc0202b16:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b1a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202b1c:	0efb7663          	bleu	a5,s6,ffffffffc0202c08 <pmm_init+0x59c>
ffffffffc0202b20:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202b24:	4585                	li	a1,1
ffffffffc0202b26:	8556                	mv	a0,s5
ffffffffc0202b28:	99b6                	add	s3,s3,a3
ffffffffc0202b2a:	be8ff0ef          	jal	ra,ffffffffc0201f12 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b2e:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202b32:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b34:	078a                	slli	a5,a5,0x2
ffffffffc0202b36:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b38:	0ce7f663          	bleu	a4,a5,ffffffffc0202c04 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b3c:	00093503          	ld	a0,0(s2)
ffffffffc0202b40:	fff809b7          	lui	s3,0xfff80
ffffffffc0202b44:	97ce                	add	a5,a5,s3
ffffffffc0202b46:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202b48:	953e                	add	a0,a0,a5
ffffffffc0202b4a:	4585                	li	a1,1
ffffffffc0202b4c:	bc6ff0ef          	jal	ra,ffffffffc0201f12 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b50:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0202b54:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b56:	078a                	slli	a5,a5,0x2
ffffffffc0202b58:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b5a:	0ae7f563          	bleu	a4,a5,ffffffffc0202c04 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b5e:	00093503          	ld	a0,0(s2)
ffffffffc0202b62:	97ce                	add	a5,a5,s3
ffffffffc0202b64:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202b66:	953e                	add	a0,a0,a5
ffffffffc0202b68:	4585                	li	a1,1
ffffffffc0202b6a:	ba8ff0ef          	jal	ra,ffffffffc0201f12 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202b6e:	601c                	ld	a5,0(s0)
ffffffffc0202b70:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0202b74:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202b78:	be0ff0ef          	jal	ra,ffffffffc0201f58 <nr_free_pages>
ffffffffc0202b7c:	3caa1163          	bne	s4,a0,ffffffffc0202f3e <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202b80:	00005517          	auipc	a0,0x5
ffffffffc0202b84:	0e050513          	addi	a0,a0,224 # ffffffffc0207c60 <default_pmm_manager+0x718>
ffffffffc0202b88:	e06fd0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0202b8c:	6406                	ld	s0,64(sp)
ffffffffc0202b8e:	60a6                	ld	ra,72(sp)
ffffffffc0202b90:	74e2                	ld	s1,56(sp)
ffffffffc0202b92:	7942                	ld	s2,48(sp)
ffffffffc0202b94:	79a2                	ld	s3,40(sp)
ffffffffc0202b96:	7a02                	ld	s4,32(sp)
ffffffffc0202b98:	6ae2                	ld	s5,24(sp)
ffffffffc0202b9a:	6b42                	ld	s6,16(sp)
ffffffffc0202b9c:	6ba2                	ld	s7,8(sp)
ffffffffc0202b9e:	6c02                	ld	s8,0(sp)
ffffffffc0202ba0:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0202ba2:	8c8ff06f          	j	ffffffffc0201c6a <kmalloc_init>
ffffffffc0202ba6:	6008                	ld	a0,0(s0)
ffffffffc0202ba8:	bd75                	j	ffffffffc0202a64 <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202baa:	00005697          	auipc	a3,0x5
ffffffffc0202bae:	f2668693          	addi	a3,a3,-218 # ffffffffc0207ad0 <default_pmm_manager+0x588>
ffffffffc0202bb2:	00004617          	auipc	a2,0x4
ffffffffc0202bb6:	24e60613          	addi	a2,a2,590 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202bba:	25800593          	li	a1,600
ffffffffc0202bbe:	00005517          	auipc	a0,0x5
ffffffffc0202bc2:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202bc6:	8bffd0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0202bca:	86d6                	mv	a3,s5
ffffffffc0202bcc:	00005617          	auipc	a2,0x5
ffffffffc0202bd0:	9cc60613          	addi	a2,a2,-1588 # ffffffffc0207598 <default_pmm_manager+0x50>
ffffffffc0202bd4:	25800593          	li	a1,600
ffffffffc0202bd8:	00005517          	auipc	a0,0x5
ffffffffc0202bdc:	b3050513          	addi	a0,a0,-1232 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202be0:	8a5fd0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202be4:	00005697          	auipc	a3,0x5
ffffffffc0202be8:	f2c68693          	addi	a3,a3,-212 # ffffffffc0207b10 <default_pmm_manager+0x5c8>
ffffffffc0202bec:	00004617          	auipc	a2,0x4
ffffffffc0202bf0:	21460613          	addi	a2,a2,532 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202bf4:	25900593          	li	a1,601
ffffffffc0202bf8:	00005517          	auipc	a0,0x5
ffffffffc0202bfc:	b1050513          	addi	a0,a0,-1264 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202c00:	885fd0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0202c04:	a6aff0ef          	jal	ra,ffffffffc0201e6e <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0202c08:	00005617          	auipc	a2,0x5
ffffffffc0202c0c:	99060613          	addi	a2,a2,-1648 # ffffffffc0207598 <default_pmm_manager+0x50>
ffffffffc0202c10:	06900593          	li	a1,105
ffffffffc0202c14:	00005517          	auipc	a0,0x5
ffffffffc0202c18:	9ac50513          	addi	a0,a0,-1620 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0202c1c:	869fd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202c20:	00005617          	auipc	a2,0x5
ffffffffc0202c24:	c8060613          	addi	a2,a2,-896 # ffffffffc02078a0 <default_pmm_manager+0x358>
ffffffffc0202c28:	07400593          	li	a1,116
ffffffffc0202c2c:	00005517          	auipc	a0,0x5
ffffffffc0202c30:	99450513          	addi	a0,a0,-1644 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0202c34:	851fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202c38:	00005697          	auipc	a3,0x5
ffffffffc0202c3c:	ba868693          	addi	a3,a3,-1112 # ffffffffc02077e0 <default_pmm_manager+0x298>
ffffffffc0202c40:	00004617          	auipc	a2,0x4
ffffffffc0202c44:	1c060613          	addi	a2,a2,448 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202c48:	21c00593          	li	a1,540
ffffffffc0202c4c:	00005517          	auipc	a0,0x5
ffffffffc0202c50:	abc50513          	addi	a0,a0,-1348 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202c54:	831fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202c58:	00005697          	auipc	a3,0x5
ffffffffc0202c5c:	c7068693          	addi	a3,a3,-912 # ffffffffc02078c8 <default_pmm_manager+0x380>
ffffffffc0202c60:	00004617          	auipc	a2,0x4
ffffffffc0202c64:	1a060613          	addi	a2,a2,416 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202c68:	23800593          	li	a1,568
ffffffffc0202c6c:	00005517          	auipc	a0,0x5
ffffffffc0202c70:	a9c50513          	addi	a0,a0,-1380 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202c74:	811fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202c78:	00005697          	auipc	a3,0x5
ffffffffc0202c7c:	ec868693          	addi	a3,a3,-312 # ffffffffc0207b40 <default_pmm_manager+0x5f8>
ffffffffc0202c80:	00004617          	auipc	a2,0x4
ffffffffc0202c84:	18060613          	addi	a2,a2,384 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202c88:	26100593          	li	a1,609
ffffffffc0202c8c:	00005517          	auipc	a0,0x5
ffffffffc0202c90:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202c94:	ff0fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202c98:	00005697          	auipc	a3,0x5
ffffffffc0202c9c:	cc068693          	addi	a3,a3,-832 # ffffffffc0207958 <default_pmm_manager+0x410>
ffffffffc0202ca0:	00004617          	auipc	a2,0x4
ffffffffc0202ca4:	16060613          	addi	a2,a2,352 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202ca8:	23700593          	li	a1,567
ffffffffc0202cac:	00005517          	auipc	a0,0x5
ffffffffc0202cb0:	a5c50513          	addi	a0,a0,-1444 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202cb4:	fd0fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202cb8:	00005697          	auipc	a3,0x5
ffffffffc0202cbc:	d6868693          	addi	a3,a3,-664 # ffffffffc0207a20 <default_pmm_manager+0x4d8>
ffffffffc0202cc0:	00004617          	auipc	a2,0x4
ffffffffc0202cc4:	14060613          	addi	a2,a2,320 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202cc8:	23600593          	li	a1,566
ffffffffc0202ccc:	00005517          	auipc	a0,0x5
ffffffffc0202cd0:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202cd4:	fb0fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202cd8:	00005697          	auipc	a3,0x5
ffffffffc0202cdc:	d3068693          	addi	a3,a3,-720 # ffffffffc0207a08 <default_pmm_manager+0x4c0>
ffffffffc0202ce0:	00004617          	auipc	a2,0x4
ffffffffc0202ce4:	12060613          	addi	a2,a2,288 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202ce8:	23500593          	li	a1,565
ffffffffc0202cec:	00005517          	auipc	a0,0x5
ffffffffc0202cf0:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202cf4:	f90fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202cf8:	00005697          	auipc	a3,0x5
ffffffffc0202cfc:	ce068693          	addi	a3,a3,-800 # ffffffffc02079d8 <default_pmm_manager+0x490>
ffffffffc0202d00:	00004617          	auipc	a2,0x4
ffffffffc0202d04:	10060613          	addi	a2,a2,256 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202d08:	23400593          	li	a1,564
ffffffffc0202d0c:	00005517          	auipc	a0,0x5
ffffffffc0202d10:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202d14:	f70fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202d18:	00005697          	auipc	a3,0x5
ffffffffc0202d1c:	ca868693          	addi	a3,a3,-856 # ffffffffc02079c0 <default_pmm_manager+0x478>
ffffffffc0202d20:	00004617          	auipc	a2,0x4
ffffffffc0202d24:	0e060613          	addi	a2,a2,224 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202d28:	23200593          	li	a1,562
ffffffffc0202d2c:	00005517          	auipc	a0,0x5
ffffffffc0202d30:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202d34:	f50fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202d38:	00005697          	auipc	a3,0x5
ffffffffc0202d3c:	c7068693          	addi	a3,a3,-912 # ffffffffc02079a8 <default_pmm_manager+0x460>
ffffffffc0202d40:	00004617          	auipc	a2,0x4
ffffffffc0202d44:	0c060613          	addi	a2,a2,192 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202d48:	23100593          	li	a1,561
ffffffffc0202d4c:	00005517          	auipc	a0,0x5
ffffffffc0202d50:	9bc50513          	addi	a0,a0,-1604 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202d54:	f30fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202d58:	00005697          	auipc	a3,0x5
ffffffffc0202d5c:	c4068693          	addi	a3,a3,-960 # ffffffffc0207998 <default_pmm_manager+0x450>
ffffffffc0202d60:	00004617          	auipc	a2,0x4
ffffffffc0202d64:	0a060613          	addi	a2,a2,160 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202d68:	23000593          	li	a1,560
ffffffffc0202d6c:	00005517          	auipc	a0,0x5
ffffffffc0202d70:	99c50513          	addi	a0,a0,-1636 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202d74:	f10fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202d78:	00005697          	auipc	a3,0x5
ffffffffc0202d7c:	c1068693          	addi	a3,a3,-1008 # ffffffffc0207988 <default_pmm_manager+0x440>
ffffffffc0202d80:	00004617          	auipc	a2,0x4
ffffffffc0202d84:	08060613          	addi	a2,a2,128 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202d88:	22f00593          	li	a1,559
ffffffffc0202d8c:	00005517          	auipc	a0,0x5
ffffffffc0202d90:	97c50513          	addi	a0,a0,-1668 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202d94:	ef0fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202d98:	00005697          	auipc	a3,0x5
ffffffffc0202d9c:	bc068693          	addi	a3,a3,-1088 # ffffffffc0207958 <default_pmm_manager+0x410>
ffffffffc0202da0:	00004617          	auipc	a2,0x4
ffffffffc0202da4:	06060613          	addi	a2,a2,96 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202da8:	22e00593          	li	a1,558
ffffffffc0202dac:	00005517          	auipc	a0,0x5
ffffffffc0202db0:	95c50513          	addi	a0,a0,-1700 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202db4:	ed0fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202db8:	00005697          	auipc	a3,0x5
ffffffffc0202dbc:	b6868693          	addi	a3,a3,-1176 # ffffffffc0207920 <default_pmm_manager+0x3d8>
ffffffffc0202dc0:	00004617          	auipc	a2,0x4
ffffffffc0202dc4:	04060613          	addi	a2,a2,64 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202dc8:	22d00593          	li	a1,557
ffffffffc0202dcc:	00005517          	auipc	a0,0x5
ffffffffc0202dd0:	93c50513          	addi	a0,a0,-1732 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202dd4:	eb0fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202dd8:	00005697          	auipc	a3,0x5
ffffffffc0202ddc:	b2068693          	addi	a3,a3,-1248 # ffffffffc02078f8 <default_pmm_manager+0x3b0>
ffffffffc0202de0:	00004617          	auipc	a2,0x4
ffffffffc0202de4:	02060613          	addi	a2,a2,32 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202de8:	22a00593          	li	a1,554
ffffffffc0202dec:	00005517          	auipc	a0,0x5
ffffffffc0202df0:	91c50513          	addi	a0,a0,-1764 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202df4:	e90fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202df8:	86da                	mv	a3,s6
ffffffffc0202dfa:	00004617          	auipc	a2,0x4
ffffffffc0202dfe:	79e60613          	addi	a2,a2,1950 # ffffffffc0207598 <default_pmm_manager+0x50>
ffffffffc0202e02:	22900593          	li	a1,553
ffffffffc0202e06:	00005517          	auipc	a0,0x5
ffffffffc0202e0a:	90250513          	addi	a0,a0,-1790 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202e0e:	e76fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202e12:	86be                	mv	a3,a5
ffffffffc0202e14:	00004617          	auipc	a2,0x4
ffffffffc0202e18:	78460613          	addi	a2,a2,1924 # ffffffffc0207598 <default_pmm_manager+0x50>
ffffffffc0202e1c:	06900593          	li	a1,105
ffffffffc0202e20:	00004517          	auipc	a0,0x4
ffffffffc0202e24:	7a050513          	addi	a0,a0,1952 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0202e28:	e5cfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202e2c:	00005697          	auipc	a3,0x5
ffffffffc0202e30:	c3c68693          	addi	a3,a3,-964 # ffffffffc0207a68 <default_pmm_manager+0x520>
ffffffffc0202e34:	00004617          	auipc	a2,0x4
ffffffffc0202e38:	fcc60613          	addi	a2,a2,-52 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202e3c:	24300593          	li	a1,579
ffffffffc0202e40:	00005517          	auipc	a0,0x5
ffffffffc0202e44:	8c850513          	addi	a0,a0,-1848 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202e48:	e3cfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202e4c:	00005697          	auipc	a3,0x5
ffffffffc0202e50:	bd468693          	addi	a3,a3,-1068 # ffffffffc0207a20 <default_pmm_manager+0x4d8>
ffffffffc0202e54:	00004617          	auipc	a2,0x4
ffffffffc0202e58:	fac60613          	addi	a2,a2,-84 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202e5c:	24100593          	li	a1,577
ffffffffc0202e60:	00005517          	auipc	a0,0x5
ffffffffc0202e64:	8a850513          	addi	a0,a0,-1880 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202e68:	e1cfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202e6c:	00005697          	auipc	a3,0x5
ffffffffc0202e70:	be468693          	addi	a3,a3,-1052 # ffffffffc0207a50 <default_pmm_manager+0x508>
ffffffffc0202e74:	00004617          	auipc	a2,0x4
ffffffffc0202e78:	f8c60613          	addi	a2,a2,-116 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202e7c:	24000593          	li	a1,576
ffffffffc0202e80:	00005517          	auipc	a0,0x5
ffffffffc0202e84:	88850513          	addi	a0,a0,-1912 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202e88:	dfcfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202e8c:	00005697          	auipc	a3,0x5
ffffffffc0202e90:	d4468693          	addi	a3,a3,-700 # ffffffffc0207bd0 <default_pmm_manager+0x688>
ffffffffc0202e94:	00004617          	auipc	a2,0x4
ffffffffc0202e98:	f6c60613          	addi	a2,a2,-148 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202e9c:	26400593          	li	a1,612
ffffffffc0202ea0:	00005517          	auipc	a0,0x5
ffffffffc0202ea4:	86850513          	addi	a0,a0,-1944 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202ea8:	ddcfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202eac:	00005697          	auipc	a3,0x5
ffffffffc0202eb0:	ce468693          	addi	a3,a3,-796 # ffffffffc0207b90 <default_pmm_manager+0x648>
ffffffffc0202eb4:	00004617          	auipc	a2,0x4
ffffffffc0202eb8:	f4c60613          	addi	a2,a2,-180 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202ebc:	26300593          	li	a1,611
ffffffffc0202ec0:	00005517          	auipc	a0,0x5
ffffffffc0202ec4:	84850513          	addi	a0,a0,-1976 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202ec8:	dbcfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202ecc:	00005697          	auipc	a3,0x5
ffffffffc0202ed0:	cac68693          	addi	a3,a3,-852 # ffffffffc0207b78 <default_pmm_manager+0x630>
ffffffffc0202ed4:	00004617          	auipc	a2,0x4
ffffffffc0202ed8:	f2c60613          	addi	a2,a2,-212 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202edc:	26200593          	li	a1,610
ffffffffc0202ee0:	00005517          	auipc	a0,0x5
ffffffffc0202ee4:	82850513          	addi	a0,a0,-2008 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202ee8:	d9cfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202eec:	86be                	mv	a3,a5
ffffffffc0202eee:	00004617          	auipc	a2,0x4
ffffffffc0202ef2:	6aa60613          	addi	a2,a2,1706 # ffffffffc0207598 <default_pmm_manager+0x50>
ffffffffc0202ef6:	22800593          	li	a1,552
ffffffffc0202efa:	00005517          	auipc	a0,0x5
ffffffffc0202efe:	80e50513          	addi	a0,a0,-2034 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202f02:	d82fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202f06:	00004617          	auipc	a2,0x4
ffffffffc0202f0a:	6ca60613          	addi	a2,a2,1738 # ffffffffc02075d0 <default_pmm_manager+0x88>
ffffffffc0202f0e:	07f00593          	li	a1,127
ffffffffc0202f12:	00004517          	auipc	a0,0x4
ffffffffc0202f16:	7f650513          	addi	a0,a0,2038 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202f1a:	d6afd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202f1e:	00005697          	auipc	a3,0x5
ffffffffc0202f22:	ce268693          	addi	a3,a3,-798 # ffffffffc0207c00 <default_pmm_manager+0x6b8>
ffffffffc0202f26:	00004617          	auipc	a2,0x4
ffffffffc0202f2a:	eda60613          	addi	a2,a2,-294 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202f2e:	26800593          	li	a1,616
ffffffffc0202f32:	00004517          	auipc	a0,0x4
ffffffffc0202f36:	7d650513          	addi	a0,a0,2006 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202f3a:	d4afd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202f3e:	00005697          	auipc	a3,0x5
ffffffffc0202f42:	b5268693          	addi	a3,a3,-1198 # ffffffffc0207a90 <default_pmm_manager+0x548>
ffffffffc0202f46:	00004617          	auipc	a2,0x4
ffffffffc0202f4a:	eba60613          	addi	a2,a2,-326 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202f4e:	27400593          	li	a1,628
ffffffffc0202f52:	00004517          	auipc	a0,0x4
ffffffffc0202f56:	7b650513          	addi	a0,a0,1974 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202f5a:	d2afd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202f5e:	00005697          	auipc	a3,0x5
ffffffffc0202f62:	98268693          	addi	a3,a3,-1662 # ffffffffc02078e0 <default_pmm_manager+0x398>
ffffffffc0202f66:	00004617          	auipc	a2,0x4
ffffffffc0202f6a:	e9a60613          	addi	a2,a2,-358 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202f6e:	22600593          	li	a1,550
ffffffffc0202f72:	00004517          	auipc	a0,0x4
ffffffffc0202f76:	79650513          	addi	a0,a0,1942 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202f7a:	d0afd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202f7e:	00005697          	auipc	a3,0x5
ffffffffc0202f82:	94a68693          	addi	a3,a3,-1718 # ffffffffc02078c8 <default_pmm_manager+0x380>
ffffffffc0202f86:	00004617          	auipc	a2,0x4
ffffffffc0202f8a:	e7a60613          	addi	a2,a2,-390 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202f8e:	22500593          	li	a1,549
ffffffffc0202f92:	00004517          	auipc	a0,0x4
ffffffffc0202f96:	77650513          	addi	a0,a0,1910 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202f9a:	ceafd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202f9e:	00005697          	auipc	a3,0x5
ffffffffc0202fa2:	87a68693          	addi	a3,a3,-1926 # ffffffffc0207818 <default_pmm_manager+0x2d0>
ffffffffc0202fa6:	00004617          	auipc	a2,0x4
ffffffffc0202faa:	e5a60613          	addi	a2,a2,-422 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202fae:	21d00593          	li	a1,541
ffffffffc0202fb2:	00004517          	auipc	a0,0x4
ffffffffc0202fb6:	75650513          	addi	a0,a0,1878 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202fba:	ccafd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202fbe:	00005697          	auipc	a3,0x5
ffffffffc0202fc2:	8b268693          	addi	a3,a3,-1870 # ffffffffc0207870 <default_pmm_manager+0x328>
ffffffffc0202fc6:	00004617          	auipc	a2,0x4
ffffffffc0202fca:	e3a60613          	addi	a2,a2,-454 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202fce:	22400593          	li	a1,548
ffffffffc0202fd2:	00004517          	auipc	a0,0x4
ffffffffc0202fd6:	73650513          	addi	a0,a0,1846 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202fda:	caafd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202fde:	00005697          	auipc	a3,0x5
ffffffffc0202fe2:	86268693          	addi	a3,a3,-1950 # ffffffffc0207840 <default_pmm_manager+0x2f8>
ffffffffc0202fe6:	00004617          	auipc	a2,0x4
ffffffffc0202fea:	e1a60613          	addi	a2,a2,-486 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0202fee:	22100593          	li	a1,545
ffffffffc0202ff2:	00004517          	auipc	a0,0x4
ffffffffc0202ff6:	71650513          	addi	a0,a0,1814 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0202ffa:	c8afd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202ffe:	00005697          	auipc	a3,0x5
ffffffffc0203002:	a2268693          	addi	a3,a3,-1502 # ffffffffc0207a20 <default_pmm_manager+0x4d8>
ffffffffc0203006:	00004617          	auipc	a2,0x4
ffffffffc020300a:	dfa60613          	addi	a2,a2,-518 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020300e:	23d00593          	li	a1,573
ffffffffc0203012:	00004517          	auipc	a0,0x4
ffffffffc0203016:	6f650513          	addi	a0,a0,1782 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc020301a:	c6afd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020301e:	00005697          	auipc	a3,0x5
ffffffffc0203022:	8c268693          	addi	a3,a3,-1854 # ffffffffc02078e0 <default_pmm_manager+0x398>
ffffffffc0203026:	00004617          	auipc	a2,0x4
ffffffffc020302a:	dda60613          	addi	a2,a2,-550 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020302e:	23c00593          	li	a1,572
ffffffffc0203032:	00004517          	auipc	a0,0x4
ffffffffc0203036:	6d650513          	addi	a0,a0,1750 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc020303a:	c4afd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020303e:	00005697          	auipc	a3,0x5
ffffffffc0203042:	9fa68693          	addi	a3,a3,-1542 # ffffffffc0207a38 <default_pmm_manager+0x4f0>
ffffffffc0203046:	00004617          	auipc	a2,0x4
ffffffffc020304a:	dba60613          	addi	a2,a2,-582 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020304e:	23900593          	li	a1,569
ffffffffc0203052:	00004517          	auipc	a0,0x4
ffffffffc0203056:	6b650513          	addi	a0,a0,1718 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc020305a:	c2afd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020305e:	00005697          	auipc	a3,0x5
ffffffffc0203062:	bda68693          	addi	a3,a3,-1062 # ffffffffc0207c38 <default_pmm_manager+0x6f0>
ffffffffc0203066:	00004617          	auipc	a2,0x4
ffffffffc020306a:	d9a60613          	addi	a2,a2,-614 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020306e:	26b00593          	li	a1,619
ffffffffc0203072:	00004517          	auipc	a0,0x4
ffffffffc0203076:	69650513          	addi	a0,a0,1686 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc020307a:	c0afd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020307e:	00005697          	auipc	a3,0x5
ffffffffc0203082:	a1268693          	addi	a3,a3,-1518 # ffffffffc0207a90 <default_pmm_manager+0x548>
ffffffffc0203086:	00004617          	auipc	a2,0x4
ffffffffc020308a:	d7a60613          	addi	a2,a2,-646 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020308e:	24b00593          	li	a1,587
ffffffffc0203092:	00004517          	auipc	a0,0x4
ffffffffc0203096:	67650513          	addi	a0,a0,1654 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc020309a:	beafd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc020309e:	00005697          	auipc	a3,0x5
ffffffffc02030a2:	a8a68693          	addi	a3,a3,-1398 # ffffffffc0207b28 <default_pmm_manager+0x5e0>
ffffffffc02030a6:	00004617          	auipc	a2,0x4
ffffffffc02030aa:	d5a60613          	addi	a2,a2,-678 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02030ae:	25d00593          	li	a1,605
ffffffffc02030b2:	00004517          	auipc	a0,0x4
ffffffffc02030b6:	65650513          	addi	a0,a0,1622 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc02030ba:	bcafd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02030be:	00004697          	auipc	a3,0x4
ffffffffc02030c2:	70268693          	addi	a3,a3,1794 # ffffffffc02077c0 <default_pmm_manager+0x278>
ffffffffc02030c6:	00004617          	auipc	a2,0x4
ffffffffc02030ca:	d3a60613          	addi	a2,a2,-710 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02030ce:	21b00593          	li	a1,539
ffffffffc02030d2:	00004517          	auipc	a0,0x4
ffffffffc02030d6:	63650513          	addi	a0,a0,1590 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc02030da:	baafd0ef          	jal	ra,ffffffffc0200484 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02030de:	00004617          	auipc	a2,0x4
ffffffffc02030e2:	4f260613          	addi	a2,a2,1266 # ffffffffc02075d0 <default_pmm_manager+0x88>
ffffffffc02030e6:	0c100593          	li	a1,193
ffffffffc02030ea:	00004517          	auipc	a0,0x4
ffffffffc02030ee:	61e50513          	addi	a0,a0,1566 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc02030f2:	b92fd0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02030f6 <copy_range>:
int copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) {
ffffffffc02030f6:	7119                	addi	sp,sp,-128
ffffffffc02030f8:	e0da                	sd	s6,64(sp)
ffffffffc02030fa:	8b2a                	mv	s6,a0
    cprintf("\ncopy on write activated\n");
ffffffffc02030fc:	00004517          	auipc	a0,0x4
ffffffffc0203100:	58c50513          	addi	a0,a0,1420 # ffffffffc0207688 <default_pmm_manager+0x140>
int copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) {
ffffffffc0203104:	f4a6                	sd	s1,104(sp)
ffffffffc0203106:	f0ca                	sd	s2,96(sp)
ffffffffc0203108:	ec6e                	sd	s11,24(sp)
ffffffffc020310a:	8936                	mv	s2,a3
ffffffffc020310c:	8db2                	mv	s11,a2
ffffffffc020310e:	e03a                	sd	a4,0(sp)
ffffffffc0203110:	fc86                	sd	ra,120(sp)
ffffffffc0203112:	f8a2                	sd	s0,112(sp)
ffffffffc0203114:	ecce                	sd	s3,88(sp)
ffffffffc0203116:	e8d2                	sd	s4,80(sp)
ffffffffc0203118:	e4d6                	sd	s5,72(sp)
ffffffffc020311a:	fc5e                	sd	s7,56(sp)
ffffffffc020311c:	f862                	sd	s8,48(sp)
ffffffffc020311e:	f466                	sd	s9,40(sp)
ffffffffc0203120:	f06a                	sd	s10,32(sp)
ffffffffc0203122:	84ae                	mv	s1,a1
    cprintf("\ncopy on write activated\n");
ffffffffc0203124:	86afd0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203128:	012de733          	or	a4,s11,s2
ffffffffc020312c:	03471793          	slli	a5,a4,0x34
ffffffffc0203130:	26079263          	bnez	a5,ffffffffc0203394 <copy_range+0x29e>
    assert(USER_ACCESS(start, end));
ffffffffc0203134:	00200737          	lui	a4,0x200
ffffffffc0203138:	22ede263          	bltu	s11,a4,ffffffffc020335c <copy_range+0x266>
ffffffffc020313c:	232df063          	bleu	s2,s11,ffffffffc020335c <copy_range+0x266>
ffffffffc0203140:	4705                	li	a4,1
ffffffffc0203142:	077e                	slli	a4,a4,0x1f
ffffffffc0203144:	21276c63          	bltu	a4,s2,ffffffffc020335c <copy_range+0x266>
ffffffffc0203148:	5afd                	li	s5,-1
        start += PGSIZE;
ffffffffc020314a:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc020314c:	000a9c97          	auipc	s9,0xa9
ffffffffc0203150:	3ccc8c93          	addi	s9,s9,972 # ffffffffc02ac518 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203154:	000a9c17          	auipc	s8,0xa9
ffffffffc0203158:	434c0c13          	addi	s8,s8,1076 # ffffffffc02ac588 <pages>
    return page - pages + nbase;
ffffffffc020315c:	00080bb7          	lui	s7,0x80
    return KADDR(page2pa(page));
ffffffffc0203160:	00cada93          	srli	s5,s5,0xc
ffffffffc0203164:	000a9d17          	auipc	s10,0xa9
ffffffffc0203168:	414d0d13          	addi	s10,s10,1044 # ffffffffc02ac578 <va_pa_offset>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc020316c:	4601                	li	a2,0
ffffffffc020316e:	85ee                	mv	a1,s11
ffffffffc0203170:	8526                	mv	a0,s1
ffffffffc0203172:	e27fe0ef          	jal	ra,ffffffffc0201f98 <get_pte>
ffffffffc0203176:	842a                	mv	s0,a0
        if (ptep == NULL) {
ffffffffc0203178:	c179                	beqz	a0,ffffffffc020323e <copy_range+0x148>
        if (*ptep & PTE_V) {
ffffffffc020317a:	6118                	ld	a4,0(a0)
ffffffffc020317c:	8b05                	andi	a4,a4,1
ffffffffc020317e:	e705                	bnez	a4,ffffffffc02031a6 <copy_range+0xb0>
        start += PGSIZE;
ffffffffc0203180:	9dd2                	add	s11,s11,s4
    } while (start != 0 && start < end);
ffffffffc0203182:	ff2de5e3          	bltu	s11,s2,ffffffffc020316c <copy_range+0x76>
    return 0;
ffffffffc0203186:	4501                	li	a0,0
}
ffffffffc0203188:	70e6                	ld	ra,120(sp)
ffffffffc020318a:	7446                	ld	s0,112(sp)
ffffffffc020318c:	74a6                	ld	s1,104(sp)
ffffffffc020318e:	7906                	ld	s2,96(sp)
ffffffffc0203190:	69e6                	ld	s3,88(sp)
ffffffffc0203192:	6a46                	ld	s4,80(sp)
ffffffffc0203194:	6aa6                	ld	s5,72(sp)
ffffffffc0203196:	6b06                	ld	s6,64(sp)
ffffffffc0203198:	7be2                	ld	s7,56(sp)
ffffffffc020319a:	7c42                	ld	s8,48(sp)
ffffffffc020319c:	7ca2                	ld	s9,40(sp)
ffffffffc020319e:	7d02                	ld	s10,32(sp)
ffffffffc02031a0:	6de2                	ld	s11,24(sp)
ffffffffc02031a2:	6109                	addi	sp,sp,128
ffffffffc02031a4:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) return -E_NO_MEM;
ffffffffc02031a6:	4605                	li	a2,1
ffffffffc02031a8:	85ee                	mv	a1,s11
ffffffffc02031aa:	855a                	mv	a0,s6
ffffffffc02031ac:	dedfe0ef          	jal	ra,ffffffffc0201f98 <get_pte>
ffffffffc02031b0:	12050b63          	beqz	a0,ffffffffc02032e6 <copy_range+0x1f0>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc02031b4:	6018                	ld	a4,0(s0)
    if (!(pte & PTE_V)) {
ffffffffc02031b6:	00177693          	andi	a3,a4,1
ffffffffc02031ba:	0007099b          	sext.w	s3,a4
ffffffffc02031be:	16068363          	beqz	a3,ffffffffc0203324 <copy_range+0x22e>
    if (PPN(pa) >= npage) {
ffffffffc02031c2:	000cb683          	ld	a3,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc02031c6:	070a                	slli	a4,a4,0x2
ffffffffc02031c8:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031ca:	1ad77963          	bleu	a3,a4,ffffffffc020337c <copy_range+0x286>
    return &pages[PPN(pa) - nbase];
ffffffffc02031ce:	fff807b7          	lui	a5,0xfff80
ffffffffc02031d2:	973e                	add	a4,a4,a5
ffffffffc02031d4:	000c3403          	ld	s0,0(s8)
            if(share)
ffffffffc02031d8:	6782                	ld	a5,0(sp)
ffffffffc02031da:	071a                	slli	a4,a4,0x6
ffffffffc02031dc:	943a                	add	s0,s0,a4
ffffffffc02031de:	cfad                	beqz	a5,ffffffffc0203258 <copy_range+0x162>
    return page - pages + nbase;
ffffffffc02031e0:	8719                	srai	a4,a4,0x6
ffffffffc02031e2:	975e                	add	a4,a4,s7
    return KADDR(page2pa(page));
ffffffffc02031e4:	01577633          	and	a2,a4,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc02031e8:	0732                	slli	a4,a4,0xc
    return KADDR(page2pa(page));
ffffffffc02031ea:	10d67063          	bleu	a3,a2,ffffffffc02032ea <copy_range+0x1f4>
ffffffffc02031ee:	000d3583          	ld	a1,0(s10)
                cprintf("Sharing the page 0x%x\n", page2kva(page));
ffffffffc02031f2:	00004517          	auipc	a0,0x4
ffffffffc02031f6:	4b650513          	addi	a0,a0,1206 # ffffffffc02076a8 <default_pmm_manager+0x160>
                page_insert(from, page, start, perm & ~PTE_W);
ffffffffc02031fa:	01b9f993          	andi	s3,s3,27
                cprintf("Sharing the page 0x%x\n", page2kva(page));
ffffffffc02031fe:	95ba                	add	a1,a1,a4
ffffffffc0203200:	f8ffc0ef          	jal	ra,ffffffffc020018e <cprintf>
                page_insert(from, page, start, perm & ~PTE_W);
ffffffffc0203204:	86ce                	mv	a3,s3
ffffffffc0203206:	866e                	mv	a2,s11
ffffffffc0203208:	85a2                	mv	a1,s0
ffffffffc020320a:	8526                	mv	a0,s1
ffffffffc020320c:	ba2ff0ef          	jal	ra,ffffffffc02025ae <page_insert>
                ret = page_insert(to, page, start, perm & ~PTE_W);
ffffffffc0203210:	86ce                	mv	a3,s3
ffffffffc0203212:	866e                	mv	a2,s11
ffffffffc0203214:	85a2                	mv	a1,s0
ffffffffc0203216:	855a                	mv	a0,s6
ffffffffc0203218:	b96ff0ef          	jal	ra,ffffffffc02025ae <page_insert>
            assert(ret == 0);
ffffffffc020321c:	d135                	beqz	a0,ffffffffc0203180 <copy_range+0x8a>
ffffffffc020321e:	00004697          	auipc	a3,0x4
ffffffffc0203222:	4da68693          	addi	a3,a3,1242 # ffffffffc02076f8 <default_pmm_manager+0x1b0>
ffffffffc0203226:	00004617          	auipc	a2,0x4
ffffffffc020322a:	bda60613          	addi	a2,a2,-1062 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020322e:	1bc00593          	li	a1,444
ffffffffc0203232:	00004517          	auipc	a0,0x4
ffffffffc0203236:	4d650513          	addi	a0,a0,1238 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc020323a:	a4afd0ef          	jal	ra,ffffffffc0200484 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020323e:	00200737          	lui	a4,0x200
ffffffffc0203242:	00ed87b3          	add	a5,s11,a4
ffffffffc0203246:	ffe00737          	lui	a4,0xffe00
ffffffffc020324a:	00e7fdb3          	and	s11,a5,a4
    } while (start != 0 && start < end);
ffffffffc020324e:	f20d8ce3          	beqz	s11,ffffffffc0203186 <copy_range+0x90>
ffffffffc0203252:	f12dede3          	bltu	s11,s2,ffffffffc020316c <copy_range+0x76>
ffffffffc0203256:	bf05                	j	ffffffffc0203186 <copy_range+0x90>
                struct Page *npage = alloc_page();
ffffffffc0203258:	4505                	li	a0,1
ffffffffc020325a:	c31fe0ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
                assert(page!=NULL);
ffffffffc020325e:	c05d                	beqz	s0,ffffffffc0203304 <copy_range+0x20e>
                assert(npage!=NULL);
ffffffffc0203260:	cd71                	beqz	a0,ffffffffc020333c <copy_range+0x246>
    return page - pages + nbase;
ffffffffc0203262:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc0203266:	000cb703          	ld	a4,0(s9)
    return page - pages + nbase;
ffffffffc020326a:	40d506b3          	sub	a3,a0,a3
ffffffffc020326e:	8699                	srai	a3,a3,0x6
ffffffffc0203270:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0203272:	0156f633          	and	a2,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0203276:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203278:	06e67a63          	bleu	a4,a2,ffffffffc02032ec <copy_range+0x1f6>
ffffffffc020327c:	000d3583          	ld	a1,0(s10)
ffffffffc0203280:	e42a                	sd	a0,8(sp)
                cprintf("alloc a new page 0x%x\n", page2kva(npage));
ffffffffc0203282:	00004517          	auipc	a0,0x4
ffffffffc0203286:	45e50513          	addi	a0,a0,1118 # ffffffffc02076e0 <default_pmm_manager+0x198>
ffffffffc020328a:	95b6                	add	a1,a1,a3
ffffffffc020328c:	f03fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    return page - pages + nbase;
ffffffffc0203290:	000c3703          	ld	a4,0(s8)
    return KADDR(page2pa(page));
ffffffffc0203294:	000cb603          	ld	a2,0(s9)
ffffffffc0203298:	6822                	ld	a6,8(sp)
    return page - pages + nbase;
ffffffffc020329a:	40e406b3          	sub	a3,s0,a4
ffffffffc020329e:	8699                	srai	a3,a3,0x6
ffffffffc02032a0:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc02032a2:	0156f5b3          	and	a1,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc02032a6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02032a8:	04c5f263          	bleu	a2,a1,ffffffffc02032ec <copy_range+0x1f6>
    return page - pages + nbase;
ffffffffc02032ac:	40e80733          	sub	a4,a6,a4
    return KADDR(page2pa(page));
ffffffffc02032b0:	000d3503          	ld	a0,0(s10)
    return page - pages + nbase;
ffffffffc02032b4:	8719                	srai	a4,a4,0x6
ffffffffc02032b6:	975e                	add	a4,a4,s7
    return KADDR(page2pa(page));
ffffffffc02032b8:	015778b3          	and	a7,a4,s5
ffffffffc02032bc:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02032c0:	0732                	slli	a4,a4,0xc
    return KADDR(page2pa(page));
ffffffffc02032c2:	02c8f463          	bleu	a2,a7,ffffffffc02032ea <copy_range+0x1f4>
                memcpy(kva_dst, kva_src, PGSIZE);
ffffffffc02032c6:	6605                	lui	a2,0x1
ffffffffc02032c8:	953a                	add	a0,a0,a4
ffffffffc02032ca:	e442                	sd	a6,8(sp)
ffffffffc02032cc:	512030ef          	jal	ra,ffffffffc02067de <memcpy>
                ret = page_insert(to, npage, start, perm);
ffffffffc02032d0:	6822                	ld	a6,8(sp)
ffffffffc02032d2:	01f9f693          	andi	a3,s3,31
ffffffffc02032d6:	866e                	mv	a2,s11
ffffffffc02032d8:	85c2                	mv	a1,a6
ffffffffc02032da:	855a                	mv	a0,s6
ffffffffc02032dc:	ad2ff0ef          	jal	ra,ffffffffc02025ae <page_insert>
            assert(ret == 0);
ffffffffc02032e0:	ea0500e3          	beqz	a0,ffffffffc0203180 <copy_range+0x8a>
ffffffffc02032e4:	bf2d                	j	ffffffffc020321e <copy_range+0x128>
            if ((nptep = get_pte(to, start, 1)) == NULL) return -E_NO_MEM;
ffffffffc02032e6:	5571                	li	a0,-4
ffffffffc02032e8:	b545                	j	ffffffffc0203188 <copy_range+0x92>
ffffffffc02032ea:	86ba                	mv	a3,a4
ffffffffc02032ec:	00004617          	auipc	a2,0x4
ffffffffc02032f0:	2ac60613          	addi	a2,a2,684 # ffffffffc0207598 <default_pmm_manager+0x50>
ffffffffc02032f4:	06900593          	li	a1,105
ffffffffc02032f8:	00004517          	auipc	a0,0x4
ffffffffc02032fc:	2c850513          	addi	a0,a0,712 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0203300:	984fd0ef          	jal	ra,ffffffffc0200484 <__panic>
                assert(page!=NULL);
ffffffffc0203304:	00004697          	auipc	a3,0x4
ffffffffc0203308:	3bc68693          	addi	a3,a3,956 # ffffffffc02076c0 <default_pmm_manager+0x178>
ffffffffc020330c:	00004617          	auipc	a2,0x4
ffffffffc0203310:	af460613          	addi	a2,a2,-1292 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203314:	1b300593          	li	a1,435
ffffffffc0203318:	00004517          	auipc	a0,0x4
ffffffffc020331c:	3f050513          	addi	a0,a0,1008 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0203320:	964fd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203324:	00004617          	auipc	a2,0x4
ffffffffc0203328:	57c60613          	addi	a2,a2,1404 # ffffffffc02078a0 <default_pmm_manager+0x358>
ffffffffc020332c:	07400593          	li	a1,116
ffffffffc0203330:	00004517          	auipc	a0,0x4
ffffffffc0203334:	29050513          	addi	a0,a0,656 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0203338:	94cfd0ef          	jal	ra,ffffffffc0200484 <__panic>
                assert(npage!=NULL);
ffffffffc020333c:	00004697          	auipc	a3,0x4
ffffffffc0203340:	39468693          	addi	a3,a3,916 # ffffffffc02076d0 <default_pmm_manager+0x188>
ffffffffc0203344:	00004617          	auipc	a2,0x4
ffffffffc0203348:	abc60613          	addi	a2,a2,-1348 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020334c:	1b400593          	li	a1,436
ffffffffc0203350:	00004517          	auipc	a0,0x4
ffffffffc0203354:	3b850513          	addi	a0,a0,952 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0203358:	92cfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020335c:	00005697          	auipc	a3,0x5
ffffffffc0203360:	95468693          	addi	a3,a3,-1708 # ffffffffc0207cb0 <default_pmm_manager+0x768>
ffffffffc0203364:	00004617          	auipc	a2,0x4
ffffffffc0203368:	a9c60613          	addi	a2,a2,-1380 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020336c:	19500593          	li	a1,405
ffffffffc0203370:	00004517          	auipc	a0,0x4
ffffffffc0203374:	39850513          	addi	a0,a0,920 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc0203378:	90cfd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020337c:	00004617          	auipc	a2,0x4
ffffffffc0203380:	27c60613          	addi	a2,a2,636 # ffffffffc02075f8 <default_pmm_manager+0xb0>
ffffffffc0203384:	06200593          	li	a1,98
ffffffffc0203388:	00004517          	auipc	a0,0x4
ffffffffc020338c:	23850513          	addi	a0,a0,568 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0203390:	8f4fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203394:	00005697          	auipc	a3,0x5
ffffffffc0203398:	8ec68693          	addi	a3,a3,-1812 # ffffffffc0207c80 <default_pmm_manager+0x738>
ffffffffc020339c:	00004617          	auipc	a2,0x4
ffffffffc02033a0:	a6460613          	addi	a2,a2,-1436 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02033a4:	19400593          	li	a1,404
ffffffffc02033a8:	00004517          	auipc	a0,0x4
ffffffffc02033ac:	36050513          	addi	a0,a0,864 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc02033b0:	8d4fd0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02033b4 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02033b4:	12058073          	sfence.vma	a1
}
ffffffffc02033b8:	8082                	ret

ffffffffc02033ba <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02033ba:	7179                	addi	sp,sp,-48
ffffffffc02033bc:	e84a                	sd	s2,16(sp)
ffffffffc02033be:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02033c0:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02033c2:	f022                	sd	s0,32(sp)
ffffffffc02033c4:	ec26                	sd	s1,24(sp)
ffffffffc02033c6:	e44e                	sd	s3,8(sp)
ffffffffc02033c8:	f406                	sd	ra,40(sp)
ffffffffc02033ca:	84ae                	mv	s1,a1
ffffffffc02033cc:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02033ce:	abdfe0ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc02033d2:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc02033d4:	cd1d                	beqz	a0,ffffffffc0203412 <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc02033d6:	85aa                	mv	a1,a0
ffffffffc02033d8:	86ce                	mv	a3,s3
ffffffffc02033da:	8626                	mv	a2,s1
ffffffffc02033dc:	854a                	mv	a0,s2
ffffffffc02033de:	9d0ff0ef          	jal	ra,ffffffffc02025ae <page_insert>
ffffffffc02033e2:	e121                	bnez	a0,ffffffffc0203422 <pgdir_alloc_page+0x68>
        if (swap_init_ok) {
ffffffffc02033e4:	000a9797          	auipc	a5,0xa9
ffffffffc02033e8:	14478793          	addi	a5,a5,324 # ffffffffc02ac528 <swap_init_ok>
ffffffffc02033ec:	439c                	lw	a5,0(a5)
ffffffffc02033ee:	2781                	sext.w	a5,a5
ffffffffc02033f0:	c38d                	beqz	a5,ffffffffc0203412 <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc02033f2:	000a9797          	auipc	a5,0xa9
ffffffffc02033f6:	27678793          	addi	a5,a5,630 # ffffffffc02ac668 <check_mm_struct>
ffffffffc02033fa:	6388                	ld	a0,0(a5)
ffffffffc02033fc:	c919                	beqz	a0,ffffffffc0203412 <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc02033fe:	4681                	li	a3,0
ffffffffc0203400:	8622                	mv	a2,s0
ffffffffc0203402:	85a6                	mv	a1,s1
ffffffffc0203404:	7da000ef          	jal	ra,ffffffffc0203bde <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0203408:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc020340a:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc020340c:	4785                	li	a5,1
ffffffffc020340e:	02f71063          	bne	a4,a5,ffffffffc020342e <pgdir_alloc_page+0x74>
}
ffffffffc0203412:	8522                	mv	a0,s0
ffffffffc0203414:	70a2                	ld	ra,40(sp)
ffffffffc0203416:	7402                	ld	s0,32(sp)
ffffffffc0203418:	64e2                	ld	s1,24(sp)
ffffffffc020341a:	6942                	ld	s2,16(sp)
ffffffffc020341c:	69a2                	ld	s3,8(sp)
ffffffffc020341e:	6145                	addi	sp,sp,48
ffffffffc0203420:	8082                	ret
            free_page(page);
ffffffffc0203422:	8522                	mv	a0,s0
ffffffffc0203424:	4585                	li	a1,1
ffffffffc0203426:	aedfe0ef          	jal	ra,ffffffffc0201f12 <free_pages>
            return NULL;
ffffffffc020342a:	4401                	li	s0,0
ffffffffc020342c:	b7dd                	j	ffffffffc0203412 <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc020342e:	00004697          	auipc	a3,0x4
ffffffffc0203432:	2ea68693          	addi	a3,a3,746 # ffffffffc0207718 <default_pmm_manager+0x1d0>
ffffffffc0203436:	00004617          	auipc	a2,0x4
ffffffffc020343a:	9ca60613          	addi	a2,a2,-1590 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020343e:	1fc00593          	li	a1,508
ffffffffc0203442:	00004517          	auipc	a0,0x4
ffffffffc0203446:	2c650513          	addi	a0,a0,710 # ffffffffc0207708 <default_pmm_manager+0x1c0>
ffffffffc020344a:	83afd0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020344e <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020344e:	7135                	addi	sp,sp,-160
ffffffffc0203450:	ed06                	sd	ra,152(sp)
ffffffffc0203452:	e922                	sd	s0,144(sp)
ffffffffc0203454:	e526                	sd	s1,136(sp)
ffffffffc0203456:	e14a                	sd	s2,128(sp)
ffffffffc0203458:	fcce                	sd	s3,120(sp)
ffffffffc020345a:	f8d2                	sd	s4,112(sp)
ffffffffc020345c:	f4d6                	sd	s5,104(sp)
ffffffffc020345e:	f0da                	sd	s6,96(sp)
ffffffffc0203460:	ecde                	sd	s7,88(sp)
ffffffffc0203462:	e8e2                	sd	s8,80(sp)
ffffffffc0203464:	e4e6                	sd	s9,72(sp)
ffffffffc0203466:	e0ea                	sd	s10,64(sp)
ffffffffc0203468:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc020346a:	09f010ef          	jal	ra,ffffffffc0204d08 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020346e:	000a9797          	auipc	a5,0xa9
ffffffffc0203472:	1aa78793          	addi	a5,a5,426 # ffffffffc02ac618 <max_swap_offset>
ffffffffc0203476:	6394                	ld	a3,0(a5)
ffffffffc0203478:	010007b7          	lui	a5,0x1000
ffffffffc020347c:	17e1                	addi	a5,a5,-8
ffffffffc020347e:	ff968713          	addi	a4,a3,-7
ffffffffc0203482:	4ae7ee63          	bltu	a5,a4,ffffffffc020393e <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc0203486:	0009e797          	auipc	a5,0x9e
ffffffffc020348a:	c2278793          	addi	a5,a5,-990 # ffffffffc02a10a8 <swap_manager_fifo>
     int r = sm->init();
ffffffffc020348e:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0203490:	000a9697          	auipc	a3,0xa9
ffffffffc0203494:	08f6b823          	sd	a5,144(a3) # ffffffffc02ac520 <sm>
     int r = sm->init();
ffffffffc0203498:	9702                	jalr	a4
ffffffffc020349a:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc020349c:	c10d                	beqz	a0,ffffffffc02034be <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020349e:	60ea                	ld	ra,152(sp)
ffffffffc02034a0:	644a                	ld	s0,144(sp)
ffffffffc02034a2:	8556                	mv	a0,s5
ffffffffc02034a4:	64aa                	ld	s1,136(sp)
ffffffffc02034a6:	690a                	ld	s2,128(sp)
ffffffffc02034a8:	79e6                	ld	s3,120(sp)
ffffffffc02034aa:	7a46                	ld	s4,112(sp)
ffffffffc02034ac:	7aa6                	ld	s5,104(sp)
ffffffffc02034ae:	7b06                	ld	s6,96(sp)
ffffffffc02034b0:	6be6                	ld	s7,88(sp)
ffffffffc02034b2:	6c46                	ld	s8,80(sp)
ffffffffc02034b4:	6ca6                	ld	s9,72(sp)
ffffffffc02034b6:	6d06                	ld	s10,64(sp)
ffffffffc02034b8:	7de2                	ld	s11,56(sp)
ffffffffc02034ba:	610d                	addi	sp,sp,160
ffffffffc02034bc:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02034be:	000a9797          	auipc	a5,0xa9
ffffffffc02034c2:	06278793          	addi	a5,a5,98 # ffffffffc02ac520 <sm>
ffffffffc02034c6:	639c                	ld	a5,0(a5)
ffffffffc02034c8:	00005517          	auipc	a0,0x5
ffffffffc02034cc:	88050513          	addi	a0,a0,-1920 # ffffffffc0207d48 <default_pmm_manager+0x800>
    return listelm->next;
ffffffffc02034d0:	000a9417          	auipc	s0,0xa9
ffffffffc02034d4:	08840413          	addi	s0,s0,136 # ffffffffc02ac558 <free_area>
ffffffffc02034d8:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02034da:	4785                	li	a5,1
ffffffffc02034dc:	000a9717          	auipc	a4,0xa9
ffffffffc02034e0:	04f72623          	sw	a5,76(a4) # ffffffffc02ac528 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02034e4:	cabfc0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02034e8:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02034ea:	36878e63          	beq	a5,s0,ffffffffc0203866 <swap_init+0x418>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02034ee:	ff07b703          	ld	a4,-16(a5)
ffffffffc02034f2:	8305                	srli	a4,a4,0x1
ffffffffc02034f4:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02034f6:	36070c63          	beqz	a4,ffffffffc020386e <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc02034fa:	4481                	li	s1,0
ffffffffc02034fc:	4901                	li	s2,0
ffffffffc02034fe:	a031                	j	ffffffffc020350a <swap_init+0xbc>
ffffffffc0203500:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0203504:	8b09                	andi	a4,a4,2
ffffffffc0203506:	36070463          	beqz	a4,ffffffffc020386e <swap_init+0x420>
        count ++, total += p->property;
ffffffffc020350a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020350e:	679c                	ld	a5,8(a5)
ffffffffc0203510:	2905                	addiw	s2,s2,1
ffffffffc0203512:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203514:	fe8796e3          	bne	a5,s0,ffffffffc0203500 <swap_init+0xb2>
ffffffffc0203518:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc020351a:	a3ffe0ef          	jal	ra,ffffffffc0201f58 <nr_free_pages>
ffffffffc020351e:	69351863          	bne	a0,s3,ffffffffc0203bae <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0203522:	8626                	mv	a2,s1
ffffffffc0203524:	85ca                	mv	a1,s2
ffffffffc0203526:	00005517          	auipc	a0,0x5
ffffffffc020352a:	83a50513          	addi	a0,a0,-1990 # ffffffffc0207d60 <default_pmm_manager+0x818>
ffffffffc020352e:	c61fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0203532:	457000ef          	jal	ra,ffffffffc0204188 <mm_create>
ffffffffc0203536:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0203538:	60050b63          	beqz	a0,ffffffffc0203b4e <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020353c:	000a9797          	auipc	a5,0xa9
ffffffffc0203540:	12c78793          	addi	a5,a5,300 # ffffffffc02ac668 <check_mm_struct>
ffffffffc0203544:	639c                	ld	a5,0(a5)
ffffffffc0203546:	62079463          	bnez	a5,ffffffffc0203b6e <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020354a:	000a9797          	auipc	a5,0xa9
ffffffffc020354e:	fc678793          	addi	a5,a5,-58 # ffffffffc02ac510 <boot_pgdir>
ffffffffc0203552:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0203556:	000a9797          	auipc	a5,0xa9
ffffffffc020355a:	10a7b923          	sd	a0,274(a5) # ffffffffc02ac668 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020355e:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203562:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0203566:	4e079863          	bnez	a5,ffffffffc0203a56 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc020356a:	6599                	lui	a1,0x6
ffffffffc020356c:	460d                	li	a2,3
ffffffffc020356e:	6505                	lui	a0,0x1
ffffffffc0203570:	465000ef          	jal	ra,ffffffffc02041d4 <vma_create>
ffffffffc0203574:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0203576:	50050063          	beqz	a0,ffffffffc0203a76 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc020357a:	855e                	mv	a0,s7
ffffffffc020357c:	4c5000ef          	jal	ra,ffffffffc0204240 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0203580:	00005517          	auipc	a0,0x5
ffffffffc0203584:	85050513          	addi	a0,a0,-1968 # ffffffffc0207dd0 <default_pmm_manager+0x888>
ffffffffc0203588:	c07fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc020358c:	018bb503          	ld	a0,24(s7) # 80018 <_binary_obj___user_exit_out_size+0x75590>
ffffffffc0203590:	4605                	li	a2,1
ffffffffc0203592:	6585                	lui	a1,0x1
ffffffffc0203594:	a05fe0ef          	jal	ra,ffffffffc0201f98 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0203598:	4e050f63          	beqz	a0,ffffffffc0203a96 <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc020359c:	00005517          	auipc	a0,0x5
ffffffffc02035a0:	88450513          	addi	a0,a0,-1916 # ffffffffc0207e20 <default_pmm_manager+0x8d8>
ffffffffc02035a4:	000a9997          	auipc	s3,0xa9
ffffffffc02035a8:	fec98993          	addi	s3,s3,-20 # ffffffffc02ac590 <check_rp>
ffffffffc02035ac:	be3fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02035b0:	000a9a17          	auipc	s4,0xa9
ffffffffc02035b4:	000a0a13          	mv	s4,s4
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02035b8:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc02035ba:	4505                	li	a0,1
ffffffffc02035bc:	8cffe0ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc02035c0:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc02035c4:	32050d63          	beqz	a0,ffffffffc02038fe <swap_init+0x4b0>
ffffffffc02035c8:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02035ca:	8b89                	andi	a5,a5,2
ffffffffc02035cc:	30079963          	bnez	a5,ffffffffc02038de <swap_init+0x490>
ffffffffc02035d0:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02035d2:	ff4c14e3          	bne	s8,s4,ffffffffc02035ba <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02035d6:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc02035d8:	000a9c17          	auipc	s8,0xa9
ffffffffc02035dc:	fb8c0c13          	addi	s8,s8,-72 # ffffffffc02ac590 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc02035e0:	ec3e                	sd	a5,24(sp)
ffffffffc02035e2:	641c                	ld	a5,8(s0)
ffffffffc02035e4:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02035e6:	481c                	lw	a5,16(s0)
ffffffffc02035e8:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc02035ea:	000a9797          	auipc	a5,0xa9
ffffffffc02035ee:	f687bb23          	sd	s0,-138(a5) # ffffffffc02ac560 <free_area+0x8>
ffffffffc02035f2:	000a9797          	auipc	a5,0xa9
ffffffffc02035f6:	f687b323          	sd	s0,-154(a5) # ffffffffc02ac558 <free_area>
     nr_free = 0;
ffffffffc02035fa:	000a9797          	auipc	a5,0xa9
ffffffffc02035fe:	f607a723          	sw	zero,-146(a5) # ffffffffc02ac568 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0203602:	000c3503          	ld	a0,0(s8)
ffffffffc0203606:	4585                	li	a1,1
ffffffffc0203608:	0c21                	addi	s8,s8,8
ffffffffc020360a:	909fe0ef          	jal	ra,ffffffffc0201f12 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020360e:	ff4c1ae3          	bne	s8,s4,ffffffffc0203602 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203612:	01042c03          	lw	s8,16(s0)
ffffffffc0203616:	4791                	li	a5,4
ffffffffc0203618:	50fc1b63          	bne	s8,a5,ffffffffc0203b2e <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020361c:	00005517          	auipc	a0,0x5
ffffffffc0203620:	88c50513          	addi	a0,a0,-1908 # ffffffffc0207ea8 <default_pmm_manager+0x960>
ffffffffc0203624:	b6bfc0ef          	jal	ra,ffffffffc020018e <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203628:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc020362a:	000a9797          	auipc	a5,0xa9
ffffffffc020362e:	f007a123          	sw	zero,-254(a5) # ffffffffc02ac52c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203632:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0203634:	000a9797          	auipc	a5,0xa9
ffffffffc0203638:	ef878793          	addi	a5,a5,-264 # ffffffffc02ac52c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020363c:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
     assert(pgfault_num==1);
ffffffffc0203640:	4398                	lw	a4,0(a5)
ffffffffc0203642:	4585                	li	a1,1
ffffffffc0203644:	2701                	sext.w	a4,a4
ffffffffc0203646:	38b71863          	bne	a4,a1,ffffffffc02039d6 <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc020364a:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc020364e:	4394                	lw	a3,0(a5)
ffffffffc0203650:	2681                	sext.w	a3,a3
ffffffffc0203652:	3ae69263          	bne	a3,a4,ffffffffc02039f6 <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203656:	6689                	lui	a3,0x2
ffffffffc0203658:	462d                	li	a2,11
ffffffffc020365a:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7578>
     assert(pgfault_num==2);
ffffffffc020365e:	4398                	lw	a4,0(a5)
ffffffffc0203660:	4589                	li	a1,2
ffffffffc0203662:	2701                	sext.w	a4,a4
ffffffffc0203664:	2eb71963          	bne	a4,a1,ffffffffc0203956 <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0203668:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc020366c:	4394                	lw	a3,0(a5)
ffffffffc020366e:	2681                	sext.w	a3,a3
ffffffffc0203670:	30e69363          	bne	a3,a4,ffffffffc0203976 <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203674:	668d                	lui	a3,0x3
ffffffffc0203676:	4631                	li	a2,12
ffffffffc0203678:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6578>
     assert(pgfault_num==3);
ffffffffc020367c:	4398                	lw	a4,0(a5)
ffffffffc020367e:	458d                	li	a1,3
ffffffffc0203680:	2701                	sext.w	a4,a4
ffffffffc0203682:	30b71a63          	bne	a4,a1,ffffffffc0203996 <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0203686:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc020368a:	4394                	lw	a3,0(a5)
ffffffffc020368c:	2681                	sext.w	a3,a3
ffffffffc020368e:	32e69463          	bne	a3,a4,ffffffffc02039b6 <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203692:	6691                	lui	a3,0x4
ffffffffc0203694:	4635                	li	a2,13
ffffffffc0203696:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5578>
     assert(pgfault_num==4);
ffffffffc020369a:	4398                	lw	a4,0(a5)
ffffffffc020369c:	2701                	sext.w	a4,a4
ffffffffc020369e:	37871c63          	bne	a4,s8,ffffffffc0203a16 <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02036a2:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02036a6:	439c                	lw	a5,0(a5)
ffffffffc02036a8:	2781                	sext.w	a5,a5
ffffffffc02036aa:	38e79663          	bne	a5,a4,ffffffffc0203a36 <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02036ae:	481c                	lw	a5,16(s0)
ffffffffc02036b0:	40079363          	bnez	a5,ffffffffc0203ab6 <swap_init+0x668>
ffffffffc02036b4:	000a9797          	auipc	a5,0xa9
ffffffffc02036b8:	efc78793          	addi	a5,a5,-260 # ffffffffc02ac5b0 <swap_in_seq_no>
ffffffffc02036bc:	000a9717          	auipc	a4,0xa9
ffffffffc02036c0:	f1c70713          	addi	a4,a4,-228 # ffffffffc02ac5d8 <swap_out_seq_no>
ffffffffc02036c4:	000a9617          	auipc	a2,0xa9
ffffffffc02036c8:	f1460613          	addi	a2,a2,-236 # ffffffffc02ac5d8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02036cc:	56fd                	li	a3,-1
ffffffffc02036ce:	c394                	sw	a3,0(a5)
ffffffffc02036d0:	c314                	sw	a3,0(a4)
ffffffffc02036d2:	0791                	addi	a5,a5,4
ffffffffc02036d4:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc02036d6:	fef61ce3          	bne	a2,a5,ffffffffc02036ce <swap_init+0x280>
ffffffffc02036da:	000a9697          	auipc	a3,0xa9
ffffffffc02036de:	f5e68693          	addi	a3,a3,-162 # ffffffffc02ac638 <check_ptep>
ffffffffc02036e2:	000a9817          	auipc	a6,0xa9
ffffffffc02036e6:	eae80813          	addi	a6,a6,-338 # ffffffffc02ac590 <check_rp>
ffffffffc02036ea:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc02036ec:	000a9c97          	auipc	s9,0xa9
ffffffffc02036f0:	e2cc8c93          	addi	s9,s9,-468 # ffffffffc02ac518 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02036f4:	00006d97          	auipc	s11,0x6
ffffffffc02036f8:	884d8d93          	addi	s11,s11,-1916 # ffffffffc0208f78 <nbase>
ffffffffc02036fc:	000a9c17          	auipc	s8,0xa9
ffffffffc0203700:	e8cc0c13          	addi	s8,s8,-372 # ffffffffc02ac588 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0203704:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203708:	4601                	li	a2,0
ffffffffc020370a:	85ea                	mv	a1,s10
ffffffffc020370c:	855a                	mv	a0,s6
ffffffffc020370e:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0203710:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203712:	887fe0ef          	jal	ra,ffffffffc0201f98 <get_pte>
ffffffffc0203716:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203718:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020371a:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc020371c:	20050163          	beqz	a0,ffffffffc020391e <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203720:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203722:	0017f613          	andi	a2,a5,1
ffffffffc0203726:	1a060063          	beqz	a2,ffffffffc02038c6 <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc020372a:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020372e:	078a                	slli	a5,a5,0x2
ffffffffc0203730:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203732:	14c7fe63          	bleu	a2,a5,ffffffffc020388e <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203736:	000db703          	ld	a4,0(s11)
ffffffffc020373a:	000c3603          	ld	a2,0(s8)
ffffffffc020373e:	00083583          	ld	a1,0(a6)
ffffffffc0203742:	8f99                	sub	a5,a5,a4
ffffffffc0203744:	079a                	slli	a5,a5,0x6
ffffffffc0203746:	e43a                	sd	a4,8(sp)
ffffffffc0203748:	97b2                	add	a5,a5,a2
ffffffffc020374a:	14f59e63          	bne	a1,a5,ffffffffc02038a6 <swap_init+0x458>
ffffffffc020374e:	6785                	lui	a5,0x1
ffffffffc0203750:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203752:	6795                	lui	a5,0x5
ffffffffc0203754:	06a1                	addi	a3,a3,8
ffffffffc0203756:	0821                	addi	a6,a6,8
ffffffffc0203758:	fafd16e3          	bne	s10,a5,ffffffffc0203704 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc020375c:	00004517          	auipc	a0,0x4
ffffffffc0203760:	7f450513          	addi	a0,a0,2036 # ffffffffc0207f50 <default_pmm_manager+0xa08>
ffffffffc0203764:	a2bfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = sm->check_swap();
ffffffffc0203768:	000a9797          	auipc	a5,0xa9
ffffffffc020376c:	db878793          	addi	a5,a5,-584 # ffffffffc02ac520 <sm>
ffffffffc0203770:	639c                	ld	a5,0(a5)
ffffffffc0203772:	7f9c                	ld	a5,56(a5)
ffffffffc0203774:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0203776:	40051c63          	bnez	a0,ffffffffc0203b8e <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc020377a:	77a2                	ld	a5,40(sp)
ffffffffc020377c:	000a9717          	auipc	a4,0xa9
ffffffffc0203780:	def72623          	sw	a5,-532(a4) # ffffffffc02ac568 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0203784:	67e2                	ld	a5,24(sp)
ffffffffc0203786:	000a9717          	auipc	a4,0xa9
ffffffffc020378a:	dcf73923          	sd	a5,-558(a4) # ffffffffc02ac558 <free_area>
ffffffffc020378e:	7782                	ld	a5,32(sp)
ffffffffc0203790:	000a9717          	auipc	a4,0xa9
ffffffffc0203794:	dcf73823          	sd	a5,-560(a4) # ffffffffc02ac560 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0203798:	0009b503          	ld	a0,0(s3)
ffffffffc020379c:	4585                	li	a1,1
ffffffffc020379e:	09a1                	addi	s3,s3,8
ffffffffc02037a0:	f72fe0ef          	jal	ra,ffffffffc0201f12 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02037a4:	ff499ae3          	bne	s3,s4,ffffffffc0203798 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc02037a8:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc02037ac:	855e                	mv	a0,s7
ffffffffc02037ae:	361000ef          	jal	ra,ffffffffc020430e <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02037b2:	000a9797          	auipc	a5,0xa9
ffffffffc02037b6:	d5e78793          	addi	a5,a5,-674 # ffffffffc02ac510 <boot_pgdir>
ffffffffc02037ba:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc02037bc:	000a9697          	auipc	a3,0xa9
ffffffffc02037c0:	ea06b623          	sd	zero,-340(a3) # ffffffffc02ac668 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc02037c4:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc02037c8:	6394                	ld	a3,0(a5)
ffffffffc02037ca:	068a                	slli	a3,a3,0x2
ffffffffc02037cc:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02037ce:	0ce6f063          	bleu	a4,a3,ffffffffc020388e <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc02037d2:	67a2                	ld	a5,8(sp)
ffffffffc02037d4:	000c3503          	ld	a0,0(s8)
ffffffffc02037d8:	8e9d                	sub	a3,a3,a5
ffffffffc02037da:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02037dc:	8699                	srai	a3,a3,0x6
ffffffffc02037de:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02037e0:	57fd                	li	a5,-1
ffffffffc02037e2:	83b1                	srli	a5,a5,0xc
ffffffffc02037e4:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02037e6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02037e8:	2ee7f763          	bleu	a4,a5,ffffffffc0203ad6 <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc02037ec:	000a9797          	auipc	a5,0xa9
ffffffffc02037f0:	d8c78793          	addi	a5,a5,-628 # ffffffffc02ac578 <va_pa_offset>
ffffffffc02037f4:	639c                	ld	a5,0(a5)
ffffffffc02037f6:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02037f8:	629c                	ld	a5,0(a3)
ffffffffc02037fa:	078a                	slli	a5,a5,0x2
ffffffffc02037fc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02037fe:	08e7f863          	bleu	a4,a5,ffffffffc020388e <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203802:	69a2                	ld	s3,8(sp)
ffffffffc0203804:	4585                	li	a1,1
ffffffffc0203806:	413787b3          	sub	a5,a5,s3
ffffffffc020380a:	079a                	slli	a5,a5,0x6
ffffffffc020380c:	953e                	add	a0,a0,a5
ffffffffc020380e:	f04fe0ef          	jal	ra,ffffffffc0201f12 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203812:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203816:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc020381a:	078a                	slli	a5,a5,0x2
ffffffffc020381c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020381e:	06e7f863          	bleu	a4,a5,ffffffffc020388e <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203822:	000c3503          	ld	a0,0(s8)
ffffffffc0203826:	413787b3          	sub	a5,a5,s3
ffffffffc020382a:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc020382c:	4585                	li	a1,1
ffffffffc020382e:	953e                	add	a0,a0,a5
ffffffffc0203830:	ee2fe0ef          	jal	ra,ffffffffc0201f12 <free_pages>
     pgdir[0] = 0;
ffffffffc0203834:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203838:	12000073          	sfence.vma
    return listelm->next;
ffffffffc020383c:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020383e:	00878963          	beq	a5,s0,ffffffffc0203850 <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203842:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203846:	679c                	ld	a5,8(a5)
ffffffffc0203848:	397d                	addiw	s2,s2,-1
ffffffffc020384a:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020384c:	fe879be3          	bne	a5,s0,ffffffffc0203842 <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc0203850:	28091f63          	bnez	s2,ffffffffc0203aee <swap_init+0x6a0>
     assert(total==0);
ffffffffc0203854:	2a049d63          	bnez	s1,ffffffffc0203b0e <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc0203858:	00004517          	auipc	a0,0x4
ffffffffc020385c:	74850513          	addi	a0,a0,1864 # ffffffffc0207fa0 <default_pmm_manager+0xa58>
ffffffffc0203860:	92ffc0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0203864:	b92d                	j	ffffffffc020349e <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0203866:	4481                	li	s1,0
ffffffffc0203868:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc020386a:	4981                	li	s3,0
ffffffffc020386c:	b17d                	j	ffffffffc020351a <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc020386e:	00004697          	auipc	a3,0x4
ffffffffc0203872:	94a68693          	addi	a3,a3,-1718 # ffffffffc02071b8 <commands+0x890>
ffffffffc0203876:	00003617          	auipc	a2,0x3
ffffffffc020387a:	58a60613          	addi	a2,a2,1418 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020387e:	0bc00593          	li	a1,188
ffffffffc0203882:	00004517          	auipc	a0,0x4
ffffffffc0203886:	4b650513          	addi	a0,a0,1206 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc020388a:	bfbfc0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020388e:	00004617          	auipc	a2,0x4
ffffffffc0203892:	d6a60613          	addi	a2,a2,-662 # ffffffffc02075f8 <default_pmm_manager+0xb0>
ffffffffc0203896:	06200593          	li	a1,98
ffffffffc020389a:	00004517          	auipc	a0,0x4
ffffffffc020389e:	d2650513          	addi	a0,a0,-730 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc02038a2:	be3fc0ef          	jal	ra,ffffffffc0200484 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02038a6:	00004697          	auipc	a3,0x4
ffffffffc02038aa:	68268693          	addi	a3,a3,1666 # ffffffffc0207f28 <default_pmm_manager+0x9e0>
ffffffffc02038ae:	00003617          	auipc	a2,0x3
ffffffffc02038b2:	55260613          	addi	a2,a2,1362 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02038b6:	0fc00593          	li	a1,252
ffffffffc02038ba:	00004517          	auipc	a0,0x4
ffffffffc02038be:	47e50513          	addi	a0,a0,1150 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc02038c2:	bc3fc0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02038c6:	00004617          	auipc	a2,0x4
ffffffffc02038ca:	fda60613          	addi	a2,a2,-38 # ffffffffc02078a0 <default_pmm_manager+0x358>
ffffffffc02038ce:	07400593          	li	a1,116
ffffffffc02038d2:	00004517          	auipc	a0,0x4
ffffffffc02038d6:	cee50513          	addi	a0,a0,-786 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc02038da:	babfc0ef          	jal	ra,ffffffffc0200484 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc02038de:	00004697          	auipc	a3,0x4
ffffffffc02038e2:	58268693          	addi	a3,a3,1410 # ffffffffc0207e60 <default_pmm_manager+0x918>
ffffffffc02038e6:	00003617          	auipc	a2,0x3
ffffffffc02038ea:	51a60613          	addi	a2,a2,1306 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02038ee:	0dd00593          	li	a1,221
ffffffffc02038f2:	00004517          	auipc	a0,0x4
ffffffffc02038f6:	44650513          	addi	a0,a0,1094 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc02038fa:	b8bfc0ef          	jal	ra,ffffffffc0200484 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc02038fe:	00004697          	auipc	a3,0x4
ffffffffc0203902:	54a68693          	addi	a3,a3,1354 # ffffffffc0207e48 <default_pmm_manager+0x900>
ffffffffc0203906:	00003617          	auipc	a2,0x3
ffffffffc020390a:	4fa60613          	addi	a2,a2,1274 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020390e:	0dc00593          	li	a1,220
ffffffffc0203912:	00004517          	auipc	a0,0x4
ffffffffc0203916:	42650513          	addi	a0,a0,1062 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc020391a:	b6bfc0ef          	jal	ra,ffffffffc0200484 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc020391e:	00004697          	auipc	a3,0x4
ffffffffc0203922:	5f268693          	addi	a3,a3,1522 # ffffffffc0207f10 <default_pmm_manager+0x9c8>
ffffffffc0203926:	00003617          	auipc	a2,0x3
ffffffffc020392a:	4da60613          	addi	a2,a2,1242 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020392e:	0fb00593          	li	a1,251
ffffffffc0203932:	00004517          	auipc	a0,0x4
ffffffffc0203936:	40650513          	addi	a0,a0,1030 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc020393a:	b4bfc0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020393e:	00004617          	auipc	a2,0x4
ffffffffc0203942:	3da60613          	addi	a2,a2,986 # ffffffffc0207d18 <default_pmm_manager+0x7d0>
ffffffffc0203946:	02800593          	li	a1,40
ffffffffc020394a:	00004517          	auipc	a0,0x4
ffffffffc020394e:	3ee50513          	addi	a0,a0,1006 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc0203952:	b33fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==2);
ffffffffc0203956:	00004697          	auipc	a3,0x4
ffffffffc020395a:	58a68693          	addi	a3,a3,1418 # ffffffffc0207ee0 <default_pmm_manager+0x998>
ffffffffc020395e:	00003617          	auipc	a2,0x3
ffffffffc0203962:	4a260613          	addi	a2,a2,1186 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203966:	09700593          	li	a1,151
ffffffffc020396a:	00004517          	auipc	a0,0x4
ffffffffc020396e:	3ce50513          	addi	a0,a0,974 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc0203972:	b13fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==2);
ffffffffc0203976:	00004697          	auipc	a3,0x4
ffffffffc020397a:	56a68693          	addi	a3,a3,1386 # ffffffffc0207ee0 <default_pmm_manager+0x998>
ffffffffc020397e:	00003617          	auipc	a2,0x3
ffffffffc0203982:	48260613          	addi	a2,a2,1154 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203986:	09900593          	li	a1,153
ffffffffc020398a:	00004517          	auipc	a0,0x4
ffffffffc020398e:	3ae50513          	addi	a0,a0,942 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc0203992:	af3fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==3);
ffffffffc0203996:	00004697          	auipc	a3,0x4
ffffffffc020399a:	55a68693          	addi	a3,a3,1370 # ffffffffc0207ef0 <default_pmm_manager+0x9a8>
ffffffffc020399e:	00003617          	auipc	a2,0x3
ffffffffc02039a2:	46260613          	addi	a2,a2,1122 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02039a6:	09b00593          	li	a1,155
ffffffffc02039aa:	00004517          	auipc	a0,0x4
ffffffffc02039ae:	38e50513          	addi	a0,a0,910 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc02039b2:	ad3fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==3);
ffffffffc02039b6:	00004697          	auipc	a3,0x4
ffffffffc02039ba:	53a68693          	addi	a3,a3,1338 # ffffffffc0207ef0 <default_pmm_manager+0x9a8>
ffffffffc02039be:	00003617          	auipc	a2,0x3
ffffffffc02039c2:	44260613          	addi	a2,a2,1090 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02039c6:	09d00593          	li	a1,157
ffffffffc02039ca:	00004517          	auipc	a0,0x4
ffffffffc02039ce:	36e50513          	addi	a0,a0,878 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc02039d2:	ab3fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==1);
ffffffffc02039d6:	00004697          	auipc	a3,0x4
ffffffffc02039da:	4fa68693          	addi	a3,a3,1274 # ffffffffc0207ed0 <default_pmm_manager+0x988>
ffffffffc02039de:	00003617          	auipc	a2,0x3
ffffffffc02039e2:	42260613          	addi	a2,a2,1058 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02039e6:	09300593          	li	a1,147
ffffffffc02039ea:	00004517          	auipc	a0,0x4
ffffffffc02039ee:	34e50513          	addi	a0,a0,846 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc02039f2:	a93fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==1);
ffffffffc02039f6:	00004697          	auipc	a3,0x4
ffffffffc02039fa:	4da68693          	addi	a3,a3,1242 # ffffffffc0207ed0 <default_pmm_manager+0x988>
ffffffffc02039fe:	00003617          	auipc	a2,0x3
ffffffffc0203a02:	40260613          	addi	a2,a2,1026 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203a06:	09500593          	li	a1,149
ffffffffc0203a0a:	00004517          	auipc	a0,0x4
ffffffffc0203a0e:	32e50513          	addi	a0,a0,814 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc0203a12:	a73fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==4);
ffffffffc0203a16:	00004697          	auipc	a3,0x4
ffffffffc0203a1a:	4ea68693          	addi	a3,a3,1258 # ffffffffc0207f00 <default_pmm_manager+0x9b8>
ffffffffc0203a1e:	00003617          	auipc	a2,0x3
ffffffffc0203a22:	3e260613          	addi	a2,a2,994 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203a26:	09f00593          	li	a1,159
ffffffffc0203a2a:	00004517          	auipc	a0,0x4
ffffffffc0203a2e:	30e50513          	addi	a0,a0,782 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc0203a32:	a53fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==4);
ffffffffc0203a36:	00004697          	auipc	a3,0x4
ffffffffc0203a3a:	4ca68693          	addi	a3,a3,1226 # ffffffffc0207f00 <default_pmm_manager+0x9b8>
ffffffffc0203a3e:	00003617          	auipc	a2,0x3
ffffffffc0203a42:	3c260613          	addi	a2,a2,962 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203a46:	0a100593          	li	a1,161
ffffffffc0203a4a:	00004517          	auipc	a0,0x4
ffffffffc0203a4e:	2ee50513          	addi	a0,a0,750 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc0203a52:	a33fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203a56:	00004697          	auipc	a3,0x4
ffffffffc0203a5a:	35a68693          	addi	a3,a3,858 # ffffffffc0207db0 <default_pmm_manager+0x868>
ffffffffc0203a5e:	00003617          	auipc	a2,0x3
ffffffffc0203a62:	3a260613          	addi	a2,a2,930 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203a66:	0cc00593          	li	a1,204
ffffffffc0203a6a:	00004517          	auipc	a0,0x4
ffffffffc0203a6e:	2ce50513          	addi	a0,a0,718 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc0203a72:	a13fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(vma != NULL);
ffffffffc0203a76:	00004697          	auipc	a3,0x4
ffffffffc0203a7a:	34a68693          	addi	a3,a3,842 # ffffffffc0207dc0 <default_pmm_manager+0x878>
ffffffffc0203a7e:	00003617          	auipc	a2,0x3
ffffffffc0203a82:	38260613          	addi	a2,a2,898 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203a86:	0cf00593          	li	a1,207
ffffffffc0203a8a:	00004517          	auipc	a0,0x4
ffffffffc0203a8e:	2ae50513          	addi	a0,a0,686 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc0203a92:	9f3fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203a96:	00004697          	auipc	a3,0x4
ffffffffc0203a9a:	37268693          	addi	a3,a3,882 # ffffffffc0207e08 <default_pmm_manager+0x8c0>
ffffffffc0203a9e:	00003617          	auipc	a2,0x3
ffffffffc0203aa2:	36260613          	addi	a2,a2,866 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203aa6:	0d700593          	li	a1,215
ffffffffc0203aaa:	00004517          	auipc	a0,0x4
ffffffffc0203aae:	28e50513          	addi	a0,a0,654 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc0203ab2:	9d3fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert( nr_free == 0);         
ffffffffc0203ab6:	00004697          	auipc	a3,0x4
ffffffffc0203aba:	8d268693          	addi	a3,a3,-1838 # ffffffffc0207388 <commands+0xa60>
ffffffffc0203abe:	00003617          	auipc	a2,0x3
ffffffffc0203ac2:	34260613          	addi	a2,a2,834 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203ac6:	0f300593          	li	a1,243
ffffffffc0203aca:	00004517          	auipc	a0,0x4
ffffffffc0203ace:	26e50513          	addi	a0,a0,622 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc0203ad2:	9b3fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203ad6:	00004617          	auipc	a2,0x4
ffffffffc0203ada:	ac260613          	addi	a2,a2,-1342 # ffffffffc0207598 <default_pmm_manager+0x50>
ffffffffc0203ade:	06900593          	li	a1,105
ffffffffc0203ae2:	00004517          	auipc	a0,0x4
ffffffffc0203ae6:	ade50513          	addi	a0,a0,-1314 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0203aea:	99bfc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(count==0);
ffffffffc0203aee:	00004697          	auipc	a3,0x4
ffffffffc0203af2:	49268693          	addi	a3,a3,1170 # ffffffffc0207f80 <default_pmm_manager+0xa38>
ffffffffc0203af6:	00003617          	auipc	a2,0x3
ffffffffc0203afa:	30a60613          	addi	a2,a2,778 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203afe:	11d00593          	li	a1,285
ffffffffc0203b02:	00004517          	auipc	a0,0x4
ffffffffc0203b06:	23650513          	addi	a0,a0,566 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc0203b0a:	97bfc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(total==0);
ffffffffc0203b0e:	00004697          	auipc	a3,0x4
ffffffffc0203b12:	48268693          	addi	a3,a3,1154 # ffffffffc0207f90 <default_pmm_manager+0xa48>
ffffffffc0203b16:	00003617          	auipc	a2,0x3
ffffffffc0203b1a:	2ea60613          	addi	a2,a2,746 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203b1e:	11e00593          	li	a1,286
ffffffffc0203b22:	00004517          	auipc	a0,0x4
ffffffffc0203b26:	21650513          	addi	a0,a0,534 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc0203b2a:	95bfc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203b2e:	00004697          	auipc	a3,0x4
ffffffffc0203b32:	35268693          	addi	a3,a3,850 # ffffffffc0207e80 <default_pmm_manager+0x938>
ffffffffc0203b36:	00003617          	auipc	a2,0x3
ffffffffc0203b3a:	2ca60613          	addi	a2,a2,714 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203b3e:	0ea00593          	li	a1,234
ffffffffc0203b42:	00004517          	auipc	a0,0x4
ffffffffc0203b46:	1f650513          	addi	a0,a0,502 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc0203b4a:	93bfc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(mm != NULL);
ffffffffc0203b4e:	00004697          	auipc	a3,0x4
ffffffffc0203b52:	23a68693          	addi	a3,a3,570 # ffffffffc0207d88 <default_pmm_manager+0x840>
ffffffffc0203b56:	00003617          	auipc	a2,0x3
ffffffffc0203b5a:	2aa60613          	addi	a2,a2,682 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203b5e:	0c400593          	li	a1,196
ffffffffc0203b62:	00004517          	auipc	a0,0x4
ffffffffc0203b66:	1d650513          	addi	a0,a0,470 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc0203b6a:	91bfc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203b6e:	00004697          	auipc	a3,0x4
ffffffffc0203b72:	22a68693          	addi	a3,a3,554 # ffffffffc0207d98 <default_pmm_manager+0x850>
ffffffffc0203b76:	00003617          	auipc	a2,0x3
ffffffffc0203b7a:	28a60613          	addi	a2,a2,650 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203b7e:	0c700593          	li	a1,199
ffffffffc0203b82:	00004517          	auipc	a0,0x4
ffffffffc0203b86:	1b650513          	addi	a0,a0,438 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc0203b8a:	8fbfc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(ret==0);
ffffffffc0203b8e:	00004697          	auipc	a3,0x4
ffffffffc0203b92:	3ea68693          	addi	a3,a3,1002 # ffffffffc0207f78 <default_pmm_manager+0xa30>
ffffffffc0203b96:	00003617          	auipc	a2,0x3
ffffffffc0203b9a:	26a60613          	addi	a2,a2,618 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203b9e:	10200593          	li	a1,258
ffffffffc0203ba2:	00004517          	auipc	a0,0x4
ffffffffc0203ba6:	19650513          	addi	a0,a0,406 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc0203baa:	8dbfc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203bae:	00003697          	auipc	a3,0x3
ffffffffc0203bb2:	63268693          	addi	a3,a3,1586 # ffffffffc02071e0 <commands+0x8b8>
ffffffffc0203bb6:	00003617          	auipc	a2,0x3
ffffffffc0203bba:	24a60613          	addi	a2,a2,586 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203bbe:	0bf00593          	li	a1,191
ffffffffc0203bc2:	00004517          	auipc	a0,0x4
ffffffffc0203bc6:	17650513          	addi	a0,a0,374 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc0203bca:	8bbfc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203bce <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203bce:	000a9797          	auipc	a5,0xa9
ffffffffc0203bd2:	95278793          	addi	a5,a5,-1710 # ffffffffc02ac520 <sm>
ffffffffc0203bd6:	639c                	ld	a5,0(a5)
ffffffffc0203bd8:	0107b303          	ld	t1,16(a5)
ffffffffc0203bdc:	8302                	jr	t1

ffffffffc0203bde <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203bde:	000a9797          	auipc	a5,0xa9
ffffffffc0203be2:	94278793          	addi	a5,a5,-1726 # ffffffffc02ac520 <sm>
ffffffffc0203be6:	639c                	ld	a5,0(a5)
ffffffffc0203be8:	0207b303          	ld	t1,32(a5)
ffffffffc0203bec:	8302                	jr	t1

ffffffffc0203bee <swap_out>:
{
ffffffffc0203bee:	711d                	addi	sp,sp,-96
ffffffffc0203bf0:	ec86                	sd	ra,88(sp)
ffffffffc0203bf2:	e8a2                	sd	s0,80(sp)
ffffffffc0203bf4:	e4a6                	sd	s1,72(sp)
ffffffffc0203bf6:	e0ca                	sd	s2,64(sp)
ffffffffc0203bf8:	fc4e                	sd	s3,56(sp)
ffffffffc0203bfa:	f852                	sd	s4,48(sp)
ffffffffc0203bfc:	f456                	sd	s5,40(sp)
ffffffffc0203bfe:	f05a                	sd	s6,32(sp)
ffffffffc0203c00:	ec5e                	sd	s7,24(sp)
ffffffffc0203c02:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203c04:	cde9                	beqz	a1,ffffffffc0203cde <swap_out+0xf0>
ffffffffc0203c06:	8ab2                	mv	s5,a2
ffffffffc0203c08:	892a                	mv	s2,a0
ffffffffc0203c0a:	8a2e                	mv	s4,a1
ffffffffc0203c0c:	4401                	li	s0,0
ffffffffc0203c0e:	000a9997          	auipc	s3,0xa9
ffffffffc0203c12:	91298993          	addi	s3,s3,-1774 # ffffffffc02ac520 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203c16:	00004b17          	auipc	s6,0x4
ffffffffc0203c1a:	40ab0b13          	addi	s6,s6,1034 # ffffffffc0208020 <default_pmm_manager+0xad8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203c1e:	00004b97          	auipc	s7,0x4
ffffffffc0203c22:	3eab8b93          	addi	s7,s7,1002 # ffffffffc0208008 <default_pmm_manager+0xac0>
ffffffffc0203c26:	a825                	j	ffffffffc0203c5e <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203c28:	67a2                	ld	a5,8(sp)
ffffffffc0203c2a:	8626                	mv	a2,s1
ffffffffc0203c2c:	85a2                	mv	a1,s0
ffffffffc0203c2e:	7f94                	ld	a3,56(a5)
ffffffffc0203c30:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203c32:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203c34:	82b1                	srli	a3,a3,0xc
ffffffffc0203c36:	0685                	addi	a3,a3,1
ffffffffc0203c38:	d56fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203c3c:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203c3e:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203c40:	7d1c                	ld	a5,56(a0)
ffffffffc0203c42:	83b1                	srli	a5,a5,0xc
ffffffffc0203c44:	0785                	addi	a5,a5,1
ffffffffc0203c46:	07a2                	slli	a5,a5,0x8
ffffffffc0203c48:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203c4c:	ac6fe0ef          	jal	ra,ffffffffc0201f12 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203c50:	01893503          	ld	a0,24(s2)
ffffffffc0203c54:	85a6                	mv	a1,s1
ffffffffc0203c56:	f5eff0ef          	jal	ra,ffffffffc02033b4 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203c5a:	048a0d63          	beq	s4,s0,ffffffffc0203cb4 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203c5e:	0009b783          	ld	a5,0(s3)
ffffffffc0203c62:	8656                	mv	a2,s5
ffffffffc0203c64:	002c                	addi	a1,sp,8
ffffffffc0203c66:	7b9c                	ld	a5,48(a5)
ffffffffc0203c68:	854a                	mv	a0,s2
ffffffffc0203c6a:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203c6c:	e12d                	bnez	a0,ffffffffc0203cce <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203c6e:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203c70:	01893503          	ld	a0,24(s2)
ffffffffc0203c74:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203c76:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203c78:	85a6                	mv	a1,s1
ffffffffc0203c7a:	b1efe0ef          	jal	ra,ffffffffc0201f98 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c7e:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203c80:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c82:	8b85                	andi	a5,a5,1
ffffffffc0203c84:	cfb9                	beqz	a5,ffffffffc0203ce2 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203c86:	65a2                	ld	a1,8(sp)
ffffffffc0203c88:	7d9c                	ld	a5,56(a1)
ffffffffc0203c8a:	83b1                	srli	a5,a5,0xc
ffffffffc0203c8c:	00178513          	addi	a0,a5,1
ffffffffc0203c90:	0522                	slli	a0,a0,0x8
ffffffffc0203c92:	146010ef          	jal	ra,ffffffffc0204dd8 <swapfs_write>
ffffffffc0203c96:	d949                	beqz	a0,ffffffffc0203c28 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203c98:	855e                	mv	a0,s7
ffffffffc0203c9a:	cf4fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203c9e:	0009b783          	ld	a5,0(s3)
ffffffffc0203ca2:	6622                	ld	a2,8(sp)
ffffffffc0203ca4:	4681                	li	a3,0
ffffffffc0203ca6:	739c                	ld	a5,32(a5)
ffffffffc0203ca8:	85a6                	mv	a1,s1
ffffffffc0203caa:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203cac:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203cae:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203cb0:	fa8a17e3          	bne	s4,s0,ffffffffc0203c5e <swap_out+0x70>
}
ffffffffc0203cb4:	8522                	mv	a0,s0
ffffffffc0203cb6:	60e6                	ld	ra,88(sp)
ffffffffc0203cb8:	6446                	ld	s0,80(sp)
ffffffffc0203cba:	64a6                	ld	s1,72(sp)
ffffffffc0203cbc:	6906                	ld	s2,64(sp)
ffffffffc0203cbe:	79e2                	ld	s3,56(sp)
ffffffffc0203cc0:	7a42                	ld	s4,48(sp)
ffffffffc0203cc2:	7aa2                	ld	s5,40(sp)
ffffffffc0203cc4:	7b02                	ld	s6,32(sp)
ffffffffc0203cc6:	6be2                	ld	s7,24(sp)
ffffffffc0203cc8:	6c42                	ld	s8,16(sp)
ffffffffc0203cca:	6125                	addi	sp,sp,96
ffffffffc0203ccc:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203cce:	85a2                	mv	a1,s0
ffffffffc0203cd0:	00004517          	auipc	a0,0x4
ffffffffc0203cd4:	2f050513          	addi	a0,a0,752 # ffffffffc0207fc0 <default_pmm_manager+0xa78>
ffffffffc0203cd8:	cb6fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                  break;
ffffffffc0203cdc:	bfe1                	j	ffffffffc0203cb4 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203cde:	4401                	li	s0,0
ffffffffc0203ce0:	bfd1                	j	ffffffffc0203cb4 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203ce2:	00004697          	auipc	a3,0x4
ffffffffc0203ce6:	30e68693          	addi	a3,a3,782 # ffffffffc0207ff0 <default_pmm_manager+0xaa8>
ffffffffc0203cea:	00003617          	auipc	a2,0x3
ffffffffc0203cee:	11660613          	addi	a2,a2,278 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203cf2:	06800593          	li	a1,104
ffffffffc0203cf6:	00004517          	auipc	a0,0x4
ffffffffc0203cfa:	04250513          	addi	a0,a0,66 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc0203cfe:	f86fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203d02 <swap_in>:
{
ffffffffc0203d02:	7179                	addi	sp,sp,-48
ffffffffc0203d04:	e84a                	sd	s2,16(sp)
ffffffffc0203d06:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203d08:	4505                	li	a0,1
{
ffffffffc0203d0a:	ec26                	sd	s1,24(sp)
ffffffffc0203d0c:	e44e                	sd	s3,8(sp)
ffffffffc0203d0e:	f406                	sd	ra,40(sp)
ffffffffc0203d10:	f022                	sd	s0,32(sp)
ffffffffc0203d12:	84ae                	mv	s1,a1
ffffffffc0203d14:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203d16:	974fe0ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
     assert(result!=NULL);
ffffffffc0203d1a:	c129                	beqz	a0,ffffffffc0203d5c <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203d1c:	842a                	mv	s0,a0
ffffffffc0203d1e:	01893503          	ld	a0,24(s2)
ffffffffc0203d22:	4601                	li	a2,0
ffffffffc0203d24:	85a6                	mv	a1,s1
ffffffffc0203d26:	a72fe0ef          	jal	ra,ffffffffc0201f98 <get_pte>
ffffffffc0203d2a:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203d2c:	6108                	ld	a0,0(a0)
ffffffffc0203d2e:	85a2                	mv	a1,s0
ffffffffc0203d30:	010010ef          	jal	ra,ffffffffc0204d40 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203d34:	00093583          	ld	a1,0(s2)
ffffffffc0203d38:	8626                	mv	a2,s1
ffffffffc0203d3a:	00004517          	auipc	a0,0x4
ffffffffc0203d3e:	f9e50513          	addi	a0,a0,-98 # ffffffffc0207cd8 <default_pmm_manager+0x790>
ffffffffc0203d42:	81a1                	srli	a1,a1,0x8
ffffffffc0203d44:	c4afc0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0203d48:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203d4a:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203d4e:	7402                	ld	s0,32(sp)
ffffffffc0203d50:	64e2                	ld	s1,24(sp)
ffffffffc0203d52:	6942                	ld	s2,16(sp)
ffffffffc0203d54:	69a2                	ld	s3,8(sp)
ffffffffc0203d56:	4501                	li	a0,0
ffffffffc0203d58:	6145                	addi	sp,sp,48
ffffffffc0203d5a:	8082                	ret
     assert(result!=NULL);
ffffffffc0203d5c:	00004697          	auipc	a3,0x4
ffffffffc0203d60:	f6c68693          	addi	a3,a3,-148 # ffffffffc0207cc8 <default_pmm_manager+0x780>
ffffffffc0203d64:	00003617          	auipc	a2,0x3
ffffffffc0203d68:	09c60613          	addi	a2,a2,156 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203d6c:	07e00593          	li	a1,126
ffffffffc0203d70:	00004517          	auipc	a0,0x4
ffffffffc0203d74:	fc850513          	addi	a0,a0,-56 # ffffffffc0207d38 <default_pmm_manager+0x7f0>
ffffffffc0203d78:	f0cfc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203d7c <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203d7c:	000a9797          	auipc	a5,0xa9
ffffffffc0203d80:	8dc78793          	addi	a5,a5,-1828 # ffffffffc02ac658 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203d84:	f51c                	sd	a5,40(a0)
ffffffffc0203d86:	e79c                	sd	a5,8(a5)
ffffffffc0203d88:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203d8a:	4501                	li	a0,0
ffffffffc0203d8c:	8082                	ret

ffffffffc0203d8e <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203d8e:	4501                	li	a0,0
ffffffffc0203d90:	8082                	ret

ffffffffc0203d92 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203d92:	4501                	li	a0,0
ffffffffc0203d94:	8082                	ret

ffffffffc0203d96 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203d96:	4501                	li	a0,0
ffffffffc0203d98:	8082                	ret

ffffffffc0203d9a <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203d9a:	711d                	addi	sp,sp,-96
ffffffffc0203d9c:	fc4e                	sd	s3,56(sp)
ffffffffc0203d9e:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203da0:	00004517          	auipc	a0,0x4
ffffffffc0203da4:	2c050513          	addi	a0,a0,704 # ffffffffc0208060 <default_pmm_manager+0xb18>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203da8:	698d                	lui	s3,0x3
ffffffffc0203daa:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203dac:	e8a2                	sd	s0,80(sp)
ffffffffc0203dae:	e4a6                	sd	s1,72(sp)
ffffffffc0203db0:	ec86                	sd	ra,88(sp)
ffffffffc0203db2:	e0ca                	sd	s2,64(sp)
ffffffffc0203db4:	f456                	sd	s5,40(sp)
ffffffffc0203db6:	f05a                	sd	s6,32(sp)
ffffffffc0203db8:	ec5e                	sd	s7,24(sp)
ffffffffc0203dba:	e862                	sd	s8,16(sp)
ffffffffc0203dbc:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0203dbe:	000a8417          	auipc	s0,0xa8
ffffffffc0203dc2:	76e40413          	addi	s0,s0,1902 # ffffffffc02ac52c <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203dc6:	bc8fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203dca:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6578>
    assert(pgfault_num==4);
ffffffffc0203dce:	4004                	lw	s1,0(s0)
ffffffffc0203dd0:	4791                	li	a5,4
ffffffffc0203dd2:	2481                	sext.w	s1,s1
ffffffffc0203dd4:	14f49963          	bne	s1,a5,ffffffffc0203f26 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203dd8:	00004517          	auipc	a0,0x4
ffffffffc0203ddc:	2c850513          	addi	a0,a0,712 # ffffffffc02080a0 <default_pmm_manager+0xb58>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203de0:	6a85                	lui	s5,0x1
ffffffffc0203de2:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203de4:	baafc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203de8:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
    assert(pgfault_num==4);
ffffffffc0203dec:	00042903          	lw	s2,0(s0)
ffffffffc0203df0:	2901                	sext.w	s2,s2
ffffffffc0203df2:	2a991a63          	bne	s2,s1,ffffffffc02040a6 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203df6:	00004517          	auipc	a0,0x4
ffffffffc0203dfa:	2d250513          	addi	a0,a0,722 # ffffffffc02080c8 <default_pmm_manager+0xb80>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203dfe:	6b91                	lui	s7,0x4
ffffffffc0203e00:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203e02:	b8cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203e06:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5578>
    assert(pgfault_num==4);
ffffffffc0203e0a:	4004                	lw	s1,0(s0)
ffffffffc0203e0c:	2481                	sext.w	s1,s1
ffffffffc0203e0e:	27249c63          	bne	s1,s2,ffffffffc0204086 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203e12:	00004517          	auipc	a0,0x4
ffffffffc0203e16:	2de50513          	addi	a0,a0,734 # ffffffffc02080f0 <default_pmm_manager+0xba8>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203e1a:	6909                	lui	s2,0x2
ffffffffc0203e1c:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203e1e:	b70fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203e22:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x7578>
    assert(pgfault_num==4);
ffffffffc0203e26:	401c                	lw	a5,0(s0)
ffffffffc0203e28:	2781                	sext.w	a5,a5
ffffffffc0203e2a:	22979e63          	bne	a5,s1,ffffffffc0204066 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203e2e:	00004517          	auipc	a0,0x4
ffffffffc0203e32:	2ea50513          	addi	a0,a0,746 # ffffffffc0208118 <default_pmm_manager+0xbd0>
ffffffffc0203e36:	b58fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203e3a:	6795                	lui	a5,0x5
ffffffffc0203e3c:	4739                	li	a4,14
ffffffffc0203e3e:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4578>
    assert(pgfault_num==5);
ffffffffc0203e42:	4004                	lw	s1,0(s0)
ffffffffc0203e44:	4795                	li	a5,5
ffffffffc0203e46:	2481                	sext.w	s1,s1
ffffffffc0203e48:	1ef49f63          	bne	s1,a5,ffffffffc0204046 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203e4c:	00004517          	auipc	a0,0x4
ffffffffc0203e50:	2a450513          	addi	a0,a0,676 # ffffffffc02080f0 <default_pmm_manager+0xba8>
ffffffffc0203e54:	b3afc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203e58:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203e5c:	401c                	lw	a5,0(s0)
ffffffffc0203e5e:	2781                	sext.w	a5,a5
ffffffffc0203e60:	1c979363          	bne	a5,s1,ffffffffc0204026 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203e64:	00004517          	auipc	a0,0x4
ffffffffc0203e68:	23c50513          	addi	a0,a0,572 # ffffffffc02080a0 <default_pmm_manager+0xb58>
ffffffffc0203e6c:	b22fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203e70:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203e74:	401c                	lw	a5,0(s0)
ffffffffc0203e76:	4719                	li	a4,6
ffffffffc0203e78:	2781                	sext.w	a5,a5
ffffffffc0203e7a:	18e79663          	bne	a5,a4,ffffffffc0204006 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203e7e:	00004517          	auipc	a0,0x4
ffffffffc0203e82:	27250513          	addi	a0,a0,626 # ffffffffc02080f0 <default_pmm_manager+0xba8>
ffffffffc0203e86:	b08fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203e8a:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203e8e:	401c                	lw	a5,0(s0)
ffffffffc0203e90:	471d                	li	a4,7
ffffffffc0203e92:	2781                	sext.w	a5,a5
ffffffffc0203e94:	14e79963          	bne	a5,a4,ffffffffc0203fe6 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203e98:	00004517          	auipc	a0,0x4
ffffffffc0203e9c:	1c850513          	addi	a0,a0,456 # ffffffffc0208060 <default_pmm_manager+0xb18>
ffffffffc0203ea0:	aeefc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203ea4:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203ea8:	401c                	lw	a5,0(s0)
ffffffffc0203eaa:	4721                	li	a4,8
ffffffffc0203eac:	2781                	sext.w	a5,a5
ffffffffc0203eae:	10e79c63          	bne	a5,a4,ffffffffc0203fc6 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203eb2:	00004517          	auipc	a0,0x4
ffffffffc0203eb6:	21650513          	addi	a0,a0,534 # ffffffffc02080c8 <default_pmm_manager+0xb80>
ffffffffc0203eba:	ad4fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203ebe:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203ec2:	401c                	lw	a5,0(s0)
ffffffffc0203ec4:	4725                	li	a4,9
ffffffffc0203ec6:	2781                	sext.w	a5,a5
ffffffffc0203ec8:	0ce79f63          	bne	a5,a4,ffffffffc0203fa6 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203ecc:	00004517          	auipc	a0,0x4
ffffffffc0203ed0:	24c50513          	addi	a0,a0,588 # ffffffffc0208118 <default_pmm_manager+0xbd0>
ffffffffc0203ed4:	abafc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203ed8:	6795                	lui	a5,0x5
ffffffffc0203eda:	4739                	li	a4,14
ffffffffc0203edc:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4578>
    assert(pgfault_num==10);
ffffffffc0203ee0:	4004                	lw	s1,0(s0)
ffffffffc0203ee2:	47a9                	li	a5,10
ffffffffc0203ee4:	2481                	sext.w	s1,s1
ffffffffc0203ee6:	0af49063          	bne	s1,a5,ffffffffc0203f86 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203eea:	00004517          	auipc	a0,0x4
ffffffffc0203eee:	1b650513          	addi	a0,a0,438 # ffffffffc02080a0 <default_pmm_manager+0xb58>
ffffffffc0203ef2:	a9cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203ef6:	6785                	lui	a5,0x1
ffffffffc0203ef8:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
ffffffffc0203efc:	06979563          	bne	a5,s1,ffffffffc0203f66 <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0203f00:	401c                	lw	a5,0(s0)
ffffffffc0203f02:	472d                	li	a4,11
ffffffffc0203f04:	2781                	sext.w	a5,a5
ffffffffc0203f06:	04e79063          	bne	a5,a4,ffffffffc0203f46 <_fifo_check_swap+0x1ac>
}
ffffffffc0203f0a:	60e6                	ld	ra,88(sp)
ffffffffc0203f0c:	6446                	ld	s0,80(sp)
ffffffffc0203f0e:	64a6                	ld	s1,72(sp)
ffffffffc0203f10:	6906                	ld	s2,64(sp)
ffffffffc0203f12:	79e2                	ld	s3,56(sp)
ffffffffc0203f14:	7a42                	ld	s4,48(sp)
ffffffffc0203f16:	7aa2                	ld	s5,40(sp)
ffffffffc0203f18:	7b02                	ld	s6,32(sp)
ffffffffc0203f1a:	6be2                	ld	s7,24(sp)
ffffffffc0203f1c:	6c42                	ld	s8,16(sp)
ffffffffc0203f1e:	6ca2                	ld	s9,8(sp)
ffffffffc0203f20:	4501                	li	a0,0
ffffffffc0203f22:	6125                	addi	sp,sp,96
ffffffffc0203f24:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203f26:	00004697          	auipc	a3,0x4
ffffffffc0203f2a:	fda68693          	addi	a3,a3,-38 # ffffffffc0207f00 <default_pmm_manager+0x9b8>
ffffffffc0203f2e:	00003617          	auipc	a2,0x3
ffffffffc0203f32:	ed260613          	addi	a2,a2,-302 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203f36:	05100593          	li	a1,81
ffffffffc0203f3a:	00004517          	auipc	a0,0x4
ffffffffc0203f3e:	14e50513          	addi	a0,a0,334 # ffffffffc0208088 <default_pmm_manager+0xb40>
ffffffffc0203f42:	d42fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==11);
ffffffffc0203f46:	00004697          	auipc	a3,0x4
ffffffffc0203f4a:	28268693          	addi	a3,a3,642 # ffffffffc02081c8 <default_pmm_manager+0xc80>
ffffffffc0203f4e:	00003617          	auipc	a2,0x3
ffffffffc0203f52:	eb260613          	addi	a2,a2,-334 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203f56:	07300593          	li	a1,115
ffffffffc0203f5a:	00004517          	auipc	a0,0x4
ffffffffc0203f5e:	12e50513          	addi	a0,a0,302 # ffffffffc0208088 <default_pmm_manager+0xb40>
ffffffffc0203f62:	d22fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203f66:	00004697          	auipc	a3,0x4
ffffffffc0203f6a:	23a68693          	addi	a3,a3,570 # ffffffffc02081a0 <default_pmm_manager+0xc58>
ffffffffc0203f6e:	00003617          	auipc	a2,0x3
ffffffffc0203f72:	e9260613          	addi	a2,a2,-366 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203f76:	07100593          	li	a1,113
ffffffffc0203f7a:	00004517          	auipc	a0,0x4
ffffffffc0203f7e:	10e50513          	addi	a0,a0,270 # ffffffffc0208088 <default_pmm_manager+0xb40>
ffffffffc0203f82:	d02fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==10);
ffffffffc0203f86:	00004697          	auipc	a3,0x4
ffffffffc0203f8a:	20a68693          	addi	a3,a3,522 # ffffffffc0208190 <default_pmm_manager+0xc48>
ffffffffc0203f8e:	00003617          	auipc	a2,0x3
ffffffffc0203f92:	e7260613          	addi	a2,a2,-398 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203f96:	06f00593          	li	a1,111
ffffffffc0203f9a:	00004517          	auipc	a0,0x4
ffffffffc0203f9e:	0ee50513          	addi	a0,a0,238 # ffffffffc0208088 <default_pmm_manager+0xb40>
ffffffffc0203fa2:	ce2fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==9);
ffffffffc0203fa6:	00004697          	auipc	a3,0x4
ffffffffc0203faa:	1da68693          	addi	a3,a3,474 # ffffffffc0208180 <default_pmm_manager+0xc38>
ffffffffc0203fae:	00003617          	auipc	a2,0x3
ffffffffc0203fb2:	e5260613          	addi	a2,a2,-430 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203fb6:	06c00593          	li	a1,108
ffffffffc0203fba:	00004517          	auipc	a0,0x4
ffffffffc0203fbe:	0ce50513          	addi	a0,a0,206 # ffffffffc0208088 <default_pmm_manager+0xb40>
ffffffffc0203fc2:	cc2fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==8);
ffffffffc0203fc6:	00004697          	auipc	a3,0x4
ffffffffc0203fca:	1aa68693          	addi	a3,a3,426 # ffffffffc0208170 <default_pmm_manager+0xc28>
ffffffffc0203fce:	00003617          	auipc	a2,0x3
ffffffffc0203fd2:	e3260613          	addi	a2,a2,-462 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203fd6:	06900593          	li	a1,105
ffffffffc0203fda:	00004517          	auipc	a0,0x4
ffffffffc0203fde:	0ae50513          	addi	a0,a0,174 # ffffffffc0208088 <default_pmm_manager+0xb40>
ffffffffc0203fe2:	ca2fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==7);
ffffffffc0203fe6:	00004697          	auipc	a3,0x4
ffffffffc0203fea:	17a68693          	addi	a3,a3,378 # ffffffffc0208160 <default_pmm_manager+0xc18>
ffffffffc0203fee:	00003617          	auipc	a2,0x3
ffffffffc0203ff2:	e1260613          	addi	a2,a2,-494 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0203ff6:	06600593          	li	a1,102
ffffffffc0203ffa:	00004517          	auipc	a0,0x4
ffffffffc0203ffe:	08e50513          	addi	a0,a0,142 # ffffffffc0208088 <default_pmm_manager+0xb40>
ffffffffc0204002:	c82fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==6);
ffffffffc0204006:	00004697          	auipc	a3,0x4
ffffffffc020400a:	14a68693          	addi	a3,a3,330 # ffffffffc0208150 <default_pmm_manager+0xc08>
ffffffffc020400e:	00003617          	auipc	a2,0x3
ffffffffc0204012:	df260613          	addi	a2,a2,-526 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0204016:	06300593          	li	a1,99
ffffffffc020401a:	00004517          	auipc	a0,0x4
ffffffffc020401e:	06e50513          	addi	a0,a0,110 # ffffffffc0208088 <default_pmm_manager+0xb40>
ffffffffc0204022:	c62fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==5);
ffffffffc0204026:	00004697          	auipc	a3,0x4
ffffffffc020402a:	11a68693          	addi	a3,a3,282 # ffffffffc0208140 <default_pmm_manager+0xbf8>
ffffffffc020402e:	00003617          	auipc	a2,0x3
ffffffffc0204032:	dd260613          	addi	a2,a2,-558 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0204036:	06000593          	li	a1,96
ffffffffc020403a:	00004517          	auipc	a0,0x4
ffffffffc020403e:	04e50513          	addi	a0,a0,78 # ffffffffc0208088 <default_pmm_manager+0xb40>
ffffffffc0204042:	c42fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==5);
ffffffffc0204046:	00004697          	auipc	a3,0x4
ffffffffc020404a:	0fa68693          	addi	a3,a3,250 # ffffffffc0208140 <default_pmm_manager+0xbf8>
ffffffffc020404e:	00003617          	auipc	a2,0x3
ffffffffc0204052:	db260613          	addi	a2,a2,-590 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0204056:	05d00593          	li	a1,93
ffffffffc020405a:	00004517          	auipc	a0,0x4
ffffffffc020405e:	02e50513          	addi	a0,a0,46 # ffffffffc0208088 <default_pmm_manager+0xb40>
ffffffffc0204062:	c22fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==4);
ffffffffc0204066:	00004697          	auipc	a3,0x4
ffffffffc020406a:	e9a68693          	addi	a3,a3,-358 # ffffffffc0207f00 <default_pmm_manager+0x9b8>
ffffffffc020406e:	00003617          	auipc	a2,0x3
ffffffffc0204072:	d9260613          	addi	a2,a2,-622 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0204076:	05a00593          	li	a1,90
ffffffffc020407a:	00004517          	auipc	a0,0x4
ffffffffc020407e:	00e50513          	addi	a0,a0,14 # ffffffffc0208088 <default_pmm_manager+0xb40>
ffffffffc0204082:	c02fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==4);
ffffffffc0204086:	00004697          	auipc	a3,0x4
ffffffffc020408a:	e7a68693          	addi	a3,a3,-390 # ffffffffc0207f00 <default_pmm_manager+0x9b8>
ffffffffc020408e:	00003617          	auipc	a2,0x3
ffffffffc0204092:	d7260613          	addi	a2,a2,-654 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0204096:	05700593          	li	a1,87
ffffffffc020409a:	00004517          	auipc	a0,0x4
ffffffffc020409e:	fee50513          	addi	a0,a0,-18 # ffffffffc0208088 <default_pmm_manager+0xb40>
ffffffffc02040a2:	be2fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==4);
ffffffffc02040a6:	00004697          	auipc	a3,0x4
ffffffffc02040aa:	e5a68693          	addi	a3,a3,-422 # ffffffffc0207f00 <default_pmm_manager+0x9b8>
ffffffffc02040ae:	00003617          	auipc	a2,0x3
ffffffffc02040b2:	d5260613          	addi	a2,a2,-686 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02040b6:	05400593          	li	a1,84
ffffffffc02040ba:	00004517          	auipc	a0,0x4
ffffffffc02040be:	fce50513          	addi	a0,a0,-50 # ffffffffc0208088 <default_pmm_manager+0xb40>
ffffffffc02040c2:	bc2fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02040c6 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02040c6:	751c                	ld	a5,40(a0)
{
ffffffffc02040c8:	1141                	addi	sp,sp,-16
ffffffffc02040ca:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc02040cc:	cf91                	beqz	a5,ffffffffc02040e8 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc02040ce:	ee0d                	bnez	a2,ffffffffc0204108 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc02040d0:	679c                	ld	a5,8(a5)
}
ffffffffc02040d2:	60a2                	ld	ra,8(sp)
ffffffffc02040d4:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc02040d6:	6394                	ld	a3,0(a5)
ffffffffc02040d8:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc02040da:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc02040de:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02040e0:	e314                	sd	a3,0(a4)
ffffffffc02040e2:	e19c                	sd	a5,0(a1)
}
ffffffffc02040e4:	0141                	addi	sp,sp,16
ffffffffc02040e6:	8082                	ret
         assert(head != NULL);
ffffffffc02040e8:	00004697          	auipc	a3,0x4
ffffffffc02040ec:	11068693          	addi	a3,a3,272 # ffffffffc02081f8 <default_pmm_manager+0xcb0>
ffffffffc02040f0:	00003617          	auipc	a2,0x3
ffffffffc02040f4:	d1060613          	addi	a2,a2,-752 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02040f8:	04100593          	li	a1,65
ffffffffc02040fc:	00004517          	auipc	a0,0x4
ffffffffc0204100:	f8c50513          	addi	a0,a0,-116 # ffffffffc0208088 <default_pmm_manager+0xb40>
ffffffffc0204104:	b80fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(in_tick==0);
ffffffffc0204108:	00004697          	auipc	a3,0x4
ffffffffc020410c:	10068693          	addi	a3,a3,256 # ffffffffc0208208 <default_pmm_manager+0xcc0>
ffffffffc0204110:	00003617          	auipc	a2,0x3
ffffffffc0204114:	cf060613          	addi	a2,a2,-784 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0204118:	04200593          	li	a1,66
ffffffffc020411c:	00004517          	auipc	a0,0x4
ffffffffc0204120:	f6c50513          	addi	a0,a0,-148 # ffffffffc0208088 <default_pmm_manager+0xb40>
ffffffffc0204124:	b60fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204128 <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0204128:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020412c:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc020412e:	cb09                	beqz	a4,ffffffffc0204140 <_fifo_map_swappable+0x18>
ffffffffc0204130:	cb81                	beqz	a5,ffffffffc0204140 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204132:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0204134:	e398                	sd	a4,0(a5)
}
ffffffffc0204136:	4501                	li	a0,0
ffffffffc0204138:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc020413a:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc020413c:	f614                	sd	a3,40(a2)
ffffffffc020413e:	8082                	ret
{
ffffffffc0204140:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0204142:	00004697          	auipc	a3,0x4
ffffffffc0204146:	09668693          	addi	a3,a3,150 # ffffffffc02081d8 <default_pmm_manager+0xc90>
ffffffffc020414a:	00003617          	auipc	a2,0x3
ffffffffc020414e:	cb660613          	addi	a2,a2,-842 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0204152:	03200593          	li	a1,50
ffffffffc0204156:	00004517          	auipc	a0,0x4
ffffffffc020415a:	f3250513          	addi	a0,a0,-206 # ffffffffc0208088 <default_pmm_manager+0xb40>
{
ffffffffc020415e:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0204160:	b24fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204164 <check_vma_overlap.isra.1.part.2>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0204164:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0204166:	00004697          	auipc	a3,0x4
ffffffffc020416a:	0ca68693          	addi	a3,a3,202 # ffffffffc0208230 <default_pmm_manager+0xce8>
ffffffffc020416e:	00003617          	auipc	a2,0x3
ffffffffc0204172:	c9260613          	addi	a2,a2,-878 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0204176:	06d00593          	li	a1,109
ffffffffc020417a:	00004517          	auipc	a0,0x4
ffffffffc020417e:	0d650513          	addi	a0,a0,214 # ffffffffc0208250 <default_pmm_manager+0xd08>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0204182:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0204184:	b00fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204188 <mm_create>:
mm_create(void) {
ffffffffc0204188:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020418a:	04000513          	li	a0,64
mm_create(void) {
ffffffffc020418e:	e022                	sd	s0,0(sp)
ffffffffc0204190:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0204192:	afdfd0ef          	jal	ra,ffffffffc0201c8e <kmalloc>
ffffffffc0204196:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0204198:	c515                	beqz	a0,ffffffffc02041c4 <mm_create+0x3c>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020419a:	000a8797          	auipc	a5,0xa8
ffffffffc020419e:	38e78793          	addi	a5,a5,910 # ffffffffc02ac528 <swap_init_ok>
ffffffffc02041a2:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc02041a4:	e408                	sd	a0,8(s0)
ffffffffc02041a6:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02041a8:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02041ac:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02041b0:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02041b4:	2781                	sext.w	a5,a5
ffffffffc02041b6:	ef81                	bnez	a5,ffffffffc02041ce <mm_create+0x46>
        else mm->sm_priv = NULL;
ffffffffc02041b8:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc02041bc:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc02041c0:	02043c23          	sd	zero,56(s0)
}
ffffffffc02041c4:	8522                	mv	a0,s0
ffffffffc02041c6:	60a2                	ld	ra,8(sp)
ffffffffc02041c8:	6402                	ld	s0,0(sp)
ffffffffc02041ca:	0141                	addi	sp,sp,16
ffffffffc02041cc:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02041ce:	a01ff0ef          	jal	ra,ffffffffc0203bce <swap_init_mm>
ffffffffc02041d2:	b7ed                	j	ffffffffc02041bc <mm_create+0x34>

ffffffffc02041d4 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02041d4:	1101                	addi	sp,sp,-32
ffffffffc02041d6:	e04a                	sd	s2,0(sp)
ffffffffc02041d8:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02041da:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02041de:	e822                	sd	s0,16(sp)
ffffffffc02041e0:	e426                	sd	s1,8(sp)
ffffffffc02041e2:	ec06                	sd	ra,24(sp)
ffffffffc02041e4:	84ae                	mv	s1,a1
ffffffffc02041e6:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02041e8:	aa7fd0ef          	jal	ra,ffffffffc0201c8e <kmalloc>
    if (vma != NULL) {
ffffffffc02041ec:	c509                	beqz	a0,ffffffffc02041f6 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02041ee:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02041f2:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02041f4:	cd00                	sw	s0,24(a0)
}
ffffffffc02041f6:	60e2                	ld	ra,24(sp)
ffffffffc02041f8:	6442                	ld	s0,16(sp)
ffffffffc02041fa:	64a2                	ld	s1,8(sp)
ffffffffc02041fc:	6902                	ld	s2,0(sp)
ffffffffc02041fe:	6105                	addi	sp,sp,32
ffffffffc0204200:	8082                	ret

ffffffffc0204202 <find_vma>:
    if (mm != NULL) {
ffffffffc0204202:	c51d                	beqz	a0,ffffffffc0204230 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0204204:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204206:	c781                	beqz	a5,ffffffffc020420e <find_vma+0xc>
ffffffffc0204208:	6798                	ld	a4,8(a5)
ffffffffc020420a:	02e5f663          	bleu	a4,a1,ffffffffc0204236 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc020420e:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc0204210:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0204212:	00f50f63          	beq	a0,a5,ffffffffc0204230 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0204216:	fe87b703          	ld	a4,-24(a5)
ffffffffc020421a:	fee5ebe3          	bltu	a1,a4,ffffffffc0204210 <find_vma+0xe>
ffffffffc020421e:	ff07b703          	ld	a4,-16(a5)
ffffffffc0204222:	fee5f7e3          	bleu	a4,a1,ffffffffc0204210 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0204226:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0204228:	c781                	beqz	a5,ffffffffc0204230 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc020422a:	e91c                	sd	a5,16(a0)
}
ffffffffc020422c:	853e                	mv	a0,a5
ffffffffc020422e:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0204230:	4781                	li	a5,0
}
ffffffffc0204232:	853e                	mv	a0,a5
ffffffffc0204234:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204236:	6b98                	ld	a4,16(a5)
ffffffffc0204238:	fce5fbe3          	bleu	a4,a1,ffffffffc020420e <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc020423c:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc020423e:	b7fd                	j	ffffffffc020422c <find_vma+0x2a>

ffffffffc0204240 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0204240:	6590                	ld	a2,8(a1)
ffffffffc0204242:	0105b803          	ld	a6,16(a1) # 1010 <_binary_obj___user_faultread_out_size-0x8568>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0204246:	1141                	addi	sp,sp,-16
ffffffffc0204248:	e406                	sd	ra,8(sp)
ffffffffc020424a:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020424c:	01066863          	bltu	a2,a6,ffffffffc020425c <insert_vma_struct+0x1c>
ffffffffc0204250:	a8b9                	j	ffffffffc02042ae <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0204252:	fe87b683          	ld	a3,-24(a5)
ffffffffc0204256:	04d66763          	bltu	a2,a3,ffffffffc02042a4 <insert_vma_struct+0x64>
ffffffffc020425a:	873e                	mv	a4,a5
ffffffffc020425c:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc020425e:	fef51ae3          	bne	a0,a5,ffffffffc0204252 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0204262:	02a70463          	beq	a4,a0,ffffffffc020428a <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0204266:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc020426a:	fe873883          	ld	a7,-24(a4)
ffffffffc020426e:	08d8f063          	bleu	a3,a7,ffffffffc02042ee <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0204272:	04d66e63          	bltu	a2,a3,ffffffffc02042ce <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0204276:	00f50a63          	beq	a0,a5,ffffffffc020428a <insert_vma_struct+0x4a>
ffffffffc020427a:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc020427e:	0506e863          	bltu	a3,a6,ffffffffc02042ce <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0204282:	ff07b603          	ld	a2,-16(a5)
ffffffffc0204286:	02c6f263          	bleu	a2,a3,ffffffffc02042aa <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc020428a:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc020428c:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc020428e:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0204292:	e390                	sd	a2,0(a5)
ffffffffc0204294:	e710                	sd	a2,8(a4)
}
ffffffffc0204296:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0204298:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc020429a:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc020429c:	2685                	addiw	a3,a3,1
ffffffffc020429e:	d114                	sw	a3,32(a0)
}
ffffffffc02042a0:	0141                	addi	sp,sp,16
ffffffffc02042a2:	8082                	ret
    if (le_prev != list) {
ffffffffc02042a4:	fca711e3          	bne	a4,a0,ffffffffc0204266 <insert_vma_struct+0x26>
ffffffffc02042a8:	bfd9                	j	ffffffffc020427e <insert_vma_struct+0x3e>
ffffffffc02042aa:	ebbff0ef          	jal	ra,ffffffffc0204164 <check_vma_overlap.isra.1.part.2>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02042ae:	00004697          	auipc	a3,0x4
ffffffffc02042b2:	0d268693          	addi	a3,a3,210 # ffffffffc0208380 <default_pmm_manager+0xe38>
ffffffffc02042b6:	00003617          	auipc	a2,0x3
ffffffffc02042ba:	b4a60613          	addi	a2,a2,-1206 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02042be:	07400593          	li	a1,116
ffffffffc02042c2:	00004517          	auipc	a0,0x4
ffffffffc02042c6:	f8e50513          	addi	a0,a0,-114 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc02042ca:	9bafc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02042ce:	00004697          	auipc	a3,0x4
ffffffffc02042d2:	0f268693          	addi	a3,a3,242 # ffffffffc02083c0 <default_pmm_manager+0xe78>
ffffffffc02042d6:	00003617          	auipc	a2,0x3
ffffffffc02042da:	b2a60613          	addi	a2,a2,-1238 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02042de:	06c00593          	li	a1,108
ffffffffc02042e2:	00004517          	auipc	a0,0x4
ffffffffc02042e6:	f6e50513          	addi	a0,a0,-146 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc02042ea:	99afc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02042ee:	00004697          	auipc	a3,0x4
ffffffffc02042f2:	0b268693          	addi	a3,a3,178 # ffffffffc02083a0 <default_pmm_manager+0xe58>
ffffffffc02042f6:	00003617          	auipc	a2,0x3
ffffffffc02042fa:	b0a60613          	addi	a2,a2,-1270 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02042fe:	06b00593          	li	a1,107
ffffffffc0204302:	00004517          	auipc	a0,0x4
ffffffffc0204306:	f4e50513          	addi	a0,a0,-178 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc020430a:	97afc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020430e <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc020430e:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0204310:	1141                	addi	sp,sp,-16
ffffffffc0204312:	e406                	sd	ra,8(sp)
ffffffffc0204314:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0204316:	e78d                	bnez	a5,ffffffffc0204340 <mm_destroy+0x32>
ffffffffc0204318:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020431a:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc020431c:	00a40c63          	beq	s0,a0,ffffffffc0204334 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0204320:	6118                	ld	a4,0(a0)
ffffffffc0204322:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0204324:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0204326:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0204328:	e398                	sd	a4,0(a5)
ffffffffc020432a:	a21fd0ef          	jal	ra,ffffffffc0201d4a <kfree>
    return listelm->next;
ffffffffc020432e:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0204330:	fea418e3          	bne	s0,a0,ffffffffc0204320 <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0204334:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0204336:	6402                	ld	s0,0(sp)
ffffffffc0204338:	60a2                	ld	ra,8(sp)
ffffffffc020433a:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc020433c:	a0ffd06f          	j	ffffffffc0201d4a <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0204340:	00004697          	auipc	a3,0x4
ffffffffc0204344:	0a068693          	addi	a3,a3,160 # ffffffffc02083e0 <default_pmm_manager+0xe98>
ffffffffc0204348:	00003617          	auipc	a2,0x3
ffffffffc020434c:	ab860613          	addi	a2,a2,-1352 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0204350:	09400593          	li	a1,148
ffffffffc0204354:	00004517          	auipc	a0,0x4
ffffffffc0204358:	efc50513          	addi	a0,a0,-260 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc020435c:	928fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204360 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204360:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc0204362:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204364:	17fd                	addi	a5,a5,-1
ffffffffc0204366:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc0204368:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020436a:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc020436e:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204370:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc0204372:	fc06                	sd	ra,56(sp)
ffffffffc0204374:	f04a                	sd	s2,32(sp)
ffffffffc0204376:	ec4e                	sd	s3,24(sp)
ffffffffc0204378:	e852                	sd	s4,16(sp)
ffffffffc020437a:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020437c:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc0204380:	002007b7          	lui	a5,0x200
ffffffffc0204384:	01047433          	and	s0,s0,a6
ffffffffc0204388:	06f4e363          	bltu	s1,a5,ffffffffc02043ee <mm_map+0x8e>
ffffffffc020438c:	0684f163          	bleu	s0,s1,ffffffffc02043ee <mm_map+0x8e>
ffffffffc0204390:	4785                	li	a5,1
ffffffffc0204392:	07fe                	slli	a5,a5,0x1f
ffffffffc0204394:	0487ed63          	bltu	a5,s0,ffffffffc02043ee <mm_map+0x8e>
ffffffffc0204398:	89aa                	mv	s3,a0
ffffffffc020439a:	8a3a                	mv	s4,a4
ffffffffc020439c:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc020439e:	c931                	beqz	a0,ffffffffc02043f2 <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc02043a0:	85a6                	mv	a1,s1
ffffffffc02043a2:	e61ff0ef          	jal	ra,ffffffffc0204202 <find_vma>
ffffffffc02043a6:	c501                	beqz	a0,ffffffffc02043ae <mm_map+0x4e>
ffffffffc02043a8:	651c                	ld	a5,8(a0)
ffffffffc02043aa:	0487e263          	bltu	a5,s0,ffffffffc02043ee <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02043ae:	03000513          	li	a0,48
ffffffffc02043b2:	8ddfd0ef          	jal	ra,ffffffffc0201c8e <kmalloc>
ffffffffc02043b6:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02043b8:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc02043ba:	02090163          	beqz	s2,ffffffffc02043dc <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02043be:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02043c0:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc02043c4:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc02043c8:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc02043cc:	85ca                	mv	a1,s2
ffffffffc02043ce:	e73ff0ef          	jal	ra,ffffffffc0204240 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc02043d2:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc02043d4:	000a0463          	beqz	s4,ffffffffc02043dc <mm_map+0x7c>
        *vma_store = vma;
ffffffffc02043d8:	012a3023          	sd	s2,0(s4) # ffffffffc02ac5b0 <swap_in_seq_no>

out:
    return ret;
}
ffffffffc02043dc:	70e2                	ld	ra,56(sp)
ffffffffc02043de:	7442                	ld	s0,48(sp)
ffffffffc02043e0:	74a2                	ld	s1,40(sp)
ffffffffc02043e2:	7902                	ld	s2,32(sp)
ffffffffc02043e4:	69e2                	ld	s3,24(sp)
ffffffffc02043e6:	6a42                	ld	s4,16(sp)
ffffffffc02043e8:	6aa2                	ld	s5,8(sp)
ffffffffc02043ea:	6121                	addi	sp,sp,64
ffffffffc02043ec:	8082                	ret
        return -E_INVAL;
ffffffffc02043ee:	5575                	li	a0,-3
ffffffffc02043f0:	b7f5                	j	ffffffffc02043dc <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc02043f2:	00004697          	auipc	a3,0x4
ffffffffc02043f6:	99668693          	addi	a3,a3,-1642 # ffffffffc0207d88 <default_pmm_manager+0x840>
ffffffffc02043fa:	00003617          	auipc	a2,0x3
ffffffffc02043fe:	a0660613          	addi	a2,a2,-1530 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0204402:	0a700593          	li	a1,167
ffffffffc0204406:	00004517          	auipc	a0,0x4
ffffffffc020440a:	e4a50513          	addi	a0,a0,-438 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc020440e:	876fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204412 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0204412:	7139                	addi	sp,sp,-64
ffffffffc0204414:	fc06                	sd	ra,56(sp)
ffffffffc0204416:	f822                	sd	s0,48(sp)
ffffffffc0204418:	f426                	sd	s1,40(sp)
ffffffffc020441a:	f04a                	sd	s2,32(sp)
ffffffffc020441c:	ec4e                	sd	s3,24(sp)
ffffffffc020441e:	e852                	sd	s4,16(sp)
ffffffffc0204420:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0204422:	c535                	beqz	a0,ffffffffc020448e <dup_mmap+0x7c>
ffffffffc0204424:	892a                	mv	s2,a0
ffffffffc0204426:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0204428:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc020442a:	e59d                	bnez	a1,ffffffffc0204458 <dup_mmap+0x46>
ffffffffc020442c:	a08d                	j	ffffffffc020448e <dup_mmap+0x7c>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc020442e:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc0204430:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_exit_out_size+0x1f5580>
        insert_vma_struct(to, nvma);
ffffffffc0204434:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc0204436:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc020443a:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc020443e:	e03ff0ef          	jal	ra,ffffffffc0204240 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc0204442:	ff043683          	ld	a3,-16(s0)
ffffffffc0204446:	fe843603          	ld	a2,-24(s0)
ffffffffc020444a:	6c8c                	ld	a1,24(s1)
ffffffffc020444c:	01893503          	ld	a0,24(s2)
ffffffffc0204450:	4701                	li	a4,0
ffffffffc0204452:	ca5fe0ef          	jal	ra,ffffffffc02030f6 <copy_range>
ffffffffc0204456:	e105                	bnez	a0,ffffffffc0204476 <dup_mmap+0x64>
    return listelm->prev;
ffffffffc0204458:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc020445a:	02848863          	beq	s1,s0,ffffffffc020448a <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020445e:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0204462:	fe843a83          	ld	s5,-24(s0)
ffffffffc0204466:	ff043a03          	ld	s4,-16(s0)
ffffffffc020446a:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020446e:	821fd0ef          	jal	ra,ffffffffc0201c8e <kmalloc>
ffffffffc0204472:	87aa                	mv	a5,a0
    if (vma != NULL) {
ffffffffc0204474:	fd4d                	bnez	a0,ffffffffc020442e <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0204476:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0204478:	70e2                	ld	ra,56(sp)
ffffffffc020447a:	7442                	ld	s0,48(sp)
ffffffffc020447c:	74a2                	ld	s1,40(sp)
ffffffffc020447e:	7902                	ld	s2,32(sp)
ffffffffc0204480:	69e2                	ld	s3,24(sp)
ffffffffc0204482:	6a42                	ld	s4,16(sp)
ffffffffc0204484:	6aa2                	ld	s5,8(sp)
ffffffffc0204486:	6121                	addi	sp,sp,64
ffffffffc0204488:	8082                	ret
    return 0;
ffffffffc020448a:	4501                	li	a0,0
ffffffffc020448c:	b7f5                	j	ffffffffc0204478 <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc020448e:	00004697          	auipc	a3,0x4
ffffffffc0204492:	eb268693          	addi	a3,a3,-334 # ffffffffc0208340 <default_pmm_manager+0xdf8>
ffffffffc0204496:	00003617          	auipc	a2,0x3
ffffffffc020449a:	96a60613          	addi	a2,a2,-1686 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020449e:	0c000593          	li	a1,192
ffffffffc02044a2:	00004517          	auipc	a0,0x4
ffffffffc02044a6:	dae50513          	addi	a0,a0,-594 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc02044aa:	fdbfb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02044ae <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc02044ae:	1101                	addi	sp,sp,-32
ffffffffc02044b0:	ec06                	sd	ra,24(sp)
ffffffffc02044b2:	e822                	sd	s0,16(sp)
ffffffffc02044b4:	e426                	sd	s1,8(sp)
ffffffffc02044b6:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02044b8:	c531                	beqz	a0,ffffffffc0204504 <exit_mmap+0x56>
ffffffffc02044ba:	591c                	lw	a5,48(a0)
ffffffffc02044bc:	84aa                	mv	s1,a0
ffffffffc02044be:	e3b9                	bnez	a5,ffffffffc0204504 <exit_mmap+0x56>
    return listelm->next;
ffffffffc02044c0:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02044c2:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc02044c6:	02850663          	beq	a0,s0,ffffffffc02044f2 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02044ca:	ff043603          	ld	a2,-16(s0)
ffffffffc02044ce:	fe843583          	ld	a1,-24(s0)
ffffffffc02044d2:	854a                	mv	a0,s2
ffffffffc02044d4:	cf9fd0ef          	jal	ra,ffffffffc02021cc <unmap_range>
ffffffffc02044d8:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02044da:	fe8498e3          	bne	s1,s0,ffffffffc02044ca <exit_mmap+0x1c>
ffffffffc02044de:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc02044e0:	00848c63          	beq	s1,s0,ffffffffc02044f8 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02044e4:	ff043603          	ld	a2,-16(s0)
ffffffffc02044e8:	fe843583          	ld	a1,-24(s0)
ffffffffc02044ec:	854a                	mv	a0,s2
ffffffffc02044ee:	df7fd0ef          	jal	ra,ffffffffc02022e4 <exit_range>
ffffffffc02044f2:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02044f4:	fe8498e3          	bne	s1,s0,ffffffffc02044e4 <exit_mmap+0x36>
    }
}
ffffffffc02044f8:	60e2                	ld	ra,24(sp)
ffffffffc02044fa:	6442                	ld	s0,16(sp)
ffffffffc02044fc:	64a2                	ld	s1,8(sp)
ffffffffc02044fe:	6902                	ld	s2,0(sp)
ffffffffc0204500:	6105                	addi	sp,sp,32
ffffffffc0204502:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204504:	00004697          	auipc	a3,0x4
ffffffffc0204508:	e5c68693          	addi	a3,a3,-420 # ffffffffc0208360 <default_pmm_manager+0xe18>
ffffffffc020450c:	00003617          	auipc	a2,0x3
ffffffffc0204510:	8f460613          	addi	a2,a2,-1804 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0204514:	0d600593          	li	a1,214
ffffffffc0204518:	00004517          	auipc	a0,0x4
ffffffffc020451c:	d3850513          	addi	a0,a0,-712 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc0204520:	f65fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204524 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0204524:	7139                	addi	sp,sp,-64
ffffffffc0204526:	f822                	sd	s0,48(sp)
ffffffffc0204528:	f426                	sd	s1,40(sp)
ffffffffc020452a:	fc06                	sd	ra,56(sp)
ffffffffc020452c:	f04a                	sd	s2,32(sp)
ffffffffc020452e:	ec4e                	sd	s3,24(sp)
ffffffffc0204530:	e852                	sd	s4,16(sp)
ffffffffc0204532:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0204534:	c55ff0ef          	jal	ra,ffffffffc0204188 <mm_create>
    assert(mm != NULL);
ffffffffc0204538:	842a                	mv	s0,a0
ffffffffc020453a:	03200493          	li	s1,50
ffffffffc020453e:	e919                	bnez	a0,ffffffffc0204554 <vmm_init+0x30>
ffffffffc0204540:	a989                	j	ffffffffc0204992 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0204542:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204544:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204546:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020454a:	14ed                	addi	s1,s1,-5
ffffffffc020454c:	8522                	mv	a0,s0
ffffffffc020454e:	cf3ff0ef          	jal	ra,ffffffffc0204240 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0204552:	c88d                	beqz	s1,ffffffffc0204584 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204554:	03000513          	li	a0,48
ffffffffc0204558:	f36fd0ef          	jal	ra,ffffffffc0201c8e <kmalloc>
ffffffffc020455c:	85aa                	mv	a1,a0
ffffffffc020455e:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0204562:	f165                	bnez	a0,ffffffffc0204542 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0204564:	00004697          	auipc	a3,0x4
ffffffffc0204568:	85c68693          	addi	a3,a3,-1956 # ffffffffc0207dc0 <default_pmm_manager+0x878>
ffffffffc020456c:	00003617          	auipc	a2,0x3
ffffffffc0204570:	89460613          	addi	a2,a2,-1900 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0204574:	11300593          	li	a1,275
ffffffffc0204578:	00004517          	auipc	a0,0x4
ffffffffc020457c:	cd850513          	addi	a0,a0,-808 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc0204580:	f05fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0204584:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0204588:	1f900913          	li	s2,505
ffffffffc020458c:	a819                	j	ffffffffc02045a2 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc020458e:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204590:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204592:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0204596:	0495                	addi	s1,s1,5
ffffffffc0204598:	8522                	mv	a0,s0
ffffffffc020459a:	ca7ff0ef          	jal	ra,ffffffffc0204240 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020459e:	03248a63          	beq	s1,s2,ffffffffc02045d2 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02045a2:	03000513          	li	a0,48
ffffffffc02045a6:	ee8fd0ef          	jal	ra,ffffffffc0201c8e <kmalloc>
ffffffffc02045aa:	85aa                	mv	a1,a0
ffffffffc02045ac:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02045b0:	fd79                	bnez	a0,ffffffffc020458e <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc02045b2:	00004697          	auipc	a3,0x4
ffffffffc02045b6:	80e68693          	addi	a3,a3,-2034 # ffffffffc0207dc0 <default_pmm_manager+0x878>
ffffffffc02045ba:	00003617          	auipc	a2,0x3
ffffffffc02045be:	84660613          	addi	a2,a2,-1978 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02045c2:	11900593          	li	a1,281
ffffffffc02045c6:	00004517          	auipc	a0,0x4
ffffffffc02045ca:	c8a50513          	addi	a0,a0,-886 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc02045ce:	eb7fb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc02045d2:	6418                	ld	a4,8(s0)
ffffffffc02045d4:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc02045d6:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc02045da:	2ee40063          	beq	s0,a4,ffffffffc02048ba <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02045de:	fe873603          	ld	a2,-24(a4)
ffffffffc02045e2:	ffe78693          	addi	a3,a5,-2
ffffffffc02045e6:	24d61a63          	bne	a2,a3,ffffffffc020483a <vmm_init+0x316>
ffffffffc02045ea:	ff073683          	ld	a3,-16(a4)
ffffffffc02045ee:	24f69663          	bne	a3,a5,ffffffffc020483a <vmm_init+0x316>
ffffffffc02045f2:	0795                	addi	a5,a5,5
ffffffffc02045f4:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc02045f6:	feb792e3          	bne	a5,a1,ffffffffc02045da <vmm_init+0xb6>
ffffffffc02045fa:	491d                	li	s2,7
ffffffffc02045fc:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02045fe:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0204602:	85a6                	mv	a1,s1
ffffffffc0204604:	8522                	mv	a0,s0
ffffffffc0204606:	bfdff0ef          	jal	ra,ffffffffc0204202 <find_vma>
ffffffffc020460a:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc020460c:	30050763          	beqz	a0,ffffffffc020491a <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0204610:	00148593          	addi	a1,s1,1
ffffffffc0204614:	8522                	mv	a0,s0
ffffffffc0204616:	bedff0ef          	jal	ra,ffffffffc0204202 <find_vma>
ffffffffc020461a:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc020461c:	2c050f63          	beqz	a0,ffffffffc02048fa <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0204620:	85ca                	mv	a1,s2
ffffffffc0204622:	8522                	mv	a0,s0
ffffffffc0204624:	bdfff0ef          	jal	ra,ffffffffc0204202 <find_vma>
        assert(vma3 == NULL);
ffffffffc0204628:	2a051963          	bnez	a0,ffffffffc02048da <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc020462c:	00348593          	addi	a1,s1,3
ffffffffc0204630:	8522                	mv	a0,s0
ffffffffc0204632:	bd1ff0ef          	jal	ra,ffffffffc0204202 <find_vma>
        assert(vma4 == NULL);
ffffffffc0204636:	32051263          	bnez	a0,ffffffffc020495a <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc020463a:	00448593          	addi	a1,s1,4
ffffffffc020463e:	8522                	mv	a0,s0
ffffffffc0204640:	bc3ff0ef          	jal	ra,ffffffffc0204202 <find_vma>
        assert(vma5 == NULL);
ffffffffc0204644:	2e051b63          	bnez	a0,ffffffffc020493a <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0204648:	008a3783          	ld	a5,8(s4)
ffffffffc020464c:	20979763          	bne	a5,s1,ffffffffc020485a <vmm_init+0x336>
ffffffffc0204650:	010a3783          	ld	a5,16(s4)
ffffffffc0204654:	21279363          	bne	a5,s2,ffffffffc020485a <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0204658:	0089b783          	ld	a5,8(s3)
ffffffffc020465c:	20979f63          	bne	a5,s1,ffffffffc020487a <vmm_init+0x356>
ffffffffc0204660:	0109b783          	ld	a5,16(s3)
ffffffffc0204664:	21279b63          	bne	a5,s2,ffffffffc020487a <vmm_init+0x356>
ffffffffc0204668:	0495                	addi	s1,s1,5
ffffffffc020466a:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020466c:	f9549be3          	bne	s1,s5,ffffffffc0204602 <vmm_init+0xde>
ffffffffc0204670:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0204672:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0204674:	85a6                	mv	a1,s1
ffffffffc0204676:	8522                	mv	a0,s0
ffffffffc0204678:	b8bff0ef          	jal	ra,ffffffffc0204202 <find_vma>
ffffffffc020467c:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0204680:	c90d                	beqz	a0,ffffffffc02046b2 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0204682:	6914                	ld	a3,16(a0)
ffffffffc0204684:	6510                	ld	a2,8(a0)
ffffffffc0204686:	00004517          	auipc	a0,0x4
ffffffffc020468a:	e7250513          	addi	a0,a0,-398 # ffffffffc02084f8 <default_pmm_manager+0xfb0>
ffffffffc020468e:	b01fb0ef          	jal	ra,ffffffffc020018e <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0204692:	00004697          	auipc	a3,0x4
ffffffffc0204696:	e8e68693          	addi	a3,a3,-370 # ffffffffc0208520 <default_pmm_manager+0xfd8>
ffffffffc020469a:	00002617          	auipc	a2,0x2
ffffffffc020469e:	76660613          	addi	a2,a2,1894 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02046a2:	13b00593          	li	a1,315
ffffffffc02046a6:	00004517          	auipc	a0,0x4
ffffffffc02046aa:	baa50513          	addi	a0,a0,-1110 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc02046ae:	dd7fb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc02046b2:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc02046b4:	fd2490e3          	bne	s1,s2,ffffffffc0204674 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc02046b8:	8522                	mv	a0,s0
ffffffffc02046ba:	c55ff0ef          	jal	ra,ffffffffc020430e <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02046be:	00004517          	auipc	a0,0x4
ffffffffc02046c2:	e7a50513          	addi	a0,a0,-390 # ffffffffc0208538 <default_pmm_manager+0xff0>
ffffffffc02046c6:	ac9fb0ef          	jal	ra,ffffffffc020018e <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02046ca:	88ffd0ef          	jal	ra,ffffffffc0201f58 <nr_free_pages>
ffffffffc02046ce:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc02046d0:	ab9ff0ef          	jal	ra,ffffffffc0204188 <mm_create>
ffffffffc02046d4:	000a8797          	auipc	a5,0xa8
ffffffffc02046d8:	f8a7ba23          	sd	a0,-108(a5) # ffffffffc02ac668 <check_mm_struct>
ffffffffc02046dc:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc02046de:	36050663          	beqz	a0,ffffffffc0204a4a <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02046e2:	000a8797          	auipc	a5,0xa8
ffffffffc02046e6:	e2e78793          	addi	a5,a5,-466 # ffffffffc02ac510 <boot_pgdir>
ffffffffc02046ea:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc02046ee:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02046f2:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02046f6:	2c079e63          	bnez	a5,ffffffffc02049d2 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02046fa:	03000513          	li	a0,48
ffffffffc02046fe:	d90fd0ef          	jal	ra,ffffffffc0201c8e <kmalloc>
ffffffffc0204702:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0204704:	18050b63          	beqz	a0,ffffffffc020489a <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0204708:	002007b7          	lui	a5,0x200
ffffffffc020470c:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc020470e:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0204710:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0204712:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0204714:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0204716:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc020471a:	b27ff0ef          	jal	ra,ffffffffc0204240 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020471e:	10000593          	li	a1,256
ffffffffc0204722:	8526                	mv	a0,s1
ffffffffc0204724:	adfff0ef          	jal	ra,ffffffffc0204202 <find_vma>
ffffffffc0204728:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc020472c:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0204730:	2ca41163          	bne	s0,a0,ffffffffc02049f2 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0204734:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f5578>
        sum += i;
ffffffffc0204738:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc020473a:	fee79de3          	bne	a5,a4,ffffffffc0204734 <vmm_init+0x210>
        sum += i;
ffffffffc020473e:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0204740:	10000793          	li	a5,256
        sum += i;
ffffffffc0204744:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x8222>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0204748:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020474c:	0007c683          	lbu	a3,0(a5)
ffffffffc0204750:	0785                	addi	a5,a5,1
ffffffffc0204752:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0204754:	fec79ce3          	bne	a5,a2,ffffffffc020474c <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc0204758:	2c071963          	bnez	a4,ffffffffc0204a2a <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc020475c:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0204760:	000a8a97          	auipc	s5,0xa8
ffffffffc0204764:	db8a8a93          	addi	s5,s5,-584 # ffffffffc02ac518 <npage>
ffffffffc0204768:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020476c:	078a                	slli	a5,a5,0x2
ffffffffc020476e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204770:	20e7f563          	bleu	a4,a5,ffffffffc020497a <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0204774:	00005697          	auipc	a3,0x5
ffffffffc0204778:	80468693          	addi	a3,a3,-2044 # ffffffffc0208f78 <nbase>
ffffffffc020477c:	0006ba03          	ld	s4,0(a3)
ffffffffc0204780:	414786b3          	sub	a3,a5,s4
ffffffffc0204784:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0204786:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204788:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc020478a:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc020478c:	83b1                	srli	a5,a5,0xc
ffffffffc020478e:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204790:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204792:	28e7f063          	bleu	a4,a5,ffffffffc0204a12 <vmm_init+0x4ee>
ffffffffc0204796:	000a8797          	auipc	a5,0xa8
ffffffffc020479a:	de278793          	addi	a5,a5,-542 # ffffffffc02ac578 <va_pa_offset>
ffffffffc020479e:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02047a0:	4581                	li	a1,0
ffffffffc02047a2:	854a                	mv	a0,s2
ffffffffc02047a4:	9436                	add	s0,s0,a3
ffffffffc02047a6:	d95fd0ef          	jal	ra,ffffffffc020253a <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02047aa:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02047ac:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02047b0:	078a                	slli	a5,a5,0x2
ffffffffc02047b2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02047b4:	1ce7f363          	bleu	a4,a5,ffffffffc020497a <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02047b8:	000a8417          	auipc	s0,0xa8
ffffffffc02047bc:	dd040413          	addi	s0,s0,-560 # ffffffffc02ac588 <pages>
ffffffffc02047c0:	6008                	ld	a0,0(s0)
ffffffffc02047c2:	414787b3          	sub	a5,a5,s4
ffffffffc02047c6:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02047c8:	953e                	add	a0,a0,a5
ffffffffc02047ca:	4585                	li	a1,1
ffffffffc02047cc:	f46fd0ef          	jal	ra,ffffffffc0201f12 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02047d0:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02047d4:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02047d8:	078a                	slli	a5,a5,0x2
ffffffffc02047da:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02047dc:	18e7ff63          	bleu	a4,a5,ffffffffc020497a <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02047e0:	6008                	ld	a0,0(s0)
ffffffffc02047e2:	414787b3          	sub	a5,a5,s4
ffffffffc02047e6:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02047e8:	4585                	li	a1,1
ffffffffc02047ea:	953e                	add	a0,a0,a5
ffffffffc02047ec:	f26fd0ef          	jal	ra,ffffffffc0201f12 <free_pages>
    pgdir[0] = 0;
ffffffffc02047f0:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc02047f4:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc02047f8:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc02047fc:	8526                	mv	a0,s1
ffffffffc02047fe:	b11ff0ef          	jal	ra,ffffffffc020430e <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0204802:	000a8797          	auipc	a5,0xa8
ffffffffc0204806:	e607b323          	sd	zero,-410(a5) # ffffffffc02ac668 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020480a:	f4efd0ef          	jal	ra,ffffffffc0201f58 <nr_free_pages>
ffffffffc020480e:	1aa99263          	bne	s3,a0,ffffffffc02049b2 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0204812:	00004517          	auipc	a0,0x4
ffffffffc0204816:	db650513          	addi	a0,a0,-586 # ffffffffc02085c8 <default_pmm_manager+0x1080>
ffffffffc020481a:	975fb0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc020481e:	7442                	ld	s0,48(sp)
ffffffffc0204820:	70e2                	ld	ra,56(sp)
ffffffffc0204822:	74a2                	ld	s1,40(sp)
ffffffffc0204824:	7902                	ld	s2,32(sp)
ffffffffc0204826:	69e2                	ld	s3,24(sp)
ffffffffc0204828:	6a42                	ld	s4,16(sp)
ffffffffc020482a:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020482c:	00004517          	auipc	a0,0x4
ffffffffc0204830:	dbc50513          	addi	a0,a0,-580 # ffffffffc02085e8 <default_pmm_manager+0x10a0>
}
ffffffffc0204834:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0204836:	959fb06f          	j	ffffffffc020018e <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020483a:	00004697          	auipc	a3,0x4
ffffffffc020483e:	bd668693          	addi	a3,a3,-1066 # ffffffffc0208410 <default_pmm_manager+0xec8>
ffffffffc0204842:	00002617          	auipc	a2,0x2
ffffffffc0204846:	5be60613          	addi	a2,a2,1470 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020484a:	12200593          	li	a1,290
ffffffffc020484e:	00004517          	auipc	a0,0x4
ffffffffc0204852:	a0250513          	addi	a0,a0,-1534 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc0204856:	c2ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020485a:	00004697          	auipc	a3,0x4
ffffffffc020485e:	c3e68693          	addi	a3,a3,-962 # ffffffffc0208498 <default_pmm_manager+0xf50>
ffffffffc0204862:	00002617          	auipc	a2,0x2
ffffffffc0204866:	59e60613          	addi	a2,a2,1438 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020486a:	13200593          	li	a1,306
ffffffffc020486e:	00004517          	auipc	a0,0x4
ffffffffc0204872:	9e250513          	addi	a0,a0,-1566 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc0204876:	c0ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020487a:	00004697          	auipc	a3,0x4
ffffffffc020487e:	c4e68693          	addi	a3,a3,-946 # ffffffffc02084c8 <default_pmm_manager+0xf80>
ffffffffc0204882:	00002617          	auipc	a2,0x2
ffffffffc0204886:	57e60613          	addi	a2,a2,1406 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020488a:	13300593          	li	a1,307
ffffffffc020488e:	00004517          	auipc	a0,0x4
ffffffffc0204892:	9c250513          	addi	a0,a0,-1598 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc0204896:	beffb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(vma != NULL);
ffffffffc020489a:	00003697          	auipc	a3,0x3
ffffffffc020489e:	52668693          	addi	a3,a3,1318 # ffffffffc0207dc0 <default_pmm_manager+0x878>
ffffffffc02048a2:	00002617          	auipc	a2,0x2
ffffffffc02048a6:	55e60613          	addi	a2,a2,1374 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02048aa:	15200593          	li	a1,338
ffffffffc02048ae:	00004517          	auipc	a0,0x4
ffffffffc02048b2:	9a250513          	addi	a0,a0,-1630 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc02048b6:	bcffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02048ba:	00004697          	auipc	a3,0x4
ffffffffc02048be:	b3e68693          	addi	a3,a3,-1218 # ffffffffc02083f8 <default_pmm_manager+0xeb0>
ffffffffc02048c2:	00002617          	auipc	a2,0x2
ffffffffc02048c6:	53e60613          	addi	a2,a2,1342 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02048ca:	12000593          	li	a1,288
ffffffffc02048ce:	00004517          	auipc	a0,0x4
ffffffffc02048d2:	98250513          	addi	a0,a0,-1662 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc02048d6:	baffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma3 == NULL);
ffffffffc02048da:	00004697          	auipc	a3,0x4
ffffffffc02048de:	b8e68693          	addi	a3,a3,-1138 # ffffffffc0208468 <default_pmm_manager+0xf20>
ffffffffc02048e2:	00002617          	auipc	a2,0x2
ffffffffc02048e6:	51e60613          	addi	a2,a2,1310 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02048ea:	12c00593          	li	a1,300
ffffffffc02048ee:	00004517          	auipc	a0,0x4
ffffffffc02048f2:	96250513          	addi	a0,a0,-1694 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc02048f6:	b8ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma2 != NULL);
ffffffffc02048fa:	00004697          	auipc	a3,0x4
ffffffffc02048fe:	b5e68693          	addi	a3,a3,-1186 # ffffffffc0208458 <default_pmm_manager+0xf10>
ffffffffc0204902:	00002617          	auipc	a2,0x2
ffffffffc0204906:	4fe60613          	addi	a2,a2,1278 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020490a:	12a00593          	li	a1,298
ffffffffc020490e:	00004517          	auipc	a0,0x4
ffffffffc0204912:	94250513          	addi	a0,a0,-1726 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc0204916:	b6ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma1 != NULL);
ffffffffc020491a:	00004697          	auipc	a3,0x4
ffffffffc020491e:	b2e68693          	addi	a3,a3,-1234 # ffffffffc0208448 <default_pmm_manager+0xf00>
ffffffffc0204922:	00002617          	auipc	a2,0x2
ffffffffc0204926:	4de60613          	addi	a2,a2,1246 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020492a:	12800593          	li	a1,296
ffffffffc020492e:	00004517          	auipc	a0,0x4
ffffffffc0204932:	92250513          	addi	a0,a0,-1758 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc0204936:	b4ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma5 == NULL);
ffffffffc020493a:	00004697          	auipc	a3,0x4
ffffffffc020493e:	b4e68693          	addi	a3,a3,-1202 # ffffffffc0208488 <default_pmm_manager+0xf40>
ffffffffc0204942:	00002617          	auipc	a2,0x2
ffffffffc0204946:	4be60613          	addi	a2,a2,1214 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020494a:	13000593          	li	a1,304
ffffffffc020494e:	00004517          	auipc	a0,0x4
ffffffffc0204952:	90250513          	addi	a0,a0,-1790 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc0204956:	b2ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma4 == NULL);
ffffffffc020495a:	00004697          	auipc	a3,0x4
ffffffffc020495e:	b1e68693          	addi	a3,a3,-1250 # ffffffffc0208478 <default_pmm_manager+0xf30>
ffffffffc0204962:	00002617          	auipc	a2,0x2
ffffffffc0204966:	49e60613          	addi	a2,a2,1182 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020496a:	12e00593          	li	a1,302
ffffffffc020496e:	00004517          	auipc	a0,0x4
ffffffffc0204972:	8e250513          	addi	a0,a0,-1822 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc0204976:	b0ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020497a:	00003617          	auipc	a2,0x3
ffffffffc020497e:	c7e60613          	addi	a2,a2,-898 # ffffffffc02075f8 <default_pmm_manager+0xb0>
ffffffffc0204982:	06200593          	li	a1,98
ffffffffc0204986:	00003517          	auipc	a0,0x3
ffffffffc020498a:	c3a50513          	addi	a0,a0,-966 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc020498e:	af7fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(mm != NULL);
ffffffffc0204992:	00003697          	auipc	a3,0x3
ffffffffc0204996:	3f668693          	addi	a3,a3,1014 # ffffffffc0207d88 <default_pmm_manager+0x840>
ffffffffc020499a:	00002617          	auipc	a2,0x2
ffffffffc020499e:	46660613          	addi	a2,a2,1126 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02049a2:	10c00593          	li	a1,268
ffffffffc02049a6:	00004517          	auipc	a0,0x4
ffffffffc02049aa:	8aa50513          	addi	a0,a0,-1878 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc02049ae:	ad7fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02049b2:	00004697          	auipc	a3,0x4
ffffffffc02049b6:	bee68693          	addi	a3,a3,-1042 # ffffffffc02085a0 <default_pmm_manager+0x1058>
ffffffffc02049ba:	00002617          	auipc	a2,0x2
ffffffffc02049be:	44660613          	addi	a2,a2,1094 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02049c2:	17000593          	li	a1,368
ffffffffc02049c6:	00004517          	auipc	a0,0x4
ffffffffc02049ca:	88a50513          	addi	a0,a0,-1910 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc02049ce:	ab7fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02049d2:	00003697          	auipc	a3,0x3
ffffffffc02049d6:	3de68693          	addi	a3,a3,990 # ffffffffc0207db0 <default_pmm_manager+0x868>
ffffffffc02049da:	00002617          	auipc	a2,0x2
ffffffffc02049de:	42660613          	addi	a2,a2,1062 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02049e2:	14f00593          	li	a1,335
ffffffffc02049e6:	00004517          	auipc	a0,0x4
ffffffffc02049ea:	86a50513          	addi	a0,a0,-1942 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc02049ee:	a97fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02049f2:	00004697          	auipc	a3,0x4
ffffffffc02049f6:	b7e68693          	addi	a3,a3,-1154 # ffffffffc0208570 <default_pmm_manager+0x1028>
ffffffffc02049fa:	00002617          	auipc	a2,0x2
ffffffffc02049fe:	40660613          	addi	a2,a2,1030 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0204a02:	15700593          	li	a1,343
ffffffffc0204a06:	00004517          	auipc	a0,0x4
ffffffffc0204a0a:	84a50513          	addi	a0,a0,-1974 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc0204a0e:	a77fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc0204a12:	00003617          	auipc	a2,0x3
ffffffffc0204a16:	b8660613          	addi	a2,a2,-1146 # ffffffffc0207598 <default_pmm_manager+0x50>
ffffffffc0204a1a:	06900593          	li	a1,105
ffffffffc0204a1e:	00003517          	auipc	a0,0x3
ffffffffc0204a22:	ba250513          	addi	a0,a0,-1118 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0204a26:	a5ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(sum == 0);
ffffffffc0204a2a:	00004697          	auipc	a3,0x4
ffffffffc0204a2e:	b6668693          	addi	a3,a3,-1178 # ffffffffc0208590 <default_pmm_manager+0x1048>
ffffffffc0204a32:	00002617          	auipc	a2,0x2
ffffffffc0204a36:	3ce60613          	addi	a2,a2,974 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0204a3a:	16300593          	li	a1,355
ffffffffc0204a3e:	00004517          	auipc	a0,0x4
ffffffffc0204a42:	81250513          	addi	a0,a0,-2030 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc0204a46:	a3ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0204a4a:	00004697          	auipc	a3,0x4
ffffffffc0204a4e:	b0e68693          	addi	a3,a3,-1266 # ffffffffc0208558 <default_pmm_manager+0x1010>
ffffffffc0204a52:	00002617          	auipc	a2,0x2
ffffffffc0204a56:	3ae60613          	addi	a2,a2,942 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0204a5a:	14b00593          	li	a1,331
ffffffffc0204a5e:	00003517          	auipc	a0,0x3
ffffffffc0204a62:	7f250513          	addi	a0,a0,2034 # ffffffffc0208250 <default_pmm_manager+0xd08>
ffffffffc0204a66:	a1ffb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204a6a <do_pgfault>:
//    }
//    ret = 0;
// failed:
//     return ret;
// }
int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204a6a:	715d                	addi	sp,sp,-80
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204a6c:	85b2                	mv	a1,a2
int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204a6e:	e0a2                	sd	s0,64(sp)
ffffffffc0204a70:	fc26                	sd	s1,56(sp)
ffffffffc0204a72:	e486                	sd	ra,72(sp)
ffffffffc0204a74:	f84a                	sd	s2,48(sp)
ffffffffc0204a76:	f44e                	sd	s3,40(sp)
ffffffffc0204a78:	f052                	sd	s4,32(sp)
ffffffffc0204a7a:	ec56                	sd	s5,24(sp)
ffffffffc0204a7c:	8432                	mv	s0,a2
ffffffffc0204a7e:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204a80:	f82ff0ef          	jal	ra,ffffffffc0204202 <find_vma>

    pgfault_num++;
ffffffffc0204a84:	000a8797          	auipc	a5,0xa8
ffffffffc0204a88:	aa878793          	addi	a5,a5,-1368 # ffffffffc02ac52c <pgfault_num>
ffffffffc0204a8c:	439c                	lw	a5,0(a5)
ffffffffc0204a8e:	2785                	addiw	a5,a5,1
ffffffffc0204a90:	000a8717          	auipc	a4,0xa8
ffffffffc0204a94:	a8f72e23          	sw	a5,-1380(a4) # ffffffffc02ac52c <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0204a98:	16050863          	beqz	a0,ffffffffc0204c08 <do_pgfault+0x19e>
ffffffffc0204a9c:	651c                	ld	a5,8(a0)
ffffffffc0204a9e:	16f46563          	bltu	s0,a5,ffffffffc0204c08 <do_pgfault+0x19e>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204aa2:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0204aa4:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204aa6:	8b89                	andi	a5,a5,2
ffffffffc0204aa8:	ebbd                	bnez	a5,ffffffffc0204b1e <do_pgfault+0xb4>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204aaa:	767d                	lui	a2,0xfffff

    ret = -E_NO_MEM;

    pte_t *ptep=NULL;
    // 查找当前虚拟地址所对应的页表项
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204aac:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204aae:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204ab0:	85a2                	mv	a1,s0
ffffffffc0204ab2:	4605                	li	a2,1
ffffffffc0204ab4:	ce4fd0ef          	jal	ra,ffffffffc0201f98 <get_pte>
ffffffffc0204ab8:	892a                	mv	s2,a0
ffffffffc0204aba:	16050063          	beqz	a0,ffffffffc0204c1a <do_pgfault+0x1b0>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    // 如果这个页表项所对应的物理页不存在，则
    if (*ptep == 0) {
ffffffffc0204abe:	6110                	ld	a2,0(a0)
ffffffffc0204ac0:	10060563          	beqz	a2,ffffffffc0204bca <do_pgfault+0x160>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    }
    else {
        struct Page *page=NULL;
ffffffffc0204ac4:	e402                	sd	zero,8(sp)
        // 如果当前页错误的原因是写入了只读页面
        if (*ptep & PTE_V) {
ffffffffc0204ac6:	00167793          	andi	a5,a2,1
ffffffffc0204aca:	efa1                	bnez	a5,ffffffffc0204b22 <do_pgfault+0xb8>
                page_insert(mm->pgdir, page, addr, perm);
        }
        else
        {
            // 如果swap已经初始化完成
            if(swap_init_ok) {
ffffffffc0204acc:	000a8797          	auipc	a5,0xa8
ffffffffc0204ad0:	a5c78793          	addi	a5,a5,-1444 # ffffffffc02ac528 <swap_init_ok>
ffffffffc0204ad4:	439c                	lw	a5,0(a5)
ffffffffc0204ad6:	2781                	sext.w	a5,a5
ffffffffc0204ad8:	10078f63          	beqz	a5,ffffffffc0204bf6 <do_pgfault+0x18c>
                // 将目标数据加载到某块新的物理页中。
                // 该物理页可能是尚未分配的物理页，也可能是从别的已分配物理页中取的
                if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc0204adc:	0030                	addi	a2,sp,8
ffffffffc0204ade:	85a2                	mv	a1,s0
ffffffffc0204ae0:	8526                	mv	a0,s1
ffffffffc0204ae2:	a20ff0ef          	jal	ra,ffffffffc0203d02 <swap_in>
ffffffffc0204ae6:	892a                	mv	s2,a0
ffffffffc0204ae8:	10051063          	bnez	a0,ffffffffc0204be8 <do_pgfault+0x17e>
                    cprintf("swap_in in do_pgfault failed\n");
                    goto failed;
                }
                // 将该物理页与对应的虚拟地址关联，同时设置页表。
                page_insert(mm->pgdir, page, addr, perm);
ffffffffc0204aec:	65a2                	ld	a1,8(sp)
ffffffffc0204aee:	6c88                	ld	a0,24(s1)
ffffffffc0204af0:	86ce                	mv	a3,s3
ffffffffc0204af2:	8622                	mv	a2,s0
ffffffffc0204af4:	abbfd0ef          	jal	ra,ffffffffc02025ae <page_insert>
                cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
                goto failed;
            }
        }
        // 当前缺失的页已经加载回内存中，所以设置当前页为可swap。
        swap_map_swappable(mm, addr, page, 1);
ffffffffc0204af8:	6622                	ld	a2,8(sp)
ffffffffc0204afa:	4685                	li	a3,1
ffffffffc0204afc:	85a2                	mv	a1,s0
ffffffffc0204afe:	8526                	mv	a0,s1
ffffffffc0204b00:	8deff0ef          	jal	ra,ffffffffc0203bde <swap_map_swappable>
        page->pra_vaddr = addr;
ffffffffc0204b04:	67a2                	ld	a5,8(sp)
   }
   ret = 0;
ffffffffc0204b06:	4901                	li	s2,0
        page->pra_vaddr = addr;
ffffffffc0204b08:	ff80                	sd	s0,56(a5)
failed:
    return ret;
}
ffffffffc0204b0a:	60a6                	ld	ra,72(sp)
ffffffffc0204b0c:	6406                	ld	s0,64(sp)
ffffffffc0204b0e:	854a                	mv	a0,s2
ffffffffc0204b10:	74e2                	ld	s1,56(sp)
ffffffffc0204b12:	7942                	ld	s2,48(sp)
ffffffffc0204b14:	79a2                	ld	s3,40(sp)
ffffffffc0204b16:	7a02                	ld	s4,32(sp)
ffffffffc0204b18:	6ae2                	ld	s5,24(sp)
ffffffffc0204b1a:	6161                	addi	sp,sp,80
ffffffffc0204b1c:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0204b1e:	49dd                	li	s3,23
ffffffffc0204b20:	b769                	j	ffffffffc0204aaa <do_pgfault+0x40>
            cprintf("\n\nCOW: ptep 0x%x, pte 0x%x\n",ptep, *ptep);
ffffffffc0204b22:	85aa                	mv	a1,a0
ffffffffc0204b24:	00003517          	auipc	a0,0x3
ffffffffc0204b28:	7b450513          	addi	a0,a0,1972 # ffffffffc02082d8 <default_pmm_manager+0xd90>
ffffffffc0204b2c:	e62fb0ef          	jal	ra,ffffffffc020018e <cprintf>
            page = pte2page(*ptep);
ffffffffc0204b30:	00093783          	ld	a5,0(s2)
    if (!(pte & PTE_V)) {
ffffffffc0204b34:	0017f713          	andi	a4,a5,1
ffffffffc0204b38:	10070663          	beqz	a4,ffffffffc0204c44 <do_pgfault+0x1da>
    if (PPN(pa) >= npage) {
ffffffffc0204b3c:	000a8a17          	auipc	s4,0xa8
ffffffffc0204b40:	9dca0a13          	addi	s4,s4,-1572 # ffffffffc02ac518 <npage>
ffffffffc0204b44:	000a3703          	ld	a4,0(s4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0204b48:	078a                	slli	a5,a5,0x2
ffffffffc0204b4a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204b4c:	10e7f863          	bleu	a4,a5,ffffffffc0204c5c <do_pgfault+0x1f2>
    return &pages[PPN(pa) - nbase];
ffffffffc0204b50:	00004717          	auipc	a4,0x4
ffffffffc0204b54:	42870713          	addi	a4,a4,1064 # ffffffffc0208f78 <nbase>
ffffffffc0204b58:	00073903          	ld	s2,0(a4)
ffffffffc0204b5c:	000a8a97          	auipc	s5,0xa8
ffffffffc0204b60:	a2ca8a93          	addi	s5,s5,-1492 # ffffffffc02ac588 <pages>
ffffffffc0204b64:	000ab583          	ld	a1,0(s5)
ffffffffc0204b68:	412787b3          	sub	a5,a5,s2
ffffffffc0204b6c:	079a                	slli	a5,a5,0x6
ffffffffc0204b6e:	95be                	add	a1,a1,a5
            if(page_ref(page) > 1)
ffffffffc0204b70:	4198                	lw	a4,0(a1)
ffffffffc0204b72:	4785                	li	a5,1
            page = pte2page(*ptep);
ffffffffc0204b74:	e42e                	sd	a1,8(sp)
    return page->ref;
ffffffffc0204b76:	6c88                	ld	a0,24(s1)
            if(page_ref(page) > 1)
ffffffffc0204b78:	f6e7dce3          	ble	a4,a5,ffffffffc0204af0 <do_pgfault+0x86>
                struct Page* newPage = pgdir_alloc_page(mm->pgdir, addr, perm);
ffffffffc0204b7c:	864e                	mv	a2,s3
ffffffffc0204b7e:	85a2                	mv	a1,s0
ffffffffc0204b80:	83bfe0ef          	jal	ra,ffffffffc02033ba <pgdir_alloc_page>
    return page - pages + nbase;
ffffffffc0204b84:	000ab783          	ld	a5,0(s5)
ffffffffc0204b88:	66a2                	ld	a3,8(sp)
    return KADDR(page2pa(page));
ffffffffc0204b8a:	577d                	li	a4,-1
ffffffffc0204b8c:	000a3603          	ld	a2,0(s4)
    return page - pages + nbase;
ffffffffc0204b90:	8e9d                	sub	a3,a3,a5
ffffffffc0204b92:	8699                	srai	a3,a3,0x6
ffffffffc0204b94:	96ca                	add	a3,a3,s2
    return KADDR(page2pa(page));
ffffffffc0204b96:	8331                	srli	a4,a4,0xc
ffffffffc0204b98:	00e6f5b3          	and	a1,a3,a4
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b9c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204b9e:	08c5f763          	bleu	a2,a1,ffffffffc0204c2c <do_pgfault+0x1c2>
    return page - pages + nbase;
ffffffffc0204ba2:	40f507b3          	sub	a5,a0,a5
    return KADDR(page2pa(page));
ffffffffc0204ba6:	000a8597          	auipc	a1,0xa8
ffffffffc0204baa:	9d258593          	addi	a1,a1,-1582 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0204bae:	6188                	ld	a0,0(a1)
    return page - pages + nbase;
ffffffffc0204bb0:	8799                	srai	a5,a5,0x6
ffffffffc0204bb2:	97ca                	add	a5,a5,s2
    return KADDR(page2pa(page));
ffffffffc0204bb4:	8f7d                	and	a4,a4,a5
ffffffffc0204bb6:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0204bba:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0204bbc:	06c77763          	bleu	a2,a4,ffffffffc0204c2a <do_pgfault+0x1c0>
                memcpy(kva_dst, kva_src, PGSIZE);
ffffffffc0204bc0:	6605                	lui	a2,0x1
ffffffffc0204bc2:	953e                	add	a0,a0,a5
ffffffffc0204bc4:	41b010ef          	jal	ra,ffffffffc02067de <memcpy>
ffffffffc0204bc8:	bf05                	j	ffffffffc0204af8 <do_pgfault+0x8e>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204bca:	6c88                	ld	a0,24(s1)
ffffffffc0204bcc:	864e                	mv	a2,s3
ffffffffc0204bce:	85a2                	mv	a1,s0
ffffffffc0204bd0:	feafe0ef          	jal	ra,ffffffffc02033ba <pgdir_alloc_page>
   ret = 0;
ffffffffc0204bd4:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204bd6:	f915                	bnez	a0,ffffffffc0204b0a <do_pgfault+0xa0>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204bd8:	00003517          	auipc	a0,0x3
ffffffffc0204bdc:	6d850513          	addi	a0,a0,1752 # ffffffffc02082b0 <default_pmm_manager+0xd68>
ffffffffc0204be0:	daefb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204be4:	5971                	li	s2,-4
            goto failed;
ffffffffc0204be6:	b715                	j	ffffffffc0204b0a <do_pgfault+0xa0>
                    cprintf("swap_in in do_pgfault failed\n");
ffffffffc0204be8:	00003517          	auipc	a0,0x3
ffffffffc0204bec:	71050513          	addi	a0,a0,1808 # ffffffffc02082f8 <default_pmm_manager+0xdb0>
ffffffffc0204bf0:	d9efb0ef          	jal	ra,ffffffffc020018e <cprintf>
                    goto failed;
ffffffffc0204bf4:	bf19                	j	ffffffffc0204b0a <do_pgfault+0xa0>
                cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
ffffffffc0204bf6:	85b2                	mv	a1,a2
ffffffffc0204bf8:	00003517          	auipc	a0,0x3
ffffffffc0204bfc:	72050513          	addi	a0,a0,1824 # ffffffffc0208318 <default_pmm_manager+0xdd0>
ffffffffc0204c00:	d8efb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204c04:	5971                	li	s2,-4
                goto failed;
ffffffffc0204c06:	b711                	j	ffffffffc0204b0a <do_pgfault+0xa0>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204c08:	85a2                	mv	a1,s0
ffffffffc0204c0a:	00003517          	auipc	a0,0x3
ffffffffc0204c0e:	65650513          	addi	a0,a0,1622 # ffffffffc0208260 <default_pmm_manager+0xd18>
ffffffffc0204c12:	d7cfb0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = -E_INVAL;
ffffffffc0204c16:	5975                	li	s2,-3
        goto failed;
ffffffffc0204c18:	bdcd                	j	ffffffffc0204b0a <do_pgfault+0xa0>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204c1a:	00003517          	auipc	a0,0x3
ffffffffc0204c1e:	67650513          	addi	a0,a0,1654 # ffffffffc0208290 <default_pmm_manager+0xd48>
ffffffffc0204c22:	d6cfb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204c26:	5971                	li	s2,-4
        goto failed;
ffffffffc0204c28:	b5cd                	j	ffffffffc0204b0a <do_pgfault+0xa0>
ffffffffc0204c2a:	86be                	mv	a3,a5
ffffffffc0204c2c:	00003617          	auipc	a2,0x3
ffffffffc0204c30:	96c60613          	addi	a2,a2,-1684 # ffffffffc0207598 <default_pmm_manager+0x50>
ffffffffc0204c34:	06900593          	li	a1,105
ffffffffc0204c38:	00003517          	auipc	a0,0x3
ffffffffc0204c3c:	98850513          	addi	a0,a0,-1656 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0204c40:	845fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0204c44:	00003617          	auipc	a2,0x3
ffffffffc0204c48:	c5c60613          	addi	a2,a2,-932 # ffffffffc02078a0 <default_pmm_manager+0x358>
ffffffffc0204c4c:	07400593          	li	a1,116
ffffffffc0204c50:	00003517          	auipc	a0,0x3
ffffffffc0204c54:	97050513          	addi	a0,a0,-1680 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0204c58:	82dfb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204c5c:	00003617          	auipc	a2,0x3
ffffffffc0204c60:	99c60613          	addi	a2,a2,-1636 # ffffffffc02075f8 <default_pmm_manager+0xb0>
ffffffffc0204c64:	06200593          	li	a1,98
ffffffffc0204c68:	00003517          	auipc	a0,0x3
ffffffffc0204c6c:	95850513          	addi	a0,a0,-1704 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0204c70:	815fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204c74 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0204c74:	7179                	addi	sp,sp,-48
ffffffffc0204c76:	f022                	sd	s0,32(sp)
ffffffffc0204c78:	f406                	sd	ra,40(sp)
ffffffffc0204c7a:	ec26                	sd	s1,24(sp)
ffffffffc0204c7c:	e84a                	sd	s2,16(sp)
ffffffffc0204c7e:	e44e                	sd	s3,8(sp)
ffffffffc0204c80:	e052                	sd	s4,0(sp)
ffffffffc0204c82:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0204c84:	c135                	beqz	a0,ffffffffc0204ce8 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0204c86:	002007b7          	lui	a5,0x200
ffffffffc0204c8a:	04f5e663          	bltu	a1,a5,ffffffffc0204cd6 <user_mem_check+0x62>
ffffffffc0204c8e:	00c584b3          	add	s1,a1,a2
ffffffffc0204c92:	0495f263          	bleu	s1,a1,ffffffffc0204cd6 <user_mem_check+0x62>
ffffffffc0204c96:	4785                	li	a5,1
ffffffffc0204c98:	07fe                	slli	a5,a5,0x1f
ffffffffc0204c9a:	0297ee63          	bltu	a5,s1,ffffffffc0204cd6 <user_mem_check+0x62>
ffffffffc0204c9e:	892a                	mv	s2,a0
ffffffffc0204ca0:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204ca2:	6a05                	lui	s4,0x1
ffffffffc0204ca4:	a821                	j	ffffffffc0204cbc <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204ca6:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204caa:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204cac:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204cae:	c685                	beqz	a3,ffffffffc0204cd6 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204cb0:	c399                	beqz	a5,ffffffffc0204cb6 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204cb2:	02e46263          	bltu	s0,a4,ffffffffc0204cd6 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0204cb6:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0204cb8:	04947663          	bleu	s1,s0,ffffffffc0204d04 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0204cbc:	85a2                	mv	a1,s0
ffffffffc0204cbe:	854a                	mv	a0,s2
ffffffffc0204cc0:	d42ff0ef          	jal	ra,ffffffffc0204202 <find_vma>
ffffffffc0204cc4:	c909                	beqz	a0,ffffffffc0204cd6 <user_mem_check+0x62>
ffffffffc0204cc6:	6518                	ld	a4,8(a0)
ffffffffc0204cc8:	00e46763          	bltu	s0,a4,ffffffffc0204cd6 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204ccc:	4d1c                	lw	a5,24(a0)
ffffffffc0204cce:	fc099ce3          	bnez	s3,ffffffffc0204ca6 <user_mem_check+0x32>
ffffffffc0204cd2:	8b85                	andi	a5,a5,1
ffffffffc0204cd4:	f3ed                	bnez	a5,ffffffffc0204cb6 <user_mem_check+0x42>
            return 0;
ffffffffc0204cd6:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0204cd8:	70a2                	ld	ra,40(sp)
ffffffffc0204cda:	7402                	ld	s0,32(sp)
ffffffffc0204cdc:	64e2                	ld	s1,24(sp)
ffffffffc0204cde:	6942                	ld	s2,16(sp)
ffffffffc0204ce0:	69a2                	ld	s3,8(sp)
ffffffffc0204ce2:	6a02                	ld	s4,0(sp)
ffffffffc0204ce4:	6145                	addi	sp,sp,48
ffffffffc0204ce6:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204ce8:	c02007b7          	lui	a5,0xc0200
ffffffffc0204cec:	4501                	li	a0,0
ffffffffc0204cee:	fef5e5e3          	bltu	a1,a5,ffffffffc0204cd8 <user_mem_check+0x64>
ffffffffc0204cf2:	962e                	add	a2,a2,a1
ffffffffc0204cf4:	fec5f2e3          	bleu	a2,a1,ffffffffc0204cd8 <user_mem_check+0x64>
ffffffffc0204cf8:	c8000537          	lui	a0,0xc8000
ffffffffc0204cfc:	0505                	addi	a0,a0,1
ffffffffc0204cfe:	00a63533          	sltu	a0,a2,a0
ffffffffc0204d02:	bfd9                	j	ffffffffc0204cd8 <user_mem_check+0x64>
        return 1;
ffffffffc0204d04:	4505                	li	a0,1
ffffffffc0204d06:	bfc9                	j	ffffffffc0204cd8 <user_mem_check+0x64>

ffffffffc0204d08 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204d08:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204d0a:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204d0c:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204d0e:	8f1fb0ef          	jal	ra,ffffffffc02005fe <ide_device_valid>
ffffffffc0204d12:	cd01                	beqz	a0,ffffffffc0204d2a <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204d14:	4505                	li	a0,1
ffffffffc0204d16:	8effb0ef          	jal	ra,ffffffffc0200604 <ide_device_size>
}
ffffffffc0204d1a:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204d1c:	810d                	srli	a0,a0,0x3
ffffffffc0204d1e:	000a8797          	auipc	a5,0xa8
ffffffffc0204d22:	8ea7bd23          	sd	a0,-1798(a5) # ffffffffc02ac618 <max_swap_offset>
}
ffffffffc0204d26:	0141                	addi	sp,sp,16
ffffffffc0204d28:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204d2a:	00004617          	auipc	a2,0x4
ffffffffc0204d2e:	8d660613          	addi	a2,a2,-1834 # ffffffffc0208600 <default_pmm_manager+0x10b8>
ffffffffc0204d32:	45b5                	li	a1,13
ffffffffc0204d34:	00004517          	auipc	a0,0x4
ffffffffc0204d38:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0208620 <default_pmm_manager+0x10d8>
ffffffffc0204d3c:	f48fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204d40 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204d40:	1141                	addi	sp,sp,-16
ffffffffc0204d42:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d44:	00855793          	srli	a5,a0,0x8
ffffffffc0204d48:	cfb9                	beqz	a5,ffffffffc0204da6 <swapfs_read+0x66>
ffffffffc0204d4a:	000a8717          	auipc	a4,0xa8
ffffffffc0204d4e:	8ce70713          	addi	a4,a4,-1842 # ffffffffc02ac618 <max_swap_offset>
ffffffffc0204d52:	6318                	ld	a4,0(a4)
ffffffffc0204d54:	04e7f963          	bleu	a4,a5,ffffffffc0204da6 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204d58:	000a8717          	auipc	a4,0xa8
ffffffffc0204d5c:	83070713          	addi	a4,a4,-2000 # ffffffffc02ac588 <pages>
ffffffffc0204d60:	6310                	ld	a2,0(a4)
ffffffffc0204d62:	00004717          	auipc	a4,0x4
ffffffffc0204d66:	21670713          	addi	a4,a4,534 # ffffffffc0208f78 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204d6a:	000a7697          	auipc	a3,0xa7
ffffffffc0204d6e:	7ae68693          	addi	a3,a3,1966 # ffffffffc02ac518 <npage>
    return page - pages + nbase;
ffffffffc0204d72:	40c58633          	sub	a2,a1,a2
ffffffffc0204d76:	630c                	ld	a1,0(a4)
ffffffffc0204d78:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204d7a:	577d                	li	a4,-1
ffffffffc0204d7c:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204d7e:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204d80:	8331                	srli	a4,a4,0xc
ffffffffc0204d82:	8f71                	and	a4,a4,a2
ffffffffc0204d84:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204d88:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204d8a:	02d77a63          	bleu	a3,a4,ffffffffc0204dbe <swapfs_read+0x7e>
ffffffffc0204d8e:	000a7797          	auipc	a5,0xa7
ffffffffc0204d92:	7ea78793          	addi	a5,a5,2026 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0204d96:	639c                	ld	a5,0(a5)
}
ffffffffc0204d98:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d9a:	46a1                	li	a3,8
ffffffffc0204d9c:	963e                	add	a2,a2,a5
ffffffffc0204d9e:	4505                	li	a0,1
}
ffffffffc0204da0:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204da2:	869fb06f          	j	ffffffffc020060a <ide_read_secs>
ffffffffc0204da6:	86aa                	mv	a3,a0
ffffffffc0204da8:	00004617          	auipc	a2,0x4
ffffffffc0204dac:	89060613          	addi	a2,a2,-1904 # ffffffffc0208638 <default_pmm_manager+0x10f0>
ffffffffc0204db0:	45d1                	li	a1,20
ffffffffc0204db2:	00004517          	auipc	a0,0x4
ffffffffc0204db6:	86e50513          	addi	a0,a0,-1938 # ffffffffc0208620 <default_pmm_manager+0x10d8>
ffffffffc0204dba:	ecafb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0204dbe:	86b2                	mv	a3,a2
ffffffffc0204dc0:	06900593          	li	a1,105
ffffffffc0204dc4:	00002617          	auipc	a2,0x2
ffffffffc0204dc8:	7d460613          	addi	a2,a2,2004 # ffffffffc0207598 <default_pmm_manager+0x50>
ffffffffc0204dcc:	00002517          	auipc	a0,0x2
ffffffffc0204dd0:	7f450513          	addi	a0,a0,2036 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0204dd4:	eb0fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204dd8 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204dd8:	1141                	addi	sp,sp,-16
ffffffffc0204dda:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204ddc:	00855793          	srli	a5,a0,0x8
ffffffffc0204de0:	cfb9                	beqz	a5,ffffffffc0204e3e <swapfs_write+0x66>
ffffffffc0204de2:	000a8717          	auipc	a4,0xa8
ffffffffc0204de6:	83670713          	addi	a4,a4,-1994 # ffffffffc02ac618 <max_swap_offset>
ffffffffc0204dea:	6318                	ld	a4,0(a4)
ffffffffc0204dec:	04e7f963          	bleu	a4,a5,ffffffffc0204e3e <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204df0:	000a7717          	auipc	a4,0xa7
ffffffffc0204df4:	79870713          	addi	a4,a4,1944 # ffffffffc02ac588 <pages>
ffffffffc0204df8:	6310                	ld	a2,0(a4)
ffffffffc0204dfa:	00004717          	auipc	a4,0x4
ffffffffc0204dfe:	17e70713          	addi	a4,a4,382 # ffffffffc0208f78 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204e02:	000a7697          	auipc	a3,0xa7
ffffffffc0204e06:	71668693          	addi	a3,a3,1814 # ffffffffc02ac518 <npage>
    return page - pages + nbase;
ffffffffc0204e0a:	40c58633          	sub	a2,a1,a2
ffffffffc0204e0e:	630c                	ld	a1,0(a4)
ffffffffc0204e10:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204e12:	577d                	li	a4,-1
ffffffffc0204e14:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204e16:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204e18:	8331                	srli	a4,a4,0xc
ffffffffc0204e1a:	8f71                	and	a4,a4,a2
ffffffffc0204e1c:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e20:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204e22:	02d77a63          	bleu	a3,a4,ffffffffc0204e56 <swapfs_write+0x7e>
ffffffffc0204e26:	000a7797          	auipc	a5,0xa7
ffffffffc0204e2a:	75278793          	addi	a5,a5,1874 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0204e2e:	639c                	ld	a5,0(a5)
}
ffffffffc0204e30:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204e32:	46a1                	li	a3,8
ffffffffc0204e34:	963e                	add	a2,a2,a5
ffffffffc0204e36:	4505                	li	a0,1
}
ffffffffc0204e38:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204e3a:	ff4fb06f          	j	ffffffffc020062e <ide_write_secs>
ffffffffc0204e3e:	86aa                	mv	a3,a0
ffffffffc0204e40:	00003617          	auipc	a2,0x3
ffffffffc0204e44:	7f860613          	addi	a2,a2,2040 # ffffffffc0208638 <default_pmm_manager+0x10f0>
ffffffffc0204e48:	45e5                	li	a1,25
ffffffffc0204e4a:	00003517          	auipc	a0,0x3
ffffffffc0204e4e:	7d650513          	addi	a0,a0,2006 # ffffffffc0208620 <default_pmm_manager+0x10d8>
ffffffffc0204e52:	e32fb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0204e56:	86b2                	mv	a3,a2
ffffffffc0204e58:	06900593          	li	a1,105
ffffffffc0204e5c:	00002617          	auipc	a2,0x2
ffffffffc0204e60:	73c60613          	addi	a2,a2,1852 # ffffffffc0207598 <default_pmm_manager+0x50>
ffffffffc0204e64:	00002517          	auipc	a0,0x2
ffffffffc0204e68:	75c50513          	addi	a0,a0,1884 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0204e6c:	e18fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204e70 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204e70:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204e72:	9402                	jalr	s0

	jal do_exit
ffffffffc0204e74:	732000ef          	jal	ra,ffffffffc02055a6 <do_exit>

ffffffffc0204e78 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204e78:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204e7a:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204e7e:	e022                	sd	s0,0(sp)
ffffffffc0204e80:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204e82:	e0dfc0ef          	jal	ra,ffffffffc0201c8e <kmalloc>
ffffffffc0204e86:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204e88:	cd29                	beqz	a0,ffffffffc0204ee2 <alloc_proc+0x6a>
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
    
        proc->state = PROC_UNINIT;
ffffffffc0204e8a:	57fd                	li	a5,-1
ffffffffc0204e8c:	1782                	slli	a5,a5,0x20
ffffffffc0204e8e:	e11c                	sd	a5,0(a0)
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        proc->mm = NULL; // 进程所用的虚拟内存
        memset(&(proc->context), 0, sizeof(struct context)); // 进程的上下文
ffffffffc0204e90:	07000613          	li	a2,112
ffffffffc0204e94:	4581                	li	a1,0
        proc->runs = 0;
ffffffffc0204e96:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0204e9a:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0204e9e:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0204ea2:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0204ea6:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context)); // 进程的上下文
ffffffffc0204eaa:	03050513          	addi	a0,a0,48
ffffffffc0204eae:	11f010ef          	jal	ra,ffffffffc02067cc <memset>
        proc->tf = NULL; // 中断帧指针
        proc->cr3 = boot_cr3; // 页目录表地址 设为 内核页目录表基址
ffffffffc0204eb2:	000a7797          	auipc	a5,0xa7
ffffffffc0204eb6:	6ce78793          	addi	a5,a5,1742 # ffffffffc02ac580 <boot_cr3>
ffffffffc0204eba:	639c                	ld	a5,0(a5)
        proc->tf = NULL; // 中断帧指针
ffffffffc0204ebc:	0a043023          	sd	zero,160(s0)
        proc->flags = 0; // 标志位
ffffffffc0204ec0:	0a042823          	sw	zero,176(s0)
        proc->cr3 = boot_cr3; // 页目录表地址 设为 内核页目录表基址
ffffffffc0204ec4:	f45c                	sd	a5,168(s0)
        memset(&(proc->name), 0, PROC_NAME_LEN); // 进程名
ffffffffc0204ec6:	463d                	li	a2,15
ffffffffc0204ec8:	4581                	li	a1,0
ffffffffc0204eca:	0b440513          	addi	a0,s0,180
ffffffffc0204ece:	0ff010ef          	jal	ra,ffffffffc02067cc <memset>
        proc->wait_state = 0;  
ffffffffc0204ed2:	0e042623          	sw	zero,236(s0)
        proc->cptr = proc->optr = proc->yptr = NULL;
ffffffffc0204ed6:	0e043c23          	sd	zero,248(s0)
ffffffffc0204eda:	10043023          	sd	zero,256(s0)
ffffffffc0204ede:	0e043823          	sd	zero,240(s0)
    }
    return proc;
}
ffffffffc0204ee2:	8522                	mv	a0,s0
ffffffffc0204ee4:	60a2                	ld	ra,8(sp)
ffffffffc0204ee6:	6402                	ld	s0,0(sp)
ffffffffc0204ee8:	0141                	addi	sp,sp,16
ffffffffc0204eea:	8082                	ret

ffffffffc0204eec <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204eec:	000a7797          	auipc	a5,0xa7
ffffffffc0204ef0:	64478793          	addi	a5,a5,1604 # ffffffffc02ac530 <current>
ffffffffc0204ef4:	639c                	ld	a5,0(a5)
ffffffffc0204ef6:	73c8                	ld	a0,160(a5)
ffffffffc0204ef8:	eebfb06f          	j	ffffffffc0200de2 <forkrets>

ffffffffc0204efc <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204efc:	000a7797          	auipc	a5,0xa7
ffffffffc0204f00:	63478793          	addi	a5,a5,1588 # ffffffffc02ac530 <current>
ffffffffc0204f04:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0204f06:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204f08:	00004617          	auipc	a2,0x4
ffffffffc0204f0c:	b4060613          	addi	a2,a2,-1216 # ffffffffc0208a48 <default_pmm_manager+0x1500>
ffffffffc0204f10:	43cc                	lw	a1,4(a5)
ffffffffc0204f12:	00004517          	auipc	a0,0x4
ffffffffc0204f16:	b4650513          	addi	a0,a0,-1210 # ffffffffc0208a58 <default_pmm_manager+0x1510>
user_main(void *arg) {
ffffffffc0204f1a:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204f1c:	a72fb0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0204f20:	00004797          	auipc	a5,0x4
ffffffffc0204f24:	b2878793          	addi	a5,a5,-1240 # ffffffffc0208a48 <default_pmm_manager+0x1500>
ffffffffc0204f28:	3fe05717          	auipc	a4,0x3fe05
ffffffffc0204f2c:	3b870713          	addi	a4,a4,952 # a2e0 <_binary_obj___user_forktest_out_size>
ffffffffc0204f30:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204f32:	853e                	mv	a0,a5
ffffffffc0204f34:	00043717          	auipc	a4,0x43
ffffffffc0204f38:	14c70713          	addi	a4,a4,332 # ffffffffc0248080 <_binary_obj___user_forktest_out_start>
ffffffffc0204f3c:	f03a                	sd	a4,32(sp)
ffffffffc0204f3e:	f43e                	sd	a5,40(sp)
ffffffffc0204f40:	e802                	sd	zero,16(sp)
ffffffffc0204f42:	7ec010ef          	jal	ra,ffffffffc020672e <strlen>
ffffffffc0204f46:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204f48:	4511                	li	a0,4
ffffffffc0204f4a:	55a2                	lw	a1,40(sp)
ffffffffc0204f4c:	4662                	lw	a2,24(sp)
ffffffffc0204f4e:	5682                	lw	a3,32(sp)
ffffffffc0204f50:	4722                	lw	a4,8(sp)
ffffffffc0204f52:	48a9                	li	a7,10
ffffffffc0204f54:	9002                	ebreak
ffffffffc0204f56:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204f58:	65c2                	ld	a1,16(sp)
ffffffffc0204f5a:	00004517          	auipc	a0,0x4
ffffffffc0204f5e:	b2650513          	addi	a0,a0,-1242 # ffffffffc0208a80 <default_pmm_manager+0x1538>
ffffffffc0204f62:	a2cfb0ef          	jal	ra,ffffffffc020018e <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204f66:	00004617          	auipc	a2,0x4
ffffffffc0204f6a:	b2a60613          	addi	a2,a2,-1238 # ffffffffc0208a90 <default_pmm_manager+0x1548>
ffffffffc0204f6e:	35900593          	li	a1,857
ffffffffc0204f72:	00004517          	auipc	a0,0x4
ffffffffc0204f76:	b3e50513          	addi	a0,a0,-1218 # ffffffffc0208ab0 <default_pmm_manager+0x1568>
ffffffffc0204f7a:	d0afb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204f7e <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204f7e:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204f80:	1141                	addi	sp,sp,-16
ffffffffc0204f82:	e406                	sd	ra,8(sp)
ffffffffc0204f84:	c02007b7          	lui	a5,0xc0200
ffffffffc0204f88:	04f6e263          	bltu	a3,a5,ffffffffc0204fcc <put_pgdir+0x4e>
ffffffffc0204f8c:	000a7797          	auipc	a5,0xa7
ffffffffc0204f90:	5ec78793          	addi	a5,a5,1516 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0204f94:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204f96:	000a7797          	auipc	a5,0xa7
ffffffffc0204f9a:	58278793          	addi	a5,a5,1410 # ffffffffc02ac518 <npage>
ffffffffc0204f9e:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0204fa0:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204fa2:	82b1                	srli	a3,a3,0xc
ffffffffc0204fa4:	04f6f063          	bleu	a5,a3,ffffffffc0204fe4 <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc0204fa8:	00004797          	auipc	a5,0x4
ffffffffc0204fac:	fd078793          	addi	a5,a5,-48 # ffffffffc0208f78 <nbase>
ffffffffc0204fb0:	639c                	ld	a5,0(a5)
ffffffffc0204fb2:	000a7717          	auipc	a4,0xa7
ffffffffc0204fb6:	5d670713          	addi	a4,a4,1494 # ffffffffc02ac588 <pages>
ffffffffc0204fba:	6308                	ld	a0,0(a4)
}
ffffffffc0204fbc:	60a2                	ld	ra,8(sp)
ffffffffc0204fbe:	8e9d                	sub	a3,a3,a5
ffffffffc0204fc0:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204fc2:	4585                	li	a1,1
ffffffffc0204fc4:	9536                	add	a0,a0,a3
}
ffffffffc0204fc6:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204fc8:	f4bfc06f          	j	ffffffffc0201f12 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204fcc:	00002617          	auipc	a2,0x2
ffffffffc0204fd0:	60460613          	addi	a2,a2,1540 # ffffffffc02075d0 <default_pmm_manager+0x88>
ffffffffc0204fd4:	06e00593          	li	a1,110
ffffffffc0204fd8:	00002517          	auipc	a0,0x2
ffffffffc0204fdc:	5e850513          	addi	a0,a0,1512 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0204fe0:	ca4fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204fe4:	00002617          	auipc	a2,0x2
ffffffffc0204fe8:	61460613          	addi	a2,a2,1556 # ffffffffc02075f8 <default_pmm_manager+0xb0>
ffffffffc0204fec:	06200593          	li	a1,98
ffffffffc0204ff0:	00002517          	auipc	a0,0x2
ffffffffc0204ff4:	5d050513          	addi	a0,a0,1488 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0204ff8:	c8cfb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204ffc <setup_pgdir>:
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204ffc:	1101                	addi	sp,sp,-32
ffffffffc0204ffe:	e426                	sd	s1,8(sp)
ffffffffc0205000:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL) {
ffffffffc0205002:	4505                	li	a0,1
setup_pgdir(struct mm_struct *mm) {
ffffffffc0205004:	ec06                	sd	ra,24(sp)
ffffffffc0205006:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL) {
ffffffffc0205008:	e83fc0ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
ffffffffc020500c:	c125                	beqz	a0,ffffffffc020506c <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc020500e:	000a7797          	auipc	a5,0xa7
ffffffffc0205012:	57a78793          	addi	a5,a5,1402 # ffffffffc02ac588 <pages>
ffffffffc0205016:	6394                	ld	a3,0(a5)
ffffffffc0205018:	00004797          	auipc	a5,0x4
ffffffffc020501c:	f6078793          	addi	a5,a5,-160 # ffffffffc0208f78 <nbase>
ffffffffc0205020:	6380                	ld	s0,0(a5)
ffffffffc0205022:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0205026:	000a7717          	auipc	a4,0xa7
ffffffffc020502a:	4f270713          	addi	a4,a4,1266 # ffffffffc02ac518 <npage>
    return page - pages + nbase;
ffffffffc020502e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205030:	57fd                	li	a5,-1
ffffffffc0205032:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0205034:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0205036:	83b1                	srli	a5,a5,0xc
ffffffffc0205038:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020503a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020503c:	02e7fa63          	bleu	a4,a5,ffffffffc0205070 <setup_pgdir+0x74>
ffffffffc0205040:	000a7797          	auipc	a5,0xa7
ffffffffc0205044:	53878793          	addi	a5,a5,1336 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0205048:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc020504a:	000a7797          	auipc	a5,0xa7
ffffffffc020504e:	4c678793          	addi	a5,a5,1222 # ffffffffc02ac510 <boot_pgdir>
ffffffffc0205052:	638c                	ld	a1,0(a5)
ffffffffc0205054:	9436                	add	s0,s0,a3
ffffffffc0205056:	6605                	lui	a2,0x1
ffffffffc0205058:	8522                	mv	a0,s0
ffffffffc020505a:	784010ef          	jal	ra,ffffffffc02067de <memcpy>
    return 0;
ffffffffc020505e:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc0205060:	ec80                	sd	s0,24(s1)
}
ffffffffc0205062:	60e2                	ld	ra,24(sp)
ffffffffc0205064:	6442                	ld	s0,16(sp)
ffffffffc0205066:	64a2                	ld	s1,8(sp)
ffffffffc0205068:	6105                	addi	sp,sp,32
ffffffffc020506a:	8082                	ret
        return -E_NO_MEM;
ffffffffc020506c:	5571                	li	a0,-4
ffffffffc020506e:	bfd5                	j	ffffffffc0205062 <setup_pgdir+0x66>
ffffffffc0205070:	00002617          	auipc	a2,0x2
ffffffffc0205074:	52860613          	addi	a2,a2,1320 # ffffffffc0207598 <default_pmm_manager+0x50>
ffffffffc0205078:	06900593          	li	a1,105
ffffffffc020507c:	00002517          	auipc	a0,0x2
ffffffffc0205080:	54450513          	addi	a0,a0,1348 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0205084:	c00fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205088 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0205088:	1101                	addi	sp,sp,-32
ffffffffc020508a:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020508c:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0205090:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205092:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0205094:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205096:	8522                	mv	a0,s0
ffffffffc0205098:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020509a:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020509c:	730010ef          	jal	ra,ffffffffc02067cc <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02050a0:	8522                	mv	a0,s0
}
ffffffffc02050a2:	6442                	ld	s0,16(sp)
ffffffffc02050a4:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02050a6:	85a6                	mv	a1,s1
}
ffffffffc02050a8:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02050aa:	463d                	li	a2,15
}
ffffffffc02050ac:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02050ae:	7300106f          	j	ffffffffc02067de <memcpy>

ffffffffc02050b2 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc02050b2:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc02050b4:	000a7797          	auipc	a5,0xa7
ffffffffc02050b8:	47c78793          	addi	a5,a5,1148 # ffffffffc02ac530 <current>
proc_run(struct proc_struct *proc) {
ffffffffc02050bc:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc02050be:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc02050c0:	ec06                	sd	ra,24(sp)
ffffffffc02050c2:	e822                	sd	s0,16(sp)
ffffffffc02050c4:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc02050c6:	02a48b63          	beq	s1,a0,ffffffffc02050fc <proc_run+0x4a>
ffffffffc02050ca:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050cc:	100027f3          	csrr	a5,sstatus
ffffffffc02050d0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02050d2:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050d4:	e3a9                	bnez	a5,ffffffffc0205116 <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc02050d6:	745c                	ld	a5,168(s0)
            current = proc; // 将当前进程换为 要切换到的进程
ffffffffc02050d8:	000a7717          	auipc	a4,0xa7
ffffffffc02050dc:	44873c23          	sd	s0,1112(a4) # ffffffffc02ac530 <current>
ffffffffc02050e0:	577d                	li	a4,-1
ffffffffc02050e2:	177e                	slli	a4,a4,0x3f
ffffffffc02050e4:	83b1                	srli	a5,a5,0xc
ffffffffc02050e6:	8fd9                	or	a5,a5,a4
ffffffffc02050e8:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context)); // 调用 switch_to 进行上下文的保存与切换
ffffffffc02050ec:	03040593          	addi	a1,s0,48
ffffffffc02050f0:	03048513          	addi	a0,s1,48
ffffffffc02050f4:	7cf000ef          	jal	ra,ffffffffc02060c2 <switch_to>
    if (flag) {
ffffffffc02050f8:	00091863          	bnez	s2,ffffffffc0205108 <proc_run+0x56>
}
ffffffffc02050fc:	60e2                	ld	ra,24(sp)
ffffffffc02050fe:	6442                	ld	s0,16(sp)
ffffffffc0205100:	64a2                	ld	s1,8(sp)
ffffffffc0205102:	6902                	ld	s2,0(sp)
ffffffffc0205104:	6105                	addi	sp,sp,32
ffffffffc0205106:	8082                	ret
ffffffffc0205108:	6442                	ld	s0,16(sp)
ffffffffc020510a:	60e2                	ld	ra,24(sp)
ffffffffc020510c:	64a2                	ld	s1,8(sp)
ffffffffc020510e:	6902                	ld	s2,0(sp)
ffffffffc0205110:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205112:	d42fb06f          	j	ffffffffc0200654 <intr_enable>
        intr_disable();
ffffffffc0205116:	d44fb0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc020511a:	4905                	li	s2,1
ffffffffc020511c:	bf6d                	j	ffffffffc02050d6 <proc_run+0x24>

ffffffffc020511e <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc020511e:	0005071b          	sext.w	a4,a0
ffffffffc0205122:	6789                	lui	a5,0x2
ffffffffc0205124:	fff7069b          	addiw	a3,a4,-1
ffffffffc0205128:	17f9                	addi	a5,a5,-2
ffffffffc020512a:	04d7e063          	bltu	a5,a3,ffffffffc020516a <find_proc+0x4c>
find_proc(int pid) {
ffffffffc020512e:	1141                	addi	sp,sp,-16
ffffffffc0205130:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205132:	45a9                	li	a1,10
ffffffffc0205134:	842a                	mv	s0,a0
ffffffffc0205136:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc0205138:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020513a:	1e4010ef          	jal	ra,ffffffffc020631e <hash32>
ffffffffc020513e:	02051693          	slli	a3,a0,0x20
ffffffffc0205142:	82f1                	srli	a3,a3,0x1c
ffffffffc0205144:	000a3517          	auipc	a0,0xa3
ffffffffc0205148:	3b450513          	addi	a0,a0,948 # ffffffffc02a84f8 <hash_list>
ffffffffc020514c:	96aa                	add	a3,a3,a0
ffffffffc020514e:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0205150:	a029                	j	ffffffffc020515a <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0205152:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x764c>
ffffffffc0205156:	00870c63          	beq	a4,s0,ffffffffc020516e <find_proc+0x50>
ffffffffc020515a:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020515c:	fef69be3          	bne	a3,a5,ffffffffc0205152 <find_proc+0x34>
}
ffffffffc0205160:	60a2                	ld	ra,8(sp)
ffffffffc0205162:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0205164:	4501                	li	a0,0
}
ffffffffc0205166:	0141                	addi	sp,sp,16
ffffffffc0205168:	8082                	ret
    return NULL;
ffffffffc020516a:	4501                	li	a0,0
}
ffffffffc020516c:	8082                	ret
ffffffffc020516e:	60a2                	ld	ra,8(sp)
ffffffffc0205170:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205172:	f2878513          	addi	a0,a5,-216
}
ffffffffc0205176:	0141                	addi	sp,sp,16
ffffffffc0205178:	8082                	ret

ffffffffc020517a <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc020517a:	7159                	addi	sp,sp,-112
ffffffffc020517c:	e0d2                	sd	s4,64(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc020517e:	000a7a17          	auipc	s4,0xa7
ffffffffc0205182:	3caa0a13          	addi	s4,s4,970 # ffffffffc02ac548 <nr_process>
ffffffffc0205186:	000a2703          	lw	a4,0(s4)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc020518a:	f486                	sd	ra,104(sp)
ffffffffc020518c:	f0a2                	sd	s0,96(sp)
ffffffffc020518e:	eca6                	sd	s1,88(sp)
ffffffffc0205190:	e8ca                	sd	s2,80(sp)
ffffffffc0205192:	e4ce                	sd	s3,72(sp)
ffffffffc0205194:	fc56                	sd	s5,56(sp)
ffffffffc0205196:	f85a                	sd	s6,48(sp)
ffffffffc0205198:	f45e                	sd	s7,40(sp)
ffffffffc020519a:	f062                	sd	s8,32(sp)
ffffffffc020519c:	ec66                	sd	s9,24(sp)
ffffffffc020519e:	e86a                	sd	s10,16(sp)
ffffffffc02051a0:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02051a2:	6785                	lui	a5,0x1
ffffffffc02051a4:	30f75a63          	ble	a5,a4,ffffffffc02054b8 <do_fork+0x33e>
ffffffffc02051a8:	89aa                	mv	s3,a0
ffffffffc02051aa:	892e                	mv	s2,a1
ffffffffc02051ac:	84b2                	mv	s1,a2
    if ((proc = alloc_proc()) == NULL)
ffffffffc02051ae:	ccbff0ef          	jal	ra,ffffffffc0204e78 <alloc_proc>
ffffffffc02051b2:	842a                	mv	s0,a0
ffffffffc02051b4:	2e050463          	beqz	a0,ffffffffc020549c <do_fork+0x322>
    proc->parent = current; // 设置父进程
ffffffffc02051b8:	000a7c17          	auipc	s8,0xa7
ffffffffc02051bc:	378c0c13          	addi	s8,s8,888 # ffffffffc02ac530 <current>
ffffffffc02051c0:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0);  
ffffffffc02051c4:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x848c>
    proc->parent = current; // 设置父进程
ffffffffc02051c8:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);  
ffffffffc02051ca:	30071563          	bnez	a4,ffffffffc02054d4 <do_fork+0x35a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02051ce:	4509                	li	a0,2
ffffffffc02051d0:	cbbfc0ef          	jal	ra,ffffffffc0201e8a <alloc_pages>
    if (page != NULL) {
ffffffffc02051d4:	2c050163          	beqz	a0,ffffffffc0205496 <do_fork+0x31c>
    return page - pages + nbase;
ffffffffc02051d8:	000a7a97          	auipc	s5,0xa7
ffffffffc02051dc:	3b0a8a93          	addi	s5,s5,944 # ffffffffc02ac588 <pages>
ffffffffc02051e0:	000ab683          	ld	a3,0(s5)
ffffffffc02051e4:	00004b17          	auipc	s6,0x4
ffffffffc02051e8:	d94b0b13          	addi	s6,s6,-620 # ffffffffc0208f78 <nbase>
ffffffffc02051ec:	000b3783          	ld	a5,0(s6)
ffffffffc02051f0:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc02051f4:	000a7b97          	auipc	s7,0xa7
ffffffffc02051f8:	324b8b93          	addi	s7,s7,804 # ffffffffc02ac518 <npage>
    return page - pages + nbase;
ffffffffc02051fc:	8699                	srai	a3,a3,0x6
ffffffffc02051fe:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205200:	000bb703          	ld	a4,0(s7)
ffffffffc0205204:	57fd                	li	a5,-1
ffffffffc0205206:	83b1                	srli	a5,a5,0xc
ffffffffc0205208:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020520a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020520c:	2ae7f863          	bleu	a4,a5,ffffffffc02054bc <do_fork+0x342>
ffffffffc0205210:	000a7c97          	auipc	s9,0xa7
ffffffffc0205214:	368c8c93          	addi	s9,s9,872 # ffffffffc02ac578 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0205218:	000c3703          	ld	a4,0(s8)
ffffffffc020521c:	000cb783          	ld	a5,0(s9)
ffffffffc0205220:	02873c03          	ld	s8,40(a4)
ffffffffc0205224:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0205226:	e814                	sd	a3,16(s0)
    if (oldmm == NULL) {
ffffffffc0205228:	020c0863          	beqz	s8,ffffffffc0205258 <do_fork+0xde>
    if (clone_flags & CLONE_VM) {
ffffffffc020522c:	1009f993          	andi	s3,s3,256
ffffffffc0205230:	1e098163          	beqz	s3,ffffffffc0205412 <do_fork+0x298>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0205234:	030c2703          	lw	a4,48(s8)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205238:	018c3783          	ld	a5,24(s8)
ffffffffc020523c:	c02006b7          	lui	a3,0xc0200
ffffffffc0205240:	2705                	addiw	a4,a4,1
ffffffffc0205242:	02ec2823          	sw	a4,48(s8)
    proc->mm = mm;
ffffffffc0205246:	03843423          	sd	s8,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020524a:	2ad7e563          	bltu	a5,a3,ffffffffc02054f4 <do_fork+0x37a>
ffffffffc020524e:	000cb703          	ld	a4,0(s9)
ffffffffc0205252:	6814                	ld	a3,16(s0)
ffffffffc0205254:	8f99                	sub	a5,a5,a4
ffffffffc0205256:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205258:	6789                	lui	a5,0x2
ffffffffc020525a:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7698>
ffffffffc020525e:	96be                	add	a3,a3,a5
ffffffffc0205260:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0205262:	87b6                	mv	a5,a3
ffffffffc0205264:	12048813          	addi	a6,s1,288
ffffffffc0205268:	6088                	ld	a0,0(s1)
ffffffffc020526a:	648c                	ld	a1,8(s1)
ffffffffc020526c:	6890                	ld	a2,16(s1)
ffffffffc020526e:	6c98                	ld	a4,24(s1)
ffffffffc0205270:	e388                	sd	a0,0(a5)
ffffffffc0205272:	e78c                	sd	a1,8(a5)
ffffffffc0205274:	eb90                	sd	a2,16(a5)
ffffffffc0205276:	ef98                	sd	a4,24(a5)
ffffffffc0205278:	02048493          	addi	s1,s1,32
ffffffffc020527c:	02078793          	addi	a5,a5,32
ffffffffc0205280:	ff0494e3          	bne	s1,a6,ffffffffc0205268 <do_fork+0xee>
    proc->tf->gpr.a0 = 0;
ffffffffc0205284:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205288:	12090e63          	beqz	s2,ffffffffc02053c4 <do_fork+0x24a>
ffffffffc020528c:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205290:	00000797          	auipc	a5,0x0
ffffffffc0205294:	c5c78793          	addi	a5,a5,-932 # ffffffffc0204eec <forkret>
ffffffffc0205298:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020529a:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020529c:	100027f3          	csrr	a5,sstatus
ffffffffc02052a0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02052a2:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02052a4:	12079f63          	bnez	a5,ffffffffc02053e2 <do_fork+0x268>
    if (++ last_pid >= MAX_PID) {
ffffffffc02052a8:	0009c797          	auipc	a5,0x9c
ffffffffc02052ac:	e4878793          	addi	a5,a5,-440 # ffffffffc02a10f0 <last_pid.1691>
ffffffffc02052b0:	439c                	lw	a5,0(a5)
ffffffffc02052b2:	6709                	lui	a4,0x2
ffffffffc02052b4:	0017851b          	addiw	a0,a5,1
ffffffffc02052b8:	0009c697          	auipc	a3,0x9c
ffffffffc02052bc:	e2a6ac23          	sw	a0,-456(a3) # ffffffffc02a10f0 <last_pid.1691>
ffffffffc02052c0:	14e55263          	ble	a4,a0,ffffffffc0205404 <do_fork+0x28a>
    if (last_pid >= next_safe) {
ffffffffc02052c4:	0009c797          	auipc	a5,0x9c
ffffffffc02052c8:	e3078793          	addi	a5,a5,-464 # ffffffffc02a10f4 <next_safe.1690>
ffffffffc02052cc:	439c                	lw	a5,0(a5)
ffffffffc02052ce:	000a7497          	auipc	s1,0xa7
ffffffffc02052d2:	3a248493          	addi	s1,s1,930 # ffffffffc02ac670 <proc_list>
ffffffffc02052d6:	06f54063          	blt	a0,a5,ffffffffc0205336 <do_fork+0x1bc>
        next_safe = MAX_PID;
ffffffffc02052da:	6789                	lui	a5,0x2
ffffffffc02052dc:	0009c717          	auipc	a4,0x9c
ffffffffc02052e0:	e0f72c23          	sw	a5,-488(a4) # ffffffffc02a10f4 <next_safe.1690>
ffffffffc02052e4:	4581                	li	a1,0
ffffffffc02052e6:	87aa                	mv	a5,a0
ffffffffc02052e8:	000a7497          	auipc	s1,0xa7
ffffffffc02052ec:	38848493          	addi	s1,s1,904 # ffffffffc02ac670 <proc_list>
    repeat:
ffffffffc02052f0:	6889                	lui	a7,0x2
ffffffffc02052f2:	882e                	mv	a6,a1
ffffffffc02052f4:	6609                	lui	a2,0x2
        le = list;
ffffffffc02052f6:	000a7697          	auipc	a3,0xa7
ffffffffc02052fa:	37a68693          	addi	a3,a3,890 # ffffffffc02ac670 <proc_list>
ffffffffc02052fe:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc0205300:	00968f63          	beq	a3,s1,ffffffffc020531e <do_fork+0x1a4>
            if (proc->pid == last_pid) {
ffffffffc0205304:	f3c6a703          	lw	a4,-196(a3)
ffffffffc0205308:	0ae78963          	beq	a5,a4,ffffffffc02053ba <do_fork+0x240>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc020530c:	fee7d9e3          	ble	a4,a5,ffffffffc02052fe <do_fork+0x184>
ffffffffc0205310:	fec757e3          	ble	a2,a4,ffffffffc02052fe <do_fork+0x184>
ffffffffc0205314:	6694                	ld	a3,8(a3)
ffffffffc0205316:	863a                	mv	a2,a4
ffffffffc0205318:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc020531a:	fe9695e3          	bne	a3,s1,ffffffffc0205304 <do_fork+0x18a>
ffffffffc020531e:	c591                	beqz	a1,ffffffffc020532a <do_fork+0x1b0>
ffffffffc0205320:	0009c717          	auipc	a4,0x9c
ffffffffc0205324:	dcf72823          	sw	a5,-560(a4) # ffffffffc02a10f0 <last_pid.1691>
ffffffffc0205328:	853e                	mv	a0,a5
ffffffffc020532a:	00080663          	beqz	a6,ffffffffc0205336 <do_fork+0x1bc>
ffffffffc020532e:	0009c797          	auipc	a5,0x9c
ffffffffc0205332:	dcc7a323          	sw	a2,-570(a5) # ffffffffc02a10f4 <next_safe.1690>
        proc->pid = get_pid(); // 这一句话要在前面！！！ 
ffffffffc0205336:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205338:	45a9                	li	a1,10
ffffffffc020533a:	2501                	sext.w	a0,a0
ffffffffc020533c:	7e3000ef          	jal	ra,ffffffffc020631e <hash32>
ffffffffc0205340:	1502                	slli	a0,a0,0x20
ffffffffc0205342:	000a3797          	auipc	a5,0xa3
ffffffffc0205346:	1b678793          	addi	a5,a5,438 # ffffffffc02a84f8 <hash_list>
ffffffffc020534a:	8171                	srli	a0,a0,0x1c
ffffffffc020534c:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc020534e:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205350:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205352:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc0205356:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0205358:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc020535a:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc020535c:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc020535e:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc0205362:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc0205364:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc0205366:	e21c                	sd	a5,0(a2)
ffffffffc0205368:	000a7597          	auipc	a1,0xa7
ffffffffc020536c:	30f5b823          	sd	a5,784(a1) # ffffffffc02ac678 <proc_list+0x8>
    elm->next = next;
ffffffffc0205370:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc0205372:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc0205374:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205378:	10e43023          	sd	a4,256(s0)
ffffffffc020537c:	c311                	beqz	a4,ffffffffc0205380 <do_fork+0x206>
        proc->optr->yptr = proc;
ffffffffc020537e:	ff60                	sd	s0,248(a4)
    nr_process ++;
ffffffffc0205380:	000a2783          	lw	a5,0(s4)
    proc->parent->cptr = proc;
ffffffffc0205384:	fae0                	sd	s0,240(a3)
    nr_process ++;
ffffffffc0205386:	2785                	addiw	a5,a5,1
ffffffffc0205388:	000a7717          	auipc	a4,0xa7
ffffffffc020538c:	1cf72023          	sw	a5,448(a4) # ffffffffc02ac548 <nr_process>
    if (flag) {
ffffffffc0205390:	10091863          	bnez	s2,ffffffffc02054a0 <do_fork+0x326>
    wakeup_proc(proc);
ffffffffc0205394:	8522                	mv	a0,s0
ffffffffc0205396:	597000ef          	jal	ra,ffffffffc020612c <wakeup_proc>
    ret = proc->pid;
ffffffffc020539a:	4048                	lw	a0,4(s0)
}
ffffffffc020539c:	70a6                	ld	ra,104(sp)
ffffffffc020539e:	7406                	ld	s0,96(sp)
ffffffffc02053a0:	64e6                	ld	s1,88(sp)
ffffffffc02053a2:	6946                	ld	s2,80(sp)
ffffffffc02053a4:	69a6                	ld	s3,72(sp)
ffffffffc02053a6:	6a06                	ld	s4,64(sp)
ffffffffc02053a8:	7ae2                	ld	s5,56(sp)
ffffffffc02053aa:	7b42                	ld	s6,48(sp)
ffffffffc02053ac:	7ba2                	ld	s7,40(sp)
ffffffffc02053ae:	7c02                	ld	s8,32(sp)
ffffffffc02053b0:	6ce2                	ld	s9,24(sp)
ffffffffc02053b2:	6d42                	ld	s10,16(sp)
ffffffffc02053b4:	6da2                	ld	s11,8(sp)
ffffffffc02053b6:	6165                	addi	sp,sp,112
ffffffffc02053b8:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc02053ba:	2785                	addiw	a5,a5,1
ffffffffc02053bc:	0ec7d563          	ble	a2,a5,ffffffffc02054a6 <do_fork+0x32c>
ffffffffc02053c0:	4585                	li	a1,1
ffffffffc02053c2:	bf35                	j	ffffffffc02052fe <do_fork+0x184>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02053c4:	8936                	mv	s2,a3
ffffffffc02053c6:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02053ca:	00000797          	auipc	a5,0x0
ffffffffc02053ce:	b2278793          	addi	a5,a5,-1246 # ffffffffc0204eec <forkret>
ffffffffc02053d2:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02053d4:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02053d6:	100027f3          	csrr	a5,sstatus
ffffffffc02053da:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02053dc:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02053de:	ec0785e3          	beqz	a5,ffffffffc02052a8 <do_fork+0x12e>
        intr_disable();
ffffffffc02053e2:	a78fb0ef          	jal	ra,ffffffffc020065a <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc02053e6:	0009c797          	auipc	a5,0x9c
ffffffffc02053ea:	d0a78793          	addi	a5,a5,-758 # ffffffffc02a10f0 <last_pid.1691>
ffffffffc02053ee:	439c                	lw	a5,0(a5)
ffffffffc02053f0:	6709                	lui	a4,0x2
        return 1;
ffffffffc02053f2:	4905                	li	s2,1
ffffffffc02053f4:	0017851b          	addiw	a0,a5,1
ffffffffc02053f8:	0009c697          	auipc	a3,0x9c
ffffffffc02053fc:	cea6ac23          	sw	a0,-776(a3) # ffffffffc02a10f0 <last_pid.1691>
ffffffffc0205400:	ece542e3          	blt	a0,a4,ffffffffc02052c4 <do_fork+0x14a>
        last_pid = 1;
ffffffffc0205404:	4785                	li	a5,1
ffffffffc0205406:	0009c717          	auipc	a4,0x9c
ffffffffc020540a:	cef72523          	sw	a5,-790(a4) # ffffffffc02a10f0 <last_pid.1691>
ffffffffc020540e:	4505                	li	a0,1
ffffffffc0205410:	b5e9                	j	ffffffffc02052da <do_fork+0x160>
    if ((mm = mm_create()) == NULL) {
ffffffffc0205412:	d77fe0ef          	jal	ra,ffffffffc0204188 <mm_create>
ffffffffc0205416:	8d2a                	mv	s10,a0
ffffffffc0205418:	c539                	beqz	a0,ffffffffc0205466 <do_fork+0x2ec>
    if (setup_pgdir(mm) != 0) {
ffffffffc020541a:	be3ff0ef          	jal	ra,ffffffffc0204ffc <setup_pgdir>
ffffffffc020541e:	e949                	bnez	a0,ffffffffc02054b0 <do_fork+0x336>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc0205420:	038c0d93          	addi	s11,s8,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0205424:	4785                	li	a5,1
ffffffffc0205426:	40fdb7af          	amoor.d	a5,a5,(s11)
ffffffffc020542a:	8b85                	andi	a5,a5,1
ffffffffc020542c:	4985                	li	s3,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc020542e:	c799                	beqz	a5,ffffffffc020543c <do_fork+0x2c2>
        schedule();
ffffffffc0205430:	579000ef          	jal	ra,ffffffffc02061a8 <schedule>
ffffffffc0205434:	413db7af          	amoor.d	a5,s3,(s11)
ffffffffc0205438:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc020543a:	fbfd                	bnez	a5,ffffffffc0205430 <do_fork+0x2b6>
        ret = dup_mmap(mm, oldmm);
ffffffffc020543c:	85e2                	mv	a1,s8
ffffffffc020543e:	856a                	mv	a0,s10
ffffffffc0205440:	fd3fe0ef          	jal	ra,ffffffffc0204412 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0205444:	57f9                	li	a5,-2
ffffffffc0205446:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc020544a:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc020544c:	c3e9                	beqz	a5,ffffffffc020550e <do_fork+0x394>
    if (ret != 0) {
ffffffffc020544e:	8c6a                	mv	s8,s10
ffffffffc0205450:	de0502e3          	beqz	a0,ffffffffc0205234 <do_fork+0xba>
    exit_mmap(mm);
ffffffffc0205454:	856a                	mv	a0,s10
ffffffffc0205456:	858ff0ef          	jal	ra,ffffffffc02044ae <exit_mmap>
    put_pgdir(mm);
ffffffffc020545a:	856a                	mv	a0,s10
ffffffffc020545c:	b23ff0ef          	jal	ra,ffffffffc0204f7e <put_pgdir>
    mm_destroy(mm);
ffffffffc0205460:	856a                	mv	a0,s10
ffffffffc0205462:	eadfe0ef          	jal	ra,ffffffffc020430e <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205466:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0205468:	c02007b7          	lui	a5,0xc0200
ffffffffc020546c:	0cf6e963          	bltu	a3,a5,ffffffffc020553e <do_fork+0x3c4>
ffffffffc0205470:	000cb783          	ld	a5,0(s9)
    if (PPN(pa) >= npage) {
ffffffffc0205474:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc0205478:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc020547c:	83b1                	srli	a5,a5,0xc
ffffffffc020547e:	0ae7f463          	bleu	a4,a5,ffffffffc0205526 <do_fork+0x3ac>
    return &pages[PPN(pa) - nbase];
ffffffffc0205482:	000b3703          	ld	a4,0(s6)
ffffffffc0205486:	000ab503          	ld	a0,0(s5)
ffffffffc020548a:	4589                	li	a1,2
ffffffffc020548c:	8f99                	sub	a5,a5,a4
ffffffffc020548e:	079a                	slli	a5,a5,0x6
ffffffffc0205490:	953e                	add	a0,a0,a5
ffffffffc0205492:	a81fc0ef          	jal	ra,ffffffffc0201f12 <free_pages>
    kfree(proc);
ffffffffc0205496:	8522                	mv	a0,s0
ffffffffc0205498:	8b3fc0ef          	jal	ra,ffffffffc0201d4a <kfree>
    ret = -E_NO_MEM;
ffffffffc020549c:	5571                	li	a0,-4
    return ret;
ffffffffc020549e:	bdfd                	j	ffffffffc020539c <do_fork+0x222>
        intr_enable();
ffffffffc02054a0:	9b4fb0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc02054a4:	bdc5                	j	ffffffffc0205394 <do_fork+0x21a>
                    if (last_pid >= MAX_PID) {
ffffffffc02054a6:	0117c363          	blt	a5,a7,ffffffffc02054ac <do_fork+0x332>
                        last_pid = 1;
ffffffffc02054aa:	4785                	li	a5,1
                    goto repeat;
ffffffffc02054ac:	4585                	li	a1,1
ffffffffc02054ae:	b591                	j	ffffffffc02052f2 <do_fork+0x178>
    mm_destroy(mm);
ffffffffc02054b0:	856a                	mv	a0,s10
ffffffffc02054b2:	e5dfe0ef          	jal	ra,ffffffffc020430e <mm_destroy>
ffffffffc02054b6:	bf45                	j	ffffffffc0205466 <do_fork+0x2ec>
    int ret = -E_NO_FREE_PROC;
ffffffffc02054b8:	556d                	li	a0,-5
ffffffffc02054ba:	b5cd                	j	ffffffffc020539c <do_fork+0x222>
    return KADDR(page2pa(page));
ffffffffc02054bc:	00002617          	auipc	a2,0x2
ffffffffc02054c0:	0dc60613          	addi	a2,a2,220 # ffffffffc0207598 <default_pmm_manager+0x50>
ffffffffc02054c4:	06900593          	li	a1,105
ffffffffc02054c8:	00002517          	auipc	a0,0x2
ffffffffc02054cc:	0f850513          	addi	a0,a0,248 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc02054d0:	fb5fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(current->wait_state == 0);  
ffffffffc02054d4:	00003697          	auipc	a3,0x3
ffffffffc02054d8:	34c68693          	addi	a3,a3,844 # ffffffffc0208820 <default_pmm_manager+0x12d8>
ffffffffc02054dc:	00002617          	auipc	a2,0x2
ffffffffc02054e0:	92460613          	addi	a2,a2,-1756 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02054e4:	1b500593          	li	a1,437
ffffffffc02054e8:	00003517          	auipc	a0,0x3
ffffffffc02054ec:	5c850513          	addi	a0,a0,1480 # ffffffffc0208ab0 <default_pmm_manager+0x1568>
ffffffffc02054f0:	f95fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02054f4:	86be                	mv	a3,a5
ffffffffc02054f6:	00002617          	auipc	a2,0x2
ffffffffc02054fa:	0da60613          	addi	a2,a2,218 # ffffffffc02075d0 <default_pmm_manager+0x88>
ffffffffc02054fe:	16700593          	li	a1,359
ffffffffc0205502:	00003517          	auipc	a0,0x3
ffffffffc0205506:	5ae50513          	addi	a0,a0,1454 # ffffffffc0208ab0 <default_pmm_manager+0x1568>
ffffffffc020550a:	f7bfa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("Unlock failed.\n");
ffffffffc020550e:	00003617          	auipc	a2,0x3
ffffffffc0205512:	33260613          	addi	a2,a2,818 # ffffffffc0208840 <default_pmm_manager+0x12f8>
ffffffffc0205516:	03100593          	li	a1,49
ffffffffc020551a:	00003517          	auipc	a0,0x3
ffffffffc020551e:	33650513          	addi	a0,a0,822 # ffffffffc0208850 <default_pmm_manager+0x1308>
ffffffffc0205522:	f63fa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205526:	00002617          	auipc	a2,0x2
ffffffffc020552a:	0d260613          	addi	a2,a2,210 # ffffffffc02075f8 <default_pmm_manager+0xb0>
ffffffffc020552e:	06200593          	li	a1,98
ffffffffc0205532:	00002517          	auipc	a0,0x2
ffffffffc0205536:	08e50513          	addi	a0,a0,142 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc020553a:	f4bfa0ef          	jal	ra,ffffffffc0200484 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020553e:	00002617          	auipc	a2,0x2
ffffffffc0205542:	09260613          	addi	a2,a2,146 # ffffffffc02075d0 <default_pmm_manager+0x88>
ffffffffc0205546:	06e00593          	li	a1,110
ffffffffc020554a:	00002517          	auipc	a0,0x2
ffffffffc020554e:	07650513          	addi	a0,a0,118 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0205552:	f33fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205556 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205556:	7129                	addi	sp,sp,-320
ffffffffc0205558:	fa22                	sd	s0,304(sp)
ffffffffc020555a:	f626                	sd	s1,296(sp)
ffffffffc020555c:	f24a                	sd	s2,288(sp)
ffffffffc020555e:	84ae                	mv	s1,a1
ffffffffc0205560:	892a                	mv	s2,a0
ffffffffc0205562:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205564:	4581                	li	a1,0
ffffffffc0205566:	12000613          	li	a2,288
ffffffffc020556a:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020556c:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020556e:	25e010ef          	jal	ra,ffffffffc02067cc <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0205572:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0205574:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0205576:	100027f3          	csrr	a5,sstatus
ffffffffc020557a:	edd7f793          	andi	a5,a5,-291
ffffffffc020557e:	1207e793          	ori	a5,a5,288
ffffffffc0205582:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205584:	860a                	mv	a2,sp
ffffffffc0205586:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020558a:	00000797          	auipc	a5,0x0
ffffffffc020558e:	8e678793          	addi	a5,a5,-1818 # ffffffffc0204e70 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205592:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205594:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205596:	be5ff0ef          	jal	ra,ffffffffc020517a <do_fork>
}
ffffffffc020559a:	70f2                	ld	ra,312(sp)
ffffffffc020559c:	7452                	ld	s0,304(sp)
ffffffffc020559e:	74b2                	ld	s1,296(sp)
ffffffffc02055a0:	7912                	ld	s2,288(sp)
ffffffffc02055a2:	6131                	addi	sp,sp,320
ffffffffc02055a4:	8082                	ret

ffffffffc02055a6 <do_exit>:
do_exit(int error_code) {
ffffffffc02055a6:	7179                	addi	sp,sp,-48
ffffffffc02055a8:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc02055aa:	000a7717          	auipc	a4,0xa7
ffffffffc02055ae:	f8e70713          	addi	a4,a4,-114 # ffffffffc02ac538 <idleproc>
ffffffffc02055b2:	000a7917          	auipc	s2,0xa7
ffffffffc02055b6:	f7e90913          	addi	s2,s2,-130 # ffffffffc02ac530 <current>
ffffffffc02055ba:	00093783          	ld	a5,0(s2)
ffffffffc02055be:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc02055c0:	f406                	sd	ra,40(sp)
ffffffffc02055c2:	f022                	sd	s0,32(sp)
ffffffffc02055c4:	ec26                	sd	s1,24(sp)
ffffffffc02055c6:	e44e                	sd	s3,8(sp)
ffffffffc02055c8:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc02055ca:	0ce78c63          	beq	a5,a4,ffffffffc02056a2 <do_exit+0xfc>
    if (current == initproc) {
ffffffffc02055ce:	000a7417          	auipc	s0,0xa7
ffffffffc02055d2:	f7240413          	addi	s0,s0,-142 # ffffffffc02ac540 <initproc>
ffffffffc02055d6:	6018                	ld	a4,0(s0)
ffffffffc02055d8:	0ee78b63          	beq	a5,a4,ffffffffc02056ce <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc02055dc:	7784                	ld	s1,40(a5)
ffffffffc02055de:	89aa                	mv	s3,a0
    if (mm != NULL) {
ffffffffc02055e0:	c48d                	beqz	s1,ffffffffc020560a <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc02055e2:	000a7797          	auipc	a5,0xa7
ffffffffc02055e6:	f9e78793          	addi	a5,a5,-98 # ffffffffc02ac580 <boot_cr3>
ffffffffc02055ea:	639c                	ld	a5,0(a5)
ffffffffc02055ec:	577d                	li	a4,-1
ffffffffc02055ee:	177e                	slli	a4,a4,0x3f
ffffffffc02055f0:	83b1                	srli	a5,a5,0xc
ffffffffc02055f2:	8fd9                	or	a5,a5,a4
ffffffffc02055f4:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02055f8:	589c                	lw	a5,48(s1)
ffffffffc02055fa:	fff7871b          	addiw	a4,a5,-1
ffffffffc02055fe:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205600:	cf4d                	beqz	a4,ffffffffc02056ba <do_exit+0x114>
        current->mm = NULL;
ffffffffc0205602:	00093783          	ld	a5,0(s2)
ffffffffc0205606:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc020560a:	00093783          	ld	a5,0(s2)
ffffffffc020560e:	470d                	li	a4,3
ffffffffc0205610:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0205612:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205616:	100027f3          	csrr	a5,sstatus
ffffffffc020561a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020561c:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020561e:	e7e1                	bnez	a5,ffffffffc02056e6 <do_exit+0x140>
        proc = current->parent;
ffffffffc0205620:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205624:	800007b7          	lui	a5,0x80000
ffffffffc0205628:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc020562a:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc020562c:	0ec52703          	lw	a4,236(a0)
ffffffffc0205630:	0af70f63          	beq	a4,a5,ffffffffc02056ee <do_exit+0x148>
ffffffffc0205634:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205638:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020563c:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020563e:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) {
ffffffffc0205640:	7afc                	ld	a5,240(a3)
ffffffffc0205642:	cb95                	beqz	a5,ffffffffc0205676 <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc0205644:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff5678>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205648:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc020564a:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020564c:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc020564e:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205652:	10e7b023          	sd	a4,256(a5)
ffffffffc0205656:	c311                	beqz	a4,ffffffffc020565a <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc0205658:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020565a:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc020565c:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc020565e:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205660:	fe9710e3          	bne	a4,s1,ffffffffc0205640 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205664:	0ec52783          	lw	a5,236(a0)
ffffffffc0205668:	fd379ce3          	bne	a5,s3,ffffffffc0205640 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc020566c:	2c1000ef          	jal	ra,ffffffffc020612c <wakeup_proc>
ffffffffc0205670:	00093683          	ld	a3,0(s2)
ffffffffc0205674:	b7f1                	j	ffffffffc0205640 <do_exit+0x9a>
    if (flag) {
ffffffffc0205676:	020a1363          	bnez	s4,ffffffffc020569c <do_exit+0xf6>
    schedule();
ffffffffc020567a:	32f000ef          	jal	ra,ffffffffc02061a8 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc020567e:	00093783          	ld	a5,0(s2)
ffffffffc0205682:	00003617          	auipc	a2,0x3
ffffffffc0205686:	17e60613          	addi	a2,a2,382 # ffffffffc0208800 <default_pmm_manager+0x12b8>
ffffffffc020568a:	21000593          	li	a1,528
ffffffffc020568e:	43d4                	lw	a3,4(a5)
ffffffffc0205690:	00003517          	auipc	a0,0x3
ffffffffc0205694:	42050513          	addi	a0,a0,1056 # ffffffffc0208ab0 <default_pmm_manager+0x1568>
ffffffffc0205698:	dedfa0ef          	jal	ra,ffffffffc0200484 <__panic>
        intr_enable();
ffffffffc020569c:	fb9fa0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc02056a0:	bfe9                	j	ffffffffc020567a <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc02056a2:	00003617          	auipc	a2,0x3
ffffffffc02056a6:	13e60613          	addi	a2,a2,318 # ffffffffc02087e0 <default_pmm_manager+0x1298>
ffffffffc02056aa:	1e400593          	li	a1,484
ffffffffc02056ae:	00003517          	auipc	a0,0x3
ffffffffc02056b2:	40250513          	addi	a0,a0,1026 # ffffffffc0208ab0 <default_pmm_manager+0x1568>
ffffffffc02056b6:	dcffa0ef          	jal	ra,ffffffffc0200484 <__panic>
            exit_mmap(mm);
ffffffffc02056ba:	8526                	mv	a0,s1
ffffffffc02056bc:	df3fe0ef          	jal	ra,ffffffffc02044ae <exit_mmap>
            put_pgdir(mm);
ffffffffc02056c0:	8526                	mv	a0,s1
ffffffffc02056c2:	8bdff0ef          	jal	ra,ffffffffc0204f7e <put_pgdir>
            mm_destroy(mm);
ffffffffc02056c6:	8526                	mv	a0,s1
ffffffffc02056c8:	c47fe0ef          	jal	ra,ffffffffc020430e <mm_destroy>
ffffffffc02056cc:	bf1d                	j	ffffffffc0205602 <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc02056ce:	00003617          	auipc	a2,0x3
ffffffffc02056d2:	12260613          	addi	a2,a2,290 # ffffffffc02087f0 <default_pmm_manager+0x12a8>
ffffffffc02056d6:	1e700593          	li	a1,487
ffffffffc02056da:	00003517          	auipc	a0,0x3
ffffffffc02056de:	3d650513          	addi	a0,a0,982 # ffffffffc0208ab0 <default_pmm_manager+0x1568>
ffffffffc02056e2:	da3fa0ef          	jal	ra,ffffffffc0200484 <__panic>
        intr_disable();
ffffffffc02056e6:	f75fa0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc02056ea:	4a05                	li	s4,1
ffffffffc02056ec:	bf15                	j	ffffffffc0205620 <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc02056ee:	23f000ef          	jal	ra,ffffffffc020612c <wakeup_proc>
ffffffffc02056f2:	b789                	j	ffffffffc0205634 <do_exit+0x8e>

ffffffffc02056f4 <do_wait.part.1>:
do_wait(int pid, int *code_store) {
ffffffffc02056f4:	7139                	addi	sp,sp,-64
ffffffffc02056f6:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc02056f8:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc02056fc:	f426                	sd	s1,40(sp)
ffffffffc02056fe:	f04a                	sd	s2,32(sp)
ffffffffc0205700:	ec4e                	sd	s3,24(sp)
ffffffffc0205702:	e456                	sd	s5,8(sp)
ffffffffc0205704:	e05a                	sd	s6,0(sp)
ffffffffc0205706:	fc06                	sd	ra,56(sp)
ffffffffc0205708:	f822                	sd	s0,48(sp)
ffffffffc020570a:	89aa                	mv	s3,a0
ffffffffc020570c:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc020570e:	000a7917          	auipc	s2,0xa7
ffffffffc0205712:	e2290913          	addi	s2,s2,-478 # ffffffffc02ac530 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205716:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc0205718:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc020571a:	2a05                	addiw	s4,s4,1
    if (pid != 0) {
ffffffffc020571c:	02098f63          	beqz	s3,ffffffffc020575a <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc0205720:	854e                	mv	a0,s3
ffffffffc0205722:	9fdff0ef          	jal	ra,ffffffffc020511e <find_proc>
ffffffffc0205726:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc0205728:	12050063          	beqz	a0,ffffffffc0205848 <do_wait.part.1+0x154>
ffffffffc020572c:	00093703          	ld	a4,0(s2)
ffffffffc0205730:	711c                	ld	a5,32(a0)
ffffffffc0205732:	10e79b63          	bne	a5,a4,ffffffffc0205848 <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205736:	411c                	lw	a5,0(a0)
ffffffffc0205738:	02978c63          	beq	a5,s1,ffffffffc0205770 <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc020573c:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc0205740:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc0205744:	265000ef          	jal	ra,ffffffffc02061a8 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc0205748:	00093783          	ld	a5,0(s2)
ffffffffc020574c:	0b07a783          	lw	a5,176(a5)
ffffffffc0205750:	8b85                	andi	a5,a5,1
ffffffffc0205752:	d7e9                	beqz	a5,ffffffffc020571c <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc0205754:	555d                	li	a0,-9
ffffffffc0205756:	e51ff0ef          	jal	ra,ffffffffc02055a6 <do_exit>
        proc = current->cptr;
ffffffffc020575a:	00093703          	ld	a4,0(s2)
ffffffffc020575e:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205760:	e409                	bnez	s0,ffffffffc020576a <do_wait.part.1+0x76>
ffffffffc0205762:	a0dd                	j	ffffffffc0205848 <do_wait.part.1+0x154>
ffffffffc0205764:	10043403          	ld	s0,256(s0)
ffffffffc0205768:	d871                	beqz	s0,ffffffffc020573c <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020576a:	401c                	lw	a5,0(s0)
ffffffffc020576c:	fe979ce3          	bne	a5,s1,ffffffffc0205764 <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc0205770:	000a7797          	auipc	a5,0xa7
ffffffffc0205774:	dc878793          	addi	a5,a5,-568 # ffffffffc02ac538 <idleproc>
ffffffffc0205778:	639c                	ld	a5,0(a5)
ffffffffc020577a:	0c878d63          	beq	a5,s0,ffffffffc0205854 <do_wait.part.1+0x160>
ffffffffc020577e:	000a7797          	auipc	a5,0xa7
ffffffffc0205782:	dc278793          	addi	a5,a5,-574 # ffffffffc02ac540 <initproc>
ffffffffc0205786:	639c                	ld	a5,0(a5)
ffffffffc0205788:	0cf40663          	beq	s0,a5,ffffffffc0205854 <do_wait.part.1+0x160>
    if (code_store != NULL) {
ffffffffc020578c:	000b0663          	beqz	s6,ffffffffc0205798 <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc0205790:	0e842783          	lw	a5,232(s0)
ffffffffc0205794:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205798:	100027f3          	csrr	a5,sstatus
ffffffffc020579c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020579e:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02057a0:	e7d5                	bnez	a5,ffffffffc020584c <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc02057a2:	6c70                	ld	a2,216(s0)
ffffffffc02057a4:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc02057a6:	10043703          	ld	a4,256(s0)
ffffffffc02057aa:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02057ac:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02057ae:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02057b0:	6470                	ld	a2,200(s0)
ffffffffc02057b2:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc02057b4:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02057b6:	e290                	sd	a2,0(a3)
ffffffffc02057b8:	c319                	beqz	a4,ffffffffc02057be <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc02057ba:	ff7c                	sd	a5,248(a4)
ffffffffc02057bc:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc02057be:	c3d1                	beqz	a5,ffffffffc0205842 <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc02057c0:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc02057c4:	000a7797          	auipc	a5,0xa7
ffffffffc02057c8:	d8478793          	addi	a5,a5,-636 # ffffffffc02ac548 <nr_process>
ffffffffc02057cc:	439c                	lw	a5,0(a5)
ffffffffc02057ce:	37fd                	addiw	a5,a5,-1
ffffffffc02057d0:	000a7717          	auipc	a4,0xa7
ffffffffc02057d4:	d6f72c23          	sw	a5,-648(a4) # ffffffffc02ac548 <nr_process>
    if (flag) {
ffffffffc02057d8:	e1b5                	bnez	a1,ffffffffc020583c <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02057da:	6814                	ld	a3,16(s0)
ffffffffc02057dc:	c02007b7          	lui	a5,0xc0200
ffffffffc02057e0:	0af6e263          	bltu	a3,a5,ffffffffc0205884 <do_wait.part.1+0x190>
ffffffffc02057e4:	000a7797          	auipc	a5,0xa7
ffffffffc02057e8:	d9478793          	addi	a5,a5,-620 # ffffffffc02ac578 <va_pa_offset>
ffffffffc02057ec:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02057ee:	000a7797          	auipc	a5,0xa7
ffffffffc02057f2:	d2a78793          	addi	a5,a5,-726 # ffffffffc02ac518 <npage>
ffffffffc02057f6:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc02057f8:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc02057fa:	82b1                	srli	a3,a3,0xc
ffffffffc02057fc:	06f6f863          	bleu	a5,a3,ffffffffc020586c <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc0205800:	00003797          	auipc	a5,0x3
ffffffffc0205804:	77878793          	addi	a5,a5,1912 # ffffffffc0208f78 <nbase>
ffffffffc0205808:	639c                	ld	a5,0(a5)
ffffffffc020580a:	000a7717          	auipc	a4,0xa7
ffffffffc020580e:	d7e70713          	addi	a4,a4,-642 # ffffffffc02ac588 <pages>
ffffffffc0205812:	6308                	ld	a0,0(a4)
ffffffffc0205814:	8e9d                	sub	a3,a3,a5
ffffffffc0205816:	069a                	slli	a3,a3,0x6
ffffffffc0205818:	9536                	add	a0,a0,a3
ffffffffc020581a:	4589                	li	a1,2
ffffffffc020581c:	ef6fc0ef          	jal	ra,ffffffffc0201f12 <free_pages>
    kfree(proc);
ffffffffc0205820:	8522                	mv	a0,s0
ffffffffc0205822:	d28fc0ef          	jal	ra,ffffffffc0201d4a <kfree>
    return 0;
ffffffffc0205826:	4501                	li	a0,0
}
ffffffffc0205828:	70e2                	ld	ra,56(sp)
ffffffffc020582a:	7442                	ld	s0,48(sp)
ffffffffc020582c:	74a2                	ld	s1,40(sp)
ffffffffc020582e:	7902                	ld	s2,32(sp)
ffffffffc0205830:	69e2                	ld	s3,24(sp)
ffffffffc0205832:	6a42                	ld	s4,16(sp)
ffffffffc0205834:	6aa2                	ld	s5,8(sp)
ffffffffc0205836:	6b02                	ld	s6,0(sp)
ffffffffc0205838:	6121                	addi	sp,sp,64
ffffffffc020583a:	8082                	ret
        intr_enable();
ffffffffc020583c:	e19fa0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0205840:	bf69                	j	ffffffffc02057da <do_wait.part.1+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc0205842:	701c                	ld	a5,32(s0)
ffffffffc0205844:	fbf8                	sd	a4,240(a5)
ffffffffc0205846:	bfbd                	j	ffffffffc02057c4 <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc0205848:	5579                	li	a0,-2
ffffffffc020584a:	bff9                	j	ffffffffc0205828 <do_wait.part.1+0x134>
        intr_disable();
ffffffffc020584c:	e0ffa0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc0205850:	4585                	li	a1,1
ffffffffc0205852:	bf81                	j	ffffffffc02057a2 <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc0205854:	00003617          	auipc	a2,0x3
ffffffffc0205858:	01460613          	addi	a2,a2,20 # ffffffffc0208868 <default_pmm_manager+0x1320>
ffffffffc020585c:	30700593          	li	a1,775
ffffffffc0205860:	00003517          	auipc	a0,0x3
ffffffffc0205864:	25050513          	addi	a0,a0,592 # ffffffffc0208ab0 <default_pmm_manager+0x1568>
ffffffffc0205868:	c1dfa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020586c:	00002617          	auipc	a2,0x2
ffffffffc0205870:	d8c60613          	addi	a2,a2,-628 # ffffffffc02075f8 <default_pmm_manager+0xb0>
ffffffffc0205874:	06200593          	li	a1,98
ffffffffc0205878:	00002517          	auipc	a0,0x2
ffffffffc020587c:	d4850513          	addi	a0,a0,-696 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0205880:	c05fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205884:	00002617          	auipc	a2,0x2
ffffffffc0205888:	d4c60613          	addi	a2,a2,-692 # ffffffffc02075d0 <default_pmm_manager+0x88>
ffffffffc020588c:	06e00593          	li	a1,110
ffffffffc0205890:	00002517          	auipc	a0,0x2
ffffffffc0205894:	d3050513          	addi	a0,a0,-720 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0205898:	bedfa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020589c <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc020589c:	1141                	addi	sp,sp,-16
ffffffffc020589e:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02058a0:	eb8fc0ef          	jal	ra,ffffffffc0201f58 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02058a4:	be6fc0ef          	jal	ra,ffffffffc0201c8a <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02058a8:	4601                	li	a2,0
ffffffffc02058aa:	4581                	li	a1,0
ffffffffc02058ac:	fffff517          	auipc	a0,0xfffff
ffffffffc02058b0:	65050513          	addi	a0,a0,1616 # ffffffffc0204efc <user_main>
ffffffffc02058b4:	ca3ff0ef          	jal	ra,ffffffffc0205556 <kernel_thread>
    if (pid <= 0) {
ffffffffc02058b8:	00a04563          	bgtz	a0,ffffffffc02058c2 <init_main+0x26>
ffffffffc02058bc:	a841                	j	ffffffffc020594c <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc02058be:	0eb000ef          	jal	ra,ffffffffc02061a8 <schedule>
    if (code_store != NULL) {
ffffffffc02058c2:	4581                	li	a1,0
ffffffffc02058c4:	4501                	li	a0,0
ffffffffc02058c6:	e2fff0ef          	jal	ra,ffffffffc02056f4 <do_wait.part.1>
    while (do_wait(0, NULL) == 0) {
ffffffffc02058ca:	d975                	beqz	a0,ffffffffc02058be <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc02058cc:	00003517          	auipc	a0,0x3
ffffffffc02058d0:	fdc50513          	addi	a0,a0,-36 # ffffffffc02088a8 <default_pmm_manager+0x1360>
ffffffffc02058d4:	8bbfa0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02058d8:	000a7797          	auipc	a5,0xa7
ffffffffc02058dc:	c6878793          	addi	a5,a5,-920 # ffffffffc02ac540 <initproc>
ffffffffc02058e0:	639c                	ld	a5,0(a5)
ffffffffc02058e2:	7bf8                	ld	a4,240(a5)
ffffffffc02058e4:	e721                	bnez	a4,ffffffffc020592c <init_main+0x90>
ffffffffc02058e6:	7ff8                	ld	a4,248(a5)
ffffffffc02058e8:	e331                	bnez	a4,ffffffffc020592c <init_main+0x90>
ffffffffc02058ea:	1007b703          	ld	a4,256(a5)
ffffffffc02058ee:	ef1d                	bnez	a4,ffffffffc020592c <init_main+0x90>
    assert(nr_process == 2);
ffffffffc02058f0:	000a7717          	auipc	a4,0xa7
ffffffffc02058f4:	c5870713          	addi	a4,a4,-936 # ffffffffc02ac548 <nr_process>
ffffffffc02058f8:	4314                	lw	a3,0(a4)
ffffffffc02058fa:	4709                	li	a4,2
ffffffffc02058fc:	0ae69463          	bne	a3,a4,ffffffffc02059a4 <init_main+0x108>
    return listelm->next;
ffffffffc0205900:	000a7697          	auipc	a3,0xa7
ffffffffc0205904:	d7068693          	addi	a3,a3,-656 # ffffffffc02ac670 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205908:	6698                	ld	a4,8(a3)
ffffffffc020590a:	0c878793          	addi	a5,a5,200
ffffffffc020590e:	06f71b63          	bne	a4,a5,ffffffffc0205984 <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205912:	629c                	ld	a5,0(a3)
ffffffffc0205914:	04f71863          	bne	a4,a5,ffffffffc0205964 <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc0205918:	00003517          	auipc	a0,0x3
ffffffffc020591c:	07850513          	addi	a0,a0,120 # ffffffffc0208990 <default_pmm_manager+0x1448>
ffffffffc0205920:	86ffa0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
}
ffffffffc0205924:	60a2                	ld	ra,8(sp)
ffffffffc0205926:	4501                	li	a0,0
ffffffffc0205928:	0141                	addi	sp,sp,16
ffffffffc020592a:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020592c:	00003697          	auipc	a3,0x3
ffffffffc0205930:	fa468693          	addi	a3,a3,-92 # ffffffffc02088d0 <default_pmm_manager+0x1388>
ffffffffc0205934:	00001617          	auipc	a2,0x1
ffffffffc0205938:	4cc60613          	addi	a2,a2,1228 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020593c:	36c00593          	li	a1,876
ffffffffc0205940:	00003517          	auipc	a0,0x3
ffffffffc0205944:	17050513          	addi	a0,a0,368 # ffffffffc0208ab0 <default_pmm_manager+0x1568>
ffffffffc0205948:	b3dfa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("create user_main failed.\n");
ffffffffc020594c:	00003617          	auipc	a2,0x3
ffffffffc0205950:	f3c60613          	addi	a2,a2,-196 # ffffffffc0208888 <default_pmm_manager+0x1340>
ffffffffc0205954:	36400593          	li	a1,868
ffffffffc0205958:	00003517          	auipc	a0,0x3
ffffffffc020595c:	15850513          	addi	a0,a0,344 # ffffffffc0208ab0 <default_pmm_manager+0x1568>
ffffffffc0205960:	b25fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205964:	00003697          	auipc	a3,0x3
ffffffffc0205968:	ffc68693          	addi	a3,a3,-4 # ffffffffc0208960 <default_pmm_manager+0x1418>
ffffffffc020596c:	00001617          	auipc	a2,0x1
ffffffffc0205970:	49460613          	addi	a2,a2,1172 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0205974:	36f00593          	li	a1,879
ffffffffc0205978:	00003517          	auipc	a0,0x3
ffffffffc020597c:	13850513          	addi	a0,a0,312 # ffffffffc0208ab0 <default_pmm_manager+0x1568>
ffffffffc0205980:	b05fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205984:	00003697          	auipc	a3,0x3
ffffffffc0205988:	fac68693          	addi	a3,a3,-84 # ffffffffc0208930 <default_pmm_manager+0x13e8>
ffffffffc020598c:	00001617          	auipc	a2,0x1
ffffffffc0205990:	47460613          	addi	a2,a2,1140 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0205994:	36e00593          	li	a1,878
ffffffffc0205998:	00003517          	auipc	a0,0x3
ffffffffc020599c:	11850513          	addi	a0,a0,280 # ffffffffc0208ab0 <default_pmm_manager+0x1568>
ffffffffc02059a0:	ae5fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_process == 2);
ffffffffc02059a4:	00003697          	auipc	a3,0x3
ffffffffc02059a8:	f7c68693          	addi	a3,a3,-132 # ffffffffc0208920 <default_pmm_manager+0x13d8>
ffffffffc02059ac:	00001617          	auipc	a2,0x1
ffffffffc02059b0:	45460613          	addi	a2,a2,1108 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc02059b4:	36d00593          	li	a1,877
ffffffffc02059b8:	00003517          	auipc	a0,0x3
ffffffffc02059bc:	0f850513          	addi	a0,a0,248 # ffffffffc0208ab0 <default_pmm_manager+0x1568>
ffffffffc02059c0:	ac5fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02059c4 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02059c4:	7135                	addi	sp,sp,-160
ffffffffc02059c6:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02059c8:	000a7a17          	auipc	s4,0xa7
ffffffffc02059cc:	b68a0a13          	addi	s4,s4,-1176 # ffffffffc02ac530 <current>
ffffffffc02059d0:	000a3783          	ld	a5,0(s4)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02059d4:	e14a                	sd	s2,128(sp)
ffffffffc02059d6:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02059d8:	0287b903          	ld	s2,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02059dc:	fcce                	sd	s3,120(sp)
ffffffffc02059de:	f0da                	sd	s6,96(sp)
ffffffffc02059e0:	89aa                	mv	s3,a0
ffffffffc02059e2:	842e                	mv	s0,a1
ffffffffc02059e4:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02059e6:	4681                	li	a3,0
ffffffffc02059e8:	862e                	mv	a2,a1
ffffffffc02059ea:	85aa                	mv	a1,a0
ffffffffc02059ec:	854a                	mv	a0,s2
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02059ee:	ed06                	sd	ra,152(sp)
ffffffffc02059f0:	e526                	sd	s1,136(sp)
ffffffffc02059f2:	f4d6                	sd	s5,104(sp)
ffffffffc02059f4:	ecde                	sd	s7,88(sp)
ffffffffc02059f6:	e8e2                	sd	s8,80(sp)
ffffffffc02059f8:	e4e6                	sd	s9,72(sp)
ffffffffc02059fa:	e0ea                	sd	s10,64(sp)
ffffffffc02059fc:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02059fe:	a76ff0ef          	jal	ra,ffffffffc0204c74 <user_mem_check>
ffffffffc0205a02:	40050463          	beqz	a0,ffffffffc0205e0a <do_execve+0x446>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0205a06:	4641                	li	a2,16
ffffffffc0205a08:	4581                	li	a1,0
ffffffffc0205a0a:	1008                	addi	a0,sp,32
ffffffffc0205a0c:	5c1000ef          	jal	ra,ffffffffc02067cc <memset>
    memcpy(local_name, name, len);
ffffffffc0205a10:	47bd                	li	a5,15
ffffffffc0205a12:	8622                	mv	a2,s0
ffffffffc0205a14:	0687ee63          	bltu	a5,s0,ffffffffc0205a90 <do_execve+0xcc>
ffffffffc0205a18:	85ce                	mv	a1,s3
ffffffffc0205a1a:	1008                	addi	a0,sp,32
ffffffffc0205a1c:	5c3000ef          	jal	ra,ffffffffc02067de <memcpy>
    if (mm != NULL) {
ffffffffc0205a20:	06090f63          	beqz	s2,ffffffffc0205a9e <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc0205a24:	00002517          	auipc	a0,0x2
ffffffffc0205a28:	36450513          	addi	a0,a0,868 # ffffffffc0207d88 <default_pmm_manager+0x840>
ffffffffc0205a2c:	f9afa0ef          	jal	ra,ffffffffc02001c6 <cputs>
        lcr3(boot_cr3);
ffffffffc0205a30:	000a7797          	auipc	a5,0xa7
ffffffffc0205a34:	b5078793          	addi	a5,a5,-1200 # ffffffffc02ac580 <boot_cr3>
ffffffffc0205a38:	639c                	ld	a5,0(a5)
ffffffffc0205a3a:	577d                	li	a4,-1
ffffffffc0205a3c:	177e                	slli	a4,a4,0x3f
ffffffffc0205a3e:	83b1                	srli	a5,a5,0xc
ffffffffc0205a40:	8fd9                	or	a5,a5,a4
ffffffffc0205a42:	18079073          	csrw	satp,a5
ffffffffc0205a46:	03092783          	lw	a5,48(s2)
ffffffffc0205a4a:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205a4e:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205a52:	28070b63          	beqz	a4,ffffffffc0205ce8 <do_execve+0x324>
        current->mm = NULL;
ffffffffc0205a56:	000a3783          	ld	a5,0(s4)
ffffffffc0205a5a:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc0205a5e:	f2afe0ef          	jal	ra,ffffffffc0204188 <mm_create>
ffffffffc0205a62:	892a                	mv	s2,a0
ffffffffc0205a64:	c135                	beqz	a0,ffffffffc0205ac8 <do_execve+0x104>
    if (setup_pgdir(mm) != 0) {
ffffffffc0205a66:	d96ff0ef          	jal	ra,ffffffffc0204ffc <setup_pgdir>
ffffffffc0205a6a:	e931                	bnez	a0,ffffffffc0205abe <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205a6c:	000b2703          	lw	a4,0(s6)
ffffffffc0205a70:	464c47b7          	lui	a5,0x464c4
ffffffffc0205a74:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9af7>
ffffffffc0205a78:	04f70a63          	beq	a4,a5,ffffffffc0205acc <do_execve+0x108>
    put_pgdir(mm);
ffffffffc0205a7c:	854a                	mv	a0,s2
ffffffffc0205a7e:	d00ff0ef          	jal	ra,ffffffffc0204f7e <put_pgdir>
    mm_destroy(mm);
ffffffffc0205a82:	854a                	mv	a0,s2
ffffffffc0205a84:	88bfe0ef          	jal	ra,ffffffffc020430e <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0205a88:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc0205a8a:	854e                	mv	a0,s3
ffffffffc0205a8c:	b1bff0ef          	jal	ra,ffffffffc02055a6 <do_exit>
    memcpy(local_name, name, len);
ffffffffc0205a90:	463d                	li	a2,15
ffffffffc0205a92:	85ce                	mv	a1,s3
ffffffffc0205a94:	1008                	addi	a0,sp,32
ffffffffc0205a96:	549000ef          	jal	ra,ffffffffc02067de <memcpy>
    if (mm != NULL) {
ffffffffc0205a9a:	f80915e3          	bnez	s2,ffffffffc0205a24 <do_execve+0x60>
    if (current->mm != NULL) {
ffffffffc0205a9e:	000a3783          	ld	a5,0(s4)
ffffffffc0205aa2:	779c                	ld	a5,40(a5)
ffffffffc0205aa4:	dfcd                	beqz	a5,ffffffffc0205a5e <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205aa6:	00003617          	auipc	a2,0x3
ffffffffc0205aaa:	bb260613          	addi	a2,a2,-1102 # ffffffffc0208658 <default_pmm_manager+0x1110>
ffffffffc0205aae:	21a00593          	li	a1,538
ffffffffc0205ab2:	00003517          	auipc	a0,0x3
ffffffffc0205ab6:	ffe50513          	addi	a0,a0,-2 # ffffffffc0208ab0 <default_pmm_manager+0x1568>
ffffffffc0205aba:	9cbfa0ef          	jal	ra,ffffffffc0200484 <__panic>
    mm_destroy(mm);
ffffffffc0205abe:	854a                	mv	a0,s2
ffffffffc0205ac0:	84ffe0ef          	jal	ra,ffffffffc020430e <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0205ac4:	59f1                	li	s3,-4
ffffffffc0205ac6:	b7d1                	j	ffffffffc0205a8a <do_execve+0xc6>
ffffffffc0205ac8:	59f1                	li	s3,-4
ffffffffc0205aca:	b7c1                	j	ffffffffc0205a8a <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205acc:	038b5703          	lhu	a4,56(s6)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205ad0:	020b3403          	ld	s0,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205ad4:	00371793          	slli	a5,a4,0x3
ffffffffc0205ad8:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205ada:	945a                	add	s0,s0,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205adc:	078e                	slli	a5,a5,0x3
ffffffffc0205ade:	97a2                	add	a5,a5,s0
ffffffffc0205ae0:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc0205ae2:	02f47b63          	bleu	a5,s0,ffffffffc0205b18 <do_execve+0x154>
    return KADDR(page2pa(page));
ffffffffc0205ae6:	5bfd                	li	s7,-1
ffffffffc0205ae8:	00cbd793          	srli	a5,s7,0xc
    return page - pages + nbase;
ffffffffc0205aec:	000a7d97          	auipc	s11,0xa7
ffffffffc0205af0:	a9cd8d93          	addi	s11,s11,-1380 # ffffffffc02ac588 <pages>
ffffffffc0205af4:	00003d17          	auipc	s10,0x3
ffffffffc0205af8:	484d0d13          	addi	s10,s10,1156 # ffffffffc0208f78 <nbase>
    return KADDR(page2pa(page));
ffffffffc0205afc:	e43e                	sd	a5,8(sp)
ffffffffc0205afe:	000a7c97          	auipc	s9,0xa7
ffffffffc0205b02:	a1ac8c93          	addi	s9,s9,-1510 # ffffffffc02ac518 <npage>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0205b06:	4018                	lw	a4,0(s0)
ffffffffc0205b08:	4785                	li	a5,1
ffffffffc0205b0a:	0ef70d63          	beq	a4,a5,ffffffffc0205c04 <do_execve+0x240>
    for (; ph < ph_end; ph ++) {
ffffffffc0205b0e:	67e2                	ld	a5,24(sp)
ffffffffc0205b10:	03840413          	addi	s0,s0,56
ffffffffc0205b14:	fef469e3          	bltu	s0,a5,ffffffffc0205b06 <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0205b18:	4701                	li	a4,0
ffffffffc0205b1a:	46ad                	li	a3,11
ffffffffc0205b1c:	00100637          	lui	a2,0x100
ffffffffc0205b20:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205b24:	854a                	mv	a0,s2
ffffffffc0205b26:	83bfe0ef          	jal	ra,ffffffffc0204360 <mm_map>
ffffffffc0205b2a:	89aa                	mv	s3,a0
ffffffffc0205b2c:	1a051463          	bnez	a0,ffffffffc0205cd4 <do_execve+0x310>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205b30:	01893503          	ld	a0,24(s2)
ffffffffc0205b34:	467d                	li	a2,31
ffffffffc0205b36:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205b3a:	881fd0ef          	jal	ra,ffffffffc02033ba <pgdir_alloc_page>
ffffffffc0205b3e:	36050263          	beqz	a0,ffffffffc0205ea2 <do_execve+0x4de>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b42:	01893503          	ld	a0,24(s2)
ffffffffc0205b46:	467d                	li	a2,31
ffffffffc0205b48:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205b4c:	86ffd0ef          	jal	ra,ffffffffc02033ba <pgdir_alloc_page>
ffffffffc0205b50:	32050963          	beqz	a0,ffffffffc0205e82 <do_execve+0x4be>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b54:	01893503          	ld	a0,24(s2)
ffffffffc0205b58:	467d                	li	a2,31
ffffffffc0205b5a:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0205b5e:	85dfd0ef          	jal	ra,ffffffffc02033ba <pgdir_alloc_page>
ffffffffc0205b62:	30050063          	beqz	a0,ffffffffc0205e62 <do_execve+0x49e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b66:	01893503          	ld	a0,24(s2)
ffffffffc0205b6a:	467d                	li	a2,31
ffffffffc0205b6c:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205b70:	84bfd0ef          	jal	ra,ffffffffc02033ba <pgdir_alloc_page>
ffffffffc0205b74:	2c050763          	beqz	a0,ffffffffc0205e42 <do_execve+0x47e>
    mm->mm_count += 1;
ffffffffc0205b78:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc0205b7c:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205b80:	01893683          	ld	a3,24(s2)
ffffffffc0205b84:	2785                	addiw	a5,a5,1
ffffffffc0205b86:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc0205b8a:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_exit_out_size+0xf55a0>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205b8e:	c02007b7          	lui	a5,0xc0200
ffffffffc0205b92:	28f6ec63          	bltu	a3,a5,ffffffffc0205e2a <do_execve+0x466>
ffffffffc0205b96:	000a7797          	auipc	a5,0xa7
ffffffffc0205b9a:	9e278793          	addi	a5,a5,-1566 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0205b9e:	639c                	ld	a5,0(a5)
ffffffffc0205ba0:	577d                	li	a4,-1
ffffffffc0205ba2:	177e                	slli	a4,a4,0x3f
ffffffffc0205ba4:	8e9d                	sub	a3,a3,a5
ffffffffc0205ba6:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205baa:	f654                	sd	a3,168(a2)
ffffffffc0205bac:	8fd9                	or	a5,a5,a4
ffffffffc0205bae:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205bb2:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205bb4:	4581                	li	a1,0
ffffffffc0205bb6:	12000613          	li	a2,288
ffffffffc0205bba:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0205bbc:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205bc0:	40d000ef          	jal	ra,ffffffffc02067cc <memset>
    tf->epc = elf->e_entry;
ffffffffc0205bc4:	018b3703          	ld	a4,24(s6)
    tf->gpr.sp = USTACKTOP;
ffffffffc0205bc8:	4785                	li	a5,1
    set_proc_name(current, local_name);
ffffffffc0205bca:	000a3503          	ld	a0,0(s4)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0205bce:	edf4f493          	andi	s1,s1,-289
    tf->gpr.sp = USTACKTOP;
ffffffffc0205bd2:	07fe                	slli	a5,a5,0x1f
ffffffffc0205bd4:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0205bd6:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0205bda:	10943023          	sd	s1,256(s0)
    set_proc_name(current, local_name);
ffffffffc0205bde:	100c                	addi	a1,sp,32
ffffffffc0205be0:	ca8ff0ef          	jal	ra,ffffffffc0205088 <set_proc_name>
}
ffffffffc0205be4:	60ea                	ld	ra,152(sp)
ffffffffc0205be6:	644a                	ld	s0,144(sp)
ffffffffc0205be8:	854e                	mv	a0,s3
ffffffffc0205bea:	64aa                	ld	s1,136(sp)
ffffffffc0205bec:	690a                	ld	s2,128(sp)
ffffffffc0205bee:	79e6                	ld	s3,120(sp)
ffffffffc0205bf0:	7a46                	ld	s4,112(sp)
ffffffffc0205bf2:	7aa6                	ld	s5,104(sp)
ffffffffc0205bf4:	7b06                	ld	s6,96(sp)
ffffffffc0205bf6:	6be6                	ld	s7,88(sp)
ffffffffc0205bf8:	6c46                	ld	s8,80(sp)
ffffffffc0205bfa:	6ca6                	ld	s9,72(sp)
ffffffffc0205bfc:	6d06                	ld	s10,64(sp)
ffffffffc0205bfe:	7de2                	ld	s11,56(sp)
ffffffffc0205c00:	610d                	addi	sp,sp,160
ffffffffc0205c02:	8082                	ret
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205c04:	7410                	ld	a2,40(s0)
ffffffffc0205c06:	701c                	ld	a5,32(s0)
ffffffffc0205c08:	20f66363          	bltu	a2,a5,ffffffffc0205e0e <do_execve+0x44a>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205c0c:	405c                	lw	a5,4(s0)
ffffffffc0205c0e:	0017f693          	andi	a3,a5,1
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205c12:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205c16:	068a                	slli	a3,a3,0x2
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205c18:	0e071263          	bnez	a4,ffffffffc0205cfc <do_execve+0x338>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205c1c:	4745                	li	a4,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205c1e:	8b91                	andi	a5,a5,4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205c20:	e03a                	sd	a4,0(sp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205c22:	c789                	beqz	a5,ffffffffc0205c2c <do_execve+0x268>
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205c24:	47cd                	li	a5,19
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205c26:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205c2a:	e03e                	sd	a5,0(sp)
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205c2c:	0026f793          	andi	a5,a3,2
ffffffffc0205c30:	efe1                	bnez	a5,ffffffffc0205d08 <do_execve+0x344>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205c32:	0046f793          	andi	a5,a3,4
ffffffffc0205c36:	c789                	beqz	a5,ffffffffc0205c40 <do_execve+0x27c>
ffffffffc0205c38:	6782                	ld	a5,0(sp)
ffffffffc0205c3a:	0087e793          	ori	a5,a5,8
ffffffffc0205c3e:	e03e                	sd	a5,0(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205c40:	680c                	ld	a1,16(s0)
ffffffffc0205c42:	4701                	li	a4,0
ffffffffc0205c44:	854a                	mv	a0,s2
ffffffffc0205c46:	f1afe0ef          	jal	ra,ffffffffc0204360 <mm_map>
ffffffffc0205c4a:	89aa                	mv	s3,a0
ffffffffc0205c4c:	e541                	bnez	a0,ffffffffc0205cd4 <do_execve+0x310>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205c4e:	01043b83          	ld	s7,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205c52:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205c56:	00843a83          	ld	s5,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205c5a:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205c5c:	99de                	add	s3,s3,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205c5e:	9ada                	add	s5,s5,s6
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205c60:	00fbfc33          	and	s8,s7,a5
        while (start < end) {
ffffffffc0205c64:	053bef63          	bltu	s7,s3,ffffffffc0205cc2 <do_execve+0x2fe>
ffffffffc0205c68:	aa79                	j	ffffffffc0205e06 <do_execve+0x442>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205c6a:	6785                	lui	a5,0x1
ffffffffc0205c6c:	418b8533          	sub	a0,s7,s8
ffffffffc0205c70:	9c3e                	add	s8,s8,a5
ffffffffc0205c72:	417c0833          	sub	a6,s8,s7
            if (end < la) {
ffffffffc0205c76:	0189f463          	bleu	s8,s3,ffffffffc0205c7e <do_execve+0x2ba>
                size -= la - end;
ffffffffc0205c7a:	41798833          	sub	a6,s3,s7
    return page - pages + nbase;
ffffffffc0205c7e:	000db683          	ld	a3,0(s11)
ffffffffc0205c82:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205c86:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205c88:	40d486b3          	sub	a3,s1,a3
ffffffffc0205c8c:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205c8e:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205c92:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205c94:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c98:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c9a:	16c5fc63          	bleu	a2,a1,ffffffffc0205e12 <do_execve+0x44e>
ffffffffc0205c9e:	000a7797          	auipc	a5,0xa7
ffffffffc0205ca2:	8da78793          	addi	a5,a5,-1830 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0205ca6:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205caa:	85d6                	mv	a1,s5
ffffffffc0205cac:	8642                	mv	a2,a6
ffffffffc0205cae:	96c6                	add	a3,a3,a7
ffffffffc0205cb0:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205cb2:	9bc2                	add	s7,s7,a6
ffffffffc0205cb4:	e842                	sd	a6,16(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205cb6:	329000ef          	jal	ra,ffffffffc02067de <memcpy>
            start += size, from += size;
ffffffffc0205cba:	6842                	ld	a6,16(sp)
ffffffffc0205cbc:	9ac2                	add	s5,s5,a6
        while (start < end) {
ffffffffc0205cbe:	053bf863          	bleu	s3,s7,ffffffffc0205d0e <do_execve+0x34a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205cc2:	01893503          	ld	a0,24(s2)
ffffffffc0205cc6:	6602                	ld	a2,0(sp)
ffffffffc0205cc8:	85e2                	mv	a1,s8
ffffffffc0205cca:	ef0fd0ef          	jal	ra,ffffffffc02033ba <pgdir_alloc_page>
ffffffffc0205cce:	84aa                	mv	s1,a0
ffffffffc0205cd0:	fd49                	bnez	a0,ffffffffc0205c6a <do_execve+0x2a6>
        ret = -E_NO_MEM;
ffffffffc0205cd2:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc0205cd4:	854a                	mv	a0,s2
ffffffffc0205cd6:	fd8fe0ef          	jal	ra,ffffffffc02044ae <exit_mmap>
    put_pgdir(mm);
ffffffffc0205cda:	854a                	mv	a0,s2
ffffffffc0205cdc:	aa2ff0ef          	jal	ra,ffffffffc0204f7e <put_pgdir>
    mm_destroy(mm);
ffffffffc0205ce0:	854a                	mv	a0,s2
ffffffffc0205ce2:	e2cfe0ef          	jal	ra,ffffffffc020430e <mm_destroy>
    return ret;
ffffffffc0205ce6:	b355                	j	ffffffffc0205a8a <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0205ce8:	854a                	mv	a0,s2
ffffffffc0205cea:	fc4fe0ef          	jal	ra,ffffffffc02044ae <exit_mmap>
            put_pgdir(mm);
ffffffffc0205cee:	854a                	mv	a0,s2
ffffffffc0205cf0:	a8eff0ef          	jal	ra,ffffffffc0204f7e <put_pgdir>
            mm_destroy(mm);
ffffffffc0205cf4:	854a                	mv	a0,s2
ffffffffc0205cf6:	e18fe0ef          	jal	ra,ffffffffc020430e <mm_destroy>
ffffffffc0205cfa:	bbb1                	j	ffffffffc0205a56 <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205cfc:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205d00:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205d02:	2681                	sext.w	a3,a3
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205d04:	f20790e3          	bnez	a5,ffffffffc0205c24 <do_execve+0x260>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205d08:	47dd                	li	a5,23
ffffffffc0205d0a:	e03e                	sd	a5,0(sp)
ffffffffc0205d0c:	b71d                	j	ffffffffc0205c32 <do_execve+0x26e>
ffffffffc0205d0e:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc0205d12:	7414                	ld	a3,40(s0)
ffffffffc0205d14:	99b6                	add	s3,s3,a3
        if (start < la) {
ffffffffc0205d16:	098bf163          	bleu	s8,s7,ffffffffc0205d98 <do_execve+0x3d4>
            if (start == end) {
ffffffffc0205d1a:	df798ae3          	beq	s3,s7,ffffffffc0205b0e <do_execve+0x14a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205d1e:	6505                	lui	a0,0x1
ffffffffc0205d20:	955e                	add	a0,a0,s7
ffffffffc0205d22:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0205d26:	41798ab3          	sub	s5,s3,s7
            if (end < la) {
ffffffffc0205d2a:	0d89fb63          	bleu	s8,s3,ffffffffc0205e00 <do_execve+0x43c>
    return page - pages + nbase;
ffffffffc0205d2e:	000db683          	ld	a3,0(s11)
ffffffffc0205d32:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205d36:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205d38:	40d486b3          	sub	a3,s1,a3
ffffffffc0205d3c:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205d3e:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205d42:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205d44:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205d48:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205d4a:	0cc5f463          	bleu	a2,a1,ffffffffc0205e12 <do_execve+0x44e>
ffffffffc0205d4e:	000a7617          	auipc	a2,0xa7
ffffffffc0205d52:	82a60613          	addi	a2,a2,-2006 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0205d56:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205d5a:	4581                	li	a1,0
ffffffffc0205d5c:	8656                	mv	a2,s5
ffffffffc0205d5e:	96c2                	add	a3,a3,a6
ffffffffc0205d60:	9536                	add	a0,a0,a3
ffffffffc0205d62:	26b000ef          	jal	ra,ffffffffc02067cc <memset>
            start += size;
ffffffffc0205d66:	017a8733          	add	a4,s5,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205d6a:	0389f463          	bleu	s8,s3,ffffffffc0205d92 <do_execve+0x3ce>
ffffffffc0205d6e:	dae980e3          	beq	s3,a4,ffffffffc0205b0e <do_execve+0x14a>
ffffffffc0205d72:	00003697          	auipc	a3,0x3
ffffffffc0205d76:	90e68693          	addi	a3,a3,-1778 # ffffffffc0208680 <default_pmm_manager+0x1138>
ffffffffc0205d7a:	00001617          	auipc	a2,0x1
ffffffffc0205d7e:	08660613          	addi	a2,a2,134 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0205d82:	26f00593          	li	a1,623
ffffffffc0205d86:	00003517          	auipc	a0,0x3
ffffffffc0205d8a:	d2a50513          	addi	a0,a0,-726 # ffffffffc0208ab0 <default_pmm_manager+0x1568>
ffffffffc0205d8e:	ef6fa0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0205d92:	ff8710e3          	bne	a4,s8,ffffffffc0205d72 <do_execve+0x3ae>
ffffffffc0205d96:	8be2                	mv	s7,s8
ffffffffc0205d98:	000a6a97          	auipc	s5,0xa6
ffffffffc0205d9c:	7e0a8a93          	addi	s5,s5,2016 # ffffffffc02ac578 <va_pa_offset>
        while (start < end) {
ffffffffc0205da0:	053be763          	bltu	s7,s3,ffffffffc0205dee <do_execve+0x42a>
ffffffffc0205da4:	b3ad                	j	ffffffffc0205b0e <do_execve+0x14a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205da6:	6785                	lui	a5,0x1
ffffffffc0205da8:	418b8533          	sub	a0,s7,s8
ffffffffc0205dac:	9c3e                	add	s8,s8,a5
ffffffffc0205dae:	417c0633          	sub	a2,s8,s7
            if (end < la) {
ffffffffc0205db2:	0189f463          	bleu	s8,s3,ffffffffc0205dba <do_execve+0x3f6>
                size -= la - end;
ffffffffc0205db6:	41798633          	sub	a2,s3,s7
    return page - pages + nbase;
ffffffffc0205dba:	000db683          	ld	a3,0(s11)
ffffffffc0205dbe:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205dc2:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205dc4:	40d486b3          	sub	a3,s1,a3
ffffffffc0205dc8:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205dca:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205dce:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0205dd0:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205dd4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205dd6:	02b87e63          	bleu	a1,a6,ffffffffc0205e12 <do_execve+0x44e>
ffffffffc0205dda:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc0205dde:	9bb2                	add	s7,s7,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0205de0:	4581                	li	a1,0
ffffffffc0205de2:	96c2                	add	a3,a3,a6
ffffffffc0205de4:	9536                	add	a0,a0,a3
ffffffffc0205de6:	1e7000ef          	jal	ra,ffffffffc02067cc <memset>
        while (start < end) {
ffffffffc0205dea:	d33bf2e3          	bleu	s3,s7,ffffffffc0205b0e <do_execve+0x14a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205dee:	01893503          	ld	a0,24(s2)
ffffffffc0205df2:	6602                	ld	a2,0(sp)
ffffffffc0205df4:	85e2                	mv	a1,s8
ffffffffc0205df6:	dc4fd0ef          	jal	ra,ffffffffc02033ba <pgdir_alloc_page>
ffffffffc0205dfa:	84aa                	mv	s1,a0
ffffffffc0205dfc:	f54d                	bnez	a0,ffffffffc0205da6 <do_execve+0x3e2>
ffffffffc0205dfe:	bdd1                	j	ffffffffc0205cd2 <do_execve+0x30e>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205e00:	417c0ab3          	sub	s5,s8,s7
ffffffffc0205e04:	b72d                	j	ffffffffc0205d2e <do_execve+0x36a>
        while (start < end) {
ffffffffc0205e06:	89de                	mv	s3,s7
ffffffffc0205e08:	b729                	j	ffffffffc0205d12 <do_execve+0x34e>
        return -E_INVAL;
ffffffffc0205e0a:	59f5                	li	s3,-3
ffffffffc0205e0c:	bbe1                	j	ffffffffc0205be4 <do_execve+0x220>
            ret = -E_INVAL_ELF;
ffffffffc0205e0e:	59e1                	li	s3,-8
ffffffffc0205e10:	b5d1                	j	ffffffffc0205cd4 <do_execve+0x310>
ffffffffc0205e12:	00001617          	auipc	a2,0x1
ffffffffc0205e16:	78660613          	addi	a2,a2,1926 # ffffffffc0207598 <default_pmm_manager+0x50>
ffffffffc0205e1a:	06900593          	li	a1,105
ffffffffc0205e1e:	00001517          	auipc	a0,0x1
ffffffffc0205e22:	7a250513          	addi	a0,a0,1954 # ffffffffc02075c0 <default_pmm_manager+0x78>
ffffffffc0205e26:	e5efa0ef          	jal	ra,ffffffffc0200484 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205e2a:	00001617          	auipc	a2,0x1
ffffffffc0205e2e:	7a660613          	addi	a2,a2,1958 # ffffffffc02075d0 <default_pmm_manager+0x88>
ffffffffc0205e32:	28a00593          	li	a1,650
ffffffffc0205e36:	00003517          	auipc	a0,0x3
ffffffffc0205e3a:	c7a50513          	addi	a0,a0,-902 # ffffffffc0208ab0 <default_pmm_manager+0x1568>
ffffffffc0205e3e:	e46fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205e42:	00003697          	auipc	a3,0x3
ffffffffc0205e46:	95668693          	addi	a3,a3,-1706 # ffffffffc0208798 <default_pmm_manager+0x1250>
ffffffffc0205e4a:	00001617          	auipc	a2,0x1
ffffffffc0205e4e:	fb660613          	addi	a2,a2,-74 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0205e52:	28500593          	li	a1,645
ffffffffc0205e56:	00003517          	auipc	a0,0x3
ffffffffc0205e5a:	c5a50513          	addi	a0,a0,-934 # ffffffffc0208ab0 <default_pmm_manager+0x1568>
ffffffffc0205e5e:	e26fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205e62:	00003697          	auipc	a3,0x3
ffffffffc0205e66:	8ee68693          	addi	a3,a3,-1810 # ffffffffc0208750 <default_pmm_manager+0x1208>
ffffffffc0205e6a:	00001617          	auipc	a2,0x1
ffffffffc0205e6e:	f9660613          	addi	a2,a2,-106 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0205e72:	28400593          	li	a1,644
ffffffffc0205e76:	00003517          	auipc	a0,0x3
ffffffffc0205e7a:	c3a50513          	addi	a0,a0,-966 # ffffffffc0208ab0 <default_pmm_manager+0x1568>
ffffffffc0205e7e:	e06fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205e82:	00003697          	auipc	a3,0x3
ffffffffc0205e86:	88668693          	addi	a3,a3,-1914 # ffffffffc0208708 <default_pmm_manager+0x11c0>
ffffffffc0205e8a:	00001617          	auipc	a2,0x1
ffffffffc0205e8e:	f7660613          	addi	a2,a2,-138 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0205e92:	28300593          	li	a1,643
ffffffffc0205e96:	00003517          	auipc	a0,0x3
ffffffffc0205e9a:	c1a50513          	addi	a0,a0,-998 # ffffffffc0208ab0 <default_pmm_manager+0x1568>
ffffffffc0205e9e:	de6fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205ea2:	00003697          	auipc	a3,0x3
ffffffffc0205ea6:	81e68693          	addi	a3,a3,-2018 # ffffffffc02086c0 <default_pmm_manager+0x1178>
ffffffffc0205eaa:	00001617          	auipc	a2,0x1
ffffffffc0205eae:	f5660613          	addi	a2,a2,-170 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0205eb2:	28200593          	li	a1,642
ffffffffc0205eb6:	00003517          	auipc	a0,0x3
ffffffffc0205eba:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0208ab0 <default_pmm_manager+0x1568>
ffffffffc0205ebe:	dc6fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205ec2 <do_yield>:
    current->need_resched = 1;
ffffffffc0205ec2:	000a6797          	auipc	a5,0xa6
ffffffffc0205ec6:	66e78793          	addi	a5,a5,1646 # ffffffffc02ac530 <current>
ffffffffc0205eca:	639c                	ld	a5,0(a5)
ffffffffc0205ecc:	4705                	li	a4,1
}
ffffffffc0205ece:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205ed0:	ef98                	sd	a4,24(a5)
}
ffffffffc0205ed2:	8082                	ret

ffffffffc0205ed4 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205ed4:	1101                	addi	sp,sp,-32
ffffffffc0205ed6:	e822                	sd	s0,16(sp)
ffffffffc0205ed8:	e426                	sd	s1,8(sp)
ffffffffc0205eda:	ec06                	sd	ra,24(sp)
ffffffffc0205edc:	842e                	mv	s0,a1
ffffffffc0205ede:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205ee0:	cd81                	beqz	a1,ffffffffc0205ef8 <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205ee2:	000a6797          	auipc	a5,0xa6
ffffffffc0205ee6:	64e78793          	addi	a5,a5,1614 # ffffffffc02ac530 <current>
ffffffffc0205eea:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205eec:	4685                	li	a3,1
ffffffffc0205eee:	4611                	li	a2,4
ffffffffc0205ef0:	7788                	ld	a0,40(a5)
ffffffffc0205ef2:	d83fe0ef          	jal	ra,ffffffffc0204c74 <user_mem_check>
ffffffffc0205ef6:	c909                	beqz	a0,ffffffffc0205f08 <do_wait+0x34>
ffffffffc0205ef8:	85a2                	mv	a1,s0
}
ffffffffc0205efa:	6442                	ld	s0,16(sp)
ffffffffc0205efc:	60e2                	ld	ra,24(sp)
ffffffffc0205efe:	8526                	mv	a0,s1
ffffffffc0205f00:	64a2                	ld	s1,8(sp)
ffffffffc0205f02:	6105                	addi	sp,sp,32
ffffffffc0205f04:	ff0ff06f          	j	ffffffffc02056f4 <do_wait.part.1>
ffffffffc0205f08:	60e2                	ld	ra,24(sp)
ffffffffc0205f0a:	6442                	ld	s0,16(sp)
ffffffffc0205f0c:	64a2                	ld	s1,8(sp)
ffffffffc0205f0e:	5575                	li	a0,-3
ffffffffc0205f10:	6105                	addi	sp,sp,32
ffffffffc0205f12:	8082                	ret

ffffffffc0205f14 <do_kill>:
do_kill(int pid) {
ffffffffc0205f14:	1141                	addi	sp,sp,-16
ffffffffc0205f16:	e406                	sd	ra,8(sp)
ffffffffc0205f18:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc0205f1a:	a04ff0ef          	jal	ra,ffffffffc020511e <find_proc>
ffffffffc0205f1e:	cd0d                	beqz	a0,ffffffffc0205f58 <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205f20:	0b052703          	lw	a4,176(a0)
ffffffffc0205f24:	00177693          	andi	a3,a4,1
ffffffffc0205f28:	e695                	bnez	a3,ffffffffc0205f54 <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205f2a:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205f2e:	00176713          	ori	a4,a4,1
ffffffffc0205f32:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205f36:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205f38:	0006c763          	bltz	a3,ffffffffc0205f46 <do_kill+0x32>
}
ffffffffc0205f3c:	8522                	mv	a0,s0
ffffffffc0205f3e:	60a2                	ld	ra,8(sp)
ffffffffc0205f40:	6402                	ld	s0,0(sp)
ffffffffc0205f42:	0141                	addi	sp,sp,16
ffffffffc0205f44:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205f46:	1e6000ef          	jal	ra,ffffffffc020612c <wakeup_proc>
}
ffffffffc0205f4a:	8522                	mv	a0,s0
ffffffffc0205f4c:	60a2                	ld	ra,8(sp)
ffffffffc0205f4e:	6402                	ld	s0,0(sp)
ffffffffc0205f50:	0141                	addi	sp,sp,16
ffffffffc0205f52:	8082                	ret
        return -E_KILLED;
ffffffffc0205f54:	545d                	li	s0,-9
ffffffffc0205f56:	b7dd                	j	ffffffffc0205f3c <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205f58:	5475                	li	s0,-3
ffffffffc0205f5a:	b7cd                	j	ffffffffc0205f3c <do_kill+0x28>

ffffffffc0205f5c <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205f5c:	000a6797          	auipc	a5,0xa6
ffffffffc0205f60:	71478793          	addi	a5,a5,1812 # ffffffffc02ac670 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205f64:	1101                	addi	sp,sp,-32
ffffffffc0205f66:	000a6717          	auipc	a4,0xa6
ffffffffc0205f6a:	70f73923          	sd	a5,1810(a4) # ffffffffc02ac678 <proc_list+0x8>
ffffffffc0205f6e:	000a6717          	auipc	a4,0xa6
ffffffffc0205f72:	70f73123          	sd	a5,1794(a4) # ffffffffc02ac670 <proc_list>
ffffffffc0205f76:	ec06                	sd	ra,24(sp)
ffffffffc0205f78:	e822                	sd	s0,16(sp)
ffffffffc0205f7a:	e426                	sd	s1,8(sp)
ffffffffc0205f7c:	000a2797          	auipc	a5,0xa2
ffffffffc0205f80:	57c78793          	addi	a5,a5,1404 # ffffffffc02a84f8 <hash_list>
ffffffffc0205f84:	000a6717          	auipc	a4,0xa6
ffffffffc0205f88:	57470713          	addi	a4,a4,1396 # ffffffffc02ac4f8 <is_panic>
ffffffffc0205f8c:	e79c                	sd	a5,8(a5)
ffffffffc0205f8e:	e39c                	sd	a5,0(a5)
ffffffffc0205f90:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205f92:	fee79de3          	bne	a5,a4,ffffffffc0205f8c <proc_init+0x30>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205f96:	ee3fe0ef          	jal	ra,ffffffffc0204e78 <alloc_proc>
ffffffffc0205f9a:	000a6717          	auipc	a4,0xa6
ffffffffc0205f9e:	58a73f23          	sd	a0,1438(a4) # ffffffffc02ac538 <idleproc>
ffffffffc0205fa2:	000a6497          	auipc	s1,0xa6
ffffffffc0205fa6:	59648493          	addi	s1,s1,1430 # ffffffffc02ac538 <idleproc>
ffffffffc0205faa:	c559                	beqz	a0,ffffffffc0206038 <proc_init+0xdc>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205fac:	4709                	li	a4,2
ffffffffc0205fae:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0205fb0:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205fb2:	00003717          	auipc	a4,0x3
ffffffffc0205fb6:	04e70713          	addi	a4,a4,78 # ffffffffc0209000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0205fba:	00003597          	auipc	a1,0x3
ffffffffc0205fbe:	a0e58593          	addi	a1,a1,-1522 # ffffffffc02089c8 <default_pmm_manager+0x1480>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205fc2:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205fc4:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc0205fc6:	8c2ff0ef          	jal	ra,ffffffffc0205088 <set_proc_name>
    nr_process ++;
ffffffffc0205fca:	000a6797          	auipc	a5,0xa6
ffffffffc0205fce:	57e78793          	addi	a5,a5,1406 # ffffffffc02ac548 <nr_process>
ffffffffc0205fd2:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205fd4:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205fd6:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205fd8:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205fda:	4581                	li	a1,0
ffffffffc0205fdc:	00000517          	auipc	a0,0x0
ffffffffc0205fe0:	8c050513          	addi	a0,a0,-1856 # ffffffffc020589c <init_main>
    nr_process ++;
ffffffffc0205fe4:	000a6697          	auipc	a3,0xa6
ffffffffc0205fe8:	56f6a223          	sw	a5,1380(a3) # ffffffffc02ac548 <nr_process>
    current = idleproc;
ffffffffc0205fec:	000a6797          	auipc	a5,0xa6
ffffffffc0205ff0:	54e7b223          	sd	a4,1348(a5) # ffffffffc02ac530 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205ff4:	d62ff0ef          	jal	ra,ffffffffc0205556 <kernel_thread>
    if (pid <= 0) {
ffffffffc0205ff8:	08a05c63          	blez	a0,ffffffffc0206090 <proc_init+0x134>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205ffc:	922ff0ef          	jal	ra,ffffffffc020511e <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0206000:	00003597          	auipc	a1,0x3
ffffffffc0206004:	9f058593          	addi	a1,a1,-1552 # ffffffffc02089f0 <default_pmm_manager+0x14a8>
    initproc = find_proc(pid);
ffffffffc0206008:	000a6797          	auipc	a5,0xa6
ffffffffc020600c:	52a7bc23          	sd	a0,1336(a5) # ffffffffc02ac540 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0206010:	878ff0ef          	jal	ra,ffffffffc0205088 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0206014:	609c                	ld	a5,0(s1)
ffffffffc0206016:	cfa9                	beqz	a5,ffffffffc0206070 <proc_init+0x114>
ffffffffc0206018:	43dc                	lw	a5,4(a5)
ffffffffc020601a:	ebb9                	bnez	a5,ffffffffc0206070 <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020601c:	000a6797          	auipc	a5,0xa6
ffffffffc0206020:	52478793          	addi	a5,a5,1316 # ffffffffc02ac540 <initproc>
ffffffffc0206024:	639c                	ld	a5,0(a5)
ffffffffc0206026:	c78d                	beqz	a5,ffffffffc0206050 <proc_init+0xf4>
ffffffffc0206028:	43dc                	lw	a5,4(a5)
ffffffffc020602a:	02879363          	bne	a5,s0,ffffffffc0206050 <proc_init+0xf4>
}
ffffffffc020602e:	60e2                	ld	ra,24(sp)
ffffffffc0206030:	6442                	ld	s0,16(sp)
ffffffffc0206032:	64a2                	ld	s1,8(sp)
ffffffffc0206034:	6105                	addi	sp,sp,32
ffffffffc0206036:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0206038:	00003617          	auipc	a2,0x3
ffffffffc020603c:	97860613          	addi	a2,a2,-1672 # ffffffffc02089b0 <default_pmm_manager+0x1468>
ffffffffc0206040:	38100593          	li	a1,897
ffffffffc0206044:	00003517          	auipc	a0,0x3
ffffffffc0206048:	a6c50513          	addi	a0,a0,-1428 # ffffffffc0208ab0 <default_pmm_manager+0x1568>
ffffffffc020604c:	c38fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0206050:	00003697          	auipc	a3,0x3
ffffffffc0206054:	9d068693          	addi	a3,a3,-1584 # ffffffffc0208a20 <default_pmm_manager+0x14d8>
ffffffffc0206058:	00001617          	auipc	a2,0x1
ffffffffc020605c:	da860613          	addi	a2,a2,-600 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0206060:	39600593          	li	a1,918
ffffffffc0206064:	00003517          	auipc	a0,0x3
ffffffffc0206068:	a4c50513          	addi	a0,a0,-1460 # ffffffffc0208ab0 <default_pmm_manager+0x1568>
ffffffffc020606c:	c18fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0206070:	00003697          	auipc	a3,0x3
ffffffffc0206074:	98868693          	addi	a3,a3,-1656 # ffffffffc02089f8 <default_pmm_manager+0x14b0>
ffffffffc0206078:	00001617          	auipc	a2,0x1
ffffffffc020607c:	d8860613          	addi	a2,a2,-632 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc0206080:	39500593          	li	a1,917
ffffffffc0206084:	00003517          	auipc	a0,0x3
ffffffffc0206088:	a2c50513          	addi	a0,a0,-1492 # ffffffffc0208ab0 <default_pmm_manager+0x1568>
ffffffffc020608c:	bf8fa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("create init_main failed.\n");
ffffffffc0206090:	00003617          	auipc	a2,0x3
ffffffffc0206094:	94060613          	addi	a2,a2,-1728 # ffffffffc02089d0 <default_pmm_manager+0x1488>
ffffffffc0206098:	38f00593          	li	a1,911
ffffffffc020609c:	00003517          	auipc	a0,0x3
ffffffffc02060a0:	a1450513          	addi	a0,a0,-1516 # ffffffffc0208ab0 <default_pmm_manager+0x1568>
ffffffffc02060a4:	be0fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02060a8 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc02060a8:	1141                	addi	sp,sp,-16
ffffffffc02060aa:	e022                	sd	s0,0(sp)
ffffffffc02060ac:	e406                	sd	ra,8(sp)
ffffffffc02060ae:	000a6417          	auipc	s0,0xa6
ffffffffc02060b2:	48240413          	addi	s0,s0,1154 # ffffffffc02ac530 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc02060b6:	6018                	ld	a4,0(s0)
ffffffffc02060b8:	6f1c                	ld	a5,24(a4)
ffffffffc02060ba:	dffd                	beqz	a5,ffffffffc02060b8 <cpu_idle+0x10>
            schedule();
ffffffffc02060bc:	0ec000ef          	jal	ra,ffffffffc02061a8 <schedule>
ffffffffc02060c0:	bfdd                	j	ffffffffc02060b6 <cpu_idle+0xe>

ffffffffc02060c2 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc02060c2:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc02060c6:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc02060ca:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc02060cc:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc02060ce:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc02060d2:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc02060d6:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc02060da:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc02060de:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc02060e2:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc02060e6:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc02060ea:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc02060ee:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc02060f2:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc02060f6:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc02060fa:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc02060fe:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0206100:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0206102:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0206106:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc020610a:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc020610e:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0206112:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0206116:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc020611a:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc020611e:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0206122:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0206126:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc020612a:	8082                	ret

ffffffffc020612c <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020612c:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc020612e:	1101                	addi	sp,sp,-32
ffffffffc0206130:	ec06                	sd	ra,24(sp)
ffffffffc0206132:	e822                	sd	s0,16(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206134:	478d                	li	a5,3
ffffffffc0206136:	04f70a63          	beq	a4,a5,ffffffffc020618a <wakeup_proc+0x5e>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020613a:	100027f3          	csrr	a5,sstatus
ffffffffc020613e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0206140:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206142:	ef8d                	bnez	a5,ffffffffc020617c <wakeup_proc+0x50>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0206144:	4789                	li	a5,2
ffffffffc0206146:	00f70f63          	beq	a4,a5,ffffffffc0206164 <wakeup_proc+0x38>
            proc->state = PROC_RUNNABLE;
ffffffffc020614a:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc020614c:	0e052623          	sw	zero,236(a0)
    if (flag) {
ffffffffc0206150:	e409                	bnez	s0,ffffffffc020615a <wakeup_proc+0x2e>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206152:	60e2                	ld	ra,24(sp)
ffffffffc0206154:	6442                	ld	s0,16(sp)
ffffffffc0206156:	6105                	addi	sp,sp,32
ffffffffc0206158:	8082                	ret
ffffffffc020615a:	6442                	ld	s0,16(sp)
ffffffffc020615c:	60e2                	ld	ra,24(sp)
ffffffffc020615e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0206160:	cf4fa06f          	j	ffffffffc0200654 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0206164:	00003617          	auipc	a2,0x3
ffffffffc0206168:	99c60613          	addi	a2,a2,-1636 # ffffffffc0208b00 <default_pmm_manager+0x15b8>
ffffffffc020616c:	45c9                	li	a1,18
ffffffffc020616e:	00003517          	auipc	a0,0x3
ffffffffc0206172:	97a50513          	addi	a0,a0,-1670 # ffffffffc0208ae8 <default_pmm_manager+0x15a0>
ffffffffc0206176:	b7afa0ef          	jal	ra,ffffffffc02004f0 <__warn>
ffffffffc020617a:	bfd9                	j	ffffffffc0206150 <wakeup_proc+0x24>
ffffffffc020617c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020617e:	cdcfa0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc0206182:	6522                	ld	a0,8(sp)
ffffffffc0206184:	4405                	li	s0,1
ffffffffc0206186:	4118                	lw	a4,0(a0)
ffffffffc0206188:	bf75                	j	ffffffffc0206144 <wakeup_proc+0x18>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020618a:	00003697          	auipc	a3,0x3
ffffffffc020618e:	93e68693          	addi	a3,a3,-1730 # ffffffffc0208ac8 <default_pmm_manager+0x1580>
ffffffffc0206192:	00001617          	auipc	a2,0x1
ffffffffc0206196:	c6e60613          	addi	a2,a2,-914 # ffffffffc0206e00 <commands+0x4d8>
ffffffffc020619a:	45a5                	li	a1,9
ffffffffc020619c:	00003517          	auipc	a0,0x3
ffffffffc02061a0:	94c50513          	addi	a0,a0,-1716 # ffffffffc0208ae8 <default_pmm_manager+0x15a0>
ffffffffc02061a4:	ae0fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02061a8 <schedule>:

void
schedule(void) {
ffffffffc02061a8:	1141                	addi	sp,sp,-16
ffffffffc02061aa:	e406                	sd	ra,8(sp)
ffffffffc02061ac:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02061ae:	100027f3          	csrr	a5,sstatus
ffffffffc02061b2:	8b89                	andi	a5,a5,2
ffffffffc02061b4:	4401                	li	s0,0
ffffffffc02061b6:	e3d1                	bnez	a5,ffffffffc020623a <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02061b8:	000a6797          	auipc	a5,0xa6
ffffffffc02061bc:	37878793          	addi	a5,a5,888 # ffffffffc02ac530 <current>
ffffffffc02061c0:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02061c4:	000a6797          	auipc	a5,0xa6
ffffffffc02061c8:	37478793          	addi	a5,a5,884 # ffffffffc02ac538 <idleproc>
ffffffffc02061cc:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc02061ce:	0008bc23          	sd	zero,24(a7) # 2018 <_binary_obj___user_faultread_out_size-0x7560>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02061d2:	04a88e63          	beq	a7,a0,ffffffffc020622e <schedule+0x86>
ffffffffc02061d6:	0c888693          	addi	a3,a7,200
ffffffffc02061da:	000a6617          	auipc	a2,0xa6
ffffffffc02061de:	49660613          	addi	a2,a2,1174 # ffffffffc02ac670 <proc_list>
        le = last;
ffffffffc02061e2:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc02061e4:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc02061e6:	4809                	li	a6,2
    return listelm->next;
ffffffffc02061e8:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc02061ea:	00c78863          	beq	a5,a2,ffffffffc02061fa <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc02061ee:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02061f2:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc02061f6:	01070463          	beq	a4,a6,ffffffffc02061fe <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc02061fa:	fef697e3          	bne	a3,a5,ffffffffc02061e8 <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02061fe:	c589                	beqz	a1,ffffffffc0206208 <schedule+0x60>
ffffffffc0206200:	4198                	lw	a4,0(a1)
ffffffffc0206202:	4789                	li	a5,2
ffffffffc0206204:	00f70e63          	beq	a4,a5,ffffffffc0206220 <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0206208:	451c                	lw	a5,8(a0)
ffffffffc020620a:	2785                	addiw	a5,a5,1
ffffffffc020620c:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc020620e:	00a88463          	beq	a7,a0,ffffffffc0206216 <schedule+0x6e>
            proc_run(next);
ffffffffc0206212:	ea1fe0ef          	jal	ra,ffffffffc02050b2 <proc_run>
    if (flag) {
ffffffffc0206216:	e419                	bnez	s0,ffffffffc0206224 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206218:	60a2                	ld	ra,8(sp)
ffffffffc020621a:	6402                	ld	s0,0(sp)
ffffffffc020621c:	0141                	addi	sp,sp,16
ffffffffc020621e:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206220:	852e                	mv	a0,a1
ffffffffc0206222:	b7dd                	j	ffffffffc0206208 <schedule+0x60>
}
ffffffffc0206224:	6402                	ld	s0,0(sp)
ffffffffc0206226:	60a2                	ld	ra,8(sp)
ffffffffc0206228:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020622a:	c2afa06f          	j	ffffffffc0200654 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020622e:	000a6617          	auipc	a2,0xa6
ffffffffc0206232:	44260613          	addi	a2,a2,1090 # ffffffffc02ac670 <proc_list>
ffffffffc0206236:	86b2                	mv	a3,a2
ffffffffc0206238:	b76d                	j	ffffffffc02061e2 <schedule+0x3a>
        intr_disable();
ffffffffc020623a:	c20fa0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc020623e:	4405                	li	s0,1
ffffffffc0206240:	bfa5                	j	ffffffffc02061b8 <schedule+0x10>

ffffffffc0206242 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0206242:	000a6797          	auipc	a5,0xa6
ffffffffc0206246:	2ee78793          	addi	a5,a5,750 # ffffffffc02ac530 <current>
ffffffffc020624a:	639c                	ld	a5,0(a5)
}
ffffffffc020624c:	43c8                	lw	a0,4(a5)
ffffffffc020624e:	8082                	ret

ffffffffc0206250 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0206250:	4501                	li	a0,0
ffffffffc0206252:	8082                	ret

ffffffffc0206254 <sys_putc>:
    cputchar(c);
ffffffffc0206254:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0206256:	1141                	addi	sp,sp,-16
ffffffffc0206258:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc020625a:	f69f90ef          	jal	ra,ffffffffc02001c2 <cputchar>
}
ffffffffc020625e:	60a2                	ld	ra,8(sp)
ffffffffc0206260:	4501                	li	a0,0
ffffffffc0206262:	0141                	addi	sp,sp,16
ffffffffc0206264:	8082                	ret

ffffffffc0206266 <sys_kill>:
    return do_kill(pid);
ffffffffc0206266:	4108                	lw	a0,0(a0)
ffffffffc0206268:	cadff06f          	j	ffffffffc0205f14 <do_kill>

ffffffffc020626c <sys_yield>:
    return do_yield();
ffffffffc020626c:	c57ff06f          	j	ffffffffc0205ec2 <do_yield>

ffffffffc0206270 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0206270:	6d14                	ld	a3,24(a0)
ffffffffc0206272:	6910                	ld	a2,16(a0)
ffffffffc0206274:	650c                	ld	a1,8(a0)
ffffffffc0206276:	6108                	ld	a0,0(a0)
ffffffffc0206278:	f4cff06f          	j	ffffffffc02059c4 <do_execve>

ffffffffc020627c <sys_wait>:
    return do_wait(pid, store);
ffffffffc020627c:	650c                	ld	a1,8(a0)
ffffffffc020627e:	4108                	lw	a0,0(a0)
ffffffffc0206280:	c55ff06f          	j	ffffffffc0205ed4 <do_wait>

ffffffffc0206284 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0206284:	000a6797          	auipc	a5,0xa6
ffffffffc0206288:	2ac78793          	addi	a5,a5,684 # ffffffffc02ac530 <current>
ffffffffc020628c:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc020628e:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc0206290:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0206292:	6a0c                	ld	a1,16(a2)
ffffffffc0206294:	ee7fe06f          	j	ffffffffc020517a <do_fork>

ffffffffc0206298 <sys_exit>:
    return do_exit(error_code);
ffffffffc0206298:	4108                	lw	a0,0(a0)
ffffffffc020629a:	b0cff06f          	j	ffffffffc02055a6 <do_exit>

ffffffffc020629e <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc020629e:	715d                	addi	sp,sp,-80
ffffffffc02062a0:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02062a2:	000a6497          	auipc	s1,0xa6
ffffffffc02062a6:	28e48493          	addi	s1,s1,654 # ffffffffc02ac530 <current>
ffffffffc02062aa:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02062ac:	e0a2                	sd	s0,64(sp)
ffffffffc02062ae:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02062b0:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02062b2:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02062b4:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02062b6:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02062ba:	0327ee63          	bltu	a5,s2,ffffffffc02062f6 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc02062be:	00391713          	slli	a4,s2,0x3
ffffffffc02062c2:	00003797          	auipc	a5,0x3
ffffffffc02062c6:	8a678793          	addi	a5,a5,-1882 # ffffffffc0208b68 <syscalls>
ffffffffc02062ca:	97ba                	add	a5,a5,a4
ffffffffc02062cc:	639c                	ld	a5,0(a5)
ffffffffc02062ce:	c785                	beqz	a5,ffffffffc02062f6 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc02062d0:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc02062d2:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc02062d4:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc02062d6:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc02062d8:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc02062da:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc02062dc:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc02062de:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02062e0:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc02062e2:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02062e4:	0028                	addi	a0,sp,8
ffffffffc02062e6:	9782                	jalr	a5
ffffffffc02062e8:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc02062ea:	60a6                	ld	ra,72(sp)
ffffffffc02062ec:	6406                	ld	s0,64(sp)
ffffffffc02062ee:	74e2                	ld	s1,56(sp)
ffffffffc02062f0:	7942                	ld	s2,48(sp)
ffffffffc02062f2:	6161                	addi	sp,sp,80
ffffffffc02062f4:	8082                	ret
    print_trapframe(tf);
ffffffffc02062f6:	8522                	mv	a0,s0
ffffffffc02062f8:	d52fa0ef          	jal	ra,ffffffffc020084a <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc02062fc:	609c                	ld	a5,0(s1)
ffffffffc02062fe:	86ca                	mv	a3,s2
ffffffffc0206300:	00003617          	auipc	a2,0x3
ffffffffc0206304:	82060613          	addi	a2,a2,-2016 # ffffffffc0208b20 <default_pmm_manager+0x15d8>
ffffffffc0206308:	43d8                	lw	a4,4(a5)
ffffffffc020630a:	06300593          	li	a1,99
ffffffffc020630e:	0b478793          	addi	a5,a5,180
ffffffffc0206312:	00003517          	auipc	a0,0x3
ffffffffc0206316:	83e50513          	addi	a0,a0,-1986 # ffffffffc0208b50 <default_pmm_manager+0x1608>
ffffffffc020631a:	96afa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020631e <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc020631e:	9e3707b7          	lui	a5,0x9e370
ffffffffc0206322:	2785                	addiw	a5,a5,1
ffffffffc0206324:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0206328:	02000793          	li	a5,32
ffffffffc020632c:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0206330:	00b5553b          	srlw	a0,a0,a1
ffffffffc0206334:	8082                	ret

ffffffffc0206336 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0206336:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020633a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020633c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206340:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0206342:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206346:	f022                	sd	s0,32(sp)
ffffffffc0206348:	ec26                	sd	s1,24(sp)
ffffffffc020634a:	e84a                	sd	s2,16(sp)
ffffffffc020634c:	f406                	sd	ra,40(sp)
ffffffffc020634e:	e44e                	sd	s3,8(sp)
ffffffffc0206350:	84aa                	mv	s1,a0
ffffffffc0206352:	892e                	mv	s2,a1
ffffffffc0206354:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0206358:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc020635a:	03067e63          	bleu	a6,a2,ffffffffc0206396 <printnum+0x60>
ffffffffc020635e:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0206360:	00805763          	blez	s0,ffffffffc020636e <printnum+0x38>
ffffffffc0206364:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0206366:	85ca                	mv	a1,s2
ffffffffc0206368:	854e                	mv	a0,s3
ffffffffc020636a:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020636c:	fc65                	bnez	s0,ffffffffc0206364 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020636e:	1a02                	slli	s4,s4,0x20
ffffffffc0206370:	020a5a13          	srli	s4,s4,0x20
ffffffffc0206374:	00003797          	auipc	a5,0x3
ffffffffc0206378:	b1478793          	addi	a5,a5,-1260 # ffffffffc0208e88 <error_string+0xc8>
ffffffffc020637c:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc020637e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206380:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0206384:	70a2                	ld	ra,40(sp)
ffffffffc0206386:	69a2                	ld	s3,8(sp)
ffffffffc0206388:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020638a:	85ca                	mv	a1,s2
ffffffffc020638c:	8326                	mv	t1,s1
}
ffffffffc020638e:	6942                	ld	s2,16(sp)
ffffffffc0206390:	64e2                	ld	s1,24(sp)
ffffffffc0206392:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206394:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0206396:	03065633          	divu	a2,a2,a6
ffffffffc020639a:	8722                	mv	a4,s0
ffffffffc020639c:	f9bff0ef          	jal	ra,ffffffffc0206336 <printnum>
ffffffffc02063a0:	b7f9                	j	ffffffffc020636e <printnum+0x38>

ffffffffc02063a2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02063a2:	7119                	addi	sp,sp,-128
ffffffffc02063a4:	f4a6                	sd	s1,104(sp)
ffffffffc02063a6:	f0ca                	sd	s2,96(sp)
ffffffffc02063a8:	e8d2                	sd	s4,80(sp)
ffffffffc02063aa:	e4d6                	sd	s5,72(sp)
ffffffffc02063ac:	e0da                	sd	s6,64(sp)
ffffffffc02063ae:	fc5e                	sd	s7,56(sp)
ffffffffc02063b0:	f862                	sd	s8,48(sp)
ffffffffc02063b2:	f06a                	sd	s10,32(sp)
ffffffffc02063b4:	fc86                	sd	ra,120(sp)
ffffffffc02063b6:	f8a2                	sd	s0,112(sp)
ffffffffc02063b8:	ecce                	sd	s3,88(sp)
ffffffffc02063ba:	f466                	sd	s9,40(sp)
ffffffffc02063bc:	ec6e                	sd	s11,24(sp)
ffffffffc02063be:	892a                	mv	s2,a0
ffffffffc02063c0:	84ae                	mv	s1,a1
ffffffffc02063c2:	8d32                	mv	s10,a2
ffffffffc02063c4:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02063c6:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063c8:	00003a17          	auipc	s4,0x3
ffffffffc02063cc:	8a0a0a13          	addi	s4,s4,-1888 # ffffffffc0208c68 <syscalls+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02063d0:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02063d4:	00003c17          	auipc	s8,0x3
ffffffffc02063d8:	9ecc0c13          	addi	s8,s8,-1556 # ffffffffc0208dc0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02063dc:	000d4503          	lbu	a0,0(s10)
ffffffffc02063e0:	02500793          	li	a5,37
ffffffffc02063e4:	001d0413          	addi	s0,s10,1
ffffffffc02063e8:	00f50e63          	beq	a0,a5,ffffffffc0206404 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02063ec:	c521                	beqz	a0,ffffffffc0206434 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02063ee:	02500993          	li	s3,37
ffffffffc02063f2:	a011                	j	ffffffffc02063f6 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02063f4:	c121                	beqz	a0,ffffffffc0206434 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02063f6:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02063f8:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02063fa:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02063fc:	fff44503          	lbu	a0,-1(s0)
ffffffffc0206400:	ff351ae3          	bne	a0,s3,ffffffffc02063f4 <vprintfmt+0x52>
ffffffffc0206404:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0206408:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020640c:	4981                	li	s3,0
ffffffffc020640e:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0206410:	5cfd                	li	s9,-1
ffffffffc0206412:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206414:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0206418:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020641a:	fdd6069b          	addiw	a3,a2,-35
ffffffffc020641e:	0ff6f693          	andi	a3,a3,255
ffffffffc0206422:	00140d13          	addi	s10,s0,1
ffffffffc0206426:	20d5e563          	bltu	a1,a3,ffffffffc0206630 <vprintfmt+0x28e>
ffffffffc020642a:	068a                	slli	a3,a3,0x2
ffffffffc020642c:	96d2                	add	a3,a3,s4
ffffffffc020642e:	4294                	lw	a3,0(a3)
ffffffffc0206430:	96d2                	add	a3,a3,s4
ffffffffc0206432:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0206434:	70e6                	ld	ra,120(sp)
ffffffffc0206436:	7446                	ld	s0,112(sp)
ffffffffc0206438:	74a6                	ld	s1,104(sp)
ffffffffc020643a:	7906                	ld	s2,96(sp)
ffffffffc020643c:	69e6                	ld	s3,88(sp)
ffffffffc020643e:	6a46                	ld	s4,80(sp)
ffffffffc0206440:	6aa6                	ld	s5,72(sp)
ffffffffc0206442:	6b06                	ld	s6,64(sp)
ffffffffc0206444:	7be2                	ld	s7,56(sp)
ffffffffc0206446:	7c42                	ld	s8,48(sp)
ffffffffc0206448:	7ca2                	ld	s9,40(sp)
ffffffffc020644a:	7d02                	ld	s10,32(sp)
ffffffffc020644c:	6de2                	ld	s11,24(sp)
ffffffffc020644e:	6109                	addi	sp,sp,128
ffffffffc0206450:	8082                	ret
    if (lflag >= 2) {
ffffffffc0206452:	4705                	li	a4,1
ffffffffc0206454:	008a8593          	addi	a1,s5,8
ffffffffc0206458:	01074463          	blt	a4,a6,ffffffffc0206460 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc020645c:	26080363          	beqz	a6,ffffffffc02066c2 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0206460:	000ab603          	ld	a2,0(s5)
ffffffffc0206464:	46c1                	li	a3,16
ffffffffc0206466:	8aae                	mv	s5,a1
ffffffffc0206468:	a06d                	j	ffffffffc0206512 <vprintfmt+0x170>
            goto reswitch;
ffffffffc020646a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020646e:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206470:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206472:	b765                	j	ffffffffc020641a <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0206474:	000aa503          	lw	a0,0(s5)
ffffffffc0206478:	85a6                	mv	a1,s1
ffffffffc020647a:	0aa1                	addi	s5,s5,8
ffffffffc020647c:	9902                	jalr	s2
            break;
ffffffffc020647e:	bfb9                	j	ffffffffc02063dc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206480:	4705                	li	a4,1
ffffffffc0206482:	008a8993          	addi	s3,s5,8
ffffffffc0206486:	01074463          	blt	a4,a6,ffffffffc020648e <vprintfmt+0xec>
    else if (lflag) {
ffffffffc020648a:	22080463          	beqz	a6,ffffffffc02066b2 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc020648e:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0206492:	24044463          	bltz	s0,ffffffffc02066da <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0206496:	8622                	mv	a2,s0
ffffffffc0206498:	8ace                	mv	s5,s3
ffffffffc020649a:	46a9                	li	a3,10
ffffffffc020649c:	a89d                	j	ffffffffc0206512 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc020649e:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02064a2:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02064a4:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02064a6:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02064aa:	8fb5                	xor	a5,a5,a3
ffffffffc02064ac:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02064b0:	1ad74363          	blt	a4,a3,ffffffffc0206656 <vprintfmt+0x2b4>
ffffffffc02064b4:	00369793          	slli	a5,a3,0x3
ffffffffc02064b8:	97e2                	add	a5,a5,s8
ffffffffc02064ba:	639c                	ld	a5,0(a5)
ffffffffc02064bc:	18078d63          	beqz	a5,ffffffffc0206656 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02064c0:	86be                	mv	a3,a5
ffffffffc02064c2:	00000617          	auipc	a2,0x0
ffffffffc02064c6:	35e60613          	addi	a2,a2,862 # ffffffffc0206820 <etext+0x2a>
ffffffffc02064ca:	85a6                	mv	a1,s1
ffffffffc02064cc:	854a                	mv	a0,s2
ffffffffc02064ce:	240000ef          	jal	ra,ffffffffc020670e <printfmt>
ffffffffc02064d2:	b729                	j	ffffffffc02063dc <vprintfmt+0x3a>
            lflag ++;
ffffffffc02064d4:	00144603          	lbu	a2,1(s0)
ffffffffc02064d8:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064da:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02064dc:	bf3d                	j	ffffffffc020641a <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02064de:	4705                	li	a4,1
ffffffffc02064e0:	008a8593          	addi	a1,s5,8
ffffffffc02064e4:	01074463          	blt	a4,a6,ffffffffc02064ec <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02064e8:	1e080263          	beqz	a6,ffffffffc02066cc <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc02064ec:	000ab603          	ld	a2,0(s5)
ffffffffc02064f0:	46a1                	li	a3,8
ffffffffc02064f2:	8aae                	mv	s5,a1
ffffffffc02064f4:	a839                	j	ffffffffc0206512 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc02064f6:	03000513          	li	a0,48
ffffffffc02064fa:	85a6                	mv	a1,s1
ffffffffc02064fc:	e03e                	sd	a5,0(sp)
ffffffffc02064fe:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0206500:	85a6                	mv	a1,s1
ffffffffc0206502:	07800513          	li	a0,120
ffffffffc0206506:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206508:	0aa1                	addi	s5,s5,8
ffffffffc020650a:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc020650e:	6782                	ld	a5,0(sp)
ffffffffc0206510:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0206512:	876e                	mv	a4,s11
ffffffffc0206514:	85a6                	mv	a1,s1
ffffffffc0206516:	854a                	mv	a0,s2
ffffffffc0206518:	e1fff0ef          	jal	ra,ffffffffc0206336 <printnum>
            break;
ffffffffc020651c:	b5c1                	j	ffffffffc02063dc <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020651e:	000ab603          	ld	a2,0(s5)
ffffffffc0206522:	0aa1                	addi	s5,s5,8
ffffffffc0206524:	1c060663          	beqz	a2,ffffffffc02066f0 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0206528:	00160413          	addi	s0,a2,1
ffffffffc020652c:	17b05c63          	blez	s11,ffffffffc02066a4 <vprintfmt+0x302>
ffffffffc0206530:	02d00593          	li	a1,45
ffffffffc0206534:	14b79263          	bne	a5,a1,ffffffffc0206678 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206538:	00064783          	lbu	a5,0(a2)
ffffffffc020653c:	0007851b          	sext.w	a0,a5
ffffffffc0206540:	c905                	beqz	a0,ffffffffc0206570 <vprintfmt+0x1ce>
ffffffffc0206542:	000cc563          	bltz	s9,ffffffffc020654c <vprintfmt+0x1aa>
ffffffffc0206546:	3cfd                	addiw	s9,s9,-1
ffffffffc0206548:	036c8263          	beq	s9,s6,ffffffffc020656c <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc020654c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020654e:	18098463          	beqz	s3,ffffffffc02066d6 <vprintfmt+0x334>
ffffffffc0206552:	3781                	addiw	a5,a5,-32
ffffffffc0206554:	18fbf163          	bleu	a5,s7,ffffffffc02066d6 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0206558:	03f00513          	li	a0,63
ffffffffc020655c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020655e:	0405                	addi	s0,s0,1
ffffffffc0206560:	fff44783          	lbu	a5,-1(s0)
ffffffffc0206564:	3dfd                	addiw	s11,s11,-1
ffffffffc0206566:	0007851b          	sext.w	a0,a5
ffffffffc020656a:	fd61                	bnez	a0,ffffffffc0206542 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc020656c:	e7b058e3          	blez	s11,ffffffffc02063dc <vprintfmt+0x3a>
ffffffffc0206570:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206572:	85a6                	mv	a1,s1
ffffffffc0206574:	02000513          	li	a0,32
ffffffffc0206578:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020657a:	e60d81e3          	beqz	s11,ffffffffc02063dc <vprintfmt+0x3a>
ffffffffc020657e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206580:	85a6                	mv	a1,s1
ffffffffc0206582:	02000513          	li	a0,32
ffffffffc0206586:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206588:	fe0d94e3          	bnez	s11,ffffffffc0206570 <vprintfmt+0x1ce>
ffffffffc020658c:	bd81                	j	ffffffffc02063dc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020658e:	4705                	li	a4,1
ffffffffc0206590:	008a8593          	addi	a1,s5,8
ffffffffc0206594:	01074463          	blt	a4,a6,ffffffffc020659c <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0206598:	12080063          	beqz	a6,ffffffffc02066b8 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc020659c:	000ab603          	ld	a2,0(s5)
ffffffffc02065a0:	46a9                	li	a3,10
ffffffffc02065a2:	8aae                	mv	s5,a1
ffffffffc02065a4:	b7bd                	j	ffffffffc0206512 <vprintfmt+0x170>
ffffffffc02065a6:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02065aa:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02065ae:	846a                	mv	s0,s10
ffffffffc02065b0:	b5ad                	j	ffffffffc020641a <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02065b2:	85a6                	mv	a1,s1
ffffffffc02065b4:	02500513          	li	a0,37
ffffffffc02065b8:	9902                	jalr	s2
            break;
ffffffffc02065ba:	b50d                	j	ffffffffc02063dc <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02065bc:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02065c0:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02065c4:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02065c6:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02065c8:	e40dd9e3          	bgez	s11,ffffffffc020641a <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02065cc:	8de6                	mv	s11,s9
ffffffffc02065ce:	5cfd                	li	s9,-1
ffffffffc02065d0:	b5a9                	j	ffffffffc020641a <vprintfmt+0x78>
            goto reswitch;
ffffffffc02065d2:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02065d6:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02065da:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02065dc:	bd3d                	j	ffffffffc020641a <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02065de:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02065e2:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02065e6:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02065e8:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02065ec:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02065f0:	fcd56ce3          	bltu	a0,a3,ffffffffc02065c8 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc02065f4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02065f6:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02065fa:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02065fe:	0196873b          	addw	a4,a3,s9
ffffffffc0206602:	0017171b          	slliw	a4,a4,0x1
ffffffffc0206606:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc020660a:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc020660e:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0206612:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206616:	fcd57fe3          	bleu	a3,a0,ffffffffc02065f4 <vprintfmt+0x252>
ffffffffc020661a:	b77d                	j	ffffffffc02065c8 <vprintfmt+0x226>
            if (width < 0)
ffffffffc020661c:	fffdc693          	not	a3,s11
ffffffffc0206620:	96fd                	srai	a3,a3,0x3f
ffffffffc0206622:	00ddfdb3          	and	s11,s11,a3
ffffffffc0206626:	00144603          	lbu	a2,1(s0)
ffffffffc020662a:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020662c:	846a                	mv	s0,s10
ffffffffc020662e:	b3f5                	j	ffffffffc020641a <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0206630:	85a6                	mv	a1,s1
ffffffffc0206632:	02500513          	li	a0,37
ffffffffc0206636:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0206638:	fff44703          	lbu	a4,-1(s0)
ffffffffc020663c:	02500793          	li	a5,37
ffffffffc0206640:	8d22                	mv	s10,s0
ffffffffc0206642:	d8f70de3          	beq	a4,a5,ffffffffc02063dc <vprintfmt+0x3a>
ffffffffc0206646:	02500713          	li	a4,37
ffffffffc020664a:	1d7d                	addi	s10,s10,-1
ffffffffc020664c:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0206650:	fee79de3          	bne	a5,a4,ffffffffc020664a <vprintfmt+0x2a8>
ffffffffc0206654:	b361                	j	ffffffffc02063dc <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0206656:	00003617          	auipc	a2,0x3
ffffffffc020665a:	91260613          	addi	a2,a2,-1774 # ffffffffc0208f68 <error_string+0x1a8>
ffffffffc020665e:	85a6                	mv	a1,s1
ffffffffc0206660:	854a                	mv	a0,s2
ffffffffc0206662:	0ac000ef          	jal	ra,ffffffffc020670e <printfmt>
ffffffffc0206666:	bb9d                	j	ffffffffc02063dc <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0206668:	00003617          	auipc	a2,0x3
ffffffffc020666c:	8f860613          	addi	a2,a2,-1800 # ffffffffc0208f60 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc0206670:	00003417          	auipc	s0,0x3
ffffffffc0206674:	8f140413          	addi	s0,s0,-1807 # ffffffffc0208f61 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206678:	8532                	mv	a0,a2
ffffffffc020667a:	85e6                	mv	a1,s9
ffffffffc020667c:	e032                	sd	a2,0(sp)
ffffffffc020667e:	e43e                	sd	a5,8(sp)
ffffffffc0206680:	0cc000ef          	jal	ra,ffffffffc020674c <strnlen>
ffffffffc0206684:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0206688:	6602                	ld	a2,0(sp)
ffffffffc020668a:	01b05d63          	blez	s11,ffffffffc02066a4 <vprintfmt+0x302>
ffffffffc020668e:	67a2                	ld	a5,8(sp)
ffffffffc0206690:	2781                	sext.w	a5,a5
ffffffffc0206692:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0206694:	6522                	ld	a0,8(sp)
ffffffffc0206696:	85a6                	mv	a1,s1
ffffffffc0206698:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020669a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020669c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020669e:	6602                	ld	a2,0(sp)
ffffffffc02066a0:	fe0d9ae3          	bnez	s11,ffffffffc0206694 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02066a4:	00064783          	lbu	a5,0(a2)
ffffffffc02066a8:	0007851b          	sext.w	a0,a5
ffffffffc02066ac:	e8051be3          	bnez	a0,ffffffffc0206542 <vprintfmt+0x1a0>
ffffffffc02066b0:	b335                	j	ffffffffc02063dc <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02066b2:	000aa403          	lw	s0,0(s5)
ffffffffc02066b6:	bbf1                	j	ffffffffc0206492 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02066b8:	000ae603          	lwu	a2,0(s5)
ffffffffc02066bc:	46a9                	li	a3,10
ffffffffc02066be:	8aae                	mv	s5,a1
ffffffffc02066c0:	bd89                	j	ffffffffc0206512 <vprintfmt+0x170>
ffffffffc02066c2:	000ae603          	lwu	a2,0(s5)
ffffffffc02066c6:	46c1                	li	a3,16
ffffffffc02066c8:	8aae                	mv	s5,a1
ffffffffc02066ca:	b5a1                	j	ffffffffc0206512 <vprintfmt+0x170>
ffffffffc02066cc:	000ae603          	lwu	a2,0(s5)
ffffffffc02066d0:	46a1                	li	a3,8
ffffffffc02066d2:	8aae                	mv	s5,a1
ffffffffc02066d4:	bd3d                	j	ffffffffc0206512 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02066d6:	9902                	jalr	s2
ffffffffc02066d8:	b559                	j	ffffffffc020655e <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02066da:	85a6                	mv	a1,s1
ffffffffc02066dc:	02d00513          	li	a0,45
ffffffffc02066e0:	e03e                	sd	a5,0(sp)
ffffffffc02066e2:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02066e4:	8ace                	mv	s5,s3
ffffffffc02066e6:	40800633          	neg	a2,s0
ffffffffc02066ea:	46a9                	li	a3,10
ffffffffc02066ec:	6782                	ld	a5,0(sp)
ffffffffc02066ee:	b515                	j	ffffffffc0206512 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02066f0:	01b05663          	blez	s11,ffffffffc02066fc <vprintfmt+0x35a>
ffffffffc02066f4:	02d00693          	li	a3,45
ffffffffc02066f8:	f6d798e3          	bne	a5,a3,ffffffffc0206668 <vprintfmt+0x2c6>
ffffffffc02066fc:	00003417          	auipc	s0,0x3
ffffffffc0206700:	86540413          	addi	s0,s0,-1947 # ffffffffc0208f61 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206704:	02800513          	li	a0,40
ffffffffc0206708:	02800793          	li	a5,40
ffffffffc020670c:	bd1d                	j	ffffffffc0206542 <vprintfmt+0x1a0>

ffffffffc020670e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020670e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0206710:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206714:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206716:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206718:	ec06                	sd	ra,24(sp)
ffffffffc020671a:	f83a                	sd	a4,48(sp)
ffffffffc020671c:	fc3e                	sd	a5,56(sp)
ffffffffc020671e:	e0c2                	sd	a6,64(sp)
ffffffffc0206720:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0206722:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206724:	c7fff0ef          	jal	ra,ffffffffc02063a2 <vprintfmt>
}
ffffffffc0206728:	60e2                	ld	ra,24(sp)
ffffffffc020672a:	6161                	addi	sp,sp,80
ffffffffc020672c:	8082                	ret

ffffffffc020672e <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020672e:	00054783          	lbu	a5,0(a0)
ffffffffc0206732:	cb91                	beqz	a5,ffffffffc0206746 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0206734:	4781                	li	a5,0
        cnt ++;
ffffffffc0206736:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0206738:	00f50733          	add	a4,a0,a5
ffffffffc020673c:	00074703          	lbu	a4,0(a4)
ffffffffc0206740:	fb7d                	bnez	a4,ffffffffc0206736 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0206742:	853e                	mv	a0,a5
ffffffffc0206744:	8082                	ret
    size_t cnt = 0;
ffffffffc0206746:	4781                	li	a5,0
}
ffffffffc0206748:	853e                	mv	a0,a5
ffffffffc020674a:	8082                	ret

ffffffffc020674c <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc020674c:	c185                	beqz	a1,ffffffffc020676c <strnlen+0x20>
ffffffffc020674e:	00054783          	lbu	a5,0(a0)
ffffffffc0206752:	cf89                	beqz	a5,ffffffffc020676c <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0206754:	4781                	li	a5,0
ffffffffc0206756:	a021                	j	ffffffffc020675e <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206758:	00074703          	lbu	a4,0(a4)
ffffffffc020675c:	c711                	beqz	a4,ffffffffc0206768 <strnlen+0x1c>
        cnt ++;
ffffffffc020675e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206760:	00f50733          	add	a4,a0,a5
ffffffffc0206764:	fef59ae3          	bne	a1,a5,ffffffffc0206758 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0206768:	853e                	mv	a0,a5
ffffffffc020676a:	8082                	ret
    size_t cnt = 0;
ffffffffc020676c:	4781                	li	a5,0
}
ffffffffc020676e:	853e                	mv	a0,a5
ffffffffc0206770:	8082                	ret

ffffffffc0206772 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206772:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0206774:	0585                	addi	a1,a1,1
ffffffffc0206776:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020677a:	0785                	addi	a5,a5,1
ffffffffc020677c:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206780:	fb75                	bnez	a4,ffffffffc0206774 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206782:	8082                	ret

ffffffffc0206784 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206784:	00054783          	lbu	a5,0(a0)
ffffffffc0206788:	0005c703          	lbu	a4,0(a1)
ffffffffc020678c:	cb91                	beqz	a5,ffffffffc02067a0 <strcmp+0x1c>
ffffffffc020678e:	00e79c63          	bne	a5,a4,ffffffffc02067a6 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0206792:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206794:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0206798:	0585                	addi	a1,a1,1
ffffffffc020679a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020679e:	fbe5                	bnez	a5,ffffffffc020678e <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02067a0:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02067a2:	9d19                	subw	a0,a0,a4
ffffffffc02067a4:	8082                	ret
ffffffffc02067a6:	0007851b          	sext.w	a0,a5
ffffffffc02067aa:	9d19                	subw	a0,a0,a4
ffffffffc02067ac:	8082                	ret

ffffffffc02067ae <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02067ae:	00054783          	lbu	a5,0(a0)
ffffffffc02067b2:	cb91                	beqz	a5,ffffffffc02067c6 <strchr+0x18>
        if (*s == c) {
ffffffffc02067b4:	00b79563          	bne	a5,a1,ffffffffc02067be <strchr+0x10>
ffffffffc02067b8:	a809                	j	ffffffffc02067ca <strchr+0x1c>
ffffffffc02067ba:	00b78763          	beq	a5,a1,ffffffffc02067c8 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02067be:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02067c0:	00054783          	lbu	a5,0(a0)
ffffffffc02067c4:	fbfd                	bnez	a5,ffffffffc02067ba <strchr+0xc>
    }
    return NULL;
ffffffffc02067c6:	4501                	li	a0,0
}
ffffffffc02067c8:	8082                	ret
ffffffffc02067ca:	8082                	ret

ffffffffc02067cc <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02067cc:	ca01                	beqz	a2,ffffffffc02067dc <memset+0x10>
ffffffffc02067ce:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02067d0:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02067d2:	0785                	addi	a5,a5,1
ffffffffc02067d4:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02067d8:	fec79de3          	bne	a5,a2,ffffffffc02067d2 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02067dc:	8082                	ret

ffffffffc02067de <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02067de:	ca19                	beqz	a2,ffffffffc02067f4 <memcpy+0x16>
ffffffffc02067e0:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02067e2:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02067e4:	0585                	addi	a1,a1,1
ffffffffc02067e6:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02067ea:	0785                	addi	a5,a5,1
ffffffffc02067ec:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02067f0:	fec59ae3          	bne	a1,a2,ffffffffc02067e4 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02067f4:	8082                	ret
