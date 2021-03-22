%include    "asm/ps_game.asm"
bits        32

; Update the virtual size on the read-only section header.
va_org  0x400220
dd      new_size_rdata

va_section  .text
; Patch: Modify the text that gets printed when the log starts.
va_org      0x403D53
push        git_hash
add         eax, 0xE0
push        game_log_text

va_section  .rdata
; Add a string to the end of the read-only data.
va_org          rdata_end
%include                    "asm/metadata.asm"
game_log_text   db          'PS_GAME__system log start [Teos - Rev %s]', 0, 0

; Calculate the new size of the read-only data.
new_size_rdata  equ         $-$$
va_org          end