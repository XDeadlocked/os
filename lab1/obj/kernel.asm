
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp
    
    tail kern_init
    80200008:	0040006f          	j	8020000c <kern_init>

000000008020000c <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000c:	00004517          	auipc	a0,0x4
    80200010:	00450513          	addi	a0,a0,4 # 80204010 <edata>
    80200014:	00004617          	auipc	a2,0x4
    80200018:	01460613          	addi	a2,a2,20 # 80204028 <end>
int kern_init(void) {
    8020001c:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001e:	8e09                	sub	a2,a2,a0
    80200020:	4581                	li	a1,0
int kern_init(void) {
    80200022:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200024:	26d000ef          	jal	ra,80200a90 <memset>

    cons_init();  // init the console
    80200028:	150000ef          	jal	ra,80200178 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002c:	00001597          	auipc	a1,0x1
    80200030:	a7c58593          	addi	a1,a1,-1412 # 80200aa8 <etext+0x6>
    80200034:	00001517          	auipc	a0,0x1
    80200038:	a9450513          	addi	a0,a0,-1388 # 80200ac8 <etext+0x26>
    8020003c:	034000ef          	jal	ra,80200070 <cprintf>

    print_kerninfo();
    80200040:	064000ef          	jal	ra,802000a4 <print_kerninfo>

    //__asm__ volatile("ebreak");
    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200044:	144000ef          	jal	ra,80200188 <idt_init>
    80200048:	0000                	unimp
    8020004a:	0000                	unimp
    __asm__ volatile(".word 0x00000000");
//------------------



    clock_init();  // init clock interrupt
    8020004c:	0e8000ef          	jal	ra,80200134 <clock_init>

    intr_enable();  // enable irq interrupt
    80200050:	132000ef          	jal	ra,80200182 <intr_enable>
    
    while (1){

    }
    80200054:	a001                	j	80200054 <kern_init+0x48>

0000000080200056 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200056:	1141                	addi	sp,sp,-16
    80200058:	e022                	sd	s0,0(sp)
    8020005a:	e406                	sd	ra,8(sp)
    8020005c:	842e                	mv	s0,a1
    cons_putc(c);
    8020005e:	11c000ef          	jal	ra,8020017a <cons_putc>
    (*cnt)++;
    80200062:	401c                	lw	a5,0(s0)
}
    80200064:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200066:	2785                	addiw	a5,a5,1
    80200068:	c01c                	sw	a5,0(s0)
}
    8020006a:	6402                	ld	s0,0(sp)
    8020006c:	0141                	addi	sp,sp,16
    8020006e:	8082                	ret

0000000080200070 <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    80200070:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    80200072:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200076:	f42e                	sd	a1,40(sp)
    80200078:	f832                	sd	a2,48(sp)
    8020007a:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    8020007c:	862a                	mv	a2,a0
    8020007e:	004c                	addi	a1,sp,4
    80200080:	00000517          	auipc	a0,0x0
    80200084:	fd650513          	addi	a0,a0,-42 # 80200056 <cputch>
    80200088:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    8020008a:	ec06                	sd	ra,24(sp)
    8020008c:	e0ba                	sd	a4,64(sp)
    8020008e:	e4be                	sd	a5,72(sp)
    80200090:	e8c2                	sd	a6,80(sp)
    80200092:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200094:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200096:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200098:	5f2000ef          	jal	ra,8020068a <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    8020009c:	60e2                	ld	ra,24(sp)
    8020009e:	4512                	lw	a0,4(sp)
    802000a0:	6125                	addi	sp,sp,96
    802000a2:	8082                	ret

00000000802000a4 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a4:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a6:	00001517          	auipc	a0,0x1
    802000aa:	a2a50513          	addi	a0,a0,-1494 # 80200ad0 <etext+0x2e>
void print_kerninfo(void) {
    802000ae:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000b0:	fc1ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b4:	00000597          	auipc	a1,0x0
    802000b8:	f5858593          	addi	a1,a1,-168 # 8020000c <kern_init>
    802000bc:	00001517          	auipc	a0,0x1
    802000c0:	a3450513          	addi	a0,a0,-1484 # 80200af0 <etext+0x4e>
    802000c4:	fadff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c8:	00001597          	auipc	a1,0x1
    802000cc:	9da58593          	addi	a1,a1,-1574 # 80200aa2 <etext>
    802000d0:	00001517          	auipc	a0,0x1
    802000d4:	a4050513          	addi	a0,a0,-1472 # 80200b10 <etext+0x6e>
    802000d8:	f99ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000dc:	00004597          	auipc	a1,0x4
    802000e0:	f3458593          	addi	a1,a1,-204 # 80204010 <edata>
    802000e4:	00001517          	auipc	a0,0x1
    802000e8:	a4c50513          	addi	a0,a0,-1460 # 80200b30 <etext+0x8e>
    802000ec:	f85ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000f0:	00004597          	auipc	a1,0x4
    802000f4:	f3858593          	addi	a1,a1,-200 # 80204028 <end>
    802000f8:	00001517          	auipc	a0,0x1
    802000fc:	a5850513          	addi	a0,a0,-1448 # 80200b50 <etext+0xae>
    80200100:	f71ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200104:	00004597          	auipc	a1,0x4
    80200108:	32358593          	addi	a1,a1,803 # 80204427 <end+0x3ff>
    8020010c:	00000797          	auipc	a5,0x0
    80200110:	f0078793          	addi	a5,a5,-256 # 8020000c <kern_init>
    80200114:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200118:	43f7d593          	srai	a1,a5,0x3f
}
    8020011c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011e:	3ff5f593          	andi	a1,a1,1023
    80200122:	95be                	add	a1,a1,a5
    80200124:	85a9                	srai	a1,a1,0xa
    80200126:	00001517          	auipc	a0,0x1
    8020012a:	a4a50513          	addi	a0,a0,-1462 # 80200b70 <etext+0xce>
}
    8020012e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200130:	f41ff06f          	j	80200070 <cprintf>

0000000080200134 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    80200134:	1141                	addi	sp,sp,-16
    80200136:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200138:	02000793          	li	a5,32
    8020013c:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200140:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200144:	67e1                	lui	a5,0x18
    80200146:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    8020014a:	953e                	add	a0,a0,a5
    8020014c:	0e7000ef          	jal	ra,80200a32 <sbi_set_timer>
}
    80200150:	60a2                	ld	ra,8(sp)
    ticks = 0;
    80200152:	00004797          	auipc	a5,0x4
    80200156:	ec07b723          	sd	zero,-306(a5) # 80204020 <ticks>
    cprintf("++ setup timer interrupts\n");
    8020015a:	00001517          	auipc	a0,0x1
    8020015e:	a4650513          	addi	a0,a0,-1466 # 80200ba0 <etext+0xfe>
}
    80200162:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200164:	f0dff06f          	j	80200070 <cprintf>

0000000080200168 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200168:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020016c:	67e1                	lui	a5,0x18
    8020016e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200172:	953e                	add	a0,a0,a5
    80200174:	0bf0006f          	j	80200a32 <sbi_set_timer>

