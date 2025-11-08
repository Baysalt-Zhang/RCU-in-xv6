
user/_alloctest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test0>:
#include "user/user.h"

enum { NCHILD = 50, NFD = 10};

void
test0() {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	1800                	addi	s0,sp,48
  int i, j;
  int fd;

  printf("filetest: start\n");
   c:	00001517          	auipc	a0,0x1
  10:	9d450513          	addi	a0,a0,-1580 # 9e0 <malloc+0xe6>
  14:	00001097          	auipc	ra,0x1
  18:	828080e7          	jalr	-2008(ra) # 83c <printf>
  1c:	03200493          	li	s1,50
    printf("test setup is wrong\n");
    exit(1);
  }

  for (i = 0; i < NCHILD; i++) {
    int pid = fork();
  20:	00000097          	auipc	ra,0x0
  24:	48c080e7          	jalr	1164(ra) # 4ac <fork>
    if(pid < 0){
  28:	04054263          	bltz	a0,6c <test0+0x6c>
      printf("fork failed\n");
      exit(-1);
    }
    if(pid == 0){
  2c:	cd29                	beqz	a0,86 <test0+0x86>
  for (i = 0; i < NCHILD; i++) {
  2e:	34fd                	addiw	s1,s1,-1
  30:	f8e5                	bnez	s1,20 <test0+0x20>
  32:	03200493          	li	s1,50
  }

  for(int i = 0; i < NCHILD; i++){
    int xstatus;
    wait(&xstatus);
    if(xstatus == -1) {
  36:	597d                	li	s2,-1
    wait(&xstatus);
  38:	fdc40513          	addi	a0,s0,-36
  3c:	00000097          	auipc	ra,0x0
  40:	480080e7          	jalr	1152(ra) # 4bc <wait>
    if(xstatus == -1) {
  44:	fdc42783          	lw	a5,-36(s0)
  48:	09278563          	beq	a5,s2,d2 <test0+0xd2>
  for(int i = 0; i < NCHILD; i++){
  4c:	34fd                	addiw	s1,s1,-1
  4e:	f4ed                	bnez	s1,38 <test0+0x38>
       printf("filetest: FAILED\n");
       exit(-1);
    }
  }

  printf("filetest: OK\n");
  50:	00001517          	auipc	a0,0x1
  54:	9e850513          	addi	a0,a0,-1560 # a38 <malloc+0x13e>
  58:	00000097          	auipc	ra,0x0
  5c:	7e4080e7          	jalr	2020(ra) # 83c <printf>
}
  60:	70a2                	ld	ra,40(sp)
  62:	7402                	ld	s0,32(sp)
  64:	64e2                	ld	s1,24(sp)
  66:	6942                	ld	s2,16(sp)
  68:	6145                	addi	sp,sp,48
  6a:	8082                	ret
      printf("fork failed\n");
  6c:	00001517          	auipc	a0,0x1
  70:	98c50513          	addi	a0,a0,-1652 # 9f8 <malloc+0xfe>
  74:	00000097          	auipc	ra,0x0
  78:	7c8080e7          	jalr	1992(ra) # 83c <printf>
      exit(-1);
  7c:	557d                	li	a0,-1
  7e:	00000097          	auipc	ra,0x0
  82:	436080e7          	jalr	1078(ra) # 4b4 <exit>
  86:	44a9                	li	s1,10
        if ((fd = open("README", O_RDONLY)) < 0) {
  88:	00001917          	auipc	s2,0x1
  8c:	98090913          	addi	s2,s2,-1664 # a08 <malloc+0x10e>
  90:	4581                	li	a1,0
  92:	854a                	mv	a0,s2
  94:	00000097          	auipc	ra,0x0
  98:	460080e7          	jalr	1120(ra) # 4f4 <open>
  9c:	00054e63          	bltz	a0,b8 <test0+0xb8>
      for(j = 0; j < NFD; j++) {
  a0:	34fd                	addiw	s1,s1,-1
  a2:	f4fd                	bnez	s1,90 <test0+0x90>
      sleep(10);
  a4:	4529                	li	a0,10
  a6:	00000097          	auipc	ra,0x0
  aa:	49e080e7          	jalr	1182(ra) # 544 <sleep>
      exit(0);  // no errors; exit with 0.
  ae:	4501                	li	a0,0
  b0:	00000097          	auipc	ra,0x0
  b4:	404080e7          	jalr	1028(ra) # 4b4 <exit>
          printf("open failed\n");
  b8:	00001517          	auipc	a0,0x1
  bc:	95850513          	addi	a0,a0,-1704 # a10 <malloc+0x116>
  c0:	00000097          	auipc	ra,0x0
  c4:	77c080e7          	jalr	1916(ra) # 83c <printf>
          exit(-1);
  c8:	557d                	li	a0,-1
  ca:	00000097          	auipc	ra,0x0
  ce:	3ea080e7          	jalr	1002(ra) # 4b4 <exit>
       printf("filetest: FAILED\n");
  d2:	00001517          	auipc	a0,0x1
  d6:	94e50513          	addi	a0,a0,-1714 # a20 <malloc+0x126>
  da:	00000097          	auipc	ra,0x0
  de:	762080e7          	jalr	1890(ra) # 83c <printf>
       exit(-1);
  e2:	557d                	li	a0,-1
  e4:	00000097          	auipc	ra,0x0
  e8:	3d0080e7          	jalr	976(ra) # 4b4 <exit>

00000000000000ec <test1>:

void test1()
{
  ec:	7139                	addi	sp,sp,-64
  ee:	fc06                	sd	ra,56(sp)
  f0:	f822                	sd	s0,48(sp)
  f2:	f426                	sd	s1,40(sp)
  f4:	f04a                	sd	s2,32(sp)
  f6:	ec4e                	sd	s3,24(sp)
  f8:	0080                	addi	s0,sp,64
  int pid, xstatus, n0, n;

  printf("memtest: start\n");
  fa:	00001517          	auipc	a0,0x1
  fe:	94e50513          	addi	a0,a0,-1714 # a48 <malloc+0x14e>
 102:	00000097          	auipc	ra,0x0
 106:	73a080e7          	jalr	1850(ra) # 83c <printf>

  n0 = nfree();
 10a:	00000097          	auipc	ra,0x0
 10e:	452080e7          	jalr	1106(ra) # 55c <nfree>
 112:	84aa                	mv	s1,a0

  pid = fork();
 114:	00000097          	auipc	ra,0x0
 118:	398080e7          	jalr	920(ra) # 4ac <fork>
  if(pid < 0){
 11c:	04054f63          	bltz	a0,17a <test1+0x8e>
    printf("fork failed");
    exit(1);
  }

  if(pid == 0){
 120:	ed41                	bnez	a0,1b8 <test1+0xcc>
    int i, fd;

    n0 = nfree();
 122:	00000097          	auipc	ra,0x0
 126:	43a080e7          	jalr	1082(ra) # 55c <nfree>
 12a:	89aa                	mv	s3,a0
 12c:	44a9                	li	s1,10
    for(i = 0; i < NFD; i++) {
      if ((fd = open("README", O_RDONLY)) < 0) {
 12e:	00001917          	auipc	s2,0x1
 132:	8da90913          	addi	s2,s2,-1830 # a08 <malloc+0x10e>
 136:	4581                	li	a1,0
 138:	854a                	mv	a0,s2
 13a:	00000097          	auipc	ra,0x0
 13e:	3ba080e7          	jalr	954(ra) # 4f4 <open>
 142:	04054963          	bltz	a0,194 <test1+0xa8>
    for(i = 0; i < NFD; i++) {
 146:	34fd                	addiw	s1,s1,-1
 148:	f4fd                	bnez	s1,136 <test1+0x4a>
        // the open() failed; exit with -1
        printf("open failed\n");
        exit(-1);
      }
    }
    n = n0 - nfree();
 14a:	00000097          	auipc	ra,0x0
 14e:	412080e7          	jalr	1042(ra) # 55c <nfree>
 152:	40a9853b          	subw	a0,s3,a0
 156:	0005059b          	sext.w	a1,a0
    // n should be 0 but we're okay with 1
    if(n != 0 && n != 1){
 15a:	4785                	li	a5,1
 15c:	04b7f963          	bgeu	a5,a1,1ae <test1+0xc2>
      printf("expected to allocate at most one page, got %d\n", n);
 160:	00001517          	auipc	a0,0x1
 164:	90850513          	addi	a0,a0,-1784 # a68 <malloc+0x16e>
 168:	00000097          	auipc	ra,0x0
 16c:	6d4080e7          	jalr	1748(ra) # 83c <printf>
      exit(-1);
 170:	557d                	li	a0,-1
 172:	00000097          	auipc	ra,0x0
 176:	342080e7          	jalr	834(ra) # 4b4 <exit>
    printf("fork failed");
 17a:	00001517          	auipc	a0,0x1
 17e:	8de50513          	addi	a0,a0,-1826 # a58 <malloc+0x15e>
 182:	00000097          	auipc	ra,0x0
 186:	6ba080e7          	jalr	1722(ra) # 83c <printf>
    exit(1);
 18a:	4505                	li	a0,1
 18c:	00000097          	auipc	ra,0x0
 190:	328080e7          	jalr	808(ra) # 4b4 <exit>
        printf("open failed\n");
 194:	00001517          	auipc	a0,0x1
 198:	87c50513          	addi	a0,a0,-1924 # a10 <malloc+0x116>
 19c:	00000097          	auipc	ra,0x0
 1a0:	6a0080e7          	jalr	1696(ra) # 83c <printf>
        exit(-1);
 1a4:	557d                	li	a0,-1
 1a6:	00000097          	auipc	ra,0x0
 1aa:	30e080e7          	jalr	782(ra) # 4b4 <exit>
    }
    exit(0);
 1ae:	4501                	li	a0,0
 1b0:	00000097          	auipc	ra,0x0
 1b4:	304080e7          	jalr	772(ra) # 4b4 <exit>
  }

  wait(&xstatus);
 1b8:	fcc40513          	addi	a0,s0,-52
 1bc:	00000097          	auipc	ra,0x0
 1c0:	300080e7          	jalr	768(ra) # 4bc <wait>
  if(xstatus == -1)
 1c4:	fcc42703          	lw	a4,-52(s0)
 1c8:	57fd                	li	a5,-1
 1ca:	02f70a63          	beq	a4,a5,1fe <test1+0x112>
    goto failed;

  n = n0 - nfree();
 1ce:	00000097          	auipc	ra,0x0
 1d2:	38e080e7          	jalr	910(ra) # 55c <nfree>
 1d6:	40a485bb          	subw	a1,s1,a0
  if(n){
 1da:	e991                	bnez	a1,1ee <test1+0x102>
    printf("expected to free all the pages, got %d\n", n);
    goto failed;
  }
  printf("memtest: OK\n");
 1dc:	00001517          	auipc	a0,0x1
 1e0:	8e450513          	addi	a0,a0,-1820 # ac0 <malloc+0x1c6>
 1e4:	00000097          	auipc	ra,0x0
 1e8:	658080e7          	jalr	1624(ra) # 83c <printf>
  return;
 1ec:	a00d                	j	20e <test1+0x122>
    printf("expected to free all the pages, got %d\n", n);
 1ee:	00001517          	auipc	a0,0x1
 1f2:	8aa50513          	addi	a0,a0,-1878 # a98 <malloc+0x19e>
 1f6:	00000097          	auipc	ra,0x0
 1fa:	646080e7          	jalr	1606(ra) # 83c <printf>

failed:
  printf("memtest: FAILED\n");
 1fe:	00001517          	auipc	a0,0x1
 202:	8d250513          	addi	a0,a0,-1838 # ad0 <malloc+0x1d6>
 206:	00000097          	auipc	ra,0x0
 20a:	636080e7          	jalr	1590(ra) # 83c <printf>
}
 20e:	70e2                	ld	ra,56(sp)
 210:	7442                	ld	s0,48(sp)
 212:	74a2                	ld	s1,40(sp)
 214:	7902                	ld	s2,32(sp)
 216:	69e2                	ld	s3,24(sp)
 218:	6121                	addi	sp,sp,64
 21a:	8082                	ret

000000000000021c <main>:

int
main(int argc, char *argv[])
{
 21c:	1141                	addi	sp,sp,-16
 21e:	e406                	sd	ra,8(sp)
 220:	e022                	sd	s0,0(sp)
 222:	0800                	addi	s0,sp,16
  test0();
 224:	00000097          	auipc	ra,0x0
 228:	ddc080e7          	jalr	-548(ra) # 0 <test0>
  test1();
 22c:	00000097          	auipc	ra,0x0
 230:	ec0080e7          	jalr	-320(ra) # ec <test1>
  exit(0);
 234:	4501                	li	a0,0
 236:	00000097          	auipc	ra,0x0
 23a:	27e080e7          	jalr	638(ra) # 4b4 <exit>

000000000000023e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 23e:	1141                	addi	sp,sp,-16
 240:	e422                	sd	s0,8(sp)
 242:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 244:	87aa                	mv	a5,a0
 246:	0585                	addi	a1,a1,1
 248:	0785                	addi	a5,a5,1
 24a:	fff5c703          	lbu	a4,-1(a1)
 24e:	fee78fa3          	sb	a4,-1(a5)
 252:	fb75                	bnez	a4,246 <strcpy+0x8>
    ;
  return os;
}
 254:	6422                	ld	s0,8(sp)
 256:	0141                	addi	sp,sp,16
 258:	8082                	ret

000000000000025a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 25a:	1141                	addi	sp,sp,-16
 25c:	e422                	sd	s0,8(sp)
 25e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 260:	00054783          	lbu	a5,0(a0)
 264:	cb91                	beqz	a5,278 <strcmp+0x1e>
 266:	0005c703          	lbu	a4,0(a1)
 26a:	00f71763          	bne	a4,a5,278 <strcmp+0x1e>
    p++, q++;
 26e:	0505                	addi	a0,a0,1
 270:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 272:	00054783          	lbu	a5,0(a0)
 276:	fbe5                	bnez	a5,266 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 278:	0005c503          	lbu	a0,0(a1)
}
 27c:	40a7853b          	subw	a0,a5,a0
 280:	6422                	ld	s0,8(sp)
 282:	0141                	addi	sp,sp,16
 284:	8082                	ret

0000000000000286 <strlen>:

uint
strlen(const char *s)
{
 286:	1141                	addi	sp,sp,-16
 288:	e422                	sd	s0,8(sp)
 28a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 28c:	00054783          	lbu	a5,0(a0)
 290:	cf91                	beqz	a5,2ac <strlen+0x26>
 292:	0505                	addi	a0,a0,1
 294:	87aa                	mv	a5,a0
 296:	4685                	li	a3,1
 298:	9e89                	subw	a3,a3,a0
 29a:	00f6853b          	addw	a0,a3,a5
 29e:	0785                	addi	a5,a5,1
 2a0:	fff7c703          	lbu	a4,-1(a5)
 2a4:	fb7d                	bnez	a4,29a <strlen+0x14>
    ;
  return n;
}
 2a6:	6422                	ld	s0,8(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret
  for(n = 0; s[n]; n++)
 2ac:	4501                	li	a0,0
 2ae:	bfe5                	j	2a6 <strlen+0x20>

00000000000002b0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2b0:	1141                	addi	sp,sp,-16
 2b2:	e422                	sd	s0,8(sp)
 2b4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2b6:	ce09                	beqz	a2,2d0 <memset+0x20>
 2b8:	87aa                	mv	a5,a0
 2ba:	fff6071b          	addiw	a4,a2,-1
 2be:	1702                	slli	a4,a4,0x20
 2c0:	9301                	srli	a4,a4,0x20
 2c2:	0705                	addi	a4,a4,1
 2c4:	972a                	add	a4,a4,a0
    cdst[i] = c;
 2c6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2ca:	0785                	addi	a5,a5,1
 2cc:	fee79de3          	bne	a5,a4,2c6 <memset+0x16>
  }
  return dst;
}
 2d0:	6422                	ld	s0,8(sp)
 2d2:	0141                	addi	sp,sp,16
 2d4:	8082                	ret

00000000000002d6 <strchr>:

char*
strchr(const char *s, char c)
{
 2d6:	1141                	addi	sp,sp,-16
 2d8:	e422                	sd	s0,8(sp)
 2da:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2dc:	00054783          	lbu	a5,0(a0)
 2e0:	cb99                	beqz	a5,2f6 <strchr+0x20>
    if(*s == c)
 2e2:	00f58763          	beq	a1,a5,2f0 <strchr+0x1a>
  for(; *s; s++)
 2e6:	0505                	addi	a0,a0,1
 2e8:	00054783          	lbu	a5,0(a0)
 2ec:	fbfd                	bnez	a5,2e2 <strchr+0xc>
      return (char*)s;
  return 0;
 2ee:	4501                	li	a0,0
}
 2f0:	6422                	ld	s0,8(sp)
 2f2:	0141                	addi	sp,sp,16
 2f4:	8082                	ret
  return 0;
 2f6:	4501                	li	a0,0
 2f8:	bfe5                	j	2f0 <strchr+0x1a>

00000000000002fa <gets>:

char*
gets(char *buf, int max)
{
 2fa:	711d                	addi	sp,sp,-96
 2fc:	ec86                	sd	ra,88(sp)
 2fe:	e8a2                	sd	s0,80(sp)
 300:	e4a6                	sd	s1,72(sp)
 302:	e0ca                	sd	s2,64(sp)
 304:	fc4e                	sd	s3,56(sp)
 306:	f852                	sd	s4,48(sp)
 308:	f456                	sd	s5,40(sp)
 30a:	f05a                	sd	s6,32(sp)
 30c:	ec5e                	sd	s7,24(sp)
 30e:	1080                	addi	s0,sp,96
 310:	8baa                	mv	s7,a0
 312:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 314:	892a                	mv	s2,a0
 316:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 318:	4aa9                	li	s5,10
 31a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 31c:	89a6                	mv	s3,s1
 31e:	2485                	addiw	s1,s1,1
 320:	0344d863          	bge	s1,s4,350 <gets+0x56>
    cc = read(0, &c, 1);
 324:	4605                	li	a2,1
 326:	faf40593          	addi	a1,s0,-81
 32a:	4501                	li	a0,0
 32c:	00000097          	auipc	ra,0x0
 330:	1a0080e7          	jalr	416(ra) # 4cc <read>
    if(cc < 1)
 334:	00a05e63          	blez	a0,350 <gets+0x56>
    buf[i++] = c;
 338:	faf44783          	lbu	a5,-81(s0)
 33c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 340:	01578763          	beq	a5,s5,34e <gets+0x54>
 344:	0905                	addi	s2,s2,1
 346:	fd679be3          	bne	a5,s6,31c <gets+0x22>
  for(i=0; i+1 < max; ){
 34a:	89a6                	mv	s3,s1
 34c:	a011                	j	350 <gets+0x56>
 34e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 350:	99de                	add	s3,s3,s7
 352:	00098023          	sb	zero,0(s3)
  return buf;
}
 356:	855e                	mv	a0,s7
 358:	60e6                	ld	ra,88(sp)
 35a:	6446                	ld	s0,80(sp)
 35c:	64a6                	ld	s1,72(sp)
 35e:	6906                	ld	s2,64(sp)
 360:	79e2                	ld	s3,56(sp)
 362:	7a42                	ld	s4,48(sp)
 364:	7aa2                	ld	s5,40(sp)
 366:	7b02                	ld	s6,32(sp)
 368:	6be2                	ld	s7,24(sp)
 36a:	6125                	addi	sp,sp,96
 36c:	8082                	ret

000000000000036e <stat>:

int
stat(const char *n, struct stat *st)
{
 36e:	1101                	addi	sp,sp,-32
 370:	ec06                	sd	ra,24(sp)
 372:	e822                	sd	s0,16(sp)
 374:	e426                	sd	s1,8(sp)
 376:	e04a                	sd	s2,0(sp)
 378:	1000                	addi	s0,sp,32
 37a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 37c:	4581                	li	a1,0
 37e:	00000097          	auipc	ra,0x0
 382:	176080e7          	jalr	374(ra) # 4f4 <open>
  if(fd < 0)
 386:	02054563          	bltz	a0,3b0 <stat+0x42>
 38a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 38c:	85ca                	mv	a1,s2
 38e:	00000097          	auipc	ra,0x0
 392:	17e080e7          	jalr	382(ra) # 50c <fstat>
 396:	892a                	mv	s2,a0
  close(fd);
 398:	8526                	mv	a0,s1
 39a:	00000097          	auipc	ra,0x0
 39e:	142080e7          	jalr	322(ra) # 4dc <close>
  return r;
}
 3a2:	854a                	mv	a0,s2
 3a4:	60e2                	ld	ra,24(sp)
 3a6:	6442                	ld	s0,16(sp)
 3a8:	64a2                	ld	s1,8(sp)
 3aa:	6902                	ld	s2,0(sp)
 3ac:	6105                	addi	sp,sp,32
 3ae:	8082                	ret
    return -1;
 3b0:	597d                	li	s2,-1
 3b2:	bfc5                	j	3a2 <stat+0x34>

00000000000003b4 <atoi>:

int
atoi(const char *s)
{
 3b4:	1141                	addi	sp,sp,-16
 3b6:	e422                	sd	s0,8(sp)
 3b8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3ba:	00054603          	lbu	a2,0(a0)
 3be:	fd06079b          	addiw	a5,a2,-48
 3c2:	0ff7f793          	andi	a5,a5,255
 3c6:	4725                	li	a4,9
 3c8:	02f76963          	bltu	a4,a5,3fa <atoi+0x46>
 3cc:	86aa                	mv	a3,a0
  n = 0;
 3ce:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3d0:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3d2:	0685                	addi	a3,a3,1
 3d4:	0025179b          	slliw	a5,a0,0x2
 3d8:	9fa9                	addw	a5,a5,a0
 3da:	0017979b          	slliw	a5,a5,0x1
 3de:	9fb1                	addw	a5,a5,a2
 3e0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3e4:	0006c603          	lbu	a2,0(a3)
 3e8:	fd06071b          	addiw	a4,a2,-48
 3ec:	0ff77713          	andi	a4,a4,255
 3f0:	fee5f1e3          	bgeu	a1,a4,3d2 <atoi+0x1e>
  return n;
}
 3f4:	6422                	ld	s0,8(sp)
 3f6:	0141                	addi	sp,sp,16
 3f8:	8082                	ret
  n = 0;
 3fa:	4501                	li	a0,0
 3fc:	bfe5                	j	3f4 <atoi+0x40>

00000000000003fe <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3fe:	1141                	addi	sp,sp,-16
 400:	e422                	sd	s0,8(sp)
 402:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 404:	02b57663          	bgeu	a0,a1,430 <memmove+0x32>
    while(n-- > 0)
 408:	02c05163          	blez	a2,42a <memmove+0x2c>
 40c:	fff6079b          	addiw	a5,a2,-1
 410:	1782                	slli	a5,a5,0x20
 412:	9381                	srli	a5,a5,0x20
 414:	0785                	addi	a5,a5,1
 416:	97aa                	add	a5,a5,a0
  dst = vdst;
 418:	872a                	mv	a4,a0
      *dst++ = *src++;
 41a:	0585                	addi	a1,a1,1
 41c:	0705                	addi	a4,a4,1
 41e:	fff5c683          	lbu	a3,-1(a1)
 422:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 426:	fee79ae3          	bne	a5,a4,41a <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 42a:	6422                	ld	s0,8(sp)
 42c:	0141                	addi	sp,sp,16
 42e:	8082                	ret
    dst += n;
 430:	00c50733          	add	a4,a0,a2
    src += n;
 434:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 436:	fec05ae3          	blez	a2,42a <memmove+0x2c>
 43a:	fff6079b          	addiw	a5,a2,-1
 43e:	1782                	slli	a5,a5,0x20
 440:	9381                	srli	a5,a5,0x20
 442:	fff7c793          	not	a5,a5
 446:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 448:	15fd                	addi	a1,a1,-1
 44a:	177d                	addi	a4,a4,-1
 44c:	0005c683          	lbu	a3,0(a1)
 450:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 454:	fee79ae3          	bne	a5,a4,448 <memmove+0x4a>
 458:	bfc9                	j	42a <memmove+0x2c>

000000000000045a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 45a:	1141                	addi	sp,sp,-16
 45c:	e422                	sd	s0,8(sp)
 45e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 460:	ca05                	beqz	a2,490 <memcmp+0x36>
 462:	fff6069b          	addiw	a3,a2,-1
 466:	1682                	slli	a3,a3,0x20
 468:	9281                	srli	a3,a3,0x20
 46a:	0685                	addi	a3,a3,1
 46c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 46e:	00054783          	lbu	a5,0(a0)
 472:	0005c703          	lbu	a4,0(a1)
 476:	00e79863          	bne	a5,a4,486 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 47a:	0505                	addi	a0,a0,1
    p2++;
 47c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 47e:	fed518e3          	bne	a0,a3,46e <memcmp+0x14>
  }
  return 0;
 482:	4501                	li	a0,0
 484:	a019                	j	48a <memcmp+0x30>
      return *p1 - *p2;
 486:	40e7853b          	subw	a0,a5,a4
}
 48a:	6422                	ld	s0,8(sp)
 48c:	0141                	addi	sp,sp,16
 48e:	8082                	ret
  return 0;
 490:	4501                	li	a0,0
 492:	bfe5                	j	48a <memcmp+0x30>

0000000000000494 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 494:	1141                	addi	sp,sp,-16
 496:	e406                	sd	ra,8(sp)
 498:	e022                	sd	s0,0(sp)
 49a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 49c:	00000097          	auipc	ra,0x0
 4a0:	f62080e7          	jalr	-158(ra) # 3fe <memmove>
}
 4a4:	60a2                	ld	ra,8(sp)
 4a6:	6402                	ld	s0,0(sp)
 4a8:	0141                	addi	sp,sp,16
 4aa:	8082                	ret

00000000000004ac <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4ac:	4885                	li	a7,1
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4b4:	4889                	li	a7,2
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <wait>:
.global wait
wait:
 li a7, SYS_wait
 4bc:	488d                	li	a7,3
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4c4:	4891                	li	a7,4
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <read>:
.global read
read:
 li a7, SYS_read
 4cc:	4895                	li	a7,5
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <write>:
.global write
write:
 li a7, SYS_write
 4d4:	48c1                	li	a7,16
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <close>:
.global close
close:
 li a7, SYS_close
 4dc:	48d5                	li	a7,21
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4e4:	4899                	li	a7,6
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <exec>:
.global exec
exec:
 li a7, SYS_exec
 4ec:	489d                	li	a7,7
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <open>:
.global open
open:
 li a7, SYS_open
 4f4:	48bd                	li	a7,15
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4fc:	48c5                	li	a7,17
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 504:	48c9                	li	a7,18
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 50c:	48a1                	li	a7,8
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <link>:
.global link
link:
 li a7, SYS_link
 514:	48cd                	li	a7,19
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 51c:	48d1                	li	a7,20
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 524:	48a5                	li	a7,9
 ecall
 526:	00000073          	ecall
 ret
 52a:	8082                	ret

000000000000052c <dup>:
.global dup
dup:
 li a7, SYS_dup
 52c:	48a9                	li	a7,10
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 534:	48ad                	li	a7,11
 ecall
 536:	00000073          	ecall
 ret
 53a:	8082                	ret

000000000000053c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 53c:	48b1                	li	a7,12
 ecall
 53e:	00000073          	ecall
 ret
 542:	8082                	ret

0000000000000544 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 544:	48b5                	li	a7,13
 ecall
 546:	00000073          	ecall
 ret
 54a:	8082                	ret

000000000000054c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 54c:	48b9                	li	a7,14
 ecall
 54e:	00000073          	ecall
 ret
 552:	8082                	ret

0000000000000554 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 554:	48d9                	li	a7,22
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <nfree>:
.global nfree
nfree:
 li a7, SYS_nfree
 55c:	48dd                	li	a7,23
 ecall
 55e:	00000073          	ecall
 ret
 562:	8082                	ret

0000000000000564 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 564:	1101                	addi	sp,sp,-32
 566:	ec06                	sd	ra,24(sp)
 568:	e822                	sd	s0,16(sp)
 56a:	1000                	addi	s0,sp,32
 56c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 570:	4605                	li	a2,1
 572:	fef40593          	addi	a1,s0,-17
 576:	00000097          	auipc	ra,0x0
 57a:	f5e080e7          	jalr	-162(ra) # 4d4 <write>
}
 57e:	60e2                	ld	ra,24(sp)
 580:	6442                	ld	s0,16(sp)
 582:	6105                	addi	sp,sp,32
 584:	8082                	ret

0000000000000586 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 586:	7139                	addi	sp,sp,-64
 588:	fc06                	sd	ra,56(sp)
 58a:	f822                	sd	s0,48(sp)
 58c:	f426                	sd	s1,40(sp)
 58e:	f04a                	sd	s2,32(sp)
 590:	ec4e                	sd	s3,24(sp)
 592:	0080                	addi	s0,sp,64
 594:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 596:	c299                	beqz	a3,59c <printint+0x16>
 598:	0805c863          	bltz	a1,628 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 59c:	2581                	sext.w	a1,a1
  neg = 0;
 59e:	4881                	li	a7,0
 5a0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5a4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5a6:	2601                	sext.w	a2,a2
 5a8:	00000517          	auipc	a0,0x0
 5ac:	54850513          	addi	a0,a0,1352 # af0 <digits>
 5b0:	883a                	mv	a6,a4
 5b2:	2705                	addiw	a4,a4,1
 5b4:	02c5f7bb          	remuw	a5,a1,a2
 5b8:	1782                	slli	a5,a5,0x20
 5ba:	9381                	srli	a5,a5,0x20
 5bc:	97aa                	add	a5,a5,a0
 5be:	0007c783          	lbu	a5,0(a5)
 5c2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5c6:	0005879b          	sext.w	a5,a1
 5ca:	02c5d5bb          	divuw	a1,a1,a2
 5ce:	0685                	addi	a3,a3,1
 5d0:	fec7f0e3          	bgeu	a5,a2,5b0 <printint+0x2a>
  if(neg)
 5d4:	00088b63          	beqz	a7,5ea <printint+0x64>
    buf[i++] = '-';
 5d8:	fd040793          	addi	a5,s0,-48
 5dc:	973e                	add	a4,a4,a5
 5de:	02d00793          	li	a5,45
 5e2:	fef70823          	sb	a5,-16(a4)
 5e6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5ea:	02e05863          	blez	a4,61a <printint+0x94>
 5ee:	fc040793          	addi	a5,s0,-64
 5f2:	00e78933          	add	s2,a5,a4
 5f6:	fff78993          	addi	s3,a5,-1
 5fa:	99ba                	add	s3,s3,a4
 5fc:	377d                	addiw	a4,a4,-1
 5fe:	1702                	slli	a4,a4,0x20
 600:	9301                	srli	a4,a4,0x20
 602:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 606:	fff94583          	lbu	a1,-1(s2)
 60a:	8526                	mv	a0,s1
 60c:	00000097          	auipc	ra,0x0
 610:	f58080e7          	jalr	-168(ra) # 564 <putc>
  while(--i >= 0)
 614:	197d                	addi	s2,s2,-1
 616:	ff3918e3          	bne	s2,s3,606 <printint+0x80>
}
 61a:	70e2                	ld	ra,56(sp)
 61c:	7442                	ld	s0,48(sp)
 61e:	74a2                	ld	s1,40(sp)
 620:	7902                	ld	s2,32(sp)
 622:	69e2                	ld	s3,24(sp)
 624:	6121                	addi	sp,sp,64
 626:	8082                	ret
    x = -xx;
 628:	40b005bb          	negw	a1,a1
    neg = 1;
 62c:	4885                	li	a7,1
    x = -xx;
 62e:	bf8d                	j	5a0 <printint+0x1a>

