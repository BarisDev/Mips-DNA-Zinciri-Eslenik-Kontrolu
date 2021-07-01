.data
zincir1: .asciiz "ATGATGATGC"
zincir2: .asciiz "TCGCGCTAGC"
zincir3: .asciiz "CGTCGTAAAC"
zincir4: .asciiz "TATTTACGAA"
zincir5: .asciiz "TACTACTACG" #sonu G


diffmsg:	.asciiz	"\nstringler farklı\n\n"
samemsg:	.asciiz "\nstringler aynı, k0 ve k1 registerında saklanıyor\n\n"

buffer: .space 10	#buffer bizim eşleniğimizi tutacak

A:	.word	65 #A
T:	.word	84 #T
G:	.word	71 #G
C:	.word	67 #C

.text
#EŞLENİK ALMA BAŞLANGICI
#eşlenik nasıl alınır: zincirin elemanlarını tek tek okur ve A ise bufferda karşılık gelen elemana T yazar, G ise C yazar.
_function_eslenik:
		lw		$t1, A
		lw		$t2, T
		lw		$t3, G
		lw		$t4, C
		move    $t0, $a0 	#zincir1'in adresi t0'da
		la		$t5, buffer #buffer adresi t5'te
		lb		$s1, ($t5)	#bufferın ilk elemanı
	loop:# 0. eleman A mı, T mi, G mi, C mi?
		lb		$s0, ($t0)	#zincirin ilk elemanı
	    beq		$s0, $t1, elemanA	#dizinin elemanı A ise elemanA dallan
	    beq		$s0, $t2, elemanT	#dizinin elemanı T ise elemanT dallan
	    beq		$s0, $t3, elemanG	#dizinin elemanı G ise elemanG dallan
	    beq		$s0, $t4, elemanC	#dizinin elemanı C ise elemanC dallan
	    blez 	$s0, print	#stringin sonuna geldiysek buffer yazdırmaya dallan
	loop2:    
	    addi	$t0, $t0, 1
	    j		loop
	elemanA:
		move	$s1, $t2	#buffer elemanına T at
		sb		$s1, ($t5)	#buffer adresindeki değeri belleğe store et
		addi	$t5, $t5, 1	#buffer adresini 1 artır (char 1 byte)
		j		loop2
	elemanT:
		move	$s1, $t1
		sb		$s1, ($t5)	
		addi	$t5, $t5, 1
		j		loop2
	elemanG:
		move	$s1, $t4
		sb		$s1, ($t5)
		addi	$t5, $t5, 1
		j		loop2
	elemanC:
		move	$s1, $t3
		sb		$s1, ($t5)
		addi	$t5, $t5, 1
		j		loop2
	print:
		#registerları boşalt..
		move	$s0, $zero
		move	$s1, $zero
		move	$t0, $zero
		move	$t1, $zero
		move	$t2, $zero
		move	$t3, $zero
		move	$t4, $zero
		move	$t5, $zero
		#..ve buffer'ı yazdır
		li		$v0, 4
		la 		$a0, buffer
		syscall
		jr $ra
	