0000000080200178 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200178:	8082                	ret

000000008020017a <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    8020017a:	0ff57513          	andi	a0,a0,255
    8020017e:	0990006f          	j	80200a16 <sbi_console_putchar>

0000000080200182 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    80200182:	100167f3          	csrrsi	a5,sstatus,2
    80200186:	8082                	ret

0000000080200188 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200188:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    8020018c:	00000797          	auipc	a5,0x0
    80200190:	3dc78793          	addi	a5,a5,988 # 80200568 <__alltraps>
    80200194:	10579073          	csrw	stvec,a5
}
    80200198:	8082                	ret

000000008020019a <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019a:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    8020019c:	1141                	addi	sp,sp,-16
    8020019e:	e022                	sd	s0,0(sp)
    802001a0:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a2:	00001517          	auipc	a0,0x1
    802001a6:	b8e50513          	addi	a0,a0,-1138 # 80200d30 <etext+0x28e>
void print_regs(struct pushregs *gpr) {
    802001aa:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001ac:	ec5ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001b0:	640c                	ld	a1,8(s0)
    802001b2:	00001517          	auipc	a0,0x1
    802001b6:	b9650513          	addi	a0,a0,-1130 # 80200d48 <etext+0x2a6>
    802001ba:	eb7ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001be:	680c                	ld	a1,16(s0)
    802001c0:	00001517          	auipc	a0,0x1
    802001c4:	ba050513          	addi	a0,a0,-1120 # 80200d60 <etext+0x2be>
    802001c8:	ea9ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001cc:	6c0c                	ld	a1,24(s0)
    802001ce:	00001517          	auipc	a0,0x1
    802001d2:	baa50513          	addi	a0,a0,-1110 # 80200d78 <etext+0x2d6>
    802001d6:	e9bff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001da:	700c                	ld	a1,32(s0)
    802001dc:	00001517          	auipc	a0,0x1
    802001e0:	bb450513          	addi	a0,a0,-1100 # 80200d90 <etext+0x2ee>
    802001e4:	e8dff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e8:	740c                	ld	a1,40(s0)
    802001ea:	00001517          	auipc	a0,0x1
    802001ee:	bbe50513          	addi	a0,a0,-1090 # 80200da8 <etext+0x306>
    802001f2:	e7fff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001f6:	780c                	ld	a1,48(s0)
    802001f8:	00001517          	auipc	a0,0x1
    802001fc:	bc850513          	addi	a0,a0,-1080 # 80200dc0 <etext+0x31e>
    80200200:	e71ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200204:	7c0c                	ld	a1,56(s0)
    80200206:	00001517          	auipc	a0,0x1
    8020020a:	bd250513          	addi	a0,a0,-1070 # 80200dd8 <etext+0x336>
    8020020e:	e63ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200212:	602c                	ld	a1,64(s0)
    80200214:	00001517          	auipc	a0,0x1
    80200218:	bdc50513          	addi	a0,a0,-1060 # 80200df0 <etext+0x34e>
    8020021c:	e55ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200220:	642c                	ld	a1,72(s0)
    80200222:	00001517          	auipc	a0,0x1
    80200226:	be650513          	addi	a0,a0,-1050 # 80200e08 <etext+0x366>
    8020022a:	e47ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    8020022e:	682c                	ld	a1,80(s0)
    80200230:	00001517          	auipc	a0,0x1
    80200234:	bf050513          	addi	a0,a0,-1040 # 80200e20 <etext+0x37e>
    80200238:	e39ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    8020023c:	6c2c                	ld	a1,88(s0)
    8020023e:	00001517          	auipc	a0,0x1
    80200242:	bfa50513          	addi	a0,a0,-1030 # 80200e38 <etext+0x396>
    80200246:	e2bff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    8020024a:	702c                	ld	a1,96(s0)
    8020024c:	00001517          	auipc	a0,0x1
    80200250:	c0450513          	addi	a0,a0,-1020 # 80200e50 <etext+0x3ae>
    80200254:	e1dff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200258:	742c                	ld	a1,104(s0)
    8020025a:	00001517          	auipc	a0,0x1
    8020025e:	c0e50513          	addi	a0,a0,-1010 # 80200e68 <etext+0x3c6>
    80200262:	e0fff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200266:	782c                	ld	a1,112(s0)
    80200268:	00001517          	auipc	a0,0x1
    8020026c:	c1850513          	addi	a0,a0,-1000 # 80200e80 <etext+0x3de>
    80200270:	e01ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200274:	7c2c                	ld	a1,120(s0)
    80200276:	00001517          	auipc	a0,0x1
    8020027a:	c2250513          	addi	a0,a0,-990 # 80200e98 <etext+0x3f6>
    8020027e:	df3ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200282:	604c                	ld	a1,128(s0)
    80200284:	00001517          	auipc	a0,0x1
    80200288:	c2c50513          	addi	a0,a0,-980 # 80200eb0 <etext+0x40e>
    8020028c:	de5ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200290:	644c                	ld	a1,136(s0)
    80200292:	00001517          	auipc	a0,0x1
    80200296:	c3650513          	addi	a0,a0,-970 # 80200ec8 <etext+0x426>
    8020029a:	dd7ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    8020029e:	684c                	ld	a1,144(s0)
    802002a0:	00001517          	auipc	a0,0x1
    802002a4:	c4050513          	addi	a0,a0,-960 # 80200ee0 <etext+0x43e>
    802002a8:	dc9ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002ac:	6c4c                	ld	a1,152(s0)
    802002ae:	00001517          	auipc	a0,0x1
    802002b2:	c4a50513          	addi	a0,a0,-950 # 80200ef8 <etext+0x456>
    802002b6:	dbbff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002ba:	704c                	ld	a1,160(s0)
    802002bc:	00001517          	auipc	a0,0x1
    802002c0:	c5450513          	addi	a0,a0,-940 # 80200f10 <etext+0x46e>
    802002c4:	dadff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c8:	744c                	ld	a1,168(s0)
    802002ca:	00001517          	auipc	a0,0x1
    802002ce:	c5e50513          	addi	a0,a0,-930 # 80200f28 <etext+0x486>
    802002d2:	d9fff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002d6:	784c                	ld	a1,176(s0)
    802002d8:	00001517          	auipc	a0,0x1
    802002dc:	c6850513          	addi	a0,a0,-920 # 80200f40 <etext+0x49e>
    802002e0:	d91ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002e4:	7c4c                	ld	a1,184(s0)
    802002e6:	00001517          	auipc	a0,0x1
    802002ea:	c7250513          	addi	a0,a0,-910 # 80200f58 <etext+0x4b6>
    802002ee:	d83ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002f2:	606c                	ld	a1,192(s0)
    802002f4:	00001517          	auipc	a0,0x1
    802002f8:	c7c50513          	addi	a0,a0,-900 # 80200f70 <etext+0x4ce>
    802002fc:	d75ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    80200300:	646c                	ld	a1,200(s0)
    80200302:	00001517          	auipc	a0,0x1
    80200306:	c8650513          	addi	a0,a0,-890 # 80200f88 <etext+0x4e6>
    8020030a:	d67ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    8020030e:	686c                	ld	a1,208(s0)
    80200310:	00001517          	auipc	a0,0x1
    80200314:	c9050513          	addi	a0,a0,-880 # 80200fa0 <etext+0x4fe>
    80200318:	d59ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    8020031c:	6c6c                	ld	a1,216(s0)
    8020031e:	00001517          	auipc	a0,0x1
    80200322:	c9a50513          	addi	a0,a0,-870 # 80200fb8 <etext+0x516>
    80200326:	d4bff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    8020032a:	706c                	ld	a1,224(s0)
    8020032c:	00001517          	auipc	a0,0x1
    80200330:	ca450513          	addi	a0,a0,-860 # 80200fd0 <etext+0x52e>
    80200334:	d3dff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200338:	746c                	ld	a1,232(s0)
    8020033a:	00001517          	auipc	a0,0x1
    8020033e:	cae50513          	addi	a0,a0,-850 # 80200fe8 <etext+0x546>
    80200342:	d2fff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200346:	786c                	ld	a1,240(s0)
    80200348:	00001517          	auipc	a0,0x1
    8020034c:	cb850513          	addi	a0,a0,-840 # 80201000 <etext+0x55e>
    80200350:	d21ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200354:	7c6c                	ld	a1,248(s0)
}
    80200356:	6402                	ld	s0,0(sp)
    80200358:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020035a:	00001517          	auipc	a0,0x1
    8020035e:	cbe50513          	addi	a0,a0,-834 # 80201018 <etext+0x576>
}
    80200362:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200364:	d0dff06f          	j	80200070 <cprintf>

