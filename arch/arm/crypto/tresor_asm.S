/***************************************************************************
 *
 * Cold boot resistant AES-128 for 32-bit ARM machines supporting NEON
 *
 * Copyright (C) 2012 Johannes Goetzfried <johannes@jgoetzfried.de>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms and conditions of the GNU General Public License,
 * version 2, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
 * Place - Suite 330, Boston, MA 02111-1307 USA.
 *
 ***************************************************************************/

.file "tresor_asm.S"

/* 128-bit NEON registers */
rstate .qn q0          /* AES state */
rhelp  .qn q1          /* helping register */
rk1    .qn q2          /* round key  1 */
rk2    .qn q3          /* round key  2 */
rk3    .qn q4          /* round key  3 */
rk4    .qn q5          /* round key  4 */
rk5    .qn q6          /* round key  5 */
rk6    .qn q7          /* round key  6 */
rk7    .qn q8          /* round key  7 */
rk8    .qn q9          /* round key  8 */
rk9    .qn q10         /* round key  9 */
rk10   .qn q11         /* round key 10 */
rnull  .qn q12         /* just zeros   */

rstated0 .dn d0
rstated1 .dn d1
rhelpd0  .dn d2
rhelpd1  .dn d3
rk1d0    .dn d4
rk1d1    .dn d5
rk2d0    .dn d6
rk2d1    .dn d7
rk3d0    .dn d8
rk3d1    .dn d9
rk4d0    .dn d10
rk4d1    .dn d11
rk5d0    .dn d12
rk5d1    .dn d13
rk6d0    .dn d14
rk6d1    .dn d15
rk7d0    .dn d16
rk7d1    .dn d17
rk8d0    .dn d18
rk8d1    .dn d19
rk9d0    .dn d20
rk9d1    .dn d21
rk10d0   .dn d22
rk10d1   .dn d23


/***************************************************************************
 *  				DATA SEGMENT
 ***************************************************************************/

.data

