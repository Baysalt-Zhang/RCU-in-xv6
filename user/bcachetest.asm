
user/_bcachetest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <createfile>:
  exit(0);
}

void
createfile(char *file, int nblock)
{
   0:	bd010113          	addi	sp,sp,-1072
   4:	42113423          	sd	ra,1064(sp)
   8:	42813023          	sd	s0,1056(sp)
   c:	40913c23          	sd	s1,1048(sp)
  10:	41213823          	sd	s2,1040(sp)
  14:	41313423          	sd	s3,1032(sp)
  18:	41413023          	sd	s4,1024(sp)
  1c:	43010413          	addi	s0,sp,1072
  20:	8a2a                	mv	s4,a0
  22:	89ae                	mv	s3,a1
  int fd;
  char buf[BSIZE];
  int i;
  
  fd = open(file, O_CREATE | O_RDWR);
  24:	20200593          	li	a1,514
  28:	00000097          	auipc	ra,0x0
  2c:	74e080e7          	jalr	1870(ra) # 776 <open>
  if(fd < 0){
  30:	04054a63          	bltz	a0,84 <createfile+0x84>
  34:	892a                	mv	s2,a0
    printf("test0 create %s failed\n", file);
    exit(-1);
  }
  for(i = 0; i < nblock; i++) {
  36:	4481                	li	s1,0
  38:	03305263          	blez	s3,5c <createfile+0x5c>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)) {
  3c:	40000613          	li	a2,1024
  40:	bd040593          	addi	a1,s0,-1072
  44:	854a                	mv	a0,s2
  46:	00000097          	auipc	ra,0x0
  4a:	710080e7          	jalr	1808(ra) # 756 <write>
  4e:	40000793          	li	a5,1024
  52:	04f51763          	bne	a0,a5,a0 <createfile+0xa0>
  for(i = 0; i < nblock; i++) {
  56:	2485                	addiw	s1,s1,1
  58:	fe9992e3          	bne	s3,s1,3c <createfile+0x3c>
      printf("write %s failed\n", file);
      exit(-1);
    }
  }
  close(fd);
  5c:	854a                	mv	a0,s2
  5e:	00000097          	auipc	ra,0x0
  62:	700080e7          	jalr	1792(ra) # 75e <close>
}
  66:	42813083          	ld	ra,1064(sp)
  6a:	42013403          	ld	s0,1056(sp)
  6e:	41813483          	ld	s1,1048(sp)
  72:	41013903          	ld	s2,1040(sp)
  76:	40813983          	ld	s3,1032(sp)
  7a:	40013a03          	ld	s4,1024(sp)
  7e:	43010113          	addi	sp,sp,1072
  82:	8082                	ret
    printf("test0 create %s failed\n", file);
  84:	85d2                	mv	a1,s4
  86:	00001517          	auipc	a0,0x1
  8a:	c0250513          	addi	a0,a0,-1022 # c88 <malloc+0xe4>
  8e:	00001097          	auipc	ra,0x1
  92:	a58080e7          	jalr	-1448(ra) # ae6 <printf>
    exit(-1);
  96:	557d                	li	a0,-1
  98:	00000097          	auipc	ra,0x0
  9c:	69e080e7          	jalr	1694(ra) # 736 <exit>
      printf("write %s failed\n", file);
  a0:	85d2                	mv	a1,s4
  a2:	00001517          	auipc	a0,0x1
  a6:	bfe50513          	addi	a0,a0,-1026 # ca0 <malloc+0xfc>
  aa:	00001097          	auipc	ra,0x1
  ae:	a3c080e7          	jalr	-1476(ra) # ae6 <printf>
      exit(-1);
  b2:	557d                	li	a0,-1
  b4:	00000097          	auipc	ra,0x0
  b8:	682080e7          	jalr	1666(ra) # 736 <exit>

00000000000000bc <readfile>:

void
readfile(char *file, int nbytes, int inc)
{
  bc:	bc010113          	addi	sp,sp,-1088
  c0:	42113c23          	sd	ra,1080(sp)
  c4:	42813823          	sd	s0,1072(sp)
  c8:	42913423          	sd	s1,1064(sp)
  cc:	43213023          	sd	s2,1056(sp)
  d0:	41313c23          	sd	s3,1048(sp)
  d4:	41413823          	sd	s4,1040(sp)
  d8:	41513423          	sd	s5,1032(sp)
  dc:	44010413          	addi	s0,sp,1088
  char buf[BSIZE];
  int fd;
  int i;

  if(inc > BSIZE) {
  e0:	40000793          	li	a5,1024
  e4:	06c7c463          	blt	a5,a2,14c <readfile+0x90>
  e8:	8aaa                	mv	s5,a0
  ea:	8a2e                	mv	s4,a1
  ec:	84b2                	mv	s1,a2
    printf("test0: inc too large\n");
    exit(-1);
  }
  if ((fd = open(file, O_RDONLY)) < 0) {
  ee:	4581                	li	a1,0
  f0:	00000097          	auipc	ra,0x0
  f4:	686080e7          	jalr	1670(ra) # 776 <open>
  f8:	89aa                	mv	s3,a0
  fa:	06054663          	bltz	a0,166 <readfile+0xaa>
    printf("test0 open %s failed\n", file);
    exit(-1);
  }
  for (i = 0; i < nbytes; i += inc) {
  fe:	4901                	li	s2,0
 100:	03405063          	blez	s4,120 <readfile+0x64>
    if(read(fd, buf, inc) != inc) {
 104:	8626                	mv	a2,s1
 106:	bc040593          	addi	a1,s0,-1088
 10a:	854e                	mv	a0,s3
 10c:	00000097          	auipc	ra,0x0
 110:	642080e7          	jalr	1602(ra) # 74e <read>
 114:	06951763          	bne	a0,s1,182 <readfile+0xc6>
  for (i = 0; i < nbytes; i += inc) {
 118:	0124893b          	addw	s2,s1,s2
 11c:	ff4944e3          	blt	s2,s4,104 <readfile+0x48>
      printf("read %s failed for block %d (%d)\n", file, i, nbytes);
      exit(-1);
    }
  }
  close(fd);
 120:	854e                	mv	a0,s3
 122:	00000097          	auipc	ra,0x0
 126:	63c080e7          	jalr	1596(ra) # 75e <close>
}
 12a:	43813083          	ld	ra,1080(sp)
 12e:	43013403          	ld	s0,1072(sp)
 132:	42813483          	ld	s1,1064(sp)
 136:	42013903          	ld	s2,1056(sp)
 13a:	41813983          	ld	s3,1048(sp)
 13e:	41013a03          	ld	s4,1040(sp)
 142:	40813a83          	ld	s5,1032(sp)
 146:	44010113          	addi	sp,sp,1088
 14a:	8082                	ret
    printf("test0: inc too large\n");
 14c:	00001517          	auipc	a0,0x1
 150:	b6c50513          	addi	a0,a0,-1172 # cb8 <malloc+0x114>
 154:	00001097          	auipc	ra,0x1
 158:	992080e7          	jalr	-1646(ra) # ae6 <printf>
    exit(-1);
 15c:	557d                	li	a0,-1
 15e:	00000097          	auipc	ra,0x0
 162:	5d8080e7          	jalr	1496(ra) # 736 <exit>
    printf("test0 open %s failed\n", file);
 166:	85d6                	mv	a1,s5
 168:	00001517          	auipc	a0,0x1
 16c:	b6850513          	addi	a0,a0,-1176 # cd0 <malloc+0x12c>
 170:	00001097          	auipc	ra,0x1
 174:	976080e7          	jalr	-1674(ra) # ae6 <printf>
    exit(-1);
 178:	557d                	li	a0,-1
 17a:	00000097          	auipc	ra,0x0
 17e:	5bc080e7          	jalr	1468(ra) # 736 <exit>
      printf("read %s failed for block %d (%d)\n", file, i, nbytes);
 182:	86d2                	mv	a3,s4
 184:	864a                	mv	a2,s2
 186:	85d6                	mv	a1,s5
 188:	00001517          	auipc	a0,0x1
 18c:	b6050513          	addi	a0,a0,-1184 # ce8 <malloc+0x144>
 190:	00001097          	auipc	ra,0x1
 194:	956080e7          	jalr	-1706(ra) # ae6 <printf>
      exit(-1);
 198:	557d                	li	a0,-1
 19a:	00000097          	auipc	ra,0x0
 19e:	59c080e7          	jalr	1436(ra) # 736 <exit>

00000000000001a2 <test0>:

void
test0()
{
 1a2:	7139                	addi	sp,sp,-64
 1a4:	fc06                	sd	ra,56(sp)
 1a6:	f822                	sd	s0,48(sp)
 1a8:	f426                	sd	s1,40(sp)
 1aa:	f04a                	sd	s2,32(sp)
 1ac:	ec4e                	sd	s3,24(sp)
 1ae:	0080                	addi	s0,sp,64
  char file[2];
  char dir[2];
  enum { N = 10, NCHILD = 3 };
  int n;

  dir[0] = '0';
 1b0:	03000793          	li	a5,48
 1b4:	fcf40023          	sb	a5,-64(s0)
  dir[1] = '\0';
 1b8:	fc0400a3          	sb	zero,-63(s0)
  file[0] = 'F';
 1bc:	04600793          	li	a5,70
 1c0:	fcf40423          	sb	a5,-56(s0)
  file[1] = '\0';
 1c4:	fc0404a3          	sb	zero,-55(s0)

  printf("start test0\n");
 1c8:	00001517          	auipc	a0,0x1
 1cc:	b4850513          	addi	a0,a0,-1208 # d10 <malloc+0x16c>
 1d0:	00001097          	auipc	ra,0x1
 1d4:	916080e7          	jalr	-1770(ra) # ae6 <printf>
 1d8:	03000493          	li	s1,48
    if (chdir(dir) < 0) {
      printf("chdir failed\n");
      exit(1);
    }
    createfile(file, N);
    if (chdir("..") < 0) {
 1dc:	00001997          	auipc	s3,0x1
 1e0:	b6498993          	addi	s3,s3,-1180 # d40 <malloc+0x19c>
  for(int i = 0; i < NCHILD; i++){
 1e4:	03300913          	li	s2,51
    dir[0] = '0' + i;
 1e8:	fc940023          	sb	s1,-64(s0)
    if (mkdir(dir) < 0) {
 1ec:	fc040513          	addi	a0,s0,-64
 1f0:	00000097          	auipc	ra,0x0
 1f4:	5ae080e7          	jalr	1454(ra) # 79e <mkdir>
 1f8:	0c054063          	bltz	a0,2b8 <test0+0x116>
    if (chdir(dir) < 0) {
 1fc:	fc040513          	addi	a0,s0,-64
 200:	00000097          	auipc	ra,0x0
 204:	5a6080e7          	jalr	1446(ra) # 7a6 <chdir>
 208:	0c054563          	bltz	a0,2d2 <test0+0x130>
    createfile(file, N);
 20c:	45a9                	li	a1,10
 20e:	fc840513          	addi	a0,s0,-56
 212:	00000097          	auipc	ra,0x0
 216:	dee080e7          	jalr	-530(ra) # 0 <createfile>
    if (chdir("..") < 0) {
 21a:	854e                	mv	a0,s3
 21c:	00000097          	auipc	ra,0x0
 220:	58a080e7          	jalr	1418(ra) # 7a6 <chdir>
 224:	0c054463          	bltz	a0,2ec <test0+0x14a>
  for(int i = 0; i < NCHILD; i++){
 228:	2485                	addiw	s1,s1,1
 22a:	0ff4f493          	andi	s1,s1,255
 22e:	fb249de3          	bne	s1,s2,1e8 <test0+0x46>
      printf("chdir failed\n");
      exit(1);
    }
  }
  ntas(0);
 232:	4501                	li	a0,0
 234:	00000097          	auipc	ra,0x0
 238:	5a2080e7          	jalr	1442(ra) # 7d6 <ntas>
 23c:	03000493          	li	s1,48
  for(int i = 0; i < NCHILD; i++){
 240:	03300913          	li	s2,51
    dir[0] = '0' + i;
 244:	fc940023          	sb	s1,-64(s0)
    int pid = fork();
 248:	00000097          	auipc	ra,0x0
 24c:	4e6080e7          	jalr	1254(ra) # 72e <fork>
    if(pid < 0){
 250:	0a054b63          	bltz	a0,306 <test0+0x164>
      printf("fork failed");
      exit(-1);
    }
    if(pid == 0){
 254:	c571                	beqz	a0,320 <test0+0x17e>
  for(int i = 0; i < NCHILD; i++){
 256:	2485                	addiw	s1,s1,1
 258:	0ff4f493          	andi	s1,s1,255
 25c:	ff2494e3          	bne	s1,s2,244 <test0+0xa2>
      exit(0);
    }
  }

  for(int i = 0; i < NCHILD; i++){
    wait(0);
 260:	4501                	li	a0,0
 262:	00000097          	auipc	ra,0x0
 266:	4dc080e7          	jalr	1244(ra) # 73e <wait>
 26a:	4501                	li	a0,0
 26c:	00000097          	auipc	ra,0x0
 270:	4d2080e7          	jalr	1234(ra) # 73e <wait>
 274:	4501                	li	a0,0
 276:	00000097          	auipc	ra,0x0
 27a:	4c8080e7          	jalr	1224(ra) # 73e <wait>
  }
  printf("test0 results:\n");
 27e:	00001517          	auipc	a0,0x1
 282:	ada50513          	addi	a0,a0,-1318 # d58 <malloc+0x1b4>
 286:	00001097          	auipc	ra,0x1
 28a:	860080e7          	jalr	-1952(ra) # ae6 <printf>
  n = ntas(1);
 28e:	4505                	li	a0,1
 290:	00000097          	auipc	ra,0x0
 294:	546080e7          	jalr	1350(ra) # 7d6 <ntas>
  if (n == 0)
 298:	e94d                	bnez	a0,34a <test0+0x1a8>
    printf("test0: OK\n");
 29a:	00001517          	auipc	a0,0x1
 29e:	ace50513          	addi	a0,a0,-1330 # d68 <malloc+0x1c4>
 2a2:	00001097          	auipc	ra,0x1
 2a6:	844080e7          	jalr	-1980(ra) # ae6 <printf>
  else
    printf("test0: FAIL\n");
}
 2aa:	70e2                	ld	ra,56(sp)
 2ac:	7442                	ld	s0,48(sp)
 2ae:	74a2                	ld	s1,40(sp)
 2b0:	7902                	ld	s2,32(sp)
 2b2:	69e2                	ld	s3,24(sp)
 2b4:	6121                	addi	sp,sp,64
 2b6:	8082                	ret
      printf("mkdir failed\n");
 2b8:	00001517          	auipc	a0,0x1
 2bc:	a6850513          	addi	a0,a0,-1432 # d20 <malloc+0x17c>
 2c0:	00001097          	auipc	ra,0x1
 2c4:	826080e7          	jalr	-2010(ra) # ae6 <printf>
      exit(1);
 2c8:	4505                	li	a0,1
 2ca:	00000097          	auipc	ra,0x0
 2ce:	46c080e7          	jalr	1132(ra) # 736 <exit>
      printf("chdir failed\n");
 2d2:	00001517          	auipc	a0,0x1
 2d6:	a5e50513          	addi	a0,a0,-1442 # d30 <malloc+0x18c>
 2da:	00001097          	auipc	ra,0x1
 2de:	80c080e7          	jalr	-2036(ra) # ae6 <printf>
      exit(1);
 2e2:	4505                	li	a0,1
 2e4:	00000097          	auipc	ra,0x0
 2e8:	452080e7          	jalr	1106(ra) # 736 <exit>
      printf("chdir failed\n");
 2ec:	00001517          	auipc	a0,0x1
 2f0:	a4450513          	addi	a0,a0,-1468 # d30 <malloc+0x18c>
 2f4:	00000097          	auipc	ra,0x0
 2f8:	7f2080e7          	jalr	2034(ra) # ae6 <printf>
      exit(1);
 2fc:	4505                	li	a0,1
 2fe:	00000097          	auipc	ra,0x0
 302:	438080e7          	jalr	1080(ra) # 736 <exit>
      printf("fork failed");
 306:	00001517          	auipc	a0,0x1
 30a:	a4250513          	addi	a0,a0,-1470 # d48 <malloc+0x1a4>
 30e:	00000097          	auipc	ra,0x0
 312:	7d8080e7          	jalr	2008(ra) # ae6 <printf>
      exit(-1);
 316:	557d                	li	a0,-1
 318:	00000097          	auipc	ra,0x0
 31c:	41e080e7          	jalr	1054(ra) # 736 <exit>
      if (chdir(dir) < 0) {
 320:	fc040513          	addi	a0,s0,-64
 324:	00000097          	auipc	ra,0x0
 328:	482080e7          	jalr	1154(ra) # 7a6 <chdir>
 32c:	02055863          	bgez	a0,35c <test0+0x1ba>
        printf("chdir failed\n");
 330:	00001517          	auipc	a0,0x1
 334:	a0050513          	addi	a0,a0,-1536 # d30 <malloc+0x18c>
 338:	00000097          	auipc	ra,0x0
 33c:	7ae080e7          	jalr	1966(ra) # ae6 <printf>
        exit(1);
 340:	4505                	li	a0,1
 342:	00000097          	auipc	ra,0x0
 346:	3f4080e7          	jalr	1012(ra) # 736 <exit>
    printf("test0: FAIL\n");
 34a:	00001517          	auipc	a0,0x1
 34e:	a2e50513          	addi	a0,a0,-1490 # d78 <malloc+0x1d4>
 352:	00000097          	auipc	ra,0x0
 356:	794080e7          	jalr	1940(ra) # ae6 <printf>
}
 35a:	bf81                	j	2aa <test0+0x108>
        readfile(file, N*BSIZE, 1);
 35c:	4605                	li	a2,1
 35e:	658d                	lui	a1,0x3
 360:	80058593          	addi	a1,a1,-2048 # 2800 <__global_pointer$+0x123f>
 364:	fc840513          	addi	a0,s0,-56
 368:	00000097          	auipc	ra,0x0
 36c:	d54080e7          	jalr	-684(ra) # bc <readfile>
      exit(0);
 370:	4501                	li	a0,0
 372:	00000097          	auipc	ra,0x0
 376:	3c4080e7          	jalr	964(ra) # 736 <exit>

000000000000037a <test1>:

void test1()
{
 37a:	7179                	addi	sp,sp,-48
 37c:	f406                	sd	ra,40(sp)
 37e:	f022                	sd	s0,32(sp)
 380:	ec26                	sd	s1,24(sp)
 382:	1800                	addi	s0,sp,48
  char file[3];
  enum { N = 100, BIG=100, NCHILD=2 };
  
  printf("start test1\n");
 384:	00001517          	auipc	a0,0x1
 388:	a0450513          	addi	a0,a0,-1532 # d88 <malloc+0x1e4>
 38c:	00000097          	auipc	ra,0x0
 390:	75a080e7          	jalr	1882(ra) # ae6 <printf>
  file[0] = 'B';
 394:	04200793          	li	a5,66
 398:	fcf40c23          	sb	a5,-40(s0)
  file[2] = '\0';
 39c:	fc040d23          	sb	zero,-38(s0)
  for(int i = 0; i < NCHILD; i++){
    file[1] = '0' + i;
 3a0:	03000493          	li	s1,48
 3a4:	fc940ca3          	sb	s1,-39(s0)
    if (i == 0) {
      createfile(file, BIG);
 3a8:	06400593          	li	a1,100
 3ac:	fd840513          	addi	a0,s0,-40
 3b0:	00000097          	auipc	ra,0x0
 3b4:	c50080e7          	jalr	-944(ra) # 0 <createfile>
    file[1] = '0' + i;
 3b8:	03100793          	li	a5,49
 3bc:	fcf40ca3          	sb	a5,-39(s0)
    } else {
      createfile(file, 1);
 3c0:	4585                	li	a1,1
 3c2:	fd840513          	addi	a0,s0,-40
 3c6:	00000097          	auipc	ra,0x0
 3ca:	c3a080e7          	jalr	-966(ra) # 0 <createfile>
    }
  }
  for(int i = 0; i < NCHILD; i++){
    file[1] = '0' + i;
 3ce:	fc940ca3          	sb	s1,-39(s0)
    int pid = fork();
 3d2:	00000097          	auipc	ra,0x0
 3d6:	35c080e7          	jalr	860(ra) # 72e <fork>
    if(pid < 0){
 3da:	04054563          	bltz	a0,424 <test1+0xaa>
      printf("fork failed");
      exit(-1);
    }
    if(pid == 0){
 3de:	c125                	beqz	a0,43e <test1+0xc4>
    file[1] = '0' + i;
 3e0:	03100793          	li	a5,49
 3e4:	fcf40ca3          	sb	a5,-39(s0)
    int pid = fork();
 3e8:	00000097          	auipc	ra,0x0
 3ec:	346080e7          	jalr	838(ra) # 72e <fork>
    if(pid < 0){
 3f0:	02054a63          	bltz	a0,424 <test1+0xaa>
    if(pid == 0){
 3f4:	cd2d                	beqz	a0,46e <test1+0xf4>
      exit(0);
    }
  }

  for(int i = 0; i < NCHILD; i++){
    wait(0);
 3f6:	4501                	li	a0,0
 3f8:	00000097          	auipc	ra,0x0
 3fc:	346080e7          	jalr	838(ra) # 73e <wait>
 400:	4501                	li	a0,0
 402:	00000097          	auipc	ra,0x0
 406:	33c080e7          	jalr	828(ra) # 73e <wait>
  }
  printf("test1 OK\n");
 40a:	00001517          	auipc	a0,0x1
 40e:	98e50513          	addi	a0,a0,-1650 # d98 <malloc+0x1f4>
 412:	00000097          	auipc	ra,0x0
 416:	6d4080e7          	jalr	1748(ra) # ae6 <printf>
}
 41a:	70a2                	ld	ra,40(sp)
 41c:	7402                	ld	s0,32(sp)
 41e:	64e2                	ld	s1,24(sp)
 420:	6145                	addi	sp,sp,48
 422:	8082                	ret
      printf("fork failed");
 424:	00001517          	auipc	a0,0x1
 428:	92450513          	addi	a0,a0,-1756 # d48 <malloc+0x1a4>
 42c:	00000097          	auipc	ra,0x0
 430:	6ba080e7          	jalr	1722(ra) # ae6 <printf>
      exit(-1);
 434:	557d                	li	a0,-1
 436:	00000097          	auipc	ra,0x0
 43a:	300080e7          	jalr	768(ra) # 736 <exit>
    if(pid == 0){
 43e:	06400493          	li	s1,100
          readfile(file, BIG*BSIZE, BSIZE);
 442:	40000613          	li	a2,1024
 446:	65e5                	lui	a1,0x19
 448:	fd840513          	addi	a0,s0,-40
 44c:	00000097          	auipc	ra,0x0
 450:	c70080e7          	jalr	-912(ra) # bc <readfile>
        for (i = 0; i < N; i++) {
 454:	34fd                	addiw	s1,s1,-1
 456:	f4f5                	bnez	s1,442 <test1+0xc8>
        unlink(file);
 458:	fd840513          	addi	a0,s0,-40
 45c:	00000097          	auipc	ra,0x0
 460:	32a080e7          	jalr	810(ra) # 786 <unlink>
        exit(0);
 464:	4501                	li	a0,0
 466:	00000097          	auipc	ra,0x0
 46a:	2d0080e7          	jalr	720(ra) # 736 <exit>
 46e:	06400493          	li	s1,100
          readfile(file, 1, BSIZE);
 472:	40000613          	li	a2,1024
 476:	4585                	li	a1,1
 478:	fd840513          	addi	a0,s0,-40
 47c:	00000097          	auipc	ra,0x0
 480:	c40080e7          	jalr	-960(ra) # bc <readfile>
        for (i = 0; i < N; i++) {
 484:	34fd                	addiw	s1,s1,-1
 486:	f4f5                	bnez	s1,472 <test1+0xf8>
        unlink(file);
 488:	fd840513          	addi	a0,s0,-40
 48c:	00000097          	auipc	ra,0x0
 490:	2fa080e7          	jalr	762(ra) # 786 <unlink>
      exit(0);
 494:	4501                	li	a0,0
 496:	00000097          	auipc	ra,0x0
 49a:	2a0080e7          	jalr	672(ra) # 736 <exit>

000000000000049e <main>:
{
 49e:	1141                	addi	sp,sp,-16
 4a0:	e406                	sd	ra,8(sp)
 4a2:	e022                	sd	s0,0(sp)
 4a4:	0800                	addi	s0,sp,16
  test0();
 4a6:	00000097          	auipc	ra,0x0
 4aa:	cfc080e7          	jalr	-772(ra) # 1a2 <test0>
  test1();
 4ae:	00000097          	auipc	ra,0x0
 4b2:	ecc080e7          	jalr	-308(ra) # 37a <test1>
  exit(0);
 4b6:	4501                	li	a0,0
 4b8:	00000097          	auipc	ra,0x0
 4bc:	27e080e7          	jalr	638(ra) # 736 <exit>

00000000000004c0 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 4c0:	1141                	addi	sp,sp,-16
 4c2:	e422                	sd	s0,8(sp)
 4c4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 4c6:	87aa                	mv	a5,a0
 4c8:	0585                	addi	a1,a1,1
 4ca:	0785                	addi	a5,a5,1
 4cc:	fff5c703          	lbu	a4,-1(a1) # 18fff <__global_pointer$+0x17a3e>
 4d0:	fee78fa3          	sb	a4,-1(a5)
 4d4:	fb75                	bnez	a4,4c8 <strcpy+0x8>
    ;
  return os;
}
 4d6:	6422                	ld	s0,8(sp)
 4d8:	0141                	addi	sp,sp,16
 4da:	8082                	ret

00000000000004dc <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4dc:	1141                	addi	sp,sp,-16
 4de:	e422                	sd	s0,8(sp)
 4e0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 4e2:	00054783          	lbu	a5,0(a0)
 4e6:	cb91                	beqz	a5,4fa <strcmp+0x1e>
 4e8:	0005c703          	lbu	a4,0(a1)
 4ec:	00f71763          	bne	a4,a5,4fa <strcmp+0x1e>
    p++, q++;
 4f0:	0505                	addi	a0,a0,1
 4f2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 4f4:	00054783          	lbu	a5,0(a0)
 4f8:	fbe5                	bnez	a5,4e8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 4fa:	0005c503          	lbu	a0,0(a1)
}
 4fe:	40a7853b          	subw	a0,a5,a0
 502:	6422                	ld	s0,8(sp)
 504:	0141                	addi	sp,sp,16
 506:	8082                	ret

0000000000000508 <strlen>:

uint
strlen(const char *s)
{
 508:	1141                	addi	sp,sp,-16
 50a:	e422                	sd	s0,8(sp)
 50c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 50e:	00054783          	lbu	a5,0(a0)
 512:	cf91                	beqz	a5,52e <strlen+0x26>
 514:	0505                	addi	a0,a0,1
 516:	87aa                	mv	a5,a0
 518:	4685                	li	a3,1
 51a:	9e89                	subw	a3,a3,a0
 51c:	00f6853b          	addw	a0,a3,a5
 520:	0785                	addi	a5,a5,1
 522:	fff7c703          	lbu	a4,-1(a5)
 526:	fb7d                	bnez	a4,51c <strlen+0x14>
    ;
  return n;
}
 528:	6422                	ld	s0,8(sp)
 52a:	0141                	addi	sp,sp,16
 52c:	8082                	ret
  for(n = 0; s[n]; n++)
 52e:	4501                	li	a0,0
 530:	bfe5                	j	528 <strlen+0x20>

0000000000000532 <memset>:

void*
memset(void *dst, int c, uint n)
{
 532:	1141                	addi	sp,sp,-16
 534:	e422                	sd	s0,8(sp)
 536:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 538:	ce09                	beqz	a2,552 <memset+0x20>
 53a:	87aa                	mv	a5,a0
 53c:	fff6071b          	addiw	a4,a2,-1
 540:	1702                	slli	a4,a4,0x20
 542:	9301                	srli	a4,a4,0x20
 544:	0705                	addi	a4,a4,1
 546:	972a                	add	a4,a4,a0
    cdst[i] = c;
 548:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 54c:	0785                	addi	a5,a5,1
 54e:	fee79de3          	bne	a5,a4,548 <memset+0x16>
  }
  return dst;
}
 552:	6422                	ld	s0,8(sp)
 554:	0141                	addi	sp,sp,16
 556:	8082                	ret

0000000000000558 <strchr>:

char*
strchr(const char *s, char c)
{
 558:	1141                	addi	sp,sp,-16
 55a:	e422                	sd	s0,8(sp)
 55c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 55e:	00054783          	lbu	a5,0(a0)
 562:	cb99                	beqz	a5,578 <strchr+0x20>
    if(*s == c)
 564:	00f58763          	beq	a1,a5,572 <strchr+0x1a>
  for(; *s; s++)
 568:	0505                	addi	a0,a0,1
 56a:	00054783          	lbu	a5,0(a0)
 56e:	fbfd                	bnez	a5,564 <strchr+0xc>
      return (char*)s;
  return 0;
 570:	4501                	li	a0,0
}
 572:	6422                	ld	s0,8(sp)
 574:	0141                	addi	sp,sp,16
 576:	8082                	ret
  return 0;
 578:	4501                	li	a0,0
 57a:	bfe5                	j	572 <strchr+0x1a>

000000000000057c <gets>:

char*
gets(char *buf, int max)
{
 57c:	711d                	addi	sp,sp,-96
 57e:	ec86                	sd	ra,88(sp)
 580:	e8a2                	sd	s0,80(sp)
 582:	e4a6                	sd	s1,72(sp)
 584:	e0ca                	sd	s2,64(sp)
 586:	fc4e                	sd	s3,56(sp)
 588:	f852                	sd	s4,48(sp)
 58a:	f456                	sd	s5,40(sp)
 58c:	f05a                	sd	s6,32(sp)
 58e:	ec5e                	sd	s7,24(sp)
 590:	1080                	addi	s0,sp,96
 592:	8baa                	mv	s7,a0
 594:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 596:	892a                	mv	s2,a0
 598:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 59a:	4aa9                	li	s5,10
 59c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 59e:	89a6                	mv	s3,s1
 5a0:	2485                	addiw	s1,s1,1
 5a2:	0344d863          	bge	s1,s4,5d2 <gets+0x56>
    cc = read(0, &c, 1);
 5a6:	4605                	li	a2,1
 5a8:	faf40593          	addi	a1,s0,-81
 5ac:	4501                	li	a0,0
 5ae:	00000097          	auipc	ra,0x0
 5b2:	1a0080e7          	jalr	416(ra) # 74e <read>
    if(cc < 1)
 5b6:	00a05e63          	blez	a0,5d2 <gets+0x56>
    buf[i++] = c;
 5ba:	faf44783          	lbu	a5,-81(s0)
 5be:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 5c2:	01578763          	beq	a5,s5,5d0 <gets+0x54>
 5c6:	0905                	addi	s2,s2,1
 5c8:	fd679be3          	bne	a5,s6,59e <gets+0x22>
  for(i=0; i+1 < max; ){
 5cc:	89a6                	mv	s3,s1
 5ce:	a011                	j	5d2 <gets+0x56>
 5d0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 5d2:	99de                	add	s3,s3,s7
 5d4:	00098023          	sb	zero,0(s3)
  return buf;
}
 5d8:	855e                	mv	a0,s7
 5da:	60e6                	ld	ra,88(sp)
 5dc:	6446                	ld	s0,80(sp)
 5de:	64a6                	ld	s1,72(sp)
 5e0:	6906                	ld	s2,64(sp)
 5e2:	79e2                	ld	s3,56(sp)
 5e4:	7a42                	ld	s4,48(sp)
 5e6:	7aa2                	ld	s5,40(sp)
 5e8:	7b02                	ld	s6,32(sp)
 5ea:	6be2                	ld	s7,24(sp)
 5ec:	6125                	addi	sp,sp,96
 5ee:	8082                	ret

00000000000005f0 <stat>:

int
stat(const char *n, struct stat *st)
{
 5f0:	1101                	addi	sp,sp,-32
 5f2:	ec06                	sd	ra,24(sp)
 5f4:	e822                	sd	s0,16(sp)
 5f6:	e426                	sd	s1,8(sp)
 5f8:	e04a                	sd	s2,0(sp)
 5fa:	1000                	addi	s0,sp,32
 5fc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5fe:	4581                	li	a1,0
 600:	00000097          	auipc	ra,0x0
 604:	176080e7          	jalr	374(ra) # 776 <open>
  if(fd < 0)
 608:	02054563          	bltz	a0,632 <stat+0x42>
 60c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 60e:	85ca                	mv	a1,s2
 610:	00000097          	auipc	ra,0x0
 614:	17e080e7          	jalr	382(ra) # 78e <fstat>
 618:	892a                	mv	s2,a0
  close(fd);
 61a:	8526                	mv	a0,s1
 61c:	00000097          	auipc	ra,0x0
 620:	142080e7          	jalr	322(ra) # 75e <close>
  return r;
}
 624:	854a                	mv	a0,s2
 626:	60e2                	ld	ra,24(sp)
 628:	6442                	ld	s0,16(sp)
 62a:	64a2                	ld	s1,8(sp)
 62c:	6902                	ld	s2,0(sp)
 62e:	6105                	addi	sp,sp,32
 630:	8082                	ret
    return -1;
 632:	597d                	li	s2,-1
 634:	bfc5                	j	624 <stat+0x34>

0000000000000636 <atoi>:

int
atoi(const char *s)
{
 636:	1141                	addi	sp,sp,-16
 638:	e422                	sd	s0,8(sp)
 63a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 63c:	00054603          	lbu	a2,0(a0)
 640:	fd06079b          	addiw	a5,a2,-48
 644:	0ff7f793          	andi	a5,a5,255
 648:	4725                	li	a4,9
 64a:	02f76963          	bltu	a4,a5,67c <atoi+0x46>
 64e:	86aa                	mv	a3,a0
  n = 0;
 650:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 652:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 654:	0685                	addi	a3,a3,1
 656:	0025179b          	slliw	a5,a0,0x2
 65a:	9fa9                	addw	a5,a5,a0
 65c:	0017979b          	slliw	a5,a5,0x1
 660:	9fb1                	addw	a5,a5,a2
 662:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 666:	0006c603          	lbu	a2,0(a3)
 66a:	fd06071b          	addiw	a4,a2,-48
 66e:	0ff77713          	andi	a4,a4,255
 672:	fee5f1e3          	bgeu	a1,a4,654 <atoi+0x1e>
  return n;
}
 676:	6422                	ld	s0,8(sp)
 678:	0141                	addi	sp,sp,16
 67a:	8082                	ret
  n = 0;
 67c:	4501                	li	a0,0
 67e:	bfe5                	j	676 <atoi+0x40>

0000000000000680 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 680:	1141                	addi	sp,sp,-16
 682:	e422                	sd	s0,8(sp)
 684:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 686:	02b57663          	bgeu	a0,a1,6b2 <memmove+0x32>
    while(n-- > 0)
 68a:	02c05163          	blez	a2,6ac <memmove+0x2c>
 68e:	fff6079b          	addiw	a5,a2,-1
 692:	1782                	slli	a5,a5,0x20
 694:	9381                	srli	a5,a5,0x20
 696:	0785                	addi	a5,a5,1
 698:	97aa                	add	a5,a5,a0
  dst = vdst;
 69a:	872a                	mv	a4,a0
      *dst++ = *src++;
 69c:	0585                	addi	a1,a1,1
 69e:	0705                	addi	a4,a4,1
 6a0:	fff5c683          	lbu	a3,-1(a1)
 6a4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 6a8:	fee79ae3          	bne	a5,a4,69c <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 6ac:	6422                	ld	s0,8(sp)
 6ae:	0141                	addi	sp,sp,16
 6b0:	8082                	ret
    dst += n;
 6b2:	00c50733          	add	a4,a0,a2
    src += n;
 6b6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 6b8:	fec05ae3          	blez	a2,6ac <memmove+0x2c>
 6bc:	fff6079b          	addiw	a5,a2,-1
 6c0:	1782                	slli	a5,a5,0x20
 6c2:	9381                	srli	a5,a5,0x20
 6c4:	fff7c793          	not	a5,a5
 6c8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 6ca:	15fd                	addi	a1,a1,-1
 6cc:	177d                	addi	a4,a4,-1
 6ce:	0005c683          	lbu	a3,0(a1)
 6d2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 6d6:	fee79ae3          	bne	a5,a4,6ca <memmove+0x4a>
 6da:	bfc9                	j	6ac <memmove+0x2c>

00000000000006dc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 6dc:	1141                	addi	sp,sp,-16
 6de:	e422                	sd	s0,8(sp)
 6e0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 6e2:	ca05                	beqz	a2,712 <memcmp+0x36>
 6e4:	fff6069b          	addiw	a3,a2,-1
 6e8:	1682                	slli	a3,a3,0x20
 6ea:	9281                	srli	a3,a3,0x20
 6ec:	0685                	addi	a3,a3,1
 6ee:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 6f0:	00054783          	lbu	a5,0(a0)
 6f4:	0005c703          	lbu	a4,0(a1)
 6f8:	00e79863          	bne	a5,a4,708 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 6fc:	0505                	addi	a0,a0,1
    p2++;
 6fe:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 700:	fed518e3          	bne	a0,a3,6f0 <memcmp+0x14>
  }
  return 0;
 704:	4501                	li	a0,0
 706:	a019                	j	70c <memcmp+0x30>
      return *p1 - *p2;
 708:	40e7853b          	subw	a0,a5,a4
}
 70c:	6422                	ld	s0,8(sp)
 70e:	0141                	addi	sp,sp,16
 710:	8082                	ret
  return 0;
 712:	4501                	li	a0,0
 714:	bfe5                	j	70c <memcmp+0x30>

0000000000000716 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 716:	1141                	addi	sp,sp,-16
 718:	e406                	sd	ra,8(sp)
 71a:	e022                	sd	s0,0(sp)
 71c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 71e:	00000097          	auipc	ra,0x0
 722:	f62080e7          	jalr	-158(ra) # 680 <memmove>
}
 726:	60a2                	ld	ra,8(sp)
 728:	6402                	ld	s0,0(sp)
 72a:	0141                	addi	sp,sp,16
 72c:	8082                	ret

000000000000072e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 72e:	4885                	li	a7,1
 ecall
 730:	00000073          	ecall
 ret
 734:	8082                	ret

0000000000000736 <exit>:
.global exit
exit:
 li a7, SYS_exit
 736:	4889                	li	a7,2
 ecall
 738:	00000073          	ecall
 ret
 73c:	8082                	ret

000000000000073e <wait>:
.global wait
wait:
 li a7, SYS_wait
 73e:	488d                	li	a7,3
 ecall
 740:	00000073          	ecall
 ret
 744:	8082                	ret

0000000000000746 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 746:	4891                	li	a7,4
 ecall
 748:	00000073          	ecall
 ret
 74c:	8082                	ret

000000000000074e <read>:
.global read
read:
 li a7, SYS_read
 74e:	4895                	li	a7,5
 ecall
 750:	00000073          	ecall
 ret
 754:	8082                	ret

0000000000000756 <write>:
.global write
write:
 li a7, SYS_write
 756:	48c1                	li	a7,16
 ecall
 758:	00000073          	ecall
 ret
 75c:	8082                	ret

000000000000075e <close>:
.global close
close:
 li a7, SYS_close
 75e:	48d5                	li	a7,21
 ecall
 760:	00000073          	ecall
 ret
 764:	8082                	ret

0000000000000766 <kill>:
.global kill
kill:
 li a7, SYS_kill
 766:	4899                	li	a7,6
 ecall
 768:	00000073          	ecall
 ret
 76c:	8082                	ret

000000000000076e <exec>:
.global exec
exec:
 li a7, SYS_exec
 76e:	489d                	li	a7,7
 ecall
 770:	00000073          	ecall
 ret
 774:	8082                	ret

0000000000000776 <open>:
.global open
open:
 li a7, SYS_open
 776:	48bd                	li	a7,15
 ecall
 778:	00000073          	ecall
 ret
 77c:	8082                	ret

000000000000077e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 77e:	48c5                	li	a7,17
 ecall
 780:	00000073          	ecall
 ret
 784:	8082                	ret

0000000000000786 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 786:	48c9                	li	a7,18
 ecall
 788:	00000073          	ecall
 ret
 78c:	8082                	ret

000000000000078e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 78e:	48a1                	li	a7,8
 ecall
 790:	00000073          	ecall
 ret
 794:	8082                	ret

0000000000000796 <link>:
.global link
link:
 li a7, SYS_link
 796:	48cd                	li	a7,19
 ecall
 798:	00000073          	ecall
 ret
 79c:	8082                	ret

000000000000079e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 79e:	48d1                	li	a7,20
 ecall
 7a0:	00000073          	ecall
 ret
 7a4:	8082                	ret

00000000000007a6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 7a6:	48a5                	li	a7,9
 ecall
 7a8:	00000073          	ecall
 ret
 7ac:	8082                	ret

00000000000007ae <dup>:
.global dup
dup:
 li a7, SYS_dup
 7ae:	48a9                	li	a7,10
 ecall
 7b0:	00000073          	ecall
 ret
 7b4:	8082                	ret

00000000000007b6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 7b6:	48ad                	li	a7,11
 ecall
 7b8:	00000073          	ecall
 ret
 7bc:	8082                	ret

00000000000007be <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 7be:	48b1                	li	a7,12
 ecall
 7c0:	00000073          	ecall
 ret
 7c4:	8082                	ret

00000000000007c6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 7c6:	48b5                	li	a7,13
 ecall
 7c8:	00000073          	ecall
 ret
 7cc:	8082                	ret

00000000000007ce <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 7ce:	48b9                	li	a7,14
 ecall
 7d0:	00000073          	ecall
 ret
 7d4:	8082                	ret

00000000000007d6 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 7d6:	48d9                	li	a7,22
 ecall
 7d8:	00000073          	ecall
 ret
 7dc:	8082                	ret

00000000000007de <nfree>:
.global nfree
nfree:
 li a7, SYS_nfree
 7de:	48dd                	li	a7,23
 ecall
 7e0:	00000073          	ecall
 ret
 7e4:	8082                	ret

00000000000007e6 <test_rcu>:
.global test_rcu
test_rcu:
 li a7, SYS_test_rcu
 7e6:	48e1                	li	a7,24
 ecall
 7e8:	00000073          	ecall
 ret
 7ec:	8082                	ret

00000000000007ee <rcu_read_only>:
.global rcu_read_only
rcu_read_only:
 li a7, SYS_rcu_read_only
 7ee:	48e5                	li	a7,25
 ecall
 7f0:	00000073          	ecall
 ret
 7f4:	8082                	ret

00000000000007f6 <rcu_read_heavy>:
.global rcu_read_heavy
rcu_read_heavy:
 li a7, SYS_rcu_read_heavy
 7f6:	48e9                	li	a7,26
 ecall
 7f8:	00000073          	ecall
 ret
 7fc:	8082                	ret

00000000000007fe <rcu_read_write_mix>:
.global rcu_read_write_mix
rcu_read_write_mix:
 li a7, SYS_rcu_read_write_mix
 7fe:	48ed                	li	a7,27
 ecall
 800:	00000073          	ecall
 ret
 804:	8082                	ret

0000000000000806 <rcu_read_stress>:
.global rcu_read_stress
rcu_read_stress:
 li a7, SYS_rcu_read_stress
 806:	48f1                	li	a7,28
 ecall
 808:	00000073          	ecall
 ret
 80c:	8082                	ret

000000000000080e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 80e:	1101                	addi	sp,sp,-32
 810:	ec06                	sd	ra,24(sp)
 812:	e822                	sd	s0,16(sp)
 814:	1000                	addi	s0,sp,32
 816:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 81a:	4605                	li	a2,1
 81c:	fef40593          	addi	a1,s0,-17
 820:	00000097          	auipc	ra,0x0
 824:	f36080e7          	jalr	-202(ra) # 756 <write>
}
 828:	60e2                	ld	ra,24(sp)
 82a:	6442                	ld	s0,16(sp)
 82c:	6105                	addi	sp,sp,32
 82e:	8082                	ret

0000000000000830 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 830:	7139                	addi	sp,sp,-64
 832:	fc06                	sd	ra,56(sp)
 834:	f822                	sd	s0,48(sp)
 836:	f426                	sd	s1,40(sp)
 838:	f04a                	sd	s2,32(sp)
 83a:	ec4e                	sd	s3,24(sp)
 83c:	0080                	addi	s0,sp,64
 83e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 840:	c299                	beqz	a3,846 <printint+0x16>
 842:	0805c863          	bltz	a1,8d2 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 846:	2581                	sext.w	a1,a1
  neg = 0;
 848:	4881                	li	a7,0
 84a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 84e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 850:	2601                	sext.w	a2,a2
 852:	00000517          	auipc	a0,0x0
 856:	55e50513          	addi	a0,a0,1374 # db0 <digits>
 85a:	883a                	mv	a6,a4
 85c:	2705                	addiw	a4,a4,1
 85e:	02c5f7bb          	remuw	a5,a1,a2
 862:	1782                	slli	a5,a5,0x20
 864:	9381                	srli	a5,a5,0x20
 866:	97aa                	add	a5,a5,a0
 868:	0007c783          	lbu	a5,0(a5)
 86c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 870:	0005879b          	sext.w	a5,a1
 874:	02c5d5bb          	divuw	a1,a1,a2
 878:	0685                	addi	a3,a3,1
 87a:	fec7f0e3          	bgeu	a5,a2,85a <printint+0x2a>
  if(neg)
 87e:	00088b63          	beqz	a7,894 <printint+0x64>
    buf[i++] = '-';
 882:	fd040793          	addi	a5,s0,-48
 886:	973e                	add	a4,a4,a5
 888:	02d00793          	li	a5,45
 88c:	fef70823          	sb	a5,-16(a4)
 890:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 894:	02e05863          	blez	a4,8c4 <printint+0x94>
 898:	fc040793          	addi	a5,s0,-64
 89c:	00e78933          	add	s2,a5,a4
 8a0:	fff78993          	addi	s3,a5,-1
 8a4:	99ba                	add	s3,s3,a4
 8a6:	377d                	addiw	a4,a4,-1
 8a8:	1702                	slli	a4,a4,0x20
 8aa:	9301                	srli	a4,a4,0x20
 8ac:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 8b0:	fff94583          	lbu	a1,-1(s2)
 8b4:	8526                	mv	a0,s1
 8b6:	00000097          	auipc	ra,0x0
 8ba:	f58080e7          	jalr	-168(ra) # 80e <putc>
  while(--i >= 0)
 8be:	197d                	addi	s2,s2,-1
 8c0:	ff3918e3          	bne	s2,s3,8b0 <printint+0x80>
}
 8c4:	70e2                	ld	ra,56(sp)
 8c6:	7442                	ld	s0,48(sp)
 8c8:	74a2                	ld	s1,40(sp)
 8ca:	7902                	ld	s2,32(sp)
 8cc:	69e2                	ld	s3,24(sp)
 8ce:	6121                	addi	sp,sp,64
 8d0:	8082                	ret
    x = -xx;
 8d2:	40b005bb          	negw	a1,a1
    neg = 1;
 8d6:	4885                	li	a7,1
    x = -xx;
 8d8:	bf8d                	j	84a <printint+0x1a>

00000000000008da <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 8da:	7119                	addi	sp,sp,-128
 8dc:	fc86                	sd	ra,120(sp)
 8de:	f8a2                	sd	s0,112(sp)
 8e0:	f4a6                	sd	s1,104(sp)
 8e2:	f0ca                	sd	s2,96(sp)
 8e4:	ecce                	sd	s3,88(sp)
 8e6:	e8d2                	sd	s4,80(sp)
 8e8:	e4d6                	sd	s5,72(sp)
 8ea:	e0da                	sd	s6,64(sp)
 8ec:	fc5e                	sd	s7,56(sp)
 8ee:	f862                	sd	s8,48(sp)
 8f0:	f466                	sd	s9,40(sp)
 8f2:	f06a                	sd	s10,32(sp)
 8f4:	ec6e                	sd	s11,24(sp)
 8f6:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 8f8:	0005c903          	lbu	s2,0(a1)
 8fc:	18090f63          	beqz	s2,a9a <vprintf+0x1c0>
 900:	8aaa                	mv	s5,a0
 902:	8b32                	mv	s6,a2
 904:	00158493          	addi	s1,a1,1
  state = 0;
 908:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 90a:	02500a13          	li	s4,37
      if(c == 'd'){
 90e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 912:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 916:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 91a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 91e:	00000b97          	auipc	s7,0x0
 922:	492b8b93          	addi	s7,s7,1170 # db0 <digits>
 926:	a839                	j	944 <vprintf+0x6a>
        putc(fd, c);
 928:	85ca                	mv	a1,s2
 92a:	8556                	mv	a0,s5
 92c:	00000097          	auipc	ra,0x0
 930:	ee2080e7          	jalr	-286(ra) # 80e <putc>
 934:	a019                	j	93a <vprintf+0x60>
    } else if(state == '%'){
 936:	01498f63          	beq	s3,s4,954 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 93a:	0485                	addi	s1,s1,1
 93c:	fff4c903          	lbu	s2,-1(s1)
 940:	14090d63          	beqz	s2,a9a <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 944:	0009079b          	sext.w	a5,s2
    if(state == 0){
 948:	fe0997e3          	bnez	s3,936 <vprintf+0x5c>
      if(c == '%'){
 94c:	fd479ee3          	bne	a5,s4,928 <vprintf+0x4e>
        state = '%';
 950:	89be                	mv	s3,a5
 952:	b7e5                	j	93a <vprintf+0x60>
      if(c == 'd'){
 954:	05878063          	beq	a5,s8,994 <vprintf+0xba>
      } else if(c == 'l') {
 958:	05978c63          	beq	a5,s9,9b0 <vprintf+0xd6>
      } else if(c == 'x') {
 95c:	07a78863          	beq	a5,s10,9cc <vprintf+0xf2>
      } else if(c == 'p') {
 960:	09b78463          	beq	a5,s11,9e8 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 964:	07300713          	li	a4,115
 968:	0ce78663          	beq	a5,a4,a34 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 96c:	06300713          	li	a4,99
 970:	0ee78e63          	beq	a5,a4,a6c <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 974:	11478863          	beq	a5,s4,a84 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 978:	85d2                	mv	a1,s4
 97a:	8556                	mv	a0,s5
 97c:	00000097          	auipc	ra,0x0
 980:	e92080e7          	jalr	-366(ra) # 80e <putc>
        putc(fd, c);
 984:	85ca                	mv	a1,s2
 986:	8556                	mv	a0,s5
 988:	00000097          	auipc	ra,0x0
 98c:	e86080e7          	jalr	-378(ra) # 80e <putc>
      }
      state = 0;
 990:	4981                	li	s3,0
 992:	b765                	j	93a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 994:	008b0913          	addi	s2,s6,8
 998:	4685                	li	a3,1
 99a:	4629                	li	a2,10
 99c:	000b2583          	lw	a1,0(s6)
 9a0:	8556                	mv	a0,s5
 9a2:	00000097          	auipc	ra,0x0
 9a6:	e8e080e7          	jalr	-370(ra) # 830 <printint>
 9aa:	8b4a                	mv	s6,s2
      state = 0;
 9ac:	4981                	li	s3,0
 9ae:	b771                	j	93a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 9b0:	008b0913          	addi	s2,s6,8
 9b4:	4681                	li	a3,0
 9b6:	4629                	li	a2,10
 9b8:	000b2583          	lw	a1,0(s6)
 9bc:	8556                	mv	a0,s5
 9be:	00000097          	auipc	ra,0x0
 9c2:	e72080e7          	jalr	-398(ra) # 830 <printint>
 9c6:	8b4a                	mv	s6,s2
      state = 0;
 9c8:	4981                	li	s3,0
 9ca:	bf85                	j	93a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 9cc:	008b0913          	addi	s2,s6,8
 9d0:	4681                	li	a3,0
 9d2:	4641                	li	a2,16
 9d4:	000b2583          	lw	a1,0(s6)
 9d8:	8556                	mv	a0,s5
 9da:	00000097          	auipc	ra,0x0
 9de:	e56080e7          	jalr	-426(ra) # 830 <printint>
 9e2:	8b4a                	mv	s6,s2
      state = 0;
 9e4:	4981                	li	s3,0
 9e6:	bf91                	j	93a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 9e8:	008b0793          	addi	a5,s6,8
 9ec:	f8f43423          	sd	a5,-120(s0)
 9f0:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 9f4:	03000593          	li	a1,48
 9f8:	8556                	mv	a0,s5
 9fa:	00000097          	auipc	ra,0x0
 9fe:	e14080e7          	jalr	-492(ra) # 80e <putc>
  putc(fd, 'x');
 a02:	85ea                	mv	a1,s10
 a04:	8556                	mv	a0,s5
 a06:	00000097          	auipc	ra,0x0
 a0a:	e08080e7          	jalr	-504(ra) # 80e <putc>
 a0e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 a10:	03c9d793          	srli	a5,s3,0x3c
 a14:	97de                	add	a5,a5,s7
 a16:	0007c583          	lbu	a1,0(a5)
 a1a:	8556                	mv	a0,s5
 a1c:	00000097          	auipc	ra,0x0
 a20:	df2080e7          	jalr	-526(ra) # 80e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 a24:	0992                	slli	s3,s3,0x4
 a26:	397d                	addiw	s2,s2,-1
 a28:	fe0914e3          	bnez	s2,a10 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 a2c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 a30:	4981                	li	s3,0
 a32:	b721                	j	93a <vprintf+0x60>
        s = va_arg(ap, char*);
 a34:	008b0993          	addi	s3,s6,8
 a38:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 a3c:	02090163          	beqz	s2,a5e <vprintf+0x184>
        while(*s != 0){
 a40:	00094583          	lbu	a1,0(s2)
 a44:	c9a1                	beqz	a1,a94 <vprintf+0x1ba>
          putc(fd, *s);
 a46:	8556                	mv	a0,s5
 a48:	00000097          	auipc	ra,0x0
 a4c:	dc6080e7          	jalr	-570(ra) # 80e <putc>
          s++;
 a50:	0905                	addi	s2,s2,1
        while(*s != 0){
 a52:	00094583          	lbu	a1,0(s2)
 a56:	f9e5                	bnez	a1,a46 <vprintf+0x16c>
        s = va_arg(ap, char*);
 a58:	8b4e                	mv	s6,s3
      state = 0;
 a5a:	4981                	li	s3,0
 a5c:	bdf9                	j	93a <vprintf+0x60>
          s = "(null)";
 a5e:	00000917          	auipc	s2,0x0
 a62:	34a90913          	addi	s2,s2,842 # da8 <malloc+0x204>
        while(*s != 0){
 a66:	02800593          	li	a1,40
 a6a:	bff1                	j	a46 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 a6c:	008b0913          	addi	s2,s6,8
 a70:	000b4583          	lbu	a1,0(s6)
 a74:	8556                	mv	a0,s5
 a76:	00000097          	auipc	ra,0x0
 a7a:	d98080e7          	jalr	-616(ra) # 80e <putc>
 a7e:	8b4a                	mv	s6,s2
      state = 0;
 a80:	4981                	li	s3,0
 a82:	bd65                	j	93a <vprintf+0x60>
        putc(fd, c);
 a84:	85d2                	mv	a1,s4
 a86:	8556                	mv	a0,s5
 a88:	00000097          	auipc	ra,0x0
 a8c:	d86080e7          	jalr	-634(ra) # 80e <putc>
      state = 0;
 a90:	4981                	li	s3,0
 a92:	b565                	j	93a <vprintf+0x60>
        s = va_arg(ap, char*);
 a94:	8b4e                	mv	s6,s3
      state = 0;
 a96:	4981                	li	s3,0
 a98:	b54d                	j	93a <vprintf+0x60>
    }
  }
}
 a9a:	70e6                	ld	ra,120(sp)
 a9c:	7446                	ld	s0,112(sp)
 a9e:	74a6                	ld	s1,104(sp)
 aa0:	7906                	ld	s2,96(sp)
 aa2:	69e6                	ld	s3,88(sp)
 aa4:	6a46                	ld	s4,80(sp)
 aa6:	6aa6                	ld	s5,72(sp)
 aa8:	6b06                	ld	s6,64(sp)
 aaa:	7be2                	ld	s7,56(sp)
 aac:	7c42                	ld	s8,48(sp)
 aae:	7ca2                	ld	s9,40(sp)
 ab0:	7d02                	ld	s10,32(sp)
 ab2:	6de2                	ld	s11,24(sp)
 ab4:	6109                	addi	sp,sp,128
 ab6:	8082                	ret

0000000000000ab8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 ab8:	715d                	addi	sp,sp,-80
 aba:	ec06                	sd	ra,24(sp)
 abc:	e822                	sd	s0,16(sp)
 abe:	1000                	addi	s0,sp,32
 ac0:	e010                	sd	a2,0(s0)
 ac2:	e414                	sd	a3,8(s0)
 ac4:	e818                	sd	a4,16(s0)
 ac6:	ec1c                	sd	a5,24(s0)
 ac8:	03043023          	sd	a6,32(s0)
 acc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 ad0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 ad4:	8622                	mv	a2,s0
 ad6:	00000097          	auipc	ra,0x0
 ada:	e04080e7          	jalr	-508(ra) # 8da <vprintf>
}
 ade:	60e2                	ld	ra,24(sp)
 ae0:	6442                	ld	s0,16(sp)
 ae2:	6161                	addi	sp,sp,80
 ae4:	8082                	ret

0000000000000ae6 <printf>:

void
printf(const char *fmt, ...)
{
 ae6:	711d                	addi	sp,sp,-96
 ae8:	ec06                	sd	ra,24(sp)
 aea:	e822                	sd	s0,16(sp)
 aec:	1000                	addi	s0,sp,32
 aee:	e40c                	sd	a1,8(s0)
 af0:	e810                	sd	a2,16(s0)
 af2:	ec14                	sd	a3,24(s0)
 af4:	f018                	sd	a4,32(s0)
 af6:	f41c                	sd	a5,40(s0)
 af8:	03043823          	sd	a6,48(s0)
 afc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 b00:	00840613          	addi	a2,s0,8
 b04:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 b08:	85aa                	mv	a1,a0
 b0a:	4505                	li	a0,1
 b0c:	00000097          	auipc	ra,0x0
 b10:	dce080e7          	jalr	-562(ra) # 8da <vprintf>
}
 b14:	60e2                	ld	ra,24(sp)
 b16:	6442                	ld	s0,16(sp)
 b18:	6125                	addi	sp,sp,96
 b1a:	8082                	ret

0000000000000b1c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b1c:	1141                	addi	sp,sp,-16
 b1e:	e422                	sd	s0,8(sp)
 b20:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b22:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b26:	00000797          	auipc	a5,0x0
 b2a:	2a27b783          	ld	a5,674(a5) # dc8 <freep>
 b2e:	a805                	j	b5e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 b30:	4618                	lw	a4,8(a2)
 b32:	9db9                	addw	a1,a1,a4
 b34:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 b38:	6398                	ld	a4,0(a5)
 b3a:	6318                	ld	a4,0(a4)
 b3c:	fee53823          	sd	a4,-16(a0)
 b40:	a091                	j	b84 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 b42:	ff852703          	lw	a4,-8(a0)
 b46:	9e39                	addw	a2,a2,a4
 b48:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 b4a:	ff053703          	ld	a4,-16(a0)
 b4e:	e398                	sd	a4,0(a5)
 b50:	a099                	j	b96 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b52:	6398                	ld	a4,0(a5)
 b54:	00e7e463          	bltu	a5,a4,b5c <free+0x40>
 b58:	00e6ea63          	bltu	a3,a4,b6c <free+0x50>
{
 b5c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b5e:	fed7fae3          	bgeu	a5,a3,b52 <free+0x36>
 b62:	6398                	ld	a4,0(a5)
 b64:	00e6e463          	bltu	a3,a4,b6c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b68:	fee7eae3          	bltu	a5,a4,b5c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 b6c:	ff852583          	lw	a1,-8(a0)
 b70:	6390                	ld	a2,0(a5)
 b72:	02059713          	slli	a4,a1,0x20
 b76:	9301                	srli	a4,a4,0x20
 b78:	0712                	slli	a4,a4,0x4
 b7a:	9736                	add	a4,a4,a3
 b7c:	fae60ae3          	beq	a2,a4,b30 <free+0x14>
    bp->s.ptr = p->s.ptr;
 b80:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 b84:	4790                	lw	a2,8(a5)
 b86:	02061713          	slli	a4,a2,0x20
 b8a:	9301                	srli	a4,a4,0x20
 b8c:	0712                	slli	a4,a4,0x4
 b8e:	973e                	add	a4,a4,a5
 b90:	fae689e3          	beq	a3,a4,b42 <free+0x26>
  } else
    p->s.ptr = bp;
 b94:	e394                	sd	a3,0(a5)
  freep = p;
 b96:	00000717          	auipc	a4,0x0
 b9a:	22f73923          	sd	a5,562(a4) # dc8 <freep>
}
 b9e:	6422                	ld	s0,8(sp)
 ba0:	0141                	addi	sp,sp,16
 ba2:	8082                	ret

0000000000000ba4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 ba4:	7139                	addi	sp,sp,-64
 ba6:	fc06                	sd	ra,56(sp)
 ba8:	f822                	sd	s0,48(sp)
 baa:	f426                	sd	s1,40(sp)
 bac:	f04a                	sd	s2,32(sp)
 bae:	ec4e                	sd	s3,24(sp)
 bb0:	e852                	sd	s4,16(sp)
 bb2:	e456                	sd	s5,8(sp)
 bb4:	e05a                	sd	s6,0(sp)
 bb6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 bb8:	02051493          	slli	s1,a0,0x20
 bbc:	9081                	srli	s1,s1,0x20
 bbe:	04bd                	addi	s1,s1,15
 bc0:	8091                	srli	s1,s1,0x4
 bc2:	0014899b          	addiw	s3,s1,1
 bc6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 bc8:	00000517          	auipc	a0,0x0
 bcc:	20053503          	ld	a0,512(a0) # dc8 <freep>
 bd0:	c515                	beqz	a0,bfc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bd2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 bd4:	4798                	lw	a4,8(a5)
 bd6:	02977f63          	bgeu	a4,s1,c14 <malloc+0x70>
 bda:	8a4e                	mv	s4,s3
 bdc:	0009871b          	sext.w	a4,s3
 be0:	6685                	lui	a3,0x1
 be2:	00d77363          	bgeu	a4,a3,be8 <malloc+0x44>
 be6:	6a05                	lui	s4,0x1
 be8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 bec:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 bf0:	00000917          	auipc	s2,0x0
 bf4:	1d890913          	addi	s2,s2,472 # dc8 <freep>
  if(p == (char*)-1)
 bf8:	5afd                	li	s5,-1
 bfa:	a88d                	j	c6c <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 bfc:	00000797          	auipc	a5,0x0
 c00:	1d478793          	addi	a5,a5,468 # dd0 <base>
 c04:	00000717          	auipc	a4,0x0
 c08:	1cf73223          	sd	a5,452(a4) # dc8 <freep>
 c0c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 c0e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 c12:	b7e1                	j	bda <malloc+0x36>
      if(p->s.size == nunits)
 c14:	02e48b63          	beq	s1,a4,c4a <malloc+0xa6>
        p->s.size -= nunits;
 c18:	4137073b          	subw	a4,a4,s3
 c1c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 c1e:	1702                	slli	a4,a4,0x20
 c20:	9301                	srli	a4,a4,0x20
 c22:	0712                	slli	a4,a4,0x4
 c24:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 c26:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c2a:	00000717          	auipc	a4,0x0
 c2e:	18a73f23          	sd	a0,414(a4) # dc8 <freep>
      return (void*)(p + 1);
 c32:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 c36:	70e2                	ld	ra,56(sp)
 c38:	7442                	ld	s0,48(sp)
 c3a:	74a2                	ld	s1,40(sp)
 c3c:	7902                	ld	s2,32(sp)
 c3e:	69e2                	ld	s3,24(sp)
 c40:	6a42                	ld	s4,16(sp)
 c42:	6aa2                	ld	s5,8(sp)
 c44:	6b02                	ld	s6,0(sp)
 c46:	6121                	addi	sp,sp,64
 c48:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 c4a:	6398                	ld	a4,0(a5)
 c4c:	e118                	sd	a4,0(a0)
 c4e:	bff1                	j	c2a <malloc+0x86>
  hp->s.size = nu;
 c50:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 c54:	0541                	addi	a0,a0,16
 c56:	00000097          	auipc	ra,0x0
 c5a:	ec6080e7          	jalr	-314(ra) # b1c <free>
  return freep;
 c5e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 c62:	d971                	beqz	a0,c36 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c64:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c66:	4798                	lw	a4,8(a5)
 c68:	fa9776e3          	bgeu	a4,s1,c14 <malloc+0x70>
    if(p == freep)
 c6c:	00093703          	ld	a4,0(s2)
 c70:	853e                	mv	a0,a5
 c72:	fef719e3          	bne	a4,a5,c64 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 c76:	8552                	mv	a0,s4
 c78:	00000097          	auipc	ra,0x0
 c7c:	b46080e7          	jalr	-1210(ra) # 7be <sbrk>
  if(p == (char*)-1)
 c80:	fd5518e3          	bne	a0,s5,c50 <malloc+0xac>
        return 0;
 c84:	4501                	li	a0,0
 c86:	bf45                	j	c36 <malloc+0x92>
