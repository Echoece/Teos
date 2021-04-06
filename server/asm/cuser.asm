cuser_original_size             equ 0x5EB0
operator_new                    equ 0x503A3F
cuser_return                    equ 0x40AA72
cuser_enter_world_retn          equ 0x44A838
cuser_status_offset             equ 0x5768
cuser_max_admin_status          equ 10
cuser_packet_retn               equ 0x466DD6
cuser_bad_handshake             equ 0x466E62
cuser_char_list_retn            equ 0x46D726
cuser_enable_char_select_offset equ 0x57C0

; The new size of the CUser structure.
cuser_size:
    dd 0

; The address of the cuser_on_connect function.
cuser_on_connect:
    dd 0

; The address for receiving a packet.
cuser_on_packet_recv:
    dd 0

; The address to send the character list.
cuser_send_character_list_addr:
    dd 0

; The new initialisation routine
cuser_create:
    ;mov eax, dword [cuser_size]
    ;push eax
    push cuser_original_size
    call operator_new
    jmp  cuser_return

; Gets executed when a user enters the game world
cuser_enter_world:
    ; Call the library function.
    push eax
    mov eax, dword [cuser_on_connect]
    push ecx
    call eax
    pop eax

    ; Go back to the original function
    cmp byte [edi+cuser_status_offset], cuser_max_admin_status
    jmp cuser_enter_world_retn

; Gets executed when a packet is received from a player.
cuser_packet_recv:
    ; Call the library function.
    push eax
    mov eax, dword [cuser_on_packet_recv]
    push esi
    push edi
    call eax

    ; If the library returned true, we should no longer handle the packet.
    test al,al
    pop eax
    jne cuser_packet_recv_cancel

    ; If the first packet isn't a handshake, close the connection.
    cmp word [esi], 0xA301
    jne cuser_bad_handshake

    ; Continue processing the packet as normal
    jmp cuser_packet_retn

; Discontinue the processing of a packet (return early)
cuser_packet_recv_cancel:
    pop edi
    pop esi
    pop ebx
    mov esp,ebp
    pop ebp
    retn

; Send the character list
cuser_send_character_list:
    push edi
    mov edi, dword [cuser_send_character_list_addr]
    push ebp
    call edi
    pop edi
    mov byte [ebp + cuser_enable_char_select_offset], al ; Enable character selection if characters were found.
    jmp cuser_char_list_retn