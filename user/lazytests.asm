
user/_lazytests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <sparse_memory>:

#define REGION_SZ (1024 * 1024 * 1024)

void
sparse_memory(char *s)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  char *i, *prev_end, *new_end;
  
  prev_end = sbrk(REGION_SZ);
   8:	40000537          	lui	a0,0x40000
   c:	00000097          	auipc	ra,0x0
  10:	604080e7          	jalr	1540(ra) # 610 <sbrk>
  if (prev_end == (char*)0xffffffffffffffffL) {
  14:	57fd                	li	a5,-1
  16:	02f50b63          	beq	a0,a5,4c <sparse_memory+0x4c>
    printf("sbrk() failed\n");
    exit(1);
  }
  new_end = prev_end + REGION_SZ;

  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
  1a:	6605                	lui	a2,0x1
  1c:	962a                	add	a2,a2,a0
  1e:	40001737          	lui	a4,0x40001
  22:	972a                	add	a4,a4,a0
  24:	87b2                	mv	a5,a2
  26:	000406b7          	lui	a3,0x40
    *(char **)i = i;
  2a:	e39c                	sd	a5,0(a5)
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
  2c:	97b6                	add	a5,a5,a3
  2e:	fee79ee3          	bne	a5,a4,2a <sparse_memory+0x2a>

  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
  32:	000406b7          	lui	a3,0x40
    if (*(char **)i != i) {
  36:	621c                	ld	a5,0(a2)
  38:	02c79763          	bne	a5,a2,66 <sparse_memory+0x66>
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
  3c:	9636                	add	a2,a2,a3
  3e:	fee61ce3          	bne	a2,a4,36 <sparse_memory+0x36>
      printf("failed to read value from memory\n");
      exit(1);
    }
  }

  exit(0);
  42:	4501                	li	a0,0
  44:	00000097          	auipc	ra,0x0
  48:	544080e7          	jalr	1348(ra) # 588 <exit>
    printf("sbrk() failed\n");
  4c:	00001517          	auipc	a0,0x1
  50:	ac450513          	addi	a0,a0,-1340 # b10 <malloc+0x11a>
  54:	00001097          	auipc	ra,0x1
  58:	8e4080e7          	jalr	-1820(ra) # 938 <printf>
    exit(1);
  5c:	4505                	li	a0,1
  5e:	00000097          	auipc	ra,0x0
  62:	52a080e7          	jalr	1322(ra) # 588 <exit>
      printf("failed to read value from memory\n");
  66:	00001517          	auipc	a0,0x1
  6a:	aba50513          	addi	a0,a0,-1350 # b20 <malloc+0x12a>
  6e:	00001097          	auipc	ra,0x1
  72:	8ca080e7          	jalr	-1846(ra) # 938 <printf>
      exit(1);
  76:	4505                	li	a0,1
  78:	00000097          	auipc	ra,0x0
  7c:	510080e7          	jalr	1296(ra) # 588 <exit>

0000000000000080 <sparse_memory_unmap>:
}

void
sparse_memory_unmap(char *s)
{
  80:	7139                	addi	sp,sp,-64
  82:	fc06                	sd	ra,56(sp)
  84:	f822                	sd	s0,48(sp)
  86:	f426                	sd	s1,40(sp)
  88:	f04a                	sd	s2,32(sp)
  8a:	ec4e                	sd	s3,24(sp)
  8c:	0080                	addi	s0,sp,64
  int pid;
  char *i, *prev_end, *new_end;

  prev_end = sbrk(REGION_SZ);
  8e:	40000537          	lui	a0,0x40000
  92:	00000097          	auipc	ra,0x0
  96:	57e080e7          	jalr	1406(ra) # 610 <sbrk>
  if (prev_end == (char*)0xffffffffffffffffL) {
  9a:	57fd                	li	a5,-1
  9c:	04f50863          	beq	a0,a5,ec <sparse_memory_unmap+0x6c>
    printf("sbrk() failed\n");
    exit(1);
  }
  new_end = prev_end + REGION_SZ;

  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
  a0:	6905                	lui	s2,0x1
  a2:	992a                	add	s2,s2,a0
  a4:	400014b7          	lui	s1,0x40001
  a8:	94aa                	add	s1,s1,a0
  aa:	87ca                	mv	a5,s2
  ac:	01000737          	lui	a4,0x1000
    *(char **)i = i;
  b0:	e39c                	sd	a5,0(a5)
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
  b2:	97ba                	add	a5,a5,a4
  b4:	fef49ee3          	bne	s1,a5,b0 <sparse_memory_unmap+0x30>

  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE) {
  b8:	010009b7          	lui	s3,0x1000
    pid = fork();
  bc:	00000097          	auipc	ra,0x0
  c0:	4c4080e7          	jalr	1220(ra) # 580 <fork>
    if (pid < 0) {
  c4:	04054163          	bltz	a0,106 <sparse_memory_unmap+0x86>
      printf("error forking\n");
      exit(1);
    } else if (pid == 0) {
  c8:	cd21                	beqz	a0,120 <sparse_memory_unmap+0xa0>
      sbrk(-1L * REGION_SZ);
      *(char **)i = i;
      exit(0);
    } else {
      int status;
      wait(&status);
  ca:	fcc40513          	addi	a0,s0,-52
  ce:	00000097          	auipc	ra,0x0
  d2:	4c2080e7          	jalr	1218(ra) # 590 <wait>
      if (status == 0) {
  d6:	fcc42783          	lw	a5,-52(s0)
  da:	c3a5                	beqz	a5,13a <sparse_memory_unmap+0xba>
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE) {
  dc:	994e                	add	s2,s2,s3
  de:	fd249fe3          	bne	s1,s2,bc <sparse_memory_unmap+0x3c>
        exit(1);
      }
    }
  }

  exit(0);
  e2:	4501                	li	a0,0
  e4:	00000097          	auipc	ra,0x0
  e8:	4a4080e7          	jalr	1188(ra) # 588 <exit>
    printf("sbrk() failed\n");
  ec:	00001517          	auipc	a0,0x1
  f0:	a2450513          	addi	a0,a0,-1500 # b10 <malloc+0x11a>
  f4:	00001097          	auipc	ra,0x1
  f8:	844080e7          	jalr	-1980(ra) # 938 <printf>
    exit(1);
  fc:	4505                	li	a0,1
  fe:	00000097          	auipc	ra,0x0
 102:	48a080e7          	jalr	1162(ra) # 588 <exit>
      printf("error forking\n");
 106:	00001517          	auipc	a0,0x1
 10a:	a4250513          	addi	a0,a0,-1470 # b48 <malloc+0x152>
 10e:	00001097          	auipc	ra,0x1
 112:	82a080e7          	jalr	-2006(ra) # 938 <printf>
      exit(1);
 116:	4505                	li	a0,1
 118:	00000097          	auipc	ra,0x0
 11c:	470080e7          	jalr	1136(ra) # 588 <exit>
      sbrk(-1L * REGION_SZ);
 120:	c0000537          	lui	a0,0xc0000
 124:	00000097          	auipc	ra,0x0
 128:	4ec080e7          	jalr	1260(ra) # 610 <sbrk>
      *(char **)i = i;
 12c:	01293023          	sd	s2,0(s2) # 1000 <__BSS_END__+0x378>
      exit(0);
 130:	4501                	li	a0,0
 132:	00000097          	auipc	ra,0x0
 136:	456080e7          	jalr	1110(ra) # 588 <exit>
        printf("memory not unmapped\n");
 13a:	00001517          	auipc	a0,0x1
 13e:	a1e50513          	addi	a0,a0,-1506 # b58 <malloc+0x162>
 142:	00000097          	auipc	ra,0x0
 146:	7f6080e7          	jalr	2038(ra) # 938 <printf>
        exit(1);
 14a:	4505                	li	a0,1
 14c:	00000097          	auipc	ra,0x0
 150:	43c080e7          	jalr	1084(ra) # 588 <exit>