0000000000000630 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 630:	7119                	addi	sp,sp,-128
 632:	fc86                	sd	ra,120(sp)
 634:	f8a2                	sd	s0,112(sp)
 636:	f4a6                	sd	s1,104(sp)
 638:	f0ca                	sd	s2,96(sp)
 63a:	ecce                	sd	s3,88(sp)
 63c:	e8d2                	sd	s4,80(sp)
 63e:	e4d6                	sd	s5,72(sp)
 640:	e0da                	sd	s6,64(sp)
 642:	fc5e                	sd	s7,56(sp)
 644:	f862                	sd	s8,48(sp)
 646:	f466                	sd	s9,40(sp)
 648:	f06a                	sd	s10,32(sp)
 64a:	ec6e                	sd	s11,24(sp)
 64c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 64e:	0005c903          	lbu	s2,0(a1)
 652:	18090f63          	beqz	s2,7f0 <vprintf+0x1c0>
 656:	8aaa                	mv	s5,a0
 658:	8b32                	mv	s6,a2
 65a:	00158493          	addi	s1,a1,1
  state = 0;
 65e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 660:	02500a13          	li	s4,37
      if(c == 'd'){
 664:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 668:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 66c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 670:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 674:	00000b97          	auipc	s7,0x0
 678:	47cb8b93          	addi	s7,s7,1148 # af0 <digits>
 67c:	a839                	j	69a <vprintf+0x6a>
        putc(fd, c);
 67e:	85ca                	mv	a1,s2
 680:	8556                	mv	a0,s5
 682:	00000097          	auipc	ra,0x0
 686:	ee2080e7          	jalr	-286(ra) # 564 <putc>
 68a:	a019                	j	690 <vprintf+0x60>
    } else if(state == '%'){
 68c:	01498f63          	beq	s3,s4,6aa <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 690:	0485                	addi	s1,s1,1
 692:	fff4c903          	lbu	s2,-1(s1)
 696:	14090d63          	beqz	s2,7f0 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 69a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 69e:	fe0997e3          	bnez	s3,68c <vprintf+0x5c>
      if(c == '%'){
 6a2:	fd479ee3          	bne	a5,s4,67e <vprintf+0x4e>
        state = '%';
 6a6:	89be                	mv	s3,a5
 6a8:	b7e5                	j	690 <vprintf+0x60>
      if(c == 'd'){
 6aa:	05878063          	beq	a5,s8,6ea <vprintf+0xba>
      } else if(c == 'l') {
 6ae:	05978c63          	beq	a5,s9,706 <vprintf+0xd6>
      } else if(c == 'x') {
 6b2:	07a78863          	beq	a5,s10,722 <vprintf+0xf2>
      } else if(c == 'p') {
 6b6:	09b78463          	beq	a5,s11,73e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 6ba:	07300713          	li	a4,115
 6be:	0ce78663          	beq	a5,a4,78a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6c2:	06300713          	li	a4,99
 6c6:	0ee78e63          	beq	a5,a4,7c2 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 6ca:	11478863          	beq	a5,s4,7da <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6ce:	85d2                	mv	a1,s4
 6d0:	8556                	mv	a0,s5
 6d2:	00000097          	auipc	ra,0x0
 6d6:	e92080e7          	jalr	-366(ra) # 564 <putc>
        putc(fd, c);
 6da:	85ca                	mv	a1,s2
 6dc:	8556                	mv	a0,s5
 6de:	00000097          	auipc	ra,0x0
 6e2:	e86080e7          	jalr	-378(ra) # 564 <putc>
      }
      state = 0;
 6e6:	4981                	li	s3,0
 6e8:	b765                	j	690 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6ea:	008b0913          	addi	s2,s6,8
 6ee:	4685                	li	a3,1
 6f0:	4629                	li	a2,10
 6f2:	000b2583          	lw	a1,0(s6)
 6f6:	8556                	mv	a0,s5
 6f8:	00000097          	auipc	ra,0x0
 6fc:	e8e080e7          	jalr	-370(ra) # 586 <printint>
 700:	8b4a                	mv	s6,s2
      state = 0;
 702:	4981                	li	s3,0
 704:	b771                	j	690 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 706:	008b0913          	addi	s2,s6,8
 70a:	4681                	li	a3,0
 70c:	4629                	li	a2,10
 70e:	000b2583          	lw	a1,0(s6)
 712:	8556                	mv	a0,s5
 714:	00000097          	auipc	ra,0x0
 718:	e72080e7          	jalr	-398(ra) # 586 <printint>
 71c:	8b4a                	mv	s6,s2
      state = 0;
 71e:	4981                	li	s3,0
 720:	bf85                	j	690 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 722:	008b0913          	addi	s2,s6,8
 726:	4681                	li	a3,0
 728:	4641                	li	a2,16
 72a:	000b2583          	lw	a1,0(s6)
 72e:	8556                	mv	a0,s5
 730:	00000097          	auipc	ra,0x0
 734:	e56080e7          	jalr	-426(ra) # 586 <printint>
 738:	8b4a                	mv	s6,s2
      state = 0;
 73a:	4981                	li	s3,0
 73c:	bf91                	j	690 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 73e:	008b0793          	addi	a5,s6,8
 742:	f8f43423          	sd	a5,-120(s0)
 746:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 74a:	03000593          	li	a1,48
 74e:	8556                	mv	a0,s5
 750:	00000097          	auipc	ra,0x0
 754:	e14080e7          	jalr	-492(ra) # 564 <putc>
  putc(fd, 'x');
 758:	85ea                	mv	a1,s10
 75a:	8556                	mv	a0,s5
 75c:	00000097          	auipc	ra,0x0
 760:	e08080e7          	jalr	-504(ra) # 564 <putc>
 764:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 766:	03c9d793          	srli	a5,s3,0x3c
 76a:	97de                	add	a5,a5,s7
 76c:	0007c583          	lbu	a1,0(a5)
 770:	8556                	mv	a0,s5
 772:	00000097          	auipc	ra,0x0
 776:	df2080e7          	jalr	-526(ra) # 564 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 77a:	0992                	slli	s3,s3,0x4
 77c:	397d                	addiw	s2,s2,-1
 77e:	fe0914e3          	bnez	s2,766 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 782:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 786:	4981                	li	s3,0
 788:	b721                	j	690 <vprintf+0x60>
        s = va_arg(ap, char*);
 78a:	008b0993          	addi	s3,s6,8
 78e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 792:	02090163          	beqz	s2,7b4 <vprintf+0x184>
        while(*s != 0){
 796:	00094583          	lbu	a1,0(s2)
 79a:	c9a1                	beqz	a1,7ea <vprintf+0x1ba>
          putc(fd, *s);
 79c:	8556                	mv	a0,s5
 79e:	00000097          	auipc	ra,0x0
 7a2:	dc6080e7          	jalr	-570(ra) # 564 <putc>
          s++;
 7a6:	0905                	addi	s2,s2,1
        while(*s != 0){
 7a8:	00094583          	lbu	a1,0(s2)
 7ac:	f9e5                	bnez	a1,79c <vprintf+0x16c>
        s = va_arg(ap, char*);
 7ae:	8b4e                	mv	s6,s3
      state = 0;
 7b0:	4981                	li	s3,0
 7b2:	bdf9                	j	690 <vprintf+0x60>
          s = "(null)";
 7b4:	00000917          	auipc	s2,0x0
 7b8:	33490913          	addi	s2,s2,820 # ae8 <malloc+0x1ee>
        while(*s != 0){
 7bc:	02800593          	li	a1,40
 7c0:	bff1                	j	79c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 7c2:	008b0913          	addi	s2,s6,8
 7c6:	000b4583          	lbu	a1,0(s6)
 7ca:	8556                	mv	a0,s5
 7cc:	00000097          	auipc	ra,0x0
 7d0:	d98080e7          	jalr	-616(ra) # 564 <putc>
 7d4:	8b4a                	mv	s6,s2
      state = 0;
 7d6:	4981                	li	s3,0
 7d8:	bd65                	j	690 <vprintf+0x60>
        putc(fd, c);
 7da:	85d2                	mv	a1,s4
 7dc:	8556                	mv	a0,s5
 7de:	00000097          	auipc	ra,0x0
 7e2:	d86080e7          	jalr	-634(ra) # 564 <putc>
      state = 0;
 7e6:	4981                	li	s3,0
 7e8:	b565                	j	690 <vprintf+0x60>
        s = va_arg(ap, char*);
 7ea:	8b4e                	mv	s6,s3
      state = 0;
 7ec:	4981                	li	s3,0
 7ee:	b54d                	j	690 <vprintf+0x60>
    }
  }
}
 7f0:	70e6                	ld	ra,120(sp)
 7f2:	7446                	ld	s0,112(sp)
 7f4:	74a6                	ld	s1,104(sp)
 7f6:	7906                	ld	s2,96(sp)
 7f8:	69e6                	ld	s3,88(sp)
 7fa:	6a46                	ld	s4,80(sp)
 7fc:	6aa6                	ld	s5,72(sp)
 7fe:	6b06                	ld	s6,64(sp)
 800:	7be2                	ld	s7,56(sp)
 802:	7c42                	ld	s8,48(sp)
 804:	7ca2                	ld	s9,40(sp)
 806:	7d02                	ld	s10,32(sp)
 808:	6de2                	ld	s11,24(sp)
 80a:	6109                	addi	sp,sp,128
 80c:	8082                	ret

000000000000080e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 80e:	715d                	addi	sp,sp,-80
 810:	ec06                	sd	ra,24(sp)
 812:	e822                	sd	s0,16(sp)
 814:	1000                	addi	s0,sp,32
 816:	e010                	sd	a2,0(s0)
 818:	e414                	sd	a3,8(s0)
 81a:	e818                	sd	a4,16(s0)
 81c:	ec1c                	sd	a5,24(s0)
 81e:	03043023          	sd	a6,32(s0)
 822:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 826:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 82a:	8622                	mv	a2,s0
 82c:	00000097          	auipc	ra,0x0
 830:	e04080e7          	jalr	-508(ra) # 630 <vprintf>
}
 834:	60e2                	ld	ra,24(sp)
 836:	6442                	ld	s0,16(sp)
 838:	6161                	addi	sp,sp,80
 83a:	8082                	ret

000000000000083c <printf>:

void
printf(const char *fmt, ...)
{
 83c:	711d                	addi	sp,sp,-96
 83e:	ec06                	sd	ra,24(sp)
 840:	e822                	sd	s0,16(sp)
 842:	1000                	addi	s0,sp,32
 844:	e40c                	sd	a1,8(s0)
 846:	e810                	sd	a2,16(s0)
 848:	ec14                	sd	a3,24(s0)
 84a:	f018                	sd	a4,32(s0)
 84c:	f41c                	sd	a5,40(s0)
 84e:	03043823          	sd	a6,48(s0)
 852:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 856:	00840613          	addi	a2,s0,8
 85a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 85e:	85aa                	mv	a1,a0
 860:	4505                	li	a0,1
 862:	00000097          	auipc	ra,0x0
 866:	dce080e7          	jalr	-562(ra) # 630 <vprintf>
}
 86a:	60e2                	ld	ra,24(sp)
 86c:	6442                	ld	s0,16(sp)
 86e:	6125                	addi	sp,sp,96
 870:	8082                	ret

0000000000000872 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 872:	1141                	addi	sp,sp,-16
 874:	e422                	sd	s0,8(sp)
 876:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 878:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 87c:	00000797          	auipc	a5,0x0
 880:	28c7b783          	ld	a5,652(a5) # b08 <freep>
 884:	a805                	j	8b4 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 886:	4618                	lw	a4,8(a2)
 888:	9db9                	addw	a1,a1,a4
 88a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 88e:	6398                	ld	a4,0(a5)
 890:	6318                	ld	a4,0(a4)
 892:	fee53823          	sd	a4,-16(a0)
 896:	a091                	j	8da <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 898:	ff852703          	lw	a4,-8(a0)
 89c:	9e39                	addw	a2,a2,a4
 89e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 8a0:	ff053703          	ld	a4,-16(a0)
 8a4:	e398                	sd	a4,0(a5)
 8a6:	a099                	j	8ec <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a8:	6398                	ld	a4,0(a5)
 8aa:	00e7e463          	bltu	a5,a4,8b2 <free+0x40>
 8ae:	00e6ea63          	bltu	a3,a4,8c2 <free+0x50>
{
 8b2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b4:	fed7fae3          	bgeu	a5,a3,8a8 <free+0x36>
 8b8:	6398                	ld	a4,0(a5)
 8ba:	00e6e463          	bltu	a3,a4,8c2 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8be:	fee7eae3          	bltu	a5,a4,8b2 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8c2:	ff852583          	lw	a1,-8(a0)
 8c6:	6390                	ld	a2,0(a5)
 8c8:	02059713          	slli	a4,a1,0x20
 8cc:	9301                	srli	a4,a4,0x20
 8ce:	0712                	slli	a4,a4,0x4
 8d0:	9736                	add	a4,a4,a3
 8d2:	fae60ae3          	beq	a2,a4,886 <free+0x14>
    bp->s.ptr = p->s.ptr;
 8d6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8da:	4790                	lw	a2,8(a5)
 8dc:	02061713          	slli	a4,a2,0x20
 8e0:	9301                	srli	a4,a4,0x20
 8e2:	0712                	slli	a4,a4,0x4
 8e4:	973e                	add	a4,a4,a5
 8e6:	fae689e3          	beq	a3,a4,898 <free+0x26>
  } else
    p->s.ptr = bp;
 8ea:	e394                	sd	a3,0(a5)
  freep = p;
 8ec:	00000717          	auipc	a4,0x0
 8f0:	20f73e23          	sd	a5,540(a4) # b08 <freep>
}
 8f4:	6422                	ld	s0,8(sp)
 8f6:	0141                	addi	sp,sp,16
 8f8:	8082                	ret