0000000080200368 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200368:	1141                	addi	sp,sp,-16
    8020036a:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    8020036c:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    8020036e:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200370:	00001517          	auipc	a0,0x1
    80200374:	cc050513          	addi	a0,a0,-832 # 80201030 <etext+0x58e>
void print_trapframe(struct trapframe *tf) {
    80200378:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    8020037a:	cf7ff0ef          	jal	ra,80200070 <cprintf>
    print_regs(&tf->gpr);
    8020037e:	8522                	mv	a0,s0
    80200380:	e1bff0ef          	jal	ra,8020019a <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200384:	10043583          	ld	a1,256(s0)
    80200388:	00001517          	auipc	a0,0x1
    8020038c:	cc050513          	addi	a0,a0,-832 # 80201048 <etext+0x5a6>
    80200390:	ce1ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200394:	10843583          	ld	a1,264(s0)
    80200398:	00001517          	auipc	a0,0x1
    8020039c:	cc850513          	addi	a0,a0,-824 # 80201060 <etext+0x5be>
    802003a0:	cd1ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003a4:	11043583          	ld	a1,272(s0)
    802003a8:	00001517          	auipc	a0,0x1
    802003ac:	cd050513          	addi	a0,a0,-816 # 80201078 <etext+0x5d6>
    802003b0:	cc1ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b4:	11843583          	ld	a1,280(s0)
}
    802003b8:	6402                	ld	s0,0(sp)
    802003ba:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003bc:	00001517          	auipc	a0,0x1
    802003c0:	cd450513          	addi	a0,a0,-812 # 80201090 <etext+0x5ee>
}
    802003c4:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c6:	cabff06f          	j	80200070 <cprintf>