0000000000000154 <oom>:
}

void
oom(char *s)
{
 154:	7179                	addi	sp,sp,-48
 156:	f406                	sd	ra,40(sp)
 158:	f022                	sd	s0,32(sp)
 15a:	ec26                	sd	s1,24(sp)
 15c:	1800                	addi	s0,sp,48
  void *m1, *m2;
  int pid;

  if((pid = fork()) == 0){
 15e:	00000097          	auipc	ra,0x0
 162:	422080e7          	jalr	1058(ra) # 580 <fork>
    m1 = 0;
 166:	4481                	li	s1,0
  if((pid = fork()) == 0){
 168:	c10d                	beqz	a0,18a <oom+0x36>
      m1 = m2;
    }
    exit(0);
  } else {
    int xstatus;
    wait(&xstatus);
 16a:	fdc40513          	addi	a0,s0,-36
 16e:	00000097          	auipc	ra,0x0
 172:	422080e7          	jalr	1058(ra) # 590 <wait>
    exit(xstatus == 0);
 176:	fdc42503          	lw	a0,-36(s0)
 17a:	00153513          	seqz	a0,a0
 17e:	00000097          	auipc	ra,0x0
 182:	40a080e7          	jalr	1034(ra) # 588 <exit>
      *(char**)m2 = m1;
 186:	e104                	sd	s1,0(a0)
      m1 = m2;
 188:	84aa                	mv	s1,a0
    while((m2 = malloc(4096*4096)) != 0){
 18a:	01000537          	lui	a0,0x1000
 18e:	00001097          	auipc	ra,0x1
 192:	868080e7          	jalr	-1944(ra) # 9f6 <malloc>
 196:	f965                	bnez	a0,186 <oom+0x32>
    exit(0);
 198:	00000097          	auipc	ra,0x0
 19c:	3f0080e7          	jalr	1008(ra) # 588 <exit>

00000000000001a0 <run>:
}

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
 1a0:	7179                	addi	sp,sp,-48
 1a2:	f406                	sd	ra,40(sp)
 1a4:	f022                	sd	s0,32(sp)
 1a6:	ec26                	sd	s1,24(sp)
 1a8:	e84a                	sd	s2,16(sp)
 1aa:	1800                	addi	s0,sp,48
 1ac:	892a                	mv	s2,a0
 1ae:	84ae                	mv	s1,a1
  int pid;
  int xstatus;
  
  printf("running test %s\n", s);
 1b0:	00001517          	auipc	a0,0x1
 1b4:	9c050513          	addi	a0,a0,-1600 # b70 <malloc+0x17a>
 1b8:	00000097          	auipc	ra,0x0
 1bc:	780080e7          	jalr	1920(ra) # 938 <printf>
  if((pid = fork()) < 0) {
 1c0:	00000097          	auipc	ra,0x0
 1c4:	3c0080e7          	jalr	960(ra) # 580 <fork>
 1c8:	02054f63          	bltz	a0,206 <run+0x66>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
 1cc:	c931                	beqz	a0,220 <run+0x80>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
 1ce:	fdc40513          	addi	a0,s0,-36
 1d2:	00000097          	auipc	ra,0x0
 1d6:	3be080e7          	jalr	958(ra) # 590 <wait>
    if(xstatus != 0) 
 1da:	fdc42783          	lw	a5,-36(s0)
 1de:	cba1                	beqz	a5,22e <run+0x8e>
      printf("test %s: FAILED\n", s);
 1e0:	85a6                	mv	a1,s1
 1e2:	00001517          	auipc	a0,0x1
 1e6:	9be50513          	addi	a0,a0,-1602 # ba0 <malloc+0x1aa>
 1ea:	00000097          	auipc	ra,0x0
 1ee:	74e080e7          	jalr	1870(ra) # 938 <printf>
    else
      printf("test %s: OK\n", s);
    return xstatus == 0;
 1f2:	fdc42503          	lw	a0,-36(s0)
  }
}
 1f6:	00153513          	seqz	a0,a0
 1fa:	70a2                	ld	ra,40(sp)
 1fc:	7402                	ld	s0,32(sp)
 1fe:	64e2                	ld	s1,24(sp)
 200:	6942                	ld	s2,16(sp)
 202:	6145                	addi	sp,sp,48
 204:	8082                	ret
    printf("runtest: fork error\n");
 206:	00001517          	auipc	a0,0x1
 20a:	98250513          	addi	a0,a0,-1662 # b88 <malloc+0x192>
 20e:	00000097          	auipc	ra,0x0
 212:	72a080e7          	jalr	1834(ra) # 938 <printf>
    exit(1);
 216:	4505                	li	a0,1
 218:	00000097          	auipc	ra,0x0
 21c:	370080e7          	jalr	880(ra) # 588 <exit>
    f(s);
 220:	8526                	mv	a0,s1
 222:	9902                	jalr	s2
    exit(0);
 224:	4501                	li	a0,0
 226:	00000097          	auipc	ra,0x0
 22a:	362080e7          	jalr	866(ra) # 588 <exit>
      printf("test %s: OK\n", s);
 22e:	85a6                	mv	a1,s1
 230:	00001517          	auipc	a0,0x1
 234:	98850513          	addi	a0,a0,-1656 # bb8 <malloc+0x1c2>
 238:	00000097          	auipc	ra,0x0
 23c:	700080e7          	jalr	1792(ra) # 938 <printf>
 240:	bf4d                	j	1f2 <run+0x52>

0000000000000242 <main>:

int
main(int argc, char *argv[])
{
 242:	7159                	addi	sp,sp,-112
 244:	f486                	sd	ra,104(sp)
 246:	f0a2                	sd	s0,96(sp)
 248:	eca6                	sd	s1,88(sp)
 24a:	e8ca                	sd	s2,80(sp)
 24c:	e4ce                	sd	s3,72(sp)
 24e:	e0d2                	sd	s4,64(sp)
 250:	1880                	addi	s0,sp,112
  char *n = 0;
  if(argc > 1) {
 252:	4785                	li	a5,1
  char *n = 0;
 254:	4901                	li	s2,0
  if(argc > 1) {
 256:	00a7d463          	bge	a5,a0,25e <main+0x1c>
    n = argv[1];
 25a:	0085b903          	ld	s2,8(a1)
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
 25e:	00001797          	auipc	a5,0x1
 262:	9b278793          	addi	a5,a5,-1614 # c10 <malloc+0x21a>
 266:	0007b883          	ld	a7,0(a5)
 26a:	0087b803          	ld	a6,8(a5)
 26e:	6b88                	ld	a0,16(a5)
 270:	6f8c                	ld	a1,24(a5)
 272:	7390                	ld	a2,32(a5)
 274:	7794                	ld	a3,40(a5)
 276:	7b98                	ld	a4,48(a5)
 278:	7f9c                	ld	a5,56(a5)
 27a:	f9143823          	sd	a7,-112(s0)
 27e:	f9043c23          	sd	a6,-104(s0)
 282:	faa43023          	sd	a0,-96(s0)
 286:	fab43423          	sd	a1,-88(s0)
 28a:	fac43823          	sd	a2,-80(s0)
 28e:	fad43c23          	sd	a3,-72(s0)
 292:	fce43023          	sd	a4,-64(s0)
 296:	fcf43423          	sd	a5,-56(s0)
    { sparse_memory_unmap, "lazy unmap"},
    { oom, "out of memory"},
    { 0, 0},
  };
    
  printf("lazytests starting\n");
 29a:	00001517          	auipc	a0,0x1
 29e:	92e50513          	addi	a0,a0,-1746 # bc8 <malloc+0x1d2>
 2a2:	00000097          	auipc	ra,0x0
 2a6:	696080e7          	jalr	1686(ra) # 938 <printf>

  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
 2aa:	f9843503          	ld	a0,-104(s0)
 2ae:	c529                	beqz	a0,2f8 <main+0xb6>
 2b0:	f9040493          	addi	s1,s0,-112
  int fail = 0;
 2b4:	4981                	li	s3,0
    if((n == 0) || strcmp(t->s, n) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
 2b6:	4a05                	li	s4,1
 2b8:	a021                	j	2c0 <main+0x7e>
  for (struct test *t = tests; t->s != 0; t++) {
 2ba:	04c1                	addi	s1,s1,16
 2bc:	6488                	ld	a0,8(s1)
 2be:	c115                	beqz	a0,2e2 <main+0xa0>
    if((n == 0) || strcmp(t->s, n) == 0) {
 2c0:	00090863          	beqz	s2,2d0 <main+0x8e>
 2c4:	85ca                	mv	a1,s2
 2c6:	00000097          	auipc	ra,0x0
 2ca:	068080e7          	jalr	104(ra) # 32e <strcmp>
 2ce:	f575                	bnez	a0,2ba <main+0x78>
      if(!run(t->f, t->s))
 2d0:	648c                	ld	a1,8(s1)
 2d2:	6088                	ld	a0,0(s1)
 2d4:	00000097          	auipc	ra,0x0
 2d8:	ecc080e7          	jalr	-308(ra) # 1a0 <run>
 2dc:	fd79                	bnez	a0,2ba <main+0x78>
        fail = 1;
 2de:	89d2                	mv	s3,s4
 2e0:	bfe9                	j	2ba <main+0x78>
    }
  }
  if(!fail)
 2e2:	00098b63          	beqz	s3,2f8 <main+0xb6>
    printf("ALL TESTS PASSED\n");
  else
    printf("SOME TESTS FAILED\n");
 2e6:	00001517          	auipc	a0,0x1
 2ea:	91250513          	addi	a0,a0,-1774 # bf8 <malloc+0x202>
 2ee:	00000097          	auipc	ra,0x0
 2f2:	64a080e7          	jalr	1610(ra) # 938 <printf>
 2f6:	a809                	j	308 <main+0xc6>
    printf("ALL TESTS PASSED\n");
 2f8:	00001517          	auipc	a0,0x1
 2fc:	8e850513          	addi	a0,a0,-1816 # be0 <malloc+0x1ea>
 300:	00000097          	auipc	ra,0x0
 304:	638080e7          	jalr	1592(ra) # 938 <printf>
  exit(1);   // not reached.
 308:	4505                	li	a0,1
 30a:	00000097          	auipc	ra,0x0
 30e:	27e080e7          	jalr	638(ra) # 588 <exit>

0000000000000312 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 312:	1141                	addi	sp,sp,-16
 314:	e422                	sd	s0,8(sp)
 316:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 318:	87aa                	mv	a5,a0
 31a:	0585                	addi	a1,a1,1
 31c:	0785                	addi	a5,a5,1
 31e:	fff5c703          	lbu	a4,-1(a1)
 322:	fee78fa3          	sb	a4,-1(a5)
 326:	fb75                	bnez	a4,31a <strcpy+0x8>
    ;
  return os;
}
 328:	6422                	ld	s0,8(sp)
 32a:	0141                	addi	sp,sp,16
 32c:	8082                	ret

000000000000032e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 32e:	1141                	addi	sp,sp,-16
 330:	e422                	sd	s0,8(sp)
 332:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 334:	00054783          	lbu	a5,0(a0)
 338:	cb91                	beqz	a5,34c <strcmp+0x1e>
 33a:	0005c703          	lbu	a4,0(a1)
 33e:	00f71763          	bne	a4,a5,34c <strcmp+0x1e>
    p++, q++;
 342:	0505                	addi	a0,a0,1
 344:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 346:	00054783          	lbu	a5,0(a0)
 34a:	fbe5                	bnez	a5,33a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 34c:	0005c503          	lbu	a0,0(a1)
}
 350:	40a7853b          	subw	a0,a5,a0
 354:	6422                	ld	s0,8(sp)
 356:	0141                	addi	sp,sp,16
 358:	8082                	ret

000000000000035a <strlen>:

uint
strlen(const char *s)
{
 35a:	1141                	addi	sp,sp,-16
 35c:	e422                	sd	s0,8(sp)
 35e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 360:	00054783          	lbu	a5,0(a0)
 364:	cf91                	beqz	a5,380 <strlen+0x26>
 366:	0505                	addi	a0,a0,1
 368:	87aa                	mv	a5,a0
 36a:	4685                	li	a3,1
 36c:	9e89                	subw	a3,a3,a0
 36e:	00f6853b          	addw	a0,a3,a5
 372:	0785                	addi	a5,a5,1
 374:	fff7c703          	lbu	a4,-1(a5)
 378:	fb7d                	bnez	a4,36e <strlen+0x14>
    ;
  return n;
}
 37a:	6422                	ld	s0,8(sp)
 37c:	0141                	addi	sp,sp,16
 37e:	8082                	ret
  for(n = 0; s[n]; n++)
 380:	4501                	li	a0,0
 382:	bfe5                	j	37a <strlen+0x20>

0000000000000384 <memset>:

void*
memset(void *dst, int c, uint n)
{
 384:	1141                	addi	sp,sp,-16
 386:	e422                	sd	s0,8(sp)
 388:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 38a:	ce09                	beqz	a2,3a4 <memset+0x20>
 38c:	87aa                	mv	a5,a0
 38e:	fff6071b          	addiw	a4,a2,-1
 392:	1702                	slli	a4,a4,0x20
 394:	9301                	srli	a4,a4,0x20
 396:	0705                	addi	a4,a4,1
 398:	972a                	add	a4,a4,a0
    cdst[i] = c;
 39a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 39e:	0785                	addi	a5,a5,1
 3a0:	fee79de3          	bne	a5,a4,39a <memset+0x16>
  }
  return dst;
}
 3a4:	6422                	ld	s0,8(sp)
 3a6:	0141                	addi	sp,sp,16
 3a8:	8082                	ret

00000000000003aa <strchr>:

char*
strchr(const char *s, char c)
{
 3aa:	1141                	addi	sp,sp,-16
 3ac:	e422                	sd	s0,8(sp)
 3ae:	0800                	addi	s0,sp,16
  for(; *s; s++)
 3b0:	00054783          	lbu	a5,0(a0)
 3b4:	cb99                	beqz	a5,3ca <strchr+0x20>
    if(*s == c)
 3b6:	00f58763          	beq	a1,a5,3c4 <strchr+0x1a>
  for(; *s; s++)
 3ba:	0505                	addi	a0,a0,1
 3bc:	00054783          	lbu	a5,0(a0)
 3c0:	fbfd                	bnez	a5,3b6 <strchr+0xc>
      return (char*)s;
  return 0;
 3c2:	4501                	li	a0,0
}
 3c4:	6422                	ld	s0,8(sp)
 3c6:	0141                	addi	sp,sp,16
 3c8:	8082                	ret
  return 0;
 3ca:	4501                	li	a0,0
 3cc:	bfe5                	j	3c4 <strchr+0x1a>

00000000000003ce <gets>:

char*
gets(char *buf, int max)
{
 3ce:	711d                	addi	sp,sp,-96
 3d0:	ec86                	sd	ra,88(sp)
 3d2:	e8a2                	sd	s0,80(sp)
 3d4:	e4a6                	sd	s1,72(sp)
 3d6:	e0ca                	sd	s2,64(sp)
 3d8:	fc4e                	sd	s3,56(sp)
 3da:	f852                	sd	s4,48(sp)
 3dc:	f456                	sd	s5,40(sp)
 3de:	f05a                	sd	s6,32(sp)
 3e0:	ec5e                	sd	s7,24(sp)
 3e2:	1080                	addi	s0,sp,96
 3e4:	8baa                	mv	s7,a0
 3e6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3e8:	892a                	mv	s2,a0
 3ea:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3ec:	4aa9                	li	s5,10
 3ee:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3f0:	89a6                	mv	s3,s1
 3f2:	2485                	addiw	s1,s1,1
 3f4:	0344d863          	bge	s1,s4,424 <gets+0x56>
    cc = read(0, &c, 1);
 3f8:	4605                	li	a2,1
 3fa:	faf40593          	addi	a1,s0,-81
 3fe:	4501                	li	a0,0
 400:	00000097          	auipc	ra,0x0
 404:	1a0080e7          	jalr	416(ra) # 5a0 <read>
    if(cc < 1)
 408:	00a05e63          	blez	a0,424 <gets+0x56>
    buf[i++] = c;
 40c:	faf44783          	lbu	a5,-81(s0)
 410:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 414:	01578763          	beq	a5,s5,422 <gets+0x54>
 418:	0905                	addi	s2,s2,1
 41a:	fd679be3          	bne	a5,s6,3f0 <gets+0x22>
  for(i=0; i+1 < max; ){
 41e:	89a6                	mv	s3,s1
 420:	a011                	j	424 <gets+0x56>
 422:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 424:	99de                	add	s3,s3,s7
 426:	00098023          	sb	zero,0(s3) # 1000000 <__global_pointer$+0xffeb97>
  return buf;
}
 42a:	855e                	mv	a0,s7
 42c:	60e6                	ld	ra,88(sp)
 42e:	6446                	ld	s0,80(sp)
 430:	64a6                	ld	s1,72(sp)
 432:	6906                	ld	s2,64(sp)
 434:	79e2                	ld	s3,56(sp)
 436:	7a42                	ld	s4,48(sp)
 438:	7aa2                	ld	s5,40(sp)
 43a:	7b02                	ld	s6,32(sp)
 43c:	6be2                	ld	s7,24(sp)
 43e:	6125                	addi	sp,sp,96
 440:	8082                	ret

0000000000000442 <stat>:

int
stat(const char *n, struct stat *st)
{
 442:	1101                	addi	sp,sp,-32
 444:	ec06                	sd	ra,24(sp)
 446:	e822                	sd	s0,16(sp)
 448:	e426                	sd	s1,8(sp)
 44a:	e04a                	sd	s2,0(sp)
 44c:	1000                	addi	s0,sp,32
 44e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 450:	4581                	li	a1,0
 452:	00000097          	auipc	ra,0x0
 456:	176080e7          	jalr	374(ra) # 5c8 <open>
  if(fd < 0)
 45a:	02054563          	bltz	a0,484 <stat+0x42>
 45e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 460:	85ca                	mv	a1,s2
 462:	00000097          	auipc	ra,0x0
 466:	17e080e7          	jalr	382(ra) # 5e0 <fstat>
 46a:	892a                	mv	s2,a0
  close(fd);
 46c:	8526                	mv	a0,s1
 46e:	00000097          	auipc	ra,0x0
 472:	142080e7          	jalr	322(ra) # 5b0 <close>
  return r;
}
 476:	854a                	mv	a0,s2
 478:	60e2                	ld	ra,24(sp)
 47a:	6442                	ld	s0,16(sp)
 47c:	64a2                	ld	s1,8(sp)
 47e:	6902                	ld	s2,0(sp)
 480:	6105                	addi	sp,sp,32
 482:	8082                	ret
    return -1;
 484:	597d                	li	s2,-1
 486:	bfc5                	j	476 <stat+0x34>

0000000000000488 <atoi>:

int
atoi(const char *s)
{
 488:	1141                	addi	sp,sp,-16
 48a:	e422                	sd	s0,8(sp)
 48c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 48e:	00054603          	lbu	a2,0(a0)
 492:	fd06079b          	addiw	a5,a2,-48
 496:	0ff7f793          	andi	a5,a5,255
 49a:	4725                	li	a4,9
 49c:	02f76963          	bltu	a4,a5,4ce <atoi+0x46>
 4a0:	86aa                	mv	a3,a0
  n = 0;
 4a2:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 4a4:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 4a6:	0685                	addi	a3,a3,1
 4a8:	0025179b          	slliw	a5,a0,0x2
 4ac:	9fa9                	addw	a5,a5,a0
 4ae:	0017979b          	slliw	a5,a5,0x1
 4b2:	9fb1                	addw	a5,a5,a2
 4b4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4b8:	0006c603          	lbu	a2,0(a3) # 40000 <__global_pointer$+0x3eb97>
 4bc:	fd06071b          	addiw	a4,a2,-48
 4c0:	0ff77713          	andi	a4,a4,255
 4c4:	fee5f1e3          	bgeu	a1,a4,4a6 <atoi+0x1e>
  return n;
}
 4c8:	6422                	ld	s0,8(sp)
 4ca:	0141                	addi	sp,sp,16
 4cc:	8082                	ret
  n = 0;
 4ce:	4501                	li	a0,0
 4d0:	bfe5                	j	4c8 <atoi+0x40>

00000000000004d2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4d2:	1141                	addi	sp,sp,-16
 4d4:	e422                	sd	s0,8(sp)
 4d6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4d8:	02b57663          	bgeu	a0,a1,504 <memmove+0x32>
    while(n-- > 0)
 4dc:	02c05163          	blez	a2,4fe <memmove+0x2c>
 4e0:	fff6079b          	addiw	a5,a2,-1
 4e4:	1782                	slli	a5,a5,0x20
 4e6:	9381                	srli	a5,a5,0x20
 4e8:	0785                	addi	a5,a5,1
 4ea:	97aa                	add	a5,a5,a0
  dst = vdst;
 4ec:	872a                	mv	a4,a0
      *dst++ = *src++;
 4ee:	0585                	addi	a1,a1,1
 4f0:	0705                	addi	a4,a4,1
 4f2:	fff5c683          	lbu	a3,-1(a1)
 4f6:	fed70fa3          	sb	a3,-1(a4) # ffffff <__global_pointer$+0xffeb96>
    while(n-- > 0)
 4fa:	fee79ae3          	bne	a5,a4,4ee <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4fe:	6422                	ld	s0,8(sp)
 500:	0141                	addi	sp,sp,16
 502:	8082                	ret
    dst += n;
 504:	00c50733          	add	a4,a0,a2
    src += n;
 508:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 50a:	fec05ae3          	blez	a2,4fe <memmove+0x2c>
 50e:	fff6079b          	addiw	a5,a2,-1
 512:	1782                	slli	a5,a5,0x20
 514:	9381                	srli	a5,a5,0x20
 516:	fff7c793          	not	a5,a5
 51a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 51c:	15fd                	addi	a1,a1,-1
 51e:	177d                	addi	a4,a4,-1
 520:	0005c683          	lbu	a3,0(a1)
 524:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 528:	fee79ae3          	bne	a5,a4,51c <memmove+0x4a>
 52c:	bfc9                	j	4fe <memmove+0x2c>

000000000000052e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 52e:	1141                	addi	sp,sp,-16
 530:	e422                	sd	s0,8(sp)
 532:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 534:	ca05                	beqz	a2,564 <memcmp+0x36>
 536:	fff6069b          	addiw	a3,a2,-1
 53a:	1682                	slli	a3,a3,0x20
 53c:	9281                	srli	a3,a3,0x20
 53e:	0685                	addi	a3,a3,1
 540:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 542:	00054783          	lbu	a5,0(a0)
 546:	0005c703          	lbu	a4,0(a1)
 54a:	00e79863          	bne	a5,a4,55a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 54e:	0505                	addi	a0,a0,1
    p2++;
 550:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 552:	fed518e3          	bne	a0,a3,542 <memcmp+0x14>
  }
  return 0;
 556:	4501                	li	a0,0
 558:	a019                	j	55e <memcmp+0x30>
      return *p1 - *p2;
 55a:	40e7853b          	subw	a0,a5,a4
}
 55e:	6422                	ld	s0,8(sp)
 560:	0141                	addi	sp,sp,16
 562:	8082                	ret
  return 0;
 564:	4501                	li	a0,0
 566:	bfe5                	j	55e <memcmp+0x30>

