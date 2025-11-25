
user/_cat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	89aa                	mv	s3,a0
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  10:	00001917          	auipc	s2,0x1
  14:	94090913          	addi	s2,s2,-1728 # 950 <buf>
  18:	20000613          	li	a2,512
  1c:	85ca                	mv	a1,s2
  1e:	854e                	mv	a0,s3
  20:	00000097          	auipc	ra,0x0
  24:	386080e7          	jalr	902(ra) # 3a6 <read>
  28:	84aa                	mv	s1,a0
  2a:	02a05863          	blez	a0,5a <cat+0x5a>
    if (write(1, buf, n) != n) {
  2e:	8626                	mv	a2,s1
  30:	85ca                	mv	a1,s2
  32:	4505                	li	a0,1
  34:	00000097          	auipc	ra,0x0
  38:	37a080e7          	jalr	890(ra) # 3ae <write>
  3c:	fc950ee3          	beq	a0,s1,18 <cat+0x18>
      printf("cat: write error\n");
  40:	00001517          	auipc	a0,0x1
  44:	8a050513          	addi	a0,a0,-1888 # 8e0 <malloc+0xe4>
  48:	00000097          	auipc	ra,0x0
  4c:	6f6080e7          	jalr	1782(ra) # 73e <printf>
      exit(1);
  50:	4505                	li	a0,1
  52:	00000097          	auipc	ra,0x0
  56:	33c080e7          	jalr	828(ra) # 38e <exit>
    }
  }
  if(n < 0){
  5a:	00054963          	bltz	a0,6c <cat+0x6c>
    printf("cat: read error\n");
    exit(1);
  }
}
  5e:	70a2                	ld	ra,40(sp)
  60:	7402                	ld	s0,32(sp)
  62:	64e2                	ld	s1,24(sp)
  64:	6942                	ld	s2,16(sp)
  66:	69a2                	ld	s3,8(sp)
  68:	6145                	addi	sp,sp,48
  6a:	8082                	ret
    printf("cat: read error\n");
  6c:	00001517          	auipc	a0,0x1
  70:	88c50513          	addi	a0,a0,-1908 # 8f8 <malloc+0xfc>
  74:	00000097          	auipc	ra,0x0
  78:	6ca080e7          	jalr	1738(ra) # 73e <printf>
    exit(1);
  7c:	4505                	li	a0,1
  7e:	00000097          	auipc	ra,0x0
  82:	310080e7          	jalr	784(ra) # 38e <exit>

0000000000000086 <main>:

int
main(int argc, char *argv[])
{
  86:	7179                	addi	sp,sp,-48
  88:	f406                	sd	ra,40(sp)
  8a:	f022                	sd	s0,32(sp)
  8c:	ec26                	sd	s1,24(sp)
  8e:	e84a                	sd	s2,16(sp)
  90:	e44e                	sd	s3,8(sp)
  92:	e052                	sd	s4,0(sp)
  94:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  96:	4785                	li	a5,1
  98:	04a7d763          	bge	a5,a0,e6 <main+0x60>
  9c:	00858913          	addi	s2,a1,8
  a0:	ffe5099b          	addiw	s3,a0,-2
  a4:	1982                	slli	s3,s3,0x20
  a6:	0209d993          	srli	s3,s3,0x20
  aa:	098e                	slli	s3,s3,0x3
  ac:	05c1                	addi	a1,a1,16
  ae:	99ae                	add	s3,s3,a1
    cat(0);
    exit(1);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
  b0:	4581                	li	a1,0
  b2:	00093503          	ld	a0,0(s2)
  b6:	00000097          	auipc	ra,0x0
  ba:	318080e7          	jalr	792(ra) # 3ce <open>
  be:	84aa                	mv	s1,a0
  c0:	02054d63          	bltz	a0,fa <main+0x74>
      printf("cat: cannot open %s\n", argv[i]);
      exit(1);
    }
    cat(fd);
  c4:	00000097          	auipc	ra,0x0
  c8:	f3c080e7          	jalr	-196(ra) # 0 <cat>
    close(fd);
  cc:	8526                	mv	a0,s1
  ce:	00000097          	auipc	ra,0x0
  d2:	2e8080e7          	jalr	744(ra) # 3b6 <close>
  for(i = 1; i < argc; i++){
  d6:	0921                	addi	s2,s2,8
  d8:	fd391ce3          	bne	s2,s3,b0 <main+0x2a>
  }
  exit(0);
  dc:	4501                	li	a0,0
  de:	00000097          	auipc	ra,0x0
  e2:	2b0080e7          	jalr	688(ra) # 38e <exit>
    cat(0);
  e6:	4501                	li	a0,0
  e8:	00000097          	auipc	ra,0x0
  ec:	f18080e7          	jalr	-232(ra) # 0 <cat>
    exit(1);
  f0:	4505                	li	a0,1
  f2:	00000097          	auipc	ra,0x0
  f6:	29c080e7          	jalr	668(ra) # 38e <exit>
      printf("cat: cannot open %s\n", argv[i]);
  fa:	00093583          	ld	a1,0(s2)
  fe:	00001517          	auipc	a0,0x1
 102:	81250513          	addi	a0,a0,-2030 # 910 <malloc+0x114>
 106:	00000097          	auipc	ra,0x0
 10a:	638080e7          	jalr	1592(ra) # 73e <printf>
      exit(1);
 10e:	4505                	li	a0,1
 110:	00000097          	auipc	ra,0x0
 114:	27e080e7          	jalr	638(ra) # 38e <exit>