00000000802003ca <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003ca:	11853783          	ld	a5,280(a0)
    802003ce:	577d                	li	a4,-1
    802003d0:	8305                	srli	a4,a4,0x1
    802003d2:	8ff9                	and	a5,a5,a4
    static size_t tick_s=0;//计数器
    static size_t num1=0;//打印次数
    switch (cause) {
    802003d4:	472d                	li	a4,11
    802003d6:	08f76063          	bltu	a4,a5,80200456 <interrupt_handler+0x8c>
    802003da:	00000717          	auipc	a4,0x0
    802003de:	7e270713          	addi	a4,a4,2018 # 80200bbc <etext+0x11a>
    802003e2:	078a                	slli	a5,a5,0x2
    802003e4:	97ba                	add	a5,a5,a4
    802003e6:	439c                	lw	a5,0(a5)
    802003e8:	97ba                	add	a5,a5,a4
    802003ea:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003ec:	00001517          	auipc	a0,0x1
    802003f0:	8f450513          	addi	a0,a0,-1804 # 80200ce0 <etext+0x23e>
    802003f4:	c7dff06f          	j	80200070 <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003f8:	00001517          	auipc	a0,0x1
    802003fc:	8c850513          	addi	a0,a0,-1848 # 80200cc0 <etext+0x21e>
    80200400:	c71ff06f          	j	80200070 <cprintf>
            cprintf("User software interrupt\n");
    80200404:	00001517          	auipc	a0,0x1
    80200408:	87c50513          	addi	a0,a0,-1924 # 80200c80 <etext+0x1de>
    8020040c:	c65ff06f          	j	80200070 <cprintf>
            cprintf("Supervisor software interrupt\n");
    80200410:	00001517          	auipc	a0,0x1
    80200414:	89050513          	addi	a0,a0,-1904 # 80200ca0 <etext+0x1fe>
    80200418:	c59ff06f          	j	80200070 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    8020041c:	00001517          	auipc	a0,0x1
    80200420:	8f450513          	addi	a0,a0,-1804 # 80200d10 <etext+0x26e>
    80200424:	c4dff06f          	j	80200070 <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200428:	1141                	addi	sp,sp,-16
    8020042a:	e406                	sd	ra,8(sp)
            clock_set_next_event();// 设置下一次的时钟中断
    8020042c:	d3dff0ef          	jal	ra,80200168 <clock_set_next_event>
            ticks++;
    80200430:	00004717          	auipc	a4,0x4
    80200434:	bf070713          	addi	a4,a4,-1040 # 80204020 <ticks>
    80200438:	631c                	ld	a5,0(a4)
    8020043a:	0785                	addi	a5,a5,1
    8020043c:	00004697          	auipc	a3,0x4
    80200440:	bef6b223          	sd	a5,-1052(a3) # 80204020 <ticks>
            if(ticks % TICK_NUM == 0){
    80200444:	631c                	ld	a5,0(a4)
    80200446:	06400713          	li	a4,100
    8020044a:	02e7f7b3          	remu	a5,a5,a4
    8020044e:	c791                	beqz	a5,8020045a <interrupt_handler+0x90>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200450:	60a2                	ld	ra,8(sp)
    80200452:	0141                	addi	sp,sp,16
    80200454:	8082                	ret
            print_trapframe(tf);
    80200456:	f13ff06f          	j	80200368 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    8020045a:	06400593          	li	a1,100
    8020045e:	00001517          	auipc	a0,0x1
    80200462:	8a250513          	addi	a0,a0,-1886 # 80200d00 <etext+0x25e>
    80200466:	c0bff0ef          	jal	ra,80200070 <cprintf>
                    num1++;//打印次数+1
    8020046a:	00004797          	auipc	a5,0x4
    8020046e:	ba678793          	addi	a5,a5,-1114 # 80204010 <edata>
    80200472:	639c                	ld	a5,0(a5)
                    if(num1==10){
    80200474:	4729                	li	a4,10
                    num1++;//打印次数+1
    80200476:	0785                	addi	a5,a5,1
    80200478:	00004697          	auipc	a3,0x4
    8020047c:	b8f6bc23          	sd	a5,-1128(a3) # 80204010 <edata>
                    if(num1==10){
    80200480:	fce798e3          	bne	a5,a4,80200450 <interrupt_handler+0x86>
}
    80200484:	60a2                	ld	ra,8(sp)
    80200486:	0141                	addi	sp,sp,16
                        sbi_shutdown();
    80200488:	5c60006f          	j	80200a4e <sbi_shutdown>

000000008020048c <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    8020048c:	11853783          	ld	a5,280(a0)
    80200490:	472d                	li	a4,11
    80200492:	02f76863          	bltu	a4,a5,802004c2 <exception_handler+0x36>
    80200496:	4705                	li	a4,1
    80200498:	00f71733          	sll	a4,a4,a5
    8020049c:	6785                	lui	a5,0x1
    8020049e:	17cd                	addi	a5,a5,-13
    802004a0:	8ff9                	and	a5,a5,a4
    802004a2:	ef99                	bnez	a5,802004c0 <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
    802004a4:	1141                	addi	sp,sp,-16
    802004a6:	e022                	sd	s0,0(sp)
    802004a8:	e406                	sd	ra,8(sp)
    802004aa:	00877793          	andi	a5,a4,8
    802004ae:	842a                	mv	s0,a0
    802004b0:	e3b1                	bnez	a5,802004f4 <exception_handler+0x68>
    802004b2:	8b11                	andi	a4,a4,4
    802004b4:	eb09                	bnez	a4,802004c6 <exception_handler+0x3a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004b6:	6402                	ld	s0,0(sp)
    802004b8:	60a2                	ld	ra,8(sp)
    802004ba:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004bc:	eadff06f          	j	80200368 <print_trapframe>
    802004c0:	8082                	ret
    802004c2:	ea7ff06f          	j	80200368 <print_trapframe>
            cprintf("Exception type: Illegal instruction\n");
    802004c6:	00000517          	auipc	a0,0x0
    802004ca:	72a50513          	addi	a0,a0,1834 # 80200bf0 <etext+0x14e>
    802004ce:	ba3ff0ef          	jal	ra,80200070 <cprintf>
            cprintf("Ebreak caught at 0x%08x\n", tf->epc);
    802004d2:	10843583          	ld	a1,264(s0)
    802004d6:	00000517          	auipc	a0,0x0
    802004da:	74250513          	addi	a0,a0,1858 # 80200c18 <etext+0x176>
    802004de:	b93ff0ef          	jal	ra,80200070 <cprintf>
            tf->epc += 4;// 更新 tf->epc寄存器
    802004e2:	10843783          	ld	a5,264(s0)
}
    802004e6:	60a2                	ld	ra,8(sp)
            tf->epc += 4;// 更新 tf->epc寄存器
    802004e8:	0791                	addi	a5,a5,4
    802004ea:	10f43423          	sd	a5,264(s0)
}
    802004ee:	6402                	ld	s0,0(sp)
    802004f0:	0141                	addi	sp,sp,16
    802004f2:	8082                	ret
            cprintf("Exception type: Breakpoint");
    802004f4:	00000517          	auipc	a0,0x0
    802004f8:	74450513          	addi	a0,a0,1860 # 80200c38 <etext+0x196>
    802004fc:	b75ff0ef          	jal	ra,80200070 <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n",tf->epc);
    80200500:	10843583          	ld	a1,264(s0)
    80200504:	00000517          	auipc	a0,0x0
    80200508:	75450513          	addi	a0,a0,1876 # 80200c58 <etext+0x1b6>
    8020050c:	b65ff0ef          	jal	ra,80200070 <cprintf>
            sbi_shutdown();
    80200510:	53e000ef          	jal	ra,80200a4e <sbi_shutdown>
            tf->epc += 4;// 更新 tf->epc寄存器
    80200514:	10843783          	ld	a5,264(s0)
}
    80200518:	60a2                	ld	ra,8(sp)
            tf->epc += 4;// 更新 tf->epc寄存器
    8020051a:	0791                	addi	a5,a5,4
    8020051c:	10f43423          	sd	a5,264(s0)
}
    80200520:	6402                	ld	s0,0(sp)
    80200522:	0141                	addi	sp,sp,16
    80200524:	8082                	ret

