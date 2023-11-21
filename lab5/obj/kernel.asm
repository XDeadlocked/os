
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
ffffffffc020004e:	5c6060ef          	jal	ra,ffffffffc0206614 <memset>
    cons_init();                // init the console
ffffffffc0200052:	536000ef          	jal	ra,ffffffffc0200588 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00006597          	auipc	a1,0x6
ffffffffc020005a:	5ea58593          	addi	a1,a1,1514 # ffffffffc0206640 <etext+0x2>
ffffffffc020005e:	00006517          	auipc	a0,0x6
ffffffffc0200062:	60250513          	addi	a0,a0,1538 # ffffffffc0206660 <etext+0x22>
ffffffffc0200066:	128000ef          	jal	ra,ffffffffc020018e <cprintf>

    print_kerninfo();
ffffffffc020006a:	1ac000ef          	jal	ra,ffffffffc0200216 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	5d2020ef          	jal	ra,ffffffffc0202640 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5ee000ef          	jal	ra,ffffffffc0200660 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5ec000ef          	jal	ra,ffffffffc0200662 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	3f4040ef          	jal	ra,ffffffffc020446e <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	527050ef          	jal	ra,ffffffffc0205da4 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	57a000ef          	jal	ra,ffffffffc02005fc <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	312030ef          	jal	ra,ffffffffc0203398 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	4a8000ef          	jal	ra,ffffffffc0200532 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	5c6000ef          	jal	ra,ffffffffc0200654 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc0200092:	65f050ef          	jal	ra,ffffffffc0205ef0 <cpu_idle>

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
ffffffffc02000b2:	5ba50513          	addi	a0,a0,1466 # ffffffffc0206668 <etext+0x2a>
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
ffffffffc0200182:	068060ef          	jal	ra,ffffffffc02061ea <vprintfmt>
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
ffffffffc02001b6:	034060ef          	jal	ra,ffffffffc02061ea <vprintfmt>
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
ffffffffc020021c:	48850513          	addi	a0,a0,1160 # ffffffffc02066a0 <etext+0x62>
void print_kerninfo(void) {
ffffffffc0200220:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200222:	f6dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200226:	00000597          	auipc	a1,0x0
ffffffffc020022a:	e1058593          	addi	a1,a1,-496 # ffffffffc0200036 <kern_init>
ffffffffc020022e:	00006517          	auipc	a0,0x6
ffffffffc0200232:	49250513          	addi	a0,a0,1170 # ffffffffc02066c0 <etext+0x82>
ffffffffc0200236:	f59ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020023a:	00006597          	auipc	a1,0x6
ffffffffc020023e:	40458593          	addi	a1,a1,1028 # ffffffffc020663e <etext>
ffffffffc0200242:	00006517          	auipc	a0,0x6
ffffffffc0200246:	49e50513          	addi	a0,a0,1182 # ffffffffc02066e0 <etext+0xa2>
ffffffffc020024a:	f45ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020024e:	000a1597          	auipc	a1,0xa1
ffffffffc0200252:	eaa58593          	addi	a1,a1,-342 # ffffffffc02a10f8 <edata>
ffffffffc0200256:	00006517          	auipc	a0,0x6
ffffffffc020025a:	4aa50513          	addi	a0,a0,1194 # ffffffffc0206700 <etext+0xc2>
ffffffffc020025e:	f31ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200262:	000ac597          	auipc	a1,0xac
ffffffffc0200266:	41e58593          	addi	a1,a1,1054 # ffffffffc02ac680 <end>
ffffffffc020026a:	00006517          	auipc	a0,0x6
ffffffffc020026e:	4b650513          	addi	a0,a0,1206 # ffffffffc0206720 <etext+0xe2>
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
ffffffffc020029c:	4a850513          	addi	a0,a0,1192 # ffffffffc0206740 <etext+0x102>
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
ffffffffc02002ac:	3c860613          	addi	a2,a2,968 # ffffffffc0206670 <etext+0x32>
ffffffffc02002b0:	04d00593          	li	a1,77
ffffffffc02002b4:	00006517          	auipc	a0,0x6
ffffffffc02002b8:	3d450513          	addi	a0,a0,980 # ffffffffc0206688 <etext+0x4a>
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
ffffffffc02002c8:	58c60613          	addi	a2,a2,1420 # ffffffffc0206850 <commands+0xe0>
ffffffffc02002cc:	00006597          	auipc	a1,0x6
ffffffffc02002d0:	5a458593          	addi	a1,a1,1444 # ffffffffc0206870 <commands+0x100>
ffffffffc02002d4:	00006517          	auipc	a0,0x6
ffffffffc02002d8:	5a450513          	addi	a0,a0,1444 # ffffffffc0206878 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002dc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002de:	eb1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002e2:	00006617          	auipc	a2,0x6
ffffffffc02002e6:	5a660613          	addi	a2,a2,1446 # ffffffffc0206888 <commands+0x118>
ffffffffc02002ea:	00006597          	auipc	a1,0x6
ffffffffc02002ee:	5c658593          	addi	a1,a1,1478 # ffffffffc02068b0 <commands+0x140>
ffffffffc02002f2:	00006517          	auipc	a0,0x6
ffffffffc02002f6:	58650513          	addi	a0,a0,1414 # ffffffffc0206878 <commands+0x108>
ffffffffc02002fa:	e95ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002fe:	00006617          	auipc	a2,0x6
ffffffffc0200302:	5c260613          	addi	a2,a2,1474 # ffffffffc02068c0 <commands+0x150>
ffffffffc0200306:	00006597          	auipc	a1,0x6
ffffffffc020030a:	5da58593          	addi	a1,a1,1498 # ffffffffc02068e0 <commands+0x170>
ffffffffc020030e:	00006517          	auipc	a0,0x6
ffffffffc0200312:	56a50513          	addi	a0,a0,1386 # ffffffffc0206878 <commands+0x108>
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
ffffffffc020034c:	47050513          	addi	a0,a0,1136 # ffffffffc02067b8 <commands+0x48>
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
ffffffffc020036e:	47650513          	addi	a0,a0,1142 # ffffffffc02067e0 <commands+0x70>
ffffffffc0200372:	e1dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    if (tf != NULL) {
ffffffffc0200376:	000c0563          	beqz	s8,ffffffffc0200380 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020037a:	8562                	mv	a0,s8
ffffffffc020037c:	4ce000ef          	jal	ra,ffffffffc020084a <print_trapframe>
ffffffffc0200380:	00006c97          	auipc	s9,0x6
ffffffffc0200384:	3f0c8c93          	addi	s9,s9,1008 # ffffffffc0206770 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200388:	00006997          	auipc	s3,0x6
ffffffffc020038c:	48098993          	addi	s3,s3,1152 # ffffffffc0206808 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200390:	00006917          	auipc	s2,0x6
ffffffffc0200394:	48090913          	addi	s2,s2,1152 # ffffffffc0206810 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200398:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020039a:	00006b17          	auipc	s6,0x6
ffffffffc020039e:	47eb0b13          	addi	s6,s6,1150 # ffffffffc0206818 <commands+0xa8>
    if (argc == 0) {
ffffffffc02003a2:	00006a97          	auipc	s5,0x6
ffffffffc02003a6:	4cea8a93          	addi	s5,s5,1230 # ffffffffc0206870 <commands+0x100>
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
ffffffffc02003c0:	236060ef          	jal	ra,ffffffffc02065f6 <strchr>
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
ffffffffc02003da:	39ad0d13          	addi	s10,s10,922 # ffffffffc0206770 <commands>
    if (argc == 0) {
ffffffffc02003de:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003e0:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003e2:	0d61                	addi	s10,s10,24
ffffffffc02003e4:	1e8060ef          	jal	ra,ffffffffc02065cc <strcmp>
ffffffffc02003e8:	c919                	beqz	a0,ffffffffc02003fe <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ea:	2405                	addiw	s0,s0,1
ffffffffc02003ec:	09740463          	beq	s0,s7,ffffffffc0200474 <kmonitor+0x132>
ffffffffc02003f0:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003f4:	6582                	ld	a1,0(sp)
ffffffffc02003f6:	0d61                	addi	s10,s10,24
ffffffffc02003f8:	1d4060ef          	jal	ra,ffffffffc02065cc <strcmp>
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
ffffffffc020045e:	198060ef          	jal	ra,ffffffffc02065f6 <strchr>
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
ffffffffc020047a:	3c250513          	addi	a0,a0,962 # ffffffffc0206838 <commands+0xc8>
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
ffffffffc02004ba:	43a50513          	addi	a0,a0,1082 # ffffffffc02068f0 <commands+0x180>
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
ffffffffc02004d0:	3f450513          	addi	a0,a0,1012 # ffffffffc02078c0 <default_pmm_manager+0x530>
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
ffffffffc0200502:	41250513          	addi	a0,a0,1042 # ffffffffc0206910 <commands+0x1a0>
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
ffffffffc0200522:	3a250513          	addi	a0,a0,930 # ffffffffc02078c0 <default_pmm_manager+0x530>
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
ffffffffc020055c:	3d850513          	addi	a0,a0,984 # ffffffffc0206930 <commands+0x1c0>
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
ffffffffc0200622:	004060ef          	jal	ra,ffffffffc0206626 <memcpy>
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
ffffffffc0200648:	7df050ef          	jal	ra,ffffffffc0206626 <memcpy>
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
ffffffffc020066a:	68678793          	addi	a5,a5,1670 # ffffffffc0200cec <__alltraps>
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
ffffffffc0200688:	60c50513          	addi	a0,a0,1548 # ffffffffc0206c90 <commands+0x520>
void print_regs(struct pushregs* gpr) {
ffffffffc020068c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020068e:	b01ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200692:	640c                	ld	a1,8(s0)
ffffffffc0200694:	00006517          	auipc	a0,0x6
ffffffffc0200698:	61450513          	addi	a0,a0,1556 # ffffffffc0206ca8 <commands+0x538>
ffffffffc020069c:	af3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02006a0:	680c                	ld	a1,16(s0)
ffffffffc02006a2:	00006517          	auipc	a0,0x6
ffffffffc02006a6:	61e50513          	addi	a0,a0,1566 # ffffffffc0206cc0 <commands+0x550>
ffffffffc02006aa:	ae5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02006ae:	6c0c                	ld	a1,24(s0)
ffffffffc02006b0:	00006517          	auipc	a0,0x6
ffffffffc02006b4:	62850513          	addi	a0,a0,1576 # ffffffffc0206cd8 <commands+0x568>
ffffffffc02006b8:	ad7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006bc:	700c                	ld	a1,32(s0)
ffffffffc02006be:	00006517          	auipc	a0,0x6
ffffffffc02006c2:	63250513          	addi	a0,a0,1586 # ffffffffc0206cf0 <commands+0x580>
ffffffffc02006c6:	ac9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006ca:	740c                	ld	a1,40(s0)
ffffffffc02006cc:	00006517          	auipc	a0,0x6
ffffffffc02006d0:	63c50513          	addi	a0,a0,1596 # ffffffffc0206d08 <commands+0x598>
ffffffffc02006d4:	abbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006d8:	780c                	ld	a1,48(s0)
ffffffffc02006da:	00006517          	auipc	a0,0x6
ffffffffc02006de:	64650513          	addi	a0,a0,1606 # ffffffffc0206d20 <commands+0x5b0>
ffffffffc02006e2:	aadff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006e6:	7c0c                	ld	a1,56(s0)
ffffffffc02006e8:	00006517          	auipc	a0,0x6
ffffffffc02006ec:	65050513          	addi	a0,a0,1616 # ffffffffc0206d38 <commands+0x5c8>
ffffffffc02006f0:	a9fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006f4:	602c                	ld	a1,64(s0)
ffffffffc02006f6:	00006517          	auipc	a0,0x6
ffffffffc02006fa:	65a50513          	addi	a0,a0,1626 # ffffffffc0206d50 <commands+0x5e0>
ffffffffc02006fe:	a91ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200702:	642c                	ld	a1,72(s0)
ffffffffc0200704:	00006517          	auipc	a0,0x6
ffffffffc0200708:	66450513          	addi	a0,a0,1636 # ffffffffc0206d68 <commands+0x5f8>
ffffffffc020070c:	a83ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200710:	682c                	ld	a1,80(s0)
ffffffffc0200712:	00006517          	auipc	a0,0x6
ffffffffc0200716:	66e50513          	addi	a0,a0,1646 # ffffffffc0206d80 <commands+0x610>
ffffffffc020071a:	a75ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020071e:	6c2c                	ld	a1,88(s0)
ffffffffc0200720:	00006517          	auipc	a0,0x6
ffffffffc0200724:	67850513          	addi	a0,a0,1656 # ffffffffc0206d98 <commands+0x628>
ffffffffc0200728:	a67ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020072c:	702c                	ld	a1,96(s0)
ffffffffc020072e:	00006517          	auipc	a0,0x6
ffffffffc0200732:	68250513          	addi	a0,a0,1666 # ffffffffc0206db0 <commands+0x640>
ffffffffc0200736:	a59ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020073a:	742c                	ld	a1,104(s0)
ffffffffc020073c:	00006517          	auipc	a0,0x6
ffffffffc0200740:	68c50513          	addi	a0,a0,1676 # ffffffffc0206dc8 <commands+0x658>
ffffffffc0200744:	a4bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200748:	782c                	ld	a1,112(s0)
ffffffffc020074a:	00006517          	auipc	a0,0x6
ffffffffc020074e:	69650513          	addi	a0,a0,1686 # ffffffffc0206de0 <commands+0x670>
ffffffffc0200752:	a3dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200756:	7c2c                	ld	a1,120(s0)
ffffffffc0200758:	00006517          	auipc	a0,0x6
ffffffffc020075c:	6a050513          	addi	a0,a0,1696 # ffffffffc0206df8 <commands+0x688>
ffffffffc0200760:	a2fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200764:	604c                	ld	a1,128(s0)
ffffffffc0200766:	00006517          	auipc	a0,0x6
ffffffffc020076a:	6aa50513          	addi	a0,a0,1706 # ffffffffc0206e10 <commands+0x6a0>
ffffffffc020076e:	a21ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200772:	644c                	ld	a1,136(s0)
ffffffffc0200774:	00006517          	auipc	a0,0x6
ffffffffc0200778:	6b450513          	addi	a0,a0,1716 # ffffffffc0206e28 <commands+0x6b8>
ffffffffc020077c:	a13ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200780:	684c                	ld	a1,144(s0)
ffffffffc0200782:	00006517          	auipc	a0,0x6
ffffffffc0200786:	6be50513          	addi	a0,a0,1726 # ffffffffc0206e40 <commands+0x6d0>
ffffffffc020078a:	a05ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020078e:	6c4c                	ld	a1,152(s0)
ffffffffc0200790:	00006517          	auipc	a0,0x6
ffffffffc0200794:	6c850513          	addi	a0,a0,1736 # ffffffffc0206e58 <commands+0x6e8>
ffffffffc0200798:	9f7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020079c:	704c                	ld	a1,160(s0)
ffffffffc020079e:	00006517          	auipc	a0,0x6
ffffffffc02007a2:	6d250513          	addi	a0,a0,1746 # ffffffffc0206e70 <commands+0x700>
ffffffffc02007a6:	9e9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02007aa:	744c                	ld	a1,168(s0)
ffffffffc02007ac:	00006517          	auipc	a0,0x6
ffffffffc02007b0:	6dc50513          	addi	a0,a0,1756 # ffffffffc0206e88 <commands+0x718>
ffffffffc02007b4:	9dbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007b8:	784c                	ld	a1,176(s0)
ffffffffc02007ba:	00006517          	auipc	a0,0x6
ffffffffc02007be:	6e650513          	addi	a0,a0,1766 # ffffffffc0206ea0 <commands+0x730>
ffffffffc02007c2:	9cdff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007c6:	7c4c                	ld	a1,184(s0)
ffffffffc02007c8:	00006517          	auipc	a0,0x6
ffffffffc02007cc:	6f050513          	addi	a0,a0,1776 # ffffffffc0206eb8 <commands+0x748>
ffffffffc02007d0:	9bfff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007d4:	606c                	ld	a1,192(s0)
ffffffffc02007d6:	00006517          	auipc	a0,0x6
ffffffffc02007da:	6fa50513          	addi	a0,a0,1786 # ffffffffc0206ed0 <commands+0x760>
ffffffffc02007de:	9b1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007e2:	646c                	ld	a1,200(s0)
ffffffffc02007e4:	00006517          	auipc	a0,0x6
ffffffffc02007e8:	70450513          	addi	a0,a0,1796 # ffffffffc0206ee8 <commands+0x778>
ffffffffc02007ec:	9a3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007f0:	686c                	ld	a1,208(s0)
ffffffffc02007f2:	00006517          	auipc	a0,0x6
ffffffffc02007f6:	70e50513          	addi	a0,a0,1806 # ffffffffc0206f00 <commands+0x790>
ffffffffc02007fa:	995ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200800:	00006517          	auipc	a0,0x6
ffffffffc0200804:	71850513          	addi	a0,a0,1816 # ffffffffc0206f18 <commands+0x7a8>
ffffffffc0200808:	987ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020080c:	706c                	ld	a1,224(s0)
ffffffffc020080e:	00006517          	auipc	a0,0x6
ffffffffc0200812:	72250513          	addi	a0,a0,1826 # ffffffffc0206f30 <commands+0x7c0>
ffffffffc0200816:	979ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020081a:	746c                	ld	a1,232(s0)
ffffffffc020081c:	00006517          	auipc	a0,0x6
ffffffffc0200820:	72c50513          	addi	a0,a0,1836 # ffffffffc0206f48 <commands+0x7d8>
ffffffffc0200824:	96bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200828:	786c                	ld	a1,240(s0)
ffffffffc020082a:	00006517          	auipc	a0,0x6
ffffffffc020082e:	73650513          	addi	a0,a0,1846 # ffffffffc0206f60 <commands+0x7f0>
ffffffffc0200832:	95dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200836:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200838:	6402                	ld	s0,0(sp)
ffffffffc020083a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	73c50513          	addi	a0,a0,1852 # ffffffffc0206f78 <commands+0x808>
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
ffffffffc0200852:	00006517          	auipc	a0,0x6
ffffffffc0200856:	73e50513          	addi	a0,a0,1854 # ffffffffc0206f90 <commands+0x820>
print_trapframe(struct trapframe *tf) {
ffffffffc020085a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020085c:	933ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200860:	8522                	mv	a0,s0
ffffffffc0200862:	e1bff0ef          	jal	ra,ffffffffc020067c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200866:	10043583          	ld	a1,256(s0)
ffffffffc020086a:	00006517          	auipc	a0,0x6
ffffffffc020086e:	73e50513          	addi	a0,a0,1854 # ffffffffc0206fa8 <commands+0x838>
ffffffffc0200872:	91dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200876:	10843583          	ld	a1,264(s0)
ffffffffc020087a:	00006517          	auipc	a0,0x6
ffffffffc020087e:	74650513          	addi	a0,a0,1862 # ffffffffc0206fc0 <commands+0x850>
ffffffffc0200882:	90dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200886:	11043583          	ld	a1,272(s0)
ffffffffc020088a:	00006517          	auipc	a0,0x6
ffffffffc020088e:	74e50513          	addi	a0,a0,1870 # ffffffffc0206fd8 <commands+0x868>
ffffffffc0200892:	8fdff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200896:	11843583          	ld	a1,280(s0)
}
ffffffffc020089a:	6402                	ld	s0,0(sp)
ffffffffc020089c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020089e:	00006517          	auipc	a0,0x6
ffffffffc02008a2:	74a50513          	addi	a0,a0,1866 # ffffffffc0206fe8 <commands+0x878>
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
ffffffffc02008ea:	32a50513          	addi	a0,a0,810 # ffffffffc0206c10 <commands+0x4a0>
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
ffffffffc020091e:	0960406f          	j	ffffffffc02049b4 <do_pgfault>
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
ffffffffc0200954:	0600406f          	j	ffffffffc02049b4 <do_pgfault>
        assert(current == idleproc);
ffffffffc0200958:	00006697          	auipc	a3,0x6
ffffffffc020095c:	2d868693          	addi	a3,a3,728 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0200960:	00006617          	auipc	a2,0x6
ffffffffc0200964:	2e860613          	addi	a2,a2,744 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0200968:	06b00593          	li	a1,107
ffffffffc020096c:	00006517          	auipc	a0,0x6
ffffffffc0200970:	2f450513          	addi	a0,a0,756 # ffffffffc0206c60 <commands+0x4f0>
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
ffffffffc02009a6:	26e50513          	addi	a0,a0,622 # ffffffffc0206c10 <commands+0x4a0>
ffffffffc02009aa:	fe4ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            panic("unhandled page fault.\n");
ffffffffc02009ae:	00006617          	auipc	a2,0x6
ffffffffc02009b2:	2ca60613          	addi	a2,a2,714 # ffffffffc0206c78 <commands+0x508>
ffffffffc02009b6:	07200593          	li	a1,114
ffffffffc02009ba:	00006517          	auipc	a0,0x6
ffffffffc02009be:	2a650513          	addi	a0,a0,678 # ffffffffc0206c60 <commands+0x4f0>
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
ffffffffc02009e0:	f7070713          	addi	a4,a4,-144 # ffffffffc020694c <commands+0x1dc>
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
ffffffffc02009f2:	1e250513          	addi	a0,a0,482 # ffffffffc0206bd0 <commands+0x460>
ffffffffc02009f6:	f98ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009fa:	00006517          	auipc	a0,0x6
ffffffffc02009fe:	1b650513          	addi	a0,a0,438 # ffffffffc0206bb0 <commands+0x440>
ffffffffc0200a02:	f8cff06f          	j	ffffffffc020018e <cprintf>
            cprintf("User software interrupt\n");
ffffffffc0200a06:	00006517          	auipc	a0,0x6
ffffffffc0200a0a:	16a50513          	addi	a0,a0,362 # ffffffffc0206b70 <commands+0x400>
ffffffffc0200a0e:	f80ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a12:	00006517          	auipc	a0,0x6
ffffffffc0200a16:	17e50513          	addi	a0,a0,382 # ffffffffc0206b90 <commands+0x420>
ffffffffc0200a1a:	f74ff06f          	j	ffffffffc020018e <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a1e:	00006517          	auipc	a0,0x6
ffffffffc0200a22:	1d250513          	addi	a0,a0,466 # ffffffffc0206bf0 <commands+0x480>
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
ffffffffc0200a70:	1cf76463          	bltu	a4,a5,ffffffffc0200c38 <exception_handler+0x1ce>
ffffffffc0200a74:	00006717          	auipc	a4,0x6
ffffffffc0200a78:	f0870713          	addi	a4,a4,-248 # ffffffffc020697c <commands+0x20c>
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
ffffffffc0200a94:	03850513          	addi	a0,a0,56 # ffffffffc0206ac8 <commands+0x358>
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
ffffffffc0200aae:	6380506f          	j	ffffffffc02060e6 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200ab2:	00006517          	auipc	a0,0x6
ffffffffc0200ab6:	03650513          	addi	a0,a0,54 # ffffffffc0206ae8 <commands+0x378>
}
ffffffffc0200aba:	6442                	ld	s0,16(sp)
ffffffffc0200abc:	60e2                	ld	ra,24(sp)
ffffffffc0200abe:	64a2                	ld	s1,8(sp)
ffffffffc0200ac0:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200ac2:	eccff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200ac6:	00006517          	auipc	a0,0x6
ffffffffc0200aca:	04250513          	addi	a0,a0,66 # ffffffffc0206b08 <commands+0x398>
ffffffffc0200ace:	b7f5                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ad0:	00006517          	auipc	a0,0x6
ffffffffc0200ad4:	05850513          	addi	a0,a0,88 # ffffffffc0206b28 <commands+0x3b8>
ffffffffc0200ad8:	b7cd                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ada:	00006517          	auipc	a0,0x6
ffffffffc0200ade:	06650513          	addi	a0,a0,102 # ffffffffc0206b40 <commands+0x3d0>
ffffffffc0200ae2:	eacff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae6:	8522                	mv	a0,s0
ffffffffc0200ae8:	dc5ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200aec:	84aa                	mv	s1,a0
ffffffffc0200aee:	14051763          	bnez	a0,ffffffffc0200c3c <exception_handler+0x1d2>
}
ffffffffc0200af2:	60e2                	ld	ra,24(sp)
ffffffffc0200af4:	6442                	ld	s0,16(sp)
ffffffffc0200af6:	64a2                	ld	s1,8(sp)
ffffffffc0200af8:	6105                	addi	sp,sp,32
ffffffffc0200afa:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200afc:	00006517          	auipc	a0,0x6
ffffffffc0200b00:	05c50513          	addi	a0,a0,92 # ffffffffc0206b58 <commands+0x3e8>
ffffffffc0200b04:	e8aff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b08:	8522                	mv	a0,s0
ffffffffc0200b0a:	da3ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200b0e:	84aa                	mv	s1,a0
ffffffffc0200b10:	d16d                	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b12:	8522                	mv	a0,s0
ffffffffc0200b14:	d37ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b18:	86a6                	mv	a3,s1
ffffffffc0200b1a:	00006617          	auipc	a2,0x6
ffffffffc0200b1e:	f5e60613          	addi	a2,a2,-162 # ffffffffc0206a78 <commands+0x308>
ffffffffc0200b22:	0f900593          	li	a1,249
ffffffffc0200b26:	00006517          	auipc	a0,0x6
ffffffffc0200b2a:	13a50513          	addi	a0,a0,314 # ffffffffc0206c60 <commands+0x4f0>
ffffffffc0200b2e:	957ff0ef          	jal	ra,ffffffffc0200484 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b32:	00006517          	auipc	a0,0x6
ffffffffc0200b36:	e8e50513          	addi	a0,a0,-370 # ffffffffc02069c0 <commands+0x250>
ffffffffc0200b3a:	b741                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b3c:	00006517          	auipc	a0,0x6
ffffffffc0200b40:	ea450513          	addi	a0,a0,-348 # ffffffffc02069e0 <commands+0x270>
ffffffffc0200b44:	bf9d                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b46:	00006517          	auipc	a0,0x6
ffffffffc0200b4a:	eba50513          	addi	a0,a0,-326 # ffffffffc0206a00 <commands+0x290>
ffffffffc0200b4e:	b7b5                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b50:	00006517          	auipc	a0,0x6
ffffffffc0200b54:	ec850513          	addi	a0,a0,-312 # ffffffffc0206a18 <commands+0x2a8>
ffffffffc0200b58:	e36ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b5c:	6458                	ld	a4,136(s0)
ffffffffc0200b5e:	47a9                	li	a5,10
ffffffffc0200b60:	f8f719e3          	bne	a4,a5,ffffffffc0200af2 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b64:	10843783          	ld	a5,264(s0)
                cprintf("activate syscall\n");
ffffffffc0200b68:	00006517          	auipc	a0,0x6
ffffffffc0200b6c:	ec050513          	addi	a0,a0,-320 # ffffffffc0206a28 <commands+0x2b8>
                tf->epc += 4;
ffffffffc0200b70:	0791                	addi	a5,a5,4
ffffffffc0200b72:	10f43423          	sd	a5,264(s0)
                cprintf("activate syscall\n");
ffffffffc0200b76:	e18ff0ef          	jal	ra,ffffffffc020018e <cprintf>
                syscall();
ffffffffc0200b7a:	56c050ef          	jal	ra,ffffffffc02060e6 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b7e:	000ac797          	auipc	a5,0xac
ffffffffc0200b82:	9b278793          	addi	a5,a5,-1614 # ffffffffc02ac530 <current>
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
ffffffffc0200b9c:	00006517          	auipc	a0,0x6
ffffffffc0200ba0:	ea450513          	addi	a0,a0,-348 # ffffffffc0206a40 <commands+0x2d0>
ffffffffc0200ba4:	bf19                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200ba6:	00006517          	auipc	a0,0x6
ffffffffc0200baa:	eba50513          	addi	a0,a0,-326 # ffffffffc0206a60 <commands+0x2f0>
ffffffffc0200bae:	de0ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bb2:	8522                	mv	a0,s0
ffffffffc0200bb4:	cf9ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200bb8:	84aa                	mv	s1,a0
ffffffffc0200bba:	dd05                	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bbc:	8522                	mv	a0,s0
ffffffffc0200bbe:	c8dff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bc2:	86a6                	mv	a3,s1
ffffffffc0200bc4:	00006617          	auipc	a2,0x6
ffffffffc0200bc8:	eb460613          	addi	a2,a2,-332 # ffffffffc0206a78 <commands+0x308>
ffffffffc0200bcc:	0ce00593          	li	a1,206
ffffffffc0200bd0:	00006517          	auipc	a0,0x6
ffffffffc0200bd4:	09050513          	addi	a0,a0,144 # ffffffffc0206c60 <commands+0x4f0>
ffffffffc0200bd8:	8adff0ef          	jal	ra,ffffffffc0200484 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bdc:	00006517          	auipc	a0,0x6
ffffffffc0200be0:	ed450513          	addi	a0,a0,-300 # ffffffffc0206ab0 <commands+0x340>
ffffffffc0200be4:	daaff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200be8:	8522                	mv	a0,s0
ffffffffc0200bea:	cc3ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200bee:	84aa                	mv	s1,a0
ffffffffc0200bf0:	f00501e3          	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bf4:	8522                	mv	a0,s0
ffffffffc0200bf6:	c55ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bfa:	86a6                	mv	a3,s1
ffffffffc0200bfc:	00006617          	auipc	a2,0x6
ffffffffc0200c00:	e7c60613          	addi	a2,a2,-388 # ffffffffc0206a78 <commands+0x308>
ffffffffc0200c04:	0d800593          	li	a1,216
ffffffffc0200c08:	00006517          	auipc	a0,0x6
ffffffffc0200c0c:	05850513          	addi	a0,a0,88 # ffffffffc0206c60 <commands+0x4f0>
ffffffffc0200c10:	875ff0ef          	jal	ra,ffffffffc0200484 <__panic>
}
ffffffffc0200c14:	6442                	ld	s0,16(sp)
ffffffffc0200c16:	60e2                	ld	ra,24(sp)
ffffffffc0200c18:	64a2                	ld	s1,8(sp)
ffffffffc0200c1a:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200c1c:	c2fff06f          	j	ffffffffc020084a <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200c20:	00006617          	auipc	a2,0x6
ffffffffc0200c24:	e7860613          	addi	a2,a2,-392 # ffffffffc0206a98 <commands+0x328>
ffffffffc0200c28:	0d200593          	li	a1,210
ffffffffc0200c2c:	00006517          	auipc	a0,0x6
ffffffffc0200c30:	03450513          	addi	a0,a0,52 # ffffffffc0206c60 <commands+0x4f0>
ffffffffc0200c34:	851ff0ef          	jal	ra,ffffffffc0200484 <__panic>
            print_trapframe(tf);
ffffffffc0200c38:	c13ff06f          	j	ffffffffc020084a <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c3c:	8522                	mv	a0,s0
ffffffffc0200c3e:	c0dff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c42:	86a6                	mv	a3,s1
ffffffffc0200c44:	00006617          	auipc	a2,0x6
ffffffffc0200c48:	e3460613          	addi	a2,a2,-460 # ffffffffc0206a78 <commands+0x308>
ffffffffc0200c4c:	0f200593          	li	a1,242
ffffffffc0200c50:	00006517          	auipc	a0,0x6
ffffffffc0200c54:	01050513          	addi	a0,a0,16 # ffffffffc0206c60 <commands+0x4f0>
ffffffffc0200c58:	82dff0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0200c5c <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c5c:	1101                	addi	sp,sp,-32
ffffffffc0200c5e:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c60:	000ac417          	auipc	s0,0xac
ffffffffc0200c64:	8d040413          	addi	s0,s0,-1840 # ffffffffc02ac530 <current>
ffffffffc0200c68:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c6a:	ec06                	sd	ra,24(sp)
ffffffffc0200c6c:	e426                	sd	s1,8(sp)
ffffffffc0200c6e:	e04a                	sd	s2,0(sp)
ffffffffc0200c70:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c74:	cf1d                	beqz	a4,ffffffffc0200cb2 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c76:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c7a:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c7e:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c80:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c84:	0206c463          	bltz	a3,ffffffffc0200cac <trap+0x50>
        exception_handler(tf);
ffffffffc0200c88:	de3ff0ef          	jal	ra,ffffffffc0200a6a <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c8c:	601c                	ld	a5,0(s0)
ffffffffc0200c8e:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c92:	e499                	bnez	s1,ffffffffc0200ca0 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c94:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c98:	8b05                	andi	a4,a4,1
ffffffffc0200c9a:	e339                	bnez	a4,ffffffffc0200ce0 <trap+0x84>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c9c:	6f9c                	ld	a5,24(a5)
ffffffffc0200c9e:	eb95                	bnez	a5,ffffffffc0200cd2 <trap+0x76>
                schedule();
            }
        }
    }
}
ffffffffc0200ca0:	60e2                	ld	ra,24(sp)
ffffffffc0200ca2:	6442                	ld	s0,16(sp)
ffffffffc0200ca4:	64a2                	ld	s1,8(sp)
ffffffffc0200ca6:	6902                	ld	s2,0(sp)
ffffffffc0200ca8:	6105                	addi	sp,sp,32
ffffffffc0200caa:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200cac:	d21ff0ef          	jal	ra,ffffffffc02009cc <interrupt_handler>
ffffffffc0200cb0:	bff1                	j	ffffffffc0200c8c <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200cb2:	0006c963          	bltz	a3,ffffffffc0200cc4 <trap+0x68>
}
ffffffffc0200cb6:	6442                	ld	s0,16(sp)
ffffffffc0200cb8:	60e2                	ld	ra,24(sp)
ffffffffc0200cba:	64a2                	ld	s1,8(sp)
ffffffffc0200cbc:	6902                	ld	s2,0(sp)
ffffffffc0200cbe:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200cc0:	dabff06f          	j	ffffffffc0200a6a <exception_handler>
}
ffffffffc0200cc4:	6442                	ld	s0,16(sp)
ffffffffc0200cc6:	60e2                	ld	ra,24(sp)
ffffffffc0200cc8:	64a2                	ld	s1,8(sp)
ffffffffc0200cca:	6902                	ld	s2,0(sp)
ffffffffc0200ccc:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200cce:	cffff06f          	j	ffffffffc02009cc <interrupt_handler>
}
ffffffffc0200cd2:	6442                	ld	s0,16(sp)
ffffffffc0200cd4:	60e2                	ld	ra,24(sp)
ffffffffc0200cd6:	64a2                	ld	s1,8(sp)
ffffffffc0200cd8:	6902                	ld	s2,0(sp)
ffffffffc0200cda:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200cdc:	3140506f          	j	ffffffffc0205ff0 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200ce0:	555d                	li	a0,-9
ffffffffc0200ce2:	70c040ef          	jal	ra,ffffffffc02053ee <do_exit>
ffffffffc0200ce6:	601c                	ld	a5,0(s0)
ffffffffc0200ce8:	bf55                	j	ffffffffc0200c9c <trap+0x40>
	...

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
ffffffffc0200d58:	f05ff0ef          	jal	ra,ffffffffc0200c5c <trap>

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
ffffffffc0200dba:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7698>

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
ffffffffc0200e62:	000ab797          	auipc	a5,0xab
ffffffffc0200e66:	6f678793          	addi	a5,a5,1782 # ffffffffc02ac558 <free_area>
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
ffffffffc0200e74:	000ab517          	auipc	a0,0xab
ffffffffc0200e78:	6f456503          	lwu	a0,1780(a0) # ffffffffc02ac568 <free_area+0x10>
ffffffffc0200e7c:	8082                	ret

ffffffffc0200e7e <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
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
ffffffffc0200e82:	000ab917          	auipc	s2,0xab
ffffffffc0200e86:	6d690913          	addi	s2,s2,1750 # ffffffffc02ac558 <free_area>
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
ffffffffc0200f1e:	000ab797          	auipc	a5,0xab
ffffffffc0200f22:	66a78793          	addi	a5,a5,1642 # ffffffffc02ac588 <pages>
ffffffffc0200f26:	639c                	ld	a5,0(a5)
ffffffffc0200f28:	00008717          	auipc	a4,0x8
ffffffffc0200f2c:	e1870713          	addi	a4,a4,-488 # ffffffffc0208d40 <nbase>
ffffffffc0200f30:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f32:	000ab717          	auipc	a4,0xab
ffffffffc0200f36:	5e670713          	addi	a4,a4,1510 # ffffffffc02ac518 <npage>
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
ffffffffc0200f76:	000ab797          	auipc	a5,0xab
ffffffffc0200f7a:	5f27b523          	sd	s2,1514(a5) # ffffffffc02ac560 <free_area+0x8>
ffffffffc0200f7e:	000ab797          	auipc	a5,0xab
ffffffffc0200f82:	5d27bd23          	sd	s2,1498(a5) # ffffffffc02ac558 <free_area>
    nr_free = 0;
ffffffffc0200f86:	000ab797          	auipc	a5,0xab
ffffffffc0200f8a:	5e07a123          	sw	zero,1506(a5) # ffffffffc02ac568 <free_area+0x10>
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
ffffffffc0201016:	000ab797          	auipc	a5,0xab
ffffffffc020101a:	5587b123          	sd	s8,1346(a5) # ffffffffc02ac558 <free_area>
ffffffffc020101e:	000ab797          	auipc	a5,0xab
ffffffffc0201022:	5577b123          	sd	s7,1346(a5) # ffffffffc02ac560 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0201026:	000ab797          	auipc	a5,0xab
ffffffffc020102a:	5567a123          	sw	s6,1346(a5) # ffffffffc02ac568 <free_area+0x10>
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
ffffffffc0201062:	000ab797          	auipc	a5,0xab
ffffffffc0201066:	4f27bb23          	sd	s2,1270(a5) # ffffffffc02ac558 <free_area>
ffffffffc020106a:	000ab797          	auipc	a5,0xab
ffffffffc020106e:	4f27bb23          	sd	s2,1270(a5) # ffffffffc02ac560 <free_area+0x8>
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
ffffffffc0201086:	000ab797          	auipc	a5,0xab
ffffffffc020108a:	4e07a123          	sw	zero,1250(a5) # ffffffffc02ac568 <free_area+0x10>
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
ffffffffc0201156:	000ab797          	auipc	a5,0xab
ffffffffc020115a:	4177a923          	sw	s7,1042(a5) # ffffffffc02ac568 <free_area+0x10>
    free_list = free_list_store;
ffffffffc020115e:	000ab797          	auipc	a5,0xab
ffffffffc0201162:	3f67bd23          	sd	s6,1018(a5) # ffffffffc02ac558 <free_area>
ffffffffc0201166:	000ab797          	auipc	a5,0xab
ffffffffc020116a:	3f57bd23          	sd	s5,1018(a5) # ffffffffc02ac560 <free_area+0x8>
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
ffffffffc02011b0:	00006697          	auipc	a3,0x6
ffffffffc02011b4:	e5068693          	addi	a3,a3,-432 # ffffffffc0207000 <commands+0x890>
ffffffffc02011b8:	00006617          	auipc	a2,0x6
ffffffffc02011bc:	a9060613          	addi	a2,a2,-1392 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02011c0:	0f000593          	li	a1,240
ffffffffc02011c4:	00006517          	auipc	a0,0x6
ffffffffc02011c8:	e4c50513          	addi	a0,a0,-436 # ffffffffc0207010 <commands+0x8a0>
ffffffffc02011cc:	ab8ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02011d0:	00006697          	auipc	a3,0x6
ffffffffc02011d4:	ed868693          	addi	a3,a3,-296 # ffffffffc02070a8 <commands+0x938>
ffffffffc02011d8:	00006617          	auipc	a2,0x6
ffffffffc02011dc:	a7060613          	addi	a2,a2,-1424 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02011e0:	0bd00593          	li	a1,189
ffffffffc02011e4:	00006517          	auipc	a0,0x6
ffffffffc02011e8:	e2c50513          	addi	a0,a0,-468 # ffffffffc0207010 <commands+0x8a0>
ffffffffc02011ec:	a98ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02011f0:	00006697          	auipc	a3,0x6
ffffffffc02011f4:	ee068693          	addi	a3,a3,-288 # ffffffffc02070d0 <commands+0x960>
ffffffffc02011f8:	00006617          	auipc	a2,0x6
ffffffffc02011fc:	a5060613          	addi	a2,a2,-1456 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201200:	0be00593          	li	a1,190
ffffffffc0201204:	00006517          	auipc	a0,0x6
ffffffffc0201208:	e0c50513          	addi	a0,a0,-500 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020120c:	a78ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201210:	00006697          	auipc	a3,0x6
ffffffffc0201214:	f0068693          	addi	a3,a3,-256 # ffffffffc0207110 <commands+0x9a0>
ffffffffc0201218:	00006617          	auipc	a2,0x6
ffffffffc020121c:	a3060613          	addi	a2,a2,-1488 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201220:	0c000593          	li	a1,192
ffffffffc0201224:	00006517          	auipc	a0,0x6
ffffffffc0201228:	dec50513          	addi	a0,a0,-532 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020122c:	a58ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201230:	00006697          	auipc	a3,0x6
ffffffffc0201234:	f6868693          	addi	a3,a3,-152 # ffffffffc0207198 <commands+0xa28>
ffffffffc0201238:	00006617          	auipc	a2,0x6
ffffffffc020123c:	a1060613          	addi	a2,a2,-1520 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201240:	0d900593          	li	a1,217
ffffffffc0201244:	00006517          	auipc	a0,0x6
ffffffffc0201248:	dcc50513          	addi	a0,a0,-564 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020124c:	a38ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201250:	00006697          	auipc	a3,0x6
ffffffffc0201254:	df868693          	addi	a3,a3,-520 # ffffffffc0207048 <commands+0x8d8>
ffffffffc0201258:	00006617          	auipc	a2,0x6
ffffffffc020125c:	9f060613          	addi	a2,a2,-1552 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201260:	0d200593          	li	a1,210
ffffffffc0201264:	00006517          	auipc	a0,0x6
ffffffffc0201268:	dac50513          	addi	a0,a0,-596 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020126c:	a18ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free == 3);
ffffffffc0201270:	00006697          	auipc	a3,0x6
ffffffffc0201274:	f1868693          	addi	a3,a3,-232 # ffffffffc0207188 <commands+0xa18>
ffffffffc0201278:	00006617          	auipc	a2,0x6
ffffffffc020127c:	9d060613          	addi	a2,a2,-1584 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201280:	0d000593          	li	a1,208
ffffffffc0201284:	00006517          	auipc	a0,0x6
ffffffffc0201288:	d8c50513          	addi	a0,a0,-628 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020128c:	9f8ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201290:	00006697          	auipc	a3,0x6
ffffffffc0201294:	ee068693          	addi	a3,a3,-288 # ffffffffc0207170 <commands+0xa00>
ffffffffc0201298:	00006617          	auipc	a2,0x6
ffffffffc020129c:	9b060613          	addi	a2,a2,-1616 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02012a0:	0cb00593          	li	a1,203
ffffffffc02012a4:	00006517          	auipc	a0,0x6
ffffffffc02012a8:	d6c50513          	addi	a0,a0,-660 # ffffffffc0207010 <commands+0x8a0>
ffffffffc02012ac:	9d8ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02012b0:	00006697          	auipc	a3,0x6
ffffffffc02012b4:	ea068693          	addi	a3,a3,-352 # ffffffffc0207150 <commands+0x9e0>
ffffffffc02012b8:	00006617          	auipc	a2,0x6
ffffffffc02012bc:	99060613          	addi	a2,a2,-1648 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02012c0:	0c200593          	li	a1,194
ffffffffc02012c4:	00006517          	auipc	a0,0x6
ffffffffc02012c8:	d4c50513          	addi	a0,a0,-692 # ffffffffc0207010 <commands+0x8a0>
ffffffffc02012cc:	9b8ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(p0 != NULL);
ffffffffc02012d0:	00006697          	auipc	a3,0x6
ffffffffc02012d4:	f1068693          	addi	a3,a3,-240 # ffffffffc02071e0 <commands+0xa70>
ffffffffc02012d8:	00006617          	auipc	a2,0x6
ffffffffc02012dc:	97060613          	addi	a2,a2,-1680 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02012e0:	0f800593          	li	a1,248
ffffffffc02012e4:	00006517          	auipc	a0,0x6
ffffffffc02012e8:	d2c50513          	addi	a0,a0,-724 # ffffffffc0207010 <commands+0x8a0>
ffffffffc02012ec:	998ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free == 0);
ffffffffc02012f0:	00006697          	auipc	a3,0x6
ffffffffc02012f4:	ee068693          	addi	a3,a3,-288 # ffffffffc02071d0 <commands+0xa60>
ffffffffc02012f8:	00006617          	auipc	a2,0x6
ffffffffc02012fc:	95060613          	addi	a2,a2,-1712 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201300:	0df00593          	li	a1,223
ffffffffc0201304:	00006517          	auipc	a0,0x6
ffffffffc0201308:	d0c50513          	addi	a0,a0,-756 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020130c:	978ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201310:	00006697          	auipc	a3,0x6
ffffffffc0201314:	e6068693          	addi	a3,a3,-416 # ffffffffc0207170 <commands+0xa00>
ffffffffc0201318:	00006617          	auipc	a2,0x6
ffffffffc020131c:	93060613          	addi	a2,a2,-1744 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201320:	0dd00593          	li	a1,221
ffffffffc0201324:	00006517          	auipc	a0,0x6
ffffffffc0201328:	cec50513          	addi	a0,a0,-788 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020132c:	958ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201330:	00006697          	auipc	a3,0x6
ffffffffc0201334:	e8068693          	addi	a3,a3,-384 # ffffffffc02071b0 <commands+0xa40>
ffffffffc0201338:	00006617          	auipc	a2,0x6
ffffffffc020133c:	91060613          	addi	a2,a2,-1776 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201340:	0dc00593          	li	a1,220
ffffffffc0201344:	00006517          	auipc	a0,0x6
ffffffffc0201348:	ccc50513          	addi	a0,a0,-820 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020134c:	938ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201350:	00006697          	auipc	a3,0x6
ffffffffc0201354:	cf868693          	addi	a3,a3,-776 # ffffffffc0207048 <commands+0x8d8>
ffffffffc0201358:	00006617          	auipc	a2,0x6
ffffffffc020135c:	8f060613          	addi	a2,a2,-1808 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201360:	0b900593          	li	a1,185
ffffffffc0201364:	00006517          	auipc	a0,0x6
ffffffffc0201368:	cac50513          	addi	a0,a0,-852 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020136c:	918ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201370:	00006697          	auipc	a3,0x6
ffffffffc0201374:	e0068693          	addi	a3,a3,-512 # ffffffffc0207170 <commands+0xa00>
ffffffffc0201378:	00006617          	auipc	a2,0x6
ffffffffc020137c:	8d060613          	addi	a2,a2,-1840 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201380:	0d600593          	li	a1,214
ffffffffc0201384:	00006517          	auipc	a0,0x6
ffffffffc0201388:	c8c50513          	addi	a0,a0,-884 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020138c:	8f8ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201390:	00006697          	auipc	a3,0x6
ffffffffc0201394:	cf868693          	addi	a3,a3,-776 # ffffffffc0207088 <commands+0x918>
ffffffffc0201398:	00006617          	auipc	a2,0x6
ffffffffc020139c:	8b060613          	addi	a2,a2,-1872 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02013a0:	0d400593          	li	a1,212
ffffffffc02013a4:	00006517          	auipc	a0,0x6
ffffffffc02013a8:	c6c50513          	addi	a0,a0,-916 # ffffffffc0207010 <commands+0x8a0>
ffffffffc02013ac:	8d8ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02013b0:	00006697          	auipc	a3,0x6
ffffffffc02013b4:	cb868693          	addi	a3,a3,-840 # ffffffffc0207068 <commands+0x8f8>
ffffffffc02013b8:	00006617          	auipc	a2,0x6
ffffffffc02013bc:	89060613          	addi	a2,a2,-1904 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02013c0:	0d300593          	li	a1,211
ffffffffc02013c4:	00006517          	auipc	a0,0x6
ffffffffc02013c8:	c4c50513          	addi	a0,a0,-948 # ffffffffc0207010 <commands+0x8a0>
ffffffffc02013cc:	8b8ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02013d0:	00006697          	auipc	a3,0x6
ffffffffc02013d4:	cb868693          	addi	a3,a3,-840 # ffffffffc0207088 <commands+0x918>
ffffffffc02013d8:	00006617          	auipc	a2,0x6
ffffffffc02013dc:	87060613          	addi	a2,a2,-1936 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02013e0:	0bb00593          	li	a1,187
ffffffffc02013e4:	00006517          	auipc	a0,0x6
ffffffffc02013e8:	c2c50513          	addi	a0,a0,-980 # ffffffffc0207010 <commands+0x8a0>
ffffffffc02013ec:	898ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(count == 0);
ffffffffc02013f0:	00006697          	auipc	a3,0x6
ffffffffc02013f4:	f4068693          	addi	a3,a3,-192 # ffffffffc0207330 <commands+0xbc0>
ffffffffc02013f8:	00006617          	auipc	a2,0x6
ffffffffc02013fc:	85060613          	addi	a2,a2,-1968 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201400:	12500593          	li	a1,293
ffffffffc0201404:	00006517          	auipc	a0,0x6
ffffffffc0201408:	c0c50513          	addi	a0,a0,-1012 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020140c:	878ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free == 0);
ffffffffc0201410:	00006697          	auipc	a3,0x6
ffffffffc0201414:	dc068693          	addi	a3,a3,-576 # ffffffffc02071d0 <commands+0xa60>
ffffffffc0201418:	00006617          	auipc	a2,0x6
ffffffffc020141c:	83060613          	addi	a2,a2,-2000 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201420:	11a00593          	li	a1,282
ffffffffc0201424:	00006517          	auipc	a0,0x6
ffffffffc0201428:	bec50513          	addi	a0,a0,-1044 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020142c:	858ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201430:	00006697          	auipc	a3,0x6
ffffffffc0201434:	d4068693          	addi	a3,a3,-704 # ffffffffc0207170 <commands+0xa00>
ffffffffc0201438:	00006617          	auipc	a2,0x6
ffffffffc020143c:	81060613          	addi	a2,a2,-2032 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201440:	11800593          	li	a1,280
ffffffffc0201444:	00006517          	auipc	a0,0x6
ffffffffc0201448:	bcc50513          	addi	a0,a0,-1076 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020144c:	838ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201450:	00006697          	auipc	a3,0x6
ffffffffc0201454:	ce068693          	addi	a3,a3,-800 # ffffffffc0207130 <commands+0x9c0>
ffffffffc0201458:	00005617          	auipc	a2,0x5
ffffffffc020145c:	7f060613          	addi	a2,a2,2032 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201460:	0c100593          	li	a1,193
ffffffffc0201464:	00006517          	auipc	a0,0x6
ffffffffc0201468:	bac50513          	addi	a0,a0,-1108 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020146c:	818ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201470:	00006697          	auipc	a3,0x6
ffffffffc0201474:	e8068693          	addi	a3,a3,-384 # ffffffffc02072f0 <commands+0xb80>
ffffffffc0201478:	00005617          	auipc	a2,0x5
ffffffffc020147c:	7d060613          	addi	a2,a2,2000 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201480:	11200593          	li	a1,274
ffffffffc0201484:	00006517          	auipc	a0,0x6
ffffffffc0201488:	b8c50513          	addi	a0,a0,-1140 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020148c:	ff9fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201490:	00006697          	auipc	a3,0x6
ffffffffc0201494:	e4068693          	addi	a3,a3,-448 # ffffffffc02072d0 <commands+0xb60>
ffffffffc0201498:	00005617          	auipc	a2,0x5
ffffffffc020149c:	7b060613          	addi	a2,a2,1968 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02014a0:	11000593          	li	a1,272
ffffffffc02014a4:	00006517          	auipc	a0,0x6
ffffffffc02014a8:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0207010 <commands+0x8a0>
ffffffffc02014ac:	fd9fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02014b0:	00006697          	auipc	a3,0x6
ffffffffc02014b4:	df868693          	addi	a3,a3,-520 # ffffffffc02072a8 <commands+0xb38>
ffffffffc02014b8:	00005617          	auipc	a2,0x5
ffffffffc02014bc:	79060613          	addi	a2,a2,1936 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02014c0:	10e00593          	li	a1,270
ffffffffc02014c4:	00006517          	auipc	a0,0x6
ffffffffc02014c8:	b4c50513          	addi	a0,a0,-1204 # ffffffffc0207010 <commands+0x8a0>
ffffffffc02014cc:	fb9fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02014d0:	00006697          	auipc	a3,0x6
ffffffffc02014d4:	db068693          	addi	a3,a3,-592 # ffffffffc0207280 <commands+0xb10>
ffffffffc02014d8:	00005617          	auipc	a2,0x5
ffffffffc02014dc:	77060613          	addi	a2,a2,1904 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02014e0:	10d00593          	li	a1,269
ffffffffc02014e4:	00006517          	auipc	a0,0x6
ffffffffc02014e8:	b2c50513          	addi	a0,a0,-1236 # ffffffffc0207010 <commands+0x8a0>
ffffffffc02014ec:	f99fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02014f0:	00006697          	auipc	a3,0x6
ffffffffc02014f4:	d8068693          	addi	a3,a3,-640 # ffffffffc0207270 <commands+0xb00>
ffffffffc02014f8:	00005617          	auipc	a2,0x5
ffffffffc02014fc:	75060613          	addi	a2,a2,1872 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201500:	10800593          	li	a1,264
ffffffffc0201504:	00006517          	auipc	a0,0x6
ffffffffc0201508:	b0c50513          	addi	a0,a0,-1268 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020150c:	f79fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201510:	00006697          	auipc	a3,0x6
ffffffffc0201514:	c6068693          	addi	a3,a3,-928 # ffffffffc0207170 <commands+0xa00>
ffffffffc0201518:	00005617          	auipc	a2,0x5
ffffffffc020151c:	73060613          	addi	a2,a2,1840 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201520:	10700593          	li	a1,263
ffffffffc0201524:	00006517          	auipc	a0,0x6
ffffffffc0201528:	aec50513          	addi	a0,a0,-1300 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020152c:	f59fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201530:	00006697          	auipc	a3,0x6
ffffffffc0201534:	d2068693          	addi	a3,a3,-736 # ffffffffc0207250 <commands+0xae0>
ffffffffc0201538:	00005617          	auipc	a2,0x5
ffffffffc020153c:	71060613          	addi	a2,a2,1808 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201540:	10600593          	li	a1,262
ffffffffc0201544:	00006517          	auipc	a0,0x6
ffffffffc0201548:	acc50513          	addi	a0,a0,-1332 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020154c:	f39fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201550:	00006697          	auipc	a3,0x6
ffffffffc0201554:	cd068693          	addi	a3,a3,-816 # ffffffffc0207220 <commands+0xab0>
ffffffffc0201558:	00005617          	auipc	a2,0x5
ffffffffc020155c:	6f060613          	addi	a2,a2,1776 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201560:	10500593          	li	a1,261
ffffffffc0201564:	00006517          	auipc	a0,0x6
ffffffffc0201568:	aac50513          	addi	a0,a0,-1364 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020156c:	f19fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201570:	00006697          	auipc	a3,0x6
ffffffffc0201574:	c9868693          	addi	a3,a3,-872 # ffffffffc0207208 <commands+0xa98>
ffffffffc0201578:	00005617          	auipc	a2,0x5
ffffffffc020157c:	6d060613          	addi	a2,a2,1744 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201580:	10400593          	li	a1,260
ffffffffc0201584:	00006517          	auipc	a0,0x6
ffffffffc0201588:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020158c:	ef9fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201590:	00006697          	auipc	a3,0x6
ffffffffc0201594:	be068693          	addi	a3,a3,-1056 # ffffffffc0207170 <commands+0xa00>
ffffffffc0201598:	00005617          	auipc	a2,0x5
ffffffffc020159c:	6b060613          	addi	a2,a2,1712 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02015a0:	0fe00593          	li	a1,254
ffffffffc02015a4:	00006517          	auipc	a0,0x6
ffffffffc02015a8:	a6c50513          	addi	a0,a0,-1428 # ffffffffc0207010 <commands+0x8a0>
ffffffffc02015ac:	ed9fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(!PageProperty(p0));
ffffffffc02015b0:	00006697          	auipc	a3,0x6
ffffffffc02015b4:	c4068693          	addi	a3,a3,-960 # ffffffffc02071f0 <commands+0xa80>
ffffffffc02015b8:	00005617          	auipc	a2,0x5
ffffffffc02015bc:	69060613          	addi	a2,a2,1680 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02015c0:	0f900593          	li	a1,249
ffffffffc02015c4:	00006517          	auipc	a0,0x6
ffffffffc02015c8:	a4c50513          	addi	a0,a0,-1460 # ffffffffc0207010 <commands+0x8a0>
ffffffffc02015cc:	eb9fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02015d0:	00006697          	auipc	a3,0x6
ffffffffc02015d4:	d4068693          	addi	a3,a3,-704 # ffffffffc0207310 <commands+0xba0>
ffffffffc02015d8:	00005617          	auipc	a2,0x5
ffffffffc02015dc:	67060613          	addi	a2,a2,1648 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02015e0:	11700593          	li	a1,279
ffffffffc02015e4:	00006517          	auipc	a0,0x6
ffffffffc02015e8:	a2c50513          	addi	a0,a0,-1492 # ffffffffc0207010 <commands+0x8a0>
ffffffffc02015ec:	e99fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(total == 0);
ffffffffc02015f0:	00006697          	auipc	a3,0x6
ffffffffc02015f4:	d5068693          	addi	a3,a3,-688 # ffffffffc0207340 <commands+0xbd0>
ffffffffc02015f8:	00005617          	auipc	a2,0x5
ffffffffc02015fc:	65060613          	addi	a2,a2,1616 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201600:	12600593          	li	a1,294
ffffffffc0201604:	00006517          	auipc	a0,0x6
ffffffffc0201608:	a0c50513          	addi	a0,a0,-1524 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020160c:	e79fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201610:	00006697          	auipc	a3,0x6
ffffffffc0201614:	a1868693          	addi	a3,a3,-1512 # ffffffffc0207028 <commands+0x8b8>
ffffffffc0201618:	00005617          	auipc	a2,0x5
ffffffffc020161c:	63060613          	addi	a2,a2,1584 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201620:	0f300593          	li	a1,243
ffffffffc0201624:	00006517          	auipc	a0,0x6
ffffffffc0201628:	9ec50513          	addi	a0,a0,-1556 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020162c:	e59fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201630:	00006697          	auipc	a3,0x6
ffffffffc0201634:	a3868693          	addi	a3,a3,-1480 # ffffffffc0207068 <commands+0x8f8>
ffffffffc0201638:	00005617          	auipc	a2,0x5
ffffffffc020163c:	61060613          	addi	a2,a2,1552 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201640:	0ba00593          	li	a1,186
ffffffffc0201644:	00006517          	auipc	a0,0x6
ffffffffc0201648:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020164c:	e39fe0ef          	jal	ra,ffffffffc0200484 <__panic>

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
ffffffffc02016a6:	000ab697          	auipc	a3,0xab
ffffffffc02016aa:	eb268693          	addi	a3,a3,-334 # ffffffffc02ac558 <free_area>
ffffffffc02016ae:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02016b0:	669c                	ld	a5,8(a3)
ffffffffc02016b2:	9db9                	addw	a1,a1,a4
ffffffffc02016b4:	000ab717          	auipc	a4,0xab
ffffffffc02016b8:	eab72a23          	sw	a1,-332(a4) # ffffffffc02ac568 <free_area+0x10>
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
ffffffffc02016e4:	000ab817          	auipc	a6,0xab
ffffffffc02016e8:	e6b83a23          	sd	a1,-396(a6) # ffffffffc02ac558 <free_area>
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
ffffffffc02017b0:	00006697          	auipc	a3,0x6
ffffffffc02017b4:	ba068693          	addi	a3,a3,-1120 # ffffffffc0207350 <commands+0xbe0>
ffffffffc02017b8:	00005617          	auipc	a2,0x5
ffffffffc02017bc:	49060613          	addi	a2,a2,1168 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02017c0:	08300593          	li	a1,131
ffffffffc02017c4:	00006517          	auipc	a0,0x6
ffffffffc02017c8:	84c50513          	addi	a0,a0,-1972 # ffffffffc0207010 <commands+0x8a0>
ffffffffc02017cc:	cb9fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(n > 0);
ffffffffc02017d0:	00006697          	auipc	a3,0x6
ffffffffc02017d4:	ba868693          	addi	a3,a3,-1112 # ffffffffc0207378 <commands+0xc08>
ffffffffc02017d8:	00005617          	auipc	a2,0x5
ffffffffc02017dc:	47060613          	addi	a2,a2,1136 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02017e0:	08000593          	li	a1,128
ffffffffc02017e4:	00006517          	auipc	a0,0x6
ffffffffc02017e8:	82c50513          	addi	a0,a0,-2004 # ffffffffc0207010 <commands+0x8a0>
ffffffffc02017ec:	c99fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02017f0 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02017f0:	c959                	beqz	a0,ffffffffc0201886 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02017f2:	000ab597          	auipc	a1,0xab
ffffffffc02017f6:	d6658593          	addi	a1,a1,-666 # ffffffffc02ac558 <free_area>
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
ffffffffc0201874:	000ab717          	auipc	a4,0xab
ffffffffc0201878:	cf072a23          	sw	a6,-780(a4) # ffffffffc02ac568 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020187c:	5775                	li	a4,-3
ffffffffc020187e:	17c1                	addi	a5,a5,-16
ffffffffc0201880:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201884:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201886:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201888:	00006697          	auipc	a3,0x6
ffffffffc020188c:	af068693          	addi	a3,a3,-1296 # ffffffffc0207378 <commands+0xc08>
ffffffffc0201890:	00005617          	auipc	a2,0x5
ffffffffc0201894:	3b860613          	addi	a2,a2,952 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201898:	06200593          	li	a1,98
ffffffffc020189c:	00005517          	auipc	a0,0x5
ffffffffc02018a0:	77450513          	addi	a0,a0,1908 # ffffffffc0207010 <commands+0x8a0>
default_alloc_pages(size_t n) {
ffffffffc02018a4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02018a6:	bdffe0ef          	jal	ra,ffffffffc0200484 <__panic>

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
ffffffffc02018ec:	000ab697          	auipc	a3,0xab
ffffffffc02018f0:	c6c68693          	addi	a3,a3,-916 # ffffffffc02ac558 <free_area>
ffffffffc02018f4:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02018f6:	669c                	ld	a5,8(a3)
ffffffffc02018f8:	9db9                	addw	a1,a1,a4
ffffffffc02018fa:	000ab717          	auipc	a4,0xab
ffffffffc02018fe:	c6b72723          	sw	a1,-914(a4) # ffffffffc02ac568 <free_area+0x10>
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
ffffffffc020192a:	000ab717          	auipc	a4,0xab
ffffffffc020192e:	c2b73723          	sd	a1,-978(a4) # ffffffffc02ac558 <free_area>
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
ffffffffc0201970:	00006697          	auipc	a3,0x6
ffffffffc0201974:	a1068693          	addi	a3,a3,-1520 # ffffffffc0207380 <commands+0xc10>
ffffffffc0201978:	00005617          	auipc	a2,0x5
ffffffffc020197c:	2d060613          	addi	a2,a2,720 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201980:	04900593          	li	a1,73
ffffffffc0201984:	00005517          	auipc	a0,0x5
ffffffffc0201988:	68c50513          	addi	a0,a0,1676 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020198c:	af9fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(n > 0);
ffffffffc0201990:	00006697          	auipc	a3,0x6
ffffffffc0201994:	9e868693          	addi	a3,a3,-1560 # ffffffffc0207378 <commands+0xc08>
ffffffffc0201998:	00005617          	auipc	a2,0x5
ffffffffc020199c:	2b060613          	addi	a2,a2,688 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02019a0:	04600593          	li	a1,70
ffffffffc02019a4:	00005517          	auipc	a0,0x5
ffffffffc02019a8:	66c50513          	addi	a0,a0,1644 # ffffffffc0207010 <commands+0x8a0>
ffffffffc02019ac:	ad9fe0ef          	jal	ra,ffffffffc0200484 <__panic>

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
ffffffffc02019be:	0009f797          	auipc	a5,0x9f
ffffffffc02019c2:	72a78793          	addi	a5,a5,1834 # ffffffffc02a10e8 <slobfree>
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
ffffffffc0201a02:	0009f717          	auipc	a4,0x9f
ffffffffc0201a06:	6ef73323          	sd	a5,1766(a4) # ffffffffc02a10e8 <slobfree>
    if (flag) {
ffffffffc0201a0a:	c199                	beqz	a1,ffffffffc0201a10 <slob_free+0x60>
        intr_enable();
ffffffffc0201a0c:	c49fe06f          	j	ffffffffc0200654 <intr_enable>
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
ffffffffc0201a28:	c33fe0ef          	jal	ra,ffffffffc020065a <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a2c:	0009f797          	auipc	a5,0x9f
ffffffffc0201a30:	6bc78793          	addi	a5,a5,1724 # ffffffffc02a10e8 <slobfree>
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
ffffffffc0201a74:	0009f717          	auipc	a4,0x9f
ffffffffc0201a78:	66f73a23          	sd	a5,1652(a4) # ffffffffc02a10e8 <slobfree>
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
ffffffffc0201aaa:	babfe06f          	j	ffffffffc0200654 <intr_enable>
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
ffffffffc0201ad6:	000ab797          	auipc	a5,0xab
ffffffffc0201ada:	ab278793          	addi	a5,a5,-1358 # ffffffffc02ac588 <pages>
ffffffffc0201ade:	6394                	ld	a3,0(a5)
ffffffffc0201ae0:	00007797          	auipc	a5,0x7
ffffffffc0201ae4:	26078793          	addi	a5,a5,608 # ffffffffc0208d40 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201ae8:	000ab717          	auipc	a4,0xab
ffffffffc0201aec:	a3070713          	addi	a4,a4,-1488 # ffffffffc02ac518 <npage>
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
ffffffffc0201b08:	000ab797          	auipc	a5,0xab
ffffffffc0201b0c:	a7078793          	addi	a5,a5,-1424 # ffffffffc02ac578 <va_pa_offset>
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
ffffffffc0201b26:	8be60613          	addi	a2,a2,-1858 # ffffffffc02073e0 <default_pmm_manager+0x50>
ffffffffc0201b2a:	06900593          	li	a1,105
ffffffffc0201b2e:	00006517          	auipc	a0,0x6
ffffffffc0201b32:	8da50513          	addi	a0,a0,-1830 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc0201b36:	94ffe0ef          	jal	ra,ffffffffc0200484 <__panic>

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
ffffffffc0201b5c:	0009f497          	auipc	s1,0x9f
ffffffffc0201b60:	58c48493          	addi	s1,s1,1420 # ffffffffc02a10e8 <slobfree>
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
ffffffffc0201bba:	0009f717          	auipc	a4,0x9f
ffffffffc0201bbe:	52f73723          	sd	a5,1326(a4) # ffffffffc02a10e8 <slobfree>
    if (flag) {
ffffffffc0201bc2:	ee15                	bnez	a2,ffffffffc0201bfe <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc0201bc4:	70a2                	ld	ra,40(sp)
ffffffffc0201bc6:	7402                	ld	s0,32(sp)
ffffffffc0201bc8:	64e2                	ld	s1,24(sp)
ffffffffc0201bca:	6145                	addi	sp,sp,48
ffffffffc0201bcc:	8082                	ret
        intr_disable();
ffffffffc0201bce:	a8dfe0ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc0201bd2:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0201bd4:	609c                	ld	a5,0(s1)
ffffffffc0201bd6:	b7d9                	j	ffffffffc0201b9c <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc0201bd8:	a7dfe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
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
ffffffffc0201bf4:	0009f717          	auipc	a4,0x9f
ffffffffc0201bf8:	4ef73a23          	sd	a5,1268(a4) # ffffffffc02a10e8 <slobfree>
    if (flag) {
ffffffffc0201bfc:	d661                	beqz	a2,ffffffffc0201bc4 <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc0201bfe:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201c00:	a55fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
}
ffffffffc0201c04:	70a2                	ld	ra,40(sp)
ffffffffc0201c06:	7402                	ld	s0,32(sp)
ffffffffc0201c08:	6522                	ld	a0,8(sp)
ffffffffc0201c0a:	64e2                	ld	s1,24(sp)
ffffffffc0201c0c:	6145                	addi	sp,sp,48
ffffffffc0201c0e:	8082                	ret
        intr_disable();
ffffffffc0201c10:	a4bfe0ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc0201c14:	4605                	li	a2,1
ffffffffc0201c16:	b799                	j	ffffffffc0201b5c <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201c18:	853e                	mv	a0,a5
ffffffffc0201c1a:	87b6                	mv	a5,a3
ffffffffc0201c1c:	b761                	j	ffffffffc0201ba4 <slob_alloc.isra.1.constprop.3+0x6a>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201c1e:	00006697          	auipc	a3,0x6
ffffffffc0201c22:	86268693          	addi	a3,a3,-1950 # ffffffffc0207480 <default_pmm_manager+0xf0>
ffffffffc0201c26:	00005617          	auipc	a2,0x5
ffffffffc0201c2a:	02260613          	addi	a2,a2,34 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0201c2e:	06400593          	li	a1,100
ffffffffc0201c32:	00006517          	auipc	a0,0x6
ffffffffc0201c36:	86e50513          	addi	a0,a0,-1938 # ffffffffc02074a0 <default_pmm_manager+0x110>
ffffffffc0201c3a:	84bfe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201c3e <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201c3e:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201c40:	00006517          	auipc	a0,0x6
ffffffffc0201c44:	87850513          	addi	a0,a0,-1928 # ffffffffc02074b8 <default_pmm_manager+0x128>
kmalloc_init(void) {
ffffffffc0201c48:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201c4a:	d44fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201c4e:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c50:	00006517          	auipc	a0,0x6
ffffffffc0201c54:	81050513          	addi	a0,a0,-2032 # ffffffffc0207460 <default_pmm_manager+0xd0>
}
ffffffffc0201c58:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c5a:	d34fe06f          	j	ffffffffc020018e <cprintf>

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
ffffffffc0201c6e:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8589>
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
ffffffffc0201caa:	000ab797          	auipc	a5,0xab
ffffffffc0201cae:	85e78793          	addi	a5,a5,-1954 # ffffffffc02ac508 <bigblocks>
ffffffffc0201cb2:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201cb4:	000ab717          	auipc	a4,0xab
ffffffffc0201cb8:	84973a23          	sd	s1,-1964(a4) # ffffffffc02ac508 <bigblocks>
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
ffffffffc0201ce8:	973fe0ef          	jal	ra,ffffffffc020065a <intr_disable>
		bb->next = bigblocks;
ffffffffc0201cec:	000ab797          	auipc	a5,0xab
ffffffffc0201cf0:	81c78793          	addi	a5,a5,-2020 # ffffffffc02ac508 <bigblocks>
ffffffffc0201cf4:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201cf6:	000ab717          	auipc	a4,0xab
ffffffffc0201cfa:	80973923          	sd	s1,-2030(a4) # ffffffffc02ac508 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201cfe:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201d00:	955fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
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
ffffffffc0201d38:	000aa797          	auipc	a5,0xaa
ffffffffc0201d3c:	7d078793          	addi	a5,a5,2000 # ffffffffc02ac508 <bigblocks>
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
ffffffffc0201d80:	000aa797          	auipc	a5,0xaa
ffffffffc0201d84:	7f878793          	addi	a5,a5,2040 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0201d88:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201d8a:	000aa797          	auipc	a5,0xaa
ffffffffc0201d8e:	78e78793          	addi	a5,a5,1934 # ffffffffc02ac518 <npage>
ffffffffc0201d92:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201d94:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201d96:	80b1                	srli	s1,s1,0xc
ffffffffc0201d98:	08f4f963          	bleu	a5,s1,ffffffffc0201e2a <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d9c:	00007797          	auipc	a5,0x7
ffffffffc0201da0:	fa478793          	addi	a5,a5,-92 # ffffffffc0208d40 <nbase>
ffffffffc0201da4:	639c                	ld	a5,0(a5)
ffffffffc0201da6:	000aa697          	auipc	a3,0xaa
ffffffffc0201daa:	7e268693          	addi	a3,a3,2018 # ffffffffc02ac588 <pages>
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
ffffffffc0201dd0:	88bfe0ef          	jal	ra,ffffffffc020065a <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201dd4:	000aa797          	auipc	a5,0xaa
ffffffffc0201dd8:	73478793          	addi	a5,a5,1844 # ffffffffc02ac508 <bigblocks>
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
ffffffffc0201dec:	869fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0201df0:	bf85                	j	ffffffffc0201d60 <kfree+0x42>
				*last = bb->next;
ffffffffc0201df2:	000aa797          	auipc	a5,0xaa
ffffffffc0201df6:	7087bb23          	sd	s0,1814(a5) # ffffffffc02ac508 <bigblocks>
ffffffffc0201dfa:	8436                	mv	s0,a3
ffffffffc0201dfc:	859fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0201e00:	bf9d                	j	ffffffffc0201d76 <kfree+0x58>
ffffffffc0201e02:	8082                	ret
ffffffffc0201e04:	000aa797          	auipc	a5,0xaa
ffffffffc0201e08:	7087b223          	sd	s0,1796(a5) # ffffffffc02ac508 <bigblocks>
ffffffffc0201e0c:	8436                	mv	s0,a3
ffffffffc0201e0e:	b7a5                	j	ffffffffc0201d76 <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0201e10:	86a6                	mv	a3,s1
ffffffffc0201e12:	00005617          	auipc	a2,0x5
ffffffffc0201e16:	60660613          	addi	a2,a2,1542 # ffffffffc0207418 <default_pmm_manager+0x88>
ffffffffc0201e1a:	06e00593          	li	a1,110
ffffffffc0201e1e:	00005517          	auipc	a0,0x5
ffffffffc0201e22:	5ea50513          	addi	a0,a0,1514 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc0201e26:	e5efe0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201e2a:	00005617          	auipc	a2,0x5
ffffffffc0201e2e:	61660613          	addi	a2,a2,1558 # ffffffffc0207440 <default_pmm_manager+0xb0>
ffffffffc0201e32:	06200593          	li	a1,98
ffffffffc0201e36:	00005517          	auipc	a0,0x5
ffffffffc0201e3a:	5d250513          	addi	a0,a0,1490 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc0201e3e:	e46fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201e42 <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0201e42:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201e44:	00005617          	auipc	a2,0x5
ffffffffc0201e48:	5fc60613          	addi	a2,a2,1532 # ffffffffc0207440 <default_pmm_manager+0xb0>
ffffffffc0201e4c:	06200593          	li	a1,98
ffffffffc0201e50:	00005517          	auipc	a0,0x5
ffffffffc0201e54:	5b850513          	addi	a0,a0,1464 # ffffffffc0207408 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201e58:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201e5a:	e2afe0ef          	jal	ra,ffffffffc0200484 <__panic>

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
ffffffffc0201e70:	000aa497          	auipc	s1,0xaa
ffffffffc0201e74:	70048493          	addi	s1,s1,1792 # ffffffffc02ac570 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e78:	4985                	li	s3,1
ffffffffc0201e7a:	000aaa17          	auipc	s4,0xaa
ffffffffc0201e7e:	6aea0a13          	addi	s4,s4,1710 # ffffffffc02ac528 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e82:	0005091b          	sext.w	s2,a0
ffffffffc0201e86:	000aaa97          	auipc	s5,0xaa
ffffffffc0201e8a:	7e2a8a93          	addi	s5,s5,2018 # ffffffffc02ac668 <check_mm_struct>
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
ffffffffc0201eba:	fa0fe0ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc0201ebe:	609c                	ld	a5,0(s1)
ffffffffc0201ec0:	8522                	mv	a0,s0
ffffffffc0201ec2:	6f9c                	ld	a5,24(a5)
ffffffffc0201ec4:	9782                	jalr	a5
ffffffffc0201ec6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201ec8:	f8cfe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
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
ffffffffc0201eee:	000aa797          	auipc	a5,0xaa
ffffffffc0201ef2:	68278793          	addi	a5,a5,1666 # ffffffffc02ac570 <pmm_manager>
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
ffffffffc0201f0a:	f50fe0ef          	jal	ra,ffffffffc020065a <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201f0e:	000aa797          	auipc	a5,0xaa
ffffffffc0201f12:	66278793          	addi	a5,a5,1634 # ffffffffc02ac570 <pmm_manager>
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
ffffffffc0201f28:	f2cfe06f          	j	ffffffffc0200654 <intr_enable>

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
ffffffffc0201f34:	000aa797          	auipc	a5,0xaa
ffffffffc0201f38:	63c78793          	addi	a5,a5,1596 # ffffffffc02ac570 <pmm_manager>
ffffffffc0201f3c:	639c                	ld	a5,0(a5)
ffffffffc0201f3e:	0287b303          	ld	t1,40(a5)
ffffffffc0201f42:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201f44:	1141                	addi	sp,sp,-16
ffffffffc0201f46:	e406                	sd	ra,8(sp)
ffffffffc0201f48:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201f4a:	f10fe0ef          	jal	ra,ffffffffc020065a <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f4e:	000aa797          	auipc	a5,0xaa
ffffffffc0201f52:	62278793          	addi	a5,a5,1570 # ffffffffc02ac570 <pmm_manager>
ffffffffc0201f56:	639c                	ld	a5,0(a5)
ffffffffc0201f58:	779c                	ld	a5,40(a5)
ffffffffc0201f5a:	9782                	jalr	a5
ffffffffc0201f5c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201f5e:	ef6fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
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
ffffffffc0201f94:	000aa997          	auipc	s3,0xaa
ffffffffc0201f98:	58498993          	addi	s3,s3,1412 # ffffffffc02ac518 <npage>
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
ffffffffc0201fae:	000aab17          	auipc	s6,0xaa
ffffffffc0201fb2:	5dab0b13          	addi	s6,s6,1498 # ffffffffc02ac588 <pages>
ffffffffc0201fb6:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0201fba:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201fbc:	000aa997          	auipc	s3,0xaa
ffffffffc0201fc0:	55c98993          	addi	s3,s3,1372 # ffffffffc02ac518 <npage>
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
ffffffffc0201fe2:	000aa797          	auipc	a5,0xaa
ffffffffc0201fe6:	59678793          	addi	a5,a5,1430 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0201fea:	639c                	ld	a5,0(a5)
ffffffffc0201fec:	6605                	lui	a2,0x1
ffffffffc0201fee:	4581                	li	a1,0
ffffffffc0201ff0:	953e                	add	a0,a0,a5
ffffffffc0201ff2:	622040ef          	jal	ra,ffffffffc0206614 <memset>
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
ffffffffc020201c:	000aaa97          	auipc	s5,0xaa
ffffffffc0202020:	55ca8a93          	addi	s5,s5,1372 # ffffffffc02ac578 <va_pa_offset>
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
ffffffffc020204e:	000aab17          	auipc	s6,0xaa
ffffffffc0202052:	53ab0b13          	addi	s6,s6,1338 # ffffffffc02ac588 <pages>
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
ffffffffc0202084:	590040ef          	jal	ra,ffffffffc0206614 <memset>
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
ffffffffc02020da:	00005617          	auipc	a2,0x5
ffffffffc02020de:	30660613          	addi	a2,a2,774 # ffffffffc02073e0 <default_pmm_manager+0x50>
ffffffffc02020e2:	0e300593          	li	a1,227
ffffffffc02020e6:	00005517          	auipc	a0,0x5
ffffffffc02020ea:	41a50513          	addi	a0,a0,1050 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc02020ee:	b96fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02020f2:	00005617          	auipc	a2,0x5
ffffffffc02020f6:	2ee60613          	addi	a2,a2,750 # ffffffffc02073e0 <default_pmm_manager+0x50>
ffffffffc02020fa:	0ee00593          	li	a1,238
ffffffffc02020fe:	00005517          	auipc	a0,0x5
ffffffffc0202102:	40250513          	addi	a0,a0,1026 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202106:	b7efe0ef          	jal	ra,ffffffffc0200484 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020210a:	86aa                	mv	a3,a0
ffffffffc020210c:	00005617          	auipc	a2,0x5
ffffffffc0202110:	2d460613          	addi	a2,a2,724 # ffffffffc02073e0 <default_pmm_manager+0x50>
ffffffffc0202114:	0eb00593          	li	a1,235
ffffffffc0202118:	00005517          	auipc	a0,0x5
ffffffffc020211c:	3e850513          	addi	a0,a0,1000 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202120:	b64fe0ef          	jal	ra,ffffffffc0200484 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202124:	86aa                	mv	a3,a0
ffffffffc0202126:	00005617          	auipc	a2,0x5
ffffffffc020212a:	2ba60613          	addi	a2,a2,698 # ffffffffc02073e0 <default_pmm_manager+0x50>
ffffffffc020212e:	0df00593          	li	a1,223
ffffffffc0202132:	00005517          	auipc	a0,0x5
ffffffffc0202136:	3ce50513          	addi	a0,a0,974 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc020213a:	b4afe0ef          	jal	ra,ffffffffc0200484 <__panic>

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
ffffffffc0202164:	000aa717          	auipc	a4,0xaa
ffffffffc0202168:	3b470713          	addi	a4,a4,948 # ffffffffc02ac518 <npage>
ffffffffc020216c:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc020216e:	078a                	slli	a5,a5,0x2
ffffffffc0202170:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202172:	02e7f563          	bleu	a4,a5,ffffffffc020219c <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202176:	000aa717          	auipc	a4,0xaa
ffffffffc020217a:	41270713          	addi	a4,a4,1042 # ffffffffc02ac588 <pages>
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
ffffffffc02021de:	000aac97          	auipc	s9,0xaa
ffffffffc02021e2:	33ac8c93          	addi	s9,s9,826 # ffffffffc02ac518 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02021e6:	000aac17          	auipc	s8,0xaa
ffffffffc02021ea:	3a2c0c13          	addi	s8,s8,930 # ffffffffc02ac588 <pages>
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
ffffffffc0202278:	83468693          	addi	a3,a3,-1996 # ffffffffc0207aa8 <default_pmm_manager+0x718>
ffffffffc020227c:	00005617          	auipc	a2,0x5
ffffffffc0202280:	9cc60613          	addi	a2,a2,-1588 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202284:	11000593          	li	a1,272
ffffffffc0202288:	00005517          	auipc	a0,0x5
ffffffffc020228c:	27850513          	addi	a0,a0,632 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202290:	9f4fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202294:	00005697          	auipc	a3,0x5
ffffffffc0202298:	7e468693          	addi	a3,a3,2020 # ffffffffc0207a78 <default_pmm_manager+0x6e8>
ffffffffc020229c:	00005617          	auipc	a2,0x5
ffffffffc02022a0:	9ac60613          	addi	a2,a2,-1620 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02022a4:	10f00593          	li	a1,271
ffffffffc02022a8:	00005517          	auipc	a0,0x5
ffffffffc02022ac:	25850513          	addi	a0,a0,600 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc02022b0:	9d4fe0ef          	jal	ra,ffffffffc0200484 <__panic>
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
ffffffffc020232a:	000aad17          	auipc	s10,0xaa
ffffffffc020232e:	1eed0d13          	addi	s10,s10,494 # ffffffffc02ac518 <npage>
    return KADDR(page2pa(page));
ffffffffc0202332:	00cddd93          	srli	s11,s11,0xc
ffffffffc0202336:	000aa717          	auipc	a4,0xaa
ffffffffc020233a:	24270713          	addi	a4,a4,578 # ffffffffc02ac578 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc020233e:	000aae97          	auipc	t4,0xaa
ffffffffc0202342:	24ae8e93          	addi	t4,t4,586 # ffffffffc02ac588 <pages>
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
ffffffffc0202420:	000aae97          	auipc	t4,0xaa
ffffffffc0202424:	168e8e93          	addi	t4,t4,360 # ffffffffc02ac588 <pages>
ffffffffc0202428:	6e02                	ld	t3,0(sp)
ffffffffc020242a:	c0000337          	lui	t1,0xc0000
ffffffffc020242e:	fff808b7          	lui	a7,0xfff80
ffffffffc0202432:	00080837          	lui	a6,0x80
ffffffffc0202436:	000aa717          	auipc	a4,0xaa
ffffffffc020243a:	14270713          	addi	a4,a4,322 # ffffffffc02ac578 <va_pa_offset>
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
ffffffffc0202460:	000aa717          	auipc	a4,0xaa
ffffffffc0202464:	11870713          	addi	a4,a4,280 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0202468:	c0000337          	lui	t1,0xc0000
ffffffffc020246c:	6e02                	ld	t3,0(sp)
ffffffffc020246e:	000aae97          	auipc	t4,0xaa
ffffffffc0202472:	11ae8e93          	addi	t4,t4,282 # ffffffffc02ac588 <pages>
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
ffffffffc020249e:	00005697          	auipc	a3,0x5
ffffffffc02024a2:	5da68693          	addi	a3,a3,1498 # ffffffffc0207a78 <default_pmm_manager+0x6e8>
ffffffffc02024a6:	00004617          	auipc	a2,0x4
ffffffffc02024aa:	7a260613          	addi	a2,a2,1954 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02024ae:	12000593          	li	a1,288
ffffffffc02024b2:	00005517          	auipc	a0,0x5
ffffffffc02024b6:	04e50513          	addi	a0,a0,78 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc02024ba:	fcbfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc02024be:	00005617          	auipc	a2,0x5
ffffffffc02024c2:	f2260613          	addi	a2,a2,-222 # ffffffffc02073e0 <default_pmm_manager+0x50>
ffffffffc02024c6:	06900593          	li	a1,105
ffffffffc02024ca:	00005517          	auipc	a0,0x5
ffffffffc02024ce:	f3e50513          	addi	a0,a0,-194 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc02024d2:	fb3fd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02024d6:	00005617          	auipc	a2,0x5
ffffffffc02024da:	f6a60613          	addi	a2,a2,-150 # ffffffffc0207440 <default_pmm_manager+0xb0>
ffffffffc02024de:	06200593          	li	a1,98
ffffffffc02024e2:	00005517          	auipc	a0,0x5
ffffffffc02024e6:	f2650513          	addi	a0,a0,-218 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc02024ea:	f9bfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02024ee:	00005697          	auipc	a3,0x5
ffffffffc02024f2:	5ba68693          	addi	a3,a3,1466 # ffffffffc0207aa8 <default_pmm_manager+0x718>
ffffffffc02024f6:	00004617          	auipc	a2,0x4
ffffffffc02024fa:	75260613          	addi	a2,a2,1874 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02024fe:	12100593          	li	a1,289
ffffffffc0202502:	00005517          	auipc	a0,0x5
ffffffffc0202506:	ffe50513          	addi	a0,a0,-2 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc020250a:	f7bfd0ef          	jal	ra,ffffffffc0200484 <__panic>

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
ffffffffc0202534:	000aa717          	auipc	a4,0xaa
ffffffffc0202538:	fe470713          	addi	a4,a4,-28 # ffffffffc02ac518 <npage>
ffffffffc020253c:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc020253e:	078a                	slli	a5,a5,0x2
ffffffffc0202540:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202542:	02e7fe63          	bleu	a4,a5,ffffffffc020257e <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0202546:	000aa717          	auipc	a4,0xaa
ffffffffc020254a:	04270713          	addi	a4,a4,66 # ffffffffc02ac588 <pages>
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
ffffffffc02025b2:	000aa797          	auipc	a5,0xaa
ffffffffc02025b6:	fd678793          	addi	a5,a5,-42 # ffffffffc02ac588 <pages>
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
ffffffffc02025e8:	000aa717          	auipc	a4,0xaa
ffffffffc02025ec:	f3070713          	addi	a4,a4,-208 # ffffffffc02ac518 <npage>
ffffffffc02025f0:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02025f2:	078a                	slli	a5,a5,0x2
ffffffffc02025f4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02025f6:	04e7f363          	bleu	a4,a5,ffffffffc020263c <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc02025fa:	000aaa17          	auipc	s4,0xaa
ffffffffc02025fe:	f8ea0a13          	addi	s4,s4,-114 # ffffffffc02ac588 <pages>
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
ffffffffc0202640:	00005797          	auipc	a5,0x5
ffffffffc0202644:	d5078793          	addi	a5,a5,-688 # ffffffffc0207390 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202648:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc020264a:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020264c:	00005517          	auipc	a0,0x5
ffffffffc0202650:	edc50513          	addi	a0,a0,-292 # ffffffffc0207528 <default_pmm_manager+0x198>
void pmm_init(void) {
ffffffffc0202654:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202656:	000aa717          	auipc	a4,0xaa
ffffffffc020265a:	f0f73d23          	sd	a5,-230(a4) # ffffffffc02ac570 <pmm_manager>
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
ffffffffc0202670:	000aa417          	auipc	s0,0xaa
ffffffffc0202674:	f0040413          	addi	s0,s0,-256 # ffffffffc02ac570 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202678:	b17fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    pmm_manager->init();
ffffffffc020267c:	601c                	ld	a5,0(s0)
ffffffffc020267e:	000aa497          	auipc	s1,0xaa
ffffffffc0202682:	e9a48493          	addi	s1,s1,-358 # ffffffffc02ac518 <npage>
ffffffffc0202686:	000aa917          	auipc	s2,0xaa
ffffffffc020268a:	f0290913          	addi	s2,s2,-254 # ffffffffc02ac588 <pages>
ffffffffc020268e:	679c                	ld	a5,8(a5)
ffffffffc0202690:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202692:	57f5                	li	a5,-3
ffffffffc0202694:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0202696:	00005517          	auipc	a0,0x5
ffffffffc020269a:	eaa50513          	addi	a0,a0,-342 # ffffffffc0207540 <default_pmm_manager+0x1b0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020269e:	000aa717          	auipc	a4,0xaa
ffffffffc02026a2:	ecf73d23          	sd	a5,-294(a4) # ffffffffc02ac578 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02026a6:	ae9fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02026aa:	46c5                	li	a3,17
ffffffffc02026ac:	06ee                	slli	a3,a3,0x1b
ffffffffc02026ae:	40100613          	li	a2,1025
ffffffffc02026b2:	16fd                	addi	a3,a3,-1
ffffffffc02026b4:	0656                	slli	a2,a2,0x15
ffffffffc02026b6:	07e005b7          	lui	a1,0x7e00
ffffffffc02026ba:	00005517          	auipc	a0,0x5
ffffffffc02026be:	e9e50513          	addi	a0,a0,-354 # ffffffffc0207558 <default_pmm_manager+0x1c8>
ffffffffc02026c2:	acdfd0ef          	jal	ra,ffffffffc020018e <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026c6:	777d                	lui	a4,0xfffff
ffffffffc02026c8:	000ab797          	auipc	a5,0xab
ffffffffc02026cc:	fb778793          	addi	a5,a5,-73 # ffffffffc02ad67f <end+0xfff>
ffffffffc02026d0:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02026d2:	00088737          	lui	a4,0x88
ffffffffc02026d6:	000aa697          	auipc	a3,0xaa
ffffffffc02026da:	e4e6b123          	sd	a4,-446(a3) # ffffffffc02ac518 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026de:	000aa717          	auipc	a4,0xaa
ffffffffc02026e2:	eaf73523          	sd	a5,-342(a4) # ffffffffc02ac588 <pages>
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
ffffffffc0202724:	000aa997          	auipc	s3,0xaa
ffffffffc0202728:	e5498993          	addi	s3,s3,-428 # ffffffffc02ac578 <va_pa_offset>
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
ffffffffc0202764:	00005517          	auipc	a0,0x5
ffffffffc0202768:	e1c50513          	addi	a0,a0,-484 # ffffffffc0207580 <default_pmm_manager+0x1f0>
ffffffffc020276c:	a23fd0ef          	jal	ra,ffffffffc020018e <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202770:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202772:	000aa417          	auipc	s0,0xaa
ffffffffc0202776:	d9e40413          	addi	s0,s0,-610 # ffffffffc02ac510 <boot_pgdir>
    pmm_manager->check();
ffffffffc020277a:	7b9c                	ld	a5,48(a5)
ffffffffc020277c:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020277e:	00005517          	auipc	a0,0x5
ffffffffc0202782:	e1a50513          	addi	a0,a0,-486 # ffffffffc0207598 <default_pmm_manager+0x208>
ffffffffc0202786:	a09fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020278a:	00009697          	auipc	a3,0x9
ffffffffc020278e:	87668693          	addi	a3,a3,-1930 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0202792:	000aa797          	auipc	a5,0xaa
ffffffffc0202796:	d6d7bf23          	sd	a3,-642(a5) # ffffffffc02ac510 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020279a:	c02007b7          	lui	a5,0xc0200
ffffffffc020279e:	10f6eae3          	bltu	a3,a5,ffffffffc02030b2 <pmm_init+0xa72>
ffffffffc02027a2:	0009b783          	ld	a5,0(s3)
ffffffffc02027a6:	8e9d                	sub	a3,a3,a5
ffffffffc02027a8:	000aa797          	auipc	a5,0xaa
ffffffffc02027ac:	dcd7bc23          	sd	a3,-552(a5) # ffffffffc02ac580 <boot_cr3>
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
ffffffffc020282c:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
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
ffffffffc020284e:	0007bb03          	ld	s6,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
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
ffffffffc02028b0:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_exit_out_size+0x1f5578>
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
ffffffffc02029d4:	00005517          	auipc	a0,0x5
ffffffffc02029d8:	ed450513          	addi	a0,a0,-300 # ffffffffc02078a8 <default_pmm_manager+0x518>
ffffffffc02029dc:	fb2fd0ef          	jal	ra,ffffffffc020018e <cprintf>
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
ffffffffc0202a68:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x8478>
ffffffffc0202a6c:	85d6                	mv	a1,s5
ffffffffc0202a6e:	b15ff0ef          	jal	ra,ffffffffc0202582 <page_insert>
ffffffffc0202a72:	40051763          	bnez	a0,ffffffffc0202e80 <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc0202a76:	000aa703          	lw	a4,0(s5)
ffffffffc0202a7a:	4789                	li	a5,2
ffffffffc0202a7c:	3ef71263          	bne	a4,a5,ffffffffc0202e60 <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202a80:	00005597          	auipc	a1,0x5
ffffffffc0202a84:	f6058593          	addi	a1,a1,-160 # ffffffffc02079e0 <default_pmm_manager+0x650>
ffffffffc0202a88:	10000513          	li	a0,256
ffffffffc0202a8c:	32f030ef          	jal	ra,ffffffffc02065ba <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202a90:	100b0593          	addi	a1,s6,256
ffffffffc0202a94:	10000513          	li	a0,256
ffffffffc0202a98:	335030ef          	jal	ra,ffffffffc02065cc <strcmp>
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
ffffffffc0202acc:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fd52a80>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202ad0:	2a7030ef          	jal	ra,ffffffffc0206576 <strlen>
ffffffffc0202ad4:	54051f63          	bnez	a0,ffffffffc0203032 <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202ad8:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202adc:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ade:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd52980>
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
ffffffffc0202b54:	00005517          	auipc	a0,0x5
ffffffffc0202b58:	f0450513          	addi	a0,a0,-252 # ffffffffc0207a58 <default_pmm_manager+0x6c8>
ffffffffc0202b5c:	e32fd0ef          	jal	ra,ffffffffc020018e <cprintf>
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
ffffffffc0202b7e:	00005697          	auipc	a3,0x5
ffffffffc0202b82:	d4a68693          	addi	a3,a3,-694 # ffffffffc02078c8 <default_pmm_manager+0x538>
ffffffffc0202b86:	00004617          	auipc	a2,0x4
ffffffffc0202b8a:	0c260613          	addi	a2,a2,194 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202b8e:	22600593          	li	a1,550
ffffffffc0202b92:	00005517          	auipc	a0,0x5
ffffffffc0202b96:	96e50513          	addi	a0,a0,-1682 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202b9a:	8ebfd0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0202b9e:	86d6                	mv	a3,s5
ffffffffc0202ba0:	00005617          	auipc	a2,0x5
ffffffffc0202ba4:	84060613          	addi	a2,a2,-1984 # ffffffffc02073e0 <default_pmm_manager+0x50>
ffffffffc0202ba8:	22600593          	li	a1,550
ffffffffc0202bac:	00005517          	auipc	a0,0x5
ffffffffc0202bb0:	95450513          	addi	a0,a0,-1708 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202bb4:	8d1fd0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202bb8:	00005697          	auipc	a3,0x5
ffffffffc0202bbc:	d5068693          	addi	a3,a3,-688 # ffffffffc0207908 <default_pmm_manager+0x578>
ffffffffc0202bc0:	00004617          	auipc	a2,0x4
ffffffffc0202bc4:	08860613          	addi	a2,a2,136 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202bc8:	22700593          	li	a1,551
ffffffffc0202bcc:	00005517          	auipc	a0,0x5
ffffffffc0202bd0:	93450513          	addi	a0,a0,-1740 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202bd4:	8b1fd0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0202bd8:	a6aff0ef          	jal	ra,ffffffffc0201e42 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0202bdc:	00005617          	auipc	a2,0x5
ffffffffc0202be0:	80460613          	addi	a2,a2,-2044 # ffffffffc02073e0 <default_pmm_manager+0x50>
ffffffffc0202be4:	06900593          	li	a1,105
ffffffffc0202be8:	00005517          	auipc	a0,0x5
ffffffffc0202bec:	82050513          	addi	a0,a0,-2016 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc0202bf0:	895fd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202bf4:	00005617          	auipc	a2,0x5
ffffffffc0202bf8:	aa460613          	addi	a2,a2,-1372 # ffffffffc0207698 <default_pmm_manager+0x308>
ffffffffc0202bfc:	07400593          	li	a1,116
ffffffffc0202c00:	00005517          	auipc	a0,0x5
ffffffffc0202c04:	80850513          	addi	a0,a0,-2040 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc0202c08:	87dfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202c0c:	00005697          	auipc	a3,0x5
ffffffffc0202c10:	9cc68693          	addi	a3,a3,-1588 # ffffffffc02075d8 <default_pmm_manager+0x248>
ffffffffc0202c14:	00004617          	auipc	a2,0x4
ffffffffc0202c18:	03460613          	addi	a2,a2,52 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202c1c:	1ea00593          	li	a1,490
ffffffffc0202c20:	00005517          	auipc	a0,0x5
ffffffffc0202c24:	8e050513          	addi	a0,a0,-1824 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202c28:	85dfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202c2c:	00005697          	auipc	a3,0x5
ffffffffc0202c30:	a9468693          	addi	a3,a3,-1388 # ffffffffc02076c0 <default_pmm_manager+0x330>
ffffffffc0202c34:	00004617          	auipc	a2,0x4
ffffffffc0202c38:	01460613          	addi	a2,a2,20 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202c3c:	20600593          	li	a1,518
ffffffffc0202c40:	00005517          	auipc	a0,0x5
ffffffffc0202c44:	8c050513          	addi	a0,a0,-1856 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202c48:	83dfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202c4c:	00005697          	auipc	a3,0x5
ffffffffc0202c50:	cec68693          	addi	a3,a3,-788 # ffffffffc0207938 <default_pmm_manager+0x5a8>
ffffffffc0202c54:	00004617          	auipc	a2,0x4
ffffffffc0202c58:	ff460613          	addi	a2,a2,-12 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202c5c:	22f00593          	li	a1,559
ffffffffc0202c60:	00005517          	auipc	a0,0x5
ffffffffc0202c64:	8a050513          	addi	a0,a0,-1888 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202c68:	81dfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202c6c:	00005697          	auipc	a3,0x5
ffffffffc0202c70:	ae468693          	addi	a3,a3,-1308 # ffffffffc0207750 <default_pmm_manager+0x3c0>
ffffffffc0202c74:	00004617          	auipc	a2,0x4
ffffffffc0202c78:	fd460613          	addi	a2,a2,-44 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202c7c:	20500593          	li	a1,517
ffffffffc0202c80:	00005517          	auipc	a0,0x5
ffffffffc0202c84:	88050513          	addi	a0,a0,-1920 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202c88:	ffcfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202c8c:	00005697          	auipc	a3,0x5
ffffffffc0202c90:	b8c68693          	addi	a3,a3,-1140 # ffffffffc0207818 <default_pmm_manager+0x488>
ffffffffc0202c94:	00004617          	auipc	a2,0x4
ffffffffc0202c98:	fb460613          	addi	a2,a2,-76 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202c9c:	20400593          	li	a1,516
ffffffffc0202ca0:	00005517          	auipc	a0,0x5
ffffffffc0202ca4:	86050513          	addi	a0,a0,-1952 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202ca8:	fdcfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202cac:	00005697          	auipc	a3,0x5
ffffffffc0202cb0:	b5468693          	addi	a3,a3,-1196 # ffffffffc0207800 <default_pmm_manager+0x470>
ffffffffc0202cb4:	00004617          	auipc	a2,0x4
ffffffffc0202cb8:	f9460613          	addi	a2,a2,-108 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202cbc:	20300593          	li	a1,515
ffffffffc0202cc0:	00005517          	auipc	a0,0x5
ffffffffc0202cc4:	84050513          	addi	a0,a0,-1984 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202cc8:	fbcfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202ccc:	00005697          	auipc	a3,0x5
ffffffffc0202cd0:	b0468693          	addi	a3,a3,-1276 # ffffffffc02077d0 <default_pmm_manager+0x440>
ffffffffc0202cd4:	00004617          	auipc	a2,0x4
ffffffffc0202cd8:	f7460613          	addi	a2,a2,-140 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202cdc:	20200593          	li	a1,514
ffffffffc0202ce0:	00005517          	auipc	a0,0x5
ffffffffc0202ce4:	82050513          	addi	a0,a0,-2016 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202ce8:	f9cfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202cec:	00005697          	auipc	a3,0x5
ffffffffc0202cf0:	acc68693          	addi	a3,a3,-1332 # ffffffffc02077b8 <default_pmm_manager+0x428>
ffffffffc0202cf4:	00004617          	auipc	a2,0x4
ffffffffc0202cf8:	f5460613          	addi	a2,a2,-172 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202cfc:	20000593          	li	a1,512
ffffffffc0202d00:	00005517          	auipc	a0,0x5
ffffffffc0202d04:	80050513          	addi	a0,a0,-2048 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202d08:	f7cfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202d0c:	00005697          	auipc	a3,0x5
ffffffffc0202d10:	a9468693          	addi	a3,a3,-1388 # ffffffffc02077a0 <default_pmm_manager+0x410>
ffffffffc0202d14:	00004617          	auipc	a2,0x4
ffffffffc0202d18:	f3460613          	addi	a2,a2,-204 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202d1c:	1ff00593          	li	a1,511
ffffffffc0202d20:	00004517          	auipc	a0,0x4
ffffffffc0202d24:	7e050513          	addi	a0,a0,2016 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202d28:	f5cfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202d2c:	00005697          	auipc	a3,0x5
ffffffffc0202d30:	a6468693          	addi	a3,a3,-1436 # ffffffffc0207790 <default_pmm_manager+0x400>
ffffffffc0202d34:	00004617          	auipc	a2,0x4
ffffffffc0202d38:	f1460613          	addi	a2,a2,-236 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202d3c:	1fe00593          	li	a1,510
ffffffffc0202d40:	00004517          	auipc	a0,0x4
ffffffffc0202d44:	7c050513          	addi	a0,a0,1984 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202d48:	f3cfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202d4c:	00005697          	auipc	a3,0x5
ffffffffc0202d50:	a3468693          	addi	a3,a3,-1484 # ffffffffc0207780 <default_pmm_manager+0x3f0>
ffffffffc0202d54:	00004617          	auipc	a2,0x4
ffffffffc0202d58:	ef460613          	addi	a2,a2,-268 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202d5c:	1fd00593          	li	a1,509
ffffffffc0202d60:	00004517          	auipc	a0,0x4
ffffffffc0202d64:	7a050513          	addi	a0,a0,1952 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202d68:	f1cfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202d6c:	00005697          	auipc	a3,0x5
ffffffffc0202d70:	9e468693          	addi	a3,a3,-1564 # ffffffffc0207750 <default_pmm_manager+0x3c0>
ffffffffc0202d74:	00004617          	auipc	a2,0x4
ffffffffc0202d78:	ed460613          	addi	a2,a2,-300 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202d7c:	1fc00593          	li	a1,508
ffffffffc0202d80:	00004517          	auipc	a0,0x4
ffffffffc0202d84:	78050513          	addi	a0,a0,1920 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202d88:	efcfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202d8c:	00005697          	auipc	a3,0x5
ffffffffc0202d90:	98c68693          	addi	a3,a3,-1652 # ffffffffc0207718 <default_pmm_manager+0x388>
ffffffffc0202d94:	00004617          	auipc	a2,0x4
ffffffffc0202d98:	eb460613          	addi	a2,a2,-332 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202d9c:	1fb00593          	li	a1,507
ffffffffc0202da0:	00004517          	auipc	a0,0x4
ffffffffc0202da4:	76050513          	addi	a0,a0,1888 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202da8:	edcfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202dac:	00005697          	auipc	a3,0x5
ffffffffc0202db0:	94468693          	addi	a3,a3,-1724 # ffffffffc02076f0 <default_pmm_manager+0x360>
ffffffffc0202db4:	00004617          	auipc	a2,0x4
ffffffffc0202db8:	e9460613          	addi	a2,a2,-364 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202dbc:	1f800593          	li	a1,504
ffffffffc0202dc0:	00004517          	auipc	a0,0x4
ffffffffc0202dc4:	74050513          	addi	a0,a0,1856 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202dc8:	ebcfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202dcc:	86da                	mv	a3,s6
ffffffffc0202dce:	00004617          	auipc	a2,0x4
ffffffffc0202dd2:	61260613          	addi	a2,a2,1554 # ffffffffc02073e0 <default_pmm_manager+0x50>
ffffffffc0202dd6:	1f700593          	li	a1,503
ffffffffc0202dda:	00004517          	auipc	a0,0x4
ffffffffc0202dde:	72650513          	addi	a0,a0,1830 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202de2:	ea2fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202de6:	86be                	mv	a3,a5
ffffffffc0202de8:	00004617          	auipc	a2,0x4
ffffffffc0202dec:	5f860613          	addi	a2,a2,1528 # ffffffffc02073e0 <default_pmm_manager+0x50>
ffffffffc0202df0:	06900593          	li	a1,105
ffffffffc0202df4:	00004517          	auipc	a0,0x4
ffffffffc0202df8:	61450513          	addi	a0,a0,1556 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc0202dfc:	e88fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202e00:	00005697          	auipc	a3,0x5
ffffffffc0202e04:	a6068693          	addi	a3,a3,-1440 # ffffffffc0207860 <default_pmm_manager+0x4d0>
ffffffffc0202e08:	00004617          	auipc	a2,0x4
ffffffffc0202e0c:	e4060613          	addi	a2,a2,-448 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202e10:	21100593          	li	a1,529
ffffffffc0202e14:	00004517          	auipc	a0,0x4
ffffffffc0202e18:	6ec50513          	addi	a0,a0,1772 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202e1c:	e68fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202e20:	00005697          	auipc	a3,0x5
ffffffffc0202e24:	9f868693          	addi	a3,a3,-1544 # ffffffffc0207818 <default_pmm_manager+0x488>
ffffffffc0202e28:	00004617          	auipc	a2,0x4
ffffffffc0202e2c:	e2060613          	addi	a2,a2,-480 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202e30:	20f00593          	li	a1,527
ffffffffc0202e34:	00004517          	auipc	a0,0x4
ffffffffc0202e38:	6cc50513          	addi	a0,a0,1740 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202e3c:	e48fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202e40:	00005697          	auipc	a3,0x5
ffffffffc0202e44:	a0868693          	addi	a3,a3,-1528 # ffffffffc0207848 <default_pmm_manager+0x4b8>
ffffffffc0202e48:	00004617          	auipc	a2,0x4
ffffffffc0202e4c:	e0060613          	addi	a2,a2,-512 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202e50:	20e00593          	li	a1,526
ffffffffc0202e54:	00004517          	auipc	a0,0x4
ffffffffc0202e58:	6ac50513          	addi	a0,a0,1708 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202e5c:	e28fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202e60:	00005697          	auipc	a3,0x5
ffffffffc0202e64:	b6868693          	addi	a3,a3,-1176 # ffffffffc02079c8 <default_pmm_manager+0x638>
ffffffffc0202e68:	00004617          	auipc	a2,0x4
ffffffffc0202e6c:	de060613          	addi	a2,a2,-544 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202e70:	23200593          	li	a1,562
ffffffffc0202e74:	00004517          	auipc	a0,0x4
ffffffffc0202e78:	68c50513          	addi	a0,a0,1676 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202e7c:	e08fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202e80:	00005697          	auipc	a3,0x5
ffffffffc0202e84:	b0868693          	addi	a3,a3,-1272 # ffffffffc0207988 <default_pmm_manager+0x5f8>
ffffffffc0202e88:	00004617          	auipc	a2,0x4
ffffffffc0202e8c:	dc060613          	addi	a2,a2,-576 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202e90:	23100593          	li	a1,561
ffffffffc0202e94:	00004517          	auipc	a0,0x4
ffffffffc0202e98:	66c50513          	addi	a0,a0,1644 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202e9c:	de8fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202ea0:	00005697          	auipc	a3,0x5
ffffffffc0202ea4:	ad068693          	addi	a3,a3,-1328 # ffffffffc0207970 <default_pmm_manager+0x5e0>
ffffffffc0202ea8:	00004617          	auipc	a2,0x4
ffffffffc0202eac:	da060613          	addi	a2,a2,-608 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202eb0:	23000593          	li	a1,560
ffffffffc0202eb4:	00004517          	auipc	a0,0x4
ffffffffc0202eb8:	64c50513          	addi	a0,a0,1612 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202ebc:	dc8fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202ec0:	86be                	mv	a3,a5
ffffffffc0202ec2:	00004617          	auipc	a2,0x4
ffffffffc0202ec6:	51e60613          	addi	a2,a2,1310 # ffffffffc02073e0 <default_pmm_manager+0x50>
ffffffffc0202eca:	1f600593          	li	a1,502
ffffffffc0202ece:	00004517          	auipc	a0,0x4
ffffffffc0202ed2:	63250513          	addi	a0,a0,1586 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202ed6:	daefd0ef          	jal	ra,ffffffffc0200484 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202eda:	00004617          	auipc	a2,0x4
ffffffffc0202ede:	53e60613          	addi	a2,a2,1342 # ffffffffc0207418 <default_pmm_manager+0x88>
ffffffffc0202ee2:	07f00593          	li	a1,127
ffffffffc0202ee6:	00004517          	auipc	a0,0x4
ffffffffc0202eea:	61a50513          	addi	a0,a0,1562 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202eee:	d96fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202ef2:	00005697          	auipc	a3,0x5
ffffffffc0202ef6:	b0668693          	addi	a3,a3,-1274 # ffffffffc02079f8 <default_pmm_manager+0x668>
ffffffffc0202efa:	00004617          	auipc	a2,0x4
ffffffffc0202efe:	d4e60613          	addi	a2,a2,-690 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202f02:	23600593          	li	a1,566
ffffffffc0202f06:	00004517          	auipc	a0,0x4
ffffffffc0202f0a:	5fa50513          	addi	a0,a0,1530 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202f0e:	d76fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202f12:	00005697          	auipc	a3,0x5
ffffffffc0202f16:	97668693          	addi	a3,a3,-1674 # ffffffffc0207888 <default_pmm_manager+0x4f8>
ffffffffc0202f1a:	00004617          	auipc	a2,0x4
ffffffffc0202f1e:	d2e60613          	addi	a2,a2,-722 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202f22:	24200593          	li	a1,578
ffffffffc0202f26:	00004517          	auipc	a0,0x4
ffffffffc0202f2a:	5da50513          	addi	a0,a0,1498 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202f2e:	d56fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202f32:	00004697          	auipc	a3,0x4
ffffffffc0202f36:	7a668693          	addi	a3,a3,1958 # ffffffffc02076d8 <default_pmm_manager+0x348>
ffffffffc0202f3a:	00004617          	auipc	a2,0x4
ffffffffc0202f3e:	d0e60613          	addi	a2,a2,-754 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202f42:	1f400593          	li	a1,500
ffffffffc0202f46:	00004517          	auipc	a0,0x4
ffffffffc0202f4a:	5ba50513          	addi	a0,a0,1466 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202f4e:	d36fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202f52:	00004697          	auipc	a3,0x4
ffffffffc0202f56:	76e68693          	addi	a3,a3,1902 # ffffffffc02076c0 <default_pmm_manager+0x330>
ffffffffc0202f5a:	00004617          	auipc	a2,0x4
ffffffffc0202f5e:	cee60613          	addi	a2,a2,-786 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202f62:	1f300593          	li	a1,499
ffffffffc0202f66:	00004517          	auipc	a0,0x4
ffffffffc0202f6a:	59a50513          	addi	a0,a0,1434 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202f6e:	d16fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202f72:	00004697          	auipc	a3,0x4
ffffffffc0202f76:	69e68693          	addi	a3,a3,1694 # ffffffffc0207610 <default_pmm_manager+0x280>
ffffffffc0202f7a:	00004617          	auipc	a2,0x4
ffffffffc0202f7e:	cce60613          	addi	a2,a2,-818 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202f82:	1eb00593          	li	a1,491
ffffffffc0202f86:	00004517          	auipc	a0,0x4
ffffffffc0202f8a:	57a50513          	addi	a0,a0,1402 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202f8e:	cf6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202f92:	00004697          	auipc	a3,0x4
ffffffffc0202f96:	6d668693          	addi	a3,a3,1750 # ffffffffc0207668 <default_pmm_manager+0x2d8>
ffffffffc0202f9a:	00004617          	auipc	a2,0x4
ffffffffc0202f9e:	cae60613          	addi	a2,a2,-850 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202fa2:	1f200593          	li	a1,498
ffffffffc0202fa6:	00004517          	auipc	a0,0x4
ffffffffc0202faa:	55a50513          	addi	a0,a0,1370 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202fae:	cd6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202fb2:	00004697          	auipc	a3,0x4
ffffffffc0202fb6:	68668693          	addi	a3,a3,1670 # ffffffffc0207638 <default_pmm_manager+0x2a8>
ffffffffc0202fba:	00004617          	auipc	a2,0x4
ffffffffc0202fbe:	c8e60613          	addi	a2,a2,-882 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202fc2:	1ef00593          	li	a1,495
ffffffffc0202fc6:	00004517          	auipc	a0,0x4
ffffffffc0202fca:	53a50513          	addi	a0,a0,1338 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202fce:	cb6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202fd2:	00005697          	auipc	a3,0x5
ffffffffc0202fd6:	84668693          	addi	a3,a3,-1978 # ffffffffc0207818 <default_pmm_manager+0x488>
ffffffffc0202fda:	00004617          	auipc	a2,0x4
ffffffffc0202fde:	c6e60613          	addi	a2,a2,-914 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0202fe2:	20b00593          	li	a1,523
ffffffffc0202fe6:	00004517          	auipc	a0,0x4
ffffffffc0202fea:	51a50513          	addi	a0,a0,1306 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0202fee:	c96fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202ff2:	00004697          	auipc	a3,0x4
ffffffffc0202ff6:	6e668693          	addi	a3,a3,1766 # ffffffffc02076d8 <default_pmm_manager+0x348>
ffffffffc0202ffa:	00004617          	auipc	a2,0x4
ffffffffc0202ffe:	c4e60613          	addi	a2,a2,-946 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203002:	20a00593          	li	a1,522
ffffffffc0203006:	00004517          	auipc	a0,0x4
ffffffffc020300a:	4fa50513          	addi	a0,a0,1274 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc020300e:	c76fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203012:	00005697          	auipc	a3,0x5
ffffffffc0203016:	81e68693          	addi	a3,a3,-2018 # ffffffffc0207830 <default_pmm_manager+0x4a0>
ffffffffc020301a:	00004617          	auipc	a2,0x4
ffffffffc020301e:	c2e60613          	addi	a2,a2,-978 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203022:	20700593          	li	a1,519
ffffffffc0203026:	00004517          	auipc	a0,0x4
ffffffffc020302a:	4da50513          	addi	a0,a0,1242 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc020302e:	c56fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203032:	00005697          	auipc	a3,0x5
ffffffffc0203036:	9fe68693          	addi	a3,a3,-1538 # ffffffffc0207a30 <default_pmm_manager+0x6a0>
ffffffffc020303a:	00004617          	auipc	a2,0x4
ffffffffc020303e:	c0e60613          	addi	a2,a2,-1010 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203042:	23900593          	li	a1,569
ffffffffc0203046:	00004517          	auipc	a0,0x4
ffffffffc020304a:	4ba50513          	addi	a0,a0,1210 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc020304e:	c36fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203052:	00005697          	auipc	a3,0x5
ffffffffc0203056:	83668693          	addi	a3,a3,-1994 # ffffffffc0207888 <default_pmm_manager+0x4f8>
ffffffffc020305a:	00004617          	auipc	a2,0x4
ffffffffc020305e:	bee60613          	addi	a2,a2,-1042 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203062:	21900593          	li	a1,537
ffffffffc0203066:	00004517          	auipc	a0,0x4
ffffffffc020306a:	49a50513          	addi	a0,a0,1178 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc020306e:	c16fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203072:	00005697          	auipc	a3,0x5
ffffffffc0203076:	8ae68693          	addi	a3,a3,-1874 # ffffffffc0207920 <default_pmm_manager+0x590>
ffffffffc020307a:	00004617          	auipc	a2,0x4
ffffffffc020307e:	bce60613          	addi	a2,a2,-1074 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203082:	22b00593          	li	a1,555
ffffffffc0203086:	00004517          	auipc	a0,0x4
ffffffffc020308a:	47a50513          	addi	a0,a0,1146 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc020308e:	bf6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203092:	00004697          	auipc	a3,0x4
ffffffffc0203096:	52668693          	addi	a3,a3,1318 # ffffffffc02075b8 <default_pmm_manager+0x228>
ffffffffc020309a:	00004617          	auipc	a2,0x4
ffffffffc020309e:	bae60613          	addi	a2,a2,-1106 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02030a2:	1e900593          	li	a1,489
ffffffffc02030a6:	00004517          	auipc	a0,0x4
ffffffffc02030aa:	45a50513          	addi	a0,a0,1114 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc02030ae:	bd6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02030b2:	00004617          	auipc	a2,0x4
ffffffffc02030b6:	36660613          	addi	a2,a2,870 # ffffffffc0207418 <default_pmm_manager+0x88>
ffffffffc02030ba:	0c100593          	li	a1,193
ffffffffc02030be:	00004517          	auipc	a0,0x4
ffffffffc02030c2:	44250513          	addi	a0,a0,1090 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc02030c6:	bbefd0ef          	jal	ra,ffffffffc0200484 <__panic>

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
ffffffffc0203112:	000a9c17          	auipc	s8,0xa9
ffffffffc0203116:	406c0c13          	addi	s8,s8,1030 # ffffffffc02ac518 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020311a:	000a9b97          	auipc	s7,0xa9
ffffffffc020311e:	46eb8b93          	addi	s7,s7,1134 # ffffffffc02ac588 <pages>
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
ffffffffc02031ca:	000a9717          	auipc	a4,0xa9
ffffffffc02031ce:	3ae70713          	addi	a4,a4,942 # ffffffffc02ac578 <va_pa_offset>
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
ffffffffc02031ea:	43c030ef          	jal	ra,ffffffffc0206626 <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc02031ee:	86e6                	mv	a3,s9
ffffffffc02031f0:	8622                	mv	a2,s0
ffffffffc02031f2:	85ea                	mv	a1,s10
ffffffffc02031f4:	8556                	mv	a0,s5
ffffffffc02031f6:	b8cff0ef          	jal	ra,ffffffffc0202582 <page_insert>
            assert(ret == 0);
ffffffffc02031fa:	d131                	beqz	a0,ffffffffc020313e <copy_range+0x74>
ffffffffc02031fc:	00004697          	auipc	a3,0x4
ffffffffc0203200:	2f468693          	addi	a3,a3,756 # ffffffffc02074f0 <default_pmm_manager+0x160>
ffffffffc0203204:	00004617          	auipc	a2,0x4
ffffffffc0203208:	a4460613          	addi	a2,a2,-1468 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc020320c:	18b00593          	li	a1,395
ffffffffc0203210:	00004517          	auipc	a0,0x4
ffffffffc0203214:	2f050513          	addi	a0,a0,752 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0203218:	a6cfd0ef          	jal	ra,ffffffffc0200484 <__panic>
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
ffffffffc0203236:	00004617          	auipc	a2,0x4
ffffffffc020323a:	1aa60613          	addi	a2,a2,426 # ffffffffc02073e0 <default_pmm_manager+0x50>
ffffffffc020323e:	06900593          	li	a1,105
ffffffffc0203242:	00004517          	auipc	a0,0x4
ffffffffc0203246:	1c650513          	addi	a0,a0,454 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc020324a:	a3afd0ef          	jal	ra,ffffffffc0200484 <__panic>
            assert(page != NULL);
ffffffffc020324e:	00004697          	auipc	a3,0x4
ffffffffc0203252:	28268693          	addi	a3,a3,642 # ffffffffc02074d0 <default_pmm_manager+0x140>
ffffffffc0203256:	00004617          	auipc	a2,0x4
ffffffffc020325a:	9f260613          	addi	a2,a2,-1550 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc020325e:	17200593          	li	a1,370
ffffffffc0203262:	00004517          	auipc	a0,0x4
ffffffffc0203266:	29e50513          	addi	a0,a0,670 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc020326a:	a1afd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020326e:	00005697          	auipc	a3,0x5
ffffffffc0203272:	83a68693          	addi	a3,a3,-1990 # ffffffffc0207aa8 <default_pmm_manager+0x718>
ffffffffc0203276:	00004617          	auipc	a2,0x4
ffffffffc020327a:	9d260613          	addi	a2,a2,-1582 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc020327e:	15e00593          	li	a1,350
ffffffffc0203282:	00004517          	auipc	a0,0x4
ffffffffc0203286:	27e50513          	addi	a0,a0,638 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc020328a:	9fafd0ef          	jal	ra,ffffffffc0200484 <__panic>
            assert(npage != NULL);
ffffffffc020328e:	00004697          	auipc	a3,0x4
ffffffffc0203292:	25268693          	addi	a3,a3,594 # ffffffffc02074e0 <default_pmm_manager+0x150>
ffffffffc0203296:	00004617          	auipc	a2,0x4
ffffffffc020329a:	9b260613          	addi	a2,a2,-1614 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc020329e:	17300593          	li	a1,371
ffffffffc02032a2:	00004517          	auipc	a0,0x4
ffffffffc02032a6:	25e50513          	addi	a0,a0,606 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc02032aa:	9dafd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02032ae:	00004617          	auipc	a2,0x4
ffffffffc02032b2:	19260613          	addi	a2,a2,402 # ffffffffc0207440 <default_pmm_manager+0xb0>
ffffffffc02032b6:	06200593          	li	a1,98
ffffffffc02032ba:	00004517          	auipc	a0,0x4
ffffffffc02032be:	14e50513          	addi	a0,a0,334 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc02032c2:	9c2fd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02032c6:	00004617          	auipc	a2,0x4
ffffffffc02032ca:	3d260613          	addi	a2,a2,978 # ffffffffc0207698 <default_pmm_manager+0x308>
ffffffffc02032ce:	07400593          	li	a1,116
ffffffffc02032d2:	00004517          	auipc	a0,0x4
ffffffffc02032d6:	13650513          	addi	a0,a0,310 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc02032da:	9aafd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02032de:	00004697          	auipc	a3,0x4
ffffffffc02032e2:	79a68693          	addi	a3,a3,1946 # ffffffffc0207a78 <default_pmm_manager+0x6e8>
ffffffffc02032e6:	00004617          	auipc	a2,0x4
ffffffffc02032ea:	96260613          	addi	a2,a2,-1694 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02032ee:	15d00593          	li	a1,349
ffffffffc02032f2:	00004517          	auipc	a0,0x4
ffffffffc02032f6:	20e50513          	addi	a0,a0,526 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc02032fa:	98afd0ef          	jal	ra,ffffffffc0200484 <__panic>

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
ffffffffc020332e:	000a9797          	auipc	a5,0xa9
ffffffffc0203332:	1fa78793          	addi	a5,a5,506 # ffffffffc02ac528 <swap_init_ok>
ffffffffc0203336:	439c                	lw	a5,0(a5)
ffffffffc0203338:	2781                	sext.w	a5,a5
ffffffffc020333a:	c38d                	beqz	a5,ffffffffc020335c <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc020333c:	000a9797          	auipc	a5,0xa9
ffffffffc0203340:	32c78793          	addi	a5,a5,812 # ffffffffc02ac668 <check_mm_struct>
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
ffffffffc0203378:	00004697          	auipc	a3,0x4
ffffffffc020337c:	19868693          	addi	a3,a3,408 # ffffffffc0207510 <default_pmm_manager+0x180>
ffffffffc0203380:	00004617          	auipc	a2,0x4
ffffffffc0203384:	8c860613          	addi	a2,a2,-1848 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203388:	1ca00593          	li	a1,458
ffffffffc020338c:	00004517          	auipc	a0,0x4
ffffffffc0203390:	17450513          	addi	a0,a0,372 # ffffffffc0207500 <default_pmm_manager+0x170>
ffffffffc0203394:	8f0fd0ef          	jal	ra,ffffffffc0200484 <__panic>

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
ffffffffc02033b4:	79c010ef          	jal	ra,ffffffffc0204b50 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02033b8:	000a9797          	auipc	a5,0xa9
ffffffffc02033bc:	26078793          	addi	a5,a5,608 # ffffffffc02ac618 <max_swap_offset>
ffffffffc02033c0:	6394                	ld	a3,0(a5)
ffffffffc02033c2:	010007b7          	lui	a5,0x1000
ffffffffc02033c6:	17e1                	addi	a5,a5,-8
ffffffffc02033c8:	ff968713          	addi	a4,a3,-7
ffffffffc02033cc:	4ae7ee63          	bltu	a5,a4,ffffffffc0203888 <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc02033d0:	0009e797          	auipc	a5,0x9e
ffffffffc02033d4:	cd878793          	addi	a5,a5,-808 # ffffffffc02a10a8 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02033d8:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02033da:	000a9697          	auipc	a3,0xa9
ffffffffc02033de:	14f6b323          	sd	a5,326(a3) # ffffffffc02ac520 <sm>
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
ffffffffc0203408:	000a9797          	auipc	a5,0xa9
ffffffffc020340c:	11878793          	addi	a5,a5,280 # ffffffffc02ac520 <sm>
ffffffffc0203410:	639c                	ld	a5,0(a5)
ffffffffc0203412:	00004517          	auipc	a0,0x4
ffffffffc0203416:	72e50513          	addi	a0,a0,1838 # ffffffffc0207b40 <default_pmm_manager+0x7b0>
    return listelm->next;
ffffffffc020341a:	000a9417          	auipc	s0,0xa9
ffffffffc020341e:	13e40413          	addi	s0,s0,318 # ffffffffc02ac558 <free_area>
ffffffffc0203422:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0203424:	4785                	li	a5,1
ffffffffc0203426:	000a9717          	auipc	a4,0xa9
ffffffffc020342a:	10f72123          	sw	a5,258(a4) # ffffffffc02ac528 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020342e:	d61fc0ef          	jal	ra,ffffffffc020018e <cprintf>
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
ffffffffc0203470:	00004517          	auipc	a0,0x4
ffffffffc0203474:	6e850513          	addi	a0,a0,1768 # ffffffffc0207b58 <default_pmm_manager+0x7c8>
ffffffffc0203478:	d17fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc020347c:	457000ef          	jal	ra,ffffffffc02040d2 <mm_create>
ffffffffc0203480:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0203482:	60050b63          	beqz	a0,ffffffffc0203a98 <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0203486:	000a9797          	auipc	a5,0xa9
ffffffffc020348a:	1e278793          	addi	a5,a5,482 # ffffffffc02ac668 <check_mm_struct>
ffffffffc020348e:	639c                	ld	a5,0(a5)
ffffffffc0203490:	62079463          	bnez	a5,ffffffffc0203ab8 <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203494:	000a9797          	auipc	a5,0xa9
ffffffffc0203498:	07c78793          	addi	a5,a5,124 # ffffffffc02ac510 <boot_pgdir>
ffffffffc020349c:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc02034a0:	000a9797          	auipc	a5,0xa9
ffffffffc02034a4:	1ca7b423          	sd	a0,456(a5) # ffffffffc02ac668 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc02034a8:	000b3783          	ld	a5,0(s6) # 80000 <_binary_obj___user_exit_out_size+0x75578>
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02034ac:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02034b0:	4e079863          	bnez	a5,ffffffffc02039a0 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02034b4:	6599                	lui	a1,0x6
ffffffffc02034b6:	460d                	li	a2,3
ffffffffc02034b8:	6505                	lui	a0,0x1
ffffffffc02034ba:	465000ef          	jal	ra,ffffffffc020411e <vma_create>
ffffffffc02034be:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02034c0:	50050063          	beqz	a0,ffffffffc02039c0 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc02034c4:	855e                	mv	a0,s7
ffffffffc02034c6:	4c5000ef          	jal	ra,ffffffffc020418a <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02034ca:	00004517          	auipc	a0,0x4
ffffffffc02034ce:	6fe50513          	addi	a0,a0,1790 # ffffffffc0207bc8 <default_pmm_manager+0x838>
ffffffffc02034d2:	cbdfc0ef          	jal	ra,ffffffffc020018e <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02034d6:	018bb503          	ld	a0,24(s7)
ffffffffc02034da:	4605                	li	a2,1
ffffffffc02034dc:	6585                	lui	a1,0x1
ffffffffc02034de:	a8ffe0ef          	jal	ra,ffffffffc0201f6c <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02034e2:	4e050f63          	beqz	a0,ffffffffc02039e0 <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02034e6:	00004517          	auipc	a0,0x4
ffffffffc02034ea:	73250513          	addi	a0,a0,1842 # ffffffffc0207c18 <default_pmm_manager+0x888>
ffffffffc02034ee:	000a9997          	auipc	s3,0xa9
ffffffffc02034f2:	0a298993          	addi	s3,s3,162 # ffffffffc02ac590 <check_rp>
ffffffffc02034f6:	c99fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02034fa:	000a9a17          	auipc	s4,0xa9
ffffffffc02034fe:	0b6a0a13          	addi	s4,s4,182 # ffffffffc02ac5b0 <swap_in_seq_no>
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
ffffffffc0203522:	000a9c17          	auipc	s8,0xa9
ffffffffc0203526:	06ec0c13          	addi	s8,s8,110 # ffffffffc02ac590 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc020352a:	ec3e                	sd	a5,24(sp)
ffffffffc020352c:	641c                	ld	a5,8(s0)
ffffffffc020352e:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0203530:	481c                	lw	a5,16(s0)
ffffffffc0203532:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0203534:	000a9797          	auipc	a5,0xa9
ffffffffc0203538:	0287b623          	sd	s0,44(a5) # ffffffffc02ac560 <free_area+0x8>
ffffffffc020353c:	000a9797          	auipc	a5,0xa9
ffffffffc0203540:	0087be23          	sd	s0,28(a5) # ffffffffc02ac558 <free_area>
     nr_free = 0;
ffffffffc0203544:	000a9797          	auipc	a5,0xa9
ffffffffc0203548:	0207a223          	sw	zero,36(a5) # ffffffffc02ac568 <free_area+0x10>
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
ffffffffc0203566:	00004517          	auipc	a0,0x4
ffffffffc020356a:	73a50513          	addi	a0,a0,1850 # ffffffffc0207ca0 <default_pmm_manager+0x910>
ffffffffc020356e:	c21fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203572:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0203574:	000a9797          	auipc	a5,0xa9
ffffffffc0203578:	fa07ac23          	sw	zero,-72(a5) # ffffffffc02ac52c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020357c:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc020357e:	000a9797          	auipc	a5,0xa9
ffffffffc0203582:	fae78793          	addi	a5,a5,-82 # ffffffffc02ac52c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203586:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
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
ffffffffc02035a4:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7578>
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
ffffffffc02035c2:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6578>
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
ffffffffc02035e0:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5578>
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
ffffffffc02035fe:	000a9797          	auipc	a5,0xa9
ffffffffc0203602:	fb278793          	addi	a5,a5,-78 # ffffffffc02ac5b0 <swap_in_seq_no>
ffffffffc0203606:	000a9717          	auipc	a4,0xa9
ffffffffc020360a:	fd270713          	addi	a4,a4,-46 # ffffffffc02ac5d8 <swap_out_seq_no>
ffffffffc020360e:	000a9617          	auipc	a2,0xa9
ffffffffc0203612:	fca60613          	addi	a2,a2,-54 # ffffffffc02ac5d8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0203616:	56fd                	li	a3,-1
ffffffffc0203618:	c394                	sw	a3,0(a5)
ffffffffc020361a:	c314                	sw	a3,0(a4)
ffffffffc020361c:	0791                	addi	a5,a5,4
ffffffffc020361e:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0203620:	fef61ce3          	bne	a2,a5,ffffffffc0203618 <swap_init+0x280>
ffffffffc0203624:	000a9697          	auipc	a3,0xa9
ffffffffc0203628:	01468693          	addi	a3,a3,20 # ffffffffc02ac638 <check_ptep>
ffffffffc020362c:	000a9817          	auipc	a6,0xa9
ffffffffc0203630:	f6480813          	addi	a6,a6,-156 # ffffffffc02ac590 <check_rp>
ffffffffc0203634:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203636:	000a9c97          	auipc	s9,0xa9
ffffffffc020363a:	ee2c8c93          	addi	s9,s9,-286 # ffffffffc02ac518 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020363e:	00005d97          	auipc	s11,0x5
ffffffffc0203642:	702d8d93          	addi	s11,s11,1794 # ffffffffc0208d40 <nbase>
ffffffffc0203646:	000a9c17          	auipc	s8,0xa9
ffffffffc020364a:	f42c0c13          	addi	s8,s8,-190 # ffffffffc02ac588 <pages>
     
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
ffffffffc02036a6:	00004517          	auipc	a0,0x4
ffffffffc02036aa:	6a250513          	addi	a0,a0,1698 # ffffffffc0207d48 <default_pmm_manager+0x9b8>
ffffffffc02036ae:	ae1fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = sm->check_swap();
ffffffffc02036b2:	000a9797          	auipc	a5,0xa9
ffffffffc02036b6:	e6e78793          	addi	a5,a5,-402 # ffffffffc02ac520 <sm>
ffffffffc02036ba:	639c                	ld	a5,0(a5)
ffffffffc02036bc:	7f9c                	ld	a5,56(a5)
ffffffffc02036be:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02036c0:	40051c63          	bnez	a0,ffffffffc0203ad8 <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc02036c4:	77a2                	ld	a5,40(sp)
ffffffffc02036c6:	000a9717          	auipc	a4,0xa9
ffffffffc02036ca:	eaf72123          	sw	a5,-350(a4) # ffffffffc02ac568 <free_area+0x10>
     free_list = free_list_store;
ffffffffc02036ce:	67e2                	ld	a5,24(sp)
ffffffffc02036d0:	000a9717          	auipc	a4,0xa9
ffffffffc02036d4:	e8f73423          	sd	a5,-376(a4) # ffffffffc02ac558 <free_area>
ffffffffc02036d8:	7782                	ld	a5,32(sp)
ffffffffc02036da:	000a9717          	auipc	a4,0xa9
ffffffffc02036de:	e8f73323          	sd	a5,-378(a4) # ffffffffc02ac560 <free_area+0x8>

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
ffffffffc02036f8:	361000ef          	jal	ra,ffffffffc0204258 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02036fc:	000a9797          	auipc	a5,0xa9
ffffffffc0203700:	e1478793          	addi	a5,a5,-492 # ffffffffc02ac510 <boot_pgdir>
ffffffffc0203704:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc0203706:	000a9697          	auipc	a3,0xa9
ffffffffc020370a:	f606b123          	sd	zero,-158(a3) # ffffffffc02ac668 <check_mm_struct>
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
ffffffffc0203736:	000a9797          	auipc	a5,0xa9
ffffffffc020373a:	e4278793          	addi	a5,a5,-446 # ffffffffc02ac578 <va_pa_offset>
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
ffffffffc02037a2:	00004517          	auipc	a0,0x4
ffffffffc02037a6:	5f650513          	addi	a0,a0,1526 # ffffffffc0207d98 <default_pmm_manager+0xa08>
ffffffffc02037aa:	9e5fc0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02037ae:	b92d                	j	ffffffffc02033e8 <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc02037b0:	4481                	li	s1,0
ffffffffc02037b2:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc02037b4:	4981                	li	s3,0
ffffffffc02037b6:	b17d                	j	ffffffffc0203464 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc02037b8:	00004697          	auipc	a3,0x4
ffffffffc02037bc:	84868693          	addi	a3,a3,-1976 # ffffffffc0207000 <commands+0x890>
ffffffffc02037c0:	00003617          	auipc	a2,0x3
ffffffffc02037c4:	48860613          	addi	a2,a2,1160 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02037c8:	0bc00593          	li	a1,188
ffffffffc02037cc:	00004517          	auipc	a0,0x4
ffffffffc02037d0:	36450513          	addi	a0,a0,868 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc02037d4:	cb1fc0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02037d8:	00004617          	auipc	a2,0x4
ffffffffc02037dc:	c6860613          	addi	a2,a2,-920 # ffffffffc0207440 <default_pmm_manager+0xb0>
ffffffffc02037e0:	06200593          	li	a1,98
ffffffffc02037e4:	00004517          	auipc	a0,0x4
ffffffffc02037e8:	c2450513          	addi	a0,a0,-988 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc02037ec:	c99fc0ef          	jal	ra,ffffffffc0200484 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02037f0:	00004697          	auipc	a3,0x4
ffffffffc02037f4:	53068693          	addi	a3,a3,1328 # ffffffffc0207d20 <default_pmm_manager+0x990>
ffffffffc02037f8:	00003617          	auipc	a2,0x3
ffffffffc02037fc:	45060613          	addi	a2,a2,1104 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203800:	0fc00593          	li	a1,252
ffffffffc0203804:	00004517          	auipc	a0,0x4
ffffffffc0203808:	32c50513          	addi	a0,a0,812 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc020380c:	c79fc0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203810:	00004617          	auipc	a2,0x4
ffffffffc0203814:	e8860613          	addi	a2,a2,-376 # ffffffffc0207698 <default_pmm_manager+0x308>
ffffffffc0203818:	07400593          	li	a1,116
ffffffffc020381c:	00004517          	auipc	a0,0x4
ffffffffc0203820:	bec50513          	addi	a0,a0,-1044 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc0203824:	c61fc0ef          	jal	ra,ffffffffc0200484 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0203828:	00004697          	auipc	a3,0x4
ffffffffc020382c:	43068693          	addi	a3,a3,1072 # ffffffffc0207c58 <default_pmm_manager+0x8c8>
ffffffffc0203830:	00003617          	auipc	a2,0x3
ffffffffc0203834:	41860613          	addi	a2,a2,1048 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203838:	0dd00593          	li	a1,221
ffffffffc020383c:	00004517          	auipc	a0,0x4
ffffffffc0203840:	2f450513          	addi	a0,a0,756 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc0203844:	c41fc0ef          	jal	ra,ffffffffc0200484 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0203848:	00004697          	auipc	a3,0x4
ffffffffc020384c:	3f868693          	addi	a3,a3,1016 # ffffffffc0207c40 <default_pmm_manager+0x8b0>
ffffffffc0203850:	00003617          	auipc	a2,0x3
ffffffffc0203854:	3f860613          	addi	a2,a2,1016 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203858:	0dc00593          	li	a1,220
ffffffffc020385c:	00004517          	auipc	a0,0x4
ffffffffc0203860:	2d450513          	addi	a0,a0,724 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc0203864:	c21fc0ef          	jal	ra,ffffffffc0200484 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203868:	00004697          	auipc	a3,0x4
ffffffffc020386c:	4a068693          	addi	a3,a3,1184 # ffffffffc0207d08 <default_pmm_manager+0x978>
ffffffffc0203870:	00003617          	auipc	a2,0x3
ffffffffc0203874:	3d860613          	addi	a2,a2,984 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203878:	0fb00593          	li	a1,251
ffffffffc020387c:	00004517          	auipc	a0,0x4
ffffffffc0203880:	2b450513          	addi	a0,a0,692 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc0203884:	c01fc0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0203888:	00004617          	auipc	a2,0x4
ffffffffc020388c:	28860613          	addi	a2,a2,648 # ffffffffc0207b10 <default_pmm_manager+0x780>
ffffffffc0203890:	02800593          	li	a1,40
ffffffffc0203894:	00004517          	auipc	a0,0x4
ffffffffc0203898:	29c50513          	addi	a0,a0,668 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc020389c:	be9fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==2);
ffffffffc02038a0:	00004697          	auipc	a3,0x4
ffffffffc02038a4:	43868693          	addi	a3,a3,1080 # ffffffffc0207cd8 <default_pmm_manager+0x948>
ffffffffc02038a8:	00003617          	auipc	a2,0x3
ffffffffc02038ac:	3a060613          	addi	a2,a2,928 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02038b0:	09700593          	li	a1,151
ffffffffc02038b4:	00004517          	auipc	a0,0x4
ffffffffc02038b8:	27c50513          	addi	a0,a0,636 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc02038bc:	bc9fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==2);
ffffffffc02038c0:	00004697          	auipc	a3,0x4
ffffffffc02038c4:	41868693          	addi	a3,a3,1048 # ffffffffc0207cd8 <default_pmm_manager+0x948>
ffffffffc02038c8:	00003617          	auipc	a2,0x3
ffffffffc02038cc:	38060613          	addi	a2,a2,896 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02038d0:	09900593          	li	a1,153
ffffffffc02038d4:	00004517          	auipc	a0,0x4
ffffffffc02038d8:	25c50513          	addi	a0,a0,604 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc02038dc:	ba9fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==3);
ffffffffc02038e0:	00004697          	auipc	a3,0x4
ffffffffc02038e4:	40868693          	addi	a3,a3,1032 # ffffffffc0207ce8 <default_pmm_manager+0x958>
ffffffffc02038e8:	00003617          	auipc	a2,0x3
ffffffffc02038ec:	36060613          	addi	a2,a2,864 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02038f0:	09b00593          	li	a1,155
ffffffffc02038f4:	00004517          	auipc	a0,0x4
ffffffffc02038f8:	23c50513          	addi	a0,a0,572 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc02038fc:	b89fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==3);
ffffffffc0203900:	00004697          	auipc	a3,0x4
ffffffffc0203904:	3e868693          	addi	a3,a3,1000 # ffffffffc0207ce8 <default_pmm_manager+0x958>
ffffffffc0203908:	00003617          	auipc	a2,0x3
ffffffffc020390c:	34060613          	addi	a2,a2,832 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203910:	09d00593          	li	a1,157
ffffffffc0203914:	00004517          	auipc	a0,0x4
ffffffffc0203918:	21c50513          	addi	a0,a0,540 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc020391c:	b69fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==1);
ffffffffc0203920:	00004697          	auipc	a3,0x4
ffffffffc0203924:	3a868693          	addi	a3,a3,936 # ffffffffc0207cc8 <default_pmm_manager+0x938>
ffffffffc0203928:	00003617          	auipc	a2,0x3
ffffffffc020392c:	32060613          	addi	a2,a2,800 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203930:	09300593          	li	a1,147
ffffffffc0203934:	00004517          	auipc	a0,0x4
ffffffffc0203938:	1fc50513          	addi	a0,a0,508 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc020393c:	b49fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==1);
ffffffffc0203940:	00004697          	auipc	a3,0x4
ffffffffc0203944:	38868693          	addi	a3,a3,904 # ffffffffc0207cc8 <default_pmm_manager+0x938>
ffffffffc0203948:	00003617          	auipc	a2,0x3
ffffffffc020394c:	30060613          	addi	a2,a2,768 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203950:	09500593          	li	a1,149
ffffffffc0203954:	00004517          	auipc	a0,0x4
ffffffffc0203958:	1dc50513          	addi	a0,a0,476 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc020395c:	b29fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==4);
ffffffffc0203960:	00004697          	auipc	a3,0x4
ffffffffc0203964:	39868693          	addi	a3,a3,920 # ffffffffc0207cf8 <default_pmm_manager+0x968>
ffffffffc0203968:	00003617          	auipc	a2,0x3
ffffffffc020396c:	2e060613          	addi	a2,a2,736 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203970:	09f00593          	li	a1,159
ffffffffc0203974:	00004517          	auipc	a0,0x4
ffffffffc0203978:	1bc50513          	addi	a0,a0,444 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc020397c:	b09fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==4);
ffffffffc0203980:	00004697          	auipc	a3,0x4
ffffffffc0203984:	37868693          	addi	a3,a3,888 # ffffffffc0207cf8 <default_pmm_manager+0x968>
ffffffffc0203988:	00003617          	auipc	a2,0x3
ffffffffc020398c:	2c060613          	addi	a2,a2,704 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203990:	0a100593          	li	a1,161
ffffffffc0203994:	00004517          	auipc	a0,0x4
ffffffffc0203998:	19c50513          	addi	a0,a0,412 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc020399c:	ae9fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgdir[0] == 0);
ffffffffc02039a0:	00004697          	auipc	a3,0x4
ffffffffc02039a4:	20868693          	addi	a3,a3,520 # ffffffffc0207ba8 <default_pmm_manager+0x818>
ffffffffc02039a8:	00003617          	auipc	a2,0x3
ffffffffc02039ac:	2a060613          	addi	a2,a2,672 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02039b0:	0cc00593          	li	a1,204
ffffffffc02039b4:	00004517          	auipc	a0,0x4
ffffffffc02039b8:	17c50513          	addi	a0,a0,380 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc02039bc:	ac9fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(vma != NULL);
ffffffffc02039c0:	00004697          	auipc	a3,0x4
ffffffffc02039c4:	1f868693          	addi	a3,a3,504 # ffffffffc0207bb8 <default_pmm_manager+0x828>
ffffffffc02039c8:	00003617          	auipc	a2,0x3
ffffffffc02039cc:	28060613          	addi	a2,a2,640 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02039d0:	0cf00593          	li	a1,207
ffffffffc02039d4:	00004517          	auipc	a0,0x4
ffffffffc02039d8:	15c50513          	addi	a0,a0,348 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc02039dc:	aa9fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02039e0:	00004697          	auipc	a3,0x4
ffffffffc02039e4:	22068693          	addi	a3,a3,544 # ffffffffc0207c00 <default_pmm_manager+0x870>
ffffffffc02039e8:	00003617          	auipc	a2,0x3
ffffffffc02039ec:	26060613          	addi	a2,a2,608 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02039f0:	0d700593          	li	a1,215
ffffffffc02039f4:	00004517          	auipc	a0,0x4
ffffffffc02039f8:	13c50513          	addi	a0,a0,316 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc02039fc:	a89fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert( nr_free == 0);         
ffffffffc0203a00:	00003697          	auipc	a3,0x3
ffffffffc0203a04:	7d068693          	addi	a3,a3,2000 # ffffffffc02071d0 <commands+0xa60>
ffffffffc0203a08:	00003617          	auipc	a2,0x3
ffffffffc0203a0c:	24060613          	addi	a2,a2,576 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203a10:	0f300593          	li	a1,243
ffffffffc0203a14:	00004517          	auipc	a0,0x4
ffffffffc0203a18:	11c50513          	addi	a0,a0,284 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc0203a1c:	a69fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203a20:	00004617          	auipc	a2,0x4
ffffffffc0203a24:	9c060613          	addi	a2,a2,-1600 # ffffffffc02073e0 <default_pmm_manager+0x50>
ffffffffc0203a28:	06900593          	li	a1,105
ffffffffc0203a2c:	00004517          	auipc	a0,0x4
ffffffffc0203a30:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc0203a34:	a51fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(count==0);
ffffffffc0203a38:	00004697          	auipc	a3,0x4
ffffffffc0203a3c:	34068693          	addi	a3,a3,832 # ffffffffc0207d78 <default_pmm_manager+0x9e8>
ffffffffc0203a40:	00003617          	auipc	a2,0x3
ffffffffc0203a44:	20860613          	addi	a2,a2,520 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203a48:	11d00593          	li	a1,285
ffffffffc0203a4c:	00004517          	auipc	a0,0x4
ffffffffc0203a50:	0e450513          	addi	a0,a0,228 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc0203a54:	a31fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(total==0);
ffffffffc0203a58:	00004697          	auipc	a3,0x4
ffffffffc0203a5c:	33068693          	addi	a3,a3,816 # ffffffffc0207d88 <default_pmm_manager+0x9f8>
ffffffffc0203a60:	00003617          	auipc	a2,0x3
ffffffffc0203a64:	1e860613          	addi	a2,a2,488 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203a68:	11e00593          	li	a1,286
ffffffffc0203a6c:	00004517          	auipc	a0,0x4
ffffffffc0203a70:	0c450513          	addi	a0,a0,196 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc0203a74:	a11fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203a78:	00004697          	auipc	a3,0x4
ffffffffc0203a7c:	20068693          	addi	a3,a3,512 # ffffffffc0207c78 <default_pmm_manager+0x8e8>
ffffffffc0203a80:	00003617          	auipc	a2,0x3
ffffffffc0203a84:	1c860613          	addi	a2,a2,456 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203a88:	0ea00593          	li	a1,234
ffffffffc0203a8c:	00004517          	auipc	a0,0x4
ffffffffc0203a90:	0a450513          	addi	a0,a0,164 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc0203a94:	9f1fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(mm != NULL);
ffffffffc0203a98:	00004697          	auipc	a3,0x4
ffffffffc0203a9c:	0e868693          	addi	a3,a3,232 # ffffffffc0207b80 <default_pmm_manager+0x7f0>
ffffffffc0203aa0:	00003617          	auipc	a2,0x3
ffffffffc0203aa4:	1a860613          	addi	a2,a2,424 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203aa8:	0c400593          	li	a1,196
ffffffffc0203aac:	00004517          	auipc	a0,0x4
ffffffffc0203ab0:	08450513          	addi	a0,a0,132 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc0203ab4:	9d1fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203ab8:	00004697          	auipc	a3,0x4
ffffffffc0203abc:	0d868693          	addi	a3,a3,216 # ffffffffc0207b90 <default_pmm_manager+0x800>
ffffffffc0203ac0:	00003617          	auipc	a2,0x3
ffffffffc0203ac4:	18860613          	addi	a2,a2,392 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203ac8:	0c700593          	li	a1,199
ffffffffc0203acc:	00004517          	auipc	a0,0x4
ffffffffc0203ad0:	06450513          	addi	a0,a0,100 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc0203ad4:	9b1fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(ret==0);
ffffffffc0203ad8:	00004697          	auipc	a3,0x4
ffffffffc0203adc:	29868693          	addi	a3,a3,664 # ffffffffc0207d70 <default_pmm_manager+0x9e0>
ffffffffc0203ae0:	00003617          	auipc	a2,0x3
ffffffffc0203ae4:	16860613          	addi	a2,a2,360 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203ae8:	10200593          	li	a1,258
ffffffffc0203aec:	00004517          	auipc	a0,0x4
ffffffffc0203af0:	04450513          	addi	a0,a0,68 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc0203af4:	991fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203af8:	00003697          	auipc	a3,0x3
ffffffffc0203afc:	53068693          	addi	a3,a3,1328 # ffffffffc0207028 <commands+0x8b8>
ffffffffc0203b00:	00003617          	auipc	a2,0x3
ffffffffc0203b04:	14860613          	addi	a2,a2,328 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203b08:	0bf00593          	li	a1,191
ffffffffc0203b0c:	00004517          	auipc	a0,0x4
ffffffffc0203b10:	02450513          	addi	a0,a0,36 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc0203b14:	971fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203b18 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203b18:	000a9797          	auipc	a5,0xa9
ffffffffc0203b1c:	a0878793          	addi	a5,a5,-1528 # ffffffffc02ac520 <sm>
ffffffffc0203b20:	639c                	ld	a5,0(a5)
ffffffffc0203b22:	0107b303          	ld	t1,16(a5)
ffffffffc0203b26:	8302                	jr	t1

ffffffffc0203b28 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203b28:	000a9797          	auipc	a5,0xa9
ffffffffc0203b2c:	9f878793          	addi	a5,a5,-1544 # ffffffffc02ac520 <sm>
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
ffffffffc0203b58:	000a9997          	auipc	s3,0xa9
ffffffffc0203b5c:	9c898993          	addi	s3,s3,-1592 # ffffffffc02ac520 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b60:	00004b17          	auipc	s6,0x4
ffffffffc0203b64:	2b8b0b13          	addi	s6,s6,696 # ffffffffc0207e18 <default_pmm_manager+0xa88>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203b68:	00004b97          	auipc	s7,0x4
ffffffffc0203b6c:	298b8b93          	addi	s7,s7,664 # ffffffffc0207e00 <default_pmm_manager+0xa70>
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
ffffffffc0203b82:	e0cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
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
ffffffffc0203bdc:	044010ef          	jal	ra,ffffffffc0204c20 <swapfs_write>
ffffffffc0203be0:	d949                	beqz	a0,ffffffffc0203b72 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203be2:	855e                	mv	a0,s7
ffffffffc0203be4:	daafc0ef          	jal	ra,ffffffffc020018e <cprintf>
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
ffffffffc0203c1a:	00004517          	auipc	a0,0x4
ffffffffc0203c1e:	19e50513          	addi	a0,a0,414 # ffffffffc0207db8 <default_pmm_manager+0xa28>
ffffffffc0203c22:	d6cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
                  break;
ffffffffc0203c26:	bfe1                	j	ffffffffc0203bfe <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203c28:	4401                	li	s0,0
ffffffffc0203c2a:	bfd1                	j	ffffffffc0203bfe <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c2c:	00004697          	auipc	a3,0x4
ffffffffc0203c30:	1bc68693          	addi	a3,a3,444 # ffffffffc0207de8 <default_pmm_manager+0xa58>
ffffffffc0203c34:	00003617          	auipc	a2,0x3
ffffffffc0203c38:	01460613          	addi	a2,a2,20 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203c3c:	06800593          	li	a1,104
ffffffffc0203c40:	00004517          	auipc	a0,0x4
ffffffffc0203c44:	ef050513          	addi	a0,a0,-272 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc0203c48:	83dfc0ef          	jal	ra,ffffffffc0200484 <__panic>

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
ffffffffc0203c7a:	70f000ef          	jal	ra,ffffffffc0204b88 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203c7e:	00093583          	ld	a1,0(s2)
ffffffffc0203c82:	8626                	mv	a2,s1
ffffffffc0203c84:	00004517          	auipc	a0,0x4
ffffffffc0203c88:	e4c50513          	addi	a0,a0,-436 # ffffffffc0207ad0 <default_pmm_manager+0x740>
ffffffffc0203c8c:	81a1                	srli	a1,a1,0x8
ffffffffc0203c8e:	d00fc0ef          	jal	ra,ffffffffc020018e <cprintf>
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
ffffffffc0203ca6:	00004697          	auipc	a3,0x4
ffffffffc0203caa:	e1a68693          	addi	a3,a3,-486 # ffffffffc0207ac0 <default_pmm_manager+0x730>
ffffffffc0203cae:	00003617          	auipc	a2,0x3
ffffffffc0203cb2:	f9a60613          	addi	a2,a2,-102 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203cb6:	07e00593          	li	a1,126
ffffffffc0203cba:	00004517          	auipc	a0,0x4
ffffffffc0203cbe:	e7650513          	addi	a0,a0,-394 # ffffffffc0207b30 <default_pmm_manager+0x7a0>
ffffffffc0203cc2:	fc2fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203cc6 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203cc6:	000a9797          	auipc	a5,0xa9
ffffffffc0203cca:	99278793          	addi	a5,a5,-1646 # ffffffffc02ac658 <pra_list_head>
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
ffffffffc0203cea:	00004517          	auipc	a0,0x4
ffffffffc0203cee:	16e50513          	addi	a0,a0,366 # ffffffffc0207e58 <default_pmm_manager+0xac8>
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
ffffffffc0203d08:	000a9417          	auipc	s0,0xa9
ffffffffc0203d0c:	82440413          	addi	s0,s0,-2012 # ffffffffc02ac52c <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203d10:	c7efc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203d14:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6578>
    assert(pgfault_num==4);
ffffffffc0203d18:	4004                	lw	s1,0(s0)
ffffffffc0203d1a:	4791                	li	a5,4
ffffffffc0203d1c:	2481                	sext.w	s1,s1
ffffffffc0203d1e:	14f49963          	bne	s1,a5,ffffffffc0203e70 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d22:	00004517          	auipc	a0,0x4
ffffffffc0203d26:	17650513          	addi	a0,a0,374 # ffffffffc0207e98 <default_pmm_manager+0xb08>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d2a:	6a85                	lui	s5,0x1
ffffffffc0203d2c:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d2e:	c60fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d32:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
    assert(pgfault_num==4);
ffffffffc0203d36:	00042903          	lw	s2,0(s0)
ffffffffc0203d3a:	2901                	sext.w	s2,s2
ffffffffc0203d3c:	2a991a63          	bne	s2,s1,ffffffffc0203ff0 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d40:	00004517          	auipc	a0,0x4
ffffffffc0203d44:	18050513          	addi	a0,a0,384 # ffffffffc0207ec0 <default_pmm_manager+0xb30>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d48:	6b91                	lui	s7,0x4
ffffffffc0203d4a:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d4c:	c42fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d50:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5578>
    assert(pgfault_num==4);
ffffffffc0203d54:	4004                	lw	s1,0(s0)
ffffffffc0203d56:	2481                	sext.w	s1,s1
ffffffffc0203d58:	27249c63          	bne	s1,s2,ffffffffc0203fd0 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d5c:	00004517          	auipc	a0,0x4
ffffffffc0203d60:	18c50513          	addi	a0,a0,396 # ffffffffc0207ee8 <default_pmm_manager+0xb58>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d64:	6909                	lui	s2,0x2
ffffffffc0203d66:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d68:	c26fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d6c:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x7578>
    assert(pgfault_num==4);
ffffffffc0203d70:	401c                	lw	a5,0(s0)
ffffffffc0203d72:	2781                	sext.w	a5,a5
ffffffffc0203d74:	22979e63          	bne	a5,s1,ffffffffc0203fb0 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203d78:	00004517          	auipc	a0,0x4
ffffffffc0203d7c:	19850513          	addi	a0,a0,408 # ffffffffc0207f10 <default_pmm_manager+0xb80>
ffffffffc0203d80:	c0efc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203d84:	6795                	lui	a5,0x5
ffffffffc0203d86:	4739                	li	a4,14
ffffffffc0203d88:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4578>
    assert(pgfault_num==5);
ffffffffc0203d8c:	4004                	lw	s1,0(s0)
ffffffffc0203d8e:	4795                	li	a5,5
ffffffffc0203d90:	2481                	sext.w	s1,s1
ffffffffc0203d92:	1ef49f63          	bne	s1,a5,ffffffffc0203f90 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d96:	00004517          	auipc	a0,0x4
ffffffffc0203d9a:	15250513          	addi	a0,a0,338 # ffffffffc0207ee8 <default_pmm_manager+0xb58>
ffffffffc0203d9e:	bf0fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203da2:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203da6:	401c                	lw	a5,0(s0)
ffffffffc0203da8:	2781                	sext.w	a5,a5
ffffffffc0203daa:	1c979363          	bne	a5,s1,ffffffffc0203f70 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203dae:	00004517          	auipc	a0,0x4
ffffffffc0203db2:	0ea50513          	addi	a0,a0,234 # ffffffffc0207e98 <default_pmm_manager+0xb08>
ffffffffc0203db6:	bd8fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203dba:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203dbe:	401c                	lw	a5,0(s0)
ffffffffc0203dc0:	4719                	li	a4,6
ffffffffc0203dc2:	2781                	sext.w	a5,a5
ffffffffc0203dc4:	18e79663          	bne	a5,a4,ffffffffc0203f50 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203dc8:	00004517          	auipc	a0,0x4
ffffffffc0203dcc:	12050513          	addi	a0,a0,288 # ffffffffc0207ee8 <default_pmm_manager+0xb58>
ffffffffc0203dd0:	bbefc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203dd4:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203dd8:	401c                	lw	a5,0(s0)
ffffffffc0203dda:	471d                	li	a4,7
ffffffffc0203ddc:	2781                	sext.w	a5,a5
ffffffffc0203dde:	14e79963          	bne	a5,a4,ffffffffc0203f30 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203de2:	00004517          	auipc	a0,0x4
ffffffffc0203de6:	07650513          	addi	a0,a0,118 # ffffffffc0207e58 <default_pmm_manager+0xac8>
ffffffffc0203dea:	ba4fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203dee:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203df2:	401c                	lw	a5,0(s0)
ffffffffc0203df4:	4721                	li	a4,8
ffffffffc0203df6:	2781                	sext.w	a5,a5
ffffffffc0203df8:	10e79c63          	bne	a5,a4,ffffffffc0203f10 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203dfc:	00004517          	auipc	a0,0x4
ffffffffc0203e00:	0c450513          	addi	a0,a0,196 # ffffffffc0207ec0 <default_pmm_manager+0xb30>
ffffffffc0203e04:	b8afc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203e08:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203e0c:	401c                	lw	a5,0(s0)
ffffffffc0203e0e:	4725                	li	a4,9
ffffffffc0203e10:	2781                	sext.w	a5,a5
ffffffffc0203e12:	0ce79f63          	bne	a5,a4,ffffffffc0203ef0 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203e16:	00004517          	auipc	a0,0x4
ffffffffc0203e1a:	0fa50513          	addi	a0,a0,250 # ffffffffc0207f10 <default_pmm_manager+0xb80>
ffffffffc0203e1e:	b70fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203e22:	6795                	lui	a5,0x5
ffffffffc0203e24:	4739                	li	a4,14
ffffffffc0203e26:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4578>
    assert(pgfault_num==10);
ffffffffc0203e2a:	4004                	lw	s1,0(s0)
ffffffffc0203e2c:	47a9                	li	a5,10
ffffffffc0203e2e:	2481                	sext.w	s1,s1
ffffffffc0203e30:	0af49063          	bne	s1,a5,ffffffffc0203ed0 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203e34:	00004517          	auipc	a0,0x4
ffffffffc0203e38:	06450513          	addi	a0,a0,100 # ffffffffc0207e98 <default_pmm_manager+0xb08>
ffffffffc0203e3c:	b52fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203e40:	6785                	lui	a5,0x1
ffffffffc0203e42:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
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
ffffffffc0203e70:	00004697          	auipc	a3,0x4
ffffffffc0203e74:	e8868693          	addi	a3,a3,-376 # ffffffffc0207cf8 <default_pmm_manager+0x968>
ffffffffc0203e78:	00003617          	auipc	a2,0x3
ffffffffc0203e7c:	dd060613          	addi	a2,a2,-560 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203e80:	05100593          	li	a1,81
ffffffffc0203e84:	00004517          	auipc	a0,0x4
ffffffffc0203e88:	ffc50513          	addi	a0,a0,-4 # ffffffffc0207e80 <default_pmm_manager+0xaf0>
ffffffffc0203e8c:	df8fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==11);
ffffffffc0203e90:	00004697          	auipc	a3,0x4
ffffffffc0203e94:	13068693          	addi	a3,a3,304 # ffffffffc0207fc0 <default_pmm_manager+0xc30>
ffffffffc0203e98:	00003617          	auipc	a2,0x3
ffffffffc0203e9c:	db060613          	addi	a2,a2,-592 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203ea0:	07300593          	li	a1,115
ffffffffc0203ea4:	00004517          	auipc	a0,0x4
ffffffffc0203ea8:	fdc50513          	addi	a0,a0,-36 # ffffffffc0207e80 <default_pmm_manager+0xaf0>
ffffffffc0203eac:	dd8fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203eb0:	00004697          	auipc	a3,0x4
ffffffffc0203eb4:	0e868693          	addi	a3,a3,232 # ffffffffc0207f98 <default_pmm_manager+0xc08>
ffffffffc0203eb8:	00003617          	auipc	a2,0x3
ffffffffc0203ebc:	d9060613          	addi	a2,a2,-624 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203ec0:	07100593          	li	a1,113
ffffffffc0203ec4:	00004517          	auipc	a0,0x4
ffffffffc0203ec8:	fbc50513          	addi	a0,a0,-68 # ffffffffc0207e80 <default_pmm_manager+0xaf0>
ffffffffc0203ecc:	db8fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==10);
ffffffffc0203ed0:	00004697          	auipc	a3,0x4
ffffffffc0203ed4:	0b868693          	addi	a3,a3,184 # ffffffffc0207f88 <default_pmm_manager+0xbf8>
ffffffffc0203ed8:	00003617          	auipc	a2,0x3
ffffffffc0203edc:	d7060613          	addi	a2,a2,-656 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203ee0:	06f00593          	li	a1,111
ffffffffc0203ee4:	00004517          	auipc	a0,0x4
ffffffffc0203ee8:	f9c50513          	addi	a0,a0,-100 # ffffffffc0207e80 <default_pmm_manager+0xaf0>
ffffffffc0203eec:	d98fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==9);
ffffffffc0203ef0:	00004697          	auipc	a3,0x4
ffffffffc0203ef4:	08868693          	addi	a3,a3,136 # ffffffffc0207f78 <default_pmm_manager+0xbe8>
ffffffffc0203ef8:	00003617          	auipc	a2,0x3
ffffffffc0203efc:	d5060613          	addi	a2,a2,-688 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203f00:	06c00593          	li	a1,108
ffffffffc0203f04:	00004517          	auipc	a0,0x4
ffffffffc0203f08:	f7c50513          	addi	a0,a0,-132 # ffffffffc0207e80 <default_pmm_manager+0xaf0>
ffffffffc0203f0c:	d78fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==8);
ffffffffc0203f10:	00004697          	auipc	a3,0x4
ffffffffc0203f14:	05868693          	addi	a3,a3,88 # ffffffffc0207f68 <default_pmm_manager+0xbd8>
ffffffffc0203f18:	00003617          	auipc	a2,0x3
ffffffffc0203f1c:	d3060613          	addi	a2,a2,-720 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203f20:	06900593          	li	a1,105
ffffffffc0203f24:	00004517          	auipc	a0,0x4
ffffffffc0203f28:	f5c50513          	addi	a0,a0,-164 # ffffffffc0207e80 <default_pmm_manager+0xaf0>
ffffffffc0203f2c:	d58fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==7);
ffffffffc0203f30:	00004697          	auipc	a3,0x4
ffffffffc0203f34:	02868693          	addi	a3,a3,40 # ffffffffc0207f58 <default_pmm_manager+0xbc8>
ffffffffc0203f38:	00003617          	auipc	a2,0x3
ffffffffc0203f3c:	d1060613          	addi	a2,a2,-752 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203f40:	06600593          	li	a1,102
ffffffffc0203f44:	00004517          	auipc	a0,0x4
ffffffffc0203f48:	f3c50513          	addi	a0,a0,-196 # ffffffffc0207e80 <default_pmm_manager+0xaf0>
ffffffffc0203f4c:	d38fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==6);
ffffffffc0203f50:	00004697          	auipc	a3,0x4
ffffffffc0203f54:	ff868693          	addi	a3,a3,-8 # ffffffffc0207f48 <default_pmm_manager+0xbb8>
ffffffffc0203f58:	00003617          	auipc	a2,0x3
ffffffffc0203f5c:	cf060613          	addi	a2,a2,-784 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203f60:	06300593          	li	a1,99
ffffffffc0203f64:	00004517          	auipc	a0,0x4
ffffffffc0203f68:	f1c50513          	addi	a0,a0,-228 # ffffffffc0207e80 <default_pmm_manager+0xaf0>
ffffffffc0203f6c:	d18fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==5);
ffffffffc0203f70:	00004697          	auipc	a3,0x4
ffffffffc0203f74:	fc868693          	addi	a3,a3,-56 # ffffffffc0207f38 <default_pmm_manager+0xba8>
ffffffffc0203f78:	00003617          	auipc	a2,0x3
ffffffffc0203f7c:	cd060613          	addi	a2,a2,-816 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203f80:	06000593          	li	a1,96
ffffffffc0203f84:	00004517          	auipc	a0,0x4
ffffffffc0203f88:	efc50513          	addi	a0,a0,-260 # ffffffffc0207e80 <default_pmm_manager+0xaf0>
ffffffffc0203f8c:	cf8fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==5);
ffffffffc0203f90:	00004697          	auipc	a3,0x4
ffffffffc0203f94:	fa868693          	addi	a3,a3,-88 # ffffffffc0207f38 <default_pmm_manager+0xba8>
ffffffffc0203f98:	00003617          	auipc	a2,0x3
ffffffffc0203f9c:	cb060613          	addi	a2,a2,-848 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203fa0:	05d00593          	li	a1,93
ffffffffc0203fa4:	00004517          	auipc	a0,0x4
ffffffffc0203fa8:	edc50513          	addi	a0,a0,-292 # ffffffffc0207e80 <default_pmm_manager+0xaf0>
ffffffffc0203fac:	cd8fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==4);
ffffffffc0203fb0:	00004697          	auipc	a3,0x4
ffffffffc0203fb4:	d4868693          	addi	a3,a3,-696 # ffffffffc0207cf8 <default_pmm_manager+0x968>
ffffffffc0203fb8:	00003617          	auipc	a2,0x3
ffffffffc0203fbc:	c9060613          	addi	a2,a2,-880 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203fc0:	05a00593          	li	a1,90
ffffffffc0203fc4:	00004517          	auipc	a0,0x4
ffffffffc0203fc8:	ebc50513          	addi	a0,a0,-324 # ffffffffc0207e80 <default_pmm_manager+0xaf0>
ffffffffc0203fcc:	cb8fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==4);
ffffffffc0203fd0:	00004697          	auipc	a3,0x4
ffffffffc0203fd4:	d2868693          	addi	a3,a3,-728 # ffffffffc0207cf8 <default_pmm_manager+0x968>
ffffffffc0203fd8:	00003617          	auipc	a2,0x3
ffffffffc0203fdc:	c7060613          	addi	a2,a2,-912 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0203fe0:	05700593          	li	a1,87
ffffffffc0203fe4:	00004517          	auipc	a0,0x4
ffffffffc0203fe8:	e9c50513          	addi	a0,a0,-356 # ffffffffc0207e80 <default_pmm_manager+0xaf0>
ffffffffc0203fec:	c98fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==4);
ffffffffc0203ff0:	00004697          	auipc	a3,0x4
ffffffffc0203ff4:	d0868693          	addi	a3,a3,-760 # ffffffffc0207cf8 <default_pmm_manager+0x968>
ffffffffc0203ff8:	00003617          	auipc	a2,0x3
ffffffffc0203ffc:	c5060613          	addi	a2,a2,-944 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0204000:	05400593          	li	a1,84
ffffffffc0204004:	00004517          	auipc	a0,0x4
ffffffffc0204008:	e7c50513          	addi	a0,a0,-388 # ffffffffc0207e80 <default_pmm_manager+0xaf0>
ffffffffc020400c:	c78fc0ef          	jal	ra,ffffffffc0200484 <__panic>

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
ffffffffc0204032:	00004697          	auipc	a3,0x4
ffffffffc0204036:	fbe68693          	addi	a3,a3,-66 # ffffffffc0207ff0 <default_pmm_manager+0xc60>
ffffffffc020403a:	00003617          	auipc	a2,0x3
ffffffffc020403e:	c0e60613          	addi	a2,a2,-1010 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0204042:	04100593          	li	a1,65
ffffffffc0204046:	00004517          	auipc	a0,0x4
ffffffffc020404a:	e3a50513          	addi	a0,a0,-454 # ffffffffc0207e80 <default_pmm_manager+0xaf0>
ffffffffc020404e:	c36fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(in_tick==0);
ffffffffc0204052:	00004697          	auipc	a3,0x4
ffffffffc0204056:	fae68693          	addi	a3,a3,-82 # ffffffffc0208000 <default_pmm_manager+0xc70>
ffffffffc020405a:	00003617          	auipc	a2,0x3
ffffffffc020405e:	bee60613          	addi	a2,a2,-1042 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0204062:	04200593          	li	a1,66
ffffffffc0204066:	00004517          	auipc	a0,0x4
ffffffffc020406a:	e1a50513          	addi	a0,a0,-486 # ffffffffc0207e80 <default_pmm_manager+0xaf0>
ffffffffc020406e:	c16fc0ef          	jal	ra,ffffffffc0200484 <__panic>

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
ffffffffc020408c:	00004697          	auipc	a3,0x4
ffffffffc0204090:	f4468693          	addi	a3,a3,-188 # ffffffffc0207fd0 <default_pmm_manager+0xc40>
ffffffffc0204094:	00003617          	auipc	a2,0x3
ffffffffc0204098:	bb460613          	addi	a2,a2,-1100 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc020409c:	03200593          	li	a1,50
ffffffffc02040a0:	00004517          	auipc	a0,0x4
ffffffffc02040a4:	de050513          	addi	a0,a0,-544 # ffffffffc0207e80 <default_pmm_manager+0xaf0>
{
ffffffffc02040a8:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc02040aa:	bdafc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02040ae <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02040ae:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02040b0:	00004697          	auipc	a3,0x4
ffffffffc02040b4:	f7868693          	addi	a3,a3,-136 # ffffffffc0208028 <default_pmm_manager+0xc98>
ffffffffc02040b8:	00003617          	auipc	a2,0x3
ffffffffc02040bc:	b9060613          	addi	a2,a2,-1136 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02040c0:	06d00593          	li	a1,109
ffffffffc02040c4:	00004517          	auipc	a0,0x4
ffffffffc02040c8:	f8450513          	addi	a0,a0,-124 # ffffffffc0208048 <default_pmm_manager+0xcb8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02040cc:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02040ce:	bb6fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02040d2 <mm_create>:
mm_create(void) {
ffffffffc02040d2:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02040d4:	04000513          	li	a0,64
mm_create(void) {
ffffffffc02040d8:	e022                	sd	s0,0(sp)
ffffffffc02040da:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02040dc:	b87fd0ef          	jal	ra,ffffffffc0201c62 <kmalloc>
ffffffffc02040e0:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02040e2:	c515                	beqz	a0,ffffffffc020410e <mm_create+0x3c>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02040e4:	000a8797          	auipc	a5,0xa8
ffffffffc02040e8:	44478793          	addi	a5,a5,1092 # ffffffffc02ac528 <swap_init_ok>
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
ffffffffc0204100:	ef81                	bnez	a5,ffffffffc0204118 <mm_create+0x46>
        else mm->sm_priv = NULL;
ffffffffc0204102:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc0204106:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc020410a:	02043c23          	sd	zero,56(s0)
}
ffffffffc020410e:	8522                	mv	a0,s0
ffffffffc0204110:	60a2                	ld	ra,8(sp)
ffffffffc0204112:	6402                	ld	s0,0(sp)
ffffffffc0204114:	0141                	addi	sp,sp,16
ffffffffc0204116:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0204118:	a01ff0ef          	jal	ra,ffffffffc0203b18 <swap_init_mm>
ffffffffc020411c:	b7ed                	j	ffffffffc0204106 <mm_create+0x34>

ffffffffc020411e <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020411e:	1101                	addi	sp,sp,-32
ffffffffc0204120:	e04a                	sd	s2,0(sp)
ffffffffc0204122:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204124:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0204128:	e822                	sd	s0,16(sp)
ffffffffc020412a:	e426                	sd	s1,8(sp)
ffffffffc020412c:	ec06                	sd	ra,24(sp)
ffffffffc020412e:	84ae                	mv	s1,a1
ffffffffc0204130:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204132:	b31fd0ef          	jal	ra,ffffffffc0201c62 <kmalloc>
    if (vma != NULL) {
ffffffffc0204136:	c509                	beqz	a0,ffffffffc0204140 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0204138:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc020413c:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020413e:	cd00                	sw	s0,24(a0)
}
ffffffffc0204140:	60e2                	ld	ra,24(sp)
ffffffffc0204142:	6442                	ld	s0,16(sp)
ffffffffc0204144:	64a2                	ld	s1,8(sp)
ffffffffc0204146:	6902                	ld	s2,0(sp)
ffffffffc0204148:	6105                	addi	sp,sp,32
ffffffffc020414a:	8082                	ret

ffffffffc020414c <find_vma>:
    if (mm != NULL) {
ffffffffc020414c:	c51d                	beqz	a0,ffffffffc020417a <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc020414e:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204150:	c781                	beqz	a5,ffffffffc0204158 <find_vma+0xc>
ffffffffc0204152:	6798                	ld	a4,8(a5)
ffffffffc0204154:	02e5f663          	bleu	a4,a1,ffffffffc0204180 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0204158:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc020415a:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc020415c:	00f50f63          	beq	a0,a5,ffffffffc020417a <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0204160:	fe87b703          	ld	a4,-24(a5)
ffffffffc0204164:	fee5ebe3          	bltu	a1,a4,ffffffffc020415a <find_vma+0xe>
ffffffffc0204168:	ff07b703          	ld	a4,-16(a5)
ffffffffc020416c:	fee5f7e3          	bleu	a4,a1,ffffffffc020415a <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0204170:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0204172:	c781                	beqz	a5,ffffffffc020417a <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0204174:	e91c                	sd	a5,16(a0)
}
ffffffffc0204176:	853e                	mv	a0,a5
ffffffffc0204178:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc020417a:	4781                	li	a5,0
}
ffffffffc020417c:	853e                	mv	a0,a5
ffffffffc020417e:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204180:	6b98                	ld	a4,16(a5)
ffffffffc0204182:	fce5fbe3          	bleu	a4,a1,ffffffffc0204158 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0204186:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0204188:	b7fd                	j	ffffffffc0204176 <find_vma+0x2a>

ffffffffc020418a <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc020418a:	6590                	ld	a2,8(a1)
ffffffffc020418c:	0105b803          	ld	a6,16(a1) # 1010 <_binary_obj___user_faultread_out_size-0x8568>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0204190:	1141                	addi	sp,sp,-16
ffffffffc0204192:	e406                	sd	ra,8(sp)
ffffffffc0204194:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0204196:	01066863          	bltu	a2,a6,ffffffffc02041a6 <insert_vma_struct+0x1c>
ffffffffc020419a:	a8b9                	j	ffffffffc02041f8 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc020419c:	fe87b683          	ld	a3,-24(a5)
ffffffffc02041a0:	04d66763          	bltu	a2,a3,ffffffffc02041ee <insert_vma_struct+0x64>
ffffffffc02041a4:	873e                	mv	a4,a5
ffffffffc02041a6:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc02041a8:	fef51ae3          	bne	a0,a5,ffffffffc020419c <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02041ac:	02a70463          	beq	a4,a0,ffffffffc02041d4 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02041b0:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02041b4:	fe873883          	ld	a7,-24(a4)
ffffffffc02041b8:	08d8f063          	bleu	a3,a7,ffffffffc0204238 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041bc:	04d66e63          	bltu	a2,a3,ffffffffc0204218 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc02041c0:	00f50a63          	beq	a0,a5,ffffffffc02041d4 <insert_vma_struct+0x4a>
ffffffffc02041c4:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041c8:	0506e863          	bltu	a3,a6,ffffffffc0204218 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02041cc:	ff07b603          	ld	a2,-16(a5)
ffffffffc02041d0:	02c6f263          	bleu	a2,a3,ffffffffc02041f4 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02041d4:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc02041d6:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02041d8:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02041dc:	e390                	sd	a2,0(a5)
ffffffffc02041de:	e710                	sd	a2,8(a4)
}
ffffffffc02041e0:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02041e2:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02041e4:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc02041e6:	2685                	addiw	a3,a3,1
ffffffffc02041e8:	d114                	sw	a3,32(a0)
}
ffffffffc02041ea:	0141                	addi	sp,sp,16
ffffffffc02041ec:	8082                	ret
    if (le_prev != list) {
ffffffffc02041ee:	fca711e3          	bne	a4,a0,ffffffffc02041b0 <insert_vma_struct+0x26>
ffffffffc02041f2:	bfd9                	j	ffffffffc02041c8 <insert_vma_struct+0x3e>
ffffffffc02041f4:	ebbff0ef          	jal	ra,ffffffffc02040ae <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02041f8:	00004697          	auipc	a3,0x4
ffffffffc02041fc:	f5068693          	addi	a3,a3,-176 # ffffffffc0208148 <default_pmm_manager+0xdb8>
ffffffffc0204200:	00003617          	auipc	a2,0x3
ffffffffc0204204:	a4860613          	addi	a2,a2,-1464 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0204208:	07400593          	li	a1,116
ffffffffc020420c:	00004517          	auipc	a0,0x4
ffffffffc0204210:	e3c50513          	addi	a0,a0,-452 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc0204214:	a70fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0204218:	00004697          	auipc	a3,0x4
ffffffffc020421c:	f7068693          	addi	a3,a3,-144 # ffffffffc0208188 <default_pmm_manager+0xdf8>
ffffffffc0204220:	00003617          	auipc	a2,0x3
ffffffffc0204224:	a2860613          	addi	a2,a2,-1496 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0204228:	06c00593          	li	a1,108
ffffffffc020422c:	00004517          	auipc	a0,0x4
ffffffffc0204230:	e1c50513          	addi	a0,a0,-484 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc0204234:	a50fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0204238:	00004697          	auipc	a3,0x4
ffffffffc020423c:	f3068693          	addi	a3,a3,-208 # ffffffffc0208168 <default_pmm_manager+0xdd8>
ffffffffc0204240:	00003617          	auipc	a2,0x3
ffffffffc0204244:	a0860613          	addi	a2,a2,-1528 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0204248:	06b00593          	li	a1,107
ffffffffc020424c:	00004517          	auipc	a0,0x4
ffffffffc0204250:	dfc50513          	addi	a0,a0,-516 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc0204254:	a30fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204258 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0204258:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc020425a:	1141                	addi	sp,sp,-16
ffffffffc020425c:	e406                	sd	ra,8(sp)
ffffffffc020425e:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0204260:	e78d                	bnez	a5,ffffffffc020428a <mm_destroy+0x32>
ffffffffc0204262:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0204264:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0204266:	00a40c63          	beq	s0,a0,ffffffffc020427e <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020426a:	6118                	ld	a4,0(a0)
ffffffffc020426c:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc020426e:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0204270:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0204272:	e398                	sd	a4,0(a5)
ffffffffc0204274:	aabfd0ef          	jal	ra,ffffffffc0201d1e <kfree>
    return listelm->next;
ffffffffc0204278:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020427a:	fea418e3          	bne	s0,a0,ffffffffc020426a <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc020427e:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0204280:	6402                	ld	s0,0(sp)
ffffffffc0204282:	60a2                	ld	ra,8(sp)
ffffffffc0204284:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0204286:	a99fd06f          	j	ffffffffc0201d1e <kfree>
    assert(mm_count(mm) == 0);
ffffffffc020428a:	00004697          	auipc	a3,0x4
ffffffffc020428e:	f1e68693          	addi	a3,a3,-226 # ffffffffc02081a8 <default_pmm_manager+0xe18>
ffffffffc0204292:	00003617          	auipc	a2,0x3
ffffffffc0204296:	9b660613          	addi	a2,a2,-1610 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc020429a:	09400593          	li	a1,148
ffffffffc020429e:	00004517          	auipc	a0,0x4
ffffffffc02042a2:	daa50513          	addi	a0,a0,-598 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc02042a6:	9defc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02042aa <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042aa:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc02042ac:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042ae:	17fd                	addi	a5,a5,-1
ffffffffc02042b0:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc02042b2:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042b4:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc02042b8:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042ba:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc02042bc:	fc06                	sd	ra,56(sp)
ffffffffc02042be:	f04a                	sd	s2,32(sp)
ffffffffc02042c0:	ec4e                	sd	s3,24(sp)
ffffffffc02042c2:	e852                	sd	s4,16(sp)
ffffffffc02042c4:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042c6:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc02042ca:	002007b7          	lui	a5,0x200
ffffffffc02042ce:	01047433          	and	s0,s0,a6
ffffffffc02042d2:	06f4e363          	bltu	s1,a5,ffffffffc0204338 <mm_map+0x8e>
ffffffffc02042d6:	0684f163          	bleu	s0,s1,ffffffffc0204338 <mm_map+0x8e>
ffffffffc02042da:	4785                	li	a5,1
ffffffffc02042dc:	07fe                	slli	a5,a5,0x1f
ffffffffc02042de:	0487ed63          	bltu	a5,s0,ffffffffc0204338 <mm_map+0x8e>
ffffffffc02042e2:	89aa                	mv	s3,a0
ffffffffc02042e4:	8a3a                	mv	s4,a4
ffffffffc02042e6:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02042e8:	c931                	beqz	a0,ffffffffc020433c <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc02042ea:	85a6                	mv	a1,s1
ffffffffc02042ec:	e61ff0ef          	jal	ra,ffffffffc020414c <find_vma>
ffffffffc02042f0:	c501                	beqz	a0,ffffffffc02042f8 <mm_map+0x4e>
ffffffffc02042f2:	651c                	ld	a5,8(a0)
ffffffffc02042f4:	0487e263          	bltu	a5,s0,ffffffffc0204338 <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02042f8:	03000513          	li	a0,48
ffffffffc02042fc:	967fd0ef          	jal	ra,ffffffffc0201c62 <kmalloc>
ffffffffc0204300:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0204302:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc0204304:	02090163          	beqz	s2,ffffffffc0204326 <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0204308:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc020430a:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc020430e:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0204312:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0204316:	85ca                	mv	a1,s2
ffffffffc0204318:	e73ff0ef          	jal	ra,ffffffffc020418a <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc020431c:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc020431e:	000a0463          	beqz	s4,ffffffffc0204326 <mm_map+0x7c>
        *vma_store = vma;
ffffffffc0204322:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0204326:	70e2                	ld	ra,56(sp)
ffffffffc0204328:	7442                	ld	s0,48(sp)
ffffffffc020432a:	74a2                	ld	s1,40(sp)
ffffffffc020432c:	7902                	ld	s2,32(sp)
ffffffffc020432e:	69e2                	ld	s3,24(sp)
ffffffffc0204330:	6a42                	ld	s4,16(sp)
ffffffffc0204332:	6aa2                	ld	s5,8(sp)
ffffffffc0204334:	6121                	addi	sp,sp,64
ffffffffc0204336:	8082                	ret
        return -E_INVAL;
ffffffffc0204338:	5575                	li	a0,-3
ffffffffc020433a:	b7f5                	j	ffffffffc0204326 <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc020433c:	00004697          	auipc	a3,0x4
ffffffffc0204340:	84468693          	addi	a3,a3,-1980 # ffffffffc0207b80 <default_pmm_manager+0x7f0>
ffffffffc0204344:	00003617          	auipc	a2,0x3
ffffffffc0204348:	90460613          	addi	a2,a2,-1788 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc020434c:	0a700593          	li	a1,167
ffffffffc0204350:	00004517          	auipc	a0,0x4
ffffffffc0204354:	cf850513          	addi	a0,a0,-776 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc0204358:	92cfc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020435c <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc020435c:	7139                	addi	sp,sp,-64
ffffffffc020435e:	fc06                	sd	ra,56(sp)
ffffffffc0204360:	f822                	sd	s0,48(sp)
ffffffffc0204362:	f426                	sd	s1,40(sp)
ffffffffc0204364:	f04a                	sd	s2,32(sp)
ffffffffc0204366:	ec4e                	sd	s3,24(sp)
ffffffffc0204368:	e852                	sd	s4,16(sp)
ffffffffc020436a:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc020436c:	c535                	beqz	a0,ffffffffc02043d8 <dup_mmap+0x7c>
ffffffffc020436e:	892a                	mv	s2,a0
ffffffffc0204370:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0204372:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0204374:	e59d                	bnez	a1,ffffffffc02043a2 <dup_mmap+0x46>
ffffffffc0204376:	a08d                	j	ffffffffc02043d8 <dup_mmap+0x7c>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0204378:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc020437a:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_exit_out_size+0x1f5580>
        insert_vma_struct(to, nvma);
ffffffffc020437e:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc0204380:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc0204384:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc0204388:	e03ff0ef          	jal	ra,ffffffffc020418a <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc020438c:	ff043683          	ld	a3,-16(s0)
ffffffffc0204390:	fe843603          	ld	a2,-24(s0)
ffffffffc0204394:	6c8c                	ld	a1,24(s1)
ffffffffc0204396:	01893503          	ld	a0,24(s2)
ffffffffc020439a:	4701                	li	a4,0
ffffffffc020439c:	d2ffe0ef          	jal	ra,ffffffffc02030ca <copy_range>
ffffffffc02043a0:	e105                	bnez	a0,ffffffffc02043c0 <dup_mmap+0x64>
    return listelm->prev;
ffffffffc02043a2:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc02043a4:	02848863          	beq	s1,s0,ffffffffc02043d4 <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02043a8:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02043ac:	fe843a83          	ld	s5,-24(s0)
ffffffffc02043b0:	ff043a03          	ld	s4,-16(s0)
ffffffffc02043b4:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02043b8:	8abfd0ef          	jal	ra,ffffffffc0201c62 <kmalloc>
ffffffffc02043bc:	87aa                	mv	a5,a0
    if (vma != NULL) {
ffffffffc02043be:	fd4d                	bnez	a0,ffffffffc0204378 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc02043c0:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02043c2:	70e2                	ld	ra,56(sp)
ffffffffc02043c4:	7442                	ld	s0,48(sp)
ffffffffc02043c6:	74a2                	ld	s1,40(sp)
ffffffffc02043c8:	7902                	ld	s2,32(sp)
ffffffffc02043ca:	69e2                	ld	s3,24(sp)
ffffffffc02043cc:	6a42                	ld	s4,16(sp)
ffffffffc02043ce:	6aa2                	ld	s5,8(sp)
ffffffffc02043d0:	6121                	addi	sp,sp,64
ffffffffc02043d2:	8082                	ret
    return 0;
ffffffffc02043d4:	4501                	li	a0,0
ffffffffc02043d6:	b7f5                	j	ffffffffc02043c2 <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc02043d8:	00004697          	auipc	a3,0x4
ffffffffc02043dc:	d3068693          	addi	a3,a3,-720 # ffffffffc0208108 <default_pmm_manager+0xd78>
ffffffffc02043e0:	00003617          	auipc	a2,0x3
ffffffffc02043e4:	86860613          	addi	a2,a2,-1944 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02043e8:	0c000593          	li	a1,192
ffffffffc02043ec:	00004517          	auipc	a0,0x4
ffffffffc02043f0:	c5c50513          	addi	a0,a0,-932 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc02043f4:	890fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02043f8 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc02043f8:	1101                	addi	sp,sp,-32
ffffffffc02043fa:	ec06                	sd	ra,24(sp)
ffffffffc02043fc:	e822                	sd	s0,16(sp)
ffffffffc02043fe:	e426                	sd	s1,8(sp)
ffffffffc0204400:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204402:	c531                	beqz	a0,ffffffffc020444e <exit_mmap+0x56>
ffffffffc0204404:	591c                	lw	a5,48(a0)
ffffffffc0204406:	84aa                	mv	s1,a0
ffffffffc0204408:	e3b9                	bnez	a5,ffffffffc020444e <exit_mmap+0x56>
    return listelm->next;
ffffffffc020440a:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc020440c:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0204410:	02850663          	beq	a0,s0,ffffffffc020443c <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204414:	ff043603          	ld	a2,-16(s0)
ffffffffc0204418:	fe843583          	ld	a1,-24(s0)
ffffffffc020441c:	854a                	mv	a0,s2
ffffffffc020441e:	d83fd0ef          	jal	ra,ffffffffc02021a0 <unmap_range>
ffffffffc0204422:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204424:	fe8498e3          	bne	s1,s0,ffffffffc0204414 <exit_mmap+0x1c>
ffffffffc0204428:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc020442a:	00848c63          	beq	s1,s0,ffffffffc0204442 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020442e:	ff043603          	ld	a2,-16(s0)
ffffffffc0204432:	fe843583          	ld	a1,-24(s0)
ffffffffc0204436:	854a                	mv	a0,s2
ffffffffc0204438:	e81fd0ef          	jal	ra,ffffffffc02022b8 <exit_range>
ffffffffc020443c:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc020443e:	fe8498e3          	bne	s1,s0,ffffffffc020442e <exit_mmap+0x36>
    }
}
ffffffffc0204442:	60e2                	ld	ra,24(sp)
ffffffffc0204444:	6442                	ld	s0,16(sp)
ffffffffc0204446:	64a2                	ld	s1,8(sp)
ffffffffc0204448:	6902                	ld	s2,0(sp)
ffffffffc020444a:	6105                	addi	sp,sp,32
ffffffffc020444c:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc020444e:	00004697          	auipc	a3,0x4
ffffffffc0204452:	cda68693          	addi	a3,a3,-806 # ffffffffc0208128 <default_pmm_manager+0xd98>
ffffffffc0204456:	00002617          	auipc	a2,0x2
ffffffffc020445a:	7f260613          	addi	a2,a2,2034 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc020445e:	0d600593          	li	a1,214
ffffffffc0204462:	00004517          	auipc	a0,0x4
ffffffffc0204466:	be650513          	addi	a0,a0,-1050 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc020446a:	81afc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020446e <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc020446e:	7139                	addi	sp,sp,-64
ffffffffc0204470:	f822                	sd	s0,48(sp)
ffffffffc0204472:	f426                	sd	s1,40(sp)
ffffffffc0204474:	fc06                	sd	ra,56(sp)
ffffffffc0204476:	f04a                	sd	s2,32(sp)
ffffffffc0204478:	ec4e                	sd	s3,24(sp)
ffffffffc020447a:	e852                	sd	s4,16(sp)
ffffffffc020447c:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc020447e:	c55ff0ef          	jal	ra,ffffffffc02040d2 <mm_create>
    assert(mm != NULL);
ffffffffc0204482:	842a                	mv	s0,a0
ffffffffc0204484:	03200493          	li	s1,50
ffffffffc0204488:	e919                	bnez	a0,ffffffffc020449e <vmm_init+0x30>
ffffffffc020448a:	a989                	j	ffffffffc02048dc <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc020448c:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc020448e:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204490:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0204494:	14ed                	addi	s1,s1,-5
ffffffffc0204496:	8522                	mv	a0,s0
ffffffffc0204498:	cf3ff0ef          	jal	ra,ffffffffc020418a <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc020449c:	c88d                	beqz	s1,ffffffffc02044ce <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020449e:	03000513          	li	a0,48
ffffffffc02044a2:	fc0fd0ef          	jal	ra,ffffffffc0201c62 <kmalloc>
ffffffffc02044a6:	85aa                	mv	a1,a0
ffffffffc02044a8:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02044ac:	f165                	bnez	a0,ffffffffc020448c <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc02044ae:	00003697          	auipc	a3,0x3
ffffffffc02044b2:	70a68693          	addi	a3,a3,1802 # ffffffffc0207bb8 <default_pmm_manager+0x828>
ffffffffc02044b6:	00002617          	auipc	a2,0x2
ffffffffc02044ba:	79260613          	addi	a2,a2,1938 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02044be:	11300593          	li	a1,275
ffffffffc02044c2:	00004517          	auipc	a0,0x4
ffffffffc02044c6:	b8650513          	addi	a0,a0,-1146 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc02044ca:	fbbfb0ef          	jal	ra,ffffffffc0200484 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc02044ce:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02044d2:	1f900913          	li	s2,505
ffffffffc02044d6:	a819                	j	ffffffffc02044ec <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc02044d8:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02044da:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02044dc:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02044e0:	0495                	addi	s1,s1,5
ffffffffc02044e2:	8522                	mv	a0,s0
ffffffffc02044e4:	ca7ff0ef          	jal	ra,ffffffffc020418a <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02044e8:	03248a63          	beq	s1,s2,ffffffffc020451c <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02044ec:	03000513          	li	a0,48
ffffffffc02044f0:	f72fd0ef          	jal	ra,ffffffffc0201c62 <kmalloc>
ffffffffc02044f4:	85aa                	mv	a1,a0
ffffffffc02044f6:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02044fa:	fd79                	bnez	a0,ffffffffc02044d8 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc02044fc:	00003697          	auipc	a3,0x3
ffffffffc0204500:	6bc68693          	addi	a3,a3,1724 # ffffffffc0207bb8 <default_pmm_manager+0x828>
ffffffffc0204504:	00002617          	auipc	a2,0x2
ffffffffc0204508:	74460613          	addi	a2,a2,1860 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc020450c:	11900593          	li	a1,281
ffffffffc0204510:	00004517          	auipc	a0,0x4
ffffffffc0204514:	b3850513          	addi	a0,a0,-1224 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc0204518:	f6dfb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc020451c:	6418                	ld	a4,8(s0)
ffffffffc020451e:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0204520:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0204524:	2ee40063          	beq	s0,a4,ffffffffc0204804 <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0204528:	fe873603          	ld	a2,-24(a4)
ffffffffc020452c:	ffe78693          	addi	a3,a5,-2
ffffffffc0204530:	24d61a63          	bne	a2,a3,ffffffffc0204784 <vmm_init+0x316>
ffffffffc0204534:	ff073683          	ld	a3,-16(a4)
ffffffffc0204538:	24f69663          	bne	a3,a5,ffffffffc0204784 <vmm_init+0x316>
ffffffffc020453c:	0795                	addi	a5,a5,5
ffffffffc020453e:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0204540:	feb792e3          	bne	a5,a1,ffffffffc0204524 <vmm_init+0xb6>
ffffffffc0204544:	491d                	li	s2,7
ffffffffc0204546:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0204548:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc020454c:	85a6                	mv	a1,s1
ffffffffc020454e:	8522                	mv	a0,s0
ffffffffc0204550:	bfdff0ef          	jal	ra,ffffffffc020414c <find_vma>
ffffffffc0204554:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0204556:	30050763          	beqz	a0,ffffffffc0204864 <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc020455a:	00148593          	addi	a1,s1,1
ffffffffc020455e:	8522                	mv	a0,s0
ffffffffc0204560:	bedff0ef          	jal	ra,ffffffffc020414c <find_vma>
ffffffffc0204564:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0204566:	2c050f63          	beqz	a0,ffffffffc0204844 <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc020456a:	85ca                	mv	a1,s2
ffffffffc020456c:	8522                	mv	a0,s0
ffffffffc020456e:	bdfff0ef          	jal	ra,ffffffffc020414c <find_vma>
        assert(vma3 == NULL);
ffffffffc0204572:	2a051963          	bnez	a0,ffffffffc0204824 <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0204576:	00348593          	addi	a1,s1,3
ffffffffc020457a:	8522                	mv	a0,s0
ffffffffc020457c:	bd1ff0ef          	jal	ra,ffffffffc020414c <find_vma>
        assert(vma4 == NULL);
ffffffffc0204580:	32051263          	bnez	a0,ffffffffc02048a4 <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0204584:	00448593          	addi	a1,s1,4
ffffffffc0204588:	8522                	mv	a0,s0
ffffffffc020458a:	bc3ff0ef          	jal	ra,ffffffffc020414c <find_vma>
        assert(vma5 == NULL);
ffffffffc020458e:	2e051b63          	bnez	a0,ffffffffc0204884 <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0204592:	008a3783          	ld	a5,8(s4)
ffffffffc0204596:	20979763          	bne	a5,s1,ffffffffc02047a4 <vmm_init+0x336>
ffffffffc020459a:	010a3783          	ld	a5,16(s4)
ffffffffc020459e:	21279363          	bne	a5,s2,ffffffffc02047a4 <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02045a2:	0089b783          	ld	a5,8(s3)
ffffffffc02045a6:	20979f63          	bne	a5,s1,ffffffffc02047c4 <vmm_init+0x356>
ffffffffc02045aa:	0109b783          	ld	a5,16(s3)
ffffffffc02045ae:	21279b63          	bne	a5,s2,ffffffffc02047c4 <vmm_init+0x356>
ffffffffc02045b2:	0495                	addi	s1,s1,5
ffffffffc02045b4:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02045b6:	f9549be3          	bne	s1,s5,ffffffffc020454c <vmm_init+0xde>
ffffffffc02045ba:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02045bc:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02045be:	85a6                	mv	a1,s1
ffffffffc02045c0:	8522                	mv	a0,s0
ffffffffc02045c2:	b8bff0ef          	jal	ra,ffffffffc020414c <find_vma>
ffffffffc02045c6:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc02045ca:	c90d                	beqz	a0,ffffffffc02045fc <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02045cc:	6914                	ld	a3,16(a0)
ffffffffc02045ce:	6510                	ld	a2,8(a0)
ffffffffc02045d0:	00004517          	auipc	a0,0x4
ffffffffc02045d4:	cf050513          	addi	a0,a0,-784 # ffffffffc02082c0 <default_pmm_manager+0xf30>
ffffffffc02045d8:	bb7fb0ef          	jal	ra,ffffffffc020018e <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02045dc:	00004697          	auipc	a3,0x4
ffffffffc02045e0:	d0c68693          	addi	a3,a3,-756 # ffffffffc02082e8 <default_pmm_manager+0xf58>
ffffffffc02045e4:	00002617          	auipc	a2,0x2
ffffffffc02045e8:	66460613          	addi	a2,a2,1636 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02045ec:	13b00593          	li	a1,315
ffffffffc02045f0:	00004517          	auipc	a0,0x4
ffffffffc02045f4:	a5850513          	addi	a0,a0,-1448 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc02045f8:	e8dfb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc02045fc:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc02045fe:	fd2490e3          	bne	s1,s2,ffffffffc02045be <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0204602:	8522                	mv	a0,s0
ffffffffc0204604:	c55ff0ef          	jal	ra,ffffffffc0204258 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0204608:	00004517          	auipc	a0,0x4
ffffffffc020460c:	cf850513          	addi	a0,a0,-776 # ffffffffc0208300 <default_pmm_manager+0xf70>
ffffffffc0204610:	b7ffb0ef          	jal	ra,ffffffffc020018e <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0204614:	919fd0ef          	jal	ra,ffffffffc0201f2c <nr_free_pages>
ffffffffc0204618:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc020461a:	ab9ff0ef          	jal	ra,ffffffffc02040d2 <mm_create>
ffffffffc020461e:	000a8797          	auipc	a5,0xa8
ffffffffc0204622:	04a7b523          	sd	a0,74(a5) # ffffffffc02ac668 <check_mm_struct>
ffffffffc0204626:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0204628:	36050663          	beqz	a0,ffffffffc0204994 <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020462c:	000a8797          	auipc	a5,0xa8
ffffffffc0204630:	ee478793          	addi	a5,a5,-284 # ffffffffc02ac510 <boot_pgdir>
ffffffffc0204634:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0204638:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020463c:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0204640:	2c079e63          	bnez	a5,ffffffffc020491c <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204644:	03000513          	li	a0,48
ffffffffc0204648:	e1afd0ef          	jal	ra,ffffffffc0201c62 <kmalloc>
ffffffffc020464c:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc020464e:	18050b63          	beqz	a0,ffffffffc02047e4 <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0204652:	002007b7          	lui	a5,0x200
ffffffffc0204656:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0204658:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc020465a:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc020465c:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc020465e:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0204660:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0204664:	b27ff0ef          	jal	ra,ffffffffc020418a <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0204668:	10000593          	li	a1,256
ffffffffc020466c:	8526                	mv	a0,s1
ffffffffc020466e:	adfff0ef          	jal	ra,ffffffffc020414c <find_vma>
ffffffffc0204672:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc0204676:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc020467a:	2ca41163          	bne	s0,a0,ffffffffc020493c <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc020467e:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f5578>
        sum += i;
ffffffffc0204682:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0204684:	fee79de3          	bne	a5,a4,ffffffffc020467e <vmm_init+0x210>
        sum += i;
ffffffffc0204688:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc020468a:	10000793          	li	a5,256
        sum += i;
ffffffffc020468e:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x8222>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0204692:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0204696:	0007c683          	lbu	a3,0(a5)
ffffffffc020469a:	0785                	addi	a5,a5,1
ffffffffc020469c:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc020469e:	fec79ce3          	bne	a5,a2,ffffffffc0204696 <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc02046a2:	2c071963          	bnez	a4,ffffffffc0204974 <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc02046a6:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02046aa:	000a8a97          	auipc	s5,0xa8
ffffffffc02046ae:	e6ea8a93          	addi	s5,s5,-402 # ffffffffc02ac518 <npage>
ffffffffc02046b2:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02046b6:	078a                	slli	a5,a5,0x2
ffffffffc02046b8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02046ba:	20e7f563          	bleu	a4,a5,ffffffffc02048c4 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02046be:	00004697          	auipc	a3,0x4
ffffffffc02046c2:	68268693          	addi	a3,a3,1666 # ffffffffc0208d40 <nbase>
ffffffffc02046c6:	0006ba03          	ld	s4,0(a3)
ffffffffc02046ca:	414786b3          	sub	a3,a5,s4
ffffffffc02046ce:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02046d0:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02046d2:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc02046d4:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc02046d6:	83b1                	srli	a5,a5,0xc
ffffffffc02046d8:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02046da:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02046dc:	28e7f063          	bleu	a4,a5,ffffffffc020495c <vmm_init+0x4ee>
ffffffffc02046e0:	000a8797          	auipc	a5,0xa8
ffffffffc02046e4:	e9878793          	addi	a5,a5,-360 # ffffffffc02ac578 <va_pa_offset>
ffffffffc02046e8:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02046ea:	4581                	li	a1,0
ffffffffc02046ec:	854a                	mv	a0,s2
ffffffffc02046ee:	9436                	add	s0,s0,a3
ffffffffc02046f0:	e1ffd0ef          	jal	ra,ffffffffc020250e <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02046f4:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02046f6:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02046fa:	078a                	slli	a5,a5,0x2
ffffffffc02046fc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02046fe:	1ce7f363          	bleu	a4,a5,ffffffffc02048c4 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0204702:	000a8417          	auipc	s0,0xa8
ffffffffc0204706:	e8640413          	addi	s0,s0,-378 # ffffffffc02ac588 <pages>
ffffffffc020470a:	6008                	ld	a0,0(s0)
ffffffffc020470c:	414787b3          	sub	a5,a5,s4
ffffffffc0204710:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0204712:	953e                	add	a0,a0,a5
ffffffffc0204714:	4585                	li	a1,1
ffffffffc0204716:	fd0fd0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020471a:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020471e:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204722:	078a                	slli	a5,a5,0x2
ffffffffc0204724:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204726:	18e7ff63          	bleu	a4,a5,ffffffffc02048c4 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc020472a:	6008                	ld	a0,0(s0)
ffffffffc020472c:	414787b3          	sub	a5,a5,s4
ffffffffc0204730:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0204732:	4585                	li	a1,1
ffffffffc0204734:	953e                	add	a0,a0,a5
ffffffffc0204736:	fb0fd0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    pgdir[0] = 0;
ffffffffc020473a:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc020473e:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0204742:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0204746:	8526                	mv	a0,s1
ffffffffc0204748:	b11ff0ef          	jal	ra,ffffffffc0204258 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc020474c:	000a8797          	auipc	a5,0xa8
ffffffffc0204750:	f007be23          	sd	zero,-228(a5) # ffffffffc02ac668 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0204754:	fd8fd0ef          	jal	ra,ffffffffc0201f2c <nr_free_pages>
ffffffffc0204758:	1aa99263          	bne	s3,a0,ffffffffc02048fc <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc020475c:	00004517          	auipc	a0,0x4
ffffffffc0204760:	c3450513          	addi	a0,a0,-972 # ffffffffc0208390 <default_pmm_manager+0x1000>
ffffffffc0204764:	a2bfb0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0204768:	7442                	ld	s0,48(sp)
ffffffffc020476a:	70e2                	ld	ra,56(sp)
ffffffffc020476c:	74a2                	ld	s1,40(sp)
ffffffffc020476e:	7902                	ld	s2,32(sp)
ffffffffc0204770:	69e2                	ld	s3,24(sp)
ffffffffc0204772:	6a42                	ld	s4,16(sp)
ffffffffc0204774:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0204776:	00004517          	auipc	a0,0x4
ffffffffc020477a:	c3a50513          	addi	a0,a0,-966 # ffffffffc02083b0 <default_pmm_manager+0x1020>
}
ffffffffc020477e:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0204780:	a0ffb06f          	j	ffffffffc020018e <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0204784:	00004697          	auipc	a3,0x4
ffffffffc0204788:	a5468693          	addi	a3,a3,-1452 # ffffffffc02081d8 <default_pmm_manager+0xe48>
ffffffffc020478c:	00002617          	auipc	a2,0x2
ffffffffc0204790:	4bc60613          	addi	a2,a2,1212 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0204794:	12200593          	li	a1,290
ffffffffc0204798:	00004517          	auipc	a0,0x4
ffffffffc020479c:	8b050513          	addi	a0,a0,-1872 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc02047a0:	ce5fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02047a4:	00004697          	auipc	a3,0x4
ffffffffc02047a8:	abc68693          	addi	a3,a3,-1348 # ffffffffc0208260 <default_pmm_manager+0xed0>
ffffffffc02047ac:	00002617          	auipc	a2,0x2
ffffffffc02047b0:	49c60613          	addi	a2,a2,1180 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02047b4:	13200593          	li	a1,306
ffffffffc02047b8:	00004517          	auipc	a0,0x4
ffffffffc02047bc:	89050513          	addi	a0,a0,-1904 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc02047c0:	cc5fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02047c4:	00004697          	auipc	a3,0x4
ffffffffc02047c8:	acc68693          	addi	a3,a3,-1332 # ffffffffc0208290 <default_pmm_manager+0xf00>
ffffffffc02047cc:	00002617          	auipc	a2,0x2
ffffffffc02047d0:	47c60613          	addi	a2,a2,1148 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02047d4:	13300593          	li	a1,307
ffffffffc02047d8:	00004517          	auipc	a0,0x4
ffffffffc02047dc:	87050513          	addi	a0,a0,-1936 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc02047e0:	ca5fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(vma != NULL);
ffffffffc02047e4:	00003697          	auipc	a3,0x3
ffffffffc02047e8:	3d468693          	addi	a3,a3,980 # ffffffffc0207bb8 <default_pmm_manager+0x828>
ffffffffc02047ec:	00002617          	auipc	a2,0x2
ffffffffc02047f0:	45c60613          	addi	a2,a2,1116 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02047f4:	15200593          	li	a1,338
ffffffffc02047f8:	00004517          	auipc	a0,0x4
ffffffffc02047fc:	85050513          	addi	a0,a0,-1968 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc0204800:	c85fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0204804:	00004697          	auipc	a3,0x4
ffffffffc0204808:	9bc68693          	addi	a3,a3,-1604 # ffffffffc02081c0 <default_pmm_manager+0xe30>
ffffffffc020480c:	00002617          	auipc	a2,0x2
ffffffffc0204810:	43c60613          	addi	a2,a2,1084 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0204814:	12000593          	li	a1,288
ffffffffc0204818:	00004517          	auipc	a0,0x4
ffffffffc020481c:	83050513          	addi	a0,a0,-2000 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc0204820:	c65fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma3 == NULL);
ffffffffc0204824:	00004697          	auipc	a3,0x4
ffffffffc0204828:	a0c68693          	addi	a3,a3,-1524 # ffffffffc0208230 <default_pmm_manager+0xea0>
ffffffffc020482c:	00002617          	auipc	a2,0x2
ffffffffc0204830:	41c60613          	addi	a2,a2,1052 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0204834:	12c00593          	li	a1,300
ffffffffc0204838:	00004517          	auipc	a0,0x4
ffffffffc020483c:	81050513          	addi	a0,a0,-2032 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc0204840:	c45fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma2 != NULL);
ffffffffc0204844:	00004697          	auipc	a3,0x4
ffffffffc0204848:	9dc68693          	addi	a3,a3,-1572 # ffffffffc0208220 <default_pmm_manager+0xe90>
ffffffffc020484c:	00002617          	auipc	a2,0x2
ffffffffc0204850:	3fc60613          	addi	a2,a2,1020 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0204854:	12a00593          	li	a1,298
ffffffffc0204858:	00003517          	auipc	a0,0x3
ffffffffc020485c:	7f050513          	addi	a0,a0,2032 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc0204860:	c25fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma1 != NULL);
ffffffffc0204864:	00004697          	auipc	a3,0x4
ffffffffc0204868:	9ac68693          	addi	a3,a3,-1620 # ffffffffc0208210 <default_pmm_manager+0xe80>
ffffffffc020486c:	00002617          	auipc	a2,0x2
ffffffffc0204870:	3dc60613          	addi	a2,a2,988 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0204874:	12800593          	li	a1,296
ffffffffc0204878:	00003517          	auipc	a0,0x3
ffffffffc020487c:	7d050513          	addi	a0,a0,2000 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc0204880:	c05fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma5 == NULL);
ffffffffc0204884:	00004697          	auipc	a3,0x4
ffffffffc0204888:	9cc68693          	addi	a3,a3,-1588 # ffffffffc0208250 <default_pmm_manager+0xec0>
ffffffffc020488c:	00002617          	auipc	a2,0x2
ffffffffc0204890:	3bc60613          	addi	a2,a2,956 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0204894:	13000593          	li	a1,304
ffffffffc0204898:	00003517          	auipc	a0,0x3
ffffffffc020489c:	7b050513          	addi	a0,a0,1968 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc02048a0:	be5fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma4 == NULL);
ffffffffc02048a4:	00004697          	auipc	a3,0x4
ffffffffc02048a8:	99c68693          	addi	a3,a3,-1636 # ffffffffc0208240 <default_pmm_manager+0xeb0>
ffffffffc02048ac:	00002617          	auipc	a2,0x2
ffffffffc02048b0:	39c60613          	addi	a2,a2,924 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02048b4:	12e00593          	li	a1,302
ffffffffc02048b8:	00003517          	auipc	a0,0x3
ffffffffc02048bc:	79050513          	addi	a0,a0,1936 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc02048c0:	bc5fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02048c4:	00003617          	auipc	a2,0x3
ffffffffc02048c8:	b7c60613          	addi	a2,a2,-1156 # ffffffffc0207440 <default_pmm_manager+0xb0>
ffffffffc02048cc:	06200593          	li	a1,98
ffffffffc02048d0:	00003517          	auipc	a0,0x3
ffffffffc02048d4:	b3850513          	addi	a0,a0,-1224 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc02048d8:	badfb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(mm != NULL);
ffffffffc02048dc:	00003697          	auipc	a3,0x3
ffffffffc02048e0:	2a468693          	addi	a3,a3,676 # ffffffffc0207b80 <default_pmm_manager+0x7f0>
ffffffffc02048e4:	00002617          	auipc	a2,0x2
ffffffffc02048e8:	36460613          	addi	a2,a2,868 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02048ec:	10c00593          	li	a1,268
ffffffffc02048f0:	00003517          	auipc	a0,0x3
ffffffffc02048f4:	75850513          	addi	a0,a0,1880 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc02048f8:	b8dfb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02048fc:	00004697          	auipc	a3,0x4
ffffffffc0204900:	a6c68693          	addi	a3,a3,-1428 # ffffffffc0208368 <default_pmm_manager+0xfd8>
ffffffffc0204904:	00002617          	auipc	a2,0x2
ffffffffc0204908:	34460613          	addi	a2,a2,836 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc020490c:	17000593          	li	a1,368
ffffffffc0204910:	00003517          	auipc	a0,0x3
ffffffffc0204914:	73850513          	addi	a0,a0,1848 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc0204918:	b6dfb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir[0] == 0);
ffffffffc020491c:	00003697          	auipc	a3,0x3
ffffffffc0204920:	28c68693          	addi	a3,a3,652 # ffffffffc0207ba8 <default_pmm_manager+0x818>
ffffffffc0204924:	00002617          	auipc	a2,0x2
ffffffffc0204928:	32460613          	addi	a2,a2,804 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc020492c:	14f00593          	li	a1,335
ffffffffc0204930:	00003517          	auipc	a0,0x3
ffffffffc0204934:	71850513          	addi	a0,a0,1816 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc0204938:	b4dfb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc020493c:	00004697          	auipc	a3,0x4
ffffffffc0204940:	9fc68693          	addi	a3,a3,-1540 # ffffffffc0208338 <default_pmm_manager+0xfa8>
ffffffffc0204944:	00002617          	auipc	a2,0x2
ffffffffc0204948:	30460613          	addi	a2,a2,772 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc020494c:	15700593          	li	a1,343
ffffffffc0204950:	00003517          	auipc	a0,0x3
ffffffffc0204954:	6f850513          	addi	a0,a0,1784 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc0204958:	b2dfb0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc020495c:	00003617          	auipc	a2,0x3
ffffffffc0204960:	a8460613          	addi	a2,a2,-1404 # ffffffffc02073e0 <default_pmm_manager+0x50>
ffffffffc0204964:	06900593          	li	a1,105
ffffffffc0204968:	00003517          	auipc	a0,0x3
ffffffffc020496c:	aa050513          	addi	a0,a0,-1376 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc0204970:	b15fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(sum == 0);
ffffffffc0204974:	00004697          	auipc	a3,0x4
ffffffffc0204978:	9e468693          	addi	a3,a3,-1564 # ffffffffc0208358 <default_pmm_manager+0xfc8>
ffffffffc020497c:	00002617          	auipc	a2,0x2
ffffffffc0204980:	2cc60613          	addi	a2,a2,716 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0204984:	16300593          	li	a1,355
ffffffffc0204988:	00003517          	auipc	a0,0x3
ffffffffc020498c:	6c050513          	addi	a0,a0,1728 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc0204990:	af5fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0204994:	00004697          	auipc	a3,0x4
ffffffffc0204998:	98c68693          	addi	a3,a3,-1652 # ffffffffc0208320 <default_pmm_manager+0xf90>
ffffffffc020499c:	00002617          	auipc	a2,0x2
ffffffffc02049a0:	2ac60613          	addi	a2,a2,684 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02049a4:	14b00593          	li	a1,331
ffffffffc02049a8:	00003517          	auipc	a0,0x3
ffffffffc02049ac:	6a050513          	addi	a0,a0,1696 # ffffffffc0208048 <default_pmm_manager+0xcb8>
ffffffffc02049b0:	ad5fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02049b4 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02049b4:	7139                	addi	sp,sp,-64
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02049b6:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02049b8:	f822                	sd	s0,48(sp)
ffffffffc02049ba:	f426                	sd	s1,40(sp)
ffffffffc02049bc:	fc06                	sd	ra,56(sp)
ffffffffc02049be:	f04a                	sd	s2,32(sp)
ffffffffc02049c0:	ec4e                	sd	s3,24(sp)
ffffffffc02049c2:	8432                	mv	s0,a2
ffffffffc02049c4:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02049c6:	f86ff0ef          	jal	ra,ffffffffc020414c <find_vma>

    pgfault_num++;
ffffffffc02049ca:	000a8797          	auipc	a5,0xa8
ffffffffc02049ce:	b6278793          	addi	a5,a5,-1182 # ffffffffc02ac52c <pgfault_num>
ffffffffc02049d2:	439c                	lw	a5,0(a5)
ffffffffc02049d4:	2785                	addiw	a5,a5,1
ffffffffc02049d6:	000a8717          	auipc	a4,0xa8
ffffffffc02049da:	b4f72b23          	sw	a5,-1194(a4) # ffffffffc02ac52c <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02049de:	c555                	beqz	a0,ffffffffc0204a8a <do_pgfault+0xd6>
ffffffffc02049e0:	651c                	ld	a5,8(a0)
ffffffffc02049e2:	0af46463          	bltu	s0,a5,ffffffffc0204a8a <do_pgfault+0xd6>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02049e6:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02049e8:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02049ea:	8b89                	andi	a5,a5,2
ffffffffc02049ec:	e3a5                	bnez	a5,ffffffffc0204a4c <do_pgfault+0x98>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02049ee:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02049f0:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02049f2:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02049f4:	85a2                	mv	a1,s0
ffffffffc02049f6:	4605                	li	a2,1
ffffffffc02049f8:	d74fd0ef          	jal	ra,ffffffffc0201f6c <get_pte>
ffffffffc02049fc:	c945                	beqz	a0,ffffffffc0204aac <do_pgfault+0xf8>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc02049fe:	610c                	ld	a1,0(a0)
ffffffffc0204a00:	c5b5                	beqz	a1,ffffffffc0204a6c <do_pgfault+0xb8>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0204a02:	000a8797          	auipc	a5,0xa8
ffffffffc0204a06:	b2678793          	addi	a5,a5,-1242 # ffffffffc02ac528 <swap_init_ok>
ffffffffc0204a0a:	439c                	lw	a5,0(a5)
ffffffffc0204a0c:	2781                	sext.w	a5,a5
ffffffffc0204a0e:	c7d9                	beqz	a5,ffffffffc0204a9c <do_pgfault+0xe8>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            ret = swap_in(mm, addr, &page);
ffffffffc0204a10:	0030                	addi	a2,sp,8
ffffffffc0204a12:	85a2                	mv	a1,s0
ffffffffc0204a14:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0204a16:	e402                	sd	zero,8(sp)
            ret = swap_in(mm, addr, &page);
ffffffffc0204a18:	a34ff0ef          	jal	ra,ffffffffc0203c4c <swap_in>
ffffffffc0204a1c:	892a                	mv	s2,a0
            if(ret!=0){
ffffffffc0204a1e:	e90d                	bnez	a0,ffffffffc0204a50 <do_pgfault+0x9c>
                cprintf("swap_in failed\n");
                goto failed;
            }
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc0204a20:	65a2                	ld	a1,8(sp)
ffffffffc0204a22:	6c88                	ld	a0,24(s1)
ffffffffc0204a24:	86ce                	mv	a3,s3
ffffffffc0204a26:	8622                	mv	a2,s0
ffffffffc0204a28:	b5bfd0ef          	jal	ra,ffffffffc0202582 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0204a2c:	6622                	ld	a2,8(sp)
ffffffffc0204a2e:	4685                	li	a3,1
ffffffffc0204a30:	85a2                	mv	a1,s0
ffffffffc0204a32:	8526                	mv	a0,s1
ffffffffc0204a34:	8f4ff0ef          	jal	ra,ffffffffc0203b28 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0204a38:	67a2                	ld	a5,8(sp)
ffffffffc0204a3a:	ff80                	sd	s0,56(a5)
        }
   }
   ret = 0;
failed:
    return ret;
}
ffffffffc0204a3c:	70e2                	ld	ra,56(sp)
ffffffffc0204a3e:	7442                	ld	s0,48(sp)
ffffffffc0204a40:	854a                	mv	a0,s2
ffffffffc0204a42:	74a2                	ld	s1,40(sp)
ffffffffc0204a44:	7902                	ld	s2,32(sp)
ffffffffc0204a46:	69e2                	ld	s3,24(sp)
ffffffffc0204a48:	6121                	addi	sp,sp,64
ffffffffc0204a4a:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0204a4c:	49dd                	li	s3,23
ffffffffc0204a4e:	b745                	j	ffffffffc02049ee <do_pgfault+0x3a>
                cprintf("swap_in failed\n");
ffffffffc0204a50:	00003517          	auipc	a0,0x3
ffffffffc0204a54:	68050513          	addi	a0,a0,1664 # ffffffffc02080d0 <default_pmm_manager+0xd40>
ffffffffc0204a58:	f36fb0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0204a5c:	70e2                	ld	ra,56(sp)
ffffffffc0204a5e:	7442                	ld	s0,48(sp)
ffffffffc0204a60:	854a                	mv	a0,s2
ffffffffc0204a62:	74a2                	ld	s1,40(sp)
ffffffffc0204a64:	7902                	ld	s2,32(sp)
ffffffffc0204a66:	69e2                	ld	s3,24(sp)
ffffffffc0204a68:	6121                	addi	sp,sp,64
ffffffffc0204a6a:	8082                	ret
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204a6c:	6c88                	ld	a0,24(s1)
ffffffffc0204a6e:	864e                	mv	a2,s3
ffffffffc0204a70:	85a2                	mv	a1,s0
ffffffffc0204a72:	893fe0ef          	jal	ra,ffffffffc0203304 <pgdir_alloc_page>
   ret = 0;
ffffffffc0204a76:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204a78:	f171                	bnez	a0,ffffffffc0204a3c <do_pgfault+0x88>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204a7a:	00003517          	auipc	a0,0x3
ffffffffc0204a7e:	62e50513          	addi	a0,a0,1582 # ffffffffc02080a8 <default_pmm_manager+0xd18>
ffffffffc0204a82:	f0cfb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a86:	5971                	li	s2,-4
            goto failed;
ffffffffc0204a88:	bf55                	j	ffffffffc0204a3c <do_pgfault+0x88>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204a8a:	85a2                	mv	a1,s0
ffffffffc0204a8c:	00003517          	auipc	a0,0x3
ffffffffc0204a90:	5cc50513          	addi	a0,a0,1484 # ffffffffc0208058 <default_pmm_manager+0xcc8>
ffffffffc0204a94:	efafb0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = -E_INVAL;
ffffffffc0204a98:	5975                	li	s2,-3
        goto failed;
ffffffffc0204a9a:	b74d                	j	ffffffffc0204a3c <do_pgfault+0x88>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0204a9c:	00003517          	auipc	a0,0x3
ffffffffc0204aa0:	64450513          	addi	a0,a0,1604 # ffffffffc02080e0 <default_pmm_manager+0xd50>
ffffffffc0204aa4:	eeafb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204aa8:	5971                	li	s2,-4
            goto failed;
ffffffffc0204aaa:	bf49                	j	ffffffffc0204a3c <do_pgfault+0x88>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204aac:	00003517          	auipc	a0,0x3
ffffffffc0204ab0:	5dc50513          	addi	a0,a0,1500 # ffffffffc0208088 <default_pmm_manager+0xcf8>
ffffffffc0204ab4:	edafb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204ab8:	5971                	li	s2,-4
        goto failed;
ffffffffc0204aba:	b749                	j	ffffffffc0204a3c <do_pgfault+0x88>

ffffffffc0204abc <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0204abc:	7179                	addi	sp,sp,-48
ffffffffc0204abe:	f022                	sd	s0,32(sp)
ffffffffc0204ac0:	f406                	sd	ra,40(sp)
ffffffffc0204ac2:	ec26                	sd	s1,24(sp)
ffffffffc0204ac4:	e84a                	sd	s2,16(sp)
ffffffffc0204ac6:	e44e                	sd	s3,8(sp)
ffffffffc0204ac8:	e052                	sd	s4,0(sp)
ffffffffc0204aca:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0204acc:	c135                	beqz	a0,ffffffffc0204b30 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0204ace:	002007b7          	lui	a5,0x200
ffffffffc0204ad2:	04f5e663          	bltu	a1,a5,ffffffffc0204b1e <user_mem_check+0x62>
ffffffffc0204ad6:	00c584b3          	add	s1,a1,a2
ffffffffc0204ada:	0495f263          	bleu	s1,a1,ffffffffc0204b1e <user_mem_check+0x62>
ffffffffc0204ade:	4785                	li	a5,1
ffffffffc0204ae0:	07fe                	slli	a5,a5,0x1f
ffffffffc0204ae2:	0297ee63          	bltu	a5,s1,ffffffffc0204b1e <user_mem_check+0x62>
ffffffffc0204ae6:	892a                	mv	s2,a0
ffffffffc0204ae8:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204aea:	6a05                	lui	s4,0x1
ffffffffc0204aec:	a821                	j	ffffffffc0204b04 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204aee:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204af2:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204af4:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204af6:	c685                	beqz	a3,ffffffffc0204b1e <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204af8:	c399                	beqz	a5,ffffffffc0204afe <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204afa:	02e46263          	bltu	s0,a4,ffffffffc0204b1e <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0204afe:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0204b00:	04947663          	bleu	s1,s0,ffffffffc0204b4c <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0204b04:	85a2                	mv	a1,s0
ffffffffc0204b06:	854a                	mv	a0,s2
ffffffffc0204b08:	e44ff0ef          	jal	ra,ffffffffc020414c <find_vma>
ffffffffc0204b0c:	c909                	beqz	a0,ffffffffc0204b1e <user_mem_check+0x62>
ffffffffc0204b0e:	6518                	ld	a4,8(a0)
ffffffffc0204b10:	00e46763          	bltu	s0,a4,ffffffffc0204b1e <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204b14:	4d1c                	lw	a5,24(a0)
ffffffffc0204b16:	fc099ce3          	bnez	s3,ffffffffc0204aee <user_mem_check+0x32>
ffffffffc0204b1a:	8b85                	andi	a5,a5,1
ffffffffc0204b1c:	f3ed                	bnez	a5,ffffffffc0204afe <user_mem_check+0x42>
            return 0;
ffffffffc0204b1e:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0204b20:	70a2                	ld	ra,40(sp)
ffffffffc0204b22:	7402                	ld	s0,32(sp)
ffffffffc0204b24:	64e2                	ld	s1,24(sp)
ffffffffc0204b26:	6942                	ld	s2,16(sp)
ffffffffc0204b28:	69a2                	ld	s3,8(sp)
ffffffffc0204b2a:	6a02                	ld	s4,0(sp)
ffffffffc0204b2c:	6145                	addi	sp,sp,48
ffffffffc0204b2e:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204b30:	c02007b7          	lui	a5,0xc0200
ffffffffc0204b34:	4501                	li	a0,0
ffffffffc0204b36:	fef5e5e3          	bltu	a1,a5,ffffffffc0204b20 <user_mem_check+0x64>
ffffffffc0204b3a:	962e                	add	a2,a2,a1
ffffffffc0204b3c:	fec5f2e3          	bleu	a2,a1,ffffffffc0204b20 <user_mem_check+0x64>
ffffffffc0204b40:	c8000537          	lui	a0,0xc8000
ffffffffc0204b44:	0505                	addi	a0,a0,1
ffffffffc0204b46:	00a63533          	sltu	a0,a2,a0
ffffffffc0204b4a:	bfd9                	j	ffffffffc0204b20 <user_mem_check+0x64>
        return 1;
ffffffffc0204b4c:	4505                	li	a0,1
ffffffffc0204b4e:	bfc9                	j	ffffffffc0204b20 <user_mem_check+0x64>

ffffffffc0204b50 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204b50:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b52:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204b54:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b56:	aa9fb0ef          	jal	ra,ffffffffc02005fe <ide_device_valid>
ffffffffc0204b5a:	cd01                	beqz	a0,ffffffffc0204b72 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b5c:	4505                	li	a0,1
ffffffffc0204b5e:	aa7fb0ef          	jal	ra,ffffffffc0200604 <ide_device_size>
}
ffffffffc0204b62:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b64:	810d                	srli	a0,a0,0x3
ffffffffc0204b66:	000a8797          	auipc	a5,0xa8
ffffffffc0204b6a:	aaa7b923          	sd	a0,-1358(a5) # ffffffffc02ac618 <max_swap_offset>
}
ffffffffc0204b6e:	0141                	addi	sp,sp,16
ffffffffc0204b70:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204b72:	00004617          	auipc	a2,0x4
ffffffffc0204b76:	85660613          	addi	a2,a2,-1962 # ffffffffc02083c8 <default_pmm_manager+0x1038>
ffffffffc0204b7a:	45b5                	li	a1,13
ffffffffc0204b7c:	00004517          	auipc	a0,0x4
ffffffffc0204b80:	86c50513          	addi	a0,a0,-1940 # ffffffffc02083e8 <default_pmm_manager+0x1058>
ffffffffc0204b84:	901fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204b88 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204b88:	1141                	addi	sp,sp,-16
ffffffffc0204b8a:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b8c:	00855793          	srli	a5,a0,0x8
ffffffffc0204b90:	cfb9                	beqz	a5,ffffffffc0204bee <swapfs_read+0x66>
ffffffffc0204b92:	000a8717          	auipc	a4,0xa8
ffffffffc0204b96:	a8670713          	addi	a4,a4,-1402 # ffffffffc02ac618 <max_swap_offset>
ffffffffc0204b9a:	6318                	ld	a4,0(a4)
ffffffffc0204b9c:	04e7f963          	bleu	a4,a5,ffffffffc0204bee <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204ba0:	000a8717          	auipc	a4,0xa8
ffffffffc0204ba4:	9e870713          	addi	a4,a4,-1560 # ffffffffc02ac588 <pages>
ffffffffc0204ba8:	6310                	ld	a2,0(a4)
ffffffffc0204baa:	00004717          	auipc	a4,0x4
ffffffffc0204bae:	19670713          	addi	a4,a4,406 # ffffffffc0208d40 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204bb2:	000a8697          	auipc	a3,0xa8
ffffffffc0204bb6:	96668693          	addi	a3,a3,-1690 # ffffffffc02ac518 <npage>
    return page - pages + nbase;
ffffffffc0204bba:	40c58633          	sub	a2,a1,a2
ffffffffc0204bbe:	630c                	ld	a1,0(a4)
ffffffffc0204bc0:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204bc2:	577d                	li	a4,-1
ffffffffc0204bc4:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204bc6:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204bc8:	8331                	srli	a4,a4,0xc
ffffffffc0204bca:	8f71                	and	a4,a4,a2
ffffffffc0204bcc:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204bd0:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204bd2:	02d77a63          	bleu	a3,a4,ffffffffc0204c06 <swapfs_read+0x7e>
ffffffffc0204bd6:	000a8797          	auipc	a5,0xa8
ffffffffc0204bda:	9a278793          	addi	a5,a5,-1630 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0204bde:	639c                	ld	a5,0(a5)
}
ffffffffc0204be0:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204be2:	46a1                	li	a3,8
ffffffffc0204be4:	963e                	add	a2,a2,a5
ffffffffc0204be6:	4505                	li	a0,1
}
ffffffffc0204be8:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bea:	a21fb06f          	j	ffffffffc020060a <ide_read_secs>
ffffffffc0204bee:	86aa                	mv	a3,a0
ffffffffc0204bf0:	00004617          	auipc	a2,0x4
ffffffffc0204bf4:	81060613          	addi	a2,a2,-2032 # ffffffffc0208400 <default_pmm_manager+0x1070>
ffffffffc0204bf8:	45d1                	li	a1,20
ffffffffc0204bfa:	00003517          	auipc	a0,0x3
ffffffffc0204bfe:	7ee50513          	addi	a0,a0,2030 # ffffffffc02083e8 <default_pmm_manager+0x1058>
ffffffffc0204c02:	883fb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0204c06:	86b2                	mv	a3,a2
ffffffffc0204c08:	06900593          	li	a1,105
ffffffffc0204c0c:	00002617          	auipc	a2,0x2
ffffffffc0204c10:	7d460613          	addi	a2,a2,2004 # ffffffffc02073e0 <default_pmm_manager+0x50>
ffffffffc0204c14:	00002517          	auipc	a0,0x2
ffffffffc0204c18:	7f450513          	addi	a0,a0,2036 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc0204c1c:	869fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204c20 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204c20:	1141                	addi	sp,sp,-16
ffffffffc0204c22:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c24:	00855793          	srli	a5,a0,0x8
ffffffffc0204c28:	cfb9                	beqz	a5,ffffffffc0204c86 <swapfs_write+0x66>
ffffffffc0204c2a:	000a8717          	auipc	a4,0xa8
ffffffffc0204c2e:	9ee70713          	addi	a4,a4,-1554 # ffffffffc02ac618 <max_swap_offset>
ffffffffc0204c32:	6318                	ld	a4,0(a4)
ffffffffc0204c34:	04e7f963          	bleu	a4,a5,ffffffffc0204c86 <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204c38:	000a8717          	auipc	a4,0xa8
ffffffffc0204c3c:	95070713          	addi	a4,a4,-1712 # ffffffffc02ac588 <pages>
ffffffffc0204c40:	6310                	ld	a2,0(a4)
ffffffffc0204c42:	00004717          	auipc	a4,0x4
ffffffffc0204c46:	0fe70713          	addi	a4,a4,254 # ffffffffc0208d40 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204c4a:	000a8697          	auipc	a3,0xa8
ffffffffc0204c4e:	8ce68693          	addi	a3,a3,-1842 # ffffffffc02ac518 <npage>
    return page - pages + nbase;
ffffffffc0204c52:	40c58633          	sub	a2,a1,a2
ffffffffc0204c56:	630c                	ld	a1,0(a4)
ffffffffc0204c58:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204c5a:	577d                	li	a4,-1
ffffffffc0204c5c:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204c5e:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204c60:	8331                	srli	a4,a4,0xc
ffffffffc0204c62:	8f71                	and	a4,a4,a2
ffffffffc0204c64:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c68:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204c6a:	02d77a63          	bleu	a3,a4,ffffffffc0204c9e <swapfs_write+0x7e>
ffffffffc0204c6e:	000a8797          	auipc	a5,0xa8
ffffffffc0204c72:	90a78793          	addi	a5,a5,-1782 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0204c76:	639c                	ld	a5,0(a5)
}
ffffffffc0204c78:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c7a:	46a1                	li	a3,8
ffffffffc0204c7c:	963e                	add	a2,a2,a5
ffffffffc0204c7e:	4505                	li	a0,1
}
ffffffffc0204c80:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c82:	9adfb06f          	j	ffffffffc020062e <ide_write_secs>
ffffffffc0204c86:	86aa                	mv	a3,a0
ffffffffc0204c88:	00003617          	auipc	a2,0x3
ffffffffc0204c8c:	77860613          	addi	a2,a2,1912 # ffffffffc0208400 <default_pmm_manager+0x1070>
ffffffffc0204c90:	45e5                	li	a1,25
ffffffffc0204c92:	00003517          	auipc	a0,0x3
ffffffffc0204c96:	75650513          	addi	a0,a0,1878 # ffffffffc02083e8 <default_pmm_manager+0x1058>
ffffffffc0204c9a:	feafb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0204c9e:	86b2                	mv	a3,a2
ffffffffc0204ca0:	06900593          	li	a1,105
ffffffffc0204ca4:	00002617          	auipc	a2,0x2
ffffffffc0204ca8:	73c60613          	addi	a2,a2,1852 # ffffffffc02073e0 <default_pmm_manager+0x50>
ffffffffc0204cac:	00002517          	auipc	a0,0x2
ffffffffc0204cb0:	75c50513          	addi	a0,a0,1884 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc0204cb4:	fd0fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204cb8 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204cb8:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204cba:	9402                	jalr	s0

	jal do_exit
ffffffffc0204cbc:	732000ef          	jal	ra,ffffffffc02053ee <do_exit>

ffffffffc0204cc0 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204cc0:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204cc2:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204cc6:	e022                	sd	s0,0(sp)
ffffffffc0204cc8:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204cca:	f99fc0ef          	jal	ra,ffffffffc0201c62 <kmalloc>
ffffffffc0204cce:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204cd0:	cd29                	beqz	a0,ffffffffc0204d2a <alloc_proc+0x6a>
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
    
        proc->state = PROC_UNINIT;
ffffffffc0204cd2:	57fd                	li	a5,-1
ffffffffc0204cd4:	1782                	slli	a5,a5,0x20
ffffffffc0204cd6:	e11c                	sd	a5,0(a0)
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        proc->mm = NULL; // 进程所用的虚拟内存
        memset(&(proc->context), 0, sizeof(struct context)); // 进程的上下文
ffffffffc0204cd8:	07000613          	li	a2,112
ffffffffc0204cdc:	4581                	li	a1,0
        proc->runs = 0;
ffffffffc0204cde:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0204ce2:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0204ce6:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0204cea:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0204cee:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context)); // 进程的上下文
ffffffffc0204cf2:	03050513          	addi	a0,a0,48
ffffffffc0204cf6:	11f010ef          	jal	ra,ffffffffc0206614 <memset>
        proc->tf = NULL; // 中断帧指针
        proc->cr3 = boot_cr3; // 页目录表地址 设为 内核页目录表基址
ffffffffc0204cfa:	000a8797          	auipc	a5,0xa8
ffffffffc0204cfe:	88678793          	addi	a5,a5,-1914 # ffffffffc02ac580 <boot_cr3>
ffffffffc0204d02:	639c                	ld	a5,0(a5)
        proc->tf = NULL; // 中断帧指针
ffffffffc0204d04:	0a043023          	sd	zero,160(s0)
        proc->flags = 0; // 标志位
ffffffffc0204d08:	0a042823          	sw	zero,176(s0)
        proc->cr3 = boot_cr3; // 页目录表地址 设为 内核页目录表基址
ffffffffc0204d0c:	f45c                	sd	a5,168(s0)
        memset(&(proc->name), 0, PROC_NAME_LEN); // 进程名
ffffffffc0204d0e:	463d                	li	a2,15
ffffffffc0204d10:	4581                	li	a1,0
ffffffffc0204d12:	0b440513          	addi	a0,s0,180
ffffffffc0204d16:	0ff010ef          	jal	ra,ffffffffc0206614 <memset>
        proc->wait_state = 0;  
ffffffffc0204d1a:	0e042623          	sw	zero,236(s0)
        proc->cptr = proc->optr = proc->yptr = NULL;
ffffffffc0204d1e:	0e043c23          	sd	zero,248(s0)
ffffffffc0204d22:	10043023          	sd	zero,256(s0)
ffffffffc0204d26:	0e043823          	sd	zero,240(s0)
    }
    return proc;
}
ffffffffc0204d2a:	8522                	mv	a0,s0
ffffffffc0204d2c:	60a2                	ld	ra,8(sp)
ffffffffc0204d2e:	6402                	ld	s0,0(sp)
ffffffffc0204d30:	0141                	addi	sp,sp,16
ffffffffc0204d32:	8082                	ret

ffffffffc0204d34 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204d34:	000a7797          	auipc	a5,0xa7
ffffffffc0204d38:	7fc78793          	addi	a5,a5,2044 # ffffffffc02ac530 <current>
ffffffffc0204d3c:	639c                	ld	a5,0(a5)
ffffffffc0204d3e:	73c8                	ld	a0,160(a5)
ffffffffc0204d40:	876fc06f          	j	ffffffffc0200db6 <forkrets>

ffffffffc0204d44 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d44:	000a7797          	auipc	a5,0xa7
ffffffffc0204d48:	7ec78793          	addi	a5,a5,2028 # ffffffffc02ac530 <current>
ffffffffc0204d4c:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0204d4e:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d50:	00004617          	auipc	a2,0x4
ffffffffc0204d54:	ac060613          	addi	a2,a2,-1344 # ffffffffc0208810 <default_pmm_manager+0x1480>
ffffffffc0204d58:	43cc                	lw	a1,4(a5)
ffffffffc0204d5a:	00004517          	auipc	a0,0x4
ffffffffc0204d5e:	ac650513          	addi	a0,a0,-1338 # ffffffffc0208820 <default_pmm_manager+0x1490>
user_main(void *arg) {
ffffffffc0204d62:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d64:	c2afb0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0204d68:	00004797          	auipc	a5,0x4
ffffffffc0204d6c:	aa878793          	addi	a5,a5,-1368 # ffffffffc0208810 <default_pmm_manager+0x1480>
ffffffffc0204d70:	3fe05717          	auipc	a4,0x3fe05
ffffffffc0204d74:	57070713          	addi	a4,a4,1392 # a2e0 <_binary_obj___user_forktest_out_size>
ffffffffc0204d78:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204d7a:	853e                	mv	a0,a5
ffffffffc0204d7c:	00043717          	auipc	a4,0x43
ffffffffc0204d80:	30470713          	addi	a4,a4,772 # ffffffffc0248080 <_binary_obj___user_forktest_out_start>
ffffffffc0204d84:	f03a                	sd	a4,32(sp)
ffffffffc0204d86:	f43e                	sd	a5,40(sp)
ffffffffc0204d88:	e802                	sd	zero,16(sp)
ffffffffc0204d8a:	7ec010ef          	jal	ra,ffffffffc0206576 <strlen>
ffffffffc0204d8e:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204d90:	4511                	li	a0,4
ffffffffc0204d92:	55a2                	lw	a1,40(sp)
ffffffffc0204d94:	4662                	lw	a2,24(sp)
ffffffffc0204d96:	5682                	lw	a3,32(sp)
ffffffffc0204d98:	4722                	lw	a4,8(sp)
ffffffffc0204d9a:	48a9                	li	a7,10
ffffffffc0204d9c:	9002                	ebreak
ffffffffc0204d9e:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204da0:	65c2                	ld	a1,16(sp)
ffffffffc0204da2:	00004517          	auipc	a0,0x4
ffffffffc0204da6:	aa650513          	addi	a0,a0,-1370 # ffffffffc0208848 <default_pmm_manager+0x14b8>
ffffffffc0204daa:	be4fb0ef          	jal	ra,ffffffffc020018e <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204dae:	00004617          	auipc	a2,0x4
ffffffffc0204db2:	aaa60613          	addi	a2,a2,-1366 # ffffffffc0208858 <default_pmm_manager+0x14c8>
ffffffffc0204db6:	35900593          	li	a1,857
ffffffffc0204dba:	00004517          	auipc	a0,0x4
ffffffffc0204dbe:	abe50513          	addi	a0,a0,-1346 # ffffffffc0208878 <default_pmm_manager+0x14e8>
ffffffffc0204dc2:	ec2fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204dc6 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204dc6:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204dc8:	1141                	addi	sp,sp,-16
ffffffffc0204dca:	e406                	sd	ra,8(sp)
ffffffffc0204dcc:	c02007b7          	lui	a5,0xc0200
ffffffffc0204dd0:	04f6e263          	bltu	a3,a5,ffffffffc0204e14 <put_pgdir+0x4e>
ffffffffc0204dd4:	000a7797          	auipc	a5,0xa7
ffffffffc0204dd8:	7a478793          	addi	a5,a5,1956 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0204ddc:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204dde:	000a7797          	auipc	a5,0xa7
ffffffffc0204de2:	73a78793          	addi	a5,a5,1850 # ffffffffc02ac518 <npage>
ffffffffc0204de6:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0204de8:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204dea:	82b1                	srli	a3,a3,0xc
ffffffffc0204dec:	04f6f063          	bleu	a5,a3,ffffffffc0204e2c <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc0204df0:	00004797          	auipc	a5,0x4
ffffffffc0204df4:	f5078793          	addi	a5,a5,-176 # ffffffffc0208d40 <nbase>
ffffffffc0204df8:	639c                	ld	a5,0(a5)
ffffffffc0204dfa:	000a7717          	auipc	a4,0xa7
ffffffffc0204dfe:	78e70713          	addi	a4,a4,1934 # ffffffffc02ac588 <pages>
ffffffffc0204e02:	6308                	ld	a0,0(a4)
}
ffffffffc0204e04:	60a2                	ld	ra,8(sp)
ffffffffc0204e06:	8e9d                	sub	a3,a3,a5
ffffffffc0204e08:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204e0a:	4585                	li	a1,1
ffffffffc0204e0c:	9536                	add	a0,a0,a3
}
ffffffffc0204e0e:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204e10:	8d6fd06f          	j	ffffffffc0201ee6 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204e14:	00002617          	auipc	a2,0x2
ffffffffc0204e18:	60460613          	addi	a2,a2,1540 # ffffffffc0207418 <default_pmm_manager+0x88>
ffffffffc0204e1c:	06e00593          	li	a1,110
ffffffffc0204e20:	00002517          	auipc	a0,0x2
ffffffffc0204e24:	5e850513          	addi	a0,a0,1512 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc0204e28:	e5cfb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204e2c:	00002617          	auipc	a2,0x2
ffffffffc0204e30:	61460613          	addi	a2,a2,1556 # ffffffffc0207440 <default_pmm_manager+0xb0>
ffffffffc0204e34:	06200593          	li	a1,98
ffffffffc0204e38:	00002517          	auipc	a0,0x2
ffffffffc0204e3c:	5d050513          	addi	a0,a0,1488 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc0204e40:	e44fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204e44 <setup_pgdir>:
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204e44:	1101                	addi	sp,sp,-32
ffffffffc0204e46:	e426                	sd	s1,8(sp)
ffffffffc0204e48:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL) {
ffffffffc0204e4a:	4505                	li	a0,1
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204e4c:	ec06                	sd	ra,24(sp)
ffffffffc0204e4e:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL) {
ffffffffc0204e50:	80efd0ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
ffffffffc0204e54:	c125                	beqz	a0,ffffffffc0204eb4 <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc0204e56:	000a7797          	auipc	a5,0xa7
ffffffffc0204e5a:	73278793          	addi	a5,a5,1842 # ffffffffc02ac588 <pages>
ffffffffc0204e5e:	6394                	ld	a3,0(a5)
ffffffffc0204e60:	00004797          	auipc	a5,0x4
ffffffffc0204e64:	ee078793          	addi	a5,a5,-288 # ffffffffc0208d40 <nbase>
ffffffffc0204e68:	6380                	ld	s0,0(a5)
ffffffffc0204e6a:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204e6e:	000a7717          	auipc	a4,0xa7
ffffffffc0204e72:	6aa70713          	addi	a4,a4,1706 # ffffffffc02ac518 <npage>
    return page - pages + nbase;
ffffffffc0204e76:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204e78:	57fd                	li	a5,-1
ffffffffc0204e7a:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0204e7c:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0204e7e:	83b1                	srli	a5,a5,0xc
ffffffffc0204e80:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e82:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204e84:	02e7fa63          	bleu	a4,a5,ffffffffc0204eb8 <setup_pgdir+0x74>
ffffffffc0204e88:	000a7797          	auipc	a5,0xa7
ffffffffc0204e8c:	6f078793          	addi	a5,a5,1776 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0204e90:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0204e92:	000a7797          	auipc	a5,0xa7
ffffffffc0204e96:	67e78793          	addi	a5,a5,1662 # ffffffffc02ac510 <boot_pgdir>
ffffffffc0204e9a:	638c                	ld	a1,0(a5)
ffffffffc0204e9c:	9436                	add	s0,s0,a3
ffffffffc0204e9e:	6605                	lui	a2,0x1
ffffffffc0204ea0:	8522                	mv	a0,s0
ffffffffc0204ea2:	784010ef          	jal	ra,ffffffffc0206626 <memcpy>
    return 0;
ffffffffc0204ea6:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc0204ea8:	ec80                	sd	s0,24(s1)
}
ffffffffc0204eaa:	60e2                	ld	ra,24(sp)
ffffffffc0204eac:	6442                	ld	s0,16(sp)
ffffffffc0204eae:	64a2                	ld	s1,8(sp)
ffffffffc0204eb0:	6105                	addi	sp,sp,32
ffffffffc0204eb2:	8082                	ret
        return -E_NO_MEM;
ffffffffc0204eb4:	5571                	li	a0,-4
ffffffffc0204eb6:	bfd5                	j	ffffffffc0204eaa <setup_pgdir+0x66>
ffffffffc0204eb8:	00002617          	auipc	a2,0x2
ffffffffc0204ebc:	52860613          	addi	a2,a2,1320 # ffffffffc02073e0 <default_pmm_manager+0x50>
ffffffffc0204ec0:	06900593          	li	a1,105
ffffffffc0204ec4:	00002517          	auipc	a0,0x2
ffffffffc0204ec8:	54450513          	addi	a0,a0,1348 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc0204ecc:	db8fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204ed0 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204ed0:	1101                	addi	sp,sp,-32
ffffffffc0204ed2:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ed4:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204ed8:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204eda:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204edc:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ede:	8522                	mv	a0,s0
ffffffffc0204ee0:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204ee2:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ee4:	730010ef          	jal	ra,ffffffffc0206614 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204ee8:	8522                	mv	a0,s0
}
ffffffffc0204eea:	6442                	ld	s0,16(sp)
ffffffffc0204eec:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204eee:	85a6                	mv	a1,s1
}
ffffffffc0204ef0:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204ef2:	463d                	li	a2,15
}
ffffffffc0204ef4:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204ef6:	7300106f          	j	ffffffffc0206626 <memcpy>

ffffffffc0204efa <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204efa:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc0204efc:	000a7797          	auipc	a5,0xa7
ffffffffc0204f00:	63478793          	addi	a5,a5,1588 # ffffffffc02ac530 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204f04:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc0204f06:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc0204f08:	ec06                	sd	ra,24(sp)
ffffffffc0204f0a:	e822                	sd	s0,16(sp)
ffffffffc0204f0c:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc0204f0e:	02a48b63          	beq	s1,a0,ffffffffc0204f44 <proc_run+0x4a>
ffffffffc0204f12:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f14:	100027f3          	csrr	a5,sstatus
ffffffffc0204f18:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204f1a:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f1c:	e3a9                	bnez	a5,ffffffffc0204f5e <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204f1e:	745c                	ld	a5,168(s0)
            current = proc; // 将当前进程换为 要切换到的进程
ffffffffc0204f20:	000a7717          	auipc	a4,0xa7
ffffffffc0204f24:	60873823          	sd	s0,1552(a4) # ffffffffc02ac530 <current>
ffffffffc0204f28:	577d                	li	a4,-1
ffffffffc0204f2a:	177e                	slli	a4,a4,0x3f
ffffffffc0204f2c:	83b1                	srli	a5,a5,0xc
ffffffffc0204f2e:	8fd9                	or	a5,a5,a4
ffffffffc0204f30:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context)); // 调用 switch_to 进行上下文的保存与切换
ffffffffc0204f34:	03040593          	addi	a1,s0,48
ffffffffc0204f38:	03048513          	addi	a0,s1,48
ffffffffc0204f3c:	7cf000ef          	jal	ra,ffffffffc0205f0a <switch_to>
    if (flag) {
ffffffffc0204f40:	00091863          	bnez	s2,ffffffffc0204f50 <proc_run+0x56>
}
ffffffffc0204f44:	60e2                	ld	ra,24(sp)
ffffffffc0204f46:	6442                	ld	s0,16(sp)
ffffffffc0204f48:	64a2                	ld	s1,8(sp)
ffffffffc0204f4a:	6902                	ld	s2,0(sp)
ffffffffc0204f4c:	6105                	addi	sp,sp,32
ffffffffc0204f4e:	8082                	ret
ffffffffc0204f50:	6442                	ld	s0,16(sp)
ffffffffc0204f52:	60e2                	ld	ra,24(sp)
ffffffffc0204f54:	64a2                	ld	s1,8(sp)
ffffffffc0204f56:	6902                	ld	s2,0(sp)
ffffffffc0204f58:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204f5a:	efafb06f          	j	ffffffffc0200654 <intr_enable>
        intr_disable();
ffffffffc0204f5e:	efcfb0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc0204f62:	4905                	li	s2,1
ffffffffc0204f64:	bf6d                	j	ffffffffc0204f1e <proc_run+0x24>

ffffffffc0204f66 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204f66:	0005071b          	sext.w	a4,a0
ffffffffc0204f6a:	6789                	lui	a5,0x2
ffffffffc0204f6c:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204f70:	17f9                	addi	a5,a5,-2
ffffffffc0204f72:	04d7e063          	bltu	a5,a3,ffffffffc0204fb2 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0204f76:	1141                	addi	sp,sp,-16
ffffffffc0204f78:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204f7a:	45a9                	li	a1,10
ffffffffc0204f7c:	842a                	mv	s0,a0
ffffffffc0204f7e:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc0204f80:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204f82:	1e4010ef          	jal	ra,ffffffffc0206166 <hash32>
ffffffffc0204f86:	02051693          	slli	a3,a0,0x20
ffffffffc0204f8a:	82f1                	srli	a3,a3,0x1c
ffffffffc0204f8c:	000a3517          	auipc	a0,0xa3
ffffffffc0204f90:	56c50513          	addi	a0,a0,1388 # ffffffffc02a84f8 <hash_list>
ffffffffc0204f94:	96aa                	add	a3,a3,a0
ffffffffc0204f96:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204f98:	a029                	j	ffffffffc0204fa2 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0204f9a:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x764c>
ffffffffc0204f9e:	00870c63          	beq	a4,s0,ffffffffc0204fb6 <find_proc+0x50>
ffffffffc0204fa2:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204fa4:	fef69be3          	bne	a3,a5,ffffffffc0204f9a <find_proc+0x34>
}
ffffffffc0204fa8:	60a2                	ld	ra,8(sp)
ffffffffc0204faa:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0204fac:	4501                	li	a0,0
}
ffffffffc0204fae:	0141                	addi	sp,sp,16
ffffffffc0204fb0:	8082                	ret
    return NULL;
ffffffffc0204fb2:	4501                	li	a0,0
}
ffffffffc0204fb4:	8082                	ret
ffffffffc0204fb6:	60a2                	ld	ra,8(sp)
ffffffffc0204fb8:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204fba:	f2878513          	addi	a0,a5,-216
}
ffffffffc0204fbe:	0141                	addi	sp,sp,16
ffffffffc0204fc0:	8082                	ret

ffffffffc0204fc2 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204fc2:	7159                	addi	sp,sp,-112
ffffffffc0204fc4:	e0d2                	sd	s4,64(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204fc6:	000a7a17          	auipc	s4,0xa7
ffffffffc0204fca:	582a0a13          	addi	s4,s4,1410 # ffffffffc02ac548 <nr_process>
ffffffffc0204fce:	000a2703          	lw	a4,0(s4)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204fd2:	f486                	sd	ra,104(sp)
ffffffffc0204fd4:	f0a2                	sd	s0,96(sp)
ffffffffc0204fd6:	eca6                	sd	s1,88(sp)
ffffffffc0204fd8:	e8ca                	sd	s2,80(sp)
ffffffffc0204fda:	e4ce                	sd	s3,72(sp)
ffffffffc0204fdc:	fc56                	sd	s5,56(sp)
ffffffffc0204fde:	f85a                	sd	s6,48(sp)
ffffffffc0204fe0:	f45e                	sd	s7,40(sp)
ffffffffc0204fe2:	f062                	sd	s8,32(sp)
ffffffffc0204fe4:	ec66                	sd	s9,24(sp)
ffffffffc0204fe6:	e86a                	sd	s10,16(sp)
ffffffffc0204fe8:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204fea:	6785                	lui	a5,0x1
ffffffffc0204fec:	30f75a63          	ble	a5,a4,ffffffffc0205300 <do_fork+0x33e>
ffffffffc0204ff0:	89aa                	mv	s3,a0
ffffffffc0204ff2:	892e                	mv	s2,a1
ffffffffc0204ff4:	84b2                	mv	s1,a2
    if ((proc = alloc_proc()) == NULL)
ffffffffc0204ff6:	ccbff0ef          	jal	ra,ffffffffc0204cc0 <alloc_proc>
ffffffffc0204ffa:	842a                	mv	s0,a0
ffffffffc0204ffc:	2e050463          	beqz	a0,ffffffffc02052e4 <do_fork+0x322>
    proc->parent = current; // 设置父进程
ffffffffc0205000:	000a7c17          	auipc	s8,0xa7
ffffffffc0205004:	530c0c13          	addi	s8,s8,1328 # ffffffffc02ac530 <current>
ffffffffc0205008:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0);  
ffffffffc020500c:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x848c>
    proc->parent = current; // 设置父进程
ffffffffc0205010:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);  
ffffffffc0205012:	30071563          	bnez	a4,ffffffffc020531c <do_fork+0x35a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0205016:	4509                	li	a0,2
ffffffffc0205018:	e47fc0ef          	jal	ra,ffffffffc0201e5e <alloc_pages>
    if (page != NULL) {
ffffffffc020501c:	2c050163          	beqz	a0,ffffffffc02052de <do_fork+0x31c>
    return page - pages + nbase;
ffffffffc0205020:	000a7a97          	auipc	s5,0xa7
ffffffffc0205024:	568a8a93          	addi	s5,s5,1384 # ffffffffc02ac588 <pages>
ffffffffc0205028:	000ab683          	ld	a3,0(s5)
ffffffffc020502c:	00004b17          	auipc	s6,0x4
ffffffffc0205030:	d14b0b13          	addi	s6,s6,-748 # ffffffffc0208d40 <nbase>
ffffffffc0205034:	000b3783          	ld	a5,0(s6)
ffffffffc0205038:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc020503c:	000a7b97          	auipc	s7,0xa7
ffffffffc0205040:	4dcb8b93          	addi	s7,s7,1244 # ffffffffc02ac518 <npage>
    return page - pages + nbase;
ffffffffc0205044:	8699                	srai	a3,a3,0x6
ffffffffc0205046:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205048:	000bb703          	ld	a4,0(s7)
ffffffffc020504c:	57fd                	li	a5,-1
ffffffffc020504e:	83b1                	srli	a5,a5,0xc
ffffffffc0205050:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0205052:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205054:	2ae7f863          	bleu	a4,a5,ffffffffc0205304 <do_fork+0x342>
ffffffffc0205058:	000a7c97          	auipc	s9,0xa7
ffffffffc020505c:	520c8c93          	addi	s9,s9,1312 # ffffffffc02ac578 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0205060:	000c3703          	ld	a4,0(s8)
ffffffffc0205064:	000cb783          	ld	a5,0(s9)
ffffffffc0205068:	02873c03          	ld	s8,40(a4)
ffffffffc020506c:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc020506e:	e814                	sd	a3,16(s0)
    if (oldmm == NULL) {
ffffffffc0205070:	020c0863          	beqz	s8,ffffffffc02050a0 <do_fork+0xde>
    if (clone_flags & CLONE_VM) {
ffffffffc0205074:	1009f993          	andi	s3,s3,256
ffffffffc0205078:	1e098163          	beqz	s3,ffffffffc020525a <do_fork+0x298>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc020507c:	030c2703          	lw	a4,48(s8)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205080:	018c3783          	ld	a5,24(s8)
ffffffffc0205084:	c02006b7          	lui	a3,0xc0200
ffffffffc0205088:	2705                	addiw	a4,a4,1
ffffffffc020508a:	02ec2823          	sw	a4,48(s8)
    proc->mm = mm;
ffffffffc020508e:	03843423          	sd	s8,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205092:	2ad7e563          	bltu	a5,a3,ffffffffc020533c <do_fork+0x37a>
ffffffffc0205096:	000cb703          	ld	a4,0(s9)
ffffffffc020509a:	6814                	ld	a3,16(s0)
ffffffffc020509c:	8f99                	sub	a5,a5,a4
ffffffffc020509e:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02050a0:	6789                	lui	a5,0x2
ffffffffc02050a2:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7698>
ffffffffc02050a6:	96be                	add	a3,a3,a5
ffffffffc02050a8:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc02050aa:	87b6                	mv	a5,a3
ffffffffc02050ac:	12048813          	addi	a6,s1,288
ffffffffc02050b0:	6088                	ld	a0,0(s1)
ffffffffc02050b2:	648c                	ld	a1,8(s1)
ffffffffc02050b4:	6890                	ld	a2,16(s1)
ffffffffc02050b6:	6c98                	ld	a4,24(s1)
ffffffffc02050b8:	e388                	sd	a0,0(a5)
ffffffffc02050ba:	e78c                	sd	a1,8(a5)
ffffffffc02050bc:	eb90                	sd	a2,16(a5)
ffffffffc02050be:	ef98                	sd	a4,24(a5)
ffffffffc02050c0:	02048493          	addi	s1,s1,32
ffffffffc02050c4:	02078793          	addi	a5,a5,32
ffffffffc02050c8:	ff0494e3          	bne	s1,a6,ffffffffc02050b0 <do_fork+0xee>
    proc->tf->gpr.a0 = 0;
ffffffffc02050cc:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02050d0:	12090e63          	beqz	s2,ffffffffc020520c <do_fork+0x24a>
ffffffffc02050d4:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02050d8:	00000797          	auipc	a5,0x0
ffffffffc02050dc:	c5c78793          	addi	a5,a5,-932 # ffffffffc0204d34 <forkret>
ffffffffc02050e0:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02050e2:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050e4:	100027f3          	csrr	a5,sstatus
ffffffffc02050e8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02050ea:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050ec:	12079f63          	bnez	a5,ffffffffc020522a <do_fork+0x268>
    if (++ last_pid >= MAX_PID) {
ffffffffc02050f0:	0009c797          	auipc	a5,0x9c
ffffffffc02050f4:	00078793          	mv	a5,a5
ffffffffc02050f8:	439c                	lw	a5,0(a5)
ffffffffc02050fa:	6709                	lui	a4,0x2
ffffffffc02050fc:	0017851b          	addiw	a0,a5,1
ffffffffc0205100:	0009c697          	auipc	a3,0x9c
ffffffffc0205104:	fea6a823          	sw	a0,-16(a3) # ffffffffc02a10f0 <last_pid.1691>
ffffffffc0205108:	14e55263          	ble	a4,a0,ffffffffc020524c <do_fork+0x28a>
    if (last_pid >= next_safe) {
ffffffffc020510c:	0009c797          	auipc	a5,0x9c
ffffffffc0205110:	fe878793          	addi	a5,a5,-24 # ffffffffc02a10f4 <next_safe.1690>
ffffffffc0205114:	439c                	lw	a5,0(a5)
ffffffffc0205116:	000a7497          	auipc	s1,0xa7
ffffffffc020511a:	55a48493          	addi	s1,s1,1370 # ffffffffc02ac670 <proc_list>
ffffffffc020511e:	06f54063          	blt	a0,a5,ffffffffc020517e <do_fork+0x1bc>
        next_safe = MAX_PID;
ffffffffc0205122:	6789                	lui	a5,0x2
ffffffffc0205124:	0009c717          	auipc	a4,0x9c
ffffffffc0205128:	fcf72823          	sw	a5,-48(a4) # ffffffffc02a10f4 <next_safe.1690>
ffffffffc020512c:	4581                	li	a1,0
ffffffffc020512e:	87aa                	mv	a5,a0
ffffffffc0205130:	000a7497          	auipc	s1,0xa7
ffffffffc0205134:	54048493          	addi	s1,s1,1344 # ffffffffc02ac670 <proc_list>
    repeat:
ffffffffc0205138:	6889                	lui	a7,0x2
ffffffffc020513a:	882e                	mv	a6,a1
ffffffffc020513c:	6609                	lui	a2,0x2
        le = list;
ffffffffc020513e:	000a7697          	auipc	a3,0xa7
ffffffffc0205142:	53268693          	addi	a3,a3,1330 # ffffffffc02ac670 <proc_list>
ffffffffc0205146:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc0205148:	00968f63          	beq	a3,s1,ffffffffc0205166 <do_fork+0x1a4>
            if (proc->pid == last_pid) {
ffffffffc020514c:	f3c6a703          	lw	a4,-196(a3)
ffffffffc0205150:	0ae78963          	beq	a5,a4,ffffffffc0205202 <do_fork+0x240>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0205154:	fee7d9e3          	ble	a4,a5,ffffffffc0205146 <do_fork+0x184>
ffffffffc0205158:	fec757e3          	ble	a2,a4,ffffffffc0205146 <do_fork+0x184>
ffffffffc020515c:	6694                	ld	a3,8(a3)
ffffffffc020515e:	863a                	mv	a2,a4
ffffffffc0205160:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc0205162:	fe9695e3          	bne	a3,s1,ffffffffc020514c <do_fork+0x18a>
ffffffffc0205166:	c591                	beqz	a1,ffffffffc0205172 <do_fork+0x1b0>
ffffffffc0205168:	0009c717          	auipc	a4,0x9c
ffffffffc020516c:	f8f72423          	sw	a5,-120(a4) # ffffffffc02a10f0 <last_pid.1691>
ffffffffc0205170:	853e                	mv	a0,a5
ffffffffc0205172:	00080663          	beqz	a6,ffffffffc020517e <do_fork+0x1bc>
ffffffffc0205176:	0009c797          	auipc	a5,0x9c
ffffffffc020517a:	f6c7af23          	sw	a2,-130(a5) # ffffffffc02a10f4 <next_safe.1690>
        proc->pid = get_pid(); // 这一句话要在前面！！！ 
ffffffffc020517e:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205180:	45a9                	li	a1,10
ffffffffc0205182:	2501                	sext.w	a0,a0
ffffffffc0205184:	7e3000ef          	jal	ra,ffffffffc0206166 <hash32>
ffffffffc0205188:	1502                	slli	a0,a0,0x20
ffffffffc020518a:	000a3797          	auipc	a5,0xa3
ffffffffc020518e:	36e78793          	addi	a5,a5,878 # ffffffffc02a84f8 <hash_list>
ffffffffc0205192:	8171                	srli	a0,a0,0x1c
ffffffffc0205194:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0205196:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205198:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020519a:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc020519e:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02051a0:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc02051a2:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051a4:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc02051a6:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc02051aa:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc02051ac:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc02051ae:	e21c                	sd	a5,0(a2)
ffffffffc02051b0:	000a7597          	auipc	a1,0xa7
ffffffffc02051b4:	4cf5b423          	sd	a5,1224(a1) # ffffffffc02ac678 <proc_list+0x8>
    elm->next = next;
ffffffffc02051b8:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc02051ba:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc02051bc:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051c0:	10e43023          	sd	a4,256(s0)
ffffffffc02051c4:	c311                	beqz	a4,ffffffffc02051c8 <do_fork+0x206>
        proc->optr->yptr = proc;
ffffffffc02051c6:	ff60                	sd	s0,248(a4)
    nr_process ++;
ffffffffc02051c8:	000a2783          	lw	a5,0(s4)
    proc->parent->cptr = proc;
ffffffffc02051cc:	fae0                	sd	s0,240(a3)
    nr_process ++;
ffffffffc02051ce:	2785                	addiw	a5,a5,1
ffffffffc02051d0:	000a7717          	auipc	a4,0xa7
ffffffffc02051d4:	36f72c23          	sw	a5,888(a4) # ffffffffc02ac548 <nr_process>
    if (flag) {
ffffffffc02051d8:	10091863          	bnez	s2,ffffffffc02052e8 <do_fork+0x326>
    wakeup_proc(proc);
ffffffffc02051dc:	8522                	mv	a0,s0
ffffffffc02051de:	597000ef          	jal	ra,ffffffffc0205f74 <wakeup_proc>
    ret = proc->pid;
ffffffffc02051e2:	4048                	lw	a0,4(s0)
}
ffffffffc02051e4:	70a6                	ld	ra,104(sp)
ffffffffc02051e6:	7406                	ld	s0,96(sp)
ffffffffc02051e8:	64e6                	ld	s1,88(sp)
ffffffffc02051ea:	6946                	ld	s2,80(sp)
ffffffffc02051ec:	69a6                	ld	s3,72(sp)
ffffffffc02051ee:	6a06                	ld	s4,64(sp)
ffffffffc02051f0:	7ae2                	ld	s5,56(sp)
ffffffffc02051f2:	7b42                	ld	s6,48(sp)
ffffffffc02051f4:	7ba2                	ld	s7,40(sp)
ffffffffc02051f6:	7c02                	ld	s8,32(sp)
ffffffffc02051f8:	6ce2                	ld	s9,24(sp)
ffffffffc02051fa:	6d42                	ld	s10,16(sp)
ffffffffc02051fc:	6da2                	ld	s11,8(sp)
ffffffffc02051fe:	6165                	addi	sp,sp,112
ffffffffc0205200:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc0205202:	2785                	addiw	a5,a5,1
ffffffffc0205204:	0ec7d563          	ble	a2,a5,ffffffffc02052ee <do_fork+0x32c>
ffffffffc0205208:	4585                	li	a1,1
ffffffffc020520a:	bf35                	j	ffffffffc0205146 <do_fork+0x184>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020520c:	8936                	mv	s2,a3
ffffffffc020520e:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205212:	00000797          	auipc	a5,0x0
ffffffffc0205216:	b2278793          	addi	a5,a5,-1246 # ffffffffc0204d34 <forkret>
ffffffffc020521a:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020521c:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020521e:	100027f3          	csrr	a5,sstatus
ffffffffc0205222:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205224:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205226:	ec0785e3          	beqz	a5,ffffffffc02050f0 <do_fork+0x12e>
        intr_disable();
ffffffffc020522a:	c30fb0ef          	jal	ra,ffffffffc020065a <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc020522e:	0009c797          	auipc	a5,0x9c
ffffffffc0205232:	ec278793          	addi	a5,a5,-318 # ffffffffc02a10f0 <last_pid.1691>
ffffffffc0205236:	439c                	lw	a5,0(a5)
ffffffffc0205238:	6709                	lui	a4,0x2
        return 1;
ffffffffc020523a:	4905                	li	s2,1
ffffffffc020523c:	0017851b          	addiw	a0,a5,1
ffffffffc0205240:	0009c697          	auipc	a3,0x9c
ffffffffc0205244:	eaa6a823          	sw	a0,-336(a3) # ffffffffc02a10f0 <last_pid.1691>
ffffffffc0205248:	ece542e3          	blt	a0,a4,ffffffffc020510c <do_fork+0x14a>
        last_pid = 1;
ffffffffc020524c:	4785                	li	a5,1
ffffffffc020524e:	0009c717          	auipc	a4,0x9c
ffffffffc0205252:	eaf72123          	sw	a5,-350(a4) # ffffffffc02a10f0 <last_pid.1691>
ffffffffc0205256:	4505                	li	a0,1
ffffffffc0205258:	b5e9                	j	ffffffffc0205122 <do_fork+0x160>
    if ((mm = mm_create()) == NULL) {
ffffffffc020525a:	e79fe0ef          	jal	ra,ffffffffc02040d2 <mm_create>
ffffffffc020525e:	8d2a                	mv	s10,a0
ffffffffc0205260:	c539                	beqz	a0,ffffffffc02052ae <do_fork+0x2ec>
    if (setup_pgdir(mm) != 0) {
ffffffffc0205262:	be3ff0ef          	jal	ra,ffffffffc0204e44 <setup_pgdir>
ffffffffc0205266:	e949                	bnez	a0,ffffffffc02052f8 <do_fork+0x336>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc0205268:	038c0d93          	addi	s11,s8,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020526c:	4785                	li	a5,1
ffffffffc020526e:	40fdb7af          	amoor.d	a5,a5,(s11)
ffffffffc0205272:	8b85                	andi	a5,a5,1
ffffffffc0205274:	4985                	li	s3,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc0205276:	c799                	beqz	a5,ffffffffc0205284 <do_fork+0x2c2>
        schedule();
ffffffffc0205278:	579000ef          	jal	ra,ffffffffc0205ff0 <schedule>
ffffffffc020527c:	413db7af          	amoor.d	a5,s3,(s11)
ffffffffc0205280:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc0205282:	fbfd                	bnez	a5,ffffffffc0205278 <do_fork+0x2b6>
        ret = dup_mmap(mm, oldmm);
ffffffffc0205284:	85e2                	mv	a1,s8
ffffffffc0205286:	856a                	mv	a0,s10
ffffffffc0205288:	8d4ff0ef          	jal	ra,ffffffffc020435c <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020528c:	57f9                	li	a5,-2
ffffffffc020528e:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc0205292:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc0205294:	c3e9                	beqz	a5,ffffffffc0205356 <do_fork+0x394>
    if (ret != 0) {
ffffffffc0205296:	8c6a                	mv	s8,s10
ffffffffc0205298:	de0502e3          	beqz	a0,ffffffffc020507c <do_fork+0xba>
    exit_mmap(mm);
ffffffffc020529c:	856a                	mv	a0,s10
ffffffffc020529e:	95aff0ef          	jal	ra,ffffffffc02043f8 <exit_mmap>
    put_pgdir(mm);
ffffffffc02052a2:	856a                	mv	a0,s10
ffffffffc02052a4:	b23ff0ef          	jal	ra,ffffffffc0204dc6 <put_pgdir>
    mm_destroy(mm);
ffffffffc02052a8:	856a                	mv	a0,s10
ffffffffc02052aa:	faffe0ef          	jal	ra,ffffffffc0204258 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02052ae:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02052b0:	c02007b7          	lui	a5,0xc0200
ffffffffc02052b4:	0cf6e963          	bltu	a3,a5,ffffffffc0205386 <do_fork+0x3c4>
ffffffffc02052b8:	000cb783          	ld	a5,0(s9)
    if (PPN(pa) >= npage) {
ffffffffc02052bc:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc02052c0:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02052c4:	83b1                	srli	a5,a5,0xc
ffffffffc02052c6:	0ae7f463          	bleu	a4,a5,ffffffffc020536e <do_fork+0x3ac>
    return &pages[PPN(pa) - nbase];
ffffffffc02052ca:	000b3703          	ld	a4,0(s6)
ffffffffc02052ce:	000ab503          	ld	a0,0(s5)
ffffffffc02052d2:	4589                	li	a1,2
ffffffffc02052d4:	8f99                	sub	a5,a5,a4
ffffffffc02052d6:	079a                	slli	a5,a5,0x6
ffffffffc02052d8:	953e                	add	a0,a0,a5
ffffffffc02052da:	c0dfc0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    kfree(proc);
ffffffffc02052de:	8522                	mv	a0,s0
ffffffffc02052e0:	a3ffc0ef          	jal	ra,ffffffffc0201d1e <kfree>
    ret = -E_NO_MEM;
ffffffffc02052e4:	5571                	li	a0,-4
    return ret;
ffffffffc02052e6:	bdfd                	j	ffffffffc02051e4 <do_fork+0x222>
        intr_enable();
ffffffffc02052e8:	b6cfb0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc02052ec:	bdc5                	j	ffffffffc02051dc <do_fork+0x21a>
                    if (last_pid >= MAX_PID) {
ffffffffc02052ee:	0117c363          	blt	a5,a7,ffffffffc02052f4 <do_fork+0x332>
                        last_pid = 1;
ffffffffc02052f2:	4785                	li	a5,1
                    goto repeat;
ffffffffc02052f4:	4585                	li	a1,1
ffffffffc02052f6:	b591                	j	ffffffffc020513a <do_fork+0x178>
    mm_destroy(mm);
ffffffffc02052f8:	856a                	mv	a0,s10
ffffffffc02052fa:	f5ffe0ef          	jal	ra,ffffffffc0204258 <mm_destroy>
ffffffffc02052fe:	bf45                	j	ffffffffc02052ae <do_fork+0x2ec>
    int ret = -E_NO_FREE_PROC;
ffffffffc0205300:	556d                	li	a0,-5
ffffffffc0205302:	b5cd                	j	ffffffffc02051e4 <do_fork+0x222>
    return KADDR(page2pa(page));
ffffffffc0205304:	00002617          	auipc	a2,0x2
ffffffffc0205308:	0dc60613          	addi	a2,a2,220 # ffffffffc02073e0 <default_pmm_manager+0x50>
ffffffffc020530c:	06900593          	li	a1,105
ffffffffc0205310:	00002517          	auipc	a0,0x2
ffffffffc0205314:	0f850513          	addi	a0,a0,248 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc0205318:	96cfb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(current->wait_state == 0);  
ffffffffc020531c:	00003697          	auipc	a3,0x3
ffffffffc0205320:	2cc68693          	addi	a3,a3,716 # ffffffffc02085e8 <default_pmm_manager+0x1258>
ffffffffc0205324:	00002617          	auipc	a2,0x2
ffffffffc0205328:	92460613          	addi	a2,a2,-1756 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc020532c:	1b500593          	li	a1,437
ffffffffc0205330:	00003517          	auipc	a0,0x3
ffffffffc0205334:	54850513          	addi	a0,a0,1352 # ffffffffc0208878 <default_pmm_manager+0x14e8>
ffffffffc0205338:	94cfb0ef          	jal	ra,ffffffffc0200484 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020533c:	86be                	mv	a3,a5
ffffffffc020533e:	00002617          	auipc	a2,0x2
ffffffffc0205342:	0da60613          	addi	a2,a2,218 # ffffffffc0207418 <default_pmm_manager+0x88>
ffffffffc0205346:	16700593          	li	a1,359
ffffffffc020534a:	00003517          	auipc	a0,0x3
ffffffffc020534e:	52e50513          	addi	a0,a0,1326 # ffffffffc0208878 <default_pmm_manager+0x14e8>
ffffffffc0205352:	932fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("Unlock failed.\n");
ffffffffc0205356:	00003617          	auipc	a2,0x3
ffffffffc020535a:	2b260613          	addi	a2,a2,690 # ffffffffc0208608 <default_pmm_manager+0x1278>
ffffffffc020535e:	03100593          	li	a1,49
ffffffffc0205362:	00003517          	auipc	a0,0x3
ffffffffc0205366:	2b650513          	addi	a0,a0,694 # ffffffffc0208618 <default_pmm_manager+0x1288>
ffffffffc020536a:	91afb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020536e:	00002617          	auipc	a2,0x2
ffffffffc0205372:	0d260613          	addi	a2,a2,210 # ffffffffc0207440 <default_pmm_manager+0xb0>
ffffffffc0205376:	06200593          	li	a1,98
ffffffffc020537a:	00002517          	auipc	a0,0x2
ffffffffc020537e:	08e50513          	addi	a0,a0,142 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc0205382:	902fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205386:	00002617          	auipc	a2,0x2
ffffffffc020538a:	09260613          	addi	a2,a2,146 # ffffffffc0207418 <default_pmm_manager+0x88>
ffffffffc020538e:	06e00593          	li	a1,110
ffffffffc0205392:	00002517          	auipc	a0,0x2
ffffffffc0205396:	07650513          	addi	a0,a0,118 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc020539a:	8eafb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020539e <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020539e:	7129                	addi	sp,sp,-320
ffffffffc02053a0:	fa22                	sd	s0,304(sp)
ffffffffc02053a2:	f626                	sd	s1,296(sp)
ffffffffc02053a4:	f24a                	sd	s2,288(sp)
ffffffffc02053a6:	84ae                	mv	s1,a1
ffffffffc02053a8:	892a                	mv	s2,a0
ffffffffc02053aa:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02053ac:	4581                	li	a1,0
ffffffffc02053ae:	12000613          	li	a2,288
ffffffffc02053b2:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02053b4:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02053b6:	25e010ef          	jal	ra,ffffffffc0206614 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02053ba:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02053bc:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02053be:	100027f3          	csrr	a5,sstatus
ffffffffc02053c2:	edd7f793          	andi	a5,a5,-291
ffffffffc02053c6:	1207e793          	ori	a5,a5,288
ffffffffc02053ca:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053cc:	860a                	mv	a2,sp
ffffffffc02053ce:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02053d2:	00000797          	auipc	a5,0x0
ffffffffc02053d6:	8e678793          	addi	a5,a5,-1818 # ffffffffc0204cb8 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053da:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02053dc:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053de:	be5ff0ef          	jal	ra,ffffffffc0204fc2 <do_fork>
}
ffffffffc02053e2:	70f2                	ld	ra,312(sp)
ffffffffc02053e4:	7452                	ld	s0,304(sp)
ffffffffc02053e6:	74b2                	ld	s1,296(sp)
ffffffffc02053e8:	7912                	ld	s2,288(sp)
ffffffffc02053ea:	6131                	addi	sp,sp,320
ffffffffc02053ec:	8082                	ret

ffffffffc02053ee <do_exit>:
do_exit(int error_code) {
ffffffffc02053ee:	7179                	addi	sp,sp,-48
ffffffffc02053f0:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc02053f2:	000a7717          	auipc	a4,0xa7
ffffffffc02053f6:	14670713          	addi	a4,a4,326 # ffffffffc02ac538 <idleproc>
ffffffffc02053fa:	000a7917          	auipc	s2,0xa7
ffffffffc02053fe:	13690913          	addi	s2,s2,310 # ffffffffc02ac530 <current>
ffffffffc0205402:	00093783          	ld	a5,0(s2)
ffffffffc0205406:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc0205408:	f406                	sd	ra,40(sp)
ffffffffc020540a:	f022                	sd	s0,32(sp)
ffffffffc020540c:	ec26                	sd	s1,24(sp)
ffffffffc020540e:	e44e                	sd	s3,8(sp)
ffffffffc0205410:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc0205412:	0ce78c63          	beq	a5,a4,ffffffffc02054ea <do_exit+0xfc>
    if (current == initproc) {
ffffffffc0205416:	000a7417          	auipc	s0,0xa7
ffffffffc020541a:	12a40413          	addi	s0,s0,298 # ffffffffc02ac540 <initproc>
ffffffffc020541e:	6018                	ld	a4,0(s0)
ffffffffc0205420:	0ee78b63          	beq	a5,a4,ffffffffc0205516 <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc0205424:	7784                	ld	s1,40(a5)
ffffffffc0205426:	89aa                	mv	s3,a0
    if (mm != NULL) {
ffffffffc0205428:	c48d                	beqz	s1,ffffffffc0205452 <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc020542a:	000a7797          	auipc	a5,0xa7
ffffffffc020542e:	15678793          	addi	a5,a5,342 # ffffffffc02ac580 <boot_cr3>
ffffffffc0205432:	639c                	ld	a5,0(a5)
ffffffffc0205434:	577d                	li	a4,-1
ffffffffc0205436:	177e                	slli	a4,a4,0x3f
ffffffffc0205438:	83b1                	srli	a5,a5,0xc
ffffffffc020543a:	8fd9                	or	a5,a5,a4
ffffffffc020543c:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0205440:	589c                	lw	a5,48(s1)
ffffffffc0205442:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205446:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205448:	cf4d                	beqz	a4,ffffffffc0205502 <do_exit+0x114>
        current->mm = NULL;
ffffffffc020544a:	00093783          	ld	a5,0(s2)
ffffffffc020544e:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0205452:	00093783          	ld	a5,0(s2)
ffffffffc0205456:	470d                	li	a4,3
ffffffffc0205458:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc020545a:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020545e:	100027f3          	csrr	a5,sstatus
ffffffffc0205462:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205464:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205466:	e7e1                	bnez	a5,ffffffffc020552e <do_exit+0x140>
        proc = current->parent;
ffffffffc0205468:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc020546c:	800007b7          	lui	a5,0x80000
ffffffffc0205470:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc0205472:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205474:	0ec52703          	lw	a4,236(a0)
ffffffffc0205478:	0af70f63          	beq	a4,a5,ffffffffc0205536 <do_exit+0x148>
ffffffffc020547c:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205480:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205484:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205486:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) {
ffffffffc0205488:	7afc                	ld	a5,240(a3)
ffffffffc020548a:	cb95                	beqz	a5,ffffffffc02054be <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc020548c:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff5678>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205490:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc0205492:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205494:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0205496:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020549a:	10e7b023          	sd	a4,256(a5)
ffffffffc020549e:	c311                	beqz	a4,ffffffffc02054a2 <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc02054a0:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054a2:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02054a4:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02054a6:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054a8:	fe9710e3          	bne	a4,s1,ffffffffc0205488 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02054ac:	0ec52783          	lw	a5,236(a0)
ffffffffc02054b0:	fd379ce3          	bne	a5,s3,ffffffffc0205488 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc02054b4:	2c1000ef          	jal	ra,ffffffffc0205f74 <wakeup_proc>
ffffffffc02054b8:	00093683          	ld	a3,0(s2)
ffffffffc02054bc:	b7f1                	j	ffffffffc0205488 <do_exit+0x9a>
    if (flag) {
ffffffffc02054be:	020a1363          	bnez	s4,ffffffffc02054e4 <do_exit+0xf6>
    schedule();
ffffffffc02054c2:	32f000ef          	jal	ra,ffffffffc0205ff0 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc02054c6:	00093783          	ld	a5,0(s2)
ffffffffc02054ca:	00003617          	auipc	a2,0x3
ffffffffc02054ce:	0fe60613          	addi	a2,a2,254 # ffffffffc02085c8 <default_pmm_manager+0x1238>
ffffffffc02054d2:	21000593          	li	a1,528
ffffffffc02054d6:	43d4                	lw	a3,4(a5)
ffffffffc02054d8:	00003517          	auipc	a0,0x3
ffffffffc02054dc:	3a050513          	addi	a0,a0,928 # ffffffffc0208878 <default_pmm_manager+0x14e8>
ffffffffc02054e0:	fa5fa0ef          	jal	ra,ffffffffc0200484 <__panic>
        intr_enable();
ffffffffc02054e4:	970fb0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc02054e8:	bfe9                	j	ffffffffc02054c2 <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc02054ea:	00003617          	auipc	a2,0x3
ffffffffc02054ee:	0be60613          	addi	a2,a2,190 # ffffffffc02085a8 <default_pmm_manager+0x1218>
ffffffffc02054f2:	1e400593          	li	a1,484
ffffffffc02054f6:	00003517          	auipc	a0,0x3
ffffffffc02054fa:	38250513          	addi	a0,a0,898 # ffffffffc0208878 <default_pmm_manager+0x14e8>
ffffffffc02054fe:	f87fa0ef          	jal	ra,ffffffffc0200484 <__panic>
            exit_mmap(mm);
ffffffffc0205502:	8526                	mv	a0,s1
ffffffffc0205504:	ef5fe0ef          	jal	ra,ffffffffc02043f8 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205508:	8526                	mv	a0,s1
ffffffffc020550a:	8bdff0ef          	jal	ra,ffffffffc0204dc6 <put_pgdir>
            mm_destroy(mm);
ffffffffc020550e:	8526                	mv	a0,s1
ffffffffc0205510:	d49fe0ef          	jal	ra,ffffffffc0204258 <mm_destroy>
ffffffffc0205514:	bf1d                	j	ffffffffc020544a <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc0205516:	00003617          	auipc	a2,0x3
ffffffffc020551a:	0a260613          	addi	a2,a2,162 # ffffffffc02085b8 <default_pmm_manager+0x1228>
ffffffffc020551e:	1e700593          	li	a1,487
ffffffffc0205522:	00003517          	auipc	a0,0x3
ffffffffc0205526:	35650513          	addi	a0,a0,854 # ffffffffc0208878 <default_pmm_manager+0x14e8>
ffffffffc020552a:	f5bfa0ef          	jal	ra,ffffffffc0200484 <__panic>
        intr_disable();
ffffffffc020552e:	92cfb0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc0205532:	4a05                	li	s4,1
ffffffffc0205534:	bf15                	j	ffffffffc0205468 <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc0205536:	23f000ef          	jal	ra,ffffffffc0205f74 <wakeup_proc>
ffffffffc020553a:	b789                	j	ffffffffc020547c <do_exit+0x8e>

ffffffffc020553c <do_wait.part.1>:
do_wait(int pid, int *code_store) {
ffffffffc020553c:	7139                	addi	sp,sp,-64
ffffffffc020553e:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc0205540:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc0205544:	f426                	sd	s1,40(sp)
ffffffffc0205546:	f04a                	sd	s2,32(sp)
ffffffffc0205548:	ec4e                	sd	s3,24(sp)
ffffffffc020554a:	e456                	sd	s5,8(sp)
ffffffffc020554c:	e05a                	sd	s6,0(sp)
ffffffffc020554e:	fc06                	sd	ra,56(sp)
ffffffffc0205550:	f822                	sd	s0,48(sp)
ffffffffc0205552:	89aa                	mv	s3,a0
ffffffffc0205554:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc0205556:	000a7917          	auipc	s2,0xa7
ffffffffc020555a:	fda90913          	addi	s2,s2,-38 # ffffffffc02ac530 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020555e:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc0205560:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc0205562:	2a05                	addiw	s4,s4,1
    if (pid != 0) {
ffffffffc0205564:	02098f63          	beqz	s3,ffffffffc02055a2 <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc0205568:	854e                	mv	a0,s3
ffffffffc020556a:	9fdff0ef          	jal	ra,ffffffffc0204f66 <find_proc>
ffffffffc020556e:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc0205570:	12050063          	beqz	a0,ffffffffc0205690 <do_wait.part.1+0x154>
ffffffffc0205574:	00093703          	ld	a4,0(s2)
ffffffffc0205578:	711c                	ld	a5,32(a0)
ffffffffc020557a:	10e79b63          	bne	a5,a4,ffffffffc0205690 <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020557e:	411c                	lw	a5,0(a0)
ffffffffc0205580:	02978c63          	beq	a5,s1,ffffffffc02055b8 <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc0205584:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc0205588:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc020558c:	265000ef          	jal	ra,ffffffffc0205ff0 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc0205590:	00093783          	ld	a5,0(s2)
ffffffffc0205594:	0b07a783          	lw	a5,176(a5)
ffffffffc0205598:	8b85                	andi	a5,a5,1
ffffffffc020559a:	d7e9                	beqz	a5,ffffffffc0205564 <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc020559c:	555d                	li	a0,-9
ffffffffc020559e:	e51ff0ef          	jal	ra,ffffffffc02053ee <do_exit>
        proc = current->cptr;
ffffffffc02055a2:	00093703          	ld	a4,0(s2)
ffffffffc02055a6:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc02055a8:	e409                	bnez	s0,ffffffffc02055b2 <do_wait.part.1+0x76>
ffffffffc02055aa:	a0dd                	j	ffffffffc0205690 <do_wait.part.1+0x154>
ffffffffc02055ac:	10043403          	ld	s0,256(s0)
ffffffffc02055b0:	d871                	beqz	s0,ffffffffc0205584 <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055b2:	401c                	lw	a5,0(s0)
ffffffffc02055b4:	fe979ce3          	bne	a5,s1,ffffffffc02055ac <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc02055b8:	000a7797          	auipc	a5,0xa7
ffffffffc02055bc:	f8078793          	addi	a5,a5,-128 # ffffffffc02ac538 <idleproc>
ffffffffc02055c0:	639c                	ld	a5,0(a5)
ffffffffc02055c2:	0c878d63          	beq	a5,s0,ffffffffc020569c <do_wait.part.1+0x160>
ffffffffc02055c6:	000a7797          	auipc	a5,0xa7
ffffffffc02055ca:	f7a78793          	addi	a5,a5,-134 # ffffffffc02ac540 <initproc>
ffffffffc02055ce:	639c                	ld	a5,0(a5)
ffffffffc02055d0:	0cf40663          	beq	s0,a5,ffffffffc020569c <do_wait.part.1+0x160>
    if (code_store != NULL) {
ffffffffc02055d4:	000b0663          	beqz	s6,ffffffffc02055e0 <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc02055d8:	0e842783          	lw	a5,232(s0)
ffffffffc02055dc:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055e0:	100027f3          	csrr	a5,sstatus
ffffffffc02055e4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02055e6:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055e8:	e7d5                	bnez	a5,ffffffffc0205694 <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc02055ea:	6c70                	ld	a2,216(s0)
ffffffffc02055ec:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc02055ee:	10043703          	ld	a4,256(s0)
ffffffffc02055f2:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02055f4:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02055f6:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02055f8:	6470                	ld	a2,200(s0)
ffffffffc02055fa:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc02055fc:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02055fe:	e290                	sd	a2,0(a3)
ffffffffc0205600:	c319                	beqz	a4,ffffffffc0205606 <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc0205602:	ff7c                	sd	a5,248(a4)
ffffffffc0205604:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc0205606:	c3d1                	beqz	a5,ffffffffc020568a <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc0205608:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc020560c:	000a7797          	auipc	a5,0xa7
ffffffffc0205610:	f3c78793          	addi	a5,a5,-196 # ffffffffc02ac548 <nr_process>
ffffffffc0205614:	439c                	lw	a5,0(a5)
ffffffffc0205616:	37fd                	addiw	a5,a5,-1
ffffffffc0205618:	000a7717          	auipc	a4,0xa7
ffffffffc020561c:	f2f72823          	sw	a5,-208(a4) # ffffffffc02ac548 <nr_process>
    if (flag) {
ffffffffc0205620:	e1b5                	bnez	a1,ffffffffc0205684 <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205622:	6814                	ld	a3,16(s0)
ffffffffc0205624:	c02007b7          	lui	a5,0xc0200
ffffffffc0205628:	0af6e263          	bltu	a3,a5,ffffffffc02056cc <do_wait.part.1+0x190>
ffffffffc020562c:	000a7797          	auipc	a5,0xa7
ffffffffc0205630:	f4c78793          	addi	a5,a5,-180 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0205634:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0205636:	000a7797          	auipc	a5,0xa7
ffffffffc020563a:	ee278793          	addi	a5,a5,-286 # ffffffffc02ac518 <npage>
ffffffffc020563e:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0205640:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0205642:	82b1                	srli	a3,a3,0xc
ffffffffc0205644:	06f6f863          	bleu	a5,a3,ffffffffc02056b4 <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc0205648:	00003797          	auipc	a5,0x3
ffffffffc020564c:	6f878793          	addi	a5,a5,1784 # ffffffffc0208d40 <nbase>
ffffffffc0205650:	639c                	ld	a5,0(a5)
ffffffffc0205652:	000a7717          	auipc	a4,0xa7
ffffffffc0205656:	f3670713          	addi	a4,a4,-202 # ffffffffc02ac588 <pages>
ffffffffc020565a:	6308                	ld	a0,0(a4)
ffffffffc020565c:	8e9d                	sub	a3,a3,a5
ffffffffc020565e:	069a                	slli	a3,a3,0x6
ffffffffc0205660:	9536                	add	a0,a0,a3
ffffffffc0205662:	4589                	li	a1,2
ffffffffc0205664:	883fc0ef          	jal	ra,ffffffffc0201ee6 <free_pages>
    kfree(proc);
ffffffffc0205668:	8522                	mv	a0,s0
ffffffffc020566a:	eb4fc0ef          	jal	ra,ffffffffc0201d1e <kfree>
    return 0;
ffffffffc020566e:	4501                	li	a0,0
}
ffffffffc0205670:	70e2                	ld	ra,56(sp)
ffffffffc0205672:	7442                	ld	s0,48(sp)
ffffffffc0205674:	74a2                	ld	s1,40(sp)
ffffffffc0205676:	7902                	ld	s2,32(sp)
ffffffffc0205678:	69e2                	ld	s3,24(sp)
ffffffffc020567a:	6a42                	ld	s4,16(sp)
ffffffffc020567c:	6aa2                	ld	s5,8(sp)
ffffffffc020567e:	6b02                	ld	s6,0(sp)
ffffffffc0205680:	6121                	addi	sp,sp,64
ffffffffc0205682:	8082                	ret
        intr_enable();
ffffffffc0205684:	fd1fa0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0205688:	bf69                	j	ffffffffc0205622 <do_wait.part.1+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc020568a:	701c                	ld	a5,32(s0)
ffffffffc020568c:	fbf8                	sd	a4,240(a5)
ffffffffc020568e:	bfbd                	j	ffffffffc020560c <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc0205690:	5579                	li	a0,-2
ffffffffc0205692:	bff9                	j	ffffffffc0205670 <do_wait.part.1+0x134>
        intr_disable();
ffffffffc0205694:	fc7fa0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc0205698:	4585                	li	a1,1
ffffffffc020569a:	bf81                	j	ffffffffc02055ea <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc020569c:	00003617          	auipc	a2,0x3
ffffffffc02056a0:	f9460613          	addi	a2,a2,-108 # ffffffffc0208630 <default_pmm_manager+0x12a0>
ffffffffc02056a4:	30700593          	li	a1,775
ffffffffc02056a8:	00003517          	auipc	a0,0x3
ffffffffc02056ac:	1d050513          	addi	a0,a0,464 # ffffffffc0208878 <default_pmm_manager+0x14e8>
ffffffffc02056b0:	dd5fa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02056b4:	00002617          	auipc	a2,0x2
ffffffffc02056b8:	d8c60613          	addi	a2,a2,-628 # ffffffffc0207440 <default_pmm_manager+0xb0>
ffffffffc02056bc:	06200593          	li	a1,98
ffffffffc02056c0:	00002517          	auipc	a0,0x2
ffffffffc02056c4:	d4850513          	addi	a0,a0,-696 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc02056c8:	dbdfa0ef          	jal	ra,ffffffffc0200484 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02056cc:	00002617          	auipc	a2,0x2
ffffffffc02056d0:	d4c60613          	addi	a2,a2,-692 # ffffffffc0207418 <default_pmm_manager+0x88>
ffffffffc02056d4:	06e00593          	li	a1,110
ffffffffc02056d8:	00002517          	auipc	a0,0x2
ffffffffc02056dc:	d3050513          	addi	a0,a0,-720 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc02056e0:	da5fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02056e4 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc02056e4:	1141                	addi	sp,sp,-16
ffffffffc02056e6:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02056e8:	845fc0ef          	jal	ra,ffffffffc0201f2c <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02056ec:	d72fc0ef          	jal	ra,ffffffffc0201c5e <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02056f0:	4601                	li	a2,0
ffffffffc02056f2:	4581                	li	a1,0
ffffffffc02056f4:	fffff517          	auipc	a0,0xfffff
ffffffffc02056f8:	65050513          	addi	a0,a0,1616 # ffffffffc0204d44 <user_main>
ffffffffc02056fc:	ca3ff0ef          	jal	ra,ffffffffc020539e <kernel_thread>
    if (pid <= 0) {
ffffffffc0205700:	00a04563          	bgtz	a0,ffffffffc020570a <init_main+0x26>
ffffffffc0205704:	a841                	j	ffffffffc0205794 <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc0205706:	0eb000ef          	jal	ra,ffffffffc0205ff0 <schedule>
    if (code_store != NULL) {
ffffffffc020570a:	4581                	li	a1,0
ffffffffc020570c:	4501                	li	a0,0
ffffffffc020570e:	e2fff0ef          	jal	ra,ffffffffc020553c <do_wait.part.1>
    while (do_wait(0, NULL) == 0) {
ffffffffc0205712:	d975                	beqz	a0,ffffffffc0205706 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0205714:	00003517          	auipc	a0,0x3
ffffffffc0205718:	f5c50513          	addi	a0,a0,-164 # ffffffffc0208670 <default_pmm_manager+0x12e0>
ffffffffc020571c:	a73fa0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205720:	000a7797          	auipc	a5,0xa7
ffffffffc0205724:	e2078793          	addi	a5,a5,-480 # ffffffffc02ac540 <initproc>
ffffffffc0205728:	639c                	ld	a5,0(a5)
ffffffffc020572a:	7bf8                	ld	a4,240(a5)
ffffffffc020572c:	e721                	bnez	a4,ffffffffc0205774 <init_main+0x90>
ffffffffc020572e:	7ff8                	ld	a4,248(a5)
ffffffffc0205730:	e331                	bnez	a4,ffffffffc0205774 <init_main+0x90>
ffffffffc0205732:	1007b703          	ld	a4,256(a5)
ffffffffc0205736:	ef1d                	bnez	a4,ffffffffc0205774 <init_main+0x90>
    assert(nr_process == 2);
ffffffffc0205738:	000a7717          	auipc	a4,0xa7
ffffffffc020573c:	e1070713          	addi	a4,a4,-496 # ffffffffc02ac548 <nr_process>
ffffffffc0205740:	4314                	lw	a3,0(a4)
ffffffffc0205742:	4709                	li	a4,2
ffffffffc0205744:	0ae69463          	bne	a3,a4,ffffffffc02057ec <init_main+0x108>
    return listelm->next;
ffffffffc0205748:	000a7697          	auipc	a3,0xa7
ffffffffc020574c:	f2868693          	addi	a3,a3,-216 # ffffffffc02ac670 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205750:	6698                	ld	a4,8(a3)
ffffffffc0205752:	0c878793          	addi	a5,a5,200
ffffffffc0205756:	06f71b63          	bne	a4,a5,ffffffffc02057cc <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020575a:	629c                	ld	a5,0(a3)
ffffffffc020575c:	04f71863          	bne	a4,a5,ffffffffc02057ac <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc0205760:	00003517          	auipc	a0,0x3
ffffffffc0205764:	ff850513          	addi	a0,a0,-8 # ffffffffc0208758 <default_pmm_manager+0x13c8>
ffffffffc0205768:	a27fa0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
}
ffffffffc020576c:	60a2                	ld	ra,8(sp)
ffffffffc020576e:	4501                	li	a0,0
ffffffffc0205770:	0141                	addi	sp,sp,16
ffffffffc0205772:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205774:	00003697          	auipc	a3,0x3
ffffffffc0205778:	f2468693          	addi	a3,a3,-220 # ffffffffc0208698 <default_pmm_manager+0x1308>
ffffffffc020577c:	00001617          	auipc	a2,0x1
ffffffffc0205780:	4cc60613          	addi	a2,a2,1228 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0205784:	36c00593          	li	a1,876
ffffffffc0205788:	00003517          	auipc	a0,0x3
ffffffffc020578c:	0f050513          	addi	a0,a0,240 # ffffffffc0208878 <default_pmm_manager+0x14e8>
ffffffffc0205790:	cf5fa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("create user_main failed.\n");
ffffffffc0205794:	00003617          	auipc	a2,0x3
ffffffffc0205798:	ebc60613          	addi	a2,a2,-324 # ffffffffc0208650 <default_pmm_manager+0x12c0>
ffffffffc020579c:	36400593          	li	a1,868
ffffffffc02057a0:	00003517          	auipc	a0,0x3
ffffffffc02057a4:	0d850513          	addi	a0,a0,216 # ffffffffc0208878 <default_pmm_manager+0x14e8>
ffffffffc02057a8:	cddfa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02057ac:	00003697          	auipc	a3,0x3
ffffffffc02057b0:	f7c68693          	addi	a3,a3,-132 # ffffffffc0208728 <default_pmm_manager+0x1398>
ffffffffc02057b4:	00001617          	auipc	a2,0x1
ffffffffc02057b8:	49460613          	addi	a2,a2,1172 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02057bc:	36f00593          	li	a1,879
ffffffffc02057c0:	00003517          	auipc	a0,0x3
ffffffffc02057c4:	0b850513          	addi	a0,a0,184 # ffffffffc0208878 <default_pmm_manager+0x14e8>
ffffffffc02057c8:	cbdfa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02057cc:	00003697          	auipc	a3,0x3
ffffffffc02057d0:	f2c68693          	addi	a3,a3,-212 # ffffffffc02086f8 <default_pmm_manager+0x1368>
ffffffffc02057d4:	00001617          	auipc	a2,0x1
ffffffffc02057d8:	47460613          	addi	a2,a2,1140 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02057dc:	36e00593          	li	a1,878
ffffffffc02057e0:	00003517          	auipc	a0,0x3
ffffffffc02057e4:	09850513          	addi	a0,a0,152 # ffffffffc0208878 <default_pmm_manager+0x14e8>
ffffffffc02057e8:	c9dfa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_process == 2);
ffffffffc02057ec:	00003697          	auipc	a3,0x3
ffffffffc02057f0:	efc68693          	addi	a3,a3,-260 # ffffffffc02086e8 <default_pmm_manager+0x1358>
ffffffffc02057f4:	00001617          	auipc	a2,0x1
ffffffffc02057f8:	45460613          	addi	a2,a2,1108 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02057fc:	36d00593          	li	a1,877
ffffffffc0205800:	00003517          	auipc	a0,0x3
ffffffffc0205804:	07850513          	addi	a0,a0,120 # ffffffffc0208878 <default_pmm_manager+0x14e8>
ffffffffc0205808:	c7dfa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020580c <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020580c:	7135                	addi	sp,sp,-160
ffffffffc020580e:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205810:	000a7a17          	auipc	s4,0xa7
ffffffffc0205814:	d20a0a13          	addi	s4,s4,-736 # ffffffffc02ac530 <current>
ffffffffc0205818:	000a3783          	ld	a5,0(s4)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020581c:	e14a                	sd	s2,128(sp)
ffffffffc020581e:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205820:	0287b903          	ld	s2,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205824:	fcce                	sd	s3,120(sp)
ffffffffc0205826:	f0da                	sd	s6,96(sp)
ffffffffc0205828:	89aa                	mv	s3,a0
ffffffffc020582a:	842e                	mv	s0,a1
ffffffffc020582c:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc020582e:	4681                	li	a3,0
ffffffffc0205830:	862e                	mv	a2,a1
ffffffffc0205832:	85aa                	mv	a1,a0
ffffffffc0205834:	854a                	mv	a0,s2
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205836:	ed06                	sd	ra,152(sp)
ffffffffc0205838:	e526                	sd	s1,136(sp)
ffffffffc020583a:	f4d6                	sd	s5,104(sp)
ffffffffc020583c:	ecde                	sd	s7,88(sp)
ffffffffc020583e:	e8e2                	sd	s8,80(sp)
ffffffffc0205840:	e4e6                	sd	s9,72(sp)
ffffffffc0205842:	e0ea                	sd	s10,64(sp)
ffffffffc0205844:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205846:	a76ff0ef          	jal	ra,ffffffffc0204abc <user_mem_check>
ffffffffc020584a:	40050463          	beqz	a0,ffffffffc0205c52 <do_execve+0x446>
    memset(local_name, 0, sizeof(local_name));
ffffffffc020584e:	4641                	li	a2,16
ffffffffc0205850:	4581                	li	a1,0
ffffffffc0205852:	1008                	addi	a0,sp,32
ffffffffc0205854:	5c1000ef          	jal	ra,ffffffffc0206614 <memset>
    memcpy(local_name, name, len);
ffffffffc0205858:	47bd                	li	a5,15
ffffffffc020585a:	8622                	mv	a2,s0
ffffffffc020585c:	0687ee63          	bltu	a5,s0,ffffffffc02058d8 <do_execve+0xcc>
ffffffffc0205860:	85ce                	mv	a1,s3
ffffffffc0205862:	1008                	addi	a0,sp,32
ffffffffc0205864:	5c3000ef          	jal	ra,ffffffffc0206626 <memcpy>
    if (mm != NULL) {
ffffffffc0205868:	06090f63          	beqz	s2,ffffffffc02058e6 <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc020586c:	00002517          	auipc	a0,0x2
ffffffffc0205870:	31450513          	addi	a0,a0,788 # ffffffffc0207b80 <default_pmm_manager+0x7f0>
ffffffffc0205874:	953fa0ef          	jal	ra,ffffffffc02001c6 <cputs>
        lcr3(boot_cr3);
ffffffffc0205878:	000a7797          	auipc	a5,0xa7
ffffffffc020587c:	d0878793          	addi	a5,a5,-760 # ffffffffc02ac580 <boot_cr3>
ffffffffc0205880:	639c                	ld	a5,0(a5)
ffffffffc0205882:	577d                	li	a4,-1
ffffffffc0205884:	177e                	slli	a4,a4,0x3f
ffffffffc0205886:	83b1                	srli	a5,a5,0xc
ffffffffc0205888:	8fd9                	or	a5,a5,a4
ffffffffc020588a:	18079073          	csrw	satp,a5
ffffffffc020588e:	03092783          	lw	a5,48(s2)
ffffffffc0205892:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205896:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0) {
ffffffffc020589a:	28070b63          	beqz	a4,ffffffffc0205b30 <do_execve+0x324>
        current->mm = NULL;
ffffffffc020589e:	000a3783          	ld	a5,0(s4)
ffffffffc02058a2:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc02058a6:	82dfe0ef          	jal	ra,ffffffffc02040d2 <mm_create>
ffffffffc02058aa:	892a                	mv	s2,a0
ffffffffc02058ac:	c135                	beqz	a0,ffffffffc0205910 <do_execve+0x104>
    if (setup_pgdir(mm) != 0) {
ffffffffc02058ae:	d96ff0ef          	jal	ra,ffffffffc0204e44 <setup_pgdir>
ffffffffc02058b2:	e931                	bnez	a0,ffffffffc0205906 <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02058b4:	000b2703          	lw	a4,0(s6)
ffffffffc02058b8:	464c47b7          	lui	a5,0x464c4
ffffffffc02058bc:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9af7>
ffffffffc02058c0:	04f70a63          	beq	a4,a5,ffffffffc0205914 <do_execve+0x108>
    put_pgdir(mm);
ffffffffc02058c4:	854a                	mv	a0,s2
ffffffffc02058c6:	d00ff0ef          	jal	ra,ffffffffc0204dc6 <put_pgdir>
    mm_destroy(mm);
ffffffffc02058ca:	854a                	mv	a0,s2
ffffffffc02058cc:	98dfe0ef          	jal	ra,ffffffffc0204258 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc02058d0:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc02058d2:	854e                	mv	a0,s3
ffffffffc02058d4:	b1bff0ef          	jal	ra,ffffffffc02053ee <do_exit>
    memcpy(local_name, name, len);
ffffffffc02058d8:	463d                	li	a2,15
ffffffffc02058da:	85ce                	mv	a1,s3
ffffffffc02058dc:	1008                	addi	a0,sp,32
ffffffffc02058de:	549000ef          	jal	ra,ffffffffc0206626 <memcpy>
    if (mm != NULL) {
ffffffffc02058e2:	f80915e3          	bnez	s2,ffffffffc020586c <do_execve+0x60>
    if (current->mm != NULL) {
ffffffffc02058e6:	000a3783          	ld	a5,0(s4)
ffffffffc02058ea:	779c                	ld	a5,40(a5)
ffffffffc02058ec:	dfcd                	beqz	a5,ffffffffc02058a6 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc02058ee:	00003617          	auipc	a2,0x3
ffffffffc02058f2:	b3260613          	addi	a2,a2,-1230 # ffffffffc0208420 <default_pmm_manager+0x1090>
ffffffffc02058f6:	21a00593          	li	a1,538
ffffffffc02058fa:	00003517          	auipc	a0,0x3
ffffffffc02058fe:	f7e50513          	addi	a0,a0,-130 # ffffffffc0208878 <default_pmm_manager+0x14e8>
ffffffffc0205902:	b83fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    mm_destroy(mm);
ffffffffc0205906:	854a                	mv	a0,s2
ffffffffc0205908:	951fe0ef          	jal	ra,ffffffffc0204258 <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc020590c:	59f1                	li	s3,-4
ffffffffc020590e:	b7d1                	j	ffffffffc02058d2 <do_execve+0xc6>
ffffffffc0205910:	59f1                	li	s3,-4
ffffffffc0205912:	b7c1                	j	ffffffffc02058d2 <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205914:	038b5703          	lhu	a4,56(s6)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205918:	020b3403          	ld	s0,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020591c:	00371793          	slli	a5,a4,0x3
ffffffffc0205920:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205922:	945a                	add	s0,s0,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205924:	078e                	slli	a5,a5,0x3
ffffffffc0205926:	97a2                	add	a5,a5,s0
ffffffffc0205928:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc020592a:	02f47b63          	bleu	a5,s0,ffffffffc0205960 <do_execve+0x154>
    return KADDR(page2pa(page));
ffffffffc020592e:	5bfd                	li	s7,-1
ffffffffc0205930:	00cbd793          	srli	a5,s7,0xc
    return page - pages + nbase;
ffffffffc0205934:	000a7d97          	auipc	s11,0xa7
ffffffffc0205938:	c54d8d93          	addi	s11,s11,-940 # ffffffffc02ac588 <pages>
ffffffffc020593c:	00003d17          	auipc	s10,0x3
ffffffffc0205940:	404d0d13          	addi	s10,s10,1028 # ffffffffc0208d40 <nbase>
    return KADDR(page2pa(page));
ffffffffc0205944:	e43e                	sd	a5,8(sp)
ffffffffc0205946:	000a7c97          	auipc	s9,0xa7
ffffffffc020594a:	bd2c8c93          	addi	s9,s9,-1070 # ffffffffc02ac518 <npage>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc020594e:	4018                	lw	a4,0(s0)
ffffffffc0205950:	4785                	li	a5,1
ffffffffc0205952:	0ef70d63          	beq	a4,a5,ffffffffc0205a4c <do_execve+0x240>
    for (; ph < ph_end; ph ++) {
ffffffffc0205956:	67e2                	ld	a5,24(sp)
ffffffffc0205958:	03840413          	addi	s0,s0,56
ffffffffc020595c:	fef469e3          	bltu	s0,a5,ffffffffc020594e <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0205960:	4701                	li	a4,0
ffffffffc0205962:	46ad                	li	a3,11
ffffffffc0205964:	00100637          	lui	a2,0x100
ffffffffc0205968:	7ff005b7          	lui	a1,0x7ff00
ffffffffc020596c:	854a                	mv	a0,s2
ffffffffc020596e:	93dfe0ef          	jal	ra,ffffffffc02042aa <mm_map>
ffffffffc0205972:	89aa                	mv	s3,a0
ffffffffc0205974:	1a051463          	bnez	a0,ffffffffc0205b1c <do_execve+0x310>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205978:	01893503          	ld	a0,24(s2)
ffffffffc020597c:	467d                	li	a2,31
ffffffffc020597e:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205982:	983fd0ef          	jal	ra,ffffffffc0203304 <pgdir_alloc_page>
ffffffffc0205986:	36050263          	beqz	a0,ffffffffc0205cea <do_execve+0x4de>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc020598a:	01893503          	ld	a0,24(s2)
ffffffffc020598e:	467d                	li	a2,31
ffffffffc0205990:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205994:	971fd0ef          	jal	ra,ffffffffc0203304 <pgdir_alloc_page>
ffffffffc0205998:	32050963          	beqz	a0,ffffffffc0205cca <do_execve+0x4be>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc020599c:	01893503          	ld	a0,24(s2)
ffffffffc02059a0:	467d                	li	a2,31
ffffffffc02059a2:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc02059a6:	95ffd0ef          	jal	ra,ffffffffc0203304 <pgdir_alloc_page>
ffffffffc02059aa:	30050063          	beqz	a0,ffffffffc0205caa <do_execve+0x49e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc02059ae:	01893503          	ld	a0,24(s2)
ffffffffc02059b2:	467d                	li	a2,31
ffffffffc02059b4:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc02059b8:	94dfd0ef          	jal	ra,ffffffffc0203304 <pgdir_alloc_page>
ffffffffc02059bc:	2c050763          	beqz	a0,ffffffffc0205c8a <do_execve+0x47e>
    mm->mm_count += 1;
ffffffffc02059c0:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc02059c4:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059c8:	01893683          	ld	a3,24(s2)
ffffffffc02059cc:	2785                	addiw	a5,a5,1
ffffffffc02059ce:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc02059d2:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_exit_out_size+0xf55a0>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059d6:	c02007b7          	lui	a5,0xc0200
ffffffffc02059da:	28f6ec63          	bltu	a3,a5,ffffffffc0205c72 <do_execve+0x466>
ffffffffc02059de:	000a7797          	auipc	a5,0xa7
ffffffffc02059e2:	b9a78793          	addi	a5,a5,-1126 # ffffffffc02ac578 <va_pa_offset>
ffffffffc02059e6:	639c                	ld	a5,0(a5)
ffffffffc02059e8:	577d                	li	a4,-1
ffffffffc02059ea:	177e                	slli	a4,a4,0x3f
ffffffffc02059ec:	8e9d                	sub	a3,a3,a5
ffffffffc02059ee:	00c6d793          	srli	a5,a3,0xc
ffffffffc02059f2:	f654                	sd	a3,168(a2)
ffffffffc02059f4:	8fd9                	or	a5,a5,a4
ffffffffc02059f6:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc02059fa:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02059fc:	4581                	li	a1,0
ffffffffc02059fe:	12000613          	li	a2,288
ffffffffc0205a02:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0205a04:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205a08:	40d000ef          	jal	ra,ffffffffc0206614 <memset>
    tf->epc = elf->e_entry;
ffffffffc0205a0c:	018b3703          	ld	a4,24(s6)
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a10:	4785                	li	a5,1
    set_proc_name(current, local_name);
ffffffffc0205a12:	000a3503          	ld	a0,0(s4)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0205a16:	edf4f493          	andi	s1,s1,-289
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a1a:	07fe                	slli	a5,a5,0x1f
ffffffffc0205a1c:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0205a1e:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0205a22:	10943023          	sd	s1,256(s0)
    set_proc_name(current, local_name);
ffffffffc0205a26:	100c                	addi	a1,sp,32
ffffffffc0205a28:	ca8ff0ef          	jal	ra,ffffffffc0204ed0 <set_proc_name>
}
ffffffffc0205a2c:	60ea                	ld	ra,152(sp)
ffffffffc0205a2e:	644a                	ld	s0,144(sp)
ffffffffc0205a30:	854e                	mv	a0,s3
ffffffffc0205a32:	64aa                	ld	s1,136(sp)
ffffffffc0205a34:	690a                	ld	s2,128(sp)
ffffffffc0205a36:	79e6                	ld	s3,120(sp)
ffffffffc0205a38:	7a46                	ld	s4,112(sp)
ffffffffc0205a3a:	7aa6                	ld	s5,104(sp)
ffffffffc0205a3c:	7b06                	ld	s6,96(sp)
ffffffffc0205a3e:	6be6                	ld	s7,88(sp)
ffffffffc0205a40:	6c46                	ld	s8,80(sp)
ffffffffc0205a42:	6ca6                	ld	s9,72(sp)
ffffffffc0205a44:	6d06                	ld	s10,64(sp)
ffffffffc0205a46:	7de2                	ld	s11,56(sp)
ffffffffc0205a48:	610d                	addi	sp,sp,160
ffffffffc0205a4a:	8082                	ret
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205a4c:	7410                	ld	a2,40(s0)
ffffffffc0205a4e:	701c                	ld	a5,32(s0)
ffffffffc0205a50:	20f66363          	bltu	a2,a5,ffffffffc0205c56 <do_execve+0x44a>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205a54:	405c                	lw	a5,4(s0)
ffffffffc0205a56:	0017f693          	andi	a3,a5,1
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a5a:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205a5e:	068a                	slli	a3,a3,0x2
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a60:	0e071263          	bnez	a4,ffffffffc0205b44 <do_execve+0x338>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a64:	4745                	li	a4,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a66:	8b91                	andi	a5,a5,4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a68:	e03a                	sd	a4,0(sp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a6a:	c789                	beqz	a5,ffffffffc0205a74 <do_execve+0x268>
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205a6c:	47cd                	li	a5,19
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a6e:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205a72:	e03e                	sd	a5,0(sp)
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205a74:	0026f793          	andi	a5,a3,2
ffffffffc0205a78:	efe1                	bnez	a5,ffffffffc0205b50 <do_execve+0x344>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205a7a:	0046f793          	andi	a5,a3,4
ffffffffc0205a7e:	c789                	beqz	a5,ffffffffc0205a88 <do_execve+0x27c>
ffffffffc0205a80:	6782                	ld	a5,0(sp)
ffffffffc0205a82:	0087e793          	ori	a5,a5,8
ffffffffc0205a86:	e03e                	sd	a5,0(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205a88:	680c                	ld	a1,16(s0)
ffffffffc0205a8a:	4701                	li	a4,0
ffffffffc0205a8c:	854a                	mv	a0,s2
ffffffffc0205a8e:	81dfe0ef          	jal	ra,ffffffffc02042aa <mm_map>
ffffffffc0205a92:	89aa                	mv	s3,a0
ffffffffc0205a94:	e541                	bnez	a0,ffffffffc0205b1c <do_execve+0x310>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a96:	01043b83          	ld	s7,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205a9a:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205a9e:	00843a83          	ld	s5,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205aa2:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205aa4:	99de                	add	s3,s3,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205aa6:	9ada                	add	s5,s5,s6
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205aa8:	00fbfc33          	and	s8,s7,a5
        while (start < end) {
ffffffffc0205aac:	053bef63          	bltu	s7,s3,ffffffffc0205b0a <do_execve+0x2fe>
ffffffffc0205ab0:	aa79                	j	ffffffffc0205c4e <do_execve+0x442>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205ab2:	6785                	lui	a5,0x1
ffffffffc0205ab4:	418b8533          	sub	a0,s7,s8
ffffffffc0205ab8:	9c3e                	add	s8,s8,a5
ffffffffc0205aba:	417c0833          	sub	a6,s8,s7
            if (end < la) {
ffffffffc0205abe:	0189f463          	bleu	s8,s3,ffffffffc0205ac6 <do_execve+0x2ba>
                size -= la - end;
ffffffffc0205ac2:	41798833          	sub	a6,s3,s7
    return page - pages + nbase;
ffffffffc0205ac6:	000db683          	ld	a3,0(s11)
ffffffffc0205aca:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205ace:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205ad0:	40d486b3          	sub	a3,s1,a3
ffffffffc0205ad4:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205ad6:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205ada:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205adc:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205ae0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205ae2:	16c5fc63          	bleu	a2,a1,ffffffffc0205c5a <do_execve+0x44e>
ffffffffc0205ae6:	000a7797          	auipc	a5,0xa7
ffffffffc0205aea:	a9278793          	addi	a5,a5,-1390 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0205aee:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205af2:	85d6                	mv	a1,s5
ffffffffc0205af4:	8642                	mv	a2,a6
ffffffffc0205af6:	96c6                	add	a3,a3,a7
ffffffffc0205af8:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205afa:	9bc2                	add	s7,s7,a6
ffffffffc0205afc:	e842                	sd	a6,16(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205afe:	329000ef          	jal	ra,ffffffffc0206626 <memcpy>
            start += size, from += size;
ffffffffc0205b02:	6842                	ld	a6,16(sp)
ffffffffc0205b04:	9ac2                	add	s5,s5,a6
        while (start < end) {
ffffffffc0205b06:	053bf863          	bleu	s3,s7,ffffffffc0205b56 <do_execve+0x34a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205b0a:	01893503          	ld	a0,24(s2)
ffffffffc0205b0e:	6602                	ld	a2,0(sp)
ffffffffc0205b10:	85e2                	mv	a1,s8
ffffffffc0205b12:	ff2fd0ef          	jal	ra,ffffffffc0203304 <pgdir_alloc_page>
ffffffffc0205b16:	84aa                	mv	s1,a0
ffffffffc0205b18:	fd49                	bnez	a0,ffffffffc0205ab2 <do_execve+0x2a6>
        ret = -E_NO_MEM;
ffffffffc0205b1a:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc0205b1c:	854a                	mv	a0,s2
ffffffffc0205b1e:	8dbfe0ef          	jal	ra,ffffffffc02043f8 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205b22:	854a                	mv	a0,s2
ffffffffc0205b24:	aa2ff0ef          	jal	ra,ffffffffc0204dc6 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205b28:	854a                	mv	a0,s2
ffffffffc0205b2a:	f2efe0ef          	jal	ra,ffffffffc0204258 <mm_destroy>
    return ret;
ffffffffc0205b2e:	b355                	j	ffffffffc02058d2 <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0205b30:	854a                	mv	a0,s2
ffffffffc0205b32:	8c7fe0ef          	jal	ra,ffffffffc02043f8 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205b36:	854a                	mv	a0,s2
ffffffffc0205b38:	a8eff0ef          	jal	ra,ffffffffc0204dc6 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205b3c:	854a                	mv	a0,s2
ffffffffc0205b3e:	f1afe0ef          	jal	ra,ffffffffc0204258 <mm_destroy>
ffffffffc0205b42:	bbb1                	j	ffffffffc020589e <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b44:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b48:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b4a:	2681                	sext.w	a3,a3
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b4c:	f20790e3          	bnez	a5,ffffffffc0205a6c <do_execve+0x260>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205b50:	47dd                	li	a5,23
ffffffffc0205b52:	e03e                	sd	a5,0(sp)
ffffffffc0205b54:	b71d                	j	ffffffffc0205a7a <do_execve+0x26e>
ffffffffc0205b56:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc0205b5a:	7414                	ld	a3,40(s0)
ffffffffc0205b5c:	99b6                	add	s3,s3,a3
        if (start < la) {
ffffffffc0205b5e:	098bf163          	bleu	s8,s7,ffffffffc0205be0 <do_execve+0x3d4>
            if (start == end) {
ffffffffc0205b62:	df798ae3          	beq	s3,s7,ffffffffc0205956 <do_execve+0x14a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205b66:	6505                	lui	a0,0x1
ffffffffc0205b68:	955e                	add	a0,a0,s7
ffffffffc0205b6a:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0205b6e:	41798ab3          	sub	s5,s3,s7
            if (end < la) {
ffffffffc0205b72:	0d89fb63          	bleu	s8,s3,ffffffffc0205c48 <do_execve+0x43c>
    return page - pages + nbase;
ffffffffc0205b76:	000db683          	ld	a3,0(s11)
ffffffffc0205b7a:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205b7e:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205b80:	40d486b3          	sub	a3,s1,a3
ffffffffc0205b84:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205b86:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205b8a:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205b8c:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b90:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b92:	0cc5f463          	bleu	a2,a1,ffffffffc0205c5a <do_execve+0x44e>
ffffffffc0205b96:	000a7617          	auipc	a2,0xa7
ffffffffc0205b9a:	9e260613          	addi	a2,a2,-1566 # ffffffffc02ac578 <va_pa_offset>
ffffffffc0205b9e:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205ba2:	4581                	li	a1,0
ffffffffc0205ba4:	8656                	mv	a2,s5
ffffffffc0205ba6:	96c2                	add	a3,a3,a6
ffffffffc0205ba8:	9536                	add	a0,a0,a3
ffffffffc0205baa:	26b000ef          	jal	ra,ffffffffc0206614 <memset>
            start += size;
ffffffffc0205bae:	017a8733          	add	a4,s5,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205bb2:	0389f463          	bleu	s8,s3,ffffffffc0205bda <do_execve+0x3ce>
ffffffffc0205bb6:	dae980e3          	beq	s3,a4,ffffffffc0205956 <do_execve+0x14a>
ffffffffc0205bba:	00003697          	auipc	a3,0x3
ffffffffc0205bbe:	88e68693          	addi	a3,a3,-1906 # ffffffffc0208448 <default_pmm_manager+0x10b8>
ffffffffc0205bc2:	00001617          	auipc	a2,0x1
ffffffffc0205bc6:	08660613          	addi	a2,a2,134 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0205bca:	26f00593          	li	a1,623
ffffffffc0205bce:	00003517          	auipc	a0,0x3
ffffffffc0205bd2:	caa50513          	addi	a0,a0,-854 # ffffffffc0208878 <default_pmm_manager+0x14e8>
ffffffffc0205bd6:	8affa0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0205bda:	ff8710e3          	bne	a4,s8,ffffffffc0205bba <do_execve+0x3ae>
ffffffffc0205bde:	8be2                	mv	s7,s8
ffffffffc0205be0:	000a7a97          	auipc	s5,0xa7
ffffffffc0205be4:	998a8a93          	addi	s5,s5,-1640 # ffffffffc02ac578 <va_pa_offset>
        while (start < end) {
ffffffffc0205be8:	053be763          	bltu	s7,s3,ffffffffc0205c36 <do_execve+0x42a>
ffffffffc0205bec:	b3ad                	j	ffffffffc0205956 <do_execve+0x14a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205bee:	6785                	lui	a5,0x1
ffffffffc0205bf0:	418b8533          	sub	a0,s7,s8
ffffffffc0205bf4:	9c3e                	add	s8,s8,a5
ffffffffc0205bf6:	417c0633          	sub	a2,s8,s7
            if (end < la) {
ffffffffc0205bfa:	0189f463          	bleu	s8,s3,ffffffffc0205c02 <do_execve+0x3f6>
                size -= la - end;
ffffffffc0205bfe:	41798633          	sub	a2,s3,s7
    return page - pages + nbase;
ffffffffc0205c02:	000db683          	ld	a3,0(s11)
ffffffffc0205c06:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205c0a:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205c0c:	40d486b3          	sub	a3,s1,a3
ffffffffc0205c10:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205c12:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205c16:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0205c18:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c1c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c1e:	02b87e63          	bleu	a1,a6,ffffffffc0205c5a <do_execve+0x44e>
ffffffffc0205c22:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc0205c26:	9bb2                	add	s7,s7,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c28:	4581                	li	a1,0
ffffffffc0205c2a:	96c2                	add	a3,a3,a6
ffffffffc0205c2c:	9536                	add	a0,a0,a3
ffffffffc0205c2e:	1e7000ef          	jal	ra,ffffffffc0206614 <memset>
        while (start < end) {
ffffffffc0205c32:	d33bf2e3          	bleu	s3,s7,ffffffffc0205956 <do_execve+0x14a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205c36:	01893503          	ld	a0,24(s2)
ffffffffc0205c3a:	6602                	ld	a2,0(sp)
ffffffffc0205c3c:	85e2                	mv	a1,s8
ffffffffc0205c3e:	ec6fd0ef          	jal	ra,ffffffffc0203304 <pgdir_alloc_page>
ffffffffc0205c42:	84aa                	mv	s1,a0
ffffffffc0205c44:	f54d                	bnez	a0,ffffffffc0205bee <do_execve+0x3e2>
ffffffffc0205c46:	bdd1                	j	ffffffffc0205b1a <do_execve+0x30e>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205c48:	417c0ab3          	sub	s5,s8,s7
ffffffffc0205c4c:	b72d                	j	ffffffffc0205b76 <do_execve+0x36a>
        while (start < end) {
ffffffffc0205c4e:	89de                	mv	s3,s7
ffffffffc0205c50:	b729                	j	ffffffffc0205b5a <do_execve+0x34e>
        return -E_INVAL;
ffffffffc0205c52:	59f5                	li	s3,-3
ffffffffc0205c54:	bbe1                	j	ffffffffc0205a2c <do_execve+0x220>
            ret = -E_INVAL_ELF;
ffffffffc0205c56:	59e1                	li	s3,-8
ffffffffc0205c58:	b5d1                	j	ffffffffc0205b1c <do_execve+0x310>
ffffffffc0205c5a:	00001617          	auipc	a2,0x1
ffffffffc0205c5e:	78660613          	addi	a2,a2,1926 # ffffffffc02073e0 <default_pmm_manager+0x50>
ffffffffc0205c62:	06900593          	li	a1,105
ffffffffc0205c66:	00001517          	auipc	a0,0x1
ffffffffc0205c6a:	7a250513          	addi	a0,a0,1954 # ffffffffc0207408 <default_pmm_manager+0x78>
ffffffffc0205c6e:	817fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205c72:	00001617          	auipc	a2,0x1
ffffffffc0205c76:	7a660613          	addi	a2,a2,1958 # ffffffffc0207418 <default_pmm_manager+0x88>
ffffffffc0205c7a:	28a00593          	li	a1,650
ffffffffc0205c7e:	00003517          	auipc	a0,0x3
ffffffffc0205c82:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0208878 <default_pmm_manager+0x14e8>
ffffffffc0205c86:	ffefa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c8a:	00003697          	auipc	a3,0x3
ffffffffc0205c8e:	8d668693          	addi	a3,a3,-1834 # ffffffffc0208560 <default_pmm_manager+0x11d0>
ffffffffc0205c92:	00001617          	auipc	a2,0x1
ffffffffc0205c96:	fb660613          	addi	a2,a2,-74 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0205c9a:	28500593          	li	a1,645
ffffffffc0205c9e:	00003517          	auipc	a0,0x3
ffffffffc0205ca2:	bda50513          	addi	a0,a0,-1062 # ffffffffc0208878 <default_pmm_manager+0x14e8>
ffffffffc0205ca6:	fdefa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205caa:	00003697          	auipc	a3,0x3
ffffffffc0205cae:	86e68693          	addi	a3,a3,-1938 # ffffffffc0208518 <default_pmm_manager+0x1188>
ffffffffc0205cb2:	00001617          	auipc	a2,0x1
ffffffffc0205cb6:	f9660613          	addi	a2,a2,-106 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0205cba:	28400593          	li	a1,644
ffffffffc0205cbe:	00003517          	auipc	a0,0x3
ffffffffc0205cc2:	bba50513          	addi	a0,a0,-1094 # ffffffffc0208878 <default_pmm_manager+0x14e8>
ffffffffc0205cc6:	fbefa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205cca:	00003697          	auipc	a3,0x3
ffffffffc0205cce:	80668693          	addi	a3,a3,-2042 # ffffffffc02084d0 <default_pmm_manager+0x1140>
ffffffffc0205cd2:	00001617          	auipc	a2,0x1
ffffffffc0205cd6:	f7660613          	addi	a2,a2,-138 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0205cda:	28300593          	li	a1,643
ffffffffc0205cde:	00003517          	auipc	a0,0x3
ffffffffc0205ce2:	b9a50513          	addi	a0,a0,-1126 # ffffffffc0208878 <default_pmm_manager+0x14e8>
ffffffffc0205ce6:	f9efa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205cea:	00002697          	auipc	a3,0x2
ffffffffc0205cee:	79e68693          	addi	a3,a3,1950 # ffffffffc0208488 <default_pmm_manager+0x10f8>
ffffffffc0205cf2:	00001617          	auipc	a2,0x1
ffffffffc0205cf6:	f5660613          	addi	a2,a2,-170 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0205cfa:	28200593          	li	a1,642
ffffffffc0205cfe:	00003517          	auipc	a0,0x3
ffffffffc0205d02:	b7a50513          	addi	a0,a0,-1158 # ffffffffc0208878 <default_pmm_manager+0x14e8>
ffffffffc0205d06:	f7efa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205d0a <do_yield>:
    current->need_resched = 1;
ffffffffc0205d0a:	000a7797          	auipc	a5,0xa7
ffffffffc0205d0e:	82678793          	addi	a5,a5,-2010 # ffffffffc02ac530 <current>
ffffffffc0205d12:	639c                	ld	a5,0(a5)
ffffffffc0205d14:	4705                	li	a4,1
}
ffffffffc0205d16:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205d18:	ef98                	sd	a4,24(a5)
}
ffffffffc0205d1a:	8082                	ret

ffffffffc0205d1c <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205d1c:	1101                	addi	sp,sp,-32
ffffffffc0205d1e:	e822                	sd	s0,16(sp)
ffffffffc0205d20:	e426                	sd	s1,8(sp)
ffffffffc0205d22:	ec06                	sd	ra,24(sp)
ffffffffc0205d24:	842e                	mv	s0,a1
ffffffffc0205d26:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205d28:	cd81                	beqz	a1,ffffffffc0205d40 <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205d2a:	000a7797          	auipc	a5,0xa7
ffffffffc0205d2e:	80678793          	addi	a5,a5,-2042 # ffffffffc02ac530 <current>
ffffffffc0205d32:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205d34:	4685                	li	a3,1
ffffffffc0205d36:	4611                	li	a2,4
ffffffffc0205d38:	7788                	ld	a0,40(a5)
ffffffffc0205d3a:	d83fe0ef          	jal	ra,ffffffffc0204abc <user_mem_check>
ffffffffc0205d3e:	c909                	beqz	a0,ffffffffc0205d50 <do_wait+0x34>
ffffffffc0205d40:	85a2                	mv	a1,s0
}
ffffffffc0205d42:	6442                	ld	s0,16(sp)
ffffffffc0205d44:	60e2                	ld	ra,24(sp)
ffffffffc0205d46:	8526                	mv	a0,s1
ffffffffc0205d48:	64a2                	ld	s1,8(sp)
ffffffffc0205d4a:	6105                	addi	sp,sp,32
ffffffffc0205d4c:	ff0ff06f          	j	ffffffffc020553c <do_wait.part.1>
ffffffffc0205d50:	60e2                	ld	ra,24(sp)
ffffffffc0205d52:	6442                	ld	s0,16(sp)
ffffffffc0205d54:	64a2                	ld	s1,8(sp)
ffffffffc0205d56:	5575                	li	a0,-3
ffffffffc0205d58:	6105                	addi	sp,sp,32
ffffffffc0205d5a:	8082                	ret

ffffffffc0205d5c <do_kill>:
do_kill(int pid) {
ffffffffc0205d5c:	1141                	addi	sp,sp,-16
ffffffffc0205d5e:	e406                	sd	ra,8(sp)
ffffffffc0205d60:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc0205d62:	a04ff0ef          	jal	ra,ffffffffc0204f66 <find_proc>
ffffffffc0205d66:	cd0d                	beqz	a0,ffffffffc0205da0 <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205d68:	0b052703          	lw	a4,176(a0)
ffffffffc0205d6c:	00177693          	andi	a3,a4,1
ffffffffc0205d70:	e695                	bnez	a3,ffffffffc0205d9c <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205d72:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205d76:	00176713          	ori	a4,a4,1
ffffffffc0205d7a:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205d7e:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205d80:	0006c763          	bltz	a3,ffffffffc0205d8e <do_kill+0x32>
}
ffffffffc0205d84:	8522                	mv	a0,s0
ffffffffc0205d86:	60a2                	ld	ra,8(sp)
ffffffffc0205d88:	6402                	ld	s0,0(sp)
ffffffffc0205d8a:	0141                	addi	sp,sp,16
ffffffffc0205d8c:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205d8e:	1e6000ef          	jal	ra,ffffffffc0205f74 <wakeup_proc>
}
ffffffffc0205d92:	8522                	mv	a0,s0
ffffffffc0205d94:	60a2                	ld	ra,8(sp)
ffffffffc0205d96:	6402                	ld	s0,0(sp)
ffffffffc0205d98:	0141                	addi	sp,sp,16
ffffffffc0205d9a:	8082                	ret
        return -E_KILLED;
ffffffffc0205d9c:	545d                	li	s0,-9
ffffffffc0205d9e:	b7dd                	j	ffffffffc0205d84 <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205da0:	5475                	li	s0,-3
ffffffffc0205da2:	b7cd                	j	ffffffffc0205d84 <do_kill+0x28>

ffffffffc0205da4 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205da4:	000a7797          	auipc	a5,0xa7
ffffffffc0205da8:	8cc78793          	addi	a5,a5,-1844 # ffffffffc02ac670 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205dac:	1101                	addi	sp,sp,-32
ffffffffc0205dae:	000a7717          	auipc	a4,0xa7
ffffffffc0205db2:	8cf73523          	sd	a5,-1846(a4) # ffffffffc02ac678 <proc_list+0x8>
ffffffffc0205db6:	000a7717          	auipc	a4,0xa7
ffffffffc0205dba:	8af73d23          	sd	a5,-1862(a4) # ffffffffc02ac670 <proc_list>
ffffffffc0205dbe:	ec06                	sd	ra,24(sp)
ffffffffc0205dc0:	e822                	sd	s0,16(sp)
ffffffffc0205dc2:	e426                	sd	s1,8(sp)
ffffffffc0205dc4:	000a2797          	auipc	a5,0xa2
ffffffffc0205dc8:	73478793          	addi	a5,a5,1844 # ffffffffc02a84f8 <hash_list>
ffffffffc0205dcc:	000a6717          	auipc	a4,0xa6
ffffffffc0205dd0:	72c70713          	addi	a4,a4,1836 # ffffffffc02ac4f8 <is_panic>
ffffffffc0205dd4:	e79c                	sd	a5,8(a5)
ffffffffc0205dd6:	e39c                	sd	a5,0(a5)
ffffffffc0205dd8:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205dda:	fee79de3          	bne	a5,a4,ffffffffc0205dd4 <proc_init+0x30>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205dde:	ee3fe0ef          	jal	ra,ffffffffc0204cc0 <alloc_proc>
ffffffffc0205de2:	000a6717          	auipc	a4,0xa6
ffffffffc0205de6:	74a73b23          	sd	a0,1878(a4) # ffffffffc02ac538 <idleproc>
ffffffffc0205dea:	000a6497          	auipc	s1,0xa6
ffffffffc0205dee:	74e48493          	addi	s1,s1,1870 # ffffffffc02ac538 <idleproc>
ffffffffc0205df2:	c559                	beqz	a0,ffffffffc0205e80 <proc_init+0xdc>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205df4:	4709                	li	a4,2
ffffffffc0205df6:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0205df8:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205dfa:	00003717          	auipc	a4,0x3
ffffffffc0205dfe:	20670713          	addi	a4,a4,518 # ffffffffc0209000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0205e02:	00003597          	auipc	a1,0x3
ffffffffc0205e06:	98e58593          	addi	a1,a1,-1650 # ffffffffc0208790 <default_pmm_manager+0x1400>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e0a:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205e0c:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc0205e0e:	8c2ff0ef          	jal	ra,ffffffffc0204ed0 <set_proc_name>
    nr_process ++;
ffffffffc0205e12:	000a6797          	auipc	a5,0xa6
ffffffffc0205e16:	73678793          	addi	a5,a5,1846 # ffffffffc02ac548 <nr_process>
ffffffffc0205e1a:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205e1c:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e1e:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205e20:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e22:	4581                	li	a1,0
ffffffffc0205e24:	00000517          	auipc	a0,0x0
ffffffffc0205e28:	8c050513          	addi	a0,a0,-1856 # ffffffffc02056e4 <init_main>
    nr_process ++;
ffffffffc0205e2c:	000a6697          	auipc	a3,0xa6
ffffffffc0205e30:	70f6ae23          	sw	a5,1820(a3) # ffffffffc02ac548 <nr_process>
    current = idleproc;
ffffffffc0205e34:	000a6797          	auipc	a5,0xa6
ffffffffc0205e38:	6ee7be23          	sd	a4,1788(a5) # ffffffffc02ac530 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e3c:	d62ff0ef          	jal	ra,ffffffffc020539e <kernel_thread>
    if (pid <= 0) {
ffffffffc0205e40:	08a05c63          	blez	a0,ffffffffc0205ed8 <proc_init+0x134>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205e44:	922ff0ef          	jal	ra,ffffffffc0204f66 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0205e48:	00003597          	auipc	a1,0x3
ffffffffc0205e4c:	97058593          	addi	a1,a1,-1680 # ffffffffc02087b8 <default_pmm_manager+0x1428>
    initproc = find_proc(pid);
ffffffffc0205e50:	000a6797          	auipc	a5,0xa6
ffffffffc0205e54:	6ea7b823          	sd	a0,1776(a5) # ffffffffc02ac540 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0205e58:	878ff0ef          	jal	ra,ffffffffc0204ed0 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205e5c:	609c                	ld	a5,0(s1)
ffffffffc0205e5e:	cfa9                	beqz	a5,ffffffffc0205eb8 <proc_init+0x114>
ffffffffc0205e60:	43dc                	lw	a5,4(a5)
ffffffffc0205e62:	ebb9                	bnez	a5,ffffffffc0205eb8 <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e64:	000a6797          	auipc	a5,0xa6
ffffffffc0205e68:	6dc78793          	addi	a5,a5,1756 # ffffffffc02ac540 <initproc>
ffffffffc0205e6c:	639c                	ld	a5,0(a5)
ffffffffc0205e6e:	c78d                	beqz	a5,ffffffffc0205e98 <proc_init+0xf4>
ffffffffc0205e70:	43dc                	lw	a5,4(a5)
ffffffffc0205e72:	02879363          	bne	a5,s0,ffffffffc0205e98 <proc_init+0xf4>
}
ffffffffc0205e76:	60e2                	ld	ra,24(sp)
ffffffffc0205e78:	6442                	ld	s0,16(sp)
ffffffffc0205e7a:	64a2                	ld	s1,8(sp)
ffffffffc0205e7c:	6105                	addi	sp,sp,32
ffffffffc0205e7e:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0205e80:	00003617          	auipc	a2,0x3
ffffffffc0205e84:	8f860613          	addi	a2,a2,-1800 # ffffffffc0208778 <default_pmm_manager+0x13e8>
ffffffffc0205e88:	38100593          	li	a1,897
ffffffffc0205e8c:	00003517          	auipc	a0,0x3
ffffffffc0205e90:	9ec50513          	addi	a0,a0,-1556 # ffffffffc0208878 <default_pmm_manager+0x14e8>
ffffffffc0205e94:	df0fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e98:	00003697          	auipc	a3,0x3
ffffffffc0205e9c:	95068693          	addi	a3,a3,-1712 # ffffffffc02087e8 <default_pmm_manager+0x1458>
ffffffffc0205ea0:	00001617          	auipc	a2,0x1
ffffffffc0205ea4:	da860613          	addi	a2,a2,-600 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0205ea8:	39600593          	li	a1,918
ffffffffc0205eac:	00003517          	auipc	a0,0x3
ffffffffc0205eb0:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0208878 <default_pmm_manager+0x14e8>
ffffffffc0205eb4:	dd0fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205eb8:	00003697          	auipc	a3,0x3
ffffffffc0205ebc:	90868693          	addi	a3,a3,-1784 # ffffffffc02087c0 <default_pmm_manager+0x1430>
ffffffffc0205ec0:	00001617          	auipc	a2,0x1
ffffffffc0205ec4:	d8860613          	addi	a2,a2,-632 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0205ec8:	39500593          	li	a1,917
ffffffffc0205ecc:	00003517          	auipc	a0,0x3
ffffffffc0205ed0:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0208878 <default_pmm_manager+0x14e8>
ffffffffc0205ed4:	db0fa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("create init_main failed.\n");
ffffffffc0205ed8:	00003617          	auipc	a2,0x3
ffffffffc0205edc:	8c060613          	addi	a2,a2,-1856 # ffffffffc0208798 <default_pmm_manager+0x1408>
ffffffffc0205ee0:	38f00593          	li	a1,911
ffffffffc0205ee4:	00003517          	auipc	a0,0x3
ffffffffc0205ee8:	99450513          	addi	a0,a0,-1644 # ffffffffc0208878 <default_pmm_manager+0x14e8>
ffffffffc0205eec:	d98fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205ef0 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205ef0:	1141                	addi	sp,sp,-16
ffffffffc0205ef2:	e022                	sd	s0,0(sp)
ffffffffc0205ef4:	e406                	sd	ra,8(sp)
ffffffffc0205ef6:	000a6417          	auipc	s0,0xa6
ffffffffc0205efa:	63a40413          	addi	s0,s0,1594 # ffffffffc02ac530 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205efe:	6018                	ld	a4,0(s0)
ffffffffc0205f00:	6f1c                	ld	a5,24(a4)
ffffffffc0205f02:	dffd                	beqz	a5,ffffffffc0205f00 <cpu_idle+0x10>
            schedule();
ffffffffc0205f04:	0ec000ef          	jal	ra,ffffffffc0205ff0 <schedule>
ffffffffc0205f08:	bfdd                	j	ffffffffc0205efe <cpu_idle+0xe>

ffffffffc0205f0a <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0205f0a:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0205f0e:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0205f12:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0205f14:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0205f16:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0205f1a:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0205f1e:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0205f22:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0205f26:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0205f2a:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0205f2e:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0205f32:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0205f36:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0205f3a:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0205f3e:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0205f42:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0205f46:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0205f48:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0205f4a:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0205f4e:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0205f52:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0205f56:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0205f5a:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0205f5e:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0205f62:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0205f66:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0205f6a:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0205f6e:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0205f72:	8082                	ret

ffffffffc0205f74 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f74:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205f76:	1101                	addi	sp,sp,-32
ffffffffc0205f78:	ec06                	sd	ra,24(sp)
ffffffffc0205f7a:	e822                	sd	s0,16(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f7c:	478d                	li	a5,3
ffffffffc0205f7e:	04f70a63          	beq	a4,a5,ffffffffc0205fd2 <wakeup_proc+0x5e>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f82:	100027f3          	csrr	a5,sstatus
ffffffffc0205f86:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205f88:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f8a:	ef8d                	bnez	a5,ffffffffc0205fc4 <wakeup_proc+0x50>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205f8c:	4789                	li	a5,2
ffffffffc0205f8e:	00f70f63          	beq	a4,a5,ffffffffc0205fac <wakeup_proc+0x38>
            proc->state = PROC_RUNNABLE;
ffffffffc0205f92:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc0205f94:	0e052623          	sw	zero,236(a0)
    if (flag) {
ffffffffc0205f98:	e409                	bnez	s0,ffffffffc0205fa2 <wakeup_proc+0x2e>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205f9a:	60e2                	ld	ra,24(sp)
ffffffffc0205f9c:	6442                	ld	s0,16(sp)
ffffffffc0205f9e:	6105                	addi	sp,sp,32
ffffffffc0205fa0:	8082                	ret
ffffffffc0205fa2:	6442                	ld	s0,16(sp)
ffffffffc0205fa4:	60e2                	ld	ra,24(sp)
ffffffffc0205fa6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205fa8:	eacfa06f          	j	ffffffffc0200654 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205fac:	00003617          	auipc	a2,0x3
ffffffffc0205fb0:	91c60613          	addi	a2,a2,-1764 # ffffffffc02088c8 <default_pmm_manager+0x1538>
ffffffffc0205fb4:	45c9                	li	a1,18
ffffffffc0205fb6:	00003517          	auipc	a0,0x3
ffffffffc0205fba:	8fa50513          	addi	a0,a0,-1798 # ffffffffc02088b0 <default_pmm_manager+0x1520>
ffffffffc0205fbe:	d32fa0ef          	jal	ra,ffffffffc02004f0 <__warn>
ffffffffc0205fc2:	bfd9                	j	ffffffffc0205f98 <wakeup_proc+0x24>
ffffffffc0205fc4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0205fc6:	e94fa0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc0205fca:	6522                	ld	a0,8(sp)
ffffffffc0205fcc:	4405                	li	s0,1
ffffffffc0205fce:	4118                	lw	a4,0(a0)
ffffffffc0205fd0:	bf75                	j	ffffffffc0205f8c <wakeup_proc+0x18>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205fd2:	00003697          	auipc	a3,0x3
ffffffffc0205fd6:	8be68693          	addi	a3,a3,-1858 # ffffffffc0208890 <default_pmm_manager+0x1500>
ffffffffc0205fda:	00001617          	auipc	a2,0x1
ffffffffc0205fde:	c6e60613          	addi	a2,a2,-914 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0205fe2:	45a5                	li	a1,9
ffffffffc0205fe4:	00003517          	auipc	a0,0x3
ffffffffc0205fe8:	8cc50513          	addi	a0,a0,-1844 # ffffffffc02088b0 <default_pmm_manager+0x1520>
ffffffffc0205fec:	c98fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205ff0 <schedule>:

void
schedule(void) {
ffffffffc0205ff0:	1141                	addi	sp,sp,-16
ffffffffc0205ff2:	e406                	sd	ra,8(sp)
ffffffffc0205ff4:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205ff6:	100027f3          	csrr	a5,sstatus
ffffffffc0205ffa:	8b89                	andi	a5,a5,2
ffffffffc0205ffc:	4401                	li	s0,0
ffffffffc0205ffe:	e3d1                	bnez	a5,ffffffffc0206082 <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0206000:	000a6797          	auipc	a5,0xa6
ffffffffc0206004:	53078793          	addi	a5,a5,1328 # ffffffffc02ac530 <current>
ffffffffc0206008:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020600c:	000a6797          	auipc	a5,0xa6
ffffffffc0206010:	52c78793          	addi	a5,a5,1324 # ffffffffc02ac538 <idleproc>
ffffffffc0206014:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc0206016:	0008bc23          	sd	zero,24(a7) # 2018 <_binary_obj___user_faultread_out_size-0x7560>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020601a:	04a88e63          	beq	a7,a0,ffffffffc0206076 <schedule+0x86>
ffffffffc020601e:	0c888693          	addi	a3,a7,200
ffffffffc0206022:	000a6617          	auipc	a2,0xa6
ffffffffc0206026:	64e60613          	addi	a2,a2,1614 # ffffffffc02ac670 <proc_list>
        le = last;
ffffffffc020602a:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc020602c:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc020602e:	4809                	li	a6,2
    return listelm->next;
ffffffffc0206030:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0206032:	00c78863          	beq	a5,a2,ffffffffc0206042 <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206036:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc020603a:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc020603e:	01070463          	beq	a4,a6,ffffffffc0206046 <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc0206042:	fef697e3          	bne	a3,a5,ffffffffc0206030 <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206046:	c589                	beqz	a1,ffffffffc0206050 <schedule+0x60>
ffffffffc0206048:	4198                	lw	a4,0(a1)
ffffffffc020604a:	4789                	li	a5,2
ffffffffc020604c:	00f70e63          	beq	a4,a5,ffffffffc0206068 <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0206050:	451c                	lw	a5,8(a0)
ffffffffc0206052:	2785                	addiw	a5,a5,1
ffffffffc0206054:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0206056:	00a88463          	beq	a7,a0,ffffffffc020605e <schedule+0x6e>
            proc_run(next);
ffffffffc020605a:	ea1fe0ef          	jal	ra,ffffffffc0204efa <proc_run>
    if (flag) {
ffffffffc020605e:	e419                	bnez	s0,ffffffffc020606c <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206060:	60a2                	ld	ra,8(sp)
ffffffffc0206062:	6402                	ld	s0,0(sp)
ffffffffc0206064:	0141                	addi	sp,sp,16
ffffffffc0206066:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206068:	852e                	mv	a0,a1
ffffffffc020606a:	b7dd                	j	ffffffffc0206050 <schedule+0x60>
}
ffffffffc020606c:	6402                	ld	s0,0(sp)
ffffffffc020606e:	60a2                	ld	ra,8(sp)
ffffffffc0206070:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0206072:	de2fa06f          	j	ffffffffc0200654 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206076:	000a6617          	auipc	a2,0xa6
ffffffffc020607a:	5fa60613          	addi	a2,a2,1530 # ffffffffc02ac670 <proc_list>
ffffffffc020607e:	86b2                	mv	a3,a2
ffffffffc0206080:	b76d                	j	ffffffffc020602a <schedule+0x3a>
        intr_disable();
ffffffffc0206082:	dd8fa0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc0206086:	4405                	li	s0,1
ffffffffc0206088:	bfa5                	j	ffffffffc0206000 <schedule+0x10>

ffffffffc020608a <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc020608a:	000a6797          	auipc	a5,0xa6
ffffffffc020608e:	4a678793          	addi	a5,a5,1190 # ffffffffc02ac530 <current>
ffffffffc0206092:	639c                	ld	a5,0(a5)
}
ffffffffc0206094:	43c8                	lw	a0,4(a5)
ffffffffc0206096:	8082                	ret

ffffffffc0206098 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0206098:	4501                	li	a0,0
ffffffffc020609a:	8082                	ret

ffffffffc020609c <sys_putc>:
    cputchar(c);
ffffffffc020609c:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc020609e:	1141                	addi	sp,sp,-16
ffffffffc02060a0:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc02060a2:	920fa0ef          	jal	ra,ffffffffc02001c2 <cputchar>
}
ffffffffc02060a6:	60a2                	ld	ra,8(sp)
ffffffffc02060a8:	4501                	li	a0,0
ffffffffc02060aa:	0141                	addi	sp,sp,16
ffffffffc02060ac:	8082                	ret

ffffffffc02060ae <sys_kill>:
    return do_kill(pid);
ffffffffc02060ae:	4108                	lw	a0,0(a0)
ffffffffc02060b0:	cadff06f          	j	ffffffffc0205d5c <do_kill>

ffffffffc02060b4 <sys_yield>:
    return do_yield();
ffffffffc02060b4:	c57ff06f          	j	ffffffffc0205d0a <do_yield>

ffffffffc02060b8 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc02060b8:	6d14                	ld	a3,24(a0)
ffffffffc02060ba:	6910                	ld	a2,16(a0)
ffffffffc02060bc:	650c                	ld	a1,8(a0)
ffffffffc02060be:	6108                	ld	a0,0(a0)
ffffffffc02060c0:	f4cff06f          	j	ffffffffc020580c <do_execve>

ffffffffc02060c4 <sys_wait>:
    return do_wait(pid, store);
ffffffffc02060c4:	650c                	ld	a1,8(a0)
ffffffffc02060c6:	4108                	lw	a0,0(a0)
ffffffffc02060c8:	c55ff06f          	j	ffffffffc0205d1c <do_wait>

ffffffffc02060cc <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc02060cc:	000a6797          	auipc	a5,0xa6
ffffffffc02060d0:	46478793          	addi	a5,a5,1124 # ffffffffc02ac530 <current>
ffffffffc02060d4:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc02060d6:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc02060d8:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02060da:	6a0c                	ld	a1,16(a2)
ffffffffc02060dc:	ee7fe06f          	j	ffffffffc0204fc2 <do_fork>

ffffffffc02060e0 <sys_exit>:
    return do_exit(error_code);
ffffffffc02060e0:	4108                	lw	a0,0(a0)
ffffffffc02060e2:	b0cff06f          	j	ffffffffc02053ee <do_exit>

ffffffffc02060e6 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc02060e6:	715d                	addi	sp,sp,-80
ffffffffc02060e8:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02060ea:	000a6497          	auipc	s1,0xa6
ffffffffc02060ee:	44648493          	addi	s1,s1,1094 # ffffffffc02ac530 <current>
ffffffffc02060f2:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02060f4:	e0a2                	sd	s0,64(sp)
ffffffffc02060f6:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02060f8:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02060fa:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02060fc:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02060fe:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0206102:	0327ee63          	bltu	a5,s2,ffffffffc020613e <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0206106:	00391713          	slli	a4,s2,0x3
ffffffffc020610a:	00003797          	auipc	a5,0x3
ffffffffc020610e:	82678793          	addi	a5,a5,-2010 # ffffffffc0208930 <syscalls>
ffffffffc0206112:	97ba                	add	a5,a5,a4
ffffffffc0206114:	639c                	ld	a5,0(a5)
ffffffffc0206116:	c785                	beqz	a5,ffffffffc020613e <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc0206118:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc020611a:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc020611c:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc020611e:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0206120:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0206122:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0206124:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0206126:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0206128:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc020612a:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc020612c:	0028                	addi	a0,sp,8
ffffffffc020612e:	9782                	jalr	a5
ffffffffc0206130:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0206132:	60a6                	ld	ra,72(sp)
ffffffffc0206134:	6406                	ld	s0,64(sp)
ffffffffc0206136:	74e2                	ld	s1,56(sp)
ffffffffc0206138:	7942                	ld	s2,48(sp)
ffffffffc020613a:	6161                	addi	sp,sp,80
ffffffffc020613c:	8082                	ret
    print_trapframe(tf);
ffffffffc020613e:	8522                	mv	a0,s0
ffffffffc0206140:	f0afa0ef          	jal	ra,ffffffffc020084a <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0206144:	609c                	ld	a5,0(s1)
ffffffffc0206146:	86ca                	mv	a3,s2
ffffffffc0206148:	00002617          	auipc	a2,0x2
ffffffffc020614c:	7a060613          	addi	a2,a2,1952 # ffffffffc02088e8 <default_pmm_manager+0x1558>
ffffffffc0206150:	43d8                	lw	a4,4(a5)
ffffffffc0206152:	06300593          	li	a1,99
ffffffffc0206156:	0b478793          	addi	a5,a5,180
ffffffffc020615a:	00002517          	auipc	a0,0x2
ffffffffc020615e:	7be50513          	addi	a0,a0,1982 # ffffffffc0208918 <default_pmm_manager+0x1588>
ffffffffc0206162:	b22fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0206166 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0206166:	9e3707b7          	lui	a5,0x9e370
ffffffffc020616a:	2785                	addiw	a5,a5,1
ffffffffc020616c:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0206170:	02000793          	li	a5,32
ffffffffc0206174:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0206178:	00b5553b          	srlw	a0,a0,a1
ffffffffc020617c:	8082                	ret

ffffffffc020617e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020617e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206182:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0206184:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206188:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020618a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020618e:	f022                	sd	s0,32(sp)
ffffffffc0206190:	ec26                	sd	s1,24(sp)
ffffffffc0206192:	e84a                	sd	s2,16(sp)
ffffffffc0206194:	f406                	sd	ra,40(sp)
ffffffffc0206196:	e44e                	sd	s3,8(sp)
ffffffffc0206198:	84aa                	mv	s1,a0
ffffffffc020619a:	892e                	mv	s2,a1
ffffffffc020619c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02061a0:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02061a2:	03067e63          	bleu	a6,a2,ffffffffc02061de <printnum+0x60>
ffffffffc02061a6:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02061a8:	00805763          	blez	s0,ffffffffc02061b6 <printnum+0x38>
ffffffffc02061ac:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02061ae:	85ca                	mv	a1,s2
ffffffffc02061b0:	854e                	mv	a0,s3
ffffffffc02061b2:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02061b4:	fc65                	bnez	s0,ffffffffc02061ac <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02061b6:	1a02                	slli	s4,s4,0x20
ffffffffc02061b8:	020a5a13          	srli	s4,s4,0x20
ffffffffc02061bc:	00003797          	auipc	a5,0x3
ffffffffc02061c0:	a9478793          	addi	a5,a5,-1388 # ffffffffc0208c50 <error_string+0xc8>
ffffffffc02061c4:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02061c6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02061c8:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02061cc:	70a2                	ld	ra,40(sp)
ffffffffc02061ce:	69a2                	ld	s3,8(sp)
ffffffffc02061d0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02061d2:	85ca                	mv	a1,s2
ffffffffc02061d4:	8326                	mv	t1,s1
}
ffffffffc02061d6:	6942                	ld	s2,16(sp)
ffffffffc02061d8:	64e2                	ld	s1,24(sp)
ffffffffc02061da:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02061dc:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02061de:	03065633          	divu	a2,a2,a6
ffffffffc02061e2:	8722                	mv	a4,s0
ffffffffc02061e4:	f9bff0ef          	jal	ra,ffffffffc020617e <printnum>
ffffffffc02061e8:	b7f9                	j	ffffffffc02061b6 <printnum+0x38>

ffffffffc02061ea <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02061ea:	7119                	addi	sp,sp,-128
ffffffffc02061ec:	f4a6                	sd	s1,104(sp)
ffffffffc02061ee:	f0ca                	sd	s2,96(sp)
ffffffffc02061f0:	e8d2                	sd	s4,80(sp)
ffffffffc02061f2:	e4d6                	sd	s5,72(sp)
ffffffffc02061f4:	e0da                	sd	s6,64(sp)
ffffffffc02061f6:	fc5e                	sd	s7,56(sp)
ffffffffc02061f8:	f862                	sd	s8,48(sp)
ffffffffc02061fa:	f06a                	sd	s10,32(sp)
ffffffffc02061fc:	fc86                	sd	ra,120(sp)
ffffffffc02061fe:	f8a2                	sd	s0,112(sp)
ffffffffc0206200:	ecce                	sd	s3,88(sp)
ffffffffc0206202:	f466                	sd	s9,40(sp)
ffffffffc0206204:	ec6e                	sd	s11,24(sp)
ffffffffc0206206:	892a                	mv	s2,a0
ffffffffc0206208:	84ae                	mv	s1,a1
ffffffffc020620a:	8d32                	mv	s10,a2
ffffffffc020620c:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020620e:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206210:	00003a17          	auipc	s4,0x3
ffffffffc0206214:	820a0a13          	addi	s4,s4,-2016 # ffffffffc0208a30 <syscalls+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206218:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020621c:	00003c17          	auipc	s8,0x3
ffffffffc0206220:	96cc0c13          	addi	s8,s8,-1684 # ffffffffc0208b88 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206224:	000d4503          	lbu	a0,0(s10)
ffffffffc0206228:	02500793          	li	a5,37
ffffffffc020622c:	001d0413          	addi	s0,s10,1
ffffffffc0206230:	00f50e63          	beq	a0,a5,ffffffffc020624c <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0206234:	c521                	beqz	a0,ffffffffc020627c <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206236:	02500993          	li	s3,37
ffffffffc020623a:	a011                	j	ffffffffc020623e <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc020623c:	c121                	beqz	a0,ffffffffc020627c <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc020623e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206240:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0206242:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206244:	fff44503          	lbu	a0,-1(s0)
ffffffffc0206248:	ff351ae3          	bne	a0,s3,ffffffffc020623c <vprintfmt+0x52>
ffffffffc020624c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0206250:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0206254:	4981                	li	s3,0
ffffffffc0206256:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0206258:	5cfd                	li	s9,-1
ffffffffc020625a:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020625c:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0206260:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206262:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0206266:	0ff6f693          	andi	a3,a3,255
ffffffffc020626a:	00140d13          	addi	s10,s0,1
ffffffffc020626e:	20d5e563          	bltu	a1,a3,ffffffffc0206478 <vprintfmt+0x28e>
ffffffffc0206272:	068a                	slli	a3,a3,0x2
ffffffffc0206274:	96d2                	add	a3,a3,s4
ffffffffc0206276:	4294                	lw	a3,0(a3)
ffffffffc0206278:	96d2                	add	a3,a3,s4
ffffffffc020627a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020627c:	70e6                	ld	ra,120(sp)
ffffffffc020627e:	7446                	ld	s0,112(sp)
ffffffffc0206280:	74a6                	ld	s1,104(sp)
ffffffffc0206282:	7906                	ld	s2,96(sp)
ffffffffc0206284:	69e6                	ld	s3,88(sp)
ffffffffc0206286:	6a46                	ld	s4,80(sp)
ffffffffc0206288:	6aa6                	ld	s5,72(sp)
ffffffffc020628a:	6b06                	ld	s6,64(sp)
ffffffffc020628c:	7be2                	ld	s7,56(sp)
ffffffffc020628e:	7c42                	ld	s8,48(sp)
ffffffffc0206290:	7ca2                	ld	s9,40(sp)
ffffffffc0206292:	7d02                	ld	s10,32(sp)
ffffffffc0206294:	6de2                	ld	s11,24(sp)
ffffffffc0206296:	6109                	addi	sp,sp,128
ffffffffc0206298:	8082                	ret
    if (lflag >= 2) {
ffffffffc020629a:	4705                	li	a4,1
ffffffffc020629c:	008a8593          	addi	a1,s5,8
ffffffffc02062a0:	01074463          	blt	a4,a6,ffffffffc02062a8 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc02062a4:	26080363          	beqz	a6,ffffffffc020650a <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc02062a8:	000ab603          	ld	a2,0(s5)
ffffffffc02062ac:	46c1                	li	a3,16
ffffffffc02062ae:	8aae                	mv	s5,a1
ffffffffc02062b0:	a06d                	j	ffffffffc020635a <vprintfmt+0x170>
            goto reswitch;
ffffffffc02062b2:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02062b6:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062b8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02062ba:	b765                	j	ffffffffc0206262 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc02062bc:	000aa503          	lw	a0,0(s5)
ffffffffc02062c0:	85a6                	mv	a1,s1
ffffffffc02062c2:	0aa1                	addi	s5,s5,8
ffffffffc02062c4:	9902                	jalr	s2
            break;
ffffffffc02062c6:	bfb9                	j	ffffffffc0206224 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02062c8:	4705                	li	a4,1
ffffffffc02062ca:	008a8993          	addi	s3,s5,8
ffffffffc02062ce:	01074463          	blt	a4,a6,ffffffffc02062d6 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02062d2:	22080463          	beqz	a6,ffffffffc02064fa <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02062d6:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02062da:	24044463          	bltz	s0,ffffffffc0206522 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02062de:	8622                	mv	a2,s0
ffffffffc02062e0:	8ace                	mv	s5,s3
ffffffffc02062e2:	46a9                	li	a3,10
ffffffffc02062e4:	a89d                	j	ffffffffc020635a <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02062e6:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02062ea:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02062ec:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02062ee:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02062f2:	8fb5                	xor	a5,a5,a3
ffffffffc02062f4:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02062f8:	1ad74363          	blt	a4,a3,ffffffffc020649e <vprintfmt+0x2b4>
ffffffffc02062fc:	00369793          	slli	a5,a3,0x3
ffffffffc0206300:	97e2                	add	a5,a5,s8
ffffffffc0206302:	639c                	ld	a5,0(a5)
ffffffffc0206304:	18078d63          	beqz	a5,ffffffffc020649e <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0206308:	86be                	mv	a3,a5
ffffffffc020630a:	00000617          	auipc	a2,0x0
ffffffffc020630e:	35e60613          	addi	a2,a2,862 # ffffffffc0206668 <etext+0x2a>
ffffffffc0206312:	85a6                	mv	a1,s1
ffffffffc0206314:	854a                	mv	a0,s2
ffffffffc0206316:	240000ef          	jal	ra,ffffffffc0206556 <printfmt>
ffffffffc020631a:	b729                	j	ffffffffc0206224 <vprintfmt+0x3a>
            lflag ++;
ffffffffc020631c:	00144603          	lbu	a2,1(s0)
ffffffffc0206320:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206322:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206324:	bf3d                	j	ffffffffc0206262 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0206326:	4705                	li	a4,1
ffffffffc0206328:	008a8593          	addi	a1,s5,8
ffffffffc020632c:	01074463          	blt	a4,a6,ffffffffc0206334 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0206330:	1e080263          	beqz	a6,ffffffffc0206514 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0206334:	000ab603          	ld	a2,0(s5)
ffffffffc0206338:	46a1                	li	a3,8
ffffffffc020633a:	8aae                	mv	s5,a1
ffffffffc020633c:	a839                	j	ffffffffc020635a <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc020633e:	03000513          	li	a0,48
ffffffffc0206342:	85a6                	mv	a1,s1
ffffffffc0206344:	e03e                	sd	a5,0(sp)
ffffffffc0206346:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0206348:	85a6                	mv	a1,s1
ffffffffc020634a:	07800513          	li	a0,120
ffffffffc020634e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206350:	0aa1                	addi	s5,s5,8
ffffffffc0206352:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0206356:	6782                	ld	a5,0(sp)
ffffffffc0206358:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020635a:	876e                	mv	a4,s11
ffffffffc020635c:	85a6                	mv	a1,s1
ffffffffc020635e:	854a                	mv	a0,s2
ffffffffc0206360:	e1fff0ef          	jal	ra,ffffffffc020617e <printnum>
            break;
ffffffffc0206364:	b5c1                	j	ffffffffc0206224 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206366:	000ab603          	ld	a2,0(s5)
ffffffffc020636a:	0aa1                	addi	s5,s5,8
ffffffffc020636c:	1c060663          	beqz	a2,ffffffffc0206538 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0206370:	00160413          	addi	s0,a2,1
ffffffffc0206374:	17b05c63          	blez	s11,ffffffffc02064ec <vprintfmt+0x302>
ffffffffc0206378:	02d00593          	li	a1,45
ffffffffc020637c:	14b79263          	bne	a5,a1,ffffffffc02064c0 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206380:	00064783          	lbu	a5,0(a2)
ffffffffc0206384:	0007851b          	sext.w	a0,a5
ffffffffc0206388:	c905                	beqz	a0,ffffffffc02063b8 <vprintfmt+0x1ce>
ffffffffc020638a:	000cc563          	bltz	s9,ffffffffc0206394 <vprintfmt+0x1aa>
ffffffffc020638e:	3cfd                	addiw	s9,s9,-1
ffffffffc0206390:	036c8263          	beq	s9,s6,ffffffffc02063b4 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0206394:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206396:	18098463          	beqz	s3,ffffffffc020651e <vprintfmt+0x334>
ffffffffc020639a:	3781                	addiw	a5,a5,-32
ffffffffc020639c:	18fbf163          	bleu	a5,s7,ffffffffc020651e <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc02063a0:	03f00513          	li	a0,63
ffffffffc02063a4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02063a6:	0405                	addi	s0,s0,1
ffffffffc02063a8:	fff44783          	lbu	a5,-1(s0)
ffffffffc02063ac:	3dfd                	addiw	s11,s11,-1
ffffffffc02063ae:	0007851b          	sext.w	a0,a5
ffffffffc02063b2:	fd61                	bnez	a0,ffffffffc020638a <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc02063b4:	e7b058e3          	blez	s11,ffffffffc0206224 <vprintfmt+0x3a>
ffffffffc02063b8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02063ba:	85a6                	mv	a1,s1
ffffffffc02063bc:	02000513          	li	a0,32
ffffffffc02063c0:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02063c2:	e60d81e3          	beqz	s11,ffffffffc0206224 <vprintfmt+0x3a>
ffffffffc02063c6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02063c8:	85a6                	mv	a1,s1
ffffffffc02063ca:	02000513          	li	a0,32
ffffffffc02063ce:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02063d0:	fe0d94e3          	bnez	s11,ffffffffc02063b8 <vprintfmt+0x1ce>
ffffffffc02063d4:	bd81                	j	ffffffffc0206224 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02063d6:	4705                	li	a4,1
ffffffffc02063d8:	008a8593          	addi	a1,s5,8
ffffffffc02063dc:	01074463          	blt	a4,a6,ffffffffc02063e4 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02063e0:	12080063          	beqz	a6,ffffffffc0206500 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02063e4:	000ab603          	ld	a2,0(s5)
ffffffffc02063e8:	46a9                	li	a3,10
ffffffffc02063ea:	8aae                	mv	s5,a1
ffffffffc02063ec:	b7bd                	j	ffffffffc020635a <vprintfmt+0x170>
ffffffffc02063ee:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02063f2:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063f6:	846a                	mv	s0,s10
ffffffffc02063f8:	b5ad                	j	ffffffffc0206262 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02063fa:	85a6                	mv	a1,s1
ffffffffc02063fc:	02500513          	li	a0,37
ffffffffc0206400:	9902                	jalr	s2
            break;
ffffffffc0206402:	b50d                	j	ffffffffc0206224 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0206404:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0206408:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020640c:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020640e:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0206410:	e40dd9e3          	bgez	s11,ffffffffc0206262 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0206414:	8de6                	mv	s11,s9
ffffffffc0206416:	5cfd                	li	s9,-1
ffffffffc0206418:	b5a9                	j	ffffffffc0206262 <vprintfmt+0x78>
            goto reswitch;
ffffffffc020641a:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc020641e:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206422:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206424:	bd3d                	j	ffffffffc0206262 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0206426:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc020642a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020642e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0206430:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0206434:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206438:	fcd56ce3          	bltu	a0,a3,ffffffffc0206410 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc020643c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020643e:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0206442:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0206446:	0196873b          	addw	a4,a3,s9
ffffffffc020644a:	0017171b          	slliw	a4,a4,0x1
ffffffffc020644e:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0206452:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0206456:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020645a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020645e:	fcd57fe3          	bleu	a3,a0,ffffffffc020643c <vprintfmt+0x252>
ffffffffc0206462:	b77d                	j	ffffffffc0206410 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0206464:	fffdc693          	not	a3,s11
ffffffffc0206468:	96fd                	srai	a3,a3,0x3f
ffffffffc020646a:	00ddfdb3          	and	s11,s11,a3
ffffffffc020646e:	00144603          	lbu	a2,1(s0)
ffffffffc0206472:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206474:	846a                	mv	s0,s10
ffffffffc0206476:	b3f5                	j	ffffffffc0206262 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0206478:	85a6                	mv	a1,s1
ffffffffc020647a:	02500513          	li	a0,37
ffffffffc020647e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0206480:	fff44703          	lbu	a4,-1(s0)
ffffffffc0206484:	02500793          	li	a5,37
ffffffffc0206488:	8d22                	mv	s10,s0
ffffffffc020648a:	d8f70de3          	beq	a4,a5,ffffffffc0206224 <vprintfmt+0x3a>
ffffffffc020648e:	02500713          	li	a4,37
ffffffffc0206492:	1d7d                	addi	s10,s10,-1
ffffffffc0206494:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0206498:	fee79de3          	bne	a5,a4,ffffffffc0206492 <vprintfmt+0x2a8>
ffffffffc020649c:	b361                	j	ffffffffc0206224 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020649e:	00003617          	auipc	a2,0x3
ffffffffc02064a2:	89260613          	addi	a2,a2,-1902 # ffffffffc0208d30 <error_string+0x1a8>
ffffffffc02064a6:	85a6                	mv	a1,s1
ffffffffc02064a8:	854a                	mv	a0,s2
ffffffffc02064aa:	0ac000ef          	jal	ra,ffffffffc0206556 <printfmt>
ffffffffc02064ae:	bb9d                	j	ffffffffc0206224 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02064b0:	00003617          	auipc	a2,0x3
ffffffffc02064b4:	87860613          	addi	a2,a2,-1928 # ffffffffc0208d28 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc02064b8:	00003417          	auipc	s0,0x3
ffffffffc02064bc:	87140413          	addi	s0,s0,-1935 # ffffffffc0208d29 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02064c0:	8532                	mv	a0,a2
ffffffffc02064c2:	85e6                	mv	a1,s9
ffffffffc02064c4:	e032                	sd	a2,0(sp)
ffffffffc02064c6:	e43e                	sd	a5,8(sp)
ffffffffc02064c8:	0cc000ef          	jal	ra,ffffffffc0206594 <strnlen>
ffffffffc02064cc:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02064d0:	6602                	ld	a2,0(sp)
ffffffffc02064d2:	01b05d63          	blez	s11,ffffffffc02064ec <vprintfmt+0x302>
ffffffffc02064d6:	67a2                	ld	a5,8(sp)
ffffffffc02064d8:	2781                	sext.w	a5,a5
ffffffffc02064da:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02064dc:	6522                	ld	a0,8(sp)
ffffffffc02064de:	85a6                	mv	a1,s1
ffffffffc02064e0:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02064e2:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02064e4:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02064e6:	6602                	ld	a2,0(sp)
ffffffffc02064e8:	fe0d9ae3          	bnez	s11,ffffffffc02064dc <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02064ec:	00064783          	lbu	a5,0(a2)
ffffffffc02064f0:	0007851b          	sext.w	a0,a5
ffffffffc02064f4:	e8051be3          	bnez	a0,ffffffffc020638a <vprintfmt+0x1a0>
ffffffffc02064f8:	b335                	j	ffffffffc0206224 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02064fa:	000aa403          	lw	s0,0(s5)
ffffffffc02064fe:	bbf1                	j	ffffffffc02062da <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0206500:	000ae603          	lwu	a2,0(s5)
ffffffffc0206504:	46a9                	li	a3,10
ffffffffc0206506:	8aae                	mv	s5,a1
ffffffffc0206508:	bd89                	j	ffffffffc020635a <vprintfmt+0x170>
ffffffffc020650a:	000ae603          	lwu	a2,0(s5)
ffffffffc020650e:	46c1                	li	a3,16
ffffffffc0206510:	8aae                	mv	s5,a1
ffffffffc0206512:	b5a1                	j	ffffffffc020635a <vprintfmt+0x170>
ffffffffc0206514:	000ae603          	lwu	a2,0(s5)
ffffffffc0206518:	46a1                	li	a3,8
ffffffffc020651a:	8aae                	mv	s5,a1
ffffffffc020651c:	bd3d                	j	ffffffffc020635a <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc020651e:	9902                	jalr	s2
ffffffffc0206520:	b559                	j	ffffffffc02063a6 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0206522:	85a6                	mv	a1,s1
ffffffffc0206524:	02d00513          	li	a0,45
ffffffffc0206528:	e03e                	sd	a5,0(sp)
ffffffffc020652a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020652c:	8ace                	mv	s5,s3
ffffffffc020652e:	40800633          	neg	a2,s0
ffffffffc0206532:	46a9                	li	a3,10
ffffffffc0206534:	6782                	ld	a5,0(sp)
ffffffffc0206536:	b515                	j	ffffffffc020635a <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0206538:	01b05663          	blez	s11,ffffffffc0206544 <vprintfmt+0x35a>
ffffffffc020653c:	02d00693          	li	a3,45
ffffffffc0206540:	f6d798e3          	bne	a5,a3,ffffffffc02064b0 <vprintfmt+0x2c6>
ffffffffc0206544:	00002417          	auipc	s0,0x2
ffffffffc0206548:	7e540413          	addi	s0,s0,2021 # ffffffffc0208d29 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020654c:	02800513          	li	a0,40
ffffffffc0206550:	02800793          	li	a5,40
ffffffffc0206554:	bd1d                	j	ffffffffc020638a <vprintfmt+0x1a0>

ffffffffc0206556 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206556:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0206558:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020655c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020655e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206560:	ec06                	sd	ra,24(sp)
ffffffffc0206562:	f83a                	sd	a4,48(sp)
ffffffffc0206564:	fc3e                	sd	a5,56(sp)
ffffffffc0206566:	e0c2                	sd	a6,64(sp)
ffffffffc0206568:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020656a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020656c:	c7fff0ef          	jal	ra,ffffffffc02061ea <vprintfmt>
}
ffffffffc0206570:	60e2                	ld	ra,24(sp)
ffffffffc0206572:	6161                	addi	sp,sp,80
ffffffffc0206574:	8082                	ret

ffffffffc0206576 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0206576:	00054783          	lbu	a5,0(a0)
ffffffffc020657a:	cb91                	beqz	a5,ffffffffc020658e <strlen+0x18>
    size_t cnt = 0;
ffffffffc020657c:	4781                	li	a5,0
        cnt ++;
ffffffffc020657e:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0206580:	00f50733          	add	a4,a0,a5
ffffffffc0206584:	00074703          	lbu	a4,0(a4)
ffffffffc0206588:	fb7d                	bnez	a4,ffffffffc020657e <strlen+0x8>
    }
    return cnt;
}
ffffffffc020658a:	853e                	mv	a0,a5
ffffffffc020658c:	8082                	ret
    size_t cnt = 0;
ffffffffc020658e:	4781                	li	a5,0
}
ffffffffc0206590:	853e                	mv	a0,a5
ffffffffc0206592:	8082                	ret

ffffffffc0206594 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206594:	c185                	beqz	a1,ffffffffc02065b4 <strnlen+0x20>
ffffffffc0206596:	00054783          	lbu	a5,0(a0)
ffffffffc020659a:	cf89                	beqz	a5,ffffffffc02065b4 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc020659c:	4781                	li	a5,0
ffffffffc020659e:	a021                	j	ffffffffc02065a6 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02065a0:	00074703          	lbu	a4,0(a4)
ffffffffc02065a4:	c711                	beqz	a4,ffffffffc02065b0 <strnlen+0x1c>
        cnt ++;
ffffffffc02065a6:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02065a8:	00f50733          	add	a4,a0,a5
ffffffffc02065ac:	fef59ae3          	bne	a1,a5,ffffffffc02065a0 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02065b0:	853e                	mv	a0,a5
ffffffffc02065b2:	8082                	ret
    size_t cnt = 0;
ffffffffc02065b4:	4781                	li	a5,0
}
ffffffffc02065b6:	853e                	mv	a0,a5
ffffffffc02065b8:	8082                	ret

ffffffffc02065ba <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02065ba:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02065bc:	0585                	addi	a1,a1,1
ffffffffc02065be:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02065c2:	0785                	addi	a5,a5,1
ffffffffc02065c4:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02065c8:	fb75                	bnez	a4,ffffffffc02065bc <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02065ca:	8082                	ret

ffffffffc02065cc <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02065cc:	00054783          	lbu	a5,0(a0)
ffffffffc02065d0:	0005c703          	lbu	a4,0(a1)
ffffffffc02065d4:	cb91                	beqz	a5,ffffffffc02065e8 <strcmp+0x1c>
ffffffffc02065d6:	00e79c63          	bne	a5,a4,ffffffffc02065ee <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02065da:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02065dc:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02065e0:	0585                	addi	a1,a1,1
ffffffffc02065e2:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02065e6:	fbe5                	bnez	a5,ffffffffc02065d6 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02065e8:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02065ea:	9d19                	subw	a0,a0,a4
ffffffffc02065ec:	8082                	ret
ffffffffc02065ee:	0007851b          	sext.w	a0,a5
ffffffffc02065f2:	9d19                	subw	a0,a0,a4
ffffffffc02065f4:	8082                	ret

ffffffffc02065f6 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02065f6:	00054783          	lbu	a5,0(a0)
ffffffffc02065fa:	cb91                	beqz	a5,ffffffffc020660e <strchr+0x18>
        if (*s == c) {
ffffffffc02065fc:	00b79563          	bne	a5,a1,ffffffffc0206606 <strchr+0x10>
ffffffffc0206600:	a809                	j	ffffffffc0206612 <strchr+0x1c>
ffffffffc0206602:	00b78763          	beq	a5,a1,ffffffffc0206610 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0206606:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0206608:	00054783          	lbu	a5,0(a0)
ffffffffc020660c:	fbfd                	bnez	a5,ffffffffc0206602 <strchr+0xc>
    }
    return NULL;
ffffffffc020660e:	4501                	li	a0,0
}
ffffffffc0206610:	8082                	ret
ffffffffc0206612:	8082                	ret

ffffffffc0206614 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0206614:	ca01                	beqz	a2,ffffffffc0206624 <memset+0x10>
ffffffffc0206616:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0206618:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020661a:	0785                	addi	a5,a5,1
ffffffffc020661c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0206620:	fec79de3          	bne	a5,a2,ffffffffc020661a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0206624:	8082                	ret

ffffffffc0206626 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0206626:	ca19                	beqz	a2,ffffffffc020663c <memcpy+0x16>
ffffffffc0206628:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020662a:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020662c:	0585                	addi	a1,a1,1
ffffffffc020662e:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0206632:	0785                	addi	a5,a5,1
ffffffffc0206634:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0206638:	fec59ae3          	bne	a1,a2,ffffffffc020662c <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020663c:	8082                	ret
