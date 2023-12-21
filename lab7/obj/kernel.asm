
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020d2b7          	lui	t0,0xc020d
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
ffffffffc0200028:	c020d137          	lui	sp,0xc020d

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
static void lab1_switch_test(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	000d4517          	auipc	a0,0xd4
ffffffffc020003a:	eca50513          	addi	a0,a0,-310 # ffffffffc02d3f00 <edata>
ffffffffc020003e:	000df617          	auipc	a2,0xdf
ffffffffc0200042:	5d260613          	addi	a2,a2,1490 # ffffffffc02df610 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	4d6070ef          	jal	ra,ffffffffc0207524 <memset>
    cons_init();                // init the console
ffffffffc0200052:	52e000ef          	jal	ra,ffffffffc0200580 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00007597          	auipc	a1,0x7
ffffffffc020005a:	4fa58593          	addi	a1,a1,1274 # ffffffffc0207550 <etext+0x2>
ffffffffc020005e:	00007517          	auipc	a0,0x7
ffffffffc0200062:	51250513          	addi	a0,a0,1298 # ffffffffc0207570 <etext+0x22>
ffffffffc0200066:	12c000ef          	jal	ra,ffffffffc0200192 <cprintf>

    print_kerninfo();
ffffffffc020006a:	1b0000ef          	jal	ra,ffffffffc020021a <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	5d2020ef          	jal	ra,ffffffffc0202640 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5e6000ef          	jal	ra,ffffffffc0200658 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5e4000ef          	jal	ra,ffffffffc020065a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	3fa040ef          	jal	ra,ffffffffc0204474 <vmm_init>
    sched_init();
ffffffffc020007e:	27f060ef          	jal	ra,ffffffffc0206afc <sched_init>
    proc_init();                // init process table
ffffffffc0200082:	704060ef          	jal	ra,ffffffffc0206786 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200086:	56e000ef          	jal	ra,ffffffffc02005f4 <ide_init>
    swap_init();                // init swap
ffffffffc020008a:	30e030ef          	jal	ra,ffffffffc0203398 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008e:	4a8000ef          	jal	ra,ffffffffc0200536 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc0200092:	5ba000ef          	jal	ra,ffffffffc020064c <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
        
    cpu_idle();                 // run idle process
ffffffffc0200096:	03d060ef          	jal	ra,ffffffffc02068d2 <cpu_idle>

ffffffffc020009a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020009a:	715d                	addi	sp,sp,-80
ffffffffc020009c:	e486                	sd	ra,72(sp)
ffffffffc020009e:	e0a2                	sd	s0,64(sp)
ffffffffc02000a0:	fc26                	sd	s1,56(sp)
ffffffffc02000a2:	f84a                	sd	s2,48(sp)
ffffffffc02000a4:	f44e                	sd	s3,40(sp)
ffffffffc02000a6:	f052                	sd	s4,32(sp)
ffffffffc02000a8:	ec56                	sd	s5,24(sp)
ffffffffc02000aa:	e85a                	sd	s6,16(sp)
ffffffffc02000ac:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02000ae:	c901                	beqz	a0,ffffffffc02000be <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02000b0:	85aa                	mv	a1,a0
ffffffffc02000b2:	00007517          	auipc	a0,0x7
ffffffffc02000b6:	4c650513          	addi	a0,a0,1222 # ffffffffc0207578 <etext+0x2a>
ffffffffc02000ba:	0d8000ef          	jal	ra,ffffffffc0200192 <cprintf>
readline(const char *prompt) {
ffffffffc02000be:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000c0:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000c2:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000c4:	4aa9                	li	s5,10
ffffffffc02000c6:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000c8:	000d4b97          	auipc	s7,0xd4
ffffffffc02000cc:	e38b8b93          	addi	s7,s7,-456 # ffffffffc02d3f00 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000d0:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000d4:	136000ef          	jal	ra,ffffffffc020020a <getchar>
ffffffffc02000d8:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000da:	00054b63          	bltz	a0,ffffffffc02000f0 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000de:	00a95b63          	ble	a0,s2,ffffffffc02000f4 <readline+0x5a>
ffffffffc02000e2:	029a5463          	ble	s1,s4,ffffffffc020010a <readline+0x70>
        c = getchar();
ffffffffc02000e6:	124000ef          	jal	ra,ffffffffc020020a <getchar>
ffffffffc02000ea:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000ec:	fe0559e3          	bgez	a0,ffffffffc02000de <readline+0x44>
            return NULL;
ffffffffc02000f0:	4501                	li	a0,0
ffffffffc02000f2:	a099                	j	ffffffffc0200138 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02000f4:	03341463          	bne	s0,s3,ffffffffc020011c <readline+0x82>
ffffffffc02000f8:	e8b9                	bnez	s1,ffffffffc020014e <readline+0xb4>
        c = getchar();
ffffffffc02000fa:	110000ef          	jal	ra,ffffffffc020020a <getchar>
ffffffffc02000fe:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0200100:	fe0548e3          	bltz	a0,ffffffffc02000f0 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200104:	fea958e3          	ble	a0,s2,ffffffffc02000f4 <readline+0x5a>
ffffffffc0200108:	4481                	li	s1,0
            cputchar(c);
ffffffffc020010a:	8522                	mv	a0,s0
ffffffffc020010c:	0ba000ef          	jal	ra,ffffffffc02001c6 <cputchar>
            buf[i ++] = c;
ffffffffc0200110:	009b87b3          	add	a5,s7,s1
ffffffffc0200114:	00878023          	sb	s0,0(a5)
ffffffffc0200118:	2485                	addiw	s1,s1,1
ffffffffc020011a:	bf6d                	j	ffffffffc02000d4 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc020011c:	01540463          	beq	s0,s5,ffffffffc0200124 <readline+0x8a>
ffffffffc0200120:	fb641ae3          	bne	s0,s6,ffffffffc02000d4 <readline+0x3a>
            cputchar(c);
ffffffffc0200124:	8522                	mv	a0,s0
ffffffffc0200126:	0a0000ef          	jal	ra,ffffffffc02001c6 <cputchar>
            buf[i] = '\0';
ffffffffc020012a:	000d4517          	auipc	a0,0xd4
ffffffffc020012e:	dd650513          	addi	a0,a0,-554 # ffffffffc02d3f00 <edata>
ffffffffc0200132:	94aa                	add	s1,s1,a0
ffffffffc0200134:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200138:	60a6                	ld	ra,72(sp)
ffffffffc020013a:	6406                	ld	s0,64(sp)
ffffffffc020013c:	74e2                	ld	s1,56(sp)
ffffffffc020013e:	7942                	ld	s2,48(sp)
ffffffffc0200140:	79a2                	ld	s3,40(sp)
ffffffffc0200142:	7a02                	ld	s4,32(sp)
ffffffffc0200144:	6ae2                	ld	s5,24(sp)
ffffffffc0200146:	6b42                	ld	s6,16(sp)
ffffffffc0200148:	6ba2                	ld	s7,8(sp)
ffffffffc020014a:	6161                	addi	sp,sp,80
ffffffffc020014c:	8082                	ret
            cputchar(c);
ffffffffc020014e:	4521                	li	a0,8
ffffffffc0200150:	076000ef          	jal	ra,ffffffffc02001c6 <cputchar>
            i --;
ffffffffc0200154:	34fd                	addiw	s1,s1,-1
ffffffffc0200156:	bfbd                	j	ffffffffc02000d4 <readline+0x3a>

ffffffffc0200158 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200158:	1141                	addi	sp,sp,-16
ffffffffc020015a:	e022                	sd	s0,0(sp)
ffffffffc020015c:	e406                	sd	ra,8(sp)
ffffffffc020015e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200160:	422000ef          	jal	ra,ffffffffc0200582 <cons_putc>
    (*cnt) ++;
ffffffffc0200164:	401c                	lw	a5,0(s0)
}
ffffffffc0200166:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200168:	2785                	addiw	a5,a5,1
ffffffffc020016a:	c01c                	sw	a5,0(s0)
}
ffffffffc020016c:	6402                	ld	s0,0(sp)
ffffffffc020016e:	0141                	addi	sp,sp,16
ffffffffc0200170:	8082                	ret

ffffffffc0200172 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200172:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200174:	86ae                	mv	a3,a1
ffffffffc0200176:	862a                	mv	a2,a0
ffffffffc0200178:	006c                	addi	a1,sp,12
ffffffffc020017a:	00000517          	auipc	a0,0x0
ffffffffc020017e:	fde50513          	addi	a0,a0,-34 # ffffffffc0200158 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200182:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200184:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200186:	775060ef          	jal	ra,ffffffffc02070fa <vprintfmt>
    return cnt;
}
ffffffffc020018a:	60e2                	ld	ra,24(sp)
ffffffffc020018c:	4532                	lw	a0,12(sp)
ffffffffc020018e:	6105                	addi	sp,sp,32
ffffffffc0200190:	8082                	ret

ffffffffc0200192 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200192:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200194:	02810313          	addi	t1,sp,40 # ffffffffc020d028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200198:	f42e                	sd	a1,40(sp)
ffffffffc020019a:	f832                	sd	a2,48(sp)
ffffffffc020019c:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020019e:	862a                	mv	a2,a0
ffffffffc02001a0:	004c                	addi	a1,sp,4
ffffffffc02001a2:	00000517          	auipc	a0,0x0
ffffffffc02001a6:	fb650513          	addi	a0,a0,-74 # ffffffffc0200158 <cputch>
ffffffffc02001aa:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02001ac:	ec06                	sd	ra,24(sp)
ffffffffc02001ae:	e0ba                	sd	a4,64(sp)
ffffffffc02001b0:	e4be                	sd	a5,72(sp)
ffffffffc02001b2:	e8c2                	sd	a6,80(sp)
ffffffffc02001b4:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001b6:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001b8:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001ba:	741060ef          	jal	ra,ffffffffc02070fa <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001be:	60e2                	ld	ra,24(sp)
ffffffffc02001c0:	4512                	lw	a0,4(sp)
ffffffffc02001c2:	6125                	addi	sp,sp,96
ffffffffc02001c4:	8082                	ret

ffffffffc02001c6 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001c6:	3bc0006f          	j	ffffffffc0200582 <cons_putc>

ffffffffc02001ca <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02001ca:	1101                	addi	sp,sp,-32
ffffffffc02001cc:	e822                	sd	s0,16(sp)
ffffffffc02001ce:	ec06                	sd	ra,24(sp)
ffffffffc02001d0:	e426                	sd	s1,8(sp)
ffffffffc02001d2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02001d4:	00054503          	lbu	a0,0(a0)
ffffffffc02001d8:	c51d                	beqz	a0,ffffffffc0200206 <cputs+0x3c>
ffffffffc02001da:	0405                	addi	s0,s0,1
ffffffffc02001dc:	4485                	li	s1,1
ffffffffc02001de:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02001e0:	3a2000ef          	jal	ra,ffffffffc0200582 <cons_putc>
    (*cnt) ++;
ffffffffc02001e4:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc02001e8:	0405                	addi	s0,s0,1
ffffffffc02001ea:	fff44503          	lbu	a0,-1(s0)
ffffffffc02001ee:	f96d                	bnez	a0,ffffffffc02001e0 <cputs+0x16>
ffffffffc02001f0:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001f4:	4529                	li	a0,10
ffffffffc02001f6:	38c000ef          	jal	ra,ffffffffc0200582 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001fa:	8522                	mv	a0,s0
ffffffffc02001fc:	60e2                	ld	ra,24(sp)
ffffffffc02001fe:	6442                	ld	s0,16(sp)
ffffffffc0200200:	64a2                	ld	s1,8(sp)
ffffffffc0200202:	6105                	addi	sp,sp,32
ffffffffc0200204:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200206:	4405                	li	s0,1
ffffffffc0200208:	b7f5                	j	ffffffffc02001f4 <cputs+0x2a>

ffffffffc020020a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020020a:	1141                	addi	sp,sp,-16
ffffffffc020020c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020020e:	3aa000ef          	jal	ra,ffffffffc02005b8 <cons_getc>
ffffffffc0200212:	dd75                	beqz	a0,ffffffffc020020e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200214:	60a2                	ld	ra,8(sp)
ffffffffc0200216:	0141                	addi	sp,sp,16
ffffffffc0200218:	8082                	ret

ffffffffc020021a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020021a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020021c:	00007517          	auipc	a0,0x7
ffffffffc0200220:	39450513          	addi	a0,a0,916 # ffffffffc02075b0 <etext+0x62>
void print_kerninfo(void) {
ffffffffc0200224:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200226:	f6dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020022a:	00000597          	auipc	a1,0x0
ffffffffc020022e:	e0c58593          	addi	a1,a1,-500 # ffffffffc0200036 <kern_init>
ffffffffc0200232:	00007517          	auipc	a0,0x7
ffffffffc0200236:	39e50513          	addi	a0,a0,926 # ffffffffc02075d0 <etext+0x82>
ffffffffc020023a:	f59ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020023e:	00007597          	auipc	a1,0x7
ffffffffc0200242:	31058593          	addi	a1,a1,784 # ffffffffc020754e <etext>
ffffffffc0200246:	00007517          	auipc	a0,0x7
ffffffffc020024a:	3aa50513          	addi	a0,a0,938 # ffffffffc02075f0 <etext+0xa2>
ffffffffc020024e:	f45ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200252:	000d4597          	auipc	a1,0xd4
ffffffffc0200256:	cae58593          	addi	a1,a1,-850 # ffffffffc02d3f00 <edata>
ffffffffc020025a:	00007517          	auipc	a0,0x7
ffffffffc020025e:	3b650513          	addi	a0,a0,950 # ffffffffc0207610 <etext+0xc2>
ffffffffc0200262:	f31ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200266:	000df597          	auipc	a1,0xdf
ffffffffc020026a:	3aa58593          	addi	a1,a1,938 # ffffffffc02df610 <end>
ffffffffc020026e:	00007517          	auipc	a0,0x7
ffffffffc0200272:	3c250513          	addi	a0,a0,962 # ffffffffc0207630 <etext+0xe2>
ffffffffc0200276:	f1dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020027a:	000df597          	auipc	a1,0xdf
ffffffffc020027e:	79558593          	addi	a1,a1,1941 # ffffffffc02dfa0f <end+0x3ff>
ffffffffc0200282:	00000797          	auipc	a5,0x0
ffffffffc0200286:	db478793          	addi	a5,a5,-588 # ffffffffc0200036 <kern_init>
ffffffffc020028a:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020028e:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200292:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200294:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200298:	95be                	add	a1,a1,a5
ffffffffc020029a:	85a9                	srai	a1,a1,0xa
ffffffffc020029c:	00007517          	auipc	a0,0x7
ffffffffc02002a0:	3b450513          	addi	a0,a0,948 # ffffffffc0207650 <etext+0x102>
}
ffffffffc02002a4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002a6:	eedff06f          	j	ffffffffc0200192 <cprintf>

ffffffffc02002aa <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002aa:	1141                	addi	sp,sp,-16
     * and line number, etc.
     *    (3.5) popup a calling stackframe
     *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
     *                   the calling funciton's ebp = ss:[ebp]
     */
    panic("Not Implemented!");
ffffffffc02002ac:	00007617          	auipc	a2,0x7
ffffffffc02002b0:	2d460613          	addi	a2,a2,724 # ffffffffc0207580 <etext+0x32>
ffffffffc02002b4:	05b00593          	li	a1,91
ffffffffc02002b8:	00007517          	auipc	a0,0x7
ffffffffc02002bc:	2e050513          	addi	a0,a0,736 # ffffffffc0207598 <etext+0x4a>
void print_stackframe(void) {
ffffffffc02002c0:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002c2:	1c6000ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02002c6 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002c6:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002c8:	00007617          	auipc	a2,0x7
ffffffffc02002cc:	49860613          	addi	a2,a2,1176 # ffffffffc0207760 <commands+0xe0>
ffffffffc02002d0:	00007597          	auipc	a1,0x7
ffffffffc02002d4:	4b058593          	addi	a1,a1,1200 # ffffffffc0207780 <commands+0x100>
ffffffffc02002d8:	00007517          	auipc	a0,0x7
ffffffffc02002dc:	4b050513          	addi	a0,a0,1200 # ffffffffc0207788 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e0:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e2:	eb1ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc02002e6:	00007617          	auipc	a2,0x7
ffffffffc02002ea:	4b260613          	addi	a2,a2,1202 # ffffffffc0207798 <commands+0x118>
ffffffffc02002ee:	00007597          	auipc	a1,0x7
ffffffffc02002f2:	4d258593          	addi	a1,a1,1234 # ffffffffc02077c0 <commands+0x140>
ffffffffc02002f6:	00007517          	auipc	a0,0x7
ffffffffc02002fa:	49250513          	addi	a0,a0,1170 # ffffffffc0207788 <commands+0x108>
ffffffffc02002fe:	e95ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc0200302:	00007617          	auipc	a2,0x7
ffffffffc0200306:	4ce60613          	addi	a2,a2,1230 # ffffffffc02077d0 <commands+0x150>
ffffffffc020030a:	00007597          	auipc	a1,0x7
ffffffffc020030e:	4e658593          	addi	a1,a1,1254 # ffffffffc02077f0 <commands+0x170>
ffffffffc0200312:	00007517          	auipc	a0,0x7
ffffffffc0200316:	47650513          	addi	a0,a0,1142 # ffffffffc0207788 <commands+0x108>
ffffffffc020031a:	e79ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    }
    return 0;
}
ffffffffc020031e:	60a2                	ld	ra,8(sp)
ffffffffc0200320:	4501                	li	a0,0
ffffffffc0200322:	0141                	addi	sp,sp,16
ffffffffc0200324:	8082                	ret

ffffffffc0200326 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200326:	1141                	addi	sp,sp,-16
ffffffffc0200328:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020032a:	ef1ff0ef          	jal	ra,ffffffffc020021a <print_kerninfo>
    return 0;
}
ffffffffc020032e:	60a2                	ld	ra,8(sp)
ffffffffc0200330:	4501                	li	a0,0
ffffffffc0200332:	0141                	addi	sp,sp,16
ffffffffc0200334:	8082                	ret

ffffffffc0200336 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200336:	1141                	addi	sp,sp,-16
ffffffffc0200338:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020033a:	f71ff0ef          	jal	ra,ffffffffc02002aa <print_stackframe>
    return 0;
}
ffffffffc020033e:	60a2                	ld	ra,8(sp)
ffffffffc0200340:	4501                	li	a0,0
ffffffffc0200342:	0141                	addi	sp,sp,16
ffffffffc0200344:	8082                	ret

ffffffffc0200346 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200346:	7115                	addi	sp,sp,-224
ffffffffc0200348:	e962                	sd	s8,144(sp)
ffffffffc020034a:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020034c:	00007517          	auipc	a0,0x7
ffffffffc0200350:	37c50513          	addi	a0,a0,892 # ffffffffc02076c8 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200354:	ed86                	sd	ra,216(sp)
ffffffffc0200356:	e9a2                	sd	s0,208(sp)
ffffffffc0200358:	e5a6                	sd	s1,200(sp)
ffffffffc020035a:	e1ca                	sd	s2,192(sp)
ffffffffc020035c:	fd4e                	sd	s3,184(sp)
ffffffffc020035e:	f952                	sd	s4,176(sp)
ffffffffc0200360:	f556                	sd	s5,168(sp)
ffffffffc0200362:	f15a                	sd	s6,160(sp)
ffffffffc0200364:	ed5e                	sd	s7,152(sp)
ffffffffc0200366:	e566                	sd	s9,136(sp)
ffffffffc0200368:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020036a:	e29ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020036e:	00007517          	auipc	a0,0x7
ffffffffc0200372:	38250513          	addi	a0,a0,898 # ffffffffc02076f0 <commands+0x70>
ffffffffc0200376:	e1dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    if (tf != NULL) {
ffffffffc020037a:	000c0563          	beqz	s8,ffffffffc0200384 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020037e:	8562                	mv	a0,s8
ffffffffc0200380:	4c2000ef          	jal	ra,ffffffffc0200842 <print_trapframe>
ffffffffc0200384:	00007c97          	auipc	s9,0x7
ffffffffc0200388:	2fcc8c93          	addi	s9,s9,764 # ffffffffc0207680 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020038c:	00007997          	auipc	s3,0x7
ffffffffc0200390:	38c98993          	addi	s3,s3,908 # ffffffffc0207718 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200394:	00007917          	auipc	s2,0x7
ffffffffc0200398:	38c90913          	addi	s2,s2,908 # ffffffffc0207720 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc020039c:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020039e:	00007b17          	auipc	s6,0x7
ffffffffc02003a2:	38ab0b13          	addi	s6,s6,906 # ffffffffc0207728 <commands+0xa8>
    if (argc == 0) {
ffffffffc02003a6:	00007a97          	auipc	s5,0x7
ffffffffc02003aa:	3daa8a93          	addi	s5,s5,986 # ffffffffc0207780 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ae:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003b0:	854e                	mv	a0,s3
ffffffffc02003b2:	ce9ff0ef          	jal	ra,ffffffffc020009a <readline>
ffffffffc02003b6:	842a                	mv	s0,a0
ffffffffc02003b8:	dd65                	beqz	a0,ffffffffc02003b0 <kmonitor+0x6a>
ffffffffc02003ba:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003be:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003c0:	c999                	beqz	a1,ffffffffc02003d6 <kmonitor+0x90>
ffffffffc02003c2:	854a                	mv	a0,s2
ffffffffc02003c4:	142070ef          	jal	ra,ffffffffc0207506 <strchr>
ffffffffc02003c8:	c925                	beqz	a0,ffffffffc0200438 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02003ca:	00144583          	lbu	a1,1(s0)
ffffffffc02003ce:	00040023          	sb	zero,0(s0)
ffffffffc02003d2:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003d4:	f5fd                	bnez	a1,ffffffffc02003c2 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02003d6:	dce9                	beqz	s1,ffffffffc02003b0 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003d8:	6582                	ld	a1,0(sp)
ffffffffc02003da:	00007d17          	auipc	s10,0x7
ffffffffc02003de:	2a6d0d13          	addi	s10,s10,678 # ffffffffc0207680 <commands>
    if (argc == 0) {
ffffffffc02003e2:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003e4:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003e6:	0d61                	addi	s10,s10,24
ffffffffc02003e8:	0f4070ef          	jal	ra,ffffffffc02074dc <strcmp>
ffffffffc02003ec:	c919                	beqz	a0,ffffffffc0200402 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ee:	2405                	addiw	s0,s0,1
ffffffffc02003f0:	09740463          	beq	s0,s7,ffffffffc0200478 <kmonitor+0x132>
ffffffffc02003f4:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003f8:	6582                	ld	a1,0(sp)
ffffffffc02003fa:	0d61                	addi	s10,s10,24
ffffffffc02003fc:	0e0070ef          	jal	ra,ffffffffc02074dc <strcmp>
ffffffffc0200400:	f57d                	bnez	a0,ffffffffc02003ee <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200402:	00141793          	slli	a5,s0,0x1
ffffffffc0200406:	97a2                	add	a5,a5,s0
ffffffffc0200408:	078e                	slli	a5,a5,0x3
ffffffffc020040a:	97e6                	add	a5,a5,s9
ffffffffc020040c:	6b9c                	ld	a5,16(a5)
ffffffffc020040e:	8662                	mv	a2,s8
ffffffffc0200410:	002c                	addi	a1,sp,8
ffffffffc0200412:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200416:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200418:	f8055ce3          	bgez	a0,ffffffffc02003b0 <kmonitor+0x6a>
}
ffffffffc020041c:	60ee                	ld	ra,216(sp)
ffffffffc020041e:	644e                	ld	s0,208(sp)
ffffffffc0200420:	64ae                	ld	s1,200(sp)
ffffffffc0200422:	690e                	ld	s2,192(sp)
ffffffffc0200424:	79ea                	ld	s3,184(sp)
ffffffffc0200426:	7a4a                	ld	s4,176(sp)
ffffffffc0200428:	7aaa                	ld	s5,168(sp)
ffffffffc020042a:	7b0a                	ld	s6,160(sp)
ffffffffc020042c:	6bea                	ld	s7,152(sp)
ffffffffc020042e:	6c4a                	ld	s8,144(sp)
ffffffffc0200430:	6caa                	ld	s9,136(sp)
ffffffffc0200432:	6d0a                	ld	s10,128(sp)
ffffffffc0200434:	612d                	addi	sp,sp,224
ffffffffc0200436:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200438:	00044783          	lbu	a5,0(s0)
ffffffffc020043c:	dfc9                	beqz	a5,ffffffffc02003d6 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020043e:	03448863          	beq	s1,s4,ffffffffc020046e <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc0200442:	00349793          	slli	a5,s1,0x3
ffffffffc0200446:	0118                	addi	a4,sp,128
ffffffffc0200448:	97ba                	add	a5,a5,a4
ffffffffc020044a:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020044e:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200452:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200454:	e591                	bnez	a1,ffffffffc0200460 <kmonitor+0x11a>
ffffffffc0200456:	b749                	j	ffffffffc02003d8 <kmonitor+0x92>
            buf ++;
ffffffffc0200458:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020045a:	00044583          	lbu	a1,0(s0)
ffffffffc020045e:	ddad                	beqz	a1,ffffffffc02003d8 <kmonitor+0x92>
ffffffffc0200460:	854a                	mv	a0,s2
ffffffffc0200462:	0a4070ef          	jal	ra,ffffffffc0207506 <strchr>
ffffffffc0200466:	d96d                	beqz	a0,ffffffffc0200458 <kmonitor+0x112>
ffffffffc0200468:	00044583          	lbu	a1,0(s0)
ffffffffc020046c:	bf91                	j	ffffffffc02003c0 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020046e:	45c1                	li	a1,16
ffffffffc0200470:	855a                	mv	a0,s6
ffffffffc0200472:	d21ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc0200476:	b7f1                	j	ffffffffc0200442 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200478:	6582                	ld	a1,0(sp)
ffffffffc020047a:	00007517          	auipc	a0,0x7
ffffffffc020047e:	2ce50513          	addi	a0,a0,718 # ffffffffc0207748 <commands+0xc8>
ffffffffc0200482:	d11ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    return 0;
ffffffffc0200486:	b72d                	j	ffffffffc02003b0 <kmonitor+0x6a>

ffffffffc0200488 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200488:	000df317          	auipc	t1,0xdf
ffffffffc020048c:	ea830313          	addi	t1,t1,-344 # ffffffffc02df330 <is_panic>
ffffffffc0200490:	00033303          	ld	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200494:	715d                	addi	sp,sp,-80
ffffffffc0200496:	ec06                	sd	ra,24(sp)
ffffffffc0200498:	e822                	sd	s0,16(sp)
ffffffffc020049a:	f436                	sd	a3,40(sp)
ffffffffc020049c:	f83a                	sd	a4,48(sp)
ffffffffc020049e:	fc3e                	sd	a5,56(sp)
ffffffffc02004a0:	e0c2                	sd	a6,64(sp)
ffffffffc02004a2:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02004a4:	02031c63          	bnez	t1,ffffffffc02004dc <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02004a8:	4785                	li	a5,1
ffffffffc02004aa:	8432                	mv	s0,a2
ffffffffc02004ac:	000df717          	auipc	a4,0xdf
ffffffffc02004b0:	e8f73223          	sd	a5,-380(a4) # ffffffffc02df330 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b4:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02004b6:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b8:	85aa                	mv	a1,a0
ffffffffc02004ba:	00007517          	auipc	a0,0x7
ffffffffc02004be:	34650513          	addi	a0,a0,838 # ffffffffc0207800 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02004c2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004c4:	ccfff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004c8:	65a2                	ld	a1,8(sp)
ffffffffc02004ca:	8522                	mv	a0,s0
ffffffffc02004cc:	ca7ff0ef          	jal	ra,ffffffffc0200172 <vcprintf>
    cprintf("\n");
ffffffffc02004d0:	00008517          	auipc	a0,0x8
ffffffffc02004d4:	2e850513          	addi	a0,a0,744 # ffffffffc02087b8 <default_pmm_manager+0x530>
ffffffffc02004d8:	cbbff0ef          	jal	ra,ffffffffc0200192 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004dc:	4501                	li	a0,0
ffffffffc02004de:	4581                	li	a1,0
ffffffffc02004e0:	4601                	li	a2,0
ffffffffc02004e2:	48a1                	li	a7,8
ffffffffc02004e4:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004e8:	16a000ef          	jal	ra,ffffffffc0200652 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004ec:	4501                	li	a0,0
ffffffffc02004ee:	e59ff0ef          	jal	ra,ffffffffc0200346 <kmonitor>
ffffffffc02004f2:	bfed                	j	ffffffffc02004ec <__panic+0x64>

ffffffffc02004f4 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004f4:	715d                	addi	sp,sp,-80
ffffffffc02004f6:	e822                	sd	s0,16(sp)
ffffffffc02004f8:	fc3e                	sd	a5,56(sp)
ffffffffc02004fa:	8432                	mv	s0,a2
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004fc:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004fe:	862e                	mv	a2,a1
ffffffffc0200500:	85aa                	mv	a1,a0
ffffffffc0200502:	00007517          	auipc	a0,0x7
ffffffffc0200506:	31e50513          	addi	a0,a0,798 # ffffffffc0207820 <commands+0x1a0>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc020050a:	ec06                	sd	ra,24(sp)
ffffffffc020050c:	f436                	sd	a3,40(sp)
ffffffffc020050e:	f83a                	sd	a4,48(sp)
ffffffffc0200510:	e0c2                	sd	a6,64(sp)
ffffffffc0200512:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200514:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200516:	c7dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020051a:	65a2                	ld	a1,8(sp)
ffffffffc020051c:	8522                	mv	a0,s0
ffffffffc020051e:	c55ff0ef          	jal	ra,ffffffffc0200172 <vcprintf>
    cprintf("\n");
ffffffffc0200522:	00008517          	auipc	a0,0x8
ffffffffc0200526:	29650513          	addi	a0,a0,662 # ffffffffc02087b8 <default_pmm_manager+0x530>
ffffffffc020052a:	c69ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    va_end(ap);
}
ffffffffc020052e:	60e2                	ld	ra,24(sp)
ffffffffc0200530:	6442                	ld	s0,16(sp)
ffffffffc0200532:	6161                	addi	sp,sp,80
ffffffffc0200534:	8082                	ret

ffffffffc0200536 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    set_csr(sie, MIP_STIP);
ffffffffc0200536:	02000793          	li	a5,32
ffffffffc020053a:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020053e:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200542:	67e1                	lui	a5,0x18
ffffffffc0200544:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_matrix_out_size+0xca60>
ffffffffc0200548:	953e                	add	a0,a0,a5
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020054a:	4581                	li	a1,0
ffffffffc020054c:	4601                	li	a2,0
ffffffffc020054e:	4881                	li	a7,0
ffffffffc0200550:	00000073          	ecall
    cprintf("++ setup timer interrupts\n");
ffffffffc0200554:	00007517          	auipc	a0,0x7
ffffffffc0200558:	2ec50513          	addi	a0,a0,748 # ffffffffc0207840 <commands+0x1c0>
    ticks = 0;
ffffffffc020055c:	000df797          	auipc	a5,0xdf
ffffffffc0200560:	e207ba23          	sd	zero,-460(a5) # ffffffffc02df390 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200564:	c2fff06f          	j	ffffffffc0200192 <cprintf>

ffffffffc0200568 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200568:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020056c:	67e1                	lui	a5,0x18
ffffffffc020056e:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_matrix_out_size+0xca60>
ffffffffc0200572:	953e                	add	a0,a0,a5
ffffffffc0200574:	4581                	li	a1,0
ffffffffc0200576:	4601                	li	a2,0
ffffffffc0200578:	4881                	li	a7,0
ffffffffc020057a:	00000073          	ecall
ffffffffc020057e:	8082                	ret

ffffffffc0200580 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <cons_putc>:
#include <riscv.h>
#include <assert.h>
#include <atomic.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200582:	100027f3          	csrr	a5,sstatus
ffffffffc0200586:	8b89                	andi	a5,a5,2
ffffffffc0200588:	0ff57513          	andi	a0,a0,255
ffffffffc020058c:	e799                	bnez	a5,ffffffffc020059a <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020058e:	4581                	li	a1,0
ffffffffc0200590:	4601                	li	a2,0
ffffffffc0200592:	4885                	li	a7,1
ffffffffc0200594:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200598:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020059a:	1101                	addi	sp,sp,-32
ffffffffc020059c:	ec06                	sd	ra,24(sp)
ffffffffc020059e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005a0:	0b2000ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc02005a4:	6522                	ld	a0,8(sp)
ffffffffc02005a6:	4581                	li	a1,0
ffffffffc02005a8:	4601                	li	a2,0
ffffffffc02005aa:	4885                	li	a7,1
ffffffffc02005ac:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005b0:	60e2                	ld	ra,24(sp)
ffffffffc02005b2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005b4:	0980006f          	j	ffffffffc020064c <intr_enable>

ffffffffc02005b8 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005b8:	100027f3          	csrr	a5,sstatus
ffffffffc02005bc:	8b89                	andi	a5,a5,2
ffffffffc02005be:	eb89                	bnez	a5,ffffffffc02005d0 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005c0:	4501                	li	a0,0
ffffffffc02005c2:	4581                	li	a1,0
ffffffffc02005c4:	4601                	li	a2,0
ffffffffc02005c6:	4889                	li	a7,2
ffffffffc02005c8:	00000073          	ecall
ffffffffc02005cc:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005ce:	8082                	ret
int cons_getc(void) {
ffffffffc02005d0:	1101                	addi	sp,sp,-32
ffffffffc02005d2:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005d4:	07e000ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc02005d8:	4501                	li	a0,0
ffffffffc02005da:	4581                	li	a1,0
ffffffffc02005dc:	4601                	li	a2,0
ffffffffc02005de:	4889                	li	a7,2
ffffffffc02005e0:	00000073          	ecall
ffffffffc02005e4:	2501                	sext.w	a0,a0
ffffffffc02005e6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005e8:	064000ef          	jal	ra,ffffffffc020064c <intr_enable>
}
ffffffffc02005ec:	60e2                	ld	ra,24(sp)
ffffffffc02005ee:	6522                	ld	a0,8(sp)
ffffffffc02005f0:	6105                	addi	sp,sp,32
ffffffffc02005f2:	8082                	ret

ffffffffc02005f4 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02005f4:	8082                	ret

ffffffffc02005f6 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02005f6:	00253513          	sltiu	a0,a0,2
ffffffffc02005fa:	8082                	ret

ffffffffc02005fc <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02005fc:	03800513          	li	a0,56
ffffffffc0200600:	8082                	ret

ffffffffc0200602 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200602:	000d4797          	auipc	a5,0xd4
ffffffffc0200606:	cfe78793          	addi	a5,a5,-770 # ffffffffc02d4300 <ide>
ffffffffc020060a:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc020060e:	1141                	addi	sp,sp,-16
ffffffffc0200610:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200612:	95be                	add	a1,a1,a5
ffffffffc0200614:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200618:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020061a:	71d060ef          	jal	ra,ffffffffc0207536 <memcpy>
    return 0;
}
ffffffffc020061e:	60a2                	ld	ra,8(sp)
ffffffffc0200620:	4501                	li	a0,0
ffffffffc0200622:	0141                	addi	sp,sp,16
ffffffffc0200624:	8082                	ret

ffffffffc0200626 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200626:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200628:	0095979b          	slliw	a5,a1,0x9
ffffffffc020062c:	000d4517          	auipc	a0,0xd4
ffffffffc0200630:	cd450513          	addi	a0,a0,-812 # ffffffffc02d4300 <ide>
                   size_t nsecs) {
ffffffffc0200634:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200636:	00969613          	slli	a2,a3,0x9
ffffffffc020063a:	85ba                	mv	a1,a4
ffffffffc020063c:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc020063e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200640:	6f7060ef          	jal	ra,ffffffffc0207536 <memcpy>
    return 0;
}
ffffffffc0200644:	60a2                	ld	ra,8(sp)
ffffffffc0200646:	4501                	li	a0,0
ffffffffc0200648:	0141                	addi	sp,sp,16
ffffffffc020064a:	8082                	ret

ffffffffc020064c <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020064c:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200650:	8082                	ret

ffffffffc0200652 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200652:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200656:	8082                	ret

ffffffffc0200658 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200658:	8082                	ret

ffffffffc020065a <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020065a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020065e:	00000797          	auipc	a5,0x0
ffffffffc0200662:	68e78793          	addi	a5,a5,1678 # ffffffffc0200cec <__alltraps>
ffffffffc0200666:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020066a:	000407b7          	lui	a5,0x40
ffffffffc020066e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200672:	8082                	ret

ffffffffc0200674 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200674:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc0200676:	1141                	addi	sp,sp,-16
ffffffffc0200678:	e022                	sd	s0,0(sp)
ffffffffc020067a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067c:	00007517          	auipc	a0,0x7
ffffffffc0200680:	50c50513          	addi	a0,a0,1292 # ffffffffc0207b88 <commands+0x508>
void print_regs(struct pushregs* gpr) {
ffffffffc0200684:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200686:	b0dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020068a:	640c                	ld	a1,8(s0)
ffffffffc020068c:	00007517          	auipc	a0,0x7
ffffffffc0200690:	51450513          	addi	a0,a0,1300 # ffffffffc0207ba0 <commands+0x520>
ffffffffc0200694:	affff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200698:	680c                	ld	a1,16(s0)
ffffffffc020069a:	00007517          	auipc	a0,0x7
ffffffffc020069e:	51e50513          	addi	a0,a0,1310 # ffffffffc0207bb8 <commands+0x538>
ffffffffc02006a2:	af1ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02006a6:	6c0c                	ld	a1,24(s0)
ffffffffc02006a8:	00007517          	auipc	a0,0x7
ffffffffc02006ac:	52850513          	addi	a0,a0,1320 # ffffffffc0207bd0 <commands+0x550>
ffffffffc02006b0:	ae3ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006b4:	700c                	ld	a1,32(s0)
ffffffffc02006b6:	00007517          	auipc	a0,0x7
ffffffffc02006ba:	53250513          	addi	a0,a0,1330 # ffffffffc0207be8 <commands+0x568>
ffffffffc02006be:	ad5ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006c2:	740c                	ld	a1,40(s0)
ffffffffc02006c4:	00007517          	auipc	a0,0x7
ffffffffc02006c8:	53c50513          	addi	a0,a0,1340 # ffffffffc0207c00 <commands+0x580>
ffffffffc02006cc:	ac7ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006d0:	780c                	ld	a1,48(s0)
ffffffffc02006d2:	00007517          	auipc	a0,0x7
ffffffffc02006d6:	54650513          	addi	a0,a0,1350 # ffffffffc0207c18 <commands+0x598>
ffffffffc02006da:	ab9ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006de:	7c0c                	ld	a1,56(s0)
ffffffffc02006e0:	00007517          	auipc	a0,0x7
ffffffffc02006e4:	55050513          	addi	a0,a0,1360 # ffffffffc0207c30 <commands+0x5b0>
ffffffffc02006e8:	aabff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006ec:	602c                	ld	a1,64(s0)
ffffffffc02006ee:	00007517          	auipc	a0,0x7
ffffffffc02006f2:	55a50513          	addi	a0,a0,1370 # ffffffffc0207c48 <commands+0x5c8>
ffffffffc02006f6:	a9dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006fa:	642c                	ld	a1,72(s0)
ffffffffc02006fc:	00007517          	auipc	a0,0x7
ffffffffc0200700:	56450513          	addi	a0,a0,1380 # ffffffffc0207c60 <commands+0x5e0>
ffffffffc0200704:	a8fff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200708:	682c                	ld	a1,80(s0)
ffffffffc020070a:	00007517          	auipc	a0,0x7
ffffffffc020070e:	56e50513          	addi	a0,a0,1390 # ffffffffc0207c78 <commands+0x5f8>
ffffffffc0200712:	a81ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200716:	6c2c                	ld	a1,88(s0)
ffffffffc0200718:	00007517          	auipc	a0,0x7
ffffffffc020071c:	57850513          	addi	a0,a0,1400 # ffffffffc0207c90 <commands+0x610>
ffffffffc0200720:	a73ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200724:	702c                	ld	a1,96(s0)
ffffffffc0200726:	00007517          	auipc	a0,0x7
ffffffffc020072a:	58250513          	addi	a0,a0,1410 # ffffffffc0207ca8 <commands+0x628>
ffffffffc020072e:	a65ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200732:	742c                	ld	a1,104(s0)
ffffffffc0200734:	00007517          	auipc	a0,0x7
ffffffffc0200738:	58c50513          	addi	a0,a0,1420 # ffffffffc0207cc0 <commands+0x640>
ffffffffc020073c:	a57ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200740:	782c                	ld	a1,112(s0)
ffffffffc0200742:	00007517          	auipc	a0,0x7
ffffffffc0200746:	59650513          	addi	a0,a0,1430 # ffffffffc0207cd8 <commands+0x658>
ffffffffc020074a:	a49ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020074e:	7c2c                	ld	a1,120(s0)
ffffffffc0200750:	00007517          	auipc	a0,0x7
ffffffffc0200754:	5a050513          	addi	a0,a0,1440 # ffffffffc0207cf0 <commands+0x670>
ffffffffc0200758:	a3bff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020075c:	604c                	ld	a1,128(s0)
ffffffffc020075e:	00007517          	auipc	a0,0x7
ffffffffc0200762:	5aa50513          	addi	a0,a0,1450 # ffffffffc0207d08 <commands+0x688>
ffffffffc0200766:	a2dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020076a:	644c                	ld	a1,136(s0)
ffffffffc020076c:	00007517          	auipc	a0,0x7
ffffffffc0200770:	5b450513          	addi	a0,a0,1460 # ffffffffc0207d20 <commands+0x6a0>
ffffffffc0200774:	a1fff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200778:	684c                	ld	a1,144(s0)
ffffffffc020077a:	00007517          	auipc	a0,0x7
ffffffffc020077e:	5be50513          	addi	a0,a0,1470 # ffffffffc0207d38 <commands+0x6b8>
ffffffffc0200782:	a11ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200786:	6c4c                	ld	a1,152(s0)
ffffffffc0200788:	00007517          	auipc	a0,0x7
ffffffffc020078c:	5c850513          	addi	a0,a0,1480 # ffffffffc0207d50 <commands+0x6d0>
ffffffffc0200790:	a03ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200794:	704c                	ld	a1,160(s0)
ffffffffc0200796:	00007517          	auipc	a0,0x7
ffffffffc020079a:	5d250513          	addi	a0,a0,1490 # ffffffffc0207d68 <commands+0x6e8>
ffffffffc020079e:	9f5ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02007a2:	744c                	ld	a1,168(s0)
ffffffffc02007a4:	00007517          	auipc	a0,0x7
ffffffffc02007a8:	5dc50513          	addi	a0,a0,1500 # ffffffffc0207d80 <commands+0x700>
ffffffffc02007ac:	9e7ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007b0:	784c                	ld	a1,176(s0)
ffffffffc02007b2:	00007517          	auipc	a0,0x7
ffffffffc02007b6:	5e650513          	addi	a0,a0,1510 # ffffffffc0207d98 <commands+0x718>
ffffffffc02007ba:	9d9ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007be:	7c4c                	ld	a1,184(s0)
ffffffffc02007c0:	00007517          	auipc	a0,0x7
ffffffffc02007c4:	5f050513          	addi	a0,a0,1520 # ffffffffc0207db0 <commands+0x730>
ffffffffc02007c8:	9cbff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007cc:	606c                	ld	a1,192(s0)
ffffffffc02007ce:	00007517          	auipc	a0,0x7
ffffffffc02007d2:	5fa50513          	addi	a0,a0,1530 # ffffffffc0207dc8 <commands+0x748>
ffffffffc02007d6:	9bdff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007da:	646c                	ld	a1,200(s0)
ffffffffc02007dc:	00007517          	auipc	a0,0x7
ffffffffc02007e0:	60450513          	addi	a0,a0,1540 # ffffffffc0207de0 <commands+0x760>
ffffffffc02007e4:	9afff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007e8:	686c                	ld	a1,208(s0)
ffffffffc02007ea:	00007517          	auipc	a0,0x7
ffffffffc02007ee:	60e50513          	addi	a0,a0,1550 # ffffffffc0207df8 <commands+0x778>
ffffffffc02007f2:	9a1ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007f6:	6c6c                	ld	a1,216(s0)
ffffffffc02007f8:	00007517          	auipc	a0,0x7
ffffffffc02007fc:	61850513          	addi	a0,a0,1560 # ffffffffc0207e10 <commands+0x790>
ffffffffc0200800:	993ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200804:	706c                	ld	a1,224(s0)
ffffffffc0200806:	00007517          	auipc	a0,0x7
ffffffffc020080a:	62250513          	addi	a0,a0,1570 # ffffffffc0207e28 <commands+0x7a8>
ffffffffc020080e:	985ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200812:	746c                	ld	a1,232(s0)
ffffffffc0200814:	00007517          	auipc	a0,0x7
ffffffffc0200818:	62c50513          	addi	a0,a0,1580 # ffffffffc0207e40 <commands+0x7c0>
ffffffffc020081c:	977ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200820:	786c                	ld	a1,240(s0)
ffffffffc0200822:	00007517          	auipc	a0,0x7
ffffffffc0200826:	63650513          	addi	a0,a0,1590 # ffffffffc0207e58 <commands+0x7d8>
ffffffffc020082a:	969ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200830:	6402                	ld	s0,0(sp)
ffffffffc0200832:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200834:	00007517          	auipc	a0,0x7
ffffffffc0200838:	63c50513          	addi	a0,a0,1596 # ffffffffc0207e70 <commands+0x7f0>
}
ffffffffc020083c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020083e:	955ff06f          	j	ffffffffc0200192 <cprintf>

ffffffffc0200842 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200842:	1141                	addi	sp,sp,-16
ffffffffc0200844:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200846:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200848:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020084a:	00007517          	auipc	a0,0x7
ffffffffc020084e:	63e50513          	addi	a0,a0,1598 # ffffffffc0207e88 <commands+0x808>
print_trapframe(struct trapframe *tf) {
ffffffffc0200852:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200854:	93fff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200858:	8522                	mv	a0,s0
ffffffffc020085a:	e1bff0ef          	jal	ra,ffffffffc0200674 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020085e:	10043583          	ld	a1,256(s0)
ffffffffc0200862:	00007517          	auipc	a0,0x7
ffffffffc0200866:	63e50513          	addi	a0,a0,1598 # ffffffffc0207ea0 <commands+0x820>
ffffffffc020086a:	929ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020086e:	10843583          	ld	a1,264(s0)
ffffffffc0200872:	00007517          	auipc	a0,0x7
ffffffffc0200876:	64650513          	addi	a0,a0,1606 # ffffffffc0207eb8 <commands+0x838>
ffffffffc020087a:	919ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc020087e:	11043583          	ld	a1,272(s0)
ffffffffc0200882:	00007517          	auipc	a0,0x7
ffffffffc0200886:	64e50513          	addi	a0,a0,1614 # ffffffffc0207ed0 <commands+0x850>
ffffffffc020088a:	909ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200892:	6402                	ld	s0,0(sp)
ffffffffc0200894:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200896:	00007517          	auipc	a0,0x7
ffffffffc020089a:	64a50513          	addi	a0,a0,1610 # ffffffffc0207ee0 <commands+0x860>
}
ffffffffc020089e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02008a0:	8f3ff06f          	j	ffffffffc0200192 <cprintf>

ffffffffc02008a4 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc02008a4:	1101                	addi	sp,sp,-32
ffffffffc02008a6:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008a8:	000df497          	auipc	s1,0xdf
ffffffffc02008ac:	c0048493          	addi	s1,s1,-1024 # ffffffffc02df4a8 <check_mm_struct>
ffffffffc02008b0:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008b2:	e822                	sd	s0,16(sp)
ffffffffc02008b4:	ec06                	sd	ra,24(sp)
ffffffffc02008b6:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008b8:	cbbd                	beqz	a5,ffffffffc020092e <pgfault_handler+0x8a>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ba:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008be:	11053583          	ld	a1,272(a0)
ffffffffc02008c2:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008c6:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008ca:	cba1                	beqz	a5,ffffffffc020091a <pgfault_handler+0x76>
ffffffffc02008cc:	11843703          	ld	a4,280(s0)
ffffffffc02008d0:	47bd                	li	a5,15
ffffffffc02008d2:	05700693          	li	a3,87
ffffffffc02008d6:	00f70463          	beq	a4,a5,ffffffffc02008de <pgfault_handler+0x3a>
ffffffffc02008da:	05200693          	li	a3,82
ffffffffc02008de:	00007517          	auipc	a0,0x7
ffffffffc02008e2:	22a50513          	addi	a0,a0,554 # ffffffffc0207b08 <commands+0x488>
ffffffffc02008e6:	8adff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008ea:	6088                	ld	a0,0(s1)
ffffffffc02008ec:	c129                	beqz	a0,ffffffffc020092e <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008ee:	000df797          	auipc	a5,0xdf
ffffffffc02008f2:	a7278793          	addi	a5,a5,-1422 # ffffffffc02df360 <current>
ffffffffc02008f6:	6398                	ld	a4,0(a5)
ffffffffc02008f8:	000df797          	auipc	a5,0xdf
ffffffffc02008fc:	a7078793          	addi	a5,a5,-1424 # ffffffffc02df368 <idleproc>
ffffffffc0200900:	639c                	ld	a5,0(a5)
ffffffffc0200902:	04f71763          	bne	a4,a5,ffffffffc0200950 <pgfault_handler+0xac>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200906:	11043603          	ld	a2,272(s0)
ffffffffc020090a:	11843583          	ld	a1,280(s0)
}
ffffffffc020090e:	6442                	ld	s0,16(sp)
ffffffffc0200910:	60e2                	ld	ra,24(sp)
ffffffffc0200912:	64a2                	ld	s1,8(sp)
ffffffffc0200914:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200916:	0a40406f          	j	ffffffffc02049ba <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020091a:	11843703          	ld	a4,280(s0)
ffffffffc020091e:	47bd                	li	a5,15
ffffffffc0200920:	05500613          	li	a2,85
ffffffffc0200924:	05700693          	li	a3,87
ffffffffc0200928:	faf719e3          	bne	a4,a5,ffffffffc02008da <pgfault_handler+0x36>
ffffffffc020092c:	bf4d                	j	ffffffffc02008de <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc020092e:	000df797          	auipc	a5,0xdf
ffffffffc0200932:	a3278793          	addi	a5,a5,-1486 # ffffffffc02df360 <current>
ffffffffc0200936:	639c                	ld	a5,0(a5)
ffffffffc0200938:	cf85                	beqz	a5,ffffffffc0200970 <pgfault_handler+0xcc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020093a:	11043603          	ld	a2,272(s0)
ffffffffc020093e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200942:	6442                	ld	s0,16(sp)
ffffffffc0200944:	60e2                	ld	ra,24(sp)
ffffffffc0200946:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200948:	7788                	ld	a0,40(a5)
}
ffffffffc020094a:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020094c:	06e0406f          	j	ffffffffc02049ba <do_pgfault>
        assert(current == idleproc);
ffffffffc0200950:	00007697          	auipc	a3,0x7
ffffffffc0200954:	1d868693          	addi	a3,a3,472 # ffffffffc0207b28 <commands+0x4a8>
ffffffffc0200958:	00007617          	auipc	a2,0x7
ffffffffc020095c:	1e860613          	addi	a2,a2,488 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0200960:	06c00593          	li	a1,108
ffffffffc0200964:	00007517          	auipc	a0,0x7
ffffffffc0200968:	1f450513          	addi	a0,a0,500 # ffffffffc0207b58 <commands+0x4d8>
ffffffffc020096c:	b1dff0ef          	jal	ra,ffffffffc0200488 <__panic>
            print_trapframe(tf);
ffffffffc0200970:	8522                	mv	a0,s0
ffffffffc0200972:	ed1ff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200976:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020097a:	11043583          	ld	a1,272(s0)
ffffffffc020097e:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200982:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200986:	e399                	bnez	a5,ffffffffc020098c <pgfault_handler+0xe8>
ffffffffc0200988:	05500613          	li	a2,85
ffffffffc020098c:	11843703          	ld	a4,280(s0)
ffffffffc0200990:	47bd                	li	a5,15
ffffffffc0200992:	02f70663          	beq	a4,a5,ffffffffc02009be <pgfault_handler+0x11a>
ffffffffc0200996:	05200693          	li	a3,82
ffffffffc020099a:	00007517          	auipc	a0,0x7
ffffffffc020099e:	16e50513          	addi	a0,a0,366 # ffffffffc0207b08 <commands+0x488>
ffffffffc02009a2:	ff0ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc02009a6:	00007617          	auipc	a2,0x7
ffffffffc02009aa:	1ca60613          	addi	a2,a2,458 # ffffffffc0207b70 <commands+0x4f0>
ffffffffc02009ae:	07300593          	li	a1,115
ffffffffc02009b2:	00007517          	auipc	a0,0x7
ffffffffc02009b6:	1a650513          	addi	a0,a0,422 # ffffffffc0207b58 <commands+0x4d8>
ffffffffc02009ba:	acfff0ef          	jal	ra,ffffffffc0200488 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009be:	05700693          	li	a3,87
ffffffffc02009c2:	bfe1                	j	ffffffffc020099a <pgfault_handler+0xf6>

ffffffffc02009c4 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009c4:	11853783          	ld	a5,280(a0)
ffffffffc02009c8:	577d                	li	a4,-1
ffffffffc02009ca:	8305                	srli	a4,a4,0x1
ffffffffc02009cc:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02009ce:	472d                	li	a4,11
ffffffffc02009d0:	06f76b63          	bltu	a4,a5,ffffffffc0200a46 <interrupt_handler+0x82>
ffffffffc02009d4:	00007717          	auipc	a4,0x7
ffffffffc02009d8:	e8870713          	addi	a4,a4,-376 # ffffffffc020785c <commands+0x1dc>
ffffffffc02009dc:	078a                	slli	a5,a5,0x2
ffffffffc02009de:	97ba                	add	a5,a5,a4
ffffffffc02009e0:	439c                	lw	a5,0(a5)
ffffffffc02009e2:	97ba                	add	a5,a5,a4
ffffffffc02009e4:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009e6:	00007517          	auipc	a0,0x7
ffffffffc02009ea:	0e250513          	addi	a0,a0,226 # ffffffffc0207ac8 <commands+0x448>
ffffffffc02009ee:	fa4ff06f          	j	ffffffffc0200192 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009f2:	00007517          	auipc	a0,0x7
ffffffffc02009f6:	0b650513          	addi	a0,a0,182 # ffffffffc0207aa8 <commands+0x428>
ffffffffc02009fa:	f98ff06f          	j	ffffffffc0200192 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009fe:	00007517          	auipc	a0,0x7
ffffffffc0200a02:	06a50513          	addi	a0,a0,106 # ffffffffc0207a68 <commands+0x3e8>
ffffffffc0200a06:	f8cff06f          	j	ffffffffc0200192 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a0a:	00007517          	auipc	a0,0x7
ffffffffc0200a0e:	07e50513          	addi	a0,a0,126 # ffffffffc0207a88 <commands+0x408>
ffffffffc0200a12:	f80ff06f          	j	ffffffffc0200192 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a16:	00007517          	auipc	a0,0x7
ffffffffc0200a1a:	0d250513          	addi	a0,a0,210 # ffffffffc0207ae8 <commands+0x468>
ffffffffc0200a1e:	f74ff06f          	j	ffffffffc0200192 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a22:	1141                	addi	sp,sp,-16
ffffffffc0200a24:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a26:	b43ff0ef          	jal	ra,ffffffffc0200568 <clock_set_next_event>
            ++ticks;
ffffffffc0200a2a:	000df797          	auipc	a5,0xdf
ffffffffc0200a2e:	96678793          	addi	a5,a5,-1690 # ffffffffc02df390 <ticks>
ffffffffc0200a32:	639c                	ld	a5,0(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a34:	60a2                	ld	ra,8(sp)
            ++ticks;
ffffffffc0200a36:	0785                	addi	a5,a5,1
ffffffffc0200a38:	000df717          	auipc	a4,0xdf
ffffffffc0200a3c:	94f73c23          	sd	a5,-1704(a4) # ffffffffc02df390 <ticks>
}
ffffffffc0200a40:	0141                	addi	sp,sp,16
            run_timer_list();//lab7
ffffffffc0200a42:	3e00606f          	j	ffffffffc0206e22 <run_timer_list>
            print_trapframe(tf);
ffffffffc0200a46:	dfdff06f          	j	ffffffffc0200842 <print_trapframe>

ffffffffc0200a4a <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a4a:	11853783          	ld	a5,280(a0)
ffffffffc0200a4e:	473d                	li	a4,15
ffffffffc0200a50:	1ef76563          	bltu	a4,a5,ffffffffc0200c3a <exception_handler+0x1f0>
ffffffffc0200a54:	00007717          	auipc	a4,0x7
ffffffffc0200a58:	e3870713          	addi	a4,a4,-456 # ffffffffc020788c <commands+0x20c>
ffffffffc0200a5c:	078a                	slli	a5,a5,0x2
ffffffffc0200a5e:	97ba                	add	a5,a5,a4
ffffffffc0200a60:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a62:	1101                	addi	sp,sp,-32
ffffffffc0200a64:	e822                	sd	s0,16(sp)
ffffffffc0200a66:	ec06                	sd	ra,24(sp)
ffffffffc0200a68:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a6a:	97ba                	add	a5,a5,a4
ffffffffc0200a6c:	842a                	mv	s0,a0
ffffffffc0200a6e:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a70:	00007517          	auipc	a0,0x7
ffffffffc0200a74:	f5050513          	addi	a0,a0,-176 # ffffffffc02079c0 <commands+0x340>
ffffffffc0200a78:	f1aff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            tf->epc += 4;
ffffffffc0200a7c:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a80:	60e2                	ld	ra,24(sp)
ffffffffc0200a82:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a84:	0791                	addi	a5,a5,4
ffffffffc0200a86:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a8a:	6442                	ld	s0,16(sp)
ffffffffc0200a8c:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a8e:	5660606f          	j	ffffffffc0206ff4 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a92:	00007517          	auipc	a0,0x7
ffffffffc0200a96:	f4e50513          	addi	a0,a0,-178 # ffffffffc02079e0 <commands+0x360>
}
ffffffffc0200a9a:	6442                	ld	s0,16(sp)
ffffffffc0200a9c:	60e2                	ld	ra,24(sp)
ffffffffc0200a9e:	64a2                	ld	s1,8(sp)
ffffffffc0200aa0:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200aa2:	ef0ff06f          	j	ffffffffc0200192 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200aa6:	00007517          	auipc	a0,0x7
ffffffffc0200aaa:	f5a50513          	addi	a0,a0,-166 # ffffffffc0207a00 <commands+0x380>
ffffffffc0200aae:	b7f5                	j	ffffffffc0200a9a <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ab0:	00007517          	auipc	a0,0x7
ffffffffc0200ab4:	f7050513          	addi	a0,a0,-144 # ffffffffc0207a20 <commands+0x3a0>
ffffffffc0200ab8:	edaff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200abc:	8522                	mv	a0,s0
ffffffffc0200abe:	de7ff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200ac2:	84aa                	mv	s1,a0
ffffffffc0200ac4:	16051d63          	bnez	a0,ffffffffc0200c3e <exception_handler+0x1f4>
}
ffffffffc0200ac8:	60e2                	ld	ra,24(sp)
ffffffffc0200aca:	6442                	ld	s0,16(sp)
ffffffffc0200acc:	64a2                	ld	s1,8(sp)
ffffffffc0200ace:	6105                	addi	sp,sp,32
ffffffffc0200ad0:	8082                	ret
            cprintf("Load page fault\n");
ffffffffc0200ad2:	00007517          	auipc	a0,0x7
ffffffffc0200ad6:	f6650513          	addi	a0,a0,-154 # ffffffffc0207a38 <commands+0x3b8>
ffffffffc0200ada:	eb8ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ade:	8522                	mv	a0,s0
ffffffffc0200ae0:	dc5ff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200ae4:	84aa                	mv	s1,a0
ffffffffc0200ae6:	d16d                	beqz	a0,ffffffffc0200ac8 <exception_handler+0x7e>
                print_trapframe(tf);
ffffffffc0200ae8:	8522                	mv	a0,s0
ffffffffc0200aea:	d59ff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200aee:	86a6                	mv	a3,s1
ffffffffc0200af0:	00007617          	auipc	a2,0x7
ffffffffc0200af4:	e8060613          	addi	a2,a2,-384 # ffffffffc0207970 <commands+0x2f0>
ffffffffc0200af8:	0f400593          	li	a1,244
ffffffffc0200afc:	00007517          	auipc	a0,0x7
ffffffffc0200b00:	05c50513          	addi	a0,a0,92 # ffffffffc0207b58 <commands+0x4d8>
ffffffffc0200b04:	985ff0ef          	jal	ra,ffffffffc0200488 <__panic>
            cprintf("Store/AMO page fault\n");
ffffffffc0200b08:	00007517          	auipc	a0,0x7
ffffffffc0200b0c:	f4850513          	addi	a0,a0,-184 # ffffffffc0207a50 <commands+0x3d0>
ffffffffc0200b10:	e82ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b14:	8522                	mv	a0,s0
ffffffffc0200b16:	d8fff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200b1a:	84aa                	mv	s1,a0
ffffffffc0200b1c:	d555                	beqz	a0,ffffffffc0200ac8 <exception_handler+0x7e>
                print_trapframe(tf);
ffffffffc0200b1e:	8522                	mv	a0,s0
ffffffffc0200b20:	d23ff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b24:	86a6                	mv	a3,s1
ffffffffc0200b26:	00007617          	auipc	a2,0x7
ffffffffc0200b2a:	e4a60613          	addi	a2,a2,-438 # ffffffffc0207970 <commands+0x2f0>
ffffffffc0200b2e:	0fb00593          	li	a1,251
ffffffffc0200b32:	00007517          	auipc	a0,0x7
ffffffffc0200b36:	02650513          	addi	a0,a0,38 # ffffffffc0207b58 <commands+0x4d8>
ffffffffc0200b3a:	94fff0ef          	jal	ra,ffffffffc0200488 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b3e:	00007517          	auipc	a0,0x7
ffffffffc0200b42:	d9250513          	addi	a0,a0,-622 # ffffffffc02078d0 <commands+0x250>
ffffffffc0200b46:	bf91                	j	ffffffffc0200a9a <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b48:	00007517          	auipc	a0,0x7
ffffffffc0200b4c:	da850513          	addi	a0,a0,-600 # ffffffffc02078f0 <commands+0x270>
ffffffffc0200b50:	b7a9                	j	ffffffffc0200a9a <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b52:	00007517          	auipc	a0,0x7
ffffffffc0200b56:	dbe50513          	addi	a0,a0,-578 # ffffffffc0207910 <commands+0x290>
ffffffffc0200b5a:	b781                	j	ffffffffc0200a9a <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b5c:	00007517          	auipc	a0,0x7
ffffffffc0200b60:	dcc50513          	addi	a0,a0,-564 # ffffffffc0207928 <commands+0x2a8>
ffffffffc0200b64:	e2eff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b68:	6458                	ld	a4,136(s0)
ffffffffc0200b6a:	47a9                	li	a5,10
ffffffffc0200b6c:	f4f71ee3          	bne	a4,a5,ffffffffc0200ac8 <exception_handler+0x7e>
                tf->epc += 4;
ffffffffc0200b70:	10843783          	ld	a5,264(s0)
ffffffffc0200b74:	0791                	addi	a5,a5,4
ffffffffc0200b76:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b7a:	47a060ef          	jal	ra,ffffffffc0206ff4 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b7e:	000de797          	auipc	a5,0xde
ffffffffc0200b82:	7e278793          	addi	a5,a5,2018 # ffffffffc02df360 <current>
ffffffffc0200b86:	639c                	ld	a5,0(a5)
ffffffffc0200b88:	8522                	mv	a0,s0
}
ffffffffc0200b8a:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b8c:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200b8e:	60e2                	ld	ra,24(sp)
ffffffffc0200b90:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b92:	6589                	lui	a1,0x2
ffffffffc0200b94:	95be                	add	a1,a1,a5
}
ffffffffc0200b96:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b98:	2220006f          	j	ffffffffc0200dba <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b9c:	00007517          	auipc	a0,0x7
ffffffffc0200ba0:	d9c50513          	addi	a0,a0,-612 # ffffffffc0207938 <commands+0x2b8>
ffffffffc0200ba4:	bddd                	j	ffffffffc0200a9a <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200ba6:	00007517          	auipc	a0,0x7
ffffffffc0200baa:	db250513          	addi	a0,a0,-590 # ffffffffc0207958 <commands+0x2d8>
ffffffffc0200bae:	de4ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bb2:	8522                	mv	a0,s0
ffffffffc0200bb4:	cf1ff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200bb8:	84aa                	mv	s1,a0
ffffffffc0200bba:	f00507e3          	beqz	a0,ffffffffc0200ac8 <exception_handler+0x7e>
                print_trapframe(tf);
ffffffffc0200bbe:	8522                	mv	a0,s0
ffffffffc0200bc0:	c83ff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bc4:	86a6                	mv	a3,s1
ffffffffc0200bc6:	00007617          	auipc	a2,0x7
ffffffffc0200bca:	daa60613          	addi	a2,a2,-598 # ffffffffc0207970 <commands+0x2f0>
ffffffffc0200bce:	0cc00593          	li	a1,204
ffffffffc0200bd2:	00007517          	auipc	a0,0x7
ffffffffc0200bd6:	f8650513          	addi	a0,a0,-122 # ffffffffc0207b58 <commands+0x4d8>
ffffffffc0200bda:	8afff0ef          	jal	ra,ffffffffc0200488 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bde:	00007517          	auipc	a0,0x7
ffffffffc0200be2:	dca50513          	addi	a0,a0,-566 # ffffffffc02079a8 <commands+0x328>
ffffffffc0200be6:	dacff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bea:	8522                	mv	a0,s0
ffffffffc0200bec:	cb9ff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200bf0:	84aa                	mv	s1,a0
ffffffffc0200bf2:	ec050be3          	beqz	a0,ffffffffc0200ac8 <exception_handler+0x7e>
                print_trapframe(tf);
ffffffffc0200bf6:	8522                	mv	a0,s0
ffffffffc0200bf8:	c4bff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bfc:	86a6                	mv	a3,s1
ffffffffc0200bfe:	00007617          	auipc	a2,0x7
ffffffffc0200c02:	d7260613          	addi	a2,a2,-654 # ffffffffc0207970 <commands+0x2f0>
ffffffffc0200c06:	0d600593          	li	a1,214
ffffffffc0200c0a:	00007517          	auipc	a0,0x7
ffffffffc0200c0e:	f4e50513          	addi	a0,a0,-178 # ffffffffc0207b58 <commands+0x4d8>
ffffffffc0200c12:	877ff0ef          	jal	ra,ffffffffc0200488 <__panic>
}
ffffffffc0200c16:	6442                	ld	s0,16(sp)
ffffffffc0200c18:	60e2                	ld	ra,24(sp)
ffffffffc0200c1a:	64a2                	ld	s1,8(sp)
ffffffffc0200c1c:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200c1e:	c25ff06f          	j	ffffffffc0200842 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200c22:	00007617          	auipc	a2,0x7
ffffffffc0200c26:	d6e60613          	addi	a2,a2,-658 # ffffffffc0207990 <commands+0x310>
ffffffffc0200c2a:	0d000593          	li	a1,208
ffffffffc0200c2e:	00007517          	auipc	a0,0x7
ffffffffc0200c32:	f2a50513          	addi	a0,a0,-214 # ffffffffc0207b58 <commands+0x4d8>
ffffffffc0200c36:	853ff0ef          	jal	ra,ffffffffc0200488 <__panic>
            print_trapframe(tf);
ffffffffc0200c3a:	c09ff06f          	j	ffffffffc0200842 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c3e:	8522                	mv	a0,s0
ffffffffc0200c40:	c03ff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c44:	86a6                	mv	a3,s1
ffffffffc0200c46:	00007617          	auipc	a2,0x7
ffffffffc0200c4a:	d2a60613          	addi	a2,a2,-726 # ffffffffc0207970 <commands+0x2f0>
ffffffffc0200c4e:	0ed00593          	li	a1,237
ffffffffc0200c52:	00007517          	auipc	a0,0x7
ffffffffc0200c56:	f0650513          	addi	a0,a0,-250 # ffffffffc0207b58 <commands+0x4d8>
ffffffffc0200c5a:	82fff0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0200c5e <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c5e:	1101                	addi	sp,sp,-32
ffffffffc0200c60:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c62:	000de417          	auipc	s0,0xde
ffffffffc0200c66:	6fe40413          	addi	s0,s0,1790 # ffffffffc02df360 <current>
ffffffffc0200c6a:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c6c:	ec06                	sd	ra,24(sp)
ffffffffc0200c6e:	e426                	sd	s1,8(sp)
ffffffffc0200c70:	e04a                	sd	s2,0(sp)
ffffffffc0200c72:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c76:	cf1d                	beqz	a4,ffffffffc0200cb4 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c78:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c7c:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c80:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c82:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c86:	0206c463          	bltz	a3,ffffffffc0200cae <trap+0x50>
        exception_handler(tf);
ffffffffc0200c8a:	dc1ff0ef          	jal	ra,ffffffffc0200a4a <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c8e:	601c                	ld	a5,0(s0)
ffffffffc0200c90:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c94:	e499                	bnez	s1,ffffffffc0200ca2 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c96:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c9a:	8b05                	andi	a4,a4,1
ffffffffc0200c9c:	e339                	bnez	a4,ffffffffc0200ce2 <trap+0x84>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c9e:	6f9c                	ld	a5,24(a5)
ffffffffc0200ca0:	eb95                	bnez	a5,ffffffffc0200cd4 <trap+0x76>
                schedule();
            }
        }
    }
}
ffffffffc0200ca2:	60e2                	ld	ra,24(sp)
ffffffffc0200ca4:	6442                	ld	s0,16(sp)
ffffffffc0200ca6:	64a2                	ld	s1,8(sp)
ffffffffc0200ca8:	6902                	ld	s2,0(sp)
ffffffffc0200caa:	6105                	addi	sp,sp,32
ffffffffc0200cac:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200cae:	d17ff0ef          	jal	ra,ffffffffc02009c4 <interrupt_handler>
ffffffffc0200cb2:	bff1                	j	ffffffffc0200c8e <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200cb4:	0006c963          	bltz	a3,ffffffffc0200cc6 <trap+0x68>
}
ffffffffc0200cb8:	6442                	ld	s0,16(sp)
ffffffffc0200cba:	60e2                	ld	ra,24(sp)
ffffffffc0200cbc:	64a2                	ld	s1,8(sp)
ffffffffc0200cbe:	6902                	ld	s2,0(sp)
ffffffffc0200cc0:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200cc2:	d89ff06f          	j	ffffffffc0200a4a <exception_handler>
}
ffffffffc0200cc6:	6442                	ld	s0,16(sp)
ffffffffc0200cc8:	60e2                	ld	ra,24(sp)
ffffffffc0200cca:	64a2                	ld	s1,8(sp)
ffffffffc0200ccc:	6902                	ld	s2,0(sp)
ffffffffc0200cce:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200cd0:	cf5ff06f          	j	ffffffffc02009c4 <interrupt_handler>
}
ffffffffc0200cd4:	6442                	ld	s0,16(sp)
ffffffffc0200cd6:	60e2                	ld	ra,24(sp)
ffffffffc0200cd8:	64a2                	ld	s1,8(sp)
ffffffffc0200cda:	6902                	ld	s2,0(sp)
ffffffffc0200cdc:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200cde:	72d0506f          	j	ffffffffc0206c0a <schedule>
                do_exit(-E_KILLED);
ffffffffc0200ce2:	555d                	li	a0,-9
ffffffffc0200ce4:	7d7040ef          	jal	ra,ffffffffc0205cba <do_exit>
ffffffffc0200ce8:	601c                	ld	a5,0(s0)
ffffffffc0200cea:	bf55                	j	ffffffffc0200c9e <trap+0x40>

ffffffffc0200cec <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200cec:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200cf0:	00011463          	bnez	sp,ffffffffc0200cf8 <__alltraps+0xc>
ffffffffc0200cf4:	14002173          	csrr	sp,sscratch
ffffffffc0200cf8:	712d                	addi	sp,sp,-288
ffffffffc0200cfa:	e002                	sd	zero,0(sp)
ffffffffc0200cfc:	e406                	sd	ra,8(sp)
ffffffffc0200cfe:	ec0e                	sd	gp,24(sp)
ffffffffc0200d00:	f012                	sd	tp,32(sp)
ffffffffc0200d02:	f416                	sd	t0,40(sp)
ffffffffc0200d04:	f81a                	sd	t1,48(sp)
ffffffffc0200d06:	fc1e                	sd	t2,56(sp)
ffffffffc0200d08:	e0a2                	sd	s0,64(sp)
ffffffffc0200d0a:	e4a6                	sd	s1,72(sp)
ffffffffc0200d0c:	e8aa                	sd	a0,80(sp)
ffffffffc0200d0e:	ecae                	sd	a1,88(sp)
ffffffffc0200d10:	f0b2                	sd	a2,96(sp)
ffffffffc0200d12:	f4b6                	sd	a3,104(sp)
ffffffffc0200d14:	f8ba                	sd	a4,112(sp)
ffffffffc0200d16:	fcbe                	sd	a5,120(sp)
ffffffffc0200d18:	e142                	sd	a6,128(sp)
ffffffffc0200d1a:	e546                	sd	a7,136(sp)
ffffffffc0200d1c:	e94a                	sd	s2,144(sp)
ffffffffc0200d1e:	ed4e                	sd	s3,152(sp)
ffffffffc0200d20:	f152                	sd	s4,160(sp)
ffffffffc0200d22:	f556                	sd	s5,168(sp)
ffffffffc0200d24:	f95a                	sd	s6,176(sp)
ffffffffc0200d26:	fd5e                	sd	s7,184(sp)
ffffffffc0200d28:	e1e2                	sd	s8,192(sp)
ffffffffc0200d2a:	e5e6                	sd	s9,200(sp)
ffffffffc0200d2c:	e9ea                	sd	s10,208(sp)
ffffffffc0200d2e:	edee                	sd	s11,216(sp)
ffffffffc0200d30:	f1f2                	sd	t3,224(sp)
ffffffffc0200d32:	f5f6                	sd	t4,232(sp)
ffffffffc0200d34:	f9fa                	sd	t5,240(sp)
ffffffffc0200d36:	fdfe                	sd	t6,248(sp)
ffffffffc0200d38:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d3c:	100024f3          	csrr	s1,sstatus
ffffffffc0200d40:	14102973          	csrr	s2,sepc
ffffffffc0200d44:	143029f3          	csrr	s3,stval
ffffffffc0200d48:	14202a73          	csrr	s4,scause
ffffffffc0200d4c:	e822                	sd	s0,16(sp)
ffffffffc0200d4e:	e226                	sd	s1,256(sp)
ffffffffc0200d50:	e64a                	sd	s2,264(sp)
ffffffffc0200d52:	ea4e                	sd	s3,272(sp)
ffffffffc0200d54:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d56:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d58:	f07ff0ef          	jal	ra,ffffffffc0200c5e <trap>

ffffffffc0200d5c <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d5c:	6492                	ld	s1,256(sp)
ffffffffc0200d5e:	6932                	ld	s2,264(sp)
ffffffffc0200d60:	1004f413          	andi	s0,s1,256
ffffffffc0200d64:	e401                	bnez	s0,ffffffffc0200d6c <__trapret+0x10>
ffffffffc0200d66:	1200                	addi	s0,sp,288
ffffffffc0200d68:	14041073          	csrw	sscratch,s0
ffffffffc0200d6c:	10049073          	csrw	sstatus,s1
ffffffffc0200d70:	14191073          	csrw	sepc,s2
ffffffffc0200d74:	60a2                	ld	ra,8(sp)
ffffffffc0200d76:	61e2                	ld	gp,24(sp)
ffffffffc0200d78:	7202                	ld	tp,32(sp)
ffffffffc0200d7a:	72a2                	ld	t0,40(sp)
ffffffffc0200d7c:	7342                	ld	t1,48(sp)
ffffffffc0200d7e:	73e2                	ld	t2,56(sp)
ffffffffc0200d80:	6406                	ld	s0,64(sp)
ffffffffc0200d82:	64a6                	ld	s1,72(sp)
ffffffffc0200d84:	6546                	ld	a0,80(sp)
ffffffffc0200d86:	65e6                	ld	a1,88(sp)
ffffffffc0200d88:	7606                	ld	a2,96(sp)
ffffffffc0200d8a:	76a6                	ld	a3,104(sp)
ffffffffc0200d8c:	7746                	ld	a4,112(sp)
ffffffffc0200d8e:	77e6                	ld	a5,120(sp)
ffffffffc0200d90:	680a                	ld	a6,128(sp)
ffffffffc0200d92:	68aa                	ld	a7,136(sp)
ffffffffc0200d94:	694a                	ld	s2,144(sp)
ffffffffc0200d96:	69ea                	ld	s3,152(sp)
ffffffffc0200d98:	7a0a                	ld	s4,160(sp)
ffffffffc0200d9a:	7aaa                	ld	s5,168(sp)
ffffffffc0200d9c:	7b4a                	ld	s6,176(sp)
ffffffffc0200d9e:	7bea                	ld	s7,184(sp)
ffffffffc0200da0:	6c0e                	ld	s8,192(sp)
ffffffffc0200da2:	6cae                	ld	s9,200(sp)
ffffffffc0200da4:	6d4e                	ld	s10,208(sp)
ffffffffc0200da6:	6dee                	ld	s11,216(sp)
ffffffffc0200da8:	7e0e                	ld	t3,224(sp)
ffffffffc0200daa:	7eae                	ld	t4,232(sp)
ffffffffc0200dac:	7f4e                	ld	t5,240(sp)
ffffffffc0200dae:	7fee                	ld	t6,248(sp)
ffffffffc0200db0:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200db2:	10200073          	sret

ffffffffc0200db6 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200db6:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200db8:	b755                	j	ffffffffc0200d5c <__trapret>

ffffffffc0200dba <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200dba:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7bf8>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200dbe:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200dc2:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200dc6:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200dca:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200dce:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200dd2:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200dd6:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200dda:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200dde:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200de0:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200de2:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200de4:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200de6:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200de8:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200dea:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200dec:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200dee:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200df0:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200df2:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200df4:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200df6:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200df8:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dfa:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200dfc:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200dfe:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200e00:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200e02:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200e04:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200e06:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200e08:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200e0a:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200e0c:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200e0e:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200e10:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200e12:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200e14:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200e16:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200e18:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200e1a:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200e1c:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200e1e:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200e20:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200e22:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200e24:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200e26:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200e28:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200e2a:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200e2c:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200e2e:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e30:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e32:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e34:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e36:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e38:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e3a:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e3c:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e3e:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e40:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e42:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e44:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e46:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e48:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e4a:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e4c:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e4e:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e50:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e52:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e54:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e56:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e58:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e5a:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e5c:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e5e:	812e                	mv	sp,a1
ffffffffc0200e60:	bdf5                	j	ffffffffc0200d5c <__trapret>

ffffffffc0200e62 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e62:	000de797          	auipc	a5,0xde
ffffffffc0200e66:	53678793          	addi	a5,a5,1334 # ffffffffc02df398 <free_area>
ffffffffc0200e6a:	e79c                	sd	a5,8(a5)
ffffffffc0200e6c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e6e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e72:	8082                	ret

ffffffffc0200e74 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200e74:	000de517          	auipc	a0,0xde
ffffffffc0200e78:	53456503          	lwu	a0,1332(a0) # ffffffffc02df3a8 <free_area+0x10>
ffffffffc0200e7c:	8082                	ret

ffffffffc0200e7e <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200e7e:	715d                	addi	sp,sp,-80
ffffffffc0200e80:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e82:	000de917          	auipc	s2,0xde
ffffffffc0200e86:	51690913          	addi	s2,s2,1302 # ffffffffc02df398 <free_area>
ffffffffc0200e8a:	00893783          	ld	a5,8(s2)
ffffffffc0200e8e:	e486                	sd	ra,72(sp)
ffffffffc0200e90:	e0a2                	sd	s0,64(sp)
ffffffffc0200e92:	fc26                	sd	s1,56(sp)
ffffffffc0200e94:	f44e                	sd	s3,40(sp)
ffffffffc0200e96:	f052                	sd	s4,32(sp)
ffffffffc0200e98:	ec56                	sd	s5,24(sp)
ffffffffc0200e9a:	e85a                	sd	s6,16(sp)
ffffffffc0200e9c:	e45e                	sd	s7,8(sp)
ffffffffc0200e9e:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ea0:	31278463          	beq	a5,s2,ffffffffc02011a8 <default_check+0x32a>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200ea4:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200ea8:	8305                	srli	a4,a4,0x1
ffffffffc0200eaa:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200eac:	30070263          	beqz	a4,ffffffffc02011b0 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0200eb0:	4401                	li	s0,0
ffffffffc0200eb2:	4481                	li	s1,0
ffffffffc0200eb4:	a031                	j	ffffffffc0200ec0 <default_check+0x42>
ffffffffc0200eb6:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200eba:	8b09                	andi	a4,a4,2
ffffffffc0200ebc:	2e070a63          	beqz	a4,ffffffffc02011b0 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0200ec0:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ec4:	679c                	ld	a5,8(a5)
ffffffffc0200ec6:	2485                	addiw	s1,s1,1
ffffffffc0200ec8:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200eca:	ff2796e3          	bne	a5,s2,ffffffffc0200eb6 <default_check+0x38>
ffffffffc0200ece:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200ed0:	05c010ef          	jal	ra,ffffffffc0201f2c <nr_free_pages>
ffffffffc0200ed4:	73351e63          	bne	a0,s3,ffffffffc0201610 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ed8:	4505                	li	a0,1
ffffffffc0200eda:	785000ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc0200ede:	8a2a                	mv	s4,a0
ffffffffc0200ee0:	46050863          	beqz	a0,ffffffffc0201350 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ee4:	4505                	li	a0,1
ffffffffc0200ee6:	779000ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc0200eea:	89aa                	mv	s3,a0
ffffffffc0200eec:	74050263          	beqz	a0,ffffffffc0201630 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ef0:	4505                	li	a0,1
ffffffffc0200ef2:	76d000ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc0200ef6:	8aaa                	mv	s5,a0
ffffffffc0200ef8:	4c050c63          	beqz	a0,ffffffffc02013d0 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200efc:	2d3a0a63          	beq	s4,s3,ffffffffc02011d0 <default_check+0x352>
ffffffffc0200f00:	2caa0863          	beq	s4,a0,ffffffffc02011d0 <default_check+0x352>
ffffffffc0200f04:	2ca98663          	beq	s3,a0,ffffffffc02011d0 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200f08:	000a2783          	lw	a5,0(s4)
ffffffffc0200f0c:	2e079263          	bnez	a5,ffffffffc02011f0 <default_check+0x372>
ffffffffc0200f10:	0009a783          	lw	a5,0(s3)
ffffffffc0200f14:	2c079e63          	bnez	a5,ffffffffc02011f0 <default_check+0x372>
ffffffffc0200f18:	411c                	lw	a5,0(a0)
ffffffffc0200f1a:	2c079b63          	bnez	a5,ffffffffc02011f0 <default_check+0x372>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200f1e:	000de797          	auipc	a5,0xde
ffffffffc0200f22:	4aa78793          	addi	a5,a5,1194 # ffffffffc02df3c8 <pages>
ffffffffc0200f26:	639c                	ld	a5,0(a5)
ffffffffc0200f28:	0000a717          	auipc	a4,0xa
ffffffffc0200f2c:	a2870713          	addi	a4,a4,-1496 # ffffffffc020a950 <nbase>
ffffffffc0200f30:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f32:	000de717          	auipc	a4,0xde
ffffffffc0200f36:	41670713          	addi	a4,a4,1046 # ffffffffc02df348 <npage>
ffffffffc0200f3a:	6314                	ld	a3,0(a4)
ffffffffc0200f3c:	40fa0733          	sub	a4,s4,a5
ffffffffc0200f40:	8719                	srai	a4,a4,0x6
ffffffffc0200f42:	9732                	add	a4,a4,a2
ffffffffc0200f44:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f46:	0732                	slli	a4,a4,0xc
ffffffffc0200f48:	2cd77463          	bleu	a3,a4,ffffffffc0201210 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0200f4c:	40f98733          	sub	a4,s3,a5
ffffffffc0200f50:	8719                	srai	a4,a4,0x6
ffffffffc0200f52:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f54:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200f56:	4ed77d63          	bleu	a3,a4,ffffffffc0201450 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0200f5a:	40f507b3          	sub	a5,a0,a5
ffffffffc0200f5e:	8799                	srai	a5,a5,0x6
ffffffffc0200f60:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f62:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f64:	34d7f663          	bleu	a3,a5,ffffffffc02012b0 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0200f68:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200f6a:	00093c03          	ld	s8,0(s2)
ffffffffc0200f6e:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200f72:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200f76:	000de797          	auipc	a5,0xde
ffffffffc0200f7a:	4327b523          	sd	s2,1066(a5) # ffffffffc02df3a0 <free_area+0x8>
ffffffffc0200f7e:	000de797          	auipc	a5,0xde
ffffffffc0200f82:	4127bd23          	sd	s2,1050(a5) # ffffffffc02df398 <free_area>
    nr_free = 0;
ffffffffc0200f86:	000de797          	auipc	a5,0xde
ffffffffc0200f8a:	4207a123          	sw	zero,1058(a5) # ffffffffc02df3a8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200f8e:	6d1000ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc0200f92:	2e051f63          	bnez	a0,ffffffffc0201290 <default_check+0x412>
    free_page(p0);
ffffffffc0200f96:	4585                	li	a1,1
ffffffffc0200f98:	8552                	mv	a0,s4
ffffffffc0200f9a:	74d000ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    free_page(p1);
ffffffffc0200f9e:	4585                	li	a1,1
ffffffffc0200fa0:	854e                	mv	a0,s3
ffffffffc0200fa2:	745000ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    free_page(p2);
ffffffffc0200fa6:	4585                	li	a1,1
ffffffffc0200fa8:	8556                	mv	a0,s5
ffffffffc0200faa:	73d000ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    assert(nr_free == 3);
ffffffffc0200fae:	01092703          	lw	a4,16(s2)
ffffffffc0200fb2:	478d                	li	a5,3
ffffffffc0200fb4:	2af71e63          	bne	a4,a5,ffffffffc0201270 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200fb8:	4505                	li	a0,1
ffffffffc0200fba:	6a5000ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc0200fbe:	89aa                	mv	s3,a0
ffffffffc0200fc0:	28050863          	beqz	a0,ffffffffc0201250 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200fc4:	4505                	li	a0,1
ffffffffc0200fc6:	699000ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc0200fca:	8aaa                	mv	s5,a0
ffffffffc0200fcc:	3e050263          	beqz	a0,ffffffffc02013b0 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fd0:	4505                	li	a0,1
ffffffffc0200fd2:	68d000ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc0200fd6:	8a2a                	mv	s4,a0
ffffffffc0200fd8:	3a050c63          	beqz	a0,ffffffffc0201390 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0200fdc:	4505                	li	a0,1
ffffffffc0200fde:	681000ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc0200fe2:	38051763          	bnez	a0,ffffffffc0201370 <default_check+0x4f2>
    free_page(p0);
ffffffffc0200fe6:	4585                	li	a1,1
ffffffffc0200fe8:	854e                	mv	a0,s3
ffffffffc0200fea:	6fd000ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200fee:	00893783          	ld	a5,8(s2)
ffffffffc0200ff2:	23278f63          	beq	a5,s2,ffffffffc0201230 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0200ff6:	4505                	li	a0,1
ffffffffc0200ff8:	667000ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc0200ffc:	32a99a63          	bne	s3,a0,ffffffffc0201330 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0201000:	4505                	li	a0,1
ffffffffc0201002:	65d000ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc0201006:	30051563          	bnez	a0,ffffffffc0201310 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc020100a:	01092783          	lw	a5,16(s2)
ffffffffc020100e:	2e079163          	bnez	a5,ffffffffc02012f0 <default_check+0x472>
    free_page(p);
ffffffffc0201012:	854e                	mv	a0,s3
ffffffffc0201014:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201016:	000de797          	auipc	a5,0xde
ffffffffc020101a:	3987b123          	sd	s8,898(a5) # ffffffffc02df398 <free_area>
ffffffffc020101e:	000de797          	auipc	a5,0xde
ffffffffc0201022:	3977b123          	sd	s7,898(a5) # ffffffffc02df3a0 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0201026:	000de797          	auipc	a5,0xde
ffffffffc020102a:	3967a123          	sw	s6,898(a5) # ffffffffc02df3a8 <free_area+0x10>
    free_page(p);
ffffffffc020102e:	6b9000ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    free_page(p1);
ffffffffc0201032:	4585                	li	a1,1
ffffffffc0201034:	8556                	mv	a0,s5
ffffffffc0201036:	6b1000ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    free_page(p2);
ffffffffc020103a:	4585                	li	a1,1
ffffffffc020103c:	8552                	mv	a0,s4
ffffffffc020103e:	6a9000ef          	jal	ra,ffffffffc0201ee6 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201042:	4515                	li	a0,5
ffffffffc0201044:	61b000ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc0201048:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc020104a:	28050363          	beqz	a0,ffffffffc02012d0 <default_check+0x452>
ffffffffc020104e:	651c                	ld	a5,8(a0)
ffffffffc0201050:	8385                	srli	a5,a5,0x1
ffffffffc0201052:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0201054:	54079e63          	bnez	a5,ffffffffc02015b0 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201058:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020105a:	00093b03          	ld	s6,0(s2)
ffffffffc020105e:	00893a83          	ld	s5,8(s2)
ffffffffc0201062:	000de797          	auipc	a5,0xde
ffffffffc0201066:	3327bb23          	sd	s2,822(a5) # ffffffffc02df398 <free_area>
ffffffffc020106a:	000de797          	auipc	a5,0xde
ffffffffc020106e:	3327bb23          	sd	s2,822(a5) # ffffffffc02df3a0 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0201072:	5ed000ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc0201076:	50051d63          	bnez	a0,ffffffffc0201590 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020107a:	08098a13          	addi	s4,s3,128
ffffffffc020107e:	8552                	mv	a0,s4
ffffffffc0201080:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201082:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0201086:	000de797          	auipc	a5,0xde
ffffffffc020108a:	3207a123          	sw	zero,802(a5) # ffffffffc02df3a8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc020108e:	659000ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201092:	4511                	li	a0,4
ffffffffc0201094:	5cb000ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc0201098:	4c051c63          	bnez	a0,ffffffffc0201570 <default_check+0x6f2>
ffffffffc020109c:	0889b783          	ld	a5,136(s3)
ffffffffc02010a0:	8385                	srli	a5,a5,0x1
ffffffffc02010a2:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02010a4:	4a078663          	beqz	a5,ffffffffc0201550 <default_check+0x6d2>
ffffffffc02010a8:	0909a703          	lw	a4,144(s3)
ffffffffc02010ac:	478d                	li	a5,3
ffffffffc02010ae:	4af71163          	bne	a4,a5,ffffffffc0201550 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02010b2:	450d                	li	a0,3
ffffffffc02010b4:	5ab000ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc02010b8:	8c2a                	mv	s8,a0
ffffffffc02010ba:	46050b63          	beqz	a0,ffffffffc0201530 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc02010be:	4505                	li	a0,1
ffffffffc02010c0:	59f000ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc02010c4:	44051663          	bnez	a0,ffffffffc0201510 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc02010c8:	438a1463          	bne	s4,s8,ffffffffc02014f0 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02010cc:	4585                	li	a1,1
ffffffffc02010ce:	854e                	mv	a0,s3
ffffffffc02010d0:	617000ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    free_pages(p1, 3);
ffffffffc02010d4:	458d                	li	a1,3
ffffffffc02010d6:	8552                	mv	a0,s4
ffffffffc02010d8:	60f000ef          	jal	ra,ffffffffc0201ee6 <free_pages>
ffffffffc02010dc:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02010e0:	04098c13          	addi	s8,s3,64
ffffffffc02010e4:	8385                	srli	a5,a5,0x1
ffffffffc02010e6:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02010e8:	3e078463          	beqz	a5,ffffffffc02014d0 <default_check+0x652>
ffffffffc02010ec:	0109a703          	lw	a4,16(s3)
ffffffffc02010f0:	4785                	li	a5,1
ffffffffc02010f2:	3cf71f63          	bne	a4,a5,ffffffffc02014d0 <default_check+0x652>
ffffffffc02010f6:	008a3783          	ld	a5,8(s4)
ffffffffc02010fa:	8385                	srli	a5,a5,0x1
ffffffffc02010fc:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010fe:	3a078963          	beqz	a5,ffffffffc02014b0 <default_check+0x632>
ffffffffc0201102:	010a2703          	lw	a4,16(s4)
ffffffffc0201106:	478d                	li	a5,3
ffffffffc0201108:	3af71463          	bne	a4,a5,ffffffffc02014b0 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020110c:	4505                	li	a0,1
ffffffffc020110e:	551000ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc0201112:	36a99f63          	bne	s3,a0,ffffffffc0201490 <default_check+0x612>
    free_page(p0);
ffffffffc0201116:	4585                	li	a1,1
ffffffffc0201118:	5cf000ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020111c:	4509                	li	a0,2
ffffffffc020111e:	541000ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc0201122:	34aa1763          	bne	s4,a0,ffffffffc0201470 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc0201126:	4589                	li	a1,2
ffffffffc0201128:	5bf000ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    free_page(p2);
ffffffffc020112c:	4585                	li	a1,1
ffffffffc020112e:	8562                	mv	a0,s8
ffffffffc0201130:	5b7000ef          	jal	ra,ffffffffc0201ee6 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201134:	4515                	li	a0,5
ffffffffc0201136:	529000ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc020113a:	89aa                	mv	s3,a0
ffffffffc020113c:	48050a63          	beqz	a0,ffffffffc02015d0 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0201140:	4505                	li	a0,1
ffffffffc0201142:	51d000ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc0201146:	2e051563          	bnez	a0,ffffffffc0201430 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc020114a:	01092783          	lw	a5,16(s2)
ffffffffc020114e:	2c079163          	bnez	a5,ffffffffc0201410 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201152:	4595                	li	a1,5
ffffffffc0201154:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0201156:	000de797          	auipc	a5,0xde
ffffffffc020115a:	2577a923          	sw	s7,594(a5) # ffffffffc02df3a8 <free_area+0x10>
    free_list = free_list_store;
ffffffffc020115e:	000de797          	auipc	a5,0xde
ffffffffc0201162:	2367bd23          	sd	s6,570(a5) # ffffffffc02df398 <free_area>
ffffffffc0201166:	000de797          	auipc	a5,0xde
ffffffffc020116a:	2357bd23          	sd	s5,570(a5) # ffffffffc02df3a0 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc020116e:	579000ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    return listelm->next;
ffffffffc0201172:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201176:	01278963          	beq	a5,s2,ffffffffc0201188 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020117a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020117e:	679c                	ld	a5,8(a5)
ffffffffc0201180:	34fd                	addiw	s1,s1,-1
ffffffffc0201182:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201184:	ff279be3          	bne	a5,s2,ffffffffc020117a <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc0201188:	26049463          	bnez	s1,ffffffffc02013f0 <default_check+0x572>
    assert(total == 0);
ffffffffc020118c:	46041263          	bnez	s0,ffffffffc02015f0 <default_check+0x772>
}
ffffffffc0201190:	60a6                	ld	ra,72(sp)
ffffffffc0201192:	6406                	ld	s0,64(sp)
ffffffffc0201194:	74e2                	ld	s1,56(sp)
ffffffffc0201196:	7942                	ld	s2,48(sp)
ffffffffc0201198:	79a2                	ld	s3,40(sp)
ffffffffc020119a:	7a02                	ld	s4,32(sp)
ffffffffc020119c:	6ae2                	ld	s5,24(sp)
ffffffffc020119e:	6b42                	ld	s6,16(sp)
ffffffffc02011a0:	6ba2                	ld	s7,8(sp)
ffffffffc02011a2:	6c02                	ld	s8,0(sp)
ffffffffc02011a4:	6161                	addi	sp,sp,80
ffffffffc02011a6:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02011a8:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02011aa:	4401                	li	s0,0
ffffffffc02011ac:	4481                	li	s1,0
ffffffffc02011ae:	b30d                	j	ffffffffc0200ed0 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc02011b0:	00007697          	auipc	a3,0x7
ffffffffc02011b4:	d4868693          	addi	a3,a3,-696 # ffffffffc0207ef8 <commands+0x878>
ffffffffc02011b8:	00007617          	auipc	a2,0x7
ffffffffc02011bc:	98860613          	addi	a2,a2,-1656 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02011c0:	0ef00593          	li	a1,239
ffffffffc02011c4:	00007517          	auipc	a0,0x7
ffffffffc02011c8:	d4450513          	addi	a0,a0,-700 # ffffffffc0207f08 <commands+0x888>
ffffffffc02011cc:	abcff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02011d0:	00007697          	auipc	a3,0x7
ffffffffc02011d4:	dd068693          	addi	a3,a3,-560 # ffffffffc0207fa0 <commands+0x920>
ffffffffc02011d8:	00007617          	auipc	a2,0x7
ffffffffc02011dc:	96860613          	addi	a2,a2,-1688 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02011e0:	0bc00593          	li	a1,188
ffffffffc02011e4:	00007517          	auipc	a0,0x7
ffffffffc02011e8:	d2450513          	addi	a0,a0,-732 # ffffffffc0207f08 <commands+0x888>
ffffffffc02011ec:	a9cff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02011f0:	00007697          	auipc	a3,0x7
ffffffffc02011f4:	dd868693          	addi	a3,a3,-552 # ffffffffc0207fc8 <commands+0x948>
ffffffffc02011f8:	00007617          	auipc	a2,0x7
ffffffffc02011fc:	94860613          	addi	a2,a2,-1720 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201200:	0bd00593          	li	a1,189
ffffffffc0201204:	00007517          	auipc	a0,0x7
ffffffffc0201208:	d0450513          	addi	a0,a0,-764 # ffffffffc0207f08 <commands+0x888>
ffffffffc020120c:	a7cff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201210:	00007697          	auipc	a3,0x7
ffffffffc0201214:	df868693          	addi	a3,a3,-520 # ffffffffc0208008 <commands+0x988>
ffffffffc0201218:	00007617          	auipc	a2,0x7
ffffffffc020121c:	92860613          	addi	a2,a2,-1752 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201220:	0bf00593          	li	a1,191
ffffffffc0201224:	00007517          	auipc	a0,0x7
ffffffffc0201228:	ce450513          	addi	a0,a0,-796 # ffffffffc0207f08 <commands+0x888>
ffffffffc020122c:	a5cff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201230:	00007697          	auipc	a3,0x7
ffffffffc0201234:	e6068693          	addi	a3,a3,-416 # ffffffffc0208090 <commands+0xa10>
ffffffffc0201238:	00007617          	auipc	a2,0x7
ffffffffc020123c:	90860613          	addi	a2,a2,-1784 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201240:	0d800593          	li	a1,216
ffffffffc0201244:	00007517          	auipc	a0,0x7
ffffffffc0201248:	cc450513          	addi	a0,a0,-828 # ffffffffc0207f08 <commands+0x888>
ffffffffc020124c:	a3cff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201250:	00007697          	auipc	a3,0x7
ffffffffc0201254:	cf068693          	addi	a3,a3,-784 # ffffffffc0207f40 <commands+0x8c0>
ffffffffc0201258:	00007617          	auipc	a2,0x7
ffffffffc020125c:	8e860613          	addi	a2,a2,-1816 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201260:	0d100593          	li	a1,209
ffffffffc0201264:	00007517          	auipc	a0,0x7
ffffffffc0201268:	ca450513          	addi	a0,a0,-860 # ffffffffc0207f08 <commands+0x888>
ffffffffc020126c:	a1cff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free == 3);
ffffffffc0201270:	00007697          	auipc	a3,0x7
ffffffffc0201274:	e1068693          	addi	a3,a3,-496 # ffffffffc0208080 <commands+0xa00>
ffffffffc0201278:	00007617          	auipc	a2,0x7
ffffffffc020127c:	8c860613          	addi	a2,a2,-1848 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201280:	0cf00593          	li	a1,207
ffffffffc0201284:	00007517          	auipc	a0,0x7
ffffffffc0201288:	c8450513          	addi	a0,a0,-892 # ffffffffc0207f08 <commands+0x888>
ffffffffc020128c:	9fcff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201290:	00007697          	auipc	a3,0x7
ffffffffc0201294:	dd868693          	addi	a3,a3,-552 # ffffffffc0208068 <commands+0x9e8>
ffffffffc0201298:	00007617          	auipc	a2,0x7
ffffffffc020129c:	8a860613          	addi	a2,a2,-1880 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02012a0:	0ca00593          	li	a1,202
ffffffffc02012a4:	00007517          	auipc	a0,0x7
ffffffffc02012a8:	c6450513          	addi	a0,a0,-924 # ffffffffc0207f08 <commands+0x888>
ffffffffc02012ac:	9dcff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02012b0:	00007697          	auipc	a3,0x7
ffffffffc02012b4:	d9868693          	addi	a3,a3,-616 # ffffffffc0208048 <commands+0x9c8>
ffffffffc02012b8:	00007617          	auipc	a2,0x7
ffffffffc02012bc:	88860613          	addi	a2,a2,-1912 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02012c0:	0c100593          	li	a1,193
ffffffffc02012c4:	00007517          	auipc	a0,0x7
ffffffffc02012c8:	c4450513          	addi	a0,a0,-956 # ffffffffc0207f08 <commands+0x888>
ffffffffc02012cc:	9bcff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(p0 != NULL);
ffffffffc02012d0:	00007697          	auipc	a3,0x7
ffffffffc02012d4:	e0868693          	addi	a3,a3,-504 # ffffffffc02080d8 <commands+0xa58>
ffffffffc02012d8:	00007617          	auipc	a2,0x7
ffffffffc02012dc:	86860613          	addi	a2,a2,-1944 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02012e0:	0f700593          	li	a1,247
ffffffffc02012e4:	00007517          	auipc	a0,0x7
ffffffffc02012e8:	c2450513          	addi	a0,a0,-988 # ffffffffc0207f08 <commands+0x888>
ffffffffc02012ec:	99cff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free == 0);
ffffffffc02012f0:	00007697          	auipc	a3,0x7
ffffffffc02012f4:	dd868693          	addi	a3,a3,-552 # ffffffffc02080c8 <commands+0xa48>
ffffffffc02012f8:	00007617          	auipc	a2,0x7
ffffffffc02012fc:	84860613          	addi	a2,a2,-1976 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201300:	0de00593          	li	a1,222
ffffffffc0201304:	00007517          	auipc	a0,0x7
ffffffffc0201308:	c0450513          	addi	a0,a0,-1020 # ffffffffc0207f08 <commands+0x888>
ffffffffc020130c:	97cff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201310:	00007697          	auipc	a3,0x7
ffffffffc0201314:	d5868693          	addi	a3,a3,-680 # ffffffffc0208068 <commands+0x9e8>
ffffffffc0201318:	00007617          	auipc	a2,0x7
ffffffffc020131c:	82860613          	addi	a2,a2,-2008 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201320:	0dc00593          	li	a1,220
ffffffffc0201324:	00007517          	auipc	a0,0x7
ffffffffc0201328:	be450513          	addi	a0,a0,-1052 # ffffffffc0207f08 <commands+0x888>
ffffffffc020132c:	95cff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201330:	00007697          	auipc	a3,0x7
ffffffffc0201334:	d7868693          	addi	a3,a3,-648 # ffffffffc02080a8 <commands+0xa28>
ffffffffc0201338:	00007617          	auipc	a2,0x7
ffffffffc020133c:	80860613          	addi	a2,a2,-2040 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201340:	0db00593          	li	a1,219
ffffffffc0201344:	00007517          	auipc	a0,0x7
ffffffffc0201348:	bc450513          	addi	a0,a0,-1084 # ffffffffc0207f08 <commands+0x888>
ffffffffc020134c:	93cff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201350:	00007697          	auipc	a3,0x7
ffffffffc0201354:	bf068693          	addi	a3,a3,-1040 # ffffffffc0207f40 <commands+0x8c0>
ffffffffc0201358:	00006617          	auipc	a2,0x6
ffffffffc020135c:	7e860613          	addi	a2,a2,2024 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201360:	0b800593          	li	a1,184
ffffffffc0201364:	00007517          	auipc	a0,0x7
ffffffffc0201368:	ba450513          	addi	a0,a0,-1116 # ffffffffc0207f08 <commands+0x888>
ffffffffc020136c:	91cff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201370:	00007697          	auipc	a3,0x7
ffffffffc0201374:	cf868693          	addi	a3,a3,-776 # ffffffffc0208068 <commands+0x9e8>
ffffffffc0201378:	00006617          	auipc	a2,0x6
ffffffffc020137c:	7c860613          	addi	a2,a2,1992 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201380:	0d500593          	li	a1,213
ffffffffc0201384:	00007517          	auipc	a0,0x7
ffffffffc0201388:	b8450513          	addi	a0,a0,-1148 # ffffffffc0207f08 <commands+0x888>
ffffffffc020138c:	8fcff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201390:	00007697          	auipc	a3,0x7
ffffffffc0201394:	bf068693          	addi	a3,a3,-1040 # ffffffffc0207f80 <commands+0x900>
ffffffffc0201398:	00006617          	auipc	a2,0x6
ffffffffc020139c:	7a860613          	addi	a2,a2,1960 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02013a0:	0d300593          	li	a1,211
ffffffffc02013a4:	00007517          	auipc	a0,0x7
ffffffffc02013a8:	b6450513          	addi	a0,a0,-1180 # ffffffffc0207f08 <commands+0x888>
ffffffffc02013ac:	8dcff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02013b0:	00007697          	auipc	a3,0x7
ffffffffc02013b4:	bb068693          	addi	a3,a3,-1104 # ffffffffc0207f60 <commands+0x8e0>
ffffffffc02013b8:	00006617          	auipc	a2,0x6
ffffffffc02013bc:	78860613          	addi	a2,a2,1928 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02013c0:	0d200593          	li	a1,210
ffffffffc02013c4:	00007517          	auipc	a0,0x7
ffffffffc02013c8:	b4450513          	addi	a0,a0,-1212 # ffffffffc0207f08 <commands+0x888>
ffffffffc02013cc:	8bcff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02013d0:	00007697          	auipc	a3,0x7
ffffffffc02013d4:	bb068693          	addi	a3,a3,-1104 # ffffffffc0207f80 <commands+0x900>
ffffffffc02013d8:	00006617          	auipc	a2,0x6
ffffffffc02013dc:	76860613          	addi	a2,a2,1896 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02013e0:	0ba00593          	li	a1,186
ffffffffc02013e4:	00007517          	auipc	a0,0x7
ffffffffc02013e8:	b2450513          	addi	a0,a0,-1244 # ffffffffc0207f08 <commands+0x888>
ffffffffc02013ec:	89cff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(count == 0);
ffffffffc02013f0:	00007697          	auipc	a3,0x7
ffffffffc02013f4:	e3868693          	addi	a3,a3,-456 # ffffffffc0208228 <commands+0xba8>
ffffffffc02013f8:	00006617          	auipc	a2,0x6
ffffffffc02013fc:	74860613          	addi	a2,a2,1864 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201400:	12400593          	li	a1,292
ffffffffc0201404:	00007517          	auipc	a0,0x7
ffffffffc0201408:	b0450513          	addi	a0,a0,-1276 # ffffffffc0207f08 <commands+0x888>
ffffffffc020140c:	87cff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free == 0);
ffffffffc0201410:	00007697          	auipc	a3,0x7
ffffffffc0201414:	cb868693          	addi	a3,a3,-840 # ffffffffc02080c8 <commands+0xa48>
ffffffffc0201418:	00006617          	auipc	a2,0x6
ffffffffc020141c:	72860613          	addi	a2,a2,1832 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201420:	11900593          	li	a1,281
ffffffffc0201424:	00007517          	auipc	a0,0x7
ffffffffc0201428:	ae450513          	addi	a0,a0,-1308 # ffffffffc0207f08 <commands+0x888>
ffffffffc020142c:	85cff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201430:	00007697          	auipc	a3,0x7
ffffffffc0201434:	c3868693          	addi	a3,a3,-968 # ffffffffc0208068 <commands+0x9e8>
ffffffffc0201438:	00006617          	auipc	a2,0x6
ffffffffc020143c:	70860613          	addi	a2,a2,1800 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201440:	11700593          	li	a1,279
ffffffffc0201444:	00007517          	auipc	a0,0x7
ffffffffc0201448:	ac450513          	addi	a0,a0,-1340 # ffffffffc0207f08 <commands+0x888>
ffffffffc020144c:	83cff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201450:	00007697          	auipc	a3,0x7
ffffffffc0201454:	bd868693          	addi	a3,a3,-1064 # ffffffffc0208028 <commands+0x9a8>
ffffffffc0201458:	00006617          	auipc	a2,0x6
ffffffffc020145c:	6e860613          	addi	a2,a2,1768 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201460:	0c000593          	li	a1,192
ffffffffc0201464:	00007517          	auipc	a0,0x7
ffffffffc0201468:	aa450513          	addi	a0,a0,-1372 # ffffffffc0207f08 <commands+0x888>
ffffffffc020146c:	81cff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201470:	00007697          	auipc	a3,0x7
ffffffffc0201474:	d7868693          	addi	a3,a3,-648 # ffffffffc02081e8 <commands+0xb68>
ffffffffc0201478:	00006617          	auipc	a2,0x6
ffffffffc020147c:	6c860613          	addi	a2,a2,1736 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201480:	11100593          	li	a1,273
ffffffffc0201484:	00007517          	auipc	a0,0x7
ffffffffc0201488:	a8450513          	addi	a0,a0,-1404 # ffffffffc0207f08 <commands+0x888>
ffffffffc020148c:	ffdfe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201490:	00007697          	auipc	a3,0x7
ffffffffc0201494:	d3868693          	addi	a3,a3,-712 # ffffffffc02081c8 <commands+0xb48>
ffffffffc0201498:	00006617          	auipc	a2,0x6
ffffffffc020149c:	6a860613          	addi	a2,a2,1704 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02014a0:	10f00593          	li	a1,271
ffffffffc02014a4:	00007517          	auipc	a0,0x7
ffffffffc02014a8:	a6450513          	addi	a0,a0,-1436 # ffffffffc0207f08 <commands+0x888>
ffffffffc02014ac:	fddfe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02014b0:	00007697          	auipc	a3,0x7
ffffffffc02014b4:	cf068693          	addi	a3,a3,-784 # ffffffffc02081a0 <commands+0xb20>
ffffffffc02014b8:	00006617          	auipc	a2,0x6
ffffffffc02014bc:	68860613          	addi	a2,a2,1672 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02014c0:	10d00593          	li	a1,269
ffffffffc02014c4:	00007517          	auipc	a0,0x7
ffffffffc02014c8:	a4450513          	addi	a0,a0,-1468 # ffffffffc0207f08 <commands+0x888>
ffffffffc02014cc:	fbdfe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02014d0:	00007697          	auipc	a3,0x7
ffffffffc02014d4:	ca868693          	addi	a3,a3,-856 # ffffffffc0208178 <commands+0xaf8>
ffffffffc02014d8:	00006617          	auipc	a2,0x6
ffffffffc02014dc:	66860613          	addi	a2,a2,1640 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02014e0:	10c00593          	li	a1,268
ffffffffc02014e4:	00007517          	auipc	a0,0x7
ffffffffc02014e8:	a2450513          	addi	a0,a0,-1500 # ffffffffc0207f08 <commands+0x888>
ffffffffc02014ec:	f9dfe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02014f0:	00007697          	auipc	a3,0x7
ffffffffc02014f4:	c7868693          	addi	a3,a3,-904 # ffffffffc0208168 <commands+0xae8>
ffffffffc02014f8:	00006617          	auipc	a2,0x6
ffffffffc02014fc:	64860613          	addi	a2,a2,1608 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201500:	10700593          	li	a1,263
ffffffffc0201504:	00007517          	auipc	a0,0x7
ffffffffc0201508:	a0450513          	addi	a0,a0,-1532 # ffffffffc0207f08 <commands+0x888>
ffffffffc020150c:	f7dfe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201510:	00007697          	auipc	a3,0x7
ffffffffc0201514:	b5868693          	addi	a3,a3,-1192 # ffffffffc0208068 <commands+0x9e8>
ffffffffc0201518:	00006617          	auipc	a2,0x6
ffffffffc020151c:	62860613          	addi	a2,a2,1576 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201520:	10600593          	li	a1,262
ffffffffc0201524:	00007517          	auipc	a0,0x7
ffffffffc0201528:	9e450513          	addi	a0,a0,-1564 # ffffffffc0207f08 <commands+0x888>
ffffffffc020152c:	f5dfe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201530:	00007697          	auipc	a3,0x7
ffffffffc0201534:	c1868693          	addi	a3,a3,-1000 # ffffffffc0208148 <commands+0xac8>
ffffffffc0201538:	00006617          	auipc	a2,0x6
ffffffffc020153c:	60860613          	addi	a2,a2,1544 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201540:	10500593          	li	a1,261
ffffffffc0201544:	00007517          	auipc	a0,0x7
ffffffffc0201548:	9c450513          	addi	a0,a0,-1596 # ffffffffc0207f08 <commands+0x888>
ffffffffc020154c:	f3dfe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201550:	00007697          	auipc	a3,0x7
ffffffffc0201554:	bc868693          	addi	a3,a3,-1080 # ffffffffc0208118 <commands+0xa98>
ffffffffc0201558:	00006617          	auipc	a2,0x6
ffffffffc020155c:	5e860613          	addi	a2,a2,1512 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201560:	10400593          	li	a1,260
ffffffffc0201564:	00007517          	auipc	a0,0x7
ffffffffc0201568:	9a450513          	addi	a0,a0,-1628 # ffffffffc0207f08 <commands+0x888>
ffffffffc020156c:	f1dfe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201570:	00007697          	auipc	a3,0x7
ffffffffc0201574:	b9068693          	addi	a3,a3,-1136 # ffffffffc0208100 <commands+0xa80>
ffffffffc0201578:	00006617          	auipc	a2,0x6
ffffffffc020157c:	5c860613          	addi	a2,a2,1480 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201580:	10300593          	li	a1,259
ffffffffc0201584:	00007517          	auipc	a0,0x7
ffffffffc0201588:	98450513          	addi	a0,a0,-1660 # ffffffffc0207f08 <commands+0x888>
ffffffffc020158c:	efdfe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201590:	00007697          	auipc	a3,0x7
ffffffffc0201594:	ad868693          	addi	a3,a3,-1320 # ffffffffc0208068 <commands+0x9e8>
ffffffffc0201598:	00006617          	auipc	a2,0x6
ffffffffc020159c:	5a860613          	addi	a2,a2,1448 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02015a0:	0fd00593          	li	a1,253
ffffffffc02015a4:	00007517          	auipc	a0,0x7
ffffffffc02015a8:	96450513          	addi	a0,a0,-1692 # ffffffffc0207f08 <commands+0x888>
ffffffffc02015ac:	eddfe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(!PageProperty(p0));
ffffffffc02015b0:	00007697          	auipc	a3,0x7
ffffffffc02015b4:	b3868693          	addi	a3,a3,-1224 # ffffffffc02080e8 <commands+0xa68>
ffffffffc02015b8:	00006617          	auipc	a2,0x6
ffffffffc02015bc:	58860613          	addi	a2,a2,1416 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02015c0:	0f800593          	li	a1,248
ffffffffc02015c4:	00007517          	auipc	a0,0x7
ffffffffc02015c8:	94450513          	addi	a0,a0,-1724 # ffffffffc0207f08 <commands+0x888>
ffffffffc02015cc:	ebdfe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02015d0:	00007697          	auipc	a3,0x7
ffffffffc02015d4:	c3868693          	addi	a3,a3,-968 # ffffffffc0208208 <commands+0xb88>
ffffffffc02015d8:	00006617          	auipc	a2,0x6
ffffffffc02015dc:	56860613          	addi	a2,a2,1384 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02015e0:	11600593          	li	a1,278
ffffffffc02015e4:	00007517          	auipc	a0,0x7
ffffffffc02015e8:	92450513          	addi	a0,a0,-1756 # ffffffffc0207f08 <commands+0x888>
ffffffffc02015ec:	e9dfe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(total == 0);
ffffffffc02015f0:	00007697          	auipc	a3,0x7
ffffffffc02015f4:	c4868693          	addi	a3,a3,-952 # ffffffffc0208238 <commands+0xbb8>
ffffffffc02015f8:	00006617          	auipc	a2,0x6
ffffffffc02015fc:	54860613          	addi	a2,a2,1352 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201600:	12500593          	li	a1,293
ffffffffc0201604:	00007517          	auipc	a0,0x7
ffffffffc0201608:	90450513          	addi	a0,a0,-1788 # ffffffffc0207f08 <commands+0x888>
ffffffffc020160c:	e7dfe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201610:	00007697          	auipc	a3,0x7
ffffffffc0201614:	91068693          	addi	a3,a3,-1776 # ffffffffc0207f20 <commands+0x8a0>
ffffffffc0201618:	00006617          	auipc	a2,0x6
ffffffffc020161c:	52860613          	addi	a2,a2,1320 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201620:	0f200593          	li	a1,242
ffffffffc0201624:	00007517          	auipc	a0,0x7
ffffffffc0201628:	8e450513          	addi	a0,a0,-1820 # ffffffffc0207f08 <commands+0x888>
ffffffffc020162c:	e5dfe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201630:	00007697          	auipc	a3,0x7
ffffffffc0201634:	93068693          	addi	a3,a3,-1744 # ffffffffc0207f60 <commands+0x8e0>
ffffffffc0201638:	00006617          	auipc	a2,0x6
ffffffffc020163c:	50860613          	addi	a2,a2,1288 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201640:	0b900593          	li	a1,185
ffffffffc0201644:	00007517          	auipc	a0,0x7
ffffffffc0201648:	8c450513          	addi	a0,a0,-1852 # ffffffffc0207f08 <commands+0x888>
ffffffffc020164c:	e3dfe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201650 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201650:	1141                	addi	sp,sp,-16
ffffffffc0201652:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201654:	16058e63          	beqz	a1,ffffffffc02017d0 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc0201658:	00659693          	slli	a3,a1,0x6
ffffffffc020165c:	96aa                	add	a3,a3,a0
ffffffffc020165e:	02d50d63          	beq	a0,a3,ffffffffc0201698 <default_free_pages+0x48>
ffffffffc0201662:	651c                	ld	a5,8(a0)
ffffffffc0201664:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201666:	14079563          	bnez	a5,ffffffffc02017b0 <default_free_pages+0x160>
ffffffffc020166a:	651c                	ld	a5,8(a0)
ffffffffc020166c:	8385                	srli	a5,a5,0x1
ffffffffc020166e:	8b85                	andi	a5,a5,1
ffffffffc0201670:	14079063          	bnez	a5,ffffffffc02017b0 <default_free_pages+0x160>
ffffffffc0201674:	87aa                	mv	a5,a0
ffffffffc0201676:	a809                	j	ffffffffc0201688 <default_free_pages+0x38>
ffffffffc0201678:	6798                	ld	a4,8(a5)
ffffffffc020167a:	8b05                	andi	a4,a4,1
ffffffffc020167c:	12071a63          	bnez	a4,ffffffffc02017b0 <default_free_pages+0x160>
ffffffffc0201680:	6798                	ld	a4,8(a5)
ffffffffc0201682:	8b09                	andi	a4,a4,2
ffffffffc0201684:	12071663          	bnez	a4,ffffffffc02017b0 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc0201688:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc020168c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201690:	04078793          	addi	a5,a5,64
ffffffffc0201694:	fed792e3          	bne	a5,a3,ffffffffc0201678 <default_free_pages+0x28>
    base->property = n;
ffffffffc0201698:	2581                	sext.w	a1,a1
ffffffffc020169a:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc020169c:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02016a0:	4789                	li	a5,2
ffffffffc02016a2:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02016a6:	000de697          	auipc	a3,0xde
ffffffffc02016aa:	cf268693          	addi	a3,a3,-782 # ffffffffc02df398 <free_area>
ffffffffc02016ae:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02016b0:	669c                	ld	a5,8(a3)
ffffffffc02016b2:	9db9                	addw	a1,a1,a4
ffffffffc02016b4:	000de717          	auipc	a4,0xde
ffffffffc02016b8:	ceb72a23          	sw	a1,-780(a4) # ffffffffc02df3a8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02016bc:	0cd78163          	beq	a5,a3,ffffffffc020177e <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc02016c0:	fe878713          	addi	a4,a5,-24
ffffffffc02016c4:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02016c6:	4801                	li	a6,0
ffffffffc02016c8:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02016cc:	00e56a63          	bltu	a0,a4,ffffffffc02016e0 <default_free_pages+0x90>
    return listelm->next;
ffffffffc02016d0:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02016d2:	04d70f63          	beq	a4,a3,ffffffffc0201730 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016d6:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02016d8:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02016dc:	fee57ae3          	bleu	a4,a0,ffffffffc02016d0 <default_free_pages+0x80>
ffffffffc02016e0:	00080663          	beqz	a6,ffffffffc02016ec <default_free_pages+0x9c>
ffffffffc02016e4:	000de817          	auipc	a6,0xde
ffffffffc02016e8:	cab83a23          	sd	a1,-844(a6) # ffffffffc02df398 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02016ec:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02016ee:	e390                	sd	a2,0(a5)
ffffffffc02016f0:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02016f2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016f4:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02016f6:	06d58a63          	beq	a1,a3,ffffffffc020176a <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc02016fa:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc02016fe:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0201702:	02061793          	slli	a5,a2,0x20
ffffffffc0201706:	83e9                	srli	a5,a5,0x1a
ffffffffc0201708:	97ba                	add	a5,a5,a4
ffffffffc020170a:	04f51b63          	bne	a0,a5,ffffffffc0201760 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc020170e:	491c                	lw	a5,16(a0)
ffffffffc0201710:	9e3d                	addw	a2,a2,a5
ffffffffc0201712:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201716:	57f5                	li	a5,-3
ffffffffc0201718:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020171c:	01853803          	ld	a6,24(a0)
ffffffffc0201720:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc0201722:	853a                	mv	a0,a4
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201724:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc0201728:	659c                	ld	a5,8(a1)
ffffffffc020172a:	01063023          	sd	a6,0(a2)
ffffffffc020172e:	a815                	j	ffffffffc0201762 <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc0201730:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201732:	f114                	sd	a3,32(a0)
ffffffffc0201734:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201736:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201738:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020173a:	00d70563          	beq	a4,a3,ffffffffc0201744 <default_free_pages+0xf4>
ffffffffc020173e:	4805                	li	a6,1
ffffffffc0201740:	87ba                	mv	a5,a4
ffffffffc0201742:	bf59                	j	ffffffffc02016d8 <default_free_pages+0x88>
ffffffffc0201744:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0201746:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0201748:	00d78d63          	beq	a5,a3,ffffffffc0201762 <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc020174c:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201750:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0201754:	02061793          	slli	a5,a2,0x20
ffffffffc0201758:	83e9                	srli	a5,a5,0x1a
ffffffffc020175a:	97ba                	add	a5,a5,a4
ffffffffc020175c:	faf509e3          	beq	a0,a5,ffffffffc020170e <default_free_pages+0xbe>
ffffffffc0201760:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201762:	fe878713          	addi	a4,a5,-24
ffffffffc0201766:	00d78963          	beq	a5,a3,ffffffffc0201778 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc020176a:	4910                	lw	a2,16(a0)
ffffffffc020176c:	02061693          	slli	a3,a2,0x20
ffffffffc0201770:	82e9                	srli	a3,a3,0x1a
ffffffffc0201772:	96aa                	add	a3,a3,a0
ffffffffc0201774:	00d70e63          	beq	a4,a3,ffffffffc0201790 <default_free_pages+0x140>
}
ffffffffc0201778:	60a2                	ld	ra,8(sp)
ffffffffc020177a:	0141                	addi	sp,sp,16
ffffffffc020177c:	8082                	ret
ffffffffc020177e:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201780:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201784:	e398                	sd	a4,0(a5)
ffffffffc0201786:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201788:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020178a:	ed1c                	sd	a5,24(a0)
}
ffffffffc020178c:	0141                	addi	sp,sp,16
ffffffffc020178e:	8082                	ret
            base->property += p->property;
ffffffffc0201790:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201794:	ff078693          	addi	a3,a5,-16
ffffffffc0201798:	9e39                	addw	a2,a2,a4
ffffffffc020179a:	c910                	sw	a2,16(a0)
ffffffffc020179c:	5775                	li	a4,-3
ffffffffc020179e:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02017a2:	6398                	ld	a4,0(a5)
ffffffffc02017a4:	679c                	ld	a5,8(a5)
}
ffffffffc02017a6:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02017a8:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02017aa:	e398                	sd	a4,0(a5)
ffffffffc02017ac:	0141                	addi	sp,sp,16
ffffffffc02017ae:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02017b0:	00007697          	auipc	a3,0x7
ffffffffc02017b4:	a9868693          	addi	a3,a3,-1384 # ffffffffc0208248 <commands+0xbc8>
ffffffffc02017b8:	00006617          	auipc	a2,0x6
ffffffffc02017bc:	38860613          	addi	a2,a2,904 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02017c0:	08200593          	li	a1,130
ffffffffc02017c4:	00006517          	auipc	a0,0x6
ffffffffc02017c8:	74450513          	addi	a0,a0,1860 # ffffffffc0207f08 <commands+0x888>
ffffffffc02017cc:	cbdfe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(n > 0);
ffffffffc02017d0:	00007697          	auipc	a3,0x7
ffffffffc02017d4:	aa068693          	addi	a3,a3,-1376 # ffffffffc0208270 <commands+0xbf0>
ffffffffc02017d8:	00006617          	auipc	a2,0x6
ffffffffc02017dc:	36860613          	addi	a2,a2,872 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02017e0:	07f00593          	li	a1,127
ffffffffc02017e4:	00006517          	auipc	a0,0x6
ffffffffc02017e8:	72450513          	addi	a0,a0,1828 # ffffffffc0207f08 <commands+0x888>
ffffffffc02017ec:	c9dfe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02017f0 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02017f0:	c959                	beqz	a0,ffffffffc0201886 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02017f2:	000de597          	auipc	a1,0xde
ffffffffc02017f6:	ba658593          	addi	a1,a1,-1114 # ffffffffc02df398 <free_area>
ffffffffc02017fa:	0105a803          	lw	a6,16(a1)
ffffffffc02017fe:	862a                	mv	a2,a0
ffffffffc0201800:	02081793          	slli	a5,a6,0x20
ffffffffc0201804:	9381                	srli	a5,a5,0x20
ffffffffc0201806:	00a7ee63          	bltu	a5,a0,ffffffffc0201822 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc020180a:	87ae                	mv	a5,a1
ffffffffc020180c:	a801                	j	ffffffffc020181c <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc020180e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201812:	02071693          	slli	a3,a4,0x20
ffffffffc0201816:	9281                	srli	a3,a3,0x20
ffffffffc0201818:	00c6f763          	bleu	a2,a3,ffffffffc0201826 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc020181c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020181e:	feb798e3          	bne	a5,a1,ffffffffc020180e <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201822:	4501                	li	a0,0
}
ffffffffc0201824:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0201826:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc020182a:	dd6d                	beqz	a0,ffffffffc0201824 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc020182c:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201830:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0201834:	00060e1b          	sext.w	t3,a2
ffffffffc0201838:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc020183c:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201840:	02d67863          	bleu	a3,a2,ffffffffc0201870 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc0201844:	061a                	slli	a2,a2,0x6
ffffffffc0201846:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc0201848:	41c7073b          	subw	a4,a4,t3
ffffffffc020184c:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020184e:	00860693          	addi	a3,a2,8
ffffffffc0201852:	4709                	li	a4,2
ffffffffc0201854:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201858:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020185c:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0201860:	0105a803          	lw	a6,16(a1)
ffffffffc0201864:	e314                	sd	a3,0(a4)
ffffffffc0201866:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc020186a:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc020186c:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0201870:	41c8083b          	subw	a6,a6,t3
ffffffffc0201874:	000de717          	auipc	a4,0xde
ffffffffc0201878:	b3072a23          	sw	a6,-1228(a4) # ffffffffc02df3a8 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020187c:	5775                	li	a4,-3
ffffffffc020187e:	17c1                	addi	a5,a5,-16
ffffffffc0201880:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201884:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201886:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201888:	00007697          	auipc	a3,0x7
ffffffffc020188c:	9e868693          	addi	a3,a3,-1560 # ffffffffc0208270 <commands+0xbf0>
ffffffffc0201890:	00006617          	auipc	a2,0x6
ffffffffc0201894:	2b060613          	addi	a2,a2,688 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201898:	06100593          	li	a1,97
ffffffffc020189c:	00006517          	auipc	a0,0x6
ffffffffc02018a0:	66c50513          	addi	a0,a0,1644 # ffffffffc0207f08 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc02018a4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02018a6:	be3fe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02018aa <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02018aa:	1141                	addi	sp,sp,-16
ffffffffc02018ac:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02018ae:	c1ed                	beqz	a1,ffffffffc0201990 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc02018b0:	00659693          	slli	a3,a1,0x6
ffffffffc02018b4:	96aa                	add	a3,a3,a0
ffffffffc02018b6:	02d50463          	beq	a0,a3,ffffffffc02018de <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02018ba:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02018bc:	87aa                	mv	a5,a0
ffffffffc02018be:	8b05                	andi	a4,a4,1
ffffffffc02018c0:	e709                	bnez	a4,ffffffffc02018ca <default_init_memmap+0x20>
ffffffffc02018c2:	a07d                	j	ffffffffc0201970 <default_init_memmap+0xc6>
ffffffffc02018c4:	6798                	ld	a4,8(a5)
ffffffffc02018c6:	8b05                	andi	a4,a4,1
ffffffffc02018c8:	c745                	beqz	a4,ffffffffc0201970 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc02018ca:	0007a823          	sw	zero,16(a5)
ffffffffc02018ce:	0007b423          	sd	zero,8(a5)
ffffffffc02018d2:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02018d6:	04078793          	addi	a5,a5,64
ffffffffc02018da:	fed795e3          	bne	a5,a3,ffffffffc02018c4 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc02018de:	2581                	sext.w	a1,a1
ffffffffc02018e0:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02018e2:	4789                	li	a5,2
ffffffffc02018e4:	00850713          	addi	a4,a0,8
ffffffffc02018e8:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02018ec:	000de697          	auipc	a3,0xde
ffffffffc02018f0:	aac68693          	addi	a3,a3,-1364 # ffffffffc02df398 <free_area>
ffffffffc02018f4:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02018f6:	669c                	ld	a5,8(a3)
ffffffffc02018f8:	9db9                	addw	a1,a1,a4
ffffffffc02018fa:	000de717          	auipc	a4,0xde
ffffffffc02018fe:	aab72723          	sw	a1,-1362(a4) # ffffffffc02df3a8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201902:	04d78a63          	beq	a5,a3,ffffffffc0201956 <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc0201906:	fe878713          	addi	a4,a5,-24
ffffffffc020190a:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020190c:	4801                	li	a6,0
ffffffffc020190e:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201912:	00e56a63          	bltu	a0,a4,ffffffffc0201926 <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc0201916:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201918:	02d70563          	beq	a4,a3,ffffffffc0201942 <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020191c:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020191e:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201922:	fee57ae3          	bleu	a4,a0,ffffffffc0201916 <default_init_memmap+0x6c>
ffffffffc0201926:	00080663          	beqz	a6,ffffffffc0201932 <default_init_memmap+0x88>
ffffffffc020192a:	000de717          	auipc	a4,0xde
ffffffffc020192e:	a6b73723          	sd	a1,-1426(a4) # ffffffffc02df398 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201932:	6398                	ld	a4,0(a5)
}
ffffffffc0201934:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201936:	e390                	sd	a2,0(a5)
ffffffffc0201938:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020193a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020193c:	ed18                	sd	a4,24(a0)
ffffffffc020193e:	0141                	addi	sp,sp,16
ffffffffc0201940:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201942:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201944:	f114                	sd	a3,32(a0)
ffffffffc0201946:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201948:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020194a:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020194c:	00d70e63          	beq	a4,a3,ffffffffc0201968 <default_init_memmap+0xbe>
ffffffffc0201950:	4805                	li	a6,1
ffffffffc0201952:	87ba                	mv	a5,a4
ffffffffc0201954:	b7e9                	j	ffffffffc020191e <default_init_memmap+0x74>
}
ffffffffc0201956:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201958:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020195c:	e398                	sd	a4,0(a5)
ffffffffc020195e:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201960:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201962:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201964:	0141                	addi	sp,sp,16
ffffffffc0201966:	8082                	ret
ffffffffc0201968:	60a2                	ld	ra,8(sp)
ffffffffc020196a:	e290                	sd	a2,0(a3)
ffffffffc020196c:	0141                	addi	sp,sp,16
ffffffffc020196e:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201970:	00007697          	auipc	a3,0x7
ffffffffc0201974:	90868693          	addi	a3,a3,-1784 # ffffffffc0208278 <commands+0xbf8>
ffffffffc0201978:	00006617          	auipc	a2,0x6
ffffffffc020197c:	1c860613          	addi	a2,a2,456 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201980:	04800593          	li	a1,72
ffffffffc0201984:	00006517          	auipc	a0,0x6
ffffffffc0201988:	58450513          	addi	a0,a0,1412 # ffffffffc0207f08 <commands+0x888>
ffffffffc020198c:	afdfe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(n > 0);
ffffffffc0201990:	00007697          	auipc	a3,0x7
ffffffffc0201994:	8e068693          	addi	a3,a3,-1824 # ffffffffc0208270 <commands+0xbf0>
ffffffffc0201998:	00006617          	auipc	a2,0x6
ffffffffc020199c:	1a860613          	addi	a2,a2,424 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02019a0:	04500593          	li	a1,69
ffffffffc02019a4:	00006517          	auipc	a0,0x6
ffffffffc02019a8:	56450513          	addi	a0,a0,1380 # ffffffffc0207f08 <commands+0x888>
ffffffffc02019ac:	addfe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02019b0 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02019b0:	c125                	beqz	a0,ffffffffc0201a10 <slob_free+0x60>
		return;

	if (size)
ffffffffc02019b2:	e1a5                	bnez	a1,ffffffffc0201a12 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019b4:	100027f3          	csrr	a5,sstatus
ffffffffc02019b8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02019ba:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019bc:	e3bd                	bnez	a5,ffffffffc0201a22 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019be:	000d2797          	auipc	a5,0xd2
ffffffffc02019c2:	52a78793          	addi	a5,a5,1322 # ffffffffc02d3ee8 <slobfree>
ffffffffc02019c6:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019c8:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019ca:	00a7fa63          	bleu	a0,a5,ffffffffc02019de <slob_free+0x2e>
ffffffffc02019ce:	00e56c63          	bltu	a0,a4,ffffffffc02019e6 <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019d2:	00e7fa63          	bleu	a4,a5,ffffffffc02019e6 <slob_free+0x36>
    return 0;
ffffffffc02019d6:	87ba                	mv	a5,a4
ffffffffc02019d8:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019da:	fea7eae3          	bltu	a5,a0,ffffffffc02019ce <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019de:	fee7ece3          	bltu	a5,a4,ffffffffc02019d6 <slob_free+0x26>
ffffffffc02019e2:	fee57ae3          	bleu	a4,a0,ffffffffc02019d6 <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc02019e6:	4110                	lw	a2,0(a0)
ffffffffc02019e8:	00461693          	slli	a3,a2,0x4
ffffffffc02019ec:	96aa                	add	a3,a3,a0
ffffffffc02019ee:	08d70b63          	beq	a4,a3,ffffffffc0201a84 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02019f2:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc02019f4:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02019f6:	00469713          	slli	a4,a3,0x4
ffffffffc02019fa:	973e                	add	a4,a4,a5
ffffffffc02019fc:	08e50f63          	beq	a0,a4,ffffffffc0201a9a <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201a00:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc0201a02:	000d2717          	auipc	a4,0xd2
ffffffffc0201a06:	4ef73323          	sd	a5,1254(a4) # ffffffffc02d3ee8 <slobfree>
    if (flag) {
ffffffffc0201a0a:	c199                	beqz	a1,ffffffffc0201a10 <slob_free+0x60>
        intr_enable();
ffffffffc0201a0c:	c41fe06f          	j	ffffffffc020064c <intr_enable>
ffffffffc0201a10:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc0201a12:	05bd                	addi	a1,a1,15
ffffffffc0201a14:	8191                	srli	a1,a1,0x4
ffffffffc0201a16:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a18:	100027f3          	csrr	a5,sstatus
ffffffffc0201a1c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201a1e:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a20:	dfd9                	beqz	a5,ffffffffc02019be <slob_free+0xe>
{
ffffffffc0201a22:	1101                	addi	sp,sp,-32
ffffffffc0201a24:	e42a                	sd	a0,8(sp)
ffffffffc0201a26:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201a28:	c2bfe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a2c:	000d2797          	auipc	a5,0xd2
ffffffffc0201a30:	4bc78793          	addi	a5,a5,1212 # ffffffffc02d3ee8 <slobfree>
ffffffffc0201a34:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0201a36:	6522                	ld	a0,8(sp)
ffffffffc0201a38:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a3a:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a3c:	00a7fa63          	bleu	a0,a5,ffffffffc0201a50 <slob_free+0xa0>
ffffffffc0201a40:	00e56c63          	bltu	a0,a4,ffffffffc0201a58 <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a44:	00e7fa63          	bleu	a4,a5,ffffffffc0201a58 <slob_free+0xa8>
    return 0;
ffffffffc0201a48:	87ba                	mv	a5,a4
ffffffffc0201a4a:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a4c:	fea7eae3          	bltu	a5,a0,ffffffffc0201a40 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a50:	fee7ece3          	bltu	a5,a4,ffffffffc0201a48 <slob_free+0x98>
ffffffffc0201a54:	fee57ae3          	bleu	a4,a0,ffffffffc0201a48 <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0201a58:	4110                	lw	a2,0(a0)
ffffffffc0201a5a:	00461693          	slli	a3,a2,0x4
ffffffffc0201a5e:	96aa                	add	a3,a3,a0
ffffffffc0201a60:	04d70763          	beq	a4,a3,ffffffffc0201aae <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0201a64:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a66:	4394                	lw	a3,0(a5)
ffffffffc0201a68:	00469713          	slli	a4,a3,0x4
ffffffffc0201a6c:	973e                	add	a4,a4,a5
ffffffffc0201a6e:	04e50663          	beq	a0,a4,ffffffffc0201aba <slob_free+0x10a>
		cur->next = b;
ffffffffc0201a72:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0201a74:	000d2717          	auipc	a4,0xd2
ffffffffc0201a78:	46f73a23          	sd	a5,1140(a4) # ffffffffc02d3ee8 <slobfree>
    if (flag) {
ffffffffc0201a7c:	e58d                	bnez	a1,ffffffffc0201aa6 <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201a7e:	60e2                	ld	ra,24(sp)
ffffffffc0201a80:	6105                	addi	sp,sp,32
ffffffffc0201a82:	8082                	ret
		b->units += cur->next->units;
ffffffffc0201a84:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a86:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201a88:	9e35                	addw	a2,a2,a3
ffffffffc0201a8a:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0201a8c:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201a8e:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a90:	00469713          	slli	a4,a3,0x4
ffffffffc0201a94:	973e                	add	a4,a4,a5
ffffffffc0201a96:	f6e515e3          	bne	a0,a4,ffffffffc0201a00 <slob_free+0x50>
		cur->units += b->units;
ffffffffc0201a9a:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201a9c:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201a9e:	9eb9                	addw	a3,a3,a4
ffffffffc0201aa0:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201aa2:	e790                	sd	a2,8(a5)
ffffffffc0201aa4:	bfb9                	j	ffffffffc0201a02 <slob_free+0x52>
}
ffffffffc0201aa6:	60e2                	ld	ra,24(sp)
ffffffffc0201aa8:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201aaa:	ba3fe06f          	j	ffffffffc020064c <intr_enable>
		b->units += cur->next->units;
ffffffffc0201aae:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201ab0:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201ab2:	9e35                	addw	a2,a2,a3
ffffffffc0201ab4:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0201ab6:	e518                	sd	a4,8(a0)
ffffffffc0201ab8:	b77d                	j	ffffffffc0201a66 <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0201aba:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201abc:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201abe:	9eb9                	addw	a3,a3,a4
ffffffffc0201ac0:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201ac2:	e790                	sd	a2,8(a5)
ffffffffc0201ac4:	bf45                	j	ffffffffc0201a74 <slob_free+0xc4>

ffffffffc0201ac6 <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201ac6:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201ac8:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201aca:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201ace:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201ad0:	38e000ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
  if(!page)
ffffffffc0201ad4:	c139                	beqz	a0,ffffffffc0201b1a <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc0201ad6:	000de797          	auipc	a5,0xde
ffffffffc0201ada:	8f278793          	addi	a5,a5,-1806 # ffffffffc02df3c8 <pages>
ffffffffc0201ade:	6394                	ld	a3,0(a5)
ffffffffc0201ae0:	00009797          	auipc	a5,0x9
ffffffffc0201ae4:	e7078793          	addi	a5,a5,-400 # ffffffffc020a950 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201ae8:	000de717          	auipc	a4,0xde
ffffffffc0201aec:	86070713          	addi	a4,a4,-1952 # ffffffffc02df348 <npage>
    return page - pages + nbase;
ffffffffc0201af0:	40d506b3          	sub	a3,a0,a3
ffffffffc0201af4:	6388                	ld	a0,0(a5)
ffffffffc0201af6:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201af8:	57fd                	li	a5,-1
ffffffffc0201afa:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0201afc:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0201afe:	83b1                	srli	a5,a5,0xc
ffffffffc0201b00:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201b02:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201b04:	00e7ff63          	bleu	a4,a5,ffffffffc0201b22 <__slob_get_free_pages.isra.0+0x5c>
ffffffffc0201b08:	000de797          	auipc	a5,0xde
ffffffffc0201b0c:	8b078793          	addi	a5,a5,-1872 # ffffffffc02df3b8 <va_pa_offset>
ffffffffc0201b10:	6388                	ld	a0,0(a5)
}
ffffffffc0201b12:	60a2                	ld	ra,8(sp)
ffffffffc0201b14:	9536                	add	a0,a0,a3
ffffffffc0201b16:	0141                	addi	sp,sp,16
ffffffffc0201b18:	8082                	ret
ffffffffc0201b1a:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc0201b1c:	4501                	li	a0,0
}
ffffffffc0201b1e:	0141                	addi	sp,sp,16
ffffffffc0201b20:	8082                	ret
ffffffffc0201b22:	00006617          	auipc	a2,0x6
ffffffffc0201b26:	7b660613          	addi	a2,a2,1974 # ffffffffc02082d8 <default_pmm_manager+0x50>
ffffffffc0201b2a:	06900593          	li	a1,105
ffffffffc0201b2e:	00006517          	auipc	a0,0x6
ffffffffc0201b32:	7d250513          	addi	a0,a0,2002 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc0201b36:	953fe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201b3a <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201b3a:	7179                	addi	sp,sp,-48
ffffffffc0201b3c:	f406                	sd	ra,40(sp)
ffffffffc0201b3e:	f022                	sd	s0,32(sp)
ffffffffc0201b40:	ec26                	sd	s1,24(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201b42:	01050713          	addi	a4,a0,16
ffffffffc0201b46:	6785                	lui	a5,0x1
ffffffffc0201b48:	0cf77b63          	bleu	a5,a4,ffffffffc0201c1e <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201b4c:	00f50413          	addi	s0,a0,15
ffffffffc0201b50:	8011                	srli	s0,s0,0x4
ffffffffc0201b52:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b54:	10002673          	csrr	a2,sstatus
ffffffffc0201b58:	8a09                	andi	a2,a2,2
ffffffffc0201b5a:	ea5d                	bnez	a2,ffffffffc0201c10 <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc0201b5c:	000d2497          	auipc	s1,0xd2
ffffffffc0201b60:	38c48493          	addi	s1,s1,908 # ffffffffc02d3ee8 <slobfree>
ffffffffc0201b64:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b66:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b68:	4398                	lw	a4,0(a5)
ffffffffc0201b6a:	0a875763          	ble	s0,a4,ffffffffc0201c18 <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc0201b6e:	00f68a63          	beq	a3,a5,ffffffffc0201b82 <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b72:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b74:	4118                	lw	a4,0(a0)
ffffffffc0201b76:	02875763          	ble	s0,a4,ffffffffc0201ba4 <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc0201b7a:	6094                	ld	a3,0(s1)
ffffffffc0201b7c:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc0201b7e:	fef69ae3          	bne	a3,a5,ffffffffc0201b72 <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc0201b82:	ea39                	bnez	a2,ffffffffc0201bd8 <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201b84:	4501                	li	a0,0
ffffffffc0201b86:	f41ff0ef          	jal	ra,ffffffffc0201ac6 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201b8a:	cd29                	beqz	a0,ffffffffc0201be4 <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201b8c:	6585                	lui	a1,0x1
ffffffffc0201b8e:	e23ff0ef          	jal	ra,ffffffffc02019b0 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b92:	10002673          	csrr	a2,sstatus
ffffffffc0201b96:	8a09                	andi	a2,a2,2
ffffffffc0201b98:	ea1d                	bnez	a2,ffffffffc0201bce <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc0201b9a:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b9c:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b9e:	4118                	lw	a4,0(a0)
ffffffffc0201ba0:	fc874de3          	blt	a4,s0,ffffffffc0201b7a <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc0201ba4:	04e40663          	beq	s0,a4,ffffffffc0201bf0 <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc0201ba8:	00441693          	slli	a3,s0,0x4
ffffffffc0201bac:	96aa                	add	a3,a3,a0
ffffffffc0201bae:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201bb0:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc0201bb2:	9f01                	subw	a4,a4,s0
ffffffffc0201bb4:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201bb6:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201bb8:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc0201bba:	000d2717          	auipc	a4,0xd2
ffffffffc0201bbe:	32f73723          	sd	a5,814(a4) # ffffffffc02d3ee8 <slobfree>
    if (flag) {
ffffffffc0201bc2:	ee15                	bnez	a2,ffffffffc0201bfe <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc0201bc4:	70a2                	ld	ra,40(sp)
ffffffffc0201bc6:	7402                	ld	s0,32(sp)
ffffffffc0201bc8:	64e2                	ld	s1,24(sp)
ffffffffc0201bca:	6145                	addi	sp,sp,48
ffffffffc0201bcc:	8082                	ret
        intr_disable();
ffffffffc0201bce:	a85fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201bd2:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0201bd4:	609c                	ld	a5,0(s1)
ffffffffc0201bd6:	b7d9                	j	ffffffffc0201b9c <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc0201bd8:	a75fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201bdc:	4501                	li	a0,0
ffffffffc0201bde:	ee9ff0ef          	jal	ra,ffffffffc0201ac6 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201be2:	f54d                	bnez	a0,ffffffffc0201b8c <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc0201be4:	70a2                	ld	ra,40(sp)
ffffffffc0201be6:	7402                	ld	s0,32(sp)
ffffffffc0201be8:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc0201bea:	4501                	li	a0,0
}
ffffffffc0201bec:	6145                	addi	sp,sp,48
ffffffffc0201bee:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201bf0:	6518                	ld	a4,8(a0)
ffffffffc0201bf2:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc0201bf4:	000d2717          	auipc	a4,0xd2
ffffffffc0201bf8:	2ef73a23          	sd	a5,756(a4) # ffffffffc02d3ee8 <slobfree>
    if (flag) {
ffffffffc0201bfc:	d661                	beqz	a2,ffffffffc0201bc4 <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc0201bfe:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201c00:	a4dfe0ef          	jal	ra,ffffffffc020064c <intr_enable>
}
ffffffffc0201c04:	70a2                	ld	ra,40(sp)
ffffffffc0201c06:	7402                	ld	s0,32(sp)
ffffffffc0201c08:	6522                	ld	a0,8(sp)
ffffffffc0201c0a:	64e2                	ld	s1,24(sp)
ffffffffc0201c0c:	6145                	addi	sp,sp,48
ffffffffc0201c0e:	8082                	ret
        intr_disable();
ffffffffc0201c10:	a43fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201c14:	4605                	li	a2,1
ffffffffc0201c16:	b799                	j	ffffffffc0201b5c <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201c18:	853e                	mv	a0,a5
ffffffffc0201c1a:	87b6                	mv	a5,a3
ffffffffc0201c1c:	b761                	j	ffffffffc0201ba4 <slob_alloc.isra.1.constprop.3+0x6a>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201c1e:	00006697          	auipc	a3,0x6
ffffffffc0201c22:	75a68693          	addi	a3,a3,1882 # ffffffffc0208378 <default_pmm_manager+0xf0>
ffffffffc0201c26:	00006617          	auipc	a2,0x6
ffffffffc0201c2a:	f1a60613          	addi	a2,a2,-230 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0201c2e:	06400593          	li	a1,100
ffffffffc0201c32:	00006517          	auipc	a0,0x6
ffffffffc0201c36:	76650513          	addi	a0,a0,1894 # ffffffffc0208398 <default_pmm_manager+0x110>
ffffffffc0201c3a:	84ffe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201c3e <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201c3e:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201c40:	00006517          	auipc	a0,0x6
ffffffffc0201c44:	77050513          	addi	a0,a0,1904 # ffffffffc02083b0 <default_pmm_manager+0x128>
kmalloc_init(void) {
ffffffffc0201c48:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201c4a:	d48fe0ef          	jal	ra,ffffffffc0200192 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201c4e:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c50:	00006517          	auipc	a0,0x6
ffffffffc0201c54:	70850513          	addi	a0,a0,1800 # ffffffffc0208358 <default_pmm_manager+0xd0>
}
ffffffffc0201c58:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c5a:	d38fe06f          	j	ffffffffc0200192 <cprintf>

ffffffffc0201c5e <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201c5e:	4501                	li	a0,0
ffffffffc0201c60:	8082                	ret

ffffffffc0201c62 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201c62:	1101                	addi	sp,sp,-32
ffffffffc0201c64:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c66:	6905                	lui	s2,0x1
{
ffffffffc0201c68:	e822                	sd	s0,16(sp)
ffffffffc0201c6a:	ec06                	sd	ra,24(sp)
ffffffffc0201c6c:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c6e:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8ae9>
{
ffffffffc0201c72:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c74:	04a7fc63          	bleu	a0,a5,ffffffffc0201ccc <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201c78:	4561                	li	a0,24
ffffffffc0201c7a:	ec1ff0ef          	jal	ra,ffffffffc0201b3a <slob_alloc.isra.1.constprop.3>
ffffffffc0201c7e:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201c80:	cd21                	beqz	a0,ffffffffc0201cd8 <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0201c82:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201c86:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c88:	00f95763          	ble	a5,s2,ffffffffc0201c96 <kmalloc+0x34>
ffffffffc0201c8c:	6705                	lui	a4,0x1
ffffffffc0201c8e:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201c90:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c92:	fef74ee3          	blt	a4,a5,ffffffffc0201c8e <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201c96:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201c98:	e2fff0ef          	jal	ra,ffffffffc0201ac6 <__slob_get_free_pages.isra.0>
ffffffffc0201c9c:	e488                	sd	a0,8(s1)
ffffffffc0201c9e:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201ca0:	c935                	beqz	a0,ffffffffc0201d14 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ca2:	100027f3          	csrr	a5,sstatus
ffffffffc0201ca6:	8b89                	andi	a5,a5,2
ffffffffc0201ca8:	e3a1                	bnez	a5,ffffffffc0201ce8 <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0201caa:	000dd797          	auipc	a5,0xdd
ffffffffc0201cae:	68e78793          	addi	a5,a5,1678 # ffffffffc02df338 <bigblocks>
ffffffffc0201cb2:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201cb4:	000dd717          	auipc	a4,0xdd
ffffffffc0201cb8:	68973223          	sd	s1,1668(a4) # ffffffffc02df338 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201cbc:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201cbe:	8522                	mv	a0,s0
ffffffffc0201cc0:	60e2                	ld	ra,24(sp)
ffffffffc0201cc2:	6442                	ld	s0,16(sp)
ffffffffc0201cc4:	64a2                	ld	s1,8(sp)
ffffffffc0201cc6:	6902                	ld	s2,0(sp)
ffffffffc0201cc8:	6105                	addi	sp,sp,32
ffffffffc0201cca:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201ccc:	0541                	addi	a0,a0,16
ffffffffc0201cce:	e6dff0ef          	jal	ra,ffffffffc0201b3a <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201cd2:	01050413          	addi	s0,a0,16
ffffffffc0201cd6:	f565                	bnez	a0,ffffffffc0201cbe <kmalloc+0x5c>
ffffffffc0201cd8:	4401                	li	s0,0
}
ffffffffc0201cda:	8522                	mv	a0,s0
ffffffffc0201cdc:	60e2                	ld	ra,24(sp)
ffffffffc0201cde:	6442                	ld	s0,16(sp)
ffffffffc0201ce0:	64a2                	ld	s1,8(sp)
ffffffffc0201ce2:	6902                	ld	s2,0(sp)
ffffffffc0201ce4:	6105                	addi	sp,sp,32
ffffffffc0201ce6:	8082                	ret
        intr_disable();
ffffffffc0201ce8:	96bfe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201cec:	000dd797          	auipc	a5,0xdd
ffffffffc0201cf0:	64c78793          	addi	a5,a5,1612 # ffffffffc02df338 <bigblocks>
ffffffffc0201cf4:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201cf6:	000dd717          	auipc	a4,0xdd
ffffffffc0201cfa:	64973123          	sd	s1,1602(a4) # ffffffffc02df338 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201cfe:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201d00:	94dfe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201d04:	6480                	ld	s0,8(s1)
}
ffffffffc0201d06:	60e2                	ld	ra,24(sp)
ffffffffc0201d08:	64a2                	ld	s1,8(sp)
ffffffffc0201d0a:	8522                	mv	a0,s0
ffffffffc0201d0c:	6442                	ld	s0,16(sp)
ffffffffc0201d0e:	6902                	ld	s2,0(sp)
ffffffffc0201d10:	6105                	addi	sp,sp,32
ffffffffc0201d12:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d14:	45e1                	li	a1,24
ffffffffc0201d16:	8526                	mv	a0,s1
ffffffffc0201d18:	c99ff0ef          	jal	ra,ffffffffc02019b0 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201d1c:	b74d                	j	ffffffffc0201cbe <kmalloc+0x5c>

ffffffffc0201d1e <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201d1e:	c175                	beqz	a0,ffffffffc0201e02 <kfree+0xe4>
{
ffffffffc0201d20:	1101                	addi	sp,sp,-32
ffffffffc0201d22:	e426                	sd	s1,8(sp)
ffffffffc0201d24:	ec06                	sd	ra,24(sp)
ffffffffc0201d26:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201d28:	03451793          	slli	a5,a0,0x34
ffffffffc0201d2c:	84aa                	mv	s1,a0
ffffffffc0201d2e:	eb8d                	bnez	a5,ffffffffc0201d60 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d30:	100027f3          	csrr	a5,sstatus
ffffffffc0201d34:	8b89                	andi	a5,a5,2
ffffffffc0201d36:	efc9                	bnez	a5,ffffffffc0201dd0 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d38:	000dd797          	auipc	a5,0xdd
ffffffffc0201d3c:	60078793          	addi	a5,a5,1536 # ffffffffc02df338 <bigblocks>
ffffffffc0201d40:	6394                	ld	a3,0(a5)
ffffffffc0201d42:	ce99                	beqz	a3,ffffffffc0201d60 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201d44:	669c                	ld	a5,8(a3)
ffffffffc0201d46:	6a80                	ld	s0,16(a3)
ffffffffc0201d48:	0af50e63          	beq	a0,a5,ffffffffc0201e04 <kfree+0xe6>
    return 0;
ffffffffc0201d4c:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d4e:	c801                	beqz	s0,ffffffffc0201d5e <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0201d50:	6418                	ld	a4,8(s0)
ffffffffc0201d52:	681c                	ld	a5,16(s0)
ffffffffc0201d54:	00970f63          	beq	a4,s1,ffffffffc0201d72 <kfree+0x54>
ffffffffc0201d58:	86a2                	mv	a3,s0
ffffffffc0201d5a:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d5c:	f875                	bnez	s0,ffffffffc0201d50 <kfree+0x32>
    if (flag) {
ffffffffc0201d5e:	e659                	bnez	a2,ffffffffc0201dec <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201d60:	6442                	ld	s0,16(sp)
ffffffffc0201d62:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d64:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201d68:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d6a:	4581                	li	a1,0
}
ffffffffc0201d6c:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d6e:	c43ff06f          	j	ffffffffc02019b0 <slob_free>
				*last = bb->next;
ffffffffc0201d72:	ea9c                	sd	a5,16(a3)
ffffffffc0201d74:	e641                	bnez	a2,ffffffffc0201dfc <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0201d76:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201d7a:	4018                	lw	a4,0(s0)
ffffffffc0201d7c:	08f4ea63          	bltu	s1,a5,ffffffffc0201e10 <kfree+0xf2>
ffffffffc0201d80:	000dd797          	auipc	a5,0xdd
ffffffffc0201d84:	63878793          	addi	a5,a5,1592 # ffffffffc02df3b8 <va_pa_offset>
ffffffffc0201d88:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201d8a:	000dd797          	auipc	a5,0xdd
ffffffffc0201d8e:	5be78793          	addi	a5,a5,1470 # ffffffffc02df348 <npage>
ffffffffc0201d92:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201d94:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201d96:	80b1                	srli	s1,s1,0xc
ffffffffc0201d98:	08f4f963          	bleu	a5,s1,ffffffffc0201e2a <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d9c:	00009797          	auipc	a5,0x9
ffffffffc0201da0:	bb478793          	addi	a5,a5,-1100 # ffffffffc020a950 <nbase>
ffffffffc0201da4:	639c                	ld	a5,0(a5)
ffffffffc0201da6:	000dd697          	auipc	a3,0xdd
ffffffffc0201daa:	62268693          	addi	a3,a3,1570 # ffffffffc02df3c8 <pages>
ffffffffc0201dae:	6288                	ld	a0,0(a3)
ffffffffc0201db0:	8c9d                	sub	s1,s1,a5
ffffffffc0201db2:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201db4:	4585                	li	a1,1
ffffffffc0201db6:	9526                	add	a0,a0,s1
ffffffffc0201db8:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201dbc:	12a000ef          	jal	ra,ffffffffc0201ee6 <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201dc0:	8522                	mv	a0,s0
}
ffffffffc0201dc2:	6442                	ld	s0,16(sp)
ffffffffc0201dc4:	60e2                	ld	ra,24(sp)
ffffffffc0201dc6:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201dc8:	45e1                	li	a1,24
}
ffffffffc0201dca:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201dcc:	be5ff06f          	j	ffffffffc02019b0 <slob_free>
        intr_disable();
ffffffffc0201dd0:	883fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201dd4:	000dd797          	auipc	a5,0xdd
ffffffffc0201dd8:	56478793          	addi	a5,a5,1380 # ffffffffc02df338 <bigblocks>
ffffffffc0201ddc:	6394                	ld	a3,0(a5)
ffffffffc0201dde:	c699                	beqz	a3,ffffffffc0201dec <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0201de0:	669c                	ld	a5,8(a3)
ffffffffc0201de2:	6a80                	ld	s0,16(a3)
ffffffffc0201de4:	00f48763          	beq	s1,a5,ffffffffc0201df2 <kfree+0xd4>
        return 1;
ffffffffc0201de8:	4605                	li	a2,1
ffffffffc0201dea:	b795                	j	ffffffffc0201d4e <kfree+0x30>
        intr_enable();
ffffffffc0201dec:	861fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201df0:	bf85                	j	ffffffffc0201d60 <kfree+0x42>
				*last = bb->next;
ffffffffc0201df2:	000dd797          	auipc	a5,0xdd
ffffffffc0201df6:	5487b323          	sd	s0,1350(a5) # ffffffffc02df338 <bigblocks>
ffffffffc0201dfa:	8436                	mv	s0,a3
ffffffffc0201dfc:	851fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201e00:	bf9d                	j	ffffffffc0201d76 <kfree+0x58>
ffffffffc0201e02:	8082                	ret
ffffffffc0201e04:	000dd797          	auipc	a5,0xdd
ffffffffc0201e08:	5287ba23          	sd	s0,1332(a5) # ffffffffc02df338 <bigblocks>
ffffffffc0201e0c:	8436                	mv	s0,a3
ffffffffc0201e0e:	b7a5                	j	ffffffffc0201d76 <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0201e10:	86a6                	mv	a3,s1
ffffffffc0201e12:	00006617          	auipc	a2,0x6
ffffffffc0201e16:	4fe60613          	addi	a2,a2,1278 # ffffffffc0208310 <default_pmm_manager+0x88>
ffffffffc0201e1a:	06e00593          	li	a1,110
ffffffffc0201e1e:	00006517          	auipc	a0,0x6
ffffffffc0201e22:	4e250513          	addi	a0,a0,1250 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc0201e26:	e62fe0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201e2a:	00006617          	auipc	a2,0x6
ffffffffc0201e2e:	50e60613          	addi	a2,a2,1294 # ffffffffc0208338 <default_pmm_manager+0xb0>
ffffffffc0201e32:	06200593          	li	a1,98
ffffffffc0201e36:	00006517          	auipc	a0,0x6
ffffffffc0201e3a:	4ca50513          	addi	a0,a0,1226 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc0201e3e:	e4afe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201e42 <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0201e42:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201e44:	00006617          	auipc	a2,0x6
ffffffffc0201e48:	4f460613          	addi	a2,a2,1268 # ffffffffc0208338 <default_pmm_manager+0xb0>
ffffffffc0201e4c:	06200593          	li	a1,98
ffffffffc0201e50:	00006517          	auipc	a0,0x6
ffffffffc0201e54:	4b050513          	addi	a0,a0,1200 # ffffffffc0208300 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201e58:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201e5a:	e2efe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201e5e <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201e5e:	715d                	addi	sp,sp,-80
ffffffffc0201e60:	e0a2                	sd	s0,64(sp)
ffffffffc0201e62:	fc26                	sd	s1,56(sp)
ffffffffc0201e64:	f84a                	sd	s2,48(sp)
ffffffffc0201e66:	f44e                	sd	s3,40(sp)
ffffffffc0201e68:	f052                	sd	s4,32(sp)
ffffffffc0201e6a:	ec56                	sd	s5,24(sp)
ffffffffc0201e6c:	e486                	sd	ra,72(sp)
ffffffffc0201e6e:	842a                	mv	s0,a0
ffffffffc0201e70:	000dd497          	auipc	s1,0xdd
ffffffffc0201e74:	54048493          	addi	s1,s1,1344 # ffffffffc02df3b0 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e78:	4985                	li	s3,1
ffffffffc0201e7a:	000dda17          	auipc	s4,0xdd
ffffffffc0201e7e:	4dea0a13          	addi	s4,s4,1246 # ffffffffc02df358 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e82:	0005091b          	sext.w	s2,a0
ffffffffc0201e86:	000dda97          	auipc	s5,0xdd
ffffffffc0201e8a:	622a8a93          	addi	s5,s5,1570 # ffffffffc02df4a8 <check_mm_struct>
ffffffffc0201e8e:	a00d                	j	ffffffffc0201eb0 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201e90:	609c                	ld	a5,0(s1)
ffffffffc0201e92:	6f9c                	ld	a5,24(a5)
ffffffffc0201e94:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e96:	4601                	li	a2,0
ffffffffc0201e98:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e9a:	ed0d                	bnez	a0,ffffffffc0201ed4 <alloc_pages+0x76>
ffffffffc0201e9c:	0289ec63          	bltu	s3,s0,ffffffffc0201ed4 <alloc_pages+0x76>
ffffffffc0201ea0:	000a2783          	lw	a5,0(s4)
ffffffffc0201ea4:	2781                	sext.w	a5,a5
ffffffffc0201ea6:	c79d                	beqz	a5,ffffffffc0201ed4 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201ea8:	000ab503          	ld	a0,0(s5)
ffffffffc0201eac:	48d010ef          	jal	ra,ffffffffc0203b38 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201eb0:	100027f3          	csrr	a5,sstatus
ffffffffc0201eb4:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201eb6:	8522                	mv	a0,s0
ffffffffc0201eb8:	dfe1                	beqz	a5,ffffffffc0201e90 <alloc_pages+0x32>
        intr_disable();
ffffffffc0201eba:	f98fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201ebe:	609c                	ld	a5,0(s1)
ffffffffc0201ec0:	8522                	mv	a0,s0
ffffffffc0201ec2:	6f9c                	ld	a5,24(a5)
ffffffffc0201ec4:	9782                	jalr	a5
ffffffffc0201ec6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201ec8:	f84fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201ecc:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0201ece:	4601                	li	a2,0
ffffffffc0201ed0:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201ed2:	d569                	beqz	a0,ffffffffc0201e9c <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201ed4:	60a6                	ld	ra,72(sp)
ffffffffc0201ed6:	6406                	ld	s0,64(sp)
ffffffffc0201ed8:	74e2                	ld	s1,56(sp)
ffffffffc0201eda:	7942                	ld	s2,48(sp)
ffffffffc0201edc:	79a2                	ld	s3,40(sp)
ffffffffc0201ede:	7a02                	ld	s4,32(sp)
ffffffffc0201ee0:	6ae2                	ld	s5,24(sp)
ffffffffc0201ee2:	6161                	addi	sp,sp,80
ffffffffc0201ee4:	8082                	ret

ffffffffc0201ee6 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ee6:	100027f3          	csrr	a5,sstatus
ffffffffc0201eea:	8b89                	andi	a5,a5,2
ffffffffc0201eec:	eb89                	bnez	a5,ffffffffc0201efe <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201eee:	000dd797          	auipc	a5,0xdd
ffffffffc0201ef2:	4c278793          	addi	a5,a5,1218 # ffffffffc02df3b0 <pmm_manager>
ffffffffc0201ef6:	639c                	ld	a5,0(a5)
ffffffffc0201ef8:	0207b303          	ld	t1,32(a5)
ffffffffc0201efc:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201efe:	1101                	addi	sp,sp,-32
ffffffffc0201f00:	ec06                	sd	ra,24(sp)
ffffffffc0201f02:	e822                	sd	s0,16(sp)
ffffffffc0201f04:	e426                	sd	s1,8(sp)
ffffffffc0201f06:	842a                	mv	s0,a0
ffffffffc0201f08:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201f0a:	f48fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201f0e:	000dd797          	auipc	a5,0xdd
ffffffffc0201f12:	4a278793          	addi	a5,a5,1186 # ffffffffc02df3b0 <pmm_manager>
ffffffffc0201f16:	639c                	ld	a5,0(a5)
ffffffffc0201f18:	85a6                	mv	a1,s1
ffffffffc0201f1a:	8522                	mv	a0,s0
ffffffffc0201f1c:	739c                	ld	a5,32(a5)
ffffffffc0201f1e:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201f20:	6442                	ld	s0,16(sp)
ffffffffc0201f22:	60e2                	ld	ra,24(sp)
ffffffffc0201f24:	64a2                	ld	s1,8(sp)
ffffffffc0201f26:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201f28:	f24fe06f          	j	ffffffffc020064c <intr_enable>

ffffffffc0201f2c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f2c:	100027f3          	csrr	a5,sstatus
ffffffffc0201f30:	8b89                	andi	a5,a5,2
ffffffffc0201f32:	eb89                	bnez	a5,ffffffffc0201f44 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f34:	000dd797          	auipc	a5,0xdd
ffffffffc0201f38:	47c78793          	addi	a5,a5,1148 # ffffffffc02df3b0 <pmm_manager>
ffffffffc0201f3c:	639c                	ld	a5,0(a5)
ffffffffc0201f3e:	0287b303          	ld	t1,40(a5)
ffffffffc0201f42:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201f44:	1141                	addi	sp,sp,-16
ffffffffc0201f46:	e406                	sd	ra,8(sp)
ffffffffc0201f48:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201f4a:	f08fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f4e:	000dd797          	auipc	a5,0xdd
ffffffffc0201f52:	46278793          	addi	a5,a5,1122 # ffffffffc02df3b0 <pmm_manager>
ffffffffc0201f56:	639c                	ld	a5,0(a5)
ffffffffc0201f58:	779c                	ld	a5,40(a5)
ffffffffc0201f5a:	9782                	jalr	a5
ffffffffc0201f5c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201f5e:	eeefe0ef          	jal	ra,ffffffffc020064c <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201f62:	8522                	mv	a0,s0
ffffffffc0201f64:	60a2                	ld	ra,8(sp)
ffffffffc0201f66:	6402                	ld	s0,0(sp)
ffffffffc0201f68:	0141                	addi	sp,sp,16
ffffffffc0201f6a:	8082                	ret

ffffffffc0201f6c <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f6c:	7139                	addi	sp,sp,-64
ffffffffc0201f6e:	f426                	sd	s1,40(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201f70:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201f74:	1ff4f493          	andi	s1,s1,511
ffffffffc0201f78:	048e                	slli	s1,s1,0x3
ffffffffc0201f7a:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f7c:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f7e:	f04a                	sd	s2,32(sp)
ffffffffc0201f80:	ec4e                	sd	s3,24(sp)
ffffffffc0201f82:	e852                	sd	s4,16(sp)
ffffffffc0201f84:	fc06                	sd	ra,56(sp)
ffffffffc0201f86:	f822                	sd	s0,48(sp)
ffffffffc0201f88:	e456                	sd	s5,8(sp)
ffffffffc0201f8a:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f8c:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f90:	892e                	mv	s2,a1
ffffffffc0201f92:	8a32                	mv	s4,a2
ffffffffc0201f94:	000dd997          	auipc	s3,0xdd
ffffffffc0201f98:	3b498993          	addi	s3,s3,948 # ffffffffc02df348 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f9c:	e7bd                	bnez	a5,ffffffffc020200a <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201f9e:	12060c63          	beqz	a2,ffffffffc02020d6 <get_pte+0x16a>
ffffffffc0201fa2:	4505                	li	a0,1
ffffffffc0201fa4:	ebbff0ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc0201fa8:	842a                	mv	s0,a0
ffffffffc0201faa:	12050663          	beqz	a0,ffffffffc02020d6 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201fae:	000ddb17          	auipc	s6,0xdd
ffffffffc0201fb2:	41ab0b13          	addi	s6,s6,1050 # ffffffffc02df3c8 <pages>
ffffffffc0201fb6:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0201fba:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201fbc:	000dd997          	auipc	s3,0xdd
ffffffffc0201fc0:	38c98993          	addi	s3,s3,908 # ffffffffc02df348 <npage>
    return page - pages + nbase;
ffffffffc0201fc4:	40a40533          	sub	a0,s0,a0
ffffffffc0201fc8:	00080ab7          	lui	s5,0x80
ffffffffc0201fcc:	8519                	srai	a0,a0,0x6
ffffffffc0201fce:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0201fd2:	c01c                	sw	a5,0(s0)
ffffffffc0201fd4:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201fd6:	9556                	add	a0,a0,s5
ffffffffc0201fd8:	83b1                	srli	a5,a5,0xc
ffffffffc0201fda:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fdc:	0532                	slli	a0,a0,0xc
ffffffffc0201fde:	14e7f363          	bleu	a4,a5,ffffffffc0202124 <get_pte+0x1b8>
ffffffffc0201fe2:	000dd797          	auipc	a5,0xdd
ffffffffc0201fe6:	3d678793          	addi	a5,a5,982 # ffffffffc02df3b8 <va_pa_offset>
ffffffffc0201fea:	639c                	ld	a5,0(a5)
ffffffffc0201fec:	6605                	lui	a2,0x1
ffffffffc0201fee:	4581                	li	a1,0
ffffffffc0201ff0:	953e                	add	a0,a0,a5
ffffffffc0201ff2:	532050ef          	jal	ra,ffffffffc0207524 <memset>
    return page - pages + nbase;
ffffffffc0201ff6:	000b3683          	ld	a3,0(s6)
ffffffffc0201ffa:	40d406b3          	sub	a3,s0,a3
ffffffffc0201ffe:	8699                	srai	a3,a3,0x6
ffffffffc0202000:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202002:	06aa                	slli	a3,a3,0xa
ffffffffc0202004:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202008:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020200a:	77fd                	lui	a5,0xfffff
ffffffffc020200c:	068a                	slli	a3,a3,0x2
ffffffffc020200e:	0009b703          	ld	a4,0(s3)
ffffffffc0202012:	8efd                	and	a3,a3,a5
ffffffffc0202014:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202018:	0ce7f163          	bleu	a4,a5,ffffffffc02020da <get_pte+0x16e>
ffffffffc020201c:	000dda97          	auipc	s5,0xdd
ffffffffc0202020:	39ca8a93          	addi	s5,s5,924 # ffffffffc02df3b8 <va_pa_offset>
ffffffffc0202024:	000ab403          	ld	s0,0(s5)
ffffffffc0202028:	01595793          	srli	a5,s2,0x15
ffffffffc020202c:	1ff7f793          	andi	a5,a5,511
ffffffffc0202030:	96a2                	add	a3,a3,s0
ffffffffc0202032:	00379413          	slli	s0,a5,0x3
ffffffffc0202036:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0202038:	6014                	ld	a3,0(s0)
ffffffffc020203a:	0016f793          	andi	a5,a3,1
ffffffffc020203e:	e3ad                	bnez	a5,ffffffffc02020a0 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202040:	080a0b63          	beqz	s4,ffffffffc02020d6 <get_pte+0x16a>
ffffffffc0202044:	4505                	li	a0,1
ffffffffc0202046:	e19ff0ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc020204a:	84aa                	mv	s1,a0
ffffffffc020204c:	c549                	beqz	a0,ffffffffc02020d6 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc020204e:	000ddb17          	auipc	s6,0xdd
ffffffffc0202052:	37ab0b13          	addi	s6,s6,890 # ffffffffc02df3c8 <pages>
ffffffffc0202056:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc020205a:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc020205c:	00080a37          	lui	s4,0x80
ffffffffc0202060:	40a48533          	sub	a0,s1,a0
ffffffffc0202064:	8519                	srai	a0,a0,0x6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202066:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc020206a:	c09c                	sw	a5,0(s1)
ffffffffc020206c:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc020206e:	9552                	add	a0,a0,s4
ffffffffc0202070:	83b1                	srli	a5,a5,0xc
ffffffffc0202072:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202074:	0532                	slli	a0,a0,0xc
ffffffffc0202076:	08e7fa63          	bleu	a4,a5,ffffffffc020210a <get_pte+0x19e>
ffffffffc020207a:	000ab783          	ld	a5,0(s5)
ffffffffc020207e:	6605                	lui	a2,0x1
ffffffffc0202080:	4581                	li	a1,0
ffffffffc0202082:	953e                	add	a0,a0,a5
ffffffffc0202084:	4a0050ef          	jal	ra,ffffffffc0207524 <memset>
    return page - pages + nbase;
ffffffffc0202088:	000b3683          	ld	a3,0(s6)
ffffffffc020208c:	40d486b3          	sub	a3,s1,a3
ffffffffc0202090:	8699                	srai	a3,a3,0x6
ffffffffc0202092:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202094:	06aa                	slli	a3,a3,0xa
ffffffffc0202096:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020209a:	e014                	sd	a3,0(s0)
ffffffffc020209c:	0009b703          	ld	a4,0(s3)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02020a0:	068a                	slli	a3,a3,0x2
ffffffffc02020a2:	757d                	lui	a0,0xfffff
ffffffffc02020a4:	8ee9                	and	a3,a3,a0
ffffffffc02020a6:	00c6d793          	srli	a5,a3,0xc
ffffffffc02020aa:	04e7f463          	bleu	a4,a5,ffffffffc02020f2 <get_pte+0x186>
ffffffffc02020ae:	000ab503          	ld	a0,0(s5)
ffffffffc02020b2:	00c95793          	srli	a5,s2,0xc
ffffffffc02020b6:	1ff7f793          	andi	a5,a5,511
ffffffffc02020ba:	96aa                	add	a3,a3,a0
ffffffffc02020bc:	00379513          	slli	a0,a5,0x3
ffffffffc02020c0:	9536                	add	a0,a0,a3
}
ffffffffc02020c2:	70e2                	ld	ra,56(sp)
ffffffffc02020c4:	7442                	ld	s0,48(sp)
ffffffffc02020c6:	74a2                	ld	s1,40(sp)
ffffffffc02020c8:	7902                	ld	s2,32(sp)
ffffffffc02020ca:	69e2                	ld	s3,24(sp)
ffffffffc02020cc:	6a42                	ld	s4,16(sp)
ffffffffc02020ce:	6aa2                	ld	s5,8(sp)
ffffffffc02020d0:	6b02                	ld	s6,0(sp)
ffffffffc02020d2:	6121                	addi	sp,sp,64
ffffffffc02020d4:	8082                	ret
            return NULL;
ffffffffc02020d6:	4501                	li	a0,0
ffffffffc02020d8:	b7ed                	j	ffffffffc02020c2 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02020da:	00006617          	auipc	a2,0x6
ffffffffc02020de:	1fe60613          	addi	a2,a2,510 # ffffffffc02082d8 <default_pmm_manager+0x50>
ffffffffc02020e2:	0fe00593          	li	a1,254
ffffffffc02020e6:	00006517          	auipc	a0,0x6
ffffffffc02020ea:	31250513          	addi	a0,a0,786 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc02020ee:	b9afe0ef          	jal	ra,ffffffffc0200488 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02020f2:	00006617          	auipc	a2,0x6
ffffffffc02020f6:	1e660613          	addi	a2,a2,486 # ffffffffc02082d8 <default_pmm_manager+0x50>
ffffffffc02020fa:	10900593          	li	a1,265
ffffffffc02020fe:	00006517          	auipc	a0,0x6
ffffffffc0202102:	2fa50513          	addi	a0,a0,762 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202106:	b82fe0ef          	jal	ra,ffffffffc0200488 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020210a:	86aa                	mv	a3,a0
ffffffffc020210c:	00006617          	auipc	a2,0x6
ffffffffc0202110:	1cc60613          	addi	a2,a2,460 # ffffffffc02082d8 <default_pmm_manager+0x50>
ffffffffc0202114:	10600593          	li	a1,262
ffffffffc0202118:	00006517          	auipc	a0,0x6
ffffffffc020211c:	2e050513          	addi	a0,a0,736 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202120:	b68fe0ef          	jal	ra,ffffffffc0200488 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202124:	86aa                	mv	a3,a0
ffffffffc0202126:	00006617          	auipc	a2,0x6
ffffffffc020212a:	1b260613          	addi	a2,a2,434 # ffffffffc02082d8 <default_pmm_manager+0x50>
ffffffffc020212e:	0fa00593          	li	a1,250
ffffffffc0202132:	00006517          	auipc	a0,0x6
ffffffffc0202136:	2c650513          	addi	a0,a0,710 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc020213a:	b4efe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020213e <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020213e:	1141                	addi	sp,sp,-16
ffffffffc0202140:	e022                	sd	s0,0(sp)
ffffffffc0202142:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202144:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202146:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202148:	e25ff0ef          	jal	ra,ffffffffc0201f6c <get_pte>
    if (ptep_store != NULL) {
ffffffffc020214c:	c011                	beqz	s0,ffffffffc0202150 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc020214e:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202150:	c129                	beqz	a0,ffffffffc0202192 <get_page+0x54>
ffffffffc0202152:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202154:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202156:	0017f713          	andi	a4,a5,1
ffffffffc020215a:	e709                	bnez	a4,ffffffffc0202164 <get_page+0x26>
}
ffffffffc020215c:	60a2                	ld	ra,8(sp)
ffffffffc020215e:	6402                	ld	s0,0(sp)
ffffffffc0202160:	0141                	addi	sp,sp,16
ffffffffc0202162:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202164:	000dd717          	auipc	a4,0xdd
ffffffffc0202168:	1e470713          	addi	a4,a4,484 # ffffffffc02df348 <npage>
ffffffffc020216c:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc020216e:	078a                	slli	a5,a5,0x2
ffffffffc0202170:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202172:	02e7f563          	bleu	a4,a5,ffffffffc020219c <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202176:	000dd717          	auipc	a4,0xdd
ffffffffc020217a:	25270713          	addi	a4,a4,594 # ffffffffc02df3c8 <pages>
ffffffffc020217e:	6308                	ld	a0,0(a4)
ffffffffc0202180:	60a2                	ld	ra,8(sp)
ffffffffc0202182:	6402                	ld	s0,0(sp)
ffffffffc0202184:	fff80737          	lui	a4,0xfff80
ffffffffc0202188:	97ba                	add	a5,a5,a4
ffffffffc020218a:	079a                	slli	a5,a5,0x6
ffffffffc020218c:	953e                	add	a0,a0,a5
ffffffffc020218e:	0141                	addi	sp,sp,16
ffffffffc0202190:	8082                	ret
ffffffffc0202192:	60a2                	ld	ra,8(sp)
ffffffffc0202194:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0202196:	4501                	li	a0,0
}
ffffffffc0202198:	0141                	addi	sp,sp,16
ffffffffc020219a:	8082                	ret
ffffffffc020219c:	ca7ff0ef          	jal	ra,ffffffffc0201e42 <pa2page.part.4>

ffffffffc02021a0 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02021a0:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02021a2:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02021a6:	ec86                	sd	ra,88(sp)
ffffffffc02021a8:	e8a2                	sd	s0,80(sp)
ffffffffc02021aa:	e4a6                	sd	s1,72(sp)
ffffffffc02021ac:	e0ca                	sd	s2,64(sp)
ffffffffc02021ae:	fc4e                	sd	s3,56(sp)
ffffffffc02021b0:	f852                	sd	s4,48(sp)
ffffffffc02021b2:	f456                	sd	s5,40(sp)
ffffffffc02021b4:	f05a                	sd	s6,32(sp)
ffffffffc02021b6:	ec5e                	sd	s7,24(sp)
ffffffffc02021b8:	e862                	sd	s8,16(sp)
ffffffffc02021ba:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02021bc:	03479713          	slli	a4,a5,0x34
ffffffffc02021c0:	eb71                	bnez	a4,ffffffffc0202294 <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc02021c2:	002007b7          	lui	a5,0x200
ffffffffc02021c6:	842e                	mv	s0,a1
ffffffffc02021c8:	0af5e663          	bltu	a1,a5,ffffffffc0202274 <unmap_range+0xd4>
ffffffffc02021cc:	8932                	mv	s2,a2
ffffffffc02021ce:	0ac5f363          	bleu	a2,a1,ffffffffc0202274 <unmap_range+0xd4>
ffffffffc02021d2:	4785                	li	a5,1
ffffffffc02021d4:	07fe                	slli	a5,a5,0x1f
ffffffffc02021d6:	08c7ef63          	bltu	a5,a2,ffffffffc0202274 <unmap_range+0xd4>
ffffffffc02021da:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02021dc:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02021de:	000ddc97          	auipc	s9,0xdd
ffffffffc02021e2:	16ac8c93          	addi	s9,s9,362 # ffffffffc02df348 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02021e6:	000ddc17          	auipc	s8,0xdd
ffffffffc02021ea:	1e2c0c13          	addi	s8,s8,482 # ffffffffc02df3c8 <pages>
ffffffffc02021ee:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02021f2:	00200b37          	lui	s6,0x200
ffffffffc02021f6:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02021fa:	4601                	li	a2,0
ffffffffc02021fc:	85a2                	mv	a1,s0
ffffffffc02021fe:	854e                	mv	a0,s3
ffffffffc0202200:	d6dff0ef          	jal	ra,ffffffffc0201f6c <get_pte>
ffffffffc0202204:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc0202206:	cd21                	beqz	a0,ffffffffc020225e <unmap_range+0xbe>
        if (*ptep != 0) {
ffffffffc0202208:	611c                	ld	a5,0(a0)
ffffffffc020220a:	e38d                	bnez	a5,ffffffffc020222c <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc020220c:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc020220e:	ff2466e3          	bltu	s0,s2,ffffffffc02021fa <unmap_range+0x5a>
}
ffffffffc0202212:	60e6                	ld	ra,88(sp)
ffffffffc0202214:	6446                	ld	s0,80(sp)
ffffffffc0202216:	64a6                	ld	s1,72(sp)
ffffffffc0202218:	6906                	ld	s2,64(sp)
ffffffffc020221a:	79e2                	ld	s3,56(sp)
ffffffffc020221c:	7a42                	ld	s4,48(sp)
ffffffffc020221e:	7aa2                	ld	s5,40(sp)
ffffffffc0202220:	7b02                	ld	s6,32(sp)
ffffffffc0202222:	6be2                	ld	s7,24(sp)
ffffffffc0202224:	6c42                	ld	s8,16(sp)
ffffffffc0202226:	6ca2                	ld	s9,8(sp)
ffffffffc0202228:	6125                	addi	sp,sp,96
ffffffffc020222a:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc020222c:	0017f713          	andi	a4,a5,1
ffffffffc0202230:	df71                	beqz	a4,ffffffffc020220c <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc0202232:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202236:	078a                	slli	a5,a5,0x2
ffffffffc0202238:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020223a:	06e7fd63          	bleu	a4,a5,ffffffffc02022b4 <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc020223e:	000c3503          	ld	a0,0(s8)
ffffffffc0202242:	97de                	add	a5,a5,s7
ffffffffc0202244:	079a                	slli	a5,a5,0x6
ffffffffc0202246:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202248:	411c                	lw	a5,0(a0)
ffffffffc020224a:	fff7871b          	addiw	a4,a5,-1
ffffffffc020224e:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202250:	cf11                	beqz	a4,ffffffffc020226c <unmap_range+0xcc>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202252:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202256:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc020225a:	9452                	add	s0,s0,s4
ffffffffc020225c:	bf4d                	j	ffffffffc020220e <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020225e:	945a                	add	s0,s0,s6
ffffffffc0202260:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0202264:	d45d                	beqz	s0,ffffffffc0202212 <unmap_range+0x72>
ffffffffc0202266:	f9246ae3          	bltu	s0,s2,ffffffffc02021fa <unmap_range+0x5a>
ffffffffc020226a:	b765                	j	ffffffffc0202212 <unmap_range+0x72>
            free_page(page);
ffffffffc020226c:	4585                	li	a1,1
ffffffffc020226e:	c79ff0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
ffffffffc0202272:	b7c5                	j	ffffffffc0202252 <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc0202274:	00006697          	auipc	a3,0x6
ffffffffc0202278:	72c68693          	addi	a3,a3,1836 # ffffffffc02089a0 <default_pmm_manager+0x718>
ffffffffc020227c:	00006617          	auipc	a2,0x6
ffffffffc0202280:	8c460613          	addi	a2,a2,-1852 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202284:	14100593          	li	a1,321
ffffffffc0202288:	00006517          	auipc	a0,0x6
ffffffffc020228c:	17050513          	addi	a0,a0,368 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202290:	9f8fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202294:	00006697          	auipc	a3,0x6
ffffffffc0202298:	6dc68693          	addi	a3,a3,1756 # ffffffffc0208970 <default_pmm_manager+0x6e8>
ffffffffc020229c:	00006617          	auipc	a2,0x6
ffffffffc02022a0:	8a460613          	addi	a2,a2,-1884 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02022a4:	14000593          	li	a1,320
ffffffffc02022a8:	00006517          	auipc	a0,0x6
ffffffffc02022ac:	15050513          	addi	a0,a0,336 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc02022b0:	9d8fe0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc02022b4:	b8fff0ef          	jal	ra,ffffffffc0201e42 <pa2page.part.4>

ffffffffc02022b8 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02022b8:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022ba:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02022be:	fc86                	sd	ra,120(sp)
ffffffffc02022c0:	f8a2                	sd	s0,112(sp)
ffffffffc02022c2:	f4a6                	sd	s1,104(sp)
ffffffffc02022c4:	f0ca                	sd	s2,96(sp)
ffffffffc02022c6:	ecce                	sd	s3,88(sp)
ffffffffc02022c8:	e8d2                	sd	s4,80(sp)
ffffffffc02022ca:	e4d6                	sd	s5,72(sp)
ffffffffc02022cc:	e0da                	sd	s6,64(sp)
ffffffffc02022ce:	fc5e                	sd	s7,56(sp)
ffffffffc02022d0:	f862                	sd	s8,48(sp)
ffffffffc02022d2:	f466                	sd	s9,40(sp)
ffffffffc02022d4:	f06a                	sd	s10,32(sp)
ffffffffc02022d6:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022d8:	03479713          	slli	a4,a5,0x34
ffffffffc02022dc:	1c071163          	bnez	a4,ffffffffc020249e <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc02022e0:	002007b7          	lui	a5,0x200
ffffffffc02022e4:	20f5e563          	bltu	a1,a5,ffffffffc02024ee <exit_range+0x236>
ffffffffc02022e8:	8b32                	mv	s6,a2
ffffffffc02022ea:	20c5f263          	bleu	a2,a1,ffffffffc02024ee <exit_range+0x236>
ffffffffc02022ee:	4785                	li	a5,1
ffffffffc02022f0:	07fe                	slli	a5,a5,0x1f
ffffffffc02022f2:	1ec7ee63          	bltu	a5,a2,ffffffffc02024ee <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02022f6:	c00009b7          	lui	s3,0xc0000
ffffffffc02022fa:	400007b7          	lui	a5,0x40000
ffffffffc02022fe:	0135f9b3          	and	s3,a1,s3
ffffffffc0202302:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0202304:	c0000337          	lui	t1,0xc0000
ffffffffc0202308:	00698933          	add	s2,s3,t1
ffffffffc020230c:	01e95913          	srli	s2,s2,0x1e
ffffffffc0202310:	1ff97913          	andi	s2,s2,511
ffffffffc0202314:	8e2a                	mv	t3,a0
ffffffffc0202316:	090e                	slli	s2,s2,0x3
ffffffffc0202318:	9972                	add	s2,s2,t3
ffffffffc020231a:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc020231e:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc0202322:	5dfd                	li	s11,-1
        if (pde1&PTE_V){
ffffffffc0202324:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202328:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc020232a:	000ddd17          	auipc	s10,0xdd
ffffffffc020232e:	01ed0d13          	addi	s10,s10,30 # ffffffffc02df348 <npage>
    return KADDR(page2pa(page));
ffffffffc0202332:	00cddd93          	srli	s11,s11,0xc
ffffffffc0202336:	000dd717          	auipc	a4,0xdd
ffffffffc020233a:	08270713          	addi	a4,a4,130 # ffffffffc02df3b8 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc020233e:	000dde97          	auipc	t4,0xdd
ffffffffc0202342:	08ae8e93          	addi	t4,t4,138 # ffffffffc02df3c8 <pages>
        if (pde1&PTE_V){
ffffffffc0202346:	e79d                	bnez	a5,ffffffffc0202374 <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc0202348:	12098963          	beqz	s3,ffffffffc020247a <exit_range+0x1c2>
ffffffffc020234c:	400007b7          	lui	a5,0x40000
ffffffffc0202350:	84ce                	mv	s1,s3
ffffffffc0202352:	97ce                	add	a5,a5,s3
ffffffffc0202354:	1369f363          	bleu	s6,s3,ffffffffc020247a <exit_range+0x1c2>
ffffffffc0202358:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc020235a:	00698933          	add	s2,s3,t1
ffffffffc020235e:	01e95913          	srli	s2,s2,0x1e
ffffffffc0202362:	1ff97913          	andi	s2,s2,511
ffffffffc0202366:	090e                	slli	s2,s2,0x3
ffffffffc0202368:	9972                	add	s2,s2,t3
ffffffffc020236a:	00093b83          	ld	s7,0(s2)
        if (pde1&PTE_V){
ffffffffc020236e:	001bf793          	andi	a5,s7,1
ffffffffc0202372:	dbf9                	beqz	a5,ffffffffc0202348 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0202374:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202378:	0b8a                	slli	s7,s7,0x2
ffffffffc020237a:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc020237e:	14fbfc63          	bleu	a5,s7,ffffffffc02024d6 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202382:	fff80ab7          	lui	s5,0xfff80
ffffffffc0202386:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc0202388:	000806b7          	lui	a3,0x80
ffffffffc020238c:	96d6                	add	a3,a3,s5
ffffffffc020238e:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc0202392:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc0202396:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc0202398:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020239a:	12f67263          	bleu	a5,a2,ffffffffc02024be <exit_range+0x206>
ffffffffc020239e:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc02023a2:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc02023a4:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc02023a8:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc02023aa:	00080837          	lui	a6,0x80
ffffffffc02023ae:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc02023b0:	00200c37          	lui	s8,0x200
ffffffffc02023b4:	a801                	j	ffffffffc02023c4 <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc02023b6:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc02023b8:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02023ba:	c0d9                	beqz	s1,ffffffffc0202440 <exit_range+0x188>
ffffffffc02023bc:	0934f263          	bleu	s3,s1,ffffffffc0202440 <exit_range+0x188>
ffffffffc02023c0:	0d64fc63          	bleu	s6,s1,ffffffffc0202498 <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02023c4:	0154d413          	srli	s0,s1,0x15
ffffffffc02023c8:	1ff47413          	andi	s0,s0,511
ffffffffc02023cc:	040e                	slli	s0,s0,0x3
ffffffffc02023ce:	9452                	add	s0,s0,s4
ffffffffc02023d0:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc02023d2:	0017f693          	andi	a3,a5,1
ffffffffc02023d6:	d2e5                	beqz	a3,ffffffffc02023b6 <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc02023d8:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02023dc:	00279513          	slli	a0,a5,0x2
ffffffffc02023e0:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023e2:	0eb57a63          	bleu	a1,a0,ffffffffc02024d6 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc02023e6:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc02023e8:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc02023ec:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc02023f0:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02023f2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02023f4:	0cb7f563          	bleu	a1,a5,ffffffffc02024be <exit_range+0x206>
ffffffffc02023f8:	631c                	ld	a5,0(a4)
ffffffffc02023fa:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02023fc:	015685b3          	add	a1,a3,s5
                        if (pt[i]&PTE_V){
ffffffffc0202400:	629c                	ld	a5,0(a3)
ffffffffc0202402:	8b85                	andi	a5,a5,1
ffffffffc0202404:	fbd5                	bnez	a5,ffffffffc02023b8 <exit_range+0x100>
ffffffffc0202406:	06a1                	addi	a3,a3,8
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0202408:	fed59ce3          	bne	a1,a3,ffffffffc0202400 <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc020240c:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc0202410:	4585                	li	a1,1
ffffffffc0202412:	e072                	sd	t3,0(sp)
ffffffffc0202414:	953e                	add	a0,a0,a5
ffffffffc0202416:	ad1ff0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
                d0start += PTSIZE;
ffffffffc020241a:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc020241c:	00043023          	sd	zero,0(s0)
ffffffffc0202420:	000dde97          	auipc	t4,0xdd
ffffffffc0202424:	fa8e8e93          	addi	t4,t4,-88 # ffffffffc02df3c8 <pages>
ffffffffc0202428:	6e02                	ld	t3,0(sp)
ffffffffc020242a:	c0000337          	lui	t1,0xc0000
ffffffffc020242e:	fff808b7          	lui	a7,0xfff80
ffffffffc0202432:	00080837          	lui	a6,0x80
ffffffffc0202436:	000dd717          	auipc	a4,0xdd
ffffffffc020243a:	f8270713          	addi	a4,a4,-126 # ffffffffc02df3b8 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc020243e:	fcbd                	bnez	s1,ffffffffc02023bc <exit_range+0x104>
            if (free_pd0) {
ffffffffc0202440:	f00c84e3          	beqz	s9,ffffffffc0202348 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0202444:	000d3783          	ld	a5,0(s10)
ffffffffc0202448:	e072                	sd	t3,0(sp)
ffffffffc020244a:	08fbf663          	bleu	a5,s7,ffffffffc02024d6 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc020244e:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc0202452:	67a2                	ld	a5,8(sp)
ffffffffc0202454:	4585                	li	a1,1
ffffffffc0202456:	953e                	add	a0,a0,a5
ffffffffc0202458:	a8fff0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc020245c:	00093023          	sd	zero,0(s2)
ffffffffc0202460:	000dd717          	auipc	a4,0xdd
ffffffffc0202464:	f5870713          	addi	a4,a4,-168 # ffffffffc02df3b8 <va_pa_offset>
ffffffffc0202468:	c0000337          	lui	t1,0xc0000
ffffffffc020246c:	6e02                	ld	t3,0(sp)
ffffffffc020246e:	000dde97          	auipc	t4,0xdd
ffffffffc0202472:	f5ae8e93          	addi	t4,t4,-166 # ffffffffc02df3c8 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc0202476:	ec099be3          	bnez	s3,ffffffffc020234c <exit_range+0x94>
}
ffffffffc020247a:	70e6                	ld	ra,120(sp)
ffffffffc020247c:	7446                	ld	s0,112(sp)
ffffffffc020247e:	74a6                	ld	s1,104(sp)
ffffffffc0202480:	7906                	ld	s2,96(sp)
ffffffffc0202482:	69e6                	ld	s3,88(sp)
ffffffffc0202484:	6a46                	ld	s4,80(sp)
ffffffffc0202486:	6aa6                	ld	s5,72(sp)
ffffffffc0202488:	6b06                	ld	s6,64(sp)
ffffffffc020248a:	7be2                	ld	s7,56(sp)
ffffffffc020248c:	7c42                	ld	s8,48(sp)
ffffffffc020248e:	7ca2                	ld	s9,40(sp)
ffffffffc0202490:	7d02                	ld	s10,32(sp)
ffffffffc0202492:	6de2                	ld	s11,24(sp)
ffffffffc0202494:	6109                	addi	sp,sp,128
ffffffffc0202496:	8082                	ret
            if (free_pd0) {
ffffffffc0202498:	ea0c8ae3          	beqz	s9,ffffffffc020234c <exit_range+0x94>
ffffffffc020249c:	b765                	j	ffffffffc0202444 <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020249e:	00006697          	auipc	a3,0x6
ffffffffc02024a2:	4d268693          	addi	a3,a3,1234 # ffffffffc0208970 <default_pmm_manager+0x6e8>
ffffffffc02024a6:	00005617          	auipc	a2,0x5
ffffffffc02024aa:	69a60613          	addi	a2,a2,1690 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02024ae:	15100593          	li	a1,337
ffffffffc02024b2:	00006517          	auipc	a0,0x6
ffffffffc02024b6:	f4650513          	addi	a0,a0,-186 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc02024ba:	fcffd0ef          	jal	ra,ffffffffc0200488 <__panic>
    return KADDR(page2pa(page));
ffffffffc02024be:	00006617          	auipc	a2,0x6
ffffffffc02024c2:	e1a60613          	addi	a2,a2,-486 # ffffffffc02082d8 <default_pmm_manager+0x50>
ffffffffc02024c6:	06900593          	li	a1,105
ffffffffc02024ca:	00006517          	auipc	a0,0x6
ffffffffc02024ce:	e3650513          	addi	a0,a0,-458 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc02024d2:	fb7fd0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02024d6:	00006617          	auipc	a2,0x6
ffffffffc02024da:	e6260613          	addi	a2,a2,-414 # ffffffffc0208338 <default_pmm_manager+0xb0>
ffffffffc02024de:	06200593          	li	a1,98
ffffffffc02024e2:	00006517          	auipc	a0,0x6
ffffffffc02024e6:	e1e50513          	addi	a0,a0,-482 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc02024ea:	f9ffd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02024ee:	00006697          	auipc	a3,0x6
ffffffffc02024f2:	4b268693          	addi	a3,a3,1202 # ffffffffc02089a0 <default_pmm_manager+0x718>
ffffffffc02024f6:	00005617          	auipc	a2,0x5
ffffffffc02024fa:	64a60613          	addi	a2,a2,1610 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02024fe:	15200593          	li	a1,338
ffffffffc0202502:	00006517          	auipc	a0,0x6
ffffffffc0202506:	ef650513          	addi	a0,a0,-266 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc020250a:	f7ffd0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020250e <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc020250e:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202510:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202512:	e426                	sd	s1,8(sp)
ffffffffc0202514:	ec06                	sd	ra,24(sp)
ffffffffc0202516:	e822                	sd	s0,16(sp)
ffffffffc0202518:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020251a:	a53ff0ef          	jal	ra,ffffffffc0201f6c <get_pte>
    if (ptep != NULL) {
ffffffffc020251e:	c511                	beqz	a0,ffffffffc020252a <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202520:	611c                	ld	a5,0(a0)
ffffffffc0202522:	842a                	mv	s0,a0
ffffffffc0202524:	0017f713          	andi	a4,a5,1
ffffffffc0202528:	e711                	bnez	a4,ffffffffc0202534 <page_remove+0x26>
}
ffffffffc020252a:	60e2                	ld	ra,24(sp)
ffffffffc020252c:	6442                	ld	s0,16(sp)
ffffffffc020252e:	64a2                	ld	s1,8(sp)
ffffffffc0202530:	6105                	addi	sp,sp,32
ffffffffc0202532:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202534:	000dd717          	auipc	a4,0xdd
ffffffffc0202538:	e1470713          	addi	a4,a4,-492 # ffffffffc02df348 <npage>
ffffffffc020253c:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc020253e:	078a                	slli	a5,a5,0x2
ffffffffc0202540:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202542:	02e7fe63          	bleu	a4,a5,ffffffffc020257e <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0202546:	000dd717          	auipc	a4,0xdd
ffffffffc020254a:	e8270713          	addi	a4,a4,-382 # ffffffffc02df3c8 <pages>
ffffffffc020254e:	6308                	ld	a0,0(a4)
ffffffffc0202550:	fff80737          	lui	a4,0xfff80
ffffffffc0202554:	97ba                	add	a5,a5,a4
ffffffffc0202556:	079a                	slli	a5,a5,0x6
ffffffffc0202558:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020255a:	411c                	lw	a5,0(a0)
ffffffffc020255c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202560:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202562:	cb11                	beqz	a4,ffffffffc0202576 <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202564:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202568:	12048073          	sfence.vma	s1
}
ffffffffc020256c:	60e2                	ld	ra,24(sp)
ffffffffc020256e:	6442                	ld	s0,16(sp)
ffffffffc0202570:	64a2                	ld	s1,8(sp)
ffffffffc0202572:	6105                	addi	sp,sp,32
ffffffffc0202574:	8082                	ret
            free_page(page);
ffffffffc0202576:	4585                	li	a1,1
ffffffffc0202578:	96fff0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
ffffffffc020257c:	b7e5                	j	ffffffffc0202564 <page_remove+0x56>
ffffffffc020257e:	8c5ff0ef          	jal	ra,ffffffffc0201e42 <pa2page.part.4>

ffffffffc0202582 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202582:	7179                	addi	sp,sp,-48
ffffffffc0202584:	e44e                	sd	s3,8(sp)
ffffffffc0202586:	89b2                	mv	s3,a2
ffffffffc0202588:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020258a:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020258c:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020258e:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202590:	ec26                	sd	s1,24(sp)
ffffffffc0202592:	f406                	sd	ra,40(sp)
ffffffffc0202594:	e84a                	sd	s2,16(sp)
ffffffffc0202596:	e052                	sd	s4,0(sp)
ffffffffc0202598:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020259a:	9d3ff0ef          	jal	ra,ffffffffc0201f6c <get_pte>
    if (ptep == NULL) {
ffffffffc020259e:	cd49                	beqz	a0,ffffffffc0202638 <page_insert+0xb6>
    page->ref += 1;
ffffffffc02025a0:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc02025a2:	611c                	ld	a5,0(a0)
ffffffffc02025a4:	892a                	mv	s2,a0
ffffffffc02025a6:	0016871b          	addiw	a4,a3,1
ffffffffc02025aa:	c018                	sw	a4,0(s0)
ffffffffc02025ac:	0017f713          	andi	a4,a5,1
ffffffffc02025b0:	ef05                	bnez	a4,ffffffffc02025e8 <page_insert+0x66>
ffffffffc02025b2:	000dd797          	auipc	a5,0xdd
ffffffffc02025b6:	e1678793          	addi	a5,a5,-490 # ffffffffc02df3c8 <pages>
ffffffffc02025ba:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc02025bc:	8c19                	sub	s0,s0,a4
ffffffffc02025be:	000806b7          	lui	a3,0x80
ffffffffc02025c2:	8419                	srai	s0,s0,0x6
ffffffffc02025c4:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02025c6:	042a                	slli	s0,s0,0xa
ffffffffc02025c8:	8c45                	or	s0,s0,s1
ffffffffc02025ca:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02025ce:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025d2:	12098073          	sfence.vma	s3
    return 0;
ffffffffc02025d6:	4501                	li	a0,0
}
ffffffffc02025d8:	70a2                	ld	ra,40(sp)
ffffffffc02025da:	7402                	ld	s0,32(sp)
ffffffffc02025dc:	64e2                	ld	s1,24(sp)
ffffffffc02025de:	6942                	ld	s2,16(sp)
ffffffffc02025e0:	69a2                	ld	s3,8(sp)
ffffffffc02025e2:	6a02                	ld	s4,0(sp)
ffffffffc02025e4:	6145                	addi	sp,sp,48
ffffffffc02025e6:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02025e8:	000dd717          	auipc	a4,0xdd
ffffffffc02025ec:	d6070713          	addi	a4,a4,-672 # ffffffffc02df348 <npage>
ffffffffc02025f0:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02025f2:	078a                	slli	a5,a5,0x2
ffffffffc02025f4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02025f6:	04e7f363          	bleu	a4,a5,ffffffffc020263c <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc02025fa:	000dda17          	auipc	s4,0xdd
ffffffffc02025fe:	dcea0a13          	addi	s4,s4,-562 # ffffffffc02df3c8 <pages>
ffffffffc0202602:	000a3703          	ld	a4,0(s4)
ffffffffc0202606:	fff80537          	lui	a0,0xfff80
ffffffffc020260a:	953e                	add	a0,a0,a5
ffffffffc020260c:	051a                	slli	a0,a0,0x6
ffffffffc020260e:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc0202610:	00a40a63          	beq	s0,a0,ffffffffc0202624 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc0202614:	411c                	lw	a5,0(a0)
ffffffffc0202616:	fff7869b          	addiw	a3,a5,-1
ffffffffc020261a:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc020261c:	c691                	beqz	a3,ffffffffc0202628 <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020261e:	12098073          	sfence.vma	s3
ffffffffc0202622:	bf69                	j	ffffffffc02025bc <page_insert+0x3a>
ffffffffc0202624:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202626:	bf59                	j	ffffffffc02025bc <page_insert+0x3a>
            free_page(page);
ffffffffc0202628:	4585                	li	a1,1
ffffffffc020262a:	8bdff0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
ffffffffc020262e:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202632:	12098073          	sfence.vma	s3
ffffffffc0202636:	b759                	j	ffffffffc02025bc <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0202638:	5571                	li	a0,-4
ffffffffc020263a:	bf79                	j	ffffffffc02025d8 <page_insert+0x56>
ffffffffc020263c:	807ff0ef          	jal	ra,ffffffffc0201e42 <pa2page.part.4>

ffffffffc0202640 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202640:	00006797          	auipc	a5,0x6
ffffffffc0202644:	c4878793          	addi	a5,a5,-952 # ffffffffc0208288 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202648:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc020264a:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020264c:	00006517          	auipc	a0,0x6
ffffffffc0202650:	dd450513          	addi	a0,a0,-556 # ffffffffc0208420 <default_pmm_manager+0x198>
void pmm_init(void) {
ffffffffc0202654:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202656:	000dd717          	auipc	a4,0xdd
ffffffffc020265a:	d4f73d23          	sd	a5,-678(a4) # ffffffffc02df3b0 <pmm_manager>
void pmm_init(void) {
ffffffffc020265e:	e0a2                	sd	s0,64(sp)
ffffffffc0202660:	fc26                	sd	s1,56(sp)
ffffffffc0202662:	f84a                	sd	s2,48(sp)
ffffffffc0202664:	f44e                	sd	s3,40(sp)
ffffffffc0202666:	f052                	sd	s4,32(sp)
ffffffffc0202668:	ec56                	sd	s5,24(sp)
ffffffffc020266a:	e85a                	sd	s6,16(sp)
ffffffffc020266c:	e45e                	sd	s7,8(sp)
ffffffffc020266e:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202670:	000dd417          	auipc	s0,0xdd
ffffffffc0202674:	d4040413          	addi	s0,s0,-704 # ffffffffc02df3b0 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202678:	b1bfd0ef          	jal	ra,ffffffffc0200192 <cprintf>
    pmm_manager->init();
ffffffffc020267c:	601c                	ld	a5,0(s0)
ffffffffc020267e:	000dd497          	auipc	s1,0xdd
ffffffffc0202682:	cca48493          	addi	s1,s1,-822 # ffffffffc02df348 <npage>
ffffffffc0202686:	000dd917          	auipc	s2,0xdd
ffffffffc020268a:	d4290913          	addi	s2,s2,-702 # ffffffffc02df3c8 <pages>
ffffffffc020268e:	679c                	ld	a5,8(a5)
ffffffffc0202690:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202692:	57f5                	li	a5,-3
ffffffffc0202694:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0202696:	00006517          	auipc	a0,0x6
ffffffffc020269a:	da250513          	addi	a0,a0,-606 # ffffffffc0208438 <default_pmm_manager+0x1b0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020269e:	000dd717          	auipc	a4,0xdd
ffffffffc02026a2:	d0f73d23          	sd	a5,-742(a4) # ffffffffc02df3b8 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02026a6:	aedfd0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02026aa:	46c5                	li	a3,17
ffffffffc02026ac:	06ee                	slli	a3,a3,0x1b
ffffffffc02026ae:	40100613          	li	a2,1025
ffffffffc02026b2:	16fd                	addi	a3,a3,-1
ffffffffc02026b4:	0656                	slli	a2,a2,0x15
ffffffffc02026b6:	07e005b7          	lui	a1,0x7e00
ffffffffc02026ba:	00006517          	auipc	a0,0x6
ffffffffc02026be:	d9650513          	addi	a0,a0,-618 # ffffffffc0208450 <default_pmm_manager+0x1c8>
ffffffffc02026c2:	ad1fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026c6:	777d                	lui	a4,0xfffff
ffffffffc02026c8:	000de797          	auipc	a5,0xde
ffffffffc02026cc:	f4778793          	addi	a5,a5,-185 # ffffffffc02e060f <end+0xfff>
ffffffffc02026d0:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02026d2:	00088737          	lui	a4,0x88
ffffffffc02026d6:	000dd697          	auipc	a3,0xdd
ffffffffc02026da:	c6e6b923          	sd	a4,-910(a3) # ffffffffc02df348 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026de:	000dd717          	auipc	a4,0xdd
ffffffffc02026e2:	cef73523          	sd	a5,-790(a4) # ffffffffc02df3c8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02026e6:	4701                	li	a4,0
ffffffffc02026e8:	4685                	li	a3,1
ffffffffc02026ea:	fff80837          	lui	a6,0xfff80
ffffffffc02026ee:	a019                	j	ffffffffc02026f4 <pmm_init+0xb4>
ffffffffc02026f0:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc02026f4:	00671613          	slli	a2,a4,0x6
ffffffffc02026f8:	97b2                	add	a5,a5,a2
ffffffffc02026fa:	07a1                	addi	a5,a5,8
ffffffffc02026fc:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202700:	6090                	ld	a2,0(s1)
ffffffffc0202702:	0705                	addi	a4,a4,1
ffffffffc0202704:	010607b3          	add	a5,a2,a6
ffffffffc0202708:	fef764e3          	bltu	a4,a5,ffffffffc02026f0 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020270c:	00093503          	ld	a0,0(s2)
ffffffffc0202710:	fe0007b7          	lui	a5,0xfe000
ffffffffc0202714:	00661693          	slli	a3,a2,0x6
ffffffffc0202718:	97aa                	add	a5,a5,a0
ffffffffc020271a:	96be                	add	a3,a3,a5
ffffffffc020271c:	c02007b7          	lui	a5,0xc0200
ffffffffc0202720:	7af6ed63          	bltu	a3,a5,ffffffffc0202eda <pmm_init+0x89a>
ffffffffc0202724:	000dd997          	auipc	s3,0xdd
ffffffffc0202728:	c9498993          	addi	s3,s3,-876 # ffffffffc02df3b8 <va_pa_offset>
ffffffffc020272c:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0202730:	47c5                	li	a5,17
ffffffffc0202732:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202734:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0202736:	02f6f763          	bleu	a5,a3,ffffffffc0202764 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020273a:	6585                	lui	a1,0x1
ffffffffc020273c:	15fd                	addi	a1,a1,-1
ffffffffc020273e:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc0202740:	00c6d713          	srli	a4,a3,0xc
ffffffffc0202744:	48c77a63          	bleu	a2,a4,ffffffffc0202bd8 <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc0202748:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020274a:	75fd                	lui	a1,0xfffff
ffffffffc020274c:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc020274e:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc0202750:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202752:	40d786b3          	sub	a3,a5,a3
ffffffffc0202756:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0202758:	00c6d593          	srli	a1,a3,0xc
ffffffffc020275c:	953a                	add	a0,a0,a4
ffffffffc020275e:	9602                	jalr	a2
ffffffffc0202760:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202764:	00006517          	auipc	a0,0x6
ffffffffc0202768:	d1450513          	addi	a0,a0,-748 # ffffffffc0208478 <default_pmm_manager+0x1f0>
ffffffffc020276c:	a27fd0ef          	jal	ra,ffffffffc0200192 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202770:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202772:	000dd417          	auipc	s0,0xdd
ffffffffc0202776:	bce40413          	addi	s0,s0,-1074 # ffffffffc02df340 <boot_pgdir>
    pmm_manager->check();
ffffffffc020277a:	7b9c                	ld	a5,48(a5)
ffffffffc020277c:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020277e:	00006517          	auipc	a0,0x6
ffffffffc0202782:	d1250513          	addi	a0,a0,-750 # ffffffffc0208490 <default_pmm_manager+0x208>
ffffffffc0202786:	a0dfd0ef          	jal	ra,ffffffffc0200192 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020278a:	0000b697          	auipc	a3,0xb
ffffffffc020278e:	87668693          	addi	a3,a3,-1930 # ffffffffc020d000 <boot_page_table_sv39>
ffffffffc0202792:	000dd797          	auipc	a5,0xdd
ffffffffc0202796:	bad7b723          	sd	a3,-1106(a5) # ffffffffc02df340 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020279a:	c02007b7          	lui	a5,0xc0200
ffffffffc020279e:	10f6eae3          	bltu	a3,a5,ffffffffc02030b2 <pmm_init+0xa72>
ffffffffc02027a2:	0009b783          	ld	a5,0(s3)
ffffffffc02027a6:	8e9d                	sub	a3,a3,a5
ffffffffc02027a8:	000dd797          	auipc	a5,0xdd
ffffffffc02027ac:	c0d7bc23          	sd	a3,-1000(a5) # ffffffffc02df3c0 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc02027b0:	f7cff0ef          	jal	ra,ffffffffc0201f2c <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02027b4:	6098                	ld	a4,0(s1)
ffffffffc02027b6:	c80007b7          	lui	a5,0xc8000
ffffffffc02027ba:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc02027bc:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02027be:	0ce7eae3          	bltu	a5,a4,ffffffffc0203092 <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02027c2:	6008                	ld	a0,0(s0)
ffffffffc02027c4:	44050463          	beqz	a0,ffffffffc0202c0c <pmm_init+0x5cc>
ffffffffc02027c8:	6785                	lui	a5,0x1
ffffffffc02027ca:	17fd                	addi	a5,a5,-1
ffffffffc02027cc:	8fe9                	and	a5,a5,a0
ffffffffc02027ce:	2781                	sext.w	a5,a5
ffffffffc02027d0:	42079e63          	bnez	a5,ffffffffc0202c0c <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02027d4:	4601                	li	a2,0
ffffffffc02027d6:	4581                	li	a1,0
ffffffffc02027d8:	967ff0ef          	jal	ra,ffffffffc020213e <get_page>
ffffffffc02027dc:	78051b63          	bnez	a0,ffffffffc0202f72 <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02027e0:	4505                	li	a0,1
ffffffffc02027e2:	e7cff0ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc02027e6:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02027e8:	6008                	ld	a0,0(s0)
ffffffffc02027ea:	4681                	li	a3,0
ffffffffc02027ec:	4601                	li	a2,0
ffffffffc02027ee:	85d6                	mv	a1,s5
ffffffffc02027f0:	d93ff0ef          	jal	ra,ffffffffc0202582 <page_insert>
ffffffffc02027f4:	7a051f63          	bnez	a0,ffffffffc0202fb2 <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02027f8:	6008                	ld	a0,0(s0)
ffffffffc02027fa:	4601                	li	a2,0
ffffffffc02027fc:	4581                	li	a1,0
ffffffffc02027fe:	f6eff0ef          	jal	ra,ffffffffc0201f6c <get_pte>
ffffffffc0202802:	78050863          	beqz	a0,ffffffffc0202f92 <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc0202806:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202808:	0017f713          	andi	a4,a5,1
ffffffffc020280c:	3e070463          	beqz	a4,ffffffffc0202bf4 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc0202810:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202812:	078a                	slli	a5,a5,0x2
ffffffffc0202814:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202816:	3ce7f163          	bleu	a4,a5,ffffffffc0202bd8 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020281a:	00093683          	ld	a3,0(s2)
ffffffffc020281e:	fff80637          	lui	a2,0xfff80
ffffffffc0202822:	97b2                	add	a5,a5,a2
ffffffffc0202824:	079a                	slli	a5,a5,0x6
ffffffffc0202826:	97b6                	add	a5,a5,a3
ffffffffc0202828:	72fa9563          	bne	s5,a5,ffffffffc0202f52 <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc020282c:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8ad8>
ffffffffc0202830:	4785                	li	a5,1
ffffffffc0202832:	70fb9063          	bne	s7,a5,ffffffffc0202f32 <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202836:	6008                	ld	a0,0(s0)
ffffffffc0202838:	76fd                	lui	a3,0xfffff
ffffffffc020283a:	611c                	ld	a5,0(a0)
ffffffffc020283c:	078a                	slli	a5,a5,0x2
ffffffffc020283e:	8ff5                	and	a5,a5,a3
ffffffffc0202840:	00c7d613          	srli	a2,a5,0xc
ffffffffc0202844:	66e67e63          	bleu	a4,a2,ffffffffc0202ec0 <pmm_init+0x880>
ffffffffc0202848:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020284c:	97e2                	add	a5,a5,s8
ffffffffc020284e:	0007bb03          	ld	s6,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8ad8>
ffffffffc0202852:	0b0a                	slli	s6,s6,0x2
ffffffffc0202854:	00db7b33          	and	s6,s6,a3
ffffffffc0202858:	00cb5793          	srli	a5,s6,0xc
ffffffffc020285c:	56e7f863          	bleu	a4,a5,ffffffffc0202dcc <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202860:	4601                	li	a2,0
ffffffffc0202862:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202864:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202866:	f06ff0ef          	jal	ra,ffffffffc0201f6c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020286a:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020286c:	55651063          	bne	a0,s6,ffffffffc0202dac <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc0202870:	4505                	li	a0,1
ffffffffc0202872:	decff0ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc0202876:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202878:	6008                	ld	a0,0(s0)
ffffffffc020287a:	46d1                	li	a3,20
ffffffffc020287c:	6605                	lui	a2,0x1
ffffffffc020287e:	85da                	mv	a1,s6
ffffffffc0202880:	d03ff0ef          	jal	ra,ffffffffc0202582 <page_insert>
ffffffffc0202884:	50051463          	bnez	a0,ffffffffc0202d8c <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202888:	6008                	ld	a0,0(s0)
ffffffffc020288a:	4601                	li	a2,0
ffffffffc020288c:	6585                	lui	a1,0x1
ffffffffc020288e:	edeff0ef          	jal	ra,ffffffffc0201f6c <get_pte>
ffffffffc0202892:	4c050d63          	beqz	a0,ffffffffc0202d6c <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc0202896:	611c                	ld	a5,0(a0)
ffffffffc0202898:	0107f713          	andi	a4,a5,16
ffffffffc020289c:	4a070863          	beqz	a4,ffffffffc0202d4c <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc02028a0:	8b91                	andi	a5,a5,4
ffffffffc02028a2:	48078563          	beqz	a5,ffffffffc0202d2c <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02028a6:	6008                	ld	a0,0(s0)
ffffffffc02028a8:	611c                	ld	a5,0(a0)
ffffffffc02028aa:	8bc1                	andi	a5,a5,16
ffffffffc02028ac:	46078063          	beqz	a5,ffffffffc0202d0c <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc02028b0:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_matrix_out_size+0x1f43c0>
ffffffffc02028b4:	43779c63          	bne	a5,s7,ffffffffc0202cec <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02028b8:	4681                	li	a3,0
ffffffffc02028ba:	6605                	lui	a2,0x1
ffffffffc02028bc:	85d6                	mv	a1,s5
ffffffffc02028be:	cc5ff0ef          	jal	ra,ffffffffc0202582 <page_insert>
ffffffffc02028c2:	40051563          	bnez	a0,ffffffffc0202ccc <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc02028c6:	000aa703          	lw	a4,0(s5)
ffffffffc02028ca:	4789                	li	a5,2
ffffffffc02028cc:	3ef71063          	bne	a4,a5,ffffffffc0202cac <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc02028d0:	000b2783          	lw	a5,0(s6)
ffffffffc02028d4:	3a079c63          	bnez	a5,ffffffffc0202c8c <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02028d8:	6008                	ld	a0,0(s0)
ffffffffc02028da:	4601                	li	a2,0
ffffffffc02028dc:	6585                	lui	a1,0x1
ffffffffc02028de:	e8eff0ef          	jal	ra,ffffffffc0201f6c <get_pte>
ffffffffc02028e2:	38050563          	beqz	a0,ffffffffc0202c6c <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc02028e6:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02028e8:	00177793          	andi	a5,a4,1
ffffffffc02028ec:	30078463          	beqz	a5,ffffffffc0202bf4 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc02028f0:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02028f2:	00271793          	slli	a5,a4,0x2
ffffffffc02028f6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028f8:	2ed7f063          	bleu	a3,a5,ffffffffc0202bd8 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02028fc:	00093683          	ld	a3,0(s2)
ffffffffc0202900:	fff80637          	lui	a2,0xfff80
ffffffffc0202904:	97b2                	add	a5,a5,a2
ffffffffc0202906:	079a                	slli	a5,a5,0x6
ffffffffc0202908:	97b6                	add	a5,a5,a3
ffffffffc020290a:	32fa9163          	bne	s5,a5,ffffffffc0202c2c <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc020290e:	8b41                	andi	a4,a4,16
ffffffffc0202910:	70071163          	bnez	a4,ffffffffc0203012 <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc0202914:	6008                	ld	a0,0(s0)
ffffffffc0202916:	4581                	li	a1,0
ffffffffc0202918:	bf7ff0ef          	jal	ra,ffffffffc020250e <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc020291c:	000aa703          	lw	a4,0(s5)
ffffffffc0202920:	4785                	li	a5,1
ffffffffc0202922:	6cf71863          	bne	a4,a5,ffffffffc0202ff2 <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc0202926:	000b2783          	lw	a5,0(s6)
ffffffffc020292a:	6a079463          	bnez	a5,ffffffffc0202fd2 <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc020292e:	6008                	ld	a0,0(s0)
ffffffffc0202930:	6585                	lui	a1,0x1
ffffffffc0202932:	bddff0ef          	jal	ra,ffffffffc020250e <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202936:	000aa783          	lw	a5,0(s5)
ffffffffc020293a:	50079363          	bnez	a5,ffffffffc0202e40 <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc020293e:	000b2783          	lw	a5,0(s6)
ffffffffc0202942:	4c079f63          	bnez	a5,ffffffffc0202e20 <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202946:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020294a:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020294c:	000ab783          	ld	a5,0(s5)
ffffffffc0202950:	078a                	slli	a5,a5,0x2
ffffffffc0202952:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202954:	28c7f263          	bleu	a2,a5,ffffffffc0202bd8 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202958:	fff80737          	lui	a4,0xfff80
ffffffffc020295c:	00093503          	ld	a0,0(s2)
ffffffffc0202960:	97ba                	add	a5,a5,a4
ffffffffc0202962:	079a                	slli	a5,a5,0x6
ffffffffc0202964:	00f50733          	add	a4,a0,a5
ffffffffc0202968:	4314                	lw	a3,0(a4)
ffffffffc020296a:	4705                	li	a4,1
ffffffffc020296c:	48e69a63          	bne	a3,a4,ffffffffc0202e00 <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc0202970:	8799                	srai	a5,a5,0x6
ffffffffc0202972:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc0202976:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc0202978:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc020297a:	8331                	srli	a4,a4,0xc
ffffffffc020297c:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc020297e:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202980:	46c77363          	bleu	a2,a4,ffffffffc0202de6 <pmm_init+0x7a6>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202984:	0009b683          	ld	a3,0(s3)
ffffffffc0202988:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc020298a:	639c                	ld	a5,0(a5)
ffffffffc020298c:	078a                	slli	a5,a5,0x2
ffffffffc020298e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202990:	24c7f463          	bleu	a2,a5,ffffffffc0202bd8 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202994:	416787b3          	sub	a5,a5,s6
ffffffffc0202998:	079a                	slli	a5,a5,0x6
ffffffffc020299a:	953e                	add	a0,a0,a5
ffffffffc020299c:	4585                	li	a1,1
ffffffffc020299e:	d48ff0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02029a2:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc02029a6:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02029a8:	078a                	slli	a5,a5,0x2
ffffffffc02029aa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02029ac:	22e7f663          	bleu	a4,a5,ffffffffc0202bd8 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02029b0:	00093503          	ld	a0,0(s2)
ffffffffc02029b4:	416787b3          	sub	a5,a5,s6
ffffffffc02029b8:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02029ba:	953e                	add	a0,a0,a5
ffffffffc02029bc:	4585                	li	a1,1
ffffffffc02029be:	d28ff0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02029c2:	601c                	ld	a5,0(s0)
ffffffffc02029c4:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02029c8:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02029cc:	d60ff0ef          	jal	ra,ffffffffc0201f2c <nr_free_pages>
ffffffffc02029d0:	68aa1163          	bne	s4,a0,ffffffffc0203052 <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02029d4:	00006517          	auipc	a0,0x6
ffffffffc02029d8:	dcc50513          	addi	a0,a0,-564 # ffffffffc02087a0 <default_pmm_manager+0x518>
ffffffffc02029dc:	fb6fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc02029e0:	d4cff0ef          	jal	ra,ffffffffc0201f2c <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029e4:	6098                	ld	a4,0(s1)
ffffffffc02029e6:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc02029ea:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029ec:	00c71693          	slli	a3,a4,0xc
ffffffffc02029f0:	18d7f563          	bleu	a3,a5,ffffffffc0202b7a <pmm_init+0x53a>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029f4:	83b1                	srli	a5,a5,0xc
ffffffffc02029f6:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029f8:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029fc:	1ae7f163          	bleu	a4,a5,ffffffffc0202b9e <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202a00:	7bfd                	lui	s7,0xfffff
ffffffffc0202a02:	6b05                	lui	s6,0x1
ffffffffc0202a04:	a029                	j	ffffffffc0202a0e <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202a06:	00cad713          	srli	a4,s5,0xc
ffffffffc0202a0a:	18f77a63          	bleu	a5,a4,ffffffffc0202b9e <pmm_init+0x55e>
ffffffffc0202a0e:	0009b583          	ld	a1,0(s3)
ffffffffc0202a12:	4601                	li	a2,0
ffffffffc0202a14:	95d6                	add	a1,a1,s5
ffffffffc0202a16:	d56ff0ef          	jal	ra,ffffffffc0201f6c <get_pte>
ffffffffc0202a1a:	16050263          	beqz	a0,ffffffffc0202b7e <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202a1e:	611c                	ld	a5,0(a0)
ffffffffc0202a20:	078a                	slli	a5,a5,0x2
ffffffffc0202a22:	0177f7b3          	and	a5,a5,s7
ffffffffc0202a26:	19579963          	bne	a5,s5,ffffffffc0202bb8 <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202a2a:	609c                	ld	a5,0(s1)
ffffffffc0202a2c:	9ada                	add	s5,s5,s6
ffffffffc0202a2e:	6008                	ld	a0,0(s0)
ffffffffc0202a30:	00c79713          	slli	a4,a5,0xc
ffffffffc0202a34:	fceae9e3          	bltu	s5,a4,ffffffffc0202a06 <pmm_init+0x3c6>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0202a38:	611c                	ld	a5,0(a0)
ffffffffc0202a3a:	62079c63          	bnez	a5,ffffffffc0203072 <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc0202a3e:	4505                	li	a0,1
ffffffffc0202a40:	c1eff0ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc0202a44:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202a46:	6008                	ld	a0,0(s0)
ffffffffc0202a48:	4699                	li	a3,6
ffffffffc0202a4a:	10000613          	li	a2,256
ffffffffc0202a4e:	85d6                	mv	a1,s5
ffffffffc0202a50:	b33ff0ef          	jal	ra,ffffffffc0202582 <page_insert>
ffffffffc0202a54:	1e051c63          	bnez	a0,ffffffffc0202c4c <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc0202a58:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0202a5c:	4785                	li	a5,1
ffffffffc0202a5e:	44f71163          	bne	a4,a5,ffffffffc0202ea0 <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202a62:	6008                	ld	a0,0(s0)
ffffffffc0202a64:	6b05                	lui	s6,0x1
ffffffffc0202a66:	4699                	li	a3,6
ffffffffc0202a68:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x89d8>
ffffffffc0202a6c:	85d6                	mv	a1,s5
ffffffffc0202a6e:	b15ff0ef          	jal	ra,ffffffffc0202582 <page_insert>
ffffffffc0202a72:	40051763          	bnez	a0,ffffffffc0202e80 <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc0202a76:	000aa703          	lw	a4,0(s5)
ffffffffc0202a7a:	4789                	li	a5,2
ffffffffc0202a7c:	3ef71263          	bne	a4,a5,ffffffffc0202e60 <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202a80:	00006597          	auipc	a1,0x6
ffffffffc0202a84:	e5858593          	addi	a1,a1,-424 # ffffffffc02088d8 <default_pmm_manager+0x650>
ffffffffc0202a88:	10000513          	li	a0,256
ffffffffc0202a8c:	23f040ef          	jal	ra,ffffffffc02074ca <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202a90:	100b0593          	addi	a1,s6,256
ffffffffc0202a94:	10000513          	li	a0,256
ffffffffc0202a98:	245040ef          	jal	ra,ffffffffc02074dc <strcmp>
ffffffffc0202a9c:	44051b63          	bnez	a0,ffffffffc0202ef2 <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc0202aa0:	00093683          	ld	a3,0(s2)
ffffffffc0202aa4:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202aa8:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0202aaa:	40da86b3          	sub	a3,s5,a3
ffffffffc0202aae:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202ab0:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202ab2:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202ab4:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0202ab8:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202abc:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202abe:	10f77f63          	bleu	a5,a4,ffffffffc0202bdc <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202ac2:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202ac6:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202aca:	96be                	add	a3,a3,a5
ffffffffc0202acc:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fd1faf0>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202ad0:	1b7040ef          	jal	ra,ffffffffc0207486 <strlen>
ffffffffc0202ad4:	54051f63          	bnez	a0,ffffffffc0203032 <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202ad8:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202adc:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ade:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd1f9f0>
ffffffffc0202ae2:	068a                	slli	a3,a3,0x2
ffffffffc0202ae4:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ae6:	0ef6f963          	bleu	a5,a3,ffffffffc0202bd8 <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc0202aea:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202aee:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202af0:	0efb7663          	bleu	a5,s6,ffffffffc0202bdc <pmm_init+0x59c>
ffffffffc0202af4:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202af8:	4585                	li	a1,1
ffffffffc0202afa:	8556                	mv	a0,s5
ffffffffc0202afc:	99b6                	add	s3,s3,a3
ffffffffc0202afe:	be8ff0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b02:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202b06:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b08:	078a                	slli	a5,a5,0x2
ffffffffc0202b0a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b0c:	0ce7f663          	bleu	a4,a5,ffffffffc0202bd8 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b10:	00093503          	ld	a0,0(s2)
ffffffffc0202b14:	fff809b7          	lui	s3,0xfff80
ffffffffc0202b18:	97ce                	add	a5,a5,s3
ffffffffc0202b1a:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202b1c:	953e                	add	a0,a0,a5
ffffffffc0202b1e:	4585                	li	a1,1
ffffffffc0202b20:	bc6ff0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b24:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0202b28:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b2a:	078a                	slli	a5,a5,0x2
ffffffffc0202b2c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b2e:	0ae7f563          	bleu	a4,a5,ffffffffc0202bd8 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b32:	00093503          	ld	a0,0(s2)
ffffffffc0202b36:	97ce                	add	a5,a5,s3
ffffffffc0202b38:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202b3a:	953e                	add	a0,a0,a5
ffffffffc0202b3c:	4585                	li	a1,1
ffffffffc0202b3e:	ba8ff0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202b42:	601c                	ld	a5,0(s0)
ffffffffc0202b44:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0202b48:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202b4c:	be0ff0ef          	jal	ra,ffffffffc0201f2c <nr_free_pages>
ffffffffc0202b50:	3caa1163          	bne	s4,a0,ffffffffc0202f12 <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202b54:	00006517          	auipc	a0,0x6
ffffffffc0202b58:	dfc50513          	addi	a0,a0,-516 # ffffffffc0208950 <default_pmm_manager+0x6c8>
ffffffffc0202b5c:	e36fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
}
ffffffffc0202b60:	6406                	ld	s0,64(sp)
ffffffffc0202b62:	60a6                	ld	ra,72(sp)
ffffffffc0202b64:	74e2                	ld	s1,56(sp)
ffffffffc0202b66:	7942                	ld	s2,48(sp)
ffffffffc0202b68:	79a2                	ld	s3,40(sp)
ffffffffc0202b6a:	7a02                	ld	s4,32(sp)
ffffffffc0202b6c:	6ae2                	ld	s5,24(sp)
ffffffffc0202b6e:	6b42                	ld	s6,16(sp)
ffffffffc0202b70:	6ba2                	ld	s7,8(sp)
ffffffffc0202b72:	6c02                	ld	s8,0(sp)
ffffffffc0202b74:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0202b76:	8c8ff06f          	j	ffffffffc0201c3e <kmalloc_init>
ffffffffc0202b7a:	6008                	ld	a0,0(s0)
ffffffffc0202b7c:	bd75                	j	ffffffffc0202a38 <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202b7e:	00006697          	auipc	a3,0x6
ffffffffc0202b82:	c4268693          	addi	a3,a3,-958 # ffffffffc02087c0 <default_pmm_manager+0x538>
ffffffffc0202b86:	00005617          	auipc	a2,0x5
ffffffffc0202b8a:	fba60613          	addi	a2,a2,-70 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202b8e:	25700593          	li	a1,599
ffffffffc0202b92:	00006517          	auipc	a0,0x6
ffffffffc0202b96:	86650513          	addi	a0,a0,-1946 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202b9a:	8effd0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0202b9e:	86d6                	mv	a3,s5
ffffffffc0202ba0:	00005617          	auipc	a2,0x5
ffffffffc0202ba4:	73860613          	addi	a2,a2,1848 # ffffffffc02082d8 <default_pmm_manager+0x50>
ffffffffc0202ba8:	25700593          	li	a1,599
ffffffffc0202bac:	00006517          	auipc	a0,0x6
ffffffffc0202bb0:	84c50513          	addi	a0,a0,-1972 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202bb4:	8d5fd0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202bb8:	00006697          	auipc	a3,0x6
ffffffffc0202bbc:	c4868693          	addi	a3,a3,-952 # ffffffffc0208800 <default_pmm_manager+0x578>
ffffffffc0202bc0:	00005617          	auipc	a2,0x5
ffffffffc0202bc4:	f8060613          	addi	a2,a2,-128 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202bc8:	25800593          	li	a1,600
ffffffffc0202bcc:	00006517          	auipc	a0,0x6
ffffffffc0202bd0:	82c50513          	addi	a0,a0,-2004 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202bd4:	8b5fd0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0202bd8:	a6aff0ef          	jal	ra,ffffffffc0201e42 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0202bdc:	00005617          	auipc	a2,0x5
ffffffffc0202be0:	6fc60613          	addi	a2,a2,1788 # ffffffffc02082d8 <default_pmm_manager+0x50>
ffffffffc0202be4:	06900593          	li	a1,105
ffffffffc0202be8:	00005517          	auipc	a0,0x5
ffffffffc0202bec:	71850513          	addi	a0,a0,1816 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc0202bf0:	899fd0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202bf4:	00006617          	auipc	a2,0x6
ffffffffc0202bf8:	99c60613          	addi	a2,a2,-1636 # ffffffffc0208590 <default_pmm_manager+0x308>
ffffffffc0202bfc:	07400593          	li	a1,116
ffffffffc0202c00:	00005517          	auipc	a0,0x5
ffffffffc0202c04:	70050513          	addi	a0,a0,1792 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc0202c08:	881fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202c0c:	00006697          	auipc	a3,0x6
ffffffffc0202c10:	8c468693          	addi	a3,a3,-1852 # ffffffffc02084d0 <default_pmm_manager+0x248>
ffffffffc0202c14:	00005617          	auipc	a2,0x5
ffffffffc0202c18:	f2c60613          	addi	a2,a2,-212 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202c1c:	21b00593          	li	a1,539
ffffffffc0202c20:	00005517          	auipc	a0,0x5
ffffffffc0202c24:	7d850513          	addi	a0,a0,2008 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202c28:	861fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202c2c:	00006697          	auipc	a3,0x6
ffffffffc0202c30:	98c68693          	addi	a3,a3,-1652 # ffffffffc02085b8 <default_pmm_manager+0x330>
ffffffffc0202c34:	00005617          	auipc	a2,0x5
ffffffffc0202c38:	f0c60613          	addi	a2,a2,-244 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202c3c:	23700593          	li	a1,567
ffffffffc0202c40:	00005517          	auipc	a0,0x5
ffffffffc0202c44:	7b850513          	addi	a0,a0,1976 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202c48:	841fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202c4c:	00006697          	auipc	a3,0x6
ffffffffc0202c50:	be468693          	addi	a3,a3,-1052 # ffffffffc0208830 <default_pmm_manager+0x5a8>
ffffffffc0202c54:	00005617          	auipc	a2,0x5
ffffffffc0202c58:	eec60613          	addi	a2,a2,-276 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202c5c:	26000593          	li	a1,608
ffffffffc0202c60:	00005517          	auipc	a0,0x5
ffffffffc0202c64:	79850513          	addi	a0,a0,1944 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202c68:	821fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202c6c:	00006697          	auipc	a3,0x6
ffffffffc0202c70:	9dc68693          	addi	a3,a3,-1572 # ffffffffc0208648 <default_pmm_manager+0x3c0>
ffffffffc0202c74:	00005617          	auipc	a2,0x5
ffffffffc0202c78:	ecc60613          	addi	a2,a2,-308 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202c7c:	23600593          	li	a1,566
ffffffffc0202c80:	00005517          	auipc	a0,0x5
ffffffffc0202c84:	77850513          	addi	a0,a0,1912 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202c88:	801fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202c8c:	00006697          	auipc	a3,0x6
ffffffffc0202c90:	a8468693          	addi	a3,a3,-1404 # ffffffffc0208710 <default_pmm_manager+0x488>
ffffffffc0202c94:	00005617          	auipc	a2,0x5
ffffffffc0202c98:	eac60613          	addi	a2,a2,-340 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202c9c:	23500593          	li	a1,565
ffffffffc0202ca0:	00005517          	auipc	a0,0x5
ffffffffc0202ca4:	75850513          	addi	a0,a0,1880 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202ca8:	fe0fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202cac:	00006697          	auipc	a3,0x6
ffffffffc0202cb0:	a4c68693          	addi	a3,a3,-1460 # ffffffffc02086f8 <default_pmm_manager+0x470>
ffffffffc0202cb4:	00005617          	auipc	a2,0x5
ffffffffc0202cb8:	e8c60613          	addi	a2,a2,-372 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202cbc:	23400593          	li	a1,564
ffffffffc0202cc0:	00005517          	auipc	a0,0x5
ffffffffc0202cc4:	73850513          	addi	a0,a0,1848 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202cc8:	fc0fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202ccc:	00006697          	auipc	a3,0x6
ffffffffc0202cd0:	9fc68693          	addi	a3,a3,-1540 # ffffffffc02086c8 <default_pmm_manager+0x440>
ffffffffc0202cd4:	00005617          	auipc	a2,0x5
ffffffffc0202cd8:	e6c60613          	addi	a2,a2,-404 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202cdc:	23300593          	li	a1,563
ffffffffc0202ce0:	00005517          	auipc	a0,0x5
ffffffffc0202ce4:	71850513          	addi	a0,a0,1816 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202ce8:	fa0fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202cec:	00006697          	auipc	a3,0x6
ffffffffc0202cf0:	9c468693          	addi	a3,a3,-1596 # ffffffffc02086b0 <default_pmm_manager+0x428>
ffffffffc0202cf4:	00005617          	auipc	a2,0x5
ffffffffc0202cf8:	e4c60613          	addi	a2,a2,-436 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202cfc:	23100593          	li	a1,561
ffffffffc0202d00:	00005517          	auipc	a0,0x5
ffffffffc0202d04:	6f850513          	addi	a0,a0,1784 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202d08:	f80fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202d0c:	00006697          	auipc	a3,0x6
ffffffffc0202d10:	98c68693          	addi	a3,a3,-1652 # ffffffffc0208698 <default_pmm_manager+0x410>
ffffffffc0202d14:	00005617          	auipc	a2,0x5
ffffffffc0202d18:	e2c60613          	addi	a2,a2,-468 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202d1c:	23000593          	li	a1,560
ffffffffc0202d20:	00005517          	auipc	a0,0x5
ffffffffc0202d24:	6d850513          	addi	a0,a0,1752 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202d28:	f60fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202d2c:	00006697          	auipc	a3,0x6
ffffffffc0202d30:	95c68693          	addi	a3,a3,-1700 # ffffffffc0208688 <default_pmm_manager+0x400>
ffffffffc0202d34:	00005617          	auipc	a2,0x5
ffffffffc0202d38:	e0c60613          	addi	a2,a2,-500 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202d3c:	22f00593          	li	a1,559
ffffffffc0202d40:	00005517          	auipc	a0,0x5
ffffffffc0202d44:	6b850513          	addi	a0,a0,1720 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202d48:	f40fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202d4c:	00006697          	auipc	a3,0x6
ffffffffc0202d50:	92c68693          	addi	a3,a3,-1748 # ffffffffc0208678 <default_pmm_manager+0x3f0>
ffffffffc0202d54:	00005617          	auipc	a2,0x5
ffffffffc0202d58:	dec60613          	addi	a2,a2,-532 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202d5c:	22e00593          	li	a1,558
ffffffffc0202d60:	00005517          	auipc	a0,0x5
ffffffffc0202d64:	69850513          	addi	a0,a0,1688 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202d68:	f20fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202d6c:	00006697          	auipc	a3,0x6
ffffffffc0202d70:	8dc68693          	addi	a3,a3,-1828 # ffffffffc0208648 <default_pmm_manager+0x3c0>
ffffffffc0202d74:	00005617          	auipc	a2,0x5
ffffffffc0202d78:	dcc60613          	addi	a2,a2,-564 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202d7c:	22d00593          	li	a1,557
ffffffffc0202d80:	00005517          	auipc	a0,0x5
ffffffffc0202d84:	67850513          	addi	a0,a0,1656 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202d88:	f00fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202d8c:	00006697          	auipc	a3,0x6
ffffffffc0202d90:	88468693          	addi	a3,a3,-1916 # ffffffffc0208610 <default_pmm_manager+0x388>
ffffffffc0202d94:	00005617          	auipc	a2,0x5
ffffffffc0202d98:	dac60613          	addi	a2,a2,-596 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202d9c:	22c00593          	li	a1,556
ffffffffc0202da0:	00005517          	auipc	a0,0x5
ffffffffc0202da4:	65850513          	addi	a0,a0,1624 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202da8:	ee0fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202dac:	00006697          	auipc	a3,0x6
ffffffffc0202db0:	83c68693          	addi	a3,a3,-1988 # ffffffffc02085e8 <default_pmm_manager+0x360>
ffffffffc0202db4:	00005617          	auipc	a2,0x5
ffffffffc0202db8:	d8c60613          	addi	a2,a2,-628 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202dbc:	22900593          	li	a1,553
ffffffffc0202dc0:	00005517          	auipc	a0,0x5
ffffffffc0202dc4:	63850513          	addi	a0,a0,1592 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202dc8:	ec0fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202dcc:	86da                	mv	a3,s6
ffffffffc0202dce:	00005617          	auipc	a2,0x5
ffffffffc0202dd2:	50a60613          	addi	a2,a2,1290 # ffffffffc02082d8 <default_pmm_manager+0x50>
ffffffffc0202dd6:	22800593          	li	a1,552
ffffffffc0202dda:	00005517          	auipc	a0,0x5
ffffffffc0202dde:	61e50513          	addi	a0,a0,1566 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202de2:	ea6fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202de6:	86be                	mv	a3,a5
ffffffffc0202de8:	00005617          	auipc	a2,0x5
ffffffffc0202dec:	4f060613          	addi	a2,a2,1264 # ffffffffc02082d8 <default_pmm_manager+0x50>
ffffffffc0202df0:	06900593          	li	a1,105
ffffffffc0202df4:	00005517          	auipc	a0,0x5
ffffffffc0202df8:	50c50513          	addi	a0,a0,1292 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc0202dfc:	e8cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202e00:	00006697          	auipc	a3,0x6
ffffffffc0202e04:	95868693          	addi	a3,a3,-1704 # ffffffffc0208758 <default_pmm_manager+0x4d0>
ffffffffc0202e08:	00005617          	auipc	a2,0x5
ffffffffc0202e0c:	d3860613          	addi	a2,a2,-712 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202e10:	24200593          	li	a1,578
ffffffffc0202e14:	00005517          	auipc	a0,0x5
ffffffffc0202e18:	5e450513          	addi	a0,a0,1508 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202e1c:	e6cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202e20:	00006697          	auipc	a3,0x6
ffffffffc0202e24:	8f068693          	addi	a3,a3,-1808 # ffffffffc0208710 <default_pmm_manager+0x488>
ffffffffc0202e28:	00005617          	auipc	a2,0x5
ffffffffc0202e2c:	d1860613          	addi	a2,a2,-744 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202e30:	24000593          	li	a1,576
ffffffffc0202e34:	00005517          	auipc	a0,0x5
ffffffffc0202e38:	5c450513          	addi	a0,a0,1476 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202e3c:	e4cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202e40:	00006697          	auipc	a3,0x6
ffffffffc0202e44:	90068693          	addi	a3,a3,-1792 # ffffffffc0208740 <default_pmm_manager+0x4b8>
ffffffffc0202e48:	00005617          	auipc	a2,0x5
ffffffffc0202e4c:	cf860613          	addi	a2,a2,-776 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202e50:	23f00593          	li	a1,575
ffffffffc0202e54:	00005517          	auipc	a0,0x5
ffffffffc0202e58:	5a450513          	addi	a0,a0,1444 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202e5c:	e2cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202e60:	00006697          	auipc	a3,0x6
ffffffffc0202e64:	a6068693          	addi	a3,a3,-1440 # ffffffffc02088c0 <default_pmm_manager+0x638>
ffffffffc0202e68:	00005617          	auipc	a2,0x5
ffffffffc0202e6c:	cd860613          	addi	a2,a2,-808 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202e70:	26300593          	li	a1,611
ffffffffc0202e74:	00005517          	auipc	a0,0x5
ffffffffc0202e78:	58450513          	addi	a0,a0,1412 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202e7c:	e0cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202e80:	00006697          	auipc	a3,0x6
ffffffffc0202e84:	a0068693          	addi	a3,a3,-1536 # ffffffffc0208880 <default_pmm_manager+0x5f8>
ffffffffc0202e88:	00005617          	auipc	a2,0x5
ffffffffc0202e8c:	cb860613          	addi	a2,a2,-840 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202e90:	26200593          	li	a1,610
ffffffffc0202e94:	00005517          	auipc	a0,0x5
ffffffffc0202e98:	56450513          	addi	a0,a0,1380 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202e9c:	decfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202ea0:	00006697          	auipc	a3,0x6
ffffffffc0202ea4:	9c868693          	addi	a3,a3,-1592 # ffffffffc0208868 <default_pmm_manager+0x5e0>
ffffffffc0202ea8:	00005617          	auipc	a2,0x5
ffffffffc0202eac:	c9860613          	addi	a2,a2,-872 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202eb0:	26100593          	li	a1,609
ffffffffc0202eb4:	00005517          	auipc	a0,0x5
ffffffffc0202eb8:	54450513          	addi	a0,a0,1348 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202ebc:	dccfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202ec0:	86be                	mv	a3,a5
ffffffffc0202ec2:	00005617          	auipc	a2,0x5
ffffffffc0202ec6:	41660613          	addi	a2,a2,1046 # ffffffffc02082d8 <default_pmm_manager+0x50>
ffffffffc0202eca:	22700593          	li	a1,551
ffffffffc0202ece:	00005517          	auipc	a0,0x5
ffffffffc0202ed2:	52a50513          	addi	a0,a0,1322 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202ed6:	db2fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202eda:	00005617          	auipc	a2,0x5
ffffffffc0202ede:	43660613          	addi	a2,a2,1078 # ffffffffc0208310 <default_pmm_manager+0x88>
ffffffffc0202ee2:	07f00593          	li	a1,127
ffffffffc0202ee6:	00005517          	auipc	a0,0x5
ffffffffc0202eea:	51250513          	addi	a0,a0,1298 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202eee:	d9afd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202ef2:	00006697          	auipc	a3,0x6
ffffffffc0202ef6:	9fe68693          	addi	a3,a3,-1538 # ffffffffc02088f0 <default_pmm_manager+0x668>
ffffffffc0202efa:	00005617          	auipc	a2,0x5
ffffffffc0202efe:	c4660613          	addi	a2,a2,-954 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202f02:	26700593          	li	a1,615
ffffffffc0202f06:	00005517          	auipc	a0,0x5
ffffffffc0202f0a:	4f250513          	addi	a0,a0,1266 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202f0e:	d7afd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202f12:	00006697          	auipc	a3,0x6
ffffffffc0202f16:	86e68693          	addi	a3,a3,-1938 # ffffffffc0208780 <default_pmm_manager+0x4f8>
ffffffffc0202f1a:	00005617          	auipc	a2,0x5
ffffffffc0202f1e:	c2660613          	addi	a2,a2,-986 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202f22:	27300593          	li	a1,627
ffffffffc0202f26:	00005517          	auipc	a0,0x5
ffffffffc0202f2a:	4d250513          	addi	a0,a0,1234 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202f2e:	d5afd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202f32:	00005697          	auipc	a3,0x5
ffffffffc0202f36:	69e68693          	addi	a3,a3,1694 # ffffffffc02085d0 <default_pmm_manager+0x348>
ffffffffc0202f3a:	00005617          	auipc	a2,0x5
ffffffffc0202f3e:	c0660613          	addi	a2,a2,-1018 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202f42:	22500593          	li	a1,549
ffffffffc0202f46:	00005517          	auipc	a0,0x5
ffffffffc0202f4a:	4b250513          	addi	a0,a0,1202 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202f4e:	d3afd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202f52:	00005697          	auipc	a3,0x5
ffffffffc0202f56:	66668693          	addi	a3,a3,1638 # ffffffffc02085b8 <default_pmm_manager+0x330>
ffffffffc0202f5a:	00005617          	auipc	a2,0x5
ffffffffc0202f5e:	be660613          	addi	a2,a2,-1050 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202f62:	22400593          	li	a1,548
ffffffffc0202f66:	00005517          	auipc	a0,0x5
ffffffffc0202f6a:	49250513          	addi	a0,a0,1170 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202f6e:	d1afd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202f72:	00005697          	auipc	a3,0x5
ffffffffc0202f76:	59668693          	addi	a3,a3,1430 # ffffffffc0208508 <default_pmm_manager+0x280>
ffffffffc0202f7a:	00005617          	auipc	a2,0x5
ffffffffc0202f7e:	bc660613          	addi	a2,a2,-1082 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202f82:	21c00593          	li	a1,540
ffffffffc0202f86:	00005517          	auipc	a0,0x5
ffffffffc0202f8a:	47250513          	addi	a0,a0,1138 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202f8e:	cfafd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202f92:	00005697          	auipc	a3,0x5
ffffffffc0202f96:	5ce68693          	addi	a3,a3,1486 # ffffffffc0208560 <default_pmm_manager+0x2d8>
ffffffffc0202f9a:	00005617          	auipc	a2,0x5
ffffffffc0202f9e:	ba660613          	addi	a2,a2,-1114 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202fa2:	22300593          	li	a1,547
ffffffffc0202fa6:	00005517          	auipc	a0,0x5
ffffffffc0202faa:	45250513          	addi	a0,a0,1106 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202fae:	cdafd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202fb2:	00005697          	auipc	a3,0x5
ffffffffc0202fb6:	57e68693          	addi	a3,a3,1406 # ffffffffc0208530 <default_pmm_manager+0x2a8>
ffffffffc0202fba:	00005617          	auipc	a2,0x5
ffffffffc0202fbe:	b8660613          	addi	a2,a2,-1146 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202fc2:	22000593          	li	a1,544
ffffffffc0202fc6:	00005517          	auipc	a0,0x5
ffffffffc0202fca:	43250513          	addi	a0,a0,1074 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202fce:	cbafd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202fd2:	00005697          	auipc	a3,0x5
ffffffffc0202fd6:	73e68693          	addi	a3,a3,1854 # ffffffffc0208710 <default_pmm_manager+0x488>
ffffffffc0202fda:	00005617          	auipc	a2,0x5
ffffffffc0202fde:	b6660613          	addi	a2,a2,-1178 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0202fe2:	23c00593          	li	a1,572
ffffffffc0202fe6:	00005517          	auipc	a0,0x5
ffffffffc0202fea:	41250513          	addi	a0,a0,1042 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0202fee:	c9afd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202ff2:	00005697          	auipc	a3,0x5
ffffffffc0202ff6:	5de68693          	addi	a3,a3,1502 # ffffffffc02085d0 <default_pmm_manager+0x348>
ffffffffc0202ffa:	00005617          	auipc	a2,0x5
ffffffffc0202ffe:	b4660613          	addi	a2,a2,-1210 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203002:	23b00593          	li	a1,571
ffffffffc0203006:	00005517          	auipc	a0,0x5
ffffffffc020300a:	3f250513          	addi	a0,a0,1010 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc020300e:	c7afd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203012:	00005697          	auipc	a3,0x5
ffffffffc0203016:	71668693          	addi	a3,a3,1814 # ffffffffc0208728 <default_pmm_manager+0x4a0>
ffffffffc020301a:	00005617          	auipc	a2,0x5
ffffffffc020301e:	b2660613          	addi	a2,a2,-1242 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203022:	23800593          	li	a1,568
ffffffffc0203026:	00005517          	auipc	a0,0x5
ffffffffc020302a:	3d250513          	addi	a0,a0,978 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc020302e:	c5afd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203032:	00006697          	auipc	a3,0x6
ffffffffc0203036:	8f668693          	addi	a3,a3,-1802 # ffffffffc0208928 <default_pmm_manager+0x6a0>
ffffffffc020303a:	00005617          	auipc	a2,0x5
ffffffffc020303e:	b0660613          	addi	a2,a2,-1274 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203042:	26a00593          	li	a1,618
ffffffffc0203046:	00005517          	auipc	a0,0x5
ffffffffc020304a:	3b250513          	addi	a0,a0,946 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc020304e:	c3afd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203052:	00005697          	auipc	a3,0x5
ffffffffc0203056:	72e68693          	addi	a3,a3,1838 # ffffffffc0208780 <default_pmm_manager+0x4f8>
ffffffffc020305a:	00005617          	auipc	a2,0x5
ffffffffc020305e:	ae660613          	addi	a2,a2,-1306 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203062:	24a00593          	li	a1,586
ffffffffc0203066:	00005517          	auipc	a0,0x5
ffffffffc020306a:	39250513          	addi	a0,a0,914 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc020306e:	c1afd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203072:	00005697          	auipc	a3,0x5
ffffffffc0203076:	7a668693          	addi	a3,a3,1958 # ffffffffc0208818 <default_pmm_manager+0x590>
ffffffffc020307a:	00005617          	auipc	a2,0x5
ffffffffc020307e:	ac660613          	addi	a2,a2,-1338 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203082:	25c00593          	li	a1,604
ffffffffc0203086:	00005517          	auipc	a0,0x5
ffffffffc020308a:	37250513          	addi	a0,a0,882 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc020308e:	bfafd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203092:	00005697          	auipc	a3,0x5
ffffffffc0203096:	41e68693          	addi	a3,a3,1054 # ffffffffc02084b0 <default_pmm_manager+0x228>
ffffffffc020309a:	00005617          	auipc	a2,0x5
ffffffffc020309e:	aa660613          	addi	a2,a2,-1370 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02030a2:	21a00593          	li	a1,538
ffffffffc02030a6:	00005517          	auipc	a0,0x5
ffffffffc02030aa:	35250513          	addi	a0,a0,850 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc02030ae:	bdafd0ef          	jal	ra,ffffffffc0200488 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02030b2:	00005617          	auipc	a2,0x5
ffffffffc02030b6:	25e60613          	addi	a2,a2,606 # ffffffffc0208310 <default_pmm_manager+0x88>
ffffffffc02030ba:	0c100593          	li	a1,193
ffffffffc02030be:	00005517          	auipc	a0,0x5
ffffffffc02030c2:	33a50513          	addi	a0,a0,826 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc02030c6:	bc2fd0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02030ca <copy_range>:
               bool share) {
ffffffffc02030ca:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02030cc:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc02030d0:	f486                	sd	ra,104(sp)
ffffffffc02030d2:	f0a2                	sd	s0,96(sp)
ffffffffc02030d4:	eca6                	sd	s1,88(sp)
ffffffffc02030d6:	e8ca                	sd	s2,80(sp)
ffffffffc02030d8:	e4ce                	sd	s3,72(sp)
ffffffffc02030da:	e0d2                	sd	s4,64(sp)
ffffffffc02030dc:	fc56                	sd	s5,56(sp)
ffffffffc02030de:	f85a                	sd	s6,48(sp)
ffffffffc02030e0:	f45e                	sd	s7,40(sp)
ffffffffc02030e2:	f062                	sd	s8,32(sp)
ffffffffc02030e4:	ec66                	sd	s9,24(sp)
ffffffffc02030e6:	e86a                	sd	s10,16(sp)
ffffffffc02030e8:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02030ea:	03479713          	slli	a4,a5,0x34
ffffffffc02030ee:	1e071863          	bnez	a4,ffffffffc02032de <copy_range+0x214>
    assert(USER_ACCESS(start, end));
ffffffffc02030f2:	002007b7          	lui	a5,0x200
ffffffffc02030f6:	8432                	mv	s0,a2
ffffffffc02030f8:	16f66b63          	bltu	a2,a5,ffffffffc020326e <copy_range+0x1a4>
ffffffffc02030fc:	84b6                	mv	s1,a3
ffffffffc02030fe:	16d67863          	bleu	a3,a2,ffffffffc020326e <copy_range+0x1a4>
ffffffffc0203102:	4785                	li	a5,1
ffffffffc0203104:	07fe                	slli	a5,a5,0x1f
ffffffffc0203106:	16d7e463          	bltu	a5,a3,ffffffffc020326e <copy_range+0x1a4>
ffffffffc020310a:	5a7d                	li	s4,-1
ffffffffc020310c:	8aaa                	mv	s5,a0
ffffffffc020310e:	892e                	mv	s2,a1
        start += PGSIZE;
ffffffffc0203110:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203112:	000dcc17          	auipc	s8,0xdc
ffffffffc0203116:	236c0c13          	addi	s8,s8,566 # ffffffffc02df348 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020311a:	000dcb97          	auipc	s7,0xdc
ffffffffc020311e:	2aeb8b93          	addi	s7,s7,686 # ffffffffc02df3c8 <pages>
    return page - pages + nbase;
ffffffffc0203122:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc0203126:	00ca5a13          	srli	s4,s4,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc020312a:	4601                	li	a2,0
ffffffffc020312c:	85a2                	mv	a1,s0
ffffffffc020312e:	854a                	mv	a0,s2
ffffffffc0203130:	e3dfe0ef          	jal	ra,ffffffffc0201f6c <get_pte>
ffffffffc0203134:	8caa                	mv	s9,a0
        if (ptep == NULL) {
ffffffffc0203136:	c17d                	beqz	a0,ffffffffc020321c <copy_range+0x152>
        if (*ptep & PTE_V) {
ffffffffc0203138:	611c                	ld	a5,0(a0)
ffffffffc020313a:	8b85                	andi	a5,a5,1
ffffffffc020313c:	e785                	bnez	a5,ffffffffc0203164 <copy_range+0x9a>
        start += PGSIZE;
ffffffffc020313e:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc0203140:	fe9465e3          	bltu	s0,s1,ffffffffc020312a <copy_range+0x60>
    return 0;
ffffffffc0203144:	4501                	li	a0,0
}
ffffffffc0203146:	70a6                	ld	ra,104(sp)
ffffffffc0203148:	7406                	ld	s0,96(sp)
ffffffffc020314a:	64e6                	ld	s1,88(sp)
ffffffffc020314c:	6946                	ld	s2,80(sp)
ffffffffc020314e:	69a6                	ld	s3,72(sp)
ffffffffc0203150:	6a06                	ld	s4,64(sp)
ffffffffc0203152:	7ae2                	ld	s5,56(sp)
ffffffffc0203154:	7b42                	ld	s6,48(sp)
ffffffffc0203156:	7ba2                	ld	s7,40(sp)
ffffffffc0203158:	7c02                	ld	s8,32(sp)
ffffffffc020315a:	6ce2                	ld	s9,24(sp)
ffffffffc020315c:	6d42                	ld	s10,16(sp)
ffffffffc020315e:	6da2                	ld	s11,8(sp)
ffffffffc0203160:	6165                	addi	sp,sp,112
ffffffffc0203162:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc0203164:	4605                	li	a2,1
ffffffffc0203166:	85a2                	mv	a1,s0
ffffffffc0203168:	8556                	mv	a0,s5
ffffffffc020316a:	e03fe0ef          	jal	ra,ffffffffc0201f6c <get_pte>
ffffffffc020316e:	c169                	beqz	a0,ffffffffc0203230 <copy_range+0x166>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0203170:	000cb783          	ld	a5,0(s9)
    if (!(pte & PTE_V)) {
ffffffffc0203174:	0017f713          	andi	a4,a5,1
ffffffffc0203178:	01f7fc93          	andi	s9,a5,31
ffffffffc020317c:	14070563          	beqz	a4,ffffffffc02032c6 <copy_range+0x1fc>
    if (PPN(pa) >= npage) {
ffffffffc0203180:	000c3683          	ld	a3,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203184:	078a                	slli	a5,a5,0x2
ffffffffc0203186:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020318a:	12d77263          	bleu	a3,a4,ffffffffc02032ae <copy_range+0x1e4>
    return &pages[PPN(pa) - nbase];
ffffffffc020318e:	000bb783          	ld	a5,0(s7)
ffffffffc0203192:	fff806b7          	lui	a3,0xfff80
ffffffffc0203196:	9736                	add	a4,a4,a3
ffffffffc0203198:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc020319a:	4505                	li	a0,1
ffffffffc020319c:	00e78db3          	add	s11,a5,a4
ffffffffc02031a0:	cbffe0ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc02031a4:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc02031a6:	0a0d8463          	beqz	s11,ffffffffc020324e <copy_range+0x184>
            assert(npage != NULL);
ffffffffc02031aa:	c175                	beqz	a0,ffffffffc020328e <copy_range+0x1c4>
    return page - pages + nbase;
ffffffffc02031ac:	000bb703          	ld	a4,0(s7)
    return KADDR(page2pa(page));
ffffffffc02031b0:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc02031b4:	40ed86b3          	sub	a3,s11,a4
ffffffffc02031b8:	8699                	srai	a3,a3,0x6
ffffffffc02031ba:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc02031bc:	0146f7b3          	and	a5,a3,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc02031c0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02031c2:	06c7fa63          	bleu	a2,a5,ffffffffc0203236 <copy_range+0x16c>
    return page - pages + nbase;
ffffffffc02031c6:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc02031ca:	000dc717          	auipc	a4,0xdc
ffffffffc02031ce:	1ee70713          	addi	a4,a4,494 # ffffffffc02df3b8 <va_pa_offset>
ffffffffc02031d2:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc02031d4:	8799                	srai	a5,a5,0x6
ffffffffc02031d6:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc02031d8:	0147f733          	and	a4,a5,s4
ffffffffc02031dc:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02031e0:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02031e2:	04c77963          	bleu	a2,a4,ffffffffc0203234 <copy_range+0x16a>
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ffffffffc02031e6:	6605                	lui	a2,0x1
ffffffffc02031e8:	953e                	add	a0,a0,a5
ffffffffc02031ea:	34c040ef          	jal	ra,ffffffffc0207536 <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc02031ee:	86e6                	mv	a3,s9
ffffffffc02031f0:	8622                	mv	a2,s0
ffffffffc02031f2:	85ea                	mv	a1,s10
ffffffffc02031f4:	8556                	mv	a0,s5
ffffffffc02031f6:	b8cff0ef          	jal	ra,ffffffffc0202582 <page_insert>
            assert(ret == 0);
ffffffffc02031fa:	d131                	beqz	a0,ffffffffc020313e <copy_range+0x74>
ffffffffc02031fc:	00005697          	auipc	a3,0x5
ffffffffc0203200:	1ec68693          	addi	a3,a3,492 # ffffffffc02083e8 <default_pmm_manager+0x160>
ffffffffc0203204:	00005617          	auipc	a2,0x5
ffffffffc0203208:	93c60613          	addi	a2,a2,-1732 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020320c:	1bc00593          	li	a1,444
ffffffffc0203210:	00005517          	auipc	a0,0x5
ffffffffc0203214:	1e850513          	addi	a0,a0,488 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0203218:	a70fd0ef          	jal	ra,ffffffffc0200488 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020321c:	002007b7          	lui	a5,0x200
ffffffffc0203220:	943e                	add	s0,s0,a5
ffffffffc0203222:	ffe007b7          	lui	a5,0xffe00
ffffffffc0203226:	8c7d                	and	s0,s0,a5
    } while (start != 0 && start < end);
ffffffffc0203228:	dc11                	beqz	s0,ffffffffc0203144 <copy_range+0x7a>
ffffffffc020322a:	f09460e3          	bltu	s0,s1,ffffffffc020312a <copy_range+0x60>
ffffffffc020322e:	bf19                	j	ffffffffc0203144 <copy_range+0x7a>
                return -E_NO_MEM;
ffffffffc0203230:	5571                	li	a0,-4
ffffffffc0203232:	bf11                	j	ffffffffc0203146 <copy_range+0x7c>
ffffffffc0203234:	86be                	mv	a3,a5
ffffffffc0203236:	00005617          	auipc	a2,0x5
ffffffffc020323a:	0a260613          	addi	a2,a2,162 # ffffffffc02082d8 <default_pmm_manager+0x50>
ffffffffc020323e:	06900593          	li	a1,105
ffffffffc0203242:	00005517          	auipc	a0,0x5
ffffffffc0203246:	0be50513          	addi	a0,a0,190 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc020324a:	a3efd0ef          	jal	ra,ffffffffc0200488 <__panic>
            assert(page != NULL);
ffffffffc020324e:	00005697          	auipc	a3,0x5
ffffffffc0203252:	17a68693          	addi	a3,a3,378 # ffffffffc02083c8 <default_pmm_manager+0x140>
ffffffffc0203256:	00005617          	auipc	a2,0x5
ffffffffc020325a:	8ea60613          	addi	a2,a2,-1814 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020325e:	1a300593          	li	a1,419
ffffffffc0203262:	00005517          	auipc	a0,0x5
ffffffffc0203266:	19650513          	addi	a0,a0,406 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc020326a:	a1efd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020326e:	00005697          	auipc	a3,0x5
ffffffffc0203272:	73268693          	addi	a3,a3,1842 # ffffffffc02089a0 <default_pmm_manager+0x718>
ffffffffc0203276:	00005617          	auipc	a2,0x5
ffffffffc020327a:	8ca60613          	addi	a2,a2,-1846 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020327e:	18f00593          	li	a1,399
ffffffffc0203282:	00005517          	auipc	a0,0x5
ffffffffc0203286:	17650513          	addi	a0,a0,374 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc020328a:	9fefd0ef          	jal	ra,ffffffffc0200488 <__panic>
            assert(npage != NULL);
ffffffffc020328e:	00005697          	auipc	a3,0x5
ffffffffc0203292:	14a68693          	addi	a3,a3,330 # ffffffffc02083d8 <default_pmm_manager+0x150>
ffffffffc0203296:	00005617          	auipc	a2,0x5
ffffffffc020329a:	8aa60613          	addi	a2,a2,-1878 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020329e:	1a400593          	li	a1,420
ffffffffc02032a2:	00005517          	auipc	a0,0x5
ffffffffc02032a6:	15650513          	addi	a0,a0,342 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc02032aa:	9defd0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02032ae:	00005617          	auipc	a2,0x5
ffffffffc02032b2:	08a60613          	addi	a2,a2,138 # ffffffffc0208338 <default_pmm_manager+0xb0>
ffffffffc02032b6:	06200593          	li	a1,98
ffffffffc02032ba:	00005517          	auipc	a0,0x5
ffffffffc02032be:	04650513          	addi	a0,a0,70 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc02032c2:	9c6fd0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02032c6:	00005617          	auipc	a2,0x5
ffffffffc02032ca:	2ca60613          	addi	a2,a2,714 # ffffffffc0208590 <default_pmm_manager+0x308>
ffffffffc02032ce:	07400593          	li	a1,116
ffffffffc02032d2:	00005517          	auipc	a0,0x5
ffffffffc02032d6:	02e50513          	addi	a0,a0,46 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc02032da:	9aefd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02032de:	00005697          	auipc	a3,0x5
ffffffffc02032e2:	69268693          	addi	a3,a3,1682 # ffffffffc0208970 <default_pmm_manager+0x6e8>
ffffffffc02032e6:	00005617          	auipc	a2,0x5
ffffffffc02032ea:	85a60613          	addi	a2,a2,-1958 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02032ee:	18e00593          	li	a1,398
ffffffffc02032f2:	00005517          	auipc	a0,0x5
ffffffffc02032f6:	10650513          	addi	a0,a0,262 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc02032fa:	98efd0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02032fe <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02032fe:	12058073          	sfence.vma	a1
}
ffffffffc0203302:	8082                	ret

ffffffffc0203304 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203304:	7179                	addi	sp,sp,-48
ffffffffc0203306:	e84a                	sd	s2,16(sp)
ffffffffc0203308:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc020330a:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc020330c:	f022                	sd	s0,32(sp)
ffffffffc020330e:	ec26                	sd	s1,24(sp)
ffffffffc0203310:	e44e                	sd	s3,8(sp)
ffffffffc0203312:	f406                	sd	ra,40(sp)
ffffffffc0203314:	84ae                	mv	s1,a1
ffffffffc0203316:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0203318:	b47fe0ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc020331c:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc020331e:	cd1d                	beqz	a0,ffffffffc020335c <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203320:	85aa                	mv	a1,a0
ffffffffc0203322:	86ce                	mv	a3,s3
ffffffffc0203324:	8626                	mv	a2,s1
ffffffffc0203326:	854a                	mv	a0,s2
ffffffffc0203328:	a5aff0ef          	jal	ra,ffffffffc0202582 <page_insert>
ffffffffc020332c:	e121                	bnez	a0,ffffffffc020336c <pgdir_alloc_page+0x68>
        if (swap_init_ok) {
ffffffffc020332e:	000dc797          	auipc	a5,0xdc
ffffffffc0203332:	02a78793          	addi	a5,a5,42 # ffffffffc02df358 <swap_init_ok>
ffffffffc0203336:	439c                	lw	a5,0(a5)
ffffffffc0203338:	2781                	sext.w	a5,a5
ffffffffc020333a:	c38d                	beqz	a5,ffffffffc020335c <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc020333c:	000dc797          	auipc	a5,0xdc
ffffffffc0203340:	16c78793          	addi	a5,a5,364 # ffffffffc02df4a8 <check_mm_struct>
ffffffffc0203344:	6388                	ld	a0,0(a5)
ffffffffc0203346:	c919                	beqz	a0,ffffffffc020335c <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0203348:	4681                	li	a3,0
ffffffffc020334a:	8622                	mv	a2,s0
ffffffffc020334c:	85a6                	mv	a1,s1
ffffffffc020334e:	7da000ef          	jal	ra,ffffffffc0203b28 <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0203352:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0203354:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc0203356:	4785                	li	a5,1
ffffffffc0203358:	02f71063          	bne	a4,a5,ffffffffc0203378 <pgdir_alloc_page+0x74>
}
ffffffffc020335c:	8522                	mv	a0,s0
ffffffffc020335e:	70a2                	ld	ra,40(sp)
ffffffffc0203360:	7402                	ld	s0,32(sp)
ffffffffc0203362:	64e2                	ld	s1,24(sp)
ffffffffc0203364:	6942                	ld	s2,16(sp)
ffffffffc0203366:	69a2                	ld	s3,8(sp)
ffffffffc0203368:	6145                	addi	sp,sp,48
ffffffffc020336a:	8082                	ret
            free_page(page);
ffffffffc020336c:	8522                	mv	a0,s0
ffffffffc020336e:	4585                	li	a1,1
ffffffffc0203370:	b77fe0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
            return NULL;
ffffffffc0203374:	4401                	li	s0,0
ffffffffc0203376:	b7dd                	j	ffffffffc020335c <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc0203378:	00005697          	auipc	a3,0x5
ffffffffc020337c:	09068693          	addi	a3,a3,144 # ffffffffc0208408 <default_pmm_manager+0x180>
ffffffffc0203380:	00004617          	auipc	a2,0x4
ffffffffc0203384:	7c060613          	addi	a2,a2,1984 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203388:	1fb00593          	li	a1,507
ffffffffc020338c:	00005517          	auipc	a0,0x5
ffffffffc0203390:	06c50513          	addi	a0,a0,108 # ffffffffc02083f8 <default_pmm_manager+0x170>
ffffffffc0203394:	8f4fd0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0203398 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0203398:	7135                	addi	sp,sp,-160
ffffffffc020339a:	ed06                	sd	ra,152(sp)
ffffffffc020339c:	e922                	sd	s0,144(sp)
ffffffffc020339e:	e526                	sd	s1,136(sp)
ffffffffc02033a0:	e14a                	sd	s2,128(sp)
ffffffffc02033a2:	fcce                	sd	s3,120(sp)
ffffffffc02033a4:	f8d2                	sd	s4,112(sp)
ffffffffc02033a6:	f4d6                	sd	s5,104(sp)
ffffffffc02033a8:	f0da                	sd	s6,96(sp)
ffffffffc02033aa:	ecde                	sd	s7,88(sp)
ffffffffc02033ac:	e8e2                	sd	s8,80(sp)
ffffffffc02033ae:	e4e6                	sd	s9,72(sp)
ffffffffc02033b0:	e0ea                	sd	s10,64(sp)
ffffffffc02033b2:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02033b4:	0ac020ef          	jal	ra,ffffffffc0205460 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02033b8:	000dc797          	auipc	a5,0xdc
ffffffffc02033bc:	0a078793          	addi	a5,a5,160 # ffffffffc02df458 <max_swap_offset>
ffffffffc02033c0:	6394                	ld	a3,0(a5)
ffffffffc02033c2:	010007b7          	lui	a5,0x1000
ffffffffc02033c6:	17e1                	addi	a5,a5,-8
ffffffffc02033c8:	ff968713          	addi	a4,a3,-7
ffffffffc02033cc:	4ae7ee63          	bltu	a5,a4,ffffffffc0203888 <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc02033d0:	000d1797          	auipc	a5,0xd1
ffffffffc02033d4:	aa878793          	addi	a5,a5,-1368 # ffffffffc02d3e78 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02033d8:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02033da:	000dc697          	auipc	a3,0xdc
ffffffffc02033de:	f6f6bb23          	sd	a5,-138(a3) # ffffffffc02df350 <sm>
     int r = sm->init();
ffffffffc02033e2:	9702                	jalr	a4
ffffffffc02033e4:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc02033e6:	c10d                	beqz	a0,ffffffffc0203408 <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02033e8:	60ea                	ld	ra,152(sp)
ffffffffc02033ea:	644a                	ld	s0,144(sp)
ffffffffc02033ec:	8556                	mv	a0,s5
ffffffffc02033ee:	64aa                	ld	s1,136(sp)
ffffffffc02033f0:	690a                	ld	s2,128(sp)
ffffffffc02033f2:	79e6                	ld	s3,120(sp)
ffffffffc02033f4:	7a46                	ld	s4,112(sp)
ffffffffc02033f6:	7aa6                	ld	s5,104(sp)
ffffffffc02033f8:	7b06                	ld	s6,96(sp)
ffffffffc02033fa:	6be6                	ld	s7,88(sp)
ffffffffc02033fc:	6c46                	ld	s8,80(sp)
ffffffffc02033fe:	6ca6                	ld	s9,72(sp)
ffffffffc0203400:	6d06                	ld	s10,64(sp)
ffffffffc0203402:	7de2                	ld	s11,56(sp)
ffffffffc0203404:	610d                	addi	sp,sp,160
ffffffffc0203406:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203408:	000dc797          	auipc	a5,0xdc
ffffffffc020340c:	f4878793          	addi	a5,a5,-184 # ffffffffc02df350 <sm>
ffffffffc0203410:	639c                	ld	a5,0(a5)
ffffffffc0203412:	00005517          	auipc	a0,0x5
ffffffffc0203416:	62650513          	addi	a0,a0,1574 # ffffffffc0208a38 <default_pmm_manager+0x7b0>
    return listelm->next;
ffffffffc020341a:	000dc417          	auipc	s0,0xdc
ffffffffc020341e:	f7e40413          	addi	s0,s0,-130 # ffffffffc02df398 <free_area>
ffffffffc0203422:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0203424:	4785                	li	a5,1
ffffffffc0203426:	000dc717          	auipc	a4,0xdc
ffffffffc020342a:	f2f72923          	sw	a5,-206(a4) # ffffffffc02df358 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020342e:	d65fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc0203432:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203434:	36878e63          	beq	a5,s0,ffffffffc02037b0 <swap_init+0x418>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0203438:	ff07b703          	ld	a4,-16(a5)
ffffffffc020343c:	8305                	srli	a4,a4,0x1
ffffffffc020343e:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203440:	36070c63          	beqz	a4,ffffffffc02037b8 <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc0203444:	4481                	li	s1,0
ffffffffc0203446:	4901                	li	s2,0
ffffffffc0203448:	a031                	j	ffffffffc0203454 <swap_init+0xbc>
ffffffffc020344a:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc020344e:	8b09                	andi	a4,a4,2
ffffffffc0203450:	36070463          	beqz	a4,ffffffffc02037b8 <swap_init+0x420>
        count ++, total += p->property;
ffffffffc0203454:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203458:	679c                	ld	a5,8(a5)
ffffffffc020345a:	2905                	addiw	s2,s2,1
ffffffffc020345c:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020345e:	fe8796e3          	bne	a5,s0,ffffffffc020344a <swap_init+0xb2>
ffffffffc0203462:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0203464:	ac9fe0ef          	jal	ra,ffffffffc0201f2c <nr_free_pages>
ffffffffc0203468:	69351863          	bne	a0,s3,ffffffffc0203af8 <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc020346c:	8626                	mv	a2,s1
ffffffffc020346e:	85ca                	mv	a1,s2
ffffffffc0203470:	00005517          	auipc	a0,0x5
ffffffffc0203474:	5e050513          	addi	a0,a0,1504 # ffffffffc0208a50 <default_pmm_manager+0x7c8>
ffffffffc0203478:	d1bfc0ef          	jal	ra,ffffffffc0200192 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc020347c:	457000ef          	jal	ra,ffffffffc02040d2 <mm_create>
ffffffffc0203480:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0203482:	60050b63          	beqz	a0,ffffffffc0203a98 <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0203486:	000dc797          	auipc	a5,0xdc
ffffffffc020348a:	02278793          	addi	a5,a5,34 # ffffffffc02df4a8 <check_mm_struct>
ffffffffc020348e:	639c                	ld	a5,0(a5)
ffffffffc0203490:	62079463          	bnez	a5,ffffffffc0203ab8 <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203494:	000dc797          	auipc	a5,0xdc
ffffffffc0203498:	eac78793          	addi	a5,a5,-340 # ffffffffc02df340 <boot_pgdir>
ffffffffc020349c:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc02034a0:	000dc797          	auipc	a5,0xdc
ffffffffc02034a4:	00a7b423          	sd	a0,8(a5) # ffffffffc02df4a8 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc02034a8:	000b3783          	ld	a5,0(s6) # 80000 <_binary_obj___user_matrix_out_size+0x743c0>
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02034ac:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02034b0:	4e079863          	bnez	a5,ffffffffc02039a0 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02034b4:	6599                	lui	a1,0x6
ffffffffc02034b6:	460d                	li	a2,3
ffffffffc02034b8:	6505                	lui	a0,0x1
ffffffffc02034ba:	46b000ef          	jal	ra,ffffffffc0204124 <vma_create>
ffffffffc02034be:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02034c0:	50050063          	beqz	a0,ffffffffc02039c0 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc02034c4:	855e                	mv	a0,s7
ffffffffc02034c6:	4cb000ef          	jal	ra,ffffffffc0204190 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02034ca:	00005517          	auipc	a0,0x5
ffffffffc02034ce:	5f650513          	addi	a0,a0,1526 # ffffffffc0208ac0 <default_pmm_manager+0x838>
ffffffffc02034d2:	cc1fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02034d6:	018bb503          	ld	a0,24(s7)
ffffffffc02034da:	4605                	li	a2,1
ffffffffc02034dc:	6585                	lui	a1,0x1
ffffffffc02034de:	a8ffe0ef          	jal	ra,ffffffffc0201f6c <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02034e2:	4e050f63          	beqz	a0,ffffffffc02039e0 <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02034e6:	00005517          	auipc	a0,0x5
ffffffffc02034ea:	62a50513          	addi	a0,a0,1578 # ffffffffc0208b10 <default_pmm_manager+0x888>
ffffffffc02034ee:	000dc997          	auipc	s3,0xdc
ffffffffc02034f2:	ee298993          	addi	s3,s3,-286 # ffffffffc02df3d0 <check_rp>
ffffffffc02034f6:	c9dfc0ef          	jal	ra,ffffffffc0200192 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02034fa:	000dca17          	auipc	s4,0xdc
ffffffffc02034fe:	ef6a0a13          	addi	s4,s4,-266 # ffffffffc02df3f0 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203502:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc0203504:	4505                	li	a0,1
ffffffffc0203506:	959fe0ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc020350a:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc020350e:	32050d63          	beqz	a0,ffffffffc0203848 <swap_init+0x4b0>
ffffffffc0203512:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0203514:	8b89                	andi	a5,a5,2
ffffffffc0203516:	30079963          	bnez	a5,ffffffffc0203828 <swap_init+0x490>
ffffffffc020351a:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020351c:	ff4c14e3          	bne	s8,s4,ffffffffc0203504 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0203520:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0203522:	000dcc17          	auipc	s8,0xdc
ffffffffc0203526:	eaec0c13          	addi	s8,s8,-338 # ffffffffc02df3d0 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc020352a:	ec3e                	sd	a5,24(sp)
ffffffffc020352c:	641c                	ld	a5,8(s0)
ffffffffc020352e:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0203530:	481c                	lw	a5,16(s0)
ffffffffc0203532:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0203534:	000dc797          	auipc	a5,0xdc
ffffffffc0203538:	e687b623          	sd	s0,-404(a5) # ffffffffc02df3a0 <free_area+0x8>
ffffffffc020353c:	000dc797          	auipc	a5,0xdc
ffffffffc0203540:	e487be23          	sd	s0,-420(a5) # ffffffffc02df398 <free_area>
     nr_free = 0;
ffffffffc0203544:	000dc797          	auipc	a5,0xdc
ffffffffc0203548:	e607a223          	sw	zero,-412(a5) # ffffffffc02df3a8 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc020354c:	000c3503          	ld	a0,0(s8)
ffffffffc0203550:	4585                	li	a1,1
ffffffffc0203552:	0c21                	addi	s8,s8,8
ffffffffc0203554:	993fe0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203558:	ff4c1ae3          	bne	s8,s4,ffffffffc020354c <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020355c:	01042c03          	lw	s8,16(s0)
ffffffffc0203560:	4791                	li	a5,4
ffffffffc0203562:	50fc1b63          	bne	s8,a5,ffffffffc0203a78 <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0203566:	00005517          	auipc	a0,0x5
ffffffffc020356a:	63250513          	addi	a0,a0,1586 # ffffffffc0208b98 <default_pmm_manager+0x910>
ffffffffc020356e:	c25fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203572:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0203574:	000dc797          	auipc	a5,0xdc
ffffffffc0203578:	de07a423          	sw	zero,-536(a5) # ffffffffc02df35c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020357c:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc020357e:	000dc797          	auipc	a5,0xdc
ffffffffc0203582:	dde78793          	addi	a5,a5,-546 # ffffffffc02df35c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203586:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x8ad8>
     assert(pgfault_num==1);
ffffffffc020358a:	4398                	lw	a4,0(a5)
ffffffffc020358c:	4585                	li	a1,1
ffffffffc020358e:	2701                	sext.w	a4,a4
ffffffffc0203590:	38b71863          	bne	a4,a1,ffffffffc0203920 <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0203594:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0203598:	4394                	lw	a3,0(a5)
ffffffffc020359a:	2681                	sext.w	a3,a3
ffffffffc020359c:	3ae69263          	bne	a3,a4,ffffffffc0203940 <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02035a0:	6689                	lui	a3,0x2
ffffffffc02035a2:	462d                	li	a2,11
ffffffffc02035a4:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7ad8>
     assert(pgfault_num==2);
ffffffffc02035a8:	4398                	lw	a4,0(a5)
ffffffffc02035aa:	4589                	li	a1,2
ffffffffc02035ac:	2701                	sext.w	a4,a4
ffffffffc02035ae:	2eb71963          	bne	a4,a1,ffffffffc02038a0 <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02035b2:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc02035b6:	4394                	lw	a3,0(a5)
ffffffffc02035b8:	2681                	sext.w	a3,a3
ffffffffc02035ba:	30e69363          	bne	a3,a4,ffffffffc02038c0 <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02035be:	668d                	lui	a3,0x3
ffffffffc02035c0:	4631                	li	a2,12
ffffffffc02035c2:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6ad8>
     assert(pgfault_num==3);
ffffffffc02035c6:	4398                	lw	a4,0(a5)
ffffffffc02035c8:	458d                	li	a1,3
ffffffffc02035ca:	2701                	sext.w	a4,a4
ffffffffc02035cc:	30b71a63          	bne	a4,a1,ffffffffc02038e0 <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02035d0:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02035d4:	4394                	lw	a3,0(a5)
ffffffffc02035d6:	2681                	sext.w	a3,a3
ffffffffc02035d8:	32e69463          	bne	a3,a4,ffffffffc0203900 <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02035dc:	6691                	lui	a3,0x4
ffffffffc02035de:	4635                	li	a2,13
ffffffffc02035e0:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5ad8>
     assert(pgfault_num==4);
ffffffffc02035e4:	4398                	lw	a4,0(a5)
ffffffffc02035e6:	2701                	sext.w	a4,a4
ffffffffc02035e8:	37871c63          	bne	a4,s8,ffffffffc0203960 <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02035ec:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02035f0:	439c                	lw	a5,0(a5)
ffffffffc02035f2:	2781                	sext.w	a5,a5
ffffffffc02035f4:	38e79663          	bne	a5,a4,ffffffffc0203980 <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02035f8:	481c                	lw	a5,16(s0)
ffffffffc02035fa:	40079363          	bnez	a5,ffffffffc0203a00 <swap_init+0x668>
ffffffffc02035fe:	000dc797          	auipc	a5,0xdc
ffffffffc0203602:	df278793          	addi	a5,a5,-526 # ffffffffc02df3f0 <swap_in_seq_no>
ffffffffc0203606:	000dc717          	auipc	a4,0xdc
ffffffffc020360a:	e1270713          	addi	a4,a4,-494 # ffffffffc02df418 <swap_out_seq_no>
ffffffffc020360e:	000dc617          	auipc	a2,0xdc
ffffffffc0203612:	e0a60613          	addi	a2,a2,-502 # ffffffffc02df418 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0203616:	56fd                	li	a3,-1
ffffffffc0203618:	c394                	sw	a3,0(a5)
ffffffffc020361a:	c314                	sw	a3,0(a4)
ffffffffc020361c:	0791                	addi	a5,a5,4
ffffffffc020361e:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0203620:	fef61ce3          	bne	a2,a5,ffffffffc0203618 <swap_init+0x280>
ffffffffc0203624:	000dc697          	auipc	a3,0xdc
ffffffffc0203628:	e5468693          	addi	a3,a3,-428 # ffffffffc02df478 <check_ptep>
ffffffffc020362c:	000dc817          	auipc	a6,0xdc
ffffffffc0203630:	da480813          	addi	a6,a6,-604 # ffffffffc02df3d0 <check_rp>
ffffffffc0203634:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203636:	000dcc97          	auipc	s9,0xdc
ffffffffc020363a:	d12c8c93          	addi	s9,s9,-750 # ffffffffc02df348 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020363e:	00007d97          	auipc	s11,0x7
ffffffffc0203642:	312d8d93          	addi	s11,s11,786 # ffffffffc020a950 <nbase>
ffffffffc0203646:	000dcc17          	auipc	s8,0xdc
ffffffffc020364a:	d82c0c13          	addi	s8,s8,-638 # ffffffffc02df3c8 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc020364e:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203652:	4601                	li	a2,0
ffffffffc0203654:	85ea                	mv	a1,s10
ffffffffc0203656:	855a                	mv	a0,s6
ffffffffc0203658:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc020365a:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020365c:	911fe0ef          	jal	ra,ffffffffc0201f6c <get_pte>
ffffffffc0203660:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203662:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203664:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0203666:	20050163          	beqz	a0,ffffffffc0203868 <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020366a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020366c:	0017f613          	andi	a2,a5,1
ffffffffc0203670:	1a060063          	beqz	a2,ffffffffc0203810 <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc0203674:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203678:	078a                	slli	a5,a5,0x2
ffffffffc020367a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020367c:	14c7fe63          	bleu	a2,a5,ffffffffc02037d8 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203680:	000db703          	ld	a4,0(s11)
ffffffffc0203684:	000c3603          	ld	a2,0(s8)
ffffffffc0203688:	00083583          	ld	a1,0(a6)
ffffffffc020368c:	8f99                	sub	a5,a5,a4
ffffffffc020368e:	079a                	slli	a5,a5,0x6
ffffffffc0203690:	e43a                	sd	a4,8(sp)
ffffffffc0203692:	97b2                	add	a5,a5,a2
ffffffffc0203694:	14f59e63          	bne	a1,a5,ffffffffc02037f0 <swap_init+0x458>
ffffffffc0203698:	6785                	lui	a5,0x1
ffffffffc020369a:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020369c:	6795                	lui	a5,0x5
ffffffffc020369e:	06a1                	addi	a3,a3,8
ffffffffc02036a0:	0821                	addi	a6,a6,8
ffffffffc02036a2:	fafd16e3          	bne	s10,a5,ffffffffc020364e <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc02036a6:	00005517          	auipc	a0,0x5
ffffffffc02036aa:	59a50513          	addi	a0,a0,1434 # ffffffffc0208c40 <default_pmm_manager+0x9b8>
ffffffffc02036ae:	ae5fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    int ret = sm->check_swap();
ffffffffc02036b2:	000dc797          	auipc	a5,0xdc
ffffffffc02036b6:	c9e78793          	addi	a5,a5,-866 # ffffffffc02df350 <sm>
ffffffffc02036ba:	639c                	ld	a5,0(a5)
ffffffffc02036bc:	7f9c                	ld	a5,56(a5)
ffffffffc02036be:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02036c0:	40051c63          	bnez	a0,ffffffffc0203ad8 <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc02036c4:	77a2                	ld	a5,40(sp)
ffffffffc02036c6:	000dc717          	auipc	a4,0xdc
ffffffffc02036ca:	cef72123          	sw	a5,-798(a4) # ffffffffc02df3a8 <free_area+0x10>
     free_list = free_list_store;
ffffffffc02036ce:	67e2                	ld	a5,24(sp)
ffffffffc02036d0:	000dc717          	auipc	a4,0xdc
ffffffffc02036d4:	ccf73423          	sd	a5,-824(a4) # ffffffffc02df398 <free_area>
ffffffffc02036d8:	7782                	ld	a5,32(sp)
ffffffffc02036da:	000dc717          	auipc	a4,0xdc
ffffffffc02036de:	ccf73323          	sd	a5,-826(a4) # ffffffffc02df3a0 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02036e2:	0009b503          	ld	a0,0(s3)
ffffffffc02036e6:	4585                	li	a1,1
ffffffffc02036e8:	09a1                	addi	s3,s3,8
ffffffffc02036ea:	ffcfe0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02036ee:	ff499ae3          	bne	s3,s4,ffffffffc02036e2 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc02036f2:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc02036f6:	855e                	mv	a0,s7
ffffffffc02036f8:	367000ef          	jal	ra,ffffffffc020425e <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02036fc:	000dc797          	auipc	a5,0xdc
ffffffffc0203700:	c4478793          	addi	a5,a5,-956 # ffffffffc02df340 <boot_pgdir>
ffffffffc0203704:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc0203706:	000dc697          	auipc	a3,0xdc
ffffffffc020370a:	da06b123          	sd	zero,-606(a3) # ffffffffc02df4a8 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc020370e:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203712:	6394                	ld	a3,0(a5)
ffffffffc0203714:	068a                	slli	a3,a3,0x2
ffffffffc0203716:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203718:	0ce6f063          	bleu	a4,a3,ffffffffc02037d8 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc020371c:	67a2                	ld	a5,8(sp)
ffffffffc020371e:	000c3503          	ld	a0,0(s8)
ffffffffc0203722:	8e9d                	sub	a3,a3,a5
ffffffffc0203724:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0203726:	8699                	srai	a3,a3,0x6
ffffffffc0203728:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020372a:	57fd                	li	a5,-1
ffffffffc020372c:	83b1                	srli	a5,a5,0xc
ffffffffc020372e:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203730:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203732:	2ee7f763          	bleu	a4,a5,ffffffffc0203a20 <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc0203736:	000dc797          	auipc	a5,0xdc
ffffffffc020373a:	c8278793          	addi	a5,a5,-894 # ffffffffc02df3b8 <va_pa_offset>
ffffffffc020373e:	639c                	ld	a5,0(a5)
ffffffffc0203740:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203742:	629c                	ld	a5,0(a3)
ffffffffc0203744:	078a                	slli	a5,a5,0x2
ffffffffc0203746:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203748:	08e7f863          	bleu	a4,a5,ffffffffc02037d8 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc020374c:	69a2                	ld	s3,8(sp)
ffffffffc020374e:	4585                	li	a1,1
ffffffffc0203750:	413787b3          	sub	a5,a5,s3
ffffffffc0203754:	079a                	slli	a5,a5,0x6
ffffffffc0203756:	953e                	add	a0,a0,a5
ffffffffc0203758:	f8efe0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020375c:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203760:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203764:	078a                	slli	a5,a5,0x2
ffffffffc0203766:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203768:	06e7f863          	bleu	a4,a5,ffffffffc02037d8 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc020376c:	000c3503          	ld	a0,0(s8)
ffffffffc0203770:	413787b3          	sub	a5,a5,s3
ffffffffc0203774:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0203776:	4585                	li	a1,1
ffffffffc0203778:	953e                	add	a0,a0,a5
ffffffffc020377a:	f6cfe0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
     pgdir[0] = 0;
ffffffffc020377e:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203782:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0203786:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203788:	00878963          	beq	a5,s0,ffffffffc020379a <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc020378c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203790:	679c                	ld	a5,8(a5)
ffffffffc0203792:	397d                	addiw	s2,s2,-1
ffffffffc0203794:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203796:	fe879be3          	bne	a5,s0,ffffffffc020378c <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc020379a:	28091f63          	bnez	s2,ffffffffc0203a38 <swap_init+0x6a0>
     assert(total==0);
ffffffffc020379e:	2a049d63          	bnez	s1,ffffffffc0203a58 <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc02037a2:	00005517          	auipc	a0,0x5
ffffffffc02037a6:	4ee50513          	addi	a0,a0,1262 # ffffffffc0208c90 <default_pmm_manager+0xa08>
ffffffffc02037aa:	9e9fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc02037ae:	b92d                	j	ffffffffc02033e8 <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc02037b0:	4481                	li	s1,0
ffffffffc02037b2:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc02037b4:	4981                	li	s3,0
ffffffffc02037b6:	b17d                	j	ffffffffc0203464 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc02037b8:	00004697          	auipc	a3,0x4
ffffffffc02037bc:	74068693          	addi	a3,a3,1856 # ffffffffc0207ef8 <commands+0x878>
ffffffffc02037c0:	00004617          	auipc	a2,0x4
ffffffffc02037c4:	38060613          	addi	a2,a2,896 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02037c8:	0bc00593          	li	a1,188
ffffffffc02037cc:	00005517          	auipc	a0,0x5
ffffffffc02037d0:	25c50513          	addi	a0,a0,604 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc02037d4:	cb5fc0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02037d8:	00005617          	auipc	a2,0x5
ffffffffc02037dc:	b6060613          	addi	a2,a2,-1184 # ffffffffc0208338 <default_pmm_manager+0xb0>
ffffffffc02037e0:	06200593          	li	a1,98
ffffffffc02037e4:	00005517          	auipc	a0,0x5
ffffffffc02037e8:	b1c50513          	addi	a0,a0,-1252 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc02037ec:	c9dfc0ef          	jal	ra,ffffffffc0200488 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02037f0:	00005697          	auipc	a3,0x5
ffffffffc02037f4:	42868693          	addi	a3,a3,1064 # ffffffffc0208c18 <default_pmm_manager+0x990>
ffffffffc02037f8:	00004617          	auipc	a2,0x4
ffffffffc02037fc:	34860613          	addi	a2,a2,840 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203800:	0fc00593          	li	a1,252
ffffffffc0203804:	00005517          	auipc	a0,0x5
ffffffffc0203808:	22450513          	addi	a0,a0,548 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc020380c:	c7dfc0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203810:	00005617          	auipc	a2,0x5
ffffffffc0203814:	d8060613          	addi	a2,a2,-640 # ffffffffc0208590 <default_pmm_manager+0x308>
ffffffffc0203818:	07400593          	li	a1,116
ffffffffc020381c:	00005517          	auipc	a0,0x5
ffffffffc0203820:	ae450513          	addi	a0,a0,-1308 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc0203824:	c65fc0ef          	jal	ra,ffffffffc0200488 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0203828:	00005697          	auipc	a3,0x5
ffffffffc020382c:	32868693          	addi	a3,a3,808 # ffffffffc0208b50 <default_pmm_manager+0x8c8>
ffffffffc0203830:	00004617          	auipc	a2,0x4
ffffffffc0203834:	31060613          	addi	a2,a2,784 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203838:	0dd00593          	li	a1,221
ffffffffc020383c:	00005517          	auipc	a0,0x5
ffffffffc0203840:	1ec50513          	addi	a0,a0,492 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc0203844:	c45fc0ef          	jal	ra,ffffffffc0200488 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0203848:	00005697          	auipc	a3,0x5
ffffffffc020384c:	2f068693          	addi	a3,a3,752 # ffffffffc0208b38 <default_pmm_manager+0x8b0>
ffffffffc0203850:	00004617          	auipc	a2,0x4
ffffffffc0203854:	2f060613          	addi	a2,a2,752 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203858:	0dc00593          	li	a1,220
ffffffffc020385c:	00005517          	auipc	a0,0x5
ffffffffc0203860:	1cc50513          	addi	a0,a0,460 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc0203864:	c25fc0ef          	jal	ra,ffffffffc0200488 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203868:	00005697          	auipc	a3,0x5
ffffffffc020386c:	39868693          	addi	a3,a3,920 # ffffffffc0208c00 <default_pmm_manager+0x978>
ffffffffc0203870:	00004617          	auipc	a2,0x4
ffffffffc0203874:	2d060613          	addi	a2,a2,720 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203878:	0fb00593          	li	a1,251
ffffffffc020387c:	00005517          	auipc	a0,0x5
ffffffffc0203880:	1ac50513          	addi	a0,a0,428 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc0203884:	c05fc0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0203888:	00005617          	auipc	a2,0x5
ffffffffc020388c:	18060613          	addi	a2,a2,384 # ffffffffc0208a08 <default_pmm_manager+0x780>
ffffffffc0203890:	02800593          	li	a1,40
ffffffffc0203894:	00005517          	auipc	a0,0x5
ffffffffc0203898:	19450513          	addi	a0,a0,404 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc020389c:	bedfc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==2);
ffffffffc02038a0:	00005697          	auipc	a3,0x5
ffffffffc02038a4:	33068693          	addi	a3,a3,816 # ffffffffc0208bd0 <default_pmm_manager+0x948>
ffffffffc02038a8:	00004617          	auipc	a2,0x4
ffffffffc02038ac:	29860613          	addi	a2,a2,664 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02038b0:	09700593          	li	a1,151
ffffffffc02038b4:	00005517          	auipc	a0,0x5
ffffffffc02038b8:	17450513          	addi	a0,a0,372 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc02038bc:	bcdfc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==2);
ffffffffc02038c0:	00005697          	auipc	a3,0x5
ffffffffc02038c4:	31068693          	addi	a3,a3,784 # ffffffffc0208bd0 <default_pmm_manager+0x948>
ffffffffc02038c8:	00004617          	auipc	a2,0x4
ffffffffc02038cc:	27860613          	addi	a2,a2,632 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02038d0:	09900593          	li	a1,153
ffffffffc02038d4:	00005517          	auipc	a0,0x5
ffffffffc02038d8:	15450513          	addi	a0,a0,340 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc02038dc:	badfc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==3);
ffffffffc02038e0:	00005697          	auipc	a3,0x5
ffffffffc02038e4:	30068693          	addi	a3,a3,768 # ffffffffc0208be0 <default_pmm_manager+0x958>
ffffffffc02038e8:	00004617          	auipc	a2,0x4
ffffffffc02038ec:	25860613          	addi	a2,a2,600 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02038f0:	09b00593          	li	a1,155
ffffffffc02038f4:	00005517          	auipc	a0,0x5
ffffffffc02038f8:	13450513          	addi	a0,a0,308 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc02038fc:	b8dfc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==3);
ffffffffc0203900:	00005697          	auipc	a3,0x5
ffffffffc0203904:	2e068693          	addi	a3,a3,736 # ffffffffc0208be0 <default_pmm_manager+0x958>
ffffffffc0203908:	00004617          	auipc	a2,0x4
ffffffffc020390c:	23860613          	addi	a2,a2,568 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203910:	09d00593          	li	a1,157
ffffffffc0203914:	00005517          	auipc	a0,0x5
ffffffffc0203918:	11450513          	addi	a0,a0,276 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc020391c:	b6dfc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==1);
ffffffffc0203920:	00005697          	auipc	a3,0x5
ffffffffc0203924:	2a068693          	addi	a3,a3,672 # ffffffffc0208bc0 <default_pmm_manager+0x938>
ffffffffc0203928:	00004617          	auipc	a2,0x4
ffffffffc020392c:	21860613          	addi	a2,a2,536 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203930:	09300593          	li	a1,147
ffffffffc0203934:	00005517          	auipc	a0,0x5
ffffffffc0203938:	0f450513          	addi	a0,a0,244 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc020393c:	b4dfc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==1);
ffffffffc0203940:	00005697          	auipc	a3,0x5
ffffffffc0203944:	28068693          	addi	a3,a3,640 # ffffffffc0208bc0 <default_pmm_manager+0x938>
ffffffffc0203948:	00004617          	auipc	a2,0x4
ffffffffc020394c:	1f860613          	addi	a2,a2,504 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203950:	09500593          	li	a1,149
ffffffffc0203954:	00005517          	auipc	a0,0x5
ffffffffc0203958:	0d450513          	addi	a0,a0,212 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc020395c:	b2dfc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==4);
ffffffffc0203960:	00005697          	auipc	a3,0x5
ffffffffc0203964:	29068693          	addi	a3,a3,656 # ffffffffc0208bf0 <default_pmm_manager+0x968>
ffffffffc0203968:	00004617          	auipc	a2,0x4
ffffffffc020396c:	1d860613          	addi	a2,a2,472 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203970:	09f00593          	li	a1,159
ffffffffc0203974:	00005517          	auipc	a0,0x5
ffffffffc0203978:	0b450513          	addi	a0,a0,180 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc020397c:	b0dfc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==4);
ffffffffc0203980:	00005697          	auipc	a3,0x5
ffffffffc0203984:	27068693          	addi	a3,a3,624 # ffffffffc0208bf0 <default_pmm_manager+0x968>
ffffffffc0203988:	00004617          	auipc	a2,0x4
ffffffffc020398c:	1b860613          	addi	a2,a2,440 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203990:	0a100593          	li	a1,161
ffffffffc0203994:	00005517          	auipc	a0,0x5
ffffffffc0203998:	09450513          	addi	a0,a0,148 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc020399c:	aedfc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgdir[0] == 0);
ffffffffc02039a0:	00005697          	auipc	a3,0x5
ffffffffc02039a4:	10068693          	addi	a3,a3,256 # ffffffffc0208aa0 <default_pmm_manager+0x818>
ffffffffc02039a8:	00004617          	auipc	a2,0x4
ffffffffc02039ac:	19860613          	addi	a2,a2,408 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02039b0:	0cc00593          	li	a1,204
ffffffffc02039b4:	00005517          	auipc	a0,0x5
ffffffffc02039b8:	07450513          	addi	a0,a0,116 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc02039bc:	acdfc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(vma != NULL);
ffffffffc02039c0:	00005697          	auipc	a3,0x5
ffffffffc02039c4:	0f068693          	addi	a3,a3,240 # ffffffffc0208ab0 <default_pmm_manager+0x828>
ffffffffc02039c8:	00004617          	auipc	a2,0x4
ffffffffc02039cc:	17860613          	addi	a2,a2,376 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02039d0:	0cf00593          	li	a1,207
ffffffffc02039d4:	00005517          	auipc	a0,0x5
ffffffffc02039d8:	05450513          	addi	a0,a0,84 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc02039dc:	aadfc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02039e0:	00005697          	auipc	a3,0x5
ffffffffc02039e4:	11868693          	addi	a3,a3,280 # ffffffffc0208af8 <default_pmm_manager+0x870>
ffffffffc02039e8:	00004617          	auipc	a2,0x4
ffffffffc02039ec:	15860613          	addi	a2,a2,344 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02039f0:	0d700593          	li	a1,215
ffffffffc02039f4:	00005517          	auipc	a0,0x5
ffffffffc02039f8:	03450513          	addi	a0,a0,52 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc02039fc:	a8dfc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert( nr_free == 0);         
ffffffffc0203a00:	00004697          	auipc	a3,0x4
ffffffffc0203a04:	6c868693          	addi	a3,a3,1736 # ffffffffc02080c8 <commands+0xa48>
ffffffffc0203a08:	00004617          	auipc	a2,0x4
ffffffffc0203a0c:	13860613          	addi	a2,a2,312 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203a10:	0f300593          	li	a1,243
ffffffffc0203a14:	00005517          	auipc	a0,0x5
ffffffffc0203a18:	01450513          	addi	a0,a0,20 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc0203a1c:	a6dfc0ef          	jal	ra,ffffffffc0200488 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203a20:	00005617          	auipc	a2,0x5
ffffffffc0203a24:	8b860613          	addi	a2,a2,-1864 # ffffffffc02082d8 <default_pmm_manager+0x50>
ffffffffc0203a28:	06900593          	li	a1,105
ffffffffc0203a2c:	00005517          	auipc	a0,0x5
ffffffffc0203a30:	8d450513          	addi	a0,a0,-1836 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc0203a34:	a55fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(count==0);
ffffffffc0203a38:	00005697          	auipc	a3,0x5
ffffffffc0203a3c:	23868693          	addi	a3,a3,568 # ffffffffc0208c70 <default_pmm_manager+0x9e8>
ffffffffc0203a40:	00004617          	auipc	a2,0x4
ffffffffc0203a44:	10060613          	addi	a2,a2,256 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203a48:	11d00593          	li	a1,285
ffffffffc0203a4c:	00005517          	auipc	a0,0x5
ffffffffc0203a50:	fdc50513          	addi	a0,a0,-36 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc0203a54:	a35fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(total==0);
ffffffffc0203a58:	00005697          	auipc	a3,0x5
ffffffffc0203a5c:	22868693          	addi	a3,a3,552 # ffffffffc0208c80 <default_pmm_manager+0x9f8>
ffffffffc0203a60:	00004617          	auipc	a2,0x4
ffffffffc0203a64:	0e060613          	addi	a2,a2,224 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203a68:	11e00593          	li	a1,286
ffffffffc0203a6c:	00005517          	auipc	a0,0x5
ffffffffc0203a70:	fbc50513          	addi	a0,a0,-68 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc0203a74:	a15fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203a78:	00005697          	auipc	a3,0x5
ffffffffc0203a7c:	0f868693          	addi	a3,a3,248 # ffffffffc0208b70 <default_pmm_manager+0x8e8>
ffffffffc0203a80:	00004617          	auipc	a2,0x4
ffffffffc0203a84:	0c060613          	addi	a2,a2,192 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203a88:	0ea00593          	li	a1,234
ffffffffc0203a8c:	00005517          	auipc	a0,0x5
ffffffffc0203a90:	f9c50513          	addi	a0,a0,-100 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc0203a94:	9f5fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(mm != NULL);
ffffffffc0203a98:	00005697          	auipc	a3,0x5
ffffffffc0203a9c:	fe068693          	addi	a3,a3,-32 # ffffffffc0208a78 <default_pmm_manager+0x7f0>
ffffffffc0203aa0:	00004617          	auipc	a2,0x4
ffffffffc0203aa4:	0a060613          	addi	a2,a2,160 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203aa8:	0c400593          	li	a1,196
ffffffffc0203aac:	00005517          	auipc	a0,0x5
ffffffffc0203ab0:	f7c50513          	addi	a0,a0,-132 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc0203ab4:	9d5fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203ab8:	00005697          	auipc	a3,0x5
ffffffffc0203abc:	fd068693          	addi	a3,a3,-48 # ffffffffc0208a88 <default_pmm_manager+0x800>
ffffffffc0203ac0:	00004617          	auipc	a2,0x4
ffffffffc0203ac4:	08060613          	addi	a2,a2,128 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203ac8:	0c700593          	li	a1,199
ffffffffc0203acc:	00005517          	auipc	a0,0x5
ffffffffc0203ad0:	f5c50513          	addi	a0,a0,-164 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc0203ad4:	9b5fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(ret==0);
ffffffffc0203ad8:	00005697          	auipc	a3,0x5
ffffffffc0203adc:	19068693          	addi	a3,a3,400 # ffffffffc0208c68 <default_pmm_manager+0x9e0>
ffffffffc0203ae0:	00004617          	auipc	a2,0x4
ffffffffc0203ae4:	06060613          	addi	a2,a2,96 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203ae8:	10200593          	li	a1,258
ffffffffc0203aec:	00005517          	auipc	a0,0x5
ffffffffc0203af0:	f3c50513          	addi	a0,a0,-196 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc0203af4:	995fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203af8:	00004697          	auipc	a3,0x4
ffffffffc0203afc:	42868693          	addi	a3,a3,1064 # ffffffffc0207f20 <commands+0x8a0>
ffffffffc0203b00:	00004617          	auipc	a2,0x4
ffffffffc0203b04:	04060613          	addi	a2,a2,64 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203b08:	0bf00593          	li	a1,191
ffffffffc0203b0c:	00005517          	auipc	a0,0x5
ffffffffc0203b10:	f1c50513          	addi	a0,a0,-228 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc0203b14:	975fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0203b18 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203b18:	000dc797          	auipc	a5,0xdc
ffffffffc0203b1c:	83878793          	addi	a5,a5,-1992 # ffffffffc02df350 <sm>
ffffffffc0203b20:	639c                	ld	a5,0(a5)
ffffffffc0203b22:	0107b303          	ld	t1,16(a5)
ffffffffc0203b26:	8302                	jr	t1

ffffffffc0203b28 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203b28:	000dc797          	auipc	a5,0xdc
ffffffffc0203b2c:	82878793          	addi	a5,a5,-2008 # ffffffffc02df350 <sm>
ffffffffc0203b30:	639c                	ld	a5,0(a5)
ffffffffc0203b32:	0207b303          	ld	t1,32(a5)
ffffffffc0203b36:	8302                	jr	t1

ffffffffc0203b38 <swap_out>:
{
ffffffffc0203b38:	711d                	addi	sp,sp,-96
ffffffffc0203b3a:	ec86                	sd	ra,88(sp)
ffffffffc0203b3c:	e8a2                	sd	s0,80(sp)
ffffffffc0203b3e:	e4a6                	sd	s1,72(sp)
ffffffffc0203b40:	e0ca                	sd	s2,64(sp)
ffffffffc0203b42:	fc4e                	sd	s3,56(sp)
ffffffffc0203b44:	f852                	sd	s4,48(sp)
ffffffffc0203b46:	f456                	sd	s5,40(sp)
ffffffffc0203b48:	f05a                	sd	s6,32(sp)
ffffffffc0203b4a:	ec5e                	sd	s7,24(sp)
ffffffffc0203b4c:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203b4e:	cde9                	beqz	a1,ffffffffc0203c28 <swap_out+0xf0>
ffffffffc0203b50:	8ab2                	mv	s5,a2
ffffffffc0203b52:	892a                	mv	s2,a0
ffffffffc0203b54:	8a2e                	mv	s4,a1
ffffffffc0203b56:	4401                	li	s0,0
ffffffffc0203b58:	000db997          	auipc	s3,0xdb
ffffffffc0203b5c:	7f898993          	addi	s3,s3,2040 # ffffffffc02df350 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b60:	00005b17          	auipc	s6,0x5
ffffffffc0203b64:	1b0b0b13          	addi	s6,s6,432 # ffffffffc0208d10 <default_pmm_manager+0xa88>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203b68:	00005b97          	auipc	s7,0x5
ffffffffc0203b6c:	190b8b93          	addi	s7,s7,400 # ffffffffc0208cf8 <default_pmm_manager+0xa70>
ffffffffc0203b70:	a825                	j	ffffffffc0203ba8 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b72:	67a2                	ld	a5,8(sp)
ffffffffc0203b74:	8626                	mv	a2,s1
ffffffffc0203b76:	85a2                	mv	a1,s0
ffffffffc0203b78:	7f94                	ld	a3,56(a5)
ffffffffc0203b7a:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203b7c:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b7e:	82b1                	srli	a3,a3,0xc
ffffffffc0203b80:	0685                	addi	a3,a3,1
ffffffffc0203b82:	e10fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b86:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203b88:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b8a:	7d1c                	ld	a5,56(a0)
ffffffffc0203b8c:	83b1                	srli	a5,a5,0xc
ffffffffc0203b8e:	0785                	addi	a5,a5,1
ffffffffc0203b90:	07a2                	slli	a5,a5,0x8
ffffffffc0203b92:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203b96:	b50fe0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203b9a:	01893503          	ld	a0,24(s2)
ffffffffc0203b9e:	85a6                	mv	a1,s1
ffffffffc0203ba0:	f5eff0ef          	jal	ra,ffffffffc02032fe <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203ba4:	048a0d63          	beq	s4,s0,ffffffffc0203bfe <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203ba8:	0009b783          	ld	a5,0(s3)
ffffffffc0203bac:	8656                	mv	a2,s5
ffffffffc0203bae:	002c                	addi	a1,sp,8
ffffffffc0203bb0:	7b9c                	ld	a5,48(a5)
ffffffffc0203bb2:	854a                	mv	a0,s2
ffffffffc0203bb4:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203bb6:	e12d                	bnez	a0,ffffffffc0203c18 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203bb8:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203bba:	01893503          	ld	a0,24(s2)
ffffffffc0203bbe:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203bc0:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203bc2:	85a6                	mv	a1,s1
ffffffffc0203bc4:	ba8fe0ef          	jal	ra,ffffffffc0201f6c <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203bc8:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203bca:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203bcc:	8b85                	andi	a5,a5,1
ffffffffc0203bce:	cfb9                	beqz	a5,ffffffffc0203c2c <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203bd0:	65a2                	ld	a1,8(sp)
ffffffffc0203bd2:	7d9c                	ld	a5,56(a1)
ffffffffc0203bd4:	83b1                	srli	a5,a5,0xc
ffffffffc0203bd6:	00178513          	addi	a0,a5,1
ffffffffc0203bda:	0522                	slli	a0,a0,0x8
ffffffffc0203bdc:	155010ef          	jal	ra,ffffffffc0205530 <swapfs_write>
ffffffffc0203be0:	d949                	beqz	a0,ffffffffc0203b72 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203be2:	855e                	mv	a0,s7
ffffffffc0203be4:	daefc0ef          	jal	ra,ffffffffc0200192 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203be8:	0009b783          	ld	a5,0(s3)
ffffffffc0203bec:	6622                	ld	a2,8(sp)
ffffffffc0203bee:	4681                	li	a3,0
ffffffffc0203bf0:	739c                	ld	a5,32(a5)
ffffffffc0203bf2:	85a6                	mv	a1,s1
ffffffffc0203bf4:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203bf6:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203bf8:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203bfa:	fa8a17e3          	bne	s4,s0,ffffffffc0203ba8 <swap_out+0x70>
}
ffffffffc0203bfe:	8522                	mv	a0,s0
ffffffffc0203c00:	60e6                	ld	ra,88(sp)
ffffffffc0203c02:	6446                	ld	s0,80(sp)
ffffffffc0203c04:	64a6                	ld	s1,72(sp)
ffffffffc0203c06:	6906                	ld	s2,64(sp)
ffffffffc0203c08:	79e2                	ld	s3,56(sp)
ffffffffc0203c0a:	7a42                	ld	s4,48(sp)
ffffffffc0203c0c:	7aa2                	ld	s5,40(sp)
ffffffffc0203c0e:	7b02                	ld	s6,32(sp)
ffffffffc0203c10:	6be2                	ld	s7,24(sp)
ffffffffc0203c12:	6c42                	ld	s8,16(sp)
ffffffffc0203c14:	6125                	addi	sp,sp,96
ffffffffc0203c16:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203c18:	85a2                	mv	a1,s0
ffffffffc0203c1a:	00005517          	auipc	a0,0x5
ffffffffc0203c1e:	09650513          	addi	a0,a0,150 # ffffffffc0208cb0 <default_pmm_manager+0xa28>
ffffffffc0203c22:	d70fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
                  break;
ffffffffc0203c26:	bfe1                	j	ffffffffc0203bfe <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203c28:	4401                	li	s0,0
ffffffffc0203c2a:	bfd1                	j	ffffffffc0203bfe <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c2c:	00005697          	auipc	a3,0x5
ffffffffc0203c30:	0b468693          	addi	a3,a3,180 # ffffffffc0208ce0 <default_pmm_manager+0xa58>
ffffffffc0203c34:	00004617          	auipc	a2,0x4
ffffffffc0203c38:	f0c60613          	addi	a2,a2,-244 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203c3c:	06800593          	li	a1,104
ffffffffc0203c40:	00005517          	auipc	a0,0x5
ffffffffc0203c44:	de850513          	addi	a0,a0,-536 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc0203c48:	841fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0203c4c <swap_in>:
{
ffffffffc0203c4c:	7179                	addi	sp,sp,-48
ffffffffc0203c4e:	e84a                	sd	s2,16(sp)
ffffffffc0203c50:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203c52:	4505                	li	a0,1
{
ffffffffc0203c54:	ec26                	sd	s1,24(sp)
ffffffffc0203c56:	e44e                	sd	s3,8(sp)
ffffffffc0203c58:	f406                	sd	ra,40(sp)
ffffffffc0203c5a:	f022                	sd	s0,32(sp)
ffffffffc0203c5c:	84ae                	mv	s1,a1
ffffffffc0203c5e:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203c60:	9fefe0ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
     assert(result!=NULL);
ffffffffc0203c64:	c129                	beqz	a0,ffffffffc0203ca6 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203c66:	842a                	mv	s0,a0
ffffffffc0203c68:	01893503          	ld	a0,24(s2)
ffffffffc0203c6c:	4601                	li	a2,0
ffffffffc0203c6e:	85a6                	mv	a1,s1
ffffffffc0203c70:	afcfe0ef          	jal	ra,ffffffffc0201f6c <get_pte>
ffffffffc0203c74:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203c76:	6108                	ld	a0,0(a0)
ffffffffc0203c78:	85a2                	mv	a1,s0
ffffffffc0203c7a:	01f010ef          	jal	ra,ffffffffc0205498 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203c7e:	00093583          	ld	a1,0(s2)
ffffffffc0203c82:	8626                	mv	a2,s1
ffffffffc0203c84:	00005517          	auipc	a0,0x5
ffffffffc0203c88:	d4450513          	addi	a0,a0,-700 # ffffffffc02089c8 <default_pmm_manager+0x740>
ffffffffc0203c8c:	81a1                	srli	a1,a1,0x8
ffffffffc0203c8e:	d04fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
}
ffffffffc0203c92:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203c94:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203c98:	7402                	ld	s0,32(sp)
ffffffffc0203c9a:	64e2                	ld	s1,24(sp)
ffffffffc0203c9c:	6942                	ld	s2,16(sp)
ffffffffc0203c9e:	69a2                	ld	s3,8(sp)
ffffffffc0203ca0:	4501                	li	a0,0
ffffffffc0203ca2:	6145                	addi	sp,sp,48
ffffffffc0203ca4:	8082                	ret
     assert(result!=NULL);
ffffffffc0203ca6:	00005697          	auipc	a3,0x5
ffffffffc0203caa:	d1268693          	addi	a3,a3,-750 # ffffffffc02089b8 <default_pmm_manager+0x730>
ffffffffc0203cae:	00004617          	auipc	a2,0x4
ffffffffc0203cb2:	e9260613          	addi	a2,a2,-366 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203cb6:	07e00593          	li	a1,126
ffffffffc0203cba:	00005517          	auipc	a0,0x5
ffffffffc0203cbe:	d6e50513          	addi	a0,a0,-658 # ffffffffc0208a28 <default_pmm_manager+0x7a0>
ffffffffc0203cc2:	fc6fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0203cc6 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203cc6:	000db797          	auipc	a5,0xdb
ffffffffc0203cca:	7d278793          	addi	a5,a5,2002 # ffffffffc02df498 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203cce:	f51c                	sd	a5,40(a0)
ffffffffc0203cd0:	e79c                	sd	a5,8(a5)
ffffffffc0203cd2:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203cd4:	4501                	li	a0,0
ffffffffc0203cd6:	8082                	ret

ffffffffc0203cd8 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203cd8:	4501                	li	a0,0
ffffffffc0203cda:	8082                	ret

ffffffffc0203cdc <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203cdc:	4501                	li	a0,0
ffffffffc0203cde:	8082                	ret

ffffffffc0203ce0 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203ce0:	4501                	li	a0,0
ffffffffc0203ce2:	8082                	ret

ffffffffc0203ce4 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203ce4:	711d                	addi	sp,sp,-96
ffffffffc0203ce6:	fc4e                	sd	s3,56(sp)
ffffffffc0203ce8:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203cea:	00005517          	auipc	a0,0x5
ffffffffc0203cee:	06650513          	addi	a0,a0,102 # ffffffffc0208d50 <default_pmm_manager+0xac8>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203cf2:	698d                	lui	s3,0x3
ffffffffc0203cf4:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203cf6:	e8a2                	sd	s0,80(sp)
ffffffffc0203cf8:	e4a6                	sd	s1,72(sp)
ffffffffc0203cfa:	ec86                	sd	ra,88(sp)
ffffffffc0203cfc:	e0ca                	sd	s2,64(sp)
ffffffffc0203cfe:	f456                	sd	s5,40(sp)
ffffffffc0203d00:	f05a                	sd	s6,32(sp)
ffffffffc0203d02:	ec5e                	sd	s7,24(sp)
ffffffffc0203d04:	e862                	sd	s8,16(sp)
ffffffffc0203d06:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0203d08:	000db417          	auipc	s0,0xdb
ffffffffc0203d0c:	65440413          	addi	s0,s0,1620 # ffffffffc02df35c <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203d10:	c82fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203d14:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6ad8>
    assert(pgfault_num==4);
ffffffffc0203d18:	4004                	lw	s1,0(s0)
ffffffffc0203d1a:	4791                	li	a5,4
ffffffffc0203d1c:	2481                	sext.w	s1,s1
ffffffffc0203d1e:	14f49963          	bne	s1,a5,ffffffffc0203e70 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d22:	00005517          	auipc	a0,0x5
ffffffffc0203d26:	06e50513          	addi	a0,a0,110 # ffffffffc0208d90 <default_pmm_manager+0xb08>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d2a:	6a85                	lui	s5,0x1
ffffffffc0203d2c:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d2e:	c64fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d32:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8ad8>
    assert(pgfault_num==4);
ffffffffc0203d36:	00042903          	lw	s2,0(s0)
ffffffffc0203d3a:	2901                	sext.w	s2,s2
ffffffffc0203d3c:	2a991a63          	bne	s2,s1,ffffffffc0203ff0 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d40:	00005517          	auipc	a0,0x5
ffffffffc0203d44:	07850513          	addi	a0,a0,120 # ffffffffc0208db8 <default_pmm_manager+0xb30>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d48:	6b91                	lui	s7,0x4
ffffffffc0203d4a:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d4c:	c46fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d50:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5ad8>
    assert(pgfault_num==4);
ffffffffc0203d54:	4004                	lw	s1,0(s0)
ffffffffc0203d56:	2481                	sext.w	s1,s1
ffffffffc0203d58:	27249c63          	bne	s1,s2,ffffffffc0203fd0 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d5c:	00005517          	auipc	a0,0x5
ffffffffc0203d60:	08450513          	addi	a0,a0,132 # ffffffffc0208de0 <default_pmm_manager+0xb58>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d64:	6909                	lui	s2,0x2
ffffffffc0203d66:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d68:	c2afc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d6c:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x7ad8>
    assert(pgfault_num==4);
ffffffffc0203d70:	401c                	lw	a5,0(s0)
ffffffffc0203d72:	2781                	sext.w	a5,a5
ffffffffc0203d74:	22979e63          	bne	a5,s1,ffffffffc0203fb0 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203d78:	00005517          	auipc	a0,0x5
ffffffffc0203d7c:	09050513          	addi	a0,a0,144 # ffffffffc0208e08 <default_pmm_manager+0xb80>
ffffffffc0203d80:	c12fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203d84:	6795                	lui	a5,0x5
ffffffffc0203d86:	4739                	li	a4,14
ffffffffc0203d88:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4ad8>
    assert(pgfault_num==5);
ffffffffc0203d8c:	4004                	lw	s1,0(s0)
ffffffffc0203d8e:	4795                	li	a5,5
ffffffffc0203d90:	2481                	sext.w	s1,s1
ffffffffc0203d92:	1ef49f63          	bne	s1,a5,ffffffffc0203f90 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d96:	00005517          	auipc	a0,0x5
ffffffffc0203d9a:	04a50513          	addi	a0,a0,74 # ffffffffc0208de0 <default_pmm_manager+0xb58>
ffffffffc0203d9e:	bf4fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203da2:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203da6:	401c                	lw	a5,0(s0)
ffffffffc0203da8:	2781                	sext.w	a5,a5
ffffffffc0203daa:	1c979363          	bne	a5,s1,ffffffffc0203f70 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203dae:	00005517          	auipc	a0,0x5
ffffffffc0203db2:	fe250513          	addi	a0,a0,-30 # ffffffffc0208d90 <default_pmm_manager+0xb08>
ffffffffc0203db6:	bdcfc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203dba:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203dbe:	401c                	lw	a5,0(s0)
ffffffffc0203dc0:	4719                	li	a4,6
ffffffffc0203dc2:	2781                	sext.w	a5,a5
ffffffffc0203dc4:	18e79663          	bne	a5,a4,ffffffffc0203f50 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203dc8:	00005517          	auipc	a0,0x5
ffffffffc0203dcc:	01850513          	addi	a0,a0,24 # ffffffffc0208de0 <default_pmm_manager+0xb58>
ffffffffc0203dd0:	bc2fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203dd4:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203dd8:	401c                	lw	a5,0(s0)
ffffffffc0203dda:	471d                	li	a4,7
ffffffffc0203ddc:	2781                	sext.w	a5,a5
ffffffffc0203dde:	14e79963          	bne	a5,a4,ffffffffc0203f30 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203de2:	00005517          	auipc	a0,0x5
ffffffffc0203de6:	f6e50513          	addi	a0,a0,-146 # ffffffffc0208d50 <default_pmm_manager+0xac8>
ffffffffc0203dea:	ba8fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203dee:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203df2:	401c                	lw	a5,0(s0)
ffffffffc0203df4:	4721                	li	a4,8
ffffffffc0203df6:	2781                	sext.w	a5,a5
ffffffffc0203df8:	10e79c63          	bne	a5,a4,ffffffffc0203f10 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203dfc:	00005517          	auipc	a0,0x5
ffffffffc0203e00:	fbc50513          	addi	a0,a0,-68 # ffffffffc0208db8 <default_pmm_manager+0xb30>
ffffffffc0203e04:	b8efc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203e08:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203e0c:	401c                	lw	a5,0(s0)
ffffffffc0203e0e:	4725                	li	a4,9
ffffffffc0203e10:	2781                	sext.w	a5,a5
ffffffffc0203e12:	0ce79f63          	bne	a5,a4,ffffffffc0203ef0 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203e16:	00005517          	auipc	a0,0x5
ffffffffc0203e1a:	ff250513          	addi	a0,a0,-14 # ffffffffc0208e08 <default_pmm_manager+0xb80>
ffffffffc0203e1e:	b74fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203e22:	6795                	lui	a5,0x5
ffffffffc0203e24:	4739                	li	a4,14
ffffffffc0203e26:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4ad8>
    assert(pgfault_num==10);
ffffffffc0203e2a:	4004                	lw	s1,0(s0)
ffffffffc0203e2c:	47a9                	li	a5,10
ffffffffc0203e2e:	2481                	sext.w	s1,s1
ffffffffc0203e30:	0af49063          	bne	s1,a5,ffffffffc0203ed0 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203e34:	00005517          	auipc	a0,0x5
ffffffffc0203e38:	f5c50513          	addi	a0,a0,-164 # ffffffffc0208d90 <default_pmm_manager+0xb08>
ffffffffc0203e3c:	b56fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203e40:	6785                	lui	a5,0x1
ffffffffc0203e42:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8ad8>
ffffffffc0203e46:	06979563          	bne	a5,s1,ffffffffc0203eb0 <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0203e4a:	401c                	lw	a5,0(s0)
ffffffffc0203e4c:	472d                	li	a4,11
ffffffffc0203e4e:	2781                	sext.w	a5,a5
ffffffffc0203e50:	04e79063          	bne	a5,a4,ffffffffc0203e90 <_fifo_check_swap+0x1ac>
}
ffffffffc0203e54:	60e6                	ld	ra,88(sp)
ffffffffc0203e56:	6446                	ld	s0,80(sp)
ffffffffc0203e58:	64a6                	ld	s1,72(sp)
ffffffffc0203e5a:	6906                	ld	s2,64(sp)
ffffffffc0203e5c:	79e2                	ld	s3,56(sp)
ffffffffc0203e5e:	7a42                	ld	s4,48(sp)
ffffffffc0203e60:	7aa2                	ld	s5,40(sp)
ffffffffc0203e62:	7b02                	ld	s6,32(sp)
ffffffffc0203e64:	6be2                	ld	s7,24(sp)
ffffffffc0203e66:	6c42                	ld	s8,16(sp)
ffffffffc0203e68:	6ca2                	ld	s9,8(sp)
ffffffffc0203e6a:	4501                	li	a0,0
ffffffffc0203e6c:	6125                	addi	sp,sp,96
ffffffffc0203e6e:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203e70:	00005697          	auipc	a3,0x5
ffffffffc0203e74:	d8068693          	addi	a3,a3,-640 # ffffffffc0208bf0 <default_pmm_manager+0x968>
ffffffffc0203e78:	00004617          	auipc	a2,0x4
ffffffffc0203e7c:	cc860613          	addi	a2,a2,-824 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203e80:	05100593          	li	a1,81
ffffffffc0203e84:	00005517          	auipc	a0,0x5
ffffffffc0203e88:	ef450513          	addi	a0,a0,-268 # ffffffffc0208d78 <default_pmm_manager+0xaf0>
ffffffffc0203e8c:	dfcfc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==11);
ffffffffc0203e90:	00005697          	auipc	a3,0x5
ffffffffc0203e94:	02868693          	addi	a3,a3,40 # ffffffffc0208eb8 <default_pmm_manager+0xc30>
ffffffffc0203e98:	00004617          	auipc	a2,0x4
ffffffffc0203e9c:	ca860613          	addi	a2,a2,-856 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203ea0:	07300593          	li	a1,115
ffffffffc0203ea4:	00005517          	auipc	a0,0x5
ffffffffc0203ea8:	ed450513          	addi	a0,a0,-300 # ffffffffc0208d78 <default_pmm_manager+0xaf0>
ffffffffc0203eac:	ddcfc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203eb0:	00005697          	auipc	a3,0x5
ffffffffc0203eb4:	fe068693          	addi	a3,a3,-32 # ffffffffc0208e90 <default_pmm_manager+0xc08>
ffffffffc0203eb8:	00004617          	auipc	a2,0x4
ffffffffc0203ebc:	c8860613          	addi	a2,a2,-888 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203ec0:	07100593          	li	a1,113
ffffffffc0203ec4:	00005517          	auipc	a0,0x5
ffffffffc0203ec8:	eb450513          	addi	a0,a0,-332 # ffffffffc0208d78 <default_pmm_manager+0xaf0>
ffffffffc0203ecc:	dbcfc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==10);
ffffffffc0203ed0:	00005697          	auipc	a3,0x5
ffffffffc0203ed4:	fb068693          	addi	a3,a3,-80 # ffffffffc0208e80 <default_pmm_manager+0xbf8>
ffffffffc0203ed8:	00004617          	auipc	a2,0x4
ffffffffc0203edc:	c6860613          	addi	a2,a2,-920 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203ee0:	06f00593          	li	a1,111
ffffffffc0203ee4:	00005517          	auipc	a0,0x5
ffffffffc0203ee8:	e9450513          	addi	a0,a0,-364 # ffffffffc0208d78 <default_pmm_manager+0xaf0>
ffffffffc0203eec:	d9cfc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==9);
ffffffffc0203ef0:	00005697          	auipc	a3,0x5
ffffffffc0203ef4:	f8068693          	addi	a3,a3,-128 # ffffffffc0208e70 <default_pmm_manager+0xbe8>
ffffffffc0203ef8:	00004617          	auipc	a2,0x4
ffffffffc0203efc:	c4860613          	addi	a2,a2,-952 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203f00:	06c00593          	li	a1,108
ffffffffc0203f04:	00005517          	auipc	a0,0x5
ffffffffc0203f08:	e7450513          	addi	a0,a0,-396 # ffffffffc0208d78 <default_pmm_manager+0xaf0>
ffffffffc0203f0c:	d7cfc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==8);
ffffffffc0203f10:	00005697          	auipc	a3,0x5
ffffffffc0203f14:	f5068693          	addi	a3,a3,-176 # ffffffffc0208e60 <default_pmm_manager+0xbd8>
ffffffffc0203f18:	00004617          	auipc	a2,0x4
ffffffffc0203f1c:	c2860613          	addi	a2,a2,-984 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203f20:	06900593          	li	a1,105
ffffffffc0203f24:	00005517          	auipc	a0,0x5
ffffffffc0203f28:	e5450513          	addi	a0,a0,-428 # ffffffffc0208d78 <default_pmm_manager+0xaf0>
ffffffffc0203f2c:	d5cfc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==7);
ffffffffc0203f30:	00005697          	auipc	a3,0x5
ffffffffc0203f34:	f2068693          	addi	a3,a3,-224 # ffffffffc0208e50 <default_pmm_manager+0xbc8>
ffffffffc0203f38:	00004617          	auipc	a2,0x4
ffffffffc0203f3c:	c0860613          	addi	a2,a2,-1016 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203f40:	06600593          	li	a1,102
ffffffffc0203f44:	00005517          	auipc	a0,0x5
ffffffffc0203f48:	e3450513          	addi	a0,a0,-460 # ffffffffc0208d78 <default_pmm_manager+0xaf0>
ffffffffc0203f4c:	d3cfc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==6);
ffffffffc0203f50:	00005697          	auipc	a3,0x5
ffffffffc0203f54:	ef068693          	addi	a3,a3,-272 # ffffffffc0208e40 <default_pmm_manager+0xbb8>
ffffffffc0203f58:	00004617          	auipc	a2,0x4
ffffffffc0203f5c:	be860613          	addi	a2,a2,-1048 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203f60:	06300593          	li	a1,99
ffffffffc0203f64:	00005517          	auipc	a0,0x5
ffffffffc0203f68:	e1450513          	addi	a0,a0,-492 # ffffffffc0208d78 <default_pmm_manager+0xaf0>
ffffffffc0203f6c:	d1cfc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==5);
ffffffffc0203f70:	00005697          	auipc	a3,0x5
ffffffffc0203f74:	ec068693          	addi	a3,a3,-320 # ffffffffc0208e30 <default_pmm_manager+0xba8>
ffffffffc0203f78:	00004617          	auipc	a2,0x4
ffffffffc0203f7c:	bc860613          	addi	a2,a2,-1080 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203f80:	06000593          	li	a1,96
ffffffffc0203f84:	00005517          	auipc	a0,0x5
ffffffffc0203f88:	df450513          	addi	a0,a0,-524 # ffffffffc0208d78 <default_pmm_manager+0xaf0>
ffffffffc0203f8c:	cfcfc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==5);
ffffffffc0203f90:	00005697          	auipc	a3,0x5
ffffffffc0203f94:	ea068693          	addi	a3,a3,-352 # ffffffffc0208e30 <default_pmm_manager+0xba8>
ffffffffc0203f98:	00004617          	auipc	a2,0x4
ffffffffc0203f9c:	ba860613          	addi	a2,a2,-1112 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203fa0:	05d00593          	li	a1,93
ffffffffc0203fa4:	00005517          	auipc	a0,0x5
ffffffffc0203fa8:	dd450513          	addi	a0,a0,-556 # ffffffffc0208d78 <default_pmm_manager+0xaf0>
ffffffffc0203fac:	cdcfc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==4);
ffffffffc0203fb0:	00005697          	auipc	a3,0x5
ffffffffc0203fb4:	c4068693          	addi	a3,a3,-960 # ffffffffc0208bf0 <default_pmm_manager+0x968>
ffffffffc0203fb8:	00004617          	auipc	a2,0x4
ffffffffc0203fbc:	b8860613          	addi	a2,a2,-1144 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203fc0:	05a00593          	li	a1,90
ffffffffc0203fc4:	00005517          	auipc	a0,0x5
ffffffffc0203fc8:	db450513          	addi	a0,a0,-588 # ffffffffc0208d78 <default_pmm_manager+0xaf0>
ffffffffc0203fcc:	cbcfc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==4);
ffffffffc0203fd0:	00005697          	auipc	a3,0x5
ffffffffc0203fd4:	c2068693          	addi	a3,a3,-992 # ffffffffc0208bf0 <default_pmm_manager+0x968>
ffffffffc0203fd8:	00004617          	auipc	a2,0x4
ffffffffc0203fdc:	b6860613          	addi	a2,a2,-1176 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0203fe0:	05700593          	li	a1,87
ffffffffc0203fe4:	00005517          	auipc	a0,0x5
ffffffffc0203fe8:	d9450513          	addi	a0,a0,-620 # ffffffffc0208d78 <default_pmm_manager+0xaf0>
ffffffffc0203fec:	c9cfc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==4);
ffffffffc0203ff0:	00005697          	auipc	a3,0x5
ffffffffc0203ff4:	c0068693          	addi	a3,a3,-1024 # ffffffffc0208bf0 <default_pmm_manager+0x968>
ffffffffc0203ff8:	00004617          	auipc	a2,0x4
ffffffffc0203ffc:	b4860613          	addi	a2,a2,-1208 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0204000:	05400593          	li	a1,84
ffffffffc0204004:	00005517          	auipc	a0,0x5
ffffffffc0204008:	d7450513          	addi	a0,a0,-652 # ffffffffc0208d78 <default_pmm_manager+0xaf0>
ffffffffc020400c:	c7cfc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204010 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0204010:	751c                	ld	a5,40(a0)
{
ffffffffc0204012:	1141                	addi	sp,sp,-16
ffffffffc0204014:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0204016:	cf91                	beqz	a5,ffffffffc0204032 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0204018:	ee0d                	bnez	a2,ffffffffc0204052 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc020401a:	679c                	ld	a5,8(a5)
}
ffffffffc020401c:	60a2                	ld	ra,8(sp)
ffffffffc020401e:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0204020:	6394                	ld	a3,0(a5)
ffffffffc0204022:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0204024:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0204028:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020402a:	e314                	sd	a3,0(a4)
ffffffffc020402c:	e19c                	sd	a5,0(a1)
}
ffffffffc020402e:	0141                	addi	sp,sp,16
ffffffffc0204030:	8082                	ret
         assert(head != NULL);
ffffffffc0204032:	00005697          	auipc	a3,0x5
ffffffffc0204036:	eb668693          	addi	a3,a3,-330 # ffffffffc0208ee8 <default_pmm_manager+0xc60>
ffffffffc020403a:	00004617          	auipc	a2,0x4
ffffffffc020403e:	b0660613          	addi	a2,a2,-1274 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0204042:	04100593          	li	a1,65
ffffffffc0204046:	00005517          	auipc	a0,0x5
ffffffffc020404a:	d3250513          	addi	a0,a0,-718 # ffffffffc0208d78 <default_pmm_manager+0xaf0>
ffffffffc020404e:	c3afc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(in_tick==0);
ffffffffc0204052:	00005697          	auipc	a3,0x5
ffffffffc0204056:	ea668693          	addi	a3,a3,-346 # ffffffffc0208ef8 <default_pmm_manager+0xc70>
ffffffffc020405a:	00004617          	auipc	a2,0x4
ffffffffc020405e:	ae660613          	addi	a2,a2,-1306 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0204062:	04200593          	li	a1,66
ffffffffc0204066:	00005517          	auipc	a0,0x5
ffffffffc020406a:	d1250513          	addi	a0,a0,-750 # ffffffffc0208d78 <default_pmm_manager+0xaf0>
ffffffffc020406e:	c1afc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204072 <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0204072:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0204076:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0204078:	cb09                	beqz	a4,ffffffffc020408a <_fifo_map_swappable+0x18>
ffffffffc020407a:	cb81                	beqz	a5,ffffffffc020408a <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020407c:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc020407e:	e398                	sd	a4,0(a5)
}
ffffffffc0204080:	4501                	li	a0,0
ffffffffc0204082:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0204084:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0204086:	f614                	sd	a3,40(a2)
ffffffffc0204088:	8082                	ret
{
ffffffffc020408a:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc020408c:	00005697          	auipc	a3,0x5
ffffffffc0204090:	e3c68693          	addi	a3,a3,-452 # ffffffffc0208ec8 <default_pmm_manager+0xc40>
ffffffffc0204094:	00004617          	auipc	a2,0x4
ffffffffc0204098:	aac60613          	addi	a2,a2,-1364 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020409c:	03200593          	li	a1,50
ffffffffc02040a0:	00005517          	auipc	a0,0x5
ffffffffc02040a4:	cd850513          	addi	a0,a0,-808 # ffffffffc0208d78 <default_pmm_manager+0xaf0>
{
ffffffffc02040a8:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc02040aa:	bdefc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02040ae <check_vma_overlap.isra.2.part.3>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02040ae:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02040b0:	00005697          	auipc	a3,0x5
ffffffffc02040b4:	e7068693          	addi	a3,a3,-400 # ffffffffc0208f20 <default_pmm_manager+0xc98>
ffffffffc02040b8:	00004617          	auipc	a2,0x4
ffffffffc02040bc:	a8860613          	addi	a2,a2,-1400 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02040c0:	06d00593          	li	a1,109
ffffffffc02040c4:	00005517          	auipc	a0,0x5
ffffffffc02040c8:	e7c50513          	addi	a0,a0,-388 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02040cc:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02040ce:	bbafc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02040d2 <mm_create>:
mm_create(void) {
ffffffffc02040d2:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02040d4:	05800513          	li	a0,88
mm_create(void) {
ffffffffc02040d8:	e022                	sd	s0,0(sp)
ffffffffc02040da:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02040dc:	b87fd0ef          	jal	ra,ffffffffc0201c62 <kmalloc>
ffffffffc02040e0:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02040e2:	c90d                	beqz	a0,ffffffffc0204114 <mm_create+0x42>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02040e4:	000db797          	auipc	a5,0xdb
ffffffffc02040e8:	27478793          	addi	a5,a5,628 # ffffffffc02df358 <swap_init_ok>
ffffffffc02040ec:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc02040ee:	e408                	sd	a0,8(s0)
ffffffffc02040f0:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02040f2:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02040f6:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02040fa:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02040fe:	2781                	sext.w	a5,a5
ffffffffc0204100:	ef99                	bnez	a5,ffffffffc020411e <mm_create+0x4c>
        else mm->sm_priv = NULL;
ffffffffc0204102:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc0204106:	02042823          	sw	zero,48(s0)
        sem_init(&(mm->mm_sem), 1);
ffffffffc020410a:	4585                	li	a1,1
ffffffffc020410c:	03840513          	addi	a0,s0,56
ffffffffc0204110:	228010ef          	jal	ra,ffffffffc0205338 <sem_init>
}
ffffffffc0204114:	8522                	mv	a0,s0
ffffffffc0204116:	60a2                	ld	ra,8(sp)
ffffffffc0204118:	6402                	ld	s0,0(sp)
ffffffffc020411a:	0141                	addi	sp,sp,16
ffffffffc020411c:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020411e:	9fbff0ef          	jal	ra,ffffffffc0203b18 <swap_init_mm>
ffffffffc0204122:	b7d5                	j	ffffffffc0204106 <mm_create+0x34>

ffffffffc0204124 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0204124:	1101                	addi	sp,sp,-32
ffffffffc0204126:	e04a                	sd	s2,0(sp)
ffffffffc0204128:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020412a:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020412e:	e822                	sd	s0,16(sp)
ffffffffc0204130:	e426                	sd	s1,8(sp)
ffffffffc0204132:	ec06                	sd	ra,24(sp)
ffffffffc0204134:	84ae                	mv	s1,a1
ffffffffc0204136:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204138:	b2bfd0ef          	jal	ra,ffffffffc0201c62 <kmalloc>
    if (vma != NULL) {
ffffffffc020413c:	c509                	beqz	a0,ffffffffc0204146 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020413e:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204142:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204144:	cd00                	sw	s0,24(a0)
}
ffffffffc0204146:	60e2                	ld	ra,24(sp)
ffffffffc0204148:	6442                	ld	s0,16(sp)
ffffffffc020414a:	64a2                	ld	s1,8(sp)
ffffffffc020414c:	6902                	ld	s2,0(sp)
ffffffffc020414e:	6105                	addi	sp,sp,32
ffffffffc0204150:	8082                	ret

ffffffffc0204152 <find_vma>:
    if (mm != NULL) {
ffffffffc0204152:	c51d                	beqz	a0,ffffffffc0204180 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0204154:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204156:	c781                	beqz	a5,ffffffffc020415e <find_vma+0xc>
ffffffffc0204158:	6798                	ld	a4,8(a5)
ffffffffc020415a:	02e5f663          	bleu	a4,a1,ffffffffc0204186 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc020415e:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc0204160:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0204162:	00f50f63          	beq	a0,a5,ffffffffc0204180 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0204166:	fe87b703          	ld	a4,-24(a5)
ffffffffc020416a:	fee5ebe3          	bltu	a1,a4,ffffffffc0204160 <find_vma+0xe>
ffffffffc020416e:	ff07b703          	ld	a4,-16(a5)
ffffffffc0204172:	fee5f7e3          	bleu	a4,a1,ffffffffc0204160 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0204176:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0204178:	c781                	beqz	a5,ffffffffc0204180 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc020417a:	e91c                	sd	a5,16(a0)
}
ffffffffc020417c:	853e                	mv	a0,a5
ffffffffc020417e:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0204180:	4781                	li	a5,0
}
ffffffffc0204182:	853e                	mv	a0,a5
ffffffffc0204184:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204186:	6b98                	ld	a4,16(a5)
ffffffffc0204188:	fce5fbe3          	bleu	a4,a1,ffffffffc020415e <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc020418c:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc020418e:	b7fd                	j	ffffffffc020417c <find_vma+0x2a>

ffffffffc0204190 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0204190:	6590                	ld	a2,8(a1)
ffffffffc0204192:	0105b803          	ld	a6,16(a1) # 1010 <_binary_obj___user_faultread_out_size-0x8ac8>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0204196:	1141                	addi	sp,sp,-16
ffffffffc0204198:	e406                	sd	ra,8(sp)
ffffffffc020419a:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020419c:	01066863          	bltu	a2,a6,ffffffffc02041ac <insert_vma_struct+0x1c>
ffffffffc02041a0:	a8b9                	j	ffffffffc02041fe <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02041a2:	fe87b683          	ld	a3,-24(a5)
ffffffffc02041a6:	04d66763          	bltu	a2,a3,ffffffffc02041f4 <insert_vma_struct+0x64>
ffffffffc02041aa:	873e                	mv	a4,a5
ffffffffc02041ac:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc02041ae:	fef51ae3          	bne	a0,a5,ffffffffc02041a2 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02041b2:	02a70463          	beq	a4,a0,ffffffffc02041da <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02041b6:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02041ba:	fe873883          	ld	a7,-24(a4)
ffffffffc02041be:	08d8f063          	bleu	a3,a7,ffffffffc020423e <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041c2:	04d66e63          	bltu	a2,a3,ffffffffc020421e <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc02041c6:	00f50a63          	beq	a0,a5,ffffffffc02041da <insert_vma_struct+0x4a>
ffffffffc02041ca:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041ce:	0506e863          	bltu	a3,a6,ffffffffc020421e <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02041d2:	ff07b603          	ld	a2,-16(a5)
ffffffffc02041d6:	02c6f263          	bleu	a2,a3,ffffffffc02041fa <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02041da:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc02041dc:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02041de:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02041e2:	e390                	sd	a2,0(a5)
ffffffffc02041e4:	e710                	sd	a2,8(a4)
}
ffffffffc02041e6:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02041e8:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02041ea:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc02041ec:	2685                	addiw	a3,a3,1
ffffffffc02041ee:	d114                	sw	a3,32(a0)
}
ffffffffc02041f0:	0141                	addi	sp,sp,16
ffffffffc02041f2:	8082                	ret
    if (le_prev != list) {
ffffffffc02041f4:	fca711e3          	bne	a4,a0,ffffffffc02041b6 <insert_vma_struct+0x26>
ffffffffc02041f8:	bfd9                	j	ffffffffc02041ce <insert_vma_struct+0x3e>
ffffffffc02041fa:	eb5ff0ef          	jal	ra,ffffffffc02040ae <check_vma_overlap.isra.2.part.3>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02041fe:	00005697          	auipc	a3,0x5
ffffffffc0204202:	e5268693          	addi	a3,a3,-430 # ffffffffc0209050 <default_pmm_manager+0xdc8>
ffffffffc0204206:	00004617          	auipc	a2,0x4
ffffffffc020420a:	93a60613          	addi	a2,a2,-1734 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020420e:	07400593          	li	a1,116
ffffffffc0204212:	00005517          	auipc	a0,0x5
ffffffffc0204216:	d2e50513          	addi	a0,a0,-722 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc020421a:	a6efc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020421e:	00005697          	auipc	a3,0x5
ffffffffc0204222:	e7268693          	addi	a3,a3,-398 # ffffffffc0209090 <default_pmm_manager+0xe08>
ffffffffc0204226:	00004617          	auipc	a2,0x4
ffffffffc020422a:	91a60613          	addi	a2,a2,-1766 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020422e:	06c00593          	li	a1,108
ffffffffc0204232:	00005517          	auipc	a0,0x5
ffffffffc0204236:	d0e50513          	addi	a0,a0,-754 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc020423a:	a4efc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020423e:	00005697          	auipc	a3,0x5
ffffffffc0204242:	e3268693          	addi	a3,a3,-462 # ffffffffc0209070 <default_pmm_manager+0xde8>
ffffffffc0204246:	00004617          	auipc	a2,0x4
ffffffffc020424a:	8fa60613          	addi	a2,a2,-1798 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020424e:	06b00593          	li	a1,107
ffffffffc0204252:	00005517          	auipc	a0,0x5
ffffffffc0204256:	cee50513          	addi	a0,a0,-786 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc020425a:	a2efc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020425e <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc020425e:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0204260:	1141                	addi	sp,sp,-16
ffffffffc0204262:	e406                	sd	ra,8(sp)
ffffffffc0204264:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0204266:	e78d                	bnez	a5,ffffffffc0204290 <mm_destroy+0x32>
ffffffffc0204268:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020426a:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc020426c:	00a40c63          	beq	s0,a0,ffffffffc0204284 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0204270:	6118                	ld	a4,0(a0)
ffffffffc0204272:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0204274:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0204276:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0204278:	e398                	sd	a4,0(a5)
ffffffffc020427a:	aa5fd0ef          	jal	ra,ffffffffc0201d1e <kfree>
    return listelm->next;
ffffffffc020427e:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0204280:	fea418e3          	bne	s0,a0,ffffffffc0204270 <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0204284:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0204286:	6402                	ld	s0,0(sp)
ffffffffc0204288:	60a2                	ld	ra,8(sp)
ffffffffc020428a:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc020428c:	a93fd06f          	j	ffffffffc0201d1e <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0204290:	00005697          	auipc	a3,0x5
ffffffffc0204294:	e2068693          	addi	a3,a3,-480 # ffffffffc02090b0 <default_pmm_manager+0xe28>
ffffffffc0204298:	00004617          	auipc	a2,0x4
ffffffffc020429c:	8a860613          	addi	a2,a2,-1880 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02042a0:	09400593          	li	a1,148
ffffffffc02042a4:	00005517          	auipc	a0,0x5
ffffffffc02042a8:	c9c50513          	addi	a0,a0,-868 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc02042ac:	9dcfc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02042b0 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042b0:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc02042b2:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042b4:	17fd                	addi	a5,a5,-1
ffffffffc02042b6:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc02042b8:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042ba:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc02042be:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042c0:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc02042c2:	fc06                	sd	ra,56(sp)
ffffffffc02042c4:	f04a                	sd	s2,32(sp)
ffffffffc02042c6:	ec4e                	sd	s3,24(sp)
ffffffffc02042c8:	e852                	sd	s4,16(sp)
ffffffffc02042ca:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042cc:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc02042d0:	002007b7          	lui	a5,0x200
ffffffffc02042d4:	01047433          	and	s0,s0,a6
ffffffffc02042d8:	06f4e363          	bltu	s1,a5,ffffffffc020433e <mm_map+0x8e>
ffffffffc02042dc:	0684f163          	bleu	s0,s1,ffffffffc020433e <mm_map+0x8e>
ffffffffc02042e0:	4785                	li	a5,1
ffffffffc02042e2:	07fe                	slli	a5,a5,0x1f
ffffffffc02042e4:	0487ed63          	bltu	a5,s0,ffffffffc020433e <mm_map+0x8e>
ffffffffc02042e8:	89aa                	mv	s3,a0
ffffffffc02042ea:	8a3a                	mv	s4,a4
ffffffffc02042ec:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02042ee:	c931                	beqz	a0,ffffffffc0204342 <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc02042f0:	85a6                	mv	a1,s1
ffffffffc02042f2:	e61ff0ef          	jal	ra,ffffffffc0204152 <find_vma>
ffffffffc02042f6:	c501                	beqz	a0,ffffffffc02042fe <mm_map+0x4e>
ffffffffc02042f8:	651c                	ld	a5,8(a0)
ffffffffc02042fa:	0487e263          	bltu	a5,s0,ffffffffc020433e <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02042fe:	03000513          	li	a0,48
ffffffffc0204302:	961fd0ef          	jal	ra,ffffffffc0201c62 <kmalloc>
ffffffffc0204306:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0204308:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc020430a:	02090163          	beqz	s2,ffffffffc020432c <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc020430e:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc0204310:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0204314:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0204318:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc020431c:	85ca                	mv	a1,s2
ffffffffc020431e:	e73ff0ef          	jal	ra,ffffffffc0204190 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0204322:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc0204324:	000a0463          	beqz	s4,ffffffffc020432c <mm_map+0x7c>
        *vma_store = vma;
ffffffffc0204328:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc020432c:	70e2                	ld	ra,56(sp)
ffffffffc020432e:	7442                	ld	s0,48(sp)
ffffffffc0204330:	74a2                	ld	s1,40(sp)
ffffffffc0204332:	7902                	ld	s2,32(sp)
ffffffffc0204334:	69e2                	ld	s3,24(sp)
ffffffffc0204336:	6a42                	ld	s4,16(sp)
ffffffffc0204338:	6aa2                	ld	s5,8(sp)
ffffffffc020433a:	6121                	addi	sp,sp,64
ffffffffc020433c:	8082                	ret
        return -E_INVAL;
ffffffffc020433e:	5575                	li	a0,-3
ffffffffc0204340:	b7f5                	j	ffffffffc020432c <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc0204342:	00004697          	auipc	a3,0x4
ffffffffc0204346:	73668693          	addi	a3,a3,1846 # ffffffffc0208a78 <default_pmm_manager+0x7f0>
ffffffffc020434a:	00003617          	auipc	a2,0x3
ffffffffc020434e:	7f660613          	addi	a2,a2,2038 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0204352:	0a700593          	li	a1,167
ffffffffc0204356:	00005517          	auipc	a0,0x5
ffffffffc020435a:	bea50513          	addi	a0,a0,-1046 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc020435e:	92afc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204362 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0204362:	7139                	addi	sp,sp,-64
ffffffffc0204364:	fc06                	sd	ra,56(sp)
ffffffffc0204366:	f822                	sd	s0,48(sp)
ffffffffc0204368:	f426                	sd	s1,40(sp)
ffffffffc020436a:	f04a                	sd	s2,32(sp)
ffffffffc020436c:	ec4e                	sd	s3,24(sp)
ffffffffc020436e:	e852                	sd	s4,16(sp)
ffffffffc0204370:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0204372:	c535                	beqz	a0,ffffffffc02043de <dup_mmap+0x7c>
ffffffffc0204374:	892a                	mv	s2,a0
ffffffffc0204376:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0204378:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc020437a:	e59d                	bnez	a1,ffffffffc02043a8 <dup_mmap+0x46>
ffffffffc020437c:	a08d                	j	ffffffffc02043de <dup_mmap+0x7c>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc020437e:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc0204380:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_matrix_out_size+0x1f43c8>
        insert_vma_struct(to, nvma);
ffffffffc0204384:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc0204386:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc020438a:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc020438e:	e03ff0ef          	jal	ra,ffffffffc0204190 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc0204392:	ff043683          	ld	a3,-16(s0)
ffffffffc0204396:	fe843603          	ld	a2,-24(s0)
ffffffffc020439a:	6c8c                	ld	a1,24(s1)
ffffffffc020439c:	01893503          	ld	a0,24(s2)
ffffffffc02043a0:	4701                	li	a4,0
ffffffffc02043a2:	d29fe0ef          	jal	ra,ffffffffc02030ca <copy_range>
ffffffffc02043a6:	e105                	bnez	a0,ffffffffc02043c6 <dup_mmap+0x64>
    return listelm->prev;
ffffffffc02043a8:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc02043aa:	02848863          	beq	s1,s0,ffffffffc02043da <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02043ae:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02043b2:	fe843a83          	ld	s5,-24(s0)
ffffffffc02043b6:	ff043a03          	ld	s4,-16(s0)
ffffffffc02043ba:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02043be:	8a5fd0ef          	jal	ra,ffffffffc0201c62 <kmalloc>
ffffffffc02043c2:	87aa                	mv	a5,a0
    if (vma != NULL) {
ffffffffc02043c4:	fd4d                	bnez	a0,ffffffffc020437e <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc02043c6:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02043c8:	70e2                	ld	ra,56(sp)
ffffffffc02043ca:	7442                	ld	s0,48(sp)
ffffffffc02043cc:	74a2                	ld	s1,40(sp)
ffffffffc02043ce:	7902                	ld	s2,32(sp)
ffffffffc02043d0:	69e2                	ld	s3,24(sp)
ffffffffc02043d2:	6a42                	ld	s4,16(sp)
ffffffffc02043d4:	6aa2                	ld	s5,8(sp)
ffffffffc02043d6:	6121                	addi	sp,sp,64
ffffffffc02043d8:	8082                	ret
    return 0;
ffffffffc02043da:	4501                	li	a0,0
ffffffffc02043dc:	b7f5                	j	ffffffffc02043c8 <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc02043de:	00005697          	auipc	a3,0x5
ffffffffc02043e2:	c3268693          	addi	a3,a3,-974 # ffffffffc0209010 <default_pmm_manager+0xd88>
ffffffffc02043e6:	00003617          	auipc	a2,0x3
ffffffffc02043ea:	75a60613          	addi	a2,a2,1882 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02043ee:	0c000593          	li	a1,192
ffffffffc02043f2:	00005517          	auipc	a0,0x5
ffffffffc02043f6:	b4e50513          	addi	a0,a0,-1202 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc02043fa:	88efc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02043fe <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc02043fe:	1101                	addi	sp,sp,-32
ffffffffc0204400:	ec06                	sd	ra,24(sp)
ffffffffc0204402:	e822                	sd	s0,16(sp)
ffffffffc0204404:	e426                	sd	s1,8(sp)
ffffffffc0204406:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204408:	c531                	beqz	a0,ffffffffc0204454 <exit_mmap+0x56>
ffffffffc020440a:	591c                	lw	a5,48(a0)
ffffffffc020440c:	84aa                	mv	s1,a0
ffffffffc020440e:	e3b9                	bnez	a5,ffffffffc0204454 <exit_mmap+0x56>
    return listelm->next;
ffffffffc0204410:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0204412:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0204416:	02850663          	beq	a0,s0,ffffffffc0204442 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020441a:	ff043603          	ld	a2,-16(s0)
ffffffffc020441e:	fe843583          	ld	a1,-24(s0)
ffffffffc0204422:	854a                	mv	a0,s2
ffffffffc0204424:	d7dfd0ef          	jal	ra,ffffffffc02021a0 <unmap_range>
ffffffffc0204428:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc020442a:	fe8498e3          	bne	s1,s0,ffffffffc020441a <exit_mmap+0x1c>
ffffffffc020442e:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc0204430:	00848c63          	beq	s1,s0,ffffffffc0204448 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204434:	ff043603          	ld	a2,-16(s0)
ffffffffc0204438:	fe843583          	ld	a1,-24(s0)
ffffffffc020443c:	854a                	mv	a0,s2
ffffffffc020443e:	e7bfd0ef          	jal	ra,ffffffffc02022b8 <exit_range>
ffffffffc0204442:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204444:	fe8498e3          	bne	s1,s0,ffffffffc0204434 <exit_mmap+0x36>
    }
}
ffffffffc0204448:	60e2                	ld	ra,24(sp)
ffffffffc020444a:	6442                	ld	s0,16(sp)
ffffffffc020444c:	64a2                	ld	s1,8(sp)
ffffffffc020444e:	6902                	ld	s2,0(sp)
ffffffffc0204450:	6105                	addi	sp,sp,32
ffffffffc0204452:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204454:	00005697          	auipc	a3,0x5
ffffffffc0204458:	bdc68693          	addi	a3,a3,-1060 # ffffffffc0209030 <default_pmm_manager+0xda8>
ffffffffc020445c:	00003617          	auipc	a2,0x3
ffffffffc0204460:	6e460613          	addi	a2,a2,1764 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0204464:	0d600593          	li	a1,214
ffffffffc0204468:	00005517          	auipc	a0,0x5
ffffffffc020446c:	ad850513          	addi	a0,a0,-1320 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc0204470:	818fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204474 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0204474:	7139                	addi	sp,sp,-64
ffffffffc0204476:	f822                	sd	s0,48(sp)
ffffffffc0204478:	f426                	sd	s1,40(sp)
ffffffffc020447a:	fc06                	sd	ra,56(sp)
ffffffffc020447c:	f04a                	sd	s2,32(sp)
ffffffffc020447e:	ec4e                	sd	s3,24(sp)
ffffffffc0204480:	e852                	sd	s4,16(sp)
ffffffffc0204482:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0204484:	c4fff0ef          	jal	ra,ffffffffc02040d2 <mm_create>
    assert(mm != NULL);
ffffffffc0204488:	842a                	mv	s0,a0
ffffffffc020448a:	03200493          	li	s1,50
ffffffffc020448e:	e919                	bnez	a0,ffffffffc02044a4 <vmm_init+0x30>
ffffffffc0204490:	a989                	j	ffffffffc02048e2 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0204492:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204494:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204496:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020449a:	14ed                	addi	s1,s1,-5
ffffffffc020449c:	8522                	mv	a0,s0
ffffffffc020449e:	cf3ff0ef          	jal	ra,ffffffffc0204190 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02044a2:	c88d                	beqz	s1,ffffffffc02044d4 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02044a4:	03000513          	li	a0,48
ffffffffc02044a8:	fbafd0ef          	jal	ra,ffffffffc0201c62 <kmalloc>
ffffffffc02044ac:	85aa                	mv	a1,a0
ffffffffc02044ae:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02044b2:	f165                	bnez	a0,ffffffffc0204492 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc02044b4:	00004697          	auipc	a3,0x4
ffffffffc02044b8:	5fc68693          	addi	a3,a3,1532 # ffffffffc0208ab0 <default_pmm_manager+0x828>
ffffffffc02044bc:	00003617          	auipc	a2,0x3
ffffffffc02044c0:	68460613          	addi	a2,a2,1668 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02044c4:	11300593          	li	a1,275
ffffffffc02044c8:	00005517          	auipc	a0,0x5
ffffffffc02044cc:	a7850513          	addi	a0,a0,-1416 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc02044d0:	fb9fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc02044d4:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02044d8:	1f900913          	li	s2,505
ffffffffc02044dc:	a819                	j	ffffffffc02044f2 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc02044de:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02044e0:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02044e2:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02044e6:	0495                	addi	s1,s1,5
ffffffffc02044e8:	8522                	mv	a0,s0
ffffffffc02044ea:	ca7ff0ef          	jal	ra,ffffffffc0204190 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02044ee:	03248a63          	beq	s1,s2,ffffffffc0204522 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02044f2:	03000513          	li	a0,48
ffffffffc02044f6:	f6cfd0ef          	jal	ra,ffffffffc0201c62 <kmalloc>
ffffffffc02044fa:	85aa                	mv	a1,a0
ffffffffc02044fc:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0204500:	fd79                	bnez	a0,ffffffffc02044de <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0204502:	00004697          	auipc	a3,0x4
ffffffffc0204506:	5ae68693          	addi	a3,a3,1454 # ffffffffc0208ab0 <default_pmm_manager+0x828>
ffffffffc020450a:	00003617          	auipc	a2,0x3
ffffffffc020450e:	63660613          	addi	a2,a2,1590 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0204512:	11900593          	li	a1,281
ffffffffc0204516:	00005517          	auipc	a0,0x5
ffffffffc020451a:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc020451e:	f6bfb0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0204522:	6418                	ld	a4,8(s0)
ffffffffc0204524:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0204526:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc020452a:	2ee40063          	beq	s0,a4,ffffffffc020480a <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020452e:	fe873603          	ld	a2,-24(a4)
ffffffffc0204532:	ffe78693          	addi	a3,a5,-2
ffffffffc0204536:	24d61a63          	bne	a2,a3,ffffffffc020478a <vmm_init+0x316>
ffffffffc020453a:	ff073683          	ld	a3,-16(a4)
ffffffffc020453e:	24f69663          	bne	a3,a5,ffffffffc020478a <vmm_init+0x316>
ffffffffc0204542:	0795                	addi	a5,a5,5
ffffffffc0204544:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0204546:	feb792e3          	bne	a5,a1,ffffffffc020452a <vmm_init+0xb6>
ffffffffc020454a:	491d                	li	s2,7
ffffffffc020454c:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020454e:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0204552:	85a6                	mv	a1,s1
ffffffffc0204554:	8522                	mv	a0,s0
ffffffffc0204556:	bfdff0ef          	jal	ra,ffffffffc0204152 <find_vma>
ffffffffc020455a:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc020455c:	30050763          	beqz	a0,ffffffffc020486a <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0204560:	00148593          	addi	a1,s1,1
ffffffffc0204564:	8522                	mv	a0,s0
ffffffffc0204566:	bedff0ef          	jal	ra,ffffffffc0204152 <find_vma>
ffffffffc020456a:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc020456c:	2c050f63          	beqz	a0,ffffffffc020484a <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0204570:	85ca                	mv	a1,s2
ffffffffc0204572:	8522                	mv	a0,s0
ffffffffc0204574:	bdfff0ef          	jal	ra,ffffffffc0204152 <find_vma>
        assert(vma3 == NULL);
ffffffffc0204578:	2a051963          	bnez	a0,ffffffffc020482a <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc020457c:	00348593          	addi	a1,s1,3
ffffffffc0204580:	8522                	mv	a0,s0
ffffffffc0204582:	bd1ff0ef          	jal	ra,ffffffffc0204152 <find_vma>
        assert(vma4 == NULL);
ffffffffc0204586:	32051263          	bnez	a0,ffffffffc02048aa <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc020458a:	00448593          	addi	a1,s1,4
ffffffffc020458e:	8522                	mv	a0,s0
ffffffffc0204590:	bc3ff0ef          	jal	ra,ffffffffc0204152 <find_vma>
        assert(vma5 == NULL);
ffffffffc0204594:	2e051b63          	bnez	a0,ffffffffc020488a <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0204598:	008a3783          	ld	a5,8(s4)
ffffffffc020459c:	20979763          	bne	a5,s1,ffffffffc02047aa <vmm_init+0x336>
ffffffffc02045a0:	010a3783          	ld	a5,16(s4)
ffffffffc02045a4:	21279363          	bne	a5,s2,ffffffffc02047aa <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02045a8:	0089b783          	ld	a5,8(s3)
ffffffffc02045ac:	20979f63          	bne	a5,s1,ffffffffc02047ca <vmm_init+0x356>
ffffffffc02045b0:	0109b783          	ld	a5,16(s3)
ffffffffc02045b4:	21279b63          	bne	a5,s2,ffffffffc02047ca <vmm_init+0x356>
ffffffffc02045b8:	0495                	addi	s1,s1,5
ffffffffc02045ba:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02045bc:	f9549be3          	bne	s1,s5,ffffffffc0204552 <vmm_init+0xde>
ffffffffc02045c0:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02045c2:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02045c4:	85a6                	mv	a1,s1
ffffffffc02045c6:	8522                	mv	a0,s0
ffffffffc02045c8:	b8bff0ef          	jal	ra,ffffffffc0204152 <find_vma>
ffffffffc02045cc:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc02045d0:	c90d                	beqz	a0,ffffffffc0204602 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02045d2:	6914                	ld	a3,16(a0)
ffffffffc02045d4:	6510                	ld	a2,8(a0)
ffffffffc02045d6:	00005517          	auipc	a0,0x5
ffffffffc02045da:	bf250513          	addi	a0,a0,-1038 # ffffffffc02091c8 <default_pmm_manager+0xf40>
ffffffffc02045de:	bb5fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02045e2:	00005697          	auipc	a3,0x5
ffffffffc02045e6:	c0e68693          	addi	a3,a3,-1010 # ffffffffc02091f0 <default_pmm_manager+0xf68>
ffffffffc02045ea:	00003617          	auipc	a2,0x3
ffffffffc02045ee:	55660613          	addi	a2,a2,1366 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02045f2:	13b00593          	li	a1,315
ffffffffc02045f6:	00005517          	auipc	a0,0x5
ffffffffc02045fa:	94a50513          	addi	a0,a0,-1718 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc02045fe:	e8bfb0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0204602:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0204604:	fd2490e3          	bne	s1,s2,ffffffffc02045c4 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0204608:	8522                	mv	a0,s0
ffffffffc020460a:	c55ff0ef          	jal	ra,ffffffffc020425e <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020460e:	00005517          	auipc	a0,0x5
ffffffffc0204612:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0209208 <default_pmm_manager+0xf80>
ffffffffc0204616:	b7dfb0ef          	jal	ra,ffffffffc0200192 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020461a:	913fd0ef          	jal	ra,ffffffffc0201f2c <nr_free_pages>
ffffffffc020461e:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0204620:	ab3ff0ef          	jal	ra,ffffffffc02040d2 <mm_create>
ffffffffc0204624:	000db797          	auipc	a5,0xdb
ffffffffc0204628:	e8a7b223          	sd	a0,-380(a5) # ffffffffc02df4a8 <check_mm_struct>
ffffffffc020462c:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc020462e:	36050663          	beqz	a0,ffffffffc020499a <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204632:	000db797          	auipc	a5,0xdb
ffffffffc0204636:	d0e78793          	addi	a5,a5,-754 # ffffffffc02df340 <boot_pgdir>
ffffffffc020463a:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc020463e:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204642:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0204646:	2c079e63          	bnez	a5,ffffffffc0204922 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020464a:	03000513          	li	a0,48
ffffffffc020464e:	e14fd0ef          	jal	ra,ffffffffc0201c62 <kmalloc>
ffffffffc0204652:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0204654:	18050b63          	beqz	a0,ffffffffc02047ea <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0204658:	002007b7          	lui	a5,0x200
ffffffffc020465c:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc020465e:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0204660:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0204662:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0204664:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0204666:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc020466a:	b27ff0ef          	jal	ra,ffffffffc0204190 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020466e:	10000593          	li	a1,256
ffffffffc0204672:	8526                	mv	a0,s1
ffffffffc0204674:	adfff0ef          	jal	ra,ffffffffc0204152 <find_vma>
ffffffffc0204678:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc020467c:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0204680:	2ca41163          	bne	s0,a0,ffffffffc0204942 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0204684:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_matrix_out_size+0x1f43c0>
        sum += i;
ffffffffc0204688:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc020468a:	fee79de3          	bne	a5,a4,ffffffffc0204684 <vmm_init+0x210>
        sum += i;
ffffffffc020468e:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0204690:	10000793          	li	a5,256
        sum += i;
ffffffffc0204694:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x8782>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0204698:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020469c:	0007c683          	lbu	a3,0(a5)
ffffffffc02046a0:	0785                	addi	a5,a5,1
ffffffffc02046a2:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02046a4:	fec79ce3          	bne	a5,a2,ffffffffc020469c <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc02046a8:	2c071963          	bnez	a4,ffffffffc020497a <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc02046ac:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02046b0:	000dba97          	auipc	s5,0xdb
ffffffffc02046b4:	c98a8a93          	addi	s5,s5,-872 # ffffffffc02df348 <npage>
ffffffffc02046b8:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02046bc:	078a                	slli	a5,a5,0x2
ffffffffc02046be:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02046c0:	20e7f563          	bleu	a4,a5,ffffffffc02048ca <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02046c4:	00006697          	auipc	a3,0x6
ffffffffc02046c8:	28c68693          	addi	a3,a3,652 # ffffffffc020a950 <nbase>
ffffffffc02046cc:	0006ba03          	ld	s4,0(a3)
ffffffffc02046d0:	414786b3          	sub	a3,a5,s4
ffffffffc02046d4:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02046d6:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02046d8:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc02046da:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc02046dc:	83b1                	srli	a5,a5,0xc
ffffffffc02046de:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02046e0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02046e2:	28e7f063          	bleu	a4,a5,ffffffffc0204962 <vmm_init+0x4ee>
ffffffffc02046e6:	000db797          	auipc	a5,0xdb
ffffffffc02046ea:	cd278793          	addi	a5,a5,-814 # ffffffffc02df3b8 <va_pa_offset>
ffffffffc02046ee:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02046f0:	4581                	li	a1,0
ffffffffc02046f2:	854a                	mv	a0,s2
ffffffffc02046f4:	9436                	add	s0,s0,a3
ffffffffc02046f6:	e19fd0ef          	jal	ra,ffffffffc020250e <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02046fa:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02046fc:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204700:	078a                	slli	a5,a5,0x2
ffffffffc0204702:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204704:	1ce7f363          	bleu	a4,a5,ffffffffc02048ca <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0204708:	000db417          	auipc	s0,0xdb
ffffffffc020470c:	cc040413          	addi	s0,s0,-832 # ffffffffc02df3c8 <pages>
ffffffffc0204710:	6008                	ld	a0,0(s0)
ffffffffc0204712:	414787b3          	sub	a5,a5,s4
ffffffffc0204716:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0204718:	953e                	add	a0,a0,a5
ffffffffc020471a:	4585                	li	a1,1
ffffffffc020471c:	fcafd0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0204720:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0204724:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204728:	078a                	slli	a5,a5,0x2
ffffffffc020472a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020472c:	18e7ff63          	bleu	a4,a5,ffffffffc02048ca <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0204730:	6008                	ld	a0,0(s0)
ffffffffc0204732:	414787b3          	sub	a5,a5,s4
ffffffffc0204736:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0204738:	4585                	li	a1,1
ffffffffc020473a:	953e                	add	a0,a0,a5
ffffffffc020473c:	faafd0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    pgdir[0] = 0;
ffffffffc0204740:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0204744:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0204748:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc020474c:	8526                	mv	a0,s1
ffffffffc020474e:	b11ff0ef          	jal	ra,ffffffffc020425e <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0204752:	000db797          	auipc	a5,0xdb
ffffffffc0204756:	d407bb23          	sd	zero,-682(a5) # ffffffffc02df4a8 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020475a:	fd2fd0ef          	jal	ra,ffffffffc0201f2c <nr_free_pages>
ffffffffc020475e:	1aa99263          	bne	s3,a0,ffffffffc0204902 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0204762:	00005517          	auipc	a0,0x5
ffffffffc0204766:	b3650513          	addi	a0,a0,-1226 # ffffffffc0209298 <default_pmm_manager+0x1010>
ffffffffc020476a:	a29fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
}
ffffffffc020476e:	7442                	ld	s0,48(sp)
ffffffffc0204770:	70e2                	ld	ra,56(sp)
ffffffffc0204772:	74a2                	ld	s1,40(sp)
ffffffffc0204774:	7902                	ld	s2,32(sp)
ffffffffc0204776:	69e2                	ld	s3,24(sp)
ffffffffc0204778:	6a42                	ld	s4,16(sp)
ffffffffc020477a:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020477c:	00005517          	auipc	a0,0x5
ffffffffc0204780:	b3c50513          	addi	a0,a0,-1220 # ffffffffc02092b8 <default_pmm_manager+0x1030>
}
ffffffffc0204784:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0204786:	a0dfb06f          	j	ffffffffc0200192 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020478a:	00005697          	auipc	a3,0x5
ffffffffc020478e:	95668693          	addi	a3,a3,-1706 # ffffffffc02090e0 <default_pmm_manager+0xe58>
ffffffffc0204792:	00003617          	auipc	a2,0x3
ffffffffc0204796:	3ae60613          	addi	a2,a2,942 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020479a:	12200593          	li	a1,290
ffffffffc020479e:	00004517          	auipc	a0,0x4
ffffffffc02047a2:	7a250513          	addi	a0,a0,1954 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc02047a6:	ce3fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02047aa:	00005697          	auipc	a3,0x5
ffffffffc02047ae:	9be68693          	addi	a3,a3,-1602 # ffffffffc0209168 <default_pmm_manager+0xee0>
ffffffffc02047b2:	00003617          	auipc	a2,0x3
ffffffffc02047b6:	38e60613          	addi	a2,a2,910 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02047ba:	13200593          	li	a1,306
ffffffffc02047be:	00004517          	auipc	a0,0x4
ffffffffc02047c2:	78250513          	addi	a0,a0,1922 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc02047c6:	cc3fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02047ca:	00005697          	auipc	a3,0x5
ffffffffc02047ce:	9ce68693          	addi	a3,a3,-1586 # ffffffffc0209198 <default_pmm_manager+0xf10>
ffffffffc02047d2:	00003617          	auipc	a2,0x3
ffffffffc02047d6:	36e60613          	addi	a2,a2,878 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02047da:	13300593          	li	a1,307
ffffffffc02047de:	00004517          	auipc	a0,0x4
ffffffffc02047e2:	76250513          	addi	a0,a0,1890 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc02047e6:	ca3fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(vma != NULL);
ffffffffc02047ea:	00004697          	auipc	a3,0x4
ffffffffc02047ee:	2c668693          	addi	a3,a3,710 # ffffffffc0208ab0 <default_pmm_manager+0x828>
ffffffffc02047f2:	00003617          	auipc	a2,0x3
ffffffffc02047f6:	34e60613          	addi	a2,a2,846 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02047fa:	15200593          	li	a1,338
ffffffffc02047fe:	00004517          	auipc	a0,0x4
ffffffffc0204802:	74250513          	addi	a0,a0,1858 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc0204806:	c83fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc020480a:	00005697          	auipc	a3,0x5
ffffffffc020480e:	8be68693          	addi	a3,a3,-1858 # ffffffffc02090c8 <default_pmm_manager+0xe40>
ffffffffc0204812:	00003617          	auipc	a2,0x3
ffffffffc0204816:	32e60613          	addi	a2,a2,814 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020481a:	12000593          	li	a1,288
ffffffffc020481e:	00004517          	auipc	a0,0x4
ffffffffc0204822:	72250513          	addi	a0,a0,1826 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc0204826:	c63fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma3 == NULL);
ffffffffc020482a:	00005697          	auipc	a3,0x5
ffffffffc020482e:	90e68693          	addi	a3,a3,-1778 # ffffffffc0209138 <default_pmm_manager+0xeb0>
ffffffffc0204832:	00003617          	auipc	a2,0x3
ffffffffc0204836:	30e60613          	addi	a2,a2,782 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020483a:	12c00593          	li	a1,300
ffffffffc020483e:	00004517          	auipc	a0,0x4
ffffffffc0204842:	70250513          	addi	a0,a0,1794 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc0204846:	c43fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma2 != NULL);
ffffffffc020484a:	00005697          	auipc	a3,0x5
ffffffffc020484e:	8de68693          	addi	a3,a3,-1826 # ffffffffc0209128 <default_pmm_manager+0xea0>
ffffffffc0204852:	00003617          	auipc	a2,0x3
ffffffffc0204856:	2ee60613          	addi	a2,a2,750 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020485a:	12a00593          	li	a1,298
ffffffffc020485e:	00004517          	auipc	a0,0x4
ffffffffc0204862:	6e250513          	addi	a0,a0,1762 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc0204866:	c23fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma1 != NULL);
ffffffffc020486a:	00005697          	auipc	a3,0x5
ffffffffc020486e:	8ae68693          	addi	a3,a3,-1874 # ffffffffc0209118 <default_pmm_manager+0xe90>
ffffffffc0204872:	00003617          	auipc	a2,0x3
ffffffffc0204876:	2ce60613          	addi	a2,a2,718 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020487a:	12800593          	li	a1,296
ffffffffc020487e:	00004517          	auipc	a0,0x4
ffffffffc0204882:	6c250513          	addi	a0,a0,1730 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc0204886:	c03fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma5 == NULL);
ffffffffc020488a:	00005697          	auipc	a3,0x5
ffffffffc020488e:	8ce68693          	addi	a3,a3,-1842 # ffffffffc0209158 <default_pmm_manager+0xed0>
ffffffffc0204892:	00003617          	auipc	a2,0x3
ffffffffc0204896:	2ae60613          	addi	a2,a2,686 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020489a:	13000593          	li	a1,304
ffffffffc020489e:	00004517          	auipc	a0,0x4
ffffffffc02048a2:	6a250513          	addi	a0,a0,1698 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc02048a6:	be3fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma4 == NULL);
ffffffffc02048aa:	00005697          	auipc	a3,0x5
ffffffffc02048ae:	89e68693          	addi	a3,a3,-1890 # ffffffffc0209148 <default_pmm_manager+0xec0>
ffffffffc02048b2:	00003617          	auipc	a2,0x3
ffffffffc02048b6:	28e60613          	addi	a2,a2,654 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02048ba:	12e00593          	li	a1,302
ffffffffc02048be:	00004517          	auipc	a0,0x4
ffffffffc02048c2:	68250513          	addi	a0,a0,1666 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc02048c6:	bc3fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02048ca:	00004617          	auipc	a2,0x4
ffffffffc02048ce:	a6e60613          	addi	a2,a2,-1426 # ffffffffc0208338 <default_pmm_manager+0xb0>
ffffffffc02048d2:	06200593          	li	a1,98
ffffffffc02048d6:	00004517          	auipc	a0,0x4
ffffffffc02048da:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc02048de:	babfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(mm != NULL);
ffffffffc02048e2:	00004697          	auipc	a3,0x4
ffffffffc02048e6:	19668693          	addi	a3,a3,406 # ffffffffc0208a78 <default_pmm_manager+0x7f0>
ffffffffc02048ea:	00003617          	auipc	a2,0x3
ffffffffc02048ee:	25660613          	addi	a2,a2,598 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02048f2:	10c00593          	li	a1,268
ffffffffc02048f6:	00004517          	auipc	a0,0x4
ffffffffc02048fa:	64a50513          	addi	a0,a0,1610 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc02048fe:	b8bfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0204902:	00005697          	auipc	a3,0x5
ffffffffc0204906:	96e68693          	addi	a3,a3,-1682 # ffffffffc0209270 <default_pmm_manager+0xfe8>
ffffffffc020490a:	00003617          	auipc	a2,0x3
ffffffffc020490e:	23660613          	addi	a2,a2,566 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0204912:	17000593          	li	a1,368
ffffffffc0204916:	00004517          	auipc	a0,0x4
ffffffffc020491a:	62a50513          	addi	a0,a0,1578 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc020491e:	b6bfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0204922:	00004697          	auipc	a3,0x4
ffffffffc0204926:	17e68693          	addi	a3,a3,382 # ffffffffc0208aa0 <default_pmm_manager+0x818>
ffffffffc020492a:	00003617          	auipc	a2,0x3
ffffffffc020492e:	21660613          	addi	a2,a2,534 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0204932:	14f00593          	li	a1,335
ffffffffc0204936:	00004517          	auipc	a0,0x4
ffffffffc020493a:	60a50513          	addi	a0,a0,1546 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc020493e:	b4bfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0204942:	00005697          	auipc	a3,0x5
ffffffffc0204946:	8fe68693          	addi	a3,a3,-1794 # ffffffffc0209240 <default_pmm_manager+0xfb8>
ffffffffc020494a:	00003617          	auipc	a2,0x3
ffffffffc020494e:	1f660613          	addi	a2,a2,502 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0204952:	15700593          	li	a1,343
ffffffffc0204956:	00004517          	auipc	a0,0x4
ffffffffc020495a:	5ea50513          	addi	a0,a0,1514 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc020495e:	b2bfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    return KADDR(page2pa(page));
ffffffffc0204962:	00004617          	auipc	a2,0x4
ffffffffc0204966:	97660613          	addi	a2,a2,-1674 # ffffffffc02082d8 <default_pmm_manager+0x50>
ffffffffc020496a:	06900593          	li	a1,105
ffffffffc020496e:	00004517          	auipc	a0,0x4
ffffffffc0204972:	99250513          	addi	a0,a0,-1646 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc0204976:	b13fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(sum == 0);
ffffffffc020497a:	00005697          	auipc	a3,0x5
ffffffffc020497e:	8e668693          	addi	a3,a3,-1818 # ffffffffc0209260 <default_pmm_manager+0xfd8>
ffffffffc0204982:	00003617          	auipc	a2,0x3
ffffffffc0204986:	1be60613          	addi	a2,a2,446 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020498a:	16300593          	li	a1,355
ffffffffc020498e:	00004517          	auipc	a0,0x4
ffffffffc0204992:	5b250513          	addi	a0,a0,1458 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc0204996:	af3fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc020499a:	00005697          	auipc	a3,0x5
ffffffffc020499e:	88e68693          	addi	a3,a3,-1906 # ffffffffc0209228 <default_pmm_manager+0xfa0>
ffffffffc02049a2:	00003617          	auipc	a2,0x3
ffffffffc02049a6:	19e60613          	addi	a2,a2,414 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02049aa:	14b00593          	li	a1,331
ffffffffc02049ae:	00004517          	auipc	a0,0x4
ffffffffc02049b2:	59250513          	addi	a0,a0,1426 # ffffffffc0208f40 <default_pmm_manager+0xcb8>
ffffffffc02049b6:	ad3fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02049ba <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02049ba:	7139                	addi	sp,sp,-64
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02049bc:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02049be:	f822                	sd	s0,48(sp)
ffffffffc02049c0:	f426                	sd	s1,40(sp)
ffffffffc02049c2:	fc06                	sd	ra,56(sp)
ffffffffc02049c4:	f04a                	sd	s2,32(sp)
ffffffffc02049c6:	ec4e                	sd	s3,24(sp)
ffffffffc02049c8:	8432                	mv	s0,a2
ffffffffc02049ca:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02049cc:	f86ff0ef          	jal	ra,ffffffffc0204152 <find_vma>

    pgfault_num++;
ffffffffc02049d0:	000db797          	auipc	a5,0xdb
ffffffffc02049d4:	98c78793          	addi	a5,a5,-1652 # ffffffffc02df35c <pgfault_num>
ffffffffc02049d8:	439c                	lw	a5,0(a5)
ffffffffc02049da:	2785                	addiw	a5,a5,1
ffffffffc02049dc:	000db717          	auipc	a4,0xdb
ffffffffc02049e0:	98f72023          	sw	a5,-1664(a4) # ffffffffc02df35c <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02049e4:	c555                	beqz	a0,ffffffffc0204a90 <do_pgfault+0xd6>
ffffffffc02049e6:	651c                	ld	a5,8(a0)
ffffffffc02049e8:	0af46463          	bltu	s0,a5,ffffffffc0204a90 <do_pgfault+0xd6>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02049ec:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02049ee:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02049f0:	8b89                	andi	a5,a5,2
ffffffffc02049f2:	e3a5                	bnez	a5,ffffffffc0204a52 <do_pgfault+0x98>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02049f4:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02049f6:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02049f8:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02049fa:	85a2                	mv	a1,s0
ffffffffc02049fc:	4605                	li	a2,1
ffffffffc02049fe:	d6efd0ef          	jal	ra,ffffffffc0201f6c <get_pte>
ffffffffc0204a02:	c945                	beqz	a0,ffffffffc0204ab2 <do_pgfault+0xf8>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0204a04:	610c                	ld	a1,0(a0)
ffffffffc0204a06:	c5b5                	beqz	a1,ffffffffc0204a72 <do_pgfault+0xb8>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if(swap_init_ok) {
ffffffffc0204a08:	000db797          	auipc	a5,0xdb
ffffffffc0204a0c:	95078793          	addi	a5,a5,-1712 # ffffffffc02df358 <swap_init_ok>
ffffffffc0204a10:	439c                	lw	a5,0(a5)
ffffffffc0204a12:	2781                	sext.w	a5,a5
ffffffffc0204a14:	c7d9                	beqz	a5,ffffffffc0204aa2 <do_pgfault+0xe8>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc0204a16:	0030                	addi	a2,sp,8
ffffffffc0204a18:	85a2                	mv	a1,s0
ffffffffc0204a1a:	8526                	mv	a0,s1
            struct Page *page=NULL;
ffffffffc0204a1c:	e402                	sd	zero,8(sp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc0204a1e:	a2eff0ef          	jal	ra,ffffffffc0203c4c <swap_in>
ffffffffc0204a22:	892a                	mv	s2,a0
ffffffffc0204a24:	e90d                	bnez	a0,ffffffffc0204a56 <do_pgfault+0x9c>
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc0204a26:	65a2                	ld	a1,8(sp)
ffffffffc0204a28:	6c88                	ld	a0,24(s1)
ffffffffc0204a2a:	86ce                	mv	a3,s3
ffffffffc0204a2c:	8622                	mv	a2,s0
ffffffffc0204a2e:	b55fd0ef          	jal	ra,ffffffffc0202582 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0204a32:	6622                	ld	a2,8(sp)
ffffffffc0204a34:	4685                	li	a3,1
ffffffffc0204a36:	85a2                	mv	a1,s0
ffffffffc0204a38:	8526                	mv	a0,s1
ffffffffc0204a3a:	8eeff0ef          	jal	ra,ffffffffc0203b28 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0204a3e:	67a2                	ld	a5,8(sp)
ffffffffc0204a40:	ff80                	sd	s0,56(a5)
        }
   }
   ret = 0;
failed:
    return ret;
}
ffffffffc0204a42:	70e2                	ld	ra,56(sp)
ffffffffc0204a44:	7442                	ld	s0,48(sp)
ffffffffc0204a46:	854a                	mv	a0,s2
ffffffffc0204a48:	74a2                	ld	s1,40(sp)
ffffffffc0204a4a:	7902                	ld	s2,32(sp)
ffffffffc0204a4c:	69e2                	ld	s3,24(sp)
ffffffffc0204a4e:	6121                	addi	sp,sp,64
ffffffffc0204a50:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0204a52:	49dd                	li	s3,23
ffffffffc0204a54:	b745                	j	ffffffffc02049f4 <do_pgfault+0x3a>
                cprintf("swap_in in do_pgfault failed\n");
ffffffffc0204a56:	00004517          	auipc	a0,0x4
ffffffffc0204a5a:	57250513          	addi	a0,a0,1394 # ffffffffc0208fc8 <default_pmm_manager+0xd40>
ffffffffc0204a5e:	f34fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
}
ffffffffc0204a62:	70e2                	ld	ra,56(sp)
ffffffffc0204a64:	7442                	ld	s0,48(sp)
ffffffffc0204a66:	854a                	mv	a0,s2
ffffffffc0204a68:	74a2                	ld	s1,40(sp)
ffffffffc0204a6a:	7902                	ld	s2,32(sp)
ffffffffc0204a6c:	69e2                	ld	s3,24(sp)
ffffffffc0204a6e:	6121                	addi	sp,sp,64
ffffffffc0204a70:	8082                	ret
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204a72:	6c88                	ld	a0,24(s1)
ffffffffc0204a74:	864e                	mv	a2,s3
ffffffffc0204a76:	85a2                	mv	a1,s0
ffffffffc0204a78:	88dfe0ef          	jal	ra,ffffffffc0203304 <pgdir_alloc_page>
   ret = 0;
ffffffffc0204a7c:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204a7e:	f171                	bnez	a0,ffffffffc0204a42 <do_pgfault+0x88>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204a80:	00004517          	auipc	a0,0x4
ffffffffc0204a84:	52050513          	addi	a0,a0,1312 # ffffffffc0208fa0 <default_pmm_manager+0xd18>
ffffffffc0204a88:	f0afb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a8c:	5971                	li	s2,-4
            goto failed;
ffffffffc0204a8e:	bf55                	j	ffffffffc0204a42 <do_pgfault+0x88>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204a90:	85a2                	mv	a1,s0
ffffffffc0204a92:	00004517          	auipc	a0,0x4
ffffffffc0204a96:	4be50513          	addi	a0,a0,1214 # ffffffffc0208f50 <default_pmm_manager+0xcc8>
ffffffffc0204a9a:	ef8fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    int ret = -E_INVAL;
ffffffffc0204a9e:	5975                	li	s2,-3
        goto failed;
ffffffffc0204aa0:	b74d                	j	ffffffffc0204a42 <do_pgfault+0x88>
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
ffffffffc0204aa2:	00004517          	auipc	a0,0x4
ffffffffc0204aa6:	54650513          	addi	a0,a0,1350 # ffffffffc0208fe8 <default_pmm_manager+0xd60>
ffffffffc0204aaa:	ee8fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204aae:	5971                	li	s2,-4
            goto failed;
ffffffffc0204ab0:	bf49                	j	ffffffffc0204a42 <do_pgfault+0x88>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204ab2:	00004517          	auipc	a0,0x4
ffffffffc0204ab6:	4ce50513          	addi	a0,a0,1230 # ffffffffc0208f80 <default_pmm_manager+0xcf8>
ffffffffc0204aba:	ed8fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204abe:	5971                	li	s2,-4
        goto failed;
ffffffffc0204ac0:	b749                	j	ffffffffc0204a42 <do_pgfault+0x88>

ffffffffc0204ac2 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0204ac2:	7179                	addi	sp,sp,-48
ffffffffc0204ac4:	f022                	sd	s0,32(sp)
ffffffffc0204ac6:	f406                	sd	ra,40(sp)
ffffffffc0204ac8:	ec26                	sd	s1,24(sp)
ffffffffc0204aca:	e84a                	sd	s2,16(sp)
ffffffffc0204acc:	e44e                	sd	s3,8(sp)
ffffffffc0204ace:	e052                	sd	s4,0(sp)
ffffffffc0204ad0:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0204ad2:	c135                	beqz	a0,ffffffffc0204b36 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0204ad4:	002007b7          	lui	a5,0x200
ffffffffc0204ad8:	04f5e663          	bltu	a1,a5,ffffffffc0204b24 <user_mem_check+0x62>
ffffffffc0204adc:	00c584b3          	add	s1,a1,a2
ffffffffc0204ae0:	0495f263          	bleu	s1,a1,ffffffffc0204b24 <user_mem_check+0x62>
ffffffffc0204ae4:	4785                	li	a5,1
ffffffffc0204ae6:	07fe                	slli	a5,a5,0x1f
ffffffffc0204ae8:	0297ee63          	bltu	a5,s1,ffffffffc0204b24 <user_mem_check+0x62>
ffffffffc0204aec:	892a                	mv	s2,a0
ffffffffc0204aee:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204af0:	6a05                	lui	s4,0x1
ffffffffc0204af2:	a821                	j	ffffffffc0204b0a <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204af4:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204af8:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204afa:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204afc:	c685                	beqz	a3,ffffffffc0204b24 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204afe:	c399                	beqz	a5,ffffffffc0204b04 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204b00:	02e46263          	bltu	s0,a4,ffffffffc0204b24 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0204b04:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0204b06:	04947663          	bleu	s1,s0,ffffffffc0204b52 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0204b0a:	85a2                	mv	a1,s0
ffffffffc0204b0c:	854a                	mv	a0,s2
ffffffffc0204b0e:	e44ff0ef          	jal	ra,ffffffffc0204152 <find_vma>
ffffffffc0204b12:	c909                	beqz	a0,ffffffffc0204b24 <user_mem_check+0x62>
ffffffffc0204b14:	6518                	ld	a4,8(a0)
ffffffffc0204b16:	00e46763          	bltu	s0,a4,ffffffffc0204b24 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204b1a:	4d1c                	lw	a5,24(a0)
ffffffffc0204b1c:	fc099ce3          	bnez	s3,ffffffffc0204af4 <user_mem_check+0x32>
ffffffffc0204b20:	8b85                	andi	a5,a5,1
ffffffffc0204b22:	f3ed                	bnez	a5,ffffffffc0204b04 <user_mem_check+0x42>
            return 0;
ffffffffc0204b24:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0204b26:	70a2                	ld	ra,40(sp)
ffffffffc0204b28:	7402                	ld	s0,32(sp)
ffffffffc0204b2a:	64e2                	ld	s1,24(sp)
ffffffffc0204b2c:	6942                	ld	s2,16(sp)
ffffffffc0204b2e:	69a2                	ld	s3,8(sp)
ffffffffc0204b30:	6a02                	ld	s4,0(sp)
ffffffffc0204b32:	6145                	addi	sp,sp,48
ffffffffc0204b34:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204b36:	c02007b7          	lui	a5,0xc0200
ffffffffc0204b3a:	4501                	li	a0,0
ffffffffc0204b3c:	fef5e5e3          	bltu	a1,a5,ffffffffc0204b26 <user_mem_check+0x64>
ffffffffc0204b40:	962e                	add	a2,a2,a1
ffffffffc0204b42:	fec5f2e3          	bleu	a2,a1,ffffffffc0204b26 <user_mem_check+0x64>
ffffffffc0204b46:	c8000537          	lui	a0,0xc8000
ffffffffc0204b4a:	0505                	addi	a0,a0,1
ffffffffc0204b4c:	00a63533          	sltu	a0,a2,a0
ffffffffc0204b50:	bfd9                	j	ffffffffc0204b26 <user_mem_check+0x64>
        return 1;
ffffffffc0204b52:	4505                	li	a0,1
ffffffffc0204b54:	bfc9                	j	ffffffffc0204b26 <user_mem_check+0x64>

ffffffffc0204b56 <phi_test_sema>:

struct proc_struct *philosopher_proc_sema[N];

void phi_test_sema(int i) /* i：哲学家号码从0到N-1 */
{ 
    if(state_sema[i]==HUNGRY&&state_sema[LEFT]!=EATING
ffffffffc0204b56:	000db697          	auipc	a3,0xdb
ffffffffc0204b5a:	95a68693          	addi	a3,a3,-1702 # ffffffffc02df4b0 <state_sema>
ffffffffc0204b5e:	00251793          	slli	a5,a0,0x2
ffffffffc0204b62:	97b6                	add	a5,a5,a3
ffffffffc0204b64:	4390                	lw	a2,0(a5)
ffffffffc0204b66:	4705                	li	a4,1
ffffffffc0204b68:	00e60363          	beq	a2,a4,ffffffffc0204b6e <phi_test_sema+0x18>
            &&state_sema[RIGHT]!=EATING)
    {
        state_sema[i]=EATING;
        up(&s[i]);
    }
}
ffffffffc0204b6c:	8082                	ret
    if(state_sema[i]==HUNGRY&&state_sema[LEFT]!=EATING
ffffffffc0204b6e:	0045071b          	addiw	a4,a0,4
ffffffffc0204b72:	4595                	li	a1,5
ffffffffc0204b74:	02b7673b          	remw	a4,a4,a1
ffffffffc0204b78:	4609                	li	a2,2
ffffffffc0204b7a:	070a                	slli	a4,a4,0x2
ffffffffc0204b7c:	9736                	add	a4,a4,a3
ffffffffc0204b7e:	4318                	lw	a4,0(a4)
ffffffffc0204b80:	fec706e3          	beq	a4,a2,ffffffffc0204b6c <phi_test_sema+0x16>
            &&state_sema[RIGHT]!=EATING)
ffffffffc0204b84:	0015071b          	addiw	a4,a0,1
ffffffffc0204b88:	02b7673b          	remw	a4,a4,a1
ffffffffc0204b8c:	070a                	slli	a4,a4,0x2
ffffffffc0204b8e:	96ba                	add	a3,a3,a4
ffffffffc0204b90:	4298                	lw	a4,0(a3)
ffffffffc0204b92:	fcc70de3          	beq	a4,a2,ffffffffc0204b6c <phi_test_sema+0x16>
        up(&s[i]);
ffffffffc0204b96:	00151713          	slli	a4,a0,0x1
ffffffffc0204b9a:	953a                	add	a0,a0,a4
ffffffffc0204b9c:	050e                	slli	a0,a0,0x3
ffffffffc0204b9e:	000db717          	auipc	a4,0xdb
ffffffffc0204ba2:	9ea70713          	addi	a4,a4,-1558 # ffffffffc02df588 <s>
ffffffffc0204ba6:	953a                	add	a0,a0,a4
        state_sema[i]=EATING;
ffffffffc0204ba8:	c390                	sw	a2,0(a5)
        up(&s[i]);
ffffffffc0204baa:	7960006f          	j	ffffffffc0205340 <up>

ffffffffc0204bae <phi_take_forks_sema>:

void phi_take_forks_sema(int i) /* i：哲学家号码从0到N-1 */
{ 
ffffffffc0204bae:	1141                	addi	sp,sp,-16
ffffffffc0204bb0:	e022                	sd	s0,0(sp)
ffffffffc0204bb2:	842a                	mv	s0,a0
        down(&mutex); /* 进入临界区 */
ffffffffc0204bb4:	000db517          	auipc	a0,0xdb
ffffffffc0204bb8:	93c50513          	addi	a0,a0,-1732 # ffffffffc02df4f0 <mutex>
{ 
ffffffffc0204bbc:	e406                	sd	ra,8(sp)
        down(&mutex); /* 进入临界区 */
ffffffffc0204bbe:	786000ef          	jal	ra,ffffffffc0205344 <down>
        state_sema[i]=HUNGRY; /* 记录下哲学家i饥饿的事实 */
ffffffffc0204bc2:	00241713          	slli	a4,s0,0x2
ffffffffc0204bc6:	000db797          	auipc	a5,0xdb
ffffffffc0204bca:	8ea78793          	addi	a5,a5,-1814 # ffffffffc02df4b0 <state_sema>
ffffffffc0204bce:	97ba                	add	a5,a5,a4
        phi_test_sema(i); /* 试图得到两只叉子 */
ffffffffc0204bd0:	8522                	mv	a0,s0
        state_sema[i]=HUNGRY; /* 记录下哲学家i饥饿的事实 */
ffffffffc0204bd2:	4705                	li	a4,1
ffffffffc0204bd4:	c398                	sw	a4,0(a5)
        phi_test_sema(i); /* 试图得到两只叉子 */
ffffffffc0204bd6:	f81ff0ef          	jal	ra,ffffffffc0204b56 <phi_test_sema>
        up(&mutex); /* 离开临界区 */
ffffffffc0204bda:	000db517          	auipc	a0,0xdb
ffffffffc0204bde:	91650513          	addi	a0,a0,-1770 # ffffffffc02df4f0 <mutex>
ffffffffc0204be2:	75e000ef          	jal	ra,ffffffffc0205340 <up>
        down(&s[i]); /* 如果得不到叉子就阻塞 */
ffffffffc0204be6:	00141793          	slli	a5,s0,0x1
ffffffffc0204bea:	97a2                	add	a5,a5,s0
}
ffffffffc0204bec:	6402                	ld	s0,0(sp)
ffffffffc0204bee:	60a2                	ld	ra,8(sp)
        down(&s[i]); /* 如果得不到叉子就阻塞 */
ffffffffc0204bf0:	078e                	slli	a5,a5,0x3
ffffffffc0204bf2:	000db517          	auipc	a0,0xdb
ffffffffc0204bf6:	99650513          	addi	a0,a0,-1642 # ffffffffc02df588 <s>
ffffffffc0204bfa:	953e                	add	a0,a0,a5
}
ffffffffc0204bfc:	0141                	addi	sp,sp,16
        down(&s[i]); /* 如果得不到叉子就阻塞 */
ffffffffc0204bfe:	7460006f          	j	ffffffffc0205344 <down>

ffffffffc0204c02 <phi_put_forks_sema>:

void phi_put_forks_sema(int i) /* i：哲学家号码从0到N-1 */
{ 
ffffffffc0204c02:	1101                	addi	sp,sp,-32
ffffffffc0204c04:	e822                	sd	s0,16(sp)
ffffffffc0204c06:	842a                	mv	s0,a0
        down(&mutex); /* 进入临界区 */
ffffffffc0204c08:	000db517          	auipc	a0,0xdb
ffffffffc0204c0c:	8e850513          	addi	a0,a0,-1816 # ffffffffc02df4f0 <mutex>
{ 
ffffffffc0204c10:	ec06                	sd	ra,24(sp)
ffffffffc0204c12:	e426                	sd	s1,8(sp)
        down(&mutex); /* 进入临界区 */
ffffffffc0204c14:	730000ef          	jal	ra,ffffffffc0205344 <down>
        state_sema[i]=THINKING; /* 哲学家进餐结束 */
        phi_test_sema(LEFT); /* 看一下左邻居现在是否能进餐 */
ffffffffc0204c18:	4495                	li	s1,5
ffffffffc0204c1a:	0044051b          	addiw	a0,s0,4
ffffffffc0204c1e:	0295653b          	remw	a0,a0,s1
        state_sema[i]=THINKING; /* 哲学家进餐结束 */
ffffffffc0204c22:	00241713          	slli	a4,s0,0x2
ffffffffc0204c26:	000db797          	auipc	a5,0xdb
ffffffffc0204c2a:	88a78793          	addi	a5,a5,-1910 # ffffffffc02df4b0 <state_sema>
ffffffffc0204c2e:	97ba                	add	a5,a5,a4
ffffffffc0204c30:	0007a023          	sw	zero,0(a5)
        phi_test_sema(LEFT); /* 看一下左邻居现在是否能进餐 */
ffffffffc0204c34:	f23ff0ef          	jal	ra,ffffffffc0204b56 <phi_test_sema>
        phi_test_sema(RIGHT); /* 看一下右邻居现在是否能进餐 */
ffffffffc0204c38:	0014051b          	addiw	a0,s0,1
ffffffffc0204c3c:	0295653b          	remw	a0,a0,s1
ffffffffc0204c40:	f17ff0ef          	jal	ra,ffffffffc0204b56 <phi_test_sema>
        up(&mutex); /* 离开临界区 */
}
ffffffffc0204c44:	6442                	ld	s0,16(sp)
ffffffffc0204c46:	60e2                	ld	ra,24(sp)
ffffffffc0204c48:	64a2                	ld	s1,8(sp)
        up(&mutex); /* 离开临界区 */
ffffffffc0204c4a:	000db517          	auipc	a0,0xdb
ffffffffc0204c4e:	8a650513          	addi	a0,a0,-1882 # ffffffffc02df4f0 <mutex>
}
ffffffffc0204c52:	6105                	addi	sp,sp,32
        up(&mutex); /* 离开临界区 */
ffffffffc0204c54:	6ec0006f          	j	ffffffffc0205340 <up>

ffffffffc0204c58 <philosopher_using_semaphore>:

int philosopher_using_semaphore(void * arg) /* i：哲学家号码，从0到N-1 */
{
ffffffffc0204c58:	7179                	addi	sp,sp,-48
ffffffffc0204c5a:	ec26                	sd	s1,24(sp)
    int i, iter=0;
    i=(int)arg;
ffffffffc0204c5c:	0005049b          	sext.w	s1,a0
    cprintf("I am No.%d philosopher_sema\n",i);
ffffffffc0204c60:	85a6                	mv	a1,s1
ffffffffc0204c62:	00005517          	auipc	a0,0x5
ffffffffc0204c66:	88650513          	addi	a0,a0,-1914 # ffffffffc02094e8 <default_pmm_manager+0x1260>
{
ffffffffc0204c6a:	f022                	sd	s0,32(sp)
ffffffffc0204c6c:	e84a                	sd	s2,16(sp)
ffffffffc0204c6e:	e44e                	sd	s3,8(sp)
ffffffffc0204c70:	e052                	sd	s4,0(sp)
ffffffffc0204c72:	f406                	sd	ra,40(sp)
    while(iter++<TIMES)
ffffffffc0204c74:	4405                	li	s0,1
    cprintf("I am No.%d philosopher_sema\n",i);
ffffffffc0204c76:	d1cfb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    { /* 无限循环 */
        cprintf("Iter %d, No.%d philosopher_sema is thinking\n",iter,i); /* 哲学家正在思考 */
ffffffffc0204c7a:	00005a17          	auipc	s4,0x5
ffffffffc0204c7e:	88ea0a13          	addi	s4,s4,-1906 # ffffffffc0209508 <default_pmm_manager+0x1280>
        do_sleep(SLEEP_TIME);
        phi_take_forks_sema(i); 
        /* 需要两只叉子，或者阻塞 */
        cprintf("Iter %d, No.%d philosopher_sema is eating\n",iter,i); /* 进餐 */
ffffffffc0204c82:	00005997          	auipc	s3,0x5
ffffffffc0204c86:	8b698993          	addi	s3,s3,-1866 # ffffffffc0209538 <default_pmm_manager+0x12b0>
    while(iter++<TIMES)
ffffffffc0204c8a:	4915                	li	s2,5
        cprintf("Iter %d, No.%d philosopher_sema is thinking\n",iter,i); /* 哲学家正在思考 */
ffffffffc0204c8c:	85a2                	mv	a1,s0
ffffffffc0204c8e:	8626                	mv	a2,s1
ffffffffc0204c90:	8552                	mv	a0,s4
ffffffffc0204c92:	d00fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
        do_sleep(SLEEP_TIME);
ffffffffc0204c96:	4529                	li	a0,10
ffffffffc0204c98:	491010ef          	jal	ra,ffffffffc0206928 <do_sleep>
        phi_take_forks_sema(i); 
ffffffffc0204c9c:	8526                	mv	a0,s1
ffffffffc0204c9e:	f11ff0ef          	jal	ra,ffffffffc0204bae <phi_take_forks_sema>
        cprintf("Iter %d, No.%d philosopher_sema is eating\n",iter,i); /* 进餐 */
ffffffffc0204ca2:	85a2                	mv	a1,s0
ffffffffc0204ca4:	8626                	mv	a2,s1
ffffffffc0204ca6:	854e                	mv	a0,s3
ffffffffc0204ca8:	ceafb0ef          	jal	ra,ffffffffc0200192 <cprintf>
        do_sleep(SLEEP_TIME);
ffffffffc0204cac:	4529                	li	a0,10
ffffffffc0204cae:	47b010ef          	jal	ra,ffffffffc0206928 <do_sleep>
    while(iter++<TIMES)
ffffffffc0204cb2:	2405                	addiw	s0,s0,1
        phi_put_forks_sema(i); 
ffffffffc0204cb4:	8526                	mv	a0,s1
ffffffffc0204cb6:	f4dff0ef          	jal	ra,ffffffffc0204c02 <phi_put_forks_sema>
    while(iter++<TIMES)
ffffffffc0204cba:	fd2419e3          	bne	s0,s2,ffffffffc0204c8c <philosopher_using_semaphore+0x34>
        /* 把两把叉子同时放回桌子 */
    }
    cprintf("No.%d philosopher_sema quit\n",i);
ffffffffc0204cbe:	85a6                	mv	a1,s1
ffffffffc0204cc0:	00005517          	auipc	a0,0x5
ffffffffc0204cc4:	8a850513          	addi	a0,a0,-1880 # ffffffffc0209568 <default_pmm_manager+0x12e0>
ffffffffc0204cc8:	ccafb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    return 0;    
}
ffffffffc0204ccc:	70a2                	ld	ra,40(sp)
ffffffffc0204cce:	7402                	ld	s0,32(sp)
ffffffffc0204cd0:	64e2                	ld	s1,24(sp)
ffffffffc0204cd2:	6942                	ld	s2,16(sp)
ffffffffc0204cd4:	69a2                	ld	s3,8(sp)
ffffffffc0204cd6:	6a02                	ld	s4,0(sp)
ffffffffc0204cd8:	4501                	li	a0,0
ffffffffc0204cda:	6145                	addi	sp,sp,48
ffffffffc0204cdc:	8082                	ret

ffffffffc0204cde <phi_test_condvar>:

struct proc_struct *philosopher_proc_condvar[N]; // N philosopher
int state_condvar[N];                            // the philosopher's state: EATING, HUNGARY, THINKING  
monitor_t mt, *mtp=&mt;                          // monitor

void phi_test_condvar (int i) { 
ffffffffc0204cde:	7179                	addi	sp,sp,-48
ffffffffc0204ce0:	ec26                	sd	s1,24(sp)
    if(state_condvar[i]==HUNGRY&&state_condvar[LEFT]!=EATING
ffffffffc0204ce2:	000db717          	auipc	a4,0xdb
ffffffffc0204ce6:	86670713          	addi	a4,a4,-1946 # ffffffffc02df548 <state_condvar>
ffffffffc0204cea:	00251493          	slli	s1,a0,0x2
void phi_test_condvar (int i) { 
ffffffffc0204cee:	e84a                	sd	s2,16(sp)
    if(state_condvar[i]==HUNGRY&&state_condvar[LEFT]!=EATING
ffffffffc0204cf0:	00970933          	add	s2,a4,s1
ffffffffc0204cf4:	00092683          	lw	a3,0(s2)
void phi_test_condvar (int i) { 
ffffffffc0204cf8:	f406                	sd	ra,40(sp)
ffffffffc0204cfa:	f022                	sd	s0,32(sp)
ffffffffc0204cfc:	e44e                	sd	s3,8(sp)
    if(state_condvar[i]==HUNGRY&&state_condvar[LEFT]!=EATING
ffffffffc0204cfe:	4785                	li	a5,1
ffffffffc0204d00:	00f68963          	beq	a3,a5,ffffffffc0204d12 <phi_test_condvar+0x34>
        cprintf("phi_test_condvar: state_condvar[%d] will eating\n",i);
        state_condvar[i] = EATING ;
        cprintf("phi_test_condvar: signal self_cv[%d] \n",i);
        cond_signal(&mtp->cv[i]) ;
    }
}
ffffffffc0204d04:	70a2                	ld	ra,40(sp)
ffffffffc0204d06:	7402                	ld	s0,32(sp)
ffffffffc0204d08:	64e2                	ld	s1,24(sp)
ffffffffc0204d0a:	6942                	ld	s2,16(sp)
ffffffffc0204d0c:	69a2                	ld	s3,8(sp)
ffffffffc0204d0e:	6145                	addi	sp,sp,48
ffffffffc0204d10:	8082                	ret
    if(state_condvar[i]==HUNGRY&&state_condvar[LEFT]!=EATING
ffffffffc0204d12:	0045079b          	addiw	a5,a0,4
ffffffffc0204d16:	4695                	li	a3,5
ffffffffc0204d18:	02d7e7bb          	remw	a5,a5,a3
ffffffffc0204d1c:	4989                	li	s3,2
ffffffffc0204d1e:	078a                	slli	a5,a5,0x2
ffffffffc0204d20:	97ba                	add	a5,a5,a4
ffffffffc0204d22:	439c                	lw	a5,0(a5)
ffffffffc0204d24:	ff3780e3          	beq	a5,s3,ffffffffc0204d04 <phi_test_condvar+0x26>
            &&state_condvar[RIGHT]!=EATING) {
ffffffffc0204d28:	0015079b          	addiw	a5,a0,1
ffffffffc0204d2c:	02d7e7bb          	remw	a5,a5,a3
ffffffffc0204d30:	078a                	slli	a5,a5,0x2
ffffffffc0204d32:	973e                	add	a4,a4,a5
ffffffffc0204d34:	431c                	lw	a5,0(a4)
ffffffffc0204d36:	fd3787e3          	beq	a5,s3,ffffffffc0204d04 <phi_test_condvar+0x26>
        cprintf("phi_test_condvar: state_condvar[%d] will eating\n",i);
ffffffffc0204d3a:	842a                	mv	s0,a0
ffffffffc0204d3c:	85aa                	mv	a1,a0
ffffffffc0204d3e:	00004517          	auipc	a0,0x4
ffffffffc0204d42:	6aa50513          	addi	a0,a0,1706 # ffffffffc02093e8 <default_pmm_manager+0x1160>
ffffffffc0204d46:	c4cfb0ef          	jal	ra,ffffffffc0200192 <cprintf>
        cprintf("phi_test_condvar: signal self_cv[%d] \n",i);
ffffffffc0204d4a:	85a2                	mv	a1,s0
ffffffffc0204d4c:	00004517          	auipc	a0,0x4
ffffffffc0204d50:	6d450513          	addi	a0,a0,1748 # ffffffffc0209420 <default_pmm_manager+0x1198>
        state_condvar[i] = EATING ;
ffffffffc0204d54:	01392023          	sw	s3,0(s2)
        cprintf("phi_test_condvar: signal self_cv[%d] \n",i);
ffffffffc0204d58:	c3afb0ef          	jal	ra,ffffffffc0200192 <cprintf>
        cond_signal(&mtp->cv[i]) ;
ffffffffc0204d5c:	000cf797          	auipc	a5,0xcf
ffffffffc0204d60:	19478793          	addi	a5,a5,404 # ffffffffc02d3ef0 <mtp>
ffffffffc0204d64:	639c                	ld	a5,0(a5)
ffffffffc0204d66:	00848533          	add	a0,s1,s0
}
ffffffffc0204d6a:	7402                	ld	s0,32(sp)
        cond_signal(&mtp->cv[i]) ;
ffffffffc0204d6c:	7f9c                	ld	a5,56(a5)
}
ffffffffc0204d6e:	70a2                	ld	ra,40(sp)
ffffffffc0204d70:	64e2                	ld	s1,24(sp)
ffffffffc0204d72:	6942                	ld	s2,16(sp)
ffffffffc0204d74:	69a2                	ld	s3,8(sp)
        cond_signal(&mtp->cv[i]) ;
ffffffffc0204d76:	050e                	slli	a0,a0,0x3
ffffffffc0204d78:	953e                	add	a0,a0,a5
}
ffffffffc0204d7a:	6145                	addi	sp,sp,48
        cond_signal(&mtp->cv[i]) ;
ffffffffc0204d7c:	3a60006f          	j	ffffffffc0205122 <cond_signal>

ffffffffc0204d80 <phi_take_forks_condvar>:


void phi_take_forks_condvar(int i) {
ffffffffc0204d80:	7179                	addi	sp,sp,-48
ffffffffc0204d82:	e44e                	sd	s3,8(sp)
     down(&(mtp->mutex));
ffffffffc0204d84:	000cf997          	auipc	s3,0xcf
ffffffffc0204d88:	16c98993          	addi	s3,s3,364 # ffffffffc02d3ef0 <mtp>
void phi_take_forks_condvar(int i) {
ffffffffc0204d8c:	e84a                	sd	s2,16(sp)
ffffffffc0204d8e:	892a                	mv	s2,a0
     down(&(mtp->mutex));
ffffffffc0204d90:	0009b503          	ld	a0,0(s3)
void phi_take_forks_condvar(int i) {
ffffffffc0204d94:	f406                	sd	ra,40(sp)
ffffffffc0204d96:	f022                	sd	s0,32(sp)
ffffffffc0204d98:	ec26                	sd	s1,24(sp)
//--------into routine in monitor--------------
     // LAB7 EXERCISE: YOUR CODE
     // I am hungry
     state_condvar[i] = HUNGRY;//饿了，要吃
ffffffffc0204d9a:	000da417          	auipc	s0,0xda
ffffffffc0204d9e:	7ae40413          	addi	s0,s0,1966 # ffffffffc02df548 <state_condvar>
     down(&(mtp->mutex));
ffffffffc0204da2:	5a2000ef          	jal	ra,ffffffffc0205344 <down>
     state_condvar[i] = HUNGRY;//饿了，要吃
ffffffffc0204da6:	00291493          	slli	s1,s2,0x2
ffffffffc0204daa:	4785                	li	a5,1
ffffffffc0204dac:	9426                	add	s0,s0,s1
     // try to get fork
     phi_test_condvar(i);
ffffffffc0204dae:	854a                	mv	a0,s2
     state_condvar[i] = HUNGRY;//饿了，要吃
ffffffffc0204db0:	c01c                	sw	a5,0(s0)
     phi_test_condvar(i);
ffffffffc0204db2:	f2dff0ef          	jal	ra,ffffffffc0204cde <phi_test_condvar>
        // if I can't get fork, I will wait
        if(state_condvar[i] != EATING) {
ffffffffc0204db6:	4018                	lw	a4,0(s0)
ffffffffc0204db8:	4789                	li	a5,2
ffffffffc0204dba:	02f70163          	beq	a4,a5,ffffffffc0204ddc <phi_take_forks_condvar+0x5c>
            cprintf("phi_take_forks_condvar: %d didn't get fork and will wait\n",i);
ffffffffc0204dbe:	85ca                	mv	a1,s2
ffffffffc0204dc0:	00004517          	auipc	a0,0x4
ffffffffc0204dc4:	5e850513          	addi	a0,a0,1512 # ffffffffc02093a8 <default_pmm_manager+0x1120>
ffffffffc0204dc8:	bcafb0ef          	jal	ra,ffffffffc0200192 <cprintf>
            cond_wait(&mtp->cv[i]);//等待
ffffffffc0204dcc:	0009b783          	ld	a5,0(s3)
ffffffffc0204dd0:	94ca                	add	s1,s1,s2
ffffffffc0204dd2:	048e                	slli	s1,s1,0x3
ffffffffc0204dd4:	7f88                	ld	a0,56(a5)
ffffffffc0204dd6:	9526                	add	a0,a0,s1
ffffffffc0204dd8:	3ba000ef          	jal	ra,ffffffffc0205192 <cond_wait>
        }
//--------leave routine in monitor--------------

      if(mtp->next_count>0)
ffffffffc0204ddc:	0009b503          	ld	a0,0(s3)
ffffffffc0204de0:	591c                	lw	a5,48(a0)
ffffffffc0204de2:	00f05363          	blez	a5,ffffffffc0204de8 <phi_take_forks_condvar+0x68>
         up(&(mtp->next));
ffffffffc0204de6:	0561                	addi	a0,a0,24
      else
         up(&(mtp->mutex));
}
ffffffffc0204de8:	7402                	ld	s0,32(sp)
ffffffffc0204dea:	70a2                	ld	ra,40(sp)
ffffffffc0204dec:	64e2                	ld	s1,24(sp)
ffffffffc0204dee:	6942                	ld	s2,16(sp)
ffffffffc0204df0:	69a2                	ld	s3,8(sp)
ffffffffc0204df2:	6145                	addi	sp,sp,48
         up(&(mtp->mutex));
ffffffffc0204df4:	54c0006f          	j	ffffffffc0205340 <up>

ffffffffc0204df8 <phi_put_forks_condvar>:

void phi_put_forks_condvar(int i) {
ffffffffc0204df8:	1101                	addi	sp,sp,-32
ffffffffc0204dfa:	e426                	sd	s1,8(sp)
     down(&(mtp->mutex));
ffffffffc0204dfc:	000cf497          	auipc	s1,0xcf
ffffffffc0204e00:	0f448493          	addi	s1,s1,244 # ffffffffc02d3ef0 <mtp>
void phi_put_forks_condvar(int i) {
ffffffffc0204e04:	e822                	sd	s0,16(sp)
ffffffffc0204e06:	842a                	mv	s0,a0
     down(&(mtp->mutex));
ffffffffc0204e08:	6088                	ld	a0,0(s1)
void phi_put_forks_condvar(int i) {
ffffffffc0204e0a:	ec06                	sd	ra,24(sp)
ffffffffc0204e0c:	e04a                	sd	s2,0(sp)
     down(&(mtp->mutex));
ffffffffc0204e0e:	536000ef          	jal	ra,ffffffffc0205344 <down>
//--------into routine in monitor--------------
     // LAB7 EXERCISE: YOUR CODE
     // I ate over
        state_condvar[i] = THINKING;//吃完了，要思考
        //cprintf("phi_put_forks_condvar: %d ate over and will test left and right neighbors\n",i);
        phi_test_condvar(LEFT); // test left and right neighbors
ffffffffc0204e12:	4915                	li	s2,5
ffffffffc0204e14:	0044051b          	addiw	a0,s0,4
ffffffffc0204e18:	0325653b          	remw	a0,a0,s2
        state_condvar[i] = THINKING;//吃完了，要思考
ffffffffc0204e1c:	00241713          	slli	a4,s0,0x2
ffffffffc0204e20:	000da797          	auipc	a5,0xda
ffffffffc0204e24:	72878793          	addi	a5,a5,1832 # ffffffffc02df548 <state_condvar>
ffffffffc0204e28:	97ba                	add	a5,a5,a4
ffffffffc0204e2a:	0007a023          	sw	zero,0(a5)
        phi_test_condvar(LEFT); // test left and right neighbors
ffffffffc0204e2e:	eb1ff0ef          	jal	ra,ffffffffc0204cde <phi_test_condvar>
        phi_test_condvar(RIGHT);
ffffffffc0204e32:	0014051b          	addiw	a0,s0,1
ffffffffc0204e36:	0325653b          	remw	a0,a0,s2
ffffffffc0204e3a:	ea5ff0ef          	jal	ra,ffffffffc0204cde <phi_test_condvar>
     // test left and right neighbors
    
//--------leave routine in monitor--------------
     if(mtp->next_count>0)
ffffffffc0204e3e:	6088                	ld	a0,0(s1)
ffffffffc0204e40:	591c                	lw	a5,48(a0)
ffffffffc0204e42:	00f05363          	blez	a5,ffffffffc0204e48 <phi_put_forks_condvar+0x50>
        up(&(mtp->next));
ffffffffc0204e46:	0561                	addi	a0,a0,24
     else
        up(&(mtp->mutex));
}
ffffffffc0204e48:	6442                	ld	s0,16(sp)
ffffffffc0204e4a:	60e2                	ld	ra,24(sp)
ffffffffc0204e4c:	64a2                	ld	s1,8(sp)
ffffffffc0204e4e:	6902                	ld	s2,0(sp)
ffffffffc0204e50:	6105                	addi	sp,sp,32
        up(&(mtp->mutex));
ffffffffc0204e52:	4ee0006f          	j	ffffffffc0205340 <up>

ffffffffc0204e56 <philosopher_using_condvar>:

//---------- philosophers using monitor (condition variable) ----------------------
int philosopher_using_condvar(void * arg) { /* arg is the No. of philosopher 0~N-1*/
ffffffffc0204e56:	7179                	addi	sp,sp,-48
ffffffffc0204e58:	ec26                	sd	s1,24(sp)
  
    int i, iter=0;
    i=(int)arg;
ffffffffc0204e5a:	0005049b          	sext.w	s1,a0
    cprintf("I am No.%d philosopher_condvar\n",i);
ffffffffc0204e5e:	85a6                	mv	a1,s1
ffffffffc0204e60:	00004517          	auipc	a0,0x4
ffffffffc0204e64:	5e850513          	addi	a0,a0,1512 # ffffffffc0209448 <default_pmm_manager+0x11c0>
int philosopher_using_condvar(void * arg) { /* arg is the No. of philosopher 0~N-1*/
ffffffffc0204e68:	f022                	sd	s0,32(sp)
ffffffffc0204e6a:	e84a                	sd	s2,16(sp)
ffffffffc0204e6c:	e44e                	sd	s3,8(sp)
ffffffffc0204e6e:	e052                	sd	s4,0(sp)
ffffffffc0204e70:	f406                	sd	ra,40(sp)
    while(iter++<TIMES)
ffffffffc0204e72:	4405                	li	s0,1
    cprintf("I am No.%d philosopher_condvar\n",i);
ffffffffc0204e74:	b1efb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    { /* iterate*/
        cprintf("Iter %d, No.%d philosopher_condvar is thinking\n",iter,i); /* thinking*/
ffffffffc0204e78:	00004a17          	auipc	s4,0x4
ffffffffc0204e7c:	5f0a0a13          	addi	s4,s4,1520 # ffffffffc0209468 <default_pmm_manager+0x11e0>
        do_sleep(SLEEP_TIME);
        phi_take_forks_condvar(i); 
        /* need two forks, maybe blocked */
        cprintf("Iter %d, No.%d philosopher_condvar is eating\n",iter,i); /* eating*/
ffffffffc0204e80:	00004997          	auipc	s3,0x4
ffffffffc0204e84:	61898993          	addi	s3,s3,1560 # ffffffffc0209498 <default_pmm_manager+0x1210>
    while(iter++<TIMES)
ffffffffc0204e88:	4915                	li	s2,5
        cprintf("Iter %d, No.%d philosopher_condvar is thinking\n",iter,i); /* thinking*/
ffffffffc0204e8a:	85a2                	mv	a1,s0
ffffffffc0204e8c:	8626                	mv	a2,s1
ffffffffc0204e8e:	8552                	mv	a0,s4
ffffffffc0204e90:	b02fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
        do_sleep(SLEEP_TIME);
ffffffffc0204e94:	4529                	li	a0,10
ffffffffc0204e96:	293010ef          	jal	ra,ffffffffc0206928 <do_sleep>
        phi_take_forks_condvar(i); 
ffffffffc0204e9a:	8526                	mv	a0,s1
ffffffffc0204e9c:	ee5ff0ef          	jal	ra,ffffffffc0204d80 <phi_take_forks_condvar>
        cprintf("Iter %d, No.%d philosopher_condvar is eating\n",iter,i); /* eating*/
ffffffffc0204ea0:	85a2                	mv	a1,s0
ffffffffc0204ea2:	8626                	mv	a2,s1
ffffffffc0204ea4:	854e                	mv	a0,s3
ffffffffc0204ea6:	aecfb0ef          	jal	ra,ffffffffc0200192 <cprintf>
        do_sleep(SLEEP_TIME);
ffffffffc0204eaa:	4529                	li	a0,10
ffffffffc0204eac:	27d010ef          	jal	ra,ffffffffc0206928 <do_sleep>
    while(iter++<TIMES)
ffffffffc0204eb0:	2405                	addiw	s0,s0,1
        phi_put_forks_condvar(i); 
ffffffffc0204eb2:	8526                	mv	a0,s1
ffffffffc0204eb4:	f45ff0ef          	jal	ra,ffffffffc0204df8 <phi_put_forks_condvar>
    while(iter++<TIMES)
ffffffffc0204eb8:	fd2419e3          	bne	s0,s2,ffffffffc0204e8a <philosopher_using_condvar+0x34>
        /* return two forks back*/
    }
    cprintf("No.%d philosopher_condvar quit\n",i);
ffffffffc0204ebc:	85a6                	mv	a1,s1
ffffffffc0204ebe:	00004517          	auipc	a0,0x4
ffffffffc0204ec2:	60a50513          	addi	a0,a0,1546 # ffffffffc02094c8 <default_pmm_manager+0x1240>
ffffffffc0204ec6:	accfb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    return 0;    
}
ffffffffc0204eca:	70a2                	ld	ra,40(sp)
ffffffffc0204ecc:	7402                	ld	s0,32(sp)
ffffffffc0204ece:	64e2                	ld	s1,24(sp)
ffffffffc0204ed0:	6942                	ld	s2,16(sp)
ffffffffc0204ed2:	69a2                	ld	s3,8(sp)
ffffffffc0204ed4:	6a02                	ld	s4,0(sp)
ffffffffc0204ed6:	4501                	li	a0,0
ffffffffc0204ed8:	6145                	addi	sp,sp,48
ffffffffc0204eda:	8082                	ret

ffffffffc0204edc <check_sync>:

void check_sync(void){
ffffffffc0204edc:	7159                	addi	sp,sp,-112
ffffffffc0204ede:	f0a2                	sd	s0,96(sp)

    int i, pids[N];

    //check semaphore
    sem_init(&mutex, 1);
ffffffffc0204ee0:	4585                	li	a1,1
ffffffffc0204ee2:	000da517          	auipc	a0,0xda
ffffffffc0204ee6:	60e50513          	addi	a0,a0,1550 # ffffffffc02df4f0 <mutex>
ffffffffc0204eea:	0020                	addi	s0,sp,8
void check_sync(void){
ffffffffc0204eec:	eca6                	sd	s1,88(sp)
ffffffffc0204eee:	e8ca                	sd	s2,80(sp)
ffffffffc0204ef0:	e4ce                	sd	s3,72(sp)
ffffffffc0204ef2:	e0d2                	sd	s4,64(sp)
ffffffffc0204ef4:	fc56                	sd	s5,56(sp)
ffffffffc0204ef6:	f85a                	sd	s6,48(sp)
ffffffffc0204ef8:	f45e                	sd	s7,40(sp)
ffffffffc0204efa:	f486                	sd	ra,104(sp)
ffffffffc0204efc:	f062                	sd	s8,32(sp)
ffffffffc0204efe:	000daa17          	auipc	s4,0xda
ffffffffc0204f02:	68aa0a13          	addi	s4,s4,1674 # ffffffffc02df588 <s>
    sem_init(&mutex, 1);
ffffffffc0204f06:	432000ef          	jal	ra,ffffffffc0205338 <sem_init>
    for(i=0;i<N;i++){
ffffffffc0204f0a:	000da997          	auipc	s3,0xda
ffffffffc0204f0e:	65698993          	addi	s3,s3,1622 # ffffffffc02df560 <philosopher_proc_sema>
    sem_init(&mutex, 1);
ffffffffc0204f12:	8922                	mv	s2,s0
ffffffffc0204f14:	4481                	li	s1,0
        sem_init(&s[i], 0);
        int pid = kernel_thread(philosopher_using_semaphore, (void *)i, 0);
ffffffffc0204f16:	00000b97          	auipc	s7,0x0
ffffffffc0204f1a:	d42b8b93          	addi	s7,s7,-702 # ffffffffc0204c58 <philosopher_using_semaphore>
        if (pid <= 0) {
            panic("create No.%d philosopher_using_semaphore failed.\n");
        }
        pids[i] = pid;
        philosopher_proc_sema[i] = find_proc(pid);
        set_proc_name(philosopher_proc_sema[i], "philosopher_sema_proc");
ffffffffc0204f1e:	00004b17          	auipc	s6,0x4
ffffffffc0204f22:	402b0b13          	addi	s6,s6,1026 # ffffffffc0209320 <default_pmm_manager+0x1098>
    for(i=0;i<N;i++){
ffffffffc0204f26:	4a95                	li	s5,5
        sem_init(&s[i], 0);
ffffffffc0204f28:	4581                	li	a1,0
ffffffffc0204f2a:	8552                	mv	a0,s4
ffffffffc0204f2c:	40c000ef          	jal	ra,ffffffffc0205338 <sem_init>
        int pid = kernel_thread(philosopher_using_semaphore, (void *)i, 0);
ffffffffc0204f30:	4601                	li	a2,0
ffffffffc0204f32:	85a6                	mv	a1,s1
ffffffffc0204f34:	855e                	mv	a0,s7
ffffffffc0204f36:	535000ef          	jal	ra,ffffffffc0205c6a <kernel_thread>
        if (pid <= 0) {
ffffffffc0204f3a:	0ca05963          	blez	a0,ffffffffc020500c <check_sync+0x130>
        pids[i] = pid;
ffffffffc0204f3e:	00a92023          	sw	a0,0(s2)
        philosopher_proc_sema[i] = find_proc(pid);
ffffffffc0204f42:	0df000ef          	jal	ra,ffffffffc0205820 <find_proc>
ffffffffc0204f46:	00a9b023          	sd	a0,0(s3)
        set_proc_name(philosopher_proc_sema[i], "philosopher_sema_proc");
ffffffffc0204f4a:	85da                	mv	a1,s6
ffffffffc0204f4c:	0485                	addi	s1,s1,1
ffffffffc0204f4e:	0a61                	addi	s4,s4,24
ffffffffc0204f50:	03b000ef          	jal	ra,ffffffffc020578a <set_proc_name>
ffffffffc0204f54:	0911                	addi	s2,s2,4
ffffffffc0204f56:	09a1                	addi	s3,s3,8
    for(i=0;i<N;i++){
ffffffffc0204f58:	fd5498e3          	bne	s1,s5,ffffffffc0204f28 <check_sync+0x4c>
ffffffffc0204f5c:	01440a93          	addi	s5,s0,20
ffffffffc0204f60:	84a2                	mv	s1,s0
    }
    for (i=0;i<N;i++)
        assert(do_wait(pids[i],NULL) == 0);
ffffffffc0204f62:	4088                	lw	a0,0(s1)
ffffffffc0204f64:	4581                	li	a1,0
ffffffffc0204f66:	798010ef          	jal	ra,ffffffffc02066fe <do_wait>
ffffffffc0204f6a:	0e051963          	bnez	a0,ffffffffc020505c <check_sync+0x180>
ffffffffc0204f6e:	0491                	addi	s1,s1,4
    for (i=0;i<N;i++)
ffffffffc0204f70:	ff5499e3          	bne	s1,s5,ffffffffc0204f62 <check_sync+0x86>

    //check condition variable
    monitor_init(&mt, N);
ffffffffc0204f74:	4595                	li	a1,5
ffffffffc0204f76:	000da517          	auipc	a0,0xda
ffffffffc0204f7a:	59250513          	addi	a0,a0,1426 # ffffffffc02df508 <mt>
ffffffffc0204f7e:	0fe000ef          	jal	ra,ffffffffc020507c <monitor_init>
    for(i=0;i<N;i++){
ffffffffc0204f82:	000da917          	auipc	s2,0xda
ffffffffc0204f86:	5c690913          	addi	s2,s2,1478 # ffffffffc02df548 <state_condvar>
ffffffffc0204f8a:	000daa17          	auipc	s4,0xda
ffffffffc0204f8e:	53ea0a13          	addi	s4,s4,1342 # ffffffffc02df4c8 <philosopher_proc_condvar>
    monitor_init(&mt, N);
ffffffffc0204f92:	89a2                	mv	s3,s0
ffffffffc0204f94:	4481                	li	s1,0
        state_condvar[i]=THINKING;
        int pid = kernel_thread(philosopher_using_condvar, (void *)i, 0);
ffffffffc0204f96:	00000b17          	auipc	s6,0x0
ffffffffc0204f9a:	ec0b0b13          	addi	s6,s6,-320 # ffffffffc0204e56 <philosopher_using_condvar>
        if (pid <= 0) {
            panic("create No.%d philosopher_using_condvar failed.\n");
        }
        pids[i] = pid;
        philosopher_proc_condvar[i] = find_proc(pid);
        set_proc_name(philosopher_proc_condvar[i], "philosopher_condvar_proc");
ffffffffc0204f9e:	00004c17          	auipc	s8,0x4
ffffffffc0204fa2:	3eac0c13          	addi	s8,s8,1002 # ffffffffc0209388 <default_pmm_manager+0x1100>
    for(i=0;i<N;i++){
ffffffffc0204fa6:	4b95                	li	s7,5
        int pid = kernel_thread(philosopher_using_condvar, (void *)i, 0);
ffffffffc0204fa8:	4601                	li	a2,0
ffffffffc0204faa:	85a6                	mv	a1,s1
ffffffffc0204fac:	855a                	mv	a0,s6
        state_condvar[i]=THINKING;
ffffffffc0204fae:	00092023          	sw	zero,0(s2)
        int pid = kernel_thread(philosopher_using_condvar, (void *)i, 0);
ffffffffc0204fb2:	4b9000ef          	jal	ra,ffffffffc0205c6a <kernel_thread>
        if (pid <= 0) {
ffffffffc0204fb6:	08a05763          	blez	a0,ffffffffc0205044 <check_sync+0x168>
        pids[i] = pid;
ffffffffc0204fba:	00a9a023          	sw	a0,0(s3)
        philosopher_proc_condvar[i] = find_proc(pid);
ffffffffc0204fbe:	063000ef          	jal	ra,ffffffffc0205820 <find_proc>
ffffffffc0204fc2:	00aa3023          	sd	a0,0(s4)
        set_proc_name(philosopher_proc_condvar[i], "philosopher_condvar_proc");
ffffffffc0204fc6:	85e2                	mv	a1,s8
ffffffffc0204fc8:	0485                	addi	s1,s1,1
ffffffffc0204fca:	0911                	addi	s2,s2,4
ffffffffc0204fcc:	7be000ef          	jal	ra,ffffffffc020578a <set_proc_name>
ffffffffc0204fd0:	0991                	addi	s3,s3,4
ffffffffc0204fd2:	0a21                	addi	s4,s4,8
    for(i=0;i<N;i++){
ffffffffc0204fd4:	fd749ae3          	bne	s1,s7,ffffffffc0204fa8 <check_sync+0xcc>
    }
    for (i=0;i<N;i++)
        assert(do_wait(pids[i],NULL) == 0);
ffffffffc0204fd8:	4008                	lw	a0,0(s0)
ffffffffc0204fda:	4581                	li	a1,0
ffffffffc0204fdc:	722010ef          	jal	ra,ffffffffc02066fe <do_wait>
ffffffffc0204fe0:	e131                	bnez	a0,ffffffffc0205024 <check_sync+0x148>
ffffffffc0204fe2:	0411                	addi	s0,s0,4
    for (i=0;i<N;i++)
ffffffffc0204fe4:	ff541ae3          	bne	s0,s5,ffffffffc0204fd8 <check_sync+0xfc>
    monitor_free(&mt, N);
}
ffffffffc0204fe8:	7406                	ld	s0,96(sp)
ffffffffc0204fea:	70a6                	ld	ra,104(sp)
ffffffffc0204fec:	64e6                	ld	s1,88(sp)
ffffffffc0204fee:	6946                	ld	s2,80(sp)
ffffffffc0204ff0:	69a6                	ld	s3,72(sp)
ffffffffc0204ff2:	6a06                	ld	s4,64(sp)
ffffffffc0204ff4:	7ae2                	ld	s5,56(sp)
ffffffffc0204ff6:	7b42                	ld	s6,48(sp)
ffffffffc0204ff8:	7ba2                	ld	s7,40(sp)
ffffffffc0204ffa:	7c02                	ld	s8,32(sp)
    monitor_free(&mt, N);
ffffffffc0204ffc:	4595                	li	a1,5
ffffffffc0204ffe:	000da517          	auipc	a0,0xda
ffffffffc0205002:	50a50513          	addi	a0,a0,1290 # ffffffffc02df508 <mt>
}
ffffffffc0205006:	6165                	addi	sp,sp,112
    monitor_free(&mt, N);
ffffffffc0205008:	1140006f          	j	ffffffffc020511c <monitor_free>
            panic("create No.%d philosopher_using_semaphore failed.\n");
ffffffffc020500c:	00004617          	auipc	a2,0x4
ffffffffc0205010:	2c460613          	addi	a2,a2,708 # ffffffffc02092d0 <default_pmm_manager+0x1048>
ffffffffc0205014:	0fc00593          	li	a1,252
ffffffffc0205018:	00004517          	auipc	a0,0x4
ffffffffc020501c:	2f050513          	addi	a0,a0,752 # ffffffffc0209308 <default_pmm_manager+0x1080>
ffffffffc0205020:	c68fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(do_wait(pids[i],NULL) == 0);
ffffffffc0205024:	00004697          	auipc	a3,0x4
ffffffffc0205028:	31468693          	addi	a3,a3,788 # ffffffffc0209338 <default_pmm_manager+0x10b0>
ffffffffc020502c:	00003617          	auipc	a2,0x3
ffffffffc0205030:	b1460613          	addi	a2,a2,-1260 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0205034:	11200593          	li	a1,274
ffffffffc0205038:	00004517          	auipc	a0,0x4
ffffffffc020503c:	2d050513          	addi	a0,a0,720 # ffffffffc0209308 <default_pmm_manager+0x1080>
ffffffffc0205040:	c48fb0ef          	jal	ra,ffffffffc0200488 <__panic>
            panic("create No.%d philosopher_using_condvar failed.\n");
ffffffffc0205044:	00004617          	auipc	a2,0x4
ffffffffc0205048:	31460613          	addi	a2,a2,788 # ffffffffc0209358 <default_pmm_manager+0x10d0>
ffffffffc020504c:	10b00593          	li	a1,267
ffffffffc0205050:	00004517          	auipc	a0,0x4
ffffffffc0205054:	2b850513          	addi	a0,a0,696 # ffffffffc0209308 <default_pmm_manager+0x1080>
ffffffffc0205058:	c30fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(do_wait(pids[i],NULL) == 0);
ffffffffc020505c:	00004697          	auipc	a3,0x4
ffffffffc0205060:	2dc68693          	addi	a3,a3,732 # ffffffffc0209338 <default_pmm_manager+0x10b0>
ffffffffc0205064:	00003617          	auipc	a2,0x3
ffffffffc0205068:	adc60613          	addi	a2,a2,-1316 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020506c:	10300593          	li	a1,259
ffffffffc0205070:	00004517          	auipc	a0,0x4
ffffffffc0205074:	29850513          	addi	a0,a0,664 # ffffffffc0209308 <default_pmm_manager+0x1080>
ffffffffc0205078:	c10fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020507c <monitor_init>:
#include <assert.h>


// Initialize monitor.
void     
monitor_init (monitor_t * mtp, size_t num_cv) {
ffffffffc020507c:	1101                	addi	sp,sp,-32
ffffffffc020507e:	ec06                	sd	ra,24(sp)
ffffffffc0205080:	e822                	sd	s0,16(sp)
ffffffffc0205082:	e426                	sd	s1,8(sp)
ffffffffc0205084:	e04a                	sd	s2,0(sp)
    int i;
    assert(num_cv>0);
ffffffffc0205086:	cda9                	beqz	a1,ffffffffc02050e0 <monitor_init+0x64>
    mtp->next_count = 0;
ffffffffc0205088:	842e                	mv	s0,a1
ffffffffc020508a:	02052823          	sw	zero,48(a0)
    mtp->cv = NULL;
    sem_init(&(mtp->mutex), 1); //unlocked
ffffffffc020508e:	4585                	li	a1,1
    mtp->cv = NULL;
ffffffffc0205090:	02053c23          	sd	zero,56(a0)
    sem_init(&(mtp->mutex), 1); //unlocked
ffffffffc0205094:	84aa                	mv	s1,a0
    sem_init(&(mtp->next), 0);
    mtp->cv =(condvar_t *) kmalloc(sizeof(condvar_t)*num_cv);
ffffffffc0205096:	00241913          	slli	s2,s0,0x2
    sem_init(&(mtp->mutex), 1); //unlocked
ffffffffc020509a:	29e000ef          	jal	ra,ffffffffc0205338 <sem_init>
    sem_init(&(mtp->next), 0);
ffffffffc020509e:	4581                	li	a1,0
ffffffffc02050a0:	01848513          	addi	a0,s1,24
    mtp->cv =(condvar_t *) kmalloc(sizeof(condvar_t)*num_cv);
ffffffffc02050a4:	9922                	add	s2,s2,s0
    sem_init(&(mtp->next), 0);
ffffffffc02050a6:	292000ef          	jal	ra,ffffffffc0205338 <sem_init>
    mtp->cv =(condvar_t *) kmalloc(sizeof(condvar_t)*num_cv);
ffffffffc02050aa:	090e                	slli	s2,s2,0x3
ffffffffc02050ac:	854a                	mv	a0,s2
ffffffffc02050ae:	bb5fc0ef          	jal	ra,ffffffffc0201c62 <kmalloc>
ffffffffc02050b2:	fc88                	sd	a0,56(s1)
    assert(mtp->cv!=NULL);
ffffffffc02050b4:	4401                	li	s0,0
ffffffffc02050b6:	c521                	beqz	a0,ffffffffc02050fe <monitor_init+0x82>
    for(i=0; i<num_cv; i++){
        mtp->cv[i].count=0;
ffffffffc02050b8:	9522                	add	a0,a0,s0
ffffffffc02050ba:	00052c23          	sw	zero,24(a0)
        sem_init(&(mtp->cv[i].sem),0);
ffffffffc02050be:	4581                	li	a1,0
ffffffffc02050c0:	278000ef          	jal	ra,ffffffffc0205338 <sem_init>
        mtp->cv[i].owner=mtp;
ffffffffc02050c4:	7c88                	ld	a0,56(s1)
ffffffffc02050c6:	008507b3          	add	a5,a0,s0
ffffffffc02050ca:	f384                	sd	s1,32(a5)
ffffffffc02050cc:	02840413          	addi	s0,s0,40
    for(i=0; i<num_cv; i++){
ffffffffc02050d0:	fe8914e3          	bne	s2,s0,ffffffffc02050b8 <monitor_init+0x3c>
    }
}
ffffffffc02050d4:	60e2                	ld	ra,24(sp)
ffffffffc02050d6:	6442                	ld	s0,16(sp)
ffffffffc02050d8:	64a2                	ld	s1,8(sp)
ffffffffc02050da:	6902                	ld	s2,0(sp)
ffffffffc02050dc:	6105                	addi	sp,sp,32
ffffffffc02050de:	8082                	ret
    assert(num_cv>0);
ffffffffc02050e0:	00004697          	auipc	a3,0x4
ffffffffc02050e4:	5c868693          	addi	a3,a3,1480 # ffffffffc02096a8 <default_pmm_manager+0x1420>
ffffffffc02050e8:	00003617          	auipc	a2,0x3
ffffffffc02050ec:	a5860613          	addi	a2,a2,-1448 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02050f0:	45ad                	li	a1,11
ffffffffc02050f2:	00004517          	auipc	a0,0x4
ffffffffc02050f6:	5c650513          	addi	a0,a0,1478 # ffffffffc02096b8 <default_pmm_manager+0x1430>
ffffffffc02050fa:	b8efb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(mtp->cv!=NULL);
ffffffffc02050fe:	00004697          	auipc	a3,0x4
ffffffffc0205102:	5d268693          	addi	a3,a3,1490 # ffffffffc02096d0 <default_pmm_manager+0x1448>
ffffffffc0205106:	00003617          	auipc	a2,0x3
ffffffffc020510a:	a3a60613          	addi	a2,a2,-1478 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020510e:	45c5                	li	a1,17
ffffffffc0205110:	00004517          	auipc	a0,0x4
ffffffffc0205114:	5a850513          	addi	a0,a0,1448 # ffffffffc02096b8 <default_pmm_manager+0x1430>
ffffffffc0205118:	b70fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020511c <monitor_free>:

// Free monitor.
void
monitor_free (monitor_t * mtp, size_t num_cv) {
    kfree(mtp->cv);
ffffffffc020511c:	7d08                	ld	a0,56(a0)
ffffffffc020511e:	c01fc06f          	j	ffffffffc0201d1e <kfree>

ffffffffc0205122 <cond_signal>:

// Unlock one of threads waiting on the condition variable. 
void 
cond_signal (condvar_t *cvp) {
   //LAB7 EXERCISE: YOUR CODE
   cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
ffffffffc0205122:	711c                	ld	a5,32(a0)
ffffffffc0205124:	4d10                	lw	a2,24(a0)
cond_signal (condvar_t *cvp) {
ffffffffc0205126:	1141                	addi	sp,sp,-16
   cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
ffffffffc0205128:	5b94                	lw	a3,48(a5)
cond_signal (condvar_t *cvp) {
ffffffffc020512a:	e022                	sd	s0,0(sp)
   cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
ffffffffc020512c:	85aa                	mv	a1,a0
cond_signal (condvar_t *cvp) {
ffffffffc020512e:	842a                	mv	s0,a0
   cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
ffffffffc0205130:	00004517          	auipc	a0,0x4
ffffffffc0205134:	45850513          	addi	a0,a0,1112 # ffffffffc0209588 <default_pmm_manager+0x1300>
cond_signal (condvar_t *cvp) {
ffffffffc0205138:	e406                	sd	ra,8(sp)
   cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
ffffffffc020513a:	858fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
   *             mt.next_count--;
   *          }
   *       }
   */
    //如果不存在线程正在等待带释放的条件变量，则不执行任何操作，否则，对传入条件变量内置的信号执行操作。
    if(cvp->count>0) {
ffffffffc020513e:	4c10                	lw	a2,24(s0)
ffffffffc0205140:	00c04e63          	bgtz	a2,ffffffffc020515c <cond_signal+0x3a>
ffffffffc0205144:	701c                	ld	a5,32(s0)
            cvp->owner->next_count ++;//增加next_count
            up(&(cvp->sem));//增加信号量
            down(&(cvp->owner->next));//减少next信号量
            cvp->owner->next_count --;//减少next_count
    }
   cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc0205146:	85a2                	mv	a1,s0
}
ffffffffc0205148:	6402                	ld	s0,0(sp)
ffffffffc020514a:	60a2                	ld	ra,8(sp)
ffffffffc020514c:	5b94                	lw	a3,48(a5)
   cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc020514e:	00004517          	auipc	a0,0x4
ffffffffc0205152:	48250513          	addi	a0,a0,1154 # ffffffffc02095d0 <default_pmm_manager+0x1348>
}
ffffffffc0205156:	0141                	addi	sp,sp,16
   cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc0205158:	83afb06f          	j	ffffffffc0200192 <cprintf>
            cvp->owner->next_count ++;//增加next_count
ffffffffc020515c:	7018                	ld	a4,32(s0)
            up(&(cvp->sem));//增加信号量
ffffffffc020515e:	8522                	mv	a0,s0
            cvp->owner->next_count ++;//增加next_count
ffffffffc0205160:	5b1c                	lw	a5,48(a4)
ffffffffc0205162:	2785                	addiw	a5,a5,1
ffffffffc0205164:	db1c                	sw	a5,48(a4)
            up(&(cvp->sem));//增加信号量
ffffffffc0205166:	1da000ef          	jal	ra,ffffffffc0205340 <up>
            down(&(cvp->owner->next));//减少next信号量
ffffffffc020516a:	7008                	ld	a0,32(s0)
ffffffffc020516c:	0561                	addi	a0,a0,24
ffffffffc020516e:	1d6000ef          	jal	ra,ffffffffc0205344 <down>
            cvp->owner->next_count --;//减少next_count
ffffffffc0205172:	7018                	ld	a4,32(s0)
ffffffffc0205174:	4c10                	lw	a2,24(s0)
   cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc0205176:	85a2                	mv	a1,s0
            cvp->owner->next_count --;//减少next_count
ffffffffc0205178:	5b1c                	lw	a5,48(a4)
}
ffffffffc020517a:	6402                	ld	s0,0(sp)
ffffffffc020517c:	60a2                	ld	ra,8(sp)
            cvp->owner->next_count --;//减少next_count
ffffffffc020517e:	fff7869b          	addiw	a3,a5,-1
ffffffffc0205182:	db14                	sw	a3,48(a4)
   cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc0205184:	00004517          	auipc	a0,0x4
ffffffffc0205188:	44c50513          	addi	a0,a0,1100 # ffffffffc02095d0 <default_pmm_manager+0x1348>
}
ffffffffc020518c:	0141                	addi	sp,sp,16
   cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc020518e:	804fb06f          	j	ffffffffc0200192 <cprintf>

ffffffffc0205192 <cond_wait>:
// Suspend calling thread on a condition variable waiting for condition Atomically unlocks 
// mutex and suspends calling thread on conditional variable after waking up locks mutex. Notice: mp is mutex semaphore for monitor's procedures
void
cond_wait (condvar_t *cvp) {
    //LAB7 EXERCISE: YOUR CODE
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc0205192:	711c                	ld	a5,32(a0)
ffffffffc0205194:	4d10                	lw	a2,24(a0)
cond_wait (condvar_t *cvp) {
ffffffffc0205196:	1141                	addi	sp,sp,-16
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc0205198:	5b94                	lw	a3,48(a5)
cond_wait (condvar_t *cvp) {
ffffffffc020519a:	e022                	sd	s0,0(sp)
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc020519c:	85aa                	mv	a1,a0
cond_wait (condvar_t *cvp) {
ffffffffc020519e:	842a                	mv	s0,a0
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc02051a0:	00004517          	auipc	a0,0x4
ffffffffc02051a4:	47850513          	addi	a0,a0,1144 # ffffffffc0209618 <default_pmm_manager+0x1390>
cond_wait (condvar_t *cvp) {
ffffffffc02051a8:	e406                	sd	ra,8(sp)
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc02051aa:	fe9fa0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *         wait(cv.sem);
    *         cv.count --;
    */
    //当某个线程因为等待条件变量而准备将自身挂起前，此时条件变量中的count变量应自增1。
    cvp->count++;
    if(cvp->owner->next_count > 0)
ffffffffc02051ae:	7008                	ld	a0,32(s0)
    cvp->count++;
ffffffffc02051b0:	4c1c                	lw	a5,24(s0)
    if(cvp->owner->next_count > 0)
ffffffffc02051b2:	5918                	lw	a4,48(a0)
    cvp->count++;
ffffffffc02051b4:	2785                	addiw	a5,a5,1
ffffffffc02051b6:	cc1c                	sw	a5,24(s0)
    if(cvp->owner->next_count > 0)
ffffffffc02051b8:	02e05763          	blez	a4,ffffffffc02051e6 <cond_wait+0x54>
        up(&(cvp->owner->next));
ffffffffc02051bc:	0561                	addi	a0,a0,24
ffffffffc02051be:	182000ef          	jal	ra,ffffffffc0205340 <up>
    else
        up(&(cvp->owner->mutex));
    //之后当前进程应该释放所等待的条件变量所属的管程互斥锁，以便于让其他线程执行管程代码。但如果存在一个已经在管程中、但因为执行cond_signal而挂起的线程，则优先继续执行该线程。
    down(&(cvp->sem));
ffffffffc02051c2:	8522                	mv	a0,s0
ffffffffc02051c4:	180000ef          	jal	ra,ffffffffc0205344 <down>
    cvp->count--;
ffffffffc02051c8:	4c10                	lw	a2,24(s0)
    //释放管程后，尝试获取该条件变量。如果获取失败，则当前线程将在down函数的内部被挂起，然后将等待条件变量的线程数量-1
    cprintf("cond_wait end:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc02051ca:	701c                	ld	a5,32(s0)
ffffffffc02051cc:	85a2                	mv	a1,s0
    cvp->count--;
ffffffffc02051ce:	367d                	addiw	a2,a2,-1
    cprintf("cond_wait end:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc02051d0:	5b94                	lw	a3,48(a5)
    cvp->count--;
ffffffffc02051d2:	cc10                	sw	a2,24(s0)
}
ffffffffc02051d4:	6402                	ld	s0,0(sp)
ffffffffc02051d6:	60a2                	ld	ra,8(sp)
    cprintf("cond_wait end:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc02051d8:	00004517          	auipc	a0,0x4
ffffffffc02051dc:	48850513          	addi	a0,a0,1160 # ffffffffc0209660 <default_pmm_manager+0x13d8>
}
ffffffffc02051e0:	0141                	addi	sp,sp,16
    cprintf("cond_wait end:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc02051e2:	fb1fa06f          	j	ffffffffc0200192 <cprintf>
        up(&(cvp->owner->mutex));
ffffffffc02051e6:	15a000ef          	jal	ra,ffffffffc0205340 <up>
ffffffffc02051ea:	bfe1                	j	ffffffffc02051c2 <cond_wait+0x30>

ffffffffc02051ec <__down.constprop.0>:
        }
    }
    local_intr_restore(intr_flag);
}

static __noinline uint32_t __down(semaphore_t *sem, uint32_t wait_state) {
ffffffffc02051ec:	711d                	addi	sp,sp,-96
ffffffffc02051ee:	ec86                	sd	ra,88(sp)
ffffffffc02051f0:	e8a2                	sd	s0,80(sp)
ffffffffc02051f2:	e4a6                	sd	s1,72(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02051f4:	100027f3          	csrr	a5,sstatus
ffffffffc02051f8:	8b89                	andi	a5,a5,2
ffffffffc02051fa:	ebb1                	bnez	a5,ffffffffc020524e <__down.constprop.0+0x62>
    bool intr_flag;
    local_intr_save(intr_flag);
    if (sem->value > 0) {
ffffffffc02051fc:	411c                	lw	a5,0(a0)
ffffffffc02051fe:	00f05a63          	blez	a5,ffffffffc0205212 <__down.constprop.0+0x26>
        sem->value --;
ffffffffc0205202:	37fd                	addiw	a5,a5,-1
ffffffffc0205204:	c11c                	sw	a5,0(a0)
        local_intr_restore(intr_flag);
        return 0;
ffffffffc0205206:	4501                	li	a0,0

    if (wait->wakeup_flags != wait_state) {
        return wait->wakeup_flags;
    }
    return 0;
}
ffffffffc0205208:	60e6                	ld	ra,88(sp)
ffffffffc020520a:	6446                	ld	s0,80(sp)
ffffffffc020520c:	64a6                	ld	s1,72(sp)
ffffffffc020520e:	6125                	addi	sp,sp,96
ffffffffc0205210:	8082                	ret
    wait_current_set(&(sem->wait_queue), wait, wait_state);
ffffffffc0205212:	00850413          	addi	s0,a0,8
ffffffffc0205216:	0824                	addi	s1,sp,24
ffffffffc0205218:	10000613          	li	a2,256
ffffffffc020521c:	85a6                	mv	a1,s1
ffffffffc020521e:	8522                	mv	a0,s0
ffffffffc0205220:	1ec000ef          	jal	ra,ffffffffc020540c <wait_current_set>
    schedule();
ffffffffc0205224:	1e7010ef          	jal	ra,ffffffffc0206c0a <schedule>
ffffffffc0205228:	100027f3          	csrr	a5,sstatus
ffffffffc020522c:	8b89                	andi	a5,a5,2
ffffffffc020522e:	e3b5                	bnez	a5,ffffffffc0205292 <__down.constprop.0+0xa6>
    wait_current_del(&(sem->wait_queue), wait);
ffffffffc0205230:	8526                	mv	a0,s1
ffffffffc0205232:	1a0000ef          	jal	ra,ffffffffc02053d2 <wait_in_queue>
ffffffffc0205236:	e929                	bnez	a0,ffffffffc0205288 <__down.constprop.0+0x9c>
    if (wait->wakeup_flags != wait_state) {
ffffffffc0205238:	5502                	lw	a0,32(sp)
ffffffffc020523a:	10000793          	li	a5,256
ffffffffc020523e:	fcf515e3          	bne	a0,a5,ffffffffc0205208 <__down.constprop.0+0x1c>
}
ffffffffc0205242:	60e6                	ld	ra,88(sp)
ffffffffc0205244:	6446                	ld	s0,80(sp)
ffffffffc0205246:	64a6                	ld	s1,72(sp)
    return 0;
ffffffffc0205248:	4501                	li	a0,0
}
ffffffffc020524a:	6125                	addi	sp,sp,96
ffffffffc020524c:	8082                	ret
ffffffffc020524e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0205250:	c02fb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
    if (sem->value > 0) {
ffffffffc0205254:	6522                	ld	a0,8(sp)
ffffffffc0205256:	411c                	lw	a5,0(a0)
ffffffffc0205258:	00f05c63          	blez	a5,ffffffffc0205270 <__down.constprop.0+0x84>
        sem->value --;
ffffffffc020525c:	37fd                	addiw	a5,a5,-1
ffffffffc020525e:	c11c                	sw	a5,0(a0)
        intr_enable();
ffffffffc0205260:	becfb0ef          	jal	ra,ffffffffc020064c <intr_enable>
}
ffffffffc0205264:	60e6                	ld	ra,88(sp)
ffffffffc0205266:	6446                	ld	s0,80(sp)
ffffffffc0205268:	64a6                	ld	s1,72(sp)
        return 0;
ffffffffc020526a:	4501                	li	a0,0
}
ffffffffc020526c:	6125                	addi	sp,sp,96
ffffffffc020526e:	8082                	ret
    wait_current_set(&(sem->wait_queue), wait, wait_state);
ffffffffc0205270:	00850413          	addi	s0,a0,8
ffffffffc0205274:	0824                	addi	s1,sp,24
ffffffffc0205276:	10000613          	li	a2,256
ffffffffc020527a:	85a6                	mv	a1,s1
ffffffffc020527c:	8522                	mv	a0,s0
ffffffffc020527e:	18e000ef          	jal	ra,ffffffffc020540c <wait_current_set>
ffffffffc0205282:	bcafb0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0205286:	bf79                	j	ffffffffc0205224 <__down.constprop.0+0x38>
    wait_current_del(&(sem->wait_queue), wait);
ffffffffc0205288:	85a6                	mv	a1,s1
ffffffffc020528a:	8522                	mv	a0,s0
ffffffffc020528c:	112000ef          	jal	ra,ffffffffc020539e <wait_queue_del>
    if (flag) {
ffffffffc0205290:	b765                	j	ffffffffc0205238 <__down.constprop.0+0x4c>
        intr_disable();
ffffffffc0205292:	bc0fb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0205296:	8526                	mv	a0,s1
ffffffffc0205298:	13a000ef          	jal	ra,ffffffffc02053d2 <wait_in_queue>
ffffffffc020529c:	e501                	bnez	a0,ffffffffc02052a4 <__down.constprop.0+0xb8>
        intr_enable();
ffffffffc020529e:	baefb0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc02052a2:	bf59                	j	ffffffffc0205238 <__down.constprop.0+0x4c>
ffffffffc02052a4:	85a6                	mv	a1,s1
ffffffffc02052a6:	8522                	mv	a0,s0
ffffffffc02052a8:	0f6000ef          	jal	ra,ffffffffc020539e <wait_queue_del>
    if (flag) {
ffffffffc02052ac:	bfcd                	j	ffffffffc020529e <__down.constprop.0+0xb2>

ffffffffc02052ae <__up.constprop.1>:
static __noinline void __up(semaphore_t *sem, uint32_t wait_state) {
ffffffffc02052ae:	1101                	addi	sp,sp,-32
ffffffffc02052b0:	e426                	sd	s1,8(sp)
ffffffffc02052b2:	ec06                	sd	ra,24(sp)
ffffffffc02052b4:	e822                	sd	s0,16(sp)
ffffffffc02052b6:	e04a                	sd	s2,0(sp)
ffffffffc02052b8:	84aa                	mv	s1,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02052ba:	100027f3          	csrr	a5,sstatus
ffffffffc02052be:	8b89                	andi	a5,a5,2
ffffffffc02052c0:	4901                	li	s2,0
ffffffffc02052c2:	eba1                	bnez	a5,ffffffffc0205312 <__up.constprop.1+0x64>
        if ((wait = wait_queue_first(&(sem->wait_queue))) == NULL) {
ffffffffc02052c4:	00848413          	addi	s0,s1,8
ffffffffc02052c8:	8522                	mv	a0,s0
ffffffffc02052ca:	0f8000ef          	jal	ra,ffffffffc02053c2 <wait_queue_first>
ffffffffc02052ce:	cd15                	beqz	a0,ffffffffc020530a <__up.constprop.1+0x5c>
            assert(wait->proc->wait_state == wait_state);
ffffffffc02052d0:	6118                	ld	a4,0(a0)
ffffffffc02052d2:	10000793          	li	a5,256
ffffffffc02052d6:	0ec72703          	lw	a4,236(a4)
ffffffffc02052da:	04f71063          	bne	a4,a5,ffffffffc020531a <__up.constprop.1+0x6c>
            wakeup_wait(&(sem->wait_queue), wait, wait_state, 1);
ffffffffc02052de:	85aa                	mv	a1,a0
ffffffffc02052e0:	4685                	li	a3,1
ffffffffc02052e2:	10000613          	li	a2,256
ffffffffc02052e6:	8522                	mv	a0,s0
ffffffffc02052e8:	0f8000ef          	jal	ra,ffffffffc02053e0 <wakeup_wait>
    if (flag) {
ffffffffc02052ec:	00091863          	bnez	s2,ffffffffc02052fc <__up.constprop.1+0x4e>
}
ffffffffc02052f0:	60e2                	ld	ra,24(sp)
ffffffffc02052f2:	6442                	ld	s0,16(sp)
ffffffffc02052f4:	64a2                	ld	s1,8(sp)
ffffffffc02052f6:	6902                	ld	s2,0(sp)
ffffffffc02052f8:	6105                	addi	sp,sp,32
ffffffffc02052fa:	8082                	ret
ffffffffc02052fc:	6442                	ld	s0,16(sp)
ffffffffc02052fe:	60e2                	ld	ra,24(sp)
ffffffffc0205300:	64a2                	ld	s1,8(sp)
ffffffffc0205302:	6902                	ld	s2,0(sp)
ffffffffc0205304:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205306:	b46fb06f          	j	ffffffffc020064c <intr_enable>
            sem->value ++;
ffffffffc020530a:	409c                	lw	a5,0(s1)
ffffffffc020530c:	2785                	addiw	a5,a5,1
ffffffffc020530e:	c09c                	sw	a5,0(s1)
ffffffffc0205310:	bff1                	j	ffffffffc02052ec <__up.constprop.1+0x3e>
        intr_disable();
ffffffffc0205312:	b40fb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0205316:	4905                	li	s2,1
ffffffffc0205318:	b775                	j	ffffffffc02052c4 <__up.constprop.1+0x16>
            assert(wait->proc->wait_state == wait_state);
ffffffffc020531a:	00004697          	auipc	a3,0x4
ffffffffc020531e:	3c668693          	addi	a3,a3,966 # ffffffffc02096e0 <default_pmm_manager+0x1458>
ffffffffc0205322:	00003617          	auipc	a2,0x3
ffffffffc0205326:	81e60613          	addi	a2,a2,-2018 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020532a:	45e5                	li	a1,25
ffffffffc020532c:	00004517          	auipc	a0,0x4
ffffffffc0205330:	3dc50513          	addi	a0,a0,988 # ffffffffc0209708 <default_pmm_manager+0x1480>
ffffffffc0205334:	954fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0205338 <sem_init>:
    sem->value = value;
ffffffffc0205338:	c10c                	sw	a1,0(a0)
    wait_queue_init(&(sem->wait_queue));
ffffffffc020533a:	0521                	addi	a0,a0,8
ffffffffc020533c:	05c0006f          	j	ffffffffc0205398 <wait_queue_init>

ffffffffc0205340 <up>:

void
up(semaphore_t *sem) {
    __up(sem, WT_KSEM);
ffffffffc0205340:	f6fff06f          	j	ffffffffc02052ae <__up.constprop.1>

ffffffffc0205344 <down>:
}

void
down(semaphore_t *sem) {
ffffffffc0205344:	1141                	addi	sp,sp,-16
ffffffffc0205346:	e406                	sd	ra,8(sp)
    uint32_t flags = __down(sem, WT_KSEM);
ffffffffc0205348:	ea5ff0ef          	jal	ra,ffffffffc02051ec <__down.constprop.0>
ffffffffc020534c:	2501                	sext.w	a0,a0
    assert(flags == 0);
ffffffffc020534e:	e501                	bnez	a0,ffffffffc0205356 <down+0x12>
}
ffffffffc0205350:	60a2                	ld	ra,8(sp)
ffffffffc0205352:	0141                	addi	sp,sp,16
ffffffffc0205354:	8082                	ret
    assert(flags == 0);
ffffffffc0205356:	00004697          	auipc	a3,0x4
ffffffffc020535a:	3c268693          	addi	a3,a3,962 # ffffffffc0209718 <default_pmm_manager+0x1490>
ffffffffc020535e:	00002617          	auipc	a2,0x2
ffffffffc0205362:	7e260613          	addi	a2,a2,2018 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0205366:	04000593          	li	a1,64
ffffffffc020536a:	00004517          	auipc	a0,0x4
ffffffffc020536e:	39e50513          	addi	a0,a0,926 # ffffffffc0209708 <default_pmm_manager+0x1480>
ffffffffc0205372:	916fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0205376 <wait_queue_del.part.1>:
    wait->wait_queue = queue;
    list_add_before(&(queue->wait_head), &(wait->wait_link));
}

void
wait_queue_del(wait_queue_t *queue, wait_t *wait) {
ffffffffc0205376:	1141                	addi	sp,sp,-16
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
ffffffffc0205378:	00004697          	auipc	a3,0x4
ffffffffc020537c:	3c068693          	addi	a3,a3,960 # ffffffffc0209738 <default_pmm_manager+0x14b0>
ffffffffc0205380:	00002617          	auipc	a2,0x2
ffffffffc0205384:	7c060613          	addi	a2,a2,1984 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0205388:	45f1                	li	a1,28
ffffffffc020538a:	00004517          	auipc	a0,0x4
ffffffffc020538e:	3ee50513          	addi	a0,a0,1006 # ffffffffc0209778 <default_pmm_manager+0x14f0>
wait_queue_del(wait_queue_t *queue, wait_t *wait) {
ffffffffc0205392:	e406                	sd	ra,8(sp)
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
ffffffffc0205394:	8f4fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0205398 <wait_queue_init>:
    elm->prev = elm->next = elm;
ffffffffc0205398:	e508                	sd	a0,8(a0)
ffffffffc020539a:	e108                	sd	a0,0(a0)
}
ffffffffc020539c:	8082                	ret

ffffffffc020539e <wait_queue_del>:
    return list->next == list;
ffffffffc020539e:	7198                	ld	a4,32(a1)
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
ffffffffc02053a0:	01858793          	addi	a5,a1,24
ffffffffc02053a4:	00e78b63          	beq	a5,a4,ffffffffc02053ba <wait_queue_del+0x1c>
ffffffffc02053a8:	6994                	ld	a3,16(a1)
ffffffffc02053aa:	00a69863          	bne	a3,a0,ffffffffc02053ba <wait_queue_del+0x1c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02053ae:	6d94                	ld	a3,24(a1)
    prev->next = next;
ffffffffc02053b0:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02053b2:	e314                	sd	a3,0(a4)
    elm->prev = elm->next = elm;
ffffffffc02053b4:	f19c                	sd	a5,32(a1)
ffffffffc02053b6:	ed9c                	sd	a5,24(a1)
ffffffffc02053b8:	8082                	ret
wait_queue_del(wait_queue_t *queue, wait_t *wait) {
ffffffffc02053ba:	1141                	addi	sp,sp,-16
ffffffffc02053bc:	e406                	sd	ra,8(sp)
ffffffffc02053be:	fb9ff0ef          	jal	ra,ffffffffc0205376 <wait_queue_del.part.1>

ffffffffc02053c2 <wait_queue_first>:
    return listelm->next;
ffffffffc02053c2:	651c                	ld	a5,8(a0)
}

wait_t *
wait_queue_first(wait_queue_t *queue) {
    list_entry_t *le = list_next(&(queue->wait_head));
    if (le != &(queue->wait_head)) {
ffffffffc02053c4:	00f50563          	beq	a0,a5,ffffffffc02053ce <wait_queue_first+0xc>
        return le2wait(le, wait_link);
ffffffffc02053c8:	fe878513          	addi	a0,a5,-24
ffffffffc02053cc:	8082                	ret
    }
    return NULL;
ffffffffc02053ce:	4501                	li	a0,0
}
ffffffffc02053d0:	8082                	ret

ffffffffc02053d2 <wait_in_queue>:
    return list_empty(&(queue->wait_head));
}

bool
wait_in_queue(wait_t *wait) {
    return !list_empty(&(wait->wait_link));
ffffffffc02053d2:	711c                	ld	a5,32(a0)
ffffffffc02053d4:	0561                	addi	a0,a0,24
ffffffffc02053d6:	40a78533          	sub	a0,a5,a0
}
ffffffffc02053da:	00a03533          	snez	a0,a0
ffffffffc02053de:	8082                	ret

ffffffffc02053e0 <wakeup_wait>:

void
wakeup_wait(wait_queue_t *queue, wait_t *wait, uint32_t wakeup_flags, bool del) {
    if (del) {
ffffffffc02053e0:	ce91                	beqz	a3,ffffffffc02053fc <wakeup_wait+0x1c>
    return list->next == list;
ffffffffc02053e2:	7198                	ld	a4,32(a1)
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
ffffffffc02053e4:	01858793          	addi	a5,a1,24
ffffffffc02053e8:	00e78e63          	beq	a5,a4,ffffffffc0205404 <wakeup_wait+0x24>
ffffffffc02053ec:	6994                	ld	a3,16(a1)
ffffffffc02053ee:	00d51b63          	bne	a0,a3,ffffffffc0205404 <wakeup_wait+0x24>
    __list_del(listelm->prev, listelm->next);
ffffffffc02053f2:	6d94                	ld	a3,24(a1)
    prev->next = next;
ffffffffc02053f4:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02053f6:	e314                	sd	a3,0(a4)
    elm->prev = elm->next = elm;
ffffffffc02053f8:	f19c                	sd	a5,32(a1)
ffffffffc02053fa:	ed9c                	sd	a5,24(a1)
        wait_queue_del(queue, wait);
    }
    wait->wakeup_flags = wakeup_flags;
    wakeup_proc(wait->proc);
ffffffffc02053fc:	6188                	ld	a0,0(a1)
    wait->wakeup_flags = wakeup_flags;
ffffffffc02053fe:	c590                	sw	a2,8(a1)
    wakeup_proc(wait->proc);
ffffffffc0205400:	7500106f          	j	ffffffffc0206b50 <wakeup_proc>
wakeup_wait(wait_queue_t *queue, wait_t *wait, uint32_t wakeup_flags, bool del) {
ffffffffc0205404:	1141                	addi	sp,sp,-16
ffffffffc0205406:	e406                	sd	ra,8(sp)
ffffffffc0205408:	f6fff0ef          	jal	ra,ffffffffc0205376 <wait_queue_del.part.1>

ffffffffc020540c <wait_current_set>:
    }
}

void
wait_current_set(wait_queue_t *queue, wait_t *wait, uint32_t wait_state) {
    assert(current != NULL);
ffffffffc020540c:	000da797          	auipc	a5,0xda
ffffffffc0205410:	f5478793          	addi	a5,a5,-172 # ffffffffc02df360 <current>
ffffffffc0205414:	639c                	ld	a5,0(a5)
ffffffffc0205416:	c39d                	beqz	a5,ffffffffc020543c <wait_current_set+0x30>
    list_init(&(wait->wait_link));
ffffffffc0205418:	01858713          	addi	a4,a1,24
    wait->wakeup_flags = WT_INTERRUPTED;
ffffffffc020541c:	800006b7          	lui	a3,0x80000
ffffffffc0205420:	ed98                	sd	a4,24(a1)
    wait->proc = proc;
ffffffffc0205422:	e19c                	sd	a5,0(a1)
    wait->wakeup_flags = WT_INTERRUPTED;
ffffffffc0205424:	c594                	sw	a3,8(a1)
    wait_init(wait, current);
    current->state = PROC_SLEEPING;
ffffffffc0205426:	4685                	li	a3,1
ffffffffc0205428:	c394                	sw	a3,0(a5)
    current->wait_state = wait_state;
ffffffffc020542a:	0ec7a623          	sw	a2,236(a5)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020542e:	611c                	ld	a5,0(a0)
    wait->wait_queue = queue;
ffffffffc0205430:	e988                	sd	a0,16(a1)
    prev->next = next->prev = elm;
ffffffffc0205432:	e118                	sd	a4,0(a0)
ffffffffc0205434:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0205436:	f188                	sd	a0,32(a1)
    elm->prev = prev;
ffffffffc0205438:	ed9c                	sd	a5,24(a1)
ffffffffc020543a:	8082                	ret
wait_current_set(wait_queue_t *queue, wait_t *wait, uint32_t wait_state) {
ffffffffc020543c:	1141                	addi	sp,sp,-16
    assert(current != NULL);
ffffffffc020543e:	00004697          	auipc	a3,0x4
ffffffffc0205442:	2ea68693          	addi	a3,a3,746 # ffffffffc0209728 <default_pmm_manager+0x14a0>
ffffffffc0205446:	00002617          	auipc	a2,0x2
ffffffffc020544a:	6fa60613          	addi	a2,a2,1786 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020544e:	07400593          	li	a1,116
ffffffffc0205452:	00004517          	auipc	a0,0x4
ffffffffc0205456:	32650513          	addi	a0,a0,806 # ffffffffc0209778 <default_pmm_manager+0x14f0>
wait_current_set(wait_queue_t *queue, wait_t *wait, uint32_t wait_state) {
ffffffffc020545a:	e406                	sd	ra,8(sp)
    assert(current != NULL);
ffffffffc020545c:	82cfb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0205460 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0205460:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0205462:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0205464:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0205466:	990fb0ef          	jal	ra,ffffffffc02005f6 <ide_device_valid>
ffffffffc020546a:	cd01                	beqz	a0,ffffffffc0205482 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc020546c:	4505                	li	a0,1
ffffffffc020546e:	98efb0ef          	jal	ra,ffffffffc02005fc <ide_device_size>
}
ffffffffc0205472:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0205474:	810d                	srli	a0,a0,0x3
ffffffffc0205476:	000da797          	auipc	a5,0xda
ffffffffc020547a:	fea7b123          	sd	a0,-30(a5) # ffffffffc02df458 <max_swap_offset>
}
ffffffffc020547e:	0141                	addi	sp,sp,16
ffffffffc0205480:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0205482:	00004617          	auipc	a2,0x4
ffffffffc0205486:	30e60613          	addi	a2,a2,782 # ffffffffc0209790 <default_pmm_manager+0x1508>
ffffffffc020548a:	45b5                	li	a1,13
ffffffffc020548c:	00004517          	auipc	a0,0x4
ffffffffc0205490:	32450513          	addi	a0,a0,804 # ffffffffc02097b0 <default_pmm_manager+0x1528>
ffffffffc0205494:	ff5fa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0205498 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0205498:	1141                	addi	sp,sp,-16
ffffffffc020549a:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020549c:	00855793          	srli	a5,a0,0x8
ffffffffc02054a0:	cfb9                	beqz	a5,ffffffffc02054fe <swapfs_read+0x66>
ffffffffc02054a2:	000da717          	auipc	a4,0xda
ffffffffc02054a6:	fb670713          	addi	a4,a4,-74 # ffffffffc02df458 <max_swap_offset>
ffffffffc02054aa:	6318                	ld	a4,0(a4)
ffffffffc02054ac:	04e7f963          	bleu	a4,a5,ffffffffc02054fe <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc02054b0:	000da717          	auipc	a4,0xda
ffffffffc02054b4:	f1870713          	addi	a4,a4,-232 # ffffffffc02df3c8 <pages>
ffffffffc02054b8:	6310                	ld	a2,0(a4)
ffffffffc02054ba:	00005717          	auipc	a4,0x5
ffffffffc02054be:	49670713          	addi	a4,a4,1174 # ffffffffc020a950 <nbase>
    return KADDR(page2pa(page));
ffffffffc02054c2:	000da697          	auipc	a3,0xda
ffffffffc02054c6:	e8668693          	addi	a3,a3,-378 # ffffffffc02df348 <npage>
    return page - pages + nbase;
ffffffffc02054ca:	40c58633          	sub	a2,a1,a2
ffffffffc02054ce:	630c                	ld	a1,0(a4)
ffffffffc02054d0:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc02054d2:	577d                	li	a4,-1
ffffffffc02054d4:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc02054d6:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc02054d8:	8331                	srli	a4,a4,0xc
ffffffffc02054da:	8f71                	and	a4,a4,a2
ffffffffc02054dc:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc02054e0:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc02054e2:	02d77a63          	bleu	a3,a4,ffffffffc0205516 <swapfs_read+0x7e>
ffffffffc02054e6:	000da797          	auipc	a5,0xda
ffffffffc02054ea:	ed278793          	addi	a5,a5,-302 # ffffffffc02df3b8 <va_pa_offset>
ffffffffc02054ee:	639c                	ld	a5,0(a5)
}
ffffffffc02054f0:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02054f2:	46a1                	li	a3,8
ffffffffc02054f4:	963e                	add	a2,a2,a5
ffffffffc02054f6:	4505                	li	a0,1
}
ffffffffc02054f8:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02054fa:	908fb06f          	j	ffffffffc0200602 <ide_read_secs>
ffffffffc02054fe:	86aa                	mv	a3,a0
ffffffffc0205500:	00004617          	auipc	a2,0x4
ffffffffc0205504:	2c860613          	addi	a2,a2,712 # ffffffffc02097c8 <default_pmm_manager+0x1540>
ffffffffc0205508:	45d1                	li	a1,20
ffffffffc020550a:	00004517          	auipc	a0,0x4
ffffffffc020550e:	2a650513          	addi	a0,a0,678 # ffffffffc02097b0 <default_pmm_manager+0x1528>
ffffffffc0205512:	f77fa0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0205516:	86b2                	mv	a3,a2
ffffffffc0205518:	06900593          	li	a1,105
ffffffffc020551c:	00003617          	auipc	a2,0x3
ffffffffc0205520:	dbc60613          	addi	a2,a2,-580 # ffffffffc02082d8 <default_pmm_manager+0x50>
ffffffffc0205524:	00003517          	auipc	a0,0x3
ffffffffc0205528:	ddc50513          	addi	a0,a0,-548 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc020552c:	f5dfa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0205530 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0205530:	1141                	addi	sp,sp,-16
ffffffffc0205532:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0205534:	00855793          	srli	a5,a0,0x8
ffffffffc0205538:	cfb9                	beqz	a5,ffffffffc0205596 <swapfs_write+0x66>
ffffffffc020553a:	000da717          	auipc	a4,0xda
ffffffffc020553e:	f1e70713          	addi	a4,a4,-226 # ffffffffc02df458 <max_swap_offset>
ffffffffc0205542:	6318                	ld	a4,0(a4)
ffffffffc0205544:	04e7f963          	bleu	a4,a5,ffffffffc0205596 <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0205548:	000da717          	auipc	a4,0xda
ffffffffc020554c:	e8070713          	addi	a4,a4,-384 # ffffffffc02df3c8 <pages>
ffffffffc0205550:	6310                	ld	a2,0(a4)
ffffffffc0205552:	00005717          	auipc	a4,0x5
ffffffffc0205556:	3fe70713          	addi	a4,a4,1022 # ffffffffc020a950 <nbase>
    return KADDR(page2pa(page));
ffffffffc020555a:	000da697          	auipc	a3,0xda
ffffffffc020555e:	dee68693          	addi	a3,a3,-530 # ffffffffc02df348 <npage>
    return page - pages + nbase;
ffffffffc0205562:	40c58633          	sub	a2,a1,a2
ffffffffc0205566:	630c                	ld	a1,0(a4)
ffffffffc0205568:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc020556a:	577d                	li	a4,-1
ffffffffc020556c:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc020556e:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0205570:	8331                	srli	a4,a4,0xc
ffffffffc0205572:	8f71                	and	a4,a4,a2
ffffffffc0205574:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0205578:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc020557a:	02d77a63          	bleu	a3,a4,ffffffffc02055ae <swapfs_write+0x7e>
ffffffffc020557e:	000da797          	auipc	a5,0xda
ffffffffc0205582:	e3a78793          	addi	a5,a5,-454 # ffffffffc02df3b8 <va_pa_offset>
ffffffffc0205586:	639c                	ld	a5,0(a5)
}
ffffffffc0205588:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020558a:	46a1                	li	a3,8
ffffffffc020558c:	963e                	add	a2,a2,a5
ffffffffc020558e:	4505                	li	a0,1
}
ffffffffc0205590:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0205592:	894fb06f          	j	ffffffffc0200626 <ide_write_secs>
ffffffffc0205596:	86aa                	mv	a3,a0
ffffffffc0205598:	00004617          	auipc	a2,0x4
ffffffffc020559c:	23060613          	addi	a2,a2,560 # ffffffffc02097c8 <default_pmm_manager+0x1540>
ffffffffc02055a0:	45e5                	li	a1,25
ffffffffc02055a2:	00004517          	auipc	a0,0x4
ffffffffc02055a6:	20e50513          	addi	a0,a0,526 # ffffffffc02097b0 <default_pmm_manager+0x1528>
ffffffffc02055aa:	edffa0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc02055ae:	86b2                	mv	a3,a2
ffffffffc02055b0:	06900593          	li	a1,105
ffffffffc02055b4:	00003617          	auipc	a2,0x3
ffffffffc02055b8:	d2460613          	addi	a2,a2,-732 # ffffffffc02082d8 <default_pmm_manager+0x50>
ffffffffc02055bc:	00003517          	auipc	a0,0x3
ffffffffc02055c0:	d4450513          	addi	a0,a0,-700 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc02055c4:	ec5fa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02055c8 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc02055c8:	8526                	mv	a0,s1
	jalr s0
ffffffffc02055ca:	9402                	jalr	s0

	jal do_exit
ffffffffc02055cc:	6ee000ef          	jal	ra,ffffffffc0205cba <do_exit>

ffffffffc02055d0 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc02055d0:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02055d2:	14800513          	li	a0,328
alloc_proc(void) {
ffffffffc02055d6:	e022                	sd	s0,0(sp)
ffffffffc02055d8:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02055da:	e88fc0ef          	jal	ra,ffffffffc0201c62 <kmalloc>
ffffffffc02055de:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc02055e0:	c149                	beqz	a0,ffffffffc0205662 <alloc_proc+0x92>
     *     skew_heap_entry_t lab6_run_pool;            // FOR LAB6 ONLY: the entry in the run pool
     *     uint32_t lab6_stride;                       // FOR LAB6 ONLY: the current stride of the process
     *     uint32_t lab6_priority;                     // FOR LAB6 ONLY: the priority of process, set by lab6_set_priority(uint32_t)
     */
        proc->rq = NULL;
        list_init(&(proc->run_link));
ffffffffc02055e2:	11050793          	addi	a5,a0,272
    elm->prev = elm->next = elm;
ffffffffc02055e6:	10f53c23          	sd	a5,280(a0)
ffffffffc02055ea:	10f53823          	sd	a5,272(a0)
        proc->time_slice = 0;
        proc->lab6_run_pool.left = proc->lab6_run_pool.right = proc->lab6_run_pool.parent = NULL;
        proc->lab6_stride = 0;
ffffffffc02055ee:	4785                	li	a5,1
ffffffffc02055f0:	1782                	slli	a5,a5,0x20
ffffffffc02055f2:	14f53023          	sd	a5,320(a0)
        proc->lab6_priority = 1;
        //
        proc->state = PROC_UNINIT;
ffffffffc02055f6:	57fd                	li	a5,-1
ffffffffc02055f8:	1782                	slli	a5,a5,0x20
ffffffffc02055fa:	e11c                	sd	a5,0(a0)
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        proc->mm = NULL; // 进程所用的虚拟内存
        memset(&(proc->context), 0, sizeof(struct context)); // 进程的上下文
ffffffffc02055fc:	07000613          	li	a2,112
ffffffffc0205600:	4581                	li	a1,0
        proc->rq = NULL;
ffffffffc0205602:	10053423          	sd	zero,264(a0)
        proc->time_slice = 0;
ffffffffc0205606:	12052023          	sw	zero,288(a0)
        proc->lab6_run_pool.left = proc->lab6_run_pool.right = proc->lab6_run_pool.parent = NULL;
ffffffffc020560a:	12053423          	sd	zero,296(a0)
ffffffffc020560e:	12053823          	sd	zero,304(a0)
ffffffffc0205612:	12053c23          	sd	zero,312(a0)
        proc->runs = 0;
ffffffffc0205616:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc020561a:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc020561e:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0205622:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0205626:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context)); // 进程的上下文
ffffffffc020562a:	03050513          	addi	a0,a0,48
ffffffffc020562e:	6f7010ef          	jal	ra,ffffffffc0207524 <memset>
        proc->tf = NULL; // 中断帧指针
        proc->cr3 = boot_cr3; // 页目录表地址 设为 内核页目录表基址
ffffffffc0205632:	000da797          	auipc	a5,0xda
ffffffffc0205636:	d8e78793          	addi	a5,a5,-626 # ffffffffc02df3c0 <boot_cr3>
ffffffffc020563a:	639c                	ld	a5,0(a5)
        proc->tf = NULL; // 中断帧指针
ffffffffc020563c:	0a043023          	sd	zero,160(s0)
        proc->flags = 0; // 标志位
ffffffffc0205640:	0a042823          	sw	zero,176(s0)
        proc->cr3 = boot_cr3; // 页目录表地址 设为 内核页目录表基址
ffffffffc0205644:	f45c                	sd	a5,168(s0)
        memset(&(proc->name), 0, PROC_NAME_LEN); // 进程名
ffffffffc0205646:	463d                	li	a2,15
ffffffffc0205648:	4581                	li	a1,0
ffffffffc020564a:	0b440513          	addi	a0,s0,180
ffffffffc020564e:	6d7010ef          	jal	ra,ffffffffc0207524 <memset>
        proc->wait_state = 0;  
ffffffffc0205652:	0e042623          	sw	zero,236(s0)
        proc->cptr = proc->optr = proc->yptr = NULL;
ffffffffc0205656:	0e043c23          	sd	zero,248(s0)
ffffffffc020565a:	10043023          	sd	zero,256(s0)
ffffffffc020565e:	0e043823          	sd	zero,240(s0)
    }
    return proc;
}
ffffffffc0205662:	8522                	mv	a0,s0
ffffffffc0205664:	60a2                	ld	ra,8(sp)
ffffffffc0205666:	6402                	ld	s0,0(sp)
ffffffffc0205668:	0141                	addi	sp,sp,16
ffffffffc020566a:	8082                	ret

ffffffffc020566c <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc020566c:	000da797          	auipc	a5,0xda
ffffffffc0205670:	cf478793          	addi	a5,a5,-780 # ffffffffc02df360 <current>
ffffffffc0205674:	639c                	ld	a5,0(a5)
ffffffffc0205676:	73c8                	ld	a0,160(a5)
ffffffffc0205678:	f3efb06f          	j	ffffffffc0200db6 <forkrets>

ffffffffc020567c <user_main>:
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    KERNEL_EXECVE(exit);
ffffffffc020567c:	000da797          	auipc	a5,0xda
ffffffffc0205680:	ce478793          	addi	a5,a5,-796 # ffffffffc02df360 <current>
ffffffffc0205684:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0205686:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE(exit);
ffffffffc0205688:	00004617          	auipc	a2,0x4
ffffffffc020568c:	54860613          	addi	a2,a2,1352 # ffffffffc0209bd0 <default_pmm_manager+0x1948>
ffffffffc0205690:	43cc                	lw	a1,4(a5)
ffffffffc0205692:	00004517          	auipc	a0,0x4
ffffffffc0205696:	54650513          	addi	a0,a0,1350 # ffffffffc0209bd8 <default_pmm_manager+0x1950>
user_main(void *arg) {
ffffffffc020569a:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE(exit);
ffffffffc020569c:	af7fa0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc02056a0:	00004797          	auipc	a5,0x4
ffffffffc02056a4:	53078793          	addi	a5,a5,1328 # ffffffffc0209bd0 <default_pmm_manager+0x1948>
ffffffffc02056a8:	3fe06717          	auipc	a4,0x3fe06
ffffffffc02056ac:	94070713          	addi	a4,a4,-1728 # afe8 <_binary_obj___user_exit_out_size>
ffffffffc02056b0:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc02056b2:	853e                	mv	a0,a5
ffffffffc02056b4:	00028717          	auipc	a4,0x28
ffffffffc02056b8:	afc70713          	addi	a4,a4,-1284 # ffffffffc022d1b0 <_binary_obj___user_exit_out_start>
ffffffffc02056bc:	f03a                	sd	a4,32(sp)
ffffffffc02056be:	f43e                	sd	a5,40(sp)
ffffffffc02056c0:	e802                	sd	zero,16(sp)
ffffffffc02056c2:	5c5010ef          	jal	ra,ffffffffc0207486 <strlen>
ffffffffc02056c6:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc02056c8:	4511                	li	a0,4
ffffffffc02056ca:	75a2                	ld	a1,40(sp)
ffffffffc02056cc:	6662                	ld	a2,24(sp)
ffffffffc02056ce:	7682                	ld	a3,32(sp)
ffffffffc02056d0:	6722                	ld	a4,8(sp)
ffffffffc02056d2:	48a9                	li	a7,10
ffffffffc02056d4:	9002                	ebreak
ffffffffc02056d6:	e82a                	sd	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc02056d8:	65c2                	ld	a1,16(sp)
ffffffffc02056da:	00004517          	auipc	a0,0x4
ffffffffc02056de:	52650513          	addi	a0,a0,1318 # ffffffffc0209c00 <default_pmm_manager+0x1978>
ffffffffc02056e2:	ab1fa0ef          	jal	ra,ffffffffc0200192 <cprintf>
#endif
    panic("user_main execve failed.\n");
ffffffffc02056e6:	00004617          	auipc	a2,0x4
ffffffffc02056ea:	52a60613          	addi	a2,a2,1322 # ffffffffc0209c10 <default_pmm_manager+0x1988>
ffffffffc02056ee:	36500593          	li	a1,869
ffffffffc02056f2:	00004517          	auipc	a0,0x4
ffffffffc02056f6:	53e50513          	addi	a0,a0,1342 # ffffffffc0209c30 <default_pmm_manager+0x19a8>
ffffffffc02056fa:	d8ffa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02056fe <setup_pgdir.isra.2>:
setup_pgdir(struct mm_struct *mm) {
ffffffffc02056fe:	1101                	addi	sp,sp,-32
ffffffffc0205700:	e426                	sd	s1,8(sp)
ffffffffc0205702:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL) {
ffffffffc0205704:	4505                	li	a0,1
setup_pgdir(struct mm_struct *mm) {
ffffffffc0205706:	ec06                	sd	ra,24(sp)
ffffffffc0205708:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL) {
ffffffffc020570a:	f54fc0ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc020570e:	c125                	beqz	a0,ffffffffc020576e <setup_pgdir.isra.2+0x70>
    return page - pages + nbase;
ffffffffc0205710:	000da797          	auipc	a5,0xda
ffffffffc0205714:	cb878793          	addi	a5,a5,-840 # ffffffffc02df3c8 <pages>
ffffffffc0205718:	6394                	ld	a3,0(a5)
ffffffffc020571a:	00005797          	auipc	a5,0x5
ffffffffc020571e:	23678793          	addi	a5,a5,566 # ffffffffc020a950 <nbase>
ffffffffc0205722:	6380                	ld	s0,0(a5)
ffffffffc0205724:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0205728:	000da717          	auipc	a4,0xda
ffffffffc020572c:	c2070713          	addi	a4,a4,-992 # ffffffffc02df348 <npage>
    return page - pages + nbase;
ffffffffc0205730:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205732:	57fd                	li	a5,-1
ffffffffc0205734:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0205736:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0205738:	83b1                	srli	a5,a5,0xc
ffffffffc020573a:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020573c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020573e:	02e7fa63          	bleu	a4,a5,ffffffffc0205772 <setup_pgdir.isra.2+0x74>
ffffffffc0205742:	000da797          	auipc	a5,0xda
ffffffffc0205746:	c7678793          	addi	a5,a5,-906 # ffffffffc02df3b8 <va_pa_offset>
ffffffffc020574a:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc020574c:	000da797          	auipc	a5,0xda
ffffffffc0205750:	bf478793          	addi	a5,a5,-1036 # ffffffffc02df340 <boot_pgdir>
ffffffffc0205754:	638c                	ld	a1,0(a5)
ffffffffc0205756:	9436                	add	s0,s0,a3
ffffffffc0205758:	6605                	lui	a2,0x1
ffffffffc020575a:	8522                	mv	a0,s0
ffffffffc020575c:	5db010ef          	jal	ra,ffffffffc0207536 <memcpy>
    return 0;
ffffffffc0205760:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc0205762:	e080                	sd	s0,0(s1)
}
ffffffffc0205764:	60e2                	ld	ra,24(sp)
ffffffffc0205766:	6442                	ld	s0,16(sp)
ffffffffc0205768:	64a2                	ld	s1,8(sp)
ffffffffc020576a:	6105                	addi	sp,sp,32
ffffffffc020576c:	8082                	ret
        return -E_NO_MEM;
ffffffffc020576e:	5571                	li	a0,-4
ffffffffc0205770:	bfd5                	j	ffffffffc0205764 <setup_pgdir.isra.2+0x66>
ffffffffc0205772:	00003617          	auipc	a2,0x3
ffffffffc0205776:	b6660613          	addi	a2,a2,-1178 # ffffffffc02082d8 <default_pmm_manager+0x50>
ffffffffc020577a:	06900593          	li	a1,105
ffffffffc020577e:	00003517          	auipc	a0,0x3
ffffffffc0205782:	b8250513          	addi	a0,a0,-1150 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc0205786:	d03fa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020578a <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020578a:	1101                	addi	sp,sp,-32
ffffffffc020578c:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020578e:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0205792:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205794:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0205796:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205798:	8522                	mv	a0,s0
ffffffffc020579a:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020579c:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020579e:	587010ef          	jal	ra,ffffffffc0207524 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02057a2:	8522                	mv	a0,s0
}
ffffffffc02057a4:	6442                	ld	s0,16(sp)
ffffffffc02057a6:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02057a8:	85a6                	mv	a1,s1
}
ffffffffc02057aa:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02057ac:	463d                	li	a2,15
}
ffffffffc02057ae:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02057b0:	5870106f          	j	ffffffffc0207536 <memcpy>

ffffffffc02057b4 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc02057b4:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc02057b6:	000da797          	auipc	a5,0xda
ffffffffc02057ba:	baa78793          	addi	a5,a5,-1110 # ffffffffc02df360 <current>
proc_run(struct proc_struct *proc) {
ffffffffc02057be:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc02057c0:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc02057c2:	ec06                	sd	ra,24(sp)
ffffffffc02057c4:	e822                	sd	s0,16(sp)
ffffffffc02057c6:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc02057c8:	02a48b63          	beq	s1,a0,ffffffffc02057fe <proc_run+0x4a>
ffffffffc02057cc:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02057ce:	100027f3          	csrr	a5,sstatus
ffffffffc02057d2:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02057d4:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02057d6:	e3a9                	bnez	a5,ffffffffc0205818 <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc02057d8:	745c                	ld	a5,168(s0)
            current = proc; // 将当前进程换为 要切换到的进程
ffffffffc02057da:	000da717          	auipc	a4,0xda
ffffffffc02057de:	b8873323          	sd	s0,-1146(a4) # ffffffffc02df360 <current>
ffffffffc02057e2:	577d                	li	a4,-1
ffffffffc02057e4:	177e                	slli	a4,a4,0x3f
ffffffffc02057e6:	83b1                	srli	a5,a5,0xc
ffffffffc02057e8:	8fd9                	or	a5,a5,a4
ffffffffc02057ea:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context)); // 调用 switch_to 进行上下文的保存与切换
ffffffffc02057ee:	03040593          	addi	a1,s0,48
ffffffffc02057f2:	03048513          	addi	a0,s1,48
ffffffffc02057f6:	1ba010ef          	jal	ra,ffffffffc02069b0 <switch_to>
    if (flag) {
ffffffffc02057fa:	00091863          	bnez	s2,ffffffffc020580a <proc_run+0x56>
}
ffffffffc02057fe:	60e2                	ld	ra,24(sp)
ffffffffc0205800:	6442                	ld	s0,16(sp)
ffffffffc0205802:	64a2                	ld	s1,8(sp)
ffffffffc0205804:	6902                	ld	s2,0(sp)
ffffffffc0205806:	6105                	addi	sp,sp,32
ffffffffc0205808:	8082                	ret
ffffffffc020580a:	6442                	ld	s0,16(sp)
ffffffffc020580c:	60e2                	ld	ra,24(sp)
ffffffffc020580e:	64a2                	ld	s1,8(sp)
ffffffffc0205810:	6902                	ld	s2,0(sp)
ffffffffc0205812:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205814:	e39fa06f          	j	ffffffffc020064c <intr_enable>
        intr_disable();
ffffffffc0205818:	e3bfa0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc020581c:	4905                	li	s2,1
ffffffffc020581e:	bf6d                	j	ffffffffc02057d8 <proc_run+0x24>

ffffffffc0205820 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205820:	0005071b          	sext.w	a4,a0
ffffffffc0205824:	6789                	lui	a5,0x2
ffffffffc0205826:	fff7069b          	addiw	a3,a4,-1
ffffffffc020582a:	17f9                	addi	a5,a5,-2
ffffffffc020582c:	04d7e063          	bltu	a5,a3,ffffffffc020586c <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0205830:	1141                	addi	sp,sp,-16
ffffffffc0205832:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205834:	45a9                	li	a1,10
ffffffffc0205836:	842a                	mv	s0,a0
ffffffffc0205838:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc020583a:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020583c:	03b010ef          	jal	ra,ffffffffc0207076 <hash32>
ffffffffc0205840:	02051693          	slli	a3,a0,0x20
ffffffffc0205844:	82f1                	srli	a3,a3,0x1c
ffffffffc0205846:	000d6517          	auipc	a0,0xd6
ffffffffc020584a:	aba50513          	addi	a0,a0,-1350 # ffffffffc02db300 <hash_list>
ffffffffc020584e:	96aa                	add	a3,a3,a0
ffffffffc0205850:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0205852:	a029                	j	ffffffffc020585c <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0205854:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7bac>
ffffffffc0205858:	00870c63          	beq	a4,s0,ffffffffc0205870 <find_proc+0x50>
    return listelm->next;
ffffffffc020585c:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020585e:	fef69be3          	bne	a3,a5,ffffffffc0205854 <find_proc+0x34>
}
ffffffffc0205862:	60a2                	ld	ra,8(sp)
ffffffffc0205864:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0205866:	4501                	li	a0,0
}
ffffffffc0205868:	0141                	addi	sp,sp,16
ffffffffc020586a:	8082                	ret
    return NULL;
ffffffffc020586c:	4501                	li	a0,0
}
ffffffffc020586e:	8082                	ret
ffffffffc0205870:	60a2                	ld	ra,8(sp)
ffffffffc0205872:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205874:	f2878513          	addi	a0,a5,-216
}
ffffffffc0205878:	0141                	addi	sp,sp,16
ffffffffc020587a:	8082                	ret

ffffffffc020587c <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc020587c:	7159                	addi	sp,sp,-112
ffffffffc020587e:	e8ca                	sd	s2,80(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0205880:	000da917          	auipc	s2,0xda
ffffffffc0205884:	af890913          	addi	s2,s2,-1288 # ffffffffc02df378 <nr_process>
ffffffffc0205888:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc020588c:	f486                	sd	ra,104(sp)
ffffffffc020588e:	f0a2                	sd	s0,96(sp)
ffffffffc0205890:	eca6                	sd	s1,88(sp)
ffffffffc0205892:	e4ce                	sd	s3,72(sp)
ffffffffc0205894:	e0d2                	sd	s4,64(sp)
ffffffffc0205896:	fc56                	sd	s5,56(sp)
ffffffffc0205898:	f85a                	sd	s6,48(sp)
ffffffffc020589a:	f45e                	sd	s7,40(sp)
ffffffffc020589c:	f062                	sd	s8,32(sp)
ffffffffc020589e:	ec66                	sd	s9,24(sp)
ffffffffc02058a0:	e86a                	sd	s10,16(sp)
ffffffffc02058a2:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02058a4:	6785                	lui	a5,0x1
ffffffffc02058a6:	32f75f63          	ble	a5,a4,ffffffffc0205be4 <do_fork+0x368>
ffffffffc02058aa:	8a2a                	mv	s4,a0
ffffffffc02058ac:	89ae                	mv	s3,a1
ffffffffc02058ae:	84b2                	mv	s1,a2
    if ((proc = alloc_proc()) == NULL)
ffffffffc02058b0:	d21ff0ef          	jal	ra,ffffffffc02055d0 <alloc_proc>
ffffffffc02058b4:	842a                	mv	s0,a0
ffffffffc02058b6:	2a050763          	beqz	a0,ffffffffc0205b64 <do_fork+0x2e8>
    proc->parent = current; // 设置父进程
ffffffffc02058ba:	000dab97          	auipc	s7,0xda
ffffffffc02058be:	aa6b8b93          	addi	s7,s7,-1370 # ffffffffc02df360 <current>
ffffffffc02058c2:	000bb783          	ld	a5,0(s7)
    assert(current->wait_state == 0);  
ffffffffc02058c6:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x89ec>
    proc->parent = current; // 设置父进程
ffffffffc02058ca:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);  
ffffffffc02058cc:	32071a63          	bnez	a4,ffffffffc0205c00 <do_fork+0x384>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02058d0:	4509                	li	a0,2
ffffffffc02058d2:	d8cfc0ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
    if (page != NULL) {
ffffffffc02058d6:	28050463          	beqz	a0,ffffffffc0205b5e <do_fork+0x2e2>
    return page - pages + nbase;
ffffffffc02058da:	000dac97          	auipc	s9,0xda
ffffffffc02058de:	aeec8c93          	addi	s9,s9,-1298 # ffffffffc02df3c8 <pages>
ffffffffc02058e2:	000cb683          	ld	a3,0(s9)
ffffffffc02058e6:	00005797          	auipc	a5,0x5
ffffffffc02058ea:	06a78793          	addi	a5,a5,106 # ffffffffc020a950 <nbase>
ffffffffc02058ee:	0007ba83          	ld	s5,0(a5)
ffffffffc02058f2:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc02058f6:	000dad17          	auipc	s10,0xda
ffffffffc02058fa:	a52d0d13          	addi	s10,s10,-1454 # ffffffffc02df348 <npage>
    return page - pages + nbase;
ffffffffc02058fe:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205900:	57fd                	li	a5,-1
ffffffffc0205902:	000d3703          	ld	a4,0(s10)
    return page - pages + nbase;
ffffffffc0205906:	96d6                	add	a3,a3,s5
    return KADDR(page2pa(page));
ffffffffc0205908:	83b1                	srli	a5,a5,0xc
ffffffffc020590a:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020590c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020590e:	2ce7fd63          	bleu	a4,a5,ffffffffc0205be8 <do_fork+0x36c>
ffffffffc0205912:	000dac17          	auipc	s8,0xda
ffffffffc0205916:	aa6c0c13          	addi	s8,s8,-1370 # ffffffffc02df3b8 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc020591a:	000bb703          	ld	a4,0(s7)
ffffffffc020591e:	000c3783          	ld	a5,0(s8)
ffffffffc0205922:	02873b03          	ld	s6,40(a4)
ffffffffc0205926:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0205928:	e814                	sd	a3,16(s0)
    if (oldmm == NULL) {
ffffffffc020592a:	020b0863          	beqz	s6,ffffffffc020595a <do_fork+0xde>
    if (clone_flags & CLONE_VM) {
ffffffffc020592e:	100a7a13          	andi	s4,s4,256
ffffffffc0205932:	1e0a0463          	beqz	s4,ffffffffc0205b1a <do_fork+0x29e>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0205936:	030b2703          	lw	a4,48(s6)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020593a:	018b3783          	ld	a5,24(s6)
ffffffffc020593e:	c02006b7          	lui	a3,0xc0200
ffffffffc0205942:	2705                	addiw	a4,a4,1
ffffffffc0205944:	02eb2823          	sw	a4,48(s6)
    proc->mm = mm;
ffffffffc0205948:	03643423          	sd	s6,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020594c:	2cd7ea63          	bltu	a5,a3,ffffffffc0205c20 <do_fork+0x3a4>
ffffffffc0205950:	000c3703          	ld	a4,0(s8)
ffffffffc0205954:	6814                	ld	a3,16(s0)
ffffffffc0205956:	8f99                	sub	a5,a5,a4
ffffffffc0205958:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc020595a:	6789                	lui	a5,0x2
ffffffffc020595c:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7bf8>
ffffffffc0205960:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0205962:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205964:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0205966:	87b6                	mv	a5,a3
ffffffffc0205968:	12048893          	addi	a7,s1,288
ffffffffc020596c:	00063803          	ld	a6,0(a2)
ffffffffc0205970:	6608                	ld	a0,8(a2)
ffffffffc0205972:	6a0c                	ld	a1,16(a2)
ffffffffc0205974:	6e18                	ld	a4,24(a2)
ffffffffc0205976:	0107b023          	sd	a6,0(a5)
ffffffffc020597a:	e788                	sd	a0,8(a5)
ffffffffc020597c:	eb8c                	sd	a1,16(a5)
ffffffffc020597e:	ef98                	sd	a4,24(a5)
ffffffffc0205980:	02060613          	addi	a2,a2,32
ffffffffc0205984:	02078793          	addi	a5,a5,32
ffffffffc0205988:	ff1612e3          	bne	a2,a7,ffffffffc020596c <do_fork+0xf0>
    proc->tf->gpr.a0 = 0;
ffffffffc020598c:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205990:	12098e63          	beqz	s3,ffffffffc0205acc <do_fork+0x250>
ffffffffc0205994:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205998:	00000797          	auipc	a5,0x0
ffffffffc020599c:	cd478793          	addi	a5,a5,-812 # ffffffffc020566c <forkret>
ffffffffc02059a0:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02059a2:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02059a4:	100027f3          	csrr	a5,sstatus
ffffffffc02059a8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02059aa:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02059ac:	12079f63          	bnez	a5,ffffffffc0205aea <do_fork+0x26e>
    if (++ last_pid >= MAX_PID) {
ffffffffc02059b0:	000ce797          	auipc	a5,0xce
ffffffffc02059b4:	54878793          	addi	a5,a5,1352 # ffffffffc02d3ef8 <last_pid.1832>
ffffffffc02059b8:	439c                	lw	a5,0(a5)
ffffffffc02059ba:	6709                	lui	a4,0x2
ffffffffc02059bc:	0017851b          	addiw	a0,a5,1
ffffffffc02059c0:	000ce697          	auipc	a3,0xce
ffffffffc02059c4:	52a6ac23          	sw	a0,1336(a3) # ffffffffc02d3ef8 <last_pid.1832>
ffffffffc02059c8:	14e55263          	ble	a4,a0,ffffffffc0205b0c <do_fork+0x290>
    if (last_pid >= next_safe) {
ffffffffc02059cc:	000ce797          	auipc	a5,0xce
ffffffffc02059d0:	53078793          	addi	a5,a5,1328 # ffffffffc02d3efc <next_safe.1831>
ffffffffc02059d4:	439c                	lw	a5,0(a5)
ffffffffc02059d6:	000da497          	auipc	s1,0xda
ffffffffc02059da:	c2a48493          	addi	s1,s1,-982 # ffffffffc02df600 <proc_list>
ffffffffc02059de:	06f54063          	blt	a0,a5,ffffffffc0205a3e <do_fork+0x1c2>
        next_safe = MAX_PID;
ffffffffc02059e2:	6789                	lui	a5,0x2
ffffffffc02059e4:	000ce717          	auipc	a4,0xce
ffffffffc02059e8:	50f72c23          	sw	a5,1304(a4) # ffffffffc02d3efc <next_safe.1831>
ffffffffc02059ec:	4581                	li	a1,0
ffffffffc02059ee:	87aa                	mv	a5,a0
ffffffffc02059f0:	000da497          	auipc	s1,0xda
ffffffffc02059f4:	c1048493          	addi	s1,s1,-1008 # ffffffffc02df600 <proc_list>
    repeat:
ffffffffc02059f8:	6889                	lui	a7,0x2
ffffffffc02059fa:	882e                	mv	a6,a1
ffffffffc02059fc:	6609                	lui	a2,0x2
        le = list;
ffffffffc02059fe:	000da697          	auipc	a3,0xda
ffffffffc0205a02:	c0268693          	addi	a3,a3,-1022 # ffffffffc02df600 <proc_list>
ffffffffc0205a06:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc0205a08:	00968f63          	beq	a3,s1,ffffffffc0205a26 <do_fork+0x1aa>
            if (proc->pid == last_pid) {
ffffffffc0205a0c:	f3c6a703          	lw	a4,-196(a3)
ffffffffc0205a10:	0af70963          	beq	a4,a5,ffffffffc0205ac2 <do_fork+0x246>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0205a14:	fee7d9e3          	ble	a4,a5,ffffffffc0205a06 <do_fork+0x18a>
ffffffffc0205a18:	fec757e3          	ble	a2,a4,ffffffffc0205a06 <do_fork+0x18a>
ffffffffc0205a1c:	6694                	ld	a3,8(a3)
ffffffffc0205a1e:	863a                	mv	a2,a4
ffffffffc0205a20:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc0205a22:	fe9695e3          	bne	a3,s1,ffffffffc0205a0c <do_fork+0x190>
ffffffffc0205a26:	c591                	beqz	a1,ffffffffc0205a32 <do_fork+0x1b6>
ffffffffc0205a28:	000ce717          	auipc	a4,0xce
ffffffffc0205a2c:	4cf72823          	sw	a5,1232(a4) # ffffffffc02d3ef8 <last_pid.1832>
ffffffffc0205a30:	853e                	mv	a0,a5
ffffffffc0205a32:	00080663          	beqz	a6,ffffffffc0205a3e <do_fork+0x1c2>
ffffffffc0205a36:	000ce797          	auipc	a5,0xce
ffffffffc0205a3a:	4cc7a323          	sw	a2,1222(a5) # ffffffffc02d3efc <next_safe.1831>
        proc->pid = get_pid(); // 这一句话要在前面！！！ 
ffffffffc0205a3e:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205a40:	45a9                	li	a1,10
ffffffffc0205a42:	2501                	sext.w	a0,a0
ffffffffc0205a44:	632010ef          	jal	ra,ffffffffc0207076 <hash32>
ffffffffc0205a48:	1502                	slli	a0,a0,0x20
ffffffffc0205a4a:	000d6797          	auipc	a5,0xd6
ffffffffc0205a4e:	8b678793          	addi	a5,a5,-1866 # ffffffffc02db300 <hash_list>
ffffffffc0205a52:	8171                	srli	a0,a0,0x1c
ffffffffc0205a54:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0205a56:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205a58:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205a5a:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc0205a5e:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0205a60:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc0205a62:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205a64:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0205a66:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc0205a6a:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc0205a6c:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc0205a6e:	e21c                	sd	a5,0(a2)
ffffffffc0205a70:	000da597          	auipc	a1,0xda
ffffffffc0205a74:	b8f5bc23          	sd	a5,-1128(a1) # ffffffffc02df608 <proc_list+0x8>
    elm->next = next;
ffffffffc0205a78:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc0205a7a:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc0205a7c:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205a80:	10e43023          	sd	a4,256(s0)
ffffffffc0205a84:	c311                	beqz	a4,ffffffffc0205a88 <do_fork+0x20c>
        proc->optr->yptr = proc;
ffffffffc0205a86:	ff60                	sd	s0,248(a4)
    nr_process ++;
ffffffffc0205a88:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc0205a8c:	fae0                	sd	s0,240(a3)
    nr_process ++;
ffffffffc0205a8e:	2785                	addiw	a5,a5,1
ffffffffc0205a90:	000da717          	auipc	a4,0xda
ffffffffc0205a94:	8ef72423          	sw	a5,-1816(a4) # ffffffffc02df378 <nr_process>
    if (flag) {
ffffffffc0205a98:	0c099863          	bnez	s3,ffffffffc0205b68 <do_fork+0x2ec>
    wakeup_proc(proc);
ffffffffc0205a9c:	8522                	mv	a0,s0
ffffffffc0205a9e:	0b2010ef          	jal	ra,ffffffffc0206b50 <wakeup_proc>
    ret = proc->pid;
ffffffffc0205aa2:	4048                	lw	a0,4(s0)
}
ffffffffc0205aa4:	70a6                	ld	ra,104(sp)
ffffffffc0205aa6:	7406                	ld	s0,96(sp)
ffffffffc0205aa8:	64e6                	ld	s1,88(sp)
ffffffffc0205aaa:	6946                	ld	s2,80(sp)
ffffffffc0205aac:	69a6                	ld	s3,72(sp)
ffffffffc0205aae:	6a06                	ld	s4,64(sp)
ffffffffc0205ab0:	7ae2                	ld	s5,56(sp)
ffffffffc0205ab2:	7b42                	ld	s6,48(sp)
ffffffffc0205ab4:	7ba2                	ld	s7,40(sp)
ffffffffc0205ab6:	7c02                	ld	s8,32(sp)
ffffffffc0205ab8:	6ce2                	ld	s9,24(sp)
ffffffffc0205aba:	6d42                	ld	s10,16(sp)
ffffffffc0205abc:	6da2                	ld	s11,8(sp)
ffffffffc0205abe:	6165                	addi	sp,sp,112
ffffffffc0205ac0:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc0205ac2:	2785                	addiw	a5,a5,1
ffffffffc0205ac4:	0ac7d563          	ble	a2,a5,ffffffffc0205b6e <do_fork+0x2f2>
ffffffffc0205ac8:	4585                	li	a1,1
ffffffffc0205aca:	bf35                	j	ffffffffc0205a06 <do_fork+0x18a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205acc:	89b6                	mv	s3,a3
ffffffffc0205ace:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205ad2:	00000797          	auipc	a5,0x0
ffffffffc0205ad6:	b9a78793          	addi	a5,a5,-1126 # ffffffffc020566c <forkret>
ffffffffc0205ada:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205adc:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205ade:	100027f3          	csrr	a5,sstatus
ffffffffc0205ae2:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205ae4:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205ae6:	ec0785e3          	beqz	a5,ffffffffc02059b0 <do_fork+0x134>
        intr_disable();
ffffffffc0205aea:	b69fa0ef          	jal	ra,ffffffffc0200652 <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205aee:	000ce797          	auipc	a5,0xce
ffffffffc0205af2:	40a78793          	addi	a5,a5,1034 # ffffffffc02d3ef8 <last_pid.1832>
ffffffffc0205af6:	439c                	lw	a5,0(a5)
ffffffffc0205af8:	6709                	lui	a4,0x2
        return 1;
ffffffffc0205afa:	4985                	li	s3,1
ffffffffc0205afc:	0017851b          	addiw	a0,a5,1
ffffffffc0205b00:	000ce697          	auipc	a3,0xce
ffffffffc0205b04:	3ea6ac23          	sw	a0,1016(a3) # ffffffffc02d3ef8 <last_pid.1832>
ffffffffc0205b08:	ece542e3          	blt	a0,a4,ffffffffc02059cc <do_fork+0x150>
        last_pid = 1;
ffffffffc0205b0c:	4785                	li	a5,1
ffffffffc0205b0e:	000ce717          	auipc	a4,0xce
ffffffffc0205b12:	3ef72523          	sw	a5,1002(a4) # ffffffffc02d3ef8 <last_pid.1832>
ffffffffc0205b16:	4505                	li	a0,1
ffffffffc0205b18:	b5e9                	j	ffffffffc02059e2 <do_fork+0x166>
    if ((mm = mm_create()) == NULL) {
ffffffffc0205b1a:	db8fe0ef          	jal	ra,ffffffffc02040d2 <mm_create>
ffffffffc0205b1e:	8a2a                	mv	s4,a0
ffffffffc0205b20:	c901                	beqz	a0,ffffffffc0205b30 <do_fork+0x2b4>
    if (setup_pgdir(mm) != 0) {
ffffffffc0205b22:	0561                	addi	a0,a0,24
ffffffffc0205b24:	bdbff0ef          	jal	ra,ffffffffc02056fe <setup_pgdir.isra.2>
ffffffffc0205b28:	c921                	beqz	a0,ffffffffc0205b78 <do_fork+0x2fc>
    mm_destroy(mm);
ffffffffc0205b2a:	8552                	mv	a0,s4
ffffffffc0205b2c:	f32fe0ef          	jal	ra,ffffffffc020425e <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205b30:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0205b32:	c02007b7          	lui	a5,0xc0200
ffffffffc0205b36:	10f6e263          	bltu	a3,a5,ffffffffc0205c3a <do_fork+0x3be>
ffffffffc0205b3a:	000c3783          	ld	a5,0(s8)
    if (PPN(pa) >= npage) {
ffffffffc0205b3e:	000d3703          	ld	a4,0(s10)
    return pa2page(PADDR(kva));
ffffffffc0205b42:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205b46:	83b1                	srli	a5,a5,0xc
ffffffffc0205b48:	10e7f563          	bleu	a4,a5,ffffffffc0205c52 <do_fork+0x3d6>
    return &pages[PPN(pa) - nbase];
ffffffffc0205b4c:	000cb503          	ld	a0,0(s9)
ffffffffc0205b50:	415787b3          	sub	a5,a5,s5
ffffffffc0205b54:	079a                	slli	a5,a5,0x6
ffffffffc0205b56:	4589                	li	a1,2
ffffffffc0205b58:	953e                	add	a0,a0,a5
ffffffffc0205b5a:	b8cfc0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    kfree(proc);
ffffffffc0205b5e:	8522                	mv	a0,s0
ffffffffc0205b60:	9befc0ef          	jal	ra,ffffffffc0201d1e <kfree>
    ret = -E_NO_MEM;
ffffffffc0205b64:	5571                	li	a0,-4
    return ret;
ffffffffc0205b66:	bf3d                	j	ffffffffc0205aa4 <do_fork+0x228>
        intr_enable();
ffffffffc0205b68:	ae5fa0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0205b6c:	bf05                	j	ffffffffc0205a9c <do_fork+0x220>
                    if (last_pid >= MAX_PID) {
ffffffffc0205b6e:	0117c363          	blt	a5,a7,ffffffffc0205b74 <do_fork+0x2f8>
                        last_pid = 1;
ffffffffc0205b72:	4785                	li	a5,1
                    goto repeat;
ffffffffc0205b74:	4585                	li	a1,1
ffffffffc0205b76:	b551                	j	ffffffffc02059fa <do_fork+0x17e>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        down(&(mm->mm_sem));
ffffffffc0205b78:	038b0d93          	addi	s11,s6,56
ffffffffc0205b7c:	856e                	mv	a0,s11
ffffffffc0205b7e:	fc6ff0ef          	jal	ra,ffffffffc0205344 <down>
        if (current != NULL) {
ffffffffc0205b82:	000bb783          	ld	a5,0(s7)
ffffffffc0205b86:	c781                	beqz	a5,ffffffffc0205b8e <do_fork+0x312>
            mm->locked_by = current->pid;
ffffffffc0205b88:	43dc                	lw	a5,4(a5)
ffffffffc0205b8a:	04fb2823          	sw	a5,80(s6)
        ret = dup_mmap(mm, oldmm);
ffffffffc0205b8e:	85da                	mv	a1,s6
ffffffffc0205b90:	8552                	mv	a0,s4
ffffffffc0205b92:	fd0fe0ef          	jal	ra,ffffffffc0204362 <dup_mmap>
ffffffffc0205b96:	8baa                	mv	s7,a0
}

static inline void
unlock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        up(&(mm->mm_sem));
ffffffffc0205b98:	856e                	mv	a0,s11
ffffffffc0205b9a:	fa6ff0ef          	jal	ra,ffffffffc0205340 <up>
        mm->locked_by = 0;
ffffffffc0205b9e:	040b2823          	sw	zero,80(s6)
    if (ret != 0) {
ffffffffc0205ba2:	8b52                	mv	s6,s4
ffffffffc0205ba4:	d80b89e3          	beqz	s7,ffffffffc0205936 <do_fork+0xba>
    exit_mmap(mm);
ffffffffc0205ba8:	8552                	mv	a0,s4
ffffffffc0205baa:	855fe0ef          	jal	ra,ffffffffc02043fe <exit_mmap>
    return pa2page(PADDR(kva));
ffffffffc0205bae:	018a3683          	ld	a3,24(s4)
ffffffffc0205bb2:	c02007b7          	lui	a5,0xc0200
ffffffffc0205bb6:	08f6e263          	bltu	a3,a5,ffffffffc0205c3a <do_fork+0x3be>
ffffffffc0205bba:	000c3703          	ld	a4,0(s8)
    if (PPN(pa) >= npage) {
ffffffffc0205bbe:	000d3783          	ld	a5,0(s10)
    return pa2page(PADDR(kva));
ffffffffc0205bc2:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0205bc4:	82b1                	srli	a3,a3,0xc
ffffffffc0205bc6:	08f6f663          	bleu	a5,a3,ffffffffc0205c52 <do_fork+0x3d6>
    return &pages[PPN(pa) - nbase];
ffffffffc0205bca:	000cb503          	ld	a0,0(s9)
ffffffffc0205bce:	415686b3          	sub	a3,a3,s5
ffffffffc0205bd2:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0205bd4:	9536                	add	a0,a0,a3
ffffffffc0205bd6:	4585                	li	a1,1
ffffffffc0205bd8:	b0efc0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    mm_destroy(mm);
ffffffffc0205bdc:	8552                	mv	a0,s4
ffffffffc0205bde:	e80fe0ef          	jal	ra,ffffffffc020425e <mm_destroy>
ffffffffc0205be2:	b7b9                	j	ffffffffc0205b30 <do_fork+0x2b4>
    int ret = -E_NO_FREE_PROC;
ffffffffc0205be4:	556d                	li	a0,-5
ffffffffc0205be6:	bd7d                	j	ffffffffc0205aa4 <do_fork+0x228>
    return KADDR(page2pa(page));
ffffffffc0205be8:	00002617          	auipc	a2,0x2
ffffffffc0205bec:	6f060613          	addi	a2,a2,1776 # ffffffffc02082d8 <default_pmm_manager+0x50>
ffffffffc0205bf0:	06900593          	li	a1,105
ffffffffc0205bf4:	00002517          	auipc	a0,0x2
ffffffffc0205bf8:	70c50513          	addi	a0,a0,1804 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc0205bfc:	88dfa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(current->wait_state == 0);  
ffffffffc0205c00:	00004697          	auipc	a3,0x4
ffffffffc0205c04:	db868693          	addi	a3,a3,-584 # ffffffffc02099b8 <default_pmm_manager+0x1730>
ffffffffc0205c08:	00002617          	auipc	a2,0x2
ffffffffc0205c0c:	f3860613          	addi	a2,a2,-200 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0205c10:	1c300593          	li	a1,451
ffffffffc0205c14:	00004517          	auipc	a0,0x4
ffffffffc0205c18:	01c50513          	addi	a0,a0,28 # ffffffffc0209c30 <default_pmm_manager+0x19a8>
ffffffffc0205c1c:	86dfa0ef          	jal	ra,ffffffffc0200488 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205c20:	86be                	mv	a3,a5
ffffffffc0205c22:	00002617          	auipc	a2,0x2
ffffffffc0205c26:	6ee60613          	addi	a2,a2,1774 # ffffffffc0208310 <default_pmm_manager+0x88>
ffffffffc0205c2a:	17600593          	li	a1,374
ffffffffc0205c2e:	00004517          	auipc	a0,0x4
ffffffffc0205c32:	00250513          	addi	a0,a0,2 # ffffffffc0209c30 <default_pmm_manager+0x19a8>
ffffffffc0205c36:	853fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205c3a:	00002617          	auipc	a2,0x2
ffffffffc0205c3e:	6d660613          	addi	a2,a2,1750 # ffffffffc0208310 <default_pmm_manager+0x88>
ffffffffc0205c42:	06e00593          	li	a1,110
ffffffffc0205c46:	00002517          	auipc	a0,0x2
ffffffffc0205c4a:	6ba50513          	addi	a0,a0,1722 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc0205c4e:	83bfa0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205c52:	00002617          	auipc	a2,0x2
ffffffffc0205c56:	6e660613          	addi	a2,a2,1766 # ffffffffc0208338 <default_pmm_manager+0xb0>
ffffffffc0205c5a:	06200593          	li	a1,98
ffffffffc0205c5e:	00002517          	auipc	a0,0x2
ffffffffc0205c62:	6a250513          	addi	a0,a0,1698 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc0205c66:	823fa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0205c6a <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205c6a:	7129                	addi	sp,sp,-320
ffffffffc0205c6c:	fa22                	sd	s0,304(sp)
ffffffffc0205c6e:	f626                	sd	s1,296(sp)
ffffffffc0205c70:	f24a                	sd	s2,288(sp)
ffffffffc0205c72:	84ae                	mv	s1,a1
ffffffffc0205c74:	892a                	mv	s2,a0
ffffffffc0205c76:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205c78:	4581                	li	a1,0
ffffffffc0205c7a:	12000613          	li	a2,288
ffffffffc0205c7e:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205c80:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205c82:	0a3010ef          	jal	ra,ffffffffc0207524 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0205c86:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0205c88:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0205c8a:	100027f3          	csrr	a5,sstatus
ffffffffc0205c8e:	edd7f793          	andi	a5,a5,-291
ffffffffc0205c92:	1207e793          	ori	a5,a5,288
ffffffffc0205c96:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205c98:	860a                	mv	a2,sp
ffffffffc0205c9a:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205c9e:	00000797          	auipc	a5,0x0
ffffffffc0205ca2:	92a78793          	addi	a5,a5,-1750 # ffffffffc02055c8 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205ca6:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205ca8:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205caa:	bd3ff0ef          	jal	ra,ffffffffc020587c <do_fork>
}
ffffffffc0205cae:	70f2                	ld	ra,312(sp)
ffffffffc0205cb0:	7452                	ld	s0,304(sp)
ffffffffc0205cb2:	74b2                	ld	s1,296(sp)
ffffffffc0205cb4:	7912                	ld	s2,288(sp)
ffffffffc0205cb6:	6131                	addi	sp,sp,320
ffffffffc0205cb8:	8082                	ret

ffffffffc0205cba <do_exit>:
do_exit(int error_code) {
ffffffffc0205cba:	7179                	addi	sp,sp,-48
ffffffffc0205cbc:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc0205cbe:	000d9717          	auipc	a4,0xd9
ffffffffc0205cc2:	6aa70713          	addi	a4,a4,1706 # ffffffffc02df368 <idleproc>
ffffffffc0205cc6:	000d9917          	auipc	s2,0xd9
ffffffffc0205cca:	69a90913          	addi	s2,s2,1690 # ffffffffc02df360 <current>
ffffffffc0205cce:	00093783          	ld	a5,0(s2)
ffffffffc0205cd2:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc0205cd4:	f406                	sd	ra,40(sp)
ffffffffc0205cd6:	f022                	sd	s0,32(sp)
ffffffffc0205cd8:	ec26                	sd	s1,24(sp)
ffffffffc0205cda:	e44e                	sd	s3,8(sp)
ffffffffc0205cdc:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc0205cde:	0ce78d63          	beq	a5,a4,ffffffffc0205db8 <do_exit+0xfe>
    if (current == initproc) {
ffffffffc0205ce2:	000d9417          	auipc	s0,0xd9
ffffffffc0205ce6:	68e40413          	addi	s0,s0,1678 # ffffffffc02df370 <initproc>
ffffffffc0205cea:	6018                	ld	a4,0(s0)
ffffffffc0205cec:	12e78c63          	beq	a5,a4,ffffffffc0205e24 <do_exit+0x16a>
    struct mm_struct *mm = current->mm;
ffffffffc0205cf0:	7784                	ld	s1,40(a5)
ffffffffc0205cf2:	89aa                	mv	s3,a0
    if (mm != NULL) {
ffffffffc0205cf4:	c48d                	beqz	s1,ffffffffc0205d1e <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc0205cf6:	000d9797          	auipc	a5,0xd9
ffffffffc0205cfa:	6ca78793          	addi	a5,a5,1738 # ffffffffc02df3c0 <boot_cr3>
ffffffffc0205cfe:	639c                	ld	a5,0(a5)
ffffffffc0205d00:	577d                	li	a4,-1
ffffffffc0205d02:	177e                	slli	a4,a4,0x3f
ffffffffc0205d04:	83b1                	srli	a5,a5,0xc
ffffffffc0205d06:	8fd9                	or	a5,a5,a4
ffffffffc0205d08:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0205d0c:	589c                	lw	a5,48(s1)
ffffffffc0205d0e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205d12:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205d14:	cf55                	beqz	a4,ffffffffc0205dd0 <do_exit+0x116>
        current->mm = NULL;
ffffffffc0205d16:	00093783          	ld	a5,0(s2)
ffffffffc0205d1a:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0205d1e:	00093783          	ld	a5,0(s2)
ffffffffc0205d22:	470d                	li	a4,3
ffffffffc0205d24:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0205d26:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205d2a:	100027f3          	csrr	a5,sstatus
ffffffffc0205d2e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205d30:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205d32:	10079563          	bnez	a5,ffffffffc0205e3c <do_exit+0x182>
        proc = current->parent;
ffffffffc0205d36:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205d3a:	800007b7          	lui	a5,0x80000
ffffffffc0205d3e:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc0205d40:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205d42:	0ec52703          	lw	a4,236(a0)
ffffffffc0205d46:	0ef70f63          	beq	a4,a5,ffffffffc0205e44 <do_exit+0x18a>
ffffffffc0205d4a:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205d4e:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205d52:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205d54:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) {
ffffffffc0205d56:	7afc                	ld	a5,240(a3)
ffffffffc0205d58:	cb95                	beqz	a5,ffffffffc0205d8c <do_exit+0xd2>
            current->cptr = proc->optr;
ffffffffc0205d5a:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_matrix_out_size+0xffffffff7fff44c0>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205d5e:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc0205d60:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205d62:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0205d64:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205d68:	10e7b023          	sd	a4,256(a5)
ffffffffc0205d6c:	c311                	beqz	a4,ffffffffc0205d70 <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc0205d6e:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205d70:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0205d72:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0205d74:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205d76:	fe9710e3          	bne	a4,s1,ffffffffc0205d56 <do_exit+0x9c>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205d7a:	0ec52783          	lw	a5,236(a0)
ffffffffc0205d7e:	fd379ce3          	bne	a5,s3,ffffffffc0205d56 <do_exit+0x9c>
                    wakeup_proc(initproc);
ffffffffc0205d82:	5cf000ef          	jal	ra,ffffffffc0206b50 <wakeup_proc>
ffffffffc0205d86:	00093683          	ld	a3,0(s2)
ffffffffc0205d8a:	b7f1                	j	ffffffffc0205d56 <do_exit+0x9c>
    if (flag) {
ffffffffc0205d8c:	020a1363          	bnez	s4,ffffffffc0205db2 <do_exit+0xf8>
    schedule();
ffffffffc0205d90:	67b000ef          	jal	ra,ffffffffc0206c0a <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0205d94:	00093783          	ld	a5,0(s2)
ffffffffc0205d98:	00004617          	auipc	a2,0x4
ffffffffc0205d9c:	c0060613          	addi	a2,a2,-1024 # ffffffffc0209998 <default_pmm_manager+0x1710>
ffffffffc0205da0:	21d00593          	li	a1,541
ffffffffc0205da4:	43d4                	lw	a3,4(a5)
ffffffffc0205da6:	00004517          	auipc	a0,0x4
ffffffffc0205daa:	e8a50513          	addi	a0,a0,-374 # ffffffffc0209c30 <default_pmm_manager+0x19a8>
ffffffffc0205dae:	edafa0ef          	jal	ra,ffffffffc0200488 <__panic>
        intr_enable();
ffffffffc0205db2:	89bfa0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0205db6:	bfe9                	j	ffffffffc0205d90 <do_exit+0xd6>
        panic("idleproc exit.\n");
ffffffffc0205db8:	00004617          	auipc	a2,0x4
ffffffffc0205dbc:	bc060613          	addi	a2,a2,-1088 # ffffffffc0209978 <default_pmm_manager+0x16f0>
ffffffffc0205dc0:	1f100593          	li	a1,497
ffffffffc0205dc4:	00004517          	auipc	a0,0x4
ffffffffc0205dc8:	e6c50513          	addi	a0,a0,-404 # ffffffffc0209c30 <default_pmm_manager+0x19a8>
ffffffffc0205dcc:	ebcfa0ef          	jal	ra,ffffffffc0200488 <__panic>
            exit_mmap(mm);
ffffffffc0205dd0:	8526                	mv	a0,s1
ffffffffc0205dd2:	e2cfe0ef          	jal	ra,ffffffffc02043fe <exit_mmap>
    return pa2page(PADDR(kva));
ffffffffc0205dd6:	6c94                	ld	a3,24(s1)
ffffffffc0205dd8:	c02007b7          	lui	a5,0xc0200
ffffffffc0205ddc:	06f6e763          	bltu	a3,a5,ffffffffc0205e4a <do_exit+0x190>
ffffffffc0205de0:	000d9797          	auipc	a5,0xd9
ffffffffc0205de4:	5d878793          	addi	a5,a5,1496 # ffffffffc02df3b8 <va_pa_offset>
ffffffffc0205de8:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0205dea:	000d9797          	auipc	a5,0xd9
ffffffffc0205dee:	55e78793          	addi	a5,a5,1374 # ffffffffc02df348 <npage>
ffffffffc0205df2:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0205df4:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0205df6:	82b1                	srli	a3,a3,0xc
ffffffffc0205df8:	06f6f563          	bleu	a5,a3,ffffffffc0205e62 <do_exit+0x1a8>
    return &pages[PPN(pa) - nbase];
ffffffffc0205dfc:	00005797          	auipc	a5,0x5
ffffffffc0205e00:	b5478793          	addi	a5,a5,-1196 # ffffffffc020a950 <nbase>
ffffffffc0205e04:	639c                	ld	a5,0(a5)
ffffffffc0205e06:	000d9717          	auipc	a4,0xd9
ffffffffc0205e0a:	5c270713          	addi	a4,a4,1474 # ffffffffc02df3c8 <pages>
ffffffffc0205e0e:	6308                	ld	a0,0(a4)
ffffffffc0205e10:	8e9d                	sub	a3,a3,a5
ffffffffc0205e12:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0205e14:	9536                	add	a0,a0,a3
ffffffffc0205e16:	4585                	li	a1,1
ffffffffc0205e18:	8cefc0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
            mm_destroy(mm);
ffffffffc0205e1c:	8526                	mv	a0,s1
ffffffffc0205e1e:	c40fe0ef          	jal	ra,ffffffffc020425e <mm_destroy>
ffffffffc0205e22:	bdd5                	j	ffffffffc0205d16 <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc0205e24:	00004617          	auipc	a2,0x4
ffffffffc0205e28:	b6460613          	addi	a2,a2,-1180 # ffffffffc0209988 <default_pmm_manager+0x1700>
ffffffffc0205e2c:	1f400593          	li	a1,500
ffffffffc0205e30:	00004517          	auipc	a0,0x4
ffffffffc0205e34:	e0050513          	addi	a0,a0,-512 # ffffffffc0209c30 <default_pmm_manager+0x19a8>
ffffffffc0205e38:	e50fa0ef          	jal	ra,ffffffffc0200488 <__panic>
        intr_disable();
ffffffffc0205e3c:	817fa0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0205e40:	4a05                	li	s4,1
ffffffffc0205e42:	bdd5                	j	ffffffffc0205d36 <do_exit+0x7c>
            wakeup_proc(proc);
ffffffffc0205e44:	50d000ef          	jal	ra,ffffffffc0206b50 <wakeup_proc>
ffffffffc0205e48:	b709                	j	ffffffffc0205d4a <do_exit+0x90>
    return pa2page(PADDR(kva));
ffffffffc0205e4a:	00002617          	auipc	a2,0x2
ffffffffc0205e4e:	4c660613          	addi	a2,a2,1222 # ffffffffc0208310 <default_pmm_manager+0x88>
ffffffffc0205e52:	06e00593          	li	a1,110
ffffffffc0205e56:	00002517          	auipc	a0,0x2
ffffffffc0205e5a:	4aa50513          	addi	a0,a0,1194 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc0205e5e:	e2afa0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205e62:	00002617          	auipc	a2,0x2
ffffffffc0205e66:	4d660613          	addi	a2,a2,1238 # ffffffffc0208338 <default_pmm_manager+0xb0>
ffffffffc0205e6a:	06200593          	li	a1,98
ffffffffc0205e6e:	00002517          	auipc	a0,0x2
ffffffffc0205e72:	49250513          	addi	a0,a0,1170 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc0205e76:	e12fa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0205e7a <do_wait.part.5>:
do_wait(int pid, int *code_store) {
ffffffffc0205e7a:	7139                	addi	sp,sp,-64
ffffffffc0205e7c:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc0205e7e:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc0205e82:	f426                	sd	s1,40(sp)
ffffffffc0205e84:	f04a                	sd	s2,32(sp)
ffffffffc0205e86:	ec4e                	sd	s3,24(sp)
ffffffffc0205e88:	e456                	sd	s5,8(sp)
ffffffffc0205e8a:	e05a                	sd	s6,0(sp)
ffffffffc0205e8c:	fc06                	sd	ra,56(sp)
ffffffffc0205e8e:	f822                	sd	s0,48(sp)
ffffffffc0205e90:	89aa                	mv	s3,a0
ffffffffc0205e92:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc0205e94:	000d9917          	auipc	s2,0xd9
ffffffffc0205e98:	4cc90913          	addi	s2,s2,1228 # ffffffffc02df360 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205e9c:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc0205e9e:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc0205ea0:	2a05                	addiw	s4,s4,1
    if (pid != 0) {
ffffffffc0205ea2:	02098f63          	beqz	s3,ffffffffc0205ee0 <do_wait.part.5+0x66>
        proc = find_proc(pid);
ffffffffc0205ea6:	854e                	mv	a0,s3
ffffffffc0205ea8:	979ff0ef          	jal	ra,ffffffffc0205820 <find_proc>
ffffffffc0205eac:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc0205eae:	12050063          	beqz	a0,ffffffffc0205fce <do_wait.part.5+0x154>
ffffffffc0205eb2:	00093703          	ld	a4,0(s2)
ffffffffc0205eb6:	711c                	ld	a5,32(a0)
ffffffffc0205eb8:	10e79b63          	bne	a5,a4,ffffffffc0205fce <do_wait.part.5+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205ebc:	411c                	lw	a5,0(a0)
ffffffffc0205ebe:	02978c63          	beq	a5,s1,ffffffffc0205ef6 <do_wait.part.5+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc0205ec2:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc0205ec6:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc0205eca:	541000ef          	jal	ra,ffffffffc0206c0a <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc0205ece:	00093783          	ld	a5,0(s2)
ffffffffc0205ed2:	0b07a783          	lw	a5,176(a5)
ffffffffc0205ed6:	8b85                	andi	a5,a5,1
ffffffffc0205ed8:	d7e9                	beqz	a5,ffffffffc0205ea2 <do_wait.part.5+0x28>
            do_exit(-E_KILLED);
ffffffffc0205eda:	555d                	li	a0,-9
ffffffffc0205edc:	ddfff0ef          	jal	ra,ffffffffc0205cba <do_exit>
        proc = current->cptr;
ffffffffc0205ee0:	00093703          	ld	a4,0(s2)
ffffffffc0205ee4:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205ee6:	e409                	bnez	s0,ffffffffc0205ef0 <do_wait.part.5+0x76>
ffffffffc0205ee8:	a0dd                	j	ffffffffc0205fce <do_wait.part.5+0x154>
ffffffffc0205eea:	10043403          	ld	s0,256(s0)
ffffffffc0205eee:	d871                	beqz	s0,ffffffffc0205ec2 <do_wait.part.5+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205ef0:	401c                	lw	a5,0(s0)
ffffffffc0205ef2:	fe979ce3          	bne	a5,s1,ffffffffc0205eea <do_wait.part.5+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc0205ef6:	000d9797          	auipc	a5,0xd9
ffffffffc0205efa:	47278793          	addi	a5,a5,1138 # ffffffffc02df368 <idleproc>
ffffffffc0205efe:	639c                	ld	a5,0(a5)
ffffffffc0205f00:	0c878d63          	beq	a5,s0,ffffffffc0205fda <do_wait.part.5+0x160>
ffffffffc0205f04:	000d9797          	auipc	a5,0xd9
ffffffffc0205f08:	46c78793          	addi	a5,a5,1132 # ffffffffc02df370 <initproc>
ffffffffc0205f0c:	639c                	ld	a5,0(a5)
ffffffffc0205f0e:	0cf40663          	beq	s0,a5,ffffffffc0205fda <do_wait.part.5+0x160>
    if (code_store != NULL) {
ffffffffc0205f12:	000b0663          	beqz	s6,ffffffffc0205f1e <do_wait.part.5+0xa4>
        *code_store = proc->exit_code;
ffffffffc0205f16:	0e842783          	lw	a5,232(s0)
ffffffffc0205f1a:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f1e:	100027f3          	csrr	a5,sstatus
ffffffffc0205f22:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205f24:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f26:	e7d5                	bnez	a5,ffffffffc0205fd2 <do_wait.part.5+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc0205f28:	6c70                	ld	a2,216(s0)
ffffffffc0205f2a:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc0205f2c:	10043703          	ld	a4,256(s0)
ffffffffc0205f30:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0205f32:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205f34:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0205f36:	6470                	ld	a2,200(s0)
ffffffffc0205f38:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0205f3a:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205f3c:	e290                	sd	a2,0(a3)
ffffffffc0205f3e:	c319                	beqz	a4,ffffffffc0205f44 <do_wait.part.5+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc0205f40:	ff7c                	sd	a5,248(a4)
ffffffffc0205f42:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc0205f44:	c3d1                	beqz	a5,ffffffffc0205fc8 <do_wait.part.5+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc0205f46:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc0205f4a:	000d9797          	auipc	a5,0xd9
ffffffffc0205f4e:	42e78793          	addi	a5,a5,1070 # ffffffffc02df378 <nr_process>
ffffffffc0205f52:	439c                	lw	a5,0(a5)
ffffffffc0205f54:	37fd                	addiw	a5,a5,-1
ffffffffc0205f56:	000d9717          	auipc	a4,0xd9
ffffffffc0205f5a:	42f72123          	sw	a5,1058(a4) # ffffffffc02df378 <nr_process>
    if (flag) {
ffffffffc0205f5e:	e1b5                	bnez	a1,ffffffffc0205fc2 <do_wait.part.5+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205f60:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0205f62:	c02007b7          	lui	a5,0xc0200
ffffffffc0205f66:	0af6e263          	bltu	a3,a5,ffffffffc020600a <do_wait.part.5+0x190>
ffffffffc0205f6a:	000d9797          	auipc	a5,0xd9
ffffffffc0205f6e:	44e78793          	addi	a5,a5,1102 # ffffffffc02df3b8 <va_pa_offset>
ffffffffc0205f72:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0205f74:	000d9797          	auipc	a5,0xd9
ffffffffc0205f78:	3d478793          	addi	a5,a5,980 # ffffffffc02df348 <npage>
ffffffffc0205f7c:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0205f7e:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0205f80:	82b1                	srli	a3,a3,0xc
ffffffffc0205f82:	06f6f863          	bleu	a5,a3,ffffffffc0205ff2 <do_wait.part.5+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc0205f86:	00005797          	auipc	a5,0x5
ffffffffc0205f8a:	9ca78793          	addi	a5,a5,-1590 # ffffffffc020a950 <nbase>
ffffffffc0205f8e:	639c                	ld	a5,0(a5)
ffffffffc0205f90:	000d9717          	auipc	a4,0xd9
ffffffffc0205f94:	43870713          	addi	a4,a4,1080 # ffffffffc02df3c8 <pages>
ffffffffc0205f98:	6308                	ld	a0,0(a4)
ffffffffc0205f9a:	8e9d                	sub	a3,a3,a5
ffffffffc0205f9c:	069a                	slli	a3,a3,0x6
ffffffffc0205f9e:	9536                	add	a0,a0,a3
ffffffffc0205fa0:	4589                	li	a1,2
ffffffffc0205fa2:	f45fb0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    kfree(proc);
ffffffffc0205fa6:	8522                	mv	a0,s0
ffffffffc0205fa8:	d77fb0ef          	jal	ra,ffffffffc0201d1e <kfree>
    return 0;
ffffffffc0205fac:	4501                	li	a0,0
}
ffffffffc0205fae:	70e2                	ld	ra,56(sp)
ffffffffc0205fb0:	7442                	ld	s0,48(sp)
ffffffffc0205fb2:	74a2                	ld	s1,40(sp)
ffffffffc0205fb4:	7902                	ld	s2,32(sp)
ffffffffc0205fb6:	69e2                	ld	s3,24(sp)
ffffffffc0205fb8:	6a42                	ld	s4,16(sp)
ffffffffc0205fba:	6aa2                	ld	s5,8(sp)
ffffffffc0205fbc:	6b02                	ld	s6,0(sp)
ffffffffc0205fbe:	6121                	addi	sp,sp,64
ffffffffc0205fc0:	8082                	ret
        intr_enable();
ffffffffc0205fc2:	e8afa0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0205fc6:	bf69                	j	ffffffffc0205f60 <do_wait.part.5+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc0205fc8:	701c                	ld	a5,32(s0)
ffffffffc0205fca:	fbf8                	sd	a4,240(a5)
ffffffffc0205fcc:	bfbd                	j	ffffffffc0205f4a <do_wait.part.5+0xd0>
    return -E_BAD_PROC;
ffffffffc0205fce:	5579                	li	a0,-2
ffffffffc0205fd0:	bff9                	j	ffffffffc0205fae <do_wait.part.5+0x134>
        intr_disable();
ffffffffc0205fd2:	e80fa0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0205fd6:	4585                	li	a1,1
ffffffffc0205fd8:	bf81                	j	ffffffffc0205f28 <do_wait.part.5+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc0205fda:	00004617          	auipc	a2,0x4
ffffffffc0205fde:	9fe60613          	addi	a2,a2,-1538 # ffffffffc02099d8 <default_pmm_manager+0x1750>
ffffffffc0205fe2:	31400593          	li	a1,788
ffffffffc0205fe6:	00004517          	auipc	a0,0x4
ffffffffc0205fea:	c4a50513          	addi	a0,a0,-950 # ffffffffc0209c30 <default_pmm_manager+0x19a8>
ffffffffc0205fee:	c9afa0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205ff2:	00002617          	auipc	a2,0x2
ffffffffc0205ff6:	34660613          	addi	a2,a2,838 # ffffffffc0208338 <default_pmm_manager+0xb0>
ffffffffc0205ffa:	06200593          	li	a1,98
ffffffffc0205ffe:	00002517          	auipc	a0,0x2
ffffffffc0206002:	30250513          	addi	a0,a0,770 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc0206006:	c82fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020600a:	00002617          	auipc	a2,0x2
ffffffffc020600e:	30660613          	addi	a2,a2,774 # ffffffffc0208310 <default_pmm_manager+0x88>
ffffffffc0206012:	06e00593          	li	a1,110
ffffffffc0206016:	00002517          	auipc	a0,0x2
ffffffffc020601a:	2ea50513          	addi	a0,a0,746 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc020601e:	c6afa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0206022 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc0206022:	1141                	addi	sp,sp,-16
ffffffffc0206024:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0206026:	f07fb0ef          	jal	ra,ffffffffc0201f2c <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc020602a:	c35fb0ef          	jal	ra,ffffffffc0201c5e <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc020602e:	4601                	li	a2,0
ffffffffc0206030:	4581                	li	a1,0
ffffffffc0206032:	fffff517          	auipc	a0,0xfffff
ffffffffc0206036:	64a50513          	addi	a0,a0,1610 # ffffffffc020567c <user_main>
ffffffffc020603a:	c31ff0ef          	jal	ra,ffffffffc0205c6a <kernel_thread>
    if (pid <= 0) {
ffffffffc020603e:	08a05c63          	blez	a0,ffffffffc02060d6 <init_main+0xb4>
        panic("create user_main failed.\n");
    }
    extern void check_sync(void);
    check_sync();                // check philosopher sync problem
ffffffffc0206042:	e9bfe0ef          	jal	ra,ffffffffc0204edc <check_sync>

    while (do_wait(0, NULL) == 0) {
ffffffffc0206046:	a019                	j	ffffffffc020604c <init_main+0x2a>
        schedule();
ffffffffc0206048:	3c3000ef          	jal	ra,ffffffffc0206c0a <schedule>
    if (code_store != NULL) {
ffffffffc020604c:	4581                	li	a1,0
ffffffffc020604e:	4501                	li	a0,0
ffffffffc0206050:	e2bff0ef          	jal	ra,ffffffffc0205e7a <do_wait.part.5>
    while (do_wait(0, NULL) == 0) {
ffffffffc0206054:	d975                	beqz	a0,ffffffffc0206048 <init_main+0x26>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0206056:	00004517          	auipc	a0,0x4
ffffffffc020605a:	9c250513          	addi	a0,a0,-1598 # ffffffffc0209a18 <default_pmm_manager+0x1790>
ffffffffc020605e:	934fa0ef          	jal	ra,ffffffffc0200192 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0206062:	000d9797          	auipc	a5,0xd9
ffffffffc0206066:	30e78793          	addi	a5,a5,782 # ffffffffc02df370 <initproc>
ffffffffc020606a:	639c                	ld	a5,0(a5)
ffffffffc020606c:	7bf8                	ld	a4,240(a5)
ffffffffc020606e:	e721                	bnez	a4,ffffffffc02060b6 <init_main+0x94>
ffffffffc0206070:	7ff8                	ld	a4,248(a5)
ffffffffc0206072:	e331                	bnez	a4,ffffffffc02060b6 <init_main+0x94>
ffffffffc0206074:	1007b703          	ld	a4,256(a5)
ffffffffc0206078:	ef1d                	bnez	a4,ffffffffc02060b6 <init_main+0x94>
    assert(nr_process == 2);
ffffffffc020607a:	000d9717          	auipc	a4,0xd9
ffffffffc020607e:	2fe70713          	addi	a4,a4,766 # ffffffffc02df378 <nr_process>
ffffffffc0206082:	4314                	lw	a3,0(a4)
ffffffffc0206084:	4709                	li	a4,2
ffffffffc0206086:	0ae69463          	bne	a3,a4,ffffffffc020612e <init_main+0x10c>
    return listelm->next;
ffffffffc020608a:	000d9697          	auipc	a3,0xd9
ffffffffc020608e:	57668693          	addi	a3,a3,1398 # ffffffffc02df600 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0206092:	6698                	ld	a4,8(a3)
ffffffffc0206094:	0c878793          	addi	a5,a5,200
ffffffffc0206098:	06f71b63          	bne	a4,a5,ffffffffc020610e <init_main+0xec>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020609c:	629c                	ld	a5,0(a3)
ffffffffc020609e:	04f71863          	bne	a4,a5,ffffffffc02060ee <init_main+0xcc>

    cprintf("init check memory pass.\n");
ffffffffc02060a2:	00004517          	auipc	a0,0x4
ffffffffc02060a6:	a5e50513          	addi	a0,a0,-1442 # ffffffffc0209b00 <default_pmm_manager+0x1878>
ffffffffc02060aa:	8e8fa0ef          	jal	ra,ffffffffc0200192 <cprintf>
    return 0;
}
ffffffffc02060ae:	60a2                	ld	ra,8(sp)
ffffffffc02060b0:	4501                	li	a0,0
ffffffffc02060b2:	0141                	addi	sp,sp,16
ffffffffc02060b4:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02060b6:	00004697          	auipc	a3,0x4
ffffffffc02060ba:	98a68693          	addi	a3,a3,-1654 # ffffffffc0209a40 <default_pmm_manager+0x17b8>
ffffffffc02060be:	00002617          	auipc	a2,0x2
ffffffffc02060c2:	a8260613          	addi	a2,a2,-1406 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02060c6:	37a00593          	li	a1,890
ffffffffc02060ca:	00004517          	auipc	a0,0x4
ffffffffc02060ce:	b6650513          	addi	a0,a0,-1178 # ffffffffc0209c30 <default_pmm_manager+0x19a8>
ffffffffc02060d2:	bb6fa0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("create user_main failed.\n");
ffffffffc02060d6:	00004617          	auipc	a2,0x4
ffffffffc02060da:	92260613          	addi	a2,a2,-1758 # ffffffffc02099f8 <default_pmm_manager+0x1770>
ffffffffc02060de:	37000593          	li	a1,880
ffffffffc02060e2:	00004517          	auipc	a0,0x4
ffffffffc02060e6:	b4e50513          	addi	a0,a0,-1202 # ffffffffc0209c30 <default_pmm_manager+0x19a8>
ffffffffc02060ea:	b9efa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02060ee:	00004697          	auipc	a3,0x4
ffffffffc02060f2:	9e268693          	addi	a3,a3,-1566 # ffffffffc0209ad0 <default_pmm_manager+0x1848>
ffffffffc02060f6:	00002617          	auipc	a2,0x2
ffffffffc02060fa:	a4a60613          	addi	a2,a2,-1462 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02060fe:	37d00593          	li	a1,893
ffffffffc0206102:	00004517          	auipc	a0,0x4
ffffffffc0206106:	b2e50513          	addi	a0,a0,-1234 # ffffffffc0209c30 <default_pmm_manager+0x19a8>
ffffffffc020610a:	b7efa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020610e:	00004697          	auipc	a3,0x4
ffffffffc0206112:	99268693          	addi	a3,a3,-1646 # ffffffffc0209aa0 <default_pmm_manager+0x1818>
ffffffffc0206116:	00002617          	auipc	a2,0x2
ffffffffc020611a:	a2a60613          	addi	a2,a2,-1494 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020611e:	37c00593          	li	a1,892
ffffffffc0206122:	00004517          	auipc	a0,0x4
ffffffffc0206126:	b0e50513          	addi	a0,a0,-1266 # ffffffffc0209c30 <default_pmm_manager+0x19a8>
ffffffffc020612a:	b5efa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_process == 2);
ffffffffc020612e:	00004697          	auipc	a3,0x4
ffffffffc0206132:	96268693          	addi	a3,a3,-1694 # ffffffffc0209a90 <default_pmm_manager+0x1808>
ffffffffc0206136:	00002617          	auipc	a2,0x2
ffffffffc020613a:	a0a60613          	addi	a2,a2,-1526 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020613e:	37b00593          	li	a1,891
ffffffffc0206142:	00004517          	auipc	a0,0x4
ffffffffc0206146:	aee50513          	addi	a0,a0,-1298 # ffffffffc0209c30 <default_pmm_manager+0x19a8>
ffffffffc020614a:	b3efa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020614e <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020614e:	7135                	addi	sp,sp,-160
ffffffffc0206150:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0206152:	000d9a17          	auipc	s4,0xd9
ffffffffc0206156:	20ea0a13          	addi	s4,s4,526 # ffffffffc02df360 <current>
ffffffffc020615a:	000a3783          	ld	a5,0(s4)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020615e:	e526                	sd	s1,136(sp)
ffffffffc0206160:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0206162:	7784                	ld	s1,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0206164:	fcce                	sd	s3,120(sp)
ffffffffc0206166:	f0da                	sd	s6,96(sp)
ffffffffc0206168:	89aa                	mv	s3,a0
ffffffffc020616a:	842e                	mv	s0,a1
ffffffffc020616c:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc020616e:	4681                	li	a3,0
ffffffffc0206170:	862e                	mv	a2,a1
ffffffffc0206172:	85aa                	mv	a1,a0
ffffffffc0206174:	8526                	mv	a0,s1
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0206176:	ed06                	sd	ra,152(sp)
ffffffffc0206178:	e14a                	sd	s2,128(sp)
ffffffffc020617a:	f4d6                	sd	s5,104(sp)
ffffffffc020617c:	ecde                	sd	s7,88(sp)
ffffffffc020617e:	e8e2                	sd	s8,80(sp)
ffffffffc0206180:	e4e6                	sd	s9,72(sp)
ffffffffc0206182:	e0ea                	sd	s10,64(sp)
ffffffffc0206184:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0206186:	93dfe0ef          	jal	ra,ffffffffc0204ac2 <user_mem_check>
ffffffffc020618a:	46050d63          	beqz	a0,ffffffffc0206604 <do_execve+0x4b6>
    memset(local_name, 0, sizeof(local_name));
ffffffffc020618e:	4641                	li	a2,16
ffffffffc0206190:	4581                	li	a1,0
ffffffffc0206192:	1008                	addi	a0,sp,32
ffffffffc0206194:	390010ef          	jal	ra,ffffffffc0207524 <memset>
    memcpy(local_name, name, len);
ffffffffc0206198:	47bd                	li	a5,15
ffffffffc020619a:	8622                	mv	a2,s0
ffffffffc020619c:	1887ef63          	bltu	a5,s0,ffffffffc020633a <do_execve+0x1ec>
ffffffffc02061a0:	85ce                	mv	a1,s3
ffffffffc02061a2:	1008                	addi	a0,sp,32
ffffffffc02061a4:	392010ef          	jal	ra,ffffffffc0207536 <memcpy>
    if (mm != NULL) {
ffffffffc02061a8:	1a048063          	beqz	s1,ffffffffc0206348 <do_execve+0x1fa>
        cputs("mm != NULL");
ffffffffc02061ac:	00003517          	auipc	a0,0x3
ffffffffc02061b0:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0208a78 <default_pmm_manager+0x7f0>
ffffffffc02061b4:	816fa0ef          	jal	ra,ffffffffc02001ca <cputs>
        lcr3(boot_cr3);
ffffffffc02061b8:	000d9797          	auipc	a5,0xd9
ffffffffc02061bc:	20878793          	addi	a5,a5,520 # ffffffffc02df3c0 <boot_cr3>
ffffffffc02061c0:	639c                	ld	a5,0(a5)
ffffffffc02061c2:	577d                	li	a4,-1
ffffffffc02061c4:	177e                	slli	a4,a4,0x3f
ffffffffc02061c6:	83b1                	srli	a5,a5,0xc
ffffffffc02061c8:	8fd9                	or	a5,a5,a4
ffffffffc02061ca:	18079073          	csrw	satp,a5
ffffffffc02061ce:	589c                	lw	a5,48(s1)
ffffffffc02061d0:	fff7871b          	addiw	a4,a5,-1
ffffffffc02061d4:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc02061d6:	2c070763          	beqz	a4,ffffffffc02064a4 <do_execve+0x356>
        current->mm = NULL;
ffffffffc02061da:	000a3783          	ld	a5,0(s4)
ffffffffc02061de:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc02061e2:	ef1fd0ef          	jal	ra,ffffffffc02040d2 <mm_create>
ffffffffc02061e6:	84aa                	mv	s1,a0
ffffffffc02061e8:	18050863          	beqz	a0,ffffffffc0206378 <do_execve+0x22a>
    if (setup_pgdir(mm) != 0) {
ffffffffc02061ec:	0561                	addi	a0,a0,24
ffffffffc02061ee:	d10ff0ef          	jal	ra,ffffffffc02056fe <setup_pgdir.isra.2>
ffffffffc02061f2:	16051c63          	bnez	a0,ffffffffc020636a <do_execve+0x21c>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02061f6:	000b2703          	lw	a4,0(s6)
ffffffffc02061fa:	464c47b7          	lui	a5,0x464c4
ffffffffc02061fe:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_matrix_out_size+0x464b893f>
ffffffffc0206202:	24f71963          	bne	a4,a5,ffffffffc0206454 <do_execve+0x306>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0206206:	038b5703          	lhu	a4,56(s6)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020620a:	020b3403          	ld	s0,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020620e:	00371793          	slli	a5,a4,0x3
ffffffffc0206212:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0206214:	945a                	add	s0,s0,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0206216:	078e                	slli	a5,a5,0x3
ffffffffc0206218:	97a2                	add	a5,a5,s0
ffffffffc020621a:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc020621c:	02f47b63          	bleu	a5,s0,ffffffffc0206252 <do_execve+0x104>
    return KADDR(page2pa(page));
ffffffffc0206220:	5bfd                	li	s7,-1
ffffffffc0206222:	00cbd793          	srli	a5,s7,0xc
    return page - pages + nbase;
ffffffffc0206226:	000d9d97          	auipc	s11,0xd9
ffffffffc020622a:	1a2d8d93          	addi	s11,s11,418 # ffffffffc02df3c8 <pages>
ffffffffc020622e:	00004d17          	auipc	s10,0x4
ffffffffc0206232:	722d0d13          	addi	s10,s10,1826 # ffffffffc020a950 <nbase>
    return KADDR(page2pa(page));
ffffffffc0206236:	e43e                	sd	a5,8(sp)
ffffffffc0206238:	000d9c97          	auipc	s9,0xd9
ffffffffc020623c:	110c8c93          	addi	s9,s9,272 # ffffffffc02df348 <npage>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0206240:	4018                	lw	a4,0(s0)
ffffffffc0206242:	4785                	li	a5,1
ffffffffc0206244:	12f70c63          	beq	a4,a5,ffffffffc020637c <do_execve+0x22e>
    for (; ph < ph_end; ph ++) {
ffffffffc0206248:	67e2                	ld	a5,24(sp)
ffffffffc020624a:	03840413          	addi	s0,s0,56
ffffffffc020624e:	fef469e3          	bltu	s0,a5,ffffffffc0206240 <do_execve+0xf2>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0206252:	4701                	li	a4,0
ffffffffc0206254:	46ad                	li	a3,11
ffffffffc0206256:	00100637          	lui	a2,0x100
ffffffffc020625a:	7ff005b7          	lui	a1,0x7ff00
ffffffffc020625e:	8526                	mv	a0,s1
ffffffffc0206260:	850fe0ef          	jal	ra,ffffffffc02042b0 <mm_map>
ffffffffc0206264:	89aa                	mv	s3,a0
ffffffffc0206266:	1e051363          	bnez	a0,ffffffffc020644c <do_execve+0x2fe>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc020626a:	6c88                	ld	a0,24(s1)
ffffffffc020626c:	467d                	li	a2,31
ffffffffc020626e:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0206272:	892fd0ef          	jal	ra,ffffffffc0203304 <pgdir_alloc_page>
ffffffffc0206276:	44050b63          	beqz	a0,ffffffffc02066cc <do_execve+0x57e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc020627a:	6c88                	ld	a0,24(s1)
ffffffffc020627c:	467d                	li	a2,31
ffffffffc020627e:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0206282:	882fd0ef          	jal	ra,ffffffffc0203304 <pgdir_alloc_page>
ffffffffc0206286:	42050363          	beqz	a0,ffffffffc02066ac <do_execve+0x55e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc020628a:	6c88                	ld	a0,24(s1)
ffffffffc020628c:	467d                	li	a2,31
ffffffffc020628e:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0206292:	872fd0ef          	jal	ra,ffffffffc0203304 <pgdir_alloc_page>
ffffffffc0206296:	3e050b63          	beqz	a0,ffffffffc020668c <do_execve+0x53e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc020629a:	6c88                	ld	a0,24(s1)
ffffffffc020629c:	467d                	li	a2,31
ffffffffc020629e:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc02062a2:	862fd0ef          	jal	ra,ffffffffc0203304 <pgdir_alloc_page>
ffffffffc02062a6:	3c050363          	beqz	a0,ffffffffc020666c <do_execve+0x51e>
    mm->mm_count += 1;
ffffffffc02062aa:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc02062ac:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02062b0:	6c94                	ld	a3,24(s1)
ffffffffc02062b2:	2785                	addiw	a5,a5,1
ffffffffc02062b4:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc02062b6:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02062b8:	c02007b7          	lui	a5,0xc0200
ffffffffc02062bc:	38f6ec63          	bltu	a3,a5,ffffffffc0206654 <do_execve+0x506>
ffffffffc02062c0:	000d9797          	auipc	a5,0xd9
ffffffffc02062c4:	0f878793          	addi	a5,a5,248 # ffffffffc02df3b8 <va_pa_offset>
ffffffffc02062c8:	639c                	ld	a5,0(a5)
ffffffffc02062ca:	577d                	li	a4,-1
ffffffffc02062cc:	177e                	slli	a4,a4,0x3f
ffffffffc02062ce:	8e9d                	sub	a3,a3,a5
ffffffffc02062d0:	00c6d793          	srli	a5,a3,0xc
ffffffffc02062d4:	f654                	sd	a3,168(a2)
ffffffffc02062d6:	8fd9                	or	a5,a5,a4
ffffffffc02062d8:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc02062dc:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02062de:	4581                	li	a1,0
ffffffffc02062e0:	12000613          	li	a2,288
ffffffffc02062e4:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc02062e6:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02062ea:	23a010ef          	jal	ra,ffffffffc0207524 <memset>
    tf->epc = elf->e_entry;
ffffffffc02062ee:	018b3703          	ld	a4,24(s6)
    tf->gpr.sp = USTACKTOP;
ffffffffc02062f2:	4785                	li	a5,1
ffffffffc02062f4:	07fe                	slli	a5,a5,0x1f
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc02062f6:	edf4f493          	andi	s1,s1,-289
    tf->gpr.sp = USTACKTOP;
ffffffffc02062fa:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc02062fc:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0206300:	10943023          	sd	s1,256(s0)
    cprintf("1\n");
ffffffffc0206304:	00003517          	auipc	a0,0x3
ffffffffc0206308:	66c50513          	addi	a0,a0,1644 # ffffffffc0209970 <default_pmm_manager+0x16e8>
ffffffffc020630c:	e87f90ef          	jal	ra,ffffffffc0200192 <cprintf>
    set_proc_name(current, local_name);
ffffffffc0206310:	000a3503          	ld	a0,0(s4)
ffffffffc0206314:	100c                	addi	a1,sp,32
ffffffffc0206316:	c74ff0ef          	jal	ra,ffffffffc020578a <set_proc_name>
}
ffffffffc020631a:	60ea                	ld	ra,152(sp)
ffffffffc020631c:	644a                	ld	s0,144(sp)
ffffffffc020631e:	854e                	mv	a0,s3
ffffffffc0206320:	64aa                	ld	s1,136(sp)
ffffffffc0206322:	690a                	ld	s2,128(sp)
ffffffffc0206324:	79e6                	ld	s3,120(sp)
ffffffffc0206326:	7a46                	ld	s4,112(sp)
ffffffffc0206328:	7aa6                	ld	s5,104(sp)
ffffffffc020632a:	7b06                	ld	s6,96(sp)
ffffffffc020632c:	6be6                	ld	s7,88(sp)
ffffffffc020632e:	6c46                	ld	s8,80(sp)
ffffffffc0206330:	6ca6                	ld	s9,72(sp)
ffffffffc0206332:	6d06                	ld	s10,64(sp)
ffffffffc0206334:	7de2                	ld	s11,56(sp)
ffffffffc0206336:	610d                	addi	sp,sp,160
ffffffffc0206338:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc020633a:	463d                	li	a2,15
ffffffffc020633c:	85ce                	mv	a1,s3
ffffffffc020633e:	1008                	addi	a0,sp,32
ffffffffc0206340:	1f6010ef          	jal	ra,ffffffffc0207536 <memcpy>
    if (mm != NULL) {
ffffffffc0206344:	e60494e3          	bnez	s1,ffffffffc02061ac <do_execve+0x5e>
    if (current->mm != NULL) {
ffffffffc0206348:	000a3783          	ld	a5,0(s4)
ffffffffc020634c:	779c                	ld	a5,40(a5)
ffffffffc020634e:	e8078ae3          	beqz	a5,ffffffffc02061e2 <do_execve+0x94>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0206352:	00003617          	auipc	a2,0x3
ffffffffc0206356:	49660613          	addi	a2,a2,1174 # ffffffffc02097e8 <default_pmm_manager+0x1560>
ffffffffc020635a:	22700593          	li	a1,551
ffffffffc020635e:	00004517          	auipc	a0,0x4
ffffffffc0206362:	8d250513          	addi	a0,a0,-1838 # ffffffffc0209c30 <default_pmm_manager+0x19a8>
ffffffffc0206366:	922fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    mm_destroy(mm);
ffffffffc020636a:	8526                	mv	a0,s1
ffffffffc020636c:	ef3fd0ef          	jal	ra,ffffffffc020425e <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0206370:	59f1                	li	s3,-4
    do_exit(ret);
ffffffffc0206372:	854e                	mv	a0,s3
ffffffffc0206374:	947ff0ef          	jal	ra,ffffffffc0205cba <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0206378:	59f1                	li	s3,-4
ffffffffc020637a:	bfe5                	j	ffffffffc0206372 <do_execve+0x224>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc020637c:	7410                	ld	a2,40(s0)
ffffffffc020637e:	701c                	ld	a5,32(s0)
ffffffffc0206380:	28f66463          	bltu	a2,a5,ffffffffc0206608 <do_execve+0x4ba>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0206384:	405c                	lw	a5,4(s0)
ffffffffc0206386:	0017f693          	andi	a3,a5,1
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc020638a:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc020638e:	068a                	slli	a3,a3,0x2
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0206390:	16071463          	bnez	a4,ffffffffc02064f8 <do_execve+0x3aa>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0206394:	4745                	li	a4,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0206396:	8b91                	andi	a5,a5,4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0206398:	e03a                	sd	a4,0(sp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc020639a:	c789                	beqz	a5,ffffffffc02063a4 <do_execve+0x256>
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc020639c:	47cd                	li	a5,19
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc020639e:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc02063a2:	e03e                	sd	a5,0(sp)
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc02063a4:	0026f793          	andi	a5,a3,2
ffffffffc02063a8:	14079e63          	bnez	a5,ffffffffc0206504 <do_execve+0x3b6>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc02063ac:	0046f793          	andi	a5,a3,4
ffffffffc02063b0:	c789                	beqz	a5,ffffffffc02063ba <do_execve+0x26c>
ffffffffc02063b2:	6782                	ld	a5,0(sp)
ffffffffc02063b4:	0087e793          	ori	a5,a5,8
ffffffffc02063b8:	e03e                	sd	a5,0(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc02063ba:	680c                	ld	a1,16(s0)
ffffffffc02063bc:	4701                	li	a4,0
ffffffffc02063be:	8526                	mv	a0,s1
ffffffffc02063c0:	ef1fd0ef          	jal	ra,ffffffffc02042b0 <mm_map>
ffffffffc02063c4:	89aa                	mv	s3,a0
ffffffffc02063c6:	e159                	bnez	a0,ffffffffc020644c <do_execve+0x2fe>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02063c8:	01043b83          	ld	s7,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc02063cc:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc02063d0:	00843a83          	ld	s5,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02063d4:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc02063d6:	99de                	add	s3,s3,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc02063d8:	9ada                	add	s5,s5,s6
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02063da:	00fbfc33          	and	s8,s7,a5
        while (start < end) {
ffffffffc02063de:	053bef63          	bltu	s7,s3,ffffffffc020643c <do_execve+0x2ee>
ffffffffc02063e2:	ac39                	j	ffffffffc0206600 <do_execve+0x4b2>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc02063e4:	6785                	lui	a5,0x1
ffffffffc02063e6:	418b8533          	sub	a0,s7,s8
ffffffffc02063ea:	9c3e                	add	s8,s8,a5
ffffffffc02063ec:	417c0833          	sub	a6,s8,s7
            if (end < la) {
ffffffffc02063f0:	0189f463          	bleu	s8,s3,ffffffffc02063f8 <do_execve+0x2aa>
                size -= la - end;
ffffffffc02063f4:	41798833          	sub	a6,s3,s7
    return page - pages + nbase;
ffffffffc02063f8:	000db683          	ld	a3,0(s11)
ffffffffc02063fc:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0206400:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0206402:	40d906b3          	sub	a3,s2,a3
ffffffffc0206406:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0206408:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc020640c:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc020640e:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0206412:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0206414:	1ec5fc63          	bleu	a2,a1,ffffffffc020660c <do_execve+0x4be>
ffffffffc0206418:	000d9797          	auipc	a5,0xd9
ffffffffc020641c:	fa078793          	addi	a5,a5,-96 # ffffffffc02df3b8 <va_pa_offset>
ffffffffc0206420:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0206424:	85d6                	mv	a1,s5
ffffffffc0206426:	8642                	mv	a2,a6
ffffffffc0206428:	96c6                	add	a3,a3,a7
ffffffffc020642a:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc020642c:	9bc2                	add	s7,s7,a6
ffffffffc020642e:	e842                	sd	a6,16(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0206430:	106010ef          	jal	ra,ffffffffc0207536 <memcpy>
            start += size, from += size;
ffffffffc0206434:	6842                	ld	a6,16(sp)
ffffffffc0206436:	9ac2                	add	s5,s5,a6
        while (start < end) {
ffffffffc0206438:	0d3bf963          	bleu	s3,s7,ffffffffc020650a <do_execve+0x3bc>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc020643c:	6c88                	ld	a0,24(s1)
ffffffffc020643e:	6602                	ld	a2,0(sp)
ffffffffc0206440:	85e2                	mv	a1,s8
ffffffffc0206442:	ec3fc0ef          	jal	ra,ffffffffc0203304 <pgdir_alloc_page>
ffffffffc0206446:	892a                	mv	s2,a0
ffffffffc0206448:	fd51                	bnez	a0,ffffffffc02063e4 <do_execve+0x296>
        ret = -E_NO_MEM;
ffffffffc020644a:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc020644c:	8526                	mv	a0,s1
ffffffffc020644e:	fb1fd0ef          	jal	ra,ffffffffc02043fe <exit_mmap>
ffffffffc0206452:	a011                	j	ffffffffc0206456 <do_execve+0x308>
        ret = -E_INVAL_ELF;
ffffffffc0206454:	59e1                	li	s3,-8
    return pa2page(PADDR(kva));
ffffffffc0206456:	6c94                	ld	a3,24(s1)
ffffffffc0206458:	c02007b7          	lui	a5,0xc0200
ffffffffc020645c:	1cf6e463          	bltu	a3,a5,ffffffffc0206624 <do_execve+0x4d6>
ffffffffc0206460:	000d9797          	auipc	a5,0xd9
ffffffffc0206464:	f5878793          	addi	a5,a5,-168 # ffffffffc02df3b8 <va_pa_offset>
ffffffffc0206468:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc020646a:	000d9797          	auipc	a5,0xd9
ffffffffc020646e:	ede78793          	addi	a5,a5,-290 # ffffffffc02df348 <npage>
ffffffffc0206472:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0206474:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0206476:	82b1                	srli	a3,a3,0xc
ffffffffc0206478:	1cf6f263          	bleu	a5,a3,ffffffffc020663c <do_execve+0x4ee>
    return &pages[PPN(pa) - nbase];
ffffffffc020647c:	00004797          	auipc	a5,0x4
ffffffffc0206480:	4d478793          	addi	a5,a5,1236 # ffffffffc020a950 <nbase>
ffffffffc0206484:	639c                	ld	a5,0(a5)
ffffffffc0206486:	000d9717          	auipc	a4,0xd9
ffffffffc020648a:	f4270713          	addi	a4,a4,-190 # ffffffffc02df3c8 <pages>
ffffffffc020648e:	6308                	ld	a0,0(a4)
ffffffffc0206490:	8e9d                	sub	a3,a3,a5
ffffffffc0206492:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0206494:	9536                	add	a0,a0,a3
ffffffffc0206496:	4585                	li	a1,1
ffffffffc0206498:	a4ffb0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    mm_destroy(mm);
ffffffffc020649c:	8526                	mv	a0,s1
ffffffffc020649e:	dc1fd0ef          	jal	ra,ffffffffc020425e <mm_destroy>
    return ret;
ffffffffc02064a2:	bdc1                	j	ffffffffc0206372 <do_execve+0x224>
            exit_mmap(mm);
ffffffffc02064a4:	8526                	mv	a0,s1
ffffffffc02064a6:	f59fd0ef          	jal	ra,ffffffffc02043fe <exit_mmap>
    return pa2page(PADDR(kva));
ffffffffc02064aa:	6c94                	ld	a3,24(s1)
ffffffffc02064ac:	c02007b7          	lui	a5,0xc0200
ffffffffc02064b0:	16f6ea63          	bltu	a3,a5,ffffffffc0206624 <do_execve+0x4d6>
ffffffffc02064b4:	000d9797          	auipc	a5,0xd9
ffffffffc02064b8:	f0478793          	addi	a5,a5,-252 # ffffffffc02df3b8 <va_pa_offset>
ffffffffc02064bc:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02064be:	000d9797          	auipc	a5,0xd9
ffffffffc02064c2:	e8a78793          	addi	a5,a5,-374 # ffffffffc02df348 <npage>
ffffffffc02064c6:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc02064c8:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc02064ca:	82b1                	srli	a3,a3,0xc
ffffffffc02064cc:	16f6f863          	bleu	a5,a3,ffffffffc020663c <do_execve+0x4ee>
    return &pages[PPN(pa) - nbase];
ffffffffc02064d0:	00004797          	auipc	a5,0x4
ffffffffc02064d4:	48078793          	addi	a5,a5,1152 # ffffffffc020a950 <nbase>
ffffffffc02064d8:	639c                	ld	a5,0(a5)
ffffffffc02064da:	000d9717          	auipc	a4,0xd9
ffffffffc02064de:	eee70713          	addi	a4,a4,-274 # ffffffffc02df3c8 <pages>
ffffffffc02064e2:	6308                	ld	a0,0(a4)
ffffffffc02064e4:	8e9d                	sub	a3,a3,a5
ffffffffc02064e6:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc02064e8:	9536                	add	a0,a0,a3
ffffffffc02064ea:	4585                	li	a1,1
ffffffffc02064ec:	9fbfb0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
            mm_destroy(mm);
ffffffffc02064f0:	8526                	mv	a0,s1
ffffffffc02064f2:	d6dfd0ef          	jal	ra,ffffffffc020425e <mm_destroy>
ffffffffc02064f6:	b1d5                	j	ffffffffc02061da <do_execve+0x8c>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc02064f8:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc02064fc:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc02064fe:	2681                	sext.w	a3,a3
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0206500:	e8079ee3          	bnez	a5,ffffffffc020639c <do_execve+0x24e>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0206504:	47dd                	li	a5,23
ffffffffc0206506:	e03e                	sd	a5,0(sp)
ffffffffc0206508:	b555                	j	ffffffffc02063ac <do_execve+0x25e>
ffffffffc020650a:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc020650e:	7414                	ld	a3,40(s0)
ffffffffc0206510:	99b6                	add	s3,s3,a3
        if (start < la) {
ffffffffc0206512:	098bf163          	bleu	s8,s7,ffffffffc0206594 <do_execve+0x446>
            if (start == end) {
ffffffffc0206516:	d37989e3          	beq	s3,s7,ffffffffc0206248 <do_execve+0xfa>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc020651a:	6505                	lui	a0,0x1
ffffffffc020651c:	955e                	add	a0,a0,s7
ffffffffc020651e:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0206522:	41798ab3          	sub	s5,s3,s7
            if (end < la) {
ffffffffc0206526:	0d89fa63          	bleu	s8,s3,ffffffffc02065fa <do_execve+0x4ac>
    return page - pages + nbase;
ffffffffc020652a:	000db683          	ld	a3,0(s11)
ffffffffc020652e:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0206532:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0206534:	40d906b3          	sub	a3,s2,a3
ffffffffc0206538:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020653a:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc020653e:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0206540:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0206544:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0206546:	0cc5f363          	bleu	a2,a1,ffffffffc020660c <do_execve+0x4be>
ffffffffc020654a:	000d9617          	auipc	a2,0xd9
ffffffffc020654e:	e6e60613          	addi	a2,a2,-402 # ffffffffc02df3b8 <va_pa_offset>
ffffffffc0206552:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0206556:	4581                	li	a1,0
ffffffffc0206558:	8656                	mv	a2,s5
ffffffffc020655a:	96c2                	add	a3,a3,a6
ffffffffc020655c:	9536                	add	a0,a0,a3
ffffffffc020655e:	7c7000ef          	jal	ra,ffffffffc0207524 <memset>
            start += size;
ffffffffc0206562:	015b8733          	add	a4,s7,s5
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0206566:	0389f463          	bleu	s8,s3,ffffffffc020658e <do_execve+0x440>
ffffffffc020656a:	cce98fe3          	beq	s3,a4,ffffffffc0206248 <do_execve+0xfa>
ffffffffc020656e:	00003697          	auipc	a3,0x3
ffffffffc0206572:	2a268693          	addi	a3,a3,674 # ffffffffc0209810 <default_pmm_manager+0x1588>
ffffffffc0206576:	00001617          	auipc	a2,0x1
ffffffffc020657a:	5ca60613          	addi	a2,a2,1482 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020657e:	27c00593          	li	a1,636
ffffffffc0206582:	00003517          	auipc	a0,0x3
ffffffffc0206586:	6ae50513          	addi	a0,a0,1710 # ffffffffc0209c30 <default_pmm_manager+0x19a8>
ffffffffc020658a:	efff90ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc020658e:	ff8710e3          	bne	a4,s8,ffffffffc020656e <do_execve+0x420>
ffffffffc0206592:	8be2                	mv	s7,s8
ffffffffc0206594:	000d9a97          	auipc	s5,0xd9
ffffffffc0206598:	e24a8a93          	addi	s5,s5,-476 # ffffffffc02df3b8 <va_pa_offset>
        while (start < end) {
ffffffffc020659c:	053be763          	bltu	s7,s3,ffffffffc02065ea <do_execve+0x49c>
ffffffffc02065a0:	b165                	j	ffffffffc0206248 <do_execve+0xfa>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc02065a2:	6785                	lui	a5,0x1
ffffffffc02065a4:	418b8533          	sub	a0,s7,s8
ffffffffc02065a8:	9c3e                	add	s8,s8,a5
ffffffffc02065aa:	417c0633          	sub	a2,s8,s7
            if (end < la) {
ffffffffc02065ae:	0189f463          	bleu	s8,s3,ffffffffc02065b6 <do_execve+0x468>
                size -= la - end;
ffffffffc02065b2:	41798633          	sub	a2,s3,s7
    return page - pages + nbase;
ffffffffc02065b6:	000db683          	ld	a3,0(s11)
ffffffffc02065ba:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc02065be:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc02065c0:	40d906b3          	sub	a3,s2,a3
ffffffffc02065c4:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02065c6:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc02065ca:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc02065cc:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc02065d0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02065d2:	02b87d63          	bleu	a1,a6,ffffffffc020660c <do_execve+0x4be>
ffffffffc02065d6:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc02065da:	9bb2                	add	s7,s7,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc02065dc:	4581                	li	a1,0
ffffffffc02065de:	96c2                	add	a3,a3,a6
ffffffffc02065e0:	9536                	add	a0,a0,a3
ffffffffc02065e2:	743000ef          	jal	ra,ffffffffc0207524 <memset>
        while (start < end) {
ffffffffc02065e6:	c73bf1e3          	bleu	s3,s7,ffffffffc0206248 <do_execve+0xfa>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc02065ea:	6c88                	ld	a0,24(s1)
ffffffffc02065ec:	6602                	ld	a2,0(sp)
ffffffffc02065ee:	85e2                	mv	a1,s8
ffffffffc02065f0:	d15fc0ef          	jal	ra,ffffffffc0203304 <pgdir_alloc_page>
ffffffffc02065f4:	892a                	mv	s2,a0
ffffffffc02065f6:	f555                	bnez	a0,ffffffffc02065a2 <do_execve+0x454>
ffffffffc02065f8:	bd89                	j	ffffffffc020644a <do_execve+0x2fc>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc02065fa:	417c0ab3          	sub	s5,s8,s7
ffffffffc02065fe:	b735                	j	ffffffffc020652a <do_execve+0x3dc>
        while (start < end) {
ffffffffc0206600:	89de                	mv	s3,s7
ffffffffc0206602:	b731                	j	ffffffffc020650e <do_execve+0x3c0>
        return -E_INVAL;
ffffffffc0206604:	59f5                	li	s3,-3
ffffffffc0206606:	bb11                	j	ffffffffc020631a <do_execve+0x1cc>
            ret = -E_INVAL_ELF;
ffffffffc0206608:	59e1                	li	s3,-8
ffffffffc020660a:	b589                	j	ffffffffc020644c <do_execve+0x2fe>
ffffffffc020660c:	00002617          	auipc	a2,0x2
ffffffffc0206610:	ccc60613          	addi	a2,a2,-820 # ffffffffc02082d8 <default_pmm_manager+0x50>
ffffffffc0206614:	06900593          	li	a1,105
ffffffffc0206618:	00002517          	auipc	a0,0x2
ffffffffc020661c:	ce850513          	addi	a0,a0,-792 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc0206620:	e69f90ef          	jal	ra,ffffffffc0200488 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0206624:	00002617          	auipc	a2,0x2
ffffffffc0206628:	cec60613          	addi	a2,a2,-788 # ffffffffc0208310 <default_pmm_manager+0x88>
ffffffffc020662c:	06e00593          	li	a1,110
ffffffffc0206630:	00002517          	auipc	a0,0x2
ffffffffc0206634:	cd050513          	addi	a0,a0,-816 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc0206638:	e51f90ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020663c:	00002617          	auipc	a2,0x2
ffffffffc0206640:	cfc60613          	addi	a2,a2,-772 # ffffffffc0208338 <default_pmm_manager+0xb0>
ffffffffc0206644:	06200593          	li	a1,98
ffffffffc0206648:	00002517          	auipc	a0,0x2
ffffffffc020664c:	cb850513          	addi	a0,a0,-840 # ffffffffc0208300 <default_pmm_manager+0x78>
ffffffffc0206650:	e39f90ef          	jal	ra,ffffffffc0200488 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0206654:	00002617          	auipc	a2,0x2
ffffffffc0206658:	cbc60613          	addi	a2,a2,-836 # ffffffffc0208310 <default_pmm_manager+0x88>
ffffffffc020665c:	29700593          	li	a1,663
ffffffffc0206660:	00003517          	auipc	a0,0x3
ffffffffc0206664:	5d050513          	addi	a0,a0,1488 # ffffffffc0209c30 <default_pmm_manager+0x19a8>
ffffffffc0206668:	e21f90ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc020666c:	00003697          	auipc	a3,0x3
ffffffffc0206670:	2bc68693          	addi	a3,a3,700 # ffffffffc0209928 <default_pmm_manager+0x16a0>
ffffffffc0206674:	00001617          	auipc	a2,0x1
ffffffffc0206678:	4cc60613          	addi	a2,a2,1228 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020667c:	29200593          	li	a1,658
ffffffffc0206680:	00003517          	auipc	a0,0x3
ffffffffc0206684:	5b050513          	addi	a0,a0,1456 # ffffffffc0209c30 <default_pmm_manager+0x19a8>
ffffffffc0206688:	e01f90ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc020668c:	00003697          	auipc	a3,0x3
ffffffffc0206690:	25468693          	addi	a3,a3,596 # ffffffffc02098e0 <default_pmm_manager+0x1658>
ffffffffc0206694:	00001617          	auipc	a2,0x1
ffffffffc0206698:	4ac60613          	addi	a2,a2,1196 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020669c:	29100593          	li	a1,657
ffffffffc02066a0:	00003517          	auipc	a0,0x3
ffffffffc02066a4:	59050513          	addi	a0,a0,1424 # ffffffffc0209c30 <default_pmm_manager+0x19a8>
ffffffffc02066a8:	de1f90ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc02066ac:	00003697          	auipc	a3,0x3
ffffffffc02066b0:	1ec68693          	addi	a3,a3,492 # ffffffffc0209898 <default_pmm_manager+0x1610>
ffffffffc02066b4:	00001617          	auipc	a2,0x1
ffffffffc02066b8:	48c60613          	addi	a2,a2,1164 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02066bc:	29000593          	li	a1,656
ffffffffc02066c0:	00003517          	auipc	a0,0x3
ffffffffc02066c4:	57050513          	addi	a0,a0,1392 # ffffffffc0209c30 <default_pmm_manager+0x19a8>
ffffffffc02066c8:	dc1f90ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc02066cc:	00003697          	auipc	a3,0x3
ffffffffc02066d0:	18468693          	addi	a3,a3,388 # ffffffffc0209850 <default_pmm_manager+0x15c8>
ffffffffc02066d4:	00001617          	auipc	a2,0x1
ffffffffc02066d8:	46c60613          	addi	a2,a2,1132 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02066dc:	28f00593          	li	a1,655
ffffffffc02066e0:	00003517          	auipc	a0,0x3
ffffffffc02066e4:	55050513          	addi	a0,a0,1360 # ffffffffc0209c30 <default_pmm_manager+0x19a8>
ffffffffc02066e8:	da1f90ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02066ec <do_yield>:
    current->need_resched = 1;
ffffffffc02066ec:	000d9797          	auipc	a5,0xd9
ffffffffc02066f0:	c7478793          	addi	a5,a5,-908 # ffffffffc02df360 <current>
ffffffffc02066f4:	639c                	ld	a5,0(a5)
ffffffffc02066f6:	4705                	li	a4,1
}
ffffffffc02066f8:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc02066fa:	ef98                	sd	a4,24(a5)
}
ffffffffc02066fc:	8082                	ret

ffffffffc02066fe <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc02066fe:	1101                	addi	sp,sp,-32
ffffffffc0206700:	e822                	sd	s0,16(sp)
ffffffffc0206702:	e426                	sd	s1,8(sp)
ffffffffc0206704:	ec06                	sd	ra,24(sp)
ffffffffc0206706:	842e                	mv	s0,a1
ffffffffc0206708:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc020670a:	cd81                	beqz	a1,ffffffffc0206722 <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc020670c:	000d9797          	auipc	a5,0xd9
ffffffffc0206710:	c5478793          	addi	a5,a5,-940 # ffffffffc02df360 <current>
ffffffffc0206714:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0206716:	4685                	li	a3,1
ffffffffc0206718:	4611                	li	a2,4
ffffffffc020671a:	7788                	ld	a0,40(a5)
ffffffffc020671c:	ba6fe0ef          	jal	ra,ffffffffc0204ac2 <user_mem_check>
ffffffffc0206720:	c909                	beqz	a0,ffffffffc0206732 <do_wait+0x34>
ffffffffc0206722:	85a2                	mv	a1,s0
}
ffffffffc0206724:	6442                	ld	s0,16(sp)
ffffffffc0206726:	60e2                	ld	ra,24(sp)
ffffffffc0206728:	8526                	mv	a0,s1
ffffffffc020672a:	64a2                	ld	s1,8(sp)
ffffffffc020672c:	6105                	addi	sp,sp,32
ffffffffc020672e:	f4cff06f          	j	ffffffffc0205e7a <do_wait.part.5>
ffffffffc0206732:	60e2                	ld	ra,24(sp)
ffffffffc0206734:	6442                	ld	s0,16(sp)
ffffffffc0206736:	64a2                	ld	s1,8(sp)
ffffffffc0206738:	5575                	li	a0,-3
ffffffffc020673a:	6105                	addi	sp,sp,32
ffffffffc020673c:	8082                	ret

ffffffffc020673e <do_kill>:
do_kill(int pid) {
ffffffffc020673e:	1141                	addi	sp,sp,-16
ffffffffc0206740:	e406                	sd	ra,8(sp)
ffffffffc0206742:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc0206744:	8dcff0ef          	jal	ra,ffffffffc0205820 <find_proc>
ffffffffc0206748:	cd0d                	beqz	a0,ffffffffc0206782 <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc020674a:	0b052703          	lw	a4,176(a0)
ffffffffc020674e:	00177693          	andi	a3,a4,1
ffffffffc0206752:	e695                	bnez	a3,ffffffffc020677e <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0206754:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0206758:	00176713          	ori	a4,a4,1
ffffffffc020675c:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0206760:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0206762:	0006c763          	bltz	a3,ffffffffc0206770 <do_kill+0x32>
}
ffffffffc0206766:	8522                	mv	a0,s0
ffffffffc0206768:	60a2                	ld	ra,8(sp)
ffffffffc020676a:	6402                	ld	s0,0(sp)
ffffffffc020676c:	0141                	addi	sp,sp,16
ffffffffc020676e:	8082                	ret
                wakeup_proc(proc);
ffffffffc0206770:	3e0000ef          	jal	ra,ffffffffc0206b50 <wakeup_proc>
}
ffffffffc0206774:	8522                	mv	a0,s0
ffffffffc0206776:	60a2                	ld	ra,8(sp)
ffffffffc0206778:	6402                	ld	s0,0(sp)
ffffffffc020677a:	0141                	addi	sp,sp,16
ffffffffc020677c:	8082                	ret
        return -E_KILLED;
ffffffffc020677e:	545d                	li	s0,-9
ffffffffc0206780:	b7dd                	j	ffffffffc0206766 <do_kill+0x28>
    return -E_INVAL;
ffffffffc0206782:	5475                	li	s0,-3
ffffffffc0206784:	b7cd                	j	ffffffffc0206766 <do_kill+0x28>

ffffffffc0206786 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0206786:	000d9797          	auipc	a5,0xd9
ffffffffc020678a:	e7a78793          	addi	a5,a5,-390 # ffffffffc02df600 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc020678e:	1101                	addi	sp,sp,-32
ffffffffc0206790:	000d9717          	auipc	a4,0xd9
ffffffffc0206794:	e6f73c23          	sd	a5,-392(a4) # ffffffffc02df608 <proc_list+0x8>
ffffffffc0206798:	000d9717          	auipc	a4,0xd9
ffffffffc020679c:	e6f73423          	sd	a5,-408(a4) # ffffffffc02df600 <proc_list>
ffffffffc02067a0:	ec06                	sd	ra,24(sp)
ffffffffc02067a2:	e822                	sd	s0,16(sp)
ffffffffc02067a4:	e426                	sd	s1,8(sp)
ffffffffc02067a6:	000d5797          	auipc	a5,0xd5
ffffffffc02067aa:	b5a78793          	addi	a5,a5,-1190 # ffffffffc02db300 <hash_list>
ffffffffc02067ae:	000d9717          	auipc	a4,0xd9
ffffffffc02067b2:	b5270713          	addi	a4,a4,-1198 # ffffffffc02df300 <__rq>
ffffffffc02067b6:	e79c                	sd	a5,8(a5)
ffffffffc02067b8:	e39c                	sd	a5,0(a5)
ffffffffc02067ba:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc02067bc:	fee79de3          	bne	a5,a4,ffffffffc02067b6 <proc_init+0x30>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc02067c0:	e11fe0ef          	jal	ra,ffffffffc02055d0 <alloc_proc>
ffffffffc02067c4:	000d9717          	auipc	a4,0xd9
ffffffffc02067c8:	baa73223          	sd	a0,-1116(a4) # ffffffffc02df368 <idleproc>
ffffffffc02067cc:	000d9497          	auipc	s1,0xd9
ffffffffc02067d0:	b9c48493          	addi	s1,s1,-1124 # ffffffffc02df368 <idleproc>
ffffffffc02067d4:	c559                	beqz	a0,ffffffffc0206862 <proc_init+0xdc>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc02067d6:	4709                	li	a4,2
ffffffffc02067d8:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc02067da:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02067dc:	00005717          	auipc	a4,0x5
ffffffffc02067e0:	82470713          	addi	a4,a4,-2012 # ffffffffc020b000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc02067e4:	00003597          	auipc	a1,0x3
ffffffffc02067e8:	36c58593          	addi	a1,a1,876 # ffffffffc0209b50 <default_pmm_manager+0x18c8>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02067ec:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc02067ee:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc02067f0:	f9bfe0ef          	jal	ra,ffffffffc020578a <set_proc_name>
    nr_process ++;
ffffffffc02067f4:	000d9797          	auipc	a5,0xd9
ffffffffc02067f8:	b8478793          	addi	a5,a5,-1148 # ffffffffc02df378 <nr_process>
ffffffffc02067fc:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc02067fe:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0206800:	4601                	li	a2,0
    nr_process ++;
ffffffffc0206802:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0206804:	4581                	li	a1,0
ffffffffc0206806:	00000517          	auipc	a0,0x0
ffffffffc020680a:	81c50513          	addi	a0,a0,-2020 # ffffffffc0206022 <init_main>
    nr_process ++;
ffffffffc020680e:	000d9697          	auipc	a3,0xd9
ffffffffc0206812:	b6f6a523          	sw	a5,-1174(a3) # ffffffffc02df378 <nr_process>
    current = idleproc;
ffffffffc0206816:	000d9797          	auipc	a5,0xd9
ffffffffc020681a:	b4e7b523          	sd	a4,-1206(a5) # ffffffffc02df360 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc020681e:	c4cff0ef          	jal	ra,ffffffffc0205c6a <kernel_thread>
    if (pid <= 0) {
ffffffffc0206822:	08a05c63          	blez	a0,ffffffffc02068ba <proc_init+0x134>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0206826:	ffbfe0ef          	jal	ra,ffffffffc0205820 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc020682a:	00003597          	auipc	a1,0x3
ffffffffc020682e:	34e58593          	addi	a1,a1,846 # ffffffffc0209b78 <default_pmm_manager+0x18f0>
    initproc = find_proc(pid);
ffffffffc0206832:	000d9797          	auipc	a5,0xd9
ffffffffc0206836:	b2a7bf23          	sd	a0,-1218(a5) # ffffffffc02df370 <initproc>
    set_proc_name(initproc, "init");
ffffffffc020683a:	f51fe0ef          	jal	ra,ffffffffc020578a <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020683e:	609c                	ld	a5,0(s1)
ffffffffc0206840:	cfa9                	beqz	a5,ffffffffc020689a <proc_init+0x114>
ffffffffc0206842:	43dc                	lw	a5,4(a5)
ffffffffc0206844:	ebb9                	bnez	a5,ffffffffc020689a <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0206846:	000d9797          	auipc	a5,0xd9
ffffffffc020684a:	b2a78793          	addi	a5,a5,-1238 # ffffffffc02df370 <initproc>
ffffffffc020684e:	639c                	ld	a5,0(a5)
ffffffffc0206850:	c78d                	beqz	a5,ffffffffc020687a <proc_init+0xf4>
ffffffffc0206852:	43dc                	lw	a5,4(a5)
ffffffffc0206854:	02879363          	bne	a5,s0,ffffffffc020687a <proc_init+0xf4>
}
ffffffffc0206858:	60e2                	ld	ra,24(sp)
ffffffffc020685a:	6442                	ld	s0,16(sp)
ffffffffc020685c:	64a2                	ld	s1,8(sp)
ffffffffc020685e:	6105                	addi	sp,sp,32
ffffffffc0206860:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0206862:	00003617          	auipc	a2,0x3
ffffffffc0206866:	2d660613          	addi	a2,a2,726 # ffffffffc0209b38 <default_pmm_manager+0x18b0>
ffffffffc020686a:	38f00593          	li	a1,911
ffffffffc020686e:	00003517          	auipc	a0,0x3
ffffffffc0206872:	3c250513          	addi	a0,a0,962 # ffffffffc0209c30 <default_pmm_manager+0x19a8>
ffffffffc0206876:	c13f90ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020687a:	00003697          	auipc	a3,0x3
ffffffffc020687e:	32e68693          	addi	a3,a3,814 # ffffffffc0209ba8 <default_pmm_manager+0x1920>
ffffffffc0206882:	00001617          	auipc	a2,0x1
ffffffffc0206886:	2be60613          	addi	a2,a2,702 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc020688a:	3a400593          	li	a1,932
ffffffffc020688e:	00003517          	auipc	a0,0x3
ffffffffc0206892:	3a250513          	addi	a0,a0,930 # ffffffffc0209c30 <default_pmm_manager+0x19a8>
ffffffffc0206896:	bf3f90ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020689a:	00003697          	auipc	a3,0x3
ffffffffc020689e:	2e668693          	addi	a3,a3,742 # ffffffffc0209b80 <default_pmm_manager+0x18f8>
ffffffffc02068a2:	00001617          	auipc	a2,0x1
ffffffffc02068a6:	29e60613          	addi	a2,a2,670 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc02068aa:	3a300593          	li	a1,931
ffffffffc02068ae:	00003517          	auipc	a0,0x3
ffffffffc02068b2:	38250513          	addi	a0,a0,898 # ffffffffc0209c30 <default_pmm_manager+0x19a8>
ffffffffc02068b6:	bd3f90ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("create init_main failed.\n");
ffffffffc02068ba:	00003617          	auipc	a2,0x3
ffffffffc02068be:	29e60613          	addi	a2,a2,670 # ffffffffc0209b58 <default_pmm_manager+0x18d0>
ffffffffc02068c2:	39d00593          	li	a1,925
ffffffffc02068c6:	00003517          	auipc	a0,0x3
ffffffffc02068ca:	36a50513          	addi	a0,a0,874 # ffffffffc0209c30 <default_pmm_manager+0x19a8>
ffffffffc02068ce:	bbbf90ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02068d2 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc02068d2:	1141                	addi	sp,sp,-16
ffffffffc02068d4:	e022                	sd	s0,0(sp)
ffffffffc02068d6:	e406                	sd	ra,8(sp)
ffffffffc02068d8:	000d9417          	auipc	s0,0xd9
ffffffffc02068dc:	a8840413          	addi	s0,s0,-1400 # ffffffffc02df360 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc02068e0:	6018                	ld	a4,0(s0)
ffffffffc02068e2:	6f1c                	ld	a5,24(a4)
ffffffffc02068e4:	dffd                	beqz	a5,ffffffffc02068e2 <cpu_idle+0x10>
            schedule();
ffffffffc02068e6:	324000ef          	jal	ra,ffffffffc0206c0a <schedule>
ffffffffc02068ea:	bfdd                	j	ffffffffc02068e0 <cpu_idle+0xe>

ffffffffc02068ec <lab6_set_priority>:
    }
}
//FOR LAB6, set the process's priority (bigger value will get more CPU time)
void
lab6_set_priority(uint32_t priority)
{
ffffffffc02068ec:	1141                	addi	sp,sp,-16
ffffffffc02068ee:	e022                	sd	s0,0(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc02068f0:	85aa                	mv	a1,a0
{
ffffffffc02068f2:	842a                	mv	s0,a0
    cprintf("set priority to %d\n", priority);
ffffffffc02068f4:	00003517          	auipc	a0,0x3
ffffffffc02068f8:	22c50513          	addi	a0,a0,556 # ffffffffc0209b20 <default_pmm_manager+0x1898>
{
ffffffffc02068fc:	e406                	sd	ra,8(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc02068fe:	895f90ef          	jal	ra,ffffffffc0200192 <cprintf>
    if (priority == 0)
        current->lab6_priority = 1;
ffffffffc0206902:	000d9797          	auipc	a5,0xd9
ffffffffc0206906:	a5e78793          	addi	a5,a5,-1442 # ffffffffc02df360 <current>
ffffffffc020690a:	639c                	ld	a5,0(a5)
    if (priority == 0)
ffffffffc020690c:	e801                	bnez	s0,ffffffffc020691c <lab6_set_priority+0x30>
    else current->lab6_priority = priority;
}
ffffffffc020690e:	60a2                	ld	ra,8(sp)
ffffffffc0206910:	6402                	ld	s0,0(sp)
        current->lab6_priority = 1;
ffffffffc0206912:	4705                	li	a4,1
ffffffffc0206914:	14e7a223          	sw	a4,324(a5)
}
ffffffffc0206918:	0141                	addi	sp,sp,16
ffffffffc020691a:	8082                	ret
    else current->lab6_priority = priority;
ffffffffc020691c:	1487a223          	sw	s0,324(a5)
}
ffffffffc0206920:	60a2                	ld	ra,8(sp)
ffffffffc0206922:	6402                	ld	s0,0(sp)
ffffffffc0206924:	0141                	addi	sp,sp,16
ffffffffc0206926:	8082                	ret

ffffffffc0206928 <do_sleep>:
// do_sleep - set current process state to sleep and add timer with "time"
//          - then call scheduler. if process run again, delete timer first.
int
do_sleep(unsigned int time) {
    if (time == 0) {
ffffffffc0206928:	c921                	beqz	a0,ffffffffc0206978 <do_sleep+0x50>
do_sleep(unsigned int time) {
ffffffffc020692a:	7179                	addi	sp,sp,-48
ffffffffc020692c:	f022                	sd	s0,32(sp)
ffffffffc020692e:	f406                	sd	ra,40(sp)
ffffffffc0206930:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206932:	100027f3          	csrr	a5,sstatus
ffffffffc0206936:	8b89                	andi	a5,a5,2
ffffffffc0206938:	e3b1                	bnez	a5,ffffffffc020697c <do_sleep+0x54>
        return 0;
    }
    bool intr_flag;
    local_intr_save(intr_flag);
    timer_t __timer, *timer = timer_init(&__timer, current, time);
ffffffffc020693a:	000d9797          	auipc	a5,0xd9
ffffffffc020693e:	a2678793          	addi	a5,a5,-1498 # ffffffffc02df360 <current>
ffffffffc0206942:	639c                	ld	a5,0(a5)
ffffffffc0206944:	0818                	addi	a4,sp,16
to_struct((le), timer_t, member)

// init a timer
static inline timer_t *
timer_init(timer_t *timer, struct proc_struct *proc, int expires) {
    timer->expires = expires;
ffffffffc0206946:	c02a                	sw	a0,0(sp)
ffffffffc0206948:	ec3a                	sd	a4,24(sp)
ffffffffc020694a:	e83a                	sd	a4,16(sp)
    timer->proc = proc;
ffffffffc020694c:	e43e                	sd	a5,8(sp)
    current->state = PROC_SLEEPING;
ffffffffc020694e:	4705                	li	a4,1
ffffffffc0206950:	c398                	sw	a4,0(a5)
    current->wait_state = WT_TIMER;
ffffffffc0206952:	80000737          	lui	a4,0x80000
ffffffffc0206956:	840a                	mv	s0,sp
ffffffffc0206958:	2709                	addiw	a4,a4,2
ffffffffc020695a:	0ee7a623          	sw	a4,236(a5)
    add_timer(timer);
ffffffffc020695e:	8522                	mv	a0,s0
ffffffffc0206960:	374000ef          	jal	ra,ffffffffc0206cd4 <add_timer>
    local_intr_restore(intr_flag);

    schedule();
ffffffffc0206964:	2a6000ef          	jal	ra,ffffffffc0206c0a <schedule>

    del_timer(timer);
ffffffffc0206968:	8522                	mv	a0,s0
ffffffffc020696a:	432000ef          	jal	ra,ffffffffc0206d9c <del_timer>
    return 0;
}
ffffffffc020696e:	70a2                	ld	ra,40(sp)
ffffffffc0206970:	7402                	ld	s0,32(sp)
ffffffffc0206972:	4501                	li	a0,0
ffffffffc0206974:	6145                	addi	sp,sp,48
ffffffffc0206976:	8082                	ret
ffffffffc0206978:	4501                	li	a0,0
ffffffffc020697a:	8082                	ret
        intr_disable();
ffffffffc020697c:	cd7f90ef          	jal	ra,ffffffffc0200652 <intr_disable>
    timer_t __timer, *timer = timer_init(&__timer, current, time);
ffffffffc0206980:	000d9797          	auipc	a5,0xd9
ffffffffc0206984:	9e078793          	addi	a5,a5,-1568 # ffffffffc02df360 <current>
ffffffffc0206988:	639c                	ld	a5,0(a5)
ffffffffc020698a:	0818                	addi	a4,sp,16
    timer->expires = expires;
ffffffffc020698c:	c022                	sw	s0,0(sp)
    timer->proc = proc;
ffffffffc020698e:	e43e                	sd	a5,8(sp)
ffffffffc0206990:	ec3a                	sd	a4,24(sp)
ffffffffc0206992:	e83a                	sd	a4,16(sp)
    current->state = PROC_SLEEPING;
ffffffffc0206994:	4705                	li	a4,1
ffffffffc0206996:	c398                	sw	a4,0(a5)
    current->wait_state = WT_TIMER;
ffffffffc0206998:	80000737          	lui	a4,0x80000
ffffffffc020699c:	2709                	addiw	a4,a4,2
ffffffffc020699e:	840a                	mv	s0,sp
    add_timer(timer);
ffffffffc02069a0:	8522                	mv	a0,s0
    current->wait_state = WT_TIMER;
ffffffffc02069a2:	0ee7a623          	sw	a4,236(a5)
    add_timer(timer);
ffffffffc02069a6:	32e000ef          	jal	ra,ffffffffc0206cd4 <add_timer>
        intr_enable();
ffffffffc02069aa:	ca3f90ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc02069ae:	bf5d                	j	ffffffffc0206964 <do_sleep+0x3c>

ffffffffc02069b0 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc02069b0:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc02069b4:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc02069b8:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc02069ba:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc02069bc:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc02069c0:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc02069c4:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc02069c8:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc02069cc:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc02069d0:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc02069d4:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc02069d8:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc02069dc:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc02069e0:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc02069e4:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc02069e8:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc02069ec:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc02069ee:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc02069f0:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc02069f4:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc02069f8:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc02069fc:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0206a00:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0206a04:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0206a08:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0206a0c:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0206a10:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0206a14:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0206a18:	8082                	ret

ffffffffc0206a1a <RR_init>:
ffffffffc0206a1a:	e508                	sd	a0,8(a0)
ffffffffc0206a1c:	e108                	sd	a0,0(a0)
#include <default_sched.h>

static void
RR_init(struct run_queue *rq) {
    list_init(&(rq->run_list));
    rq->proc_num = 0;
ffffffffc0206a1e:	00052823          	sw	zero,16(a0)
}
ffffffffc0206a22:	8082                	ret

ffffffffc0206a24 <RR_pick_next>:
    return listelm->next;
ffffffffc0206a24:	651c                	ld	a5,8(a0)
}

static struct proc_struct *
RR_pick_next(struct run_queue *rq) {
    list_entry_t *le = list_next(&(rq->run_list));
    if (le != &(rq->run_list)) {
ffffffffc0206a26:	00f50563          	beq	a0,a5,ffffffffc0206a30 <RR_pick_next+0xc>
        return le2proc(le, run_link);
ffffffffc0206a2a:	ef078513          	addi	a0,a5,-272
ffffffffc0206a2e:	8082                	ret
    }
    return NULL;
ffffffffc0206a30:	4501                	li	a0,0
}
ffffffffc0206a32:	8082                	ret

ffffffffc0206a34 <RR_proc_tick>:

static void
RR_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
    if (proc->time_slice > 0) {
ffffffffc0206a34:	1205a783          	lw	a5,288(a1)
ffffffffc0206a38:	00f05563          	blez	a5,ffffffffc0206a42 <RR_proc_tick+0xe>
        proc->time_slice --;
ffffffffc0206a3c:	37fd                	addiw	a5,a5,-1
ffffffffc0206a3e:	12f5a023          	sw	a5,288(a1)
    }
    if (proc->time_slice == 0) {
ffffffffc0206a42:	e399                	bnez	a5,ffffffffc0206a48 <RR_proc_tick+0x14>
        proc->need_resched = 1;
ffffffffc0206a44:	4785                	li	a5,1
ffffffffc0206a46:	ed9c                	sd	a5,24(a1)
    }
}
ffffffffc0206a48:	8082                	ret

ffffffffc0206a4a <RR_dequeue>:
    return list->next == list;
ffffffffc0206a4a:	1185b703          	ld	a4,280(a1)
    assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
ffffffffc0206a4e:	11058793          	addi	a5,a1,272
ffffffffc0206a52:	02e78263          	beq	a5,a4,ffffffffc0206a76 <RR_dequeue+0x2c>
ffffffffc0206a56:	1085b683          	ld	a3,264(a1)
ffffffffc0206a5a:	00a69e63          	bne	a3,a0,ffffffffc0206a76 <RR_dequeue+0x2c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0206a5e:	1105b503          	ld	a0,272(a1)
    rq->proc_num --;
ffffffffc0206a62:	4a90                	lw	a2,16(a3)
    prev->next = next;
ffffffffc0206a64:	e518                	sd	a4,8(a0)
    next->prev = prev;
ffffffffc0206a66:	e308                	sd	a0,0(a4)
    elm->prev = elm->next = elm;
ffffffffc0206a68:	10f5bc23          	sd	a5,280(a1)
ffffffffc0206a6c:	10f5b823          	sd	a5,272(a1)
ffffffffc0206a70:	367d                	addiw	a2,a2,-1
ffffffffc0206a72:	ca90                	sw	a2,16(a3)
ffffffffc0206a74:	8082                	ret
RR_dequeue(struct run_queue *rq, struct proc_struct *proc) {
ffffffffc0206a76:	1141                	addi	sp,sp,-16
    assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
ffffffffc0206a78:	00003697          	auipc	a3,0x3
ffffffffc0206a7c:	1d068693          	addi	a3,a3,464 # ffffffffc0209c48 <default_pmm_manager+0x19c0>
ffffffffc0206a80:	00001617          	auipc	a2,0x1
ffffffffc0206a84:	0c060613          	addi	a2,a2,192 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0206a88:	45e9                	li	a1,26
ffffffffc0206a8a:	00003517          	auipc	a0,0x3
ffffffffc0206a8e:	1f650513          	addi	a0,a0,502 # ffffffffc0209c80 <default_pmm_manager+0x19f8>
RR_dequeue(struct run_queue *rq, struct proc_struct *proc) {
ffffffffc0206a92:	e406                	sd	ra,8(sp)
    assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
ffffffffc0206a94:	9f5f90ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0206a98 <RR_enqueue>:
    assert(list_empty(&(proc->run_link)));
ffffffffc0206a98:	1185b703          	ld	a4,280(a1)
ffffffffc0206a9c:	11058793          	addi	a5,a1,272
ffffffffc0206aa0:	02e79d63          	bne	a5,a4,ffffffffc0206ada <RR_enqueue+0x42>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0206aa4:	6118                	ld	a4,0(a0)
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc0206aa6:	1205a683          	lw	a3,288(a1)
    prev->next = next->prev = elm;
ffffffffc0206aaa:	e11c                	sd	a5,0(a0)
ffffffffc0206aac:	e71c                	sd	a5,8(a4)
    elm->next = next;
ffffffffc0206aae:	10a5bc23          	sd	a0,280(a1)
    elm->prev = prev;
ffffffffc0206ab2:	10e5b823          	sd	a4,272(a1)
ffffffffc0206ab6:	495c                	lw	a5,20(a0)
ffffffffc0206ab8:	ea89                	bnez	a3,ffffffffc0206aca <RR_enqueue+0x32>
        proc->time_slice = rq->max_time_slice;
ffffffffc0206aba:	12f5a023          	sw	a5,288(a1)
    rq->proc_num ++;
ffffffffc0206abe:	491c                	lw	a5,16(a0)
    proc->rq = rq;
ffffffffc0206ac0:	10a5b423          	sd	a0,264(a1)
    rq->proc_num ++;
ffffffffc0206ac4:	2785                	addiw	a5,a5,1
ffffffffc0206ac6:	c91c                	sw	a5,16(a0)
ffffffffc0206ac8:	8082                	ret
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc0206aca:	fed7c8e3          	blt	a5,a3,ffffffffc0206aba <RR_enqueue+0x22>
    rq->proc_num ++;
ffffffffc0206ace:	491c                	lw	a5,16(a0)
    proc->rq = rq;
ffffffffc0206ad0:	10a5b423          	sd	a0,264(a1)
    rq->proc_num ++;
ffffffffc0206ad4:	2785                	addiw	a5,a5,1
ffffffffc0206ad6:	c91c                	sw	a5,16(a0)
ffffffffc0206ad8:	8082                	ret
RR_enqueue(struct run_queue *rq, struct proc_struct *proc) {
ffffffffc0206ada:	1141                	addi	sp,sp,-16
    assert(list_empty(&(proc->run_link)));
ffffffffc0206adc:	00003697          	auipc	a3,0x3
ffffffffc0206ae0:	1c468693          	addi	a3,a3,452 # ffffffffc0209ca0 <default_pmm_manager+0x1a18>
ffffffffc0206ae4:	00001617          	auipc	a2,0x1
ffffffffc0206ae8:	05c60613          	addi	a2,a2,92 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0206aec:	45bd                	li	a1,15
ffffffffc0206aee:	00003517          	auipc	a0,0x3
ffffffffc0206af2:	19250513          	addi	a0,a0,402 # ffffffffc0209c80 <default_pmm_manager+0x19f8>
RR_enqueue(struct run_queue *rq, struct proc_struct *proc) {
ffffffffc0206af6:	e406                	sd	ra,8(sp)
    assert(list_empty(&(proc->run_link)));
ffffffffc0206af8:	991f90ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0206afc <sched_init>:
}

static struct run_queue __rq;

void
sched_init(void) {
ffffffffc0206afc:	1141                	addi	sp,sp,-16
    list_init(&timer_list);

    sched_class = &default_sched_class;
ffffffffc0206afe:	000cd697          	auipc	a3,0xcd
ffffffffc0206b02:	3ba68693          	addi	a3,a3,954 # ffffffffc02d3eb8 <default_sched_class>
sched_init(void) {
ffffffffc0206b06:	e022                	sd	s0,0(sp)
ffffffffc0206b08:	e406                	sd	ra,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0206b0a:	000d9797          	auipc	a5,0xd9
ffffffffc0206b0e:	81678793          	addi	a5,a5,-2026 # ffffffffc02df320 <timer_list>

    rq = &__rq;
    rq->max_time_slice = MAX_TIME_SLICE;
    sched_class->init(rq);
ffffffffc0206b12:	6690                	ld	a2,8(a3)
    rq = &__rq;
ffffffffc0206b14:	000d8717          	auipc	a4,0xd8
ffffffffc0206b18:	7ec70713          	addi	a4,a4,2028 # ffffffffc02df300 <__rq>
ffffffffc0206b1c:	e79c                	sd	a5,8(a5)
ffffffffc0206b1e:	e39c                	sd	a5,0(a5)
    rq->max_time_slice = MAX_TIME_SLICE;
ffffffffc0206b20:	4795                	li	a5,5
    sched_class = &default_sched_class;
ffffffffc0206b22:	000d9417          	auipc	s0,0xd9
ffffffffc0206b26:	86640413          	addi	s0,s0,-1946 # ffffffffc02df388 <sched_class>
    rq->max_time_slice = MAX_TIME_SLICE;
ffffffffc0206b2a:	cb5c                	sw	a5,20(a4)
    sched_class->init(rq);
ffffffffc0206b2c:	853a                	mv	a0,a4
    sched_class = &default_sched_class;
ffffffffc0206b2e:	e014                	sd	a3,0(s0)
    rq = &__rq;
ffffffffc0206b30:	000d9797          	auipc	a5,0xd9
ffffffffc0206b34:	84e7b823          	sd	a4,-1968(a5) # ffffffffc02df380 <rq>
    sched_class->init(rq);
ffffffffc0206b38:	9602                	jalr	a2

    cprintf("sched class: %s\n", sched_class->name);
ffffffffc0206b3a:	601c                	ld	a5,0(s0)
}
ffffffffc0206b3c:	6402                	ld	s0,0(sp)
ffffffffc0206b3e:	60a2                	ld	ra,8(sp)
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc0206b40:	638c                	ld	a1,0(a5)
ffffffffc0206b42:	00003517          	auipc	a0,0x3
ffffffffc0206b46:	24650513          	addi	a0,a0,582 # ffffffffc0209d88 <default_pmm_manager+0x1b00>
}
ffffffffc0206b4a:	0141                	addi	sp,sp,16
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc0206b4c:	e46f906f          	j	ffffffffc0200192 <cprintf>

ffffffffc0206b50 <wakeup_proc>:

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206b50:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0206b52:	1101                	addi	sp,sp,-32
ffffffffc0206b54:	ec06                	sd	ra,24(sp)
ffffffffc0206b56:	e822                	sd	s0,16(sp)
ffffffffc0206b58:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206b5a:	478d                	li	a5,3
ffffffffc0206b5c:	08f70763          	beq	a4,a5,ffffffffc0206bea <wakeup_proc+0x9a>
ffffffffc0206b60:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206b62:	100027f3          	csrr	a5,sstatus
ffffffffc0206b66:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0206b68:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206b6a:	ebbd                	bnez	a5,ffffffffc0206be0 <wakeup_proc+0x90>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0206b6c:	4789                	li	a5,2
ffffffffc0206b6e:	04f70c63          	beq	a4,a5,ffffffffc0206bc6 <wakeup_proc+0x76>
            proc->state = PROC_RUNNABLE;
            proc->wait_state = 0;
            if (proc != current) {
ffffffffc0206b72:	000d8717          	auipc	a4,0xd8
ffffffffc0206b76:	7ee70713          	addi	a4,a4,2030 # ffffffffc02df360 <current>
ffffffffc0206b7a:	6318                	ld	a4,0(a4)
            proc->wait_state = 0;
ffffffffc0206b7c:	0e042623          	sw	zero,236(s0)
            proc->state = PROC_RUNNABLE;
ffffffffc0206b80:	c01c                	sw	a5,0(s0)
            if (proc != current) {
ffffffffc0206b82:	02870663          	beq	a4,s0,ffffffffc0206bae <wakeup_proc+0x5e>
    if (proc != idleproc) {
ffffffffc0206b86:	000d8797          	auipc	a5,0xd8
ffffffffc0206b8a:	7e278793          	addi	a5,a5,2018 # ffffffffc02df368 <idleproc>
ffffffffc0206b8e:	639c                	ld	a5,0(a5)
ffffffffc0206b90:	00f40f63          	beq	s0,a5,ffffffffc0206bae <wakeup_proc+0x5e>
        sched_class->enqueue(rq, proc);
ffffffffc0206b94:	000d8797          	auipc	a5,0xd8
ffffffffc0206b98:	7f478793          	addi	a5,a5,2036 # ffffffffc02df388 <sched_class>
ffffffffc0206b9c:	639c                	ld	a5,0(a5)
ffffffffc0206b9e:	000d8717          	auipc	a4,0xd8
ffffffffc0206ba2:	7e270713          	addi	a4,a4,2018 # ffffffffc02df380 <rq>
ffffffffc0206ba6:	6308                	ld	a0,0(a4)
ffffffffc0206ba8:	6b9c                	ld	a5,16(a5)
ffffffffc0206baa:	85a2                	mv	a1,s0
ffffffffc0206bac:	9782                	jalr	a5
    if (flag) {
ffffffffc0206bae:	e491                	bnez	s1,ffffffffc0206bba <wakeup_proc+0x6a>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206bb0:	60e2                	ld	ra,24(sp)
ffffffffc0206bb2:	6442                	ld	s0,16(sp)
ffffffffc0206bb4:	64a2                	ld	s1,8(sp)
ffffffffc0206bb6:	6105                	addi	sp,sp,32
ffffffffc0206bb8:	8082                	ret
ffffffffc0206bba:	6442                	ld	s0,16(sp)
ffffffffc0206bbc:	60e2                	ld	ra,24(sp)
ffffffffc0206bbe:	64a2                	ld	s1,8(sp)
ffffffffc0206bc0:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0206bc2:	a8bf906f          	j	ffffffffc020064c <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0206bc6:	00003617          	auipc	a2,0x3
ffffffffc0206bca:	21260613          	addi	a2,a2,530 # ffffffffc0209dd8 <default_pmm_manager+0x1b50>
ffffffffc0206bce:	04800593          	li	a1,72
ffffffffc0206bd2:	00003517          	auipc	a0,0x3
ffffffffc0206bd6:	1ee50513          	addi	a0,a0,494 # ffffffffc0209dc0 <default_pmm_manager+0x1b38>
ffffffffc0206bda:	91bf90ef          	jal	ra,ffffffffc02004f4 <__warn>
ffffffffc0206bde:	bfc1                	j	ffffffffc0206bae <wakeup_proc+0x5e>
        intr_disable();
ffffffffc0206be0:	a73f90ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0206be4:	4018                	lw	a4,0(s0)
ffffffffc0206be6:	4485                	li	s1,1
ffffffffc0206be8:	b751                	j	ffffffffc0206b6c <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206bea:	00003697          	auipc	a3,0x3
ffffffffc0206bee:	1b668693          	addi	a3,a3,438 # ffffffffc0209da0 <default_pmm_manager+0x1b18>
ffffffffc0206bf2:	00001617          	auipc	a2,0x1
ffffffffc0206bf6:	f4e60613          	addi	a2,a2,-178 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0206bfa:	03c00593          	li	a1,60
ffffffffc0206bfe:	00003517          	auipc	a0,0x3
ffffffffc0206c02:	1c250513          	addi	a0,a0,450 # ffffffffc0209dc0 <default_pmm_manager+0x1b38>
ffffffffc0206c06:	883f90ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0206c0a <schedule>:

void
schedule(void) {
ffffffffc0206c0a:	7179                	addi	sp,sp,-48
ffffffffc0206c0c:	f406                	sd	ra,40(sp)
ffffffffc0206c0e:	f022                	sd	s0,32(sp)
ffffffffc0206c10:	ec26                	sd	s1,24(sp)
ffffffffc0206c12:	e84a                	sd	s2,16(sp)
ffffffffc0206c14:	e44e                	sd	s3,8(sp)
ffffffffc0206c16:	e052                	sd	s4,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206c18:	100027f3          	csrr	a5,sstatus
ffffffffc0206c1c:	8b89                	andi	a5,a5,2
ffffffffc0206c1e:	4a01                	li	s4,0
ffffffffc0206c20:	e7d5                	bnez	a5,ffffffffc0206ccc <schedule+0xc2>
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0206c22:	000d8497          	auipc	s1,0xd8
ffffffffc0206c26:	73e48493          	addi	s1,s1,1854 # ffffffffc02df360 <current>
ffffffffc0206c2a:	608c                	ld	a1,0(s1)
ffffffffc0206c2c:	000d8997          	auipc	s3,0xd8
ffffffffc0206c30:	75c98993          	addi	s3,s3,1884 # ffffffffc02df388 <sched_class>
ffffffffc0206c34:	000d8917          	auipc	s2,0xd8
ffffffffc0206c38:	74c90913          	addi	s2,s2,1868 # ffffffffc02df380 <rq>
        if (current->state == PROC_RUNNABLE) {
ffffffffc0206c3c:	4194                	lw	a3,0(a1)
        current->need_resched = 0;
ffffffffc0206c3e:	0005bc23          	sd	zero,24(a1)
        if (current->state == PROC_RUNNABLE) {
ffffffffc0206c42:	4709                	li	a4,2
ffffffffc0206c44:	0009b783          	ld	a5,0(s3)
ffffffffc0206c48:	00093503          	ld	a0,0(s2)
ffffffffc0206c4c:	04e68063          	beq	a3,a4,ffffffffc0206c8c <schedule+0x82>
    return sched_class->pick_next(rq);
ffffffffc0206c50:	739c                	ld	a5,32(a5)
ffffffffc0206c52:	9782                	jalr	a5
ffffffffc0206c54:	842a                	mv	s0,a0
            sched_class_enqueue(current);
        }
        if ((next = sched_class_pick_next()) != NULL) {
ffffffffc0206c56:	cd21                	beqz	a0,ffffffffc0206cae <schedule+0xa4>
    sched_class->dequeue(rq, proc);
ffffffffc0206c58:	0009b783          	ld	a5,0(s3)
ffffffffc0206c5c:	00093503          	ld	a0,0(s2)
ffffffffc0206c60:	85a2                	mv	a1,s0
ffffffffc0206c62:	6f9c                	ld	a5,24(a5)
ffffffffc0206c64:	9782                	jalr	a5
            sched_class_dequeue(next);
        }
        if (next == NULL) {
            next = idleproc;
        }
        next->runs ++;
ffffffffc0206c66:	441c                	lw	a5,8(s0)
        if (next != current) {
ffffffffc0206c68:	6098                	ld	a4,0(s1)
        next->runs ++;
ffffffffc0206c6a:	2785                	addiw	a5,a5,1
ffffffffc0206c6c:	c41c                	sw	a5,8(s0)
        if (next != current) {
ffffffffc0206c6e:	00870563          	beq	a4,s0,ffffffffc0206c78 <schedule+0x6e>
            proc_run(next);
ffffffffc0206c72:	8522                	mv	a0,s0
ffffffffc0206c74:	b41fe0ef          	jal	ra,ffffffffc02057b4 <proc_run>
    if (flag) {
ffffffffc0206c78:	040a1163          	bnez	s4,ffffffffc0206cba <schedule+0xb0>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206c7c:	70a2                	ld	ra,40(sp)
ffffffffc0206c7e:	7402                	ld	s0,32(sp)
ffffffffc0206c80:	64e2                	ld	s1,24(sp)
ffffffffc0206c82:	6942                	ld	s2,16(sp)
ffffffffc0206c84:	69a2                	ld	s3,8(sp)
ffffffffc0206c86:	6a02                	ld	s4,0(sp)
ffffffffc0206c88:	6145                	addi	sp,sp,48
ffffffffc0206c8a:	8082                	ret
    if (proc != idleproc) {
ffffffffc0206c8c:	000d8717          	auipc	a4,0xd8
ffffffffc0206c90:	6dc70713          	addi	a4,a4,1756 # ffffffffc02df368 <idleproc>
ffffffffc0206c94:	6318                	ld	a4,0(a4)
ffffffffc0206c96:	fae58de3          	beq	a1,a4,ffffffffc0206c50 <schedule+0x46>
        sched_class->enqueue(rq, proc);
ffffffffc0206c9a:	6b9c                	ld	a5,16(a5)
ffffffffc0206c9c:	9782                	jalr	a5
ffffffffc0206c9e:	0009b783          	ld	a5,0(s3)
ffffffffc0206ca2:	00093503          	ld	a0,0(s2)
    return sched_class->pick_next(rq);
ffffffffc0206ca6:	739c                	ld	a5,32(a5)
ffffffffc0206ca8:	9782                	jalr	a5
ffffffffc0206caa:	842a                	mv	s0,a0
        if ((next = sched_class_pick_next()) != NULL) {
ffffffffc0206cac:	f555                	bnez	a0,ffffffffc0206c58 <schedule+0x4e>
            next = idleproc;
ffffffffc0206cae:	000d8797          	auipc	a5,0xd8
ffffffffc0206cb2:	6ba78793          	addi	a5,a5,1722 # ffffffffc02df368 <idleproc>
ffffffffc0206cb6:	6380                	ld	s0,0(a5)
ffffffffc0206cb8:	b77d                	j	ffffffffc0206c66 <schedule+0x5c>
}
ffffffffc0206cba:	7402                	ld	s0,32(sp)
ffffffffc0206cbc:	70a2                	ld	ra,40(sp)
ffffffffc0206cbe:	64e2                	ld	s1,24(sp)
ffffffffc0206cc0:	6942                	ld	s2,16(sp)
ffffffffc0206cc2:	69a2                	ld	s3,8(sp)
ffffffffc0206cc4:	6a02                	ld	s4,0(sp)
ffffffffc0206cc6:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0206cc8:	985f906f          	j	ffffffffc020064c <intr_enable>
        intr_disable();
ffffffffc0206ccc:	987f90ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0206cd0:	4a05                	li	s4,1
ffffffffc0206cd2:	bf81                	j	ffffffffc0206c22 <schedule+0x18>

ffffffffc0206cd4 <add_timer>:

// add timer to timer_list
void
add_timer(timer_t *timer) {
ffffffffc0206cd4:	1101                	addi	sp,sp,-32
ffffffffc0206cd6:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206cd8:	100027f3          	csrr	a5,sstatus
ffffffffc0206cdc:	8b89                	andi	a5,a5,2
ffffffffc0206cde:	4801                	li	a6,0
ffffffffc0206ce0:	eba5                	bnez	a5,ffffffffc0206d50 <add_timer+0x7c>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        assert(timer->expires > 0 && timer->proc != NULL);
ffffffffc0206ce2:	411c                	lw	a5,0(a0)
ffffffffc0206ce4:	cfa5                	beqz	a5,ffffffffc0206d5c <add_timer+0x88>
ffffffffc0206ce6:	6518                	ld	a4,8(a0)
ffffffffc0206ce8:	cb35                	beqz	a4,ffffffffc0206d5c <add_timer+0x88>
        assert(list_empty(&(timer->timer_link)));
ffffffffc0206cea:	6d18                	ld	a4,24(a0)
ffffffffc0206cec:	01050593          	addi	a1,a0,16
ffffffffc0206cf0:	08e59663          	bne	a1,a4,ffffffffc0206d7c <add_timer+0xa8>
    return listelm->next;
ffffffffc0206cf4:	000d8617          	auipc	a2,0xd8
ffffffffc0206cf8:	62c60613          	addi	a2,a2,1580 # ffffffffc02df320 <timer_list>
ffffffffc0206cfc:	6618                	ld	a4,8(a2)
        list_entry_t *le = list_next(&timer_list);
        while (le != &timer_list) {
ffffffffc0206cfe:	00c71863          	bne	a4,a2,ffffffffc0206d0e <add_timer+0x3a>
ffffffffc0206d02:	a80d                	j	ffffffffc0206d34 <add_timer+0x60>
ffffffffc0206d04:	6718                	ld	a4,8(a4)
            timer_t *next = le2timer(le, timer_link);
            if (timer->expires < next->expires) {
                next->expires -= timer->expires;
                break;
            }
            timer->expires -= next->expires;
ffffffffc0206d06:	9f95                	subw	a5,a5,a3
ffffffffc0206d08:	c11c                	sw	a5,0(a0)
        while (le != &timer_list) {
ffffffffc0206d0a:	02c70563          	beq	a4,a2,ffffffffc0206d34 <add_timer+0x60>
            if (timer->expires < next->expires) {
ffffffffc0206d0e:	ff072683          	lw	a3,-16(a4)
ffffffffc0206d12:	fed7f9e3          	bleu	a3,a5,ffffffffc0206d04 <add_timer+0x30>
                next->expires -= timer->expires;
ffffffffc0206d16:	40f687bb          	subw	a5,a3,a5
ffffffffc0206d1a:	fef72823          	sw	a5,-16(a4)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0206d1e:	631c                	ld	a5,0(a4)
    prev->next = next->prev = elm;
ffffffffc0206d20:	e30c                	sd	a1,0(a4)
ffffffffc0206d22:	e78c                	sd	a1,8(a5)
    elm->next = next;
ffffffffc0206d24:	ed18                	sd	a4,24(a0)
    elm->prev = prev;
ffffffffc0206d26:	e91c                	sd	a5,16(a0)
    if (flag) {
ffffffffc0206d28:	02080163          	beqz	a6,ffffffffc0206d4a <add_timer+0x76>
            le = list_next(le);
        }
        list_add_before(le, &(timer->timer_link));
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206d2c:	60e2                	ld	ra,24(sp)
ffffffffc0206d2e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0206d30:	91df906f          	j	ffffffffc020064c <intr_enable>
    return 0;
ffffffffc0206d34:	000d8717          	auipc	a4,0xd8
ffffffffc0206d38:	5ec70713          	addi	a4,a4,1516 # ffffffffc02df320 <timer_list>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0206d3c:	631c                	ld	a5,0(a4)
    prev->next = next->prev = elm;
ffffffffc0206d3e:	e30c                	sd	a1,0(a4)
ffffffffc0206d40:	e78c                	sd	a1,8(a5)
    elm->next = next;
ffffffffc0206d42:	ed18                	sd	a4,24(a0)
    elm->prev = prev;
ffffffffc0206d44:	e91c                	sd	a5,16(a0)
    if (flag) {
ffffffffc0206d46:	fe0813e3          	bnez	a6,ffffffffc0206d2c <add_timer+0x58>
ffffffffc0206d4a:	60e2                	ld	ra,24(sp)
ffffffffc0206d4c:	6105                	addi	sp,sp,32
ffffffffc0206d4e:	8082                	ret
ffffffffc0206d50:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0206d52:	901f90ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0206d56:	4805                	li	a6,1
ffffffffc0206d58:	6522                	ld	a0,8(sp)
ffffffffc0206d5a:	b761                	j	ffffffffc0206ce2 <add_timer+0xe>
        assert(timer->expires > 0 && timer->proc != NULL);
ffffffffc0206d5c:	00003697          	auipc	a3,0x3
ffffffffc0206d60:	f7468693          	addi	a3,a3,-140 # ffffffffc0209cd0 <default_pmm_manager+0x1a48>
ffffffffc0206d64:	00001617          	auipc	a2,0x1
ffffffffc0206d68:	ddc60613          	addi	a2,a2,-548 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0206d6c:	06c00593          	li	a1,108
ffffffffc0206d70:	00003517          	auipc	a0,0x3
ffffffffc0206d74:	05050513          	addi	a0,a0,80 # ffffffffc0209dc0 <default_pmm_manager+0x1b38>
ffffffffc0206d78:	f10f90ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(list_empty(&(timer->timer_link)));
ffffffffc0206d7c:	00003697          	auipc	a3,0x3
ffffffffc0206d80:	f8468693          	addi	a3,a3,-124 # ffffffffc0209d00 <default_pmm_manager+0x1a78>
ffffffffc0206d84:	00001617          	auipc	a2,0x1
ffffffffc0206d88:	dbc60613          	addi	a2,a2,-580 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0206d8c:	06d00593          	li	a1,109
ffffffffc0206d90:	00003517          	auipc	a0,0x3
ffffffffc0206d94:	03050513          	addi	a0,a0,48 # ffffffffc0209dc0 <default_pmm_manager+0x1b38>
ffffffffc0206d98:	ef0f90ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0206d9c <del_timer>:

// del timer from timer_list
void
del_timer(timer_t *timer) {
ffffffffc0206d9c:	1101                	addi	sp,sp,-32
ffffffffc0206d9e:	ec06                	sd	ra,24(sp)
ffffffffc0206da0:	e822                	sd	s0,16(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206da2:	100027f3          	csrr	a5,sstatus
ffffffffc0206da6:	8b89                	andi	a5,a5,2
ffffffffc0206da8:	01050413          	addi	s0,a0,16
ffffffffc0206dac:	e7a9                	bnez	a5,ffffffffc0206df6 <del_timer+0x5a>
    return list->next == list;
ffffffffc0206dae:	6d1c                	ld	a5,24(a0)
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (!list_empty(&(timer->timer_link))) {
ffffffffc0206db0:	02f40f63          	beq	s0,a5,ffffffffc0206dee <del_timer+0x52>
            if (timer->expires != 0) {
ffffffffc0206db4:	4114                	lw	a3,0(a0)
ffffffffc0206db6:	6918                	ld	a4,16(a0)
ffffffffc0206db8:	c69d                	beqz	a3,ffffffffc0206de6 <del_timer+0x4a>
                list_entry_t *le = list_next(&(timer->timer_link));
                if (le != &timer_list) {
ffffffffc0206dba:	000d8617          	auipc	a2,0xd8
ffffffffc0206dbe:	56660613          	addi	a2,a2,1382 # ffffffffc02df320 <timer_list>
    return 0;
ffffffffc0206dc2:	4581                	li	a1,0
ffffffffc0206dc4:	02c78163          	beq	a5,a2,ffffffffc0206de6 <del_timer+0x4a>
                    timer_t *next = le2timer(le, timer_link);
                    next->expires += timer->expires;
ffffffffc0206dc8:	ff07a603          	lw	a2,-16(a5)
ffffffffc0206dcc:	9eb1                	addw	a3,a3,a2
ffffffffc0206dce:	fed7a823          	sw	a3,-16(a5)
    prev->next = next;
ffffffffc0206dd2:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0206dd4:	e398                	sd	a4,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0206dd6:	ed00                	sd	s0,24(a0)
ffffffffc0206dd8:	e900                	sd	s0,16(a0)
    if (flag) {
ffffffffc0206dda:	c991                	beqz	a1,ffffffffc0206dee <del_timer+0x52>
            }
            list_del_init(&(timer->timer_link));
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206ddc:	6442                	ld	s0,16(sp)
ffffffffc0206dde:	60e2                	ld	ra,24(sp)
ffffffffc0206de0:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0206de2:	86bf906f          	j	ffffffffc020064c <intr_enable>
    prev->next = next;
ffffffffc0206de6:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0206de8:	e398                	sd	a4,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0206dea:	ed00                	sd	s0,24(a0)
ffffffffc0206dec:	e900                	sd	s0,16(a0)
ffffffffc0206dee:	60e2                	ld	ra,24(sp)
ffffffffc0206df0:	6442                	ld	s0,16(sp)
ffffffffc0206df2:	6105                	addi	sp,sp,32
ffffffffc0206df4:	8082                	ret
ffffffffc0206df6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0206df8:	85bf90ef          	jal	ra,ffffffffc0200652 <intr_disable>
    return list->next == list;
ffffffffc0206dfc:	6522                	ld	a0,8(sp)
ffffffffc0206dfe:	6d1c                	ld	a5,24(a0)
        if (!list_empty(&(timer->timer_link))) {
ffffffffc0206e00:	fc878ee3          	beq	a5,s0,ffffffffc0206ddc <del_timer+0x40>
            if (timer->expires != 0) {
ffffffffc0206e04:	4114                	lw	a3,0(a0)
ffffffffc0206e06:	6918                	ld	a4,16(a0)
ffffffffc0206e08:	ca81                	beqz	a3,ffffffffc0206e18 <del_timer+0x7c>
                if (le != &timer_list) {
ffffffffc0206e0a:	000d8617          	auipc	a2,0xd8
ffffffffc0206e0e:	51660613          	addi	a2,a2,1302 # ffffffffc02df320 <timer_list>
        return 1;
ffffffffc0206e12:	4585                	li	a1,1
ffffffffc0206e14:	fac79ae3          	bne	a5,a2,ffffffffc0206dc8 <del_timer+0x2c>
    prev->next = next;
ffffffffc0206e18:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0206e1a:	e398                	sd	a4,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0206e1c:	ed00                	sd	s0,24(a0)
ffffffffc0206e1e:	e900                	sd	s0,16(a0)
    if (flag) {
ffffffffc0206e20:	bf75                	j	ffffffffc0206ddc <del_timer+0x40>

ffffffffc0206e22 <run_timer_list>:

// call scheduler to update tick related info, and check the timer is expired? If expired, then wakup proc
void
run_timer_list(void) {
ffffffffc0206e22:	7139                	addi	sp,sp,-64
ffffffffc0206e24:	fc06                	sd	ra,56(sp)
ffffffffc0206e26:	f822                	sd	s0,48(sp)
ffffffffc0206e28:	f426                	sd	s1,40(sp)
ffffffffc0206e2a:	f04a                	sd	s2,32(sp)
ffffffffc0206e2c:	ec4e                	sd	s3,24(sp)
ffffffffc0206e2e:	e852                	sd	s4,16(sp)
ffffffffc0206e30:	e456                	sd	s5,8(sp)
ffffffffc0206e32:	e05a                	sd	s6,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206e34:	100027f3          	csrr	a5,sstatus
ffffffffc0206e38:	8b89                	andi	a5,a5,2
ffffffffc0206e3a:	4b01                	li	s6,0
ffffffffc0206e3c:	e3fd                	bnez	a5,ffffffffc0206f22 <run_timer_list+0x100>
    return listelm->next;
ffffffffc0206e3e:	000d8997          	auipc	s3,0xd8
ffffffffc0206e42:	4e298993          	addi	s3,s3,1250 # ffffffffc02df320 <timer_list>
ffffffffc0206e46:	0089b403          	ld	s0,8(s3)
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        list_entry_t *le = list_next(&timer_list);
        if (le != &timer_list) {
ffffffffc0206e4a:	07340a63          	beq	s0,s3,ffffffffc0206ebe <run_timer_list+0x9c>
            timer_t *timer = le2timer(le, timer_link);
            assert(timer->expires != 0);
ffffffffc0206e4e:	ff042783          	lw	a5,-16(s0)
            timer_t *timer = le2timer(le, timer_link);
ffffffffc0206e52:	ff040913          	addi	s2,s0,-16
            assert(timer->expires != 0);
ffffffffc0206e56:	0e078a63          	beqz	a5,ffffffffc0206f4a <run_timer_list+0x128>
            timer->expires --;
ffffffffc0206e5a:	fff7871b          	addiw	a4,a5,-1
ffffffffc0206e5e:	fee42823          	sw	a4,-16(s0)
            while (timer->expires == 0) {
ffffffffc0206e62:	ef31                	bnez	a4,ffffffffc0206ebe <run_timer_list+0x9c>
                struct proc_struct *proc = timer->proc;
                if (proc->wait_state != 0) {
                    assert(proc->wait_state & WT_INTERRUPTED);
                }
                else {
                    warn("process %d's wait_state == 0.\n", proc->pid);
ffffffffc0206e64:	00003a97          	auipc	s5,0x3
ffffffffc0206e68:	f04a8a93          	addi	s5,s5,-252 # ffffffffc0209d68 <default_pmm_manager+0x1ae0>
ffffffffc0206e6c:	00003a17          	auipc	s4,0x3
ffffffffc0206e70:	f54a0a13          	addi	s4,s4,-172 # ffffffffc0209dc0 <default_pmm_manager+0x1b38>
ffffffffc0206e74:	a005                	j	ffffffffc0206e94 <run_timer_list+0x72>
                    assert(proc->wait_state & WT_INTERRUPTED);
ffffffffc0206e76:	0a07da63          	bgez	a5,ffffffffc0206f2a <run_timer_list+0x108>
                }
                wakeup_proc(proc);
ffffffffc0206e7a:	8526                	mv	a0,s1
ffffffffc0206e7c:	cd5ff0ef          	jal	ra,ffffffffc0206b50 <wakeup_proc>
                del_timer(timer);
ffffffffc0206e80:	854a                	mv	a0,s2
ffffffffc0206e82:	f1bff0ef          	jal	ra,ffffffffc0206d9c <del_timer>
                if (le == &timer_list) {
ffffffffc0206e86:	03340c63          	beq	s0,s3,ffffffffc0206ebe <run_timer_list+0x9c>
            while (timer->expires == 0) {
ffffffffc0206e8a:	ff042783          	lw	a5,-16(s0)
                    break;
                }
                timer = le2timer(le, timer_link);
ffffffffc0206e8e:	ff040913          	addi	s2,s0,-16
            while (timer->expires == 0) {
ffffffffc0206e92:	e795                	bnez	a5,ffffffffc0206ebe <run_timer_list+0x9c>
                struct proc_struct *proc = timer->proc;
ffffffffc0206e94:	00893483          	ld	s1,8(s2)
ffffffffc0206e98:	6400                	ld	s0,8(s0)
                if (proc->wait_state != 0) {
ffffffffc0206e9a:	0ec4a783          	lw	a5,236(s1)
ffffffffc0206e9e:	ffe1                	bnez	a5,ffffffffc0206e76 <run_timer_list+0x54>
                    warn("process %d's wait_state == 0.\n", proc->pid);
ffffffffc0206ea0:	40d4                	lw	a3,4(s1)
ffffffffc0206ea2:	8656                	mv	a2,s5
ffffffffc0206ea4:	0a300593          	li	a1,163
ffffffffc0206ea8:	8552                	mv	a0,s4
ffffffffc0206eaa:	e4af90ef          	jal	ra,ffffffffc02004f4 <__warn>
                wakeup_proc(proc);
ffffffffc0206eae:	8526                	mv	a0,s1
ffffffffc0206eb0:	ca1ff0ef          	jal	ra,ffffffffc0206b50 <wakeup_proc>
                del_timer(timer);
ffffffffc0206eb4:	854a                	mv	a0,s2
ffffffffc0206eb6:	ee7ff0ef          	jal	ra,ffffffffc0206d9c <del_timer>
                if (le == &timer_list) {
ffffffffc0206eba:	fd3418e3          	bne	s0,s3,ffffffffc0206e8a <run_timer_list+0x68>
            }
        }
        sched_class_proc_tick(current);
ffffffffc0206ebe:	000d8797          	auipc	a5,0xd8
ffffffffc0206ec2:	4a278793          	addi	a5,a5,1186 # ffffffffc02df360 <current>
ffffffffc0206ec6:	638c                	ld	a1,0(a5)
    if (proc != idleproc) {
ffffffffc0206ec8:	000d8797          	auipc	a5,0xd8
ffffffffc0206ecc:	4a078793          	addi	a5,a5,1184 # ffffffffc02df368 <idleproc>
ffffffffc0206ed0:	639c                	ld	a5,0(a5)
ffffffffc0206ed2:	04f58563          	beq	a1,a5,ffffffffc0206f1c <run_timer_list+0xfa>
        sched_class->proc_tick(rq, proc);
ffffffffc0206ed6:	000d8797          	auipc	a5,0xd8
ffffffffc0206eda:	4b278793          	addi	a5,a5,1202 # ffffffffc02df388 <sched_class>
ffffffffc0206ede:	639c                	ld	a5,0(a5)
ffffffffc0206ee0:	000d8717          	auipc	a4,0xd8
ffffffffc0206ee4:	4a070713          	addi	a4,a4,1184 # ffffffffc02df380 <rq>
ffffffffc0206ee8:	6308                	ld	a0,0(a4)
ffffffffc0206eea:	779c                	ld	a5,40(a5)
ffffffffc0206eec:	9782                	jalr	a5
    if (flag) {
ffffffffc0206eee:	000b1c63          	bnez	s6,ffffffffc0206f06 <run_timer_list+0xe4>
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206ef2:	70e2                	ld	ra,56(sp)
ffffffffc0206ef4:	7442                	ld	s0,48(sp)
ffffffffc0206ef6:	74a2                	ld	s1,40(sp)
ffffffffc0206ef8:	7902                	ld	s2,32(sp)
ffffffffc0206efa:	69e2                	ld	s3,24(sp)
ffffffffc0206efc:	6a42                	ld	s4,16(sp)
ffffffffc0206efe:	6aa2                	ld	s5,8(sp)
ffffffffc0206f00:	6b02                	ld	s6,0(sp)
ffffffffc0206f02:	6121                	addi	sp,sp,64
ffffffffc0206f04:	8082                	ret
ffffffffc0206f06:	7442                	ld	s0,48(sp)
ffffffffc0206f08:	70e2                	ld	ra,56(sp)
ffffffffc0206f0a:	74a2                	ld	s1,40(sp)
ffffffffc0206f0c:	7902                	ld	s2,32(sp)
ffffffffc0206f0e:	69e2                	ld	s3,24(sp)
ffffffffc0206f10:	6a42                	ld	s4,16(sp)
ffffffffc0206f12:	6aa2                	ld	s5,8(sp)
ffffffffc0206f14:	6b02                	ld	s6,0(sp)
ffffffffc0206f16:	6121                	addi	sp,sp,64
        intr_enable();
ffffffffc0206f18:	f34f906f          	j	ffffffffc020064c <intr_enable>
        proc->need_resched = 1;
ffffffffc0206f1c:	4785                	li	a5,1
ffffffffc0206f1e:	ed9c                	sd	a5,24(a1)
ffffffffc0206f20:	b7f9                	j	ffffffffc0206eee <run_timer_list+0xcc>
        intr_disable();
ffffffffc0206f22:	f30f90ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0206f26:	4b05                	li	s6,1
ffffffffc0206f28:	bf19                	j	ffffffffc0206e3e <run_timer_list+0x1c>
                    assert(proc->wait_state & WT_INTERRUPTED);
ffffffffc0206f2a:	00003697          	auipc	a3,0x3
ffffffffc0206f2e:	e1668693          	addi	a3,a3,-490 # ffffffffc0209d40 <default_pmm_manager+0x1ab8>
ffffffffc0206f32:	00001617          	auipc	a2,0x1
ffffffffc0206f36:	c0e60613          	addi	a2,a2,-1010 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0206f3a:	0a000593          	li	a1,160
ffffffffc0206f3e:	00003517          	auipc	a0,0x3
ffffffffc0206f42:	e8250513          	addi	a0,a0,-382 # ffffffffc0209dc0 <default_pmm_manager+0x1b38>
ffffffffc0206f46:	d42f90ef          	jal	ra,ffffffffc0200488 <__panic>
            assert(timer->expires != 0);
ffffffffc0206f4a:	00003697          	auipc	a3,0x3
ffffffffc0206f4e:	dde68693          	addi	a3,a3,-546 # ffffffffc0209d28 <default_pmm_manager+0x1aa0>
ffffffffc0206f52:	00001617          	auipc	a2,0x1
ffffffffc0206f56:	bee60613          	addi	a2,a2,-1042 # ffffffffc0207b40 <commands+0x4c0>
ffffffffc0206f5a:	09a00593          	li	a1,154
ffffffffc0206f5e:	00003517          	auipc	a0,0x3
ffffffffc0206f62:	e6250513          	addi	a0,a0,-414 # ffffffffc0209dc0 <default_pmm_manager+0x1b38>
ffffffffc0206f66:	d22f90ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0206f6a <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0206f6a:	000d8797          	auipc	a5,0xd8
ffffffffc0206f6e:	3f678793          	addi	a5,a5,1014 # ffffffffc02df360 <current>
ffffffffc0206f72:	639c                	ld	a5,0(a5)
}
ffffffffc0206f74:	43c8                	lw	a0,4(a5)
ffffffffc0206f76:	8082                	ret

ffffffffc0206f78 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0206f78:	4501                	li	a0,0
ffffffffc0206f7a:	8082                	ret

ffffffffc0206f7c <sys_gettime>:
static int sys_gettime(uint64_t arg[]){
    return (int)ticks*10;
ffffffffc0206f7c:	000d8797          	auipc	a5,0xd8
ffffffffc0206f80:	41478793          	addi	a5,a5,1044 # ffffffffc02df390 <ticks>
ffffffffc0206f84:	639c                	ld	a5,0(a5)
ffffffffc0206f86:	0027951b          	slliw	a0,a5,0x2
ffffffffc0206f8a:	9d3d                	addw	a0,a0,a5
}
ffffffffc0206f8c:	0015151b          	slliw	a0,a0,0x1
ffffffffc0206f90:	8082                	ret

ffffffffc0206f92 <sys_lab6_set_priority>:
static int sys_lab6_set_priority(uint64_t arg[]){
    uint64_t priority = (uint64_t)arg[0];
    lab6_set_priority(priority);
ffffffffc0206f92:	4108                	lw	a0,0(a0)
static int sys_lab6_set_priority(uint64_t arg[]){
ffffffffc0206f94:	1141                	addi	sp,sp,-16
ffffffffc0206f96:	e406                	sd	ra,8(sp)
    lab6_set_priority(priority);
ffffffffc0206f98:	955ff0ef          	jal	ra,ffffffffc02068ec <lab6_set_priority>
    return 0;
}
ffffffffc0206f9c:	60a2                	ld	ra,8(sp)
ffffffffc0206f9e:	4501                	li	a0,0
ffffffffc0206fa0:	0141                	addi	sp,sp,16
ffffffffc0206fa2:	8082                	ret

ffffffffc0206fa4 <sys_putc>:
    cputchar(c);
ffffffffc0206fa4:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0206fa6:	1141                	addi	sp,sp,-16
ffffffffc0206fa8:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0206faa:	a1cf90ef          	jal	ra,ffffffffc02001c6 <cputchar>
}
ffffffffc0206fae:	60a2                	ld	ra,8(sp)
ffffffffc0206fb0:	4501                	li	a0,0
ffffffffc0206fb2:	0141                	addi	sp,sp,16
ffffffffc0206fb4:	8082                	ret

ffffffffc0206fb6 <sys_kill>:
    return do_kill(pid);
ffffffffc0206fb6:	4108                	lw	a0,0(a0)
ffffffffc0206fb8:	f86ff06f          	j	ffffffffc020673e <do_kill>

ffffffffc0206fbc <sys_sleep>:
static int
sys_sleep(uint64_t arg[]) {
    unsigned int time = (unsigned int)arg[0];
    return do_sleep(time);
ffffffffc0206fbc:	4108                	lw	a0,0(a0)
ffffffffc0206fbe:	96bff06f          	j	ffffffffc0206928 <do_sleep>

ffffffffc0206fc2 <sys_yield>:
    return do_yield();
ffffffffc0206fc2:	f2aff06f          	j	ffffffffc02066ec <do_yield>

ffffffffc0206fc6 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0206fc6:	6d14                	ld	a3,24(a0)
ffffffffc0206fc8:	6910                	ld	a2,16(a0)
ffffffffc0206fca:	650c                	ld	a1,8(a0)
ffffffffc0206fcc:	6108                	ld	a0,0(a0)
ffffffffc0206fce:	980ff06f          	j	ffffffffc020614e <do_execve>

ffffffffc0206fd2 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0206fd2:	650c                	ld	a1,8(a0)
ffffffffc0206fd4:	4108                	lw	a0,0(a0)
ffffffffc0206fd6:	f28ff06f          	j	ffffffffc02066fe <do_wait>

ffffffffc0206fda <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0206fda:	000d8797          	auipc	a5,0xd8
ffffffffc0206fde:	38678793          	addi	a5,a5,902 # ffffffffc02df360 <current>
ffffffffc0206fe2:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc0206fe4:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc0206fe6:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0206fe8:	6a0c                	ld	a1,16(a2)
ffffffffc0206fea:	893fe06f          	j	ffffffffc020587c <do_fork>

ffffffffc0206fee <sys_exit>:
    return do_exit(error_code);
ffffffffc0206fee:	4108                	lw	a0,0(a0)
ffffffffc0206ff0:	ccbfe06f          	j	ffffffffc0205cba <do_exit>

ffffffffc0206ff4 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0206ff4:	715d                	addi	sp,sp,-80
ffffffffc0206ff6:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206ff8:	000d8497          	auipc	s1,0xd8
ffffffffc0206ffc:	36848493          	addi	s1,s1,872 # ffffffffc02df360 <current>
ffffffffc0207000:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0207002:	e0a2                	sd	s0,64(sp)
ffffffffc0207004:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0207006:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0207008:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc020700a:	0ff00793          	li	a5,255
    int num = tf->gpr.a0;
ffffffffc020700e:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0207012:	0327ee63          	bltu	a5,s2,ffffffffc020704e <syscall+0x5a>
        if (syscalls[num] != NULL) {
ffffffffc0207016:	00391713          	slli	a4,s2,0x3
ffffffffc020701a:	00003797          	auipc	a5,0x3
ffffffffc020701e:	e2678793          	addi	a5,a5,-474 # ffffffffc0209e40 <syscalls>
ffffffffc0207022:	97ba                	add	a5,a5,a4
ffffffffc0207024:	639c                	ld	a5,0(a5)
ffffffffc0207026:	c785                	beqz	a5,ffffffffc020704e <syscall+0x5a>
            arg[0] = tf->gpr.a1;
ffffffffc0207028:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc020702a:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc020702c:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc020702e:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0207030:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0207032:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0207034:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0207036:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0207038:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc020703a:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc020703c:	0028                	addi	a0,sp,8
ffffffffc020703e:	9782                	jalr	a5
ffffffffc0207040:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0207042:	60a6                	ld	ra,72(sp)
ffffffffc0207044:	6406                	ld	s0,64(sp)
ffffffffc0207046:	74e2                	ld	s1,56(sp)
ffffffffc0207048:	7942                	ld	s2,48(sp)
ffffffffc020704a:	6161                	addi	sp,sp,80
ffffffffc020704c:	8082                	ret
    print_trapframe(tf);
ffffffffc020704e:	8522                	mv	a0,s0
ffffffffc0207050:	ff2f90ef          	jal	ra,ffffffffc0200842 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0207054:	609c                	ld	a5,0(s1)
ffffffffc0207056:	86ca                	mv	a3,s2
ffffffffc0207058:	00003617          	auipc	a2,0x3
ffffffffc020705c:	da060613          	addi	a2,a2,-608 # ffffffffc0209df8 <default_pmm_manager+0x1b70>
ffffffffc0207060:	43d8                	lw	a4,4(a5)
ffffffffc0207062:	07400593          	li	a1,116
ffffffffc0207066:	0b478793          	addi	a5,a5,180
ffffffffc020706a:	00003517          	auipc	a0,0x3
ffffffffc020706e:	dbe50513          	addi	a0,a0,-578 # ffffffffc0209e28 <default_pmm_manager+0x1ba0>
ffffffffc0207072:	c16f90ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0207076 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0207076:	9e3707b7          	lui	a5,0x9e370
ffffffffc020707a:	2785                	addiw	a5,a5,1
ffffffffc020707c:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0207080:	02000793          	li	a5,32
ffffffffc0207084:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0207088:	00b5553b          	srlw	a0,a0,a1
ffffffffc020708c:	8082                	ret

ffffffffc020708e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020708e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0207092:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0207094:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0207098:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020709a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020709e:	f022                	sd	s0,32(sp)
ffffffffc02070a0:	ec26                	sd	s1,24(sp)
ffffffffc02070a2:	e84a                	sd	s2,16(sp)
ffffffffc02070a4:	f406                	sd	ra,40(sp)
ffffffffc02070a6:	e44e                	sd	s3,8(sp)
ffffffffc02070a8:	84aa                	mv	s1,a0
ffffffffc02070aa:	892e                	mv	s2,a1
ffffffffc02070ac:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02070b0:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02070b2:	03067e63          	bleu	a6,a2,ffffffffc02070ee <printnum+0x60>
ffffffffc02070b6:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02070b8:	00805763          	blez	s0,ffffffffc02070c6 <printnum+0x38>
ffffffffc02070bc:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02070be:	85ca                	mv	a1,s2
ffffffffc02070c0:	854e                	mv	a0,s3
ffffffffc02070c2:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02070c4:	fc65                	bnez	s0,ffffffffc02070bc <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02070c6:	1a02                	slli	s4,s4,0x20
ffffffffc02070c8:	020a5a13          	srli	s4,s4,0x20
ffffffffc02070cc:	00003797          	auipc	a5,0x3
ffffffffc02070d0:	79478793          	addi	a5,a5,1940 # ffffffffc020a860 <error_string+0xc8>
ffffffffc02070d4:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02070d6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02070d8:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02070dc:	70a2                	ld	ra,40(sp)
ffffffffc02070de:	69a2                	ld	s3,8(sp)
ffffffffc02070e0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02070e2:	85ca                	mv	a1,s2
ffffffffc02070e4:	8326                	mv	t1,s1
}
ffffffffc02070e6:	6942                	ld	s2,16(sp)
ffffffffc02070e8:	64e2                	ld	s1,24(sp)
ffffffffc02070ea:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02070ec:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02070ee:	03065633          	divu	a2,a2,a6
ffffffffc02070f2:	8722                	mv	a4,s0
ffffffffc02070f4:	f9bff0ef          	jal	ra,ffffffffc020708e <printnum>
ffffffffc02070f8:	b7f9                	j	ffffffffc02070c6 <printnum+0x38>

ffffffffc02070fa <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02070fa:	7119                	addi	sp,sp,-128
ffffffffc02070fc:	f4a6                	sd	s1,104(sp)
ffffffffc02070fe:	f0ca                	sd	s2,96(sp)
ffffffffc0207100:	e8d2                	sd	s4,80(sp)
ffffffffc0207102:	e4d6                	sd	s5,72(sp)
ffffffffc0207104:	e0da                	sd	s6,64(sp)
ffffffffc0207106:	fc5e                	sd	s7,56(sp)
ffffffffc0207108:	f862                	sd	s8,48(sp)
ffffffffc020710a:	f06a                	sd	s10,32(sp)
ffffffffc020710c:	fc86                	sd	ra,120(sp)
ffffffffc020710e:	f8a2                	sd	s0,112(sp)
ffffffffc0207110:	ecce                	sd	s3,88(sp)
ffffffffc0207112:	f466                	sd	s9,40(sp)
ffffffffc0207114:	ec6e                	sd	s11,24(sp)
ffffffffc0207116:	892a                	mv	s2,a0
ffffffffc0207118:	84ae                	mv	s1,a1
ffffffffc020711a:	8d32                	mv	s10,a2
ffffffffc020711c:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020711e:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0207120:	00003a17          	auipc	s4,0x3
ffffffffc0207124:	520a0a13          	addi	s4,s4,1312 # ffffffffc020a640 <syscalls+0x800>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0207128:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020712c:	00003c17          	auipc	s8,0x3
ffffffffc0207130:	66cc0c13          	addi	s8,s8,1644 # ffffffffc020a798 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0207134:	000d4503          	lbu	a0,0(s10)
ffffffffc0207138:	02500793          	li	a5,37
ffffffffc020713c:	001d0413          	addi	s0,s10,1
ffffffffc0207140:	00f50e63          	beq	a0,a5,ffffffffc020715c <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0207144:	c521                	beqz	a0,ffffffffc020718c <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0207146:	02500993          	li	s3,37
ffffffffc020714a:	a011                	j	ffffffffc020714e <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc020714c:	c121                	beqz	a0,ffffffffc020718c <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc020714e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0207150:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0207152:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0207154:	fff44503          	lbu	a0,-1(s0)
ffffffffc0207158:	ff351ae3          	bne	a0,s3,ffffffffc020714c <vprintfmt+0x52>
ffffffffc020715c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0207160:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0207164:	4981                	li	s3,0
ffffffffc0207166:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0207168:	5cfd                	li	s9,-1
ffffffffc020716a:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020716c:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0207170:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0207172:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0207176:	0ff6f693          	andi	a3,a3,255
ffffffffc020717a:	00140d13          	addi	s10,s0,1
ffffffffc020717e:	20d5e563          	bltu	a1,a3,ffffffffc0207388 <vprintfmt+0x28e>
ffffffffc0207182:	068a                	slli	a3,a3,0x2
ffffffffc0207184:	96d2                	add	a3,a3,s4
ffffffffc0207186:	4294                	lw	a3,0(a3)
ffffffffc0207188:	96d2                	add	a3,a3,s4
ffffffffc020718a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020718c:	70e6                	ld	ra,120(sp)
ffffffffc020718e:	7446                	ld	s0,112(sp)
ffffffffc0207190:	74a6                	ld	s1,104(sp)
ffffffffc0207192:	7906                	ld	s2,96(sp)
ffffffffc0207194:	69e6                	ld	s3,88(sp)
ffffffffc0207196:	6a46                	ld	s4,80(sp)
ffffffffc0207198:	6aa6                	ld	s5,72(sp)
ffffffffc020719a:	6b06                	ld	s6,64(sp)
ffffffffc020719c:	7be2                	ld	s7,56(sp)
ffffffffc020719e:	7c42                	ld	s8,48(sp)
ffffffffc02071a0:	7ca2                	ld	s9,40(sp)
ffffffffc02071a2:	7d02                	ld	s10,32(sp)
ffffffffc02071a4:	6de2                	ld	s11,24(sp)
ffffffffc02071a6:	6109                	addi	sp,sp,128
ffffffffc02071a8:	8082                	ret
    if (lflag >= 2) {
ffffffffc02071aa:	4705                	li	a4,1
ffffffffc02071ac:	008a8593          	addi	a1,s5,8
ffffffffc02071b0:	01074463          	blt	a4,a6,ffffffffc02071b8 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc02071b4:	26080363          	beqz	a6,ffffffffc020741a <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc02071b8:	000ab603          	ld	a2,0(s5)
ffffffffc02071bc:	46c1                	li	a3,16
ffffffffc02071be:	8aae                	mv	s5,a1
ffffffffc02071c0:	a06d                	j	ffffffffc020726a <vprintfmt+0x170>
            goto reswitch;
ffffffffc02071c2:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02071c6:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02071c8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02071ca:	b765                	j	ffffffffc0207172 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc02071cc:	000aa503          	lw	a0,0(s5)
ffffffffc02071d0:	85a6                	mv	a1,s1
ffffffffc02071d2:	0aa1                	addi	s5,s5,8
ffffffffc02071d4:	9902                	jalr	s2
            break;
ffffffffc02071d6:	bfb9                	j	ffffffffc0207134 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02071d8:	4705                	li	a4,1
ffffffffc02071da:	008a8993          	addi	s3,s5,8
ffffffffc02071de:	01074463          	blt	a4,a6,ffffffffc02071e6 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02071e2:	22080463          	beqz	a6,ffffffffc020740a <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02071e6:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02071ea:	24044463          	bltz	s0,ffffffffc0207432 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02071ee:	8622                	mv	a2,s0
ffffffffc02071f0:	8ace                	mv	s5,s3
ffffffffc02071f2:	46a9                	li	a3,10
ffffffffc02071f4:	a89d                	j	ffffffffc020726a <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02071f6:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02071fa:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02071fc:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02071fe:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0207202:	8fb5                	xor	a5,a5,a3
ffffffffc0207204:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0207208:	1ad74363          	blt	a4,a3,ffffffffc02073ae <vprintfmt+0x2b4>
ffffffffc020720c:	00369793          	slli	a5,a3,0x3
ffffffffc0207210:	97e2                	add	a5,a5,s8
ffffffffc0207212:	639c                	ld	a5,0(a5)
ffffffffc0207214:	18078d63          	beqz	a5,ffffffffc02073ae <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0207218:	86be                	mv	a3,a5
ffffffffc020721a:	00000617          	auipc	a2,0x0
ffffffffc020721e:	35e60613          	addi	a2,a2,862 # ffffffffc0207578 <etext+0x2a>
ffffffffc0207222:	85a6                	mv	a1,s1
ffffffffc0207224:	854a                	mv	a0,s2
ffffffffc0207226:	240000ef          	jal	ra,ffffffffc0207466 <printfmt>
ffffffffc020722a:	b729                	j	ffffffffc0207134 <vprintfmt+0x3a>
            lflag ++;
ffffffffc020722c:	00144603          	lbu	a2,1(s0)
ffffffffc0207230:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0207232:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0207234:	bf3d                	j	ffffffffc0207172 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0207236:	4705                	li	a4,1
ffffffffc0207238:	008a8593          	addi	a1,s5,8
ffffffffc020723c:	01074463          	blt	a4,a6,ffffffffc0207244 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0207240:	1e080263          	beqz	a6,ffffffffc0207424 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0207244:	000ab603          	ld	a2,0(s5)
ffffffffc0207248:	46a1                	li	a3,8
ffffffffc020724a:	8aae                	mv	s5,a1
ffffffffc020724c:	a839                	j	ffffffffc020726a <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc020724e:	03000513          	li	a0,48
ffffffffc0207252:	85a6                	mv	a1,s1
ffffffffc0207254:	e03e                	sd	a5,0(sp)
ffffffffc0207256:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0207258:	85a6                	mv	a1,s1
ffffffffc020725a:	07800513          	li	a0,120
ffffffffc020725e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0207260:	0aa1                	addi	s5,s5,8
ffffffffc0207262:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0207266:	6782                	ld	a5,0(sp)
ffffffffc0207268:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020726a:	876e                	mv	a4,s11
ffffffffc020726c:	85a6                	mv	a1,s1
ffffffffc020726e:	854a                	mv	a0,s2
ffffffffc0207270:	e1fff0ef          	jal	ra,ffffffffc020708e <printnum>
            break;
ffffffffc0207274:	b5c1                	j	ffffffffc0207134 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0207276:	000ab603          	ld	a2,0(s5)
ffffffffc020727a:	0aa1                	addi	s5,s5,8
ffffffffc020727c:	1c060663          	beqz	a2,ffffffffc0207448 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0207280:	00160413          	addi	s0,a2,1
ffffffffc0207284:	17b05c63          	blez	s11,ffffffffc02073fc <vprintfmt+0x302>
ffffffffc0207288:	02d00593          	li	a1,45
ffffffffc020728c:	14b79263          	bne	a5,a1,ffffffffc02073d0 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0207290:	00064783          	lbu	a5,0(a2)
ffffffffc0207294:	0007851b          	sext.w	a0,a5
ffffffffc0207298:	c905                	beqz	a0,ffffffffc02072c8 <vprintfmt+0x1ce>
ffffffffc020729a:	000cc563          	bltz	s9,ffffffffc02072a4 <vprintfmt+0x1aa>
ffffffffc020729e:	3cfd                	addiw	s9,s9,-1
ffffffffc02072a0:	036c8263          	beq	s9,s6,ffffffffc02072c4 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc02072a4:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02072a6:	18098463          	beqz	s3,ffffffffc020742e <vprintfmt+0x334>
ffffffffc02072aa:	3781                	addiw	a5,a5,-32
ffffffffc02072ac:	18fbf163          	bleu	a5,s7,ffffffffc020742e <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc02072b0:	03f00513          	li	a0,63
ffffffffc02072b4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02072b6:	0405                	addi	s0,s0,1
ffffffffc02072b8:	fff44783          	lbu	a5,-1(s0)
ffffffffc02072bc:	3dfd                	addiw	s11,s11,-1
ffffffffc02072be:	0007851b          	sext.w	a0,a5
ffffffffc02072c2:	fd61                	bnez	a0,ffffffffc020729a <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc02072c4:	e7b058e3          	blez	s11,ffffffffc0207134 <vprintfmt+0x3a>
ffffffffc02072c8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02072ca:	85a6                	mv	a1,s1
ffffffffc02072cc:	02000513          	li	a0,32
ffffffffc02072d0:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02072d2:	e60d81e3          	beqz	s11,ffffffffc0207134 <vprintfmt+0x3a>
ffffffffc02072d6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02072d8:	85a6                	mv	a1,s1
ffffffffc02072da:	02000513          	li	a0,32
ffffffffc02072de:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02072e0:	fe0d94e3          	bnez	s11,ffffffffc02072c8 <vprintfmt+0x1ce>
ffffffffc02072e4:	bd81                	j	ffffffffc0207134 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02072e6:	4705                	li	a4,1
ffffffffc02072e8:	008a8593          	addi	a1,s5,8
ffffffffc02072ec:	01074463          	blt	a4,a6,ffffffffc02072f4 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02072f0:	12080063          	beqz	a6,ffffffffc0207410 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02072f4:	000ab603          	ld	a2,0(s5)
ffffffffc02072f8:	46a9                	li	a3,10
ffffffffc02072fa:	8aae                	mv	s5,a1
ffffffffc02072fc:	b7bd                	j	ffffffffc020726a <vprintfmt+0x170>
ffffffffc02072fe:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0207302:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0207306:	846a                	mv	s0,s10
ffffffffc0207308:	b5ad                	j	ffffffffc0207172 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc020730a:	85a6                	mv	a1,s1
ffffffffc020730c:	02500513          	li	a0,37
ffffffffc0207310:	9902                	jalr	s2
            break;
ffffffffc0207312:	b50d                	j	ffffffffc0207134 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0207314:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0207318:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020731c:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020731e:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0207320:	e40dd9e3          	bgez	s11,ffffffffc0207172 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0207324:	8de6                	mv	s11,s9
ffffffffc0207326:	5cfd                	li	s9,-1
ffffffffc0207328:	b5a9                	j	ffffffffc0207172 <vprintfmt+0x78>
            goto reswitch;
ffffffffc020732a:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc020732e:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0207332:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0207334:	bd3d                	j	ffffffffc0207172 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0207336:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc020733a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020733e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0207340:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0207344:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0207348:	fcd56ce3          	bltu	a0,a3,ffffffffc0207320 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc020734c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020734e:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0207352:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0207356:	0196873b          	addw	a4,a3,s9
ffffffffc020735a:	0017171b          	slliw	a4,a4,0x1
ffffffffc020735e:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0207362:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0207366:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020736a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020736e:	fcd57fe3          	bleu	a3,a0,ffffffffc020734c <vprintfmt+0x252>
ffffffffc0207372:	b77d                	j	ffffffffc0207320 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0207374:	fffdc693          	not	a3,s11
ffffffffc0207378:	96fd                	srai	a3,a3,0x3f
ffffffffc020737a:	00ddfdb3          	and	s11,s11,a3
ffffffffc020737e:	00144603          	lbu	a2,1(s0)
ffffffffc0207382:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0207384:	846a                	mv	s0,s10
ffffffffc0207386:	b3f5                	j	ffffffffc0207172 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0207388:	85a6                	mv	a1,s1
ffffffffc020738a:	02500513          	li	a0,37
ffffffffc020738e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0207390:	fff44703          	lbu	a4,-1(s0)
ffffffffc0207394:	02500793          	li	a5,37
ffffffffc0207398:	8d22                	mv	s10,s0
ffffffffc020739a:	d8f70de3          	beq	a4,a5,ffffffffc0207134 <vprintfmt+0x3a>
ffffffffc020739e:	02500713          	li	a4,37
ffffffffc02073a2:	1d7d                	addi	s10,s10,-1
ffffffffc02073a4:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02073a8:	fee79de3          	bne	a5,a4,ffffffffc02073a2 <vprintfmt+0x2a8>
ffffffffc02073ac:	b361                	j	ffffffffc0207134 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02073ae:	00003617          	auipc	a2,0x3
ffffffffc02073b2:	59260613          	addi	a2,a2,1426 # ffffffffc020a940 <error_string+0x1a8>
ffffffffc02073b6:	85a6                	mv	a1,s1
ffffffffc02073b8:	854a                	mv	a0,s2
ffffffffc02073ba:	0ac000ef          	jal	ra,ffffffffc0207466 <printfmt>
ffffffffc02073be:	bb9d                	j	ffffffffc0207134 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02073c0:	00003617          	auipc	a2,0x3
ffffffffc02073c4:	57860613          	addi	a2,a2,1400 # ffffffffc020a938 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc02073c8:	00003417          	auipc	s0,0x3
ffffffffc02073cc:	57140413          	addi	s0,s0,1393 # ffffffffc020a939 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02073d0:	8532                	mv	a0,a2
ffffffffc02073d2:	85e6                	mv	a1,s9
ffffffffc02073d4:	e032                	sd	a2,0(sp)
ffffffffc02073d6:	e43e                	sd	a5,8(sp)
ffffffffc02073d8:	0cc000ef          	jal	ra,ffffffffc02074a4 <strnlen>
ffffffffc02073dc:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02073e0:	6602                	ld	a2,0(sp)
ffffffffc02073e2:	01b05d63          	blez	s11,ffffffffc02073fc <vprintfmt+0x302>
ffffffffc02073e6:	67a2                	ld	a5,8(sp)
ffffffffc02073e8:	2781                	sext.w	a5,a5
ffffffffc02073ea:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02073ec:	6522                	ld	a0,8(sp)
ffffffffc02073ee:	85a6                	mv	a1,s1
ffffffffc02073f0:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02073f2:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02073f4:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02073f6:	6602                	ld	a2,0(sp)
ffffffffc02073f8:	fe0d9ae3          	bnez	s11,ffffffffc02073ec <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02073fc:	00064783          	lbu	a5,0(a2)
ffffffffc0207400:	0007851b          	sext.w	a0,a5
ffffffffc0207404:	e8051be3          	bnez	a0,ffffffffc020729a <vprintfmt+0x1a0>
ffffffffc0207408:	b335                	j	ffffffffc0207134 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc020740a:	000aa403          	lw	s0,0(s5)
ffffffffc020740e:	bbf1                	j	ffffffffc02071ea <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0207410:	000ae603          	lwu	a2,0(s5)
ffffffffc0207414:	46a9                	li	a3,10
ffffffffc0207416:	8aae                	mv	s5,a1
ffffffffc0207418:	bd89                	j	ffffffffc020726a <vprintfmt+0x170>
ffffffffc020741a:	000ae603          	lwu	a2,0(s5)
ffffffffc020741e:	46c1                	li	a3,16
ffffffffc0207420:	8aae                	mv	s5,a1
ffffffffc0207422:	b5a1                	j	ffffffffc020726a <vprintfmt+0x170>
ffffffffc0207424:	000ae603          	lwu	a2,0(s5)
ffffffffc0207428:	46a1                	li	a3,8
ffffffffc020742a:	8aae                	mv	s5,a1
ffffffffc020742c:	bd3d                	j	ffffffffc020726a <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc020742e:	9902                	jalr	s2
ffffffffc0207430:	b559                	j	ffffffffc02072b6 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0207432:	85a6                	mv	a1,s1
ffffffffc0207434:	02d00513          	li	a0,45
ffffffffc0207438:	e03e                	sd	a5,0(sp)
ffffffffc020743a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020743c:	8ace                	mv	s5,s3
ffffffffc020743e:	40800633          	neg	a2,s0
ffffffffc0207442:	46a9                	li	a3,10
ffffffffc0207444:	6782                	ld	a5,0(sp)
ffffffffc0207446:	b515                	j	ffffffffc020726a <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0207448:	01b05663          	blez	s11,ffffffffc0207454 <vprintfmt+0x35a>
ffffffffc020744c:	02d00693          	li	a3,45
ffffffffc0207450:	f6d798e3          	bne	a5,a3,ffffffffc02073c0 <vprintfmt+0x2c6>
ffffffffc0207454:	00003417          	auipc	s0,0x3
ffffffffc0207458:	4e540413          	addi	s0,s0,1253 # ffffffffc020a939 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020745c:	02800513          	li	a0,40
ffffffffc0207460:	02800793          	li	a5,40
ffffffffc0207464:	bd1d                	j	ffffffffc020729a <vprintfmt+0x1a0>

ffffffffc0207466 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0207466:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0207468:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020746c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020746e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0207470:	ec06                	sd	ra,24(sp)
ffffffffc0207472:	f83a                	sd	a4,48(sp)
ffffffffc0207474:	fc3e                	sd	a5,56(sp)
ffffffffc0207476:	e0c2                	sd	a6,64(sp)
ffffffffc0207478:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020747a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020747c:	c7fff0ef          	jal	ra,ffffffffc02070fa <vprintfmt>
}
ffffffffc0207480:	60e2                	ld	ra,24(sp)
ffffffffc0207482:	6161                	addi	sp,sp,80
ffffffffc0207484:	8082                	ret

ffffffffc0207486 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0207486:	00054783          	lbu	a5,0(a0)
ffffffffc020748a:	cb91                	beqz	a5,ffffffffc020749e <strlen+0x18>
    size_t cnt = 0;
ffffffffc020748c:	4781                	li	a5,0
        cnt ++;
ffffffffc020748e:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0207490:	00f50733          	add	a4,a0,a5
ffffffffc0207494:	00074703          	lbu	a4,0(a4)
ffffffffc0207498:	fb7d                	bnez	a4,ffffffffc020748e <strlen+0x8>
    }
    return cnt;
}
ffffffffc020749a:	853e                	mv	a0,a5
ffffffffc020749c:	8082                	ret
    size_t cnt = 0;
ffffffffc020749e:	4781                	li	a5,0
}
ffffffffc02074a0:	853e                	mv	a0,a5
ffffffffc02074a2:	8082                	ret

ffffffffc02074a4 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc02074a4:	c185                	beqz	a1,ffffffffc02074c4 <strnlen+0x20>
ffffffffc02074a6:	00054783          	lbu	a5,0(a0)
ffffffffc02074aa:	cf89                	beqz	a5,ffffffffc02074c4 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02074ac:	4781                	li	a5,0
ffffffffc02074ae:	a021                	j	ffffffffc02074b6 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02074b0:	00074703          	lbu	a4,0(a4)
ffffffffc02074b4:	c711                	beqz	a4,ffffffffc02074c0 <strnlen+0x1c>
        cnt ++;
ffffffffc02074b6:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02074b8:	00f50733          	add	a4,a0,a5
ffffffffc02074bc:	fef59ae3          	bne	a1,a5,ffffffffc02074b0 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02074c0:	853e                	mv	a0,a5
ffffffffc02074c2:	8082                	ret
    size_t cnt = 0;
ffffffffc02074c4:	4781                	li	a5,0
}
ffffffffc02074c6:	853e                	mv	a0,a5
ffffffffc02074c8:	8082                	ret

ffffffffc02074ca <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02074ca:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02074cc:	0585                	addi	a1,a1,1
ffffffffc02074ce:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02074d2:	0785                	addi	a5,a5,1
ffffffffc02074d4:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02074d8:	fb75                	bnez	a4,ffffffffc02074cc <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02074da:	8082                	ret

ffffffffc02074dc <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02074dc:	00054783          	lbu	a5,0(a0)
ffffffffc02074e0:	0005c703          	lbu	a4,0(a1)
ffffffffc02074e4:	cb91                	beqz	a5,ffffffffc02074f8 <strcmp+0x1c>
ffffffffc02074e6:	00e79c63          	bne	a5,a4,ffffffffc02074fe <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02074ea:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02074ec:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02074f0:	0585                	addi	a1,a1,1
ffffffffc02074f2:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02074f6:	fbe5                	bnez	a5,ffffffffc02074e6 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02074f8:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02074fa:	9d19                	subw	a0,a0,a4
ffffffffc02074fc:	8082                	ret
ffffffffc02074fe:	0007851b          	sext.w	a0,a5
ffffffffc0207502:	9d19                	subw	a0,a0,a4
ffffffffc0207504:	8082                	ret

ffffffffc0207506 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0207506:	00054783          	lbu	a5,0(a0)
ffffffffc020750a:	cb91                	beqz	a5,ffffffffc020751e <strchr+0x18>
        if (*s == c) {
ffffffffc020750c:	00b79563          	bne	a5,a1,ffffffffc0207516 <strchr+0x10>
ffffffffc0207510:	a809                	j	ffffffffc0207522 <strchr+0x1c>
ffffffffc0207512:	00b78763          	beq	a5,a1,ffffffffc0207520 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0207516:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0207518:	00054783          	lbu	a5,0(a0)
ffffffffc020751c:	fbfd                	bnez	a5,ffffffffc0207512 <strchr+0xc>
    }
    return NULL;
ffffffffc020751e:	4501                	li	a0,0
}
ffffffffc0207520:	8082                	ret
ffffffffc0207522:	8082                	ret

ffffffffc0207524 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0207524:	ca01                	beqz	a2,ffffffffc0207534 <memset+0x10>
ffffffffc0207526:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0207528:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020752a:	0785                	addi	a5,a5,1
ffffffffc020752c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0207530:	fec79de3          	bne	a5,a2,ffffffffc020752a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0207534:	8082                	ret

ffffffffc0207536 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0207536:	ca19                	beqz	a2,ffffffffc020754c <memcpy+0x16>
ffffffffc0207538:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020753a:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020753c:	0585                	addi	a1,a1,1
ffffffffc020753e:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0207542:	0785                	addi	a5,a5,1
ffffffffc0207544:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0207548:	fec59ae3          	bne	a1,a2,ffffffffc020753c <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020754c:	8082                	ret