0000000000000568 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 568:	1141                	addi	sp,sp,-16
 56a:	e406                	sd	ra,8(sp)
 56c:	e022                	sd	s0,0(sp)
 56e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 570:	00000097          	auipc	ra,0x0
 574:	f62080e7          	jalr	-158(ra) # 4d2 <memmove>
}
 578:	60a2                	ld	ra,8(sp)
 57a:	6402                	ld	s0,0(sp)
 57c:	0141                	addi	sp,sp,16
 57e:	8082                	ret

0000000000000580 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 580:	4885                	li	a7,1
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <exit>:
.global exit
exit:
 li a7, SYS_exit
 588:	4889                	li	a7,2
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <wait>:
.global wait
wait:
 li a7, SYS_wait
 590:	488d                	li	a7,3
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 598:	4891                	li	a7,4
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <read>:
.global read
read:
 li a7, SYS_read
 5a0:	4895                	li	a7,5
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <write>:
.global write
write:
 li a7, SYS_write
 5a8:	48c1                	li	a7,16
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <close>:
.global close
close:
 li a7, SYS_close
 5b0:	48d5                	li	a7,21
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 5b8:	4899                	li	a7,6
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5c0:	489d                	li	a7,7
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <open>:
.global open
open:
 li a7, SYS_open
 5c8:	48bd                	li	a7,15
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5d0:	48c5                	li	a7,17
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5d8:	48c9                	li	a7,18
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5e0:	48a1                	li	a7,8
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <link>:
.global link
link:
 li a7, SYS_link
 5e8:	48cd                	li	a7,19
 ecall
 5ea:	00000073          	ecall
 ret
 5ee:	8082                	ret

