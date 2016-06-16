  Hours             EQU R0
  Minutes           EQU R1
  Seconds           EQU R2
  TickCounterT0     EQU R6
  HalfSecondCounter EQU R5 

  CanShowHours    EQU 00H 
  CanShowMinutes  EQU 01H
  CanShowSeconds  EQU 02H
  IsInterEX0      EQU 03H
  HalfSecondFlag  EQU 03H
  IsSignal_1000   EQU 04H
  IsSignal_500    EQU 05H
  IsSignal_Pause  EQU 06H

  ShowDigitsCounter   EQU 032H
  FlashInInterAdders  EQU 033H
  FastTimerLowAdders  EQU 034H
  FastTimerHighAdders EQU 035H



  ORG 00h
  JMP Start

  ORG 03h
  JMP InterProc_INT0
  ORG 0Bh
  JMP InterProc_TF0
  ORG 1Bh
  JMP InterProc_TF1

  InterProc_INT0:
    CLR C 
   JB P2.0, SetNotHours 
    JB P3.7, NotIncHours
     INC Hours		
	 
    NotIncHours:
    JB P3.6, NotDecHours
     DEC Hours		
	 
    NotDecHours:
    CJNE Hours, #100, ContinueHoursCheck 
     MOV Hours, #0 
	 
    ContinueHoursCheck:
    CJNE Hours, #-1, EndOfTimeSet 
     MOV Hours, #99 
    JMP EndOfTimeSet
	
   SetNotHours:
   JB P2.1, SetNotMinutes	
    JB P3.7, NotIncMinutes	
     INC Minutes
	 
    NotIncMinutes:
    JB P3.6, NotDecMinutes 
     DEC Minutes	
	 
    NotDecMinutes:
    CJNE Minutes, #60, ContinueMinutesCheck 
     MOV Minutes, #0 	
     INC Hours  	
     JMP NotDecHours   	
	 
    ContinueMinutesCheck:
    CJNE Minutes, #-1, EndOfTimeSet	
     DEC Hours 				
     MOV Minutes, #59 		
     JMP NotDecHours		
    JMP EndOfTimeSet 		
	
   SetNotMinutes:
   JB P2.2, EndOfTimeSet	
    JB P3.7, NotIncSeconds	
     INC Seconds 	
	 
    NotIncSeconds:
    JB P3.6, NotDecSeconds
     DEC Seconds	
	 
    NotDecSeconds:
    CJNE Seconds, #60, ContinueSecondsCheck 
     MOV Seconds, #0 	
     INC Minutes  	
     JMP NotDecMinutes  
	 
    ContinueSecondsCheck:
    CJNE Seconds, #-1, EndOfTimeSet 
     DEC Minutes 	
     MOV Seconds, #59 	
     JMP NotDecMinutes	
	 
   EndOfTimeSet:
   MOV  FlashInInterAdders, #10
   SETB IsInterEX0
   JMP  IfIntEX0
   IfIntEX0_RET:
   CLR  IsInterEX0
  RETI 
  
  InterProc_TF0:
   CLR  TF0
   MOV  TH0,  #high(0B1DFh)  ; timer loading
   MOV  TL0,  #low(0B1DFh)
   INC  TickCounterT0
   CJNE TickCounterT0, #25, NotSufficientTicks  ; 0.5 sec
    MOV TickCounterT0, #0
    CPL HalfSecondFlag
    INC HalfSecondCounter

    Set_T1_Mode: 
    JNB IsSignal_Pause, DoNot_Pause       
     CJNE HalfSecondCounter, #0, EnfOfSet_Pause    
      CLR TR1
      CLR P3.0 
      JMP  EndOfSignalControl 
     EnfOfSet_Pause:
     CJNE HalfSecondCounter, #1, EndOfSignalControl
      MOV HalfSecondCounter, #0
      CLR IsSignal_Pause         ; One of other flags must be true
      JMP Set_T1_Mode   
    DoNot_Pause:
    JNB IsSignal_1000, DoNot_1000       
     CJNE HalfSecondCounter, #0, EnfOfSet_1000    
      MOV  FastTimerHighAdders, #high(0FE0Bh) ; 2000 Hz 
      MOV  FastTimerLowAdders,  #low(0FE0Bh) 
      MOV  TH1,  FastTimerHighAdders  
      MOV  TL1,  FastTimerLowAdders
      SETB TR1   
      JMP  EndOfSignalControl 
     EnfOfSet_1000:
     CJNE HalfSecondCounter, #2, EndOfSignalControl
      MOV HalfSecondCounter, #0
      CLR  IsSignal_1000 
      SETB IsSignal_Pause  
      SETB IsSignal_500
      JMP Set_T1_Mode   
    DoNot_1000:
    JNB IsSignal_500, DoNot_500       
     CJNE HalfSecondCounter, #0, EnfOfSet_500    
      MOV  FastTimerHighAdders, #high(0FF05h) ; 1000 Hz 
      MOV  FastTimerLowAdders,  #low(0FF05h) 
      MOV  TH1,  FastTimerHighAdders  
      MOV  TL1,  FastTimerLowAdders
      SETB TR1   
      JMP  EndOfSignalControl 
     EnfOfSet_500:
     CJNE HalfSecondCounter, #1, EndOfSignalControl
      MOV HalfSecondCounter, #0
      CLR  IsSignal_500 
      SETB IsSignal_Pause  
      SETB IsSignal_1000
      JMP Set_T1_Mode   
    DoNot_500:
    EndOfSignalControl:

    JNB HalfSecondFlag, NotSufficientTicks    
    INC  Seconds 
    CJNE Seconds, #60, NotSufficientSeconds
     MOV  Seconds, #0
     INC  Minutes           
    NotSufficientSeconds:
    CJNE Minutes, #60, NotSufficientMinutes
     MOV  Minutes, #0
     INC  Hours           
    NotSufficientMinutes:
    CJNE Hours, #100, NotSufficientHours
     MOV  Hours, #0
    NotSufficientHours:
   NotSufficientTicks:
  RETI

  InterProc_TF1:
   CLR  TF1
   CPL  P3.0 
   MOV  TH1,  FastTimerHighAdders 
   MOV  TL1,  FastTimerLowAdders
  RETI