00000000000008fa <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8fa:	7139                	addi	sp,sp,-64
 8fc:	fc06                	sd	ra,56(sp)
 8fe:	f822                	sd	s0,48(sp)
 900:	f426                	sd	s1,40(sp)
 902:	f04a                	sd	s2,32(sp)
 904:	ec4e                	sd	s3,24(sp)
 906:	e852                	sd	s4,16(sp)
 908:	e456                	sd	s5,8(sp)
 90a:	e05a                	sd	s6,0(sp)
 90c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 90e:	02051493          	slli	s1,a0,0x20
 912:	9081                	srli	s1,s1,0x20
 914:	04bd                	addi	s1,s1,15
 916:	8091                	srli	s1,s1,0x4
 918:	0014899b          	addiw	s3,s1,1
 91c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 91e:	00000517          	auipc	a0,0x0
 922:	1ea53503          	ld	a0,490(a0) # b08 <freep>
 926:	c515                	beqz	a0,952 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 928:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 92a:	4798                	lw	a4,8(a5)
 92c:	02977f63          	bgeu	a4,s1,96a <malloc+0x70>
 930:	8a4e                	mv	s4,s3
 932:	0009871b          	sext.w	a4,s3
 936:	6685                	lui	a3,0x1
 938:	00d77363          	bgeu	a4,a3,93e <malloc+0x44>
 93c:	6a05                	lui	s4,0x1
 93e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 942:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 946:	00000917          	auipc	s2,0x0
 94a:	1c290913          	addi	s2,s2,450 # b08 <freep>
  if(p == (char*)-1)
 94e:	5afd                	li	s5,-1
 950:	a88d                	j	9c2 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 952:	00000797          	auipc	a5,0x0
 956:	1be78793          	addi	a5,a5,446 # b10 <base>
 95a:	00000717          	auipc	a4,0x0
 95e:	1af73723          	sd	a5,430(a4) # b08 <freep>
 962:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 964:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 968:	b7e1                	j	930 <malloc+0x36>
      if(p->s.size == nunits)
 96a:	02e48b63          	beq	s1,a4,9a0 <malloc+0xa6>
        p->s.size -= nunits;
 96e:	4137073b          	subw	a4,a4,s3
 972:	c798                	sw	a4,8(a5)
        p += p->s.size;
 974:	1702                	slli	a4,a4,0x20
 976:	9301                	srli	a4,a4,0x20
 978:	0712                	slli	a4,a4,0x4
 97a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 97c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 980:	00000717          	auipc	a4,0x0
 984:	18a73423          	sd	a0,392(a4) # b08 <freep>
      return (void*)(p + 1);
 988:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 98c:	70e2                	ld	ra,56(sp)
 98e:	7442                	ld	s0,48(sp)
 990:	74a2                	ld	s1,40(sp)
 992:	7902                	ld	s2,32(sp)
 994:	69e2                	ld	s3,24(sp)
 996:	6a42                	ld	s4,16(sp)
 998:	6aa2                	ld	s5,8(sp)
 99a:	6b02                	ld	s6,0(sp)
 99c:	6121                	addi	sp,sp,64
 99e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9a0:	6398                	ld	a4,0(a5)
 9a2:	e118                	sd	a4,0(a0)
 9a4:	bff1                	j	980 <malloc+0x86>
  hp->s.size = nu;
 9a6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9aa:	0541                	addi	a0,a0,16
 9ac:	00000097          	auipc	ra,0x0
 9b0:	ec6080e7          	jalr	-314(ra) # 872 <free>
  return freep;
 9b4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9b8:	d971                	beqz	a0,98c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ba:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9bc:	4798                	lw	a4,8(a5)
 9be:	fa9776e3          	bgeu	a4,s1,96a <malloc+0x70>
    if(p == freep)
 9c2:	00093703          	ld	a4,0(s2)
 9c6:	853e                	mv	a0,a5
 9c8:	fef719e3          	bne	a4,a5,9ba <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 9cc:	8552                	mv	a0,s4
 9ce:	00000097          	auipc	ra,0x0
 9d2:	b6e080e7          	jalr	-1170(ra) # 53c <sbrk>
  if(p == (char*)-1)
 9d6:	fd5518e3          	bne	a0,s5,9a6 <malloc+0xac>
        return 0;
 9da:	4501                	li	a0,0
 9dc:	bf45                	j	98c <malloc+0x92>
