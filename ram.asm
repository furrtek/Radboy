.ENUM $C000 EXPORT
VBL_FLAG DB
INPUTS_ACTIVE DB			; Rising edges
INPUTS_PREV DB				; Continuous presses
MAP_FIRST DB
MAP_W DB

SECOND DB					; Frame counter for a second (~60 frames)

HV_ENABLE DB

COUNT_READ DB
OVF_FLAG DB
CHARGED_FLAG DB
GRAPH_TIMER DB
GRAPH_UPDATE DB

DIGIT_0 DB					; Units
DIGIT_1 DB              	; Tens
DIGIT_2 DB              	; Hundreds
DIGIT_3 DB              	; Thousands

STATE DB					; Refresh state machine

GRAPH_X DB
GRAPH_V DB

BUF_IDX DB
SMOOTH_BUF DS 5

VALUE DW

.ENDE