00000000000005f0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5f0:	48d1                	li	a7,20
 ecall
 5f2:	00000073          	ecall
 ret
 5f6:	8082                	ret

00000000000005f8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5f8:	48a5                	li	a7,9
 ecall
 5fa:	00000073          	ecall
 ret
 5fe:	8082                	ret

0000000000000600 <dup>:
.global dup
dup:
 li a7, SYS_dup
 600:	48a9                	li	a7,10
 ecall
 602:	00000073          	ecall
 ret
 606:	8082                	ret

0000000000000608 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 608:	48ad                	li	a7,11
 ecall
 60a:	00000073          	ecall
 ret
 60e:	8082                	ret

0000000000000610 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 610:	48b1                	li	a7,12
 ecall
 612:	00000073          	ecall
 ret
 616:	8082                	ret

0000000000000618 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 618:	48b5                	li	a7,13
 ecall
 61a:	00000073          	ecall
 ret
 61e:	8082                	ret

0000000000000620 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 620:	48b9                	li	a7,14
 ecall
 622:	00000073          	ecall
 ret
 626:	8082                	ret

0000000000000628 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 628:	48d9                	li	a7,22
 ecall
 62a:	00000073          	ecall
 ret
 62e:	8082                	ret

0000000000000630 <nfree>:
.global nfree
nfree:
 li a7, SYS_nfree
 630:	48dd                	li	a7,23
 ecall
 632:	00000073          	ecall
 ret
 636:	8082                	ret

