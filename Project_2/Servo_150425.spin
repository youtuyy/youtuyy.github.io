' Project.spin
' (M Montgomery, A Blue, Z Lin)

CON                                                                             ' set clock speed
_clkmode = xtal1 + pll1x                                                        ' multiply base clock freq
_xinfreq = 5_000_000                                                            ' base clock freq (5 MHz)

OBJ                                                                             ' INCLUDE OTHER PROGRAMS
  lcd : "ObjectLCD"                                                             ' include objectlcd
  hyp : "ObjectSerial"                                                          ' include serial object
  mem : "ObjectMemory"                                                          ' include memory object

PUB MAIN | T,TF                                                                   ' MAIN PROGRAM
  lcd.start                                                                       ' start lcd
  lcd.clear                                                                       ' clear lcd
  repeat                                                                          ' repeat forever
    T := MEASURE_TEMP (5,357)                                                     ' call measure_temp
    TF := T*9/5-460                                                            ' convert Kalvin to Farenheit
    lcd.line1                                                                     ' move cursor to start line 1
    lcd.str(string("T ="))                                                        ' print text
    lcd.dec (TF)                                                                  ' print TF
    lcd.str(string("F"))                                                          ' print text
    lcd.line2                                                                     ' move cursor to start line 2
    if T<295                                                                      ' if T is less than 290
      SERVO (0,5)                                                                 ' move servo on pin 0 to pos 5
      lcd.str(string("Brrr.. too cold."))                                         ' print text
    elseif T==295                                                                 ' else if T is exactly 293
      SERVO (0,5)                                                                 ' move servo on pin 0 to pos 5                                                                 ' move servo on pin 0 to pos 5
      lcd.str(string("Still chilly."))                                            ' print text
    elseif T=>296 and T=<299                                                      ' else if T is in range 294-299
      lcd.str(string("Just right."))                                              ' print text
    else                                                                          ' else if T is none of the above
      SERVO (0,15)                                                                ' move servo on pin 0 to pos 15
      lcd.str(string("Too warm."))                                                ' print text
    waitcnt (clkfreq*5+cnt)                                                       ' wait 5 second
    lcd.clear                                                                     ' clear lcd



PUB MEASURE_TEMP (pin, cal) | count                                             ' MEASURE TEMPERATURE
  count := 0                                                                    ' initialize counter to zero
  outa[pin] := 0                                                                ' set pin to 0
  dira[pin] := 1                                                                ' make pin an output
  waitcnt (clkfreq/1000+cnt)                                                    ' wait cap discharge
  dira[pin] := 0                                                                ' make pin an input
  count := cnt                                                                  ' store count value
  waitpeq(|<pin,|<pin,0)                                                        ' wait for pin to go high
  count := ||(cnt-count)-11                                                     ' clock cycles-delay
  return clkfreq*10/count*cal/10000                                             ' convert count to K

PUB SERVO (pin,pos)                                                             ' CONTROL SERVO ON PIN (5=<POS=<15)
  dira[pin]:=1                                                                  ' set pin to output
  repeat 30                                                                     ' repeat for 30 pulses
    outa[pin]:=1                                                                ' turn pin on
    waitcnt(clkfreq*pos/10000+cnt)                                              ' wait during on period
    outa[pin]:=0                                                                ' turn pin off
    waitcnt(clkfreq*20/1000+cnt)                                                ' wait 20 msec for off period

PUB LED
  dira[0]:=1                                                                    '  pin 0 on

  repeat                                                                        ' loops 100 times
    outa[0] := 1                                                                ' pin 0 on
    waitcnt(clkfreq*8/1000 + cnt)                                               ' pin 0 on 4/5 of a second                      ' 80% duty cycle
    outa[0] := 0                                                                ' pin 0 off
    waitcnt(clkfreq*2/1000 + cnt)                                               ' pin 0 on 1/5 of a second