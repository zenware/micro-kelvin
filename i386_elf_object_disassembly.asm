
build/boot.o:     file format elf32-i386


Disassembly of section .multiboot:

00000000 <.multiboot>:
   0:	02 b0 ad 1b 03 00    	add    0x31bad(%eax),%dh
   6:	00 00                	add    %al,(%eax)
   8:	fb                   	sti    
   9:	4f                   	dec    %edi
   a:	52                   	push   %edx
   b:	e4                   	.byte 0xe4

Disassembly of section .bootstrap_stack,:

00000000 <stack_bottom>:
	...

Disassembly of section .text:

00000000 <_start>:
   0:	bc 00 40 00 00       	mov    $0x4000,%esp
   5:	e8 fc ff ff ff       	call   6 <_start+0x6>
   a:	fa                   	cli    

0000000b <_start.hang>:
   b:	f4                   	hlt    
   c:	eb fd                	jmp    b <_start.hang>

Disassembly of section .comment:

00000000 <.comment>:
   0:	00 54 68 65          	add    %dl,0x65(%eax,%ebp,2)
   4:	20 4e 65             	and    %cl,0x65(%esi)
   7:	74 77                	je     80 <_start.hang+0x75>
   9:	69 64 65 20 41 73 73 	imul   $0x65737341,0x20(%ebp,%eiz,2),%esp
  10:	65 
  11:	6d                   	insl   (%dx),%es:(%edi)
  12:	62 6c 65 72          	bound  %ebp,0x72(%ebp,%eiz,2)
  16:	20 30                	and    %dh,(%eax)
  18:	2e 39 38             	cmp    %edi,%cs:(%eax)
  1b:	2e 34 30             	cs xor $0x30,%al
  1e:	20 28                	and    %ch,(%eax)
  20:	41                   	inc    %ecx
  21:	70 70                	jo     93 <_start.hang+0x88>
  23:	6c                   	insb   (%dx),%es:(%edi)
  24:	65 20 43 6f          	and    %al,%gs:0x6f(%ebx)
  28:	6d                   	insl   (%dx),%es:(%edi)
  29:	70 75                	jo     a0 <_start.hang+0x95>
  2b:	74 65                	je     92 <_start.hang+0x87>
  2d:	72 2c                	jb     5b <_start.hang+0x50>
  2f:	20 49 6e             	and    %cl,0x6e(%ecx)
  32:	63 2e                	arpl   %bp,(%esi)
  34:	20 62 75             	and    %ah,0x75(%edx)
  37:	69 6c 64 20 31 31 29 	imul   $0x293131,0x20(%esp,%eiz,2),%ebp
  3e:	00 

build/kernel.o:     file format elf32-i386


Disassembly of section .text:

00000000 <make_color>:
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 08             	sub    $0x8,%esp
   6:	8b 45 0c             	mov    0xc(%ebp),%eax
   9:	8b 4d 08             	mov    0x8(%ebp),%ecx
   c:	89 4d fc             	mov    %ecx,-0x4(%ebp)
   f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  12:	8b 45 fc             	mov    -0x4(%ebp),%eax
  15:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  18:	c1 e1 04             	shl    $0x4,%ecx
  1b:	09 c8                	or     %ecx,%eax
  1d:	88 c2                	mov    %al,%dl
  1f:	0f b6 c2             	movzbl %dl,%eax
  22:	83 c4 08             	add    $0x8,%esp
  25:	5d                   	pop    %ebp
  26:	c3                   	ret    
  27:	66 0f 1f 84 00 00 00 	nopw   0x0(%eax,%eax,1)
  2e:	00 00 

00000030 <make_vgaentry>:
  30:	55                   	push   %ebp
  31:	89 e5                	mov    %esp,%ebp
  33:	57                   	push   %edi
  34:	56                   	push   %esi
  35:	83 ec 08             	sub    $0x8,%esp
  38:	8a 45 0c             	mov    0xc(%ebp),%al
  3b:	8a 4d 08             	mov    0x8(%ebp),%cl
  3e:	88 4d f7             	mov    %cl,-0x9(%ebp)
  41:	88 45 f6             	mov    %al,-0xa(%ebp)
  44:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  48:	66 89 d6             	mov    %dx,%si
  4b:	66 89 75 f4          	mov    %si,-0xc(%ebp)
  4f:	8a 45 f6             	mov    -0xa(%ebp),%al
  52:	0f b6 d0             	movzbl %al,%edx
  55:	66 89 d6             	mov    %dx,%si
  58:	66 89 75 f2          	mov    %si,-0xe(%ebp)
  5c:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
  60:	0f b7 7d f2          	movzwl -0xe(%ebp),%edi
  64:	c1 e7 08             	shl    $0x8,%edi
  67:	09 fa                	or     %edi,%edx
  69:	66 89 d6             	mov    %dx,%si
  6c:	0f b7 c6             	movzwl %si,%eax
  6f:	83 c4 08             	add    $0x8,%esp
  72:	5e                   	pop    %esi
  73:	5f                   	pop    %edi
  74:	5d                   	pop    %ebp
  75:	c3                   	ret    
  76:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%eax,%eax,1)
  7d:	00 00 00 

