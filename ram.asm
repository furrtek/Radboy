.ENUM $C000 EXPORT
VBL_FLAG DB
INPUTS_ACTIVE DB			; Rising edges
INPUTS_PREV DB				; Continuous presses
MAP_FIRST DB
MAP_W DB
COUNT_ACC DW
SECOND DB					; Frame counter for a second (~60 frames)

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

AVG_BUFFER DS 30*2			; 30s


BUF_IDX DB

VALUE DW

.ENDE