.align 4
gfbd9e:	.word	0x00000000, 0x0b0d090e, 0x161a121c, 0x1d171b12
	.word	0x2c342438, 0x27392d36, 0x3a2e3624, 0x31233f2a
	.word	0x58684870, 0x5365417e, 0x4e725a6c, 0x457f5362
	.word	0x745c6c48, 0x7f516546, 0x62467e54, 0x694b775a
	.word	0xb0d090e0, 0xbbdd99ee, 0xa6ca82fc, 0xadc78bf2
	.word	0x9ce4b4d8, 0x97e9bdd6, 0x8afea6c4, 0x81f3afca
	.word	0xe8b8d890, 0xe3b5d19e, 0xfea2ca8c, 0xf5afc382
	.word	0xc48cfca8, 0xcf81f5a6, 0xd296eeb4, 0xd99be7ba
	.word	0x7bbb3bdb, 0x70b632d5, 0x6da129c7, 0x66ac20c9
	.word	0x578f1fe3, 0x5c8216ed, 0x41950dff, 0x4a9804f1
	.word	0x23d373ab, 0x28de7aa5, 0x35c961b7, 0x3ec468b9
	.word	0x0fe75793, 0x04ea5e9d, 0x19fd458f, 0x12f04c81
	.word	0xcb6bab3b, 0xc066a235, 0xdd71b927, 0xd67cb029
	.word	0xe75f8f03, 0xec52860d, 0xf1459d1f, 0xfa489411
	.word	0x9303e34b, 0x980eea45, 0x8519f157, 0x8e14f859
	.word	0xbf37c773, 0xb43ace7d, 0xa92dd56f, 0xa220dc61
	.word	0xf66d76ad, 0xfd607fa3, 0xe07764b1, 0xeb7a6dbf
	.word	0xda595295, 0xd1545b9b, 0xcc434089, 0xc74e4987
	.word	0xae053edd, 0xa50837d3, 0xb81f2cc1, 0xb31225cf
	.word	0x82311ae5, 0x893c13eb, 0x942b08f9, 0x9f2601f7
	.word	0x46bde64d, 0x4db0ef43, 0x50a7f451, 0x5baafd5f
	.word	0x6a89c275, 0x6184cb7b, 0x7c93d069, 0x779ed967
	.word	0x1ed5ae3d, 0x15d8a733, 0x08cfbc21, 0x03c2b52f
	.word	0x32e18a05, 0x39ec830b, 0x24fb9819, 0x2ff69117
	.word	0x8dd64d76, 0x86db4478, 0x9bcc5f6a, 0x90c15664
	.word	0xa1e2694e, 0xaaef6040, 0xb7f87b52, 0xbcf5725c
	.word	0xd5be0506, 0xdeb30c08, 0xc3a4171a, 0xc8a91e14
	.word	0xf98a213e, 0xf2872830, 0xef903322, 0xe49d3a2c
	.word	0x3d06dd96, 0x360bd498, 0x2b1ccf8a, 0x2011c684
	.word	0x1132f9ae, 0x1a3ff0a0, 0x0728ebb2, 0x0c25e2bc
	.word	0x656e95e6, 0x6e639ce8, 0x737487fa, 0x78798ef4
	.word	0x495ab1de, 0x4257b8d0, 0x5f40a3c2, 0x544daacc
	.word	0xf7daec41, 0xfcd7e54f, 0xe1c0fe5d, 0xeacdf753
	.word	0xdbeec879, 0xd0e3c177, 0xcdf4da65, 0xc6f9d36b
	.word	0xafb2a431, 0xa4bfad3f, 0xb9a8b62d, 0xb2a5bf23
	.word	0x83868009, 0x888b8907, 0x959c9215, 0x9e919b1b
	.word	0x470a7ca1, 0x4c0775af, 0x51106ebd, 0x5a1d67b3
	.word	0x6b3e5899, 0x60335197, 0x7d244a85, 0x7629438b
	.word	0x1f6234d1, 0x146f3ddf, 0x097826cd, 0x02752fc3
	.word	0x335610e9, 0x385b19e7, 0x254c02f5, 0x2e410bfb
	.word	0x8c61d79a, 0x876cde94, 0x9a7bc586, 0x9176cc88
	.word	0xa055f3a2, 0xab58faac, 0xb64fe1be, 0xbd42e8b0
	.word	0xd4099fea, 0xdf0496e4, 0xc2138df6, 0xc91e84f8
	.word	0xf83dbbd2, 0xf330b2dc, 0xee27a9ce, 0xe52aa0c0
	.word	0x3cb1477a, 0x37bc4e74, 0x2aab5566, 0x21a65c68
	.word	0x10856342, 0x1b886a4c, 0x069f715e, 0x0d927850
	.word	0x64d90f0a, 0x6fd40604, 0x72c31d16, 0x79ce1418
	.word	0x48ed2b32, 0x43e0223c, 0x5ef7392e, 0x55fa3020
	.word	0x01b79aec, 0x0aba93e2, 0x17ad88f0, 0x1ca081fe
	.word	0x2d83bed4, 0x268eb7da, 0x3b99acc8, 0x3094a5c6
	.word	0x59dfd29c, 0x52d2db92, 0x4fc5c080, 0x44c8c98e
	.word	0x75ebf6a4, 0x7ee6ffaa, 0x63f1e4b8, 0x68fcedb6
	.word	0xb1670a0c, 0xba6a0302, 0xa77d1810, 0xac70111e
	.word	0x9d532e34, 0x965e273a, 0x8b493c28, 0x80443526
	.word	0xe90f427c, 0xe2024b72, 0xff155060, 0xf418596e
	.word	0xc53b6644, 0xce366f4a, 0xd3217458, 0xd82c7d56
	.word	0x7a0ca137, 0x7101a839, 0x6c16b32b, 0x671bba25
	.word	0x5638850f, 0x5d358c01, 0x40229713, 0x4b2f9e1d
	.word	0x2264e947, 0x2969e049, 0x347efb5b, 0x3f73f255
	.word	0x0e50cd7f, 0x055dc471, 0x184adf63, 0x1347d66d
	.word	0xcadc31d7, 0xc1d138d9, 0xdcc623cb, 0xd7cb2ac5
	.word	0xe6e815ef, 0xede51ce1, 0xf0f207f3, 0xfbff0efd
	.word	0x92b479a7, 0x99b970a9, 0x84ae6bbb, 0x8fa362b5
	.word	0xbe805d9f, 0xb58d5491, 0xa89a4f83, 0xa397468d

