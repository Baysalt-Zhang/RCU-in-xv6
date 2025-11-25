
user/_kalloctest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test0>:
  // test1();
  exit(0);
}

void test0()
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
  void *a, *a1;
  int n = 0;
  printf("start test0\n");  
   e:	00001517          	auipc	a0,0x1
  12:	a9250513          	addi	a0,a0,-1390 # aa0 <malloc+0xe8>
  16:	00001097          	auipc	ra,0x1
  1a:	8e4080e7          	jalr	-1820(ra) # 8fa <printf>
  ntas(0);
  1e:	4501                	li	a0,0
  20:	00000097          	auipc	ra,0x0
  24:	5ca080e7          	jalr	1482(ra) # 5ea <ntas>
  for(int i = 0; i < NCHILD; i++){
    int pid = fork();
  28:	00000097          	auipc	ra,0x0
  2c:	51a080e7          	jalr	1306(ra) # 542 <fork>
    if(pid < 0){
  30:	06054363          	bltz	a0,96 <test0+0x96>
      printf("fork failed");
      exit(-1);
    }
    if(pid == 0){
  34:	cd35                	beqz	a0,b0 <test0+0xb0>
    int pid = fork();
  36:	00000097          	auipc	ra,0x0
  3a:	50c080e7          	jalr	1292(ra) # 542 <fork>
    if(pid < 0){
  3e:	04054c63          	bltz	a0,96 <test0+0x96>
    if(pid == 0){
  42:	c53d                	beqz	a0,b0 <test0+0xb0>
      exit(-1);
    }
  }

  for(int i = 0; i < NCHILD; i++){
    wait(0);
  44:	4501                	li	a0,0
  46:	00000097          	auipc	ra,0x0
  4a:	50c080e7          	jalr	1292(ra) # 552 <wait>
  4e:	4501                	li	a0,0
  50:	00000097          	auipc	ra,0x0
  54:	502080e7          	jalr	1282(ra) # 552 <wait>
  }
  printf("test0 results:\n");
  58:	00001517          	auipc	a0,0x1
  5c:	a7850513          	addi	a0,a0,-1416 # ad0 <malloc+0x118>
  60:	00001097          	auipc	ra,0x1
  64:	89a080e7          	jalr	-1894(ra) # 8fa <printf>
  n = ntas(1);
  68:	4505                	li	a0,1
  6a:	00000097          	auipc	ra,0x0
  6e:	580080e7          	jalr	1408(ra) # 5ea <ntas>
  if(n < 10) 
  72:	47a5                	li	a5,9
  74:	08a7c863          	blt	a5,a0,104 <test0+0x104>
    printf("test0 OK\n");
  78:	00001517          	auipc	a0,0x1
  7c:	a6850513          	addi	a0,a0,-1432 # ae0 <malloc+0x128>
  80:	00001097          	auipc	ra,0x1
  84:	87a080e7          	jalr	-1926(ra) # 8fa <printf>
  else
    printf("test0 FAIL\n");
}
  88:	70a2                	ld	ra,40(sp)
  8a:	7402                	ld	s0,32(sp)
  8c:	64e2                	ld	s1,24(sp)
  8e:	6942                	ld	s2,16(sp)
  90:	69a2                	ld	s3,8(sp)
  92:	6145                	addi	sp,sp,48
  94:	8082                	ret
      printf("fork failed");
  96:	00001517          	auipc	a0,0x1
  9a:	a1a50513          	addi	a0,a0,-1510 # ab0 <malloc+0xf8>
  9e:	00001097          	auipc	ra,0x1
  a2:	85c080e7          	jalr	-1956(ra) # 8fa <printf>
      exit(-1);
  a6:	557d                	li	a0,-1
  a8:	00000097          	auipc	ra,0x0
  ac:	4a2080e7          	jalr	1186(ra) # 54a <exit>
{
  b0:	6961                	lui	s2,0x18
  b2:	6a090913          	addi	s2,s2,1696 # 186a0 <__global_pointer$+0x172d7>
        *(int *)(a+4) = 1;
  b6:	4985                	li	s3,1
        a = sbrk(4096);
  b8:	6505                	lui	a0,0x1
  ba:	00000097          	auipc	ra,0x0
  be:	518080e7          	jalr	1304(ra) # 5d2 <sbrk>
  c2:	84aa                	mv	s1,a0
        *(int *)(a+4) = 1;
  c4:	01352223          	sw	s3,4(a0) # 1004 <__BSS_END__+0x41c>
        a1 = sbrk(-4096);
  c8:	757d                	lui	a0,0xfffff
  ca:	00000097          	auipc	ra,0x0
  ce:	508080e7          	jalr	1288(ra) # 5d2 <sbrk>
        if (a1 != a + 4096) {
  d2:	6785                	lui	a5,0x1
  d4:	94be                	add	s1,s1,a5
  d6:	00951a63          	bne	a0,s1,ea <test0+0xea>
      for(i = 0; i < N; i++) {
  da:	397d                	addiw	s2,s2,-1
  dc:	fc091ee3          	bnez	s2,b8 <test0+0xb8>
      exit(-1);
  e0:	557d                	li	a0,-1
  e2:	00000097          	auipc	ra,0x0
  e6:	468080e7          	jalr	1128(ra) # 54a <exit>
          printf("wrong sbrk\n");
  ea:	00001517          	auipc	a0,0x1
  ee:	9d650513          	addi	a0,a0,-1578 # ac0 <malloc+0x108>
  f2:	00001097          	auipc	ra,0x1
  f6:	808080e7          	jalr	-2040(ra) # 8fa <printf>
          exit(-1);
  fa:	557d                	li	a0,-1
  fc:	00000097          	auipc	ra,0x0
 100:	44e080e7          	jalr	1102(ra) # 54a <exit>
    printf("test0 FAIL\n");
 104:	00001517          	auipc	a0,0x1
 108:	9ec50513          	addi	a0,a0,-1556 # af0 <malloc+0x138>
 10c:	00000097          	auipc	ra,0x0
 110:	7ee080e7          	jalr	2030(ra) # 8fa <printf>
}
 114:	bf95                	j	88 <test0+0x88>

0000000000000116 <main>:
{
 116:	1141                	addi	sp,sp,-16
 118:	e406                	sd	ra,8(sp)
 11a:	e022                	sd	s0,0(sp)
 11c:	0800                	addi	s0,sp,16
  test0();
 11e:	00000097          	auipc	ra,0x0
 122:	ee2080e7          	jalr	-286(ra) # 0 <test0>
  exit(0);
 126:	4501                	li	a0,0
 128:	00000097          	auipc	ra,0x0
 12c:	422080e7          	jalr	1058(ra) # 54a <exit>

0000000000000130 <test1>:

// Run system out of memory and count tot memory allocated
void test1()
{
 130:	715d                	addi	sp,sp,-80
 132:	e486                	sd	ra,72(sp)
 134:	e0a2                	sd	s0,64(sp)
 136:	fc26                	sd	s1,56(sp)
 138:	f84a                	sd	s2,48(sp)
 13a:	f44e                	sd	s3,40(sp)
 13c:	0880                	addi	s0,sp,80
  void *a;
  int pipes[NCHILD];
  int tot = 0;
  char buf[1];
  
  printf("start test1\n");  
 13e:	00001517          	auipc	a0,0x1
 142:	9c250513          	addi	a0,a0,-1598 # b00 <malloc+0x148>
 146:	00000097          	auipc	ra,0x0
 14a:	7b4080e7          	jalr	1972(ra) # 8fa <printf>
  for(int i = 0; i < NCHILD; i++){
 14e:	fc840913          	addi	s2,s0,-56
    int fds[2];
    if(pipe(fds) != 0){
 152:	fb840513          	addi	a0,s0,-72
 156:	00000097          	auipc	ra,0x0
 15a:	404080e7          	jalr	1028(ra) # 55a <pipe>
 15e:	84aa                	mv	s1,a0
 160:	e905                	bnez	a0,190 <test1+0x60>
      printf("pipe() failed\n");
      exit(-1);
    }
    int pid = fork();
 162:	00000097          	auipc	ra,0x0
 166:	3e0080e7          	jalr	992(ra) # 542 <fork>
    if(pid < 0){
 16a:	04054063          	bltz	a0,1aa <test1+0x7a>
      printf("fork failed");
      exit(-1);
    }
    if(pid == 0){
 16e:	c939                	beqz	a0,1c4 <test1+0x94>
          exit(-1);
        }
      }
      exit(0);
    } else {
      close(fds[1]);
 170:	fbc42503          	lw	a0,-68(s0)
 174:	00000097          	auipc	ra,0x0
 178:	3fe080e7          	jalr	1022(ra) # 572 <close>
      pipes[i] = fds[0];
 17c:	fb842783          	lw	a5,-72(s0)
 180:	00f92023          	sw	a5,0(s2)
  for(int i = 0; i < NCHILD; i++){
 184:	0911                	addi	s2,s2,4
 186:	fd040793          	addi	a5,s0,-48
 18a:	fd2794e3          	bne	a5,s2,152 <test1+0x22>
 18e:	a865                	j	246 <test1+0x116>
      printf("pipe() failed\n");
 190:	00001517          	auipc	a0,0x1
 194:	98050513          	addi	a0,a0,-1664 # b10 <malloc+0x158>
 198:	00000097          	auipc	ra,0x0
 19c:	762080e7          	jalr	1890(ra) # 8fa <printf>
      exit(-1);
 1a0:	557d                	li	a0,-1
 1a2:	00000097          	auipc	ra,0x0
 1a6:	3a8080e7          	jalr	936(ra) # 54a <exit>
      printf("fork failed");
 1aa:	00001517          	auipc	a0,0x1
 1ae:	90650513          	addi	a0,a0,-1786 # ab0 <malloc+0xf8>
 1b2:	00000097          	auipc	ra,0x0
 1b6:	748080e7          	jalr	1864(ra) # 8fa <printf>
      exit(-1);
 1ba:	557d                	li	a0,-1
 1bc:	00000097          	auipc	ra,0x0
 1c0:	38e080e7          	jalr	910(ra) # 54a <exit>
      close(fds[0]);
 1c4:	fb842503          	lw	a0,-72(s0)
 1c8:	00000097          	auipc	ra,0x0
 1cc:	3aa080e7          	jalr	938(ra) # 572 <close>
 1d0:	64e1                	lui	s1,0x18
 1d2:	6a048493          	addi	s1,s1,1696 # 186a0 <__global_pointer$+0x172d7>
        *(int *)(a+4) = 1;
 1d6:	4985                	li	s3,1
        if (write(fds[1], "x", 1) != 1) {
 1d8:	00001917          	auipc	s2,0x1
 1dc:	94890913          	addi	s2,s2,-1720 # b20 <malloc+0x168>
        a = sbrk(PGSIZE);
 1e0:	6505                	lui	a0,0x1
 1e2:	00000097          	auipc	ra,0x0
 1e6:	3f0080e7          	jalr	1008(ra) # 5d2 <sbrk>
        *(int *)(a+4) = 1;
 1ea:	01352223          	sw	s3,4(a0) # 1004 <__BSS_END__+0x41c>
        if (write(fds[1], "x", 1) != 1) {
 1ee:	4605                	li	a2,1
 1f0:	85ca                	mv	a1,s2
 1f2:	fbc42503          	lw	a0,-68(s0)
 1f6:	00000097          	auipc	ra,0x0
 1fa:	374080e7          	jalr	884(ra) # 56a <write>
 1fe:	4785                	li	a5,1
 200:	00f51963          	bne	a0,a5,212 <test1+0xe2>
      for(i = 0; i < N; i++) {
 204:	34fd                	addiw	s1,s1,-1
 206:	fce9                	bnez	s1,1e0 <test1+0xb0>
      exit(0);
 208:	4501                	li	a0,0
 20a:	00000097          	auipc	ra,0x0
 20e:	340080e7          	jalr	832(ra) # 54a <exit>
          printf("write failed");
 212:	00001517          	auipc	a0,0x1
 216:	91650513          	addi	a0,a0,-1770 # b28 <malloc+0x170>
 21a:	00000097          	auipc	ra,0x0
 21e:	6e0080e7          	jalr	1760(ra) # 8fa <printf>
          exit(-1);
 222:	557d                	li	a0,-1
 224:	00000097          	auipc	ra,0x0
 228:	326080e7          	jalr	806(ra) # 54a <exit>
  int stop = 0;
  while (!stop) {
    stop = 1;
    for(int i = 0; i < NCHILD; i++){
      if (read(pipes[i], buf, 1) == 1) {
        tot += 1;
 22c:	2485                	addiw	s1,s1,1
      if (read(pipes[i], buf, 1) == 1) {
 22e:	4605                	li	a2,1
 230:	fc040593          	addi	a1,s0,-64
 234:	fcc42503          	lw	a0,-52(s0)
 238:	00000097          	auipc	ra,0x0
 23c:	32a080e7          	jalr	810(ra) # 562 <read>
 240:	4785                	li	a5,1
 242:	02f50a63          	beq	a0,a5,276 <test1+0x146>
 246:	4605                	li	a2,1
 248:	fc040593          	addi	a1,s0,-64
 24c:	fc842503          	lw	a0,-56(s0)
 250:	00000097          	auipc	ra,0x0
 254:	312080e7          	jalr	786(ra) # 562 <read>
 258:	4785                	li	a5,1
 25a:	fcf509e3          	beq	a0,a5,22c <test1+0xfc>
 25e:	4605                	li	a2,1
 260:	fc040593          	addi	a1,s0,-64
 264:	fcc42503          	lw	a0,-52(s0)
 268:	00000097          	auipc	ra,0x0
 26c:	2fa080e7          	jalr	762(ra) # 562 <read>
 270:	4785                	li	a5,1
 272:	02f51163          	bne	a0,a5,294 <test1+0x164>
        tot += 1;
 276:	2485                	addiw	s1,s1,1
  while (!stop) {
 278:	b7f9                	j	246 <test1+0x116>
    }
  }
  int n = (PHYSTOP-KERNBASE)/PGSIZE;
  printf("total allocated number of pages: %d (out of %d)\n", tot, n);
  if(n - tot > 1000) {
    printf("test1 FAILED: cannot allocate enough memory");
 27a:	00001517          	auipc	a0,0x1
 27e:	8be50513          	addi	a0,a0,-1858 # b38 <malloc+0x180>
 282:	00000097          	auipc	ra,0x0
 286:	678080e7          	jalr	1656(ra) # 8fa <printf>
    exit(-1);
 28a:	557d                	li	a0,-1
 28c:	00000097          	auipc	ra,0x0
 290:	2be080e7          	jalr	702(ra) # 54a <exit>
  printf("total allocated number of pages: %d (out of %d)\n", tot, n);
 294:	6621                	lui	a2,0x8
 296:	85a6                	mv	a1,s1
 298:	00001517          	auipc	a0,0x1
 29c:	8e050513          	addi	a0,a0,-1824 # b78 <malloc+0x1c0>
 2a0:	00000097          	auipc	ra,0x0
 2a4:	65a080e7          	jalr	1626(ra) # 8fa <printf>
  if(n - tot > 1000) {
 2a8:	67a1                	lui	a5,0x8
 2aa:	409784bb          	subw	s1,a5,s1
 2ae:	3e800793          	li	a5,1000
 2b2:	fc97c4e3          	blt	a5,s1,27a <test1+0x14a>
  }
  printf("test1 OK\n");  
 2b6:	00001517          	auipc	a0,0x1
 2ba:	8b250513          	addi	a0,a0,-1870 # b68 <malloc+0x1b0>
 2be:	00000097          	auipc	ra,0x0
 2c2:	63c080e7          	jalr	1596(ra) # 8fa <printf>
}
 2c6:	60a6                	ld	ra,72(sp)
 2c8:	6406                	ld	s0,64(sp)
 2ca:	74e2                	ld	s1,56(sp)
 2cc:	7942                	ld	s2,48(sp)
 2ce:	79a2                	ld	s3,40(sp)
 2d0:	6161                	addi	sp,sp,80
 2d2:	8082                	ret

00000000000002d4 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 2d4:	1141                	addi	sp,sp,-16
 2d6:	e422                	sd	s0,8(sp)
 2d8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2da:	87aa                	mv	a5,a0
 2dc:	0585                	addi	a1,a1,1
 2de:	0785                	addi	a5,a5,1
 2e0:	fff5c703          	lbu	a4,-1(a1)
 2e4:	fee78fa3          	sb	a4,-1(a5) # 7fff <__global_pointer$+0x6c36>
 2e8:	fb75                	bnez	a4,2dc <strcpy+0x8>
    ;
  return os;
}
 2ea:	6422                	ld	s0,8(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret

00000000000002f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e422                	sd	s0,8(sp)
 2f4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2f6:	00054783          	lbu	a5,0(a0)
 2fa:	cb91                	beqz	a5,30e <strcmp+0x1e>
 2fc:	0005c703          	lbu	a4,0(a1)
 300:	00f71763          	bne	a4,a5,30e <strcmp+0x1e>
    p++, q++;
 304:	0505                	addi	a0,a0,1
 306:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 308:	00054783          	lbu	a5,0(a0)
 30c:	fbe5                	bnez	a5,2fc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 30e:	0005c503          	lbu	a0,0(a1)
}
 312:	40a7853b          	subw	a0,a5,a0
 316:	6422                	ld	s0,8(sp)
 318:	0141                	addi	sp,sp,16
 31a:	8082                	ret

000000000000031c <strlen>:

uint
strlen(const char *s)
{
 31c:	1141                	addi	sp,sp,-16
 31e:	e422                	sd	s0,8(sp)
 320:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 322:	00054783          	lbu	a5,0(a0)
 326:	cf91                	beqz	a5,342 <strlen+0x26>
 328:	0505                	addi	a0,a0,1
 32a:	87aa                	mv	a5,a0
 32c:	4685                	li	a3,1
 32e:	9e89                	subw	a3,a3,a0
 330:	00f6853b          	addw	a0,a3,a5
 334:	0785                	addi	a5,a5,1
 336:	fff7c703          	lbu	a4,-1(a5)
 33a:	fb7d                	bnez	a4,330 <strlen+0x14>
    ;
  return n;
}
 33c:	6422                	ld	s0,8(sp)
 33e:	0141                	addi	sp,sp,16
 340:	8082                	ret
  for(n = 0; s[n]; n++)
 342:	4501                	li	a0,0
 344:	bfe5                	j	33c <strlen+0x20>

0000000000000346 <memset>:

void*
memset(void *dst, int c, uint n)
{
 346:	1141                	addi	sp,sp,-16
 348:	e422                	sd	s0,8(sp)
 34a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 34c:	ce09                	beqz	a2,366 <memset+0x20>
 34e:	87aa                	mv	a5,a0
 350:	fff6071b          	addiw	a4,a2,-1
 354:	1702                	slli	a4,a4,0x20
 356:	9301                	srli	a4,a4,0x20
 358:	0705                	addi	a4,a4,1
 35a:	972a                	add	a4,a4,a0
    cdst[i] = c;
 35c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 360:	0785                	addi	a5,a5,1
 362:	fee79de3          	bne	a5,a4,35c <memset+0x16>
  }
  return dst;
}
 366:	6422                	ld	s0,8(sp)
 368:	0141                	addi	sp,sp,16
 36a:	8082                	ret

000000000000036c <strchr>:

char*
strchr(const char *s, char c)
{
 36c:	1141                	addi	sp,sp,-16
 36e:	e422                	sd	s0,8(sp)
 370:	0800                	addi	s0,sp,16
  for(; *s; s++)
 372:	00054783          	lbu	a5,0(a0)
 376:	cb99                	beqz	a5,38c <strchr+0x20>
    if(*s == c)
 378:	00f58763          	beq	a1,a5,386 <strchr+0x1a>
  for(; *s; s++)
 37c:	0505                	addi	a0,a0,1
 37e:	00054783          	lbu	a5,0(a0)
 382:	fbfd                	bnez	a5,378 <strchr+0xc>
      return (char*)s;
  return 0;
 384:	4501                	li	a0,0
}
 386:	6422                	ld	s0,8(sp)
 388:	0141                	addi	sp,sp,16
 38a:	8082                	ret
  return 0;
 38c:	4501                	li	a0,0
 38e:	bfe5                	j	386 <strchr+0x1a>

0000000000000390 <gets>:

char*
gets(char *buf, int max)
{
 390:	711d                	addi	sp,sp,-96
 392:	ec86                	sd	ra,88(sp)
 394:	e8a2                	sd	s0,80(sp)
 396:	e4a6                	sd	s1,72(sp)
 398:	e0ca                	sd	s2,64(sp)
 39a:	fc4e                	sd	s3,56(sp)
 39c:	f852                	sd	s4,48(sp)
 39e:	f456                	sd	s5,40(sp)
 3a0:	f05a                	sd	s6,32(sp)
 3a2:	ec5e                	sd	s7,24(sp)
 3a4:	1080                	addi	s0,sp,96
 3a6:	8baa                	mv	s7,a0
 3a8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3aa:	892a                	mv	s2,a0
 3ac:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3ae:	4aa9                	li	s5,10
 3b0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3b2:	89a6                	mv	s3,s1
 3b4:	2485                	addiw	s1,s1,1
 3b6:	0344d863          	bge	s1,s4,3e6 <gets+0x56>
    cc = read(0, &c, 1);
 3ba:	4605                	li	a2,1
 3bc:	faf40593          	addi	a1,s0,-81
 3c0:	4501                	li	a0,0
 3c2:	00000097          	auipc	ra,0x0
 3c6:	1a0080e7          	jalr	416(ra) # 562 <read>
    if(cc < 1)
 3ca:	00a05e63          	blez	a0,3e6 <gets+0x56>
    buf[i++] = c;
 3ce:	faf44783          	lbu	a5,-81(s0)
 3d2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3d6:	01578763          	beq	a5,s5,3e4 <gets+0x54>
 3da:	0905                	addi	s2,s2,1
 3dc:	fd679be3          	bne	a5,s6,3b2 <gets+0x22>
  for(i=0; i+1 < max; ){
 3e0:	89a6                	mv	s3,s1
 3e2:	a011                	j	3e6 <gets+0x56>
 3e4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3e6:	99de                	add	s3,s3,s7
 3e8:	00098023          	sb	zero,0(s3)
  return buf;
}
 3ec:	855e                	mv	a0,s7
 3ee:	60e6                	ld	ra,88(sp)
 3f0:	6446                	ld	s0,80(sp)
 3f2:	64a6                	ld	s1,72(sp)
 3f4:	6906                	ld	s2,64(sp)
 3f6:	79e2                	ld	s3,56(sp)
 3f8:	7a42                	ld	s4,48(sp)
 3fa:	7aa2                	ld	s5,40(sp)
 3fc:	7b02                	ld	s6,32(sp)
 3fe:	6be2                	ld	s7,24(sp)
 400:	6125                	addi	sp,sp,96
 402:	8082                	ret

0000000000000404 <stat>:

int
stat(const char *n, struct stat *st)
{
 404:	1101                	addi	sp,sp,-32
 406:	ec06                	sd	ra,24(sp)
 408:	e822                	sd	s0,16(sp)
 40a:	e426                	sd	s1,8(sp)
 40c:	e04a                	sd	s2,0(sp)
 40e:	1000                	addi	s0,sp,32
 410:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 412:	4581                	li	a1,0
 414:	00000097          	auipc	ra,0x0
 418:	176080e7          	jalr	374(ra) # 58a <open>
  if(fd < 0)
 41c:	02054563          	bltz	a0,446 <stat+0x42>
 420:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 422:	85ca                	mv	a1,s2
 424:	00000097          	auipc	ra,0x0
 428:	17e080e7          	jalr	382(ra) # 5a2 <fstat>
 42c:	892a                	mv	s2,a0
  close(fd);
 42e:	8526                	mv	a0,s1
 430:	00000097          	auipc	ra,0x0
 434:	142080e7          	jalr	322(ra) # 572 <close>
  return r;
}
 438:	854a                	mv	a0,s2
 43a:	60e2                	ld	ra,24(sp)
 43c:	6442                	ld	s0,16(sp)
 43e:	64a2                	ld	s1,8(sp)
 440:	6902                	ld	s2,0(sp)
 442:	6105                	addi	sp,sp,32
 444:	8082                	ret
    return -1;
 446:	597d                	li	s2,-1
 448:	bfc5                	j	438 <stat+0x34>

000000000000044a <atoi>:

int
atoi(const char *s)
{
 44a:	1141                	addi	sp,sp,-16
 44c:	e422                	sd	s0,8(sp)
 44e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 450:	00054603          	lbu	a2,0(a0)
 454:	fd06079b          	addiw	a5,a2,-48
 458:	0ff7f793          	andi	a5,a5,255
 45c:	4725                	li	a4,9
 45e:	02f76963          	bltu	a4,a5,490 <atoi+0x46>
 462:	86aa                	mv	a3,a0
  n = 0;
 464:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 466:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 468:	0685                	addi	a3,a3,1
 46a:	0025179b          	slliw	a5,a0,0x2
 46e:	9fa9                	addw	a5,a5,a0
 470:	0017979b          	slliw	a5,a5,0x1
 474:	9fb1                	addw	a5,a5,a2
 476:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 47a:	0006c603          	lbu	a2,0(a3)
 47e:	fd06071b          	addiw	a4,a2,-48
 482:	0ff77713          	andi	a4,a4,255
 486:	fee5f1e3          	bgeu	a1,a4,468 <atoi+0x1e>
  return n;
}
 48a:	6422                	ld	s0,8(sp)
 48c:	0141                	addi	sp,sp,16
 48e:	8082                	ret
  n = 0;
 490:	4501                	li	a0,0
 492:	bfe5                	j	48a <atoi+0x40>

0000000000000494 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 494:	1141                	addi	sp,sp,-16
 496:	e422                	sd	s0,8(sp)
 498:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 49a:	02b57663          	bgeu	a0,a1,4c6 <memmove+0x32>
    while(n-- > 0)
 49e:	02c05163          	blez	a2,4c0 <memmove+0x2c>
 4a2:	fff6079b          	addiw	a5,a2,-1
 4a6:	1782                	slli	a5,a5,0x20
 4a8:	9381                	srli	a5,a5,0x20
 4aa:	0785                	addi	a5,a5,1
 4ac:	97aa                	add	a5,a5,a0
  dst = vdst;
 4ae:	872a                	mv	a4,a0
      *dst++ = *src++;
 4b0:	0585                	addi	a1,a1,1
 4b2:	0705                	addi	a4,a4,1
 4b4:	fff5c683          	lbu	a3,-1(a1)
 4b8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4bc:	fee79ae3          	bne	a5,a4,4b0 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4c0:	6422                	ld	s0,8(sp)
 4c2:	0141                	addi	sp,sp,16
 4c4:	8082                	ret
    dst += n;
 4c6:	00c50733          	add	a4,a0,a2
    src += n;
 4ca:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4cc:	fec05ae3          	blez	a2,4c0 <memmove+0x2c>
 4d0:	fff6079b          	addiw	a5,a2,-1
 4d4:	1782                	slli	a5,a5,0x20
 4d6:	9381                	srli	a5,a5,0x20
 4d8:	fff7c793          	not	a5,a5
 4dc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4de:	15fd                	addi	a1,a1,-1
 4e0:	177d                	addi	a4,a4,-1
 4e2:	0005c683          	lbu	a3,0(a1)
 4e6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4ea:	fee79ae3          	bne	a5,a4,4de <memmove+0x4a>
 4ee:	bfc9                	j	4c0 <memmove+0x2c>

00000000000004f0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4f0:	1141                	addi	sp,sp,-16
 4f2:	e422                	sd	s0,8(sp)
 4f4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4f6:	ca05                	beqz	a2,526 <memcmp+0x36>
 4f8:	fff6069b          	addiw	a3,a2,-1
 4fc:	1682                	slli	a3,a3,0x20
 4fe:	9281                	srli	a3,a3,0x20
 500:	0685                	addi	a3,a3,1
 502:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 504:	00054783          	lbu	a5,0(a0)
 508:	0005c703          	lbu	a4,0(a1)
 50c:	00e79863          	bne	a5,a4,51c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 510:	0505                	addi	a0,a0,1
    p2++;
 512:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 514:	fed518e3          	bne	a0,a3,504 <memcmp+0x14>
  }
  return 0;
 518:	4501                	li	a0,0
 51a:	a019                	j	520 <memcmp+0x30>
      return *p1 - *p2;
 51c:	40e7853b          	subw	a0,a5,a4
}
 520:	6422                	ld	s0,8(sp)
 522:	0141                	addi	sp,sp,16
 524:	8082                	ret
  return 0;
 526:	4501                	li	a0,0
 528:	bfe5                	j	520 <memcmp+0x30>

000000000000052a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 52a:	1141                	addi	sp,sp,-16
 52c:	e406                	sd	ra,8(sp)
 52e:	e022                	sd	s0,0(sp)
 530:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 532:	00000097          	auipc	ra,0x0
 536:	f62080e7          	jalr	-158(ra) # 494 <memmove>
}
 53a:	60a2                	ld	ra,8(sp)
 53c:	6402                	ld	s0,0(sp)
 53e:	0141                	addi	sp,sp,16
 540:	8082                	ret

0000000000000542 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 542:	4885                	li	a7,1
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <exit>:
.global exit
exit:
 li a7, SYS_exit
 54a:	4889                	li	a7,2
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <wait>:
.global wait
wait:
 li a7, SYS_wait
 552:	488d                	li	a7,3
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 55a:	4891                	li	a7,4
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <read>:
.global read
read:
 li a7, SYS_read
 562:	4895                	li	a7,5
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <write>:
.global write
write:
 li a7, SYS_write
 56a:	48c1                	li	a7,16
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <close>:
.global close
close:
 li a7, SYS_close
 572:	48d5                	li	a7,21
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <kill>:
.global kill
kill:
 li a7, SYS_kill
 57a:	4899                	li	a7,6
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <exec>:
.global exec
exec:
 li a7, SYS_exec
 582:	489d                	li	a7,7
 ecall
 584:	00000073          	ecall
 ret
 588:	8082                	ret

000000000000058a <open>:
.global open
open:
 li a7, SYS_open
 58a:	48bd                	li	a7,15
 ecall
 58c:	00000073          	ecall
 ret
 590:	8082                	ret

0000000000000592 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 592:	48c5                	li	a7,17
 ecall
 594:	00000073          	ecall
 ret
 598:	8082                	ret

000000000000059a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 59a:	48c9                	li	a7,18
 ecall
 59c:	00000073          	ecall
 ret
 5a0:	8082                	ret

00000000000005a2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5a2:	48a1                	li	a7,8
 ecall
 5a4:	00000073          	ecall
 ret
 5a8:	8082                	ret

00000000000005aa <link>:
.global link
link:
 li a7, SYS_link
 5aa:	48cd                	li	a7,19
 ecall
 5ac:	00000073          	ecall
 ret
 5b0:	8082                	ret

00000000000005b2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5b2:	48d1                	li	a7,20
 ecall
 5b4:	00000073          	ecall
 ret
 5b8:	8082                	ret

00000000000005ba <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5ba:	48a5                	li	a7,9
 ecall
 5bc:	00000073          	ecall
 ret
 5c0:	8082                	ret

00000000000005c2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5c2:	48a9                	li	a7,10
 ecall
 5c4:	00000073          	ecall
 ret
 5c8:	8082                	ret

00000000000005ca <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5ca:	48ad                	li	a7,11
 ecall
 5cc:	00000073          	ecall
 ret
 5d0:	8082                	ret

00000000000005d2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5d2:	48b1                	li	a7,12
 ecall
 5d4:	00000073          	ecall
 ret
 5d8:	8082                	ret

00000000000005da <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5da:	48b5                	li	a7,13
 ecall
 5dc:	00000073          	ecall
 ret
 5e0:	8082                	ret

00000000000005e2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5e2:	48b9                	li	a7,14
 ecall
 5e4:	00000073          	ecall
 ret
 5e8:	8082                	ret

00000000000005ea <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 5ea:	48d9                	li	a7,22
 ecall
 5ec:	00000073          	ecall
 ret
 5f0:	8082                	ret

00000000000005f2 <nfree>:
.global nfree
nfree:
 li a7, SYS_nfree
 5f2:	48dd                	li	a7,23
 ecall
 5f4:	00000073          	ecall
 ret
 5f8:	8082                	ret

00000000000005fa <test_rcu>:
.global test_rcu
test_rcu:
 li a7, SYS_test_rcu
 5fa:	48e1                	li	a7,24
 ecall
 5fc:	00000073          	ecall
 ret
 600:	8082                	ret

0000000000000602 <rcu_read_only>:
.global rcu_read_only
rcu_read_only:
 li a7, SYS_rcu_read_only
 602:	48e5                	li	a7,25
 ecall
 604:	00000073          	ecall
 ret
 608:	8082                	ret

000000000000060a <rcu_read_heavy>:
.global rcu_read_heavy
rcu_read_heavy:
 li a7, SYS_rcu_read_heavy
 60a:	48e9                	li	a7,26
 ecall
 60c:	00000073          	ecall
 ret
 610:	8082                	ret

0000000000000612 <rcu_read_write_mix>:
.global rcu_read_write_mix
rcu_read_write_mix:
 li a7, SYS_rcu_read_write_mix
 612:	48ed                	li	a7,27
 ecall
 614:	00000073          	ecall
 ret
 618:	8082                	ret

000000000000061a <rcu_read_stress>:
.global rcu_read_stress
rcu_read_stress:
 li a7, SYS_rcu_read_stress
 61a:	48f1                	li	a7,28
 ecall
 61c:	00000073          	ecall
 ret
 620:	8082                	ret

0000000000000622 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 622:	1101                	addi	sp,sp,-32
 624:	ec06                	sd	ra,24(sp)
 626:	e822                	sd	s0,16(sp)
 628:	1000                	addi	s0,sp,32
 62a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 62e:	4605                	li	a2,1
 630:	fef40593          	addi	a1,s0,-17
 634:	00000097          	auipc	ra,0x0
 638:	f36080e7          	jalr	-202(ra) # 56a <write>
}
 63c:	60e2                	ld	ra,24(sp)
 63e:	6442                	ld	s0,16(sp)
 640:	6105                	addi	sp,sp,32
 642:	8082                	ret

0000000000000644 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 644:	7139                	addi	sp,sp,-64
 646:	fc06                	sd	ra,56(sp)
 648:	f822                	sd	s0,48(sp)
 64a:	f426                	sd	s1,40(sp)
 64c:	f04a                	sd	s2,32(sp)
 64e:	ec4e                	sd	s3,24(sp)
 650:	0080                	addi	s0,sp,64
 652:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 654:	c299                	beqz	a3,65a <printint+0x16>
 656:	0805c863          	bltz	a1,6e6 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 65a:	2581                	sext.w	a1,a1
  neg = 0;
 65c:	4881                	li	a7,0
 65e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 662:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 664:	2601                	sext.w	a2,a2
 666:	00000517          	auipc	a0,0x0
 66a:	55250513          	addi	a0,a0,1362 # bb8 <digits>
 66e:	883a                	mv	a6,a4
 670:	2705                	addiw	a4,a4,1
 672:	02c5f7bb          	remuw	a5,a1,a2
 676:	1782                	slli	a5,a5,0x20
 678:	9381                	srli	a5,a5,0x20
 67a:	97aa                	add	a5,a5,a0
 67c:	0007c783          	lbu	a5,0(a5)
 680:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 684:	0005879b          	sext.w	a5,a1
 688:	02c5d5bb          	divuw	a1,a1,a2
 68c:	0685                	addi	a3,a3,1
 68e:	fec7f0e3          	bgeu	a5,a2,66e <printint+0x2a>
  if(neg)
 692:	00088b63          	beqz	a7,6a8 <printint+0x64>
    buf[i++] = '-';
 696:	fd040793          	addi	a5,s0,-48
 69a:	973e                	add	a4,a4,a5
 69c:	02d00793          	li	a5,45
 6a0:	fef70823          	sb	a5,-16(a4)
 6a4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 6a8:	02e05863          	blez	a4,6d8 <printint+0x94>
 6ac:	fc040793          	addi	a5,s0,-64
 6b0:	00e78933          	add	s2,a5,a4
 6b4:	fff78993          	addi	s3,a5,-1
 6b8:	99ba                	add	s3,s3,a4
 6ba:	377d                	addiw	a4,a4,-1
 6bc:	1702                	slli	a4,a4,0x20
 6be:	9301                	srli	a4,a4,0x20
 6c0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6c4:	fff94583          	lbu	a1,-1(s2)
 6c8:	8526                	mv	a0,s1
 6ca:	00000097          	auipc	ra,0x0
 6ce:	f58080e7          	jalr	-168(ra) # 622 <putc>
  while(--i >= 0)
 6d2:	197d                	addi	s2,s2,-1
 6d4:	ff3918e3          	bne	s2,s3,6c4 <printint+0x80>
}
 6d8:	70e2                	ld	ra,56(sp)
 6da:	7442                	ld	s0,48(sp)
 6dc:	74a2                	ld	s1,40(sp)
 6de:	7902                	ld	s2,32(sp)
 6e0:	69e2                	ld	s3,24(sp)
 6e2:	6121                	addi	sp,sp,64
 6e4:	8082                	ret
    x = -xx;
 6e6:	40b005bb          	negw	a1,a1
    neg = 1;
 6ea:	4885                	li	a7,1
    x = -xx;
 6ec:	bf8d                	j	65e <printint+0x1a>

00000000000006ee <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6ee:	7119                	addi	sp,sp,-128
 6f0:	fc86                	sd	ra,120(sp)
 6f2:	f8a2                	sd	s0,112(sp)
 6f4:	f4a6                	sd	s1,104(sp)
 6f6:	f0ca                	sd	s2,96(sp)
 6f8:	ecce                	sd	s3,88(sp)
 6fa:	e8d2                	sd	s4,80(sp)
 6fc:	e4d6                	sd	s5,72(sp)
 6fe:	e0da                	sd	s6,64(sp)
 700:	fc5e                	sd	s7,56(sp)
 702:	f862                	sd	s8,48(sp)
 704:	f466                	sd	s9,40(sp)
 706:	f06a                	sd	s10,32(sp)
 708:	ec6e                	sd	s11,24(sp)
 70a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 70c:	0005c903          	lbu	s2,0(a1)
 710:	18090f63          	beqz	s2,8ae <vprintf+0x1c0>
 714:	8aaa                	mv	s5,a0
 716:	8b32                	mv	s6,a2
 718:	00158493          	addi	s1,a1,1
  state = 0;
 71c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 71e:	02500a13          	li	s4,37
      if(c == 'd'){
 722:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 726:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 72a:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 72e:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 732:	00000b97          	auipc	s7,0x0
 736:	486b8b93          	addi	s7,s7,1158 # bb8 <digits>
 73a:	a839                	j	758 <vprintf+0x6a>
        putc(fd, c);
 73c:	85ca                	mv	a1,s2
 73e:	8556                	mv	a0,s5
 740:	00000097          	auipc	ra,0x0
 744:	ee2080e7          	jalr	-286(ra) # 622 <putc>
 748:	a019                	j	74e <vprintf+0x60>
    } else if(state == '%'){
 74a:	01498f63          	beq	s3,s4,768 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 74e:	0485                	addi	s1,s1,1
 750:	fff4c903          	lbu	s2,-1(s1)
 754:	14090d63          	beqz	s2,8ae <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 758:	0009079b          	sext.w	a5,s2
    if(state == 0){
 75c:	fe0997e3          	bnez	s3,74a <vprintf+0x5c>
      if(c == '%'){
 760:	fd479ee3          	bne	a5,s4,73c <vprintf+0x4e>
        state = '%';
 764:	89be                	mv	s3,a5
 766:	b7e5                	j	74e <vprintf+0x60>
      if(c == 'd'){
 768:	05878063          	beq	a5,s8,7a8 <vprintf+0xba>
      } else if(c == 'l') {
 76c:	05978c63          	beq	a5,s9,7c4 <vprintf+0xd6>
      } else if(c == 'x') {
 770:	07a78863          	beq	a5,s10,7e0 <vprintf+0xf2>
      } else if(c == 'p') {
 774:	09b78463          	beq	a5,s11,7fc <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 778:	07300713          	li	a4,115
 77c:	0ce78663          	beq	a5,a4,848 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 780:	06300713          	li	a4,99
 784:	0ee78e63          	beq	a5,a4,880 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 788:	11478863          	beq	a5,s4,898 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 78c:	85d2                	mv	a1,s4
 78e:	8556                	mv	a0,s5
 790:	00000097          	auipc	ra,0x0
 794:	e92080e7          	jalr	-366(ra) # 622 <putc>
        putc(fd, c);
 798:	85ca                	mv	a1,s2
 79a:	8556                	mv	a0,s5
 79c:	00000097          	auipc	ra,0x0
 7a0:	e86080e7          	jalr	-378(ra) # 622 <putc>
      }
      state = 0;
 7a4:	4981                	li	s3,0
 7a6:	b765                	j	74e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 7a8:	008b0913          	addi	s2,s6,8
 7ac:	4685                	li	a3,1
 7ae:	4629                	li	a2,10
 7b0:	000b2583          	lw	a1,0(s6)
 7b4:	8556                	mv	a0,s5
 7b6:	00000097          	auipc	ra,0x0
 7ba:	e8e080e7          	jalr	-370(ra) # 644 <printint>
 7be:	8b4a                	mv	s6,s2
      state = 0;
 7c0:	4981                	li	s3,0
 7c2:	b771                	j	74e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7c4:	008b0913          	addi	s2,s6,8
 7c8:	4681                	li	a3,0
 7ca:	4629                	li	a2,10
 7cc:	000b2583          	lw	a1,0(s6)
 7d0:	8556                	mv	a0,s5
 7d2:	00000097          	auipc	ra,0x0
 7d6:	e72080e7          	jalr	-398(ra) # 644 <printint>
 7da:	8b4a                	mv	s6,s2
      state = 0;
 7dc:	4981                	li	s3,0
 7de:	bf85                	j	74e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 7e0:	008b0913          	addi	s2,s6,8
 7e4:	4681                	li	a3,0
 7e6:	4641                	li	a2,16
 7e8:	000b2583          	lw	a1,0(s6)
 7ec:	8556                	mv	a0,s5
 7ee:	00000097          	auipc	ra,0x0
 7f2:	e56080e7          	jalr	-426(ra) # 644 <printint>
 7f6:	8b4a                	mv	s6,s2
      state = 0;
 7f8:	4981                	li	s3,0
 7fa:	bf91                	j	74e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 7fc:	008b0793          	addi	a5,s6,8
 800:	f8f43423          	sd	a5,-120(s0)
 804:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 808:	03000593          	li	a1,48
 80c:	8556                	mv	a0,s5
 80e:	00000097          	auipc	ra,0x0
 812:	e14080e7          	jalr	-492(ra) # 622 <putc>
  putc(fd, 'x');
 816:	85ea                	mv	a1,s10
 818:	8556                	mv	a0,s5
 81a:	00000097          	auipc	ra,0x0
 81e:	e08080e7          	jalr	-504(ra) # 622 <putc>
 822:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 824:	03c9d793          	srli	a5,s3,0x3c
 828:	97de                	add	a5,a5,s7
 82a:	0007c583          	lbu	a1,0(a5)
 82e:	8556                	mv	a0,s5
 830:	00000097          	auipc	ra,0x0
 834:	df2080e7          	jalr	-526(ra) # 622 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 838:	0992                	slli	s3,s3,0x4
 83a:	397d                	addiw	s2,s2,-1
 83c:	fe0914e3          	bnez	s2,824 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 840:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 844:	4981                	li	s3,0
 846:	b721                	j	74e <vprintf+0x60>
        s = va_arg(ap, char*);
 848:	008b0993          	addi	s3,s6,8
 84c:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 850:	02090163          	beqz	s2,872 <vprintf+0x184>
        while(*s != 0){
 854:	00094583          	lbu	a1,0(s2)
 858:	c9a1                	beqz	a1,8a8 <vprintf+0x1ba>
          putc(fd, *s);
 85a:	8556                	mv	a0,s5
 85c:	00000097          	auipc	ra,0x0
 860:	dc6080e7          	jalr	-570(ra) # 622 <putc>
          s++;
 864:	0905                	addi	s2,s2,1
        while(*s != 0){
 866:	00094583          	lbu	a1,0(s2)
 86a:	f9e5                	bnez	a1,85a <vprintf+0x16c>
        s = va_arg(ap, char*);
 86c:	8b4e                	mv	s6,s3
      state = 0;
 86e:	4981                	li	s3,0
 870:	bdf9                	j	74e <vprintf+0x60>
          s = "(null)";
 872:	00000917          	auipc	s2,0x0
 876:	33e90913          	addi	s2,s2,830 # bb0 <malloc+0x1f8>
        while(*s != 0){
 87a:	02800593          	li	a1,40
 87e:	bff1                	j	85a <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 880:	008b0913          	addi	s2,s6,8
 884:	000b4583          	lbu	a1,0(s6)
 888:	8556                	mv	a0,s5
 88a:	00000097          	auipc	ra,0x0
 88e:	d98080e7          	jalr	-616(ra) # 622 <putc>
 892:	8b4a                	mv	s6,s2
      state = 0;
 894:	4981                	li	s3,0
 896:	bd65                	j	74e <vprintf+0x60>
        putc(fd, c);
 898:	85d2                	mv	a1,s4
 89a:	8556                	mv	a0,s5
 89c:	00000097          	auipc	ra,0x0
 8a0:	d86080e7          	jalr	-634(ra) # 622 <putc>
      state = 0;
 8a4:	4981                	li	s3,0
 8a6:	b565                	j	74e <vprintf+0x60>
        s = va_arg(ap, char*);
 8a8:	8b4e                	mv	s6,s3
      state = 0;
 8aa:	4981                	li	s3,0
 8ac:	b54d                	j	74e <vprintf+0x60>
    }
  }
}
 8ae:	70e6                	ld	ra,120(sp)
 8b0:	7446                	ld	s0,112(sp)
 8b2:	74a6                	ld	s1,104(sp)
 8b4:	7906                	ld	s2,96(sp)
 8b6:	69e6                	ld	s3,88(sp)
 8b8:	6a46                	ld	s4,80(sp)
 8ba:	6aa6                	ld	s5,72(sp)
 8bc:	6b06                	ld	s6,64(sp)
 8be:	7be2                	ld	s7,56(sp)
 8c0:	7c42                	ld	s8,48(sp)
 8c2:	7ca2                	ld	s9,40(sp)
 8c4:	7d02                	ld	s10,32(sp)
 8c6:	6de2                	ld	s11,24(sp)
 8c8:	6109                	addi	sp,sp,128
 8ca:	8082                	ret

00000000000008cc <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8cc:	715d                	addi	sp,sp,-80
 8ce:	ec06                	sd	ra,24(sp)
 8d0:	e822                	sd	s0,16(sp)
 8d2:	1000                	addi	s0,sp,32
 8d4:	e010                	sd	a2,0(s0)
 8d6:	e414                	sd	a3,8(s0)
 8d8:	e818                	sd	a4,16(s0)
 8da:	ec1c                	sd	a5,24(s0)
 8dc:	03043023          	sd	a6,32(s0)
 8e0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8e4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8e8:	8622                	mv	a2,s0
 8ea:	00000097          	auipc	ra,0x0
 8ee:	e04080e7          	jalr	-508(ra) # 6ee <vprintf>
}
 8f2:	60e2                	ld	ra,24(sp)
 8f4:	6442                	ld	s0,16(sp)
 8f6:	6161                	addi	sp,sp,80
 8f8:	8082                	ret

00000000000008fa <printf>:

void
printf(const char *fmt, ...)
{
 8fa:	711d                	addi	sp,sp,-96
 8fc:	ec06                	sd	ra,24(sp)
 8fe:	e822                	sd	s0,16(sp)
 900:	1000                	addi	s0,sp,32
 902:	e40c                	sd	a1,8(s0)
 904:	e810                	sd	a2,16(s0)
 906:	ec14                	sd	a3,24(s0)
 908:	f018                	sd	a4,32(s0)
 90a:	f41c                	sd	a5,40(s0)
 90c:	03043823          	sd	a6,48(s0)
 910:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 914:	00840613          	addi	a2,s0,8
 918:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 91c:	85aa                	mv	a1,a0
 91e:	4505                	li	a0,1
 920:	00000097          	auipc	ra,0x0
 924:	dce080e7          	jalr	-562(ra) # 6ee <vprintf>
}
 928:	60e2                	ld	ra,24(sp)
 92a:	6442                	ld	s0,16(sp)
 92c:	6125                	addi	sp,sp,96
 92e:	8082                	ret

0000000000000930 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 930:	1141                	addi	sp,sp,-16
 932:	e422                	sd	s0,8(sp)
 934:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 936:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 93a:	00000797          	auipc	a5,0x0
 93e:	2967b783          	ld	a5,662(a5) # bd0 <freep>
 942:	a805                	j	972 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 944:	4618                	lw	a4,8(a2)
 946:	9db9                	addw	a1,a1,a4
 948:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 94c:	6398                	ld	a4,0(a5)
 94e:	6318                	ld	a4,0(a4)
 950:	fee53823          	sd	a4,-16(a0)
 954:	a091                	j	998 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 956:	ff852703          	lw	a4,-8(a0)
 95a:	9e39                	addw	a2,a2,a4
 95c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 95e:	ff053703          	ld	a4,-16(a0)
 962:	e398                	sd	a4,0(a5)
 964:	a099                	j	9aa <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 966:	6398                	ld	a4,0(a5)
 968:	00e7e463          	bltu	a5,a4,970 <free+0x40>
 96c:	00e6ea63          	bltu	a3,a4,980 <free+0x50>
{
 970:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 972:	fed7fae3          	bgeu	a5,a3,966 <free+0x36>
 976:	6398                	ld	a4,0(a5)
 978:	00e6e463          	bltu	a3,a4,980 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 97c:	fee7eae3          	bltu	a5,a4,970 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 980:	ff852583          	lw	a1,-8(a0)
 984:	6390                	ld	a2,0(a5)
 986:	02059713          	slli	a4,a1,0x20
 98a:	9301                	srli	a4,a4,0x20
 98c:	0712                	slli	a4,a4,0x4
 98e:	9736                	add	a4,a4,a3
 990:	fae60ae3          	beq	a2,a4,944 <free+0x14>
    bp->s.ptr = p->s.ptr;
 994:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 998:	4790                	lw	a2,8(a5)
 99a:	02061713          	slli	a4,a2,0x20
 99e:	9301                	srli	a4,a4,0x20
 9a0:	0712                	slli	a4,a4,0x4
 9a2:	973e                	add	a4,a4,a5
 9a4:	fae689e3          	beq	a3,a4,956 <free+0x26>
  } else
    p->s.ptr = bp;
 9a8:	e394                	sd	a3,0(a5)
  freep = p;
 9aa:	00000717          	auipc	a4,0x0
 9ae:	22f73323          	sd	a5,550(a4) # bd0 <freep>
}
 9b2:	6422                	ld	s0,8(sp)
 9b4:	0141                	addi	sp,sp,16
 9b6:	8082                	ret

00000000000009b8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9b8:	7139                	addi	sp,sp,-64
 9ba:	fc06                	sd	ra,56(sp)
 9bc:	f822                	sd	s0,48(sp)
 9be:	f426                	sd	s1,40(sp)
 9c0:	f04a                	sd	s2,32(sp)
 9c2:	ec4e                	sd	s3,24(sp)
 9c4:	e852                	sd	s4,16(sp)
 9c6:	e456                	sd	s5,8(sp)
 9c8:	e05a                	sd	s6,0(sp)
 9ca:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9cc:	02051493          	slli	s1,a0,0x20
 9d0:	9081                	srli	s1,s1,0x20
 9d2:	04bd                	addi	s1,s1,15
 9d4:	8091                	srli	s1,s1,0x4
 9d6:	0014899b          	addiw	s3,s1,1
 9da:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9dc:	00000517          	auipc	a0,0x0
 9e0:	1f453503          	ld	a0,500(a0) # bd0 <freep>
 9e4:	c515                	beqz	a0,a10 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9e8:	4798                	lw	a4,8(a5)
 9ea:	02977f63          	bgeu	a4,s1,a28 <malloc+0x70>
 9ee:	8a4e                	mv	s4,s3
 9f0:	0009871b          	sext.w	a4,s3
 9f4:	6685                	lui	a3,0x1
 9f6:	00d77363          	bgeu	a4,a3,9fc <malloc+0x44>
 9fa:	6a05                	lui	s4,0x1
 9fc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a00:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a04:	00000917          	auipc	s2,0x0
 a08:	1cc90913          	addi	s2,s2,460 # bd0 <freep>
  if(p == (char*)-1)
 a0c:	5afd                	li	s5,-1
 a0e:	a88d                	j	a80 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 a10:	00000797          	auipc	a5,0x0
 a14:	1c878793          	addi	a5,a5,456 # bd8 <base>
 a18:	00000717          	auipc	a4,0x0
 a1c:	1af73c23          	sd	a5,440(a4) # bd0 <freep>
 a20:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a22:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a26:	b7e1                	j	9ee <malloc+0x36>
      if(p->s.size == nunits)
 a28:	02e48b63          	beq	s1,a4,a5e <malloc+0xa6>
        p->s.size -= nunits;
 a2c:	4137073b          	subw	a4,a4,s3
 a30:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a32:	1702                	slli	a4,a4,0x20
 a34:	9301                	srli	a4,a4,0x20
 a36:	0712                	slli	a4,a4,0x4
 a38:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a3a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a3e:	00000717          	auipc	a4,0x0
 a42:	18a73923          	sd	a0,402(a4) # bd0 <freep>
      return (void*)(p + 1);
 a46:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a4a:	70e2                	ld	ra,56(sp)
 a4c:	7442                	ld	s0,48(sp)
 a4e:	74a2                	ld	s1,40(sp)
 a50:	7902                	ld	s2,32(sp)
 a52:	69e2                	ld	s3,24(sp)
 a54:	6a42                	ld	s4,16(sp)
 a56:	6aa2                	ld	s5,8(sp)
 a58:	6b02                	ld	s6,0(sp)
 a5a:	6121                	addi	sp,sp,64
 a5c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a5e:	6398                	ld	a4,0(a5)
 a60:	e118                	sd	a4,0(a0)
 a62:	bff1                	j	a3e <malloc+0x86>
  hp->s.size = nu;
 a64:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a68:	0541                	addi	a0,a0,16
 a6a:	00000097          	auipc	ra,0x0
 a6e:	ec6080e7          	jalr	-314(ra) # 930 <free>
  return freep;
 a72:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a76:	d971                	beqz	a0,a4a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a78:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a7a:	4798                	lw	a4,8(a5)
 a7c:	fa9776e3          	bgeu	a4,s1,a28 <malloc+0x70>
    if(p == freep)
 a80:	00093703          	ld	a4,0(s2)
 a84:	853e                	mv	a0,a5
 a86:	fef719e3          	bne	a4,a5,a78 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 a8a:	8552                	mv	a0,s4
 a8c:	00000097          	auipc	ra,0x0
 a90:	b46080e7          	jalr	-1210(ra) # 5d2 <sbrk>
  if(p == (char*)-1)
 a94:	fd5518e3          	bne	a0,s5,a64 <malloc+0xac>
        return 0;
 a98:	4501                	li	a0,0
 a9a:	bf45                	j	a4a <malloc+0x92>
