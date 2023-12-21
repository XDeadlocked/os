
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020e2b7          	lui	t0,0xc020e
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
ffffffffc0200028:	c020e137          	lui	sp,0xc020e

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
ffffffffc0200036:	000be517          	auipc	a0,0xbe
ffffffffc020003a:	e8a50513          	addi	a0,a0,-374 # ffffffffc02bdec0 <edata>
ffffffffc020003e:	000c9617          	auipc	a2,0xc9
ffffffffc0200042:	44260613          	addi	a2,a2,1090 # ffffffffc02c9480 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	0be090ef          	jal	ra,ffffffffc020910c <memset>
    cons_init();                // init the console
ffffffffc0200052:	52e000ef          	jal	ra,ffffffffc0200580 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00009597          	auipc	a1,0x9
ffffffffc020005a:	0e258593          	addi	a1,a1,226 # ffffffffc0209138 <etext+0x2>
ffffffffc020005e:	00009517          	auipc	a0,0x9
ffffffffc0200062:	0fa50513          	addi	a0,a0,250 # ffffffffc0209158 <etext+0x22>
ffffffffc0200066:	12c000ef          	jal	ra,ffffffffc0200192 <cprintf>

    print_kerninfo();
ffffffffc020006a:	1b0000ef          	jal	ra,ffffffffc020021a <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	5b6020ef          	jal	ra,ffffffffc0202624 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5e6000ef          	jal	ra,ffffffffc0200658 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5e4000ef          	jal	ra,ffffffffc020065a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	3d8040ef          	jal	ra,ffffffffc0204452 <vmm_init>
    sched_init();
ffffffffc020007e:	103080ef          	jal	ra,ffffffffc0208980 <sched_init>
    proc_init();                // init process table
ffffffffc0200082:	52f050ef          	jal	ra,ffffffffc0205db0 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200086:	56e000ef          	jal	ra,ffffffffc02005f4 <ide_init>
    swap_init();                // init swap
ffffffffc020008a:	2f2030ef          	jal	ra,ffffffffc020337c <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008e:	4a8000ef          	jal	ra,ffffffffc0200536 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc0200092:	5ba000ef          	jal	ra,ffffffffc020064c <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
ffffffffc0200096:	667050ef          	jal	ra,ffffffffc0205efc <cpu_idle>

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
ffffffffc02000b2:	00009517          	auipc	a0,0x9
ffffffffc02000b6:	0ae50513          	addi	a0,a0,174 # ffffffffc0209160 <etext+0x2a>
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
ffffffffc02000c8:	000beb97          	auipc	s7,0xbe
ffffffffc02000cc:	df8b8b93          	addi	s7,s7,-520 # ffffffffc02bdec0 <edata>
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
ffffffffc020012a:	000be517          	auipc	a0,0xbe
ffffffffc020012e:	d9650513          	addi	a0,a0,-618 # ffffffffc02bdec0 <edata>
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
ffffffffc0200186:	35d080ef          	jal	ra,ffffffffc0208ce2 <vprintfmt>
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
ffffffffc0200194:	02810313          	addi	t1,sp,40 # ffffffffc020e028 <boot_page_table_sv39+0x28>
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
ffffffffc02001ba:	329080ef          	jal	ra,ffffffffc0208ce2 <vprintfmt>
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
ffffffffc020021c:	00009517          	auipc	a0,0x9
ffffffffc0200220:	f7c50513          	addi	a0,a0,-132 # ffffffffc0209198 <etext+0x62>
void print_kerninfo(void) {
ffffffffc0200224:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200226:	f6dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020022a:	00000597          	auipc	a1,0x0
ffffffffc020022e:	e0c58593          	addi	a1,a1,-500 # ffffffffc0200036 <kern_init>
ffffffffc0200232:	00009517          	auipc	a0,0x9
ffffffffc0200236:	f8650513          	addi	a0,a0,-122 # ffffffffc02091b8 <etext+0x82>
ffffffffc020023a:	f59ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020023e:	00009597          	auipc	a1,0x9
ffffffffc0200242:	ef858593          	addi	a1,a1,-264 # ffffffffc0209136 <etext>
ffffffffc0200246:	00009517          	auipc	a0,0x9
ffffffffc020024a:	f9250513          	addi	a0,a0,-110 # ffffffffc02091d8 <etext+0xa2>
ffffffffc020024e:	f45ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200252:	000be597          	auipc	a1,0xbe
ffffffffc0200256:	c6e58593          	addi	a1,a1,-914 # ffffffffc02bdec0 <edata>
ffffffffc020025a:	00009517          	auipc	a0,0x9
ffffffffc020025e:	f9e50513          	addi	a0,a0,-98 # ffffffffc02091f8 <etext+0xc2>
ffffffffc0200262:	f31ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200266:	000c9597          	auipc	a1,0xc9
ffffffffc020026a:	21a58593          	addi	a1,a1,538 # ffffffffc02c9480 <end>
ffffffffc020026e:	00009517          	auipc	a0,0x9
ffffffffc0200272:	faa50513          	addi	a0,a0,-86 # ffffffffc0209218 <etext+0xe2>
ffffffffc0200276:	f1dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020027a:	000c9597          	auipc	a1,0xc9
ffffffffc020027e:	60558593          	addi	a1,a1,1541 # ffffffffc02c987f <end+0x3ff>
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
ffffffffc020029c:	00009517          	auipc	a0,0x9
ffffffffc02002a0:	f9c50513          	addi	a0,a0,-100 # ffffffffc0209238 <etext+0x102>
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
    panic("Not Implemented!");
ffffffffc02002ac:	00009617          	auipc	a2,0x9
ffffffffc02002b0:	ebc60613          	addi	a2,a2,-324 # ffffffffc0209168 <etext+0x32>
ffffffffc02002b4:	04d00593          	li	a1,77
ffffffffc02002b8:	00009517          	auipc	a0,0x9
ffffffffc02002bc:	ec850513          	addi	a0,a0,-312 # ffffffffc0209180 <etext+0x4a>
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
ffffffffc02002c8:	00009617          	auipc	a2,0x9
ffffffffc02002cc:	08060613          	addi	a2,a2,128 # ffffffffc0209348 <commands+0xe0>
ffffffffc02002d0:	00009597          	auipc	a1,0x9
ffffffffc02002d4:	09858593          	addi	a1,a1,152 # ffffffffc0209368 <commands+0x100>
ffffffffc02002d8:	00009517          	auipc	a0,0x9
ffffffffc02002dc:	09850513          	addi	a0,a0,152 # ffffffffc0209370 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e0:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e2:	eb1ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc02002e6:	00009617          	auipc	a2,0x9
ffffffffc02002ea:	09a60613          	addi	a2,a2,154 # ffffffffc0209380 <commands+0x118>
ffffffffc02002ee:	00009597          	auipc	a1,0x9
ffffffffc02002f2:	0ba58593          	addi	a1,a1,186 # ffffffffc02093a8 <commands+0x140>
ffffffffc02002f6:	00009517          	auipc	a0,0x9
ffffffffc02002fa:	07a50513          	addi	a0,a0,122 # ffffffffc0209370 <commands+0x108>
ffffffffc02002fe:	e95ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc0200302:	00009617          	auipc	a2,0x9
ffffffffc0200306:	0b660613          	addi	a2,a2,182 # ffffffffc02093b8 <commands+0x150>
ffffffffc020030a:	00009597          	auipc	a1,0x9
ffffffffc020030e:	0ce58593          	addi	a1,a1,206 # ffffffffc02093d8 <commands+0x170>
ffffffffc0200312:	00009517          	auipc	a0,0x9
ffffffffc0200316:	05e50513          	addi	a0,a0,94 # ffffffffc0209370 <commands+0x108>
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
ffffffffc020034c:	00009517          	auipc	a0,0x9
ffffffffc0200350:	f6450513          	addi	a0,a0,-156 # ffffffffc02092b0 <commands+0x48>
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
ffffffffc020036e:	00009517          	auipc	a0,0x9
ffffffffc0200372:	f6a50513          	addi	a0,a0,-150 # ffffffffc02092d8 <commands+0x70>
ffffffffc0200376:	e1dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    if (tf != NULL) {
ffffffffc020037a:	000c0563          	beqz	s8,ffffffffc0200384 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020037e:	8562                	mv	a0,s8
ffffffffc0200380:	4c2000ef          	jal	ra,ffffffffc0200842 <print_trapframe>
ffffffffc0200384:	00009c97          	auipc	s9,0x9
ffffffffc0200388:	ee4c8c93          	addi	s9,s9,-284 # ffffffffc0209268 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020038c:	00009997          	auipc	s3,0x9
ffffffffc0200390:	f7498993          	addi	s3,s3,-140 # ffffffffc0209300 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200394:	00009917          	auipc	s2,0x9
ffffffffc0200398:	f7490913          	addi	s2,s2,-140 # ffffffffc0209308 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc020039c:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020039e:	00009b17          	auipc	s6,0x9
ffffffffc02003a2:	f72b0b13          	addi	s6,s6,-142 # ffffffffc0209310 <commands+0xa8>
    if (argc == 0) {
ffffffffc02003a6:	00009a97          	auipc	s5,0x9
ffffffffc02003aa:	fc2a8a93          	addi	s5,s5,-62 # ffffffffc0209368 <commands+0x100>
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
ffffffffc02003c4:	52b080ef          	jal	ra,ffffffffc02090ee <strchr>
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
ffffffffc02003da:	00009d17          	auipc	s10,0x9
ffffffffc02003de:	e8ed0d13          	addi	s10,s10,-370 # ffffffffc0209268 <commands>
    if (argc == 0) {
ffffffffc02003e2:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003e4:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003e6:	0d61                	addi	s10,s10,24
ffffffffc02003e8:	4dd080ef          	jal	ra,ffffffffc02090c4 <strcmp>
ffffffffc02003ec:	c919                	beqz	a0,ffffffffc0200402 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ee:	2405                	addiw	s0,s0,1
ffffffffc02003f0:	09740463          	beq	s0,s7,ffffffffc0200478 <kmonitor+0x132>
ffffffffc02003f4:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003f8:	6582                	ld	a1,0(sp)
ffffffffc02003fa:	0d61                	addi	s10,s10,24
ffffffffc02003fc:	4c9080ef          	jal	ra,ffffffffc02090c4 <strcmp>
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
ffffffffc0200462:	48d080ef          	jal	ra,ffffffffc02090ee <strchr>
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
ffffffffc020047a:	00009517          	auipc	a0,0x9
ffffffffc020047e:	eb650513          	addi	a0,a0,-330 # ffffffffc0209330 <commands+0xc8>
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
ffffffffc0200488:	000c9317          	auipc	t1,0xc9
ffffffffc020048c:	e6830313          	addi	t1,t1,-408 # ffffffffc02c92f0 <is_panic>
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
ffffffffc02004ac:	000c9717          	auipc	a4,0xc9
ffffffffc02004b0:	e4f73223          	sd	a5,-444(a4) # ffffffffc02c92f0 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b4:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02004b6:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b8:	85aa                	mv	a1,a0
ffffffffc02004ba:	00009517          	auipc	a0,0x9
ffffffffc02004be:	f2e50513          	addi	a0,a0,-210 # ffffffffc02093e8 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02004c2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004c4:	ccfff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004c8:	65a2                	ld	a1,8(sp)
ffffffffc02004ca:	8522                	mv	a0,s0
ffffffffc02004cc:	ca7ff0ef          	jal	ra,ffffffffc0200172 <vcprintf>
    cprintf("\n");
ffffffffc02004d0:	0000a517          	auipc	a0,0xa
ffffffffc02004d4:	ed050513          	addi	a0,a0,-304 # ffffffffc020a3a0 <default_pmm_manager+0x530>
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
ffffffffc0200502:	00009517          	auipc	a0,0x9
ffffffffc0200506:	f0650513          	addi	a0,a0,-250 # ffffffffc0209408 <commands+0x1a0>
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
ffffffffc0200522:	0000a517          	auipc	a0,0xa
ffffffffc0200526:	e7e50513          	addi	a0,a0,-386 # ffffffffc020a3a0 <default_pmm_manager+0x530>
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
ffffffffc0200544:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_matrix_out_size+0xcc30>
ffffffffc0200548:	953e                	add	a0,a0,a5
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020054a:	4581                	li	a1,0
ffffffffc020054c:	4601                	li	a2,0
ffffffffc020054e:	4881                	li	a7,0
ffffffffc0200550:	00000073          	ecall
    cprintf("++ setup timer interrupts\n");
ffffffffc0200554:	00009517          	auipc	a0,0x9
ffffffffc0200558:	ed450513          	addi	a0,a0,-300 # ffffffffc0209428 <commands+0x1c0>
    ticks = 0;
ffffffffc020055c:	000c9797          	auipc	a5,0xc9
ffffffffc0200560:	de07ba23          	sd	zero,-524(a5) # ffffffffc02c9350 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200564:	c2fff06f          	j	ffffffffc0200192 <cprintf>

ffffffffc0200568 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200568:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020056c:	67e1                	lui	a5,0x18
ffffffffc020056e:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_matrix_out_size+0xcc30>
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
ffffffffc0200602:	000be797          	auipc	a5,0xbe
ffffffffc0200606:	cbe78793          	addi	a5,a5,-834 # ffffffffc02be2c0 <ide>
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
ffffffffc020061a:	305080ef          	jal	ra,ffffffffc020911e <memcpy>
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
ffffffffc020062c:	000be517          	auipc	a0,0xbe
ffffffffc0200630:	c9450513          	addi	a0,a0,-876 # ffffffffc02be2c0 <ide>
                   size_t nsecs) {
ffffffffc0200634:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200636:	00969613          	slli	a2,a3,0x9
ffffffffc020063a:	85ba                	mv	a1,a4
ffffffffc020063c:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc020063e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200640:	2df080ef          	jal	ra,ffffffffc020911e <memcpy>
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
ffffffffc0200662:	67278793          	addi	a5,a5,1650 # ffffffffc0200cd0 <__alltraps>
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
ffffffffc020067c:	00009517          	auipc	a0,0x9
ffffffffc0200680:	0f450513          	addi	a0,a0,244 # ffffffffc0209770 <commands+0x508>
void print_regs(struct pushregs* gpr) {
ffffffffc0200684:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200686:	b0dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020068a:	640c                	ld	a1,8(s0)
ffffffffc020068c:	00009517          	auipc	a0,0x9
ffffffffc0200690:	0fc50513          	addi	a0,a0,252 # ffffffffc0209788 <commands+0x520>
ffffffffc0200694:	affff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200698:	680c                	ld	a1,16(s0)
ffffffffc020069a:	00009517          	auipc	a0,0x9
ffffffffc020069e:	10650513          	addi	a0,a0,262 # ffffffffc02097a0 <commands+0x538>
ffffffffc02006a2:	af1ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02006a6:	6c0c                	ld	a1,24(s0)
ffffffffc02006a8:	00009517          	auipc	a0,0x9
ffffffffc02006ac:	11050513          	addi	a0,a0,272 # ffffffffc02097b8 <commands+0x550>
ffffffffc02006b0:	ae3ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006b4:	700c                	ld	a1,32(s0)
ffffffffc02006b6:	00009517          	auipc	a0,0x9
ffffffffc02006ba:	11a50513          	addi	a0,a0,282 # ffffffffc02097d0 <commands+0x568>
ffffffffc02006be:	ad5ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006c2:	740c                	ld	a1,40(s0)
ffffffffc02006c4:	00009517          	auipc	a0,0x9
ffffffffc02006c8:	12450513          	addi	a0,a0,292 # ffffffffc02097e8 <commands+0x580>
ffffffffc02006cc:	ac7ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006d0:	780c                	ld	a1,48(s0)
ffffffffc02006d2:	00009517          	auipc	a0,0x9
ffffffffc02006d6:	12e50513          	addi	a0,a0,302 # ffffffffc0209800 <commands+0x598>
ffffffffc02006da:	ab9ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006de:	7c0c                	ld	a1,56(s0)
ffffffffc02006e0:	00009517          	auipc	a0,0x9
ffffffffc02006e4:	13850513          	addi	a0,a0,312 # ffffffffc0209818 <commands+0x5b0>
ffffffffc02006e8:	aabff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006ec:	602c                	ld	a1,64(s0)
ffffffffc02006ee:	00009517          	auipc	a0,0x9
ffffffffc02006f2:	14250513          	addi	a0,a0,322 # ffffffffc0209830 <commands+0x5c8>
ffffffffc02006f6:	a9dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006fa:	642c                	ld	a1,72(s0)
ffffffffc02006fc:	00009517          	auipc	a0,0x9
ffffffffc0200700:	14c50513          	addi	a0,a0,332 # ffffffffc0209848 <commands+0x5e0>
ffffffffc0200704:	a8fff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200708:	682c                	ld	a1,80(s0)
ffffffffc020070a:	00009517          	auipc	a0,0x9
ffffffffc020070e:	15650513          	addi	a0,a0,342 # ffffffffc0209860 <commands+0x5f8>
ffffffffc0200712:	a81ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200716:	6c2c                	ld	a1,88(s0)
ffffffffc0200718:	00009517          	auipc	a0,0x9
ffffffffc020071c:	16050513          	addi	a0,a0,352 # ffffffffc0209878 <commands+0x610>
ffffffffc0200720:	a73ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200724:	702c                	ld	a1,96(s0)
ffffffffc0200726:	00009517          	auipc	a0,0x9
ffffffffc020072a:	16a50513          	addi	a0,a0,362 # ffffffffc0209890 <commands+0x628>
ffffffffc020072e:	a65ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200732:	742c                	ld	a1,104(s0)
ffffffffc0200734:	00009517          	auipc	a0,0x9
ffffffffc0200738:	17450513          	addi	a0,a0,372 # ffffffffc02098a8 <commands+0x640>
ffffffffc020073c:	a57ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200740:	782c                	ld	a1,112(s0)
ffffffffc0200742:	00009517          	auipc	a0,0x9
ffffffffc0200746:	17e50513          	addi	a0,a0,382 # ffffffffc02098c0 <commands+0x658>
ffffffffc020074a:	a49ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020074e:	7c2c                	ld	a1,120(s0)
ffffffffc0200750:	00009517          	auipc	a0,0x9
ffffffffc0200754:	18850513          	addi	a0,a0,392 # ffffffffc02098d8 <commands+0x670>
ffffffffc0200758:	a3bff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020075c:	604c                	ld	a1,128(s0)
ffffffffc020075e:	00009517          	auipc	a0,0x9
ffffffffc0200762:	19250513          	addi	a0,a0,402 # ffffffffc02098f0 <commands+0x688>
ffffffffc0200766:	a2dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020076a:	644c                	ld	a1,136(s0)
ffffffffc020076c:	00009517          	auipc	a0,0x9
ffffffffc0200770:	19c50513          	addi	a0,a0,412 # ffffffffc0209908 <commands+0x6a0>
ffffffffc0200774:	a1fff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200778:	684c                	ld	a1,144(s0)
ffffffffc020077a:	00009517          	auipc	a0,0x9
ffffffffc020077e:	1a650513          	addi	a0,a0,422 # ffffffffc0209920 <commands+0x6b8>
ffffffffc0200782:	a11ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200786:	6c4c                	ld	a1,152(s0)
ffffffffc0200788:	00009517          	auipc	a0,0x9
ffffffffc020078c:	1b050513          	addi	a0,a0,432 # ffffffffc0209938 <commands+0x6d0>
ffffffffc0200790:	a03ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200794:	704c                	ld	a1,160(s0)
ffffffffc0200796:	00009517          	auipc	a0,0x9
ffffffffc020079a:	1ba50513          	addi	a0,a0,442 # ffffffffc0209950 <commands+0x6e8>
ffffffffc020079e:	9f5ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02007a2:	744c                	ld	a1,168(s0)
ffffffffc02007a4:	00009517          	auipc	a0,0x9
ffffffffc02007a8:	1c450513          	addi	a0,a0,452 # ffffffffc0209968 <commands+0x700>
ffffffffc02007ac:	9e7ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007b0:	784c                	ld	a1,176(s0)
ffffffffc02007b2:	00009517          	auipc	a0,0x9
ffffffffc02007b6:	1ce50513          	addi	a0,a0,462 # ffffffffc0209980 <commands+0x718>
ffffffffc02007ba:	9d9ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007be:	7c4c                	ld	a1,184(s0)
ffffffffc02007c0:	00009517          	auipc	a0,0x9
ffffffffc02007c4:	1d850513          	addi	a0,a0,472 # ffffffffc0209998 <commands+0x730>
ffffffffc02007c8:	9cbff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007cc:	606c                	ld	a1,192(s0)
ffffffffc02007ce:	00009517          	auipc	a0,0x9
ffffffffc02007d2:	1e250513          	addi	a0,a0,482 # ffffffffc02099b0 <commands+0x748>
ffffffffc02007d6:	9bdff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007da:	646c                	ld	a1,200(s0)
ffffffffc02007dc:	00009517          	auipc	a0,0x9
ffffffffc02007e0:	1ec50513          	addi	a0,a0,492 # ffffffffc02099c8 <commands+0x760>
ffffffffc02007e4:	9afff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007e8:	686c                	ld	a1,208(s0)
ffffffffc02007ea:	00009517          	auipc	a0,0x9
ffffffffc02007ee:	1f650513          	addi	a0,a0,502 # ffffffffc02099e0 <commands+0x778>
ffffffffc02007f2:	9a1ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007f6:	6c6c                	ld	a1,216(s0)
ffffffffc02007f8:	00009517          	auipc	a0,0x9
ffffffffc02007fc:	20050513          	addi	a0,a0,512 # ffffffffc02099f8 <commands+0x790>
ffffffffc0200800:	993ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200804:	706c                	ld	a1,224(s0)
ffffffffc0200806:	00009517          	auipc	a0,0x9
ffffffffc020080a:	20a50513          	addi	a0,a0,522 # ffffffffc0209a10 <commands+0x7a8>
ffffffffc020080e:	985ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200812:	746c                	ld	a1,232(s0)
ffffffffc0200814:	00009517          	auipc	a0,0x9
ffffffffc0200818:	21450513          	addi	a0,a0,532 # ffffffffc0209a28 <commands+0x7c0>
ffffffffc020081c:	977ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200820:	786c                	ld	a1,240(s0)
ffffffffc0200822:	00009517          	auipc	a0,0x9
ffffffffc0200826:	21e50513          	addi	a0,a0,542 # ffffffffc0209a40 <commands+0x7d8>
ffffffffc020082a:	969ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200830:	6402                	ld	s0,0(sp)
ffffffffc0200832:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200834:	00009517          	auipc	a0,0x9
ffffffffc0200838:	22450513          	addi	a0,a0,548 # ffffffffc0209a58 <commands+0x7f0>
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
ffffffffc020084a:	00009517          	auipc	a0,0x9
ffffffffc020084e:	22650513          	addi	a0,a0,550 # ffffffffc0209a70 <commands+0x808>
print_trapframe(struct trapframe *tf) {
ffffffffc0200852:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200854:	93fff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200858:	8522                	mv	a0,s0
ffffffffc020085a:	e1bff0ef          	jal	ra,ffffffffc0200674 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020085e:	10043583          	ld	a1,256(s0)
ffffffffc0200862:	00009517          	auipc	a0,0x9
ffffffffc0200866:	22650513          	addi	a0,a0,550 # ffffffffc0209a88 <commands+0x820>
ffffffffc020086a:	929ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020086e:	10843583          	ld	a1,264(s0)
ffffffffc0200872:	00009517          	auipc	a0,0x9
ffffffffc0200876:	22e50513          	addi	a0,a0,558 # ffffffffc0209aa0 <commands+0x838>
ffffffffc020087a:	919ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc020087e:	11043583          	ld	a1,272(s0)
ffffffffc0200882:	00009517          	auipc	a0,0x9
ffffffffc0200886:	23650513          	addi	a0,a0,566 # ffffffffc0209ab8 <commands+0x850>
ffffffffc020088a:	909ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200892:	6402                	ld	s0,0(sp)
ffffffffc0200894:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200896:	00009517          	auipc	a0,0x9
ffffffffc020089a:	23250513          	addi	a0,a0,562 # ffffffffc0209ac8 <commands+0x860>
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
ffffffffc02008a8:	000c9497          	auipc	s1,0xc9
ffffffffc02008ac:	bc048493          	addi	s1,s1,-1088 # ffffffffc02c9468 <check_mm_struct>
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
ffffffffc02008de:	00009517          	auipc	a0,0x9
ffffffffc02008e2:	e1250513          	addi	a0,a0,-494 # ffffffffc02096f0 <commands+0x488>
ffffffffc02008e6:	8adff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008ea:	6088                	ld	a0,0(s1)
ffffffffc02008ec:	c129                	beqz	a0,ffffffffc020092e <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008ee:	000c9797          	auipc	a5,0xc9
ffffffffc02008f2:	a3278793          	addi	a5,a5,-1486 # ffffffffc02c9320 <current>
ffffffffc02008f6:	6398                	ld	a4,0(a5)
ffffffffc02008f8:	000c9797          	auipc	a5,0xc9
ffffffffc02008fc:	a3078793          	addi	a5,a5,-1488 # ffffffffc02c9328 <idleproc>
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
ffffffffc0200916:	0820406f          	j	ffffffffc0204998 <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020091a:	11843703          	ld	a4,280(s0)
ffffffffc020091e:	47bd                	li	a5,15
ffffffffc0200920:	05500613          	li	a2,85
ffffffffc0200924:	05700693          	li	a3,87
ffffffffc0200928:	faf719e3          	bne	a4,a5,ffffffffc02008da <pgfault_handler+0x36>
ffffffffc020092c:	bf4d                	j	ffffffffc02008de <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc020092e:	000c9797          	auipc	a5,0xc9
ffffffffc0200932:	9f278793          	addi	a5,a5,-1550 # ffffffffc02c9320 <current>
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
ffffffffc020094c:	04c0406f          	j	ffffffffc0204998 <do_pgfault>
        assert(current == idleproc);
ffffffffc0200950:	00009697          	auipc	a3,0x9
ffffffffc0200954:	dc068693          	addi	a3,a3,-576 # ffffffffc0209710 <commands+0x4a8>
ffffffffc0200958:	00009617          	auipc	a2,0x9
ffffffffc020095c:	dd060613          	addi	a2,a2,-560 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0200960:	06c00593          	li	a1,108
ffffffffc0200964:	00009517          	auipc	a0,0x9
ffffffffc0200968:	ddc50513          	addi	a0,a0,-548 # ffffffffc0209740 <commands+0x4d8>
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
ffffffffc020099a:	00009517          	auipc	a0,0x9
ffffffffc020099e:	d5650513          	addi	a0,a0,-682 # ffffffffc02096f0 <commands+0x488>
ffffffffc02009a2:	ff0ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc02009a6:	00009617          	auipc	a2,0x9
ffffffffc02009aa:	db260613          	addi	a2,a2,-590 # ffffffffc0209758 <commands+0x4f0>
ffffffffc02009ae:	07300593          	li	a1,115
ffffffffc02009b2:	00009517          	auipc	a0,0x9
ffffffffc02009b6:	d8e50513          	addi	a0,a0,-626 # ffffffffc0209740 <commands+0x4d8>
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
ffffffffc02009d0:	08f76163          	bltu	a4,a5,ffffffffc0200a52 <interrupt_handler+0x8e>
ffffffffc02009d4:	00009717          	auipc	a4,0x9
ffffffffc02009d8:	a7070713          	addi	a4,a4,-1424 # ffffffffc0209444 <commands+0x1dc>
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
ffffffffc02009e6:	00009517          	auipc	a0,0x9
ffffffffc02009ea:	cca50513          	addi	a0,a0,-822 # ffffffffc02096b0 <commands+0x448>
ffffffffc02009ee:	fa4ff06f          	j	ffffffffc0200192 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009f2:	00009517          	auipc	a0,0x9
ffffffffc02009f6:	c9e50513          	addi	a0,a0,-866 # ffffffffc0209690 <commands+0x428>
ffffffffc02009fa:	f98ff06f          	j	ffffffffc0200192 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009fe:	00009517          	auipc	a0,0x9
ffffffffc0200a02:	c5250513          	addi	a0,a0,-942 # ffffffffc0209650 <commands+0x3e8>
ffffffffc0200a06:	f8cff06f          	j	ffffffffc0200192 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a0a:	00009517          	auipc	a0,0x9
ffffffffc0200a0e:	c6650513          	addi	a0,a0,-922 # ffffffffc0209670 <commands+0x408>
ffffffffc0200a12:	f80ff06f          	j	ffffffffc0200192 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a16:	00009517          	auipc	a0,0x9
ffffffffc0200a1a:	cba50513          	addi	a0,a0,-838 # ffffffffc02096d0 <commands+0x468>
ffffffffc0200a1e:	f74ff06f          	j	ffffffffc0200192 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a22:	1141                	addi	sp,sp,-16
ffffffffc0200a24:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a26:	b43ff0ef          	jal	ra,ffffffffc0200568 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 ) {
ffffffffc0200a2a:	000c9797          	auipc	a5,0xc9
ffffffffc0200a2e:	92678793          	addi	a5,a5,-1754 # ffffffffc02c9350 <ticks>
ffffffffc0200a32:	639c                	ld	a5,0(a5)
            if (current){
ffffffffc0200a34:	000c9717          	auipc	a4,0xc9
ffffffffc0200a38:	8ec70713          	addi	a4,a4,-1812 # ffffffffc02c9320 <current>
ffffffffc0200a3c:	6308                	ld	a0,0(a4)
            if (++ticks % TICK_NUM == 0 ) {
ffffffffc0200a3e:	0785                	addi	a5,a5,1
ffffffffc0200a40:	000c9717          	auipc	a4,0xc9
ffffffffc0200a44:	90f73823          	sd	a5,-1776(a4) # ffffffffc02c9350 <ticks>
            if (current){
ffffffffc0200a48:	c519                	beqz	a0,ffffffffc0200a56 <interrupt_handler+0x92>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a4a:	60a2                	ld	ra,8(sp)
ffffffffc0200a4c:	0141                	addi	sp,sp,16
                sched_class_proc_tick(current); //call sched_class_proc_tick
ffffffffc0200a4e:	7030706f          	j	ffffffffc0208950 <sched_class_proc_tick>
            print_trapframe(tf);
ffffffffc0200a52:	df1ff06f          	j	ffffffffc0200842 <print_trapframe>
}
ffffffffc0200a56:	60a2                	ld	ra,8(sp)
ffffffffc0200a58:	0141                	addi	sp,sp,16
ffffffffc0200a5a:	8082                	ret

ffffffffc0200a5c <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a5c:	11853783          	ld	a5,280(a0)
ffffffffc0200a60:	473d                	li	a4,15
ffffffffc0200a62:	1af76e63          	bltu	a4,a5,ffffffffc0200c1e <exception_handler+0x1c2>
ffffffffc0200a66:	00009717          	auipc	a4,0x9
ffffffffc0200a6a:	a0e70713          	addi	a4,a4,-1522 # ffffffffc0209474 <commands+0x20c>
ffffffffc0200a6e:	078a                	slli	a5,a5,0x2
ffffffffc0200a70:	97ba                	add	a5,a5,a4
ffffffffc0200a72:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a74:	1101                	addi	sp,sp,-32
ffffffffc0200a76:	e822                	sd	s0,16(sp)
ffffffffc0200a78:	ec06                	sd	ra,24(sp)
ffffffffc0200a7a:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a7c:	97ba                	add	a5,a5,a4
ffffffffc0200a7e:	842a                	mv	s0,a0
ffffffffc0200a80:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a82:	00009517          	auipc	a0,0x9
ffffffffc0200a86:	b2650513          	addi	a0,a0,-1242 # ffffffffc02095a8 <commands+0x340>
ffffffffc0200a8a:	f08ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            tf->epc += 4;
ffffffffc0200a8e:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a92:	60e2                	ld	ra,24(sp)
ffffffffc0200a94:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a96:	0791                	addi	a5,a5,4
ffffffffc0200a98:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a9c:	6442                	ld	s0,16(sp)
ffffffffc0200a9e:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200aa0:	13c0806f          	j	ffffffffc0208bdc <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200aa4:	00009517          	auipc	a0,0x9
ffffffffc0200aa8:	b2450513          	addi	a0,a0,-1244 # ffffffffc02095c8 <commands+0x360>
}
ffffffffc0200aac:	6442                	ld	s0,16(sp)
ffffffffc0200aae:	60e2                	ld	ra,24(sp)
ffffffffc0200ab0:	64a2                	ld	s1,8(sp)
ffffffffc0200ab2:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200ab4:	edeff06f          	j	ffffffffc0200192 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200ab8:	00009517          	auipc	a0,0x9
ffffffffc0200abc:	b3050513          	addi	a0,a0,-1232 # ffffffffc02095e8 <commands+0x380>
ffffffffc0200ac0:	b7f5                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ac2:	00009517          	auipc	a0,0x9
ffffffffc0200ac6:	b4650513          	addi	a0,a0,-1210 # ffffffffc0209608 <commands+0x3a0>
ffffffffc0200aca:	b7cd                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200acc:	00009517          	auipc	a0,0x9
ffffffffc0200ad0:	b5450513          	addi	a0,a0,-1196 # ffffffffc0209620 <commands+0x3b8>
ffffffffc0200ad4:	ebeff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ad8:	8522                	mv	a0,s0
ffffffffc0200ada:	dcbff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200ade:	84aa                	mv	s1,a0
ffffffffc0200ae0:	14051163          	bnez	a0,ffffffffc0200c22 <exception_handler+0x1c6>
}
ffffffffc0200ae4:	60e2                	ld	ra,24(sp)
ffffffffc0200ae6:	6442                	ld	s0,16(sp)
ffffffffc0200ae8:	64a2                	ld	s1,8(sp)
ffffffffc0200aea:	6105                	addi	sp,sp,32
ffffffffc0200aec:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200aee:	00009517          	auipc	a0,0x9
ffffffffc0200af2:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0209638 <commands+0x3d0>
ffffffffc0200af6:	e9cff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200afa:	8522                	mv	a0,s0
ffffffffc0200afc:	da9ff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200b00:	84aa                	mv	s1,a0
ffffffffc0200b02:	d16d                	beqz	a0,ffffffffc0200ae4 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b04:	8522                	mv	a0,s0
ffffffffc0200b06:	d3dff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b0a:	86a6                	mv	a3,s1
ffffffffc0200b0c:	00009617          	auipc	a2,0x9
ffffffffc0200b10:	a4c60613          	addi	a2,a2,-1460 # ffffffffc0209558 <commands+0x2f0>
ffffffffc0200b14:	0fb00593          	li	a1,251
ffffffffc0200b18:	00009517          	auipc	a0,0x9
ffffffffc0200b1c:	c2850513          	addi	a0,a0,-984 # ffffffffc0209740 <commands+0x4d8>
ffffffffc0200b20:	969ff0ef          	jal	ra,ffffffffc0200488 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b24:	00009517          	auipc	a0,0x9
ffffffffc0200b28:	99450513          	addi	a0,a0,-1644 # ffffffffc02094b8 <commands+0x250>
ffffffffc0200b2c:	b741                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b2e:	00009517          	auipc	a0,0x9
ffffffffc0200b32:	9aa50513          	addi	a0,a0,-1622 # ffffffffc02094d8 <commands+0x270>
ffffffffc0200b36:	bf9d                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b38:	00009517          	auipc	a0,0x9
ffffffffc0200b3c:	9c050513          	addi	a0,a0,-1600 # ffffffffc02094f8 <commands+0x290>
ffffffffc0200b40:	b7b5                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b42:	00009517          	auipc	a0,0x9
ffffffffc0200b46:	9ce50513          	addi	a0,a0,-1586 # ffffffffc0209510 <commands+0x2a8>
ffffffffc0200b4a:	e48ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b4e:	6458                	ld	a4,136(s0)
ffffffffc0200b50:	47a9                	li	a5,10
ffffffffc0200b52:	f8f719e3          	bne	a4,a5,ffffffffc0200ae4 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b56:	10843783          	ld	a5,264(s0)
ffffffffc0200b5a:	0791                	addi	a5,a5,4
ffffffffc0200b5c:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b60:	07c080ef          	jal	ra,ffffffffc0208bdc <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b64:	000c8797          	auipc	a5,0xc8
ffffffffc0200b68:	7bc78793          	addi	a5,a5,1980 # ffffffffc02c9320 <current>
ffffffffc0200b6c:	639c                	ld	a5,0(a5)
ffffffffc0200b6e:	8522                	mv	a0,s0
}
ffffffffc0200b70:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b72:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200b74:	60e2                	ld	ra,24(sp)
ffffffffc0200b76:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b78:	6589                	lui	a1,0x2
ffffffffc0200b7a:	95be                	add	a1,a1,a5
}
ffffffffc0200b7c:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b7e:	2200006f          	j	ffffffffc0200d9e <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b82:	00009517          	auipc	a0,0x9
ffffffffc0200b86:	99e50513          	addi	a0,a0,-1634 # ffffffffc0209520 <commands+0x2b8>
ffffffffc0200b8a:	b70d                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b8c:	00009517          	auipc	a0,0x9
ffffffffc0200b90:	9b450513          	addi	a0,a0,-1612 # ffffffffc0209540 <commands+0x2d8>
ffffffffc0200b94:	dfeff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b98:	8522                	mv	a0,s0
ffffffffc0200b9a:	d0bff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200b9e:	84aa                	mv	s1,a0
ffffffffc0200ba0:	d131                	beqz	a0,ffffffffc0200ae4 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200ba2:	8522                	mv	a0,s0
ffffffffc0200ba4:	c9fff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200ba8:	86a6                	mv	a3,s1
ffffffffc0200baa:	00009617          	auipc	a2,0x9
ffffffffc0200bae:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0209558 <commands+0x2f0>
ffffffffc0200bb2:	0d000593          	li	a1,208
ffffffffc0200bb6:	00009517          	auipc	a0,0x9
ffffffffc0200bba:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0209740 <commands+0x4d8>
ffffffffc0200bbe:	8cbff0ef          	jal	ra,ffffffffc0200488 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bc2:	00009517          	auipc	a0,0x9
ffffffffc0200bc6:	9ce50513          	addi	a0,a0,-1586 # ffffffffc0209590 <commands+0x328>
ffffffffc0200bca:	dc8ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bce:	8522                	mv	a0,s0
ffffffffc0200bd0:	cd5ff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200bd4:	84aa                	mv	s1,a0
ffffffffc0200bd6:	f00507e3          	beqz	a0,ffffffffc0200ae4 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bda:	8522                	mv	a0,s0
ffffffffc0200bdc:	c67ff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200be0:	86a6                	mv	a3,s1
ffffffffc0200be2:	00009617          	auipc	a2,0x9
ffffffffc0200be6:	97660613          	addi	a2,a2,-1674 # ffffffffc0209558 <commands+0x2f0>
ffffffffc0200bea:	0da00593          	li	a1,218
ffffffffc0200bee:	00009517          	auipc	a0,0x9
ffffffffc0200bf2:	b5250513          	addi	a0,a0,-1198 # ffffffffc0209740 <commands+0x4d8>
ffffffffc0200bf6:	893ff0ef          	jal	ra,ffffffffc0200488 <__panic>
}
ffffffffc0200bfa:	6442                	ld	s0,16(sp)
ffffffffc0200bfc:	60e2                	ld	ra,24(sp)
ffffffffc0200bfe:	64a2                	ld	s1,8(sp)
ffffffffc0200c00:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200c02:	c41ff06f          	j	ffffffffc0200842 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200c06:	00009617          	auipc	a2,0x9
ffffffffc0200c0a:	97260613          	addi	a2,a2,-1678 # ffffffffc0209578 <commands+0x310>
ffffffffc0200c0e:	0d400593          	li	a1,212
ffffffffc0200c12:	00009517          	auipc	a0,0x9
ffffffffc0200c16:	b2e50513          	addi	a0,a0,-1234 # ffffffffc0209740 <commands+0x4d8>
ffffffffc0200c1a:	86fff0ef          	jal	ra,ffffffffc0200488 <__panic>
            print_trapframe(tf);
ffffffffc0200c1e:	c25ff06f          	j	ffffffffc0200842 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c22:	8522                	mv	a0,s0
ffffffffc0200c24:	c1fff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c28:	86a6                	mv	a3,s1
ffffffffc0200c2a:	00009617          	auipc	a2,0x9
ffffffffc0200c2e:	92e60613          	addi	a2,a2,-1746 # ffffffffc0209558 <commands+0x2f0>
ffffffffc0200c32:	0f400593          	li	a1,244
ffffffffc0200c36:	00009517          	auipc	a0,0x9
ffffffffc0200c3a:	b0a50513          	addi	a0,a0,-1270 # ffffffffc0209740 <commands+0x4d8>
ffffffffc0200c3e:	84bff0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0200c42 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c42:	1101                	addi	sp,sp,-32
ffffffffc0200c44:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c46:	000c8417          	auipc	s0,0xc8
ffffffffc0200c4a:	6da40413          	addi	s0,s0,1754 # ffffffffc02c9320 <current>
ffffffffc0200c4e:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c50:	ec06                	sd	ra,24(sp)
ffffffffc0200c52:	e426                	sd	s1,8(sp)
ffffffffc0200c54:	e04a                	sd	s2,0(sp)
ffffffffc0200c56:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c5a:	cf1d                	beqz	a4,ffffffffc0200c98 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c5c:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c60:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c64:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c66:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c6a:	0206c463          	bltz	a3,ffffffffc0200c92 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c6e:	defff0ef          	jal	ra,ffffffffc0200a5c <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c72:	601c                	ld	a5,0(s0)
ffffffffc0200c74:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c78:	e499                	bnez	s1,ffffffffc0200c86 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c7a:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c7e:	8b05                	andi	a4,a4,1
ffffffffc0200c80:	e339                	bnez	a4,ffffffffc0200cc6 <trap+0x84>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c82:	6f9c                	ld	a5,24(a5)
ffffffffc0200c84:	eb95                	bnez	a5,ffffffffc0200cb8 <trap+0x76>
                schedule();
            }
        }
    }
}
ffffffffc0200c86:	60e2                	ld	ra,24(sp)
ffffffffc0200c88:	6442                	ld	s0,16(sp)
ffffffffc0200c8a:	64a2                	ld	s1,8(sp)
ffffffffc0200c8c:	6902                	ld	s2,0(sp)
ffffffffc0200c8e:	6105                	addi	sp,sp,32
ffffffffc0200c90:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c92:	d33ff0ef          	jal	ra,ffffffffc02009c4 <interrupt_handler>
ffffffffc0200c96:	bff1                	j	ffffffffc0200c72 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c98:	0006c963          	bltz	a3,ffffffffc0200caa <trap+0x68>
}
ffffffffc0200c9c:	6442                	ld	s0,16(sp)
ffffffffc0200c9e:	60e2                	ld	ra,24(sp)
ffffffffc0200ca0:	64a2                	ld	s1,8(sp)
ffffffffc0200ca2:	6902                	ld	s2,0(sp)
ffffffffc0200ca4:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200ca6:	db7ff06f          	j	ffffffffc0200a5c <exception_handler>
}
ffffffffc0200caa:	6442                	ld	s0,16(sp)
ffffffffc0200cac:	60e2                	ld	ra,24(sp)
ffffffffc0200cae:	64a2                	ld	s1,8(sp)
ffffffffc0200cb0:	6902                	ld	s2,0(sp)
ffffffffc0200cb2:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200cb4:	d11ff06f          	j	ffffffffc02009c4 <interrupt_handler>
}
ffffffffc0200cb8:	6442                	ld	s0,16(sp)
ffffffffc0200cba:	60e2                	ld	ra,24(sp)
ffffffffc0200cbc:	64a2                	ld	s1,8(sp)
ffffffffc0200cbe:	6902                	ld	s2,0(sp)
ffffffffc0200cc0:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200cc2:	5cd0706f          	j	ffffffffc0208a8e <schedule>
                do_exit(-E_KILLED);
ffffffffc0200cc6:	555d                	li	a0,-9
ffffffffc0200cc8:	732040ef          	jal	ra,ffffffffc02053fa <do_exit>
ffffffffc0200ccc:	601c                	ld	a5,0(s0)
ffffffffc0200cce:	bf55                	j	ffffffffc0200c82 <trap+0x40>

ffffffffc0200cd0 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200cd0:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200cd4:	00011463          	bnez	sp,ffffffffc0200cdc <__alltraps+0xc>
ffffffffc0200cd8:	14002173          	csrr	sp,sscratch
ffffffffc0200cdc:	712d                	addi	sp,sp,-288
ffffffffc0200cde:	e002                	sd	zero,0(sp)
ffffffffc0200ce0:	e406                	sd	ra,8(sp)
ffffffffc0200ce2:	ec0e                	sd	gp,24(sp)
ffffffffc0200ce4:	f012                	sd	tp,32(sp)
ffffffffc0200ce6:	f416                	sd	t0,40(sp)
ffffffffc0200ce8:	f81a                	sd	t1,48(sp)
ffffffffc0200cea:	fc1e                	sd	t2,56(sp)
ffffffffc0200cec:	e0a2                	sd	s0,64(sp)
ffffffffc0200cee:	e4a6                	sd	s1,72(sp)
ffffffffc0200cf0:	e8aa                	sd	a0,80(sp)
ffffffffc0200cf2:	ecae                	sd	a1,88(sp)
ffffffffc0200cf4:	f0b2                	sd	a2,96(sp)
ffffffffc0200cf6:	f4b6                	sd	a3,104(sp)
ffffffffc0200cf8:	f8ba                	sd	a4,112(sp)
ffffffffc0200cfa:	fcbe                	sd	a5,120(sp)
ffffffffc0200cfc:	e142                	sd	a6,128(sp)
ffffffffc0200cfe:	e546                	sd	a7,136(sp)
ffffffffc0200d00:	e94a                	sd	s2,144(sp)
ffffffffc0200d02:	ed4e                	sd	s3,152(sp)
ffffffffc0200d04:	f152                	sd	s4,160(sp)
ffffffffc0200d06:	f556                	sd	s5,168(sp)
ffffffffc0200d08:	f95a                	sd	s6,176(sp)
ffffffffc0200d0a:	fd5e                	sd	s7,184(sp)
ffffffffc0200d0c:	e1e2                	sd	s8,192(sp)
ffffffffc0200d0e:	e5e6                	sd	s9,200(sp)
ffffffffc0200d10:	e9ea                	sd	s10,208(sp)
ffffffffc0200d12:	edee                	sd	s11,216(sp)
ffffffffc0200d14:	f1f2                	sd	t3,224(sp)
ffffffffc0200d16:	f5f6                	sd	t4,232(sp)
ffffffffc0200d18:	f9fa                	sd	t5,240(sp)
ffffffffc0200d1a:	fdfe                	sd	t6,248(sp)
ffffffffc0200d1c:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d20:	100024f3          	csrr	s1,sstatus
ffffffffc0200d24:	14102973          	csrr	s2,sepc
ffffffffc0200d28:	143029f3          	csrr	s3,stval
ffffffffc0200d2c:	14202a73          	csrr	s4,scause
ffffffffc0200d30:	e822                	sd	s0,16(sp)
ffffffffc0200d32:	e226                	sd	s1,256(sp)
ffffffffc0200d34:	e64a                	sd	s2,264(sp)
ffffffffc0200d36:	ea4e                	sd	s3,272(sp)
ffffffffc0200d38:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d3a:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d3c:	f07ff0ef          	jal	ra,ffffffffc0200c42 <trap>

ffffffffc0200d40 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d40:	6492                	ld	s1,256(sp)
ffffffffc0200d42:	6932                	ld	s2,264(sp)
ffffffffc0200d44:	1004f413          	andi	s0,s1,256
ffffffffc0200d48:	e401                	bnez	s0,ffffffffc0200d50 <__trapret+0x10>
ffffffffc0200d4a:	1200                	addi	s0,sp,288
ffffffffc0200d4c:	14041073          	csrw	sscratch,s0
ffffffffc0200d50:	10049073          	csrw	sstatus,s1
ffffffffc0200d54:	14191073          	csrw	sepc,s2
ffffffffc0200d58:	60a2                	ld	ra,8(sp)
ffffffffc0200d5a:	61e2                	ld	gp,24(sp)
ffffffffc0200d5c:	7202                	ld	tp,32(sp)
ffffffffc0200d5e:	72a2                	ld	t0,40(sp)
ffffffffc0200d60:	7342                	ld	t1,48(sp)
ffffffffc0200d62:	73e2                	ld	t2,56(sp)
ffffffffc0200d64:	6406                	ld	s0,64(sp)
ffffffffc0200d66:	64a6                	ld	s1,72(sp)
ffffffffc0200d68:	6546                	ld	a0,80(sp)
ffffffffc0200d6a:	65e6                	ld	a1,88(sp)
ffffffffc0200d6c:	7606                	ld	a2,96(sp)
ffffffffc0200d6e:	76a6                	ld	a3,104(sp)
ffffffffc0200d70:	7746                	ld	a4,112(sp)
ffffffffc0200d72:	77e6                	ld	a5,120(sp)
ffffffffc0200d74:	680a                	ld	a6,128(sp)
ffffffffc0200d76:	68aa                	ld	a7,136(sp)
ffffffffc0200d78:	694a                	ld	s2,144(sp)
ffffffffc0200d7a:	69ea                	ld	s3,152(sp)
ffffffffc0200d7c:	7a0a                	ld	s4,160(sp)
ffffffffc0200d7e:	7aaa                	ld	s5,168(sp)
ffffffffc0200d80:	7b4a                	ld	s6,176(sp)
ffffffffc0200d82:	7bea                	ld	s7,184(sp)
ffffffffc0200d84:	6c0e                	ld	s8,192(sp)
ffffffffc0200d86:	6cae                	ld	s9,200(sp)
ffffffffc0200d88:	6d4e                	ld	s10,208(sp)
ffffffffc0200d8a:	6dee                	ld	s11,216(sp)
ffffffffc0200d8c:	7e0e                	ld	t3,224(sp)
ffffffffc0200d8e:	7eae                	ld	t4,232(sp)
ffffffffc0200d90:	7f4e                	ld	t5,240(sp)
ffffffffc0200d92:	7fee                	ld	t6,248(sp)
ffffffffc0200d94:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d96:	10200073          	sret

ffffffffc0200d9a <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d9a:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d9c:	b755                	j	ffffffffc0200d40 <__trapret>

ffffffffc0200d9e <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d9e:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7a28>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200da2:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200da6:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200daa:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200dae:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200db2:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200db6:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200dba:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200dbe:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200dc2:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200dc4:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200dc6:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200dc8:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200dca:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200dcc:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200dce:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200dd0:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200dd2:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200dd4:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200dd6:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200dd8:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200dda:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200ddc:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dde:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200de0:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200de2:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200de4:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200de6:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200de8:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dea:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dec:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dee:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200df0:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200df2:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200df4:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200df6:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200df8:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200dfa:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200dfc:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200dfe:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200e00:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200e02:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200e04:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200e06:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200e08:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200e0a:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200e0c:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200e0e:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200e10:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200e12:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e14:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e16:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e18:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e1a:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e1c:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e1e:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e20:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e22:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e24:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e26:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e28:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e2a:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e2c:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e2e:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e30:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e32:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e34:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e36:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e38:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e3a:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e3c:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e3e:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e40:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e42:	812e                	mv	sp,a1
ffffffffc0200e44:	bdf5                	j	ffffffffc0200d40 <__trapret>

ffffffffc0200e46 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e46:	000c8797          	auipc	a5,0xc8
ffffffffc0200e4a:	51278793          	addi	a5,a5,1298 # ffffffffc02c9358 <free_area>
ffffffffc0200e4e:	e79c                	sd	a5,8(a5)
ffffffffc0200e50:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e52:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e56:	8082                	ret

ffffffffc0200e58 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200e58:	000c8517          	auipc	a0,0xc8
ffffffffc0200e5c:	51056503          	lwu	a0,1296(a0) # ffffffffc02c9368 <free_area+0x10>
ffffffffc0200e60:	8082                	ret

ffffffffc0200e62 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200e62:	715d                	addi	sp,sp,-80
ffffffffc0200e64:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e66:	000c8917          	auipc	s2,0xc8
ffffffffc0200e6a:	4f290913          	addi	s2,s2,1266 # ffffffffc02c9358 <free_area>
ffffffffc0200e6e:	00893783          	ld	a5,8(s2)
ffffffffc0200e72:	e486                	sd	ra,72(sp)
ffffffffc0200e74:	e0a2                	sd	s0,64(sp)
ffffffffc0200e76:	fc26                	sd	s1,56(sp)
ffffffffc0200e78:	f44e                	sd	s3,40(sp)
ffffffffc0200e7a:	f052                	sd	s4,32(sp)
ffffffffc0200e7c:	ec56                	sd	s5,24(sp)
ffffffffc0200e7e:	e85a                	sd	s6,16(sp)
ffffffffc0200e80:	e45e                	sd	s7,8(sp)
ffffffffc0200e82:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e84:	31278463          	beq	a5,s2,ffffffffc020118c <default_check+0x32a>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e88:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200e8c:	8305                	srli	a4,a4,0x1
ffffffffc0200e8e:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200e90:	30070263          	beqz	a4,ffffffffc0201194 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0200e94:	4401                	li	s0,0
ffffffffc0200e96:	4481                	li	s1,0
ffffffffc0200e98:	a031                	j	ffffffffc0200ea4 <default_check+0x42>
ffffffffc0200e9a:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200e9e:	8b09                	andi	a4,a4,2
ffffffffc0200ea0:	2e070a63          	beqz	a4,ffffffffc0201194 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0200ea4:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ea8:	679c                	ld	a5,8(a5)
ffffffffc0200eaa:	2485                	addiw	s1,s1,1
ffffffffc0200eac:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200eae:	ff2796e3          	bne	a5,s2,ffffffffc0200e9a <default_check+0x38>
ffffffffc0200eb2:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200eb4:	05c010ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>
ffffffffc0200eb8:	73351e63          	bne	a0,s3,ffffffffc02015f4 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ebc:	4505                	li	a0,1
ffffffffc0200ebe:	785000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200ec2:	8a2a                	mv	s4,a0
ffffffffc0200ec4:	46050863          	beqz	a0,ffffffffc0201334 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ec8:	4505                	li	a0,1
ffffffffc0200eca:	779000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200ece:	89aa                	mv	s3,a0
ffffffffc0200ed0:	74050263          	beqz	a0,ffffffffc0201614 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ed4:	4505                	li	a0,1
ffffffffc0200ed6:	76d000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200eda:	8aaa                	mv	s5,a0
ffffffffc0200edc:	4c050c63          	beqz	a0,ffffffffc02013b4 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ee0:	2d3a0a63          	beq	s4,s3,ffffffffc02011b4 <default_check+0x352>
ffffffffc0200ee4:	2caa0863          	beq	s4,a0,ffffffffc02011b4 <default_check+0x352>
ffffffffc0200ee8:	2ca98663          	beq	s3,a0,ffffffffc02011b4 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200eec:	000a2783          	lw	a5,0(s4)
ffffffffc0200ef0:	2e079263          	bnez	a5,ffffffffc02011d4 <default_check+0x372>
ffffffffc0200ef4:	0009a783          	lw	a5,0(s3)
ffffffffc0200ef8:	2c079e63          	bnez	a5,ffffffffc02011d4 <default_check+0x372>
ffffffffc0200efc:	411c                	lw	a5,0(a0)
ffffffffc0200efe:	2c079b63          	bnez	a5,ffffffffc02011d4 <default_check+0x372>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200f02:	000c8797          	auipc	a5,0xc8
ffffffffc0200f06:	48678793          	addi	a5,a5,1158 # ffffffffc02c9388 <pages>
ffffffffc0200f0a:	639c                	ld	a5,0(a5)
ffffffffc0200f0c:	0000b717          	auipc	a4,0xb
ffffffffc0200f10:	06c70713          	addi	a4,a4,108 # ffffffffc020bf78 <nbase>
ffffffffc0200f14:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f16:	000c8717          	auipc	a4,0xc8
ffffffffc0200f1a:	3f270713          	addi	a4,a4,1010 # ffffffffc02c9308 <npage>
ffffffffc0200f1e:	6314                	ld	a3,0(a4)
ffffffffc0200f20:	40fa0733          	sub	a4,s4,a5
ffffffffc0200f24:	8719                	srai	a4,a4,0x6
ffffffffc0200f26:	9732                	add	a4,a4,a2
ffffffffc0200f28:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f2a:	0732                	slli	a4,a4,0xc
ffffffffc0200f2c:	2cd77463          	bleu	a3,a4,ffffffffc02011f4 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0200f30:	40f98733          	sub	a4,s3,a5
ffffffffc0200f34:	8719                	srai	a4,a4,0x6
ffffffffc0200f36:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f38:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200f3a:	4ed77d63          	bleu	a3,a4,ffffffffc0201434 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0200f3e:	40f507b3          	sub	a5,a0,a5
ffffffffc0200f42:	8799                	srai	a5,a5,0x6
ffffffffc0200f44:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f46:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f48:	34d7f663          	bleu	a3,a5,ffffffffc0201294 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0200f4c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200f4e:	00093c03          	ld	s8,0(s2)
ffffffffc0200f52:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200f56:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200f5a:	000c8797          	auipc	a5,0xc8
ffffffffc0200f5e:	4127b323          	sd	s2,1030(a5) # ffffffffc02c9360 <free_area+0x8>
ffffffffc0200f62:	000c8797          	auipc	a5,0xc8
ffffffffc0200f66:	3f27bb23          	sd	s2,1014(a5) # ffffffffc02c9358 <free_area>
    nr_free = 0;
ffffffffc0200f6a:	000c8797          	auipc	a5,0xc8
ffffffffc0200f6e:	3e07af23          	sw	zero,1022(a5) # ffffffffc02c9368 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200f72:	6d1000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200f76:	2e051f63          	bnez	a0,ffffffffc0201274 <default_check+0x412>
    free_page(p0);
ffffffffc0200f7a:	4585                	li	a1,1
ffffffffc0200f7c:	8552                	mv	a0,s4
ffffffffc0200f7e:	74d000ef          	jal	ra,ffffffffc0201eca <free_pages>
    free_page(p1);
ffffffffc0200f82:	4585                	li	a1,1
ffffffffc0200f84:	854e                	mv	a0,s3
ffffffffc0200f86:	745000ef          	jal	ra,ffffffffc0201eca <free_pages>
    free_page(p2);
ffffffffc0200f8a:	4585                	li	a1,1
ffffffffc0200f8c:	8556                	mv	a0,s5
ffffffffc0200f8e:	73d000ef          	jal	ra,ffffffffc0201eca <free_pages>
    assert(nr_free == 3);
ffffffffc0200f92:	01092703          	lw	a4,16(s2)
ffffffffc0200f96:	478d                	li	a5,3
ffffffffc0200f98:	2af71e63          	bne	a4,a5,ffffffffc0201254 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f9c:	4505                	li	a0,1
ffffffffc0200f9e:	6a5000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200fa2:	89aa                	mv	s3,a0
ffffffffc0200fa4:	28050863          	beqz	a0,ffffffffc0201234 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200fa8:	4505                	li	a0,1
ffffffffc0200faa:	699000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200fae:	8aaa                	mv	s5,a0
ffffffffc0200fb0:	3e050263          	beqz	a0,ffffffffc0201394 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fb4:	4505                	li	a0,1
ffffffffc0200fb6:	68d000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200fba:	8a2a                	mv	s4,a0
ffffffffc0200fbc:	3a050c63          	beqz	a0,ffffffffc0201374 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0200fc0:	4505                	li	a0,1
ffffffffc0200fc2:	681000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200fc6:	38051763          	bnez	a0,ffffffffc0201354 <default_check+0x4f2>
    free_page(p0);
ffffffffc0200fca:	4585                	li	a1,1
ffffffffc0200fcc:	854e                	mv	a0,s3
ffffffffc0200fce:	6fd000ef          	jal	ra,ffffffffc0201eca <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200fd2:	00893783          	ld	a5,8(s2)
ffffffffc0200fd6:	23278f63          	beq	a5,s2,ffffffffc0201214 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0200fda:	4505                	li	a0,1
ffffffffc0200fdc:	667000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200fe0:	32a99a63          	bne	s3,a0,ffffffffc0201314 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0200fe4:	4505                	li	a0,1
ffffffffc0200fe6:	65d000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200fea:	30051563          	bnez	a0,ffffffffc02012f4 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0200fee:	01092783          	lw	a5,16(s2)
ffffffffc0200ff2:	2e079163          	bnez	a5,ffffffffc02012d4 <default_check+0x472>
    free_page(p);
ffffffffc0200ff6:	854e                	mv	a0,s3
ffffffffc0200ff8:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200ffa:	000c8797          	auipc	a5,0xc8
ffffffffc0200ffe:	3587bf23          	sd	s8,862(a5) # ffffffffc02c9358 <free_area>
ffffffffc0201002:	000c8797          	auipc	a5,0xc8
ffffffffc0201006:	3577bf23          	sd	s7,862(a5) # ffffffffc02c9360 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc020100a:	000c8797          	auipc	a5,0xc8
ffffffffc020100e:	3567af23          	sw	s6,862(a5) # ffffffffc02c9368 <free_area+0x10>
    free_page(p);
ffffffffc0201012:	6b9000ef          	jal	ra,ffffffffc0201eca <free_pages>
    free_page(p1);
ffffffffc0201016:	4585                	li	a1,1
ffffffffc0201018:	8556                	mv	a0,s5
ffffffffc020101a:	6b1000ef          	jal	ra,ffffffffc0201eca <free_pages>
    free_page(p2);
ffffffffc020101e:	4585                	li	a1,1
ffffffffc0201020:	8552                	mv	a0,s4
ffffffffc0201022:	6a9000ef          	jal	ra,ffffffffc0201eca <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201026:	4515                	li	a0,5
ffffffffc0201028:	61b000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020102c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc020102e:	28050363          	beqz	a0,ffffffffc02012b4 <default_check+0x452>
ffffffffc0201032:	651c                	ld	a5,8(a0)
ffffffffc0201034:	8385                	srli	a5,a5,0x1
ffffffffc0201036:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0201038:	54079e63          	bnez	a5,ffffffffc0201594 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc020103c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020103e:	00093b03          	ld	s6,0(s2)
ffffffffc0201042:	00893a83          	ld	s5,8(s2)
ffffffffc0201046:	000c8797          	auipc	a5,0xc8
ffffffffc020104a:	3127b923          	sd	s2,786(a5) # ffffffffc02c9358 <free_area>
ffffffffc020104e:	000c8797          	auipc	a5,0xc8
ffffffffc0201052:	3127b923          	sd	s2,786(a5) # ffffffffc02c9360 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0201056:	5ed000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020105a:	50051d63          	bnez	a0,ffffffffc0201574 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020105e:	08098a13          	addi	s4,s3,128
ffffffffc0201062:	8552                	mv	a0,s4
ffffffffc0201064:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201066:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc020106a:	000c8797          	auipc	a5,0xc8
ffffffffc020106e:	2e07af23          	sw	zero,766(a5) # ffffffffc02c9368 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201072:	659000ef          	jal	ra,ffffffffc0201eca <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201076:	4511                	li	a0,4
ffffffffc0201078:	5cb000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020107c:	4c051c63          	bnez	a0,ffffffffc0201554 <default_check+0x6f2>
ffffffffc0201080:	0889b783          	ld	a5,136(s3)
ffffffffc0201084:	8385                	srli	a5,a5,0x1
ffffffffc0201086:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201088:	4a078663          	beqz	a5,ffffffffc0201534 <default_check+0x6d2>
ffffffffc020108c:	0909a703          	lw	a4,144(s3)
ffffffffc0201090:	478d                	li	a5,3
ffffffffc0201092:	4af71163          	bne	a4,a5,ffffffffc0201534 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201096:	450d                	li	a0,3
ffffffffc0201098:	5ab000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020109c:	8c2a                	mv	s8,a0
ffffffffc020109e:	46050b63          	beqz	a0,ffffffffc0201514 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc02010a2:	4505                	li	a0,1
ffffffffc02010a4:	59f000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc02010a8:	44051663          	bnez	a0,ffffffffc02014f4 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc02010ac:	438a1463          	bne	s4,s8,ffffffffc02014d4 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02010b0:	4585                	li	a1,1
ffffffffc02010b2:	854e                	mv	a0,s3
ffffffffc02010b4:	617000ef          	jal	ra,ffffffffc0201eca <free_pages>
    free_pages(p1, 3);
ffffffffc02010b8:	458d                	li	a1,3
ffffffffc02010ba:	8552                	mv	a0,s4
ffffffffc02010bc:	60f000ef          	jal	ra,ffffffffc0201eca <free_pages>
ffffffffc02010c0:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02010c4:	04098c13          	addi	s8,s3,64
ffffffffc02010c8:	8385                	srli	a5,a5,0x1
ffffffffc02010ca:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02010cc:	3e078463          	beqz	a5,ffffffffc02014b4 <default_check+0x652>
ffffffffc02010d0:	0109a703          	lw	a4,16(s3)
ffffffffc02010d4:	4785                	li	a5,1
ffffffffc02010d6:	3cf71f63          	bne	a4,a5,ffffffffc02014b4 <default_check+0x652>
ffffffffc02010da:	008a3783          	ld	a5,8(s4)
ffffffffc02010de:	8385                	srli	a5,a5,0x1
ffffffffc02010e0:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010e2:	3a078963          	beqz	a5,ffffffffc0201494 <default_check+0x632>
ffffffffc02010e6:	010a2703          	lw	a4,16(s4)
ffffffffc02010ea:	478d                	li	a5,3
ffffffffc02010ec:	3af71463          	bne	a4,a5,ffffffffc0201494 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02010f0:	4505                	li	a0,1
ffffffffc02010f2:	551000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc02010f6:	36a99f63          	bne	s3,a0,ffffffffc0201474 <default_check+0x612>
    free_page(p0);
ffffffffc02010fa:	4585                	li	a1,1
ffffffffc02010fc:	5cf000ef          	jal	ra,ffffffffc0201eca <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201100:	4509                	li	a0,2
ffffffffc0201102:	541000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0201106:	34aa1763          	bne	s4,a0,ffffffffc0201454 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc020110a:	4589                	li	a1,2
ffffffffc020110c:	5bf000ef          	jal	ra,ffffffffc0201eca <free_pages>
    free_page(p2);
ffffffffc0201110:	4585                	li	a1,1
ffffffffc0201112:	8562                	mv	a0,s8
ffffffffc0201114:	5b7000ef          	jal	ra,ffffffffc0201eca <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201118:	4515                	li	a0,5
ffffffffc020111a:	529000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020111e:	89aa                	mv	s3,a0
ffffffffc0201120:	48050a63          	beqz	a0,ffffffffc02015b4 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0201124:	4505                	li	a0,1
ffffffffc0201126:	51d000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020112a:	2e051563          	bnez	a0,ffffffffc0201414 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc020112e:	01092783          	lw	a5,16(s2)
ffffffffc0201132:	2c079163          	bnez	a5,ffffffffc02013f4 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201136:	4595                	li	a1,5
ffffffffc0201138:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020113a:	000c8797          	auipc	a5,0xc8
ffffffffc020113e:	2377a723          	sw	s7,558(a5) # ffffffffc02c9368 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0201142:	000c8797          	auipc	a5,0xc8
ffffffffc0201146:	2167bb23          	sd	s6,534(a5) # ffffffffc02c9358 <free_area>
ffffffffc020114a:	000c8797          	auipc	a5,0xc8
ffffffffc020114e:	2157bb23          	sd	s5,534(a5) # ffffffffc02c9360 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0201152:	579000ef          	jal	ra,ffffffffc0201eca <free_pages>
    return listelm->next;
ffffffffc0201156:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020115a:	01278963          	beq	a5,s2,ffffffffc020116c <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020115e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201162:	679c                	ld	a5,8(a5)
ffffffffc0201164:	34fd                	addiw	s1,s1,-1
ffffffffc0201166:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201168:	ff279be3          	bne	a5,s2,ffffffffc020115e <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc020116c:	26049463          	bnez	s1,ffffffffc02013d4 <default_check+0x572>
    assert(total == 0);
ffffffffc0201170:	46041263          	bnez	s0,ffffffffc02015d4 <default_check+0x772>
}
ffffffffc0201174:	60a6                	ld	ra,72(sp)
ffffffffc0201176:	6406                	ld	s0,64(sp)
ffffffffc0201178:	74e2                	ld	s1,56(sp)
ffffffffc020117a:	7942                	ld	s2,48(sp)
ffffffffc020117c:	79a2                	ld	s3,40(sp)
ffffffffc020117e:	7a02                	ld	s4,32(sp)
ffffffffc0201180:	6ae2                	ld	s5,24(sp)
ffffffffc0201182:	6b42                	ld	s6,16(sp)
ffffffffc0201184:	6ba2                	ld	s7,8(sp)
ffffffffc0201186:	6c02                	ld	s8,0(sp)
ffffffffc0201188:	6161                	addi	sp,sp,80
ffffffffc020118a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc020118c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020118e:	4401                	li	s0,0
ffffffffc0201190:	4481                	li	s1,0
ffffffffc0201192:	b30d                	j	ffffffffc0200eb4 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0201194:	00009697          	auipc	a3,0x9
ffffffffc0201198:	94c68693          	addi	a3,a3,-1716 # ffffffffc0209ae0 <commands+0x878>
ffffffffc020119c:	00008617          	auipc	a2,0x8
ffffffffc02011a0:	58c60613          	addi	a2,a2,1420 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02011a4:	0ef00593          	li	a1,239
ffffffffc02011a8:	00009517          	auipc	a0,0x9
ffffffffc02011ac:	94850513          	addi	a0,a0,-1720 # ffffffffc0209af0 <commands+0x888>
ffffffffc02011b0:	ad8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02011b4:	00009697          	auipc	a3,0x9
ffffffffc02011b8:	9d468693          	addi	a3,a3,-1580 # ffffffffc0209b88 <commands+0x920>
ffffffffc02011bc:	00008617          	auipc	a2,0x8
ffffffffc02011c0:	56c60613          	addi	a2,a2,1388 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02011c4:	0bc00593          	li	a1,188
ffffffffc02011c8:	00009517          	auipc	a0,0x9
ffffffffc02011cc:	92850513          	addi	a0,a0,-1752 # ffffffffc0209af0 <commands+0x888>
ffffffffc02011d0:	ab8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02011d4:	00009697          	auipc	a3,0x9
ffffffffc02011d8:	9dc68693          	addi	a3,a3,-1572 # ffffffffc0209bb0 <commands+0x948>
ffffffffc02011dc:	00008617          	auipc	a2,0x8
ffffffffc02011e0:	54c60613          	addi	a2,a2,1356 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02011e4:	0bd00593          	li	a1,189
ffffffffc02011e8:	00009517          	auipc	a0,0x9
ffffffffc02011ec:	90850513          	addi	a0,a0,-1784 # ffffffffc0209af0 <commands+0x888>
ffffffffc02011f0:	a98ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02011f4:	00009697          	auipc	a3,0x9
ffffffffc02011f8:	9fc68693          	addi	a3,a3,-1540 # ffffffffc0209bf0 <commands+0x988>
ffffffffc02011fc:	00008617          	auipc	a2,0x8
ffffffffc0201200:	52c60613          	addi	a2,a2,1324 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201204:	0bf00593          	li	a1,191
ffffffffc0201208:	00009517          	auipc	a0,0x9
ffffffffc020120c:	8e850513          	addi	a0,a0,-1816 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201210:	a78ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201214:	00009697          	auipc	a3,0x9
ffffffffc0201218:	a6468693          	addi	a3,a3,-1436 # ffffffffc0209c78 <commands+0xa10>
ffffffffc020121c:	00008617          	auipc	a2,0x8
ffffffffc0201220:	50c60613          	addi	a2,a2,1292 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201224:	0d800593          	li	a1,216
ffffffffc0201228:	00009517          	auipc	a0,0x9
ffffffffc020122c:	8c850513          	addi	a0,a0,-1848 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201230:	a58ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201234:	00009697          	auipc	a3,0x9
ffffffffc0201238:	8f468693          	addi	a3,a3,-1804 # ffffffffc0209b28 <commands+0x8c0>
ffffffffc020123c:	00008617          	auipc	a2,0x8
ffffffffc0201240:	4ec60613          	addi	a2,a2,1260 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201244:	0d100593          	li	a1,209
ffffffffc0201248:	00009517          	auipc	a0,0x9
ffffffffc020124c:	8a850513          	addi	a0,a0,-1880 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201250:	a38ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free == 3);
ffffffffc0201254:	00009697          	auipc	a3,0x9
ffffffffc0201258:	a1468693          	addi	a3,a3,-1516 # ffffffffc0209c68 <commands+0xa00>
ffffffffc020125c:	00008617          	auipc	a2,0x8
ffffffffc0201260:	4cc60613          	addi	a2,a2,1228 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201264:	0cf00593          	li	a1,207
ffffffffc0201268:	00009517          	auipc	a0,0x9
ffffffffc020126c:	88850513          	addi	a0,a0,-1912 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201270:	a18ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201274:	00009697          	auipc	a3,0x9
ffffffffc0201278:	9dc68693          	addi	a3,a3,-1572 # ffffffffc0209c50 <commands+0x9e8>
ffffffffc020127c:	00008617          	auipc	a2,0x8
ffffffffc0201280:	4ac60613          	addi	a2,a2,1196 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201284:	0ca00593          	li	a1,202
ffffffffc0201288:	00009517          	auipc	a0,0x9
ffffffffc020128c:	86850513          	addi	a0,a0,-1944 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201290:	9f8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201294:	00009697          	auipc	a3,0x9
ffffffffc0201298:	99c68693          	addi	a3,a3,-1636 # ffffffffc0209c30 <commands+0x9c8>
ffffffffc020129c:	00008617          	auipc	a2,0x8
ffffffffc02012a0:	48c60613          	addi	a2,a2,1164 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02012a4:	0c100593          	li	a1,193
ffffffffc02012a8:	00009517          	auipc	a0,0x9
ffffffffc02012ac:	84850513          	addi	a0,a0,-1976 # ffffffffc0209af0 <commands+0x888>
ffffffffc02012b0:	9d8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(p0 != NULL);
ffffffffc02012b4:	00009697          	auipc	a3,0x9
ffffffffc02012b8:	a0c68693          	addi	a3,a3,-1524 # ffffffffc0209cc0 <commands+0xa58>
ffffffffc02012bc:	00008617          	auipc	a2,0x8
ffffffffc02012c0:	46c60613          	addi	a2,a2,1132 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02012c4:	0f700593          	li	a1,247
ffffffffc02012c8:	00009517          	auipc	a0,0x9
ffffffffc02012cc:	82850513          	addi	a0,a0,-2008 # ffffffffc0209af0 <commands+0x888>
ffffffffc02012d0:	9b8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free == 0);
ffffffffc02012d4:	00009697          	auipc	a3,0x9
ffffffffc02012d8:	9dc68693          	addi	a3,a3,-1572 # ffffffffc0209cb0 <commands+0xa48>
ffffffffc02012dc:	00008617          	auipc	a2,0x8
ffffffffc02012e0:	44c60613          	addi	a2,a2,1100 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02012e4:	0de00593          	li	a1,222
ffffffffc02012e8:	00009517          	auipc	a0,0x9
ffffffffc02012ec:	80850513          	addi	a0,a0,-2040 # ffffffffc0209af0 <commands+0x888>
ffffffffc02012f0:	998ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012f4:	00009697          	auipc	a3,0x9
ffffffffc02012f8:	95c68693          	addi	a3,a3,-1700 # ffffffffc0209c50 <commands+0x9e8>
ffffffffc02012fc:	00008617          	auipc	a2,0x8
ffffffffc0201300:	42c60613          	addi	a2,a2,1068 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201304:	0dc00593          	li	a1,220
ffffffffc0201308:	00008517          	auipc	a0,0x8
ffffffffc020130c:	7e850513          	addi	a0,a0,2024 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201310:	978ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201314:	00009697          	auipc	a3,0x9
ffffffffc0201318:	97c68693          	addi	a3,a3,-1668 # ffffffffc0209c90 <commands+0xa28>
ffffffffc020131c:	00008617          	auipc	a2,0x8
ffffffffc0201320:	40c60613          	addi	a2,a2,1036 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201324:	0db00593          	li	a1,219
ffffffffc0201328:	00008517          	auipc	a0,0x8
ffffffffc020132c:	7c850513          	addi	a0,a0,1992 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201330:	958ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201334:	00008697          	auipc	a3,0x8
ffffffffc0201338:	7f468693          	addi	a3,a3,2036 # ffffffffc0209b28 <commands+0x8c0>
ffffffffc020133c:	00008617          	auipc	a2,0x8
ffffffffc0201340:	3ec60613          	addi	a2,a2,1004 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201344:	0b800593          	li	a1,184
ffffffffc0201348:	00008517          	auipc	a0,0x8
ffffffffc020134c:	7a850513          	addi	a0,a0,1960 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201350:	938ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201354:	00009697          	auipc	a3,0x9
ffffffffc0201358:	8fc68693          	addi	a3,a3,-1796 # ffffffffc0209c50 <commands+0x9e8>
ffffffffc020135c:	00008617          	auipc	a2,0x8
ffffffffc0201360:	3cc60613          	addi	a2,a2,972 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201364:	0d500593          	li	a1,213
ffffffffc0201368:	00008517          	auipc	a0,0x8
ffffffffc020136c:	78850513          	addi	a0,a0,1928 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201370:	918ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201374:	00008697          	auipc	a3,0x8
ffffffffc0201378:	7f468693          	addi	a3,a3,2036 # ffffffffc0209b68 <commands+0x900>
ffffffffc020137c:	00008617          	auipc	a2,0x8
ffffffffc0201380:	3ac60613          	addi	a2,a2,940 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201384:	0d300593          	li	a1,211
ffffffffc0201388:	00008517          	auipc	a0,0x8
ffffffffc020138c:	76850513          	addi	a0,a0,1896 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201390:	8f8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201394:	00008697          	auipc	a3,0x8
ffffffffc0201398:	7b468693          	addi	a3,a3,1972 # ffffffffc0209b48 <commands+0x8e0>
ffffffffc020139c:	00008617          	auipc	a2,0x8
ffffffffc02013a0:	38c60613          	addi	a2,a2,908 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02013a4:	0d200593          	li	a1,210
ffffffffc02013a8:	00008517          	auipc	a0,0x8
ffffffffc02013ac:	74850513          	addi	a0,a0,1864 # ffffffffc0209af0 <commands+0x888>
ffffffffc02013b0:	8d8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02013b4:	00008697          	auipc	a3,0x8
ffffffffc02013b8:	7b468693          	addi	a3,a3,1972 # ffffffffc0209b68 <commands+0x900>
ffffffffc02013bc:	00008617          	auipc	a2,0x8
ffffffffc02013c0:	36c60613          	addi	a2,a2,876 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02013c4:	0ba00593          	li	a1,186
ffffffffc02013c8:	00008517          	auipc	a0,0x8
ffffffffc02013cc:	72850513          	addi	a0,a0,1832 # ffffffffc0209af0 <commands+0x888>
ffffffffc02013d0:	8b8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(count == 0);
ffffffffc02013d4:	00009697          	auipc	a3,0x9
ffffffffc02013d8:	a3c68693          	addi	a3,a3,-1476 # ffffffffc0209e10 <commands+0xba8>
ffffffffc02013dc:	00008617          	auipc	a2,0x8
ffffffffc02013e0:	34c60613          	addi	a2,a2,844 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02013e4:	12400593          	li	a1,292
ffffffffc02013e8:	00008517          	auipc	a0,0x8
ffffffffc02013ec:	70850513          	addi	a0,a0,1800 # ffffffffc0209af0 <commands+0x888>
ffffffffc02013f0:	898ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free == 0);
ffffffffc02013f4:	00009697          	auipc	a3,0x9
ffffffffc02013f8:	8bc68693          	addi	a3,a3,-1860 # ffffffffc0209cb0 <commands+0xa48>
ffffffffc02013fc:	00008617          	auipc	a2,0x8
ffffffffc0201400:	32c60613          	addi	a2,a2,812 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201404:	11900593          	li	a1,281
ffffffffc0201408:	00008517          	auipc	a0,0x8
ffffffffc020140c:	6e850513          	addi	a0,a0,1768 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201410:	878ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201414:	00009697          	auipc	a3,0x9
ffffffffc0201418:	83c68693          	addi	a3,a3,-1988 # ffffffffc0209c50 <commands+0x9e8>
ffffffffc020141c:	00008617          	auipc	a2,0x8
ffffffffc0201420:	30c60613          	addi	a2,a2,780 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201424:	11700593          	li	a1,279
ffffffffc0201428:	00008517          	auipc	a0,0x8
ffffffffc020142c:	6c850513          	addi	a0,a0,1736 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201430:	858ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201434:	00008697          	auipc	a3,0x8
ffffffffc0201438:	7dc68693          	addi	a3,a3,2012 # ffffffffc0209c10 <commands+0x9a8>
ffffffffc020143c:	00008617          	auipc	a2,0x8
ffffffffc0201440:	2ec60613          	addi	a2,a2,748 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201444:	0c000593          	li	a1,192
ffffffffc0201448:	00008517          	auipc	a0,0x8
ffffffffc020144c:	6a850513          	addi	a0,a0,1704 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201450:	838ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201454:	00009697          	auipc	a3,0x9
ffffffffc0201458:	97c68693          	addi	a3,a3,-1668 # ffffffffc0209dd0 <commands+0xb68>
ffffffffc020145c:	00008617          	auipc	a2,0x8
ffffffffc0201460:	2cc60613          	addi	a2,a2,716 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201464:	11100593          	li	a1,273
ffffffffc0201468:	00008517          	auipc	a0,0x8
ffffffffc020146c:	68850513          	addi	a0,a0,1672 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201470:	818ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201474:	00009697          	auipc	a3,0x9
ffffffffc0201478:	93c68693          	addi	a3,a3,-1732 # ffffffffc0209db0 <commands+0xb48>
ffffffffc020147c:	00008617          	auipc	a2,0x8
ffffffffc0201480:	2ac60613          	addi	a2,a2,684 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201484:	10f00593          	li	a1,271
ffffffffc0201488:	00008517          	auipc	a0,0x8
ffffffffc020148c:	66850513          	addi	a0,a0,1640 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201490:	ff9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201494:	00009697          	auipc	a3,0x9
ffffffffc0201498:	8f468693          	addi	a3,a3,-1804 # ffffffffc0209d88 <commands+0xb20>
ffffffffc020149c:	00008617          	auipc	a2,0x8
ffffffffc02014a0:	28c60613          	addi	a2,a2,652 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02014a4:	10d00593          	li	a1,269
ffffffffc02014a8:	00008517          	auipc	a0,0x8
ffffffffc02014ac:	64850513          	addi	a0,a0,1608 # ffffffffc0209af0 <commands+0x888>
ffffffffc02014b0:	fd9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02014b4:	00009697          	auipc	a3,0x9
ffffffffc02014b8:	8ac68693          	addi	a3,a3,-1876 # ffffffffc0209d60 <commands+0xaf8>
ffffffffc02014bc:	00008617          	auipc	a2,0x8
ffffffffc02014c0:	26c60613          	addi	a2,a2,620 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02014c4:	10c00593          	li	a1,268
ffffffffc02014c8:	00008517          	auipc	a0,0x8
ffffffffc02014cc:	62850513          	addi	a0,a0,1576 # ffffffffc0209af0 <commands+0x888>
ffffffffc02014d0:	fb9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02014d4:	00009697          	auipc	a3,0x9
ffffffffc02014d8:	87c68693          	addi	a3,a3,-1924 # ffffffffc0209d50 <commands+0xae8>
ffffffffc02014dc:	00008617          	auipc	a2,0x8
ffffffffc02014e0:	24c60613          	addi	a2,a2,588 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02014e4:	10700593          	li	a1,263
ffffffffc02014e8:	00008517          	auipc	a0,0x8
ffffffffc02014ec:	60850513          	addi	a0,a0,1544 # ffffffffc0209af0 <commands+0x888>
ffffffffc02014f0:	f99fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014f4:	00008697          	auipc	a3,0x8
ffffffffc02014f8:	75c68693          	addi	a3,a3,1884 # ffffffffc0209c50 <commands+0x9e8>
ffffffffc02014fc:	00008617          	auipc	a2,0x8
ffffffffc0201500:	22c60613          	addi	a2,a2,556 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201504:	10600593          	li	a1,262
ffffffffc0201508:	00008517          	auipc	a0,0x8
ffffffffc020150c:	5e850513          	addi	a0,a0,1512 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201510:	f79fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201514:	00009697          	auipc	a3,0x9
ffffffffc0201518:	81c68693          	addi	a3,a3,-2020 # ffffffffc0209d30 <commands+0xac8>
ffffffffc020151c:	00008617          	auipc	a2,0x8
ffffffffc0201520:	20c60613          	addi	a2,a2,524 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201524:	10500593          	li	a1,261
ffffffffc0201528:	00008517          	auipc	a0,0x8
ffffffffc020152c:	5c850513          	addi	a0,a0,1480 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201530:	f59fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201534:	00008697          	auipc	a3,0x8
ffffffffc0201538:	7cc68693          	addi	a3,a3,1996 # ffffffffc0209d00 <commands+0xa98>
ffffffffc020153c:	00008617          	auipc	a2,0x8
ffffffffc0201540:	1ec60613          	addi	a2,a2,492 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201544:	10400593          	li	a1,260
ffffffffc0201548:	00008517          	auipc	a0,0x8
ffffffffc020154c:	5a850513          	addi	a0,a0,1448 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201550:	f39fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201554:	00008697          	auipc	a3,0x8
ffffffffc0201558:	79468693          	addi	a3,a3,1940 # ffffffffc0209ce8 <commands+0xa80>
ffffffffc020155c:	00008617          	auipc	a2,0x8
ffffffffc0201560:	1cc60613          	addi	a2,a2,460 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201564:	10300593          	li	a1,259
ffffffffc0201568:	00008517          	auipc	a0,0x8
ffffffffc020156c:	58850513          	addi	a0,a0,1416 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201570:	f19fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201574:	00008697          	auipc	a3,0x8
ffffffffc0201578:	6dc68693          	addi	a3,a3,1756 # ffffffffc0209c50 <commands+0x9e8>
ffffffffc020157c:	00008617          	auipc	a2,0x8
ffffffffc0201580:	1ac60613          	addi	a2,a2,428 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201584:	0fd00593          	li	a1,253
ffffffffc0201588:	00008517          	auipc	a0,0x8
ffffffffc020158c:	56850513          	addi	a0,a0,1384 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201590:	ef9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201594:	00008697          	auipc	a3,0x8
ffffffffc0201598:	73c68693          	addi	a3,a3,1852 # ffffffffc0209cd0 <commands+0xa68>
ffffffffc020159c:	00008617          	auipc	a2,0x8
ffffffffc02015a0:	18c60613          	addi	a2,a2,396 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02015a4:	0f800593          	li	a1,248
ffffffffc02015a8:	00008517          	auipc	a0,0x8
ffffffffc02015ac:	54850513          	addi	a0,a0,1352 # ffffffffc0209af0 <commands+0x888>
ffffffffc02015b0:	ed9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02015b4:	00009697          	auipc	a3,0x9
ffffffffc02015b8:	83c68693          	addi	a3,a3,-1988 # ffffffffc0209df0 <commands+0xb88>
ffffffffc02015bc:	00008617          	auipc	a2,0x8
ffffffffc02015c0:	16c60613          	addi	a2,a2,364 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02015c4:	11600593          	li	a1,278
ffffffffc02015c8:	00008517          	auipc	a0,0x8
ffffffffc02015cc:	52850513          	addi	a0,a0,1320 # ffffffffc0209af0 <commands+0x888>
ffffffffc02015d0:	eb9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(total == 0);
ffffffffc02015d4:	00009697          	auipc	a3,0x9
ffffffffc02015d8:	84c68693          	addi	a3,a3,-1972 # ffffffffc0209e20 <commands+0xbb8>
ffffffffc02015dc:	00008617          	auipc	a2,0x8
ffffffffc02015e0:	14c60613          	addi	a2,a2,332 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02015e4:	12500593          	li	a1,293
ffffffffc02015e8:	00008517          	auipc	a0,0x8
ffffffffc02015ec:	50850513          	addi	a0,a0,1288 # ffffffffc0209af0 <commands+0x888>
ffffffffc02015f0:	e99fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(total == nr_free_pages());
ffffffffc02015f4:	00008697          	auipc	a3,0x8
ffffffffc02015f8:	51468693          	addi	a3,a3,1300 # ffffffffc0209b08 <commands+0x8a0>
ffffffffc02015fc:	00008617          	auipc	a2,0x8
ffffffffc0201600:	12c60613          	addi	a2,a2,300 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201604:	0f200593          	li	a1,242
ffffffffc0201608:	00008517          	auipc	a0,0x8
ffffffffc020160c:	4e850513          	addi	a0,a0,1256 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201610:	e79fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201614:	00008697          	auipc	a3,0x8
ffffffffc0201618:	53468693          	addi	a3,a3,1332 # ffffffffc0209b48 <commands+0x8e0>
ffffffffc020161c:	00008617          	auipc	a2,0x8
ffffffffc0201620:	10c60613          	addi	a2,a2,268 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201624:	0b900593          	li	a1,185
ffffffffc0201628:	00008517          	auipc	a0,0x8
ffffffffc020162c:	4c850513          	addi	a0,a0,1224 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201630:	e59fe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201634 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201634:	1141                	addi	sp,sp,-16
ffffffffc0201636:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201638:	16058e63          	beqz	a1,ffffffffc02017b4 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc020163c:	00659693          	slli	a3,a1,0x6
ffffffffc0201640:	96aa                	add	a3,a3,a0
ffffffffc0201642:	02d50d63          	beq	a0,a3,ffffffffc020167c <default_free_pages+0x48>
ffffffffc0201646:	651c                	ld	a5,8(a0)
ffffffffc0201648:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020164a:	14079563          	bnez	a5,ffffffffc0201794 <default_free_pages+0x160>
ffffffffc020164e:	651c                	ld	a5,8(a0)
ffffffffc0201650:	8385                	srli	a5,a5,0x1
ffffffffc0201652:	8b85                	andi	a5,a5,1
ffffffffc0201654:	14079063          	bnez	a5,ffffffffc0201794 <default_free_pages+0x160>
ffffffffc0201658:	87aa                	mv	a5,a0
ffffffffc020165a:	a809                	j	ffffffffc020166c <default_free_pages+0x38>
ffffffffc020165c:	6798                	ld	a4,8(a5)
ffffffffc020165e:	8b05                	andi	a4,a4,1
ffffffffc0201660:	12071a63          	bnez	a4,ffffffffc0201794 <default_free_pages+0x160>
ffffffffc0201664:	6798                	ld	a4,8(a5)
ffffffffc0201666:	8b09                	andi	a4,a4,2
ffffffffc0201668:	12071663          	bnez	a4,ffffffffc0201794 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc020166c:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0201670:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201674:	04078793          	addi	a5,a5,64
ffffffffc0201678:	fed792e3          	bne	a5,a3,ffffffffc020165c <default_free_pages+0x28>
    base->property = n;
ffffffffc020167c:	2581                	sext.w	a1,a1
ffffffffc020167e:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201680:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201684:	4789                	li	a5,2
ffffffffc0201686:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020168a:	000c8697          	auipc	a3,0xc8
ffffffffc020168e:	cce68693          	addi	a3,a3,-818 # ffffffffc02c9358 <free_area>
ffffffffc0201692:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201694:	669c                	ld	a5,8(a3)
ffffffffc0201696:	9db9                	addw	a1,a1,a4
ffffffffc0201698:	000c8717          	auipc	a4,0xc8
ffffffffc020169c:	ccb72823          	sw	a1,-816(a4) # ffffffffc02c9368 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02016a0:	0cd78163          	beq	a5,a3,ffffffffc0201762 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc02016a4:	fe878713          	addi	a4,a5,-24
ffffffffc02016a8:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02016aa:	4801                	li	a6,0
ffffffffc02016ac:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02016b0:	00e56a63          	bltu	a0,a4,ffffffffc02016c4 <default_free_pages+0x90>
    return listelm->next;
ffffffffc02016b4:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02016b6:	04d70f63          	beq	a4,a3,ffffffffc0201714 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016ba:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02016bc:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02016c0:	fee57ae3          	bleu	a4,a0,ffffffffc02016b4 <default_free_pages+0x80>
ffffffffc02016c4:	00080663          	beqz	a6,ffffffffc02016d0 <default_free_pages+0x9c>
ffffffffc02016c8:	000c8817          	auipc	a6,0xc8
ffffffffc02016cc:	c8b83823          	sd	a1,-880(a6) # ffffffffc02c9358 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02016d0:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02016d2:	e390                	sd	a2,0(a5)
ffffffffc02016d4:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02016d6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016d8:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02016da:	06d58a63          	beq	a1,a3,ffffffffc020174e <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc02016de:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc02016e2:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02016e6:	02061793          	slli	a5,a2,0x20
ffffffffc02016ea:	83e9                	srli	a5,a5,0x1a
ffffffffc02016ec:	97ba                	add	a5,a5,a4
ffffffffc02016ee:	04f51b63          	bne	a0,a5,ffffffffc0201744 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc02016f2:	491c                	lw	a5,16(a0)
ffffffffc02016f4:	9e3d                	addw	a2,a2,a5
ffffffffc02016f6:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02016fa:	57f5                	li	a5,-3
ffffffffc02016fc:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201700:	01853803          	ld	a6,24(a0)
ffffffffc0201704:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc0201706:	853a                	mv	a0,a4
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201708:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc020170c:	659c                	ld	a5,8(a1)
ffffffffc020170e:	01063023          	sd	a6,0(a2)
ffffffffc0201712:	a815                	j	ffffffffc0201746 <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc0201714:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201716:	f114                	sd	a3,32(a0)
ffffffffc0201718:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020171a:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020171c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020171e:	00d70563          	beq	a4,a3,ffffffffc0201728 <default_free_pages+0xf4>
ffffffffc0201722:	4805                	li	a6,1
ffffffffc0201724:	87ba                	mv	a5,a4
ffffffffc0201726:	bf59                	j	ffffffffc02016bc <default_free_pages+0x88>
ffffffffc0201728:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020172a:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc020172c:	00d78d63          	beq	a5,a3,ffffffffc0201746 <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0201730:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201734:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0201738:	02061793          	slli	a5,a2,0x20
ffffffffc020173c:	83e9                	srli	a5,a5,0x1a
ffffffffc020173e:	97ba                	add	a5,a5,a4
ffffffffc0201740:	faf509e3          	beq	a0,a5,ffffffffc02016f2 <default_free_pages+0xbe>
ffffffffc0201744:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201746:	fe878713          	addi	a4,a5,-24
ffffffffc020174a:	00d78963          	beq	a5,a3,ffffffffc020175c <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc020174e:	4910                	lw	a2,16(a0)
ffffffffc0201750:	02061693          	slli	a3,a2,0x20
ffffffffc0201754:	82e9                	srli	a3,a3,0x1a
ffffffffc0201756:	96aa                	add	a3,a3,a0
ffffffffc0201758:	00d70e63          	beq	a4,a3,ffffffffc0201774 <default_free_pages+0x140>
}
ffffffffc020175c:	60a2                	ld	ra,8(sp)
ffffffffc020175e:	0141                	addi	sp,sp,16
ffffffffc0201760:	8082                	ret
ffffffffc0201762:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201764:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201768:	e398                	sd	a4,0(a5)
ffffffffc020176a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020176c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020176e:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201770:	0141                	addi	sp,sp,16
ffffffffc0201772:	8082                	ret
            base->property += p->property;
ffffffffc0201774:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201778:	ff078693          	addi	a3,a5,-16
ffffffffc020177c:	9e39                	addw	a2,a2,a4
ffffffffc020177e:	c910                	sw	a2,16(a0)
ffffffffc0201780:	5775                	li	a4,-3
ffffffffc0201782:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201786:	6398                	ld	a4,0(a5)
ffffffffc0201788:	679c                	ld	a5,8(a5)
}
ffffffffc020178a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020178c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020178e:	e398                	sd	a4,0(a5)
ffffffffc0201790:	0141                	addi	sp,sp,16
ffffffffc0201792:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201794:	00008697          	auipc	a3,0x8
ffffffffc0201798:	69c68693          	addi	a3,a3,1692 # ffffffffc0209e30 <commands+0xbc8>
ffffffffc020179c:	00008617          	auipc	a2,0x8
ffffffffc02017a0:	f8c60613          	addi	a2,a2,-116 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02017a4:	08200593          	li	a1,130
ffffffffc02017a8:	00008517          	auipc	a0,0x8
ffffffffc02017ac:	34850513          	addi	a0,a0,840 # ffffffffc0209af0 <commands+0x888>
ffffffffc02017b0:	cd9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(n > 0);
ffffffffc02017b4:	00008697          	auipc	a3,0x8
ffffffffc02017b8:	6a468693          	addi	a3,a3,1700 # ffffffffc0209e58 <commands+0xbf0>
ffffffffc02017bc:	00008617          	auipc	a2,0x8
ffffffffc02017c0:	f6c60613          	addi	a2,a2,-148 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02017c4:	07f00593          	li	a1,127
ffffffffc02017c8:	00008517          	auipc	a0,0x8
ffffffffc02017cc:	32850513          	addi	a0,a0,808 # ffffffffc0209af0 <commands+0x888>
ffffffffc02017d0:	cb9fe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02017d4 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02017d4:	c959                	beqz	a0,ffffffffc020186a <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02017d6:	000c8597          	auipc	a1,0xc8
ffffffffc02017da:	b8258593          	addi	a1,a1,-1150 # ffffffffc02c9358 <free_area>
ffffffffc02017de:	0105a803          	lw	a6,16(a1)
ffffffffc02017e2:	862a                	mv	a2,a0
ffffffffc02017e4:	02081793          	slli	a5,a6,0x20
ffffffffc02017e8:	9381                	srli	a5,a5,0x20
ffffffffc02017ea:	00a7ee63          	bltu	a5,a0,ffffffffc0201806 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02017ee:	87ae                	mv	a5,a1
ffffffffc02017f0:	a801                	j	ffffffffc0201800 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02017f2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02017f6:	02071693          	slli	a3,a4,0x20
ffffffffc02017fa:	9281                	srli	a3,a3,0x20
ffffffffc02017fc:	00c6f763          	bleu	a2,a3,ffffffffc020180a <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201800:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201802:	feb798e3          	bne	a5,a1,ffffffffc02017f2 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201806:	4501                	li	a0,0
}
ffffffffc0201808:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc020180a:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc020180e:	dd6d                	beqz	a0,ffffffffc0201808 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201810:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201814:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0201818:	00060e1b          	sext.w	t3,a2
ffffffffc020181c:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201820:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201824:	02d67863          	bleu	a3,a2,ffffffffc0201854 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc0201828:	061a                	slli	a2,a2,0x6
ffffffffc020182a:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc020182c:	41c7073b          	subw	a4,a4,t3
ffffffffc0201830:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201832:	00860693          	addi	a3,a2,8
ffffffffc0201836:	4709                	li	a4,2
ffffffffc0201838:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc020183c:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201840:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0201844:	0105a803          	lw	a6,16(a1)
ffffffffc0201848:	e314                	sd	a3,0(a4)
ffffffffc020184a:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc020184e:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0201850:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0201854:	41c8083b          	subw	a6,a6,t3
ffffffffc0201858:	000c8717          	auipc	a4,0xc8
ffffffffc020185c:	b1072823          	sw	a6,-1264(a4) # ffffffffc02c9368 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201860:	5775                	li	a4,-3
ffffffffc0201862:	17c1                	addi	a5,a5,-16
ffffffffc0201864:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201868:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020186a:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020186c:	00008697          	auipc	a3,0x8
ffffffffc0201870:	5ec68693          	addi	a3,a3,1516 # ffffffffc0209e58 <commands+0xbf0>
ffffffffc0201874:	00008617          	auipc	a2,0x8
ffffffffc0201878:	eb460613          	addi	a2,a2,-332 # ffffffffc0209728 <commands+0x4c0>
ffffffffc020187c:	06100593          	li	a1,97
ffffffffc0201880:	00008517          	auipc	a0,0x8
ffffffffc0201884:	27050513          	addi	a0,a0,624 # ffffffffc0209af0 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc0201888:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020188a:	bfffe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020188e <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020188e:	1141                	addi	sp,sp,-16
ffffffffc0201890:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201892:	c1ed                	beqz	a1,ffffffffc0201974 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc0201894:	00659693          	slli	a3,a1,0x6
ffffffffc0201898:	96aa                	add	a3,a3,a0
ffffffffc020189a:	02d50463          	beq	a0,a3,ffffffffc02018c2 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020189e:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02018a0:	87aa                	mv	a5,a0
ffffffffc02018a2:	8b05                	andi	a4,a4,1
ffffffffc02018a4:	e709                	bnez	a4,ffffffffc02018ae <default_init_memmap+0x20>
ffffffffc02018a6:	a07d                	j	ffffffffc0201954 <default_init_memmap+0xc6>
ffffffffc02018a8:	6798                	ld	a4,8(a5)
ffffffffc02018aa:	8b05                	andi	a4,a4,1
ffffffffc02018ac:	c745                	beqz	a4,ffffffffc0201954 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc02018ae:	0007a823          	sw	zero,16(a5)
ffffffffc02018b2:	0007b423          	sd	zero,8(a5)
ffffffffc02018b6:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02018ba:	04078793          	addi	a5,a5,64
ffffffffc02018be:	fed795e3          	bne	a5,a3,ffffffffc02018a8 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc02018c2:	2581                	sext.w	a1,a1
ffffffffc02018c4:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02018c6:	4789                	li	a5,2
ffffffffc02018c8:	00850713          	addi	a4,a0,8
ffffffffc02018cc:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02018d0:	000c8697          	auipc	a3,0xc8
ffffffffc02018d4:	a8868693          	addi	a3,a3,-1400 # ffffffffc02c9358 <free_area>
ffffffffc02018d8:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02018da:	669c                	ld	a5,8(a3)
ffffffffc02018dc:	9db9                	addw	a1,a1,a4
ffffffffc02018de:	000c8717          	auipc	a4,0xc8
ffffffffc02018e2:	a8b72523          	sw	a1,-1398(a4) # ffffffffc02c9368 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02018e6:	04d78a63          	beq	a5,a3,ffffffffc020193a <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc02018ea:	fe878713          	addi	a4,a5,-24
ffffffffc02018ee:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02018f0:	4801                	li	a6,0
ffffffffc02018f2:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02018f6:	00e56a63          	bltu	a0,a4,ffffffffc020190a <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc02018fa:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02018fc:	02d70563          	beq	a4,a3,ffffffffc0201926 <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201900:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201902:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201906:	fee57ae3          	bleu	a4,a0,ffffffffc02018fa <default_init_memmap+0x6c>
ffffffffc020190a:	00080663          	beqz	a6,ffffffffc0201916 <default_init_memmap+0x88>
ffffffffc020190e:	000c8717          	auipc	a4,0xc8
ffffffffc0201912:	a4b73523          	sd	a1,-1462(a4) # ffffffffc02c9358 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201916:	6398                	ld	a4,0(a5)
}
ffffffffc0201918:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020191a:	e390                	sd	a2,0(a5)
ffffffffc020191c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020191e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201920:	ed18                	sd	a4,24(a0)
ffffffffc0201922:	0141                	addi	sp,sp,16
ffffffffc0201924:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201926:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201928:	f114                	sd	a3,32(a0)
ffffffffc020192a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020192c:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020192e:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201930:	00d70e63          	beq	a4,a3,ffffffffc020194c <default_init_memmap+0xbe>
ffffffffc0201934:	4805                	li	a6,1
ffffffffc0201936:	87ba                	mv	a5,a4
ffffffffc0201938:	b7e9                	j	ffffffffc0201902 <default_init_memmap+0x74>
}
ffffffffc020193a:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020193c:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201940:	e398                	sd	a4,0(a5)
ffffffffc0201942:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201944:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201946:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201948:	0141                	addi	sp,sp,16
ffffffffc020194a:	8082                	ret
ffffffffc020194c:	60a2                	ld	ra,8(sp)
ffffffffc020194e:	e290                	sd	a2,0(a3)
ffffffffc0201950:	0141                	addi	sp,sp,16
ffffffffc0201952:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201954:	00008697          	auipc	a3,0x8
ffffffffc0201958:	50c68693          	addi	a3,a3,1292 # ffffffffc0209e60 <commands+0xbf8>
ffffffffc020195c:	00008617          	auipc	a2,0x8
ffffffffc0201960:	dcc60613          	addi	a2,a2,-564 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201964:	04800593          	li	a1,72
ffffffffc0201968:	00008517          	auipc	a0,0x8
ffffffffc020196c:	18850513          	addi	a0,a0,392 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201970:	b19fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(n > 0);
ffffffffc0201974:	00008697          	auipc	a3,0x8
ffffffffc0201978:	4e468693          	addi	a3,a3,1252 # ffffffffc0209e58 <commands+0xbf0>
ffffffffc020197c:	00008617          	auipc	a2,0x8
ffffffffc0201980:	dac60613          	addi	a2,a2,-596 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201984:	04500593          	li	a1,69
ffffffffc0201988:	00008517          	auipc	a0,0x8
ffffffffc020198c:	16850513          	addi	a0,a0,360 # ffffffffc0209af0 <commands+0x888>
ffffffffc0201990:	af9fe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201994 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201994:	c125                	beqz	a0,ffffffffc02019f4 <slob_free+0x60>
		return;

	if (size)
ffffffffc0201996:	e1a5                	bnez	a1,ffffffffc02019f6 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201998:	100027f3          	csrr	a5,sstatus
ffffffffc020199c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020199e:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019a0:	e3bd                	bnez	a5,ffffffffc0201a06 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019a2:	000bc797          	auipc	a5,0xbc
ffffffffc02019a6:	50e78793          	addi	a5,a5,1294 # ffffffffc02bdeb0 <slobfree>
ffffffffc02019aa:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019ac:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019ae:	00a7fa63          	bleu	a0,a5,ffffffffc02019c2 <slob_free+0x2e>
ffffffffc02019b2:	00e56c63          	bltu	a0,a4,ffffffffc02019ca <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019b6:	00e7fa63          	bleu	a4,a5,ffffffffc02019ca <slob_free+0x36>
    return 0;
ffffffffc02019ba:	87ba                	mv	a5,a4
ffffffffc02019bc:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019be:	fea7eae3          	bltu	a5,a0,ffffffffc02019b2 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019c2:	fee7ece3          	bltu	a5,a4,ffffffffc02019ba <slob_free+0x26>
ffffffffc02019c6:	fee57ae3          	bleu	a4,a0,ffffffffc02019ba <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc02019ca:	4110                	lw	a2,0(a0)
ffffffffc02019cc:	00461693          	slli	a3,a2,0x4
ffffffffc02019d0:	96aa                	add	a3,a3,a0
ffffffffc02019d2:	08d70b63          	beq	a4,a3,ffffffffc0201a68 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02019d6:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc02019d8:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02019da:	00469713          	slli	a4,a3,0x4
ffffffffc02019de:	973e                	add	a4,a4,a5
ffffffffc02019e0:	08e50f63          	beq	a0,a4,ffffffffc0201a7e <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02019e4:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc02019e6:	000bc717          	auipc	a4,0xbc
ffffffffc02019ea:	4cf73523          	sd	a5,1226(a4) # ffffffffc02bdeb0 <slobfree>
    if (flag) {
ffffffffc02019ee:	c199                	beqz	a1,ffffffffc02019f4 <slob_free+0x60>
        intr_enable();
ffffffffc02019f0:	c5dfe06f          	j	ffffffffc020064c <intr_enable>
ffffffffc02019f4:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc02019f6:	05bd                	addi	a1,a1,15
ffffffffc02019f8:	8191                	srli	a1,a1,0x4
ffffffffc02019fa:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019fc:	100027f3          	csrr	a5,sstatus
ffffffffc0201a00:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201a02:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a04:	dfd9                	beqz	a5,ffffffffc02019a2 <slob_free+0xe>
{
ffffffffc0201a06:	1101                	addi	sp,sp,-32
ffffffffc0201a08:	e42a                	sd	a0,8(sp)
ffffffffc0201a0a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201a0c:	c47fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a10:	000bc797          	auipc	a5,0xbc
ffffffffc0201a14:	4a078793          	addi	a5,a5,1184 # ffffffffc02bdeb0 <slobfree>
ffffffffc0201a18:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0201a1a:	6522                	ld	a0,8(sp)
ffffffffc0201a1c:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a1e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a20:	00a7fa63          	bleu	a0,a5,ffffffffc0201a34 <slob_free+0xa0>
ffffffffc0201a24:	00e56c63          	bltu	a0,a4,ffffffffc0201a3c <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a28:	00e7fa63          	bleu	a4,a5,ffffffffc0201a3c <slob_free+0xa8>
    return 0;
ffffffffc0201a2c:	87ba                	mv	a5,a4
ffffffffc0201a2e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a30:	fea7eae3          	bltu	a5,a0,ffffffffc0201a24 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a34:	fee7ece3          	bltu	a5,a4,ffffffffc0201a2c <slob_free+0x98>
ffffffffc0201a38:	fee57ae3          	bleu	a4,a0,ffffffffc0201a2c <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0201a3c:	4110                	lw	a2,0(a0)
ffffffffc0201a3e:	00461693          	slli	a3,a2,0x4
ffffffffc0201a42:	96aa                	add	a3,a3,a0
ffffffffc0201a44:	04d70763          	beq	a4,a3,ffffffffc0201a92 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0201a48:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a4a:	4394                	lw	a3,0(a5)
ffffffffc0201a4c:	00469713          	slli	a4,a3,0x4
ffffffffc0201a50:	973e                	add	a4,a4,a5
ffffffffc0201a52:	04e50663          	beq	a0,a4,ffffffffc0201a9e <slob_free+0x10a>
		cur->next = b;
ffffffffc0201a56:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0201a58:	000bc717          	auipc	a4,0xbc
ffffffffc0201a5c:	44f73c23          	sd	a5,1112(a4) # ffffffffc02bdeb0 <slobfree>
    if (flag) {
ffffffffc0201a60:	e58d                	bnez	a1,ffffffffc0201a8a <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201a62:	60e2                	ld	ra,24(sp)
ffffffffc0201a64:	6105                	addi	sp,sp,32
ffffffffc0201a66:	8082                	ret
		b->units += cur->next->units;
ffffffffc0201a68:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a6a:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201a6c:	9e35                	addw	a2,a2,a3
ffffffffc0201a6e:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0201a70:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201a72:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a74:	00469713          	slli	a4,a3,0x4
ffffffffc0201a78:	973e                	add	a4,a4,a5
ffffffffc0201a7a:	f6e515e3          	bne	a0,a4,ffffffffc02019e4 <slob_free+0x50>
		cur->units += b->units;
ffffffffc0201a7e:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201a80:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201a82:	9eb9                	addw	a3,a3,a4
ffffffffc0201a84:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201a86:	e790                	sd	a2,8(a5)
ffffffffc0201a88:	bfb9                	j	ffffffffc02019e6 <slob_free+0x52>
}
ffffffffc0201a8a:	60e2                	ld	ra,24(sp)
ffffffffc0201a8c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201a8e:	bbffe06f          	j	ffffffffc020064c <intr_enable>
		b->units += cur->next->units;
ffffffffc0201a92:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a94:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201a96:	9e35                	addw	a2,a2,a3
ffffffffc0201a98:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0201a9a:	e518                	sd	a4,8(a0)
ffffffffc0201a9c:	b77d                	j	ffffffffc0201a4a <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0201a9e:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201aa0:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201aa2:	9eb9                	addw	a3,a3,a4
ffffffffc0201aa4:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201aa6:	e790                	sd	a2,8(a5)
ffffffffc0201aa8:	bf45                	j	ffffffffc0201a58 <slob_free+0xc4>

ffffffffc0201aaa <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201aaa:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201aac:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201aae:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201ab2:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201ab4:	38e000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
  if(!page)
ffffffffc0201ab8:	c139                	beqz	a0,ffffffffc0201afe <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc0201aba:	000c8797          	auipc	a5,0xc8
ffffffffc0201abe:	8ce78793          	addi	a5,a5,-1842 # ffffffffc02c9388 <pages>
ffffffffc0201ac2:	6394                	ld	a3,0(a5)
ffffffffc0201ac4:	0000a797          	auipc	a5,0xa
ffffffffc0201ac8:	4b478793          	addi	a5,a5,1204 # ffffffffc020bf78 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201acc:	000c8717          	auipc	a4,0xc8
ffffffffc0201ad0:	83c70713          	addi	a4,a4,-1988 # ffffffffc02c9308 <npage>
    return page - pages + nbase;
ffffffffc0201ad4:	40d506b3          	sub	a3,a0,a3
ffffffffc0201ad8:	6388                	ld	a0,0(a5)
ffffffffc0201ada:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201adc:	57fd                	li	a5,-1
ffffffffc0201ade:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0201ae0:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0201ae2:	83b1                	srli	a5,a5,0xc
ffffffffc0201ae4:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ae6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201ae8:	00e7ff63          	bleu	a4,a5,ffffffffc0201b06 <__slob_get_free_pages.isra.0+0x5c>
ffffffffc0201aec:	000c8797          	auipc	a5,0xc8
ffffffffc0201af0:	88c78793          	addi	a5,a5,-1908 # ffffffffc02c9378 <va_pa_offset>
ffffffffc0201af4:	6388                	ld	a0,0(a5)
}
ffffffffc0201af6:	60a2                	ld	ra,8(sp)
ffffffffc0201af8:	9536                	add	a0,a0,a3
ffffffffc0201afa:	0141                	addi	sp,sp,16
ffffffffc0201afc:	8082                	ret
ffffffffc0201afe:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc0201b00:	4501                	li	a0,0
}
ffffffffc0201b02:	0141                	addi	sp,sp,16
ffffffffc0201b04:	8082                	ret
ffffffffc0201b06:	00008617          	auipc	a2,0x8
ffffffffc0201b0a:	3ba60613          	addi	a2,a2,954 # ffffffffc0209ec0 <default_pmm_manager+0x50>
ffffffffc0201b0e:	06900593          	li	a1,105
ffffffffc0201b12:	00008517          	auipc	a0,0x8
ffffffffc0201b16:	3d650513          	addi	a0,a0,982 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc0201b1a:	96ffe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201b1e <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201b1e:	7179                	addi	sp,sp,-48
ffffffffc0201b20:	f406                	sd	ra,40(sp)
ffffffffc0201b22:	f022                	sd	s0,32(sp)
ffffffffc0201b24:	ec26                	sd	s1,24(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201b26:	01050713          	addi	a4,a0,16
ffffffffc0201b2a:	6785                	lui	a5,0x1
ffffffffc0201b2c:	0cf77b63          	bleu	a5,a4,ffffffffc0201c02 <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201b30:	00f50413          	addi	s0,a0,15
ffffffffc0201b34:	8011                	srli	s0,s0,0x4
ffffffffc0201b36:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b38:	10002673          	csrr	a2,sstatus
ffffffffc0201b3c:	8a09                	andi	a2,a2,2
ffffffffc0201b3e:	ea5d                	bnez	a2,ffffffffc0201bf4 <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc0201b40:	000bc497          	auipc	s1,0xbc
ffffffffc0201b44:	37048493          	addi	s1,s1,880 # ffffffffc02bdeb0 <slobfree>
ffffffffc0201b48:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b4a:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b4c:	4398                	lw	a4,0(a5)
ffffffffc0201b4e:	0a875763          	ble	s0,a4,ffffffffc0201bfc <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc0201b52:	00f68a63          	beq	a3,a5,ffffffffc0201b66 <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b56:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b58:	4118                	lw	a4,0(a0)
ffffffffc0201b5a:	02875763          	ble	s0,a4,ffffffffc0201b88 <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc0201b5e:	6094                	ld	a3,0(s1)
ffffffffc0201b60:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc0201b62:	fef69ae3          	bne	a3,a5,ffffffffc0201b56 <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc0201b66:	ea39                	bnez	a2,ffffffffc0201bbc <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201b68:	4501                	li	a0,0
ffffffffc0201b6a:	f41ff0ef          	jal	ra,ffffffffc0201aaa <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201b6e:	cd29                	beqz	a0,ffffffffc0201bc8 <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201b70:	6585                	lui	a1,0x1
ffffffffc0201b72:	e23ff0ef          	jal	ra,ffffffffc0201994 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b76:	10002673          	csrr	a2,sstatus
ffffffffc0201b7a:	8a09                	andi	a2,a2,2
ffffffffc0201b7c:	ea1d                	bnez	a2,ffffffffc0201bb2 <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc0201b7e:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b80:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b82:	4118                	lw	a4,0(a0)
ffffffffc0201b84:	fc874de3          	blt	a4,s0,ffffffffc0201b5e <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc0201b88:	04e40663          	beq	s0,a4,ffffffffc0201bd4 <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc0201b8c:	00441693          	slli	a3,s0,0x4
ffffffffc0201b90:	96aa                	add	a3,a3,a0
ffffffffc0201b92:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201b94:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc0201b96:	9f01                	subw	a4,a4,s0
ffffffffc0201b98:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201b9a:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201b9c:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc0201b9e:	000bc717          	auipc	a4,0xbc
ffffffffc0201ba2:	30f73923          	sd	a5,786(a4) # ffffffffc02bdeb0 <slobfree>
    if (flag) {
ffffffffc0201ba6:	ee15                	bnez	a2,ffffffffc0201be2 <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc0201ba8:	70a2                	ld	ra,40(sp)
ffffffffc0201baa:	7402                	ld	s0,32(sp)
ffffffffc0201bac:	64e2                	ld	s1,24(sp)
ffffffffc0201bae:	6145                	addi	sp,sp,48
ffffffffc0201bb0:	8082                	ret
        intr_disable();
ffffffffc0201bb2:	aa1fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201bb6:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0201bb8:	609c                	ld	a5,0(s1)
ffffffffc0201bba:	b7d9                	j	ffffffffc0201b80 <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc0201bbc:	a91fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201bc0:	4501                	li	a0,0
ffffffffc0201bc2:	ee9ff0ef          	jal	ra,ffffffffc0201aaa <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201bc6:	f54d                	bnez	a0,ffffffffc0201b70 <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc0201bc8:	70a2                	ld	ra,40(sp)
ffffffffc0201bca:	7402                	ld	s0,32(sp)
ffffffffc0201bcc:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc0201bce:	4501                	li	a0,0
}
ffffffffc0201bd0:	6145                	addi	sp,sp,48
ffffffffc0201bd2:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201bd4:	6518                	ld	a4,8(a0)
ffffffffc0201bd6:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc0201bd8:	000bc717          	auipc	a4,0xbc
ffffffffc0201bdc:	2cf73c23          	sd	a5,728(a4) # ffffffffc02bdeb0 <slobfree>
    if (flag) {
ffffffffc0201be0:	d661                	beqz	a2,ffffffffc0201ba8 <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc0201be2:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201be4:	a69fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
}
ffffffffc0201be8:	70a2                	ld	ra,40(sp)
ffffffffc0201bea:	7402                	ld	s0,32(sp)
ffffffffc0201bec:	6522                	ld	a0,8(sp)
ffffffffc0201bee:	64e2                	ld	s1,24(sp)
ffffffffc0201bf0:	6145                	addi	sp,sp,48
ffffffffc0201bf2:	8082                	ret
        intr_disable();
ffffffffc0201bf4:	a5ffe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201bf8:	4605                	li	a2,1
ffffffffc0201bfa:	b799                	j	ffffffffc0201b40 <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201bfc:	853e                	mv	a0,a5
ffffffffc0201bfe:	87b6                	mv	a5,a3
ffffffffc0201c00:	b761                	j	ffffffffc0201b88 <slob_alloc.isra.1.constprop.3+0x6a>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201c02:	00008697          	auipc	a3,0x8
ffffffffc0201c06:	35e68693          	addi	a3,a3,862 # ffffffffc0209f60 <default_pmm_manager+0xf0>
ffffffffc0201c0a:	00008617          	auipc	a2,0x8
ffffffffc0201c0e:	b1e60613          	addi	a2,a2,-1250 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0201c12:	06400593          	li	a1,100
ffffffffc0201c16:	00008517          	auipc	a0,0x8
ffffffffc0201c1a:	36a50513          	addi	a0,a0,874 # ffffffffc0209f80 <default_pmm_manager+0x110>
ffffffffc0201c1e:	86bfe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201c22 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201c22:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201c24:	00008517          	auipc	a0,0x8
ffffffffc0201c28:	37450513          	addi	a0,a0,884 # ffffffffc0209f98 <default_pmm_manager+0x128>
kmalloc_init(void) {
ffffffffc0201c2c:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201c2e:	d64fe0ef          	jal	ra,ffffffffc0200192 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201c32:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c34:	00008517          	auipc	a0,0x8
ffffffffc0201c38:	30c50513          	addi	a0,a0,780 # ffffffffc0209f40 <default_pmm_manager+0xd0>
}
ffffffffc0201c3c:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c3e:	d54fe06f          	j	ffffffffc0200192 <cprintf>

ffffffffc0201c42 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201c42:	4501                	li	a0,0
ffffffffc0201c44:	8082                	ret

ffffffffc0201c46 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201c46:	1101                	addi	sp,sp,-32
ffffffffc0201c48:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c4a:	6905                	lui	s2,0x1
{
ffffffffc0201c4c:	e822                	sd	s0,16(sp)
ffffffffc0201c4e:	ec06                	sd	ra,24(sp)
ffffffffc0201c50:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c52:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8919>
{
ffffffffc0201c56:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c58:	04a7fc63          	bleu	a0,a5,ffffffffc0201cb0 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201c5c:	4561                	li	a0,24
ffffffffc0201c5e:	ec1ff0ef          	jal	ra,ffffffffc0201b1e <slob_alloc.isra.1.constprop.3>
ffffffffc0201c62:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201c64:	cd21                	beqz	a0,ffffffffc0201cbc <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0201c66:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201c6a:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c6c:	00f95763          	ble	a5,s2,ffffffffc0201c7a <kmalloc+0x34>
ffffffffc0201c70:	6705                	lui	a4,0x1
ffffffffc0201c72:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201c74:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c76:	fef74ee3          	blt	a4,a5,ffffffffc0201c72 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201c7a:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201c7c:	e2fff0ef          	jal	ra,ffffffffc0201aaa <__slob_get_free_pages.isra.0>
ffffffffc0201c80:	e488                	sd	a0,8(s1)
ffffffffc0201c82:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201c84:	c935                	beqz	a0,ffffffffc0201cf8 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c86:	100027f3          	csrr	a5,sstatus
ffffffffc0201c8a:	8b89                	andi	a5,a5,2
ffffffffc0201c8c:	e3a1                	bnez	a5,ffffffffc0201ccc <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0201c8e:	000c7797          	auipc	a5,0xc7
ffffffffc0201c92:	66a78793          	addi	a5,a5,1642 # ffffffffc02c92f8 <bigblocks>
ffffffffc0201c96:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201c98:	000c7717          	auipc	a4,0xc7
ffffffffc0201c9c:	66973023          	sd	s1,1632(a4) # ffffffffc02c92f8 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201ca0:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201ca2:	8522                	mv	a0,s0
ffffffffc0201ca4:	60e2                	ld	ra,24(sp)
ffffffffc0201ca6:	6442                	ld	s0,16(sp)
ffffffffc0201ca8:	64a2                	ld	s1,8(sp)
ffffffffc0201caa:	6902                	ld	s2,0(sp)
ffffffffc0201cac:	6105                	addi	sp,sp,32
ffffffffc0201cae:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201cb0:	0541                	addi	a0,a0,16
ffffffffc0201cb2:	e6dff0ef          	jal	ra,ffffffffc0201b1e <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201cb6:	01050413          	addi	s0,a0,16
ffffffffc0201cba:	f565                	bnez	a0,ffffffffc0201ca2 <kmalloc+0x5c>
ffffffffc0201cbc:	4401                	li	s0,0
}
ffffffffc0201cbe:	8522                	mv	a0,s0
ffffffffc0201cc0:	60e2                	ld	ra,24(sp)
ffffffffc0201cc2:	6442                	ld	s0,16(sp)
ffffffffc0201cc4:	64a2                	ld	s1,8(sp)
ffffffffc0201cc6:	6902                	ld	s2,0(sp)
ffffffffc0201cc8:	6105                	addi	sp,sp,32
ffffffffc0201cca:	8082                	ret
        intr_disable();
ffffffffc0201ccc:	987fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201cd0:	000c7797          	auipc	a5,0xc7
ffffffffc0201cd4:	62878793          	addi	a5,a5,1576 # ffffffffc02c92f8 <bigblocks>
ffffffffc0201cd8:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201cda:	000c7717          	auipc	a4,0xc7
ffffffffc0201cde:	60973f23          	sd	s1,1566(a4) # ffffffffc02c92f8 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201ce2:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201ce4:	969fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201ce8:	6480                	ld	s0,8(s1)
}
ffffffffc0201cea:	60e2                	ld	ra,24(sp)
ffffffffc0201cec:	64a2                	ld	s1,8(sp)
ffffffffc0201cee:	8522                	mv	a0,s0
ffffffffc0201cf0:	6442                	ld	s0,16(sp)
ffffffffc0201cf2:	6902                	ld	s2,0(sp)
ffffffffc0201cf4:	6105                	addi	sp,sp,32
ffffffffc0201cf6:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201cf8:	45e1                	li	a1,24
ffffffffc0201cfa:	8526                	mv	a0,s1
ffffffffc0201cfc:	c99ff0ef          	jal	ra,ffffffffc0201994 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201d00:	b74d                	j	ffffffffc0201ca2 <kmalloc+0x5c>

ffffffffc0201d02 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201d02:	c175                	beqz	a0,ffffffffc0201de6 <kfree+0xe4>
{
ffffffffc0201d04:	1101                	addi	sp,sp,-32
ffffffffc0201d06:	e426                	sd	s1,8(sp)
ffffffffc0201d08:	ec06                	sd	ra,24(sp)
ffffffffc0201d0a:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201d0c:	03451793          	slli	a5,a0,0x34
ffffffffc0201d10:	84aa                	mv	s1,a0
ffffffffc0201d12:	eb8d                	bnez	a5,ffffffffc0201d44 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d14:	100027f3          	csrr	a5,sstatus
ffffffffc0201d18:	8b89                	andi	a5,a5,2
ffffffffc0201d1a:	efc9                	bnez	a5,ffffffffc0201db4 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d1c:	000c7797          	auipc	a5,0xc7
ffffffffc0201d20:	5dc78793          	addi	a5,a5,1500 # ffffffffc02c92f8 <bigblocks>
ffffffffc0201d24:	6394                	ld	a3,0(a5)
ffffffffc0201d26:	ce99                	beqz	a3,ffffffffc0201d44 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201d28:	669c                	ld	a5,8(a3)
ffffffffc0201d2a:	6a80                	ld	s0,16(a3)
ffffffffc0201d2c:	0af50e63          	beq	a0,a5,ffffffffc0201de8 <kfree+0xe6>
    return 0;
ffffffffc0201d30:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d32:	c801                	beqz	s0,ffffffffc0201d42 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0201d34:	6418                	ld	a4,8(s0)
ffffffffc0201d36:	681c                	ld	a5,16(s0)
ffffffffc0201d38:	00970f63          	beq	a4,s1,ffffffffc0201d56 <kfree+0x54>
ffffffffc0201d3c:	86a2                	mv	a3,s0
ffffffffc0201d3e:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d40:	f875                	bnez	s0,ffffffffc0201d34 <kfree+0x32>
    if (flag) {
ffffffffc0201d42:	e659                	bnez	a2,ffffffffc0201dd0 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201d44:	6442                	ld	s0,16(sp)
ffffffffc0201d46:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d48:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201d4c:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d4e:	4581                	li	a1,0
}
ffffffffc0201d50:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d52:	c43ff06f          	j	ffffffffc0201994 <slob_free>
				*last = bb->next;
ffffffffc0201d56:	ea9c                	sd	a5,16(a3)
ffffffffc0201d58:	e641                	bnez	a2,ffffffffc0201de0 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0201d5a:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201d5e:	4018                	lw	a4,0(s0)
ffffffffc0201d60:	08f4ea63          	bltu	s1,a5,ffffffffc0201df4 <kfree+0xf2>
ffffffffc0201d64:	000c7797          	auipc	a5,0xc7
ffffffffc0201d68:	61478793          	addi	a5,a5,1556 # ffffffffc02c9378 <va_pa_offset>
ffffffffc0201d6c:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201d6e:	000c7797          	auipc	a5,0xc7
ffffffffc0201d72:	59a78793          	addi	a5,a5,1434 # ffffffffc02c9308 <npage>
ffffffffc0201d76:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201d78:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201d7a:	80b1                	srli	s1,s1,0xc
ffffffffc0201d7c:	08f4f963          	bleu	a5,s1,ffffffffc0201e0e <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d80:	0000a797          	auipc	a5,0xa
ffffffffc0201d84:	1f878793          	addi	a5,a5,504 # ffffffffc020bf78 <nbase>
ffffffffc0201d88:	639c                	ld	a5,0(a5)
ffffffffc0201d8a:	000c7697          	auipc	a3,0xc7
ffffffffc0201d8e:	5fe68693          	addi	a3,a3,1534 # ffffffffc02c9388 <pages>
ffffffffc0201d92:	6288                	ld	a0,0(a3)
ffffffffc0201d94:	8c9d                	sub	s1,s1,a5
ffffffffc0201d96:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201d98:	4585                	li	a1,1
ffffffffc0201d9a:	9526                	add	a0,a0,s1
ffffffffc0201d9c:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201da0:	12a000ef          	jal	ra,ffffffffc0201eca <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201da4:	8522                	mv	a0,s0
}
ffffffffc0201da6:	6442                	ld	s0,16(sp)
ffffffffc0201da8:	60e2                	ld	ra,24(sp)
ffffffffc0201daa:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201dac:	45e1                	li	a1,24
}
ffffffffc0201dae:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201db0:	be5ff06f          	j	ffffffffc0201994 <slob_free>
        intr_disable();
ffffffffc0201db4:	89ffe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201db8:	000c7797          	auipc	a5,0xc7
ffffffffc0201dbc:	54078793          	addi	a5,a5,1344 # ffffffffc02c92f8 <bigblocks>
ffffffffc0201dc0:	6394                	ld	a3,0(a5)
ffffffffc0201dc2:	c699                	beqz	a3,ffffffffc0201dd0 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0201dc4:	669c                	ld	a5,8(a3)
ffffffffc0201dc6:	6a80                	ld	s0,16(a3)
ffffffffc0201dc8:	00f48763          	beq	s1,a5,ffffffffc0201dd6 <kfree+0xd4>
        return 1;
ffffffffc0201dcc:	4605                	li	a2,1
ffffffffc0201dce:	b795                	j	ffffffffc0201d32 <kfree+0x30>
        intr_enable();
ffffffffc0201dd0:	87dfe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201dd4:	bf85                	j	ffffffffc0201d44 <kfree+0x42>
				*last = bb->next;
ffffffffc0201dd6:	000c7797          	auipc	a5,0xc7
ffffffffc0201dda:	5287b123          	sd	s0,1314(a5) # ffffffffc02c92f8 <bigblocks>
ffffffffc0201dde:	8436                	mv	s0,a3
ffffffffc0201de0:	86dfe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201de4:	bf9d                	j	ffffffffc0201d5a <kfree+0x58>
ffffffffc0201de6:	8082                	ret
ffffffffc0201de8:	000c7797          	auipc	a5,0xc7
ffffffffc0201dec:	5087b823          	sd	s0,1296(a5) # ffffffffc02c92f8 <bigblocks>
ffffffffc0201df0:	8436                	mv	s0,a3
ffffffffc0201df2:	b7a5                	j	ffffffffc0201d5a <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0201df4:	86a6                	mv	a3,s1
ffffffffc0201df6:	00008617          	auipc	a2,0x8
ffffffffc0201dfa:	10260613          	addi	a2,a2,258 # ffffffffc0209ef8 <default_pmm_manager+0x88>
ffffffffc0201dfe:	06e00593          	li	a1,110
ffffffffc0201e02:	00008517          	auipc	a0,0x8
ffffffffc0201e06:	0e650513          	addi	a0,a0,230 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc0201e0a:	e7efe0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201e0e:	00008617          	auipc	a2,0x8
ffffffffc0201e12:	11260613          	addi	a2,a2,274 # ffffffffc0209f20 <default_pmm_manager+0xb0>
ffffffffc0201e16:	06200593          	li	a1,98
ffffffffc0201e1a:	00008517          	auipc	a0,0x8
ffffffffc0201e1e:	0ce50513          	addi	a0,a0,206 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc0201e22:	e66fe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201e26 <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0201e26:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201e28:	00008617          	auipc	a2,0x8
ffffffffc0201e2c:	0f860613          	addi	a2,a2,248 # ffffffffc0209f20 <default_pmm_manager+0xb0>
ffffffffc0201e30:	06200593          	li	a1,98
ffffffffc0201e34:	00008517          	auipc	a0,0x8
ffffffffc0201e38:	0b450513          	addi	a0,a0,180 # ffffffffc0209ee8 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201e3c:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201e3e:	e4afe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201e42 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201e42:	715d                	addi	sp,sp,-80
ffffffffc0201e44:	e0a2                	sd	s0,64(sp)
ffffffffc0201e46:	fc26                	sd	s1,56(sp)
ffffffffc0201e48:	f84a                	sd	s2,48(sp)
ffffffffc0201e4a:	f44e                	sd	s3,40(sp)
ffffffffc0201e4c:	f052                	sd	s4,32(sp)
ffffffffc0201e4e:	ec56                	sd	s5,24(sp)
ffffffffc0201e50:	e486                	sd	ra,72(sp)
ffffffffc0201e52:	842a                	mv	s0,a0
ffffffffc0201e54:	000c7497          	auipc	s1,0xc7
ffffffffc0201e58:	51c48493          	addi	s1,s1,1308 # ffffffffc02c9370 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e5c:	4985                	li	s3,1
ffffffffc0201e5e:	000c7a17          	auipc	s4,0xc7
ffffffffc0201e62:	4baa0a13          	addi	s4,s4,1210 # ffffffffc02c9318 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e66:	0005091b          	sext.w	s2,a0
ffffffffc0201e6a:	000c7a97          	auipc	s5,0xc7
ffffffffc0201e6e:	5fea8a93          	addi	s5,s5,1534 # ffffffffc02c9468 <check_mm_struct>
ffffffffc0201e72:	a00d                	j	ffffffffc0201e94 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201e74:	609c                	ld	a5,0(s1)
ffffffffc0201e76:	6f9c                	ld	a5,24(a5)
ffffffffc0201e78:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e7a:	4601                	li	a2,0
ffffffffc0201e7c:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e7e:	ed0d                	bnez	a0,ffffffffc0201eb8 <alloc_pages+0x76>
ffffffffc0201e80:	0289ec63          	bltu	s3,s0,ffffffffc0201eb8 <alloc_pages+0x76>
ffffffffc0201e84:	000a2783          	lw	a5,0(s4)
ffffffffc0201e88:	2781                	sext.w	a5,a5
ffffffffc0201e8a:	c79d                	beqz	a5,ffffffffc0201eb8 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e8c:	000ab503          	ld	a0,0(s5)
ffffffffc0201e90:	48d010ef          	jal	ra,ffffffffc0203b1c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e94:	100027f3          	csrr	a5,sstatus
ffffffffc0201e98:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201e9a:	8522                	mv	a0,s0
ffffffffc0201e9c:	dfe1                	beqz	a5,ffffffffc0201e74 <alloc_pages+0x32>
        intr_disable();
ffffffffc0201e9e:	fb4fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201ea2:	609c                	ld	a5,0(s1)
ffffffffc0201ea4:	8522                	mv	a0,s0
ffffffffc0201ea6:	6f9c                	ld	a5,24(a5)
ffffffffc0201ea8:	9782                	jalr	a5
ffffffffc0201eaa:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201eac:	fa0fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201eb0:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0201eb2:	4601                	li	a2,0
ffffffffc0201eb4:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201eb6:	d569                	beqz	a0,ffffffffc0201e80 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201eb8:	60a6                	ld	ra,72(sp)
ffffffffc0201eba:	6406                	ld	s0,64(sp)
ffffffffc0201ebc:	74e2                	ld	s1,56(sp)
ffffffffc0201ebe:	7942                	ld	s2,48(sp)
ffffffffc0201ec0:	79a2                	ld	s3,40(sp)
ffffffffc0201ec2:	7a02                	ld	s4,32(sp)
ffffffffc0201ec4:	6ae2                	ld	s5,24(sp)
ffffffffc0201ec6:	6161                	addi	sp,sp,80
ffffffffc0201ec8:	8082                	ret

ffffffffc0201eca <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201eca:	100027f3          	csrr	a5,sstatus
ffffffffc0201ece:	8b89                	andi	a5,a5,2
ffffffffc0201ed0:	eb89                	bnez	a5,ffffffffc0201ee2 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201ed2:	000c7797          	auipc	a5,0xc7
ffffffffc0201ed6:	49e78793          	addi	a5,a5,1182 # ffffffffc02c9370 <pmm_manager>
ffffffffc0201eda:	639c                	ld	a5,0(a5)
ffffffffc0201edc:	0207b303          	ld	t1,32(a5)
ffffffffc0201ee0:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201ee2:	1101                	addi	sp,sp,-32
ffffffffc0201ee4:	ec06                	sd	ra,24(sp)
ffffffffc0201ee6:	e822                	sd	s0,16(sp)
ffffffffc0201ee8:	e426                	sd	s1,8(sp)
ffffffffc0201eea:	842a                	mv	s0,a0
ffffffffc0201eec:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201eee:	f64fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201ef2:	000c7797          	auipc	a5,0xc7
ffffffffc0201ef6:	47e78793          	addi	a5,a5,1150 # ffffffffc02c9370 <pmm_manager>
ffffffffc0201efa:	639c                	ld	a5,0(a5)
ffffffffc0201efc:	85a6                	mv	a1,s1
ffffffffc0201efe:	8522                	mv	a0,s0
ffffffffc0201f00:	739c                	ld	a5,32(a5)
ffffffffc0201f02:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201f04:	6442                	ld	s0,16(sp)
ffffffffc0201f06:	60e2                	ld	ra,24(sp)
ffffffffc0201f08:	64a2                	ld	s1,8(sp)
ffffffffc0201f0a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201f0c:	f40fe06f          	j	ffffffffc020064c <intr_enable>

ffffffffc0201f10 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f10:	100027f3          	csrr	a5,sstatus
ffffffffc0201f14:	8b89                	andi	a5,a5,2
ffffffffc0201f16:	eb89                	bnez	a5,ffffffffc0201f28 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f18:	000c7797          	auipc	a5,0xc7
ffffffffc0201f1c:	45878793          	addi	a5,a5,1112 # ffffffffc02c9370 <pmm_manager>
ffffffffc0201f20:	639c                	ld	a5,0(a5)
ffffffffc0201f22:	0287b303          	ld	t1,40(a5)
ffffffffc0201f26:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201f28:	1141                	addi	sp,sp,-16
ffffffffc0201f2a:	e406                	sd	ra,8(sp)
ffffffffc0201f2c:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201f2e:	f24fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f32:	000c7797          	auipc	a5,0xc7
ffffffffc0201f36:	43e78793          	addi	a5,a5,1086 # ffffffffc02c9370 <pmm_manager>
ffffffffc0201f3a:	639c                	ld	a5,0(a5)
ffffffffc0201f3c:	779c                	ld	a5,40(a5)
ffffffffc0201f3e:	9782                	jalr	a5
ffffffffc0201f40:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201f42:	f0afe0ef          	jal	ra,ffffffffc020064c <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201f46:	8522                	mv	a0,s0
ffffffffc0201f48:	60a2                	ld	ra,8(sp)
ffffffffc0201f4a:	6402                	ld	s0,0(sp)
ffffffffc0201f4c:	0141                	addi	sp,sp,16
ffffffffc0201f4e:	8082                	ret

ffffffffc0201f50 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f50:	7139                	addi	sp,sp,-64
ffffffffc0201f52:	f426                	sd	s1,40(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201f54:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201f58:	1ff4f493          	andi	s1,s1,511
ffffffffc0201f5c:	048e                	slli	s1,s1,0x3
ffffffffc0201f5e:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f60:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f62:	f04a                	sd	s2,32(sp)
ffffffffc0201f64:	ec4e                	sd	s3,24(sp)
ffffffffc0201f66:	e852                	sd	s4,16(sp)
ffffffffc0201f68:	fc06                	sd	ra,56(sp)
ffffffffc0201f6a:	f822                	sd	s0,48(sp)
ffffffffc0201f6c:	e456                	sd	s5,8(sp)
ffffffffc0201f6e:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f70:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f74:	892e                	mv	s2,a1
ffffffffc0201f76:	8a32                	mv	s4,a2
ffffffffc0201f78:	000c7997          	auipc	s3,0xc7
ffffffffc0201f7c:	39098993          	addi	s3,s3,912 # ffffffffc02c9308 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f80:	e7bd                	bnez	a5,ffffffffc0201fee <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201f82:	12060c63          	beqz	a2,ffffffffc02020ba <get_pte+0x16a>
ffffffffc0201f86:	4505                	li	a0,1
ffffffffc0201f88:	ebbff0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0201f8c:	842a                	mv	s0,a0
ffffffffc0201f8e:	12050663          	beqz	a0,ffffffffc02020ba <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201f92:	000c7b17          	auipc	s6,0xc7
ffffffffc0201f96:	3f6b0b13          	addi	s6,s6,1014 # ffffffffc02c9388 <pages>
ffffffffc0201f9a:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0201f9e:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201fa0:	000c7997          	auipc	s3,0xc7
ffffffffc0201fa4:	36898993          	addi	s3,s3,872 # ffffffffc02c9308 <npage>
    return page - pages + nbase;
ffffffffc0201fa8:	40a40533          	sub	a0,s0,a0
ffffffffc0201fac:	00080ab7          	lui	s5,0x80
ffffffffc0201fb0:	8519                	srai	a0,a0,0x6
ffffffffc0201fb2:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0201fb6:	c01c                	sw	a5,0(s0)
ffffffffc0201fb8:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201fba:	9556                	add	a0,a0,s5
ffffffffc0201fbc:	83b1                	srli	a5,a5,0xc
ffffffffc0201fbe:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fc0:	0532                	slli	a0,a0,0xc
ffffffffc0201fc2:	14e7f363          	bleu	a4,a5,ffffffffc0202108 <get_pte+0x1b8>
ffffffffc0201fc6:	000c7797          	auipc	a5,0xc7
ffffffffc0201fca:	3b278793          	addi	a5,a5,946 # ffffffffc02c9378 <va_pa_offset>
ffffffffc0201fce:	639c                	ld	a5,0(a5)
ffffffffc0201fd0:	6605                	lui	a2,0x1
ffffffffc0201fd2:	4581                	li	a1,0
ffffffffc0201fd4:	953e                	add	a0,a0,a5
ffffffffc0201fd6:	136070ef          	jal	ra,ffffffffc020910c <memset>
    return page - pages + nbase;
ffffffffc0201fda:	000b3683          	ld	a3,0(s6)
ffffffffc0201fde:	40d406b3          	sub	a3,s0,a3
ffffffffc0201fe2:	8699                	srai	a3,a3,0x6
ffffffffc0201fe4:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201fe6:	06aa                	slli	a3,a3,0xa
ffffffffc0201fe8:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201fec:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201fee:	77fd                	lui	a5,0xfffff
ffffffffc0201ff0:	068a                	slli	a3,a3,0x2
ffffffffc0201ff2:	0009b703          	ld	a4,0(s3)
ffffffffc0201ff6:	8efd                	and	a3,a3,a5
ffffffffc0201ff8:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201ffc:	0ce7f163          	bleu	a4,a5,ffffffffc02020be <get_pte+0x16e>
ffffffffc0202000:	000c7a97          	auipc	s5,0xc7
ffffffffc0202004:	378a8a93          	addi	s5,s5,888 # ffffffffc02c9378 <va_pa_offset>
ffffffffc0202008:	000ab403          	ld	s0,0(s5)
ffffffffc020200c:	01595793          	srli	a5,s2,0x15
ffffffffc0202010:	1ff7f793          	andi	a5,a5,511
ffffffffc0202014:	96a2                	add	a3,a3,s0
ffffffffc0202016:	00379413          	slli	s0,a5,0x3
ffffffffc020201a:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc020201c:	6014                	ld	a3,0(s0)
ffffffffc020201e:	0016f793          	andi	a5,a3,1
ffffffffc0202022:	e3ad                	bnez	a5,ffffffffc0202084 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202024:	080a0b63          	beqz	s4,ffffffffc02020ba <get_pte+0x16a>
ffffffffc0202028:	4505                	li	a0,1
ffffffffc020202a:	e19ff0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020202e:	84aa                	mv	s1,a0
ffffffffc0202030:	c549                	beqz	a0,ffffffffc02020ba <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0202032:	000c7b17          	auipc	s6,0xc7
ffffffffc0202036:	356b0b13          	addi	s6,s6,854 # ffffffffc02c9388 <pages>
ffffffffc020203a:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc020203e:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc0202040:	00080a37          	lui	s4,0x80
ffffffffc0202044:	40a48533          	sub	a0,s1,a0
ffffffffc0202048:	8519                	srai	a0,a0,0x6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020204a:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc020204e:	c09c                	sw	a5,0(s1)
ffffffffc0202050:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0202052:	9552                	add	a0,a0,s4
ffffffffc0202054:	83b1                	srli	a5,a5,0xc
ffffffffc0202056:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202058:	0532                	slli	a0,a0,0xc
ffffffffc020205a:	08e7fa63          	bleu	a4,a5,ffffffffc02020ee <get_pte+0x19e>
ffffffffc020205e:	000ab783          	ld	a5,0(s5)
ffffffffc0202062:	6605                	lui	a2,0x1
ffffffffc0202064:	4581                	li	a1,0
ffffffffc0202066:	953e                	add	a0,a0,a5
ffffffffc0202068:	0a4070ef          	jal	ra,ffffffffc020910c <memset>
    return page - pages + nbase;
ffffffffc020206c:	000b3683          	ld	a3,0(s6)
ffffffffc0202070:	40d486b3          	sub	a3,s1,a3
ffffffffc0202074:	8699                	srai	a3,a3,0x6
ffffffffc0202076:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202078:	06aa                	slli	a3,a3,0xa
ffffffffc020207a:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020207e:	e014                	sd	a3,0(s0)
ffffffffc0202080:	0009b703          	ld	a4,0(s3)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202084:	068a                	slli	a3,a3,0x2
ffffffffc0202086:	757d                	lui	a0,0xfffff
ffffffffc0202088:	8ee9                	and	a3,a3,a0
ffffffffc020208a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020208e:	04e7f463          	bleu	a4,a5,ffffffffc02020d6 <get_pte+0x186>
ffffffffc0202092:	000ab503          	ld	a0,0(s5)
ffffffffc0202096:	00c95793          	srli	a5,s2,0xc
ffffffffc020209a:	1ff7f793          	andi	a5,a5,511
ffffffffc020209e:	96aa                	add	a3,a3,a0
ffffffffc02020a0:	00379513          	slli	a0,a5,0x3
ffffffffc02020a4:	9536                	add	a0,a0,a3
}
ffffffffc02020a6:	70e2                	ld	ra,56(sp)
ffffffffc02020a8:	7442                	ld	s0,48(sp)
ffffffffc02020aa:	74a2                	ld	s1,40(sp)
ffffffffc02020ac:	7902                	ld	s2,32(sp)
ffffffffc02020ae:	69e2                	ld	s3,24(sp)
ffffffffc02020b0:	6a42                	ld	s4,16(sp)
ffffffffc02020b2:	6aa2                	ld	s5,8(sp)
ffffffffc02020b4:	6b02                	ld	s6,0(sp)
ffffffffc02020b6:	6121                	addi	sp,sp,64
ffffffffc02020b8:	8082                	ret
            return NULL;
ffffffffc02020ba:	4501                	li	a0,0
ffffffffc02020bc:	b7ed                	j	ffffffffc02020a6 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02020be:	00008617          	auipc	a2,0x8
ffffffffc02020c2:	e0260613          	addi	a2,a2,-510 # ffffffffc0209ec0 <default_pmm_manager+0x50>
ffffffffc02020c6:	0fd00593          	li	a1,253
ffffffffc02020ca:	00008517          	auipc	a0,0x8
ffffffffc02020ce:	f1650513          	addi	a0,a0,-234 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc02020d2:	bb6fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02020d6:	00008617          	auipc	a2,0x8
ffffffffc02020da:	dea60613          	addi	a2,a2,-534 # ffffffffc0209ec0 <default_pmm_manager+0x50>
ffffffffc02020de:	10800593          	li	a1,264
ffffffffc02020e2:	00008517          	auipc	a0,0x8
ffffffffc02020e6:	efe50513          	addi	a0,a0,-258 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc02020ea:	b9efe0ef          	jal	ra,ffffffffc0200488 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020ee:	86aa                	mv	a3,a0
ffffffffc02020f0:	00008617          	auipc	a2,0x8
ffffffffc02020f4:	dd060613          	addi	a2,a2,-560 # ffffffffc0209ec0 <default_pmm_manager+0x50>
ffffffffc02020f8:	10500593          	li	a1,261
ffffffffc02020fc:	00008517          	auipc	a0,0x8
ffffffffc0202100:	ee450513          	addi	a0,a0,-284 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202104:	b84fe0ef          	jal	ra,ffffffffc0200488 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202108:	86aa                	mv	a3,a0
ffffffffc020210a:	00008617          	auipc	a2,0x8
ffffffffc020210e:	db660613          	addi	a2,a2,-586 # ffffffffc0209ec0 <default_pmm_manager+0x50>
ffffffffc0202112:	0f900593          	li	a1,249
ffffffffc0202116:	00008517          	auipc	a0,0x8
ffffffffc020211a:	eca50513          	addi	a0,a0,-310 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc020211e:	b6afe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0202122 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202122:	1141                	addi	sp,sp,-16
ffffffffc0202124:	e022                	sd	s0,0(sp)
ffffffffc0202126:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202128:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020212a:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020212c:	e25ff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0202130:	c011                	beqz	s0,ffffffffc0202134 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0202132:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202134:	c129                	beqz	a0,ffffffffc0202176 <get_page+0x54>
ffffffffc0202136:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202138:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020213a:	0017f713          	andi	a4,a5,1
ffffffffc020213e:	e709                	bnez	a4,ffffffffc0202148 <get_page+0x26>
}
ffffffffc0202140:	60a2                	ld	ra,8(sp)
ffffffffc0202142:	6402                	ld	s0,0(sp)
ffffffffc0202144:	0141                	addi	sp,sp,16
ffffffffc0202146:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202148:	000c7717          	auipc	a4,0xc7
ffffffffc020214c:	1c070713          	addi	a4,a4,448 # ffffffffc02c9308 <npage>
ffffffffc0202150:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202152:	078a                	slli	a5,a5,0x2
ffffffffc0202154:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202156:	02e7f563          	bleu	a4,a5,ffffffffc0202180 <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc020215a:	000c7717          	auipc	a4,0xc7
ffffffffc020215e:	22e70713          	addi	a4,a4,558 # ffffffffc02c9388 <pages>
ffffffffc0202162:	6308                	ld	a0,0(a4)
ffffffffc0202164:	60a2                	ld	ra,8(sp)
ffffffffc0202166:	6402                	ld	s0,0(sp)
ffffffffc0202168:	fff80737          	lui	a4,0xfff80
ffffffffc020216c:	97ba                	add	a5,a5,a4
ffffffffc020216e:	079a                	slli	a5,a5,0x6
ffffffffc0202170:	953e                	add	a0,a0,a5
ffffffffc0202172:	0141                	addi	sp,sp,16
ffffffffc0202174:	8082                	ret
ffffffffc0202176:	60a2                	ld	ra,8(sp)
ffffffffc0202178:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc020217a:	4501                	li	a0,0
}
ffffffffc020217c:	0141                	addi	sp,sp,16
ffffffffc020217e:	8082                	ret
ffffffffc0202180:	ca7ff0ef          	jal	ra,ffffffffc0201e26 <pa2page.part.4>

ffffffffc0202184 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202184:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202186:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020218a:	ec86                	sd	ra,88(sp)
ffffffffc020218c:	e8a2                	sd	s0,80(sp)
ffffffffc020218e:	e4a6                	sd	s1,72(sp)
ffffffffc0202190:	e0ca                	sd	s2,64(sp)
ffffffffc0202192:	fc4e                	sd	s3,56(sp)
ffffffffc0202194:	f852                	sd	s4,48(sp)
ffffffffc0202196:	f456                	sd	s5,40(sp)
ffffffffc0202198:	f05a                	sd	s6,32(sp)
ffffffffc020219a:	ec5e                	sd	s7,24(sp)
ffffffffc020219c:	e862                	sd	s8,16(sp)
ffffffffc020219e:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02021a0:	03479713          	slli	a4,a5,0x34
ffffffffc02021a4:	eb71                	bnez	a4,ffffffffc0202278 <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc02021a6:	002007b7          	lui	a5,0x200
ffffffffc02021aa:	842e                	mv	s0,a1
ffffffffc02021ac:	0af5e663          	bltu	a1,a5,ffffffffc0202258 <unmap_range+0xd4>
ffffffffc02021b0:	8932                	mv	s2,a2
ffffffffc02021b2:	0ac5f363          	bleu	a2,a1,ffffffffc0202258 <unmap_range+0xd4>
ffffffffc02021b6:	4785                	li	a5,1
ffffffffc02021b8:	07fe                	slli	a5,a5,0x1f
ffffffffc02021ba:	08c7ef63          	bltu	a5,a2,ffffffffc0202258 <unmap_range+0xd4>
ffffffffc02021be:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02021c0:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02021c2:	000c7c97          	auipc	s9,0xc7
ffffffffc02021c6:	146c8c93          	addi	s9,s9,326 # ffffffffc02c9308 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02021ca:	000c7c17          	auipc	s8,0xc7
ffffffffc02021ce:	1bec0c13          	addi	s8,s8,446 # ffffffffc02c9388 <pages>
ffffffffc02021d2:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02021d6:	00200b37          	lui	s6,0x200
ffffffffc02021da:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02021de:	4601                	li	a2,0
ffffffffc02021e0:	85a2                	mv	a1,s0
ffffffffc02021e2:	854e                	mv	a0,s3
ffffffffc02021e4:	d6dff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc02021e8:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02021ea:	cd21                	beqz	a0,ffffffffc0202242 <unmap_range+0xbe>
        if (*ptep != 0) {
ffffffffc02021ec:	611c                	ld	a5,0(a0)
ffffffffc02021ee:	e38d                	bnez	a5,ffffffffc0202210 <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc02021f0:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02021f2:	ff2466e3          	bltu	s0,s2,ffffffffc02021de <unmap_range+0x5a>
}
ffffffffc02021f6:	60e6                	ld	ra,88(sp)
ffffffffc02021f8:	6446                	ld	s0,80(sp)
ffffffffc02021fa:	64a6                	ld	s1,72(sp)
ffffffffc02021fc:	6906                	ld	s2,64(sp)
ffffffffc02021fe:	79e2                	ld	s3,56(sp)
ffffffffc0202200:	7a42                	ld	s4,48(sp)
ffffffffc0202202:	7aa2                	ld	s5,40(sp)
ffffffffc0202204:	7b02                	ld	s6,32(sp)
ffffffffc0202206:	6be2                	ld	s7,24(sp)
ffffffffc0202208:	6c42                	ld	s8,16(sp)
ffffffffc020220a:	6ca2                	ld	s9,8(sp)
ffffffffc020220c:	6125                	addi	sp,sp,96
ffffffffc020220e:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202210:	0017f713          	andi	a4,a5,1
ffffffffc0202214:	df71                	beqz	a4,ffffffffc02021f0 <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc0202216:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020221a:	078a                	slli	a5,a5,0x2
ffffffffc020221c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020221e:	06e7fd63          	bleu	a4,a5,ffffffffc0202298 <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc0202222:	000c3503          	ld	a0,0(s8)
ffffffffc0202226:	97de                	add	a5,a5,s7
ffffffffc0202228:	079a                	slli	a5,a5,0x6
ffffffffc020222a:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020222c:	411c                	lw	a5,0(a0)
ffffffffc020222e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202232:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202234:	cf11                	beqz	a4,ffffffffc0202250 <unmap_range+0xcc>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202236:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020223a:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc020223e:	9452                	add	s0,s0,s4
ffffffffc0202240:	bf4d                	j	ffffffffc02021f2 <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202242:	945a                	add	s0,s0,s6
ffffffffc0202244:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0202248:	d45d                	beqz	s0,ffffffffc02021f6 <unmap_range+0x72>
ffffffffc020224a:	f9246ae3          	bltu	s0,s2,ffffffffc02021de <unmap_range+0x5a>
ffffffffc020224e:	b765                	j	ffffffffc02021f6 <unmap_range+0x72>
            free_page(page);
ffffffffc0202250:	4585                	li	a1,1
ffffffffc0202252:	c79ff0ef          	jal	ra,ffffffffc0201eca <free_pages>
ffffffffc0202256:	b7c5                	j	ffffffffc0202236 <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc0202258:	00008697          	auipc	a3,0x8
ffffffffc020225c:	33068693          	addi	a3,a3,816 # ffffffffc020a588 <default_pmm_manager+0x718>
ffffffffc0202260:	00007617          	auipc	a2,0x7
ffffffffc0202264:	4c860613          	addi	a2,a2,1224 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202268:	14000593          	li	a1,320
ffffffffc020226c:	00008517          	auipc	a0,0x8
ffffffffc0202270:	d7450513          	addi	a0,a0,-652 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202274:	a14fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202278:	00008697          	auipc	a3,0x8
ffffffffc020227c:	2e068693          	addi	a3,a3,736 # ffffffffc020a558 <default_pmm_manager+0x6e8>
ffffffffc0202280:	00007617          	auipc	a2,0x7
ffffffffc0202284:	4a860613          	addi	a2,a2,1192 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202288:	13f00593          	li	a1,319
ffffffffc020228c:	00008517          	auipc	a0,0x8
ffffffffc0202290:	d5450513          	addi	a0,a0,-684 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202294:	9f4fe0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0202298:	b8fff0ef          	jal	ra,ffffffffc0201e26 <pa2page.part.4>

ffffffffc020229c <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020229c:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020229e:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02022a2:	fc86                	sd	ra,120(sp)
ffffffffc02022a4:	f8a2                	sd	s0,112(sp)
ffffffffc02022a6:	f4a6                	sd	s1,104(sp)
ffffffffc02022a8:	f0ca                	sd	s2,96(sp)
ffffffffc02022aa:	ecce                	sd	s3,88(sp)
ffffffffc02022ac:	e8d2                	sd	s4,80(sp)
ffffffffc02022ae:	e4d6                	sd	s5,72(sp)
ffffffffc02022b0:	e0da                	sd	s6,64(sp)
ffffffffc02022b2:	fc5e                	sd	s7,56(sp)
ffffffffc02022b4:	f862                	sd	s8,48(sp)
ffffffffc02022b6:	f466                	sd	s9,40(sp)
ffffffffc02022b8:	f06a                	sd	s10,32(sp)
ffffffffc02022ba:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022bc:	03479713          	slli	a4,a5,0x34
ffffffffc02022c0:	1c071163          	bnez	a4,ffffffffc0202482 <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc02022c4:	002007b7          	lui	a5,0x200
ffffffffc02022c8:	20f5e563          	bltu	a1,a5,ffffffffc02024d2 <exit_range+0x236>
ffffffffc02022cc:	8b32                	mv	s6,a2
ffffffffc02022ce:	20c5f263          	bleu	a2,a1,ffffffffc02024d2 <exit_range+0x236>
ffffffffc02022d2:	4785                	li	a5,1
ffffffffc02022d4:	07fe                	slli	a5,a5,0x1f
ffffffffc02022d6:	1ec7ee63          	bltu	a5,a2,ffffffffc02024d2 <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02022da:	c00009b7          	lui	s3,0xc0000
ffffffffc02022de:	400007b7          	lui	a5,0x40000
ffffffffc02022e2:	0135f9b3          	and	s3,a1,s3
ffffffffc02022e6:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02022e8:	c0000337          	lui	t1,0xc0000
ffffffffc02022ec:	00698933          	add	s2,s3,t1
ffffffffc02022f0:	01e95913          	srli	s2,s2,0x1e
ffffffffc02022f4:	1ff97913          	andi	s2,s2,511
ffffffffc02022f8:	8e2a                	mv	t3,a0
ffffffffc02022fa:	090e                	slli	s2,s2,0x3
ffffffffc02022fc:	9972                	add	s2,s2,t3
ffffffffc02022fe:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202302:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc0202306:	5dfd                	li	s11,-1
        if (pde1&PTE_V){
ffffffffc0202308:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc020230c:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc020230e:	000c7d17          	auipc	s10,0xc7
ffffffffc0202312:	ffad0d13          	addi	s10,s10,-6 # ffffffffc02c9308 <npage>
    return KADDR(page2pa(page));
ffffffffc0202316:	00cddd93          	srli	s11,s11,0xc
ffffffffc020231a:	000c7717          	auipc	a4,0xc7
ffffffffc020231e:	05e70713          	addi	a4,a4,94 # ffffffffc02c9378 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc0202322:	000c7e97          	auipc	t4,0xc7
ffffffffc0202326:	066e8e93          	addi	t4,t4,102 # ffffffffc02c9388 <pages>
        if (pde1&PTE_V){
ffffffffc020232a:	e79d                	bnez	a5,ffffffffc0202358 <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc020232c:	12098963          	beqz	s3,ffffffffc020245e <exit_range+0x1c2>
ffffffffc0202330:	400007b7          	lui	a5,0x40000
ffffffffc0202334:	84ce                	mv	s1,s3
ffffffffc0202336:	97ce                	add	a5,a5,s3
ffffffffc0202338:	1369f363          	bleu	s6,s3,ffffffffc020245e <exit_range+0x1c2>
ffffffffc020233c:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc020233e:	00698933          	add	s2,s3,t1
ffffffffc0202342:	01e95913          	srli	s2,s2,0x1e
ffffffffc0202346:	1ff97913          	andi	s2,s2,511
ffffffffc020234a:	090e                	slli	s2,s2,0x3
ffffffffc020234c:	9972                	add	s2,s2,t3
ffffffffc020234e:	00093b83          	ld	s7,0(s2)
        if (pde1&PTE_V){
ffffffffc0202352:	001bf793          	andi	a5,s7,1
ffffffffc0202356:	dbf9                	beqz	a5,ffffffffc020232c <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0202358:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc020235c:	0b8a                	slli	s7,s7,0x2
ffffffffc020235e:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202362:	14fbfc63          	bleu	a5,s7,ffffffffc02024ba <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202366:	fff80ab7          	lui	s5,0xfff80
ffffffffc020236a:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc020236c:	000806b7          	lui	a3,0x80
ffffffffc0202370:	96d6                	add	a3,a3,s5
ffffffffc0202372:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc0202376:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc020237a:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc020237c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020237e:	12f67263          	bleu	a5,a2,ffffffffc02024a2 <exit_range+0x206>
ffffffffc0202382:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc0202386:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc0202388:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc020238c:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc020238e:	00080837          	lui	a6,0x80
ffffffffc0202392:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc0202394:	00200c37          	lui	s8,0x200
ffffffffc0202398:	a801                	j	ffffffffc02023a8 <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc020239a:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc020239c:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc020239e:	c0d9                	beqz	s1,ffffffffc0202424 <exit_range+0x188>
ffffffffc02023a0:	0934f263          	bleu	s3,s1,ffffffffc0202424 <exit_range+0x188>
ffffffffc02023a4:	0d64fc63          	bleu	s6,s1,ffffffffc020247c <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02023a8:	0154d413          	srli	s0,s1,0x15
ffffffffc02023ac:	1ff47413          	andi	s0,s0,511
ffffffffc02023b0:	040e                	slli	s0,s0,0x3
ffffffffc02023b2:	9452                	add	s0,s0,s4
ffffffffc02023b4:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc02023b6:	0017f693          	andi	a3,a5,1
ffffffffc02023ba:	d2e5                	beqz	a3,ffffffffc020239a <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc02023bc:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02023c0:	00279513          	slli	a0,a5,0x2
ffffffffc02023c4:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023c6:	0eb57a63          	bleu	a1,a0,ffffffffc02024ba <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc02023ca:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc02023cc:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc02023d0:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc02023d4:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02023d6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02023d8:	0cb7f563          	bleu	a1,a5,ffffffffc02024a2 <exit_range+0x206>
ffffffffc02023dc:	631c                	ld	a5,0(a4)
ffffffffc02023de:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02023e0:	015685b3          	add	a1,a3,s5
                        if (pt[i]&PTE_V){
ffffffffc02023e4:	629c                	ld	a5,0(a3)
ffffffffc02023e6:	8b85                	andi	a5,a5,1
ffffffffc02023e8:	fbd5                	bnez	a5,ffffffffc020239c <exit_range+0x100>
ffffffffc02023ea:	06a1                	addi	a3,a3,8
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02023ec:	fed59ce3          	bne	a1,a3,ffffffffc02023e4 <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc02023f0:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc02023f4:	4585                	li	a1,1
ffffffffc02023f6:	e072                	sd	t3,0(sp)
ffffffffc02023f8:	953e                	add	a0,a0,a5
ffffffffc02023fa:	ad1ff0ef          	jal	ra,ffffffffc0201eca <free_pages>
                d0start += PTSIZE;
ffffffffc02023fe:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202400:	00043023          	sd	zero,0(s0)
ffffffffc0202404:	000c7e97          	auipc	t4,0xc7
ffffffffc0202408:	f84e8e93          	addi	t4,t4,-124 # ffffffffc02c9388 <pages>
ffffffffc020240c:	6e02                	ld	t3,0(sp)
ffffffffc020240e:	c0000337          	lui	t1,0xc0000
ffffffffc0202412:	fff808b7          	lui	a7,0xfff80
ffffffffc0202416:	00080837          	lui	a6,0x80
ffffffffc020241a:	000c7717          	auipc	a4,0xc7
ffffffffc020241e:	f5e70713          	addi	a4,a4,-162 # ffffffffc02c9378 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0202422:	fcbd                	bnez	s1,ffffffffc02023a0 <exit_range+0x104>
            if (free_pd0) {
ffffffffc0202424:	f00c84e3          	beqz	s9,ffffffffc020232c <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0202428:	000d3783          	ld	a5,0(s10)
ffffffffc020242c:	e072                	sd	t3,0(sp)
ffffffffc020242e:	08fbf663          	bleu	a5,s7,ffffffffc02024ba <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202432:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc0202436:	67a2                	ld	a5,8(sp)
ffffffffc0202438:	4585                	li	a1,1
ffffffffc020243a:	953e                	add	a0,a0,a5
ffffffffc020243c:	a8fff0ef          	jal	ra,ffffffffc0201eca <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202440:	00093023          	sd	zero,0(s2)
ffffffffc0202444:	000c7717          	auipc	a4,0xc7
ffffffffc0202448:	f3470713          	addi	a4,a4,-204 # ffffffffc02c9378 <va_pa_offset>
ffffffffc020244c:	c0000337          	lui	t1,0xc0000
ffffffffc0202450:	6e02                	ld	t3,0(sp)
ffffffffc0202452:	000c7e97          	auipc	t4,0xc7
ffffffffc0202456:	f36e8e93          	addi	t4,t4,-202 # ffffffffc02c9388 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc020245a:	ec099be3          	bnez	s3,ffffffffc0202330 <exit_range+0x94>
}
ffffffffc020245e:	70e6                	ld	ra,120(sp)
ffffffffc0202460:	7446                	ld	s0,112(sp)
ffffffffc0202462:	74a6                	ld	s1,104(sp)
ffffffffc0202464:	7906                	ld	s2,96(sp)
ffffffffc0202466:	69e6                	ld	s3,88(sp)
ffffffffc0202468:	6a46                	ld	s4,80(sp)
ffffffffc020246a:	6aa6                	ld	s5,72(sp)
ffffffffc020246c:	6b06                	ld	s6,64(sp)
ffffffffc020246e:	7be2                	ld	s7,56(sp)
ffffffffc0202470:	7c42                	ld	s8,48(sp)
ffffffffc0202472:	7ca2                	ld	s9,40(sp)
ffffffffc0202474:	7d02                	ld	s10,32(sp)
ffffffffc0202476:	6de2                	ld	s11,24(sp)
ffffffffc0202478:	6109                	addi	sp,sp,128
ffffffffc020247a:	8082                	ret
            if (free_pd0) {
ffffffffc020247c:	ea0c8ae3          	beqz	s9,ffffffffc0202330 <exit_range+0x94>
ffffffffc0202480:	b765                	j	ffffffffc0202428 <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202482:	00008697          	auipc	a3,0x8
ffffffffc0202486:	0d668693          	addi	a3,a3,214 # ffffffffc020a558 <default_pmm_manager+0x6e8>
ffffffffc020248a:	00007617          	auipc	a2,0x7
ffffffffc020248e:	29e60613          	addi	a2,a2,670 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202492:	15000593          	li	a1,336
ffffffffc0202496:	00008517          	auipc	a0,0x8
ffffffffc020249a:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc020249e:	febfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    return KADDR(page2pa(page));
ffffffffc02024a2:	00008617          	auipc	a2,0x8
ffffffffc02024a6:	a1e60613          	addi	a2,a2,-1506 # ffffffffc0209ec0 <default_pmm_manager+0x50>
ffffffffc02024aa:	06900593          	li	a1,105
ffffffffc02024ae:	00008517          	auipc	a0,0x8
ffffffffc02024b2:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc02024b6:	fd3fd0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02024ba:	00008617          	auipc	a2,0x8
ffffffffc02024be:	a6660613          	addi	a2,a2,-1434 # ffffffffc0209f20 <default_pmm_manager+0xb0>
ffffffffc02024c2:	06200593          	li	a1,98
ffffffffc02024c6:	00008517          	auipc	a0,0x8
ffffffffc02024ca:	a2250513          	addi	a0,a0,-1502 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc02024ce:	fbbfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02024d2:	00008697          	auipc	a3,0x8
ffffffffc02024d6:	0b668693          	addi	a3,a3,182 # ffffffffc020a588 <default_pmm_manager+0x718>
ffffffffc02024da:	00007617          	auipc	a2,0x7
ffffffffc02024de:	24e60613          	addi	a2,a2,590 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02024e2:	15100593          	li	a1,337
ffffffffc02024e6:	00008517          	auipc	a0,0x8
ffffffffc02024ea:	afa50513          	addi	a0,a0,-1286 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc02024ee:	f9bfd0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02024f2 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02024f2:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02024f4:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02024f6:	e426                	sd	s1,8(sp)
ffffffffc02024f8:	ec06                	sd	ra,24(sp)
ffffffffc02024fa:	e822                	sd	s0,16(sp)
ffffffffc02024fc:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02024fe:	a53ff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
    if (ptep != NULL) {
ffffffffc0202502:	c511                	beqz	a0,ffffffffc020250e <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202504:	611c                	ld	a5,0(a0)
ffffffffc0202506:	842a                	mv	s0,a0
ffffffffc0202508:	0017f713          	andi	a4,a5,1
ffffffffc020250c:	e711                	bnez	a4,ffffffffc0202518 <page_remove+0x26>
}
ffffffffc020250e:	60e2                	ld	ra,24(sp)
ffffffffc0202510:	6442                	ld	s0,16(sp)
ffffffffc0202512:	64a2                	ld	s1,8(sp)
ffffffffc0202514:	6105                	addi	sp,sp,32
ffffffffc0202516:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202518:	000c7717          	auipc	a4,0xc7
ffffffffc020251c:	df070713          	addi	a4,a4,-528 # ffffffffc02c9308 <npage>
ffffffffc0202520:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202522:	078a                	slli	a5,a5,0x2
ffffffffc0202524:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202526:	02e7fe63          	bleu	a4,a5,ffffffffc0202562 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc020252a:	000c7717          	auipc	a4,0xc7
ffffffffc020252e:	e5e70713          	addi	a4,a4,-418 # ffffffffc02c9388 <pages>
ffffffffc0202532:	6308                	ld	a0,0(a4)
ffffffffc0202534:	fff80737          	lui	a4,0xfff80
ffffffffc0202538:	97ba                	add	a5,a5,a4
ffffffffc020253a:	079a                	slli	a5,a5,0x6
ffffffffc020253c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020253e:	411c                	lw	a5,0(a0)
ffffffffc0202540:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202544:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202546:	cb11                	beqz	a4,ffffffffc020255a <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202548:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020254c:	12048073          	sfence.vma	s1
}
ffffffffc0202550:	60e2                	ld	ra,24(sp)
ffffffffc0202552:	6442                	ld	s0,16(sp)
ffffffffc0202554:	64a2                	ld	s1,8(sp)
ffffffffc0202556:	6105                	addi	sp,sp,32
ffffffffc0202558:	8082                	ret
            free_page(page);
ffffffffc020255a:	4585                	li	a1,1
ffffffffc020255c:	96fff0ef          	jal	ra,ffffffffc0201eca <free_pages>
ffffffffc0202560:	b7e5                	j	ffffffffc0202548 <page_remove+0x56>
ffffffffc0202562:	8c5ff0ef          	jal	ra,ffffffffc0201e26 <pa2page.part.4>

ffffffffc0202566 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202566:	7179                	addi	sp,sp,-48
ffffffffc0202568:	e44e                	sd	s3,8(sp)
ffffffffc020256a:	89b2                	mv	s3,a2
ffffffffc020256c:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020256e:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202570:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202572:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202574:	ec26                	sd	s1,24(sp)
ffffffffc0202576:	f406                	sd	ra,40(sp)
ffffffffc0202578:	e84a                	sd	s2,16(sp)
ffffffffc020257a:	e052                	sd	s4,0(sp)
ffffffffc020257c:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020257e:	9d3ff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
    if (ptep == NULL) {
ffffffffc0202582:	cd49                	beqz	a0,ffffffffc020261c <page_insert+0xb6>
    page->ref += 1;
ffffffffc0202584:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0202586:	611c                	ld	a5,0(a0)
ffffffffc0202588:	892a                	mv	s2,a0
ffffffffc020258a:	0016871b          	addiw	a4,a3,1
ffffffffc020258e:	c018                	sw	a4,0(s0)
ffffffffc0202590:	0017f713          	andi	a4,a5,1
ffffffffc0202594:	ef05                	bnez	a4,ffffffffc02025cc <page_insert+0x66>
ffffffffc0202596:	000c7797          	auipc	a5,0xc7
ffffffffc020259a:	df278793          	addi	a5,a5,-526 # ffffffffc02c9388 <pages>
ffffffffc020259e:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc02025a0:	8c19                	sub	s0,s0,a4
ffffffffc02025a2:	000806b7          	lui	a3,0x80
ffffffffc02025a6:	8419                	srai	s0,s0,0x6
ffffffffc02025a8:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02025aa:	042a                	slli	s0,s0,0xa
ffffffffc02025ac:	8c45                	or	s0,s0,s1
ffffffffc02025ae:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02025b2:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025b6:	12098073          	sfence.vma	s3
    return 0;
ffffffffc02025ba:	4501                	li	a0,0
}
ffffffffc02025bc:	70a2                	ld	ra,40(sp)
ffffffffc02025be:	7402                	ld	s0,32(sp)
ffffffffc02025c0:	64e2                	ld	s1,24(sp)
ffffffffc02025c2:	6942                	ld	s2,16(sp)
ffffffffc02025c4:	69a2                	ld	s3,8(sp)
ffffffffc02025c6:	6a02                	ld	s4,0(sp)
ffffffffc02025c8:	6145                	addi	sp,sp,48
ffffffffc02025ca:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02025cc:	000c7717          	auipc	a4,0xc7
ffffffffc02025d0:	d3c70713          	addi	a4,a4,-708 # ffffffffc02c9308 <npage>
ffffffffc02025d4:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02025d6:	078a                	slli	a5,a5,0x2
ffffffffc02025d8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02025da:	04e7f363          	bleu	a4,a5,ffffffffc0202620 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc02025de:	000c7a17          	auipc	s4,0xc7
ffffffffc02025e2:	daaa0a13          	addi	s4,s4,-598 # ffffffffc02c9388 <pages>
ffffffffc02025e6:	000a3703          	ld	a4,0(s4)
ffffffffc02025ea:	fff80537          	lui	a0,0xfff80
ffffffffc02025ee:	953e                	add	a0,a0,a5
ffffffffc02025f0:	051a                	slli	a0,a0,0x6
ffffffffc02025f2:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc02025f4:	00a40a63          	beq	s0,a0,ffffffffc0202608 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc02025f8:	411c                	lw	a5,0(a0)
ffffffffc02025fa:	fff7869b          	addiw	a3,a5,-1
ffffffffc02025fe:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0202600:	c691                	beqz	a3,ffffffffc020260c <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202602:	12098073          	sfence.vma	s3
ffffffffc0202606:	bf69                	j	ffffffffc02025a0 <page_insert+0x3a>
ffffffffc0202608:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc020260a:	bf59                	j	ffffffffc02025a0 <page_insert+0x3a>
            free_page(page);
ffffffffc020260c:	4585                	li	a1,1
ffffffffc020260e:	8bdff0ef          	jal	ra,ffffffffc0201eca <free_pages>
ffffffffc0202612:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202616:	12098073          	sfence.vma	s3
ffffffffc020261a:	b759                	j	ffffffffc02025a0 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc020261c:	5571                	li	a0,-4
ffffffffc020261e:	bf79                	j	ffffffffc02025bc <page_insert+0x56>
ffffffffc0202620:	807ff0ef          	jal	ra,ffffffffc0201e26 <pa2page.part.4>

ffffffffc0202624 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202624:	00008797          	auipc	a5,0x8
ffffffffc0202628:	84c78793          	addi	a5,a5,-1972 # ffffffffc0209e70 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020262c:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc020262e:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202630:	00008517          	auipc	a0,0x8
ffffffffc0202634:	9d850513          	addi	a0,a0,-1576 # ffffffffc020a008 <default_pmm_manager+0x198>
void pmm_init(void) {
ffffffffc0202638:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020263a:	000c7717          	auipc	a4,0xc7
ffffffffc020263e:	d2f73b23          	sd	a5,-714(a4) # ffffffffc02c9370 <pmm_manager>
void pmm_init(void) {
ffffffffc0202642:	e0a2                	sd	s0,64(sp)
ffffffffc0202644:	fc26                	sd	s1,56(sp)
ffffffffc0202646:	f84a                	sd	s2,48(sp)
ffffffffc0202648:	f44e                	sd	s3,40(sp)
ffffffffc020264a:	f052                	sd	s4,32(sp)
ffffffffc020264c:	ec56                	sd	s5,24(sp)
ffffffffc020264e:	e85a                	sd	s6,16(sp)
ffffffffc0202650:	e45e                	sd	s7,8(sp)
ffffffffc0202652:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202654:	000c7417          	auipc	s0,0xc7
ffffffffc0202658:	d1c40413          	addi	s0,s0,-740 # ffffffffc02c9370 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020265c:	b37fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
    pmm_manager->init();
ffffffffc0202660:	601c                	ld	a5,0(s0)
ffffffffc0202662:	000c7497          	auipc	s1,0xc7
ffffffffc0202666:	ca648493          	addi	s1,s1,-858 # ffffffffc02c9308 <npage>
ffffffffc020266a:	000c7917          	auipc	s2,0xc7
ffffffffc020266e:	d1e90913          	addi	s2,s2,-738 # ffffffffc02c9388 <pages>
ffffffffc0202672:	679c                	ld	a5,8(a5)
ffffffffc0202674:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202676:	57f5                	li	a5,-3
ffffffffc0202678:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020267a:	00008517          	auipc	a0,0x8
ffffffffc020267e:	9a650513          	addi	a0,a0,-1626 # ffffffffc020a020 <default_pmm_manager+0x1b0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202682:	000c7717          	auipc	a4,0xc7
ffffffffc0202686:	cef73b23          	sd	a5,-778(a4) # ffffffffc02c9378 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020268a:	b09fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020268e:	46c5                	li	a3,17
ffffffffc0202690:	06ee                	slli	a3,a3,0x1b
ffffffffc0202692:	40100613          	li	a2,1025
ffffffffc0202696:	16fd                	addi	a3,a3,-1
ffffffffc0202698:	0656                	slli	a2,a2,0x15
ffffffffc020269a:	07e005b7          	lui	a1,0x7e00
ffffffffc020269e:	00008517          	auipc	a0,0x8
ffffffffc02026a2:	99a50513          	addi	a0,a0,-1638 # ffffffffc020a038 <default_pmm_manager+0x1c8>
ffffffffc02026a6:	aedfd0ef          	jal	ra,ffffffffc0200192 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026aa:	777d                	lui	a4,0xfffff
ffffffffc02026ac:	000c8797          	auipc	a5,0xc8
ffffffffc02026b0:	dd378793          	addi	a5,a5,-557 # ffffffffc02ca47f <end+0xfff>
ffffffffc02026b4:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02026b6:	00088737          	lui	a4,0x88
ffffffffc02026ba:	000c7697          	auipc	a3,0xc7
ffffffffc02026be:	c4e6b723          	sd	a4,-946(a3) # ffffffffc02c9308 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026c2:	000c7717          	auipc	a4,0xc7
ffffffffc02026c6:	ccf73323          	sd	a5,-826(a4) # ffffffffc02c9388 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02026ca:	4701                	li	a4,0
ffffffffc02026cc:	4685                	li	a3,1
ffffffffc02026ce:	fff80837          	lui	a6,0xfff80
ffffffffc02026d2:	a019                	j	ffffffffc02026d8 <pmm_init+0xb4>
ffffffffc02026d4:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc02026d8:	00671613          	slli	a2,a4,0x6
ffffffffc02026dc:	97b2                	add	a5,a5,a2
ffffffffc02026de:	07a1                	addi	a5,a5,8
ffffffffc02026e0:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02026e4:	6090                	ld	a2,0(s1)
ffffffffc02026e6:	0705                	addi	a4,a4,1
ffffffffc02026e8:	010607b3          	add	a5,a2,a6
ffffffffc02026ec:	fef764e3          	bltu	a4,a5,ffffffffc02026d4 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02026f0:	00093503          	ld	a0,0(s2)
ffffffffc02026f4:	fe0007b7          	lui	a5,0xfe000
ffffffffc02026f8:	00661693          	slli	a3,a2,0x6
ffffffffc02026fc:	97aa                	add	a5,a5,a0
ffffffffc02026fe:	96be                	add	a3,a3,a5
ffffffffc0202700:	c02007b7          	lui	a5,0xc0200
ffffffffc0202704:	7af6ed63          	bltu	a3,a5,ffffffffc0202ebe <pmm_init+0x89a>
ffffffffc0202708:	000c7997          	auipc	s3,0xc7
ffffffffc020270c:	c7098993          	addi	s3,s3,-912 # ffffffffc02c9378 <va_pa_offset>
ffffffffc0202710:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0202714:	47c5                	li	a5,17
ffffffffc0202716:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202718:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc020271a:	02f6f763          	bleu	a5,a3,ffffffffc0202748 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020271e:	6585                	lui	a1,0x1
ffffffffc0202720:	15fd                	addi	a1,a1,-1
ffffffffc0202722:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc0202724:	00c6d713          	srli	a4,a3,0xc
ffffffffc0202728:	48c77a63          	bleu	a2,a4,ffffffffc0202bbc <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc020272c:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020272e:	75fd                	lui	a1,0xfffff
ffffffffc0202730:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc0202732:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc0202734:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202736:	40d786b3          	sub	a3,a5,a3
ffffffffc020273a:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc020273c:	00c6d593          	srli	a1,a3,0xc
ffffffffc0202740:	953a                	add	a0,a0,a4
ffffffffc0202742:	9602                	jalr	a2
ffffffffc0202744:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202748:	00008517          	auipc	a0,0x8
ffffffffc020274c:	91850513          	addi	a0,a0,-1768 # ffffffffc020a060 <default_pmm_manager+0x1f0>
ffffffffc0202750:	a43fd0ef          	jal	ra,ffffffffc0200192 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202754:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202756:	000c7417          	auipc	s0,0xc7
ffffffffc020275a:	baa40413          	addi	s0,s0,-1110 # ffffffffc02c9300 <boot_pgdir>
    pmm_manager->check();
ffffffffc020275e:	7b9c                	ld	a5,48(a5)
ffffffffc0202760:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202762:	00008517          	auipc	a0,0x8
ffffffffc0202766:	91650513          	addi	a0,a0,-1770 # ffffffffc020a078 <default_pmm_manager+0x208>
ffffffffc020276a:	a29fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020276e:	0000c697          	auipc	a3,0xc
ffffffffc0202772:	89268693          	addi	a3,a3,-1902 # ffffffffc020e000 <boot_page_table_sv39>
ffffffffc0202776:	000c7797          	auipc	a5,0xc7
ffffffffc020277a:	b8d7b523          	sd	a3,-1142(a5) # ffffffffc02c9300 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020277e:	c02007b7          	lui	a5,0xc0200
ffffffffc0202782:	10f6eae3          	bltu	a3,a5,ffffffffc0203096 <pmm_init+0xa72>
ffffffffc0202786:	0009b783          	ld	a5,0(s3)
ffffffffc020278a:	8e9d                	sub	a3,a3,a5
ffffffffc020278c:	000c7797          	auipc	a5,0xc7
ffffffffc0202790:	bed7ba23          	sd	a3,-1036(a5) # ffffffffc02c9380 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0202794:	f7cff0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202798:	6098                	ld	a4,0(s1)
ffffffffc020279a:	c80007b7          	lui	a5,0xc8000
ffffffffc020279e:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc02027a0:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02027a2:	0ce7eae3          	bltu	a5,a4,ffffffffc0203076 <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02027a6:	6008                	ld	a0,0(s0)
ffffffffc02027a8:	44050463          	beqz	a0,ffffffffc0202bf0 <pmm_init+0x5cc>
ffffffffc02027ac:	6785                	lui	a5,0x1
ffffffffc02027ae:	17fd                	addi	a5,a5,-1
ffffffffc02027b0:	8fe9                	and	a5,a5,a0
ffffffffc02027b2:	2781                	sext.w	a5,a5
ffffffffc02027b4:	42079e63          	bnez	a5,ffffffffc0202bf0 <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02027b8:	4601                	li	a2,0
ffffffffc02027ba:	4581                	li	a1,0
ffffffffc02027bc:	967ff0ef          	jal	ra,ffffffffc0202122 <get_page>
ffffffffc02027c0:	78051b63          	bnez	a0,ffffffffc0202f56 <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02027c4:	4505                	li	a0,1
ffffffffc02027c6:	e7cff0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc02027ca:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02027cc:	6008                	ld	a0,0(s0)
ffffffffc02027ce:	4681                	li	a3,0
ffffffffc02027d0:	4601                	li	a2,0
ffffffffc02027d2:	85d6                	mv	a1,s5
ffffffffc02027d4:	d93ff0ef          	jal	ra,ffffffffc0202566 <page_insert>
ffffffffc02027d8:	7a051f63          	bnez	a0,ffffffffc0202f96 <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02027dc:	6008                	ld	a0,0(s0)
ffffffffc02027de:	4601                	li	a2,0
ffffffffc02027e0:	4581                	li	a1,0
ffffffffc02027e2:	f6eff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc02027e6:	78050863          	beqz	a0,ffffffffc0202f76 <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc02027ea:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02027ec:	0017f713          	andi	a4,a5,1
ffffffffc02027f0:	3e070463          	beqz	a4,ffffffffc0202bd8 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc02027f4:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02027f6:	078a                	slli	a5,a5,0x2
ffffffffc02027f8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02027fa:	3ce7f163          	bleu	a4,a5,ffffffffc0202bbc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02027fe:	00093683          	ld	a3,0(s2)
ffffffffc0202802:	fff80637          	lui	a2,0xfff80
ffffffffc0202806:	97b2                	add	a5,a5,a2
ffffffffc0202808:	079a                	slli	a5,a5,0x6
ffffffffc020280a:	97b6                	add	a5,a5,a3
ffffffffc020280c:	72fa9563          	bne	s5,a5,ffffffffc0202f36 <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc0202810:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8908>
ffffffffc0202814:	4785                	li	a5,1
ffffffffc0202816:	70fb9063          	bne	s7,a5,ffffffffc0202f16 <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020281a:	6008                	ld	a0,0(s0)
ffffffffc020281c:	76fd                	lui	a3,0xfffff
ffffffffc020281e:	611c                	ld	a5,0(a0)
ffffffffc0202820:	078a                	slli	a5,a5,0x2
ffffffffc0202822:	8ff5                	and	a5,a5,a3
ffffffffc0202824:	00c7d613          	srli	a2,a5,0xc
ffffffffc0202828:	66e67e63          	bleu	a4,a2,ffffffffc0202ea4 <pmm_init+0x880>
ffffffffc020282c:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202830:	97e2                	add	a5,a5,s8
ffffffffc0202832:	0007bb03          	ld	s6,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8908>
ffffffffc0202836:	0b0a                	slli	s6,s6,0x2
ffffffffc0202838:	00db7b33          	and	s6,s6,a3
ffffffffc020283c:	00cb5793          	srli	a5,s6,0xc
ffffffffc0202840:	56e7f863          	bleu	a4,a5,ffffffffc0202db0 <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202844:	4601                	li	a2,0
ffffffffc0202846:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202848:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020284a:	f06ff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020284e:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202850:	55651063          	bne	a0,s6,ffffffffc0202d90 <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc0202854:	4505                	li	a0,1
ffffffffc0202856:	decff0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020285a:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020285c:	6008                	ld	a0,0(s0)
ffffffffc020285e:	46d1                	li	a3,20
ffffffffc0202860:	6605                	lui	a2,0x1
ffffffffc0202862:	85da                	mv	a1,s6
ffffffffc0202864:	d03ff0ef          	jal	ra,ffffffffc0202566 <page_insert>
ffffffffc0202868:	50051463          	bnez	a0,ffffffffc0202d70 <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020286c:	6008                	ld	a0,0(s0)
ffffffffc020286e:	4601                	li	a2,0
ffffffffc0202870:	6585                	lui	a1,0x1
ffffffffc0202872:	edeff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc0202876:	4c050d63          	beqz	a0,ffffffffc0202d50 <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc020287a:	611c                	ld	a5,0(a0)
ffffffffc020287c:	0107f713          	andi	a4,a5,16
ffffffffc0202880:	4a070863          	beqz	a4,ffffffffc0202d30 <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc0202884:	8b91                	andi	a5,a5,4
ffffffffc0202886:	48078563          	beqz	a5,ffffffffc0202d10 <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020288a:	6008                	ld	a0,0(s0)
ffffffffc020288c:	611c                	ld	a5,0(a0)
ffffffffc020288e:	8bc1                	andi	a5,a5,16
ffffffffc0202890:	46078063          	beqz	a5,ffffffffc0202cf0 <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc0202894:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_matrix_out_size+0x1f4590>
ffffffffc0202898:	43779c63          	bne	a5,s7,ffffffffc0202cd0 <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020289c:	4681                	li	a3,0
ffffffffc020289e:	6605                	lui	a2,0x1
ffffffffc02028a0:	85d6                	mv	a1,s5
ffffffffc02028a2:	cc5ff0ef          	jal	ra,ffffffffc0202566 <page_insert>
ffffffffc02028a6:	40051563          	bnez	a0,ffffffffc0202cb0 <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc02028aa:	000aa703          	lw	a4,0(s5)
ffffffffc02028ae:	4789                	li	a5,2
ffffffffc02028b0:	3ef71063          	bne	a4,a5,ffffffffc0202c90 <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc02028b4:	000b2783          	lw	a5,0(s6)
ffffffffc02028b8:	3a079c63          	bnez	a5,ffffffffc0202c70 <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02028bc:	6008                	ld	a0,0(s0)
ffffffffc02028be:	4601                	li	a2,0
ffffffffc02028c0:	6585                	lui	a1,0x1
ffffffffc02028c2:	e8eff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc02028c6:	38050563          	beqz	a0,ffffffffc0202c50 <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc02028ca:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02028cc:	00177793          	andi	a5,a4,1
ffffffffc02028d0:	30078463          	beqz	a5,ffffffffc0202bd8 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc02028d4:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02028d6:	00271793          	slli	a5,a4,0x2
ffffffffc02028da:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028dc:	2ed7f063          	bleu	a3,a5,ffffffffc0202bbc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02028e0:	00093683          	ld	a3,0(s2)
ffffffffc02028e4:	fff80637          	lui	a2,0xfff80
ffffffffc02028e8:	97b2                	add	a5,a5,a2
ffffffffc02028ea:	079a                	slli	a5,a5,0x6
ffffffffc02028ec:	97b6                	add	a5,a5,a3
ffffffffc02028ee:	32fa9163          	bne	s5,a5,ffffffffc0202c10 <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc02028f2:	8b41                	andi	a4,a4,16
ffffffffc02028f4:	70071163          	bnez	a4,ffffffffc0202ff6 <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc02028f8:	6008                	ld	a0,0(s0)
ffffffffc02028fa:	4581                	li	a1,0
ffffffffc02028fc:	bf7ff0ef          	jal	ra,ffffffffc02024f2 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202900:	000aa703          	lw	a4,0(s5)
ffffffffc0202904:	4785                	li	a5,1
ffffffffc0202906:	6cf71863          	bne	a4,a5,ffffffffc0202fd6 <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc020290a:	000b2783          	lw	a5,0(s6)
ffffffffc020290e:	6a079463          	bnez	a5,ffffffffc0202fb6 <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0202912:	6008                	ld	a0,0(s0)
ffffffffc0202914:	6585                	lui	a1,0x1
ffffffffc0202916:	bddff0ef          	jal	ra,ffffffffc02024f2 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020291a:	000aa783          	lw	a5,0(s5)
ffffffffc020291e:	50079363          	bnez	a5,ffffffffc0202e24 <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc0202922:	000b2783          	lw	a5,0(s6)
ffffffffc0202926:	4c079f63          	bnez	a5,ffffffffc0202e04 <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020292a:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020292e:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202930:	000ab783          	ld	a5,0(s5)
ffffffffc0202934:	078a                	slli	a5,a5,0x2
ffffffffc0202936:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202938:	28c7f263          	bleu	a2,a5,ffffffffc0202bbc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020293c:	fff80737          	lui	a4,0xfff80
ffffffffc0202940:	00093503          	ld	a0,0(s2)
ffffffffc0202944:	97ba                	add	a5,a5,a4
ffffffffc0202946:	079a                	slli	a5,a5,0x6
ffffffffc0202948:	00f50733          	add	a4,a0,a5
ffffffffc020294c:	4314                	lw	a3,0(a4)
ffffffffc020294e:	4705                	li	a4,1
ffffffffc0202950:	48e69a63          	bne	a3,a4,ffffffffc0202de4 <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc0202954:	8799                	srai	a5,a5,0x6
ffffffffc0202956:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc020295a:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc020295c:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc020295e:	8331                	srli	a4,a4,0xc
ffffffffc0202960:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202962:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202964:	46c77363          	bleu	a2,a4,ffffffffc0202dca <pmm_init+0x7a6>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202968:	0009b683          	ld	a3,0(s3)
ffffffffc020296c:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc020296e:	639c                	ld	a5,0(a5)
ffffffffc0202970:	078a                	slli	a5,a5,0x2
ffffffffc0202972:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202974:	24c7f463          	bleu	a2,a5,ffffffffc0202bbc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202978:	416787b3          	sub	a5,a5,s6
ffffffffc020297c:	079a                	slli	a5,a5,0x6
ffffffffc020297e:	953e                	add	a0,a0,a5
ffffffffc0202980:	4585                	li	a1,1
ffffffffc0202982:	d48ff0ef          	jal	ra,ffffffffc0201eca <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202986:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc020298a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020298c:	078a                	slli	a5,a5,0x2
ffffffffc020298e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202990:	22e7f663          	bleu	a4,a5,ffffffffc0202bbc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202994:	00093503          	ld	a0,0(s2)
ffffffffc0202998:	416787b3          	sub	a5,a5,s6
ffffffffc020299c:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc020299e:	953e                	add	a0,a0,a5
ffffffffc02029a0:	4585                	li	a1,1
ffffffffc02029a2:	d28ff0ef          	jal	ra,ffffffffc0201eca <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02029a6:	601c                	ld	a5,0(s0)
ffffffffc02029a8:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02029ac:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02029b0:	d60ff0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>
ffffffffc02029b4:	68aa1163          	bne	s4,a0,ffffffffc0203036 <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02029b8:	00008517          	auipc	a0,0x8
ffffffffc02029bc:	9d050513          	addi	a0,a0,-1584 # ffffffffc020a388 <default_pmm_manager+0x518>
ffffffffc02029c0:	fd2fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc02029c4:	d4cff0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029c8:	6098                	ld	a4,0(s1)
ffffffffc02029ca:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc02029ce:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029d0:	00c71693          	slli	a3,a4,0xc
ffffffffc02029d4:	18d7f563          	bleu	a3,a5,ffffffffc0202b5e <pmm_init+0x53a>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029d8:	83b1                	srli	a5,a5,0xc
ffffffffc02029da:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029dc:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029e0:	1ae7f163          	bleu	a4,a5,ffffffffc0202b82 <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02029e4:	7bfd                	lui	s7,0xfffff
ffffffffc02029e6:	6b05                	lui	s6,0x1
ffffffffc02029e8:	a029                	j	ffffffffc02029f2 <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029ea:	00cad713          	srli	a4,s5,0xc
ffffffffc02029ee:	18f77a63          	bleu	a5,a4,ffffffffc0202b82 <pmm_init+0x55e>
ffffffffc02029f2:	0009b583          	ld	a1,0(s3)
ffffffffc02029f6:	4601                	li	a2,0
ffffffffc02029f8:	95d6                	add	a1,a1,s5
ffffffffc02029fa:	d56ff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc02029fe:	16050263          	beqz	a0,ffffffffc0202b62 <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202a02:	611c                	ld	a5,0(a0)
ffffffffc0202a04:	078a                	slli	a5,a5,0x2
ffffffffc0202a06:	0177f7b3          	and	a5,a5,s7
ffffffffc0202a0a:	19579963          	bne	a5,s5,ffffffffc0202b9c <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202a0e:	609c                	ld	a5,0(s1)
ffffffffc0202a10:	9ada                	add	s5,s5,s6
ffffffffc0202a12:	6008                	ld	a0,0(s0)
ffffffffc0202a14:	00c79713          	slli	a4,a5,0xc
ffffffffc0202a18:	fceae9e3          	bltu	s5,a4,ffffffffc02029ea <pmm_init+0x3c6>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0202a1c:	611c                	ld	a5,0(a0)
ffffffffc0202a1e:	62079c63          	bnez	a5,ffffffffc0203056 <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc0202a22:	4505                	li	a0,1
ffffffffc0202a24:	c1eff0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0202a28:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202a2a:	6008                	ld	a0,0(s0)
ffffffffc0202a2c:	4699                	li	a3,6
ffffffffc0202a2e:	10000613          	li	a2,256
ffffffffc0202a32:	85d6                	mv	a1,s5
ffffffffc0202a34:	b33ff0ef          	jal	ra,ffffffffc0202566 <page_insert>
ffffffffc0202a38:	1e051c63          	bnez	a0,ffffffffc0202c30 <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc0202a3c:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0202a40:	4785                	li	a5,1
ffffffffc0202a42:	44f71163          	bne	a4,a5,ffffffffc0202e84 <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202a46:	6008                	ld	a0,0(s0)
ffffffffc0202a48:	6b05                	lui	s6,0x1
ffffffffc0202a4a:	4699                	li	a3,6
ffffffffc0202a4c:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x8808>
ffffffffc0202a50:	85d6                	mv	a1,s5
ffffffffc0202a52:	b15ff0ef          	jal	ra,ffffffffc0202566 <page_insert>
ffffffffc0202a56:	40051763          	bnez	a0,ffffffffc0202e64 <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc0202a5a:	000aa703          	lw	a4,0(s5)
ffffffffc0202a5e:	4789                	li	a5,2
ffffffffc0202a60:	3ef71263          	bne	a4,a5,ffffffffc0202e44 <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202a64:	00008597          	auipc	a1,0x8
ffffffffc0202a68:	a5c58593          	addi	a1,a1,-1444 # ffffffffc020a4c0 <default_pmm_manager+0x650>
ffffffffc0202a6c:	10000513          	li	a0,256
ffffffffc0202a70:	642060ef          	jal	ra,ffffffffc02090b2 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202a74:	100b0593          	addi	a1,s6,256
ffffffffc0202a78:	10000513          	li	a0,256
ffffffffc0202a7c:	648060ef          	jal	ra,ffffffffc02090c4 <strcmp>
ffffffffc0202a80:	44051b63          	bnez	a0,ffffffffc0202ed6 <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc0202a84:	00093683          	ld	a3,0(s2)
ffffffffc0202a88:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202a8c:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0202a8e:	40da86b3          	sub	a3,s5,a3
ffffffffc0202a92:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202a94:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202a96:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202a98:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0202a9c:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202aa0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202aa2:	10f77f63          	bleu	a5,a4,ffffffffc0202bc0 <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202aa6:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202aaa:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202aae:	96be                	add	a3,a3,a5
ffffffffc0202ab0:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fd35c80>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202ab4:	5ba060ef          	jal	ra,ffffffffc020906e <strlen>
ffffffffc0202ab8:	54051f63          	bnez	a0,ffffffffc0203016 <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202abc:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202ac0:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ac2:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd35b80>
ffffffffc0202ac6:	068a                	slli	a3,a3,0x2
ffffffffc0202ac8:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202aca:	0ef6f963          	bleu	a5,a3,ffffffffc0202bbc <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc0202ace:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ad2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202ad4:	0efb7663          	bleu	a5,s6,ffffffffc0202bc0 <pmm_init+0x59c>
ffffffffc0202ad8:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202adc:	4585                	li	a1,1
ffffffffc0202ade:	8556                	mv	a0,s5
ffffffffc0202ae0:	99b6                	add	s3,s3,a3
ffffffffc0202ae2:	be8ff0ef          	jal	ra,ffffffffc0201eca <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ae6:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202aea:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202aec:	078a                	slli	a5,a5,0x2
ffffffffc0202aee:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202af0:	0ce7f663          	bleu	a4,a5,ffffffffc0202bbc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202af4:	00093503          	ld	a0,0(s2)
ffffffffc0202af8:	fff809b7          	lui	s3,0xfff80
ffffffffc0202afc:	97ce                	add	a5,a5,s3
ffffffffc0202afe:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202b00:	953e                	add	a0,a0,a5
ffffffffc0202b02:	4585                	li	a1,1
ffffffffc0202b04:	bc6ff0ef          	jal	ra,ffffffffc0201eca <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b08:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0202b0c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b0e:	078a                	slli	a5,a5,0x2
ffffffffc0202b10:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b12:	0ae7f563          	bleu	a4,a5,ffffffffc0202bbc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b16:	00093503          	ld	a0,0(s2)
ffffffffc0202b1a:	97ce                	add	a5,a5,s3
ffffffffc0202b1c:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202b1e:	953e                	add	a0,a0,a5
ffffffffc0202b20:	4585                	li	a1,1
ffffffffc0202b22:	ba8ff0ef          	jal	ra,ffffffffc0201eca <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202b26:	601c                	ld	a5,0(s0)
ffffffffc0202b28:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0202b2c:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202b30:	be0ff0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>
ffffffffc0202b34:	3caa1163          	bne	s4,a0,ffffffffc0202ef6 <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202b38:	00008517          	auipc	a0,0x8
ffffffffc0202b3c:	a0050513          	addi	a0,a0,-1536 # ffffffffc020a538 <default_pmm_manager+0x6c8>
ffffffffc0202b40:	e52fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
}
ffffffffc0202b44:	6406                	ld	s0,64(sp)
ffffffffc0202b46:	60a6                	ld	ra,72(sp)
ffffffffc0202b48:	74e2                	ld	s1,56(sp)
ffffffffc0202b4a:	7942                	ld	s2,48(sp)
ffffffffc0202b4c:	79a2                	ld	s3,40(sp)
ffffffffc0202b4e:	7a02                	ld	s4,32(sp)
ffffffffc0202b50:	6ae2                	ld	s5,24(sp)
ffffffffc0202b52:	6b42                	ld	s6,16(sp)
ffffffffc0202b54:	6ba2                	ld	s7,8(sp)
ffffffffc0202b56:	6c02                	ld	s8,0(sp)
ffffffffc0202b58:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0202b5a:	8c8ff06f          	j	ffffffffc0201c22 <kmalloc_init>
ffffffffc0202b5e:	6008                	ld	a0,0(s0)
ffffffffc0202b60:	bd75                	j	ffffffffc0202a1c <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202b62:	00008697          	auipc	a3,0x8
ffffffffc0202b66:	84668693          	addi	a3,a3,-1978 # ffffffffc020a3a8 <default_pmm_manager+0x538>
ffffffffc0202b6a:	00007617          	auipc	a2,0x7
ffffffffc0202b6e:	bbe60613          	addi	a2,a2,-1090 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202b72:	25600593          	li	a1,598
ffffffffc0202b76:	00007517          	auipc	a0,0x7
ffffffffc0202b7a:	46a50513          	addi	a0,a0,1130 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202b7e:	90bfd0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0202b82:	86d6                	mv	a3,s5
ffffffffc0202b84:	00007617          	auipc	a2,0x7
ffffffffc0202b88:	33c60613          	addi	a2,a2,828 # ffffffffc0209ec0 <default_pmm_manager+0x50>
ffffffffc0202b8c:	25600593          	li	a1,598
ffffffffc0202b90:	00007517          	auipc	a0,0x7
ffffffffc0202b94:	45050513          	addi	a0,a0,1104 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202b98:	8f1fd0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202b9c:	00008697          	auipc	a3,0x8
ffffffffc0202ba0:	84c68693          	addi	a3,a3,-1972 # ffffffffc020a3e8 <default_pmm_manager+0x578>
ffffffffc0202ba4:	00007617          	auipc	a2,0x7
ffffffffc0202ba8:	b8460613          	addi	a2,a2,-1148 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202bac:	25700593          	li	a1,599
ffffffffc0202bb0:	00007517          	auipc	a0,0x7
ffffffffc0202bb4:	43050513          	addi	a0,a0,1072 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202bb8:	8d1fd0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0202bbc:	a6aff0ef          	jal	ra,ffffffffc0201e26 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0202bc0:	00007617          	auipc	a2,0x7
ffffffffc0202bc4:	30060613          	addi	a2,a2,768 # ffffffffc0209ec0 <default_pmm_manager+0x50>
ffffffffc0202bc8:	06900593          	li	a1,105
ffffffffc0202bcc:	00007517          	auipc	a0,0x7
ffffffffc0202bd0:	31c50513          	addi	a0,a0,796 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc0202bd4:	8b5fd0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202bd8:	00007617          	auipc	a2,0x7
ffffffffc0202bdc:	5a060613          	addi	a2,a2,1440 # ffffffffc020a178 <default_pmm_manager+0x308>
ffffffffc0202be0:	07400593          	li	a1,116
ffffffffc0202be4:	00007517          	auipc	a0,0x7
ffffffffc0202be8:	30450513          	addi	a0,a0,772 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc0202bec:	89dfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202bf0:	00007697          	auipc	a3,0x7
ffffffffc0202bf4:	4c868693          	addi	a3,a3,1224 # ffffffffc020a0b8 <default_pmm_manager+0x248>
ffffffffc0202bf8:	00007617          	auipc	a2,0x7
ffffffffc0202bfc:	b3060613          	addi	a2,a2,-1232 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202c00:	21a00593          	li	a1,538
ffffffffc0202c04:	00007517          	auipc	a0,0x7
ffffffffc0202c08:	3dc50513          	addi	a0,a0,988 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202c0c:	87dfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202c10:	00007697          	auipc	a3,0x7
ffffffffc0202c14:	59068693          	addi	a3,a3,1424 # ffffffffc020a1a0 <default_pmm_manager+0x330>
ffffffffc0202c18:	00007617          	auipc	a2,0x7
ffffffffc0202c1c:	b1060613          	addi	a2,a2,-1264 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202c20:	23600593          	li	a1,566
ffffffffc0202c24:	00007517          	auipc	a0,0x7
ffffffffc0202c28:	3bc50513          	addi	a0,a0,956 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202c2c:	85dfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202c30:	00007697          	auipc	a3,0x7
ffffffffc0202c34:	7e868693          	addi	a3,a3,2024 # ffffffffc020a418 <default_pmm_manager+0x5a8>
ffffffffc0202c38:	00007617          	auipc	a2,0x7
ffffffffc0202c3c:	af060613          	addi	a2,a2,-1296 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202c40:	25f00593          	li	a1,607
ffffffffc0202c44:	00007517          	auipc	a0,0x7
ffffffffc0202c48:	39c50513          	addi	a0,a0,924 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202c4c:	83dfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202c50:	00007697          	auipc	a3,0x7
ffffffffc0202c54:	5e068693          	addi	a3,a3,1504 # ffffffffc020a230 <default_pmm_manager+0x3c0>
ffffffffc0202c58:	00007617          	auipc	a2,0x7
ffffffffc0202c5c:	ad060613          	addi	a2,a2,-1328 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202c60:	23500593          	li	a1,565
ffffffffc0202c64:	00007517          	auipc	a0,0x7
ffffffffc0202c68:	37c50513          	addi	a0,a0,892 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202c6c:	81dfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202c70:	00007697          	auipc	a3,0x7
ffffffffc0202c74:	68868693          	addi	a3,a3,1672 # ffffffffc020a2f8 <default_pmm_manager+0x488>
ffffffffc0202c78:	00007617          	auipc	a2,0x7
ffffffffc0202c7c:	ab060613          	addi	a2,a2,-1360 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202c80:	23400593          	li	a1,564
ffffffffc0202c84:	00007517          	auipc	a0,0x7
ffffffffc0202c88:	35c50513          	addi	a0,a0,860 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202c8c:	ffcfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202c90:	00007697          	auipc	a3,0x7
ffffffffc0202c94:	65068693          	addi	a3,a3,1616 # ffffffffc020a2e0 <default_pmm_manager+0x470>
ffffffffc0202c98:	00007617          	auipc	a2,0x7
ffffffffc0202c9c:	a9060613          	addi	a2,a2,-1392 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202ca0:	23300593          	li	a1,563
ffffffffc0202ca4:	00007517          	auipc	a0,0x7
ffffffffc0202ca8:	33c50513          	addi	a0,a0,828 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202cac:	fdcfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202cb0:	00007697          	auipc	a3,0x7
ffffffffc0202cb4:	60068693          	addi	a3,a3,1536 # ffffffffc020a2b0 <default_pmm_manager+0x440>
ffffffffc0202cb8:	00007617          	auipc	a2,0x7
ffffffffc0202cbc:	a7060613          	addi	a2,a2,-1424 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202cc0:	23200593          	li	a1,562
ffffffffc0202cc4:	00007517          	auipc	a0,0x7
ffffffffc0202cc8:	31c50513          	addi	a0,a0,796 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202ccc:	fbcfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202cd0:	00007697          	auipc	a3,0x7
ffffffffc0202cd4:	5c868693          	addi	a3,a3,1480 # ffffffffc020a298 <default_pmm_manager+0x428>
ffffffffc0202cd8:	00007617          	auipc	a2,0x7
ffffffffc0202cdc:	a5060613          	addi	a2,a2,-1456 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202ce0:	23000593          	li	a1,560
ffffffffc0202ce4:	00007517          	auipc	a0,0x7
ffffffffc0202ce8:	2fc50513          	addi	a0,a0,764 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202cec:	f9cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202cf0:	00007697          	auipc	a3,0x7
ffffffffc0202cf4:	59068693          	addi	a3,a3,1424 # ffffffffc020a280 <default_pmm_manager+0x410>
ffffffffc0202cf8:	00007617          	auipc	a2,0x7
ffffffffc0202cfc:	a3060613          	addi	a2,a2,-1488 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202d00:	22f00593          	li	a1,559
ffffffffc0202d04:	00007517          	auipc	a0,0x7
ffffffffc0202d08:	2dc50513          	addi	a0,a0,732 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202d0c:	f7cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202d10:	00007697          	auipc	a3,0x7
ffffffffc0202d14:	56068693          	addi	a3,a3,1376 # ffffffffc020a270 <default_pmm_manager+0x400>
ffffffffc0202d18:	00007617          	auipc	a2,0x7
ffffffffc0202d1c:	a1060613          	addi	a2,a2,-1520 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202d20:	22e00593          	li	a1,558
ffffffffc0202d24:	00007517          	auipc	a0,0x7
ffffffffc0202d28:	2bc50513          	addi	a0,a0,700 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202d2c:	f5cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202d30:	00007697          	auipc	a3,0x7
ffffffffc0202d34:	53068693          	addi	a3,a3,1328 # ffffffffc020a260 <default_pmm_manager+0x3f0>
ffffffffc0202d38:	00007617          	auipc	a2,0x7
ffffffffc0202d3c:	9f060613          	addi	a2,a2,-1552 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202d40:	22d00593          	li	a1,557
ffffffffc0202d44:	00007517          	auipc	a0,0x7
ffffffffc0202d48:	29c50513          	addi	a0,a0,668 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202d4c:	f3cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202d50:	00007697          	auipc	a3,0x7
ffffffffc0202d54:	4e068693          	addi	a3,a3,1248 # ffffffffc020a230 <default_pmm_manager+0x3c0>
ffffffffc0202d58:	00007617          	auipc	a2,0x7
ffffffffc0202d5c:	9d060613          	addi	a2,a2,-1584 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202d60:	22c00593          	li	a1,556
ffffffffc0202d64:	00007517          	auipc	a0,0x7
ffffffffc0202d68:	27c50513          	addi	a0,a0,636 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202d6c:	f1cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202d70:	00007697          	auipc	a3,0x7
ffffffffc0202d74:	48868693          	addi	a3,a3,1160 # ffffffffc020a1f8 <default_pmm_manager+0x388>
ffffffffc0202d78:	00007617          	auipc	a2,0x7
ffffffffc0202d7c:	9b060613          	addi	a2,a2,-1616 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202d80:	22b00593          	li	a1,555
ffffffffc0202d84:	00007517          	auipc	a0,0x7
ffffffffc0202d88:	25c50513          	addi	a0,a0,604 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202d8c:	efcfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202d90:	00007697          	auipc	a3,0x7
ffffffffc0202d94:	44068693          	addi	a3,a3,1088 # ffffffffc020a1d0 <default_pmm_manager+0x360>
ffffffffc0202d98:	00007617          	auipc	a2,0x7
ffffffffc0202d9c:	99060613          	addi	a2,a2,-1648 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202da0:	22800593          	li	a1,552
ffffffffc0202da4:	00007517          	auipc	a0,0x7
ffffffffc0202da8:	23c50513          	addi	a0,a0,572 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202dac:	edcfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202db0:	86da                	mv	a3,s6
ffffffffc0202db2:	00007617          	auipc	a2,0x7
ffffffffc0202db6:	10e60613          	addi	a2,a2,270 # ffffffffc0209ec0 <default_pmm_manager+0x50>
ffffffffc0202dba:	22700593          	li	a1,551
ffffffffc0202dbe:	00007517          	auipc	a0,0x7
ffffffffc0202dc2:	22250513          	addi	a0,a0,546 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202dc6:	ec2fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202dca:	86be                	mv	a3,a5
ffffffffc0202dcc:	00007617          	auipc	a2,0x7
ffffffffc0202dd0:	0f460613          	addi	a2,a2,244 # ffffffffc0209ec0 <default_pmm_manager+0x50>
ffffffffc0202dd4:	06900593          	li	a1,105
ffffffffc0202dd8:	00007517          	auipc	a0,0x7
ffffffffc0202ddc:	11050513          	addi	a0,a0,272 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc0202de0:	ea8fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202de4:	00007697          	auipc	a3,0x7
ffffffffc0202de8:	55c68693          	addi	a3,a3,1372 # ffffffffc020a340 <default_pmm_manager+0x4d0>
ffffffffc0202dec:	00007617          	auipc	a2,0x7
ffffffffc0202df0:	93c60613          	addi	a2,a2,-1732 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202df4:	24100593          	li	a1,577
ffffffffc0202df8:	00007517          	auipc	a0,0x7
ffffffffc0202dfc:	1e850513          	addi	a0,a0,488 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202e00:	e88fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202e04:	00007697          	auipc	a3,0x7
ffffffffc0202e08:	4f468693          	addi	a3,a3,1268 # ffffffffc020a2f8 <default_pmm_manager+0x488>
ffffffffc0202e0c:	00007617          	auipc	a2,0x7
ffffffffc0202e10:	91c60613          	addi	a2,a2,-1764 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202e14:	23f00593          	li	a1,575
ffffffffc0202e18:	00007517          	auipc	a0,0x7
ffffffffc0202e1c:	1c850513          	addi	a0,a0,456 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202e20:	e68fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202e24:	00007697          	auipc	a3,0x7
ffffffffc0202e28:	50468693          	addi	a3,a3,1284 # ffffffffc020a328 <default_pmm_manager+0x4b8>
ffffffffc0202e2c:	00007617          	auipc	a2,0x7
ffffffffc0202e30:	8fc60613          	addi	a2,a2,-1796 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202e34:	23e00593          	li	a1,574
ffffffffc0202e38:	00007517          	auipc	a0,0x7
ffffffffc0202e3c:	1a850513          	addi	a0,a0,424 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202e40:	e48fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202e44:	00007697          	auipc	a3,0x7
ffffffffc0202e48:	66468693          	addi	a3,a3,1636 # ffffffffc020a4a8 <default_pmm_manager+0x638>
ffffffffc0202e4c:	00007617          	auipc	a2,0x7
ffffffffc0202e50:	8dc60613          	addi	a2,a2,-1828 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202e54:	26200593          	li	a1,610
ffffffffc0202e58:	00007517          	auipc	a0,0x7
ffffffffc0202e5c:	18850513          	addi	a0,a0,392 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202e60:	e28fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202e64:	00007697          	auipc	a3,0x7
ffffffffc0202e68:	60468693          	addi	a3,a3,1540 # ffffffffc020a468 <default_pmm_manager+0x5f8>
ffffffffc0202e6c:	00007617          	auipc	a2,0x7
ffffffffc0202e70:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202e74:	26100593          	li	a1,609
ffffffffc0202e78:	00007517          	auipc	a0,0x7
ffffffffc0202e7c:	16850513          	addi	a0,a0,360 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202e80:	e08fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202e84:	00007697          	auipc	a3,0x7
ffffffffc0202e88:	5cc68693          	addi	a3,a3,1484 # ffffffffc020a450 <default_pmm_manager+0x5e0>
ffffffffc0202e8c:	00007617          	auipc	a2,0x7
ffffffffc0202e90:	89c60613          	addi	a2,a2,-1892 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202e94:	26000593          	li	a1,608
ffffffffc0202e98:	00007517          	auipc	a0,0x7
ffffffffc0202e9c:	14850513          	addi	a0,a0,328 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202ea0:	de8fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202ea4:	86be                	mv	a3,a5
ffffffffc0202ea6:	00007617          	auipc	a2,0x7
ffffffffc0202eaa:	01a60613          	addi	a2,a2,26 # ffffffffc0209ec0 <default_pmm_manager+0x50>
ffffffffc0202eae:	22600593          	li	a1,550
ffffffffc0202eb2:	00007517          	auipc	a0,0x7
ffffffffc0202eb6:	12e50513          	addi	a0,a0,302 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202eba:	dcefd0ef          	jal	ra,ffffffffc0200488 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202ebe:	00007617          	auipc	a2,0x7
ffffffffc0202ec2:	03a60613          	addi	a2,a2,58 # ffffffffc0209ef8 <default_pmm_manager+0x88>
ffffffffc0202ec6:	07f00593          	li	a1,127
ffffffffc0202eca:	00007517          	auipc	a0,0x7
ffffffffc0202ece:	11650513          	addi	a0,a0,278 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202ed2:	db6fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202ed6:	00007697          	auipc	a3,0x7
ffffffffc0202eda:	60268693          	addi	a3,a3,1538 # ffffffffc020a4d8 <default_pmm_manager+0x668>
ffffffffc0202ede:	00007617          	auipc	a2,0x7
ffffffffc0202ee2:	84a60613          	addi	a2,a2,-1974 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202ee6:	26600593          	li	a1,614
ffffffffc0202eea:	00007517          	auipc	a0,0x7
ffffffffc0202eee:	0f650513          	addi	a0,a0,246 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202ef2:	d96fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202ef6:	00007697          	auipc	a3,0x7
ffffffffc0202efa:	47268693          	addi	a3,a3,1138 # ffffffffc020a368 <default_pmm_manager+0x4f8>
ffffffffc0202efe:	00007617          	auipc	a2,0x7
ffffffffc0202f02:	82a60613          	addi	a2,a2,-2006 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202f06:	27200593          	li	a1,626
ffffffffc0202f0a:	00007517          	auipc	a0,0x7
ffffffffc0202f0e:	0d650513          	addi	a0,a0,214 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202f12:	d76fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202f16:	00007697          	auipc	a3,0x7
ffffffffc0202f1a:	2a268693          	addi	a3,a3,674 # ffffffffc020a1b8 <default_pmm_manager+0x348>
ffffffffc0202f1e:	00007617          	auipc	a2,0x7
ffffffffc0202f22:	80a60613          	addi	a2,a2,-2038 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202f26:	22400593          	li	a1,548
ffffffffc0202f2a:	00007517          	auipc	a0,0x7
ffffffffc0202f2e:	0b650513          	addi	a0,a0,182 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202f32:	d56fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202f36:	00007697          	auipc	a3,0x7
ffffffffc0202f3a:	26a68693          	addi	a3,a3,618 # ffffffffc020a1a0 <default_pmm_manager+0x330>
ffffffffc0202f3e:	00006617          	auipc	a2,0x6
ffffffffc0202f42:	7ea60613          	addi	a2,a2,2026 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202f46:	22300593          	li	a1,547
ffffffffc0202f4a:	00007517          	auipc	a0,0x7
ffffffffc0202f4e:	09650513          	addi	a0,a0,150 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202f52:	d36fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202f56:	00007697          	auipc	a3,0x7
ffffffffc0202f5a:	19a68693          	addi	a3,a3,410 # ffffffffc020a0f0 <default_pmm_manager+0x280>
ffffffffc0202f5e:	00006617          	auipc	a2,0x6
ffffffffc0202f62:	7ca60613          	addi	a2,a2,1994 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202f66:	21b00593          	li	a1,539
ffffffffc0202f6a:	00007517          	auipc	a0,0x7
ffffffffc0202f6e:	07650513          	addi	a0,a0,118 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202f72:	d16fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202f76:	00007697          	auipc	a3,0x7
ffffffffc0202f7a:	1d268693          	addi	a3,a3,466 # ffffffffc020a148 <default_pmm_manager+0x2d8>
ffffffffc0202f7e:	00006617          	auipc	a2,0x6
ffffffffc0202f82:	7aa60613          	addi	a2,a2,1962 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202f86:	22200593          	li	a1,546
ffffffffc0202f8a:	00007517          	auipc	a0,0x7
ffffffffc0202f8e:	05650513          	addi	a0,a0,86 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202f92:	cf6fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202f96:	00007697          	auipc	a3,0x7
ffffffffc0202f9a:	18268693          	addi	a3,a3,386 # ffffffffc020a118 <default_pmm_manager+0x2a8>
ffffffffc0202f9e:	00006617          	auipc	a2,0x6
ffffffffc0202fa2:	78a60613          	addi	a2,a2,1930 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202fa6:	21f00593          	li	a1,543
ffffffffc0202faa:	00007517          	auipc	a0,0x7
ffffffffc0202fae:	03650513          	addi	a0,a0,54 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202fb2:	cd6fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202fb6:	00007697          	auipc	a3,0x7
ffffffffc0202fba:	34268693          	addi	a3,a3,834 # ffffffffc020a2f8 <default_pmm_manager+0x488>
ffffffffc0202fbe:	00006617          	auipc	a2,0x6
ffffffffc0202fc2:	76a60613          	addi	a2,a2,1898 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202fc6:	23b00593          	li	a1,571
ffffffffc0202fca:	00007517          	auipc	a0,0x7
ffffffffc0202fce:	01650513          	addi	a0,a0,22 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202fd2:	cb6fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202fd6:	00007697          	auipc	a3,0x7
ffffffffc0202fda:	1e268693          	addi	a3,a3,482 # ffffffffc020a1b8 <default_pmm_manager+0x348>
ffffffffc0202fde:	00006617          	auipc	a2,0x6
ffffffffc0202fe2:	74a60613          	addi	a2,a2,1866 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0202fe6:	23a00593          	li	a1,570
ffffffffc0202fea:	00007517          	auipc	a0,0x7
ffffffffc0202fee:	ff650513          	addi	a0,a0,-10 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0202ff2:	c96fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202ff6:	00007697          	auipc	a3,0x7
ffffffffc0202ffa:	31a68693          	addi	a3,a3,794 # ffffffffc020a310 <default_pmm_manager+0x4a0>
ffffffffc0202ffe:	00006617          	auipc	a2,0x6
ffffffffc0203002:	72a60613          	addi	a2,a2,1834 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203006:	23700593          	li	a1,567
ffffffffc020300a:	00007517          	auipc	a0,0x7
ffffffffc020300e:	fd650513          	addi	a0,a0,-42 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0203012:	c76fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203016:	00007697          	auipc	a3,0x7
ffffffffc020301a:	4fa68693          	addi	a3,a3,1274 # ffffffffc020a510 <default_pmm_manager+0x6a0>
ffffffffc020301e:	00006617          	auipc	a2,0x6
ffffffffc0203022:	70a60613          	addi	a2,a2,1802 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203026:	26900593          	li	a1,617
ffffffffc020302a:	00007517          	auipc	a0,0x7
ffffffffc020302e:	fb650513          	addi	a0,a0,-74 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0203032:	c56fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203036:	00007697          	auipc	a3,0x7
ffffffffc020303a:	33268693          	addi	a3,a3,818 # ffffffffc020a368 <default_pmm_manager+0x4f8>
ffffffffc020303e:	00006617          	auipc	a2,0x6
ffffffffc0203042:	6ea60613          	addi	a2,a2,1770 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203046:	24900593          	li	a1,585
ffffffffc020304a:	00007517          	auipc	a0,0x7
ffffffffc020304e:	f9650513          	addi	a0,a0,-106 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0203052:	c36fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203056:	00007697          	auipc	a3,0x7
ffffffffc020305a:	3aa68693          	addi	a3,a3,938 # ffffffffc020a400 <default_pmm_manager+0x590>
ffffffffc020305e:	00006617          	auipc	a2,0x6
ffffffffc0203062:	6ca60613          	addi	a2,a2,1738 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203066:	25b00593          	li	a1,603
ffffffffc020306a:	00007517          	auipc	a0,0x7
ffffffffc020306e:	f7650513          	addi	a0,a0,-138 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0203072:	c16fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203076:	00007697          	auipc	a3,0x7
ffffffffc020307a:	02268693          	addi	a3,a3,34 # ffffffffc020a098 <default_pmm_manager+0x228>
ffffffffc020307e:	00006617          	auipc	a2,0x6
ffffffffc0203082:	6aa60613          	addi	a2,a2,1706 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203086:	21900593          	li	a1,537
ffffffffc020308a:	00007517          	auipc	a0,0x7
ffffffffc020308e:	f5650513          	addi	a0,a0,-170 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0203092:	bf6fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203096:	00007617          	auipc	a2,0x7
ffffffffc020309a:	e6260613          	addi	a2,a2,-414 # ffffffffc0209ef8 <default_pmm_manager+0x88>
ffffffffc020309e:	0c100593          	li	a1,193
ffffffffc02030a2:	00007517          	auipc	a0,0x7
ffffffffc02030a6:	f3e50513          	addi	a0,a0,-194 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc02030aa:	bdefd0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02030ae <copy_range>:
               bool share) {
ffffffffc02030ae:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02030b0:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc02030b4:	f486                	sd	ra,104(sp)
ffffffffc02030b6:	f0a2                	sd	s0,96(sp)
ffffffffc02030b8:	eca6                	sd	s1,88(sp)
ffffffffc02030ba:	e8ca                	sd	s2,80(sp)
ffffffffc02030bc:	e4ce                	sd	s3,72(sp)
ffffffffc02030be:	e0d2                	sd	s4,64(sp)
ffffffffc02030c0:	fc56                	sd	s5,56(sp)
ffffffffc02030c2:	f85a                	sd	s6,48(sp)
ffffffffc02030c4:	f45e                	sd	s7,40(sp)
ffffffffc02030c6:	f062                	sd	s8,32(sp)
ffffffffc02030c8:	ec66                	sd	s9,24(sp)
ffffffffc02030ca:	e86a                	sd	s10,16(sp)
ffffffffc02030cc:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02030ce:	03479713          	slli	a4,a5,0x34
ffffffffc02030d2:	1e071863          	bnez	a4,ffffffffc02032c2 <copy_range+0x214>
    assert(USER_ACCESS(start, end));
ffffffffc02030d6:	002007b7          	lui	a5,0x200
ffffffffc02030da:	8432                	mv	s0,a2
ffffffffc02030dc:	16f66b63          	bltu	a2,a5,ffffffffc0203252 <copy_range+0x1a4>
ffffffffc02030e0:	84b6                	mv	s1,a3
ffffffffc02030e2:	16d67863          	bleu	a3,a2,ffffffffc0203252 <copy_range+0x1a4>
ffffffffc02030e6:	4785                	li	a5,1
ffffffffc02030e8:	07fe                	slli	a5,a5,0x1f
ffffffffc02030ea:	16d7e463          	bltu	a5,a3,ffffffffc0203252 <copy_range+0x1a4>
ffffffffc02030ee:	5a7d                	li	s4,-1
ffffffffc02030f0:	8aaa                	mv	s5,a0
ffffffffc02030f2:	892e                	mv	s2,a1
        start += PGSIZE;
ffffffffc02030f4:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage) {
ffffffffc02030f6:	000c6c17          	auipc	s8,0xc6
ffffffffc02030fa:	212c0c13          	addi	s8,s8,530 # ffffffffc02c9308 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02030fe:	000c6b97          	auipc	s7,0xc6
ffffffffc0203102:	28ab8b93          	addi	s7,s7,650 # ffffffffc02c9388 <pages>
    return page - pages + nbase;
ffffffffc0203106:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc020310a:	00ca5a13          	srli	s4,s4,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc020310e:	4601                	li	a2,0
ffffffffc0203110:	85a2                	mv	a1,s0
ffffffffc0203112:	854a                	mv	a0,s2
ffffffffc0203114:	e3dfe0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc0203118:	8caa                	mv	s9,a0
        if (ptep == NULL) {
ffffffffc020311a:	c17d                	beqz	a0,ffffffffc0203200 <copy_range+0x152>
        if (*ptep & PTE_V) {
ffffffffc020311c:	611c                	ld	a5,0(a0)
ffffffffc020311e:	8b85                	andi	a5,a5,1
ffffffffc0203120:	e785                	bnez	a5,ffffffffc0203148 <copy_range+0x9a>
        start += PGSIZE;
ffffffffc0203122:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc0203124:	fe9465e3          	bltu	s0,s1,ffffffffc020310e <copy_range+0x60>
    return 0;
ffffffffc0203128:	4501                	li	a0,0
}
ffffffffc020312a:	70a6                	ld	ra,104(sp)
ffffffffc020312c:	7406                	ld	s0,96(sp)
ffffffffc020312e:	64e6                	ld	s1,88(sp)
ffffffffc0203130:	6946                	ld	s2,80(sp)
ffffffffc0203132:	69a6                	ld	s3,72(sp)
ffffffffc0203134:	6a06                	ld	s4,64(sp)
ffffffffc0203136:	7ae2                	ld	s5,56(sp)
ffffffffc0203138:	7b42                	ld	s6,48(sp)
ffffffffc020313a:	7ba2                	ld	s7,40(sp)
ffffffffc020313c:	7c02                	ld	s8,32(sp)
ffffffffc020313e:	6ce2                	ld	s9,24(sp)
ffffffffc0203140:	6d42                	ld	s10,16(sp)
ffffffffc0203142:	6da2                	ld	s11,8(sp)
ffffffffc0203144:	6165                	addi	sp,sp,112
ffffffffc0203146:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc0203148:	4605                	li	a2,1
ffffffffc020314a:	85a2                	mv	a1,s0
ffffffffc020314c:	8556                	mv	a0,s5
ffffffffc020314e:	e03fe0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc0203152:	c169                	beqz	a0,ffffffffc0203214 <copy_range+0x166>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0203154:	000cb783          	ld	a5,0(s9)
    if (!(pte & PTE_V)) {
ffffffffc0203158:	0017f713          	andi	a4,a5,1
ffffffffc020315c:	01f7fc93          	andi	s9,a5,31
ffffffffc0203160:	14070563          	beqz	a4,ffffffffc02032aa <copy_range+0x1fc>
    if (PPN(pa) >= npage) {
ffffffffc0203164:	000c3683          	ld	a3,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203168:	078a                	slli	a5,a5,0x2
ffffffffc020316a:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020316e:	12d77263          	bleu	a3,a4,ffffffffc0203292 <copy_range+0x1e4>
    return &pages[PPN(pa) - nbase];
ffffffffc0203172:	000bb783          	ld	a5,0(s7)
ffffffffc0203176:	fff806b7          	lui	a3,0xfff80
ffffffffc020317a:	9736                	add	a4,a4,a3
ffffffffc020317c:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc020317e:	4505                	li	a0,1
ffffffffc0203180:	00e78db3          	add	s11,a5,a4
ffffffffc0203184:	cbffe0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0203188:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc020318a:	0a0d8463          	beqz	s11,ffffffffc0203232 <copy_range+0x184>
            assert(npage != NULL);
ffffffffc020318e:	c175                	beqz	a0,ffffffffc0203272 <copy_range+0x1c4>
    return page - pages + nbase;
ffffffffc0203190:	000bb703          	ld	a4,0(s7)
    return KADDR(page2pa(page));
ffffffffc0203194:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0203198:	40ed86b3          	sub	a3,s11,a4
ffffffffc020319c:	8699                	srai	a3,a3,0x6
ffffffffc020319e:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc02031a0:	0146f7b3          	and	a5,a3,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc02031a4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02031a6:	06c7fa63          	bleu	a2,a5,ffffffffc020321a <copy_range+0x16c>
    return page - pages + nbase;
ffffffffc02031aa:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc02031ae:	000c6717          	auipc	a4,0xc6
ffffffffc02031b2:	1ca70713          	addi	a4,a4,458 # ffffffffc02c9378 <va_pa_offset>
ffffffffc02031b6:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc02031b8:	8799                	srai	a5,a5,0x6
ffffffffc02031ba:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc02031bc:	0147f733          	and	a4,a5,s4
ffffffffc02031c0:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02031c4:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02031c6:	04c77963          	bleu	a2,a4,ffffffffc0203218 <copy_range+0x16a>
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ffffffffc02031ca:	6605                	lui	a2,0x1
ffffffffc02031cc:	953e                	add	a0,a0,a5
ffffffffc02031ce:	751050ef          	jal	ra,ffffffffc020911e <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc02031d2:	86e6                	mv	a3,s9
ffffffffc02031d4:	8622                	mv	a2,s0
ffffffffc02031d6:	85ea                	mv	a1,s10
ffffffffc02031d8:	8556                	mv	a0,s5
ffffffffc02031da:	b8cff0ef          	jal	ra,ffffffffc0202566 <page_insert>
            assert(ret == 0);
ffffffffc02031de:	d131                	beqz	a0,ffffffffc0203122 <copy_range+0x74>
ffffffffc02031e0:	00007697          	auipc	a3,0x7
ffffffffc02031e4:	df068693          	addi	a3,a3,-528 # ffffffffc0209fd0 <default_pmm_manager+0x160>
ffffffffc02031e8:	00006617          	auipc	a2,0x6
ffffffffc02031ec:	54060613          	addi	a2,a2,1344 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02031f0:	1bb00593          	li	a1,443
ffffffffc02031f4:	00007517          	auipc	a0,0x7
ffffffffc02031f8:	dec50513          	addi	a0,a0,-532 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc02031fc:	a8cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203200:	002007b7          	lui	a5,0x200
ffffffffc0203204:	943e                	add	s0,s0,a5
ffffffffc0203206:	ffe007b7          	lui	a5,0xffe00
ffffffffc020320a:	8c7d                	and	s0,s0,a5
    } while (start != 0 && start < end);
ffffffffc020320c:	dc11                	beqz	s0,ffffffffc0203128 <copy_range+0x7a>
ffffffffc020320e:	f09460e3          	bltu	s0,s1,ffffffffc020310e <copy_range+0x60>
ffffffffc0203212:	bf19                	j	ffffffffc0203128 <copy_range+0x7a>
                return -E_NO_MEM;
ffffffffc0203214:	5571                	li	a0,-4
ffffffffc0203216:	bf11                	j	ffffffffc020312a <copy_range+0x7c>
ffffffffc0203218:	86be                	mv	a3,a5
ffffffffc020321a:	00007617          	auipc	a2,0x7
ffffffffc020321e:	ca660613          	addi	a2,a2,-858 # ffffffffc0209ec0 <default_pmm_manager+0x50>
ffffffffc0203222:	06900593          	li	a1,105
ffffffffc0203226:	00007517          	auipc	a0,0x7
ffffffffc020322a:	cc250513          	addi	a0,a0,-830 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc020322e:	a5afd0ef          	jal	ra,ffffffffc0200488 <__panic>
            assert(page != NULL);
ffffffffc0203232:	00007697          	auipc	a3,0x7
ffffffffc0203236:	d7e68693          	addi	a3,a3,-642 # ffffffffc0209fb0 <default_pmm_manager+0x140>
ffffffffc020323a:	00006617          	auipc	a2,0x6
ffffffffc020323e:	4ee60613          	addi	a2,a2,1262 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203242:	1a200593          	li	a1,418
ffffffffc0203246:	00007517          	auipc	a0,0x7
ffffffffc020324a:	d9a50513          	addi	a0,a0,-614 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc020324e:	a3afd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203252:	00007697          	auipc	a3,0x7
ffffffffc0203256:	33668693          	addi	a3,a3,822 # ffffffffc020a588 <default_pmm_manager+0x718>
ffffffffc020325a:	00006617          	auipc	a2,0x6
ffffffffc020325e:	4ce60613          	addi	a2,a2,1230 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203262:	18e00593          	li	a1,398
ffffffffc0203266:	00007517          	auipc	a0,0x7
ffffffffc020326a:	d7a50513          	addi	a0,a0,-646 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc020326e:	a1afd0ef          	jal	ra,ffffffffc0200488 <__panic>
            assert(npage != NULL);
ffffffffc0203272:	00007697          	auipc	a3,0x7
ffffffffc0203276:	d4e68693          	addi	a3,a3,-690 # ffffffffc0209fc0 <default_pmm_manager+0x150>
ffffffffc020327a:	00006617          	auipc	a2,0x6
ffffffffc020327e:	4ae60613          	addi	a2,a2,1198 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203282:	1a300593          	li	a1,419
ffffffffc0203286:	00007517          	auipc	a0,0x7
ffffffffc020328a:	d5a50513          	addi	a0,a0,-678 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc020328e:	9fafd0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203292:	00007617          	auipc	a2,0x7
ffffffffc0203296:	c8e60613          	addi	a2,a2,-882 # ffffffffc0209f20 <default_pmm_manager+0xb0>
ffffffffc020329a:	06200593          	li	a1,98
ffffffffc020329e:	00007517          	auipc	a0,0x7
ffffffffc02032a2:	c4a50513          	addi	a0,a0,-950 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc02032a6:	9e2fd0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02032aa:	00007617          	auipc	a2,0x7
ffffffffc02032ae:	ece60613          	addi	a2,a2,-306 # ffffffffc020a178 <default_pmm_manager+0x308>
ffffffffc02032b2:	07400593          	li	a1,116
ffffffffc02032b6:	00007517          	auipc	a0,0x7
ffffffffc02032ba:	c3250513          	addi	a0,a0,-974 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc02032be:	9cafd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02032c2:	00007697          	auipc	a3,0x7
ffffffffc02032c6:	29668693          	addi	a3,a3,662 # ffffffffc020a558 <default_pmm_manager+0x6e8>
ffffffffc02032ca:	00006617          	auipc	a2,0x6
ffffffffc02032ce:	45e60613          	addi	a2,a2,1118 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02032d2:	18d00593          	li	a1,397
ffffffffc02032d6:	00007517          	auipc	a0,0x7
ffffffffc02032da:	d0a50513          	addi	a0,a0,-758 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc02032de:	9aafd0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02032e2 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02032e2:	12058073          	sfence.vma	a1
}
ffffffffc02032e6:	8082                	ret

ffffffffc02032e8 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02032e8:	7179                	addi	sp,sp,-48
ffffffffc02032ea:	e84a                	sd	s2,16(sp)
ffffffffc02032ec:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02032ee:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02032f0:	f022                	sd	s0,32(sp)
ffffffffc02032f2:	ec26                	sd	s1,24(sp)
ffffffffc02032f4:	e44e                	sd	s3,8(sp)
ffffffffc02032f6:	f406                	sd	ra,40(sp)
ffffffffc02032f8:	84ae                	mv	s1,a1
ffffffffc02032fa:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02032fc:	b47fe0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0203300:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203302:	cd1d                	beqz	a0,ffffffffc0203340 <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203304:	85aa                	mv	a1,a0
ffffffffc0203306:	86ce                	mv	a3,s3
ffffffffc0203308:	8626                	mv	a2,s1
ffffffffc020330a:	854a                	mv	a0,s2
ffffffffc020330c:	a5aff0ef          	jal	ra,ffffffffc0202566 <page_insert>
ffffffffc0203310:	e121                	bnez	a0,ffffffffc0203350 <pgdir_alloc_page+0x68>
        if (swap_init_ok) {
ffffffffc0203312:	000c6797          	auipc	a5,0xc6
ffffffffc0203316:	00678793          	addi	a5,a5,6 # ffffffffc02c9318 <swap_init_ok>
ffffffffc020331a:	439c                	lw	a5,0(a5)
ffffffffc020331c:	2781                	sext.w	a5,a5
ffffffffc020331e:	c38d                	beqz	a5,ffffffffc0203340 <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc0203320:	000c6797          	auipc	a5,0xc6
ffffffffc0203324:	14878793          	addi	a5,a5,328 # ffffffffc02c9468 <check_mm_struct>
ffffffffc0203328:	6388                	ld	a0,0(a5)
ffffffffc020332a:	c919                	beqz	a0,ffffffffc0203340 <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc020332c:	4681                	li	a3,0
ffffffffc020332e:	8622                	mv	a2,s0
ffffffffc0203330:	85a6                	mv	a1,s1
ffffffffc0203332:	7da000ef          	jal	ra,ffffffffc0203b0c <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0203336:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0203338:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc020333a:	4785                	li	a5,1
ffffffffc020333c:	02f71063          	bne	a4,a5,ffffffffc020335c <pgdir_alloc_page+0x74>
}
ffffffffc0203340:	8522                	mv	a0,s0
ffffffffc0203342:	70a2                	ld	ra,40(sp)
ffffffffc0203344:	7402                	ld	s0,32(sp)
ffffffffc0203346:	64e2                	ld	s1,24(sp)
ffffffffc0203348:	6942                	ld	s2,16(sp)
ffffffffc020334a:	69a2                	ld	s3,8(sp)
ffffffffc020334c:	6145                	addi	sp,sp,48
ffffffffc020334e:	8082                	ret
            free_page(page);
ffffffffc0203350:	8522                	mv	a0,s0
ffffffffc0203352:	4585                	li	a1,1
ffffffffc0203354:	b77fe0ef          	jal	ra,ffffffffc0201eca <free_pages>
            return NULL;
ffffffffc0203358:	4401                	li	s0,0
ffffffffc020335a:	b7dd                	j	ffffffffc0203340 <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc020335c:	00007697          	auipc	a3,0x7
ffffffffc0203360:	c9468693          	addi	a3,a3,-876 # ffffffffc0209ff0 <default_pmm_manager+0x180>
ffffffffc0203364:	00006617          	auipc	a2,0x6
ffffffffc0203368:	3c460613          	addi	a2,a2,964 # ffffffffc0209728 <commands+0x4c0>
ffffffffc020336c:	1fa00593          	li	a1,506
ffffffffc0203370:	00007517          	auipc	a0,0x7
ffffffffc0203374:	c7050513          	addi	a0,a0,-912 # ffffffffc0209fe0 <default_pmm_manager+0x170>
ffffffffc0203378:	910fd0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020337c <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020337c:	7135                	addi	sp,sp,-160
ffffffffc020337e:	ed06                	sd	ra,152(sp)
ffffffffc0203380:	e922                	sd	s0,144(sp)
ffffffffc0203382:	e526                	sd	s1,136(sp)
ffffffffc0203384:	e14a                	sd	s2,128(sp)
ffffffffc0203386:	fcce                	sd	s3,120(sp)
ffffffffc0203388:	f8d2                	sd	s4,112(sp)
ffffffffc020338a:	f4d6                	sd	s5,104(sp)
ffffffffc020338c:	f0da                	sd	s6,96(sp)
ffffffffc020338e:	ecde                	sd	s7,88(sp)
ffffffffc0203390:	e8e2                	sd	s8,80(sp)
ffffffffc0203392:	e4e6                	sd	s9,72(sp)
ffffffffc0203394:	e0ea                	sd	s10,64(sp)
ffffffffc0203396:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0203398:	79c010ef          	jal	ra,ffffffffc0204b34 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020339c:	000c6797          	auipc	a5,0xc6
ffffffffc02033a0:	07c78793          	addi	a5,a5,124 # ffffffffc02c9418 <max_swap_offset>
ffffffffc02033a4:	6394                	ld	a3,0(a5)
ffffffffc02033a6:	010007b7          	lui	a5,0x1000
ffffffffc02033aa:	17e1                	addi	a5,a5,-8
ffffffffc02033ac:	ff968713          	addi	a4,a3,-7
ffffffffc02033b0:	4ae7ee63          	bltu	a5,a4,ffffffffc020386c <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc02033b4:	000bb797          	auipc	a5,0xbb
ffffffffc02033b8:	a8c78793          	addi	a5,a5,-1396 # ffffffffc02bde40 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02033bc:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02033be:	000c6697          	auipc	a3,0xc6
ffffffffc02033c2:	f4f6b923          	sd	a5,-174(a3) # ffffffffc02c9310 <sm>
     int r = sm->init();
ffffffffc02033c6:	9702                	jalr	a4
ffffffffc02033c8:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc02033ca:	c10d                	beqz	a0,ffffffffc02033ec <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02033cc:	60ea                	ld	ra,152(sp)
ffffffffc02033ce:	644a                	ld	s0,144(sp)
ffffffffc02033d0:	8556                	mv	a0,s5
ffffffffc02033d2:	64aa                	ld	s1,136(sp)
ffffffffc02033d4:	690a                	ld	s2,128(sp)
ffffffffc02033d6:	79e6                	ld	s3,120(sp)
ffffffffc02033d8:	7a46                	ld	s4,112(sp)
ffffffffc02033da:	7aa6                	ld	s5,104(sp)
ffffffffc02033dc:	7b06                	ld	s6,96(sp)
ffffffffc02033de:	6be6                	ld	s7,88(sp)
ffffffffc02033e0:	6c46                	ld	s8,80(sp)
ffffffffc02033e2:	6ca6                	ld	s9,72(sp)
ffffffffc02033e4:	6d06                	ld	s10,64(sp)
ffffffffc02033e6:	7de2                	ld	s11,56(sp)
ffffffffc02033e8:	610d                	addi	sp,sp,160
ffffffffc02033ea:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02033ec:	000c6797          	auipc	a5,0xc6
ffffffffc02033f0:	f2478793          	addi	a5,a5,-220 # ffffffffc02c9310 <sm>
ffffffffc02033f4:	639c                	ld	a5,0(a5)
ffffffffc02033f6:	00007517          	auipc	a0,0x7
ffffffffc02033fa:	22a50513          	addi	a0,a0,554 # ffffffffc020a620 <default_pmm_manager+0x7b0>
    return listelm->next;
ffffffffc02033fe:	000c6417          	auipc	s0,0xc6
ffffffffc0203402:	f5a40413          	addi	s0,s0,-166 # ffffffffc02c9358 <free_area>
ffffffffc0203406:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0203408:	4785                	li	a5,1
ffffffffc020340a:	000c6717          	auipc	a4,0xc6
ffffffffc020340e:	f0f72723          	sw	a5,-242(a4) # ffffffffc02c9318 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203412:	d81fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc0203416:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203418:	36878e63          	beq	a5,s0,ffffffffc0203794 <swap_init+0x418>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020341c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203420:	8305                	srli	a4,a4,0x1
ffffffffc0203422:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203424:	36070c63          	beqz	a4,ffffffffc020379c <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc0203428:	4481                	li	s1,0
ffffffffc020342a:	4901                	li	s2,0
ffffffffc020342c:	a031                	j	ffffffffc0203438 <swap_init+0xbc>
ffffffffc020342e:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0203432:	8b09                	andi	a4,a4,2
ffffffffc0203434:	36070463          	beqz	a4,ffffffffc020379c <swap_init+0x420>
        count ++, total += p->property;
ffffffffc0203438:	ff87a703          	lw	a4,-8(a5)
ffffffffc020343c:	679c                	ld	a5,8(a5)
ffffffffc020343e:	2905                	addiw	s2,s2,1
ffffffffc0203440:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203442:	fe8796e3          	bne	a5,s0,ffffffffc020342e <swap_init+0xb2>
ffffffffc0203446:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0203448:	ac9fe0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>
ffffffffc020344c:	69351863          	bne	a0,s3,ffffffffc0203adc <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0203450:	8626                	mv	a2,s1
ffffffffc0203452:	85ca                	mv	a1,s2
ffffffffc0203454:	00007517          	auipc	a0,0x7
ffffffffc0203458:	1e450513          	addi	a0,a0,484 # ffffffffc020a638 <default_pmm_manager+0x7c8>
ffffffffc020345c:	d37fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0203460:	457000ef          	jal	ra,ffffffffc02040b6 <mm_create>
ffffffffc0203464:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0203466:	60050b63          	beqz	a0,ffffffffc0203a7c <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020346a:	000c6797          	auipc	a5,0xc6
ffffffffc020346e:	ffe78793          	addi	a5,a5,-2 # ffffffffc02c9468 <check_mm_struct>
ffffffffc0203472:	639c                	ld	a5,0(a5)
ffffffffc0203474:	62079463          	bnez	a5,ffffffffc0203a9c <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203478:	000c6797          	auipc	a5,0xc6
ffffffffc020347c:	e8878793          	addi	a5,a5,-376 # ffffffffc02c9300 <boot_pgdir>
ffffffffc0203480:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0203484:	000c6797          	auipc	a5,0xc6
ffffffffc0203488:	fea7b223          	sd	a0,-28(a5) # ffffffffc02c9468 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020348c:	000b3783          	ld	a5,0(s6) # 80000 <_binary_obj___user_matrix_out_size+0x74590>
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203490:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0203494:	4e079863          	bnez	a5,ffffffffc0203984 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0203498:	6599                	lui	a1,0x6
ffffffffc020349a:	460d                	li	a2,3
ffffffffc020349c:	6505                	lui	a0,0x1
ffffffffc020349e:	465000ef          	jal	ra,ffffffffc0204102 <vma_create>
ffffffffc02034a2:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02034a4:	50050063          	beqz	a0,ffffffffc02039a4 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc02034a8:	855e                	mv	a0,s7
ffffffffc02034aa:	4c5000ef          	jal	ra,ffffffffc020416e <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02034ae:	00007517          	auipc	a0,0x7
ffffffffc02034b2:	1fa50513          	addi	a0,a0,506 # ffffffffc020a6a8 <default_pmm_manager+0x838>
ffffffffc02034b6:	cddfc0ef          	jal	ra,ffffffffc0200192 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02034ba:	018bb503          	ld	a0,24(s7)
ffffffffc02034be:	4605                	li	a2,1
ffffffffc02034c0:	6585                	lui	a1,0x1
ffffffffc02034c2:	a8ffe0ef          	jal	ra,ffffffffc0201f50 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02034c6:	4e050f63          	beqz	a0,ffffffffc02039c4 <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02034ca:	00007517          	auipc	a0,0x7
ffffffffc02034ce:	22e50513          	addi	a0,a0,558 # ffffffffc020a6f8 <default_pmm_manager+0x888>
ffffffffc02034d2:	000c6997          	auipc	s3,0xc6
ffffffffc02034d6:	ebe98993          	addi	s3,s3,-322 # ffffffffc02c9390 <check_rp>
ffffffffc02034da:	cb9fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02034de:	000c6a17          	auipc	s4,0xc6
ffffffffc02034e2:	ed2a0a13          	addi	s4,s4,-302 # ffffffffc02c93b0 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02034e6:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc02034e8:	4505                	li	a0,1
ffffffffc02034ea:	959fe0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc02034ee:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc02034f2:	32050d63          	beqz	a0,ffffffffc020382c <swap_init+0x4b0>
ffffffffc02034f6:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02034f8:	8b89                	andi	a5,a5,2
ffffffffc02034fa:	30079963          	bnez	a5,ffffffffc020380c <swap_init+0x490>
ffffffffc02034fe:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203500:	ff4c14e3          	bne	s8,s4,ffffffffc02034e8 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0203504:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0203506:	000c6c17          	auipc	s8,0xc6
ffffffffc020350a:	e8ac0c13          	addi	s8,s8,-374 # ffffffffc02c9390 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc020350e:	ec3e                	sd	a5,24(sp)
ffffffffc0203510:	641c                	ld	a5,8(s0)
ffffffffc0203512:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0203514:	481c                	lw	a5,16(s0)
ffffffffc0203516:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0203518:	000c6797          	auipc	a5,0xc6
ffffffffc020351c:	e487b423          	sd	s0,-440(a5) # ffffffffc02c9360 <free_area+0x8>
ffffffffc0203520:	000c6797          	auipc	a5,0xc6
ffffffffc0203524:	e287bc23          	sd	s0,-456(a5) # ffffffffc02c9358 <free_area>
     nr_free = 0;
ffffffffc0203528:	000c6797          	auipc	a5,0xc6
ffffffffc020352c:	e407a023          	sw	zero,-448(a5) # ffffffffc02c9368 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0203530:	000c3503          	ld	a0,0(s8)
ffffffffc0203534:	4585                	li	a1,1
ffffffffc0203536:	0c21                	addi	s8,s8,8
ffffffffc0203538:	993fe0ef          	jal	ra,ffffffffc0201eca <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020353c:	ff4c1ae3          	bne	s8,s4,ffffffffc0203530 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203540:	01042c03          	lw	s8,16(s0)
ffffffffc0203544:	4791                	li	a5,4
ffffffffc0203546:	50fc1b63          	bne	s8,a5,ffffffffc0203a5c <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020354a:	00007517          	auipc	a0,0x7
ffffffffc020354e:	23650513          	addi	a0,a0,566 # ffffffffc020a780 <default_pmm_manager+0x910>
ffffffffc0203552:	c41fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203556:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0203558:	000c6797          	auipc	a5,0xc6
ffffffffc020355c:	dc07a223          	sw	zero,-572(a5) # ffffffffc02c931c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203560:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0203562:	000c6797          	auipc	a5,0xc6
ffffffffc0203566:	dba78793          	addi	a5,a5,-582 # ffffffffc02c931c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020356a:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x8908>
     assert(pgfault_num==1);
ffffffffc020356e:	4398                	lw	a4,0(a5)
ffffffffc0203570:	4585                	li	a1,1
ffffffffc0203572:	2701                	sext.w	a4,a4
ffffffffc0203574:	38b71863          	bne	a4,a1,ffffffffc0203904 <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0203578:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc020357c:	4394                	lw	a3,0(a5)
ffffffffc020357e:	2681                	sext.w	a3,a3
ffffffffc0203580:	3ae69263          	bne	a3,a4,ffffffffc0203924 <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203584:	6689                	lui	a3,0x2
ffffffffc0203586:	462d                	li	a2,11
ffffffffc0203588:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7908>
     assert(pgfault_num==2);
ffffffffc020358c:	4398                	lw	a4,0(a5)
ffffffffc020358e:	4589                	li	a1,2
ffffffffc0203590:	2701                	sext.w	a4,a4
ffffffffc0203592:	2eb71963          	bne	a4,a1,ffffffffc0203884 <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0203596:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc020359a:	4394                	lw	a3,0(a5)
ffffffffc020359c:	2681                	sext.w	a3,a3
ffffffffc020359e:	30e69363          	bne	a3,a4,ffffffffc02038a4 <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02035a2:	668d                	lui	a3,0x3
ffffffffc02035a4:	4631                	li	a2,12
ffffffffc02035a6:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6908>
     assert(pgfault_num==3);
ffffffffc02035aa:	4398                	lw	a4,0(a5)
ffffffffc02035ac:	458d                	li	a1,3
ffffffffc02035ae:	2701                	sext.w	a4,a4
ffffffffc02035b0:	30b71a63          	bne	a4,a1,ffffffffc02038c4 <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02035b4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02035b8:	4394                	lw	a3,0(a5)
ffffffffc02035ba:	2681                	sext.w	a3,a3
ffffffffc02035bc:	32e69463          	bne	a3,a4,ffffffffc02038e4 <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02035c0:	6691                	lui	a3,0x4
ffffffffc02035c2:	4635                	li	a2,13
ffffffffc02035c4:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5908>
     assert(pgfault_num==4);
ffffffffc02035c8:	4398                	lw	a4,0(a5)
ffffffffc02035ca:	2701                	sext.w	a4,a4
ffffffffc02035cc:	37871c63          	bne	a4,s8,ffffffffc0203944 <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02035d0:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02035d4:	439c                	lw	a5,0(a5)
ffffffffc02035d6:	2781                	sext.w	a5,a5
ffffffffc02035d8:	38e79663          	bne	a5,a4,ffffffffc0203964 <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02035dc:	481c                	lw	a5,16(s0)
ffffffffc02035de:	40079363          	bnez	a5,ffffffffc02039e4 <swap_init+0x668>
ffffffffc02035e2:	000c6797          	auipc	a5,0xc6
ffffffffc02035e6:	dce78793          	addi	a5,a5,-562 # ffffffffc02c93b0 <swap_in_seq_no>
ffffffffc02035ea:	000c6717          	auipc	a4,0xc6
ffffffffc02035ee:	dee70713          	addi	a4,a4,-530 # ffffffffc02c93d8 <swap_out_seq_no>
ffffffffc02035f2:	000c6617          	auipc	a2,0xc6
ffffffffc02035f6:	de660613          	addi	a2,a2,-538 # ffffffffc02c93d8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02035fa:	56fd                	li	a3,-1
ffffffffc02035fc:	c394                	sw	a3,0(a5)
ffffffffc02035fe:	c314                	sw	a3,0(a4)
ffffffffc0203600:	0791                	addi	a5,a5,4
ffffffffc0203602:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0203604:	fef61ce3          	bne	a2,a5,ffffffffc02035fc <swap_init+0x280>
ffffffffc0203608:	000c6697          	auipc	a3,0xc6
ffffffffc020360c:	e3068693          	addi	a3,a3,-464 # ffffffffc02c9438 <check_ptep>
ffffffffc0203610:	000c6817          	auipc	a6,0xc6
ffffffffc0203614:	d8080813          	addi	a6,a6,-640 # ffffffffc02c9390 <check_rp>
ffffffffc0203618:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc020361a:	000c6c97          	auipc	s9,0xc6
ffffffffc020361e:	ceec8c93          	addi	s9,s9,-786 # ffffffffc02c9308 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203622:	00009d97          	auipc	s11,0x9
ffffffffc0203626:	956d8d93          	addi	s11,s11,-1706 # ffffffffc020bf78 <nbase>
ffffffffc020362a:	000c6c17          	auipc	s8,0xc6
ffffffffc020362e:	d5ec0c13          	addi	s8,s8,-674 # ffffffffc02c9388 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0203632:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203636:	4601                	li	a2,0
ffffffffc0203638:	85ea                	mv	a1,s10
ffffffffc020363a:	855a                	mv	a0,s6
ffffffffc020363c:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc020363e:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203640:	911fe0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc0203644:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203646:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203648:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc020364a:	20050163          	beqz	a0,ffffffffc020384c <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020364e:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203650:	0017f613          	andi	a2,a5,1
ffffffffc0203654:	1a060063          	beqz	a2,ffffffffc02037f4 <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc0203658:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020365c:	078a                	slli	a5,a5,0x2
ffffffffc020365e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203660:	14c7fe63          	bleu	a2,a5,ffffffffc02037bc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203664:	000db703          	ld	a4,0(s11)
ffffffffc0203668:	000c3603          	ld	a2,0(s8)
ffffffffc020366c:	00083583          	ld	a1,0(a6)
ffffffffc0203670:	8f99                	sub	a5,a5,a4
ffffffffc0203672:	079a                	slli	a5,a5,0x6
ffffffffc0203674:	e43a                	sd	a4,8(sp)
ffffffffc0203676:	97b2                	add	a5,a5,a2
ffffffffc0203678:	14f59e63          	bne	a1,a5,ffffffffc02037d4 <swap_init+0x458>
ffffffffc020367c:	6785                	lui	a5,0x1
ffffffffc020367e:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203680:	6795                	lui	a5,0x5
ffffffffc0203682:	06a1                	addi	a3,a3,8
ffffffffc0203684:	0821                	addi	a6,a6,8
ffffffffc0203686:	fafd16e3          	bne	s10,a5,ffffffffc0203632 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc020368a:	00007517          	auipc	a0,0x7
ffffffffc020368e:	19e50513          	addi	a0,a0,414 # ffffffffc020a828 <default_pmm_manager+0x9b8>
ffffffffc0203692:	b01fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    int ret = sm->check_swap();
ffffffffc0203696:	000c6797          	auipc	a5,0xc6
ffffffffc020369a:	c7a78793          	addi	a5,a5,-902 # ffffffffc02c9310 <sm>
ffffffffc020369e:	639c                	ld	a5,0(a5)
ffffffffc02036a0:	7f9c                	ld	a5,56(a5)
ffffffffc02036a2:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02036a4:	40051c63          	bnez	a0,ffffffffc0203abc <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc02036a8:	77a2                	ld	a5,40(sp)
ffffffffc02036aa:	000c6717          	auipc	a4,0xc6
ffffffffc02036ae:	caf72f23          	sw	a5,-834(a4) # ffffffffc02c9368 <free_area+0x10>
     free_list = free_list_store;
ffffffffc02036b2:	67e2                	ld	a5,24(sp)
ffffffffc02036b4:	000c6717          	auipc	a4,0xc6
ffffffffc02036b8:	caf73223          	sd	a5,-860(a4) # ffffffffc02c9358 <free_area>
ffffffffc02036bc:	7782                	ld	a5,32(sp)
ffffffffc02036be:	000c6717          	auipc	a4,0xc6
ffffffffc02036c2:	caf73123          	sd	a5,-862(a4) # ffffffffc02c9360 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02036c6:	0009b503          	ld	a0,0(s3)
ffffffffc02036ca:	4585                	li	a1,1
ffffffffc02036cc:	09a1                	addi	s3,s3,8
ffffffffc02036ce:	ffcfe0ef          	jal	ra,ffffffffc0201eca <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02036d2:	ff499ae3          	bne	s3,s4,ffffffffc02036c6 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc02036d6:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc02036da:	855e                	mv	a0,s7
ffffffffc02036dc:	361000ef          	jal	ra,ffffffffc020423c <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02036e0:	000c6797          	auipc	a5,0xc6
ffffffffc02036e4:	c2078793          	addi	a5,a5,-992 # ffffffffc02c9300 <boot_pgdir>
ffffffffc02036e8:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc02036ea:	000c6697          	auipc	a3,0xc6
ffffffffc02036ee:	d606bf23          	sd	zero,-642(a3) # ffffffffc02c9468 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc02036f2:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc02036f6:	6394                	ld	a3,0(a5)
ffffffffc02036f8:	068a                	slli	a3,a3,0x2
ffffffffc02036fa:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036fc:	0ce6f063          	bleu	a4,a3,ffffffffc02037bc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203700:	67a2                	ld	a5,8(sp)
ffffffffc0203702:	000c3503          	ld	a0,0(s8)
ffffffffc0203706:	8e9d                	sub	a3,a3,a5
ffffffffc0203708:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc020370a:	8699                	srai	a3,a3,0x6
ffffffffc020370c:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020370e:	57fd                	li	a5,-1
ffffffffc0203710:	83b1                	srli	a5,a5,0xc
ffffffffc0203712:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203714:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203716:	2ee7f763          	bleu	a4,a5,ffffffffc0203a04 <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc020371a:	000c6797          	auipc	a5,0xc6
ffffffffc020371e:	c5e78793          	addi	a5,a5,-930 # ffffffffc02c9378 <va_pa_offset>
ffffffffc0203722:	639c                	ld	a5,0(a5)
ffffffffc0203724:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203726:	629c                	ld	a5,0(a3)
ffffffffc0203728:	078a                	slli	a5,a5,0x2
ffffffffc020372a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020372c:	08e7f863          	bleu	a4,a5,ffffffffc02037bc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203730:	69a2                	ld	s3,8(sp)
ffffffffc0203732:	4585                	li	a1,1
ffffffffc0203734:	413787b3          	sub	a5,a5,s3
ffffffffc0203738:	079a                	slli	a5,a5,0x6
ffffffffc020373a:	953e                	add	a0,a0,a5
ffffffffc020373c:	f8efe0ef          	jal	ra,ffffffffc0201eca <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203740:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203744:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203748:	078a                	slli	a5,a5,0x2
ffffffffc020374a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020374c:	06e7f863          	bleu	a4,a5,ffffffffc02037bc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203750:	000c3503          	ld	a0,0(s8)
ffffffffc0203754:	413787b3          	sub	a5,a5,s3
ffffffffc0203758:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc020375a:	4585                	li	a1,1
ffffffffc020375c:	953e                	add	a0,a0,a5
ffffffffc020375e:	f6cfe0ef          	jal	ra,ffffffffc0201eca <free_pages>
     pgdir[0] = 0;
ffffffffc0203762:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203766:	12000073          	sfence.vma
    return listelm->next;
ffffffffc020376a:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020376c:	00878963          	beq	a5,s0,ffffffffc020377e <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203770:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203774:	679c                	ld	a5,8(a5)
ffffffffc0203776:	397d                	addiw	s2,s2,-1
ffffffffc0203778:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020377a:	fe879be3          	bne	a5,s0,ffffffffc0203770 <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc020377e:	28091f63          	bnez	s2,ffffffffc0203a1c <swap_init+0x6a0>
     assert(total==0);
ffffffffc0203782:	2a049d63          	bnez	s1,ffffffffc0203a3c <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc0203786:	00007517          	auipc	a0,0x7
ffffffffc020378a:	0f250513          	addi	a0,a0,242 # ffffffffc020a878 <default_pmm_manager+0xa08>
ffffffffc020378e:	a05fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc0203792:	b92d                	j	ffffffffc02033cc <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0203794:	4481                	li	s1,0
ffffffffc0203796:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203798:	4981                	li	s3,0
ffffffffc020379a:	b17d                	j	ffffffffc0203448 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc020379c:	00006697          	auipc	a3,0x6
ffffffffc02037a0:	34468693          	addi	a3,a3,836 # ffffffffc0209ae0 <commands+0x878>
ffffffffc02037a4:	00006617          	auipc	a2,0x6
ffffffffc02037a8:	f8460613          	addi	a2,a2,-124 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02037ac:	0bc00593          	li	a1,188
ffffffffc02037b0:	00007517          	auipc	a0,0x7
ffffffffc02037b4:	e6050513          	addi	a0,a0,-416 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc02037b8:	cd1fc0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02037bc:	00006617          	auipc	a2,0x6
ffffffffc02037c0:	76460613          	addi	a2,a2,1892 # ffffffffc0209f20 <default_pmm_manager+0xb0>
ffffffffc02037c4:	06200593          	li	a1,98
ffffffffc02037c8:	00006517          	auipc	a0,0x6
ffffffffc02037cc:	72050513          	addi	a0,a0,1824 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc02037d0:	cb9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02037d4:	00007697          	auipc	a3,0x7
ffffffffc02037d8:	02c68693          	addi	a3,a3,44 # ffffffffc020a800 <default_pmm_manager+0x990>
ffffffffc02037dc:	00006617          	auipc	a2,0x6
ffffffffc02037e0:	f4c60613          	addi	a2,a2,-180 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02037e4:	0fc00593          	li	a1,252
ffffffffc02037e8:	00007517          	auipc	a0,0x7
ffffffffc02037ec:	e2850513          	addi	a0,a0,-472 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc02037f0:	c99fc0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02037f4:	00007617          	auipc	a2,0x7
ffffffffc02037f8:	98460613          	addi	a2,a2,-1660 # ffffffffc020a178 <default_pmm_manager+0x308>
ffffffffc02037fc:	07400593          	li	a1,116
ffffffffc0203800:	00006517          	auipc	a0,0x6
ffffffffc0203804:	6e850513          	addi	a0,a0,1768 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc0203808:	c81fc0ef          	jal	ra,ffffffffc0200488 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc020380c:	00007697          	auipc	a3,0x7
ffffffffc0203810:	f2c68693          	addi	a3,a3,-212 # ffffffffc020a738 <default_pmm_manager+0x8c8>
ffffffffc0203814:	00006617          	auipc	a2,0x6
ffffffffc0203818:	f1460613          	addi	a2,a2,-236 # ffffffffc0209728 <commands+0x4c0>
ffffffffc020381c:	0dd00593          	li	a1,221
ffffffffc0203820:	00007517          	auipc	a0,0x7
ffffffffc0203824:	df050513          	addi	a0,a0,-528 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc0203828:	c61fc0ef          	jal	ra,ffffffffc0200488 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc020382c:	00007697          	auipc	a3,0x7
ffffffffc0203830:	ef468693          	addi	a3,a3,-268 # ffffffffc020a720 <default_pmm_manager+0x8b0>
ffffffffc0203834:	00006617          	auipc	a2,0x6
ffffffffc0203838:	ef460613          	addi	a2,a2,-268 # ffffffffc0209728 <commands+0x4c0>
ffffffffc020383c:	0dc00593          	li	a1,220
ffffffffc0203840:	00007517          	auipc	a0,0x7
ffffffffc0203844:	dd050513          	addi	a0,a0,-560 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc0203848:	c41fc0ef          	jal	ra,ffffffffc0200488 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc020384c:	00007697          	auipc	a3,0x7
ffffffffc0203850:	f9c68693          	addi	a3,a3,-100 # ffffffffc020a7e8 <default_pmm_manager+0x978>
ffffffffc0203854:	00006617          	auipc	a2,0x6
ffffffffc0203858:	ed460613          	addi	a2,a2,-300 # ffffffffc0209728 <commands+0x4c0>
ffffffffc020385c:	0fb00593          	li	a1,251
ffffffffc0203860:	00007517          	auipc	a0,0x7
ffffffffc0203864:	db050513          	addi	a0,a0,-592 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc0203868:	c21fc0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020386c:	00007617          	auipc	a2,0x7
ffffffffc0203870:	d8460613          	addi	a2,a2,-636 # ffffffffc020a5f0 <default_pmm_manager+0x780>
ffffffffc0203874:	02800593          	li	a1,40
ffffffffc0203878:	00007517          	auipc	a0,0x7
ffffffffc020387c:	d9850513          	addi	a0,a0,-616 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc0203880:	c09fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==2);
ffffffffc0203884:	00007697          	auipc	a3,0x7
ffffffffc0203888:	f3468693          	addi	a3,a3,-204 # ffffffffc020a7b8 <default_pmm_manager+0x948>
ffffffffc020388c:	00006617          	auipc	a2,0x6
ffffffffc0203890:	e9c60613          	addi	a2,a2,-356 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203894:	09700593          	li	a1,151
ffffffffc0203898:	00007517          	auipc	a0,0x7
ffffffffc020389c:	d7850513          	addi	a0,a0,-648 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc02038a0:	be9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==2);
ffffffffc02038a4:	00007697          	auipc	a3,0x7
ffffffffc02038a8:	f1468693          	addi	a3,a3,-236 # ffffffffc020a7b8 <default_pmm_manager+0x948>
ffffffffc02038ac:	00006617          	auipc	a2,0x6
ffffffffc02038b0:	e7c60613          	addi	a2,a2,-388 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02038b4:	09900593          	li	a1,153
ffffffffc02038b8:	00007517          	auipc	a0,0x7
ffffffffc02038bc:	d5850513          	addi	a0,a0,-680 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc02038c0:	bc9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==3);
ffffffffc02038c4:	00007697          	auipc	a3,0x7
ffffffffc02038c8:	f0468693          	addi	a3,a3,-252 # ffffffffc020a7c8 <default_pmm_manager+0x958>
ffffffffc02038cc:	00006617          	auipc	a2,0x6
ffffffffc02038d0:	e5c60613          	addi	a2,a2,-420 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02038d4:	09b00593          	li	a1,155
ffffffffc02038d8:	00007517          	auipc	a0,0x7
ffffffffc02038dc:	d3850513          	addi	a0,a0,-712 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc02038e0:	ba9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==3);
ffffffffc02038e4:	00007697          	auipc	a3,0x7
ffffffffc02038e8:	ee468693          	addi	a3,a3,-284 # ffffffffc020a7c8 <default_pmm_manager+0x958>
ffffffffc02038ec:	00006617          	auipc	a2,0x6
ffffffffc02038f0:	e3c60613          	addi	a2,a2,-452 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02038f4:	09d00593          	li	a1,157
ffffffffc02038f8:	00007517          	auipc	a0,0x7
ffffffffc02038fc:	d1850513          	addi	a0,a0,-744 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc0203900:	b89fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==1);
ffffffffc0203904:	00007697          	auipc	a3,0x7
ffffffffc0203908:	ea468693          	addi	a3,a3,-348 # ffffffffc020a7a8 <default_pmm_manager+0x938>
ffffffffc020390c:	00006617          	auipc	a2,0x6
ffffffffc0203910:	e1c60613          	addi	a2,a2,-484 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203914:	09300593          	li	a1,147
ffffffffc0203918:	00007517          	auipc	a0,0x7
ffffffffc020391c:	cf850513          	addi	a0,a0,-776 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc0203920:	b69fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==1);
ffffffffc0203924:	00007697          	auipc	a3,0x7
ffffffffc0203928:	e8468693          	addi	a3,a3,-380 # ffffffffc020a7a8 <default_pmm_manager+0x938>
ffffffffc020392c:	00006617          	auipc	a2,0x6
ffffffffc0203930:	dfc60613          	addi	a2,a2,-516 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203934:	09500593          	li	a1,149
ffffffffc0203938:	00007517          	auipc	a0,0x7
ffffffffc020393c:	cd850513          	addi	a0,a0,-808 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc0203940:	b49fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==4);
ffffffffc0203944:	00007697          	auipc	a3,0x7
ffffffffc0203948:	e9468693          	addi	a3,a3,-364 # ffffffffc020a7d8 <default_pmm_manager+0x968>
ffffffffc020394c:	00006617          	auipc	a2,0x6
ffffffffc0203950:	ddc60613          	addi	a2,a2,-548 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203954:	09f00593          	li	a1,159
ffffffffc0203958:	00007517          	auipc	a0,0x7
ffffffffc020395c:	cb850513          	addi	a0,a0,-840 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc0203960:	b29fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==4);
ffffffffc0203964:	00007697          	auipc	a3,0x7
ffffffffc0203968:	e7468693          	addi	a3,a3,-396 # ffffffffc020a7d8 <default_pmm_manager+0x968>
ffffffffc020396c:	00006617          	auipc	a2,0x6
ffffffffc0203970:	dbc60613          	addi	a2,a2,-580 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203974:	0a100593          	li	a1,161
ffffffffc0203978:	00007517          	auipc	a0,0x7
ffffffffc020397c:	c9850513          	addi	a0,a0,-872 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc0203980:	b09fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203984:	00007697          	auipc	a3,0x7
ffffffffc0203988:	d0468693          	addi	a3,a3,-764 # ffffffffc020a688 <default_pmm_manager+0x818>
ffffffffc020398c:	00006617          	auipc	a2,0x6
ffffffffc0203990:	d9c60613          	addi	a2,a2,-612 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203994:	0cc00593          	li	a1,204
ffffffffc0203998:	00007517          	auipc	a0,0x7
ffffffffc020399c:	c7850513          	addi	a0,a0,-904 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc02039a0:	ae9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(vma != NULL);
ffffffffc02039a4:	00007697          	auipc	a3,0x7
ffffffffc02039a8:	cf468693          	addi	a3,a3,-780 # ffffffffc020a698 <default_pmm_manager+0x828>
ffffffffc02039ac:	00006617          	auipc	a2,0x6
ffffffffc02039b0:	d7c60613          	addi	a2,a2,-644 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02039b4:	0cf00593          	li	a1,207
ffffffffc02039b8:	00007517          	auipc	a0,0x7
ffffffffc02039bc:	c5850513          	addi	a0,a0,-936 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc02039c0:	ac9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02039c4:	00007697          	auipc	a3,0x7
ffffffffc02039c8:	d1c68693          	addi	a3,a3,-740 # ffffffffc020a6e0 <default_pmm_manager+0x870>
ffffffffc02039cc:	00006617          	auipc	a2,0x6
ffffffffc02039d0:	d5c60613          	addi	a2,a2,-676 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02039d4:	0d700593          	li	a1,215
ffffffffc02039d8:	00007517          	auipc	a0,0x7
ffffffffc02039dc:	c3850513          	addi	a0,a0,-968 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc02039e0:	aa9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert( nr_free == 0);         
ffffffffc02039e4:	00006697          	auipc	a3,0x6
ffffffffc02039e8:	2cc68693          	addi	a3,a3,716 # ffffffffc0209cb0 <commands+0xa48>
ffffffffc02039ec:	00006617          	auipc	a2,0x6
ffffffffc02039f0:	d3c60613          	addi	a2,a2,-708 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02039f4:	0f300593          	li	a1,243
ffffffffc02039f8:	00007517          	auipc	a0,0x7
ffffffffc02039fc:	c1850513          	addi	a0,a0,-1000 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc0203a00:	a89fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203a04:	00006617          	auipc	a2,0x6
ffffffffc0203a08:	4bc60613          	addi	a2,a2,1212 # ffffffffc0209ec0 <default_pmm_manager+0x50>
ffffffffc0203a0c:	06900593          	li	a1,105
ffffffffc0203a10:	00006517          	auipc	a0,0x6
ffffffffc0203a14:	4d850513          	addi	a0,a0,1240 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc0203a18:	a71fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(count==0);
ffffffffc0203a1c:	00007697          	auipc	a3,0x7
ffffffffc0203a20:	e3c68693          	addi	a3,a3,-452 # ffffffffc020a858 <default_pmm_manager+0x9e8>
ffffffffc0203a24:	00006617          	auipc	a2,0x6
ffffffffc0203a28:	d0460613          	addi	a2,a2,-764 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203a2c:	11d00593          	li	a1,285
ffffffffc0203a30:	00007517          	auipc	a0,0x7
ffffffffc0203a34:	be050513          	addi	a0,a0,-1056 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc0203a38:	a51fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(total==0);
ffffffffc0203a3c:	00007697          	auipc	a3,0x7
ffffffffc0203a40:	e2c68693          	addi	a3,a3,-468 # ffffffffc020a868 <default_pmm_manager+0x9f8>
ffffffffc0203a44:	00006617          	auipc	a2,0x6
ffffffffc0203a48:	ce460613          	addi	a2,a2,-796 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203a4c:	11e00593          	li	a1,286
ffffffffc0203a50:	00007517          	auipc	a0,0x7
ffffffffc0203a54:	bc050513          	addi	a0,a0,-1088 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc0203a58:	a31fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203a5c:	00007697          	auipc	a3,0x7
ffffffffc0203a60:	cfc68693          	addi	a3,a3,-772 # ffffffffc020a758 <default_pmm_manager+0x8e8>
ffffffffc0203a64:	00006617          	auipc	a2,0x6
ffffffffc0203a68:	cc460613          	addi	a2,a2,-828 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203a6c:	0ea00593          	li	a1,234
ffffffffc0203a70:	00007517          	auipc	a0,0x7
ffffffffc0203a74:	ba050513          	addi	a0,a0,-1120 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc0203a78:	a11fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(mm != NULL);
ffffffffc0203a7c:	00007697          	auipc	a3,0x7
ffffffffc0203a80:	be468693          	addi	a3,a3,-1052 # ffffffffc020a660 <default_pmm_manager+0x7f0>
ffffffffc0203a84:	00006617          	auipc	a2,0x6
ffffffffc0203a88:	ca460613          	addi	a2,a2,-860 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203a8c:	0c400593          	li	a1,196
ffffffffc0203a90:	00007517          	auipc	a0,0x7
ffffffffc0203a94:	b8050513          	addi	a0,a0,-1152 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc0203a98:	9f1fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203a9c:	00007697          	auipc	a3,0x7
ffffffffc0203aa0:	bd468693          	addi	a3,a3,-1068 # ffffffffc020a670 <default_pmm_manager+0x800>
ffffffffc0203aa4:	00006617          	auipc	a2,0x6
ffffffffc0203aa8:	c8460613          	addi	a2,a2,-892 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203aac:	0c700593          	li	a1,199
ffffffffc0203ab0:	00007517          	auipc	a0,0x7
ffffffffc0203ab4:	b6050513          	addi	a0,a0,-1184 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc0203ab8:	9d1fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(ret==0);
ffffffffc0203abc:	00007697          	auipc	a3,0x7
ffffffffc0203ac0:	d9468693          	addi	a3,a3,-620 # ffffffffc020a850 <default_pmm_manager+0x9e0>
ffffffffc0203ac4:	00006617          	auipc	a2,0x6
ffffffffc0203ac8:	c6460613          	addi	a2,a2,-924 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203acc:	10200593          	li	a1,258
ffffffffc0203ad0:	00007517          	auipc	a0,0x7
ffffffffc0203ad4:	b4050513          	addi	a0,a0,-1216 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc0203ad8:	9b1fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203adc:	00006697          	auipc	a3,0x6
ffffffffc0203ae0:	02c68693          	addi	a3,a3,44 # ffffffffc0209b08 <commands+0x8a0>
ffffffffc0203ae4:	00006617          	auipc	a2,0x6
ffffffffc0203ae8:	c4460613          	addi	a2,a2,-956 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203aec:	0bf00593          	li	a1,191
ffffffffc0203af0:	00007517          	auipc	a0,0x7
ffffffffc0203af4:	b2050513          	addi	a0,a0,-1248 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc0203af8:	991fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0203afc <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203afc:	000c6797          	auipc	a5,0xc6
ffffffffc0203b00:	81478793          	addi	a5,a5,-2028 # ffffffffc02c9310 <sm>
ffffffffc0203b04:	639c                	ld	a5,0(a5)
ffffffffc0203b06:	0107b303          	ld	t1,16(a5)
ffffffffc0203b0a:	8302                	jr	t1

ffffffffc0203b0c <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203b0c:	000c6797          	auipc	a5,0xc6
ffffffffc0203b10:	80478793          	addi	a5,a5,-2044 # ffffffffc02c9310 <sm>
ffffffffc0203b14:	639c                	ld	a5,0(a5)
ffffffffc0203b16:	0207b303          	ld	t1,32(a5)
ffffffffc0203b1a:	8302                	jr	t1

ffffffffc0203b1c <swap_out>:
{
ffffffffc0203b1c:	711d                	addi	sp,sp,-96
ffffffffc0203b1e:	ec86                	sd	ra,88(sp)
ffffffffc0203b20:	e8a2                	sd	s0,80(sp)
ffffffffc0203b22:	e4a6                	sd	s1,72(sp)
ffffffffc0203b24:	e0ca                	sd	s2,64(sp)
ffffffffc0203b26:	fc4e                	sd	s3,56(sp)
ffffffffc0203b28:	f852                	sd	s4,48(sp)
ffffffffc0203b2a:	f456                	sd	s5,40(sp)
ffffffffc0203b2c:	f05a                	sd	s6,32(sp)
ffffffffc0203b2e:	ec5e                	sd	s7,24(sp)
ffffffffc0203b30:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203b32:	cde9                	beqz	a1,ffffffffc0203c0c <swap_out+0xf0>
ffffffffc0203b34:	8ab2                	mv	s5,a2
ffffffffc0203b36:	892a                	mv	s2,a0
ffffffffc0203b38:	8a2e                	mv	s4,a1
ffffffffc0203b3a:	4401                	li	s0,0
ffffffffc0203b3c:	000c5997          	auipc	s3,0xc5
ffffffffc0203b40:	7d498993          	addi	s3,s3,2004 # ffffffffc02c9310 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b44:	00007b17          	auipc	s6,0x7
ffffffffc0203b48:	db4b0b13          	addi	s6,s6,-588 # ffffffffc020a8f8 <default_pmm_manager+0xa88>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203b4c:	00007b97          	auipc	s7,0x7
ffffffffc0203b50:	d94b8b93          	addi	s7,s7,-620 # ffffffffc020a8e0 <default_pmm_manager+0xa70>
ffffffffc0203b54:	a825                	j	ffffffffc0203b8c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b56:	67a2                	ld	a5,8(sp)
ffffffffc0203b58:	8626                	mv	a2,s1
ffffffffc0203b5a:	85a2                	mv	a1,s0
ffffffffc0203b5c:	7f94                	ld	a3,56(a5)
ffffffffc0203b5e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203b60:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b62:	82b1                	srli	a3,a3,0xc
ffffffffc0203b64:	0685                	addi	a3,a3,1
ffffffffc0203b66:	e2cfc0ef          	jal	ra,ffffffffc0200192 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b6a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203b6c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b6e:	7d1c                	ld	a5,56(a0)
ffffffffc0203b70:	83b1                	srli	a5,a5,0xc
ffffffffc0203b72:	0785                	addi	a5,a5,1
ffffffffc0203b74:	07a2                	slli	a5,a5,0x8
ffffffffc0203b76:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203b7a:	b50fe0ef          	jal	ra,ffffffffc0201eca <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203b7e:	01893503          	ld	a0,24(s2)
ffffffffc0203b82:	85a6                	mv	a1,s1
ffffffffc0203b84:	f5eff0ef          	jal	ra,ffffffffc02032e2 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203b88:	048a0d63          	beq	s4,s0,ffffffffc0203be2 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203b8c:	0009b783          	ld	a5,0(s3)
ffffffffc0203b90:	8656                	mv	a2,s5
ffffffffc0203b92:	002c                	addi	a1,sp,8
ffffffffc0203b94:	7b9c                	ld	a5,48(a5)
ffffffffc0203b96:	854a                	mv	a0,s2
ffffffffc0203b98:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203b9a:	e12d                	bnez	a0,ffffffffc0203bfc <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203b9c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203b9e:	01893503          	ld	a0,24(s2)
ffffffffc0203ba2:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203ba4:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203ba6:	85a6                	mv	a1,s1
ffffffffc0203ba8:	ba8fe0ef          	jal	ra,ffffffffc0201f50 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203bac:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203bae:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203bb0:	8b85                	andi	a5,a5,1
ffffffffc0203bb2:	cfb9                	beqz	a5,ffffffffc0203c10 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203bb4:	65a2                	ld	a1,8(sp)
ffffffffc0203bb6:	7d9c                	ld	a5,56(a1)
ffffffffc0203bb8:	83b1                	srli	a5,a5,0xc
ffffffffc0203bba:	00178513          	addi	a0,a5,1
ffffffffc0203bbe:	0522                	slli	a0,a0,0x8
ffffffffc0203bc0:	044010ef          	jal	ra,ffffffffc0204c04 <swapfs_write>
ffffffffc0203bc4:	d949                	beqz	a0,ffffffffc0203b56 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203bc6:	855e                	mv	a0,s7
ffffffffc0203bc8:	dcafc0ef          	jal	ra,ffffffffc0200192 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203bcc:	0009b783          	ld	a5,0(s3)
ffffffffc0203bd0:	6622                	ld	a2,8(sp)
ffffffffc0203bd2:	4681                	li	a3,0
ffffffffc0203bd4:	739c                	ld	a5,32(a5)
ffffffffc0203bd6:	85a6                	mv	a1,s1
ffffffffc0203bd8:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203bda:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203bdc:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203bde:	fa8a17e3          	bne	s4,s0,ffffffffc0203b8c <swap_out+0x70>
}
ffffffffc0203be2:	8522                	mv	a0,s0
ffffffffc0203be4:	60e6                	ld	ra,88(sp)
ffffffffc0203be6:	6446                	ld	s0,80(sp)
ffffffffc0203be8:	64a6                	ld	s1,72(sp)
ffffffffc0203bea:	6906                	ld	s2,64(sp)
ffffffffc0203bec:	79e2                	ld	s3,56(sp)
ffffffffc0203bee:	7a42                	ld	s4,48(sp)
ffffffffc0203bf0:	7aa2                	ld	s5,40(sp)
ffffffffc0203bf2:	7b02                	ld	s6,32(sp)
ffffffffc0203bf4:	6be2                	ld	s7,24(sp)
ffffffffc0203bf6:	6c42                	ld	s8,16(sp)
ffffffffc0203bf8:	6125                	addi	sp,sp,96
ffffffffc0203bfa:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203bfc:	85a2                	mv	a1,s0
ffffffffc0203bfe:	00007517          	auipc	a0,0x7
ffffffffc0203c02:	c9a50513          	addi	a0,a0,-870 # ffffffffc020a898 <default_pmm_manager+0xa28>
ffffffffc0203c06:	d8cfc0ef          	jal	ra,ffffffffc0200192 <cprintf>
                  break;
ffffffffc0203c0a:	bfe1                	j	ffffffffc0203be2 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203c0c:	4401                	li	s0,0
ffffffffc0203c0e:	bfd1                	j	ffffffffc0203be2 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c10:	00007697          	auipc	a3,0x7
ffffffffc0203c14:	cb868693          	addi	a3,a3,-840 # ffffffffc020a8c8 <default_pmm_manager+0xa58>
ffffffffc0203c18:	00006617          	auipc	a2,0x6
ffffffffc0203c1c:	b1060613          	addi	a2,a2,-1264 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203c20:	06800593          	li	a1,104
ffffffffc0203c24:	00007517          	auipc	a0,0x7
ffffffffc0203c28:	9ec50513          	addi	a0,a0,-1556 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc0203c2c:	85dfc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0203c30 <swap_in>:
{
ffffffffc0203c30:	7179                	addi	sp,sp,-48
ffffffffc0203c32:	e84a                	sd	s2,16(sp)
ffffffffc0203c34:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203c36:	4505                	li	a0,1
{
ffffffffc0203c38:	ec26                	sd	s1,24(sp)
ffffffffc0203c3a:	e44e                	sd	s3,8(sp)
ffffffffc0203c3c:	f406                	sd	ra,40(sp)
ffffffffc0203c3e:	f022                	sd	s0,32(sp)
ffffffffc0203c40:	84ae                	mv	s1,a1
ffffffffc0203c42:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203c44:	9fefe0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
     assert(result!=NULL);
ffffffffc0203c48:	c129                	beqz	a0,ffffffffc0203c8a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203c4a:	842a                	mv	s0,a0
ffffffffc0203c4c:	01893503          	ld	a0,24(s2)
ffffffffc0203c50:	4601                	li	a2,0
ffffffffc0203c52:	85a6                	mv	a1,s1
ffffffffc0203c54:	afcfe0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc0203c58:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203c5a:	6108                	ld	a0,0(a0)
ffffffffc0203c5c:	85a2                	mv	a1,s0
ffffffffc0203c5e:	70f000ef          	jal	ra,ffffffffc0204b6c <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203c62:	00093583          	ld	a1,0(s2)
ffffffffc0203c66:	8626                	mv	a2,s1
ffffffffc0203c68:	00007517          	auipc	a0,0x7
ffffffffc0203c6c:	94850513          	addi	a0,a0,-1720 # ffffffffc020a5b0 <default_pmm_manager+0x740>
ffffffffc0203c70:	81a1                	srli	a1,a1,0x8
ffffffffc0203c72:	d20fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
}
ffffffffc0203c76:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203c78:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203c7c:	7402                	ld	s0,32(sp)
ffffffffc0203c7e:	64e2                	ld	s1,24(sp)
ffffffffc0203c80:	6942                	ld	s2,16(sp)
ffffffffc0203c82:	69a2                	ld	s3,8(sp)
ffffffffc0203c84:	4501                	li	a0,0
ffffffffc0203c86:	6145                	addi	sp,sp,48
ffffffffc0203c88:	8082                	ret
     assert(result!=NULL);
ffffffffc0203c8a:	00007697          	auipc	a3,0x7
ffffffffc0203c8e:	91668693          	addi	a3,a3,-1770 # ffffffffc020a5a0 <default_pmm_manager+0x730>
ffffffffc0203c92:	00006617          	auipc	a2,0x6
ffffffffc0203c96:	a9660613          	addi	a2,a2,-1386 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203c9a:	07e00593          	li	a1,126
ffffffffc0203c9e:	00007517          	auipc	a0,0x7
ffffffffc0203ca2:	97250513          	addi	a0,a0,-1678 # ffffffffc020a610 <default_pmm_manager+0x7a0>
ffffffffc0203ca6:	fe2fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0203caa <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203caa:	000c5797          	auipc	a5,0xc5
ffffffffc0203cae:	7ae78793          	addi	a5,a5,1966 # ffffffffc02c9458 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203cb2:	f51c                	sd	a5,40(a0)
ffffffffc0203cb4:	e79c                	sd	a5,8(a5)
ffffffffc0203cb6:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203cb8:	4501                	li	a0,0
ffffffffc0203cba:	8082                	ret

ffffffffc0203cbc <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203cbc:	4501                	li	a0,0
ffffffffc0203cbe:	8082                	ret

ffffffffc0203cc0 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203cc0:	4501                	li	a0,0
ffffffffc0203cc2:	8082                	ret

ffffffffc0203cc4 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203cc4:	4501                	li	a0,0
ffffffffc0203cc6:	8082                	ret

ffffffffc0203cc8 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203cc8:	711d                	addi	sp,sp,-96
ffffffffc0203cca:	fc4e                	sd	s3,56(sp)
ffffffffc0203ccc:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203cce:	00007517          	auipc	a0,0x7
ffffffffc0203cd2:	c6a50513          	addi	a0,a0,-918 # ffffffffc020a938 <default_pmm_manager+0xac8>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203cd6:	698d                	lui	s3,0x3
ffffffffc0203cd8:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203cda:	e8a2                	sd	s0,80(sp)
ffffffffc0203cdc:	e4a6                	sd	s1,72(sp)
ffffffffc0203cde:	ec86                	sd	ra,88(sp)
ffffffffc0203ce0:	e0ca                	sd	s2,64(sp)
ffffffffc0203ce2:	f456                	sd	s5,40(sp)
ffffffffc0203ce4:	f05a                	sd	s6,32(sp)
ffffffffc0203ce6:	ec5e                	sd	s7,24(sp)
ffffffffc0203ce8:	e862                	sd	s8,16(sp)
ffffffffc0203cea:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0203cec:	000c5417          	auipc	s0,0xc5
ffffffffc0203cf0:	63040413          	addi	s0,s0,1584 # ffffffffc02c931c <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203cf4:	c9efc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203cf8:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6908>
    assert(pgfault_num==4);
ffffffffc0203cfc:	4004                	lw	s1,0(s0)
ffffffffc0203cfe:	4791                	li	a5,4
ffffffffc0203d00:	2481                	sext.w	s1,s1
ffffffffc0203d02:	14f49963          	bne	s1,a5,ffffffffc0203e54 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d06:	00007517          	auipc	a0,0x7
ffffffffc0203d0a:	c7250513          	addi	a0,a0,-910 # ffffffffc020a978 <default_pmm_manager+0xb08>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d0e:	6a85                	lui	s5,0x1
ffffffffc0203d10:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d12:	c80fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d16:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8908>
    assert(pgfault_num==4);
ffffffffc0203d1a:	00042903          	lw	s2,0(s0)
ffffffffc0203d1e:	2901                	sext.w	s2,s2
ffffffffc0203d20:	2a991a63          	bne	s2,s1,ffffffffc0203fd4 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d24:	00007517          	auipc	a0,0x7
ffffffffc0203d28:	c7c50513          	addi	a0,a0,-900 # ffffffffc020a9a0 <default_pmm_manager+0xb30>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d2c:	6b91                	lui	s7,0x4
ffffffffc0203d2e:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d30:	c62fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d34:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5908>
    assert(pgfault_num==4);
ffffffffc0203d38:	4004                	lw	s1,0(s0)
ffffffffc0203d3a:	2481                	sext.w	s1,s1
ffffffffc0203d3c:	27249c63          	bne	s1,s2,ffffffffc0203fb4 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d40:	00007517          	auipc	a0,0x7
ffffffffc0203d44:	c8850513          	addi	a0,a0,-888 # ffffffffc020a9c8 <default_pmm_manager+0xb58>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d48:	6909                	lui	s2,0x2
ffffffffc0203d4a:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d4c:	c46fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d50:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x7908>
    assert(pgfault_num==4);
ffffffffc0203d54:	401c                	lw	a5,0(s0)
ffffffffc0203d56:	2781                	sext.w	a5,a5
ffffffffc0203d58:	22979e63          	bne	a5,s1,ffffffffc0203f94 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203d5c:	00007517          	auipc	a0,0x7
ffffffffc0203d60:	c9450513          	addi	a0,a0,-876 # ffffffffc020a9f0 <default_pmm_manager+0xb80>
ffffffffc0203d64:	c2efc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203d68:	6795                	lui	a5,0x5
ffffffffc0203d6a:	4739                	li	a4,14
ffffffffc0203d6c:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4908>
    assert(pgfault_num==5);
ffffffffc0203d70:	4004                	lw	s1,0(s0)
ffffffffc0203d72:	4795                	li	a5,5
ffffffffc0203d74:	2481                	sext.w	s1,s1
ffffffffc0203d76:	1ef49f63          	bne	s1,a5,ffffffffc0203f74 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d7a:	00007517          	auipc	a0,0x7
ffffffffc0203d7e:	c4e50513          	addi	a0,a0,-946 # ffffffffc020a9c8 <default_pmm_manager+0xb58>
ffffffffc0203d82:	c10fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d86:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203d8a:	401c                	lw	a5,0(s0)
ffffffffc0203d8c:	2781                	sext.w	a5,a5
ffffffffc0203d8e:	1c979363          	bne	a5,s1,ffffffffc0203f54 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d92:	00007517          	auipc	a0,0x7
ffffffffc0203d96:	be650513          	addi	a0,a0,-1050 # ffffffffc020a978 <default_pmm_manager+0xb08>
ffffffffc0203d9a:	bf8fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d9e:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203da2:	401c                	lw	a5,0(s0)
ffffffffc0203da4:	4719                	li	a4,6
ffffffffc0203da6:	2781                	sext.w	a5,a5
ffffffffc0203da8:	18e79663          	bne	a5,a4,ffffffffc0203f34 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203dac:	00007517          	auipc	a0,0x7
ffffffffc0203db0:	c1c50513          	addi	a0,a0,-996 # ffffffffc020a9c8 <default_pmm_manager+0xb58>
ffffffffc0203db4:	bdefc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203db8:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203dbc:	401c                	lw	a5,0(s0)
ffffffffc0203dbe:	471d                	li	a4,7
ffffffffc0203dc0:	2781                	sext.w	a5,a5
ffffffffc0203dc2:	14e79963          	bne	a5,a4,ffffffffc0203f14 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203dc6:	00007517          	auipc	a0,0x7
ffffffffc0203dca:	b7250513          	addi	a0,a0,-1166 # ffffffffc020a938 <default_pmm_manager+0xac8>
ffffffffc0203dce:	bc4fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203dd2:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203dd6:	401c                	lw	a5,0(s0)
ffffffffc0203dd8:	4721                	li	a4,8
ffffffffc0203dda:	2781                	sext.w	a5,a5
ffffffffc0203ddc:	10e79c63          	bne	a5,a4,ffffffffc0203ef4 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203de0:	00007517          	auipc	a0,0x7
ffffffffc0203de4:	bc050513          	addi	a0,a0,-1088 # ffffffffc020a9a0 <default_pmm_manager+0xb30>
ffffffffc0203de8:	baafc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203dec:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203df0:	401c                	lw	a5,0(s0)
ffffffffc0203df2:	4725                	li	a4,9
ffffffffc0203df4:	2781                	sext.w	a5,a5
ffffffffc0203df6:	0ce79f63          	bne	a5,a4,ffffffffc0203ed4 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203dfa:	00007517          	auipc	a0,0x7
ffffffffc0203dfe:	bf650513          	addi	a0,a0,-1034 # ffffffffc020a9f0 <default_pmm_manager+0xb80>
ffffffffc0203e02:	b90fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203e06:	6795                	lui	a5,0x5
ffffffffc0203e08:	4739                	li	a4,14
ffffffffc0203e0a:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4908>
    assert(pgfault_num==10);
ffffffffc0203e0e:	4004                	lw	s1,0(s0)
ffffffffc0203e10:	47a9                	li	a5,10
ffffffffc0203e12:	2481                	sext.w	s1,s1
ffffffffc0203e14:	0af49063          	bne	s1,a5,ffffffffc0203eb4 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203e18:	00007517          	auipc	a0,0x7
ffffffffc0203e1c:	b6050513          	addi	a0,a0,-1184 # ffffffffc020a978 <default_pmm_manager+0xb08>
ffffffffc0203e20:	b72fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203e24:	6785                	lui	a5,0x1
ffffffffc0203e26:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8908>
ffffffffc0203e2a:	06979563          	bne	a5,s1,ffffffffc0203e94 <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0203e2e:	401c                	lw	a5,0(s0)
ffffffffc0203e30:	472d                	li	a4,11
ffffffffc0203e32:	2781                	sext.w	a5,a5
ffffffffc0203e34:	04e79063          	bne	a5,a4,ffffffffc0203e74 <_fifo_check_swap+0x1ac>
}
ffffffffc0203e38:	60e6                	ld	ra,88(sp)
ffffffffc0203e3a:	6446                	ld	s0,80(sp)
ffffffffc0203e3c:	64a6                	ld	s1,72(sp)
ffffffffc0203e3e:	6906                	ld	s2,64(sp)
ffffffffc0203e40:	79e2                	ld	s3,56(sp)
ffffffffc0203e42:	7a42                	ld	s4,48(sp)
ffffffffc0203e44:	7aa2                	ld	s5,40(sp)
ffffffffc0203e46:	7b02                	ld	s6,32(sp)
ffffffffc0203e48:	6be2                	ld	s7,24(sp)
ffffffffc0203e4a:	6c42                	ld	s8,16(sp)
ffffffffc0203e4c:	6ca2                	ld	s9,8(sp)
ffffffffc0203e4e:	4501                	li	a0,0
ffffffffc0203e50:	6125                	addi	sp,sp,96
ffffffffc0203e52:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203e54:	00007697          	auipc	a3,0x7
ffffffffc0203e58:	98468693          	addi	a3,a3,-1660 # ffffffffc020a7d8 <default_pmm_manager+0x968>
ffffffffc0203e5c:	00006617          	auipc	a2,0x6
ffffffffc0203e60:	8cc60613          	addi	a2,a2,-1844 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203e64:	05100593          	li	a1,81
ffffffffc0203e68:	00007517          	auipc	a0,0x7
ffffffffc0203e6c:	af850513          	addi	a0,a0,-1288 # ffffffffc020a960 <default_pmm_manager+0xaf0>
ffffffffc0203e70:	e18fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==11);
ffffffffc0203e74:	00007697          	auipc	a3,0x7
ffffffffc0203e78:	c2c68693          	addi	a3,a3,-980 # ffffffffc020aaa0 <default_pmm_manager+0xc30>
ffffffffc0203e7c:	00006617          	auipc	a2,0x6
ffffffffc0203e80:	8ac60613          	addi	a2,a2,-1876 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203e84:	07300593          	li	a1,115
ffffffffc0203e88:	00007517          	auipc	a0,0x7
ffffffffc0203e8c:	ad850513          	addi	a0,a0,-1320 # ffffffffc020a960 <default_pmm_manager+0xaf0>
ffffffffc0203e90:	df8fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203e94:	00007697          	auipc	a3,0x7
ffffffffc0203e98:	be468693          	addi	a3,a3,-1052 # ffffffffc020aa78 <default_pmm_manager+0xc08>
ffffffffc0203e9c:	00006617          	auipc	a2,0x6
ffffffffc0203ea0:	88c60613          	addi	a2,a2,-1908 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203ea4:	07100593          	li	a1,113
ffffffffc0203ea8:	00007517          	auipc	a0,0x7
ffffffffc0203eac:	ab850513          	addi	a0,a0,-1352 # ffffffffc020a960 <default_pmm_manager+0xaf0>
ffffffffc0203eb0:	dd8fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==10);
ffffffffc0203eb4:	00007697          	auipc	a3,0x7
ffffffffc0203eb8:	bb468693          	addi	a3,a3,-1100 # ffffffffc020aa68 <default_pmm_manager+0xbf8>
ffffffffc0203ebc:	00006617          	auipc	a2,0x6
ffffffffc0203ec0:	86c60613          	addi	a2,a2,-1940 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203ec4:	06f00593          	li	a1,111
ffffffffc0203ec8:	00007517          	auipc	a0,0x7
ffffffffc0203ecc:	a9850513          	addi	a0,a0,-1384 # ffffffffc020a960 <default_pmm_manager+0xaf0>
ffffffffc0203ed0:	db8fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==9);
ffffffffc0203ed4:	00007697          	auipc	a3,0x7
ffffffffc0203ed8:	b8468693          	addi	a3,a3,-1148 # ffffffffc020aa58 <default_pmm_manager+0xbe8>
ffffffffc0203edc:	00006617          	auipc	a2,0x6
ffffffffc0203ee0:	84c60613          	addi	a2,a2,-1972 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203ee4:	06c00593          	li	a1,108
ffffffffc0203ee8:	00007517          	auipc	a0,0x7
ffffffffc0203eec:	a7850513          	addi	a0,a0,-1416 # ffffffffc020a960 <default_pmm_manager+0xaf0>
ffffffffc0203ef0:	d98fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==8);
ffffffffc0203ef4:	00007697          	auipc	a3,0x7
ffffffffc0203ef8:	b5468693          	addi	a3,a3,-1196 # ffffffffc020aa48 <default_pmm_manager+0xbd8>
ffffffffc0203efc:	00006617          	auipc	a2,0x6
ffffffffc0203f00:	82c60613          	addi	a2,a2,-2004 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203f04:	06900593          	li	a1,105
ffffffffc0203f08:	00007517          	auipc	a0,0x7
ffffffffc0203f0c:	a5850513          	addi	a0,a0,-1448 # ffffffffc020a960 <default_pmm_manager+0xaf0>
ffffffffc0203f10:	d78fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==7);
ffffffffc0203f14:	00007697          	auipc	a3,0x7
ffffffffc0203f18:	b2468693          	addi	a3,a3,-1244 # ffffffffc020aa38 <default_pmm_manager+0xbc8>
ffffffffc0203f1c:	00006617          	auipc	a2,0x6
ffffffffc0203f20:	80c60613          	addi	a2,a2,-2036 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203f24:	06600593          	li	a1,102
ffffffffc0203f28:	00007517          	auipc	a0,0x7
ffffffffc0203f2c:	a3850513          	addi	a0,a0,-1480 # ffffffffc020a960 <default_pmm_manager+0xaf0>
ffffffffc0203f30:	d58fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==6);
ffffffffc0203f34:	00007697          	auipc	a3,0x7
ffffffffc0203f38:	af468693          	addi	a3,a3,-1292 # ffffffffc020aa28 <default_pmm_manager+0xbb8>
ffffffffc0203f3c:	00005617          	auipc	a2,0x5
ffffffffc0203f40:	7ec60613          	addi	a2,a2,2028 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203f44:	06300593          	li	a1,99
ffffffffc0203f48:	00007517          	auipc	a0,0x7
ffffffffc0203f4c:	a1850513          	addi	a0,a0,-1512 # ffffffffc020a960 <default_pmm_manager+0xaf0>
ffffffffc0203f50:	d38fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==5);
ffffffffc0203f54:	00007697          	auipc	a3,0x7
ffffffffc0203f58:	ac468693          	addi	a3,a3,-1340 # ffffffffc020aa18 <default_pmm_manager+0xba8>
ffffffffc0203f5c:	00005617          	auipc	a2,0x5
ffffffffc0203f60:	7cc60613          	addi	a2,a2,1996 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203f64:	06000593          	li	a1,96
ffffffffc0203f68:	00007517          	auipc	a0,0x7
ffffffffc0203f6c:	9f850513          	addi	a0,a0,-1544 # ffffffffc020a960 <default_pmm_manager+0xaf0>
ffffffffc0203f70:	d18fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==5);
ffffffffc0203f74:	00007697          	auipc	a3,0x7
ffffffffc0203f78:	aa468693          	addi	a3,a3,-1372 # ffffffffc020aa18 <default_pmm_manager+0xba8>
ffffffffc0203f7c:	00005617          	auipc	a2,0x5
ffffffffc0203f80:	7ac60613          	addi	a2,a2,1964 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203f84:	05d00593          	li	a1,93
ffffffffc0203f88:	00007517          	auipc	a0,0x7
ffffffffc0203f8c:	9d850513          	addi	a0,a0,-1576 # ffffffffc020a960 <default_pmm_manager+0xaf0>
ffffffffc0203f90:	cf8fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==4);
ffffffffc0203f94:	00007697          	auipc	a3,0x7
ffffffffc0203f98:	84468693          	addi	a3,a3,-1980 # ffffffffc020a7d8 <default_pmm_manager+0x968>
ffffffffc0203f9c:	00005617          	auipc	a2,0x5
ffffffffc0203fa0:	78c60613          	addi	a2,a2,1932 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203fa4:	05a00593          	li	a1,90
ffffffffc0203fa8:	00007517          	auipc	a0,0x7
ffffffffc0203fac:	9b850513          	addi	a0,a0,-1608 # ffffffffc020a960 <default_pmm_manager+0xaf0>
ffffffffc0203fb0:	cd8fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==4);
ffffffffc0203fb4:	00007697          	auipc	a3,0x7
ffffffffc0203fb8:	82468693          	addi	a3,a3,-2012 # ffffffffc020a7d8 <default_pmm_manager+0x968>
ffffffffc0203fbc:	00005617          	auipc	a2,0x5
ffffffffc0203fc0:	76c60613          	addi	a2,a2,1900 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203fc4:	05700593          	li	a1,87
ffffffffc0203fc8:	00007517          	auipc	a0,0x7
ffffffffc0203fcc:	99850513          	addi	a0,a0,-1640 # ffffffffc020a960 <default_pmm_manager+0xaf0>
ffffffffc0203fd0:	cb8fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==4);
ffffffffc0203fd4:	00007697          	auipc	a3,0x7
ffffffffc0203fd8:	80468693          	addi	a3,a3,-2044 # ffffffffc020a7d8 <default_pmm_manager+0x968>
ffffffffc0203fdc:	00005617          	auipc	a2,0x5
ffffffffc0203fe0:	74c60613          	addi	a2,a2,1868 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0203fe4:	05400593          	li	a1,84
ffffffffc0203fe8:	00007517          	auipc	a0,0x7
ffffffffc0203fec:	97850513          	addi	a0,a0,-1672 # ffffffffc020a960 <default_pmm_manager+0xaf0>
ffffffffc0203ff0:	c98fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0203ff4 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203ff4:	751c                	ld	a5,40(a0)
{
ffffffffc0203ff6:	1141                	addi	sp,sp,-16
ffffffffc0203ff8:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0203ffa:	cf91                	beqz	a5,ffffffffc0204016 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0203ffc:	ee0d                	bnez	a2,ffffffffc0204036 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0203ffe:	679c                	ld	a5,8(a5)
}
ffffffffc0204000:	60a2                	ld	ra,8(sp)
ffffffffc0204002:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0204004:	6394                	ld	a3,0(a5)
ffffffffc0204006:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0204008:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc020400c:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020400e:	e314                	sd	a3,0(a4)
ffffffffc0204010:	e19c                	sd	a5,0(a1)
}
ffffffffc0204012:	0141                	addi	sp,sp,16
ffffffffc0204014:	8082                	ret
         assert(head != NULL);
ffffffffc0204016:	00007697          	auipc	a3,0x7
ffffffffc020401a:	aba68693          	addi	a3,a3,-1350 # ffffffffc020aad0 <default_pmm_manager+0xc60>
ffffffffc020401e:	00005617          	auipc	a2,0x5
ffffffffc0204022:	70a60613          	addi	a2,a2,1802 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0204026:	04100593          	li	a1,65
ffffffffc020402a:	00007517          	auipc	a0,0x7
ffffffffc020402e:	93650513          	addi	a0,a0,-1738 # ffffffffc020a960 <default_pmm_manager+0xaf0>
ffffffffc0204032:	c56fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(in_tick==0);
ffffffffc0204036:	00007697          	auipc	a3,0x7
ffffffffc020403a:	aaa68693          	addi	a3,a3,-1366 # ffffffffc020aae0 <default_pmm_manager+0xc70>
ffffffffc020403e:	00005617          	auipc	a2,0x5
ffffffffc0204042:	6ea60613          	addi	a2,a2,1770 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0204046:	04200593          	li	a1,66
ffffffffc020404a:	00007517          	auipc	a0,0x7
ffffffffc020404e:	91650513          	addi	a0,a0,-1770 # ffffffffc020a960 <default_pmm_manager+0xaf0>
ffffffffc0204052:	c36fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204056 <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0204056:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020405a:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc020405c:	cb09                	beqz	a4,ffffffffc020406e <_fifo_map_swappable+0x18>
ffffffffc020405e:	cb81                	beqz	a5,ffffffffc020406e <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204060:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0204062:	e398                	sd	a4,0(a5)
}
ffffffffc0204064:	4501                	li	a0,0
ffffffffc0204066:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0204068:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc020406a:	f614                	sd	a3,40(a2)
ffffffffc020406c:	8082                	ret
{
ffffffffc020406e:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0204070:	00007697          	auipc	a3,0x7
ffffffffc0204074:	a4068693          	addi	a3,a3,-1472 # ffffffffc020aab0 <default_pmm_manager+0xc40>
ffffffffc0204078:	00005617          	auipc	a2,0x5
ffffffffc020407c:	6b060613          	addi	a2,a2,1712 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0204080:	03200593          	li	a1,50
ffffffffc0204084:	00007517          	auipc	a0,0x7
ffffffffc0204088:	8dc50513          	addi	a0,a0,-1828 # ffffffffc020a960 <default_pmm_manager+0xaf0>
{
ffffffffc020408c:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc020408e:	bfafc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204092 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0204092:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0204094:	00007697          	auipc	a3,0x7
ffffffffc0204098:	a7468693          	addi	a3,a3,-1420 # ffffffffc020ab08 <default_pmm_manager+0xc98>
ffffffffc020409c:	00005617          	auipc	a2,0x5
ffffffffc02040a0:	68c60613          	addi	a2,a2,1676 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02040a4:	06d00593          	li	a1,109
ffffffffc02040a8:	00007517          	auipc	a0,0x7
ffffffffc02040ac:	a8050513          	addi	a0,a0,-1408 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02040b0:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02040b2:	bd6fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02040b6 <mm_create>:
mm_create(void) {
ffffffffc02040b6:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02040b8:	04000513          	li	a0,64
mm_create(void) {
ffffffffc02040bc:	e022                	sd	s0,0(sp)
ffffffffc02040be:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02040c0:	b87fd0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
ffffffffc02040c4:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02040c6:	c515                	beqz	a0,ffffffffc02040f2 <mm_create+0x3c>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02040c8:	000c5797          	auipc	a5,0xc5
ffffffffc02040cc:	25078793          	addi	a5,a5,592 # ffffffffc02c9318 <swap_init_ok>
ffffffffc02040d0:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc02040d2:	e408                	sd	a0,8(s0)
ffffffffc02040d4:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02040d6:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02040da:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02040de:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02040e2:	2781                	sext.w	a5,a5
ffffffffc02040e4:	ef81                	bnez	a5,ffffffffc02040fc <mm_create+0x46>
        else mm->sm_priv = NULL;
ffffffffc02040e6:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc02040ea:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc02040ee:	02043c23          	sd	zero,56(s0)
}
ffffffffc02040f2:	8522                	mv	a0,s0
ffffffffc02040f4:	60a2                	ld	ra,8(sp)
ffffffffc02040f6:	6402                	ld	s0,0(sp)
ffffffffc02040f8:	0141                	addi	sp,sp,16
ffffffffc02040fa:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02040fc:	a01ff0ef          	jal	ra,ffffffffc0203afc <swap_init_mm>
ffffffffc0204100:	b7ed                	j	ffffffffc02040ea <mm_create+0x34>

ffffffffc0204102 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0204102:	1101                	addi	sp,sp,-32
ffffffffc0204104:	e04a                	sd	s2,0(sp)
ffffffffc0204106:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204108:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020410c:	e822                	sd	s0,16(sp)
ffffffffc020410e:	e426                	sd	s1,8(sp)
ffffffffc0204110:	ec06                	sd	ra,24(sp)
ffffffffc0204112:	84ae                	mv	s1,a1
ffffffffc0204114:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204116:	b31fd0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
    if (vma != NULL) {
ffffffffc020411a:	c509                	beqz	a0,ffffffffc0204124 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020411c:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204120:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204122:	cd00                	sw	s0,24(a0)
}
ffffffffc0204124:	60e2                	ld	ra,24(sp)
ffffffffc0204126:	6442                	ld	s0,16(sp)
ffffffffc0204128:	64a2                	ld	s1,8(sp)
ffffffffc020412a:	6902                	ld	s2,0(sp)
ffffffffc020412c:	6105                	addi	sp,sp,32
ffffffffc020412e:	8082                	ret

ffffffffc0204130 <find_vma>:
    if (mm != NULL) {
ffffffffc0204130:	c51d                	beqz	a0,ffffffffc020415e <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0204132:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204134:	c781                	beqz	a5,ffffffffc020413c <find_vma+0xc>
ffffffffc0204136:	6798                	ld	a4,8(a5)
ffffffffc0204138:	02e5f663          	bleu	a4,a1,ffffffffc0204164 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc020413c:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc020413e:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0204140:	00f50f63          	beq	a0,a5,ffffffffc020415e <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0204144:	fe87b703          	ld	a4,-24(a5)
ffffffffc0204148:	fee5ebe3          	bltu	a1,a4,ffffffffc020413e <find_vma+0xe>
ffffffffc020414c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0204150:	fee5f7e3          	bleu	a4,a1,ffffffffc020413e <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0204154:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0204156:	c781                	beqz	a5,ffffffffc020415e <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0204158:	e91c                	sd	a5,16(a0)
}
ffffffffc020415a:	853e                	mv	a0,a5
ffffffffc020415c:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc020415e:	4781                	li	a5,0
}
ffffffffc0204160:	853e                	mv	a0,a5
ffffffffc0204162:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204164:	6b98                	ld	a4,16(a5)
ffffffffc0204166:	fce5fbe3          	bleu	a4,a1,ffffffffc020413c <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc020416a:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc020416c:	b7fd                	j	ffffffffc020415a <find_vma+0x2a>

ffffffffc020416e <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc020416e:	6590                	ld	a2,8(a1)
ffffffffc0204170:	0105b803          	ld	a6,16(a1) # 1010 <_binary_obj___user_faultread_out_size-0x88f8>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0204174:	1141                	addi	sp,sp,-16
ffffffffc0204176:	e406                	sd	ra,8(sp)
ffffffffc0204178:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020417a:	01066863          	bltu	a2,a6,ffffffffc020418a <insert_vma_struct+0x1c>
ffffffffc020417e:	a8b9                	j	ffffffffc02041dc <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0204180:	fe87b683          	ld	a3,-24(a5)
ffffffffc0204184:	04d66763          	bltu	a2,a3,ffffffffc02041d2 <insert_vma_struct+0x64>
ffffffffc0204188:	873e                	mv	a4,a5
ffffffffc020418a:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc020418c:	fef51ae3          	bne	a0,a5,ffffffffc0204180 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0204190:	02a70463          	beq	a4,a0,ffffffffc02041b8 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0204194:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0204198:	fe873883          	ld	a7,-24(a4)
ffffffffc020419c:	08d8f063          	bleu	a3,a7,ffffffffc020421c <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041a0:	04d66e63          	bltu	a2,a3,ffffffffc02041fc <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc02041a4:	00f50a63          	beq	a0,a5,ffffffffc02041b8 <insert_vma_struct+0x4a>
ffffffffc02041a8:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041ac:	0506e863          	bltu	a3,a6,ffffffffc02041fc <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02041b0:	ff07b603          	ld	a2,-16(a5)
ffffffffc02041b4:	02c6f263          	bleu	a2,a3,ffffffffc02041d8 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02041b8:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc02041ba:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02041bc:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02041c0:	e390                	sd	a2,0(a5)
ffffffffc02041c2:	e710                	sd	a2,8(a4)
}
ffffffffc02041c4:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02041c6:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02041c8:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc02041ca:	2685                	addiw	a3,a3,1
ffffffffc02041cc:	d114                	sw	a3,32(a0)
}
ffffffffc02041ce:	0141                	addi	sp,sp,16
ffffffffc02041d0:	8082                	ret
    if (le_prev != list) {
ffffffffc02041d2:	fca711e3          	bne	a4,a0,ffffffffc0204194 <insert_vma_struct+0x26>
ffffffffc02041d6:	bfd9                	j	ffffffffc02041ac <insert_vma_struct+0x3e>
ffffffffc02041d8:	ebbff0ef          	jal	ra,ffffffffc0204092 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02041dc:	00007697          	auipc	a3,0x7
ffffffffc02041e0:	a5c68693          	addi	a3,a3,-1444 # ffffffffc020ac38 <default_pmm_manager+0xdc8>
ffffffffc02041e4:	00005617          	auipc	a2,0x5
ffffffffc02041e8:	54460613          	addi	a2,a2,1348 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02041ec:	07400593          	li	a1,116
ffffffffc02041f0:	00007517          	auipc	a0,0x7
ffffffffc02041f4:	93850513          	addi	a0,a0,-1736 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc02041f8:	a90fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041fc:	00007697          	auipc	a3,0x7
ffffffffc0204200:	a7c68693          	addi	a3,a3,-1412 # ffffffffc020ac78 <default_pmm_manager+0xe08>
ffffffffc0204204:	00005617          	auipc	a2,0x5
ffffffffc0204208:	52460613          	addi	a2,a2,1316 # ffffffffc0209728 <commands+0x4c0>
ffffffffc020420c:	06c00593          	li	a1,108
ffffffffc0204210:	00007517          	auipc	a0,0x7
ffffffffc0204214:	91850513          	addi	a0,a0,-1768 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc0204218:	a70fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020421c:	00007697          	auipc	a3,0x7
ffffffffc0204220:	a3c68693          	addi	a3,a3,-1476 # ffffffffc020ac58 <default_pmm_manager+0xde8>
ffffffffc0204224:	00005617          	auipc	a2,0x5
ffffffffc0204228:	50460613          	addi	a2,a2,1284 # ffffffffc0209728 <commands+0x4c0>
ffffffffc020422c:	06b00593          	li	a1,107
ffffffffc0204230:	00007517          	auipc	a0,0x7
ffffffffc0204234:	8f850513          	addi	a0,a0,-1800 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc0204238:	a50fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020423c <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc020423c:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc020423e:	1141                	addi	sp,sp,-16
ffffffffc0204240:	e406                	sd	ra,8(sp)
ffffffffc0204242:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0204244:	e78d                	bnez	a5,ffffffffc020426e <mm_destroy+0x32>
ffffffffc0204246:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0204248:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc020424a:	00a40c63          	beq	s0,a0,ffffffffc0204262 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020424e:	6118                	ld	a4,0(a0)
ffffffffc0204250:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0204252:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0204254:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0204256:	e398                	sd	a4,0(a5)
ffffffffc0204258:	aabfd0ef          	jal	ra,ffffffffc0201d02 <kfree>
    return listelm->next;
ffffffffc020425c:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020425e:	fea418e3          	bne	s0,a0,ffffffffc020424e <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0204262:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0204264:	6402                	ld	s0,0(sp)
ffffffffc0204266:	60a2                	ld	ra,8(sp)
ffffffffc0204268:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc020426a:	a99fd06f          	j	ffffffffc0201d02 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc020426e:	00007697          	auipc	a3,0x7
ffffffffc0204272:	a2a68693          	addi	a3,a3,-1494 # ffffffffc020ac98 <default_pmm_manager+0xe28>
ffffffffc0204276:	00005617          	auipc	a2,0x5
ffffffffc020427a:	4b260613          	addi	a2,a2,1202 # ffffffffc0209728 <commands+0x4c0>
ffffffffc020427e:	09400593          	li	a1,148
ffffffffc0204282:	00007517          	auipc	a0,0x7
ffffffffc0204286:	8a650513          	addi	a0,a0,-1882 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc020428a:	9fefc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020428e <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020428e:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc0204290:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204292:	17fd                	addi	a5,a5,-1
ffffffffc0204294:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc0204296:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204298:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc020429c:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020429e:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc02042a0:	fc06                	sd	ra,56(sp)
ffffffffc02042a2:	f04a                	sd	s2,32(sp)
ffffffffc02042a4:	ec4e                	sd	s3,24(sp)
ffffffffc02042a6:	e852                	sd	s4,16(sp)
ffffffffc02042a8:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042aa:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc02042ae:	002007b7          	lui	a5,0x200
ffffffffc02042b2:	01047433          	and	s0,s0,a6
ffffffffc02042b6:	06f4e363          	bltu	s1,a5,ffffffffc020431c <mm_map+0x8e>
ffffffffc02042ba:	0684f163          	bleu	s0,s1,ffffffffc020431c <mm_map+0x8e>
ffffffffc02042be:	4785                	li	a5,1
ffffffffc02042c0:	07fe                	slli	a5,a5,0x1f
ffffffffc02042c2:	0487ed63          	bltu	a5,s0,ffffffffc020431c <mm_map+0x8e>
ffffffffc02042c6:	89aa                	mv	s3,a0
ffffffffc02042c8:	8a3a                	mv	s4,a4
ffffffffc02042ca:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02042cc:	c931                	beqz	a0,ffffffffc0204320 <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc02042ce:	85a6                	mv	a1,s1
ffffffffc02042d0:	e61ff0ef          	jal	ra,ffffffffc0204130 <find_vma>
ffffffffc02042d4:	c501                	beqz	a0,ffffffffc02042dc <mm_map+0x4e>
ffffffffc02042d6:	651c                	ld	a5,8(a0)
ffffffffc02042d8:	0487e263          	bltu	a5,s0,ffffffffc020431c <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02042dc:	03000513          	li	a0,48
ffffffffc02042e0:	967fd0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
ffffffffc02042e4:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02042e6:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc02042e8:	02090163          	beqz	s2,ffffffffc020430a <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02042ec:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02042ee:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc02042f2:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc02042f6:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc02042fa:	85ca                	mv	a1,s2
ffffffffc02042fc:	e73ff0ef          	jal	ra,ffffffffc020416e <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0204300:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc0204302:	000a0463          	beqz	s4,ffffffffc020430a <mm_map+0x7c>
        *vma_store = vma;
ffffffffc0204306:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc020430a:	70e2                	ld	ra,56(sp)
ffffffffc020430c:	7442                	ld	s0,48(sp)
ffffffffc020430e:	74a2                	ld	s1,40(sp)
ffffffffc0204310:	7902                	ld	s2,32(sp)
ffffffffc0204312:	69e2                	ld	s3,24(sp)
ffffffffc0204314:	6a42                	ld	s4,16(sp)
ffffffffc0204316:	6aa2                	ld	s5,8(sp)
ffffffffc0204318:	6121                	addi	sp,sp,64
ffffffffc020431a:	8082                	ret
        return -E_INVAL;
ffffffffc020431c:	5575                	li	a0,-3
ffffffffc020431e:	b7f5                	j	ffffffffc020430a <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc0204320:	00006697          	auipc	a3,0x6
ffffffffc0204324:	34068693          	addi	a3,a3,832 # ffffffffc020a660 <default_pmm_manager+0x7f0>
ffffffffc0204328:	00005617          	auipc	a2,0x5
ffffffffc020432c:	40060613          	addi	a2,a2,1024 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0204330:	0a700593          	li	a1,167
ffffffffc0204334:	00006517          	auipc	a0,0x6
ffffffffc0204338:	7f450513          	addi	a0,a0,2036 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc020433c:	94cfc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204340 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0204340:	7139                	addi	sp,sp,-64
ffffffffc0204342:	fc06                	sd	ra,56(sp)
ffffffffc0204344:	f822                	sd	s0,48(sp)
ffffffffc0204346:	f426                	sd	s1,40(sp)
ffffffffc0204348:	f04a                	sd	s2,32(sp)
ffffffffc020434a:	ec4e                	sd	s3,24(sp)
ffffffffc020434c:	e852                	sd	s4,16(sp)
ffffffffc020434e:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0204350:	c535                	beqz	a0,ffffffffc02043bc <dup_mmap+0x7c>
ffffffffc0204352:	892a                	mv	s2,a0
ffffffffc0204354:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0204356:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0204358:	e59d                	bnez	a1,ffffffffc0204386 <dup_mmap+0x46>
ffffffffc020435a:	a08d                	j	ffffffffc02043bc <dup_mmap+0x7c>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc020435c:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc020435e:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_matrix_out_size+0x1f4598>
        insert_vma_struct(to, nvma);
ffffffffc0204362:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc0204364:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc0204368:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc020436c:	e03ff0ef          	jal	ra,ffffffffc020416e <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc0204370:	ff043683          	ld	a3,-16(s0)
ffffffffc0204374:	fe843603          	ld	a2,-24(s0)
ffffffffc0204378:	6c8c                	ld	a1,24(s1)
ffffffffc020437a:	01893503          	ld	a0,24(s2)
ffffffffc020437e:	4701                	li	a4,0
ffffffffc0204380:	d2ffe0ef          	jal	ra,ffffffffc02030ae <copy_range>
ffffffffc0204384:	e105                	bnez	a0,ffffffffc02043a4 <dup_mmap+0x64>
    return listelm->prev;
ffffffffc0204386:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc0204388:	02848863          	beq	s1,s0,ffffffffc02043b8 <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020438c:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0204390:	fe843a83          	ld	s5,-24(s0)
ffffffffc0204394:	ff043a03          	ld	s4,-16(s0)
ffffffffc0204398:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020439c:	8abfd0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
ffffffffc02043a0:	87aa                	mv	a5,a0
    if (vma != NULL) {
ffffffffc02043a2:	fd4d                	bnez	a0,ffffffffc020435c <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc02043a4:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02043a6:	70e2                	ld	ra,56(sp)
ffffffffc02043a8:	7442                	ld	s0,48(sp)
ffffffffc02043aa:	74a2                	ld	s1,40(sp)
ffffffffc02043ac:	7902                	ld	s2,32(sp)
ffffffffc02043ae:	69e2                	ld	s3,24(sp)
ffffffffc02043b0:	6a42                	ld	s4,16(sp)
ffffffffc02043b2:	6aa2                	ld	s5,8(sp)
ffffffffc02043b4:	6121                	addi	sp,sp,64
ffffffffc02043b6:	8082                	ret
    return 0;
ffffffffc02043b8:	4501                	li	a0,0
ffffffffc02043ba:	b7f5                	j	ffffffffc02043a6 <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc02043bc:	00007697          	auipc	a3,0x7
ffffffffc02043c0:	83c68693          	addi	a3,a3,-1988 # ffffffffc020abf8 <default_pmm_manager+0xd88>
ffffffffc02043c4:	00005617          	auipc	a2,0x5
ffffffffc02043c8:	36460613          	addi	a2,a2,868 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02043cc:	0c000593          	li	a1,192
ffffffffc02043d0:	00006517          	auipc	a0,0x6
ffffffffc02043d4:	75850513          	addi	a0,a0,1880 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc02043d8:	8b0fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02043dc <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc02043dc:	1101                	addi	sp,sp,-32
ffffffffc02043de:	ec06                	sd	ra,24(sp)
ffffffffc02043e0:	e822                	sd	s0,16(sp)
ffffffffc02043e2:	e426                	sd	s1,8(sp)
ffffffffc02043e4:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02043e6:	c531                	beqz	a0,ffffffffc0204432 <exit_mmap+0x56>
ffffffffc02043e8:	591c                	lw	a5,48(a0)
ffffffffc02043ea:	84aa                	mv	s1,a0
ffffffffc02043ec:	e3b9                	bnez	a5,ffffffffc0204432 <exit_mmap+0x56>
    return listelm->next;
ffffffffc02043ee:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02043f0:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc02043f4:	02850663          	beq	a0,s0,ffffffffc0204420 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02043f8:	ff043603          	ld	a2,-16(s0)
ffffffffc02043fc:	fe843583          	ld	a1,-24(s0)
ffffffffc0204400:	854a                	mv	a0,s2
ffffffffc0204402:	d83fd0ef          	jal	ra,ffffffffc0202184 <unmap_range>
ffffffffc0204406:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204408:	fe8498e3          	bne	s1,s0,ffffffffc02043f8 <exit_mmap+0x1c>
ffffffffc020440c:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc020440e:	00848c63          	beq	s1,s0,ffffffffc0204426 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204412:	ff043603          	ld	a2,-16(s0)
ffffffffc0204416:	fe843583          	ld	a1,-24(s0)
ffffffffc020441a:	854a                	mv	a0,s2
ffffffffc020441c:	e81fd0ef          	jal	ra,ffffffffc020229c <exit_range>
ffffffffc0204420:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204422:	fe8498e3          	bne	s1,s0,ffffffffc0204412 <exit_mmap+0x36>
    }
}
ffffffffc0204426:	60e2                	ld	ra,24(sp)
ffffffffc0204428:	6442                	ld	s0,16(sp)
ffffffffc020442a:	64a2                	ld	s1,8(sp)
ffffffffc020442c:	6902                	ld	s2,0(sp)
ffffffffc020442e:	6105                	addi	sp,sp,32
ffffffffc0204430:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204432:	00006697          	auipc	a3,0x6
ffffffffc0204436:	7e668693          	addi	a3,a3,2022 # ffffffffc020ac18 <default_pmm_manager+0xda8>
ffffffffc020443a:	00005617          	auipc	a2,0x5
ffffffffc020443e:	2ee60613          	addi	a2,a2,750 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0204442:	0d600593          	li	a1,214
ffffffffc0204446:	00006517          	auipc	a0,0x6
ffffffffc020444a:	6e250513          	addi	a0,a0,1762 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc020444e:	83afc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204452 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0204452:	7139                	addi	sp,sp,-64
ffffffffc0204454:	f822                	sd	s0,48(sp)
ffffffffc0204456:	f426                	sd	s1,40(sp)
ffffffffc0204458:	fc06                	sd	ra,56(sp)
ffffffffc020445a:	f04a                	sd	s2,32(sp)
ffffffffc020445c:	ec4e                	sd	s3,24(sp)
ffffffffc020445e:	e852                	sd	s4,16(sp)
ffffffffc0204460:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0204462:	c55ff0ef          	jal	ra,ffffffffc02040b6 <mm_create>
    assert(mm != NULL);
ffffffffc0204466:	842a                	mv	s0,a0
ffffffffc0204468:	03200493          	li	s1,50
ffffffffc020446c:	e919                	bnez	a0,ffffffffc0204482 <vmm_init+0x30>
ffffffffc020446e:	a989                	j	ffffffffc02048c0 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0204470:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204472:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204474:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0204478:	14ed                	addi	s1,s1,-5
ffffffffc020447a:	8522                	mv	a0,s0
ffffffffc020447c:	cf3ff0ef          	jal	ra,ffffffffc020416e <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0204480:	c88d                	beqz	s1,ffffffffc02044b2 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204482:	03000513          	li	a0,48
ffffffffc0204486:	fc0fd0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
ffffffffc020448a:	85aa                	mv	a1,a0
ffffffffc020448c:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0204490:	f165                	bnez	a0,ffffffffc0204470 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0204492:	00006697          	auipc	a3,0x6
ffffffffc0204496:	20668693          	addi	a3,a3,518 # ffffffffc020a698 <default_pmm_manager+0x828>
ffffffffc020449a:	00005617          	auipc	a2,0x5
ffffffffc020449e:	28e60613          	addi	a2,a2,654 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02044a2:	11300593          	li	a1,275
ffffffffc02044a6:	00006517          	auipc	a0,0x6
ffffffffc02044aa:	68250513          	addi	a0,a0,1666 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc02044ae:	fdbfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc02044b2:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02044b6:	1f900913          	li	s2,505
ffffffffc02044ba:	a819                	j	ffffffffc02044d0 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc02044bc:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02044be:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02044c0:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02044c4:	0495                	addi	s1,s1,5
ffffffffc02044c6:	8522                	mv	a0,s0
ffffffffc02044c8:	ca7ff0ef          	jal	ra,ffffffffc020416e <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02044cc:	03248a63          	beq	s1,s2,ffffffffc0204500 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02044d0:	03000513          	li	a0,48
ffffffffc02044d4:	f72fd0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
ffffffffc02044d8:	85aa                	mv	a1,a0
ffffffffc02044da:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02044de:	fd79                	bnez	a0,ffffffffc02044bc <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc02044e0:	00006697          	auipc	a3,0x6
ffffffffc02044e4:	1b868693          	addi	a3,a3,440 # ffffffffc020a698 <default_pmm_manager+0x828>
ffffffffc02044e8:	00005617          	auipc	a2,0x5
ffffffffc02044ec:	24060613          	addi	a2,a2,576 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02044f0:	11900593          	li	a1,281
ffffffffc02044f4:	00006517          	auipc	a0,0x6
ffffffffc02044f8:	63450513          	addi	a0,a0,1588 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc02044fc:	f8dfb0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0204500:	6418                	ld	a4,8(s0)
ffffffffc0204502:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0204504:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0204508:	2ee40063          	beq	s0,a4,ffffffffc02047e8 <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020450c:	fe873603          	ld	a2,-24(a4)
ffffffffc0204510:	ffe78693          	addi	a3,a5,-2
ffffffffc0204514:	24d61a63          	bne	a2,a3,ffffffffc0204768 <vmm_init+0x316>
ffffffffc0204518:	ff073683          	ld	a3,-16(a4)
ffffffffc020451c:	24f69663          	bne	a3,a5,ffffffffc0204768 <vmm_init+0x316>
ffffffffc0204520:	0795                	addi	a5,a5,5
ffffffffc0204522:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0204524:	feb792e3          	bne	a5,a1,ffffffffc0204508 <vmm_init+0xb6>
ffffffffc0204528:	491d                	li	s2,7
ffffffffc020452a:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020452c:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0204530:	85a6                	mv	a1,s1
ffffffffc0204532:	8522                	mv	a0,s0
ffffffffc0204534:	bfdff0ef          	jal	ra,ffffffffc0204130 <find_vma>
ffffffffc0204538:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc020453a:	30050763          	beqz	a0,ffffffffc0204848 <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc020453e:	00148593          	addi	a1,s1,1
ffffffffc0204542:	8522                	mv	a0,s0
ffffffffc0204544:	bedff0ef          	jal	ra,ffffffffc0204130 <find_vma>
ffffffffc0204548:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc020454a:	2c050f63          	beqz	a0,ffffffffc0204828 <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc020454e:	85ca                	mv	a1,s2
ffffffffc0204550:	8522                	mv	a0,s0
ffffffffc0204552:	bdfff0ef          	jal	ra,ffffffffc0204130 <find_vma>
        assert(vma3 == NULL);
ffffffffc0204556:	2a051963          	bnez	a0,ffffffffc0204808 <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc020455a:	00348593          	addi	a1,s1,3
ffffffffc020455e:	8522                	mv	a0,s0
ffffffffc0204560:	bd1ff0ef          	jal	ra,ffffffffc0204130 <find_vma>
        assert(vma4 == NULL);
ffffffffc0204564:	32051263          	bnez	a0,ffffffffc0204888 <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0204568:	00448593          	addi	a1,s1,4
ffffffffc020456c:	8522                	mv	a0,s0
ffffffffc020456e:	bc3ff0ef          	jal	ra,ffffffffc0204130 <find_vma>
        assert(vma5 == NULL);
ffffffffc0204572:	2e051b63          	bnez	a0,ffffffffc0204868 <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0204576:	008a3783          	ld	a5,8(s4)
ffffffffc020457a:	20979763          	bne	a5,s1,ffffffffc0204788 <vmm_init+0x336>
ffffffffc020457e:	010a3783          	ld	a5,16(s4)
ffffffffc0204582:	21279363          	bne	a5,s2,ffffffffc0204788 <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0204586:	0089b783          	ld	a5,8(s3)
ffffffffc020458a:	20979f63          	bne	a5,s1,ffffffffc02047a8 <vmm_init+0x356>
ffffffffc020458e:	0109b783          	ld	a5,16(s3)
ffffffffc0204592:	21279b63          	bne	a5,s2,ffffffffc02047a8 <vmm_init+0x356>
ffffffffc0204596:	0495                	addi	s1,s1,5
ffffffffc0204598:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020459a:	f9549be3          	bne	s1,s5,ffffffffc0204530 <vmm_init+0xde>
ffffffffc020459e:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02045a0:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02045a2:	85a6                	mv	a1,s1
ffffffffc02045a4:	8522                	mv	a0,s0
ffffffffc02045a6:	b8bff0ef          	jal	ra,ffffffffc0204130 <find_vma>
ffffffffc02045aa:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc02045ae:	c90d                	beqz	a0,ffffffffc02045e0 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02045b0:	6914                	ld	a3,16(a0)
ffffffffc02045b2:	6510                	ld	a2,8(a0)
ffffffffc02045b4:	00006517          	auipc	a0,0x6
ffffffffc02045b8:	7fc50513          	addi	a0,a0,2044 # ffffffffc020adb0 <default_pmm_manager+0xf40>
ffffffffc02045bc:	bd7fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02045c0:	00007697          	auipc	a3,0x7
ffffffffc02045c4:	81868693          	addi	a3,a3,-2024 # ffffffffc020add8 <default_pmm_manager+0xf68>
ffffffffc02045c8:	00005617          	auipc	a2,0x5
ffffffffc02045cc:	16060613          	addi	a2,a2,352 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02045d0:	13b00593          	li	a1,315
ffffffffc02045d4:	00006517          	auipc	a0,0x6
ffffffffc02045d8:	55450513          	addi	a0,a0,1364 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc02045dc:	eadfb0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc02045e0:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc02045e2:	fd2490e3          	bne	s1,s2,ffffffffc02045a2 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc02045e6:	8522                	mv	a0,s0
ffffffffc02045e8:	c55ff0ef          	jal	ra,ffffffffc020423c <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02045ec:	00007517          	auipc	a0,0x7
ffffffffc02045f0:	80450513          	addi	a0,a0,-2044 # ffffffffc020adf0 <default_pmm_manager+0xf80>
ffffffffc02045f4:	b9ffb0ef          	jal	ra,ffffffffc0200192 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02045f8:	919fd0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>
ffffffffc02045fc:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc02045fe:	ab9ff0ef          	jal	ra,ffffffffc02040b6 <mm_create>
ffffffffc0204602:	000c5797          	auipc	a5,0xc5
ffffffffc0204606:	e6a7b323          	sd	a0,-410(a5) # ffffffffc02c9468 <check_mm_struct>
ffffffffc020460a:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc020460c:	36050663          	beqz	a0,ffffffffc0204978 <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204610:	000c5797          	auipc	a5,0xc5
ffffffffc0204614:	cf078793          	addi	a5,a5,-784 # ffffffffc02c9300 <boot_pgdir>
ffffffffc0204618:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc020461c:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204620:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0204624:	2c079e63          	bnez	a5,ffffffffc0204900 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204628:	03000513          	li	a0,48
ffffffffc020462c:	e1afd0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
ffffffffc0204630:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0204632:	18050b63          	beqz	a0,ffffffffc02047c8 <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0204636:	002007b7          	lui	a5,0x200
ffffffffc020463a:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc020463c:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc020463e:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0204640:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0204642:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0204644:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0204648:	b27ff0ef          	jal	ra,ffffffffc020416e <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020464c:	10000593          	li	a1,256
ffffffffc0204650:	8526                	mv	a0,s1
ffffffffc0204652:	adfff0ef          	jal	ra,ffffffffc0204130 <find_vma>
ffffffffc0204656:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc020465a:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc020465e:	2ca41163          	bne	s0,a0,ffffffffc0204920 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0204662:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_matrix_out_size+0x1f4590>
        sum += i;
ffffffffc0204666:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0204668:	fee79de3          	bne	a5,a4,ffffffffc0204662 <vmm_init+0x210>
        sum += i;
ffffffffc020466c:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc020466e:	10000793          	li	a5,256
        sum += i;
ffffffffc0204672:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x85b2>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0204676:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020467a:	0007c683          	lbu	a3,0(a5)
ffffffffc020467e:	0785                	addi	a5,a5,1
ffffffffc0204680:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0204682:	fec79ce3          	bne	a5,a2,ffffffffc020467a <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc0204686:	2c071963          	bnez	a4,ffffffffc0204958 <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc020468a:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020468e:	000c5a97          	auipc	s5,0xc5
ffffffffc0204692:	c7aa8a93          	addi	s5,s5,-902 # ffffffffc02c9308 <npage>
ffffffffc0204696:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020469a:	078a                	slli	a5,a5,0x2
ffffffffc020469c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020469e:	20e7f563          	bleu	a4,a5,ffffffffc02048a8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02046a2:	00008697          	auipc	a3,0x8
ffffffffc02046a6:	8d668693          	addi	a3,a3,-1834 # ffffffffc020bf78 <nbase>
ffffffffc02046aa:	0006ba03          	ld	s4,0(a3)
ffffffffc02046ae:	414786b3          	sub	a3,a5,s4
ffffffffc02046b2:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02046b4:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02046b6:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc02046b8:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc02046ba:	83b1                	srli	a5,a5,0xc
ffffffffc02046bc:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02046be:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02046c0:	28e7f063          	bleu	a4,a5,ffffffffc0204940 <vmm_init+0x4ee>
ffffffffc02046c4:	000c5797          	auipc	a5,0xc5
ffffffffc02046c8:	cb478793          	addi	a5,a5,-844 # ffffffffc02c9378 <va_pa_offset>
ffffffffc02046cc:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02046ce:	4581                	li	a1,0
ffffffffc02046d0:	854a                	mv	a0,s2
ffffffffc02046d2:	9436                	add	s0,s0,a3
ffffffffc02046d4:	e1ffd0ef          	jal	ra,ffffffffc02024f2 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02046d8:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02046da:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02046de:	078a                	slli	a5,a5,0x2
ffffffffc02046e0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02046e2:	1ce7f363          	bleu	a4,a5,ffffffffc02048a8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02046e6:	000c5417          	auipc	s0,0xc5
ffffffffc02046ea:	ca240413          	addi	s0,s0,-862 # ffffffffc02c9388 <pages>
ffffffffc02046ee:	6008                	ld	a0,0(s0)
ffffffffc02046f0:	414787b3          	sub	a5,a5,s4
ffffffffc02046f4:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02046f6:	953e                	add	a0,a0,a5
ffffffffc02046f8:	4585                	li	a1,1
ffffffffc02046fa:	fd0fd0ef          	jal	ra,ffffffffc0201eca <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02046fe:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0204702:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204706:	078a                	slli	a5,a5,0x2
ffffffffc0204708:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020470a:	18e7ff63          	bleu	a4,a5,ffffffffc02048a8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc020470e:	6008                	ld	a0,0(s0)
ffffffffc0204710:	414787b3          	sub	a5,a5,s4
ffffffffc0204714:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0204716:	4585                	li	a1,1
ffffffffc0204718:	953e                	add	a0,a0,a5
ffffffffc020471a:	fb0fd0ef          	jal	ra,ffffffffc0201eca <free_pages>
    pgdir[0] = 0;
ffffffffc020471e:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0204722:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0204726:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc020472a:	8526                	mv	a0,s1
ffffffffc020472c:	b11ff0ef          	jal	ra,ffffffffc020423c <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0204730:	000c5797          	auipc	a5,0xc5
ffffffffc0204734:	d207bc23          	sd	zero,-712(a5) # ffffffffc02c9468 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0204738:	fd8fd0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>
ffffffffc020473c:	1aa99263          	bne	s3,a0,ffffffffc02048e0 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0204740:	00006517          	auipc	a0,0x6
ffffffffc0204744:	74050513          	addi	a0,a0,1856 # ffffffffc020ae80 <default_pmm_manager+0x1010>
ffffffffc0204748:	a4bfb0ef          	jal	ra,ffffffffc0200192 <cprintf>
}
ffffffffc020474c:	7442                	ld	s0,48(sp)
ffffffffc020474e:	70e2                	ld	ra,56(sp)
ffffffffc0204750:	74a2                	ld	s1,40(sp)
ffffffffc0204752:	7902                	ld	s2,32(sp)
ffffffffc0204754:	69e2                	ld	s3,24(sp)
ffffffffc0204756:	6a42                	ld	s4,16(sp)
ffffffffc0204758:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020475a:	00006517          	auipc	a0,0x6
ffffffffc020475e:	74650513          	addi	a0,a0,1862 # ffffffffc020aea0 <default_pmm_manager+0x1030>
}
ffffffffc0204762:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0204764:	a2ffb06f          	j	ffffffffc0200192 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0204768:	00006697          	auipc	a3,0x6
ffffffffc020476c:	56068693          	addi	a3,a3,1376 # ffffffffc020acc8 <default_pmm_manager+0xe58>
ffffffffc0204770:	00005617          	auipc	a2,0x5
ffffffffc0204774:	fb860613          	addi	a2,a2,-72 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0204778:	12200593          	li	a1,290
ffffffffc020477c:	00006517          	auipc	a0,0x6
ffffffffc0204780:	3ac50513          	addi	a0,a0,940 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc0204784:	d05fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0204788:	00006697          	auipc	a3,0x6
ffffffffc020478c:	5c868693          	addi	a3,a3,1480 # ffffffffc020ad50 <default_pmm_manager+0xee0>
ffffffffc0204790:	00005617          	auipc	a2,0x5
ffffffffc0204794:	f9860613          	addi	a2,a2,-104 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0204798:	13200593          	li	a1,306
ffffffffc020479c:	00006517          	auipc	a0,0x6
ffffffffc02047a0:	38c50513          	addi	a0,a0,908 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc02047a4:	ce5fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02047a8:	00006697          	auipc	a3,0x6
ffffffffc02047ac:	5d868693          	addi	a3,a3,1496 # ffffffffc020ad80 <default_pmm_manager+0xf10>
ffffffffc02047b0:	00005617          	auipc	a2,0x5
ffffffffc02047b4:	f7860613          	addi	a2,a2,-136 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02047b8:	13300593          	li	a1,307
ffffffffc02047bc:	00006517          	auipc	a0,0x6
ffffffffc02047c0:	36c50513          	addi	a0,a0,876 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc02047c4:	cc5fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(vma != NULL);
ffffffffc02047c8:	00006697          	auipc	a3,0x6
ffffffffc02047cc:	ed068693          	addi	a3,a3,-304 # ffffffffc020a698 <default_pmm_manager+0x828>
ffffffffc02047d0:	00005617          	auipc	a2,0x5
ffffffffc02047d4:	f5860613          	addi	a2,a2,-168 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02047d8:	15200593          	li	a1,338
ffffffffc02047dc:	00006517          	auipc	a0,0x6
ffffffffc02047e0:	34c50513          	addi	a0,a0,844 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc02047e4:	ca5fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02047e8:	00006697          	auipc	a3,0x6
ffffffffc02047ec:	4c868693          	addi	a3,a3,1224 # ffffffffc020acb0 <default_pmm_manager+0xe40>
ffffffffc02047f0:	00005617          	auipc	a2,0x5
ffffffffc02047f4:	f3860613          	addi	a2,a2,-200 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02047f8:	12000593          	li	a1,288
ffffffffc02047fc:	00006517          	auipc	a0,0x6
ffffffffc0204800:	32c50513          	addi	a0,a0,812 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc0204804:	c85fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma3 == NULL);
ffffffffc0204808:	00006697          	auipc	a3,0x6
ffffffffc020480c:	51868693          	addi	a3,a3,1304 # ffffffffc020ad20 <default_pmm_manager+0xeb0>
ffffffffc0204810:	00005617          	auipc	a2,0x5
ffffffffc0204814:	f1860613          	addi	a2,a2,-232 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0204818:	12c00593          	li	a1,300
ffffffffc020481c:	00006517          	auipc	a0,0x6
ffffffffc0204820:	30c50513          	addi	a0,a0,780 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc0204824:	c65fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma2 != NULL);
ffffffffc0204828:	00006697          	auipc	a3,0x6
ffffffffc020482c:	4e868693          	addi	a3,a3,1256 # ffffffffc020ad10 <default_pmm_manager+0xea0>
ffffffffc0204830:	00005617          	auipc	a2,0x5
ffffffffc0204834:	ef860613          	addi	a2,a2,-264 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0204838:	12a00593          	li	a1,298
ffffffffc020483c:	00006517          	auipc	a0,0x6
ffffffffc0204840:	2ec50513          	addi	a0,a0,748 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc0204844:	c45fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma1 != NULL);
ffffffffc0204848:	00006697          	auipc	a3,0x6
ffffffffc020484c:	4b868693          	addi	a3,a3,1208 # ffffffffc020ad00 <default_pmm_manager+0xe90>
ffffffffc0204850:	00005617          	auipc	a2,0x5
ffffffffc0204854:	ed860613          	addi	a2,a2,-296 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0204858:	12800593          	li	a1,296
ffffffffc020485c:	00006517          	auipc	a0,0x6
ffffffffc0204860:	2cc50513          	addi	a0,a0,716 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc0204864:	c25fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma5 == NULL);
ffffffffc0204868:	00006697          	auipc	a3,0x6
ffffffffc020486c:	4d868693          	addi	a3,a3,1240 # ffffffffc020ad40 <default_pmm_manager+0xed0>
ffffffffc0204870:	00005617          	auipc	a2,0x5
ffffffffc0204874:	eb860613          	addi	a2,a2,-328 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0204878:	13000593          	li	a1,304
ffffffffc020487c:	00006517          	auipc	a0,0x6
ffffffffc0204880:	2ac50513          	addi	a0,a0,684 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc0204884:	c05fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma4 == NULL);
ffffffffc0204888:	00006697          	auipc	a3,0x6
ffffffffc020488c:	4a868693          	addi	a3,a3,1192 # ffffffffc020ad30 <default_pmm_manager+0xec0>
ffffffffc0204890:	00005617          	auipc	a2,0x5
ffffffffc0204894:	e9860613          	addi	a2,a2,-360 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0204898:	12e00593          	li	a1,302
ffffffffc020489c:	00006517          	auipc	a0,0x6
ffffffffc02048a0:	28c50513          	addi	a0,a0,652 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc02048a4:	be5fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02048a8:	00005617          	auipc	a2,0x5
ffffffffc02048ac:	67860613          	addi	a2,a2,1656 # ffffffffc0209f20 <default_pmm_manager+0xb0>
ffffffffc02048b0:	06200593          	li	a1,98
ffffffffc02048b4:	00005517          	auipc	a0,0x5
ffffffffc02048b8:	63450513          	addi	a0,a0,1588 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc02048bc:	bcdfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(mm != NULL);
ffffffffc02048c0:	00006697          	auipc	a3,0x6
ffffffffc02048c4:	da068693          	addi	a3,a3,-608 # ffffffffc020a660 <default_pmm_manager+0x7f0>
ffffffffc02048c8:	00005617          	auipc	a2,0x5
ffffffffc02048cc:	e6060613          	addi	a2,a2,-416 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02048d0:	10c00593          	li	a1,268
ffffffffc02048d4:	00006517          	auipc	a0,0x6
ffffffffc02048d8:	25450513          	addi	a0,a0,596 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc02048dc:	badfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02048e0:	00006697          	auipc	a3,0x6
ffffffffc02048e4:	57868693          	addi	a3,a3,1400 # ffffffffc020ae58 <default_pmm_manager+0xfe8>
ffffffffc02048e8:	00005617          	auipc	a2,0x5
ffffffffc02048ec:	e4060613          	addi	a2,a2,-448 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02048f0:	17000593          	li	a1,368
ffffffffc02048f4:	00006517          	auipc	a0,0x6
ffffffffc02048f8:	23450513          	addi	a0,a0,564 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc02048fc:	b8dfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0204900:	00006697          	auipc	a3,0x6
ffffffffc0204904:	d8868693          	addi	a3,a3,-632 # ffffffffc020a688 <default_pmm_manager+0x818>
ffffffffc0204908:	00005617          	auipc	a2,0x5
ffffffffc020490c:	e2060613          	addi	a2,a2,-480 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0204910:	14f00593          	li	a1,335
ffffffffc0204914:	00006517          	auipc	a0,0x6
ffffffffc0204918:	21450513          	addi	a0,a0,532 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc020491c:	b6dfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0204920:	00006697          	auipc	a3,0x6
ffffffffc0204924:	50868693          	addi	a3,a3,1288 # ffffffffc020ae28 <default_pmm_manager+0xfb8>
ffffffffc0204928:	00005617          	auipc	a2,0x5
ffffffffc020492c:	e0060613          	addi	a2,a2,-512 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0204930:	15700593          	li	a1,343
ffffffffc0204934:	00006517          	auipc	a0,0x6
ffffffffc0204938:	1f450513          	addi	a0,a0,500 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc020493c:	b4dfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    return KADDR(page2pa(page));
ffffffffc0204940:	00005617          	auipc	a2,0x5
ffffffffc0204944:	58060613          	addi	a2,a2,1408 # ffffffffc0209ec0 <default_pmm_manager+0x50>
ffffffffc0204948:	06900593          	li	a1,105
ffffffffc020494c:	00005517          	auipc	a0,0x5
ffffffffc0204950:	59c50513          	addi	a0,a0,1436 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc0204954:	b35fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(sum == 0);
ffffffffc0204958:	00006697          	auipc	a3,0x6
ffffffffc020495c:	4f068693          	addi	a3,a3,1264 # ffffffffc020ae48 <default_pmm_manager+0xfd8>
ffffffffc0204960:	00005617          	auipc	a2,0x5
ffffffffc0204964:	dc860613          	addi	a2,a2,-568 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0204968:	16300593          	li	a1,355
ffffffffc020496c:	00006517          	auipc	a0,0x6
ffffffffc0204970:	1bc50513          	addi	a0,a0,444 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc0204974:	b15fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0204978:	00006697          	auipc	a3,0x6
ffffffffc020497c:	49868693          	addi	a3,a3,1176 # ffffffffc020ae10 <default_pmm_manager+0xfa0>
ffffffffc0204980:	00005617          	auipc	a2,0x5
ffffffffc0204984:	da860613          	addi	a2,a2,-600 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0204988:	14b00593          	li	a1,331
ffffffffc020498c:	00006517          	auipc	a0,0x6
ffffffffc0204990:	19c50513          	addi	a0,a0,412 # ffffffffc020ab28 <default_pmm_manager+0xcb8>
ffffffffc0204994:	af5fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204998 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204998:	7139                	addi	sp,sp,-64
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020499a:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020499c:	f822                	sd	s0,48(sp)
ffffffffc020499e:	f426                	sd	s1,40(sp)
ffffffffc02049a0:	fc06                	sd	ra,56(sp)
ffffffffc02049a2:	f04a                	sd	s2,32(sp)
ffffffffc02049a4:	ec4e                	sd	s3,24(sp)
ffffffffc02049a6:	8432                	mv	s0,a2
ffffffffc02049a8:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02049aa:	f86ff0ef          	jal	ra,ffffffffc0204130 <find_vma>

    pgfault_num++;
ffffffffc02049ae:	000c5797          	auipc	a5,0xc5
ffffffffc02049b2:	96e78793          	addi	a5,a5,-1682 # ffffffffc02c931c <pgfault_num>
ffffffffc02049b6:	439c                	lw	a5,0(a5)
ffffffffc02049b8:	2785                	addiw	a5,a5,1
ffffffffc02049ba:	000c5717          	auipc	a4,0xc5
ffffffffc02049be:	96f72123          	sw	a5,-1694(a4) # ffffffffc02c931c <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02049c2:	c555                	beqz	a0,ffffffffc0204a6e <do_pgfault+0xd6>
ffffffffc02049c4:	651c                	ld	a5,8(a0)
ffffffffc02049c6:	0af46463          	bltu	s0,a5,ffffffffc0204a6e <do_pgfault+0xd6>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02049ca:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02049cc:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02049ce:	8b89                	andi	a5,a5,2
ffffffffc02049d0:	e3a5                	bnez	a5,ffffffffc0204a30 <do_pgfault+0x98>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02049d2:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02049d4:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02049d6:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02049d8:	85a2                	mv	a1,s0
ffffffffc02049da:	4605                	li	a2,1
ffffffffc02049dc:	d74fd0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc02049e0:	c945                	beqz	a0,ffffffffc0204a90 <do_pgfault+0xf8>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc02049e2:	610c                	ld	a1,0(a0)
ffffffffc02049e4:	c5b5                	beqz	a1,ffffffffc0204a50 <do_pgfault+0xb8>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if(swap_init_ok) {
ffffffffc02049e6:	000c5797          	auipc	a5,0xc5
ffffffffc02049ea:	93278793          	addi	a5,a5,-1742 # ffffffffc02c9318 <swap_init_ok>
ffffffffc02049ee:	439c                	lw	a5,0(a5)
ffffffffc02049f0:	2781                	sext.w	a5,a5
ffffffffc02049f2:	c7d9                	beqz	a5,ffffffffc0204a80 <do_pgfault+0xe8>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc02049f4:	0030                	addi	a2,sp,8
ffffffffc02049f6:	85a2                	mv	a1,s0
ffffffffc02049f8:	8526                	mv	a0,s1
            struct Page *page=NULL;
ffffffffc02049fa:	e402                	sd	zero,8(sp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc02049fc:	a34ff0ef          	jal	ra,ffffffffc0203c30 <swap_in>
ffffffffc0204a00:	892a                	mv	s2,a0
ffffffffc0204a02:	e90d                	bnez	a0,ffffffffc0204a34 <do_pgfault+0x9c>
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc0204a04:	65a2                	ld	a1,8(sp)
ffffffffc0204a06:	6c88                	ld	a0,24(s1)
ffffffffc0204a08:	86ce                	mv	a3,s3
ffffffffc0204a0a:	8622                	mv	a2,s0
ffffffffc0204a0c:	b5bfd0ef          	jal	ra,ffffffffc0202566 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0204a10:	6622                	ld	a2,8(sp)
ffffffffc0204a12:	4685                	li	a3,1
ffffffffc0204a14:	85a2                	mv	a1,s0
ffffffffc0204a16:	8526                	mv	a0,s1
ffffffffc0204a18:	8f4ff0ef          	jal	ra,ffffffffc0203b0c <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0204a1c:	67a2                	ld	a5,8(sp)
ffffffffc0204a1e:	ff80                	sd	s0,56(a5)
        }
   }
   ret = 0;
failed:
    return ret;
}
ffffffffc0204a20:	70e2                	ld	ra,56(sp)
ffffffffc0204a22:	7442                	ld	s0,48(sp)
ffffffffc0204a24:	854a                	mv	a0,s2
ffffffffc0204a26:	74a2                	ld	s1,40(sp)
ffffffffc0204a28:	7902                	ld	s2,32(sp)
ffffffffc0204a2a:	69e2                	ld	s3,24(sp)
ffffffffc0204a2c:	6121                	addi	sp,sp,64
ffffffffc0204a2e:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0204a30:	49dd                	li	s3,23
ffffffffc0204a32:	b745                	j	ffffffffc02049d2 <do_pgfault+0x3a>
                cprintf("swap_in in do_pgfault failed\n");
ffffffffc0204a34:	00006517          	auipc	a0,0x6
ffffffffc0204a38:	17c50513          	addi	a0,a0,380 # ffffffffc020abb0 <default_pmm_manager+0xd40>
ffffffffc0204a3c:	f56fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
}
ffffffffc0204a40:	70e2                	ld	ra,56(sp)
ffffffffc0204a42:	7442                	ld	s0,48(sp)
ffffffffc0204a44:	854a                	mv	a0,s2
ffffffffc0204a46:	74a2                	ld	s1,40(sp)
ffffffffc0204a48:	7902                	ld	s2,32(sp)
ffffffffc0204a4a:	69e2                	ld	s3,24(sp)
ffffffffc0204a4c:	6121                	addi	sp,sp,64
ffffffffc0204a4e:	8082                	ret
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204a50:	6c88                	ld	a0,24(s1)
ffffffffc0204a52:	864e                	mv	a2,s3
ffffffffc0204a54:	85a2                	mv	a1,s0
ffffffffc0204a56:	893fe0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
   ret = 0;
ffffffffc0204a5a:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204a5c:	f171                	bnez	a0,ffffffffc0204a20 <do_pgfault+0x88>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204a5e:	00006517          	auipc	a0,0x6
ffffffffc0204a62:	12a50513          	addi	a0,a0,298 # ffffffffc020ab88 <default_pmm_manager+0xd18>
ffffffffc0204a66:	f2cfb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a6a:	5971                	li	s2,-4
            goto failed;
ffffffffc0204a6c:	bf55                	j	ffffffffc0204a20 <do_pgfault+0x88>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204a6e:	85a2                	mv	a1,s0
ffffffffc0204a70:	00006517          	auipc	a0,0x6
ffffffffc0204a74:	0c850513          	addi	a0,a0,200 # ffffffffc020ab38 <default_pmm_manager+0xcc8>
ffffffffc0204a78:	f1afb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    int ret = -E_INVAL;
ffffffffc0204a7c:	5975                	li	s2,-3
        goto failed;
ffffffffc0204a7e:	b74d                	j	ffffffffc0204a20 <do_pgfault+0x88>
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
ffffffffc0204a80:	00006517          	auipc	a0,0x6
ffffffffc0204a84:	15050513          	addi	a0,a0,336 # ffffffffc020abd0 <default_pmm_manager+0xd60>
ffffffffc0204a88:	f0afb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a8c:	5971                	li	s2,-4
            goto failed;
ffffffffc0204a8e:	bf49                	j	ffffffffc0204a20 <do_pgfault+0x88>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204a90:	00006517          	auipc	a0,0x6
ffffffffc0204a94:	0d850513          	addi	a0,a0,216 # ffffffffc020ab68 <default_pmm_manager+0xcf8>
ffffffffc0204a98:	efafb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a9c:	5971                	li	s2,-4
        goto failed;
ffffffffc0204a9e:	b749                	j	ffffffffc0204a20 <do_pgfault+0x88>

ffffffffc0204aa0 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0204aa0:	7179                	addi	sp,sp,-48
ffffffffc0204aa2:	f022                	sd	s0,32(sp)
ffffffffc0204aa4:	f406                	sd	ra,40(sp)
ffffffffc0204aa6:	ec26                	sd	s1,24(sp)
ffffffffc0204aa8:	e84a                	sd	s2,16(sp)
ffffffffc0204aaa:	e44e                	sd	s3,8(sp)
ffffffffc0204aac:	e052                	sd	s4,0(sp)
ffffffffc0204aae:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0204ab0:	c135                	beqz	a0,ffffffffc0204b14 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0204ab2:	002007b7          	lui	a5,0x200
ffffffffc0204ab6:	04f5e663          	bltu	a1,a5,ffffffffc0204b02 <user_mem_check+0x62>
ffffffffc0204aba:	00c584b3          	add	s1,a1,a2
ffffffffc0204abe:	0495f263          	bleu	s1,a1,ffffffffc0204b02 <user_mem_check+0x62>
ffffffffc0204ac2:	4785                	li	a5,1
ffffffffc0204ac4:	07fe                	slli	a5,a5,0x1f
ffffffffc0204ac6:	0297ee63          	bltu	a5,s1,ffffffffc0204b02 <user_mem_check+0x62>
ffffffffc0204aca:	892a                	mv	s2,a0
ffffffffc0204acc:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204ace:	6a05                	lui	s4,0x1
ffffffffc0204ad0:	a821                	j	ffffffffc0204ae8 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204ad2:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204ad6:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204ad8:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204ada:	c685                	beqz	a3,ffffffffc0204b02 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204adc:	c399                	beqz	a5,ffffffffc0204ae2 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204ade:	02e46263          	bltu	s0,a4,ffffffffc0204b02 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0204ae2:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0204ae4:	04947663          	bleu	s1,s0,ffffffffc0204b30 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0204ae8:	85a2                	mv	a1,s0
ffffffffc0204aea:	854a                	mv	a0,s2
ffffffffc0204aec:	e44ff0ef          	jal	ra,ffffffffc0204130 <find_vma>
ffffffffc0204af0:	c909                	beqz	a0,ffffffffc0204b02 <user_mem_check+0x62>
ffffffffc0204af2:	6518                	ld	a4,8(a0)
ffffffffc0204af4:	00e46763          	bltu	s0,a4,ffffffffc0204b02 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204af8:	4d1c                	lw	a5,24(a0)
ffffffffc0204afa:	fc099ce3          	bnez	s3,ffffffffc0204ad2 <user_mem_check+0x32>
ffffffffc0204afe:	8b85                	andi	a5,a5,1
ffffffffc0204b00:	f3ed                	bnez	a5,ffffffffc0204ae2 <user_mem_check+0x42>
            return 0;
ffffffffc0204b02:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0204b04:	70a2                	ld	ra,40(sp)
ffffffffc0204b06:	7402                	ld	s0,32(sp)
ffffffffc0204b08:	64e2                	ld	s1,24(sp)
ffffffffc0204b0a:	6942                	ld	s2,16(sp)
ffffffffc0204b0c:	69a2                	ld	s3,8(sp)
ffffffffc0204b0e:	6a02                	ld	s4,0(sp)
ffffffffc0204b10:	6145                	addi	sp,sp,48
ffffffffc0204b12:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204b14:	c02007b7          	lui	a5,0xc0200
ffffffffc0204b18:	4501                	li	a0,0
ffffffffc0204b1a:	fef5e5e3          	bltu	a1,a5,ffffffffc0204b04 <user_mem_check+0x64>
ffffffffc0204b1e:	962e                	add	a2,a2,a1
ffffffffc0204b20:	fec5f2e3          	bleu	a2,a1,ffffffffc0204b04 <user_mem_check+0x64>
ffffffffc0204b24:	c8000537          	lui	a0,0xc8000
ffffffffc0204b28:	0505                	addi	a0,a0,1
ffffffffc0204b2a:	00a63533          	sltu	a0,a2,a0
ffffffffc0204b2e:	bfd9                	j	ffffffffc0204b04 <user_mem_check+0x64>
        return 1;
ffffffffc0204b30:	4505                	li	a0,1
ffffffffc0204b32:	bfc9                	j	ffffffffc0204b04 <user_mem_check+0x64>

ffffffffc0204b34 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204b34:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b36:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204b38:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b3a:	abdfb0ef          	jal	ra,ffffffffc02005f6 <ide_device_valid>
ffffffffc0204b3e:	cd01                	beqz	a0,ffffffffc0204b56 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b40:	4505                	li	a0,1
ffffffffc0204b42:	abbfb0ef          	jal	ra,ffffffffc02005fc <ide_device_size>
}
ffffffffc0204b46:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b48:	810d                	srli	a0,a0,0x3
ffffffffc0204b4a:	000c5797          	auipc	a5,0xc5
ffffffffc0204b4e:	8ca7b723          	sd	a0,-1842(a5) # ffffffffc02c9418 <max_swap_offset>
}
ffffffffc0204b52:	0141                	addi	sp,sp,16
ffffffffc0204b54:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204b56:	00006617          	auipc	a2,0x6
ffffffffc0204b5a:	36260613          	addi	a2,a2,866 # ffffffffc020aeb8 <default_pmm_manager+0x1048>
ffffffffc0204b5e:	45b5                	li	a1,13
ffffffffc0204b60:	00006517          	auipc	a0,0x6
ffffffffc0204b64:	37850513          	addi	a0,a0,888 # ffffffffc020aed8 <default_pmm_manager+0x1068>
ffffffffc0204b68:	921fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204b6c <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204b6c:	1141                	addi	sp,sp,-16
ffffffffc0204b6e:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b70:	00855793          	srli	a5,a0,0x8
ffffffffc0204b74:	cfb9                	beqz	a5,ffffffffc0204bd2 <swapfs_read+0x66>
ffffffffc0204b76:	000c5717          	auipc	a4,0xc5
ffffffffc0204b7a:	8a270713          	addi	a4,a4,-1886 # ffffffffc02c9418 <max_swap_offset>
ffffffffc0204b7e:	6318                	ld	a4,0(a4)
ffffffffc0204b80:	04e7f963          	bleu	a4,a5,ffffffffc0204bd2 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204b84:	000c5717          	auipc	a4,0xc5
ffffffffc0204b88:	80470713          	addi	a4,a4,-2044 # ffffffffc02c9388 <pages>
ffffffffc0204b8c:	6310                	ld	a2,0(a4)
ffffffffc0204b8e:	00007717          	auipc	a4,0x7
ffffffffc0204b92:	3ea70713          	addi	a4,a4,1002 # ffffffffc020bf78 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204b96:	000c4697          	auipc	a3,0xc4
ffffffffc0204b9a:	77268693          	addi	a3,a3,1906 # ffffffffc02c9308 <npage>
    return page - pages + nbase;
ffffffffc0204b9e:	40c58633          	sub	a2,a1,a2
ffffffffc0204ba2:	630c                	ld	a1,0(a4)
ffffffffc0204ba4:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204ba6:	577d                	li	a4,-1
ffffffffc0204ba8:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204baa:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204bac:	8331                	srli	a4,a4,0xc
ffffffffc0204bae:	8f71                	and	a4,a4,a2
ffffffffc0204bb0:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204bb4:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204bb6:	02d77a63          	bleu	a3,a4,ffffffffc0204bea <swapfs_read+0x7e>
ffffffffc0204bba:	000c4797          	auipc	a5,0xc4
ffffffffc0204bbe:	7be78793          	addi	a5,a5,1982 # ffffffffc02c9378 <va_pa_offset>
ffffffffc0204bc2:	639c                	ld	a5,0(a5)
}
ffffffffc0204bc4:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bc6:	46a1                	li	a3,8
ffffffffc0204bc8:	963e                	add	a2,a2,a5
ffffffffc0204bca:	4505                	li	a0,1
}
ffffffffc0204bcc:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bce:	a35fb06f          	j	ffffffffc0200602 <ide_read_secs>
ffffffffc0204bd2:	86aa                	mv	a3,a0
ffffffffc0204bd4:	00006617          	auipc	a2,0x6
ffffffffc0204bd8:	31c60613          	addi	a2,a2,796 # ffffffffc020aef0 <default_pmm_manager+0x1080>
ffffffffc0204bdc:	45d1                	li	a1,20
ffffffffc0204bde:	00006517          	auipc	a0,0x6
ffffffffc0204be2:	2fa50513          	addi	a0,a0,762 # ffffffffc020aed8 <default_pmm_manager+0x1068>
ffffffffc0204be6:	8a3fb0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0204bea:	86b2                	mv	a3,a2
ffffffffc0204bec:	06900593          	li	a1,105
ffffffffc0204bf0:	00005617          	auipc	a2,0x5
ffffffffc0204bf4:	2d060613          	addi	a2,a2,720 # ffffffffc0209ec0 <default_pmm_manager+0x50>
ffffffffc0204bf8:	00005517          	auipc	a0,0x5
ffffffffc0204bfc:	2f050513          	addi	a0,a0,752 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc0204c00:	889fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204c04 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204c04:	1141                	addi	sp,sp,-16
ffffffffc0204c06:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c08:	00855793          	srli	a5,a0,0x8
ffffffffc0204c0c:	cfb9                	beqz	a5,ffffffffc0204c6a <swapfs_write+0x66>
ffffffffc0204c0e:	000c5717          	auipc	a4,0xc5
ffffffffc0204c12:	80a70713          	addi	a4,a4,-2038 # ffffffffc02c9418 <max_swap_offset>
ffffffffc0204c16:	6318                	ld	a4,0(a4)
ffffffffc0204c18:	04e7f963          	bleu	a4,a5,ffffffffc0204c6a <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204c1c:	000c4717          	auipc	a4,0xc4
ffffffffc0204c20:	76c70713          	addi	a4,a4,1900 # ffffffffc02c9388 <pages>
ffffffffc0204c24:	6310                	ld	a2,0(a4)
ffffffffc0204c26:	00007717          	auipc	a4,0x7
ffffffffc0204c2a:	35270713          	addi	a4,a4,850 # ffffffffc020bf78 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204c2e:	000c4697          	auipc	a3,0xc4
ffffffffc0204c32:	6da68693          	addi	a3,a3,1754 # ffffffffc02c9308 <npage>
    return page - pages + nbase;
ffffffffc0204c36:	40c58633          	sub	a2,a1,a2
ffffffffc0204c3a:	630c                	ld	a1,0(a4)
ffffffffc0204c3c:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204c3e:	577d                	li	a4,-1
ffffffffc0204c40:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204c42:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204c44:	8331                	srli	a4,a4,0xc
ffffffffc0204c46:	8f71                	and	a4,a4,a2
ffffffffc0204c48:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c4c:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204c4e:	02d77a63          	bleu	a3,a4,ffffffffc0204c82 <swapfs_write+0x7e>
ffffffffc0204c52:	000c4797          	auipc	a5,0xc4
ffffffffc0204c56:	72678793          	addi	a5,a5,1830 # ffffffffc02c9378 <va_pa_offset>
ffffffffc0204c5a:	639c                	ld	a5,0(a5)
}
ffffffffc0204c5c:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c5e:	46a1                	li	a3,8
ffffffffc0204c60:	963e                	add	a2,a2,a5
ffffffffc0204c62:	4505                	li	a0,1
}
ffffffffc0204c64:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c66:	9c1fb06f          	j	ffffffffc0200626 <ide_write_secs>
ffffffffc0204c6a:	86aa                	mv	a3,a0
ffffffffc0204c6c:	00006617          	auipc	a2,0x6
ffffffffc0204c70:	28460613          	addi	a2,a2,644 # ffffffffc020aef0 <default_pmm_manager+0x1080>
ffffffffc0204c74:	45e5                	li	a1,25
ffffffffc0204c76:	00006517          	auipc	a0,0x6
ffffffffc0204c7a:	26250513          	addi	a0,a0,610 # ffffffffc020aed8 <default_pmm_manager+0x1068>
ffffffffc0204c7e:	80bfb0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0204c82:	86b2                	mv	a3,a2
ffffffffc0204c84:	06900593          	li	a1,105
ffffffffc0204c88:	00005617          	auipc	a2,0x5
ffffffffc0204c8c:	23860613          	addi	a2,a2,568 # ffffffffc0209ec0 <default_pmm_manager+0x50>
ffffffffc0204c90:	00005517          	auipc	a0,0x5
ffffffffc0204c94:	25850513          	addi	a0,a0,600 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc0204c98:	ff0fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204c9c <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204c9c:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204c9e:	9402                	jalr	s0

	jal do_exit
ffffffffc0204ca0:	75a000ef          	jal	ra,ffffffffc02053fa <do_exit>

ffffffffc0204ca4 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204ca4:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204ca6:	14800513          	li	a0,328
alloc_proc(void) {
ffffffffc0204caa:	e022                	sd	s0,0(sp)
ffffffffc0204cac:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204cae:	f99fc0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
ffffffffc0204cb2:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204cb4:	c149                	beqz	a0,ffffffffc0204d36 <alloc_proc+0x92>
     *     skew_heap_entry_t lab6_run_pool;            // FOR LAB6 ONLY: the entry in the run pool
     *     uint32_t lab6_stride;                       // FOR LAB6 ONLY: the current stride of the process
     *     uint32_t lab6_priority;                     // FOR LAB6 ONLY: the priority of process, set by lab6_set_priority(uint32_t)
     */
        proc->rq = NULL;
        list_init(&(proc->run_link));
ffffffffc0204cb6:	11050793          	addi	a5,a0,272
    elm->prev = elm->next = elm;
ffffffffc0204cba:	10f53c23          	sd	a5,280(a0)
ffffffffc0204cbe:	10f53823          	sd	a5,272(a0)
        proc->time_slice = 0;
        proc->lab6_run_pool.left = proc->lab6_run_pool.right = proc->lab6_run_pool.parent = NULL;
        proc->lab6_stride = 0;
ffffffffc0204cc2:	4785                	li	a5,1
ffffffffc0204cc4:	1782                	slli	a5,a5,0x20
ffffffffc0204cc6:	14f53023          	sd	a5,320(a0)
        proc->lab6_priority = 1;
        //
        proc->state = PROC_UNINIT;
ffffffffc0204cca:	57fd                	li	a5,-1
ffffffffc0204ccc:	1782                	slli	a5,a5,0x20
ffffffffc0204cce:	e11c                	sd	a5,0(a0)
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        proc->mm = NULL; // 进程所用的虚拟内存
        memset(&(proc->context), 0, sizeof(struct context)); // 进程的上下文
ffffffffc0204cd0:	07000613          	li	a2,112
ffffffffc0204cd4:	4581                	li	a1,0
        proc->rq = NULL;
ffffffffc0204cd6:	10053423          	sd	zero,264(a0)
        proc->time_slice = 0;
ffffffffc0204cda:	12052023          	sw	zero,288(a0)
        proc->lab6_run_pool.left = proc->lab6_run_pool.right = proc->lab6_run_pool.parent = NULL;
ffffffffc0204cde:	12053423          	sd	zero,296(a0)
ffffffffc0204ce2:	12053823          	sd	zero,304(a0)
ffffffffc0204ce6:	12053c23          	sd	zero,312(a0)
        proc->runs = 0;
ffffffffc0204cea:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0204cee:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0204cf2:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0204cf6:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0204cfa:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context)); // 进程的上下文
ffffffffc0204cfe:	03050513          	addi	a0,a0,48
ffffffffc0204d02:	40a040ef          	jal	ra,ffffffffc020910c <memset>
        proc->tf = NULL; // 中断帧指针
        proc->cr3 = boot_cr3; // 页目录表地址 设为 内核页目录表基址
ffffffffc0204d06:	000c4797          	auipc	a5,0xc4
ffffffffc0204d0a:	67a78793          	addi	a5,a5,1658 # ffffffffc02c9380 <boot_cr3>
ffffffffc0204d0e:	639c                	ld	a5,0(a5)
        proc->tf = NULL; // 中断帧指针
ffffffffc0204d10:	0a043023          	sd	zero,160(s0)
        proc->flags = 0; // 标志位
ffffffffc0204d14:	0a042823          	sw	zero,176(s0)
        proc->cr3 = boot_cr3; // 页目录表地址 设为 内核页目录表基址
ffffffffc0204d18:	f45c                	sd	a5,168(s0)
        memset(&(proc->name), 0, PROC_NAME_LEN); // 进程名
ffffffffc0204d1a:	463d                	li	a2,15
ffffffffc0204d1c:	4581                	li	a1,0
ffffffffc0204d1e:	0b440513          	addi	a0,s0,180
ffffffffc0204d22:	3ea040ef          	jal	ra,ffffffffc020910c <memset>
        proc->wait_state = 0;  
ffffffffc0204d26:	0e042623          	sw	zero,236(s0)
        proc->cptr = proc->optr = proc->yptr = NULL;
ffffffffc0204d2a:	0e043c23          	sd	zero,248(s0)
ffffffffc0204d2e:	10043023          	sd	zero,256(s0)
ffffffffc0204d32:	0e043823          	sd	zero,240(s0)
    }
    
    return proc;
}
ffffffffc0204d36:	8522                	mv	a0,s0
ffffffffc0204d38:	60a2                	ld	ra,8(sp)
ffffffffc0204d3a:	6402                	ld	s0,0(sp)
ffffffffc0204d3c:	0141                	addi	sp,sp,16
ffffffffc0204d3e:	8082                	ret

ffffffffc0204d40 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204d40:	000c4797          	auipc	a5,0xc4
ffffffffc0204d44:	5e078793          	addi	a5,a5,1504 # ffffffffc02c9320 <current>
ffffffffc0204d48:	639c                	ld	a5,0(a5)
ffffffffc0204d4a:	73c8                	ld	a0,160(a5)
ffffffffc0204d4c:	84efc06f          	j	ffffffffc0200d9a <forkrets>

ffffffffc0204d50 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d50:	000c4797          	auipc	a5,0xc4
ffffffffc0204d54:	5d078793          	addi	a5,a5,1488 # ffffffffc02c9320 <current>
ffffffffc0204d58:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0204d5a:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d5c:	00006617          	auipc	a2,0x6
ffffffffc0204d60:	5bc60613          	addi	a2,a2,1468 # ffffffffc020b318 <default_pmm_manager+0x14a8>
ffffffffc0204d64:	43cc                	lw	a1,4(a5)
ffffffffc0204d66:	00006517          	auipc	a0,0x6
ffffffffc0204d6a:	5c250513          	addi	a0,a0,1474 # ffffffffc020b328 <default_pmm_manager+0x14b8>
user_main(void *arg) {
ffffffffc0204d6e:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d70:	c22fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc0204d74:	00006797          	auipc	a5,0x6
ffffffffc0204d78:	5a478793          	addi	a5,a5,1444 # ffffffffc020b318 <default_pmm_manager+0x14a8>
ffffffffc0204d7c:	3fe06717          	auipc	a4,0x3fe06
ffffffffc0204d80:	0f470713          	addi	a4,a4,244 # ae70 <_binary_obj___user_priority_out_size>
ffffffffc0204d84:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204d86:	853e                	mv	a0,a5
ffffffffc0204d88:	0007b717          	auipc	a4,0x7b
ffffffffc0204d8c:	10870713          	addi	a4,a4,264 # ffffffffc027fe90 <_binary_obj___user_priority_out_start>
ffffffffc0204d90:	f03a                	sd	a4,32(sp)
ffffffffc0204d92:	f43e                	sd	a5,40(sp)
ffffffffc0204d94:	e802                	sd	zero,16(sp)
ffffffffc0204d96:	2d8040ef          	jal	ra,ffffffffc020906e <strlen>
ffffffffc0204d9a:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204d9c:	4511                	li	a0,4
ffffffffc0204d9e:	55a2                	lw	a1,40(sp)
ffffffffc0204da0:	4662                	lw	a2,24(sp)
ffffffffc0204da2:	5682                	lw	a3,32(sp)
ffffffffc0204da4:	4722                	lw	a4,8(sp)
ffffffffc0204da6:	48a9                	li	a7,10
ffffffffc0204da8:	9002                	ebreak
ffffffffc0204daa:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204dac:	65c2                	ld	a1,16(sp)
ffffffffc0204dae:	00006517          	auipc	a0,0x6
ffffffffc0204db2:	5a250513          	addi	a0,a0,1442 # ffffffffc020b350 <default_pmm_manager+0x14e0>
ffffffffc0204db6:	bdcfb0ef          	jal	ra,ffffffffc0200192 <cprintf>
#else
    KERNEL_EXECVE(priority);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204dba:	00006617          	auipc	a2,0x6
ffffffffc0204dbe:	5a660613          	addi	a2,a2,1446 # ffffffffc020b360 <default_pmm_manager+0x14f0>
ffffffffc0204dc2:	36800593          	li	a1,872
ffffffffc0204dc6:	00006517          	auipc	a0,0x6
ffffffffc0204dca:	5ba50513          	addi	a0,a0,1466 # ffffffffc020b380 <default_pmm_manager+0x1510>
ffffffffc0204dce:	ebafb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204dd2 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204dd2:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204dd4:	1141                	addi	sp,sp,-16
ffffffffc0204dd6:	e406                	sd	ra,8(sp)
ffffffffc0204dd8:	c02007b7          	lui	a5,0xc0200
ffffffffc0204ddc:	04f6e263          	bltu	a3,a5,ffffffffc0204e20 <put_pgdir+0x4e>
ffffffffc0204de0:	000c4797          	auipc	a5,0xc4
ffffffffc0204de4:	59878793          	addi	a5,a5,1432 # ffffffffc02c9378 <va_pa_offset>
ffffffffc0204de8:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204dea:	000c4797          	auipc	a5,0xc4
ffffffffc0204dee:	51e78793          	addi	a5,a5,1310 # ffffffffc02c9308 <npage>
ffffffffc0204df2:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0204df4:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204df6:	82b1                	srli	a3,a3,0xc
ffffffffc0204df8:	04f6f063          	bleu	a5,a3,ffffffffc0204e38 <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc0204dfc:	00007797          	auipc	a5,0x7
ffffffffc0204e00:	17c78793          	addi	a5,a5,380 # ffffffffc020bf78 <nbase>
ffffffffc0204e04:	639c                	ld	a5,0(a5)
ffffffffc0204e06:	000c4717          	auipc	a4,0xc4
ffffffffc0204e0a:	58270713          	addi	a4,a4,1410 # ffffffffc02c9388 <pages>
ffffffffc0204e0e:	6308                	ld	a0,0(a4)
}
ffffffffc0204e10:	60a2                	ld	ra,8(sp)
ffffffffc0204e12:	8e9d                	sub	a3,a3,a5
ffffffffc0204e14:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204e16:	4585                	li	a1,1
ffffffffc0204e18:	9536                	add	a0,a0,a3
}
ffffffffc0204e1a:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204e1c:	8aefd06f          	j	ffffffffc0201eca <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204e20:	00005617          	auipc	a2,0x5
ffffffffc0204e24:	0d860613          	addi	a2,a2,216 # ffffffffc0209ef8 <default_pmm_manager+0x88>
ffffffffc0204e28:	06e00593          	li	a1,110
ffffffffc0204e2c:	00005517          	auipc	a0,0x5
ffffffffc0204e30:	0bc50513          	addi	a0,a0,188 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc0204e34:	e54fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204e38:	00005617          	auipc	a2,0x5
ffffffffc0204e3c:	0e860613          	addi	a2,a2,232 # ffffffffc0209f20 <default_pmm_manager+0xb0>
ffffffffc0204e40:	06200593          	li	a1,98
ffffffffc0204e44:	00005517          	auipc	a0,0x5
ffffffffc0204e48:	0a450513          	addi	a0,a0,164 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc0204e4c:	e3cfb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204e50 <setup_pgdir>:
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204e50:	1101                	addi	sp,sp,-32
ffffffffc0204e52:	e426                	sd	s1,8(sp)
ffffffffc0204e54:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL) {
ffffffffc0204e56:	4505                	li	a0,1
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204e58:	ec06                	sd	ra,24(sp)
ffffffffc0204e5a:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL) {
ffffffffc0204e5c:	fe7fc0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0204e60:	c125                	beqz	a0,ffffffffc0204ec0 <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc0204e62:	000c4797          	auipc	a5,0xc4
ffffffffc0204e66:	52678793          	addi	a5,a5,1318 # ffffffffc02c9388 <pages>
ffffffffc0204e6a:	6394                	ld	a3,0(a5)
ffffffffc0204e6c:	00007797          	auipc	a5,0x7
ffffffffc0204e70:	10c78793          	addi	a5,a5,268 # ffffffffc020bf78 <nbase>
ffffffffc0204e74:	6380                	ld	s0,0(a5)
ffffffffc0204e76:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204e7a:	000c4717          	auipc	a4,0xc4
ffffffffc0204e7e:	48e70713          	addi	a4,a4,1166 # ffffffffc02c9308 <npage>
    return page - pages + nbase;
ffffffffc0204e82:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204e84:	57fd                	li	a5,-1
ffffffffc0204e86:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0204e88:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0204e8a:	83b1                	srli	a5,a5,0xc
ffffffffc0204e8c:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e8e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204e90:	02e7fa63          	bleu	a4,a5,ffffffffc0204ec4 <setup_pgdir+0x74>
ffffffffc0204e94:	000c4797          	auipc	a5,0xc4
ffffffffc0204e98:	4e478793          	addi	a5,a5,1252 # ffffffffc02c9378 <va_pa_offset>
ffffffffc0204e9c:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0204e9e:	000c4797          	auipc	a5,0xc4
ffffffffc0204ea2:	46278793          	addi	a5,a5,1122 # ffffffffc02c9300 <boot_pgdir>
ffffffffc0204ea6:	638c                	ld	a1,0(a5)
ffffffffc0204ea8:	9436                	add	s0,s0,a3
ffffffffc0204eaa:	6605                	lui	a2,0x1
ffffffffc0204eac:	8522                	mv	a0,s0
ffffffffc0204eae:	270040ef          	jal	ra,ffffffffc020911e <memcpy>
    return 0;
ffffffffc0204eb2:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc0204eb4:	ec80                	sd	s0,24(s1)
}
ffffffffc0204eb6:	60e2                	ld	ra,24(sp)
ffffffffc0204eb8:	6442                	ld	s0,16(sp)
ffffffffc0204eba:	64a2                	ld	s1,8(sp)
ffffffffc0204ebc:	6105                	addi	sp,sp,32
ffffffffc0204ebe:	8082                	ret
        return -E_NO_MEM;
ffffffffc0204ec0:	5571                	li	a0,-4
ffffffffc0204ec2:	bfd5                	j	ffffffffc0204eb6 <setup_pgdir+0x66>
ffffffffc0204ec4:	00005617          	auipc	a2,0x5
ffffffffc0204ec8:	ffc60613          	addi	a2,a2,-4 # ffffffffc0209ec0 <default_pmm_manager+0x50>
ffffffffc0204ecc:	06900593          	li	a1,105
ffffffffc0204ed0:	00005517          	auipc	a0,0x5
ffffffffc0204ed4:	01850513          	addi	a0,a0,24 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc0204ed8:	db0fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204edc <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204edc:	1101                	addi	sp,sp,-32
ffffffffc0204ede:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ee0:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204ee4:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ee6:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204ee8:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204eea:	8522                	mv	a0,s0
ffffffffc0204eec:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204eee:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ef0:	21c040ef          	jal	ra,ffffffffc020910c <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204ef4:	8522                	mv	a0,s0
}
ffffffffc0204ef6:	6442                	ld	s0,16(sp)
ffffffffc0204ef8:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204efa:	85a6                	mv	a1,s1
}
ffffffffc0204efc:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204efe:	463d                	li	a2,15
}
ffffffffc0204f00:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f02:	21c0406f          	j	ffffffffc020911e <memcpy>

ffffffffc0204f06 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204f06:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc0204f08:	000c4797          	auipc	a5,0xc4
ffffffffc0204f0c:	41878793          	addi	a5,a5,1048 # ffffffffc02c9320 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204f10:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc0204f12:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc0204f14:	ec06                	sd	ra,24(sp)
ffffffffc0204f16:	e822                	sd	s0,16(sp)
ffffffffc0204f18:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc0204f1a:	02a48b63          	beq	s1,a0,ffffffffc0204f50 <proc_run+0x4a>
ffffffffc0204f1e:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f20:	100027f3          	csrr	a5,sstatus
ffffffffc0204f24:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204f26:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f28:	e3a9                	bnez	a5,ffffffffc0204f6a <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204f2a:	745c                	ld	a5,168(s0)
            current = proc; // 将当前进程换为 要切换到的进程
ffffffffc0204f2c:	000c4717          	auipc	a4,0xc4
ffffffffc0204f30:	3e873a23          	sd	s0,1012(a4) # ffffffffc02c9320 <current>
ffffffffc0204f34:	577d                	li	a4,-1
ffffffffc0204f36:	177e                	slli	a4,a4,0x3f
ffffffffc0204f38:	83b1                	srli	a5,a5,0xc
ffffffffc0204f3a:	8fd9                	or	a5,a5,a4
ffffffffc0204f3c:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context)); // 调用 switch_to 进行上下文的保存与切换
ffffffffc0204f40:	03040593          	addi	a1,s0,48
ffffffffc0204f44:	03048513          	addi	a0,s1,48
ffffffffc0204f48:	00a010ef          	jal	ra,ffffffffc0205f52 <switch_to>
    if (flag) {
ffffffffc0204f4c:	00091863          	bnez	s2,ffffffffc0204f5c <proc_run+0x56>
}
ffffffffc0204f50:	60e2                	ld	ra,24(sp)
ffffffffc0204f52:	6442                	ld	s0,16(sp)
ffffffffc0204f54:	64a2                	ld	s1,8(sp)
ffffffffc0204f56:	6902                	ld	s2,0(sp)
ffffffffc0204f58:	6105                	addi	sp,sp,32
ffffffffc0204f5a:	8082                	ret
ffffffffc0204f5c:	6442                	ld	s0,16(sp)
ffffffffc0204f5e:	60e2                	ld	ra,24(sp)
ffffffffc0204f60:	64a2                	ld	s1,8(sp)
ffffffffc0204f62:	6902                	ld	s2,0(sp)
ffffffffc0204f64:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204f66:	ee6fb06f          	j	ffffffffc020064c <intr_enable>
        intr_disable();
ffffffffc0204f6a:	ee8fb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0204f6e:	4905                	li	s2,1
ffffffffc0204f70:	bf6d                	j	ffffffffc0204f2a <proc_run+0x24>

ffffffffc0204f72 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204f72:	0005071b          	sext.w	a4,a0
ffffffffc0204f76:	6789                	lui	a5,0x2
ffffffffc0204f78:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204f7c:	17f9                	addi	a5,a5,-2
ffffffffc0204f7e:	04d7e063          	bltu	a5,a3,ffffffffc0204fbe <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0204f82:	1141                	addi	sp,sp,-16
ffffffffc0204f84:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204f86:	45a9                	li	a1,10
ffffffffc0204f88:	842a                	mv	s0,a0
ffffffffc0204f8a:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc0204f8c:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204f8e:	4d1030ef          	jal	ra,ffffffffc0208c5e <hash32>
ffffffffc0204f92:	02051693          	slli	a3,a0,0x20
ffffffffc0204f96:	82f1                	srli	a3,a3,0x1c
ffffffffc0204f98:	000c0517          	auipc	a0,0xc0
ffffffffc0204f9c:	32850513          	addi	a0,a0,808 # ffffffffc02c52c0 <hash_list>
ffffffffc0204fa0:	96aa                	add	a3,a3,a0
ffffffffc0204fa2:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204fa4:	a029                	j	ffffffffc0204fae <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0204fa6:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x79dc>
ffffffffc0204faa:	00870c63          	beq	a4,s0,ffffffffc0204fc2 <find_proc+0x50>
    return listelm->next;
ffffffffc0204fae:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204fb0:	fef69be3          	bne	a3,a5,ffffffffc0204fa6 <find_proc+0x34>
}
ffffffffc0204fb4:	60a2                	ld	ra,8(sp)
ffffffffc0204fb6:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0204fb8:	4501                	li	a0,0
}
ffffffffc0204fba:	0141                	addi	sp,sp,16
ffffffffc0204fbc:	8082                	ret
    return NULL;
ffffffffc0204fbe:	4501                	li	a0,0
}
ffffffffc0204fc0:	8082                	ret
ffffffffc0204fc2:	60a2                	ld	ra,8(sp)
ffffffffc0204fc4:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204fc6:	f2878513          	addi	a0,a5,-216
}
ffffffffc0204fca:	0141                	addi	sp,sp,16
ffffffffc0204fcc:	8082                	ret

ffffffffc0204fce <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204fce:	7159                	addi	sp,sp,-112
ffffffffc0204fd0:	e0d2                	sd	s4,64(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204fd2:	000c4a17          	auipc	s4,0xc4
ffffffffc0204fd6:	366a0a13          	addi	s4,s4,870 # ffffffffc02c9338 <nr_process>
ffffffffc0204fda:	000a2703          	lw	a4,0(s4)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204fde:	f486                	sd	ra,104(sp)
ffffffffc0204fe0:	f0a2                	sd	s0,96(sp)
ffffffffc0204fe2:	eca6                	sd	s1,88(sp)
ffffffffc0204fe4:	e8ca                	sd	s2,80(sp)
ffffffffc0204fe6:	e4ce                	sd	s3,72(sp)
ffffffffc0204fe8:	fc56                	sd	s5,56(sp)
ffffffffc0204fea:	f85a                	sd	s6,48(sp)
ffffffffc0204fec:	f45e                	sd	s7,40(sp)
ffffffffc0204fee:	f062                	sd	s8,32(sp)
ffffffffc0204ff0:	ec66                	sd	s9,24(sp)
ffffffffc0204ff2:	e86a                	sd	s10,16(sp)
ffffffffc0204ff4:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204ff6:	6785                	lui	a5,0x1
ffffffffc0204ff8:	30f75a63          	ble	a5,a4,ffffffffc020530c <do_fork+0x33e>
ffffffffc0204ffc:	89aa                	mv	s3,a0
ffffffffc0204ffe:	892e                	mv	s2,a1
ffffffffc0205000:	84b2                	mv	s1,a2
   if ((proc = alloc_proc()) == NULL)
ffffffffc0205002:	ca3ff0ef          	jal	ra,ffffffffc0204ca4 <alloc_proc>
ffffffffc0205006:	842a                	mv	s0,a0
ffffffffc0205008:	2e050463          	beqz	a0,ffffffffc02052f0 <do_fork+0x322>
    proc->parent = current; // 设置父进程
ffffffffc020500c:	000c4c17          	auipc	s8,0xc4
ffffffffc0205010:	314c0c13          	addi	s8,s8,788 # ffffffffc02c9320 <current>
ffffffffc0205014:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0);  
ffffffffc0205018:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x881c>
    proc->parent = current; // 设置父进程
ffffffffc020501c:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);  
ffffffffc020501e:	30071563          	bnez	a4,ffffffffc0205328 <do_fork+0x35a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0205022:	4509                	li	a0,2
ffffffffc0205024:	e1ffc0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
    if (page != NULL) {
ffffffffc0205028:	2c050163          	beqz	a0,ffffffffc02052ea <do_fork+0x31c>
    return page - pages + nbase;
ffffffffc020502c:	000c4a97          	auipc	s5,0xc4
ffffffffc0205030:	35ca8a93          	addi	s5,s5,860 # ffffffffc02c9388 <pages>
ffffffffc0205034:	000ab683          	ld	a3,0(s5)
ffffffffc0205038:	00007b17          	auipc	s6,0x7
ffffffffc020503c:	f40b0b13          	addi	s6,s6,-192 # ffffffffc020bf78 <nbase>
ffffffffc0205040:	000b3783          	ld	a5,0(s6)
ffffffffc0205044:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0205048:	000c4b97          	auipc	s7,0xc4
ffffffffc020504c:	2c0b8b93          	addi	s7,s7,704 # ffffffffc02c9308 <npage>
    return page - pages + nbase;
ffffffffc0205050:	8699                	srai	a3,a3,0x6
ffffffffc0205052:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205054:	000bb703          	ld	a4,0(s7)
ffffffffc0205058:	57fd                	li	a5,-1
ffffffffc020505a:	83b1                	srli	a5,a5,0xc
ffffffffc020505c:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020505e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205060:	2ae7f863          	bleu	a4,a5,ffffffffc0205310 <do_fork+0x342>
ffffffffc0205064:	000c4c97          	auipc	s9,0xc4
ffffffffc0205068:	314c8c93          	addi	s9,s9,788 # ffffffffc02c9378 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc020506c:	000c3703          	ld	a4,0(s8)
ffffffffc0205070:	000cb783          	ld	a5,0(s9)
ffffffffc0205074:	02873c03          	ld	s8,40(a4)
ffffffffc0205078:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc020507a:	e814                	sd	a3,16(s0)
    if (oldmm == NULL) {
ffffffffc020507c:	020c0863          	beqz	s8,ffffffffc02050ac <do_fork+0xde>
    if (clone_flags & CLONE_VM) {
ffffffffc0205080:	1009f993          	andi	s3,s3,256
ffffffffc0205084:	1e098163          	beqz	s3,ffffffffc0205266 <do_fork+0x298>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0205088:	030c2703          	lw	a4,48(s8)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020508c:	018c3783          	ld	a5,24(s8)
ffffffffc0205090:	c02006b7          	lui	a3,0xc0200
ffffffffc0205094:	2705                	addiw	a4,a4,1
ffffffffc0205096:	02ec2823          	sw	a4,48(s8)
    proc->mm = mm;
ffffffffc020509a:	03843423          	sd	s8,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020509e:	2ad7e563          	bltu	a5,a3,ffffffffc0205348 <do_fork+0x37a>
ffffffffc02050a2:	000cb703          	ld	a4,0(s9)
ffffffffc02050a6:	6814                	ld	a3,16(s0)
ffffffffc02050a8:	8f99                	sub	a5,a5,a4
ffffffffc02050aa:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02050ac:	6789                	lui	a5,0x2
ffffffffc02050ae:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7a28>
ffffffffc02050b2:	96be                	add	a3,a3,a5
ffffffffc02050b4:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc02050b6:	87b6                	mv	a5,a3
ffffffffc02050b8:	12048813          	addi	a6,s1,288
ffffffffc02050bc:	6088                	ld	a0,0(s1)
ffffffffc02050be:	648c                	ld	a1,8(s1)
ffffffffc02050c0:	6890                	ld	a2,16(s1)
ffffffffc02050c2:	6c98                	ld	a4,24(s1)
ffffffffc02050c4:	e388                	sd	a0,0(a5)
ffffffffc02050c6:	e78c                	sd	a1,8(a5)
ffffffffc02050c8:	eb90                	sd	a2,16(a5)
ffffffffc02050ca:	ef98                	sd	a4,24(a5)
ffffffffc02050cc:	02048493          	addi	s1,s1,32
ffffffffc02050d0:	02078793          	addi	a5,a5,32
ffffffffc02050d4:	ff0494e3          	bne	s1,a6,ffffffffc02050bc <do_fork+0xee>
    proc->tf->gpr.a0 = 0;
ffffffffc02050d8:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02050dc:	12090e63          	beqz	s2,ffffffffc0205218 <do_fork+0x24a>
ffffffffc02050e0:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02050e4:	00000797          	auipc	a5,0x0
ffffffffc02050e8:	c5c78793          	addi	a5,a5,-932 # ffffffffc0204d40 <forkret>
ffffffffc02050ec:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02050ee:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050f0:	100027f3          	csrr	a5,sstatus
ffffffffc02050f4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02050f6:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050f8:	12079f63          	bnez	a5,ffffffffc0205236 <do_fork+0x268>
    if (++ last_pid >= MAX_PID) {
ffffffffc02050fc:	000b9797          	auipc	a5,0xb9
ffffffffc0205100:	dbc78793          	addi	a5,a5,-580 # ffffffffc02bdeb8 <last_pid.1767>
ffffffffc0205104:	439c                	lw	a5,0(a5)
ffffffffc0205106:	6709                	lui	a4,0x2
ffffffffc0205108:	0017851b          	addiw	a0,a5,1
ffffffffc020510c:	000b9697          	auipc	a3,0xb9
ffffffffc0205110:	daa6a623          	sw	a0,-596(a3) # ffffffffc02bdeb8 <last_pid.1767>
ffffffffc0205114:	14e55263          	ble	a4,a0,ffffffffc0205258 <do_fork+0x28a>
    if (last_pid >= next_safe) {
ffffffffc0205118:	000b9797          	auipc	a5,0xb9
ffffffffc020511c:	da478793          	addi	a5,a5,-604 # ffffffffc02bdebc <next_safe.1766>
ffffffffc0205120:	439c                	lw	a5,0(a5)
ffffffffc0205122:	000c4497          	auipc	s1,0xc4
ffffffffc0205126:	34e48493          	addi	s1,s1,846 # ffffffffc02c9470 <proc_list>
ffffffffc020512a:	06f54063          	blt	a0,a5,ffffffffc020518a <do_fork+0x1bc>
        next_safe = MAX_PID;
ffffffffc020512e:	6789                	lui	a5,0x2
ffffffffc0205130:	000b9717          	auipc	a4,0xb9
ffffffffc0205134:	d8f72623          	sw	a5,-628(a4) # ffffffffc02bdebc <next_safe.1766>
ffffffffc0205138:	4581                	li	a1,0
ffffffffc020513a:	87aa                	mv	a5,a0
ffffffffc020513c:	000c4497          	auipc	s1,0xc4
ffffffffc0205140:	33448493          	addi	s1,s1,820 # ffffffffc02c9470 <proc_list>
    repeat:
ffffffffc0205144:	6889                	lui	a7,0x2
ffffffffc0205146:	882e                	mv	a6,a1
ffffffffc0205148:	6609                	lui	a2,0x2
        le = list;
ffffffffc020514a:	000c4697          	auipc	a3,0xc4
ffffffffc020514e:	32668693          	addi	a3,a3,806 # ffffffffc02c9470 <proc_list>
ffffffffc0205152:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc0205154:	00968f63          	beq	a3,s1,ffffffffc0205172 <do_fork+0x1a4>
            if (proc->pid == last_pid) {
ffffffffc0205158:	f3c6a703          	lw	a4,-196(a3)
ffffffffc020515c:	0ae78963          	beq	a5,a4,ffffffffc020520e <do_fork+0x240>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0205160:	fee7d9e3          	ble	a4,a5,ffffffffc0205152 <do_fork+0x184>
ffffffffc0205164:	fec757e3          	ble	a2,a4,ffffffffc0205152 <do_fork+0x184>
ffffffffc0205168:	6694                	ld	a3,8(a3)
ffffffffc020516a:	863a                	mv	a2,a4
ffffffffc020516c:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc020516e:	fe9695e3          	bne	a3,s1,ffffffffc0205158 <do_fork+0x18a>
ffffffffc0205172:	c591                	beqz	a1,ffffffffc020517e <do_fork+0x1b0>
ffffffffc0205174:	000b9717          	auipc	a4,0xb9
ffffffffc0205178:	d4f72223          	sw	a5,-700(a4) # ffffffffc02bdeb8 <last_pid.1767>
ffffffffc020517c:	853e                	mv	a0,a5
ffffffffc020517e:	00080663          	beqz	a6,ffffffffc020518a <do_fork+0x1bc>
ffffffffc0205182:	000b9797          	auipc	a5,0xb9
ffffffffc0205186:	d2c7ad23          	sw	a2,-710(a5) # ffffffffc02bdebc <next_safe.1766>
        proc->pid = get_pid(); // 这一句话要在前面！！！ 
ffffffffc020518a:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020518c:	45a9                	li	a1,10
ffffffffc020518e:	2501                	sext.w	a0,a0
ffffffffc0205190:	2cf030ef          	jal	ra,ffffffffc0208c5e <hash32>
ffffffffc0205194:	1502                	slli	a0,a0,0x20
ffffffffc0205196:	000c0797          	auipc	a5,0xc0
ffffffffc020519a:	12a78793          	addi	a5,a5,298 # ffffffffc02c52c0 <hash_list>
ffffffffc020519e:	8171                	srli	a0,a0,0x1c
ffffffffc02051a0:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02051a2:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051a4:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02051a6:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc02051aa:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02051ac:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc02051ae:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051b0:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc02051b2:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc02051b6:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc02051b8:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc02051ba:	e21c                	sd	a5,0(a2)
ffffffffc02051bc:	000c4597          	auipc	a1,0xc4
ffffffffc02051c0:	2af5be23          	sd	a5,700(a1) # ffffffffc02c9478 <proc_list+0x8>
    elm->next = next;
ffffffffc02051c4:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc02051c6:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc02051c8:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051cc:	10e43023          	sd	a4,256(s0)
ffffffffc02051d0:	c311                	beqz	a4,ffffffffc02051d4 <do_fork+0x206>
        proc->optr->yptr = proc;
ffffffffc02051d2:	ff60                	sd	s0,248(a4)
    nr_process ++;
ffffffffc02051d4:	000a2783          	lw	a5,0(s4)
    proc->parent->cptr = proc;
ffffffffc02051d8:	fae0                	sd	s0,240(a3)
    nr_process ++;
ffffffffc02051da:	2785                	addiw	a5,a5,1
ffffffffc02051dc:	000c4717          	auipc	a4,0xc4
ffffffffc02051e0:	14f72e23          	sw	a5,348(a4) # ffffffffc02c9338 <nr_process>
    if (flag) {
ffffffffc02051e4:	10091863          	bnez	s2,ffffffffc02052f4 <do_fork+0x326>
    wakeup_proc(proc);
ffffffffc02051e8:	8522                	mv	a0,s0
ffffffffc02051ea:	7ea030ef          	jal	ra,ffffffffc02089d4 <wakeup_proc>
    ret = proc->pid;
ffffffffc02051ee:	4048                	lw	a0,4(s0)
}
ffffffffc02051f0:	70a6                	ld	ra,104(sp)
ffffffffc02051f2:	7406                	ld	s0,96(sp)
ffffffffc02051f4:	64e6                	ld	s1,88(sp)
ffffffffc02051f6:	6946                	ld	s2,80(sp)
ffffffffc02051f8:	69a6                	ld	s3,72(sp)
ffffffffc02051fa:	6a06                	ld	s4,64(sp)
ffffffffc02051fc:	7ae2                	ld	s5,56(sp)
ffffffffc02051fe:	7b42                	ld	s6,48(sp)
ffffffffc0205200:	7ba2                	ld	s7,40(sp)
ffffffffc0205202:	7c02                	ld	s8,32(sp)
ffffffffc0205204:	6ce2                	ld	s9,24(sp)
ffffffffc0205206:	6d42                	ld	s10,16(sp)
ffffffffc0205208:	6da2                	ld	s11,8(sp)
ffffffffc020520a:	6165                	addi	sp,sp,112
ffffffffc020520c:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc020520e:	2785                	addiw	a5,a5,1
ffffffffc0205210:	0ec7d563          	ble	a2,a5,ffffffffc02052fa <do_fork+0x32c>
ffffffffc0205214:	4585                	li	a1,1
ffffffffc0205216:	bf35                	j	ffffffffc0205152 <do_fork+0x184>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205218:	8936                	mv	s2,a3
ffffffffc020521a:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020521e:	00000797          	auipc	a5,0x0
ffffffffc0205222:	b2278793          	addi	a5,a5,-1246 # ffffffffc0204d40 <forkret>
ffffffffc0205226:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205228:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020522a:	100027f3          	csrr	a5,sstatus
ffffffffc020522e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205230:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205232:	ec0785e3          	beqz	a5,ffffffffc02050fc <do_fork+0x12e>
        intr_disable();
ffffffffc0205236:	c1cfb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc020523a:	000b9797          	auipc	a5,0xb9
ffffffffc020523e:	c7e78793          	addi	a5,a5,-898 # ffffffffc02bdeb8 <last_pid.1767>
ffffffffc0205242:	439c                	lw	a5,0(a5)
ffffffffc0205244:	6709                	lui	a4,0x2
        return 1;
ffffffffc0205246:	4905                	li	s2,1
ffffffffc0205248:	0017851b          	addiw	a0,a5,1
ffffffffc020524c:	000b9697          	auipc	a3,0xb9
ffffffffc0205250:	c6a6a623          	sw	a0,-916(a3) # ffffffffc02bdeb8 <last_pid.1767>
ffffffffc0205254:	ece542e3          	blt	a0,a4,ffffffffc0205118 <do_fork+0x14a>
        last_pid = 1;
ffffffffc0205258:	4785                	li	a5,1
ffffffffc020525a:	000b9717          	auipc	a4,0xb9
ffffffffc020525e:	c4f72f23          	sw	a5,-930(a4) # ffffffffc02bdeb8 <last_pid.1767>
ffffffffc0205262:	4505                	li	a0,1
ffffffffc0205264:	b5e9                	j	ffffffffc020512e <do_fork+0x160>
    if ((mm = mm_create()) == NULL) {
ffffffffc0205266:	e51fe0ef          	jal	ra,ffffffffc02040b6 <mm_create>
ffffffffc020526a:	8d2a                	mv	s10,a0
ffffffffc020526c:	c539                	beqz	a0,ffffffffc02052ba <do_fork+0x2ec>
    if (setup_pgdir(mm) != 0) {
ffffffffc020526e:	be3ff0ef          	jal	ra,ffffffffc0204e50 <setup_pgdir>
ffffffffc0205272:	e949                	bnez	a0,ffffffffc0205304 <do_fork+0x336>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc0205274:	038c0d93          	addi	s11,s8,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0205278:	4785                	li	a5,1
ffffffffc020527a:	40fdb7af          	amoor.d	a5,a5,(s11)
ffffffffc020527e:	8b85                	andi	a5,a5,1
ffffffffc0205280:	4985                	li	s3,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc0205282:	c799                	beqz	a5,ffffffffc0205290 <do_fork+0x2c2>
        schedule();
ffffffffc0205284:	00b030ef          	jal	ra,ffffffffc0208a8e <schedule>
ffffffffc0205288:	413db7af          	amoor.d	a5,s3,(s11)
ffffffffc020528c:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc020528e:	fbfd                	bnez	a5,ffffffffc0205284 <do_fork+0x2b6>
        ret = dup_mmap(mm, oldmm);
ffffffffc0205290:	85e2                	mv	a1,s8
ffffffffc0205292:	856a                	mv	a0,s10
ffffffffc0205294:	8acff0ef          	jal	ra,ffffffffc0204340 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0205298:	57f9                	li	a5,-2
ffffffffc020529a:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc020529e:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc02052a0:	c3e9                	beqz	a5,ffffffffc0205362 <do_fork+0x394>
    if (ret != 0) {
ffffffffc02052a2:	8c6a                	mv	s8,s10
ffffffffc02052a4:	de0502e3          	beqz	a0,ffffffffc0205088 <do_fork+0xba>
    exit_mmap(mm);
ffffffffc02052a8:	856a                	mv	a0,s10
ffffffffc02052aa:	932ff0ef          	jal	ra,ffffffffc02043dc <exit_mmap>
    put_pgdir(mm);
ffffffffc02052ae:	856a                	mv	a0,s10
ffffffffc02052b0:	b23ff0ef          	jal	ra,ffffffffc0204dd2 <put_pgdir>
    mm_destroy(mm);
ffffffffc02052b4:	856a                	mv	a0,s10
ffffffffc02052b6:	f87fe0ef          	jal	ra,ffffffffc020423c <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02052ba:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02052bc:	c02007b7          	lui	a5,0xc0200
ffffffffc02052c0:	0cf6e963          	bltu	a3,a5,ffffffffc0205392 <do_fork+0x3c4>
ffffffffc02052c4:	000cb783          	ld	a5,0(s9)
    if (PPN(pa) >= npage) {
ffffffffc02052c8:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc02052cc:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02052d0:	83b1                	srli	a5,a5,0xc
ffffffffc02052d2:	0ae7f463          	bleu	a4,a5,ffffffffc020537a <do_fork+0x3ac>
    return &pages[PPN(pa) - nbase];
ffffffffc02052d6:	000b3703          	ld	a4,0(s6)
ffffffffc02052da:	000ab503          	ld	a0,0(s5)
ffffffffc02052de:	4589                	li	a1,2
ffffffffc02052e0:	8f99                	sub	a5,a5,a4
ffffffffc02052e2:	079a                	slli	a5,a5,0x6
ffffffffc02052e4:	953e                	add	a0,a0,a5
ffffffffc02052e6:	be5fc0ef          	jal	ra,ffffffffc0201eca <free_pages>
    kfree(proc);
ffffffffc02052ea:	8522                	mv	a0,s0
ffffffffc02052ec:	a17fc0ef          	jal	ra,ffffffffc0201d02 <kfree>
    ret = -E_NO_MEM;
ffffffffc02052f0:	5571                	li	a0,-4
    return ret;
ffffffffc02052f2:	bdfd                	j	ffffffffc02051f0 <do_fork+0x222>
        intr_enable();
ffffffffc02052f4:	b58fb0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc02052f8:	bdc5                	j	ffffffffc02051e8 <do_fork+0x21a>
                    if (last_pid >= MAX_PID) {
ffffffffc02052fa:	0117c363          	blt	a5,a7,ffffffffc0205300 <do_fork+0x332>
                        last_pid = 1;
ffffffffc02052fe:	4785                	li	a5,1
                    goto repeat;
ffffffffc0205300:	4585                	li	a1,1
ffffffffc0205302:	b591                	j	ffffffffc0205146 <do_fork+0x178>
    mm_destroy(mm);
ffffffffc0205304:	856a                	mv	a0,s10
ffffffffc0205306:	f37fe0ef          	jal	ra,ffffffffc020423c <mm_destroy>
ffffffffc020530a:	bf45                	j	ffffffffc02052ba <do_fork+0x2ec>
    int ret = -E_NO_FREE_PROC;
ffffffffc020530c:	556d                	li	a0,-5
ffffffffc020530e:	b5cd                	j	ffffffffc02051f0 <do_fork+0x222>
    return KADDR(page2pa(page));
ffffffffc0205310:	00005617          	auipc	a2,0x5
ffffffffc0205314:	bb060613          	addi	a2,a2,-1104 # ffffffffc0209ec0 <default_pmm_manager+0x50>
ffffffffc0205318:	06900593          	li	a1,105
ffffffffc020531c:	00005517          	auipc	a0,0x5
ffffffffc0205320:	bcc50513          	addi	a0,a0,-1076 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc0205324:	964fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(current->wait_state == 0);  
ffffffffc0205328:	00006697          	auipc	a3,0x6
ffffffffc020532c:	db068693          	addi	a3,a3,-592 # ffffffffc020b0d8 <default_pmm_manager+0x1268>
ffffffffc0205330:	00004617          	auipc	a2,0x4
ffffffffc0205334:	3f860613          	addi	a2,a2,1016 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0205338:	1c500593          	li	a1,453
ffffffffc020533c:	00006517          	auipc	a0,0x6
ffffffffc0205340:	04450513          	addi	a0,a0,68 # ffffffffc020b380 <default_pmm_manager+0x1510>
ffffffffc0205344:	944fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205348:	86be                	mv	a3,a5
ffffffffc020534a:	00005617          	auipc	a2,0x5
ffffffffc020534e:	bae60613          	addi	a2,a2,-1106 # ffffffffc0209ef8 <default_pmm_manager+0x88>
ffffffffc0205352:	17800593          	li	a1,376
ffffffffc0205356:	00006517          	auipc	a0,0x6
ffffffffc020535a:	02a50513          	addi	a0,a0,42 # ffffffffc020b380 <default_pmm_manager+0x1510>
ffffffffc020535e:	92afb0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("Unlock failed.\n");
ffffffffc0205362:	00006617          	auipc	a2,0x6
ffffffffc0205366:	d9660613          	addi	a2,a2,-618 # ffffffffc020b0f8 <default_pmm_manager+0x1288>
ffffffffc020536a:	03200593          	li	a1,50
ffffffffc020536e:	00006517          	auipc	a0,0x6
ffffffffc0205372:	d9a50513          	addi	a0,a0,-614 # ffffffffc020b108 <default_pmm_manager+0x1298>
ffffffffc0205376:	912fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020537a:	00005617          	auipc	a2,0x5
ffffffffc020537e:	ba660613          	addi	a2,a2,-1114 # ffffffffc0209f20 <default_pmm_manager+0xb0>
ffffffffc0205382:	06200593          	li	a1,98
ffffffffc0205386:	00005517          	auipc	a0,0x5
ffffffffc020538a:	b6250513          	addi	a0,a0,-1182 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc020538e:	8fafb0ef          	jal	ra,ffffffffc0200488 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205392:	00005617          	auipc	a2,0x5
ffffffffc0205396:	b6660613          	addi	a2,a2,-1178 # ffffffffc0209ef8 <default_pmm_manager+0x88>
ffffffffc020539a:	06e00593          	li	a1,110
ffffffffc020539e:	00005517          	auipc	a0,0x5
ffffffffc02053a2:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc02053a6:	8e2fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02053aa <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02053aa:	7129                	addi	sp,sp,-320
ffffffffc02053ac:	fa22                	sd	s0,304(sp)
ffffffffc02053ae:	f626                	sd	s1,296(sp)
ffffffffc02053b0:	f24a                	sd	s2,288(sp)
ffffffffc02053b2:	84ae                	mv	s1,a1
ffffffffc02053b4:	892a                	mv	s2,a0
ffffffffc02053b6:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02053b8:	4581                	li	a1,0
ffffffffc02053ba:	12000613          	li	a2,288
ffffffffc02053be:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02053c0:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02053c2:	54b030ef          	jal	ra,ffffffffc020910c <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02053c6:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02053c8:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02053ca:	100027f3          	csrr	a5,sstatus
ffffffffc02053ce:	edd7f793          	andi	a5,a5,-291
ffffffffc02053d2:	1207e793          	ori	a5,a5,288
ffffffffc02053d6:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053d8:	860a                	mv	a2,sp
ffffffffc02053da:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02053de:	00000797          	auipc	a5,0x0
ffffffffc02053e2:	8be78793          	addi	a5,a5,-1858 # ffffffffc0204c9c <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053e6:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02053e8:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053ea:	be5ff0ef          	jal	ra,ffffffffc0204fce <do_fork>
}
ffffffffc02053ee:	70f2                	ld	ra,312(sp)
ffffffffc02053f0:	7452                	ld	s0,304(sp)
ffffffffc02053f2:	74b2                	ld	s1,296(sp)
ffffffffc02053f4:	7912                	ld	s2,288(sp)
ffffffffc02053f6:	6131                	addi	sp,sp,320
ffffffffc02053f8:	8082                	ret

ffffffffc02053fa <do_exit>:
do_exit(int error_code) {
ffffffffc02053fa:	7179                	addi	sp,sp,-48
ffffffffc02053fc:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc02053fe:	000c4717          	auipc	a4,0xc4
ffffffffc0205402:	f2a70713          	addi	a4,a4,-214 # ffffffffc02c9328 <idleproc>
ffffffffc0205406:	000c4917          	auipc	s2,0xc4
ffffffffc020540a:	f1a90913          	addi	s2,s2,-230 # ffffffffc02c9320 <current>
ffffffffc020540e:	00093783          	ld	a5,0(s2)
ffffffffc0205412:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc0205414:	f406                	sd	ra,40(sp)
ffffffffc0205416:	f022                	sd	s0,32(sp)
ffffffffc0205418:	ec26                	sd	s1,24(sp)
ffffffffc020541a:	e44e                	sd	s3,8(sp)
ffffffffc020541c:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc020541e:	0ce78c63          	beq	a5,a4,ffffffffc02054f6 <do_exit+0xfc>
    if (current == initproc) {
ffffffffc0205422:	000c4417          	auipc	s0,0xc4
ffffffffc0205426:	f0e40413          	addi	s0,s0,-242 # ffffffffc02c9330 <initproc>
ffffffffc020542a:	6018                	ld	a4,0(s0)
ffffffffc020542c:	0ee78b63          	beq	a5,a4,ffffffffc0205522 <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc0205430:	7784                	ld	s1,40(a5)
ffffffffc0205432:	89aa                	mv	s3,a0
    if (mm != NULL) {
ffffffffc0205434:	c48d                	beqz	s1,ffffffffc020545e <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc0205436:	000c4797          	auipc	a5,0xc4
ffffffffc020543a:	f4a78793          	addi	a5,a5,-182 # ffffffffc02c9380 <boot_cr3>
ffffffffc020543e:	639c                	ld	a5,0(a5)
ffffffffc0205440:	577d                	li	a4,-1
ffffffffc0205442:	177e                	slli	a4,a4,0x3f
ffffffffc0205444:	83b1                	srli	a5,a5,0xc
ffffffffc0205446:	8fd9                	or	a5,a5,a4
ffffffffc0205448:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc020544c:	589c                	lw	a5,48(s1)
ffffffffc020544e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205452:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205454:	cf4d                	beqz	a4,ffffffffc020550e <do_exit+0x114>
        current->mm = NULL;
ffffffffc0205456:	00093783          	ld	a5,0(s2)
ffffffffc020545a:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc020545e:	00093783          	ld	a5,0(s2)
ffffffffc0205462:	470d                	li	a4,3
ffffffffc0205464:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0205466:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020546a:	100027f3          	csrr	a5,sstatus
ffffffffc020546e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205470:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205472:	e7e1                	bnez	a5,ffffffffc020553a <do_exit+0x140>
        proc = current->parent;
ffffffffc0205474:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205478:	800007b7          	lui	a5,0x80000
ffffffffc020547c:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc020547e:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205480:	0ec52703          	lw	a4,236(a0)
ffffffffc0205484:	0af70f63          	beq	a4,a5,ffffffffc0205542 <do_exit+0x148>
ffffffffc0205488:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020548c:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205490:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205492:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) {
ffffffffc0205494:	7afc                	ld	a5,240(a3)
ffffffffc0205496:	cb95                	beqz	a5,ffffffffc02054ca <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc0205498:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_matrix_out_size+0xffffffff7fff4690>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020549c:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc020549e:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02054a0:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc02054a2:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02054a6:	10e7b023          	sd	a4,256(a5)
ffffffffc02054aa:	c311                	beqz	a4,ffffffffc02054ae <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc02054ac:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054ae:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02054b0:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02054b2:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054b4:	fe9710e3          	bne	a4,s1,ffffffffc0205494 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02054b8:	0ec52783          	lw	a5,236(a0)
ffffffffc02054bc:	fd379ce3          	bne	a5,s3,ffffffffc0205494 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc02054c0:	514030ef          	jal	ra,ffffffffc02089d4 <wakeup_proc>
ffffffffc02054c4:	00093683          	ld	a3,0(s2)
ffffffffc02054c8:	b7f1                	j	ffffffffc0205494 <do_exit+0x9a>
    if (flag) {
ffffffffc02054ca:	020a1363          	bnez	s4,ffffffffc02054f0 <do_exit+0xf6>
    schedule();
ffffffffc02054ce:	5c0030ef          	jal	ra,ffffffffc0208a8e <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc02054d2:	00093783          	ld	a5,0(s2)
ffffffffc02054d6:	00006617          	auipc	a2,0x6
ffffffffc02054da:	be260613          	addi	a2,a2,-1054 # ffffffffc020b0b8 <default_pmm_manager+0x1248>
ffffffffc02054de:	22000593          	li	a1,544
ffffffffc02054e2:	43d4                	lw	a3,4(a5)
ffffffffc02054e4:	00006517          	auipc	a0,0x6
ffffffffc02054e8:	e9c50513          	addi	a0,a0,-356 # ffffffffc020b380 <default_pmm_manager+0x1510>
ffffffffc02054ec:	f9dfa0ef          	jal	ra,ffffffffc0200488 <__panic>
        intr_enable();
ffffffffc02054f0:	95cfb0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc02054f4:	bfe9                	j	ffffffffc02054ce <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc02054f6:	00006617          	auipc	a2,0x6
ffffffffc02054fa:	ba260613          	addi	a2,a2,-1118 # ffffffffc020b098 <default_pmm_manager+0x1228>
ffffffffc02054fe:	1f400593          	li	a1,500
ffffffffc0205502:	00006517          	auipc	a0,0x6
ffffffffc0205506:	e7e50513          	addi	a0,a0,-386 # ffffffffc020b380 <default_pmm_manager+0x1510>
ffffffffc020550a:	f7ffa0ef          	jal	ra,ffffffffc0200488 <__panic>
            exit_mmap(mm);
ffffffffc020550e:	8526                	mv	a0,s1
ffffffffc0205510:	ecdfe0ef          	jal	ra,ffffffffc02043dc <exit_mmap>
            put_pgdir(mm);
ffffffffc0205514:	8526                	mv	a0,s1
ffffffffc0205516:	8bdff0ef          	jal	ra,ffffffffc0204dd2 <put_pgdir>
            mm_destroy(mm);
ffffffffc020551a:	8526                	mv	a0,s1
ffffffffc020551c:	d21fe0ef          	jal	ra,ffffffffc020423c <mm_destroy>
ffffffffc0205520:	bf1d                	j	ffffffffc0205456 <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc0205522:	00006617          	auipc	a2,0x6
ffffffffc0205526:	b8660613          	addi	a2,a2,-1146 # ffffffffc020b0a8 <default_pmm_manager+0x1238>
ffffffffc020552a:	1f700593          	li	a1,503
ffffffffc020552e:	00006517          	auipc	a0,0x6
ffffffffc0205532:	e5250513          	addi	a0,a0,-430 # ffffffffc020b380 <default_pmm_manager+0x1510>
ffffffffc0205536:	f53fa0ef          	jal	ra,ffffffffc0200488 <__panic>
        intr_disable();
ffffffffc020553a:	918fb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc020553e:	4a05                	li	s4,1
ffffffffc0205540:	bf15                	j	ffffffffc0205474 <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc0205542:	492030ef          	jal	ra,ffffffffc02089d4 <wakeup_proc>
ffffffffc0205546:	b789                	j	ffffffffc0205488 <do_exit+0x8e>

ffffffffc0205548 <do_wait.part.1>:
do_wait(int pid, int *code_store) {
ffffffffc0205548:	7139                	addi	sp,sp,-64
ffffffffc020554a:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc020554c:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc0205550:	f426                	sd	s1,40(sp)
ffffffffc0205552:	f04a                	sd	s2,32(sp)
ffffffffc0205554:	ec4e                	sd	s3,24(sp)
ffffffffc0205556:	e456                	sd	s5,8(sp)
ffffffffc0205558:	e05a                	sd	s6,0(sp)
ffffffffc020555a:	fc06                	sd	ra,56(sp)
ffffffffc020555c:	f822                	sd	s0,48(sp)
ffffffffc020555e:	89aa                	mv	s3,a0
ffffffffc0205560:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc0205562:	000c4917          	auipc	s2,0xc4
ffffffffc0205566:	dbe90913          	addi	s2,s2,-578 # ffffffffc02c9320 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020556a:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc020556c:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc020556e:	2a05                	addiw	s4,s4,1
    if (pid != 0) {
ffffffffc0205570:	02098f63          	beqz	s3,ffffffffc02055ae <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc0205574:	854e                	mv	a0,s3
ffffffffc0205576:	9fdff0ef          	jal	ra,ffffffffc0204f72 <find_proc>
ffffffffc020557a:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc020557c:	12050063          	beqz	a0,ffffffffc020569c <do_wait.part.1+0x154>
ffffffffc0205580:	00093703          	ld	a4,0(s2)
ffffffffc0205584:	711c                	ld	a5,32(a0)
ffffffffc0205586:	10e79b63          	bne	a5,a4,ffffffffc020569c <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020558a:	411c                	lw	a5,0(a0)
ffffffffc020558c:	02978c63          	beq	a5,s1,ffffffffc02055c4 <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc0205590:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc0205594:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc0205598:	4f6030ef          	jal	ra,ffffffffc0208a8e <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc020559c:	00093783          	ld	a5,0(s2)
ffffffffc02055a0:	0b07a783          	lw	a5,176(a5)
ffffffffc02055a4:	8b85                	andi	a5,a5,1
ffffffffc02055a6:	d7e9                	beqz	a5,ffffffffc0205570 <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc02055a8:	555d                	li	a0,-9
ffffffffc02055aa:	e51ff0ef          	jal	ra,ffffffffc02053fa <do_exit>
        proc = current->cptr;
ffffffffc02055ae:	00093703          	ld	a4,0(s2)
ffffffffc02055b2:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc02055b4:	e409                	bnez	s0,ffffffffc02055be <do_wait.part.1+0x76>
ffffffffc02055b6:	a0dd                	j	ffffffffc020569c <do_wait.part.1+0x154>
ffffffffc02055b8:	10043403          	ld	s0,256(s0)
ffffffffc02055bc:	d871                	beqz	s0,ffffffffc0205590 <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055be:	401c                	lw	a5,0(s0)
ffffffffc02055c0:	fe979ce3          	bne	a5,s1,ffffffffc02055b8 <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc02055c4:	000c4797          	auipc	a5,0xc4
ffffffffc02055c8:	d6478793          	addi	a5,a5,-668 # ffffffffc02c9328 <idleproc>
ffffffffc02055cc:	639c                	ld	a5,0(a5)
ffffffffc02055ce:	0c878d63          	beq	a5,s0,ffffffffc02056a8 <do_wait.part.1+0x160>
ffffffffc02055d2:	000c4797          	auipc	a5,0xc4
ffffffffc02055d6:	d5e78793          	addi	a5,a5,-674 # ffffffffc02c9330 <initproc>
ffffffffc02055da:	639c                	ld	a5,0(a5)
ffffffffc02055dc:	0cf40663          	beq	s0,a5,ffffffffc02056a8 <do_wait.part.1+0x160>
    if (code_store != NULL) {
ffffffffc02055e0:	000b0663          	beqz	s6,ffffffffc02055ec <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc02055e4:	0e842783          	lw	a5,232(s0)
ffffffffc02055e8:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055ec:	100027f3          	csrr	a5,sstatus
ffffffffc02055f0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02055f2:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055f4:	e7d5                	bnez	a5,ffffffffc02056a0 <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc02055f6:	6c70                	ld	a2,216(s0)
ffffffffc02055f8:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc02055fa:	10043703          	ld	a4,256(s0)
ffffffffc02055fe:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0205600:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205602:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0205604:	6470                	ld	a2,200(s0)
ffffffffc0205606:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0205608:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020560a:	e290                	sd	a2,0(a3)
ffffffffc020560c:	c319                	beqz	a4,ffffffffc0205612 <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc020560e:	ff7c                	sd	a5,248(a4)
ffffffffc0205610:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc0205612:	c3d1                	beqz	a5,ffffffffc0205696 <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc0205614:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc0205618:	000c4797          	auipc	a5,0xc4
ffffffffc020561c:	d2078793          	addi	a5,a5,-736 # ffffffffc02c9338 <nr_process>
ffffffffc0205620:	439c                	lw	a5,0(a5)
ffffffffc0205622:	37fd                	addiw	a5,a5,-1
ffffffffc0205624:	000c4717          	auipc	a4,0xc4
ffffffffc0205628:	d0f72a23          	sw	a5,-748(a4) # ffffffffc02c9338 <nr_process>
    if (flag) {
ffffffffc020562c:	e1b5                	bnez	a1,ffffffffc0205690 <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020562e:	6814                	ld	a3,16(s0)
ffffffffc0205630:	c02007b7          	lui	a5,0xc0200
ffffffffc0205634:	0af6e263          	bltu	a3,a5,ffffffffc02056d8 <do_wait.part.1+0x190>
ffffffffc0205638:	000c4797          	auipc	a5,0xc4
ffffffffc020563c:	d4078793          	addi	a5,a5,-704 # ffffffffc02c9378 <va_pa_offset>
ffffffffc0205640:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0205642:	000c4797          	auipc	a5,0xc4
ffffffffc0205646:	cc678793          	addi	a5,a5,-826 # ffffffffc02c9308 <npage>
ffffffffc020564a:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc020564c:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc020564e:	82b1                	srli	a3,a3,0xc
ffffffffc0205650:	06f6f863          	bleu	a5,a3,ffffffffc02056c0 <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc0205654:	00007797          	auipc	a5,0x7
ffffffffc0205658:	92478793          	addi	a5,a5,-1756 # ffffffffc020bf78 <nbase>
ffffffffc020565c:	639c                	ld	a5,0(a5)
ffffffffc020565e:	000c4717          	auipc	a4,0xc4
ffffffffc0205662:	d2a70713          	addi	a4,a4,-726 # ffffffffc02c9388 <pages>
ffffffffc0205666:	6308                	ld	a0,0(a4)
ffffffffc0205668:	8e9d                	sub	a3,a3,a5
ffffffffc020566a:	069a                	slli	a3,a3,0x6
ffffffffc020566c:	9536                	add	a0,a0,a3
ffffffffc020566e:	4589                	li	a1,2
ffffffffc0205670:	85bfc0ef          	jal	ra,ffffffffc0201eca <free_pages>
    kfree(proc);
ffffffffc0205674:	8522                	mv	a0,s0
ffffffffc0205676:	e8cfc0ef          	jal	ra,ffffffffc0201d02 <kfree>
    return 0;
ffffffffc020567a:	4501                	li	a0,0
}
ffffffffc020567c:	70e2                	ld	ra,56(sp)
ffffffffc020567e:	7442                	ld	s0,48(sp)
ffffffffc0205680:	74a2                	ld	s1,40(sp)
ffffffffc0205682:	7902                	ld	s2,32(sp)
ffffffffc0205684:	69e2                	ld	s3,24(sp)
ffffffffc0205686:	6a42                	ld	s4,16(sp)
ffffffffc0205688:	6aa2                	ld	s5,8(sp)
ffffffffc020568a:	6b02                	ld	s6,0(sp)
ffffffffc020568c:	6121                	addi	sp,sp,64
ffffffffc020568e:	8082                	ret
        intr_enable();
ffffffffc0205690:	fbdfa0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0205694:	bf69                	j	ffffffffc020562e <do_wait.part.1+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc0205696:	701c                	ld	a5,32(s0)
ffffffffc0205698:	fbf8                	sd	a4,240(a5)
ffffffffc020569a:	bfbd                	j	ffffffffc0205618 <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc020569c:	5579                	li	a0,-2
ffffffffc020569e:	bff9                	j	ffffffffc020567c <do_wait.part.1+0x134>
        intr_disable();
ffffffffc02056a0:	fb3fa0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc02056a4:	4585                	li	a1,1
ffffffffc02056a6:	bf81                	j	ffffffffc02055f6 <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc02056a8:	00006617          	auipc	a2,0x6
ffffffffc02056ac:	a7860613          	addi	a2,a2,-1416 # ffffffffc020b120 <default_pmm_manager+0x12b0>
ffffffffc02056b0:	31700593          	li	a1,791
ffffffffc02056b4:	00006517          	auipc	a0,0x6
ffffffffc02056b8:	ccc50513          	addi	a0,a0,-820 # ffffffffc020b380 <default_pmm_manager+0x1510>
ffffffffc02056bc:	dcdfa0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02056c0:	00005617          	auipc	a2,0x5
ffffffffc02056c4:	86060613          	addi	a2,a2,-1952 # ffffffffc0209f20 <default_pmm_manager+0xb0>
ffffffffc02056c8:	06200593          	li	a1,98
ffffffffc02056cc:	00005517          	auipc	a0,0x5
ffffffffc02056d0:	81c50513          	addi	a0,a0,-2020 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc02056d4:	db5fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02056d8:	00005617          	auipc	a2,0x5
ffffffffc02056dc:	82060613          	addi	a2,a2,-2016 # ffffffffc0209ef8 <default_pmm_manager+0x88>
ffffffffc02056e0:	06e00593          	li	a1,110
ffffffffc02056e4:	00005517          	auipc	a0,0x5
ffffffffc02056e8:	80450513          	addi	a0,a0,-2044 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc02056ec:	d9dfa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02056f0 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc02056f0:	1141                	addi	sp,sp,-16
ffffffffc02056f2:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02056f4:	81dfc0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02056f8:	d4afc0ef          	jal	ra,ffffffffc0201c42 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02056fc:	4601                	li	a2,0
ffffffffc02056fe:	4581                	li	a1,0
ffffffffc0205700:	fffff517          	auipc	a0,0xfffff
ffffffffc0205704:	65050513          	addi	a0,a0,1616 # ffffffffc0204d50 <user_main>
ffffffffc0205708:	ca3ff0ef          	jal	ra,ffffffffc02053aa <kernel_thread>
    if (pid <= 0) {
ffffffffc020570c:	00a04563          	bgtz	a0,ffffffffc0205716 <init_main+0x26>
ffffffffc0205710:	a841                	j	ffffffffc02057a0 <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc0205712:	37c030ef          	jal	ra,ffffffffc0208a8e <schedule>
    if (code_store != NULL) {
ffffffffc0205716:	4581                	li	a1,0
ffffffffc0205718:	4501                	li	a0,0
ffffffffc020571a:	e2fff0ef          	jal	ra,ffffffffc0205548 <do_wait.part.1>
    while (do_wait(0, NULL) == 0) {
ffffffffc020571e:	d975                	beqz	a0,ffffffffc0205712 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0205720:	00006517          	auipc	a0,0x6
ffffffffc0205724:	a4050513          	addi	a0,a0,-1472 # ffffffffc020b160 <default_pmm_manager+0x12f0>
ffffffffc0205728:	a6bfa0ef          	jal	ra,ffffffffc0200192 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020572c:	000c4797          	auipc	a5,0xc4
ffffffffc0205730:	c0478793          	addi	a5,a5,-1020 # ffffffffc02c9330 <initproc>
ffffffffc0205734:	639c                	ld	a5,0(a5)
ffffffffc0205736:	7bf8                	ld	a4,240(a5)
ffffffffc0205738:	e721                	bnez	a4,ffffffffc0205780 <init_main+0x90>
ffffffffc020573a:	7ff8                	ld	a4,248(a5)
ffffffffc020573c:	e331                	bnez	a4,ffffffffc0205780 <init_main+0x90>
ffffffffc020573e:	1007b703          	ld	a4,256(a5)
ffffffffc0205742:	ef1d                	bnez	a4,ffffffffc0205780 <init_main+0x90>
    assert(nr_process == 2);
ffffffffc0205744:	000c4717          	auipc	a4,0xc4
ffffffffc0205748:	bf470713          	addi	a4,a4,-1036 # ffffffffc02c9338 <nr_process>
ffffffffc020574c:	4314                	lw	a3,0(a4)
ffffffffc020574e:	4709                	li	a4,2
ffffffffc0205750:	0ae69463          	bne	a3,a4,ffffffffc02057f8 <init_main+0x108>
    return listelm->next;
ffffffffc0205754:	000c4697          	auipc	a3,0xc4
ffffffffc0205758:	d1c68693          	addi	a3,a3,-740 # ffffffffc02c9470 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020575c:	6698                	ld	a4,8(a3)
ffffffffc020575e:	0c878793          	addi	a5,a5,200
ffffffffc0205762:	06f71b63          	bne	a4,a5,ffffffffc02057d8 <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205766:	629c                	ld	a5,0(a3)
ffffffffc0205768:	04f71863          	bne	a4,a5,ffffffffc02057b8 <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc020576c:	00006517          	auipc	a0,0x6
ffffffffc0205770:	adc50513          	addi	a0,a0,-1316 # ffffffffc020b248 <default_pmm_manager+0x13d8>
ffffffffc0205774:	a1ffa0ef          	jal	ra,ffffffffc0200192 <cprintf>
    return 0;
}
ffffffffc0205778:	60a2                	ld	ra,8(sp)
ffffffffc020577a:	4501                	li	a0,0
ffffffffc020577c:	0141                	addi	sp,sp,16
ffffffffc020577e:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205780:	00006697          	auipc	a3,0x6
ffffffffc0205784:	a0868693          	addi	a3,a3,-1528 # ffffffffc020b188 <default_pmm_manager+0x1318>
ffffffffc0205788:	00004617          	auipc	a2,0x4
ffffffffc020578c:	fa060613          	addi	a2,a2,-96 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0205790:	37b00593          	li	a1,891
ffffffffc0205794:	00006517          	auipc	a0,0x6
ffffffffc0205798:	bec50513          	addi	a0,a0,-1044 # ffffffffc020b380 <default_pmm_manager+0x1510>
ffffffffc020579c:	cedfa0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("create user_main failed.\n");
ffffffffc02057a0:	00006617          	auipc	a2,0x6
ffffffffc02057a4:	9a060613          	addi	a2,a2,-1632 # ffffffffc020b140 <default_pmm_manager+0x12d0>
ffffffffc02057a8:	37300593          	li	a1,883
ffffffffc02057ac:	00006517          	auipc	a0,0x6
ffffffffc02057b0:	bd450513          	addi	a0,a0,-1068 # ffffffffc020b380 <default_pmm_manager+0x1510>
ffffffffc02057b4:	cd5fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02057b8:	00006697          	auipc	a3,0x6
ffffffffc02057bc:	a6068693          	addi	a3,a3,-1440 # ffffffffc020b218 <default_pmm_manager+0x13a8>
ffffffffc02057c0:	00004617          	auipc	a2,0x4
ffffffffc02057c4:	f6860613          	addi	a2,a2,-152 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02057c8:	37e00593          	li	a1,894
ffffffffc02057cc:	00006517          	auipc	a0,0x6
ffffffffc02057d0:	bb450513          	addi	a0,a0,-1100 # ffffffffc020b380 <default_pmm_manager+0x1510>
ffffffffc02057d4:	cb5fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02057d8:	00006697          	auipc	a3,0x6
ffffffffc02057dc:	a1068693          	addi	a3,a3,-1520 # ffffffffc020b1e8 <default_pmm_manager+0x1378>
ffffffffc02057e0:	00004617          	auipc	a2,0x4
ffffffffc02057e4:	f4860613          	addi	a2,a2,-184 # ffffffffc0209728 <commands+0x4c0>
ffffffffc02057e8:	37d00593          	li	a1,893
ffffffffc02057ec:	00006517          	auipc	a0,0x6
ffffffffc02057f0:	b9450513          	addi	a0,a0,-1132 # ffffffffc020b380 <default_pmm_manager+0x1510>
ffffffffc02057f4:	c95fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_process == 2);
ffffffffc02057f8:	00006697          	auipc	a3,0x6
ffffffffc02057fc:	9e068693          	addi	a3,a3,-1568 # ffffffffc020b1d8 <default_pmm_manager+0x1368>
ffffffffc0205800:	00004617          	auipc	a2,0x4
ffffffffc0205804:	f2860613          	addi	a2,a2,-216 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0205808:	37c00593          	li	a1,892
ffffffffc020580c:	00006517          	auipc	a0,0x6
ffffffffc0205810:	b7450513          	addi	a0,a0,-1164 # ffffffffc020b380 <default_pmm_manager+0x1510>
ffffffffc0205814:	c75fa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0205818 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205818:	7135                	addi	sp,sp,-160
ffffffffc020581a:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020581c:	000c4a17          	auipc	s4,0xc4
ffffffffc0205820:	b04a0a13          	addi	s4,s4,-1276 # ffffffffc02c9320 <current>
ffffffffc0205824:	000a3783          	ld	a5,0(s4)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205828:	e14a                	sd	s2,128(sp)
ffffffffc020582a:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020582c:	0287b903          	ld	s2,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205830:	fcce                	sd	s3,120(sp)
ffffffffc0205832:	f0da                	sd	s6,96(sp)
ffffffffc0205834:	89aa                	mv	s3,a0
ffffffffc0205836:	842e                	mv	s0,a1
ffffffffc0205838:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc020583a:	4681                	li	a3,0
ffffffffc020583c:	862e                	mv	a2,a1
ffffffffc020583e:	85aa                	mv	a1,a0
ffffffffc0205840:	854a                	mv	a0,s2
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205842:	ed06                	sd	ra,152(sp)
ffffffffc0205844:	e526                	sd	s1,136(sp)
ffffffffc0205846:	f4d6                	sd	s5,104(sp)
ffffffffc0205848:	ecde                	sd	s7,88(sp)
ffffffffc020584a:	e8e2                	sd	s8,80(sp)
ffffffffc020584c:	e4e6                	sd	s9,72(sp)
ffffffffc020584e:	e0ea                	sd	s10,64(sp)
ffffffffc0205850:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205852:	a4eff0ef          	jal	ra,ffffffffc0204aa0 <user_mem_check>
ffffffffc0205856:	40050463          	beqz	a0,ffffffffc0205c5e <do_execve+0x446>
    memset(local_name, 0, sizeof(local_name));
ffffffffc020585a:	4641                	li	a2,16
ffffffffc020585c:	4581                	li	a1,0
ffffffffc020585e:	1008                	addi	a0,sp,32
ffffffffc0205860:	0ad030ef          	jal	ra,ffffffffc020910c <memset>
    memcpy(local_name, name, len);
ffffffffc0205864:	47bd                	li	a5,15
ffffffffc0205866:	8622                	mv	a2,s0
ffffffffc0205868:	0687ee63          	bltu	a5,s0,ffffffffc02058e4 <do_execve+0xcc>
ffffffffc020586c:	85ce                	mv	a1,s3
ffffffffc020586e:	1008                	addi	a0,sp,32
ffffffffc0205870:	0af030ef          	jal	ra,ffffffffc020911e <memcpy>
    if (mm != NULL) {
ffffffffc0205874:	06090f63          	beqz	s2,ffffffffc02058f2 <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc0205878:	00005517          	auipc	a0,0x5
ffffffffc020587c:	de850513          	addi	a0,a0,-536 # ffffffffc020a660 <default_pmm_manager+0x7f0>
ffffffffc0205880:	94bfa0ef          	jal	ra,ffffffffc02001ca <cputs>
        lcr3(boot_cr3);
ffffffffc0205884:	000c4797          	auipc	a5,0xc4
ffffffffc0205888:	afc78793          	addi	a5,a5,-1284 # ffffffffc02c9380 <boot_cr3>
ffffffffc020588c:	639c                	ld	a5,0(a5)
ffffffffc020588e:	577d                	li	a4,-1
ffffffffc0205890:	177e                	slli	a4,a4,0x3f
ffffffffc0205892:	83b1                	srli	a5,a5,0xc
ffffffffc0205894:	8fd9                	or	a5,a5,a4
ffffffffc0205896:	18079073          	csrw	satp,a5
ffffffffc020589a:	03092783          	lw	a5,48(s2)
ffffffffc020589e:	fff7871b          	addiw	a4,a5,-1
ffffffffc02058a2:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0) {
ffffffffc02058a6:	28070b63          	beqz	a4,ffffffffc0205b3c <do_execve+0x324>
        current->mm = NULL;
ffffffffc02058aa:	000a3783          	ld	a5,0(s4)
ffffffffc02058ae:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc02058b2:	805fe0ef          	jal	ra,ffffffffc02040b6 <mm_create>
ffffffffc02058b6:	892a                	mv	s2,a0
ffffffffc02058b8:	c135                	beqz	a0,ffffffffc020591c <do_execve+0x104>
    if (setup_pgdir(mm) != 0) {
ffffffffc02058ba:	d96ff0ef          	jal	ra,ffffffffc0204e50 <setup_pgdir>
ffffffffc02058be:	e931                	bnez	a0,ffffffffc0205912 <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02058c0:	000b2703          	lw	a4,0(s6)
ffffffffc02058c4:	464c47b7          	lui	a5,0x464c4
ffffffffc02058c8:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_matrix_out_size+0x464b8b0f>
ffffffffc02058cc:	04f70a63          	beq	a4,a5,ffffffffc0205920 <do_execve+0x108>
    put_pgdir(mm);
ffffffffc02058d0:	854a                	mv	a0,s2
ffffffffc02058d2:	d00ff0ef          	jal	ra,ffffffffc0204dd2 <put_pgdir>
    mm_destroy(mm);
ffffffffc02058d6:	854a                	mv	a0,s2
ffffffffc02058d8:	965fe0ef          	jal	ra,ffffffffc020423c <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc02058dc:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc02058de:	854e                	mv	a0,s3
ffffffffc02058e0:	b1bff0ef          	jal	ra,ffffffffc02053fa <do_exit>
    memcpy(local_name, name, len);
ffffffffc02058e4:	463d                	li	a2,15
ffffffffc02058e6:	85ce                	mv	a1,s3
ffffffffc02058e8:	1008                	addi	a0,sp,32
ffffffffc02058ea:	035030ef          	jal	ra,ffffffffc020911e <memcpy>
    if (mm != NULL) {
ffffffffc02058ee:	f80915e3          	bnez	s2,ffffffffc0205878 <do_execve+0x60>
    if (current->mm != NULL) {
ffffffffc02058f2:	000a3783          	ld	a5,0(s4)
ffffffffc02058f6:	779c                	ld	a5,40(a5)
ffffffffc02058f8:	dfcd                	beqz	a5,ffffffffc02058b2 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc02058fa:	00005617          	auipc	a2,0x5
ffffffffc02058fe:	61660613          	addi	a2,a2,1558 # ffffffffc020af10 <default_pmm_manager+0x10a0>
ffffffffc0205902:	22a00593          	li	a1,554
ffffffffc0205906:	00006517          	auipc	a0,0x6
ffffffffc020590a:	a7a50513          	addi	a0,a0,-1414 # ffffffffc020b380 <default_pmm_manager+0x1510>
ffffffffc020590e:	b7bfa0ef          	jal	ra,ffffffffc0200488 <__panic>
    mm_destroy(mm);
ffffffffc0205912:	854a                	mv	a0,s2
ffffffffc0205914:	929fe0ef          	jal	ra,ffffffffc020423c <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0205918:	59f1                	li	s3,-4
ffffffffc020591a:	b7d1                	j	ffffffffc02058de <do_execve+0xc6>
ffffffffc020591c:	59f1                	li	s3,-4
ffffffffc020591e:	b7c1                	j	ffffffffc02058de <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205920:	038b5703          	lhu	a4,56(s6)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205924:	020b3403          	ld	s0,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205928:	00371793          	slli	a5,a4,0x3
ffffffffc020592c:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020592e:	945a                	add	s0,s0,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205930:	078e                	slli	a5,a5,0x3
ffffffffc0205932:	97a2                	add	a5,a5,s0
ffffffffc0205934:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc0205936:	02f47b63          	bleu	a5,s0,ffffffffc020596c <do_execve+0x154>
    return KADDR(page2pa(page));
ffffffffc020593a:	5bfd                	li	s7,-1
ffffffffc020593c:	00cbd793          	srli	a5,s7,0xc
    return page - pages + nbase;
ffffffffc0205940:	000c4d97          	auipc	s11,0xc4
ffffffffc0205944:	a48d8d93          	addi	s11,s11,-1464 # ffffffffc02c9388 <pages>
ffffffffc0205948:	00006d17          	auipc	s10,0x6
ffffffffc020594c:	630d0d13          	addi	s10,s10,1584 # ffffffffc020bf78 <nbase>
    return KADDR(page2pa(page));
ffffffffc0205950:	e43e                	sd	a5,8(sp)
ffffffffc0205952:	000c4c97          	auipc	s9,0xc4
ffffffffc0205956:	9b6c8c93          	addi	s9,s9,-1610 # ffffffffc02c9308 <npage>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc020595a:	4018                	lw	a4,0(s0)
ffffffffc020595c:	4785                	li	a5,1
ffffffffc020595e:	0ef70d63          	beq	a4,a5,ffffffffc0205a58 <do_execve+0x240>
    for (; ph < ph_end; ph ++) {
ffffffffc0205962:	67e2                	ld	a5,24(sp)
ffffffffc0205964:	03840413          	addi	s0,s0,56
ffffffffc0205968:	fef469e3          	bltu	s0,a5,ffffffffc020595a <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc020596c:	4701                	li	a4,0
ffffffffc020596e:	46ad                	li	a3,11
ffffffffc0205970:	00100637          	lui	a2,0x100
ffffffffc0205974:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205978:	854a                	mv	a0,s2
ffffffffc020597a:	915fe0ef          	jal	ra,ffffffffc020428e <mm_map>
ffffffffc020597e:	89aa                	mv	s3,a0
ffffffffc0205980:	1a051463          	bnez	a0,ffffffffc0205b28 <do_execve+0x310>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205984:	01893503          	ld	a0,24(s2)
ffffffffc0205988:	467d                	li	a2,31
ffffffffc020598a:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc020598e:	95bfd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc0205992:	36050263          	beqz	a0,ffffffffc0205cf6 <do_execve+0x4de>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205996:	01893503          	ld	a0,24(s2)
ffffffffc020599a:	467d                	li	a2,31
ffffffffc020599c:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc02059a0:	949fd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc02059a4:	32050963          	beqz	a0,ffffffffc0205cd6 <do_execve+0x4be>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc02059a8:	01893503          	ld	a0,24(s2)
ffffffffc02059ac:	467d                	li	a2,31
ffffffffc02059ae:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc02059b2:	937fd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc02059b6:	30050063          	beqz	a0,ffffffffc0205cb6 <do_execve+0x49e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc02059ba:	01893503          	ld	a0,24(s2)
ffffffffc02059be:	467d                	li	a2,31
ffffffffc02059c0:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc02059c4:	925fd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc02059c8:	2c050763          	beqz	a0,ffffffffc0205c96 <do_execve+0x47e>
    mm->mm_count += 1;
ffffffffc02059cc:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc02059d0:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059d4:	01893683          	ld	a3,24(s2)
ffffffffc02059d8:	2785                	addiw	a5,a5,1
ffffffffc02059da:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc02059de:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_matrix_out_size+0xf45b8>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059e2:	c02007b7          	lui	a5,0xc0200
ffffffffc02059e6:	28f6ec63          	bltu	a3,a5,ffffffffc0205c7e <do_execve+0x466>
ffffffffc02059ea:	000c4797          	auipc	a5,0xc4
ffffffffc02059ee:	98e78793          	addi	a5,a5,-1650 # ffffffffc02c9378 <va_pa_offset>
ffffffffc02059f2:	639c                	ld	a5,0(a5)
ffffffffc02059f4:	577d                	li	a4,-1
ffffffffc02059f6:	177e                	slli	a4,a4,0x3f
ffffffffc02059f8:	8e9d                	sub	a3,a3,a5
ffffffffc02059fa:	00c6d793          	srli	a5,a3,0xc
ffffffffc02059fe:	f654                	sd	a3,168(a2)
ffffffffc0205a00:	8fd9                	or	a5,a5,a4
ffffffffc0205a02:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205a06:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205a08:	4581                	li	a1,0
ffffffffc0205a0a:	12000613          	li	a2,288
ffffffffc0205a0e:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0205a10:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205a14:	6f8030ef          	jal	ra,ffffffffc020910c <memset>
    tf->epc = elf->e_entry;
ffffffffc0205a18:	018b3703          	ld	a4,24(s6)
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a1c:	4785                	li	a5,1
    set_proc_name(current, local_name);
ffffffffc0205a1e:	000a3503          	ld	a0,0(s4)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0205a22:	edf4f493          	andi	s1,s1,-289
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a26:	07fe                	slli	a5,a5,0x1f
ffffffffc0205a28:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0205a2a:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0205a2e:	10943023          	sd	s1,256(s0)
    set_proc_name(current, local_name);
ffffffffc0205a32:	100c                	addi	a1,sp,32
ffffffffc0205a34:	ca8ff0ef          	jal	ra,ffffffffc0204edc <set_proc_name>
}
ffffffffc0205a38:	60ea                	ld	ra,152(sp)
ffffffffc0205a3a:	644a                	ld	s0,144(sp)
ffffffffc0205a3c:	854e                	mv	a0,s3
ffffffffc0205a3e:	64aa                	ld	s1,136(sp)
ffffffffc0205a40:	690a                	ld	s2,128(sp)
ffffffffc0205a42:	79e6                	ld	s3,120(sp)
ffffffffc0205a44:	7a46                	ld	s4,112(sp)
ffffffffc0205a46:	7aa6                	ld	s5,104(sp)
ffffffffc0205a48:	7b06                	ld	s6,96(sp)
ffffffffc0205a4a:	6be6                	ld	s7,88(sp)
ffffffffc0205a4c:	6c46                	ld	s8,80(sp)
ffffffffc0205a4e:	6ca6                	ld	s9,72(sp)
ffffffffc0205a50:	6d06                	ld	s10,64(sp)
ffffffffc0205a52:	7de2                	ld	s11,56(sp)
ffffffffc0205a54:	610d                	addi	sp,sp,160
ffffffffc0205a56:	8082                	ret
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205a58:	7410                	ld	a2,40(s0)
ffffffffc0205a5a:	701c                	ld	a5,32(s0)
ffffffffc0205a5c:	20f66363          	bltu	a2,a5,ffffffffc0205c62 <do_execve+0x44a>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205a60:	405c                	lw	a5,4(s0)
ffffffffc0205a62:	0017f693          	andi	a3,a5,1
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a66:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205a6a:	068a                	slli	a3,a3,0x2
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a6c:	0e071263          	bnez	a4,ffffffffc0205b50 <do_execve+0x338>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a70:	4745                	li	a4,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a72:	8b91                	andi	a5,a5,4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a74:	e03a                	sd	a4,0(sp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a76:	c789                	beqz	a5,ffffffffc0205a80 <do_execve+0x268>
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205a78:	47cd                	li	a5,19
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a7a:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205a7e:	e03e                	sd	a5,0(sp)
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205a80:	0026f793          	andi	a5,a3,2
ffffffffc0205a84:	efe1                	bnez	a5,ffffffffc0205b5c <do_execve+0x344>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205a86:	0046f793          	andi	a5,a3,4
ffffffffc0205a8a:	c789                	beqz	a5,ffffffffc0205a94 <do_execve+0x27c>
ffffffffc0205a8c:	6782                	ld	a5,0(sp)
ffffffffc0205a8e:	0087e793          	ori	a5,a5,8
ffffffffc0205a92:	e03e                	sd	a5,0(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205a94:	680c                	ld	a1,16(s0)
ffffffffc0205a96:	4701                	li	a4,0
ffffffffc0205a98:	854a                	mv	a0,s2
ffffffffc0205a9a:	ff4fe0ef          	jal	ra,ffffffffc020428e <mm_map>
ffffffffc0205a9e:	89aa                	mv	s3,a0
ffffffffc0205aa0:	e541                	bnez	a0,ffffffffc0205b28 <do_execve+0x310>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205aa2:	01043b83          	ld	s7,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205aa6:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205aaa:	00843a83          	ld	s5,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205aae:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205ab0:	99de                	add	s3,s3,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205ab2:	9ada                	add	s5,s5,s6
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205ab4:	00fbfc33          	and	s8,s7,a5
        while (start < end) {
ffffffffc0205ab8:	053bef63          	bltu	s7,s3,ffffffffc0205b16 <do_execve+0x2fe>
ffffffffc0205abc:	aa79                	j	ffffffffc0205c5a <do_execve+0x442>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205abe:	6785                	lui	a5,0x1
ffffffffc0205ac0:	418b8533          	sub	a0,s7,s8
ffffffffc0205ac4:	9c3e                	add	s8,s8,a5
ffffffffc0205ac6:	417c0833          	sub	a6,s8,s7
            if (end < la) {
ffffffffc0205aca:	0189f463          	bleu	s8,s3,ffffffffc0205ad2 <do_execve+0x2ba>
                size -= la - end;
ffffffffc0205ace:	41798833          	sub	a6,s3,s7
    return page - pages + nbase;
ffffffffc0205ad2:	000db683          	ld	a3,0(s11)
ffffffffc0205ad6:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205ada:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205adc:	40d486b3          	sub	a3,s1,a3
ffffffffc0205ae0:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205ae2:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205ae6:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205ae8:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205aec:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205aee:	16c5fc63          	bleu	a2,a1,ffffffffc0205c66 <do_execve+0x44e>
ffffffffc0205af2:	000c4797          	auipc	a5,0xc4
ffffffffc0205af6:	88678793          	addi	a5,a5,-1914 # ffffffffc02c9378 <va_pa_offset>
ffffffffc0205afa:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205afe:	85d6                	mv	a1,s5
ffffffffc0205b00:	8642                	mv	a2,a6
ffffffffc0205b02:	96c6                	add	a3,a3,a7
ffffffffc0205b04:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205b06:	9bc2                	add	s7,s7,a6
ffffffffc0205b08:	e842                	sd	a6,16(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b0a:	614030ef          	jal	ra,ffffffffc020911e <memcpy>
            start += size, from += size;
ffffffffc0205b0e:	6842                	ld	a6,16(sp)
ffffffffc0205b10:	9ac2                	add	s5,s5,a6
        while (start < end) {
ffffffffc0205b12:	053bf863          	bleu	s3,s7,ffffffffc0205b62 <do_execve+0x34a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205b16:	01893503          	ld	a0,24(s2)
ffffffffc0205b1a:	6602                	ld	a2,0(sp)
ffffffffc0205b1c:	85e2                	mv	a1,s8
ffffffffc0205b1e:	fcafd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc0205b22:	84aa                	mv	s1,a0
ffffffffc0205b24:	fd49                	bnez	a0,ffffffffc0205abe <do_execve+0x2a6>
        ret = -E_NO_MEM;
ffffffffc0205b26:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc0205b28:	854a                	mv	a0,s2
ffffffffc0205b2a:	8b3fe0ef          	jal	ra,ffffffffc02043dc <exit_mmap>
    put_pgdir(mm);
ffffffffc0205b2e:	854a                	mv	a0,s2
ffffffffc0205b30:	aa2ff0ef          	jal	ra,ffffffffc0204dd2 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205b34:	854a                	mv	a0,s2
ffffffffc0205b36:	f06fe0ef          	jal	ra,ffffffffc020423c <mm_destroy>
    return ret;
ffffffffc0205b3a:	b355                	j	ffffffffc02058de <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0205b3c:	854a                	mv	a0,s2
ffffffffc0205b3e:	89ffe0ef          	jal	ra,ffffffffc02043dc <exit_mmap>
            put_pgdir(mm);
ffffffffc0205b42:	854a                	mv	a0,s2
ffffffffc0205b44:	a8eff0ef          	jal	ra,ffffffffc0204dd2 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205b48:	854a                	mv	a0,s2
ffffffffc0205b4a:	ef2fe0ef          	jal	ra,ffffffffc020423c <mm_destroy>
ffffffffc0205b4e:	bbb1                	j	ffffffffc02058aa <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b50:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b54:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b56:	2681                	sext.w	a3,a3
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b58:	f20790e3          	bnez	a5,ffffffffc0205a78 <do_execve+0x260>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205b5c:	47dd                	li	a5,23
ffffffffc0205b5e:	e03e                	sd	a5,0(sp)
ffffffffc0205b60:	b71d                	j	ffffffffc0205a86 <do_execve+0x26e>
ffffffffc0205b62:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc0205b66:	7414                	ld	a3,40(s0)
ffffffffc0205b68:	99b6                	add	s3,s3,a3
        if (start < la) {
ffffffffc0205b6a:	098bf163          	bleu	s8,s7,ffffffffc0205bec <do_execve+0x3d4>
            if (start == end) {
ffffffffc0205b6e:	df798ae3          	beq	s3,s7,ffffffffc0205962 <do_execve+0x14a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205b72:	6505                	lui	a0,0x1
ffffffffc0205b74:	955e                	add	a0,a0,s7
ffffffffc0205b76:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0205b7a:	41798ab3          	sub	s5,s3,s7
            if (end < la) {
ffffffffc0205b7e:	0d89fb63          	bleu	s8,s3,ffffffffc0205c54 <do_execve+0x43c>
    return page - pages + nbase;
ffffffffc0205b82:	000db683          	ld	a3,0(s11)
ffffffffc0205b86:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205b8a:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205b8c:	40d486b3          	sub	a3,s1,a3
ffffffffc0205b90:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205b92:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205b96:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205b98:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b9c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b9e:	0cc5f463          	bleu	a2,a1,ffffffffc0205c66 <do_execve+0x44e>
ffffffffc0205ba2:	000c3617          	auipc	a2,0xc3
ffffffffc0205ba6:	7d660613          	addi	a2,a2,2006 # ffffffffc02c9378 <va_pa_offset>
ffffffffc0205baa:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205bae:	4581                	li	a1,0
ffffffffc0205bb0:	8656                	mv	a2,s5
ffffffffc0205bb2:	96c2                	add	a3,a3,a6
ffffffffc0205bb4:	9536                	add	a0,a0,a3
ffffffffc0205bb6:	556030ef          	jal	ra,ffffffffc020910c <memset>
            start += size;
ffffffffc0205bba:	017a8733          	add	a4,s5,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205bbe:	0389f463          	bleu	s8,s3,ffffffffc0205be6 <do_execve+0x3ce>
ffffffffc0205bc2:	dae980e3          	beq	s3,a4,ffffffffc0205962 <do_execve+0x14a>
ffffffffc0205bc6:	00005697          	auipc	a3,0x5
ffffffffc0205bca:	37268693          	addi	a3,a3,882 # ffffffffc020af38 <default_pmm_manager+0x10c8>
ffffffffc0205bce:	00004617          	auipc	a2,0x4
ffffffffc0205bd2:	b5a60613          	addi	a2,a2,-1190 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0205bd6:	27f00593          	li	a1,639
ffffffffc0205bda:	00005517          	auipc	a0,0x5
ffffffffc0205bde:	7a650513          	addi	a0,a0,1958 # ffffffffc020b380 <default_pmm_manager+0x1510>
ffffffffc0205be2:	8a7fa0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0205be6:	ff8710e3          	bne	a4,s8,ffffffffc0205bc6 <do_execve+0x3ae>
ffffffffc0205bea:	8be2                	mv	s7,s8
ffffffffc0205bec:	000c3a97          	auipc	s5,0xc3
ffffffffc0205bf0:	78ca8a93          	addi	s5,s5,1932 # ffffffffc02c9378 <va_pa_offset>
        while (start < end) {
ffffffffc0205bf4:	053be763          	bltu	s7,s3,ffffffffc0205c42 <do_execve+0x42a>
ffffffffc0205bf8:	b3ad                	j	ffffffffc0205962 <do_execve+0x14a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205bfa:	6785                	lui	a5,0x1
ffffffffc0205bfc:	418b8533          	sub	a0,s7,s8
ffffffffc0205c00:	9c3e                	add	s8,s8,a5
ffffffffc0205c02:	417c0633          	sub	a2,s8,s7
            if (end < la) {
ffffffffc0205c06:	0189f463          	bleu	s8,s3,ffffffffc0205c0e <do_execve+0x3f6>
                size -= la - end;
ffffffffc0205c0a:	41798633          	sub	a2,s3,s7
    return page - pages + nbase;
ffffffffc0205c0e:	000db683          	ld	a3,0(s11)
ffffffffc0205c12:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205c16:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205c18:	40d486b3          	sub	a3,s1,a3
ffffffffc0205c1c:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205c1e:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205c22:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0205c24:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c28:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c2a:	02b87e63          	bleu	a1,a6,ffffffffc0205c66 <do_execve+0x44e>
ffffffffc0205c2e:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc0205c32:	9bb2                	add	s7,s7,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c34:	4581                	li	a1,0
ffffffffc0205c36:	96c2                	add	a3,a3,a6
ffffffffc0205c38:	9536                	add	a0,a0,a3
ffffffffc0205c3a:	4d2030ef          	jal	ra,ffffffffc020910c <memset>
        while (start < end) {
ffffffffc0205c3e:	d33bf2e3          	bleu	s3,s7,ffffffffc0205962 <do_execve+0x14a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205c42:	01893503          	ld	a0,24(s2)
ffffffffc0205c46:	6602                	ld	a2,0(sp)
ffffffffc0205c48:	85e2                	mv	a1,s8
ffffffffc0205c4a:	e9efd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc0205c4e:	84aa                	mv	s1,a0
ffffffffc0205c50:	f54d                	bnez	a0,ffffffffc0205bfa <do_execve+0x3e2>
ffffffffc0205c52:	bdd1                	j	ffffffffc0205b26 <do_execve+0x30e>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205c54:	417c0ab3          	sub	s5,s8,s7
ffffffffc0205c58:	b72d                	j	ffffffffc0205b82 <do_execve+0x36a>
        while (start < end) {
ffffffffc0205c5a:	89de                	mv	s3,s7
ffffffffc0205c5c:	b729                	j	ffffffffc0205b66 <do_execve+0x34e>
        return -E_INVAL;
ffffffffc0205c5e:	59f5                	li	s3,-3
ffffffffc0205c60:	bbe1                	j	ffffffffc0205a38 <do_execve+0x220>
            ret = -E_INVAL_ELF;
ffffffffc0205c62:	59e1                	li	s3,-8
ffffffffc0205c64:	b5d1                	j	ffffffffc0205b28 <do_execve+0x310>
ffffffffc0205c66:	00004617          	auipc	a2,0x4
ffffffffc0205c6a:	25a60613          	addi	a2,a2,602 # ffffffffc0209ec0 <default_pmm_manager+0x50>
ffffffffc0205c6e:	06900593          	li	a1,105
ffffffffc0205c72:	00004517          	auipc	a0,0x4
ffffffffc0205c76:	27650513          	addi	a0,a0,630 # ffffffffc0209ee8 <default_pmm_manager+0x78>
ffffffffc0205c7a:	80ffa0ef          	jal	ra,ffffffffc0200488 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205c7e:	00004617          	auipc	a2,0x4
ffffffffc0205c82:	27a60613          	addi	a2,a2,634 # ffffffffc0209ef8 <default_pmm_manager+0x88>
ffffffffc0205c86:	29a00593          	li	a1,666
ffffffffc0205c8a:	00005517          	auipc	a0,0x5
ffffffffc0205c8e:	6f650513          	addi	a0,a0,1782 # ffffffffc020b380 <default_pmm_manager+0x1510>
ffffffffc0205c92:	ff6fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c96:	00005697          	auipc	a3,0x5
ffffffffc0205c9a:	3ba68693          	addi	a3,a3,954 # ffffffffc020b050 <default_pmm_manager+0x11e0>
ffffffffc0205c9e:	00004617          	auipc	a2,0x4
ffffffffc0205ca2:	a8a60613          	addi	a2,a2,-1398 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0205ca6:	29500593          	li	a1,661
ffffffffc0205caa:	00005517          	auipc	a0,0x5
ffffffffc0205cae:	6d650513          	addi	a0,a0,1750 # ffffffffc020b380 <default_pmm_manager+0x1510>
ffffffffc0205cb2:	fd6fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205cb6:	00005697          	auipc	a3,0x5
ffffffffc0205cba:	35268693          	addi	a3,a3,850 # ffffffffc020b008 <default_pmm_manager+0x1198>
ffffffffc0205cbe:	00004617          	auipc	a2,0x4
ffffffffc0205cc2:	a6a60613          	addi	a2,a2,-1430 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0205cc6:	29400593          	li	a1,660
ffffffffc0205cca:	00005517          	auipc	a0,0x5
ffffffffc0205cce:	6b650513          	addi	a0,a0,1718 # ffffffffc020b380 <default_pmm_manager+0x1510>
ffffffffc0205cd2:	fb6fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205cd6:	00005697          	auipc	a3,0x5
ffffffffc0205cda:	2ea68693          	addi	a3,a3,746 # ffffffffc020afc0 <default_pmm_manager+0x1150>
ffffffffc0205cde:	00004617          	auipc	a2,0x4
ffffffffc0205ce2:	a4a60613          	addi	a2,a2,-1462 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0205ce6:	29300593          	li	a1,659
ffffffffc0205cea:	00005517          	auipc	a0,0x5
ffffffffc0205cee:	69650513          	addi	a0,a0,1686 # ffffffffc020b380 <default_pmm_manager+0x1510>
ffffffffc0205cf2:	f96fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205cf6:	00005697          	auipc	a3,0x5
ffffffffc0205cfa:	28268693          	addi	a3,a3,642 # ffffffffc020af78 <default_pmm_manager+0x1108>
ffffffffc0205cfe:	00004617          	auipc	a2,0x4
ffffffffc0205d02:	a2a60613          	addi	a2,a2,-1494 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0205d06:	29200593          	li	a1,658
ffffffffc0205d0a:	00005517          	auipc	a0,0x5
ffffffffc0205d0e:	67650513          	addi	a0,a0,1654 # ffffffffc020b380 <default_pmm_manager+0x1510>
ffffffffc0205d12:	f76fa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0205d16 <do_yield>:
    current->need_resched = 1;
ffffffffc0205d16:	000c3797          	auipc	a5,0xc3
ffffffffc0205d1a:	60a78793          	addi	a5,a5,1546 # ffffffffc02c9320 <current>
ffffffffc0205d1e:	639c                	ld	a5,0(a5)
ffffffffc0205d20:	4705                	li	a4,1
}
ffffffffc0205d22:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205d24:	ef98                	sd	a4,24(a5)
}
ffffffffc0205d26:	8082                	ret

ffffffffc0205d28 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205d28:	1101                	addi	sp,sp,-32
ffffffffc0205d2a:	e822                	sd	s0,16(sp)
ffffffffc0205d2c:	e426                	sd	s1,8(sp)
ffffffffc0205d2e:	ec06                	sd	ra,24(sp)
ffffffffc0205d30:	842e                	mv	s0,a1
ffffffffc0205d32:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205d34:	cd81                	beqz	a1,ffffffffc0205d4c <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205d36:	000c3797          	auipc	a5,0xc3
ffffffffc0205d3a:	5ea78793          	addi	a5,a5,1514 # ffffffffc02c9320 <current>
ffffffffc0205d3e:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205d40:	4685                	li	a3,1
ffffffffc0205d42:	4611                	li	a2,4
ffffffffc0205d44:	7788                	ld	a0,40(a5)
ffffffffc0205d46:	d5bfe0ef          	jal	ra,ffffffffc0204aa0 <user_mem_check>
ffffffffc0205d4a:	c909                	beqz	a0,ffffffffc0205d5c <do_wait+0x34>
ffffffffc0205d4c:	85a2                	mv	a1,s0
}
ffffffffc0205d4e:	6442                	ld	s0,16(sp)
ffffffffc0205d50:	60e2                	ld	ra,24(sp)
ffffffffc0205d52:	8526                	mv	a0,s1
ffffffffc0205d54:	64a2                	ld	s1,8(sp)
ffffffffc0205d56:	6105                	addi	sp,sp,32
ffffffffc0205d58:	ff0ff06f          	j	ffffffffc0205548 <do_wait.part.1>
ffffffffc0205d5c:	60e2                	ld	ra,24(sp)
ffffffffc0205d5e:	6442                	ld	s0,16(sp)
ffffffffc0205d60:	64a2                	ld	s1,8(sp)
ffffffffc0205d62:	5575                	li	a0,-3
ffffffffc0205d64:	6105                	addi	sp,sp,32
ffffffffc0205d66:	8082                	ret

ffffffffc0205d68 <do_kill>:
do_kill(int pid) {
ffffffffc0205d68:	1141                	addi	sp,sp,-16
ffffffffc0205d6a:	e406                	sd	ra,8(sp)
ffffffffc0205d6c:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc0205d6e:	a04ff0ef          	jal	ra,ffffffffc0204f72 <find_proc>
ffffffffc0205d72:	cd0d                	beqz	a0,ffffffffc0205dac <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205d74:	0b052703          	lw	a4,176(a0)
ffffffffc0205d78:	00177693          	andi	a3,a4,1
ffffffffc0205d7c:	e695                	bnez	a3,ffffffffc0205da8 <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205d7e:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205d82:	00176713          	ori	a4,a4,1
ffffffffc0205d86:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205d8a:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205d8c:	0006c763          	bltz	a3,ffffffffc0205d9a <do_kill+0x32>
}
ffffffffc0205d90:	8522                	mv	a0,s0
ffffffffc0205d92:	60a2                	ld	ra,8(sp)
ffffffffc0205d94:	6402                	ld	s0,0(sp)
ffffffffc0205d96:	0141                	addi	sp,sp,16
ffffffffc0205d98:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205d9a:	43b020ef          	jal	ra,ffffffffc02089d4 <wakeup_proc>
}
ffffffffc0205d9e:	8522                	mv	a0,s0
ffffffffc0205da0:	60a2                	ld	ra,8(sp)
ffffffffc0205da2:	6402                	ld	s0,0(sp)
ffffffffc0205da4:	0141                	addi	sp,sp,16
ffffffffc0205da6:	8082                	ret
        return -E_KILLED;
ffffffffc0205da8:	545d                	li	s0,-9
ffffffffc0205daa:	b7dd                	j	ffffffffc0205d90 <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205dac:	5475                	li	s0,-3
ffffffffc0205dae:	b7cd                	j	ffffffffc0205d90 <do_kill+0x28>

ffffffffc0205db0 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205db0:	000c3797          	auipc	a5,0xc3
ffffffffc0205db4:	6c078793          	addi	a5,a5,1728 # ffffffffc02c9470 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205db8:	1101                	addi	sp,sp,-32
ffffffffc0205dba:	000c3717          	auipc	a4,0xc3
ffffffffc0205dbe:	6af73f23          	sd	a5,1726(a4) # ffffffffc02c9478 <proc_list+0x8>
ffffffffc0205dc2:	000c3717          	auipc	a4,0xc3
ffffffffc0205dc6:	6af73723          	sd	a5,1710(a4) # ffffffffc02c9470 <proc_list>
ffffffffc0205dca:	ec06                	sd	ra,24(sp)
ffffffffc0205dcc:	e822                	sd	s0,16(sp)
ffffffffc0205dce:	e426                	sd	s1,8(sp)
ffffffffc0205dd0:	000bf797          	auipc	a5,0xbf
ffffffffc0205dd4:	4f078793          	addi	a5,a5,1264 # ffffffffc02c52c0 <hash_list>
ffffffffc0205dd8:	000c3717          	auipc	a4,0xc3
ffffffffc0205ddc:	4e870713          	addi	a4,a4,1256 # ffffffffc02c92c0 <__rq>
ffffffffc0205de0:	e79c                	sd	a5,8(a5)
ffffffffc0205de2:	e39c                	sd	a5,0(a5)
ffffffffc0205de4:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205de6:	fee79de3          	bne	a5,a4,ffffffffc0205de0 <proc_init+0x30>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205dea:	ebbfe0ef          	jal	ra,ffffffffc0204ca4 <alloc_proc>
ffffffffc0205dee:	000c3717          	auipc	a4,0xc3
ffffffffc0205df2:	52a73d23          	sd	a0,1338(a4) # ffffffffc02c9328 <idleproc>
ffffffffc0205df6:	000c3497          	auipc	s1,0xc3
ffffffffc0205dfa:	53248493          	addi	s1,s1,1330 # ffffffffc02c9328 <idleproc>
ffffffffc0205dfe:	c559                	beqz	a0,ffffffffc0205e8c <proc_init+0xdc>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205e00:	4709                	li	a4,2
ffffffffc0205e02:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0205e04:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e06:	00006717          	auipc	a4,0x6
ffffffffc0205e0a:	1fa70713          	addi	a4,a4,506 # ffffffffc020c000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0205e0e:	00005597          	auipc	a1,0x5
ffffffffc0205e12:	48a58593          	addi	a1,a1,1162 # ffffffffc020b298 <default_pmm_manager+0x1428>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e16:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205e18:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc0205e1a:	8c2ff0ef          	jal	ra,ffffffffc0204edc <set_proc_name>
    nr_process ++;
ffffffffc0205e1e:	000c3797          	auipc	a5,0xc3
ffffffffc0205e22:	51a78793          	addi	a5,a5,1306 # ffffffffc02c9338 <nr_process>
ffffffffc0205e26:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205e28:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e2a:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205e2c:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e2e:	4581                	li	a1,0
ffffffffc0205e30:	00000517          	auipc	a0,0x0
ffffffffc0205e34:	8c050513          	addi	a0,a0,-1856 # ffffffffc02056f0 <init_main>
    nr_process ++;
ffffffffc0205e38:	000c3697          	auipc	a3,0xc3
ffffffffc0205e3c:	50f6a023          	sw	a5,1280(a3) # ffffffffc02c9338 <nr_process>
    current = idleproc;
ffffffffc0205e40:	000c3797          	auipc	a5,0xc3
ffffffffc0205e44:	4ee7b023          	sd	a4,1248(a5) # ffffffffc02c9320 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e48:	d62ff0ef          	jal	ra,ffffffffc02053aa <kernel_thread>
    if (pid <= 0) {
ffffffffc0205e4c:	08a05c63          	blez	a0,ffffffffc0205ee4 <proc_init+0x134>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205e50:	922ff0ef          	jal	ra,ffffffffc0204f72 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0205e54:	00005597          	auipc	a1,0x5
ffffffffc0205e58:	46c58593          	addi	a1,a1,1132 # ffffffffc020b2c0 <default_pmm_manager+0x1450>
    initproc = find_proc(pid);
ffffffffc0205e5c:	000c3797          	auipc	a5,0xc3
ffffffffc0205e60:	4ca7ba23          	sd	a0,1236(a5) # ffffffffc02c9330 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0205e64:	878ff0ef          	jal	ra,ffffffffc0204edc <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205e68:	609c                	ld	a5,0(s1)
ffffffffc0205e6a:	cfa9                	beqz	a5,ffffffffc0205ec4 <proc_init+0x114>
ffffffffc0205e6c:	43dc                	lw	a5,4(a5)
ffffffffc0205e6e:	ebb9                	bnez	a5,ffffffffc0205ec4 <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e70:	000c3797          	auipc	a5,0xc3
ffffffffc0205e74:	4c078793          	addi	a5,a5,1216 # ffffffffc02c9330 <initproc>
ffffffffc0205e78:	639c                	ld	a5,0(a5)
ffffffffc0205e7a:	c78d                	beqz	a5,ffffffffc0205ea4 <proc_init+0xf4>
ffffffffc0205e7c:	43dc                	lw	a5,4(a5)
ffffffffc0205e7e:	02879363          	bne	a5,s0,ffffffffc0205ea4 <proc_init+0xf4>
}
ffffffffc0205e82:	60e2                	ld	ra,24(sp)
ffffffffc0205e84:	6442                	ld	s0,16(sp)
ffffffffc0205e86:	64a2                	ld	s1,8(sp)
ffffffffc0205e88:	6105                	addi	sp,sp,32
ffffffffc0205e8a:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0205e8c:	00005617          	auipc	a2,0x5
ffffffffc0205e90:	3f460613          	addi	a2,a2,1012 # ffffffffc020b280 <default_pmm_manager+0x1410>
ffffffffc0205e94:	39000593          	li	a1,912
ffffffffc0205e98:	00005517          	auipc	a0,0x5
ffffffffc0205e9c:	4e850513          	addi	a0,a0,1256 # ffffffffc020b380 <default_pmm_manager+0x1510>
ffffffffc0205ea0:	de8fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205ea4:	00005697          	auipc	a3,0x5
ffffffffc0205ea8:	44c68693          	addi	a3,a3,1100 # ffffffffc020b2f0 <default_pmm_manager+0x1480>
ffffffffc0205eac:	00004617          	auipc	a2,0x4
ffffffffc0205eb0:	87c60613          	addi	a2,a2,-1924 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0205eb4:	3a500593          	li	a1,933
ffffffffc0205eb8:	00005517          	auipc	a0,0x5
ffffffffc0205ebc:	4c850513          	addi	a0,a0,1224 # ffffffffc020b380 <default_pmm_manager+0x1510>
ffffffffc0205ec0:	dc8fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205ec4:	00005697          	auipc	a3,0x5
ffffffffc0205ec8:	40468693          	addi	a3,a3,1028 # ffffffffc020b2c8 <default_pmm_manager+0x1458>
ffffffffc0205ecc:	00004617          	auipc	a2,0x4
ffffffffc0205ed0:	85c60613          	addi	a2,a2,-1956 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0205ed4:	3a400593          	li	a1,932
ffffffffc0205ed8:	00005517          	auipc	a0,0x5
ffffffffc0205edc:	4a850513          	addi	a0,a0,1192 # ffffffffc020b380 <default_pmm_manager+0x1510>
ffffffffc0205ee0:	da8fa0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("create init_main failed.\n");
ffffffffc0205ee4:	00005617          	auipc	a2,0x5
ffffffffc0205ee8:	3bc60613          	addi	a2,a2,956 # ffffffffc020b2a0 <default_pmm_manager+0x1430>
ffffffffc0205eec:	39e00593          	li	a1,926
ffffffffc0205ef0:	00005517          	auipc	a0,0x5
ffffffffc0205ef4:	49050513          	addi	a0,a0,1168 # ffffffffc020b380 <default_pmm_manager+0x1510>
ffffffffc0205ef8:	d90fa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0205efc <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205efc:	1141                	addi	sp,sp,-16
ffffffffc0205efe:	e022                	sd	s0,0(sp)
ffffffffc0205f00:	e406                	sd	ra,8(sp)
ffffffffc0205f02:	000c3417          	auipc	s0,0xc3
ffffffffc0205f06:	41e40413          	addi	s0,s0,1054 # ffffffffc02c9320 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205f0a:	6018                	ld	a4,0(s0)
ffffffffc0205f0c:	6f1c                	ld	a5,24(a4)
ffffffffc0205f0e:	dffd                	beqz	a5,ffffffffc0205f0c <cpu_idle+0x10>
            schedule();
ffffffffc0205f10:	37f020ef          	jal	ra,ffffffffc0208a8e <schedule>
ffffffffc0205f14:	bfdd                	j	ffffffffc0205f0a <cpu_idle+0xe>

ffffffffc0205f16 <lab6_set_priority>:
    }
}
//FOR LAB6, set the process's priority (bigger value will get more CPU time)
void
lab6_set_priority(uint32_t priority)
{
ffffffffc0205f16:	1141                	addi	sp,sp,-16
ffffffffc0205f18:	e022                	sd	s0,0(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc0205f1a:	85aa                	mv	a1,a0
{
ffffffffc0205f1c:	842a                	mv	s0,a0
    cprintf("set priority to %d\n", priority);
ffffffffc0205f1e:	00005517          	auipc	a0,0x5
ffffffffc0205f22:	34a50513          	addi	a0,a0,842 # ffffffffc020b268 <default_pmm_manager+0x13f8>
{
ffffffffc0205f26:	e406                	sd	ra,8(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc0205f28:	a6afa0ef          	jal	ra,ffffffffc0200192 <cprintf>
    if (priority == 0)
        current->lab6_priority = 1;
ffffffffc0205f2c:	000c3797          	auipc	a5,0xc3
ffffffffc0205f30:	3f478793          	addi	a5,a5,1012 # ffffffffc02c9320 <current>
ffffffffc0205f34:	639c                	ld	a5,0(a5)
    if (priority == 0)
ffffffffc0205f36:	e801                	bnez	s0,ffffffffc0205f46 <lab6_set_priority+0x30>
    else current->lab6_priority = priority;
}
ffffffffc0205f38:	60a2                	ld	ra,8(sp)
ffffffffc0205f3a:	6402                	ld	s0,0(sp)
        current->lab6_priority = 1;
ffffffffc0205f3c:	4705                	li	a4,1
ffffffffc0205f3e:	14e7a223          	sw	a4,324(a5)
}
ffffffffc0205f42:	0141                	addi	sp,sp,16
ffffffffc0205f44:	8082                	ret
    else current->lab6_priority = priority;
ffffffffc0205f46:	1487a223          	sw	s0,324(a5)
}
ffffffffc0205f4a:	60a2                	ld	ra,8(sp)
ffffffffc0205f4c:	6402                	ld	s0,0(sp)
ffffffffc0205f4e:	0141                	addi	sp,sp,16
ffffffffc0205f50:	8082                	ret

ffffffffc0205f52 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0205f52:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0205f56:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0205f5a:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0205f5c:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0205f5e:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0205f62:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0205f66:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0205f6a:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0205f6e:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0205f72:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0205f76:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0205f7a:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0205f7e:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0205f82:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0205f86:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0205f8a:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0205f8e:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0205f90:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0205f92:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0205f96:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0205f9a:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0205f9e:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0205fa2:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0205fa6:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0205faa:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0205fae:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0205fb2:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0205fb6:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0205fba:	8082                	ret

ffffffffc0205fbc <proc_stride_comp_f>:
static int
proc_stride_comp_f(void *a, void *b)
{
     struct proc_struct *p = le2proc(a, lab6_run_pool);
     struct proc_struct *q = le2proc(b, lab6_run_pool);
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc0205fbc:	4d08                	lw	a0,24(a0)
ffffffffc0205fbe:	4d9c                	lw	a5,24(a1)
ffffffffc0205fc0:	9d1d                	subw	a0,a0,a5
     if (c > 0) return 1;
ffffffffc0205fc2:	00a04763          	bgtz	a0,ffffffffc0205fd0 <proc_stride_comp_f+0x14>
     else if (c == 0) return 0;
ffffffffc0205fc6:	00a03533          	snez	a0,a0
ffffffffc0205fca:	40a0053b          	negw	a0,a0
ffffffffc0205fce:	8082                	ret
     if (c > 0) return 1;
ffffffffc0205fd0:	4505                	li	a0,1
     else return -1;
}
ffffffffc0205fd2:	8082                	ret

ffffffffc0205fd4 <stride_init>:
ffffffffc0205fd4:	e508                	sd	a0,8(a0)
ffffffffc0205fd6:	e108                	sd	a0,0(a0)
 */
static void
stride_init(struct run_queue *rq) {
    list_init(&(rq->run_list));
    // 注意这里不要使用skew_heap_init(rq->lab6_run_pool)
    rq->lab6_run_pool = NULL;
ffffffffc0205fd8:	00053c23          	sd	zero,24(a0)
    rq->proc_num = 0;
ffffffffc0205fdc:	00052823          	sw	zero,16(a0)
}
ffffffffc0205fe0:	8082                	ret

ffffffffc0205fe2 <stride_pick_next>:
             (1.1) If using skew_heap, we can use le2proc get the p from rq->lab6_run_poll
             (1.2) If using list, we have to search list to find the p with minimum stride value
      * (2) update p;s stride value: p->lab6_stride
      * (3) return p
      */
     skew_heap_entry_t* she = rq->lab6_run_pool;
ffffffffc0205fe2:	6d1c                	ld	a5,24(a0)
     if (she != NULL) {
ffffffffc0205fe4:	cb99                	beqz	a5,ffffffffc0205ffa <stride_pick_next+0x18>
          struct proc_struct* p = le2proc(she, lab6_run_pool);
          p->lab6_stride += BIG_STRIDE / (p->lab6_priority);
ffffffffc0205fe6:	4fd0                	lw	a2,28(a5)
ffffffffc0205fe8:	56fd                	li	a3,-1
ffffffffc0205fea:	4f98                	lw	a4,24(a5)
ffffffffc0205fec:	02c6d6bb          	divuw	a3,a3,a2
          struct proc_struct* p = le2proc(she, lab6_run_pool);
ffffffffc0205ff0:	ed878513          	addi	a0,a5,-296
          p->lab6_stride += BIG_STRIDE / (p->lab6_priority);
ffffffffc0205ff4:	9f35                	addw	a4,a4,a3
ffffffffc0205ff6:	cf98                	sw	a4,24(a5)
          return p;
ffffffffc0205ff8:	8082                	ret
     }
    return NULL;
ffffffffc0205ffa:	4501                	li	a0,0

}
ffffffffc0205ffc:	8082                	ret

ffffffffc0205ffe <stride_proc_tick>:
 * switching.
 */
static void
stride_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
     /* LAB6: YOUR CODE */
     if (proc->time_slice > 0) {
ffffffffc0205ffe:	1205a783          	lw	a5,288(a1)
ffffffffc0206002:	00f05563          	blez	a5,ffffffffc020600c <stride_proc_tick+0xe>
          proc->time_slice --;
ffffffffc0206006:	37fd                	addiw	a5,a5,-1
ffffffffc0206008:	12f5a023          	sw	a5,288(a1)
     }
     if (proc->time_slice == 0) {
ffffffffc020600c:	e399                	bnez	a5,ffffffffc0206012 <stride_proc_tick+0x14>
          proc->need_resched = 1;
ffffffffc020600e:	4785                	li	a5,1
ffffffffc0206010:	ed9c                	sd	a5,24(a1)
     }
}
ffffffffc0206012:	8082                	ret

ffffffffc0206014 <skew_heap_merge.constprop.2>:
{
     a->left = a->right = a->parent = NULL;
}

static inline skew_heap_entry_t *
skew_heap_merge(skew_heap_entry_t *a, skew_heap_entry_t *b,
ffffffffc0206014:	1101                	addi	sp,sp,-32
ffffffffc0206016:	e822                	sd	s0,16(sp)
ffffffffc0206018:	ec06                	sd	ra,24(sp)
ffffffffc020601a:	e426                	sd	s1,8(sp)
ffffffffc020601c:	e04a                	sd	s2,0(sp)
ffffffffc020601e:	842e                	mv	s0,a1
                compare_f comp)
{
     if (a == NULL) return b;
ffffffffc0206020:	c11d                	beqz	a0,ffffffffc0206046 <skew_heap_merge.constprop.2+0x32>
ffffffffc0206022:	84aa                	mv	s1,a0
     else if (b == NULL) return a;
ffffffffc0206024:	c1b9                	beqz	a1,ffffffffc020606a <skew_heap_merge.constprop.2+0x56>
     
     skew_heap_entry_t *l, *r;
     if (comp(a, b) == -1)
ffffffffc0206026:	f97ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc020602a:	57fd                	li	a5,-1
ffffffffc020602c:	02f50463          	beq	a0,a5,ffffffffc0206054 <skew_heap_merge.constprop.2+0x40>
          return a;
     }
     else
     {
          r = b->left;
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206030:	680c                	ld	a1,16(s0)
          r = b->left;
ffffffffc0206032:	00843903          	ld	s2,8(s0)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206036:	8526                	mv	a0,s1
ffffffffc0206038:	fddff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          
          b->left = l;
ffffffffc020603c:	e408                	sd	a0,8(s0)
          b->right = r;
ffffffffc020603e:	01243823          	sd	s2,16(s0)
          if (l) l->parent = b;
ffffffffc0206042:	c111                	beqz	a0,ffffffffc0206046 <skew_heap_merge.constprop.2+0x32>
ffffffffc0206044:	e100                	sd	s0,0(a0)
ffffffffc0206046:	8522                	mv	a0,s0

          return b;
     }
}
ffffffffc0206048:	60e2                	ld	ra,24(sp)
ffffffffc020604a:	6442                	ld	s0,16(sp)
ffffffffc020604c:	64a2                	ld	s1,8(sp)
ffffffffc020604e:	6902                	ld	s2,0(sp)
ffffffffc0206050:	6105                	addi	sp,sp,32
ffffffffc0206052:	8082                	ret
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206054:	6888                	ld	a0,16(s1)
          r = a->left;
ffffffffc0206056:	0084b903          	ld	s2,8(s1)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020605a:	85a2                	mv	a1,s0
ffffffffc020605c:	fb9ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0206060:	e488                	sd	a0,8(s1)
          a->right = r;
ffffffffc0206062:	0124b823          	sd	s2,16(s1)
          if (l) l->parent = a;
ffffffffc0206066:	c111                	beqz	a0,ffffffffc020606a <skew_heap_merge.constprop.2+0x56>
ffffffffc0206068:	e104                	sd	s1,0(a0)
}
ffffffffc020606a:	60e2                	ld	ra,24(sp)
ffffffffc020606c:	6442                	ld	s0,16(sp)
          if (l) l->parent = a;
ffffffffc020606e:	8526                	mv	a0,s1
}
ffffffffc0206070:	6902                	ld	s2,0(sp)
ffffffffc0206072:	64a2                	ld	s1,8(sp)
ffffffffc0206074:	6105                	addi	sp,sp,32
ffffffffc0206076:	8082                	ret

ffffffffc0206078 <stride_enqueue>:
stride_enqueue(struct run_queue *rq, struct proc_struct *proc) {
ffffffffc0206078:	7119                	addi	sp,sp,-128
ffffffffc020607a:	ecce                	sd	s3,88(sp)
     rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
ffffffffc020607c:	01853983          	ld	s3,24(a0)
stride_enqueue(struct run_queue *rq, struct proc_struct *proc) {
ffffffffc0206080:	f8a2                	sd	s0,112(sp)
ffffffffc0206082:	f4a6                	sd	s1,104(sp)
ffffffffc0206084:	f0ca                	sd	s2,96(sp)
ffffffffc0206086:	fc86                	sd	ra,120(sp)
ffffffffc0206088:	e8d2                	sd	s4,80(sp)
ffffffffc020608a:	e4d6                	sd	s5,72(sp)
ffffffffc020608c:	e0da                	sd	s6,64(sp)
ffffffffc020608e:	fc5e                	sd	s7,56(sp)
ffffffffc0206090:	f862                	sd	s8,48(sp)
ffffffffc0206092:	f466                	sd	s9,40(sp)
ffffffffc0206094:	f06a                	sd	s10,32(sp)
ffffffffc0206096:	ec6e                	sd	s11,24(sp)
     a->left = a->right = a->parent = NULL;
ffffffffc0206098:	1205b423          	sd	zero,296(a1)
ffffffffc020609c:	1205bc23          	sd	zero,312(a1)
ffffffffc02060a0:	1205b823          	sd	zero,304(a1)
ffffffffc02060a4:	84aa                	mv	s1,a0
ffffffffc02060a6:	842e                	mv	s0,a1
     rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
ffffffffc02060a8:	12858913          	addi	s2,a1,296
     if (a == NULL) return b;
ffffffffc02060ac:	02098063          	beqz	s3,ffffffffc02060cc <stride_enqueue+0x54>
     else if (b == NULL) return a;
ffffffffc02060b0:	08090c63          	beqz	s2,ffffffffc0206148 <stride_enqueue+0xd0>
     if (comp(a, b) == -1)
ffffffffc02060b4:	85ca                	mv	a1,s2
ffffffffc02060b6:	854e                	mv	a0,s3
ffffffffc02060b8:	f05ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc02060bc:	57fd                	li	a5,-1
ffffffffc02060be:	8a2a                	mv	s4,a0
ffffffffc02060c0:	04f50563          	beq	a0,a5,ffffffffc020610a <stride_enqueue+0x92>
          b->left = l;
ffffffffc02060c4:	13343823          	sd	s3,304(s0)
          if (l) l->parent = b;
ffffffffc02060c8:	0129b023          	sd	s2,0(s3) # ffffffff80000000 <_binary_obj___user_matrix_out_size+0xffffffff7fff4590>
     if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc02060cc:	12042783          	lw	a5,288(s0)
     rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
ffffffffc02060d0:	0124bc23          	sd	s2,24(s1)
     if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc02060d4:	48d8                	lw	a4,20(s1)
ffffffffc02060d6:	e79d                	bnez	a5,ffffffffc0206104 <stride_enqueue+0x8c>
          proc->time_slice = rq->max_time_slice;
ffffffffc02060d8:	12e42023          	sw	a4,288(s0)
     rq->proc_num ++;
ffffffffc02060dc:	489c                	lw	a5,16(s1)
}
ffffffffc02060de:	70e6                	ld	ra,120(sp)
     proc->rq = rq;
ffffffffc02060e0:	10943423          	sd	s1,264(s0)
}
ffffffffc02060e4:	7446                	ld	s0,112(sp)
     rq->proc_num ++;
ffffffffc02060e6:	2785                	addiw	a5,a5,1
ffffffffc02060e8:	c89c                	sw	a5,16(s1)
}
ffffffffc02060ea:	7906                	ld	s2,96(sp)
ffffffffc02060ec:	74a6                	ld	s1,104(sp)
ffffffffc02060ee:	69e6                	ld	s3,88(sp)
ffffffffc02060f0:	6a46                	ld	s4,80(sp)
ffffffffc02060f2:	6aa6                	ld	s5,72(sp)
ffffffffc02060f4:	6b06                	ld	s6,64(sp)
ffffffffc02060f6:	7be2                	ld	s7,56(sp)
ffffffffc02060f8:	7c42                	ld	s8,48(sp)
ffffffffc02060fa:	7ca2                	ld	s9,40(sp)
ffffffffc02060fc:	7d02                	ld	s10,32(sp)
ffffffffc02060fe:	6de2                	ld	s11,24(sp)
ffffffffc0206100:	6109                	addi	sp,sp,128
ffffffffc0206102:	8082                	ret
     if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc0206104:	fcf75ce3          	ble	a5,a4,ffffffffc02060dc <stride_enqueue+0x64>
ffffffffc0206108:	bfc1                	j	ffffffffc02060d8 <stride_enqueue+0x60>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020610a:	0109ba83          	ld	s5,16(s3)
          r = a->left;
ffffffffc020610e:	0089bb03          	ld	s6,8(s3)
     if (a == NULL) return b;
ffffffffc0206112:	000a8d63          	beqz	s5,ffffffffc020612c <stride_enqueue+0xb4>
     if (comp(a, b) == -1)
ffffffffc0206116:	85ca                	mv	a1,s2
ffffffffc0206118:	8556                	mv	a0,s5
ffffffffc020611a:	ea3ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc020611e:	8baa                	mv	s7,a0
ffffffffc0206120:	03450c63          	beq	a0,s4,ffffffffc0206158 <stride_enqueue+0xe0>
          b->left = l;
ffffffffc0206124:	13543823          	sd	s5,304(s0)
          if (l) l->parent = b;
ffffffffc0206128:	012ab023          	sd	s2,0(s5)
          a->left = l;
ffffffffc020612c:	0129b423          	sd	s2,8(s3)
          a->right = r;
ffffffffc0206130:	0169b823          	sd	s6,16(s3)
ffffffffc0206134:	12042783          	lw	a5,288(s0)
          if (l) l->parent = a;
ffffffffc0206138:	01393023          	sd	s3,0(s2)
ffffffffc020613c:	894e                	mv	s2,s3
     rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
ffffffffc020613e:	0124bc23          	sd	s2,24(s1)
     if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc0206142:	48d8                	lw	a4,20(s1)
ffffffffc0206144:	dbd1                	beqz	a5,ffffffffc02060d8 <stride_enqueue+0x60>
ffffffffc0206146:	bf7d                	j	ffffffffc0206104 <stride_enqueue+0x8c>
ffffffffc0206148:	12042783          	lw	a5,288(s0)
     else if (b == NULL) return a;
ffffffffc020614c:	894e                	mv	s2,s3
     rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
ffffffffc020614e:	0124bc23          	sd	s2,24(s1)
     if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc0206152:	48d8                	lw	a4,20(s1)
ffffffffc0206154:	d3d1                	beqz	a5,ffffffffc02060d8 <stride_enqueue+0x60>
ffffffffc0206156:	b77d                	j	ffffffffc0206104 <stride_enqueue+0x8c>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206158:	010aba03          	ld	s4,16(s5)
          r = a->left;
ffffffffc020615c:	008abc03          	ld	s8,8(s5)
     if (a == NULL) return b;
ffffffffc0206160:	000a0d63          	beqz	s4,ffffffffc020617a <stride_enqueue+0x102>
     if (comp(a, b) == -1)
ffffffffc0206164:	85ca                	mv	a1,s2
ffffffffc0206166:	8552                	mv	a0,s4
ffffffffc0206168:	e55ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc020616c:	8caa                	mv	s9,a0
ffffffffc020616e:	01750e63          	beq	a0,s7,ffffffffc020618a <stride_enqueue+0x112>
          b->left = l;
ffffffffc0206172:	13443823          	sd	s4,304(s0)
          if (l) l->parent = b;
ffffffffc0206176:	012a3023          	sd	s2,0(s4)
          a->left = l;
ffffffffc020617a:	012ab423          	sd	s2,8(s5)
          a->right = r;
ffffffffc020617e:	018ab823          	sd	s8,16(s5)
          if (l) l->parent = a;
ffffffffc0206182:	01593023          	sd	s5,0(s2)
ffffffffc0206186:	8956                	mv	s2,s5
ffffffffc0206188:	b755                	j	ffffffffc020612c <stride_enqueue+0xb4>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020618a:	010a3b83          	ld	s7,16(s4)
          r = a->left;
ffffffffc020618e:	008a3d03          	ld	s10,8(s4)
     if (a == NULL) return b;
ffffffffc0206192:	000b8c63          	beqz	s7,ffffffffc02061aa <stride_enqueue+0x132>
     if (comp(a, b) == -1)
ffffffffc0206196:	85ca                	mv	a1,s2
ffffffffc0206198:	855e                	mv	a0,s7
ffffffffc020619a:	e23ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc020619e:	01950e63          	beq	a0,s9,ffffffffc02061ba <stride_enqueue+0x142>
          b->left = l;
ffffffffc02061a2:	13743823          	sd	s7,304(s0)
          if (l) l->parent = b;
ffffffffc02061a6:	012bb023          	sd	s2,0(s7)
          a->left = l;
ffffffffc02061aa:	012a3423          	sd	s2,8(s4)
          a->right = r;
ffffffffc02061ae:	01aa3823          	sd	s10,16(s4)
          if (l) l->parent = a;
ffffffffc02061b2:	01493023          	sd	s4,0(s2)
ffffffffc02061b6:	8952                	mv	s2,s4
ffffffffc02061b8:	b7c9                	j	ffffffffc020617a <stride_enqueue+0x102>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02061ba:	010bbc83          	ld	s9,16(s7)
          r = a->left;
ffffffffc02061be:	008bbd83          	ld	s11,8(s7)
     if (a == NULL) return b;
ffffffffc02061c2:	000c8d63          	beqz	s9,ffffffffc02061dc <stride_enqueue+0x164>
     if (comp(a, b) == -1)
ffffffffc02061c6:	85ca                	mv	a1,s2
ffffffffc02061c8:	8566                	mv	a0,s9
ffffffffc02061ca:	df3ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc02061ce:	57fd                	li	a5,-1
ffffffffc02061d0:	00f50e63          	beq	a0,a5,ffffffffc02061ec <stride_enqueue+0x174>
          b->left = l;
ffffffffc02061d4:	13943823          	sd	s9,304(s0)
          if (l) l->parent = b;
ffffffffc02061d8:	012cb023          	sd	s2,0(s9)
          a->left = l;
ffffffffc02061dc:	012bb423          	sd	s2,8(s7)
          a->right = r;
ffffffffc02061e0:	01bbb823          	sd	s11,16(s7)
          if (l) l->parent = a;
ffffffffc02061e4:	01793023          	sd	s7,0(s2)
ffffffffc02061e8:	895e                	mv	s2,s7
ffffffffc02061ea:	b7c1                	j	ffffffffc02061aa <stride_enqueue+0x132>
          r = a->left;
ffffffffc02061ec:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02061f0:	010cb503          	ld	a0,16(s9)
ffffffffc02061f4:	85ca                	mv	a1,s2
          r = a->left;
ffffffffc02061f6:	e43e                	sd	a5,8(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02061f8:	e1dff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02061fc:	67a2                	ld	a5,8(sp)
          a->left = l;
ffffffffc02061fe:	00acb423          	sd	a0,8(s9)
          a->right = r;
ffffffffc0206202:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0206206:	c509                	beqz	a0,ffffffffc0206210 <stride_enqueue+0x198>
ffffffffc0206208:	01953023          	sd	s9,0(a0)
ffffffffc020620c:	8966                	mv	s2,s9
ffffffffc020620e:	b7f9                	j	ffffffffc02061dc <stride_enqueue+0x164>
ffffffffc0206210:	8966                	mv	s2,s9
ffffffffc0206212:	b7e9                	j	ffffffffc02061dc <stride_enqueue+0x164>

ffffffffc0206214 <stride_dequeue>:
stride_dequeue(struct run_queue *rq, struct proc_struct *proc) {
ffffffffc0206214:	7171                	addi	sp,sp,-176
ffffffffc0206216:	ed26                	sd	s1,152(sp)
static inline skew_heap_entry_t *
skew_heap_remove(skew_heap_entry_t *a, skew_heap_entry_t *b,
                 compare_f comp)
{
     skew_heap_entry_t *p   = b->parent;
     skew_heap_entry_t *rep = skew_heap_merge(b->left, b->right, comp);
ffffffffc0206218:	1305b483          	ld	s1,304(a1)
ffffffffc020621c:	f122                	sd	s0,160(sp)
ffffffffc020621e:	e94a                	sd	s2,144(sp)
ffffffffc0206220:	fcd6                	sd	s5,120(sp)
ffffffffc0206222:	f8da                	sd	s6,112(sp)
ffffffffc0206224:	e4ee                	sd	s11,72(sp)
ffffffffc0206226:	f506                	sd	ra,168(sp)
ffffffffc0206228:	e54e                	sd	s3,136(sp)
ffffffffc020622a:	e152                	sd	s4,128(sp)
ffffffffc020622c:	f4de                	sd	s7,104(sp)
ffffffffc020622e:	f0e2                	sd	s8,96(sp)
ffffffffc0206230:	ece6                	sd	s9,88(sp)
ffffffffc0206232:	e8ea                	sd	s10,80(sp)
ffffffffc0206234:	892e                	mv	s2,a1
ffffffffc0206236:	8aaa                	mv	s5,a0
     rq->lab6_run_pool = skew_heap_remove(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
ffffffffc0206238:	01853b03          	ld	s6,24(a0)
     skew_heap_entry_t *p   = b->parent;
ffffffffc020623c:	1285bd83          	ld	s11,296(a1)
     skew_heap_entry_t *rep = skew_heap_merge(b->left, b->right, comp);
ffffffffc0206240:	1385b403          	ld	s0,312(a1)
     if (a == NULL) return b;
ffffffffc0206244:	2c048363          	beqz	s1,ffffffffc020650a <stride_dequeue+0x2f6>
     else if (b == NULL) return a;
ffffffffc0206248:	3e040163          	beqz	s0,ffffffffc020662a <stride_dequeue+0x416>
     if (comp(a, b) == -1)
ffffffffc020624c:	85a2                	mv	a1,s0
ffffffffc020624e:	8526                	mv	a0,s1
ffffffffc0206250:	d6dff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206254:	5a7d                	li	s4,-1
ffffffffc0206256:	89aa                	mv	s3,a0
ffffffffc0206258:	17450d63          	beq	a0,s4,ffffffffc02063d2 <stride_dequeue+0x1be>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020625c:	01043983          	ld	s3,16(s0)
          r = b->left;
ffffffffc0206260:	00843b83          	ld	s7,8(s0)
     else if (b == NULL) return a;
ffffffffc0206264:	12098163          	beqz	s3,ffffffffc0206386 <stride_dequeue+0x172>
     if (comp(a, b) == -1)
ffffffffc0206268:	85ce                	mv	a1,s3
ffffffffc020626a:	8526                	mv	a0,s1
ffffffffc020626c:	d51ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206270:	8caa                	mv	s9,a0
ffffffffc0206272:	2b450563          	beq	a0,s4,ffffffffc020651c <stride_dequeue+0x308>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206276:	0109bd03          	ld	s10,16(s3)
          r = b->left;
ffffffffc020627a:	0089bc03          	ld	s8,8(s3)
     else if (b == NULL) return a;
ffffffffc020627e:	0e0d0d63          	beqz	s10,ffffffffc0206378 <stride_dequeue+0x164>
     if (comp(a, b) == -1)
ffffffffc0206282:	85ea                	mv	a1,s10
ffffffffc0206284:	8526                	mv	a0,s1
ffffffffc0206286:	d37ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc020628a:	8caa                	mv	s9,a0
ffffffffc020628c:	75450a63          	beq	a0,s4,ffffffffc02069e0 <stride_dequeue+0x7cc>
          r = b->left;
ffffffffc0206290:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206294:	010d3c83          	ld	s9,16(s10)
          r = b->left;
ffffffffc0206298:	e43e                	sd	a5,8(sp)
     else if (b == NULL) return a;
ffffffffc020629a:	0c0c8763          	beqz	s9,ffffffffc0206368 <stride_dequeue+0x154>
     if (comp(a, b) == -1)
ffffffffc020629e:	85e6                	mv	a1,s9
ffffffffc02062a0:	8526                	mv	a0,s1
ffffffffc02062a2:	d1bff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc02062a6:	69450063          	beq	a0,s4,ffffffffc0206926 <stride_dequeue+0x712>
          r = b->left;
ffffffffc02062aa:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02062ae:	010cba03          	ld	s4,16(s9)
          r = b->left;
ffffffffc02062b2:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc02062b4:	0a0a0263          	beqz	s4,ffffffffc0206358 <stride_dequeue+0x144>
     if (comp(a, b) == -1)
ffffffffc02062b8:	85d2                	mv	a1,s4
ffffffffc02062ba:	8526                	mv	a0,s1
ffffffffc02062bc:	d01ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc02062c0:	58fd                	li	a7,-1
ffffffffc02062c2:	351503e3          	beq	a0,a7,ffffffffc0206e08 <stride_dequeue+0xbf4>
          r = b->left;
ffffffffc02062c6:	008a3703          	ld	a4,8(s4)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02062ca:	010a3783          	ld	a5,16(s4)
          r = b->left;
ffffffffc02062ce:	ec3a                	sd	a4,24(sp)
     else if (b == NULL) return a;
ffffffffc02062d0:	cfa5                	beqz	a5,ffffffffc0206348 <stride_dequeue+0x134>
     if (comp(a, b) == -1)
ffffffffc02062d2:	85be                	mv	a1,a5
ffffffffc02062d4:	8526                	mv	a0,s1
ffffffffc02062d6:	f03e                	sd	a5,32(sp)
ffffffffc02062d8:	ce5ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc02062dc:	58fd                	li	a7,-1
ffffffffc02062de:	7782                	ld	a5,32(sp)
ffffffffc02062e0:	01151463          	bne	a0,a7,ffffffffc02062e8 <stride_dequeue+0xd4>
ffffffffc02062e4:	0580106f          	j	ffffffffc020733c <stride_dequeue+0x1128>
          r = b->left;
ffffffffc02062e8:	6798                	ld	a4,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02062ea:	0107b303          	ld	t1,16(a5)
          r = b->left;
ffffffffc02062ee:	f03a                	sd	a4,32(sp)
     else if (b == NULL) return a;
ffffffffc02062f0:	00031463          	bnez	t1,ffffffffc02062f8 <stride_dequeue+0xe4>
ffffffffc02062f4:	6a00106f          	j	ffffffffc0207994 <stride_dequeue+0x1780>
     if (comp(a, b) == -1)
ffffffffc02062f8:	859a                	mv	a1,t1
ffffffffc02062fa:	8526                	mv	a0,s1
ffffffffc02062fc:	f83e                	sd	a5,48(sp)
ffffffffc02062fe:	f41a                	sd	t1,40(sp)
ffffffffc0206300:	cbdff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206304:	58fd                	li	a7,-1
ffffffffc0206306:	7322                	ld	t1,40(sp)
ffffffffc0206308:	77c2                	ld	a5,48(sp)
ffffffffc020630a:	01151463          	bne	a0,a7,ffffffffc0206312 <stride_dequeue+0xfe>
ffffffffc020630e:	6620106f          	j	ffffffffc0207970 <stride_dequeue+0x175c>
          r = b->left;
ffffffffc0206312:	00833883          	ld	a7,8(t1) # ffffffffc0000008 <_binary_obj___user_matrix_out_size+0xffffffffbfff4598>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206316:	01033583          	ld	a1,16(t1)
ffffffffc020631a:	8526                	mv	a0,s1
ffffffffc020631c:	fc3e                	sd	a5,56(sp)
          r = b->left;
ffffffffc020631e:	f81a                	sd	t1,48(sp)
ffffffffc0206320:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206322:	cf3ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206326:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0206328:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc020632a:	77e2                	ld	a5,56(sp)
          b->left = l;
ffffffffc020632c:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0206330:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc0206334:	c119                	beqz	a0,ffffffffc020633a <stride_dequeue+0x126>
ffffffffc0206336:	00653023          	sd	t1,0(a0)
          b->right = r;
ffffffffc020633a:	7702                	ld	a4,32(sp)
          b->left = l;
ffffffffc020633c:	0067b423          	sd	t1,8(a5)
          if (l) l->parent = b;
ffffffffc0206340:	84be                	mv	s1,a5
          b->right = r;
ffffffffc0206342:	eb98                	sd	a4,16(a5)
          if (l) l->parent = b;
ffffffffc0206344:	00f33023          	sd	a5,0(t1)
          b->right = r;
ffffffffc0206348:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc020634a:	009a3423          	sd	s1,8(s4)
          b->right = r;
ffffffffc020634e:	00fa3823          	sd	a5,16(s4)
          if (l) l->parent = b;
ffffffffc0206352:	0144b023          	sd	s4,0(s1)
ffffffffc0206356:	84d2                	mv	s1,s4
          b->right = r;
ffffffffc0206358:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc020635a:	009cb423          	sd	s1,8(s9)
          b->right = r;
ffffffffc020635e:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc0206362:	0194b023          	sd	s9,0(s1)
ffffffffc0206366:	84e6                	mv	s1,s9
          b->right = r;
ffffffffc0206368:	67a2                	ld	a5,8(sp)
          b->left = l;
ffffffffc020636a:	009d3423          	sd	s1,8(s10)
          b->right = r;
ffffffffc020636e:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc0206372:	01a4b023          	sd	s10,0(s1)
ffffffffc0206376:	84ea                	mv	s1,s10
          b->left = l;
ffffffffc0206378:	0099b423          	sd	s1,8(s3)
          b->right = r;
ffffffffc020637c:	0189b823          	sd	s8,16(s3)
          if (l) l->parent = b;
ffffffffc0206380:	0134b023          	sd	s3,0(s1)
ffffffffc0206384:	84ce                	mv	s1,s3
          b->left = l;
ffffffffc0206386:	e404                	sd	s1,8(s0)
          b->right = r;
ffffffffc0206388:	01743823          	sd	s7,16(s0)
          if (l) l->parent = b;
ffffffffc020638c:	e080                	sd	s0,0(s1)
     if (rep) rep->parent = p;
ffffffffc020638e:	01b43023          	sd	s11,0(s0)
     
     if (p)
ffffffffc0206392:	180d8063          	beqz	s11,ffffffffc0206512 <stride_dequeue+0x2fe>
     {
          if (p->left == b)
ffffffffc0206396:	008db703          	ld	a4,8(s11)
ffffffffc020639a:	12890913          	addi	s2,s2,296
ffffffffc020639e:	17270c63          	beq	a4,s2,ffffffffc0206516 <stride_dequeue+0x302>
               p->left = rep;
          else p->right = rep;
ffffffffc02063a2:	008db823          	sd	s0,16(s11)
     rq->proc_num --;
ffffffffc02063a6:	010aa783          	lw	a5,16(s5)
}
ffffffffc02063aa:	70aa                	ld	ra,168(sp)
ffffffffc02063ac:	740a                	ld	s0,160(sp)
     rq->proc_num --;
ffffffffc02063ae:	37fd                	addiw	a5,a5,-1
     rq->lab6_run_pool = skew_heap_remove(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
ffffffffc02063b0:	016abc23          	sd	s6,24(s5)
     rq->proc_num --;
ffffffffc02063b4:	00faa823          	sw	a5,16(s5)
}
ffffffffc02063b8:	64ea                	ld	s1,152(sp)
ffffffffc02063ba:	694a                	ld	s2,144(sp)
ffffffffc02063bc:	69aa                	ld	s3,136(sp)
ffffffffc02063be:	6a0a                	ld	s4,128(sp)
ffffffffc02063c0:	7ae6                	ld	s5,120(sp)
ffffffffc02063c2:	7b46                	ld	s6,112(sp)
ffffffffc02063c4:	7ba6                	ld	s7,104(sp)
ffffffffc02063c6:	7c06                	ld	s8,96(sp)
ffffffffc02063c8:	6ce6                	ld	s9,88(sp)
ffffffffc02063ca:	6d46                	ld	s10,80(sp)
ffffffffc02063cc:	6da6                	ld	s11,72(sp)
ffffffffc02063ce:	614d                	addi	sp,sp,176
ffffffffc02063d0:	8082                	ret
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02063d2:	0104ba03          	ld	s4,16(s1)
          r = a->left;
ffffffffc02063d6:	0084bb83          	ld	s7,8(s1)
     if (a == NULL) return b;
ffffffffc02063da:	120a0063          	beqz	s4,ffffffffc02064fa <stride_dequeue+0x2e6>
     if (comp(a, b) == -1)
ffffffffc02063de:	85a2                	mv	a1,s0
ffffffffc02063e0:	8552                	mv	a0,s4
ffffffffc02063e2:	bdbff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc02063e6:	8caa                	mv	s9,a0
ffffffffc02063e8:	25350563          	beq	a0,s3,ffffffffc0206632 <stride_dequeue+0x41e>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02063ec:	01043d03          	ld	s10,16(s0)
          r = b->left;
ffffffffc02063f0:	00843c03          	ld	s8,8(s0)
     else if (b == NULL) return a;
ffffffffc02063f4:	0e0d0d63          	beqz	s10,ffffffffc02064ee <stride_dequeue+0x2da>
     if (comp(a, b) == -1)
ffffffffc02063f8:	85ea                	mv	a1,s10
ffffffffc02063fa:	8552                	mv	a0,s4
ffffffffc02063fc:	bc1ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206400:	8caa                	mv	s9,a0
ffffffffc0206402:	35350063          	beq	a0,s3,ffffffffc0206742 <stride_dequeue+0x52e>
          r = b->left;
ffffffffc0206406:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020640a:	010d3c83          	ld	s9,16(s10)
          r = b->left;
ffffffffc020640e:	e43e                	sd	a5,8(sp)
     else if (b == NULL) return a;
ffffffffc0206410:	0c0c8763          	beqz	s9,ffffffffc02064de <stride_dequeue+0x2ca>
     if (comp(a, b) == -1)
ffffffffc0206414:	85e6                	mv	a1,s9
ffffffffc0206416:	8552                	mv	a0,s4
ffffffffc0206418:	ba5ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc020641c:	79350c63          	beq	a0,s3,ffffffffc0206bb4 <stride_dequeue+0x9a0>
          r = b->left;
ffffffffc0206420:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206424:	010cb983          	ld	s3,16(s9)
          r = b->left;
ffffffffc0206428:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc020642a:	0a098263          	beqz	s3,ffffffffc02064ce <stride_dequeue+0x2ba>
     if (comp(a, b) == -1)
ffffffffc020642e:	85ce                	mv	a1,s3
ffffffffc0206430:	8552                	mv	a0,s4
ffffffffc0206432:	b8bff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206436:	58fd                	li	a7,-1
ffffffffc0206438:	4b1507e3          	beq	a0,a7,ffffffffc02070e6 <stride_dequeue+0xed2>
          r = b->left;
ffffffffc020643c:	0089b703          	ld	a4,8(s3)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206440:	0109b783          	ld	a5,16(s3)
          r = b->left;
ffffffffc0206444:	ec3a                	sd	a4,24(sp)
     else if (b == NULL) return a;
ffffffffc0206446:	cfa5                	beqz	a5,ffffffffc02064be <stride_dequeue+0x2aa>
     if (comp(a, b) == -1)
ffffffffc0206448:	85be                	mv	a1,a5
ffffffffc020644a:	8552                	mv	a0,s4
ffffffffc020644c:	f03e                	sd	a5,32(sp)
ffffffffc020644e:	b6fff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206452:	58fd                	li	a7,-1
ffffffffc0206454:	7782                	ld	a5,32(sp)
ffffffffc0206456:	01151463          	bne	a0,a7,ffffffffc020645e <stride_dequeue+0x24a>
ffffffffc020645a:	40e0106f          	j	ffffffffc0207868 <stride_dequeue+0x1654>
          r = b->left;
ffffffffc020645e:	6798                	ld	a4,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206460:	0107b303          	ld	t1,16(a5)
          r = b->left;
ffffffffc0206464:	f03a                	sd	a4,32(sp)
     else if (b == NULL) return a;
ffffffffc0206466:	00031463          	bnez	t1,ffffffffc020646e <stride_dequeue+0x25a>
ffffffffc020646a:	0bb0106f          	j	ffffffffc0207d24 <stride_dequeue+0x1b10>
     if (comp(a, b) == -1)
ffffffffc020646e:	859a                	mv	a1,t1
ffffffffc0206470:	8552                	mv	a0,s4
ffffffffc0206472:	f83e                	sd	a5,48(sp)
ffffffffc0206474:	f41a                	sd	t1,40(sp)
ffffffffc0206476:	b47ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc020647a:	58fd                	li	a7,-1
ffffffffc020647c:	7322                	ld	t1,40(sp)
ffffffffc020647e:	77c2                	ld	a5,48(sp)
ffffffffc0206480:	01151463          	bne	a0,a7,ffffffffc0206488 <stride_dequeue+0x274>
ffffffffc0206484:	2310106f          	j	ffffffffc0207eb4 <stride_dequeue+0x1ca0>
          r = b->left;
ffffffffc0206488:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020648c:	01033583          	ld	a1,16(t1)
ffffffffc0206490:	8552                	mv	a0,s4
ffffffffc0206492:	fc3e                	sd	a5,56(sp)
          r = b->left;
ffffffffc0206494:	f81a                	sd	t1,48(sp)
ffffffffc0206496:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206498:	b7dff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc020649c:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc020649e:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc02064a0:	77e2                	ld	a5,56(sp)
          b->left = l;
ffffffffc02064a2:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc02064a6:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc02064aa:	c119                	beqz	a0,ffffffffc02064b0 <stride_dequeue+0x29c>
ffffffffc02064ac:	00653023          	sd	t1,0(a0)
          b->right = r;
ffffffffc02064b0:	7702                	ld	a4,32(sp)
          b->left = l;
ffffffffc02064b2:	0067b423          	sd	t1,8(a5)
          if (l) l->parent = b;
ffffffffc02064b6:	8a3e                	mv	s4,a5
          b->right = r;
ffffffffc02064b8:	eb98                	sd	a4,16(a5)
          if (l) l->parent = b;
ffffffffc02064ba:	00f33023          	sd	a5,0(t1)
          b->right = r;
ffffffffc02064be:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc02064c0:	0149b423          	sd	s4,8(s3)
          b->right = r;
ffffffffc02064c4:	00f9b823          	sd	a5,16(s3)
          if (l) l->parent = b;
ffffffffc02064c8:	013a3023          	sd	s3,0(s4)
ffffffffc02064cc:	8a4e                	mv	s4,s3
          b->right = r;
ffffffffc02064ce:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc02064d0:	014cb423          	sd	s4,8(s9)
          b->right = r;
ffffffffc02064d4:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc02064d8:	019a3023          	sd	s9,0(s4)
ffffffffc02064dc:	8a66                	mv	s4,s9
          b->right = r;
ffffffffc02064de:	67a2                	ld	a5,8(sp)
          b->left = l;
ffffffffc02064e0:	014d3423          	sd	s4,8(s10)
          b->right = r;
ffffffffc02064e4:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc02064e8:	01aa3023          	sd	s10,0(s4)
ffffffffc02064ec:	8a6a                	mv	s4,s10
          b->left = l;
ffffffffc02064ee:	01443423          	sd	s4,8(s0)
          b->right = r;
ffffffffc02064f2:	01843823          	sd	s8,16(s0)
          if (l) l->parent = b;
ffffffffc02064f6:	008a3023          	sd	s0,0(s4)
          a->left = l;
ffffffffc02064fa:	e480                	sd	s0,8(s1)
          a->right = r;
ffffffffc02064fc:	0174b823          	sd	s7,16(s1)
          if (l) l->parent = a;
ffffffffc0206500:	e004                	sd	s1,0(s0)
ffffffffc0206502:	8426                	mv	s0,s1
     if (rep) rep->parent = p;
ffffffffc0206504:	01b43023          	sd	s11,0(s0)
ffffffffc0206508:	b569                	j	ffffffffc0206392 <stride_dequeue+0x17e>
ffffffffc020650a:	e80412e3          	bnez	s0,ffffffffc020638e <stride_dequeue+0x17a>
     if (p)
ffffffffc020650e:	e80d94e3          	bnez	s11,ffffffffc0206396 <stride_dequeue+0x182>
ffffffffc0206512:	8b22                	mv	s6,s0
ffffffffc0206514:	bd49                	j	ffffffffc02063a6 <stride_dequeue+0x192>
               p->left = rep;
ffffffffc0206516:	008db423          	sd	s0,8(s11)
ffffffffc020651a:	b571                	j	ffffffffc02063a6 <stride_dequeue+0x192>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020651c:	0104bc03          	ld	s8,16(s1)
          r = a->left;
ffffffffc0206520:	0084ba03          	ld	s4,8(s1)
     if (a == NULL) return b;
ffffffffc0206524:	0e0c0c63          	beqz	s8,ffffffffc020661c <stride_dequeue+0x408>
     if (comp(a, b) == -1)
ffffffffc0206528:	85ce                	mv	a1,s3
ffffffffc020652a:	8562                	mv	a0,s8
ffffffffc020652c:	a91ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206530:	8d2a                	mv	s10,a0
ffffffffc0206532:	31950263          	beq	a0,s9,ffffffffc0206836 <stride_dequeue+0x622>
          r = b->left;
ffffffffc0206536:	0089b783          	ld	a5,8(s3)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020653a:	0109bd03          	ld	s10,16(s3)
          r = b->left;
ffffffffc020653e:	e43e                	sd	a5,8(sp)
     else if (b == NULL) return a;
ffffffffc0206540:	0c0d0763          	beqz	s10,ffffffffc020660e <stride_dequeue+0x3fa>
     if (comp(a, b) == -1)
ffffffffc0206544:	85ea                	mv	a1,s10
ffffffffc0206546:	8562                	mv	a0,s8
ffffffffc0206548:	a75ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc020654c:	7f950c63          	beq	a0,s9,ffffffffc0206d44 <stride_dequeue+0xb30>
          r = b->left;
ffffffffc0206550:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206554:	010d3c83          	ld	s9,16(s10)
          r = b->left;
ffffffffc0206558:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc020655a:	0a0c8263          	beqz	s9,ffffffffc02065fe <stride_dequeue+0x3ea>
     if (comp(a, b) == -1)
ffffffffc020655e:	85e6                	mv	a1,s9
ffffffffc0206560:	8562                	mv	a0,s8
ffffffffc0206562:	a5bff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206566:	58fd                	li	a7,-1
ffffffffc0206568:	41150ae3          	beq	a0,a7,ffffffffc020717c <stride_dequeue+0xf68>
          r = b->left;
ffffffffc020656c:	008cb703          	ld	a4,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206570:	010cb783          	ld	a5,16(s9)
          r = b->left;
ffffffffc0206574:	ec3a                	sd	a4,24(sp)
     else if (b == NULL) return a;
ffffffffc0206576:	cfa5                	beqz	a5,ffffffffc02065ee <stride_dequeue+0x3da>
     if (comp(a, b) == -1)
ffffffffc0206578:	85be                	mv	a1,a5
ffffffffc020657a:	8562                	mv	a0,s8
ffffffffc020657c:	f03e                	sd	a5,32(sp)
ffffffffc020657e:	a3fff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206582:	58fd                	li	a7,-1
ffffffffc0206584:	7782                	ld	a5,32(sp)
ffffffffc0206586:	01151463          	bne	a0,a7,ffffffffc020658e <stride_dequeue+0x37a>
ffffffffc020658a:	3340106f          	j	ffffffffc02078be <stride_dequeue+0x16aa>
          r = b->left;
ffffffffc020658e:	6798                	ld	a4,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206590:	0107b303          	ld	t1,16(a5)
          r = b->left;
ffffffffc0206594:	f03a                	sd	a4,32(sp)
     else if (b == NULL) return a;
ffffffffc0206596:	00031463          	bnez	t1,ffffffffc020659e <stride_dequeue+0x38a>
ffffffffc020659a:	7900106f          	j	ffffffffc0207d2a <stride_dequeue+0x1b16>
     if (comp(a, b) == -1)
ffffffffc020659e:	859a                	mv	a1,t1
ffffffffc02065a0:	8562                	mv	a0,s8
ffffffffc02065a2:	f83e                	sd	a5,48(sp)
ffffffffc02065a4:	f41a                	sd	t1,40(sp)
ffffffffc02065a6:	a17ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc02065aa:	58fd                	li	a7,-1
ffffffffc02065ac:	7322                	ld	t1,40(sp)
ffffffffc02065ae:	77c2                	ld	a5,48(sp)
ffffffffc02065b0:	01151463          	bne	a0,a7,ffffffffc02065b8 <stride_dequeue+0x3a4>
ffffffffc02065b4:	12b0106f          	j	ffffffffc0207ede <stride_dequeue+0x1cca>
          r = b->left;
ffffffffc02065b8:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02065bc:	01033583          	ld	a1,16(t1)
ffffffffc02065c0:	8562                	mv	a0,s8
ffffffffc02065c2:	fc3e                	sd	a5,56(sp)
          r = b->left;
ffffffffc02065c4:	f81a                	sd	t1,48(sp)
ffffffffc02065c6:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02065c8:	a4dff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02065cc:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc02065ce:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc02065d0:	77e2                	ld	a5,56(sp)
          b->left = l;
ffffffffc02065d2:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc02065d6:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc02065da:	c119                	beqz	a0,ffffffffc02065e0 <stride_dequeue+0x3cc>
ffffffffc02065dc:	00653023          	sd	t1,0(a0)
          b->right = r;
ffffffffc02065e0:	7702                	ld	a4,32(sp)
          b->left = l;
ffffffffc02065e2:	0067b423          	sd	t1,8(a5)
          if (l) l->parent = b;
ffffffffc02065e6:	8c3e                	mv	s8,a5
          b->right = r;
ffffffffc02065e8:	eb98                	sd	a4,16(a5)
          if (l) l->parent = b;
ffffffffc02065ea:	00f33023          	sd	a5,0(t1)
          b->right = r;
ffffffffc02065ee:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc02065f0:	018cb423          	sd	s8,8(s9)
          b->right = r;
ffffffffc02065f4:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc02065f8:	019c3023          	sd	s9,0(s8)
ffffffffc02065fc:	8c66                	mv	s8,s9
          b->right = r;
ffffffffc02065fe:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc0206600:	018d3423          	sd	s8,8(s10)
          b->right = r;
ffffffffc0206604:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc0206608:	01ac3023          	sd	s10,0(s8)
ffffffffc020660c:	8c6a                	mv	s8,s10
          b->right = r;
ffffffffc020660e:	67a2                	ld	a5,8(sp)
          b->left = l;
ffffffffc0206610:	0189b423          	sd	s8,8(s3)
          b->right = r;
ffffffffc0206614:	00f9b823          	sd	a5,16(s3)
          if (l) l->parent = b;
ffffffffc0206618:	013c3023          	sd	s3,0(s8)
          a->left = l;
ffffffffc020661c:	0134b423          	sd	s3,8(s1)
          a->right = r;
ffffffffc0206620:	0144b823          	sd	s4,16(s1)
          if (l) l->parent = a;
ffffffffc0206624:	0099b023          	sd	s1,0(s3)
ffffffffc0206628:	bbb9                	j	ffffffffc0206386 <stride_dequeue+0x172>
     else if (b == NULL) return a;
ffffffffc020662a:	8426                	mv	s0,s1
     if (rep) rep->parent = p;
ffffffffc020662c:	01b43023          	sd	s11,0(s0)
ffffffffc0206630:	b38d                	j	ffffffffc0206392 <stride_dequeue+0x17e>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206632:	010a3c03          	ld	s8,16(s4)
          r = a->left;
ffffffffc0206636:	008a3983          	ld	s3,8(s4)
     if (a == NULL) return b;
ffffffffc020663a:	0e0c0c63          	beqz	s8,ffffffffc0206732 <stride_dequeue+0x51e>
     if (comp(a, b) == -1)
ffffffffc020663e:	85a2                	mv	a1,s0
ffffffffc0206640:	8562                	mv	a0,s8
ffffffffc0206642:	97bff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206646:	8d2a                	mv	s10,a0
ffffffffc0206648:	49950063          	beq	a0,s9,ffffffffc0206ac8 <stride_dequeue+0x8b4>
          r = b->left;
ffffffffc020664c:	641c                	ld	a5,8(s0)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020664e:	01043d03          	ld	s10,16(s0)
          r = b->left;
ffffffffc0206652:	e43e                	sd	a5,8(sp)
     else if (b == NULL) return a;
ffffffffc0206654:	0c0d0963          	beqz	s10,ffffffffc0206726 <stride_dequeue+0x512>
     if (comp(a, b) == -1)
ffffffffc0206658:	85ea                	mv	a1,s10
ffffffffc020665a:	8562                	mv	a0,s8
ffffffffc020665c:	961ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206660:	1d9500e3          	beq	a0,s9,ffffffffc0207020 <stride_dequeue+0xe0c>
          r = b->left;
ffffffffc0206664:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206668:	010d3c83          	ld	s9,16(s10)
          r = b->left;
ffffffffc020666c:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc020666e:	0a0c8463          	beqz	s9,ffffffffc0206716 <stride_dequeue+0x502>
     if (comp(a, b) == -1)
ffffffffc0206672:	85e6                	mv	a1,s9
ffffffffc0206674:	8562                	mv	a0,s8
ffffffffc0206676:	947ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc020667a:	58fd                	li	a7,-1
ffffffffc020667c:	631507e3          	beq	a0,a7,ffffffffc02074aa <stride_dequeue+0x1296>
          r = b->left;
ffffffffc0206680:	008cb703          	ld	a4,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206684:	010cb783          	ld	a5,16(s9)
          r = b->left;
ffffffffc0206688:	ec3a                	sd	a4,24(sp)
     else if (b == NULL) return a;
ffffffffc020668a:	e399                	bnez	a5,ffffffffc0206690 <stride_dequeue+0x47c>
ffffffffc020668c:	1230106f          	j	ffffffffc0207fae <stride_dequeue+0x1d9a>
     if (comp(a, b) == -1)
ffffffffc0206690:	85be                	mv	a1,a5
ffffffffc0206692:	8562                	mv	a0,s8
ffffffffc0206694:	f03e                	sd	a5,32(sp)
ffffffffc0206696:	927ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc020669a:	58fd                	li	a7,-1
ffffffffc020669c:	7782                	ld	a5,32(sp)
ffffffffc020669e:	01151463          	bne	a0,a7,ffffffffc02066a6 <stride_dequeue+0x492>
ffffffffc02066a2:	6f20106f          	j	ffffffffc0207d94 <stride_dequeue+0x1b80>
          r = b->left;
ffffffffc02066a6:	6798                	ld	a4,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02066a8:	0107b303          	ld	t1,16(a5)
          r = b->left;
ffffffffc02066ac:	f03a                	sd	a4,32(sp)
     else if (b == NULL) return a;
ffffffffc02066ae:	04030663          	beqz	t1,ffffffffc02066fa <stride_dequeue+0x4e6>
     if (comp(a, b) == -1)
ffffffffc02066b2:	859a                	mv	a1,t1
ffffffffc02066b4:	8562                	mv	a0,s8
ffffffffc02066b6:	f83e                	sd	a5,48(sp)
ffffffffc02066b8:	f41a                	sd	t1,40(sp)
ffffffffc02066ba:	903ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc02066be:	58fd                	li	a7,-1
ffffffffc02066c0:	7322                	ld	t1,40(sp)
ffffffffc02066c2:	77c2                	ld	a5,48(sp)
ffffffffc02066c4:	01151463          	bne	a0,a7,ffffffffc02066cc <stride_dequeue+0x4b8>
ffffffffc02066c8:	4190106f          	j	ffffffffc02082e0 <stride_dequeue+0x20cc>
          r = b->left;
ffffffffc02066cc:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02066d0:	01033583          	ld	a1,16(t1)
ffffffffc02066d4:	8562                	mv	a0,s8
ffffffffc02066d6:	fc3e                	sd	a5,56(sp)
          r = b->left;
ffffffffc02066d8:	f81a                	sd	t1,48(sp)
ffffffffc02066da:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02066dc:	939ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02066e0:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc02066e2:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc02066e4:	77e2                	ld	a5,56(sp)
          b->left = l;
ffffffffc02066e6:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc02066ea:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc02066ee:	e119                	bnez	a0,ffffffffc02066f4 <stride_dequeue+0x4e0>
ffffffffc02066f0:	57b0106f          	j	ffffffffc020846a <stride_dequeue+0x2256>
ffffffffc02066f4:	00653023          	sd	t1,0(a0)
ffffffffc02066f8:	8c1a                	mv	s8,t1
          b->right = r;
ffffffffc02066fa:	7702                	ld	a4,32(sp)
          b->left = l;
ffffffffc02066fc:	0187b423          	sd	s8,8(a5)
          b->right = r;
ffffffffc0206700:	eb98                	sd	a4,16(a5)
          if (l) l->parent = b;
ffffffffc0206702:	00fc3023          	sd	a5,0(s8)
          b->right = r;
ffffffffc0206706:	6762                	ld	a4,24(sp)
          b->left = l;
ffffffffc0206708:	00fcb423          	sd	a5,8(s9)
          if (l) l->parent = b;
ffffffffc020670c:	8c66                	mv	s8,s9
          b->right = r;
ffffffffc020670e:	00ecb823          	sd	a4,16(s9)
          if (l) l->parent = b;
ffffffffc0206712:	0197b023          	sd	s9,0(a5)
          b->right = r;
ffffffffc0206716:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc0206718:	018d3423          	sd	s8,8(s10)
          b->right = r;
ffffffffc020671c:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc0206720:	01ac3023          	sd	s10,0(s8)
ffffffffc0206724:	8c6a                	mv	s8,s10
          b->right = r;
ffffffffc0206726:	67a2                	ld	a5,8(sp)
          b->left = l;
ffffffffc0206728:	01843423          	sd	s8,8(s0)
          b->right = r;
ffffffffc020672c:	e81c                	sd	a5,16(s0)
          if (l) l->parent = b;
ffffffffc020672e:	008c3023          	sd	s0,0(s8)
          a->left = l;
ffffffffc0206732:	008a3423          	sd	s0,8(s4)
          a->right = r;
ffffffffc0206736:	013a3823          	sd	s3,16(s4)
          if (l) l->parent = a;
ffffffffc020673a:	01443023          	sd	s4,0(s0)
ffffffffc020673e:	8452                	mv	s0,s4
ffffffffc0206740:	bb6d                	j	ffffffffc02064fa <stride_dequeue+0x2e6>
          r = a->left;
ffffffffc0206742:	008a3783          	ld	a5,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206746:	010a3983          	ld	s3,16(s4)
          r = a->left;
ffffffffc020674a:	e43e                	sd	a5,8(sp)
     if (a == NULL) return b;
ffffffffc020674c:	0c098d63          	beqz	s3,ffffffffc0206826 <stride_dequeue+0x612>
     if (comp(a, b) == -1)
ffffffffc0206750:	85ea                	mv	a1,s10
ffffffffc0206752:	854e                	mv	a0,s3
ffffffffc0206754:	869ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206758:	73950e63          	beq	a0,s9,ffffffffc0206e94 <stride_dequeue+0xc80>
          r = b->left;
ffffffffc020675c:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206760:	010d3c83          	ld	s9,16(s10)
          r = b->left;
ffffffffc0206764:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc0206766:	0a0c8963          	beqz	s9,ffffffffc0206818 <stride_dequeue+0x604>
     if (comp(a, b) == -1)
ffffffffc020676a:	85e6                	mv	a1,s9
ffffffffc020676c:	854e                	mv	a0,s3
ffffffffc020676e:	84fff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206772:	58fd                	li	a7,-1
ffffffffc0206774:	01151463          	bne	a0,a7,ffffffffc020677c <stride_dequeue+0x568>
ffffffffc0206778:	7070006f          	j	ffffffffc020767e <stride_dequeue+0x146a>
          r = b->left;
ffffffffc020677c:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206780:	010cb803          	ld	a6,16(s9)
          r = b->left;
ffffffffc0206784:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206786:	00081463          	bnez	a6,ffffffffc020678e <stride_dequeue+0x57a>
ffffffffc020678a:	02b0106f          	j	ffffffffc0207fb4 <stride_dequeue+0x1da0>
     if (comp(a, b) == -1)
ffffffffc020678e:	85c2                	mv	a1,a6
ffffffffc0206790:	854e                	mv	a0,s3
ffffffffc0206792:	f042                	sd	a6,32(sp)
ffffffffc0206794:	829ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206798:	58fd                	li	a7,-1
ffffffffc020679a:	7802                	ld	a6,32(sp)
ffffffffc020679c:	01151463          	bne	a0,a7,ffffffffc02067a4 <stride_dequeue+0x590>
ffffffffc02067a0:	5260106f          	j	ffffffffc0207cc6 <stride_dequeue+0x1ab2>
          r = b->left;
ffffffffc02067a4:	00883783          	ld	a5,8(a6) # fffffffffffff008 <end+0x3fd35b88>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02067a8:	01083303          	ld	t1,16(a6)
          r = b->left;
ffffffffc02067ac:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc02067ae:	04030663          	beqz	t1,ffffffffc02067fa <stride_dequeue+0x5e6>
     if (comp(a, b) == -1)
ffffffffc02067b2:	859a                	mv	a1,t1
ffffffffc02067b4:	854e                	mv	a0,s3
ffffffffc02067b6:	f842                	sd	a6,48(sp)
ffffffffc02067b8:	f41a                	sd	t1,40(sp)
ffffffffc02067ba:	803ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc02067be:	58fd                	li	a7,-1
ffffffffc02067c0:	7322                	ld	t1,40(sp)
ffffffffc02067c2:	7842                	ld	a6,48(sp)
ffffffffc02067c4:	01151463          	bne	a0,a7,ffffffffc02067cc <stride_dequeue+0x5b8>
ffffffffc02067c8:	0ab0106f          	j	ffffffffc0208072 <stride_dequeue+0x1e5e>
          r = b->left;
ffffffffc02067cc:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02067d0:	01033583          	ld	a1,16(t1)
ffffffffc02067d4:	854e                	mv	a0,s3
ffffffffc02067d6:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc02067d8:	f81a                	sd	t1,48(sp)
ffffffffc02067da:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02067dc:	839ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02067e0:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc02067e2:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc02067e4:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc02067e6:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc02067ea:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc02067ee:	e119                	bnez	a0,ffffffffc02067f4 <stride_dequeue+0x5e0>
ffffffffc02067f0:	4fb0106f          	j	ffffffffc02084ea <stride_dequeue+0x22d6>
ffffffffc02067f4:	00653023          	sd	t1,0(a0)
ffffffffc02067f8:	899a                	mv	s3,t1
          b->right = r;
ffffffffc02067fa:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc02067fc:	01383423          	sd	s3,8(a6)
          b->right = r;
ffffffffc0206800:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc0206804:	0109b023          	sd	a6,0(s3)
          b->right = r;
ffffffffc0206808:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc020680a:	010cb423          	sd	a6,8(s9)
          if (l) l->parent = b;
ffffffffc020680e:	89e6                	mv	s3,s9
          b->right = r;
ffffffffc0206810:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc0206814:	01983023          	sd	s9,0(a6)
          b->right = r;
ffffffffc0206818:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc020681a:	013d3423          	sd	s3,8(s10)
          b->right = r;
ffffffffc020681e:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc0206822:	01a9b023          	sd	s10,0(s3)
          a->right = r;
ffffffffc0206826:	67a2                	ld	a5,8(sp)
          a->left = l;
ffffffffc0206828:	01aa3423          	sd	s10,8(s4)
          a->right = r;
ffffffffc020682c:	00fa3823          	sd	a5,16(s4)
          if (l) l->parent = a;
ffffffffc0206830:	014d3023          	sd	s4,0(s10)
ffffffffc0206834:	b96d                	j	ffffffffc02064ee <stride_dequeue+0x2da>
          r = a->left;
ffffffffc0206836:	008c3783          	ld	a5,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020683a:	010c3c83          	ld	s9,16(s8)
          r = a->left;
ffffffffc020683e:	e43e                	sd	a5,8(sp)
     if (a == NULL) return b;
ffffffffc0206840:	0c0c8a63          	beqz	s9,ffffffffc0206914 <stride_dequeue+0x700>
     if (comp(a, b) == -1)
ffffffffc0206844:	85ce                	mv	a1,s3
ffffffffc0206846:	8566                	mv	a0,s9
ffffffffc0206848:	f74ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc020684c:	71a50763          	beq	a0,s10,ffffffffc0206f5a <stride_dequeue+0xd46>
          r = b->left;
ffffffffc0206850:	0089b783          	ld	a5,8(s3)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206854:	0109b603          	ld	a2,16(s3)
          r = b->left;
ffffffffc0206858:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc020685a:	c655                	beqz	a2,ffffffffc0206906 <stride_dequeue+0x6f2>
     if (comp(a, b) == -1)
ffffffffc020685c:	85b2                	mv	a1,a2
ffffffffc020685e:	8566                	mv	a0,s9
ffffffffc0206860:	ec32                	sd	a2,24(sp)
ffffffffc0206862:	f5aff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206866:	58fd                	li	a7,-1
ffffffffc0206868:	6662                	ld	a2,24(sp)
ffffffffc020686a:	6b1506e3          	beq	a0,a7,ffffffffc0207716 <stride_dequeue+0x1502>
          r = b->left;
ffffffffc020686e:	661c                	ld	a5,8(a2)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206870:	01063d03          	ld	s10,16(a2)
          r = b->left;
ffffffffc0206874:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206876:	000d1463          	bnez	s10,ffffffffc020687e <stride_dequeue+0x66a>
ffffffffc020687a:	7520106f          	j	ffffffffc0207fcc <stride_dequeue+0x1db8>
     if (comp(a, b) == -1)
ffffffffc020687e:	85ea                	mv	a1,s10
ffffffffc0206880:	8566                	mv	a0,s9
ffffffffc0206882:	f032                	sd	a2,32(sp)
ffffffffc0206884:	f38ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206888:	58fd                	li	a7,-1
ffffffffc020688a:	7602                	ld	a2,32(sp)
ffffffffc020688c:	01151463          	bne	a0,a7,ffffffffc0206894 <stride_dequeue+0x680>
ffffffffc0206890:	4a60106f          	j	ffffffffc0207d36 <stride_dequeue+0x1b22>
          r = b->left;
ffffffffc0206894:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206898:	010d3303          	ld	t1,16(s10)
          r = b->left;
ffffffffc020689c:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc020689e:	04030663          	beqz	t1,ffffffffc02068ea <stride_dequeue+0x6d6>
     if (comp(a, b) == -1)
ffffffffc02068a2:	859a                	mv	a1,t1
ffffffffc02068a4:	8566                	mv	a0,s9
ffffffffc02068a6:	f832                	sd	a2,48(sp)
ffffffffc02068a8:	f41a                	sd	t1,40(sp)
ffffffffc02068aa:	f12ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc02068ae:	58fd                	li	a7,-1
ffffffffc02068b0:	7322                	ld	t1,40(sp)
ffffffffc02068b2:	7642                	ld	a2,48(sp)
ffffffffc02068b4:	01151463          	bne	a0,a7,ffffffffc02068bc <stride_dequeue+0x6a8>
ffffffffc02068b8:	2f70106f          	j	ffffffffc02083ae <stride_dequeue+0x219a>
          r = b->left;
ffffffffc02068bc:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02068c0:	01033583          	ld	a1,16(t1)
ffffffffc02068c4:	8566                	mv	a0,s9
ffffffffc02068c6:	fc32                	sd	a2,56(sp)
          r = b->left;
ffffffffc02068c8:	f81a                	sd	t1,48(sp)
ffffffffc02068ca:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02068cc:	f48ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02068d0:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc02068d2:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc02068d4:	7662                	ld	a2,56(sp)
          b->left = l;
ffffffffc02068d6:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc02068da:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc02068de:	e119                	bnez	a0,ffffffffc02068e4 <stride_dequeue+0x6d0>
ffffffffc02068e0:	3590106f          	j	ffffffffc0208438 <stride_dequeue+0x2224>
ffffffffc02068e4:	00653023          	sd	t1,0(a0)
ffffffffc02068e8:	8c9a                	mv	s9,t1
          b->right = r;
ffffffffc02068ea:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc02068ec:	019d3423          	sd	s9,8(s10)
          b->right = r;
ffffffffc02068f0:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc02068f4:	01acb023          	sd	s10,0(s9)
          b->right = r;
ffffffffc02068f8:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc02068fa:	01a63423          	sd	s10,8(a2)
          if (l) l->parent = b;
ffffffffc02068fe:	8cb2                	mv	s9,a2
          b->right = r;
ffffffffc0206900:	ea1c                	sd	a5,16(a2)
          if (l) l->parent = b;
ffffffffc0206902:	00cd3023          	sd	a2,0(s10)
          b->right = r;
ffffffffc0206906:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc0206908:	0199b423          	sd	s9,8(s3)
          b->right = r;
ffffffffc020690c:	00f9b823          	sd	a5,16(s3)
          if (l) l->parent = b;
ffffffffc0206910:	013cb023          	sd	s3,0(s9)
          a->right = r;
ffffffffc0206914:	67a2                	ld	a5,8(sp)
          a->left = l;
ffffffffc0206916:	013c3423          	sd	s3,8(s8)
          a->right = r;
ffffffffc020691a:	00fc3823          	sd	a5,16(s8)
          if (l) l->parent = a;
ffffffffc020691e:	0189b023          	sd	s8,0(s3)
ffffffffc0206922:	89e2                	mv	s3,s8
ffffffffc0206924:	b9e5                	j	ffffffffc020661c <stride_dequeue+0x408>
          r = a->left;
ffffffffc0206926:	649c                	ld	a5,8(s1)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206928:	0104ba03          	ld	s4,16(s1)
          r = a->left;
ffffffffc020692c:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc020692e:	0a0a0263          	beqz	s4,ffffffffc02069d2 <stride_dequeue+0x7be>
     if (comp(a, b) == -1)
ffffffffc0206932:	85e6                	mv	a1,s9
ffffffffc0206934:	8552                	mv	a0,s4
ffffffffc0206936:	e86ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc020693a:	58fd                	li	a7,-1
ffffffffc020693c:	171504e3          	beq	a0,a7,ffffffffc02072a4 <stride_dequeue+0x1090>
          r = b->left;
ffffffffc0206940:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206944:	010cb803          	ld	a6,16(s9)
          r = b->left;
ffffffffc0206948:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc020694a:	06080d63          	beqz	a6,ffffffffc02069c4 <stride_dequeue+0x7b0>
     if (comp(a, b) == -1)
ffffffffc020694e:	85c2                	mv	a1,a6
ffffffffc0206950:	8552                	mv	a0,s4
ffffffffc0206952:	f042                	sd	a6,32(sp)
ffffffffc0206954:	e68ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206958:	58fd                	li	a7,-1
ffffffffc020695a:	7802                	ld	a6,32(sp)
ffffffffc020695c:	6b1508e3          	beq	a0,a7,ffffffffc020780c <stride_dequeue+0x15f8>
          r = b->left;
ffffffffc0206960:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206964:	01083303          	ld	t1,16(a6)
          r = b->left;
ffffffffc0206968:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc020696a:	00031463          	bnez	t1,ffffffffc0206972 <stride_dequeue+0x75e>
ffffffffc020696e:	4dc0106f          	j	ffffffffc0207e4a <stride_dequeue+0x1c36>
     if (comp(a, b) == -1)
ffffffffc0206972:	859a                	mv	a1,t1
ffffffffc0206974:	8552                	mv	a0,s4
ffffffffc0206976:	f842                	sd	a6,48(sp)
ffffffffc0206978:	f41a                	sd	t1,40(sp)
ffffffffc020697a:	e42ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc020697e:	58fd                	li	a7,-1
ffffffffc0206980:	7322                	ld	t1,40(sp)
ffffffffc0206982:	7842                	ld	a6,48(sp)
ffffffffc0206984:	01151463          	bne	a0,a7,ffffffffc020698c <stride_dequeue+0x778>
ffffffffc0206988:	5800106f          	j	ffffffffc0207f08 <stride_dequeue+0x1cf4>
          r = b->left;
ffffffffc020698c:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206990:	01033583          	ld	a1,16(t1)
ffffffffc0206994:	8552                	mv	a0,s4
ffffffffc0206996:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc0206998:	f81a                	sd	t1,48(sp)
ffffffffc020699a:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020699c:	e78ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02069a0:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc02069a2:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc02069a4:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc02069a6:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc02069aa:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc02069ae:	c119                	beqz	a0,ffffffffc02069b4 <stride_dequeue+0x7a0>
ffffffffc02069b0:	00653023          	sd	t1,0(a0)
          b->right = r;
ffffffffc02069b4:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc02069b6:	00683423          	sd	t1,8(a6)
          if (l) l->parent = b;
ffffffffc02069ba:	8a42                	mv	s4,a6
          b->right = r;
ffffffffc02069bc:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc02069c0:	01033023          	sd	a6,0(t1)
          b->right = r;
ffffffffc02069c4:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc02069c6:	014cb423          	sd	s4,8(s9)
          b->right = r;
ffffffffc02069ca:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc02069ce:	019a3023          	sd	s9,0(s4)
          a->right = r;
ffffffffc02069d2:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc02069d4:	0194b423          	sd	s9,8(s1)
          a->right = r;
ffffffffc02069d8:	e89c                	sd	a5,16(s1)
          if (l) l->parent = a;
ffffffffc02069da:	009cb023          	sd	s1,0(s9)
ffffffffc02069de:	b269                	j	ffffffffc0206368 <stride_dequeue+0x154>
          r = a->left;
ffffffffc02069e0:	649c                	ld	a5,8(s1)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02069e2:	0104ba03          	ld	s4,16(s1)
          r = a->left;
ffffffffc02069e6:	e43e                	sd	a5,8(sp)
     if (a == NULL) return b;
ffffffffc02069e8:	0c0a0963          	beqz	s4,ffffffffc0206aba <stride_dequeue+0x8a6>
     if (comp(a, b) == -1)
ffffffffc02069ec:	85ea                	mv	a1,s10
ffffffffc02069ee:	8552                	mv	a0,s4
ffffffffc02069f0:	dccff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc02069f4:	29950463          	beq	a0,s9,ffffffffc0206c7c <stride_dequeue+0xa68>
          r = b->left;
ffffffffc02069f8:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02069fc:	010d3c83          	ld	s9,16(s10)
          r = b->left;
ffffffffc0206a00:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc0206a02:	0a0c8563          	beqz	s9,ffffffffc0206aac <stride_dequeue+0x898>
     if (comp(a, b) == -1)
ffffffffc0206a06:	85e6                	mv	a1,s9
ffffffffc0206a08:	8552                	mv	a0,s4
ffffffffc0206a0a:	db2ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206a0e:	58fd                	li	a7,-1
ffffffffc0206a10:	011501e3          	beq	a0,a7,ffffffffc0207212 <stride_dequeue+0xffe>
          r = b->left;
ffffffffc0206a14:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206a18:	010cb803          	ld	a6,16(s9)
          r = b->left;
ffffffffc0206a1c:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206a1e:	06080f63          	beqz	a6,ffffffffc0206a9c <stride_dequeue+0x888>
     if (comp(a, b) == -1)
ffffffffc0206a22:	85c2                	mv	a1,a6
ffffffffc0206a24:	8552                	mv	a0,s4
ffffffffc0206a26:	f042                	sd	a6,32(sp)
ffffffffc0206a28:	d94ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206a2c:	58fd                	li	a7,-1
ffffffffc0206a2e:	7802                	ld	a6,32(sp)
ffffffffc0206a30:	01151463          	bne	a0,a7,ffffffffc0206a38 <stride_dequeue+0x824>
ffffffffc0206a34:	6e10006f          	j	ffffffffc0207914 <stride_dequeue+0x1700>
          r = b->left;
ffffffffc0206a38:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206a3c:	01083303          	ld	t1,16(a6)
          r = b->left;
ffffffffc0206a40:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206a42:	00031463          	bnez	t1,ffffffffc0206a4a <stride_dequeue+0x836>
ffffffffc0206a46:	40a0106f          	j	ffffffffc0207e50 <stride_dequeue+0x1c3c>
     if (comp(a, b) == -1)
ffffffffc0206a4a:	859a                	mv	a1,t1
ffffffffc0206a4c:	8552                	mv	a0,s4
ffffffffc0206a4e:	f842                	sd	a6,48(sp)
ffffffffc0206a50:	f41a                	sd	t1,40(sp)
ffffffffc0206a52:	d6aff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206a56:	58fd                	li	a7,-1
ffffffffc0206a58:	7322                	ld	t1,40(sp)
ffffffffc0206a5a:	7842                	ld	a6,48(sp)
ffffffffc0206a5c:	01151463          	bne	a0,a7,ffffffffc0206a64 <stride_dequeue+0x850>
ffffffffc0206a60:	5240106f          	j	ffffffffc0207f84 <stride_dequeue+0x1d70>
          r = b->left;
ffffffffc0206a64:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206a68:	01033583          	ld	a1,16(t1)
ffffffffc0206a6c:	8552                	mv	a0,s4
ffffffffc0206a6e:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc0206a70:	f81a                	sd	t1,48(sp)
ffffffffc0206a72:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206a74:	da0ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206a78:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0206a7a:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc0206a7c:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc0206a7e:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0206a82:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc0206a86:	c119                	beqz	a0,ffffffffc0206a8c <stride_dequeue+0x878>
ffffffffc0206a88:	00653023          	sd	t1,0(a0)
          b->right = r;
ffffffffc0206a8c:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206a8e:	00683423          	sd	t1,8(a6)
          if (l) l->parent = b;
ffffffffc0206a92:	8a42                	mv	s4,a6
          b->right = r;
ffffffffc0206a94:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc0206a98:	01033023          	sd	a6,0(t1)
          b->right = r;
ffffffffc0206a9c:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0206a9e:	014cb423          	sd	s4,8(s9)
          b->right = r;
ffffffffc0206aa2:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc0206aa6:	019a3023          	sd	s9,0(s4)
ffffffffc0206aaa:	8a66                	mv	s4,s9
          b->right = r;
ffffffffc0206aac:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc0206aae:	014d3423          	sd	s4,8(s10)
          b->right = r;
ffffffffc0206ab2:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc0206ab6:	01aa3023          	sd	s10,0(s4)
          a->right = r;
ffffffffc0206aba:	67a2                	ld	a5,8(sp)
          a->left = l;
ffffffffc0206abc:	01a4b423          	sd	s10,8(s1)
          a->right = r;
ffffffffc0206ac0:	e89c                	sd	a5,16(s1)
          if (l) l->parent = a;
ffffffffc0206ac2:	009d3023          	sd	s1,0(s10)
ffffffffc0206ac6:	b84d                	j	ffffffffc0206378 <stride_dequeue+0x164>
          r = a->left;
ffffffffc0206ac8:	008c3783          	ld	a5,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206acc:	010c3c83          	ld	s9,16(s8)
          r = a->left;
ffffffffc0206ad0:	e43e                	sd	a5,8(sp)
     if (a == NULL) return b;
ffffffffc0206ad2:	0c0c8863          	beqz	s9,ffffffffc0206ba2 <stride_dequeue+0x98e>
     if (comp(a, b) == -1)
ffffffffc0206ad6:	85a2                	mv	a1,s0
ffffffffc0206ad8:	8566                	mv	a0,s9
ffffffffc0206ada:	ce2ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206ade:	0ba506e3          	beq	a0,s10,ffffffffc020738a <stride_dequeue+0x1176>
          r = b->left;
ffffffffc0206ae2:	641c                	ld	a5,8(s0)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206ae4:	01043d03          	ld	s10,16(s0)
          r = b->left;
ffffffffc0206ae8:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc0206aea:	000d1463          	bnez	s10,ffffffffc0206af2 <stride_dequeue+0x8de>
ffffffffc0206aee:	2420106f          	j	ffffffffc0207d30 <stride_dequeue+0x1b1c>
     if (comp(a, b) == -1)
ffffffffc0206af2:	85ea                	mv	a1,s10
ffffffffc0206af4:	8566                	mv	a0,s9
ffffffffc0206af6:	cc6ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206afa:	537d                	li	t1,-1
ffffffffc0206afc:	00651463          	bne	a0,t1,ffffffffc0206b04 <stride_dequeue+0x8f0>
ffffffffc0206b00:	6ef0006f          	j	ffffffffc02079ee <stride_dequeue+0x17da>
          r = b->left;
ffffffffc0206b04:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206b08:	010d3703          	ld	a4,16(s10)
          r = b->left;
ffffffffc0206b0c:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206b0e:	cf2d                	beqz	a4,ffffffffc0206b88 <stride_dequeue+0x974>
     if (comp(a, b) == -1)
ffffffffc0206b10:	85ba                	mv	a1,a4
ffffffffc0206b12:	8566                	mv	a0,s9
ffffffffc0206b14:	f03a                	sd	a4,32(sp)
ffffffffc0206b16:	ca6ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206b1a:	537d                	li	t1,-1
ffffffffc0206b1c:	7702                	ld	a4,32(sp)
ffffffffc0206b1e:	00651463          	bne	a0,t1,ffffffffc0206b26 <stride_dequeue+0x912>
ffffffffc0206b22:	69e0106f          	j	ffffffffc02081c0 <stride_dequeue+0x1fac>
          r = b->left;
ffffffffc0206b26:	671c                	ld	a5,8(a4)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206b28:	01073883          	ld	a7,16(a4)
          r = b->left;
ffffffffc0206b2c:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206b2e:	04088663          	beqz	a7,ffffffffc0206b7a <stride_dequeue+0x966>
     if (comp(a, b) == -1)
ffffffffc0206b32:	85c6                	mv	a1,a7
ffffffffc0206b34:	8566                	mv	a0,s9
ffffffffc0206b36:	f83a                	sd	a4,48(sp)
ffffffffc0206b38:	f446                	sd	a7,40(sp)
ffffffffc0206b3a:	c82ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206b3e:	537d                	li	t1,-1
ffffffffc0206b40:	78a2                	ld	a7,40(sp)
ffffffffc0206b42:	7742                	ld	a4,48(sp)
ffffffffc0206b44:	00651463          	bne	a0,t1,ffffffffc0206b4c <stride_dequeue+0x938>
ffffffffc0206b48:	4010106f          	j	ffffffffc0208748 <stride_dequeue+0x2534>
          r = b->left;
ffffffffc0206b4c:	0088b303          	ld	t1,8(a7) # 2008 <_binary_obj___user_faultread_out_size-0x7900>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206b50:	0108b583          	ld	a1,16(a7)
ffffffffc0206b54:	8566                	mv	a0,s9
ffffffffc0206b56:	fc3a                	sd	a4,56(sp)
          r = b->left;
ffffffffc0206b58:	f846                	sd	a7,48(sp)
ffffffffc0206b5a:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206b5c:	cb8ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206b60:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0206b62:	7322                	ld	t1,40(sp)
          if (l) l->parent = b;
ffffffffc0206b64:	7762                	ld	a4,56(sp)
          b->left = l;
ffffffffc0206b66:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc0206b6a:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc0206b6e:	e119                	bnez	a0,ffffffffc0206b74 <stride_dequeue+0x960>
ffffffffc0206b70:	5510106f          	j	ffffffffc02088c0 <stride_dequeue+0x26ac>
ffffffffc0206b74:	01153023          	sd	a7,0(a0)
ffffffffc0206b78:	8cc6                	mv	s9,a7
          b->right = r;
ffffffffc0206b7a:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206b7c:	01973423          	sd	s9,8(a4)
          b->right = r;
ffffffffc0206b80:	eb1c                	sd	a5,16(a4)
          if (l) l->parent = b;
ffffffffc0206b82:	00ecb023          	sd	a4,0(s9)
ffffffffc0206b86:	8cba                	mv	s9,a4
          b->right = r;
ffffffffc0206b88:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0206b8a:	019d3423          	sd	s9,8(s10)
          b->right = r;
ffffffffc0206b8e:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc0206b92:	01acb023          	sd	s10,0(s9)
          b->right = r;
ffffffffc0206b96:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc0206b98:	01a43423          	sd	s10,8(s0)
          b->right = r;
ffffffffc0206b9c:	e81c                	sd	a5,16(s0)
          if (l) l->parent = b;
ffffffffc0206b9e:	008d3023          	sd	s0,0(s10)
          a->right = r;
ffffffffc0206ba2:	67a2                	ld	a5,8(sp)
          a->left = l;
ffffffffc0206ba4:	008c3423          	sd	s0,8(s8)
          a->right = r;
ffffffffc0206ba8:	00fc3823          	sd	a5,16(s8)
          if (l) l->parent = a;
ffffffffc0206bac:	01843023          	sd	s8,0(s0)
ffffffffc0206bb0:	8462                	mv	s0,s8
ffffffffc0206bb2:	b641                	j	ffffffffc0206732 <stride_dequeue+0x51e>
          r = a->left;
ffffffffc0206bb4:	008a3783          	ld	a5,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206bb8:	010a3983          	ld	s3,16(s4)
          r = a->left;
ffffffffc0206bbc:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc0206bbe:	0a098663          	beqz	s3,ffffffffc0206c6a <stride_dequeue+0xa56>
     if (comp(a, b) == -1)
ffffffffc0206bc2:	85e6                	mv	a1,s9
ffffffffc0206bc4:	854e                	mv	a0,s3
ffffffffc0206bc6:	bf6ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206bca:	58fd                	li	a7,-1
ffffffffc0206bcc:	21150ce3          	beq	a0,a7,ffffffffc02075e4 <stride_dequeue+0x13d0>
          r = b->left;
ffffffffc0206bd0:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206bd4:	010cb803          	ld	a6,16(s9)
          r = b->left;
ffffffffc0206bd8:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206bda:	00081463          	bnez	a6,ffffffffc0206be2 <stride_dequeue+0x9ce>
ffffffffc0206bde:	3dc0106f          	j	ffffffffc0207fba <stride_dequeue+0x1da6>
     if (comp(a, b) == -1)
ffffffffc0206be2:	85c2                	mv	a1,a6
ffffffffc0206be4:	854e                	mv	a0,s3
ffffffffc0206be6:	f042                	sd	a6,32(sp)
ffffffffc0206be8:	bd4ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206bec:	58fd                	li	a7,-1
ffffffffc0206bee:	7802                	ld	a6,32(sp)
ffffffffc0206bf0:	01151463          	bne	a0,a7,ffffffffc0206bf8 <stride_dequeue+0x9e4>
ffffffffc0206bf4:	7b90006f          	j	ffffffffc0207bac <stride_dequeue+0x1998>
          r = b->left;
ffffffffc0206bf8:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206bfc:	01083303          	ld	t1,16(a6)
          r = b->left;
ffffffffc0206c00:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206c02:	04030663          	beqz	t1,ffffffffc0206c4e <stride_dequeue+0xa3a>
     if (comp(a, b) == -1)
ffffffffc0206c06:	859a                	mv	a1,t1
ffffffffc0206c08:	854e                	mv	a0,s3
ffffffffc0206c0a:	f842                	sd	a6,48(sp)
ffffffffc0206c0c:	f41a                	sd	t1,40(sp)
ffffffffc0206c0e:	baeff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206c12:	58fd                	li	a7,-1
ffffffffc0206c14:	7322                	ld	t1,40(sp)
ffffffffc0206c16:	7842                	ld	a6,48(sp)
ffffffffc0206c18:	01151463          	bne	a0,a7,ffffffffc0206c20 <stride_dequeue+0xa0c>
ffffffffc0206c1c:	5cc0106f          	j	ffffffffc02081e8 <stride_dequeue+0x1fd4>
          r = b->left;
ffffffffc0206c20:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206c24:	01033583          	ld	a1,16(t1)
ffffffffc0206c28:	854e                	mv	a0,s3
ffffffffc0206c2a:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc0206c2c:	f81a                	sd	t1,48(sp)
ffffffffc0206c2e:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206c30:	be4ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206c34:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0206c36:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc0206c38:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc0206c3a:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0206c3e:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc0206c42:	e119                	bnez	a0,ffffffffc0206c48 <stride_dequeue+0xa34>
ffffffffc0206c44:	7ee0106f          	j	ffffffffc0208432 <stride_dequeue+0x221e>
ffffffffc0206c48:	00653023          	sd	t1,0(a0)
ffffffffc0206c4c:	899a                	mv	s3,t1
          b->right = r;
ffffffffc0206c4e:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206c50:	01383423          	sd	s3,8(a6)
          b->right = r;
ffffffffc0206c54:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc0206c58:	0109b023          	sd	a6,0(s3)
          b->right = r;
ffffffffc0206c5c:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0206c5e:	010cb423          	sd	a6,8(s9)
          b->right = r;
ffffffffc0206c62:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc0206c66:	01983023          	sd	s9,0(a6)
          a->right = r;
ffffffffc0206c6a:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc0206c6c:	019a3423          	sd	s9,8(s4)
          a->right = r;
ffffffffc0206c70:	00fa3823          	sd	a5,16(s4)
          if (l) l->parent = a;
ffffffffc0206c74:	014cb023          	sd	s4,0(s9)
ffffffffc0206c78:	867ff06f          	j	ffffffffc02064de <stride_dequeue+0x2ca>
          r = a->left;
ffffffffc0206c7c:	008a3783          	ld	a5,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206c80:	010a3c83          	ld	s9,16(s4)
          r = a->left;
ffffffffc0206c84:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc0206c86:	0a0c8663          	beqz	s9,ffffffffc0206d32 <stride_dequeue+0xb1e>
     if (comp(a, b) == -1)
ffffffffc0206c8a:	85ea                	mv	a1,s10
ffffffffc0206c8c:	8566                	mv	a0,s9
ffffffffc0206c8e:	b2eff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206c92:	58fd                	li	a7,-1
ffffffffc0206c94:	0b1509e3          	beq	a0,a7,ffffffffc0207546 <stride_dequeue+0x1332>
          r = b->left;
ffffffffc0206c98:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206c9c:	010d3803          	ld	a6,16(s10)
          r = b->left;
ffffffffc0206ca0:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206ca2:	00081463          	bnez	a6,ffffffffc0206caa <stride_dequeue+0xa96>
ffffffffc0206ca6:	31a0106f          	j	ffffffffc0207fc0 <stride_dequeue+0x1dac>
     if (comp(a, b) == -1)
ffffffffc0206caa:	85c2                	mv	a1,a6
ffffffffc0206cac:	8566                	mv	a0,s9
ffffffffc0206cae:	f042                	sd	a6,32(sp)
ffffffffc0206cb0:	b0cff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206cb4:	58fd                	li	a7,-1
ffffffffc0206cb6:	7802                	ld	a6,32(sp)
ffffffffc0206cb8:	01151463          	bne	a0,a7,ffffffffc0206cc0 <stride_dequeue+0xaac>
ffffffffc0206cbc:	7ad0006f          	j	ffffffffc0207c68 <stride_dequeue+0x1a54>
          r = b->left;
ffffffffc0206cc0:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206cc4:	01083303          	ld	t1,16(a6)
          r = b->left;
ffffffffc0206cc8:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206cca:	04030663          	beqz	t1,ffffffffc0206d16 <stride_dequeue+0xb02>
     if (comp(a, b) == -1)
ffffffffc0206cce:	859a                	mv	a1,t1
ffffffffc0206cd0:	8566                	mv	a0,s9
ffffffffc0206cd2:	f842                	sd	a6,48(sp)
ffffffffc0206cd4:	f41a                	sd	t1,40(sp)
ffffffffc0206cd6:	ae6ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206cda:	58fd                	li	a7,-1
ffffffffc0206cdc:	7322                	ld	t1,40(sp)
ffffffffc0206cde:	7842                	ld	a6,48(sp)
ffffffffc0206ce0:	01151463          	bne	a0,a7,ffffffffc0206ce8 <stride_dequeue+0xad4>
ffffffffc0206ce4:	4360106f          	j	ffffffffc020811a <stride_dequeue+0x1f06>
          r = b->left;
ffffffffc0206ce8:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206cec:	01033583          	ld	a1,16(t1)
ffffffffc0206cf0:	8566                	mv	a0,s9
ffffffffc0206cf2:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc0206cf4:	f81a                	sd	t1,48(sp)
ffffffffc0206cf6:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206cf8:	b1cff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206cfc:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0206cfe:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc0206d00:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc0206d02:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0206d06:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc0206d0a:	e119                	bnez	a0,ffffffffc0206d10 <stride_dequeue+0xafc>
ffffffffc0206d0c:	7ea0106f          	j	ffffffffc02084f6 <stride_dequeue+0x22e2>
ffffffffc0206d10:	00653023          	sd	t1,0(a0)
ffffffffc0206d14:	8c9a                	mv	s9,t1
          b->right = r;
ffffffffc0206d16:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206d18:	01983423          	sd	s9,8(a6)
          b->right = r;
ffffffffc0206d1c:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc0206d20:	010cb023          	sd	a6,0(s9)
          b->right = r;
ffffffffc0206d24:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0206d26:	010d3423          	sd	a6,8(s10)
          b->right = r;
ffffffffc0206d2a:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc0206d2e:	01a83023          	sd	s10,0(a6)
          a->right = r;
ffffffffc0206d32:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc0206d34:	01aa3423          	sd	s10,8(s4)
          a->right = r;
ffffffffc0206d38:	00fa3823          	sd	a5,16(s4)
          if (l) l->parent = a;
ffffffffc0206d3c:	014d3023          	sd	s4,0(s10)
ffffffffc0206d40:	8d52                	mv	s10,s4
ffffffffc0206d42:	bba5                	j	ffffffffc0206aba <stride_dequeue+0x8a6>
          r = a->left;
ffffffffc0206d44:	008c3783          	ld	a5,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206d48:	010c3c83          	ld	s9,16(s8)
          r = a->left;
ffffffffc0206d4c:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc0206d4e:	0a0c8463          	beqz	s9,ffffffffc0206df6 <stride_dequeue+0xbe2>
     if (comp(a, b) == -1)
ffffffffc0206d52:	85ea                	mv	a1,s10
ffffffffc0206d54:	8566                	mv	a0,s9
ffffffffc0206d56:	a66ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206d5a:	58fd                	li	a7,-1
ffffffffc0206d5c:	6b150763          	beq	a0,a7,ffffffffc020740a <stride_dequeue+0x11f6>
          r = b->left;
ffffffffc0206d60:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206d64:	010d3803          	ld	a6,16(s10)
          r = b->left;
ffffffffc0206d68:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206d6a:	00081463          	bnez	a6,ffffffffc0206d72 <stride_dequeue+0xb5e>
ffffffffc0206d6e:	2580106f          	j	ffffffffc0207fc6 <stride_dequeue+0x1db2>
     if (comp(a, b) == -1)
ffffffffc0206d72:	85c2                	mv	a1,a6
ffffffffc0206d74:	8566                	mv	a0,s9
ffffffffc0206d76:	f042                	sd	a6,32(sp)
ffffffffc0206d78:	a44ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206d7c:	58fd                	li	a7,-1
ffffffffc0206d7e:	7802                	ld	a6,32(sp)
ffffffffc0206d80:	571508e3          	beq	a0,a7,ffffffffc0207af0 <stride_dequeue+0x18dc>
          r = b->left;
ffffffffc0206d84:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206d88:	01083303          	ld	t1,16(a6)
          r = b->left;
ffffffffc0206d8c:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206d8e:	04030663          	beqz	t1,ffffffffc0206dda <stride_dequeue+0xbc6>
     if (comp(a, b) == -1)
ffffffffc0206d92:	859a                	mv	a1,t1
ffffffffc0206d94:	8566                	mv	a0,s9
ffffffffc0206d96:	f842                	sd	a6,48(sp)
ffffffffc0206d98:	f41a                	sd	t1,40(sp)
ffffffffc0206d9a:	a22ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206d9e:	58fd                	li	a7,-1
ffffffffc0206da0:	7322                	ld	t1,40(sp)
ffffffffc0206da2:	7842                	ld	a6,48(sp)
ffffffffc0206da4:	01151463          	bne	a0,a7,ffffffffc0206dac <stride_dequeue+0xb98>
ffffffffc0206da8:	3ee0106f          	j	ffffffffc0208196 <stride_dequeue+0x1f82>
          r = b->left;
ffffffffc0206dac:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206db0:	01033583          	ld	a1,16(t1)
ffffffffc0206db4:	8566                	mv	a0,s9
ffffffffc0206db6:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc0206db8:	f81a                	sd	t1,48(sp)
ffffffffc0206dba:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206dbc:	a58ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206dc0:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0206dc2:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc0206dc4:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc0206dc6:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0206dca:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc0206dce:	e119                	bnez	a0,ffffffffc0206dd4 <stride_dequeue+0xbc0>
ffffffffc0206dd0:	6ee0106f          	j	ffffffffc02084be <stride_dequeue+0x22aa>
ffffffffc0206dd4:	00653023          	sd	t1,0(a0)
ffffffffc0206dd8:	8c9a                	mv	s9,t1
          b->right = r;
ffffffffc0206dda:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206ddc:	01983423          	sd	s9,8(a6)
          b->right = r;
ffffffffc0206de0:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc0206de4:	010cb023          	sd	a6,0(s9)
          b->right = r;
ffffffffc0206de8:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0206dea:	010d3423          	sd	a6,8(s10)
          b->right = r;
ffffffffc0206dee:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc0206df2:	01a83023          	sd	s10,0(a6)
          a->right = r;
ffffffffc0206df6:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc0206df8:	01ac3423          	sd	s10,8(s8)
          a->right = r;
ffffffffc0206dfc:	00fc3823          	sd	a5,16(s8)
          if (l) l->parent = a;
ffffffffc0206e00:	018d3023          	sd	s8,0(s10)
ffffffffc0206e04:	80bff06f          	j	ffffffffc020660e <stride_dequeue+0x3fa>
          r = a->left;
ffffffffc0206e08:	649c                	ld	a5,8(s1)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206e0a:	0104b883          	ld	a7,16(s1)
ffffffffc0206e0e:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc0206e10:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc0206e12:	06088963          	beqz	a7,ffffffffc0206e84 <stride_dequeue+0xc70>
     if (comp(a, b) == -1)
ffffffffc0206e16:	8546                	mv	a0,a7
ffffffffc0206e18:	85d2                	mv	a1,s4
ffffffffc0206e1a:	f446                	sd	a7,40(sp)
ffffffffc0206e1c:	9a0ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206e20:	7802                	ld	a6,32(sp)
ffffffffc0206e22:	78a2                	ld	a7,40(sp)
ffffffffc0206e24:	190505e3          	beq	a0,a6,ffffffffc02077ae <stride_dequeue+0x159a>
          r = b->left;
ffffffffc0206e28:	008a3783          	ld	a5,8(s4)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206e2c:	010a3303          	ld	t1,16(s4)
ffffffffc0206e30:	f442                	sd	a6,40(sp)
          r = b->left;
ffffffffc0206e32:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206e34:	4a030be3          	beqz	t1,ffffffffc0207aea <stride_dequeue+0x18d6>
     if (comp(a, b) == -1)
ffffffffc0206e38:	859a                	mv	a1,t1
ffffffffc0206e3a:	8546                	mv	a0,a7
ffffffffc0206e3c:	fc1a                	sd	t1,56(sp)
ffffffffc0206e3e:	f846                	sd	a7,48(sp)
ffffffffc0206e40:	97cff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206e44:	7822                	ld	a6,40(sp)
ffffffffc0206e46:	78c2                	ld	a7,48(sp)
ffffffffc0206e48:	7362                	ld	t1,56(sp)
ffffffffc0206e4a:	01051463          	bne	a0,a6,ffffffffc0206e52 <stride_dequeue+0xc3e>
ffffffffc0206e4e:	10c0106f          	j	ffffffffc0207f5a <stride_dequeue+0x1d46>
          r = b->left;
ffffffffc0206e52:	00833803          	ld	a6,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206e56:	01033583          	ld	a1,16(t1)
ffffffffc0206e5a:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0206e5c:	f81a                	sd	t1,48(sp)
ffffffffc0206e5e:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206e60:	9b4ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206e64:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0206e66:	7822                	ld	a6,40(sp)
          b->left = l;
ffffffffc0206e68:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0206e6c:	01033823          	sd	a6,16(t1)
          if (l) l->parent = b;
ffffffffc0206e70:	c119                	beqz	a0,ffffffffc0206e76 <stride_dequeue+0xc62>
ffffffffc0206e72:	00653023          	sd	t1,0(a0)
          b->right = r;
ffffffffc0206e76:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206e78:	006a3423          	sd	t1,8(s4)
          b->right = r;
ffffffffc0206e7c:	00fa3823          	sd	a5,16(s4)
          if (l) l->parent = b;
ffffffffc0206e80:	01433023          	sd	s4,0(t1)
          a->right = r;
ffffffffc0206e84:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0206e86:	0144b423          	sd	s4,8(s1)
          a->right = r;
ffffffffc0206e8a:	e89c                	sd	a5,16(s1)
          if (l) l->parent = a;
ffffffffc0206e8c:	009a3023          	sd	s1,0(s4)
ffffffffc0206e90:	cc8ff06f          	j	ffffffffc0206358 <stride_dequeue+0x144>
          r = a->left;
ffffffffc0206e94:	0089b783          	ld	a5,8(s3)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206e98:	0109bc83          	ld	s9,16(s3)
          r = a->left;
ffffffffc0206e9c:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc0206e9e:	0a0c8563          	beqz	s9,ffffffffc0206f48 <stride_dequeue+0xd34>
     if (comp(a, b) == -1)
ffffffffc0206ea2:	85ea                	mv	a1,s10
ffffffffc0206ea4:	8566                	mv	a0,s9
ffffffffc0206ea6:	916ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206eaa:	537d                	li	t1,-1
ffffffffc0206eac:	2e6507e3          	beq	a0,t1,ffffffffc020799a <stride_dequeue+0x1786>
          r = b->left;
ffffffffc0206eb0:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206eb4:	010d3803          	ld	a6,16(s10)
          r = b->left;
ffffffffc0206eb8:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206eba:	08080063          	beqz	a6,ffffffffc0206f3a <stride_dequeue+0xd26>
     if (comp(a, b) == -1)
ffffffffc0206ebe:	85c2                	mv	a1,a6
ffffffffc0206ec0:	8566                	mv	a0,s9
ffffffffc0206ec2:	f042                	sd	a6,32(sp)
ffffffffc0206ec4:	8f8ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206ec8:	537d                	li	t1,-1
ffffffffc0206eca:	7802                	ld	a6,32(sp)
ffffffffc0206ecc:	00651463          	bne	a0,t1,ffffffffc0206ed4 <stride_dequeue+0xcc0>
ffffffffc0206ed0:	29e0106f          	j	ffffffffc020816e <stride_dequeue+0x1f5a>
          r = b->left;
ffffffffc0206ed4:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206ed8:	01083883          	ld	a7,16(a6)
          r = b->left;
ffffffffc0206edc:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206ede:	04088663          	beqz	a7,ffffffffc0206f2a <stride_dequeue+0xd16>
     if (comp(a, b) == -1)
ffffffffc0206ee2:	85c6                	mv	a1,a7
ffffffffc0206ee4:	8566                	mv	a0,s9
ffffffffc0206ee6:	f842                	sd	a6,48(sp)
ffffffffc0206ee8:	f446                	sd	a7,40(sp)
ffffffffc0206eea:	8d2ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206eee:	537d                	li	t1,-1
ffffffffc0206ef0:	78a2                	ld	a7,40(sp)
ffffffffc0206ef2:	7842                	ld	a6,48(sp)
ffffffffc0206ef4:	00651463          	bne	a0,t1,ffffffffc0206efc <stride_dequeue+0xce8>
ffffffffc0206ef8:	0270106f          	j	ffffffffc020871e <stride_dequeue+0x250a>
          r = b->left;
ffffffffc0206efc:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206f00:	0108b583          	ld	a1,16(a7)
ffffffffc0206f04:	8566                	mv	a0,s9
ffffffffc0206f06:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc0206f08:	f846                	sd	a7,48(sp)
ffffffffc0206f0a:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206f0c:	908ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206f10:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0206f12:	7322                	ld	t1,40(sp)
          if (l) l->parent = b;
ffffffffc0206f14:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc0206f16:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc0206f1a:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc0206f1e:	e119                	bnez	a0,ffffffffc0206f24 <stride_dequeue+0xd10>
ffffffffc0206f20:	20d0106f          	j	ffffffffc020892c <stride_dequeue+0x2718>
ffffffffc0206f24:	01153023          	sd	a7,0(a0)
ffffffffc0206f28:	8cc6                	mv	s9,a7
          b->right = r;
ffffffffc0206f2a:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206f2c:	01983423          	sd	s9,8(a6)
          b->right = r;
ffffffffc0206f30:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc0206f34:	010cb023          	sd	a6,0(s9)
ffffffffc0206f38:	8cc2                	mv	s9,a6
          b->right = r;
ffffffffc0206f3a:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0206f3c:	019d3423          	sd	s9,8(s10)
          b->right = r;
ffffffffc0206f40:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc0206f44:	01acb023          	sd	s10,0(s9)
          a->right = r;
ffffffffc0206f48:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc0206f4a:	01a9b423          	sd	s10,8(s3)
          a->right = r;
ffffffffc0206f4e:	00f9b823          	sd	a5,16(s3)
          if (l) l->parent = a;
ffffffffc0206f52:	013d3023          	sd	s3,0(s10)
ffffffffc0206f56:	8d4e                	mv	s10,s3
ffffffffc0206f58:	b0f9                	j	ffffffffc0206826 <stride_dequeue+0x612>
          r = a->left;
ffffffffc0206f5a:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206f5e:	010cbd03          	ld	s10,16(s9)
          r = a->left;
ffffffffc0206f62:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc0206f64:	0a0d0563          	beqz	s10,ffffffffc020700e <stride_dequeue+0xdfa>
     if (comp(a, b) == -1)
ffffffffc0206f68:	85ce                	mv	a1,s3
ffffffffc0206f6a:	856a                	mv	a0,s10
ffffffffc0206f6c:	850ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206f70:	537d                	li	t1,-1
ffffffffc0206f72:	2c6508e3          	beq	a0,t1,ffffffffc0207a42 <stride_dequeue+0x182e>
          r = b->left;
ffffffffc0206f76:	0089b783          	ld	a5,8(s3)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206f7a:	0109b803          	ld	a6,16(s3)
          r = b->left;
ffffffffc0206f7e:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206f80:	08080063          	beqz	a6,ffffffffc0207000 <stride_dequeue+0xdec>
     if (comp(a, b) == -1)
ffffffffc0206f84:	85c2                	mv	a1,a6
ffffffffc0206f86:	856a                	mv	a0,s10
ffffffffc0206f88:	f042                	sd	a6,32(sp)
ffffffffc0206f8a:	832ff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206f8e:	537d                	li	t1,-1
ffffffffc0206f90:	7802                	ld	a6,32(sp)
ffffffffc0206f92:	00651463          	bne	a0,t1,ffffffffc0206f9a <stride_dequeue+0xd86>
ffffffffc0206f96:	39c0106f          	j	ffffffffc0208332 <stride_dequeue+0x211e>
          r = b->left;
ffffffffc0206f9a:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206f9e:	01083883          	ld	a7,16(a6)
          r = b->left;
ffffffffc0206fa2:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206fa4:	04088663          	beqz	a7,ffffffffc0206ff0 <stride_dequeue+0xddc>
     if (comp(a, b) == -1)
ffffffffc0206fa8:	85c6                	mv	a1,a7
ffffffffc0206faa:	856a                	mv	a0,s10
ffffffffc0206fac:	f842                	sd	a6,48(sp)
ffffffffc0206fae:	f446                	sd	a7,40(sp)
ffffffffc0206fb0:	80cff0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0206fb4:	537d                	li	t1,-1
ffffffffc0206fb6:	78a2                	ld	a7,40(sp)
ffffffffc0206fb8:	7842                	ld	a6,48(sp)
ffffffffc0206fba:	00651463          	bne	a0,t1,ffffffffc0206fc2 <stride_dequeue+0xdae>
ffffffffc0206fbe:	6d60106f          	j	ffffffffc0208694 <stride_dequeue+0x2480>
          r = b->left;
ffffffffc0206fc2:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206fc6:	0108b583          	ld	a1,16(a7)
ffffffffc0206fca:	856a                	mv	a0,s10
ffffffffc0206fcc:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc0206fce:	f846                	sd	a7,48(sp)
ffffffffc0206fd0:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206fd2:	842ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206fd6:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0206fd8:	7322                	ld	t1,40(sp)
          if (l) l->parent = b;
ffffffffc0206fda:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc0206fdc:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc0206fe0:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc0206fe4:	e119                	bnez	a0,ffffffffc0206fea <stride_dequeue+0xdd6>
ffffffffc0206fe6:	1170106f          	j	ffffffffc02088fc <stride_dequeue+0x26e8>
ffffffffc0206fea:	01153023          	sd	a7,0(a0)
ffffffffc0206fee:	8d46                	mv	s10,a7
          b->right = r;
ffffffffc0206ff0:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206ff2:	01a83423          	sd	s10,8(a6)
          b->right = r;
ffffffffc0206ff6:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc0206ffa:	010d3023          	sd	a6,0(s10)
ffffffffc0206ffe:	8d42                	mv	s10,a6
          b->right = r;
ffffffffc0207000:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0207002:	01a9b423          	sd	s10,8(s3)
          b->right = r;
ffffffffc0207006:	00f9b823          	sd	a5,16(s3)
          if (l) l->parent = b;
ffffffffc020700a:	013d3023          	sd	s3,0(s10)
          a->right = r;
ffffffffc020700e:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc0207010:	013cb423          	sd	s3,8(s9)
          a->right = r;
ffffffffc0207014:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0207018:	0199b023          	sd	s9,0(s3)
ffffffffc020701c:	89e6                	mv	s3,s9
ffffffffc020701e:	b8dd                	j	ffffffffc0206914 <stride_dequeue+0x700>
          r = a->left;
ffffffffc0207020:	008c3783          	ld	a5,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207024:	010c3c83          	ld	s9,16(s8)
          r = a->left;
ffffffffc0207028:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc020702a:	0a0c8563          	beqz	s9,ffffffffc02070d4 <stride_dequeue+0xec0>
     if (comp(a, b) == -1)
ffffffffc020702e:	85ea                	mv	a1,s10
ffffffffc0207030:	8566                	mv	a0,s9
ffffffffc0207032:	f8bfe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207036:	537d                	li	t1,-1
ffffffffc0207038:	24650fe3          	beq	a0,t1,ffffffffc0207a96 <stride_dequeue+0x1882>
          r = b->left;
ffffffffc020703c:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207040:	010d3803          	ld	a6,16(s10)
          r = b->left;
ffffffffc0207044:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0207046:	08080063          	beqz	a6,ffffffffc02070c6 <stride_dequeue+0xeb2>
     if (comp(a, b) == -1)
ffffffffc020704a:	85c2                	mv	a1,a6
ffffffffc020704c:	8566                	mv	a0,s9
ffffffffc020704e:	f042                	sd	a6,32(sp)
ffffffffc0207050:	f6dfe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207054:	537d                	li	t1,-1
ffffffffc0207056:	7802                	ld	a6,32(sp)
ffffffffc0207058:	00651463          	bne	a0,t1,ffffffffc0207060 <stride_dequeue+0xe4c>
ffffffffc020705c:	2340106f          	j	ffffffffc0208290 <stride_dequeue+0x207c>
          r = b->left;
ffffffffc0207060:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207064:	01083883          	ld	a7,16(a6)
          r = b->left;
ffffffffc0207068:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc020706a:	04088663          	beqz	a7,ffffffffc02070b6 <stride_dequeue+0xea2>
     if (comp(a, b) == -1)
ffffffffc020706e:	85c6                	mv	a1,a7
ffffffffc0207070:	8566                	mv	a0,s9
ffffffffc0207072:	f842                	sd	a6,48(sp)
ffffffffc0207074:	f446                	sd	a7,40(sp)
ffffffffc0207076:	f47fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc020707a:	537d                	li	t1,-1
ffffffffc020707c:	78a2                	ld	a7,40(sp)
ffffffffc020707e:	7842                	ld	a6,48(sp)
ffffffffc0207080:	00651463          	bne	a0,t1,ffffffffc0207088 <stride_dequeue+0xe74>
ffffffffc0207084:	5020106f          	j	ffffffffc0208586 <stride_dequeue+0x2372>
          r = b->left;
ffffffffc0207088:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020708c:	0108b583          	ld	a1,16(a7)
ffffffffc0207090:	8566                	mv	a0,s9
ffffffffc0207092:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc0207094:	f846                	sd	a7,48(sp)
ffffffffc0207096:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207098:	f7dfe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc020709c:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc020709e:	7322                	ld	t1,40(sp)
          if (l) l->parent = b;
ffffffffc02070a0:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc02070a2:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc02070a6:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc02070aa:	e119                	bnez	a0,ffffffffc02070b0 <stride_dequeue+0xe9c>
ffffffffc02070ac:	02d0106f          	j	ffffffffc02088d8 <stride_dequeue+0x26c4>
ffffffffc02070b0:	01153023          	sd	a7,0(a0)
ffffffffc02070b4:	8cc6                	mv	s9,a7
          b->right = r;
ffffffffc02070b6:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc02070b8:	01983423          	sd	s9,8(a6)
          b->right = r;
ffffffffc02070bc:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc02070c0:	010cb023          	sd	a6,0(s9)
ffffffffc02070c4:	8cc2                	mv	s9,a6
          b->right = r;
ffffffffc02070c6:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc02070c8:	019d3423          	sd	s9,8(s10)
          b->right = r;
ffffffffc02070cc:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc02070d0:	01acb023          	sd	s10,0(s9)
          a->right = r;
ffffffffc02070d4:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc02070d6:	01ac3423          	sd	s10,8(s8)
          a->right = r;
ffffffffc02070da:	00fc3823          	sd	a5,16(s8)
          if (l) l->parent = a;
ffffffffc02070de:	018d3023          	sd	s8,0(s10)
ffffffffc02070e2:	e44ff06f          	j	ffffffffc0206726 <stride_dequeue+0x512>
          r = a->left;
ffffffffc02070e6:	008a3783          	ld	a5,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02070ea:	010a3883          	ld	a7,16(s4)
ffffffffc02070ee:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc02070f0:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc02070f2:	06088c63          	beqz	a7,ffffffffc020716a <stride_dequeue+0xf56>
     if (comp(a, b) == -1)
ffffffffc02070f6:	8546                	mv	a0,a7
ffffffffc02070f8:	85ce                	mv	a1,s3
ffffffffc02070fa:	f446                	sd	a7,40(sp)
ffffffffc02070fc:	ec1fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207100:	7802                	ld	a6,32(sp)
ffffffffc0207102:	78a2                	ld	a7,40(sp)
ffffffffc0207104:	4f0504e3          	beq	a0,a6,ffffffffc0207dec <stride_dequeue+0x1bd8>
          r = b->left;
ffffffffc0207108:	0089b783          	ld	a5,8(s3)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020710c:	0109b303          	ld	t1,16(s3)
ffffffffc0207110:	f442                	sd	a6,40(sp)
          r = b->left;
ffffffffc0207112:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0207114:	04030463          	beqz	t1,ffffffffc020715c <stride_dequeue+0xf48>
     if (comp(a, b) == -1)
ffffffffc0207118:	859a                	mv	a1,t1
ffffffffc020711a:	8546                	mv	a0,a7
ffffffffc020711c:	fc1a                	sd	t1,56(sp)
ffffffffc020711e:	f846                	sd	a7,48(sp)
ffffffffc0207120:	e9dfe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207124:	7822                	ld	a6,40(sp)
ffffffffc0207126:	78c2                	ld	a7,48(sp)
ffffffffc0207128:	7362                	ld	t1,56(sp)
ffffffffc020712a:	01051463          	bne	a0,a6,ffffffffc0207132 <stride_dequeue+0xf1e>
ffffffffc020712e:	22c0106f          	j	ffffffffc020835a <stride_dequeue+0x2146>
          r = b->left;
ffffffffc0207132:	00833803          	ld	a6,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207136:	01033583          	ld	a1,16(t1)
ffffffffc020713a:	8546                	mv	a0,a7
          r = b->left;
ffffffffc020713c:	f81a                	sd	t1,48(sp)
ffffffffc020713e:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207140:	ed5fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207144:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0207146:	7822                	ld	a6,40(sp)
          b->left = l;
ffffffffc0207148:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc020714c:	01033823          	sd	a6,16(t1)
          if (l) l->parent = b;
ffffffffc0207150:	e119                	bnez	a0,ffffffffc0207156 <stride_dequeue+0xf42>
ffffffffc0207152:	2d40106f          	j	ffffffffc0208426 <stride_dequeue+0x2212>
ffffffffc0207156:	00653023          	sd	t1,0(a0)
ffffffffc020715a:	889a                	mv	a7,t1
          b->right = r;
ffffffffc020715c:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc020715e:	0119b423          	sd	a7,8(s3)
          b->right = r;
ffffffffc0207162:	00f9b823          	sd	a5,16(s3)
          if (l) l->parent = b;
ffffffffc0207166:	0138b023          	sd	s3,0(a7)
          a->right = r;
ffffffffc020716a:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc020716c:	013a3423          	sd	s3,8(s4)
          a->right = r;
ffffffffc0207170:	00fa3823          	sd	a5,16(s4)
          if (l) l->parent = a;
ffffffffc0207174:	0149b023          	sd	s4,0(s3)
ffffffffc0207178:	b56ff06f          	j	ffffffffc02064ce <stride_dequeue+0x2ba>
          r = a->left;
ffffffffc020717c:	008c3783          	ld	a5,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207180:	010c3883          	ld	a7,16(s8)
ffffffffc0207184:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc0207186:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc0207188:	06088c63          	beqz	a7,ffffffffc0207200 <stride_dequeue+0xfec>
     if (comp(a, b) == -1)
ffffffffc020718c:	8546                	mv	a0,a7
ffffffffc020718e:	85e6                	mv	a1,s9
ffffffffc0207190:	f446                	sd	a7,40(sp)
ffffffffc0207192:	e2bfe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207196:	7802                	ld	a6,32(sp)
ffffffffc0207198:	78a2                	ld	a7,40(sp)
ffffffffc020719a:	4b050ee3          	beq	a0,a6,ffffffffc0207e56 <stride_dequeue+0x1c42>
          r = b->left;
ffffffffc020719e:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02071a2:	010cb303          	ld	t1,16(s9)
ffffffffc02071a6:	f442                	sd	a6,40(sp)
          r = b->left;
ffffffffc02071a8:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc02071aa:	04030463          	beqz	t1,ffffffffc02071f2 <stride_dequeue+0xfde>
     if (comp(a, b) == -1)
ffffffffc02071ae:	859a                	mv	a1,t1
ffffffffc02071b0:	8546                	mv	a0,a7
ffffffffc02071b2:	fc1a                	sd	t1,56(sp)
ffffffffc02071b4:	f846                	sd	a7,48(sp)
ffffffffc02071b6:	e07fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc02071ba:	7822                	ld	a6,40(sp)
ffffffffc02071bc:	78c2                	ld	a7,48(sp)
ffffffffc02071be:	7362                	ld	t1,56(sp)
ffffffffc02071c0:	01051463          	bne	a0,a6,ffffffffc02071c8 <stride_dequeue+0xfb4>
ffffffffc02071c4:	1c00106f          	j	ffffffffc0208384 <stride_dequeue+0x2170>
          r = b->left;
ffffffffc02071c8:	00833803          	ld	a6,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02071cc:	01033583          	ld	a1,16(t1)
ffffffffc02071d0:	8546                	mv	a0,a7
          r = b->left;
ffffffffc02071d2:	f81a                	sd	t1,48(sp)
ffffffffc02071d4:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02071d6:	e3ffe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02071da:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc02071dc:	7822                	ld	a6,40(sp)
          b->left = l;
ffffffffc02071de:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc02071e2:	01033823          	sd	a6,16(t1)
          if (l) l->parent = b;
ffffffffc02071e6:	e119                	bnez	a0,ffffffffc02071ec <stride_dequeue+0xfd8>
ffffffffc02071e8:	2440106f          	j	ffffffffc020842c <stride_dequeue+0x2218>
ffffffffc02071ec:	00653023          	sd	t1,0(a0)
ffffffffc02071f0:	889a                	mv	a7,t1
          b->right = r;
ffffffffc02071f2:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc02071f4:	011cb423          	sd	a7,8(s9)
          b->right = r;
ffffffffc02071f8:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc02071fc:	0198b023          	sd	s9,0(a7)
          a->right = r;
ffffffffc0207200:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207202:	019c3423          	sd	s9,8(s8)
          a->right = r;
ffffffffc0207206:	00fc3823          	sd	a5,16(s8)
          if (l) l->parent = a;
ffffffffc020720a:	018cb023          	sd	s8,0(s9)
ffffffffc020720e:	bf0ff06f          	j	ffffffffc02065fe <stride_dequeue+0x3ea>
          r = a->left;
ffffffffc0207212:	008a3783          	ld	a5,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207216:	010a3883          	ld	a7,16(s4)
ffffffffc020721a:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc020721c:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc020721e:	06088a63          	beqz	a7,ffffffffc0207292 <stride_dequeue+0x107e>
     if (comp(a, b) == -1)
ffffffffc0207222:	8546                	mv	a0,a7
ffffffffc0207224:	85e6                	mv	a1,s9
ffffffffc0207226:	f446                	sd	a7,40(sp)
ffffffffc0207228:	d95fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc020722c:	7802                	ld	a6,32(sp)
ffffffffc020722e:	78a2                	ld	a7,40(sp)
ffffffffc0207230:	1d050de3          	beq	a0,a6,ffffffffc0207c0a <stride_dequeue+0x19f6>
          r = b->left;
ffffffffc0207234:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207238:	010cb303          	ld	t1,16(s9)
ffffffffc020723c:	f442                	sd	a6,40(sp)
          r = b->left;
ffffffffc020723e:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0207240:	04030263          	beqz	t1,ffffffffc0207284 <stride_dequeue+0x1070>
     if (comp(a, b) == -1)
ffffffffc0207244:	859a                	mv	a1,t1
ffffffffc0207246:	8546                	mv	a0,a7
ffffffffc0207248:	fc1a                	sd	t1,56(sp)
ffffffffc020724a:	f846                	sd	a7,48(sp)
ffffffffc020724c:	d71fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207250:	7822                	ld	a6,40(sp)
ffffffffc0207252:	78c2                	ld	a7,48(sp)
ffffffffc0207254:	7362                	ld	t1,56(sp)
ffffffffc0207256:	5b0501e3          	beq	a0,a6,ffffffffc0207ff8 <stride_dequeue+0x1de4>
          r = b->left;
ffffffffc020725a:	00833803          	ld	a6,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020725e:	01033583          	ld	a1,16(t1)
ffffffffc0207262:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207264:	f81a                	sd	t1,48(sp)
ffffffffc0207266:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207268:	dadfe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc020726c:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc020726e:	7822                	ld	a6,40(sp)
          b->left = l;
ffffffffc0207270:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0207274:	01033823          	sd	a6,16(t1)
          if (l) l->parent = b;
ffffffffc0207278:	e119                	bnez	a0,ffffffffc020727e <stride_dequeue+0x106a>
ffffffffc020727a:	2760106f          	j	ffffffffc02084f0 <stride_dequeue+0x22dc>
ffffffffc020727e:	00653023          	sd	t1,0(a0)
ffffffffc0207282:	889a                	mv	a7,t1
          b->right = r;
ffffffffc0207284:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0207286:	011cb423          	sd	a7,8(s9)
          b->right = r;
ffffffffc020728a:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc020728e:	0198b023          	sd	s9,0(a7)
          a->right = r;
ffffffffc0207292:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207294:	019a3423          	sd	s9,8(s4)
          a->right = r;
ffffffffc0207298:	00fa3823          	sd	a5,16(s4)
          if (l) l->parent = a;
ffffffffc020729c:	014cb023          	sd	s4,0(s9)
ffffffffc02072a0:	80dff06f          	j	ffffffffc0206aac <stride_dequeue+0x898>
          r = a->left;
ffffffffc02072a4:	008a3783          	ld	a5,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02072a8:	010a3883          	ld	a7,16(s4)
ffffffffc02072ac:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc02072ae:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc02072b0:	06088c63          	beqz	a7,ffffffffc0207328 <stride_dequeue+0x1114>
     if (comp(a, b) == -1)
ffffffffc02072b4:	8546                	mv	a0,a7
ffffffffc02072b6:	85e6                	mv	a1,s9
ffffffffc02072b8:	f446                	sd	a7,40(sp)
ffffffffc02072ba:	d03fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc02072be:	7802                	ld	a6,32(sp)
ffffffffc02072c0:	78a2                	ld	a7,40(sp)
ffffffffc02072c2:	090506e3          	beq	a0,a6,ffffffffc0207b4e <stride_dequeue+0x193a>
          r = b->left;
ffffffffc02072c6:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02072ca:	010cb303          	ld	t1,16(s9)
ffffffffc02072ce:	f442                	sd	a6,40(sp)
          r = b->left;
ffffffffc02072d0:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc02072d2:	04030463          	beqz	t1,ffffffffc020731a <stride_dequeue+0x1106>
     if (comp(a, b) == -1)
ffffffffc02072d6:	859a                	mv	a1,t1
ffffffffc02072d8:	8546                	mv	a0,a7
ffffffffc02072da:	fc1a                	sd	t1,56(sp)
ffffffffc02072dc:	f846                	sd	a7,48(sp)
ffffffffc02072de:	cdffe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc02072e2:	7822                	ld	a6,40(sp)
ffffffffc02072e4:	78c2                	ld	a7,48(sp)
ffffffffc02072e6:	7362                	ld	t1,56(sp)
ffffffffc02072e8:	01051463          	bne	a0,a6,ffffffffc02072f0 <stride_dequeue+0x10dc>
ffffffffc02072ec:	0ec0106f          	j	ffffffffc02083d8 <stride_dequeue+0x21c4>
          r = b->left;
ffffffffc02072f0:	00833803          	ld	a6,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02072f4:	01033583          	ld	a1,16(t1)
ffffffffc02072f8:	8546                	mv	a0,a7
          r = b->left;
ffffffffc02072fa:	f81a                	sd	t1,48(sp)
ffffffffc02072fc:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02072fe:	d17fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207302:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0207304:	7822                	ld	a6,40(sp)
          b->left = l;
ffffffffc0207306:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc020730a:	01033823          	sd	a6,16(t1)
          if (l) l->parent = b;
ffffffffc020730e:	e119                	bnez	a0,ffffffffc0207314 <stride_dequeue+0x1100>
ffffffffc0207310:	12e0106f          	j	ffffffffc020843e <stride_dequeue+0x222a>
ffffffffc0207314:	00653023          	sd	t1,0(a0)
ffffffffc0207318:	889a                	mv	a7,t1
          b->right = r;
ffffffffc020731a:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc020731c:	011cb423          	sd	a7,8(s9)
          b->right = r;
ffffffffc0207320:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc0207324:	0198b023          	sd	s9,0(a7)
          a->right = r;
ffffffffc0207328:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc020732a:	019a3423          	sd	s9,8(s4)
          a->right = r;
ffffffffc020732e:	00fa3823          	sd	a5,16(s4)
          if (l) l->parent = a;
ffffffffc0207332:	014cb023          	sd	s4,0(s9)
ffffffffc0207336:	8cd2                	mv	s9,s4
ffffffffc0207338:	e9aff06f          	j	ffffffffc02069d2 <stride_dequeue+0x7be>
          r = a->left;
ffffffffc020733c:	6498                	ld	a4,8(s1)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020733e:	0104b883          	ld	a7,16(s1)
ffffffffc0207342:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc0207344:	f03a                	sd	a4,32(sp)
     if (a == NULL) return b;
ffffffffc0207346:	02088c63          	beqz	a7,ffffffffc020737e <stride_dequeue+0x116a>
     if (comp(a, b) == -1)
ffffffffc020734a:	85be                	mv	a1,a5
ffffffffc020734c:	8546                	mv	a0,a7
ffffffffc020734e:	fc3e                	sd	a5,56(sp)
ffffffffc0207350:	f846                	sd	a7,48(sp)
ffffffffc0207352:	c6bfe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207356:	7322                	ld	t1,40(sp)
ffffffffc0207358:	78c2                	ld	a7,48(sp)
ffffffffc020735a:	77e2                	ld	a5,56(sp)
ffffffffc020735c:	3c650ae3          	beq	a0,t1,ffffffffc0207f30 <stride_dequeue+0x1d1c>
          r = b->left;
ffffffffc0207360:	0087b303          	ld	t1,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207364:	6b8c                	ld	a1,16(a5)
ffffffffc0207366:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207368:	f83e                	sd	a5,48(sp)
ffffffffc020736a:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020736c:	ca9fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207370:	77c2                	ld	a5,48(sp)
          b->right = r;
ffffffffc0207372:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207374:	e788                	sd	a0,8(a5)
          b->right = r;
ffffffffc0207376:	0067b823          	sd	t1,16(a5)
          if (l) l->parent = b;
ffffffffc020737a:	c111                	beqz	a0,ffffffffc020737e <stride_dequeue+0x116a>
ffffffffc020737c:	e11c                	sd	a5,0(a0)
          a->right = r;
ffffffffc020737e:	7702                	ld	a4,32(sp)
          a->left = l;
ffffffffc0207380:	e49c                	sd	a5,8(s1)
          a->right = r;
ffffffffc0207382:	e898                	sd	a4,16(s1)
          if (l) l->parent = a;
ffffffffc0207384:	e384                	sd	s1,0(a5)
ffffffffc0207386:	fc3fe06f          	j	ffffffffc0206348 <stride_dequeue+0x134>
          r = a->left;
ffffffffc020738a:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020738e:	010cbd03          	ld	s10,16(s9)
          r = a->left;
ffffffffc0207392:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc0207394:	520d08e3          	beqz	s10,ffffffffc02080c4 <stride_dequeue+0x1eb0>
     if (comp(a, b) == -1)
ffffffffc0207398:	85a2                	mv	a1,s0
ffffffffc020739a:	856a                	mv	a0,s10
ffffffffc020739c:	c21fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc02073a0:	587d                	li	a6,-1
ffffffffc02073a2:	430508e3          	beq	a0,a6,ffffffffc0207fd2 <stride_dequeue+0x1dbe>
          r = b->left;
ffffffffc02073a6:	641c                	ld	a5,8(s0)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02073a8:	6810                	ld	a2,16(s0)
          r = b->left;
ffffffffc02073aa:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc02073ac:	ce15                	beqz	a2,ffffffffc02073e8 <stride_dequeue+0x11d4>
     if (comp(a, b) == -1)
ffffffffc02073ae:	85b2                	mv	a1,a2
ffffffffc02073b0:	856a                	mv	a0,s10
ffffffffc02073b2:	f032                	sd	a2,32(sp)
ffffffffc02073b4:	c09fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc02073b8:	587d                	li	a6,-1
ffffffffc02073ba:	7602                	ld	a2,32(sp)
ffffffffc02073bc:	01051463          	bne	a0,a6,ffffffffc02073c4 <stride_dequeue+0x11b0>
ffffffffc02073c0:	0b00106f          	j	ffffffffc0208470 <stride_dequeue+0x225c>
          r = b->left;
ffffffffc02073c4:	00863803          	ld	a6,8(a2)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02073c8:	6a0c                	ld	a1,16(a2)
ffffffffc02073ca:	856a                	mv	a0,s10
          r = b->left;
ffffffffc02073cc:	f432                	sd	a2,40(sp)
ffffffffc02073ce:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02073d0:	c45fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02073d4:	7622                	ld	a2,40(sp)
          b->right = r;
ffffffffc02073d6:	7802                	ld	a6,32(sp)
          b->left = l;
ffffffffc02073d8:	e608                	sd	a0,8(a2)
          b->right = r;
ffffffffc02073da:	01063823          	sd	a6,16(a2)
          if (l) l->parent = b;
ffffffffc02073de:	e119                	bnez	a0,ffffffffc02073e4 <stride_dequeue+0x11d0>
ffffffffc02073e0:	1a00106f          	j	ffffffffc0208580 <stride_dequeue+0x236c>
ffffffffc02073e4:	e110                	sd	a2,0(a0)
ffffffffc02073e6:	8d32                	mv	s10,a2
          b->right = r;
ffffffffc02073e8:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc02073ea:	01a43423          	sd	s10,8(s0)
          b->right = r;
ffffffffc02073ee:	e81c                	sd	a5,16(s0)
          if (l) l->parent = b;
ffffffffc02073f0:	008d3023          	sd	s0,0(s10)
ffffffffc02073f4:	8d22                	mv	s10,s0
          a->right = r;
ffffffffc02073f6:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc02073f8:	01acb423          	sd	s10,8(s9)
          if (l) l->parent = a;
ffffffffc02073fc:	8466                	mv	s0,s9
          a->right = r;
ffffffffc02073fe:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0207402:	019d3023          	sd	s9,0(s10)
ffffffffc0207406:	f9cff06f          	j	ffffffffc0206ba2 <stride_dequeue+0x98e>
          r = a->left;
ffffffffc020740a:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020740e:	010cb803          	ld	a6,16(s9)
ffffffffc0207412:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc0207414:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc0207416:	00081463          	bnez	a6,ffffffffc020741e <stride_dequeue+0x120a>
ffffffffc020741a:	7e90006f          	j	ffffffffc0208402 <stride_dequeue+0x21ee>
     if (comp(a, b) == -1)
ffffffffc020741e:	8542                	mv	a0,a6
ffffffffc0207420:	85ea                	mv	a1,s10
ffffffffc0207422:	f442                	sd	a6,40(sp)
ffffffffc0207424:	b99fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207428:	7302                	ld	t1,32(sp)
ffffffffc020742a:	7822                	ld	a6,40(sp)
ffffffffc020742c:	00651463          	bne	a0,t1,ffffffffc0207434 <stride_dequeue+0x1220>
ffffffffc0207430:	6db0006f          	j	ffffffffc020830a <stride_dequeue+0x20f6>
          r = b->left;
ffffffffc0207434:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207438:	010d3883          	ld	a7,16(s10)
ffffffffc020743c:	fc1a                	sd	t1,56(sp)
          r = b->left;
ffffffffc020743e:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0207440:	04088463          	beqz	a7,ffffffffc0207488 <stride_dequeue+0x1274>
     if (comp(a, b) == -1)
ffffffffc0207444:	85c6                	mv	a1,a7
ffffffffc0207446:	8542                	mv	a0,a6
ffffffffc0207448:	f846                	sd	a7,48(sp)
ffffffffc020744a:	f442                	sd	a6,40(sp)
ffffffffc020744c:	b71fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207450:	7362                	ld	t1,56(sp)
ffffffffc0207452:	7822                	ld	a6,40(sp)
ffffffffc0207454:	78c2                	ld	a7,48(sp)
ffffffffc0207456:	00651463          	bne	a0,t1,ffffffffc020745e <stride_dequeue+0x124a>
ffffffffc020745a:	0ce0106f          	j	ffffffffc0208528 <stride_dequeue+0x2314>
          r = b->left;
ffffffffc020745e:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207462:	0108b583          	ld	a1,16(a7)
ffffffffc0207466:	8542                	mv	a0,a6
          r = b->left;
ffffffffc0207468:	f846                	sd	a7,48(sp)
ffffffffc020746a:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020746c:	ba9fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207470:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0207472:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207474:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc0207478:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc020747c:	e119                	bnez	a0,ffffffffc0207482 <stride_dequeue+0x126e>
ffffffffc020747e:	48a0106f          	j	ffffffffc0208908 <stride_dequeue+0x26f4>
ffffffffc0207482:	01153023          	sd	a7,0(a0)
ffffffffc0207486:	8846                	mv	a6,a7
          b->right = r;
ffffffffc0207488:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc020748a:	010d3423          	sd	a6,8(s10)
          b->right = r;
ffffffffc020748e:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc0207492:	01a83023          	sd	s10,0(a6)
ffffffffc0207496:	886a                	mv	a6,s10
          a->right = r;
ffffffffc0207498:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc020749a:	010cb423          	sd	a6,8(s9)
          if (l) l->parent = a;
ffffffffc020749e:	8d66                	mv	s10,s9
          a->right = r;
ffffffffc02074a0:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc02074a4:	01983023          	sd	s9,0(a6)
ffffffffc02074a8:	b2b9                	j	ffffffffc0206df6 <stride_dequeue+0xbe2>
          r = a->left;
ffffffffc02074aa:	008c3783          	ld	a5,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02074ae:	010c3803          	ld	a6,16(s8)
ffffffffc02074b2:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc02074b4:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc02074b6:	00081463          	bnez	a6,ffffffffc02074be <stride_dequeue+0x12aa>
ffffffffc02074ba:	75b0006f          	j	ffffffffc0208414 <stride_dequeue+0x2200>
     if (comp(a, b) == -1)
ffffffffc02074be:	8542                	mv	a0,a6
ffffffffc02074c0:	85e6                	mv	a1,s9
ffffffffc02074c2:	f442                	sd	a6,40(sp)
ffffffffc02074c4:	af9fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc02074c8:	7302                	ld	t1,32(sp)
ffffffffc02074ca:	7822                	ld	a6,40(sp)
ffffffffc02074cc:	426503e3          	beq	a0,t1,ffffffffc02080f2 <stride_dequeue+0x1ede>
          r = b->left;
ffffffffc02074d0:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02074d4:	010cb883          	ld	a7,16(s9)
ffffffffc02074d8:	fc1a                	sd	t1,56(sp)
          r = b->left;
ffffffffc02074da:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc02074dc:	04088463          	beqz	a7,ffffffffc0207524 <stride_dequeue+0x1310>
     if (comp(a, b) == -1)
ffffffffc02074e0:	85c6                	mv	a1,a7
ffffffffc02074e2:	8542                	mv	a0,a6
ffffffffc02074e4:	f846                	sd	a7,48(sp)
ffffffffc02074e6:	f442                	sd	a6,40(sp)
ffffffffc02074e8:	ad5fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc02074ec:	7362                	ld	t1,56(sp)
ffffffffc02074ee:	7822                	ld	a6,40(sp)
ffffffffc02074f0:	78c2                	ld	a7,48(sp)
ffffffffc02074f2:	00651463          	bne	a0,t1,ffffffffc02074fa <stride_dequeue+0x12e6>
ffffffffc02074f6:	0ea0106f          	j	ffffffffc02085e0 <stride_dequeue+0x23cc>
          r = b->left;
ffffffffc02074fa:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02074fe:	0108b583          	ld	a1,16(a7)
ffffffffc0207502:	8542                	mv	a0,a6
          r = b->left;
ffffffffc0207504:	f846                	sd	a7,48(sp)
ffffffffc0207506:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207508:	b0dfe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc020750c:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc020750e:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207510:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc0207514:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc0207518:	e119                	bnez	a0,ffffffffc020751e <stride_dequeue+0x130a>
ffffffffc020751a:	3ca0106f          	j	ffffffffc02088e4 <stride_dequeue+0x26d0>
ffffffffc020751e:	01153023          	sd	a7,0(a0)
ffffffffc0207522:	8846                	mv	a6,a7
          b->right = r;
ffffffffc0207524:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0207526:	010cb423          	sd	a6,8(s9)
          b->right = r;
ffffffffc020752a:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc020752e:	01983023          	sd	s9,0(a6)
ffffffffc0207532:	8866                	mv	a6,s9
          a->right = r;
ffffffffc0207534:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207536:	010c3423          	sd	a6,8(s8)
          a->right = r;
ffffffffc020753a:	00fc3823          	sd	a5,16(s8)
          if (l) l->parent = a;
ffffffffc020753e:	01883023          	sd	s8,0(a6)
ffffffffc0207542:	9d4ff06f          	j	ffffffffc0206716 <stride_dequeue+0x502>
          r = a->left;
ffffffffc0207546:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020754a:	010cb803          	ld	a6,16(s9)
ffffffffc020754e:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc0207550:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc0207552:	00081463          	bnez	a6,ffffffffc020755a <stride_dequeue+0x1346>
ffffffffc0207556:	6b30006f          	j	ffffffffc0208408 <stride_dequeue+0x21f4>
     if (comp(a, b) == -1)
ffffffffc020755a:	8542                	mv	a0,a6
ffffffffc020755c:	85ea                	mv	a1,s10
ffffffffc020755e:	f442                	sd	a6,40(sp)
ffffffffc0207560:	a5dfe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207564:	7302                	ld	t1,32(sp)
ffffffffc0207566:	7822                	ld	a6,40(sp)
ffffffffc0207568:	546508e3          	beq	a0,t1,ffffffffc02082b8 <stride_dequeue+0x20a4>
          r = b->left;
ffffffffc020756c:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207570:	010d3883          	ld	a7,16(s10)
ffffffffc0207574:	fc1a                	sd	t1,56(sp)
          r = b->left;
ffffffffc0207576:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0207578:	04088463          	beqz	a7,ffffffffc02075c0 <stride_dequeue+0x13ac>
     if (comp(a, b) == -1)
ffffffffc020757c:	85c6                	mv	a1,a7
ffffffffc020757e:	8542                	mv	a0,a6
ffffffffc0207580:	f846                	sd	a7,48(sp)
ffffffffc0207582:	f442                	sd	a6,40(sp)
ffffffffc0207584:	a39fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207588:	7362                	ld	t1,56(sp)
ffffffffc020758a:	7822                	ld	a6,40(sp)
ffffffffc020758c:	78c2                	ld	a7,48(sp)
ffffffffc020758e:	00651463          	bne	a0,t1,ffffffffc0207596 <stride_dequeue+0x1382>
ffffffffc0207592:	1e00106f          	j	ffffffffc0208772 <stride_dequeue+0x255e>
          r = b->left;
ffffffffc0207596:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020759a:	0108b583          	ld	a1,16(a7)
ffffffffc020759e:	8542                	mv	a0,a6
          r = b->left;
ffffffffc02075a0:	f846                	sd	a7,48(sp)
ffffffffc02075a2:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02075a4:	a71fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02075a8:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc02075aa:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc02075ac:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc02075b0:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc02075b4:	e119                	bnez	a0,ffffffffc02075ba <stride_dequeue+0x13a6>
ffffffffc02075b6:	3100106f          	j	ffffffffc02088c6 <stride_dequeue+0x26b2>
ffffffffc02075ba:	01153023          	sd	a7,0(a0)
ffffffffc02075be:	8846                	mv	a6,a7
          b->right = r;
ffffffffc02075c0:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc02075c2:	010d3423          	sd	a6,8(s10)
          b->right = r;
ffffffffc02075c6:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc02075ca:	01a83023          	sd	s10,0(a6)
ffffffffc02075ce:	886a                	mv	a6,s10
          a->right = r;
ffffffffc02075d0:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc02075d2:	010cb423          	sd	a6,8(s9)
          if (l) l->parent = a;
ffffffffc02075d6:	8d66                	mv	s10,s9
          a->right = r;
ffffffffc02075d8:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc02075dc:	01983023          	sd	s9,0(a6)
ffffffffc02075e0:	f52ff06f          	j	ffffffffc0206d32 <stride_dequeue+0xb1e>
          r = a->left;
ffffffffc02075e4:	0089b783          	ld	a5,8(s3)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02075e8:	0109b803          	ld	a6,16(s3)
ffffffffc02075ec:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc02075ee:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc02075f0:	620808e3          	beqz	a6,ffffffffc0208420 <stride_dequeue+0x220c>
     if (comp(a, b) == -1)
ffffffffc02075f4:	8542                	mv	a0,a6
ffffffffc02075f6:	85e6                	mv	a1,s9
ffffffffc02075f8:	f442                	sd	a6,40(sp)
ffffffffc02075fa:	9c3fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc02075fe:	7302                	ld	t1,32(sp)
ffffffffc0207600:	7822                	ld	a6,40(sp)
ffffffffc0207602:	28650de3          	beq	a0,t1,ffffffffc020809c <stride_dequeue+0x1e88>
          r = b->left;
ffffffffc0207606:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020760a:	010cb883          	ld	a7,16(s9)
ffffffffc020760e:	fc1a                	sd	t1,56(sp)
          r = b->left;
ffffffffc0207610:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0207612:	04088463          	beqz	a7,ffffffffc020765a <stride_dequeue+0x1446>
     if (comp(a, b) == -1)
ffffffffc0207616:	85c6                	mv	a1,a7
ffffffffc0207618:	8542                	mv	a0,a6
ffffffffc020761a:	f846                	sd	a7,48(sp)
ffffffffc020761c:	f442                	sd	a6,40(sp)
ffffffffc020761e:	99ffe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207622:	7362                	ld	t1,56(sp)
ffffffffc0207624:	7822                	ld	a6,40(sp)
ffffffffc0207626:	78c2                	ld	a7,48(sp)
ffffffffc0207628:	00651463          	bne	a0,t1,ffffffffc0207630 <stride_dequeue+0x141c>
ffffffffc020762c:	1cc0106f          	j	ffffffffc02087f8 <stride_dequeue+0x25e4>
          r = b->left;
ffffffffc0207630:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207634:	0108b583          	ld	a1,16(a7)
ffffffffc0207638:	8542                	mv	a0,a6
          r = b->left;
ffffffffc020763a:	f846                	sd	a7,48(sp)
ffffffffc020763c:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020763e:	9d7fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207642:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0207644:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207646:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc020764a:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc020764e:	e119                	bnez	a0,ffffffffc0207654 <stride_dequeue+0x1440>
ffffffffc0207650:	2580106f          	j	ffffffffc02088a8 <stride_dequeue+0x2694>
ffffffffc0207654:	01153023          	sd	a7,0(a0)
ffffffffc0207658:	8846                	mv	a6,a7
          b->right = r;
ffffffffc020765a:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc020765c:	010cb423          	sd	a6,8(s9)
          b->right = r;
ffffffffc0207660:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc0207664:	01983023          	sd	s9,0(a6)
ffffffffc0207668:	8866                	mv	a6,s9
          a->right = r;
ffffffffc020766a:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc020766c:	0109b423          	sd	a6,8(s3)
          if (l) l->parent = a;
ffffffffc0207670:	8cce                	mv	s9,s3
          a->right = r;
ffffffffc0207672:	00f9b823          	sd	a5,16(s3)
          if (l) l->parent = a;
ffffffffc0207676:	01383023          	sd	s3,0(a6)
ffffffffc020767a:	df0ff06f          	j	ffffffffc0206c6a <stride_dequeue+0xa56>
          r = a->left;
ffffffffc020767e:	0089b783          	ld	a5,8(s3)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207682:	0109b803          	ld	a6,16(s3)
ffffffffc0207686:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc0207688:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc020768a:	580808e3          	beqz	a6,ffffffffc020841a <stride_dequeue+0x2206>
     if (comp(a, b) == -1)
ffffffffc020768e:	8542                	mv	a0,a6
ffffffffc0207690:	85e6                	mv	a1,s9
ffffffffc0207692:	f442                	sd	a6,40(sp)
ffffffffc0207694:	929fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207698:	7302                	ld	t1,32(sp)
ffffffffc020769a:	7822                	ld	a6,40(sp)
ffffffffc020769c:	226507e3          	beq	a0,t1,ffffffffc02080ca <stride_dequeue+0x1eb6>
          r = b->left;
ffffffffc02076a0:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02076a4:	010cb883          	ld	a7,16(s9)
ffffffffc02076a8:	fc1a                	sd	t1,56(sp)
          r = b->left;
ffffffffc02076aa:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc02076ac:	04088463          	beqz	a7,ffffffffc02076f4 <stride_dequeue+0x14e0>
     if (comp(a, b) == -1)
ffffffffc02076b0:	85c6                	mv	a1,a7
ffffffffc02076b2:	8542                	mv	a0,a6
ffffffffc02076b4:	f846                	sd	a7,48(sp)
ffffffffc02076b6:	f442                	sd	a6,40(sp)
ffffffffc02076b8:	905fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc02076bc:	7362                	ld	t1,56(sp)
ffffffffc02076be:	7822                	ld	a6,40(sp)
ffffffffc02076c0:	78c2                	ld	a7,48(sp)
ffffffffc02076c2:	00651463          	bne	a0,t1,ffffffffc02076ca <stride_dequeue+0x14b6>
ffffffffc02076c6:	0d80106f          	j	ffffffffc020879e <stride_dequeue+0x258a>
          r = b->left;
ffffffffc02076ca:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02076ce:	0108b583          	ld	a1,16(a7)
ffffffffc02076d2:	8542                	mv	a0,a6
          r = b->left;
ffffffffc02076d4:	f846                	sd	a7,48(sp)
ffffffffc02076d6:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02076d8:	93dfe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02076dc:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc02076de:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc02076e0:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc02076e4:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc02076e8:	e119                	bnez	a0,ffffffffc02076ee <stride_dequeue+0x14da>
ffffffffc02076ea:	2060106f          	j	ffffffffc02088f0 <stride_dequeue+0x26dc>
ffffffffc02076ee:	01153023          	sd	a7,0(a0)
ffffffffc02076f2:	8846                	mv	a6,a7
          b->right = r;
ffffffffc02076f4:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc02076f6:	010cb423          	sd	a6,8(s9)
          b->right = r;
ffffffffc02076fa:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc02076fe:	01983023          	sd	s9,0(a6)
ffffffffc0207702:	8866                	mv	a6,s9
          a->right = r;
ffffffffc0207704:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207706:	0109b423          	sd	a6,8(s3)
          a->right = r;
ffffffffc020770a:	00f9b823          	sd	a5,16(s3)
          if (l) l->parent = a;
ffffffffc020770e:	01383023          	sd	s3,0(a6)
ffffffffc0207712:	906ff06f          	j	ffffffffc0206818 <stride_dequeue+0x604>
          r = a->left;
ffffffffc0207716:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020771a:	010cbd03          	ld	s10,16(s9)
ffffffffc020771e:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc0207720:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc0207722:	4e0d06e3          	beqz	s10,ffffffffc020840e <stride_dequeue+0x21fa>
     if (comp(a, b) == -1)
ffffffffc0207726:	85b2                	mv	a1,a2
ffffffffc0207728:	856a                	mv	a0,s10
ffffffffc020772a:	f432                	sd	a2,40(sp)
ffffffffc020772c:	891fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207730:	7302                	ld	t1,32(sp)
ffffffffc0207732:	7622                	ld	a2,40(sp)
ffffffffc0207734:	10650ce3          	beq	a0,t1,ffffffffc020804c <stride_dequeue+0x1e38>
          r = b->left;
ffffffffc0207738:	661c                	ld	a5,8(a2)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020773a:	01063883          	ld	a7,16(a2)
ffffffffc020773e:	fc1a                	sd	t1,56(sp)
          r = b->left;
ffffffffc0207740:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0207742:	04088663          	beqz	a7,ffffffffc020778e <stride_dequeue+0x157a>
     if (comp(a, b) == -1)
ffffffffc0207746:	85c6                	mv	a1,a7
ffffffffc0207748:	856a                	mv	a0,s10
ffffffffc020774a:	f832                	sd	a2,48(sp)
ffffffffc020774c:	f446                	sd	a7,40(sp)
ffffffffc020774e:	86ffe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207752:	7362                	ld	t1,56(sp)
ffffffffc0207754:	78a2                	ld	a7,40(sp)
ffffffffc0207756:	7642                	ld	a2,48(sp)
ffffffffc0207758:	00651463          	bne	a0,t1,ffffffffc0207760 <stride_dequeue+0x154c>
ffffffffc020775c:	0c80106f          	j	ffffffffc0208824 <stride_dequeue+0x2610>
          r = b->left;
ffffffffc0207760:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207764:	0108b583          	ld	a1,16(a7)
ffffffffc0207768:	856a                	mv	a0,s10
ffffffffc020776a:	fc32                	sd	a2,56(sp)
          r = b->left;
ffffffffc020776c:	f846                	sd	a7,48(sp)
ffffffffc020776e:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207770:	8a5fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207774:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0207776:	7322                	ld	t1,40(sp)
          if (l) l->parent = b;
ffffffffc0207778:	7662                	ld	a2,56(sp)
          b->left = l;
ffffffffc020777a:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc020777e:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc0207782:	e119                	bnez	a0,ffffffffc0207788 <stride_dequeue+0x1574>
ffffffffc0207784:	1c00106f          	j	ffffffffc0208944 <stride_dequeue+0x2730>
ffffffffc0207788:	01153023          	sd	a7,0(a0)
ffffffffc020778c:	8d46                	mv	s10,a7
          b->right = r;
ffffffffc020778e:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0207790:	01a63423          	sd	s10,8(a2)
          b->right = r;
ffffffffc0207794:	ea1c                	sd	a5,16(a2)
          if (l) l->parent = b;
ffffffffc0207796:	00cd3023          	sd	a2,0(s10)
ffffffffc020779a:	8d32                	mv	s10,a2
          a->right = r;
ffffffffc020779c:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc020779e:	01acb423          	sd	s10,8(s9)
          a->right = r;
ffffffffc02077a2:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc02077a6:	019d3023          	sd	s9,0(s10)
ffffffffc02077aa:	95cff06f          	j	ffffffffc0206906 <stride_dequeue+0x6f2>
          r = a->left;
ffffffffc02077ae:	0088b783          	ld	a5,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02077b2:	0108b803          	ld	a6,16(a7)
ffffffffc02077b6:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc02077b8:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc02077ba:	02080f63          	beqz	a6,ffffffffc02077f8 <stride_dequeue+0x15e4>
     if (comp(a, b) == -1)
ffffffffc02077be:	8542                	mv	a0,a6
ffffffffc02077c0:	85d2                	mv	a1,s4
ffffffffc02077c2:	fc46                	sd	a7,56(sp)
ffffffffc02077c4:	f842                	sd	a6,48(sp)
ffffffffc02077c6:	ff6fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc02077ca:	7322                	ld	t1,40(sp)
ffffffffc02077cc:	7842                	ld	a6,48(sp)
ffffffffc02077ce:	78e2                	ld	a7,56(sp)
ffffffffc02077d0:	046508e3          	beq	a0,t1,ffffffffc0208020 <stride_dequeue+0x1e0c>
          r = b->left;
ffffffffc02077d4:	008a3303          	ld	t1,8(s4)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02077d8:	010a3583          	ld	a1,16(s4)
ffffffffc02077dc:	8542                	mv	a0,a6
ffffffffc02077de:	f846                	sd	a7,48(sp)
          r = b->left;
ffffffffc02077e0:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02077e2:	833fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc02077e6:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc02077e8:	00aa3423          	sd	a0,8(s4)
          if (l) l->parent = b;
ffffffffc02077ec:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc02077ee:	006a3823          	sd	t1,16(s4)
          if (l) l->parent = b;
ffffffffc02077f2:	c119                	beqz	a0,ffffffffc02077f8 <stride_dequeue+0x15e4>
ffffffffc02077f4:	01453023          	sd	s4,0(a0)
          a->right = r;
ffffffffc02077f8:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc02077fa:	0148b423          	sd	s4,8(a7)
          a->right = r;
ffffffffc02077fe:	00f8b823          	sd	a5,16(a7)
          if (l) l->parent = a;
ffffffffc0207802:	011a3023          	sd	a7,0(s4)
ffffffffc0207806:	8a46                	mv	s4,a7
ffffffffc0207808:	e7cff06f          	j	ffffffffc0206e84 <stride_dequeue+0xc70>
          r = a->left;
ffffffffc020780c:	008a3783          	ld	a5,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207810:	010a3883          	ld	a7,16(s4)
ffffffffc0207814:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc0207816:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207818:	02088f63          	beqz	a7,ffffffffc0207856 <stride_dequeue+0x1642>
     if (comp(a, b) == -1)
ffffffffc020781c:	85c2                	mv	a1,a6
ffffffffc020781e:	8546                	mv	a0,a7
ffffffffc0207820:	fc42                	sd	a6,56(sp)
ffffffffc0207822:	f846                	sd	a7,48(sp)
ffffffffc0207824:	f98fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207828:	7322                	ld	t1,40(sp)
ffffffffc020782a:	78c2                	ld	a7,48(sp)
ffffffffc020782c:	7862                	ld	a6,56(sp)
ffffffffc020782e:	22650ce3          	beq	a0,t1,ffffffffc0208266 <stride_dequeue+0x2052>
          r = b->left;
ffffffffc0207832:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207836:	01083583          	ld	a1,16(a6)
ffffffffc020783a:	8546                	mv	a0,a7
          r = b->left;
ffffffffc020783c:	f842                	sd	a6,48(sp)
ffffffffc020783e:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207840:	fd4fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207844:	7842                	ld	a6,48(sp)
          b->right = r;
ffffffffc0207846:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207848:	00a83423          	sd	a0,8(a6)
          b->right = r;
ffffffffc020784c:	00683823          	sd	t1,16(a6)
          if (l) l->parent = b;
ffffffffc0207850:	c119                	beqz	a0,ffffffffc0207856 <stride_dequeue+0x1642>
ffffffffc0207852:	01053023          	sd	a6,0(a0)
          a->right = r;
ffffffffc0207856:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207858:	010a3423          	sd	a6,8(s4)
          a->right = r;
ffffffffc020785c:	00fa3823          	sd	a5,16(s4)
          if (l) l->parent = a;
ffffffffc0207860:	01483023          	sd	s4,0(a6)
ffffffffc0207864:	960ff06f          	j	ffffffffc02069c4 <stride_dequeue+0x7b0>
          r = a->left;
ffffffffc0207868:	008a3703          	ld	a4,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020786c:	010a3883          	ld	a7,16(s4)
ffffffffc0207870:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc0207872:	f03a                	sd	a4,32(sp)
     if (a == NULL) return b;
ffffffffc0207874:	02088c63          	beqz	a7,ffffffffc02078ac <stride_dequeue+0x1698>
     if (comp(a, b) == -1)
ffffffffc0207878:	85be                	mv	a1,a5
ffffffffc020787a:	8546                	mv	a0,a7
ffffffffc020787c:	fc3e                	sd	a5,56(sp)
ffffffffc020787e:	f846                	sd	a7,48(sp)
ffffffffc0207880:	f3cfe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207884:	7322                	ld	t1,40(sp)
ffffffffc0207886:	78c2                	ld	a7,48(sp)
ffffffffc0207888:	77e2                	ld	a5,56(sp)
ffffffffc020788a:	1a6509e3          	beq	a0,t1,ffffffffc020823c <stride_dequeue+0x2028>
          r = b->left;
ffffffffc020788e:	0087b303          	ld	t1,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207892:	6b8c                	ld	a1,16(a5)
ffffffffc0207894:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207896:	f83e                	sd	a5,48(sp)
ffffffffc0207898:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020789a:	f7afe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc020789e:	77c2                	ld	a5,48(sp)
          b->right = r;
ffffffffc02078a0:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc02078a2:	e788                	sd	a0,8(a5)
          b->right = r;
ffffffffc02078a4:	0067b823          	sd	t1,16(a5)
          if (l) l->parent = b;
ffffffffc02078a8:	c111                	beqz	a0,ffffffffc02078ac <stride_dequeue+0x1698>
ffffffffc02078aa:	e11c                	sd	a5,0(a0)
          a->right = r;
ffffffffc02078ac:	7702                	ld	a4,32(sp)
          a->left = l;
ffffffffc02078ae:	00fa3423          	sd	a5,8(s4)
          a->right = r;
ffffffffc02078b2:	00ea3823          	sd	a4,16(s4)
          if (l) l->parent = a;
ffffffffc02078b6:	0147b023          	sd	s4,0(a5)
ffffffffc02078ba:	c05fe06f          	j	ffffffffc02064be <stride_dequeue+0x2aa>
          r = a->left;
ffffffffc02078be:	008c3703          	ld	a4,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02078c2:	010c3883          	ld	a7,16(s8)
ffffffffc02078c6:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc02078c8:	f03a                	sd	a4,32(sp)
     if (a == NULL) return b;
ffffffffc02078ca:	02088c63          	beqz	a7,ffffffffc0207902 <stride_dequeue+0x16ee>
     if (comp(a, b) == -1)
ffffffffc02078ce:	85be                	mv	a1,a5
ffffffffc02078d0:	8546                	mv	a0,a7
ffffffffc02078d2:	fc3e                	sd	a5,56(sp)
ffffffffc02078d4:	f846                	sd	a7,48(sp)
ffffffffc02078d6:	ee6fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc02078da:	7322                	ld	t1,40(sp)
ffffffffc02078dc:	78c2                	ld	a7,48(sp)
ffffffffc02078de:	77e2                	ld	a5,56(sp)
ffffffffc02078e0:	126509e3          	beq	a0,t1,ffffffffc0208212 <stride_dequeue+0x1ffe>
          r = b->left;
ffffffffc02078e4:	0087b303          	ld	t1,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02078e8:	6b8c                	ld	a1,16(a5)
ffffffffc02078ea:	8546                	mv	a0,a7
          r = b->left;
ffffffffc02078ec:	f83e                	sd	a5,48(sp)
ffffffffc02078ee:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02078f0:	f24fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02078f4:	77c2                	ld	a5,48(sp)
          b->right = r;
ffffffffc02078f6:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc02078f8:	e788                	sd	a0,8(a5)
          b->right = r;
ffffffffc02078fa:	0067b823          	sd	t1,16(a5)
          if (l) l->parent = b;
ffffffffc02078fe:	c111                	beqz	a0,ffffffffc0207902 <stride_dequeue+0x16ee>
ffffffffc0207900:	e11c                	sd	a5,0(a0)
          a->right = r;
ffffffffc0207902:	7702                	ld	a4,32(sp)
          a->left = l;
ffffffffc0207904:	00fc3423          	sd	a5,8(s8)
          a->right = r;
ffffffffc0207908:	00ec3823          	sd	a4,16(s8)
          if (l) l->parent = a;
ffffffffc020790c:	0187b023          	sd	s8,0(a5)
ffffffffc0207910:	cdffe06f          	j	ffffffffc02065ee <stride_dequeue+0x3da>
          r = a->left;
ffffffffc0207914:	008a3783          	ld	a5,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207918:	010a3883          	ld	a7,16(s4)
ffffffffc020791c:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc020791e:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207920:	02088f63          	beqz	a7,ffffffffc020795e <stride_dequeue+0x174a>
     if (comp(a, b) == -1)
ffffffffc0207924:	85c2                	mv	a1,a6
ffffffffc0207926:	8546                	mv	a0,a7
ffffffffc0207928:	fc42                	sd	a6,56(sp)
ffffffffc020792a:	f846                	sd	a7,48(sp)
ffffffffc020792c:	e90fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207930:	7322                	ld	t1,40(sp)
ffffffffc0207932:	78c2                	ld	a7,48(sp)
ffffffffc0207934:	7862                	ld	a6,56(sp)
ffffffffc0207936:	006507e3          	beq	a0,t1,ffffffffc0208144 <stride_dequeue+0x1f30>
          r = b->left;
ffffffffc020793a:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020793e:	01083583          	ld	a1,16(a6)
ffffffffc0207942:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207944:	f842                	sd	a6,48(sp)
ffffffffc0207946:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207948:	eccfe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc020794c:	7842                	ld	a6,48(sp)
          b->right = r;
ffffffffc020794e:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207950:	00a83423          	sd	a0,8(a6)
          b->right = r;
ffffffffc0207954:	00683823          	sd	t1,16(a6)
          if (l) l->parent = b;
ffffffffc0207958:	c119                	beqz	a0,ffffffffc020795e <stride_dequeue+0x174a>
ffffffffc020795a:	01053023          	sd	a6,0(a0)
          a->right = r;
ffffffffc020795e:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207960:	010a3423          	sd	a6,8(s4)
          a->right = r;
ffffffffc0207964:	00fa3823          	sd	a5,16(s4)
          if (l) l->parent = a;
ffffffffc0207968:	01483023          	sd	s4,0(a6)
ffffffffc020796c:	930ff06f          	j	ffffffffc0206a9c <stride_dequeue+0x888>
          r = a->left;
ffffffffc0207970:	0084b883          	ld	a7,8(s1)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207974:	6888                	ld	a0,16(s1)
ffffffffc0207976:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0207978:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020797a:	e9afe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc020797e:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc0207980:	e488                	sd	a0,8(s1)
          if (l) l->parent = a;
ffffffffc0207982:	8326                	mv	t1,s1
          a->right = r;
ffffffffc0207984:	0114b823          	sd	a7,16(s1)
          if (l) l->parent = a;
ffffffffc0207988:	77c2                	ld	a5,48(sp)
ffffffffc020798a:	c119                	beqz	a0,ffffffffc0207990 <stride_dequeue+0x177c>
ffffffffc020798c:	9abfe06f          	j	ffffffffc0206336 <stride_dequeue+0x122>
ffffffffc0207990:	9abfe06f          	j	ffffffffc020633a <stride_dequeue+0x126>
     else if (b == NULL) return a;
ffffffffc0207994:	8326                	mv	t1,s1
ffffffffc0207996:	9a5fe06f          	j	ffffffffc020633a <stride_dequeue+0x126>
          r = a->left;
ffffffffc020799a:	008cb703          	ld	a4,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020799e:	010cb783          	ld	a5,16(s9)
ffffffffc02079a2:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc02079a4:	ec3a                	sd	a4,24(sp)
     if (a == NULL) return b;
ffffffffc02079a6:	cb95                	beqz	a5,ffffffffc02079da <stride_dequeue+0x17c6>
     if (comp(a, b) == -1)
ffffffffc02079a8:	853e                	mv	a0,a5
ffffffffc02079aa:	85ea                	mv	a1,s10
ffffffffc02079ac:	f03e                	sd	a5,32(sp)
ffffffffc02079ae:	e0efe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc02079b2:	7822                	ld	a6,40(sp)
ffffffffc02079b4:	7782                	ld	a5,32(sp)
ffffffffc02079b6:	310507e3          	beq	a0,a6,ffffffffc02084c4 <stride_dequeue+0x22b0>
          r = b->left;
ffffffffc02079ba:	008d3803          	ld	a6,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02079be:	010d3583          	ld	a1,16(s10)
ffffffffc02079c2:	853e                	mv	a0,a5
          r = b->left;
ffffffffc02079c4:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02079c6:	e4efe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc02079ca:	7802                	ld	a6,32(sp)
          b->left = l;
ffffffffc02079cc:	00ad3423          	sd	a0,8(s10)
          b->right = r;
ffffffffc02079d0:	010d3823          	sd	a6,16(s10)
          if (l) l->parent = b;
ffffffffc02079d4:	c119                	beqz	a0,ffffffffc02079da <stride_dequeue+0x17c6>
ffffffffc02079d6:	01a53023          	sd	s10,0(a0)
          a->right = r;
ffffffffc02079da:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc02079dc:	01acb423          	sd	s10,8(s9)
          a->right = r;
ffffffffc02079e0:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc02079e4:	019d3023          	sd	s9,0(s10)
ffffffffc02079e8:	8d66                	mv	s10,s9
ffffffffc02079ea:	d5eff06f          	j	ffffffffc0206f48 <stride_dequeue+0xd34>
          r = a->left;
ffffffffc02079ee:	008cb703          	ld	a4,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02079f2:	010cb783          	ld	a5,16(s9)
ffffffffc02079f6:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc02079f8:	ec3a                	sd	a4,24(sp)
     if (a == NULL) return b;
ffffffffc02079fa:	cb95                	beqz	a5,ffffffffc0207a2e <stride_dequeue+0x181a>
     if (comp(a, b) == -1)
ffffffffc02079fc:	853e                	mv	a0,a5
ffffffffc02079fe:	85ea                	mv	a1,s10
ffffffffc0207a00:	f03e                	sd	a5,32(sp)
ffffffffc0207a02:	dbafe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207a06:	7822                	ld	a6,40(sp)
ffffffffc0207a08:	7782                	ld	a5,32(sp)
ffffffffc0207a0a:	23050de3          	beq	a0,a6,ffffffffc0208444 <stride_dequeue+0x2230>
          r = b->left;
ffffffffc0207a0e:	008d3803          	ld	a6,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207a12:	010d3583          	ld	a1,16(s10)
ffffffffc0207a16:	853e                	mv	a0,a5
          r = b->left;
ffffffffc0207a18:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207a1a:	dfafe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207a1e:	7802                	ld	a6,32(sp)
          b->left = l;
ffffffffc0207a20:	00ad3423          	sd	a0,8(s10)
          b->right = r;
ffffffffc0207a24:	010d3823          	sd	a6,16(s10)
          if (l) l->parent = b;
ffffffffc0207a28:	c119                	beqz	a0,ffffffffc0207a2e <stride_dequeue+0x181a>
ffffffffc0207a2a:	01a53023          	sd	s10,0(a0)
          a->right = r;
ffffffffc0207a2e:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207a30:	01acb423          	sd	s10,8(s9)
          a->right = r;
ffffffffc0207a34:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0207a38:	019d3023          	sd	s9,0(s10)
ffffffffc0207a3c:	8d66                	mv	s10,s9
ffffffffc0207a3e:	958ff06f          	j	ffffffffc0206b96 <stride_dequeue+0x982>
          r = a->left;
ffffffffc0207a42:	008d3703          	ld	a4,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207a46:	010d3783          	ld	a5,16(s10)
ffffffffc0207a4a:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc0207a4c:	ec3a                	sd	a4,24(sp)
     if (a == NULL) return b;
ffffffffc0207a4e:	cb95                	beqz	a5,ffffffffc0207a82 <stride_dequeue+0x186e>
     if (comp(a, b) == -1)
ffffffffc0207a50:	853e                	mv	a0,a5
ffffffffc0207a52:	85ce                	mv	a1,s3
ffffffffc0207a54:	f03e                	sd	a5,32(sp)
ffffffffc0207a56:	d66fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207a5a:	7822                	ld	a6,40(sp)
ffffffffc0207a5c:	7782                	ld	a5,32(sp)
ffffffffc0207a5e:	23050de3          	beq	a0,a6,ffffffffc0208498 <stride_dequeue+0x2284>
          r = b->left;
ffffffffc0207a62:	0089b803          	ld	a6,8(s3)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207a66:	0109b583          	ld	a1,16(s3)
ffffffffc0207a6a:	853e                	mv	a0,a5
          r = b->left;
ffffffffc0207a6c:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207a6e:	da6fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207a72:	7802                	ld	a6,32(sp)
          b->left = l;
ffffffffc0207a74:	00a9b423          	sd	a0,8(s3)
          b->right = r;
ffffffffc0207a78:	0109b823          	sd	a6,16(s3)
          if (l) l->parent = b;
ffffffffc0207a7c:	c119                	beqz	a0,ffffffffc0207a82 <stride_dequeue+0x186e>
ffffffffc0207a7e:	01353023          	sd	s3,0(a0)
          a->right = r;
ffffffffc0207a82:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207a84:	013d3423          	sd	s3,8(s10)
          a->right = r;
ffffffffc0207a88:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = a;
ffffffffc0207a8c:	01a9b023          	sd	s10,0(s3)
ffffffffc0207a90:	89ea                	mv	s3,s10
ffffffffc0207a92:	d7cff06f          	j	ffffffffc020700e <stride_dequeue+0xdfa>
          r = a->left;
ffffffffc0207a96:	008cb703          	ld	a4,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207a9a:	010cb783          	ld	a5,16(s9)
ffffffffc0207a9e:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc0207aa0:	ec3a                	sd	a4,24(sp)
     if (a == NULL) return b;
ffffffffc0207aa2:	cb95                	beqz	a5,ffffffffc0207ad6 <stride_dequeue+0x18c2>
     if (comp(a, b) == -1)
ffffffffc0207aa4:	853e                	mv	a0,a5
ffffffffc0207aa6:	85ea                	mv	a1,s10
ffffffffc0207aa8:	f03e                	sd	a5,32(sp)
ffffffffc0207aaa:	d12fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207aae:	7822                	ld	a6,40(sp)
ffffffffc0207ab0:	7782                	ld	a5,32(sp)
ffffffffc0207ab2:	250505e3          	beq	a0,a6,ffffffffc02084fc <stride_dequeue+0x22e8>
          r = b->left;
ffffffffc0207ab6:	008d3803          	ld	a6,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207aba:	010d3583          	ld	a1,16(s10)
ffffffffc0207abe:	853e                	mv	a0,a5
          r = b->left;
ffffffffc0207ac0:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207ac2:	d52fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207ac6:	7802                	ld	a6,32(sp)
          b->left = l;
ffffffffc0207ac8:	00ad3423          	sd	a0,8(s10)
          b->right = r;
ffffffffc0207acc:	010d3823          	sd	a6,16(s10)
          if (l) l->parent = b;
ffffffffc0207ad0:	c119                	beqz	a0,ffffffffc0207ad6 <stride_dequeue+0x18c2>
ffffffffc0207ad2:	01a53023          	sd	s10,0(a0)
          a->right = r;
ffffffffc0207ad6:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207ad8:	01acb423          	sd	s10,8(s9)
          a->right = r;
ffffffffc0207adc:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0207ae0:	019d3023          	sd	s9,0(s10)
ffffffffc0207ae4:	8d66                	mv	s10,s9
ffffffffc0207ae6:	deeff06f          	j	ffffffffc02070d4 <stride_dequeue+0xec0>
ffffffffc0207aea:	8346                	mv	t1,a7
ffffffffc0207aec:	b8aff06f          	j	ffffffffc0206e76 <stride_dequeue+0xc62>
          r = a->left;
ffffffffc0207af0:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207af4:	010cb883          	ld	a7,16(s9)
ffffffffc0207af8:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207afa:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207afc:	02088f63          	beqz	a7,ffffffffc0207b3a <stride_dequeue+0x1926>
     if (comp(a, b) == -1)
ffffffffc0207b00:	85c2                	mv	a1,a6
ffffffffc0207b02:	8546                	mv	a0,a7
ffffffffc0207b04:	f842                	sd	a6,48(sp)
ffffffffc0207b06:	f446                	sd	a7,40(sp)
ffffffffc0207b08:	cb4fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207b0c:	7362                	ld	t1,56(sp)
ffffffffc0207b0e:	78a2                	ld	a7,40(sp)
ffffffffc0207b10:	7842                	ld	a6,48(sp)
ffffffffc0207b12:	326505e3          	beq	a0,t1,ffffffffc020863c <stride_dequeue+0x2428>
          r = b->left;
ffffffffc0207b16:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207b1a:	01083583          	ld	a1,16(a6)
ffffffffc0207b1e:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207b20:	f842                	sd	a6,48(sp)
ffffffffc0207b22:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207b24:	cf0fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207b28:	7842                	ld	a6,48(sp)
          b->right = r;
ffffffffc0207b2a:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207b2c:	00a83423          	sd	a0,8(a6)
          b->right = r;
ffffffffc0207b30:	00683823          	sd	t1,16(a6)
          if (l) l->parent = b;
ffffffffc0207b34:	c119                	beqz	a0,ffffffffc0207b3a <stride_dequeue+0x1926>
ffffffffc0207b36:	01053023          	sd	a6,0(a0)
          a->right = r;
ffffffffc0207b3a:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207b3c:	010cb423          	sd	a6,8(s9)
          a->right = r;
ffffffffc0207b40:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0207b44:	01983023          	sd	s9,0(a6)
ffffffffc0207b48:	8866                	mv	a6,s9
ffffffffc0207b4a:	a9eff06f          	j	ffffffffc0206de8 <stride_dequeue+0xbd4>
          r = a->left;
ffffffffc0207b4e:	0088b783          	ld	a5,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207b52:	0108b803          	ld	a6,16(a7)
ffffffffc0207b56:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207b58:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207b5a:	02080f63          	beqz	a6,ffffffffc0207b98 <stride_dequeue+0x1984>
     if (comp(a, b) == -1)
ffffffffc0207b5e:	8542                	mv	a0,a6
ffffffffc0207b60:	85e6                	mv	a1,s9
ffffffffc0207b62:	f846                	sd	a7,48(sp)
ffffffffc0207b64:	f442                	sd	a6,40(sp)
ffffffffc0207b66:	c56fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207b6a:	7362                	ld	t1,56(sp)
ffffffffc0207b6c:	7822                	ld	a6,40(sp)
ffffffffc0207b6e:	78c2                	ld	a7,48(sp)
ffffffffc0207b70:	44650de3          	beq	a0,t1,ffffffffc02087ca <stride_dequeue+0x25b6>
          r = b->left;
ffffffffc0207b74:	008cb303          	ld	t1,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207b78:	010cb583          	ld	a1,16(s9)
ffffffffc0207b7c:	8542                	mv	a0,a6
ffffffffc0207b7e:	f846                	sd	a7,48(sp)
          r = b->left;
ffffffffc0207b80:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207b82:	c92fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207b86:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207b88:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = b;
ffffffffc0207b8c:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0207b8e:	006cb823          	sd	t1,16(s9)
          if (l) l->parent = b;
ffffffffc0207b92:	c119                	beqz	a0,ffffffffc0207b98 <stride_dequeue+0x1984>
ffffffffc0207b94:	01953023          	sd	s9,0(a0)
          a->right = r;
ffffffffc0207b98:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207b9a:	0198b423          	sd	s9,8(a7)
          a->right = r;
ffffffffc0207b9e:	00f8b823          	sd	a5,16(a7)
          if (l) l->parent = a;
ffffffffc0207ba2:	011cb023          	sd	a7,0(s9)
ffffffffc0207ba6:	8cc6                	mv	s9,a7
ffffffffc0207ba8:	f80ff06f          	j	ffffffffc0207328 <stride_dequeue+0x1114>
          r = a->left;
ffffffffc0207bac:	0089b783          	ld	a5,8(s3)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207bb0:	0109b883          	ld	a7,16(s3)
ffffffffc0207bb4:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207bb6:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207bb8:	02088f63          	beqz	a7,ffffffffc0207bf6 <stride_dequeue+0x19e2>
     if (comp(a, b) == -1)
ffffffffc0207bbc:	85c2                	mv	a1,a6
ffffffffc0207bbe:	8546                	mv	a0,a7
ffffffffc0207bc0:	f842                	sd	a6,48(sp)
ffffffffc0207bc2:	f446                	sd	a7,40(sp)
ffffffffc0207bc4:	bf8fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207bc8:	7362                	ld	t1,56(sp)
ffffffffc0207bca:	78a2                	ld	a7,40(sp)
ffffffffc0207bcc:	7842                	ld	a6,48(sp)
ffffffffc0207bce:	486500e3          	beq	a0,t1,ffffffffc020884e <stride_dequeue+0x263a>
          r = b->left;
ffffffffc0207bd2:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207bd6:	01083583          	ld	a1,16(a6)
ffffffffc0207bda:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207bdc:	f842                	sd	a6,48(sp)
ffffffffc0207bde:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207be0:	c34fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207be4:	7842                	ld	a6,48(sp)
          b->right = r;
ffffffffc0207be6:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207be8:	00a83423          	sd	a0,8(a6)
          b->right = r;
ffffffffc0207bec:	00683823          	sd	t1,16(a6)
          if (l) l->parent = b;
ffffffffc0207bf0:	c119                	beqz	a0,ffffffffc0207bf6 <stride_dequeue+0x19e2>
ffffffffc0207bf2:	01053023          	sd	a6,0(a0)
          a->right = r;
ffffffffc0207bf6:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207bf8:	0109b423          	sd	a6,8(s3)
          a->right = r;
ffffffffc0207bfc:	00f9b823          	sd	a5,16(s3)
          if (l) l->parent = a;
ffffffffc0207c00:	01383023          	sd	s3,0(a6)
ffffffffc0207c04:	884e                	mv	a6,s3
ffffffffc0207c06:	856ff06f          	j	ffffffffc0206c5c <stride_dequeue+0xa48>
          r = a->left;
ffffffffc0207c0a:	0088b783          	ld	a5,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207c0e:	0108b803          	ld	a6,16(a7)
ffffffffc0207c12:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207c14:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207c16:	02080f63          	beqz	a6,ffffffffc0207c54 <stride_dequeue+0x1a40>
     if (comp(a, b) == -1)
ffffffffc0207c1a:	8542                	mv	a0,a6
ffffffffc0207c1c:	85e6                	mv	a1,s9
ffffffffc0207c1e:	f846                	sd	a7,48(sp)
ffffffffc0207c20:	f442                	sd	a6,40(sp)
ffffffffc0207c22:	b9afe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207c26:	7362                	ld	t1,56(sp)
ffffffffc0207c28:	7822                	ld	a6,40(sp)
ffffffffc0207c2a:	78c2                	ld	a7,48(sp)
ffffffffc0207c2c:	1e6500e3          	beq	a0,t1,ffffffffc020860c <stride_dequeue+0x23f8>
          r = b->left;
ffffffffc0207c30:	008cb303          	ld	t1,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207c34:	010cb583          	ld	a1,16(s9)
ffffffffc0207c38:	8542                	mv	a0,a6
ffffffffc0207c3a:	f846                	sd	a7,48(sp)
          r = b->left;
ffffffffc0207c3c:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207c3e:	bd6fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207c42:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207c44:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = b;
ffffffffc0207c48:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0207c4a:	006cb823          	sd	t1,16(s9)
          if (l) l->parent = b;
ffffffffc0207c4e:	c119                	beqz	a0,ffffffffc0207c54 <stride_dequeue+0x1a40>
ffffffffc0207c50:	01953023          	sd	s9,0(a0)
          a->right = r;
ffffffffc0207c54:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207c56:	0198b423          	sd	s9,8(a7)
          a->right = r;
ffffffffc0207c5a:	00f8b823          	sd	a5,16(a7)
          if (l) l->parent = a;
ffffffffc0207c5e:	011cb023          	sd	a7,0(s9)
ffffffffc0207c62:	8cc6                	mv	s9,a7
ffffffffc0207c64:	e2eff06f          	j	ffffffffc0207292 <stride_dequeue+0x107e>
          r = a->left;
ffffffffc0207c68:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207c6c:	010cb883          	ld	a7,16(s9)
ffffffffc0207c70:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207c72:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207c74:	02088f63          	beqz	a7,ffffffffc0207cb2 <stride_dequeue+0x1a9e>
     if (comp(a, b) == -1)
ffffffffc0207c78:	85c2                	mv	a1,a6
ffffffffc0207c7a:	8546                	mv	a0,a7
ffffffffc0207c7c:	f842                	sd	a6,48(sp)
ffffffffc0207c7e:	f446                	sd	a7,40(sp)
ffffffffc0207c80:	b3cfe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207c84:	7362                	ld	t1,56(sp)
ffffffffc0207c86:	78a2                	ld	a7,40(sp)
ffffffffc0207c88:	7842                	ld	a6,48(sp)
ffffffffc0207c8a:	3e6507e3          	beq	a0,t1,ffffffffc0208878 <stride_dequeue+0x2664>
          r = b->left;
ffffffffc0207c8e:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207c92:	01083583          	ld	a1,16(a6)
ffffffffc0207c96:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207c98:	f842                	sd	a6,48(sp)
ffffffffc0207c9a:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207c9c:	b78fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207ca0:	7842                	ld	a6,48(sp)
          b->right = r;
ffffffffc0207ca2:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207ca4:	00a83423          	sd	a0,8(a6)
          b->right = r;
ffffffffc0207ca8:	00683823          	sd	t1,16(a6)
          if (l) l->parent = b;
ffffffffc0207cac:	c119                	beqz	a0,ffffffffc0207cb2 <stride_dequeue+0x1a9e>
ffffffffc0207cae:	01053023          	sd	a6,0(a0)
          a->right = r;
ffffffffc0207cb2:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207cb4:	010cb423          	sd	a6,8(s9)
          a->right = r;
ffffffffc0207cb8:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0207cbc:	01983023          	sd	s9,0(a6)
ffffffffc0207cc0:	8866                	mv	a6,s9
ffffffffc0207cc2:	862ff06f          	j	ffffffffc0206d24 <stride_dequeue+0xb10>
          r = a->left;
ffffffffc0207cc6:	0089b783          	ld	a5,8(s3)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207cca:	0109b883          	ld	a7,16(s3)
ffffffffc0207cce:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207cd0:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207cd2:	02088f63          	beqz	a7,ffffffffc0207d10 <stride_dequeue+0x1afc>
     if (comp(a, b) == -1)
ffffffffc0207cd6:	85c2                	mv	a1,a6
ffffffffc0207cd8:	8546                	mv	a0,a7
ffffffffc0207cda:	f842                	sd	a6,48(sp)
ffffffffc0207cdc:	f446                	sd	a7,40(sp)
ffffffffc0207cde:	adefe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207ce2:	7362                	ld	t1,56(sp)
ffffffffc0207ce4:	78a2                	ld	a7,40(sp)
ffffffffc0207ce6:	7842                	ld	a6,48(sp)
ffffffffc0207ce8:	186500e3          	beq	a0,t1,ffffffffc0208668 <stride_dequeue+0x2454>
          r = b->left;
ffffffffc0207cec:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207cf0:	01083583          	ld	a1,16(a6)
ffffffffc0207cf4:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207cf6:	f842                	sd	a6,48(sp)
ffffffffc0207cf8:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207cfa:	b1afe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207cfe:	7842                	ld	a6,48(sp)
          b->right = r;
ffffffffc0207d00:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207d02:	00a83423          	sd	a0,8(a6)
          b->right = r;
ffffffffc0207d06:	00683823          	sd	t1,16(a6)
          if (l) l->parent = b;
ffffffffc0207d0a:	c119                	beqz	a0,ffffffffc0207d10 <stride_dequeue+0x1afc>
ffffffffc0207d0c:	01053023          	sd	a6,0(a0)
          a->right = r;
ffffffffc0207d10:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207d12:	0109b423          	sd	a6,8(s3)
          a->right = r;
ffffffffc0207d16:	00f9b823          	sd	a5,16(s3)
          if (l) l->parent = a;
ffffffffc0207d1a:	01383023          	sd	s3,0(a6)
ffffffffc0207d1e:	884e                	mv	a6,s3
ffffffffc0207d20:	ae9fe06f          	j	ffffffffc0206808 <stride_dequeue+0x5f4>
ffffffffc0207d24:	8352                	mv	t1,s4
ffffffffc0207d26:	f8afe06f          	j	ffffffffc02064b0 <stride_dequeue+0x29c>
ffffffffc0207d2a:	8362                	mv	t1,s8
ffffffffc0207d2c:	8b5fe06f          	j	ffffffffc02065e0 <stride_dequeue+0x3cc>
     else if (b == NULL) return a;
ffffffffc0207d30:	8d66                	mv	s10,s9
ffffffffc0207d32:	e65fe06f          	j	ffffffffc0206b96 <stride_dequeue+0x982>
          r = a->left;
ffffffffc0207d36:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207d3a:	010cb883          	ld	a7,16(s9)
ffffffffc0207d3e:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207d40:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207d42:	02088f63          	beqz	a7,ffffffffc0207d80 <stride_dequeue+0x1b6c>
     if (comp(a, b) == -1)
ffffffffc0207d46:	8546                	mv	a0,a7
ffffffffc0207d48:	85ea                	mv	a1,s10
ffffffffc0207d4a:	f832                	sd	a2,48(sp)
ffffffffc0207d4c:	f446                	sd	a7,40(sp)
ffffffffc0207d4e:	a6efe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207d52:	7362                	ld	t1,56(sp)
ffffffffc0207d54:	78a2                	ld	a7,40(sp)
ffffffffc0207d56:	7642                	ld	a2,48(sp)
ffffffffc0207d58:	04650ce3          	beq	a0,t1,ffffffffc02085b0 <stride_dequeue+0x239c>
          r = b->left;
ffffffffc0207d5c:	008d3303          	ld	t1,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207d60:	010d3583          	ld	a1,16(s10)
ffffffffc0207d64:	8546                	mv	a0,a7
ffffffffc0207d66:	f832                	sd	a2,48(sp)
          r = b->left;
ffffffffc0207d68:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207d6a:	aaafe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207d6e:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207d70:	00ad3423          	sd	a0,8(s10)
          if (l) l->parent = b;
ffffffffc0207d74:	7642                	ld	a2,48(sp)
          b->right = r;
ffffffffc0207d76:	006d3823          	sd	t1,16(s10)
          if (l) l->parent = b;
ffffffffc0207d7a:	c119                	beqz	a0,ffffffffc0207d80 <stride_dequeue+0x1b6c>
ffffffffc0207d7c:	01a53023          	sd	s10,0(a0)
          a->right = r;
ffffffffc0207d80:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207d82:	01acb423          	sd	s10,8(s9)
          a->right = r;
ffffffffc0207d86:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0207d8a:	019d3023          	sd	s9,0(s10)
ffffffffc0207d8e:	8d66                	mv	s10,s9
ffffffffc0207d90:	b69fe06f          	j	ffffffffc02068f8 <stride_dequeue+0x6e4>
          r = a->left;
ffffffffc0207d94:	008c3703          	ld	a4,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207d98:	010c3883          	ld	a7,16(s8)
ffffffffc0207d9c:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207d9e:	f03a                	sd	a4,32(sp)
     if (a == NULL) return b;
ffffffffc0207da0:	02088c63          	beqz	a7,ffffffffc0207dd8 <stride_dequeue+0x1bc4>
     if (comp(a, b) == -1)
ffffffffc0207da4:	85be                	mv	a1,a5
ffffffffc0207da6:	8546                	mv	a0,a7
ffffffffc0207da8:	f83e                	sd	a5,48(sp)
ffffffffc0207daa:	f446                	sd	a7,40(sp)
ffffffffc0207dac:	a10fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207db0:	7362                	ld	t1,56(sp)
ffffffffc0207db2:	78a2                	ld	a7,40(sp)
ffffffffc0207db4:	77c2                	ld	a5,48(sp)
ffffffffc0207db6:	78650f63          	beq	a0,t1,ffffffffc0208554 <stride_dequeue+0x2340>
          r = b->left;
ffffffffc0207dba:	0087b303          	ld	t1,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207dbe:	6b8c                	ld	a1,16(a5)
ffffffffc0207dc0:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207dc2:	f83e                	sd	a5,48(sp)
ffffffffc0207dc4:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207dc6:	a4efe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207dca:	77c2                	ld	a5,48(sp)
          b->right = r;
ffffffffc0207dcc:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207dce:	e788                	sd	a0,8(a5)
          b->right = r;
ffffffffc0207dd0:	0067b823          	sd	t1,16(a5)
          if (l) l->parent = b;
ffffffffc0207dd4:	c111                	beqz	a0,ffffffffc0207dd8 <stride_dequeue+0x1bc4>
ffffffffc0207dd6:	e11c                	sd	a5,0(a0)
          a->right = r;
ffffffffc0207dd8:	7702                	ld	a4,32(sp)
          a->left = l;
ffffffffc0207dda:	00fc3423          	sd	a5,8(s8)
          a->right = r;
ffffffffc0207dde:	00ec3823          	sd	a4,16(s8)
          if (l) l->parent = a;
ffffffffc0207de2:	0187b023          	sd	s8,0(a5)
ffffffffc0207de6:	87e2                	mv	a5,s8
ffffffffc0207de8:	91ffe06f          	j	ffffffffc0206706 <stride_dequeue+0x4f2>
          r = a->left;
ffffffffc0207dec:	0088b783          	ld	a5,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207df0:	0108b803          	ld	a6,16(a7)
ffffffffc0207df4:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207df6:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207df8:	02080f63          	beqz	a6,ffffffffc0207e36 <stride_dequeue+0x1c22>
     if (comp(a, b) == -1)
ffffffffc0207dfc:	8542                	mv	a0,a6
ffffffffc0207dfe:	85ce                	mv	a1,s3
ffffffffc0207e00:	f846                	sd	a7,48(sp)
ffffffffc0207e02:	f442                	sd	a6,40(sp)
ffffffffc0207e04:	9b8fe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207e08:	7362                	ld	t1,56(sp)
ffffffffc0207e0a:	7822                	ld	a6,40(sp)
ffffffffc0207e0c:	78c2                	ld	a7,48(sp)
ffffffffc0207e0e:	0e6500e3          	beq	a0,t1,ffffffffc02086ee <stride_dequeue+0x24da>
          r = b->left;
ffffffffc0207e12:	0089b303          	ld	t1,8(s3)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207e16:	0109b583          	ld	a1,16(s3)
ffffffffc0207e1a:	8542                	mv	a0,a6
ffffffffc0207e1c:	f846                	sd	a7,48(sp)
          r = b->left;
ffffffffc0207e1e:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207e20:	9f4fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207e24:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207e26:	00a9b423          	sd	a0,8(s3)
          if (l) l->parent = b;
ffffffffc0207e2a:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0207e2c:	0069b823          	sd	t1,16(s3)
          if (l) l->parent = b;
ffffffffc0207e30:	c119                	beqz	a0,ffffffffc0207e36 <stride_dequeue+0x1c22>
ffffffffc0207e32:	01353023          	sd	s3,0(a0)
          a->right = r;
ffffffffc0207e36:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207e38:	0138b423          	sd	s3,8(a7)
          a->right = r;
ffffffffc0207e3c:	00f8b823          	sd	a5,16(a7)
          if (l) l->parent = a;
ffffffffc0207e40:	0119b023          	sd	a7,0(s3)
ffffffffc0207e44:	89c6                	mv	s3,a7
ffffffffc0207e46:	b24ff06f          	j	ffffffffc020716a <stride_dequeue+0xf56>
ffffffffc0207e4a:	8352                	mv	t1,s4
ffffffffc0207e4c:	b69fe06f          	j	ffffffffc02069b4 <stride_dequeue+0x7a0>
ffffffffc0207e50:	8352                	mv	t1,s4
ffffffffc0207e52:	c3bfe06f          	j	ffffffffc0206a8c <stride_dequeue+0x878>
          r = a->left;
ffffffffc0207e56:	0088b783          	ld	a5,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207e5a:	0108b803          	ld	a6,16(a7)
ffffffffc0207e5e:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207e60:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207e62:	02080f63          	beqz	a6,ffffffffc0207ea0 <stride_dequeue+0x1c8c>
     if (comp(a, b) == -1)
ffffffffc0207e66:	8542                	mv	a0,a6
ffffffffc0207e68:	85e6                	mv	a1,s9
ffffffffc0207e6a:	f846                	sd	a7,48(sp)
ffffffffc0207e6c:	f442                	sd	a6,40(sp)
ffffffffc0207e6e:	94efe0ef          	jal	ra,ffffffffc0205fbc <proc_stride_comp_f>
ffffffffc0207e72:	7362                	ld	t1,56(sp)
ffffffffc0207e74:	7822                	ld	a6,40(sp)
ffffffffc0207e76:	78c2                	ld	a7,48(sp)
ffffffffc0207e78:	046503e3          	beq	a0,t1,ffffffffc02086be <stride_dequeue+0x24aa>
          r = b->left;
ffffffffc0207e7c:	008cb303          	ld	t1,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207e80:	010cb583          	ld	a1,16(s9)
ffffffffc0207e84:	8542                	mv	a0,a6
ffffffffc0207e86:	f846                	sd	a7,48(sp)
          r = b->left;
ffffffffc0207e88:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207e8a:	98afe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207e8e:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207e90:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = b;
ffffffffc0207e94:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0207e96:	006cb823          	sd	t1,16(s9)
          if (l) l->parent = b;
ffffffffc0207e9a:	c119                	beqz	a0,ffffffffc0207ea0 <stride_dequeue+0x1c8c>
ffffffffc0207e9c:	01953023          	sd	s9,0(a0)
          a->right = r;
ffffffffc0207ea0:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207ea2:	0198b423          	sd	s9,8(a7)
          a->right = r;
ffffffffc0207ea6:	00f8b823          	sd	a5,16(a7)
          if (l) l->parent = a;
ffffffffc0207eaa:	011cb023          	sd	a7,0(s9)
ffffffffc0207eae:	8cc6                	mv	s9,a7
ffffffffc0207eb0:	b50ff06f          	j	ffffffffc0207200 <stride_dequeue+0xfec>
          r = a->left;
ffffffffc0207eb4:	008a3883          	ld	a7,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207eb8:	010a3503          	ld	a0,16(s4)
ffffffffc0207ebc:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0207ebe:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207ec0:	954fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0207ec4:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc0207ec6:	00aa3423          	sd	a0,8(s4)
          if (l) l->parent = a;
ffffffffc0207eca:	77c2                	ld	a5,48(sp)
          a->right = r;
ffffffffc0207ecc:	011a3823          	sd	a7,16(s4)
          if (l) l->parent = a;
ffffffffc0207ed0:	e4050ae3          	beqz	a0,ffffffffc0207d24 <stride_dequeue+0x1b10>
ffffffffc0207ed4:	01453023          	sd	s4,0(a0)
ffffffffc0207ed8:	8352                	mv	t1,s4
ffffffffc0207eda:	dd6fe06f          	j	ffffffffc02064b0 <stride_dequeue+0x29c>
          r = a->left;
ffffffffc0207ede:	008c3883          	ld	a7,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207ee2:	010c3503          	ld	a0,16(s8)
ffffffffc0207ee6:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0207ee8:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207eea:	92afe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0207eee:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc0207ef0:	00ac3423          	sd	a0,8(s8)
          if (l) l->parent = a;
ffffffffc0207ef4:	77c2                	ld	a5,48(sp)
          a->right = r;
ffffffffc0207ef6:	011c3823          	sd	a7,16(s8)
          if (l) l->parent = a;
ffffffffc0207efa:	e20508e3          	beqz	a0,ffffffffc0207d2a <stride_dequeue+0x1b16>
ffffffffc0207efe:	01853023          	sd	s8,0(a0)
ffffffffc0207f02:	8362                	mv	t1,s8
ffffffffc0207f04:	edcfe06f          	j	ffffffffc02065e0 <stride_dequeue+0x3cc>
          r = a->left;
ffffffffc0207f08:	008a3883          	ld	a7,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207f0c:	010a3503          	ld	a0,16(s4)
ffffffffc0207f10:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0207f12:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207f14:	900fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0207f18:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc0207f1a:	00aa3423          	sd	a0,8(s4)
          if (l) l->parent = a;
ffffffffc0207f1e:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc0207f20:	011a3823          	sd	a7,16(s4)
          if (l) l->parent = a;
ffffffffc0207f24:	d11d                	beqz	a0,ffffffffc0207e4a <stride_dequeue+0x1c36>
ffffffffc0207f26:	01453023          	sd	s4,0(a0)
ffffffffc0207f2a:	8352                	mv	t1,s4
ffffffffc0207f2c:	a89fe06f          	j	ffffffffc02069b4 <stride_dequeue+0x7a0>
          r = a->left;
ffffffffc0207f30:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207f34:	0108b503          	ld	a0,16(a7)
ffffffffc0207f38:	85be                	mv	a1,a5
          r = a->left;
ffffffffc0207f3a:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207f3c:	8d8fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0207f40:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0207f42:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0207f44:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0207f48:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc0207f4c:	5c050b63          	beqz	a0,ffffffffc0208522 <stride_dequeue+0x230e>
ffffffffc0207f50:	01153023          	sd	a7,0(a0)
ffffffffc0207f54:	87c6                	mv	a5,a7
ffffffffc0207f56:	c28ff06f          	j	ffffffffc020737e <stride_dequeue+0x116a>
          r = a->left;
ffffffffc0207f5a:	0088b803          	ld	a6,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207f5e:	0108b503          	ld	a0,16(a7)
ffffffffc0207f62:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0207f64:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207f66:	8aefe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0207f6a:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0207f6c:	7822                	ld	a6,40(sp)
          a->left = l;
ffffffffc0207f6e:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0207f72:	0108b823          	sd	a6,16(a7)
          if (l) l->parent = a;
ffffffffc0207f76:	b6050ae3          	beqz	a0,ffffffffc0207aea <stride_dequeue+0x18d6>
ffffffffc0207f7a:	01153023          	sd	a7,0(a0)
ffffffffc0207f7e:	8346                	mv	t1,a7
ffffffffc0207f80:	ef7fe06f          	j	ffffffffc0206e76 <stride_dequeue+0xc62>
          r = a->left;
ffffffffc0207f84:	008a3883          	ld	a7,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207f88:	010a3503          	ld	a0,16(s4)
ffffffffc0207f8c:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0207f8e:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207f90:	884fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0207f94:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc0207f96:	00aa3423          	sd	a0,8(s4)
          if (l) l->parent = a;
ffffffffc0207f9a:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc0207f9c:	011a3823          	sd	a7,16(s4)
          if (l) l->parent = a;
ffffffffc0207fa0:	ea0508e3          	beqz	a0,ffffffffc0207e50 <stride_dequeue+0x1c3c>
ffffffffc0207fa4:	01453023          	sd	s4,0(a0)
ffffffffc0207fa8:	8352                	mv	t1,s4
ffffffffc0207faa:	ae3fe06f          	j	ffffffffc0206a8c <stride_dequeue+0x878>
     else if (b == NULL) return a;
ffffffffc0207fae:	87e2                	mv	a5,s8
ffffffffc0207fb0:	f56fe06f          	j	ffffffffc0206706 <stride_dequeue+0x4f2>
ffffffffc0207fb4:	884e                	mv	a6,s3
ffffffffc0207fb6:	853fe06f          	j	ffffffffc0206808 <stride_dequeue+0x5f4>
ffffffffc0207fba:	884e                	mv	a6,s3
ffffffffc0207fbc:	ca1fe06f          	j	ffffffffc0206c5c <stride_dequeue+0xa48>
ffffffffc0207fc0:	8866                	mv	a6,s9
ffffffffc0207fc2:	d63fe06f          	j	ffffffffc0206d24 <stride_dequeue+0xb10>
ffffffffc0207fc6:	8866                	mv	a6,s9
ffffffffc0207fc8:	e21fe06f          	j	ffffffffc0206de8 <stride_dequeue+0xbd4>
ffffffffc0207fcc:	8d66                	mv	s10,s9
ffffffffc0207fce:	92bfe06f          	j	ffffffffc02068f8 <stride_dequeue+0x6e4>
          r = a->left;
ffffffffc0207fd2:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207fd6:	010d3503          	ld	a0,16(s10)
ffffffffc0207fda:	85a2                	mv	a1,s0
          r = a->left;
ffffffffc0207fdc:	ec3e                	sd	a5,24(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207fde:	836fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0207fe2:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207fe4:	00ad3423          	sd	a0,8(s10)
          a->right = r;
ffffffffc0207fe8:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = a;
ffffffffc0207fec:	c0050563          	beqz	a0,ffffffffc02073f6 <stride_dequeue+0x11e2>
ffffffffc0207ff0:	01a53023          	sd	s10,0(a0)
ffffffffc0207ff4:	c02ff06f          	j	ffffffffc02073f6 <stride_dequeue+0x11e2>
          r = a->left;
ffffffffc0207ff8:	0088b803          	ld	a6,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207ffc:	0108b503          	ld	a0,16(a7)
ffffffffc0208000:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0208002:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208004:	810fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208008:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc020800a:	7822                	ld	a6,40(sp)
          a->left = l;
ffffffffc020800c:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0208010:	0108b823          	sd	a6,16(a7)
          if (l) l->parent = a;
ffffffffc0208014:	a6050863          	beqz	a0,ffffffffc0207284 <stride_dequeue+0x1070>
ffffffffc0208018:	01153023          	sd	a7,0(a0)
ffffffffc020801c:	a68ff06f          	j	ffffffffc0207284 <stride_dequeue+0x1070>
          r = a->left;
ffffffffc0208020:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208024:	01083503          	ld	a0,16(a6)
ffffffffc0208028:	85d2                	mv	a1,s4
          r = a->left;
ffffffffc020802a:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020802c:	fe9fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208030:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc0208032:	7322                	ld	t1,40(sp)
          if (l) l->parent = a;
ffffffffc0208034:	78e2                	ld	a7,56(sp)
          a->left = l;
ffffffffc0208036:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc020803a:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc020803e:	0a0500e3          	beqz	a0,ffffffffc02088de <stride_dequeue+0x26ca>
ffffffffc0208042:	01053023          	sd	a6,0(a0)
ffffffffc0208046:	8a42                	mv	s4,a6
ffffffffc0208048:	fb0ff06f          	j	ffffffffc02077f8 <stride_dequeue+0x15e4>
          r = a->left;
ffffffffc020804c:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208050:	010d3503          	ld	a0,16(s10)
ffffffffc0208054:	85b2                	mv	a1,a2
          r = a->left;
ffffffffc0208056:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208058:	fbdfd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc020805c:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc020805e:	00ad3423          	sd	a0,8(s10)
          a->right = r;
ffffffffc0208062:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = a;
ffffffffc0208066:	f2050b63          	beqz	a0,ffffffffc020779c <stride_dequeue+0x1588>
ffffffffc020806a:	01a53023          	sd	s10,0(a0)
ffffffffc020806e:	f2eff06f          	j	ffffffffc020779c <stride_dequeue+0x1588>
          r = a->left;
ffffffffc0208072:	0089b883          	ld	a7,8(s3)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208076:	0109b503          	ld	a0,16(s3)
ffffffffc020807a:	859a                	mv	a1,t1
          r = a->left;
ffffffffc020807c:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020807e:	f97fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0208082:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc0208084:	00a9b423          	sd	a0,8(s3)
          if (l) l->parent = a;
ffffffffc0208088:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc020808a:	0119b823          	sd	a7,16(s3)
          if (l) l->parent = a;
ffffffffc020808e:	e119                	bnez	a0,ffffffffc0208094 <stride_dequeue+0x1e80>
ffffffffc0208090:	f6afe06f          	j	ffffffffc02067fa <stride_dequeue+0x5e6>
ffffffffc0208094:	01353023          	sd	s3,0(a0)
ffffffffc0208098:	f62fe06f          	j	ffffffffc02067fa <stride_dequeue+0x5e6>
          r = a->left;
ffffffffc020809c:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02080a0:	01083503          	ld	a0,16(a6)
ffffffffc02080a4:	85e6                	mv	a1,s9
          r = a->left;
ffffffffc02080a6:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02080a8:	f6dfd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02080ac:	7822                	ld	a6,40(sp)
          a->right = r;
ffffffffc02080ae:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc02080b0:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc02080b4:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = a;
ffffffffc02080b8:	da050963          	beqz	a0,ffffffffc020766a <stride_dequeue+0x1456>
ffffffffc02080bc:	01053023          	sd	a6,0(a0)
ffffffffc02080c0:	daaff06f          	j	ffffffffc020766a <stride_dequeue+0x1456>
     if (a == NULL) return b;
ffffffffc02080c4:	8d22                	mv	s10,s0
ffffffffc02080c6:	b30ff06f          	j	ffffffffc02073f6 <stride_dequeue+0x11e2>
          r = a->left;
ffffffffc02080ca:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02080ce:	01083503          	ld	a0,16(a6)
ffffffffc02080d2:	85e6                	mv	a1,s9
          r = a->left;
ffffffffc02080d4:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02080d6:	f3ffd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02080da:	7822                	ld	a6,40(sp)
          a->right = r;
ffffffffc02080dc:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc02080de:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc02080e2:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = a;
ffffffffc02080e6:	e0050f63          	beqz	a0,ffffffffc0207704 <stride_dequeue+0x14f0>
ffffffffc02080ea:	01053023          	sd	a6,0(a0)
ffffffffc02080ee:	e16ff06f          	j	ffffffffc0207704 <stride_dequeue+0x14f0>
          r = a->left;
ffffffffc02080f2:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02080f6:	01083503          	ld	a0,16(a6)
ffffffffc02080fa:	85e6                	mv	a1,s9
          r = a->left;
ffffffffc02080fc:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02080fe:	f17fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208102:	7822                	ld	a6,40(sp)
          a->right = r;
ffffffffc0208104:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0208106:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc020810a:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = a;
ffffffffc020810e:	c2050363          	beqz	a0,ffffffffc0207534 <stride_dequeue+0x1320>
ffffffffc0208112:	01053023          	sd	a6,0(a0)
ffffffffc0208116:	c1eff06f          	j	ffffffffc0207534 <stride_dequeue+0x1320>
          r = a->left;
ffffffffc020811a:	008cb883          	ld	a7,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020811e:	010cb503          	ld	a0,16(s9)
ffffffffc0208122:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0208124:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208126:	eeffd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc020812a:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc020812c:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = a;
ffffffffc0208130:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc0208132:	011cb823          	sd	a7,16(s9)
          if (l) l->parent = a;
ffffffffc0208136:	e119                	bnez	a0,ffffffffc020813c <stride_dequeue+0x1f28>
ffffffffc0208138:	bdffe06f          	j	ffffffffc0206d16 <stride_dequeue+0xb02>
ffffffffc020813c:	01953023          	sd	s9,0(a0)
ffffffffc0208140:	bd7fe06f          	j	ffffffffc0206d16 <stride_dequeue+0xb02>
          r = a->left;
ffffffffc0208144:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208148:	0108b503          	ld	a0,16(a7)
ffffffffc020814c:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc020814e:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208150:	ec5fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208154:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0208156:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208158:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc020815c:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc0208160:	7c050c63          	beqz	a0,ffffffffc0208938 <stride_dequeue+0x2724>
ffffffffc0208164:	01153023          	sd	a7,0(a0)
ffffffffc0208168:	8846                	mv	a6,a7
ffffffffc020816a:	ff4ff06f          	j	ffffffffc020795e <stride_dequeue+0x174a>
          r = a->left;
ffffffffc020816e:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208172:	010cb503          	ld	a0,16(s9)
ffffffffc0208176:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc0208178:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020817a:	e9bfd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc020817e:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0208180:	00acb423          	sd	a0,8(s9)
          a->right = r;
ffffffffc0208184:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0208188:	e119                	bnez	a0,ffffffffc020818e <stride_dequeue+0x1f7a>
ffffffffc020818a:	db1fe06f          	j	ffffffffc0206f3a <stride_dequeue+0xd26>
ffffffffc020818e:	01953023          	sd	s9,0(a0)
ffffffffc0208192:	da9fe06f          	j	ffffffffc0206f3a <stride_dequeue+0xd26>
          r = a->left;
ffffffffc0208196:	008cb883          	ld	a7,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020819a:	010cb503          	ld	a0,16(s9)
ffffffffc020819e:	859a                	mv	a1,t1
          r = a->left;
ffffffffc02081a0:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02081a2:	e73fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02081a6:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc02081a8:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = a;
ffffffffc02081ac:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc02081ae:	011cb823          	sd	a7,16(s9)
          if (l) l->parent = a;
ffffffffc02081b2:	e119                	bnez	a0,ffffffffc02081b8 <stride_dequeue+0x1fa4>
ffffffffc02081b4:	c27fe06f          	j	ffffffffc0206dda <stride_dequeue+0xbc6>
ffffffffc02081b8:	01953023          	sd	s9,0(a0)
ffffffffc02081bc:	c1ffe06f          	j	ffffffffc0206dda <stride_dequeue+0xbc6>
          r = a->left;
ffffffffc02081c0:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02081c4:	010cb503          	ld	a0,16(s9)
ffffffffc02081c8:	85ba                	mv	a1,a4
          r = a->left;
ffffffffc02081ca:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02081cc:	e49fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02081d0:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc02081d2:	00acb423          	sd	a0,8(s9)
          a->right = r;
ffffffffc02081d6:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc02081da:	e119                	bnez	a0,ffffffffc02081e0 <stride_dequeue+0x1fcc>
ffffffffc02081dc:	9adfe06f          	j	ffffffffc0206b88 <stride_dequeue+0x974>
ffffffffc02081e0:	01953023          	sd	s9,0(a0)
ffffffffc02081e4:	9a5fe06f          	j	ffffffffc0206b88 <stride_dequeue+0x974>
          r = a->left;
ffffffffc02081e8:	0089b883          	ld	a7,8(s3)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02081ec:	0109b503          	ld	a0,16(s3)
ffffffffc02081f0:	859a                	mv	a1,t1
          r = a->left;
ffffffffc02081f2:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02081f4:	e21fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02081f8:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc02081fa:	00a9b423          	sd	a0,8(s3)
          if (l) l->parent = a;
ffffffffc02081fe:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc0208200:	0119b823          	sd	a7,16(s3)
          if (l) l->parent = a;
ffffffffc0208204:	e119                	bnez	a0,ffffffffc020820a <stride_dequeue+0x1ff6>
ffffffffc0208206:	a49fe06f          	j	ffffffffc0206c4e <stride_dequeue+0xa3a>
ffffffffc020820a:	01353023          	sd	s3,0(a0)
ffffffffc020820e:	a41fe06f          	j	ffffffffc0206c4e <stride_dequeue+0xa3a>
          r = a->left;
ffffffffc0208212:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208216:	0108b503          	ld	a0,16(a7)
ffffffffc020821a:	85be                	mv	a1,a5
          r = a->left;
ffffffffc020821c:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020821e:	df7fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208222:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0208224:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208226:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc020822a:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc020822e:	6e050963          	beqz	a0,ffffffffc0208920 <stride_dequeue+0x270c>
ffffffffc0208232:	01153023          	sd	a7,0(a0)
ffffffffc0208236:	87c6                	mv	a5,a7
ffffffffc0208238:	ecaff06f          	j	ffffffffc0207902 <stride_dequeue+0x16ee>
          r = a->left;
ffffffffc020823c:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208240:	0108b503          	ld	a0,16(a7)
ffffffffc0208244:	85be                	mv	a1,a5
          r = a->left;
ffffffffc0208246:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208248:	dcdfd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc020824c:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc020824e:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208250:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0208254:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc0208258:	6a050b63          	beqz	a0,ffffffffc020890e <stride_dequeue+0x26fa>
ffffffffc020825c:	01153023          	sd	a7,0(a0)
ffffffffc0208260:	87c6                	mv	a5,a7
ffffffffc0208262:	e4aff06f          	j	ffffffffc02078ac <stride_dequeue+0x1698>
          r = a->left;
ffffffffc0208266:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020826a:	0108b503          	ld	a0,16(a7)
ffffffffc020826e:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc0208270:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208272:	da3fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208276:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0208278:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc020827a:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc020827e:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc0208282:	68050963          	beqz	a0,ffffffffc0208914 <stride_dequeue+0x2700>
ffffffffc0208286:	01153023          	sd	a7,0(a0)
ffffffffc020828a:	8846                	mv	a6,a7
ffffffffc020828c:	dcaff06f          	j	ffffffffc0207856 <stride_dequeue+0x1642>
          r = a->left;
ffffffffc0208290:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208294:	010cb503          	ld	a0,16(s9)
ffffffffc0208298:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc020829a:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020829c:	d79fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02082a0:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc02082a2:	00acb423          	sd	a0,8(s9)
          a->right = r;
ffffffffc02082a6:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc02082aa:	e119                	bnez	a0,ffffffffc02082b0 <stride_dequeue+0x209c>
ffffffffc02082ac:	e1bfe06f          	j	ffffffffc02070c6 <stride_dequeue+0xeb2>
ffffffffc02082b0:	01953023          	sd	s9,0(a0)
ffffffffc02082b4:	e13fe06f          	j	ffffffffc02070c6 <stride_dequeue+0xeb2>
          r = a->left;
ffffffffc02082b8:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02082bc:	01083503          	ld	a0,16(a6)
ffffffffc02082c0:	85ea                	mv	a1,s10
          r = a->left;
ffffffffc02082c2:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02082c4:	d51fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02082c8:	7822                	ld	a6,40(sp)
          a->right = r;
ffffffffc02082ca:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc02082cc:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc02082d0:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = a;
ffffffffc02082d4:	ae050e63          	beqz	a0,ffffffffc02075d0 <stride_dequeue+0x13bc>
ffffffffc02082d8:	01053023          	sd	a6,0(a0)
ffffffffc02082dc:	af4ff06f          	j	ffffffffc02075d0 <stride_dequeue+0x13bc>
          r = a->left;
ffffffffc02082e0:	008c3883          	ld	a7,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02082e4:	010c3503          	ld	a0,16(s8)
ffffffffc02082e8:	859a                	mv	a1,t1
          r = a->left;
ffffffffc02082ea:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02082ec:	d29fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02082f0:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc02082f2:	00ac3423          	sd	a0,8(s8)
          if (l) l->parent = a;
ffffffffc02082f6:	77c2                	ld	a5,48(sp)
          a->right = r;
ffffffffc02082f8:	011c3823          	sd	a7,16(s8)
          if (l) l->parent = a;
ffffffffc02082fc:	e119                	bnez	a0,ffffffffc0208302 <stride_dequeue+0x20ee>
ffffffffc02082fe:	bfcfe06f          	j	ffffffffc02066fa <stride_dequeue+0x4e6>
ffffffffc0208302:	01853023          	sd	s8,0(a0)
ffffffffc0208306:	bf4fe06f          	j	ffffffffc02066fa <stride_dequeue+0x4e6>
          r = a->left;
ffffffffc020830a:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020830e:	01083503          	ld	a0,16(a6)
ffffffffc0208312:	85ea                	mv	a1,s10
          r = a->left;
ffffffffc0208314:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208316:	cfffd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc020831a:	7822                	ld	a6,40(sp)
          a->right = r;
ffffffffc020831c:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc020831e:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc0208322:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = a;
ffffffffc0208326:	96050963          	beqz	a0,ffffffffc0207498 <stride_dequeue+0x1284>
ffffffffc020832a:	01053023          	sd	a6,0(a0)
ffffffffc020832e:	96aff06f          	j	ffffffffc0207498 <stride_dequeue+0x1284>
          r = a->left;
ffffffffc0208332:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208336:	010d3503          	ld	a0,16(s10)
ffffffffc020833a:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc020833c:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020833e:	cd7fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0208342:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0208344:	00ad3423          	sd	a0,8(s10)
          a->right = r;
ffffffffc0208348:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = a;
ffffffffc020834c:	e119                	bnez	a0,ffffffffc0208352 <stride_dequeue+0x213e>
ffffffffc020834e:	cb3fe06f          	j	ffffffffc0207000 <stride_dequeue+0xdec>
ffffffffc0208352:	01a53023          	sd	s10,0(a0)
ffffffffc0208356:	cabfe06f          	j	ffffffffc0207000 <stride_dequeue+0xdec>
          r = a->left;
ffffffffc020835a:	0088b803          	ld	a6,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020835e:	0108b503          	ld	a0,16(a7)
ffffffffc0208362:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0208364:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208366:	caffd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc020836a:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc020836c:	7822                	ld	a6,40(sp)
          a->left = l;
ffffffffc020836e:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0208372:	0108b823          	sd	a6,16(a7)
          if (l) l->parent = a;
ffffffffc0208376:	e119                	bnez	a0,ffffffffc020837c <stride_dequeue+0x2168>
ffffffffc0208378:	de5fe06f          	j	ffffffffc020715c <stride_dequeue+0xf48>
ffffffffc020837c:	01153023          	sd	a7,0(a0)
ffffffffc0208380:	dddfe06f          	j	ffffffffc020715c <stride_dequeue+0xf48>
          r = a->left;
ffffffffc0208384:	0088b803          	ld	a6,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208388:	0108b503          	ld	a0,16(a7)
ffffffffc020838c:	859a                	mv	a1,t1
          r = a->left;
ffffffffc020838e:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208390:	c85fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208394:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0208396:	7822                	ld	a6,40(sp)
          a->left = l;
ffffffffc0208398:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc020839c:	0108b823          	sd	a6,16(a7)
          if (l) l->parent = a;
ffffffffc02083a0:	e119                	bnez	a0,ffffffffc02083a6 <stride_dequeue+0x2192>
ffffffffc02083a2:	e51fe06f          	j	ffffffffc02071f2 <stride_dequeue+0xfde>
ffffffffc02083a6:	01153023          	sd	a7,0(a0)
ffffffffc02083aa:	e49fe06f          	j	ffffffffc02071f2 <stride_dequeue+0xfde>
          r = a->left;
ffffffffc02083ae:	008cb883          	ld	a7,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02083b2:	010cb503          	ld	a0,16(s9)
ffffffffc02083b6:	859a                	mv	a1,t1
          r = a->left;
ffffffffc02083b8:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02083ba:	c5bfd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02083be:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc02083c0:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = a;
ffffffffc02083c4:	7642                	ld	a2,48(sp)
          a->right = r;
ffffffffc02083c6:	011cb823          	sd	a7,16(s9)
          if (l) l->parent = a;
ffffffffc02083ca:	e119                	bnez	a0,ffffffffc02083d0 <stride_dequeue+0x21bc>
ffffffffc02083cc:	d1efe06f          	j	ffffffffc02068ea <stride_dequeue+0x6d6>
ffffffffc02083d0:	01953023          	sd	s9,0(a0)
ffffffffc02083d4:	d16fe06f          	j	ffffffffc02068ea <stride_dequeue+0x6d6>
          r = a->left;
ffffffffc02083d8:	0088b803          	ld	a6,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02083dc:	0108b503          	ld	a0,16(a7)
ffffffffc02083e0:	859a                	mv	a1,t1
          r = a->left;
ffffffffc02083e2:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02083e4:	c31fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02083e8:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc02083ea:	7822                	ld	a6,40(sp)
          a->left = l;
ffffffffc02083ec:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc02083f0:	0108b823          	sd	a6,16(a7)
          if (l) l->parent = a;
ffffffffc02083f4:	e119                	bnez	a0,ffffffffc02083fa <stride_dequeue+0x21e6>
ffffffffc02083f6:	f25fe06f          	j	ffffffffc020731a <stride_dequeue+0x1106>
ffffffffc02083fa:	01153023          	sd	a7,0(a0)
ffffffffc02083fe:	f1dfe06f          	j	ffffffffc020731a <stride_dequeue+0x1106>
     if (a == NULL) return b;
ffffffffc0208402:	886a                	mv	a6,s10
ffffffffc0208404:	894ff06f          	j	ffffffffc0207498 <stride_dequeue+0x1284>
ffffffffc0208408:	886a                	mv	a6,s10
ffffffffc020840a:	9c6ff06f          	j	ffffffffc02075d0 <stride_dequeue+0x13bc>
ffffffffc020840e:	8d32                	mv	s10,a2
ffffffffc0208410:	b8cff06f          	j	ffffffffc020779c <stride_dequeue+0x1588>
ffffffffc0208414:	8866                	mv	a6,s9
ffffffffc0208416:	91eff06f          	j	ffffffffc0207534 <stride_dequeue+0x1320>
ffffffffc020841a:	8866                	mv	a6,s9
ffffffffc020841c:	ae8ff06f          	j	ffffffffc0207704 <stride_dequeue+0x14f0>
ffffffffc0208420:	8866                	mv	a6,s9
ffffffffc0208422:	a48ff06f          	j	ffffffffc020766a <stride_dequeue+0x1456>
          if (l) l->parent = b;
ffffffffc0208426:	889a                	mv	a7,t1
ffffffffc0208428:	d35fe06f          	j	ffffffffc020715c <stride_dequeue+0xf48>
ffffffffc020842c:	889a                	mv	a7,t1
ffffffffc020842e:	dc5fe06f          	j	ffffffffc02071f2 <stride_dequeue+0xfde>
ffffffffc0208432:	899a                	mv	s3,t1
ffffffffc0208434:	81bfe06f          	j	ffffffffc0206c4e <stride_dequeue+0xa3a>
ffffffffc0208438:	8c9a                	mv	s9,t1
ffffffffc020843a:	cb0fe06f          	j	ffffffffc02068ea <stride_dequeue+0x6d6>
ffffffffc020843e:	889a                	mv	a7,t1
ffffffffc0208440:	edbfe06f          	j	ffffffffc020731a <stride_dequeue+0x1106>
          r = a->left;
ffffffffc0208444:	0087b803          	ld	a6,8(a5)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208448:	6b88                	ld	a0,16(a5)
ffffffffc020844a:	85ea                	mv	a1,s10
          r = a->left;
ffffffffc020844c:	f43e                	sd	a5,40(sp)
ffffffffc020844e:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208450:	bc5fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208454:	77a2                	ld	a5,40(sp)
          a->right = r;
ffffffffc0208456:	7802                	ld	a6,32(sp)
          a->left = l;
ffffffffc0208458:	e788                	sd	a0,8(a5)
          a->right = r;
ffffffffc020845a:	0107b823          	sd	a6,16(a5)
          if (l) l->parent = a;
ffffffffc020845e:	4c050463          	beqz	a0,ffffffffc0208926 <stride_dequeue+0x2712>
ffffffffc0208462:	e11c                	sd	a5,0(a0)
ffffffffc0208464:	8d3e                	mv	s10,a5
ffffffffc0208466:	dc8ff06f          	j	ffffffffc0207a2e <stride_dequeue+0x181a>
          if (l) l->parent = b;
ffffffffc020846a:	8c1a                	mv	s8,t1
ffffffffc020846c:	a8efe06f          	j	ffffffffc02066fa <stride_dequeue+0x4e6>
          r = a->left;
ffffffffc0208470:	008d3803          	ld	a6,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208474:	010d3503          	ld	a0,16(s10)
ffffffffc0208478:	85b2                	mv	a1,a2
          r = a->left;
ffffffffc020847a:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020847c:	b99fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0208480:	7802                	ld	a6,32(sp)
          a->left = l;
ffffffffc0208482:	00ad3423          	sd	a0,8(s10)
          a->right = r;
ffffffffc0208486:	010d3823          	sd	a6,16(s10)
          if (l) l->parent = a;
ffffffffc020848a:	e119                	bnez	a0,ffffffffc0208490 <stride_dequeue+0x227c>
ffffffffc020848c:	f5dfe06f          	j	ffffffffc02073e8 <stride_dequeue+0x11d4>
ffffffffc0208490:	01a53023          	sd	s10,0(a0)
ffffffffc0208494:	f55fe06f          	j	ffffffffc02073e8 <stride_dequeue+0x11d4>
          r = a->left;
ffffffffc0208498:	0087b803          	ld	a6,8(a5)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020849c:	6b88                	ld	a0,16(a5)
ffffffffc020849e:	85ce                	mv	a1,s3
          r = a->left;
ffffffffc02084a0:	f43e                	sd	a5,40(sp)
ffffffffc02084a2:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02084a4:	b71fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02084a8:	77a2                	ld	a5,40(sp)
          a->right = r;
ffffffffc02084aa:	7802                	ld	a6,32(sp)
          a->left = l;
ffffffffc02084ac:	e788                	sd	a0,8(a5)
          a->right = r;
ffffffffc02084ae:	0107b823          	sd	a6,16(a5)
          if (l) l->parent = a;
ffffffffc02084b2:	3e050863          	beqz	a0,ffffffffc02088a2 <stride_dequeue+0x268e>
ffffffffc02084b6:	e11c                	sd	a5,0(a0)
ffffffffc02084b8:	89be                	mv	s3,a5
ffffffffc02084ba:	dc8ff06f          	j	ffffffffc0207a82 <stride_dequeue+0x186e>
          if (l) l->parent = b;
ffffffffc02084be:	8c9a                	mv	s9,t1
ffffffffc02084c0:	91bfe06f          	j	ffffffffc0206dda <stride_dequeue+0xbc6>
          r = a->left;
ffffffffc02084c4:	0087b803          	ld	a6,8(a5)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02084c8:	6b88                	ld	a0,16(a5)
ffffffffc02084ca:	85ea                	mv	a1,s10
          r = a->left;
ffffffffc02084cc:	f43e                	sd	a5,40(sp)
ffffffffc02084ce:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02084d0:	b45fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02084d4:	77a2                	ld	a5,40(sp)
          a->right = r;
ffffffffc02084d6:	7802                	ld	a6,32(sp)
          a->left = l;
ffffffffc02084d8:	e788                	sd	a0,8(a5)
          a->right = r;
ffffffffc02084da:	0107b823          	sd	a6,16(a5)
          if (l) l->parent = a;
ffffffffc02084de:	40050c63          	beqz	a0,ffffffffc02088f6 <stride_dequeue+0x26e2>
ffffffffc02084e2:	e11c                	sd	a5,0(a0)
ffffffffc02084e4:	8d3e                	mv	s10,a5
ffffffffc02084e6:	cf4ff06f          	j	ffffffffc02079da <stride_dequeue+0x17c6>
          if (l) l->parent = b;
ffffffffc02084ea:	899a                	mv	s3,t1
ffffffffc02084ec:	b0efe06f          	j	ffffffffc02067fa <stride_dequeue+0x5e6>
ffffffffc02084f0:	889a                	mv	a7,t1
ffffffffc02084f2:	d93fe06f          	j	ffffffffc0207284 <stride_dequeue+0x1070>
ffffffffc02084f6:	8c9a                	mv	s9,t1
ffffffffc02084f8:	81ffe06f          	j	ffffffffc0206d16 <stride_dequeue+0xb02>
          r = a->left;
ffffffffc02084fc:	0087b803          	ld	a6,8(a5)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208500:	6b88                	ld	a0,16(a5)
ffffffffc0208502:	85ea                	mv	a1,s10
          r = a->left;
ffffffffc0208504:	f43e                	sd	a5,40(sp)
ffffffffc0208506:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208508:	b0dfd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc020850c:	77a2                	ld	a5,40(sp)
          a->right = r;
ffffffffc020850e:	7802                	ld	a6,32(sp)
          a->left = l;
ffffffffc0208510:	e788                	sd	a0,8(a5)
          a->right = r;
ffffffffc0208512:	0107b823          	sd	a6,16(a5)
          if (l) l->parent = a;
ffffffffc0208516:	42050463          	beqz	a0,ffffffffc020893e <stride_dequeue+0x272a>
ffffffffc020851a:	e11c                	sd	a5,0(a0)
ffffffffc020851c:	8d3e                	mv	s10,a5
ffffffffc020851e:	db8ff06f          	j	ffffffffc0207ad6 <stride_dequeue+0x18c2>
ffffffffc0208522:	87c6                	mv	a5,a7
ffffffffc0208524:	e5bfe06f          	j	ffffffffc020737e <stride_dequeue+0x116a>
          r = a->left;
ffffffffc0208528:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020852c:	01083503          	ld	a0,16(a6)
ffffffffc0208530:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc0208532:	f842                	sd	a6,48(sp)
ffffffffc0208534:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208536:	adffd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc020853a:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc020853c:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc020853e:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc0208542:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc0208546:	e119                	bnez	a0,ffffffffc020854c <stride_dequeue+0x2338>
ffffffffc0208548:	f41fe06f          	j	ffffffffc0207488 <stride_dequeue+0x1274>
ffffffffc020854c:	01053023          	sd	a6,0(a0)
ffffffffc0208550:	f39fe06f          	j	ffffffffc0207488 <stride_dequeue+0x1274>
          r = a->left;
ffffffffc0208554:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208558:	0108b503          	ld	a0,16(a7)
ffffffffc020855c:	85be                	mv	a1,a5
          r = a->left;
ffffffffc020855e:	f846                	sd	a7,48(sp)
ffffffffc0208560:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208562:	ab3fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208566:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0208568:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc020856a:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc020856e:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc0208572:	3a050463          	beqz	a0,ffffffffc020891a <stride_dequeue+0x2706>
ffffffffc0208576:	01153023          	sd	a7,0(a0)
ffffffffc020857a:	87c6                	mv	a5,a7
ffffffffc020857c:	85dff06f          	j	ffffffffc0207dd8 <stride_dequeue+0x1bc4>
          if (l) l->parent = b;
ffffffffc0208580:	8d32                	mv	s10,a2
ffffffffc0208582:	e67fe06f          	j	ffffffffc02073e8 <stride_dequeue+0x11d4>
          r = a->left;
ffffffffc0208586:	008cb303          	ld	t1,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020858a:	010cb503          	ld	a0,16(s9)
ffffffffc020858e:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc0208590:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208592:	a83fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0208596:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208598:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = a;
ffffffffc020859c:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc020859e:	006cb823          	sd	t1,16(s9)
          if (l) l->parent = a;
ffffffffc02085a2:	e119                	bnez	a0,ffffffffc02085a8 <stride_dequeue+0x2394>
ffffffffc02085a4:	b13fe06f          	j	ffffffffc02070b6 <stride_dequeue+0xea2>
ffffffffc02085a8:	01953023          	sd	s9,0(a0)
ffffffffc02085ac:	b0bfe06f          	j	ffffffffc02070b6 <stride_dequeue+0xea2>
          r = a->left;
ffffffffc02085b0:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02085b4:	0108b503          	ld	a0,16(a7)
ffffffffc02085b8:	85ea                	mv	a1,s10
ffffffffc02085ba:	fc32                	sd	a2,56(sp)
          r = a->left;
ffffffffc02085bc:	f846                	sd	a7,48(sp)
ffffffffc02085be:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02085c0:	a55fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02085c4:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc02085c6:	7322                	ld	t1,40(sp)
          if (l) l->parent = a;
ffffffffc02085c8:	7662                	ld	a2,56(sp)
          a->left = l;
ffffffffc02085ca:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc02085ce:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc02085d2:	30050c63          	beqz	a0,ffffffffc02088ea <stride_dequeue+0x26d6>
ffffffffc02085d6:	01153023          	sd	a7,0(a0)
ffffffffc02085da:	8d46                	mv	s10,a7
ffffffffc02085dc:	fa4ff06f          	j	ffffffffc0207d80 <stride_dequeue+0x1b6c>
          r = a->left;
ffffffffc02085e0:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02085e4:	01083503          	ld	a0,16(a6)
ffffffffc02085e8:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc02085ea:	f842                	sd	a6,48(sp)
ffffffffc02085ec:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02085ee:	a27fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02085f2:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc02085f4:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc02085f6:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc02085fa:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc02085fe:	e119                	bnez	a0,ffffffffc0208604 <stride_dequeue+0x23f0>
ffffffffc0208600:	f25fe06f          	j	ffffffffc0207524 <stride_dequeue+0x1310>
ffffffffc0208604:	01053023          	sd	a6,0(a0)
ffffffffc0208608:	f1dfe06f          	j	ffffffffc0207524 <stride_dequeue+0x1310>
          r = a->left;
ffffffffc020860c:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208610:	01083503          	ld	a0,16(a6)
ffffffffc0208614:	85e6                	mv	a1,s9
ffffffffc0208616:	fc46                	sd	a7,56(sp)
          r = a->left;
ffffffffc0208618:	f842                	sd	a6,48(sp)
ffffffffc020861a:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020861c:	9f9fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208620:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc0208622:	7322                	ld	t1,40(sp)
          if (l) l->parent = a;
ffffffffc0208624:	78e2                	ld	a7,56(sp)
          a->left = l;
ffffffffc0208626:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc020862a:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc020862e:	28050f63          	beqz	a0,ffffffffc02088cc <stride_dequeue+0x26b8>
ffffffffc0208632:	01053023          	sd	a6,0(a0)
ffffffffc0208636:	8cc2                	mv	s9,a6
ffffffffc0208638:	e1cff06f          	j	ffffffffc0207c54 <stride_dequeue+0x1a40>
          r = a->left;
ffffffffc020863c:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208640:	0108b503          	ld	a0,16(a7)
ffffffffc0208644:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc0208646:	f846                	sd	a7,48(sp)
ffffffffc0208648:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020864a:	9cbfd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc020864e:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0208650:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208652:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0208656:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc020865a:	26050c63          	beqz	a0,ffffffffc02088d2 <stride_dequeue+0x26be>
ffffffffc020865e:	01153023          	sd	a7,0(a0)
ffffffffc0208662:	8846                	mv	a6,a7
ffffffffc0208664:	cd6ff06f          	j	ffffffffc0207b3a <stride_dequeue+0x1926>
          r = a->left;
ffffffffc0208668:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020866c:	0108b503          	ld	a0,16(a7)
ffffffffc0208670:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc0208672:	f846                	sd	a7,48(sp)
ffffffffc0208674:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208676:	99ffd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc020867a:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc020867c:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc020867e:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0208682:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc0208686:	26050e63          	beqz	a0,ffffffffc0208902 <stride_dequeue+0x26ee>
ffffffffc020868a:	01153023          	sd	a7,0(a0)
ffffffffc020868e:	8846                	mv	a6,a7
ffffffffc0208690:	e80ff06f          	j	ffffffffc0207d10 <stride_dequeue+0x1afc>
          r = a->left;
ffffffffc0208694:	008d3303          	ld	t1,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208698:	010d3503          	ld	a0,16(s10)
ffffffffc020869c:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc020869e:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02086a0:	975fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02086a4:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc02086a6:	00ad3423          	sd	a0,8(s10)
          if (l) l->parent = a;
ffffffffc02086aa:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc02086ac:	006d3823          	sd	t1,16(s10)
          if (l) l->parent = a;
ffffffffc02086b0:	e119                	bnez	a0,ffffffffc02086b6 <stride_dequeue+0x24a2>
ffffffffc02086b2:	93ffe06f          	j	ffffffffc0206ff0 <stride_dequeue+0xddc>
ffffffffc02086b6:	01a53023          	sd	s10,0(a0)
ffffffffc02086ba:	937fe06f          	j	ffffffffc0206ff0 <stride_dequeue+0xddc>
          r = a->left;
ffffffffc02086be:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02086c2:	01083503          	ld	a0,16(a6)
ffffffffc02086c6:	85e6                	mv	a1,s9
ffffffffc02086c8:	fc46                	sd	a7,56(sp)
          r = a->left;
ffffffffc02086ca:	f842                	sd	a6,48(sp)
ffffffffc02086cc:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02086ce:	947fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02086d2:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc02086d4:	7322                	ld	t1,40(sp)
          if (l) l->parent = a;
ffffffffc02086d6:	78e2                	ld	a7,56(sp)
          a->left = l;
ffffffffc02086d8:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc02086dc:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc02086e0:	1c050a63          	beqz	a0,ffffffffc02088b4 <stride_dequeue+0x26a0>
ffffffffc02086e4:	01053023          	sd	a6,0(a0)
ffffffffc02086e8:	8cc2                	mv	s9,a6
ffffffffc02086ea:	fb6ff06f          	j	ffffffffc0207ea0 <stride_dequeue+0x1c8c>
          r = a->left;
ffffffffc02086ee:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02086f2:	01083503          	ld	a0,16(a6)
ffffffffc02086f6:	85ce                	mv	a1,s3
ffffffffc02086f8:	fc46                	sd	a7,56(sp)
          r = a->left;
ffffffffc02086fa:	f842                	sd	a6,48(sp)
ffffffffc02086fc:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02086fe:	917fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208702:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc0208704:	7322                	ld	t1,40(sp)
          if (l) l->parent = a;
ffffffffc0208706:	78e2                	ld	a7,56(sp)
          a->left = l;
ffffffffc0208708:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc020870c:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc0208710:	22050163          	beqz	a0,ffffffffc0208932 <stride_dequeue+0x271e>
ffffffffc0208714:	01053023          	sd	a6,0(a0)
ffffffffc0208718:	89c2                	mv	s3,a6
ffffffffc020871a:	f1cff06f          	j	ffffffffc0207e36 <stride_dequeue+0x1c22>
          r = a->left;
ffffffffc020871e:	008cb303          	ld	t1,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208722:	010cb503          	ld	a0,16(s9)
ffffffffc0208726:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc0208728:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020872a:	8ebfd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc020872e:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208730:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = a;
ffffffffc0208734:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc0208736:	006cb823          	sd	t1,16(s9)
          if (l) l->parent = a;
ffffffffc020873a:	e119                	bnez	a0,ffffffffc0208740 <stride_dequeue+0x252c>
ffffffffc020873c:	feefe06f          	j	ffffffffc0206f2a <stride_dequeue+0xd16>
ffffffffc0208740:	01953023          	sd	s9,0(a0)
ffffffffc0208744:	fe6fe06f          	j	ffffffffc0206f2a <stride_dequeue+0xd16>
          r = a->left;
ffffffffc0208748:	008cb303          	ld	t1,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020874c:	010cb503          	ld	a0,16(s9)
ffffffffc0208750:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc0208752:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208754:	8c1fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0208758:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc020875a:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = a;
ffffffffc020875e:	7742                	ld	a4,48(sp)
          a->right = r;
ffffffffc0208760:	006cb823          	sd	t1,16(s9)
          if (l) l->parent = a;
ffffffffc0208764:	e119                	bnez	a0,ffffffffc020876a <stride_dequeue+0x2556>
ffffffffc0208766:	c14fe06f          	j	ffffffffc0206b7a <stride_dequeue+0x966>
ffffffffc020876a:	01953023          	sd	s9,0(a0)
ffffffffc020876e:	c0cfe06f          	j	ffffffffc0206b7a <stride_dequeue+0x966>
          r = a->left;
ffffffffc0208772:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208776:	01083503          	ld	a0,16(a6)
ffffffffc020877a:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc020877c:	f842                	sd	a6,48(sp)
ffffffffc020877e:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208780:	895fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208784:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc0208786:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208788:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc020878c:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc0208790:	e119                	bnez	a0,ffffffffc0208796 <stride_dequeue+0x2582>
ffffffffc0208792:	e2ffe06f          	j	ffffffffc02075c0 <stride_dequeue+0x13ac>
ffffffffc0208796:	01053023          	sd	a6,0(a0)
ffffffffc020879a:	e27fe06f          	j	ffffffffc02075c0 <stride_dequeue+0x13ac>
          r = a->left;
ffffffffc020879e:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02087a2:	01083503          	ld	a0,16(a6)
ffffffffc02087a6:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc02087a8:	f842                	sd	a6,48(sp)
ffffffffc02087aa:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02087ac:	869fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02087b0:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc02087b2:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc02087b4:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc02087b8:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc02087bc:	e119                	bnez	a0,ffffffffc02087c2 <stride_dequeue+0x25ae>
ffffffffc02087be:	f37fe06f          	j	ffffffffc02076f4 <stride_dequeue+0x14e0>
ffffffffc02087c2:	01053023          	sd	a6,0(a0)
ffffffffc02087c6:	f2ffe06f          	j	ffffffffc02076f4 <stride_dequeue+0x14e0>
          r = a->left;
ffffffffc02087ca:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02087ce:	01083503          	ld	a0,16(a6)
ffffffffc02087d2:	85e6                	mv	a1,s9
ffffffffc02087d4:	fc46                	sd	a7,56(sp)
          r = a->left;
ffffffffc02087d6:	f842                	sd	a6,48(sp)
ffffffffc02087d8:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02087da:	83bfd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02087de:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc02087e0:	7322                	ld	t1,40(sp)
          if (l) l->parent = a;
ffffffffc02087e2:	78e2                	ld	a7,56(sp)
          a->left = l;
ffffffffc02087e4:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc02087e8:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc02087ec:	c169                	beqz	a0,ffffffffc02088ae <stride_dequeue+0x269a>
ffffffffc02087ee:	01053023          	sd	a6,0(a0)
ffffffffc02087f2:	8cc2                	mv	s9,a6
ffffffffc02087f4:	ba4ff06f          	j	ffffffffc0207b98 <stride_dequeue+0x1984>
          r = a->left;
ffffffffc02087f8:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02087fc:	01083503          	ld	a0,16(a6)
ffffffffc0208800:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc0208802:	f842                	sd	a6,48(sp)
ffffffffc0208804:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208806:	80ffd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc020880a:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc020880c:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc020880e:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc0208812:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc0208816:	e119                	bnez	a0,ffffffffc020881c <stride_dequeue+0x2608>
ffffffffc0208818:	e43fe06f          	j	ffffffffc020765a <stride_dequeue+0x1446>
ffffffffc020881c:	01053023          	sd	a6,0(a0)
ffffffffc0208820:	e3bfe06f          	j	ffffffffc020765a <stride_dequeue+0x1446>
          r = a->left;
ffffffffc0208824:	008d3303          	ld	t1,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208828:	010d3503          	ld	a0,16(s10)
ffffffffc020882c:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc020882e:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208830:	fe4fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0208834:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208836:	00ad3423          	sd	a0,8(s10)
          if (l) l->parent = a;
ffffffffc020883a:	7642                	ld	a2,48(sp)
          a->right = r;
ffffffffc020883c:	006d3823          	sd	t1,16(s10)
          if (l) l->parent = a;
ffffffffc0208840:	e119                	bnez	a0,ffffffffc0208846 <stride_dequeue+0x2632>
ffffffffc0208842:	f4dfe06f          	j	ffffffffc020778e <stride_dequeue+0x157a>
ffffffffc0208846:	01a53023          	sd	s10,0(a0)
ffffffffc020884a:	f45fe06f          	j	ffffffffc020778e <stride_dequeue+0x157a>
          r = a->left;
ffffffffc020884e:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208852:	0108b503          	ld	a0,16(a7)
ffffffffc0208856:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc0208858:	f846                	sd	a7,48(sp)
ffffffffc020885a:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020885c:	fb8fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208860:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0208862:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208864:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0208868:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc020886c:	cd79                	beqz	a0,ffffffffc020894a <stride_dequeue+0x2736>
ffffffffc020886e:	01153023          	sd	a7,0(a0)
ffffffffc0208872:	8846                	mv	a6,a7
ffffffffc0208874:	b82ff06f          	j	ffffffffc0207bf6 <stride_dequeue+0x19e2>
          r = a->left;
ffffffffc0208878:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020887c:	0108b503          	ld	a0,16(a7)
ffffffffc0208880:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc0208882:	f846                	sd	a7,48(sp)
ffffffffc0208884:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208886:	f8efd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc020888a:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc020888c:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc020888e:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0208892:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc0208896:	c115                	beqz	a0,ffffffffc02088ba <stride_dequeue+0x26a6>
ffffffffc0208898:	01153023          	sd	a7,0(a0)
ffffffffc020889c:	8846                	mv	a6,a7
ffffffffc020889e:	c14ff06f          	j	ffffffffc0207cb2 <stride_dequeue+0x1a9e>
ffffffffc02088a2:	89be                	mv	s3,a5
ffffffffc02088a4:	9deff06f          	j	ffffffffc0207a82 <stride_dequeue+0x186e>
          if (l) l->parent = b;
ffffffffc02088a8:	8846                	mv	a6,a7
ffffffffc02088aa:	db1fe06f          	j	ffffffffc020765a <stride_dequeue+0x1446>
          if (l) l->parent = a;
ffffffffc02088ae:	8cc2                	mv	s9,a6
ffffffffc02088b0:	ae8ff06f          	j	ffffffffc0207b98 <stride_dequeue+0x1984>
ffffffffc02088b4:	8cc2                	mv	s9,a6
ffffffffc02088b6:	deaff06f          	j	ffffffffc0207ea0 <stride_dequeue+0x1c8c>
ffffffffc02088ba:	8846                	mv	a6,a7
ffffffffc02088bc:	bf6ff06f          	j	ffffffffc0207cb2 <stride_dequeue+0x1a9e>
          if (l) l->parent = b;
ffffffffc02088c0:	8cc6                	mv	s9,a7
ffffffffc02088c2:	ab8fe06f          	j	ffffffffc0206b7a <stride_dequeue+0x966>
ffffffffc02088c6:	8846                	mv	a6,a7
ffffffffc02088c8:	cf9fe06f          	j	ffffffffc02075c0 <stride_dequeue+0x13ac>
          if (l) l->parent = a;
ffffffffc02088cc:	8cc2                	mv	s9,a6
ffffffffc02088ce:	b86ff06f          	j	ffffffffc0207c54 <stride_dequeue+0x1a40>
ffffffffc02088d2:	8846                	mv	a6,a7
ffffffffc02088d4:	a66ff06f          	j	ffffffffc0207b3a <stride_dequeue+0x1926>
          if (l) l->parent = b;
ffffffffc02088d8:	8cc6                	mv	s9,a7
ffffffffc02088da:	fdcfe06f          	j	ffffffffc02070b6 <stride_dequeue+0xea2>
          if (l) l->parent = a;
ffffffffc02088de:	8a42                	mv	s4,a6
ffffffffc02088e0:	f19fe06f          	j	ffffffffc02077f8 <stride_dequeue+0x15e4>
          if (l) l->parent = b;
ffffffffc02088e4:	8846                	mv	a6,a7
ffffffffc02088e6:	c3ffe06f          	j	ffffffffc0207524 <stride_dequeue+0x1310>
          if (l) l->parent = a;
ffffffffc02088ea:	8d46                	mv	s10,a7
ffffffffc02088ec:	c94ff06f          	j	ffffffffc0207d80 <stride_dequeue+0x1b6c>
          if (l) l->parent = b;
ffffffffc02088f0:	8846                	mv	a6,a7
ffffffffc02088f2:	e03fe06f          	j	ffffffffc02076f4 <stride_dequeue+0x14e0>
          if (l) l->parent = a;
ffffffffc02088f6:	8d3e                	mv	s10,a5
ffffffffc02088f8:	8e2ff06f          	j	ffffffffc02079da <stride_dequeue+0x17c6>
          if (l) l->parent = b;
ffffffffc02088fc:	8d46                	mv	s10,a7
ffffffffc02088fe:	ef2fe06f          	j	ffffffffc0206ff0 <stride_dequeue+0xddc>
          if (l) l->parent = a;
ffffffffc0208902:	8846                	mv	a6,a7
ffffffffc0208904:	c0cff06f          	j	ffffffffc0207d10 <stride_dequeue+0x1afc>
          if (l) l->parent = b;
ffffffffc0208908:	8846                	mv	a6,a7
ffffffffc020890a:	b7ffe06f          	j	ffffffffc0207488 <stride_dequeue+0x1274>
          if (l) l->parent = a;
ffffffffc020890e:	87c6                	mv	a5,a7
ffffffffc0208910:	f9dfe06f          	j	ffffffffc02078ac <stride_dequeue+0x1698>
ffffffffc0208914:	8846                	mv	a6,a7
ffffffffc0208916:	f41fe06f          	j	ffffffffc0207856 <stride_dequeue+0x1642>
ffffffffc020891a:	87c6                	mv	a5,a7
ffffffffc020891c:	cbcff06f          	j	ffffffffc0207dd8 <stride_dequeue+0x1bc4>
ffffffffc0208920:	87c6                	mv	a5,a7
ffffffffc0208922:	fe1fe06f          	j	ffffffffc0207902 <stride_dequeue+0x16ee>
ffffffffc0208926:	8d3e                	mv	s10,a5
ffffffffc0208928:	906ff06f          	j	ffffffffc0207a2e <stride_dequeue+0x181a>
          if (l) l->parent = b;
ffffffffc020892c:	8cc6                	mv	s9,a7
ffffffffc020892e:	dfcfe06f          	j	ffffffffc0206f2a <stride_dequeue+0xd16>
          if (l) l->parent = a;
ffffffffc0208932:	89c2                	mv	s3,a6
ffffffffc0208934:	d02ff06f          	j	ffffffffc0207e36 <stride_dequeue+0x1c22>
ffffffffc0208938:	8846                	mv	a6,a7
ffffffffc020893a:	824ff06f          	j	ffffffffc020795e <stride_dequeue+0x174a>
ffffffffc020893e:	8d3e                	mv	s10,a5
ffffffffc0208940:	996ff06f          	j	ffffffffc0207ad6 <stride_dequeue+0x18c2>
          if (l) l->parent = b;
ffffffffc0208944:	8d46                	mv	s10,a7
ffffffffc0208946:	e49fe06f          	j	ffffffffc020778e <stride_dequeue+0x157a>
          if (l) l->parent = a;
ffffffffc020894a:	8846                	mv	a6,a7
ffffffffc020894c:	aaaff06f          	j	ffffffffc0207bf6 <stride_dequeue+0x19e2>

ffffffffc0208950 <sched_class_proc_tick>:
    return sched_class->pick_next(rq);
}

void
sched_class_proc_tick(struct proc_struct *proc) {
    if (proc != idleproc) {
ffffffffc0208950:	000c1797          	auipc	a5,0xc1
ffffffffc0208954:	9d878793          	addi	a5,a5,-1576 # ffffffffc02c9328 <idleproc>
ffffffffc0208958:	639c                	ld	a5,0(a5)
sched_class_proc_tick(struct proc_struct *proc) {
ffffffffc020895a:	85aa                	mv	a1,a0
    if (proc != idleproc) {
ffffffffc020895c:	00a78f63          	beq	a5,a0,ffffffffc020897a <sched_class_proc_tick+0x2a>
        sched_class->proc_tick(rq, proc);
ffffffffc0208960:	000c1797          	auipc	a5,0xc1
ffffffffc0208964:	9e878793          	addi	a5,a5,-1560 # ffffffffc02c9348 <sched_class>
ffffffffc0208968:	639c                	ld	a5,0(a5)
ffffffffc020896a:	000c1717          	auipc	a4,0xc1
ffffffffc020896e:	9d670713          	addi	a4,a4,-1578 # ffffffffc02c9340 <rq>
ffffffffc0208972:	6308                	ld	a0,0(a4)
ffffffffc0208974:	0287b303          	ld	t1,40(a5)
ffffffffc0208978:	8302                	jr	t1
    }
    else {
        proc->need_resched = 1;
ffffffffc020897a:	4705                	li	a4,1
ffffffffc020897c:	ef98                	sd	a4,24(a5)
    }
}
ffffffffc020897e:	8082                	ret

ffffffffc0208980 <sched_init>:

static struct run_queue __rq;

void
sched_init(void) {
ffffffffc0208980:	1141                	addi	sp,sp,-16
    list_init(&timer_list);

    sched_class = &stride_sched_class;
ffffffffc0208982:	000b5697          	auipc	a3,0xb5
ffffffffc0208986:	4fe68693          	addi	a3,a3,1278 # ffffffffc02bde80 <stride_sched_class>
sched_init(void) {
ffffffffc020898a:	e022                	sd	s0,0(sp)
ffffffffc020898c:	e406                	sd	ra,8(sp)
ffffffffc020898e:	000c1797          	auipc	a5,0xc1
ffffffffc0208992:	95278793          	addi	a5,a5,-1710 # ffffffffc02c92e0 <timer_list>

    rq = &__rq;
    rq->max_time_slice = MAX_TIME_SLICE;
    sched_class->init(rq);
ffffffffc0208996:	6690                	ld	a2,8(a3)
    rq = &__rq;
ffffffffc0208998:	000c1717          	auipc	a4,0xc1
ffffffffc020899c:	92870713          	addi	a4,a4,-1752 # ffffffffc02c92c0 <__rq>
ffffffffc02089a0:	e79c                	sd	a5,8(a5)
ffffffffc02089a2:	e39c                	sd	a5,0(a5)
    rq->max_time_slice = MAX_TIME_SLICE;
ffffffffc02089a4:	4795                	li	a5,5
    sched_class = &stride_sched_class;
ffffffffc02089a6:	000c1417          	auipc	s0,0xc1
ffffffffc02089aa:	9a240413          	addi	s0,s0,-1630 # ffffffffc02c9348 <sched_class>
    rq->max_time_slice = MAX_TIME_SLICE;
ffffffffc02089ae:	cb5c                	sw	a5,20(a4)
    sched_class->init(rq);
ffffffffc02089b0:	853a                	mv	a0,a4
    sched_class = &stride_sched_class;
ffffffffc02089b2:	e014                	sd	a3,0(s0)
    rq = &__rq;
ffffffffc02089b4:	000c1797          	auipc	a5,0xc1
ffffffffc02089b8:	98e7b623          	sd	a4,-1652(a5) # ffffffffc02c9340 <rq>
    sched_class->init(rq);
ffffffffc02089bc:	9602                	jalr	a2

    cprintf("sched class: %s\n", sched_class->name);
ffffffffc02089be:	601c                	ld	a5,0(s0)
}
ffffffffc02089c0:	6402                	ld	s0,0(sp)
ffffffffc02089c2:	60a2                	ld	ra,8(sp)
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc02089c4:	638c                	ld	a1,0(a5)
ffffffffc02089c6:	00003517          	auipc	a0,0x3
ffffffffc02089ca:	9ea50513          	addi	a0,a0,-1558 # ffffffffc020b3b0 <default_pmm_manager+0x1540>
}
ffffffffc02089ce:	0141                	addi	sp,sp,16
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc02089d0:	fc2f706f          	j	ffffffffc0200192 <cprintf>

ffffffffc02089d4 <wakeup_proc>:

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02089d4:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc02089d6:	1101                	addi	sp,sp,-32
ffffffffc02089d8:	ec06                	sd	ra,24(sp)
ffffffffc02089da:	e822                	sd	s0,16(sp)
ffffffffc02089dc:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02089de:	478d                	li	a5,3
ffffffffc02089e0:	08f70763          	beq	a4,a5,ffffffffc0208a6e <wakeup_proc+0x9a>
ffffffffc02089e4:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02089e6:	100027f3          	csrr	a5,sstatus
ffffffffc02089ea:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02089ec:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02089ee:	ebbd                	bnez	a5,ffffffffc0208a64 <wakeup_proc+0x90>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc02089f0:	4789                	li	a5,2
ffffffffc02089f2:	04f70c63          	beq	a4,a5,ffffffffc0208a4a <wakeup_proc+0x76>
            proc->state = PROC_RUNNABLE;
            proc->wait_state = 0;
            if (proc != current) {
ffffffffc02089f6:	000c1717          	auipc	a4,0xc1
ffffffffc02089fa:	92a70713          	addi	a4,a4,-1750 # ffffffffc02c9320 <current>
ffffffffc02089fe:	6318                	ld	a4,0(a4)
            proc->wait_state = 0;
ffffffffc0208a00:	0e042623          	sw	zero,236(s0)
            proc->state = PROC_RUNNABLE;
ffffffffc0208a04:	c01c                	sw	a5,0(s0)
            if (proc != current) {
ffffffffc0208a06:	02870663          	beq	a4,s0,ffffffffc0208a32 <wakeup_proc+0x5e>
    if (proc != idleproc) {
ffffffffc0208a0a:	000c1797          	auipc	a5,0xc1
ffffffffc0208a0e:	91e78793          	addi	a5,a5,-1762 # ffffffffc02c9328 <idleproc>
ffffffffc0208a12:	639c                	ld	a5,0(a5)
ffffffffc0208a14:	00f40f63          	beq	s0,a5,ffffffffc0208a32 <wakeup_proc+0x5e>
        sched_class->enqueue(rq, proc);
ffffffffc0208a18:	000c1797          	auipc	a5,0xc1
ffffffffc0208a1c:	93078793          	addi	a5,a5,-1744 # ffffffffc02c9348 <sched_class>
ffffffffc0208a20:	639c                	ld	a5,0(a5)
ffffffffc0208a22:	000c1717          	auipc	a4,0xc1
ffffffffc0208a26:	91e70713          	addi	a4,a4,-1762 # ffffffffc02c9340 <rq>
ffffffffc0208a2a:	6308                	ld	a0,0(a4)
ffffffffc0208a2c:	6b9c                	ld	a5,16(a5)
ffffffffc0208a2e:	85a2                	mv	a1,s0
ffffffffc0208a30:	9782                	jalr	a5
    if (flag) {
ffffffffc0208a32:	e491                	bnez	s1,ffffffffc0208a3e <wakeup_proc+0x6a>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0208a34:	60e2                	ld	ra,24(sp)
ffffffffc0208a36:	6442                	ld	s0,16(sp)
ffffffffc0208a38:	64a2                	ld	s1,8(sp)
ffffffffc0208a3a:	6105                	addi	sp,sp,32
ffffffffc0208a3c:	8082                	ret
ffffffffc0208a3e:	6442                	ld	s0,16(sp)
ffffffffc0208a40:	60e2                	ld	ra,24(sp)
ffffffffc0208a42:	64a2                	ld	s1,8(sp)
ffffffffc0208a44:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0208a46:	c07f706f          	j	ffffffffc020064c <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0208a4a:	00003617          	auipc	a2,0x3
ffffffffc0208a4e:	9b660613          	addi	a2,a2,-1610 # ffffffffc020b400 <default_pmm_manager+0x1590>
ffffffffc0208a52:	04800593          	li	a1,72
ffffffffc0208a56:	00003517          	auipc	a0,0x3
ffffffffc0208a5a:	99250513          	addi	a0,a0,-1646 # ffffffffc020b3e8 <default_pmm_manager+0x1578>
ffffffffc0208a5e:	a97f70ef          	jal	ra,ffffffffc02004f4 <__warn>
ffffffffc0208a62:	bfc1                	j	ffffffffc0208a32 <wakeup_proc+0x5e>
        intr_disable();
ffffffffc0208a64:	beff70ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0208a68:	4018                	lw	a4,0(s0)
ffffffffc0208a6a:	4485                	li	s1,1
ffffffffc0208a6c:	b751                	j	ffffffffc02089f0 <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0208a6e:	00003697          	auipc	a3,0x3
ffffffffc0208a72:	95a68693          	addi	a3,a3,-1702 # ffffffffc020b3c8 <default_pmm_manager+0x1558>
ffffffffc0208a76:	00001617          	auipc	a2,0x1
ffffffffc0208a7a:	cb260613          	addi	a2,a2,-846 # ffffffffc0209728 <commands+0x4c0>
ffffffffc0208a7e:	03c00593          	li	a1,60
ffffffffc0208a82:	00003517          	auipc	a0,0x3
ffffffffc0208a86:	96650513          	addi	a0,a0,-1690 # ffffffffc020b3e8 <default_pmm_manager+0x1578>
ffffffffc0208a8a:	9fff70ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0208a8e <schedule>:

void
schedule(void) {
ffffffffc0208a8e:	7179                	addi	sp,sp,-48
ffffffffc0208a90:	f406                	sd	ra,40(sp)
ffffffffc0208a92:	f022                	sd	s0,32(sp)
ffffffffc0208a94:	ec26                	sd	s1,24(sp)
ffffffffc0208a96:	e84a                	sd	s2,16(sp)
ffffffffc0208a98:	e44e                	sd	s3,8(sp)
ffffffffc0208a9a:	e052                	sd	s4,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0208a9c:	100027f3          	csrr	a5,sstatus
ffffffffc0208aa0:	8b89                	andi	a5,a5,2
ffffffffc0208aa2:	4a01                	li	s4,0
ffffffffc0208aa4:	e7d5                	bnez	a5,ffffffffc0208b50 <schedule+0xc2>
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0208aa6:	000c1497          	auipc	s1,0xc1
ffffffffc0208aaa:	87a48493          	addi	s1,s1,-1926 # ffffffffc02c9320 <current>
ffffffffc0208aae:	608c                	ld	a1,0(s1)
ffffffffc0208ab0:	000c1997          	auipc	s3,0xc1
ffffffffc0208ab4:	89898993          	addi	s3,s3,-1896 # ffffffffc02c9348 <sched_class>
ffffffffc0208ab8:	000c1917          	auipc	s2,0xc1
ffffffffc0208abc:	88890913          	addi	s2,s2,-1912 # ffffffffc02c9340 <rq>
        if (current->state == PROC_RUNNABLE) {
ffffffffc0208ac0:	4194                	lw	a3,0(a1)
        current->need_resched = 0;
ffffffffc0208ac2:	0005bc23          	sd	zero,24(a1)
        if (current->state == PROC_RUNNABLE) {
ffffffffc0208ac6:	4709                	li	a4,2
ffffffffc0208ac8:	0009b783          	ld	a5,0(s3)
ffffffffc0208acc:	00093503          	ld	a0,0(s2)
ffffffffc0208ad0:	04e68063          	beq	a3,a4,ffffffffc0208b10 <schedule+0x82>
    return sched_class->pick_next(rq);
ffffffffc0208ad4:	739c                	ld	a5,32(a5)
ffffffffc0208ad6:	9782                	jalr	a5
ffffffffc0208ad8:	842a                	mv	s0,a0
            sched_class_enqueue(current);
        }
        if ((next = sched_class_pick_next()) != NULL) {
ffffffffc0208ada:	cd21                	beqz	a0,ffffffffc0208b32 <schedule+0xa4>
    sched_class->dequeue(rq, proc);
ffffffffc0208adc:	0009b783          	ld	a5,0(s3)
ffffffffc0208ae0:	00093503          	ld	a0,0(s2)
ffffffffc0208ae4:	85a2                	mv	a1,s0
ffffffffc0208ae6:	6f9c                	ld	a5,24(a5)
ffffffffc0208ae8:	9782                	jalr	a5
            sched_class_dequeue(next);
        }
        if (next == NULL) {
            next = idleproc;
        }
        next->runs ++;
ffffffffc0208aea:	441c                	lw	a5,8(s0)
        if (next != current) {
ffffffffc0208aec:	6098                	ld	a4,0(s1)
        next->runs ++;
ffffffffc0208aee:	2785                	addiw	a5,a5,1
ffffffffc0208af0:	c41c                	sw	a5,8(s0)
        if (next != current) {
ffffffffc0208af2:	00870563          	beq	a4,s0,ffffffffc0208afc <schedule+0x6e>
            proc_run(next);
ffffffffc0208af6:	8522                	mv	a0,s0
ffffffffc0208af8:	c0efc0ef          	jal	ra,ffffffffc0204f06 <proc_run>
    if (flag) {
ffffffffc0208afc:	040a1163          	bnez	s4,ffffffffc0208b3e <schedule+0xb0>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0208b00:	70a2                	ld	ra,40(sp)
ffffffffc0208b02:	7402                	ld	s0,32(sp)
ffffffffc0208b04:	64e2                	ld	s1,24(sp)
ffffffffc0208b06:	6942                	ld	s2,16(sp)
ffffffffc0208b08:	69a2                	ld	s3,8(sp)
ffffffffc0208b0a:	6a02                	ld	s4,0(sp)
ffffffffc0208b0c:	6145                	addi	sp,sp,48
ffffffffc0208b0e:	8082                	ret
    if (proc != idleproc) {
ffffffffc0208b10:	000c1717          	auipc	a4,0xc1
ffffffffc0208b14:	81870713          	addi	a4,a4,-2024 # ffffffffc02c9328 <idleproc>
ffffffffc0208b18:	6318                	ld	a4,0(a4)
ffffffffc0208b1a:	fae58de3          	beq	a1,a4,ffffffffc0208ad4 <schedule+0x46>
        sched_class->enqueue(rq, proc);
ffffffffc0208b1e:	6b9c                	ld	a5,16(a5)
ffffffffc0208b20:	9782                	jalr	a5
ffffffffc0208b22:	0009b783          	ld	a5,0(s3)
ffffffffc0208b26:	00093503          	ld	a0,0(s2)
    return sched_class->pick_next(rq);
ffffffffc0208b2a:	739c                	ld	a5,32(a5)
ffffffffc0208b2c:	9782                	jalr	a5
ffffffffc0208b2e:	842a                	mv	s0,a0
        if ((next = sched_class_pick_next()) != NULL) {
ffffffffc0208b30:	f555                	bnez	a0,ffffffffc0208adc <schedule+0x4e>
            next = idleproc;
ffffffffc0208b32:	000c0797          	auipc	a5,0xc0
ffffffffc0208b36:	7f678793          	addi	a5,a5,2038 # ffffffffc02c9328 <idleproc>
ffffffffc0208b3a:	6380                	ld	s0,0(a5)
ffffffffc0208b3c:	b77d                	j	ffffffffc0208aea <schedule+0x5c>
}
ffffffffc0208b3e:	7402                	ld	s0,32(sp)
ffffffffc0208b40:	70a2                	ld	ra,40(sp)
ffffffffc0208b42:	64e2                	ld	s1,24(sp)
ffffffffc0208b44:	6942                	ld	s2,16(sp)
ffffffffc0208b46:	69a2                	ld	s3,8(sp)
ffffffffc0208b48:	6a02                	ld	s4,0(sp)
ffffffffc0208b4a:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0208b4c:	b01f706f          	j	ffffffffc020064c <intr_enable>
        intr_disable();
ffffffffc0208b50:	b03f70ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0208b54:	4a05                	li	s4,1
ffffffffc0208b56:	bf81                	j	ffffffffc0208aa6 <schedule+0x18>

ffffffffc0208b58 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0208b58:	000c0797          	auipc	a5,0xc0
ffffffffc0208b5c:	7c878793          	addi	a5,a5,1992 # ffffffffc02c9320 <current>
ffffffffc0208b60:	639c                	ld	a5,0(a5)
}
ffffffffc0208b62:	43c8                	lw	a0,4(a5)
ffffffffc0208b64:	8082                	ret

ffffffffc0208b66 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0208b66:	4501                	li	a0,0
ffffffffc0208b68:	8082                	ret

ffffffffc0208b6a <sys_gettime>:
static int sys_gettime(uint64_t arg[]){
    return (int)ticks*10;
ffffffffc0208b6a:	000c0797          	auipc	a5,0xc0
ffffffffc0208b6e:	7e678793          	addi	a5,a5,2022 # ffffffffc02c9350 <ticks>
ffffffffc0208b72:	639c                	ld	a5,0(a5)
ffffffffc0208b74:	0027951b          	slliw	a0,a5,0x2
ffffffffc0208b78:	9d3d                	addw	a0,a0,a5
}
ffffffffc0208b7a:	0015151b          	slliw	a0,a0,0x1
ffffffffc0208b7e:	8082                	ret

ffffffffc0208b80 <sys_lab6_set_priority>:
static int sys_lab6_set_priority(uint64_t arg[]){
    uint64_t priority = (uint64_t)arg[0];
    lab6_set_priority(priority);
ffffffffc0208b80:	4108                	lw	a0,0(a0)
static int sys_lab6_set_priority(uint64_t arg[]){
ffffffffc0208b82:	1141                	addi	sp,sp,-16
ffffffffc0208b84:	e406                	sd	ra,8(sp)
    lab6_set_priority(priority);
ffffffffc0208b86:	b90fd0ef          	jal	ra,ffffffffc0205f16 <lab6_set_priority>
    return 0;
}
ffffffffc0208b8a:	60a2                	ld	ra,8(sp)
ffffffffc0208b8c:	4501                	li	a0,0
ffffffffc0208b8e:	0141                	addi	sp,sp,16
ffffffffc0208b90:	8082                	ret

ffffffffc0208b92 <sys_putc>:
    cputchar(c);
ffffffffc0208b92:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0208b94:	1141                	addi	sp,sp,-16
ffffffffc0208b96:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0208b98:	e2ef70ef          	jal	ra,ffffffffc02001c6 <cputchar>
}
ffffffffc0208b9c:	60a2                	ld	ra,8(sp)
ffffffffc0208b9e:	4501                	li	a0,0
ffffffffc0208ba0:	0141                	addi	sp,sp,16
ffffffffc0208ba2:	8082                	ret

ffffffffc0208ba4 <sys_kill>:
    return do_kill(pid);
ffffffffc0208ba4:	4108                	lw	a0,0(a0)
ffffffffc0208ba6:	9c2fd06f          	j	ffffffffc0205d68 <do_kill>

ffffffffc0208baa <sys_yield>:
    return do_yield();
ffffffffc0208baa:	96cfd06f          	j	ffffffffc0205d16 <do_yield>

ffffffffc0208bae <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0208bae:	6d14                	ld	a3,24(a0)
ffffffffc0208bb0:	6910                	ld	a2,16(a0)
ffffffffc0208bb2:	650c                	ld	a1,8(a0)
ffffffffc0208bb4:	6108                	ld	a0,0(a0)
ffffffffc0208bb6:	c63fc06f          	j	ffffffffc0205818 <do_execve>

ffffffffc0208bba <sys_wait>:
    return do_wait(pid, store);
ffffffffc0208bba:	650c                	ld	a1,8(a0)
ffffffffc0208bbc:	4108                	lw	a0,0(a0)
ffffffffc0208bbe:	96afd06f          	j	ffffffffc0205d28 <do_wait>

ffffffffc0208bc2 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0208bc2:	000c0797          	auipc	a5,0xc0
ffffffffc0208bc6:	75e78793          	addi	a5,a5,1886 # ffffffffc02c9320 <current>
ffffffffc0208bca:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc0208bcc:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc0208bce:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0208bd0:	6a0c                	ld	a1,16(a2)
ffffffffc0208bd2:	bfcfc06f          	j	ffffffffc0204fce <do_fork>

ffffffffc0208bd6 <sys_exit>:
    return do_exit(error_code);
ffffffffc0208bd6:	4108                	lw	a0,0(a0)
ffffffffc0208bd8:	823fc06f          	j	ffffffffc02053fa <do_exit>

ffffffffc0208bdc <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0208bdc:	715d                	addi	sp,sp,-80
ffffffffc0208bde:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0208be0:	000c0497          	auipc	s1,0xc0
ffffffffc0208be4:	74048493          	addi	s1,s1,1856 # ffffffffc02c9320 <current>
ffffffffc0208be8:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0208bea:	e0a2                	sd	s0,64(sp)
ffffffffc0208bec:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0208bee:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0208bf0:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0208bf2:	0ff00793          	li	a5,255
    int num = tf->gpr.a0;
ffffffffc0208bf6:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0208bfa:	0327ee63          	bltu	a5,s2,ffffffffc0208c36 <syscall+0x5a>
        if (syscalls[num] != NULL) {
ffffffffc0208bfe:	00391713          	slli	a4,s2,0x3
ffffffffc0208c02:	00003797          	auipc	a5,0x3
ffffffffc0208c06:	86678793          	addi	a5,a5,-1946 # ffffffffc020b468 <syscalls>
ffffffffc0208c0a:	97ba                	add	a5,a5,a4
ffffffffc0208c0c:	639c                	ld	a5,0(a5)
ffffffffc0208c0e:	c785                	beqz	a5,ffffffffc0208c36 <syscall+0x5a>
            arg[0] = tf->gpr.a1;
ffffffffc0208c10:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0208c12:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0208c14:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0208c16:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0208c18:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0208c1a:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0208c1c:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0208c1e:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0208c20:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0208c22:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0208c24:	0028                	addi	a0,sp,8
ffffffffc0208c26:	9782                	jalr	a5
ffffffffc0208c28:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0208c2a:	60a6                	ld	ra,72(sp)
ffffffffc0208c2c:	6406                	ld	s0,64(sp)
ffffffffc0208c2e:	74e2                	ld	s1,56(sp)
ffffffffc0208c30:	7942                	ld	s2,48(sp)
ffffffffc0208c32:	6161                	addi	sp,sp,80
ffffffffc0208c34:	8082                	ret
    print_trapframe(tf);
ffffffffc0208c36:	8522                	mv	a0,s0
ffffffffc0208c38:	c0bf70ef          	jal	ra,ffffffffc0200842 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0208c3c:	609c                	ld	a5,0(s1)
ffffffffc0208c3e:	86ca                	mv	a3,s2
ffffffffc0208c40:	00002617          	auipc	a2,0x2
ffffffffc0208c44:	7e060613          	addi	a2,a2,2016 # ffffffffc020b420 <default_pmm_manager+0x15b0>
ffffffffc0208c48:	43d8                	lw	a4,4(a5)
ffffffffc0208c4a:	06d00593          	li	a1,109
ffffffffc0208c4e:	0b478793          	addi	a5,a5,180
ffffffffc0208c52:	00002517          	auipc	a0,0x2
ffffffffc0208c56:	7fe50513          	addi	a0,a0,2046 # ffffffffc020b450 <default_pmm_manager+0x15e0>
ffffffffc0208c5a:	82ff70ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0208c5e <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0208c5e:	9e3707b7          	lui	a5,0x9e370
ffffffffc0208c62:	2785                	addiw	a5,a5,1
ffffffffc0208c64:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0208c68:	02000793          	li	a5,32
ffffffffc0208c6c:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0208c70:	00b5553b          	srlw	a0,a0,a1
ffffffffc0208c74:	8082                	ret

ffffffffc0208c76 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0208c76:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0208c7a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0208c7c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0208c80:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0208c82:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0208c86:	f022                	sd	s0,32(sp)
ffffffffc0208c88:	ec26                	sd	s1,24(sp)
ffffffffc0208c8a:	e84a                	sd	s2,16(sp)
ffffffffc0208c8c:	f406                	sd	ra,40(sp)
ffffffffc0208c8e:	e44e                	sd	s3,8(sp)
ffffffffc0208c90:	84aa                	mv	s1,a0
ffffffffc0208c92:	892e                	mv	s2,a1
ffffffffc0208c94:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0208c98:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0208c9a:	03067e63          	bleu	a6,a2,ffffffffc0208cd6 <printnum+0x60>
ffffffffc0208c9e:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0208ca0:	00805763          	blez	s0,ffffffffc0208cae <printnum+0x38>
ffffffffc0208ca4:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0208ca6:	85ca                	mv	a1,s2
ffffffffc0208ca8:	854e                	mv	a0,s3
ffffffffc0208caa:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0208cac:	fc65                	bnez	s0,ffffffffc0208ca4 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0208cae:	1a02                	slli	s4,s4,0x20
ffffffffc0208cb0:	020a5a13          	srli	s4,s4,0x20
ffffffffc0208cb4:	00003797          	auipc	a5,0x3
ffffffffc0208cb8:	1d478793          	addi	a5,a5,468 # ffffffffc020be88 <error_string+0xc8>
ffffffffc0208cbc:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0208cbe:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0208cc0:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0208cc4:	70a2                	ld	ra,40(sp)
ffffffffc0208cc6:	69a2                	ld	s3,8(sp)
ffffffffc0208cc8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0208cca:	85ca                	mv	a1,s2
ffffffffc0208ccc:	8326                	mv	t1,s1
}
ffffffffc0208cce:	6942                	ld	s2,16(sp)
ffffffffc0208cd0:	64e2                	ld	s1,24(sp)
ffffffffc0208cd2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0208cd4:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0208cd6:	03065633          	divu	a2,a2,a6
ffffffffc0208cda:	8722                	mv	a4,s0
ffffffffc0208cdc:	f9bff0ef          	jal	ra,ffffffffc0208c76 <printnum>
ffffffffc0208ce0:	b7f9                	j	ffffffffc0208cae <printnum+0x38>

ffffffffc0208ce2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0208ce2:	7119                	addi	sp,sp,-128
ffffffffc0208ce4:	f4a6                	sd	s1,104(sp)
ffffffffc0208ce6:	f0ca                	sd	s2,96(sp)
ffffffffc0208ce8:	e8d2                	sd	s4,80(sp)
ffffffffc0208cea:	e4d6                	sd	s5,72(sp)
ffffffffc0208cec:	e0da                	sd	s6,64(sp)
ffffffffc0208cee:	fc5e                	sd	s7,56(sp)
ffffffffc0208cf0:	f862                	sd	s8,48(sp)
ffffffffc0208cf2:	f06a                	sd	s10,32(sp)
ffffffffc0208cf4:	fc86                	sd	ra,120(sp)
ffffffffc0208cf6:	f8a2                	sd	s0,112(sp)
ffffffffc0208cf8:	ecce                	sd	s3,88(sp)
ffffffffc0208cfa:	f466                	sd	s9,40(sp)
ffffffffc0208cfc:	ec6e                	sd	s11,24(sp)
ffffffffc0208cfe:	892a                	mv	s2,a0
ffffffffc0208d00:	84ae                	mv	s1,a1
ffffffffc0208d02:	8d32                	mv	s10,a2
ffffffffc0208d04:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0208d06:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208d08:	00003a17          	auipc	s4,0x3
ffffffffc0208d0c:	f60a0a13          	addi	s4,s4,-160 # ffffffffc020bc68 <syscalls+0x800>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0208d10:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0208d14:	00003c17          	auipc	s8,0x3
ffffffffc0208d18:	0acc0c13          	addi	s8,s8,172 # ffffffffc020bdc0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0208d1c:	000d4503          	lbu	a0,0(s10)
ffffffffc0208d20:	02500793          	li	a5,37
ffffffffc0208d24:	001d0413          	addi	s0,s10,1
ffffffffc0208d28:	00f50e63          	beq	a0,a5,ffffffffc0208d44 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0208d2c:	c521                	beqz	a0,ffffffffc0208d74 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0208d2e:	02500993          	li	s3,37
ffffffffc0208d32:	a011                	j	ffffffffc0208d36 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0208d34:	c121                	beqz	a0,ffffffffc0208d74 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0208d36:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0208d38:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0208d3a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0208d3c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0208d40:	ff351ae3          	bne	a0,s3,ffffffffc0208d34 <vprintfmt+0x52>
ffffffffc0208d44:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0208d48:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0208d4c:	4981                	li	s3,0
ffffffffc0208d4e:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0208d50:	5cfd                	li	s9,-1
ffffffffc0208d52:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208d54:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0208d58:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208d5a:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0208d5e:	0ff6f693          	andi	a3,a3,255
ffffffffc0208d62:	00140d13          	addi	s10,s0,1
ffffffffc0208d66:	20d5e563          	bltu	a1,a3,ffffffffc0208f70 <vprintfmt+0x28e>
ffffffffc0208d6a:	068a                	slli	a3,a3,0x2
ffffffffc0208d6c:	96d2                	add	a3,a3,s4
ffffffffc0208d6e:	4294                	lw	a3,0(a3)
ffffffffc0208d70:	96d2                	add	a3,a3,s4
ffffffffc0208d72:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0208d74:	70e6                	ld	ra,120(sp)
ffffffffc0208d76:	7446                	ld	s0,112(sp)
ffffffffc0208d78:	74a6                	ld	s1,104(sp)
ffffffffc0208d7a:	7906                	ld	s2,96(sp)
ffffffffc0208d7c:	69e6                	ld	s3,88(sp)
ffffffffc0208d7e:	6a46                	ld	s4,80(sp)
ffffffffc0208d80:	6aa6                	ld	s5,72(sp)
ffffffffc0208d82:	6b06                	ld	s6,64(sp)
ffffffffc0208d84:	7be2                	ld	s7,56(sp)
ffffffffc0208d86:	7c42                	ld	s8,48(sp)
ffffffffc0208d88:	7ca2                	ld	s9,40(sp)
ffffffffc0208d8a:	7d02                	ld	s10,32(sp)
ffffffffc0208d8c:	6de2                	ld	s11,24(sp)
ffffffffc0208d8e:	6109                	addi	sp,sp,128
ffffffffc0208d90:	8082                	ret
    if (lflag >= 2) {
ffffffffc0208d92:	4705                	li	a4,1
ffffffffc0208d94:	008a8593          	addi	a1,s5,8
ffffffffc0208d98:	01074463          	blt	a4,a6,ffffffffc0208da0 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0208d9c:	26080363          	beqz	a6,ffffffffc0209002 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0208da0:	000ab603          	ld	a2,0(s5)
ffffffffc0208da4:	46c1                	li	a3,16
ffffffffc0208da6:	8aae                	mv	s5,a1
ffffffffc0208da8:	a06d                	j	ffffffffc0208e52 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0208daa:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0208dae:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208db0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0208db2:	b765                	j	ffffffffc0208d5a <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0208db4:	000aa503          	lw	a0,0(s5)
ffffffffc0208db8:	85a6                	mv	a1,s1
ffffffffc0208dba:	0aa1                	addi	s5,s5,8
ffffffffc0208dbc:	9902                	jalr	s2
            break;
ffffffffc0208dbe:	bfb9                	j	ffffffffc0208d1c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0208dc0:	4705                	li	a4,1
ffffffffc0208dc2:	008a8993          	addi	s3,s5,8
ffffffffc0208dc6:	01074463          	blt	a4,a6,ffffffffc0208dce <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0208dca:	22080463          	beqz	a6,ffffffffc0208ff2 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0208dce:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0208dd2:	24044463          	bltz	s0,ffffffffc020901a <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0208dd6:	8622                	mv	a2,s0
ffffffffc0208dd8:	8ace                	mv	s5,s3
ffffffffc0208dda:	46a9                	li	a3,10
ffffffffc0208ddc:	a89d                	j	ffffffffc0208e52 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0208dde:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0208de2:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0208de4:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0208de6:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0208dea:	8fb5                	xor	a5,a5,a3
ffffffffc0208dec:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0208df0:	1ad74363          	blt	a4,a3,ffffffffc0208f96 <vprintfmt+0x2b4>
ffffffffc0208df4:	00369793          	slli	a5,a3,0x3
ffffffffc0208df8:	97e2                	add	a5,a5,s8
ffffffffc0208dfa:	639c                	ld	a5,0(a5)
ffffffffc0208dfc:	18078d63          	beqz	a5,ffffffffc0208f96 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0208e00:	86be                	mv	a3,a5
ffffffffc0208e02:	00000617          	auipc	a2,0x0
ffffffffc0208e06:	35e60613          	addi	a2,a2,862 # ffffffffc0209160 <etext+0x2a>
ffffffffc0208e0a:	85a6                	mv	a1,s1
ffffffffc0208e0c:	854a                	mv	a0,s2
ffffffffc0208e0e:	240000ef          	jal	ra,ffffffffc020904e <printfmt>
ffffffffc0208e12:	b729                	j	ffffffffc0208d1c <vprintfmt+0x3a>
            lflag ++;
ffffffffc0208e14:	00144603          	lbu	a2,1(s0)
ffffffffc0208e18:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208e1a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0208e1c:	bf3d                	j	ffffffffc0208d5a <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0208e1e:	4705                	li	a4,1
ffffffffc0208e20:	008a8593          	addi	a1,s5,8
ffffffffc0208e24:	01074463          	blt	a4,a6,ffffffffc0208e2c <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0208e28:	1e080263          	beqz	a6,ffffffffc020900c <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0208e2c:	000ab603          	ld	a2,0(s5)
ffffffffc0208e30:	46a1                	li	a3,8
ffffffffc0208e32:	8aae                	mv	s5,a1
ffffffffc0208e34:	a839                	j	ffffffffc0208e52 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0208e36:	03000513          	li	a0,48
ffffffffc0208e3a:	85a6                	mv	a1,s1
ffffffffc0208e3c:	e03e                	sd	a5,0(sp)
ffffffffc0208e3e:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0208e40:	85a6                	mv	a1,s1
ffffffffc0208e42:	07800513          	li	a0,120
ffffffffc0208e46:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0208e48:	0aa1                	addi	s5,s5,8
ffffffffc0208e4a:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0208e4e:	6782                	ld	a5,0(sp)
ffffffffc0208e50:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0208e52:	876e                	mv	a4,s11
ffffffffc0208e54:	85a6                	mv	a1,s1
ffffffffc0208e56:	854a                	mv	a0,s2
ffffffffc0208e58:	e1fff0ef          	jal	ra,ffffffffc0208c76 <printnum>
            break;
ffffffffc0208e5c:	b5c1                	j	ffffffffc0208d1c <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0208e5e:	000ab603          	ld	a2,0(s5)
ffffffffc0208e62:	0aa1                	addi	s5,s5,8
ffffffffc0208e64:	1c060663          	beqz	a2,ffffffffc0209030 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0208e68:	00160413          	addi	s0,a2,1
ffffffffc0208e6c:	17b05c63          	blez	s11,ffffffffc0208fe4 <vprintfmt+0x302>
ffffffffc0208e70:	02d00593          	li	a1,45
ffffffffc0208e74:	14b79263          	bne	a5,a1,ffffffffc0208fb8 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0208e78:	00064783          	lbu	a5,0(a2)
ffffffffc0208e7c:	0007851b          	sext.w	a0,a5
ffffffffc0208e80:	c905                	beqz	a0,ffffffffc0208eb0 <vprintfmt+0x1ce>
ffffffffc0208e82:	000cc563          	bltz	s9,ffffffffc0208e8c <vprintfmt+0x1aa>
ffffffffc0208e86:	3cfd                	addiw	s9,s9,-1
ffffffffc0208e88:	036c8263          	beq	s9,s6,ffffffffc0208eac <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0208e8c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0208e8e:	18098463          	beqz	s3,ffffffffc0209016 <vprintfmt+0x334>
ffffffffc0208e92:	3781                	addiw	a5,a5,-32
ffffffffc0208e94:	18fbf163          	bleu	a5,s7,ffffffffc0209016 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0208e98:	03f00513          	li	a0,63
ffffffffc0208e9c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0208e9e:	0405                	addi	s0,s0,1
ffffffffc0208ea0:	fff44783          	lbu	a5,-1(s0)
ffffffffc0208ea4:	3dfd                	addiw	s11,s11,-1
ffffffffc0208ea6:	0007851b          	sext.w	a0,a5
ffffffffc0208eaa:	fd61                	bnez	a0,ffffffffc0208e82 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0208eac:	e7b058e3          	blez	s11,ffffffffc0208d1c <vprintfmt+0x3a>
ffffffffc0208eb0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0208eb2:	85a6                	mv	a1,s1
ffffffffc0208eb4:	02000513          	li	a0,32
ffffffffc0208eb8:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0208eba:	e60d81e3          	beqz	s11,ffffffffc0208d1c <vprintfmt+0x3a>
ffffffffc0208ebe:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0208ec0:	85a6                	mv	a1,s1
ffffffffc0208ec2:	02000513          	li	a0,32
ffffffffc0208ec6:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0208ec8:	fe0d94e3          	bnez	s11,ffffffffc0208eb0 <vprintfmt+0x1ce>
ffffffffc0208ecc:	bd81                	j	ffffffffc0208d1c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0208ece:	4705                	li	a4,1
ffffffffc0208ed0:	008a8593          	addi	a1,s5,8
ffffffffc0208ed4:	01074463          	blt	a4,a6,ffffffffc0208edc <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0208ed8:	12080063          	beqz	a6,ffffffffc0208ff8 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0208edc:	000ab603          	ld	a2,0(s5)
ffffffffc0208ee0:	46a9                	li	a3,10
ffffffffc0208ee2:	8aae                	mv	s5,a1
ffffffffc0208ee4:	b7bd                	j	ffffffffc0208e52 <vprintfmt+0x170>
ffffffffc0208ee6:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0208eea:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208eee:	846a                	mv	s0,s10
ffffffffc0208ef0:	b5ad                	j	ffffffffc0208d5a <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0208ef2:	85a6                	mv	a1,s1
ffffffffc0208ef4:	02500513          	li	a0,37
ffffffffc0208ef8:	9902                	jalr	s2
            break;
ffffffffc0208efa:	b50d                	j	ffffffffc0208d1c <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0208efc:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0208f00:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0208f04:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208f06:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0208f08:	e40dd9e3          	bgez	s11,ffffffffc0208d5a <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0208f0c:	8de6                	mv	s11,s9
ffffffffc0208f0e:	5cfd                	li	s9,-1
ffffffffc0208f10:	b5a9                	j	ffffffffc0208d5a <vprintfmt+0x78>
            goto reswitch;
ffffffffc0208f12:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0208f16:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208f1a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0208f1c:	bd3d                	j	ffffffffc0208d5a <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0208f1e:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0208f22:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208f26:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0208f28:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0208f2c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0208f30:	fcd56ce3          	bltu	a0,a3,ffffffffc0208f08 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0208f34:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0208f36:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0208f3a:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0208f3e:	0196873b          	addw	a4,a3,s9
ffffffffc0208f42:	0017171b          	slliw	a4,a4,0x1
ffffffffc0208f46:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0208f4a:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0208f4e:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0208f52:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0208f56:	fcd57fe3          	bleu	a3,a0,ffffffffc0208f34 <vprintfmt+0x252>
ffffffffc0208f5a:	b77d                	j	ffffffffc0208f08 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0208f5c:	fffdc693          	not	a3,s11
ffffffffc0208f60:	96fd                	srai	a3,a3,0x3f
ffffffffc0208f62:	00ddfdb3          	and	s11,s11,a3
ffffffffc0208f66:	00144603          	lbu	a2,1(s0)
ffffffffc0208f6a:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208f6c:	846a                	mv	s0,s10
ffffffffc0208f6e:	b3f5                	j	ffffffffc0208d5a <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0208f70:	85a6                	mv	a1,s1
ffffffffc0208f72:	02500513          	li	a0,37
ffffffffc0208f76:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0208f78:	fff44703          	lbu	a4,-1(s0)
ffffffffc0208f7c:	02500793          	li	a5,37
ffffffffc0208f80:	8d22                	mv	s10,s0
ffffffffc0208f82:	d8f70de3          	beq	a4,a5,ffffffffc0208d1c <vprintfmt+0x3a>
ffffffffc0208f86:	02500713          	li	a4,37
ffffffffc0208f8a:	1d7d                	addi	s10,s10,-1
ffffffffc0208f8c:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0208f90:	fee79de3          	bne	a5,a4,ffffffffc0208f8a <vprintfmt+0x2a8>
ffffffffc0208f94:	b361                	j	ffffffffc0208d1c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0208f96:	00003617          	auipc	a2,0x3
ffffffffc0208f9a:	fd260613          	addi	a2,a2,-46 # ffffffffc020bf68 <error_string+0x1a8>
ffffffffc0208f9e:	85a6                	mv	a1,s1
ffffffffc0208fa0:	854a                	mv	a0,s2
ffffffffc0208fa2:	0ac000ef          	jal	ra,ffffffffc020904e <printfmt>
ffffffffc0208fa6:	bb9d                	j	ffffffffc0208d1c <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0208fa8:	00003617          	auipc	a2,0x3
ffffffffc0208fac:	fb860613          	addi	a2,a2,-72 # ffffffffc020bf60 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc0208fb0:	00003417          	auipc	s0,0x3
ffffffffc0208fb4:	fb140413          	addi	s0,s0,-79 # ffffffffc020bf61 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0208fb8:	8532                	mv	a0,a2
ffffffffc0208fba:	85e6                	mv	a1,s9
ffffffffc0208fbc:	e032                	sd	a2,0(sp)
ffffffffc0208fbe:	e43e                	sd	a5,8(sp)
ffffffffc0208fc0:	0cc000ef          	jal	ra,ffffffffc020908c <strnlen>
ffffffffc0208fc4:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0208fc8:	6602                	ld	a2,0(sp)
ffffffffc0208fca:	01b05d63          	blez	s11,ffffffffc0208fe4 <vprintfmt+0x302>
ffffffffc0208fce:	67a2                	ld	a5,8(sp)
ffffffffc0208fd0:	2781                	sext.w	a5,a5
ffffffffc0208fd2:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0208fd4:	6522                	ld	a0,8(sp)
ffffffffc0208fd6:	85a6                	mv	a1,s1
ffffffffc0208fd8:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0208fda:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0208fdc:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0208fde:	6602                	ld	a2,0(sp)
ffffffffc0208fe0:	fe0d9ae3          	bnez	s11,ffffffffc0208fd4 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0208fe4:	00064783          	lbu	a5,0(a2)
ffffffffc0208fe8:	0007851b          	sext.w	a0,a5
ffffffffc0208fec:	e8051be3          	bnez	a0,ffffffffc0208e82 <vprintfmt+0x1a0>
ffffffffc0208ff0:	b335                	j	ffffffffc0208d1c <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0208ff2:	000aa403          	lw	s0,0(s5)
ffffffffc0208ff6:	bbf1                	j	ffffffffc0208dd2 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0208ff8:	000ae603          	lwu	a2,0(s5)
ffffffffc0208ffc:	46a9                	li	a3,10
ffffffffc0208ffe:	8aae                	mv	s5,a1
ffffffffc0209000:	bd89                	j	ffffffffc0208e52 <vprintfmt+0x170>
ffffffffc0209002:	000ae603          	lwu	a2,0(s5)
ffffffffc0209006:	46c1                	li	a3,16
ffffffffc0209008:	8aae                	mv	s5,a1
ffffffffc020900a:	b5a1                	j	ffffffffc0208e52 <vprintfmt+0x170>
ffffffffc020900c:	000ae603          	lwu	a2,0(s5)
ffffffffc0209010:	46a1                	li	a3,8
ffffffffc0209012:	8aae                	mv	s5,a1
ffffffffc0209014:	bd3d                	j	ffffffffc0208e52 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0209016:	9902                	jalr	s2
ffffffffc0209018:	b559                	j	ffffffffc0208e9e <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc020901a:	85a6                	mv	a1,s1
ffffffffc020901c:	02d00513          	li	a0,45
ffffffffc0209020:	e03e                	sd	a5,0(sp)
ffffffffc0209022:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0209024:	8ace                	mv	s5,s3
ffffffffc0209026:	40800633          	neg	a2,s0
ffffffffc020902a:	46a9                	li	a3,10
ffffffffc020902c:	6782                	ld	a5,0(sp)
ffffffffc020902e:	b515                	j	ffffffffc0208e52 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0209030:	01b05663          	blez	s11,ffffffffc020903c <vprintfmt+0x35a>
ffffffffc0209034:	02d00693          	li	a3,45
ffffffffc0209038:	f6d798e3          	bne	a5,a3,ffffffffc0208fa8 <vprintfmt+0x2c6>
ffffffffc020903c:	00003417          	auipc	s0,0x3
ffffffffc0209040:	f2540413          	addi	s0,s0,-219 # ffffffffc020bf61 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0209044:	02800513          	li	a0,40
ffffffffc0209048:	02800793          	li	a5,40
ffffffffc020904c:	bd1d                	j	ffffffffc0208e82 <vprintfmt+0x1a0>

ffffffffc020904e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020904e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0209050:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0209054:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0209056:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0209058:	ec06                	sd	ra,24(sp)
ffffffffc020905a:	f83a                	sd	a4,48(sp)
ffffffffc020905c:	fc3e                	sd	a5,56(sp)
ffffffffc020905e:	e0c2                	sd	a6,64(sp)
ffffffffc0209060:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0209062:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0209064:	c7fff0ef          	jal	ra,ffffffffc0208ce2 <vprintfmt>
}
ffffffffc0209068:	60e2                	ld	ra,24(sp)
ffffffffc020906a:	6161                	addi	sp,sp,80
ffffffffc020906c:	8082                	ret

ffffffffc020906e <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020906e:	00054783          	lbu	a5,0(a0)
ffffffffc0209072:	cb91                	beqz	a5,ffffffffc0209086 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0209074:	4781                	li	a5,0
        cnt ++;
ffffffffc0209076:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0209078:	00f50733          	add	a4,a0,a5
ffffffffc020907c:	00074703          	lbu	a4,0(a4)
ffffffffc0209080:	fb7d                	bnez	a4,ffffffffc0209076 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0209082:	853e                	mv	a0,a5
ffffffffc0209084:	8082                	ret
    size_t cnt = 0;
ffffffffc0209086:	4781                	li	a5,0
}
ffffffffc0209088:	853e                	mv	a0,a5
ffffffffc020908a:	8082                	ret

ffffffffc020908c <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc020908c:	c185                	beqz	a1,ffffffffc02090ac <strnlen+0x20>
ffffffffc020908e:	00054783          	lbu	a5,0(a0)
ffffffffc0209092:	cf89                	beqz	a5,ffffffffc02090ac <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0209094:	4781                	li	a5,0
ffffffffc0209096:	a021                	j	ffffffffc020909e <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0209098:	00074703          	lbu	a4,0(a4)
ffffffffc020909c:	c711                	beqz	a4,ffffffffc02090a8 <strnlen+0x1c>
        cnt ++;
ffffffffc020909e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02090a0:	00f50733          	add	a4,a0,a5
ffffffffc02090a4:	fef59ae3          	bne	a1,a5,ffffffffc0209098 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02090a8:	853e                	mv	a0,a5
ffffffffc02090aa:	8082                	ret
    size_t cnt = 0;
ffffffffc02090ac:	4781                	li	a5,0
}
ffffffffc02090ae:	853e                	mv	a0,a5
ffffffffc02090b0:	8082                	ret

ffffffffc02090b2 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02090b2:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02090b4:	0585                	addi	a1,a1,1
ffffffffc02090b6:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02090ba:	0785                	addi	a5,a5,1
ffffffffc02090bc:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02090c0:	fb75                	bnez	a4,ffffffffc02090b4 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02090c2:	8082                	ret

ffffffffc02090c4 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02090c4:	00054783          	lbu	a5,0(a0)
ffffffffc02090c8:	0005c703          	lbu	a4,0(a1)
ffffffffc02090cc:	cb91                	beqz	a5,ffffffffc02090e0 <strcmp+0x1c>
ffffffffc02090ce:	00e79c63          	bne	a5,a4,ffffffffc02090e6 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02090d2:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02090d4:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02090d8:	0585                	addi	a1,a1,1
ffffffffc02090da:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02090de:	fbe5                	bnez	a5,ffffffffc02090ce <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02090e0:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02090e2:	9d19                	subw	a0,a0,a4
ffffffffc02090e4:	8082                	ret
ffffffffc02090e6:	0007851b          	sext.w	a0,a5
ffffffffc02090ea:	9d19                	subw	a0,a0,a4
ffffffffc02090ec:	8082                	ret

ffffffffc02090ee <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02090ee:	00054783          	lbu	a5,0(a0)
ffffffffc02090f2:	cb91                	beqz	a5,ffffffffc0209106 <strchr+0x18>
        if (*s == c) {
ffffffffc02090f4:	00b79563          	bne	a5,a1,ffffffffc02090fe <strchr+0x10>
ffffffffc02090f8:	a809                	j	ffffffffc020910a <strchr+0x1c>
ffffffffc02090fa:	00b78763          	beq	a5,a1,ffffffffc0209108 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02090fe:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0209100:	00054783          	lbu	a5,0(a0)
ffffffffc0209104:	fbfd                	bnez	a5,ffffffffc02090fa <strchr+0xc>
    }
    return NULL;
ffffffffc0209106:	4501                	li	a0,0
}
ffffffffc0209108:	8082                	ret
ffffffffc020910a:	8082                	ret

ffffffffc020910c <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020910c:	ca01                	beqz	a2,ffffffffc020911c <memset+0x10>
ffffffffc020910e:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0209110:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0209112:	0785                	addi	a5,a5,1
ffffffffc0209114:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0209118:	fec79de3          	bne	a5,a2,ffffffffc0209112 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020911c:	8082                	ret

ffffffffc020911e <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020911e:	ca19                	beqz	a2,ffffffffc0209134 <memcpy+0x16>
ffffffffc0209120:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0209122:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0209124:	0585                	addi	a1,a1,1
ffffffffc0209126:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020912a:	0785                	addi	a5,a5,1
ffffffffc020912c:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0209130:	fec59ae3          	bne	a1,a2,ffffffffc0209124 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0209134:	8082                	ret