.align 4
rc_tab:	.word	0x00000001, 0x00000002, 0x00000004, 0x00000008
	.word	0x00000010, 0x00000020, 0x00000040, 0x00000080
	.word	0x0000001b, 0x00000036

/* external tables from generic aes code */
.set	ft_tab, crypto_ft_tab
.set	fl_tab, crypto_fl_tab
.set	it_tab, crypto_it_tab
.set	il_tab, crypto_il_tab


/***************************************************************************
 *  				MACROs
 ***************************************************************************/

/* function prologue */
.macro prolog
	push		{r4-r11}
	veor		rnull, rnull, rnull
	/* read input */
	vld1.32		{rstate}, [r1]
.endm

/* function epilogue */
.macro epilog
	/* write output */
	vst1.32		{rstate}, [r0]
	/* reset NEON registers */
	veor		q0, q0, q0
	veor		q1, q1, q1
	veor		q2, q2, q2
	veor		q3, q3, q3
	veor		q4, q4, q4
	veor		q5, q5, q5
	veor		q6, q6, q6
	veor		q7, q7, q7
	veor		q8, q8, q8
	veor		q9, q9, q9
	veor		q10, q10, q10
	veor		q11, q11, q11
	eor		r1, r1, r1
	eor		r2, r2, r2
	eor		r3, r3, r3
	pop		{r4-r11}
	bx		lr
.endm

/* copy one 32-bit general purpose register to debug registers */
.macro reg_to_dbg reg dbg tmp
	lsl		\tmp, \reg, #16
	lsr		\reg, \reg, #16
	lsl		\reg, \reg, #16
	mcr		p14, #0, \reg, c0, \dbg, #4
	mcr		p14, #0, \tmp, c0, \dbg, #6
.endm

/* copy value from debug registers to one 32-bit general purpose register */
.macro dbg_to_reg reg dbg tmp
	mrc		p14, #0, \reg, c0, \dbg, #4
	mrc		p14, #0, \tmp, c0, \dbg, #6
	orr		\reg, \reg, \tmp, lsr #16
.endm

/* copy debug registers into one 128-bit neon register */
.macro	dbg_to_neon neon0 neon1
	dbg_to_reg r1, c0, r5
	dbg_to_reg r2, c1, r5
	dbg_to_reg r3, c2, r5
	dbg_to_reg r4, c3, r5
	gpr_to_neon r1, r2, r3, r4, \neon0, \neon1
.endm

/* copy four 32-bit general purpose registers into one 128-bit neon register */
.macro	gpr_to_neon gpr0 gpr1 gpr2 gpr3 neon0 neon1
	vmov		\neon0, \gpr0, \gpr1
	vmov		\neon1, \gpr2, \gpr3
.endm


