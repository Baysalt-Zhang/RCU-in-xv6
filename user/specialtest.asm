
user/_specialtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <testnull>:
  exit(failed);
}

void
testnull(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  int fd, r;
  static char buf[32] = { 'a', 'b', 'c', 0 };

  printf("\nSTART: test /dev/null\n");
   a:	00001517          	auipc	a0,0x1
   e:	e4650513          	addi	a0,a0,-442 # e50 <malloc+0xea>
  12:	00001097          	auipc	ra,0x1
  16:	c96080e7          	jalr	-874(ra) # ca8 <printf>

  fd = open("/dev/null", O_RDWR);
  1a:	4589                	li	a1,2
  1c:	00001517          	auipc	a0,0x1
  20:	e4c50513          	addi	a0,a0,-436 # e68 <malloc+0x102>
  24:	00001097          	auipc	ra,0x1
  28:	93c080e7          	jalr	-1732(ra) # 960 <open>
  2c:	84aa                	mv	s1,a0
  if (fd < 0)
  2e:	06054b63          	bltz	a0,a4 <testnull+0xa4>
    fail("could not open /dev/null\n");

  printf("reading from /dev/null..\n");
  32:	00001517          	auipc	a0,0x1
  36:	e6e50513          	addi	a0,a0,-402 # ea0 <malloc+0x13a>
  3a:	00001097          	auipc	ra,0x1
  3e:	c6e080e7          	jalr	-914(ra) # ca8 <printf>
  r = read(fd, buf, sizeof(buf));
  42:	02000613          	li	a2,32
  46:	00001597          	auipc	a1,0x1
  4a:	36a58593          	addi	a1,a1,874 # 13b0 <buf.1300>
  4e:	8526                	mv	a0,s1
  50:	00001097          	auipc	ra,0x1
  54:	8e8080e7          	jalr	-1816(ra) # 938 <read>
  if (r != 0)
  58:	ed2d                	bnez	a0,d2 <testnull+0xd2>
    fail("read /dev/null did not return EOF\n");

  printf("writing to /dev/null..\n");
  5a:	00001517          	auipc	a0,0x1
  5e:	e9650513          	addi	a0,a0,-362 # ef0 <malloc+0x18a>
  62:	00001097          	auipc	ra,0x1
  66:	c46080e7          	jalr	-954(ra) # ca8 <printf>
  r = write(fd, buf, sizeof(buf));
  6a:	02000613          	li	a2,32
  6e:	00001597          	auipc	a1,0x1
  72:	34258593          	addi	a1,a1,834 # 13b0 <buf.1300>
  76:	8526                	mv	a0,s1
  78:	00001097          	auipc	ra,0x1
  7c:	8c8080e7          	jalr	-1848(ra) # 940 <write>
  if (r != sizeof(buf))
  80:	02000793          	li	a5,32
  84:	06f50563          	beq	a0,a5,ee <testnull+0xee>
    fail("could not write to /dev/null\n");
  88:	00001517          	auipc	a0,0x1
  8c:	e8050513          	addi	a0,a0,-384 # f08 <malloc+0x1a2>
  90:	00001097          	auipc	ra,0x1
  94:	c18080e7          	jalr	-1000(ra) # ca8 <printf>
  98:	4785                	li	a5,1
  9a:	00001717          	auipc	a4,0x1
  9e:	32f72b23          	sw	a5,822(a4) # 13d0 <failed>
  a2:	a831                	j	be <testnull+0xbe>
    fail("could not open /dev/null\n");
  a4:	00001517          	auipc	a0,0x1
  a8:	dd450513          	addi	a0,a0,-556 # e78 <malloc+0x112>
  ac:	00001097          	auipc	ra,0x1
  b0:	bfc080e7          	jalr	-1028(ra) # ca8 <printf>
  b4:	4785                	li	a5,1
  b6:	00001717          	auipc	a4,0x1
  ba:	30f72d23          	sw	a5,794(a4) # 13d0 <failed>
  if (buf[0] != 'a')
    fail("/dev/null read non-zero amount of bytes\n");

  printf("SUCCESS: test /dev/null\n");
done:
  close(fd);
  be:	8526                	mv	a0,s1
  c0:	00001097          	auipc	ra,0x1
  c4:	888080e7          	jalr	-1912(ra) # 948 <close>
}
  c8:	60e2                	ld	ra,24(sp)
  ca:	6442                	ld	s0,16(sp)
  cc:	64a2                	ld	s1,8(sp)
  ce:	6105                	addi	sp,sp,32
  d0:	8082                	ret
    fail("read /dev/null did not return EOF\n");
  d2:	00001517          	auipc	a0,0x1
  d6:	dee50513          	addi	a0,a0,-530 # ec0 <malloc+0x15a>
  da:	00001097          	auipc	ra,0x1
  de:	bce080e7          	jalr	-1074(ra) # ca8 <printf>
  e2:	4785                	li	a5,1
  e4:	00001717          	auipc	a4,0x1
  e8:	2ef72623          	sw	a5,748(a4) # 13d0 <failed>
  ec:	bfc9                	j	be <testnull+0xbe>
  printf("reading from /dev/null again..\n");
  ee:	00001517          	auipc	a0,0x1
  f2:	e4250513          	addi	a0,a0,-446 # f30 <malloc+0x1ca>
  f6:	00001097          	auipc	ra,0x1
  fa:	bb2080e7          	jalr	-1102(ra) # ca8 <printf>
  r = read(fd, buf, sizeof(buf));
  fe:	02000613          	li	a2,32
 102:	00001597          	auipc	a1,0x1
 106:	2ae58593          	addi	a1,a1,686 # 13b0 <buf.1300>
 10a:	8526                	mv	a0,s1
 10c:	00001097          	auipc	ra,0x1
 110:	82c080e7          	jalr	-2004(ra) # 938 <read>
  if (r != 0)
 114:	e51d                	bnez	a0,142 <testnull+0x142>
  if (buf[0] != 'a')
 116:	00001717          	auipc	a4,0x1
 11a:	29a74703          	lbu	a4,666(a4) # 13b0 <buf.1300>
 11e:	06100793          	li	a5,97
 122:	02f70e63          	beq	a4,a5,15e <testnull+0x15e>
    fail("/dev/null read non-zero amount of bytes\n");
 126:	00001517          	auipc	a0,0x1
 12a:	e6250513          	addi	a0,a0,-414 # f88 <malloc+0x222>
 12e:	00001097          	auipc	ra,0x1
 132:	b7a080e7          	jalr	-1158(ra) # ca8 <printf>
 136:	4785                	li	a5,1
 138:	00001717          	auipc	a4,0x1
 13c:	28f72c23          	sw	a5,664(a4) # 13d0 <failed>
 140:	bfbd                	j	be <testnull+0xbe>
    fail("read /dev/null did not return EOF after write");
 142:	00001517          	auipc	a0,0x1
 146:	e0e50513          	addi	a0,a0,-498 # f50 <malloc+0x1ea>
 14a:	00001097          	auipc	ra,0x1
 14e:	b5e080e7          	jalr	-1186(ra) # ca8 <printf>
 152:	4785                	li	a5,1
 154:	00001717          	auipc	a4,0x1
 158:	26f72e23          	sw	a5,636(a4) # 13d0 <failed>
 15c:	b78d                	j	be <testnull+0xbe>
  printf("SUCCESS: test /dev/null\n");
 15e:	00001517          	auipc	a0,0x1
 162:	e6250513          	addi	a0,a0,-414 # fc0 <malloc+0x25a>
 166:	00001097          	auipc	ra,0x1
 16a:	b42080e7          	jalr	-1214(ra) # ca8 <printf>
 16e:	bf81                	j	be <testnull+0xbe>

0000000000000170 <testzero>:

void
testzero(void)
{
 170:	7179                	addi	sp,sp,-48
 172:	f406                	sd	ra,40(sp)
 174:	f022                	sd	s0,32(sp)
 176:	ec26                	sd	s1,24(sp)
 178:	1800                	addi	s0,sp,48
  int fd, r;
  char buf[8] = {'a','b','c','d','e','f','g','h'};
 17a:	00001797          	auipc	a5,0x1
 17e:	f967b783          	ld	a5,-106(a5) # 1110 <malloc+0x3aa>
 182:	fcf43c23          	sd	a5,-40(s0)

  printf("\nSTART: test /dev/zero\n");
 186:	00001517          	auipc	a0,0x1
 18a:	e5a50513          	addi	a0,a0,-422 # fe0 <malloc+0x27a>
 18e:	00001097          	auipc	ra,0x1
 192:	b1a080e7          	jalr	-1254(ra) # ca8 <printf>

  fd = open("/dev/zero", O_RDWR);
 196:	4589                	li	a1,2
 198:	00001517          	auipc	a0,0x1
 19c:	e6050513          	addi	a0,a0,-416 # ff8 <malloc+0x292>
 1a0:	00000097          	auipc	ra,0x0
 1a4:	7c0080e7          	jalr	1984(ra) # 960 <open>
 1a8:	84aa                	mv	s1,a0
  if (fd < 0)
 1aa:	04054c63          	bltz	a0,202 <testzero+0x92>
    fail("could not open /dev/zero");

  printf("writing to /dev/zero..\n");
 1ae:	00001517          	auipc	a0,0x1
 1b2:	e8250513          	addi	a0,a0,-382 # 1030 <malloc+0x2ca>
 1b6:	00001097          	auipc	ra,0x1
 1ba:	af2080e7          	jalr	-1294(ra) # ca8 <printf>
  r = write(fd, buf, sizeof(buf));
 1be:	4621                	li	a2,8
 1c0:	fd840593          	addi	a1,s0,-40
 1c4:	8526                	mv	a0,s1
 1c6:	00000097          	auipc	ra,0x0
 1ca:	77a080e7          	jalr	1914(ra) # 940 <write>
  if (r != sizeof(buf))
 1ce:	47a1                	li	a5,8
 1d0:	04f50763          	beq	a0,a5,21e <testzero+0xae>
    fail("could not write to /dev/zero");
 1d4:	00001517          	auipc	a0,0x1
 1d8:	e7450513          	addi	a0,a0,-396 # 1048 <malloc+0x2e2>
 1dc:	00001097          	auipc	ra,0x1
 1e0:	acc080e7          	jalr	-1332(ra) # ca8 <printf>
 1e4:	4785                	li	a5,1
 1e6:	00001717          	auipc	a4,0x1
 1ea:	1ef72523          	sw	a5,490(a4) # 13d0 <failed>
      fail("reading from /dev/zero produced non-zero bytes");
  }

  printf("SUCCESS: test /dev/zero\n");
