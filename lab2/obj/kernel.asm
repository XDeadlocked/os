
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
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
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

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


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fda50513          	addi	a0,a0,-38 # ffffffffc0206010 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	4ea60613          	addi	a2,a2,1258 # ffffffffc0206528 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	3c8010ef          	jal	ra,ffffffffc0201416 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00001517          	auipc	a0,0x1
ffffffffc020005a:	3ea50513          	addi	a0,a0,1002 # ffffffffc0201440 <etext>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	005000ef          	jal	ra,ffffffffc020086e <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3fc000ef          	jal	ra,ffffffffc020046a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e8000ef          	jal	ra,ffffffffc020045e <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3ce000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	65f000ef          	jal	ra,ffffffffc0200f08 <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	62b000ef          	jal	ra,ffffffffc0200f08 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	3680006f          	j	ffffffffc0200452 <cons_putc>

ffffffffc02000ee <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ee:	1101                	addi	sp,sp,-32
ffffffffc02000f0:	e822                	sd	s0,16(sp)
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e426                	sd	s1,8(sp)
ffffffffc02000f6:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c51d                	beqz	a0,ffffffffc020012a <cputs+0x3c>
ffffffffc02000fe:	0405                	addi	s0,s0,1
ffffffffc0200100:	4485                	li	s1,1
ffffffffc0200102:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200104:	34e000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200112:	f96d                	bnez	a0,ffffffffc0200104 <cputs+0x16>
ffffffffc0200114:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200118:	4529                	li	a0,10
ffffffffc020011a:	338000ef          	jal	ra,ffffffffc0200452 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011e:	8522                	mv	a0,s0
ffffffffc0200120:	60e2                	ld	ra,24(sp)
ffffffffc0200122:	6442                	ld	s0,16(sp)
ffffffffc0200124:	64a2                	ld	s1,8(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
ffffffffc020012c:	b7f5                	j	ffffffffc0200118 <cputs+0x2a>

ffffffffc020012e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012e:	1141                	addi	sp,sp,-16
ffffffffc0200130:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200132:	328000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc0200136:	dd75                	beqz	a0,ffffffffc0200132 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200138:	60a2                	ld	ra,8(sp)
ffffffffc020013a:	0141                	addi	sp,sp,16
ffffffffc020013c:	8082                	ret

ffffffffc020013e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200140:	00001517          	auipc	a0,0x1
ffffffffc0200144:	35050513          	addi	a0,a0,848 # ffffffffc0201490 <etext+0x50>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00001517          	auipc	a0,0x1
ffffffffc020015a:	35a50513          	addi	a0,a0,858 # ffffffffc02014b0 <etext+0x70>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00001597          	auipc	a1,0x1
ffffffffc0200166:	2de58593          	addi	a1,a1,734 # ffffffffc0201440 <etext>
ffffffffc020016a:	00001517          	auipc	a0,0x1
ffffffffc020016e:	36650513          	addi	a0,a0,870 # ffffffffc02014d0 <etext+0x90>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0206010 <edata>
ffffffffc020017e:	00001517          	auipc	a0,0x1
ffffffffc0200182:	37250513          	addi	a0,a0,882 # ffffffffc02014f0 <etext+0xb0>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00006597          	auipc	a1,0x6
ffffffffc020018e:	39e58593          	addi	a1,a1,926 # ffffffffc0206528 <end>
ffffffffc0200192:	00001517          	auipc	a0,0x1
ffffffffc0200196:	37e50513          	addi	a0,a0,894 # ffffffffc0201510 <etext+0xd0>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019e:	00006597          	auipc	a1,0x6
ffffffffc02001a2:	78958593          	addi	a1,a1,1929 # ffffffffc0206927 <end+0x3ff>
ffffffffc02001a6:	00000797          	auipc	a5,0x0
ffffffffc02001aa:	e9078793          	addi	a5,a5,-368 # ffffffffc0200036 <kern_init>
ffffffffc02001ae:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b2:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b6:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001bc:	95be                	add	a1,a1,a5
ffffffffc02001be:	85a9                	srai	a1,a1,0xa
ffffffffc02001c0:	00001517          	auipc	a0,0x1
ffffffffc02001c4:	37050513          	addi	a0,a0,880 # ffffffffc0201530 <etext+0xf0>
}
ffffffffc02001c8:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ca:	eedff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02001ce <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ce:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001d0:	00001617          	auipc	a2,0x1
ffffffffc02001d4:	29060613          	addi	a2,a2,656 # ffffffffc0201460 <etext+0x20>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00001517          	auipc	a0,0x1
ffffffffc02001e0:	29c50513          	addi	a0,a0,668 # ffffffffc0201478 <etext+0x38>
void print_stackframe(void) {
ffffffffc02001e4:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e6:	1c6000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001ea <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ea:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ec:	00001617          	auipc	a2,0x1
ffffffffc02001f0:	45460613          	addi	a2,a2,1108 # ffffffffc0201640 <commands+0xe0>
ffffffffc02001f4:	00001597          	auipc	a1,0x1
ffffffffc02001f8:	46c58593          	addi	a1,a1,1132 # ffffffffc0201660 <commands+0x100>
ffffffffc02001fc:	00001517          	auipc	a0,0x1
ffffffffc0200200:	46c50513          	addi	a0,a0,1132 # ffffffffc0201668 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00001617          	auipc	a2,0x1
ffffffffc020020e:	46e60613          	addi	a2,a2,1134 # ffffffffc0201678 <commands+0x118>
ffffffffc0200212:	00001597          	auipc	a1,0x1
ffffffffc0200216:	48e58593          	addi	a1,a1,1166 # ffffffffc02016a0 <commands+0x140>
ffffffffc020021a:	00001517          	auipc	a0,0x1
ffffffffc020021e:	44e50513          	addi	a0,a0,1102 # ffffffffc0201668 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00001617          	auipc	a2,0x1
ffffffffc020022a:	48a60613          	addi	a2,a2,1162 # ffffffffc02016b0 <commands+0x150>
ffffffffc020022e:	00001597          	auipc	a1,0x1
ffffffffc0200232:	4a258593          	addi	a1,a1,1186 # ffffffffc02016d0 <commands+0x170>
ffffffffc0200236:	00001517          	auipc	a0,0x1
ffffffffc020023a:	43250513          	addi	a0,a0,1074 # ffffffffc0201668 <commands+0x108>
ffffffffc020023e:	e79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc0200242:	60a2                	ld	ra,8(sp)
ffffffffc0200244:	4501                	li	a0,0
ffffffffc0200246:	0141                	addi	sp,sp,16
ffffffffc0200248:	8082                	ret

ffffffffc020024a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024a:	1141                	addi	sp,sp,-16
ffffffffc020024c:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020024e:	ef1ff0ef          	jal	ra,ffffffffc020013e <print_kerninfo>
    return 0;
}
ffffffffc0200252:	60a2                	ld	ra,8(sp)
ffffffffc0200254:	4501                	li	a0,0
ffffffffc0200256:	0141                	addi	sp,sp,16
ffffffffc0200258:	8082                	ret

ffffffffc020025a <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	1141                	addi	sp,sp,-16
ffffffffc020025c:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020025e:	f71ff0ef          	jal	ra,ffffffffc02001ce <print_stackframe>
    return 0;
}
ffffffffc0200262:	60a2                	ld	ra,8(sp)
ffffffffc0200264:	4501                	li	a0,0
ffffffffc0200266:	0141                	addi	sp,sp,16
ffffffffc0200268:	8082                	ret

ffffffffc020026a <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020026a:	7115                	addi	sp,sp,-224
ffffffffc020026c:	e962                	sd	s8,144(sp)
ffffffffc020026e:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200270:	00001517          	auipc	a0,0x1
ffffffffc0200274:	33850513          	addi	a0,a0,824 # ffffffffc02015a8 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200278:	ed86                	sd	ra,216(sp)
ffffffffc020027a:	e9a2                	sd	s0,208(sp)
ffffffffc020027c:	e5a6                	sd	s1,200(sp)
ffffffffc020027e:	e1ca                	sd	s2,192(sp)
ffffffffc0200280:	fd4e                	sd	s3,184(sp)
ffffffffc0200282:	f952                	sd	s4,176(sp)
ffffffffc0200284:	f556                	sd	s5,168(sp)
ffffffffc0200286:	f15a                	sd	s6,160(sp)
ffffffffc0200288:	ed5e                	sd	s7,152(sp)
ffffffffc020028a:	e566                	sd	s9,136(sp)
ffffffffc020028c:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028e:	e29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200292:	00001517          	auipc	a0,0x1
ffffffffc0200296:	33e50513          	addi	a0,a0,830 # ffffffffc02015d0 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00001c97          	auipc	s9,0x1
ffffffffc02002ac:	2b8c8c93          	addi	s9,s9,696 # ffffffffc0201560 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00001997          	auipc	s3,0x1
ffffffffc02002b4:	34898993          	addi	s3,s3,840 # ffffffffc02015f8 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00001917          	auipc	s2,0x1
ffffffffc02002bc:	34890913          	addi	s2,s2,840 # ffffffffc0201600 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00001b17          	auipc	s6,0x1
ffffffffc02002c6:	346b0b13          	addi	s6,s6,838 # ffffffffc0201608 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00001a97          	auipc	s5,0x1
ffffffffc02002ce:	396a8a93          	addi	s5,s5,918 # ffffffffc0201660 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	7bf000ef          	jal	ra,ffffffffc0201294 <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	110010ef          	jal	ra,ffffffffc02013f8 <strchr>
ffffffffc02002ec:	c925                	beqz	a0,ffffffffc020035c <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002ee:	00144583          	lbu	a1,1(s0)
ffffffffc02002f2:	00040023          	sb	zero,0(s0)
ffffffffc02002f6:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002f8:	f5fd                	bnez	a1,ffffffffc02002e6 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002fa:	dce9                	beqz	s1,ffffffffc02002d4 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002fc:	6582                	ld	a1,0(sp)
ffffffffc02002fe:	00001d17          	auipc	s10,0x1
ffffffffc0200302:	262d0d13          	addi	s10,s10,610 # ffffffffc0201560 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	0c2010ef          	jal	ra,ffffffffc02013ce <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	0ae010ef          	jal	ra,ffffffffc02013ce <strcmp>
ffffffffc0200324:	f57d                	bnez	a0,ffffffffc0200312 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200326:	00141793          	slli	a5,s0,0x1
ffffffffc020032a:	97a2                	add	a5,a5,s0
ffffffffc020032c:	078e                	slli	a5,a5,0x3
ffffffffc020032e:	97e6                	add	a5,a5,s9
ffffffffc0200330:	6b9c                	ld	a5,16(a5)
ffffffffc0200332:	8662                	mv	a2,s8
ffffffffc0200334:	002c                	addi	a1,sp,8
ffffffffc0200336:	fff4851b          	addiw	a0,s1,-1
ffffffffc020033a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020033c:	f8055ce3          	bgez	a0,ffffffffc02002d4 <kmonitor+0x6a>
}
ffffffffc0200340:	60ee                	ld	ra,216(sp)
ffffffffc0200342:	644e                	ld	s0,208(sp)
ffffffffc0200344:	64ae                	ld	s1,200(sp)
ffffffffc0200346:	690e                	ld	s2,192(sp)
ffffffffc0200348:	79ea                	ld	s3,184(sp)
ffffffffc020034a:	7a4a                	ld	s4,176(sp)
ffffffffc020034c:	7aaa                	ld	s5,168(sp)
ffffffffc020034e:	7b0a                	ld	s6,160(sp)
ffffffffc0200350:	6bea                	ld	s7,152(sp)
ffffffffc0200352:	6c4a                	ld	s8,144(sp)
ffffffffc0200354:	6caa                	ld	s9,136(sp)
ffffffffc0200356:	6d0a                	ld	s10,128(sp)
ffffffffc0200358:	612d                	addi	sp,sp,224
ffffffffc020035a:	8082                	ret
        if (*buf == '\0') {
ffffffffc020035c:	00044783          	lbu	a5,0(s0)
ffffffffc0200360:	dfc9                	beqz	a5,ffffffffc02002fa <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200362:	03448863          	beq	s1,s4,ffffffffc0200392 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc0200366:	00349793          	slli	a5,s1,0x3
ffffffffc020036a:	0118                	addi	a4,sp,128
ffffffffc020036c:	97ba                	add	a5,a5,a4
ffffffffc020036e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200372:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200376:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200378:	e591                	bnez	a1,ffffffffc0200384 <kmonitor+0x11a>
ffffffffc020037a:	b749                	j	ffffffffc02002fc <kmonitor+0x92>
            buf ++;
ffffffffc020037c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020037e:	00044583          	lbu	a1,0(s0)
ffffffffc0200382:	ddad                	beqz	a1,ffffffffc02002fc <kmonitor+0x92>
ffffffffc0200384:	854a                	mv	a0,s2
ffffffffc0200386:	072010ef          	jal	ra,ffffffffc02013f8 <strchr>
ffffffffc020038a:	d96d                	beqz	a0,ffffffffc020037c <kmonitor+0x112>
ffffffffc020038c:	00044583          	lbu	a1,0(s0)
ffffffffc0200390:	bf91                	j	ffffffffc02002e4 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020039a:	b7f1                	j	ffffffffc0200366 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	28a50513          	addi	a0,a0,650 # ffffffffc0201628 <commands+0xc8>
ffffffffc02003a6:	d11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc02003aa:	b72d                	j	ffffffffc02002d4 <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	11c30313          	addi	t1,t1,284 # ffffffffc02064c8 <is_panic>
ffffffffc02003b4:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	02031c63          	bnez	t1,ffffffffc0200400 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	8432                	mv	s0,a2
ffffffffc02003d0:	00006717          	auipc	a4,0x6
ffffffffc02003d4:	0ef72c23          	sw	a5,248(a4) # ffffffffc02064c8 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d8:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003da:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003dc:	85aa                	mv	a1,a0
ffffffffc02003de:	00001517          	auipc	a0,0x1
ffffffffc02003e2:	30250513          	addi	a0,a0,770 # ffffffffc02016e0 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003e6:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e8:	ccfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003ec:	65a2                	ld	a1,8(sp)
ffffffffc02003ee:	8522                	mv	a0,s0
ffffffffc02003f0:	ca7ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc02003f4:	00001517          	auipc	a0,0x1
ffffffffc02003f8:	16450513          	addi	a0,a0,356 # ffffffffc0201558 <etext+0x118>
ffffffffc02003fc:	cbbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200400:	064000ef          	jal	ra,ffffffffc0200464 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200404:	4501                	li	a0,0
ffffffffc0200406:	e65ff0ef          	jal	ra,ffffffffc020026a <kmonitor>
ffffffffc020040a:	bfed                	j	ffffffffc0200404 <__panic+0x58>

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	74b000ef          	jal	ra,ffffffffc020136e <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0a07bf23          	sd	zero,190(a5) # ffffffffc02064e8 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00001517          	auipc	a0,0x1
ffffffffc0200436:	2ce50513          	addi	a0,a0,718 # ffffffffc0201700 <commands+0x1a0>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	c7bff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200440 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200440:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200444:	67e1                	lui	a5,0x18
ffffffffc0200446:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020044a:	953e                	add	a0,a0,a5
ffffffffc020044c:	7230006f          	j	ffffffffc020136e <sbi_set_timer>

ffffffffc0200450 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200450:	8082                	ret

ffffffffc0200452 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200452:	0ff57513          	andi	a0,a0,255
ffffffffc0200456:	6fd0006f          	j	ffffffffc0201352 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	7310006f          	j	ffffffffc020138a <sbi_console_getchar>

ffffffffc020045e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046e:	00000797          	auipc	a5,0x0
ffffffffc0200472:	30678793          	addi	a5,a5,774 # ffffffffc0200774 <__alltraps>
ffffffffc0200476:	10579073          	csrw	stvec,a5
}
ffffffffc020047a:	8082                	ret