0000000000000638 <test_rcu>:
.global test_rcu
test_rcu:
 li a7, SYS_test_rcu
 638:	48e1                	li	a7,24
 ecall
 63a:	00000073          	ecall
 ret
 63e:	8082                	ret

0000000000000640 <rcu_read_only>:
.global rcu_read_only
rcu_read_only:
 li a7, SYS_rcu_read_only
 640:	48e5                	li	a7,25
 ecall
 642:	00000073          	ecall
 ret
 646:	8082                	ret

0000000000000648 <rcu_read_heavy>:
.global rcu_read_heavy
rcu_read_heavy:
 li a7, SYS_rcu_read_heavy
 648:	48e9                	li	a7,26
 ecall
 64a:	00000073          	ecall
 ret
 64e:	8082                	ret

0000000000000650 <rcu_read_write_mix>:
.global rcu_read_write_mix
rcu_read_write_mix:
 li a7, SYS_rcu_read_write_mix
 650:	48ed                	li	a7,27
 ecall
 652:	00000073          	ecall
 ret
 656:	8082                	ret

0000000000000658 <rcu_read_stress>:
.global rcu_read_stress
rcu_read_stress:
 li a7, SYS_rcu_read_stress
 658:	48f1                	li	a7,28
 ecall
 65a:	00000073          	ecall
 ret
 65e:	8082                	ret

0000000000000660 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 660:	1101                	addi	sp,sp,-32
 662:	ec06                	sd	ra,24(sp)
 664:	e822                	sd	s0,16(sp)
 666:	1000                	addi	s0,sp,32
 668:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 66c:	4605                	li	a2,1
 66e:	fef40593          	addi	a1,s0,-17
 672:	00000097          	auipc	ra,0x0
 676:	f36080e7          	jalr	-202(ra) # 5a8 <write>
}
 67a:	60e2                	ld	ra,24(sp)
 67c:	6442                	ld	s0,16(sp)
 67e:	6105                	addi	sp,sp,32
 680:	8082                	ret