done:
  close(fd);
 1ee:	8526                	mv	a0,s1
 1f0:	00000097          	auipc	ra,0x0
 1f4:	758080e7          	jalr	1880(ra) # 948 <close>
}
 1f8:	70a2                	ld	ra,40(sp)
 1fa:	7402                	ld	s0,32(sp)
 1fc:	64e2                	ld	s1,24(sp)
 1fe:	6145                	addi	sp,sp,48
 200:	8082                	ret
    fail("could not open /dev/zero");
 202:	00001517          	auipc	a0,0x1
 206:	e0650513          	addi	a0,a0,-506 # 1008 <malloc+0x2a2>
 20a:	00001097          	auipc	ra,0x1
 20e:	a9e080e7          	jalr	-1378(ra) # ca8 <printf>
 212:	4785                	li	a5,1
 214:	00001717          	auipc	a4,0x1
 218:	1af72e23          	sw	a5,444(a4) # 13d0 <failed>
 21c:	bfc9                	j	1ee <testzero+0x7e>
  printf("reading from /dev/zero..\n");
 21e:	00001517          	auipc	a0,0x1
 222:	e5250513          	addi	a0,a0,-430 # 1070 <malloc+0x30a>
 226:	00001097          	auipc	ra,0x1
 22a:	a82080e7          	jalr	-1406(ra) # ca8 <printf>
  r = read(fd, buf, sizeof(buf));
 22e:	4621                	li	a2,8
 230:	fd840593          	addi	a1,s0,-40
 234:	8526                	mv	a0,s1
 236:	00000097          	auipc	ra,0x0
 23a:	702080e7          	jalr	1794(ra) # 938 <read>
  if (r != 8)
 23e:	4721                	li	a4,8
 240:	fd840793          	addi	a5,s0,-40
 244:	fe040693          	addi	a3,s0,-32
 248:	02e51163          	bne	a0,a4,26a <testzero+0xfa>
    if (buf[i])
 24c:	0007c703          	lbu	a4,0(a5)
 250:	eb1d                	bnez	a4,286 <testzero+0x116>
  for(int i = 0; i < sizeof(buf); i++) {
 252:	0785                	addi	a5,a5,1
 254:	fed79ce3          	bne	a5,a3,24c <testzero+0xdc>
  printf("SUCCESS: test /dev/zero\n");
 258:	00001517          	auipc	a0,0x1
 25c:	e9850513          	addi	a0,a0,-360 # 10f0 <malloc+0x38a>
 260:	00001097          	auipc	ra,0x1
 264:	a48080e7          	jalr	-1464(ra) # ca8 <printf>
 268:	b759                	j	1ee <testzero+0x7e>
    fail("could not read from /dev/zero");
 26a:	00001517          	auipc	a0,0x1
 26e:	e2650513          	addi	a0,a0,-474 # 1090 <malloc+0x32a>
 272:	00001097          	auipc	ra,0x1
 276:	a36080e7          	jalr	-1482(ra) # ca8 <printf>
 27a:	4785                	li	a5,1
 27c:	00001717          	auipc	a4,0x1
 280:	14f72a23          	sw	a5,340(a4) # 13d0 <failed>
 284:	b7ad                	j	1ee <testzero+0x7e>
      fail("reading from /dev/zero produced non-zero bytes");
 286:	00001517          	auipc	a0,0x1
 28a:	e3250513          	addi	a0,a0,-462 # 10b8 <malloc+0x352>
 28e:	00001097          	auipc	ra,0x1
 292:	a1a080e7          	jalr	-1510(ra) # ca8 <printf>
 296:	4785                	li	a5,1
 298:	00001717          	auipc	a4,0x1
 29c:	12f72c23          	sw	a5,312(a4) # 13d0 <failed>
 2a0:	b7b9                	j	1ee <testzero+0x7e>

00000000000002a2 <testuptime>:

void
testuptime(void)
{
 2a2:	7139                	addi	sp,sp,-64
 2a4:	fc06                	sd	ra,56(sp)
 2a6:	f822                	sd	s0,48(sp)
 2a8:	f426                	sd	s1,40(sp)
 2aa:	f04a                	sd	s2,32(sp)
 2ac:	ec4e                	sd	s3,24(sp)
 2ae:	0080                	addi	s0,sp,64
  int fd, r, first, second;
  char buf[16] = { 0 };
 2b0:	fc043023          	sd	zero,-64(s0)
 2b4:	fc043423          	sd	zero,-56(s0)

  printf("\nSTART: test /dev/uptime\n");
 2b8:	00001517          	auipc	a0,0x1
 2bc:	e6850513          	addi	a0,a0,-408 # 1120 <malloc+0x3ba>
 2c0:	00001097          	auipc	ra,0x1
 2c4:	9e8080e7          	jalr	-1560(ra) # ca8 <printf>

  fd = open("/dev/uptime", O_RDONLY);
 2c8:	4581                	li	a1,0
 2ca:	00001517          	auipc	a0,0x1
 2ce:	e7650513          	addi	a0,a0,-394 # 1140 <malloc+0x3da>
 2d2:	00000097          	auipc	ra,0x0
 2d6:	68e080e7          	jalr	1678(ra) # 960 <open>
 2da:	84aa                	mv	s1,a0
  if (fd < 0)
 2dc:	0e054f63          	bltz	a0,3da <testuptime+0x138>
    fail("could not open /dev/uptime");

  printf("Reading from /dev/uptime..\n");
 2e0:	00001517          	auipc	a0,0x1
 2e4:	e9850513          	addi	a0,a0,-360 # 1178 <malloc+0x412>
 2e8:	00001097          	auipc	ra,0x1
 2ec:	9c0080e7          	jalr	-1600(ra) # ca8 <printf>
  r = read(fd, buf, sizeof(buf));
 2f0:	4641                	li	a2,16
 2f2:	fc040593          	addi	a1,s0,-64
 2f6:	8526                	mv	a0,s1
 2f8:	00000097          	auipc	ra,0x0
 2fc:	640080e7          	jalr	1600(ra) # 938 <read>
  if (r <= 0)
 300:	0ea05b63          	blez	a0,3f6 <testuptime+0x154>
    fail("could not read /dev/uptime");
  first = atoi(buf);
 304:	fc040513          	addi	a0,s0,-64
 308:	00000097          	auipc	ra,0x0
 30c:	518080e7          	jalr	1304(ra) # 820 <atoi>
 310:	892a                	mv	s2,a0
  memset(buf, 0, sizeof(buf));
 312:	4641                	li	a2,16
 314:	4581                	li	a1,0
 316:	fc040513          	addi	a0,s0,-64
 31a:	00000097          	auipc	ra,0x0
 31e:	402080e7          	jalr	1026(ra) # 71c <memset>

  sleep(2);
 322:	4509                	li	a0,2
 324:	00000097          	auipc	ra,0x0
 328:	68c080e7          	jalr	1676(ra) # 9b0 <sleep>

  close(fd);
 32c:	8526                	mv	a0,s1
 32e:	00000097          	auipc	ra,0x0
 332:	61a080e7          	jalr	1562(ra) # 948 <close>
  fd = open("/dev/uptime", O_RDONLY);
 336:	4581                	li	a1,0
 338:	00001517          	auipc	a0,0x1
 33c:	e0850513          	addi	a0,a0,-504 # 1140 <malloc+0x3da>
 340:	00000097          	auipc	ra,0x0
 344:	620080e7          	jalr	1568(ra) # 960 <open>
 348:	84aa                	mv	s1,a0
  printf("Reading from /dev/uptime again..\n");
 34a:	00001517          	auipc	a0,0x1
 34e:	e7650513          	addi	a0,a0,-394 # 11c0 <malloc+0x45a>
 352:	00001097          	auipc	ra,0x1
 356:	956080e7          	jalr	-1706(ra) # ca8 <printf>
  r = read(fd, buf, sizeof(buf));
 35a:	4641                	li	a2,16
 35c:	fc040593          	addi	a1,s0,-64
 360:	8526                	mv	a0,s1
 362:	00000097          	auipc	ra,0x0
 366:	5d6080e7          	jalr	1494(ra) # 938 <read>
  if (r <= 0)
 36a:	0aa05463          	blez	a0,412 <testuptime+0x170>
    fail("could not read /dev/uptime");
  second = atoi(buf);
 36e:	fc040513          	addi	a0,s0,-64
 372:	00000097          	auipc	ra,0x0
 376:	4ae080e7          	jalr	1198(ra) # 820 <atoi>
 37a:	89aa                	mv	s3,a0

  if(first <= 0 || second <= 0 || second <= first || second - first > 50) {
 37c:	01205c63          	blez	s2,394 <testuptime+0xf2>
 380:	00a05a63          	blez	a0,394 <testuptime+0xf2>
 384:	00a95863          	bge	s2,a0,394 <testuptime+0xf2>
 388:	412507bb          	subw	a5,a0,s2
 38c:	03200713          	li	a4,50
 390:	08f75f63          	bge	a4,a5,42e <testuptime+0x18c>
    printf("expected two positive, monotonically increasing integers near each other\n");
 394:	00001517          	auipc	a0,0x1
 398:	e5450513          	addi	a0,a0,-428 # 11e8 <malloc+0x482>
 39c:	00001097          	auipc	ra,0x1
 3a0:	90c080e7          	jalr	-1780(ra) # ca8 <printf>
    printf("         got: %d %d\n", first, second);
 3a4:	864e                	mv	a2,s3
 3a6:	85ca                	mv	a1,s2
 3a8:	00001517          	auipc	a0,0x1
 3ac:	e9050513          	addi	a0,a0,-368 # 1238 <malloc+0x4d2>
 3b0:	00001097          	auipc	ra,0x1
 3b4:	8f8080e7          	jalr	-1800(ra) # ca8 <printf>
    failed = 1;
 3b8:	4785                	li	a5,1
 3ba:	00001717          	auipc	a4,0x1
 3be:	00f72b23          	sw	a5,22(a4) # 13d0 <failed>
    goto done;
  }

  printf("SUCCESS: test /dev/uptime\n");
done:
  close(fd);
 3c2:	8526                	mv	a0,s1
 3c4:	00000097          	auipc	ra,0x0
 3c8:	584080e7          	jalr	1412(ra) # 948 <close>
}
 3cc:	70e2                	ld	ra,56(sp)
 3ce:	7442                	ld	s0,48(sp)
 3d0:	74a2                	ld	s1,40(sp)
 3d2:	7902                	ld	s2,32(sp)
 3d4:	69e2                	ld	s3,24(sp)
 3d6:	6121                	addi	sp,sp,64
 3d8:	8082                	ret
    fail("could not open /dev/uptime");
 3da:	00001517          	auipc	a0,0x1
 3de:	d7650513          	addi	a0,a0,-650 # 1150 <malloc+0x3ea>
 3e2:	00001097          	auipc	ra,0x1
 3e6:	8c6080e7          	jalr	-1850(ra) # ca8 <printf>
 3ea:	4785                	li	a5,1
 3ec:	00001717          	auipc	a4,0x1
 3f0:	fef72223          	sw	a5,-28(a4) # 13d0 <failed>
 3f4:	b7f9                	j	3c2 <testuptime+0x120>
    fail("could not read /dev/uptime");
 3f6:	00001517          	auipc	a0,0x1
 3fa:	da250513          	addi	a0,a0,-606 # 1198 <malloc+0x432>
 3fe:	00001097          	auipc	ra,0x1
 402:	8aa080e7          	jalr	-1878(ra) # ca8 <printf>
 406:	4785                	li	a5,1
 408:	00001717          	auipc	a4,0x1
 40c:	fcf72423          	sw	a5,-56(a4) # 13d0 <failed>
 410:	bf4d                	j	3c2 <testuptime+0x120>
    fail("could not read /dev/uptime");
 412:	00001517          	auipc	a0,0x1
 416:	d8650513          	addi	a0,a0,-634 # 1198 <malloc+0x432>
 41a:	00001097          	auipc	ra,0x1
 41e:	88e080e7          	jalr	-1906(ra) # ca8 <printf>
 422:	4785                	li	a5,1
 424:	00001717          	auipc	a4,0x1
 428:	faf72623          	sw	a5,-84(a4) # 13d0 <failed>
 42c:	bf59                	j	3c2 <testuptime+0x120>
  printf("SUCCESS: test /dev/uptime\n");
 42e:	00001517          	auipc	a0,0x1
 432:	e2250513          	addi	a0,a0,-478 # 1250 <malloc+0x4ea>
 436:	00001097          	auipc	ra,0x1
 43a:	872080e7          	jalr	-1934(ra) # ca8 <printf>
 43e:	b751                	j	3c2 <testuptime+0x120>

0000000000000440 <testrandom>:

void
testrandom(void)
{
 440:	7139                	addi	sp,sp,-64
 442:	fc06                	sd	ra,56(sp)
 444:	f822                	sd	s0,48(sp)
 446:	f426                	sd	s1,40(sp)
 448:	f04a                	sd	s2,32(sp)
 44a:	0080                	addi	s0,sp,64
  int r = 0, fd1 = -1, fd2 = -1;
  char buf1[8], buf2[8], buf3[8], buf4[8];

  printf("\nSTART: test /dev/random\n");
 44c:	00001517          	auipc	a0,0x1
 450:	e2450513          	addi	a0,a0,-476 # 1270 <malloc+0x50a>
 454:	00001097          	auipc	ra,0x1
 458:	854080e7          	jalr	-1964(ra) # ca8 <printf>

  printf("Opening /dev/random..\n");
 45c:	00001517          	auipc	a0,0x1
 460:	e3450513          	addi	a0,a0,-460 # 1290 <malloc+0x52a>
 464:	00001097          	auipc	ra,0x1
 468:	844080e7          	jalr	-1980(ra) # ca8 <printf>
  fd1 = open("/dev/random", O_RDONLY);
 46c:	4581                	li	a1,0
 46e:	00001517          	auipc	a0,0x1
 472:	e3a50513          	addi	a0,a0,-454 # 12a8 <malloc+0x542>
 476:	00000097          	auipc	ra,0x0
 47a:	4ea080e7          	jalr	1258(ra) # 960 <open>
 47e:	84aa                	mv	s1,a0
  if(fd1 < 0)
 480:	06054e63          	bltz	a0,4fc <testrandom+0xbc>
    fail("Failed to open /dev/random");
  fd2 = open("/dev/random", O_RDONLY);
 484:	4581                	li	a1,0
 486:	00001517          	auipc	a0,0x1
 48a:	e2250513          	addi	a0,a0,-478 # 12a8 <malloc+0x542>
 48e:	00000097          	auipc	ra,0x0
 492:	4d2080e7          	jalr	1234(ra) # 960 <open>
 496:	892a                	mv	s2,a0
  if (fd2 < 0)
 498:	08054163          	bltz	a0,51a <testrandom+0xda>
    fail("Failed to open /dev/random");


  printf("reading from /dev/random four times..\n");
 49c:	00001517          	auipc	a0,0x1
 4a0:	e4450513          	addi	a0,a0,-444 # 12e0 <malloc+0x57a>
 4a4:	00001097          	auipc	ra,0x1
 4a8:	804080e7          	jalr	-2044(ra) # ca8 <printf>
  r = read(fd1, buf1, sizeof(buf1));
 4ac:	4621                	li	a2,8
 4ae:	fd840593          	addi	a1,s0,-40
 4b2:	8526                	mv	a0,s1
 4b4:	00000097          	auipc	ra,0x0
 4b8:	484080e7          	jalr	1156(ra) # 938 <read>
  if (r != sizeof(buf1)) fail("Failed to read /dev/random");
 4bc:	47a1                	li	a5,8
 4be:	06f50c63          	beq	a0,a5,536 <testrandom+0xf6>
 4c2:	00001517          	auipc	a0,0x1
 4c6:	e4650513          	addi	a0,a0,-442 # 1308 <malloc+0x5a2>
 4ca:	00000097          	auipc	ra,0x0
 4ce:	7de080e7          	jalr	2014(ra) # ca8 <printf>
 4d2:	4785                	li	a5,1
 4d4:	00001717          	auipc	a4,0x1
 4d8:	eef72e23          	sw	a5,-260(a4) # 13d0 <failed>
  if(!r)
    fail("Reads of /dev/random should return random bytes..");

  printf("SUCCESS: test /dev/random\n");
done:
  close(fd1);
 4dc:	8526                	mv	a0,s1
 4de:	00000097          	auipc	ra,0x0
 4e2:	46a080e7          	jalr	1130(ra) # 948 <close>
  close(fd2);
 4e6:	854a                	mv	a0,s2
 4e8:	00000097          	auipc	ra,0x0
 4ec:	460080e7          	jalr	1120(ra) # 948 <close>
 4f0:	70e2                	ld	ra,56(sp)
 4f2:	7442                	ld	s0,48(sp)
 4f4:	74a2                	ld	s1,40(sp)
 4f6:	7902                	ld	s2,32(sp)
 4f8:	6121                	addi	sp,sp,64
 4fa:	8082                	ret
    fail("Failed to open /dev/random");
 4fc:	00001517          	auipc	a0,0x1
 500:	dbc50513          	addi	a0,a0,-580 # 12b8 <malloc+0x552>
 504:	00000097          	auipc	ra,0x0
 508:	7a4080e7          	jalr	1956(ra) # ca8 <printf>
 50c:	4785                	li	a5,1
 50e:	00001717          	auipc	a4,0x1
 512:	ecf72123          	sw	a5,-318(a4) # 13d0 <failed>
  int r = 0, fd1 = -1, fd2 = -1;
 516:	597d                	li	s2,-1
    fail("Failed to open /dev/random");
 518:	b7d1                	j	4dc <testrandom+0x9c>
    fail("Failed to open /dev/random");
 51a:	00001517          	auipc	a0,0x1
 51e:	d9e50513          	addi	a0,a0,-610 # 12b8 <malloc+0x552>
 522:	00000097          	auipc	ra,0x0
 526:	786080e7          	jalr	1926(ra) # ca8 <printf>
 52a:	4785                	li	a5,1
 52c:	00001717          	auipc	a4,0x1
 530:	eaf72223          	sw	a5,-348(a4) # 13d0 <failed>
 534:	b765                	j	4dc <testrandom+0x9c>
  r = read(fd1, buf2, sizeof(buf2));
 536:	4621                	li	a2,8
 538:	fd040593          	addi	a1,s0,-48
 53c:	8526                	mv	a0,s1
 53e:	00000097          	auipc	ra,0x0
 542:	3fa080e7          	jalr	1018(ra) # 938 <read>
  if (r != sizeof(buf2)) fail("Failed to read /dev/random");
 546:	47a1                	li	a5,8
 548:	02f50063          	beq	a0,a5,568 <testrandom+0x128>
 54c:	00001517          	auipc	a0,0x1
 550:	dbc50513          	addi	a0,a0,-580 # 1308 <malloc+0x5a2>
 554:	00000097          	auipc	ra,0x0
 558:	754080e7          	jalr	1876(ra) # ca8 <printf>
 55c:	4785                	li	a5,1
 55e:	00001717          	auipc	a4,0x1
 562:	e6f72923          	sw	a5,-398(a4) # 13d0 <failed>
 566:	bf9d                	j	4dc <testrandom+0x9c>
  r = read(fd2, buf3, sizeof(buf3));
 568:	4621                	li	a2,8
 56a:	fc840593          	addi	a1,s0,-56
 56e:	854a                	mv	a0,s2
 570:	00000097          	auipc	ra,0x0
 574:	3c8080e7          	jalr	968(ra) # 938 <read>
  if (r != sizeof(buf3)) fail("Failed to read /dev/random");
 578:	47a1                	li	a5,8
 57a:	02f50063          	beq	a0,a5,59a <testrandom+0x15a>
 57e:	00001517          	auipc	a0,0x1
 582:	d8a50513          	addi	a0,a0,-630 # 1308 <malloc+0x5a2>
 586:	00000097          	auipc	ra,0x0
 58a:	722080e7          	jalr	1826(ra) # ca8 <printf>
 58e:	4785                	li	a5,1
 590:	00001717          	auipc	a4,0x1
 594:	e4f72023          	sw	a5,-448(a4) # 13d0 <failed>
 598:	b791                	j	4dc <testrandom+0x9c>
  r = read(fd2, buf4, sizeof(buf4));
 59a:	4621                	li	a2,8
 59c:	fc040593          	addi	a1,s0,-64
 5a0:	854a                	mv	a0,s2
 5a2:	00000097          	auipc	ra,0x0
 5a6:	396080e7          	jalr	918(ra) # 938 <read>
  if (r != sizeof(buf4)) fail("Failed to read /dev/random");
 5aa:	47a1                	li	a5,8
 5ac:	02f50063          	beq	a0,a5,5cc <testrandom+0x18c>
 5b0:	00001517          	auipc	a0,0x1
 5b4:	d5850513          	addi	a0,a0,-680 # 1308 <malloc+0x5a2>
 5b8:	00000097          	auipc	ra,0x0
 5bc:	6f0080e7          	jalr	1776(ra) # ca8 <printf>
 5c0:	4785                	li	a5,1
 5c2:	00001717          	auipc	a4,0x1
 5c6:	e0f72723          	sw	a5,-498(a4) # 13d0 <failed>
 5ca:	bf09                	j	4dc <testrandom+0x9c>
  r = memcmp(buf1, buf2, 8) &&
 5cc:	4621                	li	a2,8
 5ce:	fd040593          	addi	a1,s0,-48
 5d2:	fd840513          	addi	a0,s0,-40
 5d6:	00000097          	auipc	ra,0x0
 5da:	2f0080e7          	jalr	752(ra) # 8c6 <memcmp>
      memcmp(buf2, buf4, 8) &&
 5de:	c919                	beqz	a0,5f4 <testrandom+0x1b4>
      memcmp(buf1, buf3, 8) &&
 5e0:	4621                	li	a2,8
 5e2:	fc840593          	addi	a1,s0,-56
 5e6:	fd840513          	addi	a0,s0,-40
 5ea:	00000097          	auipc	ra,0x0
 5ee:	2dc080e7          	jalr	732(ra) # 8c6 <memcmp>
  r = memcmp(buf1, buf2, 8) &&
 5f2:	ed19                	bnez	a0,610 <testrandom+0x1d0>
    fail("Reads of /dev/random should return random bytes..");
 5f4:	00001517          	auipc	a0,0x1
 5f8:	d5c50513          	addi	a0,a0,-676 # 1350 <malloc+0x5ea>
 5fc:	00000097          	auipc	ra,0x0
 600:	6ac080e7          	jalr	1708(ra) # ca8 <printf>
 604:	4785                	li	a5,1
 606:	00001717          	auipc	a4,0x1
 60a:	dcf72523          	sw	a5,-566(a4) # 13d0 <failed>
 60e:	b5f9                	j	4dc <testrandom+0x9c>
      memcmp(buf1, buf4, 8) &&
 610:	4621                	li	a2,8
 612:	fc040593          	addi	a1,s0,-64
 616:	fd840513          	addi	a0,s0,-40
 61a:	00000097          	auipc	ra,0x0
 61e:	2ac080e7          	jalr	684(ra) # 8c6 <memcmp>
      memcmp(buf1, buf3, 8) &&
 622:	d969                	beqz	a0,5f4 <testrandom+0x1b4>
      memcmp(buf2, buf3, 8) &&
 624:	4621                	li	a2,8
 626:	fc840593          	addi	a1,s0,-56
 62a:	fd040513          	addi	a0,s0,-48
 62e:	00000097          	auipc	ra,0x0
 632:	298080e7          	jalr	664(ra) # 8c6 <memcmp>
      memcmp(buf1, buf4, 8) &&
 636:	dd5d                	beqz	a0,5f4 <testrandom+0x1b4>
      memcmp(buf2, buf4, 8) &&
 638:	4621                	li	a2,8
 63a:	fc040593          	addi	a1,s0,-64
 63e:	fd040513          	addi	a0,s0,-48
 642:	00000097          	auipc	ra,0x0
 646:	284080e7          	jalr	644(ra) # 8c6 <memcmp>
      memcmp(buf2, buf3, 8) &&
 64a:	d54d                	beqz	a0,5f4 <testrandom+0x1b4>
      memcmp(buf3, buf4, 8);
 64c:	4621                	li	a2,8
 64e:	fc040593          	addi	a1,s0,-64
 652:	fc840513          	addi	a0,s0,-56
 656:	00000097          	auipc	ra,0x0
 65a:	270080e7          	jalr	624(ra) # 8c6 <memcmp>
      memcmp(buf2, buf4, 8) &&
 65e:	d959                	beqz	a0,5f4 <testrandom+0x1b4>
  printf("SUCCESS: test /dev/random\n");
 660:	00001517          	auipc	a0,0x1
 664:	cd050513          	addi	a0,a0,-816 # 1330 <malloc+0x5ca>
 668:	00000097          	auipc	ra,0x0
 66c:	640080e7          	jalr	1600(ra) # ca8 <printf>
 670:	b5b5                	j	4dc <testrandom+0x9c>

0000000000000672 <main>:
{
 672:	1141                	addi	sp,sp,-16
 674:	e406                	sd	ra,8(sp)
 676:	e022                	sd	s0,0(sp)
 678:	0800                	addi	s0,sp,16
  testnull();
 67a:	00000097          	auipc	ra,0x0
 67e:	986080e7          	jalr	-1658(ra) # 0 <testnull>
  testzero();
 682:	00000097          	auipc	ra,0x0
 686:	aee080e7          	jalr	-1298(ra) # 170 <testzero>
  testuptime();
 68a:	00000097          	auipc	ra,0x0
 68e:	c18080e7          	jalr	-1000(ra) # 2a2 <testuptime>
  testrandom();
 692:	00000097          	auipc	ra,0x0
 696:	dae080e7          	jalr	-594(ra) # 440 <testrandom>
  exit(failed);
 69a:	00001517          	auipc	a0,0x1
 69e:	d3652503          	lw	a0,-714(a0) # 13d0 <failed>
 6a2:	00000097          	auipc	ra,0x0
 6a6:	27e080e7          	jalr	638(ra) # 920 <exit>

00000000000006aa <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 6aa:	1141                	addi	sp,sp,-16
 6ac:	e422                	sd	s0,8(sp)
 6ae:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 6b0:	87aa                	mv	a5,a0
 6b2:	0585                	addi	a1,a1,1
 6b4:	0785                	addi	a5,a5,1
 6b6:	fff5c703          	lbu	a4,-1(a1)
 6ba:	fee78fa3          	sb	a4,-1(a5)
 6be:	fb75                	bnez	a4,6b2 <strcpy+0x8>
    ;
  return os;
}
 6c0:	6422                	ld	s0,8(sp)
 6c2:	0141                	addi	sp,sp,16
 6c4:	8082                	ret

00000000000006c6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 6c6:	1141                	addi	sp,sp,-16
 6c8:	e422                	sd	s0,8(sp)
 6ca:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 6cc:	00054783          	lbu	a5,0(a0)
 6d0:	cb91                	beqz	a5,6e4 <strcmp+0x1e>
 6d2:	0005c703          	lbu	a4,0(a1)
 6d6:	00f71763          	bne	a4,a5,6e4 <strcmp+0x1e>
    p++, q++;
 6da:	0505                	addi	a0,a0,1
 6dc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 6de:	00054783          	lbu	a5,0(a0)
 6e2:	fbe5                	bnez	a5,6d2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 6e4:	0005c503          	lbu	a0,0(a1)
}
 6e8:	40a7853b          	subw	a0,a5,a0
 6ec:	6422                	ld	s0,8(sp)
 6ee:	0141                	addi	sp,sp,16
 6f0:	8082                	ret

00000000000006f2 <strlen>:

uint
strlen(const char *s)
{
 6f2:	1141                	addi	sp,sp,-16
 6f4:	e422                	sd	s0,8(sp)
 6f6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 6f8:	00054783          	lbu	a5,0(a0)
 6fc:	cf91                	beqz	a5,718 <strlen+0x26>
 6fe:	0505                	addi	a0,a0,1
 700:	87aa                	mv	a5,a0
 702:	4685                	li	a3,1
 704:	9e89                	subw	a3,a3,a0
 706:	00f6853b          	addw	a0,a3,a5
 70a:	0785                	addi	a5,a5,1
 70c:	fff7c703          	lbu	a4,-1(a5)
 710:	fb7d                	bnez	a4,706 <strlen+0x14>
    ;
  return n;
}
 712:	6422                	ld	s0,8(sp)
 714:	0141                	addi	sp,sp,16
 716:	8082                	ret
  for(n = 0; s[n]; n++)
 718:	4501                	li	a0,0
 71a:	bfe5                	j	712 <strlen+0x20>

000000000000071c <memset>:

void*
memset(void *dst, int c, uint n)
{
 71c:	1141                	addi	sp,sp,-16
 71e:	e422                	sd	s0,8(sp)
 720:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 722:	ce09                	beqz	a2,73c <memset+0x20>
 724:	87aa                	mv	a5,a0
 726:	fff6071b          	addiw	a4,a2,-1
 72a:	1702                	slli	a4,a4,0x20
 72c:	9301                	srli	a4,a4,0x20
 72e:	0705                	addi	a4,a4,1
 730:	972a                	add	a4,a4,a0
    cdst[i] = c;
 732:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 736:	0785                	addi	a5,a5,1
 738:	fee79de3          	bne	a5,a4,732 <memset+0x16>
  }
  return dst;
}
 73c:	6422                	ld	s0,8(sp)
 73e:	0141                	addi	sp,sp,16
 740:	8082                	ret

