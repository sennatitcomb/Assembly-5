TITLE Project5 Program(template.asm)

; Author: Senna Titcomb
; Last Modified : 2 / 20 / 2021
; OSU email address : titcombs@oregonstate.edu
; Course number / section: 271 / 001
; Assignment Number : Program 5                Due Date : Feb 28
; Description: Write a MASM program to introduce the program, get a user request from  range[min = 15 ..max = 200],
; generate request random integers from the range[lo = 100 ..hi = 999], store them in consecutive elements of an array,
; display the list of integers before sorting, 10 numbers per line, sort the list in descending order(i.e., largest first),
; calculateand display the median value, rounded to the nearest integer, display the sorted list, 10 numbers per line.

INCLUDE Irvine32.inc


; (insert constant definitions here)
min	EQU	14
max	EQU	201
lo	EQU	100
hi	EQU	999


.data
titlemessage BYTE "Sorting Random Integers", 0dh, 0ah, 0
programmer BYTE "Programmed by Senna Titcomb", 0dh, 0ah, 0
instruction1 BYTE "This program generates random numbers in the range [100 .. 999],", 0dh, 0ah, 0
instruction2 BYTE "displays the original list, sorts the list, and calculates the", 0dh, 0ah, 0
instruction3 BYTE "median value. Finally, it displays the list sorted in descending order.", 0
getvalue BYTE "How many numbers should be generated? [15 .. 200]: ", 0
error BYTE "Invalid input", 0dh, 0ah, 0
unsorted BYTE "The unsorted random numbers:", 0dh, 0ah, 0
median BYTE "The median is ", 0
sorted BYTE "The sorted list:", 0dh, 0ah, 0
goodbye BYTE "Thanks for using my program!", 0dh, 0ah, 0
spacing BYTE "   ", 0
notevenmess BYTE "EVEN", 0dh, 0ah, 0
userinput	DWORD ?
myarray DWORD	max	DUP(? )



; (insert variable definitions here)


.code
main PROC
	call Clrscr
	call intro

	push OFFSET userinput	;pass by ref
	call getData

	push OFFSET myarray		;pass by ref
	push userinput		;pass by val
	call fillArray

	mov edx, OFFSET unsorted
	call WriteString
	push OFFSET myarray
	push userinput
	call displayList

	push OFFSET myarray		; pass by ref
	push userinput		; pass by val
	call sortList

	call Crlf
	push OFFSET myarray		; pass by ref
	push userinput		; pass by val
	call displayMedian

	mov edx, OFFSET sorted
	call WriteString
	push OFFSET myarray
	push userinput
	call displayList

	call Crlf
	mov edx, OFFSET goodbye
	call WriteString

exit; exit to operating system
main ENDP

; (insert additional procedures here)
;***************************************************************
; Procedure to print instructions
; receives: nothing
; returns: instruction output
; preconditions: nothing
; registers changed: edx
; ***************************************************************
intro PROC
	; print titlemessage
	mov edx, OFFSET titlemessage
	call WriteString
	mov edx, OFFSET programmer
	call WriteString

	; print instructions
	mov edx, OFFSET instruction1
	call WriteString
	mov edx, OFFSET instruction2
	call WriteString
	mov edx, OFFSET instruction3
	call Crlf

	ret
intro ENDP

; ***************************************************************
; Procedure to print instructions
; receives: userinput on stack
; returns:  address of userinput
; preconditions: userinput is passed into stack
; registers changed : edx, eax, ebp, esp
;***************************************************************
; {parameters: request(reference)}
getData PROC
	push	ebp
	mov		ebp, esp
	mov		edx, OFFSET getvalue
	call	WriteString
	call	ReadInt

	; validation
	validLoop:
	cmp eax, min		; is value greater than 15 ?
	jle invalid		; less than jump to error
	cmp eax, max		; is value less than 200 ?
	jge invalid		; greater than jump to error message
	jmp finish
	invalid :
	mov edx, OFFSET error
	call WriteString
	call getData		; invalid num, ask again
	finish :


	mov	ebx, [ebp + 8]		;address of userinput
	mov[ebx], eax

	pop ebp
	ret	4
getData ENDP

