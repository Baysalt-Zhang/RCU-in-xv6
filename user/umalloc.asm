
user/_umalloc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
   6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
   a:	00000797          	auipc	a5,0x0
   e:	7b67b783          	ld	a5,1974(a5) # 7c0 <freep>
  12:	a805                	j	42 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
  14:	4618                	lw	a4,8(a2)
  16:	9db9                	addw	a1,a1,a4
  18:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
  1c:	6398                	ld	a4,0(a5)
  1e:	6318                	ld	a4,0(a4)
  20:	fee53823          	sd	a4,-16(a0)
  24:	a091                	j	68 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
  26:	ff852703          	lw	a4,-8(a0)
  2a:	9e39                	addw	a2,a2,a4
  2c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
  2e:	ff053703          	ld	a4,-16(a0)
  32:	e398                	sd	a4,0(a5)
  34:	a099                	j	7a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
  36:	6398                	ld	a4,0(a5)
  38:	00e7e463          	bltu	a5,a4,40 <free+0x40>
  3c:	00e6ea63          	bltu	a3,a4,50 <free+0x50>
{
  40:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
  42:	fed7fae3          	bgeu	a5,a3,36 <free+0x36>
  46:	6398                	ld	a4,0(a5)
  48:	00e6e463          	bltu	a3,a4,50 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
  4c:	fee7eae3          	bltu	a5,a4,40 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
  50:	ff852583          	lw	a1,-8(a0)
  54:	6390                	ld	a2,0(a5)
  56:	02059713          	slli	a4,a1,0x20
  5a:	9301                	srli	a4,a4,0x20
  5c:	0712                	slli	a4,a4,0x4
  5e:	9736                	add	a4,a4,a3
  60:	fae60ae3          	beq	a2,a4,14 <free+0x14>
    bp->s.ptr = p->s.ptr;
  64:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
  68:	4790                	lw	a2,8(a5)
  6a:	02061713          	slli	a4,a2,0x20
  6e:	9301                	srli	a4,a4,0x20
  70:	0712                	slli	a4,a4,0x4
  72:	973e                	add	a4,a4,a5
  74:	fae689e3          	beq	a3,a4,26 <free+0x26>
  } else
    p->s.ptr = bp;
  78:	e394                	sd	a3,0(a5)
  freep = p;
  7a:	00000717          	auipc	a4,0x0
  7e:	74f73323          	sd	a5,1862(a4) # 7c0 <freep>
}
  82:	6422                	ld	s0,8(sp)
  84:	0141                	addi	sp,sp,16
  86:	8082                	ret