ffffffffc020047c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020047e:	1141                	addi	sp,sp,-16
ffffffffc0200480:	e022                	sd	s0,0(sp)
ffffffffc0200482:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	00001517          	auipc	a0,0x1
ffffffffc0200488:	39450513          	addi	a0,a0,916 # ffffffffc0201818 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00001517          	auipc	a0,0x1
ffffffffc0200498:	39c50513          	addi	a0,a0,924 # ffffffffc0201830 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00001517          	auipc	a0,0x1
ffffffffc02004a6:	3a650513          	addi	a0,a0,934 # ffffffffc0201848 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00001517          	auipc	a0,0x1
ffffffffc02004b4:	3b050513          	addi	a0,a0,944 # ffffffffc0201860 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00001517          	auipc	a0,0x1
ffffffffc02004c2:	3ba50513          	addi	a0,a0,954 # ffffffffc0201878 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00001517          	auipc	a0,0x1
ffffffffc02004d0:	3c450513          	addi	a0,a0,964 # ffffffffc0201890 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00001517          	auipc	a0,0x1
ffffffffc02004de:	3ce50513          	addi	a0,a0,974 # ffffffffc02018a8 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00001517          	auipc	a0,0x1
ffffffffc02004ec:	3d850513          	addi	a0,a0,984 # ffffffffc02018c0 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00001517          	auipc	a0,0x1
ffffffffc02004fa:	3e250513          	addi	a0,a0,994 # ffffffffc02018d8 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00001517          	auipc	a0,0x1
ffffffffc0200508:	3ec50513          	addi	a0,a0,1004 # ffffffffc02018f0 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00001517          	auipc	a0,0x1
ffffffffc0200516:	3f650513          	addi	a0,a0,1014 # ffffffffc0201908 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00001517          	auipc	a0,0x1
ffffffffc0200524:	40050513          	addi	a0,a0,1024 # ffffffffc0201920 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00001517          	auipc	a0,0x1
ffffffffc0200532:	40a50513          	addi	a0,a0,1034 # ffffffffc0201938 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00001517          	auipc	a0,0x1
ffffffffc0200540:	41450513          	addi	a0,a0,1044 # ffffffffc0201950 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00001517          	auipc	a0,0x1
ffffffffc020054e:	41e50513          	addi	a0,a0,1054 # ffffffffc0201968 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00001517          	auipc	a0,0x1
ffffffffc020055c:	42850513          	addi	a0,a0,1064 # ffffffffc0201980 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00001517          	auipc	a0,0x1
ffffffffc020056a:	43250513          	addi	a0,a0,1074 # ffffffffc0201998 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00001517          	auipc	a0,0x1
ffffffffc0200578:	43c50513          	addi	a0,a0,1084 # ffffffffc02019b0 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00001517          	auipc	a0,0x1
ffffffffc0200586:	44650513          	addi	a0,a0,1094 # ffffffffc02019c8 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00001517          	auipc	a0,0x1
ffffffffc0200594:	45050513          	addi	a0,a0,1104 # ffffffffc02019e0 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00001517          	auipc	a0,0x1
ffffffffc02005a2:	45a50513          	addi	a0,a0,1114 # ffffffffc02019f8 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00001517          	auipc	a0,0x1
ffffffffc02005b0:	46450513          	addi	a0,a0,1124 # ffffffffc0201a10 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00001517          	auipc	a0,0x1
ffffffffc02005be:	46e50513          	addi	a0,a0,1134 # ffffffffc0201a28 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00001517          	auipc	a0,0x1
ffffffffc02005cc:	47850513          	addi	a0,a0,1144 # ffffffffc0201a40 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00001517          	auipc	a0,0x1
ffffffffc02005da:	48250513          	addi	a0,a0,1154 # ffffffffc0201a58 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00001517          	auipc	a0,0x1
ffffffffc02005e8:	48c50513          	addi	a0,a0,1164 # ffffffffc0201a70 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00001517          	auipc	a0,0x1
ffffffffc02005f6:	49650513          	addi	a0,a0,1174 # ffffffffc0201a88 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00001517          	auipc	a0,0x1
ffffffffc0200604:	4a050513          	addi	a0,a0,1184 # ffffffffc0201aa0 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00001517          	auipc	a0,0x1
ffffffffc0200612:	4aa50513          	addi	a0,a0,1194 # ffffffffc0201ab8 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00001517          	auipc	a0,0x1
ffffffffc0200620:	4b450513          	addi	a0,a0,1204 # ffffffffc0201ad0 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00001517          	auipc	a0,0x1
ffffffffc020062e:	4be50513          	addi	a0,a0,1214 # ffffffffc0201ae8 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00001517          	auipc	a0,0x1
ffffffffc0200640:	4c450513          	addi	a0,a0,1220 # ffffffffc0201b00 <commands+0x5a0>
}
ffffffffc0200644:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200646:	a71ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00001517          	auipc	a0,0x1
ffffffffc0200656:	4c650513          	addi	a0,a0,1222 # ffffffffc0201b18 <commands+0x5b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00001517          	auipc	a0,0x1
ffffffffc020066e:	4c650513          	addi	a0,a0,1222 # ffffffffc0201b30 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00001517          	auipc	a0,0x1
ffffffffc020067e:	4ce50513          	addi	a0,a0,1230 # ffffffffc0201b48 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00001517          	auipc	a0,0x1
ffffffffc020068e:	4d650513          	addi	a0,a0,1238 # ffffffffc0201b60 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00001517          	auipc	a0,0x1
ffffffffc02006a2:	4da50513          	addi	a0,a0,1242 # ffffffffc0201b78 <commands+0x618>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	a0fff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02006ac <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006ac:	11853783          	ld	a5,280(a0)
ffffffffc02006b0:	577d                	li	a4,-1
ffffffffc02006b2:	8305                	srli	a4,a4,0x1
ffffffffc02006b4:	8ff9                	and	a5,a5,a4
    static size_t tick_s=0;//计数器
    static size_t num1=0;//打印次数
    switch (cause) {
ffffffffc02006b6:	472d                	li	a4,11
ffffffffc02006b8:	08f76663          	bltu	a4,a5,ffffffffc0200744 <interrupt_handler+0x98>
ffffffffc02006bc:	00001717          	auipc	a4,0x1
ffffffffc02006c0:	06070713          	addi	a4,a4,96 # ffffffffc020171c <commands+0x1bc>
ffffffffc02006c4:	078a                	slli	a5,a5,0x2
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	439c                	lw	a5,0(a5)
ffffffffc02006ca:	97ba                	add	a5,a5,a4
ffffffffc02006cc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ce:	00001517          	auipc	a0,0x1
ffffffffc02006d2:	0e250513          	addi	a0,a0,226 # ffffffffc02017b0 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	0b650513          	addi	a0,a0,182 # ffffffffc0201790 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	06a50513          	addi	a0,a0,106 # ffffffffc0201750 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	0de50513          	addi	a0,a0,222 # ffffffffc02017d0 <commands+0x270>
ffffffffc02006fa:	9bdff06f          	j	ffffffffc02000b6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006fe:	1141                	addi	sp,sp,-16
ffffffffc0200700:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200702:	d3fff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
            ticks++;
ffffffffc0200706:	00006717          	auipc	a4,0x6
ffffffffc020070a:	de270713          	addi	a4,a4,-542 # ffffffffc02064e8 <ticks>
ffffffffc020070e:	631c                	ld	a5,0(a4)
ffffffffc0200710:	0785                	addi	a5,a5,1
ffffffffc0200712:	00006697          	auipc	a3,0x6
ffffffffc0200716:	dcf6bb23          	sd	a5,-554(a3) # ffffffffc02064e8 <ticks>

            if(ticks % TICK_NUM == 0){
ffffffffc020071a:	631c                	ld	a5,0(a4)
ffffffffc020071c:	06400713          	li	a4,100
ffffffffc0200720:	02e7f7b3          	remu	a5,a5,a4
ffffffffc0200724:	c395                	beqz	a5,ffffffffc0200748 <interrupt_handler+0x9c>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
ffffffffc0200728:	0141                	addi	sp,sp,16
ffffffffc020072a:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	0cc50513          	addi	a0,a0,204 # ffffffffc02017f8 <commands+0x298>
ffffffffc0200734:	983ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200738:	00001517          	auipc	a0,0x1
ffffffffc020073c:	03850513          	addi	a0,a0,56 # ffffffffc0201770 <commands+0x210>
ffffffffc0200740:	977ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200744:	f07ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200748:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020074a:	06400593          	li	a1,100
ffffffffc020074e:	00001517          	auipc	a0,0x1
ffffffffc0200752:	09a50513          	addi	a0,a0,154 # ffffffffc02017e8 <commands+0x288>
}
ffffffffc0200756:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200758:	95fff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020075c <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020075c:	11853783          	ld	a5,280(a0)
ffffffffc0200760:	0007c863          	bltz	a5,ffffffffc0200770 <trap+0x14>
    switch (tf->cause) {
ffffffffc0200764:	472d                	li	a4,11
ffffffffc0200766:	00f76363          	bltu	a4,a5,ffffffffc020076c <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc020076a:	8082                	ret
            print_trapframe(tf);
ffffffffc020076c:	edfff06f          	j	ffffffffc020064a <print_trapframe>
        interrupt_handler(tf);
ffffffffc0200770:	f3dff06f          	j	ffffffffc02006ac <interrupt_handler>

ffffffffc0200774 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200774:	14011073          	csrw	sscratch,sp
ffffffffc0200778:	712d                	addi	sp,sp,-288
ffffffffc020077a:	e002                	sd	zero,0(sp)
ffffffffc020077c:	e406                	sd	ra,8(sp)
ffffffffc020077e:	ec0e                	sd	gp,24(sp)
ffffffffc0200780:	f012                	sd	tp,32(sp)
ffffffffc0200782:	f416                	sd	t0,40(sp)
ffffffffc0200784:	f81a                	sd	t1,48(sp)
ffffffffc0200786:	fc1e                	sd	t2,56(sp)
ffffffffc0200788:	e0a2                	sd	s0,64(sp)
ffffffffc020078a:	e4a6                	sd	s1,72(sp)
ffffffffc020078c:	e8aa                	sd	a0,80(sp)
ffffffffc020078e:	ecae                	sd	a1,88(sp)
ffffffffc0200790:	f0b2                	sd	a2,96(sp)
ffffffffc0200792:	f4b6                	sd	a3,104(sp)
ffffffffc0200794:	f8ba                	sd	a4,112(sp)
ffffffffc0200796:	fcbe                	sd	a5,120(sp)
ffffffffc0200798:	e142                	sd	a6,128(sp)
ffffffffc020079a:	e546                	sd	a7,136(sp)
ffffffffc020079c:	e94a                	sd	s2,144(sp)
ffffffffc020079e:	ed4e                	sd	s3,152(sp)
ffffffffc02007a0:	f152                	sd	s4,160(sp)
ffffffffc02007a2:	f556                	sd	s5,168(sp)
ffffffffc02007a4:	f95a                	sd	s6,176(sp)
ffffffffc02007a6:	fd5e                	sd	s7,184(sp)
ffffffffc02007a8:	e1e2                	sd	s8,192(sp)
ffffffffc02007aa:	e5e6                	sd	s9,200(sp)
ffffffffc02007ac:	e9ea                	sd	s10,208(sp)
ffffffffc02007ae:	edee                	sd	s11,216(sp)
ffffffffc02007b0:	f1f2                	sd	t3,224(sp)
ffffffffc02007b2:	f5f6                	sd	t4,232(sp)
ffffffffc02007b4:	f9fa                	sd	t5,240(sp)
ffffffffc02007b6:	fdfe                	sd	t6,248(sp)
ffffffffc02007b8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007bc:	100024f3          	csrr	s1,sstatus
ffffffffc02007c0:	14102973          	csrr	s2,sepc
ffffffffc02007c4:	143029f3          	csrr	s3,stval
ffffffffc02007c8:	14202a73          	csrr	s4,scause
ffffffffc02007cc:	e822                	sd	s0,16(sp)
ffffffffc02007ce:	e226                	sd	s1,256(sp)
ffffffffc02007d0:	e64a                	sd	s2,264(sp)
ffffffffc02007d2:	ea4e                	sd	s3,272(sp)
ffffffffc02007d4:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007d6:	850a                	mv	a0,sp
    jal trap
ffffffffc02007d8:	f85ff0ef          	jal	ra,ffffffffc020075c <trap>

ffffffffc02007dc <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007dc:	6492                	ld	s1,256(sp)
ffffffffc02007de:	6932                	ld	s2,264(sp)
ffffffffc02007e0:	10049073          	csrw	sstatus,s1
ffffffffc02007e4:	14191073          	csrw	sepc,s2
ffffffffc02007e8:	60a2                	ld	ra,8(sp)
ffffffffc02007ea:	61e2                	ld	gp,24(sp)
ffffffffc02007ec:	7202                	ld	tp,32(sp)
ffffffffc02007ee:	72a2                	ld	t0,40(sp)
ffffffffc02007f0:	7342                	ld	t1,48(sp)
ffffffffc02007f2:	73e2                	ld	t2,56(sp)
ffffffffc02007f4:	6406                	ld	s0,64(sp)
ffffffffc02007f6:	64a6                	ld	s1,72(sp)
ffffffffc02007f8:	6546                	ld	a0,80(sp)
ffffffffc02007fa:	65e6                	ld	a1,88(sp)
ffffffffc02007fc:	7606                	ld	a2,96(sp)
ffffffffc02007fe:	76a6                	ld	a3,104(sp)
ffffffffc0200800:	7746                	ld	a4,112(sp)
ffffffffc0200802:	77e6                	ld	a5,120(sp)
ffffffffc0200804:	680a                	ld	a6,128(sp)
ffffffffc0200806:	68aa                	ld	a7,136(sp)
ffffffffc0200808:	694a                	ld	s2,144(sp)
ffffffffc020080a:	69ea                	ld	s3,152(sp)
ffffffffc020080c:	7a0a                	ld	s4,160(sp)
ffffffffc020080e:	7aaa                	ld	s5,168(sp)
ffffffffc0200810:	7b4a                	ld	s6,176(sp)
ffffffffc0200812:	7bea                	ld	s7,184(sp)
ffffffffc0200814:	6c0e                	ld	s8,192(sp)
ffffffffc0200816:	6cae                	ld	s9,200(sp)
ffffffffc0200818:	6d4e                	ld	s10,208(sp)
ffffffffc020081a:	6dee                	ld	s11,216(sp)
ffffffffc020081c:	7e0e                	ld	t3,224(sp)
ffffffffc020081e:	7eae                	ld	t4,232(sp)
ffffffffc0200820:	7f4e                	ld	t5,240(sp)
ffffffffc0200822:	7fee                	ld	t6,248(sp)
ffffffffc0200824:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200826:	10200073          	sret

ffffffffc020082a <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020082a:	100027f3          	csrr	a5,sstatus
ffffffffc020082e:	8b89                	andi	a5,a5,2
ffffffffc0200830:	eb89                	bnez	a5,ffffffffc0200842 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200832:	00006797          	auipc	a5,0x6
ffffffffc0200836:	cde78793          	addi	a5,a5,-802 # ffffffffc0206510 <pmm_manager>
ffffffffc020083a:	639c                	ld	a5,0(a5)
ffffffffc020083c:	0187b303          	ld	t1,24(a5)
ffffffffc0200840:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc0200842:	1141                	addi	sp,sp,-16
ffffffffc0200844:	e406                	sd	ra,8(sp)
ffffffffc0200846:	e022                	sd	s0,0(sp)
ffffffffc0200848:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020084a:	c1bff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020084e:	00006797          	auipc	a5,0x6
ffffffffc0200852:	cc278793          	addi	a5,a5,-830 # ffffffffc0206510 <pmm_manager>
ffffffffc0200856:	639c                	ld	a5,0(a5)
ffffffffc0200858:	8522                	mv	a0,s0
ffffffffc020085a:	6f9c                	ld	a5,24(a5)
ffffffffc020085c:	9782                	jalr	a5
ffffffffc020085e:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200860:	bffff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200864:	8522                	mv	a0,s0
ffffffffc0200866:	60a2                	ld	ra,8(sp)
ffffffffc0200868:	6402                	ld	s0,0(sp)
ffffffffc020086a:	0141                	addi	sp,sp,16
ffffffffc020086c:	8082                	ret

ffffffffc020086e <pmm_init>:
    pmm_manager = &slub_pmm_manager;
ffffffffc020086e:	00001797          	auipc	a5,0x1
ffffffffc0200872:	50a78793          	addi	a5,a5,1290 # ffffffffc0201d78 <slub_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200876:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200878:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020087a:	00001517          	auipc	a0,0x1
ffffffffc020087e:	31650513          	addi	a0,a0,790 # ffffffffc0201b90 <commands+0x630>
void pmm_init(void) {
ffffffffc0200882:	ec06                	sd	ra,24(sp)
    pmm_manager = &slub_pmm_manager;
ffffffffc0200884:	00006717          	auipc	a4,0x6
ffffffffc0200888:	c8f73623          	sd	a5,-884(a4) # ffffffffc0206510 <pmm_manager>
void pmm_init(void) {
ffffffffc020088c:	e822                	sd	s0,16(sp)
ffffffffc020088e:	e426                	sd	s1,8(sp)
    pmm_manager = &slub_pmm_manager;
ffffffffc0200890:	00006417          	auipc	s0,0x6
ffffffffc0200894:	c8040413          	addi	s0,s0,-896 # ffffffffc0206510 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200898:	81fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc020089c:	601c                	ld	a5,0(s0)
ffffffffc020089e:	679c                	ld	a5,8(a5)
ffffffffc02008a0:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02008a2:	57f5                	li	a5,-3
ffffffffc02008a4:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02008a6:	00001517          	auipc	a0,0x1
ffffffffc02008aa:	30250513          	addi	a0,a0,770 # ffffffffc0201ba8 <commands+0x648>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02008ae:	00006717          	auipc	a4,0x6
ffffffffc02008b2:	c6f73523          	sd	a5,-918(a4) # ffffffffc0206518 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02008b6:	801ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02008ba:	46c5                	li	a3,17
ffffffffc02008bc:	06ee                	slli	a3,a3,0x1b
ffffffffc02008be:	40100613          	li	a2,1025
ffffffffc02008c2:	16fd                	addi	a3,a3,-1
ffffffffc02008c4:	0656                	slli	a2,a2,0x15
ffffffffc02008c6:	07e005b7          	lui	a1,0x7e00
ffffffffc02008ca:	00001517          	auipc	a0,0x1
ffffffffc02008ce:	2f650513          	addi	a0,a0,758 # ffffffffc0201bc0 <commands+0x660>
ffffffffc02008d2:	fe4ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02008d6:	777d                	lui	a4,0xfffff
ffffffffc02008d8:	00007797          	auipc	a5,0x7
ffffffffc02008dc:	c4f78793          	addi	a5,a5,-945 # ffffffffc0207527 <end+0xfff>
ffffffffc02008e0:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02008e2:	00088737          	lui	a4,0x88
ffffffffc02008e6:	00006697          	auipc	a3,0x6
ffffffffc02008ea:	bee6b523          	sd	a4,-1046(a3) # ffffffffc02064d0 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02008ee:	4601                	li	a2,0
ffffffffc02008f0:	00006717          	auipc	a4,0x6
ffffffffc02008f4:	c2f73823          	sd	a5,-976(a4) # ffffffffc0206520 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02008f8:	4681                	li	a3,0
ffffffffc02008fa:	00006897          	auipc	a7,0x6
ffffffffc02008fe:	bd688893          	addi	a7,a7,-1066 # ffffffffc02064d0 <npage>
ffffffffc0200902:	00006597          	auipc	a1,0x6
ffffffffc0200906:	c1e58593          	addi	a1,a1,-994 # ffffffffc0206520 <pages>
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020090a:	4805                	li	a6,1
ffffffffc020090c:	fff80537          	lui	a0,0xfff80
ffffffffc0200910:	a011                	j	ffffffffc0200914 <pmm_init+0xa6>
ffffffffc0200912:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc0200914:	97b2                	add	a5,a5,a2
ffffffffc0200916:	07a1                	addi	a5,a5,8
ffffffffc0200918:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020091c:	0008b703          	ld	a4,0(a7)
ffffffffc0200920:	0685                	addi	a3,a3,1
ffffffffc0200922:	02860613          	addi	a2,a2,40
ffffffffc0200926:	00a707b3          	add	a5,a4,a0
ffffffffc020092a:	fef6e4e3          	bltu	a3,a5,ffffffffc0200912 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020092e:	6190                	ld	a2,0(a1)
ffffffffc0200930:	00271793          	slli	a5,a4,0x2
ffffffffc0200934:	97ba                	add	a5,a5,a4
ffffffffc0200936:	fec006b7          	lui	a3,0xfec00
ffffffffc020093a:	078e                	slli	a5,a5,0x3
ffffffffc020093c:	96b2                	add	a3,a3,a2
ffffffffc020093e:	96be                	add	a3,a3,a5
ffffffffc0200940:	c02007b7          	lui	a5,0xc0200
ffffffffc0200944:	08f6e863          	bltu	a3,a5,ffffffffc02009d4 <pmm_init+0x166>
ffffffffc0200948:	00006497          	auipc	s1,0x6
ffffffffc020094c:	bd048493          	addi	s1,s1,-1072 # ffffffffc0206518 <va_pa_offset>
ffffffffc0200950:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc0200952:	45c5                	li	a1,17
ffffffffc0200954:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200956:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc0200958:	04b6e963          	bltu	a3,a1,ffffffffc02009aa <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020095c:	601c                	ld	a5,0(s0)
ffffffffc020095e:	7b9c                	ld	a5,48(a5)
ffffffffc0200960:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200962:	00001517          	auipc	a0,0x1
ffffffffc0200966:	2f650513          	addi	a0,a0,758 # ffffffffc0201c58 <commands+0x6f8>
ffffffffc020096a:	f4cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc020096e:	00004697          	auipc	a3,0x4
ffffffffc0200972:	69268693          	addi	a3,a3,1682 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200976:	00006797          	auipc	a5,0x6
ffffffffc020097a:	b6d7b123          	sd	a3,-1182(a5) # ffffffffc02064d8 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc020097e:	c02007b7          	lui	a5,0xc0200
ffffffffc0200982:	06f6e563          	bltu	a3,a5,ffffffffc02009ec <pmm_init+0x17e>
ffffffffc0200986:	609c                	ld	a5,0(s1)
}
ffffffffc0200988:	6442                	ld	s0,16(sp)
ffffffffc020098a:	60e2                	ld	ra,24(sp)
ffffffffc020098c:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020098e:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc0200990:	8e9d                	sub	a3,a3,a5
ffffffffc0200992:	00006797          	auipc	a5,0x6
ffffffffc0200996:	b6d7bb23          	sd	a3,-1162(a5) # ffffffffc0206508 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020099a:	00001517          	auipc	a0,0x1
ffffffffc020099e:	2de50513          	addi	a0,a0,734 # ffffffffc0201c78 <commands+0x718>
ffffffffc02009a2:	8636                	mv	a2,a3
}
ffffffffc02009a4:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02009a6:	f10ff06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02009aa:	6785                	lui	a5,0x1
ffffffffc02009ac:	17fd                	addi	a5,a5,-1
ffffffffc02009ae:	96be                	add	a3,a3,a5
ffffffffc02009b0:	77fd                	lui	a5,0xfffff
ffffffffc02009b2:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02009b4:	00c6d793          	srli	a5,a3,0xc
ffffffffc02009b8:	04e7f663          	bleu	a4,a5,ffffffffc0200a04 <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc02009bc:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02009be:	97aa                	add	a5,a5,a0
ffffffffc02009c0:	00279513          	slli	a0,a5,0x2
ffffffffc02009c4:	953e                	add	a0,a0,a5
ffffffffc02009c6:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02009c8:	8d95                	sub	a1,a1,a3
ffffffffc02009ca:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02009cc:	81b1                	srli	a1,a1,0xc
ffffffffc02009ce:	9532                	add	a0,a0,a2
ffffffffc02009d0:	9782                	jalr	a5
ffffffffc02009d2:	b769                	j	ffffffffc020095c <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02009d4:	00001617          	auipc	a2,0x1
ffffffffc02009d8:	21c60613          	addi	a2,a2,540 # ffffffffc0201bf0 <commands+0x690>
ffffffffc02009dc:	07000593          	li	a1,112
ffffffffc02009e0:	00001517          	auipc	a0,0x1
ffffffffc02009e4:	23850513          	addi	a0,a0,568 # ffffffffc0201c18 <commands+0x6b8>
ffffffffc02009e8:	9c5ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02009ec:	00001617          	auipc	a2,0x1
ffffffffc02009f0:	20460613          	addi	a2,a2,516 # ffffffffc0201bf0 <commands+0x690>
ffffffffc02009f4:	08b00593          	li	a1,139
ffffffffc02009f8:	00001517          	auipc	a0,0x1
ffffffffc02009fc:	22050513          	addi	a0,a0,544 # ffffffffc0201c18 <commands+0x6b8>
ffffffffc0200a00:	9adff0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200a04:	00001617          	auipc	a2,0x1
ffffffffc0200a08:	22460613          	addi	a2,a2,548 # ffffffffc0201c28 <commands+0x6c8>
ffffffffc0200a0c:	06b00593          	li	a1,107
ffffffffc0200a10:	00001517          	auipc	a0,0x1
ffffffffc0200a14:	23850513          	addi	a0,a0,568 # ffffffffc0201c48 <commands+0x6e8>
ffffffffc0200a18:	995ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200a1c <slub_nr_free_pages>:
}

static size_t
slub_nr_free_pages(void) {
	return nr_free;
}
ffffffffc0200a1c:	00006517          	auipc	a0,0x6
ffffffffc0200a20:	ae456503          	lwu	a0,-1308(a0) # ffffffffc0206500 <free_area+0x10>
ffffffffc0200a24:	8082                	ret

ffffffffc0200a26 <slub_check>:

static void
slub_check(void) {

}
ffffffffc0200a26:	8082                	ret

ffffffffc0200a28 <slub_alloc_pages>:
}

