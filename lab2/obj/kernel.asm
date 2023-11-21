
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
ffffffffc020004e:	546010ef          	jal	ra,ffffffffc0201594 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00001517          	auipc	a0,0x1
ffffffffc020005a:	55250513          	addi	a0,a0,1362 # ffffffffc02015a8 <etext+0x2>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	603000ef          	jal	ra,ffffffffc0200e6c <pmm_init>

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
ffffffffc02000aa:	7dd000ef          	jal	ra,ffffffffc0201086 <vprintfmt>
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
ffffffffc02000de:	7a9000ef          	jal	ra,ffffffffc0201086 <vprintfmt>
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
ffffffffc0200144:	4b850513          	addi	a0,a0,1208 # ffffffffc02015f8 <etext+0x52>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00001517          	auipc	a0,0x1
ffffffffc020015a:	4c250513          	addi	a0,a0,1218 # ffffffffc0201618 <etext+0x72>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00001597          	auipc	a1,0x1
ffffffffc0200166:	44458593          	addi	a1,a1,1092 # ffffffffc02015a6 <etext>
ffffffffc020016a:	00001517          	auipc	a0,0x1
ffffffffc020016e:	4ce50513          	addi	a0,a0,1230 # ffffffffc0201638 <etext+0x92>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0206010 <edata>
ffffffffc020017e:	00001517          	auipc	a0,0x1
ffffffffc0200182:	4da50513          	addi	a0,a0,1242 # ffffffffc0201658 <etext+0xb2>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00006597          	auipc	a1,0x6
ffffffffc020018e:	4ae58593          	addi	a1,a1,1198 # ffffffffc0206638 <end>
ffffffffc0200192:	00001517          	auipc	a0,0x1
ffffffffc0200196:	4e650513          	addi	a0,a0,1254 # ffffffffc0201678 <etext+0xd2>
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
ffffffffc02001c0:	00001517          	auipc	a0,0x1
ffffffffc02001c4:	4d850513          	addi	a0,a0,1240 # ffffffffc0201698 <etext+0xf2>
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
ffffffffc02001d4:	3f860613          	addi	a2,a2,1016 # ffffffffc02015c8 <etext+0x22>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00001517          	auipc	a0,0x1
ffffffffc02001e0:	40450513          	addi	a0,a0,1028 # ffffffffc02015e0 <etext+0x3a>
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
ffffffffc02001f0:	5bc60613          	addi	a2,a2,1468 # ffffffffc02017a8 <commands+0xe0>
ffffffffc02001f4:	00001597          	auipc	a1,0x1
ffffffffc02001f8:	5d458593          	addi	a1,a1,1492 # ffffffffc02017c8 <commands+0x100>
ffffffffc02001fc:	00001517          	auipc	a0,0x1
ffffffffc0200200:	5d450513          	addi	a0,a0,1492 # ffffffffc02017d0 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00001617          	auipc	a2,0x1
ffffffffc020020e:	5d660613          	addi	a2,a2,1494 # ffffffffc02017e0 <commands+0x118>
ffffffffc0200212:	00001597          	auipc	a1,0x1
ffffffffc0200216:	5f658593          	addi	a1,a1,1526 # ffffffffc0201808 <commands+0x140>
ffffffffc020021a:	00001517          	auipc	a0,0x1
ffffffffc020021e:	5b650513          	addi	a0,a0,1462 # ffffffffc02017d0 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00001617          	auipc	a2,0x1
ffffffffc020022a:	5f260613          	addi	a2,a2,1522 # ffffffffc0201818 <commands+0x150>
ffffffffc020022e:	00001597          	auipc	a1,0x1
ffffffffc0200232:	60a58593          	addi	a1,a1,1546 # ffffffffc0201838 <commands+0x170>
ffffffffc0200236:	00001517          	auipc	a0,0x1
ffffffffc020023a:	59a50513          	addi	a0,a0,1434 # ffffffffc02017d0 <commands+0x108>
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
ffffffffc0200274:	4a050513          	addi	a0,a0,1184 # ffffffffc0201710 <commands+0x48>
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
ffffffffc0200296:	4a650513          	addi	a0,a0,1190 # ffffffffc0201738 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00001c97          	auipc	s9,0x1
ffffffffc02002ac:	420c8c93          	addi	s9,s9,1056 # ffffffffc02016c8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00001997          	auipc	s3,0x1
ffffffffc02002b4:	4b098993          	addi	s3,s3,1200 # ffffffffc0201760 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00001917          	auipc	s2,0x1
ffffffffc02002bc:	4b090913          	addi	s2,s2,1200 # ffffffffc0201768 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00001b17          	auipc	s6,0x1
ffffffffc02002c6:	4aeb0b13          	addi	s6,s6,1198 # ffffffffc0201770 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00001a97          	auipc	s5,0x1
ffffffffc02002ce:	4fea8a93          	addi	s5,s5,1278 # ffffffffc02017c8 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	13c010ef          	jal	ra,ffffffffc0201412 <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	28e010ef          	jal	ra,ffffffffc0201576 <strchr>
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
ffffffffc0200302:	3cad0d13          	addi	s10,s10,970 # ffffffffc02016c8 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	240010ef          	jal	ra,ffffffffc020154c <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	22c010ef          	jal	ra,ffffffffc020154c <strcmp>
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
ffffffffc0200386:	1f0010ef          	jal	ra,ffffffffc0201576 <strchr>
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
ffffffffc02003a2:	3f250513          	addi	a0,a0,1010 # ffffffffc0201790 <commands+0xc8>
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
ffffffffc02003de:	00001517          	auipc	a0,0x1
ffffffffc02003e2:	46a50513          	addi	a0,a0,1130 # ffffffffc0201848 <commands+0x180>
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
ffffffffc02003f8:	2cc50513          	addi	a0,a0,716 # ffffffffc02016c0 <etext+0x11a>
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
ffffffffc0200424:	0c8010ef          	jal	ra,ffffffffc02014ec <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00001517          	auipc	a0,0x1
ffffffffc0200436:	43650513          	addi	a0,a0,1078 # ffffffffc0201868 <commands+0x1a0>
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
ffffffffc020044c:	0a00106f          	j	ffffffffc02014ec <sbi_set_timer>

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
ffffffffc0200456:	07a0106f          	j	ffffffffc02014d0 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	0ae0106f          	j	ffffffffc0201508 <sbi_console_getchar>

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
ffffffffc0200488:	4fc50513          	addi	a0,a0,1276 # ffffffffc0201980 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00001517          	auipc	a0,0x1
ffffffffc0200498:	50450513          	addi	a0,a0,1284 # ffffffffc0201998 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00001517          	auipc	a0,0x1
ffffffffc02004a6:	50e50513          	addi	a0,a0,1294 # ffffffffc02019b0 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00001517          	auipc	a0,0x1
ffffffffc02004b4:	51850513          	addi	a0,a0,1304 # ffffffffc02019c8 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00001517          	auipc	a0,0x1
ffffffffc02004c2:	52250513          	addi	a0,a0,1314 # ffffffffc02019e0 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00001517          	auipc	a0,0x1
ffffffffc02004d0:	52c50513          	addi	a0,a0,1324 # ffffffffc02019f8 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00001517          	auipc	a0,0x1
ffffffffc02004de:	53650513          	addi	a0,a0,1334 # ffffffffc0201a10 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00001517          	auipc	a0,0x1
ffffffffc02004ec:	54050513          	addi	a0,a0,1344 # ffffffffc0201a28 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00001517          	auipc	a0,0x1
ffffffffc02004fa:	54a50513          	addi	a0,a0,1354 # ffffffffc0201a40 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00001517          	auipc	a0,0x1
ffffffffc0200508:	55450513          	addi	a0,a0,1364 # ffffffffc0201a58 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00001517          	auipc	a0,0x1
ffffffffc0200516:	55e50513          	addi	a0,a0,1374 # ffffffffc0201a70 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00001517          	auipc	a0,0x1
ffffffffc0200524:	56850513          	addi	a0,a0,1384 # ffffffffc0201a88 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00001517          	auipc	a0,0x1
ffffffffc0200532:	57250513          	addi	a0,a0,1394 # ffffffffc0201aa0 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00001517          	auipc	a0,0x1
ffffffffc0200540:	57c50513          	addi	a0,a0,1404 # ffffffffc0201ab8 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00001517          	auipc	a0,0x1
ffffffffc020054e:	58650513          	addi	a0,a0,1414 # ffffffffc0201ad0 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00001517          	auipc	a0,0x1
ffffffffc020055c:	59050513          	addi	a0,a0,1424 # ffffffffc0201ae8 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00001517          	auipc	a0,0x1
ffffffffc020056a:	59a50513          	addi	a0,a0,1434 # ffffffffc0201b00 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00001517          	auipc	a0,0x1
ffffffffc0200578:	5a450513          	addi	a0,a0,1444 # ffffffffc0201b18 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00001517          	auipc	a0,0x1
ffffffffc0200586:	5ae50513          	addi	a0,a0,1454 # ffffffffc0201b30 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00001517          	auipc	a0,0x1
ffffffffc0200594:	5b850513          	addi	a0,a0,1464 # ffffffffc0201b48 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00001517          	auipc	a0,0x1
ffffffffc02005a2:	5c250513          	addi	a0,a0,1474 # ffffffffc0201b60 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00001517          	auipc	a0,0x1
ffffffffc02005b0:	5cc50513          	addi	a0,a0,1484 # ffffffffc0201b78 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00001517          	auipc	a0,0x1
ffffffffc02005be:	5d650513          	addi	a0,a0,1494 # ffffffffc0201b90 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00001517          	auipc	a0,0x1
ffffffffc02005cc:	5e050513          	addi	a0,a0,1504 # ffffffffc0201ba8 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00001517          	auipc	a0,0x1
ffffffffc02005da:	5ea50513          	addi	a0,a0,1514 # ffffffffc0201bc0 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00001517          	auipc	a0,0x1
ffffffffc02005e8:	5f450513          	addi	a0,a0,1524 # ffffffffc0201bd8 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00001517          	auipc	a0,0x1
ffffffffc02005f6:	5fe50513          	addi	a0,a0,1534 # ffffffffc0201bf0 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00001517          	auipc	a0,0x1
ffffffffc0200604:	60850513          	addi	a0,a0,1544 # ffffffffc0201c08 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00001517          	auipc	a0,0x1
ffffffffc0200612:	61250513          	addi	a0,a0,1554 # ffffffffc0201c20 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00001517          	auipc	a0,0x1
ffffffffc0200620:	61c50513          	addi	a0,a0,1564 # ffffffffc0201c38 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00001517          	auipc	a0,0x1
ffffffffc020062e:	62650513          	addi	a0,a0,1574 # ffffffffc0201c50 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00001517          	auipc	a0,0x1
ffffffffc0200640:	62c50513          	addi	a0,a0,1580 # ffffffffc0201c68 <commands+0x5a0>
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
ffffffffc0200656:	62e50513          	addi	a0,a0,1582 # ffffffffc0201c80 <commands+0x5b8>
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
ffffffffc020066e:	62e50513          	addi	a0,a0,1582 # ffffffffc0201c98 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00001517          	auipc	a0,0x1
ffffffffc020067e:	63650513          	addi	a0,a0,1590 # ffffffffc0201cb0 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00001517          	auipc	a0,0x1
ffffffffc020068e:	63e50513          	addi	a0,a0,1598 # ffffffffc0201cc8 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00001517          	auipc	a0,0x1
ffffffffc02006a2:	64250513          	addi	a0,a0,1602 # ffffffffc0201ce0 <commands+0x618>
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
ffffffffc02006c0:	1c870713          	addi	a4,a4,456 # ffffffffc0201884 <commands+0x1bc>
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
ffffffffc02006d2:	24a50513          	addi	a0,a0,586 # ffffffffc0201918 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	21e50513          	addi	a0,a0,542 # ffffffffc02018f8 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	1d250513          	addi	a0,a0,466 # ffffffffc02018b8 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	24650513          	addi	a0,a0,582 # ffffffffc0201938 <commands+0x270>
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
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	23450513          	addi	a0,a0,564 # ffffffffc0201960 <commands+0x298>
ffffffffc0200734:	983ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200738:	00001517          	auipc	a0,0x1
ffffffffc020073c:	1a050513          	addi	a0,a0,416 # ffffffffc02018d8 <commands+0x210>
ffffffffc0200740:	977ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200744:	f07ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200748:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020074a:	06400593          	li	a1,100
ffffffffc020074e:	00001517          	auipc	a0,0x1
ffffffffc0200752:	20250513          	addi	a0,a0,514 # ffffffffc0201950 <commands+0x288>
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
ffffffffc02008c8:	00001717          	auipc	a4,0x1
ffffffffc02008cc:	4e070713          	addi	a4,a4,1248 # ffffffffc0201da8 <commands+0x6e0>
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
ffffffffc020099a:	00001697          	auipc	a3,0x1
ffffffffc020099e:	41668693          	addi	a3,a3,1046 # ffffffffc0201db0 <commands+0x6e8>
ffffffffc02009a2:	00001617          	auipc	a2,0x1
ffffffffc02009a6:	43660613          	addi	a2,a2,1078 # ffffffffc0201dd8 <commands+0x710>
ffffffffc02009aa:	09c00593          	li	a1,156
ffffffffc02009ae:	00001517          	auipc	a0,0x1
ffffffffc02009b2:	44250513          	addi	a0,a0,1090 # ffffffffc0201df0 <commands+0x728>
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
static struct Page *buddy_alloc_pages(size_t n) {
ffffffffc0200ae0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200ae2:	00001697          	auipc	a3,0x1
ffffffffc0200ae6:	21668693          	addi	a3,a3,534 # ffffffffc0201cf8 <commands+0x630>
ffffffffc0200aea:	00001617          	auipc	a2,0x1
ffffffffc0200aee:	2ee60613          	addi	a2,a2,750 # ffffffffc0201dd8 <commands+0x710>
ffffffffc0200af2:	05000593          	li	a1,80
ffffffffc0200af6:	00001517          	auipc	a0,0x1
ffffffffc0200afa:	2fa50513          	addi	a0,a0,762 # ffffffffc0201df0 <commands+0x728>
static struct Page *buddy_alloc_pages(size_t n) {
ffffffffc0200afe:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200b00:	8adff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200b04 <buddy_check>:


static void
buddy_check(void) {
ffffffffc0200b04:	1141                	addi	sp,sp,-16

    cprintf("New test case: testing memory block validation...\n");
ffffffffc0200b06:	00001517          	auipc	a0,0x1
ffffffffc0200b0a:	1fa50513          	addi	a0,a0,506 # ffffffffc0201d00 <commands+0x638>
buddy_check(void) {
ffffffffc0200b0e:	e406                	sd	ra,8(sp)
ffffffffc0200b10:	e022                	sd	s0,0(sp)
    cprintf("New test case: testing memory block validation...\n");
ffffffffc0200b12:	da4ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>

    // 分配一页内存
    struct Page *p_ = buddy_alloc_pages(1);  // 假定1表示一页
ffffffffc0200b16:	4505                	li	a0,1
ffffffffc0200b18:	ea5ff0ef          	jal	ra,ffffffffc02009bc <buddy_alloc_pages>
    assert(p_ != NULL);
ffffffffc0200b1c:	c149                	beqz	a0,ffffffffc0200b9e <buddy_check+0x9a>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b1e:	00006797          	auipc	a5,0x6
ffffffffc0200b22:	b1278793          	addi	a5,a5,-1262 # ffffffffc0206630 <pages>
ffffffffc0200b26:	6394                	ld	a3,0(a5)
ffffffffc0200b28:	00001797          	auipc	a5,0x1
ffffffffc0200b2c:	28078793          	addi	a5,a5,640 # ffffffffc0201da8 <commands+0x6e0>
ffffffffc0200b30:	639c                	ld	a5,0(a5)
ffffffffc0200b32:	40d506b3          	sub	a3,a0,a3
ffffffffc0200b36:	868d                	srai	a3,a3,0x3
ffffffffc0200b38:	02f686b3          	mul	a3,a3,a5
ffffffffc0200b3c:	00001797          	auipc	a5,0x1
ffffffffc0200b40:	6bc78793          	addi	a5,a5,1724 # ffffffffc02021f8 <nbase>
ffffffffc0200b44:	639c                	ld	a5,0(a5)

    // 获取页面的物理地址，并转换为可用的虚拟地址。这里需要根据你的实现来完成。
    // 注意：你可能需要使用其他函数来获取/转换地址，依据你的内核/平台实现。
    uintptr_t pa = page2pa(p_);
    uintptr_t *va = KADDR(pa);
ffffffffc0200b46:	00006717          	auipc	a4,0x6
ffffffffc0200b4a:	8d270713          	addi	a4,a4,-1838 # ffffffffc0206418 <npage>
ffffffffc0200b4e:	6318                	ld	a4,0(a4)
ffffffffc0200b50:	842a                	mv	s0,a0
ffffffffc0200b52:	96be                	add	a3,a3,a5
ffffffffc0200b54:	57fd                	li	a5,-1
ffffffffc0200b56:	83b1                	srli	a5,a5,0xc
ffffffffc0200b58:	8ff5                	and	a5,a5,a3

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b5a:	06b2                	slli	a3,a3,0xc
ffffffffc0200b5c:	08e7f163          	bleu	a4,a5,ffffffffc0200bde <buddy_check+0xda>

    // 写入数据到分配的内存块
    int *data_ptr = (int *)va;
    *data_ptr = 0xdeadbeef;  // 写入一个魔数，稍后用于验证
ffffffffc0200b60:	00006797          	auipc	a5,0x6
ffffffffc0200b64:	ac878793          	addi	a5,a5,-1336 # ffffffffc0206628 <va_pa_offset>
ffffffffc0200b68:	639c                	ld	a5,0(a5)

    // 读取并验证数据
    assert(*data_ptr == 0xdeadbeef);

    // 释放内存块
    buddy_free_pages(p_, 1);
ffffffffc0200b6a:	4585                	li	a1,1
    *data_ptr = 0xdeadbeef;  // 写入一个魔数，稍后用于验证
ffffffffc0200b6c:	96be                	add	a3,a3,a5
ffffffffc0200b6e:	deadc7b7          	lui	a5,0xdeadc
ffffffffc0200b72:	eef7879b          	addiw	a5,a5,-273
ffffffffc0200b76:	c29c                	sw	a5,0(a3)
    buddy_free_pages(p_, 1);
ffffffffc0200b78:	cf9ff0ef          	jal	ra,ffffffffc0200870 <buddy_free_pages>

    // 验证是否可以正常释放，例如再次分配相同的内存块并检查地址是否相同
    struct Page *p_2 = buddy_alloc_pages(1);
ffffffffc0200b7c:	4505                	li	a0,1
ffffffffc0200b7e:	e3fff0ef          	jal	ra,ffffffffc02009bc <buddy_alloc_pages>
    assert(p_ == p_2);  // 假定相同的内存块地址会被重新分配，这取决于你的内存分配器实现
ffffffffc0200b82:	02a41e63          	bne	s0,a0,ffffffffc0200bbe <buddy_check+0xba>

    // 清理
    buddy_free_pages(p_2, 1);
ffffffffc0200b86:	4585                	li	a1,1
ffffffffc0200b88:	ce9ff0ef          	jal	ra,ffffffffc0200870 <buddy_free_pages>

    cprintf("Memory block validation test passed!\n");
}
ffffffffc0200b8c:	6402                	ld	s0,0(sp)
ffffffffc0200b8e:	60a2                	ld	ra,8(sp)
    cprintf("Memory block validation test passed!\n");
ffffffffc0200b90:	00001517          	auipc	a0,0x1
ffffffffc0200b94:	1f050513          	addi	a0,a0,496 # ffffffffc0201d80 <commands+0x6b8>
}
ffffffffc0200b98:	0141                	addi	sp,sp,16
    cprintf("Memory block validation test passed!\n");
ffffffffc0200b9a:	d1cff06f          	j	ffffffffc02000b6 <cprintf>
    assert(p_ != NULL);
ffffffffc0200b9e:	00001697          	auipc	a3,0x1
ffffffffc0200ba2:	19a68693          	addi	a3,a3,410 # ffffffffc0201d38 <commands+0x670>
ffffffffc0200ba6:	00001617          	auipc	a2,0x1
ffffffffc0200baa:	23260613          	addi	a2,a2,562 # ffffffffc0201dd8 <commands+0x710>
ffffffffc0200bae:	0d000593          	li	a1,208
ffffffffc0200bb2:	00001517          	auipc	a0,0x1
ffffffffc0200bb6:	23e50513          	addi	a0,a0,574 # ffffffffc0201df0 <commands+0x728>
ffffffffc0200bba:	ff2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p_ == p_2);  // 假定相同的内存块地址会被重新分配，这取决于你的内存分配器实现
ffffffffc0200bbe:	00001697          	auipc	a3,0x1
ffffffffc0200bc2:	1b268693          	addi	a3,a3,434 # ffffffffc0201d70 <commands+0x6a8>
ffffffffc0200bc6:	00001617          	auipc	a2,0x1
ffffffffc0200bca:	21260613          	addi	a2,a2,530 # ffffffffc0201dd8 <commands+0x710>
ffffffffc0200bce:	0e300593          	li	a1,227
ffffffffc0200bd2:	00001517          	auipc	a0,0x1
ffffffffc0200bd6:	21e50513          	addi	a0,a0,542 # ffffffffc0201df0 <commands+0x728>
ffffffffc0200bda:	fd2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t *va = KADDR(pa);
ffffffffc0200bde:	00001617          	auipc	a2,0x1
ffffffffc0200be2:	16a60613          	addi	a2,a2,362 # ffffffffc0201d48 <commands+0x680>
ffffffffc0200be6:	0d500593          	li	a1,213
ffffffffc0200bea:	00001517          	auipc	a0,0x1
ffffffffc0200bee:	20650513          	addi	a0,a0,518 # ffffffffc0201df0 <commands+0x728>
ffffffffc0200bf2:	fbaff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200bf6 <buddy_init_memmap>:
buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200bf6:	1101                	addi	sp,sp,-32
ffffffffc0200bf8:	e822                	sd	s0,16(sp)
ffffffffc0200bfa:	842a                	mv	s0,a0
    cprintf("n: %d\n", n);
ffffffffc0200bfc:	00001517          	auipc	a0,0x1
ffffffffc0200c00:	20c50513          	addi	a0,a0,524 # ffffffffc0201e08 <commands+0x740>
buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200c04:	e426                	sd	s1,8(sp)
ffffffffc0200c06:	ec06                	sd	ra,24(sp)
ffffffffc0200c08:	84ae                	mv	s1,a1
    cprintf("n: %d\n", n);
ffffffffc0200c0a:	cacff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    size |= size >> 1;
ffffffffc0200c0e:	0014d713          	srli	a4,s1,0x1
ffffffffc0200c12:	8f45                	or	a4,a4,s1
    size |= size >> 2;
ffffffffc0200c14:	00275793          	srli	a5,a4,0x2
ffffffffc0200c18:	8f5d                	or	a4,a4,a5
    size |= size >> 4;
ffffffffc0200c1a:	00475793          	srli	a5,a4,0x4
ffffffffc0200c1e:	8f5d                	or	a4,a4,a5
    size |= size >> 8;
ffffffffc0200c20:	00875793          	srli	a5,a4,0x8
ffffffffc0200c24:	8f5d                	or	a4,a4,a5
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c26:	00006797          	auipc	a5,0x6
ffffffffc0200c2a:	a0a78793          	addi	a5,a5,-1526 # ffffffffc0206630 <pages>
ffffffffc0200c2e:	0007b303          	ld	t1,0(a5)
    size |= size >> 16;
ffffffffc0200c32:	01075793          	srli	a5,a4,0x10
ffffffffc0200c36:	8f5d                	or	a4,a4,a5
    return size + 1;
ffffffffc0200c38:	00170693          	addi	a3,a4,1
ffffffffc0200c3c:	00001797          	auipc	a5,0x1
ffffffffc0200c40:	16c78793          	addi	a5,a5,364 # ffffffffc0201da8 <commands+0x6e0>
ffffffffc0200c44:	0007be03          	ld	t3,0(a5)
    size_t extra = s - n;
ffffffffc0200c48:	409687b3          	sub	a5,a3,s1
    size |= size >> 1;
ffffffffc0200c4c:	0017d613          	srli	a2,a5,0x1
ffffffffc0200c50:	406408b3          	sub	a7,s0,t1
ffffffffc0200c54:	8e5d                	or	a2,a2,a5
ffffffffc0200c56:	4038d893          	srai	a7,a7,0x3
    size |= size >> 2;
ffffffffc0200c5a:	00265793          	srli	a5,a2,0x2
ffffffffc0200c5e:	03c888b3          	mul	a7,a7,t3
ffffffffc0200c62:	8e5d                	or	a2,a2,a5
    struct buddy *buddy = &b[id_++];
ffffffffc0200c64:	00005797          	auipc	a5,0x5
ffffffffc0200c68:	7b078793          	addi	a5,a5,1968 # ffffffffc0206414 <id_>
ffffffffc0200c6c:	0007a803          	lw	a6,0(a5)
    size |= size >> 4;
ffffffffc0200c70:	00465793          	srli	a5,a2,0x4
ffffffffc0200c74:	8e5d                	or	a2,a2,a5
    size |= size >> 8;
ffffffffc0200c76:	00865793          	srli	a5,a2,0x8
ffffffffc0200c7a:	8e5d                	or	a2,a2,a5
    buddy->size = s;
ffffffffc0200c7c:	00181593          	slli	a1,a6,0x1
ffffffffc0200c80:	00001797          	auipc	a5,0x1
ffffffffc0200c84:	57878793          	addi	a5,a5,1400 # ffffffffc02021f8 <nbase>
ffffffffc0200c88:	0007bf03          	ld	t5,0(a5)
ffffffffc0200c8c:	01058eb3          	add	t4,a1,a6
    size |= size >> 16;
ffffffffc0200c90:	01065793          	srli	a5,a2,0x10
ffffffffc0200c94:	8e5d                	or	a2,a2,a5
    buddy->size = s;
ffffffffc0200c96:	00005517          	auipc	a0,0x5
ffffffffc0200c9a:	7a250513          	addi	a0,a0,1954 # ffffffffc0206438 <b>
ffffffffc0200c9e:	0e92                	slli	t4,t4,0x4
    buddy->longest = KADDR(page2pa(base));
ffffffffc0200ca0:	00005797          	auipc	a5,0x5
ffffffffc0200ca4:	77878793          	addi	a5,a5,1912 # ffffffffc0206418 <npage>
    buddy->size = s;
ffffffffc0200ca8:	9eaa                	add	t4,t4,a0
    buddy->curr_free = s - e;
ffffffffc0200caa:	8f11                	sub	a4,a4,a2
    buddy->longest = KADDR(page2pa(base));
ffffffffc0200cac:	0007bf83          	ld	t6,0(a5)
    buddy->curr_free = s - e;
ffffffffc0200cb0:	02eeb023          	sd	a4,32(t4)
    buddy->longest = KADDR(page2pa(base));
ffffffffc0200cb4:	577d                	li	a4,-1
ffffffffc0200cb6:	98fa                	add	a7,a7,t5
    struct buddy *buddy = &b[id_++];
ffffffffc0200cb8:	0018079b          	addiw	a5,a6,1
    buddy->longest = KADDR(page2pa(base));
ffffffffc0200cbc:	8331                	srli	a4,a4,0xc
ffffffffc0200cbe:	00e8f733          	and	a4,a7,a4
    struct buddy *buddy = &b[id_++];
ffffffffc0200cc2:	00005297          	auipc	t0,0x5
ffffffffc0200cc6:	74f2a923          	sw	a5,1874(t0) # ffffffffc0206414 <id_>
    buddy->size = s;
ffffffffc0200cca:	00deb023          	sd	a3,0(t4)
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cce:	08b2                	slli	a7,a7,0xc
    buddy->longest = KADDR(page2pa(base));
ffffffffc0200cd0:	19f77163          	bleu	t6,a4,ffffffffc0200e52 <buddy_init_memmap+0x25c>
ffffffffc0200cd4:	00006797          	auipc	a5,0x6
ffffffffc0200cd8:	95478793          	addi	a5,a5,-1708 # ffffffffc0206628 <va_pa_offset>
ffffffffc0200cdc:	0007b283          	ld	t0,0(a5)
    buddy->begin_page = pa2page(PADDR(ROUNDUP(buddy->longest + 2 * s * sizeof(uintptr_t), PGSIZE)));
ffffffffc0200ce0:	00769713          	slli	a4,a3,0x7
ffffffffc0200ce4:	6785                	lui	a5,0x1
    buddy->longest = KADDR(page2pa(base));
ffffffffc0200ce6:	9896                	add	a7,a7,t0
    buddy->begin_page = pa2page(PADDR(ROUNDUP(buddy->longest + 2 * s * sizeof(uintptr_t), PGSIZE)));
ffffffffc0200ce8:	17fd                	addi	a5,a5,-1
ffffffffc0200cea:	9746                	add	a4,a4,a7
ffffffffc0200cec:	973e                	add	a4,a4,a5
ffffffffc0200cee:	77fd                	lui	a5,0xfffff
ffffffffc0200cf0:	8ff9                	and	a5,a5,a4
    buddy->longest = KADDR(page2pa(base));
ffffffffc0200cf2:	011eb423          	sd	a7,8(t4)
    buddy->begin_page = pa2page(PADDR(ROUNDUP(buddy->longest + 2 * s * sizeof(uintptr_t), PGSIZE)));
ffffffffc0200cf6:	c0200737          	lui	a4,0xc0200
ffffffffc0200cfa:	12e7ef63          	bltu	a5,a4,ffffffffc0200e38 <buddy_init_memmap+0x242>
ffffffffc0200cfe:	405787b3          	sub	a5,a5,t0
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200d02:	83b1                	srli	a5,a5,0xc
ffffffffc0200d04:	11f7fe63          	bleu	t6,a5,ffffffffc0200e20 <buddy_init_memmap+0x22a>
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200d08:	41e787b3          	sub	a5,a5,t5
ffffffffc0200d0c:	00279713          	slli	a4,a5,0x2
ffffffffc0200d10:	97ba                	add	a5,a5,a4
ffffffffc0200d12:	078e                	slli	a5,a5,0x3
ffffffffc0200d14:	933e                	add	t1,t1,a5
    buddy->longest_num = buddy->begin_page - base;
ffffffffc0200d16:	408307b3          	sub	a5,t1,s0
ffffffffc0200d1a:	878d                	srai	a5,a5,0x3
ffffffffc0200d1c:	03c78e33          	mul	t3,a5,t3
ffffffffc0200d20:	0605                	addi	a2,a2,1
    buddy->begin_page = pa2page(PADDR(ROUNDUP(buddy->longest + 2 * s * sizeof(uintptr_t), PGSIZE)));
ffffffffc0200d22:	026eb423          	sd	t1,40(t4)
    size_t sn = buddy->size * 2;
ffffffffc0200d26:	0686                	slli	a3,a3,0x1
    for (int i = 0; i < 2 * buddy->size - 1; i++) {
ffffffffc0200d28:	4781                	li	a5,0
        buddy->longest[i] = sn;
ffffffffc0200d2a:	88f6                	mv	a7,t4
    buddy->total_num = n - buddy->longest_num;
ffffffffc0200d2c:	41c484b3          	sub	s1,s1,t3
    buddy->longest_num = buddy->begin_page - base;
ffffffffc0200d30:	01ceb823          	sd	t3,16(t4)
    buddy->total_num = n - buddy->longest_num;
ffffffffc0200d34:	009ebc23          	sd	s1,24(t4)
        if (IS_POWER_OF_2(i + 1)) {
ffffffffc0200d38:	0017871b          	addiw	a4,a5,1
ffffffffc0200d3c:	8f7d                	and	a4,a4,a5
ffffffffc0200d3e:	2701                	sext.w	a4,a4
ffffffffc0200d40:	e311                	bnez	a4,ffffffffc0200d44 <buddy_init_memmap+0x14e>
            sn /= 2;
ffffffffc0200d42:	8285                	srli	a3,a3,0x1
        buddy->longest[i] = sn;
ffffffffc0200d44:	0088b703          	ld	a4,8(a7)
ffffffffc0200d48:	00379313          	slli	t1,a5,0x3
ffffffffc0200d4c:	0785                	addi	a5,a5,1
ffffffffc0200d4e:	971a                	add	a4,a4,t1
ffffffffc0200d50:	e314                	sd	a3,0(a4)
    for (int i = 0; i < 2 * buddy->size - 1; i++) {
ffffffffc0200d52:	0008b703          	ld	a4,0(a7)
ffffffffc0200d56:	0706                	slli	a4,a4,0x1
ffffffffc0200d58:	177d                	addi	a4,a4,-1
ffffffffc0200d5a:	fce7efe3          	bltu	a5,a4,ffffffffc0200d38 <buddy_init_memmap+0x142>
        if (buddy->longest[id] == e) {
ffffffffc0200d5e:	0088b883          	ld	a7,8(a7)
    int id = 0;
ffffffffc0200d62:	4781                	li	a5,0
        if (buddy->longest[id] == e) {
ffffffffc0200d64:	0008b703          	ld	a4,0(a7)
ffffffffc0200d68:	08e60963          	beq	a2,a4,ffffffffc0200dfa <buddy_init_memmap+0x204>
        id = RIGHT_LEAF(id);
ffffffffc0200d6c:	2785                	addiw	a5,a5,1
ffffffffc0200d6e:	0017979b          	slliw	a5,a5,0x1
        if (buddy->longest[id] == e) {
ffffffffc0200d72:	00379713          	slli	a4,a5,0x3
ffffffffc0200d76:	9746                	add	a4,a4,a7
ffffffffc0200d78:	6314                	ld	a3,0(a4)
ffffffffc0200d7a:	fec699e3          	bne	a3,a2,ffffffffc0200d6c <buddy_init_memmap+0x176>
        buddy->longest[id] = MAX(buddy->longest[LEFT_LEAF(id)], buddy->longest[RIGHT_LEAF(id)]);
ffffffffc0200d7e:	01058333          	add	t1,a1,a6
ffffffffc0200d82:	0312                	slli	t1,t1,0x4
            buddy->longest[id] = 0;
ffffffffc0200d84:	00073023          	sd	zero,0(a4) # ffffffffc0200000 <kern_entry>
        buddy->longest[id] = MAX(buddy->longest[LEFT_LEAF(id)], buddy->longest[RIGHT_LEAF(id)]);
ffffffffc0200d88:	932a                	add	t1,t1,a0
        id = PARENT(id);
ffffffffc0200d8a:	2785                	addiw	a5,a5,1
ffffffffc0200d8c:	4017d79b          	sraiw	a5,a5,0x1
ffffffffc0200d90:	37fd                	addiw	a5,a5,-1
        buddy->longest[id] = MAX(buddy->longest[LEFT_LEAF(id)], buddy->longest[RIGHT_LEAF(id)]);
ffffffffc0200d92:	00833683          	ld	a3,8(t1)
ffffffffc0200d96:	0017971b          	slliw	a4,a5,0x1
ffffffffc0200d9a:	00270613          	addi	a2,a4,2
ffffffffc0200d9e:	0705                	addi	a4,a4,1
ffffffffc0200da0:	060e                	slli	a2,a2,0x3
ffffffffc0200da2:	070e                	slli	a4,a4,0x3
ffffffffc0200da4:	9636                	add	a2,a2,a3
ffffffffc0200da6:	9736                	add	a4,a4,a3
ffffffffc0200da8:	00073883          	ld	a7,0(a4)
ffffffffc0200dac:	6218                	ld	a4,0(a2)
ffffffffc0200dae:	00379613          	slli	a2,a5,0x3
ffffffffc0200db2:	96b2                	add	a3,a3,a2
ffffffffc0200db4:	01177363          	bleu	a7,a4,ffffffffc0200dba <buddy_init_memmap+0x1c4>
ffffffffc0200db8:	8746                	mv	a4,a7
ffffffffc0200dba:	e298                	sd	a4,0(a3)
    while (id) {
ffffffffc0200dbc:	f7f9                	bnez	a5,ffffffffc0200d8a <buddy_init_memmap+0x194>
    struct Page *p = buddy->begin_page;
ffffffffc0200dbe:	95c2                	add	a1,a1,a6
ffffffffc0200dc0:	0592                	slli	a1,a1,0x4
ffffffffc0200dc2:	95aa                	add	a1,a1,a0
    for (; p != base + buddy->curr_free; p ++) {
ffffffffc0200dc4:	7194                	ld	a3,32(a1)
    struct Page *p = buddy->begin_page;
ffffffffc0200dc6:	759c                	ld	a5,40(a1)
    for (; p != base + buddy->curr_free; p ++) {
ffffffffc0200dc8:	00269713          	slli	a4,a3,0x2
ffffffffc0200dcc:	9736                	add	a4,a4,a3
ffffffffc0200dce:	070e                	slli	a4,a4,0x3
ffffffffc0200dd0:	943a                	add	s0,s0,a4
ffffffffc0200dd2:	00878f63          	beq	a5,s0,ffffffffc0200df0 <buddy_init_memmap+0x1fa>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200dd6:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200dd8:	8b05                	andi	a4,a4,1
ffffffffc0200dda:	c31d                	beqz	a4,ffffffffc0200e00 <buddy_init_memmap+0x20a>
        p->flags = p->property = 0;
ffffffffc0200ddc:	0007a823          	sw	zero,16(a5) # fffffffffffff010 <end+0x3fdf89d8>
ffffffffc0200de0:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200de4:	0007a023          	sw	zero,0(a5)
    for (; p != base + buddy->curr_free; p ++) {
ffffffffc0200de8:	02878793          	addi	a5,a5,40
ffffffffc0200dec:	fe8795e3          	bne	a5,s0,ffffffffc0200dd6 <buddy_init_memmap+0x1e0>
}
ffffffffc0200df0:	60e2                	ld	ra,24(sp)
ffffffffc0200df2:	6442                	ld	s0,16(sp)
ffffffffc0200df4:	64a2                	ld	s1,8(sp)
ffffffffc0200df6:	6105                	addi	sp,sp,32
ffffffffc0200df8:	8082                	ret
            buddy->longest[id] = 0;
ffffffffc0200dfa:	0008b023          	sd	zero,0(a7)
    while (id) {
ffffffffc0200dfe:	b7c1                	j	ffffffffc0200dbe <buddy_init_memmap+0x1c8>
        assert(PageReserved(p));
ffffffffc0200e00:	00001697          	auipc	a3,0x1
ffffffffc0200e04:	06868693          	addi	a3,a3,104 # ffffffffc0201e68 <commands+0x7a0>
ffffffffc0200e08:	00001617          	auipc	a2,0x1
ffffffffc0200e0c:	fd060613          	addi	a2,a2,-48 # ffffffffc0201dd8 <commands+0x710>
ffffffffc0200e10:	04700593          	li	a1,71
ffffffffc0200e14:	00001517          	auipc	a0,0x1
ffffffffc0200e18:	fdc50513          	addi	a0,a0,-36 # ffffffffc0201df0 <commands+0x728>
ffffffffc0200e1c:	d90ff0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200e20:	00001617          	auipc	a2,0x1
ffffffffc0200e24:	01860613          	addi	a2,a2,24 # ffffffffc0201e38 <commands+0x770>
ffffffffc0200e28:	06b00593          	li	a1,107
ffffffffc0200e2c:	00001517          	auipc	a0,0x1
ffffffffc0200e30:	02c50513          	addi	a0,a0,44 # ffffffffc0201e58 <commands+0x790>
ffffffffc0200e34:	d78ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    buddy->begin_page = pa2page(PADDR(ROUNDUP(buddy->longest + 2 * s * sizeof(uintptr_t), PGSIZE)));
ffffffffc0200e38:	86be                	mv	a3,a5
ffffffffc0200e3a:	00001617          	auipc	a2,0x1
ffffffffc0200e3e:	fd660613          	addi	a2,a2,-42 # ffffffffc0201e10 <commands+0x748>
ffffffffc0200e42:	02a00593          	li	a1,42
ffffffffc0200e46:	00001517          	auipc	a0,0x1
ffffffffc0200e4a:	faa50513          	addi	a0,a0,-86 # ffffffffc0201df0 <commands+0x728>
ffffffffc0200e4e:	d5eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    buddy->longest = KADDR(page2pa(base));
ffffffffc0200e52:	86c6                	mv	a3,a7
ffffffffc0200e54:	00001617          	auipc	a2,0x1
ffffffffc0200e58:	ef460613          	addi	a2,a2,-268 # ffffffffc0201d48 <commands+0x680>
ffffffffc0200e5c:	02900593          	li	a1,41
ffffffffc0200e60:	00001517          	auipc	a0,0x1
ffffffffc0200e64:	f9050513          	addi	a0,a0,-112 # ffffffffc0201df0 <commands+0x728>
ffffffffc0200e68:	d44ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200e6c <pmm_init>:
static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instan

static void init_pmm_manager(void) {
    pmm_manager = &slub_pmm_manager;
ffffffffc0200e6c:	00001797          	auipc	a5,0x1
ffffffffc0200e70:	00c78793          	addi	a5,a5,12 # ffffffffc0201e78 <slub_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200e74:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200e76:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200e78:	00001517          	auipc	a0,0x1
ffffffffc0200e7c:	06850513          	addi	a0,a0,104 # ffffffffc0201ee0 <slub_pmm_manager+0x68>
void pmm_init(void) {
ffffffffc0200e80:	ec06                	sd	ra,24(sp)
    pmm_manager = &slub_pmm_manager;
ffffffffc0200e82:	00005717          	auipc	a4,0x5
ffffffffc0200e86:	78f73f23          	sd	a5,1950(a4) # ffffffffc0206620 <pmm_manager>
void pmm_init(void) {
ffffffffc0200e8a:	e822                	sd	s0,16(sp)
ffffffffc0200e8c:	e426                	sd	s1,8(sp)
    pmm_manager = &slub_pmm_manager;
ffffffffc0200e8e:	00005417          	auipc	s0,0x5
ffffffffc0200e92:	79240413          	addi	s0,s0,1938 # ffffffffc0206620 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200e96:	a20ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc0200e9a:	601c                	ld	a5,0(s0)
ffffffffc0200e9c:	679c                	ld	a5,8(a5)
ffffffffc0200e9e:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200ea0:	57f5                	li	a5,-3
ffffffffc0200ea2:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200ea4:	00001517          	auipc	a0,0x1
ffffffffc0200ea8:	05450513          	addi	a0,a0,84 # ffffffffc0201ef8 <slub_pmm_manager+0x80>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200eac:	00005717          	auipc	a4,0x5
ffffffffc0200eb0:	76f73e23          	sd	a5,1916(a4) # ffffffffc0206628 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0200eb4:	a02ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200eb8:	46c5                	li	a3,17
ffffffffc0200eba:	06ee                	slli	a3,a3,0x1b
ffffffffc0200ebc:	40100613          	li	a2,1025
ffffffffc0200ec0:	16fd                	addi	a3,a3,-1
ffffffffc0200ec2:	0656                	slli	a2,a2,0x15
ffffffffc0200ec4:	07e005b7          	lui	a1,0x7e00
ffffffffc0200ec8:	00001517          	auipc	a0,0x1
ffffffffc0200ecc:	04850513          	addi	a0,a0,72 # ffffffffc0201f10 <slub_pmm_manager+0x98>
ffffffffc0200ed0:	9e6ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200ed4:	777d                	lui	a4,0xfffff
ffffffffc0200ed6:	00006797          	auipc	a5,0x6
ffffffffc0200eda:	76178793          	addi	a5,a5,1889 # ffffffffc0207637 <end+0xfff>
ffffffffc0200ede:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200ee0:	00088737          	lui	a4,0x88
ffffffffc0200ee4:	00005697          	auipc	a3,0x5
ffffffffc0200ee8:	52e6ba23          	sd	a4,1332(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200eec:	4601                	li	a2,0
ffffffffc0200eee:	00005717          	auipc	a4,0x5
ffffffffc0200ef2:	74f73123          	sd	a5,1858(a4) # ffffffffc0206630 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200ef6:	4681                	li	a3,0
ffffffffc0200ef8:	00005897          	auipc	a7,0x5
ffffffffc0200efc:	52088893          	addi	a7,a7,1312 # ffffffffc0206418 <npage>
ffffffffc0200f00:	00005597          	auipc	a1,0x5
ffffffffc0200f04:	73058593          	addi	a1,a1,1840 # ffffffffc0206630 <pages>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200f08:	4805                	li	a6,1
ffffffffc0200f0a:	fff80537          	lui	a0,0xfff80
ffffffffc0200f0e:	a011                	j	ffffffffc0200f12 <pmm_init+0xa6>
ffffffffc0200f10:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc0200f12:	97b2                	add	a5,a5,a2
ffffffffc0200f14:	07a1                	addi	a5,a5,8
ffffffffc0200f16:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200f1a:	0008b703          	ld	a4,0(a7)
ffffffffc0200f1e:	0685                	addi	a3,a3,1
ffffffffc0200f20:	02860613          	addi	a2,a2,40
ffffffffc0200f24:	00a707b3          	add	a5,a4,a0
ffffffffc0200f28:	fef6e4e3          	bltu	a3,a5,ffffffffc0200f10 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200f2c:	6190                	ld	a2,0(a1)
ffffffffc0200f2e:	00271793          	slli	a5,a4,0x2
ffffffffc0200f32:	97ba                	add	a5,a5,a4
ffffffffc0200f34:	fec006b7          	lui	a3,0xfec00
ffffffffc0200f38:	078e                	slli	a5,a5,0x3
ffffffffc0200f3a:	96b2                	add	a3,a3,a2
ffffffffc0200f3c:	96be                	add	a3,a3,a5
ffffffffc0200f3e:	c02007b7          	lui	a5,0xc0200
ffffffffc0200f42:	08f6e863          	bltu	a3,a5,ffffffffc0200fd2 <pmm_init+0x166>
ffffffffc0200f46:	00005497          	auipc	s1,0x5
ffffffffc0200f4a:	6e248493          	addi	s1,s1,1762 # ffffffffc0206628 <va_pa_offset>
ffffffffc0200f4e:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc0200f50:	45c5                	li	a1,17
ffffffffc0200f52:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200f54:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc0200f56:	04b6e963          	bltu	a3,a1,ffffffffc0200fa8 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200f5a:	601c                	ld	a5,0(s0)
ffffffffc0200f5c:	7b9c                	ld	a5,48(a5)
ffffffffc0200f5e:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200f60:	00001517          	auipc	a0,0x1
ffffffffc0200f64:	ff050513          	addi	a0,a0,-16 # ffffffffc0201f50 <slub_pmm_manager+0xd8>
ffffffffc0200f68:	94eff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200f6c:	00004697          	auipc	a3,0x4
ffffffffc0200f70:	09468693          	addi	a3,a3,148 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200f74:	00005797          	auipc	a5,0x5
ffffffffc0200f78:	4ad7b623          	sd	a3,1196(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f7c:	c02007b7          	lui	a5,0xc0200
ffffffffc0200f80:	06f6e563          	bltu	a3,a5,ffffffffc0200fea <pmm_init+0x17e>
ffffffffc0200f84:	609c                	ld	a5,0(s1)
}
ffffffffc0200f86:	6442                	ld	s0,16(sp)
ffffffffc0200f88:	60e2                	ld	ra,24(sp)
ffffffffc0200f8a:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200f8c:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f8e:	8e9d                	sub	a3,a3,a5
ffffffffc0200f90:	00005797          	auipc	a5,0x5
ffffffffc0200f94:	68d7b423          	sd	a3,1672(a5) # ffffffffc0206618 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200f98:	00001517          	auipc	a0,0x1
ffffffffc0200f9c:	fd850513          	addi	a0,a0,-40 # ffffffffc0201f70 <slub_pmm_manager+0xf8>
ffffffffc0200fa0:	8636                	mv	a2,a3
}
ffffffffc0200fa2:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200fa4:	912ff06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200fa8:	6785                	lui	a5,0x1
ffffffffc0200faa:	17fd                	addi	a5,a5,-1
ffffffffc0200fac:	96be                	add	a3,a3,a5
ffffffffc0200fae:	77fd                	lui	a5,0xfffff
ffffffffc0200fb0:	8efd                	and	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0200fb2:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200fb6:	04e7f663          	bleu	a4,a5,ffffffffc0201002 <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc0200fba:	6018                	ld	a4,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc0200fbc:	97aa                	add	a5,a5,a0
ffffffffc0200fbe:	00279513          	slli	a0,a5,0x2
ffffffffc0200fc2:	953e                	add	a0,a0,a5
ffffffffc0200fc4:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200fc6:	8d95                	sub	a1,a1,a3
ffffffffc0200fc8:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200fca:	81b1                	srli	a1,a1,0xc
ffffffffc0200fcc:	9532                	add	a0,a0,a2
ffffffffc0200fce:	9782                	jalr	a5
ffffffffc0200fd0:	b769                	j	ffffffffc0200f5a <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200fd2:	00001617          	auipc	a2,0x1
ffffffffc0200fd6:	e3e60613          	addi	a2,a2,-450 # ffffffffc0201e10 <commands+0x748>
ffffffffc0200fda:	07100593          	li	a1,113
ffffffffc0200fde:	00001517          	auipc	a0,0x1
ffffffffc0200fe2:	f6250513          	addi	a0,a0,-158 # ffffffffc0201f40 <slub_pmm_manager+0xc8>
ffffffffc0200fe6:	bc6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200fea:	00001617          	auipc	a2,0x1
ffffffffc0200fee:	e2660613          	addi	a2,a2,-474 # ffffffffc0201e10 <commands+0x748>
ffffffffc0200ff2:	08c00593          	li	a1,140
ffffffffc0200ff6:	00001517          	auipc	a0,0x1
ffffffffc0200ffa:	f4a50513          	addi	a0,a0,-182 # ffffffffc0201f40 <slub_pmm_manager+0xc8>
ffffffffc0200ffe:	baeff0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201002:	00001617          	auipc	a2,0x1
ffffffffc0201006:	e3660613          	addi	a2,a2,-458 # ffffffffc0201e38 <commands+0x770>
ffffffffc020100a:	06b00593          	li	a1,107
ffffffffc020100e:	00001517          	auipc	a0,0x1
ffffffffc0201012:	e4a50513          	addi	a0,a0,-438 # ffffffffc0201e58 <commands+0x790>
ffffffffc0201016:	b96ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020101a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020101a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020101e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201020:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201024:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201026:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020102a:	f022                	sd	s0,32(sp)
ffffffffc020102c:	ec26                	sd	s1,24(sp)
ffffffffc020102e:	e84a                	sd	s2,16(sp)
ffffffffc0201030:	f406                	sd	ra,40(sp)
ffffffffc0201032:	e44e                	sd	s3,8(sp)
ffffffffc0201034:	84aa                	mv	s1,a0
ffffffffc0201036:	892e                	mv	s2,a1
ffffffffc0201038:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020103c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc020103e:	03067e63          	bleu	a6,a2,ffffffffc020107a <printnum+0x60>
ffffffffc0201042:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201044:	00805763          	blez	s0,ffffffffc0201052 <printnum+0x38>
ffffffffc0201048:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020104a:	85ca                	mv	a1,s2
ffffffffc020104c:	854e                	mv	a0,s3
ffffffffc020104e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201050:	fc65                	bnez	s0,ffffffffc0201048 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201052:	1a02                	slli	s4,s4,0x20
ffffffffc0201054:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201058:	00001797          	auipc	a5,0x1
ffffffffc020105c:	0e878793          	addi	a5,a5,232 # ffffffffc0202140 <error_string+0x38>
ffffffffc0201060:	9a3e                	add	s4,s4,a5
}
ffffffffc0201062:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201064:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201068:	70a2                	ld	ra,40(sp)
ffffffffc020106a:	69a2                	ld	s3,8(sp)
ffffffffc020106c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020106e:	85ca                	mv	a1,s2
ffffffffc0201070:	8326                	mv	t1,s1
}
ffffffffc0201072:	6942                	ld	s2,16(sp)
ffffffffc0201074:	64e2                	ld	s1,24(sp)
ffffffffc0201076:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201078:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020107a:	03065633          	divu	a2,a2,a6
ffffffffc020107e:	8722                	mv	a4,s0
ffffffffc0201080:	f9bff0ef          	jal	ra,ffffffffc020101a <printnum>
ffffffffc0201084:	b7f9                	j	ffffffffc0201052 <printnum+0x38>

ffffffffc0201086 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201086:	7119                	addi	sp,sp,-128
ffffffffc0201088:	f4a6                	sd	s1,104(sp)
ffffffffc020108a:	f0ca                	sd	s2,96(sp)
ffffffffc020108c:	e8d2                	sd	s4,80(sp)
ffffffffc020108e:	e4d6                	sd	s5,72(sp)
ffffffffc0201090:	e0da                	sd	s6,64(sp)
ffffffffc0201092:	fc5e                	sd	s7,56(sp)
ffffffffc0201094:	f862                	sd	s8,48(sp)
ffffffffc0201096:	f06a                	sd	s10,32(sp)
ffffffffc0201098:	fc86                	sd	ra,120(sp)
ffffffffc020109a:	f8a2                	sd	s0,112(sp)
ffffffffc020109c:	ecce                	sd	s3,88(sp)
ffffffffc020109e:	f466                	sd	s9,40(sp)
ffffffffc02010a0:	ec6e                	sd	s11,24(sp)
ffffffffc02010a2:	892a                	mv	s2,a0
ffffffffc02010a4:	84ae                	mv	s1,a1
ffffffffc02010a6:	8d32                	mv	s10,a2
ffffffffc02010a8:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02010aa:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010ac:	00001a17          	auipc	s4,0x1
ffffffffc02010b0:	f04a0a13          	addi	s4,s4,-252 # ffffffffc0201fb0 <slub_pmm_manager+0x138>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02010b4:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02010b8:	00001c17          	auipc	s8,0x1
ffffffffc02010bc:	050c0c13          	addi	s8,s8,80 # ffffffffc0202108 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010c0:	000d4503          	lbu	a0,0(s10)
ffffffffc02010c4:	02500793          	li	a5,37
ffffffffc02010c8:	001d0413          	addi	s0,s10,1
ffffffffc02010cc:	00f50e63          	beq	a0,a5,ffffffffc02010e8 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02010d0:	c521                	beqz	a0,ffffffffc0201118 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010d2:	02500993          	li	s3,37
ffffffffc02010d6:	a011                	j	ffffffffc02010da <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02010d8:	c121                	beqz	a0,ffffffffc0201118 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02010da:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010dc:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02010de:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010e0:	fff44503          	lbu	a0,-1(s0)
ffffffffc02010e4:	ff351ae3          	bne	a0,s3,ffffffffc02010d8 <vprintfmt+0x52>
ffffffffc02010e8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02010ec:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02010f0:	4981                	li	s3,0
ffffffffc02010f2:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02010f4:	5cfd                	li	s9,-1
ffffffffc02010f6:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010f8:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02010fc:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010fe:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0201102:	0ff6f693          	andi	a3,a3,255
ffffffffc0201106:	00140d13          	addi	s10,s0,1
ffffffffc020110a:	20d5e563          	bltu	a1,a3,ffffffffc0201314 <vprintfmt+0x28e>
ffffffffc020110e:	068a                	slli	a3,a3,0x2
ffffffffc0201110:	96d2                	add	a3,a3,s4
ffffffffc0201112:	4294                	lw	a3,0(a3)
ffffffffc0201114:	96d2                	add	a3,a3,s4
ffffffffc0201116:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201118:	70e6                	ld	ra,120(sp)
ffffffffc020111a:	7446                	ld	s0,112(sp)
ffffffffc020111c:	74a6                	ld	s1,104(sp)
ffffffffc020111e:	7906                	ld	s2,96(sp)
ffffffffc0201120:	69e6                	ld	s3,88(sp)
ffffffffc0201122:	6a46                	ld	s4,80(sp)
ffffffffc0201124:	6aa6                	ld	s5,72(sp)
ffffffffc0201126:	6b06                	ld	s6,64(sp)
ffffffffc0201128:	7be2                	ld	s7,56(sp)
ffffffffc020112a:	7c42                	ld	s8,48(sp)
ffffffffc020112c:	7ca2                	ld	s9,40(sp)
ffffffffc020112e:	7d02                	ld	s10,32(sp)
ffffffffc0201130:	6de2                	ld	s11,24(sp)
ffffffffc0201132:	6109                	addi	sp,sp,128
ffffffffc0201134:	8082                	ret
    if (lflag >= 2) {
ffffffffc0201136:	4705                	li	a4,1
ffffffffc0201138:	008a8593          	addi	a1,s5,8
ffffffffc020113c:	01074463          	blt	a4,a6,ffffffffc0201144 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0201140:	26080363          	beqz	a6,ffffffffc02013a6 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0201144:	000ab603          	ld	a2,0(s5)
ffffffffc0201148:	46c1                	li	a3,16
ffffffffc020114a:	8aae                	mv	s5,a1
ffffffffc020114c:	a06d                	j	ffffffffc02011f6 <vprintfmt+0x170>
            goto reswitch;
ffffffffc020114e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201152:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201154:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201156:	b765                	j	ffffffffc02010fe <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0201158:	000aa503          	lw	a0,0(s5)
ffffffffc020115c:	85a6                	mv	a1,s1
ffffffffc020115e:	0aa1                	addi	s5,s5,8
ffffffffc0201160:	9902                	jalr	s2
            break;
ffffffffc0201162:	bfb9                	j	ffffffffc02010c0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201164:	4705                	li	a4,1
ffffffffc0201166:	008a8993          	addi	s3,s5,8
ffffffffc020116a:	01074463          	blt	a4,a6,ffffffffc0201172 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc020116e:	22080463          	beqz	a6,ffffffffc0201396 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0201172:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0201176:	24044463          	bltz	s0,ffffffffc02013be <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc020117a:	8622                	mv	a2,s0
ffffffffc020117c:	8ace                	mv	s5,s3
ffffffffc020117e:	46a9                	li	a3,10
ffffffffc0201180:	a89d                	j	ffffffffc02011f6 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0201182:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201186:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201188:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc020118a:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020118e:	8fb5                	xor	a5,a5,a3
ffffffffc0201190:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201194:	1ad74363          	blt	a4,a3,ffffffffc020133a <vprintfmt+0x2b4>
ffffffffc0201198:	00369793          	slli	a5,a3,0x3
ffffffffc020119c:	97e2                	add	a5,a5,s8
ffffffffc020119e:	639c                	ld	a5,0(a5)
ffffffffc02011a0:	18078d63          	beqz	a5,ffffffffc020133a <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02011a4:	86be                	mv	a3,a5
ffffffffc02011a6:	00001617          	auipc	a2,0x1
ffffffffc02011aa:	04a60613          	addi	a2,a2,74 # ffffffffc02021f0 <error_string+0xe8>
ffffffffc02011ae:	85a6                	mv	a1,s1
ffffffffc02011b0:	854a                	mv	a0,s2
ffffffffc02011b2:	240000ef          	jal	ra,ffffffffc02013f2 <printfmt>
ffffffffc02011b6:	b729                	j	ffffffffc02010c0 <vprintfmt+0x3a>
            lflag ++;
ffffffffc02011b8:	00144603          	lbu	a2,1(s0)
ffffffffc02011bc:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011be:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02011c0:	bf3d                	j	ffffffffc02010fe <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02011c2:	4705                	li	a4,1
ffffffffc02011c4:	008a8593          	addi	a1,s5,8
ffffffffc02011c8:	01074463          	blt	a4,a6,ffffffffc02011d0 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02011cc:	1e080263          	beqz	a6,ffffffffc02013b0 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc02011d0:	000ab603          	ld	a2,0(s5)
ffffffffc02011d4:	46a1                	li	a3,8
ffffffffc02011d6:	8aae                	mv	s5,a1
ffffffffc02011d8:	a839                	j	ffffffffc02011f6 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc02011da:	03000513          	li	a0,48
ffffffffc02011de:	85a6                	mv	a1,s1
ffffffffc02011e0:	e03e                	sd	a5,0(sp)
ffffffffc02011e2:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02011e4:	85a6                	mv	a1,s1
ffffffffc02011e6:	07800513          	li	a0,120
ffffffffc02011ea:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02011ec:	0aa1                	addi	s5,s5,8
ffffffffc02011ee:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02011f2:	6782                	ld	a5,0(sp)
ffffffffc02011f4:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02011f6:	876e                	mv	a4,s11
ffffffffc02011f8:	85a6                	mv	a1,s1
ffffffffc02011fa:	854a                	mv	a0,s2
ffffffffc02011fc:	e1fff0ef          	jal	ra,ffffffffc020101a <printnum>
            break;
ffffffffc0201200:	b5c1                	j	ffffffffc02010c0 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201202:	000ab603          	ld	a2,0(s5)
ffffffffc0201206:	0aa1                	addi	s5,s5,8
ffffffffc0201208:	1c060663          	beqz	a2,ffffffffc02013d4 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc020120c:	00160413          	addi	s0,a2,1
ffffffffc0201210:	17b05c63          	blez	s11,ffffffffc0201388 <vprintfmt+0x302>
ffffffffc0201214:	02d00593          	li	a1,45
ffffffffc0201218:	14b79263          	bne	a5,a1,ffffffffc020135c <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020121c:	00064783          	lbu	a5,0(a2)
ffffffffc0201220:	0007851b          	sext.w	a0,a5
ffffffffc0201224:	c905                	beqz	a0,ffffffffc0201254 <vprintfmt+0x1ce>
ffffffffc0201226:	000cc563          	bltz	s9,ffffffffc0201230 <vprintfmt+0x1aa>
ffffffffc020122a:	3cfd                	addiw	s9,s9,-1
ffffffffc020122c:	036c8263          	beq	s9,s6,ffffffffc0201250 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0201230:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201232:	18098463          	beqz	s3,ffffffffc02013ba <vprintfmt+0x334>
ffffffffc0201236:	3781                	addiw	a5,a5,-32
ffffffffc0201238:	18fbf163          	bleu	a5,s7,ffffffffc02013ba <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc020123c:	03f00513          	li	a0,63
ffffffffc0201240:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201242:	0405                	addi	s0,s0,1
ffffffffc0201244:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201248:	3dfd                	addiw	s11,s11,-1
ffffffffc020124a:	0007851b          	sext.w	a0,a5
ffffffffc020124e:	fd61                	bnez	a0,ffffffffc0201226 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0201250:	e7b058e3          	blez	s11,ffffffffc02010c0 <vprintfmt+0x3a>
ffffffffc0201254:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201256:	85a6                	mv	a1,s1
ffffffffc0201258:	02000513          	li	a0,32
ffffffffc020125c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020125e:	e60d81e3          	beqz	s11,ffffffffc02010c0 <vprintfmt+0x3a>
ffffffffc0201262:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201264:	85a6                	mv	a1,s1
ffffffffc0201266:	02000513          	li	a0,32
ffffffffc020126a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020126c:	fe0d94e3          	bnez	s11,ffffffffc0201254 <vprintfmt+0x1ce>
ffffffffc0201270:	bd81                	j	ffffffffc02010c0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201272:	4705                	li	a4,1
ffffffffc0201274:	008a8593          	addi	a1,s5,8
ffffffffc0201278:	01074463          	blt	a4,a6,ffffffffc0201280 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc020127c:	12080063          	beqz	a6,ffffffffc020139c <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0201280:	000ab603          	ld	a2,0(s5)
ffffffffc0201284:	46a9                	li	a3,10
ffffffffc0201286:	8aae                	mv	s5,a1
ffffffffc0201288:	b7bd                	j	ffffffffc02011f6 <vprintfmt+0x170>
ffffffffc020128a:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc020128e:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201292:	846a                	mv	s0,s10
ffffffffc0201294:	b5ad                	j	ffffffffc02010fe <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0201296:	85a6                	mv	a1,s1
ffffffffc0201298:	02500513          	li	a0,37
ffffffffc020129c:	9902                	jalr	s2
            break;
ffffffffc020129e:	b50d                	j	ffffffffc02010c0 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02012a0:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02012a4:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02012a8:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012aa:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02012ac:	e40dd9e3          	bgez	s11,ffffffffc02010fe <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02012b0:	8de6                	mv	s11,s9
ffffffffc02012b2:	5cfd                	li	s9,-1
ffffffffc02012b4:	b5a9                	j	ffffffffc02010fe <vprintfmt+0x78>
            goto reswitch;
ffffffffc02012b6:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02012ba:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012be:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02012c0:	bd3d                	j	ffffffffc02010fe <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02012c2:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02012c6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012ca:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02012cc:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02012d0:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02012d4:	fcd56ce3          	bltu	a0,a3,ffffffffc02012ac <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc02012d8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02012da:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02012de:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02012e2:	0196873b          	addw	a4,a3,s9
ffffffffc02012e6:	0017171b          	slliw	a4,a4,0x1
ffffffffc02012ea:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02012ee:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02012f2:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02012f6:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02012fa:	fcd57fe3          	bleu	a3,a0,ffffffffc02012d8 <vprintfmt+0x252>
ffffffffc02012fe:	b77d                	j	ffffffffc02012ac <vprintfmt+0x226>
            if (width < 0)
ffffffffc0201300:	fffdc693          	not	a3,s11
ffffffffc0201304:	96fd                	srai	a3,a3,0x3f
ffffffffc0201306:	00ddfdb3          	and	s11,s11,a3
ffffffffc020130a:	00144603          	lbu	a2,1(s0)
ffffffffc020130e:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201310:	846a                	mv	s0,s10
ffffffffc0201312:	b3f5                	j	ffffffffc02010fe <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0201314:	85a6                	mv	a1,s1
ffffffffc0201316:	02500513          	li	a0,37
ffffffffc020131a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020131c:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201320:	02500793          	li	a5,37
ffffffffc0201324:	8d22                	mv	s10,s0
ffffffffc0201326:	d8f70de3          	beq	a4,a5,ffffffffc02010c0 <vprintfmt+0x3a>
ffffffffc020132a:	02500713          	li	a4,37
ffffffffc020132e:	1d7d                	addi	s10,s10,-1
ffffffffc0201330:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0201334:	fee79de3          	bne	a5,a4,ffffffffc020132e <vprintfmt+0x2a8>
ffffffffc0201338:	b361                	j	ffffffffc02010c0 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020133a:	00001617          	auipc	a2,0x1
ffffffffc020133e:	ea660613          	addi	a2,a2,-346 # ffffffffc02021e0 <error_string+0xd8>
ffffffffc0201342:	85a6                	mv	a1,s1
ffffffffc0201344:	854a                	mv	a0,s2
ffffffffc0201346:	0ac000ef          	jal	ra,ffffffffc02013f2 <printfmt>
ffffffffc020134a:	bb9d                	j	ffffffffc02010c0 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020134c:	00001617          	auipc	a2,0x1
ffffffffc0201350:	e8c60613          	addi	a2,a2,-372 # ffffffffc02021d8 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0201354:	00001417          	auipc	s0,0x1
ffffffffc0201358:	e8540413          	addi	s0,s0,-379 # ffffffffc02021d9 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020135c:	8532                	mv	a0,a2
ffffffffc020135e:	85e6                	mv	a1,s9
ffffffffc0201360:	e032                	sd	a2,0(sp)
ffffffffc0201362:	e43e                	sd	a5,8(sp)
ffffffffc0201364:	1c2000ef          	jal	ra,ffffffffc0201526 <strnlen>
ffffffffc0201368:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020136c:	6602                	ld	a2,0(sp)
ffffffffc020136e:	01b05d63          	blez	s11,ffffffffc0201388 <vprintfmt+0x302>
ffffffffc0201372:	67a2                	ld	a5,8(sp)
ffffffffc0201374:	2781                	sext.w	a5,a5
ffffffffc0201376:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0201378:	6522                	ld	a0,8(sp)
ffffffffc020137a:	85a6                	mv	a1,s1
ffffffffc020137c:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020137e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201380:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201382:	6602                	ld	a2,0(sp)
ffffffffc0201384:	fe0d9ae3          	bnez	s11,ffffffffc0201378 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201388:	00064783          	lbu	a5,0(a2)
ffffffffc020138c:	0007851b          	sext.w	a0,a5
ffffffffc0201390:	e8051be3          	bnez	a0,ffffffffc0201226 <vprintfmt+0x1a0>
ffffffffc0201394:	b335                	j	ffffffffc02010c0 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0201396:	000aa403          	lw	s0,0(s5)
ffffffffc020139a:	bbf1                	j	ffffffffc0201176 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc020139c:	000ae603          	lwu	a2,0(s5)
ffffffffc02013a0:	46a9                	li	a3,10
ffffffffc02013a2:	8aae                	mv	s5,a1
ffffffffc02013a4:	bd89                	j	ffffffffc02011f6 <vprintfmt+0x170>
ffffffffc02013a6:	000ae603          	lwu	a2,0(s5)
ffffffffc02013aa:	46c1                	li	a3,16
ffffffffc02013ac:	8aae                	mv	s5,a1
ffffffffc02013ae:	b5a1                	j	ffffffffc02011f6 <vprintfmt+0x170>
ffffffffc02013b0:	000ae603          	lwu	a2,0(s5)
ffffffffc02013b4:	46a1                	li	a3,8
ffffffffc02013b6:	8aae                	mv	s5,a1
ffffffffc02013b8:	bd3d                	j	ffffffffc02011f6 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02013ba:	9902                	jalr	s2
ffffffffc02013bc:	b559                	j	ffffffffc0201242 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02013be:	85a6                	mv	a1,s1
ffffffffc02013c0:	02d00513          	li	a0,45
ffffffffc02013c4:	e03e                	sd	a5,0(sp)
ffffffffc02013c6:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02013c8:	8ace                	mv	s5,s3
ffffffffc02013ca:	40800633          	neg	a2,s0
ffffffffc02013ce:	46a9                	li	a3,10
ffffffffc02013d0:	6782                	ld	a5,0(sp)
ffffffffc02013d2:	b515                	j	ffffffffc02011f6 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02013d4:	01b05663          	blez	s11,ffffffffc02013e0 <vprintfmt+0x35a>
ffffffffc02013d8:	02d00693          	li	a3,45
ffffffffc02013dc:	f6d798e3          	bne	a5,a3,ffffffffc020134c <vprintfmt+0x2c6>
ffffffffc02013e0:	00001417          	auipc	s0,0x1
ffffffffc02013e4:	df940413          	addi	s0,s0,-519 # ffffffffc02021d9 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02013e8:	02800513          	li	a0,40
ffffffffc02013ec:	02800793          	li	a5,40
ffffffffc02013f0:	bd1d                	j	ffffffffc0201226 <vprintfmt+0x1a0>

ffffffffc02013f2 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02013f2:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02013f4:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02013f8:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02013fa:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02013fc:	ec06                	sd	ra,24(sp)
ffffffffc02013fe:	f83a                	sd	a4,48(sp)
ffffffffc0201400:	fc3e                	sd	a5,56(sp)
ffffffffc0201402:	e0c2                	sd	a6,64(sp)
ffffffffc0201404:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201406:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201408:	c7fff0ef          	jal	ra,ffffffffc0201086 <vprintfmt>
}
ffffffffc020140c:	60e2                	ld	ra,24(sp)
ffffffffc020140e:	6161                	addi	sp,sp,80
ffffffffc0201410:	8082                	ret

ffffffffc0201412 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201412:	715d                	addi	sp,sp,-80
ffffffffc0201414:	e486                	sd	ra,72(sp)
ffffffffc0201416:	e0a2                	sd	s0,64(sp)
ffffffffc0201418:	fc26                	sd	s1,56(sp)
ffffffffc020141a:	f84a                	sd	s2,48(sp)
ffffffffc020141c:	f44e                	sd	s3,40(sp)
ffffffffc020141e:	f052                	sd	s4,32(sp)
ffffffffc0201420:	ec56                	sd	s5,24(sp)
ffffffffc0201422:	e85a                	sd	s6,16(sp)
ffffffffc0201424:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201426:	c901                	beqz	a0,ffffffffc0201436 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201428:	85aa                	mv	a1,a0
ffffffffc020142a:	00001517          	auipc	a0,0x1
ffffffffc020142e:	dc650513          	addi	a0,a0,-570 # ffffffffc02021f0 <error_string+0xe8>
ffffffffc0201432:	c85fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201436:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201438:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020143a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020143c:	4aa9                	li	s5,10
ffffffffc020143e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201440:	00005b97          	auipc	s7,0x5
ffffffffc0201444:	bd0b8b93          	addi	s7,s7,-1072 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201448:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020144c:	ce3fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201450:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201452:	00054b63          	bltz	a0,ffffffffc0201468 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201456:	00a95b63          	ble	a0,s2,ffffffffc020146c <readline+0x5a>
ffffffffc020145a:	029a5463          	ble	s1,s4,ffffffffc0201482 <readline+0x70>
        c = getchar();
ffffffffc020145e:	cd1fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201462:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201464:	fe0559e3          	bgez	a0,ffffffffc0201456 <readline+0x44>
            return NULL;
ffffffffc0201468:	4501                	li	a0,0
ffffffffc020146a:	a099                	j	ffffffffc02014b0 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc020146c:	03341463          	bne	s0,s3,ffffffffc0201494 <readline+0x82>
ffffffffc0201470:	e8b9                	bnez	s1,ffffffffc02014c6 <readline+0xb4>
        c = getchar();
ffffffffc0201472:	cbdfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201476:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201478:	fe0548e3          	bltz	a0,ffffffffc0201468 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020147c:	fea958e3          	ble	a0,s2,ffffffffc020146c <readline+0x5a>
ffffffffc0201480:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201482:	8522                	mv	a0,s0
ffffffffc0201484:	c67fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc0201488:	009b87b3          	add	a5,s7,s1
ffffffffc020148c:	00878023          	sb	s0,0(a5)
ffffffffc0201490:	2485                	addiw	s1,s1,1
ffffffffc0201492:	bf6d                	j	ffffffffc020144c <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201494:	01540463          	beq	s0,s5,ffffffffc020149c <readline+0x8a>
ffffffffc0201498:	fb641ae3          	bne	s0,s6,ffffffffc020144c <readline+0x3a>
            cputchar(c);
ffffffffc020149c:	8522                	mv	a0,s0
ffffffffc020149e:	c4dfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc02014a2:	00005517          	auipc	a0,0x5
ffffffffc02014a6:	b6e50513          	addi	a0,a0,-1170 # ffffffffc0206010 <edata>
ffffffffc02014aa:	94aa                	add	s1,s1,a0
ffffffffc02014ac:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02014b0:	60a6                	ld	ra,72(sp)
ffffffffc02014b2:	6406                	ld	s0,64(sp)
ffffffffc02014b4:	74e2                	ld	s1,56(sp)
ffffffffc02014b6:	7942                	ld	s2,48(sp)
ffffffffc02014b8:	79a2                	ld	s3,40(sp)
ffffffffc02014ba:	7a02                	ld	s4,32(sp)
ffffffffc02014bc:	6ae2                	ld	s5,24(sp)
ffffffffc02014be:	6b42                	ld	s6,16(sp)
ffffffffc02014c0:	6ba2                	ld	s7,8(sp)
ffffffffc02014c2:	6161                	addi	sp,sp,80
ffffffffc02014c4:	8082                	ret
            cputchar(c);
ffffffffc02014c6:	4521                	li	a0,8
ffffffffc02014c8:	c23fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc02014cc:	34fd                	addiw	s1,s1,-1
ffffffffc02014ce:	bfbd                	j	ffffffffc020144c <readline+0x3a>

ffffffffc02014d0 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc02014d0:	00005797          	auipc	a5,0x5
ffffffffc02014d4:	b3878793          	addi	a5,a5,-1224 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc02014d8:	6398                	ld	a4,0(a5)
ffffffffc02014da:	4781                	li	a5,0
ffffffffc02014dc:	88ba                	mv	a7,a4
ffffffffc02014de:	852a                	mv	a0,a0
ffffffffc02014e0:	85be                	mv	a1,a5
ffffffffc02014e2:	863e                	mv	a2,a5
ffffffffc02014e4:	00000073          	ecall
ffffffffc02014e8:	87aa                	mv	a5,a0
}
ffffffffc02014ea:	8082                	ret

ffffffffc02014ec <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc02014ec:	00005797          	auipc	a5,0x5
ffffffffc02014f0:	f3c78793          	addi	a5,a5,-196 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc02014f4:	6398                	ld	a4,0(a5)
ffffffffc02014f6:	4781                	li	a5,0
ffffffffc02014f8:	88ba                	mv	a7,a4
ffffffffc02014fa:	852a                	mv	a0,a0
ffffffffc02014fc:	85be                	mv	a1,a5
ffffffffc02014fe:	863e                	mv	a2,a5
ffffffffc0201500:	00000073          	ecall
ffffffffc0201504:	87aa                	mv	a5,a0
}
ffffffffc0201506:	8082                	ret

ffffffffc0201508 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201508:	00005797          	auipc	a5,0x5
ffffffffc020150c:	af878793          	addi	a5,a5,-1288 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201510:	639c                	ld	a5,0(a5)
ffffffffc0201512:	4501                	li	a0,0
ffffffffc0201514:	88be                	mv	a7,a5
ffffffffc0201516:	852a                	mv	a0,a0
ffffffffc0201518:	85aa                	mv	a1,a0
ffffffffc020151a:	862a                	mv	a2,a0
ffffffffc020151c:	00000073          	ecall
ffffffffc0201520:	852a                	mv	a0,a0
ffffffffc0201522:	2501                	sext.w	a0,a0
ffffffffc0201524:	8082                	ret

ffffffffc0201526 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201526:	c185                	beqz	a1,ffffffffc0201546 <strnlen+0x20>
ffffffffc0201528:	00054783          	lbu	a5,0(a0)
ffffffffc020152c:	cf89                	beqz	a5,ffffffffc0201546 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc020152e:	4781                	li	a5,0
ffffffffc0201530:	a021                	j	ffffffffc0201538 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201532:	00074703          	lbu	a4,0(a4)
ffffffffc0201536:	c711                	beqz	a4,ffffffffc0201542 <strnlen+0x1c>
        cnt ++;
ffffffffc0201538:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020153a:	00f50733          	add	a4,a0,a5
ffffffffc020153e:	fef59ae3          	bne	a1,a5,ffffffffc0201532 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201542:	853e                	mv	a0,a5
ffffffffc0201544:	8082                	ret
    size_t cnt = 0;
ffffffffc0201546:	4781                	li	a5,0
}
ffffffffc0201548:	853e                	mv	a0,a5
ffffffffc020154a:	8082                	ret

ffffffffc020154c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020154c:	00054783          	lbu	a5,0(a0)
ffffffffc0201550:	0005c703          	lbu	a4,0(a1)
ffffffffc0201554:	cb91                	beqz	a5,ffffffffc0201568 <strcmp+0x1c>
ffffffffc0201556:	00e79c63          	bne	a5,a4,ffffffffc020156e <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc020155a:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020155c:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201560:	0585                	addi	a1,a1,1
ffffffffc0201562:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201566:	fbe5                	bnez	a5,ffffffffc0201556 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201568:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020156a:	9d19                	subw	a0,a0,a4
ffffffffc020156c:	8082                	ret
ffffffffc020156e:	0007851b          	sext.w	a0,a5
ffffffffc0201572:	9d19                	subw	a0,a0,a4
ffffffffc0201574:	8082                	ret

ffffffffc0201576 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201576:	00054783          	lbu	a5,0(a0)
ffffffffc020157a:	cb91                	beqz	a5,ffffffffc020158e <strchr+0x18>
        if (*s == c) {
ffffffffc020157c:	00b79563          	bne	a5,a1,ffffffffc0201586 <strchr+0x10>
ffffffffc0201580:	a809                	j	ffffffffc0201592 <strchr+0x1c>
ffffffffc0201582:	00b78763          	beq	a5,a1,ffffffffc0201590 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201586:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201588:	00054783          	lbu	a5,0(a0)
ffffffffc020158c:	fbfd                	bnez	a5,ffffffffc0201582 <strchr+0xc>
    }
    return NULL;
ffffffffc020158e:	4501                	li	a0,0
}
ffffffffc0201590:	8082                	ret
ffffffffc0201592:	8082                	ret

ffffffffc0201594 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201594:	ca01                	beqz	a2,ffffffffc02015a4 <memset+0x10>
ffffffffc0201596:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201598:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020159a:	0785                	addi	a5,a5,1
ffffffffc020159c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02015a0:	fec79de3          	bne	a5,a2,ffffffffc020159a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02015a4:	8082                	ret