0000000000000088 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
  88:	7139                	addi	sp,sp,-64
  8a:	fc06                	sd	ra,56(sp)
  8c:	f822                	sd	s0,48(sp)
  8e:	f426                	sd	s1,40(sp)
  90:	f04a                	sd	s2,32(sp)
  92:	ec4e                	sd	s3,24(sp)
  94:	e852                	sd	s4,16(sp)
  96:	e456                	sd	s5,8(sp)
  98:	e05a                	sd	s6,0(sp)
  9a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  9c:	02051493          	slli	s1,a0,0x20
  a0:	9081                	srli	s1,s1,0x20
  a2:	04bd                	addi	s1,s1,15
  a4:	8091                	srli	s1,s1,0x4
  a6:	0014899b          	addiw	s3,s1,1
  aa:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
  ac:	00000517          	auipc	a0,0x0
  b0:	71453503          	ld	a0,1812(a0) # 7c0 <freep>
  b4:	c515                	beqz	a0,e0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
  b6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
  b8:	4798                	lw	a4,8(a5)
  ba:	02977f63          	bgeu	a4,s1,f8 <malloc+0x70>
  be:	8a4e                	mv	s4,s3
  c0:	0009871b          	sext.w	a4,s3
  c4:	6685                	lui	a3,0x1
  c6:	00d77363          	bgeu	a4,a3,cc <malloc+0x44>
  ca:	6a05                	lui	s4,0x1
  cc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
  d0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
  d4:	00000917          	auipc	s2,0x0
  d8:	6ec90913          	addi	s2,s2,1772 # 7c0 <freep>
  if(p == (char*)-1)
  dc:	5afd                	li	s5,-1
  de:	a88d                	j	150 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
  e0:	00000797          	auipc	a5,0x0
  e4:	6e878793          	addi	a5,a5,1768 # 7c8 <base>
  e8:	00000717          	auipc	a4,0x0
  ec:	6cf73c23          	sd	a5,1752(a4) # 7c0 <freep>
  f0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
  f2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
  f6:	b7e1                	j	be <malloc+0x36>
      if(p->s.size == nunits)
  f8:	02e48b63          	beq	s1,a4,12e <malloc+0xa6>
        p->s.size -= nunits;
  fc:	4137073b          	subw	a4,a4,s3
 100:	c798                	sw	a4,8(a5)
        p += p->s.size;
 102:	1702                	slli	a4,a4,0x20
 104:	9301                	srli	a4,a4,0x20
 106:	0712                	slli	a4,a4,0x4
 108:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 10a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 10e:	00000717          	auipc	a4,0x0
 112:	6aa73923          	sd	a0,1714(a4) # 7c0 <freep>
      return (void*)(p + 1);
 116:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 11a:	70e2                	ld	ra,56(sp)
 11c:	7442                	ld	s0,48(sp)
 11e:	74a2                	ld	s1,40(sp)
 120:	7902                	ld	s2,32(sp)
 122:	69e2                	ld	s3,24(sp)
 124:	6a42                	ld	s4,16(sp)
 126:	6aa2                	ld	s5,8(sp)
 128:	6b02                	ld	s6,0(sp)
 12a:	6121                	addi	sp,sp,64
 12c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 12e:	6398                	ld	a4,0(a5)
 130:	e118                	sd	a4,0(a0)
 132:	bff1                	j	10e <malloc+0x86>
  hp->s.size = nu;
 134:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 138:	0541                	addi	a0,a0,16
 13a:	00000097          	auipc	ra,0x0
 13e:	ec6080e7          	jalr	-314(ra) # 0 <free>
  return freep;
 142:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 146:	d971                	beqz	a0,11a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 148:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 14a:	4798                	lw	a4,8(a5)
 14c:	fa9776e3          	bgeu	a4,s1,f8 <malloc+0x70>
    if(p == freep)
 150:	00093703          	ld	a4,0(s2)
 154:	853e                	mv	a0,a5
 156:	fef719e3          	bne	a4,a5,148 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 15a:	8552                	mv	a0,s4
 15c:	00000097          	auipc	ra,0x0
 160:	30e080e7          	jalr	782(ra) # 46a <sbrk>
  if(p == (char*)-1)
 164:	fd5518e3          	bne	a0,s5,134 <malloc+0xac>
        return 0;
 168:	4501                	li	a0,0
 16a:	bf45                	j	11a <malloc+0x92>

000000000000016c <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 16c:	1141                	addi	sp,sp,-16
 16e:	e422                	sd	s0,8(sp)
 170:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 172:	87aa                	mv	a5,a0
 174:	0585                	addi	a1,a1,1
 176:	0785                	addi	a5,a5,1
 178:	fff5c703          	lbu	a4,-1(a1)
 17c:	fee78fa3          	sb	a4,-1(a5)
 180:	fb75                	bnez	a4,174 <strcpy+0x8>
    ;
  return os;
}
 182:	6422                	ld	s0,8(sp)
 184:	0141                	addi	sp,sp,16
 186:	8082                	ret

0000000000000188 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 188:	1141                	addi	sp,sp,-16
 18a:	e422                	sd	s0,8(sp)
 18c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 18e:	00054783          	lbu	a5,0(a0)
 192:	cb91                	beqz	a5,1a6 <strcmp+0x1e>
 194:	0005c703          	lbu	a4,0(a1)
 198:	00f71763          	bne	a4,a5,1a6 <strcmp+0x1e>
    p++, q++;
 19c:	0505                	addi	a0,a0,1
 19e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1a0:	00054783          	lbu	a5,0(a0)
 1a4:	fbe5                	bnez	a5,194 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1a6:	0005c503          	lbu	a0,0(a1)
}
 1aa:	40a7853b          	subw	a0,a5,a0
 1ae:	6422                	ld	s0,8(sp)
 1b0:	0141                	addi	sp,sp,16
 1b2:	8082                	ret

00000000000001b4 <strlen>:

uint
strlen(const char *s)
{
 1b4:	1141                	addi	sp,sp,-16
 1b6:	e422                	sd	s0,8(sp)
 1b8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ba:	00054783          	lbu	a5,0(a0)
 1be:	cf91                	beqz	a5,1da <strlen+0x26>
 1c0:	0505                	addi	a0,a0,1
 1c2:	87aa                	mv	a5,a0
 1c4:	4685                	li	a3,1
 1c6:	9e89                	subw	a3,a3,a0
 1c8:	00f6853b          	addw	a0,a3,a5
 1cc:	0785                	addi	a5,a5,1
 1ce:	fff7c703          	lbu	a4,-1(a5)
 1d2:	fb7d                	bnez	a4,1c8 <strlen+0x14>
    ;
  return n;
}
 1d4:	6422                	ld	s0,8(sp)
 1d6:	0141                	addi	sp,sp,16
 1d8:	8082                	ret
  for(n = 0; s[n]; n++)
 1da:	4501                	li	a0,0
 1dc:	bfe5                	j	1d4 <strlen+0x20>