0000000000000742 <strchr>:

char*
strchr(const char *s, char c)
{
 742:	1141                	addi	sp,sp,-16
 744:	e422                	sd	s0,8(sp)
 746:	0800                	addi	s0,sp,16
  for(; *s; s++)
 748:	00054783          	lbu	a5,0(a0)
 74c:	cb99                	beqz	a5,762 <strchr+0x20>
    if(*s == c)
 74e:	00f58763          	beq	a1,a5,75c <strchr+0x1a>
  for(; *s; s++)
 752:	0505                	addi	a0,a0,1
 754:	00054783          	lbu	a5,0(a0)
 758:	fbfd                	bnez	a5,74e <strchr+0xc>
      return (char*)s;
  return 0;
 75a:	4501                	li	a0,0
}
 75c:	6422                	ld	s0,8(sp)
 75e:	0141                	addi	sp,sp,16
 760:	8082                	ret
  return 0;
 762:	4501                	li	a0,0
 764:	bfe5                	j	75c <strchr+0x1a>

0000000000000766 <gets>:

char*
gets(char *buf, int max)
{
 766:	711d                	addi	sp,sp,-96
 768:	ec86                	sd	ra,88(sp)
 76a:	e8a2                	sd	s0,80(sp)
 76c:	e4a6                	sd	s1,72(sp)
 76e:	e0ca                	sd	s2,64(sp)
 770:	fc4e                	sd	s3,56(sp)
 772:	f852                	sd	s4,48(sp)
 774:	f456                	sd	s5,40(sp)
 776:	f05a                	sd	s6,32(sp)
 778:	ec5e                	sd	s7,24(sp)
 77a:	1080                	addi	s0,sp,96
 77c:	8baa                	mv	s7,a0
 77e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 780:	892a                	mv	s2,a0
 782:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 784:	4aa9                	li	s5,10
 786:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 788:	89a6                	mv	s3,s1
 78a:	2485                	addiw	s1,s1,1
 78c:	0344d863          	bge	s1,s4,7bc <gets+0x56>
    cc = read(0, &c, 1);
 790:	4605                	li	a2,1
 792:	faf40593          	addi	a1,s0,-81
 796:	4501                	li	a0,0
 798:	00000097          	auipc	ra,0x0
 79c:	1a0080e7          	jalr	416(ra) # 938 <read>
    if(cc < 1)
 7a0:	00a05e63          	blez	a0,7bc <gets+0x56>
    buf[i++] = c;
 7a4:	faf44783          	lbu	a5,-81(s0)
 7a8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 7ac:	01578763          	beq	a5,s5,7ba <gets+0x54>
 7b0:	0905                	addi	s2,s2,1
 7b2:	fd679be3          	bne	a5,s6,788 <gets+0x22>
  for(i=0; i+1 < max; ){
 7b6:	89a6                	mv	s3,s1
 7b8:	a011                	j	7bc <gets+0x56>
 7ba:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 7bc:	99de                	add	s3,s3,s7
 7be:	00098023          	sb	zero,0(s3)
  return buf;
}
 7c2:	855e                	mv	a0,s7
 7c4:	60e6                	ld	ra,88(sp)
 7c6:	6446                	ld	s0,80(sp)
 7c8:	64a6                	ld	s1,72(sp)
 7ca:	6906                	ld	s2,64(sp)
 7cc:	79e2                	ld	s3,56(sp)
 7ce:	7a42                	ld	s4,48(sp)
 7d0:	7aa2                	ld	s5,40(sp)
 7d2:	7b02                	ld	s6,32(sp)
 7d4:	6be2                	ld	s7,24(sp)
 7d6:	6125                	addi	sp,sp,96
 7d8:	8082                	ret

00000000000007da <stat>:

int
stat(const char *n, struct stat *st)
{
 7da:	1101                	addi	sp,sp,-32
 7dc:	ec06                	sd	ra,24(sp)
 7de:	e822                	sd	s0,16(sp)
 7e0:	e426                	sd	s1,8(sp)
 7e2:	e04a                	sd	s2,0(sp)
 7e4:	1000                	addi	s0,sp,32
 7e6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 7e8:	4581                	li	a1,0
 7ea:	00000097          	auipc	ra,0x0
 7ee:	176080e7          	jalr	374(ra) # 960 <open>
  if(fd < 0)
 7f2:	02054563          	bltz	a0,81c <stat+0x42>
 7f6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 7f8:	85ca                	mv	a1,s2
 7fa:	00000097          	auipc	ra,0x0
 7fe:	17e080e7          	jalr	382(ra) # 978 <fstat>
 802:	892a                	mv	s2,a0
  close(fd);
 804:	8526                	mv	a0,s1
 806:	00000097          	auipc	ra,0x0
 80a:	142080e7          	jalr	322(ra) # 948 <close>
  return r;
}
 80e:	854a                	mv	a0,s2
 810:	60e2                	ld	ra,24(sp)
 812:	6442                	ld	s0,16(sp)
 814:	64a2                	ld	s1,8(sp)
 816:	6902                	ld	s2,0(sp)
 818:	6105                	addi	sp,sp,32
 81a:	8082                	ret
    return -1;
 81c:	597d                	li	s2,-1
 81e:	bfc5                	j	80e <stat+0x34>

0000000000000820 <atoi>:

int
atoi(const char *s)
{
 820:	1141                	addi	sp,sp,-16
 822:	e422                	sd	s0,8(sp)
 824:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 826:	00054603          	lbu	a2,0(a0)
 82a:	fd06079b          	addiw	a5,a2,-48
 82e:	0ff7f793          	andi	a5,a5,255
 832:	4725                	li	a4,9
 834:	02f76963          	bltu	a4,a5,866 <atoi+0x46>
 838:	86aa                	mv	a3,a0
  n = 0;
 83a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 83c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 83e:	0685                	addi	a3,a3,1
 840:	0025179b          	slliw	a5,a0,0x2
 844:	9fa9                	addw	a5,a5,a0
 846:	0017979b          	slliw	a5,a5,0x1
 84a:	9fb1                	addw	a5,a5,a2
 84c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 850:	0006c603          	lbu	a2,0(a3)
 854:	fd06071b          	addiw	a4,a2,-48
 858:	0ff77713          	andi	a4,a4,255
 85c:	fee5f1e3          	bgeu	a1,a4,83e <atoi+0x1e>
  return n;
}
 860:	6422                	ld	s0,8(sp)
 862:	0141                	addi	sp,sp,16
 864:	8082                	ret
  n = 0;
 866:	4501                	li	a0,0
 868:	bfe5                	j	860 <atoi+0x40>

000000000000086a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 86a:	1141                	addi	sp,sp,-16
 86c:	e422                	sd	s0,8(sp)
 86e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 870:	02b57663          	bgeu	a0,a1,89c <memmove+0x32>
    while(n-- > 0)
 874:	02c05163          	blez	a2,896 <memmove+0x2c>
 878:	fff6079b          	addiw	a5,a2,-1
 87c:	1782                	slli	a5,a5,0x20
 87e:	9381                	srli	a5,a5,0x20
 880:	0785                	addi	a5,a5,1
 882:	97aa                	add	a5,a5,a0
  dst = vdst;
 884:	872a                	mv	a4,a0
      *dst++ = *src++;
 886:	0585                	addi	a1,a1,1
 888:	0705                	addi	a4,a4,1
 88a:	fff5c683          	lbu	a3,-1(a1)
 88e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 892:	fee79ae3          	bne	a5,a4,886 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 896:	6422                	ld	s0,8(sp)
 898:	0141                	addi	sp,sp,16
 89a:	8082                	ret
    dst += n;
 89c:	00c50733          	add	a4,a0,a2
    src += n;
 8a0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 8a2:	fec05ae3          	blez	a2,896 <memmove+0x2c>
 8a6:	fff6079b          	addiw	a5,a2,-1
 8aa:	1782                	slli	a5,a5,0x20
 8ac:	9381                	srli	a5,a5,0x20
 8ae:	fff7c793          	not	a5,a5
 8b2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 8b4:	15fd                	addi	a1,a1,-1
 8b6:	177d                	addi	a4,a4,-1
 8b8:	0005c683          	lbu	a3,0(a1)
 8bc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 8c0:	fee79ae3          	bne	a5,a4,8b4 <memmove+0x4a>
 8c4:	bfc9                	j	896 <memmove+0x2c>

00000000000008c6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 8c6:	1141                	addi	sp,sp,-16
 8c8:	e422                	sd	s0,8(sp)
 8ca:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 8cc:	ca05                	beqz	a2,8fc <memcmp+0x36>
 8ce:	fff6069b          	addiw	a3,a2,-1
 8d2:	1682                	slli	a3,a3,0x20
 8d4:	9281                	srli	a3,a3,0x20
 8d6:	0685                	addi	a3,a3,1
 8d8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 8da:	00054783          	lbu	a5,0(a0)
 8de:	0005c703          	lbu	a4,0(a1)
 8e2:	00e79863          	bne	a5,a4,8f2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 8e6:	0505                	addi	a0,a0,1
    p2++;
 8e8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 8ea:	fed518e3          	bne	a0,a3,8da <memcmp+0x14>
  }
  return 0;
 8ee:	4501                	li	a0,0
 8f0:	a019                	j	8f6 <memcmp+0x30>
      return *p1 - *p2;
 8f2:	40e7853b          	subw	a0,a5,a4
}
 8f6:	6422                	ld	s0,8(sp)
 8f8:	0141                	addi	sp,sp,16
 8fa:	8082                	ret
  return 0;
 8fc:	4501                	li	a0,0
 8fe:	bfe5                	j	8f6 <memcmp+0x30>