; ***************************************************************
; Procedure to print instructions
; receives: array and userinput on stack
; returns: stack
; preconditions: array and userinput are on stack
; registers changed : edx, ebp, esp, ecx, edi, eax
;***************************************************************
; {parameters: request(value), array(reference)}
fillArray PROC
	push	ebp
	mov		ebp, esp

	mov		ecx, [ebp + 8]		; userinput 
	mov		edi, [ebp + 12]		; address

	random:
	mov		eax, hi		; calculate randoms
	sub		eax, lo
	inc eax
	call RandomRange
	add eax, lo
	mov		[edi], eax
	add		edi, 4
	loop	random

	pop		ebp
	ret		8
fillArray ENDP

; ***************************************************************
; Procedure to print instructions
; receives: address of array and userinput on stack
; returns: sorted stack
; preconditions: array and userinput are on stack
; registers changed : edx, esp, ebp, ecx, esi, eax, ebx
;***************************************************************
; {parameters: array(reference), request(value)}
sortList PROC
	push	ebp
	mov		ebp, esp
	mov ecx, [ebp + 8]; userinput
	mov esi, [ebp + 12]; address
	
	mov eax, ecx
	mov ebx, 5
	mul ebx
	mov ecx, eax
	mov ebx, 0

	sort:
	;dec ecx
	cmp ebx, ecx	;if k < request-1
	jge finish
	mov edi, ebx	;i = k
	mov eax, ebx
	moreswap:
	cmp eax, ecx	;if j < request
	jge endofmore
	mov edx, [esi + edi]
	cmp [esi + eax], edx
	jl smaller
	mov edi, eax	;i = j
	smaller:
	add eax, 4
	jmp moreswap
	endofmore:
	mov edx, [esi + edi]
	mov eax, [esi + ebx]
	mov[esi + edi], eax
	mov[esi + ebx], edx
	add ebx, 4
	loop sort
	
	finish:
	pop ebp
	ret 8
sortList ENDP

;***************************************************************
; Procedure to exchange numbers
; receives: address of array and userinput on stack
; returns: median
; preconditions: arrayand userinput are on stack
; registers changed : edx
; ***************************************************************
; {parameters: array(reference), request(value)}
exchange PROC
	push	ebp
	mov		ebp, esp
	mov ecx, [ebp + 8]; userinput
	mov esi, [ebp + 12]; address

	mov [esi + edi], eax
	mov [esi + ebx], edx

	pop ebp
	ret 8
exchange ENDP



; ***************************************************************
; Procedure to print instructions
; receives: address of array and userinput on stack
; returns: median
; preconditions: array and userinput are on stack
; registers changed : edx
;***************************************************************
; {parameters: array(reference), request(value)}
	displayMedian PROC
	push	ebp
	mov		ebp, esp
	mov ecx, [ebp + 8]; userinput
	mov esi, [ebp + 12]; address

	mov eax, ecx
	mov edx, 0
	mov ebx, 2
	div ebx

	cmp edx, 0
	jle evennum
	mov ebx, 4
	mul ebx
	mov ebx, [esi + eax]
	mov eax, ebx
	jmp finish
	evennum:
	mov ebx, 4
	mul ebx
	;mov edx, OFFSET notevenmess
	;call WriteString
	mov ebx, [esi+eax - 4]
	mov edx, [esi+eax]
	mov eax, ebx
	add eax, edx
	cdq
	mov ebx, 2
	div ebx

	finish:
	mov edx, OFFSET median
	call WriteString
	call WriteDec
	call Crlf
	pop ebp
	ret 8

displayMedian ENDP

; ***************************************************************
; Procedure to print instructions
; receives: nothing
; returns: instruction output
; preconditions: nothing
; registers changed : edx, ebx, ebp, esp, ecx, esi
;***************************************************************
; {parameters: array(reference), request(value), title(reference)}
displayList PROC
	;mov edx, 0
	mov ebx, 0
	push	ebp
	mov		ebp, esp
	mov ecx, [ebp+8]	;userinput
	mov esi, [ebp+12]	;address

	more:
	;mov eax, [esi + edx]
	mov eax, [esi + ebx]	;current
	call WriteDec
	mov edx, OFFSET spacing
	call WriteString
	;add edx, 4
	add ebx, 4		;next
	loop more

	endMore:
	pop ebp
	ret 8
displayList ENDP

END main