00000000000001de <memset>:

void*
memset(void *dst, int c, uint n)
{
 1de:	1141                	addi	sp,sp,-16
 1e0:	e422                	sd	s0,8(sp)
 1e2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1e4:	ce09                	beqz	a2,1fe <memset+0x20>
 1e6:	87aa                	mv	a5,a0
 1e8:	fff6071b          	addiw	a4,a2,-1
 1ec:	1702                	slli	a4,a4,0x20
 1ee:	9301                	srli	a4,a4,0x20
 1f0:	0705                	addi	a4,a4,1
 1f2:	972a                	add	a4,a4,a0
    cdst[i] = c;
 1f4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1f8:	0785                	addi	a5,a5,1
 1fa:	fee79de3          	bne	a5,a4,1f4 <memset+0x16>
  }
  return dst;
}
 1fe:	6422                	ld	s0,8(sp)
 200:	0141                	addi	sp,sp,16
 202:	8082                	ret

0000000000000204 <strchr>:

char*
strchr(const char *s, char c)
{
 204:	1141                	addi	sp,sp,-16
 206:	e422                	sd	s0,8(sp)
 208:	0800                	addi	s0,sp,16
  for(; *s; s++)
 20a:	00054783          	lbu	a5,0(a0)
 20e:	cb99                	beqz	a5,224 <strchr+0x20>
    if(*s == c)
 210:	00f58763          	beq	a1,a5,21e <strchr+0x1a>
  for(; *s; s++)
 214:	0505                	addi	a0,a0,1
 216:	00054783          	lbu	a5,0(a0)
 21a:	fbfd                	bnez	a5,210 <strchr+0xc>
      return (char*)s;
  return 0;
 21c:	4501                	li	a0,0
}
 21e:	6422                	ld	s0,8(sp)
 220:	0141                	addi	sp,sp,16
 222:	8082                	ret
  return 0;
 224:	4501                	li	a0,0
 226:	bfe5                	j	21e <strchr+0x1a>

0000000000000228 <gets>:

char*
gets(char *buf, int max)
{
 228:	711d                	addi	sp,sp,-96
 22a:	ec86                	sd	ra,88(sp)
 22c:	e8a2                	sd	s0,80(sp)
 22e:	e4a6                	sd	s1,72(sp)
 230:	e0ca                	sd	s2,64(sp)
 232:	fc4e                	sd	s3,56(sp)
 234:	f852                	sd	s4,48(sp)
 236:	f456                	sd	s5,40(sp)
 238:	f05a                	sd	s6,32(sp)
 23a:	ec5e                	sd	s7,24(sp)
 23c:	1080                	addi	s0,sp,96
 23e:	8baa                	mv	s7,a0
 240:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 242:	892a                	mv	s2,a0
 244:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 246:	4aa9                	li	s5,10
 248:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 24a:	89a6                	mv	s3,s1
 24c:	2485                	addiw	s1,s1,1
 24e:	0344d863          	bge	s1,s4,27e <gets+0x56>
    cc = read(0, &c, 1);
 252:	4605                	li	a2,1
 254:	faf40593          	addi	a1,s0,-81
 258:	4501                	li	a0,0
 25a:	00000097          	auipc	ra,0x0
 25e:	1a0080e7          	jalr	416(ra) # 3fa <read>
    if(cc < 1)
 262:	00a05e63          	blez	a0,27e <gets+0x56>
    buf[i++] = c;
 266:	faf44783          	lbu	a5,-81(s0)
 26a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 26e:	01578763          	beq	a5,s5,27c <gets+0x54>
 272:	0905                	addi	s2,s2,1
 274:	fd679be3          	bne	a5,s6,24a <gets+0x22>
  for(i=0; i+1 < max; ){
 278:	89a6                	mv	s3,s1
 27a:	a011                	j	27e <gets+0x56>
 27c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 27e:	99de                	add	s3,s3,s7
 280:	00098023          	sb	zero,0(s3)
  return buf;
}
 284:	855e                	mv	a0,s7
 286:	60e6                	ld	ra,88(sp)
 288:	6446                	ld	s0,80(sp)
 28a:	64a6                	ld	s1,72(sp)
 28c:	6906                	ld	s2,64(sp)
 28e:	79e2                	ld	s3,56(sp)
 290:	7a42                	ld	s4,48(sp)
 292:	7aa2                	ld	s5,40(sp)
 294:	7b02                	ld	s6,32(sp)
 296:	6be2                	ld	s7,24(sp)
 298:	6125                	addi	sp,sp,96
 29a:	8082                	ret

000000000000029c <stat>:

int
stat(const char *n, struct stat *st)
{
 29c:	1101                	addi	sp,sp,-32
 29e:	ec06                	sd	ra,24(sp)
 2a0:	e822                	sd	s0,16(sp)
 2a2:	e426                	sd	s1,8(sp)
 2a4:	e04a                	sd	s2,0(sp)
 2a6:	1000                	addi	s0,sp,32
 2a8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2aa:	4581                	li	a1,0
 2ac:	00000097          	auipc	ra,0x0
 2b0:	176080e7          	jalr	374(ra) # 422 <open>
  if(fd < 0)
 2b4:	02054563          	bltz	a0,2de <stat+0x42>
 2b8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2ba:	85ca                	mv	a1,s2
 2bc:	00000097          	auipc	ra,0x0
 2c0:	17e080e7          	jalr	382(ra) # 43a <fstat>
 2c4:	892a                	mv	s2,a0
  close(fd);
 2c6:	8526                	mv	a0,s1
 2c8:	00000097          	auipc	ra,0x0
 2cc:	142080e7          	jalr	322(ra) # 40a <close>
  return r;
}
 2d0:	854a                	mv	a0,s2
 2d2:	60e2                	ld	ra,24(sp)
 2d4:	6442                	ld	s0,16(sp)
 2d6:	64a2                	ld	s1,8(sp)
 2d8:	6902                	ld	s2,0(sp)
 2da:	6105                	addi	sp,sp,32
 2dc:	8082                	ret
    return -1;
 2de:	597d                	li	s2,-1
 2e0:	bfc5                	j	2d0 <stat+0x34>

00000000000002e2 <atoi>:

int
atoi(const char *s)
{
 2e2:	1141                	addi	sp,sp,-16
 2e4:	e422                	sd	s0,8(sp)
 2e6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2e8:	00054603          	lbu	a2,0(a0)
 2ec:	fd06079b          	addiw	a5,a2,-48
 2f0:	0ff7f793          	andi	a5,a5,255
 2f4:	4725                	li	a4,9
 2f6:	02f76963          	bltu	a4,a5,328 <atoi+0x46>
 2fa:	86aa                	mv	a3,a0
  n = 0;
 2fc:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2fe:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 300:	0685                	addi	a3,a3,1
 302:	0025179b          	slliw	a5,a0,0x2
 306:	9fa9                	addw	a5,a5,a0
 308:	0017979b          	slliw	a5,a5,0x1
 30c:	9fb1                	addw	a5,a5,a2
 30e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 312:	0006c603          	lbu	a2,0(a3) # 1000 <__global_pointer$+0x47>
 316:	fd06071b          	addiw	a4,a2,-48
 31a:	0ff77713          	andi	a4,a4,255
 31e:	fee5f1e3          	bgeu	a1,a4,300 <atoi+0x1e>
  return n;
}
 322:	6422                	ld	s0,8(sp)
 324:	0141                	addi	sp,sp,16
 326:	8082                	ret
  n = 0;
 328:	4501                	li	a0,0
 32a:	bfe5                	j	322 <atoi+0x40>

000000000000032c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 32c:	1141                	addi	sp,sp,-16
 32e:	e422                	sd	s0,8(sp)
 330:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 332:	02b57663          	bgeu	a0,a1,35e <memmove+0x32>
    while(n-- > 0)
 336:	02c05163          	blez	a2,358 <memmove+0x2c>
 33a:	fff6079b          	addiw	a5,a2,-1
 33e:	1782                	slli	a5,a5,0x20
 340:	9381                	srli	a5,a5,0x20
 342:	0785                	addi	a5,a5,1
 344:	97aa                	add	a5,a5,a0
  dst = vdst;
 346:	872a                	mv	a4,a0
      *dst++ = *src++;
 348:	0585                	addi	a1,a1,1
 34a:	0705                	addi	a4,a4,1
 34c:	fff5c683          	lbu	a3,-1(a1)
 350:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 354:	fee79ae3          	bne	a5,a4,348 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 358:	6422                	ld	s0,8(sp)
 35a:	0141                	addi	sp,sp,16
 35c:	8082                	ret
    dst += n;
 35e:	00c50733          	add	a4,a0,a2
    src += n;
 362:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 364:	fec05ae3          	blez	a2,358 <memmove+0x2c>
 368:	fff6079b          	addiw	a5,a2,-1
 36c:	1782                	slli	a5,a5,0x20
 36e:	9381                	srli	a5,a5,0x20
 370:	fff7c793          	not	a5,a5
 374:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 376:	15fd                	addi	a1,a1,-1
 378:	177d                	addi	a4,a4,-1
 37a:	0005c683          	lbu	a3,0(a1)
 37e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 382:	fee79ae3          	bne	a5,a4,376 <memmove+0x4a>
 386:	bfc9                	j	358 <memmove+0x2c>

0000000000000388 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 388:	1141                	addi	sp,sp,-16
 38a:	e422                	sd	s0,8(sp)
 38c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 38e:	ca05                	beqz	a2,3be <memcmp+0x36>
 390:	fff6069b          	addiw	a3,a2,-1
 394:	1682                	slli	a3,a3,0x20
 396:	9281                	srli	a3,a3,0x20
 398:	0685                	addi	a3,a3,1
 39a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 39c:	00054783          	lbu	a5,0(a0)
 3a0:	0005c703          	lbu	a4,0(a1)
 3a4:	00e79863          	bne	a5,a4,3b4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3a8:	0505                	addi	a0,a0,1
    p2++;
 3aa:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3ac:	fed518e3          	bne	a0,a3,39c <memcmp+0x14>
  }
  return 0;
 3b0:	4501                	li	a0,0
 3b2:	a019                	j	3b8 <memcmp+0x30>
      return *p1 - *p2;
 3b4:	40e7853b          	subw	a0,a5,a4
}
 3b8:	6422                	ld	s0,8(sp)
 3ba:	0141                	addi	sp,sp,16
 3bc:	8082                	ret
  return 0;
 3be:	4501                	li	a0,0
 3c0:	bfe5                	j	3b8 <memcmp+0x30>