0000000000000900 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 900:	1141                	addi	sp,sp,-16
 902:	e406                	sd	ra,8(sp)
 904:	e022                	sd	s0,0(sp)
 906:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 908:	00000097          	auipc	ra,0x0
 90c:	f62080e7          	jalr	-158(ra) # 86a <memmove>
}
 910:	60a2                	ld	ra,8(sp)
 912:	6402                	ld	s0,0(sp)
 914:	0141                	addi	sp,sp,16
 916:	8082                	ret

0000000000000918 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 918:	4885                	li	a7,1
 ecall
 91a:	00000073          	ecall
 ret
 91e:	8082                	ret

0000000000000920 <exit>:
.global exit
exit:
 li a7, SYS_exit
 920:	4889                	li	a7,2
 ecall
 922:	00000073          	ecall
 ret
 926:	8082                	ret

0000000000000928 <wait>:
.global wait
wait:
 li a7, SYS_wait
 928:	488d                	li	a7,3
 ecall
 92a:	00000073          	ecall
 ret
 92e:	8082                	ret

0000000000000930 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 930:	4891                	li	a7,4
 ecall
 932:	00000073          	ecall
 ret
 936:	8082                	ret

0000000000000938 <read>:
.global read
read:
 li a7, SYS_read
 938:	4895                	li	a7,5
 ecall
 93a:	00000073          	ecall
 ret
 93e:	8082                	ret