0000000000000118 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 118:	1141                	addi	sp,sp,-16
 11a:	e422                	sd	s0,8(sp)
 11c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 11e:	87aa                	mv	a5,a0
 120:	0585                	addi	a1,a1,1
 122:	0785                	addi	a5,a5,1
 124:	fff5c703          	lbu	a4,-1(a1)
 128:	fee78fa3          	sb	a4,-1(a5)
 12c:	fb75                	bnez	a4,120 <strcpy+0x8>
    ;
  return os;
}
 12e:	6422                	ld	s0,8(sp)
 130:	0141                	addi	sp,sp,16
 132:	8082                	ret

0000000000000134 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 134:	1141                	addi	sp,sp,-16
 136:	e422                	sd	s0,8(sp)
 138:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 13a:	00054783          	lbu	a5,0(a0)
 13e:	cb91                	beqz	a5,152 <strcmp+0x1e>
 140:	0005c703          	lbu	a4,0(a1)
 144:	00f71763          	bne	a4,a5,152 <strcmp+0x1e>
    p++, q++;
 148:	0505                	addi	a0,a0,1
 14a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 14c:	00054783          	lbu	a5,0(a0)
 150:	fbe5                	bnez	a5,140 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 152:	0005c503          	lbu	a0,0(a1)
}
 156:	40a7853b          	subw	a0,a5,a0
 15a:	6422                	ld	s0,8(sp)
 15c:	0141                	addi	sp,sp,16
 15e:	8082                	ret

0000000000000160 <strlen>:

uint
strlen(const char *s)
{
 160:	1141                	addi	sp,sp,-16
 162:	e422                	sd	s0,8(sp)
 164:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 166:	00054783          	lbu	a5,0(a0)
 16a:	cf91                	beqz	a5,186 <strlen+0x26>
 16c:	0505                	addi	a0,a0,1
 16e:	87aa                	mv	a5,a0
 170:	4685                	li	a3,1
 172:	9e89                	subw	a3,a3,a0
 174:	00f6853b          	addw	a0,a3,a5
 178:	0785                	addi	a5,a5,1
 17a:	fff7c703          	lbu	a4,-1(a5)
 17e:	fb7d                	bnez	a4,174 <strlen+0x14>
    ;
  return n;
}
 180:	6422                	ld	s0,8(sp)
 182:	0141                	addi	sp,sp,16
 184:	8082                	ret
  for(n = 0; s[n]; n++)
 186:	4501                	li	a0,0
 188:	bfe5                	j	180 <strlen+0x20>

000000000000018a <memset>:

void*
memset(void *dst, int c, uint n)
{
 18a:	1141                	addi	sp,sp,-16
 18c:	e422                	sd	s0,8(sp)
 18e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 190:	ce09                	beqz	a2,1aa <memset+0x20>
 192:	87aa                	mv	a5,a0
 194:	fff6071b          	addiw	a4,a2,-1
 198:	1702                	slli	a4,a4,0x20
 19a:	9301                	srli	a4,a4,0x20
 19c:	0705                	addi	a4,a4,1
 19e:	972a                	add	a4,a4,a0
    cdst[i] = c;
 1a0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1a4:	0785                	addi	a5,a5,1
 1a6:	fee79de3          	bne	a5,a4,1a0 <memset+0x16>
  }
  return dst;
}
 1aa:	6422                	ld	s0,8(sp)
 1ac:	0141                	addi	sp,sp,16
 1ae:	8082                	ret

00000000000001b0 <strchr>:

char*
strchr(const char *s, char c)
{
 1b0:	1141                	addi	sp,sp,-16
 1b2:	e422                	sd	s0,8(sp)
 1b4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1b6:	00054783          	lbu	a5,0(a0)
 1ba:	cb99                	beqz	a5,1d0 <strchr+0x20>
    if(*s == c)
 1bc:	00f58763          	beq	a1,a5,1ca <strchr+0x1a>
  for(; *s; s++)
 1c0:	0505                	addi	a0,a0,1
 1c2:	00054783          	lbu	a5,0(a0)
 1c6:	fbfd                	bnez	a5,1bc <strchr+0xc>
      return (char*)s;
  return 0;
 1c8:	4501                	li	a0,0
}
 1ca:	6422                	ld	s0,8(sp)
 1cc:	0141                	addi	sp,sp,16
 1ce:	8082                	ret
  return 0;
 1d0:	4501                	li	a0,0
 1d2:	bfe5                	j	1ca <strchr+0x1a>

00000000000001d4 <gets>:

char*
gets(char *buf, int max)
{
 1d4:	711d                	addi	sp,sp,-96
 1d6:	ec86                	sd	ra,88(sp)
 1d8:	e8a2                	sd	s0,80(sp)
 1da:	e4a6                	sd	s1,72(sp)
 1dc:	e0ca                	sd	s2,64(sp)
 1de:	fc4e                	sd	s3,56(sp)
 1e0:	f852                	sd	s4,48(sp)
 1e2:	f456                	sd	s5,40(sp)
 1e4:	f05a                	sd	s6,32(sp)
 1e6:	ec5e                	sd	s7,24(sp)
 1e8:	1080                	addi	s0,sp,96
 1ea:	8baa                	mv	s7,a0
 1ec:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ee:	892a                	mv	s2,a0
 1f0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1f2:	4aa9                	li	s5,10
 1f4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1f6:	89a6                	mv	s3,s1
 1f8:	2485                	addiw	s1,s1,1
 1fa:	0344d863          	bge	s1,s4,22a <gets+0x56>
    cc = read(0, &c, 1);
 1fe:	4605                	li	a2,1
 200:	faf40593          	addi	a1,s0,-81
 204:	4501                	li	a0,0
 206:	00000097          	auipc	ra,0x0
 20a:	1a0080e7          	jalr	416(ra) # 3a6 <read>
    if(cc < 1)
 20e:	00a05e63          	blez	a0,22a <gets+0x56>
    buf[i++] = c;
 212:	faf44783          	lbu	a5,-81(s0)
 216:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 21a:	01578763          	beq	a5,s5,228 <gets+0x54>
 21e:	0905                	addi	s2,s2,1
 220:	fd679be3          	bne	a5,s6,1f6 <gets+0x22>
  for(i=0; i+1 < max; ){
 224:	89a6                	mv	s3,s1
 226:	a011                	j	22a <gets+0x56>
 228:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 22a:	99de                	add	s3,s3,s7
 22c:	00098023          	sb	zero,0(s3)
  return buf;
}
 230:	855e                	mv	a0,s7
 232:	60e6                	ld	ra,88(sp)
 234:	6446                	ld	s0,80(sp)
 236:	64a6                	ld	s1,72(sp)
 238:	6906                	ld	s2,64(sp)
 23a:	79e2                	ld	s3,56(sp)
 23c:	7a42                	ld	s4,48(sp)
 23e:	7aa2                	ld	s5,40(sp)
 240:	7b02                	ld	s6,32(sp)
 242:	6be2                	ld	s7,24(sp)
 244:	6125                	addi	sp,sp,96
 246:	8082                	ret

0000000000000248 <stat>:

int
stat(const char *n, struct stat *st)
{
 248:	1101                	addi	sp,sp,-32
 24a:	ec06                	sd	ra,24(sp)
 24c:	e822                	sd	s0,16(sp)
 24e:	e426                	sd	s1,8(sp)
 250:	e04a                	sd	s2,0(sp)
 252:	1000                	addi	s0,sp,32
 254:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 256:	4581                	li	a1,0
 258:	00000097          	auipc	ra,0x0
 25c:	176080e7          	jalr	374(ra) # 3ce <open>
  if(fd < 0)
 260:	02054563          	bltz	a0,28a <stat+0x42>
 264:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 266:	85ca                	mv	a1,s2
 268:	00000097          	auipc	ra,0x0
 26c:	17e080e7          	jalr	382(ra) # 3e6 <fstat>
 270:	892a                	mv	s2,a0
  close(fd);
 272:	8526                	mv	a0,s1
 274:	00000097          	auipc	ra,0x0
 278:	142080e7          	jalr	322(ra) # 3b6 <close>
  return r;
}
 27c:	854a                	mv	a0,s2
 27e:	60e2                	ld	ra,24(sp)
 280:	6442                	ld	s0,16(sp)
 282:	64a2                	ld	s1,8(sp)
 284:	6902                	ld	s2,0(sp)
 286:	6105                	addi	sp,sp,32
 288:	8082                	ret
    return -1;
 28a:	597d                	li	s2,-1
 28c:	bfc5                	j	27c <stat+0x34>

000000000000028e <atoi>:

int
atoi(const char *s)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e422                	sd	s0,8(sp)
 292:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 294:	00054603          	lbu	a2,0(a0)
 298:	fd06079b          	addiw	a5,a2,-48
 29c:	0ff7f793          	andi	a5,a5,255
 2a0:	4725                	li	a4,9
 2a2:	02f76963          	bltu	a4,a5,2d4 <atoi+0x46>
 2a6:	86aa                	mv	a3,a0
  n = 0;
 2a8:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2aa:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2ac:	0685                	addi	a3,a3,1
 2ae:	0025179b          	slliw	a5,a0,0x2
 2b2:	9fa9                	addw	a5,a5,a0
 2b4:	0017979b          	slliw	a5,a5,0x1
 2b8:	9fb1                	addw	a5,a5,a2
 2ba:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2be:	0006c603          	lbu	a2,0(a3)
 2c2:	fd06071b          	addiw	a4,a2,-48
 2c6:	0ff77713          	andi	a4,a4,255
 2ca:	fee5f1e3          	bgeu	a1,a4,2ac <atoi+0x1e>
  return n;
}
 2ce:	6422                	ld	s0,8(sp)
 2d0:	0141                	addi	sp,sp,16
 2d2:	8082                	ret
  n = 0;
 2d4:	4501                	li	a0,0
 2d6:	bfe5                	j	2ce <atoi+0x40>

