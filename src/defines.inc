JOY_SIGNATURE   = 4 << 0
KEY_R           = 1 << 4
KEY_L           = 1 << 5
KEY_X           = 1 << 6
KEY_A           = 1 << 7
KEY_RIGHT       = 1 << 8
KEY_LEFT        = 1 << 9
KEY_DOWN        = 1 << 10
KEY_UP          = 1 << 11
KEY_START       = 1 << 12
KEY_SELECT      = 1 << 13
KEY_Y           = 1 << 14
KEY_B           = 1 << 15

SPRITECHR_BASE  = $0000
BG0CHR_BASE     = $2000
BG1CHR_BASE     = $3000
BG2CHR_BASE     = $4000
BG0MAP_BASE     = $5000
BG0MAP2_BASE    = $5400
BG1MAP_BASE     = $6000
BG2MAP_BASE     = $7000

BGOFFSET        = 128
.macro LDPT addr
    LDA #<addr
    STA pointer 
    LDA #>addr
    STA pointer + 1
    LDA #^addr
    STA pointer + 2
.endmacro