#EŞLENİK ALMA BİTİŞİ
#KARŞILAŞTIRMA BAŞLANGIÇ
_function_compare:
		#buffer ile diğer zincirleri kıyaslıyoruz
		move    $t0, $a1 #zincir2'nin adresi
		la		$t5, buffer #buffer adresi t5'te
		li 		$t8, 0 #farklılık sayacımız eğer 5 olursa tüm elemanlar birbirinden farklıdır ve k0 k1 registerlarına 0 atanır
	compareloop:
		lb		$s1, ($t5)	#buffer'ın elemanı
		lb		$s2, ($t0)	#zincir2'nin elemanı
		beq		$s2, $zero, same	#zincirin sonuna geldiysek finish dallan
		bne		$s1, $s2, different	#elemanlar farklıysa different dallan
	
		addi 	$t0, $t0, 1	#zincir adresini 1 byte artır (char size 1 byte)
		addi 	$t5, $t5, 1	#buffer adresini 1 byte artır (char size 1 byte)
		j compareloop
	
	different: #farklıysa diffmsg yazdırıp fonksiyondan çık
		li 		$v0, 4
		la		$a0, diffmsg
		syscall
		addi 	$t8, $t8, 1 #t8 farklılık sayacını 1 artır
		jr $ra
	same: #aynılarsa zincirlerin idlerini bulmak lazım
		la 		$s3, zincir1
		la 		$s4, zincir2
		la 		$s5, zincir3
		la 		$s6, zincir4
		la 		$s7, zincir5

		#t9 register'ı bizim a0 ile gelen inputun adresini tutuyor
		beq		$t9, $s3, findid1	#t9 zincir1 ise
		beq		$t9, $s4, findid2	#t9 zincir2 ise
		beq		$t9, $s5, findid3	#t9 zincir3 ise
		beq		$t9, $s6, findid4	#t9 zincir4 ise
		beq		$t9, $s7, findid5	#t9 zincir5 ise
		
	nextid:
		#a1 bizim 2. inputumuz
		beq		$a1, $s3, findid_1	#a1 zincir1 ise
		beq		$a1, $s4, findid_2	#a1 zincir2 ise
		beq		$a1, $s5, findid_3	#a1 zincir3 ise
		beq		$a1, $s6, findid_4	#a1 zincir4 ise
		beq		$a1, $s7, findid_5	#a1 zincir5 ise

	#1. inputumuz kaçıncı zincirse o id k0 registerına kaydedilir
	findid1:
		li	$k0, 1
		j nextid
	findid2:
		li	$k0, 2
		j nextid
	findid3:
		li	$k0, 3
		j nextid
	findid4:
		li	$k0, 4
		j nextid
	findid5:
		li	$k0, 5
		j nextid

	#2. inputumuz kaçıncı zincirse o id k1 registerına kaydedilir
	findid_1:
		li		$k1, 1
		j return
	findid_2:
		li 		$k1, 2
		j return
	findid_3:
		li		$k1, 3
		j return
	findid_4:
		li		$k1, 4
		j return
	findid_5:
		li		$k1, 5
		j return

	return:
		li		$v0, 4
		la 		$a0, samemsg
		syscall
		addi $t7, $t7, 1 #bool değişkenimizi 1 artırdık
		jr $ra
#KARŞILAŞTIRMA BİTİŞ
main:
	#zincir1 vs zincir2
	li		$t7, 0 #bizim için bool değişkeni, eğer kıyaslama yaptıktan sonra zincirler aynıysa exite atlamamızı sağlayacak
	la 		$a0, zincir1
	jal 	_function_eslenik
	#eşlenik hesaplandığında $a0'da buffer var!
	#Bu nedenle zincir1'i t9 register'ında tutuyoruz ki idsini hesaplayalım.
	la 		$t9, zincir1
	la 		$a1, zincir2
	jal 	_function_compare
	beq 	$t7, 1, exit

	#zincir1 vs zincir3
	la 		$a0, zincir1
	jal 	_function_eslenik
	la 		$t9, zincir1
	la 		$a1, zincir3
	jal 	_function_compare
	beq 	$t7, 1, exit

	#zincir1 vs zincir4
	la 		$a0, zincir1
	jal 	_function_eslenik
	la 		$t9, zincir1
	la 		$a1, zincir4
	jal 	_function_compare
	beq 	$t7, 1, exit

	#zincir1 vs zincir5
	la 		$a0, zincir1
	jal 	_function_eslenik
	la 		$t9, zincir1
	la 		$a1, zincir5
	jal 	_function_compare
	beq 	$t7, 1, exit

	#zincir2 vs zincir3
	la 		$a0, zincir2
	jal 	_function_eslenik
	la 		$t9, zincir2
	la 		$a1, zincir3
	jal 	_function_compare
	beq 	$t7, 1, exit

	#zincir2 vs zincir4
	la 		$a0, zincir2
	jal 	_function_eslenik
	la 		$t9, zincir2
	la 		$a1, zincir4
	jal 	_function_compare
	beq 	$t7, 1, exit

	#zincir2 vs zincir5
	la 		$a0, zincir2
	jal 	_function_eslenik
	la 		$t9, zincir2
	la 		$a1, zincir5
	jal 	_function_compare
	beq 	$t7, 1, exit

	#zincir3 vs zincir4
	la 		$a0, zincir3
	jal		_function_eslenik
	la 		$t9, zincir3
	la 		$a1, zincir4
	jal 	_function_compare
	beq 	$t7, 1, exit

	#zincir3 vs zincir5
	la 		$a0, zincir3
	jal 	_function_eslenik
	la 		$t9, zincir3
	la 		$a1, zincir5
	jal 	_function_compare
	beq 	$t7, 1, exit

	#zincir4 vs zincir5
	la 		$a0, zincir4
	jal 	_function_eslenik
	la 		$t9, zincir4
	la 		$a1, zincir5
	jal 	_function_compare
	beq 	$t7, 1, exit

	beq	$t8, 10, sifir	#10 kıyaslamanın sonunda farklılık sayacı 10 ise tüm zincirler farklıdır
	j exit

sifir:
	li		$k0, 0
	li		$k1, 0
	j exit
# exit program
exit:
    li      $v0, 10 #syscall 10: exit
    syscall