00000000000003c2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3c2:	1141                	addi	sp,sp,-16
 3c4:	e406                	sd	ra,8(sp)
 3c6:	e022                	sd	s0,0(sp)
 3c8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3ca:	00000097          	auipc	ra,0x0
 3ce:	f62080e7          	jalr	-158(ra) # 32c <memmove>
}
 3d2:	60a2                	ld	ra,8(sp)
 3d4:	6402                	ld	s0,0(sp)
 3d6:	0141                	addi	sp,sp,16
 3d8:	8082                	ret

00000000000003da <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3da:	4885                	li	a7,1
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3e2:	4889                	li	a7,2
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <wait>:
.global wait
wait:
 li a7, SYS_wait
 3ea:	488d                	li	a7,3
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3f2:	4891                	li	a7,4
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <read>:
.global read
read:
 li a7, SYS_read
 3fa:	4895                	li	a7,5
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <write>:
.global write
write:
 li a7, SYS_write
 402:	48c1                	li	a7,16
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <close>:
.global close
close:
 li a7, SYS_close
 40a:	48d5                	li	a7,21
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <kill>:
.global kill
kill:
 li a7, SYS_kill
 412:	4899                	li	a7,6
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <exec>:
.global exec
exec:
 li a7, SYS_exec
 41a:	489d                	li	a7,7
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <open>:
.global open
open:
 li a7, SYS_open
 422:	48bd                	li	a7,15
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 42a:	48c5                	li	a7,17
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 432:	48c9                	li	a7,18
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 43a:	48a1                	li	a7,8
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <link>:
.global link
link:
 li a7, SYS_link
 442:	48cd                	li	a7,19
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 44a:	48d1                	li	a7,20
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 452:	48a5                	li	a7,9
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <dup>:
.global dup
dup:
 li a7, SYS_dup
 45a:	48a9                	li	a7,10
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 462:	48ad                	li	a7,11
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 46a:	48b1                	li	a7,12
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 472:	48b5                	li	a7,13
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 47a:	48b9                	li	a7,14
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 482:	48d9                	li	a7,22
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <nfree>:
.global nfree
nfree:
 li a7, SYS_nfree
 48a:	48dd                	li	a7,23
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 492:	1101                	addi	sp,sp,-32
 494:	ec06                	sd	ra,24(sp)
 496:	e822                	sd	s0,16(sp)
 498:	1000                	addi	s0,sp,32
 49a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 49e:	4605                	li	a2,1
 4a0:	fef40593          	addi	a1,s0,-17
 4a4:	00000097          	auipc	ra,0x0
 4a8:	f5e080e7          	jalr	-162(ra) # 402 <write>
}
 4ac:	60e2                	ld	ra,24(sp)
 4ae:	6442                	ld	s0,16(sp)
 4b0:	6105                	addi	sp,sp,32
 4b2:	8082                	ret