0000000000000940 <write>:
.global write
write:
 li a7, SYS_write
 940:	48c1                	li	a7,16
 ecall
 942:	00000073          	ecall
 ret
 946:	8082                	ret

0000000000000948 <close>:
.global close
close:
 li a7, SYS_close
 948:	48d5                	li	a7,21
 ecall
 94a:	00000073          	ecall
 ret
 94e:	8082                	ret

0000000000000950 <kill>:
.global kill
kill:
 li a7, SYS_kill
 950:	4899                	li	a7,6
 ecall
 952:	00000073          	ecall
 ret
 956:	8082                	ret

0000000000000958 <exec>:
.global exec
exec:
 li a7, SYS_exec
 958:	489d                	li	a7,7
 ecall
 95a:	00000073          	ecall
 ret
 95e:	8082                	ret

0000000000000960 <open>:
.global open
open:
 li a7, SYS_open
 960:	48bd                	li	a7,15
 ecall
 962:	00000073          	ecall
 ret
 966:	8082                	ret

0000000000000968 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 968:	48c5                	li	a7,17
 ecall
 96a:	00000073          	ecall
 ret
 96e:	8082                	ret

0000000000000970 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 970:	48c9                	li	a7,18
 ecall
 972:	00000073          	ecall
 ret
 976:	8082                	ret