00000080 <strlen>:
  80:	55                   	push   %ebp
  81:	89 e5                	mov    %esp,%ebp
  83:	83 ec 08             	sub    $0x8,%esp
  86:	8b 45 08             	mov    0x8(%ebp),%eax
  89:	89 45 fc             	mov    %eax,-0x4(%ebp)
  8c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  93:	8b 45 f8             	mov    -0x8(%ebp),%eax
  96:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  99:	0f be 04 01          	movsbl (%ecx,%eax,1),%eax
  9d:	83 f8 00             	cmp    $0x0,%eax
  a0:	0f 84 0e 00 00 00    	je     b4 <strlen+0x34>
  a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  a9:	83 c0 01             	add    $0x1,%eax
  ac:	89 45 f8             	mov    %eax,-0x8(%ebp)
  af:	e9 df ff ff ff       	jmp    93 <strlen+0x13>
  b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  b7:	83 c4 08             	add    $0x8,%esp
  ba:	5d                   	pop    %ebp
  bb:	c3                   	ret    
  bc:	0f 1f 40 00          	nopl   0x0(%eax)

000000c0 <terminal_initialize>:
  c0:	55                   	push   %ebp
  c1:	89 e5                	mov    %esp,%ebp
  c3:	83 ec 20             	sub    $0x20,%esp
  c6:	b8 0b 00 00 00       	mov    $0xb,%eax
  cb:	31 c9                	xor    %ecx,%ecx
  cd:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  d4:	00 00 00 
  d7:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  de:	00 00 00 
  e1:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  ef:	00 
  f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  f3:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  f6:	e8 05 ff ff ff       	call   0 <make_color>
  fb:	b9 00 80 0b 00       	mov    $0xb8000,%ecx
 100:	a2 00 00 00 00       	mov    %al,0x0
 105:	89 0d 00 00 00 00    	mov    %ecx,0x0
 10b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 112:	83 7d fc 19          	cmpl   $0x19,-0x4(%ebp)
 116:	0f 83 68 00 00 00    	jae    184 <terminal_initialize+0xc4>
 11c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
 123:	83 7d f8 50          	cmpl   $0x50,-0x8(%ebp)
 127:	0f 83 44 00 00 00    	jae    171 <terminal_initialize+0xb1>
 12d:	b8 20 00 00 00       	mov    $0x20,%eax
 132:	6b 4d fc 50          	imul   $0x50,-0x4(%ebp),%ecx
 136:	03 4d f8             	add    -0x8(%ebp),%ecx
 139:	89 4d f4             	mov    %ecx,-0xc(%ebp)
 13c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
 143:	0f b6 0d 00 00 00 00 	movzbl 0x0,%ecx
 14a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
 14e:	89 45 e8             	mov    %eax,-0x18(%ebp)
 151:	e8 da fe ff ff       	call   30 <make_vgaentry>
 156:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 159:	8b 15 00 00 00 00    	mov    0x0,%edx
 15f:	66 89 04 4a          	mov    %ax,(%edx,%ecx,2)
 163:	8b 45 f8             	mov    -0x8(%ebp),%eax
 166:	83 c0 01             	add    $0x1,%eax
 169:	89 45 f8             	mov    %eax,-0x8(%ebp)
 16c:	e9 b2 ff ff ff       	jmp    123 <terminal_initialize+0x63>
 171:	e9 00 00 00 00       	jmp    176 <terminal_initialize+0xb6>
 176:	8b 45 fc             	mov    -0x4(%ebp),%eax
 179:	83 c0 01             	add    $0x1,%eax
 17c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 17f:	e9 8e ff ff ff       	jmp    112 <terminal_initialize+0x52>
 184:	83 c4 20             	add    $0x20,%esp
 187:	5d                   	pop    %ebp
 188:	c3                   	ret    
 189:	0f 1f 80 00 00 00 00 	nopl   0x0(%eax)