0000000000000682 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 682:	7139                	addi	sp,sp,-64
 684:	fc06                	sd	ra,56(sp)
 686:	f822                	sd	s0,48(sp)
 688:	f426                	sd	s1,40(sp)
 68a:	f04a                	sd	s2,32(sp)
 68c:	ec4e                	sd	s3,24(sp)
 68e:	0080                	addi	s0,sp,64
 690:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 692:	c299                	beqz	a3,698 <printint+0x16>
 694:	0805c863          	bltz	a1,724 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 698:	2581                	sext.w	a1,a1
  neg = 0;
 69a:	4881                	li	a7,0
 69c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 6a0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 6a2:	2601                	sext.w	a2,a2
 6a4:	00000517          	auipc	a0,0x0
 6a8:	5b450513          	addi	a0,a0,1460 # c58 <digits>
 6ac:	883a                	mv	a6,a4
 6ae:	2705                	addiw	a4,a4,1
 6b0:	02c5f7bb          	remuw	a5,a1,a2
 6b4:	1782                	slli	a5,a5,0x20
 6b6:	9381                	srli	a5,a5,0x20
 6b8:	97aa                	add	a5,a5,a0
 6ba:	0007c783          	lbu	a5,0(a5)
 6be:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 6c2:	0005879b          	sext.w	a5,a1
 6c6:	02c5d5bb          	divuw	a1,a1,a2
 6ca:	0685                	addi	a3,a3,1
 6cc:	fec7f0e3          	bgeu	a5,a2,6ac <printint+0x2a>
  if(neg)
 6d0:	00088b63          	beqz	a7,6e6 <printint+0x64>
    buf[i++] = '-';
 6d4:	fd040793          	addi	a5,s0,-48
 6d8:	973e                	add	a4,a4,a5
 6da:	02d00793          	li	a5,45
 6de:	fef70823          	sb	a5,-16(a4)
 6e2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 6e6:	02e05863          	blez	a4,716 <printint+0x94>
 6ea:	fc040793          	addi	a5,s0,-64
 6ee:	00e78933          	add	s2,a5,a4
 6f2:	fff78993          	addi	s3,a5,-1
 6f6:	99ba                	add	s3,s3,a4
 6f8:	377d                	addiw	a4,a4,-1
 6fa:	1702                	slli	a4,a4,0x20
 6fc:	9301                	srli	a4,a4,0x20
 6fe:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 702:	fff94583          	lbu	a1,-1(s2)
 706:	8526                	mv	a0,s1
 708:	00000097          	auipc	ra,0x0
 70c:	f58080e7          	jalr	-168(ra) # 660 <putc>
  while(--i >= 0)
 710:	197d                	addi	s2,s2,-1
 712:	ff3918e3          	bne	s2,s3,702 <printint+0x80>
}
 716:	70e2                	ld	ra,56(sp)
 718:	7442                	ld	s0,48(sp)
 71a:	74a2                	ld	s1,40(sp)
 71c:	7902                	ld	s2,32(sp)
 71e:	69e2                	ld	s3,24(sp)
 720:	6121                	addi	sp,sp,64
 722:	8082                	ret
    x = -xx;
 724:	40b005bb          	negw	a1,a1
    neg = 1;
 728:	4885                	li	a7,1
    x = -xx;
 72a:	bf8d                	j	69c <printint+0x1a>