0000000000000978 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 978:	48a1                	li	a7,8
 ecall
 97a:	00000073          	ecall
 ret
 97e:	8082                	ret

0000000000000980 <link>:
.global link
link:
 li a7, SYS_link
 980:	48cd                	li	a7,19
 ecall
 982:	00000073          	ecall
 ret
 986:	8082                	ret

0000000000000988 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 988:	48d1                	li	a7,20
 ecall
 98a:	00000073          	ecall
 ret
 98e:	8082                	ret

0000000000000990 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 990:	48a5                	li	a7,9
 ecall
 992:	00000073          	ecall
 ret
 996:	8082                	ret

0000000000000998 <dup>:
.global dup
dup:
 li a7, SYS_dup
 998:	48a9                	li	a7,10
 ecall
 99a:	00000073          	ecall
 ret
 99e:	8082                	ret

00000000000009a0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 9a0:	48ad                	li	a7,11
 ecall
 9a2:	00000073          	ecall
 ret
 9a6:	8082                	ret

00000000000009a8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 9a8:	48b1                	li	a7,12
 ecall
 9aa:	00000073          	ecall
 ret
 9ae:	8082                	ret

00000000000009b0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 9b0:	48b5                	li	a7,13
 ecall
 9b2:	00000073          	ecall
 ret
 9b6:	8082                	ret

00000000000009b8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 9b8:	48b9                	li	a7,14
 ecall
 9ba:	00000073          	ecall
 ret
 9be:	8082                	ret

00000000000009c0 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 9c0:	48d9                	li	a7,22
 ecall
 9c2:	00000073          	ecall
 ret
 9c6:	8082                	ret

00000000000009c8 <nfree>:
.global nfree
nfree:
 li a7, SYS_nfree
 9c8:	48dd                	li	a7,23
 ecall
 9ca:	00000073          	ecall
 ret
 9ce:	8082                	ret

00000000000009d0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 9d0:	1101                	addi	sp,sp,-32
 9d2:	ec06                	sd	ra,24(sp)
 9d4:	e822                	sd	s0,16(sp)
 9d6:	1000                	addi	s0,sp,32
 9d8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 9dc:	4605                	li	a2,1
 9de:	fef40593          	addi	a1,s0,-17
 9e2:	00000097          	auipc	ra,0x0
 9e6:	f5e080e7          	jalr	-162(ra) # 940 <write>
}
 9ea:	60e2                	ld	ra,24(sp)
 9ec:	6442                	ld	s0,16(sp)
 9ee:	6105                	addi	sp,sp,32
 9f0:	8082                	ret

00000000000009f2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 9f2:	7139                	addi	sp,sp,-64
 9f4:	fc06                	sd	ra,56(sp)
 9f6:	f822                	sd	s0,48(sp)
 9f8:	f426                	sd	s1,40(sp)
 9fa:	f04a                	sd	s2,32(sp)
 9fc:	ec4e                	sd	s3,24(sp)
 9fe:	0080                	addi	s0,sp,64
 a00:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 a02:	c299                	beqz	a3,a08 <printint+0x16>
 a04:	0805c863          	bltz	a1,a94 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 a08:	2581                	sext.w	a1,a1
  neg = 0;
 a0a:	4881                	li	a7,0
 a0c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 a10:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 a12:	2601                	sext.w	a2,a2
 a14:	00001517          	auipc	a0,0x1
 a18:	98450513          	addi	a0,a0,-1660 # 1398 <digits>
 a1c:	883a                	mv	a6,a4
 a1e:	2705                	addiw	a4,a4,1
 a20:	02c5f7bb          	remuw	a5,a1,a2
 a24:	1782                	slli	a5,a5,0x20
 a26:	9381                	srli	a5,a5,0x20
 a28:	97aa                	add	a5,a5,a0
 a2a:	0007c783          	lbu	a5,0(a5)
 a2e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 a32:	0005879b          	sext.w	a5,a1
 a36:	02c5d5bb          	divuw	a1,a1,a2
 a3a:	0685                	addi	a3,a3,1
 a3c:	fec7f0e3          	bgeu	a5,a2,a1c <printint+0x2a>
  if(neg)
 a40:	00088b63          	beqz	a7,a56 <printint+0x64>
    buf[i++] = '-';
 a44:	fd040793          	addi	a5,s0,-48
 a48:	973e                	add	a4,a4,a5
 a4a:	02d00793          	li	a5,45
 a4e:	fef70823          	sb	a5,-16(a4)
 a52:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 a56:	02e05863          	blez	a4,a86 <printint+0x94>
 a5a:	fc040793          	addi	a5,s0,-64
 a5e:	00e78933          	add	s2,a5,a4
 a62:	fff78993          	addi	s3,a5,-1
 a66:	99ba                	add	s3,s3,a4
 a68:	377d                	addiw	a4,a4,-1
 a6a:	1702                	slli	a4,a4,0x20
 a6c:	9301                	srli	a4,a4,0x20
 a6e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 a72:	fff94583          	lbu	a1,-1(s2)
 a76:	8526                	mv	a0,s1
 a78:	00000097          	auipc	ra,0x0
 a7c:	f58080e7          	jalr	-168(ra) # 9d0 <putc>
  while(--i >= 0)
 a80:	197d                	addi	s2,s2,-1
 a82:	ff3918e3          	bne	s2,s3,a72 <printint+0x80>
}
 a86:	70e2                	ld	ra,56(sp)
 a88:	7442                	ld	s0,48(sp)
 a8a:	74a2                	ld	s1,40(sp)
 a8c:	7902                	ld	s2,32(sp)
 a8e:	69e2                	ld	s3,24(sp)
 a90:	6121                	addi	sp,sp,64
 a92:	8082                	ret
    x = -xx;
 a94:	40b005bb          	negw	a1,a1
    neg = 1;
 a98:	4885                	li	a7,1
    x = -xx;
 a9a:	bf8d                	j	a0c <printint+0x1a>

