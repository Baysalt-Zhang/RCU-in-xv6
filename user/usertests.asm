
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <createtest>:
}

// many creates, followed by unlink test
void
createtest(char *s)
{
       0:	7179                	addi	sp,sp,-48
       2:	f406                	sd	ra,40(sp)
       4:	f022                	sd	s0,32(sp)
       6:	ec26                	sd	s1,24(sp)
       8:	e84a                	sd	s2,16(sp)
       a:	e44e                	sd	s3,8(sp)
       c:	1800                	addi	s0,sp,48
  int i, fd;
  enum { N=52 };

  name[0] = 'a';
       e:	00007797          	auipc	a5,0x7
      12:	02278793          	addi	a5,a5,34 # 7030 <name>
      16:	06100713          	li	a4,97
      1a:	00e78023          	sb	a4,0(a5)
  name[2] = '\0';
      1e:	00078123          	sb	zero,2(a5)
      22:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
    name[1] = '0' + i;
      26:	893e                	mv	s2,a5
  for(i = 0; i < N; i++){
      28:	06400993          	li	s3,100
    name[1] = '0' + i;
      2c:	009900a3          	sb	s1,1(s2)
    fd = open(name, O_CREATE|O_RDWR);
      30:	20200593          	li	a1,514
      34:	854a                	mv	a0,s2
      36:	00005097          	auipc	ra,0x5
      3a:	8c2080e7          	jalr	-1854(ra) # 48f8 <open>
    close(fd);
      3e:	00005097          	auipc	ra,0x5
      42:	8a2080e7          	jalr	-1886(ra) # 48e0 <close>
  for(i = 0; i < N; i++){
      46:	2485                	addiw	s1,s1,1
      48:	0ff4f493          	andi	s1,s1,255
      4c:	ff3490e3          	bne	s1,s3,2c <createtest+0x2c>
  }
  name[0] = 'a';
      50:	00007797          	auipc	a5,0x7
      54:	fe078793          	addi	a5,a5,-32 # 7030 <name>
      58:	06100713          	li	a4,97
      5c:	00e78023          	sb	a4,0(a5)
  name[2] = '\0';
      60:	00078123          	sb	zero,2(a5)
      64:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
    name[1] = '0' + i;
      68:	893e                	mv	s2,a5
  for(i = 0; i < N; i++){
      6a:	06400993          	li	s3,100
    name[1] = '0' + i;
      6e:	009900a3          	sb	s1,1(s2)
    unlink(name);
      72:	854a                	mv	a0,s2
      74:	00005097          	auipc	ra,0x5
      78:	894080e7          	jalr	-1900(ra) # 4908 <unlink>
  for(i = 0; i < N; i++){
      7c:	2485                	addiw	s1,s1,1
      7e:	0ff4f493          	andi	s1,s1,255
      82:	ff3496e3          	bne	s1,s3,6e <createtest+0x6e>
  }
}
      86:	70a2                	ld	ra,40(sp)
      88:	7402                	ld	s0,32(sp)
      8a:	64e2                	ld	s1,24(sp)
      8c:	6942                	ld	s2,16(sp)
      8e:	69a2                	ld	s3,8(sp)
      90:	6145                	addi	sp,sp,48
      92:	8082                	ret

0000000000000094 <truncate1>:
{
      94:	711d                	addi	sp,sp,-96
      96:	ec86                	sd	ra,88(sp)
      98:	e8a2                	sd	s0,80(sp)
      9a:	e4a6                	sd	s1,72(sp)
      9c:	e0ca                	sd	s2,64(sp)
      9e:	fc4e                	sd	s3,56(sp)
      a0:	f852                	sd	s4,48(sp)
      a2:	f456                	sd	s5,40(sp)
      a4:	1080                	addi	s0,sp,96
      a6:	8aaa                	mv	s5,a0
  unlink("truncfile");
      a8:	00005517          	auipc	a0,0x5
      ac:	00850513          	addi	a0,a0,8 # 50b0 <malloc+0x38a>
      b0:	00005097          	auipc	ra,0x5
      b4:	858080e7          	jalr	-1960(ra) # 4908 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
      b8:	60100593          	li	a1,1537
      bc:	00005517          	auipc	a0,0x5
      c0:	ff450513          	addi	a0,a0,-12 # 50b0 <malloc+0x38a>
      c4:	00005097          	auipc	ra,0x5
      c8:	834080e7          	jalr	-1996(ra) # 48f8 <open>
      cc:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
      ce:	4611                	li	a2,4
      d0:	00005597          	auipc	a1,0x5
      d4:	ff058593          	addi	a1,a1,-16 # 50c0 <malloc+0x39a>
      d8:	00005097          	auipc	ra,0x5
      dc:	800080e7          	jalr	-2048(ra) # 48d8 <write>
  close(fd1);
      e0:	8526                	mv	a0,s1
      e2:	00004097          	auipc	ra,0x4
      e6:	7fe080e7          	jalr	2046(ra) # 48e0 <close>
  int fd2 = open("truncfile", O_RDONLY);
      ea:	4581                	li	a1,0
      ec:	00005517          	auipc	a0,0x5
      f0:	fc450513          	addi	a0,a0,-60 # 50b0 <malloc+0x38a>
      f4:	00005097          	auipc	ra,0x5
      f8:	804080e7          	jalr	-2044(ra) # 48f8 <open>
      fc:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
      fe:	02000613          	li	a2,32
     102:	fa040593          	addi	a1,s0,-96
     106:	00004097          	auipc	ra,0x4
     10a:	7ca080e7          	jalr	1994(ra) # 48d0 <read>
  if(n != 4){
     10e:	4791                	li	a5,4
     110:	0cf51e63          	bne	a0,a5,1ec <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     114:	40100593          	li	a1,1025
     118:	00005517          	auipc	a0,0x5
     11c:	f9850513          	addi	a0,a0,-104 # 50b0 <malloc+0x38a>
     120:	00004097          	auipc	ra,0x4
     124:	7d8080e7          	jalr	2008(ra) # 48f8 <open>
     128:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     12a:	4581                	li	a1,0
     12c:	00005517          	auipc	a0,0x5
     130:	f8450513          	addi	a0,a0,-124 # 50b0 <malloc+0x38a>
     134:	00004097          	auipc	ra,0x4
     138:	7c4080e7          	jalr	1988(ra) # 48f8 <open>
     13c:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     13e:	02000613          	li	a2,32
     142:	fa040593          	addi	a1,s0,-96
     146:	00004097          	auipc	ra,0x4
     14a:	78a080e7          	jalr	1930(ra) # 48d0 <read>
     14e:	8a2a                	mv	s4,a0
  if(n != 0){
     150:	ed4d                	bnez	a0,20a <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     152:	02000613          	li	a2,32
     156:	fa040593          	addi	a1,s0,-96
     15a:	8526                	mv	a0,s1
     15c:	00004097          	auipc	ra,0x4
     160:	774080e7          	jalr	1908(ra) # 48d0 <read>
     164:	8a2a                	mv	s4,a0
  if(n != 0){
     166:	e971                	bnez	a0,23a <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     168:	4619                	li	a2,6
     16a:	00005597          	auipc	a1,0x5
     16e:	fbe58593          	addi	a1,a1,-66 # 5128 <malloc+0x402>
     172:	854e                	mv	a0,s3
     174:	00004097          	auipc	ra,0x4
     178:	764080e7          	jalr	1892(ra) # 48d8 <write>
  n = read(fd3, buf, sizeof(buf));
     17c:	02000613          	li	a2,32
     180:	fa040593          	addi	a1,s0,-96
     184:	854a                	mv	a0,s2
     186:	00004097          	auipc	ra,0x4
     18a:	74a080e7          	jalr	1866(ra) # 48d0 <read>
  if(n != 6){
     18e:	4799                	li	a5,6
     190:	0cf51d63          	bne	a0,a5,26a <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     194:	02000613          	li	a2,32
     198:	fa040593          	addi	a1,s0,-96
     19c:	8526                	mv	a0,s1
     19e:	00004097          	auipc	ra,0x4
     1a2:	732080e7          	jalr	1842(ra) # 48d0 <read>
  if(n != 2){
     1a6:	4789                	li	a5,2
     1a8:	0ef51063          	bne	a0,a5,288 <truncate1+0x1f4>
  unlink("truncfile");
     1ac:	00005517          	auipc	a0,0x5
     1b0:	f0450513          	addi	a0,a0,-252 # 50b0 <malloc+0x38a>
     1b4:	00004097          	auipc	ra,0x4
     1b8:	754080e7          	jalr	1876(ra) # 4908 <unlink>
  close(fd1);
     1bc:	854e                	mv	a0,s3
     1be:	00004097          	auipc	ra,0x4
     1c2:	722080e7          	jalr	1826(ra) # 48e0 <close>
  close(fd2);
     1c6:	8526                	mv	a0,s1
     1c8:	00004097          	auipc	ra,0x4
     1cc:	718080e7          	jalr	1816(ra) # 48e0 <close>
  close(fd3);
     1d0:	854a                	mv	a0,s2
     1d2:	00004097          	auipc	ra,0x4
     1d6:	70e080e7          	jalr	1806(ra) # 48e0 <close>
}
     1da:	60e6                	ld	ra,88(sp)
     1dc:	6446                	ld	s0,80(sp)
     1de:	64a6                	ld	s1,72(sp)
     1e0:	6906                	ld	s2,64(sp)
     1e2:	79e2                	ld	s3,56(sp)
     1e4:	7a42                	ld	s4,48(sp)
     1e6:	7aa2                	ld	s5,40(sp)
     1e8:	6125                	addi	sp,sp,96
     1ea:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     1ec:	862a                	mv	a2,a0
     1ee:	85d6                	mv	a1,s5
     1f0:	00005517          	auipc	a0,0x5
     1f4:	ed850513          	addi	a0,a0,-296 # 50c8 <malloc+0x3a2>
     1f8:	00005097          	auipc	ra,0x5
     1fc:	a70080e7          	jalr	-1424(ra) # 4c68 <printf>
    exit(1);
     200:	4505                	li	a0,1
     202:	00004097          	auipc	ra,0x4
     206:	6b6080e7          	jalr	1718(ra) # 48b8 <exit>
    printf("aaa fd3=%d\n", fd3);
     20a:	85ca                	mv	a1,s2
     20c:	00005517          	auipc	a0,0x5
     210:	edc50513          	addi	a0,a0,-292 # 50e8 <malloc+0x3c2>
     214:	00005097          	auipc	ra,0x5
     218:	a54080e7          	jalr	-1452(ra) # 4c68 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     21c:	8652                	mv	a2,s4
     21e:	85d6                	mv	a1,s5
     220:	00005517          	auipc	a0,0x5
     224:	ed850513          	addi	a0,a0,-296 # 50f8 <malloc+0x3d2>
     228:	00005097          	auipc	ra,0x5
     22c:	a40080e7          	jalr	-1472(ra) # 4c68 <printf>
    exit(1);
     230:	4505                	li	a0,1
     232:	00004097          	auipc	ra,0x4
     236:	686080e7          	jalr	1670(ra) # 48b8 <exit>
    printf("bbb fd2=%d\n", fd2);
     23a:	85a6                	mv	a1,s1
     23c:	00005517          	auipc	a0,0x5
     240:	edc50513          	addi	a0,a0,-292 # 5118 <malloc+0x3f2>
     244:	00005097          	auipc	ra,0x5
     248:	a24080e7          	jalr	-1500(ra) # 4c68 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     24c:	8652                	mv	a2,s4
     24e:	85d6                	mv	a1,s5
     250:	00005517          	auipc	a0,0x5
     254:	ea850513          	addi	a0,a0,-344 # 50f8 <malloc+0x3d2>
     258:	00005097          	auipc	ra,0x5
     25c:	a10080e7          	jalr	-1520(ra) # 4c68 <printf>
    exit(1);
     260:	4505                	li	a0,1
     262:	00004097          	auipc	ra,0x4
     266:	656080e7          	jalr	1622(ra) # 48b8 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     26a:	862a                	mv	a2,a0
     26c:	85d6                	mv	a1,s5
     26e:	00005517          	auipc	a0,0x5
     272:	ec250513          	addi	a0,a0,-318 # 5130 <malloc+0x40a>
     276:	00005097          	auipc	ra,0x5
     27a:	9f2080e7          	jalr	-1550(ra) # 4c68 <printf>
    exit(1);
     27e:	4505                	li	a0,1
     280:	00004097          	auipc	ra,0x4
     284:	638080e7          	jalr	1592(ra) # 48b8 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     288:	862a                	mv	a2,a0
     28a:	85d6                	mv	a1,s5
     28c:	00005517          	auipc	a0,0x5
     290:	ec450513          	addi	a0,a0,-316 # 5150 <malloc+0x42a>
     294:	00005097          	auipc	ra,0x5
     298:	9d4080e7          	jalr	-1580(ra) # 4c68 <printf>
    exit(1);
     29c:	4505                	li	a0,1
     29e:	00004097          	auipc	ra,0x4
     2a2:	61a080e7          	jalr	1562(ra) # 48b8 <exit>

00000000000002a6 <truncate2>:
{
     2a6:	7179                	addi	sp,sp,-48
     2a8:	f406                	sd	ra,40(sp)
     2aa:	f022                	sd	s0,32(sp)
     2ac:	ec26                	sd	s1,24(sp)
     2ae:	e84a                	sd	s2,16(sp)
     2b0:	e44e                	sd	s3,8(sp)
     2b2:	1800                	addi	s0,sp,48
     2b4:	89aa                	mv	s3,a0
  unlink("truncfile");
     2b6:	00005517          	auipc	a0,0x5
     2ba:	dfa50513          	addi	a0,a0,-518 # 50b0 <malloc+0x38a>
     2be:	00004097          	auipc	ra,0x4
     2c2:	64a080e7          	jalr	1610(ra) # 4908 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     2c6:	60100593          	li	a1,1537
     2ca:	00005517          	auipc	a0,0x5
     2ce:	de650513          	addi	a0,a0,-538 # 50b0 <malloc+0x38a>
     2d2:	00004097          	auipc	ra,0x4
     2d6:	626080e7          	jalr	1574(ra) # 48f8 <open>
     2da:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     2dc:	4611                	li	a2,4
     2de:	00005597          	auipc	a1,0x5
     2e2:	de258593          	addi	a1,a1,-542 # 50c0 <malloc+0x39a>
     2e6:	00004097          	auipc	ra,0x4
     2ea:	5f2080e7          	jalr	1522(ra) # 48d8 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     2ee:	40100593          	li	a1,1025
     2f2:	00005517          	auipc	a0,0x5
     2f6:	dbe50513          	addi	a0,a0,-578 # 50b0 <malloc+0x38a>
     2fa:	00004097          	auipc	ra,0x4
     2fe:	5fe080e7          	jalr	1534(ra) # 48f8 <open>
     302:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     304:	4605                	li	a2,1
     306:	00005597          	auipc	a1,0x5
     30a:	e6a58593          	addi	a1,a1,-406 # 5170 <malloc+0x44a>
     30e:	8526                	mv	a0,s1
     310:	00004097          	auipc	ra,0x4
     314:	5c8080e7          	jalr	1480(ra) # 48d8 <write>
  if(n != -1){
     318:	57fd                	li	a5,-1
     31a:	02f51b63          	bne	a0,a5,350 <truncate2+0xaa>
  unlink("truncfile");
     31e:	00005517          	auipc	a0,0x5
     322:	d9250513          	addi	a0,a0,-622 # 50b0 <malloc+0x38a>
     326:	00004097          	auipc	ra,0x4
     32a:	5e2080e7          	jalr	1506(ra) # 4908 <unlink>
  close(fd1);
     32e:	8526                	mv	a0,s1
     330:	00004097          	auipc	ra,0x4
     334:	5b0080e7          	jalr	1456(ra) # 48e0 <close>
  close(fd2);
     338:	854a                	mv	a0,s2
     33a:	00004097          	auipc	ra,0x4
     33e:	5a6080e7          	jalr	1446(ra) # 48e0 <close>
}
     342:	70a2                	ld	ra,40(sp)
     344:	7402                	ld	s0,32(sp)
     346:	64e2                	ld	s1,24(sp)
     348:	6942                	ld	s2,16(sp)
     34a:	69a2                	ld	s3,8(sp)
     34c:	6145                	addi	sp,sp,48
     34e:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     350:	862a                	mv	a2,a0
     352:	85ce                	mv	a1,s3
     354:	00005517          	auipc	a0,0x5
     358:	e2450513          	addi	a0,a0,-476 # 5178 <malloc+0x452>
     35c:	00005097          	auipc	ra,0x5
     360:	90c080e7          	jalr	-1780(ra) # 4c68 <printf>
    exit(1);
     364:	4505                	li	a0,1
     366:	00004097          	auipc	ra,0x4
     36a:	552080e7          	jalr	1362(ra) # 48b8 <exit>

000000000000036e <opentest>:
{
     36e:	1101                	addi	sp,sp,-32
     370:	ec06                	sd	ra,24(sp)
     372:	e822                	sd	s0,16(sp)
     374:	e426                	sd	s1,8(sp)
     376:	1000                	addi	s0,sp,32
     378:	84aa                	mv	s1,a0
  fd = open("echo", 0);
     37a:	4581                	li	a1,0
     37c:	00005517          	auipc	a0,0x5
     380:	e2450513          	addi	a0,a0,-476 # 51a0 <malloc+0x47a>
     384:	00004097          	auipc	ra,0x4
     388:	574080e7          	jalr	1396(ra) # 48f8 <open>
  if(fd < 0){
     38c:	02054663          	bltz	a0,3b8 <opentest+0x4a>
  close(fd);
     390:	00004097          	auipc	ra,0x4
     394:	550080e7          	jalr	1360(ra) # 48e0 <close>
  fd = open("doesnotexist", 0);
     398:	4581                	li	a1,0
     39a:	00005517          	auipc	a0,0x5
     39e:	e2650513          	addi	a0,a0,-474 # 51c0 <malloc+0x49a>
     3a2:	00004097          	auipc	ra,0x4
     3a6:	556080e7          	jalr	1366(ra) # 48f8 <open>
  if(fd >= 0){
     3aa:	02055563          	bgez	a0,3d4 <opentest+0x66>
}
     3ae:	60e2                	ld	ra,24(sp)
     3b0:	6442                	ld	s0,16(sp)
     3b2:	64a2                	ld	s1,8(sp)
     3b4:	6105                	addi	sp,sp,32
     3b6:	8082                	ret
    printf("%s: open echo failed!\n", s);
     3b8:	85a6                	mv	a1,s1
     3ba:	00005517          	auipc	a0,0x5
     3be:	dee50513          	addi	a0,a0,-530 # 51a8 <malloc+0x482>
     3c2:	00005097          	auipc	ra,0x5
     3c6:	8a6080e7          	jalr	-1882(ra) # 4c68 <printf>
    exit(1);
     3ca:	4505                	li	a0,1
     3cc:	00004097          	auipc	ra,0x4
     3d0:	4ec080e7          	jalr	1260(ra) # 48b8 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     3d4:	85a6                	mv	a1,s1
     3d6:	00005517          	auipc	a0,0x5
     3da:	dfa50513          	addi	a0,a0,-518 # 51d0 <malloc+0x4aa>
     3de:	00005097          	auipc	ra,0x5
     3e2:	88a080e7          	jalr	-1910(ra) # 4c68 <printf>
    exit(1);
     3e6:	4505                	li	a0,1
     3e8:	00004097          	auipc	ra,0x4
     3ec:	4d0080e7          	jalr	1232(ra) # 48b8 <exit>

00000000000003f0 <writetest>:
{
     3f0:	7139                	addi	sp,sp,-64
     3f2:	fc06                	sd	ra,56(sp)
     3f4:	f822                	sd	s0,48(sp)
     3f6:	f426                	sd	s1,40(sp)
     3f8:	f04a                	sd	s2,32(sp)
     3fa:	ec4e                	sd	s3,24(sp)
     3fc:	e852                	sd	s4,16(sp)
     3fe:	e456                	sd	s5,8(sp)
     400:	e05a                	sd	s6,0(sp)
     402:	0080                	addi	s0,sp,64
     404:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     406:	20200593          	li	a1,514
     40a:	00005517          	auipc	a0,0x5
     40e:	dee50513          	addi	a0,a0,-530 # 51f8 <malloc+0x4d2>
     412:	00004097          	auipc	ra,0x4
     416:	4e6080e7          	jalr	1254(ra) # 48f8 <open>
  if(fd < 0){
     41a:	0a054d63          	bltz	a0,4d4 <writetest+0xe4>
     41e:	892a                	mv	s2,a0
     420:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     422:	00005997          	auipc	s3,0x5
     426:	dfe98993          	addi	s3,s3,-514 # 5220 <malloc+0x4fa>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     42a:	00005a97          	auipc	s5,0x5
     42e:	e2ea8a93          	addi	s5,s5,-466 # 5258 <malloc+0x532>
  for(i = 0; i < N; i++){
     432:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     436:	4629                	li	a2,10
     438:	85ce                	mv	a1,s3
     43a:	854a                	mv	a0,s2
     43c:	00004097          	auipc	ra,0x4
     440:	49c080e7          	jalr	1180(ra) # 48d8 <write>
     444:	47a9                	li	a5,10
     446:	0af51563          	bne	a0,a5,4f0 <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     44a:	4629                	li	a2,10
     44c:	85d6                	mv	a1,s5
     44e:	854a                	mv	a0,s2
     450:	00004097          	auipc	ra,0x4
     454:	488080e7          	jalr	1160(ra) # 48d8 <write>
     458:	47a9                	li	a5,10
     45a:	0af51963          	bne	a0,a5,50c <writetest+0x11c>
  for(i = 0; i < N; i++){
     45e:	2485                	addiw	s1,s1,1
     460:	fd449be3          	bne	s1,s4,436 <writetest+0x46>
  close(fd);
     464:	854a                	mv	a0,s2
     466:	00004097          	auipc	ra,0x4
     46a:	47a080e7          	jalr	1146(ra) # 48e0 <close>
  fd = open("small", O_RDONLY);
     46e:	4581                	li	a1,0
     470:	00005517          	auipc	a0,0x5
     474:	d8850513          	addi	a0,a0,-632 # 51f8 <malloc+0x4d2>
     478:	00004097          	auipc	ra,0x4
     47c:	480080e7          	jalr	1152(ra) # 48f8 <open>
     480:	84aa                	mv	s1,a0
  if(fd < 0){
     482:	0a054363          	bltz	a0,528 <writetest+0x138>
  i = read(fd, buf, N*SZ*2);
     486:	7d000613          	li	a2,2000
     48a:	00009597          	auipc	a1,0x9
     48e:	3c658593          	addi	a1,a1,966 # 9850 <buf>
     492:	00004097          	auipc	ra,0x4
     496:	43e080e7          	jalr	1086(ra) # 48d0 <read>
  if(i != N*SZ*2){
     49a:	7d000793          	li	a5,2000
     49e:	0af51363          	bne	a0,a5,544 <writetest+0x154>
  close(fd);
     4a2:	8526                	mv	a0,s1
     4a4:	00004097          	auipc	ra,0x4
     4a8:	43c080e7          	jalr	1084(ra) # 48e0 <close>
  if(unlink("small") < 0){
     4ac:	00005517          	auipc	a0,0x5
     4b0:	d4c50513          	addi	a0,a0,-692 # 51f8 <malloc+0x4d2>
     4b4:	00004097          	auipc	ra,0x4
     4b8:	454080e7          	jalr	1108(ra) # 4908 <unlink>
     4bc:	0a054263          	bltz	a0,560 <writetest+0x170>
}
     4c0:	70e2                	ld	ra,56(sp)
     4c2:	7442                	ld	s0,48(sp)
     4c4:	74a2                	ld	s1,40(sp)
     4c6:	7902                	ld	s2,32(sp)
     4c8:	69e2                	ld	s3,24(sp)
     4ca:	6a42                	ld	s4,16(sp)
     4cc:	6aa2                	ld	s5,8(sp)
     4ce:	6b02                	ld	s6,0(sp)
     4d0:	6121                	addi	sp,sp,64
     4d2:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     4d4:	85da                	mv	a1,s6
     4d6:	00005517          	auipc	a0,0x5
     4da:	d2a50513          	addi	a0,a0,-726 # 5200 <malloc+0x4da>
     4de:	00004097          	auipc	ra,0x4
     4e2:	78a080e7          	jalr	1930(ra) # 4c68 <printf>
    exit(1);
     4e6:	4505                	li	a0,1
     4e8:	00004097          	auipc	ra,0x4
     4ec:	3d0080e7          	jalr	976(ra) # 48b8 <exit>
      printf("%s: error: write aa %d new file failed\n", i);
     4f0:	85a6                	mv	a1,s1
     4f2:	00005517          	auipc	a0,0x5
     4f6:	d3e50513          	addi	a0,a0,-706 # 5230 <malloc+0x50a>
     4fa:	00004097          	auipc	ra,0x4
     4fe:	76e080e7          	jalr	1902(ra) # 4c68 <printf>
      exit(1);
     502:	4505                	li	a0,1
     504:	00004097          	auipc	ra,0x4
     508:	3b4080e7          	jalr	948(ra) # 48b8 <exit>
      printf("%s: error: write bb %d new file failed\n", i);
     50c:	85a6                	mv	a1,s1
     50e:	00005517          	auipc	a0,0x5
     512:	d5a50513          	addi	a0,a0,-678 # 5268 <malloc+0x542>
     516:	00004097          	auipc	ra,0x4
     51a:	752080e7          	jalr	1874(ra) # 4c68 <printf>
      exit(1);
     51e:	4505                	li	a0,1
     520:	00004097          	auipc	ra,0x4
     524:	398080e7          	jalr	920(ra) # 48b8 <exit>
    printf("%s: error: open small failed!\n", s);
     528:	85da                	mv	a1,s6
     52a:	00005517          	auipc	a0,0x5
     52e:	d6650513          	addi	a0,a0,-666 # 5290 <malloc+0x56a>
     532:	00004097          	auipc	ra,0x4
     536:	736080e7          	jalr	1846(ra) # 4c68 <printf>
    exit(1);
     53a:	4505                	li	a0,1
     53c:	00004097          	auipc	ra,0x4
     540:	37c080e7          	jalr	892(ra) # 48b8 <exit>
    printf("%s: read failed\n", s);
     544:	85da                	mv	a1,s6
     546:	00005517          	auipc	a0,0x5
     54a:	d6a50513          	addi	a0,a0,-662 # 52b0 <malloc+0x58a>
     54e:	00004097          	auipc	ra,0x4
     552:	71a080e7          	jalr	1818(ra) # 4c68 <printf>
    exit(1);
     556:	4505                	li	a0,1
     558:	00004097          	auipc	ra,0x4
     55c:	360080e7          	jalr	864(ra) # 48b8 <exit>
    printf("%s: unlink small failed\n", s);
     560:	85da                	mv	a1,s6
     562:	00005517          	auipc	a0,0x5
     566:	d6650513          	addi	a0,a0,-666 # 52c8 <malloc+0x5a2>
     56a:	00004097          	auipc	ra,0x4
     56e:	6fe080e7          	jalr	1790(ra) # 4c68 <printf>
    exit(1);
     572:	4505                	li	a0,1
     574:	00004097          	auipc	ra,0x4
     578:	344080e7          	jalr	836(ra) # 48b8 <exit>

000000000000057c <writebig>:
{
     57c:	7139                	addi	sp,sp,-64
     57e:	fc06                	sd	ra,56(sp)
     580:	f822                	sd	s0,48(sp)
     582:	f426                	sd	s1,40(sp)
     584:	f04a                	sd	s2,32(sp)
     586:	ec4e                	sd	s3,24(sp)
     588:	e852                	sd	s4,16(sp)
     58a:	e456                	sd	s5,8(sp)
     58c:	0080                	addi	s0,sp,64
     58e:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     590:	20200593          	li	a1,514
     594:	00005517          	auipc	a0,0x5
     598:	d5450513          	addi	a0,a0,-684 # 52e8 <malloc+0x5c2>
     59c:	00004097          	auipc	ra,0x4
     5a0:	35c080e7          	jalr	860(ra) # 48f8 <open>
     5a4:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     5a6:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     5a8:	00009917          	auipc	s2,0x9
     5ac:	2a890913          	addi	s2,s2,680 # 9850 <buf>
  for(i = 0; i < MAXFILE; i++){
     5b0:	10c00a13          	li	s4,268
  if(fd < 0){
     5b4:	06054c63          	bltz	a0,62c <writebig+0xb0>
    ((int*)buf)[0] = i;
     5b8:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     5bc:	40000613          	li	a2,1024
     5c0:	85ca                	mv	a1,s2
     5c2:	854e                	mv	a0,s3
     5c4:	00004097          	auipc	ra,0x4
     5c8:	314080e7          	jalr	788(ra) # 48d8 <write>
     5cc:	40000793          	li	a5,1024
     5d0:	06f51c63          	bne	a0,a5,648 <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     5d4:	2485                	addiw	s1,s1,1
     5d6:	ff4491e3          	bne	s1,s4,5b8 <writebig+0x3c>
  close(fd);
     5da:	854e                	mv	a0,s3
     5dc:	00004097          	auipc	ra,0x4
     5e0:	304080e7          	jalr	772(ra) # 48e0 <close>
  fd = open("big", O_RDONLY);
     5e4:	4581                	li	a1,0
     5e6:	00005517          	auipc	a0,0x5
     5ea:	d0250513          	addi	a0,a0,-766 # 52e8 <malloc+0x5c2>
     5ee:	00004097          	auipc	ra,0x4
     5f2:	30a080e7          	jalr	778(ra) # 48f8 <open>
     5f6:	89aa                	mv	s3,a0
  n = 0;
     5f8:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     5fa:	00009917          	auipc	s2,0x9
     5fe:	25690913          	addi	s2,s2,598 # 9850 <buf>
  if(fd < 0){
     602:	06054163          	bltz	a0,664 <writebig+0xe8>
    i = read(fd, buf, BSIZE);
     606:	40000613          	li	a2,1024
     60a:	85ca                	mv	a1,s2
     60c:	854e                	mv	a0,s3
     60e:	00004097          	auipc	ra,0x4
     612:	2c2080e7          	jalr	706(ra) # 48d0 <read>
    if(i == 0){
     616:	c52d                	beqz	a0,680 <writebig+0x104>
    } else if(i != BSIZE){
     618:	40000793          	li	a5,1024
     61c:	0af51d63          	bne	a0,a5,6d6 <writebig+0x15a>
    if(((int*)buf)[0] != n){
     620:	00092603          	lw	a2,0(s2)
     624:	0c961763          	bne	a2,s1,6f2 <writebig+0x176>
    n++;
     628:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     62a:	bff1                	j	606 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     62c:	85d6                	mv	a1,s5
     62e:	00005517          	auipc	a0,0x5
     632:	cc250513          	addi	a0,a0,-830 # 52f0 <malloc+0x5ca>
     636:	00004097          	auipc	ra,0x4
     63a:	632080e7          	jalr	1586(ra) # 4c68 <printf>
    exit(1);
     63e:	4505                	li	a0,1
     640:	00004097          	auipc	ra,0x4
     644:	278080e7          	jalr	632(ra) # 48b8 <exit>
      printf("%s: error: write big file failed\n", i);
     648:	85a6                	mv	a1,s1
     64a:	00005517          	auipc	a0,0x5
     64e:	cc650513          	addi	a0,a0,-826 # 5310 <malloc+0x5ea>
     652:	00004097          	auipc	ra,0x4
     656:	616080e7          	jalr	1558(ra) # 4c68 <printf>
      exit(1);
     65a:	4505                	li	a0,1
     65c:	00004097          	auipc	ra,0x4
     660:	25c080e7          	jalr	604(ra) # 48b8 <exit>
    printf("%s: error: open big failed!\n", s);
     664:	85d6                	mv	a1,s5
     666:	00005517          	auipc	a0,0x5
     66a:	cd250513          	addi	a0,a0,-814 # 5338 <malloc+0x612>
     66e:	00004097          	auipc	ra,0x4
     672:	5fa080e7          	jalr	1530(ra) # 4c68 <printf>
    exit(1);
     676:	4505                	li	a0,1
     678:	00004097          	auipc	ra,0x4
     67c:	240080e7          	jalr	576(ra) # 48b8 <exit>
      if(n == MAXFILE - 1){
     680:	10b00793          	li	a5,267
     684:	02f48a63          	beq	s1,a5,6b8 <writebig+0x13c>
  close(fd);
     688:	854e                	mv	a0,s3
     68a:	00004097          	auipc	ra,0x4
     68e:	256080e7          	jalr	598(ra) # 48e0 <close>
  if(unlink("big") < 0){
     692:	00005517          	auipc	a0,0x5
     696:	c5650513          	addi	a0,a0,-938 # 52e8 <malloc+0x5c2>
     69a:	00004097          	auipc	ra,0x4
     69e:	26e080e7          	jalr	622(ra) # 4908 <unlink>
     6a2:	06054663          	bltz	a0,70e <writebig+0x192>
}
     6a6:	70e2                	ld	ra,56(sp)
     6a8:	7442                	ld	s0,48(sp)
     6aa:	74a2                	ld	s1,40(sp)
     6ac:	7902                	ld	s2,32(sp)
     6ae:	69e2                	ld	s3,24(sp)
     6b0:	6a42                	ld	s4,16(sp)
     6b2:	6aa2                	ld	s5,8(sp)
     6b4:	6121                	addi	sp,sp,64
     6b6:	8082                	ret
        printf("%s: read only %d blocks from big", n);
     6b8:	10b00593          	li	a1,267
     6bc:	00005517          	auipc	a0,0x5
     6c0:	c9c50513          	addi	a0,a0,-868 # 5358 <malloc+0x632>
     6c4:	00004097          	auipc	ra,0x4
     6c8:	5a4080e7          	jalr	1444(ra) # 4c68 <printf>
        exit(1);
     6cc:	4505                	li	a0,1
     6ce:	00004097          	auipc	ra,0x4
     6d2:	1ea080e7          	jalr	490(ra) # 48b8 <exit>
      printf("%s: read failed %d\n", i);
     6d6:	85aa                	mv	a1,a0
     6d8:	00005517          	auipc	a0,0x5
     6dc:	ca850513          	addi	a0,a0,-856 # 5380 <malloc+0x65a>
     6e0:	00004097          	auipc	ra,0x4
     6e4:	588080e7          	jalr	1416(ra) # 4c68 <printf>
      exit(1);
     6e8:	4505                	li	a0,1
     6ea:	00004097          	auipc	ra,0x4
     6ee:	1ce080e7          	jalr	462(ra) # 48b8 <exit>
      printf("%s: read content of block %d is %d\n",
     6f2:	85a6                	mv	a1,s1
     6f4:	00005517          	auipc	a0,0x5
     6f8:	ca450513          	addi	a0,a0,-860 # 5398 <malloc+0x672>
     6fc:	00004097          	auipc	ra,0x4
     700:	56c080e7          	jalr	1388(ra) # 4c68 <printf>
      exit(1);
     704:	4505                	li	a0,1
     706:	00004097          	auipc	ra,0x4
     70a:	1b2080e7          	jalr	434(ra) # 48b8 <exit>
    printf("%s: unlink big failed\n", s);
     70e:	85d6                	mv	a1,s5
     710:	00005517          	auipc	a0,0x5
     714:	cb050513          	addi	a0,a0,-848 # 53c0 <malloc+0x69a>
     718:	00004097          	auipc	ra,0x4
     71c:	550080e7          	jalr	1360(ra) # 4c68 <printf>
    exit(1);
     720:	4505                	li	a0,1
     722:	00004097          	auipc	ra,0x4
     726:	196080e7          	jalr	406(ra) # 48b8 <exit>

000000000000072a <unlinkread>:
}

// can I unlink a file and still read it?
void
unlinkread(char *s)
{
     72a:	7179                	addi	sp,sp,-48
     72c:	f406                	sd	ra,40(sp)
     72e:	f022                	sd	s0,32(sp)
     730:	ec26                	sd	s1,24(sp)
     732:	e84a                	sd	s2,16(sp)
     734:	e44e                	sd	s3,8(sp)
     736:	1800                	addi	s0,sp,48
     738:	89aa                	mv	s3,a0
  enum { SZ = 5 };
  int fd, fd1;

  fd = open("unlinkread", O_CREATE | O_RDWR);
     73a:	20200593          	li	a1,514
     73e:	00004517          	auipc	a0,0x4
     742:	7d250513          	addi	a0,a0,2002 # 4f10 <malloc+0x1ea>
     746:	00004097          	auipc	ra,0x4
     74a:	1b2080e7          	jalr	434(ra) # 48f8 <open>
  if(fd < 0){
     74e:	0e054563          	bltz	a0,838 <unlinkread+0x10e>
     752:	84aa                	mv	s1,a0
    printf("%s: create unlinkread failed\n", s);
    exit(1);
  }
  write(fd, "hello", SZ);
     754:	4615                	li	a2,5
     756:	00005597          	auipc	a1,0x5
     75a:	ca258593          	addi	a1,a1,-862 # 53f8 <malloc+0x6d2>
     75e:	00004097          	auipc	ra,0x4
     762:	17a080e7          	jalr	378(ra) # 48d8 <write>
  close(fd);
     766:	8526                	mv	a0,s1
     768:	00004097          	auipc	ra,0x4
     76c:	178080e7          	jalr	376(ra) # 48e0 <close>

  fd = open("unlinkread", O_RDWR);
     770:	4589                	li	a1,2
     772:	00004517          	auipc	a0,0x4
     776:	79e50513          	addi	a0,a0,1950 # 4f10 <malloc+0x1ea>
     77a:	00004097          	auipc	ra,0x4
     77e:	17e080e7          	jalr	382(ra) # 48f8 <open>
     782:	84aa                	mv	s1,a0
  if(fd < 0){
     784:	0c054863          	bltz	a0,854 <unlinkread+0x12a>
    printf("%s: open unlinkread failed\n", s);
    exit(1);
  }
  if(unlink("unlinkread") != 0){
     788:	00004517          	auipc	a0,0x4
     78c:	78850513          	addi	a0,a0,1928 # 4f10 <malloc+0x1ea>
     790:	00004097          	auipc	ra,0x4
     794:	178080e7          	jalr	376(ra) # 4908 <unlink>
     798:	ed61                	bnez	a0,870 <unlinkread+0x146>
    printf("%s: unlink unlinkread failed\n", s);
    exit(1);
  }

  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     79a:	20200593          	li	a1,514
     79e:	00004517          	auipc	a0,0x4
     7a2:	77250513          	addi	a0,a0,1906 # 4f10 <malloc+0x1ea>
     7a6:	00004097          	auipc	ra,0x4
     7aa:	152080e7          	jalr	338(ra) # 48f8 <open>
     7ae:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     7b0:	460d                	li	a2,3
     7b2:	00005597          	auipc	a1,0x5
     7b6:	c8e58593          	addi	a1,a1,-882 # 5440 <malloc+0x71a>
     7ba:	00004097          	auipc	ra,0x4
     7be:	11e080e7          	jalr	286(ra) # 48d8 <write>
  close(fd1);
     7c2:	854a                	mv	a0,s2
     7c4:	00004097          	auipc	ra,0x4
     7c8:	11c080e7          	jalr	284(ra) # 48e0 <close>

  if(read(fd, buf, sizeof(buf)) != SZ){
     7cc:	660d                	lui	a2,0x3
     7ce:	00009597          	auipc	a1,0x9
     7d2:	08258593          	addi	a1,a1,130 # 9850 <buf>
     7d6:	8526                	mv	a0,s1
     7d8:	00004097          	auipc	ra,0x4
     7dc:	0f8080e7          	jalr	248(ra) # 48d0 <read>
     7e0:	4795                	li	a5,5
     7e2:	0af51563          	bne	a0,a5,88c <unlinkread+0x162>
    printf("%s: unlinkread read failed", s);
    exit(1);
  }
  if(buf[0] != 'h'){
     7e6:	00009717          	auipc	a4,0x9
     7ea:	06a74703          	lbu	a4,106(a4) # 9850 <buf>
     7ee:	06800793          	li	a5,104
     7f2:	0af71b63          	bne	a4,a5,8a8 <unlinkread+0x17e>
    printf("%s: unlinkread wrong data\n", s);
    exit(1);
  }
  if(write(fd, buf, 10) != 10){
     7f6:	4629                	li	a2,10
     7f8:	00009597          	auipc	a1,0x9
     7fc:	05858593          	addi	a1,a1,88 # 9850 <buf>
     800:	8526                	mv	a0,s1
     802:	00004097          	auipc	ra,0x4
     806:	0d6080e7          	jalr	214(ra) # 48d8 <write>
     80a:	47a9                	li	a5,10
     80c:	0af51c63          	bne	a0,a5,8c4 <unlinkread+0x19a>
    printf("%s: unlinkread write failed\n", s);
    exit(1);
  }
  close(fd);
     810:	8526                	mv	a0,s1
     812:	00004097          	auipc	ra,0x4
     816:	0ce080e7          	jalr	206(ra) # 48e0 <close>
  unlink("unlinkread");
     81a:	00004517          	auipc	a0,0x4
     81e:	6f650513          	addi	a0,a0,1782 # 4f10 <malloc+0x1ea>
     822:	00004097          	auipc	ra,0x4
     826:	0e6080e7          	jalr	230(ra) # 4908 <unlink>
}
     82a:	70a2                	ld	ra,40(sp)
     82c:	7402                	ld	s0,32(sp)
     82e:	64e2                	ld	s1,24(sp)
     830:	6942                	ld	s2,16(sp)
     832:	69a2                	ld	s3,8(sp)
     834:	6145                	addi	sp,sp,48
     836:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     838:	85ce                	mv	a1,s3
     83a:	00005517          	auipc	a0,0x5
     83e:	b9e50513          	addi	a0,a0,-1122 # 53d8 <malloc+0x6b2>
     842:	00004097          	auipc	ra,0x4
     846:	426080e7          	jalr	1062(ra) # 4c68 <printf>
    exit(1);
     84a:	4505                	li	a0,1
     84c:	00004097          	auipc	ra,0x4
     850:	06c080e7          	jalr	108(ra) # 48b8 <exit>
    printf("%s: open unlinkread failed\n", s);
     854:	85ce                	mv	a1,s3
     856:	00005517          	auipc	a0,0x5
     85a:	baa50513          	addi	a0,a0,-1110 # 5400 <malloc+0x6da>
     85e:	00004097          	auipc	ra,0x4
     862:	40a080e7          	jalr	1034(ra) # 4c68 <printf>
    exit(1);
     866:	4505                	li	a0,1
     868:	00004097          	auipc	ra,0x4
     86c:	050080e7          	jalr	80(ra) # 48b8 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     870:	85ce                	mv	a1,s3
     872:	00005517          	auipc	a0,0x5
     876:	bae50513          	addi	a0,a0,-1106 # 5420 <malloc+0x6fa>
     87a:	00004097          	auipc	ra,0x4
     87e:	3ee080e7          	jalr	1006(ra) # 4c68 <printf>
    exit(1);
     882:	4505                	li	a0,1
     884:	00004097          	auipc	ra,0x4
     888:	034080e7          	jalr	52(ra) # 48b8 <exit>
    printf("%s: unlinkread read failed", s);
     88c:	85ce                	mv	a1,s3
     88e:	00005517          	auipc	a0,0x5
     892:	bba50513          	addi	a0,a0,-1094 # 5448 <malloc+0x722>
     896:	00004097          	auipc	ra,0x4
     89a:	3d2080e7          	jalr	978(ra) # 4c68 <printf>
    exit(1);
     89e:	4505                	li	a0,1
     8a0:	00004097          	auipc	ra,0x4
     8a4:	018080e7          	jalr	24(ra) # 48b8 <exit>
    printf("%s: unlinkread wrong data\n", s);
     8a8:	85ce                	mv	a1,s3
     8aa:	00005517          	auipc	a0,0x5
     8ae:	bbe50513          	addi	a0,a0,-1090 # 5468 <malloc+0x742>
     8b2:	00004097          	auipc	ra,0x4
     8b6:	3b6080e7          	jalr	950(ra) # 4c68 <printf>
    exit(1);
     8ba:	4505                	li	a0,1
     8bc:	00004097          	auipc	ra,0x4
     8c0:	ffc080e7          	jalr	-4(ra) # 48b8 <exit>
    printf("%s: unlinkread write failed\n", s);
     8c4:	85ce                	mv	a1,s3
     8c6:	00005517          	auipc	a0,0x5
     8ca:	bc250513          	addi	a0,a0,-1086 # 5488 <malloc+0x762>
     8ce:	00004097          	auipc	ra,0x4
     8d2:	39a080e7          	jalr	922(ra) # 4c68 <printf>
    exit(1);
     8d6:	4505                	li	a0,1
     8d8:	00004097          	auipc	ra,0x4
     8dc:	fe0080e7          	jalr	-32(ra) # 48b8 <exit>

00000000000008e0 <bigwrite>:
}

// test writes that are larger than the log.
void
bigwrite(char *s)
{
     8e0:	715d                	addi	sp,sp,-80
     8e2:	e486                	sd	ra,72(sp)
     8e4:	e0a2                	sd	s0,64(sp)
     8e6:	fc26                	sd	s1,56(sp)
     8e8:	f84a                	sd	s2,48(sp)
     8ea:	f44e                	sd	s3,40(sp)
     8ec:	f052                	sd	s4,32(sp)
     8ee:	ec56                	sd	s5,24(sp)
     8f0:	e85a                	sd	s6,16(sp)
     8f2:	e45e                	sd	s7,8(sp)
     8f4:	0880                	addi	s0,sp,80
     8f6:	8baa                	mv	s7,a0
  int fd, sz;

  unlink("bigwrite");
     8f8:	00004517          	auipc	a0,0x4
     8fc:	68050513          	addi	a0,a0,1664 # 4f78 <malloc+0x252>
     900:	00004097          	auipc	ra,0x4
     904:	008080e7          	jalr	8(ra) # 4908 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     908:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     90c:	00004a97          	auipc	s5,0x4
     910:	66ca8a93          	addi	s5,s5,1644 # 4f78 <malloc+0x252>
      printf("%s: cannot create bigwrite\n", s);
      exit(1);
    }
    int i;
    for(i = 0; i < 2; i++){
      int cc = write(fd, buf, sz);
     914:	00009a17          	auipc	s4,0x9
     918:	f3ca0a13          	addi	s4,s4,-196 # 9850 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     91c:	6b0d                	lui	s6,0x3
     91e:	1c9b0b13          	addi	s6,s6,457 # 31c9 <subdir+0x3f3>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     922:	20200593          	li	a1,514
     926:	8556                	mv	a0,s5
     928:	00004097          	auipc	ra,0x4
     92c:	fd0080e7          	jalr	-48(ra) # 48f8 <open>
     930:	892a                	mv	s2,a0
    if(fd < 0){
     932:	04054d63          	bltz	a0,98c <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     936:	8626                	mv	a2,s1
     938:	85d2                	mv	a1,s4
     93a:	00004097          	auipc	ra,0x4
     93e:	f9e080e7          	jalr	-98(ra) # 48d8 <write>
     942:	89aa                	mv	s3,a0
      if(cc != sz){
     944:	06a49463          	bne	s1,a0,9ac <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     948:	8626                	mv	a2,s1
     94a:	85d2                	mv	a1,s4
     94c:	854a                	mv	a0,s2
     94e:	00004097          	auipc	ra,0x4
     952:	f8a080e7          	jalr	-118(ra) # 48d8 <write>
      if(cc != sz){
     956:	04951963          	bne	a0,s1,9a8 <bigwrite+0xc8>
        printf("%s: write(%d) ret %d\n", s, sz, cc);
        exit(1);
      }
    }
    close(fd);
     95a:	854a                	mv	a0,s2
     95c:	00004097          	auipc	ra,0x4
     960:	f84080e7          	jalr	-124(ra) # 48e0 <close>
    unlink("bigwrite");
     964:	8556                	mv	a0,s5
     966:	00004097          	auipc	ra,0x4
     96a:	fa2080e7          	jalr	-94(ra) # 4908 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     96e:	1d74849b          	addiw	s1,s1,471
     972:	fb6498e3          	bne	s1,s6,922 <bigwrite+0x42>
  }
}
     976:	60a6                	ld	ra,72(sp)
     978:	6406                	ld	s0,64(sp)
     97a:	74e2                	ld	s1,56(sp)
     97c:	7942                	ld	s2,48(sp)
     97e:	79a2                	ld	s3,40(sp)
     980:	7a02                	ld	s4,32(sp)
     982:	6ae2                	ld	s5,24(sp)
     984:	6b42                	ld	s6,16(sp)
     986:	6ba2                	ld	s7,8(sp)
     988:	6161                	addi	sp,sp,80
     98a:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     98c:	85de                	mv	a1,s7
     98e:	00005517          	auipc	a0,0x5
     992:	b1a50513          	addi	a0,a0,-1254 # 54a8 <malloc+0x782>
     996:	00004097          	auipc	ra,0x4
     99a:	2d2080e7          	jalr	722(ra) # 4c68 <printf>
      exit(1);
     99e:	4505                	li	a0,1
     9a0:	00004097          	auipc	ra,0x4
     9a4:	f18080e7          	jalr	-232(ra) # 48b8 <exit>
     9a8:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     9aa:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     9ac:	86ce                	mv	a3,s3
     9ae:	8626                	mv	a2,s1
     9b0:	85de                	mv	a1,s7
     9b2:	00005517          	auipc	a0,0x5
     9b6:	b1650513          	addi	a0,a0,-1258 # 54c8 <malloc+0x7a2>
     9ba:	00004097          	auipc	ra,0x4
     9be:	2ae080e7          	jalr	686(ra) # 4c68 <printf>
        exit(1);
     9c2:	4505                	li	a0,1
     9c4:	00004097          	auipc	ra,0x4
     9c8:	ef4080e7          	jalr	-268(ra) # 48b8 <exit>

00000000000009cc <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
     9cc:	00006797          	auipc	a5,0x6
     9d0:	77478793          	addi	a5,a5,1908 # 7140 <uninit>
     9d4:	00009697          	auipc	a3,0x9
     9d8:	e7c68693          	addi	a3,a3,-388 # 9850 <buf>
    if(uninit[i] != '\0'){
     9dc:	0007c703          	lbu	a4,0(a5)
     9e0:	e709                	bnez	a4,9ea <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
     9e2:	0785                	addi	a5,a5,1
     9e4:	fed79ce3          	bne	a5,a3,9dc <bsstest+0x10>
     9e8:	8082                	ret
{
     9ea:	1141                	addi	sp,sp,-16
     9ec:	e406                	sd	ra,8(sp)
     9ee:	e022                	sd	s0,0(sp)
     9f0:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
     9f2:	85aa                	mv	a1,a0
     9f4:	00005517          	auipc	a0,0x5
     9f8:	aec50513          	addi	a0,a0,-1300 # 54e0 <malloc+0x7ba>
     9fc:	00004097          	auipc	ra,0x4
     a00:	26c080e7          	jalr	620(ra) # 4c68 <printf>
      exit(1);
     a04:	4505                	li	a0,1
     a06:	00004097          	auipc	ra,0x4
     a0a:	eb2080e7          	jalr	-334(ra) # 48b8 <exit>

0000000000000a0e <truncate3>:
{
     a0e:	7159                	addi	sp,sp,-112
     a10:	f486                	sd	ra,104(sp)
     a12:	f0a2                	sd	s0,96(sp)
     a14:	eca6                	sd	s1,88(sp)
     a16:	e8ca                	sd	s2,80(sp)
     a18:	e4ce                	sd	s3,72(sp)
     a1a:	e0d2                	sd	s4,64(sp)
     a1c:	fc56                	sd	s5,56(sp)
     a1e:	1880                	addi	s0,sp,112
     a20:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
     a22:	60100593          	li	a1,1537
     a26:	00004517          	auipc	a0,0x4
     a2a:	68a50513          	addi	a0,a0,1674 # 50b0 <malloc+0x38a>
     a2e:	00004097          	auipc	ra,0x4
     a32:	eca080e7          	jalr	-310(ra) # 48f8 <open>
     a36:	00004097          	auipc	ra,0x4
     a3a:	eaa080e7          	jalr	-342(ra) # 48e0 <close>
  pid = fork();
     a3e:	00004097          	auipc	ra,0x4
     a42:	e72080e7          	jalr	-398(ra) # 48b0 <fork>
  if(pid < 0){
     a46:	08054063          	bltz	a0,ac6 <truncate3+0xb8>
  if(pid == 0){
     a4a:	e969                	bnez	a0,b1c <truncate3+0x10e>
     a4c:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
     a50:	00004a17          	auipc	s4,0x4
     a54:	660a0a13          	addi	s4,s4,1632 # 50b0 <malloc+0x38a>
      int n = write(fd, "1234567890", 10);
     a58:	00005a97          	auipc	s5,0x5
     a5c:	ad0a8a93          	addi	s5,s5,-1328 # 5528 <malloc+0x802>
      int fd = open("truncfile", O_WRONLY);
     a60:	4585                	li	a1,1
     a62:	8552                	mv	a0,s4
     a64:	00004097          	auipc	ra,0x4
     a68:	e94080e7          	jalr	-364(ra) # 48f8 <open>
     a6c:	84aa                	mv	s1,a0
      if(fd < 0){
     a6e:	06054a63          	bltz	a0,ae2 <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
     a72:	4629                	li	a2,10
     a74:	85d6                	mv	a1,s5
     a76:	00004097          	auipc	ra,0x4
     a7a:	e62080e7          	jalr	-414(ra) # 48d8 <write>
      if(n != 10){
     a7e:	47a9                	li	a5,10
     a80:	06f51f63          	bne	a0,a5,afe <truncate3+0xf0>
      close(fd);
     a84:	8526                	mv	a0,s1
     a86:	00004097          	auipc	ra,0x4
     a8a:	e5a080e7          	jalr	-422(ra) # 48e0 <close>
      fd = open("truncfile", O_RDONLY);
     a8e:	4581                	li	a1,0
     a90:	8552                	mv	a0,s4
     a92:	00004097          	auipc	ra,0x4
     a96:	e66080e7          	jalr	-410(ra) # 48f8 <open>
     a9a:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
     a9c:	02000613          	li	a2,32
     aa0:	f9840593          	addi	a1,s0,-104
     aa4:	00004097          	auipc	ra,0x4
     aa8:	e2c080e7          	jalr	-468(ra) # 48d0 <read>
      close(fd);
     aac:	8526                	mv	a0,s1
     aae:	00004097          	auipc	ra,0x4
     ab2:	e32080e7          	jalr	-462(ra) # 48e0 <close>
    for(int i = 0; i < 100; i++){
     ab6:	39fd                	addiw	s3,s3,-1
     ab8:	fa0994e3          	bnez	s3,a60 <truncate3+0x52>
    exit(0);
     abc:	4501                	li	a0,0
     abe:	00004097          	auipc	ra,0x4
     ac2:	dfa080e7          	jalr	-518(ra) # 48b8 <exit>
    printf("%s: fork failed\n", s);
     ac6:	85ca                	mv	a1,s2
     ac8:	00005517          	auipc	a0,0x5
     acc:	a3050513          	addi	a0,a0,-1488 # 54f8 <malloc+0x7d2>
     ad0:	00004097          	auipc	ra,0x4
     ad4:	198080e7          	jalr	408(ra) # 4c68 <printf>
    exit(1);
     ad8:	4505                	li	a0,1
     ada:	00004097          	auipc	ra,0x4
     ade:	dde080e7          	jalr	-546(ra) # 48b8 <exit>
        printf("%s: open failed\n", s);
     ae2:	85ca                	mv	a1,s2
     ae4:	00005517          	auipc	a0,0x5
     ae8:	a2c50513          	addi	a0,a0,-1492 # 5510 <malloc+0x7ea>
     aec:	00004097          	auipc	ra,0x4
     af0:	17c080e7          	jalr	380(ra) # 4c68 <printf>
        exit(1);
     af4:	4505                	li	a0,1
     af6:	00004097          	auipc	ra,0x4
     afa:	dc2080e7          	jalr	-574(ra) # 48b8 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
     afe:	862a                	mv	a2,a0
     b00:	85ca                	mv	a1,s2
     b02:	00005517          	auipc	a0,0x5
     b06:	a3650513          	addi	a0,a0,-1482 # 5538 <malloc+0x812>
     b0a:	00004097          	auipc	ra,0x4
     b0e:	15e080e7          	jalr	350(ra) # 4c68 <printf>
        exit(1);
     b12:	4505                	li	a0,1
     b14:	00004097          	auipc	ra,0x4
     b18:	da4080e7          	jalr	-604(ra) # 48b8 <exit>
     b1c:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     b20:	00004a17          	auipc	s4,0x4
     b24:	590a0a13          	addi	s4,s4,1424 # 50b0 <malloc+0x38a>
    int n = write(fd, "xxx", 3);
     b28:	00005a97          	auipc	s5,0x5
     b2c:	a30a8a93          	addi	s5,s5,-1488 # 5558 <malloc+0x832>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     b30:	60100593          	li	a1,1537
     b34:	8552                	mv	a0,s4
     b36:	00004097          	auipc	ra,0x4
     b3a:	dc2080e7          	jalr	-574(ra) # 48f8 <open>
     b3e:	84aa                	mv	s1,a0
    if(fd < 0){
     b40:	04054763          	bltz	a0,b8e <truncate3+0x180>
    int n = write(fd, "xxx", 3);
     b44:	460d                	li	a2,3
     b46:	85d6                	mv	a1,s5
     b48:	00004097          	auipc	ra,0x4
     b4c:	d90080e7          	jalr	-624(ra) # 48d8 <write>
    if(n != 3){
     b50:	478d                	li	a5,3
     b52:	04f51c63          	bne	a0,a5,baa <truncate3+0x19c>
    close(fd);
     b56:	8526                	mv	a0,s1
     b58:	00004097          	auipc	ra,0x4
     b5c:	d88080e7          	jalr	-632(ra) # 48e0 <close>
  for(int i = 0; i < 150; i++){
     b60:	39fd                	addiw	s3,s3,-1
     b62:	fc0997e3          	bnez	s3,b30 <truncate3+0x122>
  wait(&xstatus);
     b66:	fbc40513          	addi	a0,s0,-68
     b6a:	00004097          	auipc	ra,0x4
     b6e:	d56080e7          	jalr	-682(ra) # 48c0 <wait>
  unlink("truncfile");
     b72:	00004517          	auipc	a0,0x4
     b76:	53e50513          	addi	a0,a0,1342 # 50b0 <malloc+0x38a>
     b7a:	00004097          	auipc	ra,0x4
     b7e:	d8e080e7          	jalr	-626(ra) # 4908 <unlink>
  exit(xstatus);
     b82:	fbc42503          	lw	a0,-68(s0)
     b86:	00004097          	auipc	ra,0x4
     b8a:	d32080e7          	jalr	-718(ra) # 48b8 <exit>
      printf("%s: open failed\n", s);
     b8e:	85ca                	mv	a1,s2
     b90:	00005517          	auipc	a0,0x5
     b94:	98050513          	addi	a0,a0,-1664 # 5510 <malloc+0x7ea>
     b98:	00004097          	auipc	ra,0x4
     b9c:	0d0080e7          	jalr	208(ra) # 4c68 <printf>
      exit(1);
     ba0:	4505                	li	a0,1
     ba2:	00004097          	auipc	ra,0x4
     ba6:	d16080e7          	jalr	-746(ra) # 48b8 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
     baa:	862a                	mv	a2,a0
     bac:	85ca                	mv	a1,s2
     bae:	00005517          	auipc	a0,0x5
     bb2:	9b250513          	addi	a0,a0,-1614 # 5560 <malloc+0x83a>
     bb6:	00004097          	auipc	ra,0x4
     bba:	0b2080e7          	jalr	178(ra) # 4c68 <printf>
      exit(1);
     bbe:	4505                	li	a0,1
     bc0:	00004097          	auipc	ra,0x4
     bc4:	cf8080e7          	jalr	-776(ra) # 48b8 <exit>

0000000000000bc8 <exitwait>:
{
     bc8:	7139                	addi	sp,sp,-64
     bca:	fc06                	sd	ra,56(sp)
     bcc:	f822                	sd	s0,48(sp)
     bce:	f426                	sd	s1,40(sp)
     bd0:	f04a                	sd	s2,32(sp)
     bd2:	ec4e                	sd	s3,24(sp)
     bd4:	e852                	sd	s4,16(sp)
     bd6:	0080                	addi	s0,sp,64
     bd8:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
     bda:	4901                	li	s2,0
     bdc:	06400993          	li	s3,100
    pid = fork();
     be0:	00004097          	auipc	ra,0x4
     be4:	cd0080e7          	jalr	-816(ra) # 48b0 <fork>
     be8:	84aa                	mv	s1,a0
    if(pid < 0){
     bea:	02054a63          	bltz	a0,c1e <exitwait+0x56>
    if(pid){
     bee:	c151                	beqz	a0,c72 <exitwait+0xaa>
      if(wait(&xstate) != pid){
     bf0:	fcc40513          	addi	a0,s0,-52
     bf4:	00004097          	auipc	ra,0x4
     bf8:	ccc080e7          	jalr	-820(ra) # 48c0 <wait>
     bfc:	02951f63          	bne	a0,s1,c3a <exitwait+0x72>
      if(i != xstate) {
     c00:	fcc42783          	lw	a5,-52(s0)
     c04:	05279963          	bne	a5,s2,c56 <exitwait+0x8e>
  for(i = 0; i < 100; i++){
     c08:	2905                	addiw	s2,s2,1
     c0a:	fd391be3          	bne	s2,s3,be0 <exitwait+0x18>
}
     c0e:	70e2                	ld	ra,56(sp)
     c10:	7442                	ld	s0,48(sp)
     c12:	74a2                	ld	s1,40(sp)
     c14:	7902                	ld	s2,32(sp)
     c16:	69e2                	ld	s3,24(sp)
     c18:	6a42                	ld	s4,16(sp)
     c1a:	6121                	addi	sp,sp,64
     c1c:	8082                	ret
      printf("%s: fork failed\n", s);
     c1e:	85d2                	mv	a1,s4
     c20:	00005517          	auipc	a0,0x5
     c24:	8d850513          	addi	a0,a0,-1832 # 54f8 <malloc+0x7d2>
     c28:	00004097          	auipc	ra,0x4
     c2c:	040080e7          	jalr	64(ra) # 4c68 <printf>
      exit(1);
     c30:	4505                	li	a0,1
     c32:	00004097          	auipc	ra,0x4
     c36:	c86080e7          	jalr	-890(ra) # 48b8 <exit>
        printf("%s: wait wrong pid\n", s);
     c3a:	85d2                	mv	a1,s4
     c3c:	00005517          	auipc	a0,0x5
     c40:	94450513          	addi	a0,a0,-1724 # 5580 <malloc+0x85a>
     c44:	00004097          	auipc	ra,0x4
     c48:	024080e7          	jalr	36(ra) # 4c68 <printf>
        exit(1);
     c4c:	4505                	li	a0,1
     c4e:	00004097          	auipc	ra,0x4
     c52:	c6a080e7          	jalr	-918(ra) # 48b8 <exit>
        printf("%s: wait wrong exit status\n", s);
     c56:	85d2                	mv	a1,s4
     c58:	00005517          	auipc	a0,0x5
     c5c:	94050513          	addi	a0,a0,-1728 # 5598 <malloc+0x872>
     c60:	00004097          	auipc	ra,0x4
     c64:	008080e7          	jalr	8(ra) # 4c68 <printf>
        exit(1);
     c68:	4505                	li	a0,1
     c6a:	00004097          	auipc	ra,0x4
     c6e:	c4e080e7          	jalr	-946(ra) # 48b8 <exit>
      exit(i);
     c72:	854a                	mv	a0,s2
     c74:	00004097          	auipc	ra,0x4
     c78:	c44080e7          	jalr	-956(ra) # 48b8 <exit>

0000000000000c7c <twochildren>:
{
     c7c:	1101                	addi	sp,sp,-32
     c7e:	ec06                	sd	ra,24(sp)
     c80:	e822                	sd	s0,16(sp)
     c82:	e426                	sd	s1,8(sp)
     c84:	e04a                	sd	s2,0(sp)
     c86:	1000                	addi	s0,sp,32
     c88:	892a                	mv	s2,a0
     c8a:	3e800493          	li	s1,1000
    int pid1 = fork();
     c8e:	00004097          	auipc	ra,0x4
     c92:	c22080e7          	jalr	-990(ra) # 48b0 <fork>
    if(pid1 < 0){
     c96:	02054c63          	bltz	a0,cce <twochildren+0x52>
    if(pid1 == 0){
     c9a:	c921                	beqz	a0,cea <twochildren+0x6e>
      int pid2 = fork();
     c9c:	00004097          	auipc	ra,0x4
     ca0:	c14080e7          	jalr	-1004(ra) # 48b0 <fork>
      if(pid2 < 0){
     ca4:	04054763          	bltz	a0,cf2 <twochildren+0x76>
      if(pid2 == 0){
     ca8:	c13d                	beqz	a0,d0e <twochildren+0x92>
        wait(0);
     caa:	4501                	li	a0,0
     cac:	00004097          	auipc	ra,0x4
     cb0:	c14080e7          	jalr	-1004(ra) # 48c0 <wait>
        wait(0);
     cb4:	4501                	li	a0,0
     cb6:	00004097          	auipc	ra,0x4
     cba:	c0a080e7          	jalr	-1014(ra) # 48c0 <wait>
  for(int i = 0; i < 1000; i++){
     cbe:	34fd                	addiw	s1,s1,-1
     cc0:	f4f9                	bnez	s1,c8e <twochildren+0x12>
}
     cc2:	60e2                	ld	ra,24(sp)
     cc4:	6442                	ld	s0,16(sp)
     cc6:	64a2                	ld	s1,8(sp)
     cc8:	6902                	ld	s2,0(sp)
     cca:	6105                	addi	sp,sp,32
     ccc:	8082                	ret
      printf("%s: fork failed\n", s);
     cce:	85ca                	mv	a1,s2
     cd0:	00005517          	auipc	a0,0x5
     cd4:	82850513          	addi	a0,a0,-2008 # 54f8 <malloc+0x7d2>
     cd8:	00004097          	auipc	ra,0x4
     cdc:	f90080e7          	jalr	-112(ra) # 4c68 <printf>
      exit(1);
     ce0:	4505                	li	a0,1
     ce2:	00004097          	auipc	ra,0x4
     ce6:	bd6080e7          	jalr	-1066(ra) # 48b8 <exit>
      exit(0);
     cea:	00004097          	auipc	ra,0x4
     cee:	bce080e7          	jalr	-1074(ra) # 48b8 <exit>
        printf("%s: fork failed\n", s);
     cf2:	85ca                	mv	a1,s2
     cf4:	00005517          	auipc	a0,0x5
     cf8:	80450513          	addi	a0,a0,-2044 # 54f8 <malloc+0x7d2>
     cfc:	00004097          	auipc	ra,0x4
     d00:	f6c080e7          	jalr	-148(ra) # 4c68 <printf>
        exit(1);
     d04:	4505                	li	a0,1
     d06:	00004097          	auipc	ra,0x4
     d0a:	bb2080e7          	jalr	-1102(ra) # 48b8 <exit>
        exit(0);
     d0e:	00004097          	auipc	ra,0x4
     d12:	baa080e7          	jalr	-1110(ra) # 48b8 <exit>

0000000000000d16 <forkfork>:
{
     d16:	7179                	addi	sp,sp,-48
     d18:	f406                	sd	ra,40(sp)
     d1a:	f022                	sd	s0,32(sp)
     d1c:	ec26                	sd	s1,24(sp)
     d1e:	1800                	addi	s0,sp,48
     d20:	84aa                	mv	s1,a0
    int pid = fork();
     d22:	00004097          	auipc	ra,0x4
     d26:	b8e080e7          	jalr	-1138(ra) # 48b0 <fork>
    if(pid < 0){
     d2a:	04054163          	bltz	a0,d6c <forkfork+0x56>
    if(pid == 0){
     d2e:	cd29                	beqz	a0,d88 <forkfork+0x72>
    int pid = fork();
     d30:	00004097          	auipc	ra,0x4
     d34:	b80080e7          	jalr	-1152(ra) # 48b0 <fork>
    if(pid < 0){
     d38:	02054a63          	bltz	a0,d6c <forkfork+0x56>
    if(pid == 0){
     d3c:	c531                	beqz	a0,d88 <forkfork+0x72>
    wait(&xstatus);
     d3e:	fdc40513          	addi	a0,s0,-36
     d42:	00004097          	auipc	ra,0x4
     d46:	b7e080e7          	jalr	-1154(ra) # 48c0 <wait>
    if(xstatus != 0) {
     d4a:	fdc42783          	lw	a5,-36(s0)
     d4e:	ebbd                	bnez	a5,dc4 <forkfork+0xae>
    wait(&xstatus);
     d50:	fdc40513          	addi	a0,s0,-36
     d54:	00004097          	auipc	ra,0x4
     d58:	b6c080e7          	jalr	-1172(ra) # 48c0 <wait>
    if(xstatus != 0) {
     d5c:	fdc42783          	lw	a5,-36(s0)
     d60:	e3b5                	bnez	a5,dc4 <forkfork+0xae>
}
     d62:	70a2                	ld	ra,40(sp)
     d64:	7402                	ld	s0,32(sp)
     d66:	64e2                	ld	s1,24(sp)
     d68:	6145                	addi	sp,sp,48
     d6a:	8082                	ret
      printf("%s: fork failed", s);
     d6c:	85a6                	mv	a1,s1
     d6e:	00005517          	auipc	a0,0x5
     d72:	84a50513          	addi	a0,a0,-1974 # 55b8 <malloc+0x892>
     d76:	00004097          	auipc	ra,0x4
     d7a:	ef2080e7          	jalr	-270(ra) # 4c68 <printf>
      exit(1);
     d7e:	4505                	li	a0,1
     d80:	00004097          	auipc	ra,0x4
     d84:	b38080e7          	jalr	-1224(ra) # 48b8 <exit>
{
     d88:	0c800493          	li	s1,200
        int pid1 = fork();
     d8c:	00004097          	auipc	ra,0x4
     d90:	b24080e7          	jalr	-1244(ra) # 48b0 <fork>
        if(pid1 < 0){
     d94:	00054f63          	bltz	a0,db2 <forkfork+0x9c>
        if(pid1 == 0){
     d98:	c115                	beqz	a0,dbc <forkfork+0xa6>
        wait(0);
     d9a:	4501                	li	a0,0
     d9c:	00004097          	auipc	ra,0x4
     da0:	b24080e7          	jalr	-1244(ra) # 48c0 <wait>
      for(int j = 0; j < 200; j++){
     da4:	34fd                	addiw	s1,s1,-1
     da6:	f0fd                	bnez	s1,d8c <forkfork+0x76>
      exit(0);
     da8:	4501                	li	a0,0
     daa:	00004097          	auipc	ra,0x4
     dae:	b0e080e7          	jalr	-1266(ra) # 48b8 <exit>
          exit(1);
     db2:	4505                	li	a0,1
     db4:	00004097          	auipc	ra,0x4
     db8:	b04080e7          	jalr	-1276(ra) # 48b8 <exit>
          exit(0);
     dbc:	00004097          	auipc	ra,0x4
     dc0:	afc080e7          	jalr	-1284(ra) # 48b8 <exit>
      printf("%s: fork in child failed", s);
     dc4:	85a6                	mv	a1,s1
     dc6:	00005517          	auipc	a0,0x5
     dca:	80250513          	addi	a0,a0,-2046 # 55c8 <malloc+0x8a2>
     dce:	00004097          	auipc	ra,0x4
     dd2:	e9a080e7          	jalr	-358(ra) # 4c68 <printf>
      exit(1);
     dd6:	4505                	li	a0,1
     dd8:	00004097          	auipc	ra,0x4
     ddc:	ae0080e7          	jalr	-1312(ra) # 48b8 <exit>

0000000000000de0 <reparent2>:
{
     de0:	1101                	addi	sp,sp,-32
     de2:	ec06                	sd	ra,24(sp)
     de4:	e822                	sd	s0,16(sp)
     de6:	e426                	sd	s1,8(sp)
     de8:	1000                	addi	s0,sp,32
     dea:	32000493          	li	s1,800
    int pid1 = fork();
     dee:	00004097          	auipc	ra,0x4
     df2:	ac2080e7          	jalr	-1342(ra) # 48b0 <fork>
    if(pid1 < 0){
     df6:	00054f63          	bltz	a0,e14 <reparent2+0x34>
    if(pid1 == 0){
     dfa:	c915                	beqz	a0,e2e <reparent2+0x4e>
    wait(0);
     dfc:	4501                	li	a0,0
     dfe:	00004097          	auipc	ra,0x4
     e02:	ac2080e7          	jalr	-1342(ra) # 48c0 <wait>
  for(int i = 0; i < 800; i++){
     e06:	34fd                	addiw	s1,s1,-1
     e08:	f0fd                	bnez	s1,dee <reparent2+0xe>
  exit(0);
     e0a:	4501                	li	a0,0
     e0c:	00004097          	auipc	ra,0x4
     e10:	aac080e7          	jalr	-1364(ra) # 48b8 <exit>
      printf("fork failed\n");
     e14:	00005517          	auipc	a0,0x5
     e18:	e7450513          	addi	a0,a0,-396 # 5c88 <malloc+0xf62>
     e1c:	00004097          	auipc	ra,0x4
     e20:	e4c080e7          	jalr	-436(ra) # 4c68 <printf>
      exit(1);
     e24:	4505                	li	a0,1
     e26:	00004097          	auipc	ra,0x4
     e2a:	a92080e7          	jalr	-1390(ra) # 48b8 <exit>
      fork();
     e2e:	00004097          	auipc	ra,0x4
     e32:	a82080e7          	jalr	-1406(ra) # 48b0 <fork>
      fork();
     e36:	00004097          	auipc	ra,0x4
     e3a:	a7a080e7          	jalr	-1414(ra) # 48b0 <fork>
      exit(0);
     e3e:	4501                	li	a0,0
     e40:	00004097          	auipc	ra,0x4
     e44:	a78080e7          	jalr	-1416(ra) # 48b8 <exit>

0000000000000e48 <createdelete>:
{
     e48:	7175                	addi	sp,sp,-144
     e4a:	e506                	sd	ra,136(sp)
     e4c:	e122                	sd	s0,128(sp)
     e4e:	fca6                	sd	s1,120(sp)
     e50:	f8ca                	sd	s2,112(sp)
     e52:	f4ce                	sd	s3,104(sp)
     e54:	f0d2                	sd	s4,96(sp)
     e56:	ecd6                	sd	s5,88(sp)
     e58:	e8da                	sd	s6,80(sp)
     e5a:	e4de                	sd	s7,72(sp)
     e5c:	e0e2                	sd	s8,64(sp)
     e5e:	fc66                	sd	s9,56(sp)
     e60:	0900                	addi	s0,sp,144
     e62:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
     e64:	4901                	li	s2,0
     e66:	4991                	li	s3,4
    pid = fork();
     e68:	00004097          	auipc	ra,0x4
     e6c:	a48080e7          	jalr	-1464(ra) # 48b0 <fork>
     e70:	84aa                	mv	s1,a0
    if(pid < 0){
     e72:	02054f63          	bltz	a0,eb0 <createdelete+0x68>
    if(pid == 0){
     e76:	c939                	beqz	a0,ecc <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
     e78:	2905                	addiw	s2,s2,1
     e7a:	ff3917e3          	bne	s2,s3,e68 <createdelete+0x20>
     e7e:	4491                	li	s1,4
    wait(&xstatus);
     e80:	f7c40513          	addi	a0,s0,-132
     e84:	00004097          	auipc	ra,0x4
     e88:	a3c080e7          	jalr	-1476(ra) # 48c0 <wait>
    if(xstatus != 0)
     e8c:	f7c42903          	lw	s2,-132(s0)
     e90:	0e091263          	bnez	s2,f74 <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
     e94:	34fd                	addiw	s1,s1,-1
     e96:	f4ed                	bnez	s1,e80 <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
     e98:	f8040123          	sb	zero,-126(s0)
     e9c:	03000993          	li	s3,48
     ea0:	5a7d                	li	s4,-1
     ea2:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
     ea6:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
     ea8:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
     eaa:	07400a93          	li	s5,116
     eae:	a29d                	j	1014 <createdelete+0x1cc>
      printf("fork failed\n", s);
     eb0:	85e6                	mv	a1,s9
     eb2:	00005517          	auipc	a0,0x5
     eb6:	dd650513          	addi	a0,a0,-554 # 5c88 <malloc+0xf62>
     eba:	00004097          	auipc	ra,0x4
     ebe:	dae080e7          	jalr	-594(ra) # 4c68 <printf>
      exit(1);
     ec2:	4505                	li	a0,1
     ec4:	00004097          	auipc	ra,0x4
     ec8:	9f4080e7          	jalr	-1548(ra) # 48b8 <exit>
      name[0] = 'p' + pi;
     ecc:	0709091b          	addiw	s2,s2,112
     ed0:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
     ed4:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
     ed8:	4951                	li	s2,20
     eda:	a015                	j	efe <createdelete+0xb6>
          printf("%s: create failed\n", s);
     edc:	85e6                	mv	a1,s9
     ede:	00004517          	auipc	a0,0x4
     ee2:	70a50513          	addi	a0,a0,1802 # 55e8 <malloc+0x8c2>
     ee6:	00004097          	auipc	ra,0x4
     eea:	d82080e7          	jalr	-638(ra) # 4c68 <printf>
          exit(1);
     eee:	4505                	li	a0,1
     ef0:	00004097          	auipc	ra,0x4
     ef4:	9c8080e7          	jalr	-1592(ra) # 48b8 <exit>
      for(i = 0; i < N; i++){
     ef8:	2485                	addiw	s1,s1,1
     efa:	07248863          	beq	s1,s2,f6a <createdelete+0x122>
        name[1] = '0' + i;
     efe:	0304879b          	addiw	a5,s1,48
     f02:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
     f06:	20200593          	li	a1,514
     f0a:	f8040513          	addi	a0,s0,-128
     f0e:	00004097          	auipc	ra,0x4
     f12:	9ea080e7          	jalr	-1558(ra) # 48f8 <open>
        if(fd < 0){
     f16:	fc0543e3          	bltz	a0,edc <createdelete+0x94>
        close(fd);
     f1a:	00004097          	auipc	ra,0x4
     f1e:	9c6080e7          	jalr	-1594(ra) # 48e0 <close>
        if(i > 0 && (i % 2 ) == 0){
     f22:	fc905be3          	blez	s1,ef8 <createdelete+0xb0>
     f26:	0014f793          	andi	a5,s1,1
     f2a:	f7f9                	bnez	a5,ef8 <createdelete+0xb0>
          name[1] = '0' + (i / 2);
     f2c:	01f4d79b          	srliw	a5,s1,0x1f
     f30:	9fa5                	addw	a5,a5,s1
     f32:	4017d79b          	sraiw	a5,a5,0x1
     f36:	0307879b          	addiw	a5,a5,48
     f3a:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
     f3e:	f8040513          	addi	a0,s0,-128
     f42:	00004097          	auipc	ra,0x4
     f46:	9c6080e7          	jalr	-1594(ra) # 4908 <unlink>
     f4a:	fa0557e3          	bgez	a0,ef8 <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
     f4e:	85e6                	mv	a1,s9
     f50:	00004517          	auipc	a0,0x4
     f54:	6b050513          	addi	a0,a0,1712 # 5600 <malloc+0x8da>
     f58:	00004097          	auipc	ra,0x4
     f5c:	d10080e7          	jalr	-752(ra) # 4c68 <printf>
            exit(1);
     f60:	4505                	li	a0,1
     f62:	00004097          	auipc	ra,0x4
     f66:	956080e7          	jalr	-1706(ra) # 48b8 <exit>
      exit(0);
     f6a:	4501                	li	a0,0
     f6c:	00004097          	auipc	ra,0x4
     f70:	94c080e7          	jalr	-1716(ra) # 48b8 <exit>
      exit(1);
     f74:	4505                	li	a0,1
     f76:	00004097          	auipc	ra,0x4
     f7a:	942080e7          	jalr	-1726(ra) # 48b8 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
     f7e:	f8040613          	addi	a2,s0,-128
     f82:	85e6                	mv	a1,s9
     f84:	00004517          	auipc	a0,0x4
     f88:	69450513          	addi	a0,a0,1684 # 5618 <malloc+0x8f2>
     f8c:	00004097          	auipc	ra,0x4
     f90:	cdc080e7          	jalr	-804(ra) # 4c68 <printf>
        exit(1);
     f94:	4505                	li	a0,1
     f96:	00004097          	auipc	ra,0x4
     f9a:	922080e7          	jalr	-1758(ra) # 48b8 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
     f9e:	054b7163          	bgeu	s6,s4,fe0 <createdelete+0x198>
      if(fd >= 0)
     fa2:	02055a63          	bgez	a0,fd6 <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
     fa6:	2485                	addiw	s1,s1,1
     fa8:	0ff4f493          	andi	s1,s1,255
     fac:	05548c63          	beq	s1,s5,1004 <createdelete+0x1bc>
      name[0] = 'p' + pi;
     fb0:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
     fb4:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
     fb8:	4581                	li	a1,0
     fba:	f8040513          	addi	a0,s0,-128
     fbe:	00004097          	auipc	ra,0x4
     fc2:	93a080e7          	jalr	-1734(ra) # 48f8 <open>
      if((i == 0 || i >= N/2) && fd < 0){
     fc6:	00090463          	beqz	s2,fce <createdelete+0x186>
     fca:	fd2bdae3          	bge	s7,s2,f9e <createdelete+0x156>
     fce:	fa0548e3          	bltz	a0,f7e <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
     fd2:	014b7963          	bgeu	s6,s4,fe4 <createdelete+0x19c>
        close(fd);
     fd6:	00004097          	auipc	ra,0x4
     fda:	90a080e7          	jalr	-1782(ra) # 48e0 <close>
     fde:	b7e1                	j	fa6 <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
     fe0:	fc0543e3          	bltz	a0,fa6 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
     fe4:	f8040613          	addi	a2,s0,-128
     fe8:	85e6                	mv	a1,s9
     fea:	00004517          	auipc	a0,0x4
     fee:	65650513          	addi	a0,a0,1622 # 5640 <malloc+0x91a>
     ff2:	00004097          	auipc	ra,0x4
     ff6:	c76080e7          	jalr	-906(ra) # 4c68 <printf>
        exit(1);
     ffa:	4505                	li	a0,1
     ffc:	00004097          	auipc	ra,0x4
    1000:	8bc080e7          	jalr	-1860(ra) # 48b8 <exit>
  for(i = 0; i < N; i++){
    1004:	2905                	addiw	s2,s2,1
    1006:	2a05                	addiw	s4,s4,1
    1008:	2985                	addiw	s3,s3,1
    100a:	0ff9f993          	andi	s3,s3,255
    100e:	47d1                	li	a5,20
    1010:	02f90a63          	beq	s2,a5,1044 <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    1014:	84e2                	mv	s1,s8
    1016:	bf69                	j	fb0 <createdelete+0x168>
  for(i = 0; i < N; i++){
    1018:	2905                	addiw	s2,s2,1
    101a:	0ff97913          	andi	s2,s2,255
    101e:	2985                	addiw	s3,s3,1
    1020:	0ff9f993          	andi	s3,s3,255
    1024:	03490863          	beq	s2,s4,1054 <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1028:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    102a:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    102e:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1032:	f8040513          	addi	a0,s0,-128
    1036:	00004097          	auipc	ra,0x4
    103a:	8d2080e7          	jalr	-1838(ra) # 4908 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    103e:	34fd                	addiw	s1,s1,-1
    1040:	f4ed                	bnez	s1,102a <createdelete+0x1e2>
    1042:	bfd9                	j	1018 <createdelete+0x1d0>
    1044:	03000993          	li	s3,48
    1048:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    104c:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    104e:	08400a13          	li	s4,132
    1052:	bfd9                	j	1028 <createdelete+0x1e0>
}
    1054:	60aa                	ld	ra,136(sp)
    1056:	640a                	ld	s0,128(sp)
    1058:	74e6                	ld	s1,120(sp)
    105a:	7946                	ld	s2,112(sp)
    105c:	79a6                	ld	s3,104(sp)
    105e:	7a06                	ld	s4,96(sp)
    1060:	6ae6                	ld	s5,88(sp)
    1062:	6b46                	ld	s6,80(sp)
    1064:	6ba6                	ld	s7,72(sp)
    1066:	6c06                	ld	s8,64(sp)
    1068:	7ce2                	ld	s9,56(sp)
    106a:	6149                	addi	sp,sp,144
    106c:	8082                	ret

000000000000106e <forktest>:
{
    106e:	7179                	addi	sp,sp,-48
    1070:	f406                	sd	ra,40(sp)
    1072:	f022                	sd	s0,32(sp)
    1074:	ec26                	sd	s1,24(sp)
    1076:	e84a                	sd	s2,16(sp)
    1078:	e44e                	sd	s3,8(sp)
    107a:	1800                	addi	s0,sp,48
    107c:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    107e:	4481                	li	s1,0
    1080:	3e800913          	li	s2,1000
    pid = fork();
    1084:	00004097          	auipc	ra,0x4
    1088:	82c080e7          	jalr	-2004(ra) # 48b0 <fork>
    if(pid < 0)
    108c:	02054863          	bltz	a0,10bc <forktest+0x4e>
    if(pid == 0)
    1090:	c115                	beqz	a0,10b4 <forktest+0x46>
  for(n=0; n<N; n++){
    1092:	2485                	addiw	s1,s1,1
    1094:	ff2498e3          	bne	s1,s2,1084 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    1098:	85ce                	mv	a1,s3
    109a:	00004517          	auipc	a0,0x4
    109e:	5e650513          	addi	a0,a0,1510 # 5680 <malloc+0x95a>
    10a2:	00004097          	auipc	ra,0x4
    10a6:	bc6080e7          	jalr	-1082(ra) # 4c68 <printf>
    exit(1);
    10aa:	4505                	li	a0,1
    10ac:	00004097          	auipc	ra,0x4
    10b0:	80c080e7          	jalr	-2036(ra) # 48b8 <exit>
      exit(0);
    10b4:	00004097          	auipc	ra,0x4
    10b8:	804080e7          	jalr	-2044(ra) # 48b8 <exit>
  if (n == 0) {
    10bc:	cc9d                	beqz	s1,10fa <forktest+0x8c>
  if(n == N){
    10be:	3e800793          	li	a5,1000
    10c2:	fcf48be3          	beq	s1,a5,1098 <forktest+0x2a>
  for(; n > 0; n--){
    10c6:	00905b63          	blez	s1,10dc <forktest+0x6e>
    if(wait(0) < 0){
    10ca:	4501                	li	a0,0
    10cc:	00003097          	auipc	ra,0x3
    10d0:	7f4080e7          	jalr	2036(ra) # 48c0 <wait>
    10d4:	04054163          	bltz	a0,1116 <forktest+0xa8>
  for(; n > 0; n--){
    10d8:	34fd                	addiw	s1,s1,-1
    10da:	f8e5                	bnez	s1,10ca <forktest+0x5c>
  if(wait(0) != -1){
    10dc:	4501                	li	a0,0
    10de:	00003097          	auipc	ra,0x3
    10e2:	7e2080e7          	jalr	2018(ra) # 48c0 <wait>
    10e6:	57fd                	li	a5,-1
    10e8:	04f51563          	bne	a0,a5,1132 <forktest+0xc4>
}
    10ec:	70a2                	ld	ra,40(sp)
    10ee:	7402                	ld	s0,32(sp)
    10f0:	64e2                	ld	s1,24(sp)
    10f2:	6942                	ld	s2,16(sp)
    10f4:	69a2                	ld	s3,8(sp)
    10f6:	6145                	addi	sp,sp,48
    10f8:	8082                	ret
    printf("%s: no fork at all!\n", s);
    10fa:	85ce                	mv	a1,s3
    10fc:	00004517          	auipc	a0,0x4
    1100:	56c50513          	addi	a0,a0,1388 # 5668 <malloc+0x942>
    1104:	00004097          	auipc	ra,0x4
    1108:	b64080e7          	jalr	-1180(ra) # 4c68 <printf>
    exit(1);
    110c:	4505                	li	a0,1
    110e:	00003097          	auipc	ra,0x3
    1112:	7aa080e7          	jalr	1962(ra) # 48b8 <exit>
      printf("%s: wait stopped early\n", s);
    1116:	85ce                	mv	a1,s3
    1118:	00004517          	auipc	a0,0x4
    111c:	59050513          	addi	a0,a0,1424 # 56a8 <malloc+0x982>
    1120:	00004097          	auipc	ra,0x4
    1124:	b48080e7          	jalr	-1208(ra) # 4c68 <printf>
      exit(1);
    1128:	4505                	li	a0,1
    112a:	00003097          	auipc	ra,0x3
    112e:	78e080e7          	jalr	1934(ra) # 48b8 <exit>
    printf("%s: wait got too many\n", s);
    1132:	85ce                	mv	a1,s3
    1134:	00004517          	auipc	a0,0x4
    1138:	58c50513          	addi	a0,a0,1420 # 56c0 <malloc+0x99a>
    113c:	00004097          	auipc	ra,0x4
    1140:	b2c080e7          	jalr	-1236(ra) # 4c68 <printf>
    exit(1);
    1144:	4505                	li	a0,1
    1146:	00003097          	auipc	ra,0x3
    114a:	772080e7          	jalr	1906(ra) # 48b8 <exit>

000000000000114e <kernmem>:
{
    114e:	715d                	addi	sp,sp,-80
    1150:	e486                	sd	ra,72(sp)
    1152:	e0a2                	sd	s0,64(sp)
    1154:	fc26                	sd	s1,56(sp)
    1156:	f84a                	sd	s2,48(sp)
    1158:	f44e                	sd	s3,40(sp)
    115a:	f052                	sd	s4,32(sp)
    115c:	ec56                	sd	s5,24(sp)
    115e:	0880                	addi	s0,sp,80
    1160:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1162:	4485                	li	s1,1
    1164:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    1166:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1168:	69b1                	lui	s3,0xc
    116a:	35098993          	addi	s3,s3,848 # c350 <buf+0x2b00>
    116e:	1003d937          	lui	s2,0x1003d
    1172:	090e                	slli	s2,s2,0x3
    1174:	48090913          	addi	s2,s2,1152 # 1003d480 <__BSS_END__+0x10030c20>
    pid = fork();
    1178:	00003097          	auipc	ra,0x3
    117c:	738080e7          	jalr	1848(ra) # 48b0 <fork>
    if(pid < 0){
    1180:	02054963          	bltz	a0,11b2 <kernmem+0x64>
    if(pid == 0){
    1184:	c529                	beqz	a0,11ce <kernmem+0x80>
    wait(&xstatus);
    1186:	fbc40513          	addi	a0,s0,-68
    118a:	00003097          	auipc	ra,0x3
    118e:	736080e7          	jalr	1846(ra) # 48c0 <wait>
    if(xstatus != -1)  // did kernel kill child?
    1192:	fbc42783          	lw	a5,-68(s0)
    1196:	05579c63          	bne	a5,s5,11ee <kernmem+0xa0>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    119a:	94ce                	add	s1,s1,s3
    119c:	fd249ee3          	bne	s1,s2,1178 <kernmem+0x2a>
}
    11a0:	60a6                	ld	ra,72(sp)
    11a2:	6406                	ld	s0,64(sp)
    11a4:	74e2                	ld	s1,56(sp)
    11a6:	7942                	ld	s2,48(sp)
    11a8:	79a2                	ld	s3,40(sp)
    11aa:	7a02                	ld	s4,32(sp)
    11ac:	6ae2                	ld	s5,24(sp)
    11ae:	6161                	addi	sp,sp,80
    11b0:	8082                	ret
      printf("%s: fork failed\n", s);
    11b2:	85d2                	mv	a1,s4
    11b4:	00004517          	auipc	a0,0x4
    11b8:	34450513          	addi	a0,a0,836 # 54f8 <malloc+0x7d2>
    11bc:	00004097          	auipc	ra,0x4
    11c0:	aac080e7          	jalr	-1364(ra) # 4c68 <printf>
      exit(1);
    11c4:	4505                	li	a0,1
    11c6:	00003097          	auipc	ra,0x3
    11ca:	6f2080e7          	jalr	1778(ra) # 48b8 <exit>
      printf("%s: oops could read %x = %x\n", a, *a);
    11ce:	0004c603          	lbu	a2,0(s1)
    11d2:	85a6                	mv	a1,s1
    11d4:	00004517          	auipc	a0,0x4
    11d8:	50450513          	addi	a0,a0,1284 # 56d8 <malloc+0x9b2>
    11dc:	00004097          	auipc	ra,0x4
    11e0:	a8c080e7          	jalr	-1396(ra) # 4c68 <printf>
      exit(1);
    11e4:	4505                	li	a0,1
    11e6:	00003097          	auipc	ra,0x3
    11ea:	6d2080e7          	jalr	1746(ra) # 48b8 <exit>
      exit(1);
    11ee:	4505                	li	a0,1
    11f0:	00003097          	auipc	ra,0x3
    11f4:	6c8080e7          	jalr	1736(ra) # 48b8 <exit>

00000000000011f8 <stacktest>:

// check that there's an invalid page beneath
// the user stack, to catch stack overflow.
void
stacktest(char *s)
{
    11f8:	7179                	addi	sp,sp,-48
    11fa:	f406                	sd	ra,40(sp)
    11fc:	f022                	sd	s0,32(sp)
    11fe:	ec26                	sd	s1,24(sp)
    1200:	1800                	addi	s0,sp,48
    1202:	84aa                	mv	s1,a0
  int pid;
  int xstatus;
  
  pid = fork();
    1204:	00003097          	auipc	ra,0x3
    1208:	6ac080e7          	jalr	1708(ra) # 48b0 <fork>
  if(pid == 0) {
    120c:	c115                	beqz	a0,1230 <stacktest+0x38>
    char *sp = (char *) r_sp();
    sp -= PGSIZE;
    // the *sp should cause a trap.
    printf("%s: stacktest: read below stack %p\n", *sp);
    exit(1);
  } else if(pid < 0){
    120e:	04054363          	bltz	a0,1254 <stacktest+0x5c>
    printf("%s: fork failed\n", s);
    exit(1);
  }
  wait(&xstatus);
    1212:	fdc40513          	addi	a0,s0,-36
    1216:	00003097          	auipc	ra,0x3
    121a:	6aa080e7          	jalr	1706(ra) # 48c0 <wait>
  if(xstatus == -1)  // kernel killed child?
    121e:	fdc42503          	lw	a0,-36(s0)
    1222:	57fd                	li	a5,-1
    1224:	04f50663          	beq	a0,a5,1270 <stacktest+0x78>
    exit(0);
  else
    exit(xstatus);
    1228:	00003097          	auipc	ra,0x3
    122c:	690080e7          	jalr	1680(ra) # 48b8 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    1230:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", *sp);
    1232:	77fd                	lui	a5,0xfffff
    1234:	97ba                	add	a5,a5,a4
    1236:	0007c583          	lbu	a1,0(a5) # fffffffffffff000 <__BSS_END__+0xffffffffffff27a0>
    123a:	00004517          	auipc	a0,0x4
    123e:	4be50513          	addi	a0,a0,1214 # 56f8 <malloc+0x9d2>
    1242:	00004097          	auipc	ra,0x4
    1246:	a26080e7          	jalr	-1498(ra) # 4c68 <printf>
    exit(1);
    124a:	4505                	li	a0,1
    124c:	00003097          	auipc	ra,0x3
    1250:	66c080e7          	jalr	1644(ra) # 48b8 <exit>
    printf("%s: fork failed\n", s);
    1254:	85a6                	mv	a1,s1
    1256:	00004517          	auipc	a0,0x4
    125a:	2a250513          	addi	a0,a0,674 # 54f8 <malloc+0x7d2>
    125e:	00004097          	auipc	ra,0x4
    1262:	a0a080e7          	jalr	-1526(ra) # 4c68 <printf>
    exit(1);
    1266:	4505                	li	a0,1
    1268:	00003097          	auipc	ra,0x3
    126c:	650080e7          	jalr	1616(ra) # 48b8 <exit>
    exit(0);
    1270:	4501                	li	a0,0
    1272:	00003097          	auipc	ra,0x3
    1276:	646080e7          	jalr	1606(ra) # 48b8 <exit>

000000000000127a <fourteen>:
{
    127a:	1101                	addi	sp,sp,-32
    127c:	ec06                	sd	ra,24(sp)
    127e:	e822                	sd	s0,16(sp)
    1280:	e426                	sd	s1,8(sp)
    1282:	1000                	addi	s0,sp,32
    1284:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    1286:	00004517          	auipc	a0,0x4
    128a:	66a50513          	addi	a0,a0,1642 # 58f0 <malloc+0xbca>
    128e:	00003097          	auipc	ra,0x3
    1292:	692080e7          	jalr	1682(ra) # 4920 <mkdir>
    1296:	e141                	bnez	a0,1316 <fourteen+0x9c>
  if(mkdir("12345678901234/123456789012345") != 0){
    1298:	00004517          	auipc	a0,0x4
    129c:	4b050513          	addi	a0,a0,1200 # 5748 <malloc+0xa22>
    12a0:	00003097          	auipc	ra,0x3
    12a4:	680080e7          	jalr	1664(ra) # 4920 <mkdir>
    12a8:	e549                	bnez	a0,1332 <fourteen+0xb8>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    12aa:	20000593          	li	a1,512
    12ae:	00004517          	auipc	a0,0x4
    12b2:	4f250513          	addi	a0,a0,1266 # 57a0 <malloc+0xa7a>
    12b6:	00003097          	auipc	ra,0x3
    12ba:	642080e7          	jalr	1602(ra) # 48f8 <open>
  if(fd < 0){
    12be:	08054863          	bltz	a0,134e <fourteen+0xd4>
  close(fd);
    12c2:	00003097          	auipc	ra,0x3
    12c6:	61e080e7          	jalr	1566(ra) # 48e0 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    12ca:	4581                	li	a1,0
    12cc:	00004517          	auipc	a0,0x4
    12d0:	54c50513          	addi	a0,a0,1356 # 5818 <malloc+0xaf2>
    12d4:	00003097          	auipc	ra,0x3
    12d8:	624080e7          	jalr	1572(ra) # 48f8 <open>
  if(fd < 0){
    12dc:	08054763          	bltz	a0,136a <fourteen+0xf0>
  close(fd);
    12e0:	00003097          	auipc	ra,0x3
    12e4:	600080e7          	jalr	1536(ra) # 48e0 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    12e8:	00004517          	auipc	a0,0x4
    12ec:	5a050513          	addi	a0,a0,1440 # 5888 <malloc+0xb62>
    12f0:	00003097          	auipc	ra,0x3
    12f4:	630080e7          	jalr	1584(ra) # 4920 <mkdir>
    12f8:	c559                	beqz	a0,1386 <fourteen+0x10c>
  if(mkdir("123456789012345/12345678901234") == 0){
    12fa:	00004517          	auipc	a0,0x4
    12fe:	5e650513          	addi	a0,a0,1510 # 58e0 <malloc+0xbba>
    1302:	00003097          	auipc	ra,0x3
    1306:	61e080e7          	jalr	1566(ra) # 4920 <mkdir>
    130a:	cd41                	beqz	a0,13a2 <fourteen+0x128>
}
    130c:	60e2                	ld	ra,24(sp)
    130e:	6442                	ld	s0,16(sp)
    1310:	64a2                	ld	s1,8(sp)
    1312:	6105                	addi	sp,sp,32
    1314:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    1316:	85a6                	mv	a1,s1
    1318:	00004517          	auipc	a0,0x4
    131c:	40850513          	addi	a0,a0,1032 # 5720 <malloc+0x9fa>
    1320:	00004097          	auipc	ra,0x4
    1324:	948080e7          	jalr	-1720(ra) # 4c68 <printf>
    exit(1);
    1328:	4505                	li	a0,1
    132a:	00003097          	auipc	ra,0x3
    132e:	58e080e7          	jalr	1422(ra) # 48b8 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    1332:	85a6                	mv	a1,s1
    1334:	00004517          	auipc	a0,0x4
    1338:	43450513          	addi	a0,a0,1076 # 5768 <malloc+0xa42>
    133c:	00004097          	auipc	ra,0x4
    1340:	92c080e7          	jalr	-1748(ra) # 4c68 <printf>
    exit(1);
    1344:	4505                	li	a0,1
    1346:	00003097          	auipc	ra,0x3
    134a:	572080e7          	jalr	1394(ra) # 48b8 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    134e:	85a6                	mv	a1,s1
    1350:	00004517          	auipc	a0,0x4
    1354:	48050513          	addi	a0,a0,1152 # 57d0 <malloc+0xaaa>
    1358:	00004097          	auipc	ra,0x4
    135c:	910080e7          	jalr	-1776(ra) # 4c68 <printf>
    exit(1);
    1360:	4505                	li	a0,1
    1362:	00003097          	auipc	ra,0x3
    1366:	556080e7          	jalr	1366(ra) # 48b8 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    136a:	85a6                	mv	a1,s1
    136c:	00004517          	auipc	a0,0x4
    1370:	4dc50513          	addi	a0,a0,1244 # 5848 <malloc+0xb22>
    1374:	00004097          	auipc	ra,0x4
    1378:	8f4080e7          	jalr	-1804(ra) # 4c68 <printf>
    exit(1);
    137c:	4505                	li	a0,1
    137e:	00003097          	auipc	ra,0x3
    1382:	53a080e7          	jalr	1338(ra) # 48b8 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    1386:	85a6                	mv	a1,s1
    1388:	00004517          	auipc	a0,0x4
    138c:	52050513          	addi	a0,a0,1312 # 58a8 <malloc+0xb82>
    1390:	00004097          	auipc	ra,0x4
    1394:	8d8080e7          	jalr	-1832(ra) # 4c68 <printf>
    exit(1);
    1398:	4505                	li	a0,1
    139a:	00003097          	auipc	ra,0x3
    139e:	51e080e7          	jalr	1310(ra) # 48b8 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    13a2:	85a6                	mv	a1,s1
    13a4:	00004517          	auipc	a0,0x4
    13a8:	55c50513          	addi	a0,a0,1372 # 5900 <malloc+0xbda>
    13ac:	00004097          	auipc	ra,0x4
    13b0:	8bc080e7          	jalr	-1860(ra) # 4c68 <printf>
    exit(1);
    13b4:	4505                	li	a0,1
    13b6:	00003097          	auipc	ra,0x3
    13ba:	502080e7          	jalr	1282(ra) # 48b8 <exit>

00000000000013be <iputtest>:
{
    13be:	1101                	addi	sp,sp,-32
    13c0:	ec06                	sd	ra,24(sp)
    13c2:	e822                	sd	s0,16(sp)
    13c4:	e426                	sd	s1,8(sp)
    13c6:	1000                	addi	s0,sp,32
    13c8:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    13ca:	00004517          	auipc	a0,0x4
    13ce:	56e50513          	addi	a0,a0,1390 # 5938 <malloc+0xc12>
    13d2:	00003097          	auipc	ra,0x3
    13d6:	54e080e7          	jalr	1358(ra) # 4920 <mkdir>
    13da:	04054563          	bltz	a0,1424 <iputtest+0x66>
  if(chdir("iputdir") < 0){
    13de:	00004517          	auipc	a0,0x4
    13e2:	55a50513          	addi	a0,a0,1370 # 5938 <malloc+0xc12>
    13e6:	00003097          	auipc	ra,0x3
    13ea:	542080e7          	jalr	1346(ra) # 4928 <chdir>
    13ee:	04054963          	bltz	a0,1440 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    13f2:	00004517          	auipc	a0,0x4
    13f6:	58650513          	addi	a0,a0,1414 # 5978 <malloc+0xc52>
    13fa:	00003097          	auipc	ra,0x3
    13fe:	50e080e7          	jalr	1294(ra) # 4908 <unlink>
    1402:	04054d63          	bltz	a0,145c <iputtest+0x9e>
  if(chdir("/") < 0){
    1406:	00004517          	auipc	a0,0x4
    140a:	5a250513          	addi	a0,a0,1442 # 59a8 <malloc+0xc82>
    140e:	00003097          	auipc	ra,0x3
    1412:	51a080e7          	jalr	1306(ra) # 4928 <chdir>
    1416:	06054163          	bltz	a0,1478 <iputtest+0xba>
}
    141a:	60e2                	ld	ra,24(sp)
    141c:	6442                	ld	s0,16(sp)
    141e:	64a2                	ld	s1,8(sp)
    1420:	6105                	addi	sp,sp,32
    1422:	8082                	ret
    printf("%s: mkdir failed\n", s);
    1424:	85a6                	mv	a1,s1
    1426:	00004517          	auipc	a0,0x4
    142a:	51a50513          	addi	a0,a0,1306 # 5940 <malloc+0xc1a>
    142e:	00004097          	auipc	ra,0x4
    1432:	83a080e7          	jalr	-1990(ra) # 4c68 <printf>
    exit(1);
    1436:	4505                	li	a0,1
    1438:	00003097          	auipc	ra,0x3
    143c:	480080e7          	jalr	1152(ra) # 48b8 <exit>
    printf("%s: chdir iputdir failed\n", s);
    1440:	85a6                	mv	a1,s1
    1442:	00004517          	auipc	a0,0x4
    1446:	51650513          	addi	a0,a0,1302 # 5958 <malloc+0xc32>
    144a:	00004097          	auipc	ra,0x4
    144e:	81e080e7          	jalr	-2018(ra) # 4c68 <printf>
    exit(1);
    1452:	4505                	li	a0,1
    1454:	00003097          	auipc	ra,0x3
    1458:	464080e7          	jalr	1124(ra) # 48b8 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    145c:	85a6                	mv	a1,s1
    145e:	00004517          	auipc	a0,0x4
    1462:	52a50513          	addi	a0,a0,1322 # 5988 <malloc+0xc62>
    1466:	00004097          	auipc	ra,0x4
    146a:	802080e7          	jalr	-2046(ra) # 4c68 <printf>
    exit(1);
    146e:	4505                	li	a0,1
    1470:	00003097          	auipc	ra,0x3
    1474:	448080e7          	jalr	1096(ra) # 48b8 <exit>
    printf("%s: chdir / failed\n", s);
    1478:	85a6                	mv	a1,s1
    147a:	00004517          	auipc	a0,0x4
    147e:	53650513          	addi	a0,a0,1334 # 59b0 <malloc+0xc8a>
    1482:	00003097          	auipc	ra,0x3
    1486:	7e6080e7          	jalr	2022(ra) # 4c68 <printf>
    exit(1);
    148a:	4505                	li	a0,1
    148c:	00003097          	auipc	ra,0x3
    1490:	42c080e7          	jalr	1068(ra) # 48b8 <exit>

0000000000001494 <exitiputtest>:
{
    1494:	7179                	addi	sp,sp,-48
    1496:	f406                	sd	ra,40(sp)
    1498:	f022                	sd	s0,32(sp)
    149a:	ec26                	sd	s1,24(sp)
    149c:	1800                	addi	s0,sp,48
    149e:	84aa                	mv	s1,a0
  pid = fork();
    14a0:	00003097          	auipc	ra,0x3
    14a4:	410080e7          	jalr	1040(ra) # 48b0 <fork>
  if(pid < 0){
    14a8:	04054663          	bltz	a0,14f4 <exitiputtest+0x60>
  if(pid == 0){
    14ac:	ed45                	bnez	a0,1564 <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    14ae:	00004517          	auipc	a0,0x4
    14b2:	48a50513          	addi	a0,a0,1162 # 5938 <malloc+0xc12>
    14b6:	00003097          	auipc	ra,0x3
    14ba:	46a080e7          	jalr	1130(ra) # 4920 <mkdir>
    14be:	04054963          	bltz	a0,1510 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    14c2:	00004517          	auipc	a0,0x4
    14c6:	47650513          	addi	a0,a0,1142 # 5938 <malloc+0xc12>
    14ca:	00003097          	auipc	ra,0x3
    14ce:	45e080e7          	jalr	1118(ra) # 4928 <chdir>
    14d2:	04054d63          	bltz	a0,152c <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    14d6:	00004517          	auipc	a0,0x4
    14da:	4a250513          	addi	a0,a0,1186 # 5978 <malloc+0xc52>
    14de:	00003097          	auipc	ra,0x3
    14e2:	42a080e7          	jalr	1066(ra) # 4908 <unlink>
    14e6:	06054163          	bltz	a0,1548 <exitiputtest+0xb4>
    exit(0);
    14ea:	4501                	li	a0,0
    14ec:	00003097          	auipc	ra,0x3
    14f0:	3cc080e7          	jalr	972(ra) # 48b8 <exit>
    printf("%s: fork failed\n", s);
    14f4:	85a6                	mv	a1,s1
    14f6:	00004517          	auipc	a0,0x4
    14fa:	00250513          	addi	a0,a0,2 # 54f8 <malloc+0x7d2>
    14fe:	00003097          	auipc	ra,0x3
    1502:	76a080e7          	jalr	1898(ra) # 4c68 <printf>
    exit(1);
    1506:	4505                	li	a0,1
    1508:	00003097          	auipc	ra,0x3
    150c:	3b0080e7          	jalr	944(ra) # 48b8 <exit>
      printf("%s: mkdir failed\n", s);
    1510:	85a6                	mv	a1,s1
    1512:	00004517          	auipc	a0,0x4
    1516:	42e50513          	addi	a0,a0,1070 # 5940 <malloc+0xc1a>
    151a:	00003097          	auipc	ra,0x3
    151e:	74e080e7          	jalr	1870(ra) # 4c68 <printf>
      exit(1);
    1522:	4505                	li	a0,1
    1524:	00003097          	auipc	ra,0x3
    1528:	394080e7          	jalr	916(ra) # 48b8 <exit>
      printf("%s: child chdir failed\n", s);
    152c:	85a6                	mv	a1,s1
    152e:	00004517          	auipc	a0,0x4
    1532:	49a50513          	addi	a0,a0,1178 # 59c8 <malloc+0xca2>
    1536:	00003097          	auipc	ra,0x3
    153a:	732080e7          	jalr	1842(ra) # 4c68 <printf>
      exit(1);
    153e:	4505                	li	a0,1
    1540:	00003097          	auipc	ra,0x3
    1544:	378080e7          	jalr	888(ra) # 48b8 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    1548:	85a6                	mv	a1,s1
    154a:	00004517          	auipc	a0,0x4
    154e:	43e50513          	addi	a0,a0,1086 # 5988 <malloc+0xc62>
    1552:	00003097          	auipc	ra,0x3
    1556:	716080e7          	jalr	1814(ra) # 4c68 <printf>
      exit(1);
    155a:	4505                	li	a0,1
    155c:	00003097          	auipc	ra,0x3
    1560:	35c080e7          	jalr	860(ra) # 48b8 <exit>
  wait(&xstatus);
    1564:	fdc40513          	addi	a0,s0,-36
    1568:	00003097          	auipc	ra,0x3
    156c:	358080e7          	jalr	856(ra) # 48c0 <wait>
  exit(xstatus);
    1570:	fdc42503          	lw	a0,-36(s0)
    1574:	00003097          	auipc	ra,0x3
    1578:	344080e7          	jalr	836(ra) # 48b8 <exit>

000000000000157c <rmdot>:
{
    157c:	1101                	addi	sp,sp,-32
    157e:	ec06                	sd	ra,24(sp)
    1580:	e822                	sd	s0,16(sp)
    1582:	e426                	sd	s1,8(sp)
    1584:	1000                	addi	s0,sp,32
    1586:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    1588:	00004517          	auipc	a0,0x4
    158c:	45850513          	addi	a0,a0,1112 # 59e0 <malloc+0xcba>
    1590:	00003097          	auipc	ra,0x3
    1594:	390080e7          	jalr	912(ra) # 4920 <mkdir>
    1598:	e549                	bnez	a0,1622 <rmdot+0xa6>
  if(chdir("dots") != 0){
    159a:	00004517          	auipc	a0,0x4
    159e:	44650513          	addi	a0,a0,1094 # 59e0 <malloc+0xcba>
    15a2:	00003097          	auipc	ra,0x3
    15a6:	386080e7          	jalr	902(ra) # 4928 <chdir>
    15aa:	e951                	bnez	a0,163e <rmdot+0xc2>
  if(unlink(".") == 0){
    15ac:	00004517          	auipc	a0,0x4
    15b0:	46c50513          	addi	a0,a0,1132 # 5a18 <malloc+0xcf2>
    15b4:	00003097          	auipc	ra,0x3
    15b8:	354080e7          	jalr	852(ra) # 4908 <unlink>
    15bc:	cd59                	beqz	a0,165a <rmdot+0xde>
  if(unlink("..") == 0){
    15be:	00004517          	auipc	a0,0x4
    15c2:	47a50513          	addi	a0,a0,1146 # 5a38 <malloc+0xd12>
    15c6:	00003097          	auipc	ra,0x3
    15ca:	342080e7          	jalr	834(ra) # 4908 <unlink>
    15ce:	c545                	beqz	a0,1676 <rmdot+0xfa>
  if(chdir("/") != 0){
    15d0:	00004517          	auipc	a0,0x4
    15d4:	3d850513          	addi	a0,a0,984 # 59a8 <malloc+0xc82>
    15d8:	00003097          	auipc	ra,0x3
    15dc:	350080e7          	jalr	848(ra) # 4928 <chdir>
    15e0:	e94d                	bnez	a0,1692 <rmdot+0x116>
  if(unlink("dots/.") == 0){
    15e2:	00004517          	auipc	a0,0x4
    15e6:	47650513          	addi	a0,a0,1142 # 5a58 <malloc+0xd32>
    15ea:	00003097          	auipc	ra,0x3
    15ee:	31e080e7          	jalr	798(ra) # 4908 <unlink>
    15f2:	cd55                	beqz	a0,16ae <rmdot+0x132>
  if(unlink("dots/..") == 0){
    15f4:	00004517          	auipc	a0,0x4
    15f8:	48c50513          	addi	a0,a0,1164 # 5a80 <malloc+0xd5a>
    15fc:	00003097          	auipc	ra,0x3
    1600:	30c080e7          	jalr	780(ra) # 4908 <unlink>
    1604:	c179                	beqz	a0,16ca <rmdot+0x14e>
  if(unlink("dots") != 0){
    1606:	00004517          	auipc	a0,0x4
    160a:	3da50513          	addi	a0,a0,986 # 59e0 <malloc+0xcba>
    160e:	00003097          	auipc	ra,0x3
    1612:	2fa080e7          	jalr	762(ra) # 4908 <unlink>
    1616:	e961                	bnez	a0,16e6 <rmdot+0x16a>
}
    1618:	60e2                	ld	ra,24(sp)
    161a:	6442                	ld	s0,16(sp)
    161c:	64a2                	ld	s1,8(sp)
    161e:	6105                	addi	sp,sp,32
    1620:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    1622:	85a6                	mv	a1,s1
    1624:	00004517          	auipc	a0,0x4
    1628:	3c450513          	addi	a0,a0,964 # 59e8 <malloc+0xcc2>
    162c:	00003097          	auipc	ra,0x3
    1630:	63c080e7          	jalr	1596(ra) # 4c68 <printf>
    exit(1);
    1634:	4505                	li	a0,1
    1636:	00003097          	auipc	ra,0x3
    163a:	282080e7          	jalr	642(ra) # 48b8 <exit>
    printf("%s: chdir dots failed\n", s);
    163e:	85a6                	mv	a1,s1
    1640:	00004517          	auipc	a0,0x4
    1644:	3c050513          	addi	a0,a0,960 # 5a00 <malloc+0xcda>
    1648:	00003097          	auipc	ra,0x3
    164c:	620080e7          	jalr	1568(ra) # 4c68 <printf>
    exit(1);
    1650:	4505                	li	a0,1
    1652:	00003097          	auipc	ra,0x3
    1656:	266080e7          	jalr	614(ra) # 48b8 <exit>
    printf("%s: rm . worked!\n", s);
    165a:	85a6                	mv	a1,s1
    165c:	00004517          	auipc	a0,0x4
    1660:	3c450513          	addi	a0,a0,964 # 5a20 <malloc+0xcfa>
    1664:	00003097          	auipc	ra,0x3
    1668:	604080e7          	jalr	1540(ra) # 4c68 <printf>
    exit(1);
    166c:	4505                	li	a0,1
    166e:	00003097          	auipc	ra,0x3
    1672:	24a080e7          	jalr	586(ra) # 48b8 <exit>
    printf("%s: rm .. worked!\n", s);
    1676:	85a6                	mv	a1,s1
    1678:	00004517          	auipc	a0,0x4
    167c:	3c850513          	addi	a0,a0,968 # 5a40 <malloc+0xd1a>
    1680:	00003097          	auipc	ra,0x3
    1684:	5e8080e7          	jalr	1512(ra) # 4c68 <printf>
    exit(1);
    1688:	4505                	li	a0,1
    168a:	00003097          	auipc	ra,0x3
    168e:	22e080e7          	jalr	558(ra) # 48b8 <exit>
    printf("%s: chdir / failed\n", s);
    1692:	85a6                	mv	a1,s1
    1694:	00004517          	auipc	a0,0x4
    1698:	31c50513          	addi	a0,a0,796 # 59b0 <malloc+0xc8a>
    169c:	00003097          	auipc	ra,0x3
    16a0:	5cc080e7          	jalr	1484(ra) # 4c68 <printf>
    exit(1);
    16a4:	4505                	li	a0,1
    16a6:	00003097          	auipc	ra,0x3
    16aa:	212080e7          	jalr	530(ra) # 48b8 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    16ae:	85a6                	mv	a1,s1
    16b0:	00004517          	auipc	a0,0x4
    16b4:	3b050513          	addi	a0,a0,944 # 5a60 <malloc+0xd3a>
    16b8:	00003097          	auipc	ra,0x3
    16bc:	5b0080e7          	jalr	1456(ra) # 4c68 <printf>
    exit(1);
    16c0:	4505                	li	a0,1
    16c2:	00003097          	auipc	ra,0x3
    16c6:	1f6080e7          	jalr	502(ra) # 48b8 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    16ca:	85a6                	mv	a1,s1
    16cc:	00004517          	auipc	a0,0x4
    16d0:	3bc50513          	addi	a0,a0,956 # 5a88 <malloc+0xd62>
    16d4:	00003097          	auipc	ra,0x3
    16d8:	594080e7          	jalr	1428(ra) # 4c68 <printf>
    exit(1);
    16dc:	4505                	li	a0,1
    16de:	00003097          	auipc	ra,0x3
    16e2:	1da080e7          	jalr	474(ra) # 48b8 <exit>
    printf("%s: unlink dots failed!\n", s);
    16e6:	85a6                	mv	a1,s1
    16e8:	00004517          	auipc	a0,0x4
    16ec:	3c050513          	addi	a0,a0,960 # 5aa8 <malloc+0xd82>
    16f0:	00003097          	auipc	ra,0x3
    16f4:	578080e7          	jalr	1400(ra) # 4c68 <printf>
    exit(1);
    16f8:	4505                	li	a0,1
    16fa:	00003097          	auipc	ra,0x3
    16fe:	1be080e7          	jalr	446(ra) # 48b8 <exit>

0000000000001702 <openiputtest>:
{
    1702:	7179                	addi	sp,sp,-48
    1704:	f406                	sd	ra,40(sp)
    1706:	f022                	sd	s0,32(sp)
    1708:	ec26                	sd	s1,24(sp)
    170a:	1800                	addi	s0,sp,48
    170c:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    170e:	00004517          	auipc	a0,0x4
    1712:	3ba50513          	addi	a0,a0,954 # 5ac8 <malloc+0xda2>
    1716:	00003097          	auipc	ra,0x3
    171a:	20a080e7          	jalr	522(ra) # 4920 <mkdir>
    171e:	04054263          	bltz	a0,1762 <openiputtest+0x60>
  pid = fork();
    1722:	00003097          	auipc	ra,0x3
    1726:	18e080e7          	jalr	398(ra) # 48b0 <fork>
  if(pid < 0){
    172a:	04054a63          	bltz	a0,177e <openiputtest+0x7c>
  if(pid == 0){
    172e:	e93d                	bnez	a0,17a4 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    1730:	4589                	li	a1,2
    1732:	00004517          	auipc	a0,0x4
    1736:	39650513          	addi	a0,a0,918 # 5ac8 <malloc+0xda2>
    173a:	00003097          	auipc	ra,0x3
    173e:	1be080e7          	jalr	446(ra) # 48f8 <open>
    if(fd >= 0){
    1742:	04054c63          	bltz	a0,179a <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    1746:	85a6                	mv	a1,s1
    1748:	00004517          	auipc	a0,0x4
    174c:	3a050513          	addi	a0,a0,928 # 5ae8 <malloc+0xdc2>
    1750:	00003097          	auipc	ra,0x3
    1754:	518080e7          	jalr	1304(ra) # 4c68 <printf>
      exit(1);
    1758:	4505                	li	a0,1
    175a:	00003097          	auipc	ra,0x3
    175e:	15e080e7          	jalr	350(ra) # 48b8 <exit>
    printf("%s: mkdir oidir failed\n", s);
    1762:	85a6                	mv	a1,s1
    1764:	00004517          	auipc	a0,0x4
    1768:	36c50513          	addi	a0,a0,876 # 5ad0 <malloc+0xdaa>
    176c:	00003097          	auipc	ra,0x3
    1770:	4fc080e7          	jalr	1276(ra) # 4c68 <printf>
    exit(1);
    1774:	4505                	li	a0,1
    1776:	00003097          	auipc	ra,0x3
    177a:	142080e7          	jalr	322(ra) # 48b8 <exit>
    printf("%s: fork failed\n", s);
    177e:	85a6                	mv	a1,s1
    1780:	00004517          	auipc	a0,0x4
    1784:	d7850513          	addi	a0,a0,-648 # 54f8 <malloc+0x7d2>
    1788:	00003097          	auipc	ra,0x3
    178c:	4e0080e7          	jalr	1248(ra) # 4c68 <printf>
    exit(1);
    1790:	4505                	li	a0,1
    1792:	00003097          	auipc	ra,0x3
    1796:	126080e7          	jalr	294(ra) # 48b8 <exit>
    exit(0);
    179a:	4501                	li	a0,0
    179c:	00003097          	auipc	ra,0x3
    17a0:	11c080e7          	jalr	284(ra) # 48b8 <exit>
  sleep(1);
    17a4:	4505                	li	a0,1
    17a6:	00003097          	auipc	ra,0x3
    17aa:	1a2080e7          	jalr	418(ra) # 4948 <sleep>
  if(unlink("oidir") != 0){
    17ae:	00004517          	auipc	a0,0x4
    17b2:	31a50513          	addi	a0,a0,794 # 5ac8 <malloc+0xda2>
    17b6:	00003097          	auipc	ra,0x3
    17ba:	152080e7          	jalr	338(ra) # 4908 <unlink>
    17be:	cd19                	beqz	a0,17dc <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    17c0:	85a6                	mv	a1,s1
    17c2:	00004517          	auipc	a0,0x4
    17c6:	e3e50513          	addi	a0,a0,-450 # 5600 <malloc+0x8da>
    17ca:	00003097          	auipc	ra,0x3
    17ce:	49e080e7          	jalr	1182(ra) # 4c68 <printf>
    exit(1);
    17d2:	4505                	li	a0,1
    17d4:	00003097          	auipc	ra,0x3
    17d8:	0e4080e7          	jalr	228(ra) # 48b8 <exit>
  wait(&xstatus);
    17dc:	fdc40513          	addi	a0,s0,-36
    17e0:	00003097          	auipc	ra,0x3
    17e4:	0e0080e7          	jalr	224(ra) # 48c0 <wait>
  exit(xstatus);
    17e8:	fdc42503          	lw	a0,-36(s0)
    17ec:	00003097          	auipc	ra,0x3
    17f0:	0cc080e7          	jalr	204(ra) # 48b8 <exit>

00000000000017f4 <forkforkfork>:
{
    17f4:	1101                	addi	sp,sp,-32
    17f6:	ec06                	sd	ra,24(sp)
    17f8:	e822                	sd	s0,16(sp)
    17fa:	e426                	sd	s1,8(sp)
    17fc:	1000                	addi	s0,sp,32
    17fe:	84aa                	mv	s1,a0
  unlink("stopforking");
    1800:	00004517          	auipc	a0,0x4
    1804:	31050513          	addi	a0,a0,784 # 5b10 <malloc+0xdea>
    1808:	00003097          	auipc	ra,0x3
    180c:	100080e7          	jalr	256(ra) # 4908 <unlink>
  int pid = fork();
    1810:	00003097          	auipc	ra,0x3
    1814:	0a0080e7          	jalr	160(ra) # 48b0 <fork>
  if(pid < 0){
    1818:	04054563          	bltz	a0,1862 <forkforkfork+0x6e>
  if(pid == 0){
    181c:	c12d                	beqz	a0,187e <forkforkfork+0x8a>
  sleep(20); // two seconds
    181e:	4551                	li	a0,20
    1820:	00003097          	auipc	ra,0x3
    1824:	128080e7          	jalr	296(ra) # 4948 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    1828:	20200593          	li	a1,514
    182c:	00004517          	auipc	a0,0x4
    1830:	2e450513          	addi	a0,a0,740 # 5b10 <malloc+0xdea>
    1834:	00003097          	auipc	ra,0x3
    1838:	0c4080e7          	jalr	196(ra) # 48f8 <open>
    183c:	00003097          	auipc	ra,0x3
    1840:	0a4080e7          	jalr	164(ra) # 48e0 <close>
  wait(0);
    1844:	4501                	li	a0,0
    1846:	00003097          	auipc	ra,0x3
    184a:	07a080e7          	jalr	122(ra) # 48c0 <wait>
  sleep(10); // one second
    184e:	4529                	li	a0,10
    1850:	00003097          	auipc	ra,0x3
    1854:	0f8080e7          	jalr	248(ra) # 4948 <sleep>
}
    1858:	60e2                	ld	ra,24(sp)
    185a:	6442                	ld	s0,16(sp)
    185c:	64a2                	ld	s1,8(sp)
    185e:	6105                	addi	sp,sp,32
    1860:	8082                	ret
    printf("%s: fork failed", s);
    1862:	85a6                	mv	a1,s1
    1864:	00004517          	auipc	a0,0x4
    1868:	d5450513          	addi	a0,a0,-684 # 55b8 <malloc+0x892>
    186c:	00003097          	auipc	ra,0x3
    1870:	3fc080e7          	jalr	1020(ra) # 4c68 <printf>
    exit(1);
    1874:	4505                	li	a0,1
    1876:	00003097          	auipc	ra,0x3
    187a:	042080e7          	jalr	66(ra) # 48b8 <exit>
      int fd = open("stopforking", 0);
    187e:	00004497          	auipc	s1,0x4
    1882:	29248493          	addi	s1,s1,658 # 5b10 <malloc+0xdea>
    1886:	4581                	li	a1,0
    1888:	8526                	mv	a0,s1
    188a:	00003097          	auipc	ra,0x3
    188e:	06e080e7          	jalr	110(ra) # 48f8 <open>
      if(fd >= 0){
    1892:	02055463          	bgez	a0,18ba <forkforkfork+0xc6>
      if(fork() < 0){
    1896:	00003097          	auipc	ra,0x3
    189a:	01a080e7          	jalr	26(ra) # 48b0 <fork>
    189e:	fe0554e3          	bgez	a0,1886 <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    18a2:	20200593          	li	a1,514
    18a6:	8526                	mv	a0,s1
    18a8:	00003097          	auipc	ra,0x3
    18ac:	050080e7          	jalr	80(ra) # 48f8 <open>
    18b0:	00003097          	auipc	ra,0x3
    18b4:	030080e7          	jalr	48(ra) # 48e0 <close>
    18b8:	b7f9                	j	1886 <forkforkfork+0x92>
        exit(0);
    18ba:	4501                	li	a0,0
    18bc:	00003097          	auipc	ra,0x3
    18c0:	ffc080e7          	jalr	-4(ra) # 48b8 <exit>

00000000000018c4 <exectest>:
{
    18c4:	715d                	addi	sp,sp,-80
    18c6:	e486                	sd	ra,72(sp)
    18c8:	e0a2                	sd	s0,64(sp)
    18ca:	fc26                	sd	s1,56(sp)
    18cc:	f84a                	sd	s2,48(sp)
    18ce:	0880                	addi	s0,sp,80
    18d0:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    18d2:	00004797          	auipc	a5,0x4
    18d6:	8ce78793          	addi	a5,a5,-1842 # 51a0 <malloc+0x47a>
    18da:	fcf43023          	sd	a5,-64(s0)
    18de:	00004797          	auipc	a5,0x4
    18e2:	24278793          	addi	a5,a5,578 # 5b20 <malloc+0xdfa>
    18e6:	fcf43423          	sd	a5,-56(s0)
    18ea:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    18ee:	00004517          	auipc	a0,0x4
    18f2:	23a50513          	addi	a0,a0,570 # 5b28 <malloc+0xe02>
    18f6:	00003097          	auipc	ra,0x3
    18fa:	012080e7          	jalr	18(ra) # 4908 <unlink>
  pid = fork();
    18fe:	00003097          	auipc	ra,0x3
    1902:	fb2080e7          	jalr	-78(ra) # 48b0 <fork>
  if(pid < 0) {
    1906:	04054663          	bltz	a0,1952 <exectest+0x8e>
    190a:	84aa                	mv	s1,a0
  if(pid == 0) {
    190c:	e959                	bnez	a0,19a2 <exectest+0xde>
    close(1);
    190e:	4505                	li	a0,1
    1910:	00003097          	auipc	ra,0x3
    1914:	fd0080e7          	jalr	-48(ra) # 48e0 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    1918:	20100593          	li	a1,513
    191c:	00004517          	auipc	a0,0x4
    1920:	20c50513          	addi	a0,a0,524 # 5b28 <malloc+0xe02>
    1924:	00003097          	auipc	ra,0x3
    1928:	fd4080e7          	jalr	-44(ra) # 48f8 <open>
    if(fd < 0) {
    192c:	04054163          	bltz	a0,196e <exectest+0xaa>
    if(fd != 1) {
    1930:	4785                	li	a5,1
    1932:	04f50c63          	beq	a0,a5,198a <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    1936:	85ca                	mv	a1,s2
    1938:	00004517          	auipc	a0,0x4
    193c:	1f850513          	addi	a0,a0,504 # 5b30 <malloc+0xe0a>
    1940:	00003097          	auipc	ra,0x3
    1944:	328080e7          	jalr	808(ra) # 4c68 <printf>
      exit(1);
    1948:	4505                	li	a0,1
    194a:	00003097          	auipc	ra,0x3
    194e:	f6e080e7          	jalr	-146(ra) # 48b8 <exit>
     printf("%s: fork failed\n", s);
    1952:	85ca                	mv	a1,s2
    1954:	00004517          	auipc	a0,0x4
    1958:	ba450513          	addi	a0,a0,-1116 # 54f8 <malloc+0x7d2>
    195c:	00003097          	auipc	ra,0x3
    1960:	30c080e7          	jalr	780(ra) # 4c68 <printf>
     exit(1);
    1964:	4505                	li	a0,1
    1966:	00003097          	auipc	ra,0x3
    196a:	f52080e7          	jalr	-174(ra) # 48b8 <exit>
      printf("%s: create failed\n", s);
    196e:	85ca                	mv	a1,s2
    1970:	00004517          	auipc	a0,0x4
    1974:	c7850513          	addi	a0,a0,-904 # 55e8 <malloc+0x8c2>
    1978:	00003097          	auipc	ra,0x3
    197c:	2f0080e7          	jalr	752(ra) # 4c68 <printf>
      exit(1);
    1980:	4505                	li	a0,1
    1982:	00003097          	auipc	ra,0x3
    1986:	f36080e7          	jalr	-202(ra) # 48b8 <exit>
    if(exec("echo", echoargv) < 0){
    198a:	fc040593          	addi	a1,s0,-64
    198e:	00004517          	auipc	a0,0x4
    1992:	81250513          	addi	a0,a0,-2030 # 51a0 <malloc+0x47a>
    1996:	00003097          	auipc	ra,0x3
    199a:	f5a080e7          	jalr	-166(ra) # 48f0 <exec>
    199e:	02054163          	bltz	a0,19c0 <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    19a2:	fdc40513          	addi	a0,s0,-36
    19a6:	00003097          	auipc	ra,0x3
    19aa:	f1a080e7          	jalr	-230(ra) # 48c0 <wait>
    19ae:	02951763          	bne	a0,s1,19dc <exectest+0x118>
  if(xstatus != 0)
    19b2:	fdc42503          	lw	a0,-36(s0)
    19b6:	cd0d                	beqz	a0,19f0 <exectest+0x12c>
    exit(xstatus);
    19b8:	00003097          	auipc	ra,0x3
    19bc:	f00080e7          	jalr	-256(ra) # 48b8 <exit>
      printf("%s: exec echo failed\n", s);
    19c0:	85ca                	mv	a1,s2
    19c2:	00004517          	auipc	a0,0x4
    19c6:	17e50513          	addi	a0,a0,382 # 5b40 <malloc+0xe1a>
    19ca:	00003097          	auipc	ra,0x3
    19ce:	29e080e7          	jalr	670(ra) # 4c68 <printf>
      exit(1);
    19d2:	4505                	li	a0,1
    19d4:	00003097          	auipc	ra,0x3
    19d8:	ee4080e7          	jalr	-284(ra) # 48b8 <exit>
    printf("%s: wait failed!\n", s);
    19dc:	85ca                	mv	a1,s2
    19de:	00004517          	auipc	a0,0x4
    19e2:	17a50513          	addi	a0,a0,378 # 5b58 <malloc+0xe32>
    19e6:	00003097          	auipc	ra,0x3
    19ea:	282080e7          	jalr	642(ra) # 4c68 <printf>
    19ee:	b7d1                	j	19b2 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    19f0:	4581                	li	a1,0
    19f2:	00004517          	auipc	a0,0x4
    19f6:	13650513          	addi	a0,a0,310 # 5b28 <malloc+0xe02>
    19fa:	00003097          	auipc	ra,0x3
    19fe:	efe080e7          	jalr	-258(ra) # 48f8 <open>
  if(fd < 0) {
    1a02:	02054a63          	bltz	a0,1a36 <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    1a06:	4609                	li	a2,2
    1a08:	fb840593          	addi	a1,s0,-72
    1a0c:	00003097          	auipc	ra,0x3
    1a10:	ec4080e7          	jalr	-316(ra) # 48d0 <read>
    1a14:	4789                	li	a5,2
    1a16:	02f50e63          	beq	a0,a5,1a52 <exectest+0x18e>
    printf("%s: read failed\n", s);
    1a1a:	85ca                	mv	a1,s2
    1a1c:	00004517          	auipc	a0,0x4
    1a20:	89450513          	addi	a0,a0,-1900 # 52b0 <malloc+0x58a>
    1a24:	00003097          	auipc	ra,0x3
    1a28:	244080e7          	jalr	580(ra) # 4c68 <printf>
    exit(1);
    1a2c:	4505                	li	a0,1
    1a2e:	00003097          	auipc	ra,0x3
    1a32:	e8a080e7          	jalr	-374(ra) # 48b8 <exit>
    printf("%s: open failed\n", s);
    1a36:	85ca                	mv	a1,s2
    1a38:	00004517          	auipc	a0,0x4
    1a3c:	ad850513          	addi	a0,a0,-1320 # 5510 <malloc+0x7ea>
    1a40:	00003097          	auipc	ra,0x3
    1a44:	228080e7          	jalr	552(ra) # 4c68 <printf>
    exit(1);
    1a48:	4505                	li	a0,1
    1a4a:	00003097          	auipc	ra,0x3
    1a4e:	e6e080e7          	jalr	-402(ra) # 48b8 <exit>
  unlink("echo-ok");
    1a52:	00004517          	auipc	a0,0x4
    1a56:	0d650513          	addi	a0,a0,214 # 5b28 <malloc+0xe02>
    1a5a:	00003097          	auipc	ra,0x3
    1a5e:	eae080e7          	jalr	-338(ra) # 4908 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1a62:	fb844703          	lbu	a4,-72(s0)
    1a66:	04f00793          	li	a5,79
    1a6a:	00f71863          	bne	a4,a5,1a7a <exectest+0x1b6>
    1a6e:	fb944703          	lbu	a4,-71(s0)
    1a72:	04b00793          	li	a5,75
    1a76:	02f70063          	beq	a4,a5,1a96 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    1a7a:	85ca                	mv	a1,s2
    1a7c:	00004517          	auipc	a0,0x4
    1a80:	0f450513          	addi	a0,a0,244 # 5b70 <malloc+0xe4a>
    1a84:	00003097          	auipc	ra,0x3
    1a88:	1e4080e7          	jalr	484(ra) # 4c68 <printf>
    exit(1);
    1a8c:	4505                	li	a0,1
    1a8e:	00003097          	auipc	ra,0x3
    1a92:	e2a080e7          	jalr	-470(ra) # 48b8 <exit>
    exit(0);
    1a96:	4501                	li	a0,0
    1a98:	00003097          	auipc	ra,0x3
    1a9c:	e20080e7          	jalr	-480(ra) # 48b8 <exit>

0000000000001aa0 <bigargtest>:
{
    1aa0:	7179                	addi	sp,sp,-48
    1aa2:	f406                	sd	ra,40(sp)
    1aa4:	f022                	sd	s0,32(sp)
    1aa6:	ec26                	sd	s1,24(sp)
    1aa8:	1800                	addi	s0,sp,48
    1aaa:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    1aac:	00004517          	auipc	a0,0x4
    1ab0:	0dc50513          	addi	a0,a0,220 # 5b88 <malloc+0xe62>
    1ab4:	00003097          	auipc	ra,0x3
    1ab8:	e54080e7          	jalr	-428(ra) # 4908 <unlink>
  pid = fork();
    1abc:	00003097          	auipc	ra,0x3
    1ac0:	df4080e7          	jalr	-524(ra) # 48b0 <fork>
  if(pid == 0){
    1ac4:	c121                	beqz	a0,1b04 <bigargtest+0x64>
  } else if(pid < 0){
    1ac6:	0a054063          	bltz	a0,1b66 <bigargtest+0xc6>
  wait(&xstatus);
    1aca:	fdc40513          	addi	a0,s0,-36
    1ace:	00003097          	auipc	ra,0x3
    1ad2:	df2080e7          	jalr	-526(ra) # 48c0 <wait>
  if(xstatus != 0)
    1ad6:	fdc42503          	lw	a0,-36(s0)
    1ada:	e545                	bnez	a0,1b82 <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    1adc:	4581                	li	a1,0
    1ade:	00004517          	auipc	a0,0x4
    1ae2:	0aa50513          	addi	a0,a0,170 # 5b88 <malloc+0xe62>
    1ae6:	00003097          	auipc	ra,0x3
    1aea:	e12080e7          	jalr	-494(ra) # 48f8 <open>
  if(fd < 0){
    1aee:	08054e63          	bltz	a0,1b8a <bigargtest+0xea>
  close(fd);
    1af2:	00003097          	auipc	ra,0x3
    1af6:	dee080e7          	jalr	-530(ra) # 48e0 <close>
}
    1afa:	70a2                	ld	ra,40(sp)
    1afc:	7402                	ld	s0,32(sp)
    1afe:	64e2                	ld	s1,24(sp)
    1b00:	6145                	addi	sp,sp,48
    1b02:	8082                	ret
    1b04:	00005797          	auipc	a5,0x5
    1b08:	53c78793          	addi	a5,a5,1340 # 7040 <args.1751>
    1b0c:	00005697          	auipc	a3,0x5
    1b10:	62c68693          	addi	a3,a3,1580 # 7138 <args.1751+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    1b14:	00004717          	auipc	a4,0x4
    1b18:	08470713          	addi	a4,a4,132 # 5b98 <malloc+0xe72>
    1b1c:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    1b1e:	07a1                	addi	a5,a5,8
    1b20:	fed79ee3          	bne	a5,a3,1b1c <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    1b24:	00005597          	auipc	a1,0x5
    1b28:	51c58593          	addi	a1,a1,1308 # 7040 <args.1751>
    1b2c:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    1b30:	00003517          	auipc	a0,0x3
    1b34:	67050513          	addi	a0,a0,1648 # 51a0 <malloc+0x47a>
    1b38:	00003097          	auipc	ra,0x3
    1b3c:	db8080e7          	jalr	-584(ra) # 48f0 <exec>
    fd = open("bigarg-ok", O_CREATE);
    1b40:	20000593          	li	a1,512
    1b44:	00004517          	auipc	a0,0x4
    1b48:	04450513          	addi	a0,a0,68 # 5b88 <malloc+0xe62>
    1b4c:	00003097          	auipc	ra,0x3
    1b50:	dac080e7          	jalr	-596(ra) # 48f8 <open>
    close(fd);
    1b54:	00003097          	auipc	ra,0x3
    1b58:	d8c080e7          	jalr	-628(ra) # 48e0 <close>
    exit(0);
    1b5c:	4501                	li	a0,0
    1b5e:	00003097          	auipc	ra,0x3
    1b62:	d5a080e7          	jalr	-678(ra) # 48b8 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    1b66:	85a6                	mv	a1,s1
    1b68:	00004517          	auipc	a0,0x4
    1b6c:	11050513          	addi	a0,a0,272 # 5c78 <malloc+0xf52>
    1b70:	00003097          	auipc	ra,0x3
    1b74:	0f8080e7          	jalr	248(ra) # 4c68 <printf>
    exit(1);
    1b78:	4505                	li	a0,1
    1b7a:	00003097          	auipc	ra,0x3
    1b7e:	d3e080e7          	jalr	-706(ra) # 48b8 <exit>
    exit(xstatus);
    1b82:	00003097          	auipc	ra,0x3
    1b86:	d36080e7          	jalr	-714(ra) # 48b8 <exit>
    printf("%s: bigarg test failed!\n", s);
    1b8a:	85a6                	mv	a1,s1
    1b8c:	00004517          	auipc	a0,0x4
    1b90:	10c50513          	addi	a0,a0,268 # 5c98 <malloc+0xf72>
    1b94:	00003097          	auipc	ra,0x3
    1b98:	0d4080e7          	jalr	212(ra) # 4c68 <printf>
    exit(1);
    1b9c:	4505                	li	a0,1
    1b9e:	00003097          	auipc	ra,0x3
    1ba2:	d1a080e7          	jalr	-742(ra) # 48b8 <exit>

0000000000001ba6 <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    1ba6:	7139                	addi	sp,sp,-64
    1ba8:	fc06                	sd	ra,56(sp)
    1baa:	f822                	sd	s0,48(sp)
    1bac:	f426                	sd	s1,40(sp)
    1bae:	f04a                	sd	s2,32(sp)
    1bb0:	ec4e                	sd	s3,24(sp)
    1bb2:	0080                	addi	s0,sp,64
    1bb4:	64b1                	lui	s1,0xc
    1bb6:	35048493          	addi	s1,s1,848 # c350 <buf+0x2b00>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    1bba:	597d                	li	s2,-1
    1bbc:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    1bc0:	00003997          	auipc	s3,0x3
    1bc4:	5e098993          	addi	s3,s3,1504 # 51a0 <malloc+0x47a>
    argv[0] = (char*)0xffffffff;
    1bc8:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    1bcc:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    1bd0:	fc040593          	addi	a1,s0,-64
    1bd4:	854e                	mv	a0,s3
    1bd6:	00003097          	auipc	ra,0x3
    1bda:	d1a080e7          	jalr	-742(ra) # 48f0 <exec>
  for(int i = 0; i < 50000; i++){
    1bde:	34fd                	addiw	s1,s1,-1
    1be0:	f4e5                	bnez	s1,1bc8 <badarg+0x22>
  }
  
  exit(0);
    1be2:	4501                	li	a0,0
    1be4:	00003097          	auipc	ra,0x3
    1be8:	cd4080e7          	jalr	-812(ra) # 48b8 <exit>

0000000000001bec <pipe1>:
{
    1bec:	711d                	addi	sp,sp,-96
    1bee:	ec86                	sd	ra,88(sp)
    1bf0:	e8a2                	sd	s0,80(sp)
    1bf2:	e4a6                	sd	s1,72(sp)
    1bf4:	e0ca                	sd	s2,64(sp)
    1bf6:	fc4e                	sd	s3,56(sp)
    1bf8:	f852                	sd	s4,48(sp)
    1bfa:	f456                	sd	s5,40(sp)
    1bfc:	f05a                	sd	s6,32(sp)
    1bfe:	ec5e                	sd	s7,24(sp)
    1c00:	1080                	addi	s0,sp,96
    1c02:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    1c04:	fa840513          	addi	a0,s0,-88
    1c08:	00003097          	auipc	ra,0x3
    1c0c:	cc0080e7          	jalr	-832(ra) # 48c8 <pipe>
    1c10:	ed25                	bnez	a0,1c88 <pipe1+0x9c>
    1c12:	84aa                	mv	s1,a0
  pid = fork();
    1c14:	00003097          	auipc	ra,0x3
    1c18:	c9c080e7          	jalr	-868(ra) # 48b0 <fork>
    1c1c:	8a2a                	mv	s4,a0
  if(pid == 0){
    1c1e:	c159                	beqz	a0,1ca4 <pipe1+0xb8>
  } else if(pid > 0){
    1c20:	16a05e63          	blez	a0,1d9c <pipe1+0x1b0>
    close(fds[1]);
    1c24:	fac42503          	lw	a0,-84(s0)
    1c28:	00003097          	auipc	ra,0x3
    1c2c:	cb8080e7          	jalr	-840(ra) # 48e0 <close>
    total = 0;
    1c30:	8a26                	mv	s4,s1
    cc = 1;
    1c32:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    1c34:	00008a97          	auipc	s5,0x8
    1c38:	c1ca8a93          	addi	s5,s5,-996 # 9850 <buf>
      if(cc > sizeof(buf))
    1c3c:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    1c3e:	864e                	mv	a2,s3
    1c40:	85d6                	mv	a1,s5
    1c42:	fa842503          	lw	a0,-88(s0)
    1c46:	00003097          	auipc	ra,0x3
    1c4a:	c8a080e7          	jalr	-886(ra) # 48d0 <read>
    1c4e:	10a05263          	blez	a0,1d52 <pipe1+0x166>
      for(i = 0; i < n; i++){
    1c52:	00008717          	auipc	a4,0x8
    1c56:	bfe70713          	addi	a4,a4,-1026 # 9850 <buf>
    1c5a:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    1c5e:	00074683          	lbu	a3,0(a4)
    1c62:	0ff4f793          	andi	a5,s1,255
    1c66:	2485                	addiw	s1,s1,1
    1c68:	0cf69163          	bne	a3,a5,1d2a <pipe1+0x13e>
      for(i = 0; i < n; i++){
    1c6c:	0705                	addi	a4,a4,1
    1c6e:	fec498e3          	bne	s1,a2,1c5e <pipe1+0x72>
      total += n;
    1c72:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    1c76:	0019979b          	slliw	a5,s3,0x1
    1c7a:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    1c7e:	013b7363          	bgeu	s6,s3,1c84 <pipe1+0x98>
        cc = sizeof(buf);
    1c82:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    1c84:	84b2                	mv	s1,a2
    1c86:	bf65                	j	1c3e <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    1c88:	85ca                	mv	a1,s2
    1c8a:	00004517          	auipc	a0,0x4
    1c8e:	02e50513          	addi	a0,a0,46 # 5cb8 <malloc+0xf92>
    1c92:	00003097          	auipc	ra,0x3
    1c96:	fd6080e7          	jalr	-42(ra) # 4c68 <printf>
    exit(1);
    1c9a:	4505                	li	a0,1
    1c9c:	00003097          	auipc	ra,0x3
    1ca0:	c1c080e7          	jalr	-996(ra) # 48b8 <exit>
    close(fds[0]);
    1ca4:	fa842503          	lw	a0,-88(s0)
    1ca8:	00003097          	auipc	ra,0x3
    1cac:	c38080e7          	jalr	-968(ra) # 48e0 <close>
    for(n = 0; n < N; n++){
    1cb0:	00008b17          	auipc	s6,0x8
    1cb4:	ba0b0b13          	addi	s6,s6,-1120 # 9850 <buf>
    1cb8:	416004bb          	negw	s1,s6
    1cbc:	0ff4f493          	andi	s1,s1,255
    1cc0:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    1cc4:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    1cc6:	6a85                	lui	s5,0x1
    1cc8:	42da8a93          	addi	s5,s5,1069 # 142d <iputtest+0x6f>
{
    1ccc:	87da                	mv	a5,s6
        buf[i] = seq++;
    1cce:	0097873b          	addw	a4,a5,s1
    1cd2:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1cd6:	0785                	addi	a5,a5,1
    1cd8:	fef99be3          	bne	s3,a5,1cce <pipe1+0xe2>
    1cdc:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    1ce0:	40900613          	li	a2,1033
    1ce4:	85de                	mv	a1,s7
    1ce6:	fac42503          	lw	a0,-84(s0)
    1cea:	00003097          	auipc	ra,0x3
    1cee:	bee080e7          	jalr	-1042(ra) # 48d8 <write>
    1cf2:	40900793          	li	a5,1033
    1cf6:	00f51c63          	bne	a0,a5,1d0e <pipe1+0x122>
    for(n = 0; n < N; n++){
    1cfa:	24a5                	addiw	s1,s1,9
    1cfc:	0ff4f493          	andi	s1,s1,255
    1d00:	fd5a16e3          	bne	s4,s5,1ccc <pipe1+0xe0>
    exit(0);
    1d04:	4501                	li	a0,0
    1d06:	00003097          	auipc	ra,0x3
    1d0a:	bb2080e7          	jalr	-1102(ra) # 48b8 <exit>
        printf("%s: pipe1 oops 1\n", s);
    1d0e:	85ca                	mv	a1,s2
    1d10:	00004517          	auipc	a0,0x4
    1d14:	fc050513          	addi	a0,a0,-64 # 5cd0 <malloc+0xfaa>
    1d18:	00003097          	auipc	ra,0x3
    1d1c:	f50080e7          	jalr	-176(ra) # 4c68 <printf>
        exit(1);
    1d20:	4505                	li	a0,1
    1d22:	00003097          	auipc	ra,0x3
    1d26:	b96080e7          	jalr	-1130(ra) # 48b8 <exit>
          printf("%s: pipe1 oops 2\n", s);
    1d2a:	85ca                	mv	a1,s2
    1d2c:	00004517          	auipc	a0,0x4
    1d30:	fbc50513          	addi	a0,a0,-68 # 5ce8 <malloc+0xfc2>
    1d34:	00003097          	auipc	ra,0x3
    1d38:	f34080e7          	jalr	-204(ra) # 4c68 <printf>
}
    1d3c:	60e6                	ld	ra,88(sp)
    1d3e:	6446                	ld	s0,80(sp)
    1d40:	64a6                	ld	s1,72(sp)
    1d42:	6906                	ld	s2,64(sp)
    1d44:	79e2                	ld	s3,56(sp)
    1d46:	7a42                	ld	s4,48(sp)
    1d48:	7aa2                	ld	s5,40(sp)
    1d4a:	7b02                	ld	s6,32(sp)
    1d4c:	6be2                	ld	s7,24(sp)
    1d4e:	6125                	addi	sp,sp,96
    1d50:	8082                	ret
    if(total != N * SZ){
    1d52:	6785                	lui	a5,0x1
    1d54:	42d78793          	addi	a5,a5,1069 # 142d <iputtest+0x6f>
    1d58:	02fa0063          	beq	s4,a5,1d78 <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
    1d5c:	85d2                	mv	a1,s4
    1d5e:	00004517          	auipc	a0,0x4
    1d62:	fa250513          	addi	a0,a0,-94 # 5d00 <malloc+0xfda>
    1d66:	00003097          	auipc	ra,0x3
    1d6a:	f02080e7          	jalr	-254(ra) # 4c68 <printf>
      exit(1);
    1d6e:	4505                	li	a0,1
    1d70:	00003097          	auipc	ra,0x3
    1d74:	b48080e7          	jalr	-1208(ra) # 48b8 <exit>
    close(fds[0]);
    1d78:	fa842503          	lw	a0,-88(s0)
    1d7c:	00003097          	auipc	ra,0x3
    1d80:	b64080e7          	jalr	-1180(ra) # 48e0 <close>
    wait(&xstatus);
    1d84:	fa440513          	addi	a0,s0,-92
    1d88:	00003097          	auipc	ra,0x3
    1d8c:	b38080e7          	jalr	-1224(ra) # 48c0 <wait>
    exit(xstatus);
    1d90:	fa442503          	lw	a0,-92(s0)
    1d94:	00003097          	auipc	ra,0x3
    1d98:	b24080e7          	jalr	-1244(ra) # 48b8 <exit>
    printf("%s: fork() failed\n", s);
    1d9c:	85ca                	mv	a1,s2
    1d9e:	00004517          	auipc	a0,0x4
    1da2:	f8250513          	addi	a0,a0,-126 # 5d20 <malloc+0xffa>
    1da6:	00003097          	auipc	ra,0x3
    1daa:	ec2080e7          	jalr	-318(ra) # 4c68 <printf>
    exit(1);
    1dae:	4505                	li	a0,1
    1db0:	00003097          	auipc	ra,0x3
    1db4:	b08080e7          	jalr	-1272(ra) # 48b8 <exit>

0000000000001db8 <pgbug>:
{
    1db8:	7179                	addi	sp,sp,-48
    1dba:	f406                	sd	ra,40(sp)
    1dbc:	f022                	sd	s0,32(sp)
    1dbe:	ec26                	sd	s1,24(sp)
    1dc0:	1800                	addi	s0,sp,48
  argv[0] = 0;
    1dc2:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    1dc6:	00005497          	auipc	s1,0x5
    1dca:	25a4b483          	ld	s1,602(s1) # 7020 <__SDATA_BEGIN__>
    1dce:	fd840593          	addi	a1,s0,-40
    1dd2:	8526                	mv	a0,s1
    1dd4:	00003097          	auipc	ra,0x3
    1dd8:	b1c080e7          	jalr	-1252(ra) # 48f0 <exec>
  pipe((int*)0xeaeb0b5b00002f5e);
    1ddc:	8526                	mv	a0,s1
    1dde:	00003097          	auipc	ra,0x3
    1de2:	aea080e7          	jalr	-1302(ra) # 48c8 <pipe>
  exit(0);
    1de6:	4501                	li	a0,0
    1de8:	00003097          	auipc	ra,0x3
    1dec:	ad0080e7          	jalr	-1328(ra) # 48b8 <exit>

0000000000001df0 <preempt>:
{
    1df0:	7139                	addi	sp,sp,-64
    1df2:	fc06                	sd	ra,56(sp)
    1df4:	f822                	sd	s0,48(sp)
    1df6:	f426                	sd	s1,40(sp)
    1df8:	f04a                	sd	s2,32(sp)
    1dfa:	ec4e                	sd	s3,24(sp)
    1dfc:	e852                	sd	s4,16(sp)
    1dfe:	0080                	addi	s0,sp,64
    1e00:	8a2a                	mv	s4,a0
  pid1 = fork();
    1e02:	00003097          	auipc	ra,0x3
    1e06:	aae080e7          	jalr	-1362(ra) # 48b0 <fork>
  if(pid1 < 0) {
    1e0a:	00054563          	bltz	a0,1e14 <preempt+0x24>
    1e0e:	89aa                	mv	s3,a0
  if(pid1 == 0)
    1e10:	ed19                	bnez	a0,1e2e <preempt+0x3e>
    for(;;)
    1e12:	a001                	j	1e12 <preempt+0x22>
    printf("%s: fork failed");
    1e14:	00003517          	auipc	a0,0x3
    1e18:	7a450513          	addi	a0,a0,1956 # 55b8 <malloc+0x892>
    1e1c:	00003097          	auipc	ra,0x3
    1e20:	e4c080e7          	jalr	-436(ra) # 4c68 <printf>
    exit(1);
    1e24:	4505                	li	a0,1
    1e26:	00003097          	auipc	ra,0x3
    1e2a:	a92080e7          	jalr	-1390(ra) # 48b8 <exit>
  pid2 = fork();
    1e2e:	00003097          	auipc	ra,0x3
    1e32:	a82080e7          	jalr	-1406(ra) # 48b0 <fork>
    1e36:	892a                	mv	s2,a0
  if(pid2 < 0) {
    1e38:	00054463          	bltz	a0,1e40 <preempt+0x50>
  if(pid2 == 0)
    1e3c:	e105                	bnez	a0,1e5c <preempt+0x6c>
    for(;;)
    1e3e:	a001                	j	1e3e <preempt+0x4e>
    printf("%s: fork failed\n", s);
    1e40:	85d2                	mv	a1,s4
    1e42:	00003517          	auipc	a0,0x3
    1e46:	6b650513          	addi	a0,a0,1718 # 54f8 <malloc+0x7d2>
    1e4a:	00003097          	auipc	ra,0x3
    1e4e:	e1e080e7          	jalr	-482(ra) # 4c68 <printf>
    exit(1);
    1e52:	4505                	li	a0,1
    1e54:	00003097          	auipc	ra,0x3
    1e58:	a64080e7          	jalr	-1436(ra) # 48b8 <exit>
  pipe(pfds);
    1e5c:	fc840513          	addi	a0,s0,-56
    1e60:	00003097          	auipc	ra,0x3
    1e64:	a68080e7          	jalr	-1432(ra) # 48c8 <pipe>
  pid3 = fork();
    1e68:	00003097          	auipc	ra,0x3
    1e6c:	a48080e7          	jalr	-1464(ra) # 48b0 <fork>
    1e70:	84aa                	mv	s1,a0
  if(pid3 < 0) {
    1e72:	02054e63          	bltz	a0,1eae <preempt+0xbe>
  if(pid3 == 0){
    1e76:	e13d                	bnez	a0,1edc <preempt+0xec>
    close(pfds[0]);
    1e78:	fc842503          	lw	a0,-56(s0)
    1e7c:	00003097          	auipc	ra,0x3
    1e80:	a64080e7          	jalr	-1436(ra) # 48e0 <close>
    if(write(pfds[1], "x", 1) != 1)
    1e84:	4605                	li	a2,1
    1e86:	00003597          	auipc	a1,0x3
    1e8a:	2ea58593          	addi	a1,a1,746 # 5170 <malloc+0x44a>
    1e8e:	fcc42503          	lw	a0,-52(s0)
    1e92:	00003097          	auipc	ra,0x3
    1e96:	a46080e7          	jalr	-1466(ra) # 48d8 <write>
    1e9a:	4785                	li	a5,1
    1e9c:	02f51763          	bne	a0,a5,1eca <preempt+0xda>
    close(pfds[1]);
    1ea0:	fcc42503          	lw	a0,-52(s0)
    1ea4:	00003097          	auipc	ra,0x3
    1ea8:	a3c080e7          	jalr	-1476(ra) # 48e0 <close>
    for(;;)
    1eac:	a001                	j	1eac <preempt+0xbc>
     printf("%s: fork failed\n", s);
    1eae:	85d2                	mv	a1,s4
    1eb0:	00003517          	auipc	a0,0x3
    1eb4:	64850513          	addi	a0,a0,1608 # 54f8 <malloc+0x7d2>
    1eb8:	00003097          	auipc	ra,0x3
    1ebc:	db0080e7          	jalr	-592(ra) # 4c68 <printf>
     exit(1);
    1ec0:	4505                	li	a0,1
    1ec2:	00003097          	auipc	ra,0x3
    1ec6:	9f6080e7          	jalr	-1546(ra) # 48b8 <exit>
      printf("%s: preempt write error");
    1eca:	00004517          	auipc	a0,0x4
    1ece:	e6e50513          	addi	a0,a0,-402 # 5d38 <malloc+0x1012>
    1ed2:	00003097          	auipc	ra,0x3
    1ed6:	d96080e7          	jalr	-618(ra) # 4c68 <printf>
    1eda:	b7d9                	j	1ea0 <preempt+0xb0>
  close(pfds[1]);
    1edc:	fcc42503          	lw	a0,-52(s0)
    1ee0:	00003097          	auipc	ra,0x3
    1ee4:	a00080e7          	jalr	-1536(ra) # 48e0 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    1ee8:	660d                	lui	a2,0x3
    1eea:	00008597          	auipc	a1,0x8
    1eee:	96658593          	addi	a1,a1,-1690 # 9850 <buf>
    1ef2:	fc842503          	lw	a0,-56(s0)
    1ef6:	00003097          	auipc	ra,0x3
    1efa:	9da080e7          	jalr	-1574(ra) # 48d0 <read>
    1efe:	4785                	li	a5,1
    1f00:	02f50263          	beq	a0,a5,1f24 <preempt+0x134>
    printf("%s: preempt read error");
    1f04:	00004517          	auipc	a0,0x4
    1f08:	e4c50513          	addi	a0,a0,-436 # 5d50 <malloc+0x102a>
    1f0c:	00003097          	auipc	ra,0x3
    1f10:	d5c080e7          	jalr	-676(ra) # 4c68 <printf>
}
    1f14:	70e2                	ld	ra,56(sp)
    1f16:	7442                	ld	s0,48(sp)
    1f18:	74a2                	ld	s1,40(sp)
    1f1a:	7902                	ld	s2,32(sp)
    1f1c:	69e2                	ld	s3,24(sp)
    1f1e:	6a42                	ld	s4,16(sp)
    1f20:	6121                	addi	sp,sp,64
    1f22:	8082                	ret
  close(pfds[0]);
    1f24:	fc842503          	lw	a0,-56(s0)
    1f28:	00003097          	auipc	ra,0x3
    1f2c:	9b8080e7          	jalr	-1608(ra) # 48e0 <close>
  printf("kill... ");
    1f30:	00004517          	auipc	a0,0x4
    1f34:	e3850513          	addi	a0,a0,-456 # 5d68 <malloc+0x1042>
    1f38:	00003097          	auipc	ra,0x3
    1f3c:	d30080e7          	jalr	-720(ra) # 4c68 <printf>
  kill(pid1);
    1f40:	854e                	mv	a0,s3
    1f42:	00003097          	auipc	ra,0x3
    1f46:	9a6080e7          	jalr	-1626(ra) # 48e8 <kill>
  kill(pid2);
    1f4a:	854a                	mv	a0,s2
    1f4c:	00003097          	auipc	ra,0x3
    1f50:	99c080e7          	jalr	-1636(ra) # 48e8 <kill>
  kill(pid3);
    1f54:	8526                	mv	a0,s1
    1f56:	00003097          	auipc	ra,0x3
    1f5a:	992080e7          	jalr	-1646(ra) # 48e8 <kill>
  printf("wait... ");
    1f5e:	00004517          	auipc	a0,0x4
    1f62:	e1a50513          	addi	a0,a0,-486 # 5d78 <malloc+0x1052>
    1f66:	00003097          	auipc	ra,0x3
    1f6a:	d02080e7          	jalr	-766(ra) # 4c68 <printf>
  wait(0);
    1f6e:	4501                	li	a0,0
    1f70:	00003097          	auipc	ra,0x3
    1f74:	950080e7          	jalr	-1712(ra) # 48c0 <wait>
  wait(0);
    1f78:	4501                	li	a0,0
    1f7a:	00003097          	auipc	ra,0x3
    1f7e:	946080e7          	jalr	-1722(ra) # 48c0 <wait>
  wait(0);
    1f82:	4501                	li	a0,0
    1f84:	00003097          	auipc	ra,0x3
    1f88:	93c080e7          	jalr	-1732(ra) # 48c0 <wait>
    1f8c:	b761                	j	1f14 <preempt+0x124>

0000000000001f8e <reparent>:
{
    1f8e:	7179                	addi	sp,sp,-48
    1f90:	f406                	sd	ra,40(sp)
    1f92:	f022                	sd	s0,32(sp)
    1f94:	ec26                	sd	s1,24(sp)
    1f96:	e84a                	sd	s2,16(sp)
    1f98:	e44e                	sd	s3,8(sp)
    1f9a:	e052                	sd	s4,0(sp)
    1f9c:	1800                	addi	s0,sp,48
    1f9e:	89aa                	mv	s3,a0
  int master_pid = getpid();
    1fa0:	00003097          	auipc	ra,0x3
    1fa4:	998080e7          	jalr	-1640(ra) # 4938 <getpid>
    1fa8:	8a2a                	mv	s4,a0
    1faa:	0c800913          	li	s2,200
    int pid = fork();
    1fae:	00003097          	auipc	ra,0x3
    1fb2:	902080e7          	jalr	-1790(ra) # 48b0 <fork>
    1fb6:	84aa                	mv	s1,a0
    if(pid < 0){
    1fb8:	02054263          	bltz	a0,1fdc <reparent+0x4e>
    if(pid){
    1fbc:	cd21                	beqz	a0,2014 <reparent+0x86>
      if(wait(0) != pid){
    1fbe:	4501                	li	a0,0
    1fc0:	00003097          	auipc	ra,0x3
    1fc4:	900080e7          	jalr	-1792(ra) # 48c0 <wait>
    1fc8:	02951863          	bne	a0,s1,1ff8 <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    1fcc:	397d                	addiw	s2,s2,-1
    1fce:	fe0910e3          	bnez	s2,1fae <reparent+0x20>
  exit(0);
    1fd2:	4501                	li	a0,0
    1fd4:	00003097          	auipc	ra,0x3
    1fd8:	8e4080e7          	jalr	-1820(ra) # 48b8 <exit>
      printf("%s: fork failed\n", s);
    1fdc:	85ce                	mv	a1,s3
    1fde:	00003517          	auipc	a0,0x3
    1fe2:	51a50513          	addi	a0,a0,1306 # 54f8 <malloc+0x7d2>
    1fe6:	00003097          	auipc	ra,0x3
    1fea:	c82080e7          	jalr	-894(ra) # 4c68 <printf>
      exit(1);
    1fee:	4505                	li	a0,1
    1ff0:	00003097          	auipc	ra,0x3
    1ff4:	8c8080e7          	jalr	-1848(ra) # 48b8 <exit>
        printf("%s: wait wrong pid\n", s);
    1ff8:	85ce                	mv	a1,s3
    1ffa:	00003517          	auipc	a0,0x3
    1ffe:	58650513          	addi	a0,a0,1414 # 5580 <malloc+0x85a>
    2002:	00003097          	auipc	ra,0x3
    2006:	c66080e7          	jalr	-922(ra) # 4c68 <printf>
        exit(1);
    200a:	4505                	li	a0,1
    200c:	00003097          	auipc	ra,0x3
    2010:	8ac080e7          	jalr	-1876(ra) # 48b8 <exit>
      int pid2 = fork();
    2014:	00003097          	auipc	ra,0x3
    2018:	89c080e7          	jalr	-1892(ra) # 48b0 <fork>
      if(pid2 < 0){
    201c:	00054763          	bltz	a0,202a <reparent+0x9c>
      exit(0);
    2020:	4501                	li	a0,0
    2022:	00003097          	auipc	ra,0x3
    2026:	896080e7          	jalr	-1898(ra) # 48b8 <exit>
        kill(master_pid);
    202a:	8552                	mv	a0,s4
    202c:	00003097          	auipc	ra,0x3
    2030:	8bc080e7          	jalr	-1860(ra) # 48e8 <kill>
        exit(1);
    2034:	4505                	li	a0,1
    2036:	00003097          	auipc	ra,0x3
    203a:	882080e7          	jalr	-1918(ra) # 48b8 <exit>

000000000000203e <sharedfd>:
{
    203e:	7159                	addi	sp,sp,-112
    2040:	f486                	sd	ra,104(sp)
    2042:	f0a2                	sd	s0,96(sp)
    2044:	eca6                	sd	s1,88(sp)
    2046:	e8ca                	sd	s2,80(sp)
    2048:	e4ce                	sd	s3,72(sp)
    204a:	e0d2                	sd	s4,64(sp)
    204c:	fc56                	sd	s5,56(sp)
    204e:	f85a                	sd	s6,48(sp)
    2050:	f45e                	sd	s7,40(sp)
    2052:	1880                	addi	s0,sp,112
    2054:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    2056:	00003517          	auipc	a0,0x3
    205a:	ef250513          	addi	a0,a0,-270 # 4f48 <malloc+0x222>
    205e:	00003097          	auipc	ra,0x3
    2062:	8aa080e7          	jalr	-1878(ra) # 4908 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    2066:	20200593          	li	a1,514
    206a:	00003517          	auipc	a0,0x3
    206e:	ede50513          	addi	a0,a0,-290 # 4f48 <malloc+0x222>
    2072:	00003097          	auipc	ra,0x3
    2076:	886080e7          	jalr	-1914(ra) # 48f8 <open>
  if(fd < 0){
    207a:	04054a63          	bltz	a0,20ce <sharedfd+0x90>
    207e:	892a                	mv	s2,a0
  pid = fork();
    2080:	00003097          	auipc	ra,0x3
    2084:	830080e7          	jalr	-2000(ra) # 48b0 <fork>
    2088:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    208a:	06300593          	li	a1,99
    208e:	c119                	beqz	a0,2094 <sharedfd+0x56>
    2090:	07000593          	li	a1,112
    2094:	4629                	li	a2,10
    2096:	fa040513          	addi	a0,s0,-96
    209a:	00002097          	auipc	ra,0x2
    209e:	61a080e7          	jalr	1562(ra) # 46b4 <memset>
    20a2:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    20a6:	4629                	li	a2,10
    20a8:	fa040593          	addi	a1,s0,-96
    20ac:	854a                	mv	a0,s2
    20ae:	00003097          	auipc	ra,0x3
    20b2:	82a080e7          	jalr	-2006(ra) # 48d8 <write>
    20b6:	47a9                	li	a5,10
    20b8:	02f51963          	bne	a0,a5,20ea <sharedfd+0xac>
  for(i = 0; i < N; i++){
    20bc:	34fd                	addiw	s1,s1,-1
    20be:	f4e5                	bnez	s1,20a6 <sharedfd+0x68>
  if(pid == 0) {
    20c0:	04099363          	bnez	s3,2106 <sharedfd+0xc8>
    exit(0);
    20c4:	4501                	li	a0,0
    20c6:	00002097          	auipc	ra,0x2
    20ca:	7f2080e7          	jalr	2034(ra) # 48b8 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    20ce:	85d2                	mv	a1,s4
    20d0:	00004517          	auipc	a0,0x4
    20d4:	cb850513          	addi	a0,a0,-840 # 5d88 <malloc+0x1062>
    20d8:	00003097          	auipc	ra,0x3
    20dc:	b90080e7          	jalr	-1136(ra) # 4c68 <printf>
    exit(1);
    20e0:	4505                	li	a0,1
    20e2:	00002097          	auipc	ra,0x2
    20e6:	7d6080e7          	jalr	2006(ra) # 48b8 <exit>
      printf("%s: write sharedfd failed\n", s);
    20ea:	85d2                	mv	a1,s4
    20ec:	00004517          	auipc	a0,0x4
    20f0:	cc450513          	addi	a0,a0,-828 # 5db0 <malloc+0x108a>
    20f4:	00003097          	auipc	ra,0x3
    20f8:	b74080e7          	jalr	-1164(ra) # 4c68 <printf>
      exit(1);
    20fc:	4505                	li	a0,1
    20fe:	00002097          	auipc	ra,0x2
    2102:	7ba080e7          	jalr	1978(ra) # 48b8 <exit>
    wait(&xstatus);
    2106:	f9c40513          	addi	a0,s0,-100
    210a:	00002097          	auipc	ra,0x2
    210e:	7b6080e7          	jalr	1974(ra) # 48c0 <wait>
    if(xstatus != 0)
    2112:	f9c42983          	lw	s3,-100(s0)
    2116:	00098763          	beqz	s3,2124 <sharedfd+0xe6>
      exit(xstatus);
    211a:	854e                	mv	a0,s3
    211c:	00002097          	auipc	ra,0x2
    2120:	79c080e7          	jalr	1948(ra) # 48b8 <exit>
  close(fd);
    2124:	854a                	mv	a0,s2
    2126:	00002097          	auipc	ra,0x2
    212a:	7ba080e7          	jalr	1978(ra) # 48e0 <close>
  fd = open("sharedfd", 0);
    212e:	4581                	li	a1,0
    2130:	00003517          	auipc	a0,0x3
    2134:	e1850513          	addi	a0,a0,-488 # 4f48 <malloc+0x222>
    2138:	00002097          	auipc	ra,0x2
    213c:	7c0080e7          	jalr	1984(ra) # 48f8 <open>
    2140:	8baa                	mv	s7,a0
  nc = np = 0;
    2142:	8ace                	mv	s5,s3
  if(fd < 0){
    2144:	02054563          	bltz	a0,216e <sharedfd+0x130>
    2148:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    214c:	06300493          	li	s1,99
      if(buf[i] == 'p')
    2150:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    2154:	4629                	li	a2,10
    2156:	fa040593          	addi	a1,s0,-96
    215a:	855e                	mv	a0,s7
    215c:	00002097          	auipc	ra,0x2
    2160:	774080e7          	jalr	1908(ra) # 48d0 <read>
    2164:	02a05f63          	blez	a0,21a2 <sharedfd+0x164>
    2168:	fa040793          	addi	a5,s0,-96
    216c:	a01d                	j	2192 <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    216e:	85d2                	mv	a1,s4
    2170:	00004517          	auipc	a0,0x4
    2174:	c6050513          	addi	a0,a0,-928 # 5dd0 <malloc+0x10aa>
    2178:	00003097          	auipc	ra,0x3
    217c:	af0080e7          	jalr	-1296(ra) # 4c68 <printf>
    exit(1);
    2180:	4505                	li	a0,1
    2182:	00002097          	auipc	ra,0x2
    2186:	736080e7          	jalr	1846(ra) # 48b8 <exit>
        nc++;
    218a:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    218c:	0785                	addi	a5,a5,1
    218e:	fd2783e3          	beq	a5,s2,2154 <sharedfd+0x116>
      if(buf[i] == 'c')
    2192:	0007c703          	lbu	a4,0(a5)
    2196:	fe970ae3          	beq	a4,s1,218a <sharedfd+0x14c>
      if(buf[i] == 'p')
    219a:	ff6719e3          	bne	a4,s6,218c <sharedfd+0x14e>
        np++;
    219e:	2a85                	addiw	s5,s5,1
    21a0:	b7f5                	j	218c <sharedfd+0x14e>
  close(fd);
    21a2:	855e                	mv	a0,s7
    21a4:	00002097          	auipc	ra,0x2
    21a8:	73c080e7          	jalr	1852(ra) # 48e0 <close>
  unlink("sharedfd");
    21ac:	00003517          	auipc	a0,0x3
    21b0:	d9c50513          	addi	a0,a0,-612 # 4f48 <malloc+0x222>
    21b4:	00002097          	auipc	ra,0x2
    21b8:	754080e7          	jalr	1876(ra) # 4908 <unlink>
  if(nc == N*SZ && np == N*SZ){
    21bc:	6789                	lui	a5,0x2
    21be:	71078793          	addi	a5,a5,1808 # 2710 <linktest+0xfe>
    21c2:	00f99763          	bne	s3,a5,21d0 <sharedfd+0x192>
    21c6:	6789                	lui	a5,0x2
    21c8:	71078793          	addi	a5,a5,1808 # 2710 <linktest+0xfe>
    21cc:	02fa8063          	beq	s5,a5,21ec <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    21d0:	85d2                	mv	a1,s4
    21d2:	00004517          	auipc	a0,0x4
    21d6:	c2650513          	addi	a0,a0,-986 # 5df8 <malloc+0x10d2>
    21da:	00003097          	auipc	ra,0x3
    21de:	a8e080e7          	jalr	-1394(ra) # 4c68 <printf>
    exit(1);
    21e2:	4505                	li	a0,1
    21e4:	00002097          	auipc	ra,0x2
    21e8:	6d4080e7          	jalr	1748(ra) # 48b8 <exit>
    exit(0);
    21ec:	4501                	li	a0,0
    21ee:	00002097          	auipc	ra,0x2
    21f2:	6ca080e7          	jalr	1738(ra) # 48b8 <exit>

00000000000021f6 <fourfiles>:
{
    21f6:	7171                	addi	sp,sp,-176
    21f8:	f506                	sd	ra,168(sp)
    21fa:	f122                	sd	s0,160(sp)
    21fc:	ed26                	sd	s1,152(sp)
    21fe:	e94a                	sd	s2,144(sp)
    2200:	e54e                	sd	s3,136(sp)
    2202:	e152                	sd	s4,128(sp)
    2204:	fcd6                	sd	s5,120(sp)
    2206:	f8da                	sd	s6,112(sp)
    2208:	f4de                	sd	s7,104(sp)
    220a:	f0e2                	sd	s8,96(sp)
    220c:	ece6                	sd	s9,88(sp)
    220e:	e8ea                	sd	s10,80(sp)
    2210:	e4ee                	sd	s11,72(sp)
    2212:	1900                	addi	s0,sp,176
    2214:	8caa                	mv	s9,a0
  char *names[] = { "f0", "f1", "f2", "f3" };
    2216:	00003797          	auipc	a5,0x3
    221a:	bfa78793          	addi	a5,a5,-1030 # 4e10 <malloc+0xea>
    221e:	f6f43823          	sd	a5,-144(s0)
    2222:	00003797          	auipc	a5,0x3
    2226:	bf678793          	addi	a5,a5,-1034 # 4e18 <malloc+0xf2>
    222a:	f6f43c23          	sd	a5,-136(s0)
    222e:	00003797          	auipc	a5,0x3
    2232:	bf278793          	addi	a5,a5,-1038 # 4e20 <malloc+0xfa>
    2236:	f8f43023          	sd	a5,-128(s0)
    223a:	00003797          	auipc	a5,0x3
    223e:	bee78793          	addi	a5,a5,-1042 # 4e28 <malloc+0x102>
    2242:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    2246:	f7040b93          	addi	s7,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    224a:	895e                	mv	s2,s7
  for(pi = 0; pi < NCHILD; pi++){
    224c:	4481                	li	s1,0
    224e:	4a11                	li	s4,4
    fname = names[pi];
    2250:	00093983          	ld	s3,0(s2)
    unlink(fname);
    2254:	854e                	mv	a0,s3
    2256:	00002097          	auipc	ra,0x2
    225a:	6b2080e7          	jalr	1714(ra) # 4908 <unlink>
    pid = fork();
    225e:	00002097          	auipc	ra,0x2
    2262:	652080e7          	jalr	1618(ra) # 48b0 <fork>
    if(pid < 0){
    2266:	04054563          	bltz	a0,22b0 <fourfiles+0xba>
    if(pid == 0){
    226a:	c12d                	beqz	a0,22cc <fourfiles+0xd6>
  for(pi = 0; pi < NCHILD; pi++){
    226c:	2485                	addiw	s1,s1,1
    226e:	0921                	addi	s2,s2,8
    2270:	ff4490e3          	bne	s1,s4,2250 <fourfiles+0x5a>
    2274:	4491                	li	s1,4
    wait(&xstatus);
    2276:	f6c40513          	addi	a0,s0,-148
    227a:	00002097          	auipc	ra,0x2
    227e:	646080e7          	jalr	1606(ra) # 48c0 <wait>
    if(xstatus != 0)
    2282:	f6c42503          	lw	a0,-148(s0)
    2286:	ed69                	bnez	a0,2360 <fourfiles+0x16a>
  for(pi = 0; pi < NCHILD; pi++){
    2288:	34fd                	addiw	s1,s1,-1
    228a:	f4f5                	bnez	s1,2276 <fourfiles+0x80>
    228c:	03000b13          	li	s6,48
    total = 0;
    2290:	f4a43c23          	sd	a0,-168(s0)
    while((n = read(fd, buf, sizeof(buf))) > 0){
    2294:	00007a17          	auipc	s4,0x7
    2298:	5bca0a13          	addi	s4,s4,1468 # 9850 <buf>
    229c:	00007a97          	auipc	s5,0x7
    22a0:	5b5a8a93          	addi	s5,s5,1461 # 9851 <buf+0x1>
    if(total != N*SZ){
    22a4:	6d05                	lui	s10,0x1
    22a6:	770d0d13          	addi	s10,s10,1904 # 1770 <openiputtest+0x6e>
  for(i = 0; i < NCHILD; i++){
    22aa:	03400d93          	li	s11,52
    22ae:	a23d                	j	23dc <fourfiles+0x1e6>
      printf("fork failed\n", s);
    22b0:	85e6                	mv	a1,s9
    22b2:	00004517          	auipc	a0,0x4
    22b6:	9d650513          	addi	a0,a0,-1578 # 5c88 <malloc+0xf62>
    22ba:	00003097          	auipc	ra,0x3
    22be:	9ae080e7          	jalr	-1618(ra) # 4c68 <printf>
      exit(1);
    22c2:	4505                	li	a0,1
    22c4:	00002097          	auipc	ra,0x2
    22c8:	5f4080e7          	jalr	1524(ra) # 48b8 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    22cc:	20200593          	li	a1,514
    22d0:	854e                	mv	a0,s3
    22d2:	00002097          	auipc	ra,0x2
    22d6:	626080e7          	jalr	1574(ra) # 48f8 <open>
    22da:	892a                	mv	s2,a0
      if(fd < 0){
    22dc:	04054763          	bltz	a0,232a <fourfiles+0x134>
      memset(buf, '0'+pi, SZ);
    22e0:	1f400613          	li	a2,500
    22e4:	0304859b          	addiw	a1,s1,48
    22e8:	00007517          	auipc	a0,0x7
    22ec:	56850513          	addi	a0,a0,1384 # 9850 <buf>
    22f0:	00002097          	auipc	ra,0x2
    22f4:	3c4080e7          	jalr	964(ra) # 46b4 <memset>
    22f8:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    22fa:	00007997          	auipc	s3,0x7
    22fe:	55698993          	addi	s3,s3,1366 # 9850 <buf>
    2302:	1f400613          	li	a2,500
    2306:	85ce                	mv	a1,s3
    2308:	854a                	mv	a0,s2
    230a:	00002097          	auipc	ra,0x2
    230e:	5ce080e7          	jalr	1486(ra) # 48d8 <write>
    2312:	85aa                	mv	a1,a0
    2314:	1f400793          	li	a5,500
    2318:	02f51763          	bne	a0,a5,2346 <fourfiles+0x150>
      for(i = 0; i < N; i++){
    231c:	34fd                	addiw	s1,s1,-1
    231e:	f0f5                	bnez	s1,2302 <fourfiles+0x10c>
      exit(0);
    2320:	4501                	li	a0,0
    2322:	00002097          	auipc	ra,0x2
    2326:	596080e7          	jalr	1430(ra) # 48b8 <exit>
        printf("create failed\n", s);
    232a:	85e6                	mv	a1,s9
    232c:	00004517          	auipc	a0,0x4
    2330:	ae450513          	addi	a0,a0,-1308 # 5e10 <malloc+0x10ea>
    2334:	00003097          	auipc	ra,0x3
    2338:	934080e7          	jalr	-1740(ra) # 4c68 <printf>
        exit(1);
    233c:	4505                	li	a0,1
    233e:	00002097          	auipc	ra,0x2
    2342:	57a080e7          	jalr	1402(ra) # 48b8 <exit>
          printf("write failed %d\n", n);
    2346:	00004517          	auipc	a0,0x4
    234a:	ada50513          	addi	a0,a0,-1318 # 5e20 <malloc+0x10fa>
    234e:	00003097          	auipc	ra,0x3
    2352:	91a080e7          	jalr	-1766(ra) # 4c68 <printf>
          exit(1);
    2356:	4505                	li	a0,1
    2358:	00002097          	auipc	ra,0x2
    235c:	560080e7          	jalr	1376(ra) # 48b8 <exit>
      exit(xstatus);
    2360:	00002097          	auipc	ra,0x2
    2364:	558080e7          	jalr	1368(ra) # 48b8 <exit>
          printf("wrong char\n", s);
    2368:	85e6                	mv	a1,s9
    236a:	00004517          	auipc	a0,0x4
    236e:	ace50513          	addi	a0,a0,-1330 # 5e38 <malloc+0x1112>
    2372:	00003097          	auipc	ra,0x3
    2376:	8f6080e7          	jalr	-1802(ra) # 4c68 <printf>
          exit(1);
    237a:	4505                	li	a0,1
    237c:	00002097          	auipc	ra,0x2
    2380:	53c080e7          	jalr	1340(ra) # 48b8 <exit>
      total += n;
    2384:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    2388:	660d                	lui	a2,0x3
    238a:	85d2                	mv	a1,s4
    238c:	854e                	mv	a0,s3
    238e:	00002097          	auipc	ra,0x2
    2392:	542080e7          	jalr	1346(ra) # 48d0 <read>
    2396:	02a05363          	blez	a0,23bc <fourfiles+0x1c6>
    239a:	00007797          	auipc	a5,0x7
    239e:	4b678793          	addi	a5,a5,1206 # 9850 <buf>
    23a2:	fff5069b          	addiw	a3,a0,-1
    23a6:	1682                	slli	a3,a3,0x20
    23a8:	9281                	srli	a3,a3,0x20
    23aa:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    23ac:	0007c703          	lbu	a4,0(a5)
    23b0:	fa971ce3          	bne	a4,s1,2368 <fourfiles+0x172>
      for(j = 0; j < n; j++){
    23b4:	0785                	addi	a5,a5,1
    23b6:	fed79be3          	bne	a5,a3,23ac <fourfiles+0x1b6>
    23ba:	b7e9                	j	2384 <fourfiles+0x18e>
    close(fd);
    23bc:	854e                	mv	a0,s3
    23be:	00002097          	auipc	ra,0x2
    23c2:	522080e7          	jalr	1314(ra) # 48e0 <close>
    if(total != N*SZ){
    23c6:	03a91963          	bne	s2,s10,23f8 <fourfiles+0x202>
    unlink(fname);
    23ca:	8562                	mv	a0,s8
    23cc:	00002097          	auipc	ra,0x2
    23d0:	53c080e7          	jalr	1340(ra) # 4908 <unlink>
  for(i = 0; i < NCHILD; i++){
    23d4:	0ba1                	addi	s7,s7,8
    23d6:	2b05                	addiw	s6,s6,1
    23d8:	03bb0e63          	beq	s6,s11,2414 <fourfiles+0x21e>
    fname = names[i];
    23dc:	000bbc03          	ld	s8,0(s7)
    fd = open(fname, 0);
    23e0:	4581                	li	a1,0
    23e2:	8562                	mv	a0,s8
    23e4:	00002097          	auipc	ra,0x2
    23e8:	514080e7          	jalr	1300(ra) # 48f8 <open>
    23ec:	89aa                	mv	s3,a0
    total = 0;
    23ee:	f5843903          	ld	s2,-168(s0)
        if(buf[j] != '0'+i){
    23f2:	000b049b          	sext.w	s1,s6
    while((n = read(fd, buf, sizeof(buf))) > 0){
    23f6:	bf49                	j	2388 <fourfiles+0x192>
      printf("wrong length %d\n", total);
    23f8:	85ca                	mv	a1,s2
    23fa:	00004517          	auipc	a0,0x4
    23fe:	a4e50513          	addi	a0,a0,-1458 # 5e48 <malloc+0x1122>
    2402:	00003097          	auipc	ra,0x3
    2406:	866080e7          	jalr	-1946(ra) # 4c68 <printf>
      exit(1);
    240a:	4505                	li	a0,1
    240c:	00002097          	auipc	ra,0x2
    2410:	4ac080e7          	jalr	1196(ra) # 48b8 <exit>
}
    2414:	70aa                	ld	ra,168(sp)
    2416:	740a                	ld	s0,160(sp)
    2418:	64ea                	ld	s1,152(sp)
    241a:	694a                	ld	s2,144(sp)
    241c:	69aa                	ld	s3,136(sp)
    241e:	6a0a                	ld	s4,128(sp)
    2420:	7ae6                	ld	s5,120(sp)
    2422:	7b46                	ld	s6,112(sp)
    2424:	7ba6                	ld	s7,104(sp)
    2426:	7c06                	ld	s8,96(sp)
    2428:	6ce6                	ld	s9,88(sp)
    242a:	6d46                	ld	s10,80(sp)
    242c:	6da6                	ld	s11,72(sp)
    242e:	614d                	addi	sp,sp,176
    2430:	8082                	ret

0000000000002432 <bigfile>:
{
    2432:	7139                	addi	sp,sp,-64
    2434:	fc06                	sd	ra,56(sp)
    2436:	f822                	sd	s0,48(sp)
    2438:	f426                	sd	s1,40(sp)
    243a:	f04a                	sd	s2,32(sp)
    243c:	ec4e                	sd	s3,24(sp)
    243e:	e852                	sd	s4,16(sp)
    2440:	e456                	sd	s5,8(sp)
    2442:	0080                	addi	s0,sp,64
    2444:	8aaa                	mv	s5,a0
  unlink("bigfile");
    2446:	00003517          	auipc	a0,0x3
    244a:	c3a50513          	addi	a0,a0,-966 # 5080 <malloc+0x35a>
    244e:	00002097          	auipc	ra,0x2
    2452:	4ba080e7          	jalr	1210(ra) # 4908 <unlink>
  fd = open("bigfile", O_CREATE | O_RDWR);
    2456:	20200593          	li	a1,514
    245a:	00003517          	auipc	a0,0x3
    245e:	c2650513          	addi	a0,a0,-986 # 5080 <malloc+0x35a>
    2462:	00002097          	auipc	ra,0x2
    2466:	496080e7          	jalr	1174(ra) # 48f8 <open>
    246a:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    246c:	4481                	li	s1,0
    memset(buf, i, SZ);
    246e:	00007917          	auipc	s2,0x7
    2472:	3e290913          	addi	s2,s2,994 # 9850 <buf>
  for(i = 0; i < N; i++){
    2476:	4a51                	li	s4,20
  if(fd < 0){
    2478:	0a054063          	bltz	a0,2518 <bigfile+0xe6>
    memset(buf, i, SZ);
    247c:	25800613          	li	a2,600
    2480:	85a6                	mv	a1,s1
    2482:	854a                	mv	a0,s2
    2484:	00002097          	auipc	ra,0x2
    2488:	230080e7          	jalr	560(ra) # 46b4 <memset>
    if(write(fd, buf, SZ) != SZ){
    248c:	25800613          	li	a2,600
    2490:	85ca                	mv	a1,s2
    2492:	854e                	mv	a0,s3
    2494:	00002097          	auipc	ra,0x2
    2498:	444080e7          	jalr	1092(ra) # 48d8 <write>
    249c:	25800793          	li	a5,600
    24a0:	08f51a63          	bne	a0,a5,2534 <bigfile+0x102>
  for(i = 0; i < N; i++){
    24a4:	2485                	addiw	s1,s1,1
    24a6:	fd449be3          	bne	s1,s4,247c <bigfile+0x4a>
  close(fd);
    24aa:	854e                	mv	a0,s3
    24ac:	00002097          	auipc	ra,0x2
    24b0:	434080e7          	jalr	1076(ra) # 48e0 <close>
  fd = open("bigfile", 0);
    24b4:	4581                	li	a1,0
    24b6:	00003517          	auipc	a0,0x3
    24ba:	bca50513          	addi	a0,a0,-1078 # 5080 <malloc+0x35a>
    24be:	00002097          	auipc	ra,0x2
    24c2:	43a080e7          	jalr	1082(ra) # 48f8 <open>
    24c6:	8a2a                	mv	s4,a0
  total = 0;
    24c8:	4981                	li	s3,0
  for(i = 0; ; i++){
    24ca:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    24cc:	00007917          	auipc	s2,0x7
    24d0:	38490913          	addi	s2,s2,900 # 9850 <buf>
  if(fd < 0){
    24d4:	06054e63          	bltz	a0,2550 <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    24d8:	12c00613          	li	a2,300
    24dc:	85ca                	mv	a1,s2
    24de:	8552                	mv	a0,s4
    24e0:	00002097          	auipc	ra,0x2
    24e4:	3f0080e7          	jalr	1008(ra) # 48d0 <read>
    if(cc < 0){
    24e8:	08054263          	bltz	a0,256c <bigfile+0x13a>
    if(cc == 0)
    24ec:	c971                	beqz	a0,25c0 <bigfile+0x18e>
    if(cc != SZ/2){
    24ee:	12c00793          	li	a5,300
    24f2:	08f51b63          	bne	a0,a5,2588 <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    24f6:	01f4d79b          	srliw	a5,s1,0x1f
    24fa:	9fa5                	addw	a5,a5,s1
    24fc:	4017d79b          	sraiw	a5,a5,0x1
    2500:	00094703          	lbu	a4,0(s2)
    2504:	0af71063          	bne	a4,a5,25a4 <bigfile+0x172>
    2508:	12b94703          	lbu	a4,299(s2)
    250c:	08f71c63          	bne	a4,a5,25a4 <bigfile+0x172>
    total += cc;
    2510:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    2514:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    2516:	b7c9                	j	24d8 <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    2518:	85d6                	mv	a1,s5
    251a:	00004517          	auipc	a0,0x4
    251e:	94650513          	addi	a0,a0,-1722 # 5e60 <malloc+0x113a>
    2522:	00002097          	auipc	ra,0x2
    2526:	746080e7          	jalr	1862(ra) # 4c68 <printf>
    exit(1);
    252a:	4505                	li	a0,1
    252c:	00002097          	auipc	ra,0x2
    2530:	38c080e7          	jalr	908(ra) # 48b8 <exit>
      printf("%s: write bigfile failed\n", s);
    2534:	85d6                	mv	a1,s5
    2536:	00004517          	auipc	a0,0x4
    253a:	94a50513          	addi	a0,a0,-1718 # 5e80 <malloc+0x115a>
    253e:	00002097          	auipc	ra,0x2
    2542:	72a080e7          	jalr	1834(ra) # 4c68 <printf>
      exit(1);
    2546:	4505                	li	a0,1
    2548:	00002097          	auipc	ra,0x2
    254c:	370080e7          	jalr	880(ra) # 48b8 <exit>
    printf("%s: cannot open bigfile\n", s);
    2550:	85d6                	mv	a1,s5
    2552:	00004517          	auipc	a0,0x4
    2556:	94e50513          	addi	a0,a0,-1714 # 5ea0 <malloc+0x117a>
    255a:	00002097          	auipc	ra,0x2
    255e:	70e080e7          	jalr	1806(ra) # 4c68 <printf>
    exit(1);
    2562:	4505                	li	a0,1
    2564:	00002097          	auipc	ra,0x2
    2568:	354080e7          	jalr	852(ra) # 48b8 <exit>
      printf("%s: read bigfile failed\n", s);
    256c:	85d6                	mv	a1,s5
    256e:	00004517          	auipc	a0,0x4
    2572:	95250513          	addi	a0,a0,-1710 # 5ec0 <malloc+0x119a>
    2576:	00002097          	auipc	ra,0x2
    257a:	6f2080e7          	jalr	1778(ra) # 4c68 <printf>
      exit(1);
    257e:	4505                	li	a0,1
    2580:	00002097          	auipc	ra,0x2
    2584:	338080e7          	jalr	824(ra) # 48b8 <exit>
      printf("%s: short read bigfile\n", s);
    2588:	85d6                	mv	a1,s5
    258a:	00004517          	auipc	a0,0x4
    258e:	95650513          	addi	a0,a0,-1706 # 5ee0 <malloc+0x11ba>
    2592:	00002097          	auipc	ra,0x2
    2596:	6d6080e7          	jalr	1750(ra) # 4c68 <printf>
      exit(1);
    259a:	4505                	li	a0,1
    259c:	00002097          	auipc	ra,0x2
    25a0:	31c080e7          	jalr	796(ra) # 48b8 <exit>
      printf("%s: read bigfile wrong data\n", s);
    25a4:	85d6                	mv	a1,s5
    25a6:	00004517          	auipc	a0,0x4
    25aa:	95250513          	addi	a0,a0,-1710 # 5ef8 <malloc+0x11d2>
    25ae:	00002097          	auipc	ra,0x2
    25b2:	6ba080e7          	jalr	1722(ra) # 4c68 <printf>
      exit(1);
    25b6:	4505                	li	a0,1
    25b8:	00002097          	auipc	ra,0x2
    25bc:	300080e7          	jalr	768(ra) # 48b8 <exit>
  close(fd);
    25c0:	8552                	mv	a0,s4
    25c2:	00002097          	auipc	ra,0x2
    25c6:	31e080e7          	jalr	798(ra) # 48e0 <close>
  if(total != N*SZ){
    25ca:	678d                	lui	a5,0x3
    25cc:	ee078793          	addi	a5,a5,-288 # 2ee0 <subdir+0x10a>
    25d0:	02f99363          	bne	s3,a5,25f6 <bigfile+0x1c4>
  unlink("bigfile");
    25d4:	00003517          	auipc	a0,0x3
    25d8:	aac50513          	addi	a0,a0,-1364 # 5080 <malloc+0x35a>
    25dc:	00002097          	auipc	ra,0x2
    25e0:	32c080e7          	jalr	812(ra) # 4908 <unlink>
}
    25e4:	70e2                	ld	ra,56(sp)
    25e6:	7442                	ld	s0,48(sp)
    25e8:	74a2                	ld	s1,40(sp)
    25ea:	7902                	ld	s2,32(sp)
    25ec:	69e2                	ld	s3,24(sp)
    25ee:	6a42                	ld	s4,16(sp)
    25f0:	6aa2                	ld	s5,8(sp)
    25f2:	6121                	addi	sp,sp,64
    25f4:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    25f6:	85d6                	mv	a1,s5
    25f8:	00004517          	auipc	a0,0x4
    25fc:	92050513          	addi	a0,a0,-1760 # 5f18 <malloc+0x11f2>
    2600:	00002097          	auipc	ra,0x2
    2604:	668080e7          	jalr	1640(ra) # 4c68 <printf>
    exit(1);
    2608:	4505                	li	a0,1
    260a:	00002097          	auipc	ra,0x2
    260e:	2ae080e7          	jalr	686(ra) # 48b8 <exit>

0000000000002612 <linktest>:
{
    2612:	1101                	addi	sp,sp,-32
    2614:	ec06                	sd	ra,24(sp)
    2616:	e822                	sd	s0,16(sp)
    2618:	e426                	sd	s1,8(sp)
    261a:	e04a                	sd	s2,0(sp)
    261c:	1000                	addi	s0,sp,32
    261e:	892a                	mv	s2,a0
  unlink("lf1");
    2620:	00004517          	auipc	a0,0x4
    2624:	91850513          	addi	a0,a0,-1768 # 5f38 <malloc+0x1212>
    2628:	00002097          	auipc	ra,0x2
    262c:	2e0080e7          	jalr	736(ra) # 4908 <unlink>
  unlink("lf2");
    2630:	00004517          	auipc	a0,0x4
    2634:	91050513          	addi	a0,a0,-1776 # 5f40 <malloc+0x121a>
    2638:	00002097          	auipc	ra,0x2
    263c:	2d0080e7          	jalr	720(ra) # 4908 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
    2640:	20200593          	li	a1,514
    2644:	00004517          	auipc	a0,0x4
    2648:	8f450513          	addi	a0,a0,-1804 # 5f38 <malloc+0x1212>
    264c:	00002097          	auipc	ra,0x2
    2650:	2ac080e7          	jalr	684(ra) # 48f8 <open>
  if(fd < 0){
    2654:	10054763          	bltz	a0,2762 <linktest+0x150>
    2658:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
    265a:	4615                	li	a2,5
    265c:	00003597          	auipc	a1,0x3
    2660:	d9c58593          	addi	a1,a1,-612 # 53f8 <malloc+0x6d2>
    2664:	00002097          	auipc	ra,0x2
    2668:	274080e7          	jalr	628(ra) # 48d8 <write>
    266c:	4795                	li	a5,5
    266e:	10f51863          	bne	a0,a5,277e <linktest+0x16c>
  close(fd);
    2672:	8526                	mv	a0,s1
    2674:	00002097          	auipc	ra,0x2
    2678:	26c080e7          	jalr	620(ra) # 48e0 <close>
  if(link("lf1", "lf2") < 0){
    267c:	00004597          	auipc	a1,0x4
    2680:	8c458593          	addi	a1,a1,-1852 # 5f40 <malloc+0x121a>
    2684:	00004517          	auipc	a0,0x4
    2688:	8b450513          	addi	a0,a0,-1868 # 5f38 <malloc+0x1212>
    268c:	00002097          	auipc	ra,0x2
    2690:	28c080e7          	jalr	652(ra) # 4918 <link>
    2694:	10054363          	bltz	a0,279a <linktest+0x188>
  unlink("lf1");
    2698:	00004517          	auipc	a0,0x4
    269c:	8a050513          	addi	a0,a0,-1888 # 5f38 <malloc+0x1212>
    26a0:	00002097          	auipc	ra,0x2
    26a4:	268080e7          	jalr	616(ra) # 4908 <unlink>
  if(open("lf1", 0) >= 0){
    26a8:	4581                	li	a1,0
    26aa:	00004517          	auipc	a0,0x4
    26ae:	88e50513          	addi	a0,a0,-1906 # 5f38 <malloc+0x1212>
    26b2:	00002097          	auipc	ra,0x2
    26b6:	246080e7          	jalr	582(ra) # 48f8 <open>
    26ba:	0e055e63          	bgez	a0,27b6 <linktest+0x1a4>
  fd = open("lf2", 0);
    26be:	4581                	li	a1,0
    26c0:	00004517          	auipc	a0,0x4
    26c4:	88050513          	addi	a0,a0,-1920 # 5f40 <malloc+0x121a>
    26c8:	00002097          	auipc	ra,0x2
    26cc:	230080e7          	jalr	560(ra) # 48f8 <open>
    26d0:	84aa                	mv	s1,a0
  if(fd < 0){
    26d2:	10054063          	bltz	a0,27d2 <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
    26d6:	660d                	lui	a2,0x3
    26d8:	00007597          	auipc	a1,0x7
    26dc:	17858593          	addi	a1,a1,376 # 9850 <buf>
    26e0:	00002097          	auipc	ra,0x2
    26e4:	1f0080e7          	jalr	496(ra) # 48d0 <read>
    26e8:	4795                	li	a5,5
    26ea:	10f51263          	bne	a0,a5,27ee <linktest+0x1dc>
  close(fd);
    26ee:	8526                	mv	a0,s1
    26f0:	00002097          	auipc	ra,0x2
    26f4:	1f0080e7          	jalr	496(ra) # 48e0 <close>
  if(link("lf2", "lf2") >= 0){
    26f8:	00004597          	auipc	a1,0x4
    26fc:	84858593          	addi	a1,a1,-1976 # 5f40 <malloc+0x121a>
    2700:	852e                	mv	a0,a1
    2702:	00002097          	auipc	ra,0x2
    2706:	216080e7          	jalr	534(ra) # 4918 <link>
    270a:	10055063          	bgez	a0,280a <linktest+0x1f8>
  unlink("lf2");
    270e:	00004517          	auipc	a0,0x4
    2712:	83250513          	addi	a0,a0,-1998 # 5f40 <malloc+0x121a>
    2716:	00002097          	auipc	ra,0x2
    271a:	1f2080e7          	jalr	498(ra) # 4908 <unlink>
  if(link("lf2", "lf1") >= 0){
    271e:	00004597          	auipc	a1,0x4
    2722:	81a58593          	addi	a1,a1,-2022 # 5f38 <malloc+0x1212>
    2726:	00004517          	auipc	a0,0x4
    272a:	81a50513          	addi	a0,a0,-2022 # 5f40 <malloc+0x121a>
    272e:	00002097          	auipc	ra,0x2
    2732:	1ea080e7          	jalr	490(ra) # 4918 <link>
    2736:	0e055863          	bgez	a0,2826 <linktest+0x214>
  if(link(".", "lf1") >= 0){
    273a:	00003597          	auipc	a1,0x3
    273e:	7fe58593          	addi	a1,a1,2046 # 5f38 <malloc+0x1212>
    2742:	00003517          	auipc	a0,0x3
    2746:	2d650513          	addi	a0,a0,726 # 5a18 <malloc+0xcf2>
    274a:	00002097          	auipc	ra,0x2
    274e:	1ce080e7          	jalr	462(ra) # 4918 <link>
    2752:	0e055863          	bgez	a0,2842 <linktest+0x230>
}
    2756:	60e2                	ld	ra,24(sp)
    2758:	6442                	ld	s0,16(sp)
    275a:	64a2                	ld	s1,8(sp)
    275c:	6902                	ld	s2,0(sp)
    275e:	6105                	addi	sp,sp,32
    2760:	8082                	ret
    printf("%s: create lf1 failed\n", s);
    2762:	85ca                	mv	a1,s2
    2764:	00003517          	auipc	a0,0x3
    2768:	7e450513          	addi	a0,a0,2020 # 5f48 <malloc+0x1222>
    276c:	00002097          	auipc	ra,0x2
    2770:	4fc080e7          	jalr	1276(ra) # 4c68 <printf>
    exit(1);
    2774:	4505                	li	a0,1
    2776:	00002097          	auipc	ra,0x2
    277a:	142080e7          	jalr	322(ra) # 48b8 <exit>
    printf("%s: write lf1 failed\n", s);
    277e:	85ca                	mv	a1,s2
    2780:	00003517          	auipc	a0,0x3
    2784:	7e050513          	addi	a0,a0,2016 # 5f60 <malloc+0x123a>
    2788:	00002097          	auipc	ra,0x2
    278c:	4e0080e7          	jalr	1248(ra) # 4c68 <printf>
    exit(1);
    2790:	4505                	li	a0,1
    2792:	00002097          	auipc	ra,0x2
    2796:	126080e7          	jalr	294(ra) # 48b8 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
    279a:	85ca                	mv	a1,s2
    279c:	00003517          	auipc	a0,0x3
    27a0:	7dc50513          	addi	a0,a0,2012 # 5f78 <malloc+0x1252>
    27a4:	00002097          	auipc	ra,0x2
    27a8:	4c4080e7          	jalr	1220(ra) # 4c68 <printf>
    exit(1);
    27ac:	4505                	li	a0,1
    27ae:	00002097          	auipc	ra,0x2
    27b2:	10a080e7          	jalr	266(ra) # 48b8 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
    27b6:	85ca                	mv	a1,s2
    27b8:	00003517          	auipc	a0,0x3
    27bc:	7e050513          	addi	a0,a0,2016 # 5f98 <malloc+0x1272>
    27c0:	00002097          	auipc	ra,0x2
    27c4:	4a8080e7          	jalr	1192(ra) # 4c68 <printf>
    exit(1);
    27c8:	4505                	li	a0,1
    27ca:	00002097          	auipc	ra,0x2
    27ce:	0ee080e7          	jalr	238(ra) # 48b8 <exit>
    printf("%s: open lf2 failed\n", s);
    27d2:	85ca                	mv	a1,s2
    27d4:	00003517          	auipc	a0,0x3
    27d8:	7f450513          	addi	a0,a0,2036 # 5fc8 <malloc+0x12a2>
    27dc:	00002097          	auipc	ra,0x2
    27e0:	48c080e7          	jalr	1164(ra) # 4c68 <printf>
    exit(1);
    27e4:	4505                	li	a0,1
    27e6:	00002097          	auipc	ra,0x2
    27ea:	0d2080e7          	jalr	210(ra) # 48b8 <exit>
    printf("%s: read lf2 failed\n", s);
    27ee:	85ca                	mv	a1,s2
    27f0:	00003517          	auipc	a0,0x3
    27f4:	7f050513          	addi	a0,a0,2032 # 5fe0 <malloc+0x12ba>
    27f8:	00002097          	auipc	ra,0x2
    27fc:	470080e7          	jalr	1136(ra) # 4c68 <printf>
    exit(1);
    2800:	4505                	li	a0,1
    2802:	00002097          	auipc	ra,0x2
    2806:	0b6080e7          	jalr	182(ra) # 48b8 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
    280a:	85ca                	mv	a1,s2
    280c:	00003517          	auipc	a0,0x3
    2810:	7ec50513          	addi	a0,a0,2028 # 5ff8 <malloc+0x12d2>
    2814:	00002097          	auipc	ra,0x2
    2818:	454080e7          	jalr	1108(ra) # 4c68 <printf>
    exit(1);
    281c:	4505                	li	a0,1
    281e:	00002097          	auipc	ra,0x2
    2822:	09a080e7          	jalr	154(ra) # 48b8 <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
    2826:	85ca                	mv	a1,s2
    2828:	00003517          	auipc	a0,0x3
    282c:	7f850513          	addi	a0,a0,2040 # 6020 <malloc+0x12fa>
    2830:	00002097          	auipc	ra,0x2
    2834:	438080e7          	jalr	1080(ra) # 4c68 <printf>
    exit(1);
    2838:	4505                	li	a0,1
    283a:	00002097          	auipc	ra,0x2
    283e:	07e080e7          	jalr	126(ra) # 48b8 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
    2842:	85ca                	mv	a1,s2
    2844:	00004517          	auipc	a0,0x4
    2848:	80450513          	addi	a0,a0,-2044 # 6048 <malloc+0x1322>
    284c:	00002097          	auipc	ra,0x2
    2850:	41c080e7          	jalr	1052(ra) # 4c68 <printf>
    exit(1);
    2854:	4505                	li	a0,1
    2856:	00002097          	auipc	ra,0x2
    285a:	062080e7          	jalr	98(ra) # 48b8 <exit>

000000000000285e <concreate>:
{
    285e:	7135                	addi	sp,sp,-160
    2860:	ed06                	sd	ra,152(sp)
    2862:	e922                	sd	s0,144(sp)
    2864:	e526                	sd	s1,136(sp)
    2866:	e14a                	sd	s2,128(sp)
    2868:	fcce                	sd	s3,120(sp)
    286a:	f8d2                	sd	s4,112(sp)
    286c:	f4d6                	sd	s5,104(sp)
    286e:	f0da                	sd	s6,96(sp)
    2870:	ecde                	sd	s7,88(sp)
    2872:	1100                	addi	s0,sp,160
    2874:	89aa                	mv	s3,a0
  file[0] = 'C';
    2876:	04300793          	li	a5,67
    287a:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    287e:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    2882:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    2884:	4b0d                	li	s6,3
    2886:	4a85                	li	s5,1
      link("C0", file);
    2888:	00003b97          	auipc	s7,0x3
    288c:	7e0b8b93          	addi	s7,s7,2016 # 6068 <malloc+0x1342>
  for(i = 0; i < N; i++){
    2890:	02800a13          	li	s4,40
    2894:	a471                	j	2b20 <concreate+0x2c2>
      link("C0", file);
    2896:	fa840593          	addi	a1,s0,-88
    289a:	855e                	mv	a0,s7
    289c:	00002097          	auipc	ra,0x2
    28a0:	07c080e7          	jalr	124(ra) # 4918 <link>
    if(pid == 0) {
    28a4:	a48d                	j	2b06 <concreate+0x2a8>
    } else if(pid == 0 && (i % 5) == 1){
    28a6:	4795                	li	a5,5
    28a8:	02f9693b          	remw	s2,s2,a5
    28ac:	4785                	li	a5,1
    28ae:	02f90b63          	beq	s2,a5,28e4 <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    28b2:	20200593          	li	a1,514
    28b6:	fa840513          	addi	a0,s0,-88
    28ba:	00002097          	auipc	ra,0x2
    28be:	03e080e7          	jalr	62(ra) # 48f8 <open>
      if(fd < 0){
    28c2:	22055963          	bgez	a0,2af4 <concreate+0x296>
        printf("concreate create %s failed\n", file);
    28c6:	fa840593          	addi	a1,s0,-88
    28ca:	00003517          	auipc	a0,0x3
    28ce:	7a650513          	addi	a0,a0,1958 # 6070 <malloc+0x134a>
    28d2:	00002097          	auipc	ra,0x2
    28d6:	396080e7          	jalr	918(ra) # 4c68 <printf>
        exit(1);
    28da:	4505                	li	a0,1
    28dc:	00002097          	auipc	ra,0x2
    28e0:	fdc080e7          	jalr	-36(ra) # 48b8 <exit>
      link("C0", file);
    28e4:	fa840593          	addi	a1,s0,-88
    28e8:	00003517          	auipc	a0,0x3
    28ec:	78050513          	addi	a0,a0,1920 # 6068 <malloc+0x1342>
    28f0:	00002097          	auipc	ra,0x2
    28f4:	028080e7          	jalr	40(ra) # 4918 <link>
      exit(0);
    28f8:	4501                	li	a0,0
    28fa:	00002097          	auipc	ra,0x2
    28fe:	fbe080e7          	jalr	-66(ra) # 48b8 <exit>
        exit(1);
    2902:	4505                	li	a0,1
    2904:	00002097          	auipc	ra,0x2
    2908:	fb4080e7          	jalr	-76(ra) # 48b8 <exit>
  memset(fa, 0, sizeof(fa));
    290c:	02800613          	li	a2,40
    2910:	4581                	li	a1,0
    2912:	f8040513          	addi	a0,s0,-128
    2916:	00002097          	auipc	ra,0x2
    291a:	d9e080e7          	jalr	-610(ra) # 46b4 <memset>
  fd = open(".", 0);
    291e:	4581                	li	a1,0
    2920:	00003517          	auipc	a0,0x3
    2924:	0f850513          	addi	a0,a0,248 # 5a18 <malloc+0xcf2>
    2928:	00002097          	auipc	ra,0x2
    292c:	fd0080e7          	jalr	-48(ra) # 48f8 <open>
    2930:	892a                	mv	s2,a0
  n = 0;
    2932:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    2934:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    2938:	02700b13          	li	s6,39
      fa[i] = 1;
    293c:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    293e:	a03d                	j	296c <concreate+0x10e>
        printf("%s: concreate weird file %s\n", s, de.name);
    2940:	f7240613          	addi	a2,s0,-142
    2944:	85ce                	mv	a1,s3
    2946:	00003517          	auipc	a0,0x3
    294a:	74a50513          	addi	a0,a0,1866 # 6090 <malloc+0x136a>
    294e:	00002097          	auipc	ra,0x2
    2952:	31a080e7          	jalr	794(ra) # 4c68 <printf>
        exit(1);
    2956:	4505                	li	a0,1
    2958:	00002097          	auipc	ra,0x2
    295c:	f60080e7          	jalr	-160(ra) # 48b8 <exit>
      fa[i] = 1;
    2960:	fb040793          	addi	a5,s0,-80
    2964:	973e                	add	a4,a4,a5
    2966:	fd770823          	sb	s7,-48(a4)
      n++;
    296a:	2a85                	addiw	s5,s5,1
  while(read(fd, &de, sizeof(de)) > 0){
    296c:	4641                	li	a2,16
    296e:	f7040593          	addi	a1,s0,-144
    2972:	854a                	mv	a0,s2
    2974:	00002097          	auipc	ra,0x2
    2978:	f5c080e7          	jalr	-164(ra) # 48d0 <read>
    297c:	04a05a63          	blez	a0,29d0 <concreate+0x172>
    if(de.inum == 0)
    2980:	f7045783          	lhu	a5,-144(s0)
    2984:	d7e5                	beqz	a5,296c <concreate+0x10e>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    2986:	f7244783          	lbu	a5,-142(s0)
    298a:	ff4791e3          	bne	a5,s4,296c <concreate+0x10e>
    298e:	f7444783          	lbu	a5,-140(s0)
    2992:	ffe9                	bnez	a5,296c <concreate+0x10e>
      i = de.name[1] - '0';
    2994:	f7344783          	lbu	a5,-141(s0)
    2998:	fd07879b          	addiw	a5,a5,-48
    299c:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    29a0:	faeb60e3          	bltu	s6,a4,2940 <concreate+0xe2>
      if(fa[i]){
    29a4:	fb040793          	addi	a5,s0,-80
    29a8:	97ba                	add	a5,a5,a4
    29aa:	fd07c783          	lbu	a5,-48(a5)
    29ae:	dbcd                	beqz	a5,2960 <concreate+0x102>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    29b0:	f7240613          	addi	a2,s0,-142
    29b4:	85ce                	mv	a1,s3
    29b6:	00003517          	auipc	a0,0x3
    29ba:	6fa50513          	addi	a0,a0,1786 # 60b0 <malloc+0x138a>
    29be:	00002097          	auipc	ra,0x2
    29c2:	2aa080e7          	jalr	682(ra) # 4c68 <printf>
        exit(1);
    29c6:	4505                	li	a0,1
    29c8:	00002097          	auipc	ra,0x2
    29cc:	ef0080e7          	jalr	-272(ra) # 48b8 <exit>
  close(fd);
    29d0:	854a                	mv	a0,s2
    29d2:	00002097          	auipc	ra,0x2
    29d6:	f0e080e7          	jalr	-242(ra) # 48e0 <close>
  if(n != N){
    29da:	02800793          	li	a5,40
    29de:	00fa9763          	bne	s5,a5,29ec <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    29e2:	4a8d                	li	s5,3
    29e4:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    29e6:	02800a13          	li	s4,40
    29ea:	a05d                	j	2a90 <concreate+0x232>
    printf("%s: concreate not enough files in directory listing\n", s);
    29ec:	85ce                	mv	a1,s3
    29ee:	00003517          	auipc	a0,0x3
    29f2:	6ea50513          	addi	a0,a0,1770 # 60d8 <malloc+0x13b2>
    29f6:	00002097          	auipc	ra,0x2
    29fa:	272080e7          	jalr	626(ra) # 4c68 <printf>
    exit(1);
    29fe:	4505                	li	a0,1
    2a00:	00002097          	auipc	ra,0x2
    2a04:	eb8080e7          	jalr	-328(ra) # 48b8 <exit>
      printf("%s: fork failed\n", s);
    2a08:	85ce                	mv	a1,s3
    2a0a:	00003517          	auipc	a0,0x3
    2a0e:	aee50513          	addi	a0,a0,-1298 # 54f8 <malloc+0x7d2>
    2a12:	00002097          	auipc	ra,0x2
    2a16:	256080e7          	jalr	598(ra) # 4c68 <printf>
      exit(1);
    2a1a:	4505                	li	a0,1
    2a1c:	00002097          	auipc	ra,0x2
    2a20:	e9c080e7          	jalr	-356(ra) # 48b8 <exit>
      close(open(file, 0));
    2a24:	4581                	li	a1,0
    2a26:	fa840513          	addi	a0,s0,-88
    2a2a:	00002097          	auipc	ra,0x2
    2a2e:	ece080e7          	jalr	-306(ra) # 48f8 <open>
    2a32:	00002097          	auipc	ra,0x2
    2a36:	eae080e7          	jalr	-338(ra) # 48e0 <close>
      close(open(file, 0));
    2a3a:	4581                	li	a1,0
    2a3c:	fa840513          	addi	a0,s0,-88
    2a40:	00002097          	auipc	ra,0x2
    2a44:	eb8080e7          	jalr	-328(ra) # 48f8 <open>
    2a48:	00002097          	auipc	ra,0x2
    2a4c:	e98080e7          	jalr	-360(ra) # 48e0 <close>
      close(open(file, 0));
    2a50:	4581                	li	a1,0
    2a52:	fa840513          	addi	a0,s0,-88
    2a56:	00002097          	auipc	ra,0x2
    2a5a:	ea2080e7          	jalr	-350(ra) # 48f8 <open>
    2a5e:	00002097          	auipc	ra,0x2
    2a62:	e82080e7          	jalr	-382(ra) # 48e0 <close>
      close(open(file, 0));
    2a66:	4581                	li	a1,0
    2a68:	fa840513          	addi	a0,s0,-88
    2a6c:	00002097          	auipc	ra,0x2
    2a70:	e8c080e7          	jalr	-372(ra) # 48f8 <open>
    2a74:	00002097          	auipc	ra,0x2
    2a78:	e6c080e7          	jalr	-404(ra) # 48e0 <close>
    if(pid == 0)
    2a7c:	06090763          	beqz	s2,2aea <concreate+0x28c>
      wait(0);
    2a80:	4501                	li	a0,0
    2a82:	00002097          	auipc	ra,0x2
    2a86:	e3e080e7          	jalr	-450(ra) # 48c0 <wait>
  for(i = 0; i < N; i++){
    2a8a:	2485                	addiw	s1,s1,1
    2a8c:	0d448963          	beq	s1,s4,2b5e <concreate+0x300>
    file[1] = '0' + i;
    2a90:	0304879b          	addiw	a5,s1,48
    2a94:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    2a98:	00002097          	auipc	ra,0x2
    2a9c:	e18080e7          	jalr	-488(ra) # 48b0 <fork>
    2aa0:	892a                	mv	s2,a0
    if(pid < 0){
    2aa2:	f60543e3          	bltz	a0,2a08 <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    2aa6:	0354e73b          	remw	a4,s1,s5
    2aaa:	00a767b3          	or	a5,a4,a0
    2aae:	2781                	sext.w	a5,a5
    2ab0:	dbb5                	beqz	a5,2a24 <concreate+0x1c6>
    2ab2:	01671363          	bne	a4,s6,2ab8 <concreate+0x25a>
       ((i % 3) == 1 && pid != 0)){
    2ab6:	f53d                	bnez	a0,2a24 <concreate+0x1c6>
      unlink(file);
    2ab8:	fa840513          	addi	a0,s0,-88
    2abc:	00002097          	auipc	ra,0x2
    2ac0:	e4c080e7          	jalr	-436(ra) # 4908 <unlink>
      unlink(file);
    2ac4:	fa840513          	addi	a0,s0,-88
    2ac8:	00002097          	auipc	ra,0x2
    2acc:	e40080e7          	jalr	-448(ra) # 4908 <unlink>
      unlink(file);
    2ad0:	fa840513          	addi	a0,s0,-88
    2ad4:	00002097          	auipc	ra,0x2
    2ad8:	e34080e7          	jalr	-460(ra) # 4908 <unlink>
      unlink(file);
    2adc:	fa840513          	addi	a0,s0,-88
    2ae0:	00002097          	auipc	ra,0x2
    2ae4:	e28080e7          	jalr	-472(ra) # 4908 <unlink>
    2ae8:	bf51                	j	2a7c <concreate+0x21e>
      exit(0);
    2aea:	4501                	li	a0,0
    2aec:	00002097          	auipc	ra,0x2
    2af0:	dcc080e7          	jalr	-564(ra) # 48b8 <exit>
      close(fd);
    2af4:	00002097          	auipc	ra,0x2
    2af8:	dec080e7          	jalr	-532(ra) # 48e0 <close>
    if(pid == 0) {
    2afc:	bbf5                	j	28f8 <concreate+0x9a>
      close(fd);
    2afe:	00002097          	auipc	ra,0x2
    2b02:	de2080e7          	jalr	-542(ra) # 48e0 <close>
      wait(&xstatus);
    2b06:	f6c40513          	addi	a0,s0,-148
    2b0a:	00002097          	auipc	ra,0x2
    2b0e:	db6080e7          	jalr	-586(ra) # 48c0 <wait>
      if(xstatus != 0)
    2b12:	f6c42483          	lw	s1,-148(s0)
    2b16:	de0496e3          	bnez	s1,2902 <concreate+0xa4>
  for(i = 0; i < N; i++){
    2b1a:	2905                	addiw	s2,s2,1
    2b1c:	df4908e3          	beq	s2,s4,290c <concreate+0xae>
    file[1] = '0' + i;
    2b20:	0309079b          	addiw	a5,s2,48
    2b24:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    2b28:	fa840513          	addi	a0,s0,-88
    2b2c:	00002097          	auipc	ra,0x2
    2b30:	ddc080e7          	jalr	-548(ra) # 4908 <unlink>
    pid = fork();
    2b34:	00002097          	auipc	ra,0x2
    2b38:	d7c080e7          	jalr	-644(ra) # 48b0 <fork>
    if(pid && (i % 3) == 1){
    2b3c:	d60505e3          	beqz	a0,28a6 <concreate+0x48>
    2b40:	036967bb          	remw	a5,s2,s6
    2b44:	d55789e3          	beq	a5,s5,2896 <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    2b48:	20200593          	li	a1,514
    2b4c:	fa840513          	addi	a0,s0,-88
    2b50:	00002097          	auipc	ra,0x2
    2b54:	da8080e7          	jalr	-600(ra) # 48f8 <open>
      if(fd < 0){
    2b58:	fa0553e3          	bgez	a0,2afe <concreate+0x2a0>
    2b5c:	b3ad                	j	28c6 <concreate+0x68>
}
    2b5e:	60ea                	ld	ra,152(sp)
    2b60:	644a                	ld	s0,144(sp)
    2b62:	64aa                	ld	s1,136(sp)
    2b64:	690a                	ld	s2,128(sp)
    2b66:	79e6                	ld	s3,120(sp)
    2b68:	7a46                	ld	s4,112(sp)
    2b6a:	7aa6                	ld	s5,104(sp)
    2b6c:	7b06                	ld	s6,96(sp)
    2b6e:	6be6                	ld	s7,88(sp)
    2b70:	610d                	addi	sp,sp,160
    2b72:	8082                	ret

0000000000002b74 <linkunlink>:
{
    2b74:	711d                	addi	sp,sp,-96
    2b76:	ec86                	sd	ra,88(sp)
    2b78:	e8a2                	sd	s0,80(sp)
    2b7a:	e4a6                	sd	s1,72(sp)
    2b7c:	e0ca                	sd	s2,64(sp)
    2b7e:	fc4e                	sd	s3,56(sp)
    2b80:	f852                	sd	s4,48(sp)
    2b82:	f456                	sd	s5,40(sp)
    2b84:	f05a                	sd	s6,32(sp)
    2b86:	ec5e                	sd	s7,24(sp)
    2b88:	e862                	sd	s8,16(sp)
    2b8a:	e466                	sd	s9,8(sp)
    2b8c:	1080                	addi	s0,sp,96
    2b8e:	84aa                	mv	s1,a0
  unlink("x");
    2b90:	00002517          	auipc	a0,0x2
    2b94:	5e050513          	addi	a0,a0,1504 # 5170 <malloc+0x44a>
    2b98:	00002097          	auipc	ra,0x2
    2b9c:	d70080e7          	jalr	-656(ra) # 4908 <unlink>
  pid = fork();
    2ba0:	00002097          	auipc	ra,0x2
    2ba4:	d10080e7          	jalr	-752(ra) # 48b0 <fork>
  if(pid < 0){
    2ba8:	02054b63          	bltz	a0,2bde <linkunlink+0x6a>
    2bac:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    2bae:	4c85                	li	s9,1
    2bb0:	e119                	bnez	a0,2bb6 <linkunlink+0x42>
    2bb2:	06100c93          	li	s9,97
    2bb6:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    2bba:	41c659b7          	lui	s3,0x41c65
    2bbe:	e6d9899b          	addiw	s3,s3,-403
    2bc2:	690d                	lui	s2,0x3
    2bc4:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    2bc8:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    2bca:	4b05                	li	s6,1
      unlink("x");
    2bcc:	00002a97          	auipc	s5,0x2
    2bd0:	5a4a8a93          	addi	s5,s5,1444 # 5170 <malloc+0x44a>
      link("cat", "x");
    2bd4:	00003b97          	auipc	s7,0x3
    2bd8:	53cb8b93          	addi	s7,s7,1340 # 6110 <malloc+0x13ea>
    2bdc:	a091                	j	2c20 <linkunlink+0xac>
    printf("%s: fork failed\n", s);
    2bde:	85a6                	mv	a1,s1
    2be0:	00003517          	auipc	a0,0x3
    2be4:	91850513          	addi	a0,a0,-1768 # 54f8 <malloc+0x7d2>
    2be8:	00002097          	auipc	ra,0x2
    2bec:	080080e7          	jalr	128(ra) # 4c68 <printf>
    exit(1);
    2bf0:	4505                	li	a0,1
    2bf2:	00002097          	auipc	ra,0x2
    2bf6:	cc6080e7          	jalr	-826(ra) # 48b8 <exit>
      close(open("x", O_RDWR | O_CREATE));
    2bfa:	20200593          	li	a1,514
    2bfe:	8556                	mv	a0,s5
    2c00:	00002097          	auipc	ra,0x2
    2c04:	cf8080e7          	jalr	-776(ra) # 48f8 <open>
    2c08:	00002097          	auipc	ra,0x2
    2c0c:	cd8080e7          	jalr	-808(ra) # 48e0 <close>
    2c10:	a031                	j	2c1c <linkunlink+0xa8>
      unlink("x");
    2c12:	8556                	mv	a0,s5
    2c14:	00002097          	auipc	ra,0x2
    2c18:	cf4080e7          	jalr	-780(ra) # 4908 <unlink>
  for(i = 0; i < 100; i++){
    2c1c:	34fd                	addiw	s1,s1,-1
    2c1e:	c09d                	beqz	s1,2c44 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    2c20:	033c87bb          	mulw	a5,s9,s3
    2c24:	012787bb          	addw	a5,a5,s2
    2c28:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    2c2c:	0347f7bb          	remuw	a5,a5,s4
    2c30:	d7e9                	beqz	a5,2bfa <linkunlink+0x86>
    } else if((x % 3) == 1){
    2c32:	ff6790e3          	bne	a5,s6,2c12 <linkunlink+0x9e>
      link("cat", "x");
    2c36:	85d6                	mv	a1,s5
    2c38:	855e                	mv	a0,s7
    2c3a:	00002097          	auipc	ra,0x2
    2c3e:	cde080e7          	jalr	-802(ra) # 4918 <link>
    2c42:	bfe9                	j	2c1c <linkunlink+0xa8>
  if(pid)
    2c44:	020c0463          	beqz	s8,2c6c <linkunlink+0xf8>
    wait(0);
    2c48:	4501                	li	a0,0
    2c4a:	00002097          	auipc	ra,0x2
    2c4e:	c76080e7          	jalr	-906(ra) # 48c0 <wait>
}
    2c52:	60e6                	ld	ra,88(sp)
    2c54:	6446                	ld	s0,80(sp)
    2c56:	64a6                	ld	s1,72(sp)
    2c58:	6906                	ld	s2,64(sp)
    2c5a:	79e2                	ld	s3,56(sp)
    2c5c:	7a42                	ld	s4,48(sp)
    2c5e:	7aa2                	ld	s5,40(sp)
    2c60:	7b02                	ld	s6,32(sp)
    2c62:	6be2                	ld	s7,24(sp)
    2c64:	6c42                	ld	s8,16(sp)
    2c66:	6ca2                	ld	s9,8(sp)
    2c68:	6125                	addi	sp,sp,96
    2c6a:	8082                	ret
    exit(0);
    2c6c:	4501                	li	a0,0
    2c6e:	00002097          	auipc	ra,0x2
    2c72:	c4a080e7          	jalr	-950(ra) # 48b8 <exit>

0000000000002c76 <bigdir>:
{
    2c76:	715d                	addi	sp,sp,-80
    2c78:	e486                	sd	ra,72(sp)
    2c7a:	e0a2                	sd	s0,64(sp)
    2c7c:	fc26                	sd	s1,56(sp)
    2c7e:	f84a                	sd	s2,48(sp)
    2c80:	f44e                	sd	s3,40(sp)
    2c82:	f052                	sd	s4,32(sp)
    2c84:	ec56                	sd	s5,24(sp)
    2c86:	e85a                	sd	s6,16(sp)
    2c88:	0880                	addi	s0,sp,80
    2c8a:	89aa                	mv	s3,a0
  unlink("bd");
    2c8c:	00003517          	auipc	a0,0x3
    2c90:	48c50513          	addi	a0,a0,1164 # 6118 <malloc+0x13f2>
    2c94:	00002097          	auipc	ra,0x2
    2c98:	c74080e7          	jalr	-908(ra) # 4908 <unlink>
  fd = open("bd", O_CREATE);
    2c9c:	20000593          	li	a1,512
    2ca0:	00003517          	auipc	a0,0x3
    2ca4:	47850513          	addi	a0,a0,1144 # 6118 <malloc+0x13f2>
    2ca8:	00002097          	auipc	ra,0x2
    2cac:	c50080e7          	jalr	-944(ra) # 48f8 <open>
  if(fd < 0){
    2cb0:	0c054963          	bltz	a0,2d82 <bigdir+0x10c>
  close(fd);
    2cb4:	00002097          	auipc	ra,0x2
    2cb8:	c2c080e7          	jalr	-980(ra) # 48e0 <close>
  for(i = 0; i < N; i++){
    2cbc:	4901                	li	s2,0
    name[0] = 'x';
    2cbe:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
    2cc2:	00003a17          	auipc	s4,0x3
    2cc6:	456a0a13          	addi	s4,s4,1110 # 6118 <malloc+0x13f2>
  for(i = 0; i < N; i++){
    2cca:	1f400b13          	li	s6,500
    name[0] = 'x';
    2cce:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
    2cd2:	41f9579b          	sraiw	a5,s2,0x1f
    2cd6:	01a7d71b          	srliw	a4,a5,0x1a
    2cda:	012707bb          	addw	a5,a4,s2
    2cde:	4067d69b          	sraiw	a3,a5,0x6
    2ce2:	0306869b          	addiw	a3,a3,48
    2ce6:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    2cea:	03f7f793          	andi	a5,a5,63
    2cee:	9f99                	subw	a5,a5,a4
    2cf0:	0307879b          	addiw	a5,a5,48
    2cf4:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    2cf8:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
    2cfc:	fb040593          	addi	a1,s0,-80
    2d00:	8552                	mv	a0,s4
    2d02:	00002097          	auipc	ra,0x2
    2d06:	c16080e7          	jalr	-1002(ra) # 4918 <link>
    2d0a:	84aa                	mv	s1,a0
    2d0c:	e949                	bnez	a0,2d9e <bigdir+0x128>
  for(i = 0; i < N; i++){
    2d0e:	2905                	addiw	s2,s2,1
    2d10:	fb691fe3          	bne	s2,s6,2cce <bigdir+0x58>
  unlink("bd");
    2d14:	00003517          	auipc	a0,0x3
    2d18:	40450513          	addi	a0,a0,1028 # 6118 <malloc+0x13f2>
    2d1c:	00002097          	auipc	ra,0x2
    2d20:	bec080e7          	jalr	-1044(ra) # 4908 <unlink>
    name[0] = 'x';
    2d24:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    2d28:	1f400a13          	li	s4,500
    name[0] = 'x';
    2d2c:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    2d30:	41f4d79b          	sraiw	a5,s1,0x1f
    2d34:	01a7d71b          	srliw	a4,a5,0x1a
    2d38:	009707bb          	addw	a5,a4,s1
    2d3c:	4067d69b          	sraiw	a3,a5,0x6
    2d40:	0306869b          	addiw	a3,a3,48
    2d44:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    2d48:	03f7f793          	andi	a5,a5,63
    2d4c:	9f99                	subw	a5,a5,a4
    2d4e:	0307879b          	addiw	a5,a5,48
    2d52:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    2d56:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    2d5a:	fb040513          	addi	a0,s0,-80
    2d5e:	00002097          	auipc	ra,0x2
    2d62:	baa080e7          	jalr	-1110(ra) # 4908 <unlink>
    2d66:	e931                	bnez	a0,2dba <bigdir+0x144>
  for(i = 0; i < N; i++){
    2d68:	2485                	addiw	s1,s1,1
    2d6a:	fd4491e3          	bne	s1,s4,2d2c <bigdir+0xb6>
}
    2d6e:	60a6                	ld	ra,72(sp)
    2d70:	6406                	ld	s0,64(sp)
    2d72:	74e2                	ld	s1,56(sp)
    2d74:	7942                	ld	s2,48(sp)
    2d76:	79a2                	ld	s3,40(sp)
    2d78:	7a02                	ld	s4,32(sp)
    2d7a:	6ae2                	ld	s5,24(sp)
    2d7c:	6b42                	ld	s6,16(sp)
    2d7e:	6161                	addi	sp,sp,80
    2d80:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    2d82:	85ce                	mv	a1,s3
    2d84:	00003517          	auipc	a0,0x3
    2d88:	39c50513          	addi	a0,a0,924 # 6120 <malloc+0x13fa>
    2d8c:	00002097          	auipc	ra,0x2
    2d90:	edc080e7          	jalr	-292(ra) # 4c68 <printf>
    exit(1);
    2d94:	4505                	li	a0,1
    2d96:	00002097          	auipc	ra,0x2
    2d9a:	b22080e7          	jalr	-1246(ra) # 48b8 <exit>
      printf("%s: bigdir link failed\n", s);
    2d9e:	85ce                	mv	a1,s3
    2da0:	00003517          	auipc	a0,0x3
    2da4:	3a050513          	addi	a0,a0,928 # 6140 <malloc+0x141a>
    2da8:	00002097          	auipc	ra,0x2
    2dac:	ec0080e7          	jalr	-320(ra) # 4c68 <printf>
      exit(1);
    2db0:	4505                	li	a0,1
    2db2:	00002097          	auipc	ra,0x2
    2db6:	b06080e7          	jalr	-1274(ra) # 48b8 <exit>
      printf("%s: bigdir unlink failed", s);
    2dba:	85ce                	mv	a1,s3
    2dbc:	00003517          	auipc	a0,0x3
    2dc0:	39c50513          	addi	a0,a0,924 # 6158 <malloc+0x1432>
    2dc4:	00002097          	auipc	ra,0x2
    2dc8:	ea4080e7          	jalr	-348(ra) # 4c68 <printf>
      exit(1);
    2dcc:	4505                	li	a0,1
    2dce:	00002097          	auipc	ra,0x2
    2dd2:	aea080e7          	jalr	-1302(ra) # 48b8 <exit>

0000000000002dd6 <subdir>:
{
    2dd6:	1101                	addi	sp,sp,-32
    2dd8:	ec06                	sd	ra,24(sp)
    2dda:	e822                	sd	s0,16(sp)
    2ddc:	e426                	sd	s1,8(sp)
    2dde:	e04a                	sd	s2,0(sp)
    2de0:	1000                	addi	s0,sp,32
    2de2:	892a                	mv	s2,a0
  unlink("ff");
    2de4:	00003517          	auipc	a0,0x3
    2de8:	4c450513          	addi	a0,a0,1220 # 62a8 <malloc+0x1582>
    2dec:	00002097          	auipc	ra,0x2
    2df0:	b1c080e7          	jalr	-1252(ra) # 4908 <unlink>
  if(mkdir("dd") != 0){
    2df4:	00003517          	auipc	a0,0x3
    2df8:	38450513          	addi	a0,a0,900 # 6178 <malloc+0x1452>
    2dfc:	00002097          	auipc	ra,0x2
    2e00:	b24080e7          	jalr	-1244(ra) # 4920 <mkdir>
    2e04:	38051663          	bnez	a0,3190 <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    2e08:	20200593          	li	a1,514
    2e0c:	00003517          	auipc	a0,0x3
    2e10:	38c50513          	addi	a0,a0,908 # 6198 <malloc+0x1472>
    2e14:	00002097          	auipc	ra,0x2
    2e18:	ae4080e7          	jalr	-1308(ra) # 48f8 <open>
    2e1c:	84aa                	mv	s1,a0
  if(fd < 0){
    2e1e:	38054763          	bltz	a0,31ac <subdir+0x3d6>
  write(fd, "ff", 2);
    2e22:	4609                	li	a2,2
    2e24:	00003597          	auipc	a1,0x3
    2e28:	48458593          	addi	a1,a1,1156 # 62a8 <malloc+0x1582>
    2e2c:	00002097          	auipc	ra,0x2
    2e30:	aac080e7          	jalr	-1364(ra) # 48d8 <write>
  close(fd);
    2e34:	8526                	mv	a0,s1
    2e36:	00002097          	auipc	ra,0x2
    2e3a:	aaa080e7          	jalr	-1366(ra) # 48e0 <close>
  if(unlink("dd") >= 0){
    2e3e:	00003517          	auipc	a0,0x3
    2e42:	33a50513          	addi	a0,a0,826 # 6178 <malloc+0x1452>
    2e46:	00002097          	auipc	ra,0x2
    2e4a:	ac2080e7          	jalr	-1342(ra) # 4908 <unlink>
    2e4e:	36055d63          	bgez	a0,31c8 <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    2e52:	00003517          	auipc	a0,0x3
    2e56:	39e50513          	addi	a0,a0,926 # 61f0 <malloc+0x14ca>
    2e5a:	00002097          	auipc	ra,0x2
    2e5e:	ac6080e7          	jalr	-1338(ra) # 4920 <mkdir>
    2e62:	38051163          	bnez	a0,31e4 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    2e66:	20200593          	li	a1,514
    2e6a:	00003517          	auipc	a0,0x3
    2e6e:	3ae50513          	addi	a0,a0,942 # 6218 <malloc+0x14f2>
    2e72:	00002097          	auipc	ra,0x2
    2e76:	a86080e7          	jalr	-1402(ra) # 48f8 <open>
    2e7a:	84aa                	mv	s1,a0
  if(fd < 0){
    2e7c:	38054263          	bltz	a0,3200 <subdir+0x42a>
  write(fd, "FF", 2);
    2e80:	4609                	li	a2,2
    2e82:	00003597          	auipc	a1,0x3
    2e86:	3c658593          	addi	a1,a1,966 # 6248 <malloc+0x1522>
    2e8a:	00002097          	auipc	ra,0x2
    2e8e:	a4e080e7          	jalr	-1458(ra) # 48d8 <write>
  close(fd);
    2e92:	8526                	mv	a0,s1
    2e94:	00002097          	auipc	ra,0x2
    2e98:	a4c080e7          	jalr	-1460(ra) # 48e0 <close>
  fd = open("dd/dd/../ff", 0);
    2e9c:	4581                	li	a1,0
    2e9e:	00003517          	auipc	a0,0x3
    2ea2:	3b250513          	addi	a0,a0,946 # 6250 <malloc+0x152a>
    2ea6:	00002097          	auipc	ra,0x2
    2eaa:	a52080e7          	jalr	-1454(ra) # 48f8 <open>
    2eae:	84aa                	mv	s1,a0
  if(fd < 0){
    2eb0:	36054663          	bltz	a0,321c <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    2eb4:	660d                	lui	a2,0x3
    2eb6:	00007597          	auipc	a1,0x7
    2eba:	99a58593          	addi	a1,a1,-1638 # 9850 <buf>
    2ebe:	00002097          	auipc	ra,0x2
    2ec2:	a12080e7          	jalr	-1518(ra) # 48d0 <read>
  if(cc != 2 || buf[0] != 'f'){
    2ec6:	4789                	li	a5,2
    2ec8:	36f51863          	bne	a0,a5,3238 <subdir+0x462>
    2ecc:	00007717          	auipc	a4,0x7
    2ed0:	98474703          	lbu	a4,-1660(a4) # 9850 <buf>
    2ed4:	06600793          	li	a5,102
    2ed8:	36f71063          	bne	a4,a5,3238 <subdir+0x462>
  close(fd);
    2edc:	8526                	mv	a0,s1
    2ede:	00002097          	auipc	ra,0x2
    2ee2:	a02080e7          	jalr	-1534(ra) # 48e0 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    2ee6:	00003597          	auipc	a1,0x3
    2eea:	3ba58593          	addi	a1,a1,954 # 62a0 <malloc+0x157a>
    2eee:	00003517          	auipc	a0,0x3
    2ef2:	32a50513          	addi	a0,a0,810 # 6218 <malloc+0x14f2>
    2ef6:	00002097          	auipc	ra,0x2
    2efa:	a22080e7          	jalr	-1502(ra) # 4918 <link>
    2efe:	34051b63          	bnez	a0,3254 <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    2f02:	00003517          	auipc	a0,0x3
    2f06:	31650513          	addi	a0,a0,790 # 6218 <malloc+0x14f2>
    2f0a:	00002097          	auipc	ra,0x2
    2f0e:	9fe080e7          	jalr	-1538(ra) # 4908 <unlink>
    2f12:	34051f63          	bnez	a0,3270 <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2f16:	4581                	li	a1,0
    2f18:	00003517          	auipc	a0,0x3
    2f1c:	30050513          	addi	a0,a0,768 # 6218 <malloc+0x14f2>
    2f20:	00002097          	auipc	ra,0x2
    2f24:	9d8080e7          	jalr	-1576(ra) # 48f8 <open>
    2f28:	36055263          	bgez	a0,328c <subdir+0x4b6>
  if(chdir("dd") != 0){
    2f2c:	00003517          	auipc	a0,0x3
    2f30:	24c50513          	addi	a0,a0,588 # 6178 <malloc+0x1452>
    2f34:	00002097          	auipc	ra,0x2
    2f38:	9f4080e7          	jalr	-1548(ra) # 4928 <chdir>
    2f3c:	36051663          	bnez	a0,32a8 <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    2f40:	00003517          	auipc	a0,0x3
    2f44:	3f850513          	addi	a0,a0,1016 # 6338 <malloc+0x1612>
    2f48:	00002097          	auipc	ra,0x2
    2f4c:	9e0080e7          	jalr	-1568(ra) # 4928 <chdir>
    2f50:	36051a63          	bnez	a0,32c4 <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    2f54:	00003517          	auipc	a0,0x3
    2f58:	41450513          	addi	a0,a0,1044 # 6368 <malloc+0x1642>
    2f5c:	00002097          	auipc	ra,0x2
    2f60:	9cc080e7          	jalr	-1588(ra) # 4928 <chdir>
    2f64:	36051e63          	bnez	a0,32e0 <subdir+0x50a>
  if(chdir("./..") != 0){
    2f68:	00003517          	auipc	a0,0x3
    2f6c:	43050513          	addi	a0,a0,1072 # 6398 <malloc+0x1672>
    2f70:	00002097          	auipc	ra,0x2
    2f74:	9b8080e7          	jalr	-1608(ra) # 4928 <chdir>
    2f78:	38051263          	bnez	a0,32fc <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    2f7c:	4581                	li	a1,0
    2f7e:	00003517          	auipc	a0,0x3
    2f82:	32250513          	addi	a0,a0,802 # 62a0 <malloc+0x157a>
    2f86:	00002097          	auipc	ra,0x2
    2f8a:	972080e7          	jalr	-1678(ra) # 48f8 <open>
    2f8e:	84aa                	mv	s1,a0
  if(fd < 0){
    2f90:	38054463          	bltz	a0,3318 <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    2f94:	660d                	lui	a2,0x3
    2f96:	00007597          	auipc	a1,0x7
    2f9a:	8ba58593          	addi	a1,a1,-1862 # 9850 <buf>
    2f9e:	00002097          	auipc	ra,0x2
    2fa2:	932080e7          	jalr	-1742(ra) # 48d0 <read>
    2fa6:	4789                	li	a5,2
    2fa8:	38f51663          	bne	a0,a5,3334 <subdir+0x55e>
  close(fd);
    2fac:	8526                	mv	a0,s1
    2fae:	00002097          	auipc	ra,0x2
    2fb2:	932080e7          	jalr	-1742(ra) # 48e0 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2fb6:	4581                	li	a1,0
    2fb8:	00003517          	auipc	a0,0x3
    2fbc:	26050513          	addi	a0,a0,608 # 6218 <malloc+0x14f2>
    2fc0:	00002097          	auipc	ra,0x2
    2fc4:	938080e7          	jalr	-1736(ra) # 48f8 <open>
    2fc8:	38055463          	bgez	a0,3350 <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    2fcc:	20200593          	li	a1,514
    2fd0:	00003517          	auipc	a0,0x3
    2fd4:	45850513          	addi	a0,a0,1112 # 6428 <malloc+0x1702>
    2fd8:	00002097          	auipc	ra,0x2
    2fdc:	920080e7          	jalr	-1760(ra) # 48f8 <open>
    2fe0:	38055663          	bgez	a0,336c <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    2fe4:	20200593          	li	a1,514
    2fe8:	00003517          	auipc	a0,0x3
    2fec:	47050513          	addi	a0,a0,1136 # 6458 <malloc+0x1732>
    2ff0:	00002097          	auipc	ra,0x2
    2ff4:	908080e7          	jalr	-1784(ra) # 48f8 <open>
    2ff8:	38055863          	bgez	a0,3388 <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    2ffc:	20000593          	li	a1,512
    3000:	00003517          	auipc	a0,0x3
    3004:	17850513          	addi	a0,a0,376 # 6178 <malloc+0x1452>
    3008:	00002097          	auipc	ra,0x2
    300c:	8f0080e7          	jalr	-1808(ra) # 48f8 <open>
    3010:	38055a63          	bgez	a0,33a4 <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    3014:	4589                	li	a1,2
    3016:	00003517          	auipc	a0,0x3
    301a:	16250513          	addi	a0,a0,354 # 6178 <malloc+0x1452>
    301e:	00002097          	auipc	ra,0x2
    3022:	8da080e7          	jalr	-1830(ra) # 48f8 <open>
    3026:	38055d63          	bgez	a0,33c0 <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    302a:	4585                	li	a1,1
    302c:	00003517          	auipc	a0,0x3
    3030:	14c50513          	addi	a0,a0,332 # 6178 <malloc+0x1452>
    3034:	00002097          	auipc	ra,0x2
    3038:	8c4080e7          	jalr	-1852(ra) # 48f8 <open>
    303c:	3a055063          	bgez	a0,33dc <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    3040:	00003597          	auipc	a1,0x3
    3044:	4a858593          	addi	a1,a1,1192 # 64e8 <malloc+0x17c2>
    3048:	00003517          	auipc	a0,0x3
    304c:	3e050513          	addi	a0,a0,992 # 6428 <malloc+0x1702>
    3050:	00002097          	auipc	ra,0x2
    3054:	8c8080e7          	jalr	-1848(ra) # 4918 <link>
    3058:	3a050063          	beqz	a0,33f8 <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    305c:	00003597          	auipc	a1,0x3
    3060:	48c58593          	addi	a1,a1,1164 # 64e8 <malloc+0x17c2>
    3064:	00003517          	auipc	a0,0x3
    3068:	3f450513          	addi	a0,a0,1012 # 6458 <malloc+0x1732>
    306c:	00002097          	auipc	ra,0x2
    3070:	8ac080e7          	jalr	-1876(ra) # 4918 <link>
    3074:	3a050063          	beqz	a0,3414 <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    3078:	00003597          	auipc	a1,0x3
    307c:	22858593          	addi	a1,a1,552 # 62a0 <malloc+0x157a>
    3080:	00003517          	auipc	a0,0x3
    3084:	11850513          	addi	a0,a0,280 # 6198 <malloc+0x1472>
    3088:	00002097          	auipc	ra,0x2
    308c:	890080e7          	jalr	-1904(ra) # 4918 <link>
    3090:	3a050063          	beqz	a0,3430 <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    3094:	00003517          	auipc	a0,0x3
    3098:	39450513          	addi	a0,a0,916 # 6428 <malloc+0x1702>
    309c:	00002097          	auipc	ra,0x2
    30a0:	884080e7          	jalr	-1916(ra) # 4920 <mkdir>
    30a4:	3a050463          	beqz	a0,344c <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    30a8:	00003517          	auipc	a0,0x3
    30ac:	3b050513          	addi	a0,a0,944 # 6458 <malloc+0x1732>
    30b0:	00002097          	auipc	ra,0x2
    30b4:	870080e7          	jalr	-1936(ra) # 4920 <mkdir>
    30b8:	3a050863          	beqz	a0,3468 <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    30bc:	00003517          	auipc	a0,0x3
    30c0:	1e450513          	addi	a0,a0,484 # 62a0 <malloc+0x157a>
    30c4:	00002097          	auipc	ra,0x2
    30c8:	85c080e7          	jalr	-1956(ra) # 4920 <mkdir>
    30cc:	3a050c63          	beqz	a0,3484 <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    30d0:	00003517          	auipc	a0,0x3
    30d4:	38850513          	addi	a0,a0,904 # 6458 <malloc+0x1732>
    30d8:	00002097          	auipc	ra,0x2
    30dc:	830080e7          	jalr	-2000(ra) # 4908 <unlink>
    30e0:	3c050063          	beqz	a0,34a0 <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    30e4:	00003517          	auipc	a0,0x3
    30e8:	34450513          	addi	a0,a0,836 # 6428 <malloc+0x1702>
    30ec:	00002097          	auipc	ra,0x2
    30f0:	81c080e7          	jalr	-2020(ra) # 4908 <unlink>
    30f4:	3c050463          	beqz	a0,34bc <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    30f8:	00003517          	auipc	a0,0x3
    30fc:	0a050513          	addi	a0,a0,160 # 6198 <malloc+0x1472>
    3100:	00002097          	auipc	ra,0x2
    3104:	828080e7          	jalr	-2008(ra) # 4928 <chdir>
    3108:	3c050863          	beqz	a0,34d8 <subdir+0x702>
  if(chdir("dd/xx") == 0){
    310c:	00003517          	auipc	a0,0x3
    3110:	52c50513          	addi	a0,a0,1324 # 6638 <malloc+0x1912>
    3114:	00002097          	auipc	ra,0x2
    3118:	814080e7          	jalr	-2028(ra) # 4928 <chdir>
    311c:	3c050c63          	beqz	a0,34f4 <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    3120:	00003517          	auipc	a0,0x3
    3124:	18050513          	addi	a0,a0,384 # 62a0 <malloc+0x157a>
    3128:	00001097          	auipc	ra,0x1
    312c:	7e0080e7          	jalr	2016(ra) # 4908 <unlink>
    3130:	3e051063          	bnez	a0,3510 <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    3134:	00003517          	auipc	a0,0x3
    3138:	06450513          	addi	a0,a0,100 # 6198 <malloc+0x1472>
    313c:	00001097          	auipc	ra,0x1
    3140:	7cc080e7          	jalr	1996(ra) # 4908 <unlink>
    3144:	3e051463          	bnez	a0,352c <subdir+0x756>
  if(unlink("dd") == 0){
    3148:	00003517          	auipc	a0,0x3
    314c:	03050513          	addi	a0,a0,48 # 6178 <malloc+0x1452>
    3150:	00001097          	auipc	ra,0x1
    3154:	7b8080e7          	jalr	1976(ra) # 4908 <unlink>
    3158:	3e050863          	beqz	a0,3548 <subdir+0x772>
  if(unlink("dd/dd") < 0){
    315c:	00003517          	auipc	a0,0x3
    3160:	54c50513          	addi	a0,a0,1356 # 66a8 <malloc+0x1982>
    3164:	00001097          	auipc	ra,0x1
    3168:	7a4080e7          	jalr	1956(ra) # 4908 <unlink>
    316c:	3e054c63          	bltz	a0,3564 <subdir+0x78e>
  if(unlink("dd") < 0){
    3170:	00003517          	auipc	a0,0x3
    3174:	00850513          	addi	a0,a0,8 # 6178 <malloc+0x1452>
    3178:	00001097          	auipc	ra,0x1
    317c:	790080e7          	jalr	1936(ra) # 4908 <unlink>
    3180:	40054063          	bltz	a0,3580 <subdir+0x7aa>
}
    3184:	60e2                	ld	ra,24(sp)
    3186:	6442                	ld	s0,16(sp)
    3188:	64a2                	ld	s1,8(sp)
    318a:	6902                	ld	s2,0(sp)
    318c:	6105                	addi	sp,sp,32
    318e:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    3190:	85ca                	mv	a1,s2
    3192:	00003517          	auipc	a0,0x3
    3196:	fee50513          	addi	a0,a0,-18 # 6180 <malloc+0x145a>
    319a:	00002097          	auipc	ra,0x2
    319e:	ace080e7          	jalr	-1330(ra) # 4c68 <printf>
    exit(1);
    31a2:	4505                	li	a0,1
    31a4:	00001097          	auipc	ra,0x1
    31a8:	714080e7          	jalr	1812(ra) # 48b8 <exit>
    printf("%s: create dd/ff failed\n", s);
    31ac:	85ca                	mv	a1,s2
    31ae:	00003517          	auipc	a0,0x3
    31b2:	ff250513          	addi	a0,a0,-14 # 61a0 <malloc+0x147a>
    31b6:	00002097          	auipc	ra,0x2
    31ba:	ab2080e7          	jalr	-1358(ra) # 4c68 <printf>
    exit(1);
    31be:	4505                	li	a0,1
    31c0:	00001097          	auipc	ra,0x1
    31c4:	6f8080e7          	jalr	1784(ra) # 48b8 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    31c8:	85ca                	mv	a1,s2
    31ca:	00003517          	auipc	a0,0x3
    31ce:	ff650513          	addi	a0,a0,-10 # 61c0 <malloc+0x149a>
    31d2:	00002097          	auipc	ra,0x2
    31d6:	a96080e7          	jalr	-1386(ra) # 4c68 <printf>
    exit(1);
    31da:	4505                	li	a0,1
    31dc:	00001097          	auipc	ra,0x1
    31e0:	6dc080e7          	jalr	1756(ra) # 48b8 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    31e4:	85ca                	mv	a1,s2
    31e6:	00003517          	auipc	a0,0x3
    31ea:	01250513          	addi	a0,a0,18 # 61f8 <malloc+0x14d2>
    31ee:	00002097          	auipc	ra,0x2
    31f2:	a7a080e7          	jalr	-1414(ra) # 4c68 <printf>
    exit(1);
    31f6:	4505                	li	a0,1
    31f8:	00001097          	auipc	ra,0x1
    31fc:	6c0080e7          	jalr	1728(ra) # 48b8 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    3200:	85ca                	mv	a1,s2
    3202:	00003517          	auipc	a0,0x3
    3206:	02650513          	addi	a0,a0,38 # 6228 <malloc+0x1502>
    320a:	00002097          	auipc	ra,0x2
    320e:	a5e080e7          	jalr	-1442(ra) # 4c68 <printf>
    exit(1);
    3212:	4505                	li	a0,1
    3214:	00001097          	auipc	ra,0x1
    3218:	6a4080e7          	jalr	1700(ra) # 48b8 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    321c:	85ca                	mv	a1,s2
    321e:	00003517          	auipc	a0,0x3
    3222:	04250513          	addi	a0,a0,66 # 6260 <malloc+0x153a>
    3226:	00002097          	auipc	ra,0x2
    322a:	a42080e7          	jalr	-1470(ra) # 4c68 <printf>
    exit(1);
    322e:	4505                	li	a0,1
    3230:	00001097          	auipc	ra,0x1
    3234:	688080e7          	jalr	1672(ra) # 48b8 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    3238:	85ca                	mv	a1,s2
    323a:	00003517          	auipc	a0,0x3
    323e:	04650513          	addi	a0,a0,70 # 6280 <malloc+0x155a>
    3242:	00002097          	auipc	ra,0x2
    3246:	a26080e7          	jalr	-1498(ra) # 4c68 <printf>
    exit(1);
    324a:	4505                	li	a0,1
    324c:	00001097          	auipc	ra,0x1
    3250:	66c080e7          	jalr	1644(ra) # 48b8 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    3254:	85ca                	mv	a1,s2
    3256:	00003517          	auipc	a0,0x3
    325a:	05a50513          	addi	a0,a0,90 # 62b0 <malloc+0x158a>
    325e:	00002097          	auipc	ra,0x2
    3262:	a0a080e7          	jalr	-1526(ra) # 4c68 <printf>
    exit(1);
    3266:	4505                	li	a0,1
    3268:	00001097          	auipc	ra,0x1
    326c:	650080e7          	jalr	1616(ra) # 48b8 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3270:	85ca                	mv	a1,s2
    3272:	00003517          	auipc	a0,0x3
    3276:	06650513          	addi	a0,a0,102 # 62d8 <malloc+0x15b2>
    327a:	00002097          	auipc	ra,0x2
    327e:	9ee080e7          	jalr	-1554(ra) # 4c68 <printf>
    exit(1);
    3282:	4505                	li	a0,1
    3284:	00001097          	auipc	ra,0x1
    3288:	634080e7          	jalr	1588(ra) # 48b8 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    328c:	85ca                	mv	a1,s2
    328e:	00003517          	auipc	a0,0x3
    3292:	06a50513          	addi	a0,a0,106 # 62f8 <malloc+0x15d2>
    3296:	00002097          	auipc	ra,0x2
    329a:	9d2080e7          	jalr	-1582(ra) # 4c68 <printf>
    exit(1);
    329e:	4505                	li	a0,1
    32a0:	00001097          	auipc	ra,0x1
    32a4:	618080e7          	jalr	1560(ra) # 48b8 <exit>
    printf("%s: chdir dd failed\n", s);
    32a8:	85ca                	mv	a1,s2
    32aa:	00003517          	auipc	a0,0x3
    32ae:	07650513          	addi	a0,a0,118 # 6320 <malloc+0x15fa>
    32b2:	00002097          	auipc	ra,0x2
    32b6:	9b6080e7          	jalr	-1610(ra) # 4c68 <printf>
    exit(1);
    32ba:	4505                	li	a0,1
    32bc:	00001097          	auipc	ra,0x1
    32c0:	5fc080e7          	jalr	1532(ra) # 48b8 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    32c4:	85ca                	mv	a1,s2
    32c6:	00003517          	auipc	a0,0x3
    32ca:	08250513          	addi	a0,a0,130 # 6348 <malloc+0x1622>
    32ce:	00002097          	auipc	ra,0x2
    32d2:	99a080e7          	jalr	-1638(ra) # 4c68 <printf>
    exit(1);
    32d6:	4505                	li	a0,1
    32d8:	00001097          	auipc	ra,0x1
    32dc:	5e0080e7          	jalr	1504(ra) # 48b8 <exit>
    printf("chdir dd/../../dd failed\n", s);
    32e0:	85ca                	mv	a1,s2
    32e2:	00003517          	auipc	a0,0x3
    32e6:	09650513          	addi	a0,a0,150 # 6378 <malloc+0x1652>
    32ea:	00002097          	auipc	ra,0x2
    32ee:	97e080e7          	jalr	-1666(ra) # 4c68 <printf>
    exit(1);
    32f2:	4505                	li	a0,1
    32f4:	00001097          	auipc	ra,0x1
    32f8:	5c4080e7          	jalr	1476(ra) # 48b8 <exit>
    printf("%s: chdir ./.. failed\n", s);
    32fc:	85ca                	mv	a1,s2
    32fe:	00003517          	auipc	a0,0x3
    3302:	0a250513          	addi	a0,a0,162 # 63a0 <malloc+0x167a>
    3306:	00002097          	auipc	ra,0x2
    330a:	962080e7          	jalr	-1694(ra) # 4c68 <printf>
    exit(1);
    330e:	4505                	li	a0,1
    3310:	00001097          	auipc	ra,0x1
    3314:	5a8080e7          	jalr	1448(ra) # 48b8 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    3318:	85ca                	mv	a1,s2
    331a:	00003517          	auipc	a0,0x3
    331e:	09e50513          	addi	a0,a0,158 # 63b8 <malloc+0x1692>
    3322:	00002097          	auipc	ra,0x2
    3326:	946080e7          	jalr	-1722(ra) # 4c68 <printf>
    exit(1);
    332a:	4505                	li	a0,1
    332c:	00001097          	auipc	ra,0x1
    3330:	58c080e7          	jalr	1420(ra) # 48b8 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    3334:	85ca                	mv	a1,s2
    3336:	00003517          	auipc	a0,0x3
    333a:	0a250513          	addi	a0,a0,162 # 63d8 <malloc+0x16b2>
    333e:	00002097          	auipc	ra,0x2
    3342:	92a080e7          	jalr	-1750(ra) # 4c68 <printf>
    exit(1);
    3346:	4505                	li	a0,1
    3348:	00001097          	auipc	ra,0x1
    334c:	570080e7          	jalr	1392(ra) # 48b8 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    3350:	85ca                	mv	a1,s2
    3352:	00003517          	auipc	a0,0x3
    3356:	0a650513          	addi	a0,a0,166 # 63f8 <malloc+0x16d2>
    335a:	00002097          	auipc	ra,0x2
    335e:	90e080e7          	jalr	-1778(ra) # 4c68 <printf>
    exit(1);
    3362:	4505                	li	a0,1
    3364:	00001097          	auipc	ra,0x1
    3368:	554080e7          	jalr	1364(ra) # 48b8 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    336c:	85ca                	mv	a1,s2
    336e:	00003517          	auipc	a0,0x3
    3372:	0ca50513          	addi	a0,a0,202 # 6438 <malloc+0x1712>
    3376:	00002097          	auipc	ra,0x2
    337a:	8f2080e7          	jalr	-1806(ra) # 4c68 <printf>
    exit(1);
    337e:	4505                	li	a0,1
    3380:	00001097          	auipc	ra,0x1
    3384:	538080e7          	jalr	1336(ra) # 48b8 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    3388:	85ca                	mv	a1,s2
    338a:	00003517          	auipc	a0,0x3
    338e:	0de50513          	addi	a0,a0,222 # 6468 <malloc+0x1742>
    3392:	00002097          	auipc	ra,0x2
    3396:	8d6080e7          	jalr	-1834(ra) # 4c68 <printf>
    exit(1);
    339a:	4505                	li	a0,1
    339c:	00001097          	auipc	ra,0x1
    33a0:	51c080e7          	jalr	1308(ra) # 48b8 <exit>
    printf("%s: create dd succeeded!\n", s);
    33a4:	85ca                	mv	a1,s2
    33a6:	00003517          	auipc	a0,0x3
    33aa:	0e250513          	addi	a0,a0,226 # 6488 <malloc+0x1762>
    33ae:	00002097          	auipc	ra,0x2
    33b2:	8ba080e7          	jalr	-1862(ra) # 4c68 <printf>
    exit(1);
    33b6:	4505                	li	a0,1
    33b8:	00001097          	auipc	ra,0x1
    33bc:	500080e7          	jalr	1280(ra) # 48b8 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    33c0:	85ca                	mv	a1,s2
    33c2:	00003517          	auipc	a0,0x3
    33c6:	0e650513          	addi	a0,a0,230 # 64a8 <malloc+0x1782>
    33ca:	00002097          	auipc	ra,0x2
    33ce:	89e080e7          	jalr	-1890(ra) # 4c68 <printf>
    exit(1);
    33d2:	4505                	li	a0,1
    33d4:	00001097          	auipc	ra,0x1
    33d8:	4e4080e7          	jalr	1252(ra) # 48b8 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    33dc:	85ca                	mv	a1,s2
    33de:	00003517          	auipc	a0,0x3
    33e2:	0ea50513          	addi	a0,a0,234 # 64c8 <malloc+0x17a2>
    33e6:	00002097          	auipc	ra,0x2
    33ea:	882080e7          	jalr	-1918(ra) # 4c68 <printf>
    exit(1);
    33ee:	4505                	li	a0,1
    33f0:	00001097          	auipc	ra,0x1
    33f4:	4c8080e7          	jalr	1224(ra) # 48b8 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    33f8:	85ca                	mv	a1,s2
    33fa:	00003517          	auipc	a0,0x3
    33fe:	0fe50513          	addi	a0,a0,254 # 64f8 <malloc+0x17d2>
    3402:	00002097          	auipc	ra,0x2
    3406:	866080e7          	jalr	-1946(ra) # 4c68 <printf>
    exit(1);
    340a:	4505                	li	a0,1
    340c:	00001097          	auipc	ra,0x1
    3410:	4ac080e7          	jalr	1196(ra) # 48b8 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3414:	85ca                	mv	a1,s2
    3416:	00003517          	auipc	a0,0x3
    341a:	10a50513          	addi	a0,a0,266 # 6520 <malloc+0x17fa>
    341e:	00002097          	auipc	ra,0x2
    3422:	84a080e7          	jalr	-1974(ra) # 4c68 <printf>
    exit(1);
    3426:	4505                	li	a0,1
    3428:	00001097          	auipc	ra,0x1
    342c:	490080e7          	jalr	1168(ra) # 48b8 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    3430:	85ca                	mv	a1,s2
    3432:	00003517          	auipc	a0,0x3
    3436:	11650513          	addi	a0,a0,278 # 6548 <malloc+0x1822>
    343a:	00002097          	auipc	ra,0x2
    343e:	82e080e7          	jalr	-2002(ra) # 4c68 <printf>
    exit(1);
    3442:	4505                	li	a0,1
    3444:	00001097          	auipc	ra,0x1
    3448:	474080e7          	jalr	1140(ra) # 48b8 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    344c:	85ca                	mv	a1,s2
    344e:	00003517          	auipc	a0,0x3
    3452:	12250513          	addi	a0,a0,290 # 6570 <malloc+0x184a>
    3456:	00002097          	auipc	ra,0x2
    345a:	812080e7          	jalr	-2030(ra) # 4c68 <printf>
    exit(1);
    345e:	4505                	li	a0,1
    3460:	00001097          	auipc	ra,0x1
    3464:	458080e7          	jalr	1112(ra) # 48b8 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    3468:	85ca                	mv	a1,s2
    346a:	00003517          	auipc	a0,0x3
    346e:	12650513          	addi	a0,a0,294 # 6590 <malloc+0x186a>
    3472:	00001097          	auipc	ra,0x1
    3476:	7f6080e7          	jalr	2038(ra) # 4c68 <printf>
    exit(1);
    347a:	4505                	li	a0,1
    347c:	00001097          	auipc	ra,0x1
    3480:	43c080e7          	jalr	1084(ra) # 48b8 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    3484:	85ca                	mv	a1,s2
    3486:	00003517          	auipc	a0,0x3
    348a:	12a50513          	addi	a0,a0,298 # 65b0 <malloc+0x188a>
    348e:	00001097          	auipc	ra,0x1
    3492:	7da080e7          	jalr	2010(ra) # 4c68 <printf>
    exit(1);
    3496:	4505                	li	a0,1
    3498:	00001097          	auipc	ra,0x1
    349c:	420080e7          	jalr	1056(ra) # 48b8 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    34a0:	85ca                	mv	a1,s2
    34a2:	00003517          	auipc	a0,0x3
    34a6:	13650513          	addi	a0,a0,310 # 65d8 <malloc+0x18b2>
    34aa:	00001097          	auipc	ra,0x1
    34ae:	7be080e7          	jalr	1982(ra) # 4c68 <printf>
    exit(1);
    34b2:	4505                	li	a0,1
    34b4:	00001097          	auipc	ra,0x1
    34b8:	404080e7          	jalr	1028(ra) # 48b8 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    34bc:	85ca                	mv	a1,s2
    34be:	00003517          	auipc	a0,0x3
    34c2:	13a50513          	addi	a0,a0,314 # 65f8 <malloc+0x18d2>
    34c6:	00001097          	auipc	ra,0x1
    34ca:	7a2080e7          	jalr	1954(ra) # 4c68 <printf>
    exit(1);
    34ce:	4505                	li	a0,1
    34d0:	00001097          	auipc	ra,0x1
    34d4:	3e8080e7          	jalr	1000(ra) # 48b8 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    34d8:	85ca                	mv	a1,s2
    34da:	00003517          	auipc	a0,0x3
    34de:	13e50513          	addi	a0,a0,318 # 6618 <malloc+0x18f2>
    34e2:	00001097          	auipc	ra,0x1
    34e6:	786080e7          	jalr	1926(ra) # 4c68 <printf>
    exit(1);
    34ea:	4505                	li	a0,1
    34ec:	00001097          	auipc	ra,0x1
    34f0:	3cc080e7          	jalr	972(ra) # 48b8 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    34f4:	85ca                	mv	a1,s2
    34f6:	00003517          	auipc	a0,0x3
    34fa:	14a50513          	addi	a0,a0,330 # 6640 <malloc+0x191a>
    34fe:	00001097          	auipc	ra,0x1
    3502:	76a080e7          	jalr	1898(ra) # 4c68 <printf>
    exit(1);
    3506:	4505                	li	a0,1
    3508:	00001097          	auipc	ra,0x1
    350c:	3b0080e7          	jalr	944(ra) # 48b8 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3510:	85ca                	mv	a1,s2
    3512:	00003517          	auipc	a0,0x3
    3516:	dc650513          	addi	a0,a0,-570 # 62d8 <malloc+0x15b2>
    351a:	00001097          	auipc	ra,0x1
    351e:	74e080e7          	jalr	1870(ra) # 4c68 <printf>
    exit(1);
    3522:	4505                	li	a0,1
    3524:	00001097          	auipc	ra,0x1
    3528:	394080e7          	jalr	916(ra) # 48b8 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    352c:	85ca                	mv	a1,s2
    352e:	00003517          	auipc	a0,0x3
    3532:	13250513          	addi	a0,a0,306 # 6660 <malloc+0x193a>
    3536:	00001097          	auipc	ra,0x1
    353a:	732080e7          	jalr	1842(ra) # 4c68 <printf>
    exit(1);
    353e:	4505                	li	a0,1
    3540:	00001097          	auipc	ra,0x1
    3544:	378080e7          	jalr	888(ra) # 48b8 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    3548:	85ca                	mv	a1,s2
    354a:	00003517          	auipc	a0,0x3
    354e:	13650513          	addi	a0,a0,310 # 6680 <malloc+0x195a>
    3552:	00001097          	auipc	ra,0x1
    3556:	716080e7          	jalr	1814(ra) # 4c68 <printf>
    exit(1);
    355a:	4505                	li	a0,1
    355c:	00001097          	auipc	ra,0x1
    3560:	35c080e7          	jalr	860(ra) # 48b8 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    3564:	85ca                	mv	a1,s2
    3566:	00003517          	auipc	a0,0x3
    356a:	14a50513          	addi	a0,a0,330 # 66b0 <malloc+0x198a>
    356e:	00001097          	auipc	ra,0x1
    3572:	6fa080e7          	jalr	1786(ra) # 4c68 <printf>
    exit(1);
    3576:	4505                	li	a0,1
    3578:	00001097          	auipc	ra,0x1
    357c:	340080e7          	jalr	832(ra) # 48b8 <exit>
    printf("%s: unlink dd failed\n", s);
    3580:	85ca                	mv	a1,s2
    3582:	00003517          	auipc	a0,0x3
    3586:	14e50513          	addi	a0,a0,334 # 66d0 <malloc+0x19aa>
    358a:	00001097          	auipc	ra,0x1
    358e:	6de080e7          	jalr	1758(ra) # 4c68 <printf>
    exit(1);
    3592:	4505                	li	a0,1
    3594:	00001097          	auipc	ra,0x1
    3598:	324080e7          	jalr	804(ra) # 48b8 <exit>

000000000000359c <dirfile>:
{
    359c:	1101                	addi	sp,sp,-32
    359e:	ec06                	sd	ra,24(sp)
    35a0:	e822                	sd	s0,16(sp)
    35a2:	e426                	sd	s1,8(sp)
    35a4:	e04a                	sd	s2,0(sp)
    35a6:	1000                	addi	s0,sp,32
    35a8:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    35aa:	20000593          	li	a1,512
    35ae:	00002517          	auipc	a0,0x2
    35b2:	ada50513          	addi	a0,a0,-1318 # 5088 <malloc+0x362>
    35b6:	00001097          	auipc	ra,0x1
    35ba:	342080e7          	jalr	834(ra) # 48f8 <open>
  if(fd < 0){
    35be:	0e054d63          	bltz	a0,36b8 <dirfile+0x11c>
  close(fd);
    35c2:	00001097          	auipc	ra,0x1
    35c6:	31e080e7          	jalr	798(ra) # 48e0 <close>
  if(chdir("dirfile") == 0){
    35ca:	00002517          	auipc	a0,0x2
    35ce:	abe50513          	addi	a0,a0,-1346 # 5088 <malloc+0x362>
    35d2:	00001097          	auipc	ra,0x1
    35d6:	356080e7          	jalr	854(ra) # 4928 <chdir>
    35da:	cd6d                	beqz	a0,36d4 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    35dc:	4581                	li	a1,0
    35de:	00003517          	auipc	a0,0x3
    35e2:	14a50513          	addi	a0,a0,330 # 6728 <malloc+0x1a02>
    35e6:	00001097          	auipc	ra,0x1
    35ea:	312080e7          	jalr	786(ra) # 48f8 <open>
  if(fd >= 0){
    35ee:	10055163          	bgez	a0,36f0 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    35f2:	20000593          	li	a1,512
    35f6:	00003517          	auipc	a0,0x3
    35fa:	13250513          	addi	a0,a0,306 # 6728 <malloc+0x1a02>
    35fe:	00001097          	auipc	ra,0x1
    3602:	2fa080e7          	jalr	762(ra) # 48f8 <open>
  if(fd >= 0){
    3606:	10055363          	bgez	a0,370c <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    360a:	00003517          	auipc	a0,0x3
    360e:	11e50513          	addi	a0,a0,286 # 6728 <malloc+0x1a02>
    3612:	00001097          	auipc	ra,0x1
    3616:	30e080e7          	jalr	782(ra) # 4920 <mkdir>
    361a:	10050763          	beqz	a0,3728 <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    361e:	00003517          	auipc	a0,0x3
    3622:	10a50513          	addi	a0,a0,266 # 6728 <malloc+0x1a02>
    3626:	00001097          	auipc	ra,0x1
    362a:	2e2080e7          	jalr	738(ra) # 4908 <unlink>
    362e:	10050b63          	beqz	a0,3744 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    3632:	00003597          	auipc	a1,0x3
    3636:	0f658593          	addi	a1,a1,246 # 6728 <malloc+0x1a02>
    363a:	00003517          	auipc	a0,0x3
    363e:	17650513          	addi	a0,a0,374 # 67b0 <malloc+0x1a8a>
    3642:	00001097          	auipc	ra,0x1
    3646:	2d6080e7          	jalr	726(ra) # 4918 <link>
    364a:	10050b63          	beqz	a0,3760 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    364e:	00002517          	auipc	a0,0x2
    3652:	a3a50513          	addi	a0,a0,-1478 # 5088 <malloc+0x362>
    3656:	00001097          	auipc	ra,0x1
    365a:	2b2080e7          	jalr	690(ra) # 4908 <unlink>
    365e:	10051f63          	bnez	a0,377c <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    3662:	4589                	li	a1,2
    3664:	00002517          	auipc	a0,0x2
    3668:	3b450513          	addi	a0,a0,948 # 5a18 <malloc+0xcf2>
    366c:	00001097          	auipc	ra,0x1
    3670:	28c080e7          	jalr	652(ra) # 48f8 <open>
  if(fd >= 0){
    3674:	12055263          	bgez	a0,3798 <dirfile+0x1fc>
  fd = open(".", 0);
    3678:	4581                	li	a1,0
    367a:	00002517          	auipc	a0,0x2
    367e:	39e50513          	addi	a0,a0,926 # 5a18 <malloc+0xcf2>
    3682:	00001097          	auipc	ra,0x1
    3686:	276080e7          	jalr	630(ra) # 48f8 <open>
    368a:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    368c:	4605                	li	a2,1
    368e:	00002597          	auipc	a1,0x2
    3692:	ae258593          	addi	a1,a1,-1310 # 5170 <malloc+0x44a>
    3696:	00001097          	auipc	ra,0x1
    369a:	242080e7          	jalr	578(ra) # 48d8 <write>
    369e:	10a04b63          	bgtz	a0,37b4 <dirfile+0x218>
  close(fd);
    36a2:	8526                	mv	a0,s1
    36a4:	00001097          	auipc	ra,0x1
    36a8:	23c080e7          	jalr	572(ra) # 48e0 <close>
}
    36ac:	60e2                	ld	ra,24(sp)
    36ae:	6442                	ld	s0,16(sp)
    36b0:	64a2                	ld	s1,8(sp)
    36b2:	6902                	ld	s2,0(sp)
    36b4:	6105                	addi	sp,sp,32
    36b6:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    36b8:	85ca                	mv	a1,s2
    36ba:	00003517          	auipc	a0,0x3
    36be:	02e50513          	addi	a0,a0,46 # 66e8 <malloc+0x19c2>
    36c2:	00001097          	auipc	ra,0x1
    36c6:	5a6080e7          	jalr	1446(ra) # 4c68 <printf>
    exit(1);
    36ca:	4505                	li	a0,1
    36cc:	00001097          	auipc	ra,0x1
    36d0:	1ec080e7          	jalr	492(ra) # 48b8 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    36d4:	85ca                	mv	a1,s2
    36d6:	00003517          	auipc	a0,0x3
    36da:	03250513          	addi	a0,a0,50 # 6708 <malloc+0x19e2>
    36de:	00001097          	auipc	ra,0x1
    36e2:	58a080e7          	jalr	1418(ra) # 4c68 <printf>
    exit(1);
    36e6:	4505                	li	a0,1
    36e8:	00001097          	auipc	ra,0x1
    36ec:	1d0080e7          	jalr	464(ra) # 48b8 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    36f0:	85ca                	mv	a1,s2
    36f2:	00003517          	auipc	a0,0x3
    36f6:	04650513          	addi	a0,a0,70 # 6738 <malloc+0x1a12>
    36fa:	00001097          	auipc	ra,0x1
    36fe:	56e080e7          	jalr	1390(ra) # 4c68 <printf>
    exit(1);
    3702:	4505                	li	a0,1
    3704:	00001097          	auipc	ra,0x1
    3708:	1b4080e7          	jalr	436(ra) # 48b8 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    370c:	85ca                	mv	a1,s2
    370e:	00003517          	auipc	a0,0x3
    3712:	02a50513          	addi	a0,a0,42 # 6738 <malloc+0x1a12>
    3716:	00001097          	auipc	ra,0x1
    371a:	552080e7          	jalr	1362(ra) # 4c68 <printf>
    exit(1);
    371e:	4505                	li	a0,1
    3720:	00001097          	auipc	ra,0x1
    3724:	198080e7          	jalr	408(ra) # 48b8 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    3728:	85ca                	mv	a1,s2
    372a:	00003517          	auipc	a0,0x3
    372e:	03650513          	addi	a0,a0,54 # 6760 <malloc+0x1a3a>
    3732:	00001097          	auipc	ra,0x1
    3736:	536080e7          	jalr	1334(ra) # 4c68 <printf>
    exit(1);
    373a:	4505                	li	a0,1
    373c:	00001097          	auipc	ra,0x1
    3740:	17c080e7          	jalr	380(ra) # 48b8 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    3744:	85ca                	mv	a1,s2
    3746:	00003517          	auipc	a0,0x3
    374a:	04250513          	addi	a0,a0,66 # 6788 <malloc+0x1a62>
    374e:	00001097          	auipc	ra,0x1
    3752:	51a080e7          	jalr	1306(ra) # 4c68 <printf>
    exit(1);
    3756:	4505                	li	a0,1
    3758:	00001097          	auipc	ra,0x1
    375c:	160080e7          	jalr	352(ra) # 48b8 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    3760:	85ca                	mv	a1,s2
    3762:	00003517          	auipc	a0,0x3
    3766:	05650513          	addi	a0,a0,86 # 67b8 <malloc+0x1a92>
    376a:	00001097          	auipc	ra,0x1
    376e:	4fe080e7          	jalr	1278(ra) # 4c68 <printf>
    exit(1);
    3772:	4505                	li	a0,1
    3774:	00001097          	auipc	ra,0x1
    3778:	144080e7          	jalr	324(ra) # 48b8 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    377c:	85ca                	mv	a1,s2
    377e:	00003517          	auipc	a0,0x3
    3782:	06250513          	addi	a0,a0,98 # 67e0 <malloc+0x1aba>
    3786:	00001097          	auipc	ra,0x1
    378a:	4e2080e7          	jalr	1250(ra) # 4c68 <printf>
    exit(1);
    378e:	4505                	li	a0,1
    3790:	00001097          	auipc	ra,0x1
    3794:	128080e7          	jalr	296(ra) # 48b8 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    3798:	85ca                	mv	a1,s2
    379a:	00003517          	auipc	a0,0x3
    379e:	06650513          	addi	a0,a0,102 # 6800 <malloc+0x1ada>
    37a2:	00001097          	auipc	ra,0x1
    37a6:	4c6080e7          	jalr	1222(ra) # 4c68 <printf>
    exit(1);
    37aa:	4505                	li	a0,1
    37ac:	00001097          	auipc	ra,0x1
    37b0:	10c080e7          	jalr	268(ra) # 48b8 <exit>
    printf("%s: write . succeeded!\n", s);
    37b4:	85ca                	mv	a1,s2
    37b6:	00003517          	auipc	a0,0x3
    37ba:	07250513          	addi	a0,a0,114 # 6828 <malloc+0x1b02>
    37be:	00001097          	auipc	ra,0x1
    37c2:	4aa080e7          	jalr	1194(ra) # 4c68 <printf>
    exit(1);
    37c6:	4505                	li	a0,1
    37c8:	00001097          	auipc	ra,0x1
    37cc:	0f0080e7          	jalr	240(ra) # 48b8 <exit>

00000000000037d0 <iref>:
{
    37d0:	7139                	addi	sp,sp,-64
    37d2:	fc06                	sd	ra,56(sp)
    37d4:	f822                	sd	s0,48(sp)
    37d6:	f426                	sd	s1,40(sp)
    37d8:	f04a                	sd	s2,32(sp)
    37da:	ec4e                	sd	s3,24(sp)
    37dc:	e852                	sd	s4,16(sp)
    37de:	e456                	sd	s5,8(sp)
    37e0:	e05a                	sd	s6,0(sp)
    37e2:	0080                	addi	s0,sp,64
    37e4:	8b2a                	mv	s6,a0
    37e6:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    37ea:	00003a17          	auipc	s4,0x3
    37ee:	056a0a13          	addi	s4,s4,86 # 6840 <malloc+0x1b1a>
    mkdir("");
    37f2:	00003497          	auipc	s1,0x3
    37f6:	c2e48493          	addi	s1,s1,-978 # 6420 <malloc+0x16fa>
    link("README", "");
    37fa:	00003a97          	auipc	s5,0x3
    37fe:	fb6a8a93          	addi	s5,s5,-74 # 67b0 <malloc+0x1a8a>
    fd = open("xx", O_CREATE);
    3802:	00003997          	auipc	s3,0x3
    3806:	f2e98993          	addi	s3,s3,-210 # 6730 <malloc+0x1a0a>
    380a:	a891                	j	385e <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    380c:	85da                	mv	a1,s6
    380e:	00003517          	auipc	a0,0x3
    3812:	03a50513          	addi	a0,a0,58 # 6848 <malloc+0x1b22>
    3816:	00001097          	auipc	ra,0x1
    381a:	452080e7          	jalr	1106(ra) # 4c68 <printf>
      exit(1);
    381e:	4505                	li	a0,1
    3820:	00001097          	auipc	ra,0x1
    3824:	098080e7          	jalr	152(ra) # 48b8 <exit>
      printf("%s: chdir irefd failed\n", s);
    3828:	85da                	mv	a1,s6
    382a:	00003517          	auipc	a0,0x3
    382e:	03650513          	addi	a0,a0,54 # 6860 <malloc+0x1b3a>
    3832:	00001097          	auipc	ra,0x1
    3836:	436080e7          	jalr	1078(ra) # 4c68 <printf>
      exit(1);
    383a:	4505                	li	a0,1
    383c:	00001097          	auipc	ra,0x1
    3840:	07c080e7          	jalr	124(ra) # 48b8 <exit>
      close(fd);
    3844:	00001097          	auipc	ra,0x1
    3848:	09c080e7          	jalr	156(ra) # 48e0 <close>
    384c:	a889                	j	389e <iref+0xce>
    unlink("xx");
    384e:	854e                	mv	a0,s3
    3850:	00001097          	auipc	ra,0x1
    3854:	0b8080e7          	jalr	184(ra) # 4908 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3858:	397d                	addiw	s2,s2,-1
    385a:	06090063          	beqz	s2,38ba <iref+0xea>
    if(mkdir("irefd") != 0){
    385e:	8552                	mv	a0,s4
    3860:	00001097          	auipc	ra,0x1
    3864:	0c0080e7          	jalr	192(ra) # 4920 <mkdir>
    3868:	f155                	bnez	a0,380c <iref+0x3c>
    if(chdir("irefd") != 0){
    386a:	8552                	mv	a0,s4
    386c:	00001097          	auipc	ra,0x1
    3870:	0bc080e7          	jalr	188(ra) # 4928 <chdir>
    3874:	f955                	bnez	a0,3828 <iref+0x58>
    mkdir("");
    3876:	8526                	mv	a0,s1
    3878:	00001097          	auipc	ra,0x1
    387c:	0a8080e7          	jalr	168(ra) # 4920 <mkdir>
    link("README", "");
    3880:	85a6                	mv	a1,s1
    3882:	8556                	mv	a0,s5
    3884:	00001097          	auipc	ra,0x1
    3888:	094080e7          	jalr	148(ra) # 4918 <link>
    fd = open("", O_CREATE);
    388c:	20000593          	li	a1,512
    3890:	8526                	mv	a0,s1
    3892:	00001097          	auipc	ra,0x1
    3896:	066080e7          	jalr	102(ra) # 48f8 <open>
    if(fd >= 0)
    389a:	fa0555e3          	bgez	a0,3844 <iref+0x74>
    fd = open("xx", O_CREATE);
    389e:	20000593          	li	a1,512
    38a2:	854e                	mv	a0,s3
    38a4:	00001097          	auipc	ra,0x1
    38a8:	054080e7          	jalr	84(ra) # 48f8 <open>
    if(fd >= 0)
    38ac:	fa0541e3          	bltz	a0,384e <iref+0x7e>
      close(fd);
    38b0:	00001097          	auipc	ra,0x1
    38b4:	030080e7          	jalr	48(ra) # 48e0 <close>
    38b8:	bf59                	j	384e <iref+0x7e>
  chdir("/");
    38ba:	00002517          	auipc	a0,0x2
    38be:	0ee50513          	addi	a0,a0,238 # 59a8 <malloc+0xc82>
    38c2:	00001097          	auipc	ra,0x1
    38c6:	066080e7          	jalr	102(ra) # 4928 <chdir>
}
    38ca:	70e2                	ld	ra,56(sp)
    38cc:	7442                	ld	s0,48(sp)
    38ce:	74a2                	ld	s1,40(sp)
    38d0:	7902                	ld	s2,32(sp)
    38d2:	69e2                	ld	s3,24(sp)
    38d4:	6a42                	ld	s4,16(sp)
    38d6:	6aa2                	ld	s5,8(sp)
    38d8:	6b02                	ld	s6,0(sp)
    38da:	6121                	addi	sp,sp,64
    38dc:	8082                	ret

00000000000038de <validatetest>:
{
    38de:	7139                	addi	sp,sp,-64
    38e0:	fc06                	sd	ra,56(sp)
    38e2:	f822                	sd	s0,48(sp)
    38e4:	f426                	sd	s1,40(sp)
    38e6:	f04a                	sd	s2,32(sp)
    38e8:	ec4e                	sd	s3,24(sp)
    38ea:	e852                	sd	s4,16(sp)
    38ec:	e456                	sd	s5,8(sp)
    38ee:	e05a                	sd	s6,0(sp)
    38f0:	0080                	addi	s0,sp,64
    38f2:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    38f4:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    38f6:	00003997          	auipc	s3,0x3
    38fa:	f8298993          	addi	s3,s3,-126 # 6878 <malloc+0x1b52>
    38fe:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    3900:	6a85                	lui	s5,0x1
    3902:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    3906:	85a6                	mv	a1,s1
    3908:	854e                	mv	a0,s3
    390a:	00001097          	auipc	ra,0x1
    390e:	00e080e7          	jalr	14(ra) # 4918 <link>
    3912:	01251f63          	bne	a0,s2,3930 <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    3916:	94d6                	add	s1,s1,s5
    3918:	ff4497e3          	bne	s1,s4,3906 <validatetest+0x28>
}
    391c:	70e2                	ld	ra,56(sp)
    391e:	7442                	ld	s0,48(sp)
    3920:	74a2                	ld	s1,40(sp)
    3922:	7902                	ld	s2,32(sp)
    3924:	69e2                	ld	s3,24(sp)
    3926:	6a42                	ld	s4,16(sp)
    3928:	6aa2                	ld	s5,8(sp)
    392a:	6b02                	ld	s6,0(sp)
    392c:	6121                	addi	sp,sp,64
    392e:	8082                	ret
      printf("%s: link should not succeed\n", s);
    3930:	85da                	mv	a1,s6
    3932:	00003517          	auipc	a0,0x3
    3936:	f5650513          	addi	a0,a0,-170 # 6888 <malloc+0x1b62>
    393a:	00001097          	auipc	ra,0x1
    393e:	32e080e7          	jalr	814(ra) # 4c68 <printf>
      exit(1);
    3942:	4505                	li	a0,1
    3944:	00001097          	auipc	ra,0x1
    3948:	f74080e7          	jalr	-140(ra) # 48b8 <exit>

000000000000394c <sbrkmuch>:
{
    394c:	7179                	addi	sp,sp,-48
    394e:	f406                	sd	ra,40(sp)
    3950:	f022                	sd	s0,32(sp)
    3952:	ec26                	sd	s1,24(sp)
    3954:	e84a                	sd	s2,16(sp)
    3956:	e44e                	sd	s3,8(sp)
    3958:	e052                	sd	s4,0(sp)
    395a:	1800                	addi	s0,sp,48
    395c:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    395e:	4501                	li	a0,0
    3960:	00001097          	auipc	ra,0x1
    3964:	fe0080e7          	jalr	-32(ra) # 4940 <sbrk>
    3968:	892a                	mv	s2,a0
  a = sbrk(0);
    396a:	4501                	li	a0,0
    396c:	00001097          	auipc	ra,0x1
    3970:	fd4080e7          	jalr	-44(ra) # 4940 <sbrk>
    3974:	84aa                	mv	s1,a0
  p = sbrk(amt);
    3976:	06400537          	lui	a0,0x6400
    397a:	9d05                	subw	a0,a0,s1
    397c:	00001097          	auipc	ra,0x1
    3980:	fc4080e7          	jalr	-60(ra) # 4940 <sbrk>
  if (p != a) {
    3984:	0aa49963          	bne	s1,a0,3a36 <sbrkmuch+0xea>
  *lastaddr = 99;
    3988:	064007b7          	lui	a5,0x6400
    398c:	06300713          	li	a4,99
    3990:	fee78fa3          	sb	a4,-1(a5) # 63fffff <__BSS_END__+0x63f379f>
  a = sbrk(0);
    3994:	4501                	li	a0,0
    3996:	00001097          	auipc	ra,0x1
    399a:	faa080e7          	jalr	-86(ra) # 4940 <sbrk>
    399e:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    39a0:	757d                	lui	a0,0xfffff
    39a2:	00001097          	auipc	ra,0x1
    39a6:	f9e080e7          	jalr	-98(ra) # 4940 <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    39aa:	57fd                	li	a5,-1
    39ac:	0af50363          	beq	a0,a5,3a52 <sbrkmuch+0x106>
  c = sbrk(0);
    39b0:	4501                	li	a0,0
    39b2:	00001097          	auipc	ra,0x1
    39b6:	f8e080e7          	jalr	-114(ra) # 4940 <sbrk>
  if(c != a - PGSIZE){
    39ba:	77fd                	lui	a5,0xfffff
    39bc:	97a6                	add	a5,a5,s1
    39be:	0af51863          	bne	a0,a5,3a6e <sbrkmuch+0x122>
  a = sbrk(0);
    39c2:	4501                	li	a0,0
    39c4:	00001097          	auipc	ra,0x1
    39c8:	f7c080e7          	jalr	-132(ra) # 4940 <sbrk>
    39cc:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    39ce:	6505                	lui	a0,0x1
    39d0:	00001097          	auipc	ra,0x1
    39d4:	f70080e7          	jalr	-144(ra) # 4940 <sbrk>
    39d8:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    39da:	0aa49963          	bne	s1,a0,3a8c <sbrkmuch+0x140>
    39de:	4501                	li	a0,0
    39e0:	00001097          	auipc	ra,0x1
    39e4:	f60080e7          	jalr	-160(ra) # 4940 <sbrk>
    39e8:	6785                	lui	a5,0x1
    39ea:	97a6                	add	a5,a5,s1
    39ec:	0af51063          	bne	a0,a5,3a8c <sbrkmuch+0x140>
  if(*lastaddr == 99){
    39f0:	064007b7          	lui	a5,0x6400
    39f4:	fff7c703          	lbu	a4,-1(a5) # 63fffff <__BSS_END__+0x63f379f>
    39f8:	06300793          	li	a5,99
    39fc:	0af70763          	beq	a4,a5,3aaa <sbrkmuch+0x15e>
  a = sbrk(0);
    3a00:	4501                	li	a0,0
    3a02:	00001097          	auipc	ra,0x1
    3a06:	f3e080e7          	jalr	-194(ra) # 4940 <sbrk>
    3a0a:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    3a0c:	4501                	li	a0,0
    3a0e:	00001097          	auipc	ra,0x1
    3a12:	f32080e7          	jalr	-206(ra) # 4940 <sbrk>
    3a16:	40a9053b          	subw	a0,s2,a0
    3a1a:	00001097          	auipc	ra,0x1
    3a1e:	f26080e7          	jalr	-218(ra) # 4940 <sbrk>
  if(c != a){
    3a22:	0aa49263          	bne	s1,a0,3ac6 <sbrkmuch+0x17a>
}
    3a26:	70a2                	ld	ra,40(sp)
    3a28:	7402                	ld	s0,32(sp)
    3a2a:	64e2                	ld	s1,24(sp)
    3a2c:	6942                	ld	s2,16(sp)
    3a2e:	69a2                	ld	s3,8(sp)
    3a30:	6a02                	ld	s4,0(sp)
    3a32:	6145                	addi	sp,sp,48
    3a34:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    3a36:	85ce                	mv	a1,s3
    3a38:	00003517          	auipc	a0,0x3
    3a3c:	e7050513          	addi	a0,a0,-400 # 68a8 <malloc+0x1b82>
    3a40:	00001097          	auipc	ra,0x1
    3a44:	228080e7          	jalr	552(ra) # 4c68 <printf>
    exit(1);
    3a48:	4505                	li	a0,1
    3a4a:	00001097          	auipc	ra,0x1
    3a4e:	e6e080e7          	jalr	-402(ra) # 48b8 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    3a52:	85ce                	mv	a1,s3
    3a54:	00003517          	auipc	a0,0x3
    3a58:	e9c50513          	addi	a0,a0,-356 # 68f0 <malloc+0x1bca>
    3a5c:	00001097          	auipc	ra,0x1
    3a60:	20c080e7          	jalr	524(ra) # 4c68 <printf>
    exit(1);
    3a64:	4505                	li	a0,1
    3a66:	00001097          	auipc	ra,0x1
    3a6a:	e52080e7          	jalr	-430(ra) # 48b8 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    3a6e:	862a                	mv	a2,a0
    3a70:	85a6                	mv	a1,s1
    3a72:	00003517          	auipc	a0,0x3
    3a76:	e9e50513          	addi	a0,a0,-354 # 6910 <malloc+0x1bea>
    3a7a:	00001097          	auipc	ra,0x1
    3a7e:	1ee080e7          	jalr	494(ra) # 4c68 <printf>
    exit(1);
    3a82:	4505                	li	a0,1
    3a84:	00001097          	auipc	ra,0x1
    3a88:	e34080e7          	jalr	-460(ra) # 48b8 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", a, c);
    3a8c:	8652                	mv	a2,s4
    3a8e:	85a6                	mv	a1,s1
    3a90:	00003517          	auipc	a0,0x3
    3a94:	ec050513          	addi	a0,a0,-320 # 6950 <malloc+0x1c2a>
    3a98:	00001097          	auipc	ra,0x1
    3a9c:	1d0080e7          	jalr	464(ra) # 4c68 <printf>
    exit(1);
    3aa0:	4505                	li	a0,1
    3aa2:	00001097          	auipc	ra,0x1
    3aa6:	e16080e7          	jalr	-490(ra) # 48b8 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    3aaa:	85ce                	mv	a1,s3
    3aac:	00003517          	auipc	a0,0x3
    3ab0:	ed450513          	addi	a0,a0,-300 # 6980 <malloc+0x1c5a>
    3ab4:	00001097          	auipc	ra,0x1
    3ab8:	1b4080e7          	jalr	436(ra) # 4c68 <printf>
    exit(1);
    3abc:	4505                	li	a0,1
    3abe:	00001097          	auipc	ra,0x1
    3ac2:	dfa080e7          	jalr	-518(ra) # 48b8 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", a, c);
    3ac6:	862a                	mv	a2,a0
    3ac8:	85a6                	mv	a1,s1
    3aca:	00003517          	auipc	a0,0x3
    3ace:	eee50513          	addi	a0,a0,-274 # 69b8 <malloc+0x1c92>
    3ad2:	00001097          	auipc	ra,0x1
    3ad6:	196080e7          	jalr	406(ra) # 4c68 <printf>
    exit(1);
    3ada:	4505                	li	a0,1
    3adc:	00001097          	auipc	ra,0x1
    3ae0:	ddc080e7          	jalr	-548(ra) # 48b8 <exit>

0000000000003ae4 <sbrkfail>:
{
    3ae4:	7119                	addi	sp,sp,-128
    3ae6:	fc86                	sd	ra,120(sp)
    3ae8:	f8a2                	sd	s0,112(sp)
    3aea:	f4a6                	sd	s1,104(sp)
    3aec:	f0ca                	sd	s2,96(sp)
    3aee:	ecce                	sd	s3,88(sp)
    3af0:	e8d2                	sd	s4,80(sp)
    3af2:	e4d6                	sd	s5,72(sp)
    3af4:	0100                	addi	s0,sp,128
    3af6:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    3af8:	fb040513          	addi	a0,s0,-80
    3afc:	00001097          	auipc	ra,0x1
    3b00:	dcc080e7          	jalr	-564(ra) # 48c8 <pipe>
    3b04:	e901                	bnez	a0,3b14 <sbrkfail+0x30>
    3b06:	f8040493          	addi	s1,s0,-128
    3b0a:	fa840a13          	addi	s4,s0,-88
    3b0e:	89a6                	mv	s3,s1
    if(pids[i] != -1)
    3b10:	5afd                	li	s5,-1
    3b12:	a08d                	j	3b74 <sbrkfail+0x90>
    printf("%s: pipe() failed\n", s);
    3b14:	85ca                	mv	a1,s2
    3b16:	00002517          	auipc	a0,0x2
    3b1a:	1a250513          	addi	a0,a0,418 # 5cb8 <malloc+0xf92>
    3b1e:	00001097          	auipc	ra,0x1
    3b22:	14a080e7          	jalr	330(ra) # 4c68 <printf>
    exit(1);
    3b26:	4505                	li	a0,1
    3b28:	00001097          	auipc	ra,0x1
    3b2c:	d90080e7          	jalr	-624(ra) # 48b8 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    3b30:	4501                	li	a0,0
    3b32:	00001097          	auipc	ra,0x1
    3b36:	e0e080e7          	jalr	-498(ra) # 4940 <sbrk>
    3b3a:	064007b7          	lui	a5,0x6400
    3b3e:	40a7853b          	subw	a0,a5,a0
    3b42:	00001097          	auipc	ra,0x1
    3b46:	dfe080e7          	jalr	-514(ra) # 4940 <sbrk>
      write(fds[1], "x", 1);
    3b4a:	4605                	li	a2,1
    3b4c:	00001597          	auipc	a1,0x1
    3b50:	62458593          	addi	a1,a1,1572 # 5170 <malloc+0x44a>
    3b54:	fb442503          	lw	a0,-76(s0)
    3b58:	00001097          	auipc	ra,0x1
    3b5c:	d80080e7          	jalr	-640(ra) # 48d8 <write>
      for(;;) sleep(1000);
    3b60:	3e800513          	li	a0,1000
    3b64:	00001097          	auipc	ra,0x1
    3b68:	de4080e7          	jalr	-540(ra) # 4948 <sleep>
    3b6c:	bfd5                	j	3b60 <sbrkfail+0x7c>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3b6e:	0991                	addi	s3,s3,4
    3b70:	03498563          	beq	s3,s4,3b9a <sbrkfail+0xb6>
    if((pids[i] = fork()) == 0){
    3b74:	00001097          	auipc	ra,0x1
    3b78:	d3c080e7          	jalr	-708(ra) # 48b0 <fork>
    3b7c:	00a9a023          	sw	a0,0(s3)
    3b80:	d945                	beqz	a0,3b30 <sbrkfail+0x4c>
    if(pids[i] != -1)
    3b82:	ff5506e3          	beq	a0,s5,3b6e <sbrkfail+0x8a>
      read(fds[0], &scratch, 1);
    3b86:	4605                	li	a2,1
    3b88:	faf40593          	addi	a1,s0,-81
    3b8c:	fb042503          	lw	a0,-80(s0)
    3b90:	00001097          	auipc	ra,0x1
    3b94:	d40080e7          	jalr	-704(ra) # 48d0 <read>
    3b98:	bfd9                	j	3b6e <sbrkfail+0x8a>
  c = sbrk(PGSIZE);
    3b9a:	6505                	lui	a0,0x1
    3b9c:	00001097          	auipc	ra,0x1
    3ba0:	da4080e7          	jalr	-604(ra) # 4940 <sbrk>
    3ba4:	89aa                	mv	s3,a0
    if(pids[i] == -1)
    3ba6:	5afd                	li	s5,-1
    3ba8:	a021                	j	3bb0 <sbrkfail+0xcc>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3baa:	0491                	addi	s1,s1,4
    3bac:	01448f63          	beq	s1,s4,3bca <sbrkfail+0xe6>
    if(pids[i] == -1)
    3bb0:	4088                	lw	a0,0(s1)
    3bb2:	ff550ce3          	beq	a0,s5,3baa <sbrkfail+0xc6>
    kill(pids[i]);
    3bb6:	00001097          	auipc	ra,0x1
    3bba:	d32080e7          	jalr	-718(ra) # 48e8 <kill>
    wait(0);
    3bbe:	4501                	li	a0,0
    3bc0:	00001097          	auipc	ra,0x1
    3bc4:	d00080e7          	jalr	-768(ra) # 48c0 <wait>
    3bc8:	b7cd                	j	3baa <sbrkfail+0xc6>
  if(c == (char*)0xffffffffffffffffL){
    3bca:	57fd                	li	a5,-1
    3bcc:	02f98e63          	beq	s3,a5,3c08 <sbrkfail+0x124>
  pid = fork();
    3bd0:	00001097          	auipc	ra,0x1
    3bd4:	ce0080e7          	jalr	-800(ra) # 48b0 <fork>
    3bd8:	84aa                	mv	s1,a0
  if(pid < 0){
    3bda:	04054563          	bltz	a0,3c24 <sbrkfail+0x140>
  if(pid == 0){
    3bde:	c12d                	beqz	a0,3c40 <sbrkfail+0x15c>
  wait(&xstatus);
    3be0:	fbc40513          	addi	a0,s0,-68
    3be4:	00001097          	auipc	ra,0x1
    3be8:	cdc080e7          	jalr	-804(ra) # 48c0 <wait>
  if(xstatus != -1)
    3bec:	fbc42703          	lw	a4,-68(s0)
    3bf0:	57fd                	li	a5,-1
    3bf2:	08f71c63          	bne	a4,a5,3c8a <sbrkfail+0x1a6>
}
    3bf6:	70e6                	ld	ra,120(sp)
    3bf8:	7446                	ld	s0,112(sp)
    3bfa:	74a6                	ld	s1,104(sp)
    3bfc:	7906                	ld	s2,96(sp)
    3bfe:	69e6                	ld	s3,88(sp)
    3c00:	6a46                	ld	s4,80(sp)
    3c02:	6aa6                	ld	s5,72(sp)
    3c04:	6109                	addi	sp,sp,128
    3c06:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    3c08:	85ca                	mv	a1,s2
    3c0a:	00003517          	auipc	a0,0x3
    3c0e:	dd650513          	addi	a0,a0,-554 # 69e0 <malloc+0x1cba>
    3c12:	00001097          	auipc	ra,0x1
    3c16:	056080e7          	jalr	86(ra) # 4c68 <printf>
    exit(1);
    3c1a:	4505                	li	a0,1
    3c1c:	00001097          	auipc	ra,0x1
    3c20:	c9c080e7          	jalr	-868(ra) # 48b8 <exit>
    printf("%s: fork failed\n", s);
    3c24:	85ca                	mv	a1,s2
    3c26:	00002517          	auipc	a0,0x2
    3c2a:	8d250513          	addi	a0,a0,-1838 # 54f8 <malloc+0x7d2>
    3c2e:	00001097          	auipc	ra,0x1
    3c32:	03a080e7          	jalr	58(ra) # 4c68 <printf>
    exit(1);
    3c36:	4505                	li	a0,1
    3c38:	00001097          	auipc	ra,0x1
    3c3c:	c80080e7          	jalr	-896(ra) # 48b8 <exit>
    a = sbrk(0);
    3c40:	4501                	li	a0,0
    3c42:	00001097          	auipc	ra,0x1
    3c46:	cfe080e7          	jalr	-770(ra) # 4940 <sbrk>
    3c4a:	892a                	mv	s2,a0
    sbrk(10*BIG);
    3c4c:	3e800537          	lui	a0,0x3e800
    3c50:	00001097          	auipc	ra,0x1
    3c54:	cf0080e7          	jalr	-784(ra) # 4940 <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    3c58:	874a                	mv	a4,s2
    3c5a:	3e8007b7          	lui	a5,0x3e800
    3c5e:	97ca                	add	a5,a5,s2
    3c60:	6685                	lui	a3,0x1
      n += *(a+i);
    3c62:	00074603          	lbu	a2,0(a4)
    3c66:	9cb1                	addw	s1,s1,a2
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    3c68:	9736                	add	a4,a4,a3
    3c6a:	fef71ce3          	bne	a4,a5,3c62 <sbrkfail+0x17e>
    printf("%s: allocate a lot of memory succeeded %d\n", n);
    3c6e:	85a6                	mv	a1,s1
    3c70:	00003517          	auipc	a0,0x3
    3c74:	d9050513          	addi	a0,a0,-624 # 6a00 <malloc+0x1cda>
    3c78:	00001097          	auipc	ra,0x1
    3c7c:	ff0080e7          	jalr	-16(ra) # 4c68 <printf>
    exit(1);
    3c80:	4505                	li	a0,1
    3c82:	00001097          	auipc	ra,0x1
    3c86:	c36080e7          	jalr	-970(ra) # 48b8 <exit>
    exit(1);
    3c8a:	4505                	li	a0,1
    3c8c:	00001097          	auipc	ra,0x1
    3c90:	c2c080e7          	jalr	-980(ra) # 48b8 <exit>

0000000000003c94 <sbrkarg>:
{
    3c94:	7179                	addi	sp,sp,-48
    3c96:	f406                	sd	ra,40(sp)
    3c98:	f022                	sd	s0,32(sp)
    3c9a:	ec26                	sd	s1,24(sp)
    3c9c:	e84a                	sd	s2,16(sp)
    3c9e:	e44e                	sd	s3,8(sp)
    3ca0:	1800                	addi	s0,sp,48
    3ca2:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    3ca4:	6505                	lui	a0,0x1
    3ca6:	00001097          	auipc	ra,0x1
    3caa:	c9a080e7          	jalr	-870(ra) # 4940 <sbrk>
    3cae:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    3cb0:	20100593          	li	a1,513
    3cb4:	00003517          	auipc	a0,0x3
    3cb8:	d7c50513          	addi	a0,a0,-644 # 6a30 <malloc+0x1d0a>
    3cbc:	00001097          	auipc	ra,0x1
    3cc0:	c3c080e7          	jalr	-964(ra) # 48f8 <open>
    3cc4:	84aa                	mv	s1,a0
  unlink("sbrk");
    3cc6:	00003517          	auipc	a0,0x3
    3cca:	d6a50513          	addi	a0,a0,-662 # 6a30 <malloc+0x1d0a>
    3cce:	00001097          	auipc	ra,0x1
    3cd2:	c3a080e7          	jalr	-966(ra) # 4908 <unlink>
  if(fd < 0)  {
    3cd6:	0404c163          	bltz	s1,3d18 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    3cda:	6605                	lui	a2,0x1
    3cdc:	85ca                	mv	a1,s2
    3cde:	8526                	mv	a0,s1
    3ce0:	00001097          	auipc	ra,0x1
    3ce4:	bf8080e7          	jalr	-1032(ra) # 48d8 <write>
    3ce8:	04054663          	bltz	a0,3d34 <sbrkarg+0xa0>
  close(fd);
    3cec:	8526                	mv	a0,s1
    3cee:	00001097          	auipc	ra,0x1
    3cf2:	bf2080e7          	jalr	-1038(ra) # 48e0 <close>
  a = sbrk(PGSIZE);
    3cf6:	6505                	lui	a0,0x1
    3cf8:	00001097          	auipc	ra,0x1
    3cfc:	c48080e7          	jalr	-952(ra) # 4940 <sbrk>
  if(pipe((int *) a) != 0){
    3d00:	00001097          	auipc	ra,0x1
    3d04:	bc8080e7          	jalr	-1080(ra) # 48c8 <pipe>
    3d08:	e521                	bnez	a0,3d50 <sbrkarg+0xbc>
}
    3d0a:	70a2                	ld	ra,40(sp)
    3d0c:	7402                	ld	s0,32(sp)
    3d0e:	64e2                	ld	s1,24(sp)
    3d10:	6942                	ld	s2,16(sp)
    3d12:	69a2                	ld	s3,8(sp)
    3d14:	6145                	addi	sp,sp,48
    3d16:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    3d18:	85ce                	mv	a1,s3
    3d1a:	00003517          	auipc	a0,0x3
    3d1e:	d1e50513          	addi	a0,a0,-738 # 6a38 <malloc+0x1d12>
    3d22:	00001097          	auipc	ra,0x1
    3d26:	f46080e7          	jalr	-186(ra) # 4c68 <printf>
    exit(1);
    3d2a:	4505                	li	a0,1
    3d2c:	00001097          	auipc	ra,0x1
    3d30:	b8c080e7          	jalr	-1140(ra) # 48b8 <exit>
    printf("%s: write sbrk failed\n", s);
    3d34:	85ce                	mv	a1,s3
    3d36:	00003517          	auipc	a0,0x3
    3d3a:	d1a50513          	addi	a0,a0,-742 # 6a50 <malloc+0x1d2a>
    3d3e:	00001097          	auipc	ra,0x1
    3d42:	f2a080e7          	jalr	-214(ra) # 4c68 <printf>
    exit(1);
    3d46:	4505                	li	a0,1
    3d48:	00001097          	auipc	ra,0x1
    3d4c:	b70080e7          	jalr	-1168(ra) # 48b8 <exit>
    printf("%s: pipe() failed\n", s);
    3d50:	85ce                	mv	a1,s3
    3d52:	00002517          	auipc	a0,0x2
    3d56:	f6650513          	addi	a0,a0,-154 # 5cb8 <malloc+0xf92>
    3d5a:	00001097          	auipc	ra,0x1
    3d5e:	f0e080e7          	jalr	-242(ra) # 4c68 <printf>
    exit(1);
    3d62:	4505                	li	a0,1
    3d64:	00001097          	auipc	ra,0x1
    3d68:	b54080e7          	jalr	-1196(ra) # 48b8 <exit>

0000000000003d6c <argptest>:
{
    3d6c:	1101                	addi	sp,sp,-32
    3d6e:	ec06                	sd	ra,24(sp)
    3d70:	e822                	sd	s0,16(sp)
    3d72:	e426                	sd	s1,8(sp)
    3d74:	e04a                	sd	s2,0(sp)
    3d76:	1000                	addi	s0,sp,32
    3d78:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    3d7a:	4581                	li	a1,0
    3d7c:	00003517          	auipc	a0,0x3
    3d80:	cec50513          	addi	a0,a0,-788 # 6a68 <malloc+0x1d42>
    3d84:	00001097          	auipc	ra,0x1
    3d88:	b74080e7          	jalr	-1164(ra) # 48f8 <open>
  if (fd < 0) {
    3d8c:	02054b63          	bltz	a0,3dc2 <argptest+0x56>
    3d90:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    3d92:	4501                	li	a0,0
    3d94:	00001097          	auipc	ra,0x1
    3d98:	bac080e7          	jalr	-1108(ra) # 4940 <sbrk>
    3d9c:	567d                	li	a2,-1
    3d9e:	fff50593          	addi	a1,a0,-1
    3da2:	8526                	mv	a0,s1
    3da4:	00001097          	auipc	ra,0x1
    3da8:	b2c080e7          	jalr	-1236(ra) # 48d0 <read>
  close(fd);
    3dac:	8526                	mv	a0,s1
    3dae:	00001097          	auipc	ra,0x1
    3db2:	b32080e7          	jalr	-1230(ra) # 48e0 <close>
}
    3db6:	60e2                	ld	ra,24(sp)
    3db8:	6442                	ld	s0,16(sp)
    3dba:	64a2                	ld	s1,8(sp)
    3dbc:	6902                	ld	s2,0(sp)
    3dbe:	6105                	addi	sp,sp,32
    3dc0:	8082                	ret
    printf("%s: open failed\n", s);
    3dc2:	85ca                	mv	a1,s2
    3dc4:	00001517          	auipc	a0,0x1
    3dc8:	74c50513          	addi	a0,a0,1868 # 5510 <malloc+0x7ea>
    3dcc:	00001097          	auipc	ra,0x1
    3dd0:	e9c080e7          	jalr	-356(ra) # 4c68 <printf>
    exit(1);
    3dd4:	4505                	li	a0,1
    3dd6:	00001097          	auipc	ra,0x1
    3dda:	ae2080e7          	jalr	-1310(ra) # 48b8 <exit>

0000000000003dde <sbrkbugs>:
{
    3dde:	1141                	addi	sp,sp,-16
    3de0:	e406                	sd	ra,8(sp)
    3de2:	e022                	sd	s0,0(sp)
    3de4:	0800                	addi	s0,sp,16
  int pid = fork();
    3de6:	00001097          	auipc	ra,0x1
    3dea:	aca080e7          	jalr	-1334(ra) # 48b0 <fork>
  if(pid < 0){
    3dee:	02054263          	bltz	a0,3e12 <sbrkbugs+0x34>
  if(pid == 0){
    3df2:	ed0d                	bnez	a0,3e2c <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    3df4:	00001097          	auipc	ra,0x1
    3df8:	b4c080e7          	jalr	-1204(ra) # 4940 <sbrk>
    sbrk(-sz);
    3dfc:	40a0053b          	negw	a0,a0
    3e00:	00001097          	auipc	ra,0x1
    3e04:	b40080e7          	jalr	-1216(ra) # 4940 <sbrk>
    exit(0);
    3e08:	4501                	li	a0,0
    3e0a:	00001097          	auipc	ra,0x1
    3e0e:	aae080e7          	jalr	-1362(ra) # 48b8 <exit>
    printf("fork failed\n");
    3e12:	00002517          	auipc	a0,0x2
    3e16:	e7650513          	addi	a0,a0,-394 # 5c88 <malloc+0xf62>
    3e1a:	00001097          	auipc	ra,0x1
    3e1e:	e4e080e7          	jalr	-434(ra) # 4c68 <printf>
    exit(1);
    3e22:	4505                	li	a0,1
    3e24:	00001097          	auipc	ra,0x1
    3e28:	a94080e7          	jalr	-1388(ra) # 48b8 <exit>
  wait(0);
    3e2c:	4501                	li	a0,0
    3e2e:	00001097          	auipc	ra,0x1
    3e32:	a92080e7          	jalr	-1390(ra) # 48c0 <wait>
  pid = fork();
    3e36:	00001097          	auipc	ra,0x1
    3e3a:	a7a080e7          	jalr	-1414(ra) # 48b0 <fork>
  if(pid < 0){
    3e3e:	02054563          	bltz	a0,3e68 <sbrkbugs+0x8a>
  if(pid == 0){
    3e42:	e121                	bnez	a0,3e82 <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    3e44:	00001097          	auipc	ra,0x1
    3e48:	afc080e7          	jalr	-1284(ra) # 4940 <sbrk>
    sbrk(-(sz - 3500));
    3e4c:	6785                	lui	a5,0x1
    3e4e:	dac7879b          	addiw	a5,a5,-596
    3e52:	40a7853b          	subw	a0,a5,a0
    3e56:	00001097          	auipc	ra,0x1
    3e5a:	aea080e7          	jalr	-1302(ra) # 4940 <sbrk>
    exit(0);
    3e5e:	4501                	li	a0,0
    3e60:	00001097          	auipc	ra,0x1
    3e64:	a58080e7          	jalr	-1448(ra) # 48b8 <exit>
    printf("fork failed\n");
    3e68:	00002517          	auipc	a0,0x2
    3e6c:	e2050513          	addi	a0,a0,-480 # 5c88 <malloc+0xf62>
    3e70:	00001097          	auipc	ra,0x1
    3e74:	df8080e7          	jalr	-520(ra) # 4c68 <printf>
    exit(1);
    3e78:	4505                	li	a0,1
    3e7a:	00001097          	auipc	ra,0x1
    3e7e:	a3e080e7          	jalr	-1474(ra) # 48b8 <exit>
  wait(0);
    3e82:	4501                	li	a0,0
    3e84:	00001097          	auipc	ra,0x1
    3e88:	a3c080e7          	jalr	-1476(ra) # 48c0 <wait>
  pid = fork();
    3e8c:	00001097          	auipc	ra,0x1
    3e90:	a24080e7          	jalr	-1500(ra) # 48b0 <fork>
  if(pid < 0){
    3e94:	02054a63          	bltz	a0,3ec8 <sbrkbugs+0xea>
  if(pid == 0){
    3e98:	e529                	bnez	a0,3ee2 <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    3e9a:	00001097          	auipc	ra,0x1
    3e9e:	aa6080e7          	jalr	-1370(ra) # 4940 <sbrk>
    3ea2:	67ad                	lui	a5,0xb
    3ea4:	8007879b          	addiw	a5,a5,-2048
    3ea8:	40a7853b          	subw	a0,a5,a0
    3eac:	00001097          	auipc	ra,0x1
    3eb0:	a94080e7          	jalr	-1388(ra) # 4940 <sbrk>
    sbrk(-10);
    3eb4:	5559                	li	a0,-10
    3eb6:	00001097          	auipc	ra,0x1
    3eba:	a8a080e7          	jalr	-1398(ra) # 4940 <sbrk>
    exit(0);
    3ebe:	4501                	li	a0,0
    3ec0:	00001097          	auipc	ra,0x1
    3ec4:	9f8080e7          	jalr	-1544(ra) # 48b8 <exit>
    printf("fork failed\n");
    3ec8:	00002517          	auipc	a0,0x2
    3ecc:	dc050513          	addi	a0,a0,-576 # 5c88 <malloc+0xf62>
    3ed0:	00001097          	auipc	ra,0x1
    3ed4:	d98080e7          	jalr	-616(ra) # 4c68 <printf>
    exit(1);
    3ed8:	4505                	li	a0,1
    3eda:	00001097          	auipc	ra,0x1
    3ede:	9de080e7          	jalr	-1570(ra) # 48b8 <exit>
  wait(0);
    3ee2:	4501                	li	a0,0
    3ee4:	00001097          	auipc	ra,0x1
    3ee8:	9dc080e7          	jalr	-1572(ra) # 48c0 <wait>
  exit(0);
    3eec:	4501                	li	a0,0
    3eee:	00001097          	auipc	ra,0x1
    3ef2:	9ca080e7          	jalr	-1590(ra) # 48b8 <exit>

0000000000003ef6 <dirtest>:
{
    3ef6:	1101                	addi	sp,sp,-32
    3ef8:	ec06                	sd	ra,24(sp)
    3efa:	e822                	sd	s0,16(sp)
    3efc:	e426                	sd	s1,8(sp)
    3efe:	1000                	addi	s0,sp,32
    3f00:	84aa                	mv	s1,a0
  printf("mkdir test\n");
    3f02:	00003517          	auipc	a0,0x3
    3f06:	b6e50513          	addi	a0,a0,-1170 # 6a70 <malloc+0x1d4a>
    3f0a:	00001097          	auipc	ra,0x1
    3f0e:	d5e080e7          	jalr	-674(ra) # 4c68 <printf>
  if(mkdir("dir0") < 0){
    3f12:	00003517          	auipc	a0,0x3
    3f16:	b6e50513          	addi	a0,a0,-1170 # 6a80 <malloc+0x1d5a>
    3f1a:	00001097          	auipc	ra,0x1
    3f1e:	a06080e7          	jalr	-1530(ra) # 4920 <mkdir>
    3f22:	04054d63          	bltz	a0,3f7c <dirtest+0x86>
  if(chdir("dir0") < 0){
    3f26:	00003517          	auipc	a0,0x3
    3f2a:	b5a50513          	addi	a0,a0,-1190 # 6a80 <malloc+0x1d5a>
    3f2e:	00001097          	auipc	ra,0x1
    3f32:	9fa080e7          	jalr	-1542(ra) # 4928 <chdir>
    3f36:	06054163          	bltz	a0,3f98 <dirtest+0xa2>
  if(chdir("..") < 0){
    3f3a:	00002517          	auipc	a0,0x2
    3f3e:	afe50513          	addi	a0,a0,-1282 # 5a38 <malloc+0xd12>
    3f42:	00001097          	auipc	ra,0x1
    3f46:	9e6080e7          	jalr	-1562(ra) # 4928 <chdir>
    3f4a:	06054563          	bltz	a0,3fb4 <dirtest+0xbe>
  if(unlink("dir0") < 0){
    3f4e:	00003517          	auipc	a0,0x3
    3f52:	b3250513          	addi	a0,a0,-1230 # 6a80 <malloc+0x1d5a>
    3f56:	00001097          	auipc	ra,0x1
    3f5a:	9b2080e7          	jalr	-1614(ra) # 4908 <unlink>
    3f5e:	06054963          	bltz	a0,3fd0 <dirtest+0xda>
  printf("%s: mkdir test ok\n");
    3f62:	00003517          	auipc	a0,0x3
    3f66:	b6e50513          	addi	a0,a0,-1170 # 6ad0 <malloc+0x1daa>
    3f6a:	00001097          	auipc	ra,0x1
    3f6e:	cfe080e7          	jalr	-770(ra) # 4c68 <printf>
}
    3f72:	60e2                	ld	ra,24(sp)
    3f74:	6442                	ld	s0,16(sp)
    3f76:	64a2                	ld	s1,8(sp)
    3f78:	6105                	addi	sp,sp,32
    3f7a:	8082                	ret
    printf("%s: mkdir failed\n", s);
    3f7c:	85a6                	mv	a1,s1
    3f7e:	00002517          	auipc	a0,0x2
    3f82:	9c250513          	addi	a0,a0,-1598 # 5940 <malloc+0xc1a>
    3f86:	00001097          	auipc	ra,0x1
    3f8a:	ce2080e7          	jalr	-798(ra) # 4c68 <printf>
    exit(1);
    3f8e:	4505                	li	a0,1
    3f90:	00001097          	auipc	ra,0x1
    3f94:	928080e7          	jalr	-1752(ra) # 48b8 <exit>
    printf("%s: chdir dir0 failed\n", s);
    3f98:	85a6                	mv	a1,s1
    3f9a:	00003517          	auipc	a0,0x3
    3f9e:	aee50513          	addi	a0,a0,-1298 # 6a88 <malloc+0x1d62>
    3fa2:	00001097          	auipc	ra,0x1
    3fa6:	cc6080e7          	jalr	-826(ra) # 4c68 <printf>
    exit(1);
    3faa:	4505                	li	a0,1
    3fac:	00001097          	auipc	ra,0x1
    3fb0:	90c080e7          	jalr	-1780(ra) # 48b8 <exit>
    printf("%s: chdir .. failed\n", s);
    3fb4:	85a6                	mv	a1,s1
    3fb6:	00003517          	auipc	a0,0x3
    3fba:	aea50513          	addi	a0,a0,-1302 # 6aa0 <malloc+0x1d7a>
    3fbe:	00001097          	auipc	ra,0x1
    3fc2:	caa080e7          	jalr	-854(ra) # 4c68 <printf>
    exit(1);
    3fc6:	4505                	li	a0,1
    3fc8:	00001097          	auipc	ra,0x1
    3fcc:	8f0080e7          	jalr	-1808(ra) # 48b8 <exit>
    printf("%s: unlink dir0 failed\n", s);
    3fd0:	85a6                	mv	a1,s1
    3fd2:	00003517          	auipc	a0,0x3
    3fd6:	ae650513          	addi	a0,a0,-1306 # 6ab8 <malloc+0x1d92>
    3fda:	00001097          	auipc	ra,0x1
    3fde:	c8e080e7          	jalr	-882(ra) # 4c68 <printf>
    exit(1);
    3fe2:	4505                	li	a0,1
    3fe4:	00001097          	auipc	ra,0x1
    3fe8:	8d4080e7          	jalr	-1836(ra) # 48b8 <exit>

0000000000003fec <mem>:
{
    3fec:	7139                	addi	sp,sp,-64
    3fee:	fc06                	sd	ra,56(sp)
    3ff0:	f822                	sd	s0,48(sp)
    3ff2:	f426                	sd	s1,40(sp)
    3ff4:	f04a                	sd	s2,32(sp)
    3ff6:	ec4e                	sd	s3,24(sp)
    3ff8:	0080                	addi	s0,sp,64
    3ffa:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    3ffc:	00001097          	auipc	ra,0x1
    4000:	8b4080e7          	jalr	-1868(ra) # 48b0 <fork>
    m1 = 0;
    4004:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    4006:	6909                	lui	s2,0x2
    4008:	71190913          	addi	s2,s2,1809 # 2711 <linktest+0xff>
  if((pid = fork()) == 0){
    400c:	ed39                	bnez	a0,406a <mem+0x7e>
    while((m2 = malloc(10001)) != 0){
    400e:	854a                	mv	a0,s2
    4010:	00001097          	auipc	ra,0x1
    4014:	d16080e7          	jalr	-746(ra) # 4d26 <malloc>
    4018:	c501                	beqz	a0,4020 <mem+0x34>
      *(char**)m2 = m1;
    401a:	e104                	sd	s1,0(a0)
      m1 = m2;
    401c:	84aa                	mv	s1,a0
    401e:	bfc5                	j	400e <mem+0x22>
    while(m1){
    4020:	c881                	beqz	s1,4030 <mem+0x44>
      m2 = *(char**)m1;
    4022:	8526                	mv	a0,s1
    4024:	6084                	ld	s1,0(s1)
      free(m1);
    4026:	00001097          	auipc	ra,0x1
    402a:	c78080e7          	jalr	-904(ra) # 4c9e <free>
    while(m1){
    402e:	f8f5                	bnez	s1,4022 <mem+0x36>
    m1 = malloc(1024*20);
    4030:	6515                	lui	a0,0x5
    4032:	00001097          	auipc	ra,0x1
    4036:	cf4080e7          	jalr	-780(ra) # 4d26 <malloc>
    if(m1 == 0){
    403a:	c911                	beqz	a0,404e <mem+0x62>
    free(m1);
    403c:	00001097          	auipc	ra,0x1
    4040:	c62080e7          	jalr	-926(ra) # 4c9e <free>
    exit(0);
    4044:	4501                	li	a0,0
    4046:	00001097          	auipc	ra,0x1
    404a:	872080e7          	jalr	-1934(ra) # 48b8 <exit>
      printf("couldn't allocate mem?!!\n", s);
    404e:	85ce                	mv	a1,s3
    4050:	00003517          	auipc	a0,0x3
    4054:	a9850513          	addi	a0,a0,-1384 # 6ae8 <malloc+0x1dc2>
    4058:	00001097          	auipc	ra,0x1
    405c:	c10080e7          	jalr	-1008(ra) # 4c68 <printf>
      exit(1);
    4060:	4505                	li	a0,1
    4062:	00001097          	auipc	ra,0x1
    4066:	856080e7          	jalr	-1962(ra) # 48b8 <exit>
    wait(&xstatus);
    406a:	fcc40513          	addi	a0,s0,-52
    406e:	00001097          	auipc	ra,0x1
    4072:	852080e7          	jalr	-1966(ra) # 48c0 <wait>
    exit(xstatus);
    4076:	fcc42503          	lw	a0,-52(s0)
    407a:	00001097          	auipc	ra,0x1
    407e:	83e080e7          	jalr	-1986(ra) # 48b8 <exit>

0000000000004082 <sbrkbasic>:
{
    4082:	715d                	addi	sp,sp,-80
    4084:	e486                	sd	ra,72(sp)
    4086:	e0a2                	sd	s0,64(sp)
    4088:	fc26                	sd	s1,56(sp)
    408a:	f84a                	sd	s2,48(sp)
    408c:	f44e                	sd	s3,40(sp)
    408e:	f052                	sd	s4,32(sp)
    4090:	ec56                	sd	s5,24(sp)
    4092:	0880                	addi	s0,sp,80
    4094:	8a2a                	mv	s4,a0
  a = sbrk(TOOMUCH);
    4096:	40000537          	lui	a0,0x40000
    409a:	00001097          	auipc	ra,0x1
    409e:	8a6080e7          	jalr	-1882(ra) # 4940 <sbrk>
  if(a != (char*)0xffffffffffffffffL){
    40a2:	57fd                	li	a5,-1
    40a4:	02f50063          	beq	a0,a5,40c4 <sbrkbasic+0x42>
    40a8:	85aa                	mv	a1,a0
    printf("%s: sbrk(<toomuch>) returned %p\n", a);
    40aa:	00003517          	auipc	a0,0x3
    40ae:	a5e50513          	addi	a0,a0,-1442 # 6b08 <malloc+0x1de2>
    40b2:	00001097          	auipc	ra,0x1
    40b6:	bb6080e7          	jalr	-1098(ra) # 4c68 <printf>
    exit(1);
    40ba:	4505                	li	a0,1
    40bc:	00000097          	auipc	ra,0x0
    40c0:	7fc080e7          	jalr	2044(ra) # 48b8 <exit>
  a = sbrk(0);
    40c4:	4501                	li	a0,0
    40c6:	00001097          	auipc	ra,0x1
    40ca:	87a080e7          	jalr	-1926(ra) # 4940 <sbrk>
    40ce:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    40d0:	4901                	li	s2,0
    *b = 1;
    40d2:	4a85                	li	s5,1
  for(i = 0; i < 5000; i++){
    40d4:	6985                	lui	s3,0x1
    40d6:	38898993          	addi	s3,s3,904 # 1388 <fourteen+0x10e>
    40da:	a011                	j	40de <sbrkbasic+0x5c>
    a = b + 1;
    40dc:	84be                	mv	s1,a5
    b = sbrk(1);
    40de:	4505                	li	a0,1
    40e0:	00001097          	auipc	ra,0x1
    40e4:	860080e7          	jalr	-1952(ra) # 4940 <sbrk>
    if(b != a){
    40e8:	04951b63          	bne	a0,s1,413e <sbrkbasic+0xbc>
    *b = 1;
    40ec:	01548023          	sb	s5,0(s1)
    a = b + 1;
    40f0:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    40f4:	2905                	addiw	s2,s2,1
    40f6:	ff3913e3          	bne	s2,s3,40dc <sbrkbasic+0x5a>
  pid = fork();
    40fa:	00000097          	auipc	ra,0x0
    40fe:	7b6080e7          	jalr	1974(ra) # 48b0 <fork>
    4102:	892a                	mv	s2,a0
  if(pid < 0){
    4104:	04054e63          	bltz	a0,4160 <sbrkbasic+0xde>
  c = sbrk(1);
    4108:	4505                	li	a0,1
    410a:	00001097          	auipc	ra,0x1
    410e:	836080e7          	jalr	-1994(ra) # 4940 <sbrk>
  c = sbrk(1);
    4112:	4505                	li	a0,1
    4114:	00001097          	auipc	ra,0x1
    4118:	82c080e7          	jalr	-2004(ra) # 4940 <sbrk>
  if(c != a + 1){
    411c:	0489                	addi	s1,s1,2
    411e:	04a48f63          	beq	s1,a0,417c <sbrkbasic+0xfa>
    printf("%s: sbrk test failed post-fork\n", s);
    4122:	85d2                	mv	a1,s4
    4124:	00003517          	auipc	a0,0x3
    4128:	a4c50513          	addi	a0,a0,-1460 # 6b70 <malloc+0x1e4a>
    412c:	00001097          	auipc	ra,0x1
    4130:	b3c080e7          	jalr	-1220(ra) # 4c68 <printf>
    exit(1);
    4134:	4505                	li	a0,1
    4136:	00000097          	auipc	ra,0x0
    413a:	782080e7          	jalr	1922(ra) # 48b8 <exit>
      printf("%s: sbrk test failed %d %x %x\n", s, i, a, b);
    413e:	872a                	mv	a4,a0
    4140:	86a6                	mv	a3,s1
    4142:	864a                	mv	a2,s2
    4144:	85d2                	mv	a1,s4
    4146:	00003517          	auipc	a0,0x3
    414a:	9ea50513          	addi	a0,a0,-1558 # 6b30 <malloc+0x1e0a>
    414e:	00001097          	auipc	ra,0x1
    4152:	b1a080e7          	jalr	-1254(ra) # 4c68 <printf>
      exit(1);
    4156:	4505                	li	a0,1
    4158:	00000097          	auipc	ra,0x0
    415c:	760080e7          	jalr	1888(ra) # 48b8 <exit>
    printf("%s: sbrk test fork failed\n", s);
    4160:	85d2                	mv	a1,s4
    4162:	00003517          	auipc	a0,0x3
    4166:	9ee50513          	addi	a0,a0,-1554 # 6b50 <malloc+0x1e2a>
    416a:	00001097          	auipc	ra,0x1
    416e:	afe080e7          	jalr	-1282(ra) # 4c68 <printf>
    exit(1);
    4172:	4505                	li	a0,1
    4174:	00000097          	auipc	ra,0x0
    4178:	744080e7          	jalr	1860(ra) # 48b8 <exit>
  if(pid == 0)
    417c:	00091763          	bnez	s2,418a <sbrkbasic+0x108>
    exit(0);
    4180:	4501                	li	a0,0
    4182:	00000097          	auipc	ra,0x0
    4186:	736080e7          	jalr	1846(ra) # 48b8 <exit>
  wait(&xstatus);
    418a:	fbc40513          	addi	a0,s0,-68
    418e:	00000097          	auipc	ra,0x0
    4192:	732080e7          	jalr	1842(ra) # 48c0 <wait>
  exit(xstatus);
    4196:	fbc42503          	lw	a0,-68(s0)
    419a:	00000097          	auipc	ra,0x0
    419e:	71e080e7          	jalr	1822(ra) # 48b8 <exit>

00000000000041a2 <fsfull>:
{
    41a2:	7171                	addi	sp,sp,-176
    41a4:	f506                	sd	ra,168(sp)
    41a6:	f122                	sd	s0,160(sp)
    41a8:	ed26                	sd	s1,152(sp)
    41aa:	e94a                	sd	s2,144(sp)
    41ac:	e54e                	sd	s3,136(sp)
    41ae:	e152                	sd	s4,128(sp)
    41b0:	fcd6                	sd	s5,120(sp)
    41b2:	f8da                	sd	s6,112(sp)
    41b4:	f4de                	sd	s7,104(sp)
    41b6:	f0e2                	sd	s8,96(sp)
    41b8:	ece6                	sd	s9,88(sp)
    41ba:	e8ea                	sd	s10,80(sp)
    41bc:	e4ee                	sd	s11,72(sp)
    41be:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    41c0:	00003517          	auipc	a0,0x3
    41c4:	9d050513          	addi	a0,a0,-1584 # 6b90 <malloc+0x1e6a>
    41c8:	00001097          	auipc	ra,0x1
    41cc:	aa0080e7          	jalr	-1376(ra) # 4c68 <printf>
  for(nfiles = 0; ; nfiles++){
    41d0:	4481                	li	s1,0
    name[0] = 'f';
    41d2:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    41d6:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    41da:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    41de:	4b29                	li	s6,10
    printf("%s: writing %s\n", name);
    41e0:	00003c97          	auipc	s9,0x3
    41e4:	9c0c8c93          	addi	s9,s9,-1600 # 6ba0 <malloc+0x1e7a>
    int total = 0;
    41e8:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    41ea:	00005a17          	auipc	s4,0x5
    41ee:	666a0a13          	addi	s4,s4,1638 # 9850 <buf>
    name[0] = 'f';
    41f2:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    41f6:	0384c7bb          	divw	a5,s1,s8
    41fa:	0307879b          	addiw	a5,a5,48
    41fe:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4202:	0384e7bb          	remw	a5,s1,s8
    4206:	0377c7bb          	divw	a5,a5,s7
    420a:	0307879b          	addiw	a5,a5,48
    420e:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4212:	0374e7bb          	remw	a5,s1,s7
    4216:	0367c7bb          	divw	a5,a5,s6
    421a:	0307879b          	addiw	a5,a5,48
    421e:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4222:	0364e7bb          	remw	a5,s1,s6
    4226:	0307879b          	addiw	a5,a5,48
    422a:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    422e:	f4040aa3          	sb	zero,-171(s0)
    printf("%s: writing %s\n", name);
    4232:	f5040593          	addi	a1,s0,-176
    4236:	8566                	mv	a0,s9
    4238:	00001097          	auipc	ra,0x1
    423c:	a30080e7          	jalr	-1488(ra) # 4c68 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4240:	20200593          	li	a1,514
    4244:	f5040513          	addi	a0,s0,-176
    4248:	00000097          	auipc	ra,0x0
    424c:	6b0080e7          	jalr	1712(ra) # 48f8 <open>
    4250:	892a                	mv	s2,a0
    if(fd < 0){
    4252:	0a055663          	bgez	a0,42fe <fsfull+0x15c>
      printf("%s: open %s failed\n", name);
    4256:	f5040593          	addi	a1,s0,-176
    425a:	00003517          	auipc	a0,0x3
    425e:	95650513          	addi	a0,a0,-1706 # 6bb0 <malloc+0x1e8a>
    4262:	00001097          	auipc	ra,0x1
    4266:	a06080e7          	jalr	-1530(ra) # 4c68 <printf>
  while(nfiles >= 0){
    426a:	0604c363          	bltz	s1,42d0 <fsfull+0x12e>
    name[0] = 'f';
    426e:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    4272:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4276:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    427a:	4929                	li	s2,10
  while(nfiles >= 0){
    427c:	5afd                	li	s5,-1
    name[0] = 'f';
    427e:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4282:	0344c7bb          	divw	a5,s1,s4
    4286:	0307879b          	addiw	a5,a5,48
    428a:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    428e:	0344e7bb          	remw	a5,s1,s4
    4292:	0337c7bb          	divw	a5,a5,s3
    4296:	0307879b          	addiw	a5,a5,48
    429a:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    429e:	0334e7bb          	remw	a5,s1,s3
    42a2:	0327c7bb          	divw	a5,a5,s2
    42a6:	0307879b          	addiw	a5,a5,48
    42aa:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    42ae:	0324e7bb          	remw	a5,s1,s2
    42b2:	0307879b          	addiw	a5,a5,48
    42b6:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    42ba:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    42be:	f5040513          	addi	a0,s0,-176
    42c2:	00000097          	auipc	ra,0x0
    42c6:	646080e7          	jalr	1606(ra) # 4908 <unlink>
    nfiles--;
    42ca:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    42cc:	fb5499e3          	bne	s1,s5,427e <fsfull+0xdc>
  printf("fsfull test finished\n");
    42d0:	00003517          	auipc	a0,0x3
    42d4:	91050513          	addi	a0,a0,-1776 # 6be0 <malloc+0x1eba>
    42d8:	00001097          	auipc	ra,0x1
    42dc:	990080e7          	jalr	-1648(ra) # 4c68 <printf>
}
    42e0:	70aa                	ld	ra,168(sp)
    42e2:	740a                	ld	s0,160(sp)
    42e4:	64ea                	ld	s1,152(sp)
    42e6:	694a                	ld	s2,144(sp)
    42e8:	69aa                	ld	s3,136(sp)
    42ea:	6a0a                	ld	s4,128(sp)
    42ec:	7ae6                	ld	s5,120(sp)
    42ee:	7b46                	ld	s6,112(sp)
    42f0:	7ba6                	ld	s7,104(sp)
    42f2:	7c06                	ld	s8,96(sp)
    42f4:	6ce6                	ld	s9,88(sp)
    42f6:	6d46                	ld	s10,80(sp)
    42f8:	6da6                	ld	s11,72(sp)
    42fa:	614d                	addi	sp,sp,176
    42fc:	8082                	ret
    int total = 0;
    42fe:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    4300:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    4304:	40000613          	li	a2,1024
    4308:	85d2                	mv	a1,s4
    430a:	854a                	mv	a0,s2
    430c:	00000097          	auipc	ra,0x0
    4310:	5cc080e7          	jalr	1484(ra) # 48d8 <write>
      if(cc < BSIZE)
    4314:	00aad563          	bge	s5,a0,431e <fsfull+0x17c>
      total += cc;
    4318:	00a989bb          	addw	s3,s3,a0
    while(1){
    431c:	b7e5                	j	4304 <fsfull+0x162>
    printf("%s: wrote %d bytes\n", total);
    431e:	85ce                	mv	a1,s3
    4320:	00003517          	auipc	a0,0x3
    4324:	8a850513          	addi	a0,a0,-1880 # 6bc8 <malloc+0x1ea2>
    4328:	00001097          	auipc	ra,0x1
    432c:	940080e7          	jalr	-1728(ra) # 4c68 <printf>
    close(fd);
    4330:	854a                	mv	a0,s2
    4332:	00000097          	auipc	ra,0x0
    4336:	5ae080e7          	jalr	1454(ra) # 48e0 <close>
    if(total == 0)
    433a:	f20988e3          	beqz	s3,426a <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    433e:	2485                	addiw	s1,s1,1
    4340:	bd4d                	j	41f2 <fsfull+0x50>

0000000000004342 <rand>:
{
    4342:	1141                	addi	sp,sp,-16
    4344:	e422                	sd	s0,8(sp)
    4346:	0800                	addi	s0,sp,16
  randstate = randstate * 1664525 + 1013904223;
    4348:	00003717          	auipc	a4,0x3
    434c:	ce070713          	addi	a4,a4,-800 # 7028 <randstate>
    4350:	6308                	ld	a0,0(a4)
    4352:	001967b7          	lui	a5,0x196
    4356:	60d78793          	addi	a5,a5,1549 # 19660d <__BSS_END__+0x189dad>
    435a:	02f50533          	mul	a0,a0,a5
    435e:	3c6ef7b7          	lui	a5,0x3c6ef
    4362:	35f78793          	addi	a5,a5,863 # 3c6ef35f <__BSS_END__+0x3c6e2aff>
    4366:	953e                	add	a0,a0,a5
    4368:	e308                	sd	a0,0(a4)
}
    436a:	2501                	sext.w	a0,a0
    436c:	6422                	ld	s0,8(sp)
    436e:	0141                	addi	sp,sp,16
    4370:	8082                	ret

0000000000004372 <badwrite>:
{
    4372:	7179                	addi	sp,sp,-48
    4374:	f406                	sd	ra,40(sp)
    4376:	f022                	sd	s0,32(sp)
    4378:	ec26                	sd	s1,24(sp)
    437a:	e84a                	sd	s2,16(sp)
    437c:	e44e                	sd	s3,8(sp)
    437e:	e052                	sd	s4,0(sp)
    4380:	1800                	addi	s0,sp,48
  unlink("junk");
    4382:	00003517          	auipc	a0,0x3
    4386:	87650513          	addi	a0,a0,-1930 # 6bf8 <malloc+0x1ed2>
    438a:	00000097          	auipc	ra,0x0
    438e:	57e080e7          	jalr	1406(ra) # 4908 <unlink>
    4392:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    4396:	00003997          	auipc	s3,0x3
    439a:	86298993          	addi	s3,s3,-1950 # 6bf8 <malloc+0x1ed2>
    write(fd, (char*)0xffffffffffL, 1);
    439e:	5a7d                	li	s4,-1
    43a0:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    43a4:	20100593          	li	a1,513
    43a8:	854e                	mv	a0,s3
    43aa:	00000097          	auipc	ra,0x0
    43ae:	54e080e7          	jalr	1358(ra) # 48f8 <open>
    43b2:	84aa                	mv	s1,a0
    if(fd < 0){
    43b4:	06054b63          	bltz	a0,442a <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    43b8:	4605                	li	a2,1
    43ba:	85d2                	mv	a1,s4
    43bc:	00000097          	auipc	ra,0x0
    43c0:	51c080e7          	jalr	1308(ra) # 48d8 <write>
    close(fd);
    43c4:	8526                	mv	a0,s1
    43c6:	00000097          	auipc	ra,0x0
    43ca:	51a080e7          	jalr	1306(ra) # 48e0 <close>
    unlink("junk");
    43ce:	854e                	mv	a0,s3
    43d0:	00000097          	auipc	ra,0x0
    43d4:	538080e7          	jalr	1336(ra) # 4908 <unlink>
  for(int i = 0; i < assumed_free; i++){
    43d8:	397d                	addiw	s2,s2,-1
    43da:	fc0915e3          	bnez	s2,43a4 <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    43de:	20100593          	li	a1,513
    43e2:	00003517          	auipc	a0,0x3
    43e6:	81650513          	addi	a0,a0,-2026 # 6bf8 <malloc+0x1ed2>
    43ea:	00000097          	auipc	ra,0x0
    43ee:	50e080e7          	jalr	1294(ra) # 48f8 <open>
    43f2:	84aa                	mv	s1,a0
  if(fd < 0){
    43f4:	04054863          	bltz	a0,4444 <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    43f8:	4605                	li	a2,1
    43fa:	00001597          	auipc	a1,0x1
    43fe:	d7658593          	addi	a1,a1,-650 # 5170 <malloc+0x44a>
    4402:	00000097          	auipc	ra,0x0
    4406:	4d6080e7          	jalr	1238(ra) # 48d8 <write>
    440a:	4785                	li	a5,1
    440c:	04f50963          	beq	a0,a5,445e <badwrite+0xec>
    printf("write failed\n");
    4410:	00003517          	auipc	a0,0x3
    4414:	80850513          	addi	a0,a0,-2040 # 6c18 <malloc+0x1ef2>
    4418:	00001097          	auipc	ra,0x1
    441c:	850080e7          	jalr	-1968(ra) # 4c68 <printf>
    exit(1);
    4420:	4505                	li	a0,1
    4422:	00000097          	auipc	ra,0x0
    4426:	496080e7          	jalr	1174(ra) # 48b8 <exit>
      printf("open junk failed\n");
    442a:	00002517          	auipc	a0,0x2
    442e:	7d650513          	addi	a0,a0,2006 # 6c00 <malloc+0x1eda>
    4432:	00001097          	auipc	ra,0x1
    4436:	836080e7          	jalr	-1994(ra) # 4c68 <printf>
      exit(1);
    443a:	4505                	li	a0,1
    443c:	00000097          	auipc	ra,0x0
    4440:	47c080e7          	jalr	1148(ra) # 48b8 <exit>
    printf("open junk failed\n");
    4444:	00002517          	auipc	a0,0x2
    4448:	7bc50513          	addi	a0,a0,1980 # 6c00 <malloc+0x1eda>
    444c:	00001097          	auipc	ra,0x1
    4450:	81c080e7          	jalr	-2020(ra) # 4c68 <printf>
    exit(1);
    4454:	4505                	li	a0,1
    4456:	00000097          	auipc	ra,0x0
    445a:	462080e7          	jalr	1122(ra) # 48b8 <exit>
  close(fd);
    445e:	8526                	mv	a0,s1
    4460:	00000097          	auipc	ra,0x0
    4464:	480080e7          	jalr	1152(ra) # 48e0 <close>
  unlink("junk");
    4468:	00002517          	auipc	a0,0x2
    446c:	79050513          	addi	a0,a0,1936 # 6bf8 <malloc+0x1ed2>
    4470:	00000097          	auipc	ra,0x0
    4474:	498080e7          	jalr	1176(ra) # 4908 <unlink>
  exit(0);
    4478:	4501                	li	a0,0
    447a:	00000097          	auipc	ra,0x0
    447e:	43e080e7          	jalr	1086(ra) # 48b8 <exit>

0000000000004482 <run>:
}

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    4482:	7179                	addi	sp,sp,-48
    4484:	f406                	sd	ra,40(sp)
    4486:	f022                	sd	s0,32(sp)
    4488:	ec26                	sd	s1,24(sp)
    448a:	e84a                	sd	s2,16(sp)
    448c:	1800                	addi	s0,sp,48
    448e:	892a                	mv	s2,a0
    4490:	84ae                	mv	s1,a1
  int pid;
  int xstatus;
  
  printf("test %s: ", s);
    4492:	00002517          	auipc	a0,0x2
    4496:	79650513          	addi	a0,a0,1942 # 6c28 <malloc+0x1f02>
    449a:	00000097          	auipc	ra,0x0
    449e:	7ce080e7          	jalr	1998(ra) # 4c68 <printf>
  if((pid = fork()) < 0) {
    44a2:	00000097          	auipc	ra,0x0
    44a6:	40e080e7          	jalr	1038(ra) # 48b0 <fork>
    44aa:	02054f63          	bltz	a0,44e8 <run+0x66>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    44ae:	c931                	beqz	a0,4502 <run+0x80>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    44b0:	fdc40513          	addi	a0,s0,-36
    44b4:	00000097          	auipc	ra,0x0
    44b8:	40c080e7          	jalr	1036(ra) # 48c0 <wait>
    if(xstatus != 0) 
    44bc:	fdc42783          	lw	a5,-36(s0)
    44c0:	cba1                	beqz	a5,4510 <run+0x8e>
      printf("FAILED\n", s);
    44c2:	85a6                	mv	a1,s1
    44c4:	00002517          	auipc	a0,0x2
    44c8:	78c50513          	addi	a0,a0,1932 # 6c50 <malloc+0x1f2a>
    44cc:	00000097          	auipc	ra,0x0
    44d0:	79c080e7          	jalr	1948(ra) # 4c68 <printf>
    else
      printf("OK\n", s);
    return xstatus == 0;
    44d4:	fdc42503          	lw	a0,-36(s0)
  }
}
    44d8:	00153513          	seqz	a0,a0
    44dc:	70a2                	ld	ra,40(sp)
    44de:	7402                	ld	s0,32(sp)
    44e0:	64e2                	ld	s1,24(sp)
    44e2:	6942                	ld	s2,16(sp)
    44e4:	6145                	addi	sp,sp,48
    44e6:	8082                	ret
    printf("runtest: fork error\n");
    44e8:	00002517          	auipc	a0,0x2
    44ec:	75050513          	addi	a0,a0,1872 # 6c38 <malloc+0x1f12>
    44f0:	00000097          	auipc	ra,0x0
    44f4:	778080e7          	jalr	1912(ra) # 4c68 <printf>
    exit(1);
    44f8:	4505                	li	a0,1
    44fa:	00000097          	auipc	ra,0x0
    44fe:	3be080e7          	jalr	958(ra) # 48b8 <exit>
    f(s);
    4502:	8526                	mv	a0,s1
    4504:	9902                	jalr	s2
    exit(0);
    4506:	4501                	li	a0,0
    4508:	00000097          	auipc	ra,0x0
    450c:	3b0080e7          	jalr	944(ra) # 48b8 <exit>
      printf("OK\n", s);
    4510:	85a6                	mv	a1,s1
    4512:	00002517          	auipc	a0,0x2
    4516:	74650513          	addi	a0,a0,1862 # 6c58 <malloc+0x1f32>
    451a:	00000097          	auipc	ra,0x0
    451e:	74e080e7          	jalr	1870(ra) # 4c68 <printf>
    4522:	bf4d                	j	44d4 <run+0x52>

0000000000004524 <main>:

int
main(int argc, char *argv[])
{
    4524:	cd010113          	addi	sp,sp,-816
    4528:	32113423          	sd	ra,808(sp)
    452c:	32813023          	sd	s0,800(sp)
    4530:	30913c23          	sd	s1,792(sp)
    4534:	31213823          	sd	s2,784(sp)
    4538:	31313423          	sd	s3,776(sp)
    453c:	31413023          	sd	s4,768(sp)
    4540:	1e00                	addi	s0,sp,816
  char *n = 0;
  if(argc > 1) {
    4542:	4785                	li	a5,1
  char *n = 0;
    4544:	4901                	li	s2,0
  if(argc > 1) {
    4546:	00a7d463          	bge	a5,a0,454e <main+0x2a>
    n = argv[1];
    454a:	0085b903          	ld	s2,8(a1)
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    454e:	00002797          	auipc	a5,0x2
    4552:	7b278793          	addi	a5,a5,1970 # 6d00 <malloc+0x1fda>
    4556:	cd040713          	addi	a4,s0,-816
    455a:	00003817          	auipc	a6,0x3
    455e:	aa680813          	addi	a6,a6,-1370 # 7000 <malloc+0x22da>
    4562:	6388                	ld	a0,0(a5)
    4564:	678c                	ld	a1,8(a5)
    4566:	6b90                	ld	a2,16(a5)
    4568:	6f94                	ld	a3,24(a5)
    456a:	e308                	sd	a0,0(a4)
    456c:	e70c                	sd	a1,8(a4)
    456e:	eb10                	sd	a2,16(a4)
    4570:	ef14                	sd	a3,24(a4)
    4572:	02078793          	addi	a5,a5,32
    4576:	02070713          	addi	a4,a4,32
    457a:	ff0794e3          	bne	a5,a6,4562 <main+0x3e>
    {forktest, "forktest"},
    {bigdir, "bigdir"}, // slow
    { 0, 0},
  };
    
  printf("usertests starting\n");
    457e:	00002517          	auipc	a0,0x2
    4582:	6e250513          	addi	a0,a0,1762 # 6c60 <malloc+0x1f3a>
    4586:	00000097          	auipc	ra,0x0
    458a:	6e2080e7          	jalr	1762(ra) # 4c68 <printf>

  if(open("usertests.ran", 0) >= 0){
    458e:	4581                	li	a1,0
    4590:	00002517          	auipc	a0,0x2
    4594:	6e850513          	addi	a0,a0,1768 # 6c78 <malloc+0x1f52>
    4598:	00000097          	auipc	ra,0x0
    459c:	360080e7          	jalr	864(ra) # 48f8 <open>
    45a0:	00054f63          	bltz	a0,45be <main+0x9a>
    printf("already ran user tests -- rebuild fs.img (rm fs.img; make fs.img)\n");
    45a4:	00002517          	auipc	a0,0x2
    45a8:	6e450513          	addi	a0,a0,1764 # 6c88 <malloc+0x1f62>
    45ac:	00000097          	auipc	ra,0x0
    45b0:	6bc080e7          	jalr	1724(ra) # 4c68 <printf>
    exit(1);
    45b4:	4505                	li	a0,1
    45b6:	00000097          	auipc	ra,0x0
    45ba:	302080e7          	jalr	770(ra) # 48b8 <exit>
  }
  close(open("usertests.ran", O_CREATE));
    45be:	20000593          	li	a1,512
    45c2:	00002517          	auipc	a0,0x2
    45c6:	6b650513          	addi	a0,a0,1718 # 6c78 <malloc+0x1f52>
    45ca:	00000097          	auipc	ra,0x0
    45ce:	32e080e7          	jalr	814(ra) # 48f8 <open>
    45d2:	00000097          	auipc	ra,0x0
    45d6:	30e080e7          	jalr	782(ra) # 48e0 <close>

  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    45da:	cd843503          	ld	a0,-808(s0)
    45de:	c529                	beqz	a0,4628 <main+0x104>
    45e0:	cd040493          	addi	s1,s0,-816
  int fail = 0;
    45e4:	4981                	li	s3,0
    if((n == 0) || strcmp(t->s, n) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    45e6:	4a05                	li	s4,1
    45e8:	a021                	j	45f0 <main+0xcc>
  for (struct test *t = tests; t->s != 0; t++) {
    45ea:	04c1                	addi	s1,s1,16
    45ec:	6488                	ld	a0,8(s1)
    45ee:	c115                	beqz	a0,4612 <main+0xee>
    if((n == 0) || strcmp(t->s, n) == 0) {
    45f0:	00090863          	beqz	s2,4600 <main+0xdc>
    45f4:	85ca                	mv	a1,s2
    45f6:	00000097          	auipc	ra,0x0
    45fa:	068080e7          	jalr	104(ra) # 465e <strcmp>
    45fe:	f575                	bnez	a0,45ea <main+0xc6>
      if(!run(t->f, t->s))
    4600:	648c                	ld	a1,8(s1)
    4602:	6088                	ld	a0,0(s1)
    4604:	00000097          	auipc	ra,0x0
    4608:	e7e080e7          	jalr	-386(ra) # 4482 <run>
    460c:	fd79                	bnez	a0,45ea <main+0xc6>
        fail = 1;
    460e:	89d2                	mv	s3,s4
    4610:	bfe9                	j	45ea <main+0xc6>
    }
  }
  if(!fail)
    4612:	00098b63          	beqz	s3,4628 <main+0x104>
    printf("ALL TESTS PASSED\n");
  else
    printf("SOME TESTS FAILED\n");
    4616:	00002517          	auipc	a0,0x2
    461a:	6d250513          	addi	a0,a0,1746 # 6ce8 <malloc+0x1fc2>
    461e:	00000097          	auipc	ra,0x0
    4622:	64a080e7          	jalr	1610(ra) # 4c68 <printf>
    4626:	a809                	j	4638 <main+0x114>
    printf("ALL TESTS PASSED\n");
    4628:	00002517          	auipc	a0,0x2
    462c:	6a850513          	addi	a0,a0,1704 # 6cd0 <malloc+0x1faa>
    4630:	00000097          	auipc	ra,0x0
    4634:	638080e7          	jalr	1592(ra) # 4c68 <printf>
  exit(1);   // not reached.
    4638:	4505                	li	a0,1
    463a:	00000097          	auipc	ra,0x0
    463e:	27e080e7          	jalr	638(ra) # 48b8 <exit>

0000000000004642 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    4642:	1141                	addi	sp,sp,-16
    4644:	e422                	sd	s0,8(sp)
    4646:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    4648:	87aa                	mv	a5,a0
    464a:	0585                	addi	a1,a1,1
    464c:	0785                	addi	a5,a5,1
    464e:	fff5c703          	lbu	a4,-1(a1)
    4652:	fee78fa3          	sb	a4,-1(a5)
    4656:	fb75                	bnez	a4,464a <strcpy+0x8>
    ;
  return os;
}
    4658:	6422                	ld	s0,8(sp)
    465a:	0141                	addi	sp,sp,16
    465c:	8082                	ret

000000000000465e <strcmp>:

int
strcmp(const char *p, const char *q)
{
    465e:	1141                	addi	sp,sp,-16
    4660:	e422                	sd	s0,8(sp)
    4662:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    4664:	00054783          	lbu	a5,0(a0)
    4668:	cb91                	beqz	a5,467c <strcmp+0x1e>
    466a:	0005c703          	lbu	a4,0(a1)
    466e:	00f71763          	bne	a4,a5,467c <strcmp+0x1e>
    p++, q++;
    4672:	0505                	addi	a0,a0,1
    4674:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    4676:	00054783          	lbu	a5,0(a0)
    467a:	fbe5                	bnez	a5,466a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    467c:	0005c503          	lbu	a0,0(a1)
}
    4680:	40a7853b          	subw	a0,a5,a0
    4684:	6422                	ld	s0,8(sp)
    4686:	0141                	addi	sp,sp,16
    4688:	8082                	ret

000000000000468a <strlen>:

uint
strlen(const char *s)
{
    468a:	1141                	addi	sp,sp,-16
    468c:	e422                	sd	s0,8(sp)
    468e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    4690:	00054783          	lbu	a5,0(a0)
    4694:	cf91                	beqz	a5,46b0 <strlen+0x26>
    4696:	0505                	addi	a0,a0,1
    4698:	87aa                	mv	a5,a0
    469a:	4685                	li	a3,1
    469c:	9e89                	subw	a3,a3,a0
    469e:	00f6853b          	addw	a0,a3,a5
    46a2:	0785                	addi	a5,a5,1
    46a4:	fff7c703          	lbu	a4,-1(a5)
    46a8:	fb7d                	bnez	a4,469e <strlen+0x14>
    ;
  return n;
}
    46aa:	6422                	ld	s0,8(sp)
    46ac:	0141                	addi	sp,sp,16
    46ae:	8082                	ret
  for(n = 0; s[n]; n++)
    46b0:	4501                	li	a0,0
    46b2:	bfe5                	j	46aa <strlen+0x20>

00000000000046b4 <memset>:

void*
memset(void *dst, int c, uint n)
{
    46b4:	1141                	addi	sp,sp,-16
    46b6:	e422                	sd	s0,8(sp)
    46b8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    46ba:	ce09                	beqz	a2,46d4 <memset+0x20>
    46bc:	87aa                	mv	a5,a0
    46be:	fff6071b          	addiw	a4,a2,-1
    46c2:	1702                	slli	a4,a4,0x20
    46c4:	9301                	srli	a4,a4,0x20
    46c6:	0705                	addi	a4,a4,1
    46c8:	972a                	add	a4,a4,a0
    cdst[i] = c;
    46ca:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    46ce:	0785                	addi	a5,a5,1
    46d0:	fee79de3          	bne	a5,a4,46ca <memset+0x16>
  }
  return dst;
}
    46d4:	6422                	ld	s0,8(sp)
    46d6:	0141                	addi	sp,sp,16
    46d8:	8082                	ret

00000000000046da <strchr>:

char*
strchr(const char *s, char c)
{
    46da:	1141                	addi	sp,sp,-16
    46dc:	e422                	sd	s0,8(sp)
    46de:	0800                	addi	s0,sp,16
  for(; *s; s++)
    46e0:	00054783          	lbu	a5,0(a0)
    46e4:	cb99                	beqz	a5,46fa <strchr+0x20>
    if(*s == c)
    46e6:	00f58763          	beq	a1,a5,46f4 <strchr+0x1a>
  for(; *s; s++)
    46ea:	0505                	addi	a0,a0,1
    46ec:	00054783          	lbu	a5,0(a0)
    46f0:	fbfd                	bnez	a5,46e6 <strchr+0xc>
      return (char*)s;
  return 0;
    46f2:	4501                	li	a0,0
}
    46f4:	6422                	ld	s0,8(sp)
    46f6:	0141                	addi	sp,sp,16
    46f8:	8082                	ret
  return 0;
    46fa:	4501                	li	a0,0
    46fc:	bfe5                	j	46f4 <strchr+0x1a>

00000000000046fe <gets>:

char*
gets(char *buf, int max)
{
    46fe:	711d                	addi	sp,sp,-96
    4700:	ec86                	sd	ra,88(sp)
    4702:	e8a2                	sd	s0,80(sp)
    4704:	e4a6                	sd	s1,72(sp)
    4706:	e0ca                	sd	s2,64(sp)
    4708:	fc4e                	sd	s3,56(sp)
    470a:	f852                	sd	s4,48(sp)
    470c:	f456                	sd	s5,40(sp)
    470e:	f05a                	sd	s6,32(sp)
    4710:	ec5e                	sd	s7,24(sp)
    4712:	1080                	addi	s0,sp,96
    4714:	8baa                	mv	s7,a0
    4716:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    4718:	892a                	mv	s2,a0
    471a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    471c:	4aa9                	li	s5,10
    471e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    4720:	89a6                	mv	s3,s1
    4722:	2485                	addiw	s1,s1,1
    4724:	0344d863          	bge	s1,s4,4754 <gets+0x56>
    cc = read(0, &c, 1);
    4728:	4605                	li	a2,1
    472a:	faf40593          	addi	a1,s0,-81
    472e:	4501                	li	a0,0
    4730:	00000097          	auipc	ra,0x0
    4734:	1a0080e7          	jalr	416(ra) # 48d0 <read>
    if(cc < 1)
    4738:	00a05e63          	blez	a0,4754 <gets+0x56>
    buf[i++] = c;
    473c:	faf44783          	lbu	a5,-81(s0)
    4740:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    4744:	01578763          	beq	a5,s5,4752 <gets+0x54>
    4748:	0905                	addi	s2,s2,1
    474a:	fd679be3          	bne	a5,s6,4720 <gets+0x22>
  for(i=0; i+1 < max; ){
    474e:	89a6                	mv	s3,s1
    4750:	a011                	j	4754 <gets+0x56>
    4752:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    4754:	99de                	add	s3,s3,s7
    4756:	00098023          	sb	zero,0(s3)
  return buf;
}
    475a:	855e                	mv	a0,s7
    475c:	60e6                	ld	ra,88(sp)
    475e:	6446                	ld	s0,80(sp)
    4760:	64a6                	ld	s1,72(sp)
    4762:	6906                	ld	s2,64(sp)
    4764:	79e2                	ld	s3,56(sp)
    4766:	7a42                	ld	s4,48(sp)
    4768:	7aa2                	ld	s5,40(sp)
    476a:	7b02                	ld	s6,32(sp)
    476c:	6be2                	ld	s7,24(sp)
    476e:	6125                	addi	sp,sp,96
    4770:	8082                	ret

0000000000004772 <stat>:

int
stat(const char *n, struct stat *st)
{
    4772:	1101                	addi	sp,sp,-32
    4774:	ec06                	sd	ra,24(sp)
    4776:	e822                	sd	s0,16(sp)
    4778:	e426                	sd	s1,8(sp)
    477a:	e04a                	sd	s2,0(sp)
    477c:	1000                	addi	s0,sp,32
    477e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    4780:	4581                	li	a1,0
    4782:	00000097          	auipc	ra,0x0
    4786:	176080e7          	jalr	374(ra) # 48f8 <open>
  if(fd < 0)
    478a:	02054563          	bltz	a0,47b4 <stat+0x42>
    478e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    4790:	85ca                	mv	a1,s2
    4792:	00000097          	auipc	ra,0x0
    4796:	17e080e7          	jalr	382(ra) # 4910 <fstat>
    479a:	892a                	mv	s2,a0
  close(fd);
    479c:	8526                	mv	a0,s1
    479e:	00000097          	auipc	ra,0x0
    47a2:	142080e7          	jalr	322(ra) # 48e0 <close>
  return r;
}
    47a6:	854a                	mv	a0,s2
    47a8:	60e2                	ld	ra,24(sp)
    47aa:	6442                	ld	s0,16(sp)
    47ac:	64a2                	ld	s1,8(sp)
    47ae:	6902                	ld	s2,0(sp)
    47b0:	6105                	addi	sp,sp,32
    47b2:	8082                	ret
    return -1;
    47b4:	597d                	li	s2,-1
    47b6:	bfc5                	j	47a6 <stat+0x34>

00000000000047b8 <atoi>:

int
atoi(const char *s)
{
    47b8:	1141                	addi	sp,sp,-16
    47ba:	e422                	sd	s0,8(sp)
    47bc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    47be:	00054603          	lbu	a2,0(a0)
    47c2:	fd06079b          	addiw	a5,a2,-48
    47c6:	0ff7f793          	andi	a5,a5,255
    47ca:	4725                	li	a4,9
    47cc:	02f76963          	bltu	a4,a5,47fe <atoi+0x46>
    47d0:	86aa                	mv	a3,a0
  n = 0;
    47d2:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    47d4:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    47d6:	0685                	addi	a3,a3,1
    47d8:	0025179b          	slliw	a5,a0,0x2
    47dc:	9fa9                	addw	a5,a5,a0
    47de:	0017979b          	slliw	a5,a5,0x1
    47e2:	9fb1                	addw	a5,a5,a2
    47e4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    47e8:	0006c603          	lbu	a2,0(a3) # 1000 <createdelete+0x1b8>
    47ec:	fd06071b          	addiw	a4,a2,-48
    47f0:	0ff77713          	andi	a4,a4,255
    47f4:	fee5f1e3          	bgeu	a1,a4,47d6 <atoi+0x1e>
  return n;
}
    47f8:	6422                	ld	s0,8(sp)
    47fa:	0141                	addi	sp,sp,16
    47fc:	8082                	ret
  n = 0;
    47fe:	4501                	li	a0,0
    4800:	bfe5                	j	47f8 <atoi+0x40>

0000000000004802 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    4802:	1141                	addi	sp,sp,-16
    4804:	e422                	sd	s0,8(sp)
    4806:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    4808:	02b57663          	bgeu	a0,a1,4834 <memmove+0x32>
    while(n-- > 0)
    480c:	02c05163          	blez	a2,482e <memmove+0x2c>
    4810:	fff6079b          	addiw	a5,a2,-1
    4814:	1782                	slli	a5,a5,0x20
    4816:	9381                	srli	a5,a5,0x20
    4818:	0785                	addi	a5,a5,1
    481a:	97aa                	add	a5,a5,a0
  dst = vdst;
    481c:	872a                	mv	a4,a0
      *dst++ = *src++;
    481e:	0585                	addi	a1,a1,1
    4820:	0705                	addi	a4,a4,1
    4822:	fff5c683          	lbu	a3,-1(a1)
    4826:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    482a:	fee79ae3          	bne	a5,a4,481e <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    482e:	6422                	ld	s0,8(sp)
    4830:	0141                	addi	sp,sp,16
    4832:	8082                	ret
    dst += n;
    4834:	00c50733          	add	a4,a0,a2
    src += n;
    4838:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    483a:	fec05ae3          	blez	a2,482e <memmove+0x2c>
    483e:	fff6079b          	addiw	a5,a2,-1
    4842:	1782                	slli	a5,a5,0x20
    4844:	9381                	srli	a5,a5,0x20
    4846:	fff7c793          	not	a5,a5
    484a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    484c:	15fd                	addi	a1,a1,-1
    484e:	177d                	addi	a4,a4,-1
    4850:	0005c683          	lbu	a3,0(a1)
    4854:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    4858:	fee79ae3          	bne	a5,a4,484c <memmove+0x4a>
    485c:	bfc9                	j	482e <memmove+0x2c>

000000000000485e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    485e:	1141                	addi	sp,sp,-16
    4860:	e422                	sd	s0,8(sp)
    4862:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    4864:	ca05                	beqz	a2,4894 <memcmp+0x36>
    4866:	fff6069b          	addiw	a3,a2,-1
    486a:	1682                	slli	a3,a3,0x20
    486c:	9281                	srli	a3,a3,0x20
    486e:	0685                	addi	a3,a3,1
    4870:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    4872:	00054783          	lbu	a5,0(a0)
    4876:	0005c703          	lbu	a4,0(a1)
    487a:	00e79863          	bne	a5,a4,488a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    487e:	0505                	addi	a0,a0,1
    p2++;
    4880:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    4882:	fed518e3          	bne	a0,a3,4872 <memcmp+0x14>
  }
  return 0;
    4886:	4501                	li	a0,0
    4888:	a019                	j	488e <memcmp+0x30>
      return *p1 - *p2;
    488a:	40e7853b          	subw	a0,a5,a4
}
    488e:	6422                	ld	s0,8(sp)
    4890:	0141                	addi	sp,sp,16
    4892:	8082                	ret
  return 0;
    4894:	4501                	li	a0,0
    4896:	bfe5                	j	488e <memcmp+0x30>

0000000000004898 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    4898:	1141                	addi	sp,sp,-16
    489a:	e406                	sd	ra,8(sp)
    489c:	e022                	sd	s0,0(sp)
    489e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    48a0:	00000097          	auipc	ra,0x0
    48a4:	f62080e7          	jalr	-158(ra) # 4802 <memmove>
}
    48a8:	60a2                	ld	ra,8(sp)
    48aa:	6402                	ld	s0,0(sp)
    48ac:	0141                	addi	sp,sp,16
    48ae:	8082                	ret

00000000000048b0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    48b0:	4885                	li	a7,1
 ecall
    48b2:	00000073          	ecall
 ret
    48b6:	8082                	ret

00000000000048b8 <exit>:
.global exit
exit:
 li a7, SYS_exit
    48b8:	4889                	li	a7,2
 ecall
    48ba:	00000073          	ecall
 ret
    48be:	8082                	ret

00000000000048c0 <wait>:
.global wait
wait:
 li a7, SYS_wait
    48c0:	488d                	li	a7,3
 ecall
    48c2:	00000073          	ecall
 ret
    48c6:	8082                	ret

00000000000048c8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    48c8:	4891                	li	a7,4
 ecall
    48ca:	00000073          	ecall
 ret
    48ce:	8082                	ret

00000000000048d0 <read>:
.global read
read:
 li a7, SYS_read
    48d0:	4895                	li	a7,5
 ecall
    48d2:	00000073          	ecall
 ret
    48d6:	8082                	ret

00000000000048d8 <write>:
.global write
write:
 li a7, SYS_write
    48d8:	48c1                	li	a7,16
 ecall
    48da:	00000073          	ecall
 ret
    48de:	8082                	ret

00000000000048e0 <close>:
.global close
close:
 li a7, SYS_close
    48e0:	48d5                	li	a7,21
 ecall
    48e2:	00000073          	ecall
 ret
    48e6:	8082                	ret

00000000000048e8 <kill>:
.global kill
kill:
 li a7, SYS_kill
    48e8:	4899                	li	a7,6
 ecall
    48ea:	00000073          	ecall
 ret
    48ee:	8082                	ret

00000000000048f0 <exec>:
.global exec
exec:
 li a7, SYS_exec
    48f0:	489d                	li	a7,7
 ecall
    48f2:	00000073          	ecall
 ret
    48f6:	8082                	ret

00000000000048f8 <open>:
.global open
open:
 li a7, SYS_open
    48f8:	48bd                	li	a7,15
 ecall
    48fa:	00000073          	ecall
 ret
    48fe:	8082                	ret

0000000000004900 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    4900:	48c5                	li	a7,17
 ecall
    4902:	00000073          	ecall
 ret
    4906:	8082                	ret

0000000000004908 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    4908:	48c9                	li	a7,18
 ecall
    490a:	00000073          	ecall
 ret
    490e:	8082                	ret

0000000000004910 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    4910:	48a1                	li	a7,8
 ecall
    4912:	00000073          	ecall
 ret
    4916:	8082                	ret

0000000000004918 <link>:
.global link
link:
 li a7, SYS_link
    4918:	48cd                	li	a7,19
 ecall
    491a:	00000073          	ecall
 ret
    491e:	8082                	ret

0000000000004920 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    4920:	48d1                	li	a7,20
 ecall
    4922:	00000073          	ecall
 ret
    4926:	8082                	ret

0000000000004928 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    4928:	48a5                	li	a7,9
 ecall
    492a:	00000073          	ecall
 ret
    492e:	8082                	ret

0000000000004930 <dup>:
.global dup
dup:
 li a7, SYS_dup
    4930:	48a9                	li	a7,10
 ecall
    4932:	00000073          	ecall
 ret
    4936:	8082                	ret

0000000000004938 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    4938:	48ad                	li	a7,11
 ecall
    493a:	00000073          	ecall
 ret
    493e:	8082                	ret

0000000000004940 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    4940:	48b1                	li	a7,12
 ecall
    4942:	00000073          	ecall
 ret
    4946:	8082                	ret

0000000000004948 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    4948:	48b5                	li	a7,13
 ecall
    494a:	00000073          	ecall
 ret
    494e:	8082                	ret

0000000000004950 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    4950:	48b9                	li	a7,14
 ecall
    4952:	00000073          	ecall
 ret
    4956:	8082                	ret

0000000000004958 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
    4958:	48d9                	li	a7,22
 ecall
    495a:	00000073          	ecall
 ret
    495e:	8082                	ret

0000000000004960 <nfree>:
.global nfree
nfree:
 li a7, SYS_nfree
    4960:	48dd                	li	a7,23
 ecall
    4962:	00000073          	ecall
 ret
    4966:	8082                	ret

0000000000004968 <test_rcu>:
.global test_rcu
test_rcu:
 li a7, SYS_test_rcu
    4968:	48e1                	li	a7,24
 ecall
    496a:	00000073          	ecall
 ret
    496e:	8082                	ret

0000000000004970 <rcu_read_only>:
.global rcu_read_only
rcu_read_only:
 li a7, SYS_rcu_read_only
    4970:	48e5                	li	a7,25
 ecall
    4972:	00000073          	ecall
 ret
    4976:	8082                	ret

0000000000004978 <rcu_read_heavy>:
.global rcu_read_heavy
rcu_read_heavy:
 li a7, SYS_rcu_read_heavy
    4978:	48e9                	li	a7,26
 ecall
    497a:	00000073          	ecall
 ret
    497e:	8082                	ret

0000000000004980 <rcu_read_write_mix>:
.global rcu_read_write_mix
rcu_read_write_mix:
 li a7, SYS_rcu_read_write_mix
    4980:	48ed                	li	a7,27
 ecall
    4982:	00000073          	ecall
 ret
    4986:	8082                	ret

0000000000004988 <rcu_read_stress>:
.global rcu_read_stress
rcu_read_stress:
 li a7, SYS_rcu_read_stress
    4988:	48f1                	li	a7,28
 ecall
    498a:	00000073          	ecall
 ret
    498e:	8082                	ret

0000000000004990 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    4990:	1101                	addi	sp,sp,-32
    4992:	ec06                	sd	ra,24(sp)
    4994:	e822                	sd	s0,16(sp)
    4996:	1000                	addi	s0,sp,32
    4998:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    499c:	4605                	li	a2,1
    499e:	fef40593          	addi	a1,s0,-17
    49a2:	00000097          	auipc	ra,0x0
    49a6:	f36080e7          	jalr	-202(ra) # 48d8 <write>
}
    49aa:	60e2                	ld	ra,24(sp)
    49ac:	6442                	ld	s0,16(sp)
    49ae:	6105                	addi	sp,sp,32
    49b0:	8082                	ret

00000000000049b2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    49b2:	7139                	addi	sp,sp,-64
    49b4:	fc06                	sd	ra,56(sp)
    49b6:	f822                	sd	s0,48(sp)
    49b8:	f426                	sd	s1,40(sp)
    49ba:	f04a                	sd	s2,32(sp)
    49bc:	ec4e                	sd	s3,24(sp)
    49be:	0080                	addi	s0,sp,64
    49c0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    49c2:	c299                	beqz	a3,49c8 <printint+0x16>
    49c4:	0805c863          	bltz	a1,4a54 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    49c8:	2581                	sext.w	a1,a1
  neg = 0;
    49ca:	4881                	li	a7,0
    49cc:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    49d0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    49d2:	2601                	sext.w	a2,a2
    49d4:	00002517          	auipc	a0,0x2
    49d8:	63450513          	addi	a0,a0,1588 # 7008 <digits>
    49dc:	883a                	mv	a6,a4
    49de:	2705                	addiw	a4,a4,1
    49e0:	02c5f7bb          	remuw	a5,a1,a2
    49e4:	1782                	slli	a5,a5,0x20
    49e6:	9381                	srli	a5,a5,0x20
    49e8:	97aa                	add	a5,a5,a0
    49ea:	0007c783          	lbu	a5,0(a5)
    49ee:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    49f2:	0005879b          	sext.w	a5,a1
    49f6:	02c5d5bb          	divuw	a1,a1,a2
    49fa:	0685                	addi	a3,a3,1
    49fc:	fec7f0e3          	bgeu	a5,a2,49dc <printint+0x2a>
  if(neg)
    4a00:	00088b63          	beqz	a7,4a16 <printint+0x64>
    buf[i++] = '-';
    4a04:	fd040793          	addi	a5,s0,-48
    4a08:	973e                	add	a4,a4,a5
    4a0a:	02d00793          	li	a5,45
    4a0e:	fef70823          	sb	a5,-16(a4)
    4a12:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    4a16:	02e05863          	blez	a4,4a46 <printint+0x94>
    4a1a:	fc040793          	addi	a5,s0,-64
    4a1e:	00e78933          	add	s2,a5,a4
    4a22:	fff78993          	addi	s3,a5,-1
    4a26:	99ba                	add	s3,s3,a4
    4a28:	377d                	addiw	a4,a4,-1
    4a2a:	1702                	slli	a4,a4,0x20
    4a2c:	9301                	srli	a4,a4,0x20
    4a2e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    4a32:	fff94583          	lbu	a1,-1(s2)
    4a36:	8526                	mv	a0,s1
    4a38:	00000097          	auipc	ra,0x0
    4a3c:	f58080e7          	jalr	-168(ra) # 4990 <putc>
  while(--i >= 0)
    4a40:	197d                	addi	s2,s2,-1
    4a42:	ff3918e3          	bne	s2,s3,4a32 <printint+0x80>
}
    4a46:	70e2                	ld	ra,56(sp)
    4a48:	7442                	ld	s0,48(sp)
    4a4a:	74a2                	ld	s1,40(sp)
    4a4c:	7902                	ld	s2,32(sp)
    4a4e:	69e2                	ld	s3,24(sp)
    4a50:	6121                	addi	sp,sp,64
    4a52:	8082                	ret
    x = -xx;
    4a54:	40b005bb          	negw	a1,a1
    neg = 1;
    4a58:	4885                	li	a7,1
    x = -xx;
    4a5a:	bf8d                	j	49cc <printint+0x1a>

0000000000004a5c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    4a5c:	7119                	addi	sp,sp,-128
    4a5e:	fc86                	sd	ra,120(sp)
    4a60:	f8a2                	sd	s0,112(sp)
    4a62:	f4a6                	sd	s1,104(sp)
    4a64:	f0ca                	sd	s2,96(sp)
    4a66:	ecce                	sd	s3,88(sp)
    4a68:	e8d2                	sd	s4,80(sp)
    4a6a:	e4d6                	sd	s5,72(sp)
    4a6c:	e0da                	sd	s6,64(sp)
    4a6e:	fc5e                	sd	s7,56(sp)
    4a70:	f862                	sd	s8,48(sp)
    4a72:	f466                	sd	s9,40(sp)
    4a74:	f06a                	sd	s10,32(sp)
    4a76:	ec6e                	sd	s11,24(sp)
    4a78:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    4a7a:	0005c903          	lbu	s2,0(a1)
    4a7e:	18090f63          	beqz	s2,4c1c <vprintf+0x1c0>
    4a82:	8aaa                	mv	s5,a0
    4a84:	8b32                	mv	s6,a2
    4a86:	00158493          	addi	s1,a1,1
  state = 0;
    4a8a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    4a8c:	02500a13          	li	s4,37
      if(c == 'd'){
    4a90:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    4a94:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    4a98:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    4a9c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    4aa0:	00002b97          	auipc	s7,0x2
    4aa4:	568b8b93          	addi	s7,s7,1384 # 7008 <digits>
    4aa8:	a839                	j	4ac6 <vprintf+0x6a>
        putc(fd, c);
    4aaa:	85ca                	mv	a1,s2
    4aac:	8556                	mv	a0,s5
    4aae:	00000097          	auipc	ra,0x0
    4ab2:	ee2080e7          	jalr	-286(ra) # 4990 <putc>
    4ab6:	a019                	j	4abc <vprintf+0x60>
    } else if(state == '%'){
    4ab8:	01498f63          	beq	s3,s4,4ad6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    4abc:	0485                	addi	s1,s1,1
    4abe:	fff4c903          	lbu	s2,-1(s1)
    4ac2:	14090d63          	beqz	s2,4c1c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    4ac6:	0009079b          	sext.w	a5,s2
    if(state == 0){
    4aca:	fe0997e3          	bnez	s3,4ab8 <vprintf+0x5c>
      if(c == '%'){
    4ace:	fd479ee3          	bne	a5,s4,4aaa <vprintf+0x4e>
        state = '%';
    4ad2:	89be                	mv	s3,a5
    4ad4:	b7e5                	j	4abc <vprintf+0x60>
      if(c == 'd'){
    4ad6:	05878063          	beq	a5,s8,4b16 <vprintf+0xba>
      } else if(c == 'l') {
    4ada:	05978c63          	beq	a5,s9,4b32 <vprintf+0xd6>
      } else if(c == 'x') {
    4ade:	07a78863          	beq	a5,s10,4b4e <vprintf+0xf2>
      } else if(c == 'p') {
    4ae2:	09b78463          	beq	a5,s11,4b6a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    4ae6:	07300713          	li	a4,115
    4aea:	0ce78663          	beq	a5,a4,4bb6 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    4aee:	06300713          	li	a4,99
    4af2:	0ee78e63          	beq	a5,a4,4bee <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    4af6:	11478863          	beq	a5,s4,4c06 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    4afa:	85d2                	mv	a1,s4
    4afc:	8556                	mv	a0,s5
    4afe:	00000097          	auipc	ra,0x0
    4b02:	e92080e7          	jalr	-366(ra) # 4990 <putc>
        putc(fd, c);
    4b06:	85ca                	mv	a1,s2
    4b08:	8556                	mv	a0,s5
    4b0a:	00000097          	auipc	ra,0x0
    4b0e:	e86080e7          	jalr	-378(ra) # 4990 <putc>
      }
      state = 0;
    4b12:	4981                	li	s3,0
    4b14:	b765                	j	4abc <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    4b16:	008b0913          	addi	s2,s6,8
    4b1a:	4685                	li	a3,1
    4b1c:	4629                	li	a2,10
    4b1e:	000b2583          	lw	a1,0(s6)
    4b22:	8556                	mv	a0,s5
    4b24:	00000097          	auipc	ra,0x0
    4b28:	e8e080e7          	jalr	-370(ra) # 49b2 <printint>
    4b2c:	8b4a                	mv	s6,s2
      state = 0;
    4b2e:	4981                	li	s3,0
    4b30:	b771                	j	4abc <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    4b32:	008b0913          	addi	s2,s6,8
    4b36:	4681                	li	a3,0
    4b38:	4629                	li	a2,10
    4b3a:	000b2583          	lw	a1,0(s6)
    4b3e:	8556                	mv	a0,s5
    4b40:	00000097          	auipc	ra,0x0
    4b44:	e72080e7          	jalr	-398(ra) # 49b2 <printint>
    4b48:	8b4a                	mv	s6,s2
      state = 0;
    4b4a:	4981                	li	s3,0
    4b4c:	bf85                	j	4abc <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    4b4e:	008b0913          	addi	s2,s6,8
    4b52:	4681                	li	a3,0
    4b54:	4641                	li	a2,16
    4b56:	000b2583          	lw	a1,0(s6)
    4b5a:	8556                	mv	a0,s5
    4b5c:	00000097          	auipc	ra,0x0
    4b60:	e56080e7          	jalr	-426(ra) # 49b2 <printint>
    4b64:	8b4a                	mv	s6,s2
      state = 0;
    4b66:	4981                	li	s3,0
    4b68:	bf91                	j	4abc <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    4b6a:	008b0793          	addi	a5,s6,8
    4b6e:	f8f43423          	sd	a5,-120(s0)
    4b72:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    4b76:	03000593          	li	a1,48
    4b7a:	8556                	mv	a0,s5
    4b7c:	00000097          	auipc	ra,0x0
    4b80:	e14080e7          	jalr	-492(ra) # 4990 <putc>
  putc(fd, 'x');
    4b84:	85ea                	mv	a1,s10
    4b86:	8556                	mv	a0,s5
    4b88:	00000097          	auipc	ra,0x0
    4b8c:	e08080e7          	jalr	-504(ra) # 4990 <putc>
    4b90:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    4b92:	03c9d793          	srli	a5,s3,0x3c
    4b96:	97de                	add	a5,a5,s7
    4b98:	0007c583          	lbu	a1,0(a5)
    4b9c:	8556                	mv	a0,s5
    4b9e:	00000097          	auipc	ra,0x0
    4ba2:	df2080e7          	jalr	-526(ra) # 4990 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    4ba6:	0992                	slli	s3,s3,0x4
    4ba8:	397d                	addiw	s2,s2,-1
    4baa:	fe0914e3          	bnez	s2,4b92 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    4bae:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    4bb2:	4981                	li	s3,0
    4bb4:	b721                	j	4abc <vprintf+0x60>
        s = va_arg(ap, char*);
    4bb6:	008b0993          	addi	s3,s6,8
    4bba:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    4bbe:	02090163          	beqz	s2,4be0 <vprintf+0x184>
        while(*s != 0){
    4bc2:	00094583          	lbu	a1,0(s2)
    4bc6:	c9a1                	beqz	a1,4c16 <vprintf+0x1ba>
          putc(fd, *s);
    4bc8:	8556                	mv	a0,s5
    4bca:	00000097          	auipc	ra,0x0
    4bce:	dc6080e7          	jalr	-570(ra) # 4990 <putc>
          s++;
    4bd2:	0905                	addi	s2,s2,1
        while(*s != 0){
    4bd4:	00094583          	lbu	a1,0(s2)
    4bd8:	f9e5                	bnez	a1,4bc8 <vprintf+0x16c>
        s = va_arg(ap, char*);
    4bda:	8b4e                	mv	s6,s3
      state = 0;
    4bdc:	4981                	li	s3,0
    4bde:	bdf9                	j	4abc <vprintf+0x60>
          s = "(null)";
    4be0:	00002917          	auipc	s2,0x2
    4be4:	42090913          	addi	s2,s2,1056 # 7000 <malloc+0x22da>
        while(*s != 0){
    4be8:	02800593          	li	a1,40
    4bec:	bff1                	j	4bc8 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    4bee:	008b0913          	addi	s2,s6,8
    4bf2:	000b4583          	lbu	a1,0(s6)
    4bf6:	8556                	mv	a0,s5
    4bf8:	00000097          	auipc	ra,0x0
    4bfc:	d98080e7          	jalr	-616(ra) # 4990 <putc>
    4c00:	8b4a                	mv	s6,s2
      state = 0;
    4c02:	4981                	li	s3,0
    4c04:	bd65                	j	4abc <vprintf+0x60>
        putc(fd, c);
    4c06:	85d2                	mv	a1,s4
    4c08:	8556                	mv	a0,s5
    4c0a:	00000097          	auipc	ra,0x0
    4c0e:	d86080e7          	jalr	-634(ra) # 4990 <putc>
      state = 0;
    4c12:	4981                	li	s3,0
    4c14:	b565                	j	4abc <vprintf+0x60>
        s = va_arg(ap, char*);
    4c16:	8b4e                	mv	s6,s3
      state = 0;
    4c18:	4981                	li	s3,0
    4c1a:	b54d                	j	4abc <vprintf+0x60>
    }
  }
}
    4c1c:	70e6                	ld	ra,120(sp)
    4c1e:	7446                	ld	s0,112(sp)
    4c20:	74a6                	ld	s1,104(sp)
    4c22:	7906                	ld	s2,96(sp)
    4c24:	69e6                	ld	s3,88(sp)
    4c26:	6a46                	ld	s4,80(sp)
    4c28:	6aa6                	ld	s5,72(sp)
    4c2a:	6b06                	ld	s6,64(sp)
    4c2c:	7be2                	ld	s7,56(sp)
    4c2e:	7c42                	ld	s8,48(sp)
    4c30:	7ca2                	ld	s9,40(sp)
    4c32:	7d02                	ld	s10,32(sp)
    4c34:	6de2                	ld	s11,24(sp)
    4c36:	6109                	addi	sp,sp,128
    4c38:	8082                	ret

0000000000004c3a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    4c3a:	715d                	addi	sp,sp,-80
    4c3c:	ec06                	sd	ra,24(sp)
    4c3e:	e822                	sd	s0,16(sp)
    4c40:	1000                	addi	s0,sp,32
    4c42:	e010                	sd	a2,0(s0)
    4c44:	e414                	sd	a3,8(s0)
    4c46:	e818                	sd	a4,16(s0)
    4c48:	ec1c                	sd	a5,24(s0)
    4c4a:	03043023          	sd	a6,32(s0)
    4c4e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    4c52:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    4c56:	8622                	mv	a2,s0
    4c58:	00000097          	auipc	ra,0x0
    4c5c:	e04080e7          	jalr	-508(ra) # 4a5c <vprintf>
}
    4c60:	60e2                	ld	ra,24(sp)
    4c62:	6442                	ld	s0,16(sp)
    4c64:	6161                	addi	sp,sp,80
    4c66:	8082                	ret

0000000000004c68 <printf>:

void
printf(const char *fmt, ...)
{
    4c68:	711d                	addi	sp,sp,-96
    4c6a:	ec06                	sd	ra,24(sp)
    4c6c:	e822                	sd	s0,16(sp)
    4c6e:	1000                	addi	s0,sp,32
    4c70:	e40c                	sd	a1,8(s0)
    4c72:	e810                	sd	a2,16(s0)
    4c74:	ec14                	sd	a3,24(s0)
    4c76:	f018                	sd	a4,32(s0)
    4c78:	f41c                	sd	a5,40(s0)
    4c7a:	03043823          	sd	a6,48(s0)
    4c7e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    4c82:	00840613          	addi	a2,s0,8
    4c86:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    4c8a:	85aa                	mv	a1,a0
    4c8c:	4505                	li	a0,1
    4c8e:	00000097          	auipc	ra,0x0
    4c92:	dce080e7          	jalr	-562(ra) # 4a5c <vprintf>
}
    4c96:	60e2                	ld	ra,24(sp)
    4c98:	6442                	ld	s0,16(sp)
    4c9a:	6125                	addi	sp,sp,96
    4c9c:	8082                	ret

0000000000004c9e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    4c9e:	1141                	addi	sp,sp,-16
    4ca0:	e422                	sd	s0,8(sp)
    4ca2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    4ca4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    4ca8:	00002797          	auipc	a5,0x2
    4cac:	3907b783          	ld	a5,912(a5) # 7038 <freep>
    4cb0:	a805                	j	4ce0 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    4cb2:	4618                	lw	a4,8(a2)
    4cb4:	9db9                	addw	a1,a1,a4
    4cb6:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    4cba:	6398                	ld	a4,0(a5)
    4cbc:	6318                	ld	a4,0(a4)
    4cbe:	fee53823          	sd	a4,-16(a0)
    4cc2:	a091                	j	4d06 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    4cc4:	ff852703          	lw	a4,-8(a0)
    4cc8:	9e39                	addw	a2,a2,a4
    4cca:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    4ccc:	ff053703          	ld	a4,-16(a0)
    4cd0:	e398                	sd	a4,0(a5)
    4cd2:	a099                	j	4d18 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    4cd4:	6398                	ld	a4,0(a5)
    4cd6:	00e7e463          	bltu	a5,a4,4cde <free+0x40>
    4cda:	00e6ea63          	bltu	a3,a4,4cee <free+0x50>
{
    4cde:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    4ce0:	fed7fae3          	bgeu	a5,a3,4cd4 <free+0x36>
    4ce4:	6398                	ld	a4,0(a5)
    4ce6:	00e6e463          	bltu	a3,a4,4cee <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    4cea:	fee7eae3          	bltu	a5,a4,4cde <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    4cee:	ff852583          	lw	a1,-8(a0)
    4cf2:	6390                	ld	a2,0(a5)
    4cf4:	02059713          	slli	a4,a1,0x20
    4cf8:	9301                	srli	a4,a4,0x20
    4cfa:	0712                	slli	a4,a4,0x4
    4cfc:	9736                	add	a4,a4,a3
    4cfe:	fae60ae3          	beq	a2,a4,4cb2 <free+0x14>
    bp->s.ptr = p->s.ptr;
    4d02:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    4d06:	4790                	lw	a2,8(a5)
    4d08:	02061713          	slli	a4,a2,0x20
    4d0c:	9301                	srli	a4,a4,0x20
    4d0e:	0712                	slli	a4,a4,0x4
    4d10:	973e                	add	a4,a4,a5
    4d12:	fae689e3          	beq	a3,a4,4cc4 <free+0x26>
  } else
    p->s.ptr = bp;
    4d16:	e394                	sd	a3,0(a5)
  freep = p;
    4d18:	00002717          	auipc	a4,0x2
    4d1c:	32f73023          	sd	a5,800(a4) # 7038 <freep>
}
    4d20:	6422                	ld	s0,8(sp)
    4d22:	0141                	addi	sp,sp,16
    4d24:	8082                	ret

0000000000004d26 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    4d26:	7139                	addi	sp,sp,-64
    4d28:	fc06                	sd	ra,56(sp)
    4d2a:	f822                	sd	s0,48(sp)
    4d2c:	f426                	sd	s1,40(sp)
    4d2e:	f04a                	sd	s2,32(sp)
    4d30:	ec4e                	sd	s3,24(sp)
    4d32:	e852                	sd	s4,16(sp)
    4d34:	e456                	sd	s5,8(sp)
    4d36:	e05a                	sd	s6,0(sp)
    4d38:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    4d3a:	02051493          	slli	s1,a0,0x20
    4d3e:	9081                	srli	s1,s1,0x20
    4d40:	04bd                	addi	s1,s1,15
    4d42:	8091                	srli	s1,s1,0x4
    4d44:	0014899b          	addiw	s3,s1,1
    4d48:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    4d4a:	00002517          	auipc	a0,0x2
    4d4e:	2ee53503          	ld	a0,750(a0) # 7038 <freep>
    4d52:	c515                	beqz	a0,4d7e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    4d54:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    4d56:	4798                	lw	a4,8(a5)
    4d58:	02977f63          	bgeu	a4,s1,4d96 <malloc+0x70>
    4d5c:	8a4e                	mv	s4,s3
    4d5e:	0009871b          	sext.w	a4,s3
    4d62:	6685                	lui	a3,0x1
    4d64:	00d77363          	bgeu	a4,a3,4d6a <malloc+0x44>
    4d68:	6a05                	lui	s4,0x1
    4d6a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    4d6e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    4d72:	00002917          	auipc	s2,0x2
    4d76:	2c690913          	addi	s2,s2,710 # 7038 <freep>
  if(p == (char*)-1)
    4d7a:	5afd                	li	s5,-1
    4d7c:	a88d                	j	4dee <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    4d7e:	00008797          	auipc	a5,0x8
    4d82:	ad278793          	addi	a5,a5,-1326 # c850 <base>
    4d86:	00002717          	auipc	a4,0x2
    4d8a:	2af73923          	sd	a5,690(a4) # 7038 <freep>
    4d8e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    4d90:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    4d94:	b7e1                	j	4d5c <malloc+0x36>
      if(p->s.size == nunits)
    4d96:	02e48b63          	beq	s1,a4,4dcc <malloc+0xa6>
        p->s.size -= nunits;
    4d9a:	4137073b          	subw	a4,a4,s3
    4d9e:	c798                	sw	a4,8(a5)
        p += p->s.size;
    4da0:	1702                	slli	a4,a4,0x20
    4da2:	9301                	srli	a4,a4,0x20
    4da4:	0712                	slli	a4,a4,0x4
    4da6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    4da8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    4dac:	00002717          	auipc	a4,0x2
    4db0:	28a73623          	sd	a0,652(a4) # 7038 <freep>
      return (void*)(p + 1);
    4db4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    4db8:	70e2                	ld	ra,56(sp)
    4dba:	7442                	ld	s0,48(sp)
    4dbc:	74a2                	ld	s1,40(sp)
    4dbe:	7902                	ld	s2,32(sp)
    4dc0:	69e2                	ld	s3,24(sp)
    4dc2:	6a42                	ld	s4,16(sp)
    4dc4:	6aa2                	ld	s5,8(sp)
    4dc6:	6b02                	ld	s6,0(sp)
    4dc8:	6121                	addi	sp,sp,64
    4dca:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    4dcc:	6398                	ld	a4,0(a5)
    4dce:	e118                	sd	a4,0(a0)
    4dd0:	bff1                	j	4dac <malloc+0x86>
  hp->s.size = nu;
    4dd2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    4dd6:	0541                	addi	a0,a0,16
    4dd8:	00000097          	auipc	ra,0x0
    4ddc:	ec6080e7          	jalr	-314(ra) # 4c9e <free>
  return freep;
    4de0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    4de4:	d971                	beqz	a0,4db8 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    4de6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    4de8:	4798                	lw	a4,8(a5)
    4dea:	fa9776e3          	bgeu	a4,s1,4d96 <malloc+0x70>
    if(p == freep)
    4dee:	00093703          	ld	a4,0(s2)
    4df2:	853e                	mv	a0,a5
    4df4:	fef719e3          	bne	a4,a5,4de6 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    4df8:	8552                	mv	a0,s4
    4dfa:	00000097          	auipc	ra,0x0
    4dfe:	b46080e7          	jalr	-1210(ra) # 4940 <sbrk>
  if(p == (char*)-1)
    4e02:	fd5518e3          	bne	a0,s5,4dd2 <malloc+0xac>
        return 0;
    4e06:	4501                	li	a0,0
    4e08:	bf45                	j	4db8 <malloc+0x92>