0000000080200526 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    80200526:	11853783          	ld	a5,280(a0)
 * trap - handles or dispatches an exception/interrupt. if and when trap()
 * returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) { trap_dispatch(tf); }
    8020052a:	1141                	addi	sp,sp,-16
    8020052c:	e022                	sd	s0,0(sp)
    8020052e:	e406                	sd	ra,8(sp)
    80200530:	842a                	mv	s0,a0
    if ((intptr_t)tf->cause < 0) {
    80200532:	0007ce63          	bltz	a5,8020054e <trap+0x28>
        cprintf("111111111");
    80200536:	00001517          	auipc	a0,0x1
    8020053a:	b7a50513          	addi	a0,a0,-1158 # 802010b0 <etext+0x60e>
    8020053e:	b33ff0ef          	jal	ra,80200070 <cprintf>
        exception_handler(tf);
    80200542:	8522                	mv	a0,s0
void trap(struct trapframe *tf) { trap_dispatch(tf); }
    80200544:	6402                	ld	s0,0(sp)
    80200546:	60a2                	ld	ra,8(sp)
    80200548:	0141                	addi	sp,sp,16
        exception_handler(tf);
    8020054a:	f43ff06f          	j	8020048c <exception_handler>
        cprintf("222222");
    8020054e:	00001517          	auipc	a0,0x1
    80200552:	b5a50513          	addi	a0,a0,-1190 # 802010a8 <etext+0x606>
    80200556:	b1bff0ef          	jal	ra,80200070 <cprintf>
        interrupt_handler(tf);
    8020055a:	8522                	mv	a0,s0
void trap(struct trapframe *tf) { trap_dispatch(tf); }
    8020055c:	6402                	ld	s0,0(sp)
    8020055e:	60a2                	ld	ra,8(sp)
    80200560:	0141                	addi	sp,sp,16
        interrupt_handler(tf);
    80200562:	e69ff06f          	j	802003ca <interrupt_handler>
	...

0000000080200568 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    80200568:	14011073          	csrw	sscratch,sp
    8020056c:	712d                	addi	sp,sp,-288
    8020056e:	e002                	sd	zero,0(sp)
    80200570:	e406                	sd	ra,8(sp)
    80200572:	ec0e                	sd	gp,24(sp)
    80200574:	f012                	sd	tp,32(sp)
    80200576:	f416                	sd	t0,40(sp)
    80200578:	f81a                	sd	t1,48(sp)
    8020057a:	fc1e                	sd	t2,56(sp)
    8020057c:	e0a2                	sd	s0,64(sp)
    8020057e:	e4a6                	sd	s1,72(sp)
    80200580:	e8aa                	sd	a0,80(sp)
    80200582:	ecae                	sd	a1,88(sp)
    80200584:	f0b2                	sd	a2,96(sp)
    80200586:	f4b6                	sd	a3,104(sp)
    80200588:	f8ba                	sd	a4,112(sp)
    8020058a:	fcbe                	sd	a5,120(sp)
    8020058c:	e142                	sd	a6,128(sp)
    8020058e:	e546                	sd	a7,136(sp)
    80200590:	e94a                	sd	s2,144(sp)
    80200592:	ed4e                	sd	s3,152(sp)
    80200594:	f152                	sd	s4,160(sp)
    80200596:	f556                	sd	s5,168(sp)
    80200598:	f95a                	sd	s6,176(sp)
    8020059a:	fd5e                	sd	s7,184(sp)
    8020059c:	e1e2                	sd	s8,192(sp)
    8020059e:	e5e6                	sd	s9,200(sp)
    802005a0:	e9ea                	sd	s10,208(sp)
    802005a2:	edee                	sd	s11,216(sp)
    802005a4:	f1f2                	sd	t3,224(sp)
    802005a6:	f5f6                	sd	t4,232(sp)
    802005a8:	f9fa                	sd	t5,240(sp)
    802005aa:	fdfe                	sd	t6,248(sp)
    802005ac:	14001473          	csrrw	s0,sscratch,zero
    802005b0:	100024f3          	csrr	s1,sstatus
    802005b4:	14102973          	csrr	s2,sepc
    802005b8:	143029f3          	csrr	s3,stval
    802005bc:	14202a73          	csrr	s4,scause
    802005c0:	e822                	sd	s0,16(sp)
    802005c2:	e226                	sd	s1,256(sp)
    802005c4:	e64a                	sd	s2,264(sp)
    802005c6:	ea4e                	sd	s3,272(sp)
    802005c8:	ee52                	sd	s4,280(sp)

    move  a0, sp
    802005ca:	850a                	mv	a0,sp
    jal trap
    802005cc:	f5bff0ef          	jal	ra,80200526 <trap>

00000000802005d0 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    802005d0:	6492                	ld	s1,256(sp)
    802005d2:	6932                	ld	s2,264(sp)
    802005d4:	10049073          	csrw	sstatus,s1
    802005d8:	14191073          	csrw	sepc,s2
    802005dc:	60a2                	ld	ra,8(sp)
    802005de:	61e2                	ld	gp,24(sp)
    802005e0:	7202                	ld	tp,32(sp)
    802005e2:	72a2                	ld	t0,40(sp)
    802005e4:	7342                	ld	t1,48(sp)
    802005e6:	73e2                	ld	t2,56(sp)
    802005e8:	6406                	ld	s0,64(sp)
    802005ea:	64a6                	ld	s1,72(sp)
    802005ec:	6546                	ld	a0,80(sp)
    802005ee:	65e6                	ld	a1,88(sp)
    802005f0:	7606                	ld	a2,96(sp)
    802005f2:	76a6                	ld	a3,104(sp)
    802005f4:	7746                	ld	a4,112(sp)
    802005f6:	77e6                	ld	a5,120(sp)
    802005f8:	680a                	ld	a6,128(sp)
    802005fa:	68aa                	ld	a7,136(sp)
    802005fc:	694a                	ld	s2,144(sp)
    802005fe:	69ea                	ld	s3,152(sp)
    80200600:	7a0a                	ld	s4,160(sp)
    80200602:	7aaa                	ld	s5,168(sp)
    80200604:	7b4a                	ld	s6,176(sp)
    80200606:	7bea                	ld	s7,184(sp)
    80200608:	6c0e                	ld	s8,192(sp)
    8020060a:	6cae                	ld	s9,200(sp)
    8020060c:	6d4e                	ld	s10,208(sp)
    8020060e:	6dee                	ld	s11,216(sp)
    80200610:	7e0e                	ld	t3,224(sp)
    80200612:	7eae                	ld	t4,232(sp)
    80200614:	7f4e                	ld	t5,240(sp)
    80200616:	7fee                	ld	t6,248(sp)
    80200618:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    8020061a:	10200073          	sret

000000008020061e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    8020061e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200622:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    80200624:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200628:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    8020062a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    8020062e:	f022                	sd	s0,32(sp)
    80200630:	ec26                	sd	s1,24(sp)
    80200632:	e84a                	sd	s2,16(sp)
    80200634:	f406                	sd	ra,40(sp)
    80200636:	e44e                	sd	s3,8(sp)
    80200638:	84aa                	mv	s1,a0
    8020063a:	892e                	mv	s2,a1
    8020063c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    80200640:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    80200642:	03067e63          	bleu	a6,a2,8020067e <printnum+0x60>
    80200646:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    80200648:	00805763          	blez	s0,80200656 <printnum+0x38>
    8020064c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    8020064e:	85ca                	mv	a1,s2
    80200650:	854e                	mv	a0,s3
    80200652:	9482                	jalr	s1
        while (-- width > 0)
    80200654:	fc65                	bnez	s0,8020064c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    80200656:	1a02                	slli	s4,s4,0x20
    80200658:	020a5a13          	srli	s4,s4,0x20
    8020065c:	00001797          	auipc	a5,0x1
    80200660:	bf478793          	addi	a5,a5,-1036 # 80201250 <error_string+0x38>
    80200664:	9a3e                	add	s4,s4,a5
}
    80200666:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200668:	000a4503          	lbu	a0,0(s4)
}
    8020066c:	70a2                	ld	ra,40(sp)
    8020066e:	69a2                	ld	s3,8(sp)
    80200670:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200672:	85ca                	mv	a1,s2
    80200674:	8326                	mv	t1,s1
}
    80200676:	6942                	ld	s2,16(sp)
    80200678:	64e2                	ld	s1,24(sp)
    8020067a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    8020067c:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    8020067e:	03065633          	divu	a2,a2,a6
    80200682:	8722                	mv	a4,s0
    80200684:	f9bff0ef          	jal	ra,8020061e <printnum>
    80200688:	b7f9                	j	80200656 <printnum+0x38>