00000190 <terminal_setcolor>:
 190:	55                   	push   %ebp
 191:	89 e5                	mov    %esp,%ebp
 193:	50                   	push   %eax
 194:	8a 45 08             	mov    0x8(%ebp),%al
 197:	88 45 ff             	mov    %al,-0x1(%ebp)
 19a:	8a 45 ff             	mov    -0x1(%ebp),%al
 19d:	a2 00 00 00 00       	mov    %al,0x0
 1a2:	83 c4 04             	add    $0x4,%esp
 1a5:	5d                   	pop    %ebp
 1a6:	c3                   	ret    
 1a7:	66 0f 1f 84 00 00 00 	nopw   0x0(%eax,%eax,1)
 1ae:	00 00 

000001b0 <terminal_putentryat>:
 1b0:	55                   	push   %ebp
 1b1:	89 e5                	mov    %esp,%ebp
 1b3:	56                   	push   %esi
 1b4:	83 ec 18             	sub    $0x18,%esp
 1b7:	8b 45 14             	mov    0x14(%ebp),%eax
 1ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
 1bd:	8a 55 0c             	mov    0xc(%ebp),%dl
 1c0:	8a 75 08             	mov    0x8(%ebp),%dh
 1c3:	88 75 fb             	mov    %dh,-0x5(%ebp)
 1c6:	88 55 fa             	mov    %dl,-0x6(%ebp)
 1c9:	89 4d f4             	mov    %ecx,-0xc(%ebp)
 1cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
 1cf:	6b 45 f0 50          	imul   $0x50,-0x10(%ebp),%eax
 1d3:	03 45 f4             	add    -0xc(%ebp),%eax
 1d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 1d9:	8a 55 fb             	mov    -0x5(%ebp),%dl
 1dc:	0f be c2             	movsbl %dl,%eax
 1df:	89 04 24             	mov    %eax,(%esp)
 1e2:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
 1e6:	89 44 24 04          	mov    %eax,0x4(%esp)
 1ea:	e8 41 fe ff ff       	call   30 <make_vgaentry>
 1ef:	8b 4d ec             	mov    -0x14(%ebp),%ecx
 1f2:	8b 35 00 00 00 00    	mov    0x0,%esi
 1f8:	66 89 04 4e          	mov    %ax,(%esi,%ecx,2)
 1fc:	83 c4 18             	add    $0x18,%esp
 1ff:	5e                   	pop    %esi
 200:	5d                   	pop    %ebp
 201:	c3                   	ret    
 202:	66 66 66 66 66 2e 0f 	data16 data16 data16 data16 nopw %cs:0x0(%eax,%eax,1)
 209:	1f 84 00 00 00 00 00 

00000210 <terminal_putchar>:
 210:	55                   	push   %ebp
 211:	89 e5                	mov    %esp,%ebp
 213:	57                   	push   %edi
 214:	56                   	push   %esi
 215:	83 ec 14             	sub    $0x14,%esp
 218:	8a 45 08             	mov    0x8(%ebp),%al
 21b:	88 45 f7             	mov    %al,-0x9(%ebp)
 21e:	8a 45 f7             	mov    -0x9(%ebp),%al
 221:	8a 0d 00 00 00 00    	mov    0x0,%cl
 227:	8b 15 00 00 00 00    	mov    0x0,%edx
 22d:	8b 35 00 00 00 00    	mov    0x0,%esi
 233:	0f be f8             	movsbl %al,%edi
 236:	89 3c 24             	mov    %edi,(%esp)
 239:	0f b6 f9             	movzbl %cl,%edi
 23c:	89 7c 24 04          	mov    %edi,0x4(%esp)
 240:	89 54 24 08          	mov    %edx,0x8(%esp)
 244:	89 74 24 0c          	mov    %esi,0xc(%esp)
 248:	e8 63 ff ff ff       	call   1b0 <terminal_putentryat>
 24d:	8b 15 00 00 00 00    	mov    0x0,%edx
 253:	83 c2 01             	add    $0x1,%edx
 256:	89 15 00 00 00 00    	mov    %edx,0x0
 25c:	83 fa 50             	cmp    $0x50,%edx
 25f:	0f 85 2f 00 00 00    	jne    294 <terminal_putchar+0x84>
 265:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
 26c:	00 00 00 
 26f:	a1 00 00 00 00       	mov    0x0,%eax
 274:	83 c0 01             	add    $0x1,%eax
 277:	a3 00 00 00 00       	mov    %eax,0x0
 27c:	83 f8 19             	cmp    $0x19,%eax
 27f:	0f 85 0a 00 00 00    	jne    28f <terminal_putchar+0x7f>
 285:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
 28c:	00 00 00 
 28f:	e9 00 00 00 00       	jmp    294 <terminal_putchar+0x84>
 294:	83 c4 14             	add    $0x14,%esp
 297:	5e                   	pop    %esi
 298:	5f                   	pop    %edi
 299:	5d                   	pop    %ebp
 29a:	c3                   	ret    
 29b:	0f 1f 44 00 00       	nopl   0x0(%eax,%eax,1)