000000000000072c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 72c:	7119                	addi	sp,sp,-128
 72e:	fc86                	sd	ra,120(sp)
 730:	f8a2                	sd	s0,112(sp)
 732:	f4a6                	sd	s1,104(sp)
 734:	f0ca                	sd	s2,96(sp)
 736:	ecce                	sd	s3,88(sp)
 738:	e8d2                	sd	s4,80(sp)
 73a:	e4d6                	sd	s5,72(sp)
 73c:	e0da                	sd	s6,64(sp)
 73e:	fc5e                	sd	s7,56(sp)
 740:	f862                	sd	s8,48(sp)
 742:	f466                	sd	s9,40(sp)
 744:	f06a                	sd	s10,32(sp)
 746:	ec6e                	sd	s11,24(sp)
 748:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 74a:	0005c903          	lbu	s2,0(a1)
 74e:	18090f63          	beqz	s2,8ec <vprintf+0x1c0>
 752:	8aaa                	mv	s5,a0
 754:	8b32                	mv	s6,a2
 756:	00158493          	addi	s1,a1,1
  state = 0;
 75a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 75c:	02500a13          	li	s4,37
      if(c == 'd'){
 760:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 764:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 768:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 76c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 770:	00000b97          	auipc	s7,0x0
 774:	4e8b8b93          	addi	s7,s7,1256 # c58 <digits>
 778:	a839                	j	796 <vprintf+0x6a>
        putc(fd, c);
 77a:	85ca                	mv	a1,s2
 77c:	8556                	mv	a0,s5
 77e:	00000097          	auipc	ra,0x0
 782:	ee2080e7          	jalr	-286(ra) # 660 <putc>
 786:	a019                	j	78c <vprintf+0x60>
    } else if(state == '%'){
 788:	01498f63          	beq	s3,s4,7a6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 78c:	0485                	addi	s1,s1,1
 78e:	fff4c903          	lbu	s2,-1(s1) # 40000fff <__global_pointer$+0x3ffffb96>
 792:	14090d63          	beqz	s2,8ec <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 796:	0009079b          	sext.w	a5,s2
    if(state == 0){
 79a:	fe0997e3          	bnez	s3,788 <vprintf+0x5c>
      if(c == '%'){
 79e:	fd479ee3          	bne	a5,s4,77a <vprintf+0x4e>
        state = '%';
 7a2:	89be                	mv	s3,a5
 7a4:	b7e5                	j	78c <vprintf+0x60>
      if(c == 'd'){
 7a6:	05878063          	beq	a5,s8,7e6 <vprintf+0xba>
      } else if(c == 'l') {
 7aa:	05978c63          	beq	a5,s9,802 <vprintf+0xd6>
      } else if(c == 'x') {
 7ae:	07a78863          	beq	a5,s10,81e <vprintf+0xf2>
      } else if(c == 'p') {
 7b2:	09b78463          	beq	a5,s11,83a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 7b6:	07300713          	li	a4,115
 7ba:	0ce78663          	beq	a5,a4,886 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7be:	06300713          	li	a4,99
 7c2:	0ee78e63          	beq	a5,a4,8be <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 7c6:	11478863          	beq	a5,s4,8d6 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7ca:	85d2                	mv	a1,s4
 7cc:	8556                	mv	a0,s5
 7ce:	00000097          	auipc	ra,0x0
 7d2:	e92080e7          	jalr	-366(ra) # 660 <putc>
        putc(fd, c);
 7d6:	85ca                	mv	a1,s2
 7d8:	8556                	mv	a0,s5
 7da:	00000097          	auipc	ra,0x0
 7de:	e86080e7          	jalr	-378(ra) # 660 <putc>
      }
      state = 0;
 7e2:	4981                	li	s3,0
 7e4:	b765                	j	78c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 7e6:	008b0913          	addi	s2,s6,8
 7ea:	4685                	li	a3,1
 7ec:	4629                	li	a2,10
 7ee:	000b2583          	lw	a1,0(s6)
 7f2:	8556                	mv	a0,s5
 7f4:	00000097          	auipc	ra,0x0
 7f8:	e8e080e7          	jalr	-370(ra) # 682 <printint>
 7fc:	8b4a                	mv	s6,s2
      state = 0;
 7fe:	4981                	li	s3,0
 800:	b771                	j	78c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 802:	008b0913          	addi	s2,s6,8
 806:	4681                	li	a3,0
 808:	4629                	li	a2,10
 80a:	000b2583          	lw	a1,0(s6)
 80e:	8556                	mv	a0,s5
 810:	00000097          	auipc	ra,0x0
 814:	e72080e7          	jalr	-398(ra) # 682 <printint>
 818:	8b4a                	mv	s6,s2
      state = 0;
 81a:	4981                	li	s3,0
 81c:	bf85                	j	78c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 81e:	008b0913          	addi	s2,s6,8
 822:	4681                	li	a3,0
 824:	4641                	li	a2,16
 826:	000b2583          	lw	a1,0(s6)
 82a:	8556                	mv	a0,s5
 82c:	00000097          	auipc	ra,0x0
 830:	e56080e7          	jalr	-426(ra) # 682 <printint>
 834:	8b4a                	mv	s6,s2
      state = 0;
 836:	4981                	li	s3,0
 838:	bf91                	j	78c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 83a:	008b0793          	addi	a5,s6,8
 83e:	f8f43423          	sd	a5,-120(s0)
 842:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 846:	03000593          	li	a1,48
 84a:	8556                	mv	a0,s5
 84c:	00000097          	auipc	ra,0x0
 850:	e14080e7          	jalr	-492(ra) # 660 <putc>
  putc(fd, 'x');
 854:	85ea                	mv	a1,s10
 856:	8556                	mv	a0,s5
 858:	00000097          	auipc	ra,0x0
 85c:	e08080e7          	jalr	-504(ra) # 660 <putc>
 860:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 862:	03c9d793          	srli	a5,s3,0x3c
 866:	97de                	add	a5,a5,s7
 868:	0007c583          	lbu	a1,0(a5)
 86c:	8556                	mv	a0,s5
 86e:	00000097          	auipc	ra,0x0
 872:	df2080e7          	jalr	-526(ra) # 660 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 876:	0992                	slli	s3,s3,0x4
 878:	397d                	addiw	s2,s2,-1
 87a:	fe0914e3          	bnez	s2,862 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 87e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 882:	4981                	li	s3,0
 884:	b721                	j	78c <vprintf+0x60>
        s = va_arg(ap, char*);
 886:	008b0993          	addi	s3,s6,8
 88a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 88e:	02090163          	beqz	s2,8b0 <vprintf+0x184>
        while(*s != 0){
 892:	00094583          	lbu	a1,0(s2)
 896:	c9a1                	beqz	a1,8e6 <vprintf+0x1ba>
          putc(fd, *s);
 898:	8556                	mv	a0,s5
 89a:	00000097          	auipc	ra,0x0
 89e:	dc6080e7          	jalr	-570(ra) # 660 <putc>
          s++;
 8a2:	0905                	addi	s2,s2,1
        while(*s != 0){
 8a4:	00094583          	lbu	a1,0(s2)
 8a8:	f9e5                	bnez	a1,898 <vprintf+0x16c>
        s = va_arg(ap, char*);
 8aa:	8b4e                	mv	s6,s3
      state = 0;
 8ac:	4981                	li	s3,0
 8ae:	bdf9                	j	78c <vprintf+0x60>
          s = "(null)";
 8b0:	00000917          	auipc	s2,0x0
 8b4:	3a090913          	addi	s2,s2,928 # c50 <malloc+0x25a>
        while(*s != 0){
 8b8:	02800593          	li	a1,40
 8bc:	bff1                	j	898 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 8be:	008b0913          	addi	s2,s6,8
 8c2:	000b4583          	lbu	a1,0(s6)
 8c6:	8556                	mv	a0,s5
 8c8:	00000097          	auipc	ra,0x0
 8cc:	d98080e7          	jalr	-616(ra) # 660 <putc>
 8d0:	8b4a                	mv	s6,s2
      state = 0;
 8d2:	4981                	li	s3,0
 8d4:	bd65                	j	78c <vprintf+0x60>
        putc(fd, c);
 8d6:	85d2                	mv	a1,s4
 8d8:	8556                	mv	a0,s5
 8da:	00000097          	auipc	ra,0x0
 8de:	d86080e7          	jalr	-634(ra) # 660 <putc>
      state = 0;
 8e2:	4981                	li	s3,0
 8e4:	b565                	j	78c <vprintf+0x60>
        s = va_arg(ap, char*);
 8e6:	8b4e                	mv	s6,s3
      state = 0;
 8e8:	4981                	li	s3,0
 8ea:	b54d                	j	78c <vprintf+0x60>
    }
  }
}
 8ec:	70e6                	ld	ra,120(sp)
 8ee:	7446                	ld	s0,112(sp)
 8f0:	74a6                	ld	s1,104(sp)
 8f2:	7906                	ld	s2,96(sp)
 8f4:	69e6                	ld	s3,88(sp)
 8f6:	6a46                	ld	s4,80(sp)
 8f8:	6aa6                	ld	s5,72(sp)
 8fa:	6b06                	ld	s6,64(sp)
 8fc:	7be2                	ld	s7,56(sp)
 8fe:	7c42                	ld	s8,48(sp)
 900:	7ca2                	ld	s9,40(sp)
 902:	7d02                	ld	s10,32(sp)
 904:	6de2                	ld	s11,24(sp)
 906:	6109                	addi	sp,sp,128
 908:	8082                	ret

000000000000090a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 90a:	715d                	addi	sp,sp,-80
 90c:	ec06                	sd	ra,24(sp)
 90e:	e822                	sd	s0,16(sp)
 910:	1000                	addi	s0,sp,32
 912:	e010                	sd	a2,0(s0)
 914:	e414                	sd	a3,8(s0)
 916:	e818                	sd	a4,16(s0)
 918:	ec1c                	sd	a5,24(s0)
 91a:	03043023          	sd	a6,32(s0)
 91e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 922:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 926:	8622                	mv	a2,s0
 928:	00000097          	auipc	ra,0x0
 92c:	e04080e7          	jalr	-508(ra) # 72c <vprintf>
}
 930:	60e2                	ld	ra,24(sp)
 932:	6442                	ld	s0,16(sp)
 934:	6161                	addi	sp,sp,80
 936:	8082                	ret

0000000000000938 <printf>:

void
printf(const char *fmt, ...)
{
 938:	711d                	addi	sp,sp,-96
 93a:	ec06                	sd	ra,24(sp)
 93c:	e822                	sd	s0,16(sp)
 93e:	1000                	addi	s0,sp,32
 940:	e40c                	sd	a1,8(s0)
 942:	e810                	sd	a2,16(s0)
 944:	ec14                	sd	a3,24(s0)
 946:	f018                	sd	a4,32(s0)
 948:	f41c                	sd	a5,40(s0)
 94a:	03043823          	sd	a6,48(s0)
 94e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 952:	00840613          	addi	a2,s0,8
 956:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 95a:	85aa                	mv	a1,a0
 95c:	4505                	li	a0,1
 95e:	00000097          	auipc	ra,0x0
 962:	dce080e7          	jalr	-562(ra) # 72c <vprintf>
}
 966:	60e2                	ld	ra,24(sp)
 968:	6442                	ld	s0,16(sp)
 96a:	6125                	addi	sp,sp,96
 96c:	8082                	ret

000000000000096e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 96e:	1141                	addi	sp,sp,-16
 970:	e422                	sd	s0,8(sp)
 972:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 974:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 978:	00000797          	auipc	a5,0x0
 97c:	2f87b783          	ld	a5,760(a5) # c70 <freep>
 980:	a805                	j	9b0 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 982:	4618                	lw	a4,8(a2)
 984:	9db9                	addw	a1,a1,a4
 986:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 98a:	6398                	ld	a4,0(a5)
 98c:	6318                	ld	a4,0(a4)
 98e:	fee53823          	sd	a4,-16(a0)
 992:	a091                	j	9d6 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 994:	ff852703          	lw	a4,-8(a0)
 998:	9e39                	addw	a2,a2,a4
 99a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 99c:	ff053703          	ld	a4,-16(a0)
 9a0:	e398                	sd	a4,0(a5)
 9a2:	a099                	j	9e8 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9a4:	6398                	ld	a4,0(a5)
 9a6:	00e7e463          	bltu	a5,a4,9ae <free+0x40>
 9aa:	00e6ea63          	bltu	a3,a4,9be <free+0x50>
{
 9ae:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9b0:	fed7fae3          	bgeu	a5,a3,9a4 <free+0x36>
 9b4:	6398                	ld	a4,0(a5)
 9b6:	00e6e463          	bltu	a3,a4,9be <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9ba:	fee7eae3          	bltu	a5,a4,9ae <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 9be:	ff852583          	lw	a1,-8(a0)
 9c2:	6390                	ld	a2,0(a5)
 9c4:	02059713          	slli	a4,a1,0x20
 9c8:	9301                	srli	a4,a4,0x20
 9ca:	0712                	slli	a4,a4,0x4
 9cc:	9736                	add	a4,a4,a3
 9ce:	fae60ae3          	beq	a2,a4,982 <free+0x14>
    bp->s.ptr = p->s.ptr;
 9d2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9d6:	4790                	lw	a2,8(a5)
 9d8:	02061713          	slli	a4,a2,0x20
 9dc:	9301                	srli	a4,a4,0x20
 9de:	0712                	slli	a4,a4,0x4
 9e0:	973e                	add	a4,a4,a5
 9e2:	fae689e3          	beq	a3,a4,994 <free+0x26>
  } else
    p->s.ptr = bp;
 9e6:	e394                	sd	a3,0(a5)
  freep = p;
 9e8:	00000717          	auipc	a4,0x0
 9ec:	28f73423          	sd	a5,648(a4) # c70 <freep>
}
 9f0:	6422                	ld	s0,8(sp)
 9f2:	0141                	addi	sp,sp,16
 9f4:	8082                	ret

00000000000009f6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9f6:	7139                	addi	sp,sp,-64
 9f8:	fc06                	sd	ra,56(sp)
 9fa:	f822                	sd	s0,48(sp)
 9fc:	f426                	sd	s1,40(sp)
 9fe:	f04a                	sd	s2,32(sp)
 a00:	ec4e                	sd	s3,24(sp)
 a02:	e852                	sd	s4,16(sp)
 a04:	e456                	sd	s5,8(sp)
 a06:	e05a                	sd	s6,0(sp)
 a08:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a0a:	02051493          	slli	s1,a0,0x20
 a0e:	9081                	srli	s1,s1,0x20
 a10:	04bd                	addi	s1,s1,15
 a12:	8091                	srli	s1,s1,0x4
 a14:	0014899b          	addiw	s3,s1,1
 a18:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a1a:	00000517          	auipc	a0,0x0
 a1e:	25653503          	ld	a0,598(a0) # c70 <freep>
 a22:	c515                	beqz	a0,a4e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a24:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a26:	4798                	lw	a4,8(a5)
 a28:	02977f63          	bgeu	a4,s1,a66 <malloc+0x70>
 a2c:	8a4e                	mv	s4,s3
 a2e:	0009871b          	sext.w	a4,s3
 a32:	6685                	lui	a3,0x1
 a34:	00d77363          	bgeu	a4,a3,a3a <malloc+0x44>
 a38:	6a05                	lui	s4,0x1
 a3a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a3e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a42:	00000917          	auipc	s2,0x0
 a46:	22e90913          	addi	s2,s2,558 # c70 <freep>
  if(p == (char*)-1)
 a4a:	5afd                	li	s5,-1
 a4c:	a88d                	j	abe <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 a4e:	00000797          	auipc	a5,0x0
 a52:	22a78793          	addi	a5,a5,554 # c78 <base>
 a56:	00000717          	auipc	a4,0x0
 a5a:	20f73d23          	sd	a5,538(a4) # c70 <freep>
 a5e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a60:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a64:	b7e1                	j	a2c <malloc+0x36>
      if(p->s.size == nunits)
 a66:	02e48b63          	beq	s1,a4,a9c <malloc+0xa6>
        p->s.size -= nunits;
 a6a:	4137073b          	subw	a4,a4,s3
 a6e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a70:	1702                	slli	a4,a4,0x20
 a72:	9301                	srli	a4,a4,0x20
 a74:	0712                	slli	a4,a4,0x4
 a76:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a78:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a7c:	00000717          	auipc	a4,0x0
 a80:	1ea73a23          	sd	a0,500(a4) # c70 <freep>
      return (void*)(p + 1);
 a84:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a88:	70e2                	ld	ra,56(sp)
 a8a:	7442                	ld	s0,48(sp)
 a8c:	74a2                	ld	s1,40(sp)
 a8e:	7902                	ld	s2,32(sp)
 a90:	69e2                	ld	s3,24(sp)
 a92:	6a42                	ld	s4,16(sp)
 a94:	6aa2                	ld	s5,8(sp)
 a96:	6b02                	ld	s6,0(sp)
 a98:	6121                	addi	sp,sp,64
 a9a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a9c:	6398                	ld	a4,0(a5)
 a9e:	e118                	sd	a4,0(a0)
 aa0:	bff1                	j	a7c <malloc+0x86>
  hp->s.size = nu;
 aa2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 aa6:	0541                	addi	a0,a0,16
 aa8:	00000097          	auipc	ra,0x0
 aac:	ec6080e7          	jalr	-314(ra) # 96e <free>
  return freep;
 ab0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 ab4:	d971                	beqz	a0,a88 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ab6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ab8:	4798                	lw	a4,8(a5)
 aba:	fa9776e3          	bgeu	a4,s1,a66 <malloc+0x70>
    if(p == freep)
 abe:	00093703          	ld	a4,0(s2)
 ac2:	853e                	mv	a0,a5
 ac4:	fef719e3          	bne	a4,a5,ab6 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 ac8:	8552                	mv	a0,s4
 aca:	00000097          	auipc	ra,0x0
 ace:	b46080e7          	jalr	-1210(ra) # 610 <sbrk>
  if(p == (char*)-1)
 ad2:	fd5518e3          	bne	a0,s5,aa2 <malloc+0xac>
        return 0;
 ad6:	4501                	li	a0,0
 ad8:	bf45                	j	a88 <malloc+0x92>