00000000000002d8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2d8:	1141                	addi	sp,sp,-16
 2da:	e422                	sd	s0,8(sp)
 2dc:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2de:	02b57663          	bgeu	a0,a1,30a <memmove+0x32>
    while(n-- > 0)
 2e2:	02c05163          	blez	a2,304 <memmove+0x2c>
 2e6:	fff6079b          	addiw	a5,a2,-1
 2ea:	1782                	slli	a5,a5,0x20
 2ec:	9381                	srli	a5,a5,0x20
 2ee:	0785                	addi	a5,a5,1
 2f0:	97aa                	add	a5,a5,a0
  dst = vdst;
 2f2:	872a                	mv	a4,a0
      *dst++ = *src++;
 2f4:	0585                	addi	a1,a1,1
 2f6:	0705                	addi	a4,a4,1
 2f8:	fff5c683          	lbu	a3,-1(a1)
 2fc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 300:	fee79ae3          	bne	a5,a4,2f4 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 304:	6422                	ld	s0,8(sp)
 306:	0141                	addi	sp,sp,16
 308:	8082                	ret
    dst += n;
 30a:	00c50733          	add	a4,a0,a2
    src += n;
 30e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 310:	fec05ae3          	blez	a2,304 <memmove+0x2c>
 314:	fff6079b          	addiw	a5,a2,-1
 318:	1782                	slli	a5,a5,0x20
 31a:	9381                	srli	a5,a5,0x20
 31c:	fff7c793          	not	a5,a5
 320:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 322:	15fd                	addi	a1,a1,-1
 324:	177d                	addi	a4,a4,-1
 326:	0005c683          	lbu	a3,0(a1)
 32a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 32e:	fee79ae3          	bne	a5,a4,322 <memmove+0x4a>
 332:	bfc9                	j	304 <memmove+0x2c>

0000000000000334 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 334:	1141                	addi	sp,sp,-16
 336:	e422                	sd	s0,8(sp)
 338:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 33a:	ca05                	beqz	a2,36a <memcmp+0x36>
 33c:	fff6069b          	addiw	a3,a2,-1
 340:	1682                	slli	a3,a3,0x20
 342:	9281                	srli	a3,a3,0x20
 344:	0685                	addi	a3,a3,1
 346:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 348:	00054783          	lbu	a5,0(a0)
 34c:	0005c703          	lbu	a4,0(a1)
 350:	00e79863          	bne	a5,a4,360 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 354:	0505                	addi	a0,a0,1
    p2++;
 356:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 358:	fed518e3          	bne	a0,a3,348 <memcmp+0x14>
  }
  return 0;
 35c:	4501                	li	a0,0
 35e:	a019                	j	364 <memcmp+0x30>
      return *p1 - *p2;
 360:	40e7853b          	subw	a0,a5,a4
}
 364:	6422                	ld	s0,8(sp)
 366:	0141                	addi	sp,sp,16
 368:	8082                	ret
  return 0;
 36a:	4501                	li	a0,0
 36c:	bfe5                	j	364 <memcmp+0x30>

000000000000036e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 36e:	1141                	addi	sp,sp,-16
 370:	e406                	sd	ra,8(sp)
 372:	e022                	sd	s0,0(sp)
 374:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 376:	00000097          	auipc	ra,0x0
 37a:	f62080e7          	jalr	-158(ra) # 2d8 <memmove>
}
 37e:	60a2                	ld	ra,8(sp)
 380:	6402                	ld	s0,0(sp)
 382:	0141                	addi	sp,sp,16
 384:	8082                	ret

0000000000000386 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 386:	4885                	li	a7,1
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <exit>:
.global exit
exit:
 li a7, SYS_exit
 38e:	4889                	li	a7,2
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <wait>:
.global wait
wait:
 li a7, SYS_wait
 396:	488d                	li	a7,3
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 39e:	4891                	li	a7,4
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <read>:
.global read
read:
 li a7, SYS_read
 3a6:	4895                	li	a7,5
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <write>:
.global write
write:
 li a7, SYS_write
 3ae:	48c1                	li	a7,16
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <close>:
.global close
close:
 li a7, SYS_close
 3b6:	48d5                	li	a7,21
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <kill>:
.global kill
kill:
 li a7, SYS_kill
 3be:	4899                	li	a7,6
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3c6:	489d                	li	a7,7
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <open>:
.global open
open:
 li a7, SYS_open
 3ce:	48bd                	li	a7,15
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3d6:	48c5                	li	a7,17
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3de:	48c9                	li	a7,18
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3e6:	48a1                	li	a7,8
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <link>:
.global link
link:
 li a7, SYS_link
 3ee:	48cd                	li	a7,19
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3f6:	48d1                	li	a7,20
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3fe:	48a5                	li	a7,9
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <dup>:
.global dup
dup:
 li a7, SYS_dup
 406:	48a9                	li	a7,10
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 40e:	48ad                	li	a7,11
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 416:	48b1                	li	a7,12
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 41e:	48b5                	li	a7,13
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 426:	48b9                	li	a7,14
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 42e:	48d9                	li	a7,22
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <nfree>:
.global nfree
nfree:
 li a7, SYS_nfree
 436:	48dd                	li	a7,23
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <test_rcu>:
.global test_rcu
test_rcu:
 li a7, SYS_test_rcu
 43e:	48e1                	li	a7,24
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <rcu_read_only>:
.global rcu_read_only
rcu_read_only:
 li a7, SYS_rcu_read_only
 446:	48e5                	li	a7,25
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <rcu_read_heavy>:
.global rcu_read_heavy
rcu_read_heavy:
 li a7, SYS_rcu_read_heavy
 44e:	48e9                	li	a7,26
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <rcu_read_write_mix>:
.global rcu_read_write_mix
rcu_read_write_mix:
 li a7, SYS_rcu_read_write_mix
 456:	48ed                	li	a7,27
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <rcu_read_stress>:
.global rcu_read_stress
rcu_read_stress:
 li a7, SYS_rcu_read_stress
 45e:	48f1                	li	a7,28
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 466:	1101                	addi	sp,sp,-32
 468:	ec06                	sd	ra,24(sp)
 46a:	e822                	sd	s0,16(sp)
 46c:	1000                	addi	s0,sp,32
 46e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 472:	4605                	li	a2,1
 474:	fef40593          	addi	a1,s0,-17
 478:	00000097          	auipc	ra,0x0
 47c:	f36080e7          	jalr	-202(ra) # 3ae <write>
}
 480:	60e2                	ld	ra,24(sp)
 482:	6442                	ld	s0,16(sp)
 484:	6105                	addi	sp,sp,32
 486:	8082                	ret