/* xor sbox(key[index]) onto edx */
.macro	ks_box index base rk
	vmov.u8		r3, \rk\()d1[\index - 8]
	ldr		r3, [\base, r3, lsl #2]
	eor		r2, r2, r3
.endm

/* generate next round key */
.macro	generate_rk oldrk rk
	/*
	k[0] ^= s_box(k[13]) ^ rc;
	k[1] ^= s_box(k[14]);
	k[2] ^= s_box(k[15]);
	k[3] ^= s_box(k[12]);
	*/
	eor		r2, r2, r2
	ks_box		13, r7, \oldrk
	ks_box		14, r8, \oldrk
	ks_box		15, r9, \oldrk
	ks_box		12, r10, \oldrk

	ldr		r3, [r11, r1, lsl #2]
	eor		r2, r2, r3

	veor		rhelp, rhelp, rhelp
	vmov.32		rhelpd0[0], r2
	veor		\rk, \oldrk, rhelp

	/*
	for(cc = 4; cc < 16; cc += 4 )
		k[cc + 0] ^= k[cc - 4];
		k[cc + 1] ^= k[cc - 3];
		k[cc + 2] ^= k[cc - 2];
		k[cc + 3] ^= k[cc - 1];
	*/
	vmov		rhelp, \rk
	vext.32		rhelp, rnull, rhelp, #3
	veor		\rk, \rk, rhelp
	vext.32		rhelp, rnull, rhelp, #3
	veor		\rk, \rk, rhelp
	vext.32		rhelp, rnull, rhelp, #3
	veor		\rk, \rk, rhelp

	/* increment RC (round constant) counter */
	add		r1, r1, #1
.endm

/* common code for inv_mix_column */
.macro inv_mix_helper r l src dst
	.if \r > 7
		vmov.u8		r5, \src\()d1[(\r - 8)]
	.else
		vmov.u8		r5, \src\()d0[\r]
	.endif

	ldr		r6, [r11, r5, lsl #2]
	eor		\dst, \dst, r6, ror #\l
.endm

/* reg[3] = (gfmb(in[c]) ^ gfmd(in[c+1]) ^ gfm9(in[c+2]) ^ gfme(in[c+3]));
 * reg[2] = (gfmd(in[c]) ^ gfm9(in[c+1]) ^ gfme(in[c+2]) ^ gfmb(in[c+3]));
 * reg[1] = (gfm9(in[c]) ^ gfme(in[c+1]) ^ gfmb(in[c+2]) ^ gfmd(in[c+3]));
 * reg[0] = (gfme(in[c]) ^ gfmb(in[c+1]) ^ gfmd(in[c+2]) ^ gfm9(in[c+3]));
 */
.macro	inv_mix_column neonreg reg c
	eor		\reg, \reg, \reg
	inv_mix_helper	\c,      0, \neonreg, \reg
	inv_mix_helper	(\c+1), 24, \neonreg, \reg
	inv_mix_helper	(\c+2), 16, \neonreg, \reg
	inv_mix_helper	(\c+3),  8, \neonreg, \reg
.endm

/* add mixed key */
.macro add_mixed_key rk
	/* mix key */
	inv_mix_column	\rk, r1, 0
	inv_mix_column	\rk, r2, 4
	inv_mix_column	\rk, r3, 8
	inv_mix_column	\rk, r4, 12

	/* add key */
	gpr_to_neon	r1, r2, r3, r4, rhelpd0, rhelpd1
	veor		rstate, rstate, rhelp
.endm

/* common code for f_rn */
.macro f_rn_helper tab r reg
	.if \r > 7
		vmov.u8		r5, rstated1[(\r - 8)]
	.else
		vmov.u8		r5, rstated0[\r]
	.endif

	ldr		r6, [\tab, r5, lsl #2]
	eor		\reg, \reg, r6
.endm

/* reg = tab[0][state[i]] ^ tab[1][state[j]]
 *     ^ tab[2][state[k]] ^ tab[3][state[l]]
 */
.macro f_rn i j k l reg
	eor		\reg, \reg, \reg
	f_rn_helper	r7,  \i, \reg        /* tab[0][state[i]] */
	f_rn_helper	r8,  \j, \reg        /* tab[1][state[j]] */
	f_rn_helper	r9,  \k, \reg        /* tab[2][state[k]] */
	f_rn_helper	r10, \l, \reg        /* tab[3][state[l]] */
.endm

/* general forward round */
.macro f_round
	f_rn		 0,  5, 10, 15, r1
	f_rn		 4,  9, 14,  3, r2
	f_rn		 8, 13,  2,  7, r3
	f_rn		12,  1,  6, 11, r4
	gpr_to_neon	r1, r2, r3, r4, rstated0, rstated1
.endm

/* forward normal round */
.macro f_nround rk
	f_round
	veor		rstate, rstate, \rk
.endm

/* forward last round */
.macro f_lround rk
	ldr		r7, [r12] /* fl_tab */
	add		r8, r7, #1024
	add		r9, r8, #1024
	add		r10, r9, #1024
	f_round
	veor		rstate, rstate, \rk
.endm

/* general inversed round */
.macro	i_round
	f_rn		 0, 13, 10,  7, r1
	f_rn		 4,  1, 14, 11, r2
	f_rn		 8,  5,  2, 15, r3
	f_rn		12,  9,  6,  3, r4
	gpr_to_neon	r1, r2, r3, r4, rstated0, rstated1
.endm

/* inversed normal round */
.macro	i_nround rk
	i_round
	add_mixed_key	\rk
.endm

/* inversed last round */
.macro	i_lround rk
	ldr		r7, [r12, #12] /* il_tab */
	add		r8, r7, #1024
	add		r9, r8, #1024
	add		r10, r9, #1024
	i_round
	veor		rstate, rstate, \rk
.endm

/* generate AES-128 key schedule (rk1 to rk10) */
.macro	key_schedule
	eor		r1, r1, r1
	ldr		r7, [r12] /* fl_tab */
	add		r8, r7, #1024
	add		r9, r8, #1024
	add		r10, r9, #1024
	ldr		r11, [r12, #4] /* rc_tab */
	generate_rk	rk1, rk1
	generate_rk	rk1, rk2
	generate_rk	rk2, rk3
	generate_rk	rk3, rk4
	generate_rk	rk4, rk5
	generate_rk	rk5, rk6
	generate_rk	rk6, rk7
	generate_rk	rk7, rk8
	generate_rk	rk8, rk9
	generate_rk	rk9, rk10
.endm


/***************************************************************************
 *	  			CODE SEGMENT
 **************************************************************************/

.text
.code 32
.arch armv7-a
.fpu  neon
.align 4
	.global		tresor_set_key
	.global		tresor_encblk_128
	.global		tresor_decblk_128
	.extern		crypto_ft_tab
	.extern		crypto_fl_tab
	.extern		crypto_it_tab
	.extern		crypto_il_tab


tresor_encpool:
	.word	fl_tab
	.word	rc_tab
	.word	ft_tab

/* void tresor_encblk_128(u8 *out, const u8 *in) */
tresor_encblk_128:
	adr		r12, tresor_encpool
	prolog
	dbg_to_neon	rk1d0, rk1d1
	veor		rstate, rstate, rk1
	key_schedule
	ldr		r7, [r12, #8] /* ft_tab */
	add		r8, r7, #1024
	add		r9, r8, #1024
	add		r10, r9, #1024
	f_nround	rk1
	f_nround	rk2
	f_nround	rk3
	f_nround	rk4
	f_nround	rk5
	f_nround	rk6
	f_nround	rk7
	f_nround	rk8
	f_nround	rk9
	f_lround	rk10
	epilog


tresor_decpool:
	.word	fl_tab
	.word	rc_tab
	.word	it_tab
	.word	il_tab
	.word	gfbd9e

/* void tresor_decblk_128(u8 *out, const u8 *in) */
tresor_decblk_128:
	adr		r12, tresor_decpool
	prolog
	dbg_to_neon	rk1d0, rk1d1
	key_schedule
	veor		rstate, rstate, rk10
	ldr		r7, [r12, #8] /* it_tab */
	add		r8, r7, #1024
	add		r9, r8, #1024
	add		r10, r9, #1024
	ldr		r11, [r12, #16] /* gfbd9e */
	i_nround	rk9
	i_nround	rk8
	i_nround	rk7
	i_nround	rk6
	i_nround	rk5
	i_nround	rk4
	i_nround	rk3
	i_nround	rk2
	i_nround	rk1
	dbg_to_neon	rk1d0, rk1d1
	i_lround	rk1
	epilog


/* void tresor_set_key(const u8 *in_key) */
tresor_set_key:
	ldr		r1, [r0]
	reg_to_dbg	r1, c0, r2
	ldr		r1, [r0, #4]
	reg_to_dbg	r1, c1, r2
	ldr		r1, [r0, #8]
	reg_to_dbg	r1, c2, r2
	ldr		r1, [r0, #12]
	reg_to_dbg	r1, c3, r2
	eor		r1, r1, r1
	eor		r2, r2, r2
	bx		lr