000000008020068a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    8020068a:	7119                	addi	sp,sp,-128
    8020068c:	f4a6                	sd	s1,104(sp)
    8020068e:	f0ca                	sd	s2,96(sp)
    80200690:	e8d2                	sd	s4,80(sp)
    80200692:	e4d6                	sd	s5,72(sp)
    80200694:	e0da                	sd	s6,64(sp)
    80200696:	fc5e                	sd	s7,56(sp)
    80200698:	f862                	sd	s8,48(sp)
    8020069a:	f06a                	sd	s10,32(sp)
    8020069c:	fc86                	sd	ra,120(sp)
    8020069e:	f8a2                	sd	s0,112(sp)
    802006a0:	ecce                	sd	s3,88(sp)
    802006a2:	f466                	sd	s9,40(sp)
    802006a4:	ec6e                	sd	s11,24(sp)
    802006a6:	892a                	mv	s2,a0
    802006a8:	84ae                	mv	s1,a1
    802006aa:	8d32                	mv	s10,a2
    802006ac:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    802006ae:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    802006b0:	00001a17          	auipc	s4,0x1
    802006b4:	a0ca0a13          	addi	s4,s4,-1524 # 802010bc <etext+0x61a>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    802006b8:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802006bc:	00001c17          	auipc	s8,0x1
    802006c0:	b5cc0c13          	addi	s8,s8,-1188 # 80201218 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006c4:	000d4503          	lbu	a0,0(s10)
    802006c8:	02500793          	li	a5,37
    802006cc:	001d0413          	addi	s0,s10,1
    802006d0:	00f50e63          	beq	a0,a5,802006ec <vprintfmt+0x62>
            if (ch == '\0') {
    802006d4:	c521                	beqz	a0,8020071c <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006d6:	02500993          	li	s3,37
    802006da:	a011                	j	802006de <vprintfmt+0x54>
            if (ch == '\0') {
    802006dc:	c121                	beqz	a0,8020071c <vprintfmt+0x92>
            putch(ch, putdat);
    802006de:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006e0:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    802006e2:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006e4:	fff44503          	lbu	a0,-1(s0)
    802006e8:	ff351ae3          	bne	a0,s3,802006dc <vprintfmt+0x52>
    802006ec:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    802006f0:	02000793          	li	a5,32
        lflag = altflag = 0;
    802006f4:	4981                	li	s3,0
    802006f6:	4801                	li	a6,0
        width = precision = -1;
    802006f8:	5cfd                	li	s9,-1
    802006fa:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    802006fc:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    80200700:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    80200702:	fdd6069b          	addiw	a3,a2,-35
    80200706:	0ff6f693          	andi	a3,a3,255
    8020070a:	00140d13          	addi	s10,s0,1
    8020070e:	20d5e563          	bltu	a1,a3,80200918 <vprintfmt+0x28e>
    80200712:	068a                	slli	a3,a3,0x2
    80200714:	96d2                	add	a3,a3,s4
    80200716:	4294                	lw	a3,0(a3)
    80200718:	96d2                	add	a3,a3,s4
    8020071a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    8020071c:	70e6                	ld	ra,120(sp)
    8020071e:	7446                	ld	s0,112(sp)
    80200720:	74a6                	ld	s1,104(sp)
    80200722:	7906                	ld	s2,96(sp)
    80200724:	69e6                	ld	s3,88(sp)
    80200726:	6a46                	ld	s4,80(sp)
    80200728:	6aa6                	ld	s5,72(sp)
    8020072a:	6b06                	ld	s6,64(sp)
    8020072c:	7be2                	ld	s7,56(sp)
    8020072e:	7c42                	ld	s8,48(sp)
    80200730:	7ca2                	ld	s9,40(sp)
    80200732:	7d02                	ld	s10,32(sp)
    80200734:	6de2                	ld	s11,24(sp)
    80200736:	6109                	addi	sp,sp,128
    80200738:	8082                	ret
    if (lflag >= 2) {
    8020073a:	4705                	li	a4,1
    8020073c:	008a8593          	addi	a1,s5,8
    80200740:	01074463          	blt	a4,a6,80200748 <vprintfmt+0xbe>
    else if (lflag) {
    80200744:	26080363          	beqz	a6,802009aa <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
    80200748:	000ab603          	ld	a2,0(s5)
    8020074c:	46c1                	li	a3,16
    8020074e:	8aae                	mv	s5,a1
    80200750:	a06d                	j	802007fa <vprintfmt+0x170>
            goto reswitch;
    80200752:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    80200756:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200758:	846a                	mv	s0,s10
            goto reswitch;
    8020075a:	b765                	j	80200702 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
    8020075c:	000aa503          	lw	a0,0(s5)
    80200760:	85a6                	mv	a1,s1
    80200762:	0aa1                	addi	s5,s5,8
    80200764:	9902                	jalr	s2
            break;
    80200766:	bfb9                	j	802006c4 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200768:	4705                	li	a4,1
    8020076a:	008a8993          	addi	s3,s5,8
    8020076e:	01074463          	blt	a4,a6,80200776 <vprintfmt+0xec>
    else if (lflag) {
    80200772:	22080463          	beqz	a6,8020099a <vprintfmt+0x310>
        return va_arg(*ap, long);
    80200776:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    8020077a:	24044463          	bltz	s0,802009c2 <vprintfmt+0x338>
            num = getint(&ap, lflag);
    8020077e:	8622                	mv	a2,s0
    80200780:	8ace                	mv	s5,s3
    80200782:	46a9                	li	a3,10
    80200784:	a89d                	j	802007fa <vprintfmt+0x170>
            err = va_arg(ap, int);
    80200786:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020078a:	4719                	li	a4,6
            err = va_arg(ap, int);
    8020078c:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    8020078e:	41f7d69b          	sraiw	a3,a5,0x1f
    80200792:	8fb5                	xor	a5,a5,a3
    80200794:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200798:	1ad74363          	blt	a4,a3,8020093e <vprintfmt+0x2b4>
    8020079c:	00369793          	slli	a5,a3,0x3
    802007a0:	97e2                	add	a5,a5,s8
    802007a2:	639c                	ld	a5,0(a5)
    802007a4:	18078d63          	beqz	a5,8020093e <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
    802007a8:	86be                	mv	a3,a5
    802007aa:	00001617          	auipc	a2,0x1
    802007ae:	b5660613          	addi	a2,a2,-1194 # 80201300 <error_string+0xe8>
    802007b2:	85a6                	mv	a1,s1
    802007b4:	854a                	mv	a0,s2
    802007b6:	240000ef          	jal	ra,802009f6 <printfmt>
    802007ba:	b729                	j	802006c4 <vprintfmt+0x3a>
            lflag ++;
    802007bc:	00144603          	lbu	a2,1(s0)
    802007c0:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    802007c2:	846a                	mv	s0,s10
            goto reswitch;
    802007c4:	bf3d                	j	80200702 <vprintfmt+0x78>
    if (lflag >= 2) {
    802007c6:	4705                	li	a4,1
    802007c8:	008a8593          	addi	a1,s5,8
    802007cc:	01074463          	blt	a4,a6,802007d4 <vprintfmt+0x14a>
    else if (lflag) {
    802007d0:	1e080263          	beqz	a6,802009b4 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
    802007d4:	000ab603          	ld	a2,0(s5)
    802007d8:	46a1                	li	a3,8
    802007da:	8aae                	mv	s5,a1
    802007dc:	a839                	j	802007fa <vprintfmt+0x170>
            putch('0', putdat);
    802007de:	03000513          	li	a0,48
    802007e2:	85a6                	mv	a1,s1
    802007e4:	e03e                	sd	a5,0(sp)
    802007e6:	9902                	jalr	s2
            putch('x', putdat);
    802007e8:	85a6                	mv	a1,s1
    802007ea:	07800513          	li	a0,120
    802007ee:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    802007f0:	0aa1                	addi	s5,s5,8
    802007f2:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    802007f6:	6782                	ld	a5,0(sp)
    802007f8:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    802007fa:	876e                	mv	a4,s11
    802007fc:	85a6                	mv	a1,s1
    802007fe:	854a                	mv	a0,s2
    80200800:	e1fff0ef          	jal	ra,8020061e <printnum>
            break;
    80200804:	b5c1                	j	802006c4 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200806:	000ab603          	ld	a2,0(s5)
    8020080a:	0aa1                	addi	s5,s5,8
    8020080c:	1c060663          	beqz	a2,802009d8 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
    80200810:	00160413          	addi	s0,a2,1
    80200814:	17b05c63          	blez	s11,8020098c <vprintfmt+0x302>
    80200818:	02d00593          	li	a1,45
    8020081c:	14b79263          	bne	a5,a1,80200960 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200820:	00064783          	lbu	a5,0(a2)
    80200824:	0007851b          	sext.w	a0,a5
    80200828:	c905                	beqz	a0,80200858 <vprintfmt+0x1ce>
    8020082a:	000cc563          	bltz	s9,80200834 <vprintfmt+0x1aa>
    8020082e:	3cfd                	addiw	s9,s9,-1
    80200830:	036c8263          	beq	s9,s6,80200854 <vprintfmt+0x1ca>
                    putch('?', putdat);
    80200834:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200836:	18098463          	beqz	s3,802009be <vprintfmt+0x334>
    8020083a:	3781                	addiw	a5,a5,-32
    8020083c:	18fbf163          	bleu	a5,s7,802009be <vprintfmt+0x334>
                    putch('?', putdat);
    80200840:	03f00513          	li	a0,63
    80200844:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200846:	0405                	addi	s0,s0,1
    80200848:	fff44783          	lbu	a5,-1(s0)
    8020084c:	3dfd                	addiw	s11,s11,-1
    8020084e:	0007851b          	sext.w	a0,a5
    80200852:	fd61                	bnez	a0,8020082a <vprintfmt+0x1a0>
            for (; width > 0; width --) {
    80200854:	e7b058e3          	blez	s11,802006c4 <vprintfmt+0x3a>
    80200858:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    8020085a:	85a6                	mv	a1,s1
    8020085c:	02000513          	li	a0,32
    80200860:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200862:	e60d81e3          	beqz	s11,802006c4 <vprintfmt+0x3a>
    80200866:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200868:	85a6                	mv	a1,s1
    8020086a:	02000513          	li	a0,32
    8020086e:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200870:	fe0d94e3          	bnez	s11,80200858 <vprintfmt+0x1ce>
    80200874:	bd81                	j	802006c4 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200876:	4705                	li	a4,1
    80200878:	008a8593          	addi	a1,s5,8
    8020087c:	01074463          	blt	a4,a6,80200884 <vprintfmt+0x1fa>
    else if (lflag) {
    80200880:	12080063          	beqz	a6,802009a0 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
    80200884:	000ab603          	ld	a2,0(s5)
    80200888:	46a9                	li	a3,10
    8020088a:	8aae                	mv	s5,a1
    8020088c:	b7bd                	j	802007fa <vprintfmt+0x170>
    8020088e:	00144603          	lbu	a2,1(s0)
            padc = '-';
    80200892:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
    80200896:	846a                	mv	s0,s10
    80200898:	b5ad                	j	80200702 <vprintfmt+0x78>
            putch(ch, putdat);
    8020089a:	85a6                	mv	a1,s1
    8020089c:	02500513          	li	a0,37
    802008a0:	9902                	jalr	s2
            break;
    802008a2:	b50d                	j	802006c4 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
    802008a4:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    802008a8:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    802008ac:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    802008ae:	846a                	mv	s0,s10
            if (width < 0)
    802008b0:	e40dd9e3          	bgez	s11,80200702 <vprintfmt+0x78>
                width = precision, precision = -1;
    802008b4:	8de6                	mv	s11,s9
    802008b6:	5cfd                	li	s9,-1
    802008b8:	b5a9                	j	80200702 <vprintfmt+0x78>
            goto reswitch;
    802008ba:	00144603          	lbu	a2,1(s0)
            padc = '0';
    802008be:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
    802008c2:	846a                	mv	s0,s10
            goto reswitch;
    802008c4:	bd3d                	j	80200702 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
    802008c6:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    802008ca:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802008ce:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    802008d0:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    802008d4:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802008d8:	fcd56ce3          	bltu	a0,a3,802008b0 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
    802008dc:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    802008de:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    802008e2:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    802008e6:	0196873b          	addw	a4,a3,s9
    802008ea:	0017171b          	slliw	a4,a4,0x1
    802008ee:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    802008f2:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    802008f6:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    802008fa:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802008fe:	fcd57fe3          	bleu	a3,a0,802008dc <vprintfmt+0x252>
    80200902:	b77d                	j	802008b0 <vprintfmt+0x226>
            if (width < 0)
    80200904:	fffdc693          	not	a3,s11
    80200908:	96fd                	srai	a3,a3,0x3f
    8020090a:	00ddfdb3          	and	s11,s11,a3
    8020090e:	00144603          	lbu	a2,1(s0)
    80200912:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    80200914:	846a                	mv	s0,s10
    80200916:	b3f5                	j	80200702 <vprintfmt+0x78>
            putch('%', putdat);
    80200918:	85a6                	mv	a1,s1
    8020091a:	02500513          	li	a0,37
    8020091e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    80200920:	fff44703          	lbu	a4,-1(s0)
    80200924:	02500793          	li	a5,37
    80200928:	8d22                	mv	s10,s0
    8020092a:	d8f70de3          	beq	a4,a5,802006c4 <vprintfmt+0x3a>
    8020092e:	02500713          	li	a4,37
    80200932:	1d7d                	addi	s10,s10,-1
    80200934:	fffd4783          	lbu	a5,-1(s10)
    80200938:	fee79de3          	bne	a5,a4,80200932 <vprintfmt+0x2a8>
    8020093c:	b361                	j	802006c4 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    8020093e:	00001617          	auipc	a2,0x1
    80200942:	9b260613          	addi	a2,a2,-1614 # 802012f0 <error_string+0xd8>
    80200946:	85a6                	mv	a1,s1
    80200948:	854a                	mv	a0,s2
    8020094a:	0ac000ef          	jal	ra,802009f6 <printfmt>
    8020094e:	bb9d                	j	802006c4 <vprintfmt+0x3a>
                p = "(null)";
    80200950:	00001617          	auipc	a2,0x1
    80200954:	99860613          	addi	a2,a2,-1640 # 802012e8 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    80200958:	00001417          	auipc	s0,0x1
    8020095c:	99140413          	addi	s0,s0,-1647 # 802012e9 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200960:	8532                	mv	a0,a2
    80200962:	85e6                	mv	a1,s9
    80200964:	e032                	sd	a2,0(sp)
    80200966:	e43e                	sd	a5,8(sp)
    80200968:	102000ef          	jal	ra,80200a6a <strnlen>
    8020096c:	40ad8dbb          	subw	s11,s11,a0
    80200970:	6602                	ld	a2,0(sp)
    80200972:	01b05d63          	blez	s11,8020098c <vprintfmt+0x302>
    80200976:	67a2                	ld	a5,8(sp)
    80200978:	2781                	sext.w	a5,a5
    8020097a:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    8020097c:	6522                	ld	a0,8(sp)
    8020097e:	85a6                	mv	a1,s1
    80200980:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200982:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    80200984:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200986:	6602                	ld	a2,0(sp)
    80200988:	fe0d9ae3          	bnez	s11,8020097c <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020098c:	00064783          	lbu	a5,0(a2)
    80200990:	0007851b          	sext.w	a0,a5
    80200994:	e8051be3          	bnez	a0,8020082a <vprintfmt+0x1a0>
    80200998:	b335                	j	802006c4 <vprintfmt+0x3a>
        return va_arg(*ap, int);
    8020099a:	000aa403          	lw	s0,0(s5)
    8020099e:	bbf1                	j	8020077a <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
    802009a0:	000ae603          	lwu	a2,0(s5)
    802009a4:	46a9                	li	a3,10
    802009a6:	8aae                	mv	s5,a1
    802009a8:	bd89                	j	802007fa <vprintfmt+0x170>
    802009aa:	000ae603          	lwu	a2,0(s5)
    802009ae:	46c1                	li	a3,16
    802009b0:	8aae                	mv	s5,a1
    802009b2:	b5a1                	j	802007fa <vprintfmt+0x170>
    802009b4:	000ae603          	lwu	a2,0(s5)
    802009b8:	46a1                	li	a3,8
    802009ba:	8aae                	mv	s5,a1
    802009bc:	bd3d                	j	802007fa <vprintfmt+0x170>
                    putch(ch, putdat);
    802009be:	9902                	jalr	s2
    802009c0:	b559                	j	80200846 <vprintfmt+0x1bc>
                putch('-', putdat);
    802009c2:	85a6                	mv	a1,s1
    802009c4:	02d00513          	li	a0,45
    802009c8:	e03e                	sd	a5,0(sp)
    802009ca:	9902                	jalr	s2
                num = -(long long)num;
    802009cc:	8ace                	mv	s5,s3
    802009ce:	40800633          	neg	a2,s0
    802009d2:	46a9                	li	a3,10
    802009d4:	6782                	ld	a5,0(sp)
    802009d6:	b515                	j	802007fa <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
    802009d8:	01b05663          	blez	s11,802009e4 <vprintfmt+0x35a>
    802009dc:	02d00693          	li	a3,45
    802009e0:	f6d798e3          	bne	a5,a3,80200950 <vprintfmt+0x2c6>
    802009e4:	00001417          	auipc	s0,0x1
    802009e8:	90540413          	addi	s0,s0,-1787 # 802012e9 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802009ec:	02800513          	li	a0,40
    802009f0:	02800793          	li	a5,40
    802009f4:	bd1d                	j	8020082a <vprintfmt+0x1a0>

00000000802009f6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009f6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    802009f8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009fc:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009fe:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200a00:	ec06                	sd	ra,24(sp)
    80200a02:	f83a                	sd	a4,48(sp)
    80200a04:	fc3e                	sd	a5,56(sp)
    80200a06:	e0c2                	sd	a6,64(sp)
    80200a08:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    80200a0a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200a0c:	c7fff0ef          	jal	ra,8020068a <vprintfmt>
}
    80200a10:	60e2                	ld	ra,24(sp)
    80200a12:	6161                	addi	sp,sp,80
    80200a14:	8082                	ret

0000000080200a16 <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    80200a16:	00003797          	auipc	a5,0x3
    80200a1a:	5ea78793          	addi	a5,a5,1514 # 80204000 <bootstacktop>
    __asm__ volatile (
    80200a1e:	6398                	ld	a4,0(a5)
    80200a20:	4781                	li	a5,0
    80200a22:	88ba                	mv	a7,a4
    80200a24:	852a                	mv	a0,a0
    80200a26:	85be                	mv	a1,a5
    80200a28:	863e                	mv	a2,a5
    80200a2a:	00000073          	ecall
    80200a2e:	87aa                	mv	a5,a0
}
    80200a30:	8082                	ret

0000000080200a32 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    80200a32:	00003797          	auipc	a5,0x3
    80200a36:	5e678793          	addi	a5,a5,1510 # 80204018 <SBI_SET_TIMER>
    __asm__ volatile (
    80200a3a:	6398                	ld	a4,0(a5)
    80200a3c:	4781                	li	a5,0
    80200a3e:	88ba                	mv	a7,a4
    80200a40:	852a                	mv	a0,a0
    80200a42:	85be                	mv	a1,a5
    80200a44:	863e                	mv	a2,a5
    80200a46:	00000073          	ecall
    80200a4a:	87aa                	mv	a5,a0
}
    80200a4c:	8082                	ret

0000000080200a4e <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200a4e:	00003797          	auipc	a5,0x3
    80200a52:	5ba78793          	addi	a5,a5,1466 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    80200a56:	6398                	ld	a4,0(a5)
    80200a58:	4781                	li	a5,0
    80200a5a:	88ba                	mv	a7,a4
    80200a5c:	853e                	mv	a0,a5
    80200a5e:	85be                	mv	a1,a5
    80200a60:	863e                	mv	a2,a5
    80200a62:	00000073          	ecall
    80200a66:	87aa                	mv	a5,a0
    80200a68:	8082                	ret

0000000080200a6a <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    80200a6a:	c185                	beqz	a1,80200a8a <strnlen+0x20>
    80200a6c:	00054783          	lbu	a5,0(a0)
    80200a70:	cf89                	beqz	a5,80200a8a <strnlen+0x20>
    size_t cnt = 0;
    80200a72:	4781                	li	a5,0
    80200a74:	a021                	j	80200a7c <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    80200a76:	00074703          	lbu	a4,0(a4)
    80200a7a:	c711                	beqz	a4,80200a86 <strnlen+0x1c>
        cnt ++;
    80200a7c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200a7e:	00f50733          	add	a4,a0,a5
    80200a82:	fef59ae3          	bne	a1,a5,80200a76 <strnlen+0xc>
    }
    return cnt;
}
    80200a86:	853e                	mv	a0,a5
    80200a88:	8082                	ret
    size_t cnt = 0;
    80200a8a:	4781                	li	a5,0
}
    80200a8c:	853e                	mv	a0,a5
    80200a8e:	8082                	ret

0000000080200a90 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200a90:	ca01                	beqz	a2,80200aa0 <memset+0x10>
    80200a92:	962a                	add	a2,a2,a0
    char *p = s;
    80200a94:	87aa                	mv	a5,a0
        *p ++ = c;
    80200a96:	0785                	addi	a5,a5,1
    80200a98:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200a9c:	fec79de3          	bne	a5,a2,80200a96 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200aa0:	8082                	ret