00000000000004b4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4b4:	7139                	addi	sp,sp,-64
 4b6:	fc06                	sd	ra,56(sp)
 4b8:	f822                	sd	s0,48(sp)
 4ba:	f426                	sd	s1,40(sp)
 4bc:	f04a                	sd	s2,32(sp)
 4be:	ec4e                	sd	s3,24(sp)
 4c0:	0080                	addi	s0,sp,64
 4c2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4c4:	c299                	beqz	a3,4ca <printint+0x16>
 4c6:	0805c863          	bltz	a1,556 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4ca:	2581                	sext.w	a1,a1
  neg = 0;
 4cc:	4881                	li	a7,0
 4ce:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4d2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4d4:	2601                	sext.w	a2,a2
 4d6:	00000517          	auipc	a0,0x0
 4da:	2d250513          	addi	a0,a0,722 # 7a8 <digits>
 4de:	883a                	mv	a6,a4
 4e0:	2705                	addiw	a4,a4,1
 4e2:	02c5f7bb          	remuw	a5,a1,a2
 4e6:	1782                	slli	a5,a5,0x20
 4e8:	9381                	srli	a5,a5,0x20
 4ea:	97aa                	add	a5,a5,a0
 4ec:	0007c783          	lbu	a5,0(a5)
 4f0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4f4:	0005879b          	sext.w	a5,a1
 4f8:	02c5d5bb          	divuw	a1,a1,a2
 4fc:	0685                	addi	a3,a3,1
 4fe:	fec7f0e3          	bgeu	a5,a2,4de <printint+0x2a>
  if(neg)
 502:	00088b63          	beqz	a7,518 <printint+0x64>
    buf[i++] = '-';
 506:	fd040793          	addi	a5,s0,-48
 50a:	973e                	add	a4,a4,a5
 50c:	02d00793          	li	a5,45
 510:	fef70823          	sb	a5,-16(a4)
 514:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 518:	02e05863          	blez	a4,548 <printint+0x94>
 51c:	fc040793          	addi	a5,s0,-64
 520:	00e78933          	add	s2,a5,a4
 524:	fff78993          	addi	s3,a5,-1
 528:	99ba                	add	s3,s3,a4
 52a:	377d                	addiw	a4,a4,-1
 52c:	1702                	slli	a4,a4,0x20
 52e:	9301                	srli	a4,a4,0x20
 530:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 534:	fff94583          	lbu	a1,-1(s2)
 538:	8526                	mv	a0,s1
 53a:	00000097          	auipc	ra,0x0
 53e:	f58080e7          	jalr	-168(ra) # 492 <putc>
  while(--i >= 0)
 542:	197d                	addi	s2,s2,-1
 544:	ff3918e3          	bne	s2,s3,534 <printint+0x80>
}
 548:	70e2                	ld	ra,56(sp)
 54a:	7442                	ld	s0,48(sp)
 54c:	74a2                	ld	s1,40(sp)
 54e:	7902                	ld	s2,32(sp)
 550:	69e2                	ld	s3,24(sp)
 552:	6121                	addi	sp,sp,64
 554:	8082                	ret
    x = -xx;
 556:	40b005bb          	negw	a1,a1
    neg = 1;
 55a:	4885                	li	a7,1
    x = -xx;
 55c:	bf8d                	j	4ce <printint+0x1a>

