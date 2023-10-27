
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
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
ffffffffc0200028:	c0209137          	lui	sp,0xc0209

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
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	02250513          	addi	a0,a0,34 # ffffffffc020a058 <edata>
ffffffffc020003e:	00015617          	auipc	a2,0x15
ffffffffc0200042:	5b260613          	addi	a2,a2,1458 # ffffffffc02155f0 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	08d040ef          	jal	ra,ffffffffc02048da <memset>

    cons_init();                // init the console
ffffffffc0200052:	4b4000ef          	jal	ra,ffffffffc0200506 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00005597          	auipc	a1,0x5
ffffffffc020005a:	8e258593          	addi	a1,a1,-1822 # ffffffffc0204938 <etext+0x4>
ffffffffc020005e:	00005517          	auipc	a0,0x5
ffffffffc0200062:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0204958 <etext+0x24>
ffffffffc0200066:	128000ef          	jal	ra,ffffffffc020018e <cprintf>

    print_kerninfo();
ffffffffc020006a:	16c000ef          	jal	ra,ffffffffc02001d6 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	779010ef          	jal	ra,ffffffffc0201fe6 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	548000ef          	jal	ra,ffffffffc02005ba <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5b8000ef          	jal	ra,ffffffffc020062e <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	0f7030ef          	jal	ra,ffffffffc0203970 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	100040ef          	jal	ra,ffffffffc020417e <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	4f8000ef          	jal	ra,ffffffffc020057a <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	283020ef          	jal	ra,ffffffffc0202b08 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	426000ef          	jal	ra,ffffffffc02004b0 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	520000ef          	jal	ra,ffffffffc02005ae <intr_enable>

    cpu_idle();                 // run idle process
ffffffffc0200092:	2e4040ef          	jal	ra,ffffffffc0204376 <cpu_idle>

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
ffffffffc02000ae:	00005517          	auipc	a0,0x5
ffffffffc02000b2:	8b250513          	addi	a0,a0,-1870 # ffffffffc0204960 <etext+0x2c>
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
ffffffffc02000c4:	0000ab97          	auipc	s7,0xa
ffffffffc02000c8:	f94b8b93          	addi	s7,s7,-108 # ffffffffc020a058 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000cc:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000d0:	0f6000ef          	jal	ra,ffffffffc02001c6 <getchar>
ffffffffc02000d4:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000d6:	00054b63          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000da:	00a95b63          	ble	a0,s2,ffffffffc02000f0 <readline+0x5a>
ffffffffc02000de:	029a5463          	ble	s1,s4,ffffffffc0200106 <readline+0x70>
        c = getchar();
ffffffffc02000e2:	0e4000ef          	jal	ra,ffffffffc02001c6 <getchar>
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
ffffffffc02000f6:	0d0000ef          	jal	ra,ffffffffc02001c6 <getchar>
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
ffffffffc0200126:	0000a517          	auipc	a0,0xa
ffffffffc020012a:	f3250513          	addi	a0,a0,-206 # ffffffffc020a058 <edata>
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
ffffffffc020015c:	3ac000ef          	jal	ra,ffffffffc0200508 <cons_putc>
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
ffffffffc0200182:	32e040ef          	jal	ra,ffffffffc02044b0 <vprintfmt>
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
ffffffffc0200190:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
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
ffffffffc02001b6:	2fa040ef          	jal	ra,ffffffffc02044b0 <vprintfmt>
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
ffffffffc02001c2:	3460006f          	j	ffffffffc0200508 <cons_putc>

ffffffffc02001c6 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02001c6:	1141                	addi	sp,sp,-16
ffffffffc02001c8:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001ca:	374000ef          	jal	ra,ffffffffc020053e <cons_getc>
ffffffffc02001ce:	dd75                	beqz	a0,ffffffffc02001ca <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02001d0:	60a2                	ld	ra,8(sp)
ffffffffc02001d2:	0141                	addi	sp,sp,16
ffffffffc02001d4:	8082                	ret

ffffffffc02001d6 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02001d6:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001d8:	00004517          	auipc	a0,0x4
ffffffffc02001dc:	7c050513          	addi	a0,a0,1984 # ffffffffc0204998 <etext+0x64>
void print_kerninfo(void) {
ffffffffc02001e0:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001e2:	fadff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02001e6:	00000597          	auipc	a1,0x0
ffffffffc02001ea:	e5058593          	addi	a1,a1,-432 # ffffffffc0200036 <kern_init>
ffffffffc02001ee:	00004517          	auipc	a0,0x4
ffffffffc02001f2:	7ca50513          	addi	a0,a0,1994 # ffffffffc02049b8 <etext+0x84>
ffffffffc02001f6:	f99ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02001fa:	00004597          	auipc	a1,0x4
ffffffffc02001fe:	73a58593          	addi	a1,a1,1850 # ffffffffc0204934 <etext>
ffffffffc0200202:	00004517          	auipc	a0,0x4
ffffffffc0200206:	7d650513          	addi	a0,a0,2006 # ffffffffc02049d8 <etext+0xa4>
ffffffffc020020a:	f85ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020020e:	0000a597          	auipc	a1,0xa
ffffffffc0200212:	e4a58593          	addi	a1,a1,-438 # ffffffffc020a058 <edata>
ffffffffc0200216:	00004517          	auipc	a0,0x4
ffffffffc020021a:	7e250513          	addi	a0,a0,2018 # ffffffffc02049f8 <etext+0xc4>
ffffffffc020021e:	f71ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200222:	00015597          	auipc	a1,0x15
ffffffffc0200226:	3ce58593          	addi	a1,a1,974 # ffffffffc02155f0 <end>
ffffffffc020022a:	00004517          	auipc	a0,0x4
ffffffffc020022e:	7ee50513          	addi	a0,a0,2030 # ffffffffc0204a18 <etext+0xe4>
ffffffffc0200232:	f5dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200236:	00015597          	auipc	a1,0x15
ffffffffc020023a:	7b958593          	addi	a1,a1,1977 # ffffffffc02159ef <end+0x3ff>
ffffffffc020023e:	00000797          	auipc	a5,0x0
ffffffffc0200242:	df878793          	addi	a5,a5,-520 # ffffffffc0200036 <kern_init>
ffffffffc0200246:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020024a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020024e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200250:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200254:	95be                	add	a1,a1,a5
ffffffffc0200256:	85a9                	srai	a1,a1,0xa
ffffffffc0200258:	00004517          	auipc	a0,0x4
ffffffffc020025c:	7e050513          	addi	a0,a0,2016 # ffffffffc0204a38 <etext+0x104>
}
ffffffffc0200260:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200262:	f2dff06f          	j	ffffffffc020018e <cprintf>

ffffffffc0200266 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200266:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200268:	00004617          	auipc	a2,0x4
ffffffffc020026c:	70060613          	addi	a2,a2,1792 # ffffffffc0204968 <etext+0x34>
ffffffffc0200270:	04d00593          	li	a1,77
ffffffffc0200274:	00004517          	auipc	a0,0x4
ffffffffc0200278:	70c50513          	addi	a0,a0,1804 # ffffffffc0204980 <etext+0x4c>
void print_stackframe(void) {
ffffffffc020027c:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020027e:	1d2000ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0200282 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200282:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200284:	00005617          	auipc	a2,0x5
ffffffffc0200288:	8c460613          	addi	a2,a2,-1852 # ffffffffc0204b48 <commands+0xe0>
ffffffffc020028c:	00005597          	auipc	a1,0x5
ffffffffc0200290:	8dc58593          	addi	a1,a1,-1828 # ffffffffc0204b68 <commands+0x100>
ffffffffc0200294:	00005517          	auipc	a0,0x5
ffffffffc0200298:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0204b70 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020029c:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020029e:	ef1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002a2:	00005617          	auipc	a2,0x5
ffffffffc02002a6:	8de60613          	addi	a2,a2,-1826 # ffffffffc0204b80 <commands+0x118>
ffffffffc02002aa:	00005597          	auipc	a1,0x5
ffffffffc02002ae:	8fe58593          	addi	a1,a1,-1794 # ffffffffc0204ba8 <commands+0x140>
ffffffffc02002b2:	00005517          	auipc	a0,0x5
ffffffffc02002b6:	8be50513          	addi	a0,a0,-1858 # ffffffffc0204b70 <commands+0x108>
ffffffffc02002ba:	ed5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002be:	00005617          	auipc	a2,0x5
ffffffffc02002c2:	8fa60613          	addi	a2,a2,-1798 # ffffffffc0204bb8 <commands+0x150>
ffffffffc02002c6:	00005597          	auipc	a1,0x5
ffffffffc02002ca:	91258593          	addi	a1,a1,-1774 # ffffffffc0204bd8 <commands+0x170>
ffffffffc02002ce:	00005517          	auipc	a0,0x5
ffffffffc02002d2:	8a250513          	addi	a0,a0,-1886 # ffffffffc0204b70 <commands+0x108>
ffffffffc02002d6:	eb9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    }
    return 0;
}
ffffffffc02002da:	60a2                	ld	ra,8(sp)
ffffffffc02002dc:	4501                	li	a0,0
ffffffffc02002de:	0141                	addi	sp,sp,16
ffffffffc02002e0:	8082                	ret

ffffffffc02002e2 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e2:	1141                	addi	sp,sp,-16
ffffffffc02002e4:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002e6:	ef1ff0ef          	jal	ra,ffffffffc02001d6 <print_kerninfo>
    return 0;
}
ffffffffc02002ea:	60a2                	ld	ra,8(sp)
ffffffffc02002ec:	4501                	li	a0,0
ffffffffc02002ee:	0141                	addi	sp,sp,16
ffffffffc02002f0:	8082                	ret

ffffffffc02002f2 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002f2:	1141                	addi	sp,sp,-16
ffffffffc02002f4:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002f6:	f71ff0ef          	jal	ra,ffffffffc0200266 <print_stackframe>
    return 0;
}
ffffffffc02002fa:	60a2                	ld	ra,8(sp)
ffffffffc02002fc:	4501                	li	a0,0
ffffffffc02002fe:	0141                	addi	sp,sp,16
ffffffffc0200300:	8082                	ret

ffffffffc0200302 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200302:	7115                	addi	sp,sp,-224
ffffffffc0200304:	e962                	sd	s8,144(sp)
ffffffffc0200306:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200308:	00004517          	auipc	a0,0x4
ffffffffc020030c:	7a850513          	addi	a0,a0,1960 # ffffffffc0204ab0 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200310:	ed86                	sd	ra,216(sp)
ffffffffc0200312:	e9a2                	sd	s0,208(sp)
ffffffffc0200314:	e5a6                	sd	s1,200(sp)
ffffffffc0200316:	e1ca                	sd	s2,192(sp)
ffffffffc0200318:	fd4e                	sd	s3,184(sp)
ffffffffc020031a:	f952                	sd	s4,176(sp)
ffffffffc020031c:	f556                	sd	s5,168(sp)
ffffffffc020031e:	f15a                	sd	s6,160(sp)
ffffffffc0200320:	ed5e                	sd	s7,152(sp)
ffffffffc0200322:	e566                	sd	s9,136(sp)
ffffffffc0200324:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200326:	e69ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020032a:	00004517          	auipc	a0,0x4
ffffffffc020032e:	7ae50513          	addi	a0,a0,1966 # ffffffffc0204ad8 <commands+0x70>
ffffffffc0200332:	e5dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    if (tf != NULL) {
ffffffffc0200336:	000c0563          	beqz	s8,ffffffffc0200340 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020033a:	8562                	mv	a0,s8
ffffffffc020033c:	4da000ef          	jal	ra,ffffffffc0200816 <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200340:	4501                	li	a0,0
ffffffffc0200342:	4581                	li	a1,0
ffffffffc0200344:	4601                	li	a2,0
ffffffffc0200346:	48a1                	li	a7,8
ffffffffc0200348:	00000073          	ecall
ffffffffc020034c:	00004c97          	auipc	s9,0x4
ffffffffc0200350:	71cc8c93          	addi	s9,s9,1820 # ffffffffc0204a68 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200354:	00004997          	auipc	s3,0x4
ffffffffc0200358:	7ac98993          	addi	s3,s3,1964 # ffffffffc0204b00 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020035c:	00004917          	auipc	s2,0x4
ffffffffc0200360:	7ac90913          	addi	s2,s2,1964 # ffffffffc0204b08 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200364:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200366:	00004b17          	auipc	s6,0x4
ffffffffc020036a:	7aab0b13          	addi	s6,s6,1962 # ffffffffc0204b10 <commands+0xa8>
    if (argc == 0) {
ffffffffc020036e:	00004a97          	auipc	s5,0x4
ffffffffc0200372:	7faa8a93          	addi	s5,s5,2042 # ffffffffc0204b68 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200376:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200378:	854e                	mv	a0,s3
ffffffffc020037a:	d1dff0ef          	jal	ra,ffffffffc0200096 <readline>
ffffffffc020037e:	842a                	mv	s0,a0
ffffffffc0200380:	dd65                	beqz	a0,ffffffffc0200378 <kmonitor+0x76>
ffffffffc0200382:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200386:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200388:	c999                	beqz	a1,ffffffffc020039e <kmonitor+0x9c>
ffffffffc020038a:	854a                	mv	a0,s2
ffffffffc020038c:	530040ef          	jal	ra,ffffffffc02048bc <strchr>
ffffffffc0200390:	c925                	beqz	a0,ffffffffc0200400 <kmonitor+0xfe>
            *buf ++ = '\0';
ffffffffc0200392:	00144583          	lbu	a1,1(s0)
ffffffffc0200396:	00040023          	sb	zero,0(s0)
ffffffffc020039a:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020039c:	f5fd                	bnez	a1,ffffffffc020038a <kmonitor+0x88>
    if (argc == 0) {
ffffffffc020039e:	dce9                	beqz	s1,ffffffffc0200378 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003a0:	6582                	ld	a1,0(sp)
ffffffffc02003a2:	00004d17          	auipc	s10,0x4
ffffffffc02003a6:	6c6d0d13          	addi	s10,s10,1734 # ffffffffc0204a68 <commands>
    if (argc == 0) {
ffffffffc02003aa:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ac:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003ae:	0d61                	addi	s10,s10,24
ffffffffc02003b0:	4e2040ef          	jal	ra,ffffffffc0204892 <strcmp>
ffffffffc02003b4:	c919                	beqz	a0,ffffffffc02003ca <kmonitor+0xc8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003b6:	2405                	addiw	s0,s0,1
ffffffffc02003b8:	09740463          	beq	s0,s7,ffffffffc0200440 <kmonitor+0x13e>
ffffffffc02003bc:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003c0:	6582                	ld	a1,0(sp)
ffffffffc02003c2:	0d61                	addi	s10,s10,24
ffffffffc02003c4:	4ce040ef          	jal	ra,ffffffffc0204892 <strcmp>
ffffffffc02003c8:	f57d                	bnez	a0,ffffffffc02003b6 <kmonitor+0xb4>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003ca:	00141793          	slli	a5,s0,0x1
ffffffffc02003ce:	97a2                	add	a5,a5,s0
ffffffffc02003d0:	078e                	slli	a5,a5,0x3
ffffffffc02003d2:	97e6                	add	a5,a5,s9
ffffffffc02003d4:	6b9c                	ld	a5,16(a5)
ffffffffc02003d6:	8662                	mv	a2,s8
ffffffffc02003d8:	002c                	addi	a1,sp,8
ffffffffc02003da:	fff4851b          	addiw	a0,s1,-1
ffffffffc02003de:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003e0:	f8055ce3          	bgez	a0,ffffffffc0200378 <kmonitor+0x76>
}
ffffffffc02003e4:	60ee                	ld	ra,216(sp)
ffffffffc02003e6:	644e                	ld	s0,208(sp)
ffffffffc02003e8:	64ae                	ld	s1,200(sp)
ffffffffc02003ea:	690e                	ld	s2,192(sp)
ffffffffc02003ec:	79ea                	ld	s3,184(sp)
ffffffffc02003ee:	7a4a                	ld	s4,176(sp)
ffffffffc02003f0:	7aaa                	ld	s5,168(sp)
ffffffffc02003f2:	7b0a                	ld	s6,160(sp)
ffffffffc02003f4:	6bea                	ld	s7,152(sp)
ffffffffc02003f6:	6c4a                	ld	s8,144(sp)
ffffffffc02003f8:	6caa                	ld	s9,136(sp)
ffffffffc02003fa:	6d0a                	ld	s10,128(sp)
ffffffffc02003fc:	612d                	addi	sp,sp,224
ffffffffc02003fe:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200400:	00044783          	lbu	a5,0(s0)
ffffffffc0200404:	dfc9                	beqz	a5,ffffffffc020039e <kmonitor+0x9c>
        if (argc == MAXARGS - 1) {
ffffffffc0200406:	03448863          	beq	s1,s4,ffffffffc0200436 <kmonitor+0x134>
        argv[argc ++] = buf;
ffffffffc020040a:	00349793          	slli	a5,s1,0x3
ffffffffc020040e:	0118                	addi	a4,sp,128
ffffffffc0200410:	97ba                	add	a5,a5,a4
ffffffffc0200412:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200416:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020041a:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020041c:	e591                	bnez	a1,ffffffffc0200428 <kmonitor+0x126>
ffffffffc020041e:	b749                	j	ffffffffc02003a0 <kmonitor+0x9e>
            buf ++;
ffffffffc0200420:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200422:	00044583          	lbu	a1,0(s0)
ffffffffc0200426:	ddad                	beqz	a1,ffffffffc02003a0 <kmonitor+0x9e>
ffffffffc0200428:	854a                	mv	a0,s2
ffffffffc020042a:	492040ef          	jal	ra,ffffffffc02048bc <strchr>
ffffffffc020042e:	d96d                	beqz	a0,ffffffffc0200420 <kmonitor+0x11e>
ffffffffc0200430:	00044583          	lbu	a1,0(s0)
ffffffffc0200434:	bf91                	j	ffffffffc0200388 <kmonitor+0x86>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200436:	45c1                	li	a1,16
ffffffffc0200438:	855a                	mv	a0,s6
ffffffffc020043a:	d55ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc020043e:	b7f1                	j	ffffffffc020040a <kmonitor+0x108>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200440:	6582                	ld	a1,0(sp)
ffffffffc0200442:	00004517          	auipc	a0,0x4
ffffffffc0200446:	6ee50513          	addi	a0,a0,1774 # ffffffffc0204b30 <commands+0xc8>
ffffffffc020044a:	d45ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
ffffffffc020044e:	b72d                	j	ffffffffc0200378 <kmonitor+0x76>

ffffffffc0200450 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200450:	00015317          	auipc	t1,0x15
ffffffffc0200454:	01830313          	addi	t1,t1,24 # ffffffffc0215468 <is_panic>
ffffffffc0200458:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020045c:	715d                	addi	sp,sp,-80
ffffffffc020045e:	ec06                	sd	ra,24(sp)
ffffffffc0200460:	e822                	sd	s0,16(sp)
ffffffffc0200462:	f436                	sd	a3,40(sp)
ffffffffc0200464:	f83a                	sd	a4,48(sp)
ffffffffc0200466:	fc3e                	sd	a5,56(sp)
ffffffffc0200468:	e0c2                	sd	a6,64(sp)
ffffffffc020046a:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020046c:	02031c63          	bnez	t1,ffffffffc02004a4 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200470:	4785                	li	a5,1
ffffffffc0200472:	8432                	mv	s0,a2
ffffffffc0200474:	00015717          	auipc	a4,0x15
ffffffffc0200478:	fef72a23          	sw	a5,-12(a4) # ffffffffc0215468 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020047c:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc020047e:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200480:	85aa                	mv	a1,a0
ffffffffc0200482:	00004517          	auipc	a0,0x4
ffffffffc0200486:	76650513          	addi	a0,a0,1894 # ffffffffc0204be8 <commands+0x180>
    va_start(ap, fmt);
ffffffffc020048a:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020048c:	d03ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200490:	65a2                	ld	a1,8(sp)
ffffffffc0200492:	8522                	mv	a0,s0
ffffffffc0200494:	cdbff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc0200498:	00005517          	auipc	a0,0x5
ffffffffc020049c:	6d850513          	addi	a0,a0,1752 # ffffffffc0205b70 <default_pmm_manager+0x500>
ffffffffc02004a0:	cefff0ef          	jal	ra,ffffffffc020018e <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02004a4:	110000ef          	jal	ra,ffffffffc02005b4 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004a8:	4501                	li	a0,0
ffffffffc02004aa:	e59ff0ef          	jal	ra,ffffffffc0200302 <kmonitor>
ffffffffc02004ae:	bfed                	j	ffffffffc02004a8 <__panic+0x58>

ffffffffc02004b0 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004b0:	67e1                	lui	a5,0x18
ffffffffc02004b2:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc02004b6:	00015717          	auipc	a4,0x15
ffffffffc02004ba:	faf73d23          	sd	a5,-70(a4) # ffffffffc0215470 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004be:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02004c2:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004c4:	953e                	add	a0,a0,a5
ffffffffc02004c6:	4601                	li	a2,0
ffffffffc02004c8:	4881                	li	a7,0
ffffffffc02004ca:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02004ce:	02000793          	li	a5,32
ffffffffc02004d2:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02004d6:	00004517          	auipc	a0,0x4
ffffffffc02004da:	73250513          	addi	a0,a0,1842 # ffffffffc0204c08 <commands+0x1a0>
    ticks = 0;
ffffffffc02004de:	00015797          	auipc	a5,0x15
ffffffffc02004e2:	fe07b123          	sd	zero,-30(a5) # ffffffffc02154c0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02004e6:	ca9ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc02004ea <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004ea:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004ee:	00015797          	auipc	a5,0x15
ffffffffc02004f2:	f8278793          	addi	a5,a5,-126 # ffffffffc0215470 <timebase>
ffffffffc02004f6:	639c                	ld	a5,0(a5)
ffffffffc02004f8:	4581                	li	a1,0
ffffffffc02004fa:	4601                	li	a2,0
ffffffffc02004fc:	953e                	add	a0,a0,a5
ffffffffc02004fe:	4881                	li	a7,0
ffffffffc0200500:	00000073          	ecall
ffffffffc0200504:	8082                	ret

ffffffffc0200506 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200506:	8082                	ret

ffffffffc0200508 <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200508:	100027f3          	csrr	a5,sstatus
ffffffffc020050c:	8b89                	andi	a5,a5,2
ffffffffc020050e:	0ff57513          	andi	a0,a0,255
ffffffffc0200512:	e799                	bnez	a5,ffffffffc0200520 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200514:	4581                	li	a1,0
ffffffffc0200516:	4601                	li	a2,0
ffffffffc0200518:	4885                	li	a7,1
ffffffffc020051a:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020051e:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200520:	1101                	addi	sp,sp,-32
ffffffffc0200522:	ec06                	sd	ra,24(sp)
ffffffffc0200524:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200526:	08e000ef          	jal	ra,ffffffffc02005b4 <intr_disable>
ffffffffc020052a:	6522                	ld	a0,8(sp)
ffffffffc020052c:	4581                	li	a1,0
ffffffffc020052e:	4601                	li	a2,0
ffffffffc0200530:	4885                	li	a7,1
ffffffffc0200532:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200536:	60e2                	ld	ra,24(sp)
ffffffffc0200538:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020053a:	0740006f          	j	ffffffffc02005ae <intr_enable>

ffffffffc020053e <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020053e:	100027f3          	csrr	a5,sstatus
ffffffffc0200542:	8b89                	andi	a5,a5,2
ffffffffc0200544:	eb89                	bnez	a5,ffffffffc0200556 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200546:	4501                	li	a0,0
ffffffffc0200548:	4581                	li	a1,0
ffffffffc020054a:	4601                	li	a2,0
ffffffffc020054c:	4889                	li	a7,2
ffffffffc020054e:	00000073          	ecall
ffffffffc0200552:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200554:	8082                	ret
int cons_getc(void) {
ffffffffc0200556:	1101                	addi	sp,sp,-32
ffffffffc0200558:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020055a:	05a000ef          	jal	ra,ffffffffc02005b4 <intr_disable>
ffffffffc020055e:	4501                	li	a0,0
ffffffffc0200560:	4581                	li	a1,0
ffffffffc0200562:	4601                	li	a2,0
ffffffffc0200564:	4889                	li	a7,2
ffffffffc0200566:	00000073          	ecall
ffffffffc020056a:	2501                	sext.w	a0,a0
ffffffffc020056c:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020056e:	040000ef          	jal	ra,ffffffffc02005ae <intr_enable>
}
ffffffffc0200572:	60e2                	ld	ra,24(sp)
ffffffffc0200574:	6522                	ld	a0,8(sp)
ffffffffc0200576:	6105                	addi	sp,sp,32
ffffffffc0200578:	8082                	ret

ffffffffc020057a <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc020057a:	8082                	ret

ffffffffc020057c <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc020057c:	00253513          	sltiu	a0,a0,2
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc0200582:	03800513          	li	a0,56
ffffffffc0200586:	8082                	ret

ffffffffc0200588 <ide_write_secs>:
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
    return 0;
}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200588:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020058a:	0095979b          	slliw	a5,a1,0x9
ffffffffc020058e:	0000a517          	auipc	a0,0xa
ffffffffc0200592:	eca50513          	addi	a0,a0,-310 # ffffffffc020a458 <ide>
                   size_t nsecs) {
ffffffffc0200596:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200598:	00969613          	slli	a2,a3,0x9
ffffffffc020059c:	85ba                	mv	a1,a4
ffffffffc020059e:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02005a0:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005a2:	34a040ef          	jal	ra,ffffffffc02048ec <memcpy>
    return 0;
}
ffffffffc02005a6:	60a2                	ld	ra,8(sp)
ffffffffc02005a8:	4501                	li	a0,0
ffffffffc02005aa:	0141                	addi	sp,sp,16
ffffffffc02005ac:	8082                	ret

ffffffffc02005ae <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005ae:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005b2:	8082                	ret

ffffffffc02005b4 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005b4:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005b8:	8082                	ret

ffffffffc02005ba <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02005ba:	8082                	ret

ffffffffc02005bc <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005bc:	10053783          	ld	a5,256(a0)
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005c0:	1141                	addi	sp,sp,-16
ffffffffc02005c2:	e022                	sd	s0,0(sp)
ffffffffc02005c4:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005c6:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005ca:	842a                	mv	s0,a0
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005cc:	11053583          	ld	a1,272(a0)
ffffffffc02005d0:	05500613          	li	a2,85
ffffffffc02005d4:	c399                	beqz	a5,ffffffffc02005da <pgfault_handler+0x1e>
ffffffffc02005d6:	04b00613          	li	a2,75
ffffffffc02005da:	11843703          	ld	a4,280(s0)
ffffffffc02005de:	47bd                	li	a5,15
ffffffffc02005e0:	05700693          	li	a3,87
ffffffffc02005e4:	00f70463          	beq	a4,a5,ffffffffc02005ec <pgfault_handler+0x30>
ffffffffc02005e8:	05200693          	li	a3,82
ffffffffc02005ec:	00005517          	auipc	a0,0x5
ffffffffc02005f0:	91450513          	addi	a0,a0,-1772 # ffffffffc0204f00 <commands+0x498>
ffffffffc02005f4:	b9bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc02005f8:	00015797          	auipc	a5,0x15
ffffffffc02005fc:	fe078793          	addi	a5,a5,-32 # ffffffffc02155d8 <check_mm_struct>
ffffffffc0200600:	6388                	ld	a0,0(a5)
ffffffffc0200602:	c911                	beqz	a0,ffffffffc0200616 <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200604:	11043603          	ld	a2,272(s0)
ffffffffc0200608:	11842583          	lw	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc020060c:	6402                	ld	s0,0(sp)
ffffffffc020060e:	60a2                	ld	ra,8(sp)
ffffffffc0200610:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200612:	0a50306f          	j	ffffffffc0203eb6 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200616:	00005617          	auipc	a2,0x5
ffffffffc020061a:	90a60613          	addi	a2,a2,-1782 # ffffffffc0204f20 <commands+0x4b8>
ffffffffc020061e:	06200593          	li	a1,98
ffffffffc0200622:	00005517          	auipc	a0,0x5
ffffffffc0200626:	91650513          	addi	a0,a0,-1770 # ffffffffc0204f38 <commands+0x4d0>
ffffffffc020062a:	e27ff0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020062e <idt_init>:
    write_csr(sscratch, 0);
ffffffffc020062e:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200632:	00000797          	auipc	a5,0x0
ffffffffc0200636:	48e78793          	addi	a5,a5,1166 # ffffffffc0200ac0 <__alltraps>
ffffffffc020063a:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020063e:	000407b7          	lui	a5,0x40
ffffffffc0200642:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200646:	8082                	ret

ffffffffc0200648 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200648:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
ffffffffc020064e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200650:	00005517          	auipc	a0,0x5
ffffffffc0200654:	90050513          	addi	a0,a0,-1792 # ffffffffc0204f50 <commands+0x4e8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200658:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020065a:	b35ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020065e:	640c                	ld	a1,8(s0)
ffffffffc0200660:	00005517          	auipc	a0,0x5
ffffffffc0200664:	90850513          	addi	a0,a0,-1784 # ffffffffc0204f68 <commands+0x500>
ffffffffc0200668:	b27ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020066c:	680c                	ld	a1,16(s0)
ffffffffc020066e:	00005517          	auipc	a0,0x5
ffffffffc0200672:	91250513          	addi	a0,a0,-1774 # ffffffffc0204f80 <commands+0x518>
ffffffffc0200676:	b19ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020067a:	6c0c                	ld	a1,24(s0)
ffffffffc020067c:	00005517          	auipc	a0,0x5
ffffffffc0200680:	91c50513          	addi	a0,a0,-1764 # ffffffffc0204f98 <commands+0x530>
ffffffffc0200684:	b0bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200688:	700c                	ld	a1,32(s0)
ffffffffc020068a:	00005517          	auipc	a0,0x5
ffffffffc020068e:	92650513          	addi	a0,a0,-1754 # ffffffffc0204fb0 <commands+0x548>
ffffffffc0200692:	afdff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200696:	740c                	ld	a1,40(s0)
ffffffffc0200698:	00005517          	auipc	a0,0x5
ffffffffc020069c:	93050513          	addi	a0,a0,-1744 # ffffffffc0204fc8 <commands+0x560>
ffffffffc02006a0:	aefff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006a4:	780c                	ld	a1,48(s0)
ffffffffc02006a6:	00005517          	auipc	a0,0x5
ffffffffc02006aa:	93a50513          	addi	a0,a0,-1734 # ffffffffc0204fe0 <commands+0x578>
ffffffffc02006ae:	ae1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006b2:	7c0c                	ld	a1,56(s0)
ffffffffc02006b4:	00005517          	auipc	a0,0x5
ffffffffc02006b8:	94450513          	addi	a0,a0,-1724 # ffffffffc0204ff8 <commands+0x590>
ffffffffc02006bc:	ad3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006c0:	602c                	ld	a1,64(s0)
ffffffffc02006c2:	00005517          	auipc	a0,0x5
ffffffffc02006c6:	94e50513          	addi	a0,a0,-1714 # ffffffffc0205010 <commands+0x5a8>
ffffffffc02006ca:	ac5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ce:	642c                	ld	a1,72(s0)
ffffffffc02006d0:	00005517          	auipc	a0,0x5
ffffffffc02006d4:	95850513          	addi	a0,a0,-1704 # ffffffffc0205028 <commands+0x5c0>
ffffffffc02006d8:	ab7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006dc:	682c                	ld	a1,80(s0)
ffffffffc02006de:	00005517          	auipc	a0,0x5
ffffffffc02006e2:	96250513          	addi	a0,a0,-1694 # ffffffffc0205040 <commands+0x5d8>
ffffffffc02006e6:	aa9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006ea:	6c2c                	ld	a1,88(s0)
ffffffffc02006ec:	00005517          	auipc	a0,0x5
ffffffffc02006f0:	96c50513          	addi	a0,a0,-1684 # ffffffffc0205058 <commands+0x5f0>
ffffffffc02006f4:	a9bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02006f8:	702c                	ld	a1,96(s0)
ffffffffc02006fa:	00005517          	auipc	a0,0x5
ffffffffc02006fe:	97650513          	addi	a0,a0,-1674 # ffffffffc0205070 <commands+0x608>
ffffffffc0200702:	a8dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200706:	742c                	ld	a1,104(s0)
ffffffffc0200708:	00005517          	auipc	a0,0x5
ffffffffc020070c:	98050513          	addi	a0,a0,-1664 # ffffffffc0205088 <commands+0x620>
ffffffffc0200710:	a7fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200714:	782c                	ld	a1,112(s0)
ffffffffc0200716:	00005517          	auipc	a0,0x5
ffffffffc020071a:	98a50513          	addi	a0,a0,-1654 # ffffffffc02050a0 <commands+0x638>
ffffffffc020071e:	a71ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200722:	7c2c                	ld	a1,120(s0)
ffffffffc0200724:	00005517          	auipc	a0,0x5
ffffffffc0200728:	99450513          	addi	a0,a0,-1644 # ffffffffc02050b8 <commands+0x650>
ffffffffc020072c:	a63ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200730:	604c                	ld	a1,128(s0)
ffffffffc0200732:	00005517          	auipc	a0,0x5
ffffffffc0200736:	99e50513          	addi	a0,a0,-1634 # ffffffffc02050d0 <commands+0x668>
ffffffffc020073a:	a55ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020073e:	644c                	ld	a1,136(s0)
ffffffffc0200740:	00005517          	auipc	a0,0x5
ffffffffc0200744:	9a850513          	addi	a0,a0,-1624 # ffffffffc02050e8 <commands+0x680>
ffffffffc0200748:	a47ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020074c:	684c                	ld	a1,144(s0)
ffffffffc020074e:	00005517          	auipc	a0,0x5
ffffffffc0200752:	9b250513          	addi	a0,a0,-1614 # ffffffffc0205100 <commands+0x698>
ffffffffc0200756:	a39ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020075a:	6c4c                	ld	a1,152(s0)
ffffffffc020075c:	00005517          	auipc	a0,0x5
ffffffffc0200760:	9bc50513          	addi	a0,a0,-1604 # ffffffffc0205118 <commands+0x6b0>
ffffffffc0200764:	a2bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200768:	704c                	ld	a1,160(s0)
ffffffffc020076a:	00005517          	auipc	a0,0x5
ffffffffc020076e:	9c650513          	addi	a0,a0,-1594 # ffffffffc0205130 <commands+0x6c8>
ffffffffc0200772:	a1dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200776:	744c                	ld	a1,168(s0)
ffffffffc0200778:	00005517          	auipc	a0,0x5
ffffffffc020077c:	9d050513          	addi	a0,a0,-1584 # ffffffffc0205148 <commands+0x6e0>
ffffffffc0200780:	a0fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200784:	784c                	ld	a1,176(s0)
ffffffffc0200786:	00005517          	auipc	a0,0x5
ffffffffc020078a:	9da50513          	addi	a0,a0,-1574 # ffffffffc0205160 <commands+0x6f8>
ffffffffc020078e:	a01ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200792:	7c4c                	ld	a1,184(s0)
ffffffffc0200794:	00005517          	auipc	a0,0x5
ffffffffc0200798:	9e450513          	addi	a0,a0,-1564 # ffffffffc0205178 <commands+0x710>
ffffffffc020079c:	9f3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007a0:	606c                	ld	a1,192(s0)
ffffffffc02007a2:	00005517          	auipc	a0,0x5
ffffffffc02007a6:	9ee50513          	addi	a0,a0,-1554 # ffffffffc0205190 <commands+0x728>
ffffffffc02007aa:	9e5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ae:	646c                	ld	a1,200(s0)
ffffffffc02007b0:	00005517          	auipc	a0,0x5
ffffffffc02007b4:	9f850513          	addi	a0,a0,-1544 # ffffffffc02051a8 <commands+0x740>
ffffffffc02007b8:	9d7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007bc:	686c                	ld	a1,208(s0)
ffffffffc02007be:	00005517          	auipc	a0,0x5
ffffffffc02007c2:	a0250513          	addi	a0,a0,-1534 # ffffffffc02051c0 <commands+0x758>
ffffffffc02007c6:	9c9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007ca:	6c6c                	ld	a1,216(s0)
ffffffffc02007cc:	00005517          	auipc	a0,0x5
ffffffffc02007d0:	a0c50513          	addi	a0,a0,-1524 # ffffffffc02051d8 <commands+0x770>
ffffffffc02007d4:	9bbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007d8:	706c                	ld	a1,224(s0)
ffffffffc02007da:	00005517          	auipc	a0,0x5
ffffffffc02007de:	a1650513          	addi	a0,a0,-1514 # ffffffffc02051f0 <commands+0x788>
ffffffffc02007e2:	9adff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007e6:	746c                	ld	a1,232(s0)
ffffffffc02007e8:	00005517          	auipc	a0,0x5
ffffffffc02007ec:	a2050513          	addi	a0,a0,-1504 # ffffffffc0205208 <commands+0x7a0>
ffffffffc02007f0:	99fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc02007f4:	786c                	ld	a1,240(s0)
ffffffffc02007f6:	00005517          	auipc	a0,0x5
ffffffffc02007fa:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0205220 <commands+0x7b8>
ffffffffc02007fe:	991ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200802:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200804:	6402                	ld	s0,0(sp)
ffffffffc0200806:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200808:	00005517          	auipc	a0,0x5
ffffffffc020080c:	a3050513          	addi	a0,a0,-1488 # ffffffffc0205238 <commands+0x7d0>
}
ffffffffc0200810:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200812:	97dff06f          	j	ffffffffc020018e <cprintf>

ffffffffc0200816 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200816:	1141                	addi	sp,sp,-16
ffffffffc0200818:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020081a:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc020081c:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020081e:	00005517          	auipc	a0,0x5
ffffffffc0200822:	a3250513          	addi	a0,a0,-1486 # ffffffffc0205250 <commands+0x7e8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200826:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200828:	967ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    print_regs(&tf->gpr);
ffffffffc020082c:	8522                	mv	a0,s0
ffffffffc020082e:	e1bff0ef          	jal	ra,ffffffffc0200648 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200832:	10043583          	ld	a1,256(s0)
ffffffffc0200836:	00005517          	auipc	a0,0x5
ffffffffc020083a:	a3250513          	addi	a0,a0,-1486 # ffffffffc0205268 <commands+0x800>
ffffffffc020083e:	951ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200842:	10843583          	ld	a1,264(s0)
ffffffffc0200846:	00005517          	auipc	a0,0x5
ffffffffc020084a:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0205280 <commands+0x818>
ffffffffc020084e:	941ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200852:	11043583          	ld	a1,272(s0)
ffffffffc0200856:	00005517          	auipc	a0,0x5
ffffffffc020085a:	a4250513          	addi	a0,a0,-1470 # ffffffffc0205298 <commands+0x830>
ffffffffc020085e:	931ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200862:	11843583          	ld	a1,280(s0)
}
ffffffffc0200866:	6402                	ld	s0,0(sp)
ffffffffc0200868:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020086a:	00005517          	auipc	a0,0x5
ffffffffc020086e:	a4650513          	addi	a0,a0,-1466 # ffffffffc02052b0 <commands+0x848>
}
ffffffffc0200872:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200874:	91bff06f          	j	ffffffffc020018e <cprintf>

ffffffffc0200878 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200878:	11853783          	ld	a5,280(a0)
ffffffffc020087c:	577d                	li	a4,-1
ffffffffc020087e:	8305                	srli	a4,a4,0x1
ffffffffc0200880:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc0200882:	472d                	li	a4,11
ffffffffc0200884:	06f76f63          	bltu	a4,a5,ffffffffc0200902 <interrupt_handler+0x8a>
ffffffffc0200888:	00004717          	auipc	a4,0x4
ffffffffc020088c:	39c70713          	addi	a4,a4,924 # ffffffffc0204c24 <commands+0x1bc>
ffffffffc0200890:	078a                	slli	a5,a5,0x2
ffffffffc0200892:	97ba                	add	a5,a5,a4
ffffffffc0200894:	439c                	lw	a5,0(a5)
ffffffffc0200896:	97ba                	add	a5,a5,a4
ffffffffc0200898:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc020089a:	00004517          	auipc	a0,0x4
ffffffffc020089e:	61650513          	addi	a0,a0,1558 # ffffffffc0204eb0 <commands+0x448>
ffffffffc02008a2:	8edff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02008a6:	00004517          	auipc	a0,0x4
ffffffffc02008aa:	5ea50513          	addi	a0,a0,1514 # ffffffffc0204e90 <commands+0x428>
ffffffffc02008ae:	8e1ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008b2:	00004517          	auipc	a0,0x4
ffffffffc02008b6:	59e50513          	addi	a0,a0,1438 # ffffffffc0204e50 <commands+0x3e8>
ffffffffc02008ba:	8d5ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008be:	00004517          	auipc	a0,0x4
ffffffffc02008c2:	5b250513          	addi	a0,a0,1458 # ffffffffc0204e70 <commands+0x408>
ffffffffc02008c6:	8c9ff06f          	j	ffffffffc020018e <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02008ca:	00004517          	auipc	a0,0x4
ffffffffc02008ce:	61650513          	addi	a0,a0,1558 # ffffffffc0204ee0 <commands+0x478>
ffffffffc02008d2:	8bdff06f          	j	ffffffffc020018e <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008d6:	1141                	addi	sp,sp,-16
ffffffffc02008d8:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc02008da:	c11ff0ef          	jal	ra,ffffffffc02004ea <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02008de:	00015797          	auipc	a5,0x15
ffffffffc02008e2:	be278793          	addi	a5,a5,-1054 # ffffffffc02154c0 <ticks>
ffffffffc02008e6:	639c                	ld	a5,0(a5)
ffffffffc02008e8:	06400713          	li	a4,100
ffffffffc02008ec:	0785                	addi	a5,a5,1
ffffffffc02008ee:	02e7f733          	remu	a4,a5,a4
ffffffffc02008f2:	00015697          	auipc	a3,0x15
ffffffffc02008f6:	bcf6b723          	sd	a5,-1074(a3) # ffffffffc02154c0 <ticks>
ffffffffc02008fa:	c711                	beqz	a4,ffffffffc0200906 <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008fc:	60a2                	ld	ra,8(sp)
ffffffffc02008fe:	0141                	addi	sp,sp,16
ffffffffc0200900:	8082                	ret
            print_trapframe(tf);
ffffffffc0200902:	f15ff06f          	j	ffffffffc0200816 <print_trapframe>
}
ffffffffc0200906:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200908:	06400593          	li	a1,100
ffffffffc020090c:	00004517          	auipc	a0,0x4
ffffffffc0200910:	5c450513          	addi	a0,a0,1476 # ffffffffc0204ed0 <commands+0x468>
}
ffffffffc0200914:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200916:	879ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc020091a <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc020091a:	11853783          	ld	a5,280(a0)
ffffffffc020091e:	473d                	li	a4,15
ffffffffc0200920:	16f76563          	bltu	a4,a5,ffffffffc0200a8a <exception_handler+0x170>
ffffffffc0200924:	00004717          	auipc	a4,0x4
ffffffffc0200928:	33070713          	addi	a4,a4,816 # ffffffffc0204c54 <commands+0x1ec>
ffffffffc020092c:	078a                	slli	a5,a5,0x2
ffffffffc020092e:	97ba                	add	a5,a5,a4
ffffffffc0200930:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200932:	1101                	addi	sp,sp,-32
ffffffffc0200934:	e822                	sd	s0,16(sp)
ffffffffc0200936:	ec06                	sd	ra,24(sp)
ffffffffc0200938:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc020093a:	97ba                	add	a5,a5,a4
ffffffffc020093c:	842a                	mv	s0,a0
ffffffffc020093e:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200940:	00004517          	auipc	a0,0x4
ffffffffc0200944:	4f850513          	addi	a0,a0,1272 # ffffffffc0204e38 <commands+0x3d0>
ffffffffc0200948:	847ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020094c:	8522                	mv	a0,s0
ffffffffc020094e:	c6fff0ef          	jal	ra,ffffffffc02005bc <pgfault_handler>
ffffffffc0200952:	84aa                	mv	s1,a0
ffffffffc0200954:	12051d63          	bnez	a0,ffffffffc0200a8e <exception_handler+0x174>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200958:	60e2                	ld	ra,24(sp)
ffffffffc020095a:	6442                	ld	s0,16(sp)
ffffffffc020095c:	64a2                	ld	s1,8(sp)
ffffffffc020095e:	6105                	addi	sp,sp,32
ffffffffc0200960:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200962:	00004517          	auipc	a0,0x4
ffffffffc0200966:	33650513          	addi	a0,a0,822 # ffffffffc0204c98 <commands+0x230>
}
ffffffffc020096a:	6442                	ld	s0,16(sp)
ffffffffc020096c:	60e2                	ld	ra,24(sp)
ffffffffc020096e:	64a2                	ld	s1,8(sp)
ffffffffc0200970:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200972:	81dff06f          	j	ffffffffc020018e <cprintf>
ffffffffc0200976:	00004517          	auipc	a0,0x4
ffffffffc020097a:	34250513          	addi	a0,a0,834 # ffffffffc0204cb8 <commands+0x250>
ffffffffc020097e:	b7f5                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200980:	00004517          	auipc	a0,0x4
ffffffffc0200984:	35850513          	addi	a0,a0,856 # ffffffffc0204cd8 <commands+0x270>
ffffffffc0200988:	b7cd                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc020098a:	00004517          	auipc	a0,0x4
ffffffffc020098e:	36650513          	addi	a0,a0,870 # ffffffffc0204cf0 <commands+0x288>
ffffffffc0200992:	bfe1                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc0200994:	00004517          	auipc	a0,0x4
ffffffffc0200998:	36c50513          	addi	a0,a0,876 # ffffffffc0204d00 <commands+0x298>
ffffffffc020099c:	b7f9                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc020099e:	00004517          	auipc	a0,0x4
ffffffffc02009a2:	38250513          	addi	a0,a0,898 # ffffffffc0204d20 <commands+0x2b8>
ffffffffc02009a6:	fe8ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009aa:	8522                	mv	a0,s0
ffffffffc02009ac:	c11ff0ef          	jal	ra,ffffffffc02005bc <pgfault_handler>
ffffffffc02009b0:	84aa                	mv	s1,a0
ffffffffc02009b2:	d15d                	beqz	a0,ffffffffc0200958 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009b4:	8522                	mv	a0,s0
ffffffffc02009b6:	e61ff0ef          	jal	ra,ffffffffc0200816 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ba:	86a6                	mv	a3,s1
ffffffffc02009bc:	00004617          	auipc	a2,0x4
ffffffffc02009c0:	37c60613          	addi	a2,a2,892 # ffffffffc0204d38 <commands+0x2d0>
ffffffffc02009c4:	0b300593          	li	a1,179
ffffffffc02009c8:	00004517          	auipc	a0,0x4
ffffffffc02009cc:	57050513          	addi	a0,a0,1392 # ffffffffc0204f38 <commands+0x4d0>
ffffffffc02009d0:	a81ff0ef          	jal	ra,ffffffffc0200450 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02009d4:	00004517          	auipc	a0,0x4
ffffffffc02009d8:	38450513          	addi	a0,a0,900 # ffffffffc0204d58 <commands+0x2f0>
ffffffffc02009dc:	b779                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc02009de:	00004517          	auipc	a0,0x4
ffffffffc02009e2:	39250513          	addi	a0,a0,914 # ffffffffc0204d70 <commands+0x308>
ffffffffc02009e6:	fa8ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009ea:	8522                	mv	a0,s0
ffffffffc02009ec:	bd1ff0ef          	jal	ra,ffffffffc02005bc <pgfault_handler>
ffffffffc02009f0:	84aa                	mv	s1,a0
ffffffffc02009f2:	d13d                	beqz	a0,ffffffffc0200958 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009f4:	8522                	mv	a0,s0
ffffffffc02009f6:	e21ff0ef          	jal	ra,ffffffffc0200816 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009fa:	86a6                	mv	a3,s1
ffffffffc02009fc:	00004617          	auipc	a2,0x4
ffffffffc0200a00:	33c60613          	addi	a2,a2,828 # ffffffffc0204d38 <commands+0x2d0>
ffffffffc0200a04:	0bd00593          	li	a1,189
ffffffffc0200a08:	00004517          	auipc	a0,0x4
ffffffffc0200a0c:	53050513          	addi	a0,a0,1328 # ffffffffc0204f38 <commands+0x4d0>
ffffffffc0200a10:	a41ff0ef          	jal	ra,ffffffffc0200450 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200a14:	00004517          	auipc	a0,0x4
ffffffffc0200a18:	37450513          	addi	a0,a0,884 # ffffffffc0204d88 <commands+0x320>
ffffffffc0200a1c:	b7b9                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200a1e:	00004517          	auipc	a0,0x4
ffffffffc0200a22:	38a50513          	addi	a0,a0,906 # ffffffffc0204da8 <commands+0x340>
ffffffffc0200a26:	b791                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a28:	00004517          	auipc	a0,0x4
ffffffffc0200a2c:	3a050513          	addi	a0,a0,928 # ffffffffc0204dc8 <commands+0x360>
ffffffffc0200a30:	bf2d                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a32:	00004517          	auipc	a0,0x4
ffffffffc0200a36:	3b650513          	addi	a0,a0,950 # ffffffffc0204de8 <commands+0x380>
ffffffffc0200a3a:	bf05                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a3c:	00004517          	auipc	a0,0x4
ffffffffc0200a40:	3cc50513          	addi	a0,a0,972 # ffffffffc0204e08 <commands+0x3a0>
ffffffffc0200a44:	b71d                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a46:	00004517          	auipc	a0,0x4
ffffffffc0200a4a:	3da50513          	addi	a0,a0,986 # ffffffffc0204e20 <commands+0x3b8>
ffffffffc0200a4e:	f40ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a52:	8522                	mv	a0,s0
ffffffffc0200a54:	b69ff0ef          	jal	ra,ffffffffc02005bc <pgfault_handler>
ffffffffc0200a58:	84aa                	mv	s1,a0
ffffffffc0200a5a:	ee050fe3          	beqz	a0,ffffffffc0200958 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a5e:	8522                	mv	a0,s0
ffffffffc0200a60:	db7ff0ef          	jal	ra,ffffffffc0200816 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a64:	86a6                	mv	a3,s1
ffffffffc0200a66:	00004617          	auipc	a2,0x4
ffffffffc0200a6a:	2d260613          	addi	a2,a2,722 # ffffffffc0204d38 <commands+0x2d0>
ffffffffc0200a6e:	0d300593          	li	a1,211
ffffffffc0200a72:	00004517          	auipc	a0,0x4
ffffffffc0200a76:	4c650513          	addi	a0,a0,1222 # ffffffffc0204f38 <commands+0x4d0>
ffffffffc0200a7a:	9d7ff0ef          	jal	ra,ffffffffc0200450 <__panic>
}
ffffffffc0200a7e:	6442                	ld	s0,16(sp)
ffffffffc0200a80:	60e2                	ld	ra,24(sp)
ffffffffc0200a82:	64a2                	ld	s1,8(sp)
ffffffffc0200a84:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a86:	d91ff06f          	j	ffffffffc0200816 <print_trapframe>
ffffffffc0200a8a:	d8dff06f          	j	ffffffffc0200816 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200a8e:	8522                	mv	a0,s0
ffffffffc0200a90:	d87ff0ef          	jal	ra,ffffffffc0200816 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a94:	86a6                	mv	a3,s1
ffffffffc0200a96:	00004617          	auipc	a2,0x4
ffffffffc0200a9a:	2a260613          	addi	a2,a2,674 # ffffffffc0204d38 <commands+0x2d0>
ffffffffc0200a9e:	0da00593          	li	a1,218
ffffffffc0200aa2:	00004517          	auipc	a0,0x4
ffffffffc0200aa6:	49650513          	addi	a0,a0,1174 # ffffffffc0204f38 <commands+0x4d0>
ffffffffc0200aaa:	9a7ff0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0200aae <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200aae:	11853783          	ld	a5,280(a0)
ffffffffc0200ab2:	0007c463          	bltz	a5,ffffffffc0200aba <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200ab6:	e65ff06f          	j	ffffffffc020091a <exception_handler>
        interrupt_handler(tf);
ffffffffc0200aba:	dbfff06f          	j	ffffffffc0200878 <interrupt_handler>
	...

ffffffffc0200ac0 <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ac0:	14011073          	csrw	sscratch,sp
ffffffffc0200ac4:	712d                	addi	sp,sp,-288
ffffffffc0200ac6:	e406                	sd	ra,8(sp)
ffffffffc0200ac8:	ec0e                	sd	gp,24(sp)
ffffffffc0200aca:	f012                	sd	tp,32(sp)
ffffffffc0200acc:	f416                	sd	t0,40(sp)
ffffffffc0200ace:	f81a                	sd	t1,48(sp)
ffffffffc0200ad0:	fc1e                	sd	t2,56(sp)
ffffffffc0200ad2:	e0a2                	sd	s0,64(sp)
ffffffffc0200ad4:	e4a6                	sd	s1,72(sp)
ffffffffc0200ad6:	e8aa                	sd	a0,80(sp)
ffffffffc0200ad8:	ecae                	sd	a1,88(sp)
ffffffffc0200ada:	f0b2                	sd	a2,96(sp)
ffffffffc0200adc:	f4b6                	sd	a3,104(sp)
ffffffffc0200ade:	f8ba                	sd	a4,112(sp)
ffffffffc0200ae0:	fcbe                	sd	a5,120(sp)
ffffffffc0200ae2:	e142                	sd	a6,128(sp)
ffffffffc0200ae4:	e546                	sd	a7,136(sp)
ffffffffc0200ae6:	e94a                	sd	s2,144(sp)
ffffffffc0200ae8:	ed4e                	sd	s3,152(sp)
ffffffffc0200aea:	f152                	sd	s4,160(sp)
ffffffffc0200aec:	f556                	sd	s5,168(sp)
ffffffffc0200aee:	f95a                	sd	s6,176(sp)
ffffffffc0200af0:	fd5e                	sd	s7,184(sp)
ffffffffc0200af2:	e1e2                	sd	s8,192(sp)
ffffffffc0200af4:	e5e6                	sd	s9,200(sp)
ffffffffc0200af6:	e9ea                	sd	s10,208(sp)
ffffffffc0200af8:	edee                	sd	s11,216(sp)
ffffffffc0200afa:	f1f2                	sd	t3,224(sp)
ffffffffc0200afc:	f5f6                	sd	t4,232(sp)
ffffffffc0200afe:	f9fa                	sd	t5,240(sp)
ffffffffc0200b00:	fdfe                	sd	t6,248(sp)
ffffffffc0200b02:	14002473          	csrr	s0,sscratch
ffffffffc0200b06:	100024f3          	csrr	s1,sstatus
ffffffffc0200b0a:	14102973          	csrr	s2,sepc
ffffffffc0200b0e:	143029f3          	csrr	s3,stval
ffffffffc0200b12:	14202a73          	csrr	s4,scause
ffffffffc0200b16:	e822                	sd	s0,16(sp)
ffffffffc0200b18:	e226                	sd	s1,256(sp)
ffffffffc0200b1a:	e64a                	sd	s2,264(sp)
ffffffffc0200b1c:	ea4e                	sd	s3,272(sp)
ffffffffc0200b1e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200b20:	850a                	mv	a0,sp
    jal trap
ffffffffc0200b22:	f8dff0ef          	jal	ra,ffffffffc0200aae <trap>

ffffffffc0200b26 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200b26:	6492                	ld	s1,256(sp)
ffffffffc0200b28:	6932                	ld	s2,264(sp)
ffffffffc0200b2a:	10049073          	csrw	sstatus,s1
ffffffffc0200b2e:	14191073          	csrw	sepc,s2
ffffffffc0200b32:	60a2                	ld	ra,8(sp)
ffffffffc0200b34:	61e2                	ld	gp,24(sp)
ffffffffc0200b36:	7202                	ld	tp,32(sp)
ffffffffc0200b38:	72a2                	ld	t0,40(sp)
ffffffffc0200b3a:	7342                	ld	t1,48(sp)
ffffffffc0200b3c:	73e2                	ld	t2,56(sp)
ffffffffc0200b3e:	6406                	ld	s0,64(sp)
ffffffffc0200b40:	64a6                	ld	s1,72(sp)
ffffffffc0200b42:	6546                	ld	a0,80(sp)
ffffffffc0200b44:	65e6                	ld	a1,88(sp)
ffffffffc0200b46:	7606                	ld	a2,96(sp)
ffffffffc0200b48:	76a6                	ld	a3,104(sp)
ffffffffc0200b4a:	7746                	ld	a4,112(sp)
ffffffffc0200b4c:	77e6                	ld	a5,120(sp)
ffffffffc0200b4e:	680a                	ld	a6,128(sp)
ffffffffc0200b50:	68aa                	ld	a7,136(sp)
ffffffffc0200b52:	694a                	ld	s2,144(sp)
ffffffffc0200b54:	69ea                	ld	s3,152(sp)
ffffffffc0200b56:	7a0a                	ld	s4,160(sp)
ffffffffc0200b58:	7aaa                	ld	s5,168(sp)
ffffffffc0200b5a:	7b4a                	ld	s6,176(sp)
ffffffffc0200b5c:	7bea                	ld	s7,184(sp)
ffffffffc0200b5e:	6c0e                	ld	s8,192(sp)
ffffffffc0200b60:	6cae                	ld	s9,200(sp)
ffffffffc0200b62:	6d4e                	ld	s10,208(sp)
ffffffffc0200b64:	6dee                	ld	s11,216(sp)
ffffffffc0200b66:	7e0e                	ld	t3,224(sp)
ffffffffc0200b68:	7eae                	ld	t4,232(sp)
ffffffffc0200b6a:	7f4e                	ld	t5,240(sp)
ffffffffc0200b6c:	7fee                	ld	t6,248(sp)
ffffffffc0200b6e:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200b70:	10200073          	sret

ffffffffc0200b74 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200b74:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200b76:	bf45                	j	ffffffffc0200b26 <__trapret>
	...

ffffffffc0200b7a <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200b7a:	00015797          	auipc	a5,0x15
ffffffffc0200b7e:	94e78793          	addi	a5,a5,-1714 # ffffffffc02154c8 <free_area>
ffffffffc0200b82:	e79c                	sd	a5,8(a5)
ffffffffc0200b84:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200b86:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200b8a:	8082                	ret

ffffffffc0200b8c <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200b8c:	00015517          	auipc	a0,0x15
ffffffffc0200b90:	94c56503          	lwu	a0,-1716(a0) # ffffffffc02154d8 <free_area+0x10>
ffffffffc0200b94:	8082                	ret

ffffffffc0200b96 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200b96:	715d                	addi	sp,sp,-80
ffffffffc0200b98:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b9a:	00015917          	auipc	s2,0x15
ffffffffc0200b9e:	92e90913          	addi	s2,s2,-1746 # ffffffffc02154c8 <free_area>
ffffffffc0200ba2:	00893783          	ld	a5,8(s2)
ffffffffc0200ba6:	e486                	sd	ra,72(sp)
ffffffffc0200ba8:	e0a2                	sd	s0,64(sp)
ffffffffc0200baa:	fc26                	sd	s1,56(sp)
ffffffffc0200bac:	f44e                	sd	s3,40(sp)
ffffffffc0200bae:	f052                	sd	s4,32(sp)
ffffffffc0200bb0:	ec56                	sd	s5,24(sp)
ffffffffc0200bb2:	e85a                	sd	s6,16(sp)
ffffffffc0200bb4:	e45e                	sd	s7,8(sp)
ffffffffc0200bb6:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bb8:	31278463          	beq	a5,s2,ffffffffc0200ec0 <default_check+0x32a>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200bbc:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200bc0:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200bc2:	8b05                	andi	a4,a4,1
ffffffffc0200bc4:	30070263          	beqz	a4,ffffffffc0200ec8 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0200bc8:	4401                	li	s0,0
ffffffffc0200bca:	4481                	li	s1,0
ffffffffc0200bcc:	a031                	j	ffffffffc0200bd8 <default_check+0x42>
ffffffffc0200bce:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200bd2:	8b09                	andi	a4,a4,2
ffffffffc0200bd4:	2e070a63          	beqz	a4,ffffffffc0200ec8 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0200bd8:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200bdc:	679c                	ld	a5,8(a5)
ffffffffc0200bde:	2485                	addiw	s1,s1,1
ffffffffc0200be0:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200be2:	ff2796e3          	bne	a5,s2,ffffffffc0200bce <default_check+0x38>
ffffffffc0200be6:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200be8:	058010ef          	jal	ra,ffffffffc0201c40 <nr_free_pages>
ffffffffc0200bec:	73351e63          	bne	a0,s3,ffffffffc0201328 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bf0:	4505                	li	a0,1
ffffffffc0200bf2:	781000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200bf6:	8a2a                	mv	s4,a0
ffffffffc0200bf8:	46050863          	beqz	a0,ffffffffc0201068 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200bfc:	4505                	li	a0,1
ffffffffc0200bfe:	775000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200c02:	89aa                	mv	s3,a0
ffffffffc0200c04:	74050263          	beqz	a0,ffffffffc0201348 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c08:	4505                	li	a0,1
ffffffffc0200c0a:	769000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200c0e:	8aaa                	mv	s5,a0
ffffffffc0200c10:	4c050c63          	beqz	a0,ffffffffc02010e8 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c14:	2d3a0a63          	beq	s4,s3,ffffffffc0200ee8 <default_check+0x352>
ffffffffc0200c18:	2caa0863          	beq	s4,a0,ffffffffc0200ee8 <default_check+0x352>
ffffffffc0200c1c:	2ca98663          	beq	s3,a0,ffffffffc0200ee8 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c20:	000a2783          	lw	a5,0(s4)
ffffffffc0200c24:	2e079263          	bnez	a5,ffffffffc0200f08 <default_check+0x372>
ffffffffc0200c28:	0009a783          	lw	a5,0(s3)
ffffffffc0200c2c:	2c079e63          	bnez	a5,ffffffffc0200f08 <default_check+0x372>
ffffffffc0200c30:	411c                	lw	a5,0(a0)
ffffffffc0200c32:	2c079b63          	bnez	a5,ffffffffc0200f08 <default_check+0x372>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200c36:	00015797          	auipc	a5,0x15
ffffffffc0200c3a:	8c278793          	addi	a5,a5,-1854 # ffffffffc02154f8 <pages>
ffffffffc0200c3e:	639c                	ld	a5,0(a5)
ffffffffc0200c40:	00006717          	auipc	a4,0x6
ffffffffc0200c44:	d1870713          	addi	a4,a4,-744 # ffffffffc0206958 <nbase>
ffffffffc0200c48:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c4a:	00015717          	auipc	a4,0x15
ffffffffc0200c4e:	83e70713          	addi	a4,a4,-1986 # ffffffffc0215488 <npage>
ffffffffc0200c52:	6314                	ld	a3,0(a4)
ffffffffc0200c54:	40fa0733          	sub	a4,s4,a5
ffffffffc0200c58:	8719                	srai	a4,a4,0x6
ffffffffc0200c5a:	9732                	add	a4,a4,a2
ffffffffc0200c5c:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c5e:	0732                	slli	a4,a4,0xc
ffffffffc0200c60:	2cd77463          	bleu	a3,a4,ffffffffc0200f28 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0200c64:	40f98733          	sub	a4,s3,a5
ffffffffc0200c68:	8719                	srai	a4,a4,0x6
ffffffffc0200c6a:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c6c:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200c6e:	4ed77d63          	bleu	a3,a4,ffffffffc0201168 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0200c72:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c76:	8799                	srai	a5,a5,0x6
ffffffffc0200c78:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c7a:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c7c:	34d7f663          	bleu	a3,a5,ffffffffc0200fc8 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0200c80:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c82:	00093c03          	ld	s8,0(s2)
ffffffffc0200c86:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200c8a:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200c8e:	00015797          	auipc	a5,0x15
ffffffffc0200c92:	8527b123          	sd	s2,-1982(a5) # ffffffffc02154d0 <free_area+0x8>
ffffffffc0200c96:	00015797          	auipc	a5,0x15
ffffffffc0200c9a:	8327b923          	sd	s2,-1998(a5) # ffffffffc02154c8 <free_area>
    nr_free = 0;
ffffffffc0200c9e:	00015797          	auipc	a5,0x15
ffffffffc0200ca2:	8207ad23          	sw	zero,-1990(a5) # ffffffffc02154d8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200ca6:	6cd000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200caa:	2e051f63          	bnez	a0,ffffffffc0200fa8 <default_check+0x412>
    free_page(p0);
ffffffffc0200cae:	4585                	li	a1,1
ffffffffc0200cb0:	8552                	mv	a0,s4
ffffffffc0200cb2:	749000ef          	jal	ra,ffffffffc0201bfa <free_pages>
    free_page(p1);
ffffffffc0200cb6:	4585                	li	a1,1
ffffffffc0200cb8:	854e                	mv	a0,s3
ffffffffc0200cba:	741000ef          	jal	ra,ffffffffc0201bfa <free_pages>
    free_page(p2);
ffffffffc0200cbe:	4585                	li	a1,1
ffffffffc0200cc0:	8556                	mv	a0,s5
ffffffffc0200cc2:	739000ef          	jal	ra,ffffffffc0201bfa <free_pages>
    assert(nr_free == 3);
ffffffffc0200cc6:	01092703          	lw	a4,16(s2)
ffffffffc0200cca:	478d                	li	a5,3
ffffffffc0200ccc:	2af71e63          	bne	a4,a5,ffffffffc0200f88 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cd0:	4505                	li	a0,1
ffffffffc0200cd2:	6a1000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200cd6:	89aa                	mv	s3,a0
ffffffffc0200cd8:	28050863          	beqz	a0,ffffffffc0200f68 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200cdc:	4505                	li	a0,1
ffffffffc0200cde:	695000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200ce2:	8aaa                	mv	s5,a0
ffffffffc0200ce4:	3e050263          	beqz	a0,ffffffffc02010c8 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ce8:	4505                	li	a0,1
ffffffffc0200cea:	689000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200cee:	8a2a                	mv	s4,a0
ffffffffc0200cf0:	3a050c63          	beqz	a0,ffffffffc02010a8 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0200cf4:	4505                	li	a0,1
ffffffffc0200cf6:	67d000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200cfa:	38051763          	bnez	a0,ffffffffc0201088 <default_check+0x4f2>
    free_page(p0);
ffffffffc0200cfe:	4585                	li	a1,1
ffffffffc0200d00:	854e                	mv	a0,s3
ffffffffc0200d02:	6f9000ef          	jal	ra,ffffffffc0201bfa <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200d06:	00893783          	ld	a5,8(s2)
ffffffffc0200d0a:	23278f63          	beq	a5,s2,ffffffffc0200f48 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0200d0e:	4505                	li	a0,1
ffffffffc0200d10:	663000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200d14:	32a99a63          	bne	s3,a0,ffffffffc0201048 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0200d18:	4505                	li	a0,1
ffffffffc0200d1a:	659000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200d1e:	30051563          	bnez	a0,ffffffffc0201028 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0200d22:	01092783          	lw	a5,16(s2)
ffffffffc0200d26:	2e079163          	bnez	a5,ffffffffc0201008 <default_check+0x472>
    free_page(p);
ffffffffc0200d2a:	854e                	mv	a0,s3
ffffffffc0200d2c:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200d2e:	00014797          	auipc	a5,0x14
ffffffffc0200d32:	7987bd23          	sd	s8,1946(a5) # ffffffffc02154c8 <free_area>
ffffffffc0200d36:	00014797          	auipc	a5,0x14
ffffffffc0200d3a:	7977bd23          	sd	s7,1946(a5) # ffffffffc02154d0 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200d3e:	00014797          	auipc	a5,0x14
ffffffffc0200d42:	7967ad23          	sw	s6,1946(a5) # ffffffffc02154d8 <free_area+0x10>
    free_page(p);
ffffffffc0200d46:	6b5000ef          	jal	ra,ffffffffc0201bfa <free_pages>
    free_page(p1);
ffffffffc0200d4a:	4585                	li	a1,1
ffffffffc0200d4c:	8556                	mv	a0,s5
ffffffffc0200d4e:	6ad000ef          	jal	ra,ffffffffc0201bfa <free_pages>
    free_page(p2);
ffffffffc0200d52:	4585                	li	a1,1
ffffffffc0200d54:	8552                	mv	a0,s4
ffffffffc0200d56:	6a5000ef          	jal	ra,ffffffffc0201bfa <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200d5a:	4515                	li	a0,5
ffffffffc0200d5c:	617000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200d60:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200d62:	28050363          	beqz	a0,ffffffffc0200fe8 <default_check+0x452>
ffffffffc0200d66:	651c                	ld	a5,8(a0)
ffffffffc0200d68:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200d6a:	8b85                	andi	a5,a5,1
ffffffffc0200d6c:	54079e63          	bnez	a5,ffffffffc02012c8 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200d70:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200d72:	00093b03          	ld	s6,0(s2)
ffffffffc0200d76:	00893a83          	ld	s5,8(s2)
ffffffffc0200d7a:	00014797          	auipc	a5,0x14
ffffffffc0200d7e:	7527b723          	sd	s2,1870(a5) # ffffffffc02154c8 <free_area>
ffffffffc0200d82:	00014797          	auipc	a5,0x14
ffffffffc0200d86:	7527b723          	sd	s2,1870(a5) # ffffffffc02154d0 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200d8a:	5e9000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200d8e:	50051d63          	bnez	a0,ffffffffc02012a8 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200d92:	08098a13          	addi	s4,s3,128
ffffffffc0200d96:	8552                	mv	a0,s4
ffffffffc0200d98:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200d9a:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200d9e:	00014797          	auipc	a5,0x14
ffffffffc0200da2:	7207ad23          	sw	zero,1850(a5) # ffffffffc02154d8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200da6:	655000ef          	jal	ra,ffffffffc0201bfa <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200daa:	4511                	li	a0,4
ffffffffc0200dac:	5c7000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200db0:	4c051c63          	bnez	a0,ffffffffc0201288 <default_check+0x6f2>
ffffffffc0200db4:	0889b783          	ld	a5,136(s3)
ffffffffc0200db8:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200dba:	8b85                	andi	a5,a5,1
ffffffffc0200dbc:	4a078663          	beqz	a5,ffffffffc0201268 <default_check+0x6d2>
ffffffffc0200dc0:	0909a703          	lw	a4,144(s3)
ffffffffc0200dc4:	478d                	li	a5,3
ffffffffc0200dc6:	4af71163          	bne	a4,a5,ffffffffc0201268 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200dca:	450d                	li	a0,3
ffffffffc0200dcc:	5a7000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200dd0:	8c2a                	mv	s8,a0
ffffffffc0200dd2:	46050b63          	beqz	a0,ffffffffc0201248 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc0200dd6:	4505                	li	a0,1
ffffffffc0200dd8:	59b000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200ddc:	44051663          	bnez	a0,ffffffffc0201228 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc0200de0:	438a1463          	bne	s4,s8,ffffffffc0201208 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200de4:	4585                	li	a1,1
ffffffffc0200de6:	854e                	mv	a0,s3
ffffffffc0200de8:	613000ef          	jal	ra,ffffffffc0201bfa <free_pages>
    free_pages(p1, 3);
ffffffffc0200dec:	458d                	li	a1,3
ffffffffc0200dee:	8552                	mv	a0,s4
ffffffffc0200df0:	60b000ef          	jal	ra,ffffffffc0201bfa <free_pages>
ffffffffc0200df4:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200df8:	04098c13          	addi	s8,s3,64
ffffffffc0200dfc:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200dfe:	8b85                	andi	a5,a5,1
ffffffffc0200e00:	3e078463          	beqz	a5,ffffffffc02011e8 <default_check+0x652>
ffffffffc0200e04:	0109a703          	lw	a4,16(s3)
ffffffffc0200e08:	4785                	li	a5,1
ffffffffc0200e0a:	3cf71f63          	bne	a4,a5,ffffffffc02011e8 <default_check+0x652>
ffffffffc0200e0e:	008a3783          	ld	a5,8(s4)
ffffffffc0200e12:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200e14:	8b85                	andi	a5,a5,1
ffffffffc0200e16:	3a078963          	beqz	a5,ffffffffc02011c8 <default_check+0x632>
ffffffffc0200e1a:	010a2703          	lw	a4,16(s4)
ffffffffc0200e1e:	478d                	li	a5,3
ffffffffc0200e20:	3af71463          	bne	a4,a5,ffffffffc02011c8 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200e24:	4505                	li	a0,1
ffffffffc0200e26:	54d000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200e2a:	36a99f63          	bne	s3,a0,ffffffffc02011a8 <default_check+0x612>
    free_page(p0);
ffffffffc0200e2e:	4585                	li	a1,1
ffffffffc0200e30:	5cb000ef          	jal	ra,ffffffffc0201bfa <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200e34:	4509                	li	a0,2
ffffffffc0200e36:	53d000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200e3a:	34aa1763          	bne	s4,a0,ffffffffc0201188 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc0200e3e:	4589                	li	a1,2
ffffffffc0200e40:	5bb000ef          	jal	ra,ffffffffc0201bfa <free_pages>
    free_page(p2);
ffffffffc0200e44:	4585                	li	a1,1
ffffffffc0200e46:	8562                	mv	a0,s8
ffffffffc0200e48:	5b3000ef          	jal	ra,ffffffffc0201bfa <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e4c:	4515                	li	a0,5
ffffffffc0200e4e:	525000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200e52:	89aa                	mv	s3,a0
ffffffffc0200e54:	48050a63          	beqz	a0,ffffffffc02012e8 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0200e58:	4505                	li	a0,1
ffffffffc0200e5a:	519000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200e5e:	2e051563          	bnez	a0,ffffffffc0201148 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc0200e62:	01092783          	lw	a5,16(s2)
ffffffffc0200e66:	2c079163          	bnez	a5,ffffffffc0201128 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200e6a:	4595                	li	a1,5
ffffffffc0200e6c:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200e6e:	00014797          	auipc	a5,0x14
ffffffffc0200e72:	6777a523          	sw	s7,1642(a5) # ffffffffc02154d8 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200e76:	00014797          	auipc	a5,0x14
ffffffffc0200e7a:	6567b923          	sd	s6,1618(a5) # ffffffffc02154c8 <free_area>
ffffffffc0200e7e:	00014797          	auipc	a5,0x14
ffffffffc0200e82:	6557b923          	sd	s5,1618(a5) # ffffffffc02154d0 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200e86:	575000ef          	jal	ra,ffffffffc0201bfa <free_pages>
    return listelm->next;
ffffffffc0200e8a:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e8e:	01278963          	beq	a5,s2,ffffffffc0200ea0 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200e92:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e96:	679c                	ld	a5,8(a5)
ffffffffc0200e98:	34fd                	addiw	s1,s1,-1
ffffffffc0200e9a:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e9c:	ff279be3          	bne	a5,s2,ffffffffc0200e92 <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc0200ea0:	26049463          	bnez	s1,ffffffffc0201108 <default_check+0x572>
    assert(total == 0);
ffffffffc0200ea4:	46041263          	bnez	s0,ffffffffc0201308 <default_check+0x772>
}
ffffffffc0200ea8:	60a6                	ld	ra,72(sp)
ffffffffc0200eaa:	6406                	ld	s0,64(sp)
ffffffffc0200eac:	74e2                	ld	s1,56(sp)
ffffffffc0200eae:	7942                	ld	s2,48(sp)
ffffffffc0200eb0:	79a2                	ld	s3,40(sp)
ffffffffc0200eb2:	7a02                	ld	s4,32(sp)
ffffffffc0200eb4:	6ae2                	ld	s5,24(sp)
ffffffffc0200eb6:	6b42                	ld	s6,16(sp)
ffffffffc0200eb8:	6ba2                	ld	s7,8(sp)
ffffffffc0200eba:	6c02                	ld	s8,0(sp)
ffffffffc0200ebc:	6161                	addi	sp,sp,80
ffffffffc0200ebe:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ec0:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200ec2:	4401                	li	s0,0
ffffffffc0200ec4:	4481                	li	s1,0
ffffffffc0200ec6:	b30d                	j	ffffffffc0200be8 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0200ec8:	00004697          	auipc	a3,0x4
ffffffffc0200ecc:	40068693          	addi	a3,a3,1024 # ffffffffc02052c8 <commands+0x860>
ffffffffc0200ed0:	00004617          	auipc	a2,0x4
ffffffffc0200ed4:	40860613          	addi	a2,a2,1032 # ffffffffc02052d8 <commands+0x870>
ffffffffc0200ed8:	0f000593          	li	a1,240
ffffffffc0200edc:	00004517          	auipc	a0,0x4
ffffffffc0200ee0:	41450513          	addi	a0,a0,1044 # ffffffffc02052f0 <commands+0x888>
ffffffffc0200ee4:	d6cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ee8:	00004697          	auipc	a3,0x4
ffffffffc0200eec:	4a068693          	addi	a3,a3,1184 # ffffffffc0205388 <commands+0x920>
ffffffffc0200ef0:	00004617          	auipc	a2,0x4
ffffffffc0200ef4:	3e860613          	addi	a2,a2,1000 # ffffffffc02052d8 <commands+0x870>
ffffffffc0200ef8:	0bd00593          	li	a1,189
ffffffffc0200efc:	00004517          	auipc	a0,0x4
ffffffffc0200f00:	3f450513          	addi	a0,a0,1012 # ffffffffc02052f0 <commands+0x888>
ffffffffc0200f04:	d4cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200f08:	00004697          	auipc	a3,0x4
ffffffffc0200f0c:	4a868693          	addi	a3,a3,1192 # ffffffffc02053b0 <commands+0x948>
ffffffffc0200f10:	00004617          	auipc	a2,0x4
ffffffffc0200f14:	3c860613          	addi	a2,a2,968 # ffffffffc02052d8 <commands+0x870>
ffffffffc0200f18:	0be00593          	li	a1,190
ffffffffc0200f1c:	00004517          	auipc	a0,0x4
ffffffffc0200f20:	3d450513          	addi	a0,a0,980 # ffffffffc02052f0 <commands+0x888>
ffffffffc0200f24:	d2cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f28:	00004697          	auipc	a3,0x4
ffffffffc0200f2c:	4c868693          	addi	a3,a3,1224 # ffffffffc02053f0 <commands+0x988>
ffffffffc0200f30:	00004617          	auipc	a2,0x4
ffffffffc0200f34:	3a860613          	addi	a2,a2,936 # ffffffffc02052d8 <commands+0x870>
ffffffffc0200f38:	0c000593          	li	a1,192
ffffffffc0200f3c:	00004517          	auipc	a0,0x4
ffffffffc0200f40:	3b450513          	addi	a0,a0,948 # ffffffffc02052f0 <commands+0x888>
ffffffffc0200f44:	d0cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200f48:	00004697          	auipc	a3,0x4
ffffffffc0200f4c:	53068693          	addi	a3,a3,1328 # ffffffffc0205478 <commands+0xa10>
ffffffffc0200f50:	00004617          	auipc	a2,0x4
ffffffffc0200f54:	38860613          	addi	a2,a2,904 # ffffffffc02052d8 <commands+0x870>
ffffffffc0200f58:	0d900593          	li	a1,217
ffffffffc0200f5c:	00004517          	auipc	a0,0x4
ffffffffc0200f60:	39450513          	addi	a0,a0,916 # ffffffffc02052f0 <commands+0x888>
ffffffffc0200f64:	cecff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f68:	00004697          	auipc	a3,0x4
ffffffffc0200f6c:	3c068693          	addi	a3,a3,960 # ffffffffc0205328 <commands+0x8c0>
ffffffffc0200f70:	00004617          	auipc	a2,0x4
ffffffffc0200f74:	36860613          	addi	a2,a2,872 # ffffffffc02052d8 <commands+0x870>
ffffffffc0200f78:	0d200593          	li	a1,210
ffffffffc0200f7c:	00004517          	auipc	a0,0x4
ffffffffc0200f80:	37450513          	addi	a0,a0,884 # ffffffffc02052f0 <commands+0x888>
ffffffffc0200f84:	cccff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free == 3);
ffffffffc0200f88:	00004697          	auipc	a3,0x4
ffffffffc0200f8c:	4e068693          	addi	a3,a3,1248 # ffffffffc0205468 <commands+0xa00>
ffffffffc0200f90:	00004617          	auipc	a2,0x4
ffffffffc0200f94:	34860613          	addi	a2,a2,840 # ffffffffc02052d8 <commands+0x870>
ffffffffc0200f98:	0d000593          	li	a1,208
ffffffffc0200f9c:	00004517          	auipc	a0,0x4
ffffffffc0200fa0:	35450513          	addi	a0,a0,852 # ffffffffc02052f0 <commands+0x888>
ffffffffc0200fa4:	cacff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fa8:	00004697          	auipc	a3,0x4
ffffffffc0200fac:	4a868693          	addi	a3,a3,1192 # ffffffffc0205450 <commands+0x9e8>
ffffffffc0200fb0:	00004617          	auipc	a2,0x4
ffffffffc0200fb4:	32860613          	addi	a2,a2,808 # ffffffffc02052d8 <commands+0x870>
ffffffffc0200fb8:	0cb00593          	li	a1,203
ffffffffc0200fbc:	00004517          	auipc	a0,0x4
ffffffffc0200fc0:	33450513          	addi	a0,a0,820 # ffffffffc02052f0 <commands+0x888>
ffffffffc0200fc4:	c8cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200fc8:	00004697          	auipc	a3,0x4
ffffffffc0200fcc:	46868693          	addi	a3,a3,1128 # ffffffffc0205430 <commands+0x9c8>
ffffffffc0200fd0:	00004617          	auipc	a2,0x4
ffffffffc0200fd4:	30860613          	addi	a2,a2,776 # ffffffffc02052d8 <commands+0x870>
ffffffffc0200fd8:	0c200593          	li	a1,194
ffffffffc0200fdc:	00004517          	auipc	a0,0x4
ffffffffc0200fe0:	31450513          	addi	a0,a0,788 # ffffffffc02052f0 <commands+0x888>
ffffffffc0200fe4:	c6cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(p0 != NULL);
ffffffffc0200fe8:	00004697          	auipc	a3,0x4
ffffffffc0200fec:	4d868693          	addi	a3,a3,1240 # ffffffffc02054c0 <commands+0xa58>
ffffffffc0200ff0:	00004617          	auipc	a2,0x4
ffffffffc0200ff4:	2e860613          	addi	a2,a2,744 # ffffffffc02052d8 <commands+0x870>
ffffffffc0200ff8:	0f800593          	li	a1,248
ffffffffc0200ffc:	00004517          	auipc	a0,0x4
ffffffffc0201000:	2f450513          	addi	a0,a0,756 # ffffffffc02052f0 <commands+0x888>
ffffffffc0201004:	c4cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free == 0);
ffffffffc0201008:	00004697          	auipc	a3,0x4
ffffffffc020100c:	4a868693          	addi	a3,a3,1192 # ffffffffc02054b0 <commands+0xa48>
ffffffffc0201010:	00004617          	auipc	a2,0x4
ffffffffc0201014:	2c860613          	addi	a2,a2,712 # ffffffffc02052d8 <commands+0x870>
ffffffffc0201018:	0df00593          	li	a1,223
ffffffffc020101c:	00004517          	auipc	a0,0x4
ffffffffc0201020:	2d450513          	addi	a0,a0,724 # ffffffffc02052f0 <commands+0x888>
ffffffffc0201024:	c2cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201028:	00004697          	auipc	a3,0x4
ffffffffc020102c:	42868693          	addi	a3,a3,1064 # ffffffffc0205450 <commands+0x9e8>
ffffffffc0201030:	00004617          	auipc	a2,0x4
ffffffffc0201034:	2a860613          	addi	a2,a2,680 # ffffffffc02052d8 <commands+0x870>
ffffffffc0201038:	0dd00593          	li	a1,221
ffffffffc020103c:	00004517          	auipc	a0,0x4
ffffffffc0201040:	2b450513          	addi	a0,a0,692 # ffffffffc02052f0 <commands+0x888>
ffffffffc0201044:	c0cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201048:	00004697          	auipc	a3,0x4
ffffffffc020104c:	44868693          	addi	a3,a3,1096 # ffffffffc0205490 <commands+0xa28>
ffffffffc0201050:	00004617          	auipc	a2,0x4
ffffffffc0201054:	28860613          	addi	a2,a2,648 # ffffffffc02052d8 <commands+0x870>
ffffffffc0201058:	0dc00593          	li	a1,220
ffffffffc020105c:	00004517          	auipc	a0,0x4
ffffffffc0201060:	29450513          	addi	a0,a0,660 # ffffffffc02052f0 <commands+0x888>
ffffffffc0201064:	becff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201068:	00004697          	auipc	a3,0x4
ffffffffc020106c:	2c068693          	addi	a3,a3,704 # ffffffffc0205328 <commands+0x8c0>
ffffffffc0201070:	00004617          	auipc	a2,0x4
ffffffffc0201074:	26860613          	addi	a2,a2,616 # ffffffffc02052d8 <commands+0x870>
ffffffffc0201078:	0b900593          	li	a1,185
ffffffffc020107c:	00004517          	auipc	a0,0x4
ffffffffc0201080:	27450513          	addi	a0,a0,628 # ffffffffc02052f0 <commands+0x888>
ffffffffc0201084:	bccff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201088:	00004697          	auipc	a3,0x4
ffffffffc020108c:	3c868693          	addi	a3,a3,968 # ffffffffc0205450 <commands+0x9e8>
ffffffffc0201090:	00004617          	auipc	a2,0x4
ffffffffc0201094:	24860613          	addi	a2,a2,584 # ffffffffc02052d8 <commands+0x870>
ffffffffc0201098:	0d600593          	li	a1,214
ffffffffc020109c:	00004517          	auipc	a0,0x4
ffffffffc02010a0:	25450513          	addi	a0,a0,596 # ffffffffc02052f0 <commands+0x888>
ffffffffc02010a4:	bacff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02010a8:	00004697          	auipc	a3,0x4
ffffffffc02010ac:	2c068693          	addi	a3,a3,704 # ffffffffc0205368 <commands+0x900>
ffffffffc02010b0:	00004617          	auipc	a2,0x4
ffffffffc02010b4:	22860613          	addi	a2,a2,552 # ffffffffc02052d8 <commands+0x870>
ffffffffc02010b8:	0d400593          	li	a1,212
ffffffffc02010bc:	00004517          	auipc	a0,0x4
ffffffffc02010c0:	23450513          	addi	a0,a0,564 # ffffffffc02052f0 <commands+0x888>
ffffffffc02010c4:	b8cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02010c8:	00004697          	auipc	a3,0x4
ffffffffc02010cc:	28068693          	addi	a3,a3,640 # ffffffffc0205348 <commands+0x8e0>
ffffffffc02010d0:	00004617          	auipc	a2,0x4
ffffffffc02010d4:	20860613          	addi	a2,a2,520 # ffffffffc02052d8 <commands+0x870>
ffffffffc02010d8:	0d300593          	li	a1,211
ffffffffc02010dc:	00004517          	auipc	a0,0x4
ffffffffc02010e0:	21450513          	addi	a0,a0,532 # ffffffffc02052f0 <commands+0x888>
ffffffffc02010e4:	b6cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02010e8:	00004697          	auipc	a3,0x4
ffffffffc02010ec:	28068693          	addi	a3,a3,640 # ffffffffc0205368 <commands+0x900>
ffffffffc02010f0:	00004617          	auipc	a2,0x4
ffffffffc02010f4:	1e860613          	addi	a2,a2,488 # ffffffffc02052d8 <commands+0x870>
ffffffffc02010f8:	0bb00593          	li	a1,187
ffffffffc02010fc:	00004517          	auipc	a0,0x4
ffffffffc0201100:	1f450513          	addi	a0,a0,500 # ffffffffc02052f0 <commands+0x888>
ffffffffc0201104:	b4cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(count == 0);
ffffffffc0201108:	00004697          	auipc	a3,0x4
ffffffffc020110c:	50868693          	addi	a3,a3,1288 # ffffffffc0205610 <commands+0xba8>
ffffffffc0201110:	00004617          	auipc	a2,0x4
ffffffffc0201114:	1c860613          	addi	a2,a2,456 # ffffffffc02052d8 <commands+0x870>
ffffffffc0201118:	12500593          	li	a1,293
ffffffffc020111c:	00004517          	auipc	a0,0x4
ffffffffc0201120:	1d450513          	addi	a0,a0,468 # ffffffffc02052f0 <commands+0x888>
ffffffffc0201124:	b2cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free == 0);
ffffffffc0201128:	00004697          	auipc	a3,0x4
ffffffffc020112c:	38868693          	addi	a3,a3,904 # ffffffffc02054b0 <commands+0xa48>
ffffffffc0201130:	00004617          	auipc	a2,0x4
ffffffffc0201134:	1a860613          	addi	a2,a2,424 # ffffffffc02052d8 <commands+0x870>
ffffffffc0201138:	11a00593          	li	a1,282
ffffffffc020113c:	00004517          	auipc	a0,0x4
ffffffffc0201140:	1b450513          	addi	a0,a0,436 # ffffffffc02052f0 <commands+0x888>
ffffffffc0201144:	b0cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201148:	00004697          	auipc	a3,0x4
ffffffffc020114c:	30868693          	addi	a3,a3,776 # ffffffffc0205450 <commands+0x9e8>
ffffffffc0201150:	00004617          	auipc	a2,0x4
ffffffffc0201154:	18860613          	addi	a2,a2,392 # ffffffffc02052d8 <commands+0x870>
ffffffffc0201158:	11800593          	li	a1,280
ffffffffc020115c:	00004517          	auipc	a0,0x4
ffffffffc0201160:	19450513          	addi	a0,a0,404 # ffffffffc02052f0 <commands+0x888>
ffffffffc0201164:	aecff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201168:	00004697          	auipc	a3,0x4
ffffffffc020116c:	2a868693          	addi	a3,a3,680 # ffffffffc0205410 <commands+0x9a8>
ffffffffc0201170:	00004617          	auipc	a2,0x4
ffffffffc0201174:	16860613          	addi	a2,a2,360 # ffffffffc02052d8 <commands+0x870>
ffffffffc0201178:	0c100593          	li	a1,193
ffffffffc020117c:	00004517          	auipc	a0,0x4
ffffffffc0201180:	17450513          	addi	a0,a0,372 # ffffffffc02052f0 <commands+0x888>
ffffffffc0201184:	accff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201188:	00004697          	auipc	a3,0x4
ffffffffc020118c:	44868693          	addi	a3,a3,1096 # ffffffffc02055d0 <commands+0xb68>
ffffffffc0201190:	00004617          	auipc	a2,0x4
ffffffffc0201194:	14860613          	addi	a2,a2,328 # ffffffffc02052d8 <commands+0x870>
ffffffffc0201198:	11200593          	li	a1,274
ffffffffc020119c:	00004517          	auipc	a0,0x4
ffffffffc02011a0:	15450513          	addi	a0,a0,340 # ffffffffc02052f0 <commands+0x888>
ffffffffc02011a4:	aacff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02011a8:	00004697          	auipc	a3,0x4
ffffffffc02011ac:	40868693          	addi	a3,a3,1032 # ffffffffc02055b0 <commands+0xb48>
ffffffffc02011b0:	00004617          	auipc	a2,0x4
ffffffffc02011b4:	12860613          	addi	a2,a2,296 # ffffffffc02052d8 <commands+0x870>
ffffffffc02011b8:	11000593          	li	a1,272
ffffffffc02011bc:	00004517          	auipc	a0,0x4
ffffffffc02011c0:	13450513          	addi	a0,a0,308 # ffffffffc02052f0 <commands+0x888>
ffffffffc02011c4:	a8cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02011c8:	00004697          	auipc	a3,0x4
ffffffffc02011cc:	3c068693          	addi	a3,a3,960 # ffffffffc0205588 <commands+0xb20>
ffffffffc02011d0:	00004617          	auipc	a2,0x4
ffffffffc02011d4:	10860613          	addi	a2,a2,264 # ffffffffc02052d8 <commands+0x870>
ffffffffc02011d8:	10e00593          	li	a1,270
ffffffffc02011dc:	00004517          	auipc	a0,0x4
ffffffffc02011e0:	11450513          	addi	a0,a0,276 # ffffffffc02052f0 <commands+0x888>
ffffffffc02011e4:	a6cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02011e8:	00004697          	auipc	a3,0x4
ffffffffc02011ec:	37868693          	addi	a3,a3,888 # ffffffffc0205560 <commands+0xaf8>
ffffffffc02011f0:	00004617          	auipc	a2,0x4
ffffffffc02011f4:	0e860613          	addi	a2,a2,232 # ffffffffc02052d8 <commands+0x870>
ffffffffc02011f8:	10d00593          	li	a1,269
ffffffffc02011fc:	00004517          	auipc	a0,0x4
ffffffffc0201200:	0f450513          	addi	a0,a0,244 # ffffffffc02052f0 <commands+0x888>
ffffffffc0201204:	a4cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201208:	00004697          	auipc	a3,0x4
ffffffffc020120c:	34868693          	addi	a3,a3,840 # ffffffffc0205550 <commands+0xae8>
ffffffffc0201210:	00004617          	auipc	a2,0x4
ffffffffc0201214:	0c860613          	addi	a2,a2,200 # ffffffffc02052d8 <commands+0x870>
ffffffffc0201218:	10800593          	li	a1,264
ffffffffc020121c:	00004517          	auipc	a0,0x4
ffffffffc0201220:	0d450513          	addi	a0,a0,212 # ffffffffc02052f0 <commands+0x888>
ffffffffc0201224:	a2cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201228:	00004697          	auipc	a3,0x4
ffffffffc020122c:	22868693          	addi	a3,a3,552 # ffffffffc0205450 <commands+0x9e8>
ffffffffc0201230:	00004617          	auipc	a2,0x4
ffffffffc0201234:	0a860613          	addi	a2,a2,168 # ffffffffc02052d8 <commands+0x870>
ffffffffc0201238:	10700593          	li	a1,263
ffffffffc020123c:	00004517          	auipc	a0,0x4
ffffffffc0201240:	0b450513          	addi	a0,a0,180 # ffffffffc02052f0 <commands+0x888>
ffffffffc0201244:	a0cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201248:	00004697          	auipc	a3,0x4
ffffffffc020124c:	2e868693          	addi	a3,a3,744 # ffffffffc0205530 <commands+0xac8>
ffffffffc0201250:	00004617          	auipc	a2,0x4
ffffffffc0201254:	08860613          	addi	a2,a2,136 # ffffffffc02052d8 <commands+0x870>
ffffffffc0201258:	10600593          	li	a1,262
ffffffffc020125c:	00004517          	auipc	a0,0x4
ffffffffc0201260:	09450513          	addi	a0,a0,148 # ffffffffc02052f0 <commands+0x888>
ffffffffc0201264:	9ecff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201268:	00004697          	auipc	a3,0x4
ffffffffc020126c:	29868693          	addi	a3,a3,664 # ffffffffc0205500 <commands+0xa98>
ffffffffc0201270:	00004617          	auipc	a2,0x4
ffffffffc0201274:	06860613          	addi	a2,a2,104 # ffffffffc02052d8 <commands+0x870>
ffffffffc0201278:	10500593          	li	a1,261
ffffffffc020127c:	00004517          	auipc	a0,0x4
ffffffffc0201280:	07450513          	addi	a0,a0,116 # ffffffffc02052f0 <commands+0x888>
ffffffffc0201284:	9ccff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201288:	00004697          	auipc	a3,0x4
ffffffffc020128c:	26068693          	addi	a3,a3,608 # ffffffffc02054e8 <commands+0xa80>
ffffffffc0201290:	00004617          	auipc	a2,0x4
ffffffffc0201294:	04860613          	addi	a2,a2,72 # ffffffffc02052d8 <commands+0x870>
ffffffffc0201298:	10400593          	li	a1,260
ffffffffc020129c:	00004517          	auipc	a0,0x4
ffffffffc02012a0:	05450513          	addi	a0,a0,84 # ffffffffc02052f0 <commands+0x888>
ffffffffc02012a4:	9acff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012a8:	00004697          	auipc	a3,0x4
ffffffffc02012ac:	1a868693          	addi	a3,a3,424 # ffffffffc0205450 <commands+0x9e8>
ffffffffc02012b0:	00004617          	auipc	a2,0x4
ffffffffc02012b4:	02860613          	addi	a2,a2,40 # ffffffffc02052d8 <commands+0x870>
ffffffffc02012b8:	0fe00593          	li	a1,254
ffffffffc02012bc:	00004517          	auipc	a0,0x4
ffffffffc02012c0:	03450513          	addi	a0,a0,52 # ffffffffc02052f0 <commands+0x888>
ffffffffc02012c4:	98cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(!PageProperty(p0));
ffffffffc02012c8:	00004697          	auipc	a3,0x4
ffffffffc02012cc:	20868693          	addi	a3,a3,520 # ffffffffc02054d0 <commands+0xa68>
ffffffffc02012d0:	00004617          	auipc	a2,0x4
ffffffffc02012d4:	00860613          	addi	a2,a2,8 # ffffffffc02052d8 <commands+0x870>
ffffffffc02012d8:	0f900593          	li	a1,249
ffffffffc02012dc:	00004517          	auipc	a0,0x4
ffffffffc02012e0:	01450513          	addi	a0,a0,20 # ffffffffc02052f0 <commands+0x888>
ffffffffc02012e4:	96cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02012e8:	00004697          	auipc	a3,0x4
ffffffffc02012ec:	30868693          	addi	a3,a3,776 # ffffffffc02055f0 <commands+0xb88>
ffffffffc02012f0:	00004617          	auipc	a2,0x4
ffffffffc02012f4:	fe860613          	addi	a2,a2,-24 # ffffffffc02052d8 <commands+0x870>
ffffffffc02012f8:	11700593          	li	a1,279
ffffffffc02012fc:	00004517          	auipc	a0,0x4
ffffffffc0201300:	ff450513          	addi	a0,a0,-12 # ffffffffc02052f0 <commands+0x888>
ffffffffc0201304:	94cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(total == 0);
ffffffffc0201308:	00004697          	auipc	a3,0x4
ffffffffc020130c:	31868693          	addi	a3,a3,792 # ffffffffc0205620 <commands+0xbb8>
ffffffffc0201310:	00004617          	auipc	a2,0x4
ffffffffc0201314:	fc860613          	addi	a2,a2,-56 # ffffffffc02052d8 <commands+0x870>
ffffffffc0201318:	12600593          	li	a1,294
ffffffffc020131c:	00004517          	auipc	a0,0x4
ffffffffc0201320:	fd450513          	addi	a0,a0,-44 # ffffffffc02052f0 <commands+0x888>
ffffffffc0201324:	92cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201328:	00004697          	auipc	a3,0x4
ffffffffc020132c:	fe068693          	addi	a3,a3,-32 # ffffffffc0205308 <commands+0x8a0>
ffffffffc0201330:	00004617          	auipc	a2,0x4
ffffffffc0201334:	fa860613          	addi	a2,a2,-88 # ffffffffc02052d8 <commands+0x870>
ffffffffc0201338:	0f300593          	li	a1,243
ffffffffc020133c:	00004517          	auipc	a0,0x4
ffffffffc0201340:	fb450513          	addi	a0,a0,-76 # ffffffffc02052f0 <commands+0x888>
ffffffffc0201344:	90cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201348:	00004697          	auipc	a3,0x4
ffffffffc020134c:	00068693          	mv	a3,a3
ffffffffc0201350:	00004617          	auipc	a2,0x4
ffffffffc0201354:	f8860613          	addi	a2,a2,-120 # ffffffffc02052d8 <commands+0x870>
ffffffffc0201358:	0ba00593          	li	a1,186
ffffffffc020135c:	00004517          	auipc	a0,0x4
ffffffffc0201360:	f9450513          	addi	a0,a0,-108 # ffffffffc02052f0 <commands+0x888>
ffffffffc0201364:	8ecff0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201368 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201368:	1141                	addi	sp,sp,-16
ffffffffc020136a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020136c:	16058e63          	beqz	a1,ffffffffc02014e8 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc0201370:	00659693          	slli	a3,a1,0x6
ffffffffc0201374:	96aa                	add	a3,a3,a0
ffffffffc0201376:	02d50d63          	beq	a0,a3,ffffffffc02013b0 <default_free_pages+0x48>
ffffffffc020137a:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020137c:	8b85                	andi	a5,a5,1
ffffffffc020137e:	14079563          	bnez	a5,ffffffffc02014c8 <default_free_pages+0x160>
ffffffffc0201382:	651c                	ld	a5,8(a0)
ffffffffc0201384:	8385                	srli	a5,a5,0x1
ffffffffc0201386:	8b85                	andi	a5,a5,1
ffffffffc0201388:	14079063          	bnez	a5,ffffffffc02014c8 <default_free_pages+0x160>
ffffffffc020138c:	87aa                	mv	a5,a0
ffffffffc020138e:	a809                	j	ffffffffc02013a0 <default_free_pages+0x38>
ffffffffc0201390:	6798                	ld	a4,8(a5)
ffffffffc0201392:	8b05                	andi	a4,a4,1
ffffffffc0201394:	12071a63          	bnez	a4,ffffffffc02014c8 <default_free_pages+0x160>
ffffffffc0201398:	6798                	ld	a4,8(a5)
ffffffffc020139a:	8b09                	andi	a4,a4,2
ffffffffc020139c:	12071663          	bnez	a4,ffffffffc02014c8 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc02013a0:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc02013a4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02013a8:	04078793          	addi	a5,a5,64
ffffffffc02013ac:	fed792e3          	bne	a5,a3,ffffffffc0201390 <default_free_pages+0x28>
    base->property = n;
ffffffffc02013b0:	2581                	sext.w	a1,a1
ffffffffc02013b2:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02013b4:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02013b8:	4789                	li	a5,2
ffffffffc02013ba:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02013be:	00014697          	auipc	a3,0x14
ffffffffc02013c2:	10a68693          	addi	a3,a3,266 # ffffffffc02154c8 <free_area>
ffffffffc02013c6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02013c8:	669c                	ld	a5,8(a3)
ffffffffc02013ca:	9db9                	addw	a1,a1,a4
ffffffffc02013cc:	00014717          	auipc	a4,0x14
ffffffffc02013d0:	10b72623          	sw	a1,268(a4) # ffffffffc02154d8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02013d4:	0cd78163          	beq	a5,a3,ffffffffc0201496 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc02013d8:	fe878713          	addi	a4,a5,-24
ffffffffc02013dc:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02013de:	4801                	li	a6,0
ffffffffc02013e0:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02013e4:	00e56a63          	bltu	a0,a4,ffffffffc02013f8 <default_free_pages+0x90>
    return listelm->next;
ffffffffc02013e8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02013ea:	04d70f63          	beq	a4,a3,ffffffffc0201448 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013ee:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02013f0:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02013f4:	fee57ae3          	bleu	a4,a0,ffffffffc02013e8 <default_free_pages+0x80>
ffffffffc02013f8:	00080663          	beqz	a6,ffffffffc0201404 <default_free_pages+0x9c>
ffffffffc02013fc:	00014817          	auipc	a6,0x14
ffffffffc0201400:	0cb83623          	sd	a1,204(a6) # ffffffffc02154c8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201404:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201406:	e390                	sd	a2,0(a5)
ffffffffc0201408:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc020140a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020140c:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc020140e:	06d58a63          	beq	a1,a3,ffffffffc0201482 <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc0201412:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201416:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc020141a:	02061793          	slli	a5,a2,0x20
ffffffffc020141e:	83e9                	srli	a5,a5,0x1a
ffffffffc0201420:	97ba                	add	a5,a5,a4
ffffffffc0201422:	04f51b63          	bne	a0,a5,ffffffffc0201478 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc0201426:	491c                	lw	a5,16(a0)
ffffffffc0201428:	9e3d                	addw	a2,a2,a5
ffffffffc020142a:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020142e:	57f5                	li	a5,-3
ffffffffc0201430:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201434:	01853803          	ld	a6,24(a0)
ffffffffc0201438:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc020143a:	853a                	mv	a0,a4
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020143c:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc0201440:	659c                	ld	a5,8(a1)
ffffffffc0201442:	01063023          	sd	a6,0(a2)
ffffffffc0201446:	a815                	j	ffffffffc020147a <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc0201448:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020144a:	f114                	sd	a3,32(a0)
ffffffffc020144c:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020144e:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201450:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201452:	00d70563          	beq	a4,a3,ffffffffc020145c <default_free_pages+0xf4>
ffffffffc0201456:	4805                	li	a6,1
ffffffffc0201458:	87ba                	mv	a5,a4
ffffffffc020145a:	bf59                	j	ffffffffc02013f0 <default_free_pages+0x88>
ffffffffc020145c:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020145e:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0201460:	00d78d63          	beq	a5,a3,ffffffffc020147a <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0201464:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201468:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc020146c:	02061793          	slli	a5,a2,0x20
ffffffffc0201470:	83e9                	srli	a5,a5,0x1a
ffffffffc0201472:	97ba                	add	a5,a5,a4
ffffffffc0201474:	faf509e3          	beq	a0,a5,ffffffffc0201426 <default_free_pages+0xbe>
ffffffffc0201478:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc020147a:	fe878713          	addi	a4,a5,-24
ffffffffc020147e:	00d78963          	beq	a5,a3,ffffffffc0201490 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc0201482:	4910                	lw	a2,16(a0)
ffffffffc0201484:	02061693          	slli	a3,a2,0x20
ffffffffc0201488:	82e9                	srli	a3,a3,0x1a
ffffffffc020148a:	96aa                	add	a3,a3,a0
ffffffffc020148c:	00d70e63          	beq	a4,a3,ffffffffc02014a8 <default_free_pages+0x140>
}
ffffffffc0201490:	60a2                	ld	ra,8(sp)
ffffffffc0201492:	0141                	addi	sp,sp,16
ffffffffc0201494:	8082                	ret
ffffffffc0201496:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201498:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020149c:	e398                	sd	a4,0(a5)
ffffffffc020149e:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02014a0:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02014a2:	ed1c                	sd	a5,24(a0)
}
ffffffffc02014a4:	0141                	addi	sp,sp,16
ffffffffc02014a6:	8082                	ret
            base->property += p->property;
ffffffffc02014a8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02014ac:	ff078693          	addi	a3,a5,-16
ffffffffc02014b0:	9e39                	addw	a2,a2,a4
ffffffffc02014b2:	c910                	sw	a2,16(a0)
ffffffffc02014b4:	5775                	li	a4,-3
ffffffffc02014b6:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02014ba:	6398                	ld	a4,0(a5)
ffffffffc02014bc:	679c                	ld	a5,8(a5)
}
ffffffffc02014be:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02014c0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02014c2:	e398                	sd	a4,0(a5)
ffffffffc02014c4:	0141                	addi	sp,sp,16
ffffffffc02014c6:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02014c8:	00004697          	auipc	a3,0x4
ffffffffc02014cc:	16868693          	addi	a3,a3,360 # ffffffffc0205630 <commands+0xbc8>
ffffffffc02014d0:	00004617          	auipc	a2,0x4
ffffffffc02014d4:	e0860613          	addi	a2,a2,-504 # ffffffffc02052d8 <commands+0x870>
ffffffffc02014d8:	08300593          	li	a1,131
ffffffffc02014dc:	00004517          	auipc	a0,0x4
ffffffffc02014e0:	e1450513          	addi	a0,a0,-492 # ffffffffc02052f0 <commands+0x888>
ffffffffc02014e4:	f6dfe0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(n > 0);
ffffffffc02014e8:	00004697          	auipc	a3,0x4
ffffffffc02014ec:	17068693          	addi	a3,a3,368 # ffffffffc0205658 <commands+0xbf0>
ffffffffc02014f0:	00004617          	auipc	a2,0x4
ffffffffc02014f4:	de860613          	addi	a2,a2,-536 # ffffffffc02052d8 <commands+0x870>
ffffffffc02014f8:	08000593          	li	a1,128
ffffffffc02014fc:	00004517          	auipc	a0,0x4
ffffffffc0201500:	df450513          	addi	a0,a0,-524 # ffffffffc02052f0 <commands+0x888>
ffffffffc0201504:	f4dfe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201508 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201508:	c959                	beqz	a0,ffffffffc020159e <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc020150a:	00014597          	auipc	a1,0x14
ffffffffc020150e:	fbe58593          	addi	a1,a1,-66 # ffffffffc02154c8 <free_area>
ffffffffc0201512:	0105a803          	lw	a6,16(a1)
ffffffffc0201516:	862a                	mv	a2,a0
ffffffffc0201518:	02081793          	slli	a5,a6,0x20
ffffffffc020151c:	9381                	srli	a5,a5,0x20
ffffffffc020151e:	00a7ee63          	bltu	a5,a0,ffffffffc020153a <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201522:	87ae                	mv	a5,a1
ffffffffc0201524:	a801                	j	ffffffffc0201534 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201526:	ff87a703          	lw	a4,-8(a5)
ffffffffc020152a:	02071693          	slli	a3,a4,0x20
ffffffffc020152e:	9281                	srli	a3,a3,0x20
ffffffffc0201530:	00c6f763          	bleu	a2,a3,ffffffffc020153e <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201534:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201536:	feb798e3          	bne	a5,a1,ffffffffc0201526 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020153a:	4501                	li	a0,0
}
ffffffffc020153c:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc020153e:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc0201542:	dd6d                	beqz	a0,ffffffffc020153c <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201544:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201548:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc020154c:	00060e1b          	sext.w	t3,a2
ffffffffc0201550:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201554:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201558:	02d67863          	bleu	a3,a2,ffffffffc0201588 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc020155c:	061a                	slli	a2,a2,0x6
ffffffffc020155e:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc0201560:	41c7073b          	subw	a4,a4,t3
ffffffffc0201564:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201566:	00860693          	addi	a3,a2,8
ffffffffc020156a:	4709                	li	a4,2
ffffffffc020156c:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201570:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201574:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0201578:	0105a803          	lw	a6,16(a1)
ffffffffc020157c:	e314                	sd	a3,0(a4)
ffffffffc020157e:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc0201582:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0201584:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0201588:	41c8083b          	subw	a6,a6,t3
ffffffffc020158c:	00014717          	auipc	a4,0x14
ffffffffc0201590:	f5072623          	sw	a6,-180(a4) # ffffffffc02154d8 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201594:	5775                	li	a4,-3
ffffffffc0201596:	17c1                	addi	a5,a5,-16
ffffffffc0201598:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc020159c:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020159e:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02015a0:	00004697          	auipc	a3,0x4
ffffffffc02015a4:	0b868693          	addi	a3,a3,184 # ffffffffc0205658 <commands+0xbf0>
ffffffffc02015a8:	00004617          	auipc	a2,0x4
ffffffffc02015ac:	d3060613          	addi	a2,a2,-720 # ffffffffc02052d8 <commands+0x870>
ffffffffc02015b0:	06200593          	li	a1,98
ffffffffc02015b4:	00004517          	auipc	a0,0x4
ffffffffc02015b8:	d3c50513          	addi	a0,a0,-708 # ffffffffc02052f0 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc02015bc:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02015be:	e93fe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02015c2 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02015c2:	1141                	addi	sp,sp,-16
ffffffffc02015c4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02015c6:	c1ed                	beqz	a1,ffffffffc02016a8 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc02015c8:	00659693          	slli	a3,a1,0x6
ffffffffc02015cc:	96aa                	add	a3,a3,a0
ffffffffc02015ce:	02d50463          	beq	a0,a3,ffffffffc02015f6 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02015d2:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02015d4:	87aa                	mv	a5,a0
ffffffffc02015d6:	8b05                	andi	a4,a4,1
ffffffffc02015d8:	e709                	bnez	a4,ffffffffc02015e2 <default_init_memmap+0x20>
ffffffffc02015da:	a07d                	j	ffffffffc0201688 <default_init_memmap+0xc6>
ffffffffc02015dc:	6798                	ld	a4,8(a5)
ffffffffc02015de:	8b05                	andi	a4,a4,1
ffffffffc02015e0:	c745                	beqz	a4,ffffffffc0201688 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc02015e2:	0007a823          	sw	zero,16(a5)
ffffffffc02015e6:	0007b423          	sd	zero,8(a5)
ffffffffc02015ea:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02015ee:	04078793          	addi	a5,a5,64
ffffffffc02015f2:	fed795e3          	bne	a5,a3,ffffffffc02015dc <default_init_memmap+0x1a>
    base->property = n;
ffffffffc02015f6:	2581                	sext.w	a1,a1
ffffffffc02015f8:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015fa:	4789                	li	a5,2
ffffffffc02015fc:	00850713          	addi	a4,a0,8
ffffffffc0201600:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201604:	00014697          	auipc	a3,0x14
ffffffffc0201608:	ec468693          	addi	a3,a3,-316 # ffffffffc02154c8 <free_area>
ffffffffc020160c:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020160e:	669c                	ld	a5,8(a3)
ffffffffc0201610:	9db9                	addw	a1,a1,a4
ffffffffc0201612:	00014717          	auipc	a4,0x14
ffffffffc0201616:	ecb72323          	sw	a1,-314(a4) # ffffffffc02154d8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020161a:	04d78a63          	beq	a5,a3,ffffffffc020166e <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc020161e:	fe878713          	addi	a4,a5,-24
ffffffffc0201622:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201624:	4801                	li	a6,0
ffffffffc0201626:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc020162a:	00e56a63          	bltu	a0,a4,ffffffffc020163e <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc020162e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201630:	02d70563          	beq	a4,a3,ffffffffc020165a <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201634:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201636:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020163a:	fee57ae3          	bleu	a4,a0,ffffffffc020162e <default_init_memmap+0x6c>
ffffffffc020163e:	00080663          	beqz	a6,ffffffffc020164a <default_init_memmap+0x88>
ffffffffc0201642:	00014717          	auipc	a4,0x14
ffffffffc0201646:	e8b73323          	sd	a1,-378(a4) # ffffffffc02154c8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020164a:	6398                	ld	a4,0(a5)
}
ffffffffc020164c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020164e:	e390                	sd	a2,0(a5)
ffffffffc0201650:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201652:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201654:	ed18                	sd	a4,24(a0)
ffffffffc0201656:	0141                	addi	sp,sp,16
ffffffffc0201658:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020165a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020165c:	f114                	sd	a3,32(a0)
ffffffffc020165e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201660:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201662:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201664:	00d70e63          	beq	a4,a3,ffffffffc0201680 <default_init_memmap+0xbe>
ffffffffc0201668:	4805                	li	a6,1
ffffffffc020166a:	87ba                	mv	a5,a4
ffffffffc020166c:	b7e9                	j	ffffffffc0201636 <default_init_memmap+0x74>
}
ffffffffc020166e:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201670:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201674:	e398                	sd	a4,0(a5)
ffffffffc0201676:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201678:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020167a:	ed1c                	sd	a5,24(a0)
}
ffffffffc020167c:	0141                	addi	sp,sp,16
ffffffffc020167e:	8082                	ret
ffffffffc0201680:	60a2                	ld	ra,8(sp)
ffffffffc0201682:	e290                	sd	a2,0(a3)
ffffffffc0201684:	0141                	addi	sp,sp,16
ffffffffc0201686:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201688:	00004697          	auipc	a3,0x4
ffffffffc020168c:	fd868693          	addi	a3,a3,-40 # ffffffffc0205660 <commands+0xbf8>
ffffffffc0201690:	00004617          	auipc	a2,0x4
ffffffffc0201694:	c4860613          	addi	a2,a2,-952 # ffffffffc02052d8 <commands+0x870>
ffffffffc0201698:	04900593          	li	a1,73
ffffffffc020169c:	00004517          	auipc	a0,0x4
ffffffffc02016a0:	c5450513          	addi	a0,a0,-940 # ffffffffc02052f0 <commands+0x888>
ffffffffc02016a4:	dadfe0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(n > 0);
ffffffffc02016a8:	00004697          	auipc	a3,0x4
ffffffffc02016ac:	fb068693          	addi	a3,a3,-80 # ffffffffc0205658 <commands+0xbf0>
ffffffffc02016b0:	00004617          	auipc	a2,0x4
ffffffffc02016b4:	c2860613          	addi	a2,a2,-984 # ffffffffc02052d8 <commands+0x870>
ffffffffc02016b8:	04600593          	li	a1,70
ffffffffc02016bc:	00004517          	auipc	a0,0x4
ffffffffc02016c0:	c3450513          	addi	a0,a0,-972 # ffffffffc02052f0 <commands+0x888>
ffffffffc02016c4:	d8dfe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02016c8 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02016c8:	c125                	beqz	a0,ffffffffc0201728 <slob_free+0x60>
		return;

	if (size)
ffffffffc02016ca:	e1a5                	bnez	a1,ffffffffc020172a <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016cc:	100027f3          	csrr	a5,sstatus
ffffffffc02016d0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02016d2:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016d4:	e3bd                	bnez	a5,ffffffffc020173a <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02016d6:	00009797          	auipc	a5,0x9
ffffffffc02016da:	97a78793          	addi	a5,a5,-1670 # ffffffffc020a050 <slobfree>
ffffffffc02016de:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02016e0:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02016e2:	00a7fa63          	bleu	a0,a5,ffffffffc02016f6 <slob_free+0x2e>
ffffffffc02016e6:	00e56c63          	bltu	a0,a4,ffffffffc02016fe <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02016ea:	00e7fa63          	bleu	a4,a5,ffffffffc02016fe <slob_free+0x36>
    return 0;
ffffffffc02016ee:	87ba                	mv	a5,a4
ffffffffc02016f0:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02016f2:	fea7eae3          	bltu	a5,a0,ffffffffc02016e6 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02016f6:	fee7ece3          	bltu	a5,a4,ffffffffc02016ee <slob_free+0x26>
ffffffffc02016fa:	fee57ae3          	bleu	a4,a0,ffffffffc02016ee <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc02016fe:	4110                	lw	a2,0(a0)
ffffffffc0201700:	00461693          	slli	a3,a2,0x4
ffffffffc0201704:	96aa                	add	a3,a3,a0
ffffffffc0201706:	08d70b63          	beq	a4,a3,ffffffffc020179c <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc020170a:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc020170c:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc020170e:	00469713          	slli	a4,a3,0x4
ffffffffc0201712:	973e                	add	a4,a4,a5
ffffffffc0201714:	08e50f63          	beq	a0,a4,ffffffffc02017b2 <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201718:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc020171a:	00009717          	auipc	a4,0x9
ffffffffc020171e:	92f73b23          	sd	a5,-1738(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc0201722:	c199                	beqz	a1,ffffffffc0201728 <slob_free+0x60>
        intr_enable();
ffffffffc0201724:	e8bfe06f          	j	ffffffffc02005ae <intr_enable>
ffffffffc0201728:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc020172a:	05bd                	addi	a1,a1,15
ffffffffc020172c:	8191                	srli	a1,a1,0x4
ffffffffc020172e:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201730:	100027f3          	csrr	a5,sstatus
ffffffffc0201734:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201736:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201738:	dfd9                	beqz	a5,ffffffffc02016d6 <slob_free+0xe>
{
ffffffffc020173a:	1101                	addi	sp,sp,-32
ffffffffc020173c:	e42a                	sd	a0,8(sp)
ffffffffc020173e:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201740:	e75fe0ef          	jal	ra,ffffffffc02005b4 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201744:	00009797          	auipc	a5,0x9
ffffffffc0201748:	90c78793          	addi	a5,a5,-1780 # ffffffffc020a050 <slobfree>
ffffffffc020174c:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc020174e:	6522                	ld	a0,8(sp)
ffffffffc0201750:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201752:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201754:	00a7fa63          	bleu	a0,a5,ffffffffc0201768 <slob_free+0xa0>
ffffffffc0201758:	00e56c63          	bltu	a0,a4,ffffffffc0201770 <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020175c:	00e7fa63          	bleu	a4,a5,ffffffffc0201770 <slob_free+0xa8>
    return 0;
ffffffffc0201760:	87ba                	mv	a5,a4
ffffffffc0201762:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201764:	fea7eae3          	bltu	a5,a0,ffffffffc0201758 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201768:	fee7ece3          	bltu	a5,a4,ffffffffc0201760 <slob_free+0x98>
ffffffffc020176c:	fee57ae3          	bleu	a4,a0,ffffffffc0201760 <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0201770:	4110                	lw	a2,0(a0)
ffffffffc0201772:	00461693          	slli	a3,a2,0x4
ffffffffc0201776:	96aa                	add	a3,a3,a0
ffffffffc0201778:	04d70763          	beq	a4,a3,ffffffffc02017c6 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc020177c:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc020177e:	4394                	lw	a3,0(a5)
ffffffffc0201780:	00469713          	slli	a4,a3,0x4
ffffffffc0201784:	973e                	add	a4,a4,a5
ffffffffc0201786:	04e50663          	beq	a0,a4,ffffffffc02017d2 <slob_free+0x10a>
		cur->next = b;
ffffffffc020178a:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc020178c:	00009717          	auipc	a4,0x9
ffffffffc0201790:	8cf73223          	sd	a5,-1852(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc0201794:	e58d                	bnez	a1,ffffffffc02017be <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201796:	60e2                	ld	ra,24(sp)
ffffffffc0201798:	6105                	addi	sp,sp,32
ffffffffc020179a:	8082                	ret
		b->units += cur->next->units;
ffffffffc020179c:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc020179e:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc02017a0:	9e35                	addw	a2,a2,a3
ffffffffc02017a2:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc02017a4:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc02017a6:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02017a8:	00469713          	slli	a4,a3,0x4
ffffffffc02017ac:	973e                	add	a4,a4,a5
ffffffffc02017ae:	f6e515e3          	bne	a0,a4,ffffffffc0201718 <slob_free+0x50>
		cur->units += b->units;
ffffffffc02017b2:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc02017b4:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc02017b6:	9eb9                	addw	a3,a3,a4
ffffffffc02017b8:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc02017ba:	e790                	sd	a2,8(a5)
ffffffffc02017bc:	bfb9                	j	ffffffffc020171a <slob_free+0x52>
}
ffffffffc02017be:	60e2                	ld	ra,24(sp)
ffffffffc02017c0:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02017c2:	dedfe06f          	j	ffffffffc02005ae <intr_enable>
		b->units += cur->next->units;
ffffffffc02017c6:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc02017c8:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc02017ca:	9e35                	addw	a2,a2,a3
ffffffffc02017cc:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc02017ce:	e518                	sd	a4,8(a0)
ffffffffc02017d0:	b77d                	j	ffffffffc020177e <slob_free+0xb6>
		cur->units += b->units;
ffffffffc02017d2:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc02017d4:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc02017d6:	9eb9                	addw	a3,a3,a4
ffffffffc02017d8:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc02017da:	e790                	sd	a2,8(a5)
ffffffffc02017dc:	bf45                	j	ffffffffc020178c <slob_free+0xc4>

ffffffffc02017de <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc02017de:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02017e0:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc02017e2:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02017e6:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc02017e8:	38a000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
  if(!page)
ffffffffc02017ec:	c139                	beqz	a0,ffffffffc0201832 <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc02017ee:	00014797          	auipc	a5,0x14
ffffffffc02017f2:	d0a78793          	addi	a5,a5,-758 # ffffffffc02154f8 <pages>
ffffffffc02017f6:	6394                	ld	a3,0(a5)
ffffffffc02017f8:	00005797          	auipc	a5,0x5
ffffffffc02017fc:	16078793          	addi	a5,a5,352 # ffffffffc0206958 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201800:	00014717          	auipc	a4,0x14
ffffffffc0201804:	c8870713          	addi	a4,a4,-888 # ffffffffc0215488 <npage>
    return page - pages + nbase;
ffffffffc0201808:	40d506b3          	sub	a3,a0,a3
ffffffffc020180c:	6388                	ld	a0,0(a5)
ffffffffc020180e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201810:	57fd                	li	a5,-1
ffffffffc0201812:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0201814:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0201816:	83b1                	srli	a5,a5,0xc
ffffffffc0201818:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020181a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020181c:	00e7ff63          	bleu	a4,a5,ffffffffc020183a <__slob_get_free_pages.isra.0+0x5c>
ffffffffc0201820:	00014797          	auipc	a5,0x14
ffffffffc0201824:	cc878793          	addi	a5,a5,-824 # ffffffffc02154e8 <va_pa_offset>
ffffffffc0201828:	6388                	ld	a0,0(a5)
}
ffffffffc020182a:	60a2                	ld	ra,8(sp)
ffffffffc020182c:	9536                	add	a0,a0,a3
ffffffffc020182e:	0141                	addi	sp,sp,16
ffffffffc0201830:	8082                	ret
ffffffffc0201832:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc0201834:	4501                	li	a0,0
}
ffffffffc0201836:	0141                	addi	sp,sp,16
ffffffffc0201838:	8082                	ret
ffffffffc020183a:	00004617          	auipc	a2,0x4
ffffffffc020183e:	e8660613          	addi	a2,a2,-378 # ffffffffc02056c0 <default_pmm_manager+0x50>
ffffffffc0201842:	06900593          	li	a1,105
ffffffffc0201846:	00004517          	auipc	a0,0x4
ffffffffc020184a:	ea250513          	addi	a0,a0,-350 # ffffffffc02056e8 <default_pmm_manager+0x78>
ffffffffc020184e:	c03fe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201852 <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201852:	7179                	addi	sp,sp,-48
ffffffffc0201854:	f406                	sd	ra,40(sp)
ffffffffc0201856:	f022                	sd	s0,32(sp)
ffffffffc0201858:	ec26                	sd	s1,24(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc020185a:	01050713          	addi	a4,a0,16
ffffffffc020185e:	6785                	lui	a5,0x1
ffffffffc0201860:	0cf77b63          	bleu	a5,a4,ffffffffc0201936 <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201864:	00f50413          	addi	s0,a0,15
ffffffffc0201868:	8011                	srli	s0,s0,0x4
ffffffffc020186a:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020186c:	10002673          	csrr	a2,sstatus
ffffffffc0201870:	8a09                	andi	a2,a2,2
ffffffffc0201872:	ea5d                	bnez	a2,ffffffffc0201928 <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc0201874:	00008497          	auipc	s1,0x8
ffffffffc0201878:	7dc48493          	addi	s1,s1,2012 # ffffffffc020a050 <slobfree>
ffffffffc020187c:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020187e:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201880:	4398                	lw	a4,0(a5)
ffffffffc0201882:	0a875763          	ble	s0,a4,ffffffffc0201930 <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc0201886:	00f68a63          	beq	a3,a5,ffffffffc020189a <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020188a:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020188c:	4118                	lw	a4,0(a0)
ffffffffc020188e:	02875763          	ble	s0,a4,ffffffffc02018bc <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc0201892:	6094                	ld	a3,0(s1)
ffffffffc0201894:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc0201896:	fef69ae3          	bne	a3,a5,ffffffffc020188a <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc020189a:	ea39                	bnez	a2,ffffffffc02018f0 <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc020189c:	4501                	li	a0,0
ffffffffc020189e:	f41ff0ef          	jal	ra,ffffffffc02017de <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc02018a2:	cd29                	beqz	a0,ffffffffc02018fc <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc02018a4:	6585                	lui	a1,0x1
ffffffffc02018a6:	e23ff0ef          	jal	ra,ffffffffc02016c8 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018aa:	10002673          	csrr	a2,sstatus
ffffffffc02018ae:	8a09                	andi	a2,a2,2
ffffffffc02018b0:	ea1d                	bnez	a2,ffffffffc02018e6 <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc02018b2:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02018b4:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02018b6:	4118                	lw	a4,0(a0)
ffffffffc02018b8:	fc874de3          	blt	a4,s0,ffffffffc0201892 <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc02018bc:	04e40663          	beq	s0,a4,ffffffffc0201908 <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc02018c0:	00441693          	slli	a3,s0,0x4
ffffffffc02018c4:	96aa                	add	a3,a3,a0
ffffffffc02018c6:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc02018c8:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc02018ca:	9f01                	subw	a4,a4,s0
ffffffffc02018cc:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc02018ce:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc02018d0:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc02018d2:	00008717          	auipc	a4,0x8
ffffffffc02018d6:	76f73f23          	sd	a5,1918(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc02018da:	ee15                	bnez	a2,ffffffffc0201916 <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc02018dc:	70a2                	ld	ra,40(sp)
ffffffffc02018de:	7402                	ld	s0,32(sp)
ffffffffc02018e0:	64e2                	ld	s1,24(sp)
ffffffffc02018e2:	6145                	addi	sp,sp,48
ffffffffc02018e4:	8082                	ret
        intr_disable();
ffffffffc02018e6:	ccffe0ef          	jal	ra,ffffffffc02005b4 <intr_disable>
ffffffffc02018ea:	4605                	li	a2,1
			cur = slobfree;
ffffffffc02018ec:	609c                	ld	a5,0(s1)
ffffffffc02018ee:	b7d9                	j	ffffffffc02018b4 <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc02018f0:	cbffe0ef          	jal	ra,ffffffffc02005ae <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc02018f4:	4501                	li	a0,0
ffffffffc02018f6:	ee9ff0ef          	jal	ra,ffffffffc02017de <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc02018fa:	f54d                	bnez	a0,ffffffffc02018a4 <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc02018fc:	70a2                	ld	ra,40(sp)
ffffffffc02018fe:	7402                	ld	s0,32(sp)
ffffffffc0201900:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc0201902:	4501                	li	a0,0
}
ffffffffc0201904:	6145                	addi	sp,sp,48
ffffffffc0201906:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201908:	6518                	ld	a4,8(a0)
ffffffffc020190a:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc020190c:	00008717          	auipc	a4,0x8
ffffffffc0201910:	74f73223          	sd	a5,1860(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc0201914:	d661                	beqz	a2,ffffffffc02018dc <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc0201916:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201918:	c97fe0ef          	jal	ra,ffffffffc02005ae <intr_enable>
}
ffffffffc020191c:	70a2                	ld	ra,40(sp)
ffffffffc020191e:	7402                	ld	s0,32(sp)
ffffffffc0201920:	6522                	ld	a0,8(sp)
ffffffffc0201922:	64e2                	ld	s1,24(sp)
ffffffffc0201924:	6145                	addi	sp,sp,48
ffffffffc0201926:	8082                	ret
        intr_disable();
ffffffffc0201928:	c8dfe0ef          	jal	ra,ffffffffc02005b4 <intr_disable>
ffffffffc020192c:	4605                	li	a2,1
ffffffffc020192e:	b799                	j	ffffffffc0201874 <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201930:	853e                	mv	a0,a5
ffffffffc0201932:	87b6                	mv	a5,a3
ffffffffc0201934:	b761                	j	ffffffffc02018bc <slob_alloc.isra.1.constprop.3+0x6a>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201936:	00004697          	auipc	a3,0x4
ffffffffc020193a:	e2a68693          	addi	a3,a3,-470 # ffffffffc0205760 <default_pmm_manager+0xf0>
ffffffffc020193e:	00004617          	auipc	a2,0x4
ffffffffc0201942:	99a60613          	addi	a2,a2,-1638 # ffffffffc02052d8 <commands+0x870>
ffffffffc0201946:	06300593          	li	a1,99
ffffffffc020194a:	00004517          	auipc	a0,0x4
ffffffffc020194e:	e3650513          	addi	a0,a0,-458 # ffffffffc0205780 <default_pmm_manager+0x110>
ffffffffc0201952:	afffe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201956 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201956:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201958:	00004517          	auipc	a0,0x4
ffffffffc020195c:	e4050513          	addi	a0,a0,-448 # ffffffffc0205798 <default_pmm_manager+0x128>
kmalloc_init(void) {
ffffffffc0201960:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201962:	82dfe0ef          	jal	ra,ffffffffc020018e <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201966:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201968:	00004517          	auipc	a0,0x4
ffffffffc020196c:	dd850513          	addi	a0,a0,-552 # ffffffffc0205740 <default_pmm_manager+0xd0>
}
ffffffffc0201970:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201972:	81dfe06f          	j	ffffffffc020018e <cprintf>

ffffffffc0201976 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201976:	1101                	addi	sp,sp,-32
ffffffffc0201978:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc020197a:	6905                	lui	s2,0x1
{
ffffffffc020197c:	e822                	sd	s0,16(sp)
ffffffffc020197e:	ec06                	sd	ra,24(sp)
ffffffffc0201980:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201982:	fef90793          	addi	a5,s2,-17 # fef <BASE_ADDRESS-0xffffffffc01ff011>
{
ffffffffc0201986:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201988:	04a7fc63          	bleu	a0,a5,ffffffffc02019e0 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc020198c:	4561                	li	a0,24
ffffffffc020198e:	ec5ff0ef          	jal	ra,ffffffffc0201852 <slob_alloc.isra.1.constprop.3>
ffffffffc0201992:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201994:	cd21                	beqz	a0,ffffffffc02019ec <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0201996:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc020199a:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc020199c:	00f95763          	ble	a5,s2,ffffffffc02019aa <kmalloc+0x34>
ffffffffc02019a0:	6705                	lui	a4,0x1
ffffffffc02019a2:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc02019a4:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc02019a6:	fef74ee3          	blt	a4,a5,ffffffffc02019a2 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc02019aa:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc02019ac:	e33ff0ef          	jal	ra,ffffffffc02017de <__slob_get_free_pages.isra.0>
ffffffffc02019b0:	e488                	sd	a0,8(s1)
ffffffffc02019b2:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc02019b4:	c935                	beqz	a0,ffffffffc0201a28 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019b6:	100027f3          	csrr	a5,sstatus
ffffffffc02019ba:	8b89                	andi	a5,a5,2
ffffffffc02019bc:	e3a1                	bnez	a5,ffffffffc02019fc <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc02019be:	00014797          	auipc	a5,0x14
ffffffffc02019c2:	aba78793          	addi	a5,a5,-1350 # ffffffffc0215478 <bigblocks>
ffffffffc02019c6:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc02019c8:	00014717          	auipc	a4,0x14
ffffffffc02019cc:	aa973823          	sd	s1,-1360(a4) # ffffffffc0215478 <bigblocks>
		bb->next = bigblocks;
ffffffffc02019d0:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc02019d2:	8522                	mv	a0,s0
ffffffffc02019d4:	60e2                	ld	ra,24(sp)
ffffffffc02019d6:	6442                	ld	s0,16(sp)
ffffffffc02019d8:	64a2                	ld	s1,8(sp)
ffffffffc02019da:	6902                	ld	s2,0(sp)
ffffffffc02019dc:	6105                	addi	sp,sp,32
ffffffffc02019de:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc02019e0:	0541                	addi	a0,a0,16
ffffffffc02019e2:	e71ff0ef          	jal	ra,ffffffffc0201852 <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc02019e6:	01050413          	addi	s0,a0,16
ffffffffc02019ea:	f565                	bnez	a0,ffffffffc02019d2 <kmalloc+0x5c>
ffffffffc02019ec:	4401                	li	s0,0
}
ffffffffc02019ee:	8522                	mv	a0,s0
ffffffffc02019f0:	60e2                	ld	ra,24(sp)
ffffffffc02019f2:	6442                	ld	s0,16(sp)
ffffffffc02019f4:	64a2                	ld	s1,8(sp)
ffffffffc02019f6:	6902                	ld	s2,0(sp)
ffffffffc02019f8:	6105                	addi	sp,sp,32
ffffffffc02019fa:	8082                	ret
        intr_disable();
ffffffffc02019fc:	bb9fe0ef          	jal	ra,ffffffffc02005b4 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201a00:	00014797          	auipc	a5,0x14
ffffffffc0201a04:	a7878793          	addi	a5,a5,-1416 # ffffffffc0215478 <bigblocks>
ffffffffc0201a08:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201a0a:	00014717          	auipc	a4,0x14
ffffffffc0201a0e:	a6973723          	sd	s1,-1426(a4) # ffffffffc0215478 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201a12:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201a14:	b9bfe0ef          	jal	ra,ffffffffc02005ae <intr_enable>
ffffffffc0201a18:	6480                	ld	s0,8(s1)
}
ffffffffc0201a1a:	60e2                	ld	ra,24(sp)
ffffffffc0201a1c:	64a2                	ld	s1,8(sp)
ffffffffc0201a1e:	8522                	mv	a0,s0
ffffffffc0201a20:	6442                	ld	s0,16(sp)
ffffffffc0201a22:	6902                	ld	s2,0(sp)
ffffffffc0201a24:	6105                	addi	sp,sp,32
ffffffffc0201a26:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201a28:	45e1                	li	a1,24
ffffffffc0201a2a:	8526                	mv	a0,s1
ffffffffc0201a2c:	c9dff0ef          	jal	ra,ffffffffc02016c8 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201a30:	b74d                	j	ffffffffc02019d2 <kmalloc+0x5c>

ffffffffc0201a32 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201a32:	c175                	beqz	a0,ffffffffc0201b16 <kfree+0xe4>
{
ffffffffc0201a34:	1101                	addi	sp,sp,-32
ffffffffc0201a36:	e426                	sd	s1,8(sp)
ffffffffc0201a38:	ec06                	sd	ra,24(sp)
ffffffffc0201a3a:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201a3c:	03451793          	slli	a5,a0,0x34
ffffffffc0201a40:	84aa                	mv	s1,a0
ffffffffc0201a42:	eb8d                	bnez	a5,ffffffffc0201a74 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a44:	100027f3          	csrr	a5,sstatus
ffffffffc0201a48:	8b89                	andi	a5,a5,2
ffffffffc0201a4a:	efc9                	bnez	a5,ffffffffc0201ae4 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201a4c:	00014797          	auipc	a5,0x14
ffffffffc0201a50:	a2c78793          	addi	a5,a5,-1492 # ffffffffc0215478 <bigblocks>
ffffffffc0201a54:	6394                	ld	a3,0(a5)
ffffffffc0201a56:	ce99                	beqz	a3,ffffffffc0201a74 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201a58:	669c                	ld	a5,8(a3)
ffffffffc0201a5a:	6a80                	ld	s0,16(a3)
ffffffffc0201a5c:	0af50e63          	beq	a0,a5,ffffffffc0201b18 <kfree+0xe6>
    return 0;
ffffffffc0201a60:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201a62:	c801                	beqz	s0,ffffffffc0201a72 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0201a64:	6418                	ld	a4,8(s0)
ffffffffc0201a66:	681c                	ld	a5,16(s0)
ffffffffc0201a68:	00970f63          	beq	a4,s1,ffffffffc0201a86 <kfree+0x54>
ffffffffc0201a6c:	86a2                	mv	a3,s0
ffffffffc0201a6e:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201a70:	f875                	bnez	s0,ffffffffc0201a64 <kfree+0x32>
    if (flag) {
ffffffffc0201a72:	e659                	bnez	a2,ffffffffc0201b00 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201a74:	6442                	ld	s0,16(sp)
ffffffffc0201a76:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201a78:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201a7c:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201a7e:	4581                	li	a1,0
}
ffffffffc0201a80:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201a82:	c47ff06f          	j	ffffffffc02016c8 <slob_free>
				*last = bb->next;
ffffffffc0201a86:	ea9c                	sd	a5,16(a3)
ffffffffc0201a88:	e641                	bnez	a2,ffffffffc0201b10 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0201a8a:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201a8e:	4018                	lw	a4,0(s0)
ffffffffc0201a90:	08f4ea63          	bltu	s1,a5,ffffffffc0201b24 <kfree+0xf2>
ffffffffc0201a94:	00014797          	auipc	a5,0x14
ffffffffc0201a98:	a5478793          	addi	a5,a5,-1452 # ffffffffc02154e8 <va_pa_offset>
ffffffffc0201a9c:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201a9e:	00014797          	auipc	a5,0x14
ffffffffc0201aa2:	9ea78793          	addi	a5,a5,-1558 # ffffffffc0215488 <npage>
ffffffffc0201aa6:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201aa8:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201aaa:	80b1                	srli	s1,s1,0xc
ffffffffc0201aac:	08f4f963          	bleu	a5,s1,ffffffffc0201b3e <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ab0:	00005797          	auipc	a5,0x5
ffffffffc0201ab4:	ea878793          	addi	a5,a5,-344 # ffffffffc0206958 <nbase>
ffffffffc0201ab8:	639c                	ld	a5,0(a5)
ffffffffc0201aba:	00014697          	auipc	a3,0x14
ffffffffc0201abe:	a3e68693          	addi	a3,a3,-1474 # ffffffffc02154f8 <pages>
ffffffffc0201ac2:	6288                	ld	a0,0(a3)
ffffffffc0201ac4:	8c9d                	sub	s1,s1,a5
ffffffffc0201ac6:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201ac8:	4585                	li	a1,1
ffffffffc0201aca:	9526                	add	a0,a0,s1
ffffffffc0201acc:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201ad0:	12a000ef          	jal	ra,ffffffffc0201bfa <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201ad4:	8522                	mv	a0,s0
}
ffffffffc0201ad6:	6442                	ld	s0,16(sp)
ffffffffc0201ad8:	60e2                	ld	ra,24(sp)
ffffffffc0201ada:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201adc:	45e1                	li	a1,24
}
ffffffffc0201ade:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201ae0:	be9ff06f          	j	ffffffffc02016c8 <slob_free>
        intr_disable();
ffffffffc0201ae4:	ad1fe0ef          	jal	ra,ffffffffc02005b4 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201ae8:	00014797          	auipc	a5,0x14
ffffffffc0201aec:	99078793          	addi	a5,a5,-1648 # ffffffffc0215478 <bigblocks>
ffffffffc0201af0:	6394                	ld	a3,0(a5)
ffffffffc0201af2:	c699                	beqz	a3,ffffffffc0201b00 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0201af4:	669c                	ld	a5,8(a3)
ffffffffc0201af6:	6a80                	ld	s0,16(a3)
ffffffffc0201af8:	00f48763          	beq	s1,a5,ffffffffc0201b06 <kfree+0xd4>
        return 1;
ffffffffc0201afc:	4605                	li	a2,1
ffffffffc0201afe:	b795                	j	ffffffffc0201a62 <kfree+0x30>
        intr_enable();
ffffffffc0201b00:	aaffe0ef          	jal	ra,ffffffffc02005ae <intr_enable>
ffffffffc0201b04:	bf85                	j	ffffffffc0201a74 <kfree+0x42>
				*last = bb->next;
ffffffffc0201b06:	00014797          	auipc	a5,0x14
ffffffffc0201b0a:	9687b923          	sd	s0,-1678(a5) # ffffffffc0215478 <bigblocks>
ffffffffc0201b0e:	8436                	mv	s0,a3
ffffffffc0201b10:	a9ffe0ef          	jal	ra,ffffffffc02005ae <intr_enable>
ffffffffc0201b14:	bf9d                	j	ffffffffc0201a8a <kfree+0x58>
ffffffffc0201b16:	8082                	ret
ffffffffc0201b18:	00014797          	auipc	a5,0x14
ffffffffc0201b1c:	9687b023          	sd	s0,-1696(a5) # ffffffffc0215478 <bigblocks>
ffffffffc0201b20:	8436                	mv	s0,a3
ffffffffc0201b22:	b7a5                	j	ffffffffc0201a8a <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0201b24:	86a6                	mv	a3,s1
ffffffffc0201b26:	00004617          	auipc	a2,0x4
ffffffffc0201b2a:	bd260613          	addi	a2,a2,-1070 # ffffffffc02056f8 <default_pmm_manager+0x88>
ffffffffc0201b2e:	06e00593          	li	a1,110
ffffffffc0201b32:	00004517          	auipc	a0,0x4
ffffffffc0201b36:	bb650513          	addi	a0,a0,-1098 # ffffffffc02056e8 <default_pmm_manager+0x78>
ffffffffc0201b3a:	917fe0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201b3e:	00004617          	auipc	a2,0x4
ffffffffc0201b42:	be260613          	addi	a2,a2,-1054 # ffffffffc0205720 <default_pmm_manager+0xb0>
ffffffffc0201b46:	06200593          	li	a1,98
ffffffffc0201b4a:	00004517          	auipc	a0,0x4
ffffffffc0201b4e:	b9e50513          	addi	a0,a0,-1122 # ffffffffc02056e8 <default_pmm_manager+0x78>
ffffffffc0201b52:	8fffe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201b56 <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0201b56:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201b58:	00004617          	auipc	a2,0x4
ffffffffc0201b5c:	bc860613          	addi	a2,a2,-1080 # ffffffffc0205720 <default_pmm_manager+0xb0>
ffffffffc0201b60:	06200593          	li	a1,98
ffffffffc0201b64:	00004517          	auipc	a0,0x4
ffffffffc0201b68:	b8450513          	addi	a0,a0,-1148 # ffffffffc02056e8 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201b6c:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201b6e:	8e3fe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201b72 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201b72:	715d                	addi	sp,sp,-80
ffffffffc0201b74:	e0a2                	sd	s0,64(sp)
ffffffffc0201b76:	fc26                	sd	s1,56(sp)
ffffffffc0201b78:	f84a                	sd	s2,48(sp)
ffffffffc0201b7a:	f44e                	sd	s3,40(sp)
ffffffffc0201b7c:	f052                	sd	s4,32(sp)
ffffffffc0201b7e:	ec56                	sd	s5,24(sp)
ffffffffc0201b80:	e486                	sd	ra,72(sp)
ffffffffc0201b82:	842a                	mv	s0,a0
ffffffffc0201b84:	00014497          	auipc	s1,0x14
ffffffffc0201b88:	95c48493          	addi	s1,s1,-1700 # ffffffffc02154e0 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201b8c:	4985                	li	s3,1
ffffffffc0201b8e:	00014a17          	auipc	s4,0x14
ffffffffc0201b92:	90aa0a13          	addi	s4,s4,-1782 # ffffffffc0215498 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201b96:	0005091b          	sext.w	s2,a0
ffffffffc0201b9a:	00014a97          	auipc	s5,0x14
ffffffffc0201b9e:	a3ea8a93          	addi	s5,s5,-1474 # ffffffffc02155d8 <check_mm_struct>
ffffffffc0201ba2:	a00d                	j	ffffffffc0201bc4 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201ba4:	609c                	ld	a5,0(s1)
ffffffffc0201ba6:	6f9c                	ld	a5,24(a5)
ffffffffc0201ba8:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201baa:	4601                	li	a2,0
ffffffffc0201bac:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201bae:	ed0d                	bnez	a0,ffffffffc0201be8 <alloc_pages+0x76>
ffffffffc0201bb0:	0289ec63          	bltu	s3,s0,ffffffffc0201be8 <alloc_pages+0x76>
ffffffffc0201bb4:	000a2783          	lw	a5,0(s4)
ffffffffc0201bb8:	2781                	sext.w	a5,a5
ffffffffc0201bba:	c79d                	beqz	a5,ffffffffc0201be8 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201bbc:	000ab503          	ld	a0,0(s5)
ffffffffc0201bc0:	6dc010ef          	jal	ra,ffffffffc020329c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201bc4:	100027f3          	csrr	a5,sstatus
ffffffffc0201bc8:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201bca:	8522                	mv	a0,s0
ffffffffc0201bcc:	dfe1                	beqz	a5,ffffffffc0201ba4 <alloc_pages+0x32>
        intr_disable();
ffffffffc0201bce:	9e7fe0ef          	jal	ra,ffffffffc02005b4 <intr_disable>
ffffffffc0201bd2:	609c                	ld	a5,0(s1)
ffffffffc0201bd4:	8522                	mv	a0,s0
ffffffffc0201bd6:	6f9c                	ld	a5,24(a5)
ffffffffc0201bd8:	9782                	jalr	a5
ffffffffc0201bda:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201bdc:	9d3fe0ef          	jal	ra,ffffffffc02005ae <intr_enable>
ffffffffc0201be0:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0201be2:	4601                	li	a2,0
ffffffffc0201be4:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201be6:	d569                	beqz	a0,ffffffffc0201bb0 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201be8:	60a6                	ld	ra,72(sp)
ffffffffc0201bea:	6406                	ld	s0,64(sp)
ffffffffc0201bec:	74e2                	ld	s1,56(sp)
ffffffffc0201bee:	7942                	ld	s2,48(sp)
ffffffffc0201bf0:	79a2                	ld	s3,40(sp)
ffffffffc0201bf2:	7a02                	ld	s4,32(sp)
ffffffffc0201bf4:	6ae2                	ld	s5,24(sp)
ffffffffc0201bf6:	6161                	addi	sp,sp,80
ffffffffc0201bf8:	8082                	ret

ffffffffc0201bfa <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201bfa:	100027f3          	csrr	a5,sstatus
ffffffffc0201bfe:	8b89                	andi	a5,a5,2
ffffffffc0201c00:	eb89                	bnez	a5,ffffffffc0201c12 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201c02:	00014797          	auipc	a5,0x14
ffffffffc0201c06:	8de78793          	addi	a5,a5,-1826 # ffffffffc02154e0 <pmm_manager>
ffffffffc0201c0a:	639c                	ld	a5,0(a5)
ffffffffc0201c0c:	0207b303          	ld	t1,32(a5)
ffffffffc0201c10:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201c12:	1101                	addi	sp,sp,-32
ffffffffc0201c14:	ec06                	sd	ra,24(sp)
ffffffffc0201c16:	e822                	sd	s0,16(sp)
ffffffffc0201c18:	e426                	sd	s1,8(sp)
ffffffffc0201c1a:	842a                	mv	s0,a0
ffffffffc0201c1c:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201c1e:	997fe0ef          	jal	ra,ffffffffc02005b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201c22:	00014797          	auipc	a5,0x14
ffffffffc0201c26:	8be78793          	addi	a5,a5,-1858 # ffffffffc02154e0 <pmm_manager>
ffffffffc0201c2a:	639c                	ld	a5,0(a5)
ffffffffc0201c2c:	85a6                	mv	a1,s1
ffffffffc0201c2e:	8522                	mv	a0,s0
ffffffffc0201c30:	739c                	ld	a5,32(a5)
ffffffffc0201c32:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201c34:	6442                	ld	s0,16(sp)
ffffffffc0201c36:	60e2                	ld	ra,24(sp)
ffffffffc0201c38:	64a2                	ld	s1,8(sp)
ffffffffc0201c3a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201c3c:	973fe06f          	j	ffffffffc02005ae <intr_enable>

ffffffffc0201c40 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c40:	100027f3          	csrr	a5,sstatus
ffffffffc0201c44:	8b89                	andi	a5,a5,2
ffffffffc0201c46:	eb89                	bnez	a5,ffffffffc0201c58 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201c48:	00014797          	auipc	a5,0x14
ffffffffc0201c4c:	89878793          	addi	a5,a5,-1896 # ffffffffc02154e0 <pmm_manager>
ffffffffc0201c50:	639c                	ld	a5,0(a5)
ffffffffc0201c52:	0287b303          	ld	t1,40(a5)
ffffffffc0201c56:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201c58:	1141                	addi	sp,sp,-16
ffffffffc0201c5a:	e406                	sd	ra,8(sp)
ffffffffc0201c5c:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201c5e:	957fe0ef          	jal	ra,ffffffffc02005b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201c62:	00014797          	auipc	a5,0x14
ffffffffc0201c66:	87e78793          	addi	a5,a5,-1922 # ffffffffc02154e0 <pmm_manager>
ffffffffc0201c6a:	639c                	ld	a5,0(a5)
ffffffffc0201c6c:	779c                	ld	a5,40(a5)
ffffffffc0201c6e:	9782                	jalr	a5
ffffffffc0201c70:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201c72:	93dfe0ef          	jal	ra,ffffffffc02005ae <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201c76:	8522                	mv	a0,s0
ffffffffc0201c78:	60a2                	ld	ra,8(sp)
ffffffffc0201c7a:	6402                	ld	s0,0(sp)
ffffffffc0201c7c:	0141                	addi	sp,sp,16
ffffffffc0201c7e:	8082                	ret

ffffffffc0201c80 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201c80:	7139                	addi	sp,sp,-64
ffffffffc0201c82:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201c84:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201c88:	1ff4f493          	andi	s1,s1,511
ffffffffc0201c8c:	048e                	slli	s1,s1,0x3
ffffffffc0201c8e:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201c90:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201c92:	f04a                	sd	s2,32(sp)
ffffffffc0201c94:	ec4e                	sd	s3,24(sp)
ffffffffc0201c96:	e852                	sd	s4,16(sp)
ffffffffc0201c98:	fc06                	sd	ra,56(sp)
ffffffffc0201c9a:	f822                	sd	s0,48(sp)
ffffffffc0201c9c:	e456                	sd	s5,8(sp)
ffffffffc0201c9e:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201ca0:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201ca4:	892e                	mv	s2,a1
ffffffffc0201ca6:	8a32                	mv	s4,a2
ffffffffc0201ca8:	00013997          	auipc	s3,0x13
ffffffffc0201cac:	7e098993          	addi	s3,s3,2016 # ffffffffc0215488 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201cb0:	e7bd                	bnez	a5,ffffffffc0201d1e <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201cb2:	12060c63          	beqz	a2,ffffffffc0201dea <get_pte+0x16a>
ffffffffc0201cb6:	4505                	li	a0,1
ffffffffc0201cb8:	ebbff0ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0201cbc:	842a                	mv	s0,a0
ffffffffc0201cbe:	12050663          	beqz	a0,ffffffffc0201dea <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201cc2:	00014b17          	auipc	s6,0x14
ffffffffc0201cc6:	836b0b13          	addi	s6,s6,-1994 # ffffffffc02154f8 <pages>
ffffffffc0201cca:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0201cce:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201cd0:	00013997          	auipc	s3,0x13
ffffffffc0201cd4:	7b898993          	addi	s3,s3,1976 # ffffffffc0215488 <npage>
    return page - pages + nbase;
ffffffffc0201cd8:	40a40533          	sub	a0,s0,a0
ffffffffc0201cdc:	00080ab7          	lui	s5,0x80
ffffffffc0201ce0:	8519                	srai	a0,a0,0x6
ffffffffc0201ce2:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0201ce6:	c01c                	sw	a5,0(s0)
ffffffffc0201ce8:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201cea:	9556                	add	a0,a0,s5
ffffffffc0201cec:	83b1                	srli	a5,a5,0xc
ffffffffc0201cee:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201cf0:	0532                	slli	a0,a0,0xc
ffffffffc0201cf2:	14e7f363          	bleu	a4,a5,ffffffffc0201e38 <get_pte+0x1b8>
ffffffffc0201cf6:	00013797          	auipc	a5,0x13
ffffffffc0201cfa:	7f278793          	addi	a5,a5,2034 # ffffffffc02154e8 <va_pa_offset>
ffffffffc0201cfe:	639c                	ld	a5,0(a5)
ffffffffc0201d00:	6605                	lui	a2,0x1
ffffffffc0201d02:	4581                	li	a1,0
ffffffffc0201d04:	953e                	add	a0,a0,a5
ffffffffc0201d06:	3d5020ef          	jal	ra,ffffffffc02048da <memset>
    return page - pages + nbase;
ffffffffc0201d0a:	000b3683          	ld	a3,0(s6)
ffffffffc0201d0e:	40d406b3          	sub	a3,s0,a3
ffffffffc0201d12:	8699                	srai	a3,a3,0x6
ffffffffc0201d14:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201d16:	06aa                	slli	a3,a3,0xa
ffffffffc0201d18:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201d1c:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201d1e:	77fd                	lui	a5,0xfffff
ffffffffc0201d20:	068a                	slli	a3,a3,0x2
ffffffffc0201d22:	0009b703          	ld	a4,0(s3)
ffffffffc0201d26:	8efd                	and	a3,a3,a5
ffffffffc0201d28:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201d2c:	0ce7f163          	bleu	a4,a5,ffffffffc0201dee <get_pte+0x16e>
ffffffffc0201d30:	00013a97          	auipc	s5,0x13
ffffffffc0201d34:	7b8a8a93          	addi	s5,s5,1976 # ffffffffc02154e8 <va_pa_offset>
ffffffffc0201d38:	000ab403          	ld	s0,0(s5)
ffffffffc0201d3c:	01595793          	srli	a5,s2,0x15
ffffffffc0201d40:	1ff7f793          	andi	a5,a5,511
ffffffffc0201d44:	96a2                	add	a3,a3,s0
ffffffffc0201d46:	00379413          	slli	s0,a5,0x3
ffffffffc0201d4a:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201d4c:	6014                	ld	a3,0(s0)
ffffffffc0201d4e:	0016f793          	andi	a5,a3,1
ffffffffc0201d52:	e3ad                	bnez	a5,ffffffffc0201db4 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201d54:	080a0b63          	beqz	s4,ffffffffc0201dea <get_pte+0x16a>
ffffffffc0201d58:	4505                	li	a0,1
ffffffffc0201d5a:	e19ff0ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0201d5e:	84aa                	mv	s1,a0
ffffffffc0201d60:	c549                	beqz	a0,ffffffffc0201dea <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201d62:	00013b17          	auipc	s6,0x13
ffffffffc0201d66:	796b0b13          	addi	s6,s6,1942 # ffffffffc02154f8 <pages>
ffffffffc0201d6a:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0201d6e:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc0201d70:	00080a37          	lui	s4,0x80
ffffffffc0201d74:	40a48533          	sub	a0,s1,a0
ffffffffc0201d78:	8519                	srai	a0,a0,0x6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201d7a:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0201d7e:	c09c                	sw	a5,0(s1)
ffffffffc0201d80:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201d82:	9552                	add	a0,a0,s4
ffffffffc0201d84:	83b1                	srli	a5,a5,0xc
ffffffffc0201d86:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201d88:	0532                	slli	a0,a0,0xc
ffffffffc0201d8a:	08e7fa63          	bleu	a4,a5,ffffffffc0201e1e <get_pte+0x19e>
ffffffffc0201d8e:	000ab783          	ld	a5,0(s5)
ffffffffc0201d92:	6605                	lui	a2,0x1
ffffffffc0201d94:	4581                	li	a1,0
ffffffffc0201d96:	953e                	add	a0,a0,a5
ffffffffc0201d98:	343020ef          	jal	ra,ffffffffc02048da <memset>
    return page - pages + nbase;
ffffffffc0201d9c:	000b3683          	ld	a3,0(s6)
ffffffffc0201da0:	40d486b3          	sub	a3,s1,a3
ffffffffc0201da4:	8699                	srai	a3,a3,0x6
ffffffffc0201da6:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201da8:	06aa                	slli	a3,a3,0xa
ffffffffc0201daa:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201dae:	e014                	sd	a3,0(s0)
ffffffffc0201db0:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201db4:	068a                	slli	a3,a3,0x2
ffffffffc0201db6:	757d                	lui	a0,0xfffff
ffffffffc0201db8:	8ee9                	and	a3,a3,a0
ffffffffc0201dba:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201dbe:	04e7f463          	bleu	a4,a5,ffffffffc0201e06 <get_pte+0x186>
ffffffffc0201dc2:	000ab503          	ld	a0,0(s5)
ffffffffc0201dc6:	00c95793          	srli	a5,s2,0xc
ffffffffc0201dca:	1ff7f793          	andi	a5,a5,511
ffffffffc0201dce:	96aa                	add	a3,a3,a0
ffffffffc0201dd0:	00379513          	slli	a0,a5,0x3
ffffffffc0201dd4:	9536                	add	a0,a0,a3
}
ffffffffc0201dd6:	70e2                	ld	ra,56(sp)
ffffffffc0201dd8:	7442                	ld	s0,48(sp)
ffffffffc0201dda:	74a2                	ld	s1,40(sp)
ffffffffc0201ddc:	7902                	ld	s2,32(sp)
ffffffffc0201dde:	69e2                	ld	s3,24(sp)
ffffffffc0201de0:	6a42                	ld	s4,16(sp)
ffffffffc0201de2:	6aa2                	ld	s5,8(sp)
ffffffffc0201de4:	6b02                	ld	s6,0(sp)
ffffffffc0201de6:	6121                	addi	sp,sp,64
ffffffffc0201de8:	8082                	ret
            return NULL;
ffffffffc0201dea:	4501                	li	a0,0
ffffffffc0201dec:	b7ed                	j	ffffffffc0201dd6 <get_pte+0x156>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201dee:	00004617          	auipc	a2,0x4
ffffffffc0201df2:	8d260613          	addi	a2,a2,-1838 # ffffffffc02056c0 <default_pmm_manager+0x50>
ffffffffc0201df6:	0e400593          	li	a1,228
ffffffffc0201dfa:	00004517          	auipc	a0,0x4
ffffffffc0201dfe:	9b650513          	addi	a0,a0,-1610 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc0201e02:	e4efe0ef          	jal	ra,ffffffffc0200450 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201e06:	00004617          	auipc	a2,0x4
ffffffffc0201e0a:	8ba60613          	addi	a2,a2,-1862 # ffffffffc02056c0 <default_pmm_manager+0x50>
ffffffffc0201e0e:	0ef00593          	li	a1,239
ffffffffc0201e12:	00004517          	auipc	a0,0x4
ffffffffc0201e16:	99e50513          	addi	a0,a0,-1634 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc0201e1a:	e36fe0ef          	jal	ra,ffffffffc0200450 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e1e:	86aa                	mv	a3,a0
ffffffffc0201e20:	00004617          	auipc	a2,0x4
ffffffffc0201e24:	8a060613          	addi	a2,a2,-1888 # ffffffffc02056c0 <default_pmm_manager+0x50>
ffffffffc0201e28:	0ec00593          	li	a1,236
ffffffffc0201e2c:	00004517          	auipc	a0,0x4
ffffffffc0201e30:	98450513          	addi	a0,a0,-1660 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc0201e34:	e1cfe0ef          	jal	ra,ffffffffc0200450 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e38:	86aa                	mv	a3,a0
ffffffffc0201e3a:	00004617          	auipc	a2,0x4
ffffffffc0201e3e:	88660613          	addi	a2,a2,-1914 # ffffffffc02056c0 <default_pmm_manager+0x50>
ffffffffc0201e42:	0e100593          	li	a1,225
ffffffffc0201e46:	00004517          	auipc	a0,0x4
ffffffffc0201e4a:	96a50513          	addi	a0,a0,-1686 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc0201e4e:	e02fe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201e52 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201e52:	1141                	addi	sp,sp,-16
ffffffffc0201e54:	e022                	sd	s0,0(sp)
ffffffffc0201e56:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201e58:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201e5a:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201e5c:	e25ff0ef          	jal	ra,ffffffffc0201c80 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201e60:	c011                	beqz	s0,ffffffffc0201e64 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201e62:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201e64:	c129                	beqz	a0,ffffffffc0201ea6 <get_page+0x54>
ffffffffc0201e66:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201e68:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201e6a:	0017f713          	andi	a4,a5,1
ffffffffc0201e6e:	e709                	bnez	a4,ffffffffc0201e78 <get_page+0x26>
}
ffffffffc0201e70:	60a2                	ld	ra,8(sp)
ffffffffc0201e72:	6402                	ld	s0,0(sp)
ffffffffc0201e74:	0141                	addi	sp,sp,16
ffffffffc0201e76:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201e78:	00013717          	auipc	a4,0x13
ffffffffc0201e7c:	61070713          	addi	a4,a4,1552 # ffffffffc0215488 <npage>
ffffffffc0201e80:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201e82:	078a                	slli	a5,a5,0x2
ffffffffc0201e84:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e86:	02e7f563          	bleu	a4,a5,ffffffffc0201eb0 <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e8a:	00013717          	auipc	a4,0x13
ffffffffc0201e8e:	66e70713          	addi	a4,a4,1646 # ffffffffc02154f8 <pages>
ffffffffc0201e92:	6308                	ld	a0,0(a4)
ffffffffc0201e94:	60a2                	ld	ra,8(sp)
ffffffffc0201e96:	6402                	ld	s0,0(sp)
ffffffffc0201e98:	fff80737          	lui	a4,0xfff80
ffffffffc0201e9c:	97ba                	add	a5,a5,a4
ffffffffc0201e9e:	079a                	slli	a5,a5,0x6
ffffffffc0201ea0:	953e                	add	a0,a0,a5
ffffffffc0201ea2:	0141                	addi	sp,sp,16
ffffffffc0201ea4:	8082                	ret
ffffffffc0201ea6:	60a2                	ld	ra,8(sp)
ffffffffc0201ea8:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0201eaa:	4501                	li	a0,0
}
ffffffffc0201eac:	0141                	addi	sp,sp,16
ffffffffc0201eae:	8082                	ret
ffffffffc0201eb0:	ca7ff0ef          	jal	ra,ffffffffc0201b56 <pa2page.part.4>

ffffffffc0201eb4 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201eb4:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201eb6:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201eb8:	e426                	sd	s1,8(sp)
ffffffffc0201eba:	ec06                	sd	ra,24(sp)
ffffffffc0201ebc:	e822                	sd	s0,16(sp)
ffffffffc0201ebe:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201ec0:	dc1ff0ef          	jal	ra,ffffffffc0201c80 <get_pte>
    if (ptep != NULL) {
ffffffffc0201ec4:	c511                	beqz	a0,ffffffffc0201ed0 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201ec6:	611c                	ld	a5,0(a0)
ffffffffc0201ec8:	842a                	mv	s0,a0
ffffffffc0201eca:	0017f713          	andi	a4,a5,1
ffffffffc0201ece:	e711                	bnez	a4,ffffffffc0201eda <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201ed0:	60e2                	ld	ra,24(sp)
ffffffffc0201ed2:	6442                	ld	s0,16(sp)
ffffffffc0201ed4:	64a2                	ld	s1,8(sp)
ffffffffc0201ed6:	6105                	addi	sp,sp,32
ffffffffc0201ed8:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201eda:	00013717          	auipc	a4,0x13
ffffffffc0201ede:	5ae70713          	addi	a4,a4,1454 # ffffffffc0215488 <npage>
ffffffffc0201ee2:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ee4:	078a                	slli	a5,a5,0x2
ffffffffc0201ee6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ee8:	02e7fe63          	bleu	a4,a5,ffffffffc0201f24 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0201eec:	00013717          	auipc	a4,0x13
ffffffffc0201ef0:	60c70713          	addi	a4,a4,1548 # ffffffffc02154f8 <pages>
ffffffffc0201ef4:	6308                	ld	a0,0(a4)
ffffffffc0201ef6:	fff80737          	lui	a4,0xfff80
ffffffffc0201efa:	97ba                	add	a5,a5,a4
ffffffffc0201efc:	079a                	slli	a5,a5,0x6
ffffffffc0201efe:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201f00:	411c                	lw	a5,0(a0)
ffffffffc0201f02:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201f06:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201f08:	cb11                	beqz	a4,ffffffffc0201f1c <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201f0a:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201f0e:	12048073          	sfence.vma	s1
}
ffffffffc0201f12:	60e2                	ld	ra,24(sp)
ffffffffc0201f14:	6442                	ld	s0,16(sp)
ffffffffc0201f16:	64a2                	ld	s1,8(sp)
ffffffffc0201f18:	6105                	addi	sp,sp,32
ffffffffc0201f1a:	8082                	ret
            free_page(page);
ffffffffc0201f1c:	4585                	li	a1,1
ffffffffc0201f1e:	cddff0ef          	jal	ra,ffffffffc0201bfa <free_pages>
ffffffffc0201f22:	b7e5                	j	ffffffffc0201f0a <page_remove+0x56>
ffffffffc0201f24:	c33ff0ef          	jal	ra,ffffffffc0201b56 <pa2page.part.4>

ffffffffc0201f28 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201f28:	7179                	addi	sp,sp,-48
ffffffffc0201f2a:	e44e                	sd	s3,8(sp)
ffffffffc0201f2c:	89b2                	mv	s3,a2
ffffffffc0201f2e:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201f30:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201f32:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201f34:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201f36:	ec26                	sd	s1,24(sp)
ffffffffc0201f38:	f406                	sd	ra,40(sp)
ffffffffc0201f3a:	e84a                	sd	s2,16(sp)
ffffffffc0201f3c:	e052                	sd	s4,0(sp)
ffffffffc0201f3e:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201f40:	d41ff0ef          	jal	ra,ffffffffc0201c80 <get_pte>
    if (ptep == NULL) {
ffffffffc0201f44:	cd49                	beqz	a0,ffffffffc0201fde <page_insert+0xb6>
    page->ref += 1;
ffffffffc0201f46:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0201f48:	611c                	ld	a5,0(a0)
ffffffffc0201f4a:	892a                	mv	s2,a0
ffffffffc0201f4c:	0016871b          	addiw	a4,a3,1
ffffffffc0201f50:	c018                	sw	a4,0(s0)
ffffffffc0201f52:	0017f713          	andi	a4,a5,1
ffffffffc0201f56:	ef05                	bnez	a4,ffffffffc0201f8e <page_insert+0x66>
ffffffffc0201f58:	00013797          	auipc	a5,0x13
ffffffffc0201f5c:	5a078793          	addi	a5,a5,1440 # ffffffffc02154f8 <pages>
ffffffffc0201f60:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc0201f62:	8c19                	sub	s0,s0,a4
ffffffffc0201f64:	000806b7          	lui	a3,0x80
ffffffffc0201f68:	8419                	srai	s0,s0,0x6
ffffffffc0201f6a:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201f6c:	042a                	slli	s0,s0,0xa
ffffffffc0201f6e:	8c45                	or	s0,s0,s1
ffffffffc0201f70:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201f74:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201f78:	12098073          	sfence.vma	s3
    return 0;
ffffffffc0201f7c:	4501                	li	a0,0
}
ffffffffc0201f7e:	70a2                	ld	ra,40(sp)
ffffffffc0201f80:	7402                	ld	s0,32(sp)
ffffffffc0201f82:	64e2                	ld	s1,24(sp)
ffffffffc0201f84:	6942                	ld	s2,16(sp)
ffffffffc0201f86:	69a2                	ld	s3,8(sp)
ffffffffc0201f88:	6a02                	ld	s4,0(sp)
ffffffffc0201f8a:	6145                	addi	sp,sp,48
ffffffffc0201f8c:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201f8e:	00013717          	auipc	a4,0x13
ffffffffc0201f92:	4fa70713          	addi	a4,a4,1274 # ffffffffc0215488 <npage>
ffffffffc0201f96:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201f98:	078a                	slli	a5,a5,0x2
ffffffffc0201f9a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f9c:	04e7f363          	bleu	a4,a5,ffffffffc0201fe2 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc0201fa0:	00013a17          	auipc	s4,0x13
ffffffffc0201fa4:	558a0a13          	addi	s4,s4,1368 # ffffffffc02154f8 <pages>
ffffffffc0201fa8:	000a3703          	ld	a4,0(s4)
ffffffffc0201fac:	fff80537          	lui	a0,0xfff80
ffffffffc0201fb0:	953e                	add	a0,a0,a5
ffffffffc0201fb2:	051a                	slli	a0,a0,0x6
ffffffffc0201fb4:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc0201fb6:	00a40a63          	beq	s0,a0,ffffffffc0201fca <page_insert+0xa2>
    page->ref -= 1;
ffffffffc0201fba:	411c                	lw	a5,0(a0)
ffffffffc0201fbc:	fff7869b          	addiw	a3,a5,-1
ffffffffc0201fc0:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0201fc2:	c691                	beqz	a3,ffffffffc0201fce <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201fc4:	12098073          	sfence.vma	s3
ffffffffc0201fc8:	bf69                	j	ffffffffc0201f62 <page_insert+0x3a>
ffffffffc0201fca:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201fcc:	bf59                	j	ffffffffc0201f62 <page_insert+0x3a>
            free_page(page);
ffffffffc0201fce:	4585                	li	a1,1
ffffffffc0201fd0:	c2bff0ef          	jal	ra,ffffffffc0201bfa <free_pages>
ffffffffc0201fd4:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201fd8:	12098073          	sfence.vma	s3
ffffffffc0201fdc:	b759                	j	ffffffffc0201f62 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0201fde:	5571                	li	a0,-4
ffffffffc0201fe0:	bf79                	j	ffffffffc0201f7e <page_insert+0x56>
ffffffffc0201fe2:	b75ff0ef          	jal	ra,ffffffffc0201b56 <pa2page.part.4>

ffffffffc0201fe6 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201fe6:	00003797          	auipc	a5,0x3
ffffffffc0201fea:	68a78793          	addi	a5,a5,1674 # ffffffffc0205670 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201fee:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201ff0:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201ff2:	00003517          	auipc	a0,0x3
ffffffffc0201ff6:	7e650513          	addi	a0,a0,2022 # ffffffffc02057d8 <default_pmm_manager+0x168>
void pmm_init(void) {
ffffffffc0201ffa:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201ffc:	00013717          	auipc	a4,0x13
ffffffffc0202000:	4ef73223          	sd	a5,1252(a4) # ffffffffc02154e0 <pmm_manager>
void pmm_init(void) {
ffffffffc0202004:	e0a2                	sd	s0,64(sp)
ffffffffc0202006:	fc26                	sd	s1,56(sp)
ffffffffc0202008:	f84a                	sd	s2,48(sp)
ffffffffc020200a:	f44e                	sd	s3,40(sp)
ffffffffc020200c:	f052                	sd	s4,32(sp)
ffffffffc020200e:	ec56                	sd	s5,24(sp)
ffffffffc0202010:	e85a                	sd	s6,16(sp)
ffffffffc0202012:	e45e                	sd	s7,8(sp)
ffffffffc0202014:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202016:	00013417          	auipc	s0,0x13
ffffffffc020201a:	4ca40413          	addi	s0,s0,1226 # ffffffffc02154e0 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020201e:	970fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    pmm_manager->init();
ffffffffc0202022:	601c                	ld	a5,0(s0)
ffffffffc0202024:	00013497          	auipc	s1,0x13
ffffffffc0202028:	46448493          	addi	s1,s1,1124 # ffffffffc0215488 <npage>
ffffffffc020202c:	00013917          	auipc	s2,0x13
ffffffffc0202030:	4cc90913          	addi	s2,s2,1228 # ffffffffc02154f8 <pages>
ffffffffc0202034:	679c                	ld	a5,8(a5)
ffffffffc0202036:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202038:	57f5                	li	a5,-3
ffffffffc020203a:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020203c:	00003517          	auipc	a0,0x3
ffffffffc0202040:	7b450513          	addi	a0,a0,1972 # ffffffffc02057f0 <default_pmm_manager+0x180>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202044:	00013717          	auipc	a4,0x13
ffffffffc0202048:	4af73223          	sd	a5,1188(a4) # ffffffffc02154e8 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020204c:	942fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202050:	46c5                	li	a3,17
ffffffffc0202052:	06ee                	slli	a3,a3,0x1b
ffffffffc0202054:	40100613          	li	a2,1025
ffffffffc0202058:	16fd                	addi	a3,a3,-1
ffffffffc020205a:	0656                	slli	a2,a2,0x15
ffffffffc020205c:	07e005b7          	lui	a1,0x7e00
ffffffffc0202060:	00003517          	auipc	a0,0x3
ffffffffc0202064:	7a850513          	addi	a0,a0,1960 # ffffffffc0205808 <default_pmm_manager+0x198>
ffffffffc0202068:	926fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020206c:	777d                	lui	a4,0xfffff
ffffffffc020206e:	00014797          	auipc	a5,0x14
ffffffffc0202072:	58178793          	addi	a5,a5,1409 # ffffffffc02165ef <end+0xfff>
ffffffffc0202076:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0202078:	00088737          	lui	a4,0x88
ffffffffc020207c:	00013697          	auipc	a3,0x13
ffffffffc0202080:	40e6b623          	sd	a4,1036(a3) # ffffffffc0215488 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202084:	00013717          	auipc	a4,0x13
ffffffffc0202088:	46f73a23          	sd	a5,1140(a4) # ffffffffc02154f8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020208c:	4701                	li	a4,0
ffffffffc020208e:	4685                	li	a3,1
ffffffffc0202090:	fff80837          	lui	a6,0xfff80
ffffffffc0202094:	a019                	j	ffffffffc020209a <pmm_init+0xb4>
ffffffffc0202096:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc020209a:	00671613          	slli	a2,a4,0x6
ffffffffc020209e:	97b2                	add	a5,a5,a2
ffffffffc02020a0:	07a1                	addi	a5,a5,8
ffffffffc02020a2:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02020a6:	6090                	ld	a2,0(s1)
ffffffffc02020a8:	0705                	addi	a4,a4,1
ffffffffc02020aa:	010607b3          	add	a5,a2,a6
ffffffffc02020ae:	fef764e3          	bltu	a4,a5,ffffffffc0202096 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02020b2:	00093503          	ld	a0,0(s2)
ffffffffc02020b6:	fe0007b7          	lui	a5,0xfe000
ffffffffc02020ba:	00661693          	slli	a3,a2,0x6
ffffffffc02020be:	97aa                	add	a5,a5,a0
ffffffffc02020c0:	96be                	add	a3,a3,a5
ffffffffc02020c2:	c02007b7          	lui	a5,0xc0200
ffffffffc02020c6:	7af6ed63          	bltu	a3,a5,ffffffffc0202880 <pmm_init+0x89a>
ffffffffc02020ca:	00013997          	auipc	s3,0x13
ffffffffc02020ce:	41e98993          	addi	s3,s3,1054 # ffffffffc02154e8 <va_pa_offset>
ffffffffc02020d2:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc02020d6:	47c5                	li	a5,17
ffffffffc02020d8:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02020da:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc02020dc:	02f6f763          	bleu	a5,a3,ffffffffc020210a <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02020e0:	6585                	lui	a1,0x1
ffffffffc02020e2:	15fd                	addi	a1,a1,-1
ffffffffc02020e4:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc02020e6:	00c6d713          	srli	a4,a3,0xc
ffffffffc02020ea:	48c77a63          	bleu	a2,a4,ffffffffc020257e <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc02020ee:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020f0:	75fd                	lui	a1,0xfffff
ffffffffc02020f2:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc02020f4:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc02020f6:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020f8:	40d786b3          	sub	a3,a5,a3
ffffffffc02020fc:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc02020fe:	00c6d593          	srli	a1,a3,0xc
ffffffffc0202102:	953a                	add	a0,a0,a4
ffffffffc0202104:	9602                	jalr	a2
ffffffffc0202106:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc020210a:	00003517          	auipc	a0,0x3
ffffffffc020210e:	72650513          	addi	a0,a0,1830 # ffffffffc0205830 <default_pmm_manager+0x1c0>
ffffffffc0202112:	87cfe0ef          	jal	ra,ffffffffc020018e <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202116:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202118:	00013417          	auipc	s0,0x13
ffffffffc020211c:	36840413          	addi	s0,s0,872 # ffffffffc0215480 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202120:	7b9c                	ld	a5,48(a5)
ffffffffc0202122:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202124:	00003517          	auipc	a0,0x3
ffffffffc0202128:	72450513          	addi	a0,a0,1828 # ffffffffc0205848 <default_pmm_manager+0x1d8>
ffffffffc020212c:	862fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202130:	00007697          	auipc	a3,0x7
ffffffffc0202134:	ed068693          	addi	a3,a3,-304 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0202138:	00013797          	auipc	a5,0x13
ffffffffc020213c:	34d7b423          	sd	a3,840(a5) # ffffffffc0215480 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202140:	c02007b7          	lui	a5,0xc0200
ffffffffc0202144:	10f6eae3          	bltu	a3,a5,ffffffffc0202a58 <pmm_init+0xa72>
ffffffffc0202148:	0009b783          	ld	a5,0(s3)
ffffffffc020214c:	8e9d                	sub	a3,a3,a5
ffffffffc020214e:	00013797          	auipc	a5,0x13
ffffffffc0202152:	3ad7b123          	sd	a3,930(a5) # ffffffffc02154f0 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0202156:	aebff0ef          	jal	ra,ffffffffc0201c40 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020215a:	6098                	ld	a4,0(s1)
ffffffffc020215c:	c80007b7          	lui	a5,0xc8000
ffffffffc0202160:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0202162:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202164:	0ce7eae3          	bltu	a5,a4,ffffffffc0202a38 <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202168:	6008                	ld	a0,0(s0)
ffffffffc020216a:	44050463          	beqz	a0,ffffffffc02025b2 <pmm_init+0x5cc>
ffffffffc020216e:	6785                	lui	a5,0x1
ffffffffc0202170:	17fd                	addi	a5,a5,-1
ffffffffc0202172:	8fe9                	and	a5,a5,a0
ffffffffc0202174:	2781                	sext.w	a5,a5
ffffffffc0202176:	42079e63          	bnez	a5,ffffffffc02025b2 <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020217a:	4601                	li	a2,0
ffffffffc020217c:	4581                	li	a1,0
ffffffffc020217e:	cd5ff0ef          	jal	ra,ffffffffc0201e52 <get_page>
ffffffffc0202182:	78051b63          	bnez	a0,ffffffffc0202918 <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0202186:	4505                	li	a0,1
ffffffffc0202188:	9ebff0ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc020218c:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020218e:	6008                	ld	a0,0(s0)
ffffffffc0202190:	4681                	li	a3,0
ffffffffc0202192:	4601                	li	a2,0
ffffffffc0202194:	85d6                	mv	a1,s5
ffffffffc0202196:	d93ff0ef          	jal	ra,ffffffffc0201f28 <page_insert>
ffffffffc020219a:	7a051f63          	bnez	a0,ffffffffc0202958 <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020219e:	6008                	ld	a0,0(s0)
ffffffffc02021a0:	4601                	li	a2,0
ffffffffc02021a2:	4581                	li	a1,0
ffffffffc02021a4:	addff0ef          	jal	ra,ffffffffc0201c80 <get_pte>
ffffffffc02021a8:	78050863          	beqz	a0,ffffffffc0202938 <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc02021ac:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02021ae:	0017f713          	andi	a4,a5,1
ffffffffc02021b2:	3e070463          	beqz	a4,ffffffffc020259a <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc02021b6:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02021b8:	078a                	slli	a5,a5,0x2
ffffffffc02021ba:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02021bc:	3ce7f163          	bleu	a4,a5,ffffffffc020257e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02021c0:	00093683          	ld	a3,0(s2)
ffffffffc02021c4:	fff80637          	lui	a2,0xfff80
ffffffffc02021c8:	97b2                	add	a5,a5,a2
ffffffffc02021ca:	079a                	slli	a5,a5,0x6
ffffffffc02021cc:	97b6                	add	a5,a5,a3
ffffffffc02021ce:	72fa9563          	bne	s5,a5,ffffffffc02028f8 <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc02021d2:	000aab83          	lw	s7,0(s5)
ffffffffc02021d6:	4785                	li	a5,1
ffffffffc02021d8:	70fb9063          	bne	s7,a5,ffffffffc02028d8 <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02021dc:	6008                	ld	a0,0(s0)
ffffffffc02021de:	76fd                	lui	a3,0xfffff
ffffffffc02021e0:	611c                	ld	a5,0(a0)
ffffffffc02021e2:	078a                	slli	a5,a5,0x2
ffffffffc02021e4:	8ff5                	and	a5,a5,a3
ffffffffc02021e6:	00c7d613          	srli	a2,a5,0xc
ffffffffc02021ea:	66e67e63          	bleu	a4,a2,ffffffffc0202866 <pmm_init+0x880>
ffffffffc02021ee:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02021f2:	97e2                	add	a5,a5,s8
ffffffffc02021f4:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc02021f8:	0b0a                	slli	s6,s6,0x2
ffffffffc02021fa:	00db7b33          	and	s6,s6,a3
ffffffffc02021fe:	00cb5793          	srli	a5,s6,0xc
ffffffffc0202202:	56e7f863          	bleu	a4,a5,ffffffffc0202772 <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202206:	4601                	li	a2,0
ffffffffc0202208:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020220a:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020220c:	a75ff0ef          	jal	ra,ffffffffc0201c80 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202210:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202212:	55651063          	bne	a0,s6,ffffffffc0202752 <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc0202216:	4505                	li	a0,1
ffffffffc0202218:	95bff0ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc020221c:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020221e:	6008                	ld	a0,0(s0)
ffffffffc0202220:	46d1                	li	a3,20
ffffffffc0202222:	6605                	lui	a2,0x1
ffffffffc0202224:	85da                	mv	a1,s6
ffffffffc0202226:	d03ff0ef          	jal	ra,ffffffffc0201f28 <page_insert>
ffffffffc020222a:	50051463          	bnez	a0,ffffffffc0202732 <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020222e:	6008                	ld	a0,0(s0)
ffffffffc0202230:	4601                	li	a2,0
ffffffffc0202232:	6585                	lui	a1,0x1
ffffffffc0202234:	a4dff0ef          	jal	ra,ffffffffc0201c80 <get_pte>
ffffffffc0202238:	4c050d63          	beqz	a0,ffffffffc0202712 <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc020223c:	611c                	ld	a5,0(a0)
ffffffffc020223e:	0107f713          	andi	a4,a5,16
ffffffffc0202242:	4a070863          	beqz	a4,ffffffffc02026f2 <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc0202246:	8b91                	andi	a5,a5,4
ffffffffc0202248:	48078563          	beqz	a5,ffffffffc02026d2 <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020224c:	6008                	ld	a0,0(s0)
ffffffffc020224e:	611c                	ld	a5,0(a0)
ffffffffc0202250:	8bc1                	andi	a5,a5,16
ffffffffc0202252:	46078063          	beqz	a5,ffffffffc02026b2 <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc0202256:	000b2783          	lw	a5,0(s6)
ffffffffc020225a:	43779c63          	bne	a5,s7,ffffffffc0202692 <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020225e:	4681                	li	a3,0
ffffffffc0202260:	6605                	lui	a2,0x1
ffffffffc0202262:	85d6                	mv	a1,s5
ffffffffc0202264:	cc5ff0ef          	jal	ra,ffffffffc0201f28 <page_insert>
ffffffffc0202268:	40051563          	bnez	a0,ffffffffc0202672 <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc020226c:	000aa703          	lw	a4,0(s5)
ffffffffc0202270:	4789                	li	a5,2
ffffffffc0202272:	3ef71063          	bne	a4,a5,ffffffffc0202652 <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc0202276:	000b2783          	lw	a5,0(s6)
ffffffffc020227a:	3a079c63          	bnez	a5,ffffffffc0202632 <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020227e:	6008                	ld	a0,0(s0)
ffffffffc0202280:	4601                	li	a2,0
ffffffffc0202282:	6585                	lui	a1,0x1
ffffffffc0202284:	9fdff0ef          	jal	ra,ffffffffc0201c80 <get_pte>
ffffffffc0202288:	38050563          	beqz	a0,ffffffffc0202612 <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc020228c:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020228e:	00177793          	andi	a5,a4,1
ffffffffc0202292:	30078463          	beqz	a5,ffffffffc020259a <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc0202296:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202298:	00271793          	slli	a5,a4,0x2
ffffffffc020229c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020229e:	2ed7f063          	bleu	a3,a5,ffffffffc020257e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02022a2:	00093683          	ld	a3,0(s2)
ffffffffc02022a6:	fff80637          	lui	a2,0xfff80
ffffffffc02022aa:	97b2                	add	a5,a5,a2
ffffffffc02022ac:	079a                	slli	a5,a5,0x6
ffffffffc02022ae:	97b6                	add	a5,a5,a3
ffffffffc02022b0:	32fa9163          	bne	s5,a5,ffffffffc02025d2 <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc02022b4:	8b41                	andi	a4,a4,16
ffffffffc02022b6:	70071163          	bnez	a4,ffffffffc02029b8 <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc02022ba:	6008                	ld	a0,0(s0)
ffffffffc02022bc:	4581                	li	a1,0
ffffffffc02022be:	bf7ff0ef          	jal	ra,ffffffffc0201eb4 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02022c2:	000aa703          	lw	a4,0(s5)
ffffffffc02022c6:	4785                	li	a5,1
ffffffffc02022c8:	6cf71863          	bne	a4,a5,ffffffffc0202998 <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc02022cc:	000b2783          	lw	a5,0(s6)
ffffffffc02022d0:	6a079463          	bnez	a5,ffffffffc0202978 <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02022d4:	6008                	ld	a0,0(s0)
ffffffffc02022d6:	6585                	lui	a1,0x1
ffffffffc02022d8:	bddff0ef          	jal	ra,ffffffffc0201eb4 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02022dc:	000aa783          	lw	a5,0(s5)
ffffffffc02022e0:	50079363          	bnez	a5,ffffffffc02027e6 <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc02022e4:	000b2783          	lw	a5,0(s6)
ffffffffc02022e8:	4c079f63          	bnez	a5,ffffffffc02027c6 <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02022ec:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02022f0:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02022f2:	000ab783          	ld	a5,0(s5)
ffffffffc02022f6:	078a                	slli	a5,a5,0x2
ffffffffc02022f8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02022fa:	28c7f263          	bleu	a2,a5,ffffffffc020257e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02022fe:	fff80737          	lui	a4,0xfff80
ffffffffc0202302:	00093503          	ld	a0,0(s2)
ffffffffc0202306:	97ba                	add	a5,a5,a4
ffffffffc0202308:	079a                	slli	a5,a5,0x6
ffffffffc020230a:	00f50733          	add	a4,a0,a5
ffffffffc020230e:	4314                	lw	a3,0(a4)
ffffffffc0202310:	4705                	li	a4,1
ffffffffc0202312:	48e69a63          	bne	a3,a4,ffffffffc02027a6 <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc0202316:	8799                	srai	a5,a5,0x6
ffffffffc0202318:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc020231c:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc020231e:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc0202320:	8331                	srli	a4,a4,0xc
ffffffffc0202322:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202324:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202326:	46c77363          	bleu	a2,a4,ffffffffc020278c <pmm_init+0x7a6>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020232a:	0009b683          	ld	a3,0(s3)
ffffffffc020232e:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0202330:	639c                	ld	a5,0(a5)
ffffffffc0202332:	078a                	slli	a5,a5,0x2
ffffffffc0202334:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202336:	24c7f463          	bleu	a2,a5,ffffffffc020257e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020233a:	416787b3          	sub	a5,a5,s6
ffffffffc020233e:	079a                	slli	a5,a5,0x6
ffffffffc0202340:	953e                	add	a0,a0,a5
ffffffffc0202342:	4585                	li	a1,1
ffffffffc0202344:	8b7ff0ef          	jal	ra,ffffffffc0201bfa <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202348:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc020234c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020234e:	078a                	slli	a5,a5,0x2
ffffffffc0202350:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202352:	22e7f663          	bleu	a4,a5,ffffffffc020257e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202356:	00093503          	ld	a0,0(s2)
ffffffffc020235a:	416787b3          	sub	a5,a5,s6
ffffffffc020235e:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202360:	953e                	add	a0,a0,a5
ffffffffc0202362:	4585                	li	a1,1
ffffffffc0202364:	897ff0ef          	jal	ra,ffffffffc0201bfa <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202368:	601c                	ld	a5,0(s0)
ffffffffc020236a:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc020236e:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202372:	8cfff0ef          	jal	ra,ffffffffc0201c40 <nr_free_pages>
ffffffffc0202376:	68aa1163          	bne	s4,a0,ffffffffc02029f8 <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020237a:	00003517          	auipc	a0,0x3
ffffffffc020237e:	7de50513          	addi	a0,a0,2014 # ffffffffc0205b58 <default_pmm_manager+0x4e8>
ffffffffc0202382:	e0dfd0ef          	jal	ra,ffffffffc020018e <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0202386:	8bbff0ef          	jal	ra,ffffffffc0201c40 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020238a:	6098                	ld	a4,0(s1)
ffffffffc020238c:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0202390:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202392:	00c71693          	slli	a3,a4,0xc
ffffffffc0202396:	18d7f563          	bleu	a3,a5,ffffffffc0202520 <pmm_init+0x53a>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020239a:	83b1                	srli	a5,a5,0xc
ffffffffc020239c:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020239e:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02023a2:	1ae7f163          	bleu	a4,a5,ffffffffc0202544 <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02023a6:	7bfd                	lui	s7,0xfffff
ffffffffc02023a8:	6b05                	lui	s6,0x1
ffffffffc02023aa:	a029                	j	ffffffffc02023b4 <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02023ac:	00cad713          	srli	a4,s5,0xc
ffffffffc02023b0:	18f77a63          	bleu	a5,a4,ffffffffc0202544 <pmm_init+0x55e>
ffffffffc02023b4:	0009b583          	ld	a1,0(s3)
ffffffffc02023b8:	4601                	li	a2,0
ffffffffc02023ba:	95d6                	add	a1,a1,s5
ffffffffc02023bc:	8c5ff0ef          	jal	ra,ffffffffc0201c80 <get_pte>
ffffffffc02023c0:	16050263          	beqz	a0,ffffffffc0202524 <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02023c4:	611c                	ld	a5,0(a0)
ffffffffc02023c6:	078a                	slli	a5,a5,0x2
ffffffffc02023c8:	0177f7b3          	and	a5,a5,s7
ffffffffc02023cc:	19579963          	bne	a5,s5,ffffffffc020255e <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02023d0:	609c                	ld	a5,0(s1)
ffffffffc02023d2:	9ada                	add	s5,s5,s6
ffffffffc02023d4:	6008                	ld	a0,0(s0)
ffffffffc02023d6:	00c79713          	slli	a4,a5,0xc
ffffffffc02023da:	fceae9e3          	bltu	s5,a4,ffffffffc02023ac <pmm_init+0x3c6>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc02023de:	611c                	ld	a5,0(a0)
ffffffffc02023e0:	62079c63          	bnez	a5,ffffffffc0202a18 <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc02023e4:	4505                	li	a0,1
ffffffffc02023e6:	f8cff0ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc02023ea:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02023ec:	6008                	ld	a0,0(s0)
ffffffffc02023ee:	4699                	li	a3,6
ffffffffc02023f0:	10000613          	li	a2,256
ffffffffc02023f4:	85d6                	mv	a1,s5
ffffffffc02023f6:	b33ff0ef          	jal	ra,ffffffffc0201f28 <page_insert>
ffffffffc02023fa:	1e051c63          	bnez	a0,ffffffffc02025f2 <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc02023fe:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0202402:	4785                	li	a5,1
ffffffffc0202404:	44f71163          	bne	a4,a5,ffffffffc0202846 <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202408:	6008                	ld	a0,0(s0)
ffffffffc020240a:	6b05                	lui	s6,0x1
ffffffffc020240c:	4699                	li	a3,6
ffffffffc020240e:	100b0613          	addi	a2,s6,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0202412:	85d6                	mv	a1,s5
ffffffffc0202414:	b15ff0ef          	jal	ra,ffffffffc0201f28 <page_insert>
ffffffffc0202418:	40051763          	bnez	a0,ffffffffc0202826 <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc020241c:	000aa703          	lw	a4,0(s5)
ffffffffc0202420:	4789                	li	a5,2
ffffffffc0202422:	3ef71263          	bne	a4,a5,ffffffffc0202806 <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202426:	00004597          	auipc	a1,0x4
ffffffffc020242a:	86a58593          	addi	a1,a1,-1942 # ffffffffc0205c90 <default_pmm_manager+0x620>
ffffffffc020242e:	10000513          	li	a0,256
ffffffffc0202432:	44e020ef          	jal	ra,ffffffffc0204880 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202436:	100b0593          	addi	a1,s6,256
ffffffffc020243a:	10000513          	li	a0,256
ffffffffc020243e:	454020ef          	jal	ra,ffffffffc0204892 <strcmp>
ffffffffc0202442:	44051b63          	bnez	a0,ffffffffc0202898 <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc0202446:	00093683          	ld	a3,0(s2)
ffffffffc020244a:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc020244e:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0202450:	40da86b3          	sub	a3,s5,a3
ffffffffc0202454:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202456:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202458:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc020245a:	00cb5b13          	srli	s6,s6,0xc
ffffffffc020245e:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202462:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202464:	10f77f63          	bleu	a5,a4,ffffffffc0202582 <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202468:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020246c:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202470:	96be                	add	a3,a3,a5
ffffffffc0202472:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fde9b10>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202476:	3c6020ef          	jal	ra,ffffffffc020483c <strlen>
ffffffffc020247a:	54051f63          	bnez	a0,ffffffffc02029d8 <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc020247e:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202482:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202484:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fde9a10>
ffffffffc0202488:	068a                	slli	a3,a3,0x2
ffffffffc020248a:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020248c:	0ef6f963          	bleu	a5,a3,ffffffffc020257e <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc0202490:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202494:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202496:	0efb7663          	bleu	a5,s6,ffffffffc0202582 <pmm_init+0x59c>
ffffffffc020249a:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc020249e:	4585                	li	a1,1
ffffffffc02024a0:	8556                	mv	a0,s5
ffffffffc02024a2:	99b6                	add	s3,s3,a3
ffffffffc02024a4:	f56ff0ef          	jal	ra,ffffffffc0201bfa <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02024a8:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc02024ac:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02024ae:	078a                	slli	a5,a5,0x2
ffffffffc02024b0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02024b2:	0ce7f663          	bleu	a4,a5,ffffffffc020257e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02024b6:	00093503          	ld	a0,0(s2)
ffffffffc02024ba:	fff809b7          	lui	s3,0xfff80
ffffffffc02024be:	97ce                	add	a5,a5,s3
ffffffffc02024c0:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02024c2:	953e                	add	a0,a0,a5
ffffffffc02024c4:	4585                	li	a1,1
ffffffffc02024c6:	f34ff0ef          	jal	ra,ffffffffc0201bfa <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02024ca:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc02024ce:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02024d0:	078a                	slli	a5,a5,0x2
ffffffffc02024d2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02024d4:	0ae7f563          	bleu	a4,a5,ffffffffc020257e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02024d8:	00093503          	ld	a0,0(s2)
ffffffffc02024dc:	97ce                	add	a5,a5,s3
ffffffffc02024de:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02024e0:	953e                	add	a0,a0,a5
ffffffffc02024e2:	4585                	li	a1,1
ffffffffc02024e4:	f16ff0ef          	jal	ra,ffffffffc0201bfa <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02024e8:	601c                	ld	a5,0(s0)
ffffffffc02024ea:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc02024ee:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02024f2:	f4eff0ef          	jal	ra,ffffffffc0201c40 <nr_free_pages>
ffffffffc02024f6:	3caa1163          	bne	s4,a0,ffffffffc02028b8 <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02024fa:	00004517          	auipc	a0,0x4
ffffffffc02024fe:	80e50513          	addi	a0,a0,-2034 # ffffffffc0205d08 <default_pmm_manager+0x698>
ffffffffc0202502:	c8dfd0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0202506:	6406                	ld	s0,64(sp)
ffffffffc0202508:	60a6                	ld	ra,72(sp)
ffffffffc020250a:	74e2                	ld	s1,56(sp)
ffffffffc020250c:	7942                	ld	s2,48(sp)
ffffffffc020250e:	79a2                	ld	s3,40(sp)
ffffffffc0202510:	7a02                	ld	s4,32(sp)
ffffffffc0202512:	6ae2                	ld	s5,24(sp)
ffffffffc0202514:	6b42                	ld	s6,16(sp)
ffffffffc0202516:	6ba2                	ld	s7,8(sp)
ffffffffc0202518:	6c02                	ld	s8,0(sp)
ffffffffc020251a:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc020251c:	c3aff06f          	j	ffffffffc0201956 <kmalloc_init>
ffffffffc0202520:	6008                	ld	a0,0(s0)
ffffffffc0202522:	bd75                	j	ffffffffc02023de <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202524:	00003697          	auipc	a3,0x3
ffffffffc0202528:	65468693          	addi	a3,a3,1620 # ffffffffc0205b78 <default_pmm_manager+0x508>
ffffffffc020252c:	00003617          	auipc	a2,0x3
ffffffffc0202530:	dac60613          	addi	a2,a2,-596 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202534:	19d00593          	li	a1,413
ffffffffc0202538:	00003517          	auipc	a0,0x3
ffffffffc020253c:	27850513          	addi	a0,a0,632 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc0202540:	f11fd0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc0202544:	86d6                	mv	a3,s5
ffffffffc0202546:	00003617          	auipc	a2,0x3
ffffffffc020254a:	17a60613          	addi	a2,a2,378 # ffffffffc02056c0 <default_pmm_manager+0x50>
ffffffffc020254e:	19d00593          	li	a1,413
ffffffffc0202552:	00003517          	auipc	a0,0x3
ffffffffc0202556:	25e50513          	addi	a0,a0,606 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc020255a:	ef7fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020255e:	00003697          	auipc	a3,0x3
ffffffffc0202562:	65a68693          	addi	a3,a3,1626 # ffffffffc0205bb8 <default_pmm_manager+0x548>
ffffffffc0202566:	00003617          	auipc	a2,0x3
ffffffffc020256a:	d7260613          	addi	a2,a2,-654 # ffffffffc02052d8 <commands+0x870>
ffffffffc020256e:	19e00593          	li	a1,414
ffffffffc0202572:	00003517          	auipc	a0,0x3
ffffffffc0202576:	23e50513          	addi	a0,a0,574 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc020257a:	ed7fd0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc020257e:	dd8ff0ef          	jal	ra,ffffffffc0201b56 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0202582:	00003617          	auipc	a2,0x3
ffffffffc0202586:	13e60613          	addi	a2,a2,318 # ffffffffc02056c0 <default_pmm_manager+0x50>
ffffffffc020258a:	06900593          	li	a1,105
ffffffffc020258e:	00003517          	auipc	a0,0x3
ffffffffc0202592:	15a50513          	addi	a0,a0,346 # ffffffffc02056e8 <default_pmm_manager+0x78>
ffffffffc0202596:	ebbfd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020259a:	00003617          	auipc	a2,0x3
ffffffffc020259e:	3ae60613          	addi	a2,a2,942 # ffffffffc0205948 <default_pmm_manager+0x2d8>
ffffffffc02025a2:	07400593          	li	a1,116
ffffffffc02025a6:	00003517          	auipc	a0,0x3
ffffffffc02025aa:	14250513          	addi	a0,a0,322 # ffffffffc02056e8 <default_pmm_manager+0x78>
ffffffffc02025ae:	ea3fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02025b2:	00003697          	auipc	a3,0x3
ffffffffc02025b6:	2d668693          	addi	a3,a3,726 # ffffffffc0205888 <default_pmm_manager+0x218>
ffffffffc02025ba:	00003617          	auipc	a2,0x3
ffffffffc02025be:	d1e60613          	addi	a2,a2,-738 # ffffffffc02052d8 <commands+0x870>
ffffffffc02025c2:	16100593          	li	a1,353
ffffffffc02025c6:	00003517          	auipc	a0,0x3
ffffffffc02025ca:	1ea50513          	addi	a0,a0,490 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc02025ce:	e83fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02025d2:	00003697          	auipc	a3,0x3
ffffffffc02025d6:	39e68693          	addi	a3,a3,926 # ffffffffc0205970 <default_pmm_manager+0x300>
ffffffffc02025da:	00003617          	auipc	a2,0x3
ffffffffc02025de:	cfe60613          	addi	a2,a2,-770 # ffffffffc02052d8 <commands+0x870>
ffffffffc02025e2:	17d00593          	li	a1,381
ffffffffc02025e6:	00003517          	auipc	a0,0x3
ffffffffc02025ea:	1ca50513          	addi	a0,a0,458 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc02025ee:	e63fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02025f2:	00003697          	auipc	a3,0x3
ffffffffc02025f6:	5f668693          	addi	a3,a3,1526 # ffffffffc0205be8 <default_pmm_manager+0x578>
ffffffffc02025fa:	00003617          	auipc	a2,0x3
ffffffffc02025fe:	cde60613          	addi	a2,a2,-802 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202602:	1a500593          	li	a1,421
ffffffffc0202606:	00003517          	auipc	a0,0x3
ffffffffc020260a:	1aa50513          	addi	a0,a0,426 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc020260e:	e43fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202612:	00003697          	auipc	a3,0x3
ffffffffc0202616:	3ee68693          	addi	a3,a3,1006 # ffffffffc0205a00 <default_pmm_manager+0x390>
ffffffffc020261a:	00003617          	auipc	a2,0x3
ffffffffc020261e:	cbe60613          	addi	a2,a2,-834 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202622:	17c00593          	li	a1,380
ffffffffc0202626:	00003517          	auipc	a0,0x3
ffffffffc020262a:	18a50513          	addi	a0,a0,394 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc020262e:	e23fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202632:	00003697          	auipc	a3,0x3
ffffffffc0202636:	49668693          	addi	a3,a3,1174 # ffffffffc0205ac8 <default_pmm_manager+0x458>
ffffffffc020263a:	00003617          	auipc	a2,0x3
ffffffffc020263e:	c9e60613          	addi	a2,a2,-866 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202642:	17b00593          	li	a1,379
ffffffffc0202646:	00003517          	auipc	a0,0x3
ffffffffc020264a:	16a50513          	addi	a0,a0,362 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc020264e:	e03fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202652:	00003697          	auipc	a3,0x3
ffffffffc0202656:	45e68693          	addi	a3,a3,1118 # ffffffffc0205ab0 <default_pmm_manager+0x440>
ffffffffc020265a:	00003617          	auipc	a2,0x3
ffffffffc020265e:	c7e60613          	addi	a2,a2,-898 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202662:	17a00593          	li	a1,378
ffffffffc0202666:	00003517          	auipc	a0,0x3
ffffffffc020266a:	14a50513          	addi	a0,a0,330 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc020266e:	de3fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202672:	00003697          	auipc	a3,0x3
ffffffffc0202676:	40e68693          	addi	a3,a3,1038 # ffffffffc0205a80 <default_pmm_manager+0x410>
ffffffffc020267a:	00003617          	auipc	a2,0x3
ffffffffc020267e:	c5e60613          	addi	a2,a2,-930 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202682:	17900593          	li	a1,377
ffffffffc0202686:	00003517          	auipc	a0,0x3
ffffffffc020268a:	12a50513          	addi	a0,a0,298 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc020268e:	dc3fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202692:	00003697          	auipc	a3,0x3
ffffffffc0202696:	3d668693          	addi	a3,a3,982 # ffffffffc0205a68 <default_pmm_manager+0x3f8>
ffffffffc020269a:	00003617          	auipc	a2,0x3
ffffffffc020269e:	c3e60613          	addi	a2,a2,-962 # ffffffffc02052d8 <commands+0x870>
ffffffffc02026a2:	17700593          	li	a1,375
ffffffffc02026a6:	00003517          	auipc	a0,0x3
ffffffffc02026aa:	10a50513          	addi	a0,a0,266 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc02026ae:	da3fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02026b2:	00003697          	auipc	a3,0x3
ffffffffc02026b6:	39e68693          	addi	a3,a3,926 # ffffffffc0205a50 <default_pmm_manager+0x3e0>
ffffffffc02026ba:	00003617          	auipc	a2,0x3
ffffffffc02026be:	c1e60613          	addi	a2,a2,-994 # ffffffffc02052d8 <commands+0x870>
ffffffffc02026c2:	17600593          	li	a1,374
ffffffffc02026c6:	00003517          	auipc	a0,0x3
ffffffffc02026ca:	0ea50513          	addi	a0,a0,234 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc02026ce:	d83fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02026d2:	00003697          	auipc	a3,0x3
ffffffffc02026d6:	36e68693          	addi	a3,a3,878 # ffffffffc0205a40 <default_pmm_manager+0x3d0>
ffffffffc02026da:	00003617          	auipc	a2,0x3
ffffffffc02026de:	bfe60613          	addi	a2,a2,-1026 # ffffffffc02052d8 <commands+0x870>
ffffffffc02026e2:	17500593          	li	a1,373
ffffffffc02026e6:	00003517          	auipc	a0,0x3
ffffffffc02026ea:	0ca50513          	addi	a0,a0,202 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc02026ee:	d63fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02026f2:	00003697          	auipc	a3,0x3
ffffffffc02026f6:	33e68693          	addi	a3,a3,830 # ffffffffc0205a30 <default_pmm_manager+0x3c0>
ffffffffc02026fa:	00003617          	auipc	a2,0x3
ffffffffc02026fe:	bde60613          	addi	a2,a2,-1058 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202702:	17400593          	li	a1,372
ffffffffc0202706:	00003517          	auipc	a0,0x3
ffffffffc020270a:	0aa50513          	addi	a0,a0,170 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc020270e:	d43fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202712:	00003697          	auipc	a3,0x3
ffffffffc0202716:	2ee68693          	addi	a3,a3,750 # ffffffffc0205a00 <default_pmm_manager+0x390>
ffffffffc020271a:	00003617          	auipc	a2,0x3
ffffffffc020271e:	bbe60613          	addi	a2,a2,-1090 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202722:	17300593          	li	a1,371
ffffffffc0202726:	00003517          	auipc	a0,0x3
ffffffffc020272a:	08a50513          	addi	a0,a0,138 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc020272e:	d23fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202732:	00003697          	auipc	a3,0x3
ffffffffc0202736:	29668693          	addi	a3,a3,662 # ffffffffc02059c8 <default_pmm_manager+0x358>
ffffffffc020273a:	00003617          	auipc	a2,0x3
ffffffffc020273e:	b9e60613          	addi	a2,a2,-1122 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202742:	17200593          	li	a1,370
ffffffffc0202746:	00003517          	auipc	a0,0x3
ffffffffc020274a:	06a50513          	addi	a0,a0,106 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc020274e:	d03fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202752:	00003697          	auipc	a3,0x3
ffffffffc0202756:	24e68693          	addi	a3,a3,590 # ffffffffc02059a0 <default_pmm_manager+0x330>
ffffffffc020275a:	00003617          	auipc	a2,0x3
ffffffffc020275e:	b7e60613          	addi	a2,a2,-1154 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202762:	16f00593          	li	a1,367
ffffffffc0202766:	00003517          	auipc	a0,0x3
ffffffffc020276a:	04a50513          	addi	a0,a0,74 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc020276e:	ce3fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202772:	86da                	mv	a3,s6
ffffffffc0202774:	00003617          	auipc	a2,0x3
ffffffffc0202778:	f4c60613          	addi	a2,a2,-180 # ffffffffc02056c0 <default_pmm_manager+0x50>
ffffffffc020277c:	16e00593          	li	a1,366
ffffffffc0202780:	00003517          	auipc	a0,0x3
ffffffffc0202784:	03050513          	addi	a0,a0,48 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc0202788:	cc9fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    return KADDR(page2pa(page));
ffffffffc020278c:	86be                	mv	a3,a5
ffffffffc020278e:	00003617          	auipc	a2,0x3
ffffffffc0202792:	f3260613          	addi	a2,a2,-206 # ffffffffc02056c0 <default_pmm_manager+0x50>
ffffffffc0202796:	06900593          	li	a1,105
ffffffffc020279a:	00003517          	auipc	a0,0x3
ffffffffc020279e:	f4e50513          	addi	a0,a0,-178 # ffffffffc02056e8 <default_pmm_manager+0x78>
ffffffffc02027a2:	caffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02027a6:	00003697          	auipc	a3,0x3
ffffffffc02027aa:	36a68693          	addi	a3,a3,874 # ffffffffc0205b10 <default_pmm_manager+0x4a0>
ffffffffc02027ae:	00003617          	auipc	a2,0x3
ffffffffc02027b2:	b2a60613          	addi	a2,a2,-1238 # ffffffffc02052d8 <commands+0x870>
ffffffffc02027b6:	18800593          	li	a1,392
ffffffffc02027ba:	00003517          	auipc	a0,0x3
ffffffffc02027be:	ff650513          	addi	a0,a0,-10 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc02027c2:	c8ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02027c6:	00003697          	auipc	a3,0x3
ffffffffc02027ca:	30268693          	addi	a3,a3,770 # ffffffffc0205ac8 <default_pmm_manager+0x458>
ffffffffc02027ce:	00003617          	auipc	a2,0x3
ffffffffc02027d2:	b0a60613          	addi	a2,a2,-1270 # ffffffffc02052d8 <commands+0x870>
ffffffffc02027d6:	18600593          	li	a1,390
ffffffffc02027da:	00003517          	auipc	a0,0x3
ffffffffc02027de:	fd650513          	addi	a0,a0,-42 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc02027e2:	c6ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02027e6:	00003697          	auipc	a3,0x3
ffffffffc02027ea:	31268693          	addi	a3,a3,786 # ffffffffc0205af8 <default_pmm_manager+0x488>
ffffffffc02027ee:	00003617          	auipc	a2,0x3
ffffffffc02027f2:	aea60613          	addi	a2,a2,-1302 # ffffffffc02052d8 <commands+0x870>
ffffffffc02027f6:	18500593          	li	a1,389
ffffffffc02027fa:	00003517          	auipc	a0,0x3
ffffffffc02027fe:	fb650513          	addi	a0,a0,-74 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc0202802:	c4ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202806:	00003697          	auipc	a3,0x3
ffffffffc020280a:	47268693          	addi	a3,a3,1138 # ffffffffc0205c78 <default_pmm_manager+0x608>
ffffffffc020280e:	00003617          	auipc	a2,0x3
ffffffffc0202812:	aca60613          	addi	a2,a2,-1334 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202816:	1a800593          	li	a1,424
ffffffffc020281a:	00003517          	auipc	a0,0x3
ffffffffc020281e:	f9650513          	addi	a0,a0,-106 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc0202822:	c2ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202826:	00003697          	auipc	a3,0x3
ffffffffc020282a:	41268693          	addi	a3,a3,1042 # ffffffffc0205c38 <default_pmm_manager+0x5c8>
ffffffffc020282e:	00003617          	auipc	a2,0x3
ffffffffc0202832:	aaa60613          	addi	a2,a2,-1366 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202836:	1a700593          	li	a1,423
ffffffffc020283a:	00003517          	auipc	a0,0x3
ffffffffc020283e:	f7650513          	addi	a0,a0,-138 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc0202842:	c0ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202846:	00003697          	auipc	a3,0x3
ffffffffc020284a:	3da68693          	addi	a3,a3,986 # ffffffffc0205c20 <default_pmm_manager+0x5b0>
ffffffffc020284e:	00003617          	auipc	a2,0x3
ffffffffc0202852:	a8a60613          	addi	a2,a2,-1398 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202856:	1a600593          	li	a1,422
ffffffffc020285a:	00003517          	auipc	a0,0x3
ffffffffc020285e:	f5650513          	addi	a0,a0,-170 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc0202862:	beffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202866:	86be                	mv	a3,a5
ffffffffc0202868:	00003617          	auipc	a2,0x3
ffffffffc020286c:	e5860613          	addi	a2,a2,-424 # ffffffffc02056c0 <default_pmm_manager+0x50>
ffffffffc0202870:	16d00593          	li	a1,365
ffffffffc0202874:	00003517          	auipc	a0,0x3
ffffffffc0202878:	f3c50513          	addi	a0,a0,-196 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc020287c:	bd5fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202880:	00003617          	auipc	a2,0x3
ffffffffc0202884:	e7860613          	addi	a2,a2,-392 # ffffffffc02056f8 <default_pmm_manager+0x88>
ffffffffc0202888:	07f00593          	li	a1,127
ffffffffc020288c:	00003517          	auipc	a0,0x3
ffffffffc0202890:	f2450513          	addi	a0,a0,-220 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc0202894:	bbdfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202898:	00003697          	auipc	a3,0x3
ffffffffc020289c:	41068693          	addi	a3,a3,1040 # ffffffffc0205ca8 <default_pmm_manager+0x638>
ffffffffc02028a0:	00003617          	auipc	a2,0x3
ffffffffc02028a4:	a3860613          	addi	a2,a2,-1480 # ffffffffc02052d8 <commands+0x870>
ffffffffc02028a8:	1ac00593          	li	a1,428
ffffffffc02028ac:	00003517          	auipc	a0,0x3
ffffffffc02028b0:	f0450513          	addi	a0,a0,-252 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc02028b4:	b9dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02028b8:	00003697          	auipc	a3,0x3
ffffffffc02028bc:	28068693          	addi	a3,a3,640 # ffffffffc0205b38 <default_pmm_manager+0x4c8>
ffffffffc02028c0:	00003617          	auipc	a2,0x3
ffffffffc02028c4:	a1860613          	addi	a2,a2,-1512 # ffffffffc02052d8 <commands+0x870>
ffffffffc02028c8:	1b800593          	li	a1,440
ffffffffc02028cc:	00003517          	auipc	a0,0x3
ffffffffc02028d0:	ee450513          	addi	a0,a0,-284 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc02028d4:	b7dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02028d8:	00003697          	auipc	a3,0x3
ffffffffc02028dc:	0b068693          	addi	a3,a3,176 # ffffffffc0205988 <default_pmm_manager+0x318>
ffffffffc02028e0:	00003617          	auipc	a2,0x3
ffffffffc02028e4:	9f860613          	addi	a2,a2,-1544 # ffffffffc02052d8 <commands+0x870>
ffffffffc02028e8:	16b00593          	li	a1,363
ffffffffc02028ec:	00003517          	auipc	a0,0x3
ffffffffc02028f0:	ec450513          	addi	a0,a0,-316 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc02028f4:	b5dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02028f8:	00003697          	auipc	a3,0x3
ffffffffc02028fc:	07868693          	addi	a3,a3,120 # ffffffffc0205970 <default_pmm_manager+0x300>
ffffffffc0202900:	00003617          	auipc	a2,0x3
ffffffffc0202904:	9d860613          	addi	a2,a2,-1576 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202908:	16a00593          	li	a1,362
ffffffffc020290c:	00003517          	auipc	a0,0x3
ffffffffc0202910:	ea450513          	addi	a0,a0,-348 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc0202914:	b3dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202918:	00003697          	auipc	a3,0x3
ffffffffc020291c:	fa868693          	addi	a3,a3,-88 # ffffffffc02058c0 <default_pmm_manager+0x250>
ffffffffc0202920:	00003617          	auipc	a2,0x3
ffffffffc0202924:	9b860613          	addi	a2,a2,-1608 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202928:	16200593          	li	a1,354
ffffffffc020292c:	00003517          	auipc	a0,0x3
ffffffffc0202930:	e8450513          	addi	a0,a0,-380 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc0202934:	b1dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202938:	00003697          	auipc	a3,0x3
ffffffffc020293c:	fe068693          	addi	a3,a3,-32 # ffffffffc0205918 <default_pmm_manager+0x2a8>
ffffffffc0202940:	00003617          	auipc	a2,0x3
ffffffffc0202944:	99860613          	addi	a2,a2,-1640 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202948:	16900593          	li	a1,361
ffffffffc020294c:	00003517          	auipc	a0,0x3
ffffffffc0202950:	e6450513          	addi	a0,a0,-412 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc0202954:	afdfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202958:	00003697          	auipc	a3,0x3
ffffffffc020295c:	f9068693          	addi	a3,a3,-112 # ffffffffc02058e8 <default_pmm_manager+0x278>
ffffffffc0202960:	00003617          	auipc	a2,0x3
ffffffffc0202964:	97860613          	addi	a2,a2,-1672 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202968:	16600593          	li	a1,358
ffffffffc020296c:	00003517          	auipc	a0,0x3
ffffffffc0202970:	e4450513          	addi	a0,a0,-444 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc0202974:	addfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202978:	00003697          	auipc	a3,0x3
ffffffffc020297c:	15068693          	addi	a3,a3,336 # ffffffffc0205ac8 <default_pmm_manager+0x458>
ffffffffc0202980:	00003617          	auipc	a2,0x3
ffffffffc0202984:	95860613          	addi	a2,a2,-1704 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202988:	18200593          	li	a1,386
ffffffffc020298c:	00003517          	auipc	a0,0x3
ffffffffc0202990:	e2450513          	addi	a0,a0,-476 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc0202994:	abdfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202998:	00003697          	auipc	a3,0x3
ffffffffc020299c:	ff068693          	addi	a3,a3,-16 # ffffffffc0205988 <default_pmm_manager+0x318>
ffffffffc02029a0:	00003617          	auipc	a2,0x3
ffffffffc02029a4:	93860613          	addi	a2,a2,-1736 # ffffffffc02052d8 <commands+0x870>
ffffffffc02029a8:	18100593          	li	a1,385
ffffffffc02029ac:	00003517          	auipc	a0,0x3
ffffffffc02029b0:	e0450513          	addi	a0,a0,-508 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc02029b4:	a9dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02029b8:	00003697          	auipc	a3,0x3
ffffffffc02029bc:	12868693          	addi	a3,a3,296 # ffffffffc0205ae0 <default_pmm_manager+0x470>
ffffffffc02029c0:	00003617          	auipc	a2,0x3
ffffffffc02029c4:	91860613          	addi	a2,a2,-1768 # ffffffffc02052d8 <commands+0x870>
ffffffffc02029c8:	17e00593          	li	a1,382
ffffffffc02029cc:	00003517          	auipc	a0,0x3
ffffffffc02029d0:	de450513          	addi	a0,a0,-540 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc02029d4:	a7dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02029d8:	00003697          	auipc	a3,0x3
ffffffffc02029dc:	30868693          	addi	a3,a3,776 # ffffffffc0205ce0 <default_pmm_manager+0x670>
ffffffffc02029e0:	00003617          	auipc	a2,0x3
ffffffffc02029e4:	8f860613          	addi	a2,a2,-1800 # ffffffffc02052d8 <commands+0x870>
ffffffffc02029e8:	1af00593          	li	a1,431
ffffffffc02029ec:	00003517          	auipc	a0,0x3
ffffffffc02029f0:	dc450513          	addi	a0,a0,-572 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc02029f4:	a5dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02029f8:	00003697          	auipc	a3,0x3
ffffffffc02029fc:	14068693          	addi	a3,a3,320 # ffffffffc0205b38 <default_pmm_manager+0x4c8>
ffffffffc0202a00:	00003617          	auipc	a2,0x3
ffffffffc0202a04:	8d860613          	addi	a2,a2,-1832 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202a08:	19000593          	li	a1,400
ffffffffc0202a0c:	00003517          	auipc	a0,0x3
ffffffffc0202a10:	da450513          	addi	a0,a0,-604 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc0202a14:	a3dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202a18:	00003697          	auipc	a3,0x3
ffffffffc0202a1c:	1b868693          	addi	a3,a3,440 # ffffffffc0205bd0 <default_pmm_manager+0x560>
ffffffffc0202a20:	00003617          	auipc	a2,0x3
ffffffffc0202a24:	8b860613          	addi	a2,a2,-1864 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202a28:	1a100593          	li	a1,417
ffffffffc0202a2c:	00003517          	auipc	a0,0x3
ffffffffc0202a30:	d8450513          	addi	a0,a0,-636 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc0202a34:	a1dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202a38:	00003697          	auipc	a3,0x3
ffffffffc0202a3c:	e3068693          	addi	a3,a3,-464 # ffffffffc0205868 <default_pmm_manager+0x1f8>
ffffffffc0202a40:	00003617          	auipc	a2,0x3
ffffffffc0202a44:	89860613          	addi	a2,a2,-1896 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202a48:	16000593          	li	a1,352
ffffffffc0202a4c:	00003517          	auipc	a0,0x3
ffffffffc0202a50:	d6450513          	addi	a0,a0,-668 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc0202a54:	9fdfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202a58:	00003617          	auipc	a2,0x3
ffffffffc0202a5c:	ca060613          	addi	a2,a2,-864 # ffffffffc02056f8 <default_pmm_manager+0x88>
ffffffffc0202a60:	0c300593          	li	a1,195
ffffffffc0202a64:	00003517          	auipc	a0,0x3
ffffffffc0202a68:	d4c50513          	addi	a0,a0,-692 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc0202a6c:	9e5fd0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0202a70 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202a70:	12058073          	sfence.vma	a1
}
ffffffffc0202a74:	8082                	ret

ffffffffc0202a76 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202a76:	7179                	addi	sp,sp,-48
ffffffffc0202a78:	e84a                	sd	s2,16(sp)
ffffffffc0202a7a:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202a7c:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202a7e:	f022                	sd	s0,32(sp)
ffffffffc0202a80:	ec26                	sd	s1,24(sp)
ffffffffc0202a82:	e44e                	sd	s3,8(sp)
ffffffffc0202a84:	f406                	sd	ra,40(sp)
ffffffffc0202a86:	84ae                	mv	s1,a1
ffffffffc0202a88:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202a8a:	8e8ff0ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0202a8e:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202a90:	cd19                	beqz	a0,ffffffffc0202aae <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202a92:	85aa                	mv	a1,a0
ffffffffc0202a94:	86ce                	mv	a3,s3
ffffffffc0202a96:	8626                	mv	a2,s1
ffffffffc0202a98:	854a                	mv	a0,s2
ffffffffc0202a9a:	c8eff0ef          	jal	ra,ffffffffc0201f28 <page_insert>
ffffffffc0202a9e:	ed39                	bnez	a0,ffffffffc0202afc <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0202aa0:	00013797          	auipc	a5,0x13
ffffffffc0202aa4:	9f878793          	addi	a5,a5,-1544 # ffffffffc0215498 <swap_init_ok>
ffffffffc0202aa8:	439c                	lw	a5,0(a5)
ffffffffc0202aaa:	2781                	sext.w	a5,a5
ffffffffc0202aac:	eb89                	bnez	a5,ffffffffc0202abe <pgdir_alloc_page+0x48>
}
ffffffffc0202aae:	8522                	mv	a0,s0
ffffffffc0202ab0:	70a2                	ld	ra,40(sp)
ffffffffc0202ab2:	7402                	ld	s0,32(sp)
ffffffffc0202ab4:	64e2                	ld	s1,24(sp)
ffffffffc0202ab6:	6942                	ld	s2,16(sp)
ffffffffc0202ab8:	69a2                	ld	s3,8(sp)
ffffffffc0202aba:	6145                	addi	sp,sp,48
ffffffffc0202abc:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202abe:	00013797          	auipc	a5,0x13
ffffffffc0202ac2:	b1a78793          	addi	a5,a5,-1254 # ffffffffc02155d8 <check_mm_struct>
ffffffffc0202ac6:	6388                	ld	a0,0(a5)
ffffffffc0202ac8:	4681                	li	a3,0
ffffffffc0202aca:	8622                	mv	a2,s0
ffffffffc0202acc:	85a6                	mv	a1,s1
ffffffffc0202ace:	7be000ef          	jal	ra,ffffffffc020328c <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202ad2:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202ad4:	fc04                	sd	s1,56(s0)
            assert(page_ref(page) == 1);
ffffffffc0202ad6:	4785                	li	a5,1
ffffffffc0202ad8:	fcf70be3          	beq	a4,a5,ffffffffc0202aae <pgdir_alloc_page+0x38>
ffffffffc0202adc:	00003697          	auipc	a3,0x3
ffffffffc0202ae0:	ce468693          	addi	a3,a3,-796 # ffffffffc02057c0 <default_pmm_manager+0x150>
ffffffffc0202ae4:	00002617          	auipc	a2,0x2
ffffffffc0202ae8:	7f460613          	addi	a2,a2,2036 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202aec:	14800593          	li	a1,328
ffffffffc0202af0:	00003517          	auipc	a0,0x3
ffffffffc0202af4:	cc050513          	addi	a0,a0,-832 # ffffffffc02057b0 <default_pmm_manager+0x140>
ffffffffc0202af8:	959fd0ef          	jal	ra,ffffffffc0200450 <__panic>
            free_page(page);
ffffffffc0202afc:	8522                	mv	a0,s0
ffffffffc0202afe:	4585                	li	a1,1
ffffffffc0202b00:	8faff0ef          	jal	ra,ffffffffc0201bfa <free_pages>
            return NULL;
ffffffffc0202b04:	4401                	li	s0,0
ffffffffc0202b06:	b765                	j	ffffffffc0202aae <pgdir_alloc_page+0x38>

ffffffffc0202b08 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202b08:	7135                	addi	sp,sp,-160
ffffffffc0202b0a:	ed06                	sd	ra,152(sp)
ffffffffc0202b0c:	e922                	sd	s0,144(sp)
ffffffffc0202b0e:	e526                	sd	s1,136(sp)
ffffffffc0202b10:	e14a                	sd	s2,128(sp)
ffffffffc0202b12:	fcce                	sd	s3,120(sp)
ffffffffc0202b14:	f8d2                	sd	s4,112(sp)
ffffffffc0202b16:	f4d6                	sd	s5,104(sp)
ffffffffc0202b18:	f0da                	sd	s6,96(sp)
ffffffffc0202b1a:	ecde                	sd	s7,88(sp)
ffffffffc0202b1c:	e8e2                	sd	s8,80(sp)
ffffffffc0202b1e:	e4e6                	sd	s9,72(sp)
ffffffffc0202b20:	e0ea                	sd	s10,64(sp)
ffffffffc0202b22:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202b24:	454010ef          	jal	ra,ffffffffc0203f78 <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202b28:	00013797          	auipc	a5,0x13
ffffffffc0202b2c:	a6078793          	addi	a5,a5,-1440 # ffffffffc0215588 <max_swap_offset>
ffffffffc0202b30:	6394                	ld	a3,0(a5)
ffffffffc0202b32:	010007b7          	lui	a5,0x1000
ffffffffc0202b36:	17e1                	addi	a5,a5,-8
ffffffffc0202b38:	ff968713          	addi	a4,a3,-7
ffffffffc0202b3c:	4ae7e863          	bltu	a5,a4,ffffffffc0202fec <swap_init+0x4e4>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc0202b40:	00007797          	auipc	a5,0x7
ffffffffc0202b44:	4d078793          	addi	a5,a5,1232 # ffffffffc020a010 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0202b48:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0202b4a:	00013697          	auipc	a3,0x13
ffffffffc0202b4e:	94f6b323          	sd	a5,-1722(a3) # ffffffffc0215490 <sm>
     int r = sm->init();
ffffffffc0202b52:	9702                	jalr	a4
ffffffffc0202b54:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc0202b56:	c10d                	beqz	a0,ffffffffc0202b78 <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0202b58:	60ea                	ld	ra,152(sp)
ffffffffc0202b5a:	644a                	ld	s0,144(sp)
ffffffffc0202b5c:	8556                	mv	a0,s5
ffffffffc0202b5e:	64aa                	ld	s1,136(sp)
ffffffffc0202b60:	690a                	ld	s2,128(sp)
ffffffffc0202b62:	79e6                	ld	s3,120(sp)
ffffffffc0202b64:	7a46                	ld	s4,112(sp)
ffffffffc0202b66:	7aa6                	ld	s5,104(sp)
ffffffffc0202b68:	7b06                	ld	s6,96(sp)
ffffffffc0202b6a:	6be6                	ld	s7,88(sp)
ffffffffc0202b6c:	6c46                	ld	s8,80(sp)
ffffffffc0202b6e:	6ca6                	ld	s9,72(sp)
ffffffffc0202b70:	6d06                	ld	s10,64(sp)
ffffffffc0202b72:	7de2                	ld	s11,56(sp)
ffffffffc0202b74:	610d                	addi	sp,sp,160
ffffffffc0202b76:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202b78:	00013797          	auipc	a5,0x13
ffffffffc0202b7c:	91878793          	addi	a5,a5,-1768 # ffffffffc0215490 <sm>
ffffffffc0202b80:	639c                	ld	a5,0(a5)
ffffffffc0202b82:	00003517          	auipc	a0,0x3
ffffffffc0202b86:	1d650513          	addi	a0,a0,470 # ffffffffc0205d58 <default_pmm_manager+0x6e8>
    return listelm->next;
ffffffffc0202b8a:	00013417          	auipc	s0,0x13
ffffffffc0202b8e:	93e40413          	addi	s0,s0,-1730 # ffffffffc02154c8 <free_area>
ffffffffc0202b92:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202b94:	4785                	li	a5,1
ffffffffc0202b96:	00013717          	auipc	a4,0x13
ffffffffc0202b9a:	90f72123          	sw	a5,-1790(a4) # ffffffffc0215498 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202b9e:	df0fd0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0202ba2:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202ba4:	36878863          	beq	a5,s0,ffffffffc0202f14 <swap_init+0x40c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202ba8:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202bac:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202bae:	8b05                	andi	a4,a4,1
ffffffffc0202bb0:	36070663          	beqz	a4,ffffffffc0202f1c <swap_init+0x414>
     int ret, count = 0, total = 0, i;
ffffffffc0202bb4:	4481                	li	s1,0
ffffffffc0202bb6:	4901                	li	s2,0
ffffffffc0202bb8:	a031                	j	ffffffffc0202bc4 <swap_init+0xbc>
ffffffffc0202bba:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0202bbe:	8b09                	andi	a4,a4,2
ffffffffc0202bc0:	34070e63          	beqz	a4,ffffffffc0202f1c <swap_init+0x414>
        count ++, total += p->property;
ffffffffc0202bc4:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202bc8:	679c                	ld	a5,8(a5)
ffffffffc0202bca:	2905                	addiw	s2,s2,1
ffffffffc0202bcc:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bce:	fe8796e3          	bne	a5,s0,ffffffffc0202bba <swap_init+0xb2>
ffffffffc0202bd2:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0202bd4:	86cff0ef          	jal	ra,ffffffffc0201c40 <nr_free_pages>
ffffffffc0202bd8:	69351263          	bne	a0,s3,ffffffffc020325c <swap_init+0x754>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202bdc:	8626                	mv	a2,s1
ffffffffc0202bde:	85ca                	mv	a1,s2
ffffffffc0202be0:	00003517          	auipc	a0,0x3
ffffffffc0202be4:	19050513          	addi	a0,a0,400 # ffffffffc0205d70 <default_pmm_manager+0x700>
ffffffffc0202be8:	da6fd0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202bec:	3d1000ef          	jal	ra,ffffffffc02037bc <mm_create>
ffffffffc0202bf0:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202bf2:	60050563          	beqz	a0,ffffffffc02031fc <swap_init+0x6f4>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202bf6:	00013797          	auipc	a5,0x13
ffffffffc0202bfa:	9e278793          	addi	a5,a5,-1566 # ffffffffc02155d8 <check_mm_struct>
ffffffffc0202bfe:	639c                	ld	a5,0(a5)
ffffffffc0202c00:	60079e63          	bnez	a5,ffffffffc020321c <swap_init+0x714>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202c04:	00013797          	auipc	a5,0x13
ffffffffc0202c08:	87c78793          	addi	a5,a5,-1924 # ffffffffc0215480 <boot_pgdir>
ffffffffc0202c0c:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0202c10:	00013797          	auipc	a5,0x13
ffffffffc0202c14:	9ca7b423          	sd	a0,-1592(a5) # ffffffffc02155d8 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc0202c18:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202c1c:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202c20:	4e079263          	bnez	a5,ffffffffc0203104 <swap_init+0x5fc>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202c24:	6599                	lui	a1,0x6
ffffffffc0202c26:	460d                	li	a2,3
ffffffffc0202c28:	6505                	lui	a0,0x1
ffffffffc0202c2a:	3df000ef          	jal	ra,ffffffffc0203808 <vma_create>
ffffffffc0202c2e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202c30:	4e050a63          	beqz	a0,ffffffffc0203124 <swap_init+0x61c>

     insert_vma_struct(mm, vma);
ffffffffc0202c34:	855e                	mv	a0,s7
ffffffffc0202c36:	43f000ef          	jal	ra,ffffffffc0203874 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202c3a:	00003517          	auipc	a0,0x3
ffffffffc0202c3e:	1a650513          	addi	a0,a0,422 # ffffffffc0205de0 <default_pmm_manager+0x770>
ffffffffc0202c42:	d4cfd0ef          	jal	ra,ffffffffc020018e <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202c46:	018bb503          	ld	a0,24(s7)
ffffffffc0202c4a:	4605                	li	a2,1
ffffffffc0202c4c:	6585                	lui	a1,0x1
ffffffffc0202c4e:	832ff0ef          	jal	ra,ffffffffc0201c80 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202c52:	4e050963          	beqz	a0,ffffffffc0203144 <swap_init+0x63c>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202c56:	00003517          	auipc	a0,0x3
ffffffffc0202c5a:	1da50513          	addi	a0,a0,474 # ffffffffc0205e30 <default_pmm_manager+0x7c0>
ffffffffc0202c5e:	00013997          	auipc	s3,0x13
ffffffffc0202c62:	8a298993          	addi	s3,s3,-1886 # ffffffffc0215500 <check_rp>
ffffffffc0202c66:	d28fd0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c6a:	00013a17          	auipc	s4,0x13
ffffffffc0202c6e:	8b6a0a13          	addi	s4,s4,-1866 # ffffffffc0215520 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202c72:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc0202c74:	4505                	li	a0,1
ffffffffc0202c76:	efdfe0ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0202c7a:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0202c7e:	32050763          	beqz	a0,ffffffffc0202fac <swap_init+0x4a4>
ffffffffc0202c82:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202c84:	8b89                	andi	a5,a5,2
ffffffffc0202c86:	30079363          	bnez	a5,ffffffffc0202f8c <swap_init+0x484>
ffffffffc0202c8a:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c8c:	ff4c14e3          	bne	s8,s4,ffffffffc0202c74 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202c90:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202c92:	00013c17          	auipc	s8,0x13
ffffffffc0202c96:	86ec0c13          	addi	s8,s8,-1938 # ffffffffc0215500 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0202c9a:	ec3e                	sd	a5,24(sp)
ffffffffc0202c9c:	641c                	ld	a5,8(s0)
ffffffffc0202c9e:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202ca0:	481c                	lw	a5,16(s0)
ffffffffc0202ca2:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202ca4:	00013797          	auipc	a5,0x13
ffffffffc0202ca8:	8287b623          	sd	s0,-2004(a5) # ffffffffc02154d0 <free_area+0x8>
ffffffffc0202cac:	00013797          	auipc	a5,0x13
ffffffffc0202cb0:	8087be23          	sd	s0,-2020(a5) # ffffffffc02154c8 <free_area>
     nr_free = 0;
ffffffffc0202cb4:	00013797          	auipc	a5,0x13
ffffffffc0202cb8:	8207a223          	sw	zero,-2012(a5) # ffffffffc02154d8 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202cbc:	000c3503          	ld	a0,0(s8)
ffffffffc0202cc0:	4585                	li	a1,1
ffffffffc0202cc2:	0c21                	addi	s8,s8,8
ffffffffc0202cc4:	f37fe0ef          	jal	ra,ffffffffc0201bfa <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202cc8:	ff4c1ae3          	bne	s8,s4,ffffffffc0202cbc <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202ccc:	01042c03          	lw	s8,16(s0)
ffffffffc0202cd0:	4791                	li	a5,4
ffffffffc0202cd2:	50fc1563          	bne	s8,a5,ffffffffc02031dc <swap_init+0x6d4>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202cd6:	00003517          	auipc	a0,0x3
ffffffffc0202cda:	1e250513          	addi	a0,a0,482 # ffffffffc0205eb8 <default_pmm_manager+0x848>
ffffffffc0202cde:	cb0fd0ef          	jal	ra,ffffffffc020018e <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202ce2:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202ce4:	00012797          	auipc	a5,0x12
ffffffffc0202ce8:	7a07ac23          	sw	zero,1976(a5) # ffffffffc021549c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202cec:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0202cee:	00012797          	auipc	a5,0x12
ffffffffc0202cf2:	7ae78793          	addi	a5,a5,1966 # ffffffffc021549c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202cf6:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202cfa:	4398                	lw	a4,0(a5)
ffffffffc0202cfc:	4585                	li	a1,1
ffffffffc0202cfe:	2701                	sext.w	a4,a4
ffffffffc0202d00:	38b71263          	bne	a4,a1,ffffffffc0203084 <swap_init+0x57c>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202d04:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0202d08:	4394                	lw	a3,0(a5)
ffffffffc0202d0a:	2681                	sext.w	a3,a3
ffffffffc0202d0c:	38e69c63          	bne	a3,a4,ffffffffc02030a4 <swap_init+0x59c>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202d10:	6689                	lui	a3,0x2
ffffffffc0202d12:	462d                	li	a2,11
ffffffffc0202d14:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202d18:	4398                	lw	a4,0(a5)
ffffffffc0202d1a:	4589                	li	a1,2
ffffffffc0202d1c:	2701                	sext.w	a4,a4
ffffffffc0202d1e:	2eb71363          	bne	a4,a1,ffffffffc0203004 <swap_init+0x4fc>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202d22:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202d26:	4394                	lw	a3,0(a5)
ffffffffc0202d28:	2681                	sext.w	a3,a3
ffffffffc0202d2a:	2ee69d63          	bne	a3,a4,ffffffffc0203024 <swap_init+0x51c>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202d2e:	668d                	lui	a3,0x3
ffffffffc0202d30:	4631                	li	a2,12
ffffffffc0202d32:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202d36:	4398                	lw	a4,0(a5)
ffffffffc0202d38:	458d                	li	a1,3
ffffffffc0202d3a:	2701                	sext.w	a4,a4
ffffffffc0202d3c:	30b71463          	bne	a4,a1,ffffffffc0203044 <swap_init+0x53c>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202d40:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202d44:	4394                	lw	a3,0(a5)
ffffffffc0202d46:	2681                	sext.w	a3,a3
ffffffffc0202d48:	30e69e63          	bne	a3,a4,ffffffffc0203064 <swap_init+0x55c>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202d4c:	6691                	lui	a3,0x4
ffffffffc0202d4e:	4635                	li	a2,13
ffffffffc0202d50:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202d54:	4398                	lw	a4,0(a5)
ffffffffc0202d56:	2701                	sext.w	a4,a4
ffffffffc0202d58:	37871663          	bne	a4,s8,ffffffffc02030c4 <swap_init+0x5bc>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202d5c:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202d60:	439c                	lw	a5,0(a5)
ffffffffc0202d62:	2781                	sext.w	a5,a5
ffffffffc0202d64:	38e79063          	bne	a5,a4,ffffffffc02030e4 <swap_init+0x5dc>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202d68:	481c                	lw	a5,16(s0)
ffffffffc0202d6a:	3e079d63          	bnez	a5,ffffffffc0203164 <swap_init+0x65c>
ffffffffc0202d6e:	00012797          	auipc	a5,0x12
ffffffffc0202d72:	7b278793          	addi	a5,a5,1970 # ffffffffc0215520 <swap_in_seq_no>
ffffffffc0202d76:	00012717          	auipc	a4,0x12
ffffffffc0202d7a:	7d270713          	addi	a4,a4,2002 # ffffffffc0215548 <swap_out_seq_no>
ffffffffc0202d7e:	00012617          	auipc	a2,0x12
ffffffffc0202d82:	7ca60613          	addi	a2,a2,1994 # ffffffffc0215548 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202d86:	56fd                	li	a3,-1
ffffffffc0202d88:	c394                	sw	a3,0(a5)
ffffffffc0202d8a:	c314                	sw	a3,0(a4)
ffffffffc0202d8c:	0791                	addi	a5,a5,4
ffffffffc0202d8e:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202d90:	fef61ce3          	bne	a2,a5,ffffffffc0202d88 <swap_init+0x280>
ffffffffc0202d94:	00013697          	auipc	a3,0x13
ffffffffc0202d98:	81468693          	addi	a3,a3,-2028 # ffffffffc02155a8 <check_ptep>
ffffffffc0202d9c:	00012817          	auipc	a6,0x12
ffffffffc0202da0:	76480813          	addi	a6,a6,1892 # ffffffffc0215500 <check_rp>
ffffffffc0202da4:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202da6:	00012c97          	auipc	s9,0x12
ffffffffc0202daa:	6e2c8c93          	addi	s9,s9,1762 # ffffffffc0215488 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202dae:	00004d97          	auipc	s11,0x4
ffffffffc0202db2:	baad8d93          	addi	s11,s11,-1110 # ffffffffc0206958 <nbase>
ffffffffc0202db6:	00012c17          	auipc	s8,0x12
ffffffffc0202dba:	742c0c13          	addi	s8,s8,1858 # ffffffffc02154f8 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202dbe:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202dc2:	4601                	li	a2,0
ffffffffc0202dc4:	85ea                	mv	a1,s10
ffffffffc0202dc6:	855a                	mv	a0,s6
ffffffffc0202dc8:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202dca:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202dcc:	eb5fe0ef          	jal	ra,ffffffffc0201c80 <get_pte>
ffffffffc0202dd0:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202dd2:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202dd4:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202dd6:	1e050b63          	beqz	a0,ffffffffc0202fcc <swap_init+0x4c4>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202dda:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202ddc:	0017f613          	andi	a2,a5,1
ffffffffc0202de0:	18060a63          	beqz	a2,ffffffffc0202f74 <swap_init+0x46c>
    if (PPN(pa) >= npage) {
ffffffffc0202de4:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202de8:	078a                	slli	a5,a5,0x2
ffffffffc0202dea:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202dec:	14c7f863          	bleu	a2,a5,ffffffffc0202f3c <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202df0:	000db703          	ld	a4,0(s11)
ffffffffc0202df4:	000c3603          	ld	a2,0(s8)
ffffffffc0202df8:	00083583          	ld	a1,0(a6)
ffffffffc0202dfc:	8f99                	sub	a5,a5,a4
ffffffffc0202dfe:	079a                	slli	a5,a5,0x6
ffffffffc0202e00:	e43a                	sd	a4,8(sp)
ffffffffc0202e02:	97b2                	add	a5,a5,a2
ffffffffc0202e04:	14f59863          	bne	a1,a5,ffffffffc0202f54 <swap_init+0x44c>
ffffffffc0202e08:	6785                	lui	a5,0x1
ffffffffc0202e0a:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202e0c:	6795                	lui	a5,0x5
ffffffffc0202e0e:	06a1                	addi	a3,a3,8
ffffffffc0202e10:	0821                	addi	a6,a6,8
ffffffffc0202e12:	fafd16e3          	bne	s10,a5,ffffffffc0202dbe <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202e16:	00003517          	auipc	a0,0x3
ffffffffc0202e1a:	14a50513          	addi	a0,a0,330 # ffffffffc0205f60 <default_pmm_manager+0x8f0>
ffffffffc0202e1e:	b70fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = sm->check_swap();
ffffffffc0202e22:	00012797          	auipc	a5,0x12
ffffffffc0202e26:	66e78793          	addi	a5,a5,1646 # ffffffffc0215490 <sm>
ffffffffc0202e2a:	639c                	ld	a5,0(a5)
ffffffffc0202e2c:	7f9c                	ld	a5,56(a5)
ffffffffc0202e2e:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202e30:	40051663          	bnez	a0,ffffffffc020323c <swap_init+0x734>

     nr_free = nr_free_store;
ffffffffc0202e34:	77a2                	ld	a5,40(sp)
ffffffffc0202e36:	00012717          	auipc	a4,0x12
ffffffffc0202e3a:	6af72123          	sw	a5,1698(a4) # ffffffffc02154d8 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202e3e:	67e2                	ld	a5,24(sp)
ffffffffc0202e40:	00012717          	auipc	a4,0x12
ffffffffc0202e44:	68f73423          	sd	a5,1672(a4) # ffffffffc02154c8 <free_area>
ffffffffc0202e48:	7782                	ld	a5,32(sp)
ffffffffc0202e4a:	00012717          	auipc	a4,0x12
ffffffffc0202e4e:	68f73323          	sd	a5,1670(a4) # ffffffffc02154d0 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202e52:	0009b503          	ld	a0,0(s3)
ffffffffc0202e56:	4585                	li	a1,1
ffffffffc0202e58:	09a1                	addi	s3,s3,8
ffffffffc0202e5a:	da1fe0ef          	jal	ra,ffffffffc0201bfa <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202e5e:	ff499ae3          	bne	s3,s4,ffffffffc0202e52 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202e62:	855e                	mv	a0,s7
ffffffffc0202e64:	2df000ef          	jal	ra,ffffffffc0203942 <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202e68:	00012797          	auipc	a5,0x12
ffffffffc0202e6c:	61878793          	addi	a5,a5,1560 # ffffffffc0215480 <boot_pgdir>
ffffffffc0202e70:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0202e72:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202e76:	6394                	ld	a3,0(a5)
ffffffffc0202e78:	068a                	slli	a3,a3,0x2
ffffffffc0202e7a:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e7c:	0ce6f063          	bleu	a4,a3,ffffffffc0202f3c <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e80:	67a2                	ld	a5,8(sp)
ffffffffc0202e82:	000c3503          	ld	a0,0(s8)
ffffffffc0202e86:	8e9d                	sub	a3,a3,a5
ffffffffc0202e88:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0202e8a:	8699                	srai	a3,a3,0x6
ffffffffc0202e8c:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0202e8e:	57fd                	li	a5,-1
ffffffffc0202e90:	83b1                	srli	a5,a5,0xc
ffffffffc0202e92:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202e94:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202e96:	2ee7f763          	bleu	a4,a5,ffffffffc0203184 <swap_init+0x67c>
     free_page(pde2page(pd0[0]));
ffffffffc0202e9a:	00012797          	auipc	a5,0x12
ffffffffc0202e9e:	64e78793          	addi	a5,a5,1614 # ffffffffc02154e8 <va_pa_offset>
ffffffffc0202ea2:	639c                	ld	a5,0(a5)
ffffffffc0202ea4:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ea6:	629c                	ld	a5,0(a3)
ffffffffc0202ea8:	078a                	slli	a5,a5,0x2
ffffffffc0202eaa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202eac:	08e7f863          	bleu	a4,a5,ffffffffc0202f3c <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202eb0:	69a2                	ld	s3,8(sp)
ffffffffc0202eb2:	4585                	li	a1,1
ffffffffc0202eb4:	413787b3          	sub	a5,a5,s3
ffffffffc0202eb8:	079a                	slli	a5,a5,0x6
ffffffffc0202eba:	953e                	add	a0,a0,a5
ffffffffc0202ebc:	d3ffe0ef          	jal	ra,ffffffffc0201bfa <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ec0:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0202ec4:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ec8:	078a                	slli	a5,a5,0x2
ffffffffc0202eca:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ecc:	06e7f863          	bleu	a4,a5,ffffffffc0202f3c <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ed0:	000c3503          	ld	a0,0(s8)
ffffffffc0202ed4:	413787b3          	sub	a5,a5,s3
ffffffffc0202ed8:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0202eda:	4585                	li	a1,1
ffffffffc0202edc:	953e                	add	a0,a0,a5
ffffffffc0202ede:	d1dfe0ef          	jal	ra,ffffffffc0201bfa <free_pages>
     pgdir[0] = 0;
ffffffffc0202ee2:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0202ee6:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0202eea:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202eec:	00878963          	beq	a5,s0,ffffffffc0202efe <swap_init+0x3f6>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202ef0:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202ef4:	679c                	ld	a5,8(a5)
ffffffffc0202ef6:	397d                	addiw	s2,s2,-1
ffffffffc0202ef8:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202efa:	fe879be3          	bne	a5,s0,ffffffffc0202ef0 <swap_init+0x3e8>
     }
     assert(count==0);
ffffffffc0202efe:	28091f63          	bnez	s2,ffffffffc020319c <swap_init+0x694>
     assert(total==0);
ffffffffc0202f02:	2a049d63          	bnez	s1,ffffffffc02031bc <swap_init+0x6b4>

     cprintf("check_swap() succeeded!\n");
ffffffffc0202f06:	00003517          	auipc	a0,0x3
ffffffffc0202f0a:	0aa50513          	addi	a0,a0,170 # ffffffffc0205fb0 <default_pmm_manager+0x940>
ffffffffc0202f0e:	a80fd0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0202f12:	b199                	j	ffffffffc0202b58 <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202f14:	4481                	li	s1,0
ffffffffc0202f16:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f18:	4981                	li	s3,0
ffffffffc0202f1a:	b96d                	j	ffffffffc0202bd4 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202f1c:	00002697          	auipc	a3,0x2
ffffffffc0202f20:	3ac68693          	addi	a3,a3,940 # ffffffffc02052c8 <commands+0x860>
ffffffffc0202f24:	00002617          	auipc	a2,0x2
ffffffffc0202f28:	3b460613          	addi	a2,a2,948 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202f2c:	0bd00593          	li	a1,189
ffffffffc0202f30:	00003517          	auipc	a0,0x3
ffffffffc0202f34:	e1850513          	addi	a0,a0,-488 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc0202f38:	d18fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202f3c:	00002617          	auipc	a2,0x2
ffffffffc0202f40:	7e460613          	addi	a2,a2,2020 # ffffffffc0205720 <default_pmm_manager+0xb0>
ffffffffc0202f44:	06200593          	li	a1,98
ffffffffc0202f48:	00002517          	auipc	a0,0x2
ffffffffc0202f4c:	7a050513          	addi	a0,a0,1952 # ffffffffc02056e8 <default_pmm_manager+0x78>
ffffffffc0202f50:	d00fd0ef          	jal	ra,ffffffffc0200450 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202f54:	00003697          	auipc	a3,0x3
ffffffffc0202f58:	fe468693          	addi	a3,a3,-28 # ffffffffc0205f38 <default_pmm_manager+0x8c8>
ffffffffc0202f5c:	00002617          	auipc	a2,0x2
ffffffffc0202f60:	37c60613          	addi	a2,a2,892 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202f64:	0fd00593          	li	a1,253
ffffffffc0202f68:	00003517          	auipc	a0,0x3
ffffffffc0202f6c:	de050513          	addi	a0,a0,-544 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc0202f70:	ce0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202f74:	00003617          	auipc	a2,0x3
ffffffffc0202f78:	9d460613          	addi	a2,a2,-1580 # ffffffffc0205948 <default_pmm_manager+0x2d8>
ffffffffc0202f7c:	07400593          	li	a1,116
ffffffffc0202f80:	00002517          	auipc	a0,0x2
ffffffffc0202f84:	76850513          	addi	a0,a0,1896 # ffffffffc02056e8 <default_pmm_manager+0x78>
ffffffffc0202f88:	cc8fd0ef          	jal	ra,ffffffffc0200450 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202f8c:	00003697          	auipc	a3,0x3
ffffffffc0202f90:	ee468693          	addi	a3,a3,-284 # ffffffffc0205e70 <default_pmm_manager+0x800>
ffffffffc0202f94:	00002617          	auipc	a2,0x2
ffffffffc0202f98:	34460613          	addi	a2,a2,836 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202f9c:	0de00593          	li	a1,222
ffffffffc0202fa0:	00003517          	auipc	a0,0x3
ffffffffc0202fa4:	da850513          	addi	a0,a0,-600 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc0202fa8:	ca8fd0ef          	jal	ra,ffffffffc0200450 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202fac:	00003697          	auipc	a3,0x3
ffffffffc0202fb0:	eac68693          	addi	a3,a3,-340 # ffffffffc0205e58 <default_pmm_manager+0x7e8>
ffffffffc0202fb4:	00002617          	auipc	a2,0x2
ffffffffc0202fb8:	32460613          	addi	a2,a2,804 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202fbc:	0dd00593          	li	a1,221
ffffffffc0202fc0:	00003517          	auipc	a0,0x3
ffffffffc0202fc4:	d8850513          	addi	a0,a0,-632 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc0202fc8:	c88fd0ef          	jal	ra,ffffffffc0200450 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202fcc:	00003697          	auipc	a3,0x3
ffffffffc0202fd0:	f5468693          	addi	a3,a3,-172 # ffffffffc0205f20 <default_pmm_manager+0x8b0>
ffffffffc0202fd4:	00002617          	auipc	a2,0x2
ffffffffc0202fd8:	30460613          	addi	a2,a2,772 # ffffffffc02052d8 <commands+0x870>
ffffffffc0202fdc:	0fc00593          	li	a1,252
ffffffffc0202fe0:	00003517          	auipc	a0,0x3
ffffffffc0202fe4:	d6850513          	addi	a0,a0,-664 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc0202fe8:	c68fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202fec:	00003617          	auipc	a2,0x3
ffffffffc0202ff0:	d3c60613          	addi	a2,a2,-708 # ffffffffc0205d28 <default_pmm_manager+0x6b8>
ffffffffc0202ff4:	02a00593          	li	a1,42
ffffffffc0202ff8:	00003517          	auipc	a0,0x3
ffffffffc0202ffc:	d5050513          	addi	a0,a0,-688 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc0203000:	c50fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==2);
ffffffffc0203004:	00003697          	auipc	a3,0x3
ffffffffc0203008:	eec68693          	addi	a3,a3,-276 # ffffffffc0205ef0 <default_pmm_manager+0x880>
ffffffffc020300c:	00002617          	auipc	a2,0x2
ffffffffc0203010:	2cc60613          	addi	a2,a2,716 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203014:	09800593          	li	a1,152
ffffffffc0203018:	00003517          	auipc	a0,0x3
ffffffffc020301c:	d3050513          	addi	a0,a0,-720 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc0203020:	c30fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==2);
ffffffffc0203024:	00003697          	auipc	a3,0x3
ffffffffc0203028:	ecc68693          	addi	a3,a3,-308 # ffffffffc0205ef0 <default_pmm_manager+0x880>
ffffffffc020302c:	00002617          	auipc	a2,0x2
ffffffffc0203030:	2ac60613          	addi	a2,a2,684 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203034:	09a00593          	li	a1,154
ffffffffc0203038:	00003517          	auipc	a0,0x3
ffffffffc020303c:	d1050513          	addi	a0,a0,-752 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc0203040:	c10fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==3);
ffffffffc0203044:	00003697          	auipc	a3,0x3
ffffffffc0203048:	ebc68693          	addi	a3,a3,-324 # ffffffffc0205f00 <default_pmm_manager+0x890>
ffffffffc020304c:	00002617          	auipc	a2,0x2
ffffffffc0203050:	28c60613          	addi	a2,a2,652 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203054:	09c00593          	li	a1,156
ffffffffc0203058:	00003517          	auipc	a0,0x3
ffffffffc020305c:	cf050513          	addi	a0,a0,-784 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc0203060:	bf0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==3);
ffffffffc0203064:	00003697          	auipc	a3,0x3
ffffffffc0203068:	e9c68693          	addi	a3,a3,-356 # ffffffffc0205f00 <default_pmm_manager+0x890>
ffffffffc020306c:	00002617          	auipc	a2,0x2
ffffffffc0203070:	26c60613          	addi	a2,a2,620 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203074:	09e00593          	li	a1,158
ffffffffc0203078:	00003517          	auipc	a0,0x3
ffffffffc020307c:	cd050513          	addi	a0,a0,-816 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc0203080:	bd0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==1);
ffffffffc0203084:	00003697          	auipc	a3,0x3
ffffffffc0203088:	e5c68693          	addi	a3,a3,-420 # ffffffffc0205ee0 <default_pmm_manager+0x870>
ffffffffc020308c:	00002617          	auipc	a2,0x2
ffffffffc0203090:	24c60613          	addi	a2,a2,588 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203094:	09400593          	li	a1,148
ffffffffc0203098:	00003517          	auipc	a0,0x3
ffffffffc020309c:	cb050513          	addi	a0,a0,-848 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc02030a0:	bb0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==1);
ffffffffc02030a4:	00003697          	auipc	a3,0x3
ffffffffc02030a8:	e3c68693          	addi	a3,a3,-452 # ffffffffc0205ee0 <default_pmm_manager+0x870>
ffffffffc02030ac:	00002617          	auipc	a2,0x2
ffffffffc02030b0:	22c60613          	addi	a2,a2,556 # ffffffffc02052d8 <commands+0x870>
ffffffffc02030b4:	09600593          	li	a1,150
ffffffffc02030b8:	00003517          	auipc	a0,0x3
ffffffffc02030bc:	c9050513          	addi	a0,a0,-880 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc02030c0:	b90fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==4);
ffffffffc02030c4:	00003697          	auipc	a3,0x3
ffffffffc02030c8:	e4c68693          	addi	a3,a3,-436 # ffffffffc0205f10 <default_pmm_manager+0x8a0>
ffffffffc02030cc:	00002617          	auipc	a2,0x2
ffffffffc02030d0:	20c60613          	addi	a2,a2,524 # ffffffffc02052d8 <commands+0x870>
ffffffffc02030d4:	0a000593          	li	a1,160
ffffffffc02030d8:	00003517          	auipc	a0,0x3
ffffffffc02030dc:	c7050513          	addi	a0,a0,-912 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc02030e0:	b70fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==4);
ffffffffc02030e4:	00003697          	auipc	a3,0x3
ffffffffc02030e8:	e2c68693          	addi	a3,a3,-468 # ffffffffc0205f10 <default_pmm_manager+0x8a0>
ffffffffc02030ec:	00002617          	auipc	a2,0x2
ffffffffc02030f0:	1ec60613          	addi	a2,a2,492 # ffffffffc02052d8 <commands+0x870>
ffffffffc02030f4:	0a200593          	li	a1,162
ffffffffc02030f8:	00003517          	auipc	a0,0x3
ffffffffc02030fc:	c5050513          	addi	a0,a0,-944 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc0203100:	b50fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203104:	00003697          	auipc	a3,0x3
ffffffffc0203108:	cbc68693          	addi	a3,a3,-836 # ffffffffc0205dc0 <default_pmm_manager+0x750>
ffffffffc020310c:	00002617          	auipc	a2,0x2
ffffffffc0203110:	1cc60613          	addi	a2,a2,460 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203114:	0cd00593          	li	a1,205
ffffffffc0203118:	00003517          	auipc	a0,0x3
ffffffffc020311c:	c3050513          	addi	a0,a0,-976 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc0203120:	b30fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(vma != NULL);
ffffffffc0203124:	00003697          	auipc	a3,0x3
ffffffffc0203128:	cac68693          	addi	a3,a3,-852 # ffffffffc0205dd0 <default_pmm_manager+0x760>
ffffffffc020312c:	00002617          	auipc	a2,0x2
ffffffffc0203130:	1ac60613          	addi	a2,a2,428 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203134:	0d000593          	li	a1,208
ffffffffc0203138:	00003517          	auipc	a0,0x3
ffffffffc020313c:	c1050513          	addi	a0,a0,-1008 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc0203140:	b10fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203144:	00003697          	auipc	a3,0x3
ffffffffc0203148:	cd468693          	addi	a3,a3,-812 # ffffffffc0205e18 <default_pmm_manager+0x7a8>
ffffffffc020314c:	00002617          	auipc	a2,0x2
ffffffffc0203150:	18c60613          	addi	a2,a2,396 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203154:	0d800593          	li	a1,216
ffffffffc0203158:	00003517          	auipc	a0,0x3
ffffffffc020315c:	bf050513          	addi	a0,a0,-1040 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc0203160:	af0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert( nr_free == 0);         
ffffffffc0203164:	00002697          	auipc	a3,0x2
ffffffffc0203168:	34c68693          	addi	a3,a3,844 # ffffffffc02054b0 <commands+0xa48>
ffffffffc020316c:	00002617          	auipc	a2,0x2
ffffffffc0203170:	16c60613          	addi	a2,a2,364 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203174:	0f400593          	li	a1,244
ffffffffc0203178:	00003517          	auipc	a0,0x3
ffffffffc020317c:	bd050513          	addi	a0,a0,-1072 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc0203180:	ad0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203184:	00002617          	auipc	a2,0x2
ffffffffc0203188:	53c60613          	addi	a2,a2,1340 # ffffffffc02056c0 <default_pmm_manager+0x50>
ffffffffc020318c:	06900593          	li	a1,105
ffffffffc0203190:	00002517          	auipc	a0,0x2
ffffffffc0203194:	55850513          	addi	a0,a0,1368 # ffffffffc02056e8 <default_pmm_manager+0x78>
ffffffffc0203198:	ab8fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(count==0);
ffffffffc020319c:	00003697          	auipc	a3,0x3
ffffffffc02031a0:	df468693          	addi	a3,a3,-524 # ffffffffc0205f90 <default_pmm_manager+0x920>
ffffffffc02031a4:	00002617          	auipc	a2,0x2
ffffffffc02031a8:	13460613          	addi	a2,a2,308 # ffffffffc02052d8 <commands+0x870>
ffffffffc02031ac:	11c00593          	li	a1,284
ffffffffc02031b0:	00003517          	auipc	a0,0x3
ffffffffc02031b4:	b9850513          	addi	a0,a0,-1128 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc02031b8:	a98fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(total==0);
ffffffffc02031bc:	00003697          	auipc	a3,0x3
ffffffffc02031c0:	de468693          	addi	a3,a3,-540 # ffffffffc0205fa0 <default_pmm_manager+0x930>
ffffffffc02031c4:	00002617          	auipc	a2,0x2
ffffffffc02031c8:	11460613          	addi	a2,a2,276 # ffffffffc02052d8 <commands+0x870>
ffffffffc02031cc:	11d00593          	li	a1,285
ffffffffc02031d0:	00003517          	auipc	a0,0x3
ffffffffc02031d4:	b7850513          	addi	a0,a0,-1160 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc02031d8:	a78fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02031dc:	00003697          	auipc	a3,0x3
ffffffffc02031e0:	cb468693          	addi	a3,a3,-844 # ffffffffc0205e90 <default_pmm_manager+0x820>
ffffffffc02031e4:	00002617          	auipc	a2,0x2
ffffffffc02031e8:	0f460613          	addi	a2,a2,244 # ffffffffc02052d8 <commands+0x870>
ffffffffc02031ec:	0eb00593          	li	a1,235
ffffffffc02031f0:	00003517          	auipc	a0,0x3
ffffffffc02031f4:	b5850513          	addi	a0,a0,-1192 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc02031f8:	a58fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(mm != NULL);
ffffffffc02031fc:	00003697          	auipc	a3,0x3
ffffffffc0203200:	b9c68693          	addi	a3,a3,-1124 # ffffffffc0205d98 <default_pmm_manager+0x728>
ffffffffc0203204:	00002617          	auipc	a2,0x2
ffffffffc0203208:	0d460613          	addi	a2,a2,212 # ffffffffc02052d8 <commands+0x870>
ffffffffc020320c:	0c500593          	li	a1,197
ffffffffc0203210:	00003517          	auipc	a0,0x3
ffffffffc0203214:	b3850513          	addi	a0,a0,-1224 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc0203218:	a38fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc020321c:	00003697          	auipc	a3,0x3
ffffffffc0203220:	b8c68693          	addi	a3,a3,-1140 # ffffffffc0205da8 <default_pmm_manager+0x738>
ffffffffc0203224:	00002617          	auipc	a2,0x2
ffffffffc0203228:	0b460613          	addi	a2,a2,180 # ffffffffc02052d8 <commands+0x870>
ffffffffc020322c:	0c800593          	li	a1,200
ffffffffc0203230:	00003517          	auipc	a0,0x3
ffffffffc0203234:	b1850513          	addi	a0,a0,-1256 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc0203238:	a18fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(ret==0);
ffffffffc020323c:	00003697          	auipc	a3,0x3
ffffffffc0203240:	d4c68693          	addi	a3,a3,-692 # ffffffffc0205f88 <default_pmm_manager+0x918>
ffffffffc0203244:	00002617          	auipc	a2,0x2
ffffffffc0203248:	09460613          	addi	a2,a2,148 # ffffffffc02052d8 <commands+0x870>
ffffffffc020324c:	10300593          	li	a1,259
ffffffffc0203250:	00003517          	auipc	a0,0x3
ffffffffc0203254:	af850513          	addi	a0,a0,-1288 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc0203258:	9f8fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(total == nr_free_pages());
ffffffffc020325c:	00002697          	auipc	a3,0x2
ffffffffc0203260:	0ac68693          	addi	a3,a3,172 # ffffffffc0205308 <commands+0x8a0>
ffffffffc0203264:	00002617          	auipc	a2,0x2
ffffffffc0203268:	07460613          	addi	a2,a2,116 # ffffffffc02052d8 <commands+0x870>
ffffffffc020326c:	0c000593          	li	a1,192
ffffffffc0203270:	00003517          	auipc	a0,0x3
ffffffffc0203274:	ad850513          	addi	a0,a0,-1320 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc0203278:	9d8fd0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020327c <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc020327c:	00012797          	auipc	a5,0x12
ffffffffc0203280:	21478793          	addi	a5,a5,532 # ffffffffc0215490 <sm>
ffffffffc0203284:	639c                	ld	a5,0(a5)
ffffffffc0203286:	0107b303          	ld	t1,16(a5)
ffffffffc020328a:	8302                	jr	t1

ffffffffc020328c <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc020328c:	00012797          	auipc	a5,0x12
ffffffffc0203290:	20478793          	addi	a5,a5,516 # ffffffffc0215490 <sm>
ffffffffc0203294:	639c                	ld	a5,0(a5)
ffffffffc0203296:	0207b303          	ld	t1,32(a5)
ffffffffc020329a:	8302                	jr	t1

ffffffffc020329c <swap_out>:
{
ffffffffc020329c:	711d                	addi	sp,sp,-96
ffffffffc020329e:	ec86                	sd	ra,88(sp)
ffffffffc02032a0:	e8a2                	sd	s0,80(sp)
ffffffffc02032a2:	e4a6                	sd	s1,72(sp)
ffffffffc02032a4:	e0ca                	sd	s2,64(sp)
ffffffffc02032a6:	fc4e                	sd	s3,56(sp)
ffffffffc02032a8:	f852                	sd	s4,48(sp)
ffffffffc02032aa:	f456                	sd	s5,40(sp)
ffffffffc02032ac:	f05a                	sd	s6,32(sp)
ffffffffc02032ae:	ec5e                	sd	s7,24(sp)
ffffffffc02032b0:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc02032b2:	cde9                	beqz	a1,ffffffffc020338c <swap_out+0xf0>
ffffffffc02032b4:	8ab2                	mv	s5,a2
ffffffffc02032b6:	892a                	mv	s2,a0
ffffffffc02032b8:	8a2e                	mv	s4,a1
ffffffffc02032ba:	4401                	li	s0,0
ffffffffc02032bc:	00012997          	auipc	s3,0x12
ffffffffc02032c0:	1d498993          	addi	s3,s3,468 # ffffffffc0215490 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02032c4:	00003b17          	auipc	s6,0x3
ffffffffc02032c8:	d6cb0b13          	addi	s6,s6,-660 # ffffffffc0206030 <default_pmm_manager+0x9c0>
                    cprintf("SWAP: failed to save\n");
ffffffffc02032cc:	00003b97          	auipc	s7,0x3
ffffffffc02032d0:	d4cb8b93          	addi	s7,s7,-692 # ffffffffc0206018 <default_pmm_manager+0x9a8>
ffffffffc02032d4:	a825                	j	ffffffffc020330c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02032d6:	67a2                	ld	a5,8(sp)
ffffffffc02032d8:	8626                	mv	a2,s1
ffffffffc02032da:	85a2                	mv	a1,s0
ffffffffc02032dc:	7f94                	ld	a3,56(a5)
ffffffffc02032de:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc02032e0:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02032e2:	82b1                	srli	a3,a3,0xc
ffffffffc02032e4:	0685                	addi	a3,a3,1
ffffffffc02032e6:	ea9fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02032ea:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc02032ec:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02032ee:	7d1c                	ld	a5,56(a0)
ffffffffc02032f0:	83b1                	srli	a5,a5,0xc
ffffffffc02032f2:	0785                	addi	a5,a5,1
ffffffffc02032f4:	07a2                	slli	a5,a5,0x8
ffffffffc02032f6:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc02032fa:	901fe0ef          	jal	ra,ffffffffc0201bfa <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc02032fe:	01893503          	ld	a0,24(s2)
ffffffffc0203302:	85a6                	mv	a1,s1
ffffffffc0203304:	f6cff0ef          	jal	ra,ffffffffc0202a70 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203308:	048a0d63          	beq	s4,s0,ffffffffc0203362 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc020330c:	0009b783          	ld	a5,0(s3)
ffffffffc0203310:	8656                	mv	a2,s5
ffffffffc0203312:	002c                	addi	a1,sp,8
ffffffffc0203314:	7b9c                	ld	a5,48(a5)
ffffffffc0203316:	854a                	mv	a0,s2
ffffffffc0203318:	9782                	jalr	a5
          if (r != 0) {
ffffffffc020331a:	e12d                	bnez	a0,ffffffffc020337c <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc020331c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020331e:	01893503          	ld	a0,24(s2)
ffffffffc0203322:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203324:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203326:	85a6                	mv	a1,s1
ffffffffc0203328:	959fe0ef          	jal	ra,ffffffffc0201c80 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc020332c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020332e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203330:	8b85                	andi	a5,a5,1
ffffffffc0203332:	cfb9                	beqz	a5,ffffffffc0203390 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203334:	65a2                	ld	a1,8(sp)
ffffffffc0203336:	7d9c                	ld	a5,56(a1)
ffffffffc0203338:	83b1                	srli	a5,a5,0xc
ffffffffc020333a:	00178513          	addi	a0,a5,1
ffffffffc020333e:	0522                	slli	a0,a0,0x8
ffffffffc0203340:	471000ef          	jal	ra,ffffffffc0203fb0 <swapfs_write>
ffffffffc0203344:	d949                	beqz	a0,ffffffffc02032d6 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203346:	855e                	mv	a0,s7
ffffffffc0203348:	e47fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc020334c:	0009b783          	ld	a5,0(s3)
ffffffffc0203350:	6622                	ld	a2,8(sp)
ffffffffc0203352:	4681                	li	a3,0
ffffffffc0203354:	739c                	ld	a5,32(a5)
ffffffffc0203356:	85a6                	mv	a1,s1
ffffffffc0203358:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc020335a:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc020335c:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc020335e:	fa8a17e3          	bne	s4,s0,ffffffffc020330c <swap_out+0x70>
}
ffffffffc0203362:	8522                	mv	a0,s0
ffffffffc0203364:	60e6                	ld	ra,88(sp)
ffffffffc0203366:	6446                	ld	s0,80(sp)
ffffffffc0203368:	64a6                	ld	s1,72(sp)
ffffffffc020336a:	6906                	ld	s2,64(sp)
ffffffffc020336c:	79e2                	ld	s3,56(sp)
ffffffffc020336e:	7a42                	ld	s4,48(sp)
ffffffffc0203370:	7aa2                	ld	s5,40(sp)
ffffffffc0203372:	7b02                	ld	s6,32(sp)
ffffffffc0203374:	6be2                	ld	s7,24(sp)
ffffffffc0203376:	6c42                	ld	s8,16(sp)
ffffffffc0203378:	6125                	addi	sp,sp,96
ffffffffc020337a:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc020337c:	85a2                	mv	a1,s0
ffffffffc020337e:	00003517          	auipc	a0,0x3
ffffffffc0203382:	c5250513          	addi	a0,a0,-942 # ffffffffc0205fd0 <default_pmm_manager+0x960>
ffffffffc0203386:	e09fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                  break;
ffffffffc020338a:	bfe1                	j	ffffffffc0203362 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc020338c:	4401                	li	s0,0
ffffffffc020338e:	bfd1                	j	ffffffffc0203362 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203390:	00003697          	auipc	a3,0x3
ffffffffc0203394:	c7068693          	addi	a3,a3,-912 # ffffffffc0206000 <default_pmm_manager+0x990>
ffffffffc0203398:	00002617          	auipc	a2,0x2
ffffffffc020339c:	f4060613          	addi	a2,a2,-192 # ffffffffc02052d8 <commands+0x870>
ffffffffc02033a0:	06900593          	li	a1,105
ffffffffc02033a4:	00003517          	auipc	a0,0x3
ffffffffc02033a8:	9a450513          	addi	a0,a0,-1628 # ffffffffc0205d48 <default_pmm_manager+0x6d8>
ffffffffc02033ac:	8a4fd0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02033b0 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc02033b0:	00012797          	auipc	a5,0x12
ffffffffc02033b4:	21878793          	addi	a5,a5,536 # ffffffffc02155c8 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc02033b8:	f51c                	sd	a5,40(a0)
ffffffffc02033ba:	e79c                	sd	a5,8(a5)
ffffffffc02033bc:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc02033be:	4501                	li	a0,0
ffffffffc02033c0:	8082                	ret

ffffffffc02033c2 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc02033c2:	4501                	li	a0,0
ffffffffc02033c4:	8082                	ret

ffffffffc02033c6 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02033c6:	4501                	li	a0,0
ffffffffc02033c8:	8082                	ret

ffffffffc02033ca <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02033ca:	4501                	li	a0,0
ffffffffc02033cc:	8082                	ret

ffffffffc02033ce <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc02033ce:	711d                	addi	sp,sp,-96
ffffffffc02033d0:	fc4e                	sd	s3,56(sp)
ffffffffc02033d2:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02033d4:	00003517          	auipc	a0,0x3
ffffffffc02033d8:	c9c50513          	addi	a0,a0,-868 # ffffffffc0206070 <default_pmm_manager+0xa00>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02033dc:	698d                	lui	s3,0x3
ffffffffc02033de:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc02033e0:	e8a2                	sd	s0,80(sp)
ffffffffc02033e2:	e4a6                	sd	s1,72(sp)
ffffffffc02033e4:	ec86                	sd	ra,88(sp)
ffffffffc02033e6:	e0ca                	sd	s2,64(sp)
ffffffffc02033e8:	f456                	sd	s5,40(sp)
ffffffffc02033ea:	f05a                	sd	s6,32(sp)
ffffffffc02033ec:	ec5e                	sd	s7,24(sp)
ffffffffc02033ee:	e862                	sd	s8,16(sp)
ffffffffc02033f0:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc02033f2:	00012417          	auipc	s0,0x12
ffffffffc02033f6:	0aa40413          	addi	s0,s0,170 # ffffffffc021549c <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02033fa:	d95fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02033fe:	01498023          	sb	s4,0(s3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0203402:	4004                	lw	s1,0(s0)
ffffffffc0203404:	4791                	li	a5,4
ffffffffc0203406:	2481                	sext.w	s1,s1
ffffffffc0203408:	14f49963          	bne	s1,a5,ffffffffc020355a <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020340c:	00003517          	auipc	a0,0x3
ffffffffc0203410:	ca450513          	addi	a0,a0,-860 # ffffffffc02060b0 <default_pmm_manager+0xa40>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203414:	6a85                	lui	s5,0x1
ffffffffc0203416:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203418:	d77fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020341c:	016a8023          	sb	s6,0(s5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0203420:	00042903          	lw	s2,0(s0)
ffffffffc0203424:	2901                	sext.w	s2,s2
ffffffffc0203426:	2a991a63          	bne	s2,s1,ffffffffc02036da <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020342a:	00003517          	auipc	a0,0x3
ffffffffc020342e:	cae50513          	addi	a0,a0,-850 # ffffffffc02060d8 <default_pmm_manager+0xa68>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203432:	6b91                	lui	s7,0x4
ffffffffc0203434:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203436:	d59fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020343a:	018b8023          	sb	s8,0(s7) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc020343e:	4004                	lw	s1,0(s0)
ffffffffc0203440:	2481                	sext.w	s1,s1
ffffffffc0203442:	27249c63          	bne	s1,s2,ffffffffc02036ba <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203446:	00003517          	auipc	a0,0x3
ffffffffc020344a:	cba50513          	addi	a0,a0,-838 # ffffffffc0206100 <default_pmm_manager+0xa90>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020344e:	6909                	lui	s2,0x2
ffffffffc0203450:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203452:	d3dfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203456:	01990023          	sb	s9,0(s2) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc020345a:	401c                	lw	a5,0(s0)
ffffffffc020345c:	2781                	sext.w	a5,a5
ffffffffc020345e:	22979e63          	bne	a5,s1,ffffffffc020369a <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203462:	00003517          	auipc	a0,0x3
ffffffffc0203466:	cc650513          	addi	a0,a0,-826 # ffffffffc0206128 <default_pmm_manager+0xab8>
ffffffffc020346a:	d25fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020346e:	6795                	lui	a5,0x5
ffffffffc0203470:	4739                	li	a4,14
ffffffffc0203472:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203476:	4004                	lw	s1,0(s0)
ffffffffc0203478:	4795                	li	a5,5
ffffffffc020347a:	2481                	sext.w	s1,s1
ffffffffc020347c:	1ef49f63          	bne	s1,a5,ffffffffc020367a <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203480:	00003517          	auipc	a0,0x3
ffffffffc0203484:	c8050513          	addi	a0,a0,-896 # ffffffffc0206100 <default_pmm_manager+0xa90>
ffffffffc0203488:	d07fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020348c:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203490:	401c                	lw	a5,0(s0)
ffffffffc0203492:	2781                	sext.w	a5,a5
ffffffffc0203494:	1c979363          	bne	a5,s1,ffffffffc020365a <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203498:	00003517          	auipc	a0,0x3
ffffffffc020349c:	c1850513          	addi	a0,a0,-1000 # ffffffffc02060b0 <default_pmm_manager+0xa40>
ffffffffc02034a0:	ceffc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02034a4:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc02034a8:	401c                	lw	a5,0(s0)
ffffffffc02034aa:	4719                	li	a4,6
ffffffffc02034ac:	2781                	sext.w	a5,a5
ffffffffc02034ae:	18e79663          	bne	a5,a4,ffffffffc020363a <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02034b2:	00003517          	auipc	a0,0x3
ffffffffc02034b6:	c4e50513          	addi	a0,a0,-946 # ffffffffc0206100 <default_pmm_manager+0xa90>
ffffffffc02034ba:	cd5fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02034be:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc02034c2:	401c                	lw	a5,0(s0)
ffffffffc02034c4:	471d                	li	a4,7
ffffffffc02034c6:	2781                	sext.w	a5,a5
ffffffffc02034c8:	14e79963          	bne	a5,a4,ffffffffc020361a <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02034cc:	00003517          	auipc	a0,0x3
ffffffffc02034d0:	ba450513          	addi	a0,a0,-1116 # ffffffffc0206070 <default_pmm_manager+0xa00>
ffffffffc02034d4:	cbbfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02034d8:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc02034dc:	401c                	lw	a5,0(s0)
ffffffffc02034de:	4721                	li	a4,8
ffffffffc02034e0:	2781                	sext.w	a5,a5
ffffffffc02034e2:	10e79c63          	bne	a5,a4,ffffffffc02035fa <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02034e6:	00003517          	auipc	a0,0x3
ffffffffc02034ea:	bf250513          	addi	a0,a0,-1038 # ffffffffc02060d8 <default_pmm_manager+0xa68>
ffffffffc02034ee:	ca1fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02034f2:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc02034f6:	401c                	lw	a5,0(s0)
ffffffffc02034f8:	4725                	li	a4,9
ffffffffc02034fa:	2781                	sext.w	a5,a5
ffffffffc02034fc:	0ce79f63          	bne	a5,a4,ffffffffc02035da <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203500:	00003517          	auipc	a0,0x3
ffffffffc0203504:	c2850513          	addi	a0,a0,-984 # ffffffffc0206128 <default_pmm_manager+0xab8>
ffffffffc0203508:	c87fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020350c:	6795                	lui	a5,0x5
ffffffffc020350e:	4739                	li	a4,14
ffffffffc0203510:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc0203514:	4004                	lw	s1,0(s0)
ffffffffc0203516:	47a9                	li	a5,10
ffffffffc0203518:	2481                	sext.w	s1,s1
ffffffffc020351a:	0af49063          	bne	s1,a5,ffffffffc02035ba <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020351e:	00003517          	auipc	a0,0x3
ffffffffc0203522:	b9250513          	addi	a0,a0,-1134 # ffffffffc02060b0 <default_pmm_manager+0xa40>
ffffffffc0203526:	c69fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020352a:	6785                	lui	a5,0x1
ffffffffc020352c:	0007c783          	lbu	a5,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0203530:	06979563          	bne	a5,s1,ffffffffc020359a <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0203534:	401c                	lw	a5,0(s0)
ffffffffc0203536:	472d                	li	a4,11
ffffffffc0203538:	2781                	sext.w	a5,a5
ffffffffc020353a:	04e79063          	bne	a5,a4,ffffffffc020357a <_fifo_check_swap+0x1ac>
}
ffffffffc020353e:	60e6                	ld	ra,88(sp)
ffffffffc0203540:	6446                	ld	s0,80(sp)
ffffffffc0203542:	64a6                	ld	s1,72(sp)
ffffffffc0203544:	6906                	ld	s2,64(sp)
ffffffffc0203546:	79e2                	ld	s3,56(sp)
ffffffffc0203548:	7a42                	ld	s4,48(sp)
ffffffffc020354a:	7aa2                	ld	s5,40(sp)
ffffffffc020354c:	7b02                	ld	s6,32(sp)
ffffffffc020354e:	6be2                	ld	s7,24(sp)
ffffffffc0203550:	6c42                	ld	s8,16(sp)
ffffffffc0203552:	6ca2                	ld	s9,8(sp)
ffffffffc0203554:	4501                	li	a0,0
ffffffffc0203556:	6125                	addi	sp,sp,96
ffffffffc0203558:	8082                	ret
    assert(pgfault_num==4);
ffffffffc020355a:	00003697          	auipc	a3,0x3
ffffffffc020355e:	9b668693          	addi	a3,a3,-1610 # ffffffffc0205f10 <default_pmm_manager+0x8a0>
ffffffffc0203562:	00002617          	auipc	a2,0x2
ffffffffc0203566:	d7660613          	addi	a2,a2,-650 # ffffffffc02052d8 <commands+0x870>
ffffffffc020356a:	05100593          	li	a1,81
ffffffffc020356e:	00003517          	auipc	a0,0x3
ffffffffc0203572:	b2a50513          	addi	a0,a0,-1238 # ffffffffc0206098 <default_pmm_manager+0xa28>
ffffffffc0203576:	edbfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==11);
ffffffffc020357a:	00003697          	auipc	a3,0x3
ffffffffc020357e:	c5e68693          	addi	a3,a3,-930 # ffffffffc02061d8 <default_pmm_manager+0xb68>
ffffffffc0203582:	00002617          	auipc	a2,0x2
ffffffffc0203586:	d5660613          	addi	a2,a2,-682 # ffffffffc02052d8 <commands+0x870>
ffffffffc020358a:	07300593          	li	a1,115
ffffffffc020358e:	00003517          	auipc	a0,0x3
ffffffffc0203592:	b0a50513          	addi	a0,a0,-1270 # ffffffffc0206098 <default_pmm_manager+0xa28>
ffffffffc0203596:	ebbfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020359a:	00003697          	auipc	a3,0x3
ffffffffc020359e:	c1668693          	addi	a3,a3,-1002 # ffffffffc02061b0 <default_pmm_manager+0xb40>
ffffffffc02035a2:	00002617          	auipc	a2,0x2
ffffffffc02035a6:	d3660613          	addi	a2,a2,-714 # ffffffffc02052d8 <commands+0x870>
ffffffffc02035aa:	07100593          	li	a1,113
ffffffffc02035ae:	00003517          	auipc	a0,0x3
ffffffffc02035b2:	aea50513          	addi	a0,a0,-1302 # ffffffffc0206098 <default_pmm_manager+0xa28>
ffffffffc02035b6:	e9bfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==10);
ffffffffc02035ba:	00003697          	auipc	a3,0x3
ffffffffc02035be:	be668693          	addi	a3,a3,-1050 # ffffffffc02061a0 <default_pmm_manager+0xb30>
ffffffffc02035c2:	00002617          	auipc	a2,0x2
ffffffffc02035c6:	d1660613          	addi	a2,a2,-746 # ffffffffc02052d8 <commands+0x870>
ffffffffc02035ca:	06f00593          	li	a1,111
ffffffffc02035ce:	00003517          	auipc	a0,0x3
ffffffffc02035d2:	aca50513          	addi	a0,a0,-1334 # ffffffffc0206098 <default_pmm_manager+0xa28>
ffffffffc02035d6:	e7bfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==9);
ffffffffc02035da:	00003697          	auipc	a3,0x3
ffffffffc02035de:	bb668693          	addi	a3,a3,-1098 # ffffffffc0206190 <default_pmm_manager+0xb20>
ffffffffc02035e2:	00002617          	auipc	a2,0x2
ffffffffc02035e6:	cf660613          	addi	a2,a2,-778 # ffffffffc02052d8 <commands+0x870>
ffffffffc02035ea:	06c00593          	li	a1,108
ffffffffc02035ee:	00003517          	auipc	a0,0x3
ffffffffc02035f2:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0206098 <default_pmm_manager+0xa28>
ffffffffc02035f6:	e5bfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==8);
ffffffffc02035fa:	00003697          	auipc	a3,0x3
ffffffffc02035fe:	b8668693          	addi	a3,a3,-1146 # ffffffffc0206180 <default_pmm_manager+0xb10>
ffffffffc0203602:	00002617          	auipc	a2,0x2
ffffffffc0203606:	cd660613          	addi	a2,a2,-810 # ffffffffc02052d8 <commands+0x870>
ffffffffc020360a:	06900593          	li	a1,105
ffffffffc020360e:	00003517          	auipc	a0,0x3
ffffffffc0203612:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0206098 <default_pmm_manager+0xa28>
ffffffffc0203616:	e3bfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==7);
ffffffffc020361a:	00003697          	auipc	a3,0x3
ffffffffc020361e:	b5668693          	addi	a3,a3,-1194 # ffffffffc0206170 <default_pmm_manager+0xb00>
ffffffffc0203622:	00002617          	auipc	a2,0x2
ffffffffc0203626:	cb660613          	addi	a2,a2,-842 # ffffffffc02052d8 <commands+0x870>
ffffffffc020362a:	06600593          	li	a1,102
ffffffffc020362e:	00003517          	auipc	a0,0x3
ffffffffc0203632:	a6a50513          	addi	a0,a0,-1430 # ffffffffc0206098 <default_pmm_manager+0xa28>
ffffffffc0203636:	e1bfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==6);
ffffffffc020363a:	00003697          	auipc	a3,0x3
ffffffffc020363e:	b2668693          	addi	a3,a3,-1242 # ffffffffc0206160 <default_pmm_manager+0xaf0>
ffffffffc0203642:	00002617          	auipc	a2,0x2
ffffffffc0203646:	c9660613          	addi	a2,a2,-874 # ffffffffc02052d8 <commands+0x870>
ffffffffc020364a:	06300593          	li	a1,99
ffffffffc020364e:	00003517          	auipc	a0,0x3
ffffffffc0203652:	a4a50513          	addi	a0,a0,-1462 # ffffffffc0206098 <default_pmm_manager+0xa28>
ffffffffc0203656:	dfbfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==5);
ffffffffc020365a:	00003697          	auipc	a3,0x3
ffffffffc020365e:	af668693          	addi	a3,a3,-1290 # ffffffffc0206150 <default_pmm_manager+0xae0>
ffffffffc0203662:	00002617          	auipc	a2,0x2
ffffffffc0203666:	c7660613          	addi	a2,a2,-906 # ffffffffc02052d8 <commands+0x870>
ffffffffc020366a:	06000593          	li	a1,96
ffffffffc020366e:	00003517          	auipc	a0,0x3
ffffffffc0203672:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0206098 <default_pmm_manager+0xa28>
ffffffffc0203676:	ddbfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==5);
ffffffffc020367a:	00003697          	auipc	a3,0x3
ffffffffc020367e:	ad668693          	addi	a3,a3,-1322 # ffffffffc0206150 <default_pmm_manager+0xae0>
ffffffffc0203682:	00002617          	auipc	a2,0x2
ffffffffc0203686:	c5660613          	addi	a2,a2,-938 # ffffffffc02052d8 <commands+0x870>
ffffffffc020368a:	05d00593          	li	a1,93
ffffffffc020368e:	00003517          	auipc	a0,0x3
ffffffffc0203692:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0206098 <default_pmm_manager+0xa28>
ffffffffc0203696:	dbbfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==4);
ffffffffc020369a:	00003697          	auipc	a3,0x3
ffffffffc020369e:	87668693          	addi	a3,a3,-1930 # ffffffffc0205f10 <default_pmm_manager+0x8a0>
ffffffffc02036a2:	00002617          	auipc	a2,0x2
ffffffffc02036a6:	c3660613          	addi	a2,a2,-970 # ffffffffc02052d8 <commands+0x870>
ffffffffc02036aa:	05a00593          	li	a1,90
ffffffffc02036ae:	00003517          	auipc	a0,0x3
ffffffffc02036b2:	9ea50513          	addi	a0,a0,-1558 # ffffffffc0206098 <default_pmm_manager+0xa28>
ffffffffc02036b6:	d9bfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==4);
ffffffffc02036ba:	00003697          	auipc	a3,0x3
ffffffffc02036be:	85668693          	addi	a3,a3,-1962 # ffffffffc0205f10 <default_pmm_manager+0x8a0>
ffffffffc02036c2:	00002617          	auipc	a2,0x2
ffffffffc02036c6:	c1660613          	addi	a2,a2,-1002 # ffffffffc02052d8 <commands+0x870>
ffffffffc02036ca:	05700593          	li	a1,87
ffffffffc02036ce:	00003517          	auipc	a0,0x3
ffffffffc02036d2:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0206098 <default_pmm_manager+0xa28>
ffffffffc02036d6:	d7bfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==4);
ffffffffc02036da:	00003697          	auipc	a3,0x3
ffffffffc02036de:	83668693          	addi	a3,a3,-1994 # ffffffffc0205f10 <default_pmm_manager+0x8a0>
ffffffffc02036e2:	00002617          	auipc	a2,0x2
ffffffffc02036e6:	bf660613          	addi	a2,a2,-1034 # ffffffffc02052d8 <commands+0x870>
ffffffffc02036ea:	05400593          	li	a1,84
ffffffffc02036ee:	00003517          	auipc	a0,0x3
ffffffffc02036f2:	9aa50513          	addi	a0,a0,-1622 # ffffffffc0206098 <default_pmm_manager+0xa28>
ffffffffc02036f6:	d5bfc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02036fa <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02036fa:	751c                	ld	a5,40(a0)
{
ffffffffc02036fc:	1141                	addi	sp,sp,-16
ffffffffc02036fe:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0203700:	cf91                	beqz	a5,ffffffffc020371c <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0203702:	ee0d                	bnez	a2,ffffffffc020373c <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0203704:	679c                	ld	a5,8(a5)
}
ffffffffc0203706:	60a2                	ld	ra,8(sp)
ffffffffc0203708:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc020370a:	6394                	ld	a3,0(a5)
ffffffffc020370c:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc020370e:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0203712:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203714:	e314                	sd	a3,0(a4)
ffffffffc0203716:	e19c                	sd	a5,0(a1)
}
ffffffffc0203718:	0141                	addi	sp,sp,16
ffffffffc020371a:	8082                	ret
         assert(head != NULL);
ffffffffc020371c:	00003697          	auipc	a3,0x3
ffffffffc0203720:	aec68693          	addi	a3,a3,-1300 # ffffffffc0206208 <default_pmm_manager+0xb98>
ffffffffc0203724:	00002617          	auipc	a2,0x2
ffffffffc0203728:	bb460613          	addi	a2,a2,-1100 # ffffffffc02052d8 <commands+0x870>
ffffffffc020372c:	04100593          	li	a1,65
ffffffffc0203730:	00003517          	auipc	a0,0x3
ffffffffc0203734:	96850513          	addi	a0,a0,-1688 # ffffffffc0206098 <default_pmm_manager+0xa28>
ffffffffc0203738:	d19fc0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(in_tick==0);
ffffffffc020373c:	00003697          	auipc	a3,0x3
ffffffffc0203740:	adc68693          	addi	a3,a3,-1316 # ffffffffc0206218 <default_pmm_manager+0xba8>
ffffffffc0203744:	00002617          	auipc	a2,0x2
ffffffffc0203748:	b9460613          	addi	a2,a2,-1132 # ffffffffc02052d8 <commands+0x870>
ffffffffc020374c:	04200593          	li	a1,66
ffffffffc0203750:	00003517          	auipc	a0,0x3
ffffffffc0203754:	94850513          	addi	a0,a0,-1720 # ffffffffc0206098 <default_pmm_manager+0xa28>
ffffffffc0203758:	cf9fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020375c <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc020375c:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203760:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0203762:	cb09                	beqz	a4,ffffffffc0203774 <_fifo_map_swappable+0x18>
ffffffffc0203764:	cb81                	beqz	a5,ffffffffc0203774 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203766:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203768:	e398                	sd	a4,0(a5)
}
ffffffffc020376a:	4501                	li	a0,0
ffffffffc020376c:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc020376e:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0203770:	f614                	sd	a3,40(a2)
ffffffffc0203772:	8082                	ret
{
ffffffffc0203774:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203776:	00003697          	auipc	a3,0x3
ffffffffc020377a:	a7268693          	addi	a3,a3,-1422 # ffffffffc02061e8 <default_pmm_manager+0xb78>
ffffffffc020377e:	00002617          	auipc	a2,0x2
ffffffffc0203782:	b5a60613          	addi	a2,a2,-1190 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203786:	03200593          	li	a1,50
ffffffffc020378a:	00003517          	auipc	a0,0x3
ffffffffc020378e:	90e50513          	addi	a0,a0,-1778 # ffffffffc0206098 <default_pmm_manager+0xa28>
{
ffffffffc0203792:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0203794:	cbdfc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203798 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203798:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020379a:	00003697          	auipc	a3,0x3
ffffffffc020379e:	aa668693          	addi	a3,a3,-1370 # ffffffffc0206240 <default_pmm_manager+0xbd0>
ffffffffc02037a2:	00002617          	auipc	a2,0x2
ffffffffc02037a6:	b3660613          	addi	a2,a2,-1226 # ffffffffc02052d8 <commands+0x870>
ffffffffc02037aa:	07e00593          	li	a1,126
ffffffffc02037ae:	00003517          	auipc	a0,0x3
ffffffffc02037b2:	ab250513          	addi	a0,a0,-1358 # ffffffffc0206260 <default_pmm_manager+0xbf0>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02037b6:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02037b8:	c99fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02037bc <mm_create>:
mm_create(void) {
ffffffffc02037bc:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02037be:	03000513          	li	a0,48
mm_create(void) {
ffffffffc02037c2:	e022                	sd	s0,0(sp)
ffffffffc02037c4:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02037c6:	9b0fe0ef          	jal	ra,ffffffffc0201976 <kmalloc>
ffffffffc02037ca:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02037cc:	c115                	beqz	a0,ffffffffc02037f0 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02037ce:	00012797          	auipc	a5,0x12
ffffffffc02037d2:	cca78793          	addi	a5,a5,-822 # ffffffffc0215498 <swap_init_ok>
ffffffffc02037d6:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc02037d8:	e408                	sd	a0,8(s0)
ffffffffc02037da:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02037dc:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02037e0:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02037e4:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02037e8:	2781                	sext.w	a5,a5
ffffffffc02037ea:	eb81                	bnez	a5,ffffffffc02037fa <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc02037ec:	02053423          	sd	zero,40(a0)
}
ffffffffc02037f0:	8522                	mv	a0,s0
ffffffffc02037f2:	60a2                	ld	ra,8(sp)
ffffffffc02037f4:	6402                	ld	s0,0(sp)
ffffffffc02037f6:	0141                	addi	sp,sp,16
ffffffffc02037f8:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02037fa:	a83ff0ef          	jal	ra,ffffffffc020327c <swap_init_mm>
}
ffffffffc02037fe:	8522                	mv	a0,s0
ffffffffc0203800:	60a2                	ld	ra,8(sp)
ffffffffc0203802:	6402                	ld	s0,0(sp)
ffffffffc0203804:	0141                	addi	sp,sp,16
ffffffffc0203806:	8082                	ret

ffffffffc0203808 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0203808:	1101                	addi	sp,sp,-32
ffffffffc020380a:	e04a                	sd	s2,0(sp)
ffffffffc020380c:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020380e:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0203812:	e822                	sd	s0,16(sp)
ffffffffc0203814:	e426                	sd	s1,8(sp)
ffffffffc0203816:	ec06                	sd	ra,24(sp)
ffffffffc0203818:	84ae                	mv	s1,a1
ffffffffc020381a:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020381c:	95afe0ef          	jal	ra,ffffffffc0201976 <kmalloc>
    if (vma != NULL) {
ffffffffc0203820:	c509                	beqz	a0,ffffffffc020382a <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0203822:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203826:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203828:	cd00                	sw	s0,24(a0)
}
ffffffffc020382a:	60e2                	ld	ra,24(sp)
ffffffffc020382c:	6442                	ld	s0,16(sp)
ffffffffc020382e:	64a2                	ld	s1,8(sp)
ffffffffc0203830:	6902                	ld	s2,0(sp)
ffffffffc0203832:	6105                	addi	sp,sp,32
ffffffffc0203834:	8082                	ret

ffffffffc0203836 <find_vma>:
    if (mm != NULL) {
ffffffffc0203836:	c51d                	beqz	a0,ffffffffc0203864 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0203838:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020383a:	c781                	beqz	a5,ffffffffc0203842 <find_vma+0xc>
ffffffffc020383c:	6798                	ld	a4,8(a5)
ffffffffc020383e:	02e5f663          	bleu	a4,a1,ffffffffc020386a <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0203842:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc0203844:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0203846:	00f50f63          	beq	a0,a5,ffffffffc0203864 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc020384a:	fe87b703          	ld	a4,-24(a5)
ffffffffc020384e:	fee5ebe3          	bltu	a1,a4,ffffffffc0203844 <find_vma+0xe>
ffffffffc0203852:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203856:	fee5f7e3          	bleu	a4,a1,ffffffffc0203844 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc020385a:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc020385c:	c781                	beqz	a5,ffffffffc0203864 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc020385e:	e91c                	sd	a5,16(a0)
}
ffffffffc0203860:	853e                	mv	a0,a5
ffffffffc0203862:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0203864:	4781                	li	a5,0
}
ffffffffc0203866:	853e                	mv	a0,a5
ffffffffc0203868:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020386a:	6b98                	ld	a4,16(a5)
ffffffffc020386c:	fce5fbe3          	bleu	a4,a1,ffffffffc0203842 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0203870:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0203872:	b7fd                	j	ffffffffc0203860 <find_vma+0x2a>

ffffffffc0203874 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203874:	6590                	ld	a2,8(a1)
ffffffffc0203876:	0105b803          	ld	a6,16(a1) # 1010 <BASE_ADDRESS-0xffffffffc01feff0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc020387a:	1141                	addi	sp,sp,-16
ffffffffc020387c:	e406                	sd	ra,8(sp)
ffffffffc020387e:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203880:	01066863          	bltu	a2,a6,ffffffffc0203890 <insert_vma_struct+0x1c>
ffffffffc0203884:	a8b9                	j	ffffffffc02038e2 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203886:	fe87b683          	ld	a3,-24(a5)
ffffffffc020388a:	04d66763          	bltu	a2,a3,ffffffffc02038d8 <insert_vma_struct+0x64>
ffffffffc020388e:	873e                	mv	a4,a5
ffffffffc0203890:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0203892:	fef51ae3          	bne	a0,a5,ffffffffc0203886 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0203896:	02a70463          	beq	a4,a0,ffffffffc02038be <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc020389a:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc020389e:	fe873883          	ld	a7,-24(a4)
ffffffffc02038a2:	08d8f063          	bleu	a3,a7,ffffffffc0203922 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02038a6:	04d66e63          	bltu	a2,a3,ffffffffc0203902 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc02038aa:	00f50a63          	beq	a0,a5,ffffffffc02038be <insert_vma_struct+0x4a>
ffffffffc02038ae:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02038b2:	0506e863          	bltu	a3,a6,ffffffffc0203902 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02038b6:	ff07b603          	ld	a2,-16(a5)
ffffffffc02038ba:	02c6f263          	bleu	a2,a3,ffffffffc02038de <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02038be:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc02038c0:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02038c2:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02038c6:	e390                	sd	a2,0(a5)
ffffffffc02038c8:	e710                	sd	a2,8(a4)
}
ffffffffc02038ca:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02038cc:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02038ce:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc02038d0:	2685                	addiw	a3,a3,1
ffffffffc02038d2:	d114                	sw	a3,32(a0)
}
ffffffffc02038d4:	0141                	addi	sp,sp,16
ffffffffc02038d6:	8082                	ret
    if (le_prev != list) {
ffffffffc02038d8:	fca711e3          	bne	a4,a0,ffffffffc020389a <insert_vma_struct+0x26>
ffffffffc02038dc:	bfd9                	j	ffffffffc02038b2 <insert_vma_struct+0x3e>
ffffffffc02038de:	ebbff0ef          	jal	ra,ffffffffc0203798 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02038e2:	00003697          	auipc	a3,0x3
ffffffffc02038e6:	a2e68693          	addi	a3,a3,-1490 # ffffffffc0206310 <default_pmm_manager+0xca0>
ffffffffc02038ea:	00002617          	auipc	a2,0x2
ffffffffc02038ee:	9ee60613          	addi	a2,a2,-1554 # ffffffffc02052d8 <commands+0x870>
ffffffffc02038f2:	08500593          	li	a1,133
ffffffffc02038f6:	00003517          	auipc	a0,0x3
ffffffffc02038fa:	96a50513          	addi	a0,a0,-1686 # ffffffffc0206260 <default_pmm_manager+0xbf0>
ffffffffc02038fe:	b53fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203902:	00003697          	auipc	a3,0x3
ffffffffc0203906:	a4e68693          	addi	a3,a3,-1458 # ffffffffc0206350 <default_pmm_manager+0xce0>
ffffffffc020390a:	00002617          	auipc	a2,0x2
ffffffffc020390e:	9ce60613          	addi	a2,a2,-1586 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203912:	07d00593          	li	a1,125
ffffffffc0203916:	00003517          	auipc	a0,0x3
ffffffffc020391a:	94a50513          	addi	a0,a0,-1718 # ffffffffc0206260 <default_pmm_manager+0xbf0>
ffffffffc020391e:	b33fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203922:	00003697          	auipc	a3,0x3
ffffffffc0203926:	a0e68693          	addi	a3,a3,-1522 # ffffffffc0206330 <default_pmm_manager+0xcc0>
ffffffffc020392a:	00002617          	auipc	a2,0x2
ffffffffc020392e:	9ae60613          	addi	a2,a2,-1618 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203932:	07c00593          	li	a1,124
ffffffffc0203936:	00003517          	auipc	a0,0x3
ffffffffc020393a:	92a50513          	addi	a0,a0,-1750 # ffffffffc0206260 <default_pmm_manager+0xbf0>
ffffffffc020393e:	b13fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203942 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0203942:	1141                	addi	sp,sp,-16
ffffffffc0203944:	e022                	sd	s0,0(sp)
ffffffffc0203946:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203948:	6508                	ld	a0,8(a0)
ffffffffc020394a:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc020394c:	00a40c63          	beq	s0,a0,ffffffffc0203964 <mm_destroy+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203950:	6118                	ld	a4,0(a0)
ffffffffc0203952:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0203954:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203956:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203958:	e398                	sd	a4,0(a5)
ffffffffc020395a:	8d8fe0ef          	jal	ra,ffffffffc0201a32 <kfree>
    return listelm->next;
ffffffffc020395e:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203960:	fea418e3          	bne	s0,a0,ffffffffc0203950 <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
ffffffffc0203964:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0203966:	6402                	ld	s0,0(sp)
ffffffffc0203968:	60a2                	ld	ra,8(sp)
ffffffffc020396a:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc020396c:	8c6fe06f          	j	ffffffffc0201a32 <kfree>

ffffffffc0203970 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0203970:	7139                	addi	sp,sp,-64
ffffffffc0203972:	f822                	sd	s0,48(sp)
ffffffffc0203974:	f426                	sd	s1,40(sp)
ffffffffc0203976:	fc06                	sd	ra,56(sp)
ffffffffc0203978:	f04a                	sd	s2,32(sp)
ffffffffc020397a:	ec4e                	sd	s3,24(sp)
ffffffffc020397c:	e852                	sd	s4,16(sp)
ffffffffc020397e:	e456                	sd	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    struct mm_struct *mm = mm_create();
ffffffffc0203980:	e3dff0ef          	jal	ra,ffffffffc02037bc <mm_create>
    assert(mm != NULL);
ffffffffc0203984:	842a                	mv	s0,a0
ffffffffc0203986:	03200493          	li	s1,50
ffffffffc020398a:	e919                	bnez	a0,ffffffffc02039a0 <vmm_init+0x30>
ffffffffc020398c:	a989                	j	ffffffffc0203dde <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc020398e:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203990:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203992:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203996:	14ed                	addi	s1,s1,-5
ffffffffc0203998:	8522                	mv	a0,s0
ffffffffc020399a:	edbff0ef          	jal	ra,ffffffffc0203874 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc020399e:	c88d                	beqz	s1,ffffffffc02039d0 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02039a0:	03000513          	li	a0,48
ffffffffc02039a4:	fd3fd0ef          	jal	ra,ffffffffc0201976 <kmalloc>
ffffffffc02039a8:	85aa                	mv	a1,a0
ffffffffc02039aa:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02039ae:	f165                	bnez	a0,ffffffffc020398e <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc02039b0:	00002697          	auipc	a3,0x2
ffffffffc02039b4:	42068693          	addi	a3,a3,1056 # ffffffffc0205dd0 <default_pmm_manager+0x760>
ffffffffc02039b8:	00002617          	auipc	a2,0x2
ffffffffc02039bc:	92060613          	addi	a2,a2,-1760 # ffffffffc02052d8 <commands+0x870>
ffffffffc02039c0:	0c900593          	li	a1,201
ffffffffc02039c4:	00003517          	auipc	a0,0x3
ffffffffc02039c8:	89c50513          	addi	a0,a0,-1892 # ffffffffc0206260 <default_pmm_manager+0xbf0>
ffffffffc02039cc:	a85fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc02039d0:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02039d4:	1f900913          	li	s2,505
ffffffffc02039d8:	a819                	j	ffffffffc02039ee <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc02039da:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02039dc:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02039de:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02039e2:	0495                	addi	s1,s1,5
ffffffffc02039e4:	8522                	mv	a0,s0
ffffffffc02039e6:	e8fff0ef          	jal	ra,ffffffffc0203874 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02039ea:	03248a63          	beq	s1,s2,ffffffffc0203a1e <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02039ee:	03000513          	li	a0,48
ffffffffc02039f2:	f85fd0ef          	jal	ra,ffffffffc0201976 <kmalloc>
ffffffffc02039f6:	85aa                	mv	a1,a0
ffffffffc02039f8:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02039fc:	fd79                	bnez	a0,ffffffffc02039da <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc02039fe:	00002697          	auipc	a3,0x2
ffffffffc0203a02:	3d268693          	addi	a3,a3,978 # ffffffffc0205dd0 <default_pmm_manager+0x760>
ffffffffc0203a06:	00002617          	auipc	a2,0x2
ffffffffc0203a0a:	8d260613          	addi	a2,a2,-1838 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203a0e:	0cf00593          	li	a1,207
ffffffffc0203a12:	00003517          	auipc	a0,0x3
ffffffffc0203a16:	84e50513          	addi	a0,a0,-1970 # ffffffffc0206260 <default_pmm_manager+0xbf0>
ffffffffc0203a1a:	a37fc0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc0203a1e:	6418                	ld	a4,8(s0)
ffffffffc0203a20:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0203a22:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0203a26:	2ee40063          	beq	s0,a4,ffffffffc0203d06 <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203a2a:	fe873603          	ld	a2,-24(a4)
ffffffffc0203a2e:	ffe78693          	addi	a3,a5,-2
ffffffffc0203a32:	24d61a63          	bne	a2,a3,ffffffffc0203c86 <vmm_init+0x316>
ffffffffc0203a36:	ff073683          	ld	a3,-16(a4)
ffffffffc0203a3a:	24f69663          	bne	a3,a5,ffffffffc0203c86 <vmm_init+0x316>
ffffffffc0203a3e:	0795                	addi	a5,a5,5
ffffffffc0203a40:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0203a42:	feb792e3          	bne	a5,a1,ffffffffc0203a26 <vmm_init+0xb6>
ffffffffc0203a46:	491d                	li	s2,7
ffffffffc0203a48:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203a4a:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203a4e:	85a6                	mv	a1,s1
ffffffffc0203a50:	8522                	mv	a0,s0
ffffffffc0203a52:	de5ff0ef          	jal	ra,ffffffffc0203836 <find_vma>
ffffffffc0203a56:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0203a58:	30050763          	beqz	a0,ffffffffc0203d66 <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0203a5c:	00148593          	addi	a1,s1,1
ffffffffc0203a60:	8522                	mv	a0,s0
ffffffffc0203a62:	dd5ff0ef          	jal	ra,ffffffffc0203836 <find_vma>
ffffffffc0203a66:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203a68:	2c050f63          	beqz	a0,ffffffffc0203d46 <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0203a6c:	85ca                	mv	a1,s2
ffffffffc0203a6e:	8522                	mv	a0,s0
ffffffffc0203a70:	dc7ff0ef          	jal	ra,ffffffffc0203836 <find_vma>
        assert(vma3 == NULL);
ffffffffc0203a74:	2a051963          	bnez	a0,ffffffffc0203d26 <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0203a78:	00348593          	addi	a1,s1,3
ffffffffc0203a7c:	8522                	mv	a0,s0
ffffffffc0203a7e:	db9ff0ef          	jal	ra,ffffffffc0203836 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203a82:	32051263          	bnez	a0,ffffffffc0203da6 <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0203a86:	00448593          	addi	a1,s1,4
ffffffffc0203a8a:	8522                	mv	a0,s0
ffffffffc0203a8c:	dabff0ef          	jal	ra,ffffffffc0203836 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203a90:	2e051b63          	bnez	a0,ffffffffc0203d86 <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203a94:	008a3783          	ld	a5,8(s4)
ffffffffc0203a98:	20979763          	bne	a5,s1,ffffffffc0203ca6 <vmm_init+0x336>
ffffffffc0203a9c:	010a3783          	ld	a5,16(s4)
ffffffffc0203aa0:	21279363          	bne	a5,s2,ffffffffc0203ca6 <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203aa4:	0089b783          	ld	a5,8(s3)
ffffffffc0203aa8:	20979f63          	bne	a5,s1,ffffffffc0203cc6 <vmm_init+0x356>
ffffffffc0203aac:	0109b783          	ld	a5,16(s3)
ffffffffc0203ab0:	21279b63          	bne	a5,s2,ffffffffc0203cc6 <vmm_init+0x356>
ffffffffc0203ab4:	0495                	addi	s1,s1,5
ffffffffc0203ab6:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203ab8:	f9549be3          	bne	s1,s5,ffffffffc0203a4e <vmm_init+0xde>
ffffffffc0203abc:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0203abe:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0203ac0:	85a6                	mv	a1,s1
ffffffffc0203ac2:	8522                	mv	a0,s0
ffffffffc0203ac4:	d73ff0ef          	jal	ra,ffffffffc0203836 <find_vma>
ffffffffc0203ac8:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0203acc:	c90d                	beqz	a0,ffffffffc0203afe <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203ace:	6914                	ld	a3,16(a0)
ffffffffc0203ad0:	6510                	ld	a2,8(a0)
ffffffffc0203ad2:	00003517          	auipc	a0,0x3
ffffffffc0203ad6:	99e50513          	addi	a0,a0,-1634 # ffffffffc0206470 <default_pmm_manager+0xe00>
ffffffffc0203ada:	eb4fc0ef          	jal	ra,ffffffffc020018e <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203ade:	00003697          	auipc	a3,0x3
ffffffffc0203ae2:	9ba68693          	addi	a3,a3,-1606 # ffffffffc0206498 <default_pmm_manager+0xe28>
ffffffffc0203ae6:	00001617          	auipc	a2,0x1
ffffffffc0203aea:	7f260613          	addi	a2,a2,2034 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203aee:	0f100593          	li	a1,241
ffffffffc0203af2:	00002517          	auipc	a0,0x2
ffffffffc0203af6:	76e50513          	addi	a0,a0,1902 # ffffffffc0206260 <default_pmm_manager+0xbf0>
ffffffffc0203afa:	957fc0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc0203afe:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0203b00:	fd2490e3          	bne	s1,s2,ffffffffc0203ac0 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0203b04:	8522                	mv	a0,s0
ffffffffc0203b06:	e3dff0ef          	jal	ra,ffffffffc0203942 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203b0a:	00003517          	auipc	a0,0x3
ffffffffc0203b0e:	9a650513          	addi	a0,a0,-1626 # ffffffffc02064b0 <default_pmm_manager+0xe40>
ffffffffc0203b12:	e7cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203b16:	92afe0ef          	jal	ra,ffffffffc0201c40 <nr_free_pages>
ffffffffc0203b1a:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0203b1c:	ca1ff0ef          	jal	ra,ffffffffc02037bc <mm_create>
ffffffffc0203b20:	00012797          	auipc	a5,0x12
ffffffffc0203b24:	aaa7bc23          	sd	a0,-1352(a5) # ffffffffc02155d8 <check_mm_struct>
ffffffffc0203b28:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0203b2a:	36050663          	beqz	a0,ffffffffc0203e96 <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203b2e:	00012797          	auipc	a5,0x12
ffffffffc0203b32:	95278793          	addi	a5,a5,-1710 # ffffffffc0215480 <boot_pgdir>
ffffffffc0203b36:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0203b3a:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203b3e:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0203b42:	2c079e63          	bnez	a5,ffffffffc0203e1e <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203b46:	03000513          	li	a0,48
ffffffffc0203b4a:	e2dfd0ef          	jal	ra,ffffffffc0201976 <kmalloc>
ffffffffc0203b4e:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0203b50:	18050b63          	beqz	a0,ffffffffc0203ce6 <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0203b54:	002007b7          	lui	a5,0x200
ffffffffc0203b58:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0203b5a:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203b5c:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203b5e:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0203b60:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0203b62:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0203b66:	d0fff0ef          	jal	ra,ffffffffc0203874 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203b6a:	10000593          	li	a1,256
ffffffffc0203b6e:	8526                	mv	a0,s1
ffffffffc0203b70:	cc7ff0ef          	jal	ra,ffffffffc0203836 <find_vma>
ffffffffc0203b74:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0203b78:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203b7c:	2ca41163          	bne	s0,a0,ffffffffc0203e3e <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0203b80:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0203b84:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0203b86:	fee79de3          	bne	a5,a4,ffffffffc0203b80 <vmm_init+0x210>
        sum += i;
ffffffffc0203b8a:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0203b8c:	10000793          	li	a5,256
        sum += i;
ffffffffc0203b90:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0203b94:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0203b98:	0007c683          	lbu	a3,0(a5)
ffffffffc0203b9c:	0785                	addi	a5,a5,1
ffffffffc0203b9e:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0203ba0:	fec79ce3          	bne	a5,a2,ffffffffc0203b98 <vmm_init+0x228>
    }
    assert(sum == 0);
ffffffffc0203ba4:	2c071963          	bnez	a4,ffffffffc0203e76 <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203ba8:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203bac:	00012a97          	auipc	s5,0x12
ffffffffc0203bb0:	8dca8a93          	addi	s5,s5,-1828 # ffffffffc0215488 <npage>
ffffffffc0203bb4:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203bb8:	078a                	slli	a5,a5,0x2
ffffffffc0203bba:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203bbc:	20e7f563          	bleu	a4,a5,ffffffffc0203dc6 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0203bc0:	00003697          	auipc	a3,0x3
ffffffffc0203bc4:	d9868693          	addi	a3,a3,-616 # ffffffffc0206958 <nbase>
ffffffffc0203bc8:	0006ba03          	ld	s4,0(a3)
ffffffffc0203bcc:	414786b3          	sub	a3,a5,s4
ffffffffc0203bd0:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0203bd2:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0203bd4:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0203bd6:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0203bd8:	83b1                	srli	a5,a5,0xc
ffffffffc0203bda:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203bdc:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203bde:	28e7f063          	bleu	a4,a5,ffffffffc0203e5e <vmm_init+0x4ee>
ffffffffc0203be2:	00012797          	auipc	a5,0x12
ffffffffc0203be6:	90678793          	addi	a5,a5,-1786 # ffffffffc02154e8 <va_pa_offset>
ffffffffc0203bea:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203bec:	4581                	li	a1,0
ffffffffc0203bee:	854a                	mv	a0,s2
ffffffffc0203bf0:	9436                	add	s0,s0,a3
ffffffffc0203bf2:	ac2fe0ef          	jal	ra,ffffffffc0201eb4 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203bf6:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0203bf8:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203bfc:	078a                	slli	a5,a5,0x2
ffffffffc0203bfe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203c00:	1ce7f363          	bleu	a4,a5,ffffffffc0203dc6 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0203c04:	00012417          	auipc	s0,0x12
ffffffffc0203c08:	8f440413          	addi	s0,s0,-1804 # ffffffffc02154f8 <pages>
ffffffffc0203c0c:	6008                	ld	a0,0(s0)
ffffffffc0203c0e:	414787b3          	sub	a5,a5,s4
ffffffffc0203c12:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0203c14:	953e                	add	a0,a0,a5
ffffffffc0203c16:	4585                	li	a1,1
ffffffffc0203c18:	fe3fd0ef          	jal	ra,ffffffffc0201bfa <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c1c:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203c20:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c24:	078a                	slli	a5,a5,0x2
ffffffffc0203c26:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203c28:	18e7ff63          	bleu	a4,a5,ffffffffc0203dc6 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0203c2c:	6008                	ld	a0,0(s0)
ffffffffc0203c2e:	414787b3          	sub	a5,a5,s4
ffffffffc0203c32:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0203c34:	4585                	li	a1,1
ffffffffc0203c36:	953e                	add	a0,a0,a5
ffffffffc0203c38:	fc3fd0ef          	jal	ra,ffffffffc0201bfa <free_pages>
    pgdir[0] = 0;
ffffffffc0203c3c:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0203c40:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0203c44:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0203c48:	8526                	mv	a0,s1
ffffffffc0203c4a:	cf9ff0ef          	jal	ra,ffffffffc0203942 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0203c4e:	00012797          	auipc	a5,0x12
ffffffffc0203c52:	9807b523          	sd	zero,-1654(a5) # ffffffffc02155d8 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203c56:	febfd0ef          	jal	ra,ffffffffc0201c40 <nr_free_pages>
ffffffffc0203c5a:	1aa99263          	bne	s3,a0,ffffffffc0203dfe <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203c5e:	00003517          	auipc	a0,0x3
ffffffffc0203c62:	8e250513          	addi	a0,a0,-1822 # ffffffffc0206540 <default_pmm_manager+0xed0>
ffffffffc0203c66:	d28fc0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0203c6a:	7442                	ld	s0,48(sp)
ffffffffc0203c6c:	70e2                	ld	ra,56(sp)
ffffffffc0203c6e:	74a2                	ld	s1,40(sp)
ffffffffc0203c70:	7902                	ld	s2,32(sp)
ffffffffc0203c72:	69e2                	ld	s3,24(sp)
ffffffffc0203c74:	6a42                	ld	s4,16(sp)
ffffffffc0203c76:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203c78:	00003517          	auipc	a0,0x3
ffffffffc0203c7c:	8e850513          	addi	a0,a0,-1816 # ffffffffc0206560 <default_pmm_manager+0xef0>
}
ffffffffc0203c80:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203c82:	d0cfc06f          	j	ffffffffc020018e <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203c86:	00002697          	auipc	a3,0x2
ffffffffc0203c8a:	70268693          	addi	a3,a3,1794 # ffffffffc0206388 <default_pmm_manager+0xd18>
ffffffffc0203c8e:	00001617          	auipc	a2,0x1
ffffffffc0203c92:	64a60613          	addi	a2,a2,1610 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203c96:	0d800593          	li	a1,216
ffffffffc0203c9a:	00002517          	auipc	a0,0x2
ffffffffc0203c9e:	5c650513          	addi	a0,a0,1478 # ffffffffc0206260 <default_pmm_manager+0xbf0>
ffffffffc0203ca2:	faefc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203ca6:	00002697          	auipc	a3,0x2
ffffffffc0203caa:	76a68693          	addi	a3,a3,1898 # ffffffffc0206410 <default_pmm_manager+0xda0>
ffffffffc0203cae:	00001617          	auipc	a2,0x1
ffffffffc0203cb2:	62a60613          	addi	a2,a2,1578 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203cb6:	0e800593          	li	a1,232
ffffffffc0203cba:	00002517          	auipc	a0,0x2
ffffffffc0203cbe:	5a650513          	addi	a0,a0,1446 # ffffffffc0206260 <default_pmm_manager+0xbf0>
ffffffffc0203cc2:	f8efc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203cc6:	00002697          	auipc	a3,0x2
ffffffffc0203cca:	77a68693          	addi	a3,a3,1914 # ffffffffc0206440 <default_pmm_manager+0xdd0>
ffffffffc0203cce:	00001617          	auipc	a2,0x1
ffffffffc0203cd2:	60a60613          	addi	a2,a2,1546 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203cd6:	0e900593          	li	a1,233
ffffffffc0203cda:	00002517          	auipc	a0,0x2
ffffffffc0203cde:	58650513          	addi	a0,a0,1414 # ffffffffc0206260 <default_pmm_manager+0xbf0>
ffffffffc0203ce2:	f6efc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(vma != NULL);
ffffffffc0203ce6:	00002697          	auipc	a3,0x2
ffffffffc0203cea:	0ea68693          	addi	a3,a3,234 # ffffffffc0205dd0 <default_pmm_manager+0x760>
ffffffffc0203cee:	00001617          	auipc	a2,0x1
ffffffffc0203cf2:	5ea60613          	addi	a2,a2,1514 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203cf6:	10800593          	li	a1,264
ffffffffc0203cfa:	00002517          	auipc	a0,0x2
ffffffffc0203cfe:	56650513          	addi	a0,a0,1382 # ffffffffc0206260 <default_pmm_manager+0xbf0>
ffffffffc0203d02:	f4efc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203d06:	00002697          	auipc	a3,0x2
ffffffffc0203d0a:	66a68693          	addi	a3,a3,1642 # ffffffffc0206370 <default_pmm_manager+0xd00>
ffffffffc0203d0e:	00001617          	auipc	a2,0x1
ffffffffc0203d12:	5ca60613          	addi	a2,a2,1482 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203d16:	0d600593          	li	a1,214
ffffffffc0203d1a:	00002517          	auipc	a0,0x2
ffffffffc0203d1e:	54650513          	addi	a0,a0,1350 # ffffffffc0206260 <default_pmm_manager+0xbf0>
ffffffffc0203d22:	f2efc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma3 == NULL);
ffffffffc0203d26:	00002697          	auipc	a3,0x2
ffffffffc0203d2a:	6ba68693          	addi	a3,a3,1722 # ffffffffc02063e0 <default_pmm_manager+0xd70>
ffffffffc0203d2e:	00001617          	auipc	a2,0x1
ffffffffc0203d32:	5aa60613          	addi	a2,a2,1450 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203d36:	0e200593          	li	a1,226
ffffffffc0203d3a:	00002517          	auipc	a0,0x2
ffffffffc0203d3e:	52650513          	addi	a0,a0,1318 # ffffffffc0206260 <default_pmm_manager+0xbf0>
ffffffffc0203d42:	f0efc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma2 != NULL);
ffffffffc0203d46:	00002697          	auipc	a3,0x2
ffffffffc0203d4a:	68a68693          	addi	a3,a3,1674 # ffffffffc02063d0 <default_pmm_manager+0xd60>
ffffffffc0203d4e:	00001617          	auipc	a2,0x1
ffffffffc0203d52:	58a60613          	addi	a2,a2,1418 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203d56:	0e000593          	li	a1,224
ffffffffc0203d5a:	00002517          	auipc	a0,0x2
ffffffffc0203d5e:	50650513          	addi	a0,a0,1286 # ffffffffc0206260 <default_pmm_manager+0xbf0>
ffffffffc0203d62:	eeefc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma1 != NULL);
ffffffffc0203d66:	00002697          	auipc	a3,0x2
ffffffffc0203d6a:	65a68693          	addi	a3,a3,1626 # ffffffffc02063c0 <default_pmm_manager+0xd50>
ffffffffc0203d6e:	00001617          	auipc	a2,0x1
ffffffffc0203d72:	56a60613          	addi	a2,a2,1386 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203d76:	0de00593          	li	a1,222
ffffffffc0203d7a:	00002517          	auipc	a0,0x2
ffffffffc0203d7e:	4e650513          	addi	a0,a0,1254 # ffffffffc0206260 <default_pmm_manager+0xbf0>
ffffffffc0203d82:	ecefc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma5 == NULL);
ffffffffc0203d86:	00002697          	auipc	a3,0x2
ffffffffc0203d8a:	67a68693          	addi	a3,a3,1658 # ffffffffc0206400 <default_pmm_manager+0xd90>
ffffffffc0203d8e:	00001617          	auipc	a2,0x1
ffffffffc0203d92:	54a60613          	addi	a2,a2,1354 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203d96:	0e600593          	li	a1,230
ffffffffc0203d9a:	00002517          	auipc	a0,0x2
ffffffffc0203d9e:	4c650513          	addi	a0,a0,1222 # ffffffffc0206260 <default_pmm_manager+0xbf0>
ffffffffc0203da2:	eaefc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma4 == NULL);
ffffffffc0203da6:	00002697          	auipc	a3,0x2
ffffffffc0203daa:	64a68693          	addi	a3,a3,1610 # ffffffffc02063f0 <default_pmm_manager+0xd80>
ffffffffc0203dae:	00001617          	auipc	a2,0x1
ffffffffc0203db2:	52a60613          	addi	a2,a2,1322 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203db6:	0e400593          	li	a1,228
ffffffffc0203dba:	00002517          	auipc	a0,0x2
ffffffffc0203dbe:	4a650513          	addi	a0,a0,1190 # ffffffffc0206260 <default_pmm_manager+0xbf0>
ffffffffc0203dc2:	e8efc0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203dc6:	00002617          	auipc	a2,0x2
ffffffffc0203dca:	95a60613          	addi	a2,a2,-1702 # ffffffffc0205720 <default_pmm_manager+0xb0>
ffffffffc0203dce:	06200593          	li	a1,98
ffffffffc0203dd2:	00002517          	auipc	a0,0x2
ffffffffc0203dd6:	91650513          	addi	a0,a0,-1770 # ffffffffc02056e8 <default_pmm_manager+0x78>
ffffffffc0203dda:	e76fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(mm != NULL);
ffffffffc0203dde:	00002697          	auipc	a3,0x2
ffffffffc0203de2:	fba68693          	addi	a3,a3,-70 # ffffffffc0205d98 <default_pmm_manager+0x728>
ffffffffc0203de6:	00001617          	auipc	a2,0x1
ffffffffc0203dea:	4f260613          	addi	a2,a2,1266 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203dee:	0c200593          	li	a1,194
ffffffffc0203df2:	00002517          	auipc	a0,0x2
ffffffffc0203df6:	46e50513          	addi	a0,a0,1134 # ffffffffc0206260 <default_pmm_manager+0xbf0>
ffffffffc0203dfa:	e56fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203dfe:	00002697          	auipc	a3,0x2
ffffffffc0203e02:	71a68693          	addi	a3,a3,1818 # ffffffffc0206518 <default_pmm_manager+0xea8>
ffffffffc0203e06:	00001617          	auipc	a2,0x1
ffffffffc0203e0a:	4d260613          	addi	a2,a2,1234 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203e0e:	12400593          	li	a1,292
ffffffffc0203e12:	00002517          	auipc	a0,0x2
ffffffffc0203e16:	44e50513          	addi	a0,a0,1102 # ffffffffc0206260 <default_pmm_manager+0xbf0>
ffffffffc0203e1a:	e36fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203e1e:	00002697          	auipc	a3,0x2
ffffffffc0203e22:	fa268693          	addi	a3,a3,-94 # ffffffffc0205dc0 <default_pmm_manager+0x750>
ffffffffc0203e26:	00001617          	auipc	a2,0x1
ffffffffc0203e2a:	4b260613          	addi	a2,a2,1202 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203e2e:	10500593          	li	a1,261
ffffffffc0203e32:	00002517          	auipc	a0,0x2
ffffffffc0203e36:	42e50513          	addi	a0,a0,1070 # ffffffffc0206260 <default_pmm_manager+0xbf0>
ffffffffc0203e3a:	e16fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203e3e:	00002697          	auipc	a3,0x2
ffffffffc0203e42:	6aa68693          	addi	a3,a3,1706 # ffffffffc02064e8 <default_pmm_manager+0xe78>
ffffffffc0203e46:	00001617          	auipc	a2,0x1
ffffffffc0203e4a:	49260613          	addi	a2,a2,1170 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203e4e:	10d00593          	li	a1,269
ffffffffc0203e52:	00002517          	auipc	a0,0x2
ffffffffc0203e56:	40e50513          	addi	a0,a0,1038 # ffffffffc0206260 <default_pmm_manager+0xbf0>
ffffffffc0203e5a:	df6fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203e5e:	00002617          	auipc	a2,0x2
ffffffffc0203e62:	86260613          	addi	a2,a2,-1950 # ffffffffc02056c0 <default_pmm_manager+0x50>
ffffffffc0203e66:	06900593          	li	a1,105
ffffffffc0203e6a:	00002517          	auipc	a0,0x2
ffffffffc0203e6e:	87e50513          	addi	a0,a0,-1922 # ffffffffc02056e8 <default_pmm_manager+0x78>
ffffffffc0203e72:	ddefc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(sum == 0);
ffffffffc0203e76:	00002697          	auipc	a3,0x2
ffffffffc0203e7a:	69268693          	addi	a3,a3,1682 # ffffffffc0206508 <default_pmm_manager+0xe98>
ffffffffc0203e7e:	00001617          	auipc	a2,0x1
ffffffffc0203e82:	45a60613          	addi	a2,a2,1114 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203e86:	11700593          	li	a1,279
ffffffffc0203e8a:	00002517          	auipc	a0,0x2
ffffffffc0203e8e:	3d650513          	addi	a0,a0,982 # ffffffffc0206260 <default_pmm_manager+0xbf0>
ffffffffc0203e92:	dbefc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203e96:	00002697          	auipc	a3,0x2
ffffffffc0203e9a:	63a68693          	addi	a3,a3,1594 # ffffffffc02064d0 <default_pmm_manager+0xe60>
ffffffffc0203e9e:	00001617          	auipc	a2,0x1
ffffffffc0203ea2:	43a60613          	addi	a2,a2,1082 # ffffffffc02052d8 <commands+0x870>
ffffffffc0203ea6:	10100593          	li	a1,257
ffffffffc0203eaa:	00002517          	auipc	a0,0x2
ffffffffc0203eae:	3b650513          	addi	a0,a0,950 # ffffffffc0206260 <default_pmm_manager+0xbf0>
ffffffffc0203eb2:	d9efc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203eb6 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203eb6:	1101                	addi	sp,sp,-32
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203eb8:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203eba:	e822                	sd	s0,16(sp)
ffffffffc0203ebc:	e426                	sd	s1,8(sp)
ffffffffc0203ebe:	ec06                	sd	ra,24(sp)
ffffffffc0203ec0:	e04a                	sd	s2,0(sp)
ffffffffc0203ec2:	8432                	mv	s0,a2
ffffffffc0203ec4:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203ec6:	971ff0ef          	jal	ra,ffffffffc0203836 <find_vma>

    pgfault_num++;
ffffffffc0203eca:	00011797          	auipc	a5,0x11
ffffffffc0203ece:	5d278793          	addi	a5,a5,1490 # ffffffffc021549c <pgfault_num>
ffffffffc0203ed2:	439c                	lw	a5,0(a5)
ffffffffc0203ed4:	2785                	addiw	a5,a5,1
ffffffffc0203ed6:	00011717          	auipc	a4,0x11
ffffffffc0203eda:	5cf72323          	sw	a5,1478(a4) # ffffffffc021549c <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203ede:	cd21                	beqz	a0,ffffffffc0203f36 <do_pgfault+0x80>
ffffffffc0203ee0:	651c                	ld	a5,8(a0)
ffffffffc0203ee2:	04f46a63          	bltu	s0,a5,ffffffffc0203f36 <do_pgfault+0x80>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203ee6:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203ee8:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203eea:	8b89                	andi	a5,a5,2
ffffffffc0203eec:	e78d                	bnez	a5,ffffffffc0203f16 <do_pgfault+0x60>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203eee:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203ef0:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203ef2:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203ef4:	85a2                	mv	a1,s0
ffffffffc0203ef6:	4605                	li	a2,1
ffffffffc0203ef8:	d89fd0ef          	jal	ra,ffffffffc0201c80 <get_pte>
ffffffffc0203efc:	cd31                	beqz	a0,ffffffffc0203f58 <do_pgfault+0xa2>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0203efe:	610c                	ld	a1,0(a0)
ffffffffc0203f00:	cd89                	beqz	a1,ffffffffc0203f1a <do_pgfault+0x64>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203f02:	00011797          	auipc	a5,0x11
ffffffffc0203f06:	59678793          	addi	a5,a5,1430 # ffffffffc0215498 <swap_init_ok>
ffffffffc0203f0a:	439c                	lw	a5,0(a5)
ffffffffc0203f0c:	2781                	sext.w	a5,a5
ffffffffc0203f0e:	cf8d                	beqz	a5,ffffffffc0203f48 <do_pgfault+0x92>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            page->pra_vaddr = addr;
ffffffffc0203f10:	02003c23          	sd	zero,56(zero) # 38 <BASE_ADDRESS-0xffffffffc01fffc8>
ffffffffc0203f14:	9002                	ebreak
        perm |= READ_WRITE;
ffffffffc0203f16:	495d                	li	s2,23
ffffffffc0203f18:	bfd9                	j	ffffffffc0203eee <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203f1a:	6c88                	ld	a0,24(s1)
ffffffffc0203f1c:	864a                	mv	a2,s2
ffffffffc0203f1e:	85a2                	mv	a1,s0
ffffffffc0203f20:	b57fe0ef          	jal	ra,ffffffffc0202a76 <pgdir_alloc_page>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203f24:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203f26:	c129                	beqz	a0,ffffffffc0203f68 <do_pgfault+0xb2>
failed:
    return ret;
}
ffffffffc0203f28:	60e2                	ld	ra,24(sp)
ffffffffc0203f2a:	6442                	ld	s0,16(sp)
ffffffffc0203f2c:	64a2                	ld	s1,8(sp)
ffffffffc0203f2e:	6902                	ld	s2,0(sp)
ffffffffc0203f30:	853e                	mv	a0,a5
ffffffffc0203f32:	6105                	addi	sp,sp,32
ffffffffc0203f34:	8082                	ret
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203f36:	85a2                	mv	a1,s0
ffffffffc0203f38:	00002517          	auipc	a0,0x2
ffffffffc0203f3c:	33850513          	addi	a0,a0,824 # ffffffffc0206270 <default_pmm_manager+0xc00>
ffffffffc0203f40:	a4efc0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = -E_INVAL;
ffffffffc0203f44:	57f5                	li	a5,-3
        goto failed;
ffffffffc0203f46:	b7cd                	j	ffffffffc0203f28 <do_pgfault+0x72>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203f48:	00002517          	auipc	a0,0x2
ffffffffc0203f4c:	3a050513          	addi	a0,a0,928 # ffffffffc02062e8 <default_pmm_manager+0xc78>
ffffffffc0203f50:	a3efc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203f54:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203f56:	bfc9                	j	ffffffffc0203f28 <do_pgfault+0x72>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0203f58:	00002517          	auipc	a0,0x2
ffffffffc0203f5c:	34850513          	addi	a0,a0,840 # ffffffffc02062a0 <default_pmm_manager+0xc30>
ffffffffc0203f60:	a2efc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203f64:	57f1                	li	a5,-4
        goto failed;
ffffffffc0203f66:	b7c9                	j	ffffffffc0203f28 <do_pgfault+0x72>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203f68:	00002517          	auipc	a0,0x2
ffffffffc0203f6c:	35850513          	addi	a0,a0,856 # ffffffffc02062c0 <default_pmm_manager+0xc50>
ffffffffc0203f70:	a1efc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203f74:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203f76:	bf4d                	j	ffffffffc0203f28 <do_pgfault+0x72>

ffffffffc0203f78 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203f78:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203f7a:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203f7c:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203f7e:	dfefc0ef          	jal	ra,ffffffffc020057c <ide_device_valid>
ffffffffc0203f82:	cd01                	beqz	a0,ffffffffc0203f9a <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203f84:	4505                	li	a0,1
ffffffffc0203f86:	dfcfc0ef          	jal	ra,ffffffffc0200582 <ide_device_size>
}
ffffffffc0203f8a:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203f8c:	810d                	srli	a0,a0,0x3
ffffffffc0203f8e:	00011797          	auipc	a5,0x11
ffffffffc0203f92:	5ea7bd23          	sd	a0,1530(a5) # ffffffffc0215588 <max_swap_offset>
}
ffffffffc0203f96:	0141                	addi	sp,sp,16
ffffffffc0203f98:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203f9a:	00002617          	auipc	a2,0x2
ffffffffc0203f9e:	5de60613          	addi	a2,a2,1502 # ffffffffc0206578 <default_pmm_manager+0xf08>
ffffffffc0203fa2:	45b5                	li	a1,13
ffffffffc0203fa4:	00002517          	auipc	a0,0x2
ffffffffc0203fa8:	5f450513          	addi	a0,a0,1524 # ffffffffc0206598 <default_pmm_manager+0xf28>
ffffffffc0203fac:	ca4fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203fb0 <swapfs_write>:
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203fb0:	1141                	addi	sp,sp,-16
ffffffffc0203fb2:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203fb4:	00855793          	srli	a5,a0,0x8
ffffffffc0203fb8:	cfb9                	beqz	a5,ffffffffc0204016 <swapfs_write+0x66>
ffffffffc0203fba:	00011717          	auipc	a4,0x11
ffffffffc0203fbe:	5ce70713          	addi	a4,a4,1486 # ffffffffc0215588 <max_swap_offset>
ffffffffc0203fc2:	6318                	ld	a4,0(a4)
ffffffffc0203fc4:	04e7f963          	bleu	a4,a5,ffffffffc0204016 <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0203fc8:	00011717          	auipc	a4,0x11
ffffffffc0203fcc:	53070713          	addi	a4,a4,1328 # ffffffffc02154f8 <pages>
ffffffffc0203fd0:	6310                	ld	a2,0(a4)
ffffffffc0203fd2:	00003717          	auipc	a4,0x3
ffffffffc0203fd6:	98670713          	addi	a4,a4,-1658 # ffffffffc0206958 <nbase>
    return KADDR(page2pa(page));
ffffffffc0203fda:	00011697          	auipc	a3,0x11
ffffffffc0203fde:	4ae68693          	addi	a3,a3,1198 # ffffffffc0215488 <npage>
    return page - pages + nbase;
ffffffffc0203fe2:	40c58633          	sub	a2,a1,a2
ffffffffc0203fe6:	630c                	ld	a1,0(a4)
ffffffffc0203fe8:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0203fea:	577d                	li	a4,-1
ffffffffc0203fec:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0203fee:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0203ff0:	8331                	srli	a4,a4,0xc
ffffffffc0203ff2:	8f71                	and	a4,a4,a2
ffffffffc0203ff4:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203ff8:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0203ffa:	02d77a63          	bleu	a3,a4,ffffffffc020402e <swapfs_write+0x7e>
ffffffffc0203ffe:	00011797          	auipc	a5,0x11
ffffffffc0204002:	4ea78793          	addi	a5,a5,1258 # ffffffffc02154e8 <va_pa_offset>
ffffffffc0204006:	639c                	ld	a5,0(a5)
}
ffffffffc0204008:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020400a:	46a1                	li	a3,8
ffffffffc020400c:	963e                	add	a2,a2,a5
ffffffffc020400e:	4505                	li	a0,1
}
ffffffffc0204010:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204012:	d76fc06f          	j	ffffffffc0200588 <ide_write_secs>
ffffffffc0204016:	86aa                	mv	a3,a0
ffffffffc0204018:	00002617          	auipc	a2,0x2
ffffffffc020401c:	59860613          	addi	a2,a2,1432 # ffffffffc02065b0 <default_pmm_manager+0xf40>
ffffffffc0204020:	45e5                	li	a1,25
ffffffffc0204022:	00002517          	auipc	a0,0x2
ffffffffc0204026:	57650513          	addi	a0,a0,1398 # ffffffffc0206598 <default_pmm_manager+0xf28>
ffffffffc020402a:	c26fc0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc020402e:	86b2                	mv	a3,a2
ffffffffc0204030:	06900593          	li	a1,105
ffffffffc0204034:	00001617          	auipc	a2,0x1
ffffffffc0204038:	68c60613          	addi	a2,a2,1676 # ffffffffc02056c0 <default_pmm_manager+0x50>
ffffffffc020403c:	00001517          	auipc	a0,0x1
ffffffffc0204040:	6ac50513          	addi	a0,a0,1708 # ffffffffc02056e8 <default_pmm_manager+0x78>
ffffffffc0204044:	c0cfc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0204048 <set_proc_name>:
    return proc;
}

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204048:	1101                	addi	sp,sp,-32
ffffffffc020404a:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020404c:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204050:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204052:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204054:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204056:	8522                	mv	a0,s0
ffffffffc0204058:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020405a:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020405c:	07f000ef          	jal	ra,ffffffffc02048da <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204060:	8522                	mv	a0,s0
}
ffffffffc0204062:	6442                	ld	s0,16(sp)
ffffffffc0204064:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204066:	85a6                	mv	a1,s1
}
ffffffffc0204068:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020406a:	463d                	li	a2,15
}
ffffffffc020406c:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020406e:	07f0006f          	j	ffffffffc02048ec <memcpy>

ffffffffc0204072 <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
ffffffffc0204072:	1101                	addi	sp,sp,-32
ffffffffc0204074:	e822                	sd	s0,16(sp)
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
ffffffffc0204076:	00011417          	auipc	s0,0x11
ffffffffc020407a:	3e240413          	addi	s0,s0,994 # ffffffffc0215458 <name.1565>
get_proc_name(struct proc_struct *proc) {
ffffffffc020407e:	e426                	sd	s1,8(sp)
    memset(name, 0, sizeof(name));
ffffffffc0204080:	4641                	li	a2,16
get_proc_name(struct proc_struct *proc) {
ffffffffc0204082:	84aa                	mv	s1,a0
    memset(name, 0, sizeof(name));
ffffffffc0204084:	4581                	li	a1,0
ffffffffc0204086:	8522                	mv	a0,s0
get_proc_name(struct proc_struct *proc) {
ffffffffc0204088:	ec06                	sd	ra,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc020408a:	051000ef          	jal	ra,ffffffffc02048da <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc020408e:	8522                	mv	a0,s0
}
ffffffffc0204090:	6442                	ld	s0,16(sp)
ffffffffc0204092:	60e2                	ld	ra,24(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0204094:	0b448593          	addi	a1,s1,180
}
ffffffffc0204098:	64a2                	ld	s1,8(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc020409a:	463d                	li	a2,15
}
ffffffffc020409c:	6105                	addi	sp,sp,32
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc020409e:	04f0006f          	j	ffffffffc02048ec <memcpy>

ffffffffc02040a2 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02040a2:	00011797          	auipc	a5,0x11
ffffffffc02040a6:	3fe78793          	addi	a5,a5,1022 # ffffffffc02154a0 <current>
ffffffffc02040aa:	639c                	ld	a5,0(a5)
init_main(void *arg) {
ffffffffc02040ac:	1101                	addi	sp,sp,-32
ffffffffc02040ae:	e426                	sd	s1,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02040b0:	43c4                	lw	s1,4(a5)
init_main(void *arg) {
ffffffffc02040b2:	e822                	sd	s0,16(sp)
ffffffffc02040b4:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02040b6:	853e                	mv	a0,a5
init_main(void *arg) {
ffffffffc02040b8:	ec06                	sd	ra,24(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02040ba:	fb9ff0ef          	jal	ra,ffffffffc0204072 <get_proc_name>
ffffffffc02040be:	862a                	mv	a2,a0
ffffffffc02040c0:	85a6                	mv	a1,s1
ffffffffc02040c2:	00002517          	auipc	a0,0x2
ffffffffc02040c6:	53e50513          	addi	a0,a0,1342 # ffffffffc0206600 <default_pmm_manager+0xf90>
ffffffffc02040ca:	8c4fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc02040ce:	85a2                	mv	a1,s0
ffffffffc02040d0:	00002517          	auipc	a0,0x2
ffffffffc02040d4:	55850513          	addi	a0,a0,1368 # ffffffffc0206628 <default_pmm_manager+0xfb8>
ffffffffc02040d8:	8b6fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc02040dc:	00002517          	auipc	a0,0x2
ffffffffc02040e0:	55c50513          	addi	a0,a0,1372 # ffffffffc0206638 <default_pmm_manager+0xfc8>
ffffffffc02040e4:	8aafc0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
}
ffffffffc02040e8:	60e2                	ld	ra,24(sp)
ffffffffc02040ea:	6442                	ld	s0,16(sp)
ffffffffc02040ec:	64a2                	ld	s1,8(sp)
ffffffffc02040ee:	4501                	li	a0,0
ffffffffc02040f0:	6105                	addi	sp,sp,32
ffffffffc02040f2:	8082                	ret

ffffffffc02040f4 <proc_run>:
}
ffffffffc02040f4:	8082                	ret

ffffffffc02040f6 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc02040f6:	0005071b          	sext.w	a4,a0
ffffffffc02040fa:	6789                	lui	a5,0x2
ffffffffc02040fc:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204100:	17f9                	addi	a5,a5,-2
ffffffffc0204102:	04d7e063          	bltu	a5,a3,ffffffffc0204142 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0204106:	1141                	addi	sp,sp,-16
ffffffffc0204108:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020410a:	45a9                	li	a1,10
ffffffffc020410c:	842a                	mv	s0,a0
ffffffffc020410e:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc0204110:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204112:	31a000ef          	jal	ra,ffffffffc020442c <hash32>
ffffffffc0204116:	02051693          	slli	a3,a0,0x20
ffffffffc020411a:	82f1                	srli	a3,a3,0x1c
ffffffffc020411c:	0000d517          	auipc	a0,0xd
ffffffffc0204120:	33c50513          	addi	a0,a0,828 # ffffffffc0211458 <hash_list>
ffffffffc0204124:	96aa                	add	a3,a3,a0
ffffffffc0204126:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204128:	a029                	j	ffffffffc0204132 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc020412a:	f2c7a703          	lw	a4,-212(a5) # 1f2c <BASE_ADDRESS-0xffffffffc01fe0d4>
ffffffffc020412e:	00870c63          	beq	a4,s0,ffffffffc0204146 <find_proc+0x50>
ffffffffc0204132:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204134:	fef69be3          	bne	a3,a5,ffffffffc020412a <find_proc+0x34>
}
ffffffffc0204138:	60a2                	ld	ra,8(sp)
ffffffffc020413a:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc020413c:	4501                	li	a0,0
}
ffffffffc020413e:	0141                	addi	sp,sp,16
ffffffffc0204140:	8082                	ret
    return NULL;
ffffffffc0204142:	4501                	li	a0,0
}
ffffffffc0204144:	8082                	ret
ffffffffc0204146:	60a2                	ld	ra,8(sp)
ffffffffc0204148:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020414a:	f2878513          	addi	a0,a5,-216
}
ffffffffc020414e:	0141                	addi	sp,sp,16
ffffffffc0204150:	8082                	ret

ffffffffc0204152 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0204152:	7169                	addi	sp,sp,-304
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204154:	12000613          	li	a2,288
ffffffffc0204158:	4581                	li	a1,0
ffffffffc020415a:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020415c:	f606                	sd	ra,296(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020415e:	77c000ef          	jal	ra,ffffffffc02048da <memset>
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204162:	100027f3          	csrr	a5,sstatus
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204166:	00011797          	auipc	a5,0x11
ffffffffc020416a:	35278793          	addi	a5,a5,850 # ffffffffc02154b8 <nr_process>
ffffffffc020416e:	4388                	lw	a0,0(a5)
}
ffffffffc0204170:	70b2                	ld	ra,296(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204172:	6785                	lui	a5,0x1
    int ret = -E_NO_FREE_PROC;
ffffffffc0204174:	00f52533          	slt	a0,a0,a5
}
ffffffffc0204178:	156d                	addi	a0,a0,-5
ffffffffc020417a:	6155                	addi	sp,sp,304
ffffffffc020417c:	8082                	ret

ffffffffc020417e <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc020417e:	00011797          	auipc	a5,0x11
ffffffffc0204182:	46278793          	addi	a5,a5,1122 # ffffffffc02155e0 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0204186:	1101                	addi	sp,sp,-32
ffffffffc0204188:	00011717          	auipc	a4,0x11
ffffffffc020418c:	46f73023          	sd	a5,1120(a4) # ffffffffc02155e8 <proc_list+0x8>
ffffffffc0204190:	00011717          	auipc	a4,0x11
ffffffffc0204194:	44f73823          	sd	a5,1104(a4) # ffffffffc02155e0 <proc_list>
ffffffffc0204198:	ec06                	sd	ra,24(sp)
ffffffffc020419a:	e822                	sd	s0,16(sp)
ffffffffc020419c:	e426                	sd	s1,8(sp)
ffffffffc020419e:	e04a                	sd	s2,0(sp)
ffffffffc02041a0:	0000d797          	auipc	a5,0xd
ffffffffc02041a4:	2b878793          	addi	a5,a5,696 # ffffffffc0211458 <hash_list>
ffffffffc02041a8:	00011717          	auipc	a4,0x11
ffffffffc02041ac:	2b070713          	addi	a4,a4,688 # ffffffffc0215458 <name.1565>
ffffffffc02041b0:	e79c                	sd	a5,8(a5)
ffffffffc02041b2:	e39c                	sd	a5,0(a5)
ffffffffc02041b4:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc02041b6:	fee79de3          	bne	a5,a4,ffffffffc02041b0 <proc_init+0x32>
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02041ba:	0e800513          	li	a0,232
ffffffffc02041be:	fb8fd0ef          	jal	ra,ffffffffc0201976 <kmalloc>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc02041c2:	00011797          	auipc	a5,0x11
ffffffffc02041c6:	2ea7b323          	sd	a0,742(a5) # ffffffffc02154a8 <idleproc>
ffffffffc02041ca:	00011417          	auipc	s0,0x11
ffffffffc02041ce:	2de40413          	addi	s0,s0,734 # ffffffffc02154a8 <idleproc>
ffffffffc02041d2:	12050a63          	beqz	a0,ffffffffc0204306 <proc_init+0x188>
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02041d6:	07000513          	li	a0,112
ffffffffc02041da:	f9cfd0ef          	jal	ra,ffffffffc0201976 <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02041de:	07000613          	li	a2,112
ffffffffc02041e2:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02041e4:	84aa                	mv	s1,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02041e6:	6f4000ef          	jal	ra,ffffffffc02048da <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc02041ea:	6008                	ld	a0,0(s0)
ffffffffc02041ec:	85a6                	mv	a1,s1
ffffffffc02041ee:	07000613          	li	a2,112
ffffffffc02041f2:	03050513          	addi	a0,a0,48
ffffffffc02041f6:	70e000ef          	jal	ra,ffffffffc0204904 <memcmp>
ffffffffc02041fa:	892a                	mv	s2,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02041fc:	453d                	li	a0,15
ffffffffc02041fe:	f78fd0ef          	jal	ra,ffffffffc0201976 <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0204202:	463d                	li	a2,15
ffffffffc0204204:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc0204206:	84aa                	mv	s1,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0204208:	6d2000ef          	jal	ra,ffffffffc02048da <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc020420c:	6008                	ld	a0,0(s0)
ffffffffc020420e:	463d                	li	a2,15
ffffffffc0204210:	85a6                	mv	a1,s1
ffffffffc0204212:	0b450513          	addi	a0,a0,180
ffffffffc0204216:	6ee000ef          	jal	ra,ffffffffc0204904 <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc020421a:	601c                	ld	a5,0(s0)
ffffffffc020421c:	00011717          	auipc	a4,0x11
ffffffffc0204220:	2d470713          	addi	a4,a4,724 # ffffffffc02154f0 <boot_cr3>
ffffffffc0204224:	6318                	ld	a4,0(a4)
ffffffffc0204226:	77d4                	ld	a3,168(a5)
ffffffffc0204228:	08e68e63          	beq	a3,a4,ffffffffc02042c4 <proc_init+0x146>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc020422c:	4709                	li	a4,2
ffffffffc020422e:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204230:	00003717          	auipc	a4,0x3
ffffffffc0204234:	dd070713          	addi	a4,a4,-560 # ffffffffc0207000 <bootstack>
ffffffffc0204238:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;
ffffffffc020423a:	4705                	li	a4,1
ffffffffc020423c:	cf98                	sw	a4,24(a5)
    set_proc_name(idleproc, "idle");
ffffffffc020423e:	00002597          	auipc	a1,0x2
ffffffffc0204242:	44a58593          	addi	a1,a1,1098 # ffffffffc0206688 <default_pmm_manager+0x1018>
ffffffffc0204246:	853e                	mv	a0,a5
ffffffffc0204248:	e01ff0ef          	jal	ra,ffffffffc0204048 <set_proc_name>
    nr_process ++;
ffffffffc020424c:	00011797          	auipc	a5,0x11
ffffffffc0204250:	26c78793          	addi	a5,a5,620 # ffffffffc02154b8 <nr_process>
ffffffffc0204254:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0204256:	6018                	ld	a4,0(s0)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204258:	4601                	li	a2,0
    nr_process ++;
ffffffffc020425a:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc020425c:	00002597          	auipc	a1,0x2
ffffffffc0204260:	43458593          	addi	a1,a1,1076 # ffffffffc0206690 <default_pmm_manager+0x1020>
ffffffffc0204264:	00000517          	auipc	a0,0x0
ffffffffc0204268:	e3e50513          	addi	a0,a0,-450 # ffffffffc02040a2 <init_main>
    nr_process ++;
ffffffffc020426c:	00011697          	auipc	a3,0x11
ffffffffc0204270:	24f6a623          	sw	a5,588(a3) # ffffffffc02154b8 <nr_process>
    current = idleproc;
ffffffffc0204274:	00011797          	auipc	a5,0x11
ffffffffc0204278:	22e7b623          	sd	a4,556(a5) # ffffffffc02154a0 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc020427c:	ed7ff0ef          	jal	ra,ffffffffc0204152 <kernel_thread>
    if (pid <= 0) {
ffffffffc0204280:	0ca05f63          	blez	a0,ffffffffc020435e <proc_init+0x1e0>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0204284:	e73ff0ef          	jal	ra,ffffffffc02040f6 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0204288:	00002597          	auipc	a1,0x2
ffffffffc020428c:	43858593          	addi	a1,a1,1080 # ffffffffc02066c0 <default_pmm_manager+0x1050>
    initproc = find_proc(pid);
ffffffffc0204290:	00011797          	auipc	a5,0x11
ffffffffc0204294:	22a7b023          	sd	a0,544(a5) # ffffffffc02154b0 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0204298:	db1ff0ef          	jal	ra,ffffffffc0204048 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020429c:	601c                	ld	a5,0(s0)
ffffffffc020429e:	c3c5                	beqz	a5,ffffffffc020433e <proc_init+0x1c0>
ffffffffc02042a0:	43dc                	lw	a5,4(a5)
ffffffffc02042a2:	efd1                	bnez	a5,ffffffffc020433e <proc_init+0x1c0>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02042a4:	00011797          	auipc	a5,0x11
ffffffffc02042a8:	20c78793          	addi	a5,a5,524 # ffffffffc02154b0 <initproc>
ffffffffc02042ac:	639c                	ld	a5,0(a5)
ffffffffc02042ae:	cba5                	beqz	a5,ffffffffc020431e <proc_init+0x1a0>
ffffffffc02042b0:	43d8                	lw	a4,4(a5)
ffffffffc02042b2:	4785                	li	a5,1
ffffffffc02042b4:	06f71563          	bne	a4,a5,ffffffffc020431e <proc_init+0x1a0>
}
ffffffffc02042b8:	60e2                	ld	ra,24(sp)
ffffffffc02042ba:	6442                	ld	s0,16(sp)
ffffffffc02042bc:	64a2                	ld	s1,8(sp)
ffffffffc02042be:	6902                	ld	s2,0(sp)
ffffffffc02042c0:	6105                	addi	sp,sp,32
ffffffffc02042c2:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc02042c4:	73d8                	ld	a4,160(a5)
ffffffffc02042c6:	f33d                	bnez	a4,ffffffffc020422c <proc_init+0xae>
ffffffffc02042c8:	f60912e3          	bnez	s2,ffffffffc020422c <proc_init+0xae>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc02042cc:	6394                	ld	a3,0(a5)
ffffffffc02042ce:	577d                	li	a4,-1
ffffffffc02042d0:	1702                	slli	a4,a4,0x20
ffffffffc02042d2:	f4e69de3          	bne	a3,a4,ffffffffc020422c <proc_init+0xae>
ffffffffc02042d6:	4798                	lw	a4,8(a5)
ffffffffc02042d8:	fb31                	bnez	a4,ffffffffc020422c <proc_init+0xae>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc02042da:	6b98                	ld	a4,16(a5)
ffffffffc02042dc:	fb21                	bnez	a4,ffffffffc020422c <proc_init+0xae>
ffffffffc02042de:	4f98                	lw	a4,24(a5)
ffffffffc02042e0:	2701                	sext.w	a4,a4
ffffffffc02042e2:	f729                	bnez	a4,ffffffffc020422c <proc_init+0xae>
ffffffffc02042e4:	7398                	ld	a4,32(a5)
ffffffffc02042e6:	f339                	bnez	a4,ffffffffc020422c <proc_init+0xae>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc02042e8:	7798                	ld	a4,40(a5)
ffffffffc02042ea:	f329                	bnez	a4,ffffffffc020422c <proc_init+0xae>
ffffffffc02042ec:	0b07a703          	lw	a4,176(a5)
ffffffffc02042f0:	8f49                	or	a4,a4,a0
ffffffffc02042f2:	2701                	sext.w	a4,a4
ffffffffc02042f4:	ff05                	bnez	a4,ffffffffc020422c <proc_init+0xae>
        cprintf("alloc_proc() correct!\n");
ffffffffc02042f6:	00002517          	auipc	a0,0x2
ffffffffc02042fa:	37a50513          	addi	a0,a0,890 # ffffffffc0206670 <default_pmm_manager+0x1000>
ffffffffc02042fe:	e91fb0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0204302:	601c                	ld	a5,0(s0)
ffffffffc0204304:	b725                	j	ffffffffc020422c <proc_init+0xae>
        panic("cannot alloc idleproc.\n");
ffffffffc0204306:	00002617          	auipc	a2,0x2
ffffffffc020430a:	35260613          	addi	a2,a2,850 # ffffffffc0206658 <default_pmm_manager+0xfe8>
ffffffffc020430e:	15800593          	li	a1,344
ffffffffc0204312:	00002517          	auipc	a0,0x2
ffffffffc0204316:	2d650513          	addi	a0,a0,726 # ffffffffc02065e8 <default_pmm_manager+0xf78>
ffffffffc020431a:	936fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020431e:	00002697          	auipc	a3,0x2
ffffffffc0204322:	3d268693          	addi	a3,a3,978 # ffffffffc02066f0 <default_pmm_manager+0x1080>
ffffffffc0204326:	00001617          	auipc	a2,0x1
ffffffffc020432a:	fb260613          	addi	a2,a2,-78 # ffffffffc02052d8 <commands+0x870>
ffffffffc020432e:	17f00593          	li	a1,383
ffffffffc0204332:	00002517          	auipc	a0,0x2
ffffffffc0204336:	2b650513          	addi	a0,a0,694 # ffffffffc02065e8 <default_pmm_manager+0xf78>
ffffffffc020433a:	916fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020433e:	00002697          	auipc	a3,0x2
ffffffffc0204342:	38a68693          	addi	a3,a3,906 # ffffffffc02066c8 <default_pmm_manager+0x1058>
ffffffffc0204346:	00001617          	auipc	a2,0x1
ffffffffc020434a:	f9260613          	addi	a2,a2,-110 # ffffffffc02052d8 <commands+0x870>
ffffffffc020434e:	17e00593          	li	a1,382
ffffffffc0204352:	00002517          	auipc	a0,0x2
ffffffffc0204356:	29650513          	addi	a0,a0,662 # ffffffffc02065e8 <default_pmm_manager+0xf78>
ffffffffc020435a:	8f6fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("create init_main failed.\n");
ffffffffc020435e:	00002617          	auipc	a2,0x2
ffffffffc0204362:	34260613          	addi	a2,a2,834 # ffffffffc02066a0 <default_pmm_manager+0x1030>
ffffffffc0204366:	17800593          	li	a1,376
ffffffffc020436a:	00002517          	auipc	a0,0x2
ffffffffc020436e:	27e50513          	addi	a0,a0,638 # ffffffffc02065e8 <default_pmm_manager+0xf78>
ffffffffc0204372:	8defc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0204376 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0204376:	1141                	addi	sp,sp,-16
ffffffffc0204378:	e022                	sd	s0,0(sp)
ffffffffc020437a:	e406                	sd	ra,8(sp)
ffffffffc020437c:	00011417          	auipc	s0,0x11
ffffffffc0204380:	12440413          	addi	s0,s0,292 # ffffffffc02154a0 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0204384:	6018                	ld	a4,0(s0)
ffffffffc0204386:	4f1c                	lw	a5,24(a4)
ffffffffc0204388:	2781                	sext.w	a5,a5
ffffffffc020438a:	dff5                	beqz	a5,ffffffffc0204386 <cpu_idle+0x10>
            schedule();
ffffffffc020438c:	006000ef          	jal	ra,ffffffffc0204392 <schedule>
ffffffffc0204390:	bfd5                	j	ffffffffc0204384 <cpu_idle+0xe>

ffffffffc0204392 <schedule>:
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
    proc->state = PROC_RUNNABLE;
}

void
schedule(void) {
ffffffffc0204392:	1141                	addi	sp,sp,-16
ffffffffc0204394:	e406                	sd	ra,8(sp)
ffffffffc0204396:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204398:	100027f3          	csrr	a5,sstatus
ffffffffc020439c:	8b89                	andi	a5,a5,2
ffffffffc020439e:	4401                	li	s0,0
ffffffffc02043a0:	e3d1                	bnez	a5,ffffffffc0204424 <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02043a2:	00011797          	auipc	a5,0x11
ffffffffc02043a6:	0fe78793          	addi	a5,a5,254 # ffffffffc02154a0 <current>
ffffffffc02043aa:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02043ae:	00011797          	auipc	a5,0x11
ffffffffc02043b2:	0fa78793          	addi	a5,a5,250 # ffffffffc02154a8 <idleproc>
ffffffffc02043b6:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc02043b8:	0008ac23          	sw	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02043bc:	04a88e63          	beq	a7,a0,ffffffffc0204418 <schedule+0x86>
ffffffffc02043c0:	0c888693          	addi	a3,a7,200
ffffffffc02043c4:	00011617          	auipc	a2,0x11
ffffffffc02043c8:	21c60613          	addi	a2,a2,540 # ffffffffc02155e0 <proc_list>
        le = last;
ffffffffc02043cc:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc02043ce:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc02043d0:	4809                	li	a6,2
    return listelm->next;
ffffffffc02043d2:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc02043d4:	00c78863          	beq	a5,a2,ffffffffc02043e4 <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc02043d8:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02043dc:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc02043e0:	01070463          	beq	a4,a6,ffffffffc02043e8 <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc02043e4:	fef697e3          	bne	a3,a5,ffffffffc02043d2 <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02043e8:	c589                	beqz	a1,ffffffffc02043f2 <schedule+0x60>
ffffffffc02043ea:	4198                	lw	a4,0(a1)
ffffffffc02043ec:	4789                	li	a5,2
ffffffffc02043ee:	00f70e63          	beq	a4,a5,ffffffffc020440a <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc02043f2:	451c                	lw	a5,8(a0)
ffffffffc02043f4:	2785                	addiw	a5,a5,1
ffffffffc02043f6:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc02043f8:	00a88463          	beq	a7,a0,ffffffffc0204400 <schedule+0x6e>
            proc_run(next);
ffffffffc02043fc:	cf9ff0ef          	jal	ra,ffffffffc02040f4 <proc_run>
    if (flag) {
ffffffffc0204400:	e419                	bnez	s0,ffffffffc020440e <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0204402:	60a2                	ld	ra,8(sp)
ffffffffc0204404:	6402                	ld	s0,0(sp)
ffffffffc0204406:	0141                	addi	sp,sp,16
ffffffffc0204408:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020440a:	852e                	mv	a0,a1
ffffffffc020440c:	b7dd                	j	ffffffffc02043f2 <schedule+0x60>
}
ffffffffc020440e:	6402                	ld	s0,0(sp)
ffffffffc0204410:	60a2                	ld	ra,8(sp)
ffffffffc0204412:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0204414:	99afc06f          	j	ffffffffc02005ae <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204418:	00011617          	auipc	a2,0x11
ffffffffc020441c:	1c860613          	addi	a2,a2,456 # ffffffffc02155e0 <proc_list>
ffffffffc0204420:	86b2                	mv	a3,a2
ffffffffc0204422:	b76d                	j	ffffffffc02043cc <schedule+0x3a>
        intr_disable();
ffffffffc0204424:	990fc0ef          	jal	ra,ffffffffc02005b4 <intr_disable>
        return 1;
ffffffffc0204428:	4405                	li	s0,1
ffffffffc020442a:	bfa5                	j	ffffffffc02043a2 <schedule+0x10>

ffffffffc020442c <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc020442c:	9e3707b7          	lui	a5,0x9e370
ffffffffc0204430:	2785                	addiw	a5,a5,1
ffffffffc0204432:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0204436:	02000793          	li	a5,32
ffffffffc020443a:	40b785bb          	subw	a1,a5,a1
}
ffffffffc020443e:	00b5553b          	srlw	a0,a0,a1
ffffffffc0204442:	8082                	ret

ffffffffc0204444 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0204444:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204448:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020444a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020444e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0204450:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204454:	f022                	sd	s0,32(sp)
ffffffffc0204456:	ec26                	sd	s1,24(sp)
ffffffffc0204458:	e84a                	sd	s2,16(sp)
ffffffffc020445a:	f406                	sd	ra,40(sp)
ffffffffc020445c:	e44e                	sd	s3,8(sp)
ffffffffc020445e:	84aa                	mv	s1,a0
ffffffffc0204460:	892e                	mv	s2,a1
ffffffffc0204462:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204466:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0204468:	03067e63          	bleu	a6,a2,ffffffffc02044a4 <printnum+0x60>
ffffffffc020446c:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020446e:	00805763          	blez	s0,ffffffffc020447c <printnum+0x38>
ffffffffc0204472:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204474:	85ca                	mv	a1,s2
ffffffffc0204476:	854e                	mv	a0,s3
ffffffffc0204478:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020447a:	fc65                	bnez	s0,ffffffffc0204472 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020447c:	1a02                	slli	s4,s4,0x20
ffffffffc020447e:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204482:	00002797          	auipc	a5,0x2
ffffffffc0204486:	42678793          	addi	a5,a5,1062 # ffffffffc02068a8 <error_string+0x38>
ffffffffc020448a:	9a3e                	add	s4,s4,a5
}
ffffffffc020448c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020448e:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204492:	70a2                	ld	ra,40(sp)
ffffffffc0204494:	69a2                	ld	s3,8(sp)
ffffffffc0204496:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204498:	85ca                	mv	a1,s2
ffffffffc020449a:	8326                	mv	t1,s1
}
ffffffffc020449c:	6942                	ld	s2,16(sp)
ffffffffc020449e:	64e2                	ld	s1,24(sp)
ffffffffc02044a0:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02044a2:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02044a4:	03065633          	divu	a2,a2,a6
ffffffffc02044a8:	8722                	mv	a4,s0
ffffffffc02044aa:	f9bff0ef          	jal	ra,ffffffffc0204444 <printnum>
ffffffffc02044ae:	b7f9                	j	ffffffffc020447c <printnum+0x38>

ffffffffc02044b0 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02044b0:	7119                	addi	sp,sp,-128
ffffffffc02044b2:	f4a6                	sd	s1,104(sp)
ffffffffc02044b4:	f0ca                	sd	s2,96(sp)
ffffffffc02044b6:	e8d2                	sd	s4,80(sp)
ffffffffc02044b8:	e4d6                	sd	s5,72(sp)
ffffffffc02044ba:	e0da                	sd	s6,64(sp)
ffffffffc02044bc:	fc5e                	sd	s7,56(sp)
ffffffffc02044be:	f862                	sd	s8,48(sp)
ffffffffc02044c0:	f06a                	sd	s10,32(sp)
ffffffffc02044c2:	fc86                	sd	ra,120(sp)
ffffffffc02044c4:	f8a2                	sd	s0,112(sp)
ffffffffc02044c6:	ecce                	sd	s3,88(sp)
ffffffffc02044c8:	f466                	sd	s9,40(sp)
ffffffffc02044ca:	ec6e                	sd	s11,24(sp)
ffffffffc02044cc:	892a                	mv	s2,a0
ffffffffc02044ce:	84ae                	mv	s1,a1
ffffffffc02044d0:	8d32                	mv	s10,a2
ffffffffc02044d2:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02044d4:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02044d6:	00002a17          	auipc	s4,0x2
ffffffffc02044da:	242a0a13          	addi	s4,s4,578 # ffffffffc0206718 <default_pmm_manager+0x10a8>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02044de:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02044e2:	00002c17          	auipc	s8,0x2
ffffffffc02044e6:	38ec0c13          	addi	s8,s8,910 # ffffffffc0206870 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02044ea:	000d4503          	lbu	a0,0(s10) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc02044ee:	02500793          	li	a5,37
ffffffffc02044f2:	001d0413          	addi	s0,s10,1
ffffffffc02044f6:	00f50e63          	beq	a0,a5,ffffffffc0204512 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02044fa:	c521                	beqz	a0,ffffffffc0204542 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02044fc:	02500993          	li	s3,37
ffffffffc0204500:	a011                	j	ffffffffc0204504 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0204502:	c121                	beqz	a0,ffffffffc0204542 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0204504:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204506:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204508:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020450a:	fff44503          	lbu	a0,-1(s0)
ffffffffc020450e:	ff351ae3          	bne	a0,s3,ffffffffc0204502 <vprintfmt+0x52>
ffffffffc0204512:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204516:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020451a:	4981                	li	s3,0
ffffffffc020451c:	4801                	li	a6,0
        width = precision = -1;
ffffffffc020451e:	5cfd                	li	s9,-1
ffffffffc0204520:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204522:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0204526:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204528:	fdd6069b          	addiw	a3,a2,-35
ffffffffc020452c:	0ff6f693          	andi	a3,a3,255
ffffffffc0204530:	00140d13          	addi	s10,s0,1
ffffffffc0204534:	20d5e563          	bltu	a1,a3,ffffffffc020473e <vprintfmt+0x28e>
ffffffffc0204538:	068a                	slli	a3,a3,0x2
ffffffffc020453a:	96d2                	add	a3,a3,s4
ffffffffc020453c:	4294                	lw	a3,0(a3)
ffffffffc020453e:	96d2                	add	a3,a3,s4
ffffffffc0204540:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204542:	70e6                	ld	ra,120(sp)
ffffffffc0204544:	7446                	ld	s0,112(sp)
ffffffffc0204546:	74a6                	ld	s1,104(sp)
ffffffffc0204548:	7906                	ld	s2,96(sp)
ffffffffc020454a:	69e6                	ld	s3,88(sp)
ffffffffc020454c:	6a46                	ld	s4,80(sp)
ffffffffc020454e:	6aa6                	ld	s5,72(sp)
ffffffffc0204550:	6b06                	ld	s6,64(sp)
ffffffffc0204552:	7be2                	ld	s7,56(sp)
ffffffffc0204554:	7c42                	ld	s8,48(sp)
ffffffffc0204556:	7ca2                	ld	s9,40(sp)
ffffffffc0204558:	7d02                	ld	s10,32(sp)
ffffffffc020455a:	6de2                	ld	s11,24(sp)
ffffffffc020455c:	6109                	addi	sp,sp,128
ffffffffc020455e:	8082                	ret
    if (lflag >= 2) {
ffffffffc0204560:	4705                	li	a4,1
ffffffffc0204562:	008a8593          	addi	a1,s5,8
ffffffffc0204566:	01074463          	blt	a4,a6,ffffffffc020456e <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc020456a:	26080363          	beqz	a6,ffffffffc02047d0 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc020456e:	000ab603          	ld	a2,0(s5)
ffffffffc0204572:	46c1                	li	a3,16
ffffffffc0204574:	8aae                	mv	s5,a1
ffffffffc0204576:	a06d                	j	ffffffffc0204620 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0204578:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020457c:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020457e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204580:	b765                	j	ffffffffc0204528 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0204582:	000aa503          	lw	a0,0(s5)
ffffffffc0204586:	85a6                	mv	a1,s1
ffffffffc0204588:	0aa1                	addi	s5,s5,8
ffffffffc020458a:	9902                	jalr	s2
            break;
ffffffffc020458c:	bfb9                	j	ffffffffc02044ea <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020458e:	4705                	li	a4,1
ffffffffc0204590:	008a8993          	addi	s3,s5,8
ffffffffc0204594:	01074463          	blt	a4,a6,ffffffffc020459c <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0204598:	22080463          	beqz	a6,ffffffffc02047c0 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc020459c:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02045a0:	24044463          	bltz	s0,ffffffffc02047e8 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02045a4:	8622                	mv	a2,s0
ffffffffc02045a6:	8ace                	mv	s5,s3
ffffffffc02045a8:	46a9                	li	a3,10
ffffffffc02045aa:	a89d                	j	ffffffffc0204620 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02045ac:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02045b0:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02045b2:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02045b4:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02045b8:	8fb5                	xor	a5,a5,a3
ffffffffc02045ba:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02045be:	1ad74363          	blt	a4,a3,ffffffffc0204764 <vprintfmt+0x2b4>
ffffffffc02045c2:	00369793          	slli	a5,a3,0x3
ffffffffc02045c6:	97e2                	add	a5,a5,s8
ffffffffc02045c8:	639c                	ld	a5,0(a5)
ffffffffc02045ca:	18078d63          	beqz	a5,ffffffffc0204764 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02045ce:	86be                	mv	a3,a5
ffffffffc02045d0:	00000617          	auipc	a2,0x0
ffffffffc02045d4:	39060613          	addi	a2,a2,912 # ffffffffc0204960 <etext+0x2c>
ffffffffc02045d8:	85a6                	mv	a1,s1
ffffffffc02045da:	854a                	mv	a0,s2
ffffffffc02045dc:	240000ef          	jal	ra,ffffffffc020481c <printfmt>
ffffffffc02045e0:	b729                	j	ffffffffc02044ea <vprintfmt+0x3a>
            lflag ++;
ffffffffc02045e2:	00144603          	lbu	a2,1(s0)
ffffffffc02045e6:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02045e8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02045ea:	bf3d                	j	ffffffffc0204528 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02045ec:	4705                	li	a4,1
ffffffffc02045ee:	008a8593          	addi	a1,s5,8
ffffffffc02045f2:	01074463          	blt	a4,a6,ffffffffc02045fa <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02045f6:	1e080263          	beqz	a6,ffffffffc02047da <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc02045fa:	000ab603          	ld	a2,0(s5)
ffffffffc02045fe:	46a1                	li	a3,8
ffffffffc0204600:	8aae                	mv	s5,a1
ffffffffc0204602:	a839                	j	ffffffffc0204620 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0204604:	03000513          	li	a0,48
ffffffffc0204608:	85a6                	mv	a1,s1
ffffffffc020460a:	e03e                	sd	a5,0(sp)
ffffffffc020460c:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020460e:	85a6                	mv	a1,s1
ffffffffc0204610:	07800513          	li	a0,120
ffffffffc0204614:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204616:	0aa1                	addi	s5,s5,8
ffffffffc0204618:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc020461c:	6782                	ld	a5,0(sp)
ffffffffc020461e:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204620:	876e                	mv	a4,s11
ffffffffc0204622:	85a6                	mv	a1,s1
ffffffffc0204624:	854a                	mv	a0,s2
ffffffffc0204626:	e1fff0ef          	jal	ra,ffffffffc0204444 <printnum>
            break;
ffffffffc020462a:	b5c1                	j	ffffffffc02044ea <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020462c:	000ab603          	ld	a2,0(s5)
ffffffffc0204630:	0aa1                	addi	s5,s5,8
ffffffffc0204632:	1c060663          	beqz	a2,ffffffffc02047fe <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0204636:	00160413          	addi	s0,a2,1
ffffffffc020463a:	17b05c63          	blez	s11,ffffffffc02047b2 <vprintfmt+0x302>
ffffffffc020463e:	02d00593          	li	a1,45
ffffffffc0204642:	14b79263          	bne	a5,a1,ffffffffc0204786 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204646:	00064783          	lbu	a5,0(a2)
ffffffffc020464a:	0007851b          	sext.w	a0,a5
ffffffffc020464e:	c905                	beqz	a0,ffffffffc020467e <vprintfmt+0x1ce>
ffffffffc0204650:	000cc563          	bltz	s9,ffffffffc020465a <vprintfmt+0x1aa>
ffffffffc0204654:	3cfd                	addiw	s9,s9,-1
ffffffffc0204656:	036c8263          	beq	s9,s6,ffffffffc020467a <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc020465a:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020465c:	18098463          	beqz	s3,ffffffffc02047e4 <vprintfmt+0x334>
ffffffffc0204660:	3781                	addiw	a5,a5,-32
ffffffffc0204662:	18fbf163          	bleu	a5,s7,ffffffffc02047e4 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0204666:	03f00513          	li	a0,63
ffffffffc020466a:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020466c:	0405                	addi	s0,s0,1
ffffffffc020466e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204672:	3dfd                	addiw	s11,s11,-1
ffffffffc0204674:	0007851b          	sext.w	a0,a5
ffffffffc0204678:	fd61                	bnez	a0,ffffffffc0204650 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc020467a:	e7b058e3          	blez	s11,ffffffffc02044ea <vprintfmt+0x3a>
ffffffffc020467e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204680:	85a6                	mv	a1,s1
ffffffffc0204682:	02000513          	li	a0,32
ffffffffc0204686:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204688:	e60d81e3          	beqz	s11,ffffffffc02044ea <vprintfmt+0x3a>
ffffffffc020468c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020468e:	85a6                	mv	a1,s1
ffffffffc0204690:	02000513          	li	a0,32
ffffffffc0204694:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204696:	fe0d94e3          	bnez	s11,ffffffffc020467e <vprintfmt+0x1ce>
ffffffffc020469a:	bd81                	j	ffffffffc02044ea <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020469c:	4705                	li	a4,1
ffffffffc020469e:	008a8593          	addi	a1,s5,8
ffffffffc02046a2:	01074463          	blt	a4,a6,ffffffffc02046aa <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02046a6:	12080063          	beqz	a6,ffffffffc02047c6 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02046aa:	000ab603          	ld	a2,0(s5)
ffffffffc02046ae:	46a9                	li	a3,10
ffffffffc02046b0:	8aae                	mv	s5,a1
ffffffffc02046b2:	b7bd                	j	ffffffffc0204620 <vprintfmt+0x170>
ffffffffc02046b4:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02046b8:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02046bc:	846a                	mv	s0,s10
ffffffffc02046be:	b5ad                	j	ffffffffc0204528 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02046c0:	85a6                	mv	a1,s1
ffffffffc02046c2:	02500513          	li	a0,37
ffffffffc02046c6:	9902                	jalr	s2
            break;
ffffffffc02046c8:	b50d                	j	ffffffffc02044ea <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02046ca:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02046ce:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02046d2:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02046d4:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02046d6:	e40dd9e3          	bgez	s11,ffffffffc0204528 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02046da:	8de6                	mv	s11,s9
ffffffffc02046dc:	5cfd                	li	s9,-1
ffffffffc02046de:	b5a9                	j	ffffffffc0204528 <vprintfmt+0x78>
            goto reswitch;
ffffffffc02046e0:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02046e4:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02046e8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02046ea:	bd3d                	j	ffffffffc0204528 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02046ec:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02046f0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02046f4:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02046f6:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02046fa:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02046fe:	fcd56ce3          	bltu	a0,a3,ffffffffc02046d6 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0204702:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204704:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0204708:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020470c:	0196873b          	addw	a4,a3,s9
ffffffffc0204710:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204714:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0204718:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc020471c:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0204720:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204724:	fcd57fe3          	bleu	a3,a0,ffffffffc0204702 <vprintfmt+0x252>
ffffffffc0204728:	b77d                	j	ffffffffc02046d6 <vprintfmt+0x226>
            if (width < 0)
ffffffffc020472a:	fffdc693          	not	a3,s11
ffffffffc020472e:	96fd                	srai	a3,a3,0x3f
ffffffffc0204730:	00ddfdb3          	and	s11,s11,a3
ffffffffc0204734:	00144603          	lbu	a2,1(s0)
ffffffffc0204738:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020473a:	846a                	mv	s0,s10
ffffffffc020473c:	b3f5                	j	ffffffffc0204528 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc020473e:	85a6                	mv	a1,s1
ffffffffc0204740:	02500513          	li	a0,37
ffffffffc0204744:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204746:	fff44703          	lbu	a4,-1(s0)
ffffffffc020474a:	02500793          	li	a5,37
ffffffffc020474e:	8d22                	mv	s10,s0
ffffffffc0204750:	d8f70de3          	beq	a4,a5,ffffffffc02044ea <vprintfmt+0x3a>
ffffffffc0204754:	02500713          	li	a4,37
ffffffffc0204758:	1d7d                	addi	s10,s10,-1
ffffffffc020475a:	fffd4783          	lbu	a5,-1(s10)
ffffffffc020475e:	fee79de3          	bne	a5,a4,ffffffffc0204758 <vprintfmt+0x2a8>
ffffffffc0204762:	b361                	j	ffffffffc02044ea <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204764:	00002617          	auipc	a2,0x2
ffffffffc0204768:	1e460613          	addi	a2,a2,484 # ffffffffc0206948 <error_string+0xd8>
ffffffffc020476c:	85a6                	mv	a1,s1
ffffffffc020476e:	854a                	mv	a0,s2
ffffffffc0204770:	0ac000ef          	jal	ra,ffffffffc020481c <printfmt>
ffffffffc0204774:	bb9d                	j	ffffffffc02044ea <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204776:	00002617          	auipc	a2,0x2
ffffffffc020477a:	1ca60613          	addi	a2,a2,458 # ffffffffc0206940 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc020477e:	00002417          	auipc	s0,0x2
ffffffffc0204782:	1c340413          	addi	s0,s0,451 # ffffffffc0206941 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204786:	8532                	mv	a0,a2
ffffffffc0204788:	85e6                	mv	a1,s9
ffffffffc020478a:	e032                	sd	a2,0(sp)
ffffffffc020478c:	e43e                	sd	a5,8(sp)
ffffffffc020478e:	0cc000ef          	jal	ra,ffffffffc020485a <strnlen>
ffffffffc0204792:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204796:	6602                	ld	a2,0(sp)
ffffffffc0204798:	01b05d63          	blez	s11,ffffffffc02047b2 <vprintfmt+0x302>
ffffffffc020479c:	67a2                	ld	a5,8(sp)
ffffffffc020479e:	2781                	sext.w	a5,a5
ffffffffc02047a0:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02047a2:	6522                	ld	a0,8(sp)
ffffffffc02047a4:	85a6                	mv	a1,s1
ffffffffc02047a6:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02047a8:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02047aa:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02047ac:	6602                	ld	a2,0(sp)
ffffffffc02047ae:	fe0d9ae3          	bnez	s11,ffffffffc02047a2 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02047b2:	00064783          	lbu	a5,0(a2)
ffffffffc02047b6:	0007851b          	sext.w	a0,a5
ffffffffc02047ba:	e8051be3          	bnez	a0,ffffffffc0204650 <vprintfmt+0x1a0>
ffffffffc02047be:	b335                	j	ffffffffc02044ea <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02047c0:	000aa403          	lw	s0,0(s5)
ffffffffc02047c4:	bbf1                	j	ffffffffc02045a0 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02047c6:	000ae603          	lwu	a2,0(s5)
ffffffffc02047ca:	46a9                	li	a3,10
ffffffffc02047cc:	8aae                	mv	s5,a1
ffffffffc02047ce:	bd89                	j	ffffffffc0204620 <vprintfmt+0x170>
ffffffffc02047d0:	000ae603          	lwu	a2,0(s5)
ffffffffc02047d4:	46c1                	li	a3,16
ffffffffc02047d6:	8aae                	mv	s5,a1
ffffffffc02047d8:	b5a1                	j	ffffffffc0204620 <vprintfmt+0x170>
ffffffffc02047da:	000ae603          	lwu	a2,0(s5)
ffffffffc02047de:	46a1                	li	a3,8
ffffffffc02047e0:	8aae                	mv	s5,a1
ffffffffc02047e2:	bd3d                	j	ffffffffc0204620 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02047e4:	9902                	jalr	s2
ffffffffc02047e6:	b559                	j	ffffffffc020466c <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02047e8:	85a6                	mv	a1,s1
ffffffffc02047ea:	02d00513          	li	a0,45
ffffffffc02047ee:	e03e                	sd	a5,0(sp)
ffffffffc02047f0:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02047f2:	8ace                	mv	s5,s3
ffffffffc02047f4:	40800633          	neg	a2,s0
ffffffffc02047f8:	46a9                	li	a3,10
ffffffffc02047fa:	6782                	ld	a5,0(sp)
ffffffffc02047fc:	b515                	j	ffffffffc0204620 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02047fe:	01b05663          	blez	s11,ffffffffc020480a <vprintfmt+0x35a>
ffffffffc0204802:	02d00693          	li	a3,45
ffffffffc0204806:	f6d798e3          	bne	a5,a3,ffffffffc0204776 <vprintfmt+0x2c6>
ffffffffc020480a:	00002417          	auipc	s0,0x2
ffffffffc020480e:	13740413          	addi	s0,s0,311 # ffffffffc0206941 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204812:	02800513          	li	a0,40
ffffffffc0204816:	02800793          	li	a5,40
ffffffffc020481a:	bd1d                	j	ffffffffc0204650 <vprintfmt+0x1a0>

ffffffffc020481c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020481c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020481e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204822:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204824:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204826:	ec06                	sd	ra,24(sp)
ffffffffc0204828:	f83a                	sd	a4,48(sp)
ffffffffc020482a:	fc3e                	sd	a5,56(sp)
ffffffffc020482c:	e0c2                	sd	a6,64(sp)
ffffffffc020482e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204830:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204832:	c7fff0ef          	jal	ra,ffffffffc02044b0 <vprintfmt>
}
ffffffffc0204836:	60e2                	ld	ra,24(sp)
ffffffffc0204838:	6161                	addi	sp,sp,80
ffffffffc020483a:	8082                	ret

ffffffffc020483c <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020483c:	00054783          	lbu	a5,0(a0)
ffffffffc0204840:	cb91                	beqz	a5,ffffffffc0204854 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0204842:	4781                	li	a5,0
        cnt ++;
ffffffffc0204844:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0204846:	00f50733          	add	a4,a0,a5
ffffffffc020484a:	00074703          	lbu	a4,0(a4)
ffffffffc020484e:	fb7d                	bnez	a4,ffffffffc0204844 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0204850:	853e                	mv	a0,a5
ffffffffc0204852:	8082                	ret
    size_t cnt = 0;
ffffffffc0204854:	4781                	li	a5,0
}
ffffffffc0204856:	853e                	mv	a0,a5
ffffffffc0204858:	8082                	ret

ffffffffc020485a <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc020485a:	c185                	beqz	a1,ffffffffc020487a <strnlen+0x20>
ffffffffc020485c:	00054783          	lbu	a5,0(a0)
ffffffffc0204860:	cf89                	beqz	a5,ffffffffc020487a <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0204862:	4781                	li	a5,0
ffffffffc0204864:	a021                	j	ffffffffc020486c <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204866:	00074703          	lbu	a4,0(a4)
ffffffffc020486a:	c711                	beqz	a4,ffffffffc0204876 <strnlen+0x1c>
        cnt ++;
ffffffffc020486c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020486e:	00f50733          	add	a4,a0,a5
ffffffffc0204872:	fef59ae3          	bne	a1,a5,ffffffffc0204866 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0204876:	853e                	mv	a0,a5
ffffffffc0204878:	8082                	ret
    size_t cnt = 0;
ffffffffc020487a:	4781                	li	a5,0
}
ffffffffc020487c:	853e                	mv	a0,a5
ffffffffc020487e:	8082                	ret

ffffffffc0204880 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204880:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204882:	0585                	addi	a1,a1,1
ffffffffc0204884:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204888:	0785                	addi	a5,a5,1
ffffffffc020488a:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020488e:	fb75                	bnez	a4,ffffffffc0204882 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204890:	8082                	ret

ffffffffc0204892 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204892:	00054783          	lbu	a5,0(a0)
ffffffffc0204896:	0005c703          	lbu	a4,0(a1)
ffffffffc020489a:	cb91                	beqz	a5,ffffffffc02048ae <strcmp+0x1c>
ffffffffc020489c:	00e79c63          	bne	a5,a4,ffffffffc02048b4 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02048a0:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02048a2:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02048a6:	0585                	addi	a1,a1,1
ffffffffc02048a8:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02048ac:	fbe5                	bnez	a5,ffffffffc020489c <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02048ae:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02048b0:	9d19                	subw	a0,a0,a4
ffffffffc02048b2:	8082                	ret
ffffffffc02048b4:	0007851b          	sext.w	a0,a5
ffffffffc02048b8:	9d19                	subw	a0,a0,a4
ffffffffc02048ba:	8082                	ret

ffffffffc02048bc <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02048bc:	00054783          	lbu	a5,0(a0)
ffffffffc02048c0:	cb91                	beqz	a5,ffffffffc02048d4 <strchr+0x18>
        if (*s == c) {
ffffffffc02048c2:	00b79563          	bne	a5,a1,ffffffffc02048cc <strchr+0x10>
ffffffffc02048c6:	a809                	j	ffffffffc02048d8 <strchr+0x1c>
ffffffffc02048c8:	00b78763          	beq	a5,a1,ffffffffc02048d6 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02048cc:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02048ce:	00054783          	lbu	a5,0(a0)
ffffffffc02048d2:	fbfd                	bnez	a5,ffffffffc02048c8 <strchr+0xc>
    }
    return NULL;
ffffffffc02048d4:	4501                	li	a0,0
}
ffffffffc02048d6:	8082                	ret
ffffffffc02048d8:	8082                	ret

ffffffffc02048da <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02048da:	ca01                	beqz	a2,ffffffffc02048ea <memset+0x10>
ffffffffc02048dc:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02048de:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02048e0:	0785                	addi	a5,a5,1
ffffffffc02048e2:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02048e6:	fec79de3          	bne	a5,a2,ffffffffc02048e0 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02048ea:	8082                	ret

ffffffffc02048ec <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02048ec:	ca19                	beqz	a2,ffffffffc0204902 <memcpy+0x16>
ffffffffc02048ee:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02048f0:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02048f2:	0585                	addi	a1,a1,1
ffffffffc02048f4:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02048f8:	0785                	addi	a5,a5,1
ffffffffc02048fa:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02048fe:	fec59ae3          	bne	a1,a2,ffffffffc02048f2 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204902:	8082                	ret

ffffffffc0204904 <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0204904:	c21d                	beqz	a2,ffffffffc020492a <memcmp+0x26>
        if (*s1 != *s2) {
ffffffffc0204906:	00054783          	lbu	a5,0(a0)
ffffffffc020490a:	0005c703          	lbu	a4,0(a1)
ffffffffc020490e:	962a                	add	a2,a2,a0
ffffffffc0204910:	00f70963          	beq	a4,a5,ffffffffc0204922 <memcmp+0x1e>
ffffffffc0204914:	a829                	j	ffffffffc020492e <memcmp+0x2a>
ffffffffc0204916:	00054783          	lbu	a5,0(a0)
ffffffffc020491a:	0005c703          	lbu	a4,0(a1)
ffffffffc020491e:	00e79863          	bne	a5,a4,ffffffffc020492e <memcmp+0x2a>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0204922:	0505                	addi	a0,a0,1
ffffffffc0204924:	0585                	addi	a1,a1,1
    while (n -- > 0) {
ffffffffc0204926:	fea618e3          	bne	a2,a0,ffffffffc0204916 <memcmp+0x12>
    }
    return 0;
ffffffffc020492a:	4501                	li	a0,0
}
ffffffffc020492c:	8082                	ret
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020492e:	40e7853b          	subw	a0,a5,a4
ffffffffc0204932:	8082                	ret
