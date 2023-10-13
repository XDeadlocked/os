
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
ffffffffc0200042:	5fa60613          	addi	a2,a2,1530 # ffffffffc0206638 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	3ad010ef          	jal	ra,ffffffffc0201bfa <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	bba50513          	addi	a0,a0,-1094 # ffffffffc0201c10 <etext+0x4>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	468010ef          	jal	ra,ffffffffc02014d2 <pmm_init>

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
ffffffffc02000aa:	642010ef          	jal	ra,ffffffffc02016ec <vprintfmt>
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
ffffffffc02000de:	60e010ef          	jal	ra,ffffffffc02016ec <vprintfmt>
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
ffffffffc0200140:	00002517          	auipc	a0,0x2
ffffffffc0200144:	b2050513          	addi	a0,a0,-1248 # ffffffffc0201c60 <etext+0x54>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00002517          	auipc	a0,0x2
ffffffffc020015a:	b2a50513          	addi	a0,a0,-1238 # ffffffffc0201c80 <etext+0x74>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00002597          	auipc	a1,0x2
ffffffffc0200166:	aaa58593          	addi	a1,a1,-1366 # ffffffffc0201c0c <etext>
ffffffffc020016a:	00002517          	auipc	a0,0x2
ffffffffc020016e:	b3650513          	addi	a0,a0,-1226 # ffffffffc0201ca0 <etext+0x94>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0206010 <edata>
ffffffffc020017e:	00002517          	auipc	a0,0x2
ffffffffc0200182:	b4250513          	addi	a0,a0,-1214 # ffffffffc0201cc0 <etext+0xb4>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00006597          	auipc	a1,0x6
ffffffffc020018e:	4ae58593          	addi	a1,a1,1198 # ffffffffc0206638 <end>
ffffffffc0200192:	00002517          	auipc	a0,0x2
ffffffffc0200196:	b4e50513          	addi	a0,a0,-1202 # ffffffffc0201ce0 <etext+0xd4>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019e:	00007597          	auipc	a1,0x7
ffffffffc02001a2:	89958593          	addi	a1,a1,-1895 # ffffffffc0206a37 <end+0x3ff>
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
ffffffffc02001c0:	00002517          	auipc	a0,0x2
ffffffffc02001c4:	b4050513          	addi	a0,a0,-1216 # ffffffffc0201d00 <etext+0xf4>
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
ffffffffc02001d0:	00002617          	auipc	a2,0x2
ffffffffc02001d4:	a6060613          	addi	a2,a2,-1440 # ffffffffc0201c30 <etext+0x24>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00002517          	auipc	a0,0x2
ffffffffc02001e0:	a6c50513          	addi	a0,a0,-1428 # ffffffffc0201c48 <etext+0x3c>
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
ffffffffc02001ec:	00002617          	auipc	a2,0x2
ffffffffc02001f0:	c2460613          	addi	a2,a2,-988 # ffffffffc0201e10 <commands+0xe0>
ffffffffc02001f4:	00002597          	auipc	a1,0x2
ffffffffc02001f8:	c3c58593          	addi	a1,a1,-964 # ffffffffc0201e30 <commands+0x100>
ffffffffc02001fc:	00002517          	auipc	a0,0x2
ffffffffc0200200:	c3c50513          	addi	a0,a0,-964 # ffffffffc0201e38 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00002617          	auipc	a2,0x2
ffffffffc020020e:	c3e60613          	addi	a2,a2,-962 # ffffffffc0201e48 <commands+0x118>
ffffffffc0200212:	00002597          	auipc	a1,0x2
ffffffffc0200216:	c5e58593          	addi	a1,a1,-930 # ffffffffc0201e70 <commands+0x140>
ffffffffc020021a:	00002517          	auipc	a0,0x2
ffffffffc020021e:	c1e50513          	addi	a0,a0,-994 # ffffffffc0201e38 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00002617          	auipc	a2,0x2
ffffffffc020022a:	c5a60613          	addi	a2,a2,-934 # ffffffffc0201e80 <commands+0x150>
ffffffffc020022e:	00002597          	auipc	a1,0x2
ffffffffc0200232:	c7258593          	addi	a1,a1,-910 # ffffffffc0201ea0 <commands+0x170>
ffffffffc0200236:	00002517          	auipc	a0,0x2
ffffffffc020023a:	c0250513          	addi	a0,a0,-1022 # ffffffffc0201e38 <commands+0x108>
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
ffffffffc0200270:	00002517          	auipc	a0,0x2
ffffffffc0200274:	b0850513          	addi	a0,a0,-1272 # ffffffffc0201d78 <commands+0x48>
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
ffffffffc0200292:	00002517          	auipc	a0,0x2
ffffffffc0200296:	b0e50513          	addi	a0,a0,-1266 # ffffffffc0201da0 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00002c97          	auipc	s9,0x2
ffffffffc02002ac:	a88c8c93          	addi	s9,s9,-1400 # ffffffffc0201d30 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00002997          	auipc	s3,0x2
ffffffffc02002b4:	b1898993          	addi	s3,s3,-1256 # ffffffffc0201dc8 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00002917          	auipc	s2,0x2
ffffffffc02002bc:	b1890913          	addi	s2,s2,-1256 # ffffffffc0201dd0 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00002b17          	auipc	s6,0x2
ffffffffc02002c6:	b16b0b13          	addi	s6,s6,-1258 # ffffffffc0201dd8 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00002a97          	auipc	s5,0x2
ffffffffc02002ce:	b66a8a93          	addi	s5,s5,-1178 # ffffffffc0201e30 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	7a2010ef          	jal	ra,ffffffffc0201a78 <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	0f5010ef          	jal	ra,ffffffffc0201bdc <strchr>
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
ffffffffc02002fe:	00002d17          	auipc	s10,0x2
ffffffffc0200302:	a32d0d13          	addi	s10,s10,-1486 # ffffffffc0201d30 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	0a7010ef          	jal	ra,ffffffffc0201bb2 <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	093010ef          	jal	ra,ffffffffc0201bb2 <strcmp>
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
ffffffffc0200386:	057010ef          	jal	ra,ffffffffc0201bdc <strchr>
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
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0201df8 <commands+0xc8>
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
ffffffffc02003b0:	06430313          	addi	t1,t1,100 # ffffffffc0206410 <is_panic>
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
ffffffffc02003d4:	04f72023          	sw	a5,64(a4) # ffffffffc0206410 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d8:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003da:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003dc:	85aa                	mv	a1,a0
ffffffffc02003de:	00002517          	auipc	a0,0x2
ffffffffc02003e2:	ad250513          	addi	a0,a0,-1326 # ffffffffc0201eb0 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003e6:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e8:	ccfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003ec:	65a2                	ld	a1,8(sp)
ffffffffc02003ee:	8522                	mv	a0,s0
ffffffffc02003f0:	ca7ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc02003f4:	00002517          	auipc	a0,0x2
ffffffffc02003f8:	93450513          	addi	a0,a0,-1740 # ffffffffc0201d28 <etext+0x11c>
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
ffffffffc0200424:	72e010ef          	jal	ra,ffffffffc0201b52 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00002517          	auipc	a0,0x2
ffffffffc0200436:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0201ed0 <commands+0x1a0>
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
ffffffffc020044c:	7060106f          	j	ffffffffc0201b52 <sbi_set_timer>

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
ffffffffc0200456:	6e00106f          	j	ffffffffc0201b36 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	7140106f          	j	ffffffffc0201b6e <sbi_console_getchar>

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
ffffffffc0200484:	00002517          	auipc	a0,0x2
ffffffffc0200488:	b6450513          	addi	a0,a0,-1180 # ffffffffc0201fe8 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0202000 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	b7650513          	addi	a0,a0,-1162 # ffffffffc0202018 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00002517          	auipc	a0,0x2
ffffffffc02004b4:	b8050513          	addi	a0,a0,-1152 # ffffffffc0202030 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00002517          	auipc	a0,0x2
ffffffffc02004c2:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0202048 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	b9450513          	addi	a0,a0,-1132 # ffffffffc0202060 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00002517          	auipc	a0,0x2
ffffffffc02004de:	b9e50513          	addi	a0,a0,-1122 # ffffffffc0202078 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	ba850513          	addi	a0,a0,-1112 # ffffffffc0202090 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	bb250513          	addi	a0,a0,-1102 # ffffffffc02020a8 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	bbc50513          	addi	a0,a0,-1092 # ffffffffc02020c0 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	bc650513          	addi	a0,a0,-1082 # ffffffffc02020d8 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	bd050513          	addi	a0,a0,-1072 # ffffffffc02020f0 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	bda50513          	addi	a0,a0,-1062 # ffffffffc0202108 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	be450513          	addi	a0,a0,-1052 # ffffffffc0202120 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	bee50513          	addi	a0,a0,-1042 # ffffffffc0202138 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	bf850513          	addi	a0,a0,-1032 # ffffffffc0202150 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	c0250513          	addi	a0,a0,-1022 # ffffffffc0202168 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	c0c50513          	addi	a0,a0,-1012 # ffffffffc0202180 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	c1650513          	addi	a0,a0,-1002 # ffffffffc0202198 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	c2050513          	addi	a0,a0,-992 # ffffffffc02021b0 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	c2a50513          	addi	a0,a0,-982 # ffffffffc02021c8 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	c3450513          	addi	a0,a0,-972 # ffffffffc02021e0 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	c3e50513          	addi	a0,a0,-962 # ffffffffc02021f8 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	c4850513          	addi	a0,a0,-952 # ffffffffc0202210 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	c5250513          	addi	a0,a0,-942 # ffffffffc0202228 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	c5c50513          	addi	a0,a0,-932 # ffffffffc0202240 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	c6650513          	addi	a0,a0,-922 # ffffffffc0202258 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	c7050513          	addi	a0,a0,-912 # ffffffffc0202270 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	c7a50513          	addi	a0,a0,-902 # ffffffffc0202288 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	c8450513          	addi	a0,a0,-892 # ffffffffc02022a0 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	c8e50513          	addi	a0,a0,-882 # ffffffffc02022b8 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	c9450513          	addi	a0,a0,-876 # ffffffffc02022d0 <commands+0x5a0>
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
ffffffffc0200652:	00002517          	auipc	a0,0x2
ffffffffc0200656:	c9650513          	addi	a0,a0,-874 # ffffffffc02022e8 <commands+0x5b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00002517          	auipc	a0,0x2
ffffffffc020066e:	c9650513          	addi	a0,a0,-874 # ffffffffc0202300 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	c9e50513          	addi	a0,a0,-866 # ffffffffc0202318 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	ca650513          	addi	a0,a0,-858 # ffffffffc0202330 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	caa50513          	addi	a0,a0,-854 # ffffffffc0202348 <commands+0x618>
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
ffffffffc02006bc:	00002717          	auipc	a4,0x2
ffffffffc02006c0:	83070713          	addi	a4,a4,-2000 # ffffffffc0201eec <commands+0x1bc>
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
ffffffffc02006ce:	00002517          	auipc	a0,0x2
ffffffffc02006d2:	8b250513          	addi	a0,a0,-1870 # ffffffffc0201f80 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00002517          	auipc	a0,0x2
ffffffffc02006de:	88650513          	addi	a0,a0,-1914 # ffffffffc0201f60 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00002517          	auipc	a0,0x2
ffffffffc02006ea:	83a50513          	addi	a0,a0,-1990 # ffffffffc0201f20 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00002517          	auipc	a0,0x2
ffffffffc02006f6:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0201fa0 <commands+0x270>
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
ffffffffc020070a:	d2a70713          	addi	a4,a4,-726 # ffffffffc0206430 <ticks>
ffffffffc020070e:	631c                	ld	a5,0(a4)
ffffffffc0200710:	0785                	addi	a5,a5,1
ffffffffc0200712:	00006697          	auipc	a3,0x6
ffffffffc0200716:	d0f6bf23          	sd	a5,-738(a3) # ffffffffc0206430 <ticks>

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
ffffffffc020072c:	00002517          	auipc	a0,0x2
ffffffffc0200730:	89c50513          	addi	a0,a0,-1892 # ffffffffc0201fc8 <commands+0x298>
ffffffffc0200734:	983ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200738:	00002517          	auipc	a0,0x2
ffffffffc020073c:	80850513          	addi	a0,a0,-2040 # ffffffffc0201f40 <commands+0x210>
ffffffffc0200740:	977ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200744:	f07ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200748:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020074a:	06400593          	li	a1,100
ffffffffc020074e:	00002517          	auipc	a0,0x2
ffffffffc0200752:	86a50513          	addi	a0,a0,-1942 # ffffffffc0201fb8 <commands+0x288>
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

ffffffffc020082a <buddy_init>:
}

static void
buddy_init() {

}
ffffffffc020082a:	8082                	ret

ffffffffc020082c <buddy_nr_free_pages>:


static size_t
buddy_nr_free_pages(void) {
    size_t total_free_pages = 0;
    for (int i = 0; i < id_; i++) {
ffffffffc020082c:	00006797          	auipc	a5,0x6
ffffffffc0200830:	be878793          	addi	a5,a5,-1048 # ffffffffc0206414 <id_>
ffffffffc0200834:	4394                	lw	a3,0(a5)
ffffffffc0200836:	02d05b63          	blez	a3,ffffffffc020086c <buddy_nr_free_pages+0x40>
ffffffffc020083a:	36fd                	addiw	a3,a3,-1
ffffffffc020083c:	02069793          	slli	a5,a3,0x20
ffffffffc0200840:	9381                	srli	a5,a5,0x20
ffffffffc0200842:	00179693          	slli	a3,a5,0x1
ffffffffc0200846:	96be                	add	a3,a3,a5
ffffffffc0200848:	0692                	slli	a3,a3,0x4
ffffffffc020084a:	00006717          	auipc	a4,0x6
ffffffffc020084e:	c3e70713          	addi	a4,a4,-962 # ffffffffc0206488 <b+0x50>
ffffffffc0200852:	00006797          	auipc	a5,0x6
ffffffffc0200856:	c0678793          	addi	a5,a5,-1018 # ffffffffc0206458 <b+0x20>
ffffffffc020085a:	96ba                	add	a3,a3,a4
    size_t total_free_pages = 0;
ffffffffc020085c:	4501                	li	a0,0
        total_free_pages += b[i].curr_free;
ffffffffc020085e:	6398                	ld	a4,0(a5)
ffffffffc0200860:	03078793          	addi	a5,a5,48
ffffffffc0200864:	953a                	add	a0,a0,a4
    for (int i = 0; i < id_; i++) {
ffffffffc0200866:	fed79ce3          	bne	a5,a3,ffffffffc020085e <buddy_nr_free_pages+0x32>
ffffffffc020086a:	8082                	ret
    size_t total_free_pages = 0;
ffffffffc020086c:	4501                	li	a0,0
    }
    return total_free_pages;
}
ffffffffc020086e:	8082                	ret

ffffffffc0200870 <buddy_free_pages>:
    for (int i = 0; i < id_; i++) {
ffffffffc0200870:	00006797          	auipc	a5,0x6
ffffffffc0200874:	ba478793          	addi	a5,a5,-1116 # ffffffffc0206414 <id_>
ffffffffc0200878:	4390                	lw	a2,0(a5)
ffffffffc020087a:	10c05563          	blez	a2,ffffffffc0200984 <buddy_free_pages+0x114>
ffffffffc020087e:	367d                	addiw	a2,a2,-1
ffffffffc0200880:	02061793          	slli	a5,a2,0x20
ffffffffc0200884:	9381                	srli	a5,a5,0x20
ffffffffc0200886:	00179613          	slli	a2,a5,0x1
ffffffffc020088a:	963e                	add	a2,a2,a5
ffffffffc020088c:	0612                	slli	a2,a2,0x4
ffffffffc020088e:	00006717          	auipc	a4,0x6
ffffffffc0200892:	bda70713          	addi	a4,a4,-1062 # ffffffffc0206468 <b+0x30>
ffffffffc0200896:	00006797          	auipc	a5,0x6
ffffffffc020089a:	ba278793          	addi	a5,a5,-1118 # ffffffffc0206438 <b>
ffffffffc020089e:	963a                	add	a2,a2,a4
    struct buddy *buddy = NULL;
ffffffffc02008a0:	4581                	li	a1,0
        if (base >= t->begin_page && base < t->begin_page + t->size) {
ffffffffc02008a2:	7798                	ld	a4,40(a5)
ffffffffc02008a4:	00e56c63          	bltu	a0,a4,ffffffffc02008bc <buddy_free_pages+0x4c>
ffffffffc02008a8:	0007b803          	ld	a6,0(a5)
ffffffffc02008ac:	00281693          	slli	a3,a6,0x2
ffffffffc02008b0:	96c2                	add	a3,a3,a6
ffffffffc02008b2:	068e                	slli	a3,a3,0x3
ffffffffc02008b4:	9736                	add	a4,a4,a3
ffffffffc02008b6:	00e57363          	bleu	a4,a0,ffffffffc02008bc <buddy_free_pages+0x4c>
ffffffffc02008ba:	85be                	mv	a1,a5
ffffffffc02008bc:	03078793          	addi	a5,a5,48
    for (int i = 0; i < id_; i++) {
ffffffffc02008c0:	fef611e3          	bne	a2,a5,ffffffffc02008a2 <buddy_free_pages+0x32>
    if (!buddy) return;
ffffffffc02008c4:	c1e1                	beqz	a1,ffffffffc0200984 <buddy_free_pages+0x114>
    unsigned offset = base - buddy->begin_page;
ffffffffc02008c6:	759c                	ld	a5,40(a1)
ffffffffc02008c8:	00002717          	auipc	a4,0x2
ffffffffc02008cc:	d4870713          	addi	a4,a4,-696 # ffffffffc0202610 <commands+0x8e0>
ffffffffc02008d0:	40f507b3          	sub	a5,a0,a5
ffffffffc02008d4:	6308                	ld	a0,0(a4)
ffffffffc02008d6:	878d                	srai	a5,a5,0x3
    assert(offset >= 0 && offset < buddy->size);
ffffffffc02008d8:	6198                	ld	a4,0(a1)
    unsigned offset = base - buddy->begin_page;
ffffffffc02008da:	02a787b3          	mul	a5,a5,a0
    assert(offset >= 0 && offset < buddy->size);
ffffffffc02008de:	02079693          	slli	a3,a5,0x20
ffffffffc02008e2:	9281                	srli	a3,a3,0x20
    unsigned offset = base - buddy->begin_page;
ffffffffc02008e4:	0007851b          	sext.w	a0,a5
    assert(offset >= 0 && offset < buddy->size);
ffffffffc02008e8:	0ae6f863          	bleu	a4,a3,ffffffffc0200998 <buddy_free_pages+0x128>
    id = offset + buddy->size - 1;
ffffffffc02008ec:	fff7079b          	addiw	a5,a4,-1
ffffffffc02008f0:	9fa9                	addw	a5,a5,a0
    for (; buddy->longest[id]; id = PARENT(id)) {
ffffffffc02008f2:	6588                	ld	a0,8(a1)
ffffffffc02008f4:	02079713          	slli	a4,a5,0x20
ffffffffc02008f8:	8375                	srli	a4,a4,0x1d
ffffffffc02008fa:	972a                	add	a4,a4,a0
ffffffffc02008fc:	6314                	ld	a3,0(a4)
ffffffffc02008fe:	cad1                	beqz	a3,ffffffffc0200992 <buddy_free_pages+0x122>
        if (id == 0)
ffffffffc0200900:	c3d1                	beqz	a5,ffffffffc0200984 <buddy_free_pages+0x114>
        sn *= 2;
ffffffffc0200902:	4689                	li	a3,2
ffffffffc0200904:	a021                	j	ffffffffc020090c <buddy_free_pages+0x9c>
ffffffffc0200906:	0016969b          	slliw	a3,a3,0x1
        if (id == 0)
ffffffffc020090a:	cfad                	beqz	a5,ffffffffc0200984 <buddy_free_pages+0x114>
    for (; buddy->longest[id]; id = PARENT(id)) {
ffffffffc020090c:	2785                	addiw	a5,a5,1
ffffffffc020090e:	0017d79b          	srliw	a5,a5,0x1
ffffffffc0200912:	37fd                	addiw	a5,a5,-1
ffffffffc0200914:	02079713          	slli	a4,a5,0x20
ffffffffc0200918:	8375                	srli	a4,a4,0x1d
ffffffffc020091a:	972a                	add	a4,a4,a0
ffffffffc020091c:	6310                	ld	a2,0(a4)
ffffffffc020091e:	f665                	bnez	a2,ffffffffc0200906 <buddy_free_pages+0x96>
ffffffffc0200920:	02069613          	slli	a2,a3,0x20
ffffffffc0200924:	9201                	srli	a2,a2,0x20
    buddy->longest[id] = sn;
ffffffffc0200926:	e310                	sd	a2,0(a4)
    buddy->curr_free += sn;
ffffffffc0200928:	7198                	ld	a4,32(a1)
ffffffffc020092a:	9732                	add	a4,a4,a2
ffffffffc020092c:	f198                	sd	a4,32(a1)
    while (id) {
ffffffffc020092e:	cbb9                	beqz	a5,ffffffffc0200984 <buddy_free_pages+0x114>
        id = PARENT(id);
ffffffffc0200930:	2785                	addiw	a5,a5,1
ffffffffc0200932:	0017d59b          	srliw	a1,a5,0x1
ffffffffc0200936:	35fd                	addiw	a1,a1,-1
        left_longest = buddy->longest[LEFT_LEAF(id)];
ffffffffc0200938:	0015961b          	slliw	a2,a1,0x1
        right_longest = buddy->longest[RIGHT_LEAF(id)];
ffffffffc020093c:	ffe7f713          	andi	a4,a5,-2
        left_longest = buddy->longest[LEFT_LEAF(id)];
ffffffffc0200940:	2605                	addiw	a2,a2,1
ffffffffc0200942:	1602                	slli	a2,a2,0x20
        right_longest = buddy->longest[RIGHT_LEAF(id)];
ffffffffc0200944:	1702                	slli	a4,a4,0x20
        left_longest = buddy->longest[LEFT_LEAF(id)];
ffffffffc0200946:	9201                	srli	a2,a2,0x20
        right_longest = buddy->longest[RIGHT_LEAF(id)];
ffffffffc0200948:	9301                	srli	a4,a4,0x20
        left_longest = buddy->longest[LEFT_LEAF(id)];
ffffffffc020094a:	060e                	slli	a2,a2,0x3
        right_longest = buddy->longest[RIGHT_LEAF(id)];
ffffffffc020094c:	070e                	slli	a4,a4,0x3
ffffffffc020094e:	972a                	add	a4,a4,a0
        left_longest = buddy->longest[LEFT_LEAF(id)];
ffffffffc0200950:	962a                	add	a2,a2,a0
        right_longest = buddy->longest[RIGHT_LEAF(id)];
ffffffffc0200952:	00072883          	lw	a7,0(a4)
        left_longest = buddy->longest[LEFT_LEAF(id)];
ffffffffc0200956:	4210                	lw	a2,0(a2)
        sn *= 2;
ffffffffc0200958:	0016981b          	slliw	a6,a3,0x1
ffffffffc020095c:	02059713          	slli	a4,a1,0x20
ffffffffc0200960:	8375                	srli	a4,a4,0x1d
ffffffffc0200962:	0008069b          	sext.w	a3,a6
        if (left_longest + right_longest == sn)
ffffffffc0200966:	0116033b          	addw	t1,a2,a7
        id = PARENT(id);
ffffffffc020096a:	0005879b          	sext.w	a5,a1
        if (left_longest + right_longest == sn)
ffffffffc020096e:	972a                	add	a4,a4,a0
ffffffffc0200970:	00d30b63          	beq	t1,a3,ffffffffc0200986 <buddy_free_pages+0x116>
            buddy->longest[id] = MAX(left_longest, right_longest);
ffffffffc0200974:	85b2                	mv	a1,a2
ffffffffc0200976:	01167363          	bleu	a7,a2,ffffffffc020097c <buddy_free_pages+0x10c>
ffffffffc020097a:	85c6                	mv	a1,a7
ffffffffc020097c:	1582                	slli	a1,a1,0x20
ffffffffc020097e:	9181                	srli	a1,a1,0x20
ffffffffc0200980:	e30c                	sd	a1,0(a4)
    while (id) {
ffffffffc0200982:	f7dd                	bnez	a5,ffffffffc0200930 <buddy_free_pages+0xc0>
ffffffffc0200984:	8082                	ret
            buddy->longest[id] = sn;
ffffffffc0200986:	1802                	slli	a6,a6,0x20
ffffffffc0200988:	02085813          	srli	a6,a6,0x20
ffffffffc020098c:	01073023          	sd	a6,0(a4)
ffffffffc0200990:	bf79                	j	ffffffffc020092e <buddy_free_pages+0xbe>
    for (; buddy->longest[id]; id = PARENT(id)) {
ffffffffc0200992:	4605                	li	a2,1
    sn = 1;
ffffffffc0200994:	4685                	li	a3,1
ffffffffc0200996:	bf41                	j	ffffffffc0200926 <buddy_free_pages+0xb6>
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0200998:	1141                	addi	sp,sp,-16
    assert(offset >= 0 && offset < buddy->size);
ffffffffc020099a:	00002697          	auipc	a3,0x2
ffffffffc020099e:	c7e68693          	addi	a3,a3,-898 # ffffffffc0202618 <commands+0x8e8>
ffffffffc02009a2:	00002617          	auipc	a2,0x2
ffffffffc02009a6:	c9e60613          	addi	a2,a2,-866 # ffffffffc0202640 <commands+0x910>
ffffffffc02009aa:	08a00593          	li	a1,138
ffffffffc02009ae:	00002517          	auipc	a0,0x2
ffffffffc02009b2:	caa50513          	addi	a0,a0,-854 # ffffffffc0202658 <commands+0x928>
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc02009b6:	e406                	sd	ra,8(sp)
    assert(offset >= 0 && offset < buddy->size);
ffffffffc02009b8:	9f5ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02009bc <buddy_alloc_pages>:
    assert(n > 0);
ffffffffc02009bc:	12050263          	beqz	a0,ffffffffc0200ae0 <buddy_alloc_pages+0x124>
    if (!IS_POWER_OF_2(n))
ffffffffc02009c0:	fff50793          	addi	a5,a0,-1
ffffffffc02009c4:	8fe9                	and	a5,a5,a0
ffffffffc02009c6:	e7ed                	bnez	a5,ffffffffc0200ab0 <buddy_alloc_pages+0xf4>
    for (int i = 0; i < id_; i++) {
ffffffffc02009c8:	00006797          	auipc	a5,0x6
ffffffffc02009cc:	a4c78793          	addi	a5,a5,-1460 # ffffffffc0206414 <id_>
ffffffffc02009d0:	4394                	lw	a3,0(a5)
ffffffffc02009d2:	02d05a63          	blez	a3,ffffffffc0200a06 <buddy_alloc_pages+0x4a>
        if (b[i].longest[id] >= n) {
ffffffffc02009d6:	00006317          	auipc	t1,0x6
ffffffffc02009da:	a6230313          	addi	t1,t1,-1438 # ffffffffc0206438 <b>
ffffffffc02009de:	00833583          	ld	a1,8(t1)
ffffffffc02009e2:	619c                	ld	a5,0(a1)
ffffffffc02009e4:	02a7f363          	bleu	a0,a5,ffffffffc0200a0a <buddy_alloc_pages+0x4e>
ffffffffc02009e8:	00006797          	auipc	a5,0x6
ffffffffc02009ec:	a8878793          	addi	a5,a5,-1400 # ffffffffc0206470 <b+0x38>
    for (int i = 0; i < id_; i++) {
ffffffffc02009f0:	4801                	li	a6,0
ffffffffc02009f2:	a039                	j	ffffffffc0200a00 <buddy_alloc_pages+0x44>
        if (b[i].longest[id] >= n) {
ffffffffc02009f4:	638c                	ld	a1,0(a5)
ffffffffc02009f6:	03078793          	addi	a5,a5,48
ffffffffc02009fa:	6198                	ld	a4,0(a1)
ffffffffc02009fc:	00a77863          	bleu	a0,a4,ffffffffc0200a0c <buddy_alloc_pages+0x50>
    for (int i = 0; i < id_; i++) {
ffffffffc0200a00:	2805                	addiw	a6,a6,1
ffffffffc0200a02:	ff0699e3          	bne	a3,a6,ffffffffc02009f4 <buddy_alloc_pages+0x38>
        return NULL;
ffffffffc0200a06:	4501                	li	a0,0
}
ffffffffc0200a08:	8082                	ret
    for (int i = 0; i < id_; i++) {
ffffffffc0200a0a:	4801                	li	a6,0
    for (sn = buddy->size; sn != n; sn /= 2) {
ffffffffc0200a0c:	00181893          	slli	a7,a6,0x1
ffffffffc0200a10:	01088733          	add	a4,a7,a6
ffffffffc0200a14:	0712                	slli	a4,a4,0x4
ffffffffc0200a16:	971a                	add	a4,a4,t1
ffffffffc0200a18:	6314                	ld	a3,0(a4)
    size_t id = 0;
ffffffffc0200a1a:	4781                	li	a5,0
    for (sn = buddy->size; sn != n; sn /= 2) {
ffffffffc0200a1c:	00d51863          	bne	a0,a3,ffffffffc0200a2c <buddy_alloc_pages+0x70>
ffffffffc0200a20:	a855                	j	ffffffffc0200ad4 <buddy_alloc_pages+0x118>
            id = LEFT_LEAF(id);
ffffffffc0200a22:	0786                	slli	a5,a5,0x1
    for (sn = buddy->size; sn != n; sn /= 2) {
ffffffffc0200a24:	8285                	srli	a3,a3,0x1
            id = LEFT_LEAF(id);
ffffffffc0200a26:	0785                	addi	a5,a5,1
    for (sn = buddy->size; sn != n; sn /= 2) {
ffffffffc0200a28:	00d50d63          	beq	a0,a3,ffffffffc0200a42 <buddy_alloc_pages+0x86>
        if (buddy->longest[LEFT_LEAF(id)] >= n)
ffffffffc0200a2c:	00479713          	slli	a4,a5,0x4
ffffffffc0200a30:	972e                	add	a4,a4,a1
ffffffffc0200a32:	6718                	ld	a4,8(a4)
ffffffffc0200a34:	fea777e3          	bleu	a0,a4,ffffffffc0200a22 <buddy_alloc_pages+0x66>
            id = RIGHT_LEAF(id);
ffffffffc0200a38:	0785                	addi	a5,a5,1
    for (sn = buddy->size; sn != n; sn /= 2) {
ffffffffc0200a3a:	8285                	srli	a3,a3,0x1
            id = RIGHT_LEAF(id);
ffffffffc0200a3c:	0786                	slli	a5,a5,0x1
    for (sn = buddy->size; sn != n; sn /= 2) {
ffffffffc0200a3e:	fed517e3          	bne	a0,a3,ffffffffc0200a2c <buddy_alloc_pages+0x70>
    offset = (id + 1) * sn - buddy->size;
ffffffffc0200a42:	00178713          	addi	a4,a5,1
ffffffffc0200a46:	02a70e33          	mul	t3,a4,a0
    buddy->longest[id] = 0;
ffffffffc0200a4a:	00379613          	slli	a2,a5,0x3
    offset = (id + 1) * sn - buddy->size;
ffffffffc0200a4e:	010886b3          	add	a3,a7,a6
    buddy->longest[id] = 0;
ffffffffc0200a52:	962e                	add	a2,a2,a1
    offset = (id + 1) * sn - buddy->size;
ffffffffc0200a54:	0692                	slli	a3,a3,0x4
    buddy->longest[id] = 0;
ffffffffc0200a56:	00063023          	sd	zero,0(a2)
    offset = (id + 1) * sn - buddy->size;
ffffffffc0200a5a:	969a                	add	a3,a3,t1
ffffffffc0200a5c:	6294                	ld	a3,0(a3)
ffffffffc0200a5e:	40de0e33          	sub	t3,t3,a3
    while (id) {
ffffffffc0200a62:	e781                	bnez	a5,ffffffffc0200a6a <buddy_alloc_pages+0xae>
ffffffffc0200a64:	a02d                	j	ffffffffc0200a8e <buddy_alloc_pages+0xd2>
ffffffffc0200a66:	00178713          	addi	a4,a5,1
        id = PARENT(id);
ffffffffc0200a6a:	8305                	srli	a4,a4,0x1
ffffffffc0200a6c:	fff70793          	addi	a5,a4,-1
        buddy->longest[id] = MAX(buddy->longest[LEFT_LEAF(id)], buddy->longest[RIGHT_LEAF(id)]);
ffffffffc0200a70:	00479693          	slli	a3,a5,0x4
ffffffffc0200a74:	0712                	slli	a4,a4,0x4
ffffffffc0200a76:	972e                	add	a4,a4,a1
ffffffffc0200a78:	96ae                	add	a3,a3,a1
ffffffffc0200a7a:	6310                	ld	a2,0(a4)
ffffffffc0200a7c:	6694                	ld	a3,8(a3)
ffffffffc0200a7e:	00379713          	slli	a4,a5,0x3
ffffffffc0200a82:	972e                	add	a4,a4,a1
ffffffffc0200a84:	00c6f363          	bleu	a2,a3,ffffffffc0200a8a <buddy_alloc_pages+0xce>
ffffffffc0200a88:	86b2                	mv	a3,a2
ffffffffc0200a8a:	e314                	sd	a3,0(a4)
    while (id) {
ffffffffc0200a8c:	ffe9                	bnez	a5,ffffffffc0200a66 <buddy_alloc_pages+0xaa>
    buddy->curr_free -= n;
ffffffffc0200a8e:	9846                	add	a6,a6,a7
ffffffffc0200a90:	0812                	slli	a6,a6,0x4
ffffffffc0200a92:	981a                	add	a6,a6,t1
ffffffffc0200a94:	02083783          	ld	a5,32(a6)
    return buddy->begin_page + offset;
ffffffffc0200a98:	002e1713          	slli	a4,t3,0x2
ffffffffc0200a9c:	02883683          	ld	a3,40(a6)
ffffffffc0200aa0:	9772                	add	a4,a4,t3
    buddy->curr_free -= n;
ffffffffc0200aa2:	8f89                	sub	a5,a5,a0
    return buddy->begin_page + offset;
ffffffffc0200aa4:	070e                	slli	a4,a4,0x3
    buddy->curr_free -= n;
ffffffffc0200aa6:	02f83023          	sd	a5,32(a6)
    return buddy->begin_page + offset;
ffffffffc0200aaa:	00e68533          	add	a0,a3,a4
ffffffffc0200aae:	8082                	ret
    size |= size >> 1;
ffffffffc0200ab0:	00155793          	srli	a5,a0,0x1
ffffffffc0200ab4:	8fc9                	or	a5,a5,a0
    size |= size >> 2;
ffffffffc0200ab6:	0027d713          	srli	a4,a5,0x2
ffffffffc0200aba:	8fd9                	or	a5,a5,a4
    size |= size >> 4;
ffffffffc0200abc:	0047d713          	srli	a4,a5,0x4
ffffffffc0200ac0:	8fd9                	or	a5,a5,a4
    size |= size >> 8;
ffffffffc0200ac2:	0087d713          	srli	a4,a5,0x8
ffffffffc0200ac6:	8fd9                	or	a5,a5,a4
    size |= size >> 16;
ffffffffc0200ac8:	0107d513          	srli	a0,a5,0x10
ffffffffc0200acc:	8fc9                	or	a5,a5,a0
    return size + 1;
ffffffffc0200ace:	00178513          	addi	a0,a5,1
ffffffffc0200ad2:	bddd                	j	ffffffffc02009c8 <buddy_alloc_pages+0xc>
    buddy->longest[id] = 0;
ffffffffc0200ad4:	0005b023          	sd	zero,0(a1)
    offset = (id + 1) * sn - buddy->size;
ffffffffc0200ad8:	6318                	ld	a4,0(a4)
ffffffffc0200ada:	40e50e33          	sub	t3,a0,a4
    while (id) {
ffffffffc0200ade:	bf45                	j	ffffffffc0200a8e <buddy_alloc_pages+0xd2>
buddy_alloc_pages(size_t n) {
ffffffffc0200ae0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200ae2:	00002697          	auipc	a3,0x2
ffffffffc0200ae6:	87e68693          	addi	a3,a3,-1922 # ffffffffc0202360 <commands+0x630>
ffffffffc0200aea:	00002617          	auipc	a2,0x2
ffffffffc0200aee:	b5660613          	addi	a2,a2,-1194 # ffffffffc0202640 <commands+0x910>
ffffffffc0200af2:	05000593          	li	a1,80
ffffffffc0200af6:	00002517          	auipc	a0,0x2
ffffffffc0200afa:	b6250513          	addi	a0,a0,-1182 # ffffffffc0202658 <commands+0x928>
buddy_alloc_pages(size_t n) {
ffffffffc0200afe:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200b00:	8adff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200b04 <buddy_check>:


static void
buddy_check(void) {
ffffffffc0200b04:	715d                	addi	sp,sp,-80
ffffffffc0200b06:	e0a2                	sd	s0,64(sp)
    for (int i = 0; i < id_; i++) {
ffffffffc0200b08:	00006417          	auipc	s0,0x6
ffffffffc0200b0c:	90c40413          	addi	s0,s0,-1780 # ffffffffc0206414 <id_>
ffffffffc0200b10:	4014                	lw	a3,0(s0)
buddy_check(void) {
ffffffffc0200b12:	e486                	sd	ra,72(sp)
ffffffffc0200b14:	fc26                	sd	s1,56(sp)
ffffffffc0200b16:	f84a                	sd	s2,48(sp)
ffffffffc0200b18:	f44e                	sd	s3,40(sp)
ffffffffc0200b1a:	f052                	sd	s4,32(sp)
ffffffffc0200b1c:	ec56                	sd	s5,24(sp)
ffffffffc0200b1e:	e85a                	sd	s6,16(sp)
ffffffffc0200b20:	e45e                	sd	s7,8(sp)
    for (int i = 0; i < id_; i++) {
ffffffffc0200b22:	46d05363          	blez	a3,ffffffffc0200f88 <buddy_check+0x484>
ffffffffc0200b26:	36fd                	addiw	a3,a3,-1
ffffffffc0200b28:	02069793          	slli	a5,a3,0x20
ffffffffc0200b2c:	9381                	srli	a5,a5,0x20
ffffffffc0200b2e:	00179693          	slli	a3,a5,0x1
ffffffffc0200b32:	96be                	add	a3,a3,a5
ffffffffc0200b34:	0692                	slli	a3,a3,0x4
ffffffffc0200b36:	00006717          	auipc	a4,0x6
ffffffffc0200b3a:	95270713          	addi	a4,a4,-1710 # ffffffffc0206488 <b+0x50>
ffffffffc0200b3e:	00006797          	auipc	a5,0x6
ffffffffc0200b42:	91a78793          	addi	a5,a5,-1766 # ffffffffc0206458 <b+0x20>
ffffffffc0200b46:	96ba                	add	a3,a3,a4
    size_t total_free_pages = 0;
ffffffffc0200b48:	4481                	li	s1,0
        total_free_pages += b[i].curr_free;
ffffffffc0200b4a:	6398                	ld	a4,0(a5)
ffffffffc0200b4c:	03078793          	addi	a5,a5,48
ffffffffc0200b50:	94ba                	add	s1,s1,a4
    for (int i = 0; i < id_; i++) {
ffffffffc0200b52:	fed79ce3          	bne	a5,a3,ffffffffc0200b4a <buddy_check+0x46>
    size_t total = buddy_nr_free_pages();
    cprintf("total: %d\n", total);
ffffffffc0200b56:	85a6                	mv	a1,s1
ffffffffc0200b58:	00002517          	auipc	a0,0x2
ffffffffc0200b5c:	81050513          	addi	a0,a0,-2032 # ffffffffc0202368 <commands+0x638>
ffffffffc0200b60:	d56ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>

    struct Page *p0 = alloc_page();
ffffffffc0200b64:	4505                	li	a0,1
ffffffffc0200b66:	129000ef          	jal	ra,ffffffffc020148e <alloc_pages>
ffffffffc0200b6a:	892a                	mv	s2,a0
    assert(p0 != NULL);
ffffffffc0200b6c:	68050663          	beqz	a0,ffffffffc02011f8 <buddy_check+0x6f4>
    for (int i = 0; i < id_; i++) {
ffffffffc0200b70:	4010                	lw	a2,0(s0)
    size_t total_free_pages = 0;
ffffffffc0200b72:	4701                	li	a4,0
    for (int i = 0; i < id_; i++) {
ffffffffc0200b74:	02c05a63          	blez	a2,ffffffffc0200ba8 <buddy_check+0xa4>
ffffffffc0200b78:	367d                	addiw	a2,a2,-1
ffffffffc0200b7a:	02061793          	slli	a5,a2,0x20
ffffffffc0200b7e:	9381                	srli	a5,a5,0x20
ffffffffc0200b80:	00179613          	slli	a2,a5,0x1
ffffffffc0200b84:	963e                	add	a2,a2,a5
ffffffffc0200b86:	00006717          	auipc	a4,0x6
ffffffffc0200b8a:	90270713          	addi	a4,a4,-1790 # ffffffffc0206488 <b+0x50>
ffffffffc0200b8e:	0612                	slli	a2,a2,0x4
ffffffffc0200b90:	963a                	add	a2,a2,a4
ffffffffc0200b92:	00006797          	auipc	a5,0x6
ffffffffc0200b96:	8c678793          	addi	a5,a5,-1850 # ffffffffc0206458 <b+0x20>
    size_t total_free_pages = 0;
ffffffffc0200b9a:	4701                	li	a4,0
        total_free_pages += b[i].curr_free;
ffffffffc0200b9c:	6394                	ld	a3,0(a5)
ffffffffc0200b9e:	03078793          	addi	a5,a5,48
ffffffffc0200ba2:	9736                	add	a4,a4,a3
    for (int i = 0; i < id_; i++) {
ffffffffc0200ba4:	fec79ce3          	bne	a5,a2,ffffffffc0200b9c <buddy_check+0x98>
    assert(buddy_nr_free_pages() == total - 1);
ffffffffc0200ba8:	fff48793          	addi	a5,s1,-1
ffffffffc0200bac:	62e79663          	bne	a5,a4,ffffffffc02011d8 <buddy_check+0x6d4>
    assert(p0 == b[0].begin_page);
ffffffffc0200bb0:	00006a17          	auipc	s4,0x6
ffffffffc0200bb4:	888a0a13          	addi	s4,s4,-1912 # ffffffffc0206438 <b>
ffffffffc0200bb8:	028a3783          	ld	a5,40(s4)
ffffffffc0200bbc:	5f279e63          	bne	a5,s2,ffffffffc02011b8 <buddy_check+0x6b4>

    struct Page *p1 = alloc_page();
ffffffffc0200bc0:	4505                	li	a0,1
ffffffffc0200bc2:	0cd000ef          	jal	ra,ffffffffc020148e <alloc_pages>
ffffffffc0200bc6:	89aa                	mv	s3,a0
    assert(p1 != NULL);
ffffffffc0200bc8:	5c050863          	beqz	a0,ffffffffc0201198 <buddy_check+0x694>
    for (int i = 0; i < id_; i++) {
ffffffffc0200bcc:	4010                	lw	a2,0(s0)
    size_t total_free_pages = 0;
ffffffffc0200bce:	4701                	li	a4,0
    for (int i = 0; i < id_; i++) {
ffffffffc0200bd0:	02c05a63          	blez	a2,ffffffffc0200c04 <buddy_check+0x100>
ffffffffc0200bd4:	367d                	addiw	a2,a2,-1
ffffffffc0200bd6:	02061793          	slli	a5,a2,0x20
ffffffffc0200bda:	9381                	srli	a5,a5,0x20
ffffffffc0200bdc:	00179613          	slli	a2,a5,0x1
ffffffffc0200be0:	963e                	add	a2,a2,a5
ffffffffc0200be2:	00006717          	auipc	a4,0x6
ffffffffc0200be6:	8a670713          	addi	a4,a4,-1882 # ffffffffc0206488 <b+0x50>
ffffffffc0200bea:	0612                	slli	a2,a2,0x4
ffffffffc0200bec:	963a                	add	a2,a2,a4
ffffffffc0200bee:	00006797          	auipc	a5,0x6
ffffffffc0200bf2:	86a78793          	addi	a5,a5,-1942 # ffffffffc0206458 <b+0x20>
    size_t total_free_pages = 0;
ffffffffc0200bf6:	4701                	li	a4,0
        total_free_pages += b[i].curr_free;
ffffffffc0200bf8:	6394                	ld	a3,0(a5)
ffffffffc0200bfa:	03078793          	addi	a5,a5,48
ffffffffc0200bfe:	9736                	add	a4,a4,a3
    for (int i = 0; i < id_; i++) {
ffffffffc0200c00:	fec79ce3          	bne	a5,a2,ffffffffc0200bf8 <buddy_check+0xf4>
    assert(buddy_nr_free_pages() == total - 2);
ffffffffc0200c04:	ffe48793          	addi	a5,s1,-2
ffffffffc0200c08:	56e79863          	bne	a5,a4,ffffffffc0201178 <buddy_check+0x674>
    assert(p1 == b[0].begin_page + 1);
ffffffffc0200c0c:	028a3783          	ld	a5,40(s4)
ffffffffc0200c10:	02878793          	addi	a5,a5,40
ffffffffc0200c14:	54f99263          	bne	s3,a5,ffffffffc0201158 <buddy_check+0x654>

    assert(p1 == p0 + 1);
ffffffffc0200c18:	02890793          	addi	a5,s2,40
ffffffffc0200c1c:	48f99e63          	bne	s3,a5,ffffffffc02010b8 <buddy_check+0x5b4>

    buddy_free_pages(p0, 1);
ffffffffc0200c20:	4585                	li	a1,1
ffffffffc0200c22:	854a                	mv	a0,s2
ffffffffc0200c24:	c4dff0ef          	jal	ra,ffffffffc0200870 <buddy_free_pages>
    buddy_free_pages(p1, 1);
ffffffffc0200c28:	4585                	li	a1,1
ffffffffc0200c2a:	854e                	mv	a0,s3
ffffffffc0200c2c:	c45ff0ef          	jal	ra,ffffffffc0200870 <buddy_free_pages>
    for (int i = 0; i < id_; i++) {
ffffffffc0200c30:	4010                	lw	a2,0(s0)
ffffffffc0200c32:	34c05d63          	blez	a2,ffffffffc0200f8c <buddy_check+0x488>
ffffffffc0200c36:	367d                	addiw	a2,a2,-1
ffffffffc0200c38:	02061793          	slli	a5,a2,0x20
ffffffffc0200c3c:	9381                	srli	a5,a5,0x20
ffffffffc0200c3e:	00179613          	slli	a2,a5,0x1
ffffffffc0200c42:	963e                	add	a2,a2,a5
ffffffffc0200c44:	00006717          	auipc	a4,0x6
ffffffffc0200c48:	84470713          	addi	a4,a4,-1980 # ffffffffc0206488 <b+0x50>
ffffffffc0200c4c:	0612                	slli	a2,a2,0x4
ffffffffc0200c4e:	963a                	add	a2,a2,a4
ffffffffc0200c50:	00006797          	auipc	a5,0x6
ffffffffc0200c54:	80878793          	addi	a5,a5,-2040 # ffffffffc0206458 <b+0x20>
    size_t total_free_pages = 0;
ffffffffc0200c58:	4701                	li	a4,0
        total_free_pages += b[i].curr_free;
ffffffffc0200c5a:	6394                	ld	a3,0(a5)
ffffffffc0200c5c:	03078793          	addi	a5,a5,48
ffffffffc0200c60:	9736                	add	a4,a4,a3
    for (int i = 0; i < id_; i++) {
ffffffffc0200c62:	fec79ce3          	bne	a5,a2,ffffffffc0200c5a <buddy_check+0x156>
    assert(buddy_nr_free_pages() == total);
ffffffffc0200c66:	42e49963          	bne	s1,a4,ffffffffc0201098 <buddy_check+0x594>

    p0 = buddy_alloc_pages(11);
ffffffffc0200c6a:	452d                	li	a0,11
ffffffffc0200c6c:	d51ff0ef          	jal	ra,ffffffffc02009bc <buddy_alloc_pages>
    for (int i = 0; i < id_; i++) {
ffffffffc0200c70:	4010                	lw	a2,0(s0)
    p0 = buddy_alloc_pages(11);
ffffffffc0200c72:	89aa                	mv	s3,a0
    for (int i = 0; i < id_; i++) {
ffffffffc0200c74:	30c05e63          	blez	a2,ffffffffc0200f90 <buddy_check+0x48c>
ffffffffc0200c78:	367d                	addiw	a2,a2,-1
ffffffffc0200c7a:	02061793          	slli	a5,a2,0x20
ffffffffc0200c7e:	9381                	srli	a5,a5,0x20
ffffffffc0200c80:	00179613          	slli	a2,a5,0x1
ffffffffc0200c84:	963e                	add	a2,a2,a5
ffffffffc0200c86:	00006717          	auipc	a4,0x6
ffffffffc0200c8a:	80270713          	addi	a4,a4,-2046 # ffffffffc0206488 <b+0x50>
ffffffffc0200c8e:	0612                	slli	a2,a2,0x4
ffffffffc0200c90:	963a                	add	a2,a2,a4
ffffffffc0200c92:	00005797          	auipc	a5,0x5
ffffffffc0200c96:	7c678793          	addi	a5,a5,1990 # ffffffffc0206458 <b+0x20>
    size_t total_free_pages = 0;
ffffffffc0200c9a:	4701                	li	a4,0
        total_free_pages += b[i].curr_free;
ffffffffc0200c9c:	6394                	ld	a3,0(a5)
ffffffffc0200c9e:	03078793          	addi	a5,a5,48
ffffffffc0200ca2:	9736                	add	a4,a4,a3
    for (int i = 0; i < id_; i++) {
ffffffffc0200ca4:	fec79ce3          	bne	a5,a2,ffffffffc0200c9c <buddy_check+0x198>
    assert(buddy_nr_free_pages() == total - 16);
ffffffffc0200ca8:	ff048793          	addi	a5,s1,-16
ffffffffc0200cac:	34e79663          	bne	a5,a4,ffffffffc0200ff8 <buddy_check+0x4f4>

    p1 = buddy_alloc_pages(100);
ffffffffc0200cb0:	06400513          	li	a0,100
ffffffffc0200cb4:	d09ff0ef          	jal	ra,ffffffffc02009bc <buddy_alloc_pages>
    for (int i = 0; i < id_; i++) {
ffffffffc0200cb8:	4010                	lw	a2,0(s0)
    p1 = buddy_alloc_pages(100);
ffffffffc0200cba:	892a                	mv	s2,a0
    for (int i = 0; i < id_; i++) {
ffffffffc0200cbc:	2cc05c63          	blez	a2,ffffffffc0200f94 <buddy_check+0x490>
ffffffffc0200cc0:	367d                	addiw	a2,a2,-1
ffffffffc0200cc2:	02061793          	slli	a5,a2,0x20
ffffffffc0200cc6:	9381                	srli	a5,a5,0x20
ffffffffc0200cc8:	00179613          	slli	a2,a5,0x1
ffffffffc0200ccc:	963e                	add	a2,a2,a5
ffffffffc0200cce:	00005717          	auipc	a4,0x5
ffffffffc0200cd2:	7ba70713          	addi	a4,a4,1978 # ffffffffc0206488 <b+0x50>
ffffffffc0200cd6:	0612                	slli	a2,a2,0x4
ffffffffc0200cd8:	963a                	add	a2,a2,a4
ffffffffc0200cda:	00005797          	auipc	a5,0x5
ffffffffc0200cde:	77e78793          	addi	a5,a5,1918 # ffffffffc0206458 <b+0x20>
    size_t total_free_pages = 0;
ffffffffc0200ce2:	4701                	li	a4,0
        total_free_pages += b[i].curr_free;
ffffffffc0200ce4:	6394                	ld	a3,0(a5)
ffffffffc0200ce6:	03078793          	addi	a5,a5,48
ffffffffc0200cea:	9736                	add	a4,a4,a3
    for (int i = 0; i < id_; i++) {
ffffffffc0200cec:	fec79ce3          	bne	a5,a2,ffffffffc0200ce4 <buddy_check+0x1e0>
    assert(buddy_nr_free_pages() == total - 144);
ffffffffc0200cf0:	f7048793          	addi	a5,s1,-144
ffffffffc0200cf4:	2ee79263          	bne	a5,a4,ffffffffc0200fd8 <buddy_check+0x4d4>

    buddy_free_pages(p0, -1);
ffffffffc0200cf8:	55fd                	li	a1,-1
ffffffffc0200cfa:	854e                	mv	a0,s3
ffffffffc0200cfc:	b75ff0ef          	jal	ra,ffffffffc0200870 <buddy_free_pages>
    buddy_free_pages(p1, -1);
ffffffffc0200d00:	55fd                	li	a1,-1
ffffffffc0200d02:	854a                	mv	a0,s2
ffffffffc0200d04:	b6dff0ef          	jal	ra,ffffffffc0200870 <buddy_free_pages>
    for (int i = 0; i < id_; i++) {
ffffffffc0200d08:	4010                	lw	a2,0(s0)
ffffffffc0200d0a:	28c05763          	blez	a2,ffffffffc0200f98 <buddy_check+0x494>
ffffffffc0200d0e:	367d                	addiw	a2,a2,-1
ffffffffc0200d10:	02061793          	slli	a5,a2,0x20
ffffffffc0200d14:	9381                	srli	a5,a5,0x20
ffffffffc0200d16:	00179613          	slli	a2,a5,0x1
ffffffffc0200d1a:	963e                	add	a2,a2,a5
ffffffffc0200d1c:	00005717          	auipc	a4,0x5
ffffffffc0200d20:	76c70713          	addi	a4,a4,1900 # ffffffffc0206488 <b+0x50>
ffffffffc0200d24:	0612                	slli	a2,a2,0x4
ffffffffc0200d26:	963a                	add	a2,a2,a4
ffffffffc0200d28:	00005797          	auipc	a5,0x5
ffffffffc0200d2c:	73078793          	addi	a5,a5,1840 # ffffffffc0206458 <b+0x20>
    size_t total_free_pages = 0;
ffffffffc0200d30:	4701                	li	a4,0
        total_free_pages += b[i].curr_free;
ffffffffc0200d32:	6394                	ld	a3,0(a5)
ffffffffc0200d34:	03078793          	addi	a5,a5,48
ffffffffc0200d38:	9736                	add	a4,a4,a3
    for (int i = 0; i < id_; i++) {
ffffffffc0200d3a:	fec79ce3          	bne	a5,a2,ffffffffc0200d32 <buddy_check+0x22e>
    assert(buddy_nr_free_pages() == total);
ffffffffc0200d3e:	3ae49d63          	bne	s1,a4,ffffffffc02010f8 <buddy_check+0x5f4>

    p0 = buddy_alloc_pages(total);
ffffffffc0200d42:	8526                	mv	a0,s1
ffffffffc0200d44:	c79ff0ef          	jal	ra,ffffffffc02009bc <buddy_alloc_pages>
    assert(p0 == NULL);
ffffffffc0200d48:	38051863          	bnez	a0,ffffffffc02010d8 <buddy_check+0x5d4>

    p0 = buddy_alloc_pages(512);
ffffffffc0200d4c:	20000513          	li	a0,512
ffffffffc0200d50:	c6dff0ef          	jal	ra,ffffffffc02009bc <buddy_alloc_pages>
    for (int i = 0; i < id_; i++) {
ffffffffc0200d54:	4010                	lw	a2,0(s0)
    p0 = buddy_alloc_pages(512);
ffffffffc0200d56:	892a                	mv	s2,a0
    for (int i = 0; i < id_; i++) {
ffffffffc0200d58:	24c05263          	blez	a2,ffffffffc0200f9c <buddy_check+0x498>
ffffffffc0200d5c:	367d                	addiw	a2,a2,-1
ffffffffc0200d5e:	02061793          	slli	a5,a2,0x20
ffffffffc0200d62:	9381                	srli	a5,a5,0x20
ffffffffc0200d64:	00179613          	slli	a2,a5,0x1
ffffffffc0200d68:	963e                	add	a2,a2,a5
ffffffffc0200d6a:	00005717          	auipc	a4,0x5
ffffffffc0200d6e:	71e70713          	addi	a4,a4,1822 # ffffffffc0206488 <b+0x50>
ffffffffc0200d72:	0612                	slli	a2,a2,0x4
ffffffffc0200d74:	963a                	add	a2,a2,a4
ffffffffc0200d76:	00005797          	auipc	a5,0x5
ffffffffc0200d7a:	6e278793          	addi	a5,a5,1762 # ffffffffc0206458 <b+0x20>
    size_t total_free_pages = 0;
ffffffffc0200d7e:	4701                	li	a4,0
        total_free_pages += b[i].curr_free;
ffffffffc0200d80:	6394                	ld	a3,0(a5)
ffffffffc0200d82:	03078793          	addi	a5,a5,48
ffffffffc0200d86:	9736                	add	a4,a4,a3
    for (int i = 0; i < id_; i++) {
ffffffffc0200d88:	fec79ce3          	bne	a5,a2,ffffffffc0200d80 <buddy_check+0x27c>
    assert(buddy_nr_free_pages() == total - 512);
ffffffffc0200d8c:	e0048793          	addi	a5,s1,-512
ffffffffc0200d90:	2ee79463          	bne	a5,a4,ffffffffc0201078 <buddy_check+0x574>

    p1 = buddy_alloc_pages(1024);
ffffffffc0200d94:	40000513          	li	a0,1024
ffffffffc0200d98:	c25ff0ef          	jal	ra,ffffffffc02009bc <buddy_alloc_pages>
    for (int i = 0; i < id_; i++) {
ffffffffc0200d9c:	4010                	lw	a2,0(s0)
    p1 = buddy_alloc_pages(1024);
ffffffffc0200d9e:	89aa                	mv	s3,a0
    for (int i = 0; i < id_; i++) {
ffffffffc0200da0:	20c05063          	blez	a2,ffffffffc0200fa0 <buddy_check+0x49c>
ffffffffc0200da4:	367d                	addiw	a2,a2,-1
ffffffffc0200da6:	02061793          	slli	a5,a2,0x20
ffffffffc0200daa:	9381                	srli	a5,a5,0x20
ffffffffc0200dac:	00179613          	slli	a2,a5,0x1
ffffffffc0200db0:	963e                	add	a2,a2,a5
ffffffffc0200db2:	00005717          	auipc	a4,0x5
ffffffffc0200db6:	6d670713          	addi	a4,a4,1750 # ffffffffc0206488 <b+0x50>
ffffffffc0200dba:	0612                	slli	a2,a2,0x4
ffffffffc0200dbc:	963a                	add	a2,a2,a4
ffffffffc0200dbe:	00005797          	auipc	a5,0x5
ffffffffc0200dc2:	69a78793          	addi	a5,a5,1690 # ffffffffc0206458 <b+0x20>
    size_t total_free_pages = 0;
ffffffffc0200dc6:	4701                	li	a4,0
        total_free_pages += b[i].curr_free;
ffffffffc0200dc8:	6394                	ld	a3,0(a5)
ffffffffc0200dca:	03078793          	addi	a5,a5,48
ffffffffc0200dce:	9736                	add	a4,a4,a3
    for (int i = 0; i < id_; i++) {
ffffffffc0200dd0:	fec79ce3          	bne	a5,a2,ffffffffc0200dc8 <buddy_check+0x2c4>
    assert(buddy_nr_free_pages() == total - 512 - 1024);
ffffffffc0200dd4:	a0048793          	addi	a5,s1,-1536
ffffffffc0200dd8:	28e79063          	bne	a5,a4,ffffffffc0201058 <buddy_check+0x554>

    struct Page *p2 = buddy_alloc_pages(2048);
ffffffffc0200ddc:	6505                	lui	a0,0x1
ffffffffc0200dde:	80050513          	addi	a0,a0,-2048 # 800 <BASE_ADDRESS-0xffffffffc01ff800>
ffffffffc0200de2:	bdbff0ef          	jal	ra,ffffffffc02009bc <buddy_alloc_pages>
    for (int i = 0; i < id_; i++) {
ffffffffc0200de6:	4010                	lw	a2,0(s0)
    struct Page *p2 = buddy_alloc_pages(2048);
ffffffffc0200de8:	8a2a                	mv	s4,a0
    for (int i = 0; i < id_; i++) {
ffffffffc0200dea:	1ac05d63          	blez	a2,ffffffffc0200fa4 <buddy_check+0x4a0>
ffffffffc0200dee:	367d                	addiw	a2,a2,-1
ffffffffc0200df0:	02061793          	slli	a5,a2,0x20
ffffffffc0200df4:	9381                	srli	a5,a5,0x20
ffffffffc0200df6:	00179613          	slli	a2,a5,0x1
ffffffffc0200dfa:	963e                	add	a2,a2,a5
ffffffffc0200dfc:	00005717          	auipc	a4,0x5
ffffffffc0200e00:	68c70713          	addi	a4,a4,1676 # ffffffffc0206488 <b+0x50>
ffffffffc0200e04:	0612                	slli	a2,a2,0x4
ffffffffc0200e06:	963a                	add	a2,a2,a4
ffffffffc0200e08:	00005797          	auipc	a5,0x5
ffffffffc0200e0c:	65078793          	addi	a5,a5,1616 # ffffffffc0206458 <b+0x20>
    size_t total_free_pages = 0;
ffffffffc0200e10:	4701                	li	a4,0
        total_free_pages += b[i].curr_free;
ffffffffc0200e12:	6394                	ld	a3,0(a5)
ffffffffc0200e14:	03078793          	addi	a5,a5,48
ffffffffc0200e18:	9736                	add	a4,a4,a3
    for (int i = 0; i < id_; i++) {
ffffffffc0200e1a:	fec79ce3          	bne	a5,a2,ffffffffc0200e12 <buddy_check+0x30e>
    assert(buddy_nr_free_pages() == total - 512 - 1024 - 2048);
ffffffffc0200e1e:	77fd                	lui	a5,0xfffff
ffffffffc0200e20:	20078793          	addi	a5,a5,512 # fffffffffffff200 <end+0x3fdf8bc8>
ffffffffc0200e24:	97a6                	add	a5,a5,s1
ffffffffc0200e26:	30e79963          	bne	a5,a4,ffffffffc0201138 <buddy_check+0x634>

    struct Page *p3 = buddy_alloc_pages(4096);
ffffffffc0200e2a:	6505                	lui	a0,0x1
ffffffffc0200e2c:	b91ff0ef          	jal	ra,ffffffffc02009bc <buddy_alloc_pages>
    for (int i = 0; i < id_; i++) {
ffffffffc0200e30:	4010                	lw	a2,0(s0)
    struct Page *p3 = buddy_alloc_pages(4096);
ffffffffc0200e32:	8aaa                	mv	s5,a0
    for (int i = 0; i < id_; i++) {
ffffffffc0200e34:	16c05a63          	blez	a2,ffffffffc0200fa8 <buddy_check+0x4a4>
ffffffffc0200e38:	367d                	addiw	a2,a2,-1
ffffffffc0200e3a:	02061793          	slli	a5,a2,0x20
ffffffffc0200e3e:	9381                	srli	a5,a5,0x20
ffffffffc0200e40:	00179613          	slli	a2,a5,0x1
ffffffffc0200e44:	963e                	add	a2,a2,a5
ffffffffc0200e46:	00005717          	auipc	a4,0x5
ffffffffc0200e4a:	64270713          	addi	a4,a4,1602 # ffffffffc0206488 <b+0x50>
ffffffffc0200e4e:	0612                	slli	a2,a2,0x4
ffffffffc0200e50:	963a                	add	a2,a2,a4
ffffffffc0200e52:	00005797          	auipc	a5,0x5
ffffffffc0200e56:	60678793          	addi	a5,a5,1542 # ffffffffc0206458 <b+0x20>
    size_t total_free_pages = 0;
ffffffffc0200e5a:	4701                	li	a4,0
        total_free_pages += b[i].curr_free;
ffffffffc0200e5c:	6394                	ld	a3,0(a5)
ffffffffc0200e5e:	03078793          	addi	a5,a5,48
ffffffffc0200e62:	9736                	add	a4,a4,a3
    for (int i = 0; i < id_; i++) {
ffffffffc0200e64:	fec79ce3          	bne	a5,a2,ffffffffc0200e5c <buddy_check+0x358>
    assert(buddy_nr_free_pages() == total - 512 - 1024 - 2048 - 4096);
ffffffffc0200e68:	77f9                	lui	a5,0xffffe
ffffffffc0200e6a:	20078793          	addi	a5,a5,512 # ffffffffffffe200 <end+0x3fdf7bc8>
ffffffffc0200e6e:	97a6                	add	a5,a5,s1
ffffffffc0200e70:	2ae79463          	bne	a5,a4,ffffffffc0201118 <buddy_check+0x614>

    struct Page *p4 = buddy_alloc_pages(8192);
ffffffffc0200e74:	6509                	lui	a0,0x2
ffffffffc0200e76:	b47ff0ef          	jal	ra,ffffffffc02009bc <buddy_alloc_pages>
    for (int i = 0; i < id_; i++) {
ffffffffc0200e7a:	4010                	lw	a2,0(s0)
    struct Page *p4 = buddy_alloc_pages(8192);
ffffffffc0200e7c:	8b2a                	mv	s6,a0
    for (int i = 0; i < id_; i++) {
ffffffffc0200e7e:	12c05963          	blez	a2,ffffffffc0200fb0 <buddy_check+0x4ac>
ffffffffc0200e82:	367d                	addiw	a2,a2,-1
ffffffffc0200e84:	02061793          	slli	a5,a2,0x20
ffffffffc0200e88:	9381                	srli	a5,a5,0x20
ffffffffc0200e8a:	00179613          	slli	a2,a5,0x1
ffffffffc0200e8e:	963e                	add	a2,a2,a5
ffffffffc0200e90:	00005717          	auipc	a4,0x5
ffffffffc0200e94:	5f870713          	addi	a4,a4,1528 # ffffffffc0206488 <b+0x50>
ffffffffc0200e98:	0612                	slli	a2,a2,0x4
ffffffffc0200e9a:	963a                	add	a2,a2,a4
ffffffffc0200e9c:	00005797          	auipc	a5,0x5
ffffffffc0200ea0:	5bc78793          	addi	a5,a5,1468 # ffffffffc0206458 <b+0x20>
    size_t total_free_pages = 0;
ffffffffc0200ea4:	4701                	li	a4,0
        total_free_pages += b[i].curr_free;
ffffffffc0200ea6:	6394                	ld	a3,0(a5)
ffffffffc0200ea8:	03078793          	addi	a5,a5,48
ffffffffc0200eac:	9736                	add	a4,a4,a3
    for (int i = 0; i < id_; i++) {
ffffffffc0200eae:	fec79ce3          	bne	a5,a2,ffffffffc0200ea6 <buddy_check+0x3a2>
    assert(buddy_nr_free_pages() == total - 512 - 1024 - 2048 - 4096 - 8192);
ffffffffc0200eb2:	77f1                	lui	a5,0xffffc
ffffffffc0200eb4:	20078793          	addi	a5,a5,512 # ffffffffffffc200 <end+0x3fdf5bc8>
ffffffffc0200eb8:	97a6                	add	a5,a5,s1
ffffffffc0200eba:	16e79f63          	bne	a5,a4,ffffffffc0201038 <buddy_check+0x534>

    struct Page *p5 = buddy_alloc_pages(8192);
ffffffffc0200ebe:	6509                	lui	a0,0x2
ffffffffc0200ec0:	afdff0ef          	jal	ra,ffffffffc02009bc <buddy_alloc_pages>
    for (int i = 0; i < id_; i++) {
ffffffffc0200ec4:	4010                	lw	a2,0(s0)
    struct Page *p5 = buddy_alloc_pages(8192);
ffffffffc0200ec6:	8baa                	mv	s7,a0
    for (int i = 0; i < id_; i++) {
ffffffffc0200ec8:	0ec05663          	blez	a2,ffffffffc0200fb4 <buddy_check+0x4b0>
ffffffffc0200ecc:	367d                	addiw	a2,a2,-1
ffffffffc0200ece:	02061793          	slli	a5,a2,0x20
ffffffffc0200ed2:	9381                	srli	a5,a5,0x20
ffffffffc0200ed4:	00179613          	slli	a2,a5,0x1
ffffffffc0200ed8:	963e                	add	a2,a2,a5
ffffffffc0200eda:	00005717          	auipc	a4,0x5
ffffffffc0200ede:	5ae70713          	addi	a4,a4,1454 # ffffffffc0206488 <b+0x50>
ffffffffc0200ee2:	0612                	slli	a2,a2,0x4
ffffffffc0200ee4:	963a                	add	a2,a2,a4
ffffffffc0200ee6:	00005797          	auipc	a5,0x5
ffffffffc0200eea:	57278793          	addi	a5,a5,1394 # ffffffffc0206458 <b+0x20>
    size_t total_free_pages = 0;
ffffffffc0200eee:	4701                	li	a4,0
        total_free_pages += b[i].curr_free;
ffffffffc0200ef0:	6394                	ld	a3,0(a5)
ffffffffc0200ef2:	03078793          	addi	a5,a5,48
ffffffffc0200ef6:	9736                	add	a4,a4,a3
    for (int i = 0; i < id_; i++) {
ffffffffc0200ef8:	fec79ce3          	bne	a5,a2,ffffffffc0200ef0 <buddy_check+0x3ec>
    assert(buddy_nr_free_pages() == total - 512 - 1024 - 2048 - 4096 - 8192 - 8192);
ffffffffc0200efc:	77e9                	lui	a5,0xffffa
ffffffffc0200efe:	20078793          	addi	a5,a5,512 # ffffffffffffa200 <end+0x3fdf3bc8>
ffffffffc0200f02:	97a6                	add	a5,a5,s1
ffffffffc0200f04:	10e79a63          	bne	a5,a4,ffffffffc0201018 <buddy_check+0x514>

    buddy_free_pages(p0, -1);
ffffffffc0200f08:	55fd                	li	a1,-1
ffffffffc0200f0a:	854a                	mv	a0,s2
ffffffffc0200f0c:	965ff0ef          	jal	ra,ffffffffc0200870 <buddy_free_pages>
    buddy_free_pages(p1, -1);
ffffffffc0200f10:	55fd                	li	a1,-1
ffffffffc0200f12:	854e                	mv	a0,s3
ffffffffc0200f14:	95dff0ef          	jal	ra,ffffffffc0200870 <buddy_free_pages>
    buddy_free_pages(p2, -1);
ffffffffc0200f18:	55fd                	li	a1,-1
ffffffffc0200f1a:	8552                	mv	a0,s4
ffffffffc0200f1c:	955ff0ef          	jal	ra,ffffffffc0200870 <buddy_free_pages>
    buddy_free_pages(p3, -1);
ffffffffc0200f20:	55fd                	li	a1,-1
ffffffffc0200f22:	8556                	mv	a0,s5
ffffffffc0200f24:	94dff0ef          	jal	ra,ffffffffc0200870 <buddy_free_pages>
    buddy_free_pages(p4, -1);
ffffffffc0200f28:	55fd                	li	a1,-1
ffffffffc0200f2a:	855a                	mv	a0,s6
ffffffffc0200f2c:	945ff0ef          	jal	ra,ffffffffc0200870 <buddy_free_pages>
    buddy_free_pages(p5, -1);
ffffffffc0200f30:	55fd                	li	a1,-1
ffffffffc0200f32:	855e                	mv	a0,s7
ffffffffc0200f34:	93dff0ef          	jal	ra,ffffffffc0200870 <buddy_free_pages>
    for (int i = 0; i < id_; i++) {
ffffffffc0200f38:	4010                	lw	a2,0(s0)
ffffffffc0200f3a:	06c05963          	blez	a2,ffffffffc0200fac <buddy_check+0x4a8>
ffffffffc0200f3e:	367d                	addiw	a2,a2,-1
ffffffffc0200f40:	02061793          	slli	a5,a2,0x20
ffffffffc0200f44:	9381                	srli	a5,a5,0x20
ffffffffc0200f46:	00179613          	slli	a2,a5,0x1
ffffffffc0200f4a:	963e                	add	a2,a2,a5
ffffffffc0200f4c:	00005717          	auipc	a4,0x5
ffffffffc0200f50:	53c70713          	addi	a4,a4,1340 # ffffffffc0206488 <b+0x50>
ffffffffc0200f54:	0612                	slli	a2,a2,0x4
ffffffffc0200f56:	963a                	add	a2,a2,a4
ffffffffc0200f58:	00005797          	auipc	a5,0x5
ffffffffc0200f5c:	50078793          	addi	a5,a5,1280 # ffffffffc0206458 <b+0x20>
    size_t total_free_pages = 0;
ffffffffc0200f60:	4701                	li	a4,0
        total_free_pages += b[i].curr_free;
ffffffffc0200f62:	6394                	ld	a3,0(a5)
ffffffffc0200f64:	03078793          	addi	a5,a5,48
ffffffffc0200f68:	9736                	add	a4,a4,a3
    for (int i = 0; i < id_; i++) {
ffffffffc0200f6a:	fef61ce3          	bne	a2,a5,ffffffffc0200f62 <buddy_check+0x45e>

    assert(buddy_nr_free_pages() == total);
ffffffffc0200f6e:	04e49563          	bne	s1,a4,ffffffffc0200fb8 <buddy_check+0x4b4>

}
ffffffffc0200f72:	60a6                	ld	ra,72(sp)
ffffffffc0200f74:	6406                	ld	s0,64(sp)
ffffffffc0200f76:	74e2                	ld	s1,56(sp)
ffffffffc0200f78:	7942                	ld	s2,48(sp)
ffffffffc0200f7a:	79a2                	ld	s3,40(sp)
ffffffffc0200f7c:	7a02                	ld	s4,32(sp)
ffffffffc0200f7e:	6ae2                	ld	s5,24(sp)
ffffffffc0200f80:	6b42                	ld	s6,16(sp)
ffffffffc0200f82:	6ba2                	ld	s7,8(sp)
ffffffffc0200f84:	6161                	addi	sp,sp,80
ffffffffc0200f86:	8082                	ret
    size_t total_free_pages = 0;
ffffffffc0200f88:	4481                	li	s1,0
ffffffffc0200f8a:	b6f1                	j	ffffffffc0200b56 <buddy_check+0x52>
ffffffffc0200f8c:	4701                	li	a4,0
ffffffffc0200f8e:	b9e1                	j	ffffffffc0200c66 <buddy_check+0x162>
ffffffffc0200f90:	4701                	li	a4,0
ffffffffc0200f92:	bb19                	j	ffffffffc0200ca8 <buddy_check+0x1a4>
ffffffffc0200f94:	4701                	li	a4,0
ffffffffc0200f96:	bba9                	j	ffffffffc0200cf0 <buddy_check+0x1ec>
ffffffffc0200f98:	4701                	li	a4,0
ffffffffc0200f9a:	b355                	j	ffffffffc0200d3e <buddy_check+0x23a>
ffffffffc0200f9c:	4701                	li	a4,0
ffffffffc0200f9e:	b3fd                	j	ffffffffc0200d8c <buddy_check+0x288>
ffffffffc0200fa0:	4701                	li	a4,0
ffffffffc0200fa2:	bd0d                	j	ffffffffc0200dd4 <buddy_check+0x2d0>
ffffffffc0200fa4:	4701                	li	a4,0
ffffffffc0200fa6:	bda5                	j	ffffffffc0200e1e <buddy_check+0x31a>
ffffffffc0200fa8:	4701                	li	a4,0
ffffffffc0200faa:	bd7d                	j	ffffffffc0200e68 <buddy_check+0x364>
ffffffffc0200fac:	4701                	li	a4,0
ffffffffc0200fae:	b7c1                	j	ffffffffc0200f6e <buddy_check+0x46a>
ffffffffc0200fb0:	4701                	li	a4,0
ffffffffc0200fb2:	b701                	j	ffffffffc0200eb2 <buddy_check+0x3ae>
ffffffffc0200fb4:	4701                	li	a4,0
ffffffffc0200fb6:	b799                	j	ffffffffc0200efc <buddy_check+0x3f8>
    assert(buddy_nr_free_pages() == total);
ffffffffc0200fb8:	00001697          	auipc	a3,0x1
ffffffffc0200fbc:	47868693          	addi	a3,a3,1144 # ffffffffc0202430 <commands+0x700>
ffffffffc0200fc0:	00001617          	auipc	a2,0x1
ffffffffc0200fc4:	68060613          	addi	a2,a2,1664 # ffffffffc0202640 <commands+0x910>
ffffffffc0200fc8:	0ed00593          	li	a1,237
ffffffffc0200fcc:	00001517          	auipc	a0,0x1
ffffffffc0200fd0:	68c50513          	addi	a0,a0,1676 # ffffffffc0202658 <commands+0x928>
ffffffffc0200fd4:	bd8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(buddy_nr_free_pages() == total - 144);
ffffffffc0200fd8:	00001697          	auipc	a3,0x1
ffffffffc0200fdc:	4a068693          	addi	a3,a3,1184 # ffffffffc0202478 <commands+0x748>
ffffffffc0200fe0:	00001617          	auipc	a2,0x1
ffffffffc0200fe4:	66060613          	addi	a2,a2,1632 # ffffffffc0202640 <commands+0x910>
ffffffffc0200fe8:	0cb00593          	li	a1,203
ffffffffc0200fec:	00001517          	auipc	a0,0x1
ffffffffc0200ff0:	66c50513          	addi	a0,a0,1644 # ffffffffc0202658 <commands+0x928>
ffffffffc0200ff4:	bb8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(buddy_nr_free_pages() == total - 16);
ffffffffc0200ff8:	00001697          	auipc	a3,0x1
ffffffffc0200ffc:	45868693          	addi	a3,a3,1112 # ffffffffc0202450 <commands+0x720>
ffffffffc0201000:	00001617          	auipc	a2,0x1
ffffffffc0201004:	64060613          	addi	a2,a2,1600 # ffffffffc0202640 <commands+0x910>
ffffffffc0201008:	0c800593          	li	a1,200
ffffffffc020100c:	00001517          	auipc	a0,0x1
ffffffffc0201010:	64c50513          	addi	a0,a0,1612 # ffffffffc0202658 <commands+0x928>
ffffffffc0201014:	b98ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(buddy_nr_free_pages() == total - 512 - 1024 - 2048 - 4096 - 8192 - 8192);
ffffffffc0201018:	00001697          	auipc	a3,0x1
ffffffffc020101c:	5b068693          	addi	a3,a3,1456 # ffffffffc02025c8 <commands+0x898>
ffffffffc0201020:	00001617          	auipc	a2,0x1
ffffffffc0201024:	62060613          	addi	a2,a2,1568 # ffffffffc0202640 <commands+0x910>
ffffffffc0201028:	0e400593          	li	a1,228
ffffffffc020102c:	00001517          	auipc	a0,0x1
ffffffffc0201030:	62c50513          	addi	a0,a0,1580 # ffffffffc0202658 <commands+0x928>
ffffffffc0201034:	b78ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(buddy_nr_free_pages() == total - 512 - 1024 - 2048 - 4096 - 8192);
ffffffffc0201038:	00001697          	auipc	a3,0x1
ffffffffc020103c:	54868693          	addi	a3,a3,1352 # ffffffffc0202580 <commands+0x850>
ffffffffc0201040:	00001617          	auipc	a2,0x1
ffffffffc0201044:	60060613          	addi	a2,a2,1536 # ffffffffc0202640 <commands+0x910>
ffffffffc0201048:	0e100593          	li	a1,225
ffffffffc020104c:	00001517          	auipc	a0,0x1
ffffffffc0201050:	60c50513          	addi	a0,a0,1548 # ffffffffc0202658 <commands+0x928>
ffffffffc0201054:	b58ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(buddy_nr_free_pages() == total - 512 - 1024);
ffffffffc0201058:	00001697          	auipc	a3,0x1
ffffffffc020105c:	48068693          	addi	a3,a3,1152 # ffffffffc02024d8 <commands+0x7a8>
ffffffffc0201060:	00001617          	auipc	a2,0x1
ffffffffc0201064:	5e060613          	addi	a2,a2,1504 # ffffffffc0202640 <commands+0x910>
ffffffffc0201068:	0d800593          	li	a1,216
ffffffffc020106c:	00001517          	auipc	a0,0x1
ffffffffc0201070:	5ec50513          	addi	a0,a0,1516 # ffffffffc0202658 <commands+0x928>
ffffffffc0201074:	b38ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(buddy_nr_free_pages() == total - 512);
ffffffffc0201078:	00001697          	auipc	a3,0x1
ffffffffc020107c:	43868693          	addi	a3,a3,1080 # ffffffffc02024b0 <commands+0x780>
ffffffffc0201080:	00001617          	auipc	a2,0x1
ffffffffc0201084:	5c060613          	addi	a2,a2,1472 # ffffffffc0202640 <commands+0x910>
ffffffffc0201088:	0d500593          	li	a1,213
ffffffffc020108c:	00001517          	auipc	a0,0x1
ffffffffc0201090:	5cc50513          	addi	a0,a0,1484 # ffffffffc0202658 <commands+0x928>
ffffffffc0201094:	b18ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(buddy_nr_free_pages() == total);
ffffffffc0201098:	00001697          	auipc	a3,0x1
ffffffffc020109c:	39868693          	addi	a3,a3,920 # ffffffffc0202430 <commands+0x700>
ffffffffc02010a0:	00001617          	auipc	a2,0x1
ffffffffc02010a4:	5a060613          	addi	a2,a2,1440 # ffffffffc0202640 <commands+0x910>
ffffffffc02010a8:	0c500593          	li	a1,197
ffffffffc02010ac:	00001517          	auipc	a0,0x1
ffffffffc02010b0:	5ac50513          	addi	a0,a0,1452 # ffffffffc0202658 <commands+0x928>
ffffffffc02010b4:	af8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p1 == p0 + 1);
ffffffffc02010b8:	00001697          	auipc	a3,0x1
ffffffffc02010bc:	36868693          	addi	a3,a3,872 # ffffffffc0202420 <commands+0x6f0>
ffffffffc02010c0:	00001617          	auipc	a2,0x1
ffffffffc02010c4:	58060613          	addi	a2,a2,1408 # ffffffffc0202640 <commands+0x910>
ffffffffc02010c8:	0c100593          	li	a1,193
ffffffffc02010cc:	00001517          	auipc	a0,0x1
ffffffffc02010d0:	58c50513          	addi	a0,a0,1420 # ffffffffc0202658 <commands+0x928>
ffffffffc02010d4:	ad8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 == NULL);
ffffffffc02010d8:	00001697          	auipc	a3,0x1
ffffffffc02010dc:	3c868693          	addi	a3,a3,968 # ffffffffc02024a0 <commands+0x770>
ffffffffc02010e0:	00001617          	auipc	a2,0x1
ffffffffc02010e4:	56060613          	addi	a2,a2,1376 # ffffffffc0202640 <commands+0x910>
ffffffffc02010e8:	0d200593          	li	a1,210
ffffffffc02010ec:	00001517          	auipc	a0,0x1
ffffffffc02010f0:	56c50513          	addi	a0,a0,1388 # ffffffffc0202658 <commands+0x928>
ffffffffc02010f4:	ab8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(buddy_nr_free_pages() == total);
ffffffffc02010f8:	00001697          	auipc	a3,0x1
ffffffffc02010fc:	33868693          	addi	a3,a3,824 # ffffffffc0202430 <commands+0x700>
ffffffffc0201100:	00001617          	auipc	a2,0x1
ffffffffc0201104:	54060613          	addi	a2,a2,1344 # ffffffffc0202640 <commands+0x910>
ffffffffc0201108:	0cf00593          	li	a1,207
ffffffffc020110c:	00001517          	auipc	a0,0x1
ffffffffc0201110:	54c50513          	addi	a0,a0,1356 # ffffffffc0202658 <commands+0x928>
ffffffffc0201114:	a98ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(buddy_nr_free_pages() == total - 512 - 1024 - 2048 - 4096);
ffffffffc0201118:	00001697          	auipc	a3,0x1
ffffffffc020111c:	42868693          	addi	a3,a3,1064 # ffffffffc0202540 <commands+0x810>
ffffffffc0201120:	00001617          	auipc	a2,0x1
ffffffffc0201124:	52060613          	addi	a2,a2,1312 # ffffffffc0202640 <commands+0x910>
ffffffffc0201128:	0de00593          	li	a1,222
ffffffffc020112c:	00001517          	auipc	a0,0x1
ffffffffc0201130:	52c50513          	addi	a0,a0,1324 # ffffffffc0202658 <commands+0x928>
ffffffffc0201134:	a78ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(buddy_nr_free_pages() == total - 512 - 1024 - 2048);
ffffffffc0201138:	00001697          	auipc	a3,0x1
ffffffffc020113c:	3d068693          	addi	a3,a3,976 # ffffffffc0202508 <commands+0x7d8>
ffffffffc0201140:	00001617          	auipc	a2,0x1
ffffffffc0201144:	50060613          	addi	a2,a2,1280 # ffffffffc0202640 <commands+0x910>
ffffffffc0201148:	0db00593          	li	a1,219
ffffffffc020114c:	00001517          	auipc	a0,0x1
ffffffffc0201150:	50c50513          	addi	a0,a0,1292 # ffffffffc0202658 <commands+0x928>
ffffffffc0201154:	a58ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p1 == b[0].begin_page + 1);
ffffffffc0201158:	00001697          	auipc	a3,0x1
ffffffffc020115c:	2a868693          	addi	a3,a3,680 # ffffffffc0202400 <commands+0x6d0>
ffffffffc0201160:	00001617          	auipc	a2,0x1
ffffffffc0201164:	4e060613          	addi	a2,a2,1248 # ffffffffc0202640 <commands+0x910>
ffffffffc0201168:	0bf00593          	li	a1,191
ffffffffc020116c:	00001517          	auipc	a0,0x1
ffffffffc0201170:	4ec50513          	addi	a0,a0,1260 # ffffffffc0202658 <commands+0x928>
ffffffffc0201174:	a38ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(buddy_nr_free_pages() == total - 2);
ffffffffc0201178:	00001697          	auipc	a3,0x1
ffffffffc020117c:	26068693          	addi	a3,a3,608 # ffffffffc02023d8 <commands+0x6a8>
ffffffffc0201180:	00001617          	auipc	a2,0x1
ffffffffc0201184:	4c060613          	addi	a2,a2,1216 # ffffffffc0202640 <commands+0x910>
ffffffffc0201188:	0be00593          	li	a1,190
ffffffffc020118c:	00001517          	auipc	a0,0x1
ffffffffc0201190:	4cc50513          	addi	a0,a0,1228 # ffffffffc0202658 <commands+0x928>
ffffffffc0201194:	a18ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p1 != NULL);
ffffffffc0201198:	00001697          	auipc	a3,0x1
ffffffffc020119c:	23068693          	addi	a3,a3,560 # ffffffffc02023c8 <commands+0x698>
ffffffffc02011a0:	00001617          	auipc	a2,0x1
ffffffffc02011a4:	4a060613          	addi	a2,a2,1184 # ffffffffc0202640 <commands+0x910>
ffffffffc02011a8:	0bd00593          	li	a1,189
ffffffffc02011ac:	00001517          	auipc	a0,0x1
ffffffffc02011b0:	4ac50513          	addi	a0,a0,1196 # ffffffffc0202658 <commands+0x928>
ffffffffc02011b4:	9f8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 == b[0].begin_page);
ffffffffc02011b8:	00001697          	auipc	a3,0x1
ffffffffc02011bc:	1f868693          	addi	a3,a3,504 # ffffffffc02023b0 <commands+0x680>
ffffffffc02011c0:	00001617          	auipc	a2,0x1
ffffffffc02011c4:	48060613          	addi	a2,a2,1152 # ffffffffc0202640 <commands+0x910>
ffffffffc02011c8:	0ba00593          	li	a1,186
ffffffffc02011cc:	00001517          	auipc	a0,0x1
ffffffffc02011d0:	48c50513          	addi	a0,a0,1164 # ffffffffc0202658 <commands+0x928>
ffffffffc02011d4:	9d8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(buddy_nr_free_pages() == total - 1);
ffffffffc02011d8:	00001697          	auipc	a3,0x1
ffffffffc02011dc:	1b068693          	addi	a3,a3,432 # ffffffffc0202388 <commands+0x658>
ffffffffc02011e0:	00001617          	auipc	a2,0x1
ffffffffc02011e4:	46060613          	addi	a2,a2,1120 # ffffffffc0202640 <commands+0x910>
ffffffffc02011e8:	0b900593          	li	a1,185
ffffffffc02011ec:	00001517          	auipc	a0,0x1
ffffffffc02011f0:	46c50513          	addi	a0,a0,1132 # ffffffffc0202658 <commands+0x928>
ffffffffc02011f4:	9b8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc02011f8:	00001697          	auipc	a3,0x1
ffffffffc02011fc:	18068693          	addi	a3,a3,384 # ffffffffc0202378 <commands+0x648>
ffffffffc0201200:	00001617          	auipc	a2,0x1
ffffffffc0201204:	44060613          	addi	a2,a2,1088 # ffffffffc0202640 <commands+0x910>
ffffffffc0201208:	0b800593          	li	a1,184
ffffffffc020120c:	00001517          	auipc	a0,0x1
ffffffffc0201210:	44c50513          	addi	a0,a0,1100 # ffffffffc0202658 <commands+0x928>
ffffffffc0201214:	998ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201218 <buddy_init_memmap>:
buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0201218:	1101                	addi	sp,sp,-32
ffffffffc020121a:	e822                	sd	s0,16(sp)
ffffffffc020121c:	842a                	mv	s0,a0
    cprintf("n: %d\n", n);
ffffffffc020121e:	00001517          	auipc	a0,0x1
ffffffffc0201222:	45250513          	addi	a0,a0,1106 # ffffffffc0202670 <commands+0x940>
buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0201226:	e426                	sd	s1,8(sp)
ffffffffc0201228:	ec06                	sd	ra,24(sp)
ffffffffc020122a:	84ae                	mv	s1,a1
    cprintf("n: %d\n", n);
ffffffffc020122c:	e8bfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    size |= size >> 1;
ffffffffc0201230:	0014d713          	srli	a4,s1,0x1
ffffffffc0201234:	8f45                	or	a4,a4,s1
    size |= size >> 2;
ffffffffc0201236:	00275793          	srli	a5,a4,0x2
ffffffffc020123a:	8f5d                	or	a4,a4,a5
    size |= size >> 4;
ffffffffc020123c:	00475793          	srli	a5,a4,0x4
ffffffffc0201240:	8f5d                	or	a4,a4,a5
    size |= size >> 8;
ffffffffc0201242:	00875793          	srli	a5,a4,0x8
ffffffffc0201246:	8f5d                	or	a4,a4,a5
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201248:	00005797          	auipc	a5,0x5
ffffffffc020124c:	3e878793          	addi	a5,a5,1000 # ffffffffc0206630 <pages>
ffffffffc0201250:	0007b303          	ld	t1,0(a5)
    size |= size >> 16;
ffffffffc0201254:	01075793          	srli	a5,a4,0x10
ffffffffc0201258:	8f5d                	or	a4,a4,a5
    return size + 1;
ffffffffc020125a:	00170693          	addi	a3,a4,1
ffffffffc020125e:	00001797          	auipc	a5,0x1
ffffffffc0201262:	3b278793          	addi	a5,a5,946 # ffffffffc0202610 <commands+0x8e0>
ffffffffc0201266:	0007be03          	ld	t3,0(a5)
    size_t extra = s - n;
ffffffffc020126a:	409687b3          	sub	a5,a3,s1
    size |= size >> 1;
ffffffffc020126e:	0017d613          	srli	a2,a5,0x1
ffffffffc0201272:	406408b3          	sub	a7,s0,t1
ffffffffc0201276:	8e5d                	or	a2,a2,a5
ffffffffc0201278:	4038d893          	srai	a7,a7,0x3
    size |= size >> 2;
ffffffffc020127c:	00265793          	srli	a5,a2,0x2
ffffffffc0201280:	03c888b3          	mul	a7,a7,t3
ffffffffc0201284:	8e5d                	or	a2,a2,a5
    struct buddy *buddy = &b[id_++];
ffffffffc0201286:	00005797          	auipc	a5,0x5
ffffffffc020128a:	18e78793          	addi	a5,a5,398 # ffffffffc0206414 <id_>
ffffffffc020128e:	0007a803          	lw	a6,0(a5)
    size |= size >> 4;
ffffffffc0201292:	00465793          	srli	a5,a2,0x4
ffffffffc0201296:	8e5d                	or	a2,a2,a5
    size |= size >> 8;
ffffffffc0201298:	00865793          	srli	a5,a2,0x8
ffffffffc020129c:	8e5d                	or	a2,a2,a5
    buddy->size = s;
ffffffffc020129e:	00181593          	slli	a1,a6,0x1
ffffffffc02012a2:	00001797          	auipc	a5,0x1
ffffffffc02012a6:	7ce78793          	addi	a5,a5,1998 # ffffffffc0202a70 <nbase>
ffffffffc02012aa:	0007bf03          	ld	t5,0(a5)
ffffffffc02012ae:	01058eb3          	add	t4,a1,a6
    size |= size >> 16;
ffffffffc02012b2:	01065793          	srli	a5,a2,0x10
ffffffffc02012b6:	8e5d                	or	a2,a2,a5
    buddy->size = s;
ffffffffc02012b8:	00005517          	auipc	a0,0x5
ffffffffc02012bc:	18050513          	addi	a0,a0,384 # ffffffffc0206438 <b>
ffffffffc02012c0:	0e92                	slli	t4,t4,0x4
    buddy->longest = KADDR(page2pa(base));
ffffffffc02012c2:	00005797          	auipc	a5,0x5
ffffffffc02012c6:	15678793          	addi	a5,a5,342 # ffffffffc0206418 <npage>
    buddy->size = s;
ffffffffc02012ca:	9eaa                	add	t4,t4,a0
    buddy->curr_free = s - e;
ffffffffc02012cc:	8f11                	sub	a4,a4,a2
    buddy->longest = KADDR(page2pa(base));
ffffffffc02012ce:	0007bf83          	ld	t6,0(a5)
    buddy->curr_free = s - e;
ffffffffc02012d2:	02eeb023          	sd	a4,32(t4)
    buddy->longest = KADDR(page2pa(base));
ffffffffc02012d6:	577d                	li	a4,-1
ffffffffc02012d8:	98fa                	add	a7,a7,t5
    struct buddy *buddy = &b[id_++];
ffffffffc02012da:	0018079b          	addiw	a5,a6,1
    buddy->longest = KADDR(page2pa(base));
ffffffffc02012de:	8331                	srli	a4,a4,0xc
ffffffffc02012e0:	00e8f733          	and	a4,a7,a4
    struct buddy *buddy = &b[id_++];
ffffffffc02012e4:	00005297          	auipc	t0,0x5
ffffffffc02012e8:	12f2a823          	sw	a5,304(t0) # ffffffffc0206414 <id_>
    buddy->size = s;
ffffffffc02012ec:	00deb023          	sd	a3,0(t4)

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc02012f0:	08b2                	slli	a7,a7,0xc
    buddy->longest = KADDR(page2pa(base));
ffffffffc02012f2:	19f77163          	bleu	t6,a4,ffffffffc0201474 <buddy_init_memmap+0x25c>
ffffffffc02012f6:	00005797          	auipc	a5,0x5
ffffffffc02012fa:	33278793          	addi	a5,a5,818 # ffffffffc0206628 <va_pa_offset>
ffffffffc02012fe:	0007b283          	ld	t0,0(a5)
    buddy->begin_page = pa2page(PADDR(ROUNDUP(buddy->longest + 2 * s * sizeof(uintptr_t), PGSIZE)));
ffffffffc0201302:	00769713          	slli	a4,a3,0x7
ffffffffc0201306:	6785                	lui	a5,0x1
    buddy->longest = KADDR(page2pa(base));
ffffffffc0201308:	9896                	add	a7,a7,t0
    buddy->begin_page = pa2page(PADDR(ROUNDUP(buddy->longest + 2 * s * sizeof(uintptr_t), PGSIZE)));
ffffffffc020130a:	17fd                	addi	a5,a5,-1
ffffffffc020130c:	9746                	add	a4,a4,a7
ffffffffc020130e:	973e                	add	a4,a4,a5
ffffffffc0201310:	77fd                	lui	a5,0xfffff
ffffffffc0201312:	8ff9                	and	a5,a5,a4
    buddy->longest = KADDR(page2pa(base));
ffffffffc0201314:	011eb423          	sd	a7,8(t4)
    buddy->begin_page = pa2page(PADDR(ROUNDUP(buddy->longest + 2 * s * sizeof(uintptr_t), PGSIZE)));
ffffffffc0201318:	c0200737          	lui	a4,0xc0200
ffffffffc020131c:	12e7ef63          	bltu	a5,a4,ffffffffc020145a <buddy_init_memmap+0x242>
ffffffffc0201320:	405787b3          	sub	a5,a5,t0
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201324:	83b1                	srli	a5,a5,0xc
ffffffffc0201326:	11f7fe63          	bleu	t6,a5,ffffffffc0201442 <buddy_init_memmap+0x22a>
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc020132a:	41e787b3          	sub	a5,a5,t5
ffffffffc020132e:	00279713          	slli	a4,a5,0x2
ffffffffc0201332:	97ba                	add	a5,a5,a4
ffffffffc0201334:	078e                	slli	a5,a5,0x3
ffffffffc0201336:	933e                	add	t1,t1,a5
    buddy->longest_num = buddy->begin_page - base;
ffffffffc0201338:	408307b3          	sub	a5,t1,s0
ffffffffc020133c:	878d                	srai	a5,a5,0x3
ffffffffc020133e:	03c78e33          	mul	t3,a5,t3
ffffffffc0201342:	0605                	addi	a2,a2,1
    buddy->begin_page = pa2page(PADDR(ROUNDUP(buddy->longest + 2 * s * sizeof(uintptr_t), PGSIZE)));
ffffffffc0201344:	026eb423          	sd	t1,40(t4)
    size_t sn = buddy->size * 2;
ffffffffc0201348:	0686                	slli	a3,a3,0x1
    for (int i = 0; i < 2 * buddy->size - 1; i++) {
ffffffffc020134a:	4781                	li	a5,0
        buddy->longest[i] = sn;
ffffffffc020134c:	88f6                	mv	a7,t4
    buddy->total_num = n - buddy->longest_num;
ffffffffc020134e:	41c484b3          	sub	s1,s1,t3
    buddy->longest_num = buddy->begin_page - base;
ffffffffc0201352:	01ceb823          	sd	t3,16(t4)
    buddy->total_num = n - buddy->longest_num;
ffffffffc0201356:	009ebc23          	sd	s1,24(t4)
        if (IS_POWER_OF_2(i + 1)) {
ffffffffc020135a:	0017871b          	addiw	a4,a5,1
ffffffffc020135e:	8f7d                	and	a4,a4,a5
ffffffffc0201360:	2701                	sext.w	a4,a4
ffffffffc0201362:	e311                	bnez	a4,ffffffffc0201366 <buddy_init_memmap+0x14e>
            sn /= 2;
ffffffffc0201364:	8285                	srli	a3,a3,0x1
        buddy->longest[i] = sn;
ffffffffc0201366:	0088b703          	ld	a4,8(a7)
ffffffffc020136a:	00379313          	slli	t1,a5,0x3
ffffffffc020136e:	0785                	addi	a5,a5,1
ffffffffc0201370:	971a                	add	a4,a4,t1
ffffffffc0201372:	e314                	sd	a3,0(a4)
    for (int i = 0; i < 2 * buddy->size - 1; i++) {
ffffffffc0201374:	0008b703          	ld	a4,0(a7)
ffffffffc0201378:	0706                	slli	a4,a4,0x1
ffffffffc020137a:	177d                	addi	a4,a4,-1
ffffffffc020137c:	fce7efe3          	bltu	a5,a4,ffffffffc020135a <buddy_init_memmap+0x142>
        if (buddy->longest[id] == e) {
ffffffffc0201380:	0088b883          	ld	a7,8(a7)
    int id = 0;
ffffffffc0201384:	4781                	li	a5,0
        if (buddy->longest[id] == e) {
ffffffffc0201386:	0008b703          	ld	a4,0(a7)
ffffffffc020138a:	08e60963          	beq	a2,a4,ffffffffc020141c <buddy_init_memmap+0x204>
        id = RIGHT_LEAF(id);
ffffffffc020138e:	2785                	addiw	a5,a5,1
ffffffffc0201390:	0017979b          	slliw	a5,a5,0x1
        if (buddy->longest[id] == e) {
ffffffffc0201394:	00379713          	slli	a4,a5,0x3
ffffffffc0201398:	9746                	add	a4,a4,a7
ffffffffc020139a:	6314                	ld	a3,0(a4)
ffffffffc020139c:	fec699e3          	bne	a3,a2,ffffffffc020138e <buddy_init_memmap+0x176>
        buddy->longest[id] = MAX(buddy->longest[LEFT_LEAF(id)], buddy->longest[RIGHT_LEAF(id)]);
ffffffffc02013a0:	01058333          	add	t1,a1,a6
ffffffffc02013a4:	0312                	slli	t1,t1,0x4
            buddy->longest[id] = 0;
ffffffffc02013a6:	00073023          	sd	zero,0(a4) # ffffffffc0200000 <kern_entry>
        buddy->longest[id] = MAX(buddy->longest[LEFT_LEAF(id)], buddy->longest[RIGHT_LEAF(id)]);
ffffffffc02013aa:	932a                	add	t1,t1,a0
        id = PARENT(id);
ffffffffc02013ac:	2785                	addiw	a5,a5,1
ffffffffc02013ae:	4017d79b          	sraiw	a5,a5,0x1
ffffffffc02013b2:	37fd                	addiw	a5,a5,-1
        buddy->longest[id] = MAX(buddy->longest[LEFT_LEAF(id)], buddy->longest[RIGHT_LEAF(id)]);
ffffffffc02013b4:	00833683          	ld	a3,8(t1)
ffffffffc02013b8:	0017971b          	slliw	a4,a5,0x1
ffffffffc02013bc:	00270613          	addi	a2,a4,2
ffffffffc02013c0:	0705                	addi	a4,a4,1
ffffffffc02013c2:	060e                	slli	a2,a2,0x3
ffffffffc02013c4:	070e                	slli	a4,a4,0x3
ffffffffc02013c6:	9636                	add	a2,a2,a3
ffffffffc02013c8:	9736                	add	a4,a4,a3
ffffffffc02013ca:	00073883          	ld	a7,0(a4)
ffffffffc02013ce:	6218                	ld	a4,0(a2)
ffffffffc02013d0:	00379613          	slli	a2,a5,0x3
ffffffffc02013d4:	96b2                	add	a3,a3,a2
ffffffffc02013d6:	01177363          	bleu	a7,a4,ffffffffc02013dc <buddy_init_memmap+0x1c4>
ffffffffc02013da:	8746                	mv	a4,a7
ffffffffc02013dc:	e298                	sd	a4,0(a3)
    while (id) {
ffffffffc02013de:	f7f9                	bnez	a5,ffffffffc02013ac <buddy_init_memmap+0x194>
    struct Page *p = buddy->begin_page;
ffffffffc02013e0:	95c2                	add	a1,a1,a6
ffffffffc02013e2:	0592                	slli	a1,a1,0x4
ffffffffc02013e4:	95aa                	add	a1,a1,a0
    for (; p != base + buddy->curr_free; p ++) {
ffffffffc02013e6:	7194                	ld	a3,32(a1)
    struct Page *p = buddy->begin_page;
ffffffffc02013e8:	759c                	ld	a5,40(a1)
    for (; p != base + buddy->curr_free; p ++) {
ffffffffc02013ea:	00269713          	slli	a4,a3,0x2
ffffffffc02013ee:	9736                	add	a4,a4,a3
ffffffffc02013f0:	070e                	slli	a4,a4,0x3
ffffffffc02013f2:	943a                	add	s0,s0,a4
ffffffffc02013f4:	00878f63          	beq	a5,s0,ffffffffc0201412 <buddy_init_memmap+0x1fa>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02013f8:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02013fa:	8b05                	andi	a4,a4,1
ffffffffc02013fc:	c31d                	beqz	a4,ffffffffc0201422 <buddy_init_memmap+0x20a>
        p->flags = p->property = 0;
ffffffffc02013fe:	0007a823          	sw	zero,16(a5) # fffffffffffff010 <end+0x3fdf89d8>
ffffffffc0201402:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201406:	0007a023          	sw	zero,0(a5)
    for (; p != base + buddy->curr_free; p ++) {
ffffffffc020140a:	02878793          	addi	a5,a5,40
ffffffffc020140e:	fe8795e3          	bne	a5,s0,ffffffffc02013f8 <buddy_init_memmap+0x1e0>
}
ffffffffc0201412:	60e2                	ld	ra,24(sp)
ffffffffc0201414:	6442                	ld	s0,16(sp)
ffffffffc0201416:	64a2                	ld	s1,8(sp)
ffffffffc0201418:	6105                	addi	sp,sp,32
ffffffffc020141a:	8082                	ret
            buddy->longest[id] = 0;
ffffffffc020141c:	0008b023          	sd	zero,0(a7)
    while (id) {
ffffffffc0201420:	b7c1                	j	ffffffffc02013e0 <buddy_init_memmap+0x1c8>
        assert(PageReserved(p));
ffffffffc0201422:	00001697          	auipc	a3,0x1
ffffffffc0201426:	2d668693          	addi	a3,a3,726 # ffffffffc02026f8 <commands+0x9c8>
ffffffffc020142a:	00001617          	auipc	a2,0x1
ffffffffc020142e:	21660613          	addi	a2,a2,534 # ffffffffc0202640 <commands+0x910>
ffffffffc0201432:	04800593          	li	a1,72
ffffffffc0201436:	00001517          	auipc	a0,0x1
ffffffffc020143a:	22250513          	addi	a0,a0,546 # ffffffffc0202658 <commands+0x928>
ffffffffc020143e:	f6ffe0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201442:	00001617          	auipc	a2,0x1
ffffffffc0201446:	28660613          	addi	a2,a2,646 # ffffffffc02026c8 <commands+0x998>
ffffffffc020144a:	06b00593          	li	a1,107
ffffffffc020144e:	00001517          	auipc	a0,0x1
ffffffffc0201452:	29a50513          	addi	a0,a0,666 # ffffffffc02026e8 <commands+0x9b8>
ffffffffc0201456:	f57fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    buddy->begin_page = pa2page(PADDR(ROUNDUP(buddy->longest + 2 * s * sizeof(uintptr_t), PGSIZE)));
ffffffffc020145a:	86be                	mv	a3,a5
ffffffffc020145c:	00001617          	auipc	a2,0x1
ffffffffc0201460:	24460613          	addi	a2,a2,580 # ffffffffc02026a0 <commands+0x970>
ffffffffc0201464:	02b00593          	li	a1,43
ffffffffc0201468:	00001517          	auipc	a0,0x1
ffffffffc020146c:	1f050513          	addi	a0,a0,496 # ffffffffc0202658 <commands+0x928>
ffffffffc0201470:	f3dfe0ef          	jal	ra,ffffffffc02003ac <__panic>
    buddy->longest = KADDR(page2pa(base));
ffffffffc0201474:	86c6                	mv	a3,a7
ffffffffc0201476:	00001617          	auipc	a2,0x1
ffffffffc020147a:	20260613          	addi	a2,a2,514 # ffffffffc0202678 <commands+0x948>
ffffffffc020147e:	02a00593          	li	a1,42
ffffffffc0201482:	00001517          	auipc	a0,0x1
ffffffffc0201486:	1d650513          	addi	a0,a0,470 # ffffffffc0202658 <commands+0x928>
ffffffffc020148a:	f23fe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020148e <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020148e:	100027f3          	csrr	a5,sstatus
ffffffffc0201492:	8b89                	andi	a5,a5,2
ffffffffc0201494:	eb89                	bnez	a5,ffffffffc02014a6 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201496:	00005797          	auipc	a5,0x5
ffffffffc020149a:	18a78793          	addi	a5,a5,394 # ffffffffc0206620 <pmm_manager>
ffffffffc020149e:	639c                	ld	a5,0(a5)
ffffffffc02014a0:	0187b303          	ld	t1,24(a5)
ffffffffc02014a4:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc02014a6:	1141                	addi	sp,sp,-16
ffffffffc02014a8:	e406                	sd	ra,8(sp)
ffffffffc02014aa:	e022                	sd	s0,0(sp)
ffffffffc02014ac:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02014ae:	fb7fe0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02014b2:	00005797          	auipc	a5,0x5
ffffffffc02014b6:	16e78793          	addi	a5,a5,366 # ffffffffc0206620 <pmm_manager>
ffffffffc02014ba:	639c                	ld	a5,0(a5)
ffffffffc02014bc:	8522                	mv	a0,s0
ffffffffc02014be:	6f9c                	ld	a5,24(a5)
ffffffffc02014c0:	9782                	jalr	a5
ffffffffc02014c2:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc02014c4:	f9bfe0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02014c8:	8522                	mv	a0,s0
ffffffffc02014ca:	60a2                	ld	ra,8(sp)
ffffffffc02014cc:	6402                	ld	s0,0(sp)
ffffffffc02014ce:	0141                	addi	sp,sp,16
ffffffffc02014d0:	8082                	ret

ffffffffc02014d2 <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc02014d2:	00001797          	auipc	a5,0x1
ffffffffc02014d6:	23678793          	addi	a5,a5,566 # ffffffffc0202708 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02014da:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02014dc:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02014de:	00001517          	auipc	a0,0x1
ffffffffc02014e2:	27a50513          	addi	a0,a0,634 # ffffffffc0202758 <buddy_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc02014e6:	ec06                	sd	ra,24(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc02014e8:	00005717          	auipc	a4,0x5
ffffffffc02014ec:	12f73c23          	sd	a5,312(a4) # ffffffffc0206620 <pmm_manager>
void pmm_init(void) {
ffffffffc02014f0:	e822                	sd	s0,16(sp)
ffffffffc02014f2:	e426                	sd	s1,8(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc02014f4:	00005417          	auipc	s0,0x5
ffffffffc02014f8:	12c40413          	addi	s0,s0,300 # ffffffffc0206620 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02014fc:	bbbfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc0201500:	601c                	ld	a5,0(s0)
ffffffffc0201502:	679c                	ld	a5,8(a5)
ffffffffc0201504:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201506:	57f5                	li	a5,-3
ffffffffc0201508:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020150a:	00001517          	auipc	a0,0x1
ffffffffc020150e:	26650513          	addi	a0,a0,614 # ffffffffc0202770 <buddy_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201512:	00005717          	auipc	a4,0x5
ffffffffc0201516:	10f73b23          	sd	a5,278(a4) # ffffffffc0206628 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020151a:	b9dfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020151e:	46c5                	li	a3,17
ffffffffc0201520:	06ee                	slli	a3,a3,0x1b
ffffffffc0201522:	40100613          	li	a2,1025
ffffffffc0201526:	16fd                	addi	a3,a3,-1
ffffffffc0201528:	0656                	slli	a2,a2,0x15
ffffffffc020152a:	07e005b7          	lui	a1,0x7e00
ffffffffc020152e:	00001517          	auipc	a0,0x1
ffffffffc0201532:	25a50513          	addi	a0,a0,602 # ffffffffc0202788 <buddy_pmm_manager+0x80>
ffffffffc0201536:	b81fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020153a:	777d                	lui	a4,0xfffff
ffffffffc020153c:	00006797          	auipc	a5,0x6
ffffffffc0201540:	0fb78793          	addi	a5,a5,251 # ffffffffc0207637 <end+0xfff>
ffffffffc0201544:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201546:	00088737          	lui	a4,0x88
ffffffffc020154a:	00005697          	auipc	a3,0x5
ffffffffc020154e:	ece6b723          	sd	a4,-306(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201552:	4601                	li	a2,0
ffffffffc0201554:	00005717          	auipc	a4,0x5
ffffffffc0201558:	0cf73e23          	sd	a5,220(a4) # ffffffffc0206630 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020155c:	4681                	li	a3,0
ffffffffc020155e:	00005897          	auipc	a7,0x5
ffffffffc0201562:	eba88893          	addi	a7,a7,-326 # ffffffffc0206418 <npage>
ffffffffc0201566:	00005597          	auipc	a1,0x5
ffffffffc020156a:	0ca58593          	addi	a1,a1,202 # ffffffffc0206630 <pages>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020156e:	4805                	li	a6,1
ffffffffc0201570:	fff80537          	lui	a0,0xfff80
ffffffffc0201574:	a011                	j	ffffffffc0201578 <pmm_init+0xa6>
ffffffffc0201576:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc0201578:	97b2                	add	a5,a5,a2
ffffffffc020157a:	07a1                	addi	a5,a5,8
ffffffffc020157c:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201580:	0008b703          	ld	a4,0(a7)
ffffffffc0201584:	0685                	addi	a3,a3,1
ffffffffc0201586:	02860613          	addi	a2,a2,40
ffffffffc020158a:	00a707b3          	add	a5,a4,a0
ffffffffc020158e:	fef6e4e3          	bltu	a3,a5,ffffffffc0201576 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201592:	6190                	ld	a2,0(a1)
ffffffffc0201594:	00271793          	slli	a5,a4,0x2
ffffffffc0201598:	97ba                	add	a5,a5,a4
ffffffffc020159a:	fec006b7          	lui	a3,0xfec00
ffffffffc020159e:	078e                	slli	a5,a5,0x3
ffffffffc02015a0:	96b2                	add	a3,a3,a2
ffffffffc02015a2:	96be                	add	a3,a3,a5
ffffffffc02015a4:	c02007b7          	lui	a5,0xc0200
ffffffffc02015a8:	08f6e863          	bltu	a3,a5,ffffffffc0201638 <pmm_init+0x166>
ffffffffc02015ac:	00005497          	auipc	s1,0x5
ffffffffc02015b0:	07c48493          	addi	s1,s1,124 # ffffffffc0206628 <va_pa_offset>
ffffffffc02015b4:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc02015b6:	45c5                	li	a1,17
ffffffffc02015b8:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02015ba:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc02015bc:	04b6e963          	bltu	a3,a1,ffffffffc020160e <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02015c0:	601c                	ld	a5,0(s0)
ffffffffc02015c2:	7b9c                	ld	a5,48(a5)
ffffffffc02015c4:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02015c6:	00001517          	auipc	a0,0x1
ffffffffc02015ca:	20250513          	addi	a0,a0,514 # ffffffffc02027c8 <buddy_pmm_manager+0xc0>
ffffffffc02015ce:	ae9fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02015d2:	00004697          	auipc	a3,0x4
ffffffffc02015d6:	a2e68693          	addi	a3,a3,-1490 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02015da:	00005797          	auipc	a5,0x5
ffffffffc02015de:	e4d7b323          	sd	a3,-442(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02015e2:	c02007b7          	lui	a5,0xc0200
ffffffffc02015e6:	06f6e563          	bltu	a3,a5,ffffffffc0201650 <pmm_init+0x17e>
ffffffffc02015ea:	609c                	ld	a5,0(s1)
}
ffffffffc02015ec:	6442                	ld	s0,16(sp)
ffffffffc02015ee:	60e2                	ld	ra,24(sp)
ffffffffc02015f0:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02015f2:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc02015f4:	8e9d                	sub	a3,a3,a5
ffffffffc02015f6:	00005797          	auipc	a5,0x5
ffffffffc02015fa:	02d7b123          	sd	a3,34(a5) # ffffffffc0206618 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02015fe:	00001517          	auipc	a0,0x1
ffffffffc0201602:	1ea50513          	addi	a0,a0,490 # ffffffffc02027e8 <buddy_pmm_manager+0xe0>
ffffffffc0201606:	8636                	mv	a2,a3
}
ffffffffc0201608:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020160a:	aadfe06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020160e:	6785                	lui	a5,0x1
ffffffffc0201610:	17fd                	addi	a5,a5,-1
ffffffffc0201612:	96be                	add	a3,a3,a5
ffffffffc0201614:	77fd                	lui	a5,0xfffff
ffffffffc0201616:	8efd                	and	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0201618:	00c6d793          	srli	a5,a3,0xc
ffffffffc020161c:	04e7f663          	bleu	a4,a5,ffffffffc0201668 <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc0201620:	6018                	ld	a4,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc0201622:	97aa                	add	a5,a5,a0
ffffffffc0201624:	00279513          	slli	a0,a5,0x2
ffffffffc0201628:	953e                	add	a0,a0,a5
ffffffffc020162a:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020162c:	8d95                	sub	a1,a1,a3
ffffffffc020162e:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201630:	81b1                	srli	a1,a1,0xc
ffffffffc0201632:	9532                	add	a0,a0,a2
ffffffffc0201634:	9782                	jalr	a5
ffffffffc0201636:	b769                	j	ffffffffc02015c0 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201638:	00001617          	auipc	a2,0x1
ffffffffc020163c:	06860613          	addi	a2,a2,104 # ffffffffc02026a0 <commands+0x970>
ffffffffc0201640:	06f00593          	li	a1,111
ffffffffc0201644:	00001517          	auipc	a0,0x1
ffffffffc0201648:	17450513          	addi	a0,a0,372 # ffffffffc02027b8 <buddy_pmm_manager+0xb0>
ffffffffc020164c:	d61fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201650:	00001617          	auipc	a2,0x1
ffffffffc0201654:	05060613          	addi	a2,a2,80 # ffffffffc02026a0 <commands+0x970>
ffffffffc0201658:	08a00593          	li	a1,138
ffffffffc020165c:	00001517          	auipc	a0,0x1
ffffffffc0201660:	15c50513          	addi	a0,a0,348 # ffffffffc02027b8 <buddy_pmm_manager+0xb0>
ffffffffc0201664:	d49fe0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201668:	00001617          	auipc	a2,0x1
ffffffffc020166c:	06060613          	addi	a2,a2,96 # ffffffffc02026c8 <commands+0x998>
ffffffffc0201670:	06b00593          	li	a1,107
ffffffffc0201674:	00001517          	auipc	a0,0x1
ffffffffc0201678:	07450513          	addi	a0,a0,116 # ffffffffc02026e8 <commands+0x9b8>
ffffffffc020167c:	d31fe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201680 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201680:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201684:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201686:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020168a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020168c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201690:	f022                	sd	s0,32(sp)
ffffffffc0201692:	ec26                	sd	s1,24(sp)
ffffffffc0201694:	e84a                	sd	s2,16(sp)
ffffffffc0201696:	f406                	sd	ra,40(sp)
ffffffffc0201698:	e44e                	sd	s3,8(sp)
ffffffffc020169a:	84aa                	mv	s1,a0
ffffffffc020169c:	892e                	mv	s2,a1
ffffffffc020169e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02016a2:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02016a4:	03067e63          	bleu	a6,a2,ffffffffc02016e0 <printnum+0x60>
ffffffffc02016a8:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02016aa:	00805763          	blez	s0,ffffffffc02016b8 <printnum+0x38>
ffffffffc02016ae:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02016b0:	85ca                	mv	a1,s2
ffffffffc02016b2:	854e                	mv	a0,s3
ffffffffc02016b4:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02016b6:	fc65                	bnez	s0,ffffffffc02016ae <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016b8:	1a02                	slli	s4,s4,0x20
ffffffffc02016ba:	020a5a13          	srli	s4,s4,0x20
ffffffffc02016be:	00001797          	auipc	a5,0x1
ffffffffc02016c2:	2fa78793          	addi	a5,a5,762 # ffffffffc02029b8 <error_string+0x38>
ffffffffc02016c6:	9a3e                	add	s4,s4,a5
}
ffffffffc02016c8:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016ca:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02016ce:	70a2                	ld	ra,40(sp)
ffffffffc02016d0:	69a2                	ld	s3,8(sp)
ffffffffc02016d2:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016d4:	85ca                	mv	a1,s2
ffffffffc02016d6:	8326                	mv	t1,s1
}
ffffffffc02016d8:	6942                	ld	s2,16(sp)
ffffffffc02016da:	64e2                	ld	s1,24(sp)
ffffffffc02016dc:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016de:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02016e0:	03065633          	divu	a2,a2,a6
ffffffffc02016e4:	8722                	mv	a4,s0
ffffffffc02016e6:	f9bff0ef          	jal	ra,ffffffffc0201680 <printnum>
ffffffffc02016ea:	b7f9                	j	ffffffffc02016b8 <printnum+0x38>

ffffffffc02016ec <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02016ec:	7119                	addi	sp,sp,-128
ffffffffc02016ee:	f4a6                	sd	s1,104(sp)
ffffffffc02016f0:	f0ca                	sd	s2,96(sp)
ffffffffc02016f2:	e8d2                	sd	s4,80(sp)
ffffffffc02016f4:	e4d6                	sd	s5,72(sp)
ffffffffc02016f6:	e0da                	sd	s6,64(sp)
ffffffffc02016f8:	fc5e                	sd	s7,56(sp)
ffffffffc02016fa:	f862                	sd	s8,48(sp)
ffffffffc02016fc:	f06a                	sd	s10,32(sp)
ffffffffc02016fe:	fc86                	sd	ra,120(sp)
ffffffffc0201700:	f8a2                	sd	s0,112(sp)
ffffffffc0201702:	ecce                	sd	s3,88(sp)
ffffffffc0201704:	f466                	sd	s9,40(sp)
ffffffffc0201706:	ec6e                	sd	s11,24(sp)
ffffffffc0201708:	892a                	mv	s2,a0
ffffffffc020170a:	84ae                	mv	s1,a1
ffffffffc020170c:	8d32                	mv	s10,a2
ffffffffc020170e:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201710:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201712:	00001a17          	auipc	s4,0x1
ffffffffc0201716:	116a0a13          	addi	s4,s4,278 # ffffffffc0202828 <buddy_pmm_manager+0x120>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020171a:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020171e:	00001c17          	auipc	s8,0x1
ffffffffc0201722:	262c0c13          	addi	s8,s8,610 # ffffffffc0202980 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201726:	000d4503          	lbu	a0,0(s10)
ffffffffc020172a:	02500793          	li	a5,37
ffffffffc020172e:	001d0413          	addi	s0,s10,1
ffffffffc0201732:	00f50e63          	beq	a0,a5,ffffffffc020174e <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0201736:	c521                	beqz	a0,ffffffffc020177e <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201738:	02500993          	li	s3,37
ffffffffc020173c:	a011                	j	ffffffffc0201740 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc020173e:	c121                	beqz	a0,ffffffffc020177e <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0201740:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201742:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201744:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201746:	fff44503          	lbu	a0,-1(s0)
ffffffffc020174a:	ff351ae3          	bne	a0,s3,ffffffffc020173e <vprintfmt+0x52>
ffffffffc020174e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201752:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201756:	4981                	li	s3,0
ffffffffc0201758:	4801                	li	a6,0
        width = precision = -1;
ffffffffc020175a:	5cfd                	li	s9,-1
ffffffffc020175c:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020175e:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0201762:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201764:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0201768:	0ff6f693          	andi	a3,a3,255
ffffffffc020176c:	00140d13          	addi	s10,s0,1
ffffffffc0201770:	20d5e563          	bltu	a1,a3,ffffffffc020197a <vprintfmt+0x28e>
ffffffffc0201774:	068a                	slli	a3,a3,0x2
ffffffffc0201776:	96d2                	add	a3,a3,s4
ffffffffc0201778:	4294                	lw	a3,0(a3)
ffffffffc020177a:	96d2                	add	a3,a3,s4
ffffffffc020177c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020177e:	70e6                	ld	ra,120(sp)
ffffffffc0201780:	7446                	ld	s0,112(sp)
ffffffffc0201782:	74a6                	ld	s1,104(sp)
ffffffffc0201784:	7906                	ld	s2,96(sp)
ffffffffc0201786:	69e6                	ld	s3,88(sp)
ffffffffc0201788:	6a46                	ld	s4,80(sp)
ffffffffc020178a:	6aa6                	ld	s5,72(sp)
ffffffffc020178c:	6b06                	ld	s6,64(sp)
ffffffffc020178e:	7be2                	ld	s7,56(sp)
ffffffffc0201790:	7c42                	ld	s8,48(sp)
ffffffffc0201792:	7ca2                	ld	s9,40(sp)
ffffffffc0201794:	7d02                	ld	s10,32(sp)
ffffffffc0201796:	6de2                	ld	s11,24(sp)
ffffffffc0201798:	6109                	addi	sp,sp,128
ffffffffc020179a:	8082                	ret
    if (lflag >= 2) {
ffffffffc020179c:	4705                	li	a4,1
ffffffffc020179e:	008a8593          	addi	a1,s5,8
ffffffffc02017a2:	01074463          	blt	a4,a6,ffffffffc02017aa <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc02017a6:	26080363          	beqz	a6,ffffffffc0201a0c <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc02017aa:	000ab603          	ld	a2,0(s5)
ffffffffc02017ae:	46c1                	li	a3,16
ffffffffc02017b0:	8aae                	mv	s5,a1
ffffffffc02017b2:	a06d                	j	ffffffffc020185c <vprintfmt+0x170>
            goto reswitch;
ffffffffc02017b4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02017b8:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017ba:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02017bc:	b765                	j	ffffffffc0201764 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc02017be:	000aa503          	lw	a0,0(s5)
ffffffffc02017c2:	85a6                	mv	a1,s1
ffffffffc02017c4:	0aa1                	addi	s5,s5,8
ffffffffc02017c6:	9902                	jalr	s2
            break;
ffffffffc02017c8:	bfb9                	j	ffffffffc0201726 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02017ca:	4705                	li	a4,1
ffffffffc02017cc:	008a8993          	addi	s3,s5,8
ffffffffc02017d0:	01074463          	blt	a4,a6,ffffffffc02017d8 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02017d4:	22080463          	beqz	a6,ffffffffc02019fc <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02017d8:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02017dc:	24044463          	bltz	s0,ffffffffc0201a24 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02017e0:	8622                	mv	a2,s0
ffffffffc02017e2:	8ace                	mv	s5,s3
ffffffffc02017e4:	46a9                	li	a3,10
ffffffffc02017e6:	a89d                	j	ffffffffc020185c <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02017e8:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02017ec:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02017ee:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02017f0:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02017f4:	8fb5                	xor	a5,a5,a3
ffffffffc02017f6:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02017fa:	1ad74363          	blt	a4,a3,ffffffffc02019a0 <vprintfmt+0x2b4>
ffffffffc02017fe:	00369793          	slli	a5,a3,0x3
ffffffffc0201802:	97e2                	add	a5,a5,s8
ffffffffc0201804:	639c                	ld	a5,0(a5)
ffffffffc0201806:	18078d63          	beqz	a5,ffffffffc02019a0 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc020180a:	86be                	mv	a3,a5
ffffffffc020180c:	00001617          	auipc	a2,0x1
ffffffffc0201810:	25c60613          	addi	a2,a2,604 # ffffffffc0202a68 <error_string+0xe8>
ffffffffc0201814:	85a6                	mv	a1,s1
ffffffffc0201816:	854a                	mv	a0,s2
ffffffffc0201818:	240000ef          	jal	ra,ffffffffc0201a58 <printfmt>
ffffffffc020181c:	b729                	j	ffffffffc0201726 <vprintfmt+0x3a>
            lflag ++;
ffffffffc020181e:	00144603          	lbu	a2,1(s0)
ffffffffc0201822:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201824:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201826:	bf3d                	j	ffffffffc0201764 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0201828:	4705                	li	a4,1
ffffffffc020182a:	008a8593          	addi	a1,s5,8
ffffffffc020182e:	01074463          	blt	a4,a6,ffffffffc0201836 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0201832:	1e080263          	beqz	a6,ffffffffc0201a16 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0201836:	000ab603          	ld	a2,0(s5)
ffffffffc020183a:	46a1                	li	a3,8
ffffffffc020183c:	8aae                	mv	s5,a1
ffffffffc020183e:	a839                	j	ffffffffc020185c <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0201840:	03000513          	li	a0,48
ffffffffc0201844:	85a6                	mv	a1,s1
ffffffffc0201846:	e03e                	sd	a5,0(sp)
ffffffffc0201848:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020184a:	85a6                	mv	a1,s1
ffffffffc020184c:	07800513          	li	a0,120
ffffffffc0201850:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201852:	0aa1                	addi	s5,s5,8
ffffffffc0201854:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0201858:	6782                	ld	a5,0(sp)
ffffffffc020185a:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020185c:	876e                	mv	a4,s11
ffffffffc020185e:	85a6                	mv	a1,s1
ffffffffc0201860:	854a                	mv	a0,s2
ffffffffc0201862:	e1fff0ef          	jal	ra,ffffffffc0201680 <printnum>
            break;
ffffffffc0201866:	b5c1                	j	ffffffffc0201726 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201868:	000ab603          	ld	a2,0(s5)
ffffffffc020186c:	0aa1                	addi	s5,s5,8
ffffffffc020186e:	1c060663          	beqz	a2,ffffffffc0201a3a <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0201872:	00160413          	addi	s0,a2,1
ffffffffc0201876:	17b05c63          	blez	s11,ffffffffc02019ee <vprintfmt+0x302>
ffffffffc020187a:	02d00593          	li	a1,45
ffffffffc020187e:	14b79263          	bne	a5,a1,ffffffffc02019c2 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201882:	00064783          	lbu	a5,0(a2)
ffffffffc0201886:	0007851b          	sext.w	a0,a5
ffffffffc020188a:	c905                	beqz	a0,ffffffffc02018ba <vprintfmt+0x1ce>
ffffffffc020188c:	000cc563          	bltz	s9,ffffffffc0201896 <vprintfmt+0x1aa>
ffffffffc0201890:	3cfd                	addiw	s9,s9,-1
ffffffffc0201892:	036c8263          	beq	s9,s6,ffffffffc02018b6 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0201896:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201898:	18098463          	beqz	s3,ffffffffc0201a20 <vprintfmt+0x334>
ffffffffc020189c:	3781                	addiw	a5,a5,-32
ffffffffc020189e:	18fbf163          	bleu	a5,s7,ffffffffc0201a20 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc02018a2:	03f00513          	li	a0,63
ffffffffc02018a6:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018a8:	0405                	addi	s0,s0,1
ffffffffc02018aa:	fff44783          	lbu	a5,-1(s0)
ffffffffc02018ae:	3dfd                	addiw	s11,s11,-1
ffffffffc02018b0:	0007851b          	sext.w	a0,a5
ffffffffc02018b4:	fd61                	bnez	a0,ffffffffc020188c <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc02018b6:	e7b058e3          	blez	s11,ffffffffc0201726 <vprintfmt+0x3a>
ffffffffc02018ba:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02018bc:	85a6                	mv	a1,s1
ffffffffc02018be:	02000513          	li	a0,32
ffffffffc02018c2:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02018c4:	e60d81e3          	beqz	s11,ffffffffc0201726 <vprintfmt+0x3a>
ffffffffc02018c8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02018ca:	85a6                	mv	a1,s1
ffffffffc02018cc:	02000513          	li	a0,32
ffffffffc02018d0:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02018d2:	fe0d94e3          	bnez	s11,ffffffffc02018ba <vprintfmt+0x1ce>
ffffffffc02018d6:	bd81                	j	ffffffffc0201726 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02018d8:	4705                	li	a4,1
ffffffffc02018da:	008a8593          	addi	a1,s5,8
ffffffffc02018de:	01074463          	blt	a4,a6,ffffffffc02018e6 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02018e2:	12080063          	beqz	a6,ffffffffc0201a02 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02018e6:	000ab603          	ld	a2,0(s5)
ffffffffc02018ea:	46a9                	li	a3,10
ffffffffc02018ec:	8aae                	mv	s5,a1
ffffffffc02018ee:	b7bd                	j	ffffffffc020185c <vprintfmt+0x170>
ffffffffc02018f0:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02018f4:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018f8:	846a                	mv	s0,s10
ffffffffc02018fa:	b5ad                	j	ffffffffc0201764 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02018fc:	85a6                	mv	a1,s1
ffffffffc02018fe:	02500513          	li	a0,37
ffffffffc0201902:	9902                	jalr	s2
            break;
ffffffffc0201904:	b50d                	j	ffffffffc0201726 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0201906:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc020190a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020190e:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201910:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0201912:	e40dd9e3          	bgez	s11,ffffffffc0201764 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0201916:	8de6                	mv	s11,s9
ffffffffc0201918:	5cfd                	li	s9,-1
ffffffffc020191a:	b5a9                	j	ffffffffc0201764 <vprintfmt+0x78>
            goto reswitch;
ffffffffc020191c:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0201920:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201924:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201926:	bd3d                	j	ffffffffc0201764 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0201928:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc020192c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201930:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201932:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201936:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020193a:	fcd56ce3          	bltu	a0,a3,ffffffffc0201912 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc020193e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201940:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201944:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201948:	0196873b          	addw	a4,a3,s9
ffffffffc020194c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201950:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0201954:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201958:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020195c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201960:	fcd57fe3          	bleu	a3,a0,ffffffffc020193e <vprintfmt+0x252>
ffffffffc0201964:	b77d                	j	ffffffffc0201912 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0201966:	fffdc693          	not	a3,s11
ffffffffc020196a:	96fd                	srai	a3,a3,0x3f
ffffffffc020196c:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201970:	00144603          	lbu	a2,1(s0)
ffffffffc0201974:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201976:	846a                	mv	s0,s10
ffffffffc0201978:	b3f5                	j	ffffffffc0201764 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc020197a:	85a6                	mv	a1,s1
ffffffffc020197c:	02500513          	li	a0,37
ffffffffc0201980:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201982:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201986:	02500793          	li	a5,37
ffffffffc020198a:	8d22                	mv	s10,s0
ffffffffc020198c:	d8f70de3          	beq	a4,a5,ffffffffc0201726 <vprintfmt+0x3a>
ffffffffc0201990:	02500713          	li	a4,37
ffffffffc0201994:	1d7d                	addi	s10,s10,-1
ffffffffc0201996:	fffd4783          	lbu	a5,-1(s10)
ffffffffc020199a:	fee79de3          	bne	a5,a4,ffffffffc0201994 <vprintfmt+0x2a8>
ffffffffc020199e:	b361                	j	ffffffffc0201726 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02019a0:	00001617          	auipc	a2,0x1
ffffffffc02019a4:	0b860613          	addi	a2,a2,184 # ffffffffc0202a58 <error_string+0xd8>
ffffffffc02019a8:	85a6                	mv	a1,s1
ffffffffc02019aa:	854a                	mv	a0,s2
ffffffffc02019ac:	0ac000ef          	jal	ra,ffffffffc0201a58 <printfmt>
ffffffffc02019b0:	bb9d                	j	ffffffffc0201726 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02019b2:	00001617          	auipc	a2,0x1
ffffffffc02019b6:	09e60613          	addi	a2,a2,158 # ffffffffc0202a50 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02019ba:	00001417          	auipc	s0,0x1
ffffffffc02019be:	09740413          	addi	s0,s0,151 # ffffffffc0202a51 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02019c2:	8532                	mv	a0,a2
ffffffffc02019c4:	85e6                	mv	a1,s9
ffffffffc02019c6:	e032                	sd	a2,0(sp)
ffffffffc02019c8:	e43e                	sd	a5,8(sp)
ffffffffc02019ca:	1c2000ef          	jal	ra,ffffffffc0201b8c <strnlen>
ffffffffc02019ce:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02019d2:	6602                	ld	a2,0(sp)
ffffffffc02019d4:	01b05d63          	blez	s11,ffffffffc02019ee <vprintfmt+0x302>
ffffffffc02019d8:	67a2                	ld	a5,8(sp)
ffffffffc02019da:	2781                	sext.w	a5,a5
ffffffffc02019dc:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02019de:	6522                	ld	a0,8(sp)
ffffffffc02019e0:	85a6                	mv	a1,s1
ffffffffc02019e2:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02019e4:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02019e6:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02019e8:	6602                	ld	a2,0(sp)
ffffffffc02019ea:	fe0d9ae3          	bnez	s11,ffffffffc02019de <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02019ee:	00064783          	lbu	a5,0(a2)
ffffffffc02019f2:	0007851b          	sext.w	a0,a5
ffffffffc02019f6:	e8051be3          	bnez	a0,ffffffffc020188c <vprintfmt+0x1a0>
ffffffffc02019fa:	b335                	j	ffffffffc0201726 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02019fc:	000aa403          	lw	s0,0(s5)
ffffffffc0201a00:	bbf1                	j	ffffffffc02017dc <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0201a02:	000ae603          	lwu	a2,0(s5)
ffffffffc0201a06:	46a9                	li	a3,10
ffffffffc0201a08:	8aae                	mv	s5,a1
ffffffffc0201a0a:	bd89                	j	ffffffffc020185c <vprintfmt+0x170>
ffffffffc0201a0c:	000ae603          	lwu	a2,0(s5)
ffffffffc0201a10:	46c1                	li	a3,16
ffffffffc0201a12:	8aae                	mv	s5,a1
ffffffffc0201a14:	b5a1                	j	ffffffffc020185c <vprintfmt+0x170>
ffffffffc0201a16:	000ae603          	lwu	a2,0(s5)
ffffffffc0201a1a:	46a1                	li	a3,8
ffffffffc0201a1c:	8aae                	mv	s5,a1
ffffffffc0201a1e:	bd3d                	j	ffffffffc020185c <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0201a20:	9902                	jalr	s2
ffffffffc0201a22:	b559                	j	ffffffffc02018a8 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0201a24:	85a6                	mv	a1,s1
ffffffffc0201a26:	02d00513          	li	a0,45
ffffffffc0201a2a:	e03e                	sd	a5,0(sp)
ffffffffc0201a2c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201a2e:	8ace                	mv	s5,s3
ffffffffc0201a30:	40800633          	neg	a2,s0
ffffffffc0201a34:	46a9                	li	a3,10
ffffffffc0201a36:	6782                	ld	a5,0(sp)
ffffffffc0201a38:	b515                	j	ffffffffc020185c <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0201a3a:	01b05663          	blez	s11,ffffffffc0201a46 <vprintfmt+0x35a>
ffffffffc0201a3e:	02d00693          	li	a3,45
ffffffffc0201a42:	f6d798e3          	bne	a5,a3,ffffffffc02019b2 <vprintfmt+0x2c6>
ffffffffc0201a46:	00001417          	auipc	s0,0x1
ffffffffc0201a4a:	00b40413          	addi	s0,s0,11 # ffffffffc0202a51 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201a4e:	02800513          	li	a0,40
ffffffffc0201a52:	02800793          	li	a5,40
ffffffffc0201a56:	bd1d                	j	ffffffffc020188c <vprintfmt+0x1a0>

ffffffffc0201a58 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a58:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201a5a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a5e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201a60:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a62:	ec06                	sd	ra,24(sp)
ffffffffc0201a64:	f83a                	sd	a4,48(sp)
ffffffffc0201a66:	fc3e                	sd	a5,56(sp)
ffffffffc0201a68:	e0c2                	sd	a6,64(sp)
ffffffffc0201a6a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201a6c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201a6e:	c7fff0ef          	jal	ra,ffffffffc02016ec <vprintfmt>
}
ffffffffc0201a72:	60e2                	ld	ra,24(sp)
ffffffffc0201a74:	6161                	addi	sp,sp,80
ffffffffc0201a76:	8082                	ret

ffffffffc0201a78 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201a78:	715d                	addi	sp,sp,-80
ffffffffc0201a7a:	e486                	sd	ra,72(sp)
ffffffffc0201a7c:	e0a2                	sd	s0,64(sp)
ffffffffc0201a7e:	fc26                	sd	s1,56(sp)
ffffffffc0201a80:	f84a                	sd	s2,48(sp)
ffffffffc0201a82:	f44e                	sd	s3,40(sp)
ffffffffc0201a84:	f052                	sd	s4,32(sp)
ffffffffc0201a86:	ec56                	sd	s5,24(sp)
ffffffffc0201a88:	e85a                	sd	s6,16(sp)
ffffffffc0201a8a:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201a8c:	c901                	beqz	a0,ffffffffc0201a9c <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201a8e:	85aa                	mv	a1,a0
ffffffffc0201a90:	00001517          	auipc	a0,0x1
ffffffffc0201a94:	fd850513          	addi	a0,a0,-40 # ffffffffc0202a68 <error_string+0xe8>
ffffffffc0201a98:	e1efe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201a9c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a9e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201aa0:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201aa2:	4aa9                	li	s5,10
ffffffffc0201aa4:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201aa6:	00004b97          	auipc	s7,0x4
ffffffffc0201aaa:	56ab8b93          	addi	s7,s7,1386 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201aae:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201ab2:	e7cfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201ab6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201ab8:	00054b63          	bltz	a0,ffffffffc0201ace <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201abc:	00a95b63          	ble	a0,s2,ffffffffc0201ad2 <readline+0x5a>
ffffffffc0201ac0:	029a5463          	ble	s1,s4,ffffffffc0201ae8 <readline+0x70>
        c = getchar();
ffffffffc0201ac4:	e6afe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201ac8:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201aca:	fe0559e3          	bgez	a0,ffffffffc0201abc <readline+0x44>
            return NULL;
ffffffffc0201ace:	4501                	li	a0,0
ffffffffc0201ad0:	a099                	j	ffffffffc0201b16 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201ad2:	03341463          	bne	s0,s3,ffffffffc0201afa <readline+0x82>
ffffffffc0201ad6:	e8b9                	bnez	s1,ffffffffc0201b2c <readline+0xb4>
        c = getchar();
ffffffffc0201ad8:	e56fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201adc:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201ade:	fe0548e3          	bltz	a0,ffffffffc0201ace <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201ae2:	fea958e3          	ble	a0,s2,ffffffffc0201ad2 <readline+0x5a>
ffffffffc0201ae6:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201ae8:	8522                	mv	a0,s0
ffffffffc0201aea:	e00fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc0201aee:	009b87b3          	add	a5,s7,s1
ffffffffc0201af2:	00878023          	sb	s0,0(a5)
ffffffffc0201af6:	2485                	addiw	s1,s1,1
ffffffffc0201af8:	bf6d                	j	ffffffffc0201ab2 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201afa:	01540463          	beq	s0,s5,ffffffffc0201b02 <readline+0x8a>
ffffffffc0201afe:	fb641ae3          	bne	s0,s6,ffffffffc0201ab2 <readline+0x3a>
            cputchar(c);
ffffffffc0201b02:	8522                	mv	a0,s0
ffffffffc0201b04:	de6fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc0201b08:	00004517          	auipc	a0,0x4
ffffffffc0201b0c:	50850513          	addi	a0,a0,1288 # ffffffffc0206010 <edata>
ffffffffc0201b10:	94aa                	add	s1,s1,a0
ffffffffc0201b12:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201b16:	60a6                	ld	ra,72(sp)
ffffffffc0201b18:	6406                	ld	s0,64(sp)
ffffffffc0201b1a:	74e2                	ld	s1,56(sp)
ffffffffc0201b1c:	7942                	ld	s2,48(sp)
ffffffffc0201b1e:	79a2                	ld	s3,40(sp)
ffffffffc0201b20:	7a02                	ld	s4,32(sp)
ffffffffc0201b22:	6ae2                	ld	s5,24(sp)
ffffffffc0201b24:	6b42                	ld	s6,16(sp)
ffffffffc0201b26:	6ba2                	ld	s7,8(sp)
ffffffffc0201b28:	6161                	addi	sp,sp,80
ffffffffc0201b2a:	8082                	ret
            cputchar(c);
ffffffffc0201b2c:	4521                	li	a0,8
ffffffffc0201b2e:	dbcfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201b32:	34fd                	addiw	s1,s1,-1
ffffffffc0201b34:	bfbd                	j	ffffffffc0201ab2 <readline+0x3a>

ffffffffc0201b36 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201b36:	00004797          	auipc	a5,0x4
ffffffffc0201b3a:	4d278793          	addi	a5,a5,1234 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201b3e:	6398                	ld	a4,0(a5)
ffffffffc0201b40:	4781                	li	a5,0
ffffffffc0201b42:	88ba                	mv	a7,a4
ffffffffc0201b44:	852a                	mv	a0,a0
ffffffffc0201b46:	85be                	mv	a1,a5
ffffffffc0201b48:	863e                	mv	a2,a5
ffffffffc0201b4a:	00000073          	ecall
ffffffffc0201b4e:	87aa                	mv	a5,a0
}
ffffffffc0201b50:	8082                	ret

ffffffffc0201b52 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201b52:	00005797          	auipc	a5,0x5
ffffffffc0201b56:	8d678793          	addi	a5,a5,-1834 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201b5a:	6398                	ld	a4,0(a5)
ffffffffc0201b5c:	4781                	li	a5,0
ffffffffc0201b5e:	88ba                	mv	a7,a4
ffffffffc0201b60:	852a                	mv	a0,a0
ffffffffc0201b62:	85be                	mv	a1,a5
ffffffffc0201b64:	863e                	mv	a2,a5
ffffffffc0201b66:	00000073          	ecall
ffffffffc0201b6a:	87aa                	mv	a5,a0
}
ffffffffc0201b6c:	8082                	ret

ffffffffc0201b6e <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201b6e:	00004797          	auipc	a5,0x4
ffffffffc0201b72:	49278793          	addi	a5,a5,1170 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201b76:	639c                	ld	a5,0(a5)
ffffffffc0201b78:	4501                	li	a0,0
ffffffffc0201b7a:	88be                	mv	a7,a5
ffffffffc0201b7c:	852a                	mv	a0,a0
ffffffffc0201b7e:	85aa                	mv	a1,a0
ffffffffc0201b80:	862a                	mv	a2,a0
ffffffffc0201b82:	00000073          	ecall
ffffffffc0201b86:	852a                	mv	a0,a0
ffffffffc0201b88:	2501                	sext.w	a0,a0
ffffffffc0201b8a:	8082                	ret

ffffffffc0201b8c <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201b8c:	c185                	beqz	a1,ffffffffc0201bac <strnlen+0x20>
ffffffffc0201b8e:	00054783          	lbu	a5,0(a0)
ffffffffc0201b92:	cf89                	beqz	a5,ffffffffc0201bac <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201b94:	4781                	li	a5,0
ffffffffc0201b96:	a021                	j	ffffffffc0201b9e <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201b98:	00074703          	lbu	a4,0(a4)
ffffffffc0201b9c:	c711                	beqz	a4,ffffffffc0201ba8 <strnlen+0x1c>
        cnt ++;
ffffffffc0201b9e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201ba0:	00f50733          	add	a4,a0,a5
ffffffffc0201ba4:	fef59ae3          	bne	a1,a5,ffffffffc0201b98 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201ba8:	853e                	mv	a0,a5
ffffffffc0201baa:	8082                	ret
    size_t cnt = 0;
ffffffffc0201bac:	4781                	li	a5,0
}
ffffffffc0201bae:	853e                	mv	a0,a5
ffffffffc0201bb0:	8082                	ret

ffffffffc0201bb2 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201bb2:	00054783          	lbu	a5,0(a0)
ffffffffc0201bb6:	0005c703          	lbu	a4,0(a1)
ffffffffc0201bba:	cb91                	beqz	a5,ffffffffc0201bce <strcmp+0x1c>
ffffffffc0201bbc:	00e79c63          	bne	a5,a4,ffffffffc0201bd4 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201bc0:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201bc2:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201bc6:	0585                	addi	a1,a1,1
ffffffffc0201bc8:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201bcc:	fbe5                	bnez	a5,ffffffffc0201bbc <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201bce:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201bd0:	9d19                	subw	a0,a0,a4
ffffffffc0201bd2:	8082                	ret
ffffffffc0201bd4:	0007851b          	sext.w	a0,a5
ffffffffc0201bd8:	9d19                	subw	a0,a0,a4
ffffffffc0201bda:	8082                	ret

ffffffffc0201bdc <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201bdc:	00054783          	lbu	a5,0(a0)
ffffffffc0201be0:	cb91                	beqz	a5,ffffffffc0201bf4 <strchr+0x18>
        if (*s == c) {
ffffffffc0201be2:	00b79563          	bne	a5,a1,ffffffffc0201bec <strchr+0x10>
ffffffffc0201be6:	a809                	j	ffffffffc0201bf8 <strchr+0x1c>
ffffffffc0201be8:	00b78763          	beq	a5,a1,ffffffffc0201bf6 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201bec:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201bee:	00054783          	lbu	a5,0(a0)
ffffffffc0201bf2:	fbfd                	bnez	a5,ffffffffc0201be8 <strchr+0xc>
    }
    return NULL;
ffffffffc0201bf4:	4501                	li	a0,0
}
ffffffffc0201bf6:	8082                	ret
ffffffffc0201bf8:	8082                	ret

ffffffffc0201bfa <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201bfa:	ca01                	beqz	a2,ffffffffc0201c0a <memset+0x10>
ffffffffc0201bfc:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201bfe:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201c00:	0785                	addi	a5,a5,1
ffffffffc0201c02:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201c06:	fec79de3          	bne	a5,a2,ffffffffc0201c00 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201c0a:	8082                	ret