000000000000055e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 55e:	7119                	addi	sp,sp,-128
 560:	fc86                	sd	ra,120(sp)
 562:	f8a2                	sd	s0,112(sp)
 564:	f4a6                	sd	s1,104(sp)
 566:	f0ca                	sd	s2,96(sp)
 568:	ecce                	sd	s3,88(sp)
 56a:	e8d2                	sd	s4,80(sp)
 56c:	e4d6                	sd	s5,72(sp)
 56e:	e0da                	sd	s6,64(sp)
 570:	fc5e                	sd	s7,56(sp)
 572:	f862                	sd	s8,48(sp)
 574:	f466                	sd	s9,40(sp)
 576:	f06a                	sd	s10,32(sp)
 578:	ec6e                	sd	s11,24(sp)
 57a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 57c:	0005c903          	lbu	s2,0(a1)
 580:	18090f63          	beqz	s2,71e <vprintf+0x1c0>
 584:	8aaa                	mv	s5,a0
 586:	8b32                	mv	s6,a2
 588:	00158493          	addi	s1,a1,1
  state = 0;
 58c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 58e:	02500a13          	li	s4,37
      if(c == 'd'){
 592:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 596:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 59a:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 59e:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5a2:	00000b97          	auipc	s7,0x0
 5a6:	206b8b93          	addi	s7,s7,518 # 7a8 <digits>
 5aa:	a839                	j	5c8 <vprintf+0x6a>
        putc(fd, c);
 5ac:	85ca                	mv	a1,s2
 5ae:	8556                	mv	a0,s5
 5b0:	00000097          	auipc	ra,0x0
 5b4:	ee2080e7          	jalr	-286(ra) # 492 <putc>
 5b8:	a019                	j	5be <vprintf+0x60>
    } else if(state == '%'){
 5ba:	01498f63          	beq	s3,s4,5d8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5be:	0485                	addi	s1,s1,1
 5c0:	fff4c903          	lbu	s2,-1(s1)
 5c4:	14090d63          	beqz	s2,71e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5c8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5cc:	fe0997e3          	bnez	s3,5ba <vprintf+0x5c>
      if(c == '%'){
 5d0:	fd479ee3          	bne	a5,s4,5ac <vprintf+0x4e>
        state = '%';
 5d4:	89be                	mv	s3,a5
 5d6:	b7e5                	j	5be <vprintf+0x60>
      if(c == 'd'){
 5d8:	05878063          	beq	a5,s8,618 <vprintf+0xba>
      } else if(c == 'l') {
 5dc:	05978c63          	beq	a5,s9,634 <vprintf+0xd6>
      } else if(c == 'x') {
 5e0:	07a78863          	beq	a5,s10,650 <vprintf+0xf2>
      } else if(c == 'p') {
 5e4:	09b78463          	beq	a5,s11,66c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5e8:	07300713          	li	a4,115
 5ec:	0ce78663          	beq	a5,a4,6b8 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5f0:	06300713          	li	a4,99
 5f4:	0ee78e63          	beq	a5,a4,6f0 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5f8:	11478863          	beq	a5,s4,708 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5fc:	85d2                	mv	a1,s4
 5fe:	8556                	mv	a0,s5
 600:	00000097          	auipc	ra,0x0
 604:	e92080e7          	jalr	-366(ra) # 492 <putc>
        putc(fd, c);
 608:	85ca                	mv	a1,s2
 60a:	8556                	mv	a0,s5
 60c:	00000097          	auipc	ra,0x0
 610:	e86080e7          	jalr	-378(ra) # 492 <putc>
      }
      state = 0;
 614:	4981                	li	s3,0
 616:	b765                	j	5be <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 618:	008b0913          	addi	s2,s6,8
 61c:	4685                	li	a3,1
 61e:	4629                	li	a2,10
 620:	000b2583          	lw	a1,0(s6)
 624:	8556                	mv	a0,s5
 626:	00000097          	auipc	ra,0x0
 62a:	e8e080e7          	jalr	-370(ra) # 4b4 <printint>
 62e:	8b4a                	mv	s6,s2
      state = 0;
 630:	4981                	li	s3,0
 632:	b771                	j	5be <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 634:	008b0913          	addi	s2,s6,8
 638:	4681                	li	a3,0
 63a:	4629                	li	a2,10
 63c:	000b2583          	lw	a1,0(s6)
 640:	8556                	mv	a0,s5
 642:	00000097          	auipc	ra,0x0
 646:	e72080e7          	jalr	-398(ra) # 4b4 <printint>
 64a:	8b4a                	mv	s6,s2
      state = 0;
 64c:	4981                	li	s3,0
 64e:	bf85                	j	5be <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 650:	008b0913          	addi	s2,s6,8
 654:	4681                	li	a3,0
 656:	4641                	li	a2,16
 658:	000b2583          	lw	a1,0(s6)
 65c:	8556                	mv	a0,s5
 65e:	00000097          	auipc	ra,0x0
 662:	e56080e7          	jalr	-426(ra) # 4b4 <printint>
 666:	8b4a                	mv	s6,s2
      state = 0;
 668:	4981                	li	s3,0
 66a:	bf91                	j	5be <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 66c:	008b0793          	addi	a5,s6,8
 670:	f8f43423          	sd	a5,-120(s0)
 674:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 678:	03000593          	li	a1,48
 67c:	8556                	mv	a0,s5
 67e:	00000097          	auipc	ra,0x0
 682:	e14080e7          	jalr	-492(ra) # 492 <putc>
  putc(fd, 'x');
 686:	85ea                	mv	a1,s10
 688:	8556                	mv	a0,s5
 68a:	00000097          	auipc	ra,0x0
 68e:	e08080e7          	jalr	-504(ra) # 492 <putc>
 692:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 694:	03c9d793          	srli	a5,s3,0x3c
 698:	97de                	add	a5,a5,s7
 69a:	0007c583          	lbu	a1,0(a5)
 69e:	8556                	mv	a0,s5
 6a0:	00000097          	auipc	ra,0x0
 6a4:	df2080e7          	jalr	-526(ra) # 492 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6a8:	0992                	slli	s3,s3,0x4
 6aa:	397d                	addiw	s2,s2,-1
 6ac:	fe0914e3          	bnez	s2,694 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6b0:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6b4:	4981                	li	s3,0
 6b6:	b721                	j	5be <vprintf+0x60>
        s = va_arg(ap, char*);
 6b8:	008b0993          	addi	s3,s6,8
 6bc:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6c0:	02090163          	beqz	s2,6e2 <vprintf+0x184>
        while(*s != 0){
 6c4:	00094583          	lbu	a1,0(s2)
 6c8:	c9a1                	beqz	a1,718 <vprintf+0x1ba>
          putc(fd, *s);
 6ca:	8556                	mv	a0,s5
 6cc:	00000097          	auipc	ra,0x0
 6d0:	dc6080e7          	jalr	-570(ra) # 492 <putc>
          s++;
 6d4:	0905                	addi	s2,s2,1
        while(*s != 0){
 6d6:	00094583          	lbu	a1,0(s2)
 6da:	f9e5                	bnez	a1,6ca <vprintf+0x16c>
        s = va_arg(ap, char*);
 6dc:	8b4e                	mv	s6,s3
      state = 0;
 6de:	4981                	li	s3,0
 6e0:	bdf9                	j	5be <vprintf+0x60>
          s = "(null)";
 6e2:	00000917          	auipc	s2,0x0
 6e6:	0be90913          	addi	s2,s2,190 # 7a0 <printf+0x36>
        while(*s != 0){
 6ea:	02800593          	li	a1,40
 6ee:	bff1                	j	6ca <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6f0:	008b0913          	addi	s2,s6,8
 6f4:	000b4583          	lbu	a1,0(s6)
 6f8:	8556                	mv	a0,s5
 6fa:	00000097          	auipc	ra,0x0
 6fe:	d98080e7          	jalr	-616(ra) # 492 <putc>
 702:	8b4a                	mv	s6,s2
      state = 0;
 704:	4981                	li	s3,0
 706:	bd65                	j	5be <vprintf+0x60>
        putc(fd, c);
 708:	85d2                	mv	a1,s4
 70a:	8556                	mv	a0,s5
 70c:	00000097          	auipc	ra,0x0
 710:	d86080e7          	jalr	-634(ra) # 492 <putc>
      state = 0;
 714:	4981                	li	s3,0
 716:	b565                	j	5be <vprintf+0x60>
        s = va_arg(ap, char*);
 718:	8b4e                	mv	s6,s3
      state = 0;
 71a:	4981                	li	s3,0
 71c:	b54d                	j	5be <vprintf+0x60>
    }
  }
}
 71e:	70e6                	ld	ra,120(sp)
 720:	7446                	ld	s0,112(sp)
 722:	74a6                	ld	s1,104(sp)
 724:	7906                	ld	s2,96(sp)
 726:	69e6                	ld	s3,88(sp)
 728:	6a46                	ld	s4,80(sp)
 72a:	6aa6                	ld	s5,72(sp)
 72c:	6b06                	ld	s6,64(sp)
 72e:	7be2                	ld	s7,56(sp)
 730:	7c42                	ld	s8,48(sp)
 732:	7ca2                	ld	s9,40(sp)
 734:	7d02                	ld	s10,32(sp)
 736:	6de2                	ld	s11,24(sp)
 738:	6109                	addi	sp,sp,128
 73a:	8082                	ret

000000000000073c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 73c:	715d                	addi	sp,sp,-80
 73e:	ec06                	sd	ra,24(sp)
 740:	e822                	sd	s0,16(sp)
 742:	1000                	addi	s0,sp,32
 744:	e010                	sd	a2,0(s0)
 746:	e414                	sd	a3,8(s0)
 748:	e818                	sd	a4,16(s0)
 74a:	ec1c                	sd	a5,24(s0)
 74c:	03043023          	sd	a6,32(s0)
 750:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 754:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 758:	8622                	mv	a2,s0
 75a:	00000097          	auipc	ra,0x0
 75e:	e04080e7          	jalr	-508(ra) # 55e <vprintf>
}
 762:	60e2                	ld	ra,24(sp)
 764:	6442                	ld	s0,16(sp)
 766:	6161                	addi	sp,sp,80
 768:	8082                	ret

000000000000076a <printf>:

void
printf(const char *fmt, ...)
{
 76a:	711d                	addi	sp,sp,-96
 76c:	ec06                	sd	ra,24(sp)
 76e:	e822                	sd	s0,16(sp)
 770:	1000                	addi	s0,sp,32
 772:	e40c                	sd	a1,8(s0)
 774:	e810                	sd	a2,16(s0)
 776:	ec14                	sd	a3,24(s0)
 778:	f018                	sd	a4,32(s0)
 77a:	f41c                	sd	a5,40(s0)
 77c:	03043823          	sd	a6,48(s0)
 780:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 784:	00840613          	addi	a2,s0,8
 788:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 78c:	85aa                	mv	a1,a0
 78e:	4505                	li	a0,1
 790:	00000097          	auipc	ra,0x0
 794:	dce080e7          	jalr	-562(ra) # 55e <vprintf>
}
 798:	60e2                	ld	ra,24(sp)
 79a:	6442                	ld	s0,16(sp)
 79c:	6125                	addi	sp,sp,96
 79e:	8082                	ret