000002a0 <terminal_writestring>:
 2a0:	55                   	push   %ebp
 2a1:	89 e5                	mov    %esp,%ebp
 2a3:	83 ec 10             	sub    $0x10,%esp
 2a6:	8b 45 08             	mov    0x8(%ebp),%eax
 2a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
 2ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2af:	89 04 24             	mov    %eax,(%esp)
 2b2:	e8 c9 fd ff ff       	call   80 <strlen>
 2b7:	89 45 f8             	mov    %eax,-0x8(%ebp)
 2ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 2c7:	0f 83 20 00 00 00    	jae    2ed <terminal_writestring+0x4d>
 2cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d0:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 2d3:	0f be 04 01          	movsbl (%ecx,%eax,1),%eax
 2d7:	89 04 24             	mov    %eax,(%esp)
 2da:	e8 31 ff ff ff       	call   210 <terminal_putchar>
 2df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2e2:	83 c0 01             	add    $0x1,%eax
 2e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
 2e8:	e9 d4 ff ff ff       	jmp    2c1 <terminal_writestring+0x21>
 2ed:	83 c4 10             	add    $0x10,%esp
 2f0:	5d                   	pop    %ebp
 2f1:	c3                   	ret    
 2f2:	66 66 66 66 66 2e 0f 	data16 data16 data16 data16 nopw %cs:0x0(%eax,%eax,1)
 2f9:	1f 84 00 00 00 00 00 

00000300 <kernel_main>:
 300:	55                   	push   %ebp
 301:	89 e5                	mov    %esp,%ebp
 303:	50                   	push   %eax
 304:	e8 b7 fd ff ff       	call   c0 <terminal_initialize>
 309:	8d 05 00 00 00 00    	lea    0x0,%eax
 30f:	89 04 24             	mov    %eax,(%esp)
 312:	e8 89 ff ff ff       	call   2a0 <terminal_writestring>
 317:	83 c4 04             	add    $0x4,%esp
 31a:	5d                   	pop    %ebp
 31b:	c3                   	ret    

Disassembly of section .rodata.str1.1:

00000000 <.L.str>:
   0:	48                   	dec    %eax
   1:	65 6c                	gs insb (%dx),%es:(%edi)
   3:	6c                   	insb   (%dx),%es:(%edi)
   4:	6f                   	outsl  %ds:(%esi),(%dx)
   5:	2c 20                	sub    $0x20,%al
   7:	6b 65 72 6e          	imul   $0x6e,0x72(%ebp),%esp
   b:	65 6c                	gs insb (%dx),%es:(%edi)
   d:	21 0a                	and    %ecx,(%edx)
	...

Disassembly of section .comment:

00000000 <.comment>:
   0:	00 41 70             	add    %al,0x70(%ecx)
   3:	70 6c                	jo     71 <make_vgaentry+0x41>
   5:	65 20 4c 4c 56       	and    %cl,%gs:0x56(%esp,%ecx,2)
   a:	4d                   	dec    %ebp
   b:	20 76 65             	and    %dh,0x65(%esi)
   e:	72 73                	jb     83 <strlen+0x3>
  10:	69 6f 6e 20 37 2e 33 	imul   $0x332e3720,0x6e(%edi),%ebp
  17:	2e 30 20             	xor    %ah,%cs:(%eax)
  1a:	28 63 6c             	sub    %ah,0x6c(%ebx)
  1d:	61                   	popa   
  1e:	6e                   	outsb  %ds:(%esi),(%dx)
  1f:	67 2d 37 30 33 2e    	addr16 sub $0x2e333037,%eax
  25:	30 2e                	xor    %ch,(%esi)
  27:	33 31                	xor    (%ecx),%esi
  29:	29 00                	sub    %eax,(%eax)