Start:

  MOV  IE, #0

  MOV  Hours,             #0
  MOV  Minutes,           #0
  MOV  Seconds,           #0
  MOV  TickCounterT0,     #0
  MOV  HalfSecondCounter, #0
  MOV  SP, #70h 
  MOV  P0, #00000000b
  MOV  P1, #00000000b
  MOV  P2, #11111111b
  MOV  P3, #11111110b
  


  SETB CanShowHours    
  SETB CanShowMinutes 
  SETB CanShowSeconds 
  SETB HalfSecondFlag
  CLR  IsInterEX0 
  MOV  ShowDigitsCounter, #0



  CLR  TR0
  CLR  TR1
  MOV  TH0,  #high(0B1DFh) 
  MOV  TL0,  #low(0B1DFh)
  MOV  TMOD, #00010001b
  
  SETB ET0
  SETB ET1
  SETB EA
  
  
MainLoop:
 
  CALL ShowTime
  MOV  P2, #11111111b
  
  JNB P2.3, TimeCountActivate 
   CLR  TR0     
   CLR  TR1     
   SETB EX0     
   IfIntEX0:
   INC  ShowDigitsCounter
   MOV  A, ShowDigitsCounter 
   CJNE A, #15, DoNotFlash
    MOV ShowDigitsCounter, #0
    JB P2.0, FlashNotHours 
     SETB CanShowMinutes 
     SETB CanShowSeconds 
     CPL  CanShowHours 
     JMP  DoNotFlash   
    FlashNotHours:
    JB P2.1, FlashNotMinutes 
     SETB CanShowHours    
     SETB CanShowSeconds 
     CPL  CanShowMinutes 
     JMP  DoNotFlash   
    FlashNotMinutes:
    JB P2.2, DoNotFlash
     SETB CanShowHours    
     SETB CanShowMinutes 
     CPL  CanShowSeconds 
     JMP  DoNotFlash   
    DoNotFlash:   
   JNB  IsInterEX0, EndOfFlashing 
   CALL ShowTime 
   djnz FlashInInterAdders, IfIntEX0
   JMP  IfIntEX0_RET
  TimeCountActivate:
   JB TR0, TimeCountIsActive
    SETB CanShowHours    
    SETB CanShowMinutes 
    SETB CanShowSeconds
    SETB HalfSecondFlag 
    MOV  P3, #11111110b
    MOV  HalfSecondCounter, #0
    SETB IsSignal_1000   
    CLR  IsSignal_500    
    CLR  IsSignal_Pause  
    MOV  TH0,  #high(0B1DFh) ; 50 Hz
    MOV  TL0,  #low(0B1DFh)  
    MOV  FastTimerHighAdders, #high(0FE0Bh) ; 2000 Hz 
    MOV  FastTimerLowAdders,  #low(0FE0Bh)  
    MOV  TH1,  FastTimerHighAdders 
    MOV  TL1,  FastTimerLowAdders    
    CLR  EX0     ; !!!
    SETB TR0     ; !!!
    SETB TR1     ; !!!
  TimeCountIsActive:
  ;
  EndOfFlashing:

JMP MainLoop
;============================================
  
  IndiShowDigit: ; A - DigitVal, B - Pos
    mov P0, #0
    mov P1, #0
    
    XCH  A, B
    CJNE A, #1, PosNot_1  
    SETB P0.0
    JMP EndOfSetDigit
    PosNot_1:
    CJNE A, #2, PosNot_2
    SETB P0.1
    JMP EndOfSetDigit
    PosNot_2:
    CJNE A, #3, PosNot_3
    SETB P0.2
    JMP EndOfSetDigit
    PosNot_3:
    CJNE A, #4, PosNot_4
    SETB P0.3
    JMP EndOfSetDigit
    PosNot_4:
    CJNE A, #5, PosNot_5
    SETB P0.4
    JMP EndOfSetDigit
    PosNot_5:
    CJNE A, #6, PosNot_6
    SETB P0.5
    JMP EndOfSetDigit
    PosNot_6:
    CJNE A, #7, PosNot_7
    SETB P0.6
    JMP EndOfSetDigit
    PosNot_7:
    CJNE A, #8, PosNot_8
    SETB P0.7
    JMP EndOfSetDigit
    PosNot_8:
    JMP EndOfShowDigit
    EndOfSetDigit:
    
    XCH A, B
    CJNE A, #0, DigitNot_0
    SETB P1.0
    SETB P1.1
    SETB P1.2
    SETB P1.3
    SETB P1.4
    SETB P1.5
    JMP EndOfShowDigit
    DigitNot_0:
    CJNE A, #1, DigitNot_1
    SETB P1.1
    SETB P1.2
    JMP EndOfShowDigit
    DigitNot_1:
    CJNE A, #2, DigitNot_2
    SETB P1.0
    SETB P1.1
    SETB P1.6
    SETB P1.4
    SETB P1.3 
    JMP EndOfShowDigit
    DigitNot_2:
    CJNE A, #3, DigitNot_3
    SETB P1.0
    SETB P1.1
    SETB P1.6
    SETB P1.2
    SETB P1.3
    JMP EndOfShowDigit
    DigitNot_3:
    CJNE A, #4, DigitNot_4
    SETB P1.5
    SETB P1.6
    SETB P1.1
    SETB P1.2
    JMP EndOfShowDigit
    DigitNot_4:
    CJNE A, #5, DigitNot_5
    SETB P1.0
    SETB P1.5
    SETB P1.6
    SETB P1.2
    SETB P1.3
    JMP EndOfShowDigit
    DigitNot_5:
    CJNE A, #6, DigitNot_6
    SETB P1.0
    SETB P1.5
    SETB P1.4
    SETB P1.6
    SETB P1.2
    SETB P1.3
    JMP EndOfShowDigit
    DigitNot_6:
    CJNE A, #7, DigitNot_7
    SETB P1.0
    SETB P1.1
    SETB P1.2
    JMP EndOfShowDigit
    DigitNot_7:
    CJNE A, #8, DigitNot_8
    SETB P1.0
    SETB P1.1
    SETB P1.2
    SETB P1.3
    SETB P1.4
    SETB P1.5
    SETB P1.6
    SETB P1.7
    JMP EndOfShowDigit
    DigitNot_8:
    CJNE A, #9, DigitNot_9
    SETB P1.0
    SETB P1.1
    SETB P1.5
    SETB P1.6
    SETB P1.2
    SETB P1.3
    JMP EndOfShowDigit
    DigitNot_9:
    SETB P1.6
    
    EndOfShowDigit:
    MOV 30h, #4
    WaitShowDigit:
    MOV 31h, #235
    WaitShowDigit1:
    DJNZ 31h, WaitShowDigit1
    DJNZ 30h, WaitShowDigit

  RET ; End of IndiShowDigit
;--------------------------------------------
 
  ShowHours:
    MOV A, Hours
    MOV B, #10
    DIV AB

    MOV R7, B
    MOV B, #1
    CALL IndiShowDigit

    XCH A, R7
    MOV B, #2
    CALL IndiShowDigit
  RET  ; End of ShowHours 
;--------------------------------------------

  ShowMinutes:
    MOV A, Minutes
    MOV B, #10
    DIV AB
    
    MOV R7, B
    MOV B, #4
    CALL IndiShowDigit
    
    XCH A, R7
    MOV B, #5
    CALL IndiShowDigit
  RET  ; End of ShowMinutes 
;--------------------------------------------

  ShowSeconds:
    MOV A, Seconds
    MOV B, #10
    DIV AB
    
    MOV R7, B
    MOV B, #7
    CALL IndiShowDigit
    
    XCH A, R7
    MOV B, #8
    CALL IndiShowDigit
  RET  ; End of ShowSeconds 
;--------------------------------------------

  ShowTime: 
    mov P0, #0
    mov P1, #0    
    JNB CanShowHours, DontShowHours
    CALL ShowHours
    DontShowHours:
    JNB CanShowMinutes, DontShowMinutes
    CALL ShowMinutes
    DontShowMinutes:
    JNB CanShowSeconds, DontShowSeconds
    CALL ShowSeconds
    DontShowSeconds:

    MOV  A, #10
    MOV  B, #3
    CALL IndiShowDigit
    MOV  B, #6
    CALL IndiShowDigit
  RET  ; End of ShowTime
;--------------------------------------------
;============================================
  
END



         