0000000000000a9c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 a9c:	7119                	addi	sp,sp,-128
 a9e:	fc86                	sd	ra,120(sp)
 aa0:	f8a2                	sd	s0,112(sp)
 aa2:	f4a6                	sd	s1,104(sp)
 aa4:	f0ca                	sd	s2,96(sp)
 aa6:	ecce                	sd	s3,88(sp)
 aa8:	e8d2                	sd	s4,80(sp)
 aaa:	e4d6                	sd	s5,72(sp)
 aac:	e0da                	sd	s6,64(sp)
 aae:	fc5e                	sd	s7,56(sp)
 ab0:	f862                	sd	s8,48(sp)
 ab2:	f466                	sd	s9,40(sp)
 ab4:	f06a                	sd	s10,32(sp)
 ab6:	ec6e                	sd	s11,24(sp)
 ab8:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 aba:	0005c903          	lbu	s2,0(a1)
 abe:	18090f63          	beqz	s2,c5c <vprintf+0x1c0>
 ac2:	8aaa                	mv	s5,a0
 ac4:	8b32                	mv	s6,a2
 ac6:	00158493          	addi	s1,a1,1
  state = 0;
 aca:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 acc:	02500a13          	li	s4,37
      if(c == 'd'){
 ad0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 ad4:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 ad8:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 adc:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 ae0:	00001b97          	auipc	s7,0x1
 ae4:	8b8b8b93          	addi	s7,s7,-1864 # 1398 <digits>
 ae8:	a839                	j	b06 <vprintf+0x6a>
        putc(fd, c);
 aea:	85ca                	mv	a1,s2
 aec:	8556                	mv	a0,s5
 aee:	00000097          	auipc	ra,0x0
 af2:	ee2080e7          	jalr	-286(ra) # 9d0 <putc>
 af6:	a019                	j	afc <vprintf+0x60>
    } else if(state == '%'){
 af8:	01498f63          	beq	s3,s4,b16 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 afc:	0485                	addi	s1,s1,1
 afe:	fff4c903          	lbu	s2,-1(s1)
 b02:	14090d63          	beqz	s2,c5c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 b06:	0009079b          	sext.w	a5,s2
    if(state == 0){
 b0a:	fe0997e3          	bnez	s3,af8 <vprintf+0x5c>
      if(c == '%'){
 b0e:	fd479ee3          	bne	a5,s4,aea <vprintf+0x4e>
        state = '%';
 b12:	89be                	mv	s3,a5
 b14:	b7e5                	j	afc <vprintf+0x60>
      if(c == 'd'){
 b16:	05878063          	beq	a5,s8,b56 <vprintf+0xba>
      } else if(c == 'l') {
 b1a:	05978c63          	beq	a5,s9,b72 <vprintf+0xd6>
      } else if(c == 'x') {
 b1e:	07a78863          	beq	a5,s10,b8e <vprintf+0xf2>
      } else if(c == 'p') {
 b22:	09b78463          	beq	a5,s11,baa <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 b26:	07300713          	li	a4,115
 b2a:	0ce78663          	beq	a5,a4,bf6 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 b2e:	06300713          	li	a4,99
 b32:	0ee78e63          	beq	a5,a4,c2e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 b36:	11478863          	beq	a5,s4,c46 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 b3a:	85d2                	mv	a1,s4
 b3c:	8556                	mv	a0,s5
 b3e:	00000097          	auipc	ra,0x0
 b42:	e92080e7          	jalr	-366(ra) # 9d0 <putc>
        putc(fd, c);
 b46:	85ca                	mv	a1,s2
 b48:	8556                	mv	a0,s5
 b4a:	00000097          	auipc	ra,0x0
 b4e:	e86080e7          	jalr	-378(ra) # 9d0 <putc>
      }
      state = 0;
 b52:	4981                	li	s3,0
 b54:	b765                	j	afc <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 b56:	008b0913          	addi	s2,s6,8
 b5a:	4685                	li	a3,1
 b5c:	4629                	li	a2,10
 b5e:	000b2583          	lw	a1,0(s6)
 b62:	8556                	mv	a0,s5
 b64:	00000097          	auipc	ra,0x0
 b68:	e8e080e7          	jalr	-370(ra) # 9f2 <printint>
 b6c:	8b4a                	mv	s6,s2
      state = 0;
 b6e:	4981                	li	s3,0
 b70:	b771                	j	afc <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 b72:	008b0913          	addi	s2,s6,8
 b76:	4681                	li	a3,0
 b78:	4629                	li	a2,10
 b7a:	000b2583          	lw	a1,0(s6)
 b7e:	8556                	mv	a0,s5
 b80:	00000097          	auipc	ra,0x0
 b84:	e72080e7          	jalr	-398(ra) # 9f2 <printint>
 b88:	8b4a                	mv	s6,s2
      state = 0;
 b8a:	4981                	li	s3,0
 b8c:	bf85                	j	afc <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 b8e:	008b0913          	addi	s2,s6,8
 b92:	4681                	li	a3,0
 b94:	4641                	li	a2,16
 b96:	000b2583          	lw	a1,0(s6)
 b9a:	8556                	mv	a0,s5
 b9c:	00000097          	auipc	ra,0x0
 ba0:	e56080e7          	jalr	-426(ra) # 9f2 <printint>
 ba4:	8b4a                	mv	s6,s2
      state = 0;
 ba6:	4981                	li	s3,0
 ba8:	bf91                	j	afc <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 baa:	008b0793          	addi	a5,s6,8
 bae:	f8f43423          	sd	a5,-120(s0)
 bb2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 bb6:	03000593          	li	a1,48
 bba:	8556                	mv	a0,s5
 bbc:	00000097          	auipc	ra,0x0
 bc0:	e14080e7          	jalr	-492(ra) # 9d0 <putc>
  putc(fd, 'x');
 bc4:	85ea                	mv	a1,s10
 bc6:	8556                	mv	a0,s5
 bc8:	00000097          	auipc	ra,0x0
 bcc:	e08080e7          	jalr	-504(ra) # 9d0 <putc>
 bd0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 bd2:	03c9d793          	srli	a5,s3,0x3c
 bd6:	97de                	add	a5,a5,s7
 bd8:	0007c583          	lbu	a1,0(a5)
 bdc:	8556                	mv	a0,s5
 bde:	00000097          	auipc	ra,0x0
 be2:	df2080e7          	jalr	-526(ra) # 9d0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 be6:	0992                	slli	s3,s3,0x4
 be8:	397d                	addiw	s2,s2,-1
 bea:	fe0914e3          	bnez	s2,bd2 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 bee:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 bf2:	4981                	li	s3,0
 bf4:	b721                	j	afc <vprintf+0x60>
        s = va_arg(ap, char*);
 bf6:	008b0993          	addi	s3,s6,8
 bfa:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 bfe:	02090163          	beqz	s2,c20 <vprintf+0x184>
        while(*s != 0){
 c02:	00094583          	lbu	a1,0(s2)
 c06:	c9a1                	beqz	a1,c56 <vprintf+0x1ba>
          putc(fd, *s);
 c08:	8556                	mv	a0,s5
 c0a:	00000097          	auipc	ra,0x0
 c0e:	dc6080e7          	jalr	-570(ra) # 9d0 <putc>
          s++;
 c12:	0905                	addi	s2,s2,1
        while(*s != 0){
 c14:	00094583          	lbu	a1,0(s2)
 c18:	f9e5                	bnez	a1,c08 <vprintf+0x16c>
        s = va_arg(ap, char*);
 c1a:	8b4e                	mv	s6,s3
      state = 0;
 c1c:	4981                	li	s3,0
 c1e:	bdf9                	j	afc <vprintf+0x60>
          s = "(null)";
 c20:	00000917          	auipc	s2,0x0
 c24:	77090913          	addi	s2,s2,1904 # 1390 <malloc+0x62a>
        while(*s != 0){
 c28:	02800593          	li	a1,40
 c2c:	bff1                	j	c08 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 c2e:	008b0913          	addi	s2,s6,8
 c32:	000b4583          	lbu	a1,0(s6)
 c36:	8556                	mv	a0,s5
 c38:	00000097          	auipc	ra,0x0
 c3c:	d98080e7          	jalr	-616(ra) # 9d0 <putc>
 c40:	8b4a                	mv	s6,s2
      state = 0;
 c42:	4981                	li	s3,0
 c44:	bd65                	j	afc <vprintf+0x60>
        putc(fd, c);
 c46:	85d2                	mv	a1,s4
 c48:	8556                	mv	a0,s5
 c4a:	00000097          	auipc	ra,0x0
 c4e:	d86080e7          	jalr	-634(ra) # 9d0 <putc>
      state = 0;
 c52:	4981                	li	s3,0
 c54:	b565                	j	afc <vprintf+0x60>
        s = va_arg(ap, char*);
 c56:	8b4e                	mv	s6,s3
      state = 0;
 c58:	4981                	li	s3,0
 c5a:	b54d                	j	afc <vprintf+0x60>
    }
  }
}
 c5c:	70e6                	ld	ra,120(sp)
 c5e:	7446                	ld	s0,112(sp)
 c60:	74a6                	ld	s1,104(sp)
 c62:	7906                	ld	s2,96(sp)
 c64:	69e6                	ld	s3,88(sp)
 c66:	6a46                	ld	s4,80(sp)
 c68:	6aa6                	ld	s5,72(sp)
 c6a:	6b06                	ld	s6,64(sp)
 c6c:	7be2                	ld	s7,56(sp)
 c6e:	7c42                	ld	s8,48(sp)
 c70:	7ca2                	ld	s9,40(sp)
 c72:	7d02                	ld	s10,32(sp)
 c74:	6de2                	ld	s11,24(sp)
 c76:	6109                	addi	sp,sp,128
 c78:	8082                	ret

0000000000000c7a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 c7a:	715d                	addi	sp,sp,-80
 c7c:	ec06                	sd	ra,24(sp)
 c7e:	e822                	sd	s0,16(sp)
 c80:	1000                	addi	s0,sp,32
 c82:	e010                	sd	a2,0(s0)
 c84:	e414                	sd	a3,8(s0)
 c86:	e818                	sd	a4,16(s0)
 c88:	ec1c                	sd	a5,24(s0)
 c8a:	03043023          	sd	a6,32(s0)
 c8e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 c92:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 c96:	8622                	mv	a2,s0
 c98:	00000097          	auipc	ra,0x0
 c9c:	e04080e7          	jalr	-508(ra) # a9c <vprintf>
}
 ca0:	60e2                	ld	ra,24(sp)
 ca2:	6442                	ld	s0,16(sp)
 ca4:	6161                	addi	sp,sp,80
 ca6:	8082                	ret

0000000000000ca8 <printf>:

void
printf(const char *fmt, ...)
{
 ca8:	711d                	addi	sp,sp,-96
 caa:	ec06                	sd	ra,24(sp)
 cac:	e822                	sd	s0,16(sp)
 cae:	1000                	addi	s0,sp,32
 cb0:	e40c                	sd	a1,8(s0)
 cb2:	e810                	sd	a2,16(s0)
 cb4:	ec14                	sd	a3,24(s0)
 cb6:	f018                	sd	a4,32(s0)
 cb8:	f41c                	sd	a5,40(s0)
 cba:	03043823          	sd	a6,48(s0)
 cbe:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 cc2:	00840613          	addi	a2,s0,8
 cc6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 cca:	85aa                	mv	a1,a0
 ccc:	4505                	li	a0,1
 cce:	00000097          	auipc	ra,0x0
 cd2:	dce080e7          	jalr	-562(ra) # a9c <vprintf>
}
 cd6:	60e2                	ld	ra,24(sp)
 cd8:	6442                	ld	s0,16(sp)
 cda:	6125                	addi	sp,sp,96
 cdc:	8082                	ret

0000000000000cde <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 cde:	1141                	addi	sp,sp,-16
 ce0:	e422                	sd	s0,8(sp)
 ce2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 ce4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ce8:	00000797          	auipc	a5,0x0
 cec:	6f07b783          	ld	a5,1776(a5) # 13d8 <freep>
 cf0:	a805                	j	d20 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 cf2:	4618                	lw	a4,8(a2)
 cf4:	9db9                	addw	a1,a1,a4
 cf6:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 cfa:	6398                	ld	a4,0(a5)
 cfc:	6318                	ld	a4,0(a4)
 cfe:	fee53823          	sd	a4,-16(a0)
 d02:	a091                	j	d46 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 d04:	ff852703          	lw	a4,-8(a0)
 d08:	9e39                	addw	a2,a2,a4
 d0a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 d0c:	ff053703          	ld	a4,-16(a0)
 d10:	e398                	sd	a4,0(a5)
 d12:	a099                	j	d58 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d14:	6398                	ld	a4,0(a5)
 d16:	00e7e463          	bltu	a5,a4,d1e <free+0x40>
 d1a:	00e6ea63          	bltu	a3,a4,d2e <free+0x50>
{
 d1e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 d20:	fed7fae3          	bgeu	a5,a3,d14 <free+0x36>
 d24:	6398                	ld	a4,0(a5)
 d26:	00e6e463          	bltu	a3,a4,d2e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d2a:	fee7eae3          	bltu	a5,a4,d1e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 d2e:	ff852583          	lw	a1,-8(a0)
 d32:	6390                	ld	a2,0(a5)
 d34:	02059713          	slli	a4,a1,0x20
 d38:	9301                	srli	a4,a4,0x20
 d3a:	0712                	slli	a4,a4,0x4
 d3c:	9736                	add	a4,a4,a3
 d3e:	fae60ae3          	beq	a2,a4,cf2 <free+0x14>
    bp->s.ptr = p->s.ptr;
 d42:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 d46:	4790                	lw	a2,8(a5)
 d48:	02061713          	slli	a4,a2,0x20
 d4c:	9301                	srli	a4,a4,0x20
 d4e:	0712                	slli	a4,a4,0x4
 d50:	973e                	add	a4,a4,a5
 d52:	fae689e3          	beq	a3,a4,d04 <free+0x26>
  } else
    p->s.ptr = bp;
 d56:	e394                	sd	a3,0(a5)
  freep = p;
 d58:	00000717          	auipc	a4,0x0
 d5c:	68f73023          	sd	a5,1664(a4) # 13d8 <freep>
}
 d60:	6422                	ld	s0,8(sp)
 d62:	0141                	addi	sp,sp,16
 d64:	8082                	ret

0000000000000d66 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 d66:	7139                	addi	sp,sp,-64
 d68:	fc06                	sd	ra,56(sp)
 d6a:	f822                	sd	s0,48(sp)
 d6c:	f426                	sd	s1,40(sp)
 d6e:	f04a                	sd	s2,32(sp)
 d70:	ec4e                	sd	s3,24(sp)
 d72:	e852                	sd	s4,16(sp)
 d74:	e456                	sd	s5,8(sp)
 d76:	e05a                	sd	s6,0(sp)
 d78:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d7a:	02051493          	slli	s1,a0,0x20
 d7e:	9081                	srli	s1,s1,0x20
 d80:	04bd                	addi	s1,s1,15
 d82:	8091                	srli	s1,s1,0x4
 d84:	0014899b          	addiw	s3,s1,1
 d88:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 d8a:	00000517          	auipc	a0,0x0
 d8e:	64e53503          	ld	a0,1614(a0) # 13d8 <freep>
 d92:	c515                	beqz	a0,dbe <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d94:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 d96:	4798                	lw	a4,8(a5)
 d98:	02977f63          	bgeu	a4,s1,dd6 <malloc+0x70>
 d9c:	8a4e                	mv	s4,s3
 d9e:	0009871b          	sext.w	a4,s3
 da2:	6685                	lui	a3,0x1
 da4:	00d77363          	bgeu	a4,a3,daa <malloc+0x44>
 da8:	6a05                	lui	s4,0x1
 daa:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 dae:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 db2:	00000917          	auipc	s2,0x0
 db6:	62690913          	addi	s2,s2,1574 # 13d8 <freep>
  if(p == (char*)-1)
 dba:	5afd                	li	s5,-1
 dbc:	a88d                	j	e2e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 dbe:	00000797          	auipc	a5,0x0
 dc2:	62278793          	addi	a5,a5,1570 # 13e0 <base>
 dc6:	00000717          	auipc	a4,0x0
 dca:	60f73923          	sd	a5,1554(a4) # 13d8 <freep>
 dce:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 dd0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 dd4:	b7e1                	j	d9c <malloc+0x36>
      if(p->s.size == nunits)
 dd6:	02e48b63          	beq	s1,a4,e0c <malloc+0xa6>
        p->s.size -= nunits;
 dda:	4137073b          	subw	a4,a4,s3
 dde:	c798                	sw	a4,8(a5)
        p += p->s.size;
 de0:	1702                	slli	a4,a4,0x20
 de2:	9301                	srli	a4,a4,0x20
 de4:	0712                	slli	a4,a4,0x4
 de6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 de8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 dec:	00000717          	auipc	a4,0x0
 df0:	5ea73623          	sd	a0,1516(a4) # 13d8 <freep>
      return (void*)(p + 1);
 df4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 df8:	70e2                	ld	ra,56(sp)
 dfa:	7442                	ld	s0,48(sp)
 dfc:	74a2                	ld	s1,40(sp)
 dfe:	7902                	ld	s2,32(sp)
 e00:	69e2                	ld	s3,24(sp)
 e02:	6a42                	ld	s4,16(sp)
 e04:	6aa2                	ld	s5,8(sp)
 e06:	6b02                	ld	s6,0(sp)
 e08:	6121                	addi	sp,sp,64
 e0a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 e0c:	6398                	ld	a4,0(a5)
 e0e:	e118                	sd	a4,0(a0)
 e10:	bff1                	j	dec <malloc+0x86>
  hp->s.size = nu;
 e12:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 e16:	0541                	addi	a0,a0,16
 e18:	00000097          	auipc	ra,0x0
 e1c:	ec6080e7          	jalr	-314(ra) # cde <free>
  return freep;
 e20:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 e24:	d971                	beqz	a0,df8 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e26:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 e28:	4798                	lw	a4,8(a5)
 e2a:	fa9776e3          	bgeu	a4,s1,dd6 <malloc+0x70>
    if(p == freep)
 e2e:	00093703          	ld	a4,0(s2)
 e32:	853e                	mv	a0,a5
 e34:	fef719e3          	bne	a4,a5,e26 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 e38:	8552                	mv	a0,s4
 e3a:	00000097          	auipc	ra,0x0
 e3e:	b6e080e7          	jalr	-1170(ra) # 9a8 <sbrk>
  if(p == (char*)-1)
 e42:	fd5518e3          	bne	a0,s5,e12 <malloc+0xac>
        return 0;
 e46:	4501                	li	a0,0
 e48:	bf45                	j	df8 <malloc+0x92>