0000000000000488 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 488:	7139                	addi	sp,sp,-64
 48a:	fc06                	sd	ra,56(sp)
 48c:	f822                	sd	s0,48(sp)
 48e:	f426                	sd	s1,40(sp)
 490:	f04a                	sd	s2,32(sp)
 492:	ec4e                	sd	s3,24(sp)
 494:	0080                	addi	s0,sp,64
 496:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 498:	c299                	beqz	a3,49e <printint+0x16>
 49a:	0805c863          	bltz	a1,52a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 49e:	2581                	sext.w	a1,a1
  neg = 0;
 4a0:	4881                	li	a7,0
 4a2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4a6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4a8:	2601                	sext.w	a2,a2
 4aa:	00000517          	auipc	a0,0x0
 4ae:	48650513          	addi	a0,a0,1158 # 930 <digits>
 4b2:	883a                	mv	a6,a4
 4b4:	2705                	addiw	a4,a4,1
 4b6:	02c5f7bb          	remuw	a5,a1,a2
 4ba:	1782                	slli	a5,a5,0x20
 4bc:	9381                	srli	a5,a5,0x20
 4be:	97aa                	add	a5,a5,a0
 4c0:	0007c783          	lbu	a5,0(a5)
 4c4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4c8:	0005879b          	sext.w	a5,a1
 4cc:	02c5d5bb          	divuw	a1,a1,a2
 4d0:	0685                	addi	a3,a3,1
 4d2:	fec7f0e3          	bgeu	a5,a2,4b2 <printint+0x2a>
  if(neg)
 4d6:	00088b63          	beqz	a7,4ec <printint+0x64>
    buf[i++] = '-';
 4da:	fd040793          	addi	a5,s0,-48
 4de:	973e                	add	a4,a4,a5
 4e0:	02d00793          	li	a5,45
 4e4:	fef70823          	sb	a5,-16(a4)
 4e8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4ec:	02e05863          	blez	a4,51c <printint+0x94>
 4f0:	fc040793          	addi	a5,s0,-64
 4f4:	00e78933          	add	s2,a5,a4
 4f8:	fff78993          	addi	s3,a5,-1
 4fc:	99ba                	add	s3,s3,a4
 4fe:	377d                	addiw	a4,a4,-1
 500:	1702                	slli	a4,a4,0x20
 502:	9301                	srli	a4,a4,0x20
 504:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 508:	fff94583          	lbu	a1,-1(s2)
 50c:	8526                	mv	a0,s1
 50e:	00000097          	auipc	ra,0x0
 512:	f58080e7          	jalr	-168(ra) # 466 <putc>
  while(--i >= 0)
 516:	197d                	addi	s2,s2,-1
 518:	ff3918e3          	bne	s2,s3,508 <printint+0x80>
}
 51c:	70e2                	ld	ra,56(sp)
 51e:	7442                	ld	s0,48(sp)
 520:	74a2                	ld	s1,40(sp)
 522:	7902                	ld	s2,32(sp)
 524:	69e2                	ld	s3,24(sp)
 526:	6121                	addi	sp,sp,64
 528:	8082                	ret
    x = -xx;
 52a:	40b005bb          	negw	a1,a1
    neg = 1;
 52e:	4885                	li	a7,1
    x = -xx;
 530:	bf8d                	j	4a2 <printint+0x1a>

0000000000000532 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 532:	7119                	addi	sp,sp,-128
 534:	fc86                	sd	ra,120(sp)
 536:	f8a2                	sd	s0,112(sp)
 538:	f4a6                	sd	s1,104(sp)
 53a:	f0ca                	sd	s2,96(sp)
 53c:	ecce                	sd	s3,88(sp)
 53e:	e8d2                	sd	s4,80(sp)
 540:	e4d6                	sd	s5,72(sp)
 542:	e0da                	sd	s6,64(sp)
 544:	fc5e                	sd	s7,56(sp)
 546:	f862                	sd	s8,48(sp)
 548:	f466                	sd	s9,40(sp)
 54a:	f06a                	sd	s10,32(sp)
 54c:	ec6e                	sd	s11,24(sp)
 54e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 550:	0005c903          	lbu	s2,0(a1)
 554:	18090f63          	beqz	s2,6f2 <vprintf+0x1c0>
 558:	8aaa                	mv	s5,a0
 55a:	8b32                	mv	s6,a2
 55c:	00158493          	addi	s1,a1,1
  state = 0;
 560:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 562:	02500a13          	li	s4,37
      if(c == 'd'){
 566:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 56a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 56e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 572:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 576:	00000b97          	auipc	s7,0x0
 57a:	3bab8b93          	addi	s7,s7,954 # 930 <digits>
 57e:	a839                	j	59c <vprintf+0x6a>
        putc(fd, c);
 580:	85ca                	mv	a1,s2
 582:	8556                	mv	a0,s5
 584:	00000097          	auipc	ra,0x0
 588:	ee2080e7          	jalr	-286(ra) # 466 <putc>
 58c:	a019                	j	592 <vprintf+0x60>
    } else if(state == '%'){
 58e:	01498f63          	beq	s3,s4,5ac <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 592:	0485                	addi	s1,s1,1
 594:	fff4c903          	lbu	s2,-1(s1)
 598:	14090d63          	beqz	s2,6f2 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 59c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5a0:	fe0997e3          	bnez	s3,58e <vprintf+0x5c>
      if(c == '%'){
 5a4:	fd479ee3          	bne	a5,s4,580 <vprintf+0x4e>
        state = '%';
 5a8:	89be                	mv	s3,a5
 5aa:	b7e5                	j	592 <vprintf+0x60>
      if(c == 'd'){
 5ac:	05878063          	beq	a5,s8,5ec <vprintf+0xba>
      } else if(c == 'l') {
 5b0:	05978c63          	beq	a5,s9,608 <vprintf+0xd6>
      } else if(c == 'x') {
 5b4:	07a78863          	beq	a5,s10,624 <vprintf+0xf2>
      } else if(c == 'p') {
 5b8:	09b78463          	beq	a5,s11,640 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5bc:	07300713          	li	a4,115
 5c0:	0ce78663          	beq	a5,a4,68c <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5c4:	06300713          	li	a4,99
 5c8:	0ee78e63          	beq	a5,a4,6c4 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5cc:	11478863          	beq	a5,s4,6dc <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5d0:	85d2                	mv	a1,s4
 5d2:	8556                	mv	a0,s5
 5d4:	00000097          	auipc	ra,0x0
 5d8:	e92080e7          	jalr	-366(ra) # 466 <putc>
        putc(fd, c);
 5dc:	85ca                	mv	a1,s2
 5de:	8556                	mv	a0,s5
 5e0:	00000097          	auipc	ra,0x0
 5e4:	e86080e7          	jalr	-378(ra) # 466 <putc>
      }
      state = 0;
 5e8:	4981                	li	s3,0
 5ea:	b765                	j	592 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5ec:	008b0913          	addi	s2,s6,8
 5f0:	4685                	li	a3,1
 5f2:	4629                	li	a2,10
 5f4:	000b2583          	lw	a1,0(s6)
 5f8:	8556                	mv	a0,s5
 5fa:	00000097          	auipc	ra,0x0
 5fe:	e8e080e7          	jalr	-370(ra) # 488 <printint>
 602:	8b4a                	mv	s6,s2
      state = 0;
 604:	4981                	li	s3,0
 606:	b771                	j	592 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 608:	008b0913          	addi	s2,s6,8
 60c:	4681                	li	a3,0
 60e:	4629                	li	a2,10
 610:	000b2583          	lw	a1,0(s6)
 614:	8556                	mv	a0,s5
 616:	00000097          	auipc	ra,0x0
 61a:	e72080e7          	jalr	-398(ra) # 488 <printint>
 61e:	8b4a                	mv	s6,s2
      state = 0;
 620:	4981                	li	s3,0
 622:	bf85                	j	592 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 624:	008b0913          	addi	s2,s6,8
 628:	4681                	li	a3,0
 62a:	4641                	li	a2,16
 62c:	000b2583          	lw	a1,0(s6)
 630:	8556                	mv	a0,s5
 632:	00000097          	auipc	ra,0x0
 636:	e56080e7          	jalr	-426(ra) # 488 <printint>
 63a:	8b4a                	mv	s6,s2
      state = 0;
 63c:	4981                	li	s3,0
 63e:	bf91                	j	592 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 640:	008b0793          	addi	a5,s6,8
 644:	f8f43423          	sd	a5,-120(s0)
 648:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 64c:	03000593          	li	a1,48
 650:	8556                	mv	a0,s5
 652:	00000097          	auipc	ra,0x0
 656:	e14080e7          	jalr	-492(ra) # 466 <putc>
  putc(fd, 'x');
 65a:	85ea                	mv	a1,s10
 65c:	8556                	mv	a0,s5
 65e:	00000097          	auipc	ra,0x0
 662:	e08080e7          	jalr	-504(ra) # 466 <putc>
 666:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 668:	03c9d793          	srli	a5,s3,0x3c
 66c:	97de                	add	a5,a5,s7
 66e:	0007c583          	lbu	a1,0(a5)
 672:	8556                	mv	a0,s5
 674:	00000097          	auipc	ra,0x0
 678:	df2080e7          	jalr	-526(ra) # 466 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 67c:	0992                	slli	s3,s3,0x4
 67e:	397d                	addiw	s2,s2,-1
 680:	fe0914e3          	bnez	s2,668 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 684:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 688:	4981                	li	s3,0
 68a:	b721                	j	592 <vprintf+0x60>
        s = va_arg(ap, char*);
 68c:	008b0993          	addi	s3,s6,8
 690:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 694:	02090163          	beqz	s2,6b6 <vprintf+0x184>
        while(*s != 0){
 698:	00094583          	lbu	a1,0(s2)
 69c:	c9a1                	beqz	a1,6ec <vprintf+0x1ba>
          putc(fd, *s);
 69e:	8556                	mv	a0,s5
 6a0:	00000097          	auipc	ra,0x0
 6a4:	dc6080e7          	jalr	-570(ra) # 466 <putc>
          s++;
 6a8:	0905                	addi	s2,s2,1
        while(*s != 0){
 6aa:	00094583          	lbu	a1,0(s2)
 6ae:	f9e5                	bnez	a1,69e <vprintf+0x16c>
        s = va_arg(ap, char*);
 6b0:	8b4e                	mv	s6,s3
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	bdf9                	j	592 <vprintf+0x60>
          s = "(null)";
 6b6:	00000917          	auipc	s2,0x0
 6ba:	27290913          	addi	s2,s2,626 # 928 <malloc+0x12c>
        while(*s != 0){
 6be:	02800593          	li	a1,40
 6c2:	bff1                	j	69e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6c4:	008b0913          	addi	s2,s6,8
 6c8:	000b4583          	lbu	a1,0(s6)
 6cc:	8556                	mv	a0,s5
 6ce:	00000097          	auipc	ra,0x0
 6d2:	d98080e7          	jalr	-616(ra) # 466 <putc>
 6d6:	8b4a                	mv	s6,s2
      state = 0;
 6d8:	4981                	li	s3,0
 6da:	bd65                	j	592 <vprintf+0x60>
        putc(fd, c);
 6dc:	85d2                	mv	a1,s4
 6de:	8556                	mv	a0,s5
 6e0:	00000097          	auipc	ra,0x0
 6e4:	d86080e7          	jalr	-634(ra) # 466 <putc>
      state = 0;
 6e8:	4981                	li	s3,0
 6ea:	b565                	j	592 <vprintf+0x60>
        s = va_arg(ap, char*);
 6ec:	8b4e                	mv	s6,s3
      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	b54d                	j	592 <vprintf+0x60>
    }
  }
}
 6f2:	70e6                	ld	ra,120(sp)
 6f4:	7446                	ld	s0,112(sp)
 6f6:	74a6                	ld	s1,104(sp)
 6f8:	7906                	ld	s2,96(sp)
 6fa:	69e6                	ld	s3,88(sp)
 6fc:	6a46                	ld	s4,80(sp)
 6fe:	6aa6                	ld	s5,72(sp)
 700:	6b06                	ld	s6,64(sp)
 702:	7be2                	ld	s7,56(sp)
 704:	7c42                	ld	s8,48(sp)
 706:	7ca2                	ld	s9,40(sp)
 708:	7d02                	ld	s10,32(sp)
 70a:	6de2                	ld	s11,24(sp)
 70c:	6109                	addi	sp,sp,128
 70e:	8082                	ret

0000000000000710 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 710:	715d                	addi	sp,sp,-80
 712:	ec06                	sd	ra,24(sp)
 714:	e822                	sd	s0,16(sp)
 716:	1000                	addi	s0,sp,32
 718:	e010                	sd	a2,0(s0)
 71a:	e414                	sd	a3,8(s0)
 71c:	e818                	sd	a4,16(s0)
 71e:	ec1c                	sd	a5,24(s0)
 720:	03043023          	sd	a6,32(s0)
 724:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 728:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 72c:	8622                	mv	a2,s0
 72e:	00000097          	auipc	ra,0x0
 732:	e04080e7          	jalr	-508(ra) # 532 <vprintf>
}
 736:	60e2                	ld	ra,24(sp)
 738:	6442                	ld	s0,16(sp)
 73a:	6161                	addi	sp,sp,80
 73c:	8082                	ret

000000000000073e <printf>:

void
printf(const char *fmt, ...)
{
 73e:	711d                	addi	sp,sp,-96
 740:	ec06                	sd	ra,24(sp)
 742:	e822                	sd	s0,16(sp)
 744:	1000                	addi	s0,sp,32
 746:	e40c                	sd	a1,8(s0)
 748:	e810                	sd	a2,16(s0)
 74a:	ec14                	sd	a3,24(s0)
 74c:	f018                	sd	a4,32(s0)
 74e:	f41c                	sd	a5,40(s0)
 750:	03043823          	sd	a6,48(s0)
 754:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 758:	00840613          	addi	a2,s0,8
 75c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 760:	85aa                	mv	a1,a0
 762:	4505                	li	a0,1
 764:	00000097          	auipc	ra,0x0
 768:	dce080e7          	jalr	-562(ra) # 532 <vprintf>
}
 76c:	60e2                	ld	ra,24(sp)
 76e:	6442                	ld	s0,16(sp)
 770:	6125                	addi	sp,sp,96
 772:	8082                	ret

0000000000000774 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 774:	1141                	addi	sp,sp,-16
 776:	e422                	sd	s0,8(sp)
 778:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 77a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 77e:	00000797          	auipc	a5,0x0
 782:	1ca7b783          	ld	a5,458(a5) # 948 <freep>
 786:	a805                	j	7b6 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 788:	4618                	lw	a4,8(a2)
 78a:	9db9                	addw	a1,a1,a4
 78c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 790:	6398                	ld	a4,0(a5)
 792:	6318                	ld	a4,0(a4)
 794:	fee53823          	sd	a4,-16(a0)
 798:	a091                	j	7dc <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 79a:	ff852703          	lw	a4,-8(a0)
 79e:	9e39                	addw	a2,a2,a4
 7a0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7a2:	ff053703          	ld	a4,-16(a0)
 7a6:	e398                	sd	a4,0(a5)
 7a8:	a099                	j	7ee <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7aa:	6398                	ld	a4,0(a5)
 7ac:	00e7e463          	bltu	a5,a4,7b4 <free+0x40>
 7b0:	00e6ea63          	bltu	a3,a4,7c4 <free+0x50>
{
 7b4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b6:	fed7fae3          	bgeu	a5,a3,7aa <free+0x36>
 7ba:	6398                	ld	a4,0(a5)
 7bc:	00e6e463          	bltu	a3,a4,7c4 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c0:	fee7eae3          	bltu	a5,a4,7b4 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7c4:	ff852583          	lw	a1,-8(a0)
 7c8:	6390                	ld	a2,0(a5)
 7ca:	02059713          	slli	a4,a1,0x20
 7ce:	9301                	srli	a4,a4,0x20
 7d0:	0712                	slli	a4,a4,0x4
 7d2:	9736                	add	a4,a4,a3
 7d4:	fae60ae3          	beq	a2,a4,788 <free+0x14>
    bp->s.ptr = p->s.ptr;
 7d8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7dc:	4790                	lw	a2,8(a5)
 7de:	02061713          	slli	a4,a2,0x20
 7e2:	9301                	srli	a4,a4,0x20
 7e4:	0712                	slli	a4,a4,0x4
 7e6:	973e                	add	a4,a4,a5
 7e8:	fae689e3          	beq	a3,a4,79a <free+0x26>
  } else
    p->s.ptr = bp;
 7ec:	e394                	sd	a3,0(a5)
  freep = p;
 7ee:	00000717          	auipc	a4,0x0
 7f2:	14f73d23          	sd	a5,346(a4) # 948 <freep>
}
 7f6:	6422                	ld	s0,8(sp)
 7f8:	0141                	addi	sp,sp,16
 7fa:	8082                	ret

00000000000007fc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7fc:	7139                	addi	sp,sp,-64
 7fe:	fc06                	sd	ra,56(sp)
 800:	f822                	sd	s0,48(sp)
 802:	f426                	sd	s1,40(sp)
 804:	f04a                	sd	s2,32(sp)
 806:	ec4e                	sd	s3,24(sp)
 808:	e852                	sd	s4,16(sp)
 80a:	e456                	sd	s5,8(sp)
 80c:	e05a                	sd	s6,0(sp)
 80e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 810:	02051493          	slli	s1,a0,0x20
 814:	9081                	srli	s1,s1,0x20
 816:	04bd                	addi	s1,s1,15
 818:	8091                	srli	s1,s1,0x4
 81a:	0014899b          	addiw	s3,s1,1
 81e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 820:	00000517          	auipc	a0,0x0
 824:	12853503          	ld	a0,296(a0) # 948 <freep>
 828:	c515                	beqz	a0,854 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 82a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 82c:	4798                	lw	a4,8(a5)
 82e:	02977f63          	bgeu	a4,s1,86c <malloc+0x70>
 832:	8a4e                	mv	s4,s3
 834:	0009871b          	sext.w	a4,s3
 838:	6685                	lui	a3,0x1
 83a:	00d77363          	bgeu	a4,a3,840 <malloc+0x44>
 83e:	6a05                	lui	s4,0x1
 840:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 844:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 848:	00000917          	auipc	s2,0x0
 84c:	10090913          	addi	s2,s2,256 # 948 <freep>
  if(p == (char*)-1)
 850:	5afd                	li	s5,-1
 852:	a88d                	j	8c4 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 854:	00000797          	auipc	a5,0x0
 858:	2fc78793          	addi	a5,a5,764 # b50 <base>
 85c:	00000717          	auipc	a4,0x0
 860:	0ef73623          	sd	a5,236(a4) # 948 <freep>
 864:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 866:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 86a:	b7e1                	j	832 <malloc+0x36>
      if(p->s.size == nunits)
 86c:	02e48b63          	beq	s1,a4,8a2 <malloc+0xa6>
        p->s.size -= nunits;
 870:	4137073b          	subw	a4,a4,s3
 874:	c798                	sw	a4,8(a5)
        p += p->s.size;
 876:	1702                	slli	a4,a4,0x20
 878:	9301                	srli	a4,a4,0x20
 87a:	0712                	slli	a4,a4,0x4
 87c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 87e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 882:	00000717          	auipc	a4,0x0
 886:	0ca73323          	sd	a0,198(a4) # 948 <freep>
      return (void*)(p + 1);
 88a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 88e:	70e2                	ld	ra,56(sp)
 890:	7442                	ld	s0,48(sp)
 892:	74a2                	ld	s1,40(sp)
 894:	7902                	ld	s2,32(sp)
 896:	69e2                	ld	s3,24(sp)
 898:	6a42                	ld	s4,16(sp)
 89a:	6aa2                	ld	s5,8(sp)
 89c:	6b02                	ld	s6,0(sp)
 89e:	6121                	addi	sp,sp,64
 8a0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8a2:	6398                	ld	a4,0(a5)
 8a4:	e118                	sd	a4,0(a0)
 8a6:	bff1                	j	882 <malloc+0x86>
  hp->s.size = nu;
 8a8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8ac:	0541                	addi	a0,a0,16
 8ae:	00000097          	auipc	ra,0x0
 8b2:	ec6080e7          	jalr	-314(ra) # 774 <free>
  return freep;
 8b6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8ba:	d971                	beqz	a0,88e <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8bc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8be:	4798                	lw	a4,8(a5)
 8c0:	fa9776e3          	bgeu	a4,s1,86c <malloc+0x70>
    if(p == freep)
 8c4:	00093703          	ld	a4,0(s2)
 8c8:	853e                	mv	a0,a5
 8ca:	fef719e3          	bne	a4,a5,8bc <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8ce:	8552                	mv	a0,s4
 8d0:	00000097          	auipc	ra,0x0
 8d4:	b46080e7          	jalr	-1210(ra) # 416 <sbrk>
  if(p == (char*)-1)
 8d8:	fd5518e3          	bne	a0,s5,8a8 <malloc+0xac>
        return 0;
 8dc:	4501                	li	a0,0
 8de:	bf45                	j	88e <malloc+0x92>