static struct Page *
slub_alloc_pages(size_t n) {
	return NULL;
}
ffffffffc0200a28:	4501                	li	a0,0
ffffffffc0200a2a:	8082                	ret

ffffffffc0200a2c <slub_free_pages>:
	 for (size_t i = 0; i < n; i++) {
ffffffffc0200a2c:	cda1                	beqz	a1,ffffffffc0200a84 <slub_free_pages+0x58>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200a2e:	651c                	ld	a5,8(a0)
        assert(!PageReserved(page));
ffffffffc0200a30:	8b85                	andi	a5,a5,1
ffffffffc0200a32:	e3b5                	bnez	a5,ffffffffc0200a96 <slub_free_pages+0x6a>
ffffffffc0200a34:	00006817          	auipc	a6,0x6
ffffffffc0200a38:	abc80813          	addi	a6,a6,-1348 # ffffffffc02064f0 <free_area>
ffffffffc0200a3c:	01082603          	lw	a2,16(a6)
ffffffffc0200a40:	00083783          	ld	a5,0(a6)
ffffffffc0200a44:	0561                	addi	a0,a0,24
	 for (size_t i = 0; i < n; i++) {
ffffffffc0200a46:	4701                	li	a4,0
ffffffffc0200a48:	2605                	addiw	a2,a2,1
ffffffffc0200a4a:	a031                	j	ffffffffc0200a56 <slub_free_pages+0x2a>
ffffffffc0200a4c:	6d14                	ld	a3,24(a0)
ffffffffc0200a4e:	02850513          	addi	a0,a0,40
        assert(!PageReserved(page));
ffffffffc0200a52:	8a85                	andi	a3,a3,1
ffffffffc0200a54:	ea8d                	bnez	a3,ffffffffc0200a86 <slub_free_pages+0x5a>
        page->property += 1;
ffffffffc0200a56:	ff852683          	lw	a3,-8(a0)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200a5a:	e788                	sd	a0,8(a5)
ffffffffc0200a5c:	00e608bb          	addw	a7,a2,a4
ffffffffc0200a60:	2685                	addiw	a3,a3,1
    elm->next = next;
    elm->prev = prev;
ffffffffc0200a62:	e11c                	sd	a5,0(a0)
    elm->next = next;
ffffffffc0200a64:	01053423          	sd	a6,8(a0)
ffffffffc0200a68:	fed52c23          	sw	a3,-8(a0)
	 for (size_t i = 0; i < n; i++) {
ffffffffc0200a6c:	0705                	addi	a4,a4,1
        list_add_before(&free_list, &(page->page_link));
ffffffffc0200a6e:	87aa                	mv	a5,a0
	 for (size_t i = 0; i < n; i++) {
ffffffffc0200a70:	fce59ee3          	bne	a1,a4,ffffffffc0200a4c <slub_free_pages+0x20>
ffffffffc0200a74:	00006797          	auipc	a5,0x6
ffffffffc0200a78:	a6a7be23          	sd	a0,-1412(a5) # ffffffffc02064f0 <free_area>
ffffffffc0200a7c:	00006797          	auipc	a5,0x6
ffffffffc0200a80:	a917a223          	sw	a7,-1404(a5) # ffffffffc0206500 <free_area+0x10>
ffffffffc0200a84:	8082                	ret
ffffffffc0200a86:	00006717          	auipc	a4,0x6
ffffffffc0200a8a:	a6f73523          	sd	a5,-1430(a4) # ffffffffc02064f0 <free_area>
ffffffffc0200a8e:	00006797          	auipc	a5,0x6
ffffffffc0200a92:	a717a923          	sw	a7,-1422(a5) # ffffffffc0206500 <free_area+0x10>
slub_free_pages(struct Page *base, size_t n){
ffffffffc0200a96:	1141                	addi	sp,sp,-16
        assert(!PageReserved(page));
ffffffffc0200a98:	00001697          	auipc	a3,0x1
ffffffffc0200a9c:	27868693          	addi	a3,a3,632 # ffffffffc0201d10 <commands+0x7b0>
ffffffffc0200aa0:	00001617          	auipc	a2,0x1
ffffffffc0200aa4:	28860613          	addi	a2,a2,648 # ffffffffc0201d28 <commands+0x7c8>
ffffffffc0200aa8:	13300593          	li	a1,307
ffffffffc0200aac:	00001517          	auipc	a0,0x1
ffffffffc0200ab0:	25450513          	addi	a0,a0,596 # ffffffffc0201d00 <commands+0x7a0>
slub_free_pages(struct Page *base, size_t n){
ffffffffc0200ab4:	e406                	sd	ra,8(sp)
        assert(!PageReserved(page));
ffffffffc0200ab6:	8f7ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200aba <slub_init_memmap>:
	for (size_t i = 0; i < size; i++) {
ffffffffc0200aba:	cda1                	beqz	a1,ffffffffc0200b12 <slub_init_memmap+0x58>
ffffffffc0200abc:	651c                	ld	a5,8(a0)
        assert(PageReserved(page));
ffffffffc0200abe:	8b85                	andi	a5,a5,1
ffffffffc0200ac0:	cbb1                	beqz	a5,ffffffffc0200b14 <slub_init_memmap+0x5a>
ffffffffc0200ac2:	0561                	addi	a0,a0,24
	for (size_t i = 0; i < size; i++) {
ffffffffc0200ac4:	4681                	li	a3,0
ffffffffc0200ac6:	00006717          	auipc	a4,0x6
ffffffffc0200aca:	a2a70713          	addi	a4,a4,-1494 # ffffffffc02064f0 <free_area>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200ace:	5379                	li	t1,-2
        page->property = 1;
ffffffffc0200ad0:	4885                	li	a7,1
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200ad2:	4809                	li	a6,2
ffffffffc0200ad4:	a031                	j	ffffffffc0200ae0 <slub_init_memmap+0x26>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200ad6:	6d1c                	ld	a5,24(a0)
ffffffffc0200ad8:	02850513          	addi	a0,a0,40
        assert(PageReserved(page));
ffffffffc0200adc:	8b85                	andi	a5,a5,1
ffffffffc0200ade:	cb9d                	beqz	a5,ffffffffc0200b14 <slub_init_memmap+0x5a>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200ae0:	ff050793          	addi	a5,a0,-16
ffffffffc0200ae4:	6067b02f          	amoand.d	zero,t1,(a5)
        page->property = 1;
ffffffffc0200ae8:	ff152c23          	sw	a7,-8(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200aec:	4107b02f          	amoor.d	zero,a6,(a5)
        nr_free++;
ffffffffc0200af0:	4b1c                	lw	a5,16(a4)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200af2:	6310                	ld	a2,0(a4)
    prev->next = next->prev = elm;
ffffffffc0200af4:	00006e17          	auipc	t3,0x6
ffffffffc0200af8:	9eae3e23          	sd	a0,-1540(t3) # ffffffffc02064f0 <free_area>
ffffffffc0200afc:	2785                	addiw	a5,a5,1
ffffffffc0200afe:	00006e17          	auipc	t3,0x6
ffffffffc0200b02:	a0fe2123          	sw	a5,-1534(t3) # ffffffffc0206500 <free_area+0x10>
ffffffffc0200b06:	e608                	sd	a0,8(a2)
    elm->next = next;
ffffffffc0200b08:	e518                	sd	a4,8(a0)
    elm->prev = prev;
ffffffffc0200b0a:	e110                	sd	a2,0(a0)
	for (size_t i = 0; i < size; i++) {
ffffffffc0200b0c:	0685                	addi	a3,a3,1
ffffffffc0200b0e:	fcd594e3          	bne	a1,a3,ffffffffc0200ad6 <slub_init_memmap+0x1c>
ffffffffc0200b12:	8082                	ret
static void slub_init_memmap(struct Page *base, size_t size) {
ffffffffc0200b14:	1141                	addi	sp,sp,-16
        assert(PageReserved(page));
ffffffffc0200b16:	00001697          	auipc	a3,0x1
ffffffffc0200b1a:	24a68693          	addi	a3,a3,586 # ffffffffc0201d60 <commands+0x800>
ffffffffc0200b1e:	00001617          	auipc	a2,0x1
ffffffffc0200b22:	20a60613          	addi	a2,a2,522 # ffffffffc0201d28 <commands+0x7c8>
ffffffffc0200b26:	11c00593          	li	a1,284
ffffffffc0200b2a:	00001517          	auipc	a0,0x1
ffffffffc0200b2e:	1d650513          	addi	a0,a0,470 # ffffffffc0201d00 <commands+0x7a0>
static void slub_init_memmap(struct Page *base, size_t size) {
ffffffffc0200b32:	e406                	sd	ra,8(sp)
        assert(PageReserved(page));
ffffffffc0200b34:	879ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200b38 <kmem_cache_alloc>:
{
ffffffffc0200b38:	715d                	addi	sp,sp,-80
ffffffffc0200b3a:	e0a2                	sd	s0,64(sp)
    return list->next == list;
ffffffffc0200b3c:	6d00                	ld	s0,24(a0)
ffffffffc0200b3e:	fc26                	sd	s1,56(sp)
ffffffffc0200b40:	f84a                	sd	s2,48(sp)
ffffffffc0200b42:	f44e                	sd	s3,40(sp)
ffffffffc0200b44:	00001797          	auipc	a5,0x1
ffffffffc0200b48:	4cc78793          	addi	a5,a5,1228 # ffffffffc0202010 <nbase>
ffffffffc0200b4c:	e486                	sd	ra,72(sp)
ffffffffc0200b4e:	f052                	sd	s4,32(sp)
ffffffffc0200b50:	ec56                	sd	s5,24(sp)
ffffffffc0200b52:	e85a                	sd	s6,16(sp)
ffffffffc0200b54:	e45e                	sd	s7,8(sp)
	if(!list_empty(&(p->slubs_part)))
ffffffffc0200b56:	01050913          	addi	s2,a0,16
{
ffffffffc0200b5a:	84aa                	mv	s1,a0
ffffffffc0200b5c:	0007b983          	ld	s3,0(a5)
	if(!list_empty(&(p->slubs_part)))
ffffffffc0200b60:	0a890b63          	beq	s2,s0,ffffffffc0200c16 <kmem_cache_alloc+0xde>
ffffffffc0200b64:	00006797          	auipc	a5,0x6
ffffffffc0200b68:	96c78793          	addi	a5,a5,-1684 # ffffffffc02064d0 <npage>
ffffffffc0200b6c:	638c                	ld	a1,0(a5)
ffffffffc0200b6e:	00006797          	auipc	a5,0x6
ffffffffc0200b72:	9b278793          	addi	a5,a5,-1614 # ffffffffc0206520 <pages>
ffffffffc0200b76:	639c                	ld	a5,0(a5)
    return listelm->next;
ffffffffc0200b78:	00001a17          	auipc	s4,0x1
ffffffffc0200b7c:	158a0a13          	addi	s4,s4,344 # ffffffffc0201cd0 <commands+0x770>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b80:	000a3703          	ld	a4,0(s4)
	slub_t *slub = LE2SLUB(le, page_link);
ffffffffc0200b84:	fe840693          	addi	a3,s0,-24
ffffffffc0200b88:	8e9d                	sub	a3,a3,a5
ffffffffc0200b8a:	868d                	srai	a3,a3,0x3
ffffffffc0200b8c:	02e686b3          	mul	a3,a3,a4
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b90:	641c                	ld	a5,8(s0)
ffffffffc0200b92:	6018                	ld	a4,0(s0)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200b94:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200b96:	e398                	sd	a4,0(a5)
	void *kva = SLUB2KVA(slub);
ffffffffc0200b98:	57fd                	li	a5,-1
ffffffffc0200b9a:	83b1                	srli	a5,a5,0xc
ffffffffc0200b9c:	96ce                	add	a3,a3,s3
ffffffffc0200b9e:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ba0:	06b2                	slli	a3,a3,0xc
ffffffffc0200ba2:	14b7fc63          	bleu	a1,a5,ffffffffc0200cfa <kmem_cache_alloc+0x1c2>
	void *obj = buf + slub->freeoff * p->objsize;
ffffffffc0200ba6:	ffa45703          	lhu	a4,-6(s0)
ffffffffc0200baa:	0304d503          	lhu	a0,48(s1)
	slub->used++;
ffffffffc0200bae:	ff845783          	lhu	a5,-8(s0)
	void *kva = SLUB2KVA(slub);
ffffffffc0200bb2:	00006617          	auipc	a2,0x6
ffffffffc0200bb6:	96660613          	addi	a2,a2,-1690 # ffffffffc0206518 <va_pa_offset>
	void *obj = buf + slub->freeoff * p->objsize;
ffffffffc0200bba:	02e5053b          	mulw	a0,a0,a4
	void *kva = SLUB2KVA(slub);
ffffffffc0200bbe:	6210                	ld	a2,0(a2)
	slub->used++;
ffffffffc0200bc0:	2785                	addiw	a5,a5,1
ffffffffc0200bc2:	17c2                	slli	a5,a5,0x30
	void *kva = SLUB2KVA(slub);
ffffffffc0200bc4:	96b2                	add	a3,a3,a2
	slub->used++;
ffffffffc0200bc6:	93c1                	srli	a5,a5,0x30
	slub->freeoff = bufctl[slub->freeoff];
ffffffffc0200bc8:	0706                	slli	a4,a4,0x1
	void *buf = bufctl + p->num;
ffffffffc0200bca:	0324d603          	lhu	a2,50(s1)
	slub->freeoff = bufctl[slub->freeoff];
ffffffffc0200bce:	9736                	add	a4,a4,a3
	slub->used++;
ffffffffc0200bd0:	fef41c23          	sh	a5,-8(s0)
	slub->freeoff = bufctl[slub->freeoff];
ffffffffc0200bd4:	00075703          	lhu	a4,0(a4)
	void *buf = bufctl + p->num;
ffffffffc0200bd8:	00161593          	slli	a1,a2,0x1
	void *obj = buf + slub->freeoff * p->objsize;
ffffffffc0200bdc:	952e                	add	a0,a0,a1
	slub->freeoff = bufctl[slub->freeoff];
ffffffffc0200bde:	fee41d23          	sh	a4,-6(s0)
	void *obj = buf + slub->freeoff * p->objsize;
ffffffffc0200be2:	9536                	add	a0,a0,a3
	if(slub->used == p->num)
ffffffffc0200be4:	02f60363          	beq	a2,a5,ffffffffc0200c0a <kmem_cache_alloc+0xd2>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200be8:	6c9c                	ld	a5,24(s1)
    prev->next = next->prev = elm;
ffffffffc0200bea:	e380                	sd	s0,0(a5)
ffffffffc0200bec:	ec80                	sd	s0,24(s1)
    elm->next = next;
ffffffffc0200bee:	e41c                	sd	a5,8(s0)
    elm->prev = prev;
ffffffffc0200bf0:	01243023          	sd	s2,0(s0)
}
ffffffffc0200bf4:	60a6                	ld	ra,72(sp)
ffffffffc0200bf6:	6406                	ld	s0,64(sp)
ffffffffc0200bf8:	74e2                	ld	s1,56(sp)
ffffffffc0200bfa:	7942                	ld	s2,48(sp)
ffffffffc0200bfc:	79a2                	ld	s3,40(sp)
ffffffffc0200bfe:	7a02                	ld	s4,32(sp)
ffffffffc0200c00:	6ae2                	ld	s5,24(sp)
ffffffffc0200c02:	6b42                	ld	s6,16(sp)
ffffffffc0200c04:	6ba2                	ld	s7,8(sp)
ffffffffc0200c06:	6161                	addi	sp,sp,80
ffffffffc0200c08:	8082                	ret
    __list_add(elm, listelm, listelm->next);
ffffffffc0200c0a:	649c                	ld	a5,8(s1)
    prev->next = next->prev = elm;
ffffffffc0200c0c:	e380                	sd	s0,0(a5)
ffffffffc0200c0e:	e480                	sd	s0,8(s1)
    elm->next = next;
ffffffffc0200c10:	e41c                	sd	a5,8(s0)
    elm->prev = prev;
ffffffffc0200c12:	e004                	sd	s1,0(s0)
ffffffffc0200c14:	b7c5                	j	ffffffffc0200bf4 <kmem_cache_alloc+0xbc>
    return list->next == list;
ffffffffc0200c16:	7500                	ld	s0,40(a0)
		if(list_empty(&(p->slubs_free)) && kmem_cache_grow(p) == NULL)
ffffffffc0200c18:	02050793          	addi	a5,a0,32
ffffffffc0200c1c:	f4f414e3          	bne	s0,a5,ffffffffc0200b64 <kmem_cache_alloc+0x2c>
	struct Page *page = alloc_page();
ffffffffc0200c20:	4505                	li	a0,1
ffffffffc0200c22:	c09ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c26:	00006a97          	auipc	s5,0x6
ffffffffc0200c2a:	8faa8a93          	addi	s5,s5,-1798 # ffffffffc0206520 <pages>
ffffffffc0200c2e:	000ab783          	ld	a5,0(s5)
ffffffffc0200c32:	00001a17          	auipc	s4,0x1
ffffffffc0200c36:	09ea0a13          	addi	s4,s4,158 # ffffffffc0201cd0 <commands+0x770>
ffffffffc0200c3a:	000a3703          	ld	a4,0(s4)
ffffffffc0200c3e:	40f506b3          	sub	a3,a0,a5
ffffffffc0200c42:	868d                	srai	a3,a3,0x3
ffffffffc0200c44:	02e686b3          	mul	a3,a3,a4
	void *kva = KADDR(page2pa(page));
ffffffffc0200c48:	00006b17          	auipc	s6,0x6
ffffffffc0200c4c:	888b0b13          	addi	s6,s6,-1912 # ffffffffc02064d0 <npage>
ffffffffc0200c50:	577d                	li	a4,-1
ffffffffc0200c52:	000b3583          	ld	a1,0(s6)
ffffffffc0200c56:	8331                	srli	a4,a4,0xc
ffffffffc0200c58:	96ce                	add	a3,a3,s3
ffffffffc0200c5a:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c5c:	06b2                	slli	a3,a3,0xc
ffffffffc0200c5e:	0ab77a63          	bleu	a1,a4,ffffffffc0200d12 <kmem_cache_alloc+0x1da>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200c62:	7498                	ld	a4,40(s1)
ffffffffc0200c64:	00006617          	auipc	a2,0x6
ffffffffc0200c68:	8b460613          	addi	a2,a2,-1868 # ffffffffc0206518 <va_pa_offset>
	slub->used = slub->freeoff = 0;
ffffffffc0200c6c:	00052823          	sw	zero,16(a0)
	void *kva = KADDR(page2pa(page));
ffffffffc0200c70:	00063883          	ld	a7,0(a2)
	slub->p = p;
ffffffffc0200c74:	e504                	sd	s1,8(a0)
	list_add(&(p->slubs_free), &(slub->slub_linklist));
ffffffffc0200c76:	01850813          	addi	a6,a0,24
    prev->next = next->prev = elm;
ffffffffc0200c7a:	01073023          	sd	a6,0(a4)
	for(int i = 1; i < p->num; i++)
ffffffffc0200c7e:	0324d603          	lhu	a2,50(s1)
ffffffffc0200c82:	0304b423          	sd	a6,40(s1)
	void *kva = KADDR(page2pa(page));
ffffffffc0200c86:	96c6                	add	a3,a3,a7
    elm->next = next;
ffffffffc0200c88:	f118                	sd	a4,32(a0)
    elm->prev = prev;
ffffffffc0200c8a:	ed00                	sd	s0,24(a0)
	for(int i = 1; i < p->num; i++)
ffffffffc0200c8c:	4705                	li	a4,1
	void *kva = KADDR(page2pa(page));
ffffffffc0200c8e:	8436                	mv	s0,a3
	for(int i = 1; i < p->num; i++)
ffffffffc0200c90:	00c77a63          	bleu	a2,a4,ffffffffc0200ca4 <kmem_cache_alloc+0x16c>
		bufctl[i-1] = i;
ffffffffc0200c94:	00e69023          	sh	a4,0(a3)
	for(int i = 1; i < p->num; i++)
ffffffffc0200c98:	0324d603          	lhu	a2,50(s1)
ffffffffc0200c9c:	2705                	addiw	a4,a4,1
ffffffffc0200c9e:	0689                	addi	a3,a3,2
ffffffffc0200ca0:	fec74ae3          	blt	a4,a2,ffffffffc0200c94 <kmem_cache_alloc+0x15c>
	bufctl[p->num-1] = -1;
ffffffffc0200ca4:	0606                	slli	a2,a2,0x1
	if (p->ctor)
ffffffffc0200ca6:	7c98                	ld	a4,56(s1)
	bufctl[p->num-1] = -1;
ffffffffc0200ca8:	9622                	add	a2,a2,s0
ffffffffc0200caa:	56fd                	li	a3,-1
ffffffffc0200cac:	fed61f23          	sh	a3,-2(a2)
	if (p->ctor)
ffffffffc0200cb0:	c339                	beqz	a4,ffffffffc0200cf6 <kmem_cache_alloc+0x1be>
	void *buf = bufctl + p->num;
ffffffffc0200cb2:	0324d683          	lhu	a3,50(s1)
		for(void *t = buf; t < buf + p->objsize * p->num; t += p->objsize)
ffffffffc0200cb6:	0304d603          	lhu	a2,48(s1)
	void *buf = bufctl + p->num;
ffffffffc0200cba:	00169513          	slli	a0,a3,0x1
		for(void *t = buf; t < buf + p->objsize * p->num; t += p->objsize)
ffffffffc0200cbe:	02d606bb          	mulw	a3,a2,a3
	void *buf = bufctl + p->num;
ffffffffc0200cc2:	942a                	add	s0,s0,a0
		for(void *t = buf; t < buf + p->objsize * p->num; t += p->objsize)
ffffffffc0200cc4:	8ba2                	mv	s7,s0
ffffffffc0200cc6:	96a2                	add	a3,a3,s0
ffffffffc0200cc8:	00d46463          	bltu	s0,a3,ffffffffc0200cd0 <kmem_cache_alloc+0x198>
ffffffffc0200ccc:	a02d                	j	ffffffffc0200cf6 <kmem_cache_alloc+0x1be>
ffffffffc0200cce:	7c98                	ld	a4,56(s1)
			p->ctor(t,p,p->objsize);
ffffffffc0200cd0:	855e                	mv	a0,s7
ffffffffc0200cd2:	85a6                	mv	a1,s1
ffffffffc0200cd4:	9702                	jalr	a4
		for(void *t = buf; t < buf + p->objsize * p->num; t += p->objsize)
ffffffffc0200cd6:	0304d603          	lhu	a2,48(s1)
ffffffffc0200cda:	0324d783          	lhu	a5,50(s1)
ffffffffc0200cde:	9bb2                	add	s7,s7,a2
ffffffffc0200ce0:	02c787bb          	mulw	a5,a5,a2
ffffffffc0200ce4:	97a2                	add	a5,a5,s0
ffffffffc0200ce6:	fefbe4e3          	bltu	s7,a5,ffffffffc0200cce <kmem_cache_alloc+0x196>
ffffffffc0200cea:	7480                	ld	s0,40(s1)
ffffffffc0200cec:	000b3583          	ld	a1,0(s6)
ffffffffc0200cf0:	000ab783          	ld	a5,0(s5)
ffffffffc0200cf4:	b571                	j	ffffffffc0200b80 <kmem_cache_alloc+0x48>
ffffffffc0200cf6:	7480                	ld	s0,40(s1)
ffffffffc0200cf8:	b561                	j	ffffffffc0200b80 <kmem_cache_alloc+0x48>
	void *kva = SLUB2KVA(slub);
ffffffffc0200cfa:	00001617          	auipc	a2,0x1
ffffffffc0200cfe:	fde60613          	addi	a2,a2,-34 # ffffffffc0201cd8 <commands+0x778>
ffffffffc0200d02:	0a200593          	li	a1,162
ffffffffc0200d06:	00001517          	auipc	a0,0x1
ffffffffc0200d0a:	ffa50513          	addi	a0,a0,-6 # ffffffffc0201d00 <commands+0x7a0>
ffffffffc0200d0e:	e9eff0ef          	jal	ra,ffffffffc02003ac <__panic>
	void *kva = KADDR(page2pa(page));
ffffffffc0200d12:	00001617          	auipc	a2,0x1
ffffffffc0200d16:	fc660613          	addi	a2,a2,-58 # ffffffffc0201cd8 <commands+0x778>
ffffffffc0200d1a:	02300593          	li	a1,35
ffffffffc0200d1e:	00001517          	auipc	a0,0x1
ffffffffc0200d22:	fe250513          	addi	a0,a0,-30 # ffffffffc0201d00 <commands+0x7a0>
ffffffffc0200d26:	e86ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200d2a <kmem_cache_create>:
		void (*dtor)(void*, kmem_cache_t *, size_t)){
ffffffffc0200d2a:	7139                	addi	sp,sp,-64
ffffffffc0200d2c:	f426                	sd	s1,40(sp)
	assert(size <= (PGSIZE -2));
ffffffffc0200d2e:	6485                	lui	s1,0x1
		void (*dtor)(void*, kmem_cache_t *, size_t)){
ffffffffc0200d30:	fc06                	sd	ra,56(sp)
ffffffffc0200d32:	f822                	sd	s0,48(sp)
ffffffffc0200d34:	f04a                	sd	s2,32(sp)
ffffffffc0200d36:	ec4e                	sd	s3,24(sp)
ffffffffc0200d38:	e852                	sd	s4,16(sp)
ffffffffc0200d3a:	e456                	sd	s5,8(sp)
	assert(size <= (PGSIZE -2));
ffffffffc0200d3c:	ffe48793          	addi	a5,s1,-2 # ffe <BASE_ADDRESS-0xffffffffc01ff002>
ffffffffc0200d40:	08b7e263          	bltu	a5,a1,ffffffffc0200dc4 <kmem_cache_create+0x9a>
ffffffffc0200d44:	89aa                	mv	s3,a0
	kmem_cache_t *p = kmem_cache_alloc(&(cache_cache));
ffffffffc0200d46:	00005517          	auipc	a0,0x5
ffffffffc0200d4a:	2ca50513          	addi	a0,a0,714 # ffffffffc0206010 <edata>
ffffffffc0200d4e:	892e                	mv	s2,a1
ffffffffc0200d50:	8ab2                	mv	s5,a2
ffffffffc0200d52:	8a36                	mv	s4,a3
ffffffffc0200d54:	de5ff0ef          	jal	ra,ffffffffc0200b38 <kmem_cache_alloc>
ffffffffc0200d58:	842a                	mv	s0,a0
	if(p != NULL)
ffffffffc0200d5a:	c939                	beqz	a0,ffffffffc0200db0 <kmem_cache_create+0x86>
		p->num = PGSIZE / (sizeof(int16_t) + size);
ffffffffc0200d5c:	00290793          	addi	a5,s2,2
ffffffffc0200d60:	02f4d4b3          	divu	s1,s1,a5
		p->objsize = size;
ffffffffc0200d64:	03251823          	sh	s2,48(a0)
		p->ctor = ctor;
ffffffffc0200d68:	03553c23          	sd	s5,56(a0)
		p->dtor = dtor;
ffffffffc0200d6c:	05453023          	sd	s4,64(a0)
		memcpy(p->name, name, CACHE_NAMELEN);
ffffffffc0200d70:	4641                	li	a2,16
ffffffffc0200d72:	85ce                	mv	a1,s3
ffffffffc0200d74:	04850513          	addi	a0,a0,72
		p->num = PGSIZE / (sizeof(int16_t) + size);
ffffffffc0200d78:	02941923          	sh	s1,50(s0)
		memcpy(p->name, name, CACHE_NAMELEN);
ffffffffc0200d7c:	6ac000ef          	jal	ra,ffffffffc0201428 <memcpy>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200d80:	00005717          	auipc	a4,0x5
ffffffffc0200d84:	2f870713          	addi	a4,a4,760 # ffffffffc0206078 <cache_chain>
    elm->prev = elm->next = elm;
ffffffffc0200d88:	e400                	sd	s0,8(s0)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200d8a:	6714                	ld	a3,8(a4)
		list_init(&(p->slubs_free));
ffffffffc0200d8c:	02040613          	addi	a2,s0,32
		list_init(&(p->slubs_part));
ffffffffc0200d90:	01040593          	addi	a1,s0,16
    elm->prev = elm->next = elm;
ffffffffc0200d94:	e000                	sd	s0,0(s0)
		list_add(&(cache_chain), &(p->cache_link));
ffffffffc0200d96:	05840793          	addi	a5,s0,88
ffffffffc0200d9a:	f410                	sd	a2,40(s0)
ffffffffc0200d9c:	f010                	sd	a2,32(s0)
ffffffffc0200d9e:	ec0c                	sd	a1,24(s0)
ffffffffc0200da0:	e80c                	sd	a1,16(s0)
    prev->next = next->prev = elm;
ffffffffc0200da2:	e29c                	sd	a5,0(a3)
ffffffffc0200da4:	00005617          	auipc	a2,0x5
ffffffffc0200da8:	2cf63e23          	sd	a5,732(a2) # ffffffffc0206080 <cache_chain+0x8>
    elm->next = next;
ffffffffc0200dac:	f034                	sd	a3,96(s0)
    elm->prev = prev;
ffffffffc0200dae:	ec38                	sd	a4,88(s0)
}
ffffffffc0200db0:	8522                	mv	a0,s0
ffffffffc0200db2:	70e2                	ld	ra,56(sp)
ffffffffc0200db4:	7442                	ld	s0,48(sp)
ffffffffc0200db6:	74a2                	ld	s1,40(sp)
ffffffffc0200db8:	7902                	ld	s2,32(sp)
ffffffffc0200dba:	69e2                	ld	s3,24(sp)
ffffffffc0200dbc:	6a42                	ld	s4,16(sp)
ffffffffc0200dbe:	6aa2                	ld	s5,8(sp)
ffffffffc0200dc0:	6121                	addi	sp,sp,64
ffffffffc0200dc2:	8082                	ret
	assert(size <= (PGSIZE -2));
ffffffffc0200dc4:	00001697          	auipc	a3,0x1
ffffffffc0200dc8:	ef468693          	addi	a3,a3,-268 # ffffffffc0201cb8 <commands+0x758>
ffffffffc0200dcc:	00001617          	auipc	a2,0x1
ffffffffc0200dd0:	f5c60613          	addi	a2,a2,-164 # ffffffffc0201d28 <commands+0x7c8>
ffffffffc0200dd4:	05a00593          	li	a1,90
ffffffffc0200dd8:	00001517          	auipc	a0,0x1
ffffffffc0200ddc:	f2850513          	addi	a0,a0,-216 # ffffffffc0201d00 <commands+0x7a0>
ffffffffc0200de0:	dccff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200de4 <slub_init>:
{
ffffffffc0200de4:	7139                	addi	sp,sp,-64
    elm->prev = elm->next = elm;
ffffffffc0200de6:	00005717          	auipc	a4,0x5
ffffffffc0200dea:	70a70713          	addi	a4,a4,1802 # ffffffffc02064f0 <free_area>
ffffffffc0200dee:	00005797          	auipc	a5,0x5
ffffffffc0200df2:	28a78793          	addi	a5,a5,650 # ffffffffc0206078 <cache_chain>
    kmem_cache_t *result = kmem_cache_create(cache_name, sizeof(kmem_cache_t), NULL, NULL);
ffffffffc0200df6:	4681                	li	a3,0
ffffffffc0200df8:	4601                	li	a2,0
ffffffffc0200dfa:	06800593          	li	a1,104
ffffffffc0200dfe:	00001517          	auipc	a0,0x1
ffffffffc0200e02:	f4250513          	addi	a0,a0,-190 # ffffffffc0201d40 <commands+0x7e0>
{
ffffffffc0200e06:	f822                	sd	s0,48(sp)
ffffffffc0200e08:	fc06                	sd	ra,56(sp)
ffffffffc0200e0a:	00005417          	auipc	s0,0x5
ffffffffc0200e0e:	6ee43723          	sd	a4,1774(s0) # ffffffffc02064f8 <free_area+0x8>
ffffffffc0200e12:	00005417          	auipc	s0,0x5
ffffffffc0200e16:	6ce43f23          	sd	a4,1758(s0) # ffffffffc02064f0 <free_area>
ffffffffc0200e1a:	f426                	sd	s1,40(sp)
ffffffffc0200e1c:	00005717          	auipc	a4,0x5
ffffffffc0200e20:	26f73223          	sd	a5,612(a4) # ffffffffc0206080 <cache_chain+0x8>
ffffffffc0200e24:	00005717          	auipc	a4,0x5
ffffffffc0200e28:	24f73a23          	sd	a5,596(a4) # ffffffffc0206078 <cache_chain>
ffffffffc0200e2c:	f04a                	sd	s2,32(sp)
ffffffffc0200e2e:	ec4e                	sd	s3,24(sp)
    nr_free = 0;
ffffffffc0200e30:	00005717          	auipc	a4,0x5
ffffffffc0200e34:	6c072823          	sw	zero,1744(a4) # ffffffffc0206500 <free_area+0x10>
    kmem_cache_t *result = kmem_cache_create(cache_name, sizeof(kmem_cache_t), NULL, NULL);
ffffffffc0200e38:	ef3ff0ef          	jal	ra,ffffffffc0200d2a <kmem_cache_create>
    assert(result == &cache_cache);
ffffffffc0200e3c:	00005797          	auipc	a5,0x5
ffffffffc0200e40:	1d478793          	addi	a5,a5,468 # ffffffffc0206010 <edata>
ffffffffc0200e44:	02a79c63          	bne	a5,a0,ffffffffc0200e7c <slub_init+0x98>
ffffffffc0200e48:	00005497          	auipc	s1,0x5
ffffffffc0200e4c:	24048493          	addi	s1,s1,576 # ffffffffc0206088 <cache_sized>
    for (int i = 0; i < SIZED_CACHE_NUM; i++) {
ffffffffc0200e50:	4401                	li	s0,0
        cache_sized[i] = kmem_cache_create(name, (SIZED_CACHE_MIN << i), NULL, NULL);
ffffffffc0200e52:	49c1                	li	s3,16
    for (int i = 0; i < SIZED_CACHE_NUM; i++) {
ffffffffc0200e54:	4921                	li	s2,8
        cache_sized[i] = kmem_cache_create(name, (SIZED_CACHE_MIN << i), NULL, NULL);
ffffffffc0200e56:	008995bb          	sllw	a1,s3,s0
ffffffffc0200e5a:	4681                	li	a3,0
ffffffffc0200e5c:	4601                	li	a2,0
ffffffffc0200e5e:	850a                	mv	a0,sp
ffffffffc0200e60:	ecbff0ef          	jal	ra,ffffffffc0200d2a <kmem_cache_create>
ffffffffc0200e64:	e088                	sd	a0,0(s1)
    for (int i = 0; i < SIZED_CACHE_NUM; i++) {
ffffffffc0200e66:	2405                	addiw	s0,s0,1
ffffffffc0200e68:	04a1                	addi	s1,s1,8
ffffffffc0200e6a:	ff2416e3          	bne	s0,s2,ffffffffc0200e56 <slub_init+0x72>
}
ffffffffc0200e6e:	70e2                	ld	ra,56(sp)
ffffffffc0200e70:	7442                	ld	s0,48(sp)
ffffffffc0200e72:	74a2                	ld	s1,40(sp)
ffffffffc0200e74:	7902                	ld	s2,32(sp)
ffffffffc0200e76:	69e2                	ld	s3,24(sp)
ffffffffc0200e78:	6121                	addi	sp,sp,64
ffffffffc0200e7a:	8082                	ret
    assert(result == &cache_cache);
ffffffffc0200e7c:	00001697          	auipc	a3,0x1
ffffffffc0200e80:	ecc68693          	addi	a3,a3,-308 # ffffffffc0201d48 <commands+0x7e8>
ffffffffc0200e84:	00001617          	auipc	a2,0x1
ffffffffc0200e88:	ea460613          	addi	a2,a2,-348 # ffffffffc0201d28 <commands+0x7c8>
ffffffffc0200e8c:	11100593          	li	a1,273
ffffffffc0200e90:	00001517          	auipc	a0,0x1
ffffffffc0200e94:	e7050513          	addi	a0,a0,-400 # ffffffffc0201d00 <commands+0x7a0>
ffffffffc0200e98:	d14ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200e9c <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0200e9c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200ea0:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0200ea2:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200ea6:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0200ea8:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200eac:	f022                	sd	s0,32(sp)
ffffffffc0200eae:	ec26                	sd	s1,24(sp)
ffffffffc0200eb0:	e84a                	sd	s2,16(sp)
ffffffffc0200eb2:	f406                	sd	ra,40(sp)
ffffffffc0200eb4:	e44e                	sd	s3,8(sp)
ffffffffc0200eb6:	84aa                	mv	s1,a0
ffffffffc0200eb8:	892e                	mv	s2,a1
ffffffffc0200eba:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0200ebe:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0200ec0:	03067e63          	bleu	a6,a2,ffffffffc0200efc <printnum+0x60>
ffffffffc0200ec4:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0200ec6:	00805763          	blez	s0,ffffffffc0200ed4 <printnum+0x38>
ffffffffc0200eca:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0200ecc:	85ca                	mv	a1,s2
ffffffffc0200ece:	854e                	mv	a0,s3
ffffffffc0200ed0:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0200ed2:	fc65                	bnez	s0,ffffffffc0200eca <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200ed4:	1a02                	slli	s4,s4,0x20
ffffffffc0200ed6:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200eda:	00001797          	auipc	a5,0x1
ffffffffc0200ede:	07e78793          	addi	a5,a5,126 # ffffffffc0201f58 <error_string+0x38>
ffffffffc0200ee2:	9a3e                	add	s4,s4,a5
}
ffffffffc0200ee4:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200ee6:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0200eea:	70a2                	ld	ra,40(sp)
ffffffffc0200eec:	69a2                	ld	s3,8(sp)
ffffffffc0200eee:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200ef0:	85ca                	mv	a1,s2
ffffffffc0200ef2:	8326                	mv	t1,s1
}
ffffffffc0200ef4:	6942                	ld	s2,16(sp)
ffffffffc0200ef6:	64e2                	ld	s1,24(sp)
ffffffffc0200ef8:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200efa:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0200efc:	03065633          	divu	a2,a2,a6
ffffffffc0200f00:	8722                	mv	a4,s0
ffffffffc0200f02:	f9bff0ef          	jal	ra,ffffffffc0200e9c <printnum>
ffffffffc0200f06:	b7f9                	j	ffffffffc0200ed4 <printnum+0x38>

ffffffffc0200f08 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0200f08:	7119                	addi	sp,sp,-128
ffffffffc0200f0a:	f4a6                	sd	s1,104(sp)
ffffffffc0200f0c:	f0ca                	sd	s2,96(sp)
ffffffffc0200f0e:	e8d2                	sd	s4,80(sp)
ffffffffc0200f10:	e4d6                	sd	s5,72(sp)
ffffffffc0200f12:	e0da                	sd	s6,64(sp)
ffffffffc0200f14:	fc5e                	sd	s7,56(sp)
ffffffffc0200f16:	f862                	sd	s8,48(sp)
ffffffffc0200f18:	f06a                	sd	s10,32(sp)
ffffffffc0200f1a:	fc86                	sd	ra,120(sp)
ffffffffc0200f1c:	f8a2                	sd	s0,112(sp)
ffffffffc0200f1e:	ecce                	sd	s3,88(sp)
ffffffffc0200f20:	f466                	sd	s9,40(sp)
ffffffffc0200f22:	ec6e                	sd	s11,24(sp)
ffffffffc0200f24:	892a                	mv	s2,a0
ffffffffc0200f26:	84ae                	mv	s1,a1
ffffffffc0200f28:	8d32                	mv	s10,a2
ffffffffc0200f2a:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0200f2c:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f2e:	00001a17          	auipc	s4,0x1
ffffffffc0200f32:	e96a0a13          	addi	s4,s4,-362 # ffffffffc0201dc4 <slub_pmm_manager+0x4c>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0200f36:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0200f3a:	00001c17          	auipc	s8,0x1
ffffffffc0200f3e:	fe6c0c13          	addi	s8,s8,-26 # ffffffffc0201f20 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200f42:	000d4503          	lbu	a0,0(s10)
ffffffffc0200f46:	02500793          	li	a5,37
ffffffffc0200f4a:	001d0413          	addi	s0,s10,1
ffffffffc0200f4e:	00f50e63          	beq	a0,a5,ffffffffc0200f6a <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0200f52:	c521                	beqz	a0,ffffffffc0200f9a <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200f54:	02500993          	li	s3,37
ffffffffc0200f58:	a011                	j	ffffffffc0200f5c <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0200f5a:	c121                	beqz	a0,ffffffffc0200f9a <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0200f5c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200f5e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0200f60:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200f62:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200f66:	ff351ae3          	bne	a0,s3,ffffffffc0200f5a <vprintfmt+0x52>
ffffffffc0200f6a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0200f6e:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0200f72:	4981                	li	s3,0
ffffffffc0200f74:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0200f76:	5cfd                	li	s9,-1
ffffffffc0200f78:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f7a:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0200f7e:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f80:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0200f84:	0ff6f693          	andi	a3,a3,255
ffffffffc0200f88:	00140d13          	addi	s10,s0,1
ffffffffc0200f8c:	20d5e563          	bltu	a1,a3,ffffffffc0201196 <vprintfmt+0x28e>
ffffffffc0200f90:	068a                	slli	a3,a3,0x2
ffffffffc0200f92:	96d2                	add	a3,a3,s4
ffffffffc0200f94:	4294                	lw	a3,0(a3)
ffffffffc0200f96:	96d2                	add	a3,a3,s4
ffffffffc0200f98:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0200f9a:	70e6                	ld	ra,120(sp)
ffffffffc0200f9c:	7446                	ld	s0,112(sp)
ffffffffc0200f9e:	74a6                	ld	s1,104(sp)
ffffffffc0200fa0:	7906                	ld	s2,96(sp)
ffffffffc0200fa2:	69e6                	ld	s3,88(sp)
ffffffffc0200fa4:	6a46                	ld	s4,80(sp)
ffffffffc0200fa6:	6aa6                	ld	s5,72(sp)
ffffffffc0200fa8:	6b06                	ld	s6,64(sp)
ffffffffc0200faa:	7be2                	ld	s7,56(sp)
ffffffffc0200fac:	7c42                	ld	s8,48(sp)
ffffffffc0200fae:	7ca2                	ld	s9,40(sp)
ffffffffc0200fb0:	7d02                	ld	s10,32(sp)
ffffffffc0200fb2:	6de2                	ld	s11,24(sp)
ffffffffc0200fb4:	6109                	addi	sp,sp,128
ffffffffc0200fb6:	8082                	ret
    if (lflag >= 2) {
ffffffffc0200fb8:	4705                	li	a4,1
ffffffffc0200fba:	008a8593          	addi	a1,s5,8
ffffffffc0200fbe:	01074463          	blt	a4,a6,ffffffffc0200fc6 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0200fc2:	26080363          	beqz	a6,ffffffffc0201228 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0200fc6:	000ab603          	ld	a2,0(s5)
ffffffffc0200fca:	46c1                	li	a3,16
ffffffffc0200fcc:	8aae                	mv	s5,a1
ffffffffc0200fce:	a06d                	j	ffffffffc0201078 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0200fd0:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0200fd4:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200fd6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0200fd8:	b765                	j	ffffffffc0200f80 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0200fda:	000aa503          	lw	a0,0(s5)
ffffffffc0200fde:	85a6                	mv	a1,s1
ffffffffc0200fe0:	0aa1                	addi	s5,s5,8
ffffffffc0200fe2:	9902                	jalr	s2
            break;
ffffffffc0200fe4:	bfb9                	j	ffffffffc0200f42 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0200fe6:	4705                	li	a4,1
ffffffffc0200fe8:	008a8993          	addi	s3,s5,8
ffffffffc0200fec:	01074463          	blt	a4,a6,ffffffffc0200ff4 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0200ff0:	22080463          	beqz	a6,ffffffffc0201218 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0200ff4:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0200ff8:	24044463          	bltz	s0,ffffffffc0201240 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0200ffc:	8622                	mv	a2,s0
ffffffffc0200ffe:	8ace                	mv	s5,s3
ffffffffc0201000:	46a9                	li	a3,10
ffffffffc0201002:	a89d                	j	ffffffffc0201078 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0201004:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201008:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020100a:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc020100c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201010:	8fb5                	xor	a5,a5,a3
ffffffffc0201012:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201016:	1ad74363          	blt	a4,a3,ffffffffc02011bc <vprintfmt+0x2b4>
ffffffffc020101a:	00369793          	slli	a5,a3,0x3
ffffffffc020101e:	97e2                	add	a5,a5,s8
ffffffffc0201020:	639c                	ld	a5,0(a5)
ffffffffc0201022:	18078d63          	beqz	a5,ffffffffc02011bc <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201026:	86be                	mv	a3,a5
ffffffffc0201028:	00001617          	auipc	a2,0x1
ffffffffc020102c:	fe060613          	addi	a2,a2,-32 # ffffffffc0202008 <error_string+0xe8>
ffffffffc0201030:	85a6                	mv	a1,s1
ffffffffc0201032:	854a                	mv	a0,s2
ffffffffc0201034:	240000ef          	jal	ra,ffffffffc0201274 <printfmt>
ffffffffc0201038:	b729                	j	ffffffffc0200f42 <vprintfmt+0x3a>
            lflag ++;
ffffffffc020103a:	00144603          	lbu	a2,1(s0)
ffffffffc020103e:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201040:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201042:	bf3d                	j	ffffffffc0200f80 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0201044:	4705                	li	a4,1
ffffffffc0201046:	008a8593          	addi	a1,s5,8
ffffffffc020104a:	01074463          	blt	a4,a6,ffffffffc0201052 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc020104e:	1e080263          	beqz	a6,ffffffffc0201232 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0201052:	000ab603          	ld	a2,0(s5)
ffffffffc0201056:	46a1                	li	a3,8
ffffffffc0201058:	8aae                	mv	s5,a1
ffffffffc020105a:	a839                	j	ffffffffc0201078 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc020105c:	03000513          	li	a0,48
ffffffffc0201060:	85a6                	mv	a1,s1
ffffffffc0201062:	e03e                	sd	a5,0(sp)
ffffffffc0201064:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201066:	85a6                	mv	a1,s1
ffffffffc0201068:	07800513          	li	a0,120
ffffffffc020106c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020106e:	0aa1                	addi	s5,s5,8
ffffffffc0201070:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0201074:	6782                	ld	a5,0(sp)
ffffffffc0201076:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201078:	876e                	mv	a4,s11
ffffffffc020107a:	85a6                	mv	a1,s1
ffffffffc020107c:	854a                	mv	a0,s2
ffffffffc020107e:	e1fff0ef          	jal	ra,ffffffffc0200e9c <printnum>
            break;
ffffffffc0201082:	b5c1                	j	ffffffffc0200f42 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201084:	000ab603          	ld	a2,0(s5)
ffffffffc0201088:	0aa1                	addi	s5,s5,8
ffffffffc020108a:	1c060663          	beqz	a2,ffffffffc0201256 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc020108e:	00160413          	addi	s0,a2,1
ffffffffc0201092:	17b05c63          	blez	s11,ffffffffc020120a <vprintfmt+0x302>
ffffffffc0201096:	02d00593          	li	a1,45
ffffffffc020109a:	14b79263          	bne	a5,a1,ffffffffc02011de <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020109e:	00064783          	lbu	a5,0(a2)
ffffffffc02010a2:	0007851b          	sext.w	a0,a5
ffffffffc02010a6:	c905                	beqz	a0,ffffffffc02010d6 <vprintfmt+0x1ce>
ffffffffc02010a8:	000cc563          	bltz	s9,ffffffffc02010b2 <vprintfmt+0x1aa>
ffffffffc02010ac:	3cfd                	addiw	s9,s9,-1
ffffffffc02010ae:	036c8263          	beq	s9,s6,ffffffffc02010d2 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc02010b2:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02010b4:	18098463          	beqz	s3,ffffffffc020123c <vprintfmt+0x334>
ffffffffc02010b8:	3781                	addiw	a5,a5,-32
ffffffffc02010ba:	18fbf163          	bleu	a5,s7,ffffffffc020123c <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc02010be:	03f00513          	li	a0,63
ffffffffc02010c2:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02010c4:	0405                	addi	s0,s0,1
ffffffffc02010c6:	fff44783          	lbu	a5,-1(s0)
ffffffffc02010ca:	3dfd                	addiw	s11,s11,-1
ffffffffc02010cc:	0007851b          	sext.w	a0,a5
ffffffffc02010d0:	fd61                	bnez	a0,ffffffffc02010a8 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc02010d2:	e7b058e3          	blez	s11,ffffffffc0200f42 <vprintfmt+0x3a>
ffffffffc02010d6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02010d8:	85a6                	mv	a1,s1
ffffffffc02010da:	02000513          	li	a0,32
ffffffffc02010de:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02010e0:	e60d81e3          	beqz	s11,ffffffffc0200f42 <vprintfmt+0x3a>
ffffffffc02010e4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02010e6:	85a6                	mv	a1,s1
ffffffffc02010e8:	02000513          	li	a0,32
ffffffffc02010ec:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02010ee:	fe0d94e3          	bnez	s11,ffffffffc02010d6 <vprintfmt+0x1ce>
ffffffffc02010f2:	bd81                	j	ffffffffc0200f42 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02010f4:	4705                	li	a4,1
ffffffffc02010f6:	008a8593          	addi	a1,s5,8
ffffffffc02010fa:	01074463          	blt	a4,a6,ffffffffc0201102 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02010fe:	12080063          	beqz	a6,ffffffffc020121e <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0201102:	000ab603          	ld	a2,0(s5)
ffffffffc0201106:	46a9                	li	a3,10
ffffffffc0201108:	8aae                	mv	s5,a1
ffffffffc020110a:	b7bd                	j	ffffffffc0201078 <vprintfmt+0x170>
ffffffffc020110c:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0201110:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201114:	846a                	mv	s0,s10
ffffffffc0201116:	b5ad                	j	ffffffffc0200f80 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0201118:	85a6                	mv	a1,s1
ffffffffc020111a:	02500513          	li	a0,37
ffffffffc020111e:	9902                	jalr	s2
            break;
ffffffffc0201120:	b50d                	j	ffffffffc0200f42 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0201122:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0201126:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020112a:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020112c:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc020112e:	e40dd9e3          	bgez	s11,ffffffffc0200f80 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0201132:	8de6                	mv	s11,s9
ffffffffc0201134:	5cfd                	li	s9,-1
ffffffffc0201136:	b5a9                	j	ffffffffc0200f80 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0201138:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc020113c:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201140:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201142:	bd3d                	j	ffffffffc0200f80 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0201144:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0201148:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020114c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020114e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201152:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201156:	fcd56ce3          	bltu	a0,a3,ffffffffc020112e <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc020115a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020115c:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201160:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201164:	0196873b          	addw	a4,a3,s9
ffffffffc0201168:	0017171b          	slliw	a4,a4,0x1
ffffffffc020116c:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0201170:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201174:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201178:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020117c:	fcd57fe3          	bleu	a3,a0,ffffffffc020115a <vprintfmt+0x252>
ffffffffc0201180:	b77d                	j	ffffffffc020112e <vprintfmt+0x226>
            if (width < 0)
ffffffffc0201182:	fffdc693          	not	a3,s11
ffffffffc0201186:	96fd                	srai	a3,a3,0x3f
ffffffffc0201188:	00ddfdb3          	and	s11,s11,a3
ffffffffc020118c:	00144603          	lbu	a2,1(s0)
ffffffffc0201190:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201192:	846a                	mv	s0,s10
ffffffffc0201194:	b3f5                	j	ffffffffc0200f80 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0201196:	85a6                	mv	a1,s1
ffffffffc0201198:	02500513          	li	a0,37
ffffffffc020119c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020119e:	fff44703          	lbu	a4,-1(s0)
ffffffffc02011a2:	02500793          	li	a5,37
ffffffffc02011a6:	8d22                	mv	s10,s0
ffffffffc02011a8:	d8f70de3          	beq	a4,a5,ffffffffc0200f42 <vprintfmt+0x3a>
ffffffffc02011ac:	02500713          	li	a4,37
ffffffffc02011b0:	1d7d                	addi	s10,s10,-1
ffffffffc02011b2:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02011b6:	fee79de3          	bne	a5,a4,ffffffffc02011b0 <vprintfmt+0x2a8>
ffffffffc02011ba:	b361                	j	ffffffffc0200f42 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02011bc:	00001617          	auipc	a2,0x1
ffffffffc02011c0:	e3c60613          	addi	a2,a2,-452 # ffffffffc0201ff8 <error_string+0xd8>
ffffffffc02011c4:	85a6                	mv	a1,s1
ffffffffc02011c6:	854a                	mv	a0,s2
ffffffffc02011c8:	0ac000ef          	jal	ra,ffffffffc0201274 <printfmt>
ffffffffc02011cc:	bb9d                	j	ffffffffc0200f42 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02011ce:	00001617          	auipc	a2,0x1
ffffffffc02011d2:	e2260613          	addi	a2,a2,-478 # ffffffffc0201ff0 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02011d6:	00001417          	auipc	s0,0x1
ffffffffc02011da:	e1b40413          	addi	s0,s0,-485 # ffffffffc0201ff1 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02011de:	8532                	mv	a0,a2
ffffffffc02011e0:	85e6                	mv	a1,s9
ffffffffc02011e2:	e032                	sd	a2,0(sp)
ffffffffc02011e4:	e43e                	sd	a5,8(sp)
ffffffffc02011e6:	1c2000ef          	jal	ra,ffffffffc02013a8 <strnlen>
ffffffffc02011ea:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02011ee:	6602                	ld	a2,0(sp)
ffffffffc02011f0:	01b05d63          	blez	s11,ffffffffc020120a <vprintfmt+0x302>
ffffffffc02011f4:	67a2                	ld	a5,8(sp)
ffffffffc02011f6:	2781                	sext.w	a5,a5
ffffffffc02011f8:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02011fa:	6522                	ld	a0,8(sp)
ffffffffc02011fc:	85a6                	mv	a1,s1
ffffffffc02011fe:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201200:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201202:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201204:	6602                	ld	a2,0(sp)
ffffffffc0201206:	fe0d9ae3          	bnez	s11,ffffffffc02011fa <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020120a:	00064783          	lbu	a5,0(a2)
ffffffffc020120e:	0007851b          	sext.w	a0,a5
ffffffffc0201212:	e8051be3          	bnez	a0,ffffffffc02010a8 <vprintfmt+0x1a0>
ffffffffc0201216:	b335                	j	ffffffffc0200f42 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0201218:	000aa403          	lw	s0,0(s5)
ffffffffc020121c:	bbf1                	j	ffffffffc0200ff8 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc020121e:	000ae603          	lwu	a2,0(s5)
ffffffffc0201222:	46a9                	li	a3,10
ffffffffc0201224:	8aae                	mv	s5,a1
ffffffffc0201226:	bd89                	j	ffffffffc0201078 <vprintfmt+0x170>
ffffffffc0201228:	000ae603          	lwu	a2,0(s5)
ffffffffc020122c:	46c1                	li	a3,16
ffffffffc020122e:	8aae                	mv	s5,a1
ffffffffc0201230:	b5a1                	j	ffffffffc0201078 <vprintfmt+0x170>
ffffffffc0201232:	000ae603          	lwu	a2,0(s5)
ffffffffc0201236:	46a1                	li	a3,8
ffffffffc0201238:	8aae                	mv	s5,a1
ffffffffc020123a:	bd3d                	j	ffffffffc0201078 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc020123c:	9902                	jalr	s2
ffffffffc020123e:	b559                	j	ffffffffc02010c4 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0201240:	85a6                	mv	a1,s1
ffffffffc0201242:	02d00513          	li	a0,45
ffffffffc0201246:	e03e                	sd	a5,0(sp)
ffffffffc0201248:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020124a:	8ace                	mv	s5,s3
ffffffffc020124c:	40800633          	neg	a2,s0
ffffffffc0201250:	46a9                	li	a3,10
ffffffffc0201252:	6782                	ld	a5,0(sp)
ffffffffc0201254:	b515                	j	ffffffffc0201078 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0201256:	01b05663          	blez	s11,ffffffffc0201262 <vprintfmt+0x35a>
ffffffffc020125a:	02d00693          	li	a3,45
ffffffffc020125e:	f6d798e3          	bne	a5,a3,ffffffffc02011ce <vprintfmt+0x2c6>
ffffffffc0201262:	00001417          	auipc	s0,0x1
ffffffffc0201266:	d8f40413          	addi	s0,s0,-625 # ffffffffc0201ff1 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020126a:	02800513          	li	a0,40
ffffffffc020126e:	02800793          	li	a5,40
ffffffffc0201272:	bd1d                	j	ffffffffc02010a8 <vprintfmt+0x1a0>

ffffffffc0201274 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201274:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201276:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020127a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020127c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020127e:	ec06                	sd	ra,24(sp)
ffffffffc0201280:	f83a                	sd	a4,48(sp)
ffffffffc0201282:	fc3e                	sd	a5,56(sp)
ffffffffc0201284:	e0c2                	sd	a6,64(sp)
ffffffffc0201286:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201288:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020128a:	c7fff0ef          	jal	ra,ffffffffc0200f08 <vprintfmt>
}
ffffffffc020128e:	60e2                	ld	ra,24(sp)
ffffffffc0201290:	6161                	addi	sp,sp,80
ffffffffc0201292:	8082                	ret

ffffffffc0201294 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201294:	715d                	addi	sp,sp,-80
ffffffffc0201296:	e486                	sd	ra,72(sp)
ffffffffc0201298:	e0a2                	sd	s0,64(sp)
ffffffffc020129a:	fc26                	sd	s1,56(sp)
ffffffffc020129c:	f84a                	sd	s2,48(sp)
ffffffffc020129e:	f44e                	sd	s3,40(sp)
ffffffffc02012a0:	f052                	sd	s4,32(sp)
ffffffffc02012a2:	ec56                	sd	s5,24(sp)
ffffffffc02012a4:	e85a                	sd	s6,16(sp)
ffffffffc02012a6:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02012a8:	c901                	beqz	a0,ffffffffc02012b8 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02012aa:	85aa                	mv	a1,a0
ffffffffc02012ac:	00001517          	auipc	a0,0x1
ffffffffc02012b0:	d5c50513          	addi	a0,a0,-676 # ffffffffc0202008 <error_string+0xe8>
ffffffffc02012b4:	e03fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc02012b8:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02012ba:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02012bc:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02012be:	4aa9                	li	s5,10
ffffffffc02012c0:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02012c2:	00005b97          	auipc	s7,0x5
ffffffffc02012c6:	e06b8b93          	addi	s7,s7,-506 # ffffffffc02060c8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02012ca:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02012ce:	e61fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02012d2:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02012d4:	00054b63          	bltz	a0,ffffffffc02012ea <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02012d8:	00a95b63          	ble	a0,s2,ffffffffc02012ee <readline+0x5a>
ffffffffc02012dc:	029a5463          	ble	s1,s4,ffffffffc0201304 <readline+0x70>
        c = getchar();
ffffffffc02012e0:	e4ffe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02012e4:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02012e6:	fe0559e3          	bgez	a0,ffffffffc02012d8 <readline+0x44>
            return NULL;
ffffffffc02012ea:	4501                	li	a0,0
ffffffffc02012ec:	a099                	j	ffffffffc0201332 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02012ee:	03341463          	bne	s0,s3,ffffffffc0201316 <readline+0x82>
ffffffffc02012f2:	e8b9                	bnez	s1,ffffffffc0201348 <readline+0xb4>
        c = getchar();
ffffffffc02012f4:	e3bfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02012f8:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02012fa:	fe0548e3          	bltz	a0,ffffffffc02012ea <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02012fe:	fea958e3          	ble	a0,s2,ffffffffc02012ee <readline+0x5a>
ffffffffc0201302:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201304:	8522                	mv	a0,s0
ffffffffc0201306:	de5fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc020130a:	009b87b3          	add	a5,s7,s1
ffffffffc020130e:	00878023          	sb	s0,0(a5)
ffffffffc0201312:	2485                	addiw	s1,s1,1
ffffffffc0201314:	bf6d                	j	ffffffffc02012ce <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201316:	01540463          	beq	s0,s5,ffffffffc020131e <readline+0x8a>
ffffffffc020131a:	fb641ae3          	bne	s0,s6,ffffffffc02012ce <readline+0x3a>
            cputchar(c);
ffffffffc020131e:	8522                	mv	a0,s0
ffffffffc0201320:	dcbfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc0201324:	00005517          	auipc	a0,0x5
ffffffffc0201328:	da450513          	addi	a0,a0,-604 # ffffffffc02060c8 <buf>
ffffffffc020132c:	94aa                	add	s1,s1,a0
ffffffffc020132e:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201332:	60a6                	ld	ra,72(sp)
ffffffffc0201334:	6406                	ld	s0,64(sp)
ffffffffc0201336:	74e2                	ld	s1,56(sp)
ffffffffc0201338:	7942                	ld	s2,48(sp)
ffffffffc020133a:	79a2                	ld	s3,40(sp)
ffffffffc020133c:	7a02                	ld	s4,32(sp)
ffffffffc020133e:	6ae2                	ld	s5,24(sp)
ffffffffc0201340:	6b42                	ld	s6,16(sp)
ffffffffc0201342:	6ba2                	ld	s7,8(sp)
ffffffffc0201344:	6161                	addi	sp,sp,80
ffffffffc0201346:	8082                	ret
            cputchar(c);
ffffffffc0201348:	4521                	li	a0,8
ffffffffc020134a:	da1fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc020134e:	34fd                	addiw	s1,s1,-1
ffffffffc0201350:	bfbd                	j	ffffffffc02012ce <readline+0x3a>

ffffffffc0201352 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201352:	00005797          	auipc	a5,0x5
ffffffffc0201356:	cb678793          	addi	a5,a5,-842 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc020135a:	6398                	ld	a4,0(a5)
ffffffffc020135c:	4781                	li	a5,0
ffffffffc020135e:	88ba                	mv	a7,a4
ffffffffc0201360:	852a                	mv	a0,a0
ffffffffc0201362:	85be                	mv	a1,a5
ffffffffc0201364:	863e                	mv	a2,a5
ffffffffc0201366:	00000073          	ecall
ffffffffc020136a:	87aa                	mv	a5,a0
}
ffffffffc020136c:	8082                	ret

ffffffffc020136e <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc020136e:	00005797          	auipc	a5,0x5
ffffffffc0201372:	17278793          	addi	a5,a5,370 # ffffffffc02064e0 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201376:	6398                	ld	a4,0(a5)
ffffffffc0201378:	4781                	li	a5,0
ffffffffc020137a:	88ba                	mv	a7,a4
ffffffffc020137c:	852a                	mv	a0,a0
ffffffffc020137e:	85be                	mv	a1,a5
ffffffffc0201380:	863e                	mv	a2,a5
ffffffffc0201382:	00000073          	ecall
ffffffffc0201386:	87aa                	mv	a5,a0
}
ffffffffc0201388:	8082                	ret

ffffffffc020138a <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc020138a:	00005797          	auipc	a5,0x5
ffffffffc020138e:	c7678793          	addi	a5,a5,-906 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201392:	639c                	ld	a5,0(a5)
ffffffffc0201394:	4501                	li	a0,0
ffffffffc0201396:	88be                	mv	a7,a5
ffffffffc0201398:	852a                	mv	a0,a0
ffffffffc020139a:	85aa                	mv	a1,a0
ffffffffc020139c:	862a                	mv	a2,a0
ffffffffc020139e:	00000073          	ecall
ffffffffc02013a2:	852a                	mv	a0,a0
ffffffffc02013a4:	2501                	sext.w	a0,a0
ffffffffc02013a6:	8082                	ret

ffffffffc02013a8 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc02013a8:	c185                	beqz	a1,ffffffffc02013c8 <strnlen+0x20>
ffffffffc02013aa:	00054783          	lbu	a5,0(a0)
ffffffffc02013ae:	cf89                	beqz	a5,ffffffffc02013c8 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02013b0:	4781                	li	a5,0
ffffffffc02013b2:	a021                	j	ffffffffc02013ba <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02013b4:	00074703          	lbu	a4,0(a4)
ffffffffc02013b8:	c711                	beqz	a4,ffffffffc02013c4 <strnlen+0x1c>
        cnt ++;
ffffffffc02013ba:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02013bc:	00f50733          	add	a4,a0,a5
ffffffffc02013c0:	fef59ae3          	bne	a1,a5,ffffffffc02013b4 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02013c4:	853e                	mv	a0,a5
ffffffffc02013c6:	8082                	ret
    size_t cnt = 0;
ffffffffc02013c8:	4781                	li	a5,0
}
ffffffffc02013ca:	853e                	mv	a0,a5
ffffffffc02013cc:	8082                	ret

ffffffffc02013ce <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02013ce:	00054783          	lbu	a5,0(a0)
ffffffffc02013d2:	0005c703          	lbu	a4,0(a1)
ffffffffc02013d6:	cb91                	beqz	a5,ffffffffc02013ea <strcmp+0x1c>
ffffffffc02013d8:	00e79c63          	bne	a5,a4,ffffffffc02013f0 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02013dc:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02013de:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02013e2:	0585                	addi	a1,a1,1
ffffffffc02013e4:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02013e8:	fbe5                	bnez	a5,ffffffffc02013d8 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02013ea:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02013ec:	9d19                	subw	a0,a0,a4
ffffffffc02013ee:	8082                	ret
ffffffffc02013f0:	0007851b          	sext.w	a0,a5
ffffffffc02013f4:	9d19                	subw	a0,a0,a4
ffffffffc02013f6:	8082                	ret

ffffffffc02013f8 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02013f8:	00054783          	lbu	a5,0(a0)
ffffffffc02013fc:	cb91                	beqz	a5,ffffffffc0201410 <strchr+0x18>
        if (*s == c) {
ffffffffc02013fe:	00b79563          	bne	a5,a1,ffffffffc0201408 <strchr+0x10>
ffffffffc0201402:	a809                	j	ffffffffc0201414 <strchr+0x1c>
ffffffffc0201404:	00b78763          	beq	a5,a1,ffffffffc0201412 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201408:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020140a:	00054783          	lbu	a5,0(a0)
ffffffffc020140e:	fbfd                	bnez	a5,ffffffffc0201404 <strchr+0xc>
    }
    return NULL;
ffffffffc0201410:	4501                	li	a0,0
}
ffffffffc0201412:	8082                	ret
ffffffffc0201414:	8082                	ret

ffffffffc0201416 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201416:	ca01                	beqz	a2,ffffffffc0201426 <memset+0x10>
ffffffffc0201418:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020141a:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020141c:	0785                	addi	a5,a5,1
ffffffffc020141e:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201422:	fec79de3          	bne	a5,a2,ffffffffc020141c <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201426:	8082                	ret

ffffffffc0201428 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0201428:	ca19                	beqz	a2,ffffffffc020143e <memcpy+0x16>
ffffffffc020142a:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020142c:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020142e:	0585                	addi	a1,a1,1
ffffffffc0201430:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0201434:	0785                	addi	a5,a5,1
ffffffffc0201436:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020143a:	fec59ae3          	bne	a1,a2,ffffffffc020142e <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020143e:	8082                	ret